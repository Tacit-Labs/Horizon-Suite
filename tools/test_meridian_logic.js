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

run(`
  function STUB_FRAME(parent)
    local o = { scripts = {}, shown = true, parent = parent, points = {}, alpha = 1 }
    local fixed = { GetFrameLevel = 1, GetWidth = 1000, GetHeight = 1080, GetEffectiveScale = 1,
                    IsMouseOver = false, GetStringWidth = 30 }
    return setmetatable(o, { __index = function(_, k)
      if k == "SetScript" then return function(self, n, fn) self.scripts[n] = fn end end
      if k == "Show" then return function(self) self.shown = true end end
      if k == "Hide" then return function(self) self.shown = false end end
      if k == "SetShown" then return function(self, v) self.shown = v and true or false end end
      if k == "IsShown" then return function(self) return self.shown end end
      if k == "SetAlpha" then return function(self, a) self.alpha = a end end
      if k == "SetText" then return function(self, t) self.text = t end end
      if k == "GetText" then return function(self) return self.text end end
      if k == "SetPoint" then return function(self, ...) self.points[#self.points + 1] = { ... } end end
      if k == "ClearAllPoints" then return function(self) self.points = {} end end
      if k == "GetNumPoints" then return function(self) return #self.points end end
      if k == "GetPoint" then return function(self, i)
        local p = self.points[i or 1]
        if p then return p[1], p[2], p[3], p[4], p[5] end
      end end
      if k == "SetParent" then return function(self, p) self.parent = p end end
      if k == "GetParent" then return function(self) return self.parent end end
      if k == "SetWidth" then return function(self, w) self.width = w end end
      if k == "SetSize" then return function(self, w, h) self.width, self.height = w, h end end
      if k == "GetSize" then return function(self) return self.width, self.height end end
      if k == "CreateTexture" or k == "CreateFontString" then return function(self) return STUB_FRAME(self) end end
      if fixed[k] ~= nil then local v = fixed[k]; return function() return v end end
      -- Unknown methods (capitalised) are no-ops; unknown data fields stay nil, as on a real frame.
      if type(k) == "string" and k:match("^%u") then return function() end end
      return nil
    end })
  end
  function STUB_CREATE_FRAME(_, name, parent)
    local f = STUB_FRAME(parent)
    if name then _G[name] = f end
    return f
  end
  CreateFrame = STUB_CREATE_FRAME
  UIParent = STUB_FRAME()
`, 'frame-stubs');

