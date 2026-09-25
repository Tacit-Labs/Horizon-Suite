# Horizon Echo: Expanded Card Implementation Plan (3 of 4)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the expanded card: the whole conversation with a tile row, bubbles, a status line and a reply box. It opens from a tile click, a toast or the stack's Open button. Add the `⋯` menu (pin, notification tier, close), with those choices remembered per character, and shift-click links into Echo's reply boxes.

**Architecture:** The Store stays the only model. Pins and tiers persist through two new History functions, `LoadPref` and `SavePref`, which the Store calls. New pure helpers in `EchoView` cover message grouping, bubble width, relationship, the card meta line, status text, the menu's data and shared drafts. They're tested in fengari. `EchoMenu` turns the menu data into a Blizzard `MenuUtil` context menu. `EchoLinks` post-hooks the game's link insertion. `EchoCard` is the frame, and is smoke-tested with the harness's stand-in frames.

**Tech Stack:** WoW Lua 5.1 addon (Retail 120100 and Forever 16001), and the fengari harness `tools/test_echo_logic.js`.

**Spec:** `Docs/Engineering/2026-09-24-echo-chat-design.md`, sections "Expanded: card" (including "Decided for plan 3"), "Combat" and "Storage".

**Plan series:** 1 Foundation (done). 2 Tiles and stack (done). **3 Expanded card (this plan).** 4 Options page, dashboard, whisper filter, keywords and polish. All of it is on branch `feature/echo`.

## Global Constraints

- **Lua:** Lua 5.1 only, and runnable on fengari's 5.3. Don't use `goto`, `//`, bitwise operators, `unpack` (use explicit indexes), `tinsert` (use `table.insert`) or `%z` in patterns.
- **File header:** every file starts with `local addon = _G.HorizonSuite` and `if not addon then return end`, and hangs off `addon.Echo`.
- **Secret values:** ask `Echo.IsSecret(v)` before `type()`, comparing, concatenating, `:upper()`, `:match()` or indexing a table by a chat value. A secret message text may be passed to `FontString:SetText` **alone**, never joined with other text. Never read a text height or width from a FontString holding secret text.
- **Battle.net names** are protected `|K` strings: display them whole, and never cut, upper-case, format or join them.
- **Frames** are non-secure. The card closes when combat starts, but clicking a tile in combat still opens it.
- **Frame names:** `HorizonSuiteEchoCard` (new), alongside `HorizonSuiteEchoColumn` and `HorizonSuiteEchoStack`. No other globals.
- **Strings** shown to the player come from `addon.L` (`locales/horizon/enUS.lua`).
- **Colours:**
  - accent `#8FA3E8` (`View.ACCENT`)
  - panel background `View.PANEL_BG`
  - panel border `View.PANEL_BORDER`
  - glyph tile background `View.GLYPH_BG`
  - incoming bubble `0.11, 0.11, 0.15, 0.95` with border `0.28, 0.30, 0.38, 0.5`
  - outgoing bubble: accent at 0.24 alpha (0.14 while pending) with an accent border at 0.6
- **Commits:** Conventional Commits with scope `echo`, on branch `feature/echo`, each with exactly one `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` trailer. Run `git add` and `git commit` as separate commands.
- **Test command:** `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js` (383 passing at the start of this plan).
- **Parse check** (luacheck isn't installed locally):
  `NODE_PATH="$HOME/.cache/hs-test/node_modules" node -e "const {lauxlib,lua,to_luastring,to_jsstring}=require('fengari');const L=lauxlib.luaL_newstate();for(const f of process.argv.slice(1)){const s=require('fs').readFileSync(f,'utf8');console.log(f,lauxlib.luaL_loadbuffer(L,to_luastring(s),null,to_luastring(f))===lua.LUA_OK?'parses':to_jsstring(lua.lua_tostring(L,-1)))}" <files>`
- **Stand-in frames** in the harness: `STUB_FRAME` / `STUB_CREATE_FRAME`. Frame sections set `CreateFrame = STUB_CREATE_FRAME` first. Reading an unset field on a stub returns a stub function, so use `rawget` to test that a field is absent. Per-object method overrides are undone by setting them back to `nil`.

## File map

| File | Status | Responsibility |
|------|--------|----------------|
| `modules/Echo/EchoHistory.lua` | Modify | `LoadPref` and `SavePref` (per character; Battle.net by BattleTag) |
| `modules/Echo/EchoStore.lua` | Modify | Load prefs on create; save on `SetTier`, `SetPinned` and `Close`; add `OverrideOf` |
| `modules/Echo/EchoView.lua` | Modify | `StartsGroup`, `NewestOutgoing`, `BubbleWidth`, `Relationship`, `CardMeta`, `StatusText`, `MenuSpec`; shared drafts |
| `modules/Echo/EchoLinks.lua` | Create | Shift-click links into the focused Echo box |
| `modules/Echo/EchoMenu.lua` | Create | The `⋯` menu, built with `MenuUtil`, and its actions |
| `modules/Echo/EchoCard.lua` | Create | The expanded card |
| `modules/Echo/EchoStack.lua` | Modify | Shared drafts, link focus, hand-off to the card |
| `modules/Echo/EchoTiles.lua` | Modify | Tile and toast clicks open the card |
| `modules/Echo/EchoModule.lua` | Modify | Enable and disable the card, hook links, close the card in combat |
| `locales/horizon/enUS.lua` | Modify | Card and menu strings |
| `HorizonSuite.toc` | Modify | Load the new files |
| `.luacheckrc` | Modify | New read globals |
| `tools/test_echo_logic.js` | Modify | Pref, view, link, menu and card tests |

---

### Task 1: Remember pins and tiers per character

**Files:**
- Modify: `modules/Echo/EchoHistory.lua` (new functions after `History.SessionKeys`)
- Modify: `modules/Echo/EchoStore.lua` (`GetOrCreate`, `SetTier`, `SetPinned`, `Close`; new `OverrideOf`)
- Test: `tools/test_echo_logic.js` (new section before `// --- Summary`)

**Interfaces:**
- Produces:
  - `History.LoadPref(convKey) -> { tier, pinned }|nil`.
  - `History.SavePref(convKey, tier|nil, pinned) -> boolean`.
  - `Store.OverrideOf(convKey) -> string|nil`.
- Saved shape: `HorizonDB.echoHistory.prefs["Name-Realm"][prefKey] = { tier = "muted"|…|nil, pinned = true|nil }`. `prefKey` is the conversation key, except Battle.net, which uses `bt:<BattleTag>`. A Battle.net pref with no readable BattleTag isn't saved. An entry with no tier and no pin is removed.
- Prefs ignore the history switch, and `History.Clear` leaves them alone.

- [ ] **Step 1: Write the failing tests**

Insert before `// --- Summary`:

```js
// --- Prefs: pins and tiers remembered per character -------------------------------------
run(`
  local S, H = HorizonSuite.Echo.Store, HorizonSuite.Echo.History
  S.Reset()
  local db = {}
  local charKey = "Kaelis-Horizon"
  H.Bind(db, function() return charKey end)
  local savedBattleNet = C_BattleNet
  C_BattleNet = { GetAccountInfoByID = function(id) if id == 77 then return { battleTag = "Vexa#1234" } end end }

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi" })
  S.SetPinned("w:Brisa-Horizon", true)
  S.SetTier("ch:Trade", "muted")
  S.Add({ convKey = "bn:77", text = "yo" })
  S.SetTier("bn:77", "quiet")
  S.Add({ convKey = "bn:404", text = "who" })
  S.SetPinned("bn:404", true)
  local prefs = db.echoHistory.prefs and db.echoHistory.prefs["Kaelis-Horizon"]
  check("a pin is saved", prefs and prefs["w:Brisa-Horizon"] and prefs["w:Brisa-Horizon"].pinned == true, "missing")
  check("a tier is saved even before the conversation opens", prefs and prefs["ch:Trade"] and prefs["ch:Trade"].tier == "muted", "missing")
  check("battle.net prefs are saved by battletag, never account id",
        prefs and prefs["bt:Vexa#1234"] and prefs["bt:Vexa#1234"].tier == "quiet" and prefs["bn:77"] == nil, "wrong key")
  check("a battle.net friend without a battletag is not saved", prefs and prefs["bn:404"] == nil and prefs["bt:"] == nil, "saved")

  -- A reload: the store forgets everything; prefs come back as conversations reopen.
  S.Reset()
  S.Add({ convKey = "w:Brisa-Horizon", text = "back" })
  check("the pin survives a reload", S.Get("w:Brisa-Horizon").pinned == true, "lost")
  S.Add({ convKey = "ch:Trade", text = "wts" })
  check("the tier survives a reload", S.TierOf("ch:Trade") == "muted" and S.Get("ch:Trade").unread == 0, S.TierOf("ch:Trade"))
  S.Add({ convKey = "bn:77", text = "again" })
  check("a battle.net tier survives by battletag", S.TierOf("bn:77") == "quiet", S.TierOf("bn:77"))
  check("the override can be read", S.OverrideOf("ch:Trade") == "muted" and S.OverrideOf("party") == nil, "?")

  S.SetTier("ch:Trade", nil)
  check("going back to the default removes the saved entry", prefs["ch:Trade"] == nil, "kept")
  S.Close("w:Brisa-Horizon")
  check("closing a conversation drops its saved pin", prefs["w:Brisa-Horizon"] == nil, "kept")

  H.SetEnabledCheck(function() return false end)
  S.SetPinned("bn:77", true)
  check("prefs save with history turned off", prefs["bt:Vexa#1234"].pinned == true and prefs["bt:Vexa#1234"].tier == "quiet", "?")
  H.SetEnabledCheck(function() return true end)
  H.Clear()
  check("clearing history keeps prefs", db.echoHistory.prefs["Kaelis-Horizon"]["bt:Vexa#1234"] ~= nil, "wiped")

  charKey = "Alt-Horizon"
  S.Reset()
  S.Add({ convKey = "bn:77", text = "x" })
  check("prefs are per character", S.TierOf("bn:77") == "loud" and S.Get("bn:77").pinned == false, S.TierOf("bn:77"))
  db.echoHistory.prefs["Alt-Horizon"] = { ["ch:Trade"] = { tier = "shouty" } }
  S.Add({ convKey = "ch:Trade", text = "x" })
  check("an invalid saved tier is ignored", S.TierOf("ch:Trade") == "quiet", S.TierOf("ch:Trade"))
  charKey = "Kaelis-Horizon"
  C_BattleNet = savedBattleNet
  H.Unbind()
  check("an unbound history saves no prefs", H.SavePref("w:X-Horizon", "muted", false) == false, "saved")
  S.Reset()
`, 'prefs');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run the test command. Expected: exit 1 on the first `prefs` check (`a pin is saved  got: missing`), or a nil call on `OverrideOf`.

- [ ] **Step 3: Implement in `modules/Echo/EchoHistory.lua`**

Insert directly after the `end` of `History.SessionKeys`:

```lua
-- Where a conversation's pin and tier are saved: Battle.net by BattleTag (the account ID
-- only lasts a session), everything else by its conversation key.
local function PrefKey(convKey)
    if Echo.Store.KindOf(convKey) == "bnet" then
        local tag = History.BattleTagFor(convKey)
        return tag and ("bt:" .. tag) or nil
    end
    return convKey
