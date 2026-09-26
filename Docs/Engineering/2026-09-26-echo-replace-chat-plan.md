# Horizon Echo: Replacing Blizzard Chat Implementation Plan (12)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development.

**Goal:** make Echo able to stand in for Blizzard's chat windows, so the player mostly never sees Blizzard's chat. Agreed with the director on 2026-09-26. This plan replaces the separate plans 12–14 of the roadmap in the spec.

**Pattern:** it follows how Chattynator does this. We read Chattynator's current source (the `hippuli/Chattynator` mirror, version 224, Interface 120100 and 16001) on 2026-09-26 to learn the pattern, and copied no code.
- Blizzard's chat windows are moved onto a hidden parent, and their events are switched off. The one exception is that `ChatFrame1` keeps `CHAT_MSG_WHISPER`, `CHAT_MSG_BN_WHISPER` and `CAUTIONARY_CHAT_MESSAGE`, which the game needs to remember who **R** replies to.
- Blizzard's own input line, `ChatFrame1EditBox`, is kept, restyled and re-anchored. Enter, `/`, **R** and Blizzard's **Whisper** keep working, because they are the game's own.
- Blizzard's chat code is only observed, through `hooksecurefunc` post-hooks. The addon never calls it and never replaces it, never opens the input line or moves the focus into it, and never changes where typing goes.
- Other addons' `print` output is captured with a `hooksecurefunc` on `DEFAULT_CHAT_FRAME.AddMessage`. `debugstack` tells a print apart from Blizzard's own event handler adding a line.
- Other addons' chat filters run through `ChatFrameUtil.ProcessMessageEventFilters`, or `ChatFrame_GetMessageEventFilters` on older clients.

**Spec:** `Docs/Engineering/2026-09-24-echo-chat-design.md`, "Towards replacing Blizzard chat". The branch is `feature/echo`, and the work is part of the draft PR Tacit-Labs/Horizon-Suite#447.

## Global Constraints

- **Lua:** Lua 5.1, fengari-safe. Use the Echo file header pattern. No new named frames. Echo's frames stay non-secure.
- **Blizzard's chat code:**
  - Allowed: `hooksecurefunc` post-hooks on `ChatFrameUtil.*`, `ChatEdit_*`, `ChatFrame1EditBox` methods and `DEFAULT_CHAT_FRAME.AddMessage`; reading the input line's attributes (`GetAttribute`); and widget methods that position and style it (`ClearAllPoints`, `SetPoint`, `SetScale`, `SetAlpha` on its textures, `SetFontObject`, `Show` and `Hide` from inside the Activate and Deactivate post-hooks, as Chattynator does).
  - Never: calling `ChatEdit_*`, `ChatFrameUtil.*` or `ChatFrame_OpenChat`; replacing any Blizzard global or method; calling `SetFocus` on the input line; calling `SetAttribute` on it, except in Task 1's probe; or writing Lua fields on it.
- **Secret values:** call `Echo.IsSecret` before any `type()`, comparison or concatenation. `debugstack()` can be secret in Midnight, so check it before calling `find` on it. Battle.net `|K` strings are never parsed.
- **Strings and settings:** strings go through `addon.L`. New settings join `addon.ECHO_DEFAULTS` and appear on `OptionsEcho.lua`.
- **Restore:** everything Echo changes on a Blizzard frame is recorded, so it can be put back when its setting goes off, or when the module is disabled. Hiding Blizzard's chat is the exception: turning that off asks for a reload, through the existing reload prompt pattern.
- **Tests:** run `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`; 2031 tests pass at the start. Write each test first and see it fail.
  - Stub `ChatFrame1EditBox`, `ChatFrameUtil`, `DEFAULT_CHAT_FRAME`, `CHAT_FRAMES` and `debugstack` in each task's own test section.
  - Test sections go before "Redraw: one repaint per frame".
  - Parse-check every changed Lua file with the fengari one-liner in `Docs/Engineering/2026-09-25-echo-options-plan.md`.
