#!/usr/bin/env node
/**
 * Executable checks for the pure-logic half of Augment's loot roll module:
 * roll-state bucketing, the loot-history join, tally formatting and item badges.
 *
 * Why this exists. None of that logic can be exercised without a live group
 * rolling on loot, which makes it exactly the code most likely to ship wrong.
 * It is also pure — no frames, no secure calls — so it runs fine in a plain Lua
 * VM with the WoW globals stubbed. The shipped locale file is loaded too, so
 * the format templates under test are the real ones.
 *
 * Covers in particular:
 *   - WoW: Forever has no specialisations, so an off-spec Need must collapse
 *     into Need rather than rendering an "off-spec" label for a client that
 *     has no off-spec.
 *   - ResolveDrop must fail closed. Loot history carries no rollID, so the join
 *     is by item link; two simultaneous rolls on the same link must yield NO
 *     tally rather than a confident wrong one.
 *
 * Usage:
 *   npm install fengari     # one dependency, not vendored
 *   node tools/test_lootroll_logic.js
 *
 * Not wired into CI: the Luacheck workflow is a Lua parse gate with no node step.
 */

const fs = require('fs');
const path = require('path');

let fengari;
try {
  fengari = require('fengari');
} catch (e) {
  console.log('SKIP: fengari not installed.  npm install fengari');
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

// --- Stub the slice of the WoW/addon environment these files touch ---------
run(`
  _G.HorizonSuite = {
    Augment = { QUALITY_COLORS = { [1]={1,1,1},[4]={0.64,0.21,0.93} }, DB_KEYS = {},
                ToastMotion = { EDGE = 8, CHROME_HEIGHT_PAD = 10 } },
    AUGMENT_DEFAULTS = {}, AUGMENT_LIMITS = {},
    L = setmetatable({}, { __index = function(_, k) return k end }),
    GetDB = function(k, d) return d end,
    Platform = { caps = { specs = true, transmog = true, lootHistory = true },
                 Has = function(k) return _G.HorizonSuite.Platform.caps[k] == true end },
  }
  Enum = { EncounterLootDropRollState = {
    NeedMainSpec = 0, NeedOffSpec = 1, Transmog = 2, Greed = 3, NoRoll = 4, Pass = 5 } }
  C_LootHistory = {}
  C_Item = {}
`, 'stubs');

// Load the real locale so format templates are the shipped ones, not stubs.
run(read('locales/horizon/enUS.lua'), 'enUS');

run(read('modules/Augment/LootRoll/AugmentRollState.lua'),  'RollState');
run(read('modules/Augment/LootRoll/AugmentRollTally.lua'),  'RollTally');
run(read('modules/Augment/LootRoll/AugmentRollBadges.lua'), 'RollBadges');
run(read('modules/Augment/LootRoll/AugmentRollFrames.lua'), 'RollFrames');
run(read('modules/Augment/LootRoll/AugmentRollDemo.lua'), 'RollDemo');

// --- Assertions -----------------------------------------------------------
run(`
  local R = HorizonSuite.Augment.Roll
  local T = R.Tally
  local pass, fail = 0, 0
  local function check(name, ok, got)
    if ok then pass = pass + 1
    else fail = fail + 1; print("  FAIL: " .. name .. "  got: " .. tostring(got)) end
  end

  -- The module ships DISABLED, so the frame pool is never built until someone
  -- turns it on — yet the platform probe, /h roll status and /h roll clear all
  -- read the pool regardless. On the Retail client, with the module still off,
  -- /h platform probe died with "attempt to index field '?' (a nil value)".
  -- Forever never showed it only because the module had been switched on there
  -- first. These run BEFORE InitFrames, which is the default state for everyone.
  local function noThrow(fn, ...) return (pcall(fn, ...)) end
  check("HasActiveRows before InitFrames does not throw", noThrow(R.HasActiveRows), "threw")
  check("HasActiveRows before InitFrames is false", R.HasActiveRows() == false, R.HasActiveRows())
  check("FindRow before InitFrames does not throw", noThrow(R.FindRow, 1), "threw")
  check("FindRow before InitFrames is nil", R.FindRow(1) == nil, R.FindRow(1))
  check("ReleaseRoll before InitFrames does not throw (/h roll clear)", noThrow(R.ReleaseRoll, 900001), "threw")
  check("Restack before InitFrames does not throw", noThrow(R.Restack), "threw")
  check("ClearAllRolls before InitFrames does not throw", noThrow(R.ClearAllRolls), "threw")
  check("RefreshAllTallies before InitFrames does not throw", noThrow(R.RefreshAllTallies), "threw")

  -- Info-line layout. The first live demo put badges and tally on one line and
  -- the ellipsis ate the leader's name. Each gets a line now, and whichever is
  -- present moves up when the other is empty, so no row shows a blank line.
  local function fakeFS()
    return {
      text = nil, points = {},
      SetText = function(self, t) self.text = t end,
      ClearAllPoints = function(self) self.points = {} end,
      SetPoint = function(self, ...) self.points[#self.points + 1] = { ... } end,
      SetJustifyH = function(self, j) self.justify = j end,
    }
  end
  local function fakeRow()
    return {
      frame = {},
      title = fakeFS(), body = fakeFS(), tally = fakeFS(),
      -- Framed style: the icon itself is the anchor, inset 8 from the edge.
      icon = { GetPoint = function() return "LEFT", nil, "LEFT", 8, 0 end,
               GetWidth = function() return 40 end },
      iconBg = { IsShown = function() return false end },
      bar = { GetWidth = function() return 86 end },
    }
  end
  local function y(fs) return fs.points[1] and fs.points[1][5] end

  local row = fakeRow()
  R.SetInfoLines(row, "BADGES", "TALLY")
  check("both present: three lines", row.lineCount == 3, row.lineCount)
  check("both present: badges on the middle line", row.body.text == "BADGES", row.body.text)
  check("both present: tally on the bottom line", row.tally.text == "TALLY", row.tally.text)
  check("both present: name above badges above tally",
        y(row.title) > y(row.body) and y(row.body) > y(row.tally),
        tostring(y(row.title)) .. "/" .. tostring(y(row.body)) .. "/" .. tostring(y(row.tally)))
  check("both present: block centred on the icon", y(row.body) == 0, y(row.body))

  -- Both horizontal points hang off the same frame at the same height, which
  -- is the fix: no line is pinned between two anchors that disagree.
  local p1, p2 = row.title.points[1], row.title.points[2]
  check("each line anchored to the frame on both sides",
        p1[2] == row.frame and p2[2] == row.frame, "mixed anchors")
  check("left and right anchors agree vertically", p1[5] == p2[5], tostring(p1[5]) .. " vs " .. tostring(p2[5]))
  check("text clears the icon: 8 inset + 40 icon + 10 gap", p1[4] == 58, p1[4])
  check("text clears the buttons: 8 edge + 86 bar + 8 gap", p2[4] == -102, p2[4])

  row = fakeRow()
  R.SetInfoLines(row, "", "TALLY")
  check("no badges: tally moves up", row.body.text == "TALLY" and row.tally.text == "", row.body.text)
  check("no badges: two lines", row.lineCount == 2, row.lineCount)
  check("no badges: bottom line unanchored", #row.tally.points == 0, #row.tally.points)

  row = fakeRow()
  R.SetInfoLines(row, "BADGES", "")
  check("no tally: badges stay under the name", row.body.text == "BADGES" and row.tally.text == "", row.body.text)
  check("no tally: two lines", row.lineCount == 2, row.lineCount)

  row = fakeRow()
  R.SetInfoLines(row, "", "")
  check("nothing to say: name alone, centred", row.lineCount == 1 and y(row.title) == 0, row.lineCount)

  -- Remembered so an own-roll result can replace the tally and leave badges.
  row = fakeRow()
  R.SetInfoLines(row, "BADGES", "TALLY")
  R.SetInfoLines(row, row.badgeText, "You rolled 87")
  check("own roll replaces the tally, keeps the badges",
        row.body.text == "BADGES" and row.tally.text == "You rolled 87", row.tally.text)

  -- Mirrored: icon on the right, buttons packed against the left edge.
  local realGetDB = HorizonSuite.GetDB
  HorizonSuite.GetDB = function(k, d)
    if k == "lootRollIconSide" then return "right" end
    return realGetDB(k, d)
  end
  row = fakeRow()
  row.icon.GetPoint = function() return "RIGHT", nil, "RIGHT", -8, 0 end
  R.SetInfoLines(row, "BADGES", "TALLY")
  p1, p2 = row.title.points[1], row.title.points[2]
  check("mirrored: text clears the buttons on the left", p1[4] == 102, p1[4])
  check("mirrored: text clears the icon on the right", p2[4] == -58, p2[4])
  check("mirrored: text right-justified", row.title.justify == "RIGHT", row.title.justify)
  HorizonSuite.GetDB = realGetDB

  -- Bucketing, specs present
  check("NeedMainSpec -> need",  T.BucketForState(0) == "need",     T.BucketForState(0))
  check("NeedOffSpec -> needOff", T.BucketForState(1) == "needOff", T.BucketForState(1))
  check("Transmog",  T.BucketForState(2) == "transmog", T.BucketForState(2))
  check("Greed",     T.BucketForState(3) == "greed",    T.BucketForState(3))
  check("NoRoll -> waiting", T.BucketForState(4) == "waiting", T.BucketForState(4))
  check("Pass",      T.BucketForState(5) == "pass",     T.BucketForState(5))
  check("nil state", T.BucketForState(nil) == nil,      T.BucketForState(nil))

  -- THE FOREVER CASE: no specs, off-spec Need must collapse into Need
  HorizonSuite.Platform.caps.specs = false
  check("no specs: NeedOffSpec collapses to need", T.BucketForState(1) == "need", T.BucketForState(1))
  check("no specs: NeedMainSpec still need",       T.BucketForState(0) == "need", T.BucketForState(0))
  HorizonSuite.Platform.caps.specs = true

  -- Summarise
  local drop = {
    rollInfos = {
      { playerName = "Ana",  playerClass = "MAGE",   state = 0, isSelf = false },
      { playerName = "Bo",   playerClass = "ROGUE",  state = 0, isSelf = true  },
      { playerName = "Cy",   playerClass = "PRIEST", state = 3, isSelf = false },
      { playerName = "Di",   playerClass = "DRUID",  state = 5, isSelf = false },
      { playerName = "Ed",   playerClass = "WARLOCK",state = 4, isSelf = false },
    },
    currentLeader = { playerName = "Ana", roll = 87, playerClass = "MAGE" },
    isTied = false, allPassed = false,
  }
  local s = T.Summarise(drop)
  check("summary total",   s.total == 5,        s.total)
  check("summary rolled",  s.rolled == 4,       s.rolled)
  check("summary need=2",  s.counts.need == 2,  s.counts.need)
  check("summary greed=1", s.counts.greed == 1, s.counts.greed)
  check("summary pass=1",  s.counts.pass == 1,  s.counts.pass)
  check("summary waiting=1", s.counts.waiting == 1, s.counts.waiting)
  check("summary youRolled", s.youRolled == "need", s.youRolled)
  check("summary leader",  s.leaderName == "Ana" and s.leaderRoll == 87, s.leaderName)

  -- Formatting
  local line = T.FormatLine(s)
  check("line mentions counts", line:find("2") ~= nil and line:find("1") ~= nil, line)
  check("line mentions leader", line:find("Ana") ~= nil, line)
  check("line mentions leader roll", line:find("87") ~= nil, line)

  check("nil summary -> empty", T.FormatLine(nil) == "", T.FormatLine(nil))

  local won = T.Summarise({ rollInfos = {}, winner = { playerName = "Zed", roll = 99 } })
  check("winner line names winner", T.FormatLine(won):find("Zed") ~= nil, T.FormatLine(won))
  check("winner line shows roll", T.FormatLine(won):find("99") ~= nil, T.FormatLine(won))

  local allPassed = T.Summarise({ rollInfos = {}, allPassed = true })
  check("all passed line", T.FormatLine(allPassed) == "Everyone passed",
        T.FormatLine(allPassed))

  -- Nobody has chosen yet
  local waiting = T.Summarise({ rollInfos = {
    { playerName="A", playerClass="MAGE", state=4, isSelf=false },
    { playerName="B", playerClass="MAGE", state=4, isSelf=false } } })
  check("waiting-only line non-empty", T.FormatLine(waiting) ~= "", T.FormatLine(waiting))

  -- ResolveDrop fails closed
  check("no link -> nil", T.ResolveDrop(nil) == nil, "nil")
  check("empty link -> nil", T.ResolveDrop("") == nil, "empty")
  HorizonSuite.Platform.caps.lootHistory = false
  check("no lootHistory capability -> nil", T.ResolveDrop("|Hitem:1|h[x]|h") == nil, "gated")
  HorizonSuite.Platform.caps.lootHistory = true

  -- Ambiguity: two unfinished drops with the same link must resolve to nothing
  C_LootHistory.GetLootHistoryTime = function() return 100 end
  C_LootHistory.GetAllEncounterInfos = function() return { { encounterID = 1 } } end
  C_LootHistory.GetSortedDropsForEncounter = function()
    return {
      { itemHyperlink = "SAME", startTime = 98, duration = 30, rollInfos = {} },
      { itemHyperlink = "SAME", startTime = 99, duration = 30, rollInfos = {} },
    }
  end
  check("ambiguous link -> nil (fails closed)", T.ResolveDrop("SAME") == nil, "ambiguous")

  C_LootHistory.GetSortedDropsForEncounter = function()
    return { { itemHyperlink = "ONE", startTime = 98, duration = 30, rollInfos = {} } }
  end
  check("single match resolves", T.ResolveDrop("ONE") ~= nil, "single")

  -- A finished drop is not a candidate for a roll still on screen
  C_LootHistory.GetSortedDropsForEncounter = function()
    return { { itemHyperlink = "DONE", startTime = 98, duration = 30, rollInfos = {},
               winner = { playerName = "X", roll = 1 } } }
  end
  check("finished drop ignored", T.ResolveDrop("DONE") == nil, "finished")

  -- Outside the time window
  C_LootHistory.GetSortedDropsForEncounter = function()
    return { { itemHyperlink = "OLD", startTime = 10, duration = 30, rollInfos = {} } }
  end
  check("stale drop ignored", T.ResolveDrop("OLD") == nil, "stale")

  -- Badges
  local B = R.Badges
  check("bind badge off when not BoP", B.Bind(false) == nil, B.Bind(false))
  check("bind badge on when BoP", B.Bind(true) ~= nil, B.Bind(true))
  check("appearance nil without link", B.Appearance(nil) == nil, "nil link")
  check("ilvl nil without link", B.ItemLevel(nil) == nil, "nil link")

  -- Item level delta against the weaker of two rings
  C_Item.GetItemInfo = function(link)
    if link == "RING_NEW" then return "Ring", link, 3, 100, 60, "", "", 1, "INVTYPE_FINGER" end
    if link == "RING_A" then return "A", link, 3, 90, 60, "", "", 1, "INVTYPE_FINGER" end
    if link == "RING_B" then return "B", link, 3, 80, 60, "", "", 1, "INVTYPE_FINGER" end
    return nil
  end
  GetInventoryItemLink = function(_, slot)
    if slot == 11 then return "RING_A" end
    if slot == 12 then return "RING_B" end
    return nil
  end
  local badge = B.ItemLevel("RING_NEW")
  check("ilvl compares against weaker ring (+20)", badge and badge:find("%+20") ~= nil, badge)

  GetInventoryItemLink = function() return nil end
  check("ilvl nil with empty slots", B.ItemLevel("RING_NEW") == nil, B.ItemLevel("RING_NEW"))

  -- Appearance badge. PlayerHasTransmogByItemInfo answers FALSE, not nil, for
  -- things that were never collectable: a Gold Bar came back false on the
  -- Forever beta and earned itself a "New look" badge. "Not collected" and
  -- "nothing here to collect" must not share a branch.
  C_TransmogCollection = {
    PlayerHasTransmogByItemInfo = function() return false end,
    GetItemInfo = function(link)
      if link == "HOOD" then return 12345, 67890 end   -- has an appearance
      return nil                                        -- trade good: none
    end,
  }
  check("no badge on an item with no appearance (the Gold Bar bug)",
        B.Appearance("GOLD_BAR") == nil, B.Appearance("GOLD_BAR"))
  check("badge on an uncollected appearance",
        B.Appearance("HOOD") ~= nil, B.Appearance("HOOD"))

  -- Already collected: no badge.
  C_TransmogCollection.PlayerHasTransmogByItemInfo = function() return true end
  check("no badge when already collected", B.Appearance("HOOD") == nil, B.Appearance("HOOD"))

  -- "Cannot tell" is not "you do not have it".
  C_TransmogCollection.PlayerHasTransmogByItemInfo = function() return nil end
  check("no badge when the client cannot tell", B.Appearance("HOOD") == nil, B.Appearance("HOOD"))

  -- Fallback path: no GetItemInfo on this client, judge by equip slot.
  C_TransmogCollection.GetItemInfo = nil
  C_TransmogCollection.PlayerHasTransmogByItemInfo = function() return false end
  C_Item.GetItemInfo = function(link)
    if link == "HEAD_ITEM" then return "H", link, 3, 80, 60, "", "", 1, "INVTYPE_HEAD" end
    if link == "RING_ITEM" then return "R", link, 3, 80, 60, "", "", 1, "INVTYPE_FINGER" end
    if link == "TRADE_GOOD" then return "G", link, 1, 0, 1, "", "", 20, "" end
    return nil
  end
  check("fallback: badge on a head slot", B.Appearance("HEAD_ITEM") ~= nil, B.Appearance("HEAD_ITEM"))
  check("fallback: no badge on a ring (equippable, no appearance)",
        B.Appearance("RING_ITEM") == nil, B.Appearance("RING_ITEM"))
  check("fallback: no badge on a trade good",
        B.Appearance("TRADE_GOOD") == nil, B.Appearance("TRADE_GOOD"))

  -- Demo item loading. Item:CreateFromItemID is a COLON method. Called with a
  -- dot, the itemID lands in self and the real argument is nil, so every item
  -- comes back empty and nothing redraws — the Forever demo showed four
  -- "Demo Item" placeholders where the previous build had resolved three.
  -- Runs last: it replaces frame functions the earlier checks relied on.
  local received = {}
  Item = {
    CreateFromItemID = function(self, itemID)
      received[#received + 1] = { selfIsItem = (self == Item), itemID = itemID }
      return { IsItemEmpty = function() return itemID == nil end,
               ContinueOnItemLoad = function() end }
    end,
  }
  HorizonSuite.IsModuleEnabled = function() return true end
  R.InitFrames = function() end
  R.RestoreSavedPosition = function() end
  R.ShowRoll = function() return true end
  R.GetMaxVisible = function() return 4 end
  C_Item.GetItemInfo = function() return nil end
  C_Timer = { After = function() end }

  R.Demo.Run()
  check("demo asks for all four items", #received == 4, #received)
  local allGood = #received > 0
  for _, r in ipairs(received) do
    if not (r.selfIsItem and type(r.itemID) == "number") then allGood = false end
  end
  check("CreateFromItemID called as a method with a real itemID", allGood,
        received[1] and ("self=Item? " .. tostring(received[1].selfIsItem) ..
                         " itemID=" .. tostring(received[1].itemID)) or "no calls")

  print(("\\n%d passed, %d failed"):format(pass, fail))
  if fail > 0 then error("assertions failed") end
`, 'assertions');
