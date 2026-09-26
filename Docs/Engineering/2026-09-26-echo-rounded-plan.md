# Horizon Echo: Rounded, Bubble-style Look Implementation Plan (8)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development.

**Goal:** replace Echo's square boxes with a softer, modern look, as decided with the director on 2026-09-26:
- Tiles become rounded squares, like app icons.
- The card, the stack, the reply box and the unread badges get rounded corners.
- Message bubbles become chat-app bubbles: fully rounded, with a tighter corner at the bottom on the sender's side (bottom-left for theirs, bottom-right for yours).
- Roundness is "soft": about 10px on panels and bubbles, 8px on tiles.

**Architecture:** one helper, `Echo.Round`, draws a rounded rectangle from two bundled textures, `media/echo/circle.tga` (a filled circle) and `media/echo/ring.tga` (a circle outline). Both are white with anti-aliased alpha and 128×128, already generated and in the tree.
- Each corner is a quarter of the texture (texcoords), sized to that corner's radius.
- Edges and the middle are plain colour textures.
- Tinting uses `SetVertexColor`.

This is a manual 9-slice, so it needs no newer client API and works on Retail and Forever alike.

**Spec:** `Docs/Engineering/2026-09-24-echo-chat-design.md`. The branch is `feature/echo`, and the work is part of the draft PR Tacit-Labs/Horizon-Suite#447.

## Global Constraints

- **Lua:** Lua 5.1, fengari-safe. Use the Echo file header pattern. No new named frames. Frames stay non-secure.
- **Texture paths:** `"Interface\\AddOns\\" .. (addon.ADDON_NAME or "HorizonSuite") .. "\\media\\echo\\circle.tga"`, and the same for `ring.tga`. Resolve the folder once.
- **Radii:**
  - `Echo.Round.PANEL = 10`: the card, the stack card and its behind-cards.
  - `Echo.Round.BUBBLE = 10`, and `Echo.Round.TIGHT = 3` for the bubble's sender corner.
  - `Echo.Round.TILE = 8`: column tiles and the card's row tiles.
  - `Echo.Round.SMALL = 6`: the reply box, the send button and the stack's Open button.
  - Unread badges and the dot are fully round, so their radius is half their size.
  - **A radius never exceeds half the frame's shorter side.** Clamp it when the frame is laid out.
- **Borders:** a border is drawn from `ring.tga` quarters at the corners plus 1px colour lines along the edges. It is only used where Echo already draws a border today: panels, and tiles whose face is a glyph or icon. Bubbles have no border.
- **Tests:** the test command is `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js` (1092 passing at the start).
  - The stand-in frames record calls on the object, as before.
  - Existing tests that read a frame's backdrop colour (for example a dimmed bubble's alpha) may be updated to read the rounded fill's colour instead. Name each such test in the report.