- **Commits:** Conventional Commits with scope `echo`. Run `git add` and `git commit` as separate commands. Each message ends with exactly `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Never use `git stash`. Don't push.

---

### Task 1: The input-line safety probe

This finds out in game whether Echo may point Blizzard's input line at a conversation. If it can, a later plan lets clicking a tile make typing go there, so the card's own reply box can go.

**Files:** `modules/Echo/EchoSlash.lua`, the strings, and the tests.

**`/h echo probe input <target>`:**
- The target is `guild`, `say`, or a whisper `Name-Realm`.
- The probe sets `ChatFrame1EditBox`'s `chatType` attribute to `GUILD`, `SAY` or `WHISPER`, and sets `tellTarget` for a whisper.
- It then prints instructions (in `addon.L`):
  1. Run `/console taintLog 1`.
  2. Press Enter and send a message. It should go to the chosen target.
  3. In combat, type a `/cast` of one of your spells in the same box.
  4. Check for "Interface action failed because of an AddOn", and for Horizon Suite lines in `Logs/taint.log`.
- `/h echo probe input reset` sets `chatType` back to `SAY`.
- Out of combat only. In combat it prints "Try again out of combat".

**Tests:**
- The probe sets the attributes on a stub.
- It refuses in combat.
- `reset` works.
- It is the only code path that calls `SetAttribute` on the input line. Assert this by grepping the loaded sources in the test for `SetAttribute(` near `ChatFrame1EditBox`.

**Commit:** `feat(echo): a probe for pointing Blizzard's input line`.

---

### Task 2: Blizzard's input line, docked and restyled

**Files:** create `modules/Echo/EchoInput.lua`, loaded after `EchoCard.lua` in the TOC and in the test `FILES` list. Also `EchoCard.lua` and `EchoTiles.lua` for anchors, the defaults, `OptionsEcho.lua`, the strings, and the tests.

**Settings:**
- `echoDockInput`, default `true`.
- `echoInputAlwaysVisible`, default `false`.

**`Input.Enable` / `Input.Disable`** follow `echoDockInput` live.
- **On enable,** record `ChatFrame1EditBox`'s points (`GetNumPoints` and `GetPoint(i)`), its scale, and the alpha of each of its texture regions.
- **Restyle it:**
  - Set the alpha of Blizzard's border and focus textures to 0. These are the edit box's own texture regions; don't touch its FontStrings.
  - Add a background frame behind it: an unnamed child of the Echo column's parent, one frame level below the edit box's. Draw it with `Echo.Round` at radius `SMALL`, in Echo's panel colour, and colour its border with the input line's chat colour.
  - Set the edit box's FontStrings to Echo's font, through `Echo.FontPath` and `TrackFont`.
- **Anchor it:**
  - When the card is shown, the line goes under the card, flush with its bottom edge, at the card's width, with a 4px gap.
  - When no card is shown, it goes beside the Echo icon at the column's foot, opening on `View.PanelEdge(Card.WIDTH)`'s side, at `Card.WIDTH`.
  - Re-anchor on card show and hide, on edge, scale and position changes, and on `ApplyOptions`.
- **Show and hide it.** Post-hook `ChatFrameUtil.ActivateChat` / `DeactivateChat`, or `ChatEdit_ActivateChat` / `ChatEdit_DeactivateChat`, whichever exists. For `ChatFrame1EditBox` only:
  - On activate, `Show()`.
  - On deactivate, `SetShown(echoInputAlwaysVisible)`, with alpha 1 when shown.
  - With `echoInputAlwaysVisible` on, the line is shown at enable. Clicking a visible line is the game's own click, so it opens normally.
  - The hooks are installed once, and do nothing while docking is off.
- **Colour it:** post-hook `ChatFrame1EditBox.UpdateHeader`, or `ChatEdit_UpdateHeader`. Colour the background's border from `ChatTypeInfo[chatType]`, and use the channel's colour for `CHANNEL`.
- **On disable,** restore the points, scale and texture alphas, hide the background, and stop re-anchoring.
- **Combat:** `ChatFrame1EditBox` isn't protected, so re-anchoring in combat is allowed. Still, check it with `InCombatLockdown` guards if anything protected is touched. Nothing should be.
- **The card:** when the docked line is shown and its target is the conversation the card shows (Task 3's `Input.TargetKey()`), hide the card's own reply box and send button, and shrink the message area to match. Show them again otherwise.

**Tests:**
- Enable records and restyles, and disable restores the exact points, scale and alphas.
- The anchor follows the card: shown, then hidden, then the column foot. The edge rule is checked for both edges.
- The Activate and Deactivate hooks show and hide the line, honouring always-visible, and ignore other edit boxes.
- The header hook colours the border.
- Toggling the setting live works.
- The card hides its reply box while the line targets its conversation.
- No `SetFocus` or `SetAttribute` is called on the stub.

**Commit:** `feat(echo): dock Blizzard's input line under Echo`.

---

### Task 3: Echo follows the input line

**Files:** `EchoInput.lua`, `EchoCard.lua`, and the tests.

**`Input.TargetKey() -> convKey|nil`** reads `ChatFrame1EditBox:GetAttribute("chatType")`, together with `tellTarget` and `channelTarget`:

| `chatType` | Conversation |
|---|---|
| `WHISPER` | `w:` .. `Send.WhisperKeyFor(tellTarget)`, reusing `Store.WhisperKeyLike` |
| `BN_WHISPER` | the `bn:<accountID>` whose account name equals `tellTarget`, compared as whole strings (never parsed) and found through `BNGetNumFriends` / `C_BattleNet.GetFriendAccountInfo`; else nil |
| `GUILD`, `OFFICER`, `PARTY`, `RAID`, `INSTANCE_CHAT` | `guild`, `officer`, `party`, `raid`, `instance` |
| `SAY`, `YELL`, `EMOTE` | `nearby` |
| `CHANNEL` | the channel key for `GetChannelName(channelTarget)`, through `Events.ChannelKeyName` |

A secret or unreadable attribute gives nil.

**Following the line:**
- In the `UpdateHeader` post-hook, when docking is on and the line is shown and has focus (`HasFocus`), work out the target key.
- If it differs from the last followed key:
  - `Store.Start(key)`;
  - `Card.Show(key, Tiles.TileFor(key))`, which opens without focusing the card's box;
  - for Nearby, `Store.SetSendMode("nearby", chatType)`;
  - remember the key.
- Clear the remembered key on deactivate.
- Never follow while the card is animating a close.
- This covers Blizzard's **Whisper** from any right-click menu, **R**, `/w Name`, `/g` and `/1`, all typed in Blizzard's line.

**Tests:**
- Every row of the table maps as shown.
- A Battle.net match is by whole string, and an unknown one gives nil.
- The hook opens the card once per target change, doesn't open it when the line isn't focused, and doesn't open it when docking is off.
- Nearby's mode follows YELL.
- The card isn't given focus.

**Commit:** `feat(echo): open the conversation the input line is aimed at`.

---

### Task 4: The All view and other addons' filters

**Files:** `EchoStore.lua`, `EchoEvents.lua`, `EchoView.lua`, `EchoTiles.lua` (the All tile), a new `modules/Echo/EchoAll.lua` (loaded after `EchoEvents.lua`), the defaults, `OptionsEcho.lua`, the strings, and the tests.

**The All feed:**
- Add the feed kind `all`, with conversation key `"all"`. It is read-only, quiet, never persisted, never groupable, and capped at `Store.ALL_CAP = 500` lines.
- Its tile uses the icon `Interface\Icons\INV_Misc_Note_01` and the label `L["ECHO_ALL_SHORT"] = "All"`. The card title is `L["ECHO_ALL"] = "All chat"`.
- Setting: `echoAllView`, default `true`. When it's off, the tile doesn't appear.
- It is filled from two sources:
  1. **Every record Echo files,** through a Store listener on change events. Each becomes an All line: `record.text`, prefixed with the conversation's short name and the sender, in that chat type's colour, keeping `secret` as it is. A secret line's text is shown with `SetText` and never concatenated: keep the prefix in a separate field, which the view renders as its own FontString or as the line's label. Outgoing lines are included.
  2. **Everything else printed to the main chat window:** addon prints, Blizzard system text that isn't an event, and `/dump`.
     - Post-hook `DEFAULT_CHAT_FRAME.AddMessage`.
     - Skip the call when `debugstack()` is secret, or when it contains `ChatFrame_OnEvent`, `MessageEventHandler` or `Blizzard_Channels`, because those lines come from chat events Echo already files.
     - Also skip calls from Echo itself (`Interface/AddOns/HorizonSuite/modules/Echo`).
     - The line keeps the given text and r, g, b. A secret text is shown and never inspected.
- Never add a line twice. Source 2 sees only non-event lines, and source 1 sees only Echo's records.

**Filters:**
- In `EchoEvents`, before `BuildRecord`, run the event's arguments through `ChatFrameUtil.ProcessMessageEventFilters(ChatFrame1, event, ...)` when it exists, or else through the same loop over `ChatFrame_GetMessageEventFilters(event)`.
- If a filter blocks the line, drop it, and count it as filtered for the probe. If a filter returns new arguments, use them.
- Run it inside `pcall`, so a broken filter keeps the original arguments.
- Record in the report that, with Blizzard's windows still showing, filters run twice per line (once for Blizzard, once for Echo). Filters that remember what they've seen by line ID handle that.

**Tests:**
- Records are mirrored into All with their prefix, a secret record keeps `secret`, and the cap is enforced.
- The `AddMessage` hook skips event-handler stacks, secret stacks and Echo's own calls, and keeps addon prints.
- A filter that blocks drops the line, a filter that rewrites changes the text, and a filter that throws keeps the original.
- The setting hides the tile.

**Commit:** `feat(echo): an All view, and respect other addons' chat filters`.

---

### Task 5: Hide Blizzard chat

**Files:** create `modules/Echo/EchoHideChat.lua` (loaded after `EchoInput.lua`), `EchoModule.lua`, the defaults, `OptionsEcho.lua`, the strings, and the tests.

**Settings:**
- `echoHideBlizzardChat`, default `false`.
- `echoKeepCombatLog`, default `true`.

**When the setting is on,** apply it at `PLAYER_ENTERING_WORLD`, one frame later (`C_Timer.After(0)`), and never in combat. If in combat, wait for `PLAYER_REGEN_ENABLED`.
- **Move the windows away.** For each name in `CHAT_FRAMES`, except `ChatFrame2` while `echoKeepCombatLog` is on:
  - Reparent the window and its `<name>Tab` to an unnamed hidden frame that Echo owns.
  - Post-hook the tab's `SetParent`, so Blizzard can't bring it back.
- **Silence their events.**
  - `UnregisterAllEvents()`, then re-register `UPDATE_CHAT_COLOR` on each window. On `ChatFrame1` also re-register `CHAT_MSG_WHISPER`, `CHAT_MSG_BN_WHISPER` and `CAUTIONARY_CHAT_MESSAGE`, each only when `C_EventUtils.IsEventValid` says it exists.
  - Post-hook each window's `RegisterEvent` to unregister anything else again.
- **Hide Blizzard's chat buttons:** `ChatFrameMenuButton`, `ChatFrameChannelButton`, `QuickJoinToastButton`, `ChatFrameToggleVoiceDeafenButton` and `ChatFrameToggleVoiceMuteButton`, whichever exist. Reparent them to the hidden frame.
- **Keep whispers inline.** Set the `whisperMode` CVar to `inline`, and save the previous value in Echo's per-character settings.
- **The combat log, with `echoKeepCombatLog` on:** leave `ChatFrame2` and its tab alone. The Dock manager may take it with it when `ChatFrame1` moves; checking that is an in-game item. Note in the report what you expect.
- **Turning the setting off:** restore `whisperMode` and ask for a reload, with `L["ECHO_HIDE_CHAT_RELOAD"]` through the existing reload prompt. Nothing is un-hidden live.
- **Safety.** Everything runs from Echo's module code, so if Echo is disabled or fails to load, nothing is hidden. Disabling the module with the setting on also asks for a reload.
- **Requirement:** the option needs docking on. If `echoDockInput` is off, turning this on turns docking on too, and says so in its description.

**Tests:**
- Applying it reparents every window except the combat log, and the combat log too when `echoKeepCombatLog` is off.
- `ChatFrame1` keeps exactly its three whisper events, only for events that exist.
- A later `RegisterEvent` is undone, and the buttons are reparented.
- `whisperMode` is saved and set, then restored on off.
- Nothing is applied in combat until combat ends.
- Turning it off asks for a reload.
- Turning it on turns docking on.

**Commit:** `feat(echo): an option to hide Blizzard's chat windows`.

---

### Task 6: Record it

- **Spec:**
  - Replace the roadmap table in "Towards replacing Blizzard chat" with what was built.
  - Add "Replacing Blizzard chat (plan 12, 2026-09-26)" under "Interface". Cover:
    - the Chattynator-derived pattern (credit what was learned, and say that no code was copied);
    - the allowed and forbidden calls from the Global Constraints;
    - the three events `ChatFrame1` keeps, and why;
    - the All view's two sources;
    - filters;
    - the probe's purpose.
- **In-game checklist** (in this file). Echo gains files, so restart the game.
  - [ ] Press Enter: the restyled input line opens under the open card, or beside the Echo icon. `/cast` and a macro work from it, including in combat.
  - [ ] Right-click a name in Echo or on a unit frame, choose Blizzard's **Whisper**: the line opens aimed at them, and their Echo card opens above it.
  - [ ] Press **R** after a whisper: the same happens for the sender.
  - [ ] `/g`, `/1` and `/y` typed in the line switch the card to match.
  - [ ] With the line aimed at the shown card's chat, the card's own reply box is hidden, so there is only one box.
  - [ ] The All tile shows chat, addon messages (try `/dump 1`) and system text in order.
  - [ ] A spam-filter addon's blocked lines don't appear in Echo.
  - [ ] Turn on **Hide Blizzard chat** and reload: no Blizzard chat window or tab is visible, whispers still arrive in Echo, **R** still replies, and the combat log is still available.
  - [ ] Turn it off: the reload prompt appears, and after reloading Blizzard chat is back.
  - [ ] Run `/h echo probe input guild`, follow its steps, and report whether `/cast` in combat was blocked. This decides the follow-up plan.
- **Commit:** `docs(echo): record replacing Blizzard chat`.
