#!/usr/bin/env node
/**
 * Executable checks for the options page assembler and the search index.
 *
 * Why this exists. The assembler decides which page and card every setting lands on,
 * when a dependent setting shows, and what sits behind a card's More fold. A mistake
 * there hides settings from players without any error, so the rules run here in a
 * plain Lua VM with the WoW globals stubbed. No frames are built.
 *
 * Usage:
 *   npm install --prefix "$HOME/.cache/hs-test" fengari   # once, outside the repo
 *   NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_logic.js
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

// --- Stub the slice of the addon the options files touch -----------------------
run(`
  HorizonDB = {}
  DB_VALUES = {}
  REAL_PRINT = print
  PRINTED = {}
  print = function(s) PRINTED[#PRINTED + 1] = tostring(s) end

  _G.HorizonSuite = {
    DATABASE = "HorizonDB",
    L = setmetatable({}, { __index = function(_, k) return k end }),
    GetDB = function(k, d) local v = DB_VALUES[k]; if v == nil then return d end; return v end,
    Platform = { caps = {}, Has = function(k) return _G.HorizonSuite.Platform.caps[k] ~= false end },
    BrandModule = function(k) return k end,
    Dashboard_IsAxisCategoryKey = function(k)
      return k == "Modules" or k == "Profiles" or k == "GlobalToggles"
        or (type(k) == "string" and k:sub(1, 5) == "axis:")
    end,
  }
  -- Categories as the modules registered them; the in-place rewrite must leave these alone.
  SEED_LIST = {
    { key = "SeedStatic", name = "Static", options = { { type = "section", name = "S" } } },
    { key = "SeedFn", name = "Fn", options = function() return { { type = "section", name = "F" } } end },
    { key = "SeedBoom", name = "Boom", moduleKey = "boomer", options = function() error("boom") end },
  }
  SEED_ITEMS = { SEED_LIST[1], SEED_LIST[2], SEED_LIST[3] }
  _G.HorizonSuite.OptionCategories = SEED_LIST

  local L = HorizonSuite.L
  L["DASH_NEEDS_PARENT"] = "Turn on %s to use this."

  PASS, FAIL = 0, 0
  function check(name, ok, got)
    if ok then PASS = PASS + 1
    else FAIL = FAIL + 1; REAL_PRINT("  FAIL: " .. name .. "  got: " .. tostring(got)) end
  end

  -- A toggle row reading DB_VALUES[key].
  function ROW(key, extra)
    local r = { type = "toggle", name = key, dbKey = key, get = function() return DB_VALUES[key] end }
    for k, v in pairs(extra or {}) do r[k] = v end
    return r
  end
  function SEC(name, extra)
    local s = { type = "section", name = name }
    for k, v in pairs(extra or {}) do s[k] = v end
    return s
  end
  -- Compact picture of an option list: "S:<section>|<row>|M:<count>|...".
  function SHAPE(list)
    local parts = {}
    for _, r in ipairs(list or {}) do
      if r.type == "section" then parts[#parts + 1] = "S:" .. tostring(r.name)
      elseif r.type == "moreToggle" then parts[#parts + 1] = "M:" .. tostring(r.count)
      else parts[#parts + 1] = tostring(r.dbKey or r.name) end
    end
    return table.concat(parts, "|")
  end
  function PAGES(cats, mk)
    local out = {}
    for _, c in ipairs(cats) do if c.moduleKey == mk then out[#out + 1] = c.key end end
    return table.concat(out, ",")
  end
  function OPTS(cat) if type(cat.options) == "function" then return cat.options() end return cat.options end
  function FIND(cats, key) for _, c in ipairs(cats) do if c.key == key then return c end end end
  function WARNED(fragment)
    for _, w in ipairs(HorizonSuite.OptionsAssemble and HorizonSuite.OptionsAssemble.warnings or {}) do
      if w:find(fragment, 1, true) then return true end
    end
    return false
  end
  -- Fresh registry, warnings, store and DB values between test blocks.
  function RESET()
    HorizonSuite.OptionsPages.modules = {}
    if HorizonSuite.OptionsAssemble then HorizonSuite.OptionsAssemble.ResetWarnings() end
    HorizonDB = {}
    DB_VALUES = {}
  end
`, 'stubs');

// Load order matches HorizonSuite.toc. Files that are missing yet are skipped so the
// harness can grow task by task.
for (const f of ['options/OptionsPages.lua', 'options/OptionsAssemble.lua', 'options/OptionsSearch.lua']) {
  if (fs.existsSync(REPO + f)) run(read(f), f);
}

// --- Assembler: no-op on untagged categories, guarded builders --------------------------
run(`
  local A = HorizonSuite.OptionsAssemble
  check("load keeps the same list object", rawequal(HorizonSuite.OptionCategories, SEED_LIST), "different table")
  check("load keeps the count", #SEED_LIST == 3, #SEED_LIST)
  for i = 1, 3 do
    check("load keeps entry " .. i, rawequal(SEED_LIST[i], SEED_ITEMS[i]), tostring(SEED_LIST[i] and SEED_LIST[i].key))
  end
  check("erroring builder warns at load", WARNED("options builder failed"), "no warning")
  check("warning names the category", WARNED("boomer > SeedBoom") or WARNED("SeedBoom"), "no name")
  HorizonSuite.OptionCategories = nil

  -- A source that builds once, then errors, must not stop the page building from the others.
  RESET()
  HorizonSuite.RegisterModulePages("fragile", { { key = "x", name = "X" } })
  local calls = 0
  local out = A.Run({
    { key = "Flaky", moduleKey = "fragile", options = function()
        calls = calls + 1
        if calls > 1 then error("late boom") end
        return { SEC("Fonts", { page = "look", card = "text" }), ROW("a1") }
      end },
    { key = "Steady", moduleKey = "fragile", options = { SEC("More fonts", { page = "look", card = "text" }), ROW("b1") } },
  })
  local look = FIND(out, "fragile:look")
  check("page survives a failing source", look ~= nil, "no page")
  local ok, shape = pcall(function() return SHAPE(OPTS(look)) end)
  check("page build does not error", ok, shape)
  check("other source rows still show", ok and shape == "S:CARD_TEXT|b1", shape)
  check("failing source warns", WARNED("options builder failed"), "no warning")
`, 'guarded-builders');

// --- Vocabulary ------------------------------------------------------------------
run(`
  local P = HorizonSuite.OptionsPages
  check("shared pages in order", table.concat(P.SHARED, ",") == "general,layout,look", table.concat(P.SHARED, ","))
  check("layout cards in order", table.concat(P.SHARED_CARDS.layout, ",") == "position,size", table.concat(P.SHARED_CARDS.layout, ","))
  check("look cards in order", table.concat(P.SHARED_CARDS.look, ",") == "text,colours,background,animation", table.concat(P.SHARED_CARDS.look, ","))
  check("general is shared", P.IsShared("general") == true, P.IsShared("general"))
  check("module page is not shared", P.IsShared("tracked") == false, P.IsShared("tracked"))
  check("size is a layout card", P.IsSharedCard("layout", "size") == true, "false")
  check("size is not a look card", P.IsSharedCard("look", "size") == false, "true")
  check("page name is localised", P.Name("look") == "PAGE_LOOK", P.Name("look"))
  check("card name is localised", P.Name("background") == "CARD_BACKGROUND", P.Name("background"))

  P.modules = {}
  HorizonSuite.RegisterModulePages("focus", { { key = "tracked", name = "T" }, { key = "instances", name = "I" } })
  HorizonSuite.RegisterModulePages("focus", { { key = "integrations", name = "X" }, { key = "tracked", name = "T2" } })
  check("module page order is registration order", table.concat(P.modules.focus.order, ",") == "tracked,instances,integrations", table.concat(P.modules.focus.order, ","))
  check("re-registering replaces the def", P.modules.focus.defs.tracked.name == "T2", P.modules.focus.defs.tracked.name)
  HorizonSuite.RegisterModulePages("focus", { { key = "general", desc = "d" } })
  check("shared page def adds fields only", P.modules.focus.defs.general.desc == "d" and #P.modules.focus.order == 3, #P.modules.focus.order)
  P.modules = {}
`, 'vocabulary');

// --- Assembler: pages, cards, merging ---------------------------------------------
run(`
  local A = HorizonSuite.OptionsAssemble
  RESET()
  HorizonSuite.RegisterModulePages("focus", { { key = "tracked", name = "What's tracked" } })
  local cats = {
    { key = "Old1", name = "Old one", moduleKey = "focus", options = {
        SEC("Fonts", { page = "look", card = "text" }), ROW("fontA"),
        SEC("Spacing", { page = "layout", card = "size" }), ROW("gap"),
        SEC("Where", { page = "layout", card = "position" }), ROW("lock"),
    } },
    { key = "Untagged", name = "Untagged", moduleKey = "vista", options = { SEC("V"), ROW("v1") } },
    { key = "Old2", name = "Old two", moduleKey = "focus", options = function() return {
        SEC("Sizes", { page = "look", card = "text" }), ROW("fontSize"),
        SEC("Quests", { page = "tracked" }), ROW("q1"),
        SEC("Width", { page = "layout", card = "size" }), ROW("width"),
    } end },
  }
  local out = A.Run(cats)
  check("pages: shared first, then own, empty dropped", PAGES(out, "focus") == "focus:layout,focus:look,focus:tracked", PAGES(out, "focus"))
  check("untagged category passes through after the module block", out[4] and out[4].key == "Untagged", out[4] and out[4].key)
  check("input list untouched", #cats == 3 and cats[1].key == "Old1", #cats)
  local layout = FIND(out, "focus:layout")
  check("cards: shared order, merged across categories", SHAPE(OPTS(layout)) == "S:CARD_POSITION|lock|S:CARD_SIZE|gap|width", SHAPE(OPTS(layout)))
  check("text card merges two sections", SHAPE(OPTS(FIND(out, "focus:look"))) == "S:CARD_TEXT|fontA|fontSize", SHAPE(OPTS(FIND(out, "focus:look"))))
  check("module page keeps section name", SHAPE(OPTS(FIND(out, "focus:tracked"))) == "S:Quests|q1", SHAPE(OPTS(FIND(out, "focus:tracked"))))
  check("shared page name", layout.name == "PAGE_LAYOUT", layout.name)
  check("module page name", FIND(out, "focus:tracked").name == "What's tracked", FIND(out, "focus:tracked").name)
  check("page keeps moduleKey", layout.moduleKey == "focus", layout.moduleKey)
  check("page options are lazy", type(layout.options) == "function", type(layout.options))
  check("section carries card id", OPTS(layout)[1].cardId == "focus:layout:position", OPTS(layout)[1].cardId)
  check("rows are copies", OPTS(layout)[2] ~= cats[1].options[6], "same table")

  -- Legacy keys, page fields and card names.
  RESET()
  HorizonSuite.RegisterModulePages("axis", {
    { key = "general", legacyKey = "Modules" },
    { key = "profiles", name = "Profiles", legacyKey = "Profiles", desc = "d", cardNames = { share = "Sharing" } },
  })
  local out2 = A.Run({
    { key = "Modules", name = "Modules", options = { SEC("Toggles", { page = "general", card = "modules" }), ROW("m1") } },
    { key = "Profiles", name = "Profiles", options = { SEC("P", { page = "profiles" }), ROW("p1"), SEC("S", { page = "profiles", card = "share" }), ROW("s1") } },
  })
  check("legacy keys kept, nil moduleKey kept", PAGES(out2, nil) == "Modules,Profiles", PAGES(out2, nil))
  check("page field copied", FIND(out2, "Profiles").desc == "d", FIND(out2, "Profiles").desc)
  check("module card keeps its name", SHAPE(OPTS(FIND(out2, "Modules"))) == "S:Toggles|m1", SHAPE(OPTS(FIND(out2, "Modules"))))
  check("cardNames renames a module card", SHAPE(OPTS(FIND(out2, "Profiles"))) == "S:P|p1|S:Sharing|s1", SHAPE(OPTS(FIND(out2, "Profiles"))))

  -- allowEmpty keeps a page that has only its on/off switch.
  RESET()
  HorizonSuite.RegisterModulePages("augment", {
    { key = "loot", name = "Loot" },
    { key = "tracker", name = "Tracker", allowEmpty = true, enabledKey = "trackerOn" },
  })
  local out3 = A.Run({ { key = "AugmentImprovements", moduleKey = "augment", options = {
    SEC("Toasts", { page = "loot" }),
    { type = "columns",
      left = { options = { ROW("a1"), { type = "section", name = "Stacking" }, ROW("a2") } },
      right = { options = { ROW("b1") } } },
    ROW("after"),
  } } })
  check("allowEmpty page emitted", PAGES(out3, "augment") == "augment:loot,augment:tracker", PAGES(out3, "augment"))
  check("allowEmpty page has no rows", SHAPE(OPTS(FIND(out3, "augment:tracker"))) == "", SHAPE(OPTS(FIND(out3, "augment:tracker"))))
  check("page field on empty page", FIND(out3, "augment:tracker").enabledKey == "trackerOn", FIND(out3, "augment:tracker").enabledKey)
  check("columns unwrap into cards", SHAPE(OPTS(FIND(out3, "augment:loot"))) == "S:Toasts|a1|b1|after|S:Stacking|a2", SHAPE(OPTS(FIND(out3, "augment:loot"))))
`, 'assembler-pages');

// --- Assembler: load-time checks ----------------------------------------------------
run(`
  local A = HorizonSuite.OptionsAssemble
  RESET()
  local out = A.Run({ { key = "C", moduleKey = "vista", options = {
    ROW("early"),
    SEC("Typo", { page = "nope" }), ROW("x1"),
    SEC("NoCard", { page = "layout" }), ROW("x2"),
    SEC("Ok", { page = "layout", card = "size" }), ROW("ok"),
    SEC("Toggle1", { page = "look", card = "text", headerToggle = { dbKey = "t1" } }), ROW("t1row"),
    SEC("Toggle2", { page = "look", card = "text", headerToggle = { dbKey = "t2" } }), ROW("t2row"),
    SEC("M+", { page = "general", card = "behaviour", requires = "mythicPlus" }), ROW("mplus"),
  } } })
  check("row before first section warns", WARNED("before the first section"), "no warning")
  check("unknown page warns", WARNED("unknown page 'nope'"), "no warning")
  check("shared page without card warns", WARNED("has no card tag"), "no warning")
  check("bad sections skipped", SHAPE(OPTS(FIND(out, "vista:layout"))) == "S:CARD_SIZE|ok", SHAPE(OPTS(FIND(out, "vista:layout"))))
  check("first header switch kept", SHAPE(OPTS(FIND(out, "vista:look"))) == "S:CARD_TEXT|t1row", SHAPE(OPTS(FIND(out, "vista:look"))))
  -- Card merging happens when a page is built, so this warning follows the OPTS call above.
  check("second header switch in a card warns", WARNED("Toggle2"), "no warning")
  check("header switch survives on a single-section card", OPTS(FIND(out, "vista:look"))[1].headerToggle ~= nil, "nil")
  check("warnings printed to chat", #PRINTED > 0, #PRINTED)
  local before = #A.warnings
  OPTS(FIND(out, "vista:layout"))
  check("warnings are not repeated", #A.warnings == before, #A.warnings)

  HorizonSuite.Platform.caps.mythicPlus = false
  RESET()
  local out2 = A.Run({ { key = "C", moduleKey = "vista", options = {
    SEC("M+", { page = "general", card = "behaviour", requires = "mythicPlus" }), ROW("mplus"),
    SEC("Ok", { page = "layout", card = "size" }), ROW("ok"),
  } } })
  check("section missing its capability is dropped with its page", PAGES(out2, "vista") == "vista:layout", PAGES(out2, "vista"))
  HorizonSuite.Platform.caps.mythicPlus = nil

  RESET()
  local wasStrict = A.strict
  A.strict = true
  A.Run({ { key = "Loose", moduleKey = "echo", options = { SEC("A"), ROW("a") } } })
  check("strict mode warns on untagged categories", WARNED("Loose"), "no warning")
  A.strict = wasStrict
`, 'assembler-checks');

// --- Card state store -----------------------------------------------------------------
run(`
  local A = HorizonSuite.OptionsAssemble
  RESET()
  check("first card opens by default", A.IsCardExpanded("m:p:a", true) == true, "false")
  check("other cards start closed", A.IsCardExpanded("m:p:b", false) == false, "true")
  A.SetCardExpanded("m:p:a", false)
  A.SetCardExpanded("m:p:b", true)
  check("remembered closed wins over first", A.IsCardExpanded("m:p:a", true) == false, "true")
  check("remembered open wins", A.IsCardExpanded("m:p:b", false) == true, "false")
  check("state saved in the database", HorizonDB.optionsCardExpanded["m:p:b"] == true, "nil")
  check("More starts closed", A.IsMoreOpen("m:p:a") == false, "true")
  A.SetMoreOpen("m:p:a", true)
  check("More remembered", A.IsMoreOpen("m:p:a") == true and HorizonDB.optionsCardMoreOpen["m:p:a"] == true, "false")
`, 'card-store');

// --- Dependent rows -------------------------------------------------------------------
run(`
  local A = HorizonSuite.OptionsAssemble
  RESET()
  DB_VALUES = { dyn = true, preset = "custom" }
  local src = { key = "L", moduleKey = "focus", options = {
    SEC("Size", { page = "layout", card = "size" }),
    ROW("dyn"),
    ROW("maxW", { parent = "dyn" }),
    ROW("fixedW", { parent = "dyn", parentIs = false }),
    ROW("both", { parent = "dyn", visibleWhen = function() return false end }),
    ROW("preset"),
    ROW("gapA", { parent = "preset", parentIs = "custom" }),
    ROW("gapB", { parent = "preset", parentIs = function(v) return v == "custom" or v == "spaced" end }),
    ROW("orphan", { parent = "missing" }),
  } }
  local out = A.Run({ src })
  local by = {}
  for _, r in ipairs(OPTS(out[1])) do if r.dbKey then by[r.dbKey] = r end end
  check("child of an on toggle shows", by.maxW.visibleWhen() == true, "false")
  check("child is indented", by.maxW.indent == true, by.maxW.indent)
  check("parentIs false hides while the parent is on", by.fixedW.visibleWhen() == false, "true")
  check("own visibleWhen still applies", by.both.visibleWhen() == false, "true")
  check("parent refreshes its children", table.concat(by.dyn.refreshIds or {}, ",") == "maxW,fixedW,both", table.concat(by.dyn.refreshIds or {}, ","))
  check("tooltip names the parent", by.maxW.tooltip == "Turn on dyn to use this.", by.maxW.tooltip)
  DB_VALUES.dyn = false
  check("child hides when the parent is off", by.maxW.visibleWhen() == false, "true")
  check("child disabled when the parent is off", by.maxW.disabled() == true, "false")
  check("parentIs false shows when the parent is off", by.fixedW.visibleWhen() == true, "false")
  check("value match shows", by.gapA.visibleWhen() == true, "false")
  DB_VALUES.preset = "spaced"
  check("value mismatch hides", by.gapA.visibleWhen() == false, "true")
  check("function predicate", by.gapB.visibleWhen() == true, "false")
  check("missing parent warns", WARNED("orphan"), "no warning")
  A.revealId = "maxW"
  check("search reveal shows a hidden child", by.maxW.visibleWhen() == true, "false")
  A.revealId = nil
  check("source rows untouched", src.options[3].visibleWhen == nil and src.options[2].refreshIds == nil, "mutated")
`, 'dependent-rows');

// --- More fold ------------------------------------------------------------------------
run(`
  local A = HorizonSuite.OptionsAssemble
  RESET()
  local out = A.Run({ { key = "L", moduleKey = "focus", options = {
    SEC("Size", { page = "layout", card = "size" }),
    ROW("a"), ROW("adv1", { advanced = true }), ROW("b"), ROW("adv2", { advanced = true }),
    SEC("Where", { page = "layout", card = "position" }), ROW("lock"),
  } } })
  local rows = OPTS(out[1])
  check("advanced rows follow a More row", SHAPE(rows) == "S:CARD_POSITION|lock|S:CARD_SIZE|a|b|M:2|adv1|adv2", SHAPE(rows))
  local more, adv1
  for _, r in ipairs(rows) do
    if r.type == "moreToggle" then more = r end
    if r.dbKey == "adv1" then adv1 = r end
  end
  check("More row knows its card", more.cardId == "focus:layout:size", more.cardId)
  check("advanced row hidden while More is closed", adv1.visibleWhen() == false, "true")
  A.SetMoreOpen("focus:layout:size", true)
  check("advanced row shows when More opens", adv1.visibleWhen() == true, "false")
  A.SetMoreOpen("focus:layout:size", false)
  A.revealId = "adv1"
  check("search reveal shows an advanced row", adv1.visibleWhen() == true, "false")
  A.revealId = nil
`, 'more-fold');

// --- Summary -----------------------------------------------------------------------
run(`
  REAL_PRINT(PASS .. " passed, " .. FAIL .. " failed")
  if FAIL > 0 then error("options logic tests failed") end
`, 'summary');
