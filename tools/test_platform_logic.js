#!/usr/bin/env node
/**
 * Executable checks for client detection in core/Platform.lua.
 *
 * Why this exists. Forever beta build 70170 (2026-10-01) moved Forever from
 * WOW_PROJECT_MAINLINE (1) to a project ID of its own (18). Detection required
 * Mainline, so the client came out "Unknown", the known-absent list stopped
 * applying, and Delves, Mythic+, housing and the vault all switched back on.
 * Nothing in game said so except /h platform. These checks pin each client's
 * real values to the answer it must get.
 *
 * Usage:
 *   npm install fengari     # one dependency, not vendored
 *   node tools/test_platform_logic.js
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
const PLATFORM = fs.readFileSync(REPO + 'core/Platform.lua', 'utf8').replace(/^﻿/, '');

// Classic constants as the clients define them; Forever has none.
const PROJECT_CONSTANTS = `
  WOW_PROJECT_MAINLINE = 1
  WOW_PROJECT_CLASSIC = 2
  WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5
  WOW_PROJECT_WRATH_CLASSIC = 11
  WOW_PROJECT_CATACLYSM_CLASSIC = 14
  WOW_PROJECT_MISTS_CLASSIC = 19
`;

let failures = 0;
function check(label, actual, expected) {
  if (actual === expected) {
    console.log('ok   ' + label);
  } else {
    failures++;
    console.log('FAIL ' + label + ': expected ' + expected + ', got ' + actual);
  }
}

// Load Platform.lua into a fresh state as a given client and return name,
// isForever and Has("delves").
function loadAs(projectID, interfaceVersion, extra) {
  const L = lauxlib.luaL_newstate();
  lualib.luaL_openlibs(L);
  const setup = `
    ${PROJECT_CONSTANTS}
    ${extra || ''}
    WOW_PROJECT_ID = ${projectID === null ? 'nil' : projectID}
    function GetBuildInfo() return "1.60.1", "70170", "Oct 1 2026", ${interfaceVersion} end
    C_DelvesUI = {}
    _G.HorizonSuite = {}
  `;
  const probe = `
    local P = _G.HorizonSuite.Platform
    return P.name .. "|" .. tostring(P.isForever) .. "|" .. tostring(P.isRetail) .. "|" .. tostring(P.Has("delves"))
  `;
  for (const [code, name] of [[setup, 'setup'], [PLATFORM, 'Platform.lua'], [probe, 'probe']]) {
    if (lauxlib.luaL_loadbuffer(L, to_luastring(code), null, to_luastring(name)) !== lua.LUA_OK
        || lua.lua_pcall(L, 0, 1, 0) !== lua.LUA_OK) {
      console.error(name + ': ' + to_jsstring(lua.lua_tostring(L, -1)));
      process.exit(1);
    }
  }
  const [clientName, isForever, isRetail, delves] = to_jsstring(lua.lua_tostring(L, -1)).split('|');
  return { clientName, isForever, isRetail, delves };
}

// Forever, build 70170: project 18, interface 16001. The regression.
let r = loadAs(18, 16001);
check('Forever 70170 (project 18) is Forever', r.clientName, 'Forever');
check('Forever 70170 has no delves', r.delves, 'false');

// Forever before 70170 still reported Mainline.
r = loadAs(1, 16001);
check('Forever pre-70170 (Mainline, 16001) is Forever', r.clientName, 'Forever');
check('Forever pre-70170 has no delves', r.delves, 'false');

// A named Forever constant wins even at a Retail-sized interface number.
r = loadAs(18, 160100, 'WOW_PROJECT_FOREVER = 18');
check('WOW_PROJECT_FOREVER constant is taken at its word', r.clientName, 'Forever');

// Retail / Midnight.
r = loadAs(1, 120100);
check('Retail (Mainline, 120100) is Retail', r.clientName, 'Retail');
check('Retail has delves', r.delves, 'true');
r = loadAs(null, 120100);
check('Retail with no WOW_PROJECT_ID is Retail', r.clientName, 'Retail');

// Classic flavours loaded out of date must never be read as Forever.
r = loadAs(2, 11507);
check('Classic Era (project 2) is not Forever', r.isForever, 'false');
r = loadAs(19, 50500);
check('Mists Classic (project 19) is not Forever', r.isForever, 'false');
check('Mists Classic is not Retail', r.isRetail, 'false');

if (failures > 0) {
  console.log(`\n${failures} check(s) failed`);
  process.exit(1);
}
console.log('\nall platform checks passed');