end

local function PrefBucket(create)
    if not root then return nil end
    local charKey = characterKey()
    if not charKey then return nil end
    if type(root.prefs) ~= "table" then
        if not create then return nil end
        root.prefs = {}
    end
    local bucket = root.prefs[charKey]
    if type(bucket) ~= "table" then
        if not create then return nil end
        bucket = {}
        root.prefs[charKey] = bucket
    end
    return bucket
end

--- A conversation's saved pin and tier on this character. Prefs are the player's
-- settings, not chat content, so the history switch doesn't affect them.
-- @param convKey string
-- @return table|nil { tier = string|nil, pinned = boolean|nil }
function History.LoadPref(convKey)
    local key = PrefKey(convKey)
    local bucket = key and PrefBucket(false)
    local pref = bucket and bucket[key]
    if type(pref) ~= "table" then return nil end
    return pref
end

--- Save a conversation's pin and tier on this character; nothing to save removes it.
-- @param convKey string
-- @param tier string|nil  the override, nil for the kind's default
-- @param pinned boolean|nil
-- @return boolean saved
function History.SavePref(convKey, tier, pinned)
    local key = PrefKey(convKey)
    if not key then return false end
    local bucket = PrefBucket(true)
    if not bucket then return false end
    if tier == nil and not pinned then
        bucket[key] = nil
    else
        bucket[key] = { tier = tier, pinned = pinned and true or nil }
    end
    return true
end
```

- [ ] **Step 4: Implement in `modules/Echo/EchoStore.lua`**

In `GetOrCreate`, directly before `conversations[convKey] = conv`, add:

```lua
    local pref = Echo.History and Echo.History.LoadPref(convKey)
    if pref then
        conv.pinned = pref.pinned == true
        if overrides[convKey] == nil and Store.VALID_TIERS[pref.tier] then overrides[convKey] = pref.tier end
    end
```

Directly above `--- Override one conversation's tier; nil restores the default.`, add:

```lua
-- Save a conversation's pin and tier (Task 1 of plan 3).
local function SavePref(convKey)
    if not Echo.History then return end
    local conv = conversations[convKey]
    Echo.History.SavePref(convKey, overrides[convKey], conv and conv.pinned)
end

--- The conversation's own tier, or nil when it follows its kind's default.
-- @param convKey string
-- @return string|nil
function Store.OverrideOf(convKey)
    return overrides[convKey]
end
```

`Store.SetTier`, `Store.SetPinned` and `Store.Close` sit below `SavePref` in the file, so they can call it. In each one, call `SavePref(convKey)` immediately before its `Notify(...)` line.

- [ ] **Step 5: Run the tests and confirm they pass**

Expected: `398 passed, 0 failed`.

- [ ] **Step 6: Commit**

```bash
git add modules/Echo/EchoHistory.lua modules/Echo/EchoStore.lua tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): remember pins and tiers per character" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: View helpers for the card, shared drafts and strings

**Files:**
- Modify: `modules/Echo/EchoView.lua` (append before the final `NewToastQueue` block, or at the end of the file)
- Modify: `locales/horizon/enUS.lua` (append to the Echo block at the end)
- Test: `tools/test_echo_logic.js` (new section before `// --- Summary`)

**Interfaces:**
- Consumes: `Echo.Store.OverrideOf`, `Echo.Store.TierOf`, `Echo.IsSecret`, `View.LastClass`, `addon.L`.
- Produces:
  - `View.GROUP_GAP_SECONDS` (120), `View.StartsGroup(messages, i) -> boolean`, `View.NewestOutgoing(conv) -> index|nil`.
  - `View.BubbleWidth(measured|nil, maxWidth, pad) -> number`.
  - `View.Relationship(conv) -> label|nil, online|nil`, `View.CardMeta(conv) -> string`, `View.StatusText(status) -> string`.
  - `View.TIER_CHOICES`, `View.MenuSpec(conv) -> entries`.
  - `Echo.ParkDraft(convKey, text)`, `Echo.TakeDraft(convKey) -> string`, `Echo.ClearDrafts()`.
- Menu entry shape: `{ kind = "button"|"title"|"radio"|"divider", label, action = "pin"|"tier"|"close", value, selected }`.

- [ ] **Step 1: Write the failing tests**

Insert before `// --- Summary`:

