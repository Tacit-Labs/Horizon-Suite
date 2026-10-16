#!/usr/bin/env node
/**
 * Executable checks for the Meridian info bar (modules/Meridian/).
 *
 * Usage:
 *   NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_meridian_logic.js
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

run(`
  DB, ENABLED, COMBAT = {}, {}, false
  _G.HorizonSuite = {
    L = setmetatable({}, { __index = function(_, k) return k end }),
    GetDB = function(k, d) if DB[k] ~= nil then return DB[k] end return d end,
    SetDB = function(k, v) DB[k] = v end,
    IsModuleEnabled = function(self, k) return ENABLED[k] == true end,
    Platform = { caps = { mythicPlus = true, weeklyVault = true },
                 Has = function(k) return _G.HorizonSuite.Platform.caps[k] == true end },
  }
  C_Timer = { After = function(_, fn) fn() end, NewTimer = function() return { Cancel = function() end } end }
  InCombatLockdown = function() return COMBAT == true end

  PASS, FAIL = 0, 0
  function check(name, ok, got)
    if ok then PASS = PASS + 1
    else FAIL = FAIL + 1; print("  FAIL: " .. name .. "  got: " .. tostring(got)) end
  end
`, 'stubs');

// Files in TOC order. Block files are not listed: block sections load them after a reset.
const FILES = [
  'modules/Meridian/MeridianRegistry.lua',
];
for (const f of FILES) run(read(f), f);

// --- Registry --------------------------------------------------------------------
run(`
  local M = HorizonSuite.Meridian
  M._ResetForTests()
  local function T(v) return function() return v end end

  check("register: rejects a def without an id", M.RegisterBlock({ text = T("x") }) == false)
  check("register: rejects a def without text", M.RegisterBlock({ id = "a" }) == false)
  check("register: accepts a minimal def", M.RegisterBlock({ id = "a", text = T("A") }) == true)
  check("register: rejects a duplicate id", M.RegisterBlock({ id = "a", text = T("B") }) == false)
  check("register: keeps the first def", M.Get("a").text() == "A")

  local a = M.Get("a")
  check("defaults: side falls back to right", a.defaultSide == "right", a.defaultSide)
  check("defaults: order falls back to 100", a.defaultOrder == 100, a.defaultOrder)
  check("defaults: a block is on unless it says otherwise", M.IsBlockOn("a") == true)
  check("key: per-block keys", M.Key("a", "side") == "meridianBlock_a_side", M.Key("a", "side"))

  DB.meridianBlock_a_enabled = false
  check("setting: enabled false turns a block off", M.IsBlockOn("a") == false)
  DB.meridianBlock_a_enabled = nil
  DB.meridianBlock_a_side = "middle"
  check("setting: an unknown side falls back to the default", M.BlockSide("a") == "right", M.BlockSide("a"))
  DB.meridianBlock_a_side = "centre"
  check("setting: a saved side wins", M.BlockSide("a") == "centre", M.BlockSide("a"))
  DB.meridianBlock_a_side = nil

  M.RegisterBlock({ id = "b", text = T("B"), defaultSide = "left", defaultOrder = 20 })
  M.RegisterBlock({ id = "c", text = T("C"), defaultSide = "left", defaultOrder = 10 })
  local left = M.Layout("left")
  check("layout: a side is sorted by order", #left == 2 and left[1].id == "c" and left[2].id == "b", #left)
  DB.meridianBlock_b_order = 5
  left = M.Layout("left")
  check("layout: a saved order wins", left[1].id == "b", left[1] and left[1].id)
  DB.meridianBlock_b_order = nil
  M.RegisterBlock({ id = "d", text = T("D"), defaultSide = "left", defaultOrder = 10 })
  left = M.Layout("left")
  check("layout: equal orders fall back to id", left[1].id == "c" and left[2].id == "d", left[1].id .. left[2].id)
  DB.meridianBlock_c_enabled = false
  check("layout: an off block is left out", #M.Layout("left") == 2)
  DB.meridianBlock_c_enabled = nil

  M.RegisterBlock({ id = "f", text = T("F"), module = "focus" })
  ENABLED.focus = false
  check("gate: an off module hides its block", M.IsAvailable("f") == false)
  ENABLED.focus = true
  check("gate: the module coming on shows it, with no re-registration", M.IsAvailable("f") == true)
  M.RegisterBlock({ id = "k", text = T("K"), requires = "mythicPlus" })
  HorizonSuite.Platform.caps.mythicPlus = false
  check("gate: a missing capability hides the block", M.IsAvailable("k") == false)
  HorizonSuite.Platform.caps.mythicPlus = true
  check("gate: a present capability shows it", M.IsAvailable("k") == true)

  M._active = false
  check("owns: false while the bar is not active", M.Owns("a") == false)
  M._active = true
  check("owns: true for an on, available block", M.Owns("a") == true)
  DB.meridianBlock_a_enabled = false
  check("owns: false for an off block", M.Owns("a") == false)
  DB.meridianBlock_a_enabled = nil
  ENABLED.focus = false
  check("owns: false for a block whose module is off", M.Owns("f") == false)
  check("owns: false for an unknown id", M.Owns("nope") == false)
  M._active = false

  M.RegisterBlock({ id = "boom", text = function() error("bad") end })
  check("safe text: an error shows the failed marker", M.SafeText(M.Get("boom")) == M.FAILED_TEXT)
  M.RegisterBlock({ id = "none", text = T(nil) })
  check("safe text: nil stays nil (contextual)", M.SafeText(M.Get("none")) == nil)
  M.RegisterBlock({ id = "num", text = T(5) })
  check("safe text: a number becomes a string", M.SafeText(M.Get("num")) == "5")

  local calls = 0
  M.OnBlocksChanged = function() calls = calls + 1 end
  M.RegisterBlock({ id = "late", text = T("L") })
  check("hook: registering tells the bar", calls == 1, calls)
  M.OnBlocksChanged = nil

  local r, g, b = M.Accent()
  check("accent: the brand colour without class tint", r == M.BRAND[1] and g == M.BRAND[2] and b == M.BRAND[3], r)
  HorizonSuite.GetModuleClassColor = function(k) if k == "meridian" then return { 0.1, 0.2, 0.3 } end end
  r = M.Accent()
  check("accent: the class colour when tint is on", r == 0.1, r)
  HorizonSuite.GetModuleClassColor = nil

  check("glyph: a media path", M.Glyph("clock"):find("media\\\\meridian\\\\clock.tga", 1, true) ~= nil, M.Glyph("clock"))

  M._ResetForTests()
`, 'registry');

// --- Summary (keep last; add new sections above this line) -----------------------
run(`
  print(PASS .. " passed, " .. FAIL .. " failed")
  if FAIL > 0 then error("meridian logic tests failed") end
`, 'summary');
