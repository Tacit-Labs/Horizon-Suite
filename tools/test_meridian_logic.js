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
const read = f => fs.readFileSync(REPO + f, 'utf8').replace(/^\uFEFF/, '');

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
  'modules/Meridian/MeridianFormat.lua',
  'modules/Meridian/MeridianAutoHide.lua',
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

// --- Format ------------------------------------------------------------------------
run(`
  local F = HorizonSuite.Meridian.Format
  check("clock: 24-hour pads", F.Clock(9, 5, true) == "09:05", F.Clock(9, 5, true))
  check("clock: 12-hour afternoon", F.Clock(21, 37, false) == "9:37 PM", F.Clock(21, 37, false))
  check("clock: 12-hour midnight is 12 AM", F.Clock(0, 0, false) == "12:00 AM", F.Clock(0, 0, false))
  check("clock: 12-hour noon is 12 PM", F.Clock(12, 1, false) == "12:01 PM", F.Clock(12, 1, false))

  check("coords: one decimal", F.Coords(0.452, 0.618, 1) == "45.2, 61.8", F.Coords(0.452, 0.618, 1))
  check("coords: none", F.Coords(0.452, 0.618, 0) == "45, 62", F.Coords(0.452, 0.618, 0))
  check("coords: two", F.Coords(0.45219, 0.61844, 2) == "45.22, 61.84", F.Coords(0.45219, 0.61844, 2))
  check("coords: unknown precision means one", F.Coords(0.5, 0.5, 7) == "50.0, 50.0", F.Coords(0.5, 0.5, 7))
  check("coords: missing gives nil", F.Coords(nil, 0.5, 1) == nil)
  check("coords: 0,0 (inside an instance) gives nil", F.Coords(0, 0, 1) == nil)

  check("perf: whole numbers", F.Perf(59.8, 28.4) == "59 / 28", F.Perf(59.8, 28.4))
  check("perf: missing values are 0", F.Perf(nil, nil) == "0 / 0", F.Perf(nil, nil))

  check("thousands: small", F.Thousands(999) == "999", F.Thousands(999))
  check("thousands: exact group", F.Thousands(1000) == "1,000", F.Thousands(1000))
  check("thousands: millions", F.Thousands(1234567) == "1,234,567", F.Thousands(1234567))
  check("thousands: negative", F.Thousands(-12345) == "-12,345", F.Thousands(-12345))

  check("gold: whole gold only", F.Gold(123456789) == "12,345", F.Gold(123456789))
  check("gold delta: gain", F.GoldDelta(12340000) == "+1,234g", F.GoldDelta(12340000))
  check("gold delta: loss", F.GoldDelta(-120000) == "-12g", F.GoldDelta(-120000))
  check("gold delta: under a gold is 0g", F.GoldDelta(9999) == "0g", F.GoldDelta(9999))

  check("durability: lowest slot", F.LowestDurability({ { 50, 100 }, { 35, 40 }, { 10, 80 } }) == 13,
    F.LowestDurability({ { 50, 100 }, { 35, 40 }, { 10, 80 } }))
  check("durability: slots without durability are skipped", F.LowestDurability({ { nil, nil }, { 40, 40 } }) == 100)
  check("durability: nothing to measure gives nil", F.LowestDurability({ { nil, nil } }) == nil)
  check("percent", F.Percent(87.4) == "87%", F.Percent(87.4))
`, 'format');

// --- Auto-hide ---------------------------------------------------------------------
run(`
  local A = HorizonSuite.Meridian.AutoHide
  local function inp(t)
    return { autoHide = t.autoHide ~= false, keepOutOfCombat = t.keep or false, inCombat = t.combat or false,
             hovering = t.hover or false, combatMode = t.mode or "show", fadeAlpha = 0.3 }
  end

  local s = A.New(true)
  local p = A.Step(s, 1, inp({ autoHide = false }))
  check("off: always out", p == 1, p)

  s = A.New(true)
  p = A.Step(s, 1.0, inp({}))
  check("on: stays out before the hide delay", p == 1, p)
  p = A.Step(s, 0.6, inp({}))
  check("on: starts sliding after the delay", p < 1, p)
  p = A.Step(s, 1, inp({}))
  check("on: fully away", p == 0, p)

  p = A.Step(s, 0.05, inp({ hover = true }))
  check("hover: slides back in", p > 0 and p < 1, p)
  p = A.Step(s, 1, inp({ hover = true }))
  check("hover: fully out", p == 1, p)
  p = A.Step(s, 1.4, inp({}))
  check("leave: waits the delay again", p == 1, p)

  s = A.New(false)
  p = A.Step(s, 1, inp({ keep = true }))
  check("keep shown out of combat: out while not fighting", p == 1, p)
  p = A.Step(s, 1, inp({ keep = true, combat = true }))
  p = A.Step(s, 1, inp({ keep = true, combat = true }))
  check("keep shown out of combat: still hides in combat", p == 0, p)

  s = A.New(true)
  local _, alpha = A.Step(s, 0.01, inp({ autoHide = false, combat = true, mode = "fade" }))
  check("fade: combat alpha", alpha == 0.3, alpha)
  _, alpha = A.Step(s, 0.01, inp({ autoHide = false, combat = true, mode = "fade", hover = true }))
  check("fade: hover restores full alpha", alpha == 1, alpha)
  p = A.Step(s, 1, inp({ autoHide = false, combat = true, mode = "hide", hover = true }))
  check("hide: gone in combat, hover included", p == 0, p)
  p = A.Step(s, 1, inp({ autoHide = false, mode = "hide" }))
  check("hide: back after combat", p == 1, p)

  check("zone: top edge", A.CursorInZone("top", 1078, 1080, 4) == true)
  check("zone: below the top zone", A.CursorInZone("top", 1070, 1080, 4) == false)
  check("zone: bottom edge", A.CursorInZone("bottom", 3, 1080, 4) == true)
  check("zone: no cursor", A.CursorInZone("top", nil, 1080, 4) == false)
`, 'autohide');

// --- Summary (keep last; add new sections above this line) -----------------------
run(`
  print(PASS .. " passed, " .. FAIL .. " failed")
  if FAIL > 0 then error("meridian logic tests failed") end
`, 'summary');
