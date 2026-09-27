# Horizon Echo: Chat Groups and Channel Icons Implementation Plan (9)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development.

**Goal** (decided with the director on 2026-09-26):
1. **Custom chat groups.** Up to 4 named groups. Each groupable chat belongs to at most one group. A group shows as one tile in the column. Opening it shows the card with a tab per member; you read and reply per tab.
2. **Icons with a short name** on channel and feed tiles, matching the whisper tiles' class icon and name.

**Spec:** `Docs/Engineering/2026-09-24-echo-chat-design.md`. The branch is `feature/echo`, and the work is part of the draft PR Tacit-Labs/Horizon-Suite#447.

## Global Constraints

- **Code:** Lua 5.1, fengari-safe, using the Echo file header pattern. Ask `Echo.IsSecret` first for any chat value. No new named frames. Everything shown to the player goes through `addon.L`, with new keys after the last Echo key in `locales/horizon/enUS.lua`.
- **Settings:** every new setting joins `addon.ECHO_DEFAULTS`. `ECHO_KEYS` derives from it. Every key except `echoHoverDelay` must appear on `options/modules/OptionsEcho.lua`, and an existing test checks this. Table-valued settings are allowed; the profile stores tables. Read them through `Echo.Setting`, and never mutate the default table in place.
- **Groupable chats and their member ids:**

  | Member id | What it covers |
  |---|---|
  | `ch:General` | General |
  | `ch:Trade` | Trade |
  | `ch:Trade (Services)` | Services |
  | `ch:LocalDefense` | Local Defense |
  | `ch:LookingForGroup` | LFG |
  | `ch:WorldDefense` | World Defense |
  | `ch:NewcomerChat` | Newcomer |
  | `ch:*` | Any other channel ("Other channels") |
  | `guild`, `officer`, `party`, `raid`, `instance` | Those conversations |
  | `loot`, `progress`, `system` | The feeds |

  Whispers and Battle.net conversations are never grouped. A channel conversation `ch:<name>` matches its exact member id first, then `ch:*`.
