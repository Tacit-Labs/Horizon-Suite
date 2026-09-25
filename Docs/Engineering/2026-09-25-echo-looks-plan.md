# Horizon Echo: Looks and Tidy-ups Implementation Plan (6 of 6)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:**
- Class icons with a short name on whisper tiles, and a Battle.net logo for friends not on a character.
- Short names on channel tiles, so General and Guild no longer share "G".
- One tile painter and one badge rule shared by every surface.
- The card keeps your place when scrolled up.
- Drafts are dropped when you close a conversation.
- Header text is upper-cased only on English clients.

**Architecture:**
- **Tile spec.** `View.TileSpec` becomes the single description of a tile. It gains:
  - `face`: `"icon"`, `"class"`, `"letter"` or `"glyph"`
  - `classIcon`
  - `label`
  - `small`, a multi-character glyph
  - `iconFull`, meaning don't crop

  Its badge comes from a new `View.Badge`.
- **Painter.** `Echo.PaintTileFace(face, spec)` draws any tile host: the column tile, the card's row tile, the stack card's tile and the toast icon. A *host* is a small table of the textures and font strings it owns. The painter doesn't change any host's layout.
- **Card.** It counts messages that arrive while you're scrolled up, keeps the view still, and shows a clickable "new messages" hint.

**Tech Stack:** WoW Lua 5.1 addon (Retail 120100 and Forever 16001), and the fengari harness `tools/test_echo_logic.js`.

**Spec:** `Docs/Engineering/2026-09-24-echo-chat-design.md`, sections "Interface" and "Carried into plan 6".

**Plan series:**
1. Foundation (done)
2. Tiles and stack (done)
3. Card (done)
4. Feeds and links (done)
5. Settings, dashboard and redraws (built; in-game check pending)
6. **Looks and tidy-ups (this plan)**

Then finalisation: one PR from `feature/echo`.

## Global Constraints

