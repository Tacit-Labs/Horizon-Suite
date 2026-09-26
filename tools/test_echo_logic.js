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
 * Caveat: because the fake is a table, type(secret) is "table" here but
 * "string" in game. A `type(x) == "string"` check made without IsSecret first
 * therefore rejects the fake and passes this harness, yet lets a real secret
 * through. Where that matters, a test swaps in a type() that answers "string"
 * for the fake (see "secret class from the GUID lookup") and restores it.
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
  local rawType = type  -- a test may swap type() to mimic game secrets; the stub must not see it
  issecretvalue = function(v) return rawType(v) == "table" and v.__secret == true end
  UnitName = function() return "Kaelis" end
  GetNormalizedRealmName = function() return "Horizon" end
  GetPlayerInfoByGUID = function(guid)
    if guid == "Player-1-DRUID" then return "Druid", "DRUID" end
    return nil
  end
  ERR_CHAT_PLAYER_NOT_FOUND_S = "No player named '%s' is currently playing."

  -- Stand-in frames for smoke tests: every method exists and does nothing, except the
  -- handful whose results the Echo frames read back.
  function STUB_FRAME(parent)
    local o = { scripts = {}, hookScripts = {}, shown = false, parent = parent, text = "", points = {} }
    local fixed = { GetFrameLevel = 1, GetScale = 1, GetFrameStrata = "MEDIUM", IsMouseOver = false, HasFocus = false }
    return setmetatable(o, { __index = function(_, k)
      if k == "SetScript" then return function(self, n, fn) self.scripts[n] = fn end end
      if k == "HookScript" then return function(self, n, fn) self.hookScripts[n] = fn end end
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
      if k == "SetBackdropColor" then return function(self, r, g, b, a) self.bg = { r, g, b, a }; self.alpha = a end end
      if k == "SetTexture" then return function(self, tex) self.texture = tex; self.atlas = nil end end
      if k == "SetAtlas" then return function(self, atlas) self.atlas = atlas; self.texture = nil end end
      if k == "SetColorTexture" then return function(self, r, g, b, a) self.colorTexture = { r, g, b, a } end end
      if k == "SetTexCoord" then return function(self, ...) self.texCoord = { ... } end end
      if k == "SetVertexColor" then return function(self, r, g, b, a) self.vertexColor = { r, g, b, a } end end
      if k == "SetSize" then return function(self, w, h) self.width = w; self.height = h end end
      if k == "SetWidth" then return function(self, w) self.setWidth = w end end
      if k == "SetFrameLevel" then return function(self, lvl) self.frameLevel = lvl end end
      if k == "SetDrawLayer" then return function(self, layer, sublevel) self.drawLayer = layer; self.drawSublevel = sublevel end end
      if k == "CreateTexture" or k == "CreateFontString" then return function(self) return STUB_FRAME(self) end end
      if fixed[k] ~= nil then local v = fixed[k]; return function() return v end end
      return function() end
    end })
  end
  function STUB_CREATE_FRAME(_, name, parent, template) local f = STUB_FRAME(parent); f.template = template ~= "BackdropTemplate" and template or nil; if name then _G[name] = f end; return f end
  UIParent = STUB_FRAME()
  UISpecialFrames = {}
  C_Timer = { After = function() end, NewTimer = function() return { Cancel = function() end } end }
  InCombatLockdown = function() return false end

  PASS, FAIL = 0, 0
  function check(name, ok, got)
    if ok then PASS = PASS + 1
    else FAIL = FAIL + 1; print("  FAIL: " .. name .. "  got: " .. tostring(got)) end
  end
`, 'stubs');

// Load order matches HorizonSuite.toc.
const FILES = [
  'modules/Echo/EchoStore.lua',
  'modules/Echo/EchoHistory.lua',
  'modules/Echo/EchoEvents.lua',
  'modules/Echo/EchoFilter.lua',
  'modules/Echo/EchoSound.lua',
  'modules/Echo/EchoSend.lua',
  'modules/Echo/EchoView.lua',
  'modules/Echo/EchoGroups.lua',
  'modules/Echo/EchoRound.lua',
  'modules/Echo/EchoGenie.lua',
  'modules/Echo/EchoClass.lua',
  'modules/Echo/EchoRedraw.lua',
  'modules/Echo/EchoLinks.lua',
  'modules/Echo/EchoTiles.lua',
  'modules/Echo/EchoStack.lua',
  'modules/Echo/EchoMenu.lua',
  'modules/Echo/EchoCompose.lua',
  'modules/Echo/EchoCard.lua',
  'modules/Echo/EchoInput.lua',
  'modules/Echo/EchoOptions.lua',
  'modules/Echo/EchoSlash.lua',
];
for (const f of FILES) run(read(f), f);

// Views repaint synchronously in every section except the coalescing tests below.
run(`HorizonSuite.Echo.Redraw.sync = true`, 'redraw-sync');

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

  -- The server can re-encode a whisper (item links gain fields), so its echo may not match
  -- the text sent. Whisper echoes arrive in send order: confirm the oldest pending one.
  local link1 = S.AddPending("w:Re-Horizon", "look |cffa335ee|Hitem:1::|h[Cloak]|h|r")
  local link2 = S.AddPending("w:Re-Horizon", "second")
  check("a re-encoded whisper echo confirms the oldest pending",
        S.ConfirmSent({ convKey = "w:Re-Horizon", text = "look |cffa335ee|Hitem:1:0:0:0|h[Cloak]|h|r", outgoing = true }) == true
        and link1.status == "sent" and link2.status == "pending", link1.status)
  check("a re-encoded echo adds no duplicate bubble", #S.Get("w:Re-Horizon").messages == 2, #S.Get("w:Re-Horizon").messages)
  local bn = S.AddPending("bn:5", "gg |Hitem:1::|h[X]|h")
  check("a re-encoded bnet echo confirms the oldest pending",
        S.ConfirmSent({ convKey = "bn:5", text = "gg |Hitem:1:0|h[X]|h", outgoing = true }) == true
        and bn.status == "sent" and #S.Get("bn:5").messages == 1, bn.status)
  local omw = S.AddPending("party", "omw")
  check("a party echo with different text is filed as new",
        S.ConfirmSent({ convKey = "party", text = "typed in the blizzard box", outgoing = true }) == false
        and omw.status == "pending" and #S.Get("party").messages == 2, omw.status)

  local p3 = S.AddPending("w:Brisa-Horizon", "third")
  local p4 = S.AddPending("w:Brisa-Horizon", "fourth")
  check("failure marks the newest pending",
        S.MarkFailed("w:Brisa-Horizon") == p4 and p4.status == "failed" and p3.status == "pending", p4.status)
  check("failure with nothing to fail is nil", S.MarkFailed("w:Nobody-Horizon") == nil, "not nil")
  S.Reset()
`, 'store-outgoing');

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

  -- Battle.net account IDs last one session; history is keyed by BattleTag instead.
  local tags = { [77] = "Friend#1234" }
  local savedBattleNet = C_BattleNet
  C_BattleNet = { GetAccountInfoByID = function(id)
    if tags[id] == "THROW" then error("api down") end
    return tags[id] and { battleTag = tags[id] } or nil
  end }

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
  local friend = db.echoHistory.bnet["bt:Friend#1234"]
  check("bnet persisted account-wide under the BattleTag",
        friend and #friend == 1 and friend[1].text == "bnet hi", friend and #friend)
  check("bnet never persisted under the session account id", db.echoHistory.bnet["bn:77"] == nil, "keyed by id")
  check("resolver reads the BattleTag", H.BattleTagFor("bn:77") == "Friend#1234", H.BattleTagFor("bn:77"))
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
  -- Next session the same friend has a new account ID; history follows the BattleTag.
  tags = { [88] = "Friend#1234", [77] = "Other#9999" }
  S.Add({ convKey = "bn:88", text = "again" })
  check("bnet history follows the BattleTag across a new account id",
        #S.Get("bn:88").messages == 2 and S.Get("bn:88").messages[1].text == "bnet hi", #S.Get("bn:88").messages)
  S.Add({ convKey = "bn:77", text = "who dis" })
  check("a reused account id never loads another friend's history",
        #S.Get("bn:77").messages == 1 and S.Get("bn:77").messages[1].text == "who dis", #S.Get("bn:77").messages)
  check("the reused id writes to its own friend",
        #db.echoHistory.bnet["bt:Other#9999"] == 1 and #db.echoHistory.bnet["bt:Friend#1234"] == 2,
        #db.echoHistory.bnet["bt:Friend#1234"])

  local function bnetBuckets()
    local n = 0
    for _ in pairs(db.echoHistory.bnet) do n = n + 1 end
    return n
  end
  tags[55] = nil
  check("unresolvable BattleTag writes nothing",
        H.Append("bn:55", { text = "x", time = 1 }) == false and bnetBuckets() == 2, bnetBuckets())
  check("unresolvable BattleTag loads nothing", #H.Load("bn:55") == 0, #H.Load("bn:55"))
  tags[66] = SECRET("Friend#1234")
  check("secret BattleTag writes nothing",
        H.Append("bn:66", { text = "x", time = 1 }) == false and #db.echoHistory.bnet["bt:Friend#1234"] == 2,
        #db.echoHistory.bnet["bt:Friend#1234"])
  check("secret BattleTag loads nothing", #H.Load("bn:66") == 0, #H.Load("bn:66"))
  tags[44] = ""
  check("empty BattleTag writes nothing", H.Append("bn:44", { text = "x", time = 1 }) == false, "written")
  tags[33] = "THROW"
  check("a throwing lookup writes nothing", H.Append("bn:33", { text = "x", time = 1 }) == false, "written")
  C_BattleNet = nil
  check("no C_BattleNet writes nothing", H.Append("bn:88", { text = "x", time = 1 }) == false, "written")
  check("no C_BattleNet loads nothing", #H.Load("bn:88") == 0, #H.Load("bn:88"))
  C_BattleNet = savedBattleNet

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
  r = E.BuildRecord("CHAT_MSG_CHANNEL", payload("wtb ore", "Kaelis-Horizon", "Trade"))
  check("own line in a chat channel is outgoing",
        r and r.outgoing == true and r.convKey == "ch:Trade" and r.sender == nil, r and r.outgoing)
  r = E.BuildRecord("CHAT_MSG_BN_WHISPER_INFORM", payload("brb", "|Kq1|k", nil, nil, 77))
  check("bnet inform is outgoing, keyed by the account id, with no sender",
        r and r.outgoing == true and r.convKey == "bn:77" and r.sender == nil, r and r.convKey)

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
  local savedInfo = GetPlayerInfoByGUID
  GetPlayerInfoByGUID = function() return "Druid", SECRET("DRUID") end
  -- In game a secret string answers type() with "string"; make the fake do the same here,
  -- so only an IsSecret check keeps it out of the record.
  local realType = type
  type = function(v)
    if realType(v) == "table" and v.__secret == true then return "string" end
    return realType(v)
  end
  r = E.BuildRecord("CHAT_MSG_WHISPER", payload("hi", "Brisa-Horizon", nil, "Player-1-DRUID"))
  type = realType
  check("secret class from the GUID lookup is not stored", r.class == nil, r.class)
  GetPlayerInfoByGUID = savedInfo

  -- Own line with a secret sender: the readable GUID still says it is yours.
  local savedUnitGUID = UnitGUID
  UnitGUID = function(unit) if unit == "player" then return "Player-1-ME" end end
  r = E.BuildRecord("CHAT_MSG_RAID", payload("kaelis here", SECRET("Kaelis-Horizon"), nil, "Player-1-ME"))
  check("own raid line with a secret sender is outgoing", r and r.outgoing == true, r and r.outgoing)
  check("own raid line with a secret sender is not urgent", r and r.urgent == false, r and r.urgent)
  r = E.BuildRecord("CHAT_MSG_RAID", payload("go", SECRET("Lead-Horizon"), nil, "Player-1-DRUID"))
  check("another player's GUID with a secret sender is incoming", r and r.outgoing == false, r and r.outgoing)
  r = E.BuildRecord("CHAT_MSG_RAID", payload("go", SECRET("Lead-Horizon"), nil, SECRET("Player-1-ME")))
  check("a secret GUID with a secret sender is incoming", r and r.outgoing == false, r and r.outgoing)
  UnitGUID = function() return SECRET("Player-1-ME") end
  r = E.BuildRecord("CHAT_MSG_RAID", payload("go", SECRET("Lead-Horizon"), nil, "Player-1-ME"))
  check("a secret player GUID is never compared", r and r.outgoing == false, r and r.outgoing)
  UnitGUID = function(unit) if unit == "player" then return "Player-1-ME" end end
  S.Reset()
  local own = S.AddPending("raid", "omw")
  E.Dispatch("CHAT_MSG_RAID", payload("omw", SECRET("Kaelis-Horizon"), nil, "Player-1-ME"))
  check("own raid line with a secret sender confirms the pending send",
        own.status == "sent" and #S.Get("raid").messages == 1, own.status .. "/" .. #S.Get("raid").messages)
  UnitGUID = savedUnitGUID
  S.Reset()

  none, reason = E.BuildRecord("CHAT_MSG_AFK", payload("hi", "A-B"))
  check("non-Echo event is ignored", none == nil and reason == "ignored", reason)

  S.Reset()
  E.Dispatch("CHAT_MSG_WHISPER", payload("hi", "Brisa-Horizon"))
  check("dispatch files incoming", S.Get("w:Brisa-Horizon") and S.Get("w:Brisa-Horizon").unread == 1, "not filed")
  E.Dispatch("CHAT_MSG_WHISPER", payload("hi", SECRET("Who")))
  check("dispatch counts unrouted", S.GetUnroutedCount() == 1, S.GetUnroutedCount())
  E.Dispatch("CHAT_MSG_WHISPER_INFORM", payload("sure", SECRET("Brisa-Horizon")))
  check("a secret whisper recipient is counted as unrouted", S.GetUnroutedCount() == 2, S.GetUnroutedCount())
  check("a secret whisper recipient files nothing",
        #S.List() == 1 and #S.Get("w:Brisa-Horizon").messages == 1, #S.List())
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

  -- Chat messaging lockdown (Midnight encounters): file as failed, never call the API.
  local before = #sent
  C_ChatInfo.InChatMessagingLockdown = function() return true end
  Send.Send("w:Brisa-Horizon", "locked out")
  local locked = S.Get("w:Brisa-Horizon").messages
  check("lockdown does not call the send function", #sent == before, #sent)
  check("lockdown files the reply as failed",
        locked[#locked].text == "locked out" and locked[#locked].status == "failed", locked[#locked].status)
  Send.Send("bn:77", "locked bnet")
  check("lockdown blocks bnet sends too", #sent == before, #sent)
  C_ChatInfo.InChatMessagingLockdown = function() error("no api") end
  Send.Send("party", "check failed")
  check("a throwing lockdown check does not block sending", sent[#sent] == "PARTY:nil:check failed", sent[#sent])
  C_ChatInfo.InChatMessagingLockdown = nil

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

// --- Channels: zone channels keep one conversation; replies use the live index ----
run(`
  local S, E, Send = HorizonSuite.Echo.Store, HorizonSuite.Echo.Events, HorizonSuite.Echo.Send
  S.Reset()
  -- In game, arg 9 carries the zone for zone channels ("General - Zul'Aman"),
  -- arg 7 is the zone channel ID (0 for custom channels) and arg 8 the joined index.
  local function chan(text, sender, name, zoneID, index)
    return text, sender, nil, nil, nil, nil, zoneID, index, name, nil, nil, nil, nil
  end

  local r = E.BuildRecord("CHAT_MSG_CHANNEL", chan("wts", "Seller-Horizon", "General - Zul'Aman", 1, 1))
  check("zone channel keyed without the zone", r.convKey == "ch:General", r.convKey)
  check("record carries the joined index", r.channelIndex == 1, r.channelIndex)
  r = E.BuildRecord("CHAT_MSG_CHANNEL", chan("lfg", "Other-Horizon", "General - Stormwind City", 1, 1))
  check("the same zone channel elsewhere is the same conversation", r.convKey == "ch:General", r.convKey)
  r = E.BuildRecord("CHAT_MSG_CHANNEL", chan("hi", "A-Horizon", "Crafters - Guild", 0, 5))
  check("custom channel keeps its full name", r.convKey == "ch:Crafters - Guild", r.convKey)
  r = E.BuildRecord("CHAT_MSG_CHANNEL", chan("hi", "A-Horizon", "General - Zul'Aman", SECRET(1), SECRET(1)))
  check("secret zone ID falls back to the full name", r.convKey == "ch:General - Zul'Aman", r.convKey)
  check("secret index is not stored", r.channelIndex == nil, tostring(r.channelIndex))

  local joined = { [1] = "General - Stormwind City", [2] = "Trade - City", [5] = "Crafters - Guild" }
  GetChannelName = function(q)
    if type(q) == "number" then return joined[q] and q or 0, joined[q] end
    for i, name in pairs(joined) do if name == q then return i, name end end
    return 0
  end
  local function route(key)
    local rt = Send.RouteFor(key)
    return rt and (rt.chatType .. ":" .. tostring(rt.target)) or "none"
  end

  E.Dispatch("CHAT_MSG_CHANNEL", chan("wts", "Seller-Horizon", "General - Zul'Aman", 1, 1))
  check("store remembers the index", S.Get("ch:General").channelIndex == 1, S.Get("ch:General").channelIndex)
  check("reply uses the remembered index after changing zone", route("ch:General") == "CHANNEL:1", route("ch:General"))
  E.Dispatch("CHAT_MSG_CHANNEL", chan("hi", "A-Horizon", "Crafters - Guild", 0, 5))
  check("custom channel routes by its index", route("ch:Crafters - Guild") == "CHANNEL:5", route("ch:Crafters - Guild"))

  joined[1] = "LookingForGroup"
  check("a stale index pointing at another channel is not used", route("ch:General") == "none", route("ch:General"))
  joined[1] = nil
  check("a left channel cannot be sent to", route("ch:General") == "none", route("ch:General"))
  check("a channel never seen still resolves by full name", route("ch:Trade - City") == "CHANNEL:2", route("ch:Trade - City"))
  S.Reset()
`, 'channels');

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
  local aCalled = false
  local bCalled = false
  local function listenerA(key, change) aCalled = true; S.Unsubscribe(listenerA) end
  local function listenerB(key, change) bCalled = true end
  S.Subscribe(listenerA)
  S.Subscribe(listenerB)
  S.Add({ convKey = "guild", text = "x" })
  check("both listeners called even when one unsubscribes mid-notify", aCalled and bCalled, "bCalled=" .. tostring(bCalled))
  S.Reset()
`, 'store-restore');

// --- Store: restored tiles keep their saved place (final review F3) ---------------------
run(`
  local S = HorizonSuite.Echo.Store
  local function order()
    local keys = {}
    for i, c in ipairs(S.List()) do keys[i] = c.key end
    return table.concat(keys, ",")
  end
  S.Reset()
  S.Restore({ "w:A-Horizon", "w:B-Horizon" })
  S.Add({ convKey = "ch:Trade", text = "wts" })
  check("restored tiles stay above a channel that spoke after login",
        order() == "w:A-Horizon,w:B-Horizon,ch:Trade", order())

  -- The friends list arrives late: the first restore can't map the battletag yet, the
  -- retry passes the full saved list and only adds what is missing.
  S.Reset()
  S.Restore({ "w:A-Horizon" })
  S.Add({ convKey = "ch:Trade", text = "wts" })
  S.Restore({ "w:A-Horizon", "bn:9" })
  check("a late battle.net tile takes its saved place below the first",
        order() == "w:A-Horizon,bn:9,ch:Trade", order())

  S.Reset()
  S.Restore({ "w:A-Horizon" })
  S.Restore({ "bn:9", "w:A-Horizon" })
  check("a late battle.net tile saved on top goes on top", order() == "bn:9,w:A-Horizon", order())
  S.Reset()
`, 'store-restore-rank');

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
  db.echoHistory.session["Kaelis-Horizon"] = { t = 1000, keys = 5 }
  local ok, result = pcall(H.SessionKeys, 1100)
  check("corrupted keys (non-table) restores nothing without throwing", ok and #result == 0, ok and #result or "threw")
  H.SaveSession({ "w:X-Horizon" }, 1000)
  H.SetEnabledCheck(function() return false end)
  check("session with history disabled restores nothing", #H.SessionKeys(1100) == 0, "restored")
  H.SetEnabledCheck(function() return true end)
  C_BattleNet, BNGetNumFriends = savedBattleNet, savedNumFriends
  H.Unbind()
  check("unbound history has no session", #H.SessionKeys(1100) == 0 and H.SaveSession({ "w:X-Horizon" }, 1) == false, "?")
  S.Reset()
`, 'history-session');

// --- History: pruning stale conversations (plan 10, Task 1) ------------------------------
run(`
  local S, H = HorizonSuite.Echo.Store, HorizonSuite.Echo.History
  S.Reset()
  local db = {}
  local charKey = "Kaelis-Horizon"
  H.Bind(db, function() return charKey end)
  local savedBattleNet = C_BattleNet
  C_BattleNet = { GetAccountInfoByID = function(id) if id == 77 then return { battleTag = "Vexa#1234" } end end }

  H.SetMaxAge(30)
  local now = 40 * 86400 + 1000
  H.Append("w:Old-Horizon", { text = "old", time = now - 40 * 86400 })
  H.Append("w:Recent-Horizon", { text = "recent", time = now - 10 * 86400 })
  H.Append("w:PinnedStale-Horizon", { text = "pinned", time = now - 40 * 86400 })
  H.SavePref("w:PinnedStale-Horizon", nil, true)
  H.Append("bn:77", { text = "bnet old", time = now - 40 * 86400 })

  local removed = H.Prune(now)
  local mine = db.echoHistory.chars["Kaelis-Horizon"]
  check("a 40-day-old whisper list is removed at 30 days", mine["w:Old-Horizon"] == nil, "kept")
  check("a 10-day-old whisper list is kept", mine["w:Recent-Horizon"] ~= nil, "removed")
  check("a pinned stale list is kept", mine["w:PinnedStale-Horizon"] ~= nil, "removed")
  check("a stale battle.net list is pruned by its bt: key", db.echoHistory.bnet["bt:Vexa#1234"] == nil, "kept")
  check("prune returns the number of lists removed", removed == 2, removed)

  -- Fix round 1, item 5: strict > at the cutoff (a list exactly at the cutoff is kept).
  H.Append("w:AtCutoff-Horizon", { text = "boundary", time = now - 30 * 86400 })
  local removedAtBoundary = H.Prune(now)
  check("a list exactly at the cutoff is kept (strict >)", mine["w:AtCutoff-Horizon"] ~= nil, "removed")
  check("nothing removed at the exact boundary", removedAtBoundary == 0, removedAtBoundary)

  -- An empty character bucket is removed once its only list goes stale.
  S.Reset()
  charKey = "Solo-Horizon"
  H.Append("w:Gone-Horizon", { text = "bye", time = now - 40 * 86400 })
  H.Prune(now)
  check("an emptied character bucket is dropped", db.echoHistory.chars["Solo-Horizon"] == nil, "kept")

  -- Nothing is removed at 0 (Forever).
  charKey = "Kaelis-Horizon"
  H.SetMaxAge(0)
  H.Append("w:AnotherOld-Horizon", { text = "ancient", time = now - 400 * 86400 })
  local removedAtZero = H.Prune(now)
  check("nothing is removed at 0 (Forever)", removedAtZero == 0, removedAtZero)
  check("the list survives Forever", mine["w:AnotherOld-Horizon"] ~= nil, "removed")

  H.SetMaxAge(30)
  check("no root, nothing pruned", (function() H.Unbind(); return H.Prune(now) end)() == 0, "pruned")
  C_BattleNet = savedBattleNet
  S.Reset()
`, 'history-prune');

// --- History: save guild and officer chat (plan 10, Task 2) ------------------------------
run(`
  local S, H = HorizonSuite.Echo.Store, HorizonSuite.Echo.History
  S.Reset()
  S.SetPersisted("guild", false)
  S.SetPersisted("officer", false)
  local db = {}
  local charKey = "Kaelis-Horizon"
  H.Bind(db, function() return charKey end)
  local savedGetGuildInfo = GetGuildInfo
  local guildName, guildRealm = "Dawnrise", nil
  GetGuildInfo = function(unit)
    if unit ~= "player" then return nil end
    return guildName, "Officer", 3, guildRealm
  end

  check("guild key falls back to the player's own realm", H.GuildKey() == "Dawnrise-Horizon", H.GuildKey())

  -- Fix round 1, item 1: a secret name or realm never reaches a comparison other than == nil.
  do
    local realName = guildName
    guildName = SECRET("Hidden")
    check("a secret guild name gives nil", H.GuildKey() == nil, tostring(H.GuildKey()))
    guildName = realName

    local realRealm = guildRealm
    guildRealm = SECRET("HiddenRealm")
    check("a secret guild realm gives nil", H.GuildKey() == nil, tostring(H.GuildKey()))
    guildRealm = realRealm
  end

  S.SetPersisted("guild", true)
  S.Add({ convKey = "guild", text = "guild line" })
  local guildList = db.echoHistory.guilds["Dawnrise-Horizon"] and db.echoHistory.guilds["Dawnrise-Horizon"].guild
  check("a guild line is written under the guild key", guildList and #guildList == 1 and guildList[1].text == "guild line", guildList and #guildList)

  S.Add({ convKey = "officer", text = "officer line" })
  local officerList = db.echoHistory.guilds["Dawnrise-Horizon"] and db.echoHistory.guilds["Dawnrise-Horizon"].officer
  check("officer lines are not written while echoSaveOfficer is off", officerList == nil, officerList and #officerList)

  S.SetPersisted("officer", true)
  S.Add({ convKey = "officer", text = "officer line 2" })
  officerList = db.echoHistory.guilds["Dawnrise-Horizon"].officer
  check("officer lines are written once echoSaveOfficer is on", officerList and #officerList == 1 and officerList[1].text == "officer line 2", officerList and #officerList)

  for i = 1, 210 do H.Append("guild", { text = "m" .. i, time = i }) end
  local capped = db.echoHistory.guilds["Dawnrise-Horizon"].guild
  check("the guild cap is 200", #capped == 200 and capped[1].text == "m11", #capped)

  H.Append("guild", { text = "hi", time = 500, sender = "Brisa-Horizon", class = "DRUID" })
  local last = capped[#capped]
  check("sender and class are written", last.s == "Brisa-Horizon" and last.c == "DRUID", last.s)
  local loaded = H.Load("guild")
  check("sender and class round-trip on load", loaded[#loaded].sender == "Brisa-Horizon" and loaded[#loaded].class == "DRUID", loaded[#loaded].sender)

  H.Append("guild", { text = "secret sender", time = 501, sender = SECRET("Hidden-Horizon"), class = SECRET("ROGUE") })
  local secretEntry = capped[#capped]
  check("a secret sender is not written", secretEntry.s == nil, secretEntry.s)
  check("a secret class is not written", secretEntry.c == nil, secretEntry.c)

  -- A battle.net sender is a protected |K display string: never written, whatever the kind.
  local savedBattleNet = C_BattleNet
  C_BattleNet = { GetAccountInfoByID = function(id) if id == 99 then return { battleTag = "Foe#1234" } end end }
  S.Add({ convKey = "bn:99", text = "hi", sender = "|Kbnet-protected-string" })
  local bnetList = db.echoHistory.bnet["bt:Foe#1234"]
  check("a battle.net sender is never written", bnetList and bnetList[1].s == nil, bnetList and bnetList[1].s)
  C_BattleNet = savedBattleNet

  -- Nothing is written with no guild key.
  S.Reset()
  local dbNoGuild = {}
  H.Bind(dbNoGuild, function() return charKey end)
  local savedGuildName = guildName
  guildName = nil
  S.Add({ convKey = "guild", text = "no key" })
  check("nothing written with no guild key", next(dbNoGuild.echoHistory.guilds) == nil, "written")
  guildName = savedGuildName

  -- The late load prepends the saved history once the guild key resolves.
  S.Reset()
  local dbLate = {}
  H.Bind(dbLate, function() return charKey end)
  guildName = nil
  S.Add({ convKey = "guild", text = "typed before guild known" })
  check("no guild key yet: filed this session, nothing saved",
        S.Get("guild").messages[1].text == "typed before guild known" and next(dbLate.echoHistory.guilds) == nil, "?")

  dbLate.echoHistory.guilds["Dawnrise-Horizon"] = { guild = { { t = 1, text = "saved earlier" } } }
  guildName = "Dawnrise"
  S.Add({ convKey = "guild", text = "second line" })
  local msgs = S.Get("guild").messages
  check("the late load prepends the saved history once",
        #msgs == 3 and msgs[1].text == "saved earlier" and msgs[2].text == "typed before guild known" and msgs[3].text == "second line",
        #msgs)

  S.Add({ convKey = "guild", text = "third line" })
  msgs = S.Get("guild").messages
  check("the late load only happens once", #msgs == 4 and msgs[4].text == "third line", #msgs)

  -- The live toggle (fix round 1, item 2): an officer conversation created while saving is
  -- off still backfills its saved history once saving is turned on, in order.
  S.Reset()
  local dbToggle = {}
  H.Bind(dbToggle, function() return charKey end)
  guildName = "Dawnrise"
  S.SetPersisted("officer", false)
  S.Add({ convKey = "officer", text = "typed with saving off" })
  check("saving off: nothing saved, but the line still shows this session",
        S.Get("officer").messages[1].text == "typed with saving off" and next(dbToggle.echoHistory.guilds) == nil, "?")

  dbToggle.echoHistory.guilds["Dawnrise-Horizon"] = { officer = { { t = 1, text = "a" }, { t = 2, text = "b" } } }
  S.SetPersisted("officer", true)
  S.Add({ convKey = "officer", text = "typed with saving on" })
  local toggleMsgs = S.Get("officer").messages
  check("turning saving on backfills the saved lines once, in order",
        #toggleMsgs == 4 and toggleMsgs[1].text == "a" and toggleMsgs[2].text == "b"
        and toggleMsgs[3].text == "typed with saving off" and toggleMsgs[4].text == "typed with saving on",
        #toggleMsgs)

  S.Add({ convKey = "officer", text = "one more" })
  toggleMsgs = S.Get("officer").messages
  check("the backfill only happens once", #toggleMsgs == 5 and toggleMsgs[5].text == "one more", #toggleMsgs)

  -- Within the cap: a large backfill merged with the current session is trimmed to
  -- Store.MaxMessages("officer") (200), keeping the newest lines.
  S.Reset()
  local dbCap = {}
  H.Bind(dbCap, function() return charKey end)
  local bigList = {}
  for i = 1, 205 do bigList[i] = { t = i, text = "old" .. i } end
  dbCap.echoHistory.guilds["Dawnrise-Horizon"] = { officer = bigList }
  S.SetPersisted("officer", false)
  S.Add({ convKey = "officer", text = "typed with saving off" })
  S.SetPersisted("officer", true)
  S.Add({ convKey = "officer", text = "new line" })
  local cappedMsgs = S.Get("officer").messages
  check("the backfilled merge respects the message cap", #cappedMsgs == 200, #cappedMsgs)
  check("the cap keeps the newest lines", cappedMsgs[#cappedMsgs].text == "new line"
        and cappedMsgs[#cappedMsgs - 1].text == "typed with saving off", cappedMsgs[#cappedMsgs].text)

  -- SessionKeys carries guild and officer only while they are persisted.
  S.Reset()
  local dbSession = {}
  H.Bind(dbSession, function() return charKey end)
  check("session saves guild and officer when persisted",
        H.SaveSession({ "guild", "officer", "party" }, 1000) == true, "?")
  local savedKeys = dbSession.echoHistory.session["Kaelis-Horizon"].keys
  check("guild and officer saved, party dropped", table.concat(savedKeys, ",") == "guild,officer", table.concat(savedKeys, ","))
  local restored = H.SessionKeys(1600)
  check("SessionKeys restores guild and officer", table.concat(restored, ",") == "guild,officer", table.concat(restored, ","))

  S.SetPersisted("guild", false)
  S.SetPersisted("officer", false)
  H.SaveSession({ "guild", "officer" }, 2000)
  savedKeys = dbSession.echoHistory.session["Kaelis-Horizon"].keys
  check("guild/officer not saved once saving is off", #savedKeys == 0, #savedKeys)

  -- Clear wipes guilds.
  S.SetPersisted("guild", true)
  S.Add({ convKey = "guild", text = "before clear" })
  check("a guild entry exists before clear", next(dbSession.echoHistory.guilds) ~= nil, "missing")
  H.Clear()
  check("clear wipes guild history", next(dbSession.echoHistory.guilds) == nil, "kept")

  -- With echoSaveHistory off, guild isn't saved even though the guild flag is on.
  S.Reset()
  local dbOff = {}
  H.Bind(dbOff, function() return charKey end)
  H.SetEnabledCheck(function() return false end)
  S.Add({ convKey = "guild", text = "should not save" })
  check("echoSaveHistory off blocks guild saving", next(dbOff.echoHistory.guilds) == nil, "saved")
  H.SetEnabledCheck(function() return true end)

  -- Prune also covers guild and officer lists, each guild's separately (Task 1's rule).
  S.Reset()
  local dbPrune = {}
  H.Bind(dbPrune, function() return charKey end)
  H.SetMaxAge(30)
  local now2 = 40 * 86400 + 1000
  H.Append("guild", { text = "old guild line", time = now2 - 40 * 86400 })
  H.Append("officer", { text = "old officer line", time = now2 - 40 * 86400 })
  local removed2 = H.Prune(now2)
  check("prune removed both stale guild lists", removed2 == 2, removed2)
  check("an emptied guild bucket is dropped", dbPrune.echoHistory.guilds["Dawnrise-Horizon"] == nil, "kept")

  -- Fix round 1, item 3: pinning "guild" protects the current guild's list, never a stale
  -- list left behind under a different guild key.
  S.Reset()
  local dbPin = {}
  H.Bind(dbPin, function() return charKey end)
  H.SetMaxAge(30)
  local now3 = 40 * 86400 + 1000
  guildName = "Dawnrise"
  H.Append("guild", { text = "current guild line", time = now3 - 40 * 86400 })
  H.SavePref("guild", nil, true)
  dbPin.echoHistory.guilds["Oldguild-Horizon"] = { guild = { { t = now3 - 40 * 86400, text = "stale from an old guild" } } }
  local removed3 = H.Prune(now3)
  check("the current guild's pinned list survives", dbPin.echoHistory.guilds["Dawnrise-Horizon"] ~= nil
        and dbPin.echoHistory.guilds["Dawnrise-Horizon"].guild ~= nil, "removed")
  check("a stale list under a different guild key is pruned despite the pin",
        dbPin.echoHistory.guilds["Oldguild-Horizon"] == nil, "kept")
  check("only the other guild's list was removed", removed3 == 1, removed3)

  GetGuildInfo = savedGetGuildInfo
  S.SetPersisted("guild", false)
  S.SetPersisted("officer", false)
  H.Unbind()
  S.Reset()
`, 'history-guild');

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
  check("a channel tile with an icon shows its short name as a label", V.TileSpec(S.Get("ch:Trade")).label == "Trade", V.TileSpec(S.Get("ch:Trade")).label)
  check("a channel's name is its key name", V.DisplayName(S.Get("ch:Trade")) == "Trade", V.DisplayName(S.Get("ch:Trade")))
  S.SetTier("w:Brisa-Horizon", "muted")
  check("a muted conversation shows no badge", V.TileSpec(brisa).badge == nil, V.TileSpec(brisa).badge)
  S.SetTier("w:Brisa-Horizon", nil)

  check("newest loud conversation", V.NewestLoud(S.List()).key == "bn:77", V.NewestLoud(S.List()).key)
  check("no loud conversation falls back to the first", V.NewestLoud({ { key = "x", lastLoud = 0 } }).key == "x", "?")
  check("an empty list has no newest", V.NewestLoud({}) == nil, "?")

  local replied = { key = "replied", lastLoud = 5, messages = { { seq = 2 }, { seq = 5, outgoing = true } } }
  local waiting = { key = "waiting", lastLoud = 4, messages = { { seq = 4 } } }
  local chatter = { key = "chatter", lastLoud = 0, messages = { { seq = 9 } } }
  check("reply target is the newest incoming loud message, not your own reply",
        V.NewestIncomingLoud({ replied, waiting, chatter }).key == "waiting",
        V.NewestIncomingLoud and V.NewestIncomingLoud({ replied, waiting, chatter }).key)
  local onlySent = { key = "sent", lastLoud = 3, messages = { { seq = 3, outgoing = true } } }
  check("with no incoming loud message it falls back to the newest loud",
        V.NewestIncomingLoud({ chatter, onlySent }).key == "sent", V.NewestIncomingLoud({ chatter, onlySent }).key)
  check("an empty list has no reply target", V.NewestIncomingLoud({}) == nil, "?")

  local lootFeed = { key = "loot", kind = "loot", lastLoud = 9, messages = { { seq = 9 } } }
  check("a list of only a feed has no reply target", V.NewestIncomingLoud({ lootFeed }) == nil, "?")
  local whisper = { key = "w:Brisa-Horizon", kind = "whisper", lastLoud = 2, messages = { { seq = 2 } } }
  check("a feed alongside a real conversation never wins the reply target",
        V.NewestIncomingLoud({ lootFeed, whisper }).key == "w:Brisa-Horizon",
        V.NewestIncomingLoud({ lootFeed, whisper }).key)

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

// --- Tiles: smoke test with stand-in frames ---------------------------------------------
run(`
  local S, T = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles
  S.Reset()
  -- The events section installs a minimal CreateFrame of its own; use the stand-ins here.
  CreateFrame = function(...)
    local f = STUB_CREATE_FRAME(...)
    f.SetDontSavePosition = function(self, v) self.dontSave = v end
    return f
  end
  T.Enable()
  CreateFrame = STUB_CREATE_FRAME
  local column = _G.HorizonSuiteEchoColumn
  check("the column exists and is shown", column and column:IsShown(), "missing")
  check("WoW's layout cache never saves the column's position", column.dontSave == true, tostring(column.dontSave))
  check("the default anchor is bottom right", column.points[1] and column.points[1][1] == "BOTTOMRIGHT", column.points[1] and column.points[1][1])
  -- Plan 9: the stack button shows the Echo icon filling it (inset 1px), with no rounded
  -- panel fill or border behind it (the icon is already a rounded tile).
  local stackButtonRR = rawget(T._stackButton(), "_echoRound")
  check("the stack button has no rounded panel behind the icon", stackButtonRR == nil, "?")
  local sb = T._stackButton()
  check("the stack button's icon is the Echo icon", sb.icon.texture == HorizonSuite.Echo.View.ECHO_ICON, tostring(sb.icon.texture))
  check("the icon is inset 1px", sb.icon.points[1] and sb.icon.points[1][1] == "TOPLEFT"
    and sb.icon.points[1][4] == 1 and sb.icon.points[1][5] == -1, "?")
  check("the highlight starts hidden", not sb.highlight:IsShown(), "shown")
  sb.scripts.OnEnter(sb)
  check("hover shows the highlight", sb.highlight:IsShown(), "hidden")
  sb.scripts.OnLeave(sb)
  check("leaving hides the highlight", not sb.highlight:IsShown(), "shown")

  S.Add({ convKey = "w:Brisa-Horizon", text = "got the leather", class = "DRUID", sender = "Brisa-Horizon" })
  local tile = T.TileFor("w:Brisa-Horizon")
  check("a whisper gets a tile with its initial", tile and tile.convKey == "w:Brisa-Horizon" and tile.letter.text == "B", tile and tile.letter.text)
  check("a loud unread shows the dot", tile.dot.shown == true, tile.dot.shown)
  -- Final fix 7: the unread dot is one Echo.Round.Dot texture, not a 15-texture Round.
  check("the unread dot has no _echoRound handle (one-texture Dot, not a 9-slice)",
    rawget(tile.dot, "_echoRound") == nil, "?")
  check("the unread dot is sized 8x8", tile.dot.width == 8 and tile.dot.height == 8, "?")
  check("the unread dot uses the whole circle texture",
    tile.dot.texCoord and tile.dot.texCoord[1] == 0 and tile.dot.texCoord[2] == 1
      and tile.dot.texCoord[3] == 0 and tile.dot.texCoord[4] == 1, "?")
  local tileRR = rawget(tile, "_echoRound")
  check("a column tile is rounded with the TILE radius and a border", tileRR ~= nil and tileRR.corners.tl == HorizonSuite.Echo.Round.TILE and tileRR.border ~= nil, "?")
  local V = HorizonSuite.Echo.View
  local fr, fg, fb, fa = V.FaceBackground(V.TileSpec(S.Get("w:Brisa-Horizon")))
  local mb = tileRR and tileRR.fill.middleBand.vertexColor
  check("the tile's fill colour matches FaceBackground", mb and mb[1] == fr and mb[2] == fg and mb[3] == fb and mb[4] == fa, mb and table.concat(mb, ","))
  local shadeRR = rawget(tile.labelShade, "_echoRound")
  check("the label shade rounds only its bottom corners", shadeRR ~= nil and shadeRR.corners.tl == 0 and shadeRR.corners.tr == 0 and shadeRR.corners.bl == HorizonSuite.Echo.Round.TILE and shadeRR.corners.br == HorizonSuite.Echo.Round.TILE, "?")
  -- Final fix 3: the label is parented to its shade, so the shade (drawn first) never
  -- paints over it regardless of layer.
  check("the column tile's label is parented to the shade", tile.label.parent == tile.labelShade, "?")
  local toast = T._toast()
  check("a loud message shows the toast", toast and toast.shown and toast.convKey == "w:Brisa-Horizon", toast and toast.convKey)
  check("the toast body is the message", toast.entry.body.text == "got the leather", toast.entry.body.text)
  check("the toast title is the name", toast.entry.title.text == "Brisa", toast.entry.title.text)

  S.Add({ convKey = "party", text = "pull", sender = "Tank-Horizon" })
  S.Add({ convKey = "party", text = "go", sender = "Tank-Horizon" })
  local ptile = T.TileFor("party")
  check("a party tile shows its count", ptile and ptile.count.text == "2" and not ptile.dot.shown, ptile and ptile.count.text)
  local countPill = rawget(ptile, "countPill")
  local pillRR = countPill and rawget(countPill, "_echoRound")
  check("a count badge gets a small rounded pill behind it", countPill ~= nil and countPill.shown == true and pillRR ~= nil and pillRR.corners.tl == 6 and countPill.height == 12, "?")
  -- Final fix 2: the count is parented to its pill, so the pill's own fill never paints
  -- over the number regardless of layer.
  check("the column tile's count is parented to its pill", ptile.count.parent == countPill, "?")
  local pv = pillRR and pillRR.fill.middleBand.vertexColor
  check("the count pill is tinted the accent colour", pv and pv[1] == V.ACCENT.r and pv[2] == V.ACCENT.g and pv[3] == V.ACCENT.b, pv and table.concat(pv, ","))
  local tileCountPill = rawget(tile, "countPill")
  check("a dot badge shows no count pill", tileCountPill ~= nil and tileCountPill.shown == false, tostring(tileCountPill and tileCountPill.shown))
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
  local ovRR = rawget(overflow, "_echoRound")
  check("the overflow tile is rounded like a tile, with a border", ovRR ~= nil and ovRR.corners.tl == HorizonSuite.Echo.Round.TILE and ovRR.border ~= nil, "?")

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
  local Round = HorizonSuite.Echo.Round
  local cardRR = rawget(f.card, "_echoRound")
  check("the stack's top card is rounded with the PANEL radius and a border", cardRR ~= nil and cardRR.corners.tl == Round.PANEL and cardRR.border ~= nil, "?")
  local openRR = rawget(f.card.open, "_echoRound")
  check("the stack's Open button is rounded with the SMALL radius, no border", openRR ~= nil and openRR.corners.tl == Round.SMALL and openRR.border == nil, "?")
  local editRR = rawget(f.edit, "_echoRound")
  check("the stack's reply box is rounded with the SMALL radius", editRR ~= nil and editRR.corners.tl == Round.SMALL, "?")
  -- Final fix 5: the top accent rule is inset by the panel radius on both sides.
  check("the stack card's accent rule is inset by the panel radius on the left",
    f.rule.points[1] and f.rule.points[1][1] == "TOPLEFT" and f.rule.points[1][4] == Round.PANEL, "?")
  check("the stack card's accent rule is inset by the panel radius on the right",
    f.rule.points[2] and f.rule.points[2][1] == "TOPRIGHT" and f.rule.points[2][4] == -Round.PANEL, "?")

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
  local behindRR = rawget(f.behind[1], "_echoRound")
  check("a behind-card is rounded with the PANEL radius and a border", behindRR ~= nil and behindRR.corners.tl == Round.PANEL and behindRR.border ~= nil, "?")
  K.Flip(1)
  check("the wheel flips to the next card", f.card.name.text == "Vexa", f.card.name.text)
  K.Flip(5)
  check("flipping stops at the last card", f.card.name.text == "Vexa", f.card.name.text)
  K.Flip(-5)
  check("flipping stops at the first card", f.card.name.text == "Brisa", f.card.name.text)

  K.ReplyToNewest()
  check("reply-to-newest opens with the box focused", f.root:IsShown() and f.edit.focused == true, tostring(f.edit.focused))
  -- Brisa was just replied to, so Vexa's unanswered whisper is the one waiting.
  check("reply-to-newest picks the newest incoming loud conversation, not the one just answered", f.card.name.text == "Vexa", f.card.name.text)
  f.edit.scripts.OnEscapePressed(f.edit)
  check("escape leaves the box first", f.edit.focused == false and f.root:IsShown(), tostring(f.edit.focused))

  K.CloseCurrent()
  check("closing the top card shows the next conversation", f.card.name.text == "Brisa" and not S.Get("w:Vexa-Horizon").open, f.card.name.text)

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

// --- Stack: poll-based hover close (fix round 1, finding 1) ------------------------------
run(`
  local S, T, K = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles, HorizonSuite.Echo.Stack
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  local f = K._frames()
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })

  -- (a) opened with the mouse elsewhere: never arms, so it never auto-closes
  K.Open(nil)
  check("opens", f.root:IsShown(), "hidden")
  f.root.scripts.OnUpdate(f.root, 1.0)
  check("not armed: a mouse-away open never auto-closes", f.root:IsShown(), "hidden")
  K.Hide()

  -- (b) the mouse enters (arming it) then leaves: closes once away >= HOVER_CLOSE
  K.Open(nil)
  f.root.IsMouseOver = function() return true end
  f.root.scripts.OnUpdate(f.root, 0.2)
  check("armed while over: stays open", f.root:IsShown(), "hidden")
  f.root.IsMouseOver = function() return false end
  f.root.scripts.OnUpdate(f.root, 0.5)
  check("armed and away past HOVER_CLOSE: closes", not f.root:IsShown(), "shown")
  f.root.IsMouseOver = nil

  -- (c) armed and away, but the reply box has focus: away time never accrues
  K.Open(nil)
  f.root.IsMouseOver = function() return true end
  f.root.scripts.OnUpdate(f.root, 0.2)
  f.root.IsMouseOver = function() return false end
  f.edit.HasFocus = function() return true end
  f.root.scripts.OnUpdate(f.root, 1.0)
  check("a focused reply box holds the stack open", f.root:IsShown(), "hidden")
  f.root.IsMouseOver = nil
  f.edit.HasFocus = nil

  K.Hide()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'stack-hover');

// --- Stack: each card keeps its own draft (fix round 1, finding 2; final review F6b) --------
run(`
  local S, T, K = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles, HorizonSuite.Echo.Stack
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  local f = K._frames()

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  S.Add({ convKey = "w:Vexa-Horizon", text = "gz", sender = "Vexa-Horizon" })
  K.Open(nil)
  check("opens on the newest conversation", f.card.name.text == "Vexa", f.card.name.text)
  f.edit:SetText("for vexa")
  K.Flip(1)
  check("the other card starts with an empty box", f.edit.text == "", f.edit.text)
  f.edit:SetText("for brisa")
  K.Flip(-1)
  check("flipping back restores that card's draft", f.edit.text == "for vexa", f.edit.text)
  K.Flip(1)
  check("each card keeps its own draft", f.edit.text == "for brisa", f.edit.text)
  f.edit:SetText("")

  K.Open("w:Brisa-Horizon")
  check("open moves the named conversation on top", f.card.name.text == "Brisa", f.card.name.text)
  f.edit:SetText("draft")
  K.Open("w:Brisa-Horizon", true)
  check("reopening the same card on top keeps its draft", f.edit.text == "draft", f.edit.text)
  f.edit:SetText("draftr")
  f.edit.scripts.OnChar(f.edit, "r")
  check("a swallowed keybind char restores the draft, not empties it", f.edit.text == "draft", f.edit.text)

  K.Hide()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'stack-draft');

// --- Stack: keep your place (closed drafts, upper-case only in English) ------------------
run(`
  local Echo = HorizonSuite.Echo
  local S, T, K = Echo.Store, Echo.Tiles, Echo.Stack
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  local f = K._frames()

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  S.Add({ convKey = "w:Vexa-Horizon", text = "hey", sender = "Vexa-Horizon" })
  K.Open("w:Brisa-Horizon")
  f.edit:SetText("draft for brisa")
  S.Close("w:Brisa-Horizon")
  local taken = Echo.TakeDraft("w:Brisa-Horizon")
  check("closing discards the parked draft", taken == "", taken)
  check("the stack box is cleared when its own conversation closes", f.edit.text == "", f.edit.text)
  S.Add({ convKey = "w:Brisa-Horizon", text = "hey again", sender = "Brisa-Horizon" })
  K.Open("w:Brisa-Horizon")
  check("reopening after a close shows an empty box, not the old draft", f.edit.text == "", f.edit.text)

  local savedNames = LOCALIZED_CLASS_NAMES_MALE
  LOCALIZED_CLASS_NAMES_MALE = { DRUID = "Druid" }
  local realLocale = GetLocale
  GetLocale = function() return "enUS" end
  K.Flip(0)
  check("enUS upper-cases the stack's meta line", f.card.meta.text:find("DRUID", 1, true) ~= nil, f.card.meta.text)
  GetLocale = function() return "deDE" end
  K.Open("w:Vexa-Horizon")
  K.Open("w:Brisa-Horizon")
  check("deDE leaves the stack's meta line alone", f.card.meta.text:find("Druid", 1, true) ~= nil, f.card.meta.text)
  GetLocale = realLocale
  LOCALIZED_CLASS_NAMES_MALE = savedNames

  K.Hide()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'stack-keep-place');

// --- Stack: OnHide cancels a pending open and drops reply-box focus (fix round 1, finding 4) ----
run(`
  local S, T, K = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles, HorizonSuite.Echo.Stack
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  local f = K._frames()
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })

  K.Open("w:Brisa-Horizon", true)
  check("focusing the reply box sets focus", f.edit.focused == true, tostring(f.edit.focused))
  check("root registers an OnHide handler", type(f.root.scripts.OnHide) == "function", type(f.root.scripts.OnHide))
  f.root.scripts.OnHide(f.root)
  check("OnHide clears the reply box focus", f.edit.focused == false, tostring(f.edit.focused))

  K.Hide()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'stack-onhide');

// --- Stack: a click during the hover delay wins over the hover open (final review F1) ----
run(`
  local S, T, K = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles, HorizonSuite.Echo.Stack
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  local f = K._frames()
  local column = _G.HorizonSuiteEchoColumn
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  S.Add({ convKey = "w:Vexa-Horizon", text = "gz", sender = "Vexa-Horizon" })

  local savedNewTimer = C_Timer.NewTimer
  local fire, cancelled
  C_Timer.NewTimer = function(_, fn)
    fire = fn
    return { Cancel = function() cancelled = true end }
  end
  column.IsMouseOver = function() return true end
  K.HoverEnter()
  check("hovering a tile starts the open timer", type(fire) == "function", type(fire))
  K.Open("w:Brisa-Horizon")
  check("a click opens the clicked (lower) card", f.card.name.text == "Brisa", f.card.name.text)
  check("opening cancels the pending hover timer", cancelled == true, tostring(cancelled))
  fire()
  check("the hover timer firing late leaves the clicked card on top", f.card.name.text == "Brisa", f.card.name.text)
  column.IsMouseOver = nil
  C_Timer.NewTimer = savedNewTimer

  K.Hide()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'stack-hover-click');

// --- Stack: hovering a tile brings that conversation to the front ------------------------
run(`
  local S, T, K = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles, HorizonSuite.Echo.Stack
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  local f = K._frames()
  local column = _G.HorizonSuiteEchoColumn
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  S.Add({ convKey = "w:Vexa-Horizon", text = "gz", sender = "Vexa-Horizon" })
  S.Add({ convKey = "w:Thorn-Horizon", text = "yo", sender = "Thorn-Horizon" })

  local savedNewTimer = C_Timer.NewTimer
  local fire
  C_Timer.NewTimer = function(_, fn) fire = fn; return { Cancel = function() end } end
  column.IsMouseOver = function() return true end

  local brisaTile = T.TileFor("w:Brisa-Horizon")
  brisaTile.scripts.OnEnter(brisaTile)
  check("hovering a tile starts the open timer", type(fire) == "function", type(fire))
  fire()
  check("the stack opens on the hovered tile's conversation", f.root:IsShown() and f.card.name.text == "Brisa", f.card.name.text)

  local vexaTile = T.TileFor("w:Vexa-Horizon")
  vexaTile.scripts.OnEnter(vexaTile)
  check("hovering another tile while open brings it to the front", f.card.name.text == "Vexa", f.card.name.text)
  check("bringing a card forward marks it read", S.Get("w:Vexa-Horizon").unread == 0, S.Get("w:Vexa-Horizon").unread)
  vexaTile.scripts.OnEnter(vexaTile)
  check("hovering the front card's tile again changes nothing", f.card.name.text == "Vexa", f.card.name.text)

  K.Hide()
  fire = nil
  local thornTile = T.TileFor("w:Thorn-Horizon")
  thornTile.scripts.OnEnter(thornTile)
  brisaTile.scripts.OnEnter(brisaTile)
  fire()
  check("moving across tiles during the delay opens on the last one hovered", f.card.name.text == "Brisa", f.card.name.text)

  K.Hide()
  fire = nil
  local stackButton = T._stackButton()
  stackButton.scripts.OnEnter(stackButton)
  fire()
  check("hovering the chat button opens on the top conversation", f.card.name.text == S.List()[1].key:sub(3):match("^([^-]+)"), f.card.name.text)

  column.IsMouseOver = nil
  C_Timer.NewTimer = savedNewTimer
  K.Hide()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'stack-hover-tile');

// --- Events: a conversation with yourself shows each message once ---------------------------
run(`
  local S, E = HorizonSuite.Echo.Store, HorizonSuite.Echo.Events
  S.Reset()
  local function p(text, who) return text, who, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil end

  -- Typed in Blizzard's box: the game sends the received copy, then the sent echo.
  E.Dispatch("CHAT_MSG_WHISPER", p("note to self", "Kaelis-Horizon"))
  E.Dispatch("CHAT_MSG_WHISPER_INFORM", p("note to self", "Kaelis-Horizon"))
  local me = S.Get("w:Kaelis-Horizon")
  check("a whisper to yourself shows once", #me.messages == 1 and not me.messages[1].outgoing, #me.messages)
  check("a whisper to yourself stays unread", me.unread == 1, me.unread)

  -- Sent from Echo's reply box: pending line, received copy, then the echo.
  local pending = S.AddPending("w:Kaelis-Horizon", "from echo")
  E.Dispatch("CHAT_MSG_WHISPER", p("from echo", "Kaelis-Horizon"))
  E.Dispatch("CHAT_MSG_WHISPER_INFORM", p("from echo", "Kaelis-Horizon"))
  check("an Echo reply to yourself shows once", #me.messages == 2, #me.messages)
  check("the echo confirms the pending line", pending.status == "sent", pending.status)

  -- The same text twice is two messages, not one.
  E.Dispatch("CHAT_MSG_WHISPER", p("from echo", "Kaelis-Horizon"))
  E.Dispatch("CHAT_MSG_WHISPER_INFORM", p("from echo", "Kaelis-Horizon"))
  check("repeating the same text to yourself is a new message", #me.messages == 3, #me.messages)

  -- A secret copy cannot be compared, so it is kept.
  E.Dispatch("CHAT_MSG_WHISPER", p(SECRET("mid-pull"), "Kaelis-Horizon"))
  check("a secret whisper to yourself is kept", #me.messages == 4, #me.messages)

  E.Dispatch("CHAT_MSG_WHISPER", p("hi", "Brisa-Horizon"))
  E.Dispatch("CHAT_MSG_WHISPER_INFORM", p("hey", "Brisa-Horizon"))
  local brisa = S.Get("w:Brisa-Horizon")
  check("other conversations keep both sides", #brisa.messages == 2, #brisa.messages)
  check("replying to someone else still marks it read", brisa.unread == 0, brisa.unread)
  S.Reset()
`, 'self-whisper');

// --- Stack: your lines sit on the right; a flat close button -------------------------------
run(`
  local S, T, K = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles, HorizonSuite.Echo.Stack
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  local f = K._frames()
  for _, fs in ipairs(f.card.lines) do fs.SetJustifyH = function(self, j) self.justify = j end end
  S.Add({ convKey = "w:Brisa-Horizon", text = "got the leather", class = "DRUID", sender = "Brisa-Horizon" })
  S.Add({ convKey = "w:Brisa-Horizon", text = "sure", outgoing = true, status = "sent" })
  K.Open("w:Brisa-Horizon")
  check("their line sits on the left", f.card.lines[1].justify == "LEFT", f.card.lines[1].justify)
  check("your line sits on the right", f.card.lines[2].justify == "RIGHT", f.card.lines[2].justify)
  check("the close button is Echo's own, not Blizzard's", rawget(f.card.close, "template") == nil and rawget(f.card.close, "bars") ~= nil, tostring(rawget(f.card.close, "template")))
  f.card.close.scripts.OnClick(f.card.close)
  check("the close button closes the conversation", not S.Get("w:Brisa-Horizon").open, "still open")
  for _, fs in ipairs(f.card.lines) do fs.SetJustifyH = nil end
  K.Hide()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'stack-lines-close');

// --- Tiles: no toast over an open stack (final review F2) --------------------------------
run(`
  local S, T, K = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles, HorizonSuite.Echo.Stack
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  local f = K._frames()
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  local toast = T._toast()
  toast:Hide()
  K.Open("w:Brisa-Horizon")
  S.Add({ convKey = "w:Vexa-Horizon", text = "gz", sender = "Vexa-Horizon" })
  check("a loud message while the stack is open shows no toast", not toast.shown, toast.convKey)
  check("the new conversation still gets its tile", T.TileFor("w:Vexa-Horizon") ~= nil, "no tile")
  K.Hide()
  T.Hold(true)
  K.Open("w:Brisa-Horizon")
  S.Add({ convKey = "w:Orin-Horizon", text = "yo", sender = "Orin-Horizon" })
  K.Hide()
  T.Hold(false)
  check("a loud message while the stack is open is not queued for after combat", not toast.shown, toast.convKey)

  K.Disable()
  T.Disable()
  S.Reset()
`, 'tiles-stack-open');

// --- Tiles: the toast queue across combat, clicks and moving tiles (final review F5) ---------
run(`
  local S, T, K = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles, HorizonSuite.Echo.Stack
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  local toast
  local function add(key) S.Add({ convKey = key, text = "hi", sender = key:sub(3) }) end

  -- (a) combat starts again while released toasts are still playing
  T.Hold(true)
  add("w:A-Horizon"); add("w:B-Horizon"); add("w:C-Horizon")
  T.Hold(false)
  toast = T._toast()
  check("release plays the newest held toast", toast.shown and toast.convKey == "w:C-Horizon", toast.convKey)
  T.Hold(true)
  toast:Hide()
  T.NextToast()
  check("no held toast plays while holding again", not toast.shown, toast.convKey)
  T.Hold(false)
  check("the unplayed toasts replay after the next release", toast.shown and toast.convKey == "w:B-Horizon", toast.convKey)
  toast:Hide()
  T.NextToast()
  check("and the rest follow", toast.shown and toast.convKey == "w:A-Horizon", toast.convKey)
  toast:Hide()
  T.NextToast()

  -- (b) clicking a toast drops the rest of the held ones
  T.Hold(true)
  add("w:D-Horizon"); add("w:E-Horizon")
  T.Hold(false)
  check("the newest held toast shows", toast.shown and toast.convKey == "w:E-Horizon", toast.convKey)
  toast.scripts.OnClick(toast)
  K.Hide()
  -- A toast click opens the card now; close it too, or no later toast shows (G3).
  HorizonSuite.Echo.Card.Hide()
  T.NextToast()
  check("after a toast is clicked the stale held toasts do not play", not toast.shown, toast.convKey)

  -- (c) the toast follows its conversation's tile when a refresh moves it
  local savedAugment = HorizonSuite.Augment
  HorizonSuite.Augment = { ToastMotion = { ENTRANCE_DUR = 0.2, EXIT_DUR = 0.2, SLIDE_DIST = 10,
                                           Ease = function(p) return p end } }
  add("w:F-Horizon")
  check("a loud message toasts", toast.shown and toast.convKey == "w:F-Horizon", toast.convKey)
  add("w:G-Horizon")
  toast.convKey = "w:F-Horizon"   -- as if F's toast were still up when G's tile pushed F down
  toast.scripts.OnUpdate(toast, 0.05)
  local anchor = toast.points[1] and toast.points[1][2]
  check("the toast re-anchors to its conversation's tile each frame",
        anchor ~= nil and anchor == T.TileFor("w:F-Horizon"), tostring(anchor and anchor.convKey))
  HorizonSuite.Augment = savedAugment

  toast:Hide()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'tiles-toast-queue');

// --- Module wiring: login restore, Battle.net retry, combat, logout (final review F4) ------
// EchoModule.lua is not in FILES: it registers with the addon, so it loads here against a
// stubbed RegisterModule and everything it touches is put back afterwards.
run(`
  local A = HorizonSuite
  local Echo, S, H, T, K = A.Echo, A.Echo.Store, A.Echo.History, A.Echo.Tiles, A.Echo.Stack
  S.Reset()
  MODULE_TEST = {
    saved = {
      RegisterModule = A.RegisterModule, DATABASE = A.DATABASE, profileKey = A._GetCurrentCharacterProfileKey,
      IsModuleEnabled = A.IsModuleEnabled, IsLoggedIn = IsLoggedIn, CreateFrame = CreateFrame,
      SessionKeys = H.SessionKeys, SaveSession = H.SaveSession, Now = S.Now,
      hold = A.ECHO_DEFAULTS and A.ECHO_DEFAULTS.echoHoldToastsInCombat,
    },
    frames = {},
  }
  A.RegisterModule = function(_, name, def) MODULE_TEST.name, MODULE_TEST.def = name, def end
  A.DATABASE = "ECHO_TEST_DB"
  _G.ECHO_TEST_DB = {}
  A._GetCurrentCharacterProfileKey = function() return "Kaelis-Horizon" end
  A.IsModuleEnabled = function() return true end
  A.ECHO_DEFAULTS = A.ECHO_DEFAULTS or {}
  A.ECHO_DEFAULTS.echoHoldToastsInCombat = true
  IsLoggedIn = function() return false end
  CreateFrame = function(...)
    local f = STUB_CREATE_FRAME(...)
    f.events = {}
    f.RegisterEvent = function(self, e) self.events[e] = true end
    f.UnregisterEvent = function(self, e) self.events[e] = nil end
    f.UnregisterAllEvents = function(self) self.events = {} end
    MODULE_TEST.frames[#MODULE_TEST.frames + 1] = f
    return f
  end
`, 'module-stubs');
run(read('modules/Echo/EchoModule.lua'), 'modules/Echo/EchoModule.lua');
run(`
  local A = HorizonSuite
  local Echo, S, H, T, K, C = A.Echo, A.Echo.Store, A.Echo.History, A.Echo.Tiles, A.Echo.Stack, A.Echo.Card
  local M = MODULE_TEST
  check("the module registers as echo", M.name == "echo" and type(M.def) == "table", M.name)
  local clock = 10000
  S.Now = function() return clock end
  local sessionKeys = { "w:Saved-Horizon" }
  H.SessionKeys = function() return sessionKeys end
  local saves = 0
  H.SaveSession = function() saves = saves + 1; return true end

  M.def.OnEnable()
  local lifecycle
  for _, f in ipairs(M.frames) do if f.events.PLAYER_LOGOUT then lifecycle = f end end
  check("a lifecycle frame listens for logout", lifecycle ~= nil, "none")
  local function fire(event) lifecycle.scripts.OnEvent(lifecycle, event) end
  check("before the world loads nothing is restored", S.Get("w:Saved-Horizon") == nil, "restored early")
  check("it waits for PLAYER_ENTERING_WORLD", lifecycle.events.PLAYER_ENTERING_WORLD == true, "not registered")

  fire("PLAYER_LOGOUT")
  check("a logout before any restore keeps the saved tiles", saves == 0, saves)

  fire("PLAYER_ENTERING_WORLD")
  check("entering the world restores the saved tiles", S.Get("w:Saved-Horizon") ~= nil, "not restored")
  check("battle.net friend updates are watched after the restore",
        lifecycle.events.BN_FRIEND_INFO_CHANGED == true and lifecycle.events.BN_CONNECTED == true, "not registered")

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon" })
  K.Open("w:Brisa-Horizon")
  C.Open("w:Brisa-Horizon")
  local f = K._frames()
  local cf = C._frames()
  fire("PLAYER_REGEN_DISABLED")
  check("combat closes the stack", not f.root:IsShown(), "shown")
  check("combat closes the card", not cf.root:IsShown(), "shown")
  check("combat holds toasts", T.holding == true, tostring(T.holding))
  fire("PLAYER_REGEN_ENABLED")
  check("leaving combat releases toasts", T.holding == false, tostring(T.holding))

  sessionKeys = { "w:Saved-Horizon", "bn:9" }
  clock = clock + 20
  fire("BN_FRIEND_INFO_CHANGED")
  check("a late friends list restores the battle.net tile", S.Get("bn:9") ~= nil, "not restored")
  sessionKeys = { "w:Saved-Horizon", "bn:9", "bn:10" }
  clock = clock + 45
  fire("BN_CONNECTED")
  check("past a minute battle.net updates restore nothing more", S.Get("bn:10") == nil, "restored late")
  check("past a minute the battle.net events are dropped",
        not lifecycle.events.BN_FRIEND_INFO_CHANGED and not lifecycle.events.BN_CONNECTED, "still registered")

  fire("PLAYER_LOGOUT")
  check("a logout after the restore saves the session", saves == 1, saves)

  M.def.OnDisable()
  check("disable drops every lifecycle event", next(lifecycle.events) == nil, "still registered")
  IsLoggedIn = function() return true end
  sessionKeys = { "w:Again-Horizon" }
  M.def.OnEnable()
  check("enabled after login, it restores at once", S.Get("w:Again-Horizon") ~= nil, "not restored")
  M.def.OnDisable()

  local saved = M.saved
  A.RegisterModule, A.DATABASE, A._GetCurrentCharacterProfileKey = saved.RegisterModule, saved.DATABASE, saved.profileKey
  A.IsModuleEnabled, IsLoggedIn, CreateFrame = saved.IsModuleEnabled, saved.IsLoggedIn, saved.CreateFrame
  H.SessionKeys, H.SaveSession, S.Now = saved.SessionKeys, saved.SaveSession, saved.Now
  A.ECHO_DEFAULTS.echoHoldToastsInCombat = saved.hold
  Echo.Init, Echo.Disable, Echo.RestoreSession = nil, nil, nil
  _G.ECHO_TEST_DB = nil
  MODULE_TEST = nil
  S.Reset()
`, 'module');

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
  C_GuildInfo = { MemberExistsByName = function(name) if name == "Secret-Horizon" then return SECRET(true) end end }
  label = V.Relationship({ kind = "whisper", key = "w:Secret-Horizon" })
  check("a secret guild member has no relationship", label == nil, tostring(label))
  C_FriendList = { GetFriendInfo = function() error("boom") end }
  check("a throwing API is survived", pcall(V.Relationship, { kind = "whisper", key = "w:Brisa-Horizon" }), "threw")
  C_FriendList, C_GuildInfo, C_BattleNet = savedFriends, savedGuild, savedBattleNet

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  local meta = V.CardMeta(S.Get("w:Brisa-Horizon"))
  check("card meta names the class", meta:find("Druid", 1, true) ~= nil, meta)

  -- Invite target: a whisperer's bare name, a Battle.net friend on WoW as Name-Realm (only
  -- when they can actually play with you), and nil for anything else, including yourself.
  -- The stub UnitName() ("Kaelis") plus GetNormalizedRealmName() ("Horizon") make the
  -- player's own key "Kaelis-Horizon".
  check("a whisper's invite target is its name", V.InviteTarget({ kind = "whisper", key = "w:Brisa-Horizon" }) == "Brisa-Horizon", V.InviteTarget({ kind = "whisper", key = "w:Brisa-Horizon" }))
  check("a secret whisper name has no invite target", V.InviteTarget({ kind = "whisper", key = SECRET("w:Brisa-Horizon") }) == nil, "?")
  check("a self-whisper has no invite target", V.InviteTarget({ kind = "whisper", key = "w:Kaelis-Horizon" }) == nil, "?")
  local savedBnetInvite, savedWowProjectID, savedCanCooperate = C_BattleNet, WOW_PROJECT_ID, CanCooperateWithGameAccount
  WOW_PROJECT_ID = 1
  CanCooperateWithGameAccount = nil
  C_BattleNet = { GetAccountInfoByID = function(id)
    if id == 1 then return { gameAccountInfo = { clientProgram = "WoW", characterName = "Brisa", realmName = "Horizon", wowProjectID = 1, isInCurrentRegion = true } } end
    if id == 2 then return { gameAccountInfo = { clientProgram = "App" } } end
    if id == 3 then return { gameAccountInfo = { clientProgram = "WoW", characterName = SECRET("Brisa"), realmName = "Horizon", wowProjectID = 1 } } end
    if id == 4 then return { gameAccountInfo = { clientProgram = "WoW", characterName = "Brisa", realmName = "", wowProjectID = 1 } } end
    -- A Classic friend: a different wowProjectID than ours.
    if id == 5 then return { gameAccountInfo = { clientProgram = "WoW", characterName = "Brisa", realmName = "Horizon", wowProjectID = 2 } } end
    -- On a realm with a space in its name.
    if id == 6 then return { gameAccountInfo = { clientProgram = "WoW", characterName = "Brisa", realmName = "Argent Dawn", wowProjectID = 1, isInCurrentRegion = true } } end
    return nil
  end }
  check("a battle.net friend on WoW targets Name-Realm", V.InviteTarget({ kind = "bnet", key = "bn:1" }) == "Brisa-Horizon", V.InviteTarget({ kind = "bnet", key = "bn:1" }))
  check("a battle.net friend in the app has no invite target", V.InviteTarget({ kind = "bnet", key = "bn:2" }) == nil, "?")
  check("a battle.net friend with a secret name has no invite target", V.InviteTarget({ kind = "bnet", key = "bn:3" }) == nil, "?")
  check("a battle.net friend missing a realm has no invite target", V.InviteTarget({ kind = "bnet", key = "bn:4" }) == nil, "?")
  check("a Classic friend gets no invite target", V.InviteTarget({ kind = "bnet", key = "bn:5" }) == nil, "?")
  check("a realm with a space collapses it", V.InviteTarget({ kind = "bnet", key = "bn:6" }) == "Brisa-ArgentDawn", V.InviteTarget({ kind = "bnet", key = "bn:6" }))

  -- When the client offers CanCooperateWithGameAccount, it decides, full stop.
  CanCooperateWithGameAccount = function() return false end
  check("CanCooperateWithGameAccount false gets no invite target", V.InviteTarget({ kind = "bnet", key = "bn:1" }) == nil, "?")
  CanCooperateWithGameAccount = function() return true end
  check("CanCooperateWithGameAccount true overrides a mismatched project", V.InviteTarget({ kind = "bnet", key = "bn:5" }) == "Brisa-Horizon", V.InviteTarget({ kind = "bnet", key = "bn:5" }))
  C_BattleNet, WOW_PROJECT_ID, CanCooperateWithGameAccount = savedBnetInvite, savedWowProjectID, savedCanCooperate
  check("a group has no invite target", V.InviteTarget({ kind = "party", key = "party" }) == nil, "?")
  check("a feed has no invite target", V.InviteTarget({ kind = "loot", key = "loot" }) == nil, "?")

  local spec = V.MenuSpec(S.Get("w:Brisa-Horizon"))
  check("the menu starts with pin", spec[1].kind == "button" and spec[1].action == "pin" and spec[1].label == "ECHO_PIN", spec[1].label)
  check("a whisper menu offers invite next", spec[2].kind == "button" and spec[2].action == "invite" and spec[2].label == "ECHO_INVITE", spec[2].label)
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

  local groupSpec = V.MenuSpec({ key = "party", kind = "party", pinned = false })
  local hasInvite = false
  for _, e in ipairs(groupSpec) do if e.action == "invite" then hasInvite = true end end
  check("a group menu has no invite", hasInvite == false, "?")
  local feedSpec = V.MenuSpec({ key = "loot", kind = "loot", pinned = false })
  hasInvite = false
  for _, e in ipairs(feedSpec) do if e.action == "invite" then hasInvite = true end end
  check("a feed menu has no invite", hasInvite == false, "?")

  E.ClearDrafts()
  E.ParkDraft("w:A-Horizon", "half a thought")
  E.ParkDraft("w:B-Horizon", "")
  check("a parked draft comes back once", E.TakeDraft("w:A-Horizon") == "half a thought" and E.TakeDraft("w:A-Horizon") == "", "?")
  check("an empty draft is not kept", E.TakeDraft("w:B-Horizon") == "", "?")
  check("no key, no draft", E.TakeDraft(nil) == "", "?")
  S.Reset()
`, 'view-card');

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
  check("the menu has pin, invite, a title, five choices and close", #calls == 11 and calls[1][1] == "button" and calls[2][1] == "button" and calls[5][1] == "radio" and calls[11][1] == "button", #calls)

  calls[1][3]()
  check("pin pins", S.Get("w:Brisa-Horizon").pinned == true, "?")
  M.Run("w:Brisa-Horizon", "pin")
  check("pin again unpins", S.Get("w:Brisa-Horizon").pinned == false, "?")

  local savedPartyInfo, savedInviteUnit = C_PartyInfo, InviteUnit
  local invited
  C_PartyInfo = { InviteUnit = function(target) invited = target end }
  calls[2][3]()
  check("invite calls C_PartyInfo.InviteUnit with the target", invited == "Brisa-Horizon", tostring(invited))
  invited = nil
  C_PartyInfo = nil
  InviteUnit = function(target) invited = target end
  M.Run("w:Brisa-Horizon", "invite")
  check("invite falls back to the global InviteUnit", invited == "Brisa-Horizon", tostring(invited))
  invited = nil
  InviteUnit = function() error("boom") end
  check("a throwing invite is survived", pcall(M.Run, "w:Brisa-Horizon", "invite"), "threw")
  C_PartyInfo, InviteUnit = savedPartyInfo, savedInviteUnit
  check("invite on an unknown conversation is a no-op", pcall(M.Run, "w:Nobody-Horizon", "invite"), "threw")

  local muted = calls[9]
  check("the muted choice is not selected yet", muted[3]() == false, "?")
  muted[4]()
  check("choosing muted mutes", S.TierOf("w:Brisa-Horizon") == "muted" and muted[3]() == true, S.TierOf("w:Brisa-Horizon"))
  calls[5][4]()
  check("choosing default clears the override", S.OverrideOf("w:Brisa-Horizon") == nil and calls[5][3]() == true, S.OverrideOf("w:Brisa-Horizon"))

  calls[11][3]()
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

// --- Card: smoke test with stand-in frames ---------------------------------------------
run(`
  local S, T, K, C = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles, HorizonSuite.Echo.Stack, HorizonSuite.Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  local sent = {}
  C_ChatInfo = { SendChatMessage = function(msg, chatType, _, target) sent[#sent + 1] = chatType .. ":" .. tostring(target) .. ":" .. msg end }
  -- The meta line's upper-casing is locale-gated (View.Upper); pin enUS so this section's
  -- assertions about the meta text's case stay meaningful.
  local realLocale = GetLocale
  GetLocale = function() return "enUS" end
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
  local Round = HorizonSuite.Echo.Round
  local rootRR = rawget(f.root, "_echoRound")
  check("the card root is rounded with the PANEL radius and a border", rootRR ~= nil and rootRR.corners.tl == Round.PANEL and rootRR.border ~= nil, "?")
  local editRR = rawget(f.edit, "_echoRound")
  check("the card's reply box is rounded with the SMALL radius", editRR ~= nil and editRR.corners.tl == Round.SMALL, "?")
  local sendRR = rawget(f.send, "_echoRound")
  check("the send button is rounded with the SMALL radius", sendRR ~= nil and sendRR.corners.tl == Round.SMALL, "?")
  -- Final fix 5: the top accent rule is inset by the panel radius on both sides so it
  -- stays inside the rounded top corners.
  check("the card's accent rule is inset by the panel radius on the left",
    f.rule.points[1] and f.rule.points[1][1] == "TOPLEFT" and f.rule.points[1][4] == Round.PANEL, "?")
  check("the card's accent rule is inset by the panel radius on the right",
    f.rule.points[2] and f.rule.points[2][1] == "TOPRIGHT" and f.rule.points[2][4] == -Round.PANEL, "?")
  check("the card shows the chosen conversation", f.name.text == "Brisa", f.name.text)
  check("the meta line names the class", f.meta.text:find("DRUID", 1, true) ~= nil, f.meta.text)
  check("opening marks it read", S.Get("w:Brisa-Horizon").unread == 0, S.Get("w:Brisa-Horizon").unread)
  check("the newest message is the bottom bubble", f.bubbles[1].text.text == "can you craft the cloak?" and f.bubbles[1].shown, f.bubbles[1].text.text)
  check("their bubble sits on the left", f.bubbles[1].points[1][1] == "BOTTOMLEFT", f.bubbles[1].points[1][1])
  check("the older message sits above it", f.bubbles[2].text.text == "got the leather" and f.bubbles[2].points[1][5] > f.bubbles[1].points[1][5], "?")
  local b1RR = rawget(f.bubbles[1], "_echoRound")
  check("the newest incoming bubble has a tight bottom-left corner (last of its group)", b1RR ~= nil and b1RR.corners.bl == Round.TIGHT and b1RR.corners.tl == Round.BUBBLE and b1RR.border == nil, "?")
  local b2RR = rawget(f.bubbles[2], "_echoRound")
  check("an earlier bubble in the same group uses full radii", b2RR ~= nil and b2RR.corners.bl == Round.BUBBLE and b2RR.corners.tl == Round.BUBBLE, "?")
  check("the tile row shows both conversations", f.rowTiles[1].shown and f.rowTiles[2].shown and not f.rowTiles[3].shown, "?")
  local a = HorizonSuite.Echo.View.ACCENT
  local rt1RR = rawget(f.rowTiles[1], "_echoRound")
  check("the card's row tiles are rounded with the TILE radius and a border", rt1RR ~= nil and rt1RR.corners.tl == Round.TILE and rt1RR.border ~= nil, "?")
  local rt2RR = rawget(f.rowTiles[2], "_echoRound")
  local ring1 = rt1RR and rt1RR.border.ring.tl.vertexColor
  local ring2 = rt2RR and rt2RR.border.ring.tl.vertexColor
  local shownRing, otherRing
  for _, b in ipairs(f.rowTiles) do
    if b.convKey == "w:Brisa-Horizon" then shownRing = rawget(b, "_echoRound").border.ring.tl.vertexColor
    elseif b.convKey == "w:Vexa-Horizon" then otherRing = rawget(b, "_echoRound").border.ring.tl.vertexColor end
  end
  check("the shown conversation's row tile outline is the accent colour", shownRing and shownRing[1] == a.r and shownRing[2] == a.g and shownRing[3] == a.b, shownRing and table.concat(shownRing, ","))
  -- Final fix 7: the row tile's unread dot is one Echo.Round.Dot texture, fully round,
  -- not a 9-slice Round.
  check("a card row tile's unread dot has no _echoRound handle (one-texture Dot)",
    rawget(f.rowTiles[1].dot, "_echoRound") == nil, "?")
  check("a card row tile's unread dot is sized 6x6", f.rowTiles[1].dot.width == 6 and f.rowTiles[1].dot.height == 6, "?")
  check("another row tile's outline is dark", otherRing and otherRing[1] == 0 and otherRing[2] == 0 and otherRing[3] == 0, otherRing and table.concat(otherRing, ","))
  check("both row tiles are rounded", ring1 ~= nil and ring2 ~= nil, "?")

  f.edit:SetText("sure, mail them")
  f.edit.scripts.OnEnterPressed(f.edit)
  check("enter sends to the card's conversation", sent[1] == "WHISPER:Brisa-Horizon:sure, mail them", sent[1])
  check("the box empties after sending", f.edit.text == "", f.edit.text)
  check("your bubble sits on the right", f.bubbles[1].text.text == "sure, mail them" and f.bubbles[1].points[1][1] == "BOTTOMRIGHT", f.bubbles[1].points[1][1])
  local outRR = rawget(f.bubbles[1], "_echoRound")
  check("an outgoing bubble has a tight bottom-right corner (last of its group)", outRR ~= nil and outRR.corners.br == Round.TIGHT and outRR.corners.bl == Round.BUBBLE, "?")
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
  GetLocale = realLocale
  S.Reset()
`, 'card');

// --- Card: OnHide parks the draft (fix round 1, finding 1) --------------------------------
run(`
  local Echo = HorizonSuite.Echo
  local S, T, K, C = Echo.Store, Echo.Tiles, Echo.Stack, Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  C.Enable()
  local f = C._frames()

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  C.Open("w:Brisa-Horizon")
  f.edit:SetText("abc")
  check("root registers an OnHide handler", type(f.root.scripts.OnHide) == "function", type(f.root.scripts.OnHide))
  f.root:Hide()
  f.root.scripts.OnHide(f.root)
  check("escape's OnHide parks the draft", Echo.TakeDraft("w:Brisa-Horizon") == "abc", Echo.TakeDraft("w:Brisa-Horizon"))
  check("the box is empty after the draft is parked", f.edit.text == "", f.edit.text)

  Echo.ParkDraft("w:Brisa-Horizon", "xyz")
  C.Open("w:Brisa-Horizon")
  check("the draft comes back on reopen", f.edit.text == "xyz", f.edit.text)
  C.Hide()
  check("Card.Hide also parks (harness stubs don't fire OnHide on Hide())", Echo.TakeDraft("w:Brisa-Horizon") == "xyz", Echo.TakeDraft("w:Brisa-Horizon"))

  C.Disable()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'card-onhide');

// --- Genie: boundaries, pieces, colour and card alpha -------------------------------------
run(`
  local G = HorizonSuite.Echo.Genie
  local tile = { x = 870, y = 120, w = 30, h = 30 }
  local card = { x = 500, y = 100, w = 360, h = 440 }
  local n = 16

  local b0 = G.Boundaries(tile, card, 0, n)
  local folded = true
  for j = 0, n do
    local f = j / n
    if math.abs(b0.x[j] - tile.x) > 1e-9 or math.abs(b0.w[j] - tile.w) > 1e-9
      or math.abs(b0.y[j] - (tile.y + f * tile.h)) > 1e-9 then folded = false end
  end
  check("at grow 0 every boundary sits on the tile", folded, "")

  local b1 = G.Boundaries(tile, card, 1, n)
  local open = true
  for j = 0, n do
    local f = j / n
    if math.abs(b1.x[j] - card.x) > 1e-9 or math.abs(b1.w[j] - card.w) > 1e-9
      or math.abs(b1.y[j] - (card.y + f * card.h)) > 1e-9 then open = false end
  end
  check("at grow 1 every boundary sits on the card", open, "")

  -- The tile is below the card's centre: the far (top) side leads, the tile side goes last.
  local bm = G.Boundaries(tile, card, 0.5, n)
  check("the far side leads", bm.e[n] > bm.e[0], tostring(bm.e[n]) .. " vs " .. tostring(bm.e[0]))
  local mono = true
  for j = 1, n do if bm.e[j] < bm.e[j - 1] then mono = false end end
  check("progress rises steadily away from the tile", mono, "")
  local high = { x = 870, y = 600, w = 30, h = 30 }
  local bh = G.Boundaries(high, card, 0.5, n)
  check("a tile above the card flips which side leads", bh.e[0] > bh.e[n], tostring(bh.e[0]))
  check("the tile side is still folded at the stagger point", G.BoundaryProgress(0.45, 0, true) == 0, G.BoundaryProgress(0.45, 0, true))
  check("the far side is done before the end", G.BoundaryProgress(0.55, 1, true) == 1, G.BoundaryProgress(0.55, 1, true))

  -- Warped pieces share edges exactly with their neighbours.
  local pw = G.Pieces(bm, n, true)
  check("16 warped pieces", #pw == n, #pw)
  local shared = true
  for i = 1, n do
    local pc = pw[i]
    if math.abs((pc.left + pc.ul) - bm.x[i]) > 1e-9 then shared = false end
    if math.abs((pc.left + pc.ll) - bm.x[i - 1]) > 1e-9 then shared = false end
    if math.abs((pc.left + pc.width + pc.ur) - (bm.x[i] + bm.w[i])) > 1e-9 then shared = false end
    if math.abs((pc.left + pc.width + pc.lr) - (bm.x[i - 1] + bm.w[i - 1])) > 1e-9 then shared = false end
    if i > 1 and math.abs(pc.bottom - (pw[i - 1].bottom + pw[i - 1].height)) > 1e-6
      and pw[i - 1].height > 0.5 then shared = false end
  end
  check("warped corners are pinned to both boundaries", shared, "")
  local bt = G.Boundaries(tile, card, 0.5, 64)
  local pt = G.Pieces(bt, 64, false)
  check("thin strips run a hair taller", math.abs(pt[10].height - (math.max(0.5, bt.y[10] - bt.y[9]) + G.THIN_OVERLAP)) < 1e-9, pt[10].height)

  local r, g, b = G.Mix({ 1, 0, 0 }, { 0, 0, 1 }, 0)
  check("colour starts as the tile's", r == 1 and b == 0, r)
  r, g, b = G.Mix({ 1, 0, 0 }, { 0, 0, 1 }, 1)
  check("colour ends as the panel's", r == 0 and b == 1, b)

  check("the card is hidden until the end", G.CardAlpha(0.84) == 0 and G.CardAlpha(0.5) == 0, G.CardAlpha(0.84))
  check("the card fades in over the last stretch", math.abs(G.CardAlpha(0.92) - 0.5) < 1e-9, G.CardAlpha(0.92))
  check("the card is solid at the end", G.CardAlpha(1) == 1, G.CardAlpha(1))
`, 'genie-geometry');

// --- Genie: Play drives the overlay and calls onDone -----------------------------------------
run(`
  local G = HorizonSuite.Echo.Genie
  G._reset()
  local savedCreateFrame = CreateFrame
  CreateFrame = STUB_CREATE_FRAME
  local function Rect(l, b, w, h, scale)
    local f = STUB_FRAME()
    f.GetLeft = function() return l end
    f.GetBottom = function() return b end
    f.GetWidth = function() return w end
    f.GetHeight = function() return h end
    f.GetEffectiveScale = function() return scale or 1 end
    f.SetAlpha = function(self, a) self.alphaValue = a end
    return f
  end
  local tile, card = Rect(870, 120, 30, 30), Rect(500, 100, 360, 440)

  local done = 0
  G.Play({ from = STUB_FRAME(), to = STUB_FRAME(), onDone = function() done = done + 1 end })
  check("an unreadable rect goes straight to onDone", done == 1, done)
  check("an unreadable rect leaves nothing playing", not G.IsPlaying(), "playing")

  done = 0
  G.Play({ from = STUB_FRAME(), fallback = tile, to = card, onDone = function() done = done + 1 end })
  check("a tile without a rect falls back", G.IsPlaying(), "idle")
  G.Stop()

  done = 0
  G.Play({ from = tile, to = card, color = { 0.2, 0.7, 0.9 }, onDone = function() done = done + 1 end })
  local ov = G._overlay()
  check("Play builds the overlay", ov ~= nil and ov.shown, "")
  check("warped pieces where textures take vertex offsets", #ov.pieces == G.WARP_PIECES, #ov.pieces)
  check("an open starts folded, not finished", G.IsPlaying() and G.Progress() == 0 and done == 0, G.Progress())
  check("the card starts hidden", card.alphaValue == 0, card.alphaValue)
  local tick = ov.scripts.OnUpdate
  tick(ov, 0.1)
  local p1 = G.Progress()
  check("the open runs forward", p1 > 0 and p1 < 1, p1)
  check("pieces are laid against UIParent", ov.pieces[1].points[1] and ov.pieces[1].points[1][2] == UIParent, "")
  tick(ov, 0.1)
  check("progress keeps climbing", G.Progress() > p1, G.Progress())
  tick(ov, 1)
  check("onDone runs once at the end", done == 1, done)
  check("the overlay hides at the end", not ov.shown, ov.shown)
  check("the card is solid at the end", card.alphaValue == 1, card.alphaValue)
  tick(ov, 0.1)
  check("a stray tick after the end does nothing", done == 1, done)

  -- A close carries on from the finished open (grow 1) and runs down to 0.
  done = 0
  G.Play({ from = tile, to = card, reverse = true, onDone = function() done = done + 1 end })
  check("a close starts open, not finished", G.IsPlaying() and G.Progress() == 1 and done == 0, G.Progress())
  tick(ov, 0.1)
  local r1 = G.Progress()
  check("the close runs backward", r1 < 1 and r1 > 0, r1)
  tick(ov, 1)
  check("the close calls onDone at the end", done == 1, done)
  check("the close hides the overlay", not ov.shown, ov.shown)

  -- Reversing mid-open carries on from where the sheet is.
  G.Stop()
  G.Play({ from = tile, to = card })
  tick(ov, 0.275)
  local mid = G.Progress()
  G.Play({ from = tile, to = card, reverse = true })
  check("a close mid-open starts where the open was", math.abs(G.Progress() - mid) < 1e-9, G.Progress())
  tick(ov, G.CLOSE * mid + 0.01)
  check("and takes only the time left", not G.IsPlaying(), G.Progress())

  -- Stop drops onDone.
  done = 0
  G.Play({ from = tile, to = card, onDone = function() done = done + 1 end })
  tick(ov, 0.05)
  G.Stop()
  check("Stop hides the overlay", not ov.shown, ov.shown)
  tick(ov, 1)
  check("Stop drops onDone", done == 0, done)

  local rect = G.ReadRect(Rect(50, 60, 15, 15, 2))
  check("a rect is read in UIParent units", rect and rect.x == 100 and rect.y == 120 and rect.w == 30, rect and rect.x)
  G._reset()
  CreateFrame = savedCreateFrame
`, 'genie-play');

// --- Card: opens and closes with a genie from its tile --------------------------------------
run(`
  local Echo = HorizonSuite.Echo
  local S, T, K, C, G, V = Echo.Store, Echo.Tiles, Echo.Stack, Echo.Card, Echo.Genie, Echo.View
  S.Reset()
  G._reset()
  local savedCreateFrame = CreateFrame
  CreateFrame = STUB_CREATE_FRAME
  local db = {}
  HorizonSuite.ECHO_DEFAULTS = { echoAnimateCard = true, echoColumnEdge = "right" }
  HorizonSuite.GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  T.Enable()
  K.Enable()
  C.Enable()
  local f = C._frames()

  local function Geometry(frame, l, b, w, h)
    frame.GetLeft = function() return l end
    frame.GetBottom = function() return b end
    frame.GetWidth = function() return w end
    frame.GetHeight = function() return h end
    frame.GetEffectiveScale = function() return 1 end
  end
  f.root.SetAlpha = function(self, a) self.alphaValue = a end
  f.root.GetAlpha = function(self) return rawget(self, "alphaValue") or 1 end
  Geometry(f.root, 500, 100, 360, 440)

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon" })
  S.Add({ convKey = "w:Vexa-Horizon", text = "gz", sender = "Vexa-Horizon" })
  local vexa = T.TileFor("w:Vexa-Horizon")
  local brisa = T.TileFor("w:Brisa-Horizon")
  check("the column has tiles", vexa ~= nil and brisa ~= nil, "nil")
  Geometry(vexa, 870, 120, 30, 30)
  Geometry(brisa, 870, 160, 30, 30)

  vexa.scripts.OnClick(vexa)
  local ov = G._overlay()
  check("a tile open shows the card", f.root:IsShown(), "hidden")
  check("a tile open starts at alpha 0", f.root:GetAlpha() == 0, f.root:GetAlpha())
  check("a tile open starts a genie", G.IsPlaying(), "idle")
  check("the genie runs forward", not G._current().reverse, "reverse")
  check("the genie starts from the tile", G._current().from == vexa, "")
  local r, g, b = V.FaceBackground(V.TileSpec(S.Get("w:Vexa-Horizon")))
  local col = G._current().color
  check("the genie is the tile's face colour", col[1] == r and col[2] == g and col[3] == b, col[1])
  ov.scripts.OnUpdate(ov, 1)
  check("the genie ends", not G.IsPlaying(), "playing")
  check("the card is solid when the sheet ends", f.root:GetAlpha() == 1, f.root:GetAlpha())

  vexa.scripts.OnClick(vexa)
  check("a toggle close keeps the card up during the genie", f.root:IsShown(), "hidden")
  check("a toggle close runs a reverse genie", G.IsPlaying() and G._current().reverse, "")
  vexa.scripts.OnClick(vexa)
  check("a second click during the close is ignored", f.root:IsShown() and G.IsPlaying() and G._current().reverse, "")
  check("the card says a close is animating", C.IsClosing() == true, tostring(C.IsClosing()))
  ov.scripts.OnUpdate(ov, 0.1)
  check("the card fades as the sheet folds", f.root:GetAlpha() < 1, f.root:GetAlpha())
  ov.scripts.OnUpdate(ov, 1)
  check("the close hides the card at the end", not f.root:IsShown(), "shown")
  check("and that it no longer is", C.IsClosing() == false, tostring(C.IsClosing()))
  check("the close restores alpha for the next open", f.root:GetAlpha() == 1, f.root:GetAlpha())

  vexa.scripts.OnClick(vexa)
  check("reopened with a genie", G.IsPlaying() and G.Progress() == 0, G.Progress())
  C.Hide()
  check("Hide is instant", not f.root:IsShown(), "shown")
  check("Hide stops the genie", not G.IsPlaying(), "playing")
  check("Hide restores alpha", f.root:GetAlpha() == 1, f.root:GetAlpha())

  vexa.scripts.OnClick(vexa)
  ov.scripts.OnUpdate(ov, 1)
  vexa.scripts.OnClick(vexa)
  check("closing", G.IsPlaying() and G._current().reverse, "")
  f.root:Hide()
  f.root.scripts.OnHide(f.root)
  check("OnHide during a close stops the genie", not G.IsPlaying(), "playing")
  check("OnHide restores alpha", f.root:GetAlpha() == 1, f.root:GetAlpha())
  vexa.scripts.OnClick(vexa)
  check("a click after an interrupted close opens again", f.root:IsShown() and G.IsPlaying() and not G._current().reverse, "")
  C.Hide()

  vexa.scripts.OnClick(vexa)
  ov.scripts.OnUpdate(ov, 1)
  vexa.scripts.OnClick(vexa)
  check("closing again", G.IsPlaying() and G._current().reverse, "")
  brisa.scripts.OnClick(brisa)
  check("another tile mid-close cancels the close", not G.IsPlaying(), "playing")
  check("and shows the card at full alpha", f.root:IsShown() and f.root:GetAlpha() == 1, f.root:GetAlpha())
  check("on the other conversation", f.name.text == "Brisa", f.name.text)
  ov.scripts.OnUpdate(ov, 1)
  check("the cancelled close never hides the card", f.root:IsShown(), "hidden")

  local rowTile
  for _, t in ipairs(f.rowTiles) do if t.convKey == "w:Brisa-Horizon" then rowTile = t end end
  rowTile.scripts.OnClick(rowTile)
  check("a row tile close runs a reverse genie", G.IsPlaying() and G._current().reverse, "")
  check("into the column tile", G._current().from == brisa, "")
  ov.scripts.OnUpdate(ov, 1)
  check("and hides", not f.root:IsShown(), "shown")

  C.Open("w:Vexa-Horizon")
  check("no tile opens at alpha 1", f.root:GetAlpha() == 1 and not G.IsPlaying(), f.root:GetAlpha())
  C.Hide()
  db.echoAnimateCard = false
  vexa.scripts.OnClick(vexa)
  check("the setting off opens at alpha 1", f.root:IsShown() and f.root:GetAlpha() == 1, f.root:GetAlpha())
  check("the setting off plays no genie", not G.IsPlaying(), "playing")
  vexa.scripts.OnClick(vexa)
  check("the setting off closes at once", not f.root:IsShown(), "shown")
  db.echoAnimateCard = nil

  vexa.GetLeft = nil
  vexa.scripts.OnClick(vexa)
  check("an unmeasurable tile still opens, at full alpha", f.root:IsShown() and not G.IsPlaying() and f.root:GetAlpha() == 1, f.root:GetAlpha())
  C.Hide()

  C.Disable()
  K.Disable()
  T.Disable()
  G._reset()
  CreateFrame = savedCreateFrame
  HorizonSuite.ECHO_DEFAULTS, HorizonSuite.GetDB = nil, nil
  S.Reset()
`, 'card-genie');

// --- Card: retry only marks resent, and dims a retried bubble (fix round 1, finding 2) ----
run(`
  local Echo = HorizonSuite.Echo
  local S, T, K, C = Echo.Store, Echo.Tiles, Echo.Stack, Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  local sent = {}
  C_ChatInfo = { SendChatMessage = function(msg, chatType, _, target) sent[#sent + 1] = chatType .. ":" .. tostring(target) .. ":" .. msg end }
  T.Enable()
  K.Enable()
  C.Enable()
  local f = C._frames()

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  C.Open("w:Brisa-Horizon")
  f.edit:SetText("first try")
  f.edit.scripts.OnEnterPressed(f.edit)
  S.MarkFailed("w:Brisa-Horizon")
  local failedMsg = f.status.retry

  local realSend = Echo.Send.Send
  Echo.Send.Send = function() return false end
  f.status.scripts.OnClick(f.status)
  check("a failed retry that can't route leaves the message failed", failedMsg.status == "failed", failedMsg.status)
  Echo.Send.Send = realSend

  f.status.scripts.OnClick(f.status)
  check("retry sends again once it can route", sent[1] == "WHISPER:Brisa-Horizon:first try", sent[1])
  check("a successful retry marks the message retried", failedMsg.status == "retried", failedMsg.status)
  local rr2 = rawget(f.bubbles[2], "_echoRound")
  local alpha2 = rr2 and rr2.fill.middleBand.vertexColor and rr2.fill.middleBand.vertexColor[4]
  check("a retried bubble is dimmed like a pending one", alpha2 == 0.14, alpha2)

  C.Disable()
  K.Disable()
  T.Disable()
  C_ChatInfo = nil
  S.Reset()
`, 'card-retry');

// --- Card.Retry marks the card for a deferred repaint instead of rendering right away -------
run(`
  local Echo = HorizonSuite.Echo
  local S, T, K, C, R = Echo.Store, Echo.Tiles, Echo.Stack, Echo.Card, Echo.Redraw
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  C_ChatInfo = { SendChatMessage = function() end }
  T.Enable()
  K.Enable()
  C.Enable()
  local f = C._frames()

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  C.Open("w:Brisa-Horizon")
  f.edit:SetText("first try")
  f.edit.scripts.OnEnterPressed(f.edit)
  S.MarkFailed("w:Brisa-Horizon")
  local failedMsg = f.status.retry
  local function fillAlpha(b)
    local rr = rawget(b, "_echoRound")
    return rr and rr.fill.middleBand.vertexColor and rr.fill.middleBand.vertexColor[4]
  end
  check("a failed bubble is not dimmed", fillAlpha(f.bubbles[1]) == 0.24, fillAlpha(f.bubbles[1]))

  R.sync = false
  f.status.scripts.OnClick(f.status)
  check("retry still marks the record retried", failedMsg.status == "retried", failedMsg.status)
  check("the card is pending a repaint, not rendered inline", R.Pending("card") == true, R.Pending("card"))
  check("the dimmed styling has not landed yet", fillAlpha(f.bubbles[1]) == 0.24, fillAlpha(f.bubbles[1]))
  R.Flush()
  check("the dimmed styling lands once the deferred repaint runs", fillAlpha(f.bubbles[2]) == 0.14, fillAlpha(f.bubbles[2]))
  R.sync = true

  C.Disable()
  K.Disable()
  T.Disable()
  C_ChatInfo = nil
  S.Reset()
`, 'card-retry-deferred');

// --- Card: an unmeasurable-width bubble falls back to full width (fix round 1, finding 3) --
run(`
  local Echo = HorizonSuite.Echo
  local S, T, K, C = Echo.Store, Echo.Tiles, Echo.Stack, Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  C.Enable()
  local f = C._frames()

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  C.Open("w:Brisa-Horizon")
  local bubble = f.bubbles[1]
  bubble.text.GetUnboundedStringWidth = function() return 0 end
  S.Add({ convKey = "w:Brisa-Horizon", text = "zero-width report", sender = "Brisa-Horizon" })
  check("a zero measured width is treated as unmeasured", f.bubbles[1].width == HorizonSuite.Echo.Card.BUBBLE_MAX, f.bubbles[1].width)

  C.Disable()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'card-width');

// --- Card: keep your place ---------------------------------------------------------------
run(`
  local Echo = HorizonSuite.Echo
  local S, T, K, C = Echo.Store, Echo.Tiles, Echo.Stack, Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  C.Enable()
  local f = C._frames()
  local Lt = HorizonSuite.L

  S.Add({ convKey = "w:Brisa-Horizon", text = "m1", sender = "Brisa-Horizon", class = "DRUID" })
  for i = 2, 30 do S.Add({ convKey = "w:Brisa-Horizon", text = "m" .. i, sender = "Brisa-Horizon" }) end
  C.Open("w:Brisa-Horizon")
  C.Scroll(5)
  local pinned = f.bubbles[1].text.text

  rawset(Lt, "ECHO_NEW_BELOW", "%d new below")
  S.Add({ convKey = "w:Brisa-Horizon", text = "n1", sender = "Brisa-Horizon" })
  S.Add({ convKey = "w:Brisa-Horizon", text = "n2", sender = "Brisa-Horizon" })
  S.Add({ convKey = "w:Brisa-Horizon", text = "n3", sender = "Brisa-Horizon" })
  check("the bubble stays put while scrolled up", f.bubbles[1].text.text == pinned, f.bubbles[1].text.text)
  check("the hint counts the new messages", f.hint.text.text == "3 new below", f.hint.text.text)
  check("the hint is shown", f.hint.shown, "hidden")
  check("the hint is raised above the message area", f.hint.frameLevel == f.area:GetFrameLevel() + 5, tostring(f.hint.frameLevel))

  f.hint.scripts.OnClick(f.hint)
  check("clicking the hint jumps to the newest message", f.bubbles[1].text.text == "n3", f.bubbles[1].text.text)
  check("clicking the hint hides it", not f.hint.shown, "shown")

  S.Add({ convKey = "w:Brisa-Horizon", text = "n4", sender = "Brisa-Horizon" })
  check("at the bottom a new message renders at once", f.bubbles[1].text.text == "n4", f.bubbles[1].text.text)
  check("no hint shows at the bottom", not f.hint.shown, "shown")
  rawset(Lt, "ECHO_NEW_BELOW", nil)

  -- Closed drafts: a conversation closed while its draft sits in the box.
  S.Add({ convKey = "w:Vexa-Horizon", text = "hey", sender = "Vexa-Horizon" })
  C.Show("w:Brisa-Horizon")
  f.edit:SetText("draft for brisa")
  S.Close("w:Brisa-Horizon")
  local taken = Echo.TakeDraft("w:Brisa-Horizon")
  check("closing discards the parked draft", taken == "", taken)
  check("the box is cleared when its own conversation closes", f.edit.text == "", f.edit.text)
  S.Add({ convKey = "w:Brisa-Horizon", text = "hey again", sender = "Brisa-Horizon" })
  C.Open("w:Brisa-Horizon")
  check("reopening after a close shows an empty box, not the old draft", f.edit.text == "", f.edit.text)

  -- Upper-casing only in English. A mixed-case localized class name makes the change visible.
  local savedNames = LOCALIZED_CLASS_NAMES_MALE
  LOCALIZED_CLASS_NAMES_MALE = { DRUID = "Druid" }
  local realLocale = GetLocale
  GetLocale = function() return "enUS" end
  C.Show("w:Brisa-Horizon")
  check("enUS upper-cases the meta line", f.meta.text:find("DRUID", 1, true) ~= nil, f.meta.text)
  GetLocale = function() return "deDE" end
  C.Show("w:Vexa-Horizon")
  C.Show("w:Brisa-Horizon")
  check("deDE leaves the meta line alone", f.meta.text:find("Druid", 1, true) ~= nil, f.meta.text)
  GetLocale = realLocale
  LOCALIZED_CLASS_NAMES_MALE = savedNames

  C.Disable()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'card-keep-place');

// --- Stack: OnHide parks the draft (fix round 1, finding 1) -------------------------------
run(`
  local Echo = HorizonSuite.Echo
  local S, T, K = Echo.Store, Echo.Tiles, Echo.Stack
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  local f = K._frames()

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  K.Open("w:Brisa-Horizon")
  f.edit:SetText("stack draft")
  f.root:Hide()
  f.root.scripts.OnHide(f.root)
  check("escape's OnHide parks the stack draft", Echo.TakeDraft("w:Brisa-Horizon") == "stack draft", Echo.TakeDraft("w:Brisa-Horizon"))
  check("the stack box is empty after the draft is parked", f.edit.text == "", f.edit.text)

  Echo.ParkDraft("w:Brisa-Horizon", "another")
  K.Open("w:Brisa-Horizon")
  check("the draft comes back on reopen", f.edit.text == "another", f.edit.text)
  K.Hide()
  check("Stack.Hide also parks (harness stubs don't fire OnHide on Hide())", Echo.TakeDraft("w:Brisa-Horizon") == "another", Echo.TakeDraft("w:Brisa-Horizon"))

  K.Disable()
  T.Disable()
  S.Reset()
`, 'stack-onhide-park');

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
  local vexa = T.TileFor("w:Vexa-Horizon")
  vexa.scripts.OnClick(vexa)
  check("clicking another tile switches the card", card.root:IsShown() and card.name.text == "Vexa", card.name.text)
  vexa.scripts.OnClick(vexa)
  check("clicking the shown conversation's tile closes the card", not card.root:IsShown(), "still open")
  tile.scripts.OnClick(tile)
  local rowBrisa
  for _, b in ipairs(card.rowTiles) do if b.convKey == "w:Brisa-Horizon" and b:IsShown() then rowBrisa = b end end
  rowBrisa.scripts.OnClick(rowBrisa)
  check("clicking the card's own row tile for it closes the card", not card.root:IsShown(), "still open")
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

// --- Final fix G1: a reply sent while scrolled up is shown; a refused send keeps its text --
run(`
  local Echo = HorizonSuite.Echo
  local S, T, K, C = Echo.Store, Echo.Tiles, Echo.Stack, Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  C_ChatInfo = { SendChatMessage = function() end }
  T.Enable()
  K.Enable()
  C.Enable()
  local f = C._frames()

  for i = 1, 20 do S.Add({ convKey = "w:Brisa-Horizon", text = "line " .. i, sender = "Brisa-Horizon" }) end
  C.Open("w:Brisa-Horizon")
  C.Scroll(5)
  check("G1: the card is scrolled up", f.bubbles[1].text.text == "line 15", f.bubbles[1].text.text)
  f.edit:SetText("sent while scrolled up")
  C.Submit()
  check("G1: a reply sent while scrolled up is the bottom bubble", f.bubbles[1].text.text == "sent while scrolled up", f.bubbles[1].text.text)

  local realSend = Echo.Send.Send
  Echo.Send.Send = function() return false end
  f.edit:SetText("cannot route")
  C.Submit()
  check("G1: a refused send keeps its text in the card box", f.edit.text == "cannot route", f.edit.text)
  C.Hide()
  Echo.TakeDraft("w:Brisa-Horizon")

  local sf = K._frames()
  K.Open("w:Brisa-Horizon")
  sf.edit:SetText("stack cannot route")
  sf.edit.scripts.OnEnterPressed(sf.edit)
  check("G1: a refused send keeps its text in the stack box", sf.edit.text == "stack cannot route", sf.edit.text)
  Echo.Send.Send = realSend
  K.Hide()
  Echo.TakeDraft("w:Brisa-Horizon")

  C.Disable()
  K.Disable()
  T.Disable()
  C_ChatInfo = nil
  S.Reset()
`, 'final-g1');

// --- Final fix G2: only a whisper card names a class -------------------------------------
run(`
  local S, V = HorizonSuite.Echo.Store, HorizonSuite.Echo.View
  S.Reset()
  local savedNames = LOCALIZED_CLASS_NAMES_MALE
  LOCALIZED_CLASS_NAMES_MALE = { WARRIOR = "Warrior", DRUID = "Druid" }
  S.Add({ convKey = "party", text = "pull", sender = "Tank-Horizon", class = "WARRIOR" })
  local meta = V.CardMeta(S.Get("party"))
  check("G2: a party card names no speaker's class", meta:find("Warrior", 1, true) == nil, meta)
  S.Add({ convKey = "ch:Trade", text = "wts", sender = "Seller-Horizon", class = "WARRIOR" })
  meta = V.CardMeta(S.Get("ch:Trade"))
  check("G2: a channel card names no speaker's class", meta:find("Warrior", 1, true) == nil, meta)
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon", class = "DRUID" })
  meta = V.CardMeta(S.Get("w:Brisa-Horizon"))
  check("G2: a whisper card still names the class", meta:find("Druid", 1, true) ~= nil, meta)
  LOCALIZED_CLASS_NAMES_MALE = savedNames
  S.Reset()
`, 'final-g2');

// --- Final fix G3: no toast over an open card ----------------------------------------------
run(`
  local S, T, K, C = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles, HorizonSuite.Echo.Stack, HorizonSuite.Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  C.Enable()
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  local toast = T._toast()
  toast:Hide()
  C.Open("w:Brisa-Horizon")
  S.Add({ convKey = "w:Vexa-Horizon", text = "gz", sender = "Vexa-Horizon" })
  check("G3: a loud message while the card is open shows no toast", not toast.shown, toast.convKey)
  check("G3: the new conversation still gets its tile", T.TileFor("w:Vexa-Horizon") ~= nil, "no tile")
  C.Hide()
  T.Hold(true)
  C.Open("w:Brisa-Horizon")
  S.Add({ convKey = "w:Orin-Horizon", text = "yo", sender = "Orin-Horizon" })
  C.Hide()
  T.Hold(false)
  check("G3: a loud message while the card is open is not queued for after combat", not toast.shown, toast.convKey)

  C.Disable()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'final-g3');

// --- Final fix G4: another conversation's message repaints only the card's tile row -------
run(`
  local S, T, K, C = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles, HorizonSuite.Echo.Stack, HorizonSuite.Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  C.Enable()
  local f = C._frames()
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  S.Add({ convKey = "w:Vexa-Horizon", text = "gz", sender = "Vexa-Horizon" })
  S.MarkRead("w:Vexa-Horizon")
  C.Open("w:Brisa-Horizon")
  local function RowTile(key)
    for _, b in ipairs(f.rowTiles) do if b.convKey == key and b.shown then return b end end
  end
  check("G4: a read conversation's row tile has no dot", not RowTile("w:Vexa-Horizon").dot.shown, "dot")
  f.bubbles[1].text.text = "sentinel"
  S.Add({ convKey = "w:Vexa-Horizon", text = "still there?", sender = "Vexa-Horizon" })
  check("G4: another conversation's message leaves the bubbles untouched", f.bubbles[1].text.text == "sentinel", f.bubbles[1].text.text)
  check("G4: it still dots that conversation's row tile", RowTile("w:Vexa-Horizon") and RowTile("w:Vexa-Horizon").dot.shown, "no dot")
  check("G4: the card's conversation keeps its outline", RowTile("w:Brisa-Horizon") ~= nil and not RowTile("w:Brisa-Horizon").dot.shown, "?")
  S.Add({ convKey = "w:Orin-Horizon", text = "new here", sender = "Orin-Horizon" })
  check("G4: a new conversation gets a row tile without a full render", RowTile("w:Orin-Horizon") ~= nil and f.bubbles[1].text.text == "sentinel", f.bubbles[1].text.text)
  S.Add({ convKey = "w:Brisa-Horizon", text = "back", sender = "Brisa-Horizon" })
  check("G4: the card's own conversation still renders in full", f.bubbles[1].text.text == "back", f.bubbles[1].text.text)
  f.bubbles[1].text.text = "sentinel"
  S.Close("w:Orin-Horizon")
  check("G4: closing another conversation renders in full", f.bubbles[1].text.text == "back" and RowTile("w:Orin-Horizon") == nil, f.bubbles[1].text.text)

  C.Disable()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'final-g4');

// --- Final fix G5: small safety fixes ------------------------------------------------------
run(`
  local Echo = HorizonSuite.Echo
  local S, H, T, K, C, Links = Echo.Store, Echo.History, Echo.Tiles, Echo.Stack, Echo.Card, Echo.Links

  -- (a) A secret never reaches the focused box, even one that answers type() with "string"
  -- as game secrets do.
  local box = { text = "" }
  function box:Insert(t) self.text = self.text .. tostring(t) end
  function box:HasFocus() return true end
  Links.Focus(box)
  local realType = type
  type = function(v)
    if realType(v) == "table" and v.__secret == true then return "string" end
    return realType(v)
  end
  local ok, inserted = pcall(Links.Insert, SECRET("x"))
  type = realType
  check("G5a: a secret link is refused", ok and inserted == false and box.text == "", tostring(ok) .. "/" .. tostring(inserted) .. "/" .. box.text)
  Links.Blur(box)

  -- (b) No menu to open, no ⋯ button.
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  C.Enable()
  local f = C._frames()
  local savedMenuUtil = MenuUtil
  MenuUtil = { CreateContextMenu = function() end }
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  C.Open("w:Brisa-Horizon")
  check("G5b: with MenuUtil the menu button shows", f.menu.shown, "hidden")
  MenuUtil = nil
  C.Render()
  check("G5b: without MenuUtil the menu button is hidden", not f.menu.shown, "shown")
  MenuUtil = savedMenuUtil

  -- (c) A fitted bubble gets 2 px of slack, never past the widest bubble.
  local measured = 40.2
  f.bubbles[1].text.GetUnboundedStringWidth = function() return measured end
  S.Add({ convKey = "w:Brisa-Horizon", text = "short", sender = "Brisa-Horizon" })
  check("G5c: a fitted bubble gets 2 px of slack", f.bubbles[1].width == 59, f.bubbles[1].width)
  measured = 233
  S.Add({ convKey = "w:Brisa-Horizon", text = "nearly the widest", sender = "Brisa-Horizon" })
  check("G5c: the slack stops at the widest bubble", f.bubbles[1].width == C.BUBBLE_MAX, f.bubbles[1].width)
  f.bubbles[1].text.GetUnboundedStringWidth = nil
  C.Disable()
  K.Disable()
  T.Disable()

  -- (d) Closing keeps a tier override and drops the pin.
  S.Reset()
  local db = {}
  H.Bind(db, function() return "Kaelis-Horizon" end)
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi" })
  S.SetPinned("w:Brisa-Horizon", true)
  S.SetTier("w:Brisa-Horizon", "quiet")
  S.Close("w:Brisa-Horizon")
  local pref = db.echoHistory.prefs["Kaelis-Horizon"]["w:Brisa-Horizon"]
  check("G5d: closing keeps the saved tier and drops the pin", pref and pref.tier == "quiet" and pref.pinned == nil, pref and tostring(pref.pinned))
  H.Unbind()
  S.Reset()
`, 'final-g5');

// --- Final fix G6: the reply keybind while the card is open ---------------------------------
run(`
  local Echo = HorizonSuite.Echo
  local S, T, K, C = Echo.Store, Echo.Tiles, Echo.Stack, Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  C.Enable()
  local f, sf = C._frames(), K._frames()
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  C.Open("w:Brisa-Horizon")
  S.Add({ convKey = "w:Vexa-Horizon", text = "you there?", sender = "Vexa-Horizon" })
  Echo.ParkDraft("w:Vexa-Horizon", "half")
  f.edit.focused = false
  K.ReplyToNewest()
  check("G6: the keybind switches the open card to the newest loud conversation", f.root:IsShown() and f.name.text == "Vexa", f.name.text)
  check("G6: the card's reply box is focused", f.edit.focused == true, tostring(f.edit.focused))
  check("G6: the stack stays shut", not sf.root:IsShown(), "shown")
  check("G6: the draft came back with the conversation", f.edit.text == "half", f.edit.text)
  f.edit:SetText("halfr")
  check("G6: the card box handles OnChar", type(f.edit.scripts.OnChar) == "function", "no OnChar")
  if f.edit.scripts.OnChar then f.edit.scripts.OnChar(f.edit, "r") end
  check("G6: the keybind's own key is not typed into the card box", f.edit.text == "half", f.edit.text)
  f.edit:SetText("halfx")
  if f.edit.scripts.OnChar then f.edit.scripts.OnChar(f.edit, "x") end
  check("G6: later typing is kept", f.edit.text == "halfx", f.edit.text)

  C.Disable()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'final-g6');

// --- Final fix H1: the hint clamps as you scroll back down, and clears on reopen ------------
run(`
  local Echo = HorizonSuite.Echo
  local S, T, K, C = Echo.Store, Echo.Tiles, Echo.Stack, Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  C.Enable()
  local f = C._frames()
  rawset(HorizonSuite.L, "ECHO_NEW_BELOW", "%d new below")

  for i = 1, 30 do S.Add({ convKey = "w:Brisa-Horizon", text = "m" .. i, sender = "Brisa-Horizon" }) end
  C.Open("w:Brisa-Horizon")
  C.Scroll(5)
  S.Add({ convKey = "w:Brisa-Horizon", text = "n1", sender = "Brisa-Horizon" })
  S.Add({ convKey = "w:Brisa-Horizon", text = "n2", sender = "Brisa-Horizon" })
  S.Add({ convKey = "w:Brisa-Horizon", text = "n3", sender = "Brisa-Horizon" })
  check("H1: three incoming while scrolled up show the hint at 3", f.hint.text.text == "3 new below", f.hint.text.text)

  C.Scroll(-2)
  check("H1: scrolling down but staying past the new arrivals leaves the count alone", f.hint.text.text == "3 new below" and f.hint.shown, f.hint.text.text)

  C.Scroll(-5)
  check("H1: scrolling down into the new arrivals shrinks the count to match", f.hint.text.text == "1 new below" and f.hint.shown, f.hint.text.text)

  C.Scroll(-1)
  check("H1: scrolling the rest of the way to the bottom hides the hint", not f.hint.shown, "shown")

  -- Reopening the same conversation always clears a stale hint, even though its rendered
  -- key doesn't change.
  C.Scroll(5)
  S.Add({ convKey = "w:Brisa-Horizon", text = "n4", sender = "Brisa-Horizon" })
  check("H1: setup: the hint is showing again before the reopen", f.hint.shown, "hidden")
  C.Open("w:Brisa-Horizon")
  check("H1: Card.Open resets the hint even on the same conversation", not f.hint.shown, "shown")

  rawset(HorizonSuite.L, "ECHO_NEW_BELOW", nil)
  C.Disable()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'final-h1');

// --- Final fix H2: a refused send while scrolled up still renders at offset 0 --------------
run(`
  local Echo = HorizonSuite.Echo
  local S, T, K, C = Echo.Store, Echo.Tiles, Echo.Stack, Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  C.Enable()
  local f = C._frames()

  for i = 1, 20 do S.Add({ convKey = "w:Brisa-Horizon", text = "line " .. i, sender = "Brisa-Horizon" }) end
  C.Open("w:Brisa-Horizon")
  C.Scroll(5)
  check("H2: setup: the card is scrolled up", f.bubbles[1].text.text == "line 15", f.bubbles[1].text.text)

  local realSend = Echo.Send.Send
  Echo.Send.Send = function() return false end
  f.edit:SetText("nowhere to send this")
  C.Submit()
  check("H2: a refused send while scrolled up still shows the newest message", f.bubbles[1].text.text == "line 20", f.bubbles[1].text.text)
  check("H2: the refused text is kept in the box", f.edit.text == "nowhere to send this", f.edit.text)
  Echo.Send.Send = realSend

  C.Disable()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'final-h2');

// --- Final fix H3: an outgoing line anchors the view but is not counted as news ------------
run(`
  local Echo = HorizonSuite.Echo
  local S, T, K, C = Echo.Store, Echo.Tiles, Echo.Stack, Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  C.Enable()
  local f = C._frames()
  rawset(HorizonSuite.L, "ECHO_NEW_BELOW", "%d new below")

  for i = 1, 20 do S.Add({ convKey = "w:Brisa-Horizon", text = "line " .. i, sender = "Brisa-Horizon" }) end
  C.Open("w:Brisa-Horizon")
  C.Scroll(5)
  local pinned = f.bubbles[1].text.text

  -- An outgoing line lands while scrolled up (e.g. a retried send elsewhere): the view
  -- still doesn't move, but it isn't news, so the hint stays hidden.
  S.Add({ convKey = "w:Brisa-Horizon", text = "my reply", outgoing = true })
  check("H3: the bubble stays put for an outgoing line too", f.bubbles[1].text.text == pinned, f.bubbles[1].text.text)
  check("H3: an outgoing line alone shows no hint", not f.hint.shown, "shown")

  -- An incoming line afterwards still counts, on top of the anchor the outgoing line added.
  S.Add({ convKey = "w:Brisa-Horizon", text = "reply to that", sender = "Brisa-Horizon" })
  check("H3: an incoming line after it is still counted", f.hint.text.text == "1 new below" and f.hint.shown, f.hint.text.text)

  rawset(HorizonSuite.L, "ECHO_NEW_BELOW", nil)
  C.Disable()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'final-h3');

// --- Feeds: loot, progress and system lines --------------------------------------------
run(`
  local S, E = HorizonSuite.Echo.Store, HorizonSuite.Echo.Events
  S.Reset()
  local function p(text, sender) return text, sender, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil end

  check("feeds are known kinds", S.KindOf("loot") == "loot" and S.KindOf("progress") == "progress" and S.KindOf("system") == "system", "?")
  check("feeds are quiet by default", S.TierOf("loot") == "quiet" and S.TierOf("progress") == "quiet" and S.TierOf("system") == "quiet", "?")
  check("feeds are flagged", S.FEED_KINDS.loot and S.FEED_KINDS.progress and S.FEED_KINDS.system and not S.FEED_KINDS.party, "?")

  local r = E.BuildRecord("CHAT_MSG_LOOT", p("You receive loot: [Cloak].", "Kaelis-Horizon"))
  check("loot goes to the loot feed", r and r.convKey == "loot" and r.feed == true, r and r.convKey)
  check("your own loot is not an outgoing message", r.outgoing == false, r.outgoing)
  check("a feed line remembers its line type", r.chatType == "LOOT", r.chatType)
  check("a feed line has no class and is never urgent", r.class == nil and r.urgent == false, "?")
  check("money and currency go to loot", E.BuildRecord("CHAT_MSG_MONEY", p("You loot 3 Gold")).convKey == "loot"
        and E.BuildRecord("CHAT_MSG_CURRENCY", p("You receive currency")).convKey == "loot", "?")
  for _, ev in ipairs({ "CHAT_MSG_COMBAT_FACTION_CHANGE", "CHAT_MSG_COMBAT_XP_GAIN", "CHAT_MSG_SKILL" }) do
    check(ev .. " goes to progress", E.BuildRecord(ev, p("progress")).convKey == "progress", ev)
  end
  r = E.BuildRecord("CHAT_MSG_SYSTEM", p("You feel rested."))
  check("system lines go to the system feed", r.convKey == "system" and r.chatType == "SYSTEM", r.convKey)

  r = E.BuildRecord("CHAT_MSG_ACHIEVEMENT", p("%s has earned the achievement [Cloak Collector]!", "Brisa-Horizon"))
  check("an achievement names the player as a link", r.convKey == "progress"
        and r.text == "|Hplayer:Brisa-Horizon|h[Brisa]|h has earned the achievement [Cloak Collector]!", r.text)
  r = E.BuildRecord("CHAT_MSG_GUILD_ACHIEVEMENT", p("%s has earned the achievement [Raider]!", SECRET("Brisa-Horizon")))
  check("a secret achiever is named as someone", r.text == "ECHO_SOMEONE has earned the achievement [Raider]!", r.text)
  r = E.BuildRecord("CHAT_MSG_ACHIEVEMENT", p("%s has earned the achievement [Explorer]!", ""))
  check("an empty achiever is named as someone", r.text == "ECHO_SOMEONE has earned the achievement [Explorer]!", r.text)
  r = E.BuildRecord("CHAT_MSG_ACHIEVEMENT", p("%s has earned the achievement [Explorer]!", nil))
  check("a missing achiever is named as someone", r.text == "ECHO_SOMEONE has earned the achievement [Explorer]!", r.text)
  r = E.BuildRecord("CHAT_MSG_ACHIEVEMENT", p("%s has %d", nil))
  check("an achievement text that won't format is left as it came", r.text == "%s has %d", r.text)

  local savedOnline = BN_INLINE_TOAST_FRIEND_ONLINE
  BN_INLINE_TOAST_FRIEND_ONLINE = "%s has come online."
  r = E.BuildRecord("BN_INLINE_TOAST_ALERT", p("FRIEND_ONLINE", "|Kq1|k"))
  check("a battle.net alert uses Blizzard's own text", r and r.convKey == "system" and r.text == "|Kq1|k has come online." and r.chatType == "BN_INLINE_TOAST_ALERT", r and r.text)
  local none, reason = E.BuildRecord("BN_INLINE_TOAST_ALERT", p("NOT_A_REAL_TOAST", "|Kq1|k"))
  check("an alert with no Blizzard text is ignored", none == nil and reason == "ignored", reason)
  none, reason = E.BuildRecord("BN_INLINE_TOAST_ALERT", p("FRIEND_ONLINE", SECRET("|Kq1|k")))
  check("an alert with a secret name is ignored", none == nil and reason == "ignored", reason)
  BN_INLINE_TOAST_FRIEND_ONLINE = savedOnline

  local savedPending = BN_INLINE_TOAST_FRIEND_PENDING
  BN_INLINE_TOAST_FRIEND_PENDING = "You have %d pending invites."
  none, reason = E.BuildRecord("BN_INLINE_TOAST_ALERT", p("FRIEND_PENDING", "|Kq1|k"))
  check("an alert whose text needs a count is ignored", none == nil and reason == "ignored", reason)
  BN_INLINE_TOAST_FRIEND_PENDING = "%s sent %d invites"
  none, reason = E.BuildRecord("BN_INLINE_TOAST_ALERT", p("FRIEND_PENDING", "|Kq1|k"))
  check("an alert with a name and a count is ignored", none == nil and reason == "ignored", reason)
  BN_INLINE_TOAST_FRIEND_PENDING = savedPending

  r = E.BuildRecord("CHAT_MSG_LOOT", p(SECRET("You receive loot: [Hidden]."), "Kaelis-Horizon"))
  check("a secret loot line still lands in its feed", r and r.convKey == "loot" and r.secret == true, r and r.convKey)

  S.Reset()
  local q = S.AddPending("w:Ghost-Horizon", "hello?")
  E.Dispatch("CHAT_MSG_SYSTEM", "No player named 'Ghost' is currently playing.")
  check("a system line still fails the pending whisper", q.status == "failed", q.status)
  check("and it is filed in the system feed", S.Get("system") and #S.Get("system").messages == 1, "not filed")
  local T = HorizonSuite.Echo.Tiles
  local savedShowToast, toasted, lootChange = T.ShowToast, 0, nil
  T.ShowToast = function(...) toasted = toasted + 1; return savedShowToast(...) end
  local function listen(key, change) if key == "loot" then lootChange = change end end
  S.Subscribe(listen)
  E.Dispatch("CHAT_MSG_LOOT", p("You receive loot: [Cloak].", "Kaelis-Horizon"))
  check("a feed line counts as unread but stays quiet", S.Get("loot").unread == 1 and S.TierOf("loot") == "quiet", S.Get("loot").unread)
  check("a quiet feed line shows no toast", toasted == 0 and lootChange == "quiet", tostring(lootChange))
  S.Unsubscribe(listen)
  T.ShowToast = savedShowToast

  local registered = {}
  E.Enable()  -- makes sure the event frame exists (an earlier section may have made it)
  local fr = E._frame()
  local savedRegister, savedUnregister = fr.RegisterEvent, fr.UnregisterAllEvents
  fr.RegisterEvent = function(_, e) registered[e] = true end
  fr.UnregisterAllEvents = function() registered = {} end
  E.Disable()
  E.Enable()
  check("feed events are registered", registered.CHAT_MSG_LOOT and registered.CHAT_MSG_ACHIEVEMENT and registered.CHAT_MSG_SYSTEM, "missing")
  check("battle.net alerts register with the capability", registered.BN_INLINE_TOAST_ALERT == true, "missing")
  E.Disable()
  HorizonSuite.Platform.caps.bnetWhispers = false
  E.Enable()
  check("no battle.net alerts without the capability", registered.BN_INLINE_TOAST_ALERT == nil and registered.CHAT_MSG_LOOT == true, "registered")
  E.Disable()
  HorizonSuite.Platform.caps.bnetWhispers = true
  fr.RegisterEvent, fr.UnregisterAllEvents = savedRegister, savedUnregister
  S.Reset()
`, 'feeds-events');

// --- Events: robust registration; the probe skips feed lines -----------------------------
run(`
  local S, E = HorizonSuite.Echo.Store, HorizonSuite.Echo.Events
  S.Reset()
  local registered = {}
  E.Enable()
  local fr = E._frame()
  local savedRegister, savedUnregister = fr.RegisterEvent, fr.UnregisterAllEvents
  fr.RegisterEvent = function(_, e)
    if e == "CHAT_MSG_SKILL" then error("unknown event") end
    registered[e] = true
  end
  fr.UnregisterAllEvents = function() registered = {} end
  E.Disable()
  check("an event this client lacks does not stop enabling", pcall(E.Enable), "threw")
  check("and every other event still registers", registered.CHAT_MSG_WHISPER == true and registered.CHAT_MSG_LOOT == true, "missing")
  E.Disable()
  fr.RegisterEvent, fr.UnregisterAllEvents = savedRegister, savedUnregister

  local out = {}
  E.StartProbe(1, function(line) out[#out + 1] = line end)
  E.Dispatch("CHAT_MSG_LOOT", "You receive loot: [Cloak].", "Kaelis-Horizon", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
  E.Dispatch("CHAT_MSG_WHISPER", "hi", "Brisa-Horizon", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
  check("the probe spends its count on conversations, not feeds", #out == 1 and out[1]:find("CHAT_MSG_WHISPER", 1, true) == 1, out[1])
  E.StartProbe(0, nil)
  S.Reset()
`, 'events-robust');

// --- View: feed helpers ------------------------------------------------------------------
run(`
  local S, V = HorizonSuite.Echo.Store, HorizonSuite.Echo.View
  S.Reset()
  check("feeds are feeds", V.IsFeed("loot") and V.IsFeed("progress") and V.IsFeed("system"), "?")
  check("conversations are not feeds", not V.IsFeed("party") and not V.IsFeed("whisper") and not V.IsFeed(nil), "?")

  S.Add({ convKey = "loot", text = "You receive loot: [Cloak].", feed = true, chatType = "LOOT" })
  local spec = V.TileSpec(S.Get("loot"))
  check("a feed tile shows an icon, not a letter", spec.glyph == true and spec.icon == V.FEED_ICONS.loot and spec.letter == "", tostring(spec.icon))
  check("a feed tile carries its short label", spec.label == HorizonSuite.L["ECHO_FEED_SHORT_LOOT"], tostring(spec.label))
  check("a quiet feed shows no badge", spec.badge == nil, spec.badge)
  check("a feed is named by its kind", V.DisplayName(S.Get("loot")) == "ECHO_KIND_LOOT", V.DisplayName(S.Get("loot")))
  check("each feed has its own icon", V.FEED_ICONS.loot ~= V.FEED_ICONS.progress and V.FEED_ICONS.progress ~= V.FEED_ICONS.system, "?")

  local savedInfo = ChatTypeInfo
  ChatTypeInfo = { LOOT = { r = 0, g = 0.67, b = 0 }, SYSTEM = { r = 1, g = 1, b = 0 }, PARTY = { r = 0.67, g = 0.67, b = 1 } }
  local r, g, b = V.LineColor(S.Get("loot"), { chatType = "LOOT" })
  check("a feed line takes its own line type's colour", r == 0 and g == 0.67, r)
  r, g, b = V.LineColor(S.Get("loot"), { chatType = "NOT_A_TYPE" })
  local fr, fg, fb = V.ChatColor("loot")
  check("an unknown line type falls back to the feed's colour", r == fr and g == fg and b == fb, tostring(r) .. "," .. tostring(g) .. "," .. tostring(b))
  r, g, b = V.LineColor({ kind = "party" }, {})
  check("a conversation line uses its conversation's colour", r == 0.67 and b == 1, r)
  ChatTypeInfo = savedInfo

  local savedDate = date
  date = function(fmt, t) return fmt == "%H:%M" and ("12:" .. string.format("%02d", t % 60)) or "?" end
  check("feed time is hours and minutes", V.FeedTime(125) == "12:05", V.FeedTime(125))
  check("no time, no stamp", V.FeedTime(nil) == "", V.FeedTime(nil))
  date = nil
  check("no date function, no stamp", V.FeedTime(125) == "", V.FeedTime(125))
  date = savedDate
  S.Reset()
`, 'view-feeds');

// --- Links: hover and click links in Echo's text -----------------------------------------
run(`
  local Links = HorizonSuite.Echo.Links
  local savedTooltip, savedItemRef = GameTooltip, SetItemRef
  local shown, hidden, ref = nil, false, nil
  GameTooltip = {
    SetOwner = function() end,
    SetHyperlink = function(_, link) if link == "bad:1" then error("no tooltip") end shown = link end,
    Show = function() end,
    Hide = function() hidden = true end,
  }
  SetItemRef = function(link, text, button) ref = { link, text, button } end
  CreateFrame = STUB_CREATE_FRAME
  local f = CreateFrame("Frame")
  f.SetHyperlinksEnabled = function(self, on) self.hyperlinks = on end
  Links.Attach(f)
  check("links are enabled on the frame", f.hyperlinks == true, tostring(f.hyperlinks))
  f.scripts.OnHyperlinkEnter(f, "item:1")
  check("hovering a link shows its tooltip", shown == "item:1", shown)
  f.scripts.OnHyperlinkLeave(f)
  check("leaving hides it", hidden == true, "?")
  check("a link with no tooltip is survived", pcall(f.scripts.OnHyperlinkEnter, f, "bad:1"), "threw")
  f.scripts.OnHyperlinkClick(f, "item:1", "[Cloak]", "LeftButton")
  check("clicking goes through the game's own link handler", ref and ref[1] == "item:1" and ref[2] == "[Cloak]" and ref[3] == "LeftButton", "?")
  ref, shown = nil, nil
  f.scripts.OnHyperlinkEnter(f, SECRET("item:2"))
  f.scripts.OnHyperlinkClick(f, SECRET("item:2"), "[x]", "LeftButton")
  check("a secret link is ignored", shown == nil and ref == nil, "used")
  SetItemRef = nil
  check("no link handler, no error", pcall(f.scripts.OnHyperlinkClick, f, "item:1", "[Cloak]", "LeftButton"), "threw")
  f.SetHyperlinksEnabled = nil
  GameTooltip, SetItemRef = savedTooltip, savedItemRef
`, 'links-live');

// --- Links: clicks reach a real chat frame; failures are reported --------------------------
run(`
  local Links = HorizonSuite.Echo.Links
  local savedTooltip, savedItemRef = GameTooltip, SetItemRef
  local savedDefault, savedSelected, savedHandler = DEFAULT_CHAT_FRAME, SELECTED_CHAT_FRAME, geterrorhandler
  local hidden, ref, reported = false, nil, nil
  GameTooltip = {
    SetOwner = function() end,
    SetHyperlink = function(_, link) if link == "bad:1" then error("no tooltip") end end,
    Show = function() end,
    Hide = function() hidden = true end,
  }
  SetItemRef = function(link, text, button, chatFrame) ref = { link, text, button, chatFrame } end
  CreateFrame = STUB_CREATE_FRAME
  local f = CreateFrame("Frame")
  Links.Attach(f)
  local chat, selected = { editBox = {} }, { editBox = {} }
  DEFAULT_CHAT_FRAME, SELECTED_CHAT_FRAME = chat, selected
  f.scripts.OnHyperlinkClick(f, "player:Brisa", "[Brisa]", "LeftButton")
  check("a link click hands SetItemRef the default chat frame", ref and rawequal(ref[4], chat), ref and tostring(ref[4]))
  DEFAULT_CHAT_FRAME = nil
  f.scripts.OnHyperlinkClick(f, "player:Brisa", "[Brisa]", "LeftButton")
  check("without it, the selected chat frame", ref and rawequal(ref[4], selected), ref and tostring(ref[4]))
  SELECTED_CHAT_FRAME = nil
  f.scripts.OnHyperlinkClick(f, "player:Brisa", "[Brisa]", "LeftButton")
  check("without either, the Echo frame", ref and rawequal(ref[4], f), ref and tostring(ref[4]))

  SetItemRef = function() error("boom") end
  geterrorhandler = function() return function(err) reported = err end end
  check("a failing click does not throw", pcall(f.scripts.OnHyperlinkClick, f, "item:1", "[x]", "LeftButton"), "threw")
  check("a failing click reaches the error handler", type(reported) == "string" and reported:find("boom", 1, true) ~= nil, tostring(reported))
  geterrorhandler = nil
  check("no error handler, still no error", pcall(f.scripts.OnHyperlinkClick, f, "item:1", "[x]", "LeftButton"), "threw")

  hidden = false
  f.scripts.OnHyperlinkEnter(f, "bad:1")
  check("a link with no tooltip hides the tooltip", hidden == true, tostring(hidden))

  DEFAULT_CHAT_FRAME, SELECTED_CHAT_FRAME, geterrorhandler = savedDefault, savedSelected, savedHandler
  GameTooltip, SetItemRef = savedTooltip, savedItemRef
`, 'links-chat-frame');

// --- Icon tiles and read-only feeds in the stack -------------------------------------------
run(`
  local S, T, K, C = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles, HorizonSuite.Echo.Stack, HorizonSuite.Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  C.Enable()
  S.Add({ convKey = "loot", text = "You receive loot: [Cloak].", feed = true, chatType = "LOOT" })
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon", class = "DRUID" })

  local lootTile = T.TileFor("loot")
  check("a feed tile shows its icon", lootTile and lootTile.icon.shown and lootTile.letter.text == "", lootTile and lootTile.letter.text)
  local brisaTile = T.TileFor("w:Brisa-Horizon")
  check("a whisper tile shows its letter, no icon", brisaTile.icon.shown == false and brisaTile.letter.text == "B", brisaTile.letter.text)

  K.Open("loot")
  local f = K._frames()
  check("the stack shows a feed card", f.card.name.text == "ECHO_KIND_LOOT", f.card.name.text)
  check("a feed card has no reply box", f.edit.shown == false, tostring(f.edit.shown))
  check("the feed card's line is shown", f.card.lines[1].text == "You receive loot: [Cloak].", f.card.lines[1].text)
  K.Open("w:Brisa-Horizon")
  check("a conversation card keeps its reply box", f.edit.shown == true, tostring(f.edit.shown))
  check("the stack card's links are live", f.card.scripts.OnHyperlinkClick ~= nil, "not attached")

  K.Open("w:Brisa-Horizon", true)
  check("opening focused focuses the reply box", f.edit.focused == true, tostring(f.edit.focused))
  K.Select("loot")
  check("flipping to a feed card clears the reply box's focus", f.edit.focused == false, tostring(f.edit.focused))
  check("flipping to a feed card hides the reply box", f.edit.shown == false, tostring(f.edit.shown))
  K.Hide()

  C.Open("w:Brisa-Horizon")
  local cf = C._frames()
  local lootRow
  for _, b in ipairs(cf.rowTiles) do if b.convKey == "loot" then lootRow = b end end
  check("the card's row shows the feed's icon", lootRow and lootRow.icon.shown and lootRow.letter.text == "", "?")
  C.Hide()
  C.Disable()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'icons-stack-feeds');

// --- Card: feed lines and live links ---------------------------------------------------------
run(`
  local S, C = HorizonSuite.Echo.Store, HorizonSuite.Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  C.Enable()
  local f = C._frames()
  local savedDate = date
  date = function() return "12:04" end
  S.Add({ convKey = "loot", text = "You receive loot: [Cloak].", feed = true, chatType = "LOOT", time = 100 })
  S.Add({ convKey = "loot", text = SECRET("You receive loot: [Hidden]."), secret = true, feed = true, chatType = "LOOT", time = 101 })
  C.Open("loot")
  check("a feed card is read-only", f.edit.shown == false and f.send.shown == false, tostring(f.edit.shown))
  local newest, older = f.bubbles[1], f.bubbles[2]
  check("the newest feed line is at the bottom", rawequal(newest.text.text, S.Get("loot").messages[2].text), "?")
  check("a feed line carries its time", older.time and older.time.shown and older.time.text == "12:04", older.time and older.time.text)
  check("a feed line spans the card", older.points[1][1] == "BOTTOMLEFT", older.points[1][1])
  check("no status line on a feed", f.status.shown == false, tostring(f.status.shown))
  check("a feed line's links are live", older.scripts.OnHyperlinkClick ~= nil, "not attached")

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon" })
  C.Show("w:Brisa-Horizon")
  check("a conversation card has its reply box", f.edit.shown == true and f.send.shown == true, tostring(f.edit.shown))
  check("a bubble after a feed line hides its time", f.bubbles[1].time == nil or f.bubbles[1].time.shown == false, "shown")
  date = savedDate

  C.Open("w:Brisa-Horizon", true)
  check("the reply box is focused on the conversation card", f.edit.focused == true, tostring(f.edit.focused))
  C.Show("loot")
  check("showing a feed clears the reply box's focus", f.edit.focused == false, tostring(f.edit.focused))
  C.Disable()
  S.Reset()
`, 'card-feeds');

// --- Card/Stack: never focus a hidden reply box, never reply to a feed ---------------------
run(`
  local S, C = HorizonSuite.Echo.Store, HorizonSuite.Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  C.Enable()
  local f = C._frames()
  S.Add({ convKey = "loot", text = "You receive loot: [Cloak].", feed = true, chatType = "LOOT", time = 100 })
  C.Open("loot", true)
  check("opening a feed focused never focuses its hidden reply box", f.edit.focused ~= true, tostring(f.edit.focused))
  C.Disable()
  S.Reset()
`, 'card-focus-guard');

run(`
  local S, K, C = HorizonSuite.Echo.Store, HorizonSuite.Echo.Stack, HorizonSuite.Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  K.Enable()
  C.Enable()
  S.Add({ convKey = "loot", text = "You receive loot: [Cloak].", feed = true, chatType = "LOOT", time = 100 })
  K.ReplyToNewest()
  local kf, cf = K._frames(), C._frames()
  check("reply-to-newest with only a feed open leaves the stack's box unfocused", kf.edit.focused ~= true, tostring(kf.edit.focused))
  check("reply-to-newest with only a feed open leaves the card's box unfocused", cf.edit.focused ~= true, tostring(cf.edit.focused))
  K.Disable()
  C.Disable()
  S.Reset()
`, 'stack-reply-to-newest-feed-guard');

// --- Store: a closed feed stays closed until reload ----------------------------------------
run(`
  local S = HorizonSuite.Echo.Store
  S.Reset()
  local function listed(key)
    for _, c in ipairs(S.List()) do if c.key == key then return true end end
    return false
  end
  local notified
  local function listen(key, change) if key == "loot" then notified = change end end
  S.Subscribe(listen)
  S.Add({ convKey = "loot", text = "You receive loot: [Cloak].", feed = true, chatType = "LOOT" })
  S.Close("loot")
  local before = #S.Get("loot").messages
  notified = nil
  local change = S.Add({ convKey = "loot", text = "You receive loot: [Boots].", feed = true, chatType = "LOOT" })
  check("a closed feed is not reopened by a new line", not listed("loot"), "reopened")
  check("a closed feed still files the line", #S.Get("loot").messages == before + 1, #S.Get("loot").messages)
  check("a closed feed counts no unread", S.Get("loot").unread == 0, S.Get("loot").unread)
  check("a closed feed's line still notifies the views", notified ~= nil, tostring(notified))
  check("a closed feed's line never toasts", change ~= "toast" and change ~= nil, tostring(change))

  S.SetTier("loot", "loud")
  change = S.Add({ convKey = "loot", text = "You receive loot: [Belt].", feed = true, chatType = "LOOT" })
  check("a closed loud feed stays closed and quiet", not listed("loot") and change ~= "toast", tostring(change))

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon" })
  S.Close("w:Brisa-Horizon")
  S.Add({ convKey = "w:Brisa-Horizon", text = "still there?", sender = "Brisa-Horizon" })
  check("a closed whisper still reopens on a new message", listed("w:Brisa-Horizon"), "stayed closed")

  S.SetTier("progress", "muted")
  S.Add({ convKey = "progress", text = "You gain 10 XP.", feed = true, chatType = "COMBAT_XP_GAIN" })
  check("a muted feed keeps its tile", listed("progress"), "no tile")
  S.SetTier("loot", nil)
  S.SetTier("progress", nil)

  S.Reset()
  S.Add({ convKey = "loot", text = "You receive loot: [Cloak].", feed = true, chatType = "LOOT" })
  check("after a reset a new loot line shows the loot tile again", listed("loot"), "still closed")
  S.Unsubscribe(listen)
  S.Reset()
`, 'store-feed-dismissed');

// --- Stack: feed lines carry their time ------------------------------------------------------
run(`
  local S, K = HorizonSuite.Echo.Store, HorizonSuite.Echo.Stack
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  K.Enable()
  local savedDate = date
  date = function() return "12:04" end
  S.Add({ convKey = "loot", text = "You receive loot: [Cloak].", feed = true, chatType = "LOOT", time = 100 })
  S.Add({ convKey = "loot", text = SECRET("You receive loot: [Hidden]."), secret = true, feed = true, chatType = "LOOT", time = 101 })
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon", time = 102 })
  K.Open("loot")
  local card = K._frames().card
  local times = rawget(card, "times")
  check("a stack feed line shows its time", times ~= nil and times[1].shown and times[1].text == "12:04", times and times[1].text)
  if not times then times = { {}, {}, {} } end
  check("the time has its own text, apart from the line", card.lines[1].text ~= "12:04" and not rawequal(times[1], card.lines[1]), "?")
  local secretLine
  for i = 1, 2 do if type(card.lines[i].text) == "table" then secretLine = card.lines[i] end end
  check("a secret feed line stays alone in its text", secretLine ~= nil and rawequal(secretLine.text, S.Get("loot").messages[2].text), "joined")
  local feedX = card.lines[1].points[1] and card.lines[1].points[1][4]
  K.Open("w:Brisa-Horizon")
  check("a conversation card shows no time", times[1].shown == false, tostring(times[1].shown))
  local convX = card.lines[1].points[1] and card.lines[1].points[1][4]
  check("a feed line's text sits right of its time", type(feedX) == "number" and type(convX) == "number" and feedX > convX, tostring(feedX) .. " vs " .. tostring(convX))
  date = savedDate
  K.Hide()
  K.Disable()
  S.Reset()
`, 'stack-feed-times');

// --- Card: a feed's lines use the space the reply box leaves -------------------------------
run(`
  local S, C = HorizonSuite.Echo.Store, HorizonSuite.Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  C.Enable()
  local f = C._frames()
  local function bottomOffset()
    for _, pt in ipairs(f.area.points) do if pt[1] == "BOTTOMRIGHT" then return pt[5] end end
  end
  S.Add({ convKey = "loot", text = "You receive loot: [Cloak].", feed = true, chatType = "LOOT", time = 100 })
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon" })
  C.Open("loot")
  local feedBottom = bottomOffset()
  C.Show("w:Brisa-Horizon")
  local convBottom = bottomOffset()
  check("a feed card's area reaches down to the card's padding", feedBottom == C.PAD, tostring(feedBottom))
  check("a conversation card's area stops above the reply box", convBottom == C.AREA_BOTTOM, tostring(convBottom))
  C.Hide()
  C.Disable()
  S.Reset()
`, 'card-feed-area');

// --- Feeds never reach history or the saved open list; a loud feed toasts with its icon -----
run(`
  local Echo = HorizonSuite.Echo
  local S, H, T, K, C, V = Echo.Store, Echo.History, Echo.Tiles, Echo.Stack, Echo.Card, Echo.View
  S.Reset()
  local db = {}
  H.Bind(db, function() return "Kaelis-Horizon" end)
  S.Add({ convKey = "loot", text = "You receive loot: [Cloak].", feed = true, chatType = "LOOT", time = 100 })
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon", time = 101 })
  local function inHistory(key)
    for _, bucket in pairs(db.echoHistory.chars or {}) do
      if type(bucket) == "table" then
        for k, v in pairs(bucket) do
          if k == key then return true end
          if type(v) == "table" and v[key] ~= nil then return true end
        end
      end
    end
    return false
  end
  check("a feed line never reaches history", not inHistory("loot"), "written")
  check("while a whisper does (the probe above can see history)", inHistory("w:Brisa-Horizon"), "not written")
  local keys = S.OpenKeys()
  local hasLoot, hasBrisa = false, false
  for _, k in ipairs(keys) do
    if k == "loot" then hasLoot = true end
    if k == "w:Brisa-Horizon" then hasBrisa = true end
  end
  check("feeds are never saved as open", not hasLoot and hasBrisa, table.concat(keys, ","))
  H.Unbind()
  S.Reset()

  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  if K._frames() then K.Hide() end
  if C._frames() then C.Hide() end
  local savedHolding = T.holding
  T.holding = false
  S.SetTier("loot", "loud")
  local toast = T._toast()
  -- entry.icon is the face's background layer now; the icon texture itself paints onto
  -- entry.face, the overlay added over it (Task 2, "one painter for every tile").
  local icon = toast and toast.entry.face
  local texture
  if icon then icon.SetTexture = function(_, tex) texture = tex end end
  S.Add({ convKey = "loot", text = "You receive loot: [Cloak].", feed = true, chatType = "LOOT", time = 102 })
  toast = T._toast()
  check("a loud feed toasts", toast and toast.shown and toast.convKey == "loot", toast and toast.convKey)
  check("a loud feed's toast shows its icon", texture == V.FEED_ICONS.loot, tostring(texture))
  if icon then icon.SetTexture = nil end
  if toast then toast:Hide() end
  S.SetTier("loot", nil)
  T.holding = savedHolding
  T.Disable()
  S.Reset()
`, 'feeds-history-toast');

// --- Defaults, keys and limits -------------------------------------------------
run(read('options/modules/defaults/OptionsDefaultsEcho.lua'), 'echo-defaults');
run(`
  local A = HorizonSuite
  local S = A.Echo.Store
  for kind, tier in pairs(S.DEFAULT_TIERS) do
    local key = A.Echo.TierKey(kind)
    check("tier default for " .. kind, A.ECHO_DEFAULTS[key] == tier, tostring(A.ECHO_DEFAULTS[key]))
  end
  for key in pairs(A.ECHO_DEFAULTS) do
    check("routed key " .. key, A.ECHO_KEYS[key] == true, key)
  end
  check("position keys routed", A.ECHO_KEYS.echoX and A.ECHO_KEYS.echoY, "echoX/echoY")
  check("at least two tiles", A.ECHO_LIMITS.echoMaxTiles.min == 2, A.ECHO_LIMITS.echoMaxTiles.min)
  check("tier key", A.Echo.TierKey("bnet") == "echoTierBnet", A.Echo.TierKey("bnet"))
  check("feed key", A.Echo.FeedKey("loot") == "echoFeedLoot", A.Echo.FeedKey("loot"))
  check("history days default is 30", A.ECHO_DEFAULTS.echoHistoryDays == 30, A.ECHO_DEFAULTS.echoHistoryDays)
  check("guild saving defaults on", A.ECHO_DEFAULTS.echoSaveGuild == true, tostring(A.ECHO_DEFAULTS.echoSaveGuild))
  check("officer saving defaults off", A.ECHO_DEFAULTS.echoSaveOfficer == false, tostring(A.ECHO_DEFAULTS.echoSaveOfficer))
  -- Later sections run without defaults, as before this plan.
  A.ECHO_DEFAULTS, A.ECHO_KEYS, A.ECHO_LIMITS = nil, nil, nil
`, 'echo-defaults-check');

// --- Settings applied to the Store, Events and History ----------------------------
run(`
  local Echo = HorizonSuite.Echo
  local S, E = Echo.Store, Echo.Events
  S.Reset()
  local db = {}
  HorizonSuite.GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end

  check("kind tier defaults", S.KindTier("guild") == "quiet", S.KindTier("guild"))
  db.echoTierGuild = "loud"
  Echo.ApplyOptions()
  check("guild follows its setting", S.KindTier("guild") == "loud", S.KindTier("guild"))
  check("a guild conversation rings loud", S.TierOf("guild") == "loud", S.TierOf("guild"))
  S.SetTier("guild", "muted")
  check("a conversation's own tier still wins", S.TierOf("guild") == "muted", S.TierOf("guild"))
  S.SetTier("guild", nil)
  db.echoTierGuild = "bogus"
  Echo.ApplyOptions()
  check("an unknown tier falls back to the default", S.KindTier("guild") == "quiet", S.KindTier("guild"))
  check("SetKindTier refuses junk", S.SetKindTier("guild", "loudest") == false, "accepted")
  -- The harness L returns keys; give the two strings the label is built from real text.
  local Lt = HorizonSuite.L
  rawset(Lt, "ECHO_TIER_DEFAULT", "Default (%s)"); rawset(Lt, "ECHO_TIER_COUNT", "Count")
  db.echoTierGuild = "count"
  Echo.ApplyOptions()
  local label
  for _, e in ipairs(Echo.View.MenuSpec({ key = "guild", kind = "guild", pinned = false })) do
    if e.value == "default" then label = e.label end
  end
  check("the menu's default label follows the setting", label == "Default (Count)", label)
  rawset(Lt, "ECHO_TIER_DEFAULT", nil); rawset(Lt, "ECHO_TIER_COUNT", nil)

  db.echoKeywords = " heal , ,Tank,  "
  Echo.ApplyOptions()
  check("keywords parsed", #E.keywords == 2 and E.keywords[1] == "heal" and E.keywords[2] == "Tank", #E.keywords)
  check("keyword mention", E.IsMention("need a TANK for keys") == true, "no mention")
  check("your name still counts", E.IsMention("kaelis you there") == true, "no mention")
  db.echoKeywords = ""
  Echo.ApplyOptions()
  check("no keywords", #E.keywords == 0, #E.keywords)

  -- A switched-off feed files nothing and closes its tile.
  E.Dispatch("CHAT_MSG_LOOT", "You receive loot: [Linen Cloth].", "Kaelis-Horizon", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
  check("loot feed on", S.Get("loot") ~= nil and S.Get("loot").open, "no loot feed")
  db.echoFeedLoot = false
  Echo.ApplyOptions()
  check("switching the feed off closes it", not S.Get("loot").open, "still open")
  local before = #S.Get("loot").messages
  E.Dispatch("CHAT_MSG_LOOT", "You receive loot: [Wool Cloth].", "Kaelis-Horizon", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
  check("a switched-off feed files nothing", #S.Get("loot").messages == before, #S.Get("loot").messages)
  check("FeedEnabled", Echo.FeedEnabled("loot") == false and Echo.FeedEnabled("system") == true, "wrong")
  check("a conversation kind is never a switched-off feed", Echo.FeedEnabled("whisper") == true, "off")
  db.echoFeedLoot = nil
  Echo.ApplyOptions()
  E.Dispatch("CHAT_MSG_LOOT", "You receive loot: [Bolt of Wool Cloth].", "Kaelis-Horizon", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
  check("turning the feed back on reopens it on the next line", S.Get("loot").open == true, S.Get("loot") and S.Get("loot").open)

  -- Dismissed by hand while the setting stays on: the dismissal survives ApplyOptions.
  S.Close("loot")
  check("closed by hand", S.Get("loot").open == false, S.Get("loot").open)
  Echo.ApplyOptions()
  E.Dispatch("CHAT_MSG_LOOT", "You receive loot: [Simple Flour].", "Kaelis-Horizon", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
  check("a hand-closed feed stays closed with the setting unchanged", S.Get("loot").open == false, S.Get("loot").open)

  -- A system line still fails a pending whisper with the System feed off.
  db.echoFeedSystem = false
  Echo.ApplyOptions()
  S.AddPending("w:Ghost-Horizon", "hi")
  E.Dispatch("CHAT_MSG_SYSTEM", "No player named 'Ghost' is currently playing.")
  local ghost = S.Get("w:Ghost-Horizon")
  check("failed whisper with the feed off", ghost.messages[#ghost.messages].status == "failed", ghost.messages[#ghost.messages].status)
  check("no system feed", S.Get("system") == nil or not S.Get("system").open, "system feed open")
  db.echoFeedSystem = nil

  -- The history switch.
  local H = Echo.History
  local saved = {}
  H.Bind(saved, function() return "Kaelis-Horizon" end)
  db.echoSaveHistory = false
  Echo.ApplyOptions()
  check("history off writes nothing", H.Append("w:Brisa-Horizon", { time = 1, text = "hi" }) == false, "wrote")
  db.echoSaveHistory = nil
  Echo.ApplyOptions()
  check("history on writes", H.Append("w:Brisa-Horizon", { time = 1, text = "hi" }) == true, "did not write")

  -- The "Keep history for" setting reaches History.Prune's cutoff.
  db.echoHistoryDays = 7
  Echo.ApplyOptions()
  H.Append("w:OldOne-Horizon", { time = 1, text = "old" })
  -- w:Brisa-Horizon (appended above, at time 1) is stale by the same cutoff and is removed too.
  local removedShort = H.Prune(1 + 10 * 86400)
  check("ApplyOptions pushes echoHistoryDays into Prune's cutoff", removedShort == 2, removedShort)
  db.echoHistoryDays = nil

  -- echoSaveGuild / echoSaveOfficer reach Store.IsPersisted.
  db.echoSaveGuild = false
  Echo.ApplyOptions()
  check("ApplyOptions pushes echoSaveGuild off", S.IsPersisted("guild") == false, "on")
  db.echoSaveGuild = true
  Echo.ApplyOptions()
  check("ApplyOptions pushes echoSaveGuild on", S.IsPersisted("guild") == true, "off")
  db.echoSaveOfficer = true
  Echo.ApplyOptions()
  check("ApplyOptions pushes echoSaveOfficer on", S.IsPersisted("officer") == true, "off")
  db.echoSaveOfficer = false
  Echo.ApplyOptions()
  check("ApplyOptions pushes echoSaveOfficer off", S.IsPersisted("officer") == false, "on")
  db.echoSaveGuild, db.echoSaveOfficer = nil, nil
  S.SetPersisted("guild", false)
  S.SetPersisted("officer", false)
  H.Unbind()

  -- Clear falls back to the raw SavedVariables table when History is unbound (Echo disabled).
  HorizonSuite.DATABASE = "HorizonDB_Test"
  _G[HorizonSuite.DATABASE] = { echoHistory = { chars = { x = {} }, prefs = { p = 1 } } }
  Echo.History.Clear()
  local cleared = _G[HorizonSuite.DATABASE].echoHistory
  check("clear with History unbound empties chars", next(cleared.chars) == nil, cleared.chars)
  check("clear with History unbound keeps prefs", cleared.prefs.p == 1, cleared.prefs.p)
  _G[HorizonSuite.DATABASE] = nil
  HorizonSuite.DATABASE = nil

  HorizonSuite.GetDB = nil
  Echo.ApplyOptions()
  S.Reset()
`, 'echo-apply-options');

// --- Edge, scale, card size and font ---------------------------------------------
run(`
  CreateFrame = STUB_CREATE_FRAME
  local Echo = HorizonSuite.Echo
  local V = Echo.View
  local r, l = V.PanelSides("right"), V.PanelSides("left")
  check("right edge opens left", r.panel == "BOTTOMRIGHT" and r.rel == "BOTTOMLEFT" and r.dx == -8 and r.toast == "RIGHT" and r.toastDir == -1, r.panel)
  check("left edge opens right", l.panel == "BOTTOMLEFT" and l.rel == "BOTTOMRIGHT" and l.dx == 8 and l.toast == "LEFT" and l.toastDir == 1, l.panel)
  check("junk edge is right", V.PanelSides("top").panel == "BOTTOMRIGHT", V.PanelSides("top").panel)

  local db = {}
  HorizonSuite.GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  HorizonSuite.SetDB = function(k, v) db[k] = v end
  Echo.Store.Reset()
  Echo.Tiles.Enable()
  local column = _G.HorizonSuiteEchoColumn
  local scale = 1
  column.SetScale = function(self, s) scale = s end
  column.GetScale = function() return scale end
  local strata = "MEDIUM"
  column.SetFrameStrata = function(self, s) strata = s end

  -- Auto follows the column's actual half of the screen; explicit left/right override it.
  UIParent.GetWidth = function() return 1000 end
  local savedColumn = _G.HorizonSuiteEchoColumn
  _G.HorizonSuiteEchoColumn = nil
  db.echoColumnEdge = "auto"
  check("auto with no column is right", V.Edge() == "right", V.Edge())
  _G.HorizonSuiteEchoColumn = savedColumn

  column.GetCenter = function() return 200 end
  check("auto on the left half opens panels right", V.PanelSides(V.Edge()).panel == "BOTTOMLEFT", V.Edge())
  column.GetCenter = function() return 800 end
  check("auto on the right half opens panels left", V.PanelSides(V.Edge()).panel == "BOTTOMRIGHT", V.Edge())

  db.echoColumnEdge = "left"
  check("explicit left wins over the column's position", V.Edge() == "left", V.Edge())
  db.echoColumnEdge = "right"
  check("explicit right wins over the column's position", V.Edge() == "right", V.Edge())
  column.GetCenter, UIParent.GetWidth = nil, nil

  -- Default corner follows the edge.
  db.echoColumnEdge = "left"
  Echo.ApplyOptions()
  local p = column.points[#column.points]
  check("left edge default corner", p[1] == "BOTTOMLEFT" and p[3] == "BOTTOMLEFT" and p[4] > 0, p[1] .. " " .. tostring(p[4]))

  -- An undragged Auto column always sits bottom right: the no-saved-position branch reads
  -- the raw setting, not View.Edge() (which would follow the column's simulated position
  -- on the left half here and say "left").
  db.echoColumnEdge = "auto"
  UIParent.GetWidth = function() return 1000 end
  column.GetCenter = function() return 200 end
  check("auto still reports left from the column's position", V.Edge() == "left", V.Edge())
  Echo.ApplyOptions()
  p = column.points[#column.points]
  check("an undragged Auto column sits bottom right", p[1] == "BOTTOMRIGHT" and p[3] == "BOTTOMRIGHT", p[1])
  column.GetCenter, UIParent.GetWidth = nil, nil
  db.echoColumnEdge = "left"

  -- A dragged position is kept in screen units across a scale change. Scale 1.5, not the
  -- old 2, now that ApplyPosition clamps to 0.6-1.6 without a settings ECHO_LIMITS table
  -- (Minor 5): 2 would itself be clamped down to 1.6 and break the "halves" arithmetic.
  db.echoX, db.echoY = 750, 300
  db.echoScale = 1.5
  Echo.ApplyOptions()
  p = column.points[#column.points]
  check("scale 1.5 divides the offsets", p[1] == "BOTTOM" and p[4] == 500 and p[5] == 200, tostring(p[4]) .. "," .. tostring(p[5]))
  column.GetCenter = function() return 500 end
  column.GetBottom = function() return 200 end
  Echo.Tiles._savePosition()
  check("saving multiplies by the scale", db.echoX == 750 and db.echoY == 300, tostring(db.echoX) .. "," .. tostring(db.echoY))
  column.GetCenter, column.GetBottom = nil, nil

  -- Scale and strata are validated: junk falls back to a safe default (Minor 5).
  db.echoScale = 0
  Echo.ApplyOptions()
  check("a zero scale falls back to 1", scale == 1, scale)
  db.echoScale = 99
  Echo.ApplyOptions()
  check("an out-of-range scale clamps to the max", scale == 1.6, scale)
  db.echoScale = "bogus"
  Echo.ApplyOptions()
  check("a non-number scale falls back to 1", scale == 1, scale)
  db.echoScale = 1.5
  db.echoFrameStrata = "BOGUS"
  Echo.ApplyOptions()
  check("an unknown strata falls back to MEDIUM", strata == "MEDIUM", strata)
  db.echoFrameStrata = nil

  -- The stack and card open on the edge's side.
  Echo.Stack.Enable(); Echo.Card.Enable()
  Echo.Store.Add({ convKey = "w:Brisa-Horizon", sender = "Brisa-Horizon", text = "hi" })
  Echo.Card.Open("w:Brisa-Horizon")
  local card = Echo.Card._frames().root
  p = card.points[#card.points]
  check("card opens right of a left column", p[1] == "BOTTOMLEFT" and p[3] == "BOTTOMRIGHT" and p[4] == 8, p[1])
  Echo.Card.Hide()
  Echo.Stack.Open("w:Brisa-Horizon")
  local stack = Echo.Stack._frames().root
  p = stack.points[#stack.points]
  check("stack opens right of a left column", p[1] == "BOTTOMLEFT" and p[3] == "BOTTOMRIGHT", p[1])
  Echo.Stack.Hide()

  -- OnDragStop calls Echo.ApplyOptions, so an Auto column re-anchors an open stack to its
  -- new side once the drag ends, not just the column itself.
  db.echoColumnEdge = "auto"
  UIParent.GetWidth = function() return 1000 end
  column.GetCenter = function() return 200 end
  column.GetBottom = function() return 50 end
  Echo.Stack.Open("w:Brisa-Horizon")
  stack = Echo.Stack._frames().root
  p = stack.points[#stack.points]
  check("auto stack opens right before the drag", p[1] == "BOTTOMLEFT" and p[3] == "BOTTOMRIGHT", p[1])
  local stackButton = Echo.Tiles._stackButton()
  column.moving = true
  column.GetCenter = function() return 800 end
  stackButton.scripts.OnDragStop(stackButton)
  p = stack.points[#stack.points]
  check("drag stop re-anchors the stack to the new auto side", p[1] == "BOTTOMRIGHT" and p[3] == "BOTTOMLEFT", p[1])
  Echo.Stack.Hide()
  column.GetCenter, column.GetBottom, UIParent.GetWidth = nil, nil, nil
  db.echoColumnEdge = "left"

  -- Card size. ECHO_LIMITS was cleared after the defaults section; the clamp needs it.
  HorizonSuite.ECHO_LIMITS = { echoCardWidth = { min = 320, max = 520 }, echoCardHeight = { min = 320, max = 640 } }
  db.echoCardWidth, db.echoCardHeight = 480, 600
  Echo.ApplyOptions()
  check("card width from settings", card.width == 480 and card.height == 600, tostring(card.width) .. "x" .. tostring(card.height))
  check("bubble width follows the card", Echo.Card.BUBBLE_MAX == 370, Echo.Card.BUBBLE_MAX)
  check("message area follows the card", Echo.Card.AREA_HEIGHT == 600 - Echo.Card.AREA_TOP - Echo.Card.AREA_BOTTOM, Echo.Card.AREA_HEIGHT)
  db.echoCardWidth = 9999
  Echo.ApplyOptions()
  check("card width clamped", card.width == 520, card.width)

  -- Font: tracked strings are re-fonted.
  local set = {}
  local fs = { SetFont = function(self, path, size, flags) set[#set + 1] = { path, size, flags } end }
  Echo.TrackFont(fs, 12, "")
  db.echoFontPath = "Fonts\\\\ARIALN.TTF"
  Echo.ApplyOptions()
  local last = set[#set]
  check("font re-applied", last and last[1] == "Fonts\\\\ARIALN.TTF" and last[2] == 12 and last[3] == "", last and last[1])
  local countBefore = #set
  Echo.ApplyOptions()
  check("re-applying the same font path is a no-op", #set == countBefore, #set)
  db.echoFontPath = "__global__"
  check("global font", Echo.FontPath() ~= "__global__", Echo.FontPath())

  HorizonSuite.GetDB, HorizonSuite.SetDB, HorizonSuite.ECHO_LIMITS = nil, nil, nil
  Echo.ApplyOptions()
  Echo.Card.Disable(); Echo.Stack.Disable(); Echo.Tiles.Disable()
  column.SetScale, column.GetScale = nil, nil
  Echo.Store.Reset()
`, 'echo-layout-options');

// --- Blizzard whisper filter ----------------------------------------------------
run(`
  local Echo = HorizonSuite.Echo
  local F = Echo.Filter
  local added, removed = {}, {}
  ChatFrame_AddMessageEventFilter = function(event, fn) added[event] = fn end
  ChatFrame_RemoveMessageEventFilter = function(event, fn) if added[event] == fn then added[event] = nil end removed[event] = true end
  local lastTell
  ChatEdit_SetLastTellTarget = function(name, chatType) lastTell = { name, chatType } end

  F.Apply(true)
  check("filter on registers whispers", added.CHAT_MSG_WHISPER == F.Handler and added.CHAT_MSG_WHISPER_INFORM == F.Handler, "missing")
  check("filter on registers Battle.net whispers", added.CHAT_MSG_BN_WHISPER == F.Handler, "missing")
  check("filter active", F.active == true, F.active)
  F.Apply(true)
  check("applying twice is harmless", added.CHAT_MSG_WHISPER == F.Handler, "lost")

  local hide = F.Handler(nil, "CHAT_MSG_WHISPER", "hi", "Brisa-Horizon", "", "", "", "", 0, 0, "", 0, 1, "Player-1-DRUID")
  check("a filed whisper is hidden", hide == true, hide)
  check("the reply target follows a hidden whisper", lastTell and lastTell[1] == "Brisa-Horizon" and lastTell[2] == "WHISPER", lastTell and lastTell[1])

  lastTell = nil
  local keep = F.Handler(nil, "CHAT_MSG_WHISPER", SECRET("hi"), "Brisa-Horizon", "", "", "", "", 0, 0, "", 0, 1, "Player-1-DRUID")
  check("a secret whisper stays in Blizzard chat", keep == false, keep)
  check("no reply target from a kept whisper", lastTell == nil, lastTell and lastTell[1])

  keep = F.Handler(nil, "CHAT_MSG_WHISPER", "hi", SECRET("Brisa-Horizon"), "", "", "", "", 0, 0, "", 0, 1, "Player-1-DRUID")
  check("a secret sender stays in Blizzard chat", keep == false, keep)

  HorizonSuite.Platform.caps.bnetWhispers = false
  F.Apply(false); F.Apply(true)
  check("no Battle.net filter without Battle.net whispers", added.CHAT_MSG_BN_WHISPER == nil, "registered")
  HorizonSuite.Platform.caps.bnetWhispers = true

  F.Apply(false)
  check("filter off removes whispers", added.CHAT_MSG_WHISPER == nil and added.CHAT_MSG_WHISPER_INFORM == nil, "still there")
  check("filter inactive", F.active == false, F.active)

  -- ApplyOptions drives it.
  local db = { echoHideStoredWhispers = true }
  HorizonSuite.GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  CreateFrame = STUB_CREATE_FRAME
  Echo.ApplyOptions()
  check("setting on applies the filter", F.active == true, F.active)
  db.echoHideStoredWhispers = false
  Echo.ApplyOptions()
  check("setting off removes the filter", F.active == false, F.active)

  local realApply, applyCalls = F.Apply, 0
  F.Apply = function(...) applyCalls = applyCalls + 1; return realApply(...) end
  Echo.ApplyOptions()
  check("re-applying with the same filter setting is a no-op", applyCalls == 0, applyCalls)
  db.echoHideStoredWhispers = true
  Echo.ApplyOptions()
  check("a real filter change still applies", applyCalls == 1 and F.active == true, applyCalls)
  F.Apply = realApply
  db.echoHideStoredWhispers = false
  Echo.ApplyOptions()

  HorizonSuite.GetDB = nil
  ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilter, ChatEdit_SetLastTellTarget = nil, nil, nil
`, 'echo-filter');

// --- A hidden whisper still plays the sound and flashes the taskbar icon --------------------
run(`
  local Echo = HorizonSuite.Echo
  local F = Echo.Filter
  ChatEdit_SetLastTellTarget = function() end
  local soundCalls, flashCalls = 0, 0
  PlaySound = function(id) if id == 3081 then soundCalls = soundCalls + 1 end end
  SOUNDKIT = { TELL_MESSAGE = 3081 }
  FlashClientIcon = function() flashCalls = flashCalls + 1 end
  local now = 100
  GetTime = function() return now end

  F.Handler(nil, "CHAT_MSG_WHISPER", "hi", "Brisa-Horizon", "", "", "", "", 0, 0, "", 0, 1, "Player-1-DRUID")
  F.Handler(nil, "CHAT_MSG_WHISPER", "hi again", "Brisa-Horizon", "", "", "", "", 0, 0, "", 0, 1, "Player-1-DRUID")
  check("two hides at the same time play one sound", soundCalls == 1, soundCalls)
  check("two hides at the same time flash once", flashCalls == 1, flashCalls)

  now = 102
  F.Handler(nil, "CHAT_MSG_WHISPER", "later", "Brisa-Horizon", "", "", "", "", 0, 0, "", 0, 1, "Player-1-DRUID")
  check("a later time plays the sound again", soundCalls == 2, soundCalls)
  check("a later time flashes again", flashCalls == 2, flashCalls)

  local keep = F.Handler(nil, "CHAT_MSG_WHISPER", SECRET("hi"), "Brisa-Horizon", "", "", "", "", 0, 0, "", 0, 1, "Player-1-DRUID")
  check("a kept secret whisper is not hidden", keep == false, keep)
  check("a kept whisper plays no sound", soundCalls == 2, soundCalls)
  check("a kept whisper flashes nothing", flashCalls == 2, flashCalls)

  F.Handler(nil, "CHAT_MSG_WHISPER_INFORM", "hi", "Brisa-Horizon", "", "", "", "", 0, 0, "", 0, 1, "Player-1-DRUID")
  check("a hidden inform plays no sound", soundCalls == 2, soundCalls)
  check("a hidden inform flashes nothing", flashCalls == 2, flashCalls)

  PlaySound, SOUNDKIT, FlashClientIcon, GetTime, ChatEdit_SetLastTellTarget = nil, nil, nil, nil, nil
`, 'echo-filter-alert');

// --- Never hide during chat messaging lockdown --------------------------------------------
run(`
  local Echo = HorizonSuite.Echo
  local F = Echo.Filter
  local lastTell
  ChatEdit_SetLastTellTarget = function(name, chatType) lastTell = { name, chatType } end
  local soundCalls = 0
  PlaySound = function() soundCalls = soundCalls + 1 end
  SOUNDKIT = { TELL_MESSAGE = 3081 }

  C_ChatInfo = { InChatMessagingLockdown = function() return true end }
  local keep = F.Handler(nil, "CHAT_MSG_WHISPER", "hi", "Brisa-Horizon", "", "", "", "", 0, 0, "", 0, 1, "Player-1-DRUID")
  check("lockdown keeps a readable whisper", keep == false, keep)
  check("no reply target during lockdown", lastTell == nil, lastTell)
  check("no sound during lockdown", soundCalls == 0, soundCalls)

  -- A secret or failed lockdown result fails safe (counts as lockdown).
  C_ChatInfo = { InChatMessagingLockdown = function() return SECRET(true) end }
  keep = F.Handler(nil, "CHAT_MSG_WHISPER", "hi", "Brisa-Horizon", "", "", "", "", 0, 0, "", 0, 1, "Player-1-DRUID")
  check("a secret lockdown result fails safe", keep == false, keep)

  C_ChatInfo = { InChatMessagingLockdown = function() error("boom") end }
  keep = F.Handler(nil, "CHAT_MSG_WHISPER", "hi", "Brisa-Horizon", "", "", "", "", 0, 0, "", 0, 1, "Player-1-DRUID")
  check("a failed lockdown check fails safe", keep == false, keep)

  C_ChatInfo = { InChatMessagingLockdown = function() return false end }
  keep = F.Handler(nil, "CHAT_MSG_WHISPER", "hi", "Brisa-Horizon", "", "", "", "", 0, 0, "", 0, 1, "Player-1-DRUID")
  check("no lockdown hides as usual", keep == true, keep)

  C_ChatInfo = nil
  PlaySound, SOUNDKIT, ChatEdit_SetLastTellTarget = nil, nil, nil
`, 'echo-filter-lockdown');

// --- OptionsData: the global-font override pushes Echo's font too -------------------------
run(`
  local A = HorizonSuite
  A.DATABASE = "HorizonDB_TestOD"
  local db = {}
  A.GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  A.SetDB = function(k, v) db[k] = v end
  A.TYPOGRAPHY_KEYS, A.COLOR_LIVE_KEYS, A.SCALE_DEBOUNCE_KEYS, A.CLASS_COLOR_KEYS = {}, {}, {}, {}
  A.IsModuleEnabled = function(self, name) return A._echoEnabledForTest == true end
`, 'optionsdata-stubs');
run(read('options/OptionsData.lua'), 'options/OptionsData.lua');
run(`
  local A = HorizonSuite
  local realApplyFont = A.Echo.ApplyFont
  local calls = 0
  A.Echo.ApplyFont = function() calls = calls + 1 end

  A._echoEnabledForTest = true
  OptionsData_SetDB("useGlobalFont", true)
  check("the global font toggle re-fonts Echo when Echo is enabled", calls == 1, calls)

  A._echoEnabledForTest = false
  OptionsData_SetDB("useGlobalFont", true)
  check("no Echo re-font while Echo is disabled", calls == 1, calls)

  A._echoEnabledForTest = true
  OptionsData_SetDB("focusShowWorldQuests", true)
  check("an unrelated key does not re-font Echo", calls == 1, calls)

  A.Echo.ApplyFont = realApplyFont
  A.TYPOGRAPHY_KEYS, A.COLOR_LIVE_KEYS, A.SCALE_DEBOUNCE_KEYS, A.CLASS_COLOR_KEYS = nil, nil, nil, nil
  A.IsModuleEnabled, A._echoEnabledForTest = nil, nil
  A.OptionCategories, A.OptionsData_GetDB, A.OptionsData_SetDB = nil, nil, nil
  A.OptionsData_GetFontList, A.OptionsData_NotifyMainAddon, A.OptionsData_NotifyMainAddon_Live = nil, nil, nil
  _G[A.DATABASE] = nil
  A.GetDB, A.SetDB, A.DATABASE = nil, nil, nil
`, 'optionsdata-font');

// --- Options page builds -----------------------------------------------------
run(read('options/modules/defaults/OptionsDefaultsEcho.lua'), 'echo-defaults-2');
run(`
  local A = HorizonSuite
  A.OptionCategories = {}
  local db = {}
  A.OptionsData_GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  A.OptionsData_SetDB = function(k, v) db[k] = v end
  local function merge(t, o) if o then for k, v in pairs(o) do t[k] = v end end return t end
  A.Section = function(n) return { type = "section", name = n } end
  A.Button = function(n, d, f, o) return merge({ type = "button", name = n, desc = d, onClick = f }, o) end
  A.Toggle = function(n, d, key, def, o) return merge({ type = "toggle", name = n, desc = d, dbKey = key,
    get = function() return A.OptionsData_GetDB(key, def) end, set = function(v) A.OptionsData_SetDB(key, v) end }, o) end
  A.GetPerElementFontDropdownOptions = function() return { { "Global", "__global__" } } end
`, 'echo-options-stubs');
run(read('options/modules/OptionsEcho.lua'), 'options/modules/OptionsEcho.lua');
run(`
  local A = HorizonSuite
  local cat = A.OptionCategories[1]
  check("one Echo category", #A.OptionCategories == 1 and cat.moduleKey == "echo", #A.OptionCategories)
  local keys = {}
  for _, opt in ipairs(cat.options) do if opt.dbKey then keys[opt.dbKey] = opt end end
  for key in pairs(A.ECHO_DEFAULTS) do
    if key ~= "echoHoverDelay" then check("on the page: " .. key, keys[key] ~= nil, key) end
  end
  keys.echoScale.set(250)
  check("scale slider clamps", A.OptionsData_GetDB("echoScale") == 1.6, A.OptionsData_GetDB("echoScale"))
  keys.echoScale.set(85)
  check("scale slider stores a fraction", A.OptionsData_GetDB("echoScale") == 0.85, A.OptionsData_GetDB("echoScale"))
  check("scale slider reads percent", keys.echoScale.get() == 85, keys.echoScale.get())
  keys.echoMaxTiles.set(1)
  check("max tiles at least two", A.OptionsData_GetDB("echoMaxTiles") == 2, A.OptionsData_GetDB("echoMaxTiles"))
  check("guild tier default", keys.echoTierGuild.get() == "quiet", keys.echoTierGuild.get())
  A.OptionsData_SetDB("echoFeedLoot", false)
  check("loot tier hidden with its feed off", keys.echoTierLoot.visibleWhen() == false, "shown")
  check("keyword box tooltip, not desc", keys.echoKeywords.tooltip == A.L["ECHO_KEYWORDS_DESC"], keys.echoKeywords.tooltip)

  local edgeValues = {}
  for _, o in ipairs(keys.echoColumnEdge.options) do edgeValues[#edgeValues + 1] = o[2] end
  check("edge dropdown lists auto, right and left", edgeValues[1] == "auto" and edgeValues[2] == "right"
      and edgeValues[3] == "left", table.concat(edgeValues, ","))

  local historyDaysValues = {}
  for _, o in ipairs(keys.echoHistoryDays.options) do historyDaysValues[#historyDaysValues + 1] = o[2] end
  check("history days dropdown lists 7, 30, 90 and Forever", table.concat(historyDaysValues, ",") == "7,30,90,0",
      table.concat(historyDaysValues, ","))
  check("guild history toggle hides with saving off", keys.echoSaveGuild.visibleWhen ~= nil, "no visibleWhen")
  A.OptionsData_SetDB("echoSaveHistory", false)
  check("guild toggle hidden with history off", keys.echoSaveGuild.visibleWhen() == false, "shown")
  check("officer toggle hidden with history off", keys.echoSaveOfficer.visibleWhen() == false, "shown")
  A.OptionsData_SetDB("echoSaveHistory", nil)

  A.OptionsData_SetDB("echoX", 800)
  A.OptionsData_SetDB("echoY", 300)
  keys.echoColumnEdge.set("left")
  check("the edge setter clears the dragged position", A.OptionsData_GetDB("echoX") == nil and A.OptionsData_GetDB("echoY") == nil, tostring(A.OptionsData_GetDB("echoX")))

  A.OptionsData_SetDB("echoX", 800)
  A.OptionsData_SetDB("echoY", 300)
  keys.echoColumnEdge.set("auto")
  check("switching to auto keeps the dragged position", A.OptionsData_GetDB("echoX") == 800 and A.OptionsData_GetDB("echoY") == 300, tostring(A.OptionsData_GetDB("echoX")))
  check("switching to auto stores auto", A.OptionsData_GetDB("echoColumnEdge") == "auto", A.OptionsData_GetDB("echoColumnEdge"))

  -- Groups section (Task 4).
  -- L is a stub here (returns the key), so the four group-name editboxes all share one
  -- "name", as do a group dropdown and its Tiers-section namesake (e.g. "Party"). Collect
  -- every match in list order and pick by position instead of relying on the text.
  local function findOpt(typ, name, nth)
    local list = {}
    for _, opt in ipairs(cat.options) do
      if opt.type == typ and opt.name == name then list[#list + 1] = opt end
    end
    return list[nth or #list]
  end

  local lootOpt = findOpt("dropdown", A.L["ECHO_KIND_LOOT"])
  check("loot group dropdown exists", lootOpt ~= nil, "?")
  check("loot starts at None", lootOpt.get() == "none", tostring(lootOpt.get()))

  local defaultOpts = lootOpt.options()
  local defaultLabels = {}
  for _, o in ipairs(defaultOpts) do defaultLabels[#defaultLabels + 1] = o[1] end
  check("dropdown lists None then the one named default group",
    #defaultLabels == 2 and defaultLabels[1] == A.L["ECHO_GROUP_NONE"] and defaultLabels[2] == A.L["ECHO_GROUP_CHANNELS"],
    table.concat(defaultLabels, ","))

  lootOpt.set(2)
  local ofAfterAssign = A.OptionsData_GetDB("echoGroupOf")
  check("assigning loot to group 2 writes a copy",
    ofAfterAssign ~= A.ECHO_DEFAULTS.echoGroupOf and ofAfterAssign.loot == 2, tostring(ofAfterAssign and ofAfterAssign.loot))
  check("default echoGroupOf is not mutated", A.ECHO_DEFAULTS.echoGroupOf.loot == nil, tostring(A.ECHO_DEFAULTS.echoGroupOf.loot))
  check("loot now reads group 2", lootOpt.get() == 2, tostring(lootOpt.get()))

  lootOpt.set("none")
  local ofAfterClear = A.OptionsData_GetDB("echoGroupOf")
  check("clearing back to None writes another copy",
    ofAfterClear ~= ofAfterAssign and ofAfterClear.loot == nil, tostring(ofAfterClear and ofAfterClear.loot))
  check("loot back at None", lootOpt.get() == "none", tostring(lootOpt.get()))

  local group2NameOpt = findOpt("editbox", A.L["ECHO_GROUP_NAME"]:format(2), 2)
  check("group 2 name editbox exists", group2NameOpt ~= nil, "?")
  check("group 2 name starts blank", group2NameOpt.get() == "", tostring(group2NameOpt.get()))
  group2NameOpt.set("Crew")
  local namesAfter = A.OptionsData_GetDB("echoGroupNames")
  check("renaming group 2 writes a copy",
    namesAfter ~= A.ECHO_DEFAULTS.echoGroupNames and namesAfter[1] == A.L["ECHO_GROUP_CHANNELS"] and namesAfter[2] == "Crew", namesAfter and namesAfter[2])
  check("default echoGroupNames is not mutated", A.ECHO_DEFAULTS.echoGroupNames[2] == "", A.ECHO_DEFAULTS.echoGroupNames[2])

  -- Blank groups aren't offered (final fix 2): a blank-named group groups nothing, so even
  -- when something is (stale-)assigned to it, the dropdown doesn't list it, "Group N" or not.
  local partyOpt = findOpt("dropdown", A.L["ECHO_KIND_PARTY"])
  partyOpt.set(3)
  local partyOpts = partyOpt.options()
  -- None, group 1 ("Channels") and group 2 ("Crew", just renamed above); group 3 stays
  -- blank and unlisted even though party now points at it.
  check("a blank but referenced group isn't offered", #partyOpts == 3, #partyOpts)
  for _, o in ipairs(partyOpts) do
    check("no option names an unnamed group", o[2] ~= 3, o[1])
  end
  partyOpt.set("none")

  -- None beats "Other channels" (final fix 1): for an exact channel id, None writes false
  -- (not a removed entry), so it is not shadowed by a grouped ch:* fallback.
  local tradeOpt = findOpt("dropdown", A.L["ECHO_GROUP_MEMBER_TRADE"])
  local otherOpt = findOpt("dropdown", A.L["ECHO_GROUP_MEMBER_OTHER_CHANNELS"])
  check("trade and other-channels dropdowns exist", tradeOpt ~= nil and otherOpt ~= nil, "?")
  otherOpt.set(2)
  tradeOpt.set("none")
  local ofChannelNone = A.OptionsData_GetDB("echoGroupOf")
  check("None on an exact channel writes false, not a removed entry",
    ofChannelNone["ch:Trade"] == false, tostring(ofChannelNone["ch:Trade"]))
  check("the dropdown still reads None for a false entry", tradeOpt.get() == "none", tostring(tradeOpt.get()))

  A.GetDB = A.OptionsData_GetDB
  check("Groups.Of honours the exact-channel None over the ch:* group",
    A.Echo.Groups.Of("ch:Trade") == nil, tostring(A.Echo.Groups.Of("ch:Trade")))
  check("an unlisted channel still falls back to Other channels' group",
    A.Echo.Groups.Of("ch:SomeCustom") == 2, tostring(A.Echo.Groups.Of("ch:SomeCustom")))
  A.GetDB = nil

  otherOpt.set("none")
  tradeOpt.set("none")

  -- Group icon buttons (Task: group icons). One "Choose icon" button sits after each of the
  -- four group-name editboxes; addon.OpenIconPicker is stubbed to capture the opts it's
  -- called with, so the button's own wiring (title, get, set, allowDefault) is testable
  -- without the picker frame itself (the harness doesn't load HorizonIconPicker.lua).
  local capturedOpts
  A.OpenIconPicker = function(o) capturedOpts = o end

  local iconButtons = {}
  for _, opt in ipairs(cat.options) do
    if opt.type == "button" and opt.name == A.L["ECHO_GROUP_ICON"] then iconButtons[#iconButtons + 1] = opt end
  end
  check("a choose-icon button per group", #iconButtons == 4, #iconButtons)
  check("first icon button carries the options-page dbKey", iconButtons[1].dbKey == "echoGroupIcons", tostring(iconButtons[1] and iconButtons[1].dbKey))
  check("icon button desc", iconButtons[1].desc == A.L["ECHO_GROUP_ICON_DESC"], iconButtons[1].desc)

  -- Group 1 ("Channels") titles with its own name; group 2 was renamed to "Crew" above.
  iconButtons[1].onClick()
  check("titles with the group's own name", capturedOpts.title == A.L["ECHO_GROUP_CHANNELS"], tostring(capturedOpts.title))
  check("allows clearing to default", capturedOpts.allowDefault == true, tostring(capturedOpts.allowDefault))
  check("get reads the unset default", capturedOpts.get() == nil, tostring(capturedOpts.get()))

  -- Group 3 stayed blank throughout, so its button falls back to "Group 3".
  iconButtons[3].onClick()
  check("a blank group titles as Group N", capturedOpts.title == string.format(A.L["ECHO_GROUP_DEFAULT_TITLE"], 3), tostring(capturedOpts.title))

  -- set(icon) writes a fresh copy, leaving the saved and default tables untouched.
  iconButtons[1].onClick()
  local savedBefore = A.OptionsData_GetDB("echoGroupIcons")
  capturedOpts.set(136243)
  local iconsAfterSet = A.OptionsData_GetDB("echoGroupIcons")
  check("set(fileID) writes a fresh copy", iconsAfterSet ~= savedBefore and iconsAfterSet ~= A.ECHO_DEFAULTS.echoGroupIcons and iconsAfterSet[1] == 136243, tostring(iconsAfterSet and iconsAfterSet[1]))
  check("default echoGroupIcons untouched by set", A.ECHO_DEFAULTS.echoGroupIcons[1] == nil, tostring(A.ECHO_DEFAULTS.echoGroupIcons[1]))

  iconButtons[1].onClick()
  check("get reads back the chosen fileID", capturedOpts.get() == 136243, tostring(capturedOpts.get()))

  iconButtons[2].onClick()
  capturedOpts.set("Interface\\\\Icons\\\\INV_Misc_Book_09")
  local iconsAfterPath = A.OptionsData_GetDB("echoGroupIcons")
  check("set(path) writes group 2's slot without disturbing group 1's", iconsAfterPath[1] == 136243 and iconsAfterPath[2] == "Interface\\\\Icons\\\\INV_Misc_Book_09", tostring(iconsAfterPath[2]))

  -- Use default (set(nil)) clears the slot but leaves the other slot and the default table
  -- alone.
  iconButtons[1].onClick()
  capturedOpts.set(nil)
  local iconsAfterClear = A.OptionsData_GetDB("echoGroupIcons")
  check("set(nil) clears group 1's slot", iconsAfterClear[1] == nil and iconsAfterClear[2] == "Interface\\\\Icons\\\\INV_Misc_Book_09", tostring(iconsAfterClear[1]))
  check("clearing does not mutate the previous saved table", iconsAfterPath[1] == 136243, tostring(iconsAfterPath[1]))
  check("default echoGroupIcons still untouched", A.ECHO_DEFAULTS.echoGroupIcons[1] == nil and A.ECHO_DEFAULTS.echoGroupIcons[2] == nil, "?")

  A.OptionsData_SetDB("echoGroupIcons", nil)
  A.OpenIconPicker = nil

  A.OptionCategories, A.OptionsData_GetDB, A.OptionsData_SetDB = nil, nil, nil
  A.Section, A.Button, A.Toggle, A.GetPerElementFontDropdownOptions = nil, nil, nil, nil
  A.ECHO_DEFAULTS, A.ECHO_KEYS, A.ECHO_LIMITS = nil, nil, nil
`, 'echo-options-page');

// --- Slash output goes through the locale table -------------------------------
run(`
  local src = ${JSON.stringify(read('modules/Echo/EchoSlash.lua'))}
  local literal = 0
  for line in src:gmatch("[^\\n]+") do
    if line:find("HSPrint%(") and line:find('HSPrint%(%(?"') then literal = literal + 1 end
  end
  check("no literal strings printed by /h echo", literal == 0, literal)
`, 'echo-slash-locale');

// --- View: tile faces ----------------------------------------------------------
run(`
  local S, V = HorizonSuite.Echo.Store, HorizonSuite.Echo.View
  S.Reset()
  RAID_CLASS_COLORS = { DRUID = { r = 1, g = 0.49, b = 0.04 } }

  check("short name", V.ShortName("Brisa", 5) == "Brisa", V.ShortName("Brisa", 5))
  check("short name truncates", V.ShortName("Thornwick", 5) == "Thorn", V.ShortName("Thornwick", 5))
  check("short name counts characters, not bytes", V.ShortName("Ælfrida", 5) == "Ælfri", V.ShortName("Ælfrida", 5))
  check("short name of a secret is empty", V.ShortName(SECRET("x"), 5) == "", V.ShortName(SECRET("x"), 5))
  check("short name of a non-string is empty", V.ShortName(nil, 5) == "", "?")

  S.Add({ convKey = "ch:General", text = "lfg" })
  local genSpec = V.TileSpec(S.Get("ch:General"))
  check("channel General is an icon face", genSpec.face == "icon" and genSpec.icon == V.CHANNEL_ICONS.General, genSpec.face)
  check("channel General labels Gen", genSpec.label == "Gen", genSpec.label)
  S.Add({ convKey = "ch:Guild", text = "hi" })
  local chGuildSpec = V.TileSpec(S.Get("ch:Guild"))
  check("a channel named Guild isn't the guild kind", chGuildSpec.face == "glyph" and chGuildSpec.letter == "Guil" and chGuildSpec.small == true, chGuildSpec.letter)
  S.Add({ convKey = "guild", text = "gz" })
  local guildSpec = V.TileSpec(S.Get("guild"))
  check("the guild kind is its glyph", guildSpec.letter == "G" and not guildSpec.small, guildSpec.letter)
  S.Add({ convKey = "ch:Trade", text = "wts" })
  local tradeSpec = V.TileSpec(S.Get("ch:Trade"))
  check("channel Trade is an icon face", tradeSpec.face == "icon" and tradeSpec.icon == V.CHANNEL_ICONS.Trade, tradeSpec.face)
  check("channel Trade labels Trade", tradeSpec.label == "Trade", tradeSpec.label)
  S.Add({ convKey = "ch:Local Defense", text = "inc" })
  local defSpec = V.TileSpec(S.Get("ch:Local Defense"))
  check("channel Local Defense is an icon face", defSpec.face == "icon" and defSpec.icon == V.CHANNEL_ICONS.LocalDefense, defSpec.face)
  check("channel Local Defense labels Def", defSpec.label == "Def", defSpec.label)
  S.Add({ convKey = "ch:MyCustom", text = "hi" })
  local customSpec = V.TileSpec(S.Get("ch:MyCustom"))
  check("an unlisted channel stays a glyph", customSpec.face == "glyph", customSpec.face)
  check("an unlisted channel is capped at 4", customSpec.letter == "MyCu" and customSpec.small == true, customSpec.letter)

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  local brisa = S.Get("w:Brisa-Horizon")
  HorizonSuite.ResolveClassIconDisplay = function(class, source) return { kind = "file", path = "X" } end
  local classSpec = V.TileSpec(brisa)
  check("a resolved class gives a class face", classSpec.face == "class", classSpec.face)
  check("the class face carries the icon", classSpec.classIcon and classSpec.classIcon.path == "X", "?")
  check("a whisper's label is its name", classSpec.label == "Brisa", classSpec.label)
  local servicesSpec = V.TileSpec({ key = "ch:Trade (Services)", kind = "channel", unread = 0, messages = {} })
  check("the Services channel is an icon face", servicesSpec.face == "icon" and servicesSpec.icon == V.CHANNEL_ICONS["Trade(Services)"], servicesSpec.face)
  check("the Services channel reads Serv", servicesSpec.label == "Serv", servicesSpec.label)
  HorizonSuite.ResolveClassIconDisplay = function() return nil end
  local letterSpec = V.TileSpec(brisa)
  check("no resolved class gives a letter face", letterSpec.face == "letter", letterSpec.face)
  check("the letter face's letter is the initial", letterSpec.letter == "B", letterSpec.letter)
  check("the letter face keeps the label", letterSpec.label == "Brisa", letterSpec.label)
  HorizonSuite.ResolveClassIconDisplay = nil

  S.Add({ convKey = "bn:77", text = "yo", sender = "|Kq1|k" })
  local bnet = S.Get("bn:77")
  local bnetSpec = V.TileSpec(bnet)
  check("a classless Battle.net tile is the logo", bnetSpec.face == "icon" and bnetSpec.icon == V.BNET_LOGO
        and bnetSpec.iconFull == true and bnetSpec.label == nil, bnetSpec.face)
  S.Add({ convKey = "bn:77", text = "yo again", class = "DRUID", sender = "|Kq1|k" })
  HorizonSuite.ResolveClassIconDisplay = function() return { kind = "file", path = "Y" } end
  local bnetClassSpec = V.TileSpec(S.Get("bn:77"))
  check("a classed Battle.net tile is a class face", bnetClassSpec.face == "class" and bnetClassSpec.label == nil, bnetClassSpec.face)
  HorizonSuite.ResolveClassIconDisplay = nil

  S.Add({ convKey = "loot", text = "You receive item: Foo", feed = true, chatType = "LOOT" })
  local feedSpec = V.TileSpec(S.Get("loot"))
  check("a feed is still an icon face", feedSpec.face == "icon" and feedSpec.icon == V.FEED_ICONS.loot
        and feedSpec.iconFull == nil, feedSpec.face)
  check("a feed keeps its short label here too", feedSpec.label == HorizonSuite.L["ECHO_FEED_SHORT_LOOT"], feedSpec.label)

  S.SetTier("w:Brisa-Horizon", "loud")
  check("loud with unread shows a dot", V.Badge(brisa) == "dot", V.Badge(brisa))
  S.SetTier("w:Brisa-Horizon", "count")
  check("count with unread shows the count", V.Badge(brisa) == "count", V.Badge(brisa))
  S.SetTier("w:Brisa-Horizon", "quiet")
  check("quiet shows no badge", V.Badge(brisa) == nil, V.Badge(brisa))
  S.SetTier("w:Brisa-Horizon", "loud")
  local zeroUnread = { key = "w:Zero-Horizon", unread = 0 }
  check("zero unread shows no badge even when loud", V.Badge(zeroUnread) == nil, "?")
  S.SetTier("w:Brisa-Horizon", nil)

  local realLocale = GetLocale
  GetLocale = function() return "enUS" end
  check("enUS upper-cases", V.Upper("abc") == "ABC", V.Upper("abc"))
  GetLocale = function() return "deDE" end
  check("deDE leaves accented text alone", V.Upper("über") == "über", V.Upper("über"))
  local secretVal = SECRET("x")
  check("Upper leaves a secret alone", rawequal(V.Upper(secretVal), secretVal), "?")
  GetLocale = realLocale

  HorizonSuite.ResolveClassIconDisplay = nil
  S.Reset()
`, 'view-tile-faces');

// --- Tile names shrink to fit ------------------------------------------------
run(`
  CreateFrame = STUB_CREATE_FRAME
  local Echo = HorizonSuite.Echo
  local fs = STUB_FRAME()
  -- 5px per character per 10pt of size.
  fs.GetStringWidth = function(self) return #self.text * (self._echoFitSize or 10) / 2 end
  check("a short name keeps the largest size", Echo.FitText(fs, "Brisa", 36, 10, 7, "OUTLINE") == 10 and fs.text == "Brisa", fs.text)
  check("a long name shrinks to fit", Echo.FitText(fs, "Thornwick", 36, 10, 7, "OUTLINE") == 8 and fs.text == "Thornwick", fs._echoFitSize)
  Echo.FitText(fs, "Thornwickshire", 36, 10, 7, "OUTLINE")
  check("too long even at the smallest size loses letters", fs.text == "Thornwicks" and fs._echoFitSize == 7, fs.text)
  local secret = SECRET("x")
  Echo.FitText(fs, secret, 36, 10, 7, "OUTLINE")
  check("a secret is set as-is, never measured", fs.text == secret, fs.text)
  fs.GetStringWidth = nil
  Echo.FitText(fs, "Thornwickshire", 36, 10, 7, "OUTLINE")
  check("no measurement keeps the whole name", fs.text == "Thornwickshire", fs.text)
`, 'echo-fit-text');

// --- Card message text size ---------------------------------------------------
run(`
  CreateFrame = STUB_CREATE_FRAME
  local Echo = HorizonSuite.Echo
  local C = Echo.Card
  local db = { echoCardTextSize = 14 }
  HorizonSuite.GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  HorizonSuite.ECHO_LIMITS = { echoCardTextSize = { min = 9, max = 16 } }
  check("the card's text defaults to 11", C.TEXT_SIZE == 11, C.TEXT_SIZE)
  C.ApplySize()
  check("the card's text follows its setting", C.TEXT_SIZE == 14, C.TEXT_SIZE)
  db.echoCardTextSize = 40
  C.ApplySize()
  check("the card's text size is clamped", C.TEXT_SIZE == 16, C.TEXT_SIZE)
  db.echoCardTextSize = nil
  C.ApplySize()
  check("back to the default", C.TEXT_SIZE == 11, C.TEXT_SIZE)
  HorizonSuite.GetDB, HorizonSuite.ECHO_LIMITS = nil, nil
`, 'echo-card-text-size');

// --- Class lookup: a whisperer's class without a GUID ------------------------
run(`
  local Echo = HorizonSuite.Echo
  local S = Echo.Store
  S.Reset()

  local saved = {
    IsInRaid = IsInRaid, UnitName = UnitName, UnitFullName = UnitFullName, UnitClass = UnitClass,
    IsInGuild = IsInGuild, GetNumGuildMembers = GetNumGuildMembers, GetGuildRosterInfo = GetGuildRosterInfo,
    C_FriendList = C_FriendList, C_BattleNet = C_BattleNet, BNET_CLIENT_WOW = BNET_CLIENT_WOW,
    LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE, LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE,
    Now = S.Now,
  }
  LOCALIZED_CLASS_NAMES_MALE = { DRUID = "Druid", ROGUE = "Rogue", EVOKER = "Evoker", MAGE = "Mage", PALADIN = "Paladin" }
  LOCALIZED_CLASS_NAMES_FEMALE = nil

  -- A group member resolves from the party roster.
  IsInRaid = function() return false end
  UnitName = function(unit)
    if unit == "party1" then return "Brisa", "" end
    return nil
  end
  UnitClass = function(unit)
    if unit == "party1" then return "Druid", "DRUID" end
    return nil
  end
  IsInGuild = function() return false end
  C_FriendList = nil

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi" })
  local brisa = S.Get("w:Brisa-Horizon")
  local class, source = Echo.Class.Resolve(brisa)
  check("a group member resolves", class == "DRUID" and source == "group", tostring(class) .. "/" .. tostring(source))
  check("the class is cached on the conversation", brisa.resolvedClass == "DRUID" and brisa.classSource == "group", brisa.resolvedClass)

  -- A cross-realm group member matches with the realm's spaces stripped, preferring
  -- UnitFullName when the client offers it.
  UnitFullName = function(unit)
    if unit == "party2" then return "Kaelis", "Aerie Peak" end
    return nil
  end
  UnitName = function(unit)
    if unit == "party2" then return "Kaelis-Aerie Peak", nil end
    return nil
  end
  UnitClass = function(unit)
    if unit == "party2" then return "Rogue", "ROGUE" end
    return nil
  end
  S.Add({ convKey = "w:Kaelis-AeriePeak", text = "hi" })
  local kaelis = S.Get("w:Kaelis-AeriePeak")
  class, source = Echo.Class.Resolve(kaelis)
  check("a cross-realm group member resolves", class == "ROGUE" and source == "group", tostring(class) .. "/" .. tostring(source))
  UnitFullName = nil
  UnitName = function(unit)
    if unit == "party1" then return "Brisa", "" end
    return nil
  end
  UnitClass = function(unit)
    if unit == "party1" then return "Druid", "DRUID" end
    return nil
  end

  -- A guild member resolves when nobody in the group matches.
  UnitName = function() return "Someoneelse", "" end
  IsInGuild = function() return true end
  GetNumGuildMembers = function() return 1 end
  GetGuildRosterInfo = function(i)
    if i == 1 then return "Thornwick-Horizon", "Officer", 1, 60, "Rogue", "Zone", "", "", true, 1, "ROGUE" end
    return nil
  end
  S.Add({ convKey = "w:Thornwick-Horizon", text = "hi" })
  local thornwick = S.Get("w:Thornwick-Horizon")
  class, source = Echo.Class.Resolve(thornwick)
  check("a guild member resolves", class == "ROGUE" and source == "guild", tostring(class) .. "/" .. tostring(source))

  -- Final fix 7: IsInGuild's truthiness accepts any truthy readable value, not only true.
  UnitName = function() return "Someoneelse2", "" end
  IsInGuild = function() return 1 end
  S.Add({ convKey = "w:Thornwick2-Horizon", text = "hi" })
  local thornwick2 = S.Get("w:Thornwick2-Horizon")
  GetGuildRosterInfo = function(i)
    if i == 1 then return "Thornwick2-Horizon", "Officer", 1, 60, "Rogue", "Zone", "", "", true, 1, "ROGUE" end
    return nil
  end
  class, source = Echo.Class.Resolve(thornwick2)
  check("a truthy non-boolean IsInGuild still resolves a guild member",
    class == "ROGUE" and source == "guild", tostring(class) .. "/" .. tostring(source))

  -- A friend resolves when nobody in the group or guild matches.
  IsInGuild = function() return false end
  C_FriendList = {
    GetNumFriends = function() return 1 end,
    GetFriendInfoByIndex = function(i)
      if i == 1 then return { name = "Vexa", className = "Evoker" } end
      return nil
    end,
  }
  S.Add({ convKey = "w:Vexa-Horizon", text = "hi" })
  local vexa = S.Get("w:Vexa-Horizon")
  class, source = Echo.Class.Resolve(vexa)
  check("a friend resolves", class == "EVOKER" and source == "friends", tostring(class) .. "/" .. tostring(source))

  -- With no male table, the female table is still checked (fix round 1, finding 2).
  LOCALIZED_CLASS_NAMES_MALE = nil
  LOCALIZED_CLASS_NAMES_FEMALE = { PALADIN = "Paladin" }
  C_FriendList = {
    GetNumFriends = function() return 1 end,
    GetFriendInfoByIndex = function(i)
      if i == 1 then return { name = "Priss", className = "Paladin" } end
      return nil
    end,
  }
  S.Add({ convKey = "w:Priss-Horizon", text = "hi" })
  local priss = S.Get("w:Priss-Horizon")
  class, source = Echo.Class.Resolve(priss)
  check("a female-table-only friend still maps", class == "PALADIN" and source == "friends", tostring(class) .. "/" .. tostring(source))
  LOCALIZED_CLASS_NAMES_MALE = { DRUID = "Druid", ROGUE = "Rogue", EVOKER = "Evoker", MAGE = "Mage", PALADIN = "Paladin" }
  LOCALIZED_CLASS_NAMES_FEMALE = nil

  -- A message's own class always wins, even once a lookup has cached something else.
  S.Add({ convKey = "w:Vexa-Horizon", text = "hi again", class = "MAGE", sender = "Vexa-Horizon" })
  class, source = Echo.Class.Resolve(vexa)
  check("a message class wins over lookups", class == "MAGE" and source == "message", tostring(class) .. "/" .. tostring(source))

  -- A secret roster name is skipped: the guild lookup never matches it.
  IsInGuild = function() return true end
  GetNumGuildMembers = function() return 1 end
  GetGuildRosterInfo = function(i)
    if i == 1 then return SECRET("Cloak-Horizon"), nil, nil, nil, nil, nil, nil, nil, nil, nil, "WARRIOR" end
    return nil
  end
  C_FriendList = nil
  S.Add({ convKey = "w:Cloak-Horizon", text = "hi" })
  local cloak = S.Get("w:Cloak-Horizon")
  class = Echo.Class.Resolve(cloak)
  check("a secret roster name is skipped", class == nil, tostring(class))

  -- A miss isn't re-scanned within 5 seconds.
  local clock = 1000
  S.Now = function() return clock end
  local rosterCalls = 0
  IsInGuild = function() return true end
  GetNumGuildMembers = function() return 1 end
  GetGuildRosterInfo = function(i) rosterCalls = rosterCalls + 1; return nil end
  S.Add({ convKey = "w:Miss-Horizon", text = "hi" })
  local miss = S.Get("w:Miss-Horizon")
  class = Echo.Class.Resolve(miss)
  check("a fresh miss has no class", class == nil, tostring(class))
  local firstCalls = rosterCalls
  check("a miss is remembered on the conversation", miss.classMissAt ~= nil, tostring(miss.classMissAt))
  clock = clock + 2
  class = Echo.Class.Resolve(miss)
  check("a miss inside 5 seconds isn't re-scanned", rosterCalls == firstCalls, rosterCalls)
  clock = clock + 4
  class = Echo.Class.Resolve(miss)
  check("a miss past 5 seconds is re-scanned", rosterCalls > firstCalls, rosterCalls)
  S.Now = saved.Now

  -- Battle.net: a friend on WoW resolves; one in another game gets nil; never cached.
  IsInGuild = function() return false end
  C_BattleNet = {
    GetAccountInfoByID = function(id)
      if id == 1 then return { gameAccountInfo = { clientProgram = BNET_CLIENT_WOW or "WoW", className = "Rogue" } } end
      if id == 2 then return { gameAccountInfo = { clientProgram = "App", className = "Rogue" } } end
      return nil
    end,
  }
  S.Add({ convKey = "bn:1", text = "hi", sender = "|Kq1|k" })
  local bnetWow = S.Get("bn:1")
  class, source = Echo.Class.Resolve(bnetWow)
  check("a Battle.net friend on WoW resolves", class == "ROGUE" and source == "bnet", tostring(class) .. "/" .. tostring(source))
  check("a Battle.net class is never cached", bnetWow.resolvedClass == nil, tostring(bnetWow.resolvedClass))
  S.Add({ convKey = "bn:2", text = "hi", sender = "|Kq2|k" })
  local bnetApp = S.Get("bn:2")
  class = Echo.Class.Resolve(bnetApp)
  check("a Battle.net friend in another game gets nil", class == nil, tostring(class))

  -- A tile spec for a whisper with no message class but a guild-found class is the class face.
  IsInGuild = function() return true end
  GetNumGuildMembers = function() return 1 end
  GetGuildRosterInfo = function(i)
    if i == 1 then return "Restored-Horizon", nil, nil, nil, nil, nil, nil, nil, nil, nil, "PALADIN" end
    return nil
  end
  HorizonSuite.ResolveClassIconDisplay = function() return { kind = "file", path = "P" } end
  S.Add({ convKey = "w:Restored-Horizon", text = "hi" })
  local restored = S.Get("w:Restored-Horizon")
  local spec = Echo.View.TileSpec(restored)
  check("a restored whisper with a guild-found class gets a class face", spec.face == "class", spec.face)
  HorizonSuite.ResolveClassIconDisplay = nil

  -- Roster/friends events: do nothing unless something they might resolve is open, keep
  -- the miss throttle, and only fully repaint the card when it's showing an affected
  -- conversation (final review, ruling 5).
  CreateFrame = STUB_CREATE_FRAME
  IsInGuild = function() return false end
  local marks = {}
  local function ResetMarks() marks = {} end
  Echo.Redraw.Register("tiles", function() marks.tiles = true end)
  Echo.Redraw.Register("stack", function() marks.stack = true end)
  Echo.Redraw.Register("card", function() marks.card = true end)
  Echo.Redraw.Register("cardRow", function() marks.cardRow = true end)
  Echo.Class.Enable()
  local frame = Echo.Class._frame()

  -- Final fix 3: a guild roster event always marks tiles and cardRow, even with nothing a
  -- classless whisper could resolve, since the guild tile's own tabard may have changed.
  S.Reset()
  ResetMarks()
  frame.scripts.OnEvent(frame, "GUILD_ROSTER_UPDATE")
  check("no classless whisper: a guild event still marks tiles for the tabard", marks.tiles == true, "?")
  check("no classless whisper: a guild event still marks cardRow for the tabard", marks.cardRow == true, "?")
  check("no classless whisper: a guild event marks nothing else", marks.stack == nil and marks.card == nil, "marked something else")

  ResetMarks()
  frame.scripts.OnEvent(frame, "PLAYER_GUILD_UPDATE")
  check("PLAYER_GUILD_UPDATE also marks tiles for the tabard", marks.tiles == true, "?")
  check("PLAYER_GUILD_UPDATE also marks cardRow for the tabard", marks.cardRow == true, "?")

  -- With one classless whisper conversation, a guild event marks tiles and stack; a
  -- different shown conversation gets only its row marked, not the full card.
  S.Add({ convKey = "w:Retry-Horizon", text = "hi" })
  local retry = S.Get("w:Retry-Horizon")
  Echo.Class.Resolve(retry)
  check("a fresh miss sets classMissAt", retry.classMissAt ~= nil, tostring(retry.classMissAt))
  local savedShownKey = Echo.Card.ShownKey
  Echo.Card.ShownKey = function() return "w:SomeoneElse-Horizon" end
  ResetMarks()
  frame.scripts.OnEvent(frame, "GUILD_ROSTER_UPDATE")
  check("a qualifying event marks tiles", marks.tiles == true, "?")
  check("a qualifying event marks stack", marks.stack == true, "?")
  check("a different shown conversation marks only the card row", marks.cardRow == true and marks.card == nil, "?")

  -- A recent miss (inside the 5s throttle) isn't cleared by the event.
  check("a recent miss isn't cleared by an event", retry.classMissAt ~= nil, tostring(retry.classMissAt))

  -- When the card is showing the affected conversation, the full card is marked instead.
  Echo.Card.ShownKey = function() return "w:Retry-Horizon" end
  ResetMarks()
  frame.scripts.OnEvent(frame, "GUILD_ROSTER_UPDATE")
  -- cardRow is also marked here (final fix 3's unconditional tabard mark), alongside the
  -- full card the affected-conversation branch marks.
  check("the shown conversation marks the full card", marks.card == true, "?")
  check("and cardRow too, unconditionally for the tabard", marks.cardRow == true, "?")
  Echo.Card.ShownKey = savedShownKey

  -- Past the throttle, the event clears the miss.
  local savedNow2 = S.Now
  local clock2 = 5000
  S.Now = function() return clock2 end
  retry.classMissAt = clock2 - Echo.Class.MISS_SECONDS - 1
  frame.scripts.OnEvent(frame, "GROUP_ROSTER_UPDATE")
  check("a stale miss is cleared by an event", retry.classMissAt == nil, tostring(retry.classMissAt))
  S.Now = savedNow2

  Echo.Class.Disable()

  -- Enable requests the guild roster once, when in a guild, preferring C_GuildInfo over
  -- the older global, and never when not in a guild.
  local savedGuildInfo = C_GuildInfo
  local rosterRequests = 0
  C_GuildInfo = { GuildRoster = function() rosterRequests = rosterRequests + 1 end }
  IsInGuild = function() return true end
  Echo.Class.Enable()
  check("Enable requests the guild roster via C_GuildInfo when in a guild", rosterRequests == 1, rosterRequests)
  Echo.Class.Disable()

  C_GuildInfo = nil
  local oldGuildRoster = GuildRoster
  local oldRosterCalls = 0
  GuildRoster = function() oldRosterCalls = oldRosterCalls + 1 end
  Echo.Class.Enable()
  check("Enable falls back to the global GuildRoster", oldRosterCalls == 1, oldRosterCalls)
  Echo.Class.Disable()
  GuildRoster = oldGuildRoster

  IsInGuild = function() return false end
  rosterRequests = 0
  C_GuildInfo = { GuildRoster = function() rosterRequests = rosterRequests + 1 end }
  Echo.Class.Enable()
  check("Enable never requests the guild roster when not in a guild", rosterRequests == 0, rosterRequests)
  Echo.Class.Disable()
  C_GuildInfo = savedGuildInfo

  IsInRaid, UnitName, UnitFullName, UnitClass = saved.IsInRaid, saved.UnitName, saved.UnitFullName, saved.UnitClass
  IsInGuild, GetNumGuildMembers, GetGuildRosterInfo = saved.IsInGuild, saved.GetNumGuildMembers, saved.GetGuildRosterInfo
  C_FriendList, C_BattleNet, BNET_CLIENT_WOW = saved.C_FriendList, saved.C_BattleNet, saved.BNET_CLIENT_WOW
  LOCALIZED_CLASS_NAMES_MALE, LOCALIZED_CLASS_NAMES_FEMALE = saved.LOCALIZED_CLASS_NAMES_MALE, saved.LOCALIZED_CLASS_NAMES_FEMALE
  S.Reset()
`, 'class-lookup');

// --- Whisper sound choices ----------------------------------------------------
run(`
  local Echo = HorizonSuite.Echo
  local db = { echoWhisperSound = "blizzard", echoSoundInCombat = true, echoSoundBnet = true }
  HorizonSuite.ECHO_DEFAULTS = { echoWhisperSound = "blizzard", echoSoundInCombat = true, echoSoundBnet = true }
  HorizonSuite.GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  local played
  PlaySound = function(id) played = id end
  local now = 1000
  GetTime = function() return now end
  InCombatLockdown = function() return false end
  SOUNDKIT = { TELL_MESSAGE = 3081, UI_BNET_TOAST = 5274, MAP_PING = 6262 }

  Echo.Sound.Whisper(false)
  check("blizzard choice plays TELL_MESSAGE", played == 3081, played)

  now = now + 2; played = nil
  db.echoWhisperSound = "toast"
  Echo.Sound.Whisper(false)
  check("toast choice plays UI_BNET_TOAST", played == 5274, played)

  now = now + 2; played = nil
  db.echoWhisperSound = "ping"
  Echo.Sound.Whisper(false)
  check("ping choice plays MAP_PING", played == 6262, played)

  now = now + 2; played = nil
  SOUNDKIT = { TELL_MESSAGE = 3081 }
  db.echoWhisperSound = "toast"
  Echo.Sound.Whisper(false)
  check("a missing sound id falls back to TELL_MESSAGE", played == 3081, played)
  SOUNDKIT = { TELL_MESSAGE = 3081, UI_BNET_TOAST = 5274, MAP_PING = 6262 }

  now = now + 2; played = nil
  db.echoWhisperSound = "off"
  Echo.Sound.Whisper(false)
  check("off plays nothing", played == nil, played)

  db.echoWhisperSound = "blizzard"
  now = now + 2; played = nil
  InCombatLockdown = function() return true end
  db.echoSoundInCombat = false
  Echo.Sound.Whisper(false)
  check("combat with the toggle off plays nothing", played == nil, played)

  db.echoSoundInCombat = true
  now = now + 2
  Echo.Sound.Whisper(false)
  check("combat with the toggle on still plays", played == 3081, played)
  InCombatLockdown = function() return false end

  now = now + 2; played = nil
  db.echoSoundBnet = false
  Echo.Sound.Whisper(true)
  check("a Battle.net whisper with the toggle off plays nothing", played == nil, played)

  now = now + 2
  db.echoSoundBnet = true
  Echo.Sound.Whisper(true)
  check("a Battle.net whisper with the toggle on plays", played == 3081, played)

  now = now + 2
  Echo.Sound.Whisper(false)
  check("a fresh play after the gap plays", played == 3081, played)

  played = nil
  now = now + 1
  Echo.Sound.Whisper(false)
  check("a play under 1.5s later is throttled", played == nil, played)

  now = now + 1.5
  Echo.Sound.Whisper(false)
  check("a play 1.5s or more later plays again", played == 3081, played)

  played = nil
  Echo.Sound.Whisper(false, true)
  check("preview plays immediately inside the throttle window", played == 3081, played)

  InCombatLockdown = function() return true end
  db.echoSoundInCombat = false
  played = nil
  Echo.Sound.Whisper(false, true)
  check("preview bypasses the combat toggle", played == 3081, played)
  InCombatLockdown = function() return false end
  db.echoSoundInCombat = true

  db.echoSoundBnet = false
  played = nil
  Echo.Sound.Whisper(true, true)
  check("preview bypasses the Battle.net toggle", played == 3081, played)
  db.echoSoundBnet = true

  db.echoWhisperSound = "off"
  played = nil
  Echo.Sound.Whisper(false, true)
  check("preview still plays nothing when off", played == nil, played)

  PlaySound, SOUNDKIT, GetTime, InCombatLockdown = nil, nil, nil, nil
  HorizonSuite.GetDB, HorizonSuite.ECHO_DEFAULTS = nil, nil
`, 'echo-sound');

// --- Round: rounded rectangles from bundled textures -------------------------
run(`
  local Echo = HorizonSuite.Echo
  local Round = Echo.Round

  -- Apply builds the pieces once; a second Apply reuses them.
  do
    local frame = STUB_FRAME()
    local calls = 0
    local rawCreate = frame.CreateTexture
    frame.CreateTexture = function(self, ...) calls = calls + 1; return rawCreate(self, ...) end

    local h1 = Round.Apply(frame, { radius = 8 })
    local firstCalls = calls
    local h2 = Round.Apply(frame, { radius = 8 })
    check("Apply returns the same handle on a second call", h1 == h2, tostring(h2))
    check("a second Apply creates no more textures", calls == firstCalls, calls)
  end

  -- A uniform radius gives four corner quarters with the right texcoords and sizes.
  do
    local frame = STUB_FRAME()
    local h = Round.Apply(frame, { radius = 10 })
    local quads = {
      tl = { 0, 0.5, 0, 0.5 }, tr = { 0.5, 1, 0, 0.5 },
      bl = { 0, 0.5, 0.5, 1 }, br = { 0.5, 1, 0.5, 1 },
    }
    for _, c in ipairs({ "tl", "tr", "bl", "br" }) do
      local circle = h.fill.circle[c]
      local q = quads[c]
      check("uniform radius: " .. c .. " texcoord",
        circle.texCoord[1] == q[1] and circle.texCoord[2] == q[2]
          and circle.texCoord[3] == q[3] and circle.texCoord[4] == q[4],
        table.concat(circle.texCoord, ","))
      check("uniform radius: " .. c .. " quarter is sized to the radius",
        circle.width == 10 and circle.height == 10, circle.width)
      check("uniform radius: " .. c .. " fill rects are hidden (r == R)",
        h.fill.rect1[c].shown == false and h.fill.rect2[c].shown == false, "shown")
    end
  end

  -- A tight corner (br = 3, R = 10) sizes that quarter to 3 and shows both fill rects.
  do
    local frame = STUB_FRAME()
    local h = Round.Apply(frame, { radius = 10, corners = { br = 3 } })
    local circle = h.fill.circle.br
    check("tight corner: quarter sized to the corner radius", circle.width == 3 and circle.height == 3, circle.width)
    local rect1, rect2 = h.fill.rect1.br, h.fill.rect2.br
    check("tight corner: rect1 is R x (R - r)", rect1.width == 10 and rect1.height == 7, rect1.height)
    check("tight corner: rect2 is (R - r) x r", rect2.width == 7 and rect2.height == 3, rect2.width)
    check("tight corner: both fill rects are shown", rect1.shown == true and rect2.shown == true, "shown")
  end

  -- A radius bigger than half the shorter side is clamped.
  do
    local frame = STUB_FRAME()
    frame.GetWidth = function() return 40 end
    frame.GetHeight = function() return 20 end
    local h = Round.Apply(frame, { radius = 30 })
    check("radius clamps to half the shorter side", h.fill.circle.tl.width == 10, h.fill.circle.tl.width)
  end

  -- SetColor tints every fill piece.
  do
    local frame = STUB_FRAME()
    local h = Round.Apply(frame, { radius = 10 })
    Round.SetColor(frame, 0.1, 0.2, 0.3, 0.4)
    local function tinted(tex)
      local v = tex.vertexColor
      return v and v[1] == 0.1 and v[2] == 0.2 and v[3] == 0.3 and v[4] == 0.4
    end
    for _, c in ipairs({ "tl", "tr", "bl", "br" }) do
      check("SetColor tints the " .. c .. " quarter", tinted(h.fill.circle[c]), "vertexColor")
      check("SetColor tints the " .. c .. " rect1", tinted(h.fill.rect1[c]), "vertexColor")
      check("SetColor tints the " .. c .. " rect2", tinted(h.fill.rect2[c]), "vertexColor")
    end
    check("SetColor tints the top band", tinted(h.fill.topBand), "vertexColor")
    check("SetColor tints the bottom band", tinted(h.fill.bottomBand), "vertexColor")
    check("SetColor tints the middle band", tinted(h.fill.middleBand), "vertexColor")
  end

  -- SetBorderColor with alpha 0 hides the border pieces; a non-zero alpha shows them again.
  do
    local frame = STUB_FRAME()
    local h = Round.Apply(frame, { radius = 10, border = true })
    Round.SetBorderColor(frame, 1, 1, 1, 0)
    local hidden = true
    for _, c in ipairs({ "tl", "tr", "bl", "br" }) do
      if h.border.ring[c].shown ~= false then hidden = false end
    end
    for _, side in ipairs({ "top", "bottom", "left", "right" }) do
      if h.border.lines[side].shown ~= false then hidden = false end
    end
    check("SetBorderColor alpha 0 hides every border piece", hidden, "shown")

    Round.SetBorderColor(frame, 1, 1, 1, 1)
    local shown = true
    for _, c in ipairs({ "tl", "tr", "bl", "br" }) do
      if h.border.ring[c].shown ~= true then shown = false end
    end
    check("SetBorderColor with alpha restores visibility", shown, "shown")
  end

  -- Final fix 1: HookScript'd OnSizeChanged re-lays out to the frame's new size.
  do
    local frame = STUB_FRAME()
    local h = Round.Apply(frame, { radius = 10, border = true })
    check("Apply hooks OnSizeChanged when the frame supports HookScript",
      type(frame.hookScripts.OnSizeChanged) == "function", "?")
    frame.GetWidth = function() return 100 end
    frame.GetHeight = function() return 60 end
    frame.hookScripts.OnSizeChanged(frame)
    check("a resize re-lays out the top/bottom bands to the new width (w - 2R)",
      h.fill.topBand.width == 80 and h.fill.bottomBand.width == 80, h.fill.topBand.width)
    check("a resize re-lays out the middle band's height to the new height (h - 2R)",
      h.fill.middleBand.height == 40, h.fill.middleBand.height)
  end

  -- Final fix 1: a sized-frame band geometry test (not the resize hook, the initial Apply).
  do
    local frame = STUB_FRAME()
    frame.GetWidth = function() return 120 end
    frame.GetHeight = function() return 50 end
    local h = Round.Apply(frame, { radius = 10 })
    check("a sized frame's top band width is w - 2R", h.fill.topBand.width == 100, h.fill.topBand.width)
    check("a sized frame's middle band height is h - 2R", h.fill.middleBand.height == 30, h.fill.middleBand.height)
    check("a sized frame's middle band width is the full width", h.fill.middleBand.width == 120, h.fill.middleBand.width)
  end

  -- Final fix 4: fill draws below the border, both below a host's own (default) sublevel.
  do
    local frame = STUB_FRAME()
    local h = Round.Apply(frame, { radius = 10, border = true })
    for _, c in ipairs({ "tl", "tr", "bl", "br" }) do
      check("fill quarter " .. c .. " draws at sublevel -8", h.fill.circle[c].drawSublevel == -8, tostring(h.fill.circle[c].drawSublevel))
      check("border ring " .. c .. " draws at sublevel -7", h.border.ring[c].drawSublevel == -7, tostring(h.border.ring[c].drawSublevel))
    end
    check("the middle band draws at sublevel -8", h.fill.middleBand.drawSublevel == -8, tostring(h.fill.middleBand.drawSublevel))
    for _, side in ipairs({ "top", "bottom", "left", "right" }) do
      check("border line " .. side .. " draws at sublevel -7", h.border.lines[side].drawSublevel == -7, tostring(h.border.lines[side].drawSublevel))
    end
  end

  -- Final fix 7: Round.Dot is a single circle texture, not a 9-slice handle.
  do
    local parent = STUB_FRAME()
    local dot = Round.Dot(parent, 8, "OVERLAY")
    check("Dot is sized to the requested diameter", dot.width == 8 and dot.height == 8, "?")
    check("Dot uses the whole circle texture (texcoords 0-1)",
      dot.texCoord[1] == 0 and dot.texCoord[2] == 1 and dot.texCoord[3] == 0 and dot.texCoord[4] == 1, "?")
    check("Dot's texture is the bundled circle", dot.texture and dot.texture:find("circle.tga", 1, true) ~= nil, tostring(dot.texture))
    dot:SetVertexColor(0.5, 0.6, 0.7, 1)
    check("Dot tints via SetVertexColor", dot.vertexColor[1] == 0.5 and dot.vertexColor[3] == 0.7, "?")
  end

  -- Final fix 8: borderVisible gates rings/lines, and a zero-length line stays hidden even
  -- when the border is visible.
  do
    local frame = STUB_FRAME()
    frame.GetWidth = function() return 40 end
    frame.GetHeight = function() return 40 end
    local h = Round.Apply(frame, { radius = 10, border = true })
    check("borderVisible defaults true", h.borderVisible == true, tostring(h.borderVisible))
    check("a sized frame's border ring shows", h.border.ring.tl.shown == true, "?")
    check("a sized frame's border line shows (non-zero length)", h.border.lines.top.shown == true, "?")

    Round.SetBorderColor(frame, 1, 1, 1, 0)
    check("alpha 0 clears borderVisible", h.borderVisible == false, tostring(h.borderVisible))
    check("alpha 0 hides the ring", h.border.ring.tl.shown == false, "?")
    check("alpha 0 hides the line", h.border.lines.top.shown == false, "?")

    Round.SetBorderColor(frame, 1, 1, 1, 1)
    check("alpha 1 restores borderVisible", h.borderVisible == true, tostring(h.borderVisible))
    check("alpha 1 re-shows the ring", h.border.ring.tl.shown == true, "?")
    check("alpha 1 re-shows the line", h.border.lines.top.shown == true, "?")

    -- A frame exactly R tall/wide on one axis has zero-length top/bottom lines even though
    -- the border is visible: Layout must hide them rather than show a zero-length seam.
    local square = STUB_FRAME()
    square.GetWidth = function() return 20 end
    square.GetHeight = function() return 20 end
    local hs = Round.Apply(square, { radius = 10, border = true })
    check("a zero-length top border line stays hidden even though the border is visible",
      hs.borderVisible == true and hs.border.lines.top.shown == false, "?")
  end

  -- The texture path uses the addon folder.
  do
    local frame = STUB_FRAME()
    local h = Round.Apply(frame, { radius = 10, border = true })
    local circleTex = h.fill.circle.tl.texture
    local ringTex = h.border.ring.tl.texture
    check("circle texture is under the addon's media/echo folder",
      circleTex and circleTex:find("HorizonSuite", 1, true) and circleTex:find("media\\\\echo\\\\circle.tga", 1, true),
      tostring(circleTex))
    check("ring texture is under the addon's media/echo folder",
      ringTex and ringTex:find("HorizonSuite", 1, true) and ringTex:find("media\\\\echo\\\\ring.tga", 1, true),
      tostring(ringTex))
  end
`, 'echo-round');

// --- Groups: named groups of chats in the column ------------------------------
run(read('options/modules/defaults/OptionsDefaultsEcho.lua'), 'echo-defaults-groups');
run(`
  local A = HorizonSuite
  local Echo = A.Echo
  local G, V, S = Echo.Groups, Echo.View, Echo.Store
  S.Reset()

  check("groups on by default", A.ECHO_DEFAULTS.echoGroupsEnabled == true, tostring(A.ECHO_DEFAULTS.echoGroupsEnabled))
  local names = A.ECHO_DEFAULTS.echoGroupNames
  check("four group names, the first is Channels",
    type(names) == "table" and #names == 4 and names[1] == A.L["ECHO_GROUP_CHANNELS"] and names[2] == "" and names[4] == "", "?")
  local of = A.ECHO_DEFAULTS.echoGroupOf
  check("default group holds the five public channels",
    of["ch:General"] == 1 and of["ch:Trade"] == 1 and of["ch:Trade (Services)"] == 1
      and of["ch:LocalDefense"] == 1 and of["ch:LookingForGroup"] == 1 and of["ch:WorldDefense"] == nil, "?")
  check("group settings are routed", A.ECHO_KEYS.echoGroupsEnabled and A.ECHO_KEYS.echoGroupNames and A.ECHO_KEYS.echoGroupOf, "?")

  -- Defaults alone: the five channels are in group 1.
  check("defaults put Trade in group 1", G.Of("ch:Trade") == 1, tostring(G.Of("ch:Trade")))
  check("defaults leave guild alone", G.Of("guild") == nil, tostring(G.Of("guild")))

  local db = {}
  A.GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  db.echoGroupsEnabled = true
  db.echoGroupNames = { "Channels", "Crew", "", "   " }
  db.echoGroupOf = { ["ch:Trade"] = 1, ["ch:*"] = 2, guild = 2, party = 3, officer = 4, raid = 5,
                     loot = 1, ["w:Brisa-Horizon"] = 1, ["bn:7"] = 1, ["grp:1"] = 1 }
  local namesBefore, ofBefore = db.echoGroupNames, db.echoGroupOf

  check("exact channel id", G.Of("ch:Trade") == 1, tostring(G.Of("ch:Trade")))
  check("another channel falls back to ch:*", G.Of("ch:Crafters") == 2, tostring(G.Of("ch:Crafters")))
  check("a named kind", G.Of("guild") == 2, tostring(G.Of("guild")))
  check("a feed", G.Of("loot") == 1, tostring(G.Of("loot")))
  check("a blank name leaves the group unused", G.Of("party") == nil, tostring(G.Of("party")))
  check("a whitespace name leaves the group unused", G.Of("officer") == nil, tostring(G.Of("officer")))
  check("an index out of range is no group", G.Of("raid") == nil, tostring(G.Of("raid")))
  check("a whisper is never grouped", G.Of("w:Brisa-Horizon") == nil, tostring(G.Of("w:Brisa-Horizon")))
  check("battle.net is never grouped", G.Of("bn:7") == nil, tostring(G.Of("bn:7")))
  check("a group key is never grouped", G.Of("grp:1") == nil, tostring(G.Of("grp:1")))
  check("nonsense is no group", G.Of(nil) == nil and G.Of(42) == nil and G.Of("zzz") == nil, "?")
  db.echoGroupNames = { SECRET("x"), "Crew", "", "" }
  check("an unreadable name leaves the group unused", G.Of("ch:Trade") == nil, tostring(G.Of("ch:Trade")))
  check("an unreadable name reads as blank", G.Name(1) == "", tostring(G.Name(1)))
  db.echoGroupNames = namesBefore
  db.echoGroupsEnabled = false
  check("switched off, nothing is grouped", G.Of("ch:Trade") == nil and G.Of("guild") == nil, tostring(G.Of("ch:Trade")))
  db.echoGroupsEnabled = true
  db.echoGroupOf = { ["ch:Trade"] = 1, ["ch:*"] = 2 }
  db.echoGroupOf["ch:Crafters"] = false
  check("an exact entry of false is no group, not ch:*", G.Of("ch:Crafters") == nil, tostring(G.Of("ch:Crafters")))
  db.echoGroupOf = ofBefore

  check("name of a group", G.Name(2) == "Crew", G.Name(2))
  check("name out of range is blank", G.Name(9) == "" and G.Name(nil) == "", "?")
  check("group key", G.Key(3) == "grp:3", G.Key(3))
  check("index of a group key", G.IndexOf("grp:3") == 3, tostring(G.IndexOf("grp:3")))
  check("index of other keys is nil", G.IndexOf("grp:9") == nil and G.IndexOf("ch:Trade") == nil and G.IndexOf(nil) == nil, "?")

  -- A group's chosen icon (Task: group icons). No echoGroupIcons setting at all yet: every
  -- group falls back to View.GROUP_ICON.
  check("no echoGroupIcons setting falls back to the default icon", G.Icon(1) == V.GROUP_ICON, tostring(G.Icon(1)))
  db.echoGroupIcons = { 136243, "Interface\\\\Icons\\\\INV_Misc_Book_09", 0, "" }
  check("a chosen fileID", G.Icon(1) == 136243, tostring(G.Icon(1)))
  check("a chosen path", G.Icon(2) == "Interface\\\\Icons\\\\INV_Misc_Book_09", tostring(G.Icon(2)))
  check("a zero fileID falls back to the default", G.Icon(3) == V.GROUP_ICON, tostring(G.Icon(3)))
  check("an empty path falls back to the default", G.Icon(4) == V.GROUP_ICON, tostring(G.Icon(4)))
  check("an out-of-range index falls back to the default", G.Icon(9) == V.GROUP_ICON and G.Icon(nil) == V.GROUP_ICON, "?")
  db.echoGroupIcons[1] = SECRET(136243)
  check("a secret icon falls back to the default", G.Icon(1) == V.GROUP_ICON, tostring(G.Icon(1)))
  db.echoGroupIcons = nil

  -- Column: members merge into one entry at the first member's position.
  local trade = { key = "ch:Trade", kind = "channel", open = true, unread = 2 }
  local brisa = { key = "w:Brisa-Horizon", kind = "whisper", open = true, unread = 1 }
  local crafters = { key = "ch:Crafters", kind = "channel", open = true, unread = 3 }
  local guild = { key = "guild", kind = "guild", open = true, unread = 0 }
  local loot = { key = "loot", kind = "loot", open = true, unread = 4 }
  local list = { brisa, trade, crafters, guild, loot }
  local visible, overflow = V.Column(list, 8)
  check("column merges groups into entries", #visible == 3 and overflow == 0, #visible .. "/" .. overflow)
  check("an ungrouped chat stays an entry", visible[1] == brisa, visible[1] and visible[1].key)
  local g1, g2 = visible[2], visible[3]
  check("group 1 sits at Trade's position", g1.key == "grp:1" and g1.kind == "group" and g1.group == 1 and g1.open == true, g1.key)
  check("group 1 members in Store order", #g1.members == 2 and g1.members[1] == trade and g1.members[2] == loot, #g1.members)
  check("group 2 sits at Crafters' position", g2.key == "grp:2" and #g2.members == 2 and g2.members[1] == crafters and g2.members[2] == guild, g2.key)
  check("members of a group", #G.Members(2, list) == 2 and G.Members(2, list)[1] == crafters, #G.Members(2, list))
  local closed = { key = "guild", kind = "guild", open = false }
  check("a closed chat is not a member", #G.Members(2, { crafters, closed }) == 1, #G.Members(2, { crafters, closed }))

  visible, overflow = V.Column(list, 2)
  check("overflow counts entries", #visible == 1 and overflow == 2 and visible[1] == brisa, #visible .. "/" .. overflow)
  local _, _, entries = V.Column(list, 2)
  check("column hands back every entry", #entries == 3 and entries[2].key == "grp:1", entries and #entries)

  db.echoGroupsEnabled = false
  visible, overflow = V.Column(list, 8)
  check("switched off, the column is one entry per chat", #visible == 5 and visible[2] == trade, #visible)
  db.echoGroupsEnabled = true

  -- A group tile.
  S.SetTier("guild", "loud")
  local spec = V.TileSpec(g1)
  check("group face is the group icon", spec.face == "icon" and spec.icon == V.GROUP_ICON and spec.glyph == true, spec.face)
  check("group label is its short name", spec.label == V.ShortName("Channels", 6), spec.label)
  check("group accent colour", spec.r == V.ACCENT.r and spec.g == V.ACCENT.g and spec.b == V.ACCENT.b, spec.r)

  -- A chosen echoGroupIcons entry shows on the tile instead of the default group icon.
  db.echoGroupIcons = { 136243 }
  spec = V.TileSpec(g1)
  check("a chosen group icon shows on its tile", spec.icon == 136243, tostring(spec.icon))
  db.echoGroupIcons = nil
  spec = V.TileSpec(g1)
  check("no chosen icon falls back to the group icon", spec.icon == V.GROUP_ICON, tostring(spec.icon))

  -- Final fix 4: quiet (and muted) members don't inflate the group's count, only ones with
  -- their own badge do.
  check("quiet members give no badge and don't inflate the count", spec.badge == nil and spec.count == 0, spec.count)
  S.SetTier("loot", "count")
  spec = V.TileSpec(g1)
  check("a count member gives a count badge and joins the sum", spec.badge == "count" and spec.count == 4, spec.count)
  guild.unread = 1
  S.SetTier("loot", nil)
  S.SetTier("ch:Trade", "count")
  local mixed = { key = "grp:2", kind = "group", group = 2, open = true, members = { trade, guild } }
  spec = V.TileSpec(mixed)
  check("the loudest badge wins", spec.badge == "dot" and spec.count == 3, tostring(spec.badge))
  S.SetTier("guild", nil)
  S.SetTier("ch:Trade", nil)

  check("settings tables are not mutated", db.echoGroupNames == namesBefore and #namesBefore == 4
    and namesBefore[2] == "Crew" and db.echoGroupOf == ofBefore and ofBefore.raid == 5 and ofBefore["ch:*"] == 2, "?")
  local dnames, dof = A.ECHO_DEFAULTS.echoGroupNames, A.ECHO_DEFAULTS.echoGroupOf
  local n = 0
  for _ in pairs(dof) do n = n + 1 end
  check("default tables are not mutated", #dnames == 4 and dnames[1] == A.L["ECHO_GROUP_CHANNELS"] and n == 5, n)

  A.GetDB = nil
  A.ECHO_DEFAULTS, A.ECHO_KEYS, A.ECHO_LIMITS = nil, nil, nil
  S.Reset()
`, 'echo-groups');

// --- Groups: group tiles, the card's tabs, toasts and the genie ---------------
run(read('options/modules/defaults/OptionsDefaultsEcho.lua'), 'echo-defaults-group-card');
run(`
  local A = HorizonSuite
  local Echo = A.Echo
  local S, T, K, C, G, V, Gr = Echo.Store, Echo.Tiles, Echo.Stack, Echo.Card, Echo.Genie, Echo.View, Echo.Groups
  S.Reset()
  G._reset()
  Echo.ClearDrafts()
  local savedCreateFrame = CreateFrame
  CreateFrame = STUB_CREATE_FRAME
  local db = { echoAnimateCard = true, echoColumnEdge = "right" }
  A.GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  T.Enable()
  K.Enable()
  C.Enable()
  local f = C._frames()
  rawset(A.L, "ECHO_GROUP_TITLE", "%s · %s")
  local function L_FMT(_, x, y) return string.format("%s · %s", x, y) end
  local function Fill(frame) local h = rawget(frame, "_echoRound"); return h and h.fill.topBand.vertexColor end
  local function Border(frame) local h = rawget(frame, "_echoRound"); return h and h.border and h.border.ring.tl.vertexColor end
  local function Geometry(frame, l, b, w, h)
    frame.GetLeft = function() return l end
    frame.GetBottom = function() return b end
    frame.GetWidth = function() return w end
    frame.GetHeight = function() return h end
    frame.GetEffectiveScale = function() return 1 end
  end
  f.root.SetAlpha = function(self, a) self.alphaValue = a end
  f.root.GetAlpha = function(self) return rawget(self, "alphaValue") or 1 end
  Geometry(f.root, 500, 100, 360, 440)

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon" })
  S.Add({ convKey = "ch:Trade", text = "wts", sender = "Vexa-Horizon" })
  S.SetTier("ch:General", "loud")
  S.Add({ convKey = "ch:General", text = "anyone?", sender = "Thorn-Horizon" })
  S.Add({ convKey = "ch:Trade", text = "wtb", sender = "Vexa-Horizon" })

  -- The column.
  local gtile = T.TileFor("grp:1")
  check("a group tile shows for grouped channels", gtile ~= nil and gtile:IsShown(), "no tile")
  check("the group tile paints the group face", gtile and gtile.icon.texture == V.GROUP_ICON, gtile and tostring(gtile.icon.texture))
  check("TileFor(member) returns the group tile", T.TileFor("ch:Trade") == gtile and T.TileFor("ch:General") == gtile, "?")
  check("an ungrouped chat keeps its own tile", T.TileFor("w:Brisa-Horizon") ~= nil and T.TileFor("w:Brisa-Horizon") ~= gtile, "?")
  check("the newest member is the loudest", Gr.Newest(1).key == "ch:General", Gr.Newest(1) and Gr.Newest(1).key)
  check("no members, no newest", Gr.Newest(3) == nil, "?")

  local toast = T._toast()
  check("a member's loud message toasts at the group tile", toast and toast:IsShown() and toast.anchor == gtile and toast.convKey == "ch:General",
    toast and tostring(toast.convKey))
  toast:Hide()

  -- Hover peeks at the stack on the newest member.
  local hovered = "none"
  local savedHover = K.HoverEnter
  K.HoverEnter = function(key) hovered = key end
  gtile.scripts.OnEnter(gtile)
  K.HoverEnter = savedHover
  check("hovering a group tile peeks at its newest member", hovered == "ch:General", tostring(hovered))

  -- A click opens the card on the newest member, with tabs.
  Geometry(gtile, 870, 120, 30, 30)
  gtile.scripts.OnClick(gtile)
  check("a group click opens the card", f.root:IsShown(), "hidden")
  check("the genie starts from the group tile", G.IsPlaying() and G._current().from == gtile, "")
  G._overlay().scripts.OnUpdate(G._overlay(), 1)
  check("the card shows the newest member", C.ShownKey() == "ch:General", tostring(C.ShownKey()))
  check("the title names the group and the member",
    f.name.text == L_FMT("ECHO_GROUP_TITLE", A.L["ECHO_GROUP_CHANNELS"], V.DisplayName(S.Get("ch:General"))), f.name.text)
  local tabs = {}
  for _, t in ipairs(f.tabs) do if t:IsShown() then tabs[#tabs + 1] = t end end
  check("a tab per open member", #tabs == 2, #tabs)
  local tradeTab, generalTab
  for _, t in ipairs(tabs) do
    if t.convKey == "ch:Trade" then tradeTab = t elseif t.convKey == "ch:General" then generalTab = t end
  end
  check("tabs carry the members", tradeTab ~= nil and generalTab ~= nil, "?")
  check("a tab shows the member's short name", tradeTab.text.text == V.TileSpec(S.Get("ch:Trade")).label, tradeTab.text.text)
  local a = V.ACCENT
  local gf, tf = Fill(generalTab), Fill(tradeTab)
  check("the selected tab is filled with the accent", gf and gf[1] == a.r and gf[2] == a.g and gf[3] == a.b, gf and gf[1])
  check("an unselected tab is dim", tf and tf[1] ~= a.r, tf and tf[1])
  check("a tab is rounded with the small radius", rawget(generalTab, "_echoRound") ~= nil
    and rawget(generalTab, "_echoRound").corners.tl == Echo.Round.SMALL, "?")
  check("an unread member shows a dot", tradeTab.dot:IsShown(), "no dot")
  check("the selected member shows no dot", not generalTab.dot:IsShown(), "dot")
  check("the tab strip shows", f.tabStrip:IsShown(), "hidden")
  local top = f.area.points[1] and f.area.points[1][5]
  check("the message area starts below the strip", top == -(C.AREA_TOP + C.TAB_STRIP), tostring(top))

  -- The top row shows entries.
  local rowGroup, rowTrade
  for _, t in ipairs(f.rowTiles) do
    if t:IsShown() and t.convKey == "grp:1" then rowGroup = t end
    if t:IsShown() and t.convKey == "ch:Trade" then rowTrade = t end
  end
  check("the row shows a group entry", rowGroup ~= nil, "no group tile")
  check("the row shows no member tiles", rowTrade == nil, "member tile")
  local ob = rowGroup and Border(rowGroup)
  check("the shown group is outlined", ob and ob[1] == a.r and ob[4] == 1, ob and ob[1])

  -- Clicking a tab switches member and keeps drafts per member.
  f.edit:SetText("general draft")
  tradeTab.scripts.OnClick(tradeTab)
  check("a tab click switches member", C.ShownKey() == "ch:Trade", tostring(C.ShownKey()))
  check("the new member's box starts empty", f.edit:GetText() == "", f.edit:GetText())
  check("the title follows the member", f.name.text == L_FMT("ECHO_GROUP_TITLE", A.L["ECHO_GROUP_CHANNELS"], V.DisplayName(S.Get("ch:Trade"))), f.name.text)
  check("the tab reads Trade as read", S.Get("ch:Trade").unread == 0, S.Get("ch:Trade").unread)
  f.edit:SetText("trade draft")
  for _, t in ipairs(f.tabs) do if t.convKey == "ch:General" then generalTab = t end end
  generalTab.scripts.OnClick(generalTab)
  check("the first member's draft comes back", f.edit:GetText() == "general draft", f.edit:GetText())
  for _, t in ipairs(f.tabs) do if t.convKey == "ch:Trade" then tradeTab = t end end
  tradeTab.scripts.OnClick(tradeTab)
  check("the second member's draft comes back", f.edit:GetText() == "trade draft", f.edit:GetText())
  f.edit:SetText("")

  -- The toggle-close genie goes into the group tile; the card remembers the member.
  gtile.scripts.OnClick(gtile)
  check("a group toggle-close runs a reverse genie", G.IsPlaying() and G._current().reverse, "")
  check("into the group tile", G._current().from == gtile, "")
  G._overlay().scripts.OnUpdate(G._overlay(), 1)
  check("and hides the card", not f.root:IsShown(), "shown")
  C.Open("grp:1")
  check("reopening a group keeps the member last selected", C.ShownKey() == "ch:Trade", tostring(C.ShownKey()))
  C.Hide()

  -- A member key opens its group with that tab selected.
  C.Open("ch:General")
  check("a member opens as its group", C.ShownKey() == "ch:General" and f.tabStrip:IsShown(), tostring(C.ShownKey()))
  check("with the group title", f.name.text == L_FMT("ECHO_GROUP_TITLE", A.L["ECHO_GROUP_CHANNELS"], V.DisplayName(S.Get("ch:General"))), f.name.text)

  -- An ungrouped chat has no tabs and the normal area.
  C.Show("w:Brisa-Horizon")
  check("an ungrouped card hides the strip", not f.tabStrip:IsShown(), "shown")
  top = f.area.points[1] and f.area.points[1][5]
  check("and keeps the normal area", top == -C.AREA_TOP, tostring(top))
  check("and the plain title", f.name.text == "Brisa", f.name.text)

  -- Closing members through the menu.
  C.Show("grp:1")
  S.Close(C.ShownKey())
  local left = C.ShownKey()
  check("closing a member moves to the other", f.root:IsShown() and left ~= nil and S.Get(left).open and Gr.Of(left) == 1, tostring(left))
  S.Close(left)
  check("closing the last member hides the card", not f.root:IsShown(), "shown")

  -- Final fix 5: tabs never shrink below the 24px floor. (No GetStringWidth stub here, so
  -- every tab measures at Tab()'s 30px stand-in width, same as the earlier tabs above.)
  -- Twelve members share the strip evenly at exactly the 24px floor: all twelve fit, no
  -- overflow tab needed.
  S.Reset()
  db.echoGroupOf = {}
  local twelveIds = {
    "ch:General", "ch:Trade", "ch:Trade (Services)", "ch:LocalDefense", "ch:LookingForGroup",
    "ch:WorldDefense", "ch:NewcomerChat", "ch:*", "guild", "officer", "party", "raid",
  }
  for _, id in ipairs(twelveIds) do
    db.echoGroupOf[id] = 1
    S.Add({ convKey = id, text = "hi" })
  end
  C.Open("grp:1")
  local twelveShown, twelvePlus = 0, false
  for _, t in ipairs(f.tabs) do
    if t:IsShown() then
      if t.text.text:find("^%+%d+$") then twelvePlus = true else twelveShown = twelveShown + 1 end
    end
  end
  check("twelve members share the strip at exactly the 24px floor", twelveShown == 12 and not twelvePlus, twelveShown)

  -- Past the floor, only as many as fit are shown, plus a trailing "+N" tab for the rest.
  S.Reset()
  db.echoGroupOf = {}
  local manyIds = {
    "ch:General", "ch:Trade", "ch:Trade (Services)", "ch:LocalDefense", "ch:LookingForGroup",
    "ch:WorldDefense", "ch:NewcomerChat", "ch:*", "guild", "officer", "party", "raid",
    "instance", "loot", "progress", "system",
  }
  for _, id in ipairs(manyIds) do
    db.echoGroupOf[id] = 1
    S.Add({ convKey = id, text = "hi" })
  end
  C.Open("grp:1")
  local function VisibleTabs()
    local vshown, plus = {}, nil
    for _, t in ipairs(f.tabs) do
      if t:IsShown() then
        if t.text.text:find("^%+%d+$") then plus = t else vshown[#vshown + 1] = t end
      end
    end
    return vshown, plus
  end
  local mShown, mPlus = VisibleTabs()
  check("past the floor, only as many tabs fit as the strip allows", #mShown == 11, #mShown)
  check("the rest fold into a trailing +N tab", mPlus ~= nil and mPlus.text.text == "+5", mPlus and mPlus.text.text)
  local selectedShown = false
  for _, t in ipairs(mShown) do if t.convKey == C.ShownKey() then selectedShown = true end end
  check("the selected member is among the shown tabs", selectedShown, tostring(C.ShownKey()))

  -- Select a member folded into the overflow: it must be pulled back into the shown tabs.
  local hiddenKey
  for _, id in ipairs(manyIds) do
    local isShown = false
    for _, t in ipairs(mShown) do if t.convKey == id then isShown = true end end
    if not isShown then hiddenKey = id break end
  end
  check("there is a hidden member to select", hiddenKey ~= nil, "?")
  C.Show(hiddenKey)
  mShown, mPlus = VisibleTabs()
  local hiddenNowShown = false
  for _, t in ipairs(mShown) do if t.convKey == hiddenKey then hiddenNowShown = true end end
  check("selecting a folded member keeps it visible", hiddenNowShown, tostring(C.ShownKey()))
  check("still exactly one +N tab for the rest", mPlus ~= nil and mPlus.text.text == "+5", mPlus and mPlus.text.text)

  -- Clicking "+N" selects the first member it is folding in.
  local targetKey = mPlus.convKey
  mPlus.scripts.OnClick(mPlus)
  check("clicking +N selects the next hidden member", C.ShownKey() == targetKey, tostring(C.ShownKey()))

  C.Disable()
  K.Disable()
  T.Disable()
  G._reset()
  CreateFrame = savedCreateFrame
  rawset(A.L, "ECHO_GROUP_TITLE", nil)
  A.GetDB = nil
  A.ECHO_DEFAULTS, A.ECHO_KEYS, A.ECHO_LIMITS = nil, nil, nil
  Echo.ClearDrafts()
  S.Reset()
`, 'echo-group-card');

// --- Guild tabard: your own guild emblem on the Guild tile ------------------------------
run(`
  local Echo = HorizonSuite.Echo
  local V = Echo.View
  local saved = { IsInGuild = IsInGuild, C_GuildInfo = C_GuildInfo, GetTime = GetTime }

  local now = 1000
  GetTime = function() return now end

  -- Not in a guild: nil, no API call attempted.
  IsInGuild = function() return false end
  C_GuildInfo = { GetGuildTabardInfo = function() error("should not be called") end }
  V.ClearGuildTabardCache()
  check("not in a guild reads nil", V.GuildTabard() == nil, "?")

  -- No API on this client (Forever): nil.
  IsInGuild = function() return true end
  C_GuildInfo = nil
  V.ClearGuildTabardCache()
  check("no C_GuildInfo.GetGuildTabardInfo reads nil", V.GuildTabard() == nil, "?")

  -- A colour object exposing :GetRGB().
  local function ColorObj(r, g, b) return { GetRGB = function(self) return self.r, self.g, self.b end, r = r, g = g, b = b } end
  C_GuildInfo = {
    GetGuildTabardInfo = function(unit)
      if unit ~= "player" then return nil end
      return {
        emblemFileID = 12345,
        emblemColor = ColorObj(0.2, 0.4, 0.6),
        backgroundColor = ColorObj(0.9, 0.1, 0.3),
      }
    end,
  }
  V.ClearGuildTabardCache()
  local t1 = V.GuildTabard()
  check("tabard read via GetRGB: emblem", t1 and t1.emblem == 12345, t1)
  check("tabard read via GetRGB: emblem colour", t1 and t1.er == 0.2 and t1.eg == 0.4 and t1.eb == 0.6, t1)
  check("tabard read via GetRGB: background colour", t1 and t1.br == 0.9 and t1.bg == 0.1 and t1.bb == 0.3, t1)

  -- A cache hit within 5 seconds returns the same table without calling the API again.
  local calls = 0
  C_GuildInfo = {
    GetGuildTabardInfo = function()
      calls = calls + 1
      return { emblemFileID = 1, emblemColor = { r = 1, g = 1, b = 1 }, backgroundColor = { r = 1, g = 1, b = 1 } }
    end,
  }
  now = 1002
  local cached = V.GuildTabard()
  check("cache hit within 5s: same table", rawequal(cached, t1), "?")
  check("cache hit within 5s: API not called again", calls == 0, calls)

  now = 1005.5
  local refreshed = V.GuildTabard()
  check("cache expires after 5s: API called", calls == 1, calls)
  check("cache expires after 5s: new tabard reflects the fresh read", refreshed and refreshed.emblem == 1, refreshed)

  -- An event clears the cache immediately, before the 5s window elapses.
  now = 1005.6
  C_GuildInfo = {
    GetGuildTabardInfo = function()
      return { emblemFileID = 2, emblemColor = { r = 0, g = 0, b = 0 }, backgroundColor = { r = 0, g = 0, b = 0 } }
    end,
  }
  local stillCached = V.GuildTabard()
  check("still within the window: unchanged", stillCached and stillCached.emblem == 1, stillCached)
  V.ClearGuildTabardCache()
  local afterEvent = V.GuildTabard()
  check("cache cleared by an event: refreshes immediately", afterEvent and afterEvent.emblem == 2, afterEvent)

  -- A colour given as plain r/g/b fields (no :GetRGB()).
  C_GuildInfo = {
    GetGuildTabardInfo = function()
      return {
        emblemFileID = "tabard-path",
        emblemColor = { r = 0.5, g = 0.5, b = 0.25 },
        backgroundColor = { r = 0.1, g = 0.2, b = 0.3 },
      }
    end,
  }
  V.ClearGuildTabardCache()
  local t2 = V.GuildTabard()
  check("tabard read via r/g/b fields: emblem path", t2 and t2.emblem == "tabard-path", t2)
  check("tabard read via r/g/b fields: emblem colour", t2 and t2.er == 0.5 and t2.eg == 0.5 and t2.eb == 0.25, t2)
  check("tabard read via r/g/b fields: background colour", t2 and t2.br == 0.1 and t2.bg == 0.2 and t2.bb == 0.3, t2)

  -- A secret emblem ID: nil, never compared or typed.
  C_GuildInfo = {
    GetGuildTabardInfo = function()
      return { emblemFileID = SECRET(1), emblemColor = { r = 1, g = 1, b = 1 }, backgroundColor = { r = 1, g = 1, b = 1 } }
    end,
  }
  V.ClearGuildTabardCache()
  check("a secret emblem reads nil", V.GuildTabard() == nil, "?")

  -- emblemFileID missing or 0: nil.
  C_GuildInfo = {
    GetGuildTabardInfo = function()
      return { emblemFileID = 0, emblemColor = { r = 1, g = 1, b = 1 }, backgroundColor = { r = 1, g = 1, b = 1 } }
    end,
  }
  V.ClearGuildTabardCache()
  check("emblemFileID 0 reads nil", V.GuildTabard() == nil, "?")
  C_GuildInfo = {
    GetGuildTabardInfo = function() return { emblemColor = { r = 1, g = 1, b = 1 }, backgroundColor = { r = 1, g = 1, b = 1 } } end,
  }
  V.ClearGuildTabardCache()
  check("missing emblemFileID reads nil", V.GuildTabard() == nil, "?")

  -- Final fix 7: IsInGuild's truthiness accepts any truthy readable value, not only true.
  IsInGuild = function() return 1 end
  C_GuildInfo = {
    GetGuildTabardInfo = function(unit)
      if unit ~= "player" then return nil end
      local function ColorObj2(r, g, b) return { GetRGB = function(self) return self.r, self.g, self.b end, r = r, g = g, b = b } end
      return { emblemFileID = 777, emblemColor = ColorObj2(1, 1, 1), backgroundColor = ColorObj2(0, 0, 0) }
    end,
  }
  V.ClearGuildTabardCache()
  local truthyTabard = V.GuildTabard()
  check("a truthy non-boolean IsInGuild still reads the tabard", truthyTabard and truthyTabard.emblem == 777, truthyTabard)

  IsInGuild, C_GuildInfo, GetTime = saved.IsInGuild, saved.C_GuildInfo, saved.GetTime
  V.ClearGuildTabardCache()
`, 'echo-guild-tabard');

// --- Guild tile: the tabard face, its label, and the fallback G glyph -------------------
run(`
  local Echo = HorizonSuite.Echo
  local S, V = Echo.Store, Echo.View
  S.Reset()
  V.ClearGuildTabardCache()
  local saved = { IsInGuild = IsInGuild, C_GuildInfo = C_GuildInfo, GetTime = GetTime }

  -- No API at all (Forever): the G glyph, unchanged.
  IsInGuild = nil
  C_GuildInfo = nil
  GetTime = nil
  S.Add({ convKey = "guild", text = "gz" })
  local fallbackSpec = V.TileSpec(S.Get("guild"))
  check("no guild API: still the G glyph", fallbackSpec.face == "glyph" and fallbackSpec.letter == "G", fallbackSpec.face)

  -- A real tabard: face "tabard", the Guild label, and the background colour on the spec.
  local now = 2000
  GetTime = function() return now end
  IsInGuild = function() return true end
  C_GuildInfo = {
    GetGuildTabardInfo = function()
      return {
        emblemFileID = 999,
        emblemColor = { r = 0.25, g = 0.5, b = 0.75 },
        backgroundColor = { r = 0.6, g = 0.7, b = 0.8 },
      }
    end,
  }
  V.ClearGuildTabardCache()
  local tabardSpec = V.TileSpec(S.Get("guild"))
  check("with a tabard: face is tabard", tabardSpec.face == "tabard", tabardSpec.face)
  check("with a tabard: carries the tabard table", tabardSpec.tabard and tabardSpec.tabard.emblem == 999, "?")
  check("with a tabard: labelled Guild", tabardSpec.label == HorizonSuite.L["ECHO_KIND_GUILD"], tabardSpec.label)
  check("with a tabard: background colour on the spec", tabardSpec.r == 0.6 and tabardSpec.g == 0.7 and tabardSpec.b == 0.8, "?")

  -- FaceBackground follows the tabard's background colour at alpha 0.95 (the genie colour
  -- rides on this automatically, EchoCard.GenieColor -> FaceBackground).
  local fr, fg, fb, fa = V.FaceBackground(tabardSpec)
  check("FaceBackground: tabard background colour", fr == 0.6 and fg == 0.7 and fb == 0.8, "?")
  check("FaceBackground: alpha 0.95", fa == 0.95, fa)

  IsInGuild, C_GuildInfo, GetTime = saved.IsInGuild, saved.C_GuildInfo, saved.GetTime
  V.ClearGuildTabardCache()
  S.Reset()
`, 'echo-guild-tile-tabard');

// --- Painter: the tabard face paints the emblem, and a later paint resets the tint ------
run(`
  CreateFrame = STUB_CREATE_FRAME
  local Echo = HorizonSuite.Echo
  local icon = STUB_FRAME()
  local face = { icon = icon }

  local tabardSpec = {
    face = "tabard",
    tabard = { emblem = "Interface\\\\TabardEmblems\\\\Emblem_1", er = 0.3, eg = 0.6, eb = 0.9 },
  }
  Echo.PaintTileFace(face, tabardSpec)
  check("tabard paint: texture is the emblem", icon.texture == tabardSpec.tabard.emblem, icon.texture)
  check("tabard paint: full texcoords", icon.texCoord and icon.texCoord[1] == 0 and icon.texCoord[2] == 1, "?")
  check("tabard paint: vertex colour is the emblem colour", icon.vertexColor
        and icon.vertexColor[1] == 0.3 and icon.vertexColor[2] == 0.6 and icon.vertexColor[3] == 0.9
        and icon.vertexColor[4] == 1, icon.vertexColor)
  check("tabard paint: shown", icon.shown == true, "?")

  -- A recycled tile painting something else afterwards loses the emblem tint.
  local iconSpec = { face = "icon", icon = "Interface\\\\Icons\\\\INV_Misc_Coin_01" }
  Echo.PaintTileFace(face, iconSpec)
  check("a later icon paint resets the vertex colour to white", icon.vertexColor
        and icon.vertexColor[1] == 1 and icon.vertexColor[2] == 1 and icon.vertexColor[3] == 1
        and icon.vertexColor[4] == 1, icon.vertexColor)

  Echo.PaintTileFace(face, tabardSpec)
  local letterSpec = { face = "letter", letter = "B", r = 1, g = 1, b = 1 }
  Echo.PaintTileFace(face, letterSpec)
  check("a later non-icon paint also resets the vertex colour to white", icon.vertexColor
        and icon.vertexColor[1] == 1 and icon.vertexColor[2] == 1 and icon.vertexColor[3] == 1
        and icon.vertexColor[4] == 1, icon.vertexColor)
`, 'echo-tabard-painter');

// --- Dashboard: the module icon path helper (a pure function, since the dashboard file
// itself needs a full DashboardHomeWelcome_Init env this harness doesn't build) ------------
{
  const dashSrc = read('options/dashboard/DashboardHomeWelcome.lua');
  const startMarker = '-- ECHO_ICON_PATH_HELPER_START';
  const endMarker = '-- ECHO_ICON_PATH_HELPER_END';
  const startIdx = dashSrc.indexOf(startMarker);
  const endIdx = dashSrc.indexOf(endMarker);
  if (startIdx === -1 || endIdx === -1 || endIdx < startIdx) {
    console.error('echo-dashboard-icon-path: could not find the ModuleIconPath helper markers');
    process.exit(1);
  }
  const helperSrc = dashSrc.slice(startIdx + startMarker.length, endIdx);
  run(`
    ${helperSrc}
    check("a path with a backslash is used as-is",
      ModuleIconPath("Interface\\\\AddOns\\\\HorizonSuite\\\\media\\\\echo\\\\echo_icon.tga")
        == "Interface\\\\AddOns\\\\HorizonSuite\\\\media\\\\echo\\\\echo_icon.tga", "?")
    check("a bare icon name is prefixed with Interface\\\\Icons\\\\",
      ModuleIconPath("inv_letter_15") == "Interface\\\\Icons\\\\inv_letter_15", "?")
    check("a nil icon falls back to the question-mark icon",
      ModuleIconPath(nil) == "Interface\\\\Icons\\\\INV_Misc_Question_01", "?")
  `, 'echo-dashboard-icon-path');
}

// --- Guild emblem: Blizzard's painter, centred above the name ---------------------------
run(`
  CreateFrame = STUB_CREATE_FRAME
  local Echo = HorizonSuite.Echo
  local host = STUB_FRAME()
  local icon = host:CreateTexture()
  icon.GetParent = function() return host end
  local spec = { face = "tabard", tabard = { emblem = 123, er = 1, eg = 0, eb = 0, br = 0, bg = 0, bb = 1 }, label = "Guild", r = 0, g = 0, b = 1 }
  local called
  SetSmallGuildTabardTextures = function(unit, emblem, bgTex, borderTex) called = { unit, emblem, bgTex, borderTex } end
  Echo.PaintTileFace({ icon = icon, letter = STUB_FRAME(), size = 16, smallSize = 10, flags = "" }, spec)
  check("Blizzard's tabard painter draws the emblem", called and called[1] == "player" and called[2] == icon, "not called")
  check("its spare textures stay hidden", called and not called[3].shown and not called[4].shown, "shown")
  SetSmallGuildTabardTextures = function() error("boom") end
  local tex
  icon.SetTexture = function(self, t) tex = t end
  Echo.PaintTileFace({ icon = icon, letter = STUB_FRAME(), size = 16, smallSize = 10, flags = "" }, spec)
  check("a failing Blizzard painter falls back to the raw emblem", tex == 123, tex)
  icon.SetTexture = nil
  SetSmallGuildTabardTextures = nil
`, 'guild-emblem-painter');

// --- Panels open on the side with room -------------------------------------------------
run(`
  local V = HorizonSuite.Echo.View
  local db = { echoColumnEdge = "right" }
  HorizonSuite.GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  local col = STUB_FRAME()
  _G.HorizonSuiteEchoColumn = col
  col.GetScale = function() return 1 end
  UIParent.GetWidth = function() return 1920 end
  -- A column dragged to the far left, with the edge still set to Right.
  col.GetLeft = function() return 20 end
  col.GetRight = function() return 60 end
  check("no room on the left: the card opens to the right", V.PanelEdge(360) == "left", V.PanelEdge(360))
  -- Room on the usual side: keep it.
  col.GetLeft = function() return 1500 end
  col.GetRight = function() return 1540 end
  check("room on the left: the usual side is kept", V.PanelEdge(360) == "right", V.PanelEdge(360))
  -- Left edge at the far right of the screen: flip to open leftwards.
  db.echoColumnEdge = "left"
  col.GetLeft = function() return 1860 end
  col.GetRight = function() return 1900 end
  check("no room on the right: the card opens to the left", V.PanelEdge(360) == "right", V.PanelEdge(360))
  -- Neither side fits: keep the edge.
  UIParent.GetWidth = function() return 400 end
  col.GetLeft = function() return 180 end
  col.GetRight = function() return 220 end
  check("no room either side: the edge stands", V.PanelEdge(360) == "left", V.PanelEdge(360))
  -- A bigger scale needs more room.
  UIParent.GetWidth = function() return 1920 end
  db.echoColumnEdge = "right"
  col.GetScale = function() return 2 end
  col.GetLeft = function() return 150 end
  col.GetRight = function() return 170 end
  check("scale counts: 300 px left of a 2x column is too little for 360", V.PanelEdge(360) == "left", V.PanelEdge(360))
  check("no column: the edge stands", (function() _G.HorizonSuiteEchoColumn = nil; return V.PanelEdge(360) end)() == "right", "")
  UIParent.GetWidth = nil
  HorizonSuite.GetDB = nil
`, 'panel-edge-room');

// --- History & Store: pin messages in any chat (plan 10, Task 3) ------------------------
run(`
  local S, H = HorizonSuite.Echo.Store, HorizonSuite.Echo.History
  S.Reset()
  local db = {}
  local charKey = "Kaelis-Horizon"
  H.Bind(db, function() return charKey end)

  -- Pinning a channel line saves it even though channels are never persisted.
  local ok, reason = S.PinMessage("ch:Trade", { text = "wts widget", time = 100, sender = "Brisa-Horizon" })
  check("a channel pin succeeds", ok == true, tostring(reason))
  local pins = S.Pins("ch:Trade")
  check("the channel pin is saved", #pins == 1 and pins[1].text == "wts widget" and pins[1].sender == "Brisa-Horizon", pins[1] and pins[1].text)
  check("pins are stored under root.pins by the channel's own key", db.echoHistory.pins["Kaelis-Horizon"]["ch:Trade"][1].text == "wts widget", "missing")

  -- A secret record is rejected.
  ok, reason = S.PinMessage("ch:Trade", { text = SECRET("hush"), time = 200 })
  check("a secret text pin is rejected", ok == false and reason == "secret", tostring(reason))
  ok, reason = S.PinMessage("ch:Trade", { text = "ok", time = 201, secret = true })
  check("record.secret alone is rejected", ok == false and reason == "secret", tostring(reason))

  -- A duplicate pin (same t, text, s) is not added twice.
  ok, reason = S.PinMessage("ch:Trade", { text = "wts widget", time = 100, sender = "Brisa-Horizon" })
  check("re-pinning the same message succeeds without duplicating", ok == true, tostring(reason))
  check("no duplicate was added", #S.Pins("ch:Trade") == 1, #S.Pins("ch:Trade"))

  -- The 6th pin in one chat is rejected with "chat".
  for i = 2, 5 do
    S.PinMessage("ch:Trade", { text = "m" .. i, time = 100 + i })
  end
  check("five pins fit in one chat", #S.Pins("ch:Trade") == 5, #S.Pins("ch:Trade"))
  ok, reason = S.PinMessage("ch:Trade", { text = "sixth", time = 900 })
  check("the 6th pin in a chat is rejected", ok == false and reason == "chat", tostring(reason))

  -- The 51st pin overall (across chats, same character) is rejected with "total".
  for c = 2, 10 do
    for i = 1, 5 do
      S.PinMessage("ch:Chat" .. c, { text = "m" .. c .. "-" .. i, time = c * 1000 + i })
    end
  end
  local totalBefore = 0
  for _, list in pairs(db.echoHistory.pins["Kaelis-Horizon"]) do totalBefore = totalBefore + #list end
  check("50 pins exist across chats", totalBefore == 50, totalBefore)
  ok, reason = S.PinMessage("ch:Chat11", { text = "overflow", time = 99999 })
  check("the 51st pin overall is rejected", ok == false and reason == "total", tostring(reason))

  -- Unpin removes by index.
  ok = S.UnpinMessage("ch:Trade", 1)
  check("unpin removes the first pin", ok == true and #S.Pins("ch:Trade") == 4, ok)
  check("unpin removed the right entry", S.Pins("ch:Trade")[1].text == "m2", S.Pins("ch:Trade")[1] and S.Pins("ch:Trade")[1].text)
  check("an out-of-range unpin fails", S.UnpinMessage("ch:Trade", 99) == false, "removed")

  -- Battle.net pins are keyed by BattleTag and never store the |K sender.
  S.Reset()
  db = {}
  H.Bind(db, function() return charKey end)
  local savedBattleNet = C_BattleNet
  C_BattleNet = { GetAccountInfoByID = function(id) if id == 77 then return { battleTag = "Vexa#1234" } end end }
  ok, reason = S.PinMessage("bn:77", { text = "hi there", time = 300, sender = "|Kbnet-protected-string" })
  check("a battle.net pin succeeds", ok == true, tostring(reason))
  local bnetPins = db.echoHistory.pins["Kaelis-Horizon"]["bt:Vexa#1234"]
  check("battle.net pins are keyed by battletag", bnetPins and #bnetPins == 1, bnetPins and #bnetPins)
  check("a battle.net pin never stores the sender", bnetPins[1].s == nil, bnetPins[1].s)
  check("Store.Pins reflects the battletag key", S.Pins("bn:77")[1].text == "hi there" and S.Pins("bn:77")[1].sender == nil, "?")
  check("a live battle.net line matches its pin despite the |K sender", S.IsPinnedMessage("bn:77", { text = "hi there", time = 300, sender = "|Kbnet-protected-string" }) == true, "no match")

  -- An unreadable battletag can't be saved.
  C_BattleNet = { GetAccountInfoByID = function() return nil end }
  ok, reason = S.PinMessage("bn:404", { text = "no tag", time = 301 })
  check("an unreadable battletag is unsaved", ok == false and reason == "unsaved", tostring(reason))
  C_BattleNet = savedBattleNet

  -- No character key: unsaved.
  charKey = nil
  ok, reason = S.PinMessage("ch:Trade", { text = "no char", time = 302 })
  check("no character key is unsaved", ok == false and reason == "unsaved", tostring(reason))
  charKey = "Kaelis-Horizon"

  -- IsPinnedMessage matches by time, text and sender (a nil sender matches nil).
  S.Reset()
  db = {}
  H.Bind(db, function() return charKey end)
  S.PinMessage("w:Brisa-Horizon", { text = "hello", time = 500, sender = "Brisa-Horizon" })
  check("IsPinnedMessage matches the pinned record", S.IsPinnedMessage("w:Brisa-Horizon", { text = "hello", time = 500, sender = "Brisa-Horizon" }) == true, "no match")
  check("IsPinnedMessage rejects a different time", S.IsPinnedMessage("w:Brisa-Horizon", { text = "hello", time = 999, sender = "Brisa-Horizon" }) == false, "matched")
  check("IsPinnedMessage rejects a different sender", S.IsPinnedMessage("w:Brisa-Horizon", { text = "hello", time = 500, sender = "Someone-Else" }) == false, "matched")
  S.PinMessage("w:Feral-Horizon", { text = "no sender", time = 600 })
  check("a nil sender matches nil", S.IsPinnedMessage("w:Feral-Horizon", { text = "no sender", time = 600 }) == true, "no match")

  -- Pins survive History.Prune.
  H.SetMaxAge(30)
  local now = 40 * 86400 + 1000
  H.Append("w:Brisa-Horizon", { text = "hello", time = now - 40 * 86400 })
  H.Prune(now)
  check("pins survive History.Prune", #S.Pins("w:Brisa-Horizon") == 1, #S.Pins("w:Brisa-Horizon"))

  -- Pins survive a Store message-cap trim.
  S.Reset()
  db = {}
  H.Bind(db, function() return charKey end)
  S.PinMessage("w:Brisa-Horizon", { text = "keepsake", time = 1 })
  for i = 1, 150 do S.Add({ convKey = "w:Brisa-Horizon", text = "m" .. i }) end
  check("a message-cap trim doesn't affect pins", #S.Pins("w:Brisa-Horizon") == 1 and S.Pins("w:Brisa-Horizon")[1].text == "keepsake", #S.Pins("w:Brisa-Horizon"))

  -- Pinning and unpinning notify with "update".
  local notified = {}
  local function listener(convKey, change) notified[#notified + 1] = { convKey, change } end
  S.Subscribe(listener)
  S.PinMessage("w:Brisa-Horizon", { text = "another", time = 2 })
  check("pinning notifies update", notified[#notified][1] == "w:Brisa-Horizon" and notified[#notified][2] == "update", notified[#notified] and notified[#notified][2])
  S.UnpinMessage("w:Brisa-Horizon", 1)
  check("unpinning notifies update", notified[#notified][1] == "w:Brisa-Horizon" and notified[#notified][2] == "update", notified[#notified] and notified[#notified][2])
  S.Unsubscribe(listener)

  -- Clear wipes pins.
  H.Clear()
  check("clear wipes pins", next(db.echoHistory.pins) == nil, "kept")

  H.Unbind()
  S.Reset()
`, 'history-store-pins');

// --- Card: pins on the card (plan 10, Task 4) ---------------------------------------------
{
  const tgaPath = REPO + 'media/echo/pin.tga';
  const tga = fs.existsSync(tgaPath) ? fs.readFileSync(tgaPath) : Buffer.alloc(0);
  const ok = tga.length === 18 + 32 * 32 * 4 && tga[2] === 2 && tga.readUInt16LE(12) === 32
    && tga.readUInt16LE(14) === 32 && tga[16] === 32 && tga[17] === 8;
  let alpha = 0, partial = 0, colour = true;
  for (let i = 18; i < tga.length; i += 4) {
    if (tga[i + 3] > 0) alpha++;
    if (tga[i + 3] > 0 && tga[i + 3] < 255) partial++;
    if (tga[i + 3] > 0 && (tga[i] !== 255 || tga[i + 1] !== 255 || tga[i + 2] !== 255)) colour = false;
  }
  run(`check("pin.tga is a 32x32 32-bit TGA like circle.tga", ${ok}, "bad header")
       check("pin.tga is a white shape with anti-aliased alpha", ${alpha > 60 && partial > 10 && colour}, "${alpha}/${partial}/${colour}")`, 'pin-tga');
}
run(read('options/modules/defaults/OptionsDefaultsEcho.lua'), 'echo-defaults-card-pins');
run(`
  local A = HorizonSuite
  local Echo = A.Echo
  local S, H, T, K, C, M, V = Echo.Store, Echo.History, Echo.Tiles, Echo.Stack, Echo.Card, Echo.Menu, Echo.View
  S.Reset()
  Echo.ClearDrafts()
  local savedCreateFrame = CreateFrame
  CreateFrame = STUB_CREATE_FRAME
  local db = {}
  A.GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  local saved = {}
  H.Bind(saved, function() return "Kaelis-Horizon" end)
  local clock = 1000
  local savedNow = S.Now
  S.Now = function() clock = clock + 1; return clock end
  T.Enable()
  K.Enable()
  C.Enable()
  local f = C._frames()
  local a = V.ACCENT
  rawset(A.L, "ECHO_PIN_COUNTER", "%d/%d")

  -- A fake MenuUtil root that records what the menu builds.
  local function FakeRoot()
    local r = { items = {} }
    function r:CreateButton(label, fn)
      local b = { label = label, fn = fn, enabled = true }
      function b:SetEnabled(v) self.enabled = v end
      self.items[#self.items + 1] = b
      return b
    end
    function r:CreateTitle(label) self.items[#self.items + 1] = { label = label, title = true } end
    function r:CreateDivider() end
    return r
  end
  local function Build(key, record)
    local r = FakeRoot()
    M.BuildMessage(r, key, record)
    return r.items
  end

  for i = 1, 3 do S.Add({ convKey = "w:Brisa-Horizon", text = "line " .. i, sender = "Brisa-Horizon" }) end
  C.Open("w:Brisa-Horizon")
  local conv = S.Get("w:Brisa-Horizon")

  -- The strip hides with no pins, and the area sits at the plain top.
  check("no pins, no strip", f.pinStrip ~= nil and not f.pinStrip:IsShown(), "shown")
  check("no pins, the area sits under the header", f.area.points[1][5] == -C.AREA_TOP, tostring(f.area.points[1][5]))
  check("the strip height and offset", C.PIN_STRIP == 22 + 4, tostring(C.PIN_STRIP))

  -- Right-click a bubble: the menu offers Pin on an unpinned readable message.
  local opened
  local savedMenuUtil = MenuUtil
  MenuUtil = { CreateContextMenu = function(owner, gen) opened = { owner, gen } end }
  local b1 = f.bubbles[1]
  check("a bubble listens for mouse-up", type(b1.scripts.OnMouseUp) == "function", "no script")
  b1.scripts.OnMouseUp(b1, "LeftButton")
  check("a left click opens no menu", opened == nil, "opened")
  -- The menu opens a frame later, so a link click in the same frame can cancel it.
  local savedTimer, savedGetTime = C_Timer, GetTime
  local frameTime, deferred = 50, {}
  GetTime = function() return frameTime end
  C_Timer = { After = function(_, fn) deferred[#deferred + 1] = fn end, NewTimer = savedTimer.NewTimer }
  local function Flush()
    local q = deferred
    deferred = {}
    for _, fn in ipairs(q) do fn() end
  end
  local function LinkClick(b)
    if b.scripts.OnHyperlinkClick then b.scripts.OnHyperlinkClick(b, "item:1", "[x]", "RightButton") end
    if b.hookScripts.OnHyperlinkClick then b.hookScripts.OnHyperlinkClick(b, "item:1", "[x]", "RightButton") end
  end
  b1.scripts.OnMouseUp(b1, "RightButton")
  check("a right click waits a frame", opened == nil and #deferred == 1, #deferred)
  Flush()
  check("a right click opens the message menu", opened ~= nil and opened[1] == b1, "not opened")
  check("links still click through", type(b1.scripts.OnHyperlinkClick) == "function", "no link click")
  opened = nil
  frameTime = 51
  LinkClick(b1)
  b1.scripts.OnMouseUp(b1, "RightButton")
  Flush()
  check("a link click then mouse-up opens no menu", opened == nil, "opened")
  frameTime = 52
  b1.scripts.OnMouseUp(b1, "RightButton")
  LinkClick(b1)
  Flush()
  check("mouse-up then a link click opens no menu", opened == nil, "opened")
  frameTime = 53
  b1.scripts.OnMouseUp(b1, "RightButton")
  Flush()
  check("a later plain right-click opens it", opened ~= nil and opened[1] == b1, "not opened")
  -- The link click counts for 0.3 seconds either side, not only in the same frame.
  opened = nil
  frameTime = 60
  LinkClick(b1)
  frameTime = 60.2
  b1.scripts.OnMouseUp(b1, "RightButton")
  Flush()
  check("a link click just before mouse-up opens no menu", opened == nil, "opened")
  frameTime = 61
  b1.scripts.OnMouseUp(b1, "RightButton")
  frameTime = 61.1
  LinkClick(b1)
  Flush()
  check("a link click a frame after mouse-up opens no menu", opened == nil, "opened")
  frameTime = 70
  LinkClick(b1)
  frameTime = 70.5
  b1.scripts.OnMouseUp(b1, "RightButton")
  Flush()
  check("a right-click well after a link click opens the menu", opened ~= nil and opened[1] == b1, "not opened")
  C_Timer = nil
  opened = nil
  frameTime = 80
  b1.scripts.OnMouseUp(b1, "RightButton")
  check("without C_Timer the menu opens at once", opened ~= nil and opened[1] == b1, "not opened")
  C_Timer = { After = function(_, fn) deferred[#deferred + 1] = fn end, NewTimer = savedTimer.NewTimer }
  local r = FakeRoot()
  opened[2](opened[1], r)
  check("the menu offers Pin on an unpinned message", #r.items == 2 and r.items[2].label == "ECHO_INVITE_NAME" and r.items[1].label == "ECHO_PIN_MESSAGE" and r.items[1].enabled, r.items[1] and r.items[1].label)

  -- Pinning shows the strip and moves the area down.
  r.items[1].fn()
  check("pinning saves the pin", #S.Pins("w:Brisa-Horizon") == 1 and S.Pins("w:Brisa-Horizon")[1].text == "line 3", #S.Pins("w:Brisa-Horizon"))
  check("pinning shows the strip", f.pinStrip:IsShown(), "hidden")
  check("the area moves down by the strip", f.area.points[1][5] == -(C.AREA_TOP + C.PIN_STRIP), tostring(f.area.points[1][5]))
  check("the strip sits under the header", f.pinStrip.points[1][5] == -C.AREA_TOP, tostring(f.pinStrip.points[1][5]))
  check("the strip is 22px high and spans the card", C.PIN_HEIGHT == 22 and f.pinStrip.points[2] and f.pinStrip.points[2][1] == "TOPRIGHT", tostring(C.PIN_HEIGHT))
  local stripRR = rawget(f.pinStrip, "_echoRound")
  check("the strip is rounded with the small radius", stripRR ~= nil and stripRR.corners.tl == Echo.Round.SMALL, "?")
  local tint = stripRR and stripRR.fill.topBand.vertexColor
  check("the strip is a dim accent tint", tint and tint[1] == a.r and tint[2] == a.g and tint[3] == a.b and tint[4] < 0.5, tint and tint[4])
  check("the strip shows the pinned text", f.pinStrip.label.text.text == "line 3", f.pinStrip.label.text.text)
  check("the strip shows the pin icon", f.pinStrip.icon.texture ~= nil and f.pinStrip.icon.texture:find("pin.tga", 1, true) ~= nil, tostring(f.pinStrip.icon.texture))
  check("one pin, no counter", not f.pinStrip.counter:IsShown(), "shown")

  -- A pinned bubble shows the marker; the others don't.
  check("the pinned bubble shows the marker", f.bubbles[1].pin:IsShown(), "hidden")
  check("the marker is the pin icon, 10px, in the accent", f.bubbles[1].pin.width == 10 and f.bubbles[1].pin.texture:find("pin.tga", 1, true)
    and f.bubbles[1].pin.vertexColor[1] == a.r, "?")
  local mp = f.bubbles[1].pin.points[1]
  check("the marker sits inside the top corner away from the sender", mp[1] == "TOPRIGHT" and mp[3] == "TOPRIGHT" and mp[4] == -3 and mp[5] == -3,
    tostring(mp[1]) .. " " .. tostring(mp[4]) .. " " .. tostring(mp[5]))
  local tp = f.bubbles[1].text.points[1]
  check("their pinned text keeps its left inset", tp[4] == C.BUBBLE_PAD, tostring(tp[4]))
  check("their pinned text stops short of the marker", f.bubbles[1].text.setWidth <= f.bubbles[1].width - C.BUBBLE_PAD - (3 + C.PIN_MARK + 2),
    tostring(f.bubbles[1].text.setWidth) .. "/" .. tostring(f.bubbles[1].width))
  check("an unpinned bubble's text uses the plain insets", f.bubbles[2].text.points[1][4] == C.BUBBLE_PAD
    and f.bubbles[2].text.setWidth == f.bubbles[2].width - C.BUBBLE_PAD * 2, tostring(f.bubbles[2].text.setWidth))
  check("an unpinned bubble shows none", not f.bubbles[2].pin:IsShown(), "shown")

  -- The menu now offers Unpin, and Unpin works.
  local items = Build("w:Brisa-Horizon", conv.messages[3])
  check("the menu offers Unpin on a pinned message", #items == 2 and items[2].label == "ECHO_INVITE_NAME" and items[1].label == "ECHO_UNPIN_MESSAGE", items[1] and items[1].label)

  -- Disabled reasons.
  items = Build("w:Brisa-Horizon", { text = SECRET("hush"), secret = true, time = 5 })
  check("a secret message shows the hidden reason, disabled", items[1] and items[1].label == "ECHO_PIN_BLOCKED_SECRET" and items[1].enabled == false, items[1] and items[1].label)
  check("PinBlockReason agrees", S.PinBlockReason("w:Brisa-Horizon", { text = "x", secret = true }) == "secret", tostring(S.PinBlockReason("w:Brisa-Horizon", { text = "x", secret = true })))
  for i = 1, 4 do S.PinMessage("w:Full-Horizon", { text = "p" .. i, time = i }) end
  check("four pins leave room", S.PinBlockReason("w:Full-Horizon", { text = "p5", time = 5 }) == nil, "blocked")
  S.PinMessage("w:Full-Horizon", { text = "p5", time = 5 })
  items = Build("w:Full-Horizon", { text = "p6", time = 6 })
  check("a full chat shows the chat reason, disabled", items[1] and items[1].label == "ECHO_PIN_BLOCKED_CHAT" and items[1].enabled == false, items[1] and items[1].label)
  items = Build("w:Full-Horizon", { text = "p5", time = 5 })
  check("a full chat still offers Unpin on its own pins", items[1] and items[1].label == "ECHO_UNPIN_MESSAGE", items[1] and items[1].label)
  for c = 1, 9 do
    for i = 1, 5 do S.PinMessage("ch:Chan" .. c, { text = "q" .. i, time = i }) end
  end
  items = Build("w:Brisa-Horizon", conv.messages[2])
  check("the total limit shows the total reason, disabled", items[1] and items[1].label == "ECHO_PIN_BLOCKED_TOTAL" and items[1].enabled == false, items[1] and items[1].label)
  H.Bind(saved, function() return nil end)
  items = Build("w:Brisa-Horizon", conv.messages[2])
  check("an unsaveable chat shows the unsaved reason, disabled", items[1] and items[1].label == "ECHO_PIN_BLOCKED_UNSAVED" and items[1].enabled == false, items[1] and items[1].label)
  H.Bind(saved, function() return "Kaelis-Horizon" end)
  for c = 1, 9 do for i = 5, 1, -1 do S.UnpinMessage("ch:Chan" .. c, i) end end
  for i = 5, 1, -1 do S.UnpinMessage("w:Full-Horizon", i) end

  -- Three pins: the counter steps to older ones and wraps.
  S.PinMessage("w:Brisa-Horizon", conv.messages[1])
  S.PinMessage("w:Brisa-Horizon", conv.messages[2])
  -- Pins are oldest-first by when they were pinned: line 3, line 1, line 2.
  check("the strip starts on the newest pin", f.pinStrip.label.text.text == "line 2", f.pinStrip.label.text.text)
  check("two or more pins show the counter", f.pinStrip.counter:IsShown() and f.pinStrip.counter.text.text == "1/3", f.pinStrip.counter.text.text)
  f.pinStrip.counter.scripts.OnClick(f.pinStrip.counter)
  check("the counter steps to the next older pin", f.pinStrip.label.text.text == "line 1" and f.pinStrip.counter.text.text == "2/3", f.pinStrip.label.text.text)
  f.pinStrip.counter.scripts.OnClick(f.pinStrip.counter)
  check("and again", f.pinStrip.label.text.text == "line 3" and f.pinStrip.counter.text.text == "3/3", f.pinStrip.label.text.text)
  f.pinStrip.counter.scripts.OnClick(f.pinStrip.counter)
  check("the counter wraps to the newest", f.pinStrip.label.text.text == "line 2" and f.pinStrip.counter.text.text == "1/3", f.pinStrip.label.text.text)

  -- The text click scrolls to the pinned message.
  for i = 4, 30 do S.Add({ convKey = "w:Brisa-Horizon", text = "line " .. i, sender = "Brisa-Horizon" }) end
  f.pinStrip.counter.scripts.OnClick(f.pinStrip.counter)  -- line 1
  f.pinStrip.label.scripts.OnClick(f.pinStrip.label)
  check("the text click scrolls to the pinned message", f.bubbles[1].text.text == "line 1", f.bubbles[1].text.text)
  check("and marks it", f.bubbles[1].pin:IsShown(), "hidden")

  -- Hovering the text shows the full message, sender and time.
  local lines, owner = {}, nil
  local savedTooltip = GameTooltip
  GameTooltip = {
    SetOwner = function(_, o) owner = o end,
    ClearLines = function() lines = {} end,
    AddLine = function(_, t) lines[#lines + 1] = t end,
    AddDoubleLine = function(_, l, rr) lines[#lines + 1] = l; lines[#lines + 1] = rr end,
    SetText = function(_, t) lines = { t } end,
    Show = function() end,
    Hide = function() end,
  }
  local savedDate = date
  date = os and os.date or date
  f.pinStrip.label.scripts.OnEnter(f.pinStrip.label)
  local joined = table.concat(lines, "|")
  check("the tooltip shows the message", owner == f.pinStrip.label and joined:find("line 1", 1, true) ~= nil, joined)
  check("the tooltip shows the sender", joined:find("Brisa", 1, true) ~= nil, joined)
  local stamp = V.PinTime(conv.messages[1].time)
  check("the tooltip shows the time", stamp ~= "" and joined:find(stamp, 1, true) ~= nil, joined)
  f.pinStrip.label.scripts.OnLeave(f.pinStrip.label)
  date = savedDate
  GameTooltip = savedTooltip

  -- A message no longer in the conversation: the text click does nothing. A fresh save
  -- keeps only the pins, so the old lines don't load back.
  S.Reset()
  saved = { echoHistory = { pins = saved.echoHistory.pins } }
  H.Bind(saved, function() return "Kaelis-Horizon" end)
  S.Add({ convKey = "w:Brisa-Horizon", text = "fresh", sender = "Brisa-Horizon" })
  C.Open("w:Brisa-Horizon")
  check("pins outlive the messages they point at", f.pinStrip:IsShown(), "hidden")
  local ok = pcall(f.pinStrip.label.scripts.OnClick, f.pinStrip.label)
  check("a click on a gone message does nothing", ok and f.bubbles[1].text.text == "fresh", f.bubbles[1].text.text)

  -- The x unpins the shown pin; the strip hides with the last one.
  check("the x unpins the shown pin", (function()
    f.pinStrip.close.scripts.OnClick(f.pinStrip.close)
    return #S.Pins("w:Brisa-Horizon") == 2
  end)(), #S.Pins("w:Brisa-Horizon"))
  f.pinStrip.close.scripts.OnClick(f.pinStrip.close)
  f.pinStrip.close.scripts.OnClick(f.pinStrip.close)
  check("the strip hides with the last pin", #S.Pins("w:Brisa-Horizon") == 0 and not f.pinStrip:IsShown(), #S.Pins("w:Brisa-Horizon"))
  check("the area moves back up", f.area.points[1][5] == -C.AREA_TOP, tostring(f.area.points[1][5]))

  -- A reused bubble clears the marker.
  S.Add({ convKey = "w:Brisa-Horizon", text = "keep me", sender = "Brisa-Horizon" })
  local keep = S.Get("w:Brisa-Horizon").messages[2]
  S.PinMessage("w:Brisa-Horizon", keep)
  check("the pinned newest bubble is marked", f.bubbles[1].pin:IsShown(), "hidden")
  S.Add({ convKey = "w:Brisa-Horizon", text = "later", sender = "Brisa-Horizon" })
  check("the reused bottom bubble clears the marker", f.bubbles[1].text.text == "later" and not f.bubbles[1].pin:IsShown(), "shown")
  check("the marker moves with its message", f.bubbles[2].pin:IsShown(), "hidden")

  -- Your own pinned bubble is marked on the left.
  S.Add({ convKey = "w:Brisa-Horizon", text = "mine", outgoing = true })
  S.PinMessage("w:Brisa-Horizon", S.Get("w:Brisa-Horizon").messages[4])
  mp = f.bubbles[1].pin.points[1]
  check("your bubble's marker sits inside the top-left", f.bubbles[1].pin:IsShown() and mp[1] == "TOPLEFT" and mp[4] == 3 and mp[5] == -3, tostring(mp and mp[1]))
  check("your pinned text moves in past the marker", f.bubbles[1].text.points[1][4] >= 3 + C.PIN_MARK + 2, tostring(f.bubbles[1].text.points[1][4]))
  S.Add({ convKey = "w:Brisa-Horizon", text = "after", outgoing = true })
  check("a reused bubble's text goes back to the plain inset", f.bubbles[1].text.points[1][4] == C.BUBBLE_PAD
    and not f.bubbles[1].pin:IsShown(), tostring(f.bubbles[1].text.points[1][4]))
  check("the pinned bubble moved up keeps its inset", f.bubbles[2].pin:IsShown() and f.bubbles[2].text.points[1][4] >= 3 + C.PIN_MARK + 2, tostring(f.bubbles[2].text.points[1][4]))

  -- Switching conversations starts the strip on the newest pin.
  f.pinStrip.counter.scripts.OnClick(f.pinStrip.counter)
  check("stepped off the newest", f.pinStrip.label.text.text == "keep me", f.pinStrip.label.text.text)
  S.Add({ convKey = "w:Vexa-Horizon", text = "yo", sender = "Vexa-Horizon" })
  C.Show("w:Vexa-Horizon")
  check("a chat with no pins hides the strip", not f.pinStrip:IsShown(), "shown")
  C.Show("w:Brisa-Horizon")
  check("coming back starts on the newest pin", f.pinStrip.label.text.text == "mine", f.pinStrip.label.text.text)

  -- Feed lines: right-click works and the marker sits before the line.
  S.Add({ convKey = "loot", text = "You receive loot: |cff0070dd|Hitem:1::|h[Blue Thing]|h|r", chatType = "LOOT" })
  C.Show("loot")
  local line = f.bubbles[1]
  opened = nil
  line.scripts.OnMouseUp(line, "RightButton")
  Flush()
  check("a feed line opens the message menu", opened ~= nil and opened[1] == line, "not opened")
  r = FakeRoot()
  opened[2](opened[1], r)
  r.items[1].fn()
  check("a feed line pins", #S.Pins("loot") == 1, #S.Pins("loot"))
  check("a pinned feed line shows the marker before the line", line.pin:IsShown() and line.pin.points[1][1] == "TOPLEFT"
    and line.pin.points[1][4] < line.text.points[1][4], "?")
  check("the strip shows links as their names", f.pinStrip.label.text.text == "You receive loot: |cff0070dd[Blue Thing]|r", f.pinStrip.label.text.text)
  MenuUtil = savedMenuUtil
  C_Timer, GetTime = savedTimer, savedGetTime

  C.Disable()
  K.Disable()
  T.Disable()
  H.Unbind()
  rawset(A.L, "ECHO_PIN_COUNTER", nil)
  S.Now = savedNow
  CreateFrame = savedCreateFrame
  A.GetDB = nil
  A.ECHO_DEFAULTS, A.ECHO_KEYS, A.ECHO_LIMITS = nil, nil, nil
  Echo.ClearDrafts()
  S.Reset()
`, 'card-pins');

// --- Card: the pin strip on a group card ----------------------------------------------------
run(read('options/modules/defaults/OptionsDefaultsEcho.lua'), 'echo-defaults-card-pins-group');
run(`
  local A = HorizonSuite
  local Echo = A.Echo
  local S, H, T, K, C = Echo.Store, Echo.History, Echo.Tiles, Echo.Stack, Echo.Card
  S.Reset()
  Echo.ClearDrafts()
  local savedCreateFrame = CreateFrame
  CreateFrame = STUB_CREATE_FRAME
  local db = {}
  A.GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  local saved = {}
  H.Bind(saved, function() return "Kaelis-Horizon" end)
  T.Enable()
  K.Enable()
  C.Enable()
  local f = C._frames()

  S.Add({ convKey = "ch:Trade", text = "wts", sender = "Vexa-Horizon" })
  S.Add({ convKey = "ch:General", text = "anyone?", sender = "Thorn-Horizon" })
  C.Open("ch:Trade")
  check("the group card shows its tabs", f.tabStrip:IsShown() and C.ShownKey() == "ch:Trade", tostring(C.ShownKey()))
  S.PinMessage("ch:Trade", S.Get("ch:Trade").messages[1])
  check("the strip shows on the group card", f.pinStrip:IsShown(), "hidden")
  check("the strip sits under the tab strip", f.pinStrip.points[1][5] == -(C.AREA_TOP + C.TAB_STRIP), tostring(f.pinStrip.points[1][5]))
  check("the area adds the strip to the tabs", f.area.points[1][5] == -(C.AREA_TOP + C.TAB_STRIP + C.PIN_STRIP), tostring(f.area.points[1][5]))
  C.SelectMember("ch:General")
  check("a member with no pins hides the strip", not f.pinStrip:IsShown() and f.area.points[1][5] == -(C.AREA_TOP + C.TAB_STRIP), tostring(f.area.points[1][5]))

  C.Disable()
  K.Disable()
  T.Disable()
  H.Unbind()
  CreateFrame = savedCreateFrame
  A.GetDB = nil
  A.ECHO_DEFAULTS, A.ECHO_KEYS, A.ECHO_LIMITS = nil, nil, nil
  Echo.ClearDrafts()
  S.Reset()
`, 'card-pins-group');

// --- Pins and history: safety (plan 10, final fix wave) ----------------------------------
run(`
  local A = HorizonSuite
  local Echo = A.Echo
  local S, H, M = Echo.Store, Echo.History, Echo.Menu
  S.Reset()
  local db = {}
  H.Bind(db, function() return "Kaelis-Horizon" end)
  local function Items(key, record)
    local items = {}
    local r = {}
    function r:CreateButton(label, fn)
      local b = { label = label, enabled = true }
      function b:SetEnabled(v) self.enabled = v end
      items[#items + 1] = b
      return b
    end
    M.BuildMessage(r, key, record)
    return items
  end

  -- A |K string (a Battle.net friend's protected name) is never pinned or saved.
  local kline = { text = "|Kq12|k has come online.", time = 10 }
  check("a System line with |K is blocked as hidden", S.PinBlockReason("system", kline) == "secret", tostring(S.PinBlockReason("system", kline)))
  local ok, reason = S.PinMessage("system", kline)
  check("a System line with |K can't be pinned", ok == false and reason == "secret" and #S.Pins("system") == 0, tostring(reason))
  local items = Items("system", kline)
  check("the menu says a |K line is hidden", items[1] and items[1].label == "ECHO_PIN_BLOCKED_SECRET" and items[1].enabled == false, items[1] and items[1].label)
  check("Append rejects |K text", H.Append("w:Brisa-Horizon", { text = "ask |Kq3|k about it", time = 11 }) == false, "appended")
  check("nothing was written for the |K line", db.echoHistory.chars["Kaelis-Horizon"] == nil
    or db.echoHistory.chars["Kaelis-Horizon"]["w:Brisa-Horizon"] == nil, "written")
  check("Append still takes plain text", H.Append("w:Brisa-Horizon", { text = "plain", time = 12 }) == true, "rejected")

  -- A demo, pending or failed message isn't real yet: it can't be pinned.
  for _, rec in ipairs({
    { text = "demo line", time = 20, demo = true },
    { text = "on its way", time = 21, outgoing = true, status = "pending" },
    { text = "never sent", time = 22, outgoing = true, status = "failed" },
  }) do
    local label = rec.demo and "demo" or rec.status
    check("a " .. label .. " message is unsaved", S.PinBlockReason("w:Brisa-Horizon", rec) == "unsaved", tostring(S.PinBlockReason("w:Brisa-Horizon", rec)))
    local okPin, why = S.PinMessage("w:Brisa-Horizon", rec)
    check("a " .. label .. " message can't be pinned", okPin == false and why == "unsaved", tostring(why))
    local its = Items("w:Brisa-Horizon", rec)
    check("the menu shows the unsaved reason for a " .. label .. " message", its[1] and its[1].label == "ECHO_PIN_BLOCKED_UNSAVED" and its[1].enabled == false, its[1] and its[1].label)
  end
  check("a sent message can still be pinned", S.PinBlockReason("w:Brisa-Horizon", { text = "arrived", time = 23, outgoing = true, status = "sent" }) == nil, "blocked")

  -- Malformed saved lists don't break the clean-up.
  H.SetMaxAge(30)
  local now = 40 * 86400
  db.echoHistory.chars["Kaelis-Horizon"] = { ["w:Junk-Horizon"] = { 5 }, ["w:Fresh-Horizon"] = { { t = now - 10, text = "hi" } } }
  db.echoHistory.chars["Broken-Horizon"] = "not a table"
  db.echoHistory.bnet["bt:Odd#1"] = { "junk" }
  local okPrune, removed = pcall(H.Prune, now)
  check("a malformed list doesn't break the clean-up", okPrune, tostring(removed))
  check("a list with a non-table newest entry counts as stale", okPrune and db.echoHistory.chars["Kaelis-Horizon"]["w:Junk-Horizon"] == nil
    and db.echoHistory.bnet["bt:Odd#1"] == nil, "kept")
  check("a readable list is kept", db.echoHistory.chars["Kaelis-Horizon"]["w:Fresh-Horizon"] ~= nil, "removed")
  db.echoHistory.bnet = "oops"
  check("a malformed bnet root doesn't break the clean-up", (pcall(H.Prune, now)), "threw")

  H.SetMaxAge(30)
  H.Unbind()
  S.Reset()
`, 'pins-safety');

// --- Guild history and pins: cold login, late load, per-guild pins (plan 10, final fix wave)
run(`
  local A = HorizonSuite
  local Echo = A.Echo
  local S, H, T, K, C = Echo.Store, Echo.History, Echo.Tiles, Echo.Stack, Echo.Card
  S.Reset()
  S.SetPersisted("guild", true)
  S.SetPersisted("officer", true)
  local db = {}
  H.Bind(db, function() return "Kaelis-Horizon" end)
  local savedGetGuildInfo = GetGuildInfo
  local guildName = nil
  GetGuildInfo = function(unit)
    if unit ~= "player" then return nil end
    return guildName, "Member", 5, nil
  end

  -- Cold login: the guild isn't known yet, so no guild list is pruned.
  H.SetMaxAge(30)
  local now = 40 * 86400 + 1000
  db.echoHistory.guilds["Dawnrise-Horizon"] = { guild = { { t = now - 40 * 86400, text = "old but ours" } } }
  db.echoHistory.guilds["Oldguild-Horizon"] = { officer = { { t = now - 40 * 86400, text = "old and theirs" } } }
  local removed = H.Prune(now)
  check("with no guild key, no guild list is pruned", removed == 0 and db.echoHistory.guilds["Dawnrise-Horizon"] ~= nil
    and db.echoHistory.guilds["Oldguild-Horizon"] ~= nil, removed)
  db.echoHistory.guilds["Oldguild-Horizon"] = nil

  -- A restored guild tile with no key loads its history once the key appears.
  local seen = {}
  local function listener(key, change) seen[#seen + 1] = tostring(key) .. "=" .. tostring(change) end
  S.Subscribe(listener)
  db.echoHistory.guilds["Dawnrise-Horizon"] = { guild = { { t = 1, text = "saved earlier" } } }
  S.Restore({ "guild" })
  local conv = S.Get("guild")
  check("restored with no guild key: nothing loaded yet", conv and conv.historyLoaded == false and #conv.messages == 0, conv and #conv.messages)
  S.RetryHistory()
  check("a retry with still no key loads nothing", conv.historyLoaded == false and #conv.messages == 0, #conv.messages)
  guildName = "Dawnrise"
  seen = {}
  S.RetryHistory()
  check("a retry once the key appears loads the history", #conv.messages == 1 and conv.messages[1].text == "saved earlier" and conv.historyLoaded == true, #conv.messages)
  check("the retry notifies update", seen[1] == "guild=update", tostring(seen[1]))
  seen = {}
  S.RetryHistory()
  check("a second retry loads nothing more", #conv.messages == 1 and #seen == 0, #conv.messages)
  S.Add({ convKey = "guild", text = "new line" })
  check("the next message doesn't load it again", #conv.messages == 2 and conv.messages[2].text == "new line", #conv.messages)
  S.Unsubscribe(listener)

  -- PLAYER_GUILD_UPDATE retries the load.
  S.Reset()
  guildName = nil
  S.Restore({ "guild" })
  guildName = "Dawnrise"
  local savedCreateFrame = CreateFrame
  CreateFrame = STUB_CREATE_FRAME
  Echo.Class.Enable()
  local frame = Echo.Class._frame()
  frame.scripts.OnEvent(frame, "PLAYER_GUILD_UPDATE")
  check("PLAYER_GUILD_UPDATE loads a waiting guild history", #S.Get("guild").messages == 2 and S.Get("guild").historyLoaded == true, #S.Get("guild").messages)
  Echo.Class.Disable()

  -- Showing the card retries it too.
  S.Reset()
  guildName = nil
  S.Restore({ "guild" })
  guildName = "Dawnrise"
  T.Enable()
  K.Enable()
  C.Enable()
  local f = C._frames()
  C.Open("guild")
  check("opening the card loads a waiting guild history", S.Get("guild").historyLoaded == true and #S.Get("guild").messages == 2, #S.Get("guild").messages)
  check("the card shows the loaded lines", f.bubbles[1].shown and f.bubbles[1].text.text == "new line", f.bubbles[1].text.text)
  C.Disable()
  K.Disable()
  T.Disable()
  CreateFrame = savedCreateFrame

  -- Guild and officer pins are kept per guild.
  S.Reset()
  guildName = "Dawnrise"
  local ok, reason = S.PinMessage("guild", { text = "raid at 8", time = 5, sender = "Brisa-Horizon" })
  check("a guild pin succeeds", ok == true, tostring(reason))
  local pins = db.echoHistory.pins["Kaelis-Horizon"]
  check("guild pins are keyed by guild and kind", pins["g:Dawnrise-Horizon:guild"] and #pins["g:Dawnrise-Horizon:guild"] == 1 and pins["guild"] == nil, "?")
  S.PinMessage("officer", { text = "loot council", time = 6, sender = "Brisa-Horizon" })
  check("officer pins are keyed by guild and kind", pins["g:Dawnrise-Horizon:officer"] and #pins["g:Dawnrise-Horizon:officer"] == 1, "?")
  guildName = "Otherguild"
  check("another guild shows a different pin list", #S.Pins("guild") == 0
    and not S.IsPinnedMessage("guild", { text = "raid at 8", time = 5, sender = "Brisa-Horizon" }), #S.Pins("guild"))
  S.PinMessage("guild", { text = "their pin", time = 7 })
  check("the other guild's pin is its own", #S.Pins("guild") == 1 and S.Pins("guild")[1].text == "their pin", #S.Pins("guild"))
  guildName = "Dawnrise"
  check("back in the first guild, its pins return", #S.Pins("guild") == 1 and S.Pins("guild")[1].text == "raid at 8", S.Pins("guild")[1] and S.Pins("guild")[1].text)
  guildName = nil
  check("with no guild key, there are no guild pins", #S.Pins("guild") == 0, #S.Pins("guild"))
  check("with no guild key, a guild pin is unsaved", S.PinBlockReason("guild", { text = "x", time = 8 }) == "unsaved", tostring(S.PinBlockReason("guild", { text = "x", time = 8 })))
  ok, reason = S.PinMessage("guild", { text = "x", time = 8 })
  check("with no guild key, a guild pin fails", ok == false and reason == "unsaved", tostring(reason))
  check("with no guild key, unpin fails", S.UnpinMessage("guild", 1) == false, "removed")
  H.SavePref("guild", nil, true)
  check("the conversation pref stays keyed by kind", db.echoHistory.prefs["Kaelis-Horizon"]["guild"] ~= nil, "moved")

  GetGuildInfo = savedGetGuildInfo
  S.SetPersisted("guild", false)
  S.SetPersisted("officer", false)
  H.SetMaxAge(30)
  H.Unbind()
  S.Reset()
`, 'pins-guild-timing');

// --- Copy: history and pin strings say what they keep and delete (plan 10, final fix wave)
run(`SAVED_L = HorizonSuite.L; HorizonSuite.L = {}`, 'locale-swap');
run(read('locales/horizon/enUS.lua'), 'locale-enUS');
run(`
  local EN = HorizonSuite.L
  HorizonSuite.L = SAVED_L
  SAVED_L = nil
  local function has(key, text) return type(EN[key]) == "string" and EN[key]:find(text, 1, true) ~= nil end
  check("Clear's description mentions pinned messages", has("ECHO_CLEAR_HISTORY_DESC", "your pinned messages"), EN.ECHO_CLEAR_HISTORY_DESC)
  check("Clear's confirmation mentions pinned messages", has("ECHO_CLEAR_HISTORY_CONFIRM", "your pinned messages"), EN.ECHO_CLEAR_HISTORY_CONFIRM)
  check("Save chat history's description", EN.ECHO_SAVE_HISTORY_DESC == "Keep the last 100 whispers with each person between sessions, and reopen recent tiles after a reload. Guild chat is saved too, and officer chat when switched on below. Messages the game hides are never saved.", EN.ECHO_SAVE_HISTORY_DESC)
  check("Save guild chat says 200 lines", has("ECHO_SAVE_GUILD_DESC", "200"), EN.ECHO_SAVE_GUILD_DESC)
  check("Save guild chat says every character in the guild shares it", has("ECHO_SAVE_GUILD_DESC", "every character in the same guild"), EN.ECHO_SAVE_GUILD_DESC)
  check("Keep history for names column pins and message pins", has("ECHO_HISTORY_DAYS_DESC", "Conversations pinned to the column are always kept, and pinned messages are never dropped."), EN.ECHO_HISTORY_DAYS_DESC)
  check("Keep history for drops the old wording", not has("ECHO_HISTORY_DAYS_DESC", "A pinned conversation"), EN.ECHO_HISTORY_DAYS_DESC)
  check("Keep history for still says when it takes effect", has("ECHO_HISTORY_DAYS_DESC", "next login"), EN.ECHO_HISTORY_DAYS_DESC)
`, 'echo-copy');

// --- Nearby: say, yell, emotes and NPC speech (plan 11, Task 1) --------------------------
run(`
  local Echo = HorizonSuite.Echo
  local S, E, V, Send = Echo.Store, Echo.Events, Echo.View, Echo.Send
  S.Reset()
  local function payload(text, sender, guid)
    return text, sender, nil, nil, nil, nil, nil, nil, nil, nil, nil, guid, nil
  end
  local styles = {
    CHAT_MSG_SAY = "say", CHAT_MSG_YELL = "yell", CHAT_MSG_EMOTE = "emote",
    CHAT_MSG_TEXT_EMOTE = "textemote", CHAT_MSG_MONSTER_SAY = "npc",
    CHAT_MSG_MONSTER_YELL = "npcyell", CHAT_MSG_MONSTER_EMOTE = "npcemote",
  }
  for event, style in pairs(styles) do
    local r = E.BuildRecord(event, payload("hello there", "Brisa"))
    check("nearby: " .. event .. " routes to nearby", r and r.convKey == "nearby", r and r.convKey)
    check("nearby: " .. event .. " carries style " .. style, r and r.style == style, r and r.style)
    check("nearby: " .. event .. " is not a feed line", r and not r.feed, "feed")
  end
  check("nearby: the kind is valid and quiet by default", S.KindOf("nearby") == "nearby" and S.DEFAULT_TIERS.nearby == "quiet",
        tostring(S.DEFAULT_TIERS.nearby))
  check("nearby: never persisted", S.IsPersisted("nearby") == false, "persisted")
  check("nearby: not a feed", not S.FEED_KINDS.nearby, "feed")
  check("nearby: never groupable", (function()
    HorizonSuite.GetDB = function(k, d)
      if k == "echoGroupsEnabled" then return true end
      if k == "echoGroupNames" then return { "Chat" } end
      if k == "echoGroupOf" then return { nearby = 1 } end
      return d
    end
    local g = Echo.Groups.Of("nearby")
    HorizonSuite.GetDB = nil
    return g == nil end)(), "grouped")

  local r = E.BuildRecord("CHAT_MSG_SAY", payload("hi all", "Brisa"))
  check("nearby: a say line names its sender", r.sender == "Brisa-Horizon" and r.outgoing == false, r.sender)
  r = E.BuildRecord("CHAT_MSG_SAY", payload("hi all", "Kaelis"))
  check("nearby: your own say is outgoing", r.outgoing == true, tostring(r.outgoing))
  r = E.BuildRecord("CHAT_MSG_MONSTER_SAY", payload("You there!", "Kaelis"))
  check("nearby: an NPC line is never outgoing", r.outgoing == false, tostring(r.outgoing))
  r = E.BuildRecord("CHAT_MSG_MONSTER_YELL", payload("Intruders!", "Hogger"))
  check("nearby: an NPC line keeps the NPC's name", r.sender == "Hogger", r.sender)
  r = E.BuildRecord("CHAT_MSG_MONSTER_SAY", payload("Hmm.", SECRET("Hogger")))
  check("nearby: a secret NPC name is not kept", r.sender == nil, tostring(r.sender))
  r = E.BuildRecord("CHAT_MSG_MONSTER_EMOTE", payload("%s goes into a frenzy!", "Hogger"))
  check("nearby: an NPC emote names its speaker", r.text == "Hogger goes into a frenzy!", r.text)
  r = E.BuildRecord("CHAT_MSG_MONSTER_EMOTE", payload("%s roars!", SECRET("Hogger")))
  check("nearby: an NPC emote with a secret speaker says Someone", r.text == "ECHO_SOMEONE roars!", r.text)
  r = E.BuildRecord("CHAT_MSG_SAY", payload("hey Kaelis", "Brisa"))
  check("nearby: a mention of your name is urgent", r.urgent == true, tostring(r.urgent))
  S.SetKindTier("nearby", "count")
  E.Dispatch("CHAT_MSG_SAY", payload("Kaelis, over here", "Brisa"))
  check("nearby: a mention on a count tier toasts", S.Get("nearby").lastLoud > 0, S.Get("nearby").lastLoud)
  S.SetKindTier("nearby", nil)

  local registered = {}
  E.Enable()
  local fr = E._frame()
  local savedRegister = fr.RegisterEvent
  fr.RegisterEvent = function(_, ev)
    if ev == "CHAT_MSG_MONSTER_EMOTE" then error("unknown event") end
    registered[ev] = true
  end
  E.Enable()
  check("nearby: say, yell and emote events are registered",
        registered.CHAT_MSG_SAY and registered.CHAT_MSG_YELL and registered.CHAT_MSG_EMOTE
        and registered.CHAT_MSG_TEXT_EMOTE and registered.CHAT_MSG_MONSTER_SAY and registered.CHAT_MSG_MONSTER_YELL, "missing")
  check("nearby: an event the client lacks is skipped, the rest still register", registered.CHAT_MSG_WHISPER == true, "aborted")
  E.Disable()
  fr.RegisterEvent = savedRegister
  S.Reset()

  -- Display helpers.
  local savedInfo = ChatTypeInfo
  ChatTypeInfo = { SAY = { r = 1, g = 1, b = 1 }, YELL = { r = 1, g = 0.25, b = 0.25 }, EMOTE = { r = 1, g = 0.5, b = 0.25 },
                   MONSTER_SAY = { r = 1, g = 1, b = 0.62 }, MONSTER_YELL = { r = 0.9, g = 0.2, b = 0.2 },
                   MONSTER_EMOTE = { r = 0.9, g = 0.45, b = 0.2 } }
  S.Add({ convKey = "nearby", text = "hi", sender = "Brisa-Horizon", style = "say" })
  local conv = S.Get("nearby")
  local spec = V.TileSpec(conv)
  check("nearby: tile has the icon face", spec.face == "icon" and spec.icon == "Interface\\\\Icons\\\\Ability_Warrior_BattleShout", spec.icon)
  check("nearby: tile label", spec.label == "ECHO_NEARBY_SHORT", spec.label)
  check("nearby: tile uses the Say colour", spec.r == 1 and spec.g == 1 and spec.b == 1, spec.g)
  check("nearby: card title", V.DisplayName(conv) == "ECHO_NEARBY", V.DisplayName(conv))

  local function color(msg) local r, g, b = V.LineColor(conv, msg) return r .. "," .. g .. "," .. b end
  check("nearby: yell colour", color({ style = "yell" }) == "1,0.25,0.25", color({ style = "yell" }))
  check("nearby: emote colour", color({ style = "emote" }) == "1,0.5,0.25", color({ style = "emote" }))
  check("nearby: text emote uses the emote colour", color({ style = "textemote" }) == "1,0.5,0.25", color({ style = "textemote" }))
  check("nearby: NPC say colour", color({ style = "npc" }) == "1,1,0.62", color({ style = "npc" }))
  check("nearby: NPC yell colour", color({ style = "npcyell" }) == "0.9,0.2,0.2", color({ style = "npcyell" }))
  check("nearby: NPC emote colour", color({ style = "npcemote" }) == "0.9,0.45,0.2", color({ style = "npcemote" }))
  ChatTypeInfo = nil
  check("nearby: a yell colour without ChatTypeInfo falls back", color({ style = "yell" }) == "1,0.25,0.25", color({ style = "yell" }))
  ChatTypeInfo = savedInfo

  check("nearby: an emote line reads name then text",
        V.LineText(conv, { style = "emote", text = "waves.", sender = "Brisa-Horizon" }) == "Brisa waves.",
        V.LineText(conv, { style = "emote", text = "waves.", sender = "Brisa-Horizon" }))
  check("nearby: a text emote shows its text only",
        V.LineText(conv, { style = "textemote", text = "Brisa waves at you.", sender = "Brisa-Horizon" }) == "Brisa waves at you.", "?")
  local secretText = SECRET("dances")
  check("nearby: a secret emote shows its text alone",
        rawequal(V.LineText(conv, { style = "emote", text = secretText, secret = true, sender = "Brisa-Horizon" }), secretText), "joined")
  check("nearby: an emote from a secret sender shows its text alone",
        V.LineText(conv, { style = "emote", text = "dances", sender = SECRET("Brisa") }) == "dances", "joined")
  check("nearby: emote lines are full-width lines", V.IsEmoteLine({ style = "emote" }) and V.IsEmoteLine({ style = "textemote" })
        and not V.IsEmoteLine({ style = "say" }) and not V.IsEmoteLine({ style = "yell" }), "?")
  S.Reset()

  -- Sending: the mode follows the chip, and resets on Reset.
  check("nearby: the send mode starts on Say", S.SendModeOf("nearby") == "SAY", S.SendModeOf("nearby"))
  check("nearby: Say routes to SAY", Send.RouteFor("nearby").chatType == "SAY", Send.RouteFor("nearby").chatType)
  S.SetSendMode("nearby", "YELL")
  check("nearby: Yell routes to YELL", Send.RouteFor("nearby").chatType == "YELL", Send.RouteFor("nearby").chatType)
  S.SetSendMode("nearby", "EMOTE")
  check("nearby: Emote routes to EMOTE", Send.RouteFor("nearby").chatType == "EMOTE", Send.RouteFor("nearby").chatType)
  check("nearby: a route has no target", Send.RouteFor("nearby").target == nil, "target")
  S.SetSendMode("nearby", "WHISPER")
  check("nearby: an unknown mode is refused", S.SendModeOf("nearby") == "EMOTE", S.SendModeOf("nearby"))
  S.Reset()
  check("nearby: the mode resets to Say", S.SendModeOf("nearby") == "SAY", S.SendModeOf("nearby"))

  local sent = {}
  C_ChatInfo = { SendChatMessage = function(msg, chatType) sent[#sent + 1] = chatType .. ":" .. msg end }
  S.SetSendMode("nearby", "YELL")
  check("nearby: a send goes out in the current mode", Send.Send("nearby", "over here") and sent[1] == "YELL:over here", sent[1])
  local pending = S.Get("nearby").messages[1]
  check("nearby: the pending line carries the mode's style", pending.style == "yell", tostring(pending.style))
  E.Dispatch("CHAT_MSG_YELL", payload("over here", "Kaelis"))
  check("nearby: your yell's echo confirms it", pending.status == "sent", pending.status)
  S.SetSendMode("nearby", "EMOTE")
  Send.Send("nearby", "waves")
  check("nearby: an emote goes out as EMOTE", sent[2] == "EMOTE:waves", sent[2])
  local msgs = S.Get("nearby").messages
  check("nearby: a pending emote is an emote line", msgs[#msgs].style == "emote", tostring(msgs[#msgs].style))

  C_ChatInfo.SendChatMessage = function() error("SendChatMessage: SAY is restricted") end
  S.SetSendMode("nearby", "SAY")
  local ok, blocked = Send.Send("nearby", "hello?")
  msgs = S.Get("nearby").messages
  check("nearby: a thrown send marks the line failed", msgs[#msgs].status == "failed", msgs[#msgs].status)
  check("nearby: a thrown send reports it was blocked", ok == true and blocked == "blocked", tostring(blocked))
  local _, other = Send.Send("party", "hi")
  check("nearby: a thrown party send is not reported as a Nearby block", other == nil, tostring(other))
  C_ChatInfo = nil
  S.Reset()
`, 'nearby-logic');

run(`
  local Echo = HorizonSuite.Echo
  local S, C = Echo.Store, Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  local savedInfo = ChatTypeInfo
  ChatTypeInfo = { SAY = { r = 1, g = 1, b = 1 }, YELL = { r = 1, g = 0.25, b = 0.25 }, EMOTE = { r = 1, g = 0.5, b = 0.25 } }
  C.Enable()
  local f = C._frames()
  S.Add({ convKey = "nearby", text = "anyone around?", sender = "Brisa-Horizon", style = "say" })
  S.Add({ convKey = "nearby", text = "waves.", sender = "Brisa-Horizon", style = "emote" })
  S.Add({ convKey = "nearby", text = "HELP!", sender = "Vexa-Horizon", style = "yell" })
  C.Open("nearby")
  -- Record text colours, then paint again.
  for _, b in ipairs(f.bubbles) do
    rawset(b.text, "SetTextColor", function(self, r, g, bl) self.color = r .. "," .. g .. "," .. bl end)
  end
  C.Render()
  local yell, emote, say = f.bubbles[1], f.bubbles[2], f.bubbles[3]
  check("nearby card: the yell is a bubble in the yell colour", yell.text.text == "HELP!" and yell.text.color == "1,0.25,0.25",
        tostring(yell.text.color))
  check("nearby card: the emote line shows the name first", emote.text.text == "Brisa waves.", emote.text.text)
  check("nearby card: the emote line spans the card", emote.width == C.WIDTH - C.PAD * 2, emote.width)
  check("nearby card: the emote line is in the emote colour", emote.text.color == "1,0.5,0.25", tostring(emote.text.color))
  check("nearby card: the say bubble is fitted, not full-width", say.text.text == "anyone around?" and say.width ~= C.WIDTH - C.PAD * 2, say.width)
  local labelled = false
  for _, l in ipairs(f.labels) do if l.shown and l.text == "Brisa" then labelled = true end end
  check("nearby card: the speaker is named above the run", labelled, "no label")

  local secretText = SECRET("dances")
  S.Add({ convKey = "nearby", text = secretText, secret = true, sender = "Brisa-Horizon", style = "emote" })
  check("nearby card: a secret emote shows its text alone", rawequal(f.bubbles[1].text.text, secretText), "joined")

  -- The mode chip.
  check("nearby card: the mode chip shows on Nearby", f.mode and f.mode.shown == true, "hidden")
  check("nearby card: the chip starts on Say", f.mode.text.text == "ECHO_MODE_SAY", f.mode.text.text)
  check("nearby card: the reply box makes room for the chip", (rawget(f.edit, "_leftInset") or 0) > 8, rawget(f.edit, "_leftInset"))
  f.mode.scripts.OnClick(f.mode)
  check("nearby card: a click moves to Yell", S.SendModeOf("nearby") == "YELL" and f.mode.text.text == "ECHO_MODE_YELL", f.mode.text.text)
  f.mode.scripts.OnClick(f.mode)
  check("nearby card: then Emote", S.SendModeOf("nearby") == "EMOTE" and f.mode.text.text == "ECHO_MODE_EMOTE", f.mode.text.text)
  f.mode.scripts.OnClick(f.mode)
  check("nearby card: then back to Say", S.SendModeOf("nearby") == "SAY" and f.mode.text.text == "ECHO_MODE_SAY", f.mode.text.text)

  C_ChatInfo = { SendChatMessage = function() error("SAY is restricted outdoors") end }
  f.edit:SetText("hello?")
  C.Submit()
  local msgs = S.Get("nearby").messages
  check("nearby card: a blocked send is failed", msgs[#msgs].status == "failed", msgs[#msgs].status)
  check("nearby card: a blocked send explains itself in the hint", f.hint.shown and f.hint.text.text == "ECHO_SEND_BLOCKED_NEARBY",
        tostring(f.hint.text.text))
  C_ChatInfo = nil

  S.Add({ convKey = "w:Brisa-Horizon", text = "psst", sender = "Brisa-Horizon" })
  C.Show("w:Brisa-Horizon")
  check("nearby card: no chip on a whisper", f.mode.shown == false, "shown")
  check("nearby card: a whisper's reply box has its plain inset", rawget(f.edit, "_leftInset") == 8, rawget(f.edit, "_leftInset"))
  C.Disable()
  ChatTypeInfo = savedInfo
  S.Reset()
`, 'nearby-card');

// --- Nearby fix round 1: unconfirmed lines fail; NPC lines are never mentions ---------------
run(`
  local Echo = HorizonSuite.Echo
  local S, E, C, Send = Echo.Store, Echo.Events, Echo.Card, Echo.Send
  S.Reset()
  local function payload(text, sender)
    return text, sender, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
  end
  for _, ev in ipairs({ "CHAT_MSG_MONSTER_SAY", "CHAT_MSG_MONSTER_YELL", "CHAT_MSG_MONSTER_EMOTE" }) do
    local r = E.BuildRecord(ev, payload("Kaelis, bring me ten pelts", "Hogger"))
    check("nearby fix: " .. ev .. " naming you is not a mention", r.urgent == false, tostring(r.urgent))
  end
  local r = E.BuildRecord("CHAT_MSG_SAY", payload("Kaelis, hi", "Brisa"))
  check("nearby fix: a player saying your name still is", r.urgent == true, tostring(r.urgent))

  check("nearby fix: the confirm window is 8 seconds", S.NEARBY_CONFIRM_SECONDS == 8, S.NEARBY_CONFIRM_SECONDS)
  local realNow = S.Now
  local clock = 1000
  S.Now = function() return clock end
  local timers = {}
  local realTimer = C_Timer
  C_Timer = { After = function(sec, fn) timers[#timers + 1] = { sec = sec, fn = fn } end,
              NewTimer = function() return { Cancel = function() end } end }
  C_ChatInfo = { SendChatMessage = function() end }
  CreateFrame = STUB_CREATE_FRAME
  C.Enable()
  local f = C._frames()

  Send.Send("w:Brisa-Horizon", "whisper waiting")
  check("nearby fix: a whisper send schedules no expiry", #timers == 0, #timers)
  Send.Send("nearby", "confirmed soon")
  Send.Send("nearby", "never echoed")
  check("nearby fix: a Nearby send schedules a check", #timers == 2 and timers[1].sec == 8.5, timers[1] and timers[1].sec)
  local lines = S.Get("nearby").messages
  check("nearby fix: a pending line is stamped", lines[1].filedAt == 1000, tostring(lines[1].filedAt))
  E.Dispatch("CHAT_MSG_SAY", payload("confirmed soon", "Kaelis"))
  check("nearby fix: nothing expires inside the window", S.ExpirePending(1007) == 0 and lines[2].status == "pending", lines[2].status)

  C.Open("nearby")
  f.hint:Hide()
  clock = 1009
  timers[2].fn()
  check("nearby fix: an unconfirmed line fails", lines[2].status == "failed", lines[2].status)
  check("nearby fix: a confirmed line is untouched", lines[1].status == "sent", lines[1].status)
  check("nearby fix: the expiry explains itself in the hint", f.hint.shown and f.hint.text.text == "ECHO_SEND_BLOCKED_NEARBY",
        tostring(f.hint.text.text))
  local w = S.Get("w:Brisa-Horizon").messages[1]
  check("nearby fix: a whisper pending line never expires", S.ExpirePending(99999) == 0 and w.status == "pending", w.status)

  C.Show("w:Brisa-Horizon")
  f.hint:Hide()
  Send.Send("nearby", "another")
  clock = 1100
  timers[#timers].fn()
  check("nearby fix: no hint while another card is shown", f.hint.shown == false, "shown")

  C.Disable()
  C_Timer = realTimer
  C_ChatInfo = nil
  S.Now = realNow
  S.Reset()
`, 'nearby-fix-1');

run(read('options/modules/defaults/OptionsDefaultsEcho.lua'), 'nearby-defaults');
run(`
  local A = HorizonSuite
  check("nearby: the tier default is quiet", A.ECHO_DEFAULTS.echoTierNearby == "quiet", tostring(A.ECHO_DEFAULTS.echoTierNearby))
  A.OptionCategories = {}
  local db = {}
  A.OptionsData_GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  A.OptionsData_SetDB = function(k, v) db[k] = v end
  local function merge(t, o) if o then for k, v in pairs(o) do t[k] = v end end return t end
  A.Section = function(n) return { type = "section", name = n } end
  A.Button = function(n, d, f, o) return merge({ type = "button", name = n, desc = d, onClick = f }, o) end
  A.Toggle = function(n, d, key, def, o) return merge({ type = "toggle", name = n, desc = d, dbKey = key,
    get = function() return A.OptionsData_GetDB(key, def) end, set = function(v) A.OptionsData_SetDB(key, v) end }, o) end
  A.GetPerElementFontDropdownOptions = function() return { { "Global", "__global__" } } end
`, 'nearby-options-stubs');
run(read('options/modules/OptionsEcho.lua'), 'nearby-options');
run(`
  local A = HorizonSuite
  local found, afterChannel
  local seenChannel = false
  for _, opt in ipairs(A.OptionCategories[1].options) do
    if opt.dbKey == "echoTierChannel" then seenChannel = true end
    if opt.dbKey == "echoTierNearby" then found = opt; afterChannel = seenChannel end
  end
  check("nearby: the tier is on the options page", found ~= nil and found.name == A.L["ECHO_NEARBY"], found and found.name)
  check("nearby: alongside the other tiers", afterChannel == true, tostring(afterChannel))
  check("nearby: the dropdown reads quiet", found and found.get() == "quiet", found and found.get())
  A.OptionCategories, A.OptionsData_GetDB, A.OptionsData_SetDB = nil, nil, nil
  A.Section, A.Button, A.Toggle, A.GetPerElementFontDropdownOptions = nil, nil, nil, nil
  A.ECHO_DEFAULTS, A.ECHO_KEYS, A.ECHO_LIMITS = nil, nil, nil
`, 'nearby-options-check');

// --- Start chat: Store.Start ---------------------------------------------------
run(`
  local Echo = HorizonSuite.Echo
  local S = Echo.Store
  S.Reset()
  local notes = {}
  local function spy(key, change) notes[#notes + 1] = tostring(key) .. ":" .. tostring(change) end
  S.Subscribe(spy)

  S.Add({ convKey = "w:Vexa-Horizon", text = "hi", sender = "Vexa-Horizon" })
  S.SetTier("guild", "loud")
  S.Add({ convKey = "guild", text = "loud line", sender = "Thorn-Horizon" })
  notes = {}
  local conv = S.Start("w:Brisa-Horizon")
  check("start: creates the conversation", conv ~= nil and S.Get("w:Brisa-Horizon") == conv, tostring(conv))
  check("start: with no message", conv and #conv.messages == 0, conv and #conv.messages)
  check("start: open", conv and conv.open == true, conv and tostring(conv.open))
  check("start: first in List", S.List()[1] == conv, S.List()[1] and S.List()[1].key)
  check("start: notifies update", notes[#notes] == "w:Brisa-Horizon:update", notes[#notes])
  check("start: no unread", conv.unread == 0, conv.unread)

  S.Add({ convKey = "guild", text = "later loud line", sender = "Thorn-Horizon" })
  check("start: a later loud line goes above it", S.List()[1].key == "guild", S.List()[1].key)
  S.Close("w:Vexa-Horizon")
  local again = S.Start("w:Vexa-Horizon")
  check("start: reopens a closed conversation", again and again.open == true and #again.messages == 1, again and tostring(again.open))
  check("start: a reopened one is first", S.List()[1].key == "w:Vexa-Horizon", S.List()[1].key)

  S.SetPinned("guild", true)
  S.Start("w:Brisa-Horizon")
  check("start: pinned conversations stay above", S.List()[1].key == "guild" and S.List()[2].key == "w:Brisa-Horizon",
        S.List()[1].key .. "," .. S.List()[2].key)
  S.SetPinned("guild", false)

  S.Restore({ "w:Old-Horizon" })
  S.Start("party")
  check("start: above a restored conversation", S.List()[1].key == "party", S.List()[1].key)

  S.Add({ convKey = "nearby", text = "hi", sender = "Brisa-Horizon", style = "say" })
  S.Close("nearby")
  S.Get("nearby").dismissed = true
  S.Start("nearby")
  check("start: clears dismissed", S.Get("nearby").dismissed == nil and S.Get("nearby").open, tostring(S.Get("nearby").dismissed))

  notes = {}
  check("start: rejects a feed", S.Start("loot") == nil and S.Get("loot") == nil, "accepted")
  check("start: rejects an invalid key", S.Start("w:") == nil and S.Start("bogus") == nil and S.Start(nil) == nil
        and S.Start(42) == nil, "accepted")
  check("start: a rejection notifies nothing", #notes == 0, #notes)
  S.Unsubscribe(spy)
  S.Reset()
`, 'start-store');

// --- Chat shortcuts: Send.ParseShortcut --------------------------------------------
run(`
  local Echo = HorizonSuite.Echo
  local S, Send = Echo.Store, Echo.Send
  S.Reset()
  local saved = { IsInGroup = IsInGroup, IsInRaid = IsInRaid, IsInGuild = IsInGuild, GetChannelName = GetChannelName,
                  LE = LE_PARTY_CATEGORY_INSTANCE }
  LE_PARTY_CATEGORY_INSTANCE = 2
  IsInGroup = function(cat) return true end
  IsInRaid = function() return true end
  IsInGuild = function() return true end
  local P = Send.ParseShortcut
  local function sends(text, key, rest, mode)
    local r = P(text, "w:Vexa-Horizon")
    local ok = r and r.convKey == key and r.text == rest and r.mode == mode and r.blocked == nil
    check("shortcut: " .. text .. " -> " .. key, ok, r and (tostring(r.convKey) .. "|" .. tostring(r.text) .. "|" .. tostring(r.mode) .. "|" .. tostring(r.blocked)) or "nil")
  end
  for _, c in ipairs({ "s", "say", "S", "SAY" }) do sends("/" .. c .. " hi", "nearby", "hi", "SAY") end
  for _, c in ipairs({ "y", "yell", "sh", "shout" }) do sends("/" .. c .. " hi", "nearby", "hi", "YELL") end
  for _, c in ipairs({ "e", "em", "emote", "me" }) do sends("/" .. c .. " waves", "nearby", "waves", "EMOTE") end
  for _, c in ipairs({ "g", "guild" }) do sends("/" .. c .. " hi", "guild", "hi") end
  for _, c in ipairs({ "o", "officer" }) do sends("/" .. c .. " hi", "officer", "hi") end
  for _, c in ipairs({ "p", "party" }) do sends("/" .. c .. " hi", "party", "hi") end
  for _, c in ipairs({ "ra", "raid", "rw" }) do sends("/" .. c .. " pull", "raid", "pull") end
  for _, c in ipairs({ "i", "instance", "bg" }) do sends("/" .. c .. " hi", "instance", "hi") end
  for _, c in ipairs({ "w", "whisper", "t", "tell" }) do sends("/" .. c .. " Brisa hi there", "w:Brisa-Horizon", "hi there") end
  sends("/w Brisa-Argent hi", "w:Brisa-Argent", "hi")
  sends("/g   spaced out  ", "guild", "spaced out  ")

  -- Empty shortcuts switch and keep the box empty.
  local r = P("/g", "party")
  check("shortcut: /g alone is empty", r and r.blocked == "empty" and r.convKey == "guild", r and r.blocked)
  r = P("/y  ", "party")
  check("shortcut: /y alone is empty on Nearby, in Yell", r and r.blocked == "empty" and r.convKey == "nearby" and r.mode == "YELL", r and r.blocked)
  r = P("/w Brisa", "party")
  check("shortcut: /w Name alone is empty on that whisper", r and r.blocked == "empty" and r.convKey == "w:Brisa-Horizon", r and r.convKey)

  -- Nowhere.
  r = P("/w", "party")
  check("shortcut: /w with no name is nowhere", r and r.blocked == "nowhere", r and r.blocked)
  r = P("/w |Kq12|k hi", "party")
  check("shortcut: a Battle.net name is never parsed", r and r.blocked == "nowhere" and r.convKey == nil, r and r.blocked)
  r = P("/r hi", "party")
  check("shortcut: /r with no whisper is nowhere", r and r.blocked == "nowhere", r and r.blocked)
  IsInGroup = function(cat) return false end
  IsInRaid = function() return false end
  IsInGuild = function() return false end
  for _, c in ipairs({ "p", "ra", "rw", "i", "g", "o" }) do
    r = P("/" .. c .. " hi", "party")
    check("shortcut: /" .. c .. " outside the group is nowhere", r and r.blocked == "nowhere", r and r.blocked)
  end
  IsInGroup = function(cat) return cat == LE_PARTY_CATEGORY_INSTANCE end
  r = P("/i hi", "party")
  check("shortcut: instance chat asks about the instance group", r and r.convKey == "instance", r and r.blocked)
  r = P("/p hi", "party")
  check("shortcut: party asks about the home group", r and r.blocked == "nowhere", r and r.convKey)
  IsInGroup = function() return true end
  IsInRaid = function() return true end
  IsInGuild = function() return true end

  -- Commands.
  for _, t in ipairs({ "/cast Fireball", "/dance", "/foo", "/reload", "/10 hi", "/shello" }) do
    r = P(t, "party")
    check("shortcut: " .. t .. " is a command", r and r.blocked == "command", r and (r.blocked or r.convKey))
  end
  check("shortcut: a plain message is nil", P("hello there", "party") == nil, "parsed")
  local lead = P(" /dance", "party")
  check("shortcut: a leading space then / is still a command", lead and lead.blocked == "command", lead and (lead.blocked or lead.convKey))
  sends("  /g hi", "guild", "hi")
  check("shortcut: an empty text is nil", P("", "party") == nil, "parsed")
  check("shortcut: a secret text is nil", P(SECRET("/dance"), "party") == nil, "parsed")

  -- /r: the newest incoming whisper or Battle.net whisper.
  S.Add({ convKey = "w:Brisa-Horizon", text = "old", sender = "Brisa-Horizon" })
  S.Add({ convKey = "bn:7", text = "newer", sender = "Friend" })
  S.Add({ convKey = "w:Vexa-Horizon", text = "mine", outgoing = true })
  S.Add({ convKey = "guild", text = "not a whisper", sender = "Thorn-Horizon" })
  sends("/r yes", "bn:7", "yes")
  S.Add({ convKey = "w:Brisa-Horizon", text = "newest", sender = "Brisa-Horizon" })
  sends("/reply ok", "w:Brisa-Horizon", "ok")
  S.Close("w:Brisa-Horizon")
  sends("/r still", "w:Brisa-Horizon", "still")
  r = P("/r", "party")
  check("shortcut: /r alone is empty on the whisper", r and r.blocked == "empty" and r.convKey == "w:Brisa-Horizon", r and r.convKey)
  S.Reset()

  -- /1 to /9: the joined channel in that slot.
  GetChannelName = function(n)
    if n == 1 then return 1, "General - Stormwind City", 1 end
    if n == 2 then return 2, "Trade - City", 2 end
    if n == 5 then return 5, "Crafters", nil end
    return 0, nil
  end
  sends("/1 hello", "ch:General", "hello")
  sends("/2 wts", "ch:Trade", "wts")
  sends("/5 hi", "ch:Crafters", "hi")
  r = P("/3 hi", "party")
  check("shortcut: an empty slot is nowhere", r and r.blocked == "nowhere", r and r.blocked)
  r = P("/5", "party")
  check("shortcut: /5 alone is empty on that channel", r and r.blocked == "empty" and r.convKey == "ch:Crafters", r and r.convKey)
  GetChannelName = function() return 4, SECRET("Hidden") end
  r = P("/4 hi", "party")
  check("shortcut: a secret channel name is nowhere", r and r.blocked == "nowhere", r and r.blocked)
  GetChannelName = nil
  r = P("/1 hi", "party")
  check("shortcut: no GetChannelName is nowhere", r and r.blocked == "nowhere", r and r.blocked)

  -- Localised globals.
  SLASH_SAY1 = "/SAGEN"
  SLASH_GUILD2 = "/Gilde"
  SLASH_WHISPER3 = "/flüstern"
  SLASH_REPLY1 = "/antworten"
  SLASH_RAID_WARNING1 = "/rw"
  sends("/sagen hallo", "nearby", "hallo", "SAY")
  sends("/gilde hallo", "guild", "hallo")
  sends("/flüstern Brisa hallo", "w:Brisa-Horizon", "hallo")
  r = P("/antworten x", "party")
  check("shortcut: a localised reply is honoured", r and r.blocked == "nowhere", r and (r.blocked or r.convKey))
  SLASH_SAY1, SLASH_GUILD2, SLASH_WHISPER3, SLASH_REPLY1, SLASH_RAID_WARNING1 = nil, nil, nil, nil, nil

  IsInGroup, IsInRaid, IsInGuild, GetChannelName = saved.IsInGroup, saved.IsInRaid, saved.IsInGuild, saved.GetChannelName
  LE_PARTY_CATEGORY_INSTANCE = saved.LE
  S.Reset()
`, 'shortcut-parse');

// --- Chat shortcuts: the card and the stack --------------------------------------
run(`
  local Echo = HorizonSuite.Echo
  local S, C, K, Send = Echo.Store, Echo.Card, Echo.Stack, Echo.Send
  S.Reset()
  Echo.ClearDrafts()
  CreateFrame = STUB_CREATE_FRAME
  local saved = { IsInGroup = IsInGroup, IsInRaid = IsInRaid, IsInGuild = IsInGuild, C_Timer = C_Timer }
  IsInGroup = function() return true end
  IsInRaid = function() return false end
  IsInGuild = function() return true end
  local timers = {}
  C_Timer = { After = function(sec, fn) timers[#timers + 1] = { sec = sec, fn = fn } end,
              NewTimer = function() return { Cancel = function() end } end }
  local wire = {}
  C_ChatInfo = { SendChatMessage = function(msg, chatType, _, target)
    wire[#wire + 1] = chatType .. ":" .. tostring(target) .. ":" .. msg end }
  local realSend = Send.Send
  local calls = {}
  Send.Send = function(key, text) calls[#calls + 1] = key .. ":" .. text; return realSend(key, text) end

  C.Enable()
  local f = C._frames()
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon" })
  C.Open("w:Brisa-Horizon")

  -- A blocked command keeps its text and never reaches Send.Send.
  for _, t in ipairs({ "/cast Fireball", "/dance", "/foo", " /dance" }) do
    calls, wire = {}, {}
    f.hint:Hide()
    f.edit:SetText(t)
    f.edit.scripts.OnEnterPressed(f.edit)
    check("shortcut card: " .. t .. " is never sent", #calls == 0 and #wire == 0, calls[1] or wire[1])
    check("shortcut card: " .. t .. " stays in the box", f.edit:GetText() == t, f.edit:GetText())
    check("shortcut card: " .. t .. " explains itself", f.hint.shown and f.hint.text.text == "ECHO_SHORTCUT_COMMAND", f.hint.text.text)
    check("shortcut card: " .. t .. " keeps the card", C.ShownKey() == "w:Brisa-Horizon", tostring(C.ShownKey()))
  end
  local hideAt = timers[#timers]
  check("shortcut card: the hint lasts 4 seconds", hideAt and hideAt.sec == 4, hideAt and hideAt.sec)
  hideAt.fn()
  check("shortcut card: then goes", f.hint.shown == false, "shown")

  -- A stale timer doesn't hide a newer hint.
  f.edit:SetText("/dance")
  C.Submit()
  local first = timers[#timers]
  f.edit:SetText("/dance")
  C.Submit()
  first.fn()
  check("shortcut card: an older timer leaves a newer hint", f.hint.shown, "hidden")
  timers[#timers].fn()

  -- Nowhere keeps the text.
  calls = {}
  f.edit:SetText("/r hi")
  S.Reset()
  S.Add({ convKey = "guild", text = "hi", sender = "Thorn-Horizon" })
  C.Open("guild")
  f.edit:SetText("/o hi")
  IsInGuild = function() return false end
  C.Submit()
  check("shortcut card: nowhere keeps the text", f.edit:GetText() == "/o hi" and #calls == 0, f.edit:GetText())
  check("shortcut card: nowhere explains itself", f.hint.shown and f.hint.text.text == "ECHO_SHORTCUT_NOWHERE", f.hint.text.text)
  IsInGuild = function() return true end

  -- A send switches the card, starts the conversation and sends.
  calls, wire = {}, {}
  f.edit:SetText("/w Vexa see you there")
  C.Submit()
  check("shortcut card: switches to the whisper", C.ShownKey() == "w:Vexa-Horizon", tostring(C.ShownKey()))
  check("shortcut card: sends the rest there", calls[1] == "w:Vexa-Horizon:see you there" and wire[1] == "WHISPER:Vexa-Horizon:see you there", calls[1])
  check("shortcut card: the box empties", f.edit:GetText() == "", f.edit:GetText())
  check("shortcut card: the shortcut is not parked on the old conversation", Echo.TakeDraft("guild") == "", Echo.TakeDraft("guild"))
  check("shortcut card: the new conversation is first", S.List()[1].key == "w:Vexa-Horizon", S.List()[1].key)

  -- Nearby with a mode.
  calls, wire = {}, {}
  f.edit:SetText("/y over here")
  C.Submit()
  check("shortcut card: /y switches to Nearby", C.ShownKey() == "nearby", tostring(C.ShownKey()))
  check("shortcut card: in Yell", S.SendModeOf("nearby") == "YELL" and wire[1] == "YELL:nil:over here", wire[1])
  check("shortcut card: the chip follows", f.mode.text.text == "ECHO_MODE_YELL", f.mode.text.text)

  -- Empty: switch and keep the box empty.
  calls = {}
  f.edit:SetText("/g")
  C.Submit()
  check("shortcut card: /g alone switches", C.ShownKey() == "guild", tostring(C.ShownKey()))
  check("shortcut card: and empties the box", f.edit:GetText() == "" and #calls == 0, f.edit:GetText())

  -- A plain message still goes to the shown conversation.
  calls = {}
  f.edit:SetText("plain")
  C.Submit()
  check("shortcut card: a plain message goes to the shown conversation", calls[1] == "guild:plain", calls[1])

  -- The stack's quick reply: the same, but a switch opens the card.
  C.Hide()
  K.Enable()
  local k = K._frames()
  K.Open("guild")
  calls = {}
  k.edit:SetText("/dance")
  k.edit.scripts.OnEnterPressed(k.edit)
  check("shortcut stack: a command is never sent", #calls == 0, calls[1])
  check("shortcut stack: and stays in the box", k.edit:GetText() == "/dance", k.edit:GetText())
  check("shortcut stack: and explains itself", k.notice and k.notice.shown and k.notice.text.text == "ECHO_SHORTCUT_COMMAND",
        k.notice and tostring(k.notice.text.text))
  timers[#timers].fn()
  check("shortcut stack: the notice goes after its time", k.notice.shown == false and timers[#timers].sec == 4, timers[#timers].sec)
  k.edit:SetText("/r hi")
  k.edit.scripts.OnEnterPressed(k.edit)
  check("shortcut stack: nowhere keeps the text", k.edit:GetText() == "/r hi" and k.notice.text.text == "ECHO_SHORTCUT_NOWHERE", k.notice.text.text)
  k.edit:SetText("/p ready")
  k.edit.scripts.OnEnterPressed(k.edit)
  check("shortcut stack: a switch sends there", calls[1] == "party:ready", calls[1])
  check("shortcut stack: and opens the card on it", C.IsShown() and C.ShownKey() == "party" and not k.root.shown, tostring(C.ShownKey()))
  check("shortcut stack: the shortcut is not parked", Echo.TakeDraft("guild") == "", Echo.TakeDraft("guild"))
  C.Hide()
  K.Open("guild")
  calls = {}
  k.edit:SetText("/s")
  k.edit.scripts.OnEnterPressed(k.edit)
  check("shortcut stack: an empty shortcut opens the card there", C.IsShown() and C.ShownKey() == "nearby" and #calls == 0, tostring(C.ShownKey()))
  check("shortcut stack: /s sets Say", S.SendModeOf("nearby") == "SAY", S.SendModeOf("nearby"))
  check("shortcut stack: the card's box is empty", f.edit:GetText() == "", f.edit:GetText())
  C.Hide()
  K.Open("guild")
  calls = {}
  k.edit:SetText("plain")
  k.edit.scripts.OnEnterPressed(k.edit)
  check("shortcut stack: a plain message goes to the top card", calls[1] == "guild:plain" and k.edit:GetText() == "", calls[1])

  K.Disable()
  C.Disable()
  Send.Send = realSend
  C_ChatInfo = nil
  IsInGroup, IsInRaid, IsInGuild, C_Timer = saved.IsInGroup, saved.IsInRaid, saved.IsInGuild, saved.C_Timer
  S.Reset()
`, 'shortcut-card');

// --- Chat shortcuts: a grouped member opens in its group ----------------------------
run(read('options/modules/defaults/OptionsDefaultsEcho.lua'), 'shortcut-group-defaults');
run(`
  local A = HorizonSuite
  local Echo = A.Echo
  local S, C = Echo.Store, Echo.Card
  S.Reset()
  Echo.ClearDrafts()
  CreateFrame = STUB_CREATE_FRAME
  local savedGetDB = A.GetDB
  local db = { echoGroupNames = { "Channels" }, echoGroupOf = { ["ch:*"] = 1 } }
  A.GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  local savedChan = GetChannelName
  GetChannelName = function(n)
    if n == 1 then return 1, "General - City", 1 end
    if n == 2 or n == "Trade" then return 2, "Trade - City", 2 end
    return 0, nil
  end
  C_ChatInfo = { SendChatMessage = function() end }
  C.Enable()
  local f = C._frames()
  S.Add({ convKey = "ch:General", text = "hi", sender = "Thorn-Horizon", channelIndex = 1 })
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon" })
  C.Open("w:Brisa-Horizon")
  f.edit:SetText("/2 wts ore")
  C.Submit()
  check("shortcut group: a grouped channel opens in its group", C.ShownKey() == "ch:Trade" and f.tabStrip:IsShown(), tostring(C.ShownKey()))
  check("shortcut group: and the message is filed there", S.Get("ch:Trade") and S.Get("ch:Trade").messages[1].text == "wts ore", "missing")
  C.Disable()
  C_ChatInfo = nil
  GetChannelName = savedChan
  A.GetDB = savedGetDB
  A.ECHO_DEFAULTS, A.ECHO_KEYS, A.ECHO_LIMITS = nil, nil, nil
  S.Reset()
`, 'shortcut-group');


// --- Chat shortcuts fix round 1 ---------------------------------------------------
{
  const enUS = read('locales/horizon/enUS.lua');
  const ok = enUS.includes(`L["ECHO_SHORTCUT_COMMAND"]                                    = "Echo can't run commands yet. Use Blizzard's chat for this."`);
  run(`check("shortcut fix: the command notice makes no promise", ${ok}, "old wording")`, 'shortcut-fix-string');
}
run(`
  local Echo = HorizonSuite.Echo
  local S, Send, V, Gr = Echo.Store, Echo.Send, Echo.View, Echo.Groups
  S.Reset()
  local saved = { IsInGuild = IsInGuild, C_GuildInfo = C_GuildInfo, CreateFrame = CreateFrame }
  local P = Send.ParseShortcut

  -- Name case: an existing whisper wins, case-insensitively; else the first letter is capitalised.
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon" })
  S.Close("w:Brisa-Horizon")
  local r = P("/w brisa hi", "party")
  check("shortcut fix: /w finds an existing whisper whatever the case", r and r.convKey == "w:Brisa-Horizon", r and r.convKey)
  r = P("/w BRISA-horizon hi", "party")
  check("shortcut fix: the realm matches whatever the case too", r and r.convKey == "w:Brisa-Horizon", r and r.convKey)
  r = P("/w vexa hi", "party")
  check("shortcut fix: a new name gets a capital first letter", r and r.convKey == "w:Vexa-Horizon", r and r.convKey)
  r = P("/w vexa-argent hi", "party")
  check("shortcut fix: with its realm kept as typed", r and r.convKey == "w:Vexa-argent", r and r.convKey)
  r = P("/w éowyn hi", "party")
  check("shortcut fix: a non-ASCII first letter is left as typed", r and r.convKey == "w:éowyn-Horizon", r and r.convKey)
  S.Add({ convKey = "bn:7", text = "hi", sender = "Friend" })
  r = P("/w bn:7 hi", "party")
  check("shortcut fix: a Battle.net conversation is never matched", r and r.convKey == "w:Bn:7-Horizon", r and r.convKey)
  S.Reset()

  -- Officer chat asks the client whether you may speak there.
  IsInGuild = function() return true end
  C_GuildInfo = { CanSpeakInOfficerChat = function() return false end }
  check("shortcut fix: /o needs officer rights", Send.CanReach("officer") == false, "reachable")
  r = P("/o hi", "party")
  check("shortcut fix: /o without them goes nowhere", r and r.blocked == "nowhere", r and (r.blocked or r.convKey))
  check("shortcut fix: /g still only needs a guild", Send.CanReach("guild") == true, "unreachable")
  C_GuildInfo.CanSpeakInOfficerChat = function() return true end
  r = P("/o hi", "party")
  check("shortcut fix: /o with them goes to officer", r and r.convKey == "officer", r and (r.blocked or r.convKey))
  C_GuildInfo.CanSpeakInOfficerChat = function() error("boom") end
  check("shortcut fix: a throwing check is unreachable", Send.CanReach("officer") == false, "reachable")
  C_GuildInfo = {}
  check("shortcut fix: without the check, a guild is enough", Send.CanReach("officer") == true, "unreachable")
  IsInGuild = function() return false end
  check("shortcut fix: and no guild is not", Send.CanReach("officer") == false, "reachable")

  -- Ordering: a started conversation is listed first, but it is not a loud one.
  S.SetTier("guild", "loud")
  S.Add({ convKey = "guild", text = "loud", sender = "Thorn-Horizon" })
  local conv = S.Start("w:Brisa-Horizon")
  check("shortcut fix: a started conversation is first", S.List()[1] == conv, S.List()[1].key)
  check("shortcut fix: it carries startedSeq", (conv.startedSeq or 0) > 0 and conv.lastLoud == 0, conv.lastLoud)
  check("shortcut fix: NewestLoud doesn't pick it", V.NewestLoud(S.List()).key == "guild", V.NewestLoud(S.List()).key)
  S.Add({ convKey = "guild", text = "louder", sender = "Thorn-Horizon" })
  check("shortcut fix: a later loud line goes above it", S.List()[1].key == "guild", S.List()[1].key)
  S.Start("w:Brisa-Horizon")
  check("shortcut fix: starting again puts it back on top", S.List()[1].key == "w:Brisa-Horizon", S.List()[1].key)

  IsInGuild, C_GuildInfo, CreateFrame = saved.IsInGuild, saved.C_GuildInfo, saved.CreateFrame
  S.Reset()
`, 'shortcut-fix-1');

// --- Start a chat: the + button and the compose menu ---------------------------------------
{
  const enUS = read('locales/horizon/enUS.lua');
  const ok = /L\["ECHO_NEW_CHAT"\]\s+= "Start a chat"/.test(enUS);
  run(`check("compose: the + tooltip string", ${ok}, "missing")`, 'compose-string');
  const toc = read('HorizonSuite.toc');
  const tocOk = /modules\/Echo\/EchoMenu\.lua\r?\nmodules\/Echo\/EchoCompose\.lua/.test(toc);
  run(`check("compose: EchoCompose.lua loads after EchoMenu.lua", ${tocOk}, "toc order")`, 'compose-toc');
}
run(`
  local Echo = HorizonSuite.Echo
  local S, T, V = Echo.Store, Echo.Tiles, Echo.View
  local Co = Echo.Compose
  check("compose: the module exists", type(Co) == "table" and type(Co.Build) == "function" and type(Co.Open) == "function", type(Co))
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  local saved = {
    IsInGuild = IsInGuild, C_GuildInfo = C_GuildInfo, IsInGroup = IsInGroup, IsInRaid = IsInRaid,
    GetChannelList = GetChannelList, C_FriendList = C_FriendList, BNGetNumFriends = BNGetNumFriends,
    C_BattleNet = C_BattleNet, HOME = LE_PARTY_CATEGORY_HOME, INST = LE_PARTY_CATEGORY_INSTANCE,
    StaticPopupDialogs = StaticPopupDialogs, StaticPopup_Show = StaticPopup_Show, GameTooltip = GameTooltip,
    MenuUtil = MenuUtil, CardOpen = Echo.Card.Open, ComposeOpen = Co.Open,
    GetAutoCompleteResults = GetAutoCompleteResults, AUTOCOMPLETE_LIST = AUTOCOMPLETE_LIST,
  }
  MenuUtil = { CreateContextMenu = function() end }
  T.Enable()

  -- The + button: a small round button just above the Echo icon.
  local plus = T._plusButton and T._plusButton()
  local sb = T._stackButton()
  check("compose: the + button exists", plus ~= nil, "missing")
  check("compose: it is 20x20", plus and plus.width == 20 and plus.height == 20, plus and (tostring(plus.width) .. "x" .. tostring(plus.height)))
  local rr = plus and rawget(plus, "_echoRound")
  check("compose: it is rounded with the SMALL radius", rr ~= nil and rr.corners.tl == Echo.Round.SMALL, "?")
  local pt = plus and plus.points[1]
  check("compose: it sits directly above the Echo icon", pt and pt[1] == "BOTTOM" and pt[2] == sb and pt[3] == "TOP", pt and tostring(pt[1]) .. "/" .. tostring(pt[3]))
  check("compose: it shows a + glyph", plus and plus.glyph and plus.glyph.text == "+", plus and plus.glyph and plus.glyph.text)
  check("compose: it drags the column like the Echo icon", plus and plus.scripts.OnDragStart == sb.scripts.OnDragStart
        and plus.scripts.OnDragStop == sb.scripts.OnDragStop, "different")

  -- The column reserves room for it: the lowest tile sits above the + button.
  S.Add({ convKey = "w:Vexa-Horizon", text = "hi", sender = "Vexa-Horizon" })
  T.Refresh()
  local tile = T.TileFor("w:Vexa-Horizon")
  local y = tile and tile.points[#tile.points][5]
  check("compose: the tiles' bottom limit moved up past the + button", y == T.TilesBottom()
        and T.TilesBottom() >= T.TILE_SIZE + T.GAP + 20 + T.GAP, tostring(y) .. " vs " .. tostring(T.TilesBottom()))

  -- Tooltip and click.
  local tip = {}
  GameTooltip = { SetOwner = function(_, o) tip.owner = o end, SetText = function(_, t) tip.text = t end,
                  Show = function() tip.shown = true end, Hide = function() tip.shown = false end }
  plus.scripts.OnEnter(plus)
  check("compose: the tooltip says Start a chat", tip.text == "ECHO_NEW_CHAT" and tip.owner == plus and tip.shown, tostring(tip.text))
  plus.scripts.OnLeave(plus)
  check("compose: leaving hides the tooltip", tip.shown == false, "shown")
  local openedFrom
  Co.Open = function(owner) openedFrom = owner; return true end
  plus.scripts.OnClick(plus)
  check("compose: clicking opens the compose menu from the button", openedFrom == plus, tostring(openedFrom))
  Co.Open = saved.ComposeOpen
  local ctx
  local keepMenuUtil = MenuUtil
  MenuUtil = { CreateContextMenu = function(owner, gen) ctx = { owner, gen } end }
  check("compose: Open uses MenuUtil", Co.Open(plus) == true and ctx and ctx[1] == plus and type(ctx[2]) == "function", "?")
  MenuUtil = nil
  check("compose: without MenuUtil it does not open", Co.Open(plus) == false, "opened")
  MenuUtil = keepMenuUtil

  -- A started, empty conversation shows a tile; closing it removes the tile.
  S.Start("w:Empty-Horizon")
  T.Refresh()
  check("compose: a started empty conversation has a tile", T.TileFor("w:Empty-Horizon") ~= nil, "no tile")
  S.Close("w:Empty-Horizon")
  T.Refresh()
  check("compose: closing it removes the tile", T.TileFor("w:Empty-Horizon") == nil, "still shown")

  -- A fake MenuUtil root with submenus.
  local function FakeRoot()
    local r = { items = {} }
    function r:CreateButton(label, fn)
      local b = FakeRoot()
      b.label, b.fn = label, fn
      self.items[#self.items + 1] = b
      return b
    end
    function r:CreateTitle(label) self.items[#self.items + 1] = { label = label, title = true, items = {} } end
    function r:CreateDivider() self.items[#self.items + 1] = { divider = true, items = {} } end
    return r
  end
  local function Build()
    local r = FakeRoot()
    Co.Build(r)
    return r.items
  end
  local function Find(items, label)
    for _, it in ipairs(items) do
      if type(it.label) == "string" and it.label:find(label, 1, true) then return it end
    end
    return nil
  end
  local function Labels(items)
    local out = {}
    for _, it in ipairs(items) do if it.label then out[#out + 1] = tostring(it.label) end end
    return table.concat(out, ",")
  end

  -- Out of everything.
  LE_PARTY_CATEGORY_HOME, LE_PARTY_CATEGORY_INSTANCE = 1, 2
  local state = { guild = false, officer = false, home = false, inst = false, raid = false }
  IsInGuild = function() return state.guild end
  C_GuildInfo = { CanSpeakInOfficerChat = function() return state.officer end }
  IsInGroup = function(cat)
    if cat == 1 then return state.home end
    if cat == 2 then return state.inst end
    return state.home or state.inst
  end
  IsInRaid = function() return state.raid end
  GetChannelList = function() end
  C_FriendList = { GetNumFriends = function() return 0 end, GetFriendInfoByIndex = function() return nil end }
  BNGetNumFriends = function() return 0 end
  C_BattleNet = { GetFriendAccountInfo = function() return nil end }

  local items = Build()
  check("compose: alone, only Whisper and Nearby", Labels(items) == "ECHO_COMPOSE_WHISPER,ECHO_NEARBY", Labels(items))
  check("compose: no empty Friends submenu", Find(items, "ECHO_COMPOSE_FRIENDS") == nil, "shown")
  check("compose: no empty Channels submenu", Find(items, "ECHO_COMPOSE_CHANNELS") == nil, "shown")

  state.guild = true
  items = Build()
  check("compose: in a guild, Guild shows", Find(items, "ECHO_KIND_GUILD") ~= nil, Labels(items))
  check("compose: without officer rights, no Officer", Find(items, "ECHO_KIND_OFFICER") == nil, Labels(items))
  state.officer = true
  items = Build()
  check("compose: with officer rights, Officer shows", Find(items, "ECHO_KIND_OFFICER") ~= nil, Labels(items))
  C_GuildInfo = { CanEditOfficerNote = function() return false end }
  items = Build()
  check("compose: the officer-note fallback hides Officer", Find(items, "ECHO_KIND_OFFICER") == nil, Labels(items))
  C_GuildInfo = { CanEditOfficerNote = function() return true end }
  items = Build()
  check("compose: the officer-note fallback shows Officer", Find(items, "ECHO_KIND_OFFICER") ~= nil, Labels(items))

  state.inst = true
  items = Build()
  check("compose: an instance group alone is not a party", Find(items, "ECHO_KIND_PARTY") == nil, Labels(items))
  check("compose: an instance group shows Instance", Find(items, "ECHO_KIND_INSTANCE") ~= nil, Labels(items))
  state.inst, state.home = false, true
  items = Build()
  check("compose: a home group shows Party", Find(items, "ECHO_KIND_PARTY") ~= nil, Labels(items))
  check("compose: not in a raid, no Raid", Find(items, "ECHO_KIND_RAID") == nil, Labels(items))
  check("compose: no instance group, no Instance", Find(items, "ECHO_KIND_INSTANCE") == nil, Labels(items))
  state.raid = true
  items = Build()
  check("compose: in a raid, Raid shows", Find(items, "ECHO_KIND_RAID") ~= nil, Labels(items))
  IsInRaid = function() error("boom") end
  items = Build()
  check("compose: a throwing check hides the entry", Find(items, "ECHO_KIND_RAID") == nil, Labels(items))
  IsInRaid = function() return SECRET(true) end
  items = Build()
  check("compose: a secret answer hides the entry", Find(items, "ECHO_KIND_RAID") == nil, Labels(items))
  IsInRaid = function() return state.raid end

  -- Channels.
  GetChannelList = function()
    return 1, "General", false, 2, "Trade - City", false, 4, "Hidden", true, 5, SECRET("Secret"), false, 6, "mychan", false
  end
  items = Build()
  local ch = Find(items, "ECHO_COMPOSE_CHANNELS")
  check("compose: joined channels are a submenu", ch ~= nil and #ch.items == 3, ch and Labels(ch.items))
  local trade = ch and Find(ch.items, "Trade")
  check("compose: a zone channel drops its zone", trade ~= nil and not trade.label:find("City", 1, true), trade and trade.label)
  check("compose: a known channel shows its icon", trade and trade.label:find(V.CHANNEL_ICONS.Trade, 1, true) ~= nil, trade and trade.label)
  local custom = ch and Find(ch.items, "mychan")
  check("compose: a custom channel has no icon", custom and not custom.label:find("|T", 1, true), custom and custom.label)
  check("compose: disabled and secret channels are skipped", ch and Find(ch.items, "Hidden") == nil and Find(ch.items, "Secret") == nil, ch and Labels(ch.items))
  GetChannelList = function() error("boom") end
  items = Build()
  check("compose: a throwing channel list shows no submenu", Find(items, "ECHO_COMPOSE_CHANNELS") == nil, Labels(items))

  -- Choosing Trade starts ch:Trade and opens the card focused, from its tile.
  GetChannelList = function() return 2, "Trade - City", false end
  items = Build()
  trade = Find(Find(items, "ECHO_COMPOSE_CHANNELS").items, "Trade")
  local opened
  Echo.Card.Open = function(key, focus, fromTile) opened = { key = key, focus = focus, fromTile = fromTile } end
  trade.fn()
  local tradeConv = S.Get("ch:Trade")
  check("compose: choosing Trade starts ch:Trade", tradeConv ~= nil and tradeConv.open == true and #tradeConv.messages == 0, tostring(tradeConv))
  check("compose: it is first", S.List()[1].key == "ch:Trade", S.List()[1].key)
  check("compose: and opens the card focused", opened and opened.key == "ch:Trade" and opened.focus == true, opened and tostring(opened.key))
  check("compose: anchored to its tile", opened and opened.fromTile ~= nil and opened.fromTile == T.TileFor("ch:Trade"), opened and tostring(opened.fromTile))
  opened = nil
  Find(items, "ECHO_NEARBY").fn()
  check("compose: Nearby starts the Say conversation", opened and opened.key == "nearby" and S.Get("nearby").open, opened and opened.key)

  -- Friends online.
  local chars = {
    { connected = true, name = "Brisa" },
    { connected = false, name = "Offline" },
    { connected = true, name = "vexa-Argent" },
    { connected = true, name = SECRET("Hidden") },
    { connected = SECRET(true), name = "Maybe" },
    { connected = true, name = "|Kq9|k" },
  }
  C_FriendList = { GetNumFriends = function() return #chars end, GetFriendInfoByIndex = function(i) return chars[i] end }
  local bnLabel = "|Kq12|k"
  local bns = {
    { bnetAccountID = 7, accountName = bnLabel, gameAccountInfo = { isOnline = true } },
    { bnetAccountID = 8, accountName = "|Kq13|k", gameAccountInfo = { isOnline = false } },
    { bnetAccountID = SECRET(9), accountName = "|Kq14|k", gameAccountInfo = { isOnline = true } },
  }
  BNGetNumFriends = function() return #bns, 1 end
  C_BattleNet = { GetFriendAccountInfo = function(i) return bns[i] end }
  items = Build()
  local fr = Find(items, "ECHO_COMPOSE_FRIENDS")
  check("compose: online friends are a submenu", fr ~= nil and #fr.items == 3, fr and Labels(fr.items))
  check("compose: offline, secret and |K character friends are skipped", fr and Find(fr.items, "Offline") == nil
        and Find(fr.items, "Maybe") == nil and Find(fr.items, "q9") == nil and Find(fr.items, "q14") == nil, fr and Labels(fr.items))
  local bn = fr and Find(fr.items, "q12")
  check("compose: a Battle.net friend is labelled with its |K name, whole", bn and bn.label == bnLabel, bn and bn.label)
  opened = nil
  bn.fn()
  check("compose: choosing a Battle.net friend starts bn:<id>", opened and opened.key == "bn:7" and S.Get("bn:7") ~= nil, opened and opened.key)
  opened = nil
  Find(fr.items, "vexa").fn()
  check("compose: a character friend starts a whisper with a realm and a capital", opened and opened.key == "w:Vexa-Argent", opened and opened.key)
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon" })
  S.Close("w:Brisa-Horizon")
  opened = nil
  Find(fr.items, "Brisa").fn()
  check("compose: a friend reopens their existing whisper", opened and opened.key == "w:Brisa-Horizon", opened and opened.key)
  HorizonSuite.Platform.caps.bnetWhispers = false
  items = Build()
  fr = Find(items, "ECHO_COMPOSE_FRIENDS")
  check("compose: without Battle.net whispers, no Battle.net friends", fr and #fr.items == 2 and Find(fr.items, "q12") == nil, fr and Labels(fr.items))
  HorizonSuite.Platform.caps.bnetWhispers = true
  local many = {}
  for i = 1, 25 do many[i] = { connected = true, name = "Friend" .. i } end
  C_FriendList = { GetNumFriends = function() return #many end, GetFriendInfoByIndex = function(i) return many[i] end }
  items = Build()
  fr = Find(items, "ECHO_COMPOSE_FRIENDS")
  check("compose: at most 20 friends", fr and #fr.items == 20, fr and #fr.items)
  C_FriendList = { GetNumFriends = function() error("boom") end }
  BNGetNumFriends = function() error("boom") end
  items = Build()
  check("compose: throwing friends lists show no submenu", Find(items, "ECHO_COMPOSE_FRIENDS") == nil, Labels(items))

  -- Whisper...: a StaticPopup with an edit box, registered on first use.
  StaticPopupDialogs = {}
  local shownWhich
  StaticPopup_Show = function(which) shownWhich = which end
  GetAutoCompleteResults = function() end
  AUTOCOMPLETE_LIST = { WHISPER = { include = 1, exclude = 2 } }
  check("compose: the popup isn't registered before use", StaticPopupDialogs.HORIZON_ECHO_NEW_WHISPER == nil, "registered")
  Find(Build(), "ECHO_COMPOSE_WHISPER").fn()
  local dlg = StaticPopupDialogs.HORIZON_ECHO_NEW_WHISPER
  check("compose: Whisper... shows the popup", shownWhich == "HORIZON_ECHO_NEW_WHISPER" and dlg ~= nil, tostring(shownWhich))
  check("compose: it has an edit box, accept and enter", dlg and dlg.hasEditBox and type(dlg.OnAccept) == "function"
        and type(dlg.EditBoxOnEnterPressed) == "function", "?")
  check("compose: it suggests names", dlg and dlg.autoCompleteSource == GetAutoCompleteResults and type(dlg.autoCompleteArgs) == "table"
        and dlg.autoCompleteArgs[1] == 1 and dlg.autoCompleteArgs[2] == 2, dlg and tostring(dlg.autoCompleteArgs))
  local function Popup(text, field)
    local box = { GetText = function() return text end }
    return { [field or "editBox"] = box }, box
  end
  opened = nil
  dlg.OnAccept(Popup("  thorn  "))
  check("compose: accepting a name normalises it and starts the whisper", S.Get("w:Thorn-Horizon") and S.Get("w:Thorn-Horizon").open
        and opened and opened.key == "w:Thorn-Horizon" and opened.focus == true, opened and opened.key)
  opened = nil
  dlg.OnAccept(Popup("brisa", "EditBox"))
  check("compose: the new EditBox field works, and matches an existing whisper", opened and opened.key == "w:Brisa-Horizon", opened and opened.key)
  local hidden
  local popup, box = Popup("Kael-Argent")
  box.GetParent = function() return { Hide = function() hidden = true end } end
  opened = nil
  dlg.EditBoxOnEnterPressed(box)
  check("compose: Enter accepts too, and closes the popup", opened and opened.key == "w:Kael-Argent" and hidden, opened and opened.key)
  opened = nil
  dlg.OnAccept(Popup("|Kq12|k"))
  check("compose: a |K name is never parsed", opened == nil and S.Get("w:|Kq12|k-Horizon") == nil, opened and opened.key)
  dlg.OnAccept(Popup(SECRET("Brisa")))
  dlg.OnAccept(Popup(""))
  dlg.OnAccept(Popup("two words"))
  check("compose: secret, blank and spaced names start nothing", opened == nil, opened and opened.key)
  local first = dlg
  Find(Build(), "ECHO_COMPOSE_WHISPER").fn()
  check("compose: the popup is registered once", StaticPopupDialogs.HORIZON_ECHO_NEW_WHISPER == first, "replaced")
  AUTOCOMPLETE_LIST, GetAutoCompleteResults = nil, nil
  StaticPopupDialogs = {}
  Find(Build(), "ECHO_COMPOSE_WHISPER").fn()
  dlg = StaticPopupDialogs.HORIZON_ECHO_NEW_WHISPER
  check("compose: without autocomplete the popup still works", dlg and dlg.autoCompleteSource == nil and dlg.autoCompleteArgs == nil, "?")

  Echo.Card.Open = saved.CardOpen
  IsInGuild, C_GuildInfo, IsInGroup, IsInRaid = saved.IsInGuild, saved.C_GuildInfo, saved.IsInGroup, saved.IsInRaid
  GetChannelList, C_FriendList, BNGetNumFriends, C_BattleNet = saved.GetChannelList, saved.C_FriendList, saved.BNGetNumFriends, saved.C_BattleNet
  LE_PARTY_CATEGORY_HOME, LE_PARTY_CATEGORY_INSTANCE = saved.HOME, saved.INST
  StaticPopupDialogs, StaticPopup_Show, GameTooltip, MenuUtil = saved.StaticPopupDialogs, saved.StaticPopup_Show, saved.GameTooltip, saved.MenuUtil
  GetAutoCompleteResults, AUTOCOMPLETE_LIST = saved.GetAutoCompleteResults, saved.AUTOCOMPLETE_LIST
  T.Disable()
  S.Reset()
`, 'compose');

// --- Plan 11 final review: group checks and the + button fallback ------------------------
run(`
  local Echo = HorizonSuite.Echo
  local S, T, Send, M, Co = Echo.Store, Echo.Tiles, Echo.Send, Echo.Menu, Echo.Compose
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  local saved = { IsInGroup = IsInGroup, IsInRaid = IsInRaid, HOME = LE_PARTY_CATEGORY_HOME,
                  INST = LE_PARTY_CATEGORY_INSTANCE, MenuUtil = MenuUtil }

  -- Raid: the home raid only. An LFR raid is an instance group.
  LE_PARTY_CATEGORY_HOME, LE_PARTY_CATEGORY_INSTANCE = 1, 2
  local home, inst = false, true
  IsInRaid = function(cat)
    if cat == 1 then return home end
    if cat == 2 then return inst end
    return home or inst
  end
  IsInGroup = IsInRaid
  check("review: an instance-only raid is not Raid", Send.CanReach("raid") == false, "reachable")
  check("review: an instance-only raid is not Party", Send.CanReach("party") == false, "reachable")
  check("review: an instance-only raid is Instance", Send.CanReach("instance") == true, "unreachable")
  home = true
  check("review: a home raid is Raid", Send.CanReach("raid") == true, "unreachable")

  -- Instance: without the category constant, never reachable.
  LE_PARTY_CATEGORY_INSTANCE = nil
  check("review: no instance category, no Instance", Send.CanReach("instance") == false, "reachable")
  LE_PARTY_CATEGORY_INSTANCE = 2

  -- Compose uses CanReach for Party.
  local savedReach = Send.CanReach
  local asked = {}
  Send.CanReach = function(kind) asked[kind] = true; return kind == "party" end
  local r = { items = {} }
  function r:CreateButton(label, fn) local b = { label = label, fn = fn, items = {} }; b.CreateButton = r.CreateButton; self.items[#self.items + 1] = b; return b end
  function r:CreateDivider() end
  function r:CreateTitle() end
  Co.Build(r)
  local party = false
  for _, it in ipairs(r.items) do if it.label == "ECHO_KIND_PARTY" then party = true end end
  check("review: compose asks CanReach for Party", asked.party == true and party, tostring(asked.party))
  Send.CanReach = savedReach

  -- A throwing MenuUtil: every open reports false instead of raising.
  MenuUtil = { CreateContextMenu = function() error("protected") end }
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon" })
  local okC, resC = pcall(Co.Open, UIParent)
  check("review: Compose.Open catches a throwing menu", okC and resC == false, tostring(okC) .. "/" .. tostring(resC))
  local okM, resM = pcall(M.Open, UIParent, "w:Brisa-Horizon")
  check("review: Menu.Open catches a throwing menu", okM and resM == false, tostring(okM) .. "/" .. tostring(resM))
  local okO, resO = pcall(M.OpenMessage, UIParent, "w:Brisa-Horizon", S.Get("w:Brisa-Horizon").messages[1])
  check("review: Menu.OpenMessage catches a throwing menu", okO and resO == false, tostring(okO) .. "/" .. tostring(resO))
  MenuUtil = { CreateContextMenu = function() end }
  check("review: Compose.Open reports a working menu", Co.Open(UIParent) == true, "false")

  -- No MenuUtil: the + button stays hidden and the tiles drop back to one step up.
  MenuUtil = nil
  T.Enable()
  local plus = T._plusButton()
  check("review: without MenuUtil the + button is hidden", plus and not plus:IsShown(), "shown")
  check("review: and the tiles start one step up", T.TilesBottom() == T.TILE_SIZE + T.GAP, T.TilesBottom())
  local tile = T.TileFor("w:Brisa-Horizon")
  check("review: the lowest tile sits one step up", tile and tile.points[#tile.points][5] == T.TILE_SIZE + T.GAP,
        tile and tile.points[#tile.points][5])
  MenuUtil = { CreateContextMenu = function() end }
  T.Refresh()
  check("review: with MenuUtil the + button shows", plus:IsShown(), "hidden")
  check("review: and the tiles make room for it", T.TilesBottom() == T.TILE_SIZE + T.GAP + T.PLUS_SIZE + T.GAP, T.TilesBottom())
  tile = T.TileFor("w:Brisa-Horizon")
  check("review: the lowest tile moves above it", tile and tile.points[#tile.points][5] == T.TilesBottom(),
        tile and tile.points[#tile.points][5])

  T.Disable()
  IsInGroup, IsInRaid, MenuUtil = saved.IsInGroup, saved.IsInRaid, saved.MenuUtil
  LE_PARTY_CATEGORY_HOME, LE_PARTY_CATEGORY_INSTANCE = saved.HOME, saved.INST
  S.Reset()
`, 'plan11-review');

// --- Whisper or invite a message's sender, /inv, and NPC names ------------------------------
run(`
  local A = HorizonSuite
  local Echo = A.Echo
  local S, E, V, M, C, K, T, Send = Echo.Store, Echo.Events, Echo.View, Echo.Menu, Echo.Card, Echo.Stack, Echo.Tiles, Echo.Send
  S.Reset()
  Echo.ClearDrafts()
  CreateFrame = STUB_CREATE_FRAME
  local saved = { IsInGroup = IsInGroup, Leader = UnitIsGroupLeader, Assist = UnitIsGroupAssistant,
                  C_PartyInfo = C_PartyInfo, InviteUnit = InviteUnit, C_Timer = C_Timer, MenuUtil = MenuUtil }
  rawset(A.L, "ECHO_WHISPER_NAME", "Whisper %s")
  rawset(A.L, "ECHO_INVITE_NAME", "Invite %s")
  rawset(A.L, "ECHO_INVITED", "Invited %s.")
  local function payload(text, sender)
    return text, sender, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
  end

  -- 1. NPC senders keep their plain name.
  for _, ev in ipairs({ "CHAT_MSG_MONSTER_SAY", "CHAT_MSG_MONSTER_YELL", "CHAT_MSG_MONSTER_EMOTE" }) do
    local r = E.BuildRecord(ev, payload("Welcome, hero.", "Elina Stillwind"))
    check("npc: " .. ev .. " keeps the plain name", r and r.sender == "Elina Stillwind", r and tostring(r.sender))
    check("npc: " .. ev .. " is marked npc", r and r.npc == true, r and tostring(r.npc))
  end
  local say = E.BuildRecord("CHAT_MSG_SAY", payload("hi", "Brisa"))
  check("npc: a player's Say still has Name-Realm", say.sender == "Brisa-Horizon" and not say.npc, say.sender)

  -- 2. View.MessageSender.
  local MS = V.MessageSender
  check("sender: a player's channel line", MS("ch:Trade", { text = "wts", sender = "Brisa-Horizon" }) == "Brisa-Horizon", tostring(MS("ch:Trade", { text = "wts", sender = "Brisa-Horizon" })))
  check("sender: an NPC line has none", MS("nearby", { text = "hi", sender = "Hogger", npc = true, style = "npc" }) == nil, "named")
  check("sender: an NPC style without the flag has none", MS("nearby", { text = "hi", sender = "Hogger", style = "npcyell" }) == nil, "named")
  check("sender: your own line has none", MS("ch:Trade", { text = "wts", outgoing = true }) == nil, "named")
  check("sender: your own name has none", MS("ch:Trade", { text = "wts", sender = "Kaelis-Horizon" }) == nil, "named")
  check("sender: Battle.net has none", MS("bn:7", { text = "hi", sender = "|Kq7|k" }) == nil, "named")
  check("sender: a secret sender has none", MS("ch:Trade", { text = "wts", sender = SECRET("Brisa-Horizon") }) == nil, "named")
  check("sender: secret text has none", MS("ch:Trade", { text = SECRET("wts"), secret = true, sender = "Brisa-Horizon" }) == nil, "named")
  check("sender: a name with a space has none", MS("nearby", { text = "hi", sender = "Elina Stillwind-Horizon", style = "say" }) == nil, "named")
  check("sender: a name with | has none", MS("guild", { text = "hi", sender = "|cffBrisa-Horizon" }) == nil, "named")
  check("sender: a missing sender has none", MS("guild", { text = "hi" }) == nil, "named")
  check("sender: a demo line has none", MS("guild", { text = "hi", sender = "Brisa-Horizon", demo = true }) == nil, "named")
  check("sender: an incoming whisper is the conversation's name", MS("w:Brisa-Horizon", { text = "hi", sender = "Brisa-Horizon" }) == "Brisa-Horizon", "none")
  check("sender: an incoming whisper with no sender is the conversation's name", MS("w:Brisa-Horizon", { text = "hi" }) == "Brisa-Horizon", "none")
  check("sender: a feed line has none", MS("loot", { text = "You receive loot", feed = true, sender = "Brisa-Horizon" }) == nil, "named")

  -- 3. The message menu.
  local function FakeRoot()
    local r = { items = {} }
    function r:CreateButton(label, fn)
      local b = { label = label, fn = fn, enabled = true }
      function b:SetEnabled(v) self.enabled = v end
      self.items[#self.items + 1] = b
      return b
    end
    function r:CreateTitle(label) self.items[#self.items + 1] = { label = label, title = true } end
    function r:CreateDivider() self.items[#self.items + 1] = { divider = true } end
    return r
  end
  local function Build(key, record)
    local r = FakeRoot()
    M.BuildMessage(r, key, record)
    return r.items
  end
  local function Find(items, label)
    for _, it in ipairs(items) do if it.label == label then return it end end
    return nil
  end
  IsInGroup = function() return false end
  S.Add({ convKey = "ch:Trade", text = "wts cloth", sender = "Brisa-Horizon" })
  local trade = S.Get("ch:Trade").messages[1]
  local items = Build("ch:Trade", trade)
  check("menu: a Trade line offers Whisper", Find(items, "Whisper Brisa") ~= nil, #items)
  check("menu: a Trade line offers Invite", Find(items, "Invite Brisa") ~= nil, #items)
  check("menu: the pin entry stays first", items[1] and items[1].label == "ECHO_PIN_BLOCKED_UNSAVED" and items[1].enabled == false, items[1] and items[1].label)
  check("menu: a divider comes before them", items[2] and items[2].divider, "no divider")
  S.Add({ convKey = "nearby", text = "Welcome.", sender = "Elina Stillwind", npc = true, style = "npc" })
  items = Build("nearby", S.Get("nearby").messages[1])
  check("menu: an NPC line offers neither", Find(items, "Whisper Elina Stillwind") == nil and Find(items, "Invite Elina Stillwind") == nil and #items == 1, #items)
  S.Add({ convKey = "w:Brisa-Horizon", text = "hey", sender = "Brisa-Horizon" })
  items = Build("w:Brisa-Horizon", S.Get("w:Brisa-Horizon").messages[1])
  check("menu: no Whisper inside that person's whisper", Find(items, "Whisper Brisa") == nil, "shown")
  check("menu: Invite still inside the whisper", Find(items, "Invite Brisa") ~= nil, "hidden")
  IsInGroup = function() return true end
  UnitIsGroupLeader = function() return false end
  UnitIsGroupAssistant = function() return false end
  items = Build("ch:Trade", trade)
  check("menu: in a group you don't lead, no Invite", Find(items, "Invite Brisa") == nil, "shown")
  check("menu: but Whisper stays", Find(items, "Whisper Brisa") ~= nil, "hidden")
  UnitIsGroupAssistant = function() return true end
  items = Build("ch:Trade", trade)
  check("menu: an assistant can invite", Find(items, "Invite Brisa") ~= nil, "hidden")
  UnitIsGroupAssistant = function() return false end
  UnitIsGroupLeader = function() return true end
  items = Build("ch:Trade", trade)
  check("menu: a leader can invite", Find(items, "Invite Brisa") ~= nil, "hidden")
  UnitIsGroupLeader, UnitIsGroupAssistant = nil, nil
  items = Build("ch:Trade", trade)
  check("menu: without the leader checks, Invite shows", Find(items, "Invite Brisa") ~= nil, "hidden")
  IsInGroup = function() return false end

  -- Invite runs through Menu.InviteName.
  local invited
  C_PartyInfo = { InviteUnit = function(t) invited = t end }
  items = Build("ch:Trade", trade)
  Find(items, "Invite Brisa").fn()
  check("menu: Invite invites the sender", invited == "Brisa-Horizon", tostring(invited))
  invited = nil
  check("InviteName: invites a name", M.InviteName("Vexa-Horizon") == true and invited == "Vexa-Horizon", tostring(invited))
  C_PartyInfo, InviteUnit = nil, function(t) invited = t end
  M.InviteName("Thorn-Horizon")
  check("InviteName: falls back to InviteUnit", invited == "Thorn-Horizon", tostring(invited))
  InviteUnit = function() error("boom") end
  check("InviteName: survives a throwing invite", pcall(M.InviteName, "Thorn-Horizon"), "threw")
  InviteUnit = nil
  check("InviteName: no invite function is false", M.InviteName("Thorn-Horizon") == false, "true")
  local realInviteName, via = M.InviteName, nil
  M.InviteName = function(n) via = n; return true end
  M.Run("w:Brisa-Horizon", "invite")
  check("the ⋯ menu invite goes through InviteName", via == "Brisa-Horizon", tostring(via))
  M.InviteName = realInviteName

  -- Whisper opens or starts the conversation, reusing a case-insensitive match.
  T.Enable()
  C.Enable()
  items = Build("ch:Trade", trade)
  Find(items, "Whisper Brisa").fn()
  check("menu: Whisper opens the whisper card", C.IsShown() and C.ShownKey() == "w:Brisa-Horizon", tostring(C.ShownKey()))
  S.Add({ convKey = "ch:Trade", text = "lfg", sender = "Vexa-Horizon" })
  local vexa = S.Get("ch:Trade").messages[2]
  Find(Build("ch:Trade", vexa), "Whisper Vexa").fn()
  check("menu: Whisper starts a new whisper", S.Get("w:Vexa-Horizon") ~= nil and C.ShownKey() == "w:Vexa-Horizon", tostring(C.ShownKey()))
  check("menu: the started whisper is open", S.Get("w:Vexa-Horizon").open == true, "closed")
  S.Add({ convKey = "w:thorn-Horizon", text = "yo", sender = "thorn-Horizon" })
  S.Add({ convKey = "ch:Trade", text = "wtb", sender = "Thorn-Horizon" })
  local thorn = S.Get("ch:Trade").messages[3]
  Find(Build("ch:Trade", thorn), "Whisper Thorn").fn()
  check("menu: Whisper reuses a case-insensitive match", C.ShownKey() == "w:thorn-Horizon" and S.Get("w:Thorn-Horizon") == nil, tostring(C.ShownKey()))
  check("menu: the matched whisper hides Whisper", Find(Build("w:thorn-Horizon", thorn), "Whisper Thorn") == nil, "shown")

  -- 4. /inv and /invite.
  local P = Send.ParseShortcut
  local r = P("/inv Brisa", "guild")
  check("inv: /inv Brisa is an invite with the realm", r and r.action == "invite" and r.name == "Brisa-Horizon" and r.convKey == nil, r and tostring(r.name))
  r = P("/invite vexa", "guild")
  check("inv: /invite capitalises and adds the realm", r and r.action == "invite" and r.name == "Vexa-Horizon", r and tostring(r.name))
  r = P("/INV Brisa-Other", "guild")
  check("inv: a given realm is kept", r and r.name == "Brisa-Other", r and tostring(r.name))
  r = P("/inv", "w:Brisa-Horizon")
  check("inv: /inv in a whisper invites that person", r and r.action == "invite" and r.name == "Brisa-Horizon", r and tostring(r.name or r.blocked))
  r = P("/inv", "guild")
  check("inv: /inv elsewhere is nowhere", r and r.blocked == "nowhere", r and tostring(r.blocked or r.action))
  r = P("/inv", "bn:7")
  check("inv: /inv in Battle.net is nowhere", r and r.blocked == "nowhere", r and tostring(r.blocked or r.action))
  r = P("/inv |Kq1|k", "guild")
  check("inv: a |K name is nowhere", r and r.blocked == "nowhere", r and tostring(r.blocked or r.action))
  SLASH_INVITE2 = "/einladen"
  r = P("/einladen Brisa", "guild")
  check("inv: a localised global works", r and r.action == "invite" and r.name == "Brisa-Horizon", r and tostring(r.name or r.blocked))
  SLASH_INVITE2 = nil

  -- Card and stack: invite, clear the box, say so for 3 seconds, send nothing.
  local timers = {}
  C_Timer = { After = function(sec, fn) timers[#timers + 1] = { sec = sec, fn = fn } end,
              NewTimer = function() return { Cancel = function() end } end }
  local realSend, sent = Send.Send, {}
  Send.Send = function(key, text) sent[#sent + 1] = key .. ":" .. text; return false end
  invited = nil
  C_PartyInfo = { InviteUnit = function(t) invited = t end }
  local f = C._frames()
  S.Add({ convKey = "guild", text = "hi", sender = "Morn-Horizon" })
  C.Open("guild")
  f.edit:SetText("/inv Brisa")
  C.Submit()
  check("inv card: invites", invited == "Brisa-Horizon", tostring(invited))
  check("inv card: sends nothing", #sent == 0, sent[1])
  check("inv card: empties the box", f.edit:GetText() == "", f.edit:GetText())
  check("inv card: says so", f.hint.shown and f.hint.text.text == "Invited Brisa.", f.hint.text.text)
  check("inv card: for 3 seconds", timers[#timers] and timers[#timers].sec == 3, timers[#timers] and timers[#timers].sec)
  check("inv card: stays on its conversation", C.ShownKey() == "guild", tostring(C.ShownKey()))
  timers[#timers].fn()
  check("inv card: then the hint goes", f.hint.shown == false, "shown")
  invited = nil
  C.Open("w:Vexa-Horizon")
  f.edit:SetText("/inv")
  C.Submit()
  check("inv card: /inv in a whisper card invites that person", invited == "Vexa-Horizon", tostring(invited))
  f.edit:SetText("/inv")
  C.Open("guild")
  f.edit:SetText("/inv")
  invited = nil
  C.Submit()
  check("inv card: /inv elsewhere says nowhere", invited == nil and f.hint.text.text == "ECHO_SHORTCUT_NOWHERE", f.hint.text.text)
  f.edit:SetText("")

  C.Hide()
  K.Enable()
  local k = K._frames()
  K.Open("guild")
  invited = nil
  k.edit:SetText("/invite Morn")
  k.edit.scripts.OnEnterPressed(k.edit)
  check("inv stack: invites", invited == "Morn-Horizon", tostring(invited))
  check("inv stack: sends nothing", #sent == 0, sent[1])
  check("inv stack: empties the box", k.edit:GetText() == "", k.edit:GetText())
  check("inv stack: says so", k.notice.shown and k.notice.text.text == "Invited Morn.", k.notice.text.text)
  check("inv stack: for 3 seconds", timers[#timers].sec == 3, timers[#timers].sec)
  check("inv stack: stays open", k.root.shown and not C.IsShown(), "closed")
  timers[#timers].fn()
  check("inv stack: then the notice goes", k.notice.shown == false, "shown")

  -- 5. InviteTarget backstop.
  check("InviteTarget: a spaced whisper name has none", V.InviteTarget({ kind = "whisper", key = "w:Elina Stillwind-Horizon" }) == nil, "targeted")
  check("InviteTarget: a | whisper name has none", V.InviteTarget({ kind = "whisper", key = "w:|Kq1|k" }) == nil, "targeted")

  K.Disable()
  C.Disable()
  T.Disable()
  Send.Send = realSend
  IsInGroup, UnitIsGroupLeader, UnitIsGroupAssistant = saved.IsInGroup, saved.Leader, saved.Assist
  C_PartyInfo, InviteUnit, C_Timer, MenuUtil = saved.C_PartyInfo, saved.InviteUnit, saved.C_Timer, saved.MenuUtil
  rawset(A.L, "ECHO_WHISPER_NAME", nil)
  rawset(A.L, "ECHO_INVITE_NAME", nil)
  rawset(A.L, "ECHO_INVITED", nil)
  S.Reset()
`, 'echo-invite');

// --- Input probe: point Blizzard's input line at a chat (plan 12, Task 1) --------------------
run(`
  local A = HorizonSuite
  PROBE_SAVED = { reg = A.RegisterSlashHandler, print = A.HSPrint, enabled = A.IsModuleEnabled,
    strtrim = strtrim, box = ChatFrame1EditBox, combat = InCombatLockdown }
  PROBE_OUT = {}
  A.RegisterSlashHandler = function(key, fn) if key == "echo" then PROBE_HANDLER = fn end end
  A.HSPrint = function(s) PROBE_OUT[#PROBE_OUT + 1] = tostring(s) end
  A.IsModuleEnabled = function() return true end
  strtrim = strtrim or function(s) return (s:match("^%s*(.-)%s*$")) end
  InCombatLockdown = function() return false end
`, 'probe-input-stubs');
run(read('modules/Echo/EchoSlash.lua'), 'modules/Echo/EchoSlash.lua (probe input)');
run(`
  local A = HorizonSuite
  local calls = {}
  local attrs = {}
  ChatFrame1EditBox = {
    SetAttribute = function(_, k, v) calls[#calls + 1] = k .. "=" .. tostring(v); attrs[k] = v end,
    GetAttribute = function(_, k) return attrs[k] end,
  }
  local function printed(key)
    for _, s in ipairs(PROBE_OUT) do if s:find(key, 1, true) then return true end end
    return false
  end
  check("probe input: the slash handler is registered", type(PROBE_HANDLER) == "function", type(PROBE_HANDLER))

  PROBE_HANDLER("probe input guild")
  check("probe input guild: chatType is GUILD", attrs.chatType == "GUILD", attrs.chatType)
  check("probe input guild: prints the four steps", printed("ECHO_PROBE_INPUT_STEP1") and printed("ECHO_PROBE_INPUT_STEP2")
    and printed("ECHO_PROBE_INPUT_STEP3") and printed("ECHO_PROBE_INPUT_STEP4"), table.concat(PROBE_OUT, " | "))

  PROBE_HANDLER("probe input SAY")
  check("probe input say: chatType is SAY, whatever the case", attrs.chatType == "SAY", attrs.chatType)

  PROBE_HANDLER("probe input Brisa-Horizon")
  check("probe input whisper: chatType is WHISPER", attrs.chatType == "WHISPER", attrs.chatType)
  check("probe input whisper: tellTarget keeps the name as typed", attrs.tellTarget == "Brisa-Horizon", attrs.tellTarget)

  PROBE_OUT = {}
  PROBE_HANDLER("probe input reset")
  check("probe input reset: chatType back to SAY", attrs.chatType == "SAY", attrs.chatType)
  check("probe input reset: says so", printed("ECHO_PROBE_INPUT_RESET"), table.concat(PROBE_OUT, " | "))

  local before = #calls
  PROBE_OUT = {}
  PROBE_HANDLER("probe input Brisa")
  check("probe input: a name without a realm is refused", #calls == before and printed("ECHO_PROBE_INPUT_USAGE"), #calls - before)
  PROBE_HANDLER("probe input")
  check("probe input: no target is refused", #calls == before, #calls - before)

  InCombatLockdown = function() return true end
  PROBE_OUT = {}
  PROBE_HANDLER("probe input guild")
  check("probe input: refused in combat", #calls == before and printed("ECHO_PROBE_INPUT_COMBAT"), #calls - before)
  PROBE_HANDLER("probe input reset")
  check("probe input reset: refused in combat too", #calls == before, #calls - before)
  InCombatLockdown = function() return false end

  ChatFrame1EditBox = nil
  PROBE_OUT = {}
  check("probe input: no input line is reported, not an error", pcall(PROBE_HANDLER, "probe input guild") and printed("ECHO_PROBE_INPUT_NONE"), table.concat(PROBE_OUT, " | "))

  PROBE_OUT = {}
  PROBE_HANDLER("help")
  check("probe input: listed in the help", printed("ECHO_SLASH_HELP_PROBE_INPUT"), table.concat(PROBE_OUT, " | "))

  A.RegisterSlashHandler, A.HSPrint, A.IsModuleEnabled = PROBE_SAVED.reg, PROBE_SAVED.print, PROBE_SAVED.enabled
  strtrim, ChatFrame1EditBox, InCombatLockdown = PROBE_SAVED.strtrim, PROBE_SAVED.box, PROBE_SAVED.combat
  PROBE_SAVED, PROBE_OUT, PROBE_HANDLER = nil, nil, nil
`, 'probe-input');
{
  // The probe is the only code that may call SetAttribute on Blizzard's input line: no other
  // Echo source calls SetAttribute at all, and in EchoSlash.lua every call sits inside the
  // probe's own function, which names ChatFrame1EditBox.
  const sources = fs.readdirSync(REPO + 'modules/Echo').filter(f => f.endsWith('.lua'))
    .map(f => 'modules/Echo/' + f);
  const callers = sources.filter(f => read(f).includes('SetAttribute('));
  const slash = read('modules/Echo/EchoSlash.lua');
  const start = slash.indexOf('local function ProbeInput(');
  const end = start >= 0 ? slash.indexOf('\nend', start) : -1;
  const body = start >= 0 && end > start ? slash.slice(start, end) : '';
  const outside = (slash.slice(0, Math.max(start, 0)) + (end > 0 ? slash.slice(end) : '')).split('SetAttribute(').length - 1;
  run(`
    check("probe input: only EchoSlash.lua calls SetAttribute", ${JSON.stringify(callers.join(','))} == "modules/Echo/EchoSlash.lua",
      ${JSON.stringify(callers.join(','))})
    check("probe input: every SetAttribute in EchoSlash.lua is the probe's", ${outside} == 0 and ${body.includes('SetAttribute(')}, ${outside})
    check("probe input: the probe names ChatFrame1EditBox", ${body.includes('ChatFrame1EditBox')}, "not named")
  `, 'probe-input-grep');
}

// --- Input: Blizzard's input line, docked under Echo and restyled (plan 12, Task 2) -----------
run(`
  local A, Echo = HorizonSuite, HorizonSuite.Echo
  local S, T, K, C, I, V = Echo.Store, Echo.Tiles, Echo.Stack, Echo.Card, Echo.Input, Echo.View
  local saved = { hook = hooksecurefunc, util = ChatFrameUtil, box = ChatFrame1EditBox, info = ChatTypeInfo,
    chan = GetChannelName, getDB = A.GetDB, setDB = A.SetDB, create = CreateFrame, defaults = A.ECHO_DEFAULTS }
  local db = {}
  A.GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  A.SetDB = function(k, v) db[k] = v end
  A.ECHO_DEFAULTS = nil
  CreateFrame = STUB_CREATE_FRAME
  check("input: EchoInput.lua is loaded", I ~= nil, "no Echo.Input")

  -- A stand-in for Blizzard's ChatFrame1EditBox that records every call Echo makes.
  local function Region(kind, alpha)
    local r = { kind = kind, alpha = alpha, font = { "Fonts\\\\ARIALN.TTF", 14, "OUTLINE" } }
    function r:IsObjectType(t) return t == self.kind end
    function r:GetAlpha() return self.alpha end
    function r:SetAlpha(a) self.alpha = a end
    function r:GetFont() return self.font[1], self.font[2], self.font[3] end
    function r:SetFont(p, s, f) self.font = { p, s, f } end
    return r
  end
  local chatFrame = STUB_FRAME()
  local box = { calls = { focus = 0, attribute = 0 }, attrs = { chatType = "SAY" }, scale = 0.9, alpha = 1,
    shown = false, level = 5, strata = "LOW",
    points = { { "BOTTOMLEFT", chatFrame, "TOPLEFT", -5, -2 }, { "BOTTOMRIGHT", chatFrame, "TOPRIGHT", 5, -2 } } }
  local regions = { Region("Texture", 1), Region("Texture", 0.8), Region("FontString", 1) }
  function box:GetNumPoints() return #self.points end
  function box:GetPoint(i) local p = self.points[i]; return p[1], p[2], p[3], p[4], p[5] end
  function box:ClearAllPoints() self.points = {} end
  function box:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function box:GetScale() return self.scale end
  function box:SetScale(s) self.scale = s end
  function box:GetAlpha() return self.alpha end
  function box:SetAlpha(a) self.alpha = a end
  function box:Show() self.shown = true end
  function box:Hide() self.shown = false end
  function box:SetShown(v) self.shown = v and true or false end
  function box:IsShown() return self.shown end
  function box:GetRegions() return regions[1], regions[2], regions[3] end
  function box:GetAttribute(k) return self.attrs[k] end
  function box:SetAttribute() self.calls.attribute = self.calls.attribute + 1 end
  function box:SetFocus() self.calls.focus = self.calls.focus + 1 end
  function box:HasFocus() return self.focus == true end
  function box:GetFrameLevel() return self.level end
  function box:GetFrameStrata() return self.strata end
  function box:SetFrameStrata(v) self.strata = v end
  box.font = { "Fonts\\\\ARIALN.TTF", 14, "" }
  function box:GetFont() return self.font[1], self.font[2], self.font[3] end
  function box:SetFont(p, sz, fl) self.font = { p, sz, fl } end
  box.hookScripts = {}
  function box:HookScript(n, fn) self.hookScripts[n] = fn end
  local other = { shown = false }
  function other:Show() self.shown = true end
  ChatFrame1EditBox = box
  local originalPoints = { { box:GetPoint(1) }, { box:GetPoint(2) } }

  local hooks = {}
  local setPointHooks = 0
  hooksecurefunc = function(a, b, c)
    if type(a) == "table" then hooks[#hooks + 1] = { target = a, name = b, fn = c }
    else hooks[#hooks + 1] = { name = a, fn = b } end
    -- A hook on the box's own method runs after every call, Echo's included, as in game.
    if a == box and type(box[b]) == "function" then
      local orig = box[b]
      box[b] = function(...) orig(...); if b == "SetPoint" then setPointHooks = setPointHooks + 1 end; c(...) end
    end
  end
  ChatFrameUtil = { ActivateChat = function() end, DeactivateChat = function() end, UpdateHeader = function() end }
  local function fire(name, ...)
    for _, h in ipairs(hooks) do if h.name == name then h.fn(...) end end
  end

  S.Reset()
  T.Enable()
  K.Enable()
  C.Enable()
  -- An earlier section leaves the column's global cleared; the stack button's parent is the column.
  local savedColumnGlobal = _G.HorizonSuiteEchoColumn
  local column = T.StackButton().parent
  _G.HorizonSuiteEchoColumn = column
  local savedColumn = { GetScale = rawget(column, "GetScale"), GetLeft = rawget(column, "GetLeft"), GetParent = rawget(column, "GetParent"),
    GetFrameStrata = rawget(column, "GetFrameStrata") }
  column.GetFrameStrata = function() return "HIGH" end
  column.GetScale = function() return 1.25 end
  column.GetLeft = nil
  local stackButton = T.StackButton()
  check("input: Tiles.StackButton is the Echo icon", stackButton == T._stackButton(), "?")

  -- Enable records and restyles.
  db.echoColumnEdge = "right"
  I.Enable()
  I.Enable()
  local names = {}
  for _, h in ipairs(hooks) do names[#names + 1] = h.name end
  local utilHooks, boxHooks = 0, 0
  for _, h in ipairs(hooks) do
    if h.target == ChatFrameUtil then utilHooks = utilHooks + 1 end
    if h.target == box and h.name == "SetPoint" then boxHooks = boxHooks + 1 end
  end
  check("input: activate, deactivate and header are hooked on ChatFrameUtil, once", utilHooks == 3, table.concat(names, ","))
  check("input: the box's SetPoint is post-hooked, once", boxHooks == 1 and #hooks == 4, table.concat(names, ","))
  check("input: the box's OnShow and OnHide are hooked", type(box.hookScripts.OnShow) == "function" and type(box.hookScripts.OnHide) == "function", "?")
  check("input: the box takes the column's strata", box.strata == "HIGH", box.strata)
  check("input: the typed text takes Echo's font at its own size", box.font[1] == Echo.FontPath() and box.font[2] == 14, tostring(box.font[1]))
  check("input: Blizzard's textures go transparent", regions[1].alpha == 0 and regions[2].alpha == 0, regions[1].alpha .. "," .. regions[2].alpha)
  check("input: its FontStrings keep their alpha", regions[3].alpha == 1, regions[3].alpha)
  check("input: its FontStrings take Echo's font at their own size", regions[3].font[1] == Echo.FontPath() and regions[3].font[2] == 14,
    tostring(regions[3].font[1]) .. " " .. tostring(regions[3].font[2]))
  local bg = I._background()
  local bgRR = bg and rawget(bg, "_echoRound")
  check("input: a rounded background with the SMALL radius and a border", bgRR ~= nil and bgRR.corners.tl == Echo.Round.SMALL and bgRR.border ~= nil, "?")
  check("input: the background sits one level below the box, in its strata", bg and bg.frameLevel == 4, bg and bg.frameLevel)
  local fill = bgRR and bgRR.fill.middleBand.vertexColor
  check("input: the background is Echo's panel colour", fill and fill[1] == V.PANEL_BG[1] and fill[4] == V.PANEL_BG[4], fill and table.concat(fill, ","))
  check("input: the box takes the column's scale", box.scale == 1.25, box.scale)

  -- The anchor: the column's foot, opening on the panel side, at the card's width.
  local W = C.WIDTH
  local p1, p2 = box.points[1], box.points[2]
  check("input: right edge, beside the icon on its left", #box.points == 2 and p1[1] == "RIGHT" and p1[2] == stackButton and p1[3] == "LEFT" and p1[4] == -8,
    p1 and (tostring(p1[1]) .. " " .. tostring(p1[3]) .. " " .. tostring(p1[4])))
  check("input: right edge, the card's width wide", p2 and p2[1] == "LEFT" and p2[2] == stackButton and p2[3] == "LEFT" and p2[4] == -8 - W, p2 and p2[4])
  db.echoColumnEdge = "left"
  Echo.ApplyOptions()
  p1, p2 = box.points[1], box.points[2]
  check("input: left edge, beside the icon on its right", #box.points == 2 and p1[1] == "LEFT" and p1[2] == stackButton and p1[3] == "RIGHT" and p1[4] == 8,
    p1 and (tostring(p1[1]) .. " " .. tostring(p1[3]) .. " " .. tostring(p1[4])))
  check("input: left edge, the card's width wide", p2 and p2[1] == "RIGHT" and p2[3] == "RIGHT" and p2[4] == 8 + W, p2 and p2[4])
  db.echoColumnEdge = "right"
  T.ApplyPosition()
  check("input: a column move re-anchors it", box.points[1][1] == "RIGHT", box.points[1][1])

  -- The anchor follows the card: shown, hidden, the column foot again.
  S.Add({ convKey = "w:Brisa-Horizon", text = "got the leather", sender = "Brisa-Horizon" })
  S.Add({ convKey = "guild", text = "raid at 8", sender = "Vexa-Horizon" })
  C.Open("w:Brisa-Horizon")
  local root = C._frames().root
  p1, p2 = box.points[1], box.points[2]
  check("input: under the open card, flush with its left edge, 4px down", #box.points == 2 and p1[1] == "TOPLEFT" and p1[2] == root and p1[3] == "BOTTOMLEFT"
    and p1[4] == 0 and p1[5] == -4, p1 and (tostring(p1[1]) .. " " .. tostring(p1[3]) .. " " .. tostring(p1[5])))
  check("input: and with its right edge, so it is the card's width", p2 and p2[1] == "TOPRIGHT" and p2[2] == root and p2[3] == "BOTTOMRIGHT" and p2[5] == -4, p2 and p2[1])
  C.Hide()
  check("input: back at the column's foot when the card hides", box.points[1][1] == "RIGHT" and box.points[1][2] == stackButton, box.points[1][1])
  C.Open("w:Brisa-Horizon")
  root.shown = false  -- Escape hides the root directly; the stand-in doesn't fire OnHide itself
  root.scripts.OnHide(root)
  check("input: a card closed by Escape also sends it back", box.points[1][1] == "RIGHT", box.points[1][1])
  C.Open("w:Brisa-Horizon")
  C.Reanchor()
  check("input: re-anchoring the card keeps it under the card", box.points[1][2] == root, "moved")

  -- Show and hide from Blizzard's own activate and deactivate.
  fire("DeactivateChat", box)
  check("input: deactivate hides it", box.shown == false, "shown")
  check("input: and its background", bg.shown == false, "shown")
  fire("ActivateChat", box)
  check("input: activate shows it", box.shown == true, "hidden")
  check("input: and its background", bg.shown == true, "hidden")
  fire("DeactivateChat", box)
  fire("ActivateChat", other)
  check("input: another edit box's activate is ignored", box.shown == false and other.shown == false, "touched")
  db.echoInputAlwaysVisible = true
  box.alpha = 0.35
  fire("DeactivateChat", box)
  check("input: always visible keeps it shown on deactivate", box.shown == true and bg.shown == true, "hidden")
  check("input: at full alpha", box.alpha == 1, box.alpha)
  I.Disable()
  box:Hide()
  I.Enable()
  check("input: always visible shows it at enable", box.shown == true, "hidden")
  db.echoInputAlwaysVisible = nil

  -- The header hook colours the border from the chat type.
  local savedChan = GetChannelName
  ChatTypeInfo = { GUILD = { r = 0.25, g = 1, b = 0.25 }, CHANNEL = { r = 1, g = 0.75, b = 0.75 }, CHANNEL2 = { r = 0.9, g = 0.6, b = 0.3 } }
  GetChannelName = function(q)
    if q == 2 or q == "Trade - City" then return 2, "Trade - City", 0 end
    return 0
  end
  local function ring() return bgRR.border.ring.tl.vertexColor end
  box.attrs.chatType = "GUILD"
  fire("UpdateHeader", box)
  check("input: the header hook colours the border with the chat type's colour", ring()[1] == 0.25 and ring()[2] == 1 and ring()[3] == 0.25, table.concat(ring(), ","))
  box.attrs.chatType, box.attrs.channelTarget = "CHANNEL", 2
  fire("UpdateHeader", box)
  check("input: a channel uses its own channel colour", ring()[1] == 0.9 and ring()[2] == 0.6, table.concat(ring(), ","))
  box.attrs.chatType = "GUILD"
  fire("UpdateHeader", other)
  check("input: another box's header is ignored", ring()[1] == 0.9, table.concat(ring(), ","))

  -- Input.TargetKey: the conversation the line sends to.
  local function target(chatType, extra)
    box.attrs = { chatType = chatType }
    for k, v in pairs(extra or {}) do box.attrs[k] = v end
    return I.TargetKey()
  end
  check("target: a whisper matches its conversation whatever the case", target("WHISPER", { tellTarget = "brisa-horizon" }) == "w:Brisa-Horizon", I.TargetKey())
  check("target: a whisper without a realm gets yours", target("WHISPER", { tellTarget = "Vexa" }) == "w:Vexa-Horizon", I.TargetKey())
  check("target: guild", target("GUILD") == "guild", I.TargetKey())
  check("target: officer", target("OFFICER") == "officer", I.TargetKey())
  check("target: party", target("PARTY") == "party", I.TargetKey())
  check("target: raid", target("RAID") == "raid", I.TargetKey())
  check("target: instance", target("INSTANCE_CHAT") == "instance", I.TargetKey())
  check("target: say is Nearby", target("SAY") == "nearby", I.TargetKey())
  check("target: yell is Nearby", target("YELL") == "nearby", I.TargetKey())
  check("target: emote is Nearby", target("EMOTE") == "nearby", I.TargetKey())
  check("target: a channel by its joined name", target("CHANNEL", { channelTarget = 2 }) == "ch:Trade", I.TargetKey())
  check("target: a channel not joined has none", target("CHANNEL", { channelTarget = 7 }) == nil, I.TargetKey())
  check("target: Battle.net without a friends list has none", target("BN_WHISPER", { tellTarget = "Friend" }) == nil, I.TargetKey())
  check("target: a secret chat type has none", target(SECRET("GUILD")) == nil, "keyed")
  check("target: a secret whisper name has none", target("WHISPER", { tellTarget = SECRET("Brisa-Horizon") }) == nil, "keyed")

  -- The card hides its reply box while the line targets its conversation.
  local f = C._frames()
  local function areaBottom() return f.area.points[2] and f.area.points[2][5] end
  C.Show("w:Brisa-Horizon")
  fire("ActivateChat", box)
  target("WHISPER", { tellTarget = "Brisa-Horizon" })
  fire("UpdateHeader", box)
  check("card: the reply box hides while the line targets this chat", not f.edit:IsShown() and not f.send:IsShown(), "shown")
  check("card: the message area takes the reply box's space", areaBottom() == C.PAD, areaBottom())
  target("GUILD")
  fire("UpdateHeader", box)
  check("card: another target brings the reply box back", f.edit:IsShown() and f.send:IsShown(), "hidden")
  check("card: and the area's bottom", areaBottom() == C.AREA_BOTTOM, areaBottom())
  C.Show("guild")
  check("card: switching the card to the targeted chat hides it", not f.edit:IsShown(), "shown")
  fire("DeactivateChat", box)
  check("card: a hidden line never replaces the reply box", f.edit:IsShown() and f.send:IsShown(), "hidden")
  fire("ActivateChat", box)
  check("card: activating the line hides it again", not f.edit:IsShown(), "shown")

  -- Kept in place and in style (fix round 1).
  C.Hide()
  local bgStrata
  bg.SetFrameStrata = function(self, v) bgStrata = v end
  I.Reanchor()
  check("input: the background shares the column's strata", bgStrata == "HIGH", bgStrata)
  local before = setPointHooks
  local ok = pcall(box.SetPoint, box, "BOTTOMLEFT", chatFrame, "TOPLEFT", -5, -2)
  check("input: a foreign SetPoint is undone", ok and #box.points == 2 and box.points[1][2] == stackButton and box.points[2][2] == stackButton,
    box.points[1] and tostring(box.points[1][1]))
  check("input: Echo's own SetPoints don't loop back", setPointHooks - before == 3, setPointHooks - before)
  before = setPointHooks
  I.Reanchor()
  check("input: Echo's re-anchor passes through the hook without re-anchoring", setPointHooks - before == 2 and #box.points == 2, #box.points)
  regions[1].alpha, regions[2].alpha = 0.6, 1
  fire("ActivateChat", box)
  check("input: activate fades Blizzard's textures again", regions[1].alpha == 0 and regions[2].alpha == 0, regions[1].alpha)
  regions[1].alpha = 0.6
  fire("UpdateHeader", box)
  check("input: the header hook fades them again too", regions[1].alpha == 0, regions[1].alpha)
  box.shown = false
  box.hookScripts.OnHide(box)
  check("input: the background hides with the box", bg.shown == false, "shown")
  box.shown = true
  box.hookScripts.OnShow(box)
  check("input: and shows with it", bg.shown == true, "hidden")

  -- Review fixes: never strand the card without a way to type.
  local fc = C._frames()
  C.Open("w:Brisa-Horizon")
  box.attrs = { chatType = "WHISPER", tellTarget = "Brisa-Horizon" }
  fire("ActivateChat", box)
  check("review: the covered card hides its reply box", not fc.edit:IsShown(), "shown")
  box.shown = false
  box.hookScripts.OnHide(box)
  check("review: the box hiding by itself brings the reply box back", fc.edit:IsShown() and fc.send:IsShown(), "hidden")
  box.shown = true
  box.hookScripts.OnShow(box)
  check("review: and showing again hides it", not fc.edit:IsShown(), "shown")
  C.Hide()

  local realEdge, realHandler = V.PanelEdge, geterrorhandler
  local reported
  geterrorhandler = function() return function(err) reported = err end end
  V.PanelEdge = function() error("edge broke") end
  pcall(I.Reanchor)
  check("review: an error while anchoring is reported", reported ~= nil and tostring(reported):find("edge broke", 1, true) ~= nil, tostring(reported))
  V.PanelEdge, geterrorhandler = realEdge, realHandler
  pcall(box.SetPoint, box, "BOTTOMLEFT", chatFrame, "TOPLEFT", -5, -2)
  check("review: after it, a foreign SetPoint is still undone", #box.points == 2 and box.points[1][2] == stackButton,
    box.points[1] and tostring(box.points[1][2] == chatFrame))

  box.level = 0
  local lvlSet
  bg.SetFrameLevel = function(self, v) lvlSet = v end
  local ok0 = pcall(I.Reanchor)
  check("review: a level-0 box puts the background at level 0, the box untouched", ok0 and lvlSet == 0 and box.level == 0, tostring(lvlSet))
  check("review: the background draws in the BACKGROUND layer", bgRR.layer == "BACKGROUND", bgRR.layer)
  bg.SetFrameLevel = nil
  box.level = 5
  I.Reanchor()

  -- Undocking hides a box that only always-visible put on screen.
  db.echoInputAlwaysVisible = true
  fire("DeactivateChat", box)
  I.Disable()
  check("input: undocking hides an always-visible box", box.shown == false, "shown")
  I.Enable()
  box.focus = true
  I.Disable()
  check("input: but not one being typed in", box.shown == true, "hidden")
  box.focus = nil
  db.echoInputAlwaysVisible = nil
  I.Enable()
  box.shown = false
  box.hookScripts.OnShow(box)
  box.shown = true
  fire("ActivateChat", box)
  C.Show("w:Brisa-Horizon")

  -- Task 3: Echo follows the input line.
  local savedBN, savedNumFriends = C_BattleNet, BNGetNumFriends
  C_BattleNet = { GetFriendAccountInfo = function(i)
    if i == 1 then return { accountName = "|Kq1|k", bnetAccountID = 41 } end
    if i == 2 then return { accountName = "|Kq2|k", bnetAccountID = 42 } end
    if i == 3 then return { accountName = SECRET("|Kq3|k"), bnetAccountID = 43 } end
    if i == 4 then return { accountName = "|Kq4|k", bnetAccountID = SECRET(44) } end
  end }
  BNGetNumFriends = function() return 4 end
  check("follow: Battle.net is the friend whose account name matches", target("BN_WHISPER", { tellTarget = "|Kq2|k" }) == "bn:42", I.TargetKey())
  check("follow: Battle.net matches whole strings only", target("BN_WHISPER", { tellTarget = "|Kq2" }) == nil, I.TargetKey())
  check("follow: an unknown Battle.net friend has none", target("BN_WHISPER", { tellTarget = "|Kq9|k" }) == nil, I.TargetKey())
  check("follow: a secret account name never matches", target("BN_WHISPER", { tellTarget = "|Kq3|k" }) == nil, I.TargetKey())
  check("follow: a secret account ID gives none", target("BN_WHISPER", { tellTarget = "|Kq4|k" }) == nil, I.TargetKey())
  check("follow: a secret Battle.net target has none", target("BN_WHISPER", { tellTarget = SECRET("|Kq2|k") }) == nil, I.TargetKey())
  BNGetNumFriends = function() error("no friends list") end
  check("follow: an unreadable friends list has none", target("BN_WHISPER", { tellTarget = "|Kq2|k" }) == nil, I.TargetKey())
  BNGetNumFriends = function() return 4 end

  -- The header hook opens the card on the line's target, once per change, without focus.
  C.Hide()
  local realStart, realShow = S.Start, C.Show
  local starts, shows = {}, {}
  S.Start = function(key) starts[#starts + 1] = key; return realStart(key) end
  C.Show = function(key, fromTile) shows[#shows + 1] = { key = key, tile = fromTile }; return realShow(key, fromTile) end
  local fe = C._frames().edit
  fe.focused = false
  local focusCalls = 0
  local realFocus = C.Focus
  C.Focus = function(...) focusCalls = focusCalls + 1; return realFocus(...) end
  box.shown, box.focus = true, nil
  box.attrs = { chatType = "GUILD" }
  fire("UpdateHeader", box)
  check("follow: an unfocused line opens nothing", #shows == 0 and not C.IsShown(), #shows)
  box.focus = true
  fire("UpdateHeader", box)
  check("follow: a focused line opens its conversation", #shows == 1 and shows[1].key == "guild" and C.IsShown() and C.ShownKey() == "guild",
    shows[1] and shows[1].key)
  check("follow: the conversation is started", starts[1] == "guild", tostring(starts[1]))
  check("follow: the card grows out of its tile", shows[1] and shows[1].tile == T.TileFor("guild"), "other tile")
  fire("UpdateHeader", box)
  check("follow: the same target opens it only once", #shows == 1, #shows)
  box.attrs = { chatType = "WHISPER", tellTarget = "brisa-horizon" }
  fire("UpdateHeader", box)
  check("follow: a new target switches the card", #shows == 2 and C.ShownKey() == "w:Brisa-Horizon", C.ShownKey())
  box.attrs = { chatType = "WHISPER", tellTarget = "Quill" }
  fire("UpdateHeader", box)
  check("follow: a whisper to someone new starts their conversation", C.ShownKey() == "w:Quill-Horizon" and S.Get("w:Quill-Horizon") ~= nil, C.ShownKey())
  box.attrs = { chatType = "BN_WHISPER", tellTarget = "|Kq1|k" }
  fire("UpdateHeader", box)
  check("follow: a Battle.net whisper opens the friend's conversation", C.ShownKey() == "bn:41", C.ShownKey())
  box.attrs = { chatType = "SAY" }
  fire("UpdateHeader", box)
  check("follow: say opens Nearby on Say", C.ShownKey() == "nearby" and S.SendModeOf("nearby") == "SAY", S.SendModeOf("nearby"))
  local before = #shows
  box.attrs = { chatType = "YELL" }
  fire("UpdateHeader", box)
  check("follow: Nearby's mode follows yell", S.SendModeOf("nearby") == "YELL", S.SendModeOf("nearby"))
  check("follow: without opening it again", #shows == before, #shows - before)
  check("follow: the card's reply box is never focused", focusCalls == 0 and rawget(fe, "focused") ~= true, focusCalls)
  check("follow: nor Blizzard's line", box.calls.focus == 0, box.calls.focus)

  -- Deactivate forgets the target, so the next activate on it opens it again.
  fire("DeactivateChat", box)
  C.Hide()
  box.shown = true
  fire("ActivateChat", box)
  fire("UpdateHeader", box)
  check("follow: after deactivate the same target opens again", #shows == before + 1 and C.ShownKey() == "nearby", #shows - before)

  -- Never while the card is animating a close, and never while docking is off.
  local realClosing = C.IsClosing
  check("follow: the card says whether a close is animating", type(realClosing) == "function" and realClosing() == false, tostring(realClosing))
  C.IsClosing = function() return true end
  box.attrs = { chatType = "GUILD" }
  fire("UpdateHeader", box)
  check("follow: not while the card animates a close", C.ShownKey() == "nearby", C.ShownKey())
  C.IsClosing = realClosing
  fire("UpdateHeader", box)
  check("follow: and once the close is done, it follows", C.ShownKey() == "guild", C.ShownKey())
  box.shown = false
  box.attrs = { chatType = "OFFICER" }
  fire("UpdateHeader", box)
  check("follow: a hidden line opens nothing", C.ShownKey() == "guild", C.ShownKey())
  box.shown = true
  db.echoDockInput = false
  Echo.ApplyOptions()
  box.shown = true
  fire("UpdateHeader", box)
  check("follow: nothing while docking is off", C.ShownKey() == "guild", C.ShownKey())
  db.echoDockInput = nil
  Echo.ApplyOptions()

  S.Start, C.Show, C.Focus = realStart, realShow, realFocus
  C_BattleNet, BNGetNumFriends = savedBN, savedNumFriends
  box.focus = nil
  box.shown = true
  box.attrs = { chatType = "WHISPER", tellTarget = "Brisa-Horizon" }
  fire("ActivateChat", box)
  C.Show("w:Brisa-Horizon")

  -- Toggling the setting live restores everything, and the hooks then do nothing.
  db.echoDockInput = false
  Echo.ApplyOptions()
  check("input: off restores the exact points", #box.points == 2 and box.points[1][1] == originalPoints[1][1] and box.points[1][2] == chatFrame
    and box.points[1][4] == -5 and box.points[2][3] == "TOPRIGHT" and box.points[2][4] == 5 and box.points[2][5] == -2, box.points[1] and box.points[1][1])
  check("input: off restores the scale", box.scale == 0.9, box.scale)
  check("input: off restores the texture alphas", regions[1].alpha == 1 and regions[2].alpha == 0.8, regions[1].alpha .. "," .. regions[2].alpha)
  check("input: off restores the font", regions[3].font[1] == "Fonts\\\\ARIALN.TTF" and regions[3].font[3] == "OUTLINE", regions[3].font[1])
  check("input: off hides the background", bg.shown == false, "shown")
  check("input: off restores the strata", box.strata == "LOW", box.strata)
  check("input: off restores the typed text's font", box.font[1] == "Fonts\\\\ARIALN.TTF" and box.font[2] == 14, box.font[1])
  box.shown = false
  box.hookScripts.OnShow(box)
  check("input: the OnShow hook does nothing while off", bg.shown == false, "shown")
  check("card: off brings the reply box back", f.edit:IsShown(), "hidden")
  box.shown = true
  fire("DeactivateChat", box)
  check("input: the hooks do nothing while off", box.shown == true, "hidden")
  fire("UpdateHeader", box)
  C.Hide()
  check("input: a card hiding doesn't move it while off", #box.points == 2 and box.points[1][2] == chatFrame, box.points[1] and tostring(box.points[1][2]))
  local fontBefore = regions[3].font[1]
  db.echoFontPath = "Fonts\\\\SKURRI.TTF"
  Echo.ApplyFont()
  check("input: an untracked FontString keeps Blizzard's font", regions[3].font[1] == fontBefore, regions[3].font[1])
  db.echoFontPath = nil
  Echo.ApplyFont()
  db.echoDockInput = true
  Echo.ApplyOptions()
  check("input: on again docks it", box.points[1][2] == stackButton and regions[1].alpha == 0, box.points[1] and tostring(box.points[1][1]))
  check("input: the hooks are still installed only once", #hooks == 4, #hooks)
  I.Disable()
  check("input: disable restores the points again", box.points[1][2] == chatFrame and box.scale == 0.9, box.scale)

  check("input: never focuses Blizzard's input line", box.calls.focus == 0, box.calls.focus)
  check("input: never sets its attributes", box.calls.attribute == 0, box.calls.attribute)

  C.Disable()
  K.Disable()
  T.Disable()
  column.GetScale, column.GetLeft, column.GetParent = savedColumn.GetScale, savedColumn.GetLeft, savedColumn.GetParent
  column.GetFrameStrata = savedColumn.GetFrameStrata
  _G.HorizonSuiteEchoColumn = savedColumnGlobal
  GetChannelName = savedChan
  hooksecurefunc, ChatFrameUtil, ChatFrame1EditBox, ChatTypeInfo = saved.hook, saved.util, saved.box, saved.info
  A.GetDB, A.SetDB, CreateFrame, A.ECHO_DEFAULTS = saved.getDB, saved.setDB, saved.create, saved.defaults
  S.Reset()
`, 'echo-input');

// --- Redraw: one repaint per frame -------------------------------------------
run(`
  CreateFrame = STUB_CREATE_FRAME
  local Echo = HorizonSuite.Echo
  local R = Echo.Redraw
  R.sync = false
  local calls = {}
  R.Register("tiles", function() calls[#calls + 1] = "tiles" end)
  R.Register("card", function() calls[#calls + 1] = "card" end)
  R.Register("cardRow", function() calls[#calls + 1] = "cardRow" end)
  R.Mark("tiles"); R.Mark("tiles"); R.Mark("tiles")
  check("a mark waits for the next frame", #calls == 0, #calls)
  check("the mark is pending", R.Pending("tiles") == true, R.Pending("tiles"))
  R.Flush()
  check("three marks repaint once", #calls == 1 and calls[1] == "tiles", table.concat(calls, ","))
  check("nothing pending after a flush", R.Pending("tiles") == false, R.Pending("tiles"))

  calls = {}
  R.Mark("cardRow"); R.Mark("card")
  R.Flush()
  check("a full card render drops the row repaint", #calls == 1 and calls[1] == "card", table.concat(calls, ","))

  calls = {}
  R.Mark("card"); R.Mark("tiles")
  R.Flush()
  check("tiles repaint before the card", calls[1] == "tiles" and calls[2] == "card", table.concat(calls, ","))

  calls = {}
  R.Mark("tiles"); R.Clear(); R.Flush()
  check("Clear drops pending marks", #calls == 0, #calls)

  -- A handler that errors is reported and does not stop a later handler this flush.
  local savedHandler, reported = geterrorhandler, nil
  geterrorhandler = function() return function(err) reported = err end end
  R.Register("tiles", function() error("tiles boom") end)
  calls = {}
  R.Mark("tiles"); R.Mark("card")
  R.Flush()
  check("a later handler still runs after an earlier one errors", #calls == 1 and calls[1] == "card", table.concat(calls, ","))
  check("the error reaches the error handler", type(reported) == "string" and reported:find("tiles boom", 1, true) ~= nil, tostring(reported))
  geterrorhandler = savedHandler
  R.Register("tiles", function() calls[#calls + 1] = "tiles" end)

  -- A burst of lines through the real views: one Tiles.Refresh.
  local Store = Echo.Store
  Store.Reset()
  Echo.Tiles.Enable()
  local refreshes, real = 0, Echo.Tiles.Refresh
  Echo.Tiles.Refresh = function() refreshes = refreshes + 1; return real() end
  R.Register("tiles", function() Echo.Tiles.Refresh() end)
  for i = 1, 20 do Store.Add({ convKey = "loot", text = "item " .. i }) end
  check("twenty feed lines, no repaint yet", refreshes == 0, refreshes)
  R.Flush()
  check("twenty feed lines, one repaint", refreshes == 1, refreshes)
  Echo.Tiles.Refresh = real
  Echo.Tiles.Disable()
  Store.Reset()
  R.Clear()
  R.sync = true
`, 'redraw');

// --- One painter: every host draws a spec through Echo.PaintTileFace -----------------
run(`
  local S, T, K, C, V = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles, HorizonSuite.Echo.Stack, HorizonSuite.Echo.Card, HorizonSuite.Echo.View
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  C.Enable()

  -- A class-icon whisper: icon shown on every host, the column tile alone carries the label.
  HorizonSuite.ResolveClassIconDisplay = function() return { kind = "file", path = "Interface\\\\ClassIcon\\\\Druid" } end
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  local brisaSpec = V.TileSpec(S.Get("w:Brisa-Horizon"))
  check("setup: whisper resolves a class face", brisaSpec.face == "class", brisaSpec.face)

  local colTile = T.TileFor("w:Brisa-Horizon")
  check("column tile: class icon shown", colTile.icon.shown == true, tostring(colTile.icon.shown))
  check("column tile: class icon textured", colTile.icon.texture == "Interface\\\\ClassIcon\\\\Druid", tostring(colTile.icon.texture))
  check("column tile: keeps its own outline flags", colTile.letter._echoFlags == "", tostring(colTile.letter._echoFlags))
  check("column tile: whisper label shown", colTile.label.text == "Brisa", colTile.label.text)
  check("column tile: label shade shown", colTile.labelShade.shown == true, tostring(colTile.labelShade.shown))

  C.Open("w:Brisa-Horizon")
  local cf = C._frames()
  local brisaRow
  for _, b in ipairs(cf.rowTiles) do if b.convKey == "w:Brisa-Horizon" then brisaRow = b end end
  check("card row tile: class icon shown", brisaRow and brisaRow.icon.shown == true, "?")
  check("card row tile: class icon textured", brisaRow and brisaRow.icon.texture == "Interface\\\\ClassIcon\\\\Druid", "?")
  check("card row tile: keeps its own outline flags", brisaRow and brisaRow.letter._echoFlags == "", "?")
  C.Hide()

  K.Open("w:Brisa-Horizon")
  local kf = K._frames()
  check("stack card tile: class icon shown", kf.card.tileIcon.shown == true, tostring(kf.card.tileIcon.shown))
  check("stack card tile: class icon textured", kf.card.tileIcon.texture == "Interface\\\\ClassIcon\\\\Druid", "?")
  check("stack card tile: keeps its own outline flags", kf.card.letter._echoFlags == "", tostring(kf.card.letter._echoFlags))
  K.Hide()

  local toast = T._toast()
  check("toast: class icon shown", toast and toast.entry.face.shown == true, "?")
  check("toast: class icon textured", toast and toast.entry.face.texture == "Interface\\\\ClassIcon\\\\Druid", "?")
  check("toast: keeps its own outline flags", toast and toast.entry.letter._echoFlags == "", "?")

  -- An atlas class icon paints through SetAtlas instead of SetTexture.
  HorizonSuite.ResolveClassIconDisplay = function() return { kind = "atlas", atlas = "classicon-druid" } end
  S.Add({ convKey = "w:Vexa-Horizon", text = "hi", class = "DRUID", sender = "Vexa-Horizon" })
  local vexaTile = T.TileFor("w:Vexa-Horizon")
  check("column tile: atlas class icon set", vexaTile.icon.atlas == "classicon-druid", tostring(vexaTile.icon.atlas))
  HorizonSuite.ResolveClassIconDisplay = nil

  -- A Battle.net logo: icon shown, full texcoords, on every host.
  S.Add({ convKey = "bn:1", text = "yo", sender = "|Kq1|k" })
  local bnetSpec = V.TileSpec(S.Get("bn:1"))
  check("setup: bnet with no class is the logo", bnetSpec.face == "icon" and bnetSpec.icon == V.BNET_LOGO, bnetSpec.face)

  local bnetTile = T.TileFor("bn:1")
  check("column tile: bnet icon shown", bnetTile.icon.shown == true, "?")
  check("column tile: bnet full texcoords", bnetTile.icon.texCoord and bnetTile.icon.texCoord[1] == 0 and bnetTile.icon.texCoord[2] == 1, "?")

  C.Open("bn:1")
  local bnetRow
  for _, b in ipairs(cf.rowTiles) do if b.convKey == "bn:1" then bnetRow = b end end
  check("card row tile: bnet icon shown", bnetRow and bnetRow.icon.shown == true, "?")
  check("card row tile: bnet full texcoords", bnetRow and bnetRow.icon.texCoord and bnetRow.icon.texCoord[1] == 0 and bnetRow.icon.texCoord[2] == 1, "?")
  C.Hide()

  K.Open("bn:1")
  check("stack card tile: bnet icon shown", kf.card.tileIcon.shown == true, "?")
  check("stack card tile: bnet full texcoords", kf.card.tileIcon.texCoord and kf.card.tileIcon.texCoord[1] == 0 and kf.card.tileIcon.texCoord[2] == 1, "?")
  K.Hide()

  T.ShowToast("bn:1")
  toast = T._toast()
  check("toast: bnet icon shown", toast.entry.face.shown == true, "?")
  check("toast: bnet full texcoords", toast.entry.face.texCoord and toast.entry.face.texCoord[1] == 0 and toast.entry.face.texCoord[2] == 1, "?")

  -- A channel with no icon (Guild) keeps its glyph: letter "Guil" at the small size, on
  -- every host. General now has an icon (Task 1) and is covered separately.
  S.Add({ convKey = "ch:Guild", text = "lfg" })
  local guilSpec = V.TileSpec(S.Get("ch:Guild"))
  check("setup: Guild channel is Guil, small", guilSpec.letter == "Guil" and guilSpec.small == true, guilSpec.letter)

  local guilTile = T.TileFor("ch:Guild")
  check("column tile: Guil letter", guilTile.letter.text == "Guil", guilTile.letter.text)
  check("column tile: Guil small size", guilTile.letter._echoSize == 10, tostring(guilTile.letter._echoSize))

  C.Open("ch:Guild")
  local guilRow
  for _, b in ipairs(cf.rowTiles) do if b.convKey == "ch:Guild" then guilRow = b end end
  check("card row tile: Guil letter", guilRow and guilRow.letter.text == "Guil", "?")
  check("card row tile: Guil small size", guilRow and guilRow.letter._echoSize == 8, tostring(guilRow and guilRow.letter._echoSize))
  C.Hide()

  K.Open("ch:Guild")
  check("stack card tile: Guil letter", kf.card.letter.text == "Guil", kf.card.letter.text)
  check("stack card tile: Guil small size", kf.card.letter._echoSize == 9, tostring(kf.card.letter._echoSize))
  K.Hide()

  T.ShowToast("ch:Guild")
  toast = T._toast()
  check("toast: Guil letter", toast.entry.letter.text == "Guil", toast.entry.letter.text)
  check("toast: Guil small size", toast.entry.letter._echoSize == 9, tostring(toast.entry.letter._echoSize))

  -- General now carries an icon and a label instead of a glyph letter (Task 1).
  S.Add({ convKey = "ch:General", text = "lfg" })
  local genSpec = V.TileSpec(S.Get("ch:General"))
  check("setup: General channel is an icon with a Gen label", genSpec.face == "icon" and genSpec.label == "Gen", genSpec.label)

  local genTile = T.TileFor("ch:General")
  check("column tile: General icon shown", genTile.icon.shown == true, tostring(genTile.icon.shown))
  check("column tile: General icon textured", genTile.icon.texture == V.CHANNEL_ICONS.General, tostring(genTile.icon.texture))
  check("column tile: General label shown", genTile.label.text == "Gen", genTile.label.text)

  -- A party glyph: letter "P" at the full size; the column tile's label shade stays hidden.
  S.Add({ convKey = "party", text = "pull", sender = "Tank-Horizon" })
  local partySpec = V.TileSpec(S.Get("party"))
  check("setup: party is a glyph P", partySpec.glyph == true and partySpec.letter == "P", partySpec.letter)

  local partyTile = T.TileFor("party")
  check("column tile: party letter", partyTile.letter.text == "P", partyTile.letter.text)
  check("column tile: party full size", partyTile.letter._echoSize == 16, tostring(partyTile.letter._echoSize))
  check("column tile: label shade hidden for a glyph tile", partyTile.labelShade.shown == false, tostring(partyTile.labelShade.shown))

  C.Open("party")
  local partyRow
  for _, b in ipairs(cf.rowTiles) do if b.convKey == "party" then partyRow = b end end
  check("card row tile: party letter", partyRow and partyRow.letter.text == "P", "?")
  check("card row tile: party full size", partyRow and partyRow.letter._echoSize == 12, tostring(partyRow and partyRow.letter._echoSize))
  C.Hide()

  K.Open("party")
  check("stack card tile: party letter", kf.card.letter.text == "P", kf.card.letter.text)
  check("stack card tile: party full size", kf.card.letter._echoSize == 14, tostring(kf.card.letter._echoSize))
  K.Hide()

  T.ShowToast("party")
  toast = T._toast()
  check("toast: party letter", toast.entry.letter.text == "P", toast.entry.letter.text)
  check("toast: party full size", toast.entry.letter._echoSize == 14, tostring(toast.entry.letter._echoSize))

  C.Disable()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'one-painter');

// --- Final fix H4: the painter tracks size and flags together, never forcing OUTLINE ------
run(`
  local Echo = HorizonSuite.Echo
  local spec = { face = "letter", letter = "B", r = 1, g = 1, b = 1 }

  -- A host with no flags field defaults to no flags, not a hard-coded OUTLINE.
  local plainLetter = STUB_FRAME()
  Echo.PaintTileFace({ letter = plainLetter, size = 12, smallSize = 8 }, spec)
  check("H4: a host with no flags field paints with none", plainLetter._echoFlags == "", tostring(plainLetter._echoFlags))

  -- Re-fonting tracks size and flags together: either one changing re-fonts; both the same
  -- skips it.
  local letter = STUB_FRAME()
  letter._echoSize = 12
  letter._echoFlags = "OUTLINE"
  local calls, realTrackFont = 0, Echo.TrackFont
  Echo.TrackFont = function(...) calls = calls + 1; return realTrackFont(...) end
  local host = { letter = letter, size = 12, smallSize = 8, flags = "" }
  Echo.PaintTileFace(host, spec)
  check("H4: a flags change alone re-fonts", calls == 1 and letter._echoFlags == "", tostring(letter._echoFlags))
  Echo.PaintTileFace(host, spec)
  check("H4: the same size and flags skip a re-font", calls == 1, calls)
  host.flags = "OUTLINE"
  Echo.PaintTileFace(host, spec)
  check("H4: a later flags change re-fonts again", calls == 2 and letter._echoFlags == "OUTLINE", tostring(letter._echoFlags))
  Echo.TrackFont = realTrackFont
`, 'final-h4');

// --- Final fix H5: the column tile's label shade draws under the label, and the count -----
// --- badge moves off the name when a label is shown ----------------------------------------
run(`
  local S, T, V = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles, HorizonSuite.Echo.View
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon" })
  local tile = T.TileFor("w:Brisa-Horizon")
  local shadeRR = rawget(tile.labelShade, "_echoRound")
  check("H5: the label shade draws in ARTWORK, above the tile's BACKGROUND fill", shadeRR ~= nil and shadeRR.layer == "ARTWORK", shadeRR and shadeRR.layer)
  check("H5: a labelled tile moves its count off the bottom name", tile.count.points[#tile.count.points][1] == "TOPLEFT", tile.count.points[#tile.count.points][1])

  S.Add({ convKey = "party", text = "pull", sender = "Tank-Horizon" })
  local partyTile = T.TileFor("party")
  check("H5: a glyph tile with no label keeps the count at the bottom corner", partyTile.count.points[#partyTile.count.points][1] == "BOTTOMRIGHT", partyTile.count.points[#partyTile.count.points][1])

  T.Disable()
  S.Reset()
`, 'final-h5');

// --- Summary -------------------------------------------------------------------
run(`
  print(PASS .. " passed, " .. FAIL .. " failed")
  if FAIL > 0 then error("echo logic tests failed") end
`, 'summary');
