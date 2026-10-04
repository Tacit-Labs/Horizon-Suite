#!/usr/bin/env node
/**
 * Loads every real module options file through the real page assembler and checks
 * the pages that come out.
 *
 * Why this exists. test_options_logic.js proves the assembler's rules on small
 * hand-written categories. This file proves the real options files obey them: every
 * section is tagged, nothing is left as a columns block, no warning fires, and each
 * module's sidebar shows the pages we expect, in order. A mistagged section there
 * moves or hides settings with nothing worse than a red line in chat.
 *
 * Each client runs in its own fresh Lua state with permissive stubs: locale strings
 * return their key, GetDB returns the default, and an addon field nobody stubbed reads
 * as nil and is listed at the end. No frames are built.
 *
 * Usage:
 *   npm install --prefix "$HOME/.cache/hs-test" fengari   # once, outside the repo
 *   NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_modules.js
 *
 * Not wired into CI: the Luacheck workflow is a Lua parse gate with no node step.
 */

const fs = require('fs');
const path = require('path');

let fengari;
try {
  fengari = require('fengari');
} catch (e) {
  console.log('SKIP: fengari not installed. See the usage note at the top of this file.');
  process.exit(0);
}
const { lua, lauxlib, lualib, to_luastring, to_jsstring } = fengari;

const REPO = path.resolve(__dirname, '..') + '/';
const read = f => fs.readFileSync(REPO + f, 'utf8').replace(/^﻿/, '');

// Module files that load earlier in the TOC and that the options files call into.
const PREREQS = [
  'modules/Echo/EchoOptions.lua',  // Echo.TierKey / Echo.FeedKey name Echo's settings
];

// The options files in HorizonSuite.toc order, from the helpers through the search index.
const FILES = [
  'options/OptionsHelpers.lua',
  'options/OptionsPages.lua',
  'options/modules/defaults/augment/OptionsDefaultsAugmentLootFrame.lua',
  'options/modules/defaults/augment/OptionsDefaultsAugmentSelfHighlight.lua',
  'options/modules/defaults/augment/OptionsDefaultsAugmentAutoVendor.lua',
  'options/modules/defaults/augment/OptionsDefaultsAugmentTalkingHead.lua',
  'options/modules/defaults/augment/OptionsDefaultsAugmentAchievementTracker.lua',
  'options/modules/defaults/augment/OptionsDefaultsAugmentAlerts.lua',
  'options/modules/defaults/augment/OptionsDefaultsAugmentLootRoll.lua',
  'options/modules/defaults/OptionsDefaultsAugment.lua',
  'options/modules/defaults/OptionsDefaultsPresence.lua',
  'options/modules/defaults/OptionsDefaultsInsight.lua',
  'options/modules/defaults/OptionsDefaultsEssence.lua',
  'options/modules/defaults/OptionsDefaultsEcho.lua',
  'options/modules/defaults/OptionsDefaultsVista.lua',
  'options/modules/defaults/OptionsDefaultsFocus.lua',
  'options/modules/defaults/OptionsDefaultsAxis.lua',
  'options/modules/OptionsAxis.lua',
  'options/modules/OptionsGlobal.lua',
  'options/modules/OptionsFocus.lua',
  'options/modules/OptionsPresence.lua',
  'options/modules/OptionsInsight.lua',
  'options/modules/OptionsEssence.lua',
  'options/modules/OptionsEcho.lua',
  'options/modules/OptionsVista.lua',
  'options/modules/OptionsAugment.lua',
  'options/modules/OptionsAugmentTalkingHead.lua',
  'options/modules/OptionsAugmentAlerts.lua',
  'options/modules/OptionsAugmentLootRoll.lua',
  'options/modules/OptionsFocusIntegrations.lua',
  'options/OptionsAssemble.lua',
  'options/OptionsPlatform.lua',  // prunes rows whose `requires` capability is absent
  'options/OptionsSearch.lua',    // builds the search index over the assembled pages
];

// Each module's page keys, in sidebar order, on a client with every capability.
const EXPECTED = {
  axis: ['axis:general', 'axis:layout', 'GlobalToggles', 'Profiles'],
  focus: ['focus:general', 'focus:layout', 'focus:look', 'focus:tracked', 'focus:instances',
    'focus:integrations'],
  vista: ['vista:general', 'vista:layout', 'vista:look', 'vista:buttons'],
  insight: ['insight:general', 'insight:layout', 'insight:look', 'insight:players',
    'insight:npcsItems'],
  presence: ['presence:general', 'presence:layout', 'presence:look', 'presence:notifications'],
  echo: ['echo:general', 'echo:layout', 'echo:look', 'echo:feeds'],
  essence: ['essence:general', 'essence:layout'],
  augment: ['augment:loot', 'augment:alerts', 'augment:lootRoll', 'augment:talkingHead',
    'augment:vendor', 'augment:selfHighlight', 'augment:achievementTracker'],
};

