# Horizon Echo: conversation-first chat

**Date:** 2026-09-24
**Status:** Design approved, awaiting spec review
**Module:** Echo (new)

## Goal

Echo gives each conversation its own place on screen. A whisper partner or a group channel is a tile on the screen edge. Hover a tile and it becomes a card you can reply from. Click the card and it becomes the full conversation.

In simple terms: chat works like a messenger app sitting beside the normal chat window, not like one long scrolling log.

Blizzard's chat frames stay underneath as the source of truth. They still show everything, including combat log, system messages, loot, and any message Echo cannot safely read. If Echo is disabled or breaks, chat still works.

**Direction (decided with the director, 2026-09-26):** Echo is to replace Blizzard's chat windows entirely, as an option. Plan 12 built that option, **Hide Blizzard's chat windows**, off by default. The combat log is the one part Blizzard keeps. See "Towards replacing Blizzard chat" and "Replacing Blizzard chat (plan 12, 2026-09-26)" below.

## Locked decisions

| Decision | Choice |
|----------|--------|
| Shape | Custom conversation layer (tiles, stack, card) beside Blizzard's chat, not a reskin. Since plan 12 it can replace Blizzard's chat windows, as an option (see "Towards replacing Blizzard chat") |
| Conversations | Character whispers, Battle.net whispers, and group channels (party, raid, instance, guild, officer, custom channels) |
| Layout | One tile column on one screen edge; channels use glyph tiles |
| Notification tiers | Whispers: loud (reorder, toast, dot). Party/raid/instance: count, with a toast on mentions and raid warnings. Guild/officer/custom: quiet count. Each can be overridden per conversation |
| History | Whispers and BNet whispers persist (last 100 per conversation); channels are session-only; saving can be turned off |
| Combat | Stack and card collapse; tiles and counts stay live; loud toasts are held until combat ends |
| Clients | Retail and Forever, gated through `addon.Platform` capability keys |
| Intake | Echo registers its own `CHAT_MSG_*` events. Since plan 12 it also observes the main chat window's `AddMessage` through a post-hook, for the All view, and never replaces Blizzard's chat code |
| Blizzard chat | Mirrored by default; an option hides whispers Echo has stored, and another (plan 12) hides Blizzard's chat windows |

## Architecture

New module at `modules/Echo/`, registered as `echo` ("Horizon Echo").

| File | Job | Depends on |
|------|-----|-----------|
| `EchoModule.lua` | `addon:RegisterModule("echo", …)`; calls `Echo.Init` / `Echo.Disable` | core |
| `EchoEvents.lua` | Owns the event frame. Turns each `CHAT_MSG_*` payload into a message record and applies the secret-value rules | Platform |
| `EchoStore.lua` | Conversation model: keys, ordering, unread, tiers, mute/pin, persisted history. No frames. Notifies views on change | nothing UI |
| `EchoTiles.lua` | Collapsed column and preview toast | Store, shared toast styles |
| `EchoStack.lua` | Peek stack with quick reply | Store, Send |
| `EchoCard.lua` | Expanded card: header, tile row, bubbles, input | Store, Send |
| `EchoSend.lua` | Sends a reply for a conversation key. The only file that calls send APIs | Platform |
| `EchoSlash.lua` | `/h echo` commands, including `/h echo test` | Store |

Options: `options/modules/defaults/OptionsDefaultsEcho.lua` and `options/modules/OptionsEcho.lua`.

### Message record

```lua
{
    convKey  = "w:Brisa-Realm",  -- see conversation keys
    sender   = "Brisa-Realm",    -- nil when the sender was secret
    class    = "DRUID",          -- from GUID; nil for BNet app-only and channels without GUID
    text     = "...",            -- may be a secret value
    outgoing = false,
    time     = 1790000000,
    secret   = false,            -- true when text is a secret value
    status   = nil,              -- outgoing only: "pending" | "sent" | "failed"
}
```

### Conversation keys

| Key | Conversation |
|-----|--------------|
| `w:Name-Realm` | Character whisper |
| `bn:<bnetAccountID>` | Battle.net whisper |
| `party`, `raid`, `instance`, `guild`, `officer` | Group channels (leader variants fold into their channel) |
| `ch:<channelBaseName>` | Custom and numbered channels |

### Data flow

1. A `CHAT_MSG_*` event arrives.
2. `EchoEvents` builds a message record, or counts a sender-secret message.
3. `EchoStore:Add(record)` updates the conversation, unread count and ordering, then notifies listeners with the conversation key.
4. The visible view (tiles, stack or card) redraws that one conversation.

The Store has no frames, so it can be tested outside the game. Views can be rebuilt without touching data. All secret-value handling sits in `EchoEvents`.

## Intake and secret values

**Events.**

- Whispers: `CHAT_MSG_WHISPER`, `CHAT_MSG_WHISPER_INFORM`.
- BNet, registered only when `Platform.Has("bnetWhispers")`: `CHAT_MSG_BN_WHISPER`, `CHAT_MSG_BN_WHISPER_INFORM`.
- Groups: `CHAT_MSG_PARTY`, `_PARTY_LEADER`, `_RAID`, `_RAID_LEADER`, `_RAID_WARNING`, `_INSTANCE_CHAT`, `_INSTANCE_CHAT_LEADER`, `_GUILD`, `_OFFICER`, `_CHANNEL`.
- Failure detection: `CHAT_MSG_SYSTEM`, for "player not found" on whispers.

**Secret-value rules.** Checked with `issecretvalue` inside `pcall`, following the existing pattern in `AugmentCore.lua` and `InsightShared.lua`.

| Case | Behaviour |
|------|-----------|
| All readable | Full path: stored, toasted per tier, mention detection, persisted if a whisper |
| Sender readable, text secret | Filed under the right conversation. The bubble shows the secret by passing it straight to `SetText`. `secret = true`: never persisted, no mention or URL detection. Loud toasts show a generic "New message" body |
| Sender secret | No conversation can be chosen. A column marker counts "n in chat"; clicking it brings Blizzard's chat frame forward. Nothing is lost, because Blizzard's frame shows the message |

When `Platform.Has("secretChat")` is false, only the first case applies.

**Mentions.** In `party`, `raid` and `instance`, a readable message that contains the player's character name or a configured keyword is upgraded to a toast. Raid warnings always toast. Matching is case-insensitive and needs readable text.

## Sending

`EchoSend.Send(convKey, text)` maps the key to a chat type and target, then calls the platform's send function, resolved once at init.