- **Parse check:** run the fengari one-liner from `Docs/Engineering/2026-09-25-echo-options-plan.md` on every changed Lua file.
- **Commits:** Conventional Commits with scope `echo`. Run `git add` and `git commit` as separate commands. Each message ends with exactly `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Never use `git stash`.

---

### Task 1: `Echo.Round`

**Files:**
- Create `modules/Echo/EchoRound.lua`, loaded in the TOC and in the test `FILES` list straight after `EchoView.lua`.
- `media/echo/circle.tga` and `media/echo/ring.tga` already exist and are committed with this task.

**Produces:**
- **`Echo.Round.Apply(frame, opts)`** creates the textures once, stored on `frame._echoRound`, and returns that handle. `opts` has these fields:
  - `radius`: the default for all four corners.
  - `corners = { tl, tr, bl, br }`: optional per-corner radii.
  - `layer`: default `"BACKGROUND"`.
  - `border`: a boolean; build the border pieces.
- **`Echo.Round.SetColor(frame, r, g, b, a)`** tints the fill: the corners and the fill rects.
- **`Echo.Round.SetBorderColor(frame, r, g, b, a)`** tints the border. Alpha 0 hides it.
- **`Echo.Round.SetCorners(frame, tl, tr, bl, br)`** changes the radii and re-lays out. Bubbles use this when a bubble switches between incoming and outgoing.
- **`Echo.Round.Layout(frame)`** re-lays out for the frame's current size. Hosts call it after `SetSize`, and it is cheap. If the frame's size can't be read (the harness), lay out with the radii unclamped.

**Geometry (fill):** let R = the largest of the four radii, clamped to half the shorter side, and let each corner c have radius r_c ≤ R. Build the fill from:
- **The middle band:** the full width, from R above the bottom to R below the top.
- **The top band and the bottom band:** each between the two corner slots, R high.
- **Each corner slot R×R:**
  - a quarter-circle texture of size r_c in the outer corner (texcoords `0–0.5` or `0.5–1` per corner; the circle's quadrant faces outward);
  - two fill rects covering the rest of the slot: R×(R − r_c) and (R − r_c)×r_c, positioned against the inner sides. They are hidden when their size is 0.

  With r_c = R, a corner is exactly the quarter circle.

**Border:**
- Four ring quarters at radius R. Per-corner radii don't apply to borders, which only uniform shapes use.
- Four 1px lines along the straight edges, between the corner quarters.

**Tests:**
- `Apply` builds the pieces once. A second `Apply` reuses them.
- A uniform radius gives four corner quarters with the right texcoords and sizes.
- A tight corner (`br = 3` with R = 10) sizes that quarter to 3 and shows both of its fill rects at the expected sizes.
- A radius bigger than half the height is clamped.
- `SetColor` tints every fill piece.
- `SetBorderColor` with alpha 0 hides the border pieces.
- The texture path uses the addon folder.

**Commit:** `feat(echo): draw rounded rectangles from bundled textures`.

---

### Task 2: Round everything

**Files:** `modules/Echo/EchoTiles.lua`, `EchoCard.lua`, `EchoStack.lua`, and the tests.

**Changes:** every Echo surface that today uses `SetBackdrop(Echo.FLAT)` or a flat colour texture as a box gets `Echo.Round` instead. Replace each `SetBackdropColor` / `SetBackdropBorderColor` call with `Echo.Round.SetColor` / `SetBorderColor`, and call `Layout` wherever the host sizes the frame.
- **Column tiles** (`CreateTile` / `PaintTile`) and the overflow tile: radius `TILE`, with a border.
  - The class icon keeps its 3px inset, which keeps its square corners inside the tile's 8px rounded corners. Don't mask it: a circle mask would crop the icon round.
  - The label shade is rounded only at the bottom: `Echo.Round` with corners `{ tl = 0, tr = 0, bl = TILE, br = TILE }`.
- **The unread dot and count badge:** fully round.
  - The dot becomes an `Echo.Round` of 8×8 with radius 4.
  - The count gets a small rounded pill behind it (height 12, radius 6, width to fit), in the accent colour, only when a count shows.
- **The card** (`root`): radius `PANEL`, with a border. Its row tiles: radius `TILE`, keeping the "shown conversation" outline as the border colour.
- **Bubbles:** radius `BUBBLE`, no border.
  - Incoming: `SetCorners(10, 10, TIGHT, 10)`, the bottom-left tight.
  - Outgoing: `SetCorners(10, 10, 10, TIGHT)`, the bottom-right tight.
  - Feed lines stay unboxed, as today.
  - Grouped consecutive bubbles from one sender keep the tight corner only on the last bubble of the group, the one nearest the next speaker; the others use full radii. Read `View.StartsGroup` to decide.
- **The reply box and the send button:** radius `SMALL`. The send button stays square-ish but rounded.
- **The stack:** the top card and its behind-cards use radius `PANEL` with a border; the Open button uses `SMALL`.
- **Leave alone:**
  - The toast. It uses Augment's shared toast chrome, and rounding it belongs in a separate change to that chrome. Note it in the report.
  - The genie sheet, which is shaped by its own boundaries.
- **Tests:**
  - A smoke test per surface: a tile, a bubble (incoming and outgoing corners), the card root, the reply box, the stack card, the badge pill. Each gets a `_echoRound` with the right radius and colour.
  - Update the existing backdrop-colour tests, and name them in the report.

**Commit:** `feat(echo): round the tiles, card, bubbles and stack`.

---

### Task 3: Record it

- **Spec:** under "Interface", add "Rounded look (plan 8, 2026-09-26)", listing the radii, the bubble corner rule, and that the toast keeps Augment's chrome for now.
- **In-game checklist** (in this file), for the director on Windows. Echo gains files, so restart the game.
  - [ ] Tiles are rounded squares, and class icons don't poke past the corners.
  - [ ] Bubbles look like a chat app: your bubbles have their tight corner at the bottom right, theirs at the bottom left.
  - [ ] Corners look smooth, with no jagged or blurry edges at scale 100% or 140%.
  - [ ] The card, the stack, the reply box and the badges are all rounded.
  - [ ] There are no seams where the corner pieces meet the edges.
- **Commit:** `docs(echo): record the rounded look`.

## In-game checklist (final-review fix wave, 2026-09-26)

For the director on Windows. Echo gains files, so restart the game.

- [ ] Tiles are rounded squares, and class icons don't poke past the corners.
- [ ] Bubbles look like a chat app: your bubbles have their tight corner at the bottom right, theirs at the bottom left.
- [ ] Corners look smooth, with no jagged or blurry edges at scale 100% or 140%.
- [ ] The card, the stack, the reply box and the badges are all rounded.
- [ ] There are no seams where the corner pieces meet the edges.
- [ ] Unread counts are readable on their pill.
- [ ] Names on whisper tiles are readable, not darkened.
- [ ] Corners look clean at UI scale 0.64 and 1.4. Look for a dotted border, or a shimmering edge.