// Forever's off-list, read from core/Platform.lua so this test follows it.
function foreverAbsent() {
  const src = read('core/Platform.lua');
  const m = src.match(/local ABSENT_ON_FOREVER = \{([\s\S]*?)\n\}/);
  if (!m) throw new Error('ABSENT_ON_FOREVER not found in core/Platform.lua');
  return [...m[1].matchAll(/^\s*(\w+)\s*=\s*true/gm)].map(x => x[1]);
}

let PASS = 0;
let FAIL = 0;
function check(name, ok, got) {
  if (ok) PASS++;
  else { FAIL++; console.log('  FAIL: ' + name + '  got: ' + got); }
}

// The fixed list must match the TOC slice, or a new options file would go untested.
{
  const toc = read('HorizonSuite.toc').split(/\r?\n/).map(s => s.trim());
  const from = toc.indexOf(FILES[0]);
  const to = toc.indexOf(FILES[FILES.length - 1]);
  const slice = from >= 0 && to >= from ? toc.slice(from, to + 1).filter(s => s && !s.startsWith('#')) : [];
  check('file list matches HorizonSuite.toc', JSON.stringify(slice) === JSON.stringify(FILES),
    JSON.stringify(slice));
}

// Load every file in a fresh Lua state with `capsOff` capabilities absent, and return
// what the assembler produced.
function assemble(capsOff) {
  const L = lauxlib.luaL_newstate();
  lualib.luaL_openlibs(L);
  const run = (code, name) => {
    if (lauxlib.luaL_loadbuffer(L, to_luastring(code), null, to_luastring(name)) !== lua.LUA_OK
        || lua.lua_pcall(L, 0, 1, 0) !== lua.LUA_OK) {
      throw new Error(name + ': ' + to_jsstring(lua.lua_tostring(L, -1)));
    }
    const out = lua.lua_isstring(L, -1) ? to_jsstring(lua.lua_tostring(L, -1)) : null;
    lua.lua_pop(L, 1);
    return out;
  };

  run(`
    CAPS_OFF = {}
    for k in ("${capsOff.join(',')}"):gmatch("[^,]+") do CAPS_OFF[k] = true end
    HorizonDB = {}
    print = function() end  -- the assembler prints each warning; they are read from A.warnings
    local real = {
      DATABASE = "HorizonDB",
      L = setmetatable({}, { __index = function(_, k) return k end }),
      GetDB = function(_, d) return d end,
      OptionsData_GetDB = function(_, d) return d end,
      OptionsData_SetDB = function() end,
      OptionsData_NotifyMainAddon = function() end,
      Platform = { Has = function(k) return not CAPS_OFF[k] end },
      GetModuleDisplayName = function(k) return k end,
      OptionCategories = {},
      SPACING_PRESETS = setmetatable({}, { __index = function() return {} end }),
      GROUP_ORDER_PRESETS = {},
      FOCUS_STRATA_ORDER = { "BACKGROUND", "LOW", "MEDIUM", "HIGH" },
      SECTION_LABELS = {}, QUEST_COLORS = {}, HEADER_COLOR = { 1, 1, 1 },
    }
    MISSING = {}
    _G.HorizonSuite = setmetatable(real, { __index = function(_, k) MISSING[k] = true; return nil end })
    C_AddOns = { IsAddOnLoaded = function() return false end }
    IsAddOnLoaded = function() return false end
    NUM_BAG_SLOTS = 4  -- read by a desc function the search index resolves
  `, 'stub');
  for (const f of PREREQS.concat(FILES)) run(read(f), f);

  const json = run(`
    local addon = HorizonSuite
    local A = addon.OptionsAssemble
    local function q(s) return '"' .. tostring(s):gsub('[%c"\\\\]', " ") .. '"' end
    local function list(t) local o = {} for i, v in ipairs(t) do o[i] = q(v) end return "[" .. table.concat(o, ",") .. "]" end
    local pages, untagged, columns, cards, survivors = {}, {}, {}, {}, {}
    for _, cat in ipairs(addon.OptionCategories) do
      local mk = cat.moduleKey or "axis"
      pages[mk] = pages[mk] or {}
      pages[mk][#pages[mk] + 1] = cat.key
      if not cat.pageKey then untagged[#untagged + 1] = tostring(cat.key) end
      local ok, opts = pcall(function()
        if type(cat.options) == "function" then return cat.options() end
        return cat.options
      end)
      if not ok then
        columns[#columns + 1] = tostring(cat.key) .. " (builder failed: " .. tostring(opts) .. ")"
      else
        -- Each card as "<name>#<settings>", where settings counts rows that are not the
        -- card header, a More row, or the zero-height talkingHeadPreview proxy (marked "+proxy").
        local shape, cur = {}, nil
        for _, r in ipairs(opts or {}) do
          if type(r) == "table" and r.type == "columns" then columns[#columns + 1] = tostring(cat.key) end
          if type(r) == "table" and r.requires and CAPS_OFF[r.requires] then
            survivors[#survivors + 1] = tostring(cat.key) .. " › " .. tostring(r.dbKey or r.name or r.type) .. " (" .. r.requires .. ")"
          end
          if type(r) == "table" and r.type == "section" then
            cur = { name = tostring(r.name), n = 0, proxy = false }
            shape[#shape + 1] = cur
          elseif type(r) == "table" and cur and r.type == "talkingHeadPreview" then
            cur.proxy = true
          elseif type(r) == "table" and cur and r.type ~= "moreToggle" then
            cur.n = cur.n + 1
          end
        end
        local parts = {}
        for i, c in ipairs(shape) do parts[i] = q(c.name .. "#" .. c.n .. (c.proxy and "+proxy" or "")) end
        cards[#cards + 1] = q(cat.key) .. ":[" .. table.concat(parts, ",") .. "]"
      end
    end
    -- Search results with no name to show (the dashboard shows name, searchName or labelText).
    local blank = {}
    local okIdx, idx = pcall(OptionsData_BuildSearchIndex)
    if not okIdx then blank[1] = "index failed: " .. tostring(idx) end
    for _, e in ipairs(okIdx and idx or {}) do
      local o = e.option
      local n = o.name or o.searchName or o.labelText
      if type(n) == "function" then n = n() end
      if not n or n == "" then blank[#blank + 1] = tostring(e.categoryKey) .. " › " .. tostring(o.type) end
    end
    local mods = {}
    for mk, keys in pairs(pages) do mods[#mods + 1] = q(mk) .. ":" .. list(keys) end
    local missing = {}
    for k in pairs(MISSING) do missing[#missing + 1] = k end
    table.sort(missing)
    return "{" .. table.concat({
      '"warnings":' .. list(A and A.warnings or { "OptionsAssemble did not load" }),
      '"untagged":' .. list(untagged),
      '"columns":' .. list(columns),
      '"survivors":' .. list(survivors),
      '"blank":' .. list(blank),
      '"cards":{' .. table.concat(cards, ",") .. "}",
      '"pages":{' .. table.concat(mods, ",") .. "}",
      '"missing":' .. list(missing),
    }, ",") .. "}"
  `, 'collect');
  return JSON.parse(json);
}

