# Horizon Echo: Message Pins, Saved Guild Chat and History Clean-up Implementation Plan (10)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development.

**Goal** (agreed with the director on 2026-09-26):
1. **History clean-up.** Saved whisper and Battle.net conversations that nobody has touched for a set number of days are dropped at login. A pinned conversation is never dropped. The setting "Keep history for" offers 7, 30 or 90 days, or Forever; the default is 30.
2. **Saved guild chat.** Guild chat is saved by default, keeping the last 200 lines. It is shared by every character in the same guild. Officer chat has its own switch, off by default. Party, raid, instance chat and channels stay unsaved.
3. **Message pins.** Right-click a message and choose **Pin message**. The newest pin shows in a thin strip under the card's header. Clicking the strip scrolls to the pinned message, and a counter steps through older pins.
   - Pins are always saved, even in chats that are not otherwise saved, and the line limit never removes them.
   - The limits are 5 pins per chat and 50 per character.
   - A message the game hides can't be pinned.

**Size budget.** This was estimated for the director, not measured. A saved line costs about 110 bytes: 60–70 bytes of serialiser overhead plus the text. A full whisper conversation is about 11 KB, a full guild history about 22 KB, and 50 pins about 6 KB.

**Spec:** `Docs/Engineering/2026-09-24-echo-chat-design.md`. The branch is `feature/echo`, and the work is part of the draft PR Tacit-Labs/Horizon-Suite#447.

## Global Constraints