- **Lua:** Lua 5.1 only, and runnable on fengari's 5.3. Don't use `goto`, `//`, bitwise operators, `unpack`, `tinsert` or `%z`.
- **File header:** every Echo file starts with `local addon = _G.HorizonSuite` and `if not addon then return end`, and hangs off `addon.Echo`.
- **Secret values:** ask `Echo.IsSecret(v)` before `type()`, comparing, concatenating, formatting, matching or indexing by a chat value. A secret text is passed to `SetText` **alone**. Never read a size from a FontString holding secret text.
- **Battle.net `|K` names are never cut, matched or measured.** That is why Battle.net tiles carry no name label.
- **Frame names:** no new frame names. Frames are non-secure. Strings shown to the player go through `addon.L` (`locales/horizon/enUS.lua`, Echo block, after `L["ECHO_SLASH_UNKNOWN"]`).
- **Textures:**
  - Battle.net logo: `Interface\FriendsFrame\Battlenet-Battleneticon`, uncropped (texcoords 0–1).
  - Class icons: `addon.ResolveClassIconDisplay(class, "custom")` (bundled Horizon art, `core/ClassIconMedia.lua`). If that returns nil, use `addon.ResolveClassIconDisplay(class, "default")` (Blizzard's class atlas). If both return nil, the tile falls back to the letter face.
  - Feed icons: unchanged, cropped 0.08–0.92.
- **Short names:**
  - Whisper: the name without its realm, at most **5** characters.
  - Channel: its entry in `View.CHANNEL_SHORT` if it has one, else at most **4** characters.
  - Characters are counted UTF-8 aware with the existing pattern `[\1-\127\194-\244][\128-\191]*`.
  - Glyphs P, R, I, G and O stay for party, raid, instance, guild and officer.
- **`View.CHANNEL_SHORT`:** `{ General = "Gen", Trade = "Trade", LocalDefense = "Def", LookingForGroup = "LFG", Services = "Serv", WorldDefense = "WDef", NewcomerChat = "New" }`. The keys are the channel name as stored in the conversation key (`ch:<name>`). A channel with a space in its key has the space ignored for the lookup ("Local Defense" → "LocalDefense").
- **Commits:** Conventional Commits with scope `echo`, on branch `feature/echo`, each ending with exactly one `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` trailer. Run `git add` and `git commit` as separate commands. Never use `git stash`.
- **Test command:** `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js` (815 passing at the start). Every existing test that pinned the old one-letter faces is updated to the new faces in the same task, and each update is named in the report. No other existing assertion is weakened.
- **Parse check:** run the fengari one-liner from `Docs/Engineering/2026-09-25-echo-options-plan.md` Global Constraints on every changed Lua file.
- **Stand-in frames:** `STUB_FRAME` / `STUB_CREATE_FRAME`. Stubs record `SetText`, `SetPoint`, `SetSize` and `SetBackdropColor`. Add recording for `SetTexture`, `SetAtlas`, `SetColorTexture` and `SetTexCoord` to `STUB_FRAME` if a test needs to read them back. Keep the pattern: store the arguments on the object.

## File map

| File | Change |
|------|--------|
| `modules/Echo/EchoView.lua` | `ShortName`, `CHANNEL_SHORT`, `Badge`, `Upper`, `FaceBackground`, the new `TileSpec` fields, `BNET_LOGO` |
| `modules/Echo/EchoTiles.lua` | `Echo.PaintTileFace(face, spec)` rewritten; column tile gets a label and uses the painter; toast uses it |
| `modules/Echo/EchoStack.lua` | Stack card tile uses the painter; meta through `View.Upper`; closed-conversation draft dropped |
| `modules/Echo/EchoCard.lua` | Row tiles use the painter; scroll anchoring and the new-messages hint; meta through `View.Upper`; closed-conversation draft dropped |
| `locales/horizon/enUS.lua` | `ECHO_NEW_BELOW` |
| `tools/test_echo_logic.js` | Tests |
| `Docs/Engineering/2026-09-24-echo-chat-design.md` | Record plan 6 |

---

### Task 1: One description of a tile

**Files:** `modules/Echo/EchoView.lua`, `tools/test_echo_logic.js`

**Produces:**
- `View.ShortName(s, max) -> string`. Returns `""` for secret, empty or non-string input.
- `View.CHANNEL_SHORT`
- `View.BNET_LOGO`
- `View.Badge(conv) -> "dot"|"count"|nil`. It is `nil` when unread is 0. Loud gives `"dot"` and count gives `"count"`; quiet and muted give `nil`.
- `View.Upper(s) -> string`. It upper-cases only when `GetLocale()` is `"enUS"` or `"enGB"`, and returns other strings unchanged. It also returns `s` unchanged when `s` is secret or not a string.
- `View.FaceBackground(spec) -> r, g, b, a`:
  - glyph and icon faces use `GLYPH_BG`
  - the Battle.net logo uses `BNET`, at alpha 0.95
  - class and letter faces use the spec colour, at alpha 0.95
- `View.TileSpec(conv)` returns:

```lua
{
    face = "icon" | "class" | "letter" | "glyph",
    icon = path|nil,        -- face "icon": feed icon or the Battle.net logo
    iconFull = true|nil,    -- don't crop (the Battle.net logo)
    classIcon = { kind = "file", path = … } | { kind = "atlas", atlas = … } | nil,  -- face "class"
    letter = string,        -- face "letter": the initial; face "glyph": P/R/I/G/O or a channel short name; else ""
    small = true|nil,       -- letter is more than one character (draw it smaller)
    label = string|nil,     -- whisper tiles only: View.ShortName(name, 5)
    glyph = true|nil,       -- kept for existing callers: true for "glyph" and feed "icon" faces
    r, g, b,                -- accent: class colour, Battle.net blue, chat colour
    badge = View.Badge(conv), count = conv.unread or 0,
}
```

**Face rules:**
- **Feed:** `face = "icon"` with its feed icon; `glyph = true`.
- **Whisper:**
  - `label = View.ShortName(name, 5)`, where `name` is the conversation key without `w:` and without `-Realm`.
  - With a readable class that resolves an icon: `face = "class"` and `classIcon`.
  - Otherwise: `face = "letter"`, `letter = View.Initial(name)`.
  - `r, g, b` is the class colour, else `NEUTRAL`.
- **Battle.net:**
  - With a readable class that resolves an icon: `face = "class"`, no label.
  - Otherwise: `face = "icon"`, `icon = View.BNET_LOGO`, `iconFull = true`, and `r, g, b = BNET`.
- **Group kinds:** `face = "glyph"`, with the letter from `View.GLYPHS`.
- **Channel:**
  - `face = "glyph"` and `letter = CHANNEL_SHORT[key without spaces] or View.ShortName(name, 4)`.
  - `small = true` when the letter is more than one character.
  - `r, g, b = View.ChatColor("channel")`.

- [ ] **Step 1: Write the failing tests.** Add a section "View: tile faces" before the Redraw section. Cover:
  - **`ShortName`:** `"Brisa"` gives `"Brisa"`. `"Thornwick"` with 5 gives `"Thorn"`. `"Éowyn-Horizon"` isn't passed in; callers strip the realm. Accented `"Ælfrida"` with 5 gives `"Ælfri"` (five characters, not five bytes). A secret gives `""`.
  - **Channel short names:** `ch:General` gives `"Gen"` and `ch:Guild` isn't a channel. The `guild` kind gives `"G"`. `ch:Trade` gives `"Trade"`. `ch:Local Defense` gives `"Def"`. `ch:MyCustom` gives `"MyCu"`. `small` is true for all of these multi-character letters.
  - **Whisper class face:** with `ResolveClassIconDisplay` stubbed to return `{ kind = "file", path = "X" }` for DRUID, a whisper from a druid gives `face == "class"`, `classIcon.path == "X"` and `label == "Brisa"`.
  - **Whisper letter face:** with the stub returning nil, the face is `"letter"`, the letter `"B"` and the label `"Brisa"`.
  - **Battle.net:** with no class, `face == "icon"`, `icon == View.BNET_LOGO`, `iconFull == true` and no label. With a class, `face == "class"` and no label.
  - **Feeds:** a feed is still `face == "icon"` with its feed icon and without `iconFull`.
  - **`Badge`:** loud with unread gives `"dot"`, count gives `"count"`, quiet gives `nil`, and 0 unread gives `nil`.
  - **`Upper`:** with `GetLocale` stubbed to `"enUS"`, `Upper("abc")` is `"ABC"`. With `"deDE"`, `Upper("über")` is unchanged. Restore `GetLocale` afterwards.
  - **Restore every stub** at the end of the section: `HorizonSuite.ResolveClassIconDisplay` and `GetLocale`.

- [ ] **Step 2: Run them.** They fail.

- [ ] **Step 3: Implement.**
  - Add `View.CHANNEL_SHORT` and `View.BNET_LOGO = "Interface\\FriendsFrame\\Battlenet-Battleneticon"`.
  - `View.ShortName` walks `gmatch("[\1-\127\194-\244][\128-\191]*")` up to `max`.
  - `View.Badge(conv)` reads `Echo.Store.TierOf(conv.key)`.
  - A local `ClassIcon(class)` calls `addon.ResolveClassIconDisplay` as the constraints say, inside `pcall`, and returns nil when the function is missing.
  - Rewrite `View.TileSpec` to the shape and rules above.
  - Upper-case only through `View.Upper`, and add `View.FaceBackground`.

- [ ] **Step 4: Fix existing tests** that pinned the old faces. For example, a whisper tile's `letter == "B"` stays true only on the letter face. Channel `"G"` for General becomes `"Gen"`. Run the full suite; all pass.

- [ ] **Step 5: Commit:** `feat(echo): describe tile faces with class icons, logos and short names`.

---

### Task 2: One painter for every tile

**Files:** `modules/Echo/EchoTiles.lua`, `modules/Echo/EchoStack.lua`, `modules/Echo/EchoCard.lua`, `tools/test_echo_logic.js`

**Produces:** `Echo.PaintTileFace(face, spec)`, which replaces the old `(icon, letter, spec)` signature. `face` is a host table:

```lua
{
    bg = Texture|nil,        -- filled with View.FaceBackground(spec); nil when the host paints its own backdrop
    icon = Texture,          -- shown for "icon" and "class" faces
    letter = FontString,     -- the initial or glyph
    label = FontString|nil,  -- the whisper short name; hosts too small for it leave it nil
    size = number,           -- letter font size for one character
    smallSize = number,      -- letter font size when spec.small
}
```

**Painter rules:**
- **`bg`:** when present, `SetColorTexture(View.FaceBackground(spec))`.
- **`icon`:**
  - For `"icon"`: `SetTexture(spec.icon)`, then texcoords 0–1 if `spec.iconFull`, else 0.08–0.92. Show it.
  - For `"class"`: if `classIcon.kind == "atlas"`, call `SetAtlas(classIcon.atlas)`; otherwise `SetTexture(classIcon.path)` with texcoords 0–1. Show it.
  - Otherwise hide it.
- **`letter`:**
  - `Echo.TrackFont(letter, spec.small and face.smallSize or face.size, "OUTLINE")` whenever the size it last used differs. Keep the last size on the font string as `letter._echoSize`.
  - Text: `spec.letter` for `"letter"` and `"glyph"`, else `""`.
  - Colour: the spec colour for glyphs, dark `(0.05, 0.05, 0.07)` for letters.
- **`label`:** when present, `SetText(spec.label or "")` in near-white `(0.95, 0.96, 1)`.

**Hosts:**
- **Column tile** (`EchoTiles.lua` `CreateTile` / `PaintTile`):
  - Add `b.label = Echo.NewText(b, 9, "OUTLINE")` at `BOTTOM, 0, 2`, with `SetWordWrap(false)`.
  - Add `b.labelShade`, a texture across the bottom 12px at `(0, 0, 0, 0.55)`. It is shown only when the label is non-empty.
  - The host is `{ icon = b.icon, letter = b.letter, label = b.label, size = 16, smallSize = 10 }`, with no `bg`: the tile keeps its backdrop, now coloured with `View.FaceBackground(spec)`.
  - The border is the spec colour at 0.8 for glyph and icon faces, and `(0, 0, 0, 0.7)` otherwise, as today.
  - Class icons fill the tile inset 3px, as feed icons do.
  - The badge comes from `spec.badge`, as today.
  - The overflow tile keeps its own "+N" painting.
- **Card row tile** (`EchoCard.lua` `PaintTile`): `{ icon = b.icon, letter = b.letter, size = 12, smallSize = 8 }`, backdrop from `FaceBackground`. Keep the outline for the shown conversation. The dot uses `spec.badge ~= nil`, as today.
- **Stack card tile** (`EchoStack.lua`): `card.tile` is currently the tile texture itself.
  - Add `card.tileIcon = card:CreateTexture(nil, "OVERLAY")` over `card.tile`, inset 2.
  - The host is `{ bg = card.tile, icon = card.tileIcon, letter = card.letter, size = 14, smallSize = 9 }`.
  - Delete the three-way branch.
- **Toast icon** (`EchoTiles.lua` `ShowToast`): the host is `{ bg = entry.icon, … }`, but the toast's `entry.icon` is also its chrome anchor. So add `entry.face = f:CreateTexture(nil, "OVERLAY")` over `entry.icon`, and use the host `{ bg = entry.icon, icon = entry.face, letter = entry.letter, size = 14, smallSize = 9 }`. Delete the three-way branch.

- [ ] **Step 1: Write the failing tests.** Extend `STUB_FRAME` to record `SetTexture`, `SetAtlas`, `SetColorTexture` and `SetTexCoord` if needed. Add a section "One painter" that, for each host (column tile, card row tile, stack card tile, toast), paints:
  - a class-icon whisper: icon shown, texture or atlas set, label `"Brisa"` on the column tile only;
  - a Battle.net logo: icon shown, full texcoords;
  - a General channel: letter `"Gen"` at the small size;
  - a party glyph: letter `"P"` at the full size.

  Also check that the column tile's label shade is hidden for a glyph tile.

- [ ] **Step 2: Run them.** They fail.

- [ ] **Step 3: Implement** the painter and the four hosts as above.

- [ ] **Step 4: Full suite, then parse-check.**

- [ ] **Step 5: Commit:** `feat(echo): paint every tile through one painter`.

---

### Task 3: Keep your place, drop closed drafts, upper-case only in English

**Files:** `modules/Echo/EchoCard.lua`, `modules/Echo/EchoStack.lua`, `locales/horizon/enUS.lua`, `tools/test_echo_logic.js`

**Behaviour:**
- **Scroll anchoring.** `Card.OnStoreChange(convKey, change)`: when `convKey == renderedKey` and `change` is one of `"toast"`, `"count"`, `"quiet"` or `"silent"`, a message was added to the shown conversation. If `offset > 0`, the player is reading older messages:
  - `offset = offset + 1` and `newBelow = newBelow + 1`, then **don't** mark the card for a render. Nothing on screen moves.
  - Update the hint: `hint.text:SetText(L["ECHO_NEW_BELOW"]:format(newBelow))` and show it.
  - Still mark `"cardRow"`, because the row's badges may change.
  - If `offset == 0`, behave as today.
- **The hint** is a `Button` at the bottom centre of the message area, `L["ECHO_NEW_BELOW"] = "%d new ↓"`, in the accent colour on the panel background. Clicking it sets `offset = 0` and `newBelow = 0`, hides it and renders.
- **Clearing the hint.** Scrolling down to `offset == 0` (`Card.Scroll`), switching conversations (the `renderedKey` change in `Render`), `Card.Submit` and `Card.Hide` all reset `newBelow = 0` and hide the hint.
- **Closed drafts.** When a conversation is closed (`change == "closed"`), its draft is discarded: `Echo.TakeDraft(convKey)`, with the result ignored.
  - In `Card.OnStoreChange`, if the closed key is `renderedKey`, first `edit:SetText("")` and set `renderedKey = nil`, so the next `Render` doesn't park the closed conversation's text again.
  - In `Stack.OnStoreChange`, change the signature to `(convKey, change)` and do the same for the stack's rendered key and its edit box.
  - Both hold drafts for the same conversation, so both discard. `TakeDraft` is idempotent.
- **Upper-case.** `metaText:SetText(View.Upper(View.CardMeta(conv)))` in the card, and `card.meta:SetText(View.Upper(View.MetaLine(...)))` in the stack.

- [ ] **Step 1: Write the failing tests** in a section "Card: keep your place". Open the card on a conversation with 30 messages and scroll up 5 (`Card.Scroll(5)`). Then:
  - Record the text of `bubbles[1]` and add 3 incoming messages. The bubble text is unchanged, the hint shows `"3 new ↓"` (use rawset on `L` for `ECHO_NEW_BELOW`, as plan 5 did), and the card didn't re-render.
  - Clicking the hint shows the newest message in `bubbles[1]` and hides the hint.
  - At the bottom (offset 0), a new message renders at once with no hint.
  - Drafts: type a draft in the card for Brisa, then close Brisa with `Store.Close`. `Echo.TakeDraft("w:Brisa-Horizon") == ""`. When Brisa messages again and the card is reopened on it, the box is empty. Do the same for the stack.
  - With `GetLocale` returning `"deDE"`, the card meta isn't upper-cased. Restore the stub afterwards.

- [ ] **Step 2: Run them.** They fail.

- [ ] **Step 3: Implement.** Keep the existing plan 5 redraw marks.

- [ ] **Step 4: Full suite, then parse-check.**

- [ ] **Step 5: Commit:** `feat(echo): keep the card still while scrolled up and drop closed drafts`.

---

### Task 4: Record it

**Files:** `Docs/Engineering/2026-09-24-echo-chat-design.md`, `.luacheckrc`

- [ ] **Spec.**
  - Under "Collapsed: tiles", replace the letter rule with the new faces: class icon plus short name, Battle.net logo, channel short names, and the kept glyphs. Note that Battle.net tiles carry no name because `|K` names can't be cut.
  - Under "Expanded: card", add scroll anchoring and the hint.
  - Under Storage or Interface, add: "Closing a conversation drops its unsent draft on purpose".
  - Change "Carried into plan 6" to "Plan 6 did", listing each item.
- [ ] **`.luacheckrc`:** add any new read globals, if missing (none are expected; `GetLocale` and `GetClassAtlas` are already there).
- [ ] **Commit:** `docs(echo): record plan 6`.

---

### Task 5: In-game check (Windows PC, a human step)

`/reload` is enough; the TOC doesn't change.

- [ ] Whisper yourself and have a friend whisper you. Each tile shows the class emblem with the short name across the bottom, and the class colour shows in the frame.
- [ ] A Battle.net friend in the app, not in WoW, shows the Battle.net logo on blue. The same friend on a WoW character shows their class icon.
- [ ] General and Trade tiles read "Gen" and "Trade". Guild still reads "G".
- [ ] The toast, the stack card and the card's tile row show the same faces as the column.
- [ ] Open a busy channel, scroll up, and wait. What you're reading doesn't move, and "N new below" appears. Click it to jump to the newest messages.
- [ ] Type a draft to someone, close the conversation with ×, and have them message again. The reply box is empty.
- [ ] The Forever beta: class icons resolve, or fall back to the letter without errors.
- [ ] With a wide bottom bubble and a status line under it (a pending or failed send), the hint is still visible above them and clickable, not covered.
- [ ] The Battle.net logo reads clearly against the blue tile background, at both the column size and the larger card/stack sizes.
- [ ] On a whisper tile set to the count tier, the label shade and the unread count are both readable at once: the count sits clear of the name instead of overlapping it.
- [ ] Join the Services channel and use `/h echo probe` to confirm it; its tile reads "Serv", not the raw channel name or "Serv"'s first-4-character fallback.
