# Horizon Echo: Where Each Type of Chat Shows Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let the player choose, per chat type, whether it shows in Echo only, in Echo and Blizzard's chat, or in Blizzard's chat only. The case that prompted this: whispers in Echo, and everything else (guild, trade, party, the combat log) left in Blizzard's normal window.

**Architecture:** A new per-kind setting, `echoRoute<Kind>`, takes `"echo"`, `"both"` or `"blizzard"`. `Echo.ApplyOptions` turns the routes into two runtime switches:
- **The Store's handled kinds.** A `"blizzard"` kind is filed, started and restored by nobody, and its open tiles close.
- **The Blizzard message filter.** It exists today for whispers only, and generalises to every `"echo"` kind.

The old `echoHideStoredWhispers` toggle is retired. `Echo.Route` reads it as a legacy value, so a player who had it on keeps whispers in Echo only.

**Tech Stack:** Lua 5.1 (WoW addon), tests in `tools/test_echo_logic.js` run under fengari.

**Spec:** this plan carries its own design (below). It extends `Docs/Engineering/2026-09-24-echo-chat-design.md`.

## Design

| Route | Echo | Blizzard's windows (chat shown) | Blizzard's windows hidden by Echo |
|---|---|---|---|
| `echo` | files it, tiles open | the filter hides each line Echo files (an unreadable line stays) | same as `both` |
| `both` (default) | files it, tiles open | shows it | same as `echo` |
| `blizzard` | files, starts and restores nothing; open tiles close | shows it | goes to the All view |

- **Kinds with a route:** `whisper`, `bnet`, `party`, `raid`, `instance`, `guild`, `officer`, `channel`, `nearby`. Feeds (loot, progress, system) keep their existing on/off toggles.
- **The default is `both` for every kind,** which is today's behaviour with `echoHideStoredWhispers` off. With `echoHideBlizzardChat` on (the default), `both` and `echo` behave the same, so nothing changes for a player who touches nothing.
- **Legacy setting:** an unset `echoRouteWhisper` or `echoRouteBnet` reads `"echo"` when the old `echoHideStoredWhispers` is `true`. This mirrors how `CombatLog.Mode` reads the old `echoKeepCombatLog`.
- **While Echo hides Blizzard's chat,** the filter stays off for every kind. `ChatFrame1` keeps its whisper events so Blizzard's own code sets R's reply target, and a filtered line would skip that. This is today's rule for whispers, unchanged.
- **The All view picks up `"blizzard"` kinds.** `All.ExtraEvents` already registers every chat event Echo doesn't file. A `"blizzard"` kind's events count as not filed, so they reach All, and while Blizzard's chat is hidden, All is where they go. With Blizzard's chat shown, All collects them too, as it already collects every line. The `DEFAULT_CHAT_FRAME.AddMessage` stack skip keeps them from arriving twice.
- **The reply target, whisper sound and taskbar flash** for a filtered line stay whisper-only (`Filter.Handler` already limits them to `CHAT_MSG_WHISPER` and `CHAT_MSG_BN_WHISPER`). Guild, party and other lines need none of them.
- **Out of scope:** hosting the combat log in Echo while Blizzard's chat is shown. With Blizzard's chat shown, the combat log stays in its own Blizzard tab, which is what the request wants.

## Global Constraints

- **Lua and style:** Lua 5.1, fengari-safe: no `goto`, `//`, bitwise operators, `unpack`, `tinsert` or `%z`. Match the Echo file header pattern and comment density.
- **Secret values:** ask `Echo.IsSecret(v)` before `type()`, comparing, concatenating or indexing any value from the game. Settings read from the DB are not game values.
- **Taint:**
  - Never write to Blizzard chat frame fields.
  - Never hook or replace Blizzard chat functions; message filters go through `ChatFrameUtil.AddMessageEventFilter` (legacy `ChatFrame_AddMessageEventFilter`), as today.