- **Lua:** Lua 5.1, fengari-safe. Use the Echo file header pattern. No new named frames. Frames stay non-secure.
- **Secret values:** call `Echo.IsSecret` before any `type()`, comparison or concatenation on a chat value or a Blizzard return. A secret value is never written to SavedVariables. Battle.net `|K` sender strings are never stored.
- **Strings:** everything shown to the player goes through `addon.L`. New keys go after the last Echo key in `locales/horizon/enUS.lua`.
- **Settings:** every new setting joins `addon.ECHO_DEFAULTS` and must appear on `options/modules/OptionsEcho.lua`; an existing test checks this. Push a setting into the module through `Echo.ApplyOptions`, in `modules/Echo/EchoOptions.lua`.
- **Storage:** everything lives under `HorizonDB.echoHistory`, which `History.Bind` attaches as `root`. `History.Clear` wipes guild history and pins as well as whispers.
- **Harness frames:** the stand-in frames answer unknown keys with no-op functions. Read Echo's own cached fields with `rawget(frame, "_field")`.
- **Tests:** run `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`; 1407 tests pass at the start. Write each test first and see it fail. Test sections go before the "Redraw: one repaint per frame" section. Parse-check every changed Lua file with the fengari one-liner in `Docs/Engineering/2026-09-25-echo-options-plan.md`.
- **Commits:** Conventional Commits with scope `echo`. Run `git add` and `git commit` as separate commands. Each message ends with exactly `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Never use `git stash`. Don't push.

---

### Task 1: Drop stale saved conversations

**Files:** `modules/Echo/EchoHistory.lua`, `EchoOptions.lua`, `EchoModule.lua`, the defaults, `OptionsEcho.lua`, the strings, and the tests.

- **Setting:** `echoHistoryDays`, default `30`. `0` means Forever.
- **`History.SetMaxAge(days)`:** `ApplyOptions` calls it with the setting.
- **`History.Prune(now) -> removed`** runs once, after `Bind`, when the module enables.
  - The age of a conversation is `now` minus the `t` of its newest saved entry. A list with no readable `t` counts as stale.
  - It checks `root.chars[*][key]` and `root.bnet[key]`, and removes any list older than `days × 86400` seconds.
  - It keeps a list whose key has `pinned = true` in any character's `root.prefs`. Whispers are keyed by conversation key and Battle.net by `bt:<tag>`, the same keys `PrefKey` uses.
  - A character bucket left empty is removed.
  - Guild history, added in Task 2, is pruned by the same rule. Each guild's lists are pruned separately.
  - With `days = 0` it removes nothing.
  - It returns how many lists it removed, for the tests.
- **Options:** add a dropdown **Keep history for** to the History section, with 7 days, 30 days, 90 days and Forever. Changing it takes effect at the next login. Say so in the description.
- **Tests:**
  - A 40-day-old whisper list is removed at 30 days, and a 10-day-old one is kept.
  - A pinned stale list is kept.
  - Nothing is removed at `0`.
  - An empty character bucket is removed.
  - A Battle.net list is pruned by `bt:` key.

**Commit:** `feat(echo): drop saved conversations nobody has touched in a while`.

---

### Task 2: Save guild and officer chat

**Files:** `EchoHistory.lua`, `EchoStore.lua`, `EchoOptions.lua`, the defaults, `OptionsEcho.lua`, the strings, and the tests.

- **Settings:** `echoSaveGuild`, default `true`, and `echoSaveOfficer`, default `false`. Both do nothing while `echoSaveHistory` is off, because that switch is the master for everything saved automatically. The options page shows them as toggles under **Save whisper history**. Rename that toggle's label to **Save chat history**, and rewrite its description to cover whispers and, when switched on below, guild chat.
- **Which kinds are saved:** replace the fixed `Store.PERSISTED_KINDS` lookup with `Store.IsPersisted(kind)`.
  - It returns true for `whisper` and `bnet`.
  - For `guild` and `officer`, it returns true when their setting is on.
  - `ApplyOptions` pushes the two flags through `Store.SetPersisted(kind, bool)`.
  - Keep `Store.PERSISTED_KINDS` as the base table, so existing readers still work.
- **Guild key:** `History.GuildKey() -> "Guild Name-Realm" | nil`, from `GetGuildInfo("player")`.
  - Its realm return is nil for a guild on your own realm; fall back to `GetNormalizedRealmName()`.
  - Return nil when either value can't be read, is secret or is empty.
  - Call it through `pcall`.
- **Storage:** `root.guilds[guildKey] = { guild = list, officer = list }`. `Bucket` routes `guild` and `officer` conversations there. With no guild key, nothing is written or loaded.
- **Caps:**
  - `History.GUILD_CAP = 200`.
  - `Store.MaxMessages(kind)` returns 200 for `guild` and `officer`, and `Store.MAX_MESSAGES` (100) otherwise. `Append` in the Store uses it.
- **Richer entries:**
  - Saved entries gain `s`, the sender's `Name-Realm`, and `c`, the class token. Both are only written when readable and not secret.
  - `History.Load` restores them to `record.sender` and `record.class`.
  - A Battle.net `record.sender` is a `|K` string, so it is never written. Keep `s` for Battle.net entries nil.
- **Reopening after a reload:** `SaveSession` and `SessionKeys` also carry the `guild` and `officer` keys when those kinds are persisted, so a reload brings their tiles back with the history loaded.
- **Loading late:** the guild can be unknown at the moment the guild conversation is created. If `Load` found no guild key when the conversation was created, the Store loads the history the first time a key becomes available: on the next `Add` for that conversation, prepend the saved lines before the new one. Mark the conversation `historyLoaded` so this only happens once.
- **Tests:**
  - With saving on, guild lines are written under the guild key, and officer lines are only written when `echoSaveOfficer` is on.
  - The cap is 200.
  - Sender and class round-trip, and secret senders aren't written.
  - The Battle.net `|K` sender is not written.
  - Nothing is written with no guild key.
  - The late load prepends once.
  - `SessionKeys` restores `guild`.
  - `Clear` wipes `guilds`.
  - With `echoSaveHistory` off, guild isn't saved.

**Commit:** `feat(echo): save guild chat, and officer chat on request`.

---

### Task 3: The pin model

**Files:** `EchoHistory.lua`, `EchoStore.lua`, and the tests.

- **Storage:** `root.pins[charKey][prefKey] = { { t, text, s, out }, … }`, oldest first. It uses the same `charKey` and `PrefKey` as the conversation prefs, so Battle.net pins are keyed by BattleTag.
  - Pins are the player's explicit choice, so they are saved whatever the history switches say.
  - `Clear` wipes them.
  - `Prune` never touches them.
- **Limits:** `History.PINS_PER_CHAT = 5` and `History.PINS_TOTAL = 50`, per character.
- **History API:**
  - **`History.Pins(convKey) -> list`** returns a copy.
  - **`History.AddPin(convKey, record) -> ok, reason`** returns one of:
    - `false, "secret"` when `record.secret` is set or the text is secret;
    - `false, "chat"` when the chat already has 5 pins;
    - `false, "total"` when the character already has 50;
    - `false, "unsaved"` when the key can't be saved: an unknown realm, or a BattleTag that can't be read;
    - `true`.

    A record already pinned (the same `t`, `text` and `s`) returns true without adding a duplicate. The sender is stored only when readable and not a `|K` string. For a Battle.net incoming line, store `s = nil`, and the strip shows the conversation's name.
  - **`History.RemovePin(convKey, index) -> bool`.**
- **Store API:**
  - **`Store.PinMessage(convKey, record) -> ok, reason`**, **`Store.UnpinMessage(convKey, index)`** and **`Store.Pins(convKey)`**.
  - Pinning and unpinning notify with `"update"`, so views repaint.
  - **`Store.IsPinnedMessage(convKey, record) -> bool`** matches a record against the pins by `time`, `text` and `sender`. The card uses it for the bubble marker.
- **Tests:**
  - Pinning a channel line saves it even though channels aren't persisted.
  - The 6th pin in a chat returns `"chat"`, and the 51st overall returns `"total"`.
  - A secret record returns `"secret"`.
  - A duplicate pin is not added twice.
  - Unpin removes by index.
  - Pins survive `History.Prune` and a Store message-cap trim.
  - A Battle.net pin has no `s`.
  - `IsPinnedMessage` matches.

**Commit:** `feat(echo): pin messages in any chat`.

---

### Task 4: Pins on the card

**Files:** `EchoCard.lua`, `EchoMenu.lua` (or a small helper beside it), `EchoView.lua` if a pure helper helps testing, `media/echo/pin.tga`, the strings, and the tests.

- **Pin art:** generate `media/echo/pin.tga`, 32×32 RGBA: a white pushpin with anti-aliased alpha, in the style of `circle.tga`. Tint it with `SetVertexColor`. Resolve the path the same way `EchoRound` resolves its media.
- **Right-click a bubble or a feed line** to open a context menu through `MenuUtil.CreateContextMenu`, when `Echo.Menu.Available()`. The menu shows one of:
  - **Pin message** when the message isn't pinned;
  - **Unpin message** when it is;
  - a disabled button explaining why it can't be pinned: "Can't pin a hidden message", "This chat has 5 pins", "You have 50 pins" or "Can't save this chat yet".

  Hyperlink clicks keep working. Right-click opens the menu only when the click isn't on a hyperlink: use `OnMouseUp` with `"RightButton"`, since `OnHyperlinkClick` handles link clicks. Keep the menu logic in a function the tests can call, for example `Menu.BuildMessage(root, convKey, record)`.
- **The bubble marker:** a pinned message shows the pin icon, 10px, in the accent colour, at the bubble's top corner on the side away from the sender. Feed lines show it before the line. Clear it when a bubble is reused for an unpinned message.
- **The pin strip:**
  - It shows only when the shown conversation has pins. It sits under the header, and under the tab strip on a group card.
  - It is 22px high, drawn with `Echo.Round` at radius `SMALL`, in a dim accent tint.
  - It shows the pin icon, the pinned text on one line (truncated, with links shown as their names), and, when there are two or more pins, a counter such as `2/3`. Click the counter to step to the next older pin, wrapping around.
  - Click the text to scroll the card to that message when it is still in the conversation. Match with `IsPinnedMessage`, then set `offset` so the message sits at the bottom of the view. Otherwise the click does nothing.
  - Hovering the text shows the full message, its sender and its time in a tooltip.
  - A small × on the right unpins the shown pin.
  - The message area moves down by `Card.PIN_STRIP = 22 + 4` when the strip shows. Extend `AnchorArea` with a `pinned` flag, next to `grouped`.
  - When you switch between the conversations or tabs a card shows, the strip starts on the newest pin.
- **Tests:**
  - The right-click menu offers Pin on an unpinned readable message and Unpin on a pinned one.
  - The menu shows the right disabled reason for a secret message, a full chat and the total limit.
  - Pinning shows the strip, and the area anchor moves down by `PIN_STRIP`. It adds to the tab strip on a group card.
  - The counter steps and wraps.
  - The text click sets `offset` to the pinned message.
  - The × unpins, and the strip hides with the last pin.
  - A pinned bubble shows the marker, and a reused bubble clears it.

**Commit:** `feat(echo): show pinned messages on the card`.

---

### Task 5: Record it

- **Spec:** add "Message pins, saved guild chat and clean-up (plan 10, 2026-09-26)" to `Docs/Engineering/2026-09-24-echo-chat-design.md`. Cover:
  - what is saved, and where;
  - the caps: 100 per whisper chat, 200 for guild, 5 pins per chat and 50 per character;
  - the clean-up rule;
  - the size budget above;
  - that pins ignore the history switches, and `Clear` wipes them.
- **In-game checklist** (in this file). Echo gains a media file, so restart the game.
  - [ ] Right-click a Trade message and pin it. After `/reload`, open the Trade tile again: the pin strip still shows it.
  - [ ] Pin three messages in a whisper chat. The counter steps through them, and clicking the text scrolls to each.
  - [ ] The × unpins, and the strip goes away with the last pin.
  - [ ] Guild chat from before a `/reload`, or from an alt in the same guild, shows when the guild tile opens.
  - [ ] Officer chat isn't saved until its switch is on.
  - [ ] Clicking a link in a message still opens it. Right-clicking elsewhere on the message opens the pin menu.
  - [ ] During an encounter, a hidden message offers "Can't pin a hidden message".
- **Commit:** `docs(echo): record message pins and saved guild chat`.
