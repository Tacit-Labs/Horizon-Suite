# Horizon Echo: Foundation Implementation Plan (1 of 3)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Echo receives chat, files each message under the right conversation with the right tier, keeps whisper history, and sends replies. It has no interface yet, and is proven by logic tests and `/h echo` diagnostics.

**Architecture:** A new `echo` module. `EchoStore` is the conversation model and has no frames. `EchoHistory` writes whispers to `HorizonDB.echoHistory`. `EchoEvents` turns `CHAT_MSG_*` payloads into message records and holds all secret-value handling. `EchoSend` maps a conversation key to a chat type and target. Views (plans 2 and 3) will subscribe to the Store.

**Tech Stack:** WoW Lua 5.1 addon (Retail interface 120100 and Forever 16001), and a fengari (Lua in Node) logic-test harness in the shape of `tools/test_lootroll_logic.js`.

**Spec:** `Docs/Engineering/2026-09-24-echo-chat-design.md`

**Plan series:**
1. **Foundation (this plan):** Store, History, Events, Send, Platform keys, module, slash and probe.
2. **Tiles and stack:** collapsed column, preview toast, peek stack with quick reply.
3. **Card, options and polish:** expanded card, options page and dashboard entries, keybinds, Blizzard-chat whisper filter, shift-click links.

## Global Constraints

- Lua 5.1 only: no `goto`, no integer division `//`, no bitwise operators. fengari runs 5.3, so a 5.3-only construct passes the tests and then fails in game.
- Every file starts with `local addon = _G.HorizonSuite` and `if not addon then return end`, and hangs off `addon.Echo`.
- Secret values: check with `Echo.IsSecret(v)` (a `pcall`-wrapped `issecretvalue`) **before** calling `type()`, comparing, concatenating or lowercasing a chat argument.
- Secret messages are never written to SavedVariables.
- Conversation keys: `w:Name-Realm`, `bn:<bnetAccountID>`, `party`, `raid`, `instance`, `guild`, `officer`, `ch:<channelBaseName>`.
- Default tiers: whisper and bnet are `loud`; party, raid and instance are `count`; guild, officer and channel are `quiet`. A per-conversation override can also be `muted`.
- History: whispers only, at most 100 per conversation. Character whispers are stored under `chars["Name-Realm"]` and BNet under `bnet`. Channels are never persisted.
- Echo ships disabled. A module is only enabled when `HorizonDB.modules.echo.enabled` is true, so enable it with `/h echo toggle`.
- Commits: Conventional Commits with scope `echo` (`feat(echo): …`, `test(echo): …`), on branch `feature/echo-foundation`, ending with the `Co-Authored-By` line.
- Test command (install fengari outside the repo once: `npm install --prefix "$HOME/.cache/hs-test" fengari`):
  `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`
- Lint: `luacheck modules/Echo core/Platform.lua` when luacheck is installed. CI treats warnings as non-blocking, but a parse error fails.

## File map

| File | Status | Responsibility |
|------|--------|----------------|
| `modules/Echo/EchoStore.lua` | Create | Keys, kinds, tiers, conversations, ordering, unread counts, outgoing status, listeners, `Echo.IsSecret` |
| `modules/Echo/EchoHistory.lua` | Create | Whisper persistence in `HorizonDB.echoHistory` |
| `modules/Echo/EchoEvents.lua` | Create | `CHAT_MSG_*` to record, secret rules, mentions, failure detection, event registration, probe |
| `modules/Echo/EchoSend.lua` | Create | Route, split and send a reply |
| `modules/Echo/EchoSlash.lua` | Create | `/h echo` commands and test data |
| `modules/Echo/EchoModule.lua` | Create | `Echo.Init` / `Echo.Disable` and module registration |
| `tools/test_echo_logic.js` | Create | Logic tests |
| `HorizonSuite.toc` | Modify | Load the Echo files after Essence |
| `core/Platform.lua` | Modify | `bnetWhispers` and `secretChat` capability keys |
| `core/CoreSlash.lua:146` | Modify | List `echo` in the `/h` help |
| `Docs/Engineering/2026-09-24-echo-chat-design.md` | Modify (Task 8) | Record the verification results |

---

### Task 0: Branch

- [ ] **Step 1: Create the branch from an up-to-date main**

```bash
git switch main
```

```bash
git pull --rebase origin main
```

```bash
git switch -c feature/echo-foundation
```

- [ ] **Step 2: Install the test runtime outside the repo (once per machine)**

```bash
npm install --prefix "$HOME/.cache/hs-test" fengari
```

Expected: exits 0. Nothing is written inside the repo.

---

### Task 1: Test harness, conversation keys and tiers

**Files:**
- Create: `tools/test_echo_logic.js`
- Create: `modules/Echo/EchoStore.lua`
- Modify: `HorizonSuite.toc` (after `modules/Essence/EssenceModule.lua`, line 162)

**Interfaces:**
- Produces: `addon.Echo.IsSecret(v) -> boolean`; `Store.KeyFor(kind, id) -> string|nil`; `Store.KindOf(convKey) -> string|nil`; `Store.TierOf(convKey) -> "loud"|"count"|"quiet"|"muted"`; `Store.SetTier(convKey, tier|nil) -> boolean`; `Store.Subscribe(fn(convKey, change))`; `Store.Reset()`; `Store.Now() -> number`; tables `Store.DEFAULT_TIERS`, `Store.VALID_TIERS`, `Store.EVENT_KIND`, `Store.PERSISTED_KINDS`, `Store.MAX_MESSAGES`.
- Test globals used by later tasks: `check(name, ok, got)`, `SECRET(v)` (a fake secret value), `PASS`, `FAIL`.

- [ ] **Step 1: Write the harness and the failing key/tier tests**

Create `tools/test_echo_logic.js`:

```js
#!/usr/bin/env node
/**
 * Executable checks for Echo's pure-logic half: the conversation store,
 * whisper history, event-to-record building and outgoing routing.
 *
 * Why this exists. Echo's rules decide which conversation a message belongs
 * to, which tier it rings at, and what may be written to disk. Those are the
 * parts that go wrong silently in game: a secret message saved to
 * SavedVariables, or a guild line reordering the tile column. None of it
 * touches frames, so it runs in a plain Lua VM with the WoW globals stubbed.
 *
 * A fake secret value is a table carrying __secret; the stubbed issecretvalue
 * answers true for it. Code under test must ask Echo.IsSecret before touching
 * a chat argument, exactly as it must in game.
 *
 * Usage:
 *   npm install --prefix "$HOME/.cache/hs-test" fengari   # once, outside the repo
 *   NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js
 *
 * Not wired into CI: the Luacheck workflow is a Lua parse gate with no node step.
 */

const fs = require('fs');
const path = require('path');

let fengari;
try {
  fengari = require('fengari');
} catch (e) {
  console.log('SKIP: fengari not installed. See the usage note at the top of this file.');
  process.exit(0);
}
const { lua, lauxlib, lualib, to_luastring, to_jsstring } = fengari;

const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);

function run(code, name) {
  if (lauxlib.luaL_loadbuffer(L, to_luastring(code), null, to_luastring(name)) !== lua.LUA_OK
      || lua.lua_pcall(L, 0, lua.LUA_MULTRET, 0) !== lua.LUA_OK) {
    console.error(name + ': ' + to_jsstring(lua.lua_tostring(L, -1)));
    process.exit(1);
  }
}

const REPO = path.resolve(__dirname, '..') + '/';
const read = f => fs.readFileSync(REPO + f, 'utf8').replace(/^﻿/, '');

// --- Stub the slice of the WoW/addon environment Echo touches ---------------
run(`
  _G.HorizonSuite = {
    L = setmetatable({}, { __index = function(_, k) return k end }),
    Platform = { caps = { bnetWhispers = true, secretChat = true },
                 Has = function(k) return _G.HorizonSuite.Platform.caps[k] == true end },
  }
  SECRET = function(v) return { __secret = true, v = v } end
  issecretvalue = function(v) return type(v) == "table" and v.__secret == true end
  UnitName = function() return "Kaelis" end
  GetNormalizedRealmName = function() return "Horizon" end
  GetPlayerInfoByGUID = function(guid)
    if guid == "Player-1-DRUID" then return "Druid", "DRUID" end
    return nil
  end
  ERR_CHAT_PLAYER_NOT_FOUND_S = "No player named '%s' is currently playing."

  PASS, FAIL = 0, 0
  function check(name, ok, got)
    if ok then PASS = PASS + 1
    else FAIL = FAIL + 1; print("  FAIL: " .. name .. "  got: " .. tostring(got)) end
  end
`, 'stubs');

// Load order matches HorizonSuite.toc.
const FILES = [
  'modules/Echo/EchoStore.lua',
];
for (const f of FILES) run(read(f), f);

// --- Store: keys, kinds and tiers --------------------------------------------
run(`
  local S = HorizonSuite.Echo.Store
  check("whisper key", S.KeyFor("whisper", "Brisa-Horizon") == "w:Brisa-Horizon", S.KeyFor("whisper", "Brisa-Horizon"))
  check("bnet key from a number", S.KeyFor("bnet", 42) == "bn:42", S.KeyFor("bnet", 42))
  check("channel key", S.KeyFor("channel", "Trade") == "ch:Trade", S.KeyFor("channel", "Trade"))
  check("group key is the kind", S.KeyFor("raid") == "raid", S.KeyFor("raid"))
  check("whisper without a name has no key", S.KeyFor("whisper", nil) == nil, S.KeyFor("whisper", nil))
  check("empty channel name has no key", S.KeyFor("channel", "") == nil, S.KeyFor("channel", ""))
  check("unknown kind has no key", S.KeyFor("say") == nil, S.KeyFor("say"))

  check("kind of whisper key", S.KindOf("w:Brisa-Horizon") == "whisper", S.KindOf("w:Brisa-Horizon"))
  check("kind of bnet key", S.KindOf("bn:42") == "bnet", S.KindOf("bn:42"))
  check("kind of channel key", S.KindOf("ch:Trade") == "channel", S.KindOf("ch:Trade"))
  check("kind of group key", S.KindOf("guild") == "guild", S.KindOf("guild"))
  check("bare prefix is not a key", S.KindOf("w:") == nil, S.KindOf("w:"))
  check("unknown prefix is not a key", S.KindOf("x:abc") == nil, S.KindOf("x:abc"))
  check("non-string is not a key", S.KindOf(nil) == nil, S.KindOf(nil))

  -- Spec tiers: whispers loud, party/raid/instance count, guild/officer/channels quiet.
  check("whisper tier loud", S.TierOf("w:A-B") == "loud", S.TierOf("w:A-B"))
  check("bnet tier loud", S.TierOf("bn:1") == "loud", S.TierOf("bn:1"))
  check("party tier count", S.TierOf("party") == "count", S.TierOf("party"))
  check("raid tier count", S.TierOf("raid") == "count", S.TierOf("raid"))
  check("instance tier count", S.TierOf("instance") == "count", S.TierOf("instance"))
  check("guild tier quiet", S.TierOf("guild") == "quiet", S.TierOf("guild"))
  check("officer tier quiet", S.TierOf("officer") == "quiet", S.TierOf("officer"))
  check("channel tier quiet", S.TierOf("ch:Trade") == "quiet", S.TierOf("ch:Trade"))

  check("override sets a tier", S.SetTier("guild", "loud") and S.TierOf("guild") == "loud", S.TierOf("guild"))
  check("nil override restores the default", S.SetTier("guild", nil) and S.TierOf("guild") == "quiet", S.TierOf("guild"))
  check("invalid tier rejected", S.SetTier("guild", "shouty") == false and S.TierOf("guild") == "quiet", S.TierOf("guild"))
  check("mute is a tier", S.SetTier("raid", "muted") and S.TierOf("raid") == "muted", S.TierOf("raid"))
  S.Reset()
  check("reset clears overrides", S.TierOf("raid") == "count", S.TierOf("raid"))

  check("IsSecret sees a secret", HorizonSuite.Echo.IsSecret(SECRET("x")) == true, "false")
  check("IsSecret passes a plain string", HorizonSuite.Echo.IsSecret("x") == false, "true")
  check("IsSecret passes nil", HorizonSuite.Echo.IsSecret(nil) == false, "true")
