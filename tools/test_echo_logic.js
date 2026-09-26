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
      if k == "SetBackdropColor" then return function(self, r, g, b, a) self.bg = { r, g, b, a }; self.alpha = a end end
      if k == "SetTexture" then return function(self, tex) self.texture = tex; self.atlas = nil end end
      if k == "SetAtlas" then return function(self, atlas) self.atlas = atlas; self.texture = nil end end
      if k == "SetColorTexture" then return function(self, r, g, b, a) self.colorTexture = { r, g, b, a } end end
      if k == "SetTexCoord" then return function(self, ...) self.texCoord = { ... } end end
      if k == "SetSize" then return function(self, w, h) self.width = w; self.height = h end end
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
  'modules/Echo/EchoGenie.lua',
  'modules/Echo/EchoClass.lua',
  'modules/Echo/EchoRedraw.lua',
  'modules/Echo/EchoLinks.lua',
  'modules/Echo/EchoTiles.lua',
  'modules/Echo/EchoStack.lua',
  'modules/Echo/EchoMenu.lua',
  'modules/Echo/EchoCard.lua',
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

  none, reason = E.BuildRecord("CHAT_MSG_SAY", payload("hi", "A-B"))
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
  check("a channel tile uses its short name", V.TileSpec(S.Get("ch:Trade")).letter == "Trade", V.TileSpec(S.Get("ch:Trade")).letter)
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

// --- Genie: slice geometry ---------------------------------------------------------------
run(`
  local G = HorizonSuite.Echo.Genie
  local EPS = 1e-6
  local function near(a, b) return math.abs(a - b) < EPS end
  -- A column on the left: a 30x30 tile low in it, the card to its right.
  local tile = { left = 100, right = 130, bottom = 120, top = 150 }
  local card = { left = 138, right = 498, bottom = 100, top = 540 }
  local N = 32

  for _, edge in ipairs({ "left", "right" }) do
    local from, to = tile, card
    if edge == "right" then
      -- Mirror: column on the right, card to its left.
      from = { left = 900, right = 930, bottom = 120, top = 150 }
      to = { left = 532, right = 892, bottom = 100, top = 540 }
    end
    local s0 = G.Slices(from, to, 0, N, edge)
    check(edge .. ": one slice per strip", #s0 == N, #s0)
    local inside = true
    for _, s in ipairs(s0) do
      if s.left < from.left - EPS or s.right > from.right + EPS or s.bottom < from.bottom - EPS or s.top > from.top + EPS then inside = false end
    end
    check(edge .. ": p=0 keeps every strip inside the tile", inside, inside)
    check(edge .. ": p=0 spans the tile exactly", near(s0[1].bottom, from.bottom) and near(s0[N].top, from.top)
      and near(s0[1].left, from.left) and near(s0[1].right, from.right), s0[N].top)

    local s1 = G.Slices(from, to, 1, N, edge)
    local tiles = near(s1[1].bottom, to.bottom) and near(s1[N].top, to.top)
    for i, s in ipairs(s1) do
      if not (near(s.left, to.left) and near(s.right, to.right)) then tiles = false end
      if i > 1 and not near(s.bottom, s1[i - 1].top) then tiles = false end
      if s.top < s.bottom then tiles = false end
    end
    check(edge .. ": p=1 tiles the card exactly, contiguous", tiles, tiles)

    local sh = G.Slices(from, to, 0.5, N, edge)
    local mono, contiguous = true, true
    for i = 2, N do
      if sh[i].bottom < sh[i - 1].bottom - EPS then mono = false end
      if not near(sh[i].bottom, sh[i - 1].top) then contiguous = false end
    end
    check(edge .. ": p=0.5 strips are monotonic in v", mono, mono)
    check(edge .. ": p=0.5 strips have no gaps", contiguous, contiguous)
    check(edge .. ": p=0.5 is between the tile and the card", sh[N].top > from.top and sh[N].top < to.top, sh[N].top)

    -- The side away from the column bows: it moves far more across the strips than the
    -- column side, and it widens away from the tile (the neck stays narrow).
    local farKey, anchorKey = "right", "left"
    if edge == "right" then farKey, anchorKey = "left", "right" end
    local function range(key)
      local lo, hi = math.huge, -math.huge
      for _, s in ipairs(sh) do lo = math.min(lo, s[key]); hi = math.max(hi, s[key]) end
      return hi - lo
    end
    check(edge .. ": the far side bows, the column side stays put", range(farKey) > 3 * range(anchorKey),
      range(farKey) .. " vs " .. range(anchorKey))
    local neckW = sh[1].right - sh[1].left
    local farW = sh[N].right - sh[N].left
    check(edge .. ": narrow at the neck, wide at the far end", farW > neckW * 2, neckW .. " / " .. farW)
    local widening = true
    for i = 5, N do
      local w, pw = sh[i].right - sh[i].left, sh[i - 1].right - sh[i - 1].left
      if w < pw - EPS then widening = false end
    end
    check(edge .. ": the sheet widens steadily away from the tile", widening, widening)
    -- The bowed edge is a curve, not a straight line: its midpoint sits off the chord.
    local a, b, m = sh[1][farKey], sh[N][farKey], sh[N / 2][farKey]
    check(edge .. ": the bowed edge curves", math.abs(m - (a + b) / 2) > 5, m - (a + b) / 2)

    -- Per-strip progress: the far end leads (it reaches the window's top first, as in the
    -- reference frames); the neck by the tile lags and stays pinned to the tile's width.
    local qNear, qFar = G.StripProgress(from, to, 0.5, 1 / (2 * N)), G.StripProgress(from, to, 0.5, 1 - 1 / (2 * N))
    check(edge .. ": the far end is further along than the neck", qFar > qNear, qNear .. " / " .. qFar)
    check(edge .. ": strip progress reaches 1 at p=1", G.StripProgress(from, to, 1, 0) == 1 and G.StripProgress(from, to, 1, 1) == 1, "")
    check(edge .. ": the neck is still near the tile's width early on",
      (G.Slices(from, to, 0.2, N, edge)[1].right - G.Slices(from, to, 0.2, N, edge)[1].left) < 40, "")
  end

  -- Vertical leads horizontal: by mid-way the sheet is most of its height but not its width.
  local sh = G.Slices(tile, card, 0.5, N, "left")
  local hFrac = (sh[N].top - tile.top) / (card.top - tile.top)
  local wFrac = (sh[N].right - tile.right) / (card.right - tile.right)
  check("height leads width", hFrac > wFrac + 0.2, hFrac .. " / " .. wFrac)

  -- A tile above the card's middle still gives monotonic, contiguous strips.
  local high = { left = 100, right = 130, bottom = 500, top = 530 }
  local sm = G.Slices(high, card, 0.4, N, "left")
  local ok = true
  for i = 2, N do if sm[i].bottom < sm[i - 1].bottom - EPS or not near(sm[i].bottom, sm[i - 1].top) then ok = false end end
  check("a high tile still gives ordered, contiguous strips", ok, ok)
  check("p outside 0..1 is clamped", near(G.Slices(tile, card, 2, N, "left")[N].top, card.top)
    and near(G.Slices(tile, card, -1, N, "left")[N].top, tile.top), "")
`, 'genie-slices');

