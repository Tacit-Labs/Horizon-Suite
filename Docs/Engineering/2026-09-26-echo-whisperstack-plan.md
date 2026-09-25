# Horizon Echo: Ideas from Whisper Stack Implementation Plan (7)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Five improvements the director picked after reviewing "Whisper Stack", a player-made addon by Devin (a review of 2026-09-26):
1. A smarter class lookup, so more tiles get class icons.
2. Whisper sound choices.
3. Invite to group from a whisper.
4. An Auto screen edge.
5. The card growing out of the tile you clicked.

**Ownership:** Whisper Stack carries no licence. Every idea here is reimplemented in Echo's own code. **Do not copy or paraphrase Whisper Stack source, and do not ship its sound file.** Take the ideas only from this plan.

**Spec:** `Docs/Engineering/2026-09-24-echo-chat-design.md`. The branch is `feature/echo`. The work is part of the open draft PR Tacit-Labs/Horizon-Suite#447.

## Global Constraints

- **Lua and style:** Lua 5.1, fengari-safe: no `goto`, `//`, bitwise operators, `unpack`, `tinsert` or `%z`. Use the Echo file header pattern (`local addon = _G.HorizonSuite` / `if not addon then return end`).
- **Secret values:** ask `Echo.IsSecret(v)` before `type()`, comparing, concatenating, formatting, matching or indexing any value that came from the game: roster names, class names, Battle.net game-account fields, `UnitName` results. Battle.net `|K` names are never cut, matched or measured.
- **Taint:**
  - Never write to Blizzard chat frame fields (for example `tellTimer`).
  - Never hook or replace Blizzard chat functions.
  - Never call protected functions outside a click handler.
