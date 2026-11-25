#!/usr/bin/env node
/**
 * Executable checks for the pure-logic half of Augment's flight tracker:
 * learned times, estimates, stop placement and time formatting.
 *
 * Why this exists. Learning a flight time needs a real flight, and getting the
 * arithmetic wrong (deriving a leg from a multi-hop route, mixing an exact
 * route time with estimated legs) would show a confident wrong countdown. The
 * logic is pure, so it runs in a plain Lua VM with the WoW globals stubbed.
 *
 * Usage:
 *   npm install fengari     # one dependency, not vendored
 *   node tools/test_flight_logic.js
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

function evalStr(expr) {
  run(`__out = tostring(${expr})`, 'eval');
  lua.lua_getglobal(L, to_luastring('__out'));
  const s = to_jsstring(lua.lua_tostring(L, -1));
  lua.lua_pop(L, 1);
  return s;
}

const REPO = path.resolve(__dirname, '..') + '/';
const read = f => fs.readFileSync(REPO + f, 'utf8').replace(/^﻿/, '');

run(`
  _G.HorizonSuite = {
    Augment = { DB_KEYS = {} },
    AUGMENT_DEFAULTS = {}, AUGMENT_LIMITS = {},
    L = setmetatable({}, { __index = function(_, k) return k end }),
    GetDB = function(k, d) return d end,
  }
`, 'stubs');
run(read('options/modules/defaults/augment/OptionsDefaultsAugmentFlightTracker.lua'), 'defaults');
run(read('modules/Augment/FlightTracker/AugmentFlightState.lua'), 'FlightState');
run(`F = HorizonSuite.Augment.Flight`, 'alias');

let failures = 0;
function check(name, got, want) {
  if (String(got) === String(want)) {
    console.log('  ok   ' + name);
  } else {
    failures++;
    console.log('  FAIL ' + name + '\n         got:  ' + got + '\n         want: ' + want);
  }
}

// Three nodes on a straight line, 300 and 600 yards apart.
const RESET = `
  F.BindStore({})
  A = { id = 1, name = "Alpha, Zone", x = 0,   y = 0 }
  B = { id = 2, name = "Bravo, Zone", x = 300, y = 0 }
  C = { id = 3, name = "Charlie",     x = 900, y = 0 }
  direct = { nodes = { A, C } }
  multi  = { nodes = { A, B, C } }
`;

console.log('formatting');
run(RESET, 'reset');
check('ShortName drops the zone', evalStr('F.ShortName("Ironforge, Dun Morogh")'), 'Ironforge');
check('ShortName keeps a plain name', evalStr('F.ShortName("Charlie")'), 'Charlie');
check('ShortName of nil is empty', evalStr('F.ShortName(nil)'), '');
check('FormatTime under a minute', evalStr('F.FormatTime(7)'), '0:07');
check('FormatTime minutes', evalStr('F.FormatTime(125.4)'), '2:05');
check('FormatTime hours', evalStr('F.FormatTime(3725)'), '1:02:05');
check('FormatTime negative clamps', evalStr('F.FormatTime(-3)'), '0:00');

console.log('estimates before anything is learned');
run(RESET, 'reset');
check('direct route is an estimate', evalStr('F.Estimate(direct).exact'), 'false');
check('direct total = yards / fallback pace',
  evalStr('math.floor(F.Estimate(direct).total + 0.5)'), String(Math.round(900 / 26)));
check('multi-hop stop sits by distance', evalStr('string.format("%.4f", F.Estimate(multi).stops[1])'), (300 / 900).toFixed(4));
check('no positions: no total', evalStr('F.Estimate({ nodes = { {id=7}, {id=8} } }).total'), 'nil');
check('no positions: stops spaced evenly',
  evalStr('string.format("%.4f", F.Estimate({ nodes = { {id=7}, {id=8}, {id=9}, {id=10} } }).stops[2])'), (2 / 3).toFixed(4));

console.log('learning');
run(RESET, 'reset');
check('too-short flight is not learned', evalStr('F.Learn(direct, 3)'), 'false');
check('direct flight is learned', evalStr('F.Learn(direct, 60.4)'), 'true');
check('learned route is exact', evalStr('F.Estimate(direct).exact'), 'true');
check('learned route total', evalStr('F.Estimate(direct).total'), '60');
check('direct flight also stores the leg', evalStr('HorizonSuite.Augment.Flight.Store().legs["1>3"]'), '60');
check('pace becomes measured', evalStr('string.format("%.4f", F.Pace())'), (900 / 60).toFixed(4));

run(RESET, 'reset');
run('F.Learn({ nodes = { A, B } }, 30)', 'learn AB');
check('one leg known, one estimated: not exact', evalStr('F.Estimate(multi).exact'), 'false');
run('F.Learn(multi, 75)', 'learn ABC');
check('missing leg derived from the remainder', evalStr('F.Store().legs["2>3"]'), '45');
check('multi-hop now exact', evalStr('F.Estimate(multi).exact'), 'true');
check('stop placed by learned legs', evalStr('string.format("%.4f", F.Estimate(multi).stops[1])'), (30 / 75).toFixed(4));

run(RESET, 'reset');
run('F.Learn(multi, 75)', 'learn ABC cold');
check('two unknown legs: nothing derived', evalStr('F.Store().legs["1>2"]'), 'nil');
check('whole route still exact', evalStr('F.Estimate(multi).total'), '75');

run('F.ForgetLearned()', 'forget');
check('forget clears routes', evalStr('F.Estimate(multi).exact'), 'false');

console.log('progress');
run(RESET, 'reset');
check('halfway', evalStr('select(1, F.Progress({ total = 100 }, 50))'), '0.5');
check('time left', evalStr('select(3, F.Progress({ total = 100 }, 30))'), '70');
check('overrun is due', evalStr('select(2, F.Progress({ total = 100 }, 120))'), 'due');
check('no total counts up', evalStr('select(2, F.Progress({}, 12))'), 'elapsed');
check('no total reports elapsed', evalStr('select(3, F.Progress({}, 12))'), '12');

if (failures) {
  console.log(`\n${failures} check(s) failed`);
  process.exit(1);
}
console.log('\nall flight checks passed');