// --- Genie: strip colour -------------------------------------------------------------------
run(`
  local G = HorizonSuite.Echo.Genie
  local tileRGB, bg = { 0.2, 0.7, 0.9 }, { 0.06, 0.06, 0.09, 0.94 }
  local function eq(a, b) return math.abs(a - b) < 1e-6 end
  local r, g, b, a = G.StripColor(tileRGB, bg, 0, 0.5)
  check("the neck is the tile's colour", eq(r, 0.2) and eq(g, 0.7) and eq(b, 0.9) and eq(a, 1), r)
  r, g, b, a = G.StripColor(tileRGB, bg, 1, 0.5)
  check("the far end is the panel background", eq(r, 0.06) and eq(g, 0.06) and eq(b, 0.09) and eq(a, 0.94), r)
  r, g, b = G.StripColor(tileRGB, bg, 1, 0)
  check("at p=0 the whole sheet is the tile's colour", eq(r, 0.2) and eq(b, 0.9), r)
  r, g, b = G.StripColor(tileRGB, bg, 0, 1)
  check("at p=1 the whole sheet is the panel background", eq(r, 0.06) and eq(b, 0.09), r)
  local rm = G.StripColor(tileRGB, bg, 0.5, 0.5)
  check("between the ends it blends", rm < 0.2 and rm > 0.06, rm)
`, 'genie-color');

