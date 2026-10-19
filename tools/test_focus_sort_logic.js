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

console.log(failures ? failures + ' failed' : 'all passed');
process.exit(failures ? 1 : 0);