- **Strings:** everything shown to the player goes through `addon.L`. Add new keys to `locales/horizon/enUS.lua` after `L["ECHO_CARD_TEXT_SIZE_DESC"]`, aligned with their neighbours.
- **Settings:** every new setting is added to `addon.ECHO_DEFAULTS`. `ECHO_KEYS` derives from it automatically. Every setting except `echoHoverDelay` must appear on `options/modules/OptionsEcho.lua`, which an existing test enforces.
- **Commits:** Conventional Commits with scope `echo`, one per task. Run `git add` and `git commit` as separate commands. Each message ends with exactly `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Never use `git stash`.
- **Test command:** `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js` (935 passing at the start). Parse-check every changed Lua file with the fengari one-liner in `Docs/Engineering/2026-09-25-echo-options-plan.md`.
- **Stubs:** stand-in frames (`STUB_FRAME`) answer every unknown method with a no-op returning nil. So code must tolerate `CreateAnimationGroup()` returning nil. Restore every global a test stubs.

---

### Task 1: Find a whisperer's class without a GUID

**Files:**
- Create `modules/Echo/EchoClass.lua`, loaded in the TOC and in the test `FILES` list after `EchoView.lua`.
- Modify `modules/Echo/EchoView.lua`, `modules/Echo/EchoModule.lua` and `HorizonSuite.toc`.

**Why:** a tile shows a class icon only when a message carried the sender's class. Restored history, Battle.net friends and some whispers have none, so their tiles fall back to a letter.

**Produces:**
- `Echo.Class.Resolve(conv) -> class|nil, source|nil`. `source` is `"message"`, `"group"`, `"guild"`, `"friends"` or `"bnet"`.
- `View.ClassOf(conv)` replaces every `View.LastClass(conv)` call used for colour or icon (`EchoView.lua` has four). It returns `View.LastClass(conv)` first, else `Echo.Class.Resolve(conv)`.

**Rules:**
- **Whisper** (`w:Name-Realm`): look the name up in the sources below, in order, and stop at the first match.
  1. **Group:** `raid1..40` when `IsInRaid()`, else `party1..4`. Build each unit's name from `UnitName(unit)`, which returns the name and the realm, where the realm is nil or empty for your own realm. Compare it against the conversation key; the class is `select(2, UnitClass(unit))`.
  2. **Guild:** when `IsInGuild()`, loop `1..GetNumGuildMembers()`. `GetGuildRosterInfo(i)` gives the full name as its first return and the class file as its 11th.
  3. **Friends:** `C_FriendList.GetNumFriends()` and `C_FriendList.GetFriendInfoByIndex(i)`. `info.name` may lack the realm, in which case append yours. `info.className` is localized, so map it back to a class file by reversing `LOCALIZED_CLASS_NAMES_MALE`, then `LOCALIZED_CLASS_NAMES_FEMALE`.
  - Guard every API with an existence check and `pcall`. Guard every value with `IsSecret`.
- **Caching:**
  - A found class is cached on the conversation (`conv.resolvedClass`, `conv.classSource`) and never re-looked-up.
  - A miss is remembered for 5 seconds (`conv.classMissAt`), so a busy guild roster isn't scanned on every repaint.
- **Battle.net** (`bn:<id>`): `C_BattleNet.GetAccountInfoByID(id)`. When `gameAccountInfo.clientProgram == BNET_CLIENT_WOW` (fallback `"WoW"`) and `className` is readable, map it as above. This is never cached, because a friend can switch characters.
- **Refresh:**
  - `EchoClass` registers `GROUP_ROSTER_UPDATE`, `GUILD_ROSTER_UPDATE`, `FRIENDLIST_UPDATE` and, on Battle.net builds, `BN_FRIEND_INFO_CHANGED`. The registration happens in `Echo.Class.Enable()`, called from `Echo.Init`, and is undone in `Echo.Class.Disable()`.
  - On any of these events: clear `classMissAt` on open conversations that have no class, then `Echo.Redraw.Mark("tiles")`, `"stack"` and `"card"`. `Mark` already coalesces.
- **Debug:** `/h echo status` rows gain ` class=<file>(<source>)` when the conversation has a class. The strings go through `L`: extend `ECHO_SLASH_STATUS_ROW` with one more `%s`.

**Tests** (a "Class lookup" section):
- A group member, a guild member and a friend each resolve, with the right source. Stub `IsInRaid`, `UnitName`, `UnitClass`, `IsInGuild`, `GetNumGuildMembers`, `GetGuildRosterInfo`, `C_FriendList` and `LOCALIZED_CLASS_NAMES_MALE`.
- A message class wins over lookups.
- A secret roster name is skipped.
- A miss isn't re-scanned within 5 seconds; stub `Store.Now` or `GetTime`.
- A Battle.net friend on WoW gets their class, and one in the app gets nil.
- A roster event marks the views.
- A tile spec for a restored whisper with a guild-found class is `face == "class"`.

**Commit:** `feat(echo): find a whisperer's class from group, guild and friends`.

---

### Task 2: Whisper sound choices

**Files:**
- Create `modules/Echo/EchoSound.lua`, loaded after `EchoFilter.lua`.
- Modify `modules/Echo/EchoFilter.lua`, the defaults file, `OptionsEcho.lua`, the strings and `HorizonSuite.toc`.

**Behaviour:**
- **Settings:**
  - `echoWhisperSound`, default `"blizzard"`. Values:

    | Value | Sound | Label |
    |---|---|---|
    | `"blizzard"` | `SOUNDKIT.TELL_MESSAGE` | "Blizzard whisper" |
    | `"toast"` | `SOUNDKIT.UI_BNET_TOAST` | "Battle.net toast" |
    | `"ping"` | `SOUNDKIT.MAP_PING` | "Map ping" |
    | `"off"` | none | "Off" |

    Each value falls back to `TELL_MESSAGE` when its SOUNDKIT key is missing.
  - `echoSoundInCombat`, default `true`.
  - `echoSoundBnet`, default `true`.
