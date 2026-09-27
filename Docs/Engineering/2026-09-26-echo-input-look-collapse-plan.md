# Horizon Echo: Input Line Inside the Card, and Collapse Mode Implementation Plan (13)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development.

**Goal** (agreed with the director on 2026-09-26, from in-game screenshots):
1. **Blizzard's input line looks like Echo's reply box.** Pressing Enter already opens Blizzard's line under the card, but it looks bolted on (a plain box with "Say:"). Echo's own box has a darker inner field, a Say chip and a send button. Make Blizzard's line sit *inside* the card in the reply box's place and look the same, while it stays Blizzard's line, so commands keep working.
2. **Collapse mode.** A new **Collapse** setting has three choices:
   - **Off**, the default.
   - **Collapse all:** every tile and the + fold into the Echo icon.
   - **Keep new messages:** tiles with a badge stay out.

   Hovering the Echo icon slides the tiles up out of it, and leaving the column folds them back.

**Spec:** `Docs/Engineering/2026-09-24-echo-chat-design.md`. The branch is `feature/echo`, and the work is part of the draft PR Tacit-Labs/Horizon-Suite#447.

## Global Constraints

- **Lua and frames:** Lua 5.1, fengari-safe. Use the Echo file header pattern. No new named frames. Echo's frames stay non-secure.
- **Blizzard's chat code:** plan 12's rules still apply, as widened by its ledger.
  - Allowed: post-hooks; `GetAttribute`, `HasFocus` and other reads; widget methods that position and style (`ClearAllPoints`, `SetPoint`, `SetScale`, `SetFrameStrata`, `SetFont`, `SetAlpha` on the box's regions, `SetTextColor` on its FontStrings, `Show`/`Hide`/`SetShown` from the activate and deactivate hooks); `HookScript` OnShow/OnHide; `SetParent(UIParent)` only as HideChat's rescue.
  - Never: calling `ChatEdit_*`, `ChatFrameUtil.*` or `ChatFrame_OpenChat`; `SetFocus`, `SetAttribute` (outside the probe), `SetText` or `SetTextInsets` on the box; writing Lua fields on the box or its regions.
  - Everything Echo changes is recorded and restored on undock.
- **Secret values:** call `Echo.IsSecret` before any `type()`, comparison or concatenation. A secret header text is shown as it is, never measured.
- **Strings and settings:** strings go through `addon.L`. New settings join `addon.ECHO_DEFAULTS` and appear on `OptionsEcho.lua`.
- **Tests:** run `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`; 2401 tests pass at the start. Write each test first and see it fail. Test sections go before "Redraw: one repaint per frame". Parse-check every changed Lua file with the fengari one-liner in `Docs/Engineering/2026-09-25-echo-options-plan.md`.
- **Commits:** Conventional Commits with scope `echo`. Run `git add` and `git commit` as separate commands. Each message ends with exactly `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Never use `git stash`. Don't push.

---

### Task 1: The input line takes the reply box's place and look

**Files:** `modules/Echo/EchoInput.lua`, `EchoCard.lua`, the strings, and the tests.

**Placement:**
- When the card is shown and the docked line is visible, anchor Blizzard's line over the card's reply-box slot, not under the card. Use the same rect as the card's `edit`, from its left edge to the send button's right edge, since the send button hides.
- Expose `Card.ReplySlot()`, which returns the frame or rect to anchor to. Add a hidden anchor frame in the card if that's the simplest way.
- The card hides its own reply box, mode chip and send button while the line covers it. It does this whenever the line is visible over the card, not only when the line's target matches the card's conversation.
- The message area keeps its normal bottom (`AREA_BOTTOM`), because the line now sits inside the card.
- **With no card shown,** the placement beside the Echo icon stays as it is and takes the new look.
- **When the line deactivates** and always-visible is off, the card's own box comes back.

**Look:**
- Echo's background behind the line becomes the reply box's style: the same fill colour as the card's `edit` background and the same radius (`SMALL`). There is no chat-coloured border any more; the chip carries the colour.
- **The chip:**
  - An Echo-owned rounded chip frame, drawn behind Blizzard's header FontString (`box.header`, read with `rawget`, or found among the regions by `GetParentKey() == "header"`).
  - It is sized to the header's rendered width plus 8px of padding each side and 22px high, in the card's `modeChip` style: accent fill at alpha 0.22, radius `SMALL`, height 22.
  - The chip takes the chat type's colour at low alpha; its fill comes from `ChatTypeInfo`.
  - The header's text colour becomes the chip label colour (0.92, 0.93, 0.98). If `headerSuffix` exists, style it the same way. Restore both on undock.
  - The header's font is Echo's, at size 10, like `modeChip.text`. Blizzard's own header update resizes the insets to the header's width, so the typed text still starts after the chip. Don't call `SetTextInsets`.
  - If the header's width is secret or unreadable, use a 48px chip.
  - Update the chip in the `UpdateHeader` post-hook, after Blizzard sets the text.
- **Hint text:** an Echo FontString, `L["ECHO_REPLY_PLACEHOLDER"]` (reuse the card's existing placeholder string if there is one), placed after the chip in the placeholder colour. It shows while the box is empty (`GetText() == ""`, when readable and not secret) and has no IME text. Update it from a `HookScript("OnTextChanged")` post-hook; add that to the allowed list for this plan.
- The box's own texture regions stay at alpha 0, as today.

**Tests:**
- With the card shown and the line visible, the line is anchored to the reply slot, and the card's box, chip and send button are hidden.
- On deactivate the card's box comes back.
- With no card shown, the line sits beside the Echo icon with the new background.
- The chip follows the header's width, falls back to 48 when the width is secret, and is coloured from `ChatTypeInfo`.
- The header's colour and font are restored on undock.
- The hint shows when the box is empty and hides when it has text.
- No `SetText`, `SetTextInsets`, `SetFocus` or `SetAttribute` is called on the box.

**Commit:** `feat(echo): Blizzard's input line takes the reply box's place and look`.

---

### Task 2: Collapse mode

**Files:** `modules/Echo/EchoTiles.lua` (or a new `EchoCollapse.lua`, loaded after `EchoTiles.lua`, if the logic is large), the defaults, `OptionsEcho.lua`, the strings, and the tests.

**Setting:** `echoCollapse`, one of `"off"`, `"all"` or `"keepnew"`, default `"off"`. It is a dropdown in the Layout or General section:
- `L["ECHO_COLLAPSE"]` = "Collapse";
- options "Off", "Collapse all" and "Keep new messages";
- `_DESC` explains hovering the Echo icon.

**State:**
- `Collapse.expanded` (boolean) and `Collapse.progress` (0..1, where 1 is fully out).
- Collapsed means progress 0: folded tiles are hidden and the + is hidden.
- In `"keepnew"`, a tile whose spec has a badge (`View.Badge` not nil, meaning a dot or a count) stays out, and so does a group tile whose group badge is set. Those tiles pack down from the bottom slot, above the Echo icon, in their normal order. The rest fold.
- **The Echo icon's badge:** while any tiles are folded, the Echo icon shows the sum of the folded tiles' unread counts as a small count pill. If any folded tile has a dot badge, it shows a dot instead. Use `Echo.Round.Dot` and the tile count-pill style.

**Opening:**
- Entering the Echo icon, or any shown tile or the + while expanded, cancels a pending fold.
- On the icon, after `Collapse.OPEN_DELAY = 0.15` seconds, it expands.
- Tiles animate up from the icon one by one. Tile i (counted from the bottom) starts `i × 0.03` seconds after the previous one. Each moves from the icon's position to its slot over `0.18` seconds with ease-out, fading its alpha from 0 to 1.
- Drive this with one OnUpdate on the column, not an AnimationGroup, so the harness can drive it with elapsed values.

**Closing:**
- Leaving the column's region (the icon, the tiles and the +) starts a fold after `Collapse.CLOSE_DELAY = 0.6` seconds.
- The fold reverses the animation, with the top tile going first.
- Don't fold while:
  - the card is shown;
  - the stack is shown;
  - the mouse is over the stack or the card;
  - a drag is in progress.

  When the card or stack hides, start the close timer if the mouse is outside.

**Everything else:**
- **Pop-ups:** `Tiles.TileFor(convKey)` returns the Echo icon for a folded tile, so the toast and the genie come from the icon. A toast for a tile kept out in `"keepnew"` comes from that tile.
- **Setting changes:** changing the setting live re-lays out at once without animation. `"off"` shows everything as today.
- **Combat:** the frames are non-secure, so it behaves the same in combat.
- **The column's own hit area:** when collapsed, it covers only the icon and any kept tiles.

**Tests:**
- `"all"` hides every tile and the +, and the Echo icon shows the summed count, or a dot when any folded tile has a dot.
- `"keepnew"` keeps badged tiles out, packed at the bottom, and folds the rest.
- Hovering the icon expands after the delay. Driving OnUpdate moves the tiles from the icon's position to their slots with the stagger, and alpha rises.
- Leaving folds after the close delay, and not while the card or stack is shown or a drag is in progress.
- Re-entering cancels a pending fold.
- `TileFor` gives the icon for a folded tile and the tile itself for a kept one.
- Switching to `"off"` restores the normal layout at once.

**Commit:** `feat(echo): collapse the column into the Echo icon`.

---

### Task 3: Record it

- **Spec:** add "Input line look and collapse mode (plan 13, 2026-09-26)" under "Interface", with the placement and look rules, why the send button hides (sending Blizzard's line from addon code would taint it), and the collapse states, timings and badge rule.
- **In-game checklist** (in this file):
  - [ ] Press Enter with a card open: the line sits where the reply box was, with a chip ("Say", "Guild", "Whisper Brisa"), and the hint shows until you type. `/g` switches the chip.
  - [ ] Press Enter with no card open: the same look beside the Echo icon.
  - [ ] `/cast` and a macro still work from the line.
  - [ ] Choose Collapse all: the tiles fold into the Echo icon, and the icon shows the unread count.
  - [ ] Hover the icon: the tiles rise one by one. Move away: they fold back after a moment.
  - [ ] Choose Keep new messages: a tile with a new message stays out, and folds after you read it.
  - [ ] A whisper while collapsed: the pop-up slides from the Echo icon.
- **Commit:** `docs(echo): record the input line look and collapse mode`.

---

## In-game checklist (plan 13, 2026-09-26)

- [ ] Press Enter with a card open: the line sits where the reply box was, with a chip ("Say", "Guild", "Whisper Brisa"), and the hint shows until you type. `/g` switches the chip.
- [ ] Press Enter with no card open: the same look beside the Echo icon.
- [ ] `/cast` and a macro still work from the line.
- [ ] Choose Collapse all: the tiles fold into the Echo icon, and the icon shows the unread count.
- [ ] Hover the icon: the tiles rise one by one. Move away: they fold back after a moment.
- [ ] Choose Keep new messages: a tile with a new message stays out, and folds after you read it.
- [ ] A whisper while collapsed: the pop-up slides from the Echo icon.
- [ ] Class, Battle.net and channel tiles show the image filling the rounded tile with no coloured edge.
- [ ] Dragging the folded Echo icon moves it without unfolding.