- **Strings:** everything shown to the player goes through `addon.L`. New keys go in `locales/horizon/enUS.lua` only, next to the Echo keys they sit with, aligned with their neighbours. Other locales fall back to enUS.
- **Settings:** every new setting is in `addon.ECHO_DEFAULTS`, and `ECHO_KEYS` derives from it. Every setting except `echoHoverDelay` must appear on `options/modules/OptionsEcho.lua`; an existing test enforces this.
- **Commits:** Conventional Commits with scope `echo`, one per task. Run `git add` and `git commit` as separate commands. Each message ends with exactly `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Never use `git stash`.
- **Branch:** `feature/echo-chat-type-routing`, from `main`.
- **Test command:** `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js` (2833 passing at the start).
- **Parse check:** every changed Lua file, with:
  `NODE_PATH="$HOME/.cache/hs-test/node_modules" node -e "const {lauxlib,lua,to_luastring,to_jsstring}=require('fengari');const L=lauxlib.luaL_newstate();for(const f of process.argv.slice(1)){const s=require('fs').readFileSync(f,'utf8').replace(/^\uFEFF/,'');console.log(f,lauxlib.luaL_loadbuffer(L,to_luastring(s),null,to_luastring(f))===lua.LUA_OK?'parses':to_jsstring(lua.lua_tostring(L,-1)))}" <files>`
- **Stubs:** restore every global a test stubs (`ChatFrameUtil`, `ChatFrame_AddMessageEventFilter`, `ChatFrame_RemoveMessageEventFilter`, `ChatTypeGroup`, `HorizonSuite.GetDB`). Store tiers and handled kinds survive `Store.Reset()`, so a test that changes them sets them back.

---

### Task 1: The Store knows which kinds Echo handles

**Files:**
- Modify: `modules/Echo/EchoStore.lua` (state near `local kindTiers = {}`; `Store.Start` at about line 544; `Store.Restore` at about line 802)
- Modify: `modules/Echo/EchoEvents.lua` (`Events.Dispatch`, about line 496)
- Modify: `modules/Echo/EchoInput.lua` (`Follow`, about line 376)
- Test: `tools/test_echo_logic.js`

**Interfaces:**
- Produces:
  - `Store.SetKindHandled(kind: string, handled: boolean) -> boolean`. It is false for a feed or an unknown kind.
  - `Store.Handles(kind: string|nil) -> boolean`. It is false only for a conversation kind set unhandled.
  - `Store.Start` returns nil for an unhandled kind, and `Store.Restore` skips one.
  - `Events.Dispatch` drops an unhandled kind's event before running other addons' filters.

- [ ] **Step 1: Write the failing tests.** Add a section after the `'store-keys'` section:

```js
// --- Chat routing: kinds Echo leaves to Blizzard's chat ------------------------
run(`
  local Echo = HorizonSuite.Echo
  local S, E = Echo.Store, Echo.Events
  local savedUtil, savedGet = ChatFrameUtil, ChatFrame_GetMessageEventFilters
  ChatFrameUtil, ChatFrame_GetMessageEventFilters = nil, nil
  S.Reset()
  check("routing: every kind handled by default", S.Handles("whisper") and S.Handles("guild") and S.Handles(nil), "unhandled")
  check("routing: a feed can't be left to Blizzard here", S.SetKindHandled("loot", false) == false and S.Handles("loot"), "accepted")
  check("routing: an unknown kind is refused", S.SetKindHandled("say", false) == false, "accepted")
  check("routing: a kind can be left to Blizzard", S.SetKindHandled("guild", false) == true and S.Handles("guild") == false, "still handled")

  E.Dispatch("CHAT_MSG_GUILD", "hello", "Brisa-Horizon", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
  check("routing: an unhandled kind files nothing", S.Get("guild") == nil, "filed")
  E.Dispatch("CHAT_MSG_PARTY", "hi", "Brisa-Horizon", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
  check("routing: other kinds still file", S.Get("party") ~= nil and #S.Get("party").messages == 1, "missing")

  S.SetKindHandled("whisper", false)
  check("routing: an unhandled kind can't be started", S.Start("w:Brisa-Horizon") == nil and S.Get("w:Brisa-Horizon") == nil, "started")
  check("routing: nor restored", S.Restore({ "w:Brisa-Horizon", "w:Varo-Horizon" }) == 0 and S.Get("w:Varo-Horizon") == nil, "restored")

  S.SetKindHandled("whisper", true)
  S.SetKindHandled("guild", true)
  check("routing: handled again", S.Handles("whisper") and S.Handles("guild"), "unhandled")
  check("routing: and startable again", S.Start("w:Brisa-Horizon") ~= nil, "refused")
  S.Reset()
  ChatFrameUtil, ChatFrame_GetMessageEventFilters = savedUtil, savedGet
`, 'routing-store');
```

In the input section, after the `target: a secret whisper name has none` check (about line 8275), where `I`, `C`, `box`, `fire` and `target` are in scope, add:

```lua
  -- A kind left to Blizzard's chat opens no card as the line targets it.
  local S = HorizonSuite.Echo.Store
  S.SetKindHandled("officer", false)
  C.Hide()
  fire("ActivateChat", box)
  target("OFFICER")
  fire("UpdateHeader", box)
  check("input: a kind left to Blizzard's chat opens no card", S.Get("officer") == nil and not C._frames().frame:IsShown(), "opened")
  fire("DeactivateChat", box)
  S.SetKindHandled("officer", true)
```

If `C._frames()` has no `frame` field, assert on whatever the surrounding card tests use to tell whether the card is shown. The `S.Get("officer") == nil` half is the one that must hold.

- [ ] **Step 2: Run the tests to check they fail.**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`
Expected: the run stops in `routing-store` with `attempt to call a nil value (field 'Handles')`.

- [ ] **Step 3: Implement the Store half.** In `EchoStore.lua`, after `local kindTiers = {}`:

```lua
local unhandled = {}  -- kind -> true while its chat is left to Blizzard's windows (Echo.Route "blizzard")
```

After `Store.KindTier` (or beside `Store.SetKindTier`):

