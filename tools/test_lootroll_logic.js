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
    Augment = { QUALITY_COLORS = { [1]={1,1,1},[4]={0.64,0.21,0.93} }, DB_KEYS = {} },
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

// --- Assertions -----------------------------------------------------------
run(`
  local R = HorizonSuite.Augment.Roll
  local T = R.Tally
  local pass, fail = 0, 0
  local function check(name, ok, got)
    if ok then pass = pass + 1
    else fail = fail + 1; print("  FAIL: " .. name .. "  got: " .. tostring(got)) end
  end

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

  print(("\\n%d passed, %d failed"):format(pass, fail))
  if fail > 0 then error("assertions failed") end
`, 'assertions');
