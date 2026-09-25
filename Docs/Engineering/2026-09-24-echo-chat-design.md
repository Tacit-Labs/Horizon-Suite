# Horizon Echo: conversation-first chat

**Date:** 2026-09-24
**Status:** Design approved, awaiting spec review
**Module:** Echo (new)

## Goal

Echo gives each conversation its own place on screen. A whisper partner or a group channel is a tile on the screen edge. Hover a tile and it becomes a card you can reply from. Click the card and it becomes the full conversation.

In simple terms: chat works like a messenger app sitting beside the normal chat window, not like one long scrolling log.

Blizzard's chat frames stay underneath as the source of truth. They still show everything, including combat log, system messages, loot, and any message Echo cannot safely read. If Echo is disabled or breaks, chat still works.

## Locked decisions

| Decision | Choice |
|----------|--------|
| Shape | Custom conversation layer (tiles, stack, card) beside Blizzard's chat, not a reskin and not a replacement |
| Conversations | Character whispers, Battle.net whispers, and group channels (party, raid, instance, guild, officer, custom channels) |
| Layout | One tile column on one screen edge; channels use glyph tiles |
| Notification tiers | Whispers: loud (reorder, toast, dot). Party/raid/instance: count, with a toast on mentions and raid warnings. Guild/officer/custom: quiet count. Each can be overridden per conversation |
| History | Whispers and BNet whispers persist (last 100 per conversation); channels are session-only; saving can be turned off |
| Combat | Stack and card collapse; tiles and counts stay live; loud toasts are held until combat ends |
| Clients | Retail and Forever, gated through `addon.Platform` capability keys |
| Intake | Echo registers its own `CHAT_MSG_*` events; it does not hook Blizzard's chat frames |
| Blizzard chat | Mirrored by default; an option hides whispers Echo has stored |

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
- Whisper tiles show the sender's initial on their class colour. BNet friends not on a character get a neutral Battle.net-blue tile. Channel tiles are dark with a glyph: **P**, **R**, **I**, **G**, **O**, or the channel's first letter.
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
- The header shows name, class and relationship (friend, guildmate, Battle.net), plus online status where the game provides it.
- Bubbles: incoming on the left, outgoing on the right in the accent tint. The newest outgoing bubble shows pending, sent or failed. Consecutive messages from the same sender within 2 minutes are grouped. Channel cards show the sender name in class colour above each group.
- Renders the last 100 messages in pooled bubble frames inside a scroll frame.
- × closes the conversation and removes its tile. Whisper history returns if that person messages again.
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

Echo stays a layer beside Blizzard's chat, not a replacement (a full overhaul was considered and set aside: it would mean showing secret lines Echo can't sort, keeping Blizzard's input box for protected slash commands, and a combat log Midnight largely closes to addons). Three read-only **feed** conversations collect non-conversation lines:

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

### Keybinds

Added to `Bindings.xml` under "Horizon Suite":

- **Echo: Reply to newest**
- **Echo: Toggle stack**

Blizzard's own Reply binding is left alone.

### Combat

On `PLAYER_REGEN_DISABLED`, the stack and card collapse. Tiles and counts keep updating. Loud toasts queue, and on `PLAYER_REGEN_ENABLED` the held toasts play, newest first, collapsed to one per conversation. Clicking a tile in combat still opens its card.

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

## Options

| Group | Settings |
|-------|----------|
| General | Enable; column edge; lock; scale; strata; max tiles |
| Notifications | Toast style (shared Compact / Framed / Accent); tier per conversation type; mention keywords; hold toasts in combat |
| History | Save whisper history (on); Clear history |
| Blizzard chat | Hide whispers Echo has stored (off) |
| Card | Width; height; font |

All strings go through `locales/horizon/enUS.lua` so `tools/locale_audit.js` picks them up.

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

## Testing

- **Logic tests:** `tools/test_echo_logic.js`, in the same shape as `tools/test_lootroll_logic.js` (fengari, stubbed globals, real locale file). Covers conversation keys, tier and ordering rules, unread counters, the history cap and trim, "secret messages are never persisted", and "sender secret produces no conversation, only a marker count".
- **In-game checklist** on the Windows PC, on Retail and the Forever beta: whisper; BNet whisper; reply from stack and card; failed whisper; shift-click link; combat hold and release; `/reload` keeps history; an encounter to see the secret path.
- **`/h echo test`** injects sample conversations so the interface can be checked without a second account.

## Out of scope for v1

- A replacement combat log or system-message view
- Joining, leaving or managing channels
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
6. Options, persistence, keybinds and polish

**Carried into plan 2.** Found while building the foundation, left for the view work:

- History must expose its saved conversation keys (`History.Keys`, restored through `Store.Restore`), so `/reload` brings back whisper tiles. Battle.net history is saved under `bt:<BattleTag>`, so restoring it needs a BattleTag-to-current-account-ID lookup across the friends list.
- Views order bubbles by array position, not `record.seq`: history-seeded messages all carry `seq = 0`.
- Decide whether `Store.Close` should clear `pinned`.
- Add `Store.Unsubscribe` if views are rebuilt at runtime.
- Slash command strings move to `addon.L` in plan 3.

**Carried into plan 5** (options and polish; this list was "plan 4" before the feeds took that number):

- **First task of plan 5:** coalesce the Tiles, Card and Stack redraws behind a one-frame dirty flag, so a burst of lines repaints once. Feeds make this matter: a group-loot roll burst files many lines in a frame, each of which currently redraws every view.
- A per-feed on/off option (Loot, Progress, System), for players who never want a feed's tile.
- Extend `Echo.PaintTileFace` to cover the toast and the stack card, which still carry their own copy of the icon / glyph / letter three-way branch.
- One shared badge-tier helper for the tile, the card's row and the stack, instead of each deciding the badge from the tier on its own.
- The column-edge option also flips which side the toast and stack open on.
- A scale change re-derives the saved position, so the column doesn't jump.
- Channel glyphs collide (General and Guild are both "G"); give them distinct glyphs.
- Clamp `echoMaxTiles` to at least 2 in the options.
- Better tile icons than the first letter of a name (director, 2026-09-25) — e.g. class icons from `core/ClassIconMedia.lua` for whispers, portraits or race icons, a Battle.net logo.
- Coalesce the card's re-renders on busy channels further; another conversation's news already repaints only its tile row.
- Anchor the scroll position while scrolled up, so new messages don't shift what you're reading.
- Keep drafts of closed conversations, or decide they're dropped on purpose.
- `upper()` on localized meta text only changes ASCII letters; use a locale-aware upper case or leave the text as it is.
