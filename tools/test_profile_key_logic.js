#!/usr/bin/env node
/**
 * Executable checks for the character profile key in core/Core.lua
 * (GetCurrentCharacterProfileKey).
 *
 * Why this exists. WoW Forever started returning "" from GetRealmName and
 * GetNormalizedRealmName to stop addons steering layer hops. The key was
 * "Name-Realm" and came out nil without a realm, so the whole session ran on the
 * early-load profile: every setting read as default, modules came up off, and
 * nothing the player changed survived a reload. These checks pin how the key is
 * found again without a realm.
 *
 * Usage:
 *   npm install fengari     # one dependency, not vendored
 *   node tools/test_profile_key_logic.js
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
const CORE = fs.readFileSync(REPO + 'core/Core.lua', 'utf8').replace(/^﻿/, '');

// Only the key-resolution block; the rest of Core.lua needs the game's frames.
const start = CORE.indexOf('local _cachedCharKey = nil');
const end = CORE.indexOf('addon._GetCurrentCharacterProfileKey = GetCurrentCharacterProfileKey');
if (start < 0 || end < 0) {
  console.log('FAIL could not find GetCurrentCharacterProfileKey in core/Core.lua');
  process.exit(1);
}
const BLOCK = CORE.slice(start, end);

let failures = 0;
function check(label, actual, expected) {
  if (actual === expected) {
    console.log('ok   ' + label);
  } else {
    failures++;
    console.log('FAIL ' + label + ': expected ' + expected + ', got ' + actual);
  }
}

// Runs `setup`, the key block, then `body` (Lua returning a string) in a fresh state.
function run(setup, body) {
  const L = lauxlib.luaL_newstate();
  lualib.luaL_openlibs(L);
  const src = `
    addon = { DATABASE = "HorizonDB" }
    ${setup}
    ${BLOCK}
    local function key() return tostring(GetCurrentCharacterProfileKey()) end
    ${body}
  `;
  if (lauxlib.luaL_loadstring(L, to_luastring(src)) !== lua.LUA_OK ||
      lua.lua_pcall(L, 0, 1, 0) !== lua.LUA_OK) {
    return 'ERROR: ' + to_jsstring(lua.lua_tostring(L, -1));
  }
  return to_jsstring(lua.lua_tostring(L, -1));
}

const PLAYER = `
  function UnitName() return "Aria" end
  function UnitGUID() return "Player-1-0A" end
`;
const NO_REALM = `
  function GetNormalizedRealmName() return "" end
  function GetRealmName() return "" end
`;
const RESTORED = '\naddon._dbRestoredFromDisk = true\n';

check('realm present: Name-Realm',
  run(PLAYER + `function GetNormalizedRealmName() return "Silvermoon" end`, 'return key()'),
  'Aria-Silvermoon');

check('normalized realm empty, GetRealmName has it: uses GetRealmName',
  run(PLAYER + `function GetNormalizedRealmName() return "" end
                function GetRealmName() return "Argent Dawn" end`, 'return key()'),
  'Aria-ArgentDawn');

check('no realm before ADDON_LOADED: nil (retry later)',
  run(PLAYER + NO_REALM + 'HorizonDB = {}', 'return key()'),
  'nil');

check('no realm: finds the one saved key with this name',
  run(PLAYER + NO_REALM + RESTORED + `
    HorizonDB = { charProfileKeys = { ["Aria-Silvermoon"] = "Aria-Silvermoon", ["Bob-Silvermoon"] = "Main" } }`,
    'return key()'),
  'Aria-Silvermoon');

check('no realm: GUID on file wins over a name shared across realms',
  run(PLAYER + NO_REALM + RESTORED + `
    HorizonDB = {
      charProfileKeys = { ["Aria-Silvermoon"] = "A", ["Aria-Draenor"] = "B" },
      charGuids = { ["Player-1-0A"] = "Aria-Draenor" },
    }`, 'return key()'),
  'Aria-Draenor');

check('no realm: name on two realms, no GUID on file: bare name, not a guess',
  run(PLAYER + NO_REALM + RESTORED + `
    HorizonDB = { charProfileKeys = { ["Aria-Silvermoon"] = "A", ["Aria-Draenor"] = "B" } }`,
    'return key()'),
  'Aria');

check('no realm: brand-new character: bare name',
  run(PLAYER + NO_REALM + RESTORED + 'HorizonDB = { charProfileKeys = {} }', 'return key()'),
  'Aria');

check('no realm: "Arian-Realm" is not mistaken for "Aria"',
  run(PLAYER + NO_REALM + RESTORED + `
    HorizonDB = { charProfileKeys = { ["Arian-Silvermoon"] = "X" } }`, 'return key()'),
  'Aria');

check('records the GUID against the key',
  run(PLAYER + NO_REALM + RESTORED + `
    HorizonDB = { charProfileKeys = { ["Aria-Silvermoon"] = "Main" } }`,
    'key(); return tostring(HorizonDB.charGuids["Player-1-0A"])'),
  'Aria-Silvermoon');

check('realm back after realm-less sessions: profile choice carried over',
  run(PLAYER + `function GetNormalizedRealmName() return "Silvermoon" end` + RESTORED + `
    HorizonDB = { charProfileKeys = { ["Aria"] = "Main" }, charGuids = { ["Player-1-0A"] = "Aria" } }`,
    'key(); return tostring(HorizonDB.charProfileKeys["Aria-Silvermoon"])'),
  'Main');

check('secret realm treated as missing',
  run(PLAYER + RESTORED + `
    local SECRET = {}
    function issecretvalue(v) return v == SECRET end
    function GetNormalizedRealmName() return SECRET end
    function GetRealmName() return SECRET end
    HorizonDB = { charProfileKeys = { ["Aria-Silvermoon"] = "Main" } }`, 'return key()'),
  'Aria-Silvermoon');

check('key is stable for the session',
  run(PLAYER + NO_REALM + RESTORED + `
    HorizonDB = { charProfileKeys = { ["Aria-Silvermoon"] = "Main" } }`,
    'local a = key(); function GetNormalizedRealmName() return "Other" end; return a .. "|" .. key()'),
  'Aria-Silvermoon|Aria-Silvermoon');

console.log(failures === 0 ? '\nAll checks passed.' : `\n${failures} check(s) failed.`);
process.exit(failures === 0 ? 0 : 1);
