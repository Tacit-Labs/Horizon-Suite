#!/usr/bin/env node
/**
 * Executable checks for Augment Alerts' "Recipe learned" kind
 * (modules/Augment/Alerts/AugmentAlertsRecipe.lua and its wiring in
 * AugmentAlertsEvents.lua).
 *
 * Why this exists. The kind takes NEW_RECIPE_LEARNED away from Blizzard's
 * AlertFrame while it is on. Getting the hand-back wrong loses the Blizzard
 * toast for good (until /reload), and that only shows after a player turns the
 * kind or Alerts off again, so it is easy to miss in-game. "Train all" fires one
 * event per recipe; the batching that turns those into one toast is timing
 * logic that is hard to watch in-game. Both are checked here against stubs.
 *
 * Usage:
 *   NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_alerts_recipe_logic.js
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
const read = f => fs.readFileSync(REPO + f, 'utf8').replace(/^﻿/, '');

const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);

function run(code, name) {
  if (lauxlib.luaL_loadbuffer(L, to_luastring(code), null, to_luastring(name)) !== lua.LUA_OK
      || lua.lua_pcall(L, 0, 1, 0) !== lua.LUA_OK) {
    console.error(name + ': ' + to_jsstring(lua.lua_tostring(L, -1)));
    process.exit(1);
  }
  const out = lua.lua_isstring(L, -1) ? to_jsstring(lua.lua_tostring(L, -1)) : null;
  lua.lua_pop(L, 1);
  return out;
}

// --- Stub the slice of the WoW/addon environment the files touch -----------
run(`
  local db = {}
  _G.HorizonSuite = {
    AUGMENT_DEFAULTS = {}, AUGMENT_LIMITS = {},
    L = setmetatable({}, { __index = function(_, k) return k end }),
    Augment = { DB_KEYS = {} },
    Log = { registerTag = function() end },
    db = db,
    GetDB = function(k, d) local v = db[k]; if v == nil then return d end; return v end,
    IsModuleEnabled = function() return true end,
  }
  local L = _G.HorizonSuite.L
  rawset(L, "ALERTS_RECIPE_TITLE", "Recipe Learned")
  rawset(L, "ALERTS_RECIPE_MANY_TITLE", "%d Recipes Learned")
  rawset(L, "ALERTS_RECIPE_MANY_BODY", "%s and %d more.")
  rawset(L, "ALERTS_RECIPE_RANK_FORMAT", "%s (Rank %d)")

  -- Frames: event registration is all these files use.
  REJECT = {}  -- events RegisterEvent throws on, as an unknown event does in game
  local function NewFrame()
    local f = { events = {} }
    function f:RegisterEvent(e)
      if REJECT[e] then error("Attempt to register unknown event \\"" .. e .. "\\"") end
      self.events[e] = true
    end
    function f:UnregisterEvent(e) self.events[e] = nil end
    function f:UnregisterAllEvents() self.events = {} end
    function f:IsEventRegistered(e) return self.events[e] == true end
    function f:SetScript(_, fn) self.onEvent = fn end
    return f
  end
  FRAMES = {}
  CreateFrame = function() local f = NewFrame(); FRAMES[#FRAMES + 1] = f; return f end
  AlertFrame = NewFrame()
  AlertFrame.events.NEW_RECIPE_LEARNED = true

  -- Timers fire only when the test says time has passed.
  TIMERS = {}
  C_Timer = {
    After = function(_, fn) fn() end,
    NewTimer = function(_, fn)
      local t = { fn = fn }
      function t:Cancel() self.cancelled = true end
      TIMERS[#TIMERS + 1] = t
      return t
    end,
  }
  function ElapseTimers()
    local list = TIMERS
    TIMERS = {}
    for _, t in ipairs(list) do if not t.cancelled then t.fn() end end
  end
  InCombatLockdown = function() return false end
  GetTime = function() return 0 end

  RECIPES = {
    [100] = { name = "Tempered Potion", icon = 1001 },
    [101] = { name = "Algari Mana Oil", icon = 1002 },
    [102] = { name = "Flask of Alchemical Chaos", icon = 1003 },
  }
  C_TradeSkillUI = {
    GetRecipeInfo = function(id) return RECIPES[id] end,
    GetTradeSkillLineForRecipe = function(id) if RECIPES[id] or id == 200 then return 2871, "Khaz Algar Alchemy", 171 end end,
    GetTradeSkillTexture = function(id) return id == 171 and 4620669 or nil end,
  }
  C_Spell = {
    GetSpellInfo = function(id) if id == 200 then return { name = "Spell-only Recipe", iconID = 2002 } end end,
  }
`, 'stubs');

for (const f of [
  'modules/Augment/Alerts/AugmentAlertsState.lua',
  'modules/Augment/Alerts/AugmentAlertsQueue.lua',
  'modules/Augment/Alerts/AugmentAlertsEvents.lua',
  'modules/Augment/Alerts/AugmentAlertsRecipe.lua',
]) run(read(f), f);

run(`
  A = HorizonSuite.Augment.Alerts
  SHOWN = {}
  A.ShowToast = function(kind, title, body, meta)
    SHOWN[#SHOWN + 1] = { kind = kind, title = title, body = body, icon = meta and meta.icon }
  end
  A.TakeAllBaselines = function() end
  EV = FRAMES[#FRAMES]  -- the Alerts event frame
  function Fire(...) EV.onEvent(EV, "NEW_RECIPE_LEARNED", ...) end
  function Reset()
    SHOWN = {}
    TIMERS = {}
    A.Recipe.Reset()
  end
`, 'harness');

let PASS = 0;
let FAIL = 0;
function check(name, lua_expr) {
  const got = run(`return tostring(${lua_expr})`, name);
  if (got === 'true') PASS++;
  else { FAIL++; console.log('  FAIL: ' + name); }
}
function eq(name, lua_expr, want) {
  const got = run(`return tostring(${lua_expr})`, name);
  if (got === String(want)) PASS++;
  else { FAIL++; console.log('  FAIL: ' + name + '  want: ' + want + '  got: ' + got); }
}

// --- Registration hand-off -----------------------------------------------
run('HorizonSuite.db.alertsRecipeEnabled = true; A.UpdateEventRegistrations()', 'off-update');
check('Alerts off: options toggle registers nothing', 'EV.events.NEW_RECIPE_LEARNED == nil');
check('Alerts off: Blizzard keeps its toast', 'AlertFrame.events.NEW_RECIPE_LEARNED == true');

run('A.EnableEvents()', 'enable');
check('kind on: Alerts listens for the event', 'EV.events.NEW_RECIPE_LEARNED == true');
check('kind on: AlertFrame no longer gets the event', 'AlertFrame.events.NEW_RECIPE_LEARNED == nil');

run('HorizonSuite.db.alertsRecipeEnabled = false; A.UpdateEventRegistrations()', 'kind-off');
check('kind off: Alerts stops listening', 'EV.events.NEW_RECIPE_LEARNED == nil');
check('kind off: AlertFrame gets the event back', 'AlertFrame.events.NEW_RECIPE_LEARNED == true');

run('HorizonSuite.db.alertsRecipeEnabled = true; A.UpdateEventRegistrations()', 'kind-on-again');
check('kind on again: AlertFrame loses it again', 'AlertFrame.events.NEW_RECIPE_LEARNED == nil');
run('A.DisableEvents()', 'disable');
check('Alerts off: AlertFrame gets the event back', 'AlertFrame.events.NEW_RECIPE_LEARNED == true');

// A client whose AlertFrame never had the event: restore must not add it.
run('AlertFrame.events.NEW_RECIPE_LEARNED = nil; A.EnableEvents(); A.DisableEvents()', 'no-blizzard-reg');
check('restore never registers an event Blizzard had not', 'AlertFrame.events.NEW_RECIPE_LEARNED == nil');

// A client that rejects the event (Forever without it): Blizzard keeps its toast.
run('AlertFrame.events.NEW_RECIPE_LEARNED = true; REJECT.NEW_RECIPE_LEARNED = true; A.EnableEvents()', 'reject');
check('event rejected: AlertFrame keeps the event', 'AlertFrame.events.NEW_RECIPE_LEARNED == true');
run('A.DisableEvents(); REJECT.NEW_RECIPE_LEARNED = nil; A.EnableEvents()', 're-enable');

// --- Toasts --------------------------------------------------------------
run('Reset(); Fire(100); ElapseTimers()', 'single');
eq('one recipe: one toast', '#SHOWN', 1);
eq('one recipe: kind', 'SHOWN[1].kind', 'RECIPE');
eq('one recipe: title', 'SHOWN[1].title', 'Recipe Learned');
eq('one recipe: body is the recipe name', 'SHOWN[1].body', 'Tempered Potion');
eq('one recipe: recipe icon', 'SHOWN[1].icon', 1001);

run('Reset(); Fire(100, 3); ElapseTimers()', 'rank');
eq('recipeLevel adds the rank', 'SHOWN[1].body', 'Tempered Potion (Rank 3)');

run('Reset(); Fire(200); ElapseTimers()', 'spell-fallback');
eq('falls back to C_Spell for the name', 'SHOWN[1].body', 'Spell-only Recipe');
eq('falls back to C_Spell for the icon', 'SHOWN[1].icon', 2002);

run('Reset(); Fire(999); ElapseTimers()', 'unknown');
eq('a recipe with no name shows nothing', '#SHOWN', 0);

run('Reset(); Fire(100); Fire(101); Fire(102)', 'burst');
eq('Train all: nothing shown inside the window', '#SHOWN', 0);
run('ElapseTimers()', 'burst-flush');
eq('Train all: one toast', '#SHOWN', 1);
eq('Train all: count in the title', 'SHOWN[1].title', '3 Recipes Learned');
eq('Train all: first name and the rest counted', 'SHOWN[1].body', 'Tempered Potion and 2 more.');
eq('Train all: profession icon', 'SHOWN[1].icon', 4620669);

run('Reset(); Fire(100); ElapseTimers(); Fire(101); ElapseTimers()', 'two-windows');
eq('separate windows: separate toasts', '#SHOWN', 2);

run('Reset(); Fire(100); HorizonSuite.db.alertsRecipeEnabled = false; A.UpdateEventRegistrations(); ElapseTimers()', 'off-mid-batch');
eq('turned off mid-batch: the batch is dropped', '#SHOWN', 0);
run('Fire(100); ElapseTimers()', 'off-event');
eq('kind off: a stray event shows nothing', '#SHOWN', 0);

console.log(`\n${PASS} passed, ${FAIL} failed`);
process.exit(FAIL ? 1 : 0);