`, 'store-keys');

// --- Summary -------------------------------------------------------------------
run(`
  print(PASS .. " passed, " .. FAIL .. " failed")
  if FAIL > 0 then error("echo logic tests failed") end
`, 'summary');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`
Expected: exit 1 with `ENOENT` for `modules/Echo/EchoStore.lua`.

- [ ] **Step 3: Create `modules/Echo/EchoStore.lua`**

```lua
--[[
    Horizon Suite - Echo - Store
    Conversation model: keys, tiers, ordering, unread counts and outgoing status.
    No frames, so tools/test_echo_logic.js drives it directly. Views subscribe
    with Store.Subscribe and redraw the one conversation they are told about.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Store = {}
Echo.Store = Store

--- True when v is a Midnight secret value. Never throws; false on clients without secrets.
-- Ask this before calling type(), comparing, concatenating or lowercasing a chat argument.
-- @param v any
-- @return boolean
function Echo.IsSecret(v)
    if v == nil or type(issecretvalue) ~= "function" then return false end
    local ok, secret = pcall(issecretvalue, v)
    return ok and secret == true
end

Store.MAX_MESSAGES = 100

-- Spec "Notification tiers". "muted" is the per-conversation mute: stored, never counted.
Store.DEFAULT_TIERS = {
    whisper = "loud",  bnet = "loud",
    party   = "count", raid = "count", instance = "count",
    guild   = "quiet", officer = "quiet", channel = "quiet",
}
Store.VALID_TIERS = { loud = true, count = true, quiet = true, muted = true }

-- Leader and warning variants fold into their channel.
Store.EVENT_KIND = {
    CHAT_MSG_WHISPER              = "whisper",
    CHAT_MSG_WHISPER_INFORM       = "whisper",
    CHAT_MSG_BN_WHISPER           = "bnet",
    CHAT_MSG_BN_WHISPER_INFORM    = "bnet",
    CHAT_MSG_PARTY                = "party",
    CHAT_MSG_PARTY_LEADER         = "party",
    CHAT_MSG_RAID                 = "raid",
    CHAT_MSG_RAID_LEADER          = "raid",
    CHAT_MSG_RAID_WARNING         = "raid",
    CHAT_MSG_INSTANCE_CHAT        = "instance",
    CHAT_MSG_INSTANCE_CHAT_LEADER = "instance",
    CHAT_MSG_GUILD                = "guild",
    CHAT_MSG_OFFICER              = "officer",
    CHAT_MSG_CHANNEL              = "channel",
}

-- Only whisper kinds are written to history.
Store.PERSISTED_KINDS = { whisper = true, bnet = true }

local conversations = {}
local overrides = {}
local listeners = {}
local unrouted = 0
local seq = 0  -- monotonic: time() has one-second resolution, ordering needs better

--- Current time; tests replace it.
-- @return number
function Store.Now()
    return time and time() or 0
end

--- Build a conversation key.
-- @param kind string  A Store.DEFAULT_TIERS key
-- @param id string|number|nil  "Name-Realm" (whisper), account ID (bnet), base name (channel)
-- @return string|nil convKey  nil when a kind that needs an id has none
function Store.KeyFor(kind, id)
    if kind == "whisper" or kind == "bnet" or kind == "channel" then
        if id == nil or id == "" then return nil end
        local prefix = (kind == "whisper" and "w:") or (kind == "bnet" and "bn:") or "ch:"
        return prefix .. tostring(id)
    end
    if Store.DEFAULT_TIERS[kind] then return kind end
    return nil
end

--- Kind of a conversation key.
-- @param convKey string
-- @return string|nil kind
function Store.KindOf(convKey)
    if type(convKey) ~= "string" then return nil end
    local prefix = convKey:match("^(%a+):.")
    if prefix == "w" then return "whisper" end
    if prefix == "bn" then return "bnet" end
    if prefix == "ch" then return "channel" end
    if prefix or convKey:find(":", 1, true) then return nil end
    if Store.DEFAULT_TIERS[convKey] then return convKey end
    return nil
end

local function Notify(convKey, change)
    for _, fn in ipairs(listeners) do
        local ok, err = pcall(fn, convKey, change)
        if not ok then
            local handler = geterrorhandler and geterrorhandler()
            if handler then handler(err) end
        end
    end
end

--- Register a view.
-- @param fn function(convKey, change)  change: "toast" | "count" | "quiet" | "silent" |
--   "update" | "closed" | "unrouted" | "reset"; convKey is nil for "unrouted" and "reset"
function Store.Subscribe(fn)
    if type(fn) == "function" then listeners[#listeners + 1] = fn end
end

--- Tier for a conversation: its override, else its kind's default.
-- @param convKey string
-- @return string "loud" | "count" | "quiet" | "muted"
function Store.TierOf(convKey)
    local override = overrides[convKey]
    if override then return override end
    local kind = Store.KindOf(convKey)
    return (kind and Store.DEFAULT_TIERS[kind]) or "quiet"
end

--- Override one conversation's tier; nil restores the default.
-- @param convKey string
-- @param tier string|nil
-- @return boolean accepted
function Store.SetTier(convKey, tier)
    if tier ~= nil and not Store.VALID_TIERS[tier] then return false end
    overrides[convKey] = tier
    Notify(convKey, "update")
    return true
end

--- Forget every conversation (module disable, tests). Listeners and history are kept.
function Store.Reset()
    conversations = {}
    overrides = {}
    unrouted = 0
    seq = 0
    Notify(nil, "reset")
end
```

The `convKey:find(":")` line rejects `w:` and `x:abc`: they contain a colon, so they are never bare group keys.

- [ ] **Step 4: Add the file to the TOC**

In `HorizonSuite.toc`, directly after `modules/Essence/EssenceModule.lua`, add:

```
modules/Echo/EchoStore.lua
```

- [ ] **Step 5: Run the tests and confirm they pass**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`
Expected: `30 passed, 0 failed`, exit 0.

- [ ] **Step 6: Commit**

```bash
git add tools/test_echo_logic.js modules/Echo/EchoStore.lua HorizonSuite.toc
```

```bash
git commit -m "feat(echo): add conversation keys and tiers with logic test harness" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: Conversations, ordering and unread

**Files:**
- Modify: `modules/Echo/EchoStore.lua` (insert before `Store.Reset`)
- Test: `tools/test_echo_logic.js` (new section before `// --- Summary`)

**Interfaces:**
- Consumes: Task 1's locals `conversations`, `listeners`, `unrouted`, `seq`, `Notify`, and `Store.KindOf` / `Store.TierOf`.
- Produces: `Store.Add(record) -> "toast"|"count"|"quiet"|"silent"|nil`; `Store.Get(convKey) -> conv|nil`; `Store.List() -> conv[]`; `Store.MarkRead(convKey)`; `Store.SetPinned(convKey, bool)`; `Store.Close(convKey)`; `Store.CountUnrouted()`; `Store.GetUnroutedCount() -> number`; `Store.ClearUnrouted()`.
- Conversation shape: `{ key, kind, messages = {record…}, unread, createdSeq, lastLoud, pinned, open }`.
- Record fields read here: `convKey`, `outgoing`, `urgent`, `time` (stamped if nil). Written: `seq`, `time`.

- [ ] **Step 1: Write the failing tests**

Insert before `// --- Summary` in `tools/test_echo_logic.js`:

```js
// --- Store: conversations, ordering, unread -------------------------------------
run(`
  local S = HorizonSuite.Echo.Store
  S.Reset()
  local seen = {}
  S.Subscribe(function(key, change) seen[#seen + 1] = tostring(key) .. "=" .. change end)
  local clock = 1000
  S.Now = function() clock = clock + 1; return clock end

  local function msg(key, text, extra)
    local r = { convKey = key, text = text, sender = "X-Horizon" }
    for k, v in pairs(extra or {}) do r[k] = v end
    return r
  end
  local function order()
    local keys = {}
    for i, c in ipairs(S.List()) do keys[i] = c.key end
    return table.concat(keys, ",")
  end

  check("whisper toasts", S.Add(msg("w:Brisa-Horizon", "hi")) == "toast", "?")
  check("party counts", S.Add(msg("party", "pull")) == "count", "?")
  check("guild is quiet", S.Add(msg("guild", "gz")) == "quiet", "?")
  check("urgent party message toasts", S.Add(msg("party", "kaelis look", { urgent = true })) == "toast", "?")
  check("urgent guild message stays quiet", S.Add(msg("guild", "x", { urgent = true })) == "quiet", "?")
  check("unknown key rejected", S.Add(msg("say", "x")) == nil, "?")
  check("non-table rejected", S.Add(nil) == nil, "?")
  check("listener told the change", seen[1] == "w:Brisa-Horizon=toast", seen[1])

  local brisa = S.Get("w:Brisa-Horizon")
  check("record stamped with time", brisa.messages[1].time == 1001, brisa.messages[1].time)
  check("unread counts incoming", brisa.unread == 1, brisa.unread)
  check("party unread 2", S.Get("party").unread == 2, S.Get("party").unread)
  check("quiet conversations still track unread", S.Get("guild").unread == 2, S.Get("guild").unread)

  S.SetTier("guild", "muted")
  check("muted is silent", S.Add(msg("guild", "x")) == "silent", "?")
  check("muted adds no unread", S.Get("guild").unread == 2, S.Get("guild").unread)
  S.SetTier("guild", nil)

  check("loud message orders first", order() == "party,w:Brisa-Horizon,guild", order())
  S.Add(msg("guild", "more"))
  check("quiet message does not reorder", order() == "party,w:Brisa-Horizon,guild", order())
  S.Add(msg("w:Vexa-Horizon", "yo"))
  check("new whisper jumps to the top", order() == "w:Vexa-Horizon,party,w:Brisa-Horizon,guild", order())
  S.Add(msg("party", "one more"))
  check("count message does not reorder", order() == "w:Vexa-Horizon,party,w:Brisa-Horizon,guild", order())
  S.Add(msg("ch:Trade", "wts"))
  check("never-loud conversations sit below loud ones, newest first",
        order() == "w:Vexa-Horizon,party,w:Brisa-Horizon,ch:Trade,guild", order())
  S.SetPinned("guild", true)
  check("pinned first", order() == "guild,w:Vexa-Horizon,party,w:Brisa-Horizon,ch:Trade", order())
  S.SetPinned("guild", false)

  S.MarkRead("party")
  check("mark read clears unread", S.Get("party").unread == 0, S.Get("party").unread)

  S.Close("w:Vexa-Horizon")
  check("closed conversation leaves the list", order() == "party,w:Brisa-Horizon,ch:Trade,guild", order())
  S.Add(msg("w:Vexa-Horizon", "you there?"))
  check("a new message reopens it with context",
        #S.Get("w:Vexa-Horizon").messages == 2 and order():sub(1, 14) == "w:Vexa-Horizon", order())

  S.Add(msg("w:Brisa-Horizon", "sure", { outgoing = true }))
  check("outgoing clears unread", S.Get("w:Brisa-Horizon").unread == 0, S.Get("w:Brisa-Horizon").unread)
  check("replying moves a loud conversation up", order():sub(1, 15) == "w:Brisa-Horizon", order())

  for i = 1, 105 do S.Add(msg("ch:Spam", "line " .. i)) end
  local spam = S.Get("ch:Spam").messages
  check("messages capped at 100", #spam == 100, #spam)
  check("oldest messages dropped first", spam[1].text == "line 6", spam[1].text)

  S.CountUnrouted(); S.CountUnrouted()
  check("unrouted counted", S.GetUnroutedCount() == 2, S.GetUnroutedCount())
  S.ClearUnrouted()
  check("unrouted cleared", S.GetUnroutedCount() == 0, S.GetUnroutedCount())

  S.Subscribe(function() error("view broke") end)
  check("a throwing listener does not block intake", S.Add(msg("w:Brisa-Horizon", "still here")) == "toast", "blocked")

  S.Reset()
  check("reset empties the list", #S.List() == 0, #S.List())
`, 'store-conversations');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`
Expected: exit 1 with `store-conversations: … attempt to call a nil value (field 'Add')`.

- [ ] **Step 3: Implement**

Insert into `modules/Echo/EchoStore.lua` directly above `--- Forget every conversation`:

```lua
local function GetOrCreate(convKey)
    local conv = conversations[convKey]
    if conv then return conv end
    seq = seq + 1
    conv = {
        key        = convKey,
        kind       = Store.KindOf(convKey),
        messages   = {},
        unread     = 0,
        createdSeq = seq,
        lastLoud   = 0,
        pinned     = false,
        open       = true,
    }
    if Store.PERSISTED_KINDS[conv.kind] and Echo.History then
        conv.messages = Echo.History.Load(convKey)
    end
    conversations[convKey] = conv
    return conv
end

local function Append(conv, record)
    local messages = conv.messages
    messages[#messages + 1] = record
    while #messages > Store.MAX_MESSAGES do table.remove(messages, 1) end
end

local function Persist(record)
    if Echo.History and Store.PERSISTED_KINDS[Store.KindOf(record.convKey)] then
        Echo.History.Append(record.convKey, record)
    end
end

--- File a message record (spec: Message record).
-- Incoming: unread +1 unless muted; loud, or urgent on a count conversation, moves it up.
-- Outgoing: clears unread; on a loud conversation it moves it up.
-- @param record table
-- @return string|nil change  "toast" | "count" | "quiet" | "silent"; nil when rejected
function Store.Add(record)
    if type(record) ~= "table" or not Store.KindOf(record.convKey) then return nil end
    local conv = GetOrCreate(record.convKey)
    seq = seq + 1
    record.seq = seq
    record.time = record.time or Store.Now()
    Append(conv, record)
    conv.open = true
    Persist(record)

    local tier = Store.TierOf(record.convKey)
    local change
    if record.outgoing then
        change = "silent"
        conv.unread = 0
        if tier == "loud" then conv.lastLoud = seq end
    elseif tier == "muted" then
        change = "silent"
    else
        conv.unread = conv.unread + 1
        if tier == "loud" or (tier == "count" and record.urgent) then
            change = "toast"
            conv.lastLoud = seq
        elseif tier == "count" then
            change = "count"
        else
            change = "quiet"
        end
    end
    Notify(record.convKey, change)
    return change
end

--- @param convKey string
-- @return table|nil conversation
function Store.Get(convKey)
    return conversations[convKey]
end

--- Open conversations: pinned first, then most recent loud message, then newest created.
-- Count and quiet messages never change the order.
-- @return table conversations
function Store.List()
    local out = {}
    for _, conv in pairs(conversations) do
        if conv.open then out[#out + 1] = conv end
    end
    table.sort(out, function(a, b)
        if a.pinned ~= b.pinned then return a.pinned end
        if a.lastLoud ~= b.lastLoud then return a.lastLoud > b.lastLoud end
        return a.createdSeq > b.createdSeq
    end)
    return out
end

function Store.MarkRead(convKey)
    local conv = conversations[convKey]
    if not conv or conv.unread == 0 then return end
    conv.unread = 0
    Notify(convKey, "update")
end

function Store.SetPinned(convKey, pinned)
    local conv = conversations[convKey]
    if not conv then return end
    conv.pinned = pinned and true or false
    Notify(convKey, "update")
end

--- Remove a conversation's tile. Messages are kept, so a new message reopens it with context.
function Store.Close(convKey)
    local conv = conversations[convKey]
    if not conv then return end
    conv.open = false
    conv.unread = 0
    conv.pinned = false
    Notify(convKey, "closed")
end

--- A message Echo could not file (secret sender). Blizzard's chat frame still shows it.
function Store.CountUnrouted()
    unrouted = unrouted + 1
    Notify(nil, "unrouted")
end

function Store.GetUnroutedCount()
    return unrouted
end

function Store.ClearUnrouted()
    unrouted = 0
    Notify(nil, "unrouted")
end
```

- [ ] **Step 4: Run the tests and confirm they pass**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`
Expected: `61 passed, 0 failed`.

- [ ] **Step 5: Commit**

```bash
git add modules/Echo/EchoStore.lua tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): file messages into conversations with tiered unread and ordering" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 3: Outgoing status (pending, sent, failed)

**Files:**
- Modify: `modules/Echo/EchoStore.lua` (insert before `Store.Reset`)
- Test: `tools/test_echo_logic.js` (new section before `// --- Summary`)

**Interfaces:**
- Consumes: `Store.Add`, local `Persist`, `Notify`, `conversations`.
- Produces: `Store.AddPending(convKey, text) -> record|nil` (status `"pending"`); `Store.ConfirmSent(record) -> boolean matched`; `Store.MarkFailed(convKey) -> record|nil`.

- [ ] **Step 1: Write the failing tests**

Insert before `// --- Summary`:

```js
// --- Store: outgoing status --------------------------------------------------------
run(`
  local S = HorizonSuite.Echo.Store
  S.Reset()
  local p1 = S.AddPending("w:Brisa-Horizon", "first")
  local p2 = S.AddPending("w:Brisa-Horizon", "second")
  check("pending record returned", p1 and p1.status == "pending" and p1.outgoing, p1 and p1.status)
  check("pending adds no unread", S.Get("w:Brisa-Horizon").unread == 0, S.Get("w:Brisa-Horizon").unread)

  check("echo matches by text",
        S.ConfirmSent({ convKey = "w:Brisa-Horizon", text = "second", outgoing = true }) == true, "no match")
  check("only the matched message is sent", p2.status == "sent" and p1.status == "pending", p2.status .. "/" .. p1.status)
  check("echo does not add a second bubble", #S.Get("w:Brisa-Horizon").messages == 2, #S.Get("w:Brisa-Horizon").messages)

  check("a secret echo confirms the oldest pending",
        S.ConfirmSent({ convKey = "w:Brisa-Horizon", text = SECRET("first"), secret = true, outgoing = true }) == true, "no match")
  check("oldest pending now sent", p1.status == "sent", p1.status)

  check("echo with nothing pending is filed as new",
        S.ConfirmSent({ convKey = "w:Brisa-Horizon", text = "from the blizzard box", outgoing = true }) == false, "matched")
  local filed = S.Get("w:Brisa-Horizon").messages[3]
  check("filed echo is outgoing and sent",
        filed.text == "from the blizzard box" and filed.status == "sent" and filed.outgoing, filed.status)
  check("echo into an unknown conversation opens it",
        S.ConfirmSent({ convKey = "w:New-Horizon", text = "hello", outgoing = true }) == false and S.Get("w:New-Horizon") ~= nil,
        "not opened")

  local p3 = S.AddPending("w:Brisa-Horizon", "third")
  local p4 = S.AddPending("w:Brisa-Horizon", "fourth")
  check("failure marks the newest pending",
        S.MarkFailed("w:Brisa-Horizon") == p4 and p4.status == "failed" and p3.status == "pending", p4.status)
  check("failure with nothing to fail is nil", S.MarkFailed("w:Nobody-Horizon") == nil, "not nil")
  S.Reset()
`, 'store-outgoing');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`
Expected: exit 1 with `store-outgoing: … attempt to call a nil value (field 'AddPending')`.

- [ ] **Step 3: Implement**

Insert into `modules/Echo/EchoStore.lua` directly above `--- Forget every conversation`:

```lua
--- File an outgoing message before the server confirms it.
-- @param convKey string
-- @param text string
-- @return table|nil record  status "pending"
function Store.AddPending(convKey, text)
    local record = { convKey = convKey, text = text, outgoing = true, status = "pending" }
    if not Store.Add(record) then return nil end
    return record
end

local function OldestPending(conv, text, anyText)
    for _, m in ipairs(conv.messages) do
        if m.status == "pending" and (anyText or m.text == text) then return m end
    end
    return nil
end

--- Confirm an outgoing message from its echo (an _INFORM event, or your own line in a
-- group channel). Matches the oldest pending message with the same text. A secret echo
-- cannot be compared, so it confirms the oldest pending one. With nothing pending, the
-- message was typed into Blizzard's chat box, so it is filed as a new outgoing message.
-- @param record table  Outgoing record built by EchoEvents
-- @return boolean matched
function Store.ConfirmSent(record)
    local conv = conversations[record.convKey]
    local pending = conv and OldestPending(conv, record.text, record.secret)
    if not pending then
        record.status = "sent"
        Store.Add(record)
        return false
    end
    pending.status = "sent"
    Persist(pending)
    Notify(record.convKey, "update")
    return true
end

--- Mark the newest pending message in a conversation as failed.
-- @param convKey string
-- @return table|nil record
function Store.MarkFailed(convKey)
    local conv = conversations[convKey]
    if not conv then return nil end
    for i = #conv.messages, 1, -1 do
        local m = conv.messages[i]
        if m.status == "pending" then
            m.status = "failed"
            Notify(convKey, "update")
            return m
        end
    end
    return nil
end
```

- [ ] **Step 4: Run the tests and confirm they pass**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`
Expected: `73 passed, 0 failed`.

- [ ] **Step 5: Commit**

```bash
git add modules/Echo/EchoStore.lua tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): track pending, sent and failed outgoing messages" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: Whisper history

**Files:**
- Create: `modules/Echo/EchoHistory.lua`
- Modify: `HorizonSuite.toc` (after `modules/Echo/EchoStore.lua`)
- Test: `tools/test_echo_logic.js` (add the file to `FILES`, plus a new section)

**Interfaces:**
- Consumes: `Echo.Store.KindOf`, `Echo.IsSecret`. Store already calls `Echo.History.Load` / `Echo.History.Append` when `Echo.History` exists (Task 2).
- Produces: `History.Bind(db, characterKeyFn)`; `History.Unbind()`; `History.SetEnabledCheck(fn)`; `History.Append(convKey, record) -> boolean`; `History.Load(convKey) -> record[]`; `History.Clear()`; `History.CAP`.
- Saved shape: `db.echoHistory = { chars = { ["Name-Realm"] = { [convKey] = { {t, out, text}… } } }, bnet = { [convKey] = { … } } }`.
- `characterKeyFn` returns `"Name-Realm"`, or nil before the realm is known (Forever before `PLAYER_LOGIN`). In game it is `addon._GetCurrentCharacterProfileKey`.

- [ ] **Step 1: Write the failing tests**

In `tools/test_echo_logic.js`, extend `FILES`:

```js
const FILES = [
  'modules/Echo/EchoStore.lua',
  'modules/Echo/EchoHistory.lua',
];
```

Insert before `// --- Summary`:

```js
// --- History ---------------------------------------------------------------------------
run(`
  local S, H = HorizonSuite.Echo.Store, HorizonSuite.Echo.History
  S.Reset()
  local db = {}
  local charKey = "Kaelis-Horizon"
  H.Bind(db, function() return charKey end)
  check("bind creates the root",
        type(db.echoHistory) == "table" and type(db.echoHistory.chars) == "table" and type(db.echoHistory.bnet) == "table",
        "missing")

  S.Add({ convKey = "w:Brisa-Horizon", text = "got the leather" })
  S.Add({ convKey = "w:Brisa-Horizon", text = SECRET("mid-pull"), secret = true })
  S.Add({ convKey = "bn:77", text = "bnet hi" })
  S.Add({ convKey = "guild", text = "guild line" })
  S.Add({ convKey = "w:Demo-Horizon", text = "demo", demo = true })
  S.AddPending("w:Brisa-Horizon", "on my way")

  local mine = db.echoHistory.chars["Kaelis-Horizon"]
  local brisa = mine and mine["w:Brisa-Horizon"]
  check("whisper persisted per character", brisa and brisa[1].text == "got the leather", brisa and #brisa)
  check("secret and pending messages not persisted", brisa and #brisa == 1, brisa and #brisa)
  check("bnet persisted account-wide",
        db.echoHistory.bnet["bn:77"] and db.echoHistory.bnet["bn:77"][1].text == "bnet hi", "missing")
  check("channels not persisted", mine["guild"] == nil, "persisted")
  check("demo messages not persisted", mine["w:Demo-Horizon"] == nil, "persisted")

  S.ConfirmSent({ convKey = "w:Brisa-Horizon", text = "on my way", outgoing = true })
  check("a confirmed message is persisted as outgoing",
        #brisa == 2 and brisa[2].out == true and brisa[2].text == "on my way", #brisa)

  S.AddPending("w:Brisa-Horizon", "lost")
  S.MarkFailed("w:Brisa-Horizon")
  check("a failed message is not persisted", #brisa == 2, #brisa)

  for i = 1, 120 do H.Append("w:Cap-Horizon", { text = "m" .. i, time = i }) end
  local capped = mine["w:Cap-Horizon"]
  check("history capped at 100, oldest dropped", #capped == 100 and capped[1].text == "m21", #capped)

  -- Next session: a fresh store seeds a whisper conversation from history.
  S.Reset()
  S.Add({ convKey = "w:Brisa-Horizon", text = "you there?" })
  local msgs = S.Get("w:Brisa-Horizon").messages
  check("history seeds a reopened whisper",
        #msgs == 3 and msgs[1].fromHistory and msgs[3].text == "you there?", #msgs)
  check("seeded outgoing keeps its direction", msgs[2].outgoing == true and msgs[2].status == "sent", tostring(msgs[2].outgoing))

  charKey = "Alt-Horizon"
  S.Reset()
  S.Add({ convKey = "w:Brisa-Horizon", text = "hello alt" })
  check("whisper history is per character", #S.Get("w:Brisa-Horizon").messages == 1, #S.Get("w:Brisa-Horizon").messages)
  S.Add({ convKey = "bn:77", text = "again" })
  check("bnet history follows the account", #S.Get("bn:77").messages == 2, #S.Get("bn:77").messages)

  charKey = nil
  check("no character key yet, no whisper written", H.Append("w:Early-Horizon", { text = "x", time = 1 }) == false, "written")
  charKey = "Kaelis-Horizon"

  H.SetEnabledCheck(function() return false end)
  check("history off writes nothing", H.Append("w:Brisa-Horizon", { text = "x", time = 1 }) == false, "written")
  H.SetEnabledCheck(function() return true end)

  H.Clear()
  check("clear wipes everything", next(db.echoHistory.chars) == nil and next(db.echoHistory.bnet) == nil, "not wiped")
  H.Unbind()
  check("unbound history writes nothing", H.Append("w:Brisa-Horizon", { text = "x", time = 1 }) == false, "written")
  S.Reset()
`, 'history');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`
Expected: exit 1 with `ENOENT` for `modules/Echo/EchoHistory.lua`.

- [ ] **Step 3: Create `modules/Echo/EchoHistory.lua`**

```lua
--[[
    Horizon Suite - Echo - History
    Whisper history in HorizonDB.echoHistory: per character for whispers, account-wide
    for Battle.net (names resolve fresh each session; only the account ID is keyed).
    Never writes secret, pending, failed or demo messages. Channels are never persisted.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local History = {}
Echo.History = History

History.CAP = 100

local root
local characterKey = function() return nil end
local enabledCheck = function() return true end

--- Attach to the SavedVariables root.
-- @param db table  HorizonDB
-- @param keyFn function  Returns "Name-Realm", or nil while the realm is unknown
function History.Bind(db, keyFn)
    if type(db) ~= "table" then return end
    db.echoHistory = db.echoHistory or {}
    root = db.echoHistory
    root.chars = root.chars or {}
    root.bnet = root.bnet or {}
    if type(keyFn) == "function" then characterKey = keyFn end
end

function History.Unbind()
    root = nil
end

--- Options (plan 3) supplies the "Save whisper history" setting through this.
-- @param fn function  Returns true when history may be written
function History.SetEnabledCheck(fn)
    if type(fn) == "function" then enabledCheck = fn end
end

local function Bucket(convKey, create)
    if not root then return nil end
    local kind = Echo.Store.KindOf(convKey)
    local parent
    if kind == "bnet" then
        parent = root.bnet
    elseif kind == "whisper" then
        local charKey = characterKey()
        if not charKey then return nil end
        parent = root.chars[charKey]
        if not parent and create then
            parent = {}
            root.chars[charKey] = parent
        end
    end
    if not parent then return nil end
    local list = parent[convKey]
    if not list and create then
        list = {}
        parent[convKey] = list
    end
    return list
end

--- Persist one whisper. Rejections are silent: the message still shows this session.
-- @param convKey string
-- @param record table
-- @return boolean written
function History.Append(convKey, record)
    if not root or not enabledCheck() then return false end
    if record.secret or record.demo then return false end
    if record.status == "pending" or record.status == "failed" then return false end
    if Echo.IsSecret(record.text) or type(record.text) ~= "string" then return false end
    local list = Bucket(convKey, true)
    if not list then return false end
    list[#list + 1] = { t = record.time, out = record.outgoing and true or nil, text = record.text }
    while #list > History.CAP do table.remove(list, 1) end
    return true
end

--- Saved messages for a conversation, oldest first, as Store records.
-- @param convKey string
-- @return table records  empty when there is no history
function History.Load(convKey)
    local out = {}
    local list = Bucket(convKey, false)
    if not list then return out end
    for i, entry in ipairs(list) do
        out[i] = {
            convKey     = convKey,
            text        = entry.text,
            time        = entry.t,
            outgoing    = entry.out == true,
            status      = entry.out and "sent" or nil,
            fromHistory = true,
            seq         = 0,
        }
    end
    return out
end

--- Wipe all saved whispers, for every character and Battle.net.
function History.Clear()
    if not root then return end
    root.chars = {}
    root.bnet = {}
end
```

The cap is applied on every write, so the file can never grow past it. That meets the spec's "capped at 100 … trimmed on `PLAYER_LOGOUT`" without a logout handler.

- [ ] **Step 4: Add to the TOC**

In `HorizonSuite.toc`, after `modules/Echo/EchoStore.lua`:

```
modules/Echo/EchoHistory.lua
```

- [ ] **Step 5: Run the tests and confirm they pass**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`
Expected: `90 passed, 0 failed`.

- [ ] **Step 6: Commit**

```bash
git add modules/Echo/EchoHistory.lua HorizonSuite.toc tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): persist whisper history per character and battle.net account" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 5: Event intake and secret-value rules

**Files:**
- Create: `modules/Echo/EchoEvents.lua`
- Modify: `HorizonSuite.toc` (after `modules/Echo/EchoHistory.lua`)
- Test: `tools/test_echo_logic.js` (add to `FILES`, new section)

**Interfaces:**
- Consumes: `Store.EVENT_KIND`, `Store.KeyFor`, `Store.Now`, `Store.Add`, `Store.ConfirmSent`, `Store.MarkFailed`, `Store.CountUnrouted`, `Echo.IsSecret`, `addon.Platform.Has`.
- Produces: `Events.NormaliseName(name) -> "Name-Realm"|nil`; `Events.PlayerKey() -> string|nil`; `Events.IsMention(text) -> boolean`; `Events.keywords` (array, filled by options in plan 3); `Events.BuildRecord(event, ...) -> record|nil, reason` where reason is `"ignored"` or `"unrouted"`; `Events.Dispatch(event, ...)`; `Events.OnSystemMessage(text)`; `Events.Enable()`; `Events.Disable()`.
- `CHAT_MSG_*` argument positions used: 1 text, 2 sender, 9 channelBaseName, 12 guid, 13 bnSenderID.
- Record fields produced: `convKey`, `text`, `secret`, `outgoing`, `class`, `time`, `sender` (incoming only; for BNet it is the protected `|K` display string), `urgent`.

- [ ] **Step 1: Write the failing tests**

Extend `FILES`:

```js
const FILES = [
  'modules/Echo/EchoStore.lua',
  'modules/Echo/EchoHistory.lua',
  'modules/Echo/EchoEvents.lua',
];
```

Insert before `// --- Summary`:

```js
// --- Events: records, secrets, mentions, dispatch ---------------------------------------
run(`
  local S, E = HorizonSuite.Echo.Store, HorizonSuite.Echo.Events
  S.Reset()

  check("bare name gets the player's realm", E.NormaliseName("Brisa") == "Brisa-Horizon", E.NormaliseName("Brisa"))
  check("name with a realm is unchanged", E.NormaliseName("Brisa-Argent") == "Brisa-Argent", E.NormaliseName("Brisa-Argent"))
  check("secret name has no key", E.NormaliseName(SECRET("Brisa")) == nil, "keyed")
  check("player key", E.PlayerKey() == "Kaelis-Horizon", E.PlayerKey())

  -- CHAT_MSG_* payload: text, sender, 3-8, channelBaseName (9), 10-11, guid (12), bnSenderID (13).
  local function payload(text, sender, channel, guid, bnID)
    return text, sender, nil, nil, nil, nil, nil, nil, channel, nil, nil, guid, bnID
  end

  local r = E.BuildRecord("CHAT_MSG_WHISPER", payload("hi", "Brisa-Horizon", nil, "Player-1-DRUID"))
  check("whisper record key", r and r.convKey == "w:Brisa-Horizon", r and r.convKey)
  check("whisper sender", r.sender == "Brisa-Horizon", r.sender)
  check("class from GUID", r.class == "DRUID", r.class)
  check("incoming is not outgoing", r.outgoing == false, r.outgoing)
  check("readable text is not secret", r.secret == false, r.secret)

  r = E.BuildRecord("CHAT_MSG_WHISPER_INFORM", payload("sure", "Brisa-Horizon"))
  check("inform is outgoing, keyed by the recipient",
        r.outgoing == true and r.convKey == "w:Brisa-Horizon" and r.sender == nil, r.convKey)

  r = E.BuildRecord("CHAT_MSG_BN_WHISPER", payload("yo", "|Kq1|k", nil, nil, 77))
  check("bnet keyed by account id", r.convKey == "bn:77", r.convKey)
  check("bnet keeps the protected name for display", r.sender == "|Kq1|k", r.sender)

  r = E.BuildRecord("CHAT_MSG_CHANNEL", payload("wts", "Seller-Horizon", "Trade"))
  check("channel keyed by base name", r.convKey == "ch:Trade", r.convKey)

  r = E.BuildRecord("CHAT_MSG_RAID_LEADER", payload("pull", "Lead-Horizon"))
  check("leader folds into raid", r.convKey == "raid", r.convKey)
  r = E.BuildRecord("CHAT_MSG_RAID_WARNING", payload("MOVE", "Lead-Horizon"))
  check("raid warning is urgent", r.urgent == true, r.urgent)
  r = E.BuildRecord("CHAT_MSG_PARTY", payload("KAELIS heal pls", "Tank-Horizon"))
  check("mention of the player is urgent, any case", r.urgent == true, r.urgent)
  r = E.BuildRecord("CHAT_MSG_PARTY", payload("pull in 3", "Tank-Horizon"))
  check("ordinary party line is not urgent", r.urgent == false, r.urgent)
  r = E.BuildRecord("CHAT_MSG_GUILD", payload("kaelis gz", "Friend-Horizon"))
  check("mentions only upgrade party, raid and instance", r.urgent == false, r.urgent)
  E.keywords = { "healer" }
  r = E.BuildRecord("CHAT_MSG_INSTANCE_CHAT", payload("need a HEALER", "Tank-Horizon"))
  check("keyword mention is urgent", r.urgent == true, r.urgent)
  E.keywords = {}

  r = E.BuildRecord("CHAT_MSG_PARTY", payload("on my way", "Kaelis-Horizon"))
  check("own line in a group channel is outgoing", r.outgoing == true, r.outgoing)
  r = E.BuildRecord("CHAT_MSG_PARTY", payload("on my way", "Kaelis"))
  check("own line without a realm is outgoing", r.outgoing == true, r.outgoing)

  -- Secret values: spec "Secret-value rules".
  r = E.BuildRecord("CHAT_MSG_WHISPER", payload(SECRET("boss plan"), "Brisa-Horizon"))
  check("secret text is still routed", r and r.convKey == "w:Brisa-Horizon", r and r.convKey)
  check("secret text is flagged", r.secret == true, r.secret)
  r = E.BuildRecord("CHAT_MSG_PARTY", payload(SECRET("kaelis"), "Tank-Horizon"))
  check("secret text is never a mention", r.urgent == false, r.urgent)
  local none, reason = E.BuildRecord("CHAT_MSG_WHISPER", payload("hi", SECRET("Brisa-Horizon")))
  check("secret whisper sender is unrouted", none == nil and reason == "unrouted", reason)
  none, reason = E.BuildRecord("CHAT_MSG_BN_WHISPER", payload("hi", "|Kq1|k", nil, nil, SECRET(77)))
  check("secret bnet id is unrouted", none == nil and reason == "unrouted", reason)
  r = E.BuildRecord("CHAT_MSG_RAID", payload("go", SECRET("Lead-Horizon")))
  check("secret sender in a group channel still routes", r and r.convKey == "raid" and r.sender == nil, r and r.convKey)
  r = E.BuildRecord("CHAT_MSG_WHISPER", payload("hi", "Brisa-Horizon", nil, SECRET("Player-1-DRUID")))
  check("secret GUID gives no class", r.class == nil, r.class)
  none, reason = E.BuildRecord("CHAT_MSG_SAY", payload("hi", "A-B"))
  check("non-Echo event is ignored", none == nil and reason == "ignored", reason)

  S.Reset()
  E.Dispatch("CHAT_MSG_WHISPER", payload("hi", "Brisa-Horizon"))
  check("dispatch files incoming", S.Get("w:Brisa-Horizon") and S.Get("w:Brisa-Horizon").unread == 1, "not filed")
  E.Dispatch("CHAT_MSG_WHISPER", payload("hi", SECRET("Who")))
  check("dispatch counts unrouted", S.GetUnroutedCount() == 1, S.GetUnroutedCount())
  local p = S.AddPending("w:Brisa-Horizon", "sure")
  E.Dispatch("CHAT_MSG_WHISPER_INFORM", payload("sure", "Brisa-Horizon"))
  check("the inform echo confirms a pending reply", p.status == "sent", p.status)
  local q = S.AddPending("w:Ghost-Horizon", "hello?")
  E.Dispatch("CHAT_MSG_SYSTEM", "No player named 'Ghost' is currently playing.")
  check("player-not-found fails the pending whisper", q.status == "failed", q.status)
  local q2 = S.AddPending("w:Ghost-Horizon", "again?")
  E.Dispatch("CHAT_MSG_SYSTEM", "You feel rested.")
  check("other system messages are ignored", q2.status == "pending", q2.status)
  E.Dispatch("CHAT_MSG_SYSTEM", SECRET("No player named 'Ghost' is currently playing."))
  check("a secret system message is ignored", q2.status == "pending", q2.status)

  local registered = {}
  CreateFrame = function()
    return { SetScript = function() end,
             RegisterEvent = function(_, e) registered[e] = true end,
             UnregisterAllEvents = function() registered = {} end }
  end
  E.Enable()
  check("enable registers chat and system events",
        registered.CHAT_MSG_WHISPER and registered.CHAT_MSG_CHANNEL and registered.CHAT_MSG_SYSTEM, "missing")
  check("enable registers bnet when the platform has it", registered.CHAT_MSG_BN_WHISPER == true, "missing")
  E.Disable()
  check("disable unregisters", next(registered) == nil, "still registered")
  HorizonSuite.Platform.caps.bnetWhispers = false
  E.Enable()
  check("no bnet events without the capability",
        registered.CHAT_MSG_BN_WHISPER == nil and registered.CHAT_MSG_WHISPER == true, "registered")
  E.Disable()
  HorizonSuite.Platform.caps.bnetWhispers = true
  S.Reset()
`, 'events');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`
Expected: exit 1 with `ENOENT` for `modules/Echo/EchoEvents.lua`.

- [ ] **Step 3: Create `modules/Echo/EchoEvents.lua`**

```lua
--[[
    Horizon Suite - Echo - Events
    Turns CHAT_MSG_* payloads into message records and hands them to the Store.
    All of Echo's secret-value handling lives here (spec: Intake and secret values):
      - sender readable, text secret: routed, flagged secret, never persisted
      - sender secret on a whisper: no conversation; counted as unrouted
    Blizzard: CHAT_MSG_* events, GetPlayerInfoByGUID, GetNormalizedRealmName,
    ERR_CHAT_PLAYER_NOT_FOUND_S.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo
local Store = Echo.Store
local IsSecret = Echo.IsSecret

local Events = {}
Echo.Events = Events

-- Extra mention words (case-insensitive). Options fill this in plan 3.
Events.keywords = {}

local OUTGOING_EVENTS = {
    CHAT_MSG_WHISPER_INFORM    = true,
    CHAT_MSG_BN_WHISPER_INFORM = true,
}
local MENTION_KINDS = { party = true, raid = true, instance = true }

--- "Name" -> "Name-Realm"; a name that already carries a realm is unchanged.
-- @param name string
-- @return string|nil  nil for secret, empty or non-string names
function Events.NormaliseName(name)
    if IsSecret(name) or type(name) ~= "string" or name == "" then return nil end
    if name:find("-", 1, true) then return name end
    local realm = GetNormalizedRealmName and GetNormalizedRealmName()
    if type(realm) == "string" and realm ~= "" then return name .. "-" .. realm end
    return name
end

--- @return string|nil  The player's "Name-Realm"
function Events.PlayerKey()
    return Events.NormaliseName(UnitName and UnitName("player"))
end

local function ClassFromGUID(guid)
    if IsSecret(guid) or type(guid) ~= "string" or not GetPlayerInfoByGUID then return nil end
    local ok, _, englishClass = pcall(GetPlayerInfoByGUID, guid)
    if ok and type(englishClass) == "string" then return englishClass end
    return nil
end

--- True when readable text names the player or a configured keyword. Case-insensitive.
-- @param text string
-- @return boolean
function Events.IsMention(text)
    if IsSecret(text) or type(text) ~= "string" then return false end
    local lower = text:lower()
    local me = UnitName and UnitName("player")
    if type(me) == "string" and me ~= "" and lower:find(me:lower(), 1, true) then return true end
    for _, word in ipairs(Events.keywords) do
        if type(word) == "string" and word ~= "" and lower:find(word:lower(), 1, true) then return true end
    end
    return false
end

--- Build a message record from a CHAT_MSG_* payload.
-- @return table|nil record
-- @return string|nil reason  "ignored" (not an Echo event) | "unrouted" (no conversation can be chosen)
function Events.BuildRecord(event, text, sender, _, _, _, _, _, _, channelBaseName, _, _, guid, bnSenderID)
    local kind = Store.EVENT_KIND[event]
    if not kind then return nil, "ignored" end

    local id
    if kind == "whisper" then
        id = Events.NormaliseName(sender)
    elseif kind == "bnet" then
        if not IsSecret(bnSenderID) then id = bnSenderID end
    elseif kind == "channel" then
        if not IsSecret(channelBaseName) then id = channelBaseName end
    end
    local convKey = Store.KeyFor(kind, id)
    if not convKey then return nil, "unrouted" end

    local senderKey = (kind ~= "bnet") and Events.NormaliseName(sender) or nil
    local outgoing = OUTGOING_EVENTS[event] == true
        or (kind ~= "whisper" and kind ~= "bnet" and senderKey ~= nil and senderKey == Events.PlayerKey())

    local textSecret = IsSecret(text)
    local record = {
        convKey  = convKey,
        text     = text,
        secret   = textSecret,
        outgoing = outgoing,
        class    = (not outgoing) and ClassFromGUID(guid) or nil,
        time     = Store.Now(),
    }
    if not outgoing then
        if kind == "bnet" then
            -- Protected |K display string: safe to SetText, never stored.
            if not IsSecret(sender) then record.sender = sender end
        else
            record.sender = senderKey
        end
    end
    record.urgent = (event == "CHAT_MSG_RAID_WARNING")
        or (MENTION_KINDS[kind] == true and not outgoing and not textSecret and Events.IsMention(text))
    return record
end

local notFoundPattern
local function NotFoundPattern()
    if notFoundPattern == nil then
        local fmt = ERR_CHAT_PLAYER_NOT_FOUND_S
        if type(fmt) == "string" and fmt:find("%s", 1, true) then
            local escaped = fmt:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0")
            notFoundPattern = "^" .. escaped:gsub("%%%%s", "(.+)", 1) .. "$"
        else
            notFoundPattern = false
        end
    end
    return notFoundPattern
end

--- Mark the pending whisper to a player who is not online as failed.
-- @param text string  CHAT_MSG_SYSTEM message
function Events.OnSystemMessage(text)
    if IsSecret(text) or type(text) ~= "string" then return end
    local pattern = NotFoundPattern()
    if not pattern then return end
    local name = text:match(pattern)
    local convKey = name and Store.KeyFor("whisper", Events.NormaliseName(name))
    if convKey then Store.MarkFailed(convKey) end
end

--- Route one chat event. Exposed for tests and the probe.
function Events.Dispatch(event, ...)
    if event == "CHAT_MSG_SYSTEM" then
        Events.OnSystemMessage((...))
        return
    end
    local record, reason = Events.BuildRecord(event, ...)
    if not record then
        if reason == "unrouted" then Store.CountUnrouted() end
        return
    end
    if record.outgoing then
        Store.ConfirmSent(record)
    else
        Store.Add(record)
    end
end

local frame

function Events.Enable()
    if not frame then
        frame = CreateFrame("Frame")
        frame:SetScript("OnEvent", function(_, event, ...) Events.Dispatch(event, ...) end)
    end
    local hasBnet = addon.Platform and addon.Platform.Has("bnetWhispers")
    for event, kind in pairs(Store.EVENT_KIND) do
        if kind ~= "bnet" or hasBnet then frame:RegisterEvent(event) end
    end
    frame:RegisterEvent("CHAT_MSG_SYSTEM")
end

function Events.Disable()
    if frame then frame:UnregisterAllEvents() end
end
```

In the test, `CreateFrame` is stubbed after the file loads. That works because `Events.Enable` looks the global up at call time.

- [ ] **Step 4: Add to the TOC**

After `modules/Echo/EchoHistory.lua`:

```
modules/Echo/EchoEvents.lua
```

- [ ] **Step 5: Run the tests and confirm they pass**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`
Expected: `129 passed, 0 failed`.

- [ ] **Step 6: Commit**

```bash
git add modules/Echo/EchoEvents.lua HorizonSuite.toc tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): build message records from chat events with secret-value rules" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 6: Sending replies

**Files:**
- Create: `modules/Echo/EchoSend.lua`
- Modify: `HorizonSuite.toc` (after `modules/Echo/EchoEvents.lua`)
- Test: `tools/test_echo_logic.js` (add to `FILES`, new section)

**Interfaces:**
- Consumes: `Store.KindOf`, `Store.AddPending`, `Store.MarkFailed`.
- Produces: `Send.RouteFor(convKey) -> {chatType, target}|nil`; `Send.Split(text, limit?) -> string[]`; `Send.Resolve() -> sendChat|nil, sendBN|nil`; `Send.Send(convKey, text) -> boolean`; `Send.MAX_BYTES` (255).
- Send signatures assumed (Task 8 verifies them): `sendChat(message, chatType, languageID, target)` and `sendBN(bnetAccountID, message)`.

- [ ] **Step 1: Write the failing tests**

Extend `FILES`:

```js
const FILES = [
  'modules/Echo/EchoStore.lua',
  'modules/Echo/EchoHistory.lua',
  'modules/Echo/EchoEvents.lua',
  'modules/Echo/EchoSend.lua',
];
```

Insert before `// --- Summary`:

```js
// --- Send: routes, splitting, sending ---------------------------------------------------
run(`
  local S, Send = HorizonSuite.Echo.Store, HorizonSuite.Echo.Send
  S.Reset()
  GetChannelName = function(name) if name == "Trade" then return 2, "Trade - City" end return 0 end
  local function route(key)
    local r = Send.RouteFor(key)
    return r and (r.chatType .. ":" .. tostring(r.target)) or "none"
  end
  check("whisper route", route("w:Brisa-Horizon") == "WHISPER:Brisa-Horizon", route("w:Brisa-Horizon"))
  check("bnet route uses the numeric id",
        route("bn:77") == "BN_WHISPER:77" and type(Send.RouteFor("bn:77").target) == "number", route("bn:77"))
  check("party route", route("party") == "PARTY:nil", route("party"))
  check("instance route", route("instance") == "INSTANCE_CHAT:nil", route("instance"))
  check("channel route uses the joined index", route("ch:Trade") == "CHANNEL:2", route("ch:Trade"))
  check("a channel you left cannot be sent to", route("ch:Gone") == "none", route("ch:Gone"))
  check("a bad key cannot be sent to", route("nope") == "none", route("nope"))

  local parts = Send.Split("  hello  ")
  check("short text trimmed, one part", #parts == 1 and parts[1] == "hello", parts[1])
  check("blank text has no parts", #Send.Split("   ") == 0, #Send.Split("   "))
  parts = Send.Split("aaa bbb ccc", 7)
  check("splits at the last space that fits",
        #parts == 2 and parts[1] == "aaa bbb" and parts[2] == "ccc", table.concat(parts, "|"))
  local link = "|cffa335ee|Hitem:1::|h[Cloak of the Wind]|h|r"
  parts = Send.Split("loot " .. link .. " is mine", 45)
  check("never splits inside a link", #parts == 3 and parts[2] == link, table.concat(parts, " / "))
  parts = Send.Split("ééééé", 5)
  check("a hard cut never splits a UTF-8 character",
        #parts == 3 and parts[1] == "éé" and parts[3] == "é", table.concat(parts, "|"))

  local sent = {}
  C_ChatInfo = { SendChatMessage = function(msg, chatType, lang, target)
    sent[#sent + 1] = chatType .. ":" .. tostring(target) .. ":" .. msg end }
  BNSendWhisper = function(id, msg) sent[#sent + 1] = "BN:" .. id .. ":" .. msg end

  check("send whisper", Send.Send("w:Brisa-Horizon", "sure") == true and sent[1] == "WHISPER:Brisa-Horizon:sure", sent[1])
  local first = S.Get("w:Brisa-Horizon").messages[1]
  check("a sent whisper waits as pending", first.status == "pending" and first.outgoing, first.status)
  check("send bnet", Send.Send("bn:77", "yo") and sent[2] == "BN:77:yo", sent[2])
  check("send party", Send.Send("party", "omw") and sent[3] == "PARTY:nil:omw", sent[3])
  check("blank text is not sent", Send.Send("party", "   ") == false and #sent == 3, #sent)
  check("an unroutable key is not sent", Send.Send("ch:Gone", "x") == false and #sent == 3, #sent)

  Send.MAX_BYTES = 7
  Send.Send("party", "aaa bbb ccc")
  check("long text goes out in parts",
        sent[4] == "PARTY:nil:aaa bbb" and sent[5] == "PARTY:nil:ccc", tostring(sent[4]) .. "/" .. tostring(sent[5]))
  Send.MAX_BYTES = 255

  C_ChatInfo.SendChatMessage = function() error("blocked") end
  Send.Send("w:Brisa-Horizon", "again")
  local msgs = S.Get("w:Brisa-Horizon").messages
  check("a send that throws is marked failed", msgs[#msgs].status == "failed", msgs[#msgs].status)

  C_ChatInfo = nil
  SendChatMessage = function(msg, chatType) sent[#sent + 1] = "LEGACY:" .. chatType .. ":" .. msg end
  Send.Send("guild", "hi")
  check("falls back to the global send function", sent[#sent] == "LEGACY:GUILD:hi", sent[#sent])
  S.Reset()
`, 'send');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`
Expected: exit 1 with `ENOENT` for `modules/Echo/EchoSend.lua`.

- [ ] **Step 3: Create `modules/Echo/EchoSend.lua`**

```lua
--[[
    Horizon Suite - Echo - Send
    The one place Echo sends chat. Maps a conversation key to a chat type and target,
    splits long text at spaces outside links, and files each part as pending until
    EchoEvents sees the echo. Blizzard: C_ChatInfo.SendChatMessage (or SendChatMessage),
    BNSendWhisper (or C_BattleNet.SendWhisper), GetChannelName.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo
local Store = Echo.Store

local Send = {}
Echo.Send = Send

Send.MAX_BYTES = 255

local GROUP_CHAT_TYPE = {
    party    = "PARTY",
    raid     = "RAID",
    instance = "INSTANCE_CHAT",
    guild    = "GUILD",
    officer  = "OFFICER",
}

--- Where a reply to this conversation goes.
-- @param convKey string
-- @return table|nil route  { chatType = string, target = string|number|nil }
function Send.RouteFor(convKey)
    local kind = Store.KindOf(convKey)
    if kind == "whisper" then
        return { chatType = "WHISPER", target = convKey:sub(3) }
    elseif kind == "bnet" then
        local id = tonumber(convKey:sub(4))
        return id and { chatType = "BN_WHISPER", target = id } or nil
    elseif kind == "channel" then
        local index = GetChannelName and GetChannelName(convKey:sub(4))
        if type(index) ~= "number" or index == 0 then return nil end
        return { chatType = "CHANNEL", target = index }
    elseif GROUP_CHAT_TYPE[kind] then
        return { chatType = GROUP_CHAT_TYPE[kind] }
    end
    return nil
end

local function LinkRanges(text)
    local ranges, init = {}, 1
    while true do
        local s, e = text:find("|H.-|h.-|h", init)
        if not s then break end
        ranges[#ranges + 1] = { s, e }
        init = e + 1
    end
    return ranges
end

local function InsideLink(ranges, pos)
    for _, r in ipairs(ranges) do
        if pos >= r[1] and pos <= r[2] then return true end
    end
    return false
end

--- Split text into parts of at most limit bytes, breaking at spaces outside links.
-- @param text string
-- @param limit number|nil  Defaults to Send.MAX_BYTES
-- @return table parts  empty when text is blank
function Send.Split(text, limit)
    limit = limit or Send.MAX_BYTES
    local parts = {}
    text = (text:gsub("^%s+", ""):gsub("%s+$", ""))
    while #text > limit do
        local ranges = LinkRanges(text)
        local cut
        for pos = limit + 1, 2, -1 do
            if text:sub(pos, pos):match("%s") and not InsideLink(ranges, pos) then
                cut = pos
                break
            end
        end
        if cut then
            parts[#parts + 1] = (text:sub(1, cut - 1):gsub("%s+$", ""))
            text = (text:sub(cut + 1):gsub("^%s+", ""))
        else
            -- No usable space: hard cut, backing off so a UTF-8 character is never split.
            local stop = limit
            while stop > 1 do
                local b = text:byte(stop + 1)
                if not b or b < 0x80 or b >= 0xC0 then break end
                stop = stop - 1
            end
            parts[#parts + 1] = text:sub(1, stop)
            text = text:sub(stop + 1)
        end
    end
    if text ~= "" then parts[#parts + 1] = text end
    return parts
end

--- The client's send functions, looked up per call so tests and late-loading clients agree.
-- @return function|nil sendChat, function|nil sendBN
function Send.Resolve()
    local sendChat = (C_ChatInfo and C_ChatInfo.SendChatMessage) or SendChatMessage
    local sendBN = BNSendWhisper or (C_BattleNet and C_BattleNet.SendWhisper)
    return sendChat, sendBN
end

--- Send a reply. Each part is filed as pending; the echo marks it sent.
-- @param convKey string
-- @param text string
-- @return boolean sent  false when there was nothing to send or nowhere to send it
function Send.Send(convKey, text)
    if type(text) ~= "string" then return false end
    local route = Send.RouteFor(convKey)
    if not route then return false end
    local parts = Send.Split(text)
    if #parts == 0 then return false end
    local sendChat, sendBN = Send.Resolve()
    for _, part in ipairs(parts) do
        Store.AddPending(convKey, part)
        local ok
        if route.chatType == "BN_WHISPER" then
            ok = sendBN and pcall(sendBN, route.target, part)
        else
            ok = sendChat and pcall(sendChat, part, route.chatType, nil, route.target)
        end
        if not ok then Store.MarkFailed(convKey) end
    end
    return true
end
```

- [ ] **Step 4: Add to the TOC**

After `modules/Echo/EchoEvents.lua`:

```
modules/Echo/EchoSend.lua
```

- [ ] **Step 5: Run the tests and confirm they pass**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`
Expected: `150 passed, 0 failed`.

- [ ] **Step 6: Commit**

```bash
git add modules/Echo/EchoSend.lua HorizonSuite.toc tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): route, split and send replies as pending messages" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 7: Platform keys, module, slash commands and the probe

**Files:**
- Modify: `modules/Echo/EchoEvents.lua` (add the probe)
- Create: `modules/Echo/EchoSlash.lua`
- Create: `modules/Echo/EchoModule.lua`
- Modify: `HorizonSuite.toc` (after `modules/Echo/EchoSend.lua`)
- Modify: `core/Platform.lua` (the `detected` table and `Platform.unverified`)
- Modify: `core/CoreSlash.lua:146` (the help line)
- Test: `tools/test_echo_logic.js` (add `EchoSlash.lua` to `FILES`, new section)

**Interfaces:**
- Consumes: everything above; `addon.RegisterSlashHandler`, `addon.HSPrint`, `addon:RegisterModule`, `addon:SetModuleEnabled`, `addon:IsModuleEnabled`, `addon._GetCurrentCharacterProfileKey`, `addon.DATABASE`.
- Produces: `Events.DescribeArgs(event, ...) -> string`; `Events.StartProbe(count, outFn)`; `Echo.InjectTestConversations()`; `Echo.Init()`; `Echo.Disable()`; Platform keys `bnetWhispers` and `secretChat`; `/h echo` with `toggle | status | probe [n] | test | clearhistory | help`.

- [ ] **Step 1: Write the failing tests**

Extend `FILES`:

```js
const FILES = [
  'modules/Echo/EchoStore.lua',
  'modules/Echo/EchoHistory.lua',
  'modules/Echo/EchoEvents.lua',
  'modules/Echo/EchoSend.lua',
  'modules/Echo/EchoSlash.lua',
];
```

Insert before `// --- Summary`:

```js
// --- Probe and test data -------------------------------------------------------------
run(`
  local S, H, E = HorizonSuite.Echo.Store, HorizonSuite.Echo.History, HorizonSuite.Echo.Events
  S.Reset()

  local line = E.DescribeArgs("CHAT_MSG_WHISPER", "hi", SECRET("Brisa"), nil, nil, nil, nil, nil, nil, nil, nil, nil, "Player-1-DRUID", nil)
  check("probe names the event", line:find("CHAT_MSG_WHISPER", 1, true) == 1, line)
  check("probe reports a secret sender", line:find("sender=SECRET", 1, true) ~= nil, line)
  check("probe reports readable text by type, never its value",
        line:find("text=string", 1, true) ~= nil and line:find("hi", 1, true) == nil, line)
  check("probe reports unrouted", line:find("conv=none/unrouted", 1, true) ~= nil, line)
  line = E.DescribeArgs("CHAT_MSG_CHANNEL", "wts", "Seller-Horizon", nil, nil, nil, nil, nil, nil, "Trade", nil, nil, nil, nil)
  check("probe shows the conversation and route", line:find("conv=ch:Trade route=CHANNEL:2", 1, true) ~= nil, line)

  local out = {}
  E.StartProbe(1, function(s) out[#out + 1] = s end)
  E.Dispatch("CHAT_MSG_GUILD", "gz", "Friend-Horizon", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
  E.Dispatch("CHAT_MSG_GUILD", "again", "Friend-Horizon", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
  check("probe describes only the requested number of messages", #out == 1, #out)
  check("probe does not stop messages being filed", S.Get("guild") and #S.Get("guild").messages == 2, "not filed")

  S.Reset()
  local db = {}
  H.Bind(db, function() return "Kaelis-Horizon" end)
  HorizonSuite.Echo.InjectTestConversations()
  check("test data fills conversations", #S.List() >= 4, #S.List())
  check("test data never reaches history", next(db.echoHistory.chars) == nil, "written")
  H.Unbind()
  S.Reset()
`, 'probe');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`
Expected: exit 1 with `ENOENT` for `modules/Echo/EchoSlash.lua`.

- [ ] **Step 3: Add the probe to `modules/Echo/EchoEvents.lua`**

Insert directly above `--- Route one chat event.`:

```lua
local PROBE_ARGS = { { 1, "text" }, { 2, "sender" }, { 9, "channelBaseName" }, { 12, "guid" }, { 13, "bnSenderID" } }

--- One-line description of a chat payload for the verification probe.
-- Reports only type and secrecy, never values, so it is safe to print mid-encounter.
-- @return string
function Events.DescribeArgs(event, ...)
    local parts = { tostring(event) }
    for _, arg in ipairs(PROBE_ARGS) do
        local v = select(arg[1], ...)
        local state
        if v == nil then
            state = "nil"
        elseif IsSecret(v) then
            state = "SECRET"
        else
            state = type(v)
        end
        parts[#parts + 1] = arg[2] .. "=" .. state
    end
    local record, reason = Events.BuildRecord(event, ...)
    parts[#parts + 1] = "conv=" .. (record and record.convKey or ("none/" .. tostring(reason)))
    if record and Echo.Send then
        local route = Echo.Send.RouteFor(record.convKey)
        parts[#parts + 1] = "route=" .. (route
            and (route.chatType .. (route.target ~= nil and (":" .. tostring(route.target)) or ""))
            or "none")
    end
    return table.concat(parts, " ")
end

--- Describe the next `count` chat messages through outFn (spec: Verification before code).
-- @param count number
-- @param outFn function(string)
function Events.StartProbe(count, outFn)
    Events.probeRemaining = count
    Events.probeOut = outFn
end
```

Then make `Events.Dispatch` describe events while a probe is running. Replace the start of its body:

```lua
function Events.Dispatch(event, ...)
    if event == "CHAT_MSG_SYSTEM" then
```

with:

```lua
function Events.Dispatch(event, ...)
    if (Events.probeRemaining or 0) > 0 and event ~= "CHAT_MSG_SYSTEM" and Events.probeOut then
        Events.probeRemaining = Events.probeRemaining - 1
        Events.probeOut(Events.DescribeArgs(event, ...))
    end
    if event == "CHAT_MSG_SYSTEM" then
```

- [ ] **Step 4: Create `modules/Echo/EchoSlash.lua`**

```lua
--[[
    Horizon Suite - Horizon Echo (Slash)
    /h echo commands: toggle, status, probe, test, clearhistory.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local HSPrint = addon.HSPrint or function(msg) print("|cFF00CCFFHorizon Suite:|r " .. tostring(msg or "")) end

-- Sample conversations for /h echo test. Marked demo, so history never stores them.
local TEST_MESSAGES = {
    { convKey = "w:Brisa-Horizon",     sender = "Brisa-Horizon",     class = "DRUID",  text = "got the leather + threads" },
    { convKey = "w:Brisa-Horizon",     sender = "Brisa-Horizon",     class = "DRUID",  text = "can you craft the cloak if I send mats?" },
    { convKey = "w:Thornwick-Horizon", sender = "Thornwick-Horizon", class = "ROGUE",  text = "summon at the stone?" },
    { convKey = "w:Vexa-Horizon",      sender = "Vexa-Horizon",      class = "EVOKER", text = "gz on the mount!" },
    { convKey = "party",               sender = "Thornwick-Horizon", class = "ROGUE",  text = "ready check in 1" },
    { convKey = "guild",               sender = "Vexa-Horizon",      class = "EVOKER", text = "raid tonight at 8" },
}

function Echo.InjectTestConversations()
    for _, m in ipairs(TEST_MESSAGES) do
        Echo.Store.Add({
            convKey = m.convKey, sender = m.sender, class = m.class, text = m.text, demo = true,
        })
    end
end

local function PrintStatus()
    local Store = Echo.Store
    local list = Store.List()
    HSPrint(("Echo: %d conversations, %d messages left in Blizzard chat (unrouted)"):format(
        #list, Store.GetUnroutedCount()))
    for _, conv in ipairs(list) do
        HSPrint(("  %s  tier=%s unread=%d messages=%d%s"):format(
            conv.key, Store.TierOf(conv.key), conv.unread, #conv.messages, conv.pinned and " pinned" or ""))
    end
end

local function StartProbe(rest)
    local count = tonumber(rest) or 10
    local sendChat, sendBN = Echo.Send.Resolve()
    local Platform = addon.Platform
    HSPrint(("Echo probe: sendChat=%s sendBN=%s secretChat=%s bnetWhispers=%s"):format(
        sendChat and "yes" or "no", sendBN and "yes" or "no",
        tostring(Platform and Platform.Has("secretChat")), tostring(Platform and Platform.Has("bnetWhispers"))))
    Echo.Events.StartProbe(count, HSPrint)
    HSPrint(("Echo probe: describing the next %d chat messages (types only, never text)."):format(count))
end

local function HandleEchoSlash(msg)
    local cmd, rest = strtrim(msg or ""):match("^(%S*)%s*(.-)$")
    cmd = (cmd or ""):lower()

    if cmd == "toggle" then
        if InCombatLockdown() then
            HSPrint("Cannot toggle Echo during combat.")
            return
        end
        addon:SetModuleEnabled("echo", not addon:IsModuleEnabled("echo"))
        return
    end

    if not addon:IsModuleEnabled("echo") then
        HSPrint("Horizon Echo is disabled. Use /h echo toggle to enable it.")
        return
    end

    if cmd == "status" then
        PrintStatus()
    elseif cmd == "probe" then
        StartProbe(rest)
    elseif cmd == "test" then
        Echo.InjectTestConversations()
        HSPrint("Echo: added sample conversations. /h echo status lists them.")
    elseif cmd == "clearhistory" then
        Echo.History.Clear()
        HSPrint("Echo: whisper history cleared for every character.")
    elseif cmd == "" or cmd == "help" then
        HSPrint("Echo commands:")
        HSPrint("  /h echo toggle       - Enable / disable Echo (reloads the UI)")
        HSPrint("  /h echo status       - List conversations, tiers and unread counts")
        HSPrint("  /h echo probe [n]    - Describe the next n chat messages (default 10)")
        HSPrint("  /h echo test         - Add sample conversations")
        HSPrint("  /h echo clearhistory - Delete saved whisper history")
    else
        HSPrint("Unknown command. Use /h echo for help.")
    end
end

if addon.RegisterSlashHandler then
    addon.RegisterSlashHandler("echo", HandleEchoSlash)
end
```

- [ ] **Step 5: Create `modules/Echo/EchoModule.lua`**

```lua
--[[
    Horizon Suite - Horizon Echo Module
    Conversation-first chat: whispers and group channels as tiles you reply from.
    Blizzard's chat frames stay underneath as the source of truth.
    Design: Docs/Engineering/2026-09-24-echo-chat-design.md
    Registers with addon:RegisterModule.
]]

local addon = _G.HorizonSuite
if not addon or not addon.RegisterModule then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

function Echo.Init()
    -- The key function resolves lazily: Forever only knows the realm after PLAYER_LOGIN,
    -- and History writes nothing for whispers until it does.
    Echo.History.Bind(_G[addon.DATABASE], addon._GetCurrentCharacterProfileKey)
    Echo.Events.Enable()
end

function Echo.Disable()
    Echo.Events.Disable()
    Echo.Store.Reset()
    Echo.History.Unbind()
end

addon:RegisterModule("echo", {
    title       = "Horizon Echo",
    description = "Conversation-first chat: whispers and group channels as tiles you can reply from, with whisper history kept between sessions.",
    order       = 28,

    OnEnable = function()
        Echo.Init()
    end,

    OnDisable = function()
        Echo.Disable()
    end,
})
```

- [ ] **Step 6: Add to the TOC**

After `modules/Echo/EchoSend.lua`:

```
modules/Echo/EchoSlash.lua
modules/Echo/EchoModule.lua
```

- [ ] **Step 7: Add the Platform keys**

In `core/Platform.lua`, inside the `detected` table, directly after the `lootHistory = …` entry (ending `HasFunction(C_LootHistory, "GetSortedInfoForDrop"),`), add:

```lua
    -- Echo: Battle.net whisper sending, and Midnight secret chat payloads. Both stay
    -- in Platform.unverified until /h echo probe has been run on the Forever beta.
    bnetWhispers    = type(BNSendWhisper) == "function" or HasFunction(C_BattleNet, "SendWhisper"),
    secretChat      = type(issecretvalue) == "function",
```

In `Platform.unverified`, after `lootHistory    = true,`, add:

```lua
    -- Echo (2026-09-25): settled by /h echo probe on each client.
    bnetWhispers   = true,
    secretChat     = true,
```

- [ ] **Step 8: List Echo in the `/h` help**

In `core/CoreSlash.lua:146`, replace:

```lua
            HSPrint("  Modules: focus, presence, vista, augment, insight, essence")
```

with:

```lua
            HSPrint("  Modules: focus, presence, vista, augment, insight, essence, echo")
```

- [ ] **Step 9: Run the tests and lint**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`
Expected: `159 passed, 0 failed`.

Run: `luacheck modules/Echo core/Platform.lua core/CoreSlash.lua --no-color`
Expected: `0 errors`. Warnings are acceptable if they only name WoW globals missing from `.luacheckrc` (`BNSendWhisper`, `C_BattleNet`, `GetChannelName`, `geterrorhandler`). Add any that are missing to `read_globals` in `.luacheckrc`. If luacheck isn't installed locally, CI runs it on the PR.

Also run the existing suite to confirm nothing shared broke:

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_lootroll_logic.js`
Expected: `82 passed, 0 failed`.

- [ ] **Step 10: Commit**

```bash
git add modules/Echo core/Platform.lua core/CoreSlash.lua HorizonSuite.toc tools/test_echo_logic.js .luacheckrc
```

```bash
git commit -m "feat(echo): register the echo module with slash commands and a chat probe" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 8: In-game verification (on the Windows PC, a human step)

This task settles the spec's "Verification before code" items that the foundation can answer. It needs the game, so it can't be done by an agent. Hand it to the director with the branch pull commands.

**Files:**
- Modify: `Docs/Engineering/2026-09-24-echo-chat-design.md` (the "Verification before code" section)
- Possibly modify: `modules/Echo/EchoSend.lua` (the `Resolve` order), `core/Platform.lua` (the `unverified` entries)

- [ ] **Step 1: Push the branch and hand over the pull commands**

```bash
git push -u origin feature/echo-foundation
```

Director, on the Windows PC in the Retail AddOns clone:

```bash
git fetch origin
```

```bash
git switch feature/echo-foundation
```

- [ ] **Step 2: Retail checks (director, in game)**

1. `/h echo toggle` (reloads), then `/h platform`. Expect `bnetWhispers yes` and `secretChat yes`.
2. `/h echo probe 20`, then generate traffic: a whisper to and from an alt or friend, a BNet whisper, a party line, a guild line, a Trade or General line, and a whisper to a name that is offline.
3. `/h echo status`. Expect a `w:` conversation, a `bn:` one, `party`, `guild`, `ch:<name>`, and the offline whisper counted under its `w:` key.
4. `/run HorizonSuite.Echo.Send.Send("w:<Friend-Realm>", "echo test")`. The friend receives it, and `/h echo status` shows no unread change for that conversation.
5. `/run HorizonSuite.Echo.Send.Send("ch:<ChannelBaseName>", "echo test")` in a channel you're in, to check that `GetChannelName(baseName)` resolves.
6. Enter a dungeon or raid encounter with `/h echo probe 20` running, and have a groupmate whisper you and speak in instance chat mid-pull. Note which arguments show `SECRET`.
7. `/reload`, then `/h echo status`. There are no conversations (the Store is session-only). Whisper the same friend again, and the conversation shows `messages` equal to the history count plus one.
8. Log out fully, log back in, and BNet-whisper the same friend. Their saved history reappears in that friend's `bn:` conversation (keyed on disk by BattleTag, since the account ID changes between sessions), and never in another friend's.
9. Send a whisper containing an item link through `Echo.Send.Send`. `/h echo status` shows it turned `sent`, with no duplicate outgoing message from the re-encoded echo.
10. Reply to General and to Trade with `Echo.Send.Send("ch:<ChannelBaseName>", …)` while the probe runs, and read the probe's `route=`. If it is `none`, zone channels may need the full channel name for `GetChannelName`.
11. During an encounter, watch `/h echo probe 20` for a `SECRET` sender on your own raid line, and check it is filed as outgoing rather than as an incoming message.

- [ ] **Step 3: Forever beta checks (director, in game)**

Repeat Step 2 on the Forever beta install. Record whether `bnetWhispers` and `secretChat` are present, and whether any BNet whisper arrives at all.

- [ ] **Step 4: Record the results in the spec**

In `Docs/Engineering/2026-09-24-echo-chat-design.md`, under **Verification before code**, add a dated **Results (2026-09-xx)** list answering items 1, 2 and 4, plus the channel-name question from Step 2.5:

- Item 1: which arguments showed `SECRET`, in which context, and on which client.
- Item 2: which send functions resolved on each client, and whether the send in Step 2.4 arrived.
- Item 4: `AugmentToastStyles.lua` is a plain table of functions and constants, loaded by the TOC before `AugmentModule.lua`, so it works with Augment disabled and needs no move to `core/`. (Established from the code on 2026-09-25; confirm by turning Augment off before plan 2's toast task.)
- Items 3 and 5 stay open for plan 2 (bubble sizing with secret text) and plan 3 (link insertion).

If a result contradicts the code (for example, `C_ChatInfo.SendChatMessage` is absent on Forever, or `GetChannelName` needs the full channel name), fix `EchoSend.lua` in this step and re-run the logic tests. When a client settles a capability, remove it from `Platform.unverified`.

- [ ] **Step 5: Commit**

```bash
git add Docs/Engineering/2026-09-24-echo-chat-design.md modules/Echo core/Platform.lua
```

```bash
git commit -m "docs(echo): record in-game verification of chat secrets and send paths" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

- [ ] **Step 6: Open the PR with the `/pr` skill**

The PR body comes from `/pr`. It's a feature PR to `main`: squash merge, no approval required.