- **`Echo.Sound.Whisper(isBnet, preview)`** plays the chosen sound through `PlaySound(id, "Master")`, inside `pcall`. Unless `preview`, it returns without playing when:
  - the choice is `"off"`;
  - it is in combat and `echoSoundInCombat == false`;
  - `isBnet` and `echoSoundBnet == false`;
  - the last play was less than 1.5 seconds ago (`GetTime`).
- **Where it plays:** only for the whispers Echo hides from Blizzard's chat. `EchoFilter`'s `Alert()` now calls `Echo.Sound.Whisper(event == "CHAT_MSG_BN_WHISPER")` instead of `PlaySound(TELL_MESSAGE)`. The once-per-event dedupe and `FlashClientIcon` stay.
- **Where it doesn't:** whispers Blizzard still shows keep Blizzard's own sound, because Echo must not touch Blizzard's chat frames to silence it (see Global Constraints, Taint). The option's description says so: `ECHO_WHISPER_SOUND_DESC` = "The sound for whispers Echo hides from Blizzard's chat. Whispers shown in Blizzard's chat keep its own sound."
- **Options page** (Notifications section):
  - a dropdown for the sound
  - a Button `ECHO_SOUND_PREVIEW` ("Play sound") calling `Echo.Sound.Whisper(false, true)`
  - toggles for "Play in combat" and "Battle.net whispers too"

**Tests:**
- Each choice plays its SOUNDKIT id, and a missing key falls back.
- Off plays nothing.
- The combat and Battle.net switches, the throttle, and preview bypassing all three.
- The existing filter alert tests still pass, with the sound now coming via `Echo.Sound`.
- The options page lists the three new keys.

**Commit:** `feat(echo): choose the sound for whispers Echo hides`.

---

### Task 3: Invite from a whisper

**Files:** `modules/Echo/EchoView.lua` (`MenuSpec`), `modules/Echo/EchoMenu.lua`, the strings, and the tests.

**Behaviour:**
- `View.InviteTarget(conv) -> "Name-Realm"|nil`:
  - **Whisper:** the key without `w:`.
  - **Battle.net:** `gameAccountInfo.characterName` .. `"-"` .. `gameAccountInfo.realmName`, only when the friend is on WoW and both fields are readable non-empty strings.
  - **Anything else:** nil.
- `View.MenuSpec` adds `{ kind = "button", label = L["ECHO_INVITE"], action = "invite" }` straight after the pin button, only when `InviteTarget` is non-nil. `L["ECHO_INVITE"]` = "Invite to group".
- `Menu.Run(convKey, "invite")` calls `C_PartyInfo.InviteUnit(target)` when it exists, else the global `InviteUnit(target)`, inside `pcall`. It runs from the menu click, which is a hardware event.

**Tests:**
- A whisper menu has Invite, and a group or feed menu doesn't.
- A Battle.net friend on WoW has Invite targeting Name-Realm; one in the app, or with a secret name, has none.
- Running it calls the stubbed `C_PartyInfo.InviteUnit` with the target.
- Existing menu-order tests are updated, and named in the report.

**Commit:** `feat(echo): invite a whisperer to your group from the menu`.

---

### Task 4: Auto screen edge

**Files:** `modules/Echo/EchoView.lua`, `EchoTiles.lua`, `EchoStack.lua`, `EchoCard.lua`, the defaults, `OptionsEcho.lua`, the strings, and the tests.

**Behaviour:**
- `echoColumnEdge` gains `"auto"`, and **the default becomes `"auto"`**.
- `Echo.View.Edge() -> "left"|"right"`:
  - `"left"` and `"right"` are returned as set.
  - For `"auto"` (or any unknown value): when the column exists and has a centre, return `"left"` if `centerX * column:GetScale() < UIParent:GetWidth() / 2`, else `"right"`. Without a column or a centre, return `"right"`.