// Files in TOC order. Block files are not listed: block sections load them after a reset.
const FILES = [
  'modules/Meridian/MeridianRegistry.lua',
  'modules/Meridian/MeridianFormat.lua',
  'modules/Meridian/MeridianAutoHide.lua',
  'modules/Meridian/MeridianBar.lua',
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

// --- Bar -------------------------------------------------------------------------
run(`
  local M = HorizonSuite.Meridian
  local Bar = M.Bar

  local x = Bar.ComputeX({ left = { 20, 30 }, centre = { 40 }, right = { 20, 30 } }, 1000, 10, 12)
  check("x: left starts at the pad", x.left[1] == 10 and x.left[2] == 42, x.left[2])
  check("x: centre is centred", x.centre[1] == 480, x.centre[1])
  check("x: right ends at the pad", x.right[1] == 928 and x.right[2] == 960, x.right[1])
  x = Bar.ComputeX({ left = {}, centre = {}, right = {} }, 1000, 10, 12)
  check("x: empty sides", #x.left == 0 and #x.right == 0)

  M._ResetForTests()
  ATTACHED, DETACHED = 0, 0  -- globals: the next chunk reads them
  M.RegisterBlock({ id = "t1", text = function() return "abc" end, defaultSide = "left", defaultOrder = 1 })
  M.RegisterBlock({ id = "t2", text = function() return nil end, defaultSide = "right",
    Attach = function() ATTACHED = ATTACHED + 1 end, Detach = function() DETACHED = DETACHED + 1 end })
`, 'bar-setup');
run(read('options/modules/defaults/OptionsDefaultsMeridian.lua'), 'options/modules/defaults/OptionsDefaultsMeridian.lua');
run(`
  local M = HorizonSuite.Meridian
  local Bar = M.Bar
  check("defaults: a block row per registered block", HorizonSuite.MERIDIAN_DEFAULTS.meridianBlock_t1_side == "left")
  check("defaults: routing keys include block rows", HorizonSuite.MERIDIAN_KEYS.meridianBlock_t2_enabled == true)

  Bar.Enable()
  local frame = _G.HorizonSuiteMeridianBar
  check("enable: builds the named bar", frame ~= nil)
  check("enable: active, so it owns its blocks", M.Owns("t1") == true)
  local b1 = Bar._buttons.t1
  check("layout: a block with text is shown", b1 and b1.shown == true)
  check("layout: placed at the left pad", b1 and b1.points[1] and b1.points[1][4] == Bar.PAD, b1 and b1.points[1] and b1.points[1][4])
  local b2 = Bar._buttons.t2
  check("layout: a contextual block with no text is hidden", b2 and b2.shown == false)
  check("layout: Attach runs for an on block even while it is empty", ATTACHED >= 1, ATTACHED)

  DB.meridianBlock_t2_enabled = false
  Bar.Layout()
  check("layout: Detach runs once a block is switched off", DETACHED >= 1, DETACHED)
  DB.meridianBlock_t2_enabled = nil

  DB.meridianAutoHide = true
  Bar.ApplyOptions()
  Bar._driver.scripts.OnUpdate(Bar._driver, 2)
  check("auto-hide: the bar slides away with no hover", frame.shown == false)
  DB.meridianAutoHide = nil
  Bar.ApplyOptions()
  Bar._driver.scripts.OnUpdate(Bar._driver, 0.5)
  check("auto-hide off: the bar comes back", frame.shown == true)

  Bar.Disable()
  check("disable: no longer owns", M.Owns("t1") == false)
  check("disable: the bar is hidden", frame.shown == false)
  check("disable: blocks are detached", DETACHED >= 2, DETACHED)

  -- Disabling in combat defers the detach, and Vista's notification waits with it.
  HorizonSuite.Vista = { ApplyOptions = function() VISTA_CALLS = (VISTA_CALLS or 0) + 1 end }
  VISTA_CALLS = 0
  Bar.Enable()
  local vistaAfterEnable = VISTA_CALLS
  local detachedBefore = DETACHED
  COMBAT = true
  Bar.Disable()
  check("disable in combat: Vista is not told yet", VISTA_CALLS == vistaAfterEnable, VISTA_CALLS)
  check("disable in combat: detach waits for combat to end", DETACHED == detachedBefore, DETACHED)
  COMBAT = false
  Bar._driver.scripts.OnEvent(Bar._driver, "PLAYER_REGEN_ENABLED")
  check("disable in combat: detached once combat ends", DETACHED > detachedBefore, DETACHED)
  check("disable in combat: Vista is told once combat ends", VISTA_CALLS > vistaAfterEnable, VISTA_CALLS)
  check("disable in combat: no ownership notice left pending", not HorizonSuite.Meridian._ownershipPending)
  HorizonSuite.Vista = nil
  M._ResetForTests()
`, 'bar');

// --- Blocks ----------------------------------------------------------------------
run(`HorizonSuite.Meridian._ResetForTests(); DB = {}`, 'blocks-reset');
for (const f of [
  'modules/Meridian/blocks/MeridianBlocksTime.lua',
  'modules/Meridian/blocks/MeridianBlocksWorld.lua',
  'modules/Meridian/blocks/MeridianBlocksCharacter.lua',
  'modules/Meridian/blocks/MeridianBlocksNotices.lua',
  'modules/Meridian/blocks/MeridianBlocksActions.lua',
]) run(read(f), f);
run(`
  local M = HorizonSuite.Meridian
  for _, id in ipairs({ "horizon", "clock", "coords", "perf", "gold", "durability", "bags", "mail", "teleports" }) do
    check("blocks: " .. id .. " registered", M.Get(id) ~= nil)
  end
  check("blocks: clock defaults to the centre", M.BlockSide("clock") == "centre")
  check("blocks: teleports belongs to Vista", M.Get("teleports").module == "vista")

  date = function() return { hour = 21, min = 37 } end
  GetGameTime = function() return 20, 5 end
  DB.meridianClockLocal = true; DB.meridianClock24Hour = true
  check("clock: local 24-hour", M.Get("clock").text() == "21:37", M.Get("clock").text())
  DB.meridianClockLocal = false; DB.meridianClock24Hour = false
  check("clock: realm 12-hour", M.Get("clock").text() == "8:05 PM", M.Get("clock").text())
  GetGameTime = function() return nil end
  check("clock: no realm time yet gives nil", M.Get("clock").text() == nil)
  DB.meridianClockLocal = nil; DB.meridianClock24Hour = nil

  C_Map = { GetBestMapForUnit = function() return 2339 end,
            GetPlayerMapPosition = function() return { GetXY = function() return 0.452, 0.618 end } end }
  check("coords: from the map", M.Get("coords").text() == "45.2, 61.8", M.Get("coords").text())
  C_Map.GetBestMapForUnit = function() return nil end
  check("coords: no map gives nil", M.Get("coords").text() == nil)

  GetFramerate = function() return 61.7 end
  GetNetStats = function() return 0, 0, 22, 31 end
  check("perf: fps and world latency", M.Get("perf").text() == "61 / 31", M.Get("perf").text())

  GetMoney = function() return 123456789 end
  check("gold: whole gold", M.Get("gold").text() == "12,345", M.Get("gold").text())

  local dur = { [1] = { 50, 100 }, [5] = { 30, 40 } }
  GetInventoryItemDurability = function(slot) local d = dur[slot]; if d then return d[1], d[2] end end
  check("durability: lowest slot", M.Get("durability").text() == "50%", M.Get("durability").text())
  dur = {}
  check("durability: nothing equipped gives nil", M.Get("durability").text() == nil)

  NUM_BAG_SLOTS = 4
  C_Container = { GetContainerNumFreeSlots = function(bag)
    if bag == 0 then return 10, 0 end
    if bag == 1 then return 6, 0 end
    if bag == 2 then return 4, 8 end   -- a profession bag does not count
    return 0, 0
  end }
  check("bags: general free slots", M.Get("bags").text() == "16", M.Get("bags").text())

  HasNewMail = function() return true end
  check("mail: icon only while there is mail", M.Get("mail").text() == "")
  HasNewMail = function() return false end
  check("mail: nothing without mail", M.Get("mail").text() == nil)

  check("horizon: icon only", M.Get("horizon").text() == "")
  M._ResetForTests()
`, 'blocks');

// --- Queue -----------------------------------------------------------------------
run(`HorizonSuite.Meridian._ResetForTests(); DB = {}; ENABLED = {}`, 'queue-reset');
run(read('modules/Meridian/blocks/MeridianBlocksNotices.lua'), 'notices');
run(`
  local M = HorizonSuite.Meridian
  local hooks = {}
  hooksecurefunc = function(obj, name, fn) hooks[name] = fn end
  local home = STUB_FRAME()
  QueueStatusButton = STUB_FRAME(home)
  QueueStatusButton:SetPoint("BOTTOMLEFT", home, "BOTTOMLEFT", 5, 6)
  QueueStatusButton.shown = false

  local q = M.Get("queue")
  check("queue: registered", q ~= nil)
  check("queue: nothing while not queued", q.text() == nil)
  QueueStatusButton.shown = true
  check("queue: room for the eye while queued", q.text() == "")

  local host = STUB_FRAME()
  q.Attach(host)
  check("queue: attach reparents Blizzard's button", QueueStatusButton.parent == host)
  check("queue: attach centres it", QueueStatusButton.points[1][1] == "CENTER" and QueueStatusButton.points[1][2] == host)
  check("queue: attach hooks re-anchoring", hooks.SetPoint ~= nil)

  COMBAT = true
  q.Detach(host)
  check("queue: no release in combat", QueueStatusButton.parent == host)
  check("queue: still held after a combat-deferred release", HorizonSuite.Meridian.QueueHeld() == true)
  COMBAT = false
  q.Detach(host)
  check("queue: not held once released", HorizonSuite.Meridian.QueueHeld() == false)
  check("queue: release restores the parent with Vista off", QueueStatusButton.parent == home)
  check("queue: release restores the point", QueueStatusButton.points[1][1] == "BOTTOMLEFT" and QueueStatusButton.points[1][4] == 5)

  local reattached = 0
  HorizonSuite.Vista = { ReattachQueueButton = function() reattached = reattached + 1 end }
  ENABLED.vista = true
  q.Attach(host)
  q.Detach(host)
  check("queue: release hands back to Vista when it is on", reattached == 1, reattached)
  HorizonSuite.Vista = nil
  ENABLED.vista = nil
  hooksecurefunc = nil
  M._ResetForTests()
`, 'queue');

// --- Summary (keep last; add new sections above this line) -----------------------
run(`
  print(PASS .. " passed, " .. FAIL .. " failed")
  if FAIL > 0 then error("meridian logic tests failed") end
`, 'summary');