```lua
--- Set whether Echo takes a conversation kind's chat (Echo.ApplyOptions, from the
-- echoRoute* settings). A kind Echo doesn't take is filed, started and restored by
-- nobody: its chat stays in Blizzard's windows. Feeds always are taken. Store.Reset keeps
-- this, as it keeps tiers.
-- @param kind string  A Store.DEFAULT_TIERS key
-- @param handled boolean
-- @return boolean accepted
function Store.SetKindHandled(kind, handled)
    if not Store.DEFAULT_TIERS[kind] or Store.FEED_KINDS[kind] then return false end
    unhandled[kind] = (handled == false) or nil
    return true
end

--- @param kind string|nil
-- @return boolean  false only for a conversation kind left to Blizzard's chat
function Store.Handles(kind)
    return not (kind ~= nil and unhandled[kind])
end
```

In `Store.Start`, change the first guard to:

```lua
    if not kind or Store.FEED_KINDS[kind] or not Store.Handles(kind) then return nil end
```

and add to its doc comment: `nil for an invalid key, a feed, or a kind left to Blizzard's chat`.

In `Store.Restore`, change the `elseif` to:

```lua
        elseif Store.IsPersisted(Store.KindOf(key)) and Store.Handles(Store.KindOf(key)) then
```

- [ ] **Step 4: Implement the intake half.** In `Events.Dispatch`, rename `feedKind` to `kind` (it is any event's kind) and add the new guard after the feed check:

```lua
    -- A switched-off feed files nothing (the system line above still checked for a failed whisper).
    local kind = Store.EVENT_KIND[event]
    if Store.FEED_KINDS[kind] and Echo.FeedEnabled and not Echo.FeedEnabled(kind) then return end
    -- A kind left to Blizzard's chat (Echo.Route "blizzard") files nothing either.
    if kind and not Store.Handles(kind) then return end
```

Then update the later `Store.FEED_KINDS[feedKind]` (the probe check) to `Store.FEED_KINDS[kind]`.

In `EchoInput.lua` `Follow`, replace the last three lines with:

```lua
    followed = key
    -- A kind left to Blizzard's chat has no conversation to follow.
    if not Echo.Store.Start(key) then return end
    Card.Show(key, nil)  -- no tile, so no genie: the line is being typed in
```

- [ ] **Step 5: Run the tests and the parse check.** Expected: all pass (2833 + 11). Parse-check `EchoStore.lua`, `EchoEvents.lua` and `EchoInput.lua`.

- [ ] **Step 6: Commit.**

```bash
git add modules/Echo/EchoStore.lua modules/Echo/EchoEvents.lua modules/Echo/EchoInput.lua tools/test_echo_logic.js
```
```bash
git commit -m "feat(echo): let the store leave a chat kind to Blizzard's chat" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: The Blizzard filter hides any set of kinds

**Files:**
- Modify: `modules/Echo/EchoFilter.lua` (whole file: header, event lists, `Filter.Apply`)
- Modify: `modules/Echo/EchoOptions.lua:131-135` (the filter block in `Echo.ApplyOptions`)
- Modify: `modules/Echo/EchoHideChat.lua:273`, `modules/Echo/EchoModule.lua:138` (the `Apply(false)` callers)
- Test: `tools/test_echo_logic.js` (`'echo-filter'` section at about line 4135, the filter use at about line 8930)

**Interfaces:**
- Consumes: `Store.EVENT_KIND`, `Store.FEED_KINDS`, `Echo.IsEventValid` (all existing).
- Produces:
  - `Filter.Apply(kinds: table|nil)`. `kinds` is `kind -> true`; nil or empty turns the filter off.
  - `Filter.EventsFor(kinds: table|nil) -> string[]`, sorted.
  - `Filter.SameKinds(kinds: table|nil) -> boolean`.
  - `Filter.kinds`: the set applied now.
  - `Filter.active`: true while any event is registered.

- [ ] **Step 1: Update the existing tests to the new signature, and add new ones.** In the `'echo-filter'` section, replace each `F.Apply(true)` with `F.Apply({ whisper = true, bnet = true })` and each `F.Apply(false)` with `F.Apply(nil)`. Near line 8930, replace `Echo.Filter.Apply(true)` with `Echo.Filter.Apply({ whisper = true })` and `Echo.Filter.Apply(false)` with `Echo.Filter.Apply(nil)`. Then add a section right after `'echo-filter-lockdown'`:

```js
// --- The filter hides any set of kinds ---------------------------------------------
run(`
  local Echo = HorizonSuite.Echo
  local F = Echo.Filter
  local savedUtil = ChatFrameUtil
  ChatFrameUtil = nil
  local added = {}
  ChatFrame_AddMessageEventFilter = function(event, fn) added[event] = fn end
  ChatFrame_RemoveMessageEventFilter = function(event, fn) if added[event] == fn then added[event] = nil end end
  local tells = 0
  ChatEdit_SetLastTellTarget = function() tells = tells + 1 end
  local savedWhisper, sounds = Echo.Sound.Whisper, 0
  Echo.Sound.Whisper = function() sounds = sounds + 1 end

  F.Apply({ guild = true, party = true })
  check("kinds: guild is hidden", added.CHAT_MSG_GUILD == F.Handler, "missing")
  check("kinds: party and its leader are hidden", added.CHAT_MSG_PARTY == F.Handler and added.CHAT_MSG_PARTY_LEADER == F.Handler, "missing")
  check("kinds: whispers are not", added.CHAT_MSG_WHISPER == nil, "hidden")
  check("kinds: active", F.active == true, F.active)
  check("kinds: the same set", F.SameKinds({ party = true, guild = true }) == true, "differs")
  check("kinds: a different set", F.SameKinds({ guild = true }) == false and F.SameKinds(nil) == false, "same")

  local hide = F.Handler(nil, "CHAT_MSG_GUILD", "hello", "Brisa-Horizon", "", "", "", "", 0, 0, "", 0, 1, "Player-1-DRUID")
  check("kinds: a filed guild line is hidden", hide == true, hide)
  check("kinds: it sets no reply target and plays no sound", tells == 0 and sounds == 0, tells .. "/" .. sounds)
  local keep = F.Handler(nil, "CHAT_MSG_GUILD", SECRET("hello"), "Brisa-Horizon", "", "", "", "", 0, 0, "", 0, 1, "Player-1-DRUID")
  check("kinds: a secret guild line stays", keep == false, keep)

  F.Apply({ loot = true })
  check("kinds: a feed has nothing to hide", next(added) == nil and F.active == false, next(added))

  HorizonSuite.Platform.caps.bnetWhispers = false
  F.Apply({ bnet = true })
  check("kinds: no Battle.net filter without Battle.net whispers", added.CHAT_MSG_BN_WHISPER == nil and F.active == false, "registered")
  HorizonSuite.Platform.caps.bnetWhispers = true

  F.Apply(nil)
  check("kinds: off", next(added) == nil and F.active == false and F.SameKinds(nil), next(added))

  Echo.Sound.Whisper = savedWhisper
  ChatFrameUtil = savedUtil
  ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilter, ChatEdit_SetLastTellTarget = nil, nil, nil
`, 'echo-filter-kinds');
```

- [ ] **Step 2: Run the tests to check they fail.** Expected: `kinds: guild is hidden` and its neighbours fail, because `Apply` still reads its argument as a boolean.

- [ ] **Step 3: Rewrite `EchoFilter.lua`.** Replace the header's first paragraph with:

```lua
--[[
    Horizon Suite - Echo - Filter
    Hides chat Echo has filed from Blizzard's chat windows, for each kind whose route is
    "echo" (Echo.Route; Echo.ApplyOptions passes the set). A line Echo could not read
    (secret text or a secret sender) is never hidden, so nothing is lost. For whispers,
    Blizzard sets the reply target after the filters run, so a hidden incoming whisper sets
    it here instead. Blizzard also plays the whisper sound and flashes the taskbar icon
    after the filters run; a hidden incoming whisper does both here instead, once per chat
    frame, via Echo.Sound.Whisper (EchoSound.lua) and FlashClientIcon. Other kinds need
    neither.
```

Keep the lockdown paragraph and the `Blizzard:` line. Replace the two event lists with:

```lua
local INCOMING = { CHAT_MSG_WHISPER = "WHISPER", CHAT_MSG_BN_WHISPER = "BN_WHISPER" }

local registered = {}  -- events this filter is currently registered on
Filter.kinds = {}      -- kind -> true: the kinds hidden now
```

Replace `Filter.Apply` with:

```lua
--- The chat events hidden for a set of kinds: each event Store.EVENT_KIND gives one of
-- them, never a feed's, Battle.net's only where the client has Battle.net whispers, and
-- only events this client has.
-- @param kinds table|nil  kind -> true
-- @return table events  sorted
function Filter.EventsFor(kinds)
    local out = {}
    if type(kinds) ~= "table" then return out end
    local Store = Echo.Store
    local hasBnet = addon.Platform and addon.Platform.Has("bnetWhispers")
    for event, kind in pairs(Store.EVENT_KIND) do
        if kinds[kind] == true and not Store.FEED_KINDS[kind] and (hasBnet or kind ~= "bnet")
            and Echo.IsEventValid(event) then
            out[#out + 1] = event
        end
    end
    table.sort(out)
    return out
end

--- True when kinds names exactly the kinds hidden now (nil is none).
-- @param kinds table|nil
-- @return boolean
function Filter.SameKinds(kinds)
    if type(kinds) ~= "table" then kinds = {} end
    for kind, on in pairs(kinds) do
        if on == true and not Filter.kinds[kind] then return false end
    end
    for kind in pairs(Filter.kinds) do
        if kinds[kind] ~= true then return false end
    end
    return true
end

--- Hide these kinds' chat from Blizzard's windows, and stop hiding the rest.
-- @param kinds table|nil  kind -> true; nil or empty turns the filter off
function Filter.Apply(kinds)
    local remove = RemoveFn()
    for event in pairs(registered) do
        if remove then remove(event, Filter.Handler) end
    end
    registered = {}
    Filter.kinds = {}
    Filter.active = false
    if type(kinds) ~= "table" then return end
    for kind, on in pairs(kinds) do
        if on == true then Filter.kinds[kind] = true end
    end
    local add = AddFn()
    if not add then return end
    for _, event in ipairs(Filter.EventsFor(Filter.kinds)) do
        add(event, Filter.Handler)
        registered[event] = true
    end
    Filter.active = next(registered) ~= nil
end
```

`Filter.ShouldHide` and `Filter.Handler` stay as they are: `INCOMING` already limits the reply target and alert to whispers.

- [ ] **Step 4: Update the callers.** In `EchoHideChat.lua:273`:

```lua
    if Echo.Filter and Echo.Filter.active then Echo.Filter.Apply(nil) end
```

In `EchoModule.lua:138`: `Echo.Filter.Apply(nil)`.

In `Echo.ApplyOptions` (`EchoOptions.lua`), replace the two filter lines with an interim mapping. Task 3 replaces it:

```lua
    local hiding = Echo.HideChat and Echo.HideChat.IsApplied()
    local filterOn = Echo.Setting("echoHideStoredWhispers") == true and not hiding
    local kinds = filterOn and { whisper = true, bnet = true } or nil
    if not Echo.Filter.SameKinds(kinds) then Echo.Filter.Apply(kinds) end
```

- [ ] **Step 5: Run the tests and the parse check.** Expected: all pass. The existing "re-applying with the same filter setting is a no-op" test still passes through `SameKinds`. Parse-check the four changed Lua files.

- [ ] **Step 6: Commit.**

```bash
git add modules/Echo/EchoFilter.lua modules/Echo/EchoOptions.lua modules/Echo/EchoHideChat.lua modules/Echo/EchoModule.lua tools/test_echo_logic.js
```
```bash
git commit -m "refactor(echo): let the Blizzard chat filter hide any set of kinds" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 3: Route settings drive the Store, the filter and the All view

**Files:**
- Modify: `options/modules/defaults/OptionsDefaultsEcho.lua` (drop `echoHideStoredWhispers`, add the routes)
- Modify: `modules/Echo/EchoOptions.lua` (`Echo.ROUTE_KINDS`, `Echo.ROUTES`, `Echo.RouteKey`, `Echo.Route`, and `ApplyOptions`)
- Modify: `modules/Echo/EchoAll.lua` (header text and `Wanted` in `All.ExtraEvents`, about line 280)
- Modify: `modules/Echo/EchoHideChat.lua` (header lines 26-27)
- Test: `tools/test_echo_logic.js`

**Interfaces:**
- Consumes:
  - From Task 1: `Store.SetKindHandled(kind, handled) -> boolean` and `Store.Handles(kind) -> boolean`.
  - From Task 2: `Filter.Apply(kinds)`, `Filter.SameKinds(kinds) -> boolean` and `Filter.active`.
- Produces:
  - `Echo.ROUTE_KINDS: string[]`.
  - `Echo.ROUTES: { echo = true, both = true, blizzard = true }`.
  - `Echo.RouteKey(kind: string) -> string`, such as `"echoRouteWhisper"`.
  - `Echo.Route(kind: string, get?: function(key, default)) -> "echo"|"both"|"blizzard"`.

- [ ] **Step 1: Write the failing tests.** Add a section right after `'echo-filter-kinds'`:

```js
// --- Routes: where each type of chat shows -----------------------------------------
run(`
  local Echo = HorizonSuite.Echo
  local S, F = Echo.Store, Echo.Filter
  local db = {}
  HorizonSuite.GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  local savedUtil, savedGroups, savedWindow = ChatFrameUtil, ChatTypeGroup, GetChatWindowMessages
  ChatFrameUtil, GetChatWindowMessages = nil, nil
  ChatTypeGroup = { GUILD = { "CHAT_MSG_GUILD" }, WHISPER = { "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM" } }
  local added, adds = {}, 0
  ChatFrame_AddMessageEventFilter = function(event, fn) adds = adds + 1; added[event] = fn end
  ChatFrame_RemoveMessageEventFilter = function(event, fn) if added[event] == fn then added[event] = nil end end
  CreateFrame = STUB_CREATE_FRAME
  local function AllTakes(event)
    for _, e in ipairs(Echo.All.ExtraEvents()) do if e == event then return true end end
    return false
  end
  S.Reset()

  check("route: both by default", Echo.Route("guild") == "both" and Echo.Route("whisper") == "both", Echo.Route("guild"))
  db.echoHideStoredWhispers = true
  check("route: the old whisper setting reads as Echo only", Echo.Route("whisper") == "echo" and Echo.Route("bnet") == "echo", Echo.Route("whisper"))
  check("route: and leaves other kinds alone", Echo.Route("guild") == "both", Echo.Route("guild"))
  db.echoRouteWhisper = "blizzard"
  check("route: a set route beats the old setting", Echo.Route("whisper") == "blizzard", Echo.Route("whisper"))
  db.echoRouteWhisper = "shouty"
  check("route: an invalid route falls back", Echo.Route("whisper") == "echo", Echo.Route("whisper"))
  db.echoHideStoredWhispers, db.echoRouteWhisper = nil, nil
  check("route: a getter can be passed", Echo.Route("guild", function(k, d) return k == "echoRouteGuild" and "echo" or d end) == "echo", "ignored")

  -- Whispers in Echo only, everything else in Blizzard's chat.
  S.Add({ convKey = "guild", text = "old", sender = "Brisa-Horizon" })
  check("route: a guild tile is open", S.Get("guild").open == true, "closed")
  for _, kind in ipairs(Echo.ROUTE_KINDS) do db[Echo.RouteKey(kind)] = "blizzard" end
  db.echoRouteWhisper, db.echoRouteBnet = "echo", "echo"
  Echo.ApplyOptions()
  check("route: Blizzard-only kinds are not handled", not S.Handles("guild") and not S.Handles("nearby"), "handled")
  check("route: Echo-only kinds are", S.Handles("whisper") and S.Handles("bnet"), "unhandled")
  check("route: an open tile of a Blizzard-only kind closes", S.Get("guild").open == false, "open")
  check("route: whispers are hidden from Blizzard's windows", added.CHAT_MSG_WHISPER == F.Handler and added.CHAT_MSG_WHISPER_INFORM == F.Handler, "missing")
  check("route: guild chat is not", added.CHAT_MSG_GUILD == nil, "hidden")
  check("route: All takes the guild chat Echo leaves", AllTakes("CHAT_MSG_GUILD"), "missing")
  check("route: All doesn't take whispers Echo files", not AllTakes("CHAT_MSG_WHISPER"), "taken")

  adds = 0
  Echo.ApplyOptions()
  check("route: re-applying the same routes registers nothing", adds == 0, adds)

  db.echoRouteGuild = "both"
  Echo.ApplyOptions()
  check("route: both is handled and not hidden", S.Handles("guild") and added.CHAT_MSG_GUILD == nil, "wrong")
  check("route: All leaves guild chat to Echo again", not AllTakes("CHAT_MSG_GUILD"), "taken")
  db.echoRouteGuild = "echo"
  Echo.ApplyOptions()
  check("route: Echo-only guild is hidden from Blizzard", added.CHAT_MSG_GUILD == F.Handler, "shown")

  for _, kind in ipairs(Echo.ROUTE_KINDS) do db[Echo.RouteKey(kind)] = nil end
  Echo.ApplyOptions()
  check("route: back to both everywhere", F.active == false and S.Handles("guild") and S.Handles("nearby"), tostring(F.active))

  HorizonSuite.GetDB = nil
  ChatFrameUtil, ChatTypeGroup, GetChatWindowMessages = savedUtil, savedGroups, savedWindow
  ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilter = nil, nil
  S.Reset()
`, 'echo-routes');
```

- [ ] **Step 2: Run the tests to check they fail.** Expected: `attempt to call a nil value (field 'Route')`.

- [ ] **Step 3: Add the defaults.** In `OptionsDefaultsEcho.lua`, delete `echoHideStoredWhispers = false,` and add, after `echoTierSystem`:

```lua
    -- Where each type of chat shows (Echo.Route, EchoOptions.lua): "echo" (Echo only;
    -- Blizzard's windows hide each line Echo files), "both", or "blizzard" (Echo leaves it
    -- alone). Echo.Route reads an old echoHideStoredWhispers = true as "echo" for whispers
    -- and Battle.net whispers.
    echoRouteWhisper       = "both",
    echoRouteBnet          = "both",
    echoRouteParty         = "both",
    echoRouteRaid          = "both",
    echoRouteInstance      = "both",
    echoRouteGuild         = "both",
    echoRouteOfficer       = "both",
    echoRouteChannel       = "both",
    echoRouteNearby        = "both",
```

- [ ] **Step 4: Add the route helpers.** In `EchoOptions.lua`, after `Echo.FeedKey`:

```lua
-- Conversation kinds whose chat can go to Echo, Blizzard's windows, or both.
Echo.ROUTE_KINDS = { "whisper", "bnet", "party", "raid", "instance", "guild", "officer", "channel", "nearby" }
Echo.ROUTES = { echo = true, both = true, blizzard = true }

--- The setting holding where a kind's chat shows.
-- @param kind string
-- @return string
function Echo.RouteKey(kind)
    return "echoRoute" .. Capitalise(kind)
end

--- Where a kind's chat shows: "echo", "both" or "blizzard". An unset route for whispers
-- or Battle.net whispers is "echo" when the retired echoHideStoredWhispers was on.
-- @param kind string
-- @param get function|nil  (key, default) -> value; the options page passes its own
-- @return string
function Echo.Route(kind, get)
    get = get or addon.GetDB or function(_, d) return d end
    local key = Echo.RouteKey(kind)
    local route = get(key, nil)
    if Echo.ROUTES[route] then return route end
    if (kind == "whisper" or kind == "bnet") and get("echoHideStoredWhispers", nil) == true then return "echo" end
    local default = addon.ECHO_DEFAULTS and addon.ECHO_DEFAULTS[key]
    if Echo.ROUTES[default] then return default end
    return "both"
end
```

- [ ] **Step 5: Wire the routes into `Echo.ApplyOptions`.** Replace the interim filter block from Task 2 (and the comment above it) with:

```lua
    -- Where each kind's chat goes. "blizzard": Echo files, starts and restores none of it,
    -- and its open tiles close. "echo": Blizzard's windows hide each line Echo files, except
    -- while Blizzard's chat is hidden: ChatFrame1 then keeps its whisper events so that
    -- Blizzard's own code sets R's target, which a hidden line would skip.
    local hiding = Echo.HideChat and Echo.HideChat.IsApplied()
    local filtered = {}
    for _, kind in ipairs(Echo.ROUTE_KINDS) do
        local route = Echo.Route(kind)
        Store.SetKindHandled(kind, route ~= "blizzard")
        if route == "echo" and not hiding then filtered[kind] = true end
    end
    for _, conv in ipairs(Store.List()) do
        if not Store.Handles(conv.kind) then Store.Close(conv.key) end
    end
    if not Echo.Filter.SameKinds(filtered) then Echo.Filter.Apply(filtered) end
```

`All.SyncEvents` already runs at the end of `ApplyOptions`, after this block, so the All view picks up the new set in the same pass.

- [ ] **Step 6: Let All take Blizzard-only kinds.** In `All.ExtraEvents`, change the first line of `Wanted`:

```lua
    local function Wanted(event)
        -- Echo files a routed event itself, unless its kind is left to Blizzard's chat.
        local kind = routed[event]
        if kind ~= nil and Store.Handles(kind) then return false end
```

In the `EchoAll.lua` header, change "every CHAT_MSG_* in ChatTypeGroup that Echo doesn't route" to "every CHAT_MSG_* in ChatTypeGroup that Echo doesn't file (a kind left to Blizzard's chat, Echo.Route "blizzard", counts)". Make the same change in `All.ExtraEvents`'s doc comment.

In the `EchoHideChat.lua` header, replace the two lines starting `- While hiding is applied, "Hide whispers Echo has stored" stays off` with:

```lua
      - While hiding is applied, the Blizzard chat filter stays off for every kind:
        ChatFrame1 keeps its whisper events so Blizzard's own code sets R's target
        (Echo.ApplyOptions).
```

- [ ] **Step 7: Run the tests and the parse check.** Expected: all pass. The older tests that set `db.echoHideStoredWhispers = true` (about lines 4173 and 9499) keep passing through the legacy read in `Echo.Route`; leave them as they are, since they now cover the migration. The options-page test fails on `on the page: echoRouteWhisper` until Task 4. Confirm that is the only failure. Parse-check the four changed Lua files.

- [ ] **Step 8: Commit.** The options-page failure is expected at this commit and is fixed by the next.

```bash
git add options/modules/defaults/OptionsDefaultsEcho.lua modules/Echo/EchoOptions.lua modules/Echo/EchoAll.lua modules/Echo/EchoHideChat.lua tools/test_echo_logic.js
```
```bash
git commit -m "feat(echo): route each chat type to Echo, Blizzard's chat or both" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: The options page

**Files:**
- Modify: `options/modules/OptionsEcho.lua` (new section before the tiers, `TierDropdown`, the Blizzard chat section)
- Modify: `locales/horizon/enUS.lua` (new keys after `ECHO_TIER_DESC` at about line 2934; delete `ECHO_HIDE_STORED` and `ECHO_HIDE_STORED_DESC` at about line 2946)
- Test: `tools/test_echo_logic.js` (the options-page section, about line 4320)

**Interfaces:**
- Consumes from Task 3: `Echo.ROUTE_KINDS`, `Echo.RouteKey(kind)` and `Echo.Route(kind, get)`.

- [ ] **Step 1: Write the failing tests.** In the options-page section, after `check("guild tier default", ...)`:

```lua
  check("route: on the page, both by default", keys.echoRouteGuild and keys.echoRouteGuild.get() == "both", keys.echoRouteGuild and keys.echoRouteGuild.get())
  local routeValues = {}
  for _, o in ipairs(keys.echoRouteGuild.options) do routeValues[#routeValues + 1] = o[2] end
  check("route: Echo only, both, Blizzard only", table.concat(routeValues, ",") == "echo,both,blizzard", table.concat(routeValues, ","))
  A.OptionsData_SetDB("echoRouteGuild", "blizzard")
  check("route: the guild tier hides when guild is left to Blizzard", keys.echoTierGuild.visibleWhen() == false, "shown")
  A.OptionsData_SetDB("echoRouteGuild", nil)
  check("route: and shows otherwise", keys.echoTierGuild.visibleWhen() == true, "hidden")
  A.OptionsData_SetDB("echoHideStoredWhispers", true)
  check("route: the whisper route reads the old setting", keys.echoRouteWhisper.get() == "echo", keys.echoRouteWhisper.get())
  A.OptionsData_SetDB("echoHideStoredWhispers", nil)
  check("route: the old whisper toggle is gone", keys.echoHideStoredWhispers == nil, "still there")
```

- [ ] **Step 2: Run the tests to check they fail.** Expected: `on the page: echoRouteWhisper` and the new `route:` checks fail.

- [ ] **Step 3: Add the strings.** In `enUS.lua`, delete the `ECHO_HIDE_STORED` and `ECHO_HIDE_STORED_DESC` lines. After `L["ECHO_TIER_DESC"]`, add, aligned with the neighbouring `=`:

```lua
L["ECHO_SECTION_ROUTES"]                                      = "Where each type of chat shows"
L["ECHO_ROUTE_ECHO"]                                          = "Echo only"
L["ECHO_ROUTE_BOTH"]                                          = "Echo and Blizzard chat"
L["ECHO_ROUTE_BLIZZARD"]                                      = "Blizzard chat only"
L["ECHO_ROUTE_DESC"]                                          = "Echo only: Echo takes this chat and removes it from Blizzard's chat windows. Lines Echo can't read stay there. Echo and Blizzard chat: it shows in both. Blizzard chat only: Echo leaves it alone. While Echo hides Blizzard's chat, the first two are the same, and Blizzard chat only goes to the All view."
```

- [ ] **Step 4: Build the section.** In `OptionsEcho.lua`, after `TIER_OPTIONS`:

```lua
local ROUTE_OPTIONS = {
    { L["ECHO_ROUTE_ECHO"],     "echo"     },
    { L["ECHO_ROUTE_BOTH"],     "both"     },
    { L["ECHO_ROUTE_BLIZZARD"], "blizzard" },
}

-- Kinds with a route: their tier means nothing while Echo leaves them to Blizzard's chat.
local ROUTED = {}
for _, kind in ipairs(addon.Echo.ROUTE_KINDS) do ROUTED[kind] = true end
```

Change `TierDropdown` to hide a routed kind's tier when the kind is Blizzard-only:

```lua
local function TierDropdown(kind, label)
    local key = addon.Echo.TierKey(kind)
    local opt = { type = "dropdown", name = label, desc = L["ECHO_TIER_DESC"], dbKey = key,
        options = TIER_OPTIONS, preserveOrder = true,
        get = function() return getDB(key, D[key]) end,
        set = function(v) setDB(key, v) end }
    if ROUTED[kind] then
        opt.visibleWhen = function() return addon.Echo.Route(kind, getDB) ~= "blizzard" end
    end
    return opt
end

local function RouteDropdown(kind, label)
    local key = addon.Echo.RouteKey(kind)
    return { type = "dropdown", name = label, desc = L["ECHO_ROUTE_DESC"], dbKey = key,
        options = ROUTE_OPTIONS, preserveOrder = true,
        get = function() return addon.Echo.Route(kind, getDB) end,
        set = function(v) setDB(key, v) end }
end
```

In `options`, insert before `Section(L["ECHO_SECTION_TIERS"])`:

```lua
    Section(L["ECHO_SECTION_ROUTES"]),
    RouteDropdown("whisper",  L["ECHO_KIND_WHISPER"]),
    RouteDropdown("bnet",     L["ECHO_KIND_BNET"]),
    RouteDropdown("party",    L["ECHO_KIND_PARTY"]),
    RouteDropdown("raid",     L["ECHO_KIND_RAID"]),
    RouteDropdown("instance", L["ECHO_KIND_INSTANCE"]),
    RouteDropdown("guild",    L["ECHO_KIND_GUILD"]),
    RouteDropdown("officer",  L["ECHO_KIND_OFFICER"]),
    RouteDropdown("channel",  L["ECHO_KIND_CHANNEL"]),
    RouteDropdown("nearby",   L["ECHO_NEARBY"]),

```

In the `tail` table, delete the `Toggle(L["ECHO_HIDE_STORED"], ...)` line.

- [ ] **Step 5: Run the full suite and the parse check.** Expected: all pass, the Task 3 options-page failure included. Parse-check `OptionsEcho.lua` and `enUS.lua`. Also run `node tools/locale_audit.js` if it runs without arguments, and confirm it reports no missing or orphaned `ECHO_` key.

- [ ] **Step 6: Commit.**

```bash
git add options/modules/OptionsEcho.lua locales/horizon/enUS.lua tools/test_echo_logic.js
```
```bash
git commit -m "feat(echo): choose where each type of chat shows on the options page" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 5: In-game check and pull request

- [ ] **Step 1: Push the branch.** `git push -u origin feature/echo-chat-type-routing`. Hand Chris the Windows command:

```powershell
cd "C:\Users\chris\HorizonSuite"; git fetch origin; git switch feature/echo-chat-type-routing; git pull --rebase --autostash
```

- [ ] **Step 2: In-game checklist (Retail, then Forever).** `/reload`, then:
  1. Turn off "Hide Blizzard chat" and reload. Set Whispers and Battle.net whispers to **Echo only**, and every other type to **Blizzard chat only**.
  2. Whisper yourself from an alt or a friend. The line shows in Echo and not in Blizzard's window. R replies to them, and the whisper sound plays once.
  3. Guild and Trade lines show in Blizzard's window, and no Guild or Trade tile opens. A Guild tile that was open closes when the route changes.
  4. Type `/g hi` in the input line. No Echo card opens for Guild, and the line sends.
  5. The combat log stays in its own Blizzard tab.
  6. Set Guild to **Echo and Blizzard chat**. A guild line shows in both.
  7. Reload. Whisper tiles from the last session come back, and nothing comes back for a Blizzard-only kind.
  8. Turn "Hide Blizzard chat" back on and reload. Guild chat (still Blizzard-only) appears in the All view.
  9. A profile that had "Hide whispers Echo has stored" on reads **Echo only** for Whispers.

- [ ] **Step 3: Open the PR** with the `/pr` skill, ready (not draft), into `main`.