// --- Genie: Play drives the overlay and calls onDone -----------------------------------------
run(`
  local G = HorizonSuite.Echo.Genie
  local savedCreateFrame = CreateFrame
  CreateFrame = STUB_CREATE_FRAME
  local function Rect(l, r, b, t)
    local f = STUB_FRAME()
    f.GetLeft = function() return l end
    f.GetRight = function() return r end
    f.GetBottom = function() return b end
    f.GetTop = function() return t end
    f.GetEffectiveScale = function() return 1 end
    return f
  end
  local tile, card = Rect(100, 130, 120, 150), Rect(138, 498, 100, 540)

  -- No geometry (the harness's own stand-ins): straight to onDone.
  local done = 0
  G.Play({ from = STUB_FRAME(), to = STUB_FRAME(), onDone = function() done = done + 1 end })
  check("an unreadable rect goes straight to onDone", done == 1, done)
  check("an unreadable rect leaves nothing playing", not G.IsPlaying(), "playing")

  done = 0
  G.Play({ from = tile, to = card, color = { 0.2, 0.7, 0.9 }, edge = "left", onDone = function() done = done + 1 end })
  local ov = G._overlay()
  check("Play builds the overlay", ov ~= nil, "nil")
  check("the overlay shows", ov.shown, ov.shown)
  check("the overlay has 32 strips", #ov.strips == 32, #ov.strips)
  check("Play is playing", G.IsPlaying(), "idle")
  check("onDone not called yet", done == 0, done)
  local tick = ov.scripts.OnUpdate
  tick(ov, 0.05)
  local p1 = G.Progress()
  check("the open runs forward", p1 > 0 and p1 < 1, p1)
  check("strips are laid against UIParent", ov.strips[1].points[1] and ov.strips[1].points[1][2] == UIParent, "")
  check("strips get a colour", ov.strips[1].colorTexture ~= nil, "nil")
  tick(ov, 0.05)
  check("progress keeps climbing", G.Progress() > p1, G.Progress())
  tick(ov, 1)
  check("onDone runs once at the end", done == 1, done)
  check("the overlay hides at the end", not ov.shown, ov.shown)
  check("nothing plays after the end", not G.IsPlaying(), "playing")
  tick(ov, 0.1)
  check("a stray tick after the end does nothing", done == 1, done)

  -- Reverse runs p from 1 down to 0.
  done = 0
  G.Play({ from = tile, to = card, reverse = true, edge = "left", onDone = function() done = done + 1 end })
  tick(ov, 0.05)
  local r1 = G.Progress()
  check("reverse starts near 1", r1 < 1 and r1 > 0.5, r1)
  tick(ov, 0.05)
  check("reverse runs backward", G.Progress() < r1, G.Progress())
  tick(ov, 1)
  check("reverse calls onDone at the end", done == 1, done)
  -- The close ends with a short bright flash on the tile, then hides.
  check("the flash keeps the overlay up", ov.shown, ov.shown)
  tick(ov, 1)
  check("the flash ends and the overlay hides", not ov.shown, ov.shown)

  -- Stop drops onDone.
  done = 0
  G.Play({ from = tile, to = card, edge = "left", onDone = function() done = done + 1 end })
  tick(ov, 0.05)
  G.Stop()
  check("Stop hides the overlay", not ov.shown, ov.shown)
  tick(ov, 1)
  check("Stop drops onDone", done == 0, done)

  -- Frames rescaled away from UIParent are measured in UIParent units.
  local scaled = Rect(50, 65, 60, 75)
  scaled.GetEffectiveScale = function() return 2 end
  local rect = G.ReadRect(scaled)
  check("a rect is read in UIParent units", rect and rect.left == 100 and rect.top == 150, rect and rect.left)
  G.Stop()
  CreateFrame = savedCreateFrame
`, 'genie-play');