- An outgoing bubble starts as `pending`.
- The matching `_INFORM` event marks it `sent`. The server echoes whispers in send order but can re-encode the text (item links gain fields), so a whisper or BNet echo that matches no pending text confirms the oldest pending message. Group channels keep exact-text matching, because lines typed in Blizzard's box echo there too.
- During chat messaging lockdown (`C_ChatInfo.InChatMessagingLockdown`), each part is filed and marked `failed` at once, and nothing is sent.
- A "player not found" system message for that target marks it `failed`, with a retry action.
- Shift-clicking an item or achievement while an Echo input has focus inserts the link into that input instead of Blizzard's edit box, through a hook on the insert-link path.

## Interface

### Collapsed: tiles

- The column anchors to a screen edge (right by default) and grows upward from its anchor. It can be unlocked and dragged from options, like Focus.
- Whisper tiles show the sender's class emblem on their class colour, with a short name (realm dropped, at most 5 characters, UTF-8 aware) across the bottom. A class with no resolvable icon falls back to the initial on class colour. BNet friends not on a character get the Battle.net logo on a blue tile, with no name label: a `|K` name can't be cut. A Battle.net friend on a WoW character shows their class icon instead. Channel tiles show a short name: **Gen**, **Trade**, **Def**, **LFG**, **Serv**, **WDef**, **New**, or the first 4 characters for anything else. These short names are English strings, so a non-English client falls back to the first 4 characters of the channel's own name for all of them. Group kinds keep their glyphs: **P**, **R**, **I**, **G**, **O**.
- One painter, `Echo.PaintTileFace`, draws every tile face (column, card row, stack card, toast). `View.Badge` drives the unread dot or count on the column tile and the card's row tile; the stack shows unread through its own meta line's "N new" text instead, not through `View.Badge`.
- Unread: a dot on loud conversations, a number on count-tier ones, and nothing on quiet ones until opened.
- At most 8 tiles, configurable. Beyond that, a **+N** tile opens the stack.
- Order: pinned first, then by last loud message. A mention or raid warning counts as a loud message: it toasts and moves its tile up. Ordinary count and quiet messages do not reorder.
- The bottom button opens the stack and is the drag handle when the column is unlocked.
- The preview toast slides out beside the tile for loud messages only, using the shared toast chrome. Clicking it opens that card.

### Peek: stack

- Opens on hover after a short delay, from the bottom button, or from the **Echo: Reply to newest** keybind. The keybind focuses the newest loud conversation's quick-reply input.
- Each card shows sender, class, unread count, age and the last few messages. The mouse wheel flips cards.
- Quick reply: Enter sends and keeps the stack open. Escape clears focus first, then closes the stack. **Open** expands the card.
- The stack closes when the mouse leaves it, unless its input has focus.

### Expanded: card

- Grows from the stack position. Other conversations become a tile row across the top; a chevron collapses back to tiles.
- The header shows name, class and relationship (friend, guildmate, Battle.net), plus online status where the game provides it. This meta line is upper-cased only on English clients, because `upper()` only touches ASCII letters and would otherwise mangle accented text.
- Bubbles: incoming on the left, outgoing on the right in the accent tint. The newest outgoing bubble shows pending, sent or failed. Consecutive messages from the same sender within 2 minutes are grouped. Channel cards show the sender name in class colour above each group.
- Renders the last 100 messages in pooled bubble frames inside a scroll frame.
- While scrolled up, an incoming message doesn't move what you're reading. It keeps counting behind a clickable "N new below" hint instead of shifting the view; the text is plain, with no glyph, since Friz Quadrata has no down arrow to draw. Scrolling back to the bottom, switching conversations, sending a reply or closing the card all clear the hint.
- × closes the conversation and removes its tile. Whisper history returns if that person messages again. Clicking the tile of the conversation the card already shows, in the column or in the card's own tile row, closes the card instead of doing nothing; any other tile still switches to it.
- Width, height, scale, strata and font follow the suite's usual options.

**Decided for plan 3 (2026-09-25):**

- Clicking a tile, a toast or the stack's **Open** button opens the card; hovering still peeks with the stack. Card and stack never show together, and hovering the column does nothing while the card is open.
- Conversation settings live under a **⋯** button in the card header: Pin/Unpin, Notifications (Default, Loud, Count, Quiet, Muted) and Close conversation, built with Blizzard's `MenuUtil` context menu.
- Pins and tiers are remembered **per character**, next to whisper history (Battle.net by BattleTag), independent of the history switch.
- Bubbles are laid out newest-first from the bottom of a clipped area and the wheel scrolls by message, so nothing reads a text height beyond each bubble's own. Readable text is measured; a secret gets the full width and a fixed three lines.
- Drafts are shared between the stack and the card, per conversation.
- Shift-clicking a link while an Echo reply box has focus inserts it there, through a post-hook on the game's own link insertion.
- The rest of the old plan 3 (options page, dashboard, whisper filter, keywords, polish) is plan 4.

### Feeds (plan 4, decided 2026-09-25)

At the time of plan 4, Echo stayed a layer beside Blizzard's chat (a full overhaul was considered and set aside, and later taken up as a roadmap in plans 11–14: it would mean showing secret lines Echo can't sort, keeping Blizzard's input box for protected slash commands, and a combat log Midnight largely closes to addons). Three read-only **feed** conversations collect non-conversation lines:

| Feed | Events |
|---|---|
| **Loot** (`loot`) | `CHAT_MSG_LOOT`, `CHAT_MSG_MONEY`, `CHAT_MSG_CURRENCY` |
| **Progress** (`progress`) | `CHAT_MSG_COMBAT_FACTION_CHANGE`, `CHAT_MSG_COMBAT_XP_GAIN`, `CHAT_MSG_SKILL`, `CHAT_MSG_ACHIEVEMENT`, `CHAT_MSG_GUILD_ACHIEVEMENT` |
| **System** (`system`) | `CHAT_MSG_SYSTEM`, `BN_INLINE_TOAST_ALERT` (Battle.net builds only) |

- Quiet by default; the ⋯ menu can change it. Session only, never persisted or restored.
- Tiles show an icon (bag, star, cog) rather than a letter. The card and stack show feeds read-only: no reply box; full-width lines with a timestamp in Blizzard's colour for that line type.
- A feed is chosen by event type, not sender, so a secret line still lands in its feed and shows via SetText.
- Links in conversation bubbles, feed lines and the stack's lines are live: hover for the tooltip, click through the game's own `SetItemRef`, shift-click to link.
- The combat log stays Blizzard's.
- Checked in game on Retail (director, 2026-09-25): feed tiles, read-only timestamped feed cards, live links, closing a feed until reload.

### Keybinds

Added to `Bindings.xml` under "Horizon Suite":

- **Echo: Reply to newest**
- **Echo: Toggle stack**

Blizzard's own Reply binding is left alone.