- Every `Echo.Setting("echoColumnEdge")` read in the three views, including the default-corner check in `Tiles.ApplyPosition`, uses `Echo.View.Edge()` instead. An undragged `"auto"` column sits in the right corner, as today.
- **Options:** the dropdown offers Auto (`L["ECHO_EDGE_AUTO"]` = "Auto") first. The setter still clears a dragged position when switching to Left or Right, but not when switching to Auto.
- After a drag ends (`OnDragStop`), call `Echo.ApplyOptions()`, so an open stack or card re-anchors to the new side. Or re-anchor directly, whichever path is already available.

**Tests:**
- Auto with a column centred on the left half opens panels to the right.
- Auto on the right half opens them to the left.
- Explicit Left and Right still win.
- No column gives right.
- The options dropdown lists auto, right and left.
- Update the existing edge tests that assumed the old default.

**Commit:** `feat(echo): add an Auto screen edge that follows the column`.

---

### Task 5: The card grows out of the tile

**Files:** `modules/Echo/EchoCard.lua`, `modules/Echo/EchoTiles.lua` (the tile click), the defaults, `OptionsEcho.lua`, the strings, and the tests.

**Behaviour:**
- **Setting:** `echoAnimateCard`, default `true`: "Animate the card" in the Card section. `ECHO_ANIMATE_CARD_DESC` = "Grow the card out of the tile you clicked."
- **When it plays:** `Card.Open` shows the root, and then, if the setting is on and the card wasn't already shown, plays a 0.15-second animation built once on `root` by `root:CreateAnimationGroup()`:
  - a `Scale` from 0.85 to 1, with its origin at the root's panel point (`View.PanelSides(View.Edge()).panel`), which is the corner nearest the column;
  - an `Alpha` from 0 to 1;
  - smoothing `"OUT"`.
- **Nil-safe:** skip the animation when `CreateAnimationGroup` returns nil, as it does in the harness.
- **Opening from a tile:** a tile click passes the tile to `Card.Toggle` / `Card.Open` as an optional `fromTile`. When `fromTile` is given, the scale origin moves to the tile's vertical position within the card, clamped to the card's height. The card appears to grow out of that tile. Without a tile (a toast, the stack's Open button or a keybind), it grows from the panel corner.
- **Reduced motion:** combat doesn't matter, because the card doesn't open in combat. The setting is the switch.

**Tests** (stub `root.CreateAnimationGroup` for the tests that need it, returning a recorder):
- Opening builds and plays the animation once.
- A second Open while shown doesn't replay it.
- With the setting off, nothing plays.
- A nil group doesn't error.
- A tile click passes the tile.
- The options page lists `echoAnimateCard`.

**Commit:** `feat(echo): grow the card out of the tile you clicked`.

---

### Task 6: Record it

- **Spec:**
  - Add a short "Ideas from Whisper Stack (plan 7, 2026-09-26)" subsection covering the five features.
  - State the sound rule: Echo's sound plays only for whispers Echo hides, and Blizzard keeps its own.
  - Record that Echo never writes Blizzard chat-frame fields.
  - Note that Whisper Stack had no licence, and that its ideas were reimplemented, not copied.
- **Commit:** `docs(echo): record plan 7`.

### Task 7: In-game check (Windows PC, human)

`/reload` isn't enough: the TOC gains files, so restart the game.

- [ ] Whisper someone from your guild after a reload. Their restored tile shows the class icon.
- [ ] A Battle.net friend on a WoW character shows their class icon.
- [ ] With "Hide whispers Echo has stored" on, each sound choice plays on a whisper. Play sound previews it. Off is silent. With hiding off, Blizzard's own ding plays once.
- [ ] Invite to group from a whisper's ⋯ menu sends the invite.
- [ ] Auto edge: drag the column to the left half of the screen. The stack, card and pop-ups open to its right.
- [ ] Clicking a tile, the card grows smoothly out of it. With "Animate the card" off, it just appears.