// --- Card: opens and closes with a genie from its tile --------------------------------------
run(`
  local Echo = HorizonSuite.Echo
  local S, T, K, C, G, V = Echo.Store, Echo.Tiles, Echo.Stack, Echo.Card, Echo.Genie, Echo.View
  S.Reset()
  local savedCreateFrame = CreateFrame
  CreateFrame = STUB_CREATE_FRAME
  local db = {}
  HorizonSuite.ECHO_DEFAULTS = { echoAnimateCard = true, echoColumnEdge = "right" }
  HorizonSuite.GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  T.Enable()
  K.Enable()
  C.Enable()
  local f = C._frames()

  local function Geometry(frame, l, r, b, t)
    frame.GetLeft = function() return l end
    frame.GetRight = function() return r end
    frame.GetBottom = function() return b end
    frame.GetTop = function() return t end
  end
  local alphas = {}
  f.root.SetAlpha = function(self, a) self.alphaValue = a; alphas[#alphas + 1] = a end
  f.root.GetAlpha = function(self) return rawget(self, "alphaValue") or 1 end
  Geometry(f.root, 500, 860, 100, 540)

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon" })
  S.Add({ convKey = "w:Vexa-Horizon", text = "gz", sender = "Vexa-Horizon" })
  local vexa = T.TileFor("w:Vexa-Horizon")
  local brisa = T.TileFor("w:Brisa-Horizon")
  check("the column has tiles", vexa ~= nil and brisa ~= nil, "nil")
  Geometry(vexa, 870, 900, 120, 150)
  Geometry(brisa, 870, 900, 160, 190)

  -- Open from a tile: the card is shown at alpha 0 and a genie pours out of the tile.
  vexa.scripts.OnClick(vexa)
  check("a tile open shows the card", f.root:IsShown(), "hidden")
  check("a tile open starts at alpha 0", f.root:GetAlpha() == 0, f.root:GetAlpha())
  check("a tile open starts a genie", G.IsPlaying(), "idle")
  check("the genie runs forward", not G._current().reverse, "reverse")
  check("the genie starts from the tile", G._current().from == vexa, "")
  local r, g, b = V.FaceBackground(V.TileSpec(S.Get("w:Vexa-Horizon")))
  local col = G._current().color
  check("the genie is the tile's face colour", col[1] == r and col[2] == g and col[3] == b, col[1])
  check("the genie opens away from the column", G._current().edge == "right", G._current().edge)
  local ov = G._overlay()
  ov.scripts.OnUpdate(ov, 1)
  check("the genie ends", not G.IsPlaying(), "playing")
  check("the contents are still hidden when the sheet ends", f.root:GetAlpha() < 0.05, f.root:GetAlpha())
  local fader = C._frames().fader
  check("a fader is running", fader ~= nil and fader.shown, "")
  fader.scripts.OnUpdate(fader, 0.075)
  local mid = f.root:GetAlpha()
  check("the contents fade in", mid > 0 and mid < 1, mid)
  fader.scripts.OnUpdate(fader, 0.2)
  check("the fade ends at alpha 1", f.root:GetAlpha() == 1, f.root:GetAlpha())
  check("the fader stops", not fader.shown, fader.shown)

  -- Close by clicking the shown conversation's tile: a reverse genie, then the hide.
  vexa.scripts.OnClick(vexa)
  check("a toggle close keeps the card up during the genie", f.root:IsShown(), "hidden")
  check("a toggle close hides the contents at once", f.root:GetAlpha() == 0, f.root:GetAlpha())
  check("a toggle close runs a reverse genie", G.IsPlaying() and G._current().reverse, "")
  vexa.scripts.OnClick(vexa)
  check("a second click during the close is ignored", f.root:IsShown() and G.IsPlaying() and G._current().reverse, "")
  ov.scripts.OnUpdate(ov, 1)
  check("the close hides the card at the end", not f.root:IsShown(), "shown")
  check("the close restores alpha for the next open", f.root:GetAlpha() == 1, f.root:GetAlpha())
  ov.scripts.OnUpdate(ov, 1)
  check("the tile flash ends", not ov.shown, ov.shown)

  -- Escape (Card.Hide) is instant, mid-open, and restores alpha.
  vexa.scripts.OnClick(vexa)
  check("reopened with a genie", G.IsPlaying(), "idle")
  C.Hide()
  check("Hide is instant", not f.root:IsShown(), "shown")
  check("Hide stops the genie", not G.IsPlaying(), "playing")
  check("Hide restores alpha", f.root:GetAlpha() == 1, f.root:GetAlpha())
  ov.scripts.OnUpdate(ov, 1)
  check("a stopped open never fades in", C._frames().fader == nil or not C._frames().fader.shown, "")

  -- Hide mid-fade stops the fade too.
  vexa.scripts.OnClick(vexa)
  ov.scripts.OnUpdate(ov, 1)
  C.Hide()
  check("Hide stops the fade", not C._frames().fader.shown, "")
  check("Hide after a fade restores alpha", f.root:GetAlpha() == 1, f.root:GetAlpha())

  -- Escape during a close: instant too.
  vexa.scripts.OnClick(vexa)
  ov.scripts.OnUpdate(ov, 1)
  C._frames().fader.scripts.OnUpdate(C._frames().fader, 1)
  vexa.scripts.OnClick(vexa)
  check("closing", G.IsPlaying() and G._current().reverse, "")
  f.root:Hide()
  f.root.scripts.OnHide(f.root)
  check("OnHide during a close stops the genie", not G.IsPlaying(), "playing")
  check("OnHide restores alpha", f.root:GetAlpha() == 1, f.root:GetAlpha())
  vexa.scripts.OnClick(vexa)
  check("a click after an interrupted close opens again", f.root:IsShown() and G.IsPlaying() and not G._current().reverse, "")
  C.Hide()

  -- Opening another conversation while a close genie runs stops it and opens normally.
  vexa.scripts.OnClick(vexa)
  ov.scripts.OnUpdate(ov, 1)
  C._frames().fader.scripts.OnUpdate(C._frames().fader, 1)
  vexa.scripts.OnClick(vexa)
  check("closing again", G.IsPlaying() and G._current().reverse, "")
  brisa.scripts.OnClick(brisa)
  check("another tile mid-close cancels the close", not G.IsPlaying(), "playing")
  check("and shows the card at full alpha", f.root:IsShown() and f.root:GetAlpha() == 1, f.root:GetAlpha())
  check("on the other conversation", f.name.text == "Brisa", f.name.text)
  ov.scripts.OnUpdate(ov, 1)
  check("the cancelled close never hides the card", f.root:IsShown(), "hidden")

  -- The card's own row tile closes into the column tile, when it is visible.
  local rowTile
  for _, t in ipairs(f.rowTiles) do if t.convKey == "w:Brisa-Horizon" then rowTile = t end end
  rowTile.scripts.OnClick(rowTile)
  check("a row tile close runs a reverse genie", G.IsPlaying() and G._current().reverse, "")
  check("into the column tile", G._current().from == brisa, "")
  ov.scripts.OnUpdate(ov, 1)
  ov.scripts.OnUpdate(ov, 1)
  check("and hides", not f.root:IsShown(), "shown")

  -- No tile, or the setting off: shown at alpha 1, no genie.
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

  -- A tile with no geometry (the harness's stand-ins) still opens, straight to the fade.
  vexa.GetLeft = nil
  vexa.scripts.OnClick(vexa)
  check("an unmeasurable tile still opens", f.root:IsShown() and not G.IsPlaying(), "")
  C.Hide()

  C.Disable()
  K.Disable()
  T.Disable()
  G.Stop()
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
  check("a retried bubble is dimmed like a pending one", f.bubbles[2].alpha == 0.14, f.bubbles[2].alpha)

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
  check("a failed bubble is not dimmed", f.bubbles[1].alpha == 0.24, f.bubbles[1].alpha)

  R.sync = false
  f.status.scripts.OnClick(f.status)
  check("retry still marks the record retried", failedMsg.status == "retried", failedMsg.status)
  check("the card is pending a repaint, not rendered inline", R.Pending("card") == true, R.Pending("card"))
  check("the dimmed styling has not landed yet", f.bubbles[1].alpha == 0.24, f.bubbles[1].alpha)
  R.Flush()
  check("the dimmed styling lands once the deferred repaint runs", f.bubbles[2].alpha == 0.14, f.bubbles[2].alpha)
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
  A.Button = function(n, d, f) return { type = "button", name = n, desc = d, onClick = f } end
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

  A.OptionsData_SetDB("echoX", 800)
  A.OptionsData_SetDB("echoY", 300)
  keys.echoColumnEdge.set("left")
  check("the edge setter clears the dragged position", A.OptionsData_GetDB("echoX") == nil and A.OptionsData_GetDB("echoY") == nil, tostring(A.OptionsData_GetDB("echoX")))

  A.OptionsData_SetDB("echoX", 800)
  A.OptionsData_SetDB("echoY", 300)
  keys.echoColumnEdge.set("auto")
  check("switching to auto keeps the dragged position", A.OptionsData_GetDB("echoX") == 800 and A.OptionsData_GetDB("echoY") == 300, tostring(A.OptionsData_GetDB("echoX")))
  check("switching to auto stores auto", A.OptionsData_GetDB("echoColumnEdge") == "auto", A.OptionsData_GetDB("echoColumnEdge"))

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
  check("channel General is Gen", genSpec.letter == "Gen" and genSpec.small == true, genSpec.letter)
  S.Add({ convKey = "ch:Guild", text = "hi" })
  local chGuildSpec = V.TileSpec(S.Get("ch:Guild"))
  check("a channel named Guild isn't the guild kind", chGuildSpec.letter == "Guil" and chGuildSpec.small == true, chGuildSpec.letter)
  S.Add({ convKey = "guild", text = "gz" })
  local guildSpec = V.TileSpec(S.Get("guild"))
  check("the guild kind is its glyph", guildSpec.letter == "G" and not guildSpec.small, guildSpec.letter)
  S.Add({ convKey = "ch:Trade", text = "wts" })
  local tradeSpec = V.TileSpec(S.Get("ch:Trade"))
  check("channel Trade is Trade", tradeSpec.letter == "Trade" and tradeSpec.small == true, tradeSpec.letter)
  S.Add({ convKey = "ch:Local Defense", text = "inc" })
  local defSpec = V.TileSpec(S.Get("ch:Local Defense"))
  check("channel Local Defense is Def", defSpec.letter == "Def" and defSpec.small == true, defSpec.letter)
  S.Add({ convKey = "ch:MyCustom", text = "hi" })
  local customSpec = V.TileSpec(S.Get("ch:MyCustom"))
  check("an unlisted channel is capped at 4", customSpec.letter == "MyCu" and customSpec.small == true, customSpec.letter)

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", class = "DRUID", sender = "Brisa-Horizon" })
  local brisa = S.Get("w:Brisa-Horizon")
  HorizonSuite.ResolveClassIconDisplay = function(class, source) return { kind = "file", path = "X" } end
  local classSpec = V.TileSpec(brisa)
  check("a resolved class gives a class face", classSpec.face == "class", classSpec.face)
  check("the class face carries the icon", classSpec.classIcon and classSpec.classIcon.path == "X", "?")
  check("a whisper's label is its name", classSpec.label == "Brisa", classSpec.label)
  check("the Services channel reads Serv", V.TileSpec({ key = "ch:Trade (Services)", kind = "channel", unread = 0, messages = {} }).letter == "Serv",
    V.TileSpec({ key = "ch:Trade (Services)", kind = "channel", unread = 0, messages = {} }).letter)
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

  -- With no classless open whisper conversation, a guild event marks nothing.
  S.Reset()
  ResetMarks()
  frame.scripts.OnEvent(frame, "GUILD_ROSTER_UPDATE")
  check("no classless whisper: a guild event marks nothing", next(marks) == nil, "marked something")

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
  check("the shown conversation marks the full card", marks.card == true and marks.cardRow == nil, "?")
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

  -- A General channel: letter "Gen" at the small size, on every host.
  S.Add({ convKey = "ch:General", text = "lfg" })
  local genSpec = V.TileSpec(S.Get("ch:General"))
  check("setup: General channel is Gen, small", genSpec.letter == "Gen" and genSpec.small == true, genSpec.letter)

  local genTile = T.TileFor("ch:General")
  check("column tile: Gen letter", genTile.letter.text == "Gen", genTile.letter.text)
  check("column tile: Gen small size", genTile.letter._echoSize == 10, tostring(genTile.letter._echoSize))

  C.Open("ch:General")
  local genRow
  for _, b in ipairs(cf.rowTiles) do if b.convKey == "ch:General" then genRow = b end end
  check("card row tile: Gen letter", genRow and genRow.letter.text == "Gen", "?")
  check("card row tile: Gen small size", genRow and genRow.letter._echoSize == 8, tostring(genRow and genRow.letter._echoSize))
  C.Hide()

  K.Open("ch:General")
  check("stack card tile: Gen letter", kf.card.letter.text == "Gen", kf.card.letter.text)
  check("stack card tile: Gen small size", kf.card.letter._echoSize == 9, tostring(kf.card.letter._echoSize))
  K.Hide()

  T.ShowToast("ch:General")
  toast = T._toast()
  check("toast: Gen letter", toast.entry.letter.text == "Gen", toast.entry.letter.text)
  check("toast: Gen small size", toast.entry.letter._echoSize == 9, tostring(toast.entry.letter._echoSize))

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
  check("H5: the label shade draws in ARTWORK, under the OVERLAY label text", tile.labelShade.drawLayer == "ARTWORK" and tile.labelShade.drawSublevel == 7, tostring(tile.labelShade.drawLayer) .. "/" .. tostring(tile.labelShade.drawSublevel))
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