### Combat

On `PLAYER_REGEN_DISABLED`, the stack and card collapse. Tiles and counts keep updating. Loud toasts queue, and on `PLAYER_REGEN_ENABLED` the held toasts play, newest first, collapsed to one per conversation. Clicking a tile in combat still opens its card.

### Rounded look (plan 8, 2026-09-26)

Echo's square boxes became rounded squares and chat-app bubbles, drawn by one helper, `Echo.Round`, from two bundled textures rather than any newer client API.

- **Radii:** `Echo.Round.PANEL = 10` (the card, the stack card and its behind-cards), `Echo.Round.BUBBLE = 10` with `Echo.Round.TIGHT = 3` for a bubble's sender corner, `Echo.Round.TILE = 8` (column tiles and the card's row tiles), `Echo.Round.SMALL = 6` (the reply box, the send button, and the stack's and column's Open/chat buttons). Unread badges and the dot are fully round (radius half their size). A radius never exceeds half the frame's shorter side; `Echo.Round.Layout` clamps it whenever the frame is laid out, including on resize.
- **Bubble corner rule:** a bubble is fully rounded on three corners, with a tight (`TIGHT`) corner on the bottom nearest the next speaker — bottom-left for an incoming bubble, bottom-right for an outgoing one — but only on the **last bubble of a run** (the newest message overall, or the one where the next message starts a new group). Earlier bubbles in the same consecutive-sender run use full radii on all four corners.
- **How rounding is drawn:** `media/echo/circle.tga` (a filled circle) and `media/echo/ring.tga` (a circle outline), both 128×128 and pre-generated. Each corner is a texture quadrant sized to that corner's radius; edges and the middle are plain colour textures; a border (where Echo already drew one — panels, and tiles whose face is a glyph or icon) adds ring quarters plus 1px lines along the edges. This is a manual 9-slice: `Echo.Round.Apply` builds the pieces once per frame, `Echo.Round.Layout` re-lays them out for the frame's current size (hooked onto `OnSizeChanged` via `HookScript`, so a host's own resize handler still runs), and `Echo.Round.SetColor`/`SetBorderColor` tint them. Fill draws at draw-layer sublevel -8 and the border at -7, so the border always sits above the fill and a host's own child textures (left at the default sublevel) sit above both — otherwise a child (the unread count, a tile's name label) would draw under its own tile's fill regardless of layer, since a child always draws over its parent's regions. The unread dot uses `Echo.Round.Dot`, a single full-circle texture, instead of the full 9-slice, since a dot has no straight edges to fill.
- **Toast:** unchanged for now — it keeps Augment's own toast chrome (`BackdropTemplate` plus `AugmentToastStyles.ApplyChrome`), not `Echo.Round`.

### Chat groups and channel icons (plan 9, 2026-09-26)

**Groups.** Up to four named groups combine chats into one tile in the column, opening as a card with a tab per member. `modules/Echo/EchoGroups.lua` owns the rules:

- Settings: `echoGroupsEnabled` (default on), `echoGroupNames` (`{ "Channels", "", "", "" }`; a blank name leaves the group unused), `echoGroupOf` (member id → group index; an absent entry means none).
- A member id is `ch:<name>` for a channel (matching its exact id first, then `ch:*` for "any other channel"), or one of `guild`, `officer`, `party`, `raid`, `instance`, `loot`, `progress`, `system`. Whispers and Battle.net conversations are never grouped.
- **None beats "Other channels."** For an exact channel id (`ch:<name>`, not the `ch:*` wildcard), choosing None on the options page writes `false`, not a removed entry — so a channel set to None stays ungrouped even while `ch:*` is grouped. `Echo.Groups.Of` treats a `false` entry as "not grouped, no `ch:*` fallback." Every other member id's None just removes its entry (so it can fall through to a kind-level or `ch:*` default again).
- **Blank groups aren't offered.** The options page's per-chat dropdown lists None plus only the groups whose name isn't blank — never a "Group N" placeholder for an unnamed group, even if something is (stale-)assigned to it.
- **Group keys are view-only.** `Echo.Groups.Key(index)` returns `"grp:<index>"`. It is a key `Echo.View.Entries` and the card use to address a group tile; it never enters the Store, History or Send, and `Echo.Groups.Of`/`IndexOf` refuse it as a member id.
- A group tile's badge counts only its **counted** members: a member joins the sum (and can set the badge) only when its own tile would show a badge (loud → dot, count → count). A quiet or muted member's unread never inflates the group's count.
- The card's tab strip never shrinks a tab below 24px. Past that floor, as many tabs as fit are shown — always keeping the selected member visible — plus a trailing "+N" tab that selects the next hidden member.

**Icons with a short name.** `View.CHANNEL_ICONS` maps a channel's short key (`CHANNEL_SHORT`, the name with spaces removed) to an `Interface\Icons\` path:

| Channel | Icon |
|---|---|
| General | `Ability_Warrior_RallyingCry` |
| Trade | `INV_Misc_Coin_01` |
| `Trade(Services)` / Services | `Trade_BlackSmithing` |
| LocalDefense | `INV_Shield_06` |
| LookingForGroup | `INV_Misc_GroupNeedMore` |
| WorldDefense | `Ability_Warrior_DefensiveStance` |
| NewcomerChat | `INV_Misc_Book_09` |

Any other channel keeps the glyph face with its short name. A channel or feed tile with an icon also shows its label (`Gen`, `Trade`, `Loot`, `Prog`, `Sys`, …) on the dark tile. `View.GROUP_ICON` (`Spell_Holy_PrayerOfSpirit`) is the icon a group tile shows.

**Guild emblem.** The Guild tile's face is your own guild's tabard when `View.GuildTabard()` can read one (`C_GuildInfo.GetGuildTabardInfo("player")`, cached 5 seconds and cleared on `PLAYER_GUILD_UPDATE`/`GUILD_ROSTER_UPDATE`): the tile paints the emblem in its colours, background tinted from the tabard's background colour. Not in a guild, no such API (Forever), or an unreadable/zero emblem falls back to the plain "G" glyph. `IsInGuild`'s truthiness is read leniently — any truthy, non-secret value counts as "yes," not only literal `true` — since some clients hand back a value that isn't a plain boolean. Because the tabard can change without the game reloading Echo, `Echo.Class`'s roster-event handler marks `"tiles"` and `"cardRow"` unconditionally on `PLAYER_GUILD_UPDATE` and after clearing the cache on `GUILD_ROSTER_UPDATE`, not only when a classless whisper also happens to be open.

**The Echo icon.** The column's chat/stack button and the dashboard's Echo module tile both show the same director-provided art, `media/echo/echo_icon.tga` (a 128×128 rounded tile with transparent corners), exposed as `Echo.View.ECHO_ICON`. The column button shows the icon filling the button (inset 1px) with no rounded panel fill or border behind it — the icon already carries its own rounded tile — and brightens on hover via an additive `OVERLAY` highlight texture (same art, `SetBlendMode("ADD")`, alpha 0.25) shown on enter and hidden on leave. The dashboard's module-icon helper (`options/dashboard/DashboardHomeWelcome.lua`) uses a `MODULE_ICONS` value as a full path unchanged when it already contains a backslash, rather than always prefixing `Interface\Icons\`.

### Message pins, saved guild chat and clean-up (plan 10, 2026-09-26)

**What is saved, and where.** Everything lives under `HorizonDB.echoHistory`:

```lua
HorizonDB.echoHistory = {
    chars  = { ["Name-Realm"] = { ["w:Brisa-Realm"] = { {t=…, out=false, text="…", s="…", c="DRUID"}, … } } },
    bnet   = { ["bt:Friend#1234"] = { … } },
    guilds = { ["Guild Name-Realm"] = { guild = { … }, officer = { … } } },
    pins   = { ["Name-Realm"] = { ["w:Brisa-Realm"] = { {t=…, text="…", s="…", out=true}, … },
                                  ["g:Guild Name-Realm:guild"] = { … } } },
}
```

- Whispers are saved per character and Battle.net whispers account-wide by BattleTag, as before. Saved entries now also carry `s`, the sender's `Name-Realm`, and `c`, the class token, when both are readable and not secret. A Battle.net sender is a protected `|K` string, so its `s` is never written.
- Guild chat is saved by default (`echoSaveGuild`), and officer chat only when `echoSaveOfficer` is on. Both are keyed by `"Guild Name-Realm"` from `GetGuildInfo("player")`, so every character in the same guild shares them. With no readable guild key, nothing is written or loaded. A guild conversation created before the guild is known loads its saved lines once, as soon as the key can be read: on its next message, on `PLAYER_GUILD_UPDATE` or `GUILD_ROSTER_UPDATE` (`Store.RetryHistory`), or when the card shows it. **Save chat history** (`echoSaveHistory`) is the master switch for everything saved automatically. Party, raid, instance and channel chat are never saved.
- Pins are saved per character, keyed by the same `PrefKey` as the conversation prefs, so Battle.net pins are keyed by BattleTag and a Battle.net pin keeps no sender. Guild and officer pins are the exception: they belong to one guild, keyed `"g:" .. GuildKey() .. ":" .. kind`, so a character who changes guild sees that guild's pins. While the guild key can't be read, the guild tiles show no pins and pinning a guild line gives "Can't save this chat yet". The conversation prefs (a tile pinned to the column, its tier) stay keyed by `guild` and `officer`.

**Caps.** A whisper or Battle.net conversation keeps 100 lines, and guild and officer chat keep 200 each. Each chat holds 5 pins, and each character 50.

**Clean-up.** `History.Prune` runs once when the module enables, after `Bind`, under **Keep history for** (`echoHistoryDays`: 7, 30 or 90 days, or 0 for Forever; the default is 30). A saved list whose newest entry is older than the setting is removed, and a list with no readable time counts as stale. A conversation whose tile is pinned in any character's prefs is kept. That protection is keyed by conversation, and the guild's key is only ever the current guild's, so a pinned Guild or Officer tile protects only the current guild's saved lists. Another guild's lists are pruned by age alone. When the guild isn't known yet at a cold login, no guild list is pruned at all. Message pins are stored apart from these lists and are never pruned. An emptied character bucket is removed. Forever removes nothing.

**Size budget.** This was estimated, not measured. A saved line costs about 110 bytes: 60–70 bytes of serialiser overhead plus the text. A full whisper conversation is about 11 KB, a full guild history about 22 KB, and 50 pins about 6 KB.

**Pins ignore the history switches.** A pin is the player's explicit choice. It is saved in any chat, including channels and feeds that are never saved otherwise. The line cap never removes a pin, and neither does the clean-up. **Clear history** wipes pins along with whispers and guild chat. A secret message can't be pinned.

**On the card.**

- Right-click a bubble or feed line to open the pin menu. It offers **Pin message**, or **Unpin message**, or a disabled line giving the reason a pin is refused: a hidden message, 5 pins in this chat, 50 pins in all, or a chat that can't be saved yet. `Store.PinBlockReason` gives that reason without writing, from the same checks `History.AddPin` uses.
- Right-clicking a link keeps Blizzard's link behaviour. The link click stamps the time, and the pin menu opens a frame later only if no link click landed within 0.3 seconds (`Card.LINK_WINDOW`), whichever order the game fires the two events in.
- A pinned message shows a 10px pin in the accent colour, inside the bubble's top corner on the side away from the sender. The text keeps clear of the pin on that side. On a feed line, the pin sits between the time and the text.
- The pin strip is 22px high, in a dim accent tint, and shows under the header, or under the tabs on a group card, only while the shown conversation has pins. The message area moves down by `Card.PIN_STRIP` (26px) while it shows.
- The strip shows one pin's text on one line, with links shown as their names. Clicking the text scrolls the card to that message while it is still in the conversation. Hovering it shows the full message, its sender and its time. The × unpins the shown pin.
- With two or more pins, a counter steps to the next older pin and wraps round. It counts from the newest pin, so `1/n` is the newest. The strip starts on the newest pin whenever the card switches conversation or tab.

### Start a chat, Nearby and chat shortcuts (plan 11, 2026-09-26)

**Nearby.** One conversation, key `"nearby"`, for speech heard where you stand. Its default tier is `quiet` (`echoTierNearby`), it is never saved, and it can't join a chat group. Its tile shows the Battle Shout icon labelled "Near" in the Say colour, and its card is titled "Nearby". These events route to it, each filed with a `record.style`:

| Event | Style | Drawn as |
|---|---|---|
| `CHAT_MSG_SAY` | `say` | a bubble in the Say colour |
| `CHAT_MSG_YELL` | `yell` | a bubble in the Yell colour |
| `CHAT_MSG_EMOTE` | `emote` | a full-width line, `<sender> <text>`, in the Emote colour |
| `CHAT_MSG_TEXT_EMOTE` | `textemote` | a full-width line, the text only (it already names the sender) |
| `CHAT_MSG_MONSTER_SAY` | `npc` | a bubble in the NPC Say colour |
| `CHAT_MSG_MONSTER_YELL` | `npcyell` | a bubble in the NPC Yell colour |
| `CHAT_MSG_MONSTER_EMOTE` | `npcemote` | a full-width line in the NPC Emote colour |

- The colours come from `ChatTypeInfo`, with fallbacks. Group-style sender names sit above each run of bubbles. A secret emote shows its text alone, with no name joined to it.
- A player line is outgoing when its sender is you, as in group chat. An NPC line is never outgoing, and never counts as a mention of your name.
- The card's mode chip, shown only for Nearby, cycles Say, Yell and Emote. `Send.RouteFor("nearby")` sends in that mode. The mode is held in memory only and resets to Say on reload.
- **Pending expiry.** A Nearby line still pending 8 seconds after it was sent (`Store.NEARBY_CONFIRM_SECONDS`) is marked failed, because the game can drop an addon's Say or Yell without an error and no echo ever arrives. The card then shows "The game only lets addons speak nearby inside instances. Use Blizzard's chat for this." A send that throws is failed at once with the same hint. Other kinds never expire.

**Say and Yell need a hardware event.** Outdoors, the game only accepts an addon's `SAY` or `YELL` when a key press or mouse click is in the same call stack. Inside instances it accepts them without one. Every Echo send path satisfies this: Enter in the card or stack reply box, the send button, and the retry click all start from a hardware event, and `Echo.Send` sends synchronously within it. Nothing sends from a timer or an event handler. This comes from API knowledge and hasn't been confirmed in game; the in-game checklist in the plan covers it, and the pending expiry above catches a silent drop.

**Chat shortcuts.** Text typed in the card's or the stack's reply box that starts with `/` is read by `Send.ParseShortcut` before anything is sent:

| Shortcut | Goes to |
|---|---|
| `/s`, `/say` | Nearby, mode Say |
| `/y`, `/yell`, `/sh`, `/shout` | Nearby, mode Yell |
| `/e`, `/em`, `/emote`, `/me` | Nearby, mode Emote |
| `/g`, `/guild` | Guild |
| `/o`, `/officer` | Officer, only with officer rights |
| `/p`, `/party` | Party, only in a home group |
| `/ra`, `/raid`, `/rw` | Raid, only in a home raid (`/rw` is sent as a raid message) |
| `/i`, `/instance`, `/bg` | Instance |
| `/w`, `/whisper`, `/t`, `/tell` + name | a whisper to that name |
| `/r`, `/reply` | the conversation with the newest incoming whisper or Battle.net whisper |
| `/1` to `/9` | the channel joined in that slot (`GetChannelName(n)`) |

- **Rulings.**
  - Leading spaces are trimmed first, so `" /dance"` is still a command.
  - Commands match case-insensitively, and Blizzard's localised `SLASH_*` globals are accepted alongside the English forms.
  - `/w` matches an existing whisper case-insensitively (`Store.WhisperKeyLike`). A new name gets your realm when it has none, and a capital first letter when that letter is ASCII a to z. The name runs to the first space. A name containing `|` (a Battle.net `|K` name) is never parsed, so Battle.net friends are reached from the + menu instead.
  - Officer needs `C_GuildInfo.CanSpeakInOfficerChat`, falling back to `CanEditOfficerNote` and then to guild membership.
  - Party and Raid count only the home group (`LE_PARTY_CATEGORY_HOME`). A group-finder group, LFR included, talks in Instance. Without `LE_PARTY_CATEGORY_INSTANCE`, Instance is never reachable.
- A shortcut with a message switches the card to its conversation, opening it with `Store.Start`, and sends the message there. One with no message only switches. The stack's quick reply does the same, opening the card to switch.
- **Commands are never sent as chat.** Any other text starting with `/`, such as `/cast`, `/dance`, `/reload` or `/foo`, never reaches `Echo.Send`. It stays in the box, and the hint says "Echo can't run commands yet. Use Blizzard's chat for this." A shortcut with nowhere to go (`/r` with no whisper yet, `/1` with no channel in slot 1, `/p` outside a group) also stays in the box, with "There's nowhere to send that right now." A retry of a failed line skips the parser on purpose: that text was vetted when it was first sent.

**`Store.Start(convKey)`.** Creates or reopens a conversation with no message. It sets `open`, clears `dismissed`, stamps `startedSeq` from the Store's sequence so `Store.List` puts it first, and notifies `"update"`. Pinned tiles stay above it, and a later loud message goes above it, because `startedSeq` orders the list without counting as a loud message. It rejects invalid keys and the feed kinds, which are read-only. A started conversation with no messages has a tile like any other, and closing it removes the tile.

**The + menu.** A 20×20 round button (`Echo.Round.SMALL`) sits just above the Echo icon, with a `+` and the tooltip "Start a chat". It is a child of the column, so it follows the column's edge, scale and lock, and it drags the column when unlocked. The tiles stack above it (`Tiles.TilesBottom()`). Without `MenuUtil` the button stays hidden and the tiles drop back to one step above the Echo icon. A click opens `Compose.Open`, a MenuUtil context menu built by `Compose.Build`:

- **Whisper…** opens the `HORIZON_ECHO_NEW_WHISPER` StaticPopup, registered on first use. It suggests names through `GetAutoCompleteResults` with the `AUTOCOMPLETE_LIST.WHISPER` include and exclude masks. The name goes through the same rule as `/w` (`Send.WhisperKeyFor`).
- **Friends online**, a submenu of up to 20 online character friends, then Battle.net friends when the client has Battle.net whispers. A Battle.net friend is labelled with its account name, a `|K` string shown whole and never parsed, and keyed `bn:<accountID>`. The submenu is left out when empty.
- **Nearby**; **Guild**, **Officer**, **Party**, **Raid** and **Instance** by the same checks as the shortcuts (`Send.CanReach`).
- **Channels**, a submenu of every enabled joined channel from `GetChannelList()`, keyed like incoming channel chat and showing the channel's icon when it has one.
- Choosing an entry calls `Store.Start`, then opens the card on it with the reply box focused, growing from its tile or its group's tile.
- Every Blizzard call is protected with `pcall` and every value checked with `IsSecret`. Opening a menu is protected too: a refused `MenuUtil.CreateContextMenu` makes `Compose.Open`, `Menu.Open` and `Menu.OpenMessage` return false instead of raising.

### Replacing Blizzard chat (plan 12, 2026-09-26)

Plan 12 built the three pieces the roadmap below set out: Blizzard's own input line docked under Echo, the All view with other addons' filters, and an option that hides Blizzard's chat windows.

**The pattern.** We learned it from Chattynator's source (the `hippuli/Chattynator` mirror, version 224, Interface 120100 and 16001), read on 2026-09-26. Credit for the approach goes to Chattynator's authors. We copied none of its code: Echo's implementation is its own, written against the same Blizzard APIs.
- Blizzard's chat windows move onto a hidden parent and their events are switched off, with one exception on `ChatFrame1` (below).
- Blizzard's own input line, `ChatFrame1EditBox`, is kept, restyled and re-anchored. Enter, `/`, **R** and Blizzard's **Whisper** keep working because they are still the game's own code.
- Blizzard's chat code is only observed, through post-hooks. Echo never calls it, never replaces it, never focuses the input line, and never changes where typing goes.
- Other addons' `print` output is caught by a post-hook on `DEFAULT_CHAT_FRAME.AddMessage`, and `debugstack` tells a print apart from Blizzard's own event handler adding a line.

**Allowed and forbidden calls.**

| | Calls |
|---|---|
| Allowed | `hooksecurefunc` post-hooks on `ChatFrameUtil.*`, `ChatEdit_*`, `ChatFrame1EditBox` methods (its `SetPoint` included), `DEFAULT_CHAT_FRAME.AddMessage` and `FCF_OpenTemporaryWindow`; `HookScript` for the input line's `OnShow` and `OnHide`; reading the input line's attributes (`GetAttribute`); widget methods that position and style it (`ClearAllPoints`, `SetPoint`, `SetScale`, `SetFrameStrata`, `SetFont`, `SetFontObject`, `SetAlpha` on its textures, and `Show` and `Hide` from inside the activate and deactivate post-hooks); `ChatFrame1EditBox:SetParent(UIParent)`, only while its parent is one of the hidden windows |
| Forbidden | Calling `ChatEdit_*`, `ChatFrameUtil.*` or `ChatFrame_OpenChat`; replacing any Blizzard global or method; `SetFocus` on the input line; `SetAttribute` on it, except in the probe; writing Lua fields on it |

The allowed list grew twice during the plan. The first widening added `HookScript` on the line's `OnShow` and `OnHide`, the post-hook on its `SetPoint`, and `SetFrameStrata` and `SetFont`. Post-hooks only observe, and styling a widget runs none of Blizzard's chat code; Echo records each value it changes and puts it back when docking goes off. The second widening added `SetParent(UIParent)` for the input line. The line is a child of `ChatFrame1`, so hiding that window hid the line with it, and nobody could type. Echo moves it only when its parent is one of the windows it hid, records the old parent, and puts it back when docking or Echo is disabled. `/h echo status` names the line's parent, so a tester can see which case applies. If either widening turns out to taint, the probe and `taint.log` will show it.

**`ChatFrame1` keeps three events.** Every hidden window keeps `UPDATE_CHAT_COLOR`. `ChatFrame1` also keeps `CHAT_MSG_WHISPER`, `CHAT_MSG_BN_WHISPER` and `CAUTIONARY_CHAT_MESSAGE`, each only where the client has it. The game remembers who **R** replies to inside Blizzard's own whisper handler on the chat window, so without these events **R** would stop working. For the same reason, **Hide whispers Echo has stored** stays off while hiding is applied, so that Blizzard's own code on the hidden `ChatFrame1` sets the reply target, rather than Echo's filter setting it in its place. A post-hook on each hidden window's `RegisterEvent` unregisters anything else Blizzard adds back later. `whisperMode` is set to `inline` while hiding is on, so whispers never open a popout window; the CVar is account-wide, so its old value is saved account-wide and restored on the next character that doesn't hide chat.

**The All view.** One read-only, quiet feed with the key `"all"`, never saved, capped at 500 lines, switched by `echoAllView` and always on while Blizzard's chat is hidden. Its lines come from four sources:
1. **Every record Echo files**, through a Store listener. Each line carries its chat's short name and the sender in a prefix drawn on its own, so a secret text is never joined to anything. A line keeps the record's `outgoing` flag and its source; its menu pins the source message in its own chat, since All keeps no pins.
2. **Text printed to the main chat window that no chat event produced**: addon prints, `/dump`, Blizzard system text. A call from Blizzard's chat event handlers, from Echo, or with a secret stack is skipped. `debugstack` runs on every `AddMessage` while All collects; its cost is an in-game check.
3. **Chat types Echo has no tile for**, which Echo registers itself while All collects: each `CHAT_MSG_*` in `ChatTypeGroup` that Echo doesn't route, in the message groups the player gives `ChatFrame1` (`GetChatWindowMessages(1)`), plus `CHAT_MSG_COMMUNITIES_CHANNEL`. Trade skills, openings, pet info, target icons and channel joins and leaves are left out unless the player's groups name them, and combat types are left out except honour gains. While Blizzard's chat is shown it prints these lines too, and source 2's stack check keeps them from arriving twice. A type whose text is a code (channel notices, ignored, filtered and trial notices) is formatted from Blizzard's own template, or skipped; away and busy lines take Blizzard's "is Away" prefix. `%s` is filled in with the speaker only for NPC and boss speech.
4. **System events that aren't chat, only while Blizzard's chat is hidden**, since `ChatFrame1` prints them otherwise: `TIME_PLAYED_MSG`, `GUILD_MOTD`, the chat server and Battle.net connection notices, and `CHAT_REGIONAL_SEND_FAILED`. Each registers only where the client has the event and the string Blizzard formats it with.

The All tile uses the generic feed-tile path in `EchoTiles.lua`, which needed no change.

**What All still doesn't show.** The combat log. Lines another chat window prints for itself, since only `DEFAULT_CHAT_FRAME` is hooked. System events such as `/played` while Blizzard's chat is shown, because only `ChatFrame1`'s event handler prints them then, and that path is skipped. Channel joins and leaves, trade skills, openings, pet info, target icons and most combat types, as above. A print whose stack is secret. Events Chattynator also handles and Echo doesn't yet, such as `CHAT_REGIONAL_STATUS_CHANGED`, `NOTIFY_CHAT_SUPPRESSED` and removing a reported player's lines (`PLAYER_REPORT_SUBMITTED`).

**Filters.** Before Echo files a chat line, anywhere, it runs other addons' message filters over it as Blizzard does for each window: `ChatFrameUtil.ProcessMessageEventFilters` where it exists, else a loop over `ChatFrame_GetMessageEventFilters`, with `ChatFrame1` as the frame. A blocked line is dropped and counted; a rewritten one is filed as rewritten. Each filter call is protected, so a broken filter keeps the arguments it was given. Echo's own "Hide whispers Echo has stored" filter stands aside meanwhile (`Filter.passing`), because it hides lines from Blizzard's windows, never from Echo; `Events.RunFilters` always resets that flag, even after an error of its own.

**The probe.** `/h echo probe input <guild|say|Name-Realm|reset>` points Blizzard's input line at a chat by setting its attributes, the one place Echo calls `SetAttribute` on it. It finds out in game whether an addon may do that without tainting the box, by sending a message and then a `/cast` in combat from it. If it can, a later plan lets clicking a tile aim the line at that chat, and the card's own reply box can go. The reset line tells the tester to `/reload` afterwards, to clear any taint the test left.

**Hiding Blizzard's chat** (`echoHideBlizzardChat`, off by default) applies one frame after `PLAYER_ENTERING_WORLD`, never in combat, and needs the docked input line, so it turns docking on. It moves every window in `CHAT_FRAMES` and its tab onto a hidden frame Echo owns, except the combat log while `echoKeepCombatLog` is on, and moves Blizzard's chat buttons there too. A post-hook on `FCF_OpenTemporaryWindow` hides a window that opens later, such as a pet battle's log. Applying again only touches what isn't hidden yet. Nothing is un-hidden live: turning it off, or disabling Echo after it applied, asks for a reload. Everything runs from Echo's module code, so a disabled or broken Echo hides nothing.

## Towards replacing Blizzard chat (decided 2026-09-26, built in plan 12)

The director wants Echo to be able to replace Blizzard's chat windows entirely. The roadmap named four gaps; plan 12 built the answers to three, and the combat log stays Blizzard's. The detail is in "Replacing Blizzard chat (plan 12, 2026-09-26)" above.

| Gap | What was built |
|---|---|
| **Protected slash commands** (`/cast`, `/target`, macros) run only from Blizzard's own input box | Blizzard's `ChatFrame1EditBox`, restyled and docked under the open card or beside the Echo icon (`echoDockInput`). Enter, `/`, **R** and **Whisper** stay Blizzard's own. While the line is typed in, the card follows the chat it is aimed at, and a card whose chat the line covers hides its own reply box |
| **Lines Echo can't sort**: other addons' `print` output, system text, chat types Echo has no tile for | The **All** view (`echoAllView`): every record Echo files, plus the main chat window's other prints through a post-hook on `AddMessage`, plus the chat and system events Echo registers for it. Secret text is shown with `SetText` and never inspected |
| **Other addons' chat filters** (spam blockers, formatters) | `Events.RunFilters` runs the registered message filters over every line before Echo files it, so blocked spam stays blocked |
| **The combat log** is largely closed to addons in Midnight | Blizzard keeps it. With **Keep the combat log** on (`echoKeepCombatLog`, the default), hiding Blizzard's chat leaves `ChatFrame2` and its tab alone |

**Hide Blizzard's chat windows** (`echoHideBlizzardChat`) is off by default, and Blizzard's chat returns after a reload whenever it is turned off or Echo is disabled. Still to come: joining and leaving channels from Echo, the probe's verdict on aiming the input line from Echo, and, once the option has proved itself, perhaps making it the default.

## Storage

Settings live in the profile through `OptionsDefaultsEcho.lua`.

Whisper history is not profile data, because profiles are shared and copied between characters. It lives in its own top-level table in `HorizonDB`:

```lua
HorizonDB.echoHistory = {
    chars = { ["Name-Realm"] = { ["w:Brisa-Realm"] = { {t=…, out=false, text="…"}, … } } },
    bnet  = { ["bt:Friend#1234"] = { {t=…, out=true, text="…"}, … } },
}
```

- Character whispers are stored per character. BNet whispers are stored account-wide, keyed by the friend's BattleTag (`bt:<BattleTag>`, read through `C_BattleNet.GetAccountInfoByID`). The in-session conversation key stays `bn:<accountID>`, but Blizzard's account ID only lasts one session, so it is never persisted: keying history by it could load one friend's whispers into another friend's conversation after a relog.
- Fail closed: when the BattleTag cannot be read (no API, no friend info, an empty or secret value), nothing is written and nothing is loaded for that conversation.
- Capped at 100 entries per conversation and trimmed on `PLAYER_LOGOUT`.
- Secret messages are never written.
- Nothing is written when **Save whisper history** is off. **Clear history** wipes the table.
- Closing a conversation drops its unsent draft on purpose. The stack and the card share drafts per conversation, and closing either one discards the draft for both.

## Options

| Group | Settings |
|-------|----------|
| General | Enable; column edge; lock; scale; strata; max tiles |
| Notifications | Toast style (shared Compact / Framed / Accent); tier per conversation type; mention keywords; hold toasts in combat |
| History | Save whisper history (on); Clear history |
| Blizzard chat | Hide whispers Echo has stored (off) |
| Card | Width; height; font |

All strings go through `locales/horizon/enUS.lua` so `tools/locale_audit.js` picks them up.

The options page is built (plan 5). Three things to note:

- Positions are saved in screen units. A position saved at a scale other than 1 before plan 5 shifts once.
- The whisper filter sets the reply target for hidden whispers.
- A switched-off feed files nothing, but still fails a pending whisper.

## Platform capabilities

Add to `core/Platform.lua`:

| Key | Detection | Forever |
|-----|-----------|---------|
| `bnetWhispers` | Battle.net whisper events and send API present | In `Platform.unverified` until a BNet whisper is seen on the beta |
| `secretChat` | `issecretvalue` present and chat payloads can be secret | In `Platform.unverified` until checked on the beta |

## Verification before code

These are assumptions, not facts. Settle them in the first implementation step, before `EchoEvents` and `EchoSend` are written:

1. Which `CHAT_MSG_*` arguments can be secret in Midnight 12.1 (text, sender, GUID, `bnSenderID`), and in which contexts.
2. The current send functions for character, channel and Battle.net whispers on Retail and Forever.
3. Whether `FontString:SetText` with a secret string still works inside Echo's own frames, and whether `GetStringWidth` on it returns a usable number for sizing bubbles.
4. Whether `modules/Augment/ToastStyles/AugmentToastStyles.lua` works while Augment is disabled. If not, move it to `core/` as part of this work rather than copy it.
5. Which hook reliably redirects shift-click link insertion to a focused Echo input.

### Results so far (Retail, 2026-09-25, outside instances)

- `/h echo probe` reports `sendChat=yes sendBN=yes secretChat=true bnetWhispers=true`.
- Whisper and whisper-inform route to `w:Name-Realm`; the reply route is `WHISPER:Name-Realm`. Your own General line is detected as outgoing.
- No argument was secret outside an instance. Item 1 still needs an in-instance run; #444 saw secret `CHAT_MSG_SYSTEM` anywhere inside an instance on both clients, so a delve or dungeon is enough.
- **CHAT_MSG_CHANNEL arg 9 carries the zone** (`General - Zul'Aman`), so keying by it made one conversation per zone. Fixed: zone channels (arg 7 `zoneChannelID` > 0) are keyed by the name before ` - `, and replies go to the joined index from arg 8, checked against `GetChannelName(index)` before use. `GetChannelName` accepted the full name (`route=CHANNEL:1`).
- Inside a delve, before any fight, nothing was secret either: whisper and whisper-inform arrived fully readable. Chat is not hidden merely for being in an instance, so any restriction comes from combat or the encounter. **Still open:** the encounter run (a dungeon boss or M+, ideally with a groupmate whispering mid-pull). Deferred on 2026-09-25; Echo's secret paths are covered by the logic tests until then.
- Zone channels confirmed as one conversation after the fix (`ch:General`).
- Whisper history survived `/reload`: the conversation reopened with its two saved messages plus the new ones.
- Item 5 settled (Retail, 2026-09-25): `/dump ChatEdit_InsertLink == ChatFrameUtil.InsertLink` prints `false`, so the legacy global is a wrapper rather than an alias, and hooking `ChatFrameUtil.InsertLink` catches both paths. Shift-clicked links reach a focused Echo box; the expanded card, menu, remembered pins and tiers all checked in game.
- Item 4 is settled from the code: `AugmentToastStyles.lua` is a plain table of functions loaded by the TOC before `AugmentModule.lua`, so it works with Augment disabled.

## Ideas from Whisper Stack (plan 7, 2026-09-26)

Plan 7 brought five features into Echo, each one an idea seen in Whisper Stack (an
addon by Devin) and reimplemented from scratch for Echo's own architecture and
constraints:

- **A class icon without a message to carry one.** Restored history, Battle.net
  friends and some whispers arrive with no class attached, so a tile falls back
  to a letter. `Echo.Class` looks a whisperer up in your group, then your guild,
  then your friends list, and caches the first match on the conversation. A
  Battle.net friend is resolved fresh every time instead, since they can switch
  characters mid-session.
- **A sound for the whispers Echo hides.** Echo can play its own sound when it
  hides a whisper from Blizzard's chat. The rule is one-sided: Echo's sound
  plays only for whispers Echo hides, and whispers Blizzard still shows keep
  Blizzard's own sound. Echo never touches Blizzard's chat frames to silence
  them, so the two never double up and never go silent together.
- **Invite to group from a whisper's menu.** The menu offers Invite only when
  the target can actually join your group: for a Battle.net friend, that means
  `CanCooperateWithGameAccount` says yes where the client offers it, or
  failing that a matching game project and region. It never offers Invite for
  yourself.
- **An Auto screen edge.** The column can follow whichever half of the screen it
  sits on, rather than a fixed left or right, so the stack and card open away
  from the column instead of over it.
- **The card pours out of the clicked tile (a genie).** A sheet in the tile's
  colour pours out of the tile and bends as it widens into the card, the far side
  leading and the tile side last; the card fades in over the sheet's last stretch.
  Clicking the tile again runs it in reverse, back into the tile. Escape, the
  chevron and combat still close at once. "Animate the card" turns it off.

Two points worth keeping in mind when working on any of this:

- **Echo never writes to Blizzard's own chat-frame fields.** Every one of these
  features reads Blizzard's APIs (roster, friends, Battle.net, chat settings)
  but never writes to them and never hooks or replaces a Blizzard chat
  function. This keeps Echo out of the taint rules that govern Blizzard's own
  frames.
- **Whisper Stack carried no licence.** Its ideas were reimplemented from a
  plain-English description of what it does, not from its source. The one
  exception is the genie: Devin gave the director his code to help integrate it
  (2026-09-26), so `EchoGenie.lua` adapts his technique (warped pieces with shared
  edges, a matching vertical gradient, the far side leading) and credits him.

## Testing

- **Logic tests:** `tools/test_echo_logic.js`, in the same shape as `tools/test_lootroll_logic.js` (fengari, stubbed globals, real locale file). Covers conversation keys, tier and ordering rules, unread counters, the history cap and trim, "secret messages are never persisted", and "sender secret produces no conversation, only a marker count".
- **In-game checklist** on the Windows PC, on Retail and the Forever beta: whisper; BNet whisper; reply from stack and card; failed whisper; shift-click link; combat hold and release; `/reload` keeps history; an encounter to see the secret path.
- **`/h echo test`** injects sample conversations so the interface can be checked without a second account.

## Out of scope for v1

- A replacement combat log
- Joining, leaving or managing channels (planned for plan 14)
- Full-text search
- Emoji
- Syncing history between accounts

Blizzard's chat stays responsible for all of these.

## Build order

Each step can ship on its own:

1. `EchoStore` and logic tests
2. Verification spike, then `EchoEvents` and `EchoSend`, plus Platform keys
3. Tiles and preview toast
4. Stack and quick reply
5. Card
6. Options, persistence, keybinds and polish — split across plans 5 and 6

**Carried into plan 2.** Found while building the foundation, left for the view work:

- History must expose its saved conversation keys (`History.Keys`, restored through `Store.Restore`), so `/reload` brings back whisper tiles. Battle.net history is saved under `bt:<BattleTag>`, so restoring it needs a BattleTag-to-current-account-ID lookup across the friends list.
- Views order bubbles by array position, not `record.seq`: history-seeded messages all carry `seq = 0`.
- Decide whether `Store.Close` should clear `pinned`.
- Add `Store.Unsubscribe` if views are rebuilt at runtime.
- Slash command strings move to `addon.L` in plan 3.

**Plan 5 did:** the one-frame redraw coalescing for Tiles, Card and Stack; the per-feed on/off option (Loot, Progress, System); the column-edge option flipping which side the toast and stack open on; the scale-safe saved position, so a scale change no longer moves the column; and clamping `echoMaxTiles` to at least 2 in the options.

**Plan 6 did:**

- Class icons on whisper tiles, with a short name (realm dropped, 5 characters, UTF-8 aware) across the bottom, and the initial on class colour as the fallback. `core/ClassIconMedia.lua` first, then Blizzard's class atlas.
- A Battle.net logo on blue for friends not on a character, and their class icon (no name label) when they are; a `|K` name can't be cut.
- Distinct channel short names, so General and Guild no longer share "G".
- One painter, `Echo.PaintTileFace`, for the column tile, the toast, the stack card and the card's row, replacing each surface's own icon / glyph / letter branch.
- One badge rule, `View.Badge`, shared by the column tile and the card's row (the stack shows its own "N new" text on its meta line instead).
- The card keeps its place while scrolled up, with a clickable "N new below" hint (plain text, no glyph), instead of re-rendering under the reader.
- Closing a conversation drops its unsent draft on purpose, for both the stack and the card.
- Clicking the tile of the conversation the card already shows now closes the card.
- `View.Upper` upper-cases header meta text only on English clients, instead of mangling accented text on every locale.
