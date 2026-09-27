# Horizon Echo: Echo Icon Clicks and the Card Closing Itself Implementation Plan (14)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development.

**Goal** (agreed with the director on 2026-09-26):
1. **The card closes itself** when it has been left untouched for a while.
2. **Left-clicking the Echo icon** opens what needs you: the newest unread conversation, or the All view when nothing is unread. It no longer toggles the stack.
3. **Right-clicking the Echo icon** opens a quick menu:
   - Start a chat…
   - Mark all as read
   - Collapse (a radio of three choices)
   - Hide Blizzard chat
   - Lock position
   - Echo settings…
4. **The + button is removed.** Starting a chat moves to the right-click menu.

**Spec:** `Docs/Engineering/2026-09-24-echo-chat-design.md`. The branch is `feature/echo`, and the work is part of the draft PR Tacit-Labs/Horizon-Suite#447.

## Global Constraints

- **Code:** Lua 5.1, fengari-safe. Use the Echo file header pattern. No new named frames. Echo's frames stay non-secure.
- **Blizzard's input line:** plan 12's rules apply. Never call `ChatEdit_*`, `ChatFrameUtil.*` or `SetFocus`/`SetAttribute`/`SetText` on `ChatFrame1EditBox`. Reading `HasFocus()` is allowed.
- **Secret values:** call `Echo.IsSecret` before any `type()`, comparison or concatenation.
- **Strings and settings:** strings go through `addon.L`. New settings join `addon.ECHO_DEFAULTS` and appear on `OptionsEcho.lua`. Remove any default or string that no longer has a use.
- **Tests:** run `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`; 2583 tests pass at the start. Write each test first and see it fail. Test sections go before "Redraw: one repaint per frame". Parse-check every changed Lua file with the fengari one-liner in `Docs/Engineering/2026-09-25-echo-options-plan.md`.
- **Commits:** Conventional Commits with scope `echo`. Run `git add` and `git commit` as separate commands. Each message ends with exactly `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Never use `git stash`. Don't push.

---

### Task 1: The card closes itself when left alone

**Files:** `modules/Echo/EchoCard.lua`, the defaults, `OptionsEcho.lua`, the strings, and the tests.

**Setting:** `echoCardIdleClose`, in seconds. It defaults to `30`, with a slider from `0` to `120` in steps of 5, where `0` means Never. It goes in the Card section:
- `L["ECHO_CARD_IDLE_CLOSE"]` = "Close the card after";
- `_DESC` = "Seconds without touching the card before it closes itself. 0 keeps it open."

**What counts as touching the card:**
- the mouse is over the card (root) or over its row tiles;
- the card's own reply box has focus;
- Blizzard's docked line is visible over the card and has focus (`Input.Covers` plus `ChatFrame1EditBox:HasFocus()`, read with an IsSecret check);
- the card's ⋯ menu or the message menu is open (`Menu.IsOpen()`, if MenuUtil exposes it; otherwise count the ~1s after a menu was opened);
- scrolling, clicking a tab or a row tile, sending, or switching conversation.

**Timer:**
- `Card.idle` counts up in the card's OnUpdate while the card is shown and none of the touch conditions hold. Any touch resets it to 0.
- When it reaches the setting, the card closes as if its tile were clicked: the reverse genie into the tile when animation is on and the tile is visible, otherwise an instant `Card.Hide()`.
- A new message arriving in the shown conversation does not count as a touch. The card still closes on time.
- The count doesn't run while a genie is animating, or in combat. The card already collapses in combat.
- When the card closes, collapse mode's own fold timer takes over as it does today.

**Tests:**
- The card closes after the idle time, and the genie runs when a tile is present.
- The mouse over the card keeps it open, and so does focus in either box.
- Scrolling resets the count.
- `0` never closes it.
- An incoming message doesn't reset the count.
- The setting is on the options page.

**Commit:** `feat(echo): close the card after a while untouched`.

---

### Task 2: Echo icon clicks, and removing the +

**Files:** `modules/Echo/EchoTiles.lua`, `EchoCollapse.lua`, `EchoCompose.lua`, `EchoMenu.lua` (or a new `EchoIconMenu` section inside `EchoMenu.lua`), `EchoStore.lua`, the defaults, `OptionsEcho.lua`, the strings, and the tests.

**Left-click, `Tiles.OpenInbox()`:**
- Open the card on the conversation that needs you most. Pick the first match, in this order:
  1. a conversation with a `"dot"` badge (a loud unread, such as a whisper), newest by `lastLoud`;
  2. a `"count"` badge, newest by its last message's `seq`;
  3. otherwise, the All view (`"all"`, through `Store.Start` if the tile is closed; `all` is a feed, so reopen it through the feed path).
- Open it with `Card.Show(key, Tiles.TileFor(key))`. If the card is already showing that conversation, clicking closes it, as a tile toggle does.
- The stack is no longer opened by clicking the icon. Hovering tiles still peeks at it.

**Right-click, `Menu.OpenIcon(owner)`:** a MenuUtil context menu, through `pcall` as the other menus are. Entries, in order:
1. **Start a chat…:** a submenu built by `Compose.Build` (reuse it: build into the submenu's description).
2. **Mark all as read:** a new `Store.MarkAllRead()`, which runs `MarkRead` on every open conversation and notifies once.
3. A divider, a **Collapse** title, and three radios bound to `echoCollapse` (Off, Collapse all, Keep new messages), writing through `addon.SetDB`.
4. **Hide Blizzard chat:** a checkbox bound to `echoHideBlizzardChat`, writing through `addon.SetDB`. Changing it follows the existing reload flow.
5. **Lock position:** a checkbox bound to `echoLockPosition`.
6. A divider, then **Echo settings…:** opens the options to Echo's page. Use the same call the dashboard or slash command uses; look for how `/h echo` or the dashboard opens a module page. If there's no module-page opener, open the options (`addon.ShowOptions`) and document it.

**Registering the clicks:** the icon registers `"LeftButtonUp", "RightButtonUp"`. Its drag (move) stays as it is.

**Removing the + button:**
- Delete `CreatePlusButton`, `Tiles.PLUS_SIZE`, `PlusAvailable` and the + parts of `Tiles.TilesBottom()`, which is back to one step, and of Collapse (`plus` in the layout and hover).
- Remove the tests that only covered the +, and name each removed test in the report.
- Keep `Compose.Build` and the whisper popup: the right-click menu uses them.

**Strings:** the new menu labels, such as `ECHO_ICON_START`, `ECHO_ICON_MARK_READ`, `ECHO_ICON_SETTINGS` and `ECHO_LOCK_POSITION`. Reuse the existing collapse and hide-chat strings. Remove `ECHO_NEW_CHAT` if nothing uses it any more.

**Tests:**
- Left-click opens the newest dot conversation over a count one, a count one when there are no dots, and All when nothing is unread.
- A second click closes it.
- It no longer toggles the stack.
- The right-click menu has the entries in order: the Start submenu is built by Compose, Mark all read clears every unread, the radios set `echoCollapse`, and the checkboxes set their settings.
- Echo settings… calls the opener.
- The + button no longer exists, and the tile bottom is one step.
- Collapse still works with no +.

**Commit:** `feat(echo): the Echo icon opens what needs you, and right-click holds the rest`.

---

### Task 3: Record it

- **Spec:** add "Echo icon and card idle close (plan 14, 2026-09-26)" under "Interface", and update any earlier text that describes the + button or the icon opening the stack.
- **In-game checklist** (in this file):
  - [ ] Leave a card open and untouched: it closes into its tile after 30s. With the mouse over it, or while typing, it stays.
  - [ ] Left-click the Echo icon with an unread whisper: its card opens. With nothing unread: All opens. Click again: it closes.
  - [ ] Right-click the Echo icon: Start a chat… lists places to talk. Mark all as read clears the badges. The Collapse choices switch live.
  - [ ] There's no + button any more, and the column sits one step lower.
  - [ ] Dragging the Echo icon moves the column without opening anything.
- **Commit:** `docs(echo): record the Echo icon clicks and card idle close`.
