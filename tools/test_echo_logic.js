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
  'modules/Echo/EchoSend.lua',
  'modules/Echo/EchoSlash.lua',
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

// --- Summary -------------------------------------------------------------------
run(`
  print(PASS .. " passed, " .. FAIL .. " failed")
  if FAIL > 0 then error("echo logic tests failed") end
`, 'summary');
