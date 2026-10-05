#!/usr/bin/env node
/**
 * Executable checks for the options page assembler and the search index.
 *
 * Why this exists. The assembler decides which page and card every setting lands on,
 * when a dependent setting shows, and which subheadings a card shows. A mistake
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
  L["DASH_NEEDS_PARENT"] = "Depends on %s."

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
  -- Compact picture of an option list: "S:<section>|H:<subheading>|<row>|...".
  function SHAPE(list)
    local parts = {}
    for _, r in ipairs(list or {}) do
      if r.type == "section" then parts[#parts + 1] = "S:" .. tostring(r.name)
      elseif r.type == "header" then parts[#parts + 1] = "H:" .. tostring(r.name)
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
for (const f of ['options/OptionsHelpers.lua', 'options/OptionsPages.lua', 'options/OptionsAssemble.lua', 'options/OptionsSearch.lua']) {
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
  check("text card merges two one-row sections without subheadings", SHAPE(OPTS(FIND(out, "focus:look"))) == "S:CARD_TEXT|fontA|fontSize", SHAPE(OPTS(FIND(out, "focus:look"))))
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

  -- A column's title becomes a sub-heading at the top of that column's rows.
  RESET()
  HorizonSuite.RegisterModulePages("augment", { { key = "loot", name = "Loot" } })
  local out4 = A.Run({ { key = "AugmentImprovements", moduleKey = "augment", options = {
    SEC("Toasts", { page = "loot" }),
    { type = "columns",
      left = { title = "Max visible", options = { ROW("a1"), { type = "section", name = "Stacking" }, ROW("a2") } },
      right = { title = "Toast types", options = { ROW("b1") } } },
    SEC("Style", { page = "loot" }),
    { type = "columns",
      left = { options = { { type = "section", name = "Hold" }, ROW("c1") } },
      right = { title = "Hold durations", options = { ROW("d1") } } },
  } } })
  local loot4 = SHAPE(OPTS(FIND(out4, "augment:loot")))
  check("column titles become headers", loot4 == "S:Toasts|H:Max visible|a1|H:Toast types|b1|S:Stacking|a2|S:Style|H:Hold durations|d1|S:Hold|c1", loot4)
  local hdr
  for _, r in ipairs(OPTS(FIND(out4, "augment:loot"))) do if r.type == "header" then hdr = r break end end
  check("column header row has a name and no dbKey", hdr and hdr.name == "Max visible" and hdr.dbKey == nil, hdr and tostring(hdr.dbKey))
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
  check("the More store is gone", A.IsMoreOpen == nil and A.SetMoreOpen == nil, "still defined")
  check("no More state is written", HorizonDB.optionsCardMoreOpen == nil, "written")
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
  check("no hint while the parent matches", by.maxW.tooltip() == nil, tostring(by.maxW.tooltip()))
  DB_VALUES.dyn = false
  check("hint names the parent once it stops matching", by.maxW.tooltip() == "Depends on dyn.", tostring(by.maxW.tooltip()))
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

// --- Chained parents ------------------------------------------------------------------
run(`
  local A = HorizonSuite.OptionsAssemble
  RESET()
  DB_VALUES = { a = true, b = true, hid = true, kid = true, rv = true }
  local src = { key = "L", moduleKey = "focus", options = {
    SEC("Size", { page = "layout", card = "size" }),
    ROW("a"),
    ROW("b", { parent = "a" }),
    ROW("c", { parent = "b" }),
    ROW("hid", { visibleWhen = function() return false end }),
    ROW("kid", { parent = "hid" }),
    ROW("rv", { visibleWhen = function() return false end }),
    ROW("rvKid", { parent = "rv" }),
    ROW("x", { parent = "y" }),
    ROW("y", { parent = "x" }),
  } }
  local out = A.Run({ src })
  local by = {}
  for _, r in ipairs(OPTS(out[1])) do if r.dbKey then by[r.dbKey] = r end end
  check("chain shows when every link matches", by.c.visibleWhen() == true, "false")
  DB_VALUES.a = false
  check("grandchild hides when the grandparent is off", by.c.visibleWhen() == false, "true")
  check("grandchild disabled when the grandparent is off", by.c.disabled() == true, "false")
  DB_VALUES.a = true
  check("grandchild shows again", by.c.visibleWhen() == true, "false")
  check("root refreshes every descendant", table.concat(by.a.refreshIds or {}, ",") == "b,c", table.concat(by.a.refreshIds or {}, ","))
  check("middle refreshes its child", table.concat(by.b.refreshIds or {}, ",") == "c", table.concat(by.b.refreshIds or {}, ","))
  check("cycle warns", WARNED("cycle"), "no warning")
  local n = 0
  for _, w in ipairs(A.warnings) do if w:find("cycle") then n = n + 1 end end
  check("cycle warns once", n == 1, n)
  check("cycle rows stay unwired", by.x.visibleWhen == nil and by.y.visibleWhen == nil, "wired")
  check("hidden parent hides its child despite a match", by.kid.visibleWhen() == false, "true")
  A.revealId = "rvKid"
  check("revealed child shows under a hidden parent", by.rvKid.visibleWhen() == true, "false")
  A.revealId = nil
  DB_VALUES.a = false
  A.revealId = "b"
  check("revealed middle of an off chain still shows", by.b.visibleWhen() == true, "false")
  check("revealed middle of an off chain is disabled", by.b.disabled() == true, "false")
  check("grandchild under a revealed, unmatched middle is disabled", by.c.disabled() == true, "false")
  check("grandchild under a revealed, unmatched middle hides", by.c.visibleWhen() == false, "true")
  A.revealId = "c"
  check("revealed grandchild of an off chain shows", by.c.visibleWhen() == true, "false")
  A.revealId = nil
  DB_VALUES.a = true
`, 'chained-parents');

// --- Get-less parent ---------------------------------------------------------------------
run(`
  local A = HorizonSuite.OptionsAssemble
  RESET()
  DB_VALUES = { gl = true }
  local out = A.Run({ { key = "L", moduleKey = "focus", options = {
    SEC("Size", { page = "layout", card = "size" }),
    { type = "toggle", name = "gl", dbKey = "gl" },
    ROW("kid", { parent = "gl" }),
  } } })
  local by = {}
  for _, r in ipairs(OPTS(out[1])) do if r.dbKey then by[r.dbKey] = r end end
  check("get-less parent shows the child", by.kid.visibleWhen() == true, "false")
  DB_VALUES.gl = false
  check("get-less parent hides the child", by.kid.visibleWhen() == false, "true")
`, 'getless-parent');

// --- No More fold: `advanced` is ignored -------------------------------------------------
run(`
  local A = HorizonSuite.OptionsAssemble
  RESET()
  local out = A.Run({ { key = "L", moduleKey = "focus", options = {
    SEC("Size", { page = "layout", card = "size" }),
    ROW("a"), ROW("adv1", { advanced = true }), ROW("b"), ROW("adv2", { advanced = true }),
    SEC("Where", { page = "layout", card = "position" }), ROW("lock"),
  } } })
  local rows = OPTS(out[1])
  check("advanced row stays in place", SHAPE(rows) == "S:CARD_POSITION|lock|S:CARD_SIZE|a|adv1|b|adv2", SHAPE(rows))
  local more, adv1 = false, nil
  for _, r in ipairs(rows) do
    if r.type == "moreToggle" then more = true end
    if r.dbKey == "adv1" then adv1 = r end
  end
  check("no moreToggle rows", more == false, "moreToggle present")
  check("advanced row has no condition of its own", adv1 and adv1.visibleWhen == nil, "wired")
`, 'no-more-fold');

// --- Advanced rows behave like any other row ------------------------------------------------
run(`
  local A = HorizonSuite.OptionsAssemble
  RESET()
  DB_VALUES = { vis = false, own = true }
  HorizonSuite.Platform.caps.gone = false
  local out = A.Run({ { key = "L", moduleKey = "focus", options = {
    SEC("Size", { page = "layout", card = "size" }),
    ROW("vis"),
    ROW("visKid", { parent = "vis", advanced = true }),
    SEC("Where", { page = "layout", card = "position" }),
    ROW("lock"),
    ROW("p1", { advanced = true }),
    ROW("p2", { advanced = true, requires = "gone" }),
    ROW("p3", { advanced = true, visibleWhen = function() return DB_VALUES.own end }),
  } } })
  local rows = OPTS(out[1])
  HorizonSuite.Platform.caps.gone = nil
  local by = {}
  for _, r in ipairs(rows) do
    if r.dbKey and r.type ~= "section" then by[r.dbKey] = r end
  end
  check("advanced child hides while its parent is off", by.visKid.visibleWhen() == false, "shown")
  DB_VALUES.vis = true
  check("advanced child shows once its parent is on", by.visKid.visibleWhen() == true, "hidden")
  check("advanced child is indented under its parent", by.visKid.indent == true, tostring(by.visKid.indent))
  DB_VALUES.vis = false
  A.revealId = "visKid"
  check("search reveal shows an advanced child of an off parent", by.visKid.visibleWhen() == true, "hidden")
  A.revealId = nil
  check("row with an absent capability is dropped", by.p2 == nil, "present")
  check("advanced row with its own condition follows it", by.p3.visibleWhen() == true, "hidden")
  DB_VALUES.own = false
  check("advanced row with a failing condition hides", by.p3.visibleWhen() == false, "shown")
  check("no store gate on any row", HorizonDB.optionsCardMoreOpen == nil, "written")
`, 'advanced-ignored');

// --- An advanced chain behaves like any chain ------------------------------------------------
run(`
  local A = HorizonSuite.OptionsAssemble
  RESET()
  DB_VALUES = { ev = true, ap = true, ak = true }
  local out = A.Run({ { key = "L", moduleKey = "focus", options = {
    SEC("Size", { page = "layout", card = "size" }),
    ROW("ev"),
    ROW("ap", { parent = "ev", advanced = true }),
    ROW("ak", { parent = "ap", advanced = true }),
  } } })
  local by = {}
  for _, r in ipairs(OPTS(out[1])) do if r.dbKey and r.type ~= "section" then by[r.dbKey] = r end end
  check("advanced chain shows when every link matches", by.ak.visibleWhen() == true, "hidden")
  DB_VALUES.ap = false
  check("advanced grandchild hides with its advanced parent", by.ak.visibleWhen() == false, "shown")
  DB_VALUES.ap, DB_VALUES.ev = true, false
  check("advanced grandchild hides with the top of the chain", by.ak.visibleWhen() == false, "shown")
  check("the counting hook is gone", A._countingCard == nil, tostring(A._countingCard))
`, 'advanced-chain');

// --- Subheadings in merged cards ---------------------------------------------------------
run(`
  local A = HorizonSuite.OptionsAssemble
  RESET()
  HorizonSuite.RegisterModulePages("focus", { { key = "tracked", name = "T" } })
  DB_VALUES = { master = false }
  local out = A.Run({ { key = "L", moduleKey = "focus", options = {
    -- A module card: its displayed name is its first section's name.
    SEC("Quests", { page = "tracked", card = "q" }), ROW("q1"), ROW("q1b"),
    SEC("Quest extras", { page = "tracked", card = "q" }), ROW("q2"), ROW("q2b"),
    -- A single-section card.
    SEC("Alone", { page = "tracked", card = "solo" }), ROW("s1"), ROW("s2"),
    -- A module card whose first section names its own subheading, despite matching the card name.
    SEC("Forced", { page = "tracked", card = "f", subheading = "X" }), ROW("f1"), ROW("f2"),
    SEC("Forced more", { page = "tracked", card = "f" }), ROW("f3"), ROW("f4"),
    -- A shared card: no section is named like the card.
    SEC("Fonts", { page = "look", card = "text" }), ROW("master"), ROW("face"),
    SEC("Per-element", { page = "look", card = "text" }), ROW("k1", { parent = "master" }), ROW("k2", { parent = "master" }),
    SEC("Renamed", { page = "look", card = "text", subheading = "Case" }), ROW("c1"),
    SEC("Quiet", { page = "look", card = "text", subheading = false }), ROW("z1"), ROW("z2"),
    SEC("Empty", { page = "look", card = "text" }),
    -- A one-row section gets no subheading of its own.
    SEC("Spacing", { page = "layout", card = "size" }), ROW("g1"), ROW("g2"),
    SEC("Width", { page = "layout", card = "size" }), ROW("w1"),
  } } })
  local tracked = SHAPE(OPTS(FIND(out, "focus:tracked")))
  check("second section of a merged card gets a subheading; the one named like the card does not",
    tracked:find("S:Quests|q1|q1b|H:Quest extras|q2|q2b|", 1, true) == 1, tracked)
  check("a single-section card has no subheading", tracked:find("S:Alone|s1|s2|", 1, true) ~= nil, tracked)
  check("subheading = string on a module card's first section beats the name-match rule",
    tracked:find("S:Forced|H:X|f1|f2|H:Forced more|f3|f4", 1, true) ~= nil, tracked)
  local lookRows = OPTS(FIND(out, "focus:look"))
  local look = SHAPE(lookRows)
  check("every section of a shared card gets a subheading; override renames and forces a one-row section, false suppresses, empty skipped",
    look == "S:CARD_TEXT|H:Fonts|master|face|H:Per-element|k1|k2|H:Case|c1|z1|z2", look)
  local layout = SHAPE(OPTS(FIND(out, "focus:layout")))
  check("a one-row section gets no subheading", layout == "S:CARD_SIZE|H:Spacing|g1|g2|w1", layout)

  local hdr = {}
  for _, r in ipairs(lookRows) do if r.type == "header" then hdr[r.name] = r end end
  local function shows(h) return h ~= nil and (not h.visibleWhen or h.visibleWhen()) and true or false end
  check("subheading row has no dbKey", hdr["Per-element"] and hdr["Per-element"].dbKey == nil, "dbKey set")
  check("subheading over rows that always show has no condition", hdr.Fonts and hdr.Fonts.visibleWhen == nil, "conditional")
  check("subheading hides while all its rows wait on an off parent", shows(hdr["Per-element"]) == false, "shown")
  DB_VALUES.master = true
  check("subheading shows again once the parent turns on", shows(hdr["Per-element"]) == true, "hidden")
  DB_VALUES.master = false
  A.revealId = "k2"
  check("a revealed row keeps its subheading", shows(hdr["Per-element"]) == true, "hidden")
  A.revealId = nil
  check("a subheading's rows stop at the next subheading", shows(hdr.Case) == true, "hidden")
`, 'subheadings');

// --- A subheading's scope ends at the next subheading, not at a column title -------------------
run(`
  local A = HorizonSuite.OptionsAssemble
  RESET()
  DB_VALUES = { gate = false }
  local out = A.Run({ { key = "L", moduleKey = "focus", options = {
    SEC("Main", { page = "look", card = "text" }), ROW("gate"), ROW("other"),
    SEC("Cols", { page = "look", card = "text" }),
    { type = "columns",
      left = { title = "Left", options = { ROW("l1", { parent = "gate" }) } },
      right = { title = "Right", options = { ROW("r1") } } },
  } } })
  local rows = OPTS(out[1])
  check("column titles follow the section subheading, and do not count as its rows",
    SHAPE(rows) == "S:CARD_TEXT|H:Main|gate|other|H:Cols|H:Left|l1|H:Right|r1", SHAPE(rows))
  local hdr = {}
  for _, r in ipairs(rows) do if r.type == "header" then hdr[r.name] = r end end
  local function shows(h) return h ~= nil and (not h.visibleWhen or h.visibleWhen()) and true or false end
  check("section subheading counts rows past a column title", shows(hdr.Cols) == true, "hidden")
  check("column title hides when its own rows all hide", shows(hdr.Left) == false, "shown")
  DB_VALUES.gate = true
  check("column title shows with its rows", shows(hdr.Left) == true, "hidden")

  -- A header's own condition is kept and joined with the content rule.
  RESET()
  DB_VALUES = { gate = true }
  local OWN = true
  local out2 = A.Run({ { key = "L", moduleKey = "focus", options = {
    SEC("Main", { page = "look", card = "text" }), ROW("gate"),
    { type = "header", name = "Own", visibleWhen = function() return OWN end },
    ROW("o1", { parent = "gate" }),
  } } })
  local own
  for _, r in ipairs(OPTS(out2[1])) do if r.type == "header" then own = r end end
  check("header with its own condition shows while both pass", own and own.visibleWhen() == true, "hidden")
  OWN = false
  check("header's own condition still hides it", own and own.visibleWhen() == false, "shown")
  OWN = true
  DB_VALUES.gate = false
  check("content rule still hides a header with its own condition", own and own.visibleWhen() == false, "shown")
`, 'subheading-scope');

// --- Overflow cards: after = <card key> places a module card straight after that card ---------
run(`
  local A = HorizonSuite.OptionsAssemble
  RESET()
  local out = A.Run({ { key = "L", moduleKey = "focus", options = {
    SEC("Plain", { page = "look", card = "plain" }), ROW("p1"),
    SEC("Bg", { page = "look", card = "background" }), ROW("b1"),
    SEC("Sizes", { page = "look", card = "sizes", after = "text" }), ROW("s1"),
    SEC("Fonts", { page = "look", card = "text" }), ROW("f1"),
    SEC("Style", { page = "look", card = "style", after = "text" }), ROW("st1"),
    SEC("Theme", { page = "look", card = "theme", after = "colours" }), ROW("t1"),
    SEC("Col", { page = "look", card = "colours" }), ROW("c1"),
    SEC("Lost", { page = "look", card = "lost", after = "animation" }), ROW("l1"),
  } } })
  local look = SHAPE(OPTS(FIND(out, "focus:look")))
  check("after places overflow straight after its card, ties by declaration; a missing target falls back to declaration order",
    look == "S:CARD_TEXT|f1|S:Sizes|s1|S:Style|st1|S:CARD_COLOURS|c1|S:Theme|t1|S:CARD_BACKGROUND|b1|S:Plain|p1|S:Lost|l1", look)
`, 'overflow-after');

// --- A header-switch card that merges a second section keeps its own condition -------------
run(`
  local A = HorizonSuite.OptionsAssemble
  RESET()
  local INSTALLED = false
  local function installed() return INSTALLED end
  local out = A.Run({ { key = "L", moduleKey = "insight", options = {
    SEC("Addon", { page = "look", card = "addon", headerToggle = { dbKey = "on" }, visibleWhen = installed }), ROW("a1"), ROW("a2"),
    SEC("Details", { page = "look", card = "addon" }), ROW("d1"), ROW("d2"),
  } } })
  local rows = OPTS(out[1])
  check("merged header-switch card keeps its switch and a subheading for the second section",
    SHAPE(rows) == "S:Addon|a1|a2|H:Details|d1|d2", SHAPE(rows))
  local head = rows[1]
  check("merged header-switch card keeps its first section's condition",
    head.headerToggle ~= nil and type(head.visibleWhen) == "function" and head.visibleWhen() == false, tostring(head.visibleWhen))
  INSTALLED = true
  check("merged header-switch card shows once its condition passes", head.visibleWhen and head.visibleWhen() == true, "hidden")
`, 'merged-switch-card');

// --- Cards with nothing to show -------------------------------------------------------
run(`
  local A = HorizonSuite.OptionsAssemble
  RESET()
  DB_VALUES = { master = false, sw = false, gate = true }
  local OWN = true
  local out = A.Run({ { key = "L", moduleKey = "focus", options = {
    SEC("Main", { page = "layout", card = "size" }),
    ROW("master"),
    ROW("near", { parent = "master" }),
    SEC("Far", { page = "layout", card = "position" }),
    ROW("k1", { parent = "master" }),
    ROW("k2", { parent = "master" }),
    { type = "talkingHeadPreview" },
    { type = "header", name = "Group" },
  } }, { key = "M", moduleKey = "focus", options = {
    SEC("Switched", { page = "look", card = "text", headerToggle = { dbKey = "sw" } }),
    ROW("sw"),
    ROW("gate"),
    ROW("s1", { parent = "gate", parentIs = false }),
    SEC("Folded", { page = "look", card = "colours" }),
    ROW("f1", { parent = "gate", parentIs = false }),
    ROW("f2", { advanced = true }),
    SEC("Own", { page = "look", card = "background", visibleWhen = function() return OWN end }),
    ROW("o1", { parent = "gate" }),
  } } })
  local function rowsOf(key)
    local c = FIND(out, key)
    return c and OPTS(c) or {}
  end
  local hdr, by = {}, {}
  for _, k in ipairs({ "focus:layout", "focus:look" }) do
    for _, r in ipairs(rowsOf(k)) do
      if r.type == "section" then hdr[r.card] = r end
      if r.dbKey and r.type ~= "section" then by[r.dbKey] = r end
    end
  end
  local function shows(card)
    local h = hdr[card]
    return h ~= nil and (not h.visibleWhen or h.visibleWhen()) and true or false
  end
  check("card fixture wires every parent", not WARNED("not on this page"), "parent missing")
  check("card whose rows all wait on an unmatched parent hides", shows("position") == false, "shown")
  DB_VALUES.master = true
  check("that card shows once the parent matches", shows("position") == true, "hidden")
  DB_VALUES.master = false
  check("card holding the parent stays", shows("size") == true, "hidden")
  check("header-switch card is never auto-hidden", shows("text") == true, "hidden")
  check("an advanced row is ordinary content that keeps its card", shows("colours") == true, "hidden")
  check("own section condition kept while content shows", shows("background") == true, "hidden")
  OWN = false
  check("own section condition still hides the card", shows("background") == false, "shown")
  OWN = true
  DB_VALUES.gate = false
  check("auto rule ANDs with the own condition", shows("background") == false, "shown")
  DB_VALUES.gate = true
  A.revealId = "k1"
  check("a revealed row keeps its card", shows("position") == true, "hidden")
  A.revealId = nil
  check("child in the parent's card is indented", by.near.indent == true, tostring(by.near.indent))
  check("child in another card is not indented", not by.k1.indent, tostring(by.k1.indent))
  check("cross-card child still hides with its parent", by.k1.visibleWhen() == false, "true")
  check("cross-card child still gets the hint", by.k1.tooltip() == "Depends on master.", tostring(by.k1.tooltip()))
  check("parent refreshes cross-card children", table.concat(by.master.refreshIds or {}, ",") == "k1,k2,near", table.concat(by.master.refreshIds or {}, ","))
`, 'empty-cards');

// --- Search ---------------------------------------------------------------------------
run(`
  local A = HorizonSuite.OptionsAssemble
  RESET()
  HorizonSuite.RegisterModulePages("augment", { { key = "loot", name = "Loot" } })
  HorizonSuite.OptionCategories = A.Run({
    { key = "F", moduleKey = "focus", options = {
      SEC("Size", { page = "layout", card = "size" }),
      ROW("panelWidth", { name = "Panel width", keywords = { "breadth" } }),
      ROW("breadthName", { name = "Breadth" }),
      ROW("descOnly", { name = "Other", desc = "Sets the breadth" }),
      ROW("advRow", { name = "Hidden gem", advanced = true }),
      { type = "colorMatrixFull", dbKey = "colorMatrix", searchName = "Colour matrix" },
    } },
    { key = "AugmentImprovements", moduleKey = "augment", options = {
      SEC("Toasts", { page = "loot" }),
      { type = "columns", left = { options = { ROW("toastOpacity", { name = "Toast opacity" }) } }, right = { options = {} } },
    } },
  })
  HorizonSuite.OptionsSearch_Invalidate()
  local idx = OptionsData_BuildSearchIndex()
  local by = {}
  for _, e in ipairs(idx) do by[e.optionId] = e end
  check("one result per setting row", by["F_"] == nil and #idx == 6, #idx)
  check("advanced row is indexed", by.advRow ~= nil, "nil")
  check("former columns row is indexed", by.toastOpacity ~= nil, "nil")
  check("searchName makes a special widget findable", by.colorMatrix and OptionsData_SearchEntryScore(by.colorMatrix, "colour") ~= nil, "nil")
  check("entry knows its card", by.panelWidth.cardId == "focus:layout:size", by.panelWidth.cardId)
  check("entry shows page and card", by.panelWidth.categoryName == "PAGE_LAYOUT" and by.panelWidth.sectionName == "CARD_SIZE", tostring(by.panelWidth.categoryName) .. " " .. tostring(by.panelWidth.sectionName))
  local sName = OptionsData_SearchEntryScore(by.breadthName, "breadth")
  local sKw = OptionsData_SearchEntryScore(by.panelWidth, "breadth")
  local sDesc = OptionsData_SearchEntryScore(by.descOnly, "breadth")
  check("keyword matches", sKw ~= nil, "nil")
  check("keyword ranks below name", sKw and sName and sKw < sName, tostring(sKw) .. " vs " .. tostring(sName))
  check("keyword ranks above description", sKw and sDesc and sKw > sDesc, tostring(sKw) .. " vs " .. tostring(sDesc))
  check("index is cached", OptionsData_BuildSearchIndex() == idx, "rebuilt")
  HorizonSuite.OptionsSearch_Invalidate()
  check("invalidate rebuilds", OptionsData_BuildSearchIndex() ~= idx, "same table")
  HorizonSuite.OptionCategories = nil
`, 'search');

// --- Subheadings are not search results ---------------------------------------------------
run(`
  local A = HorizonSuite.OptionsAssemble
  RESET()
  HorizonSuite.OptionCategories = A.Run({ { key = "F", moduleKey = "focus", options = {
    SEC("Fonts", { page = "look", card = "text" }), ROW("fa", { name = "Font face" }), ROW("fb", { name = "Font fallback" }),
    SEC("Sizes", { page = "look", card = "text" }), ROW("fs", { name = "Font size" }), ROW("ft", { name = "Title size" }),
  } } })
  HorizonSuite.OptionsSearch_Invalidate()
  local idx = OptionsData_BuildSearchIndex()
  local headers, by = 0, {}
  for _, e in ipairs(idx) do
    if e.option.type == "header" then headers = headers + 1 end
    by[e.optionId] = e
  end
  local rows = SHAPE(OPTS(HorizonSuite.OptionCategories[1]))
  check("fixture has subheadings", rows == "S:CARD_TEXT|H:Fonts|fa|fb|H:Sizes|fs|ft", rows)
  check("subheading rows are not search results", headers == 0 and #idx == 4, #idx)
  check("a result under a subheading names its card", by.fs and by.fs.sectionName == "CARD_TEXT", by.fs and by.fs.sectionName)
  HorizonSuite.OptionCategories = nil
`, 'search-subheadings');

run(`
  local A = HorizonSuite.OptionsAssemble
  RESET()
  HorizonSuite.RegisterModulePages("augment", { { key = "loot", name = "Loot" } })
  local out = A.Run({ { key = "X", moduleKey = "augment", options = {
    SEC("T", { page = "loot" }),
    { type = "columns", left = { options = { ROW("l") } }, right = { options = { ROW("r") } } },
  } } })
  local found = false
  for _, r in ipairs(OPTS(out[1])) do if r.type == "columns" then found = true end end
  check("assembled pages never contain columns", not found, "columns row present")
  check("strict is on by default", A.strict == true, A.strict)
`, 'strict');

// --- Font rows ------------------------------------------------------------------------
run(`
  local A = HorizonSuite.OptionsAssemble
  local FontRow = HorizonSuite.FontRow
  check("FontRow helper exists", type(FontRow) == "function", type(FontRow))
  if type(FontRow) ~= "function" then return end
  RESET()
  local full = FontRow("Title text", "d", {
    family = { dbKey = "tFont" }, size = { dbKey = "tSize", min = 8, max = 32 }, outline = { dbKey = "tOutline" },
  }, { keywords = { "Title size" } })
  check("font row type", full.type == "fontRow", full.type)
  check("font row dbKey is the family key", full.dbKey == "tFont", full.dbKey)
  check("font row keeps its parts", full.parts and full.parts.size and full.parts.size.dbKey == "tSize", "no parts")
  check("opts merged", full.keywords and full.keywords[1] == "Title size", "no keywords")
  local sizeOnly = FontRow("Zone", nil, { size = { dbKey = "zSize" }, outline = { dbKey = "zOut" } })
  check("font row without a family keys on its size", sizeOnly.dbKey == "zSize", sizeOnly.dbKey)
  DB_VALUES.tSize = 17
  check("part without a getter reads its key", full.parts.size.get() == 17, tostring(full.parts.size.get()))
  check("outline kind defaults to dropdown", full.parts.outline.kind == "dropdown", tostring(full.parts.outline.kind))

  -- A row whose parent names a part key resolves against that part.
  RESET()
  DB_VALUES = { thOutline = false, kOut = "OUTLINE" }
  local src = { key = "L", moduleKey = "focus", options = {
    SEC("Text", { page = "look", card = "text" }),
    FontRow("Name", nil, {
      family = { dbKey = "thFont" }, size = { dbKey = "thSize" },
      outline = { dbKey = "thOutline", kind = "toggle", get = function() return DB_VALUES.thOutline end },
    }),
    FontRow("Kid font", nil, { family = { dbKey = "kFont" }, outline = { dbKey = "kOut" } }),
    ROW("shadow", { parent = "thOutline" }),
    ROW("thick", { parent = "kOut", parentIs = "THICKOUTLINE" }),
  } }
  local out = A.Run({ src })
  local by = {}
  for _, r in ipairs(OPTS(out[1])) do if r.dbKey then by[r.dbKey] = r end end
  check("part-key parent wires without a warning", not WARNED("not on this page"), "warned")
  check("child of an off outline part hides", by.shadow.visibleWhen() == false, "true")
  DB_VALUES.thOutline = true
  check("child of an on outline part shows", by.shadow.visibleWhen() == true, "false")
  check("child of a part is indented", by.shadow.indent == true, tostring(by.shadow.indent))
  check("hint names the font row", (function() DB_VALUES.thOutline = false; return by.shadow.tooltip() end)() == "Depends on Name.", tostring(by.shadow.tooltip()))
  check("get-less part parent hides on mismatch", by.thick.visibleWhen() == false, "true")
  DB_VALUES.kOut = "THICKOUTLINE"
  check("get-less part parent shows on match", by.thick.visibleWhen() == true, "false")
  check("font row refreshes children of its parts", table.concat(by.thFont.refreshIds or {}, ",") == "shadow", table.concat(by.thFont.refreshIds or {}, ","))
  -- A child of the row's own (family) key reads the family part's getter and default.
  RESET()
  DB_VALUES = {}
  local out3 = A.Run({ { key = "L", moduleKey = "focus", options = {
    SEC("Text", { page = "look", card = "text" }),
    FontRow("Fam", nil, { family = { dbKey = "pf", default = "FRIZ" }, size = { dbKey = "ps" } }),
    ROW("famKid", { parent = "pf", parentIs = "FRIZ" }),
  } } })
  local by3 = {}
  for _, r in ipairs(OPTS(out3[1])) do if r.dbKey then by3[r.dbKey] = r end end
  check("child of the family key matches the family default", by3.famKid.visibleWhen() == true, "false")
  DB_VALUES.pf = "ARIAL"
  check("child of the family key follows the saved family", by3.famKid.visibleWhen() == false, "true")
  check("child of the family key is indented", by3.famKid.indent == true, tostring(by3.famKid.indent))
  check("font row refreshes children of its own key", table.concat(by3.pf.refreshIds or {}, ",") == "famKid", table.concat(by3.pf.refreshIds or {}, ","))

  -- A parent above a font row refreshes the rows hanging off that font row's parts.
  RESET()
  DB_VALUES = { per = true, cOut = "OUTLINE" }
  local out2 = A.Run({ { key = "L", moduleKey = "focus", options = {
    SEC("Text", { page = "look", card = "text" }),
    ROW("per"),
    FontRow("Child font", nil, { family = { dbKey = "cFont" }, outline = { dbKey = "cOut" } }, { parent = "per" }),
    ROW("gk", { parent = "cOut", parentIs = "OUTLINE" }),
  } } })
  local by2 = {}
  for _, r in ipairs(OPTS(out2[1])) do if r.dbKey then by2[r.dbKey] = r end end
  check("parent refreshes through a font row's parts", table.concat(by2.per.refreshIds or {}, ",") == "cFont,gk", table.concat(by2.per.refreshIds or {}, ","))
  DB_VALUES.per = false
  check("part child hides when the font row's parent is off", by2.gk.visibleWhen() == false, "true")
  check("source parts untouched", src.options[2].parts.outline.refreshIds == nil and src.options[2].refreshIds == nil, "mutated")

  -- Assembly and search treat a font row as one row.
  RESET()
  HorizonSuite.OptionCategories = A.Run({ { key = "F", moduleKey = "focus", options = {
    SEC("Text", { page = "look", card = "text" }),
    ROW("plain"),
    FontRow("Title text", nil, { family = { dbKey = "tFont" }, size = { dbKey = "tSize" }, outline = { dbKey = "tOut" } },
      { advanced = true, keywords = { "Title size", "Outline" } }),
  } } })
  local rows = OPTS(HorizonSuite.OptionCategories[1])
  check("advanced font row stays in place", SHAPE(rows) == "S:CARD_TEXT|plain|tFont", SHAPE(rows))
  local fr
  for _, r in ipairs(rows) do if r.type == "fontRow" then fr = r end end
  check("advanced font row always shows", fr and fr.visibleWhen == nil, "conditional")
  HorizonSuite.OptionsSearch_Invalidate()
  local idx = OptionsData_BuildSearchIndex()
  local n, hit = 0, nil
  for _, e in ipairs(idx) do if e.option.type == "fontRow" then n = n + 1; hit = e end end
  check("font row is one search result", n == 1, n)
  check("font row result keys on its primary key", hit and hit.optionId == "tFont", hit and hit.optionId)
  check("old row name finds the font row", hit and OptionsData_SearchEntryScore(hit, "title size") ~= nil, "nil")
  HorizonSuite.OptionCategories = nil
`, 'font-rows');

// --- Font row widget logic (the parts that need no frames) -------------------------------
run(`
  local H = HorizonSuite
  check("step helper exists", type(H.FontRowStepSize) == "function", type(H.FontRowStepSize))
  check("layout helper exists", type(H.FontRowLayout) == "function", type(H.FontRowLayout))
  if type(H.FontRowStepSize) ~= "function" or type(H.FontRowLayout) ~= "function" then return end
  local S = H.FontRowStepSize
  check("plus steps by one with no step", S(14, 1, 8, 32) == 15, S(14, 1, 8, 32))
  check("minus steps by the step", S(14, -1, 8, 32, 2) == 12, S(14, -1, 8, 32, 2))
  check("plus clamps at max", S(32, 1, 8, 32) == 32, S(32, 1, 8, 32))
  check("minus clamps at min", S(8, -1, 8, 32) == 8, S(8, -1, 8, 32))
  check("typed value is clamped", S(99, 0, 8, 32) == 32, S(99, 0, 8, 32))
  check("typed value snaps to the step", S(13.4, 0, 8, 32) == 13, S(13.4, 0, 8, 32))
  check("fractional step keeps clean decimals", S(0.8, 1, 0.5, 2, 0.1) == 0.9, S(0.8, 1, 0.5, 2, 0.1))
  check("text that is not a number falls back", S("abc", 0, 8, 32, 1, 14) == 14, S("abc", 0, 8, 32, 1, 14))
  local T = H.FontRowTypedSize
  check("typed helper exists", type(T) == "function", type(T))
  if type(T) == "function" then
    check("untouched text commits nothing", T("14", 14, 8, 32, 1) == nil, tostring(T("14", 14, 8, 32, 1)))
    check("untouched text over an off-grid min commits nothing", T("7", 7, 7, 31, 2) == nil, tostring(T("7", 7, 7, 31, 2)))
    check("untouched text over a fractional value commits nothing", T("14", 13.6, 8, 32, 1) == nil, tostring(T("14", 13.6, 8, 32, 1)))
    check("text that is not a number commits nothing", T("abc", 14, 8, 32, 1) == nil, tostring(T("abc", 14, 8, 32, 1)))
    check("typed value commits clamped", T("99", 14, 8, 32, 1) == 32, tostring(T("99", 14, 8, 32, 1)))
    check("typed value equal to the saved one commits nothing", T("14.2", 14, 8, 32, 1) == nil, tostring(T("14.2", 14, 8, 32, 1)))
    check("typed fractional value commits snapped", T("1.25", 1, 0.5, 2, 0.1) == 1.3 or T("1.25", 1, 0.5, 2, 0.1) == 1.2, tostring(T("1.25", 1, 0.5, 2, 0.1)))
    check("format shows step decimals", H.FontRowFormatSize(1.3, 0.1) == "1.3" and H.FontRowFormatSize(13.6, 1) == "14", tostring(H.FontRowFormatSize(1.3, 0.1)))
  end
  local L = H.FontRowLayout
  local wide = L(970, { family = true, size = true, outline = true })
  check("wide row is one line", wide.wrapped == false and wide.lines == 1, tostring(wide.wrapped) .. " " .. tostring(wide.lines))
  check("one line at exactly 640", L(640, { family = true, size = true }).wrapped == false, "wrapped")
  local narrow = L(600, { family = true, size = true, outline = true })
  check("narrow row wraps to two lines", narrow.wrapped == true and narrow.lines == 2, tostring(narrow.wrapped) .. " " .. tostring(narrow.lines))
  check("font is never narrower than 140", L(640, { family = true }).familyW >= 140 and L(300, { family = true }).familyW >= 140, L(300, { family = true }).familyW)
  check("font flexes wider on a wide row", wide.familyW > L(640, { family = true, size = true, outline = true }).familyW, wide.familyW)
  check("narrow row with only a font stays one line", L(600, { family = true }).lines == 1, tostring(L(600, { family = true }).lines))
  check("unknown width lays out as one line", L(0, { family = true, size = true }).wrapped == false, "wrapped")
`, 'font-row-widget-logic');

// --- Card row spacing: gaps and hairlines from the visible order ----------------------
run(`
  local H = HorizonSuite
  check("row spacing helper exists", type(H.CardRowSpacing) == "function", type(H.CardRowSpacing))
  if type(H.CardRowSpacing) ~= "function" then return end
  local M = { subheadingTop = 12, subheadingBottom = 2, noteTop = 6, blockPad = 8 }
  local function picture(kinds)
    local out = {}
    for i, e in ipairs(H.CardRowSpacing(kinds, M)) do
      out[i] = (e.divider and "D" or "-") .. e.top .. "/" .. e.bottom
    end
    return table.concat(out, " ")
  end
  local p = picture({ "row", "row", "row" })
  check("no hairline above a card's first row, one above each row after", p == "-0/0 D0/0 D0/0", p)
  p = picture({ "row", "subheading", "row", "row" })
  check("no hairline above the first row of a subheading group", p == "-0/0 -12/2 -0/0 D0/0", p)
  p = picture({ "subheading", "row" })
  check("a subheading opening the card has no hairline and neither does its row", p == "-12/2 -0/0", p)
  p = picture({ "row", "block", "row" })
  check("custom widgets are padded and separated like rows", p == "-0/0 D8/8 D0/0", p)
  p = picture({ "row", "spacer", "row" })
  check("a zero-height entry is skipped for hairlines", p == "-0/0 -0/0 D0/0", p)
  p = picture({ "note", "row", "row" })
  check("a note starts a group like a subheading", p == "-6/0 -0/0 D0/0", p)
  p = picture({ "spacer", "row" })
  check("a spacer before the first row leaves it without a hairline", p == "-0/0 -0/0", p)
  check("an empty card has no entries", #H.CardRowSpacing({}, M) == 0, #H.CardRowSpacing({}, M))
`, 'card-row-spacing');

// --- Settings row height from measured text ---------------------------------------------
run(`
  local RH = HorizonSuite.SettingsRowHeight
  check("row height helper exists", type(RH) == "function", type(RH))
  if type(RH) ~= "function" then return end
  -- Default sizes: label 13 (about 15px a line), help 11 (about 13px a line).
  local M = { minH = 40, padY = 11, descGap = 2, labelMaxH = 2 * 13 * 1.5, descMaxH = 2 * 11 * 1.5 }
  local h, block = RH(15, 0, M)
  check("one label line and no description is 40", h == 40 and block == 15, h .. "/" .. block)
  h = RH(15, 13, M)
  check("a one-line description makes about 52", h == 52, h)
  h = RH(15, 26, M)
  check("a two-line description makes about 66", h == 65 or h == 66, h)
  h = RH(30, 0, M)
  check("a wrapped label grows the row", h == 52, h)
  h = RH(15, 60, M)
  check("a description over two lines is capped", h == math.ceil(15 + 2 + 33 + 22), h)
  h = RH(60, 0, M)
  check("a label over two lines is capped", h == math.ceil(39 + 22), h)
  h, block = RH(nil, nil, M)
  check("no text still gives the shortest row", h == 40 and block == 0, h .. "/" .. block)
  local _, b2 = RH(15, 13, M)
  check("the block includes the gap", b2 == 30, b2)
`, 'settings-row-height');

// --- Widget type scale: titles and help follow the label size -------------------------
run(read('options/OptionsWidgets.lua'), 'options/OptionsWidgets.lua');
run(`
  local H = HorizonSuite
  local TS = H.OptionsWidgets_TypeScaleFor
  check("type scale helper exists", type(TS) == "function", type(TS))
  if type(TS) ~= "function" then return end
  local t, h = TS(13)
  check("label 13 gives title 15 and help 11", t == 15 and h == 11, tostring(t) .. "/" .. tostring(h))
  t, h = TS(9)
  check("help never drops below 8", t == 11 and h == 8, tostring(t) .. "/" .. tostring(h))
  t, h = TS(nil)
  check("no label size falls back to 13", t == 15 and h == 11, tostring(t) .. "/" .. tostring(h))
  local D = H.OptionsWidgetsDef
  check("Def starts on the derived scale", D.TitleSize == 15 and D.HelpSize == 11, tostring(D.TitleSize) .. "/" .. tostring(D.HelpSize))
  OptionsWidgets_SetDef({ LabelSize = 16 })
  check("a new label size re-derives both", D.TitleSize == 18 and D.HelpSize == 14, tostring(D.TitleSize) .. "/" .. tostring(D.HelpSize))
  OptionsWidgets_SetDef({ LabelSize = 12, HelpSize = 20 })
  check("a size set in the same call wins", D.TitleSize == 14 and D.HelpSize == 20, tostring(D.TitleSize) .. "/" .. tostring(D.HelpSize))
  OptionsWidgets_SetDef({ FontPath = "x" })
  check("a call without a label size leaves the scale alone", D.TitleSize == 14 and D.HelpSize == 20, tostring(D.TitleSize) .. "/" .. tostring(D.HelpSize))
  OptionsWidgets_SetDef({ LabelSize = 13 })
`, 'widget-type-scale');

// --- Summary -----------------------------------------------------------------------
run(`
  REAL_PRINT(PASS .. " passed, " .. FAIL .. " failed")
  if FAIL > 0 then error("options logic tests failed") end
`, 'summary');