function common(label, r) {
  check(label + ': no assembler warnings', r.warnings.length === 0, r.warnings.length);
  for (const w of r.warnings) console.log('    warning: ' + w);
  check(label + ': every category came from the assembler', r.untagged.length === 0,
    r.untagged.join(', '));
  check(label + ': no page contains a columns row', r.columns.length === 0, r.columns.join(', '));
  check(label + ': no row survives whose capability is absent', r.survivors.length === 0,
    r.survivors.join(', '));
  check(label + ': every search result has a name', r.blank.length === 0, r.blank.join(', '));
  // A card holding nothing but the zero-height preview proxy looks empty on screen.
  const empty = [];
  for (const [key, list] of Object.entries(r.cards)) {
    for (const c of list) if (/#0\+proxy$/.test(c)) empty.push(key + ' › ' + c);
  }
  check(label + ': no card holds only the preview proxy', empty.length === 0, empty.join(', '));
  const th = r.cards['augment:talkingHead'] || [];
  check(label + ': Talking Head opens on a card with settings', th.length > 0 && !/#0(\+proxy)?$/.test(th[0]),
    th.join(', '));
  check(label + ': Talking Head keeps its preview proxy', th.some(c => c.endsWith('+proxy')), th.join(', '));
  if (label === 'Retail') console.log('  (Retail augment:talkingHead cards: ' + th.join(', ') + ')');
  if (r.missing.length) console.log('  (' + label + ' read unstubbed addon fields: ' + r.missing.join(', ') + ')');
}

// --- Retail: every capability present ---------------------------------------------
{
  const r = assemble([]);
  common('Retail', r);
  for (const [mk, want] of Object.entries(EXPECTED)) {
    const got = r.pages[mk] || [];
    check('Retail: ' + mk + ' pages', JSON.stringify(got) === JSON.stringify(want), got.join(', '));
  }
  const extra = Object.keys(r.pages).filter(mk => !EXPECTED[mk]);
  check('Retail: no unexpected module', extra.length === 0, extra.join(', '));
}

// --- Forever: the off-list from core/Platform.lua ---------------------------------
const FOREVER_OFF = foreverAbsent();
console.log('  (Forever off-list: ' + FOREVER_OFF.join(', ') + ')');
{
  const r = assemble(FOREVER_OFF);
  common('Forever', r);
  const has = (r.pages.augment || []).includes('augment:lootRoll');
  const want = !FOREVER_OFF.includes('groupLootRolls');
  check('Forever: augment:lootRoll shown exactly when groupLootRolls is present', has === want,
    has ? 'present' : 'absent');
}

// --- Forever with no group loot: the Loot Roll page drops out ---------------------
{
  const r = assemble([...new Set([...FOREVER_OFF, 'groupLootRolls'])]);
  common('Forever, no group loot', r);
  const has = (r.pages.augment || []).includes('augment:lootRoll');
  check('Forever, no group loot: augment:lootRoll absent', !has, 'present');
}

// --- Summary -----------------------------------------------------------------------
console.log(PASS + ' passed, ' + FAIL + ' failed');
if (FAIL > 0) process.exit(1);