- **Group keys:** `grp:1` .. `grp:4`. A group key is a *view* key only: it never enters the Store, History or Send.
- **Commits:** Conventional Commits with scope `echo`. Run `git add` and `git commit` as separate commands. Each message ends with exactly `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Never use `git stash`.
- **Tests:** `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js` (1196 passing at the start). Parse-check every changed Lua file with the fengari one-liner from `Docs/Engineering/2026-09-25-echo-options-plan.md`. Test sections go before the "Redraw: one repaint per frame" section.

---

### Task 1: Icons with a short name for channels and feeds

**Files:** `modules/Echo/EchoView.lua` and the tests.

- **`View.CHANNEL_ICONS`**, keyed like `CHANNEL_SHORT` (the channel name with spaces removed). Each value is an `Interface\Icons\` file path:

  | Channel | Icon |
  |---|---|
  | General | `Ability_Warrior_RallyingCry` |
  | Trade | `INV_Misc_Coin_01` |
  | `Trade(Services)` and `Services` | `Trade_BlackSmithing` |
  | LocalDefense | `INV_Shield_06` |
  | LookingForGroup | `INV_Misc_GroupNeedMore` |
  | WorldDefense | `Ability_Warrior_DefensiveStance` |
  | NewcomerChat | `INV_Misc_Book_09` |

  Any other channel keeps today's glyph face, its short name on the dark tile.
- **`View.GROUP_ICON`** = `Interface\Icons\Spell_Holy_PrayerOfSpirit`, used by group tiles in Task 3.
- **`View.TileSpec`:**
  - A channel with an icon gets `face = "icon"`, `icon = path` (cropped, not `iconFull`), `glyph = true`, `label = <its short name>` (the current `CHANNEL_SHORT` value, or `ShortName(name, 4)`), and the channel chat colour.
  - Feeds keep their icons and gain labels, from new strings: `L["ECHO_FEED_SHORT_LOOT"] = "Loot"`, `L["ECHO_FEED_SHORT_PROGRESS"] = "Prog"`, `L["ECHO_FEED_SHORT_SYSTEM"] = "Sys"`.
  - A label now shows on any face that has one. Check the painter and the column tile's label shade: today's code shows the shade only when `spec.label` is non-empty, which already works.
- **Tests:** General, Trade and Services get their icons and labels. An unknown channel stays a glyph. Feeds carry labels. Update the existing channel-face tests, and name each in the report.

**Commit:** `feat(echo): icons and short names on channel and feed tiles`.

---

### Task 2: The group model

**Files:** create `modules/Echo/EchoGroups.lua`, loaded after `EchoView.lua` in the TOC and in the test `FILES` list. Also the defaults file, `EchoView.lua` (`View.Column` and friends), and the tests.

**Settings:**
- `echoGroupsEnabled`, default `true`.
- `echoGroupNames`, default `{ "Channels", "", "", "" }`. A blank name means the group is unused.
- `echoGroupOf`, default `{ ["ch:General"] = 1, ["ch:Trade"] = 1, ["ch:Trade (Services)"] = 1, ["ch:LocalDefense"] = 1, ["ch:LookingForGroup"] = 1 }`. It maps member id to group index; an absent entry means none.

**Produces:**
- **`Echo.Groups.Of(convKey) -> index|nil`**. It returns nil when:
  - groups are switched off;
  - the kind isn't groupable;
  - the group's name is blank or unreadable;
  - the index is out of 1..4.
- **`Echo.Groups.Name(index) -> string`**.
- **`Echo.Groups.Members(index, list) -> { conv, … }`**: the open conversations in that group, in Store order.
- **`Echo.Groups.Key(index) -> "grp:<index>"`** and **`Echo.Groups.IndexOf(key) -> index|nil`**.
- **`View.Column(list, maxTiles)`** now builds *entries*. It walks the Store list in order. Each ungrouped conversation is an entry as today. The first time a grouped conversation appears, it inserts one group entry at that position; later members of the same group are skipped. A group entry is `{ key = "grp:i", kind = "group", group = i, members = {…}, open = true }`. The +N overflow counts entries.
- **`View.TileSpec` for a group entry:**
  - `face = "icon"`, `icon = View.GROUP_ICON`, `label = ShortName(Groups.Name(i), 6)`, `glyph = true`, accent colour `View.ACCENT`.
  - The badge: `"dot"` if any member's badge is `"dot"`, else `"count"` if any member's is `"count"`, else nil.
  - `count` = the sum of the members' unread.
- **`View.Badge`, `View.DisplayName` and `View.NewestLoud`** stay per conversation. Group entries are only for the column and the card row. **Don't change `Store.List`.**

**Tests:**
- `Of` follows the settings: exact channel, `ch:*` fallback, off switch, blank name, non-groupable whisper.
- `Column` merges members into one entry at the first member's position; overflow counts entries.
- A group spec sums counts and takes the loudest badge.
- Settings tables aren't mutated.

**Commit:** `feat(echo): group chats into named groups in the column`.

---

### Task 3: Group tiles, pop-ups, stack and card tabs

**Files:** `EchoTiles.lua`, `EchoStack.lua`, `EchoCard.lua`, `EchoGenie.lua` (only if needed), the strings, and the tests.

- **Column:**
  - A group entry paints through the normal painter.
  - `Tiles.TileFor(convKey)` returns the group tile when `convKey` belongs to a group that has a tile, so pop-ups and the genie anchor to it.
  - Clicking a group tile calls `Card.Toggle("grp:i", tile)`.
  - Hovering it peeks at the stack on the group's newest member (the member with the highest `lastLoud`, else the first).
- **Card:**
  - `Card.Open` / `Show` / `Toggle` accept a group key. The card keeps `groupIndex` and a selected member key. The selected member is the member last selected in this session, else the newest one.
  - Everything that renders a conversation (messages, reply box, menu, title) uses the selected member. `renderedKey` is the member's key, so drafts, the scroll anchor and read-marking all keep working per member.
  - The title reads `<group name> · <member name>`.
  - **The row of tiles across the top** shows entries (group tiles and ungrouped conversations), not raw conversations. The shown entry is outlined.
  - **A tab strip:** for a group card, a row of small rounded tabs appears under the header, one per open member.
    - Each tab is `Echo.Round` with radius `SMALL`, and shows the member's short name.
    - The selected tab is filled with the accent; the others are dim.
    - An unread member shows a dot, via `Echo.Round.Dot`.
    - Clicking a tab selects that member.
    - The message area starts below the strip: shift `AREA_TOP` by the strip's height for group cards only.
  - **Toggle-close from a group tile** runs the reverse genie into the group tile.
  - Closing a member through the ⋯ menu closes that member. If none are left, the card hides.
- **Pop-ups:** a loud message from a member shows its toast, which already names the member, anchored through `TileFor` to the group tile. Holding and releasing in combat is unchanged, because it works per conversation.
- **Stack:** it keeps showing conversations (members) as today. It isn't grouped.
- **Tests:**
  - A group tile shows for grouped channels.
  - A click opens the card on the newest member, with tabs.
  - Clicking a tab switches member and keeps drafts per member.
  - The toast anchors to the group tile.
  - `TileFor(member)` returns the group tile.
  - The row shows a group entry.
  - The toggle-close genie goes into the group tile.
  - Closing the last member hides the card.

**Commit:** `feat(echo): open a group as tabs in the card`.

---

### Task 4: Groups on the options page

**Files:** `options/modules/OptionsEcho.lua`, the strings, and the tests.

- A **Groups** section after Feeds:
  - the toggle `echoGroupsEnabled`;
  - four editboxes, "Group 1 name" .. "Group 4 name", writing a **copy** of `echoGroupNames` with one entry changed;
  - then one dropdown per groupable chat, in the order of the member table, labelled with the chat's name. Its options are "None" plus each non-blank group name (use "Group N" when a name is blank but the group is referenced). Setting it writes a copy of `echoGroupOf` with that entry set to the index, or removed.
- The existing "every default is on the page" test must pass. `echoGroupNames` and `echoGroupOf` are covered through `dbKey`, so give the first editbox `dbKey = "echoGroupNames"` and the first dropdown `dbKey = "echoGroupOf"`.
- **Tests:** renaming group 2 writes a copy. Assigning Loot to group 2 and back to None writes copies. The dropdown options list the named groups.

**Commit:** `feat(echo): configure chat groups on the options page`.

---

### Task 5: Record it

- **Spec:** add "Chat groups and channel icons (plan 9, 2026-09-26)" covering the rules above, including that group keys are view-only.
- **In-game checklist** (in this file). Echo gains files, so restart the game.
  - [ ] General, Trade and Services show as one "Channels" tile with an icon and name. Its badge adds up their unread.
  - [ ] Opening it shows tabs. Switching tabs changes the channel you read and reply to, and a draft stays with its tab.
  - [ ] A pop-up from Trade slides out from the Channels tile.
  - [ ] Rename a group and move Loot into it on the options page; the column updates without a reload.
  - [ ] Channel icons show, not blank squares, on Retail and Forever.
  - [ ] The guild tile shows your guild's emblem in its colours.
  - [ ] The Echo icon shows at the foot of the column and on the dashboard.
  - [ ] Setting a channel to None while "Other channels" is grouped keeps that channel on its own.
- **Commit:** `docs(echo): record chat groups and channel icons`.