```js
// --- View: card helpers, menu data and shared drafts ------------------------------------
run(`
  local S, V, E = HorizonSuite.Echo.Store, HorizonSuite.Echo.View, HorizonSuite.Echo
  S.Reset()

  local msgs = {
    { sender = "A-Horizon", time = 100 },
    { sender = "A-Horizon", time = 130 },
    { sender = "B-Horizon", time = 140 },
    { outgoing = true, time = 150 },
    { outgoing = true, time = 400 },
    { sender = SECRET("A-Horizon"), time = 410 },
    { sender = SECRET("A-Horizon"), time = 411 },
  }
  check("the first message starts a group", V.StartsGroup(msgs, 1) == true, "?")
  check("the same speaker soon after continues it", V.StartsGroup(msgs, 2) == false, "?")
  check("another speaker starts a group", V.StartsGroup(msgs, 3) == true, "?")
  check("switching sides starts a group", V.StartsGroup(msgs, 4) == true, "?")
  check("a long pause starts a group", V.StartsGroup(msgs, 5) == true, "?")
  check("a secret speaker always starts a group", V.StartsGroup(msgs, 7) == true, "?")

  check("newest outgoing message", V.NewestOutgoing({ messages = msgs }) == 5, V.NewestOutgoing({ messages = msgs }))
  check("no outgoing message", V.NewestOutgoing({ messages = { msgs[1] } }) == nil, "?")

  check("a short readable text gets a fitted bubble", V.BubbleWidth(40.2, 250, 8) == 57, V.BubbleWidth(40.2, 250, 8))
  check("a long readable text stops at the widest bubble", V.BubbleWidth(900, 250, 8) == 250, V.BubbleWidth(900, 250, 8))
  check("unmeasured text gets the widest bubble", V.BubbleWidth(nil, 250, 8) == 250, V.BubbleWidth(nil, 250, 8))

  check("status text", V.StatusText("pending") == "ECHO_STATUS_PENDING" and V.StatusText("failed") == "ECHO_STATUS_FAILED" and V.StatusText(nil) == "", "?")

  local savedFriends, savedGuild, savedBattleNet = C_FriendList, C_GuildInfo, C_BattleNet
  C_FriendList = { GetFriendInfo = function(name) if name == "Brisa" then return { connected = false } end end }
  C_GuildInfo = { MemberExistsByName = function(name) return name == "Thorn-Horizon" end }
  C_BattleNet = { GetAccountInfoByID = function(id) return { gameAccountInfo = { isOnline = true } } end }
  local label, online = V.Relationship({ kind = "whisper", key = "w:Brisa-Horizon" })
  check("a friend found by short name, offline", label == "ECHO_FRIEND" and online == false, tostring(label) .. "/" .. tostring(online))
  label, online = V.Relationship({ kind = "whisper", key = "w:Thorn-Horizon" })
  check("a guildmate, online unknown", label == "ECHO_GUILDMATE" and online == nil, tostring(label))
  label, online = V.Relationship({ kind = "bnet", key = "bn:77" })
  check("a battle.net friend, online", label == "ECHO_BATTLENET" and online == true, tostring(online))
  label = V.Relationship({ kind = "whisper", key = "w:Stranger-Horizon" })
  check("a stranger has no relationship", label == nil, tostring(label))
  check("channels have no relationship", V.Relationship({ kind = "party", key = "party" }) == nil, "?")
  C_FriendList = { GetFriendInfo = function() error("boom") end }
  check("a throwing API is survived", pcall(V.Relationship, { kind = "whisper", key = "w:Brisa-Horizon" }), "threw")
  C_FriendList, C_GuildInfo, C_BattleNet = savedFriends, savedGuild, savedBattleNet

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  local meta = V.CardMeta(S.Get("w:Brisa-Horizon"))
  check("card meta names the class", meta:find("Druid", 1, true) ~= nil, meta)

  local spec = V.MenuSpec(S.Get("w:Brisa-Horizon"))
  check("the menu starts with pin", spec[1].kind == "button" and spec[1].action == "pin" and spec[1].label == "ECHO_PIN", spec[1].label)
  local radios, selected = 0, nil
  for _, e in ipairs(spec) do
    if e.kind == "radio" then radios = radios + 1; if e.selected then selected = e.value end end
  end
  check("the menu offers five notification choices", radios == 5, radios)
  check("default is selected without an override", selected == "default", selected)
  check("the menu ends with close", spec[#spec].action == "close", spec[#spec].action)
  S.SetPinned("w:Brisa-Horizon", true)
  S.SetTier("w:Brisa-Horizon", "muted")
  spec = V.MenuSpec(S.Get("w:Brisa-Horizon"))
  selected = nil
  for _, e in ipairs(spec) do if e.kind == "radio" and e.selected then selected = e.value end end
  check("a pinned conversation offers unpin", spec[1].label == "ECHO_UNPIN", spec[1].label)
  check("the override is selected", selected == "muted", selected)

  E.ClearDrafts()
  E.ParkDraft("w:A-Horizon", "half a thought")
  E.ParkDraft("w:B-Horizon", "")
  check("a parked draft comes back once", E.TakeDraft("w:A-Horizon") == "half a thought" and E.TakeDraft("w:A-Horizon") == "", "?")
  check("an empty draft is not kept", E.TakeDraft("w:B-Horizon") == "", "?")
  check("no key, no draft", E.TakeDraft(nil) == "", "?")
  S.Reset()
`, 'view-card');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Expected: exit 1 with `view-card: … attempt to call a nil value (field 'StartsGroup')`.

- [ ] **Step 3: Implement in `modules/Echo/EchoView.lua`**

Append at the end of the file:

```lua
-- ---------------------------------------------------------------------------
-- The expanded card (plan 3)
-- ---------------------------------------------------------------------------

View.GROUP_GAP_SECONDS = 120

--- True when message i starts a new group: the other side, another speaker, or a pause.
-- A secret speaker can't be compared, so it always starts a group.
-- @param messages table
-- @param i number
-- @return boolean
function View.StartsGroup(messages, i)
    local cur, prev = messages[i], messages[i - 1]
    if not prev then return true end
    if (cur.outgoing and true or false) ~= (prev.outgoing and true or false) then return true end
    if not cur.outgoing then
        if Echo.IsSecret(cur.sender) or Echo.IsSecret(prev.sender) or cur.sender ~= prev.sender then
            return true
        end
    end
    if type(cur.time) == "number" and type(prev.time) == "number"
        and cur.time - prev.time > View.GROUP_GAP_SECONDS then
        return true
    end
    return false
end

--- Index of the newest outgoing message, or nil.
-- @param conv table
-- @return number|nil
function View.NewestOutgoing(conv)
    for i = #conv.messages, 1, -1 do
        if conv.messages[i].outgoing then return i end
    end
    return nil
end

--- Bubble width: fitted to readable text, the widest bubble when it couldn't be measured.
-- @param measured number|nil  the text's unwrapped width; nil for secret text
-- @param maxWidth number
-- @param pad number  inner padding on each side
-- @return number
function View.BubbleWidth(measured, maxWidth, pad)
    if type(measured) ~= "number" then return maxWidth end
    return math.min(maxWidth, math.ceil(measured) + pad * 2)
end

--- Who a conversation is with and whether they're online, where the game says.
-- @param conv table
-- @return string|nil label, boolean|nil online
function View.Relationship(conv)
    if conv.kind == "bnet" then
        local online
        local id = tonumber(conv.key:sub(4))
        local api = C_BattleNet and C_BattleNet.GetAccountInfoByID
        if id and type(api) == "function" then
            local ok, info = pcall(api, id)
            local game = ok and type(info) == "table" and info.gameAccountInfo
            if type(game) == "table" and not Echo.IsSecret(game.isOnline) then
                online = game.isOnline == true
            end
        end
        return L["ECHO_BATTLENET"], online
    elseif conv.kind == "whisper" then
        local name = conv.key:sub(3)
        local friends = C_FriendList and C_FriendList.GetFriendInfo
        if type(friends) == "function" then
            local ok, info = pcall(friends, name)
            if not ok or type(info) ~= "table" then
                ok, info = pcall(friends, name:match("^([^-]+)") or name)
            end
            if ok and type(info) == "table" then
                local online
                if not Echo.IsSecret(info.connected) then online = info.connected == true end
                return L["ECHO_FRIEND"], online
            end
        end
        local guild = C_GuildInfo and C_GuildInfo.MemberExistsByName
        if type(guild) == "function" then
            local ok, member = pcall(guild, name)
            if ok and member == true then return L["ECHO_GUILDMATE"], nil end
        end
    end
    return nil, nil
end

--- The card header's detail line: class, relationship and online status, readable parts only.
-- @param conv table
-- @return string
function View.CardMeta(conv)
    local parts = {}
    local class = View.LastClass(conv)
    if class and not Echo.IsSecret(class) then
        local names = LOCALIZED_CLASS_NAMES_MALE
        parts[#parts + 1] = (names and names[class]) or class
    end
    local relationship, online = View.Relationship(conv)
    if relationship then parts[#parts + 1] = relationship end
    if online ~= nil then parts[#parts + 1] = online and L["ECHO_ONLINE"] or L["ECHO_OFFLINE"] end
    return table.concat(parts, " · ")
end

--- The words under your newest message.
-- @param status string|nil  "pending" | "sent" | "failed"
-- @return string
function View.StatusText(status)
    if status == "pending" then return L["ECHO_STATUS_PENDING"] end
    if status == "sent" then return L["ECHO_STATUS_SENT"] end
    if status == "failed" then return L["ECHO_STATUS_FAILED"] end
    return ""
end

View.TIER_CHOICES = { "default", "loud", "count", "quiet", "muted" }

--- The ⋯ menu for a conversation, as data (EchoMenu builds the real menu from it).
-- @param conv table
-- @return table entries
function View.MenuSpec(conv)
    local override = Echo.Store.OverrideOf(conv.key) or "default"
    local defaultTier = Echo.Store.DEFAULT_TIERS[conv.kind] or "quiet"
    local entries = {
        { kind = "button", label = conv.pinned and L["ECHO_UNPIN"] or L["ECHO_PIN"], action = "pin" },
        { kind = "divider" },
        { kind = "title", label = L["ECHO_NOTIFICATIONS"] },
    }
    for _, value in ipairs(View.TIER_CHOICES) do
        local label
        if value == "default" then
            label = L["ECHO_TIER_DEFAULT"]:format(L["ECHO_TIER_" .. defaultTier:upper()])
        else
            label = L["ECHO_TIER_" .. value:upper()]
        end
        entries[#entries + 1] = { kind = "radio", label = label, action = "tier", value = value,
                                  selected = (value == override) }
    end
    entries[#entries + 1] = { kind = "divider" }
    entries[#entries + 1] = { kind = "button", label = L["ECHO_CLOSE_CONVERSATION"], action = "close" }
    return entries
end

-- Unsent replies per conversation, shared by the stack and the card.
Echo.Drafts = Echo.Drafts or {}

--- Keep a conversation's unsent reply while its box shows something else.
-- @param convKey string|nil
-- @param text string|nil
function Echo.ParkDraft(convKey, text)
    if not convKey then return end
    Echo.Drafts[convKey] = (type(text) == "string" and text ~= "") and text or nil
end

--- Take a conversation's parked reply back.
-- @param convKey string|nil
-- @return string  "" when there is none
function Echo.TakeDraft(convKey)
    if not convKey then return "" end
    local text = Echo.Drafts[convKey]
    Echo.Drafts[convKey] = nil
    return text or ""
end

function Echo.ClearDrafts()
    Echo.Drafts = {}
end
```

- [ ] **Step 4: Strings**

Append to the end of `locales/horizon/enUS.lua`:

```lua
-- Echo — expanded card and menu
L["ECHO_PIN"]                                                 = "Pin"
L["ECHO_UNPIN"]                                               = "Unpin"
L["ECHO_NOTIFICATIONS"]                                       = "Notifications"
L["ECHO_TIER_DEFAULT"]                                        = "Default (%s)"
L["ECHO_TIER_LOUD"]                                           = "Loud"
L["ECHO_TIER_COUNT"]                                          = "Count"
L["ECHO_TIER_QUIET"]                                          = "Quiet"
L["ECHO_TIER_MUTED"]                                          = "Muted"
L["ECHO_CLOSE_CONVERSATION"]                                  = "Close conversation"
L["ECHO_FRIEND"]                                              = "Friend"
L["ECHO_GUILDMATE"]                                           = "Guildmate"
L["ECHO_ONLINE"]                                              = "Online"
L["ECHO_OFFLINE"]                                             = "Offline"
L["ECHO_STATUS_PENDING"]                                      = "Sending…"
L["ECHO_STATUS_SENT"]                                         = "Sent"
L["ECHO_STATUS_FAILED"]                                       = "Not delivered"
L["ECHO_RETRY"]                                               = "Retry"
L["ECHO_WHISPER_TO"]                                          = "Whisper %s…"
L["ECHO_REPLY"]                                               = "Reply…"
```

- [ ] **Step 5: Run the tests and parse-check**

Expected: `426 passed, 0 failed`. `EchoView.lua` and `enUS.lua` both parse.

- [ ] **Step 6: Commit**

```bash
git add modules/Echo/EchoView.lua locales/horizon/enUS.lua tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): add view helpers, menu data and shared drafts for the card" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 3: Links into Echo boxes, and drafts shared by the stack

**Files:**
- Create: `modules/Echo/EchoLinks.lua`
- Modify: `modules/Echo/EchoStack.lua` (use shared drafts; tell Links about focus)
- Modify: `HorizonSuite.toc` (`modules/Echo/EchoLinks.lua` after `modules/Echo/EchoView.lua`)
- Test: `tools/test_echo_logic.js` (add `EchoLinks.lua` to `FILES` after `EchoView.lua`; new section)

**Interfaces:**
- Produces:
  - `Links.Focus(box)`, `Links.Blur(box)`.
  - `Links.Insert(text) -> boolean`.
  - `Links.Hook()`, which hooks at most one function and sets `Links.hooked`.
- Consumes: `Echo.ParkDraft`, `Echo.TakeDraft` and `Echo.ClearDrafts` (Task 2).
- Stack behaviour change: `Stack.Hide` parks the box's text for the conversation shown and empties the box, so the card, or the stack when it reopens, can take the draft.

- [ ] **Step 1: Write the failing tests**

Add `'modules/Echo/EchoLinks.lua',` to `FILES` after `'modules/Echo/EchoView.lua',`. Insert before `// --- Summary`:

```js
// --- Links: shift-click into the focused Echo box; drafts move between views -----------
run(`
  local Links, S, T, K = HorizonSuite.Echo.Links, HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles, HorizonSuite.Echo.Stack
  local savedHook, savedUtil, savedLegacy = hooksecurefunc, ChatFrameUtil, ChatEdit_InsertLink
  local hooks = {}
  hooksecurefunc = function(a, b, c)
    if type(a) == "table" then hooks[#hooks + 1] = { target = a, name = b, fn = c }
    else hooks[#hooks + 1] = { name = a, fn = b } end
  end
  ChatFrameUtil = { InsertLink = function() end }
  ChatEdit_InsertLink = function() end
  Links.hooked = nil
  Links.Hook()
  Links.Hook()
  check("one insertion function is hooked, once", #hooks == 1 and hooks[1].name == "InsertLink" and hooks[1].target == ChatFrameUtil, #hooks)

  local box = { text = "", focused = true }
  function box:Insert(t) self.text = self.text .. t end
  function box:HasFocus() return self.focused end
  local link = "|cffa335ee|Hitem:1::|h[Cloak]|h|r"
  hooks[1].fn(link)
  check("without a focused Echo box nothing is inserted", box.text == "", box.text)
  Links.Focus(box)
  hooks[1].fn(link)
  check("a shift-clicked link goes into the focused Echo box", box.text == link, box.text)
  box.focused = false
  hooks[1].fn(link)
  check("a box that lost focus without telling us gets nothing", box.text == link, box.text)
  box.focused = true
  Links.Focus(box)
  Links.Blur(box)
  hooks[1].fn(link)
  check("after blur nothing is inserted", box.text == link, box.text)
  check("empty or non-string links are ignored", Links.Insert("") == false and Links.Insert(nil) == false, "?")

  hooks = {}
  ChatFrameUtil = nil
  Links.hooked = nil
  Links.Hook()
  check("older clients hook ChatEdit_InsertLink", #hooks == 1 and hooks[1].name == "ChatEdit_InsertLink", #hooks)
  Links.hooked = nil
  hooksecurefunc, ChatFrameUtil, ChatEdit_InsertLink = savedHook, savedUtil, savedLegacy

  -- The stack parks its draft on hide, so another view can pick it up.
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  local f = K._frames()
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon" })
  K.Open("w:Brisa-Horizon")
  f.edit:SetText("half a reply")
  K.Hide()
  check("hiding the stack empties its box", f.edit.text == "", f.edit.text)
  check("hiding the stack parks the draft", HorizonSuite.Echo.TakeDraft("w:Brisa-Horizon") == "half a reply", "lost")
  f.edit.HasFocus = function() return true end
  f.edit.scripts.OnEditFocusGained(f.edit)
  local inserted = Links.Insert("L")
  check("the stack's box tells Links when it has focus", inserted, "not focused")
  f.edit.scripts.OnEditFocusLost(f.edit)
  check("and when it loses it", Links.Insert("L") == false, "still focused")
  f.edit.HasFocus = nil
  K.Disable()
  T.Disable()
  S.Reset()
`, 'links');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Expected: exit 1 with `ENOENT` for `modules/Echo/EchoLinks.lua`.

- [ ] **Step 3: Create `modules/Echo/EchoLinks.lua`**

```lua
--[[
    Horizon Suite - Echo - Links
    Shift-clicking an item, spell or achievement while an Echo reply box has focus puts the
    link into that box. The game's own link insertion is post-hooked (hooksecurefunc), so
    nothing of Blizzard's is replaced or tainted. Exactly one function is hooked, so a
    wrapper that calls the other can never insert a link twice.
    Blizzard: ChatFrameUtil.InsertLink (modern) or ChatEdit_InsertLink (older), hooksecurefunc.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Links = {}
Echo.Links = Links

local focused  -- the Echo reply box with keyboard focus, if any

--- An Echo reply box gained focus.
-- @param box EditBox
function Links.Focus(box)
    focused = box
end

--- An Echo reply box lost focus.
-- @param box EditBox
function Links.Blur(box)
    if focused == box then focused = nil end
end

--- Put a link into the focused Echo box.
-- @param text string
-- @return boolean inserted
function Links.Insert(text)
    if not focused or type(text) ~= "string" or text == "" then return false end
    if focused.HasFocus and not focused:HasFocus() then
        focused = nil
        return false
    end
    focused:Insert(text)
    return true
end

--- Hook the game's link insertion, once.
function Links.Hook()
    if Links.hooked or type(hooksecurefunc) ~= "function" then return end
    if ChatFrameUtil and type(ChatFrameUtil.InsertLink) == "function" then
        hooksecurefunc(ChatFrameUtil, "InsertLink", function(text) Links.Insert(text) end)
        Links.hooked = true
    elseif type(ChatEdit_InsertLink) == "function" then
        hooksecurefunc("ChatEdit_InsertLink", function(text) Links.Insert(text) end)
        Links.hooked = true
    end
end
```

- [ ] **Step 4: Shared drafts and link focus in `modules/Echo/EchoStack.lua`**

1. Delete the line `local drafts = {}           -- unsent reply text per conversation, while another card is on top`.
2. In `Stack.Render`, replace:

```lua
        if renderedKey then
            local text = edit:GetText()
            drafts[renderedKey] = (text ~= "") and text or nil
        end
        edit:SetText(drafts[conv.key] or "")
        drafts[conv.key] = nil
```

with:

```lua
        if renderedKey then Echo.ParkDraft(renderedKey, edit:GetText()) end
        edit:SetText(Echo.TakeDraft(conv.key))
```

3. In `CreateEdit`, change the two focus scripts to also tell Links:

```lua
    edit:SetScript("OnEditFocusGained", function(self)
        self.placeholder:Hide()
        if Echo.Links then Echo.Links.Focus(self) end
    end)
    edit:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then self.placeholder:Show() end
        if Echo.Links then Echo.Links.Blur(self) end
        Stack.HoverLeave()
    end)
```

4. In `Stack.Hide`, directly before `if edit then edit:ClearFocus() end`, add:

```lua
    -- Park the draft so the card, or the stack when it reopens, can take it back.
    if edit and renderedKey then
        Echo.ParkDraft(renderedKey, edit:GetText())
        edit:SetText("")
        renderedKey = nil
    end
```

5. In `Stack.Disable`, replace `drafts = {}` with `Echo.ClearDrafts()`.

- [ ] **Step 5: TOC, then run the tests and parse-check**

Add `modules/Echo/EchoLinks.lua` to `HorizonSuite.toc` after `modules/Echo/EchoView.lua`.

Expected: `437 passed, 0 failed`, and every existing stack draft test still passes. `EchoLinks.lua` and `EchoStack.lua` both parse.

- [ ] **Step 6: Commit**

```bash
git add modules/Echo/EchoLinks.lua modules/Echo/EchoStack.lua HorizonSuite.toc tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): put shift-clicked links into Echo boxes and share drafts" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: The ⋯ menu

**Files:**
- Create: `modules/Echo/EchoMenu.lua`
- Modify: `HorizonSuite.toc` (`modules/Echo/EchoMenu.lua` after `modules/Echo/EchoStack.lua`)
- Test: `tools/test_echo_logic.js` (add `EchoMenu.lua` to `FILES` after `EchoStack.lua`; new section)

**Interfaces:**
- Consumes: `View.MenuSpec`, `Store.Get`, `Store.SetPinned`, `Store.SetTier`, `Store.Close`, `Store.OverrideOf`.
- Produces:
  - `Menu.Run(convKey, action, value)`.
  - `Menu.Build(rootDescription, convKey)`, which uses `CreateButton(label, fn)`, `CreateTitle(label)`, `CreateDivider()` and `CreateRadio(label, isSelected, setSelected)`.
  - `Menu.Open(owner, convKey) -> boolean`.

- [ ] **Step 1: Write the failing tests**

Add `'modules/Echo/EchoMenu.lua',` to `FILES` after `'modules/Echo/EchoStack.lua',`. Insert before `// --- Summary`:

```js
// --- Menu: the ⋯ menu's contents and actions ---------------------------------------------
run(`
  local S, M = HorizonSuite.Echo.Store, HorizonSuite.Echo.Menu
  S.Reset()
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi" })

  local calls = {}
  local rootDescription = {}
  function rootDescription:CreateButton(label, fn) calls[#calls + 1] = { "button", label, fn } end
  function rootDescription:CreateTitle(label) calls[#calls + 1] = { "title", label } end
  function rootDescription:CreateDivider() calls[#calls + 1] = { "divider" } end
  function rootDescription:CreateRadio(label, isSelected, setSelected) calls[#calls + 1] = { "radio", label, isSelected, setSelected } end
  M.Build(rootDescription, "w:Brisa-Horizon")
  check("the menu has pin, a title, five choices and close", #calls == 10 and calls[1][1] == "button" and calls[4][1] == "radio" and calls[10][1] == "button", #calls)

  calls[1][3]()
  check("pin pins", S.Get("w:Brisa-Horizon").pinned == true, "?")
  M.Run("w:Brisa-Horizon", "pin")
  check("pin again unpins", S.Get("w:Brisa-Horizon").pinned == false, "?")

  local muted = calls[8]
  check("the muted choice is not selected yet", muted[3]() == false, "?")
  muted[4]()
  check("choosing muted mutes", S.TierOf("w:Brisa-Horizon") == "muted" and muted[3]() == true, S.TierOf("w:Brisa-Horizon"))
  calls[4][4]()
  check("choosing default clears the override", S.OverrideOf("w:Brisa-Horizon") == nil and calls[4][3]() == true, S.OverrideOf("w:Brisa-Horizon"))

  calls[10][3]()
  check("close closes the conversation", not S.Get("w:Brisa-Horizon").open, "still open")

  calls = {}
  M.Build(rootDescription, "w:Nobody-Horizon")
  check("no menu for an unknown conversation", #calls == 0, #calls)

  local savedMenuUtil = MenuUtil
  MenuUtil = nil
  check("without MenuUtil the menu does not open", M.Open({}, "w:Brisa-Horizon") == false, "?")
  local opened
  MenuUtil = { CreateContextMenu = function(owner, generator) opened = { owner, generator } end }
  check("with MenuUtil it opens", M.Open("owner", "w:Brisa-Horizon") == true and opened[1] == "owner" and type(opened[2]) == "function", "?")
  MenuUtil = savedMenuUtil
  S.Reset()
`, 'menu');
```

The call order is: pin, divider, title, radio default, loud, count, quiet, muted, divider, close. So index 4 is Default, index 8 is Muted and index 10 is Close.

- [ ] **Step 2: Run the tests and confirm they fail**

Expected: exit 1 with `ENOENT` for `modules/Echo/EchoMenu.lua`.

- [ ] **Step 3: Create `modules/Echo/EchoMenu.lua`**

```lua
--[[
    Horizon Suite - Echo - Menu
    The ⋯ menu on the card: pin, notification tier, close conversation. Its contents come
    from View.MenuSpec; this file turns them into Blizzard's context menu and runs the choice.
    Blizzard: MenuUtil.CreateContextMenu.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Menu = {}
Echo.Menu = Menu

--- Carry out one menu choice.
-- @param convKey string
-- @param action string  "pin" | "tier" | "close"
-- @param value string|nil  the tier for "tier" ("default" clears the override)
function Menu.Run(convKey, action, value)
    local Store = Echo.Store
    if action == "pin" then
        local conv = Store.Get(convKey)
        if conv then Store.SetPinned(convKey, not conv.pinned) end
    elseif action == "tier" then
        Store.SetTier(convKey, (value ~= "default") and value or nil)
    elseif action == "close" then
        Store.Close(convKey)
    end
end

--- Fill a MenuUtil root description for a conversation.
-- @param rootDescription table
-- @param convKey string
function Menu.Build(rootDescription, convKey)
    local conv = Echo.Store.Get(convKey)
    if not conv then return end
    for _, entry in ipairs(Echo.View.MenuSpec(conv)) do
        if entry.kind == "button" then
            local action = entry.action
            rootDescription:CreateButton(entry.label, function() Menu.Run(convKey, action) end)
        elseif entry.kind == "title" then
            rootDescription:CreateTitle(entry.label)
        elseif entry.kind == "divider" then
            rootDescription:CreateDivider()
        elseif entry.kind == "radio" then
            local value = entry.value
            rootDescription:CreateRadio(entry.label,
                function() return (Echo.Store.OverrideOf(convKey) or "default") == value end,
                function() Menu.Run(convKey, "tier", value) end)
        end
    end
end

--- Open the menu for a conversation from a button.
-- @param owner Frame
-- @param convKey string
-- @return boolean opened
function Menu.Open(owner, convKey)
    if not (MenuUtil and type(MenuUtil.CreateContextMenu) == "function") then return false end
    MenuUtil.CreateContextMenu(owner, function(_, rootDescription) Menu.Build(rootDescription, convKey) end)
    return true
end
```

- [ ] **Step 4: TOC, then run the tests and parse-check**

Add `modules/Echo/EchoMenu.lua` to `HorizonSuite.toc` after `modules/Echo/EchoStack.lua`.

Expected: `447 passed, 0 failed`. `EchoMenu.lua` parses.

- [ ] **Step 5: Commit**

```bash
git add modules/Echo/EchoMenu.lua HorizonSuite.toc tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): add the conversation menu for pin, tier and close" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 5: The expanded card

**Files:**
- Create: `modules/Echo/EchoCard.lua`
- Modify: `HorizonSuite.toc` (`modules/Echo/EchoCard.lua` after `modules/Echo/EchoMenu.lua`)
- Test: `tools/test_echo_logic.js` (add `EchoCard.lua` to `FILES` after `EchoMenu.lua`; new section)

**Interfaces:**
- Consumes:
  - `Echo.View`: `TileSpec`, `DisplayName`, `CardMeta`, `StartsGroup`, `NewestOutgoing`, `BubbleWidth`, `StatusText`, `ChatColor`, `ClassColor` and the colour constants.
  - `Echo.ParkDraft` and `Echo.TakeDraft`.
  - `Echo.Store`: `List`, `Get`, `MarkRead`, `Subscribe` and `Unsubscribe`.
  - `Echo.Send.Send`, `Echo.Menu.Open`, `Echo.Links`, `Echo.NewText`, `Echo.FLAT`, `Echo.Stack.Hide`, and the global `HorizonSuiteEchoColumn`.
- Produces:
  - Opening and closing: `Card.Open(convKey|nil, focus|nil)`, `Card.Show(convKey)`, `Card.Hide()`, `Card.IsShown() -> boolean`.
  - Actions: `Card.Scroll(delta)`, `Card.Submit()`, `Card.Retry(msg)`.
  - Drawing and lifecycle: `Card.Render()`, `Card.OnStoreChange`, `Card.Enable()`, `Card.Disable()`.
  - Test handle `Card._frames() -> { root, rowTiles, name, meta, area, edit, send, menu, chevron, bubbles, labels, status }`.
- Layout constants: `Card.WIDTH` 360, `Card.HEIGHT` 440, `Card.AREA_HEIGHT` 296, `Card.TILES` 8, `Card.TILE` 26, `Card.PAD` 12, `Card.BUBBLE_PAD` 8, `Card.BUBBLE_MAX` 250, `Card.GAP` 3, `Card.GROUP_GAP` 10, `Card.SECRET_LINES` 3, `Card.LINE_HEIGHT` 14.

- [ ] **Step 1: Write the failing smoke tests**

Add `'modules/Echo/EchoCard.lua',` to `FILES` after `'modules/Echo/EchoMenu.lua',`. Insert before `// --- Summary`:

```js
// --- Card: smoke test with stand-in frames ---------------------------------------------
run(`
  local S, T, K, C = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles, HorizonSuite.Echo.Stack, HorizonSuite.Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  local sent = {}
  C_ChatInfo = { SendChatMessage = function(msg, chatType, _, target) sent[#sent + 1] = chatType .. ":" .. tostring(target) .. ":" .. msg end }
  T.Enable()
  K.Enable()
  C.Enable()
  local f = C._frames()
  check("the card starts hidden", not f.root:IsShown(), "shown")
  check("escape can close the card", (function()
    for _, n in ipairs(UISpecialFrames) do if n == "HorizonSuiteEchoCard" then return true end end
    return false end)(), "not registered")
  C.Open(nil)
  check("with no conversations the card stays shut", not f.root:IsShown(), "shown")

  S.Add({ convKey = "w:Brisa-Horizon", text = "got the leather", class = "DRUID", sender = "Brisa-Horizon" })
  S.Add({ convKey = "w:Brisa-Horizon", text = "can you craft the cloak?", class = "DRUID", sender = "Brisa-Horizon" })
  S.Add({ convKey = "w:Vexa-Horizon", text = "gz", sender = "Vexa-Horizon" })
  C.Open("w:Brisa-Horizon")
  check("open shows the card", f.root:IsShown(), "hidden")
  check("the card shows the chosen conversation", f.name.text == "Brisa", f.name.text)
  check("the meta line names the class", f.meta.text:find("DRUID", 1, true) ~= nil, f.meta.text)
  check("opening marks it read", S.Get("w:Brisa-Horizon").unread == 0, S.Get("w:Brisa-Horizon").unread)
  check("the newest message is the bottom bubble", f.bubbles[1].text.text == "can you craft the cloak?" and f.bubbles[1].shown, f.bubbles[1].text.text)
  check("their bubble sits on the left", f.bubbles[1].points[1][1] == "BOTTOMLEFT", f.bubbles[1].points[1][1])
  check("the older message sits above it", f.bubbles[2].text.text == "got the leather" and f.bubbles[2].points[1][5] > f.bubbles[1].points[1][5], "?")
  check("the tile row shows both conversations", f.rowTiles[1].shown and f.rowTiles[2].shown and not f.rowTiles[3].shown, "?")

  f.edit:SetText("sure, mail them")
  f.edit.scripts.OnEnterPressed(f.edit)
  check("enter sends to the card's conversation", sent[1] == "WHISPER:Brisa-Horizon:sure, mail them", sent[1])
  check("the box empties after sending", f.edit.text == "", f.edit.text)
  check("your bubble sits on the right", f.bubbles[1].text.text == "sure, mail them" and f.bubbles[1].points[1][1] == "BOTTOMRIGHT", f.bubbles[1].points[1][1])
  check("the status line shows under your newest message", f.status.shown and f.status.text.text == "ECHO_STATUS_PENDING", f.status.text.text)
  check("the card stays on the conversation after it moves up the list", f.name.text == "Brisa", f.name.text)

  S.MarkFailed("w:Brisa-Horizon")
  check("a failed message offers retry", f.status.retry ~= nil and f.status.text.text:find("ECHO_RETRY", 1, true) ~= nil, f.status.text.text)
  f.status.scripts.OnClick(f.status)
  check("retry sends again", sent[2] == "WHISPER:Brisa-Horizon:sure, mail them", sent[2])

  f.edit:SetText("")
  f.edit.scripts.OnEnterPressed(f.edit)
  check("enter on an empty box only leaves it", f.edit.focused == false and #sent == 2, #sent)

  f.edit:SetText("draft for brisa")
  local vexaTile
  for _, b in ipairs(f.rowTiles) do if b.convKey == "w:Vexa-Horizon" then vexaTile = b end end
  vexaTile.scripts.OnClick(vexaTile)
  check("a row tile switches the card", f.name.text == "Vexa", f.name.text)
  check("the other conversation starts with an empty box", f.edit.text == "", f.edit.text)
  C.Show("w:Brisa-Horizon")
  check("the draft comes back with its conversation", f.edit.text == "draft for brisa", f.edit.text)

  for i = 1, 20 do S.Add({ convKey = "w:Brisa-Horizon", text = "line " .. i, sender = "Brisa-Horizon" }) end
  check("new messages show at the bottom", f.bubbles[1].text.text == "line 20", f.bubbles[1].text.text)
  C.Scroll(5)
  check("the wheel scrolls back by message", f.bubbles[1].text.text == "line 15", f.bubbles[1].text.text)
  C.Scroll(-100)
  check("scrolling stops at the newest", f.bubbles[1].text.text == "line 20", f.bubbles[1].text.text)

  S.Add({ convKey = "w:Brisa-Horizon", text = SECRET("mid-pull"), secret = true, sender = "Brisa-Horizon" })
  check("a secret message gets a bubble with the secret as its only text", f.bubbles[1].shown and rawequal(f.bubbles[1].text.text, S.Get("w:Brisa-Horizon").messages[#S.Get("w:Brisa-Horizon").messages].text), "joined")

  S.Add({ convKey = "party", text = "pull", sender = "Tank-Horizon", class = "WARRIOR" })
  S.Add({ convKey = "party", text = "now", sender = "Tank-Horizon", class = "WARRIOR" })
  S.Add({ convKey = "party", text = "heal pls", sender = "Priest-Horizon" })
  C.Show("party")
  check("a group card names each speaker once per group", f.labels[1].shown and f.labels[1].text == "Priest" and f.labels[2].shown and f.labels[2].text == "Tank" and not (rawget(f.labels, 3) and f.labels[3].shown), f.labels[1].text)

  f.chevron.scripts.OnClick(f.chevron)
  check("the chevron collapses the card", not f.root:IsShown(), "shown")

  K.Open("w:Brisa-Horizon")
  C.Open("w:Vexa-Horizon")
  check("opening the card closes the stack", f.root:IsShown() and not K._frames().root:IsShown(), "both")

  S.Close("w:Vexa-Horizon")
  check("closing the card's conversation moves to another", f.root:IsShown() and f.name.text ~= "Vexa", f.name.text)

  C.Disable()
  K.Disable()
  T.Disable()
  check("a disabled card ignores new messages", pcall(S.Add, { convKey = "w:Late-Horizon", text = "x" }), "threw")
  C_ChatInfo = nil
  S.Reset()
`, 'card');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Expected: exit 1 with `ENOENT` for `modules/Echo/EchoCard.lua`.

- [ ] **Step 3: Create `modules/Echo/EchoCard.lua`**

```lua
--[[
    Horizon Suite - Echo - Card
    The expanded card: one conversation in full. A row of tiles for the open conversations
    across the top (the current one outlined), the ⋯ menu and a collapse chevron; the name
    with class, relationship and online status; message bubbles, theirs on the left and
    yours on the right; a status line under your newest message; and a reply box with a
    send button. Opened by clicking a tile, a toast, or the stack's Open button.
    Bubbles are laid out newest-first from the bottom of a clipped area and the wheel
    scrolls by message. Readable text is measured; a secret gets the widest bubble and a
    fixed three lines, so nothing ever reads a size from a FontString holding a secret.
    Blizzard: CreateFrame, UISpecialFrames, MenuUtil (through Echo.Menu).
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo
local L = addon.L

local Card = {}
Echo.Card = Card

Card.WIDTH = 360
Card.HEIGHT = 440
Card.AREA_TOP = 92        -- message area starts this far below the top
Card.AREA_BOTTOM = 52     -- and stops this far above the bottom
Card.AREA_HEIGHT = Card.HEIGHT - Card.AREA_TOP - Card.AREA_BOTTOM
Card.TILES = 8
Card.TILE = 26
Card.PAD = 12
Card.BUBBLE_PAD = 8
Card.BUBBLE_MAX = 250
Card.GAP = 3
Card.GROUP_GAP = 10
Card.SECRET_LINES = 3
Card.LINE_HEIGHT = 14

local root, nameText, metaText, area, edit, send, menuButton, chevron, statusLine
local rowTiles, bubbles, labels = {}, {}, {}
local currentKey, renderedKey
local offset = 0  -- newest messages scrolled past

local function FontPath()
    return (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"
end

local function Paint(frame, bg, border)
    frame:SetBackdrop(Echo.FLAT)
    frame:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
    frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
end

-- A flat glyph drawn from thin bars; returns them so hover can tint them.
local function Glyph(button, parts)
    button.bars = {}
    for i, part in ipairs(parts) do
        local bar = button:CreateTexture(nil, "ARTWORK")
        bar:SetSize(part.w, part.h)
        bar:SetPoint("CENTER", button, "CENTER", part.x or 0, part.y or 0)
        bar:SetColorTexture(0.55, 0.60, 0.75, 1)
        if part.angle then bar:SetRotation(part.angle) end
        button.bars[i] = bar
    end
    local function Tint(r, g, b)
        for _, bar in ipairs(button.bars) do bar:SetColorTexture(r, g, b, 1) end
    end
    button:SetScript("OnEnter", function() Tint(0.95, 0.96, 1) end)
    button:SetScript("OnLeave", function() Tint(0.55, 0.60, 0.75) end)
end

local function PaintTile(b, spec)
    local View = Echo.View
    b.letter:SetText(spec.letter)
    if spec.glyph then
        local bg = View.GLYPH_BG
        b:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
        b.letter:SetTextColor(spec.r, spec.g, spec.b, 1)
    else
        b:SetBackdropColor(spec.r, spec.g, spec.b, 0.95)
        b.letter:SetTextColor(0.05, 0.05, 0.07, 1)
    end
end

local function Create()
    local View = Echo.View
    local a = View.ACCENT
    root = CreateFrame("Frame", "HorizonSuiteEchoCard", UIParent, "BackdropTemplate")
    root:SetSize(Card.WIDTH, Card.HEIGHT)
    root:SetClampedToScreen(true)
    root:EnableMouse(true)
    root:Hide()
    Paint(root, View.PANEL_BG, View.PANEL_BORDER)
    table.insert(UISpecialFrames, "HorizonSuiteEchoCard")
    root:SetScript("OnHide", function()
        if edit then edit:ClearFocus() end
    end)

    local rule = root:CreateTexture(nil, "OVERLAY")
    rule:SetColorTexture(a.r, a.g, a.b, 1)
    rule:SetHeight(2)
    rule:SetPoint("TOPLEFT", root, "TOPLEFT", 0, 0)
    rule:SetPoint("TOPRIGHT", root, "TOPRIGHT", 0, 0)

    chevron = CreateFrame("Button", nil, root)
    chevron:SetSize(22, 22)
    chevron:SetPoint("TOPRIGHT", root, "TOPRIGHT", -8, -12)
    Glyph(chevron, {
        { w = 8, h = 2, x = -3, y = 1, angle = -math.pi / 4 },
        { w = 8, h = 2, x = 3, y = 1, angle = math.pi / 4 },
    })
    chevron:SetScript("OnClick", function() Card.Hide() end)

    menuButton = CreateFrame("Button", nil, root)
    menuButton:SetSize(22, 22)
    menuButton:SetPoint("RIGHT", chevron, "LEFT", -4, 0)
    Glyph(menuButton, {
        { w = 3, h = 3, x = -5 },
        { w = 3, h = 3, x = 0 },
        { w = 3, h = 3, x = 5 },
    })
    menuButton:SetScript("OnClick", function(self)
        if currentKey and Echo.Menu then Echo.Menu.Open(self, currentKey) end
    end)

    for i = 1, Card.TILES do
        local b = CreateFrame("Button", nil, root, "BackdropTemplate")
        b:SetSize(Card.TILE, Card.TILE)
        b:SetPoint("TOPLEFT", root, "TOPLEFT", Card.PAD + (i - 1) * (Card.TILE + 6), -10)
        b:SetBackdrop(Echo.FLAT)
        b.letter = Echo.NewText(b, 12, "")
        b.letter:SetPoint("CENTER", b, "CENTER", 0, 0)
        b.dot = b:CreateTexture(nil, "OVERLAY")
        b.dot:SetSize(6, 6)
        b.dot:SetPoint("TOPRIGHT", b, "TOPRIGHT", 2, 2)
        b.dot:SetColorTexture(a.r, a.g, a.b, 1)
        b:RegisterForClicks("LeftButtonUp")
        b:SetScript("OnClick", function(self)
            if self.convKey then Card.Show(self.convKey) end
        end)
        b:Hide()
        rowTiles[i] = b
    end

    local divider = root:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(View.PANEL_BORDER[1], View.PANEL_BORDER[2], View.PANEL_BORDER[3], View.PANEL_BORDER[4])
    divider:SetHeight(1)
    divider:SetPoint("TOPLEFT", root, "TOPLEFT", Card.PAD, -44)
    divider:SetPoint("TOPRIGHT", root, "TOPRIGHT", -Card.PAD, -44)

    nameText = Echo.NewText(root, 15)
    nameText:SetPoint("TOPLEFT", root, "TOPLEFT", Card.PAD, -54)
    nameText:SetPoint("RIGHT", root, "RIGHT", -Card.PAD, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    metaText = Echo.NewText(root, 10, "")
    metaText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -4)
    metaText:SetTextColor(0.55, 0.60, 0.75, 1)

    area = CreateFrame("Frame", nil, root)
    area:SetPoint("TOPLEFT", root, "TOPLEFT", Card.PAD, -Card.AREA_TOP)
    area:SetPoint("BOTTOMRIGHT", root, "BOTTOMRIGHT", -Card.PAD, Card.AREA_BOTTOM)
    area:SetClipsChildren(true)
    area:EnableMouseWheel(true)
    area:SetScript("OnMouseWheel", function(_, delta) Card.Scroll(delta) end)

    statusLine = CreateFrame("Button", nil, area)
    statusLine:SetSize(180, 14)
    statusLine.text = Echo.NewText(statusLine, 10, "")
    statusLine.text:SetPoint("RIGHT", statusLine, "RIGHT", 0, 0)
    statusLine:RegisterForClicks("LeftButtonUp")
    statusLine:SetScript("OnClick", function(self)
        if self.retry then Card.Retry(self.retry) end
    end)
    statusLine:Hide()

    send = CreateFrame("Button", nil, root, "BackdropTemplate")
    send:SetSize(30, 30)
    send:SetPoint("BOTTOMRIGHT", root, "BOTTOMRIGHT", -Card.PAD, 12)
    Paint(send, { a.r, a.g, a.b, 0.9 }, { a.r, a.g, a.b, 1 })
    send.text = Echo.NewText(send, 14, "")
    send.text:SetPoint("CENTER", send, "CENTER", 1, 0)
    send.text:SetText(">")
    send.text:SetTextColor(0.05, 0.05, 0.07, 1)
    send:RegisterForClicks("LeftButtonUp")
    send:SetScript("OnClick", function() Card.Submit() end)

    edit = CreateFrame("EditBox", nil, root, "BackdropTemplate")
    edit:SetHeight(30)
    edit:SetPoint("BOTTOMLEFT", root, "BOTTOMLEFT", Card.PAD, 12)
    edit:SetPoint("BOTTOMRIGHT", send, "BOTTOMLEFT", -6, 0)
    Paint(edit, { 0.03, 0.03, 0.05, 0.95 }, View.PANEL_BORDER)
    edit:SetFont(FontPath(), 12, "")
    edit:SetTextInsets(8, 8, 0, 0)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(1020)
    edit.placeholder = Echo.NewText(edit, 12, "")
    edit.placeholder:SetPoint("LEFT", edit, "LEFT", 8, 0)
    edit.placeholder:SetTextColor(0.5, 0.52, 0.6, 1)
    edit:SetScript("OnEnterPressed", function(self)
        if self:GetText() == "" then
            self:ClearFocus()
        else
            Card.Submit()
        end
    end)
    edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    edit:SetScript("OnEditFocusGained", function(self)
        self.placeholder:Hide()
        if Echo.Links then Echo.Links.Focus(self) end
    end)
    edit:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then self.placeholder:Show() end
        if Echo.Links then Echo.Links.Blur(self) end
    end)
    edit:SetScript("OnTextChanged", function(self)
        if self:GetText() ~= "" then
            self.placeholder:Hide()
        elseif not self:HasFocus() then
            self.placeholder:Show()
        end
    end)
end

local function Bubble(i)
    local b = bubbles[i]
    if b then return b end
    b = CreateFrame("Frame", nil, area, "BackdropTemplate")
    b:SetBackdrop(Echo.FLAT)
    b.text = Echo.NewText(b, 12, "")
    b.text:SetPoint("TOPLEFT", b, "TOPLEFT", Card.BUBBLE_PAD, -Card.BUBBLE_PAD)
    b.text:SetJustifyH("LEFT")
    b.text:SetJustifyV("TOP")
    b.text:SetWordWrap(true)
    bubbles[i] = b
    return b
end

local function Label(i)
    local fs = labels[i]
    if fs then return fs end
    fs = Echo.NewText(area, 10)
    fs:SetJustifyH("LEFT")
    labels[i] = fs
    return fs
end

-- Size a bubble to its text and return its height. Readable text is measured; a secret
-- can't be, so it gets the widest bubble and a fixed number of lines.
local function SizeBubble(b, text, secret)
    local inner = Card.BUBBLE_MAX - Card.BUBBLE_PAD * 2
    b.text:SetWidth(inner)
    b.text:SetMaxLines(secret and Card.SECRET_LINES or 0)
    b.text:SetText(text)
    local width, height
    if secret then
        width = Card.BUBBLE_MAX
        height = Card.SECRET_LINES * Card.LINE_HEIGHT
    else
        local measured
        if b.text.GetUnboundedStringWidth then measured = b.text:GetUnboundedStringWidth() end
        if Echo.IsSecret(measured) or type(measured) ~= "number" then measured = nil end
        width = Echo.View.BubbleWidth(measured, Card.BUBBLE_MAX, Card.BUBBLE_PAD)
        b.text:SetWidth(width - Card.BUBBLE_PAD * 2)
        local h = b.text:GetStringHeight()
        if Echo.IsSecret(h) or type(h) ~= "number" or h <= 0 then h = Card.LINE_HEIGHT end
        height = h
    end
    b:SetSize(width, height + Card.BUBBLE_PAD * 2)
    return height + Card.BUBBLE_PAD * 2
end

local function RenderMessages(conv)
    local View = Echo.View
    local a = View.ACCENT
    local messages = conv.messages
    local r, g, b = View.ChatColor(conv.kind)
    local isGroup = conv.kind ~= "whisper" and conv.kind ~= "bnet"
    local newestOut = View.NewestOutgoing(conv)
    offset = math.max(0, math.min(offset, #messages - 1))
    local y = 4
    local used, usedLabels = 0, 0
    statusLine.retry = nil
    statusLine:Hide()
    for i = #messages - offset, 1, -1 do
        if y > Card.AREA_HEIGHT then break end
        local msg = messages[i]
        if i == newestOut and not msg.fromHistory and (msg.status == "pending" or msg.status == "sent" or msg.status == "failed") then
            local failed = msg.status == "failed"
            statusLine.text:SetText(View.StatusText(msg.status) .. (failed and (" · " .. L["ECHO_RETRY"]) or ""))
            if failed then
                statusLine.text:SetTextColor(1, 0.4, 0.4, 1)
            else
                statusLine.text:SetTextColor(0.55, 0.60, 0.75, 1)
            end
            statusLine.retry = failed and msg or nil
            statusLine:ClearAllPoints()
            statusLine:SetPoint("BOTTOMRIGHT", area, "BOTTOMRIGHT", 0, y)
            statusLine:Show()
            y = y + Card.LINE_HEIGHT
        end
        used = used + 1
        local bubble = Bubble(used)
        local secret = msg.secret or Echo.IsSecret(msg.text)
        local height = SizeBubble(bubble, msg.text, secret)
        bubble:ClearAllPoints()
        if msg.outgoing then
            bubble:SetPoint("BOTTOMRIGHT", area, "BOTTOMRIGHT", 0, y)
            bubble:SetBackdropColor(a.r, a.g, a.b, msg.status == "pending" and 0.14 or 0.24)
            bubble:SetBackdropBorderColor(a.r, a.g, a.b, 0.6)
            if msg.status == "failed" then
                bubble.text:SetTextColor(1, 0.45, 0.45, 1)
            else
                bubble.text:SetTextColor(0.92, 0.93, 0.98, 1)
            end
        else
            bubble:SetPoint("BOTTOMLEFT", area, "BOTTOMLEFT", 0, y)
            bubble:SetBackdropColor(0.11, 0.11, 0.15, 0.95)
            bubble:SetBackdropBorderColor(0.28, 0.30, 0.38, 0.5)
            bubble.text:SetTextColor(r, g, b, 1)
        end
        bubble:Show()
        y = y + height
        local startsGroup = View.StartsGroup(messages, i)
        if startsGroup and isGroup and not msg.outgoing
            and not Echo.IsSecret(msg.sender) and type(msg.sender) == "string" then
            usedLabels = usedLabels + 1
            local label = Label(usedLabels)
            label:SetText(msg.sender:match("^([^-]+)") or msg.sender)
            local cr, cg, cb = View.ClassColor(msg.class)
            label:SetTextColor(cr or r, cg or g, cb or b, 1)
            label:ClearAllPoints()
            label:SetPoint("BOTTOMLEFT", area, "BOTTOMLEFT", 2, y + 2)
            label:Show()
            y = y + Card.LINE_HEIGHT
        end
        y = y + (startsGroup and Card.GROUP_GAP or Card.GAP)
    end
    for j = used + 1, #bubbles do bubbles[j]:Hide() end
    for j = usedLabels + 1, #labels do labels[j]:Hide() end
end

--- Redraw the card around its conversation, and mark that conversation read.
function Card.Render()
    if not root or not root:IsShown() then return end
    local View, Store = Echo.View, Echo.Store
    local list = Store.List()
    local conv = currentKey and Store.Get(currentKey)
    if not conv or not conv.open then conv = list[1] end
    if not conv then
        Card.Hide()
        return
    end
    if renderedKey ~= conv.key then
        if renderedKey then Echo.ParkDraft(renderedKey, edit:GetText()) end
        edit:SetText(Echo.TakeDraft(conv.key))
        offset = 0
    end
    renderedKey = conv.key
    currentKey = conv.key

    local a = View.ACCENT
    for i = 1, Card.TILES do
        local b, other = rowTiles[i], list[i]
        if other then
            local spec = View.TileSpec(other)
            b.convKey = other.key
            PaintTile(b, spec)
            if other.key == conv.key then
                b:SetBackdropBorderColor(a.r, a.g, a.b, 1)
            else
                b:SetBackdropBorderColor(0, 0, 0, 0.7)
            end
            b.dot:SetShown(spec.badge ~= nil and other.key ~= conv.key)
            b:Show()
        else
            b.convKey = nil
            b:Hide()
        end
    end

    local spec = View.TileSpec(conv)
    nameText:SetText(View.DisplayName(conv))
    nameText:SetTextColor(spec.r, spec.g, spec.b, 1)
    metaText:SetText(View.CardMeta(conv):upper())
    if conv.kind == "whisper" then
        edit.placeholder:SetText(L["ECHO_WHISPER_TO"]:format(View.DisplayName(conv)))
    else
        edit.placeholder:SetText(L["ECHO_REPLY"])
    end
    edit.placeholder:SetShown(edit:GetText() == "" and not edit:HasFocus())

    RenderMessages(conv)
    Store.MarkRead(conv.key)
end

local function Anchor()
    local column = _G.HorizonSuiteEchoColumn
    root:ClearAllPoints()
    if column then
        root:SetScale(column:GetScale())
        root:SetFrameStrata(column:GetFrameStrata())
        root:SetFrameLevel(column:GetFrameLevel() + 10)
        root:SetPoint("BOTTOMRIGHT", column, "BOTTOMLEFT", -8, 0)
    else
        root:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

--- Open the card on a conversation; the stack closes.
-- @param convKey string|nil  nil for the top conversation
-- @param focus boolean|nil  focus the reply box
function Card.Open(convKey, focus)
    if not root then Create() end
    if #Echo.Store.List() == 0 then return end
    if Echo.Stack then Echo.Stack.Hide() end
    currentKey = convKey
    offset = 0
    Anchor()
    root:Show()
    Card.Render()
    if focus and root:IsShown() then edit:SetFocus() end
end

--- Switch the open card to another conversation (opens it if closed).
-- @param convKey string
function Card.Show(convKey)
    if not root or not root:IsShown() then
        Card.Open(convKey)
        return
    end
    currentKey = convKey
    Card.Render()
end

function Card.Hide()
    if not root then return end
    if edit and renderedKey then
        Echo.ParkDraft(renderedKey, edit:GetText())
        edit:SetText("")
        renderedKey = nil
    end
    if edit then edit:ClearFocus() end
    root:Hide()
end

--- @return boolean
function Card.IsShown()
    return root ~= nil and root:IsShown()
end

--- The mouse wheel over the messages: up (+1) shows older ones.
-- @param delta number
function Card.Scroll(delta)
    if not root or not root:IsShown() then return end
    offset = offset + delta
    Card.Render()
end

--- Send the reply box's text to the card's conversation.
function Card.Submit()
    local text = edit and edit:GetText()
    if not currentKey or not text or text == "" then return end
    Echo.Send.Send(currentKey, text)
    edit:SetText("")
    offset = 0
end

--- Send a failed message again.
-- @param msg table  the failed record
function Card.Retry(msg)
    if not currentKey or not msg or msg.status ~= "failed" then return end
    msg.status = "retried"
    Echo.Send.Send(currentKey, msg.text)
end

function Card.OnStoreChange()
    if root and root:IsShown() then Card.Render() end
end

function Card.Enable()
    if not root then Create() end
    if not Card.subscribed then
        Echo.Store.Subscribe(Card.OnStoreChange)
        Card.subscribed = true
    end
end

function Card.Disable()
    if Card.subscribed then
        Echo.Store.Unsubscribe(Card.OnStoreChange)
        Card.subscribed = false
    end
    Card.Hide()
    renderedKey, currentKey = nil, nil
end

-- Test and debug handle.
function Card._frames()
    return {
        root = root, rowTiles = rowTiles, name = nameText, meta = metaText, area = area,
        edit = edit, send = send, menu = menuButton, chevron = chevron,
        bubbles = bubbles, labels = labels, status = statusLine,
    }
end
```

- [ ] **Step 4: TOC, then run the tests and parse-check**

Add `modules/Echo/EchoCard.lua` to `HorizonSuite.toc` after `modules/Echo/EchoMenu.lua`.

Expected: `478 passed, 0 failed`. `EchoCard.lua` parses.

- [ ] **Step 5: Commit**

```bash
git add modules/Echo/EchoCard.lua HorizonSuite.toc tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): add the expanded card with bubbles, status and reply" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 6: Wiring — clicks open the card, one view at a time, combat, lint

**Files:**
- Modify: `modules/Echo/EchoTiles.lua` (tile and toast clicks)
- Modify: `modules/Echo/EchoStack.lua` (`Stack.Open` and `Stack.HoverEnter` defer to the card)
- Modify: `modules/Echo/EchoModule.lua` (enable and disable the card, hook links, close the card in combat)
- Modify: `.luacheckrc`
- Test: `tools/test_echo_logic.js` (new section before `// --- Summary`)

**Interfaces:**
- Consumes: `Card.Open`, `Card.Hide`, `Card.IsShown`, `Card.Enable`, `Card.Disable`, `Links.Hook`.

- [ ] **Step 1: Write the failing tests**

Insert before `// --- Summary`:

```js
// --- Wiring: clicks open the card; one view at a time --------------------------------------
run(`
  local S, T, K, C = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles, HorizonSuite.Echo.Stack, HorizonSuite.Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  C.Enable()
  local card, stack = C._frames(), K._frames()
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  S.Add({ convKey = "w:Vexa-Horizon", text = "gz", sender = "Vexa-Horizon" })

  local tile = T.TileFor("w:Brisa-Horizon")
  tile.scripts.OnClick(tile)
  check("clicking a tile opens the card on it", card.root:IsShown() and card.name.text == "Brisa", card.name.text)
  C.Hide()

  local toast = T._toast()
  toast.convKey = "w:Vexa-Horizon"
  toast.scripts.OnClick(toast)
  check("clicking a toast opens the card on it", card.root:IsShown() and card.name.text == "Vexa", card.name.text)

  local savedNewTimer = C_Timer.NewTimer
  local fired
  C_Timer.NewTimer = function(_, fn) fired = fn; return { Cancel = function() end } end
  K.HoverEnter("w:Brisa-Horizon")
  check("hovering the column does nothing while the card is open", fired == nil and not stack.root:IsShown(), tostring(fired))
  C_Timer.NewTimer = savedNewTimer

  C.Open("w:Vexa-Horizon")
  K.Open("w:Brisa-Horizon")
  check("opening the stack closes the card", not card.root:IsShown() and stack.root:IsShown(), "both")
  stack.edit:SetText("from the stack")
  stack.card.open.scripts.OnClick(stack.card.open)
  check("the stack's Open button opens the card", card.root:IsShown() and not stack.root:IsShown(), "?")
  check("the draft moves from the stack to the card", card.edit.text == "from the stack", card.edit.text)

  C.Disable()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'wiring');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Expected: `clicking a tile opens the card on it` fails, because the click still opens the stack.

- [ ] **Step 3: Tiles**

In `modules/Echo/EchoTiles.lua`, change the tile's `OnClick` (in `CreateTile`) to:

```lua
    b:SetScript("OnClick", function(self)
        local view = Echo.Card or Echo.Stack
        if self.convKey and view then view.Open(self.convKey) end
    end)
```

In the toast's `OnClick` (in `CreateToast`), replace `if self.convKey and Echo.Stack then Echo.Stack.Open(self.convKey) end` with:

```lua
        local view = Echo.Card or Echo.Stack
        if self.convKey and view then view.Open(self.convKey) end
```

- [ ] **Step 4: Stack**

In `modules/Echo/EchoStack.lua`:
- In `Stack.Open`, directly after `if not root then Create() end`, add `if Echo.Card then Echo.Card.Hide() end`.
- At the top of `Stack.HoverEnter`, add `if Echo.Card and Echo.Card.IsShown() then return end`.

- [ ] **Step 5: Module**

In `modules/Echo/EchoModule.lua`:
- In `OnLifecycleEvent`'s `PLAYER_REGEN_DISABLED` branch, add `Echo.Card.Hide()` after `Echo.Stack.Hide()`.
- In `Echo.Init`, after `Echo.Stack.Enable()`, add `Echo.Card.Enable()` and `Echo.Links.Hook()`.
- In `Echo.Disable`, add `Echo.Card.Disable()` before `Echo.Stack.Disable()`.

If the module smoke test (`module` section) asserts the exact events or calls on `REGEN_DISABLED`, extend it with one check that the card is hidden when combat starts.

- [ ] **Step 6: Lint globals**

In `.luacheckrc` `read_globals`, add each of these that isn't already listed (grep first): `MenuUtil`, `ChatEdit_InsertLink`, `C_GuildInfo`.

- [ ] **Step 7: Run the tests and parse-check**

Expected: `484 passed, 0 failed` (one more if you added the module combat check). `EchoTiles.lua`, `EchoStack.lua`, `EchoModule.lua` and `.luacheckrc` all parse.

- [ ] **Step 8: Commit**

```bash
git add modules/Echo/EchoTiles.lua modules/Echo/EchoStack.lua modules/Echo/EchoModule.lua .luacheckrc tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): open the card from tiles and toasts, one view at a time" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 7: In-game check (on the Windows PC, a human step)

- [ ] **Step 1: Push `feature/echo`** and hand over the pull command. The TOC gains files, so the game needs a full restart.

- [ ] **Step 2: Checklist (director, in game)**

1. `/h echo test`, then click Brisa's tile: the card opens beside the column. The tile row is at the top with Brisa outlined, and "Brisa" is in Druid orange with "DRUID" (plus "FRIEND", "ONLINE" or "GUILDMATE" where true) under it.
2. The bubbles: Brisa's two lines sit on the left, newest at the bottom, grouped close together. The reply box reads "Whisper Brisa…".
3. Type a reply and press Enter, or click the periwinkle **>**: your bubble appears on the right, "Sending…" turns to "Sent", and the box keeps focus.
4. Whisper a name that's offline from the card: "Not delivered · Retry" appears in red. Click Retry and it sends again.
5. Scroll over the messages: older ones come into view. Scroll back down to the newest.
6. Click another tile in the card's row: the card switches. A half-typed reply to Brisa comes back when you switch back.
7. Click `⋯`: Pin, Notifications (Default (Loud), Loud, Count, Quiet, Muted) and Close conversation are listed. Pin Brisa, then `/reload`: Brisa's tile is pinned first. Mute General, `/reload`, let General talk: no count on its tile.
8. With the reply box focused, shift-click an item in your bags: the link goes into Echo's box, not Blizzard's chat. Send it: the item link shows in the bubble and whoever receives it can click it.
9. Hover the column while the card is open: nothing else opens. Click a toast: the card opens on that conversation. From the stack, press **Open**: the card takes over with your draft.
10. Party or raid chat with two people talking: their names appear above each group in class colour.
11. Escape once: the reply box loses focus. Escape again: the card closes. The chevron also closes it.
12. Start a fight with the card open: it closes. Click a tile mid-fight: the card opens.
13. A whisper during an encounter where chat is hidden: it shows as a full-width bubble about three lines tall, with no error.
14. Repeat this list on Forever.
