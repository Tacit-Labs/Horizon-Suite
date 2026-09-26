# Horizon Echo: Start a Chat, Nearby and Chat Shortcuts Implementation Plan (11)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development.

**Goal:** the first step towards Echo replacing Blizzard's chat windows (see "Towards replacing Blizzard chat" in the spec), agreed with the director on 2026-09-26:
1. **Nearby.** A new conversation collects Say, Yell, emotes and NPC speech. You can reply as Say, Yell or Emote.
2. **Chat shortcuts in the reply box.** `/s`, `/y`, `/e`, `/g`, `/o`, `/p`, `/ra`, `/i`, `/w Name`, `/r` and `/1`–`/9` send to the right place, switching the card to that conversation. Any other slash command is never sent as chat. The box keeps the text and shows a hint instead.
3. **Start a chat.** A **+** button at the foot of the column opens a menu of places to talk. Picking one opens the card on that conversation with the reply box focused, even when it has no messages yet.

**Spec:** `Docs/Engineering/2026-09-24-echo-chat-design.md`. The branch is `feature/echo`, and the work is part of the draft PR Tacit-Labs/Horizon-Suite#447.

## Global Constraints

- **Lua:** Lua 5.1, fengari-safe: no `goto`, `//`, bitwise operators, `unpack`, `tinsert` or `%z`. Use the Echo file header pattern. No new named frames. Frames stay non-secure.
- **Secret values:** call `Echo.IsSecret` before any `type()`, comparison or concatenation on a chat value or a Blizzard return. Secret text may be shown with `SetText`, but is never measured, compared or stored. Battle.net `|K` strings are never cut, matched or stored.
- **Strings:** everything shown to the player goes through `addon.L`. New keys go after the last Echo key in `locales/horizon/enUS.lua`.
- **Settings:** every new setting joins `addon.ECHO_DEFAULTS` and appears on `options/modules/OptionsEcho.lua`; an existing test checks this.
- **Sending:** everything goes through `Echo.Send`. Never call Blizzard's chat edit box functions (`ChatEdit_*`, `ChatFrame_OpenChat`), and never hook them: that taints protected commands.
- **Harness frames:** the stand-in frames answer unknown keys with no-op functions. Read Echo's own cached fields with `rawget(frame, "_field")`.
- **Tests:** run `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`; 1625 tests pass at the start. Write each test first and see it fail. Test sections go before the "Redraw: one repaint per frame" section. Parse-check every changed Lua file with the fengari one-liner in `Docs/Engineering/2026-09-25-echo-options-plan.md`.
- **Commits:** Conventional Commits with scope `echo`. Run `git add` and `git commit` as separate commands. Each message ends with exactly `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Never use `git stash`. Don't push.

---

### Task 1: The Nearby conversation

**Files:** `EchoStore.lua`, `EchoEvents.lua`, `EchoSend.lua`, `EchoView.lua`, `EchoCard.lua` and `EchoStack.lua` (for display), the defaults, `OptionsEcho.lua`, the strings, and the tests.

**Kind and events:**
- Add the kind `nearby`, with conversation key `"nearby"`. Its default tier is `quiet`, with the setting `echoTierNearby = "quiet"` shown on the options page alongside the other tiers.
- It is never persisted. It isn't groupable in plan 9's groups.
- Route these events to it:

  | Event | `record.style` |
  |---|---|
  | `CHAT_MSG_SAY` | `"say"` |
  | `CHAT_MSG_YELL` | `"yell"` |
  | `CHAT_MSG_EMOTE` | `"emote"` (custom `/e` text) |
  | `CHAT_MSG_TEXT_EMOTE` | `"textemote"` (built-in emotes; the text already includes the name) |
  | `CHAT_MSG_MONSTER_SAY` | `"npc"` |
  | `CHAT_MSG_MONSTER_YELL` | `"npcyell"` |
  | `CHAT_MSG_MONSTER_EMOTE` | `"npcemote"` |

- Outgoing detection is the same as for other kinds, comparing the sender with the player. NPC lines are never outgoing.
- `record.sender` is set as for group chat, including for NPC lines: the NPC's name, when readable.
- Mentions work as for party chat, so a mention of your name on a count tier toasts.
- Check how `Events` registers events and whether Forever has them. Register only events the client knows, using the existing capability pattern.

**Display:**
- The tile uses `face = "icon"`, icon `Interface\Icons\Ability_Warrior_BattleShout`, label `L["ECHO_NEARBY_SHORT"] = "Near"`, and the Say chat colour.
- The card title is `L["ECHO_NEARBY"] = "Nearby"`.
- In the card and the stack, Nearby lines are bubbles like group chat, with the sender's name above each run. By style:
  - Yell text uses the Yell chat colour.
  - Emote and text-emote lines are full-width lines in the Emote chat colour, like feed lines. `emote` shows `<sender> <text>`, and `textemote` shows the text only. The sender is shown only when it is readable and not secret; a secret line shows its text alone.
  - NPC lines use the NPC Say, NPC Yell and NPC Emote chat colours.
  - Read the colours from `ChatTypeInfo` (`SAY`, `YELL`, `EMOTE`, `MONSTER_SAY`, `MONSTER_YELL` and `MONSTER_EMOTE`), with fallbacks.

**Sending:**
- `Send.RouteFor("nearby")` returns `{ chatType = <mode> }`, where the mode is the conversation's current send mode: `"SAY"` (the default), `"YELL"` or `"EMOTE"`.
- Add `Store.SetSendMode(convKey, mode)` and `Store.SendModeOf(convKey)`. They are in memory only, and they reset to Say on reload.
- The card shows a small mode chip (`Echo.Round`, radius `SMALL`) at the left end of the reply box, only for Nearby. Clicking it cycles Say → Yell → Emote → Say. Its label is `L["ECHO_MODE_SAY"]`, `["ECHO_MODE_YELL"]` or `["ECHO_MODE_EMOTE"]`: "Say", "Yell" or "Emote". The reply box's left inset makes room for it.
- **Secure-send check:** in Midnight, `SAY`, `YELL` and `EMOTE` from addons may be restricted outdoors or in instances.
  - Check how `Send.Send` handles a Blizzard error return, and whether the pending record is marked failed.
  - If `C_ChatInfo.SendChatMessage` raises an error for `SAY` outside instances, which is known Classic and older Retail behaviour, catch it with `pcall`, mark the message failed, and show `L["ECHO_SEND_BLOCKED_NEARBY"]`: "The game only lets addons speak nearby inside instances. Use Blizzard's chat for this." in the card's hint area.
  - Document the behaviour you find in the report.

**Tests:**
- Each event routes to `nearby` with its style, and NPC lines are never outgoing.
- The tile spec has the icon, label and colour.
- `RouteFor` follows the send mode, the chip cycles, and the mode resets on `Store.Reset`.
- A yell bubble is coloured, and emote lines render as full-width lines with the name prefix.
- A secret emote has no name concatenated.
- A thrown send error marks the record failed and shows the hint.
- The tier setting is on the options page.

**Commit:** `feat(echo): a Nearby conversation for say, yell, emotes and NPCs`.

---

### Task 2: Chat shortcuts in the reply box

**Files:** `EchoSend.lua`, `EchoCard.lua`, `EchoStack.lua` (its quick reply uses the same path), the strings, and the tests.

**`Send.ParseShortcut(text, currentKey) -> result`** is pure, apart from reading channel and group state through small injectable helpers. `result` is one of:
- `nil`: the text doesn't start with `/`. Send it to `currentKey` as today.
- `{ convKey = key, text = rest, mode = mode|nil }`: send `rest` to `key`, with `mode` for Nearby.
- `{ blocked = "command" }`: a slash command Echo doesn't send.
- `{ blocked = "empty", convKey = key }`: a known shortcut with no message. Switch to `key` and keep the box empty.
- `{ blocked = "nowhere" }`: a shortcut with nowhere to go, such as `/r` with no whisper yet, `/1` with no channel in slot 1, `/w` with no name, or `/p` outside a group.

**Commands.** Match case-insensitively, using Blizzard's localised `SLASH_*` globals where they exist, plus these English forms:

| Shortcut | Goes to |
|---|---|
| `/s`, `/say` | `nearby`, mode SAY |
| `/y`, `/yell`, `/sh`, `/shout` | `nearby`, mode YELL |
| `/e`, `/em`, `/emote`, `/me` | `nearby`, mode EMOTE |
| `/g`, `/guild` | `guild` |
| `/o`, `/officer` | `officer` |
| `/p`, `/party` | `party` |
| `/ra`, `/raid` | `raid` |
| `/rw` | `raid` (sent as a raid message; raid warnings stay Blizzard's) |
| `/i`, `/instance`, `/bg` | `instance` |
| `/w Name`, `/whisper Name`, `/t Name`, `/tell Name` | `w:<Name-Realm>` |
| `/r`, `/reply` | the most recent incoming whisper or Battle.net whisper conversation in the Store |
| `/1` to `/9` | the channel joined in that slot, found with `GetChannelName(n)`, keyed like `Events.ChannelKeyName` |

- **Whisper names:** normalise with `Events.NormaliseName`, which adds your realm when none is given. A name with a space before the message, like `/w Brisa hi there`, splits at the first space after the name. A `|K` Battle.net name is never parsed. `/w` to a Battle.net friend isn't supported, so use the + menu.
- **Anything else starting with `/`** is `blocked = "command"`. This includes `/cast`, `/dance`, `/reload` and an unknown `/foo`.

**Card and stack:**
- A send result switches the card to that conversation, opening it through `Store.Start` from Task 3. Implement a minimal `Store.Start` here if Task 3 hasn't run yet; Task 3 builds on it.
- The card then sends the message, and sets the Nearby mode first when given.
- On `blocked = "command"`, keep the text in the box and show `L["ECHO_SHORTCUT_COMMAND"]`: "Echo can't run commands yet. Press Enter to use Blizzard's chat for this." It shows in the hint area for 4 seconds. Never send the text.
- On `"empty"`, switch and clear the box.
- On `"nowhere"`, keep the text and show `L["ECHO_SHORTCUT_NOWHERE"]`: "There's nowhere to send that right now."
- The stack's quick reply behaves the same, except that a switch opens the card.

**Tests:**
- Every row of the table parses to the right key and mode.
- Localised globals are honoured.
- `/w Name msg` splits correctly, and a realm is added.
- `/r` picks the newest incoming whisper.
- `/1` resolves through `GetChannelName`.
- `/cast Fireball`, `/dance` and `/foo` are blocked and never reach `Send.Send`. Assert with a spy on the send function.
- A plain message and one starting with a space and then `/` are both `nil`.
- The card switches conversation and keeps the text on a blocked command.

**Commit:** `feat(echo): chat shortcuts in the reply box, and never send commands as chat`.

---

### Task 3: Start a chat

**Files:** `EchoStore.lua`, `EchoTiles.lua`, a new `modules/Echo/EchoCompose.lua` (loaded after `EchoMenu.lua` in the TOC and in the test `FILES` list), `EchoCard.lua`, the strings, and the tests.

**`Store.Start(convKey) -> conv|nil`:**
- It creates or reopens a conversation with no message. It sets `open = true`, clears `dismissed`, marks it newest in `Store.List` order, and notifies `"update"`.
- It rejects invalid keys, and feed kinds, which are read-only.
- A started conversation with no messages behaves like any other: it shows a tile, and closing it removes the tile.

**The + button:**
- A small round button (`Echo.Round`, radius `SMALL`, 20×20) sits directly above the Echo icon at the foot of the column, with a `+` glyph.
- The column's layout reserves room for it, so tiles stop above it.
- It follows the column's edge, scale and lock like the Echo icon.
- Its tooltip is `L["ECHO_NEW_CHAT"]`: "Start a chat".
- Clicking it opens `Compose.Open(button)`.

**`Compose.Build(rootDescription)`** fills a MenuUtil menu. Keep it testable, like `Menu.Build`:
- **Whisper…** opens a StaticPopup (`HORIZON_ECHO_NEW_WHISPER`) with an edit box.
  - Where the client supports it, set `autoCompleteSource = GetAutoCompleteResults` and `autoCompleteArgs = AUTOCOMPLETE_LIST and AUTOCOMPLETE_LIST.WHISPER`, guarded.
  - Accepting a name normalises it and calls `Start("w:" .. name)`, then opens the card focused.
  - Register it lazily in `StaticPopupDialogs` under that key. It is a dialog key, not a frame name.
- **Friends online**, a submenu, lists up to 20 online character friends (`C_FriendList`) and Battle.net friends (`bn:<accountID>`, labelled with the account name `|K` string, which may be shown but never parsed).
  - Only list Battle.net friends when the Platform capability for Battle.net whispers is present.
  - Hide the submenu when it's empty.
- **Nearby**, the Say conversation.
- **Guild** when `IsInGuild()`, and **Officer** when `C_GuildInfo.CanSpeakInOfficerChat()` (or `CanEditOfficerNote`, as a fallback) is true.
- **Party** when in a home group, **Raid** when in a raid, and **Instance** when in an instance group.
- **Channels**, a submenu of every joined channel from `GetChannelList()` (id, name, disabled triples), each keyed with `Events.ChannelKeyName` and showing its plan 9 icon when it has one. Skip disabled entries.
- Selecting an entry calls `Store.Start(key)`, then `Card.Open(key, true)` anchored to the tile, which may be a group tile.
- Every Blizzard call goes through `pcall`, and every value is checked with `IsSecret`.

**Tests:**
- `Store.Start` creates an empty open conversation and puts it first. It reopens a closed one and rejects feeds.
- The + button exists above the Echo icon, and the tiles' bottom limit moves up.
- `Compose.Build` lists entries according to the stubbed state: in or out of a guild, officer rights, party or raid, joined channels, and online friends.
- Choosing Trade starts `ch:Trade` and opens the card focused.
- The whisper popup's accept normalises the name and starts the conversation.
- A `|K` label isn't parsed.

**Commit:** `feat(echo): start a chat from the column`.

---

### Task 4: Record it

- **Spec:** add "Start a chat, Nearby and chat shortcuts (plan 11, 2026-09-26)" under "Interface". Cover:
  - the Nearby events and styles;
  - the shortcut table;
  - that commands are never sent as chat;
  - `Store.Start`;
  - the + menu;
  - what you found about addon Say and Yell restrictions.
- **In-game checklist** (in this file). Echo gains a file, so restart the game.
  - [ ] Say something in a city. It appears in the Nearby tile. Yells show in the yell colour, and emotes as lines.
  - [ ] An NPC's speech shows in Nearby.
  - [ ] The mode chip cycles Say, Yell and Emote, and each sends. Or, if the game blocks addon Say outdoors, the hint explains it.
  - [ ] In any card, `/g hello` sends to guild and switches the card, and `/1 hi` sends to General.
  - [ ] `/w Name hi` opens a whisper to Name, and `/r` answers the last whisper.
  - [ ] `/dance` or `/reload` typed in Echo does nothing except show the hint. It is never sent as chat.
  - [ ] **+** lists Whisper…, your online friends, Nearby, Guild, your group and your channels. Picking Trade opens an empty Trade card ready to type.
  - [ ] The Whisper… prompt suggests names as you type.
- **Commit:** `docs(echo): record starting chats, Nearby and chat shortcuts`.

---

## In-game checklist (plan 11, 2026-09-26)

Echo gains a file, `EchoCompose.lua`, so restart the game rather than reloading.

- [ ] Say something in a city. It appears in the Nearby tile. Yells show in the yell colour, and emotes as lines.
- [ ] An NPC's speech shows in Nearby.
- [ ] The mode chip cycles Say, Yell and Emote, and each sends. Or, if the game blocks addon Say outdoors, the hint explains it within 8 seconds.
- [ ] In any card, `/g hello` sends to guild and switches the card, and `/1 hi` sends to General.
- [ ] `/w Name hi` opens a whisper to Name, and `/r` answers the last whisper.
- [ ] `/dance` or `/reload` typed in Echo does nothing except show the hint. It is never sent as chat.
- [ ] **+** lists Whisper…, your online friends, Nearby, Guild, your group and your channels. Picking Trade opens an empty Trade card ready to type.
- [ ] The Whisper… prompt suggests names as you type.
- [ ] In an LFR raid, + offers Instance, not Raid or Party.
