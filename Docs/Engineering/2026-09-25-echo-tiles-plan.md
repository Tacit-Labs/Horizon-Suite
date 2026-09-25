# Horizon Echo: Tiles and Stack Implementation Plan (2 of 3)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Put Echo on screen: the tile column on a screen edge with unread badges and a preview toast, and the peek stack of cards with a quick-reply box. Open tiles come back after a `/reload` or a relog within 30 minutes.

**Architecture:** Plan 1's Store stays the only model. A new pure module, `EchoView`, turns conversations into what a frame draws: tile specs, display names, message lines, the column layout and the combat toast queue. It's tested in fengari. `EchoTiles` and `EchoStack` are the frames. They subscribe to the Store and redraw from `EchoView`, and are smoke-tested in fengari with stand-in frames. Session restore is a small addition to History and Store.

**Tech Stack:** WoW Lua 5.1 addon (Retail 120100 and Forever 16001), and the fengari logic harness `tools/test_echo_logic.js` from plan 1.

**Spec:** `Docs/Engineering/2026-09-24-echo-chat-design.md`, sections "Collapsed: tiles", "Peek: stack", "Combat", "Keybinds" and "Carried into plan 2".

**Plan series:** 1 Foundation (done, PR #445). **2 Tiles and stack (this plan).** 3 Card, options and polish.

## Decisions taken with the director (2026-09-25)

- **Restore:** conversations that were open when you reloaded or logged out come back if that was under 30 minutes ago. A fresh login later starts with an empty column; a conversation's history still returns the moment that person whispers again.
- **Module colour:** periwinkle `#8FA3E8`. It's used for the dot badge, the card's top rule, the toast title and border, and the column's accents.

## Global Constraints

- Lua 5.1 only, and runnable on fengari's 5.3: no `goto`, `//`, bitwise operators, `unpack` (use explicit indexes) or `tinsert` (use `table.insert`), and no `%z` in patterns.
- Every file starts with `local addon = _G.HorizonSuite` and `if not addon then return end`, and hangs off `addon.Echo`.
- Secret values: ask `Echo.IsSecret(v)` before `type()`, comparing, concatenating, `:upper()`, `:match()` or indexing a table by a chat value. A secret message text may be passed to `FontString:SetText` **alone**, never joined with other text. Battle.net names are protected `|K` strings: display them whole and never cut, upper-case or join them.
- Frames are non-secure. They may show, hide and move in combat, but the stack closes when combat starts (spec: Combat).
- Frame names: `HorizonSuiteEchoColumn` and `HorizonSuiteEchoStack`. No other globals.
- Settings are read through `Echo.Setting(key)`, which falls back to `addon.ECHO_DEFAULTS`. Positions use `echoX` and `echoY` (no default, meaning the bottom-right default anchor).
- Strings shown to the player come from `addon.L` (`locales/horizon/enUS.lua`), except `/h echo` slash output, which moves to `L` in plan 3.
- Colours: accent `#8FA3E8`; panel background `0.06, 0.06, 0.09, 0.94`; panel border `0.28, 0.30, 0.38, 0.65`; glyph tile background `0.10, 0.10, 0.13, 0.95`; neutral tile `0.45, 0.47, 0.55`; Battle.net tile `0.00, 0.68, 1.00`.
- Commits: Conventional Commits with scope `echo`, on branch `feature/echo-tiles` (stacked on `feature/echo-foundation`), each ending with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Run `git add` and `git commit` as separate commands.
- Test command: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js` (202 passing at the start of this plan).
- Parse check (luacheck isn't installed locally):
  `NODE_PATH="$HOME/.cache/hs-test/node_modules" node -e "const {lauxlib,lua,to_luastring,to_jsstring}=require('fengari');const L=lauxlib.luaL_newstate();for(const f of process.argv.slice(1)){const s=require('fs').readFileSync(f,'utf8');console.log(f,lauxlib.luaL_loadbuffer(L,to_luastring(s),null,to_luastring(f))===lua.LUA_OK?'parses':to_jsstring(lua.lua_tostring(L,-1)))}" <files>`

## File map

| File | Status | Responsibility |
|------|--------|----------------|
| `modules/Echo/EchoStore.lua` | Modify | `Store.Unsubscribe`, `Store.OpenKeys`, `Store.Restore` |
| `modules/Echo/EchoHistory.lua` | Modify | `History.SaveSession`, `History.SessionKeys`, `History.AccountIDForTag`; `Clear` wipes the session too |
| `modules/Echo/EchoView.lua` | Create | Pure view helpers and `Echo.Setting` |
| `modules/Echo/EchoTiles.lua` | Create | Column, tiles, +N, stack button, "n in chat" marker, preview toast, combat hold |
| `modules/Echo/EchoStack.lua` | Create | Peek stack, quick reply, hover open and close, keybind entry points |
| `modules/Echo/EchoModule.lua` | Modify | Restore at enable, save at logout, combat events, view enable/disable |
| `modules/Echo/EchoSlash.lua` | Modify | `/h echo lock`, `unlock`, `reset` |
| `options/modules/defaults/OptionsDefaultsEcho.lua` | Create | `addon.ECHO_DEFAULTS` |
| `locales/horizon/enUS.lua` | Modify | Echo UI strings |
| `Bindings.xml` | Modify | *Echo: Reply to newest*, *Echo: Toggle stack* |
| `HorizonSuite.toc` | Modify | Load the new files |
| `Docs/Branding/ColourSchema.md` | Modify | Echo `#8FA3E8` |
| `.luacheckrc` | Modify | New read globals |
| `tools/test_echo_logic.js` | Modify | View, session and frame smoke tests |

---

### Task 1: Store — unsubscribe, open keys, restore

**Files:**
- Modify: `modules/Echo/EchoStore.lua` (insert above `--- Forget every conversation`; extend the `Store.Subscribe` doc comment)
- Test: `tools/test_echo_logic.js` (new section before `// --- Summary`)

**Interfaces:**
- Consumes: the file's locals `conversations`, `listeners`, `Notify`, `GetOrCreate`; `Store.List`, `Store.KindOf`, `Store.PERSISTED_KINDS`.
- Produces:
  - `Store.Unsubscribe(fn)`.
  - `Store.OpenKeys() -> string[]`: open whisper and bnet keys, in List order.
  - `Store.Restore(keys) -> number`: the count restored; notifies `(nil, "restored")`.

- [ ] **Step 1: Write the failing tests**

Insert before `// --- Summary`:

```js
// --- Store: unsubscribe, open keys, restore --------------------------------------
run(`
  local S = HorizonSuite.Echo.Store
  S.Reset()
  local calls = 0
  local function listener() calls = calls + 1 end
  S.Subscribe(listener)
  S.Add({ convKey = "guild", text = "x" })
  local before = calls
  S.Unsubscribe(listener)
  S.Add({ convKey = "guild", text = "y" })
  check("an unsubscribed view hears nothing more", before > 0 and calls == before, calls)

  S.Add({ convKey = "w:A-Horizon", text = "1" })
  S.Add({ convKey = "w:B-Horizon", text = "2" })
  S.Add({ convKey = "bn:5", text = "3" })
  S.Add({ convKey = "party", text = "4" })
  S.Close("w:B-Horizon")
  local open = S.OpenKeys()
  check("open keys are open whisper conversations in list order",
        table.concat(open, ",") == "bn:5,w:A-Horizon", table.concat(open, ","))

  S.Reset()
  local restoredSeen = false
  local function watch(key, change) if change == "restored" and key == nil then restoredSeen = true end end
  S.Subscribe(watch)
  local n = S.Restore({ "w:Top-Horizon", "w:Second-Horizon", "party" })
  S.Unsubscribe(watch)
  check("restore reopens whisper conversations only", n == 2, n)
  check("views are told about a restore", restoredSeen, "not told")
  local keys = {}
  for i, c in ipairs(S.List()) do keys[i] = c.key end
  check("restored conversations keep their saved order", table.concat(keys, ",") == "w:Top-Horizon,w:Second-Horizon", table.concat(keys, ","))
  check("restored conversations have nothing unread", S.Get("w:Top-Horizon").unread == 0, S.Get("w:Top-Horizon").unread)
  S.Add({ convKey = "w:New-Horizon", text = "hey" })
  check("a new loud message sits above restored conversations", S.List()[1].key == "w:New-Horizon", S.List()[1].key)
  check("restore leaves existing conversations alone", S.Restore({ "w:New-Horizon" }) == 0, "restored twice")
  S.Close("w:Top-Horizon")
  check("restore does not reopen a conversation closed this session", S.Restore({ "w:Top-Horizon" }) == 0, "reopened")
  check("restore with nothing is harmless", S.Restore(nil) == 0, "?")
  S.Reset()
`, 'store-restore');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run the test command. Expected: exit 1 with `store-restore: … attempt to call a nil value (method 'Unsubscribe')` or `(field 'Unsubscribe')`.

- [ ] **Step 3: Implement**

In `modules/Echo/EchoStore.lua`, update the `Store.Subscribe` doc comment's change list so it also names `"restored"`: `-- "update" | "closed" | "unrouted" | "reset" | "restored"; convKey is nil for "unrouted", "reset" and "restored"`. Then insert directly above `--- Forget every conversation`:

```lua
--- Stop a view's notifications.
-- @param fn function  The function passed to Store.Subscribe
function Store.Unsubscribe(fn)
    for i = #listeners, 1, -1 do
        if listeners[i] == fn then table.remove(listeners, i) end
    end
end

--- Open whisper and Battle.net conversations, in List order. Saved at logout so a
-- reload can bring their tiles back; channels are session-only and never saved.
-- @return table keys
function Store.OpenKeys()
    local keys = {}
    for _, conv in ipairs(Store.List()) do
        if Store.PERSISTED_KINDS[conv.kind] then keys[#keys + 1] = conv.key end
    end
    return keys
end

--- Reopen conversations saved at the end of the last session, seeded from history.
-- Keys are restored last-first so the saved first key ends up on top, and every
-- restored conversation sits below anything with a loud message this session.
-- A conversation that already exists, including one closed this session, is left alone.
-- @param keys table|nil  convKeys, top first
-- @return number restored
function Store.Restore(keys)
    local restored = 0
    keys = keys or {}
    for i = #keys, 1, -1 do
        local key = keys[i]
        if Store.PERSISTED_KINDS[Store.KindOf(key)] and not conversations[key] then
            GetOrCreate(key)
            restored = restored + 1
        end
    end
    if restored > 0 then Notify(nil, "restored") end
    return restored
end
```

- [ ] **Step 4: Run the tests and confirm they pass**

Run the test command. Expected: `212 passed, 0 failed`.

- [ ] **Step 5: Commit**

```bash
git add modules/Echo/EchoStore.lua tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): restore saved conversations and let views unsubscribe" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: History — save and restore the open session

**Files:**
- Modify: `modules/Echo/EchoHistory.lua` (new functions after `History.BattleTagFor`; `History.Clear` also wipes `root.session`)
- Test: `tools/test_echo_logic.js` (new section before `// --- Summary`)

**Interfaces:**
- Consumes: the file's locals `root`, `characterKey`, `enabledCheck`; `History.BattleTagFor(convKey)`; `Echo.Store.KindOf`; `Echo.IsSecret`.
- Produces:
  - `History.SESSION_MAX_AGE` (1800).
  - `History.SaveSession(keys, now) -> boolean`.
  - `History.SessionKeys(now, maxAge?) -> string[]`.
  - `History.AccountIDForTag(battleTag) -> number|nil`.
- Saved shape: `HorizonDB.echoHistory.session["Name-Realm"] = { t = <time>, keys = { "w:Name-Realm", "bt:Tag#1234", … } }`. A Battle.net conversation is saved by BattleTag, never by the session-only account ID, and mapped back to the current account ID through the friends list.

- [ ] **Step 1: Write the failing tests**

Insert before `// --- Summary`:

```js
// --- History: open session save and restore -------------------------------------------
run(`
  local S, H = HorizonSuite.Echo.Store, HorizonSuite.Echo.History
  S.Reset()
  local db = {}
  local charKey = "Kaelis-Horizon"
  H.Bind(db, function() return charKey end)
  local savedBattleNet, savedNumFriends = C_BattleNet, BNGetNumFriends
  C_BattleNet = {
    GetAccountInfoByID = function(id) if id == 77 then return { battleTag = "Vexa#1234" } end end,
    GetFriendAccountInfo = function(i)
      if i == 1 then return { battleTag = SECRET("Hidden#1"), bnetAccountID = 12 } end
      if i == 2 then return { battleTag = "Vexa#1234", bnetAccountID = 91 } end
    end,
  }
  BNGetNumFriends = function() return 2 end

  check("session saved", H.SaveSession({ "w:Brisa-Horizon", "bn:77", "bn:404", "party" }, 1000) == true, "not saved")
  local saved = db.echoHistory.session and db.echoHistory.session["Kaelis-Horizon"]
  check("session keeps whispers and battletags, never account ids or channels",
        saved and table.concat(saved.keys, ",") == "w:Brisa-Horizon,bt:Vexa#1234", saved and table.concat(saved.keys, ","))
  local keys = H.SessionKeys(1600)
  check("a recent session restores, battle.net mapped to today's account id",
        table.concat(keys, ",") == "w:Brisa-Horizon,bn:91", table.concat(keys, ","))
  check("a session older than 30 minutes restores nothing", #H.SessionKeys(1000 + 1801) == 0, "restored")
  check("a custom max age is honoured", #H.SessionKeys(1100, 50) == 0, "restored")
  check("a secret battletag in the friends list is skipped", H.AccountIDForTag("Hidden#1") == nil, "matched")
  BNGetNumFriends = function() return 0 end
  keys = H.SessionKeys(1100)
  check("a battle.net friend no longer listed is dropped", table.concat(keys, ",") == "w:Brisa-Horizon", table.concat(keys, ","))
  BNGetNumFriends = nil
  check("no friends API, no battle.net restore", table.concat(H.SessionKeys(1100), ",") == "w:Brisa-Horizon", "?")
  charKey = "Alt-Horizon"
  check("sessions are per character", #H.SessionKeys(1100) == 0, "leaked")
  charKey = nil
  check("no character key, nothing saved", H.SaveSession({ "w:X-Horizon" }, 1100) == false, "saved")
  charKey = "Kaelis-Horizon"
  H.SetEnabledCheck(function() return false end)
  check("history off saves no session", H.SaveSession({ "w:X-Horizon" }, 2000) == false, "saved")
  H.SetEnabledCheck(function() return true end)
  H.Clear()
  check("clear wipes the session too", next(db.echoHistory.session) == nil, "kept")
  C_BattleNet, BNGetNumFriends = savedBattleNet, savedNumFriends
  H.Unbind()
  check("unbound history has no session", #H.SessionKeys(1100) == 0 and H.SaveSession({ "w:X-Horizon" }, 1) == false, "?")
  S.Reset()
`, 'history-session');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run the test command. Expected: exit 1 with `history-session: … attempt to call a nil value (field 'SaveSession')`.

- [ ] **Step 3: Implement**

In `modules/Echo/EchoHistory.lua`, replace `History.Clear` with:

```lua
--- Wipe all saved whispers, for every character and Battle.net, and the saved session.
function History.Clear()
    if not root then return end
    root.chars = {}
    root.bnet = {}
    root.session = {}
end
```

Insert directly after the end of `History.BattleTagFor`:

```lua
History.SESSION_MAX_AGE = 1800  -- a reload or a quick relog, not yesterday's login

--- The current session-only account ID for a friend's BattleTag, from the friends list.
-- @param battleTag string
-- @return number|nil
function History.AccountIDForTag(battleTag)
    local api = C_BattleNet and C_BattleNet.GetFriendAccountInfo
    if type(BNGetNumFriends) ~= "function" or type(api) ~= "function" then return nil end
    local okCount, count = pcall(BNGetNumFriends)
    if not okCount or Echo.IsSecret(count) or type(count) ~= "number" then return nil end
    for i = 1, count do
        local ok, info = pcall(api, i)
        if ok and type(info) == "table" then
            local tag = info.battleTag
            if not Echo.IsSecret(tag) and tag == battleTag then
                local id = info.bnetAccountID
                if not Echo.IsSecret(id) and type(id) == "number" then return id end
            end
        end
    end
    return nil
end

--- Remember which conversations were open, for this character (PLAYER_LOGOUT, which a
-- reload also fires). Battle.net conversations are saved by BattleTag.
-- @param keys table  Store.OpenKeys()
-- @param now number
-- @return boolean saved
function History.SaveSession(keys, now)
    if not root or not enabledCheck() then return false end
    local charKey = characterKey()
    if not charKey then return false end
    local saved = {}
    for _, key in ipairs(keys or {}) do
        local kind = Echo.Store.KindOf(key)
        if kind == "whisper" then
            saved[#saved + 1] = key
        elseif kind == "bnet" then
            local tag = History.BattleTagFor(key)
            if tag then saved[#saved + 1] = "bt:" .. tag end
        end
    end
    root.session = root.session or {}
    root.session[charKey] = { t = now, keys = saved }
    return true
end

--- The conversations to reopen, if this character's session was saved recently.
-- @param now number
-- @param maxAge number|nil  seconds; defaults to History.SESSION_MAX_AGE
-- @return table keys  top first; Battle.net friends no longer listed are dropped
function History.SessionKeys(now, maxAge)
    local out = {}
    if not root or type(root.session) ~= "table" then return out end
    local charKey = characterKey()
    local session = charKey and root.session[charKey]
    if type(session) ~= "table" or type(session.t) ~= "number" then return out end
    if now - session.t > (maxAge or History.SESSION_MAX_AGE) then return out end
    for _, key in ipairs(session.keys or {}) do
        if type(key) == "string" and key:sub(1, 3) == "bt:" then
            local id = History.AccountIDForTag(key:sub(4))
            if id then out[#out + 1] = "bn:" .. id end
        elseif Echo.Store.KindOf(key) == "whisper" then
            out[#out + 1] = key
        end
    end
    return out
end
```

- [ ] **Step 4: Run the tests and confirm they pass**

Expected: `225 passed, 0 failed`.

- [ ] **Step 5: Commit**

```bash
git add modules/Echo/EchoHistory.lua tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): save open conversations at logout and restore them within 30 minutes" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 3: EchoView, defaults, strings and colour

**Files:**
- Create: `modules/Echo/EchoView.lua`
- Create: `options/modules/defaults/OptionsDefaultsEcho.lua`
- Modify: `locales/horizon/enUS.lua` (append the Echo block at the end of the file)
- Modify: `Docs/Branding/ColourSchema.md` (add the Echo row between Axis and Essence)
- Modify: `HorizonSuite.toc`: `modules/Echo/EchoView.lua` after `modules/Echo/EchoSend.lua`; `options/modules/defaults/OptionsDefaultsEcho.lua` after `options/modules/defaults/OptionsDefaultsEssence.lua`
- Test: `tools/test_echo_logic.js` (add `EchoView.lua` to `FILES` after `EchoSend.lua`; new section)

**Interfaces:**
- Consumes: `Echo.Store` (`TierOf`, `Now`), `Echo.History.BattleTagFor`, `Echo.IsSecret`, `addon.L`, `addon.GetDB`, `addon.ECHO_DEFAULTS`.
- Produces:
  - `Echo.Setting(key)`.
  - Constants: `View.ACCENT {r,g,b}`, `View.PANEL_BG`, `View.PANEL_BORDER`, `View.GLYPH_BG` (4-number arrays), `View.NEUTRAL`, `View.BNET` (`{r,g,b}`), `View.GLYPHS`, `View.CHAT_TYPE`.
  - `View.Initial(s) -> string`, `View.ClassColor(class) -> r,g,b|nil`, `View.ChatColor(kind) -> r,g,b`.
  - `View.LastIncoming(conv) -> record|nil`, `View.LastClass(conv) -> string|nil`, `View.DisplayName(conv) -> string`.
  - `View.TileSpec(conv) -> { letter, r, g, b, glyph, badge = "dot"|"count"|nil, count }`.
  - `View.Column(list, maxTiles) -> visible, overflow`, `View.NewestLoud(list) -> conv|nil`, `View.Recent(conv, n) -> record[]`.
  - `View.Age(seconds) -> string`, `View.MetaLine(conv, now) -> string`, `View.LineText(conv, msg) -> string|secret`.
  - `View.NewToastQueue() -> { Hold(self, key, seq), Release(self) -> keys, Count(self) }`.

- [ ] **Step 1: Write the failing tests**

In `tools/test_echo_logic.js`, add `'modules/Echo/EchoView.lua',` to `FILES` directly after `'modules/Echo/EchoSend.lua',`. Insert before `// --- Summary`:

```js
// --- View: tiles, names, lines, layout, toast queue ------------------------------------
run(`
  local S, V = HorizonSuite.Echo.Store, HorizonSuite.Echo.View
  S.Reset()
  RAID_CLASS_COLORS = { DRUID = { r = 1, g = 0.49, b = 0.04 } }
  ChatTypeInfo = { PARTY = { r = 0.67, g = 0.67, b = 1 } }
  LOCALIZED_CLASS_NAMES_MALE = { DRUID = "Druid" }
  local realNow = S.Now
  S.Now = function() return 5000 end

  check("setting falls back to Echo's default", (function()
    HorizonSuite.ECHO_DEFAULTS = { echoMaxTiles = 8 }
    return HorizonSuite.Echo.Setting("echoMaxTiles") == 8 end)(), "no default")
  HorizonSuite.GetDB = function(k, d) if k == "echoMaxTiles" then return 5 end return d end
  check("a saved setting wins", HorizonSuite.Echo.Setting("echoMaxTiles") == 5, HorizonSuite.Echo.Setting("echoMaxTiles"))
  HorizonSuite.GetDB = nil

  check("initial of a name", V.Initial("brisa") == "B", V.Initial("brisa"))
  check("a multibyte first letter stays whole", V.Initial("élan") == "é", V.Initial("élan"))
  check("initial of a secret is a placeholder", V.Initial(SECRET("x")) == "?", V.Initial(SECRET("x")))

  S.Add({ convKey = "w:Brisa-Horizon", text = "got the leather", class = "DRUID", sender = "Brisa-Horizon", time = 4990 })
  S.Add({ convKey = "w:Brisa-Horizon", text = "can you craft it?", class = "DRUID", sender = "Brisa-Horizon", time = 4995 })
  local brisa = S.Get("w:Brisa-Horizon")
  local spec = V.TileSpec(brisa)
  check("whisper tile shows the initial", spec.letter == "B", spec.letter)
  check("whisper tile takes the class colour", spec.r == 1 and spec.g == 0.49 and not spec.glyph, spec.r)
  check("loud unread shows a dot", spec.badge == "dot", spec.badge)
  check("whisper name drops the realm", V.DisplayName(brisa) == "Brisa", V.DisplayName(brisa))
  local meta = V.MetaLine(brisa, 5000)
  check("meta names the class, the unread count and the age",
        meta:find("Druid", 1, true) and meta:find("ECHO_NEW_COUNT", 1, true) and meta:find("ECHO_JUST_NOW", 1, true), meta)
  check("whisper lines are just the text", V.LineText(brisa, brisa.messages[1]) == "got the leather", V.LineText(brisa, brisa.messages[1]))

  S.Add({ convKey = "w:Unknown-Horizon", text = "hi" })
  check("an unknown class falls back to neutral", V.TileSpec(S.Get("w:Unknown-Horizon")).r == V.NEUTRAL.r, "?")
  S.Add({ convKey = "bn:77", text = "yo", sender = "|Kq1|k" })
  local bnet = S.Get("bn:77")
  check("a battle.net tile is battle.net blue without a class", V.TileSpec(bnet).b == V.BNET.b and V.TileSpec(bnet).r == V.BNET.r, "?")
  check("a battle.net name is the protected sender, untouched", V.DisplayName(bnet) == "|Kq1|k", V.DisplayName(bnet))
  check("battle.net meta says battle.net", V.MetaLine(bnet, 5000):find("ECHO_BATTLENET", 1, true) ~= nil, V.MetaLine(bnet, 5000))

  S.Add({ convKey = "party", text = "pull", sender = "Tank-Horizon" })
  S.Add({ convKey = "party", text = "now", sender = "Tank-Horizon" })
  local party = S.Get("party")
  local pspec = V.TileSpec(party)
  check("a party tile is a glyph", pspec.glyph == true and pspec.letter == "P", pspec.letter)
  check("the glyph uses Blizzard's party colour", pspec.r == 0.67 and pspec.b == 1, pspec.r)
  check("a count-tier tile shows the number", pspec.badge == "count" and pspec.count == 2, pspec.badge)
  check("a group line names the speaker", V.LineText(party, party.messages[1]) == "Tank: pull", V.LineText(party, party.messages[1]))
  check("a group's name is its label", V.DisplayName(party) == "ECHO_KIND_PARTY", V.DisplayName(party))
  local secretLine = { text = SECRET("boss plan"), secret = true, sender = "Tank-Horizon" }
  check("a secret line is passed through untouched", rawequal(V.LineText(party, secretLine), secretLine.text), "joined")
  S.Add({ convKey = "guild", text = "gz" })
  check("a quiet tile shows no badge", V.TileSpec(S.Get("guild")).badge == nil, V.TileSpec(S.Get("guild")).badge)
  S.Add({ convKey = "ch:Trade", text = "wts" })
  check("a channel tile uses its first letter", V.TileSpec(S.Get("ch:Trade")).letter == "T", V.TileSpec(S.Get("ch:Trade")).letter)
  check("a channel's name is its key name", V.DisplayName(S.Get("ch:Trade")) == "Trade", V.DisplayName(S.Get("ch:Trade")))
  S.SetTier("w:Brisa-Horizon", "muted")
  check("a muted conversation shows no badge", V.TileSpec(brisa).badge == nil, V.TileSpec(brisa).badge)
  S.SetTier("w:Brisa-Horizon", nil)

  check("newest loud conversation", V.NewestLoud(S.List()).key == "bn:77", V.NewestLoud(S.List()).key)
  check("no loud conversation falls back to the first", V.NewestLoud({ { key = "x", lastLoud = 0 } }).key == "x", "?")
  check("an empty list has no newest", V.NewestLoud({}) == nil, "?")

  local ten = {}
  for i = 1, 10 do ten[i] = { key = "k" .. i } end
  local visible, overflow = V.Column(ten, 8)
  check("overflow keeps 7 tiles and a +3 tile", #visible == 7 and overflow == 3 and visible[1].key == "k1", #visible .. "/" .. overflow)
  visible, overflow = V.Column({ ten[1], ten[2] }, 8)
  check("under the cap there is no overflow", #visible == 2 and overflow == 0, #visible .. "/" .. overflow)

  local recent = V.Recent(brisa, 1)
  check("recent returns the newest messages oldest first", #recent == 1 and recent[1].text == "can you craft it?", recent[1] and recent[1].text)
  check("recent never goes past the start", #V.Recent(brisa, 10) == 2, #V.Recent(brisa, 10))
  check("age under a minute", V.Age(30) == "ECHO_JUST_NOW", V.Age(30))
  check("age in minutes", V.Age(125) == "2m", V.Age(125))
  check("age in hours", V.Age(7200) == "2h", V.Age(7200))
  check("age in days", V.Age(200000) == "2d", V.Age(200000))

  local q = V.NewToastQueue()
  q:Hold("a", 1); q:Hold("b", 3); q:Hold("a", 5)
  check("the queue counts conversations, not messages", q:Count() == 2, q:Count())
  local order = q:Release()
  check("held toasts play newest first, one per conversation", table.concat(order, ",") == "a,b", table.concat(order, ","))
  check("release empties the queue", q:Count() == 0 and #q:Release() == 0, q:Count())

  S.Now = realNow
  S.Reset()
`, 'view');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Expected: exit 1 with `ENOENT` for `modules/Echo/EchoView.lua`.

- [ ] **Step 3: Create `modules/Echo/EchoView.lua`**

```lua
--[[
    Horizon Suite - Echo - View
    Pure helpers the Echo frames draw from: colours, tile specs, names, message lines,
    the column layout and the combat toast queue. No frames, so the logic harness tests it.
    Blizzard (read only): RAID_CLASS_COLORS, C_ClassColor, ChatTypeInfo, LOCALIZED_CLASS_NAMES_MALE.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo
local L = addon.L

local View = {}
Echo.View = View

--- A saved setting, falling back to Echo's default (options/modules/defaults/OptionsDefaultsEcho.lua).
-- @param key string
-- @return any
function Echo.Setting(key)
    local defaults = addon.ECHO_DEFAULTS
    local fallback = defaults and defaults[key]
    if not addon.GetDB then return fallback end
    return addon.GetDB(key, fallback)
end

-- Echo's module colour, #8FA3E8 (Docs/Branding/ColourSchema.md).
View.ACCENT = { r = 0x8F / 255, g = 0xA3 / 255, b = 0xE8 / 255 }
View.PANEL_BG = { 0.06, 0.06, 0.09, 0.94 }
View.PANEL_BORDER = { 0.28, 0.30, 0.38, 0.65 }
View.GLYPH_BG = { 0.10, 0.10, 0.13, 0.95 }
-- A whisper whose class is unknown, and a Battle.net friend not on a character.
View.NEUTRAL = { r = 0.45, g = 0.47, b = 0.55 }
View.BNET = { r = 0.00, g = 0.68, b = 1.00 }

View.GLYPHS = { party = "P", raid = "R", instance = "I", guild = "G", officer = "O" }

-- ChatTypeInfo keys, so each kind uses Blizzard's own chat colour.
View.CHAT_TYPE = {
    whisper = "WHISPER", bnet = "BN_WHISPER", party = "PARTY", raid = "RAID",
    instance = "INSTANCE_CHAT", guild = "GUILD", officer = "OFFICER", channel = "CHANNEL",
}

local FIRST_CHAR = "^[\1-\127\194-\244][\128-\191]*"

--- First character of a readable string, UTF-8 aware, upper-cased when ASCII.
-- @param s string
-- @return string  "?" for secret, empty or non-string input
function View.Initial(s)
    if Echo.IsSecret(s) or type(s) ~= "string" then return "?" end
    local c = s:match(FIRST_CHAR)
    if not c or c == "" then return "?" end
    return c:upper()
end

--- Class colour for a class file.
-- @param class string|nil
-- @return number|nil r, number g, number b
function View.ClassColor(class)
    if Echo.IsSecret(class) or type(class) ~= "string" then return nil end
    if C_ClassColor and C_ClassColor.GetClassColor then
        local ok, c = pcall(C_ClassColor.GetClassColor, class)
        if ok and c then return c.r, c.g, c.b end
    end
    local rc = RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
    if rc then return rc.r, rc.g, rc.b end
    return nil
end

--- Blizzard's chat colour for a conversation kind, else Echo's accent.
-- @param kind string
-- @return number r, number g, number b
function View.ChatColor(kind)
    local chatType = View.CHAT_TYPE[kind]
    local info = chatType and ChatTypeInfo and ChatTypeInfo[chatType]
    if info and info.r then return info.r, info.g, info.b end
    return View.ACCENT.r, View.ACCENT.g, View.ACCENT.b
end

--- The newest incoming message, by position (history-seeded messages all have seq 0).
-- @param conv table
-- @return table|nil record
function View.LastIncoming(conv)
    local messages = conv and conv.messages
    if not messages then return nil end
    for i = #messages, 1, -1 do
        if not messages[i].outgoing then return messages[i] end
    end
    return nil
end

--- The newest class seen on an incoming message.
-- @param conv table
-- @return string|nil
function View.LastClass(conv)
    local messages = conv.messages
    for i = #messages, 1, -1 do
        local m = messages[i]
        if not m.outgoing and m.class then return m.class end
    end
    return nil
end

--- Title for a conversation's tile, toast and card. A Battle.net name is a protected
-- string and is returned whole.
-- @param conv table
-- @return string
function View.DisplayName(conv)
    local key, kind = conv.key, conv.kind
    if kind == "whisper" then
        local name = key:sub(3)
        return name:match("^([^-]+)") or name
    elseif kind == "bnet" then
        local last = View.LastIncoming(conv)
        if last and last.sender then return last.sender end
        local tag = Echo.History and Echo.History.BattleTagFor(key)
        if tag then return tag:match("^([^#]+)") or tag end
        return L["ECHO_BATTLENET"]
    elseif kind == "channel" then
        return key:sub(4)
    end
    return L["ECHO_KIND_" .. kind:upper()]
end

--- What a tile shows.
-- @param conv table
-- @return table { letter, r, g, b, glyph = boolean|nil, badge = "dot"|"count"|nil, count = number }
function View.TileSpec(conv)
    local kind = conv.kind
    local spec = { count = conv.unread or 0 }
    if kind == "whisper" or kind == "bnet" then
        local r, g, b = View.ClassColor(View.LastClass(conv))
        if not r then
            local c = (kind == "bnet") and View.BNET or View.NEUTRAL
            r, g, b = c.r, c.g, c.b
        end
        spec.r, spec.g, spec.b = r, g, b
        if kind == "whisper" then
            spec.letter = View.Initial(conv.key:sub(3))
        else
            local tag = Echo.History and Echo.History.BattleTagFor(conv.key)
            spec.letter = View.Initial(tag or "B")
        end
    else
        spec.glyph = true
        spec.letter = View.GLYPHS[kind] or View.Initial(conv.key:sub(4))
        spec.r, spec.g, spec.b = View.ChatColor(kind)
    end
    local tier = Echo.Store.TierOf(conv.key)
    if spec.count > 0 then
        if tier == "loud" then
            spec.badge = "dot"
        elseif tier == "count" then
            spec.badge = "count"
        end
    end
    return spec
end

--- Which conversations get a tile. Past maxTiles, the last slot becomes a +N tile.
-- @param list table  Store.List()
-- @param maxTiles number|nil
-- @return table visible, number overflow
function View.Column(list, maxTiles)
    maxTiles = math.max(1, maxTiles or 8)
    if #list <= maxTiles then return list, 0 end
    local visible = {}
    for i = 1, maxTiles - 1 do visible[i] = list[i] end
    return visible, #list - (maxTiles - 1)
end

--- The conversation with the most recent loud message, else the first one.
-- @param list table
-- @return table|nil conv
function View.NewestLoud(list)
    local best
    for _, conv in ipairs(list) do
        if (conv.lastLoud or 0) > 0 and (not best or conv.lastLoud > best.lastLoud) then best = conv end
    end
    return best or list[1]
end

--- The last n messages, oldest first.
-- @param conv table
-- @param n number
-- @return table records
function View.Recent(conv, n)
    local out, messages = {}, conv.messages
    for i = math.max(1, #messages - n + 1), #messages do out[#out + 1] = messages[i] end
    return out
end

--- Short age: "just now", "5m", "3h", "2d".
-- @param seconds number
-- @return string
function View.Age(seconds)
    seconds = math.max(0, seconds or 0)
    if seconds < 60 then return L["ECHO_JUST_NOW"] end
    if seconds < 3600 then return ("%dm"):format(math.floor(seconds / 60)) end
    if seconds < 86400 then return ("%dh"):format(math.floor(seconds / 3600)) end
    return ("%dd"):format(math.floor(seconds / 86400))
end

--- Card header detail: class (or Battle.net), unread count and age. Readable parts only.
-- @param conv table
-- @param now number
-- @return string
function View.MetaLine(conv, now)
    local parts = {}
    local class = View.LastClass(conv)
    if class and not Echo.IsSecret(class) then
        local names = LOCALIZED_CLASS_NAMES_MALE
        parts[#parts + 1] = (names and names[class]) or class
    elseif conv.kind == "bnet" then
        parts[#parts + 1] = L["ECHO_BATTLENET"]
    end
    if (conv.unread or 0) > 0 then parts[#parts + 1] = L["ECHO_NEW_COUNT"]:format(conv.unread) end
    local last = conv.messages[#conv.messages]
    if last and last.time then parts[#parts + 1] = View.Age(now - last.time) end
    return table.concat(parts, " · ")
end

--- Text for one message line. An incoming group line names the speaker when both parts
-- are readable. A secret text is returned untouched: SetText can show it, nothing may join it.
-- @param conv table
-- @param msg table
-- @return string|any
function View.LineText(conv, msg)
    local text = msg.text
    if msg.secret or Echo.IsSecret(text) then return text end
    if conv.kind ~= "whisper" and conv.kind ~= "bnet" and not msg.outgoing
        and not Echo.IsSecret(msg.sender) and type(msg.sender) == "string" then
        local short = msg.sender:match("^([^-]+)") or msg.sender
        return short .. ": " .. tostring(text)
    end
    return text
end

--- Toasts held during combat: one per conversation, played newest first afterwards.
-- @return table queue  :Hold(key, seq), :Release() -> keys, :Count()
function View.NewToastQueue()
    local queue = { held = {}, count = 0 }
    function queue:Hold(key, seq)
        if self.held[key] == nil then self.count = self.count + 1 end
        self.held[key] = seq or 0
    end
    function queue:Release()
        local entries = {}
        for key, seq in pairs(self.held) do entries[#entries + 1] = { key = key, seq = seq } end
        table.sort(entries, function(a, b) return a.seq > b.seq end)
        self.held, self.count = {}, 0
        local keys = {}
        for i, e in ipairs(entries) do keys[i] = e.key end
        return keys
    end
    function queue:Count()
        return self.count
    end
    return queue
end
```

- [ ] **Step 4: Create `options/modules/defaults/OptionsDefaultsEcho.lua`**

```lua
--[[
    Horizon Suite - Echo - Defaults
    ECHO_DEFAULTS for the settings Echo reads through Echo.Setting. The options page
    arrives in plan 3; until then /h echo lock | unlock | reset covers the column.
    echoX / echoY have no default: unset means the bottom-right anchor.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.ECHO_DEFAULTS = {
    echoLockPosition       = true,
    echoScale              = 1,
    echoFrameStrata        = "MEDIUM",
    echoMaxTiles           = 8,
    echoToastStyle         = "framed",
    echoToastSeconds       = 4,
    echoHoverDelay         = 0.35,
    echoHoldToastsInCombat = true,
}
```

- [ ] **Step 5: Strings, colour and TOC**

Append to the end of `locales/horizon/enUS.lua`:

```lua

-- =====================================================================
-- Echo — tiles and stack
-- =====================================================================
L["ECHO_NEW_MESSAGE"]                                         = "New message"
L["ECHO_IN_CHAT"]                                             = "%d in chat"
L["ECHO_QUICK_REPLY"]                                         = "Quick reply…"
L["ECHO_OPEN"]                                                = "Open"
L["ECHO_MORE"]                                                = "+%d more · scroll to flip"
L["ECHO_SCROLL_HINT"]                                         = "Scroll to flip"
L["ECHO_NEW_COUNT"]                                           = "%d new"
L["ECHO_JUST_NOW"]                                            = "just now"
L["ECHO_BATTLENET"]                                           = "Battle.net"
L["ECHO_KIND_PARTY"]                                          = "Party"
L["ECHO_KIND_RAID"]                                           = "Raid"
L["ECHO_KIND_INSTANCE"]                                       = "Instance"
L["ECHO_KIND_GUILD"]                                          = "Guild"
L["ECHO_KIND_OFFICER"]                                        = "Officer"
```

In `Docs/Branding/ColourSchema.md`, add this row between the Axis and Essence rows:

```
|Echo|<span style="color:#8FA3E8;">#8FA3E8</span>|
```

In `HorizonSuite.toc`, add `modules/Echo/EchoView.lua` on the line after `modules/Echo/EchoSend.lua`, and `options/modules/defaults/OptionsDefaultsEcho.lua` on the line after `options/modules/defaults/OptionsDefaultsEssence.lua`.

- [ ] **Step 6: Run the tests and parse-check**

Run the test command. Expected: `264 passed, 0 failed`. Parse-check `modules/Echo/EchoView.lua`, `options/modules/defaults/OptionsDefaultsEcho.lua` and `locales/horizon/enUS.lua`; all should report `parses`.

- [ ] **Step 7: Commit**

```bash
git add modules/Echo/EchoView.lua options/modules/defaults/OptionsDefaultsEcho.lua locales/horizon/enUS.lua Docs/Branding/ColourSchema.md HorizonSuite.toc tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): add the view helpers, defaults and strings the tiles draw from" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: The tile column and preview toast

**Files:**
- Create: `modules/Echo/EchoTiles.lua`
- Modify: `HorizonSuite.toc` (`modules/Echo/EchoTiles.lua` after `modules/Echo/EchoView.lua`)
- Test: `tools/test_echo_logic.js` (add `EchoTiles.lua` to `FILES` after `EchoView.lua`; frame stubs plus a smoke section)

**Interfaces:**
- Consumes: `Echo.View` (all of Task 3), `Echo.Setting`, `Echo.Store` (`List`, `Get`, `Subscribe`, `Unsubscribe`, `GetUnroutedCount`, `ClearUnrouted`); `Echo.Stack` (Task 5: `Open(key)`, `Toggle()`, `HoverEnter()`, `HoverLeave()`), each call guarded with `if Echo.Stack`; `addon.Augment.ToastStyles.ApplyChrome`, `addon.Augment.ToastMotion` (`ENTRANCE_DUR`, `EXIT_DUR`, `SLIDE_DIST`, `Ease`), guarded.
- Produces:
  - `Tiles.Enable()`, `Tiles.Disable()`, `Tiles.Refresh()`.
  - `Tiles.ApplyPosition()`, `Tiles.ResetPosition()`.
  - `Tiles.TileFor(convKey) -> frame`.
  - `Tiles.ShowToast(convKey) -> boolean`, `Tiles.Hold(on)`, `Tiles.NextToast()`.
  - `Tiles.OnStoreChange(convKey, change)`, `Tiles.holding`.
  - `Echo.NewText(parent, size, flags) -> FontString`, `Echo.FLAT` (backdrop table).
- Frame global: `HorizonSuiteEchoColumn`. Tiles are `tiles[i]` for `visible[i]` (`tiles[1]` is the top conversation). Each tile carries `.convKey`, `.letter`, `.dot` and `.count`. The toast carries `.convKey`, `.anchor`, `.t` and `.entry` (`frame`, `icon`, `iconBg`, `iconDark`, `letter`, `title`, `body`).

- [ ] **Step 1: Write the frame stubs and the failing smoke tests**

In `tools/test_echo_logic.js`, add `'modules/Echo/EchoTiles.lua',` to `FILES` after `'modules/Echo/EchoView.lua',`. The frame files call `CreateFrame` only when enabled. Add these stand-ins to the **first** `run(... 'stubs')` block, just before the `PASS, FAIL = 0, 0` line. The events section later installs its own minimal `CreateFrame`, so each frame section sets `CreateFrame = STUB_CREATE_FRAME` first:

```lua
  -- Stand-in frames for smoke tests: every method exists and does nothing, except the
  -- handful whose results the Echo frames read back.
  function STUB_FRAME(parent)
    local o = { scripts = {}, shown = false, parent = parent, text = "", points = {} }
    local fixed = { GetFrameLevel = 1, GetScale = 1, GetFrameStrata = "MEDIUM", IsMouseOver = false, HasFocus = false }
    return setmetatable(o, { __index = function(_, k)
      if k == "SetScript" then return function(self, n, fn) self.scripts[n] = fn end end
      if k == "GetScript" then return function(self, n) return self.scripts[n] end end
      if k == "Show" then return function(self) self.shown = true end end
      if k == "Hide" then return function(self) self.shown = false end end
      if k == "SetShown" then return function(self, v) self.shown = v and true or false end end
      if k == "IsShown" then return function(self) return self.shown end end
      if k == "SetText" then return function(self, t) self.text = t end end
      if k == "GetText" then return function(self) return self.text end end
      if k == "SetPoint" then return function(self, ...) self.points[#self.points + 1] = { ... } end end
      if k == "ClearAllPoints" then return function(self) self.points = {} end end
      if k == "SetFocus" then return function(self) self.focused = true end end
      if k == "ClearFocus" then return function(self) self.focused = false end end
      if k == "CreateTexture" or k == "CreateFontString" then return function(self) return STUB_FRAME(self) end end
      if fixed[k] ~= nil then local v = fixed[k]; return function() return v end end
      return function() end
    end })
  end
  function STUB_CREATE_FRAME(_, name, parent) local f = STUB_FRAME(parent); if name then _G[name] = f end; return f end
  UIParent = STUB_FRAME()
  UISpecialFrames = {}
  C_Timer = { After = function() end, NewTimer = function() return { Cancel = function() end } end }
  InCombatLockdown = function() return false end
```

Insert before `// --- Summary`:

```js
// --- Tiles: smoke test with stand-in frames ---------------------------------------------
run(`
  local S, T = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles
  S.Reset()
  -- The events section installs a minimal CreateFrame of its own; use the stand-ins here.
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  local column = _G.HorizonSuiteEchoColumn
  check("the column exists and is shown", column and column:IsShown(), "missing")
  check("the default anchor is bottom right", column.points[1] and column.points[1][1] == "BOTTOMRIGHT", column.points[1] and column.points[1][1])

  S.Add({ convKey = "w:Brisa-Horizon", text = "got the leather", class = "DRUID", sender = "Brisa-Horizon" })
  local tile = T.TileFor("w:Brisa-Horizon")
  check("a whisper gets a tile with its initial", tile and tile.convKey == "w:Brisa-Horizon" and tile.letter.text == "B", tile and tile.letter.text)
  check("a loud unread shows the dot", tile.dot.shown == true, tile.dot.shown)
  local toast = T._toast()
  check("a loud message shows the toast", toast and toast.shown and toast.convKey == "w:Brisa-Horizon", toast and toast.convKey)
  check("the toast body is the message", toast.entry.body.text == "got the leather", toast.entry.body.text)
  check("the toast title is the name", toast.entry.title.text == "Brisa", toast.entry.title.text)

  S.Add({ convKey = "party", text = "pull", sender = "Tank-Horizon" })
  S.Add({ convKey = "party", text = "go", sender = "Tank-Horizon" })
  local ptile = T.TileFor("party")
  check("a party tile shows its count", ptile and ptile.count.text == "2" and not ptile.dot.shown, ptile and ptile.count.text)
  check("a count message does not toast", toast.convKey == "w:Brisa-Horizon", toast.convKey)

  S.Add({ convKey = "w:Secret-Horizon", text = SECRET("boss"), secret = true, sender = "Secret-Horizon" })
  check("a secret message toasts as 'new message'", toast.entry.body.text == "ECHO_NEW_MESSAGE", toast.entry.body.text)

  T.Hold(true)
  toast:Hide()
  S.Add({ convKey = "w:Vexa-Horizon", text = "gz", sender = "Vexa-Horizon" })
  check("in combat the toast is held", not toast.shown, "shown")
  T.Hold(false)
  check("after combat the held toast plays", toast.shown and toast.convKey == "w:Vexa-Horizon", toast.convKey)

  for i = 1, 10 do S.Add({ convKey = "w:Many" .. i .. "-Horizon", text = "hi" }) end
  local overflow = T._overflow()
  check("past the cap an overflow tile shows the rest", overflow.shown and overflow.letter.text:sub(1, 1) == "+", overflow.letter.text)

  S.CountUnrouted(); S.CountUnrouted()
  local marker = T._marker()
  check("the marker shows unrouted messages", marker.shown and marker.text.text == "ECHO_IN_CHAT", marker.text.text)
  marker.scripts.OnClick(marker)
  check("clicking the marker clears it", S.GetUnroutedCount() == 0 and not marker.shown, S.GetUnroutedCount())

  S.Close("w:Brisa-Horizon")
  check("a closed conversation loses its tile", T.TileFor("w:Brisa-Horizon") == nil, "still there")

  T.Disable()
  check("disable hides the column", not column:IsShown(), "shown")
  local ok = pcall(S.Add, { convKey = "w:After-Horizon", text = "x" })
  check("a disabled column ignores new messages", ok, "threw")
  S.Reset()
`, 'tiles');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Expected: exit 1 with `ENOENT` for `modules/Echo/EchoTiles.lua`.

- [ ] **Step 3: Create `modules/Echo/EchoTiles.lua`**

```lua
--[[
    Horizon Suite - Echo - Tiles
    The collapsed column: a tile per open conversation on a screen edge (top conversation
    highest), a +N overflow tile, the stack button (the drag handle when unlocked), the
    "n in chat" marker for messages Echo could not file, and the preview toast.
    Blizzard: CreateFrame, FCF_SelectDockFrame. Shared: Augment toast chrome and motion.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo
local L = addon.L

local Tiles = {}
Echo.Tiles = Tiles

Tiles.TILE_SIZE = 40
Tiles.GAP = 6
Tiles.TOAST_WIDTH = 240
Tiles.TOAST_HEIGHT = 48

local STEP = Tiles.TILE_SIZE + Tiles.GAP

Echo.FLAT = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
}

local column, stackButton, overflowTile, marker, toast
local tiles = {}
local pending = {}          -- keys to toast after combat, newest first
local queue                 -- View toast queue, made on first Enable
Tiles.holding = false

local function FontPath()
    return (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"
end

--- A FontString in the addon's default font.
-- @param parent Frame
-- @param size number
-- @param flags string|nil  "" for none; defaults to "OUTLINE"
-- @return FontString
function Echo.NewText(parent, size, flags)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetFont(FontPath(), size, flags or "OUTLINE")
    return fs
end

local function HoverEnter()
    if Echo.Stack then Echo.Stack.HoverEnter() end
end

local function HoverLeave()
    if Echo.Stack then Echo.Stack.HoverLeave() end
end

local function PaintGlyphFrame(frame, r, g, b)
    local bg = Echo.View.GLYPH_BG
    frame:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
    frame:SetBackdropBorderColor(r, g, b, 0.8)
end

local function CreateTile()
    local b = CreateFrame("Button", nil, column, "BackdropTemplate")
    b:SetSize(Tiles.TILE_SIZE, Tiles.TILE_SIZE)
    b:SetBackdrop(Echo.FLAT)
    b.letter = Echo.NewText(b, 16, "")
    b.letter:SetPoint("CENTER", b, "CENTER", 0, 0)
    local a = Echo.View.ACCENT
    b.dot = b:CreateTexture(nil, "OVERLAY")
    b.dot:SetSize(8, 8)
    b.dot:SetPoint("TOPRIGHT", b, "TOPRIGHT", 3, 3)
    b.dot:SetColorTexture(a.r, a.g, a.b, 1)
    b.count = Echo.NewText(b, 10)
    b.count:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -2, 2)
    b:RegisterForClicks("LeftButtonUp")
    b:SetScript("OnClick", function(self)
        if self.convKey and Echo.Stack then Echo.Stack.Open(self.convKey) end
    end)
    b:SetScript("OnEnter", HoverEnter)
    b:SetScript("OnLeave", HoverLeave)
    return b
end

local function PaintTile(b, conv)
    local spec = Echo.View.TileSpec(conv)
    b.convKey = conv.key
    b.letter:SetText(spec.letter)
    if spec.glyph then
        PaintGlyphFrame(b, spec.r, spec.g, spec.b)
        b.letter:SetTextColor(spec.r, spec.g, spec.b, 1)
    else
        b:SetBackdropColor(spec.r, spec.g, spec.b, 0.95)
        b:SetBackdropBorderColor(0, 0, 0, 0.7)
        b.letter:SetTextColor(0.05, 0.05, 0.07, 1)
    end
    b.dot:SetShown(spec.badge == "dot")
    b.count:SetText(spec.badge == "count" and tostring(spec.count) or "")
    b:Show()
end

local function SavePosition()
    local x = column:GetCenter()
    local y = column:GetBottom()
    if not x or not y then return end
    addon.SetDB("echoX", math.floor(x + 0.5))
    addon.SetDB("echoY", math.floor(y + 0.5))
end

--- Anchor, scale and strata from settings. Unmoved, the column sits bottom right and
-- grows upward; once dragged it is anchored by its bottom centre.
function Tiles.ApplyPosition()
    if not column then return end
    column:ClearAllPoints()
    local x, y = tonumber(Echo.Setting("echoX")), tonumber(Echo.Setting("echoY"))
    if x and y then
        column:SetPoint("BOTTOM", UIParent, "BOTTOMLEFT", x, y)
    else
        column:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -24, 240)
    end
    column:SetScale(tonumber(Echo.Setting("echoScale")) or 1)
    column:SetFrameStrata(Echo.Setting("echoFrameStrata") or "MEDIUM")
end

function Tiles.ResetPosition()
    addon.SetDB("echoX", nil)
    addon.SetDB("echoY", nil)
    Tiles.ApplyPosition()
end

local function CreateColumn()
    local View = Echo.View
    column = CreateFrame("Frame", "HorizonSuiteEchoColumn", UIParent)
    column:SetSize(Tiles.TILE_SIZE, Tiles.TILE_SIZE)
    column:SetMovable(true)
    column:SetClampedToScreen(true)

    stackButton = CreateFrame("Button", nil, column, "BackdropTemplate")
    stackButton:SetSize(Tiles.TILE_SIZE, Tiles.TILE_SIZE)
    stackButton:SetPoint("BOTTOM", column, "BOTTOM", 0, 0)
    stackButton:SetBackdrop(Echo.FLAT)
    stackButton:SetBackdropColor(View.PANEL_BG[1], View.PANEL_BG[2], View.PANEL_BG[3], View.PANEL_BG[4])
    stackButton:SetBackdropBorderColor(View.PANEL_BORDER[1], View.PANEL_BORDER[2], View.PANEL_BORDER[3], View.PANEL_BORDER[4])
    local icon = stackButton:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", stackButton, "CENTER", 0, 0)
    icon:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-Chat-Up")
    stackButton:RegisterForClicks("LeftButtonUp")
    stackButton:RegisterForDrag("LeftButton")
    stackButton:SetScript("OnClick", function()
        if Echo.Stack then Echo.Stack.Toggle() end
    end)
    stackButton:SetScript("OnDragStart", function()
        if InCombatLockdown() or Echo.Setting("echoLockPosition") then return end
        column.moving = true
        column:StartMoving()
    end)
    stackButton:SetScript("OnDragStop", function()
        if not column.moving then return end
        column.moving = false
        column:StopMovingOrSizing()
        SavePosition()
        Tiles.ApplyPosition()
    end)
    stackButton:SetScript("OnEnter", HoverEnter)
    stackButton:SetScript("OnLeave", HoverLeave)

    marker = CreateFrame("Button", nil, column)
    marker:SetSize(90, 16)
    marker:SetPoint("RIGHT", stackButton, "LEFT", -6, 0)
    marker.text = Echo.NewText(marker, 11)
    marker.text:SetPoint("RIGHT", marker, "RIGHT", 0, 0)
    marker.text:SetTextColor(0.75, 0.77, 0.85, 1)
    marker:SetScript("OnClick", function()
        Echo.Store.ClearUnrouted()
        if FCF_SelectDockFrame and DEFAULT_CHAT_FRAME then pcall(FCF_SelectDockFrame, DEFAULT_CHAT_FRAME) end
    end)
    marker:Hide()

    overflowTile = CreateTile()
    overflowTile:Hide()
end

--- Redraw every tile from the Store. Cheap: at most echoMaxTiles + 1 frames.
function Tiles.Refresh()
    if not column or not column:IsShown() then return end
    local View = Echo.View
    local list = Echo.Store.List()
    local visible, overflow = View.Column(list, tonumber(Echo.Setting("echoMaxTiles")) or 8)
    local slot = 1
    if overflow > 0 then
        overflowTile.convKey = list[#visible + 1].key
        overflowTile.letter:SetText("+" .. overflow)
        PaintGlyphFrame(overflowTile, View.ACCENT.r, View.ACCENT.g, View.ACCENT.b)
        overflowTile.letter:SetTextColor(0.85, 0.87, 0.95, 1)
        overflowTile.dot:Hide()
        overflowTile.count:SetText("")
        overflowTile:ClearAllPoints()
        overflowTile:SetPoint("BOTTOM", column, "BOTTOM", 0, slot * STEP)
        overflowTile:Show()
        slot = slot + 1
    else
        overflowTile.convKey = nil
        overflowTile:Hide()
    end
    for i = #visible, 1, -1 do
        local b = tiles[i]
        if not b then
            b = CreateTile()
            tiles[i] = b
        end
        PaintTile(b, visible[i])
        b:ClearAllPoints()
        b:SetPoint("BOTTOM", column, "BOTTOM", 0, slot * STEP)
        slot = slot + 1
    end
    for i = #visible + 1, #tiles do
        tiles[i].convKey = nil
        tiles[i]:Hide()
    end
    column:SetHeight(slot * STEP - Tiles.GAP)

    local unrouted = Echo.Store.GetUnroutedCount()
    marker.text:SetText(unrouted > 0 and L["ECHO_IN_CHAT"]:format(unrouted) or "")
    marker:SetShown(unrouted > 0)
end

--- The frame a conversation's toast points at: its tile, else nil.
-- @param convKey string
-- @return Frame|nil
function Tiles.TileFor(convKey)
    for _, b in ipairs(tiles) do
        if b.convKey == convKey and b:IsShown() then return b end
    end
    return nil
end

local function ToastUpdate(self, elapsed)
    local M = addon.Augment and addon.Augment.ToastMotion
    if not M then
        self:Hide()
        return
    end
    local hold = tonumber(Echo.Setting("echoToastSeconds")) or 4
    if self:IsMouseOver() and self.t >= M.ENTRANCE_DUR then
        self.t = M.ENTRANCE_DUR  -- hovering keeps it up; the hold restarts on leave
    else
        self.t = self.t + elapsed
    end
    local alpha, offset = 1, 0
    if self.t < M.ENTRANCE_DUR then
        local p = M.Ease(self.t / M.ENTRANCE_DUR)
        alpha, offset = p, (1 - p) * M.SLIDE_DIST
    elseif self.t >= M.ENTRANCE_DUR + hold then
        local p = (self.t - M.ENTRANCE_DUR - hold) / M.EXIT_DUR
        if p >= 1 then
            self:Hide()
            Tiles.NextToast()
            return
        end
        alpha = 1 - M.Ease(p, "in")
    end
    self:SetAlpha(alpha)
    self:ClearAllPoints()
    self:SetPoint("RIGHT", self.anchor, "LEFT", -8 - offset, 0)
end

local function CreateToast()
    local f = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
    f:SetSize(Tiles.TOAST_WIDTH, Tiles.TOAST_HEIGHT)
    f:SetClampedToScreen(true)
    f:Hide()
    local entry = { frame = f }
    entry.iconBg = f:CreateTexture(nil, "BACKGROUND")
    entry.iconDark = f:CreateTexture(nil, "BORDER")
    entry.iconDark:SetColorTexture(0, 0, 0, 0.6)
    entry.icon = f:CreateTexture(nil, "ARTWORK")
    entry.letter = Echo.NewText(f, 14, "")
    entry.letter:SetPoint("CENTER", entry.icon, "CENTER", 0, 0)
    entry.title = Echo.NewText(f, 12)
    entry.title:SetJustifyH("LEFT")
    entry.title:SetWordWrap(false)
    entry.body = Echo.NewText(f, 12, "")
    entry.body:SetJustifyH("LEFT")
    entry.body:SetWordWrap(false)
    entry.body:SetTextColor(0.92, 0.93, 0.97, 1)
    f.entry = entry
    f.t = 0
    f:RegisterForClicks("LeftButtonUp")
    f:SetScript("OnClick", function(self)
        self:Hide()
        if self.convKey and Echo.Stack then Echo.Stack.Open(self.convKey) end
    end)
    f:SetScript("OnUpdate", ToastUpdate)
    toast = f
end

--- Show a conversation's newest incoming message beside its tile.
-- @param convKey string
-- @return boolean shown
function Tiles.ShowToast(convKey)
    if not column or not column:IsShown() then return false end
    local View = Echo.View
    local conv = Echo.Store.Get(convKey)
    local msg = conv and View.LastIncoming(conv)
    if not msg then return false end
    if not toast then CreateToast() end
    local entry = toast.entry
    local spec = View.TileSpec(conv)
    if spec.glyph then
        local bg = View.GLYPH_BG
        entry.icon:SetColorTexture(bg[1], bg[2], bg[3], 1)
        entry.letter:SetTextColor(spec.r, spec.g, spec.b, 1)
    else
        entry.icon:SetColorTexture(spec.r, spec.g, spec.b, 1)
        entry.letter:SetTextColor(0.05, 0.05, 0.07, 1)
    end
    entry.letter:SetText(spec.letter)
    entry.title:SetText(View.DisplayName(conv))
    if msg.secret or Echo.IsSecret(msg.text) then
        entry.body:SetText(L["ECHO_NEW_MESSAGE"])
    else
        entry.body:SetText(View.LineText(conv, msg))
    end
    local TS = addon.Augment and addon.Augment.ToastStyles
    if TS and TS.ApplyChrome then
        local a = View.ACCENT
        TS.ApplyChrome(entry, Echo.Setting("echoToastStyle"),
            { r = a.r, g = a.g, b = a.b, br = spec.r, bg = spec.g, bb = spec.b },
            { textMode = "dual", iconSide = "left", iconSize = 28, iconGap = 8, iconBgPad = 2,
              scale = function(v) return v end })
    end
    toast:SetScale(column:GetScale())
    toast:SetFrameStrata(column:GetFrameStrata())
    toast.anchor = Tiles.TileFor(convKey) or stackButton
    toast.convKey = convKey
    toast.t = 0
    toast:SetAlpha(0)
    toast:ClearAllPoints()
    toast:SetPoint("RIGHT", toast.anchor, "LEFT", -8, 0)
    toast:Show()
    return true
end

--- Play the next toast held over from combat.
function Tiles.NextToast()
    while #pending > 0 do
        local key = table.remove(pending, 1)
        if Tiles.ShowToast(key) then return end
    end
end

--- Hold loud toasts (combat) or release them, newest first, one per conversation.
-- @param on boolean
function Tiles.Hold(on)
    Tiles.holding = on and true or false
    if not queue then queue = Echo.View.NewToastQueue() end
    if not Tiles.holding then
        pending = queue:Release()
        Tiles.NextToast()
    end
end

--- Store listener: redraw, then toast or hold a loud message.
function Tiles.OnStoreChange(convKey, change)
    Tiles.Refresh()
    if change ~= "toast" or not convKey then return end
    if Tiles.holding then
        local conv = Echo.Store.Get(convKey)
        local last = conv and conv.messages[#conv.messages]
        queue:Hold(convKey, last and last.seq or 0)
    else
        Tiles.ShowToast(convKey)
    end
end

function Tiles.Enable()
    if not column then CreateColumn() end
    if not queue then queue = Echo.View.NewToastQueue() end
    if not Tiles.subscribed then
        Echo.Store.Subscribe(Tiles.OnStoreChange)
        Tiles.subscribed = true
    end
    Tiles.ApplyPosition()
    column:Show()
    Tiles.Refresh()
end

function Tiles.Disable()
    if Tiles.subscribed then
        Echo.Store.Unsubscribe(Tiles.OnStoreChange)
        Tiles.subscribed = false
    end
    if toast then toast:Hide() end
    if column then column:Hide() end
    pending = {}
    Tiles.holding = false
end

-- Test and debug handles.
function Tiles._toast() return toast end
function Tiles._overflow() return overflowTile end
function Tiles._marker() return marker end
```

Add `modules/Echo/EchoTiles.lua` to `HorizonSuite.toc` after `modules/Echo/EchoView.lua`.

- [ ] **Step 4: Run the tests and parse-check**

Expected: `282 passed, 0 failed`; `modules/Echo/EchoTiles.lua parses`.

- [ ] **Step 5: Commit**

```bash
git add modules/Echo/EchoTiles.lua HorizonSuite.toc tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): draw the tile column with badges and a preview toast" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 5: The peek stack and quick reply

**Files:**
- Create: `modules/Echo/EchoStack.lua`
- Modify: `HorizonSuite.toc` (`modules/Echo/EchoStack.lua` after `modules/Echo/EchoTiles.lua`)
- Modify: `Bindings.xml` (two bindings appended before `</Bindings>`)
- Test: `tools/test_echo_logic.js` (add `EchoStack.lua` to `FILES` after `EchoTiles.lua`; new section)

**Interfaces:**
- Consumes: `Echo.View`, `Echo.Setting`, `Echo.NewText`, `Echo.FLAT`, `Echo.Store` (`List`, `Subscribe`, `Unsubscribe`, `MarkRead`, `Close`, `Now`), `Echo.Send.Send`, the global `HorizonSuiteEchoColumn`, `Echo.Card` (plan 3; `Echo.Card.Open(convKey)`, may be nil).
- Produces:
  - Opening and closing: `Stack.Open(convKey|nil, focus|nil)`, `Stack.Hide()`, `Stack.Toggle()`, `Stack.ReplyToNewest()`.
  - Navigation: `Stack.Flip(step)`, `Stack.CloseCurrent()`, `Stack.Render()`.
  - Hover: `Stack.HoverEnter()`, `Stack.HoverLeave()`.
  - Lifecycle: `Stack.Enable()`, `Stack.Disable()`, `Stack.OnStoreChange(convKey, change)`.
  - Test handle `Stack._frames() -> { root, card, edit, more }`.
- Frame global: `HorizonSuiteEchoStack`, registered in `UISpecialFrames` so Escape closes it when the reply box isn't focused.

- [ ] **Step 1: Write the failing smoke tests**

Add `'modules/Echo/EchoStack.lua',` to `FILES` after `'modules/Echo/EchoTiles.lua',`. Insert before `// --- Summary`:

```js
// --- Stack: smoke test with stand-in frames ---------------------------------------------
run(`
  local S, T, K = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles, HorizonSuite.Echo.Stack
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  local sent = {}
  C_ChatInfo = { SendChatMessage = function(msg, chatType, _, target) sent[#sent + 1] = chatType .. ":" .. tostring(target) .. ":" .. msg end }
  T.Enable()
  K.Enable()
  local f = K._frames()
  check("the stack starts hidden", not f.root:IsShown(), "shown")
  K.Open(nil)
  check("with no conversations the stack stays shut", not f.root:IsShown(), "shown")
  check("escape can close the stack", UISpecialFrames[#UISpecialFrames] == "HorizonSuiteEchoStack", UISpecialFrames[#UISpecialFrames])

  S.Add({ convKey = "w:Brisa-Horizon", text = "got the leather", class = "DRUID", sender = "Brisa-Horizon" })
  S.Add({ convKey = "w:Brisa-Horizon", text = "can you craft it?", class = "DRUID", sender = "Brisa-Horizon" })
  S.Add({ convKey = "w:Vexa-Horizon", text = "gz", sender = "Vexa-Horizon" })
  K.Open("w:Brisa-Horizon")
  check("open shows the stack", f.root:IsShown(), "hidden")
  check("the chosen conversation is on top", f.card.name.text == "Brisa", f.card.name.text)
  check("the top card shows the newest message last", f.card.lines[2].text == "can you craft it?", f.card.lines[2].text)
  check("showing a card marks it read", S.Get("w:Brisa-Horizon").unread == 0, S.Get("w:Brisa-Horizon").unread)
  check("nothing peeks out behind the last card", f.behind[1].shown == false, tostring(f.behind[1].shown))

  f.edit:SetText("sure, mail them")
  f.edit.scripts.OnEnterPressed(f.edit)
  check("enter sends to the top conversation", sent[1] == "WHISPER:Brisa-Horizon:sure, mail them", sent[1])
  check("the reply box empties after sending", f.edit.text == "", f.edit.text)
  check("the stack stays open after sending", f.root:IsShown(), "closed")
  check("sending keeps the same card on top", f.card.name.text == "Brisa", f.card.name.text)
  check("the reply shows on the card", f.card.lines[3].text == "sure, mail them", f.card.lines[3].text)
  f.edit.scripts.OnEnterPressed(f.edit)
  check("enter on an empty box only leaves it", f.edit.focused == false and #sent == 1, #sent)

  check("the other card peeks out behind", f.behind[1].shown and f.behind[1].name.text == "Vexa", f.behind[1].name.text)
  K.Flip(1)
  check("the wheel flips to the next card", f.card.name.text == "Vexa", f.card.name.text)
  K.Flip(5)
  check("flipping stops at the last card", f.card.name.text == "Vexa", f.card.name.text)
  K.Flip(-5)
  check("flipping stops at the first card", f.card.name.text == "Brisa", f.card.name.text)

  K.ReplyToNewest()
  check("reply-to-newest opens with the box focused", f.root:IsShown() and f.edit.focused == true, tostring(f.edit.focused))
  check("reply-to-newest picks the newest loud conversation", f.card.name.text == "Brisa", f.card.name.text)
  f.edit.scripts.OnEscapePressed(f.edit)
  check("escape leaves the box first", f.edit.focused == false and f.root:IsShown(), tostring(f.edit.focused))

  K.CloseCurrent()
  check("closing the top card shows the next conversation", f.card.name.text == "Vexa" and not S.Get("w:Brisa-Horizon").open, f.card.name.text)

  K.Hide()
  check("hide closes the stack", not f.root:IsShown(), "shown")
  K.Toggle()
  check("toggle opens it", f.root:IsShown(), "hidden")
  K.Toggle()
  check("toggle closes it", not f.root:IsShown(), "shown")

  K.Disable()
  T.Disable()
  check("a disabled stack ignores new messages", pcall(S.Add, { convKey = "w:Late-Horizon", text = "x" }), "threw")
  C_ChatInfo = nil
  S.Reset()
`, 'stack');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Expected: exit 1 with `ENOENT` for `modules/Echo/EchoStack.lua`.

- [ ] **Step 3: Create `modules/Echo/EchoStack.lua`**

```lua
--[[
    Horizon Suite - Echo - Stack
    The peek stack beside the tile column: open conversations as cards, the chosen one on
    top showing its last few messages and a quick-reply box, the next ones peeking out
    behind it. The mouse wheel flips cards. Opens on hover, from the stack button, a tile,
    a toast or a keybind; closes when the mouse leaves unless the reply box has focus.
    Blizzard: CreateFrame, C_Timer, UISpecialFrames, UIPanelCloseButton.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo
local L = addon.L

local Stack = {}
Echo.Stack = Stack

Stack.WIDTH = 320
Stack.HEIGHT = 176
Stack.FAN = 10          -- px of each card behind that shows above the one in front
Stack.BEHIND = 2        -- cards drawn behind the top card
Stack.LINES = 3         -- messages on the top card
Stack.HOVER_CLOSE = 0.4

local root, card, edit, more
local behind = {}
local list, cursor = {}, 1
local currentKey            -- the card on top follows its conversation, not its position
local openTimer, closeTimer

local function Paint(frame, alpha)
    local bg, border = Echo.View.PANEL_BG, Echo.View.PANEL_BORDER
    frame:SetBackdrop(Echo.FLAT)
    frame:SetBackdropColor(bg[1], bg[2], bg[3], alpha or bg[4])
    frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
end

local function FontPath()
    return (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"
end

local function CreateEdit()
    edit = CreateFrame("EditBox", nil, card, "BackdropTemplate")
    edit:SetHeight(26)
    edit:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 12, 12)
    edit:SetBackdrop(Echo.FLAT)
    edit:SetBackdropColor(0.03, 0.03, 0.05, 0.95)
    edit:SetBackdropBorderColor(0.28, 0.30, 0.38, 0.65)
    edit:SetFont(FontPath(), 12, "")
    edit:SetTextInsets(8, 8, 0, 0)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(1020)
    edit.placeholder = Echo.NewText(edit, 12, "")
    edit.placeholder:SetPoint("LEFT", edit, "LEFT", 8, 0)
    edit.placeholder:SetTextColor(0.5, 0.52, 0.6, 1)
    edit:SetScript("OnEnterPressed", function(self)
        local text = self:GetText()
        local conv = list[cursor]
        if text == "" or not conv then
            self:ClearFocus()
            return
        end
        Echo.Send.Send(conv.key, text)
        self:SetText("")
    end)
    edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    edit:SetScript("OnEditFocusGained", function(self) self.placeholder:Hide() end)
    edit:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then self.placeholder:Show() end
        Stack.HoverLeave()
    end)
    -- A keybind that focuses the box must not type its own key into it.
    edit:SetScript("OnChar", function(self)
        if self.swallow then
            self.swallow = false
            self:SetText("")
        end
    end)
end

local function Create()
    root = CreateFrame("Frame", "HorizonSuiteEchoStack", UIParent)
    root:SetSize(Stack.WIDTH, Stack.HEIGHT + Stack.FAN * Stack.BEHIND + 18)
    root:SetClampedToScreen(true)
    root:EnableMouse(true)
    root:EnableMouseWheel(true)
    root:Hide()
    root:SetScript("OnMouseWheel", function(_, delta) Stack.Flip(-delta) end)
    root:SetScript("OnEnter", function() Stack.HoverEnter() end)
    root:SetScript("OnLeave", function() Stack.HoverLeave() end)
    table.insert(UISpecialFrames, "HorizonSuiteEchoStack")

    for i = 1, Stack.BEHIND do
        local b = CreateFrame("Frame", nil, root, "BackdropTemplate")
        Paint(b, 0.9)
        b:SetSize(Stack.WIDTH - 16 * i, Stack.HEIGHT)
        b:SetPoint("BOTTOM", root, "BOTTOM", 0, Stack.FAN * i)
        b:SetFrameLevel(root:GetFrameLevel() + Stack.BEHIND - i + 1)
        b.name = Echo.NewText(b, 10)
        b.name:SetPoint("TOPLEFT", b, "TOPLEFT", 10, -1)
        behind[i] = b
    end

    card = CreateFrame("Frame", nil, root, "BackdropTemplate")
    Paint(card)
    card:SetSize(Stack.WIDTH, Stack.HEIGHT)
    card:SetPoint("BOTTOM", root, "BOTTOM", 0, 0)
    card:SetFrameLevel(root:GetFrameLevel() + Stack.BEHIND + 1)
    card:EnableMouse(true)

    local a = Echo.View.ACCENT
    local rule = card:CreateTexture(nil, "OVERLAY")
    rule:SetColorTexture(a.r, a.g, a.b, 1)
    rule:SetHeight(2)
    rule:SetPoint("TOPLEFT", card, "TOPLEFT", 0, 0)
    rule:SetPoint("TOPRIGHT", card, "TOPRIGHT", 0, 0)

    card.tile = card:CreateTexture(nil, "ARTWORK")
    card.tile:SetSize(28, 28)
    card.tile:SetPoint("TOPLEFT", card, "TOPLEFT", 12, -12)
    card.letter = Echo.NewText(card, 14, "")
    card.letter:SetPoint("CENTER", card.tile, "CENTER", 0, 0)
    card.name = Echo.NewText(card, 13)
    card.name:SetPoint("TOPLEFT", card.tile, "TOPRIGHT", 8, 0)
    card.name:SetPoint("RIGHT", card, "RIGHT", -34, 0)
    card.name:SetJustifyH("LEFT")
    card.name:SetWordWrap(false)
    card.meta = Echo.NewText(card, 10, "")
    card.meta:SetPoint("TOPLEFT", card.name, "BOTTOMLEFT", 0, -3)
    card.meta:SetTextColor(0.55, 0.60, 0.75, 1)

    card.close = CreateFrame("Button", nil, card, "UIPanelCloseButton")
    card.close:SetPoint("TOPRIGHT", card, "TOPRIGHT", -2, -2)
    card.close:SetScript("OnClick", function() Stack.CloseCurrent() end)

    card.lines = {}
    for i = 1, Stack.LINES do
        local fs = Echo.NewText(card, 12, "")
        fs:SetWidth(Stack.WIDTH - 24)
        fs:SetJustifyH("LEFT")
        fs:SetWordWrap(true)
        fs:SetMaxLines(2)
        if i == 1 then
            fs:SetPoint("TOPLEFT", card, "TOPLEFT", 12, -52)
        else
            fs:SetPoint("TOPLEFT", card.lines[i - 1], "BOTTOMLEFT", 0, -3)
        end
        card.lines[i] = fs
    end

    CreateEdit()

    card.open = CreateFrame("Button", nil, card, "BackdropTemplate")
    card.open:SetSize(60, 26)
    card.open:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -12, 12)
    Paint(card.open)
    card.open.text = Echo.NewText(card.open, 12, "")
    card.open.text:SetPoint("CENTER", card.open, "CENTER", 0, 0)
    card.open.text:SetText(L["ECHO_OPEN"])
    card.open:SetScript("OnClick", function()
        local conv = list[cursor]
        if conv and Echo.Card then
            Stack.Hide()
            Echo.Card.Open(conv.key)
        end
    end)

    more = Echo.NewText(root, 10, "")
    more:SetPoint("BOTTOMRIGHT", root, "TOPRIGHT", 0, -12)
    more:SetTextColor(0.55, 0.60, 0.75, 1)
end

--- Redraw the stack from the Store around the current card, and mark that card read.
function Stack.Render()
    if not root or not root:IsShown() then return end
    local View = Echo.View
    list = Echo.Store.List()
    if #list == 0 then
        Stack.Hide()
        return
    end
    -- Replying moves a conversation up the list; keep the same card on top.
    if currentKey then
        for i, c in ipairs(list) do
            if c.key == currentKey then
                cursor = i
                break
            end
        end
    end
    cursor = math.max(1, math.min(cursor, #list))
    local conv = list[cursor]
    currentKey = conv.key
    local spec = View.TileSpec(conv)

    if spec.glyph then
        local bg = View.GLYPH_BG
        card.tile:SetColorTexture(bg[1], bg[2], bg[3], 1)
        card.letter:SetTextColor(spec.r, spec.g, spec.b, 1)
    else
        card.tile:SetColorTexture(spec.r, spec.g, spec.b, 1)
        card.letter:SetTextColor(0.05, 0.05, 0.07, 1)
    end
    card.letter:SetText(spec.letter)
    card.name:SetText(View.DisplayName(conv))
    card.name:SetTextColor(spec.r, spec.g, spec.b, 1)
    card.meta:SetText(View.MetaLine(conv, Echo.Store.Now()):upper())

    local recent = View.Recent(conv, Stack.LINES)
    local r, g, b = View.ChatColor(conv.kind)
    for i = 1, Stack.LINES do
        local fs, msg = card.lines[i], recent[i]
        if msg then
            fs:SetText(View.LineText(conv, msg))
            if msg.status == "failed" then
                fs:SetTextColor(1, 0.35, 0.35, 1)
            elseif msg.status == "pending" then
                fs:SetTextColor(0.6, 0.62, 0.7, 1)
            elseif msg.outgoing then
                fs:SetTextColor(0.85, 0.87, 0.95, 1)
            else
                fs:SetTextColor(r, g, b, 1)
            end
            fs:Show()
        else
            fs:SetText("")
            fs:Hide()
        end
    end

    local canOpen = Echo.Card ~= nil
    card.open:SetShown(canOpen)
    edit:SetWidth(Stack.WIDTH - 24 - (canOpen and 68 or 0))
    edit.placeholder:SetText(L["ECHO_QUICK_REPLY"])
    edit.placeholder:SetShown(edit:GetText() == "" and not edit:HasFocus())

    for i = 1, Stack.BEHIND do
        local other = list[cursor + i]
        if other then
            local ospec = View.TileSpec(other)
            behind[i].name:SetText(View.DisplayName(other))
            behind[i].name:SetTextColor(ospec.r, ospec.g, ospec.b, 1)
            behind[i]:Show()
        else
            behind[i]:Hide()
        end
    end
    local hidden = #list - cursor - Stack.BEHIND
    if hidden > 0 then
        more:SetText(L["ECHO_MORE"]:format(hidden))
    else
        more:SetText(#list > 1 and L["ECHO_SCROLL_HINT"] or "")
    end

    Echo.Store.MarkRead(conv.key)
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

local function CancelTimer(timer)
    if timer then timer:Cancel() end
end

--- Open the stack.
-- @param convKey string|nil  Card to put on top; nil for the first conversation
-- @param focus boolean|nil  Focus the quick-reply box
function Stack.Open(convKey, focus)
    if not root then Create() end
    local conversations = Echo.Store.List()
    if #conversations == 0 then return end
    cursor = 1
    if convKey then
        for i, conv in ipairs(conversations) do
            if conv.key == convKey then
                cursor = i
                break
            end
        end
    end
    currentKey = conversations[cursor].key
    CancelTimer(closeTimer)
    closeTimer = nil
    Anchor()
    root:Show()
    Stack.Render()
    if focus then
        edit:SetFocus()
        edit.swallow = true
        C_Timer.After(0, function() if edit then edit.swallow = false end end)
    end
end

function Stack.Hide()
    CancelTimer(openTimer)
    CancelTimer(closeTimer)
    openTimer, closeTimer = nil, nil
    if edit then edit:ClearFocus() end
    if root then root:Hide() end
end

function Stack.Toggle()
    if root and root:IsShown() then
        Stack.Hide()
    else
        Stack.Open(nil)
    end
end

--- Keybind: open on the conversation with the newest loud message, reply box focused.
function Stack.ReplyToNewest()
    local newest = Echo.View.NewestLoud(Echo.Store.List())
    if newest then Stack.Open(newest.key, true) end
end

--- Move to another card (the mouse wheel).
-- @param step number  +1 for the next card, -1 for the previous
function Stack.Flip(step)
    if not root or not root:IsShown() then return end
    cursor = math.max(1, math.min(cursor + step, #list))
    currentKey = list[cursor] and list[cursor].key
    Stack.Render()
end

--- The × on the top card: close that conversation (its tile goes too).
function Stack.CloseCurrent()
    local conv = list[cursor]
    if conv then Echo.Store.Close(conv.key) end
end

local function MouseOverEcho()
    local column = _G.HorizonSuiteEchoColumn
    if root and root:IsShown() and root:IsMouseOver() then return true end
    return column ~= nil and column:IsShown() and column:IsMouseOver()
end

--- The mouse entered the column or the stack: open after the hover delay (not in combat).
function Stack.HoverEnter()
    CancelTimer(closeTimer)
    closeTimer = nil
    if (root and root:IsShown()) or openTimer or InCombatLockdown() then return end
    local delay = tonumber(Echo.Setting("echoHoverDelay")) or 0.35
    openTimer = C_Timer.NewTimer(delay, function()
        openTimer = nil
        if MouseOverEcho() then Stack.Open(nil) end
    end)
end

--- The mouse left: close shortly unless it came back or the reply box has focus.
function Stack.HoverLeave()
    if openTimer and not MouseOverEcho() then
        openTimer:Cancel()
        openTimer = nil
    end
    if not root or not root:IsShown() then return end
    CancelTimer(closeTimer)
    closeTimer = C_Timer.NewTimer(Stack.HOVER_CLOSE, function()
        closeTimer = nil
        if not MouseOverEcho() and not (edit and edit:HasFocus()) then Stack.Hide() end
    end)
end

function Stack.OnStoreChange()
    if root and root:IsShown() then Stack.Render() end
end

function Stack.Enable()
    if not root then Create() end
    if not Stack.subscribed then
        Echo.Store.Subscribe(Stack.OnStoreChange)
        Stack.subscribed = true
    end
end

function Stack.Disable()
    if Stack.subscribed then
        Echo.Store.Unsubscribe(Stack.OnStoreChange)
        Stack.subscribed = false
    end
    Stack.Hide()
end

-- Test and debug handle.
function Stack._frames()
    return { root = root, card = card, edit = edit, more = more, behind = behind }
end
```

- [ ] **Step 4: Keybinds and TOC**

Append inside `Bindings.xml`, just before `</Bindings>`:

```xml
  <Binding name="HORIZONSUITE_ECHO_REPLY" description="Echo: Reply to newest" category="Horizon Suite">
    if HorizonSuite and HorizonSuite:IsModuleEnabled("echo") and HorizonSuite.Echo.Stack then HorizonSuite.Echo.Stack.ReplyToNewest() end
  </Binding>
  <Binding name="HORIZONSUITE_ECHO_STACK" description="Echo: Toggle stack" category="Horizon Suite">
    if HorizonSuite and HorizonSuite:IsModuleEnabled("echo") and HorizonSuite.Echo.Stack then HorizonSuite.Echo.Stack.Toggle() end
  </Binding>
```

Add `modules/Echo/EchoStack.lua` to `HorizonSuite.toc` after `modules/Echo/EchoTiles.lua`.

- [ ] **Step 5: Run the tests and parse-check**

Expected: `308 passed, 0 failed`; `modules/Echo/EchoStack.lua parses`.

- [ ] **Step 6: Commit**

```bash
git add modules/Echo/EchoStack.lua HorizonSuite.toc Bindings.xml tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): add the peek stack with quick reply and keybinds" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 6: Module wiring, slash commands and lint globals

**Files:**
- Modify: `modules/Echo/EchoModule.lua` (replace `Echo.Init` and `Echo.Disable`; add lifecycle events)
- Modify: `modules/Echo/EchoSlash.lua` (lock, unlock, reset, and help lines)
- Modify: `.luacheckrc` (read globals)

**Interfaces:**
- Consumes: `Echo.History.SaveSession`, `SessionKeys`; `Echo.Store.Restore`, `OpenKeys`, `Now`, `Reset`; `Echo.Tiles.Enable`, `Disable`, `Hold`, `ResetPosition`, `ApplyPosition`; `Echo.Stack.Enable`, `Disable`, `Hide`; `Echo.Setting`.
- Produces: `Echo.RestoreSession() -> number`; `/h echo lock | unlock | reset`.

- [ ] **Step 1: Replace `Echo.Init` and `Echo.Disable` in `modules/Echo/EchoModule.lua`**

Replace the two existing functions with:

```lua
local lifecycle  -- combat and logout events

local function OnLifecycleEvent(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        Echo.Stack.Hide()
        if Echo.Setting("echoHoldToastsInCombat") then Echo.Tiles.Hold(true) end
    elseif event == "PLAYER_REGEN_ENABLED" then
        Echo.Tiles.Hold(false)
    elseif event == "PLAYER_LOGOUT" then
        -- Fires on /reload too; the tiles open now come back if the next session starts soon.
        Echo.History.SaveSession(Echo.Store.OpenKeys(), Echo.Store.Now())
    end
end

--- Reopen the tiles saved at the end of the last session, if it ended recently.
-- @return number restored
function Echo.RestoreSession()
    return Echo.Store.Restore(Echo.History.SessionKeys(Echo.Store.Now()))
end

function Echo.Init()
    -- The key function resolves lazily: Forever only knows the realm after PLAYER_LOGIN,
    -- and History writes nothing for whispers until it does.
    Echo.History.Bind(_G[addon.DATABASE], addon._GetCurrentCharacterProfileKey)
    Echo.RestoreSession()
    Echo.Events.Enable()
    Echo.Tiles.Enable()
    Echo.Stack.Enable()
    if not lifecycle then
        lifecycle = CreateFrame("Frame")
        lifecycle:SetScript("OnEvent", OnLifecycleEvent)
    end
    lifecycle:RegisterEvent("PLAYER_REGEN_DISABLED")
    lifecycle:RegisterEvent("PLAYER_REGEN_ENABLED")
    lifecycle:RegisterEvent("PLAYER_LOGOUT")
    -- The Battle.net friends list can arrive after login; restore those tiles once it has.
    C_Timer.After(5, function()
        if addon:IsModuleEnabled("echo") then Echo.RestoreSession() end
    end)
end

function Echo.Disable()
    if lifecycle then lifecycle:UnregisterAllEvents() end
    Echo.Stack.Disable()
    Echo.Tiles.Disable()
    Echo.Events.Disable()
    Echo.Store.Reset()
    Echo.History.Unbind()
end
```

- [ ] **Step 2: Slash commands in `modules/Echo/EchoSlash.lua`**

In `HandleEchoSlash`, add these branches before `elseif cmd == "" or cmd == "help" then`:

```lua
    elseif cmd == "lock" or cmd == "unlock" then
        addon.SetDB("echoLockPosition", cmd == "lock")
        HSPrint(cmd == "lock" and "Echo: column locked."
            or "Echo: column unlocked. Drag the chat button at its foot to move it, then /h echo lock.")
    elseif cmd == "reset" then
        Echo.Tiles.ResetPosition()
        HSPrint("Echo: column moved back to the bottom right.")
```

In the help block, add after the `probe` line:

```lua
        HSPrint("  /h echo unlock       - Let the column be dragged by its chat button")
        HSPrint("  /h echo lock         - Lock the column in place")
        HSPrint("  /h echo reset        - Move the column back to the bottom right")
```

- [ ] **Step 3: Lint globals**

In `.luacheckrc`'s `read_globals`, add each of these that isn't already listed (check with `grep -n '"<name>"' .luacheckrc` first), keeping the file's style: `ChatTypeInfo`, `LOCALIZED_CLASS_NAMES_MALE`, `FCF_SelectDockFrame`, `BNGetNumFriends`, `DEFAULT_CHAT_FRAME`, `UISpecialFrames`.

- [ ] **Step 4: Run the tests and parse-check**

Expected: `308 passed, 0 failed`. Parse-check `modules/Echo/EchoModule.lua`, `modules/Echo/EchoSlash.lua` and `.luacheckrc`; all should report `parses`.

- [ ] **Step 5: Commit**

```bash
git add modules/Echo/EchoModule.lua modules/Echo/EchoSlash.lua .luacheckrc
```

```bash
git commit -m "feat(echo): wire the tiles and stack into the module with session restore" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 7: In-game check (on the Windows PC, a human step)

- [ ] **Step 1: Push and hand over the pull command**

```bash
git push -u origin feature/echo-tiles
```

The director pulls with the PowerShell one-liner for `feature/echo-tiles` and **restarts the game fully**, because the TOC gains files.

- [ ] **Step 2: Checklist (director, in game)**

1. `/h echo test`: tiles for Brisa (Druid orange), Thornwick, Vexa, a **P** party tile with a count, and a **G** guild tile with no badge. The stack button is at the foot of the column, bottom right.
2. Whisper yourself: that tile moves to the top with a dot, and a toast slides out to its left, then fades after about 4 seconds. Hovering the toast keeps it up.
3. Hover the column: after a moment the stack fans out, with the top card showing the last messages and "Quick reply…". The mouse wheel flips cards. Moving away closes it.
4. Type in the quick-reply box and press Enter: the whisper goes out, the line shows dimmed until it's sent, and the stack stays open.
5. Press Escape once: the box loses focus. Press it again: the stack closes and the game menu does **not** open.
6. Bind *Echo: Reply to newest* (Key Bindings → Horizon Suite) and press it: the stack opens on the newest whisper with the box focused, and the key's own letter is **not** typed.
7. `/h echo unlock`, drag the chat button somewhere, then `/h echo lock` and `/reload`: the column stays where you put it, and the tiles that were open come back. `/h echo reset` puts it back.
8. Log out, wait over 30 minutes (or check the next day), log in: the column starts empty; whisper a saved friend and their history returns.
9. Start a fight with the stack open: it closes. Whisper yourself mid-fight: no toast. After the fight: the toast plays.
10. `/h echo toggle` off: the column and toasts are gone.
