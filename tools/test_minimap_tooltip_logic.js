#!/usr/bin/env node
/**
 * Executable checks for the pure-logic half of Insight's minimap tooltip
 * spacing: colour-code handling, objective detection and where the blank
 * lines go.
 *
 * Why this exists. The minimap tooltip reaches the addon as one stack of text
 * with nothing marking where a node ends and a quest begins, so the sections
 * are guessed from the text. A wrong guess puts a gap in the middle of a
 * quest or splits a colour code across lines, and seeing every combination
 * in game means finding a node inside a quest area. The logic is pure, so it
 * runs in a plain Lua VM.
 *
 * Usage:
 *   npm install fengari     # one dependency, not vendored
 *   node tools/test_minimap_tooltip_logic.js
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

run(`_G.HorizonSuite = { GetDB = function(k, d) return d end }`, 'stubs');
run(read('modules/Insight/InsightMinimapTooltip.lua'), 'InsightMinimapTooltip');
run(`
  I = HorizonSuite.Insight
  -- Gap positions as "2,5" for a list of lines.
  function Gaps(lines)
    local gaps = I.FindMinimapSectionGaps(lines)
    local out = {}
    for i = 1, #lines do if gaps[i] then out[#out + 1] = tostring(i) end end
    return table.concat(out, ",")
  end
  function Split(text) return table.concat(I.SplitColouredTooltipText(text), "~") end
`, 'helpers');

let failures = 0;
function check(name, got, want) {
  if (String(got) === String(want)) {
    console.log('  ok   ' + name);
  } else {
    failures++;
    console.log('  FAIL ' + name + '\n         got:  ' + got + '\n         want: ' + want);
  }
}

const HINT = '"|cff20ff20Shift-click to plan a journey here|r"';

console.log('objective lines');
check('dash objective', evalStr('I.IsMinimapObjectiveLine("- 2/10 Gray Bear Tongue")'), 'true');
check('indented, coloured dash objective', evalStr('I.IsMinimapObjectiveLine("  |cffffffff- 0/1 Creeper Ichor|r")'), 'true');
check('bullet objective', evalStr('I.IsMinimapObjectiveLine("\\226\\128\\162 Slay 5 wolves")'), 'true');
check('node name is not', evalStr('I.IsMinimapObjectiveLine("Briarthorn")'), 'false');
check('quest title is not', evalStr('I.IsMinimapObjectiveLine("|cffffd100Elixir of Suffering|r")'), 'false');
check('dash inside a name is not', evalStr('I.IsMinimapObjectiveLine("Jin\'do the Hexxer - Boss")'), 'false');
check('nil is not', evalStr('I.IsMinimapObjectiveLine(nil)'), 'false');

console.log('where the gaps go');
check('the reported case: node, quest, objectives, hint',
  evalStr(`Gaps({ "Briarthorn", "Elixir of Suffering", "- 2/10 Gray Bear Tongue", "- 0/1 Creeper Ichor", ${HINT} })`), '2,5');
check('node on its own: no gaps', evalStr('Gaps({ "Briarthorn" })'), '');
check('two stacked nodes stay together', evalStr('Gaps({ "Briarthorn", "Copper Vein" })'), '');
check('quest first: no gap above the first line',
  evalStr('Gaps({ "Elixir of Suffering", "- 2/10 Gray Bear Tongue", "Briarthorn" })'), '3');
check('two quests back to back',
  evalStr('Gaps({ "Quest A", "- 1/2 Thing", "Quest B", "- 0/3 Other" })'), '3');
check('node between two quests',
  evalStr('Gaps({ "Quest A", "- 1/2 Thing", "Briarthorn", "Quest B", "- 0/3 Other" })'), '3,4');
check('objectives with no title above them', evalStr('Gaps({ "- 1/2 Thing", "Briarthorn" })'), '2');

console.log('splitting one multi-line string');
check('plain lines', evalStr('Split("Briarthorn\\nElixir of Suffering")'), 'Briarthorn~Elixir of Suffering');
check('closed colours stay put', evalStr('Split("|cffffd100Briarthorn|r\\n- 2/10 Tongue")'), '|cffffd100Briarthorn|r~- 2/10 Tongue');
check('an open colour carries to the next line',
  evalStr('Split("|cffffd100Briarthorn\\nElixir|r\\n- 2/10")'), '|cffffd100Briarthorn~|cffffd100Elixir|r~- 2/10');
check('the latest colour carries', evalStr('Split("|cffff0000a |cff00ff00b\\nc")'), '|cffff0000a |cff00ff00b~|cff00ff00c');
check('named colour codes carry', evalStr('Split("|cnNORMAL_FONT_COLOR:Title\\nNext|r")'), '|cnNORMAL_FONT_COLOR:Title~|cnNORMAL_FONT_COLOR:Next|r');
check('single line comes back whole', evalStr('#I.SplitColouredTooltipText("Briarthorn")'), '1');
check('nil gives nothing', evalStr('#I.SplitColouredTooltipText(nil)'), '0');

console.log('stripping colour codes');
check('strips and trims', evalStr('I.StripTooltipColourCodes("  |cffffffff- 0/1 Ichor|r ")'), '- 0/1 Ichor');

if (failures > 0) {
  console.log(`\n${failures} check(s) failed`);
  process.exit(1);
}
console.log('\nall checks passed');
