#!/usr/bin/env node
/**
 * Executable checks for Focus entry sorting in modules/Focus/rendering/FocusAggregator.lua.
 *
 * Why this exists. "Reverse order" (entrySortReverse) flips the Alphabetical, Zone and
 * Quest level sorts. A player at max level has every quest at the same level, so an
 * in-game check cannot show the level order at all, and replacing C_QuestLog.GetInfo
 * from /run to fake levels did not reach the tracker on Midnight. These checks run the
 * real SortAndGroupQuests over quests at mixed levels instead.
 *
 * Group by zone (groupQuestsByZone) splits the same group into one section per zone; those
 * checks run the real SortAndGroupQuests too.
 *
 * Usage:
 *   npm install fengari     # one dependency, not vendored
 *   node tools/test_focus_sort_logic.js
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

const REPO = path.resolve(__dirname, '..') + '/';
const AGGREGATOR = fs
  .readFileSync(REPO + 'modules/Focus/rendering/FocusAggregator.lua', 'utf8')
  .replace(/^﻿/, '');

// Just enough of the addon and the client for the file to load and sort one group.
const STUBS = `
  DB = {}
  HorizonSuite = {
    L = setmetatable({}, { __index = function(_, k) return k end }),
    GetDB = function(k, d) local v = DB[k]; if v == nil then return d end; return v end,
    focus = {},
    CATEGORY_TO_GROUP = { DEFAULT = "DEFAULT" },
    GROUP_ORDER = { "DEFAULT" },
  }
  wipe = function(t) for k in pairs(t) do t[k] = nil end; return t end
  CreateFrame = function()
    return setmetatable({}, { __index = function() return function() end end })
  end
`;

// Titles and levels chosen so level ties exist and alphabetical order differs from level order.
const SORT = `
  function order(mode, reverse)
    DB.entrySortMode, DB.entrySortReverse = mode, reverse
    local quests = {
      { title = "Bravo",   level = 85, zoneName = "Hallowfall", category = "DEFAULT", questID = 1 },
      { title = "Alpha",   level = 90, zoneName = "Dornogal",   category = "DEFAULT", questID = 2 },
      { title = "Charlie", level = 80, zoneName = "Hallowfall", category = "DEFAULT", questID = 3 },
      { title = "Delta",   level = 85, zoneName = "Azj-Kahet",  category = "DEFAULT", questID = 4 },
      { title = "Echo",    level = 90, zoneName = "Dornogal",   category = "DEFAULT", questID = 5 },
    }
    local out = {}
    for _, g in ipairs(HorizonSuite.SortAndGroupQuests(quests)) do
      for _, q in ipairs(g.quests) do out[#out + 1] = q.title end
    end
    return table.concat(out, " ")
  end

  -- Sections and their entries with numbering, e.g. "ZONE:Dornogal=1.Alpha,2.Echo".
  function sections(byZone, quests)
    DB.entrySortMode, DB.entrySortReverse, DB.groupQuestsByZone = "alpha", false, byZone
    local out = {}
    for _, g in ipairs(HorizonSuite.SortAndGroupQuests(quests)) do
      local titles = {}
      for _, q in ipairs(g.quests) do titles[#titles + 1] = q.categoryIndex .. "." .. q.title end
      out[#out + 1] = g.key .. "=" .. table.concat(titles, ",")
    end
    return table.concat(out, " ")
  end

  function zoneSections(byZone)
    return sections(byZone, {
      { title = "Bravo",   zoneName = "hallowfall", category = "DEFAULT", questID = 1 },
      { title = "Alpha",   zoneName = "Dornogal",   category = "DEFAULT", questID = 2 },
      { title = "Charlie", zoneName = "hallowfall", category = "DEFAULT", questID = 3 },
      { title = "Delta",   zoneName = "Azj-Kahet",  category = "DEFAULT", questID = 4 },
      { title = "Echo",    zoneName = "Dornogal",   category = "DEFAULT", questID = 5 },
      { title = "Foxtrot",                          category = "DEFAULT", questID = 6 },
    })
  end

  function noQuests(byZone) return sections(byZone, {}) end

  -- Retail quest log topic headers ("Upgrade System") are not zones: the grouping resolver
  -- rejects them and falls back to the quest's own map, or to none.
  function topicHeaders()
    local mapZone = { [2] = "Voidstorm" }
    HorizonSuite.GetQuestGroupingZoneName = function(questID, header)
      if header == "Voidstorm" then return header end
      return mapZone[questID]
    end
    local out = sections(true, {
      { title = "Veteran Equipment", zoneName = "Upgrade System", category = "DEFAULT", questID = 1 },
      { title = "The Time to Strike", zoneName = "Void Assaults", category = "DEFAULT", questID = 2 },
      { title = "Harvest of Darkness", zoneName = "Voidstorm",    category = "DEFAULT", questID = 3 },
    })
    HorizonSuite.GetQuestGroupingZoneName = nil
    return out
  end
`;

const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);
const chunk = STUBS + '\n' + AGGREGATOR + '\n' + SORT;
if (lauxlib.luaL_loadstring(L, to_luastring(chunk)) !== 0 || lua.lua_pcall(L, 0, 0, 0) !== 0) {
  console.log('FAIL load: ' + to_jsstring(lua.lua_tostring(L, -1)));
  process.exit(1);
}

function order(mode, reverse) {
  lua.lua_getglobal(L, to_luastring('order'));
  lua.lua_pushstring(L, to_luastring(mode));
  lua.lua_pushboolean(L, reverse);
  if (lua.lua_pcall(L, 2, 1, 0) !== 0) return 'ERROR ' + to_jsstring(lua.lua_tostring(L, -1));
  const s = to_jsstring(lua.lua_tostring(L, -1));
  lua.lua_pop(L, 1);
  return s;
}

let failures = 0;
function check(label, actual, expected) {
  if (actual === expected) {
    console.log('ok   ' + label);
  } else {
    failures++;
    console.log('FAIL ' + label + ': expected "' + expected + '", got "' + actual + '"');
  }
}

check('level: highest first, ties A to Z', order('level', false), 'Alpha Echo Bravo Delta Charlie');
check('level reversed: lowest first, ties still A to Z', order('level', true), 'Charlie Bravo Delta Alpha Echo');
check('alpha: A to Z', order('alpha', false), 'Alpha Bravo Charlie Delta Echo');
check('alpha reversed: Z to A', order('alpha', true), 'Echo Delta Charlie Bravo Alpha');
check('zone: A to Z by zone, titles A to Z', order('zone', false), 'Delta Alpha Echo Bravo Charlie');
check('zone reversed: Z to A by zone, titles still A to Z', order('zone', true), 'Bravo Charlie Alpha Echo Delta');
// One category and no distance ranks, so both fall through to titles A to Z, reversed or not.
check('questType ignores reverse', order('questType', true), 'Alpha Bravo Charlie Delta Echo');
check('proximity ignores reverse', order('proximity', true), 'Alpha Bravo Charlie Delta Echo');

function call(fn, byZone) {
  lua.lua_getglobal(L, to_luastring(fn));
  lua.lua_pushboolean(L, byZone);
  if (lua.lua_pcall(L, 1, 1, 0) !== 0) return 'ERROR ' + to_jsstring(lua.lua_tostring(L, -1));
  const s = to_jsstring(lua.lua_tostring(L, -1));
  lua.lua_pop(L, 1);
  return s;
}

check('group by zone off: one Quests section', call('zoneSections', false),
  'DEFAULT=1.Alpha,2.Bravo,3.Charlie,4.Delta,5.Echo,6.Foxtrot');
// Zones A to Z ignoring case, entries keep the sort, numbering restarts per zone, unknown zone last.
check('group by zone on: a section per zone, unknown zone under Quests', call('zoneSections', true),
  'ZONE:Azj-Kahet=1.Delta ZONE:Dornogal=1.Alpha,2.Echo ZONE:hallowfall=1.Bravo,2.Charlie DEFAULT=1.Foxtrot');
check('group by zone on with no quests: no sections', call('noQuests', true), '');
check('group by zone: topic headers are not sections', call('topicHeaders', true),
  'ZONE:Voidstorm=1.Harvest of Darkness,2.The Time to Strike DEFAULT=1.Veteran Equipment');

console.log(failures ? failures + ' failed' : 'all passed');
process.exit(failures ? 1 : 0);
