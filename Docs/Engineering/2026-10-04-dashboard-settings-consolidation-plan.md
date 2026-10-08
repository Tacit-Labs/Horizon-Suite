# Dashboard settings consolidation, phase 1: dashboard shell Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give every module the same page vocabulary (General, Layout, Look & Feel, then its own pages), open the first card on each page, hide dependent settings until they apply, add a per-card More fold, and make search cover every setting.

**Architecture:** Module options files keep registering categories into `addon.OptionCategories`, but tag each `Section` with `page` and `card`. A new assembler (`options/OptionsAssemble.lua`) runs once after every module file, groups tagged sections into pages and cards, and writes the assembled pages back into the same `addon.OptionCategories` table, so the sidebar, detail view, search and platform prune need no structural change. Untagged categories pass through unchanged until the last task makes them an error.

**Tech Stack:** World of Warcraft addon Lua 5.1 (Retail and WoW: Forever), the existing fengari test harness pattern in `tools/test_*_logic.js`, the locale tooling in `tools/`.

**Spec:** `Docs/Engineering/2026-10-04-dashboard-settings-consolidation-design.md`

## Global Constraints

- Phase 1 changes no saved setting key and needs no migration. Only where a setting appears moves.
- Shared pages, in order: `general` (General), `layout` (Layout), `look` (Look & Feel).
- Shared cards: General → `visibility`, `behaviour`; Layout → `position`, `size`; Look & Feel → `text`, `colours`, `background`, `animation`.
- Category keys `Modules`, `Profiles` and `GlobalToggles` stay as they are; other assembled pages use `<moduleKey>:<pageKey>`.
- Card ids are `<moduleKey>:<pageKey>:<cardKey>`; card open and More state live in `_G[addon.DATABASE].optionsCardExpanded` and `.optionsCardMoreOpen`.
- Retag tasks never change a row's table. They add `page`/`card` tags, may insert a new `Section`, and may move whole rows between sections.
- Lua style: 4-space indent, `local addon = _G.HorizonSuite` header, `--[[ ]]` file banner, `---` doc comments on exported functions (match `options/OptionsHelpers.lua`).
- Locale: new strings go in `locales/horizon/enUS.lua`; other locales get commented stubs via `node tools/restructure_locales.js`.
- Git: work in a worktree from `origin/main`, never in the shared main checkout. One branch per PR named `<type>/<kebab-name>`. Run `git add`, `git commit` and `git push` as separate commands. Commit messages follow Conventional Commits and end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- In-game checks run on the Windows PC, on Retail and on Forever. Push the branch and hand the director the pull command; WoW does not run on the Mac.

## Test harness

Every logic test lives in `tools/test_options_logic.js` and runs with:

```bash
NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_logic.js
```

If fengari is missing: `npm install --prefix "$HOME/.cache/hs-test" fengari` (once, outside the repo). The script prints `N passed, M failed` and exits non-zero on any failure.

## File map

| File | Status | Responsibility |
|---|---|---|
| `options/OptionsPages.lua` | Create | Shared page and card vocabulary; `addon.RegisterModulePages` |
| `options/OptionsAssemble.lua` | Create | Chunking, validation, page building, dependent rows, More fold, card state store, load-time run |
| `tools/test_options_logic.js` | Create | Logic tests for the assembler and search |
| `HorizonSuite.toc` | Modify | Load the two new files |
| `options/OptionsSearch.lua` | Modify | Index assembled pages, keywords, `searchName`, cached index |
| `options/dashboard/DashboardUtil.lua` | Modify | Axis key check accepts `axis:` keys |
| `options/dashboard/DashboardAccordionCard.lua` | Modify | `SetExpandedInstant`, `onExpandedChanged` |
| `options/dashboard/DashboardAccordionBuild.lua` | Modify | Card ids and open state, indent, More row; later delete columns path |
| `options/dashboard/DashboardDetailView.lua` | Modify | Search navigation, reveal, page header buttons |
| `options/dashboard/DashboardFrame.lua` | Modify | Invalidate search index when the dashboard opens |
| `HorizonSuite.lua` | Modify | Invalidate search index when a module is toggled |
| `options/modules/*.lua` | Modify | Section tags and page registration, one task per module |
| `locales/horizon/*.lua` | Modify | New page, card and control strings |

## PRs

| PR | Branch | Tasks |
|---|---|---|
| 1 | `feature/options-page-assembler` | 1, 2 |
| 2 | `feature/options-card-behaviour` | 3, 4, 5 |
| 3 | `feature/options-search-coverage` | 6 |
| 4–10 | `refactor/options-retag-<module>` | 7 (Axis), 8 (Focus), 9 (Vista), 10 (Insight), 11 (Presence), 12 (Echo), 13 (Essence) |
| 11 | `refactor/options-retag-augment` | 14 |
| 12 | `refactor/options-assembler-strict` | 15 |

Each PR description is generated with `/pr`. Each player-visible PR (2, 3 and every retag) gets a before and after image via `/update-card` after merge.

---

### Task 1: Page vocabulary and test harness

**Files:**
- Create: `options/OptionsPages.lua`
- Create: `tools/test_options_logic.js`
- Modify: `HorizonSuite.toc:193` (add a line after `options/OptionsHelpers.lua`)
- Modify: `locales/horizon/enUS.lua` (add keys after `DASH_SEARCH_NO_RESULTS`, line 135)

**Interfaces:**
- Produces:
  - `addon.OptionsPages` table: `SHARED` (array of page keys), `SHARED_CARDS` (`[pageKey] = { cardKey, ... }`), `NAMES` (`[key] = localeKey`), `modules` (`[moduleKey] = { order = { pageKey, ... }, defs = { [pageKey] = def } }`).
  - `OptionsPages.IsShared(pageKey) -> boolean`, `OptionsPages.IsSharedCard(pageKey, cardKey) -> boolean`, `OptionsPages.Name(key) -> string`.
  - `addon.RegisterModulePages(moduleKey, defs)`: `defs` is an array of `{ key = string, name = string|nil, legacyKey, desc, icon, accentColor, enabledKey, getEnabled, setEnabled, hidden, dashboardPreviewMode, headerButtons, cardNames, allowEmpty }`. A def for a key already registered replaces the def but keeps its place in the order. Defs for shared page keys add fields without adding to `order`.
  - Test globals in the harness: `check(name, ok, got)`, `ROW(key, extra)`, `SEC(name, extra)`, `SHAPE(list)`, `PAGES(cats, moduleKey)`, `OPTS(cat)`, `FIND(cats, key)`, `WARNED(fragment)`, `RESET()`, `DB_VALUES`, `HorizonDB`.

- [ ] **Step 1: Create the test harness with the vocabulary tests**

Create `tools/test_options_logic.js`:

```js
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

// --- Summary -----------------------------------------------------------------------
run(`
  REAL_PRINT(PASS .. " passed, " .. FAIL .. " failed")
  if FAIL > 0 then error("options logic tests failed") end
`, 'summary');
```

Later tasks add their test blocks **above** the `// --- Summary` block.

- [ ] **Step 2: Run the harness to see it fail**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_logic.js`
Expected: exits 1 with `vocabulary: [string "vocabulary"]:...: attempt to index local 'P' (a nil value)`.

- [ ] **Step 3: Create `options/OptionsPages.lua`**

```lua
--[[
    Horizon Suite - Options - Page vocabulary
    The shared page and card names every module files its settings under, and the
    registry of each module's own pages. OptionsAssemble.lua reads both to build the
    dashboard pages. Must load after OptionsHelpers.lua and before any module options file.
]]
local addon = _G.HorizonSuite
if not addon then return end

local Pages = {
    -- Shared pages, in display order. Every module shows these first.
    SHARED = { "general", "layout", "look" },
    -- Shared cards for each shared page, in display order.
    SHARED_CARDS = {
        general = { "visibility", "behaviour" },
        layout  = { "position", "size" },
        look    = { "text", "colours", "background", "animation" },
    },
    -- Locale keys for shared page and card display names.
    NAMES = {
        general    = "PAGE_GENERAL",
        layout     = "PAGE_LAYOUT",
        look       = "PAGE_LOOK",
        visibility = "CARD_VISIBILITY",
        behaviour  = "CARD_BEHAVIOUR",
        position   = "CARD_POSITION",
        size       = "CARD_SIZE",
        text       = "CARD_TEXT",
        colours    = "CARD_COLOURS",
        background = "CARD_BACKGROUND",
        animation  = "CARD_ANIMATION",
    },
    -- [moduleKey] = { order = { pageKey, ... }, defs = { [pageKey] = def } }
    modules = {},
}
addon.OptionsPages = Pages

local sharedSet = {}
for _, k in ipairs(Pages.SHARED) do sharedSet[k] = true end

--- @param pageKey string
--- @return boolean
function Pages.IsShared(pageKey)
    return sharedSet[pageKey] == true
end

--- @param pageKey string
--- @param cardKey string
--- @return boolean
function Pages.IsSharedCard(pageKey, cardKey)
    for _, k in ipairs(Pages.SHARED_CARDS[pageKey] or {}) do
        if k == cardKey then return true end
    end
    return false
end

--- Localised display name for a shared page or card key.
--- @param key string
--- @return string
function Pages.Name(key)
    local localeKey = Pages.NAMES[key]
    return localeKey and addon.L[localeKey] or key
end

--- Declare a module's own pages (shown after the shared ones) and fields for any page.
--- A def whose key is a shared page adds fields to that page without reordering anything.
--- Registering a key again replaces its def and keeps its place in the order.
--- @param moduleKey string  "axis" for the Axis categories, which carry no moduleKey
--- @param defs table  Array of page defs: { key = string, name = string|nil, ... }
function addon.RegisterModulePages(moduleKey, defs)
    local m = Pages.modules[moduleKey]
    if not m then
        m = { order = {}, defs = {} }
        Pages.modules[moduleKey] = m
    end
    for _, def in ipairs(defs) do
        if not sharedSet[def.key] and not m.defs[def.key] then
            m.order[#m.order + 1] = def.key
        end
        m.defs[def.key] = def
    end
end
```

- [ ] **Step 4: Load it from the TOC**

In `HorizonSuite.toc`, after the line `options/OptionsHelpers.lua` add:

```
options/OptionsPages.lua
```

- [ ] **Step 5: Add the shared names to the locale**

In `locales/horizon/enUS.lua`, directly after the `L["DASH_SEARCH_NO_RESULTS"]` line, add (align `=` with the surrounding lines):

```lua
L["PAGE_GENERAL"]                                              = "General"
L["PAGE_LAYOUT"]                                               = "Layout"
L["PAGE_LOOK"]                                                 = "Look & Feel"
L["CARD_VISIBILITY"]                                           = "Visibility"
L["CARD_BEHAVIOUR"]                                            = "Behaviour"
L["CARD_POSITION"]                                             = "Position"
L["CARD_SIZE"]                                                 = "Size"
L["CARD_TEXT"]                                                 = "Text"
L["CARD_COLOURS"]                                              = "Colours"
L["CARD_BACKGROUND"]                                           = "Background & border"
L["CARD_ANIMATION"]                                            = "Animation"
L["DASH_MORE"]                                                 = "More (%d)"
L["DASH_LESS"]                                                 = "Less"
L["DASH_NEEDS_PARENT"]                                         = "Turn on %s to use this."
```

Then sync the other locales and check them:

Run: `node tools/restructure_locales.js`
Run: `git diff --stat locales/`
Expected: each non-English locale file changes by about 14 inserted lines (commented stubs). If any file shows hundreds of changed lines, run `git checkout -- locales/` except `enUS.lua`, and instead add the 14 keys by hand to each of `deDE`, `esES`, `frFR`, `koKR`, `ptBR`, `zhCN` as commented lines (`-- L["PAGE_GENERAL"] = "General"`) after their `DASH_SEARCH_NO_RESULTS` line.
Run: `node tools/locale_audit.js --strict`
Expected: exit 0.

- [ ] **Step 6: Run the harness**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_logic.js`
Expected: `12 passed, 0 failed`.

- [ ] **Step 7: Commit**

```bash
git add options/OptionsPages.lua tools/test_options_logic.js HorizonSuite.toc locales/horizon/
```
```bash
git commit -m "feat(axis): add shared options page vocabulary" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: The assembler

**Files:**
- Create: `options/OptionsAssemble.lua`
- Modify: `HorizonSuite.toc:221` (add a line after `options/modules/OptionsFocusIntegrations.lua`)
- Modify: `options/dashboard/DashboardUtil.lua:79-82`
- Test: `tools/test_options_logic.js`

**Interfaces:**
- Consumes: `addon.OptionsPages` and `addon.RegisterModulePages` (Task 1).
- Produces:
  - `addon.OptionsAssemble` table with `warnings` (array of strings), `strict` (boolean, default `false`), `revealId` (string|nil), `revealPending` (boolean).
  - `OptionsAssemble.Run(categories) -> categories`: assembled list; does not modify its input.
  - `OptionsAssemble.BuildPage(moduleKey, pageKey, chunks) -> optionList`.
  - `OptionsAssemble.ResetWarnings()`.
  - `OptionsAssemble.IsRevealed(row) -> boolean` (true when `row.dbKey == revealId`).
  - `OptionsAssemble.IsCardExpanded(cardId, isFirst) -> boolean`, `SetCardExpanded(cardId, expanded)`, `IsMoreOpen(cardId) -> boolean`, `SetMoreOpen(cardId, open)`.
  - Emitted page categories carry `key`, `name`, `moduleKey`, `pageKey`, `options` (always a function) plus the page fields from the def.
  - Emitted section rows carry `cardId`, `page`, `card`.

- [ ] **Step 1: Write the failing assembler tests**

Add above `// --- Summary` in `tools/test_options_logic.js`:

```js
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
```

- [ ] **Step 2: Run to see it fail**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_logic.js`
Expected: exits 1 with `assembler-pages: ... attempt to index local 'A' (a nil value)`.

- [ ] **Step 3: Create `options/OptionsAssemble.lua`**

```lua
--[[
    Horizon Suite - Options - Page assembler
    Turns the tagged sections every module registered into dashboard pages.
    A Section tagged `page = "<key>"` (and `card = "<key>"`) is filed under that page of
    its module; sections that share a card merge into one card. Pages come out shared
    first (OptionsPages.SHARED), then the module's own pages in RegisterModulePages order.
    The result is written back into addon.OptionCategories, so the sidebar, detail view,
    search and platform prune read assembled pages without knowing about tags.
    Categories with no tagged section pass through unchanged until `strict` is on.
    Must load after every module options file and before OptionsPlatform.lua.
]]
local addon = _G.HorizonSuite
if not addon or not addon.OptionsPages then return end

local Pages = addon.OptionsPages

local Assemble = {
    warnings = {},
    -- When true, a category with no tagged section is reported as a load-time error.
    strict = false,
    -- dbKey of a row search is jumping to; that row shows even when its parent or More hides it.
    revealId = nil,
    revealPending = false,
}
addon.OptionsAssemble = Assemble

-- Fields copied from a page def onto the emitted category.
local PAGE_FIELDS = {
    "desc", "icon", "accentColor", "enabledKey", "getEnabled", "setEnabled",
    "hidden", "dashboardPreviewMode", "headerButtons",
}

local seenWarnings = {}

local function Warn(msg)
    if seenWarnings[msg] then return end
    seenWarnings[msg] = true
    Assemble.warnings[#Assemble.warnings + 1] = msg
    print("|cffff5555Horizon Suite options:|r " .. msg)
end

--- Clear recorded warnings (tests only).
function Assemble.ResetWarnings()
    Assemble.warnings = {}
    seenWarnings = {}
end

local function Resolve(v)
    if type(v) == "function" then return v() end
    return v
end

local function Label(t)
    if type(t) ~= "table" then return "?" end
    return tostring(Resolve(t.name) or Resolve(t.searchName) or t.dbKey or "?")
end

local function Copy(t)
    local c = {}
    for k, v in pairs(t) do c[k] = v end
    return c
end

local function ModuleOf(cat)
    return cat.moduleKey or "axis"
end

local function HasCapability(req)
    if not req then return true end
    local P = addon.Platform
    return not (P and P.Has) or P.Has(req)
end

local function Both(a, b)
    if not a then return b end
    if not b then return a end
    return function() return a() and b() end
end

-- ---------------------------------------------------------------------------
-- Saved card state: open/closed and More open/closed, keyed by card id.
-- ---------------------------------------------------------------------------

local function Store(field)
    local db = addon.DATABASE and _G[addon.DATABASE]
    if type(db) ~= "table" then return nil end
    if type(db[field]) ~= "table" then db[field] = {} end
    return db[field]
end

--- @param cardId string
--- @param isFirst boolean  The card is the first on its page
--- @return boolean
function Assemble.IsCardExpanded(cardId, isFirst)
    local s = Store("optionsCardExpanded")
    local v = s and s[cardId]
    if v == nil then return isFirst == true end
    return v == true
end

--- @param cardId string
--- @param expanded boolean
function Assemble.SetCardExpanded(cardId, expanded)
    local s = Store("optionsCardExpanded")
    if s then s[cardId] = expanded and true or false end
end

--- @param cardId string
--- @return boolean
function Assemble.IsMoreOpen(cardId)
    local s = Store("optionsCardMoreOpen")
    return s ~= nil and s[cardId] == true
end

--- @param cardId string
--- @param open boolean
function Assemble.SetMoreOpen(cardId, open)
    local s = Store("optionsCardMoreOpen")
    if s then s[cardId] = open and true or false end
end

--- @param row table
--- @return boolean
function Assemble.IsRevealed(row)
    return Assemble.revealId ~= nil and row.dbKey == Assemble.revealId
end

-- ---------------------------------------------------------------------------
-- Chunks: an option list split into { section = <table>, rows = { ... } }.
-- ---------------------------------------------------------------------------

-- A category is tagged when any top-level section in it carries a page tag.
local function IsTagged(list)
    if type(list) ~= "table" then return false end
    for _, row in ipairs(list) do
        if type(row) == "table" and row.type == "section" and row.page then return true end
    end
    return false
end

-- A columns block is unwrapped: rows before a column's first nested section stay in the
-- enclosing chunk; each nested section opens its own chunk and inherits the enclosing
-- section's page (and its card, on a shared page).
local function Chunks(list, moduleKey, catKey)
    local out, cur = {}, nil
    for _, row in ipairs(list) do
        if row.type == "section" then
            cur = { section = row, rows = {} }
            out[#out + 1] = cur
        elseif not cur then
            Warn(("%s › %s: '%s' sits before the first section and was skipped"):format(moduleKey, tostring(catKey), Label(row)))
        elseif row.type == "columns" then
            local outer = cur
            for _, side in ipairs({ "left", "right" }) do
                local sideCur = outer
                local opts = (row[side] and row[side].options) or {}
                for _, inner in ipairs(opts) do
                    if inner.type == "section" then
                        local s = Copy(inner)
                        if not s.page then s.page = outer.section.page end
                        if not s.card and Pages.IsShared(s.page) then s.card = outer.section.card end
                        sideCur = { section = s, rows = {} }
                        out[#out + 1] = sideCur
                    else
                        sideCur.rows[#sideCur.rows + 1] = inner
                    end
                end
            end
            cur = outer
        else
            cur.rows[#cur.rows + 1] = row
        end
    end
    return out
end

local function Valid(moduleKey, chunk)
    local s = chunk.section
    local where = moduleKey .. " › " .. Label(s)
    local mod = Pages.modules[moduleKey]
    if not s.page then
        Warn(where .. ": section has no page tag; section skipped")
        return false
    end
    if not Pages.IsShared(s.page) and not (mod and mod.defs[s.page]) then
        Warn(where .. ": unknown page '" .. tostring(s.page) .. "'; section skipped")
        return false
    end
    if Pages.IsShared(s.page) and not s.card then
        Warn(where .. ": section on shared page '" .. s.page .. "' has no card tag; section skipped")
        return false
    end
    return HasCapability(s.requires)
end

local function ModuleChunks(moduleKey, sources)
    local all = {}
    for _, cat in ipairs(sources) do
        local list = Resolve(cat.options)
        if type(list) == "table" then
            for _, chunk in ipairs(Chunks(list, moduleKey, cat.key)) do
                if Valid(moduleKey, chunk) then all[#all + 1] = chunk end
            end
        end
    end
    return all
end

-- ---------------------------------------------------------------------------
-- Dependent rows: `parent = "<dbKey>"`, optional `parentIs`. Filled in by Task 3.
-- ---------------------------------------------------------------------------

local function ExpandParents(rows, moduleKey, pageKey)
end

-- ---------------------------------------------------------------------------
-- Page building
-- ---------------------------------------------------------------------------

--- Build one page's option list from a module's chunks.
--- @param moduleKey string
--- @param pageKey string
--- @param chunks table  From ModuleChunks
--- @return table  Option list: a section row per card, then its rows
function Assemble.BuildPage(moduleKey, pageKey, chunks)
    local mod = Pages.modules[moduleKey]
    local def = (mod and mod.defs[pageKey]) or {}
    local cards, order, auto = {}, {}, 0
    for _, chunk in ipairs(chunks) do
        local s = chunk.section
        if s.page == pageKey then
            local key = s.card
            if not key then
                auto = auto + 1
                key = "_" .. auto
            end
            local card = cards[key]
            if not card then
                card = { key = key, chunks = {} }
                cards[key] = card
                order[#order + 1] = key
            end
            if #card.chunks > 0 and s.headerToggle then
                Warn(("%s › %s: '%s' has a header switch, so it must be the first section in card '%s'; section skipped")
                    :format(moduleKey, pageKey, Label(s), key))
            else
                card.chunks[#card.chunks + 1] = chunk
            end
        end
    end

    local rank, seen = {}, {}
    for i, k in ipairs(Pages.SHARED_CARDS[pageKey] or {}) do rank[k] = i end
    for i, k in ipairs(order) do seen[k] = i end
    table.sort(order, function(a, b)
        local ra, rb = rank[a], rank[b]
        if ra and rb then return ra < rb end
        if ra or rb then return ra ~= nil end
        return seen[a] < seen[b]
    end)

    local out = {}
    for _, key in ipairs(order) do
        local card = cards[key]
        local cardId = moduleKey .. ":" .. pageKey .. ":" .. key
        local merged = #card.chunks > 1
        local first = card.chunks[1].section
        local header
        if merged then
            header = { type = "section", name = first.name, headerToggle = first.headerToggle, dbKey = first.dbKey }
        else
            header = Copy(first)
        end
        header.cardId, header.page, header.card = cardId, pageKey, key
        if rank[key] then
            header.name = Pages.Name(key)
        elseif def.cardNames and def.cardNames[key] then
            header.name = def.cardNames[key]
        end
        out[#out + 1] = header

        local normal, advanced = {}, {}
        for _, chunk in ipairs(card.chunks) do
            for _, row in ipairs(chunk.rows) do
                local r = Copy(row)
                -- A merged card has one header, so each section's own condition moves onto its rows.
                if merged and chunk.section.visibleWhen then
                    r.visibleWhen = Both(chunk.section.visibleWhen, r.visibleWhen)
                end
                if r.advanced then advanced[#advanced + 1] = r else normal[#normal + 1] = r end
            end
        end
        for _, r in ipairs(normal) do out[#out + 1] = r end
        -- Task 5 inserts the More row here; until then advanced rows follow the others.
        for _, r in ipairs(advanced) do out[#out + 1] = r end
    end

    ExpandParents(out, moduleKey, pageKey)
    return out
end

local function EmitModule(moduleKey, sources)
    local chunks = ModuleChunks(moduleKey, sources)
    local used = {}
    for _, c in ipairs(chunks) do used[c.section.page] = true end
    local mod = Pages.modules[moduleKey] or { order = {}, defs = {} }

    local pageOrder = {}
    for _, k in ipairs(Pages.SHARED) do pageOrder[#pageOrder + 1] = k end
    for _, k in ipairs(mod.order) do pageOrder[#pageOrder + 1] = k end

    local pages = {}
    for _, pageKey in ipairs(pageOrder) do
        local def = mod.defs[pageKey] or {}
        if used[pageKey] or def.allowEmpty then
            local page = {
                key = def.legacyKey or (moduleKey .. ":" .. pageKey),
                name = def.name or Pages.Name(pageKey),
                moduleKey = sources[1].moduleKey,
                pageKey = pageKey,
                options = function()
                    return Assemble.BuildPage(moduleKey, pageKey, ModuleChunks(moduleKey, sources))
                end,
            }
            for _, field in ipairs(PAGE_FIELDS) do
                if def[field] ~= nil then page[field] = def[field] end
            end
            pages[#pages + 1] = page
        end
    end
    return pages
end

--- Assemble a category list. A module's pages replace its tagged categories at the
--- position of the first one; untagged categories keep their place.
--- @param categories table
--- @return table
function Assemble.Run(categories)
    local tagged, sources, firstAt = {}, {}, {}
    for i, cat in ipairs(categories) do
        tagged[i] = IsTagged(Resolve(cat.options))
        if tagged[i] then
            local mk = ModuleOf(cat)
            if not sources[mk] then
                sources[mk] = {}
                firstAt[i] = mk
            end
            sources[mk][#sources[mk] + 1] = cat
        end
    end

    local out = {}
    for i, cat in ipairs(categories) do
        if firstAt[i] then
            for _, page in ipairs(EmitModule(firstAt[i], sources[firstAt[i]])) do
                out[#out + 1] = page
            end
        elseif not tagged[i] then
            if Assemble.strict then
                Warn(("%s › %s: page has no page tags"):format(ModuleOf(cat), tostring(cat.key)))
            end
            out[#out + 1] = cat
        end
    end
    return out
end

-- Assemble in place, so anything already holding the table sees the result.
if type(addon.OptionCategories) == "table" then
    local assembled = Assemble.Run(addon.OptionCategories)
    for i = #addon.OptionCategories, 1, -1 do addon.OptionCategories[i] = nil end
    for i, cat in ipairs(assembled) do addon.OptionCategories[i] = cat end
end
```

- [ ] **Step 4: Load it from the TOC**

In `HorizonSuite.toc`, after `options/modules/OptionsFocusIntegrations.lua` and before `options/OptionsPlatform.lua`, add:

```
options/OptionsAssemble.lua
```

- [ ] **Step 5: Let the Axis check accept assembled Axis pages**

In `options/dashboard/DashboardUtil.lua`, replace `addon.Dashboard_IsAxisCategoryKey` (lines 79-82) with:

```lua
-- Categories shown under the Axis hub (dashboard + search): the three legacy keys, plus any
-- assembled Axis page ("axis:<page>").
-- @param catKey string
-- @return boolean
function addon.Dashboard_IsAxisCategoryKey(catKey)
    if catKey == "Profiles" or catKey == "Modules" or catKey == "GlobalToggles" then return true end
    return type(catKey) == "string" and catKey:sub(1, 5) == "axis:"
end
```

- [ ] **Step 6: Run the tests**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_logic.js`
Expected: `50 passed, 0 failed` (12 vocabulary, 38 assembler).

- [ ] **Step 7: Check nothing changed in game**

No module is tagged yet, so every category passes through. Push the branch and ask the director to `/reload` on the Windows PC (Retail and Forever) and confirm: no red `Horizon Suite options:` lines in chat, and the sidebar shows the same pages as before.

- [ ] **Step 8: Commit**

```bash
git add options/OptionsAssemble.lua HorizonSuite.toc options/dashboard/DashboardUtil.lua tools/test_options_logic.js
```
```bash
git commit -m "feat(axis): assemble options pages from tagged sections" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

Open PR 1 (`feature/options-page-assembler`) with `/pr`.

---

### Task 3: Dependent rows

**Files:**
- Modify: `options/OptionsAssemble.lua` (the `ExpandParents` stub)
- Modify: `options/dashboard/DashboardAccordionBuild.lua:140` (row x offset) and the `tinsert(currentCard.widgetList, ...)` call (around line 1263)
- Test: `tools/test_options_logic.js`

**Interfaces:**
- Consumes: `Assemble.BuildPage`, `Assemble.IsRevealed` (Task 2).
- Produces: rows may declare `parent = "<dbKey>"` and `parentIs = <value|false|function(v)>`. After assembly such a row has `indent = true`, a `visibleWhen`, a `disabled` function and a tooltip naming its parent, and its parent row's `refreshIds` lists the child's `dbKey`.

- [ ] **Step 1: Write the failing tests**

Add above `// --- Summary`:

```js
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
```

- [ ] **Step 2: Run to see it fail**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_logic.js`
Expected: exits 1; output includes `FAIL: child of an on toggle shows  got: false` (the stub leaves `visibleWhen` nil, so the call errors). Either an error or FAIL lines are acceptable here.

- [ ] **Step 3: Implement `ExpandParents`**

Replace the stub in `options/OptionsAssemble.lua` with:

```lua
local function ParentMatches(parentRow, row)
    local v
    if parentRow.get then v = parentRow.get() end
    local want = row.parentIs
    if type(want) == "function" then return want(v) and true or false end
    if want == nil then return v and true or false end
    if type(want) == "boolean" then return (v and true or false) == want end
    return v == want
end

local function IsTrue(fnOrBool)
    if type(fnOrBool) == "function" then return fnOrBool() and true or false end
    return fnOrBool == true
end

-- Rows are copies made by BuildPage, so wiring them here never touches a module's tables.
local function ExpandParents(rows, moduleKey, pageKey)
    local byKey = {}
    for _, r in ipairs(rows) do
        if r.dbKey then byKey[r.dbKey] = r end
    end
    for _, r in ipairs(rows) do
        if r.parent then
            local p = byKey[r.parent]
            if not p then
                Warn(("%s › %s: '%s' depends on '%s', which is not on this page"):format(moduleKey, pageKey, Label(r), tostring(r.parent)))
            elseif not r.dbKey then
                Warn(("%s › %s: '%s' has a parent but no dbKey"):format(moduleKey, pageKey, Label(r)))
            else
                local child, ownVisible, ownDisabled = r, r.visibleWhen, r.disabled
                local function match() return ParentMatches(p, child) end
                r.indent = true
                r.visibleWhen = function()
                    if ownVisible and not ownVisible() then return false end
                    return match() or Assemble.IsRevealed(child)
                end
                r.disabled = function()
                    if IsTrue(ownDisabled) then return true end
                    return not match()
                end
                local hint = addon.L["DASH_NEEDS_PARENT"]:format(Label(p))
                local tip = r.tooltip
                if type(tip) == "function" then
                    r.tooltip = function() return tip() .. "\n\n" .. hint end
                elseif tip and tip ~= "" then
                    r.tooltip = tip .. "\n\n" .. hint
                else
                    r.tooltip = hint
                end
                local ids = {}
                for _, id in ipairs(p.refreshIds or {}) do ids[#ids + 1] = id end
                ids[#ids + 1] = r.dbKey
                p.refreshIds = ids
            end
        end
    end
end
```

- [ ] **Step 4: Run the tests**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_logic.js`
Expected: `65 passed, 0 failed`.

- [ ] **Step 5: Indent dependent rows in the card**

In `options/dashboard/DashboardAccordionBuild.lua`, in `DoInstantRelayout` replace line 140:

```lua
                    entry.frame:SetPoint("TOPLEFT", card.settingsContainer, "TOPLEFT", 30, -(yOff + topGap))
```

with:

```lua
                    local rowX = entry.indent and 50 or 30
                    entry.frame:SetPoint("TOPLEFT", card.settingsContainer, "TOPLEFT", rowX, -(yOff + topGap))
```

In the `if widget then` attach block near the end of the build loop, replace the `tinsert(currentCard.widgetList, { ... })` call with:

```lua
                    -- Dependent rows sit indented under their parent with a thin accent line.
                    if opt.indent and not widget._indentBar then
                        local bar = widget:CreateTexture(nil, "ARTWORK")
                        bar:SetWidth(2)
                        bar:SetPoint("TOPLEFT", widget, "TOPLEFT", -12, -2)
                        bar:SetPoint("BOTTOMLEFT", widget, "BOTTOMLEFT", -12, 2)
                        local ar, ag, ab = accordionCardParams.GetAccentColor()
                        bar:SetColorTexture(ar, ag, ab, 0.55)
                        widget._indentBar = bar
                    end

                    tinsert(currentCard.widgetList, {
                        frame = widget,
                        isHeader = isHeader,
                        indent = opt.indent,
                        visibleWhen = (opt.type == "moduleReloadPrompt" and function() return addon._moduleReloadRecommended end) or opt.visibleWhen,
                    })
```

- [ ] **Step 6: Commit**

```bash
git add options/OptionsAssemble.lua options/dashboard/DashboardAccordionBuild.lua tools/test_options_logic.js
```
```bash
git commit -m "feat(axis): hide and indent settings until their parent applies" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: Cards remember whether they are open

**Files:**
- Modify: `options/dashboard/DashboardAccordionCard.lua` (headerBtn `OnClick`, before `return card`)
- Modify: `options/dashboard/DashboardAccordionBuild.lua` (section branch around line 397; end of `BuildAccordionDetail` around line 1283)
- Modify: `options/modules/OptionsFocus.lua:668,675,711,715`, `options/modules/OptionsVista.lua:417,524` (drop `defaultCollapsed`)

**Interfaces:**
- Consumes: `Assemble.IsCardExpanded`, `Assemble.SetCardExpanded` (Task 2); `cardId` on emitted sections.
- Produces: `card.SetExpandedInstant(expanded)`, `card.onExpandedChanged(expanded)` callback, `card.cardId`.

- [ ] **Step 1: Add instant open and a change callback to the card**

In `options/dashboard/DashboardAccordionCard.lua`, replace the `headerBtn:SetScript("OnClick", ...)` block with:

```lua
    headerBtn:SetScript("OnClick", function()
        -- Block expand when a header toggle exists and is disabled
        if card.headerToggleEnabled and not card.headerToggleEnabled() then return end
        if card.anim:IsPlaying() then return end
        card.expanded = not card.expanded
        updateExpandedVisuals()
        card.anim:Play()
        if card.onExpandedChanged then card.onExpandedChanged(card.expanded) end
    end)

    --- Open or close without animation (a page opening with a remembered state).
    --- @param expanded boolean
    function card.SetExpandedInstant(expanded)
        expanded = expanded and true or false
        card.expanded = expanded
        card:SetHeight(expanded and (card.fullHeight or card.collapsedHeight) or card.collapsedHeight)
        sc:SetAlpha(expanded and 1 or 0)
        updateExpandedVisuals()
        UpdateDetailLayout()
    end
```

- [ ] **Step 2: Record the card id when a section opens a card**

In `options/dashboard/DashboardAccordionBuild.lua`, in the `if opt.type == "section" then` branch, after `currentCard.visibleWhen = opt.visibleWhen`, add:

```lua
                currentCard.cardId = opt.cardId
```

- [ ] **Step 3: Apply the open state after the cards are built**

In the same file, after the final `if currentCard then RelayoutCard(currentCard) end` and before `UpdateDetailLayout()`, add:

```lua
        -- Open state on assembled pages: the first card opens by default and a remembered
        -- state wins. Cards with a header switch follow their switch instead.
        local Assemble = addon.OptionsAssemble
        if Assemble then
            local firstDone = false
            for _, card in ipairs(currentDetailCards) do
                if card.cardId and not card.headerToggleEnabled then
                    local isFirst = not firstDone
                    firstDone = true
                    card.SetExpandedInstant(Assemble.IsCardExpanded(card.cardId, isFirst))
                    local id = card.cardId
                    card.onExpandedChanged = function(expanded) Assemble.SetCardExpanded(id, expanded) end
                end
            end
        end
```

- [ ] **Step 4: Delete the dead `defaultCollapsed` flag**

`defaultCollapsed` is never read (`git grep -n defaultCollapsed options/dashboard` returns nothing). Make these edits:

- `options/modules/OptionsFocus.lua:668`: `Section(L["FOCUS_MYTHIC_TYPOGRAPHY"], { requires = "mythicPlus", defaultCollapsed = true })` → `Section(L["FOCUS_MYTHIC_TYPOGRAPHY"], { requires = "mythicPlus" })`
- `:675`: `Section(L["MYTHIC_COLOURS"], { requires = "mythicPlus", defaultCollapsed = true })` → `Section(L["MYTHIC_COLOURS"], { requires = "mythicPlus" })`
- `:711`: `Section(L["FOCUS_RUN_TYPOGRAPHY"], { defaultCollapsed = true })` → `Section(L["FOCUS_RUN_TYPOGRAPHY"])`
- `:715`: `Section(L["FOCUS_RUN_COLOURS"], { defaultCollapsed = true })` → `Section(L["FOCUS_RUN_COLOURS"])`
- `options/modules/OptionsVista.lua:417`: `Section(L["VISTA_PER_DIFFICULTY_COLOURS"], { defaultCollapsed = true })` → `Section(L["VISTA_PER_DIFFICULTY_COLOURS"])`
- `:524`: `Section(L["VISTA_CLOSE_FADE_TIMING"], { defaultCollapsed = true })` → `Section(L["VISTA_CLOSE_FADE_TIMING"])`

Run: `git grep -n defaultCollapsed`
Expected: no output.

- [ ] **Step 5: Run the tests**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_logic.js`
Expected: `65 passed, 0 failed` (the store tests from Task 2 cover the state rules).

- [ ] **Step 6: Commit**

```bash
git add options/dashboard/DashboardAccordionCard.lua options/dashboard/DashboardAccordionBuild.lua options/modules/OptionsFocus.lua options/modules/OptionsVista.lua
```
```bash
git commit -m "feat(axis): open the first card and remember card state" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 5: The More fold

**Files:**
- Modify: `options/OptionsAssemble.lua` (`BuildPage`, the advanced-row loop)
- Modify: `options/dashboard/DashboardAccordionBuild.lua` (type dispatch chain starting `if opt.type == "binary" or opt.type == "toggle" then`, around line 434; the `optId` computation around line 420)
- Test: `tools/test_options_logic.js`

**Interfaces:**
- Consumes: `Assemble.IsMoreOpen`, `Assemble.SetMoreOpen`, `Assemble.IsRevealed` (Task 2).
- Produces: rows with `advanced = true` follow a `{ type = "moreToggle", cardId = string, count = number }` row and show only while that card's More is open (or the row is revealed by search).

- [ ] **Step 1: Write the failing tests**

Add above `// --- Summary`:

```js
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
```

- [ ] **Step 2: Run to see it fail**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_logic.js`
Expected: `FAIL: advanced rows follow a More row  got: S:CARD_POSITION|lock|S:CARD_SIZE|a|b|adv1|adv2`, then an error on `more.cardId` (nil). Exit 1.

- [ ] **Step 3: Emit the More row**

In `Assemble.BuildPage`, replace:

```lua
        for _, r in ipairs(normal) do out[#out + 1] = r end
        -- Task 5 inserts the More row here; until then advanced rows follow the others.
        for _, r in ipairs(advanced) do out[#out + 1] = r end
```

with:

```lua
        for _, r in ipairs(normal) do out[#out + 1] = r end
        if #advanced > 0 then
            out[#out + 1] = { type = "moreToggle", cardId = cardId, count = #advanced }
            for _, r in ipairs(advanced) do
                local row, own = r, r.visibleWhen
                r.visibleWhen = function()
                    if own and not own() then return false end
                    return Assemble.IsMoreOpen(cardId) or Assemble.IsRevealed(row)
                end
                out[#out + 1] = r
            end
        end
```

- [ ] **Step 4: Run the tests**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_logic.js`
Expected: `70 passed, 0 failed`.

- [ ] **Step 5: Render the More row**

In `options/dashboard/DashboardAccordionBuild.lua`, change the start of the `optId` expression so the More row is not tracked as a setting:

```lua
                local optId = opt.type ~= "moduleReloadPrompt" and opt.type ~= "moreToggle" and (
```

Then add a branch to the type dispatch chain, directly before `elseif opt.type == "header" then`:

```lua
                elseif opt.type == "moreToggle" then
                    local cardRef, cardId, count = currentCard, opt.cardId, opt.count
                    local Assemble = addon.OptionsAssemble
                    local row = CreateFrame("Button", nil, currentCard.settingsContainer)
                    row:SetHeight(24)
                    local label = MakeText(row, "", 12, 0.44, 0.63, 0.94, "LEFT")
                    label:SetPoint("LEFT", row, "LEFT", 0, 0)
                    local function Paint()
                        local open = Assemble and Assemble.IsMoreOpen(cardId)
                        label:SetText(open and L["DASH_LESS"] or L["DASH_MORE"]:format(count))
                    end
                    Paint()
                    row.Refresh = Paint
                    row:SetScript("OnClick", function()
                        if not Assemble then return end
                        Assemble.SetMoreOpen(cardId, not Assemble.IsMoreOpen(cardId))
                        Paint()
                        RelayoutCard(cardRef, true)
                    end)
                    widget = row
```

- [ ] **Step 6: Commit**

```bash
git add options/OptionsAssemble.lua options/dashboard/DashboardAccordionBuild.lua tools/test_options_logic.js
```
```bash
git commit -m "feat(axis): fold advanced settings behind a More row" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

- [ ] **Step 7: In-game check for PR 2**

Nothing is tagged yet, so the visible changes are limited to: cards on untagged pages behave as before (no card ids), and the Focus and Vista sections that had `defaultCollapsed` still open and close. Push and ask the director to `/reload` on Retail and Forever and confirm no red `Horizon Suite options:` lines and no Lua errors when opening Focus → Instances and Vista → Appearance. The indent, first-card and More behaviour is exercised in Task 7 onwards, once Axis is tagged.

Open PR 2 (`feature/options-card-behaviour`) with `/pr`.

---

### Task 6: Search covers every setting

**Files:**
- Modify: `options/OptionsSearch.lua` (`OptionsData_SearchEntryScore`, `OptionsData_BuildSearchIndex`)
- Modify: `options/dashboard/DashboardDetailView.lua` (`NavigateToOption` around line 322; start of `f.OpenCategoryDetail` around line 1006)
- Modify: `options/dashboard/DashboardFrame.lua:1326` (dashboard `OnShow` hook)
- Modify: `HorizonSuite.lua:123` (`addon:SetModuleEnabled`)
- Test: `tools/test_options_logic.js`

**Interfaces:**
- Consumes: assembled pages with `cardId` on sections (Task 2); `Assemble.revealId`, `revealPending`, `SetMoreOpen`, `SetCardExpanded`.
- Produces:
  - Index entries gain `cardId` and `searchTokensKeywords`.
  - Rows may carry `keywords = { "<locale string>", ... }` and, for unnamed special widgets, `searchName`.
  - `OptionsData_BuildSearchIndex()` returns a cached index; `addon.OptionsSearch_Invalidate()` clears it.

- [ ] **Step 1: Write the failing tests**

Add above `// --- Summary`:

```js
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
  check("More row is not a result", by["F_"] == nil and #idx == 6, #idx)
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
```

- [ ] **Step 2: Run to see it fail**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_logic.js`
Expected: exit 1 with `search: ... attempt to call field 'OptionsSearch_Invalidate' (a nil value)`.

- [ ] **Step 3: Score keywords**

In `options/OptionsSearch.lua`, in `OptionsData_SearchEntryScore`, add one line after `bump(entry.searchTokensName, 1000, 700)`:

```lua
        bump(entry.searchTokensKeywords, 450, 320)
```

and update the doc comment above it to read `Higher = better (name > keywords > section > category > module > option id > desc).`

- [ ] **Step 4: Rebuild the index over assembled pages, with a cache**

Replace the whole `function OptionsData_BuildSearchIndex() ... end` with:

```lua
-- Row types that are layout, not settings, and never appear as results.
local NOT_SEARCHABLE = { section = true, header = true, moduleReloadPrompt = true, moreToggle = true }

local function ResolveText(v)
    if type(v) == "function" then return v() end
    return v
end

local function BuildSearchIndexUncached()
    local index = {}
    local L = addon.L
    local cats = addon.OptionCategories or {}
    for catIdx, cat in ipairs(cats) do
        local currentSection, currentCardId = "", nil
        local moduleKey = cat.moduleKey
        local moduleLabel
        if addon.Dashboard_IsAxisCategoryKey and addon.Dashboard_IsAxisCategoryKey(cat.key) then
            moduleLabel = addon.BrandModule and addon.BrandModule("axis") or "Axis"
        else
            moduleLabel = addon.BrandModule and addon.BrandModule(moduleKey) or (L and L["MODULES"])
        end
        local catNameStr = tostring(ResolveText(cat.name) or "")
        local catNameLower = catNameStr:lower()
        local catOpts = ResolveText(cat.options) or {}
        for _, opt in ipairs(catOpts) do
            if opt.type == "section" then
                currentSection = ResolveText(opt.name) or ""
                currentCardId = opt.cardId
            elseif not NOT_SEARCHABLE[opt.type] then
                local rawName = ResolveText(opt.name) or ResolveText(opt.searchName)
                local name = (rawName or ""):lower()
                local rawDesc, rawTooltip = ResolveText(opt.desc), ResolveText(opt.tooltip)
                local desc = ((rawDesc or "") .. " " .. (rawTooltip or "")):lower()
                local keywords = {}
                for _, k in ipairs(opt.keywords or {}) do keywords[#keywords + 1] = tostring(ResolveText(k) or "") end
                local keywordText = table.concat(keywords, " "):lower()
                local sectionLower = (currentSection or ""):lower()
                local moduleLower = (moduleLabel or ""):lower()
                local searchText = name .. " " .. keywordText .. " " .. desc .. " " .. sectionLower .. " " .. moduleLower
                local optionId = opt.dbKey or (cat.key .. "_" .. (rawName or ""):gsub("%s+", "_"))
                local idForTokens = tostring(optionId or ""):lower():gsub("_+", " ")
                index[#index + 1] = {
                    categoryKey = cat.key,
                    categoryName = cat.name,
                    categoryIndex = catIdx,
                    moduleKey = moduleKey,
                    moduleLabel = moduleLabel,
                    sectionName = currentSection,
                    cardId = currentCardId,
                    option = opt,
                    optionId = optionId,
                    searchText = searchText,
                    searchTokensName = TokenizeSearchCorpus(name),
                    searchTokensKeywords = TokenizeSearchCorpus(keywordText),
                    searchTokensDesc = TokenizeSearchCorpus(desc),
                    searchTokensSection = TokenizeSearchCorpus(sectionLower),
                    searchTokensModule = TokenizeSearchCorpus(moduleLower),
                    searchTokensCategory = TokenizeSearchCorpus(catNameLower),
                    searchTokensOptionId = TokenizeSearchCorpus(idForTokens),
                }
            end
        end
    end
    return index
end

local cachedIndex

--- The search index over every assembled page. Built once and reused until
--- addon.OptionsSearch_Invalidate() (dashboard opened, module toggled).
--- @return table
function OptionsData_BuildSearchIndex()
    if not cachedIndex then cachedIndex = BuildSearchIndexUncached() end
    return cachedIndex
end

--- Drop the cached index so the next search rebuilds it.
function addon.OptionsSearch_Invalidate()
    cachedIndex = nil
end
```

- [ ] **Step 5: Run the tests**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_logic.js`
Expected: `81 passed, 0 failed`.

- [ ] **Step 6: Invalidate when the dashboard opens and when a module toggles**

In `options/dashboard/DashboardFrame.lua`, inside the `f:HookScript("OnShow", function()` at line 1326, add as the first statement:

```lua
                if addon.OptionsSearch_Invalidate then addon.OptionsSearch_Invalidate() end
```

In `HorizonSuite.lua`, as the first statement inside `function addon:SetModuleEnabled(key, enabled, opts)`, add:

```lua
    if self.OptionsSearch_Invalidate then self.OptionsSearch_Invalidate() end
```

- [ ] **Step 7: Land search hits on the right card, fold and row**

In `options/dashboard/DashboardDetailView.lua`, at the very start of `f.OpenCategoryDetail` (before `if searchBox then searchBox:ClearFocus() end`), add:

```lua
        -- A search jump reveals its row for this one page; any other navigation clears it.
        local Assemble = addon.OptionsAssemble
        if Assemble then
            if Assemble.revealPending then Assemble.revealPending = false else Assemble.revealId = nil end
        end
```

In `NavigateToOption`, directly after `if targetCat then`, add:

```lua
            local Assemble = addon.OptionsAssemble
            if Assemble then
                Assemble.revealId = entry.optionId
                Assemble.revealPending = true
                if entry.cardId then
                    Assemble.SetCardExpanded(entry.cardId, true)
                    if entry.option and entry.option.advanced then Assemble.SetMoreOpen(entry.cardId, true) end
                end
            end
```

Then replace the `C_Timer.After(0.1, function() ... end)` block with:

```lua
            -- Cards are built synchronously; wait one frame so their positions are laid out.
            C_Timer.After(0, function()
                for _, card in ipairs(currentDetailCards) do
                    local hit = (entry.cardId and card.cardId == entry.cardId)
                        or (card.optionIds and card.optionIds[entry.optionId])
                    if hit then
                        if not card.expanded then
                            card.expanded = true
                            card.anim:Play()
                        end
                        local _, _, _, _, yOffset = card:GetPoint()
                        local frameH = detailScroll:GetHeight() or 0
                        local maxScroll = math.max(0, detailContent:GetHeight() - frameH)
                        local targetScroll = math.max(0, math.min(maxScroll, math.abs(yOffset or 0) - 20))
                        detailScroll:SetVerticalScroll(targetScroll)
                        break
                    end
                end
            end)
```

The `SetCardExpanded` call above means a card opened by search opens straight away when the page builds (Task 4 reads the stored state), so the `card.anim:Play()` branch only runs for untagged pages.

- [ ] **Step 8: Commit**

```bash
git add options/OptionsSearch.lua options/dashboard/DashboardDetailView.lua options/dashboard/DashboardFrame.lua HorizonSuite.lua tools/test_options_logic.js
```
```bash
git commit -m "feat(axis): search every setting and land on its card" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

- [ ] **Step 9: In-game check for PR 3**

Push and ask the director to check on Retail and Forever:
1. Search "opacity": results include Augment toast opacity (inside a columns block, previously missing).
2. Typing quickly shows no hitch (index built once per dashboard open).
3. Turning a module on or off, then searching, shows that module's settings appear or disappear.

Open PR 3 (`feature/options-search-coverage`) with `/pr`.

---

## Retag tasks (7–14)

Every retag task follows the same steps; the per-module table says what each section gets.

**How to tag:**
- `Section(L["X"])` becomes `Section(L["X"], { page = "<page>", card = "<card>" })`. If it already has an opts table, add the two fields to it.
- `{ type = "section", name = L["X"] }` gains `page = "<page>", card = "<card>"`.
- "card —" in a table means: leave `card` out (the section becomes its own card on a module page).
- "split" rows in a table give the new sections to insert and the rows (by name key) that move into each. Cut and paste whole row table literals; never edit them.
- Category-level fields named in a table move from the category table into the module's `RegisterModulePages` def. The category table keeps `key`, `name`, `moduleKey` and `options`.

**Shared verification for each retag task** (run after tagging, before committing):

1. `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_logic.js` still passes.
2. `node tools/locale_audit.js --strict` exits 0 (when the task adds locale keys).
3. Push and ask the director to check on the Windows PC, Retail then Forever:
   - `/reload` prints no red `Horizon Suite options:` line.
   - The module's sidebar group lists exactly the pages in the task's "Expected pages" line, in that order.
   - Every card named in the task's table appears on its page, and the first card on each page is open.
   - Close a card, `/reload`, reopen the page: the card is still closed.
   - Search one setting from each page: the result shows `Module > Page > Card` and opens that card.
   - On Forever, cards tagged with `requires` (Mythic+, housing, adventure guide) stay absent.

**Commit and PR for each retag task:** stage only the files the task lists, commit with the message in the task, push, and open the PR with `/pr`.

---

### Task 7: Retag Axis

**Files:**
- Modify: `options/modules/OptionsAxis.lua` (lines 13-60, 216, 327)
- Modify: `options/modules/OptionsGlobal.lua` (lines 18-40, 237, 335, 371, 461, 495)

**Interfaces:**
- Consumes: `addon.RegisterModulePages` (Task 1). Axis categories have no `moduleKey`, so their module key is `"axis"`.

- [ ] **Step 1: Register the Axis pages**

At the top of `options/modules/OptionsAxis.lua`, after the file's local declarations and before the category list, add:

```lua
-- Axis pages: General keeps the Modules key and Look & Feel keeps GlobalToggles, so
-- Welcome links and Dashboard_IsAxisCategoryKey keep working.
addon.RegisterModulePages("axis", {
    { key = "general", legacyKey = "Modules" },
    { key = "look", legacyKey = "GlobalToggles", desc = L["AXIS_SUITE_WIDE_CLASS_COLOUR_TINTING_UI"] },
    { key = "profiles", name = L["PROFILES"], legacyKey = "Profiles", desc = L["MANAGE_SWITCH_BETWEEN_YOUR_ADDON_CONFIGURATIONS"] },
})
```

The descriptions are the ones on the `GlobalToggles` (`OptionsGlobal.lua:20`) and `Profiles` (`OptionsAxis.lua:41`) categories; `Modules` has none. The Layout page needs no def; it gets the key `axis:layout`.

- [ ] **Step 2: Tag the sections**

| File:line | Section | page | card |
|---|---|---|---|
| `OptionsAxis.lua:26` | `MODULE_TOGGLES` | `general` | `modules` |
| `OptionsAxis.lua:58` | `PROFILES` | `profiles` | — |
| `OptionsAxis.lua:216` | `AXIS_SPEC_PROFILES` | `profiles` | — |
| `OptionsAxis.lua:327` | `AXIS_SHARING` | `profiles` | — |
| `OptionsGlobal.lua:39` | `AXIS_DASHBOARD_SECTION` | `look` | `dashboard` |
| `OptionsGlobal.lua:237` | `AXIS_CLASS_THEME_SECTION` | `look` | `colours` |
| `OptionsGlobal.lua:335` | `AXIS_GLOBAL_FONT_SECTION` | `look` | `text` |
| `OptionsGlobal.lua:371` | `AXIS_GLOBAL_SCALE_SECTION` | `layout` | `size` |
| `OptionsGlobal.lua:461` | `AXIS_MINIMAP_ICON_SECTION` | `general` | `minimapIcon` |
| `OptionsGlobal.lua:495` | `AXIS_GAME_MENU_SECTION` | `general` | `behaviour` |

Expected pages: General · Layout · Look & Feel · Profiles.

- [ ] **Step 3: Verify** (shared verification above). Also check: the Welcome screen's "Open module toggles", "Dashboard background" and "Class colours" links each open the right card.

- [ ] **Step 4: Commit**

```bash
git add options/modules/OptionsAxis.lua options/modules/OptionsGlobal.lua
```
```bash
git commit -m "refactor(axis): file Axis settings under the shared pages" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 8: Retag Focus

**Files:**
- Modify: `options/modules/OptionsFocus.lua`
- Modify: `options/modules/OptionsFocusIntegrations.lua:132-142,541`
- Modify: `locales/horizon/enUS.lua` (one key)

- [ ] **Step 1: Register the Focus pages**

In `options/modules/OptionsFocus.lua`, before the `local categories = {` table, add:

```lua
addon.RegisterModulePages("focus", {
    { key = "tracked", name = L["FOCUS_PAGE_TRACKED"] },
    { key = "instances", name = L["FOCUS_INSTANCES"], desc = L["CONTROL_TRACKER_VISIBILITY_WITHIN_DUNGEONS_RAIDS"] },
})
```

In `options/modules/OptionsFocusIntegrations.lua`, before `addon.OptionCategories[#addon.OptionCategories + 1] = {` (line 131), add:

```lua
addon.RegisterModulePages("focus", {
    { key = "integrations", name = L["FOCUS_INTEGRATION"], desc = L["FOCUS_INTEGRATION_DESC"],
      hidden = function() return not RareScannerIntegrationLoaded() and not SilverDragonIntegrationLoaded() end },
})
```

and delete the category's `hidden = ...` line (line 138) and its comment.

Add to `locales/horizon/enUS.lua` after `L["DASH_NEEDS_PARENT"]`:

```lua
L["FOCUS_PAGE_TRACKED"]                                        = "What's tracked"
```

then run `node tools/restructure_locales.js`.

- [ ] **Step 2: Give the sectionless pages a section**

The `Colors` and `HiddenQuests` categories have a single special widget and no section. Make their `options` lists start with a section:

```lua
        options = {
            Section(L["DASH_COLOURS"], { page = "look", card = "colours" }),
            { type = "colorMatrixFull", name = L["DASH_COLOURS"], dbKey = "colorMatrix" },
        },
```

```lua
        options = {
            Section(L["FOCUS_HIDDEN_QUESTS"], { page = "tracked" }),
            { type = "blacklistGrid", name = L["FOCUS_BLACKLISTED_QUESTS"], desc = L["FOCUS_QUESTS_HIDDEN_RIGHT_CLICK_UNTRACK"], tooltip = L["ENABLE_BLACKLIST_UNTRACKED_INTERACTIONS_ADD_QUEST"] },
        },
```

- [ ] **Step 3: Tag the sections**

| Line | Section | page | card |
|---|---|---|---|
| 210 | `VISTA_POSITION_LAYOUT` | `layout` | `position` |
| 216 | `FOCUS_DIMENSIONS` | `layout` | `size` |
| 223 | `FOCUS_SPACING` | `layout` | `size` |
| 332 | `DASH_FRAME` | `look` | `background` |
| 341 | `VISIBILITY_FADING` | `general` | `visibility` |
| 346 | `FOCUS_HEADER` | `look` | `header` |
| 355 | `FOCUS_SECTIONS_STRUCTURE` | `look` | `sections` |
| 361 | `FOCUS_ENTRY_DETAILS` | `tracked` | — |
| 379 | `FOCUS_PROGRESS_TIMERS` | `tracked` | — |
| 405 | `FOCUS_EMPHASIS` | `look` | `emphasis` |
| 420 | `DASH_CLICK_OPTIONS` | `general` | `behaviour` |
| 528 | `FOCUS_CLICK_SAFETY` | `general` | `behaviour` |
| 539 | `FOCUS_FILTERING` | `tracked` | — |
| 542 | `GROUPING` | `tracked` | — |
| 569 | `FOCUS_SORTING` | `tracked` | — |
| 580 | `FOCUS_FONT_FAMILIES` | `look` | `text` |
| 590 | `FOCUS_FONT_SIZES` | `look` | `text` |
| 601 | `FOCUS_TEXT_CASE` | `look` | `text` |
| 605 | `FOCUS_SHADOW` | `look` | `text` |
| 618 | `QUEST_TRACKING` | `general` | `behaviour` |
| 622 | `NAME_TOMTOM` | `general` | `tomtom` |
| 633 | `FOCUS_ANIMATIONS` | `look` | `animation` |
| 635 | `OBJECTIVE_PROGRESS` | `look` | `animation` |
| 647 | `DASH_VISIBILITY` | `instances` | — |
| 660 | `MYTHIC_BLOCK` (keeps `requires`) | `instances` | — |
| 668 | `FOCUS_MYTHIC_TYPOGRAPHY` (keeps `requires`) | `instances` | — |
| 675 | `MYTHIC_COLOURS` (keeps `requires`) | `instances` | — |
| 704 | `FOCUS_RUN_TRACKER` | `instances` | — |
| 711 | `FOCUS_RUN_TYPOGRAPHY` | `instances` | — |
| 715 | `FOCUS_RUN_COLOURS` | `instances` | — |
| 731 | `FOCUS_DELVES_DUNGEONS` | `instances` | — |
| 736 | `FOCUS_SCENARIO_BAR` | `instances` | — |
| 746 | `FOCUS_WORLD_QUESTS` | `tracked` | — |
| 748 | `FOCUS_RARE_BOSSES` | `tracked` | — |
| 754 | `FOCUS_ACHIEVEMENTS` | `tracked` | — |
| 761 | `FOCUS_ENDEAVORS` (keeps `requires`) | `tracked` | — |
| 764 | `FOCUS_DECOR` (keeps `requires`) | `tracked` | — |
| 767 | `FOCUS_APPEARANCES` | `tracked` | — |
| 772 | `RECIPES` | `tracked` | — |
| 785 | `FOCUS_ADVENTURE_GUIDE` (keeps `requires`) | `tracked` | — |
| 788 | `FOCUS_FLOATING_QUEST_ITEM` | `tracked` | — |
| `OptionsFocusIntegrations.lua:142` | `FOCUS_INTEGRATION_RARESCANNER` (keeps `visibleWhen`) | `integrations` | — |
| `OptionsFocusIntegrations.lua:541` | `FOCUS_INTEGRATION_SILVERDRAGON` (keeps `visibleWhen`) | `integrations` | — |

If any of these sections carries a `headerToggle` and lands in a card with an earlier section, the load prints a red line naming it; give that section its own card key instead (for example `card = "spacing"` for `FOCUS_SPACING`) and note it in the PR.

Expected pages: General · Layout · Look & Feel · What's tracked · Instances · Integrations (Integrations only when RareScanner or SilverDragon is installed).

- [ ] **Step 4: Verify** (shared verification above). Also check: Layout → Size shows Dynamic width and the spacing preset rows; changing Dynamic width shows or hides the width rows as before.

- [ ] **Step 5: Commit**

```bash
git add options/modules/OptionsFocus.lua options/modules/OptionsFocusIntegrations.lua locales/horizon/
```
```bash
git commit -m "refactor(focus): file Focus settings under the shared pages" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 9: Retag Vista

**Files:**
- Modify: `options/modules/OptionsVista.lua`

- [ ] **Step 1: Register the Vista pages**

Before the Vista category list, add:

```lua
addon.RegisterModulePages("vista", {
    { key = "buttons", name = L["VISTA_ADDON_BUTTONS"], desc = L["VISTA_ICON_MANAGEMENT"] },
})
```

- [ ] **Step 2: Tag the sections**

| Line | Section | page | card |
|---|---|---|---|
| 32 | `SIZE_SHAPE` | `layout` | `size` |
| 39 | `AXIS_POSITION` | `layout` | `position` |
| 46 | `VISTA_AUTO_ZOOM` | `general` | `behaviour` |
| 52 | `VISTA_TEXT_ELEMENTS` | `general` | `visibility` |
| 70 | `VISTA_MINIMAP_BUTTONS` | `buttons` | — |
| 80 | `VISTA_TELEPORT_MENU` | `general` | `teleport` |
| 130 | `VISTA_BORDER` | `look` | `background` |
| 169 | `VISTA_TEXT_POSITIONS` | `layout` | `textPositions` |
| 222 | `VISTA_BUTTON_POSITIONS` | `buttons` | — |
| 237 | `VISTA_BUTTON_SIZES` | `buttons` | — |
| 294 | `VISTA_ZONE_TEXT_HEADER` | `look` | `text` |
| 316 | `VISTA_COORDINATES_TEXT` | `look` | `text` |
| 348 | `VISTA_TEXT` | `look` | `text` |
| 370 | `VISTA_PERFORMANCE_TEXT` | `look` | `text` |
| 395 | `VISTA_DIFFICULTY_TEXT` | `look` | `text` |
| 417 | `VISTA_PER_DIFFICULTY_COLOURS` | `look` | `colours` |
| 453 | `VISTA_BUTTON_MANAGEMENT` | `buttons` | — |
| 524 | `VISTA_CLOSE_FADE_TIMING` | `buttons` | — |
| 548 | `DASH_LAYOUT` | `buttons` | — |
| 585 | `VISTA_PANEL_APPEARANCE` | `buttons` | — |
| 618 | `VISTA_MOUSEOVER_BAR_APPEARANCE` | `buttons` | — |
| 654 | `VISTA_MANAGED_BUTTONS` | `buttons` | — |
| 692 | `VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE` | `buttons` | — |

Expected pages: General · Layout · Look & Feel · Buttons.

- [ ] **Step 3: Verify** (shared verification). Also check: Look & Feel → Text holds the five former text sections in that order.

- [ ] **Step 4: Commit**

```bash
git add options/modules/OptionsVista.lua
```
```bash
git commit -m "refactor(vista): file Vista settings under the shared pages" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 10: Retag Insight

**Files:**
- Modify: `options/modules/OptionsInsight.lua`
- Modify: `locales/horizon/enUS.lua` (one key)

- [ ] **Step 1: Register the Insight pages**

Before the Insight category list, add:

```lua
addon.RegisterModulePages("insight", {
    { key = "general", dashboardPreviewMode = "global" },
    { key = "layout", dashboardPreviewMode = "global" },
    { key = "look", dashboardPreviewMode = "global" },
    { key = "players", name = L["INSIGHT_CATEGORY_PLAYER"], dashboardPreviewMode = "player" },
    { key = "npcsItems", name = L["INSIGHT_PAGE_NPCS_ITEMS"], dashboardPreviewMode = "npc",
      cardNames = { npc = L["INSIGHT_CATEGORY_NPC"], item = L["INSIGHT_CATEGORY_ITEM"] } },
})
```

Add to `locales/horizon/enUS.lua` after `L["FOCUS_PAGE_TRACKED"]` (or after `L["DASH_NEEDS_PARENT"]` if Task 8 has not merged):

```lua
L["INSIGHT_PAGE_NPCS_ITEMS"]                                   = "NPCs & items"
```

then run `node tools/restructure_locales.js`.

- [ ] **Step 2: Move the TRP3 page's visibility onto its card**

Above the category list, add a local holding the body of the `InsightTRP3` category's `hidden` function, inverted:

```lua
-- TRP3 card shows when TRP3 is active, or installed and enabled (Horizon may load first).
local function TRP3Installed()
    if TRP3_API then return true end
    if C_AddOns and C_AddOns.GetAddOnInfo then
        local ok, _, _, _, loadable = pcall(C_AddOns.GetAddOnInfo, "totalRP3")
        if ok and loadable then return true end
    end
    return false
end
```

Delete the `InsightTRP3` category's `hidden = function() ... end,` field and its `dashboardPreviewMode` line.

- [ ] **Step 3: Tag the sections**

| Line | Section | page | card |
|---|---|---|---|
| 35 | `AXIS_POSITION` | `layout` | `position` |
| 51 | `DASH_APPEARANCE` | `look` | `background` |
| 59 | `INSIGHT_SECTION_COMBAT` | `general` | `visibility` |
| 61 | `INSIGHT_SECTION_ICONS_AND_SEPARATORS` | `look` | `icons` |
| 73 | `INSIGHT_SECTION_IDENTITY` | `players` | — |
| 110 | `INSIGHT_SECTION_STATUS_PVP` | `players` | — |
| 120 | `INSIGHT_SECTION_RATINGS_GEAR` | `players` | — |
| 126 | `INSIGHT_SECTION_MOUNT` | `players` | — |
| 129 | `INSIGHT_SECTION_CLASS` | `players` | — |
| 135 | `FOCUS_FONT_SIZES` | `players` | — |
| 160 | `INSIGHT_CATEGORY_TRP3` (keeps `headerToggle`, `dbKey`; add `visibleWhen = TRP3Installed`) | `players` | `trp3` |
| 182 | `INSIGHT_SECTION_NPC_TOOLTIP` | `npcsItems` | `npc` |
| 188 | `FOCUS_FONT_SIZES` | `npcsItems` | `npc` |
| 200 | `INSIGHT_SECTION_TRANSMOG` | `npcsItems` | `item` |
| 202 | `INSIGHT_SECTION_ITEM_STYLING` | `npcsItems` | `item` |
| 207 | `FOCUS_FONT_SIZES` | `npcsItems` | `item` |

Expected pages: General · Layout · Look & Feel · Player · NPCs & items.

- [ ] **Step 4: Verify** (shared verification). Also check: the preview pull-out shows the player preview on Player and the NPC preview on NPCs & items; the TRP3 card appears only with TRP3 installed.

- [ ] **Step 5: Commit**

```bash
git add options/modules/OptionsInsight.lua locales/horizon/
```
```bash
git commit -m "refactor(insight): file Insight settings under the shared pages" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 11: Retag Presence

**Files:**
- Modify: `options/modules/OptionsPresence.lua`

- [ ] **Step 1: Register the Presence pages**

Before the Presence category list, add:

```lua
addon.RegisterModulePages("presence", {
    { key = "notifications", name = L["PRESENCE_NOTIFICATIONS"], desc = L["CHOOSE_WHICH_EVENTS_TRIGGER_SCREEN_ALERTS"] },
})
```

- [ ] **Step 2: Split the Display section**

The `DASH_DISPLAY` section (lines 47-53) holds behaviour, position and size rows. Rewrite it as three sections, moving whole rows:

```
Section(L["DASH_DISPLAY"], { page = "general", card = "behaviour" }),
    <TOAST_ICONS row>, <PRESENCE_TOAST_ICON_SIZE row>, <PRESENCE_HIDE_QUEST_UPDATE_TITLE row>, <PRESENCE_DISCOVERY_LINE row>,
Section(L["DASH_DISPLAY"], { page = "layout", card = "position" }),
    <PRESENCE_FRAME_VERTICAL_POSITION row>,
Section(L["DASH_DISPLAY"], { page = "layout", card = "size" }),
    <PRESENCE_FRAME_SCALE row>,
```

- [ ] **Step 3: Tag the remaining sections**

| Line | Section | page | card |
|---|---|---|---|
| 54 | `PRESENCE_ANIMATION` | `look` | `animation` |
| 67 | `PRESENCE_PREVIEW` | `notifications` | `preview` |
| 77 | `PRESENCE_NOTIFICATION_TYPES` | `notifications` | — |
| 82 | `INSTANCE_SUPPRESSION` | `notifications` | — |
| 110 | `DASH_TYPOGRAPHY` | `look` | `text` |
| 146 | `PRESENCE_LARGE_NOTIFICATIONS` | `look` | `text` |
| 149 | `PRESENCE_MEDIUM_NOTIFICATIONS` | `look` | `text` |
| 152 | `PRESENCE_SMALL_NOTIFICATIONS` | `look` | `text` |
| 155 | `PRESENCE_DISCOVERY_NOTIFICATIONS` | `look` | `text` |
| 157 | `DASH_COLOURS` | `look` | `colours` |
| 160 | `ZONE_TYPE_COLOURING` | `look` | `colours` |

Expected pages: General · Layout · Look & Feel · Notifications.

- [ ] **Step 4: Verify** (shared verification). Also check: the preview card is first on Notifications and its type picker still drives the preview.

- [ ] **Step 5: Commit**

```bash
git add options/modules/OptionsPresence.lua
```
```bash
git commit -m "refactor(presence): file Presence settings under the shared pages" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 12: Retag Echo

**Files:**
- Modify: `options/modules/OptionsEcho.lua`
- Modify: `locales/horizon/enUS.lua` (one key)

- [ ] **Step 1: Register the Echo pages**

Before `local options = {` add:

```lua
addon.RegisterModulePages("echo", {
    { key = "feeds", name = L["ECHO_PAGE_FEEDS"] },
})
```

Add to `locales/horizon/enUS.lua` with the other new page keys:

```lua
L["ECHO_PAGE_FEEDS"]                                           = "Feeds & groups"
```

then run `node tools/restructure_locales.js`.

- [ ] **Step 2: Split the General section**

The `ECHO_SECTION_GENERAL` section (lines 78-117) holds, in order: column edge, lock, reset position, scale, strata, collapse. Rewrite it as three sections, moving whole rows:

```
Section(L["ECHO_SECTION_GENERAL"], { page = "layout", card = "position" }),
    <ECHO_COLUMN_EDGE row>, <ECHO_LOCK row>, <AXIS_RESET_POSITION row>, <ECHO_STRATA row>,
Section(L["ECHO_SECTION_GENERAL"], { page = "layout", card = "size" }),
    <ECHO_SCALE row>,
Section(L["ECHO_SECTION_GENERAL"], { page = "general", card = "behaviour" }),
    <ECHO_COLLAPSE row>,
```

- [ ] **Step 3: Tag the remaining sections**

| Line | Section | page | card |
|---|---|---|---|
| 118 | `ECHO_SECTION_NOTIFICATIONS` | `general` | `notifications` |
| 140 | `ECHO_SECTION_TIERS` | `feeds` | — |
| 151 | `ECHO_SECTION_FEEDS` | `feeds` | — |
| 224 | `ECHO_SECTION_GROUPS` | `feeds` | — |
| 306 | `ECHO_SECTION_HISTORY` | `general` | `history` |
| 321 | `ECHO_SECTION_BLIZZARD_CHAT` | `general` | `blizzardChat` |
| 338 | `ECHO_SECTION_CARD` | `look` | `card` |

Expected pages: General · Layout · Look & Feel · Feeds & groups.

- [ ] **Step 4: Verify** (shared verification). Also run the Echo logic tests, since `OptionsEcho.lua` is loaded by them:

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`
Expected: `... passed, 0 failed`.

- [ ] **Step 5: Commit**

```bash
git add options/modules/OptionsEcho.lua locales/horizon/
```
```bash
git commit -m "refactor(echo): file Echo settings under the shared pages" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 13: Retag Essence

**Files:**
- Modify: `options/modules/OptionsEssence.lua`

- [ ] **Step 1: Tag the sections**

| Line | Section | page | card |
|---|---|---|---|
| 25 | `AXIS_POSITION` | `layout` | `position` |
| 31 | `DASH_APPEARANCE` | `general` | `visibility` |

Expected pages: General · Layout.

- [ ] **Step 2: Verify** (shared verification).

- [ ] **Step 3: Commit**

```bash
git add options/modules/OptionsEssence.lua
```
```bash
git commit -m "refactor(essence): file Essence settings under the shared pages" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 14: Retag Augment and move header buttons onto pages

**Files:**
- Modify: `options/dashboard/DashboardDetailView.lua` (two header-button blocks: in `f.OpenCategoryDetail` around lines 1044-1102, and in `f.OpenModule` around lines 1316-1373)
- Modify: `options/modules/OptionsAugment.lua`
- Modify: `options/modules/OptionsAugmentAlerts.lua`
- Modify: `options/modules/OptionsAugmentLootRoll.lua`
- Modify: `options/modules/OptionsAugmentTalkingHead.lua`
- Modify: `options/OptionsPages.lua` (add `Pages.FromCategory`)

**Interfaces:**
- Produces: `addon.OptionsPages.FromCategory(cat, key, extra) -> def`.
- Produces: a page field `headerButtons = { preview = fn|nil, reset = fn|nil, anchor = fn|nil }`; the detail view shows each fixed header button whose function is present.

- [ ] **Step 1: One helper for the page header buttons**

In `options/dashboard/DashboardDetailView.lua`, before `f.OpenCategoryDetail = function(...)`, add:

```lua
    -- Fixed header buttons come from the page's `headerButtons` field.
    local function ApplyPageHeaderButtons(cat)
        local hb = (cat and cat.headerButtons) or {}
        local function Wire(btn, fn)
            if not btn then return end
            if fn then
                btn._onClick = fn
                btn:Show()
            else
                btn:Hide()
            end
        end
        Wire(f.detailPreviewBtn, hb.preview)
        Wire(f.detailResetBtn, hb.reset)
        Wire(f.detailAnchorBtn, hb.anchor)
        if f.detailEnableBtn then f.detailEnableBtn:Hide() end
    end
```

In `f.OpenCategoryDetail`, replace the whole `do ... end` block that starts with `local isAugment = selCat and selCat.key == "AugmentImprovements"` and ends with `if f.detailEnableBtn then f.detailEnableBtn:Hide() end` with:

```lua
        ApplyPageHeaderButtons(matchedCatIdx and addon.OptionCategories[matchedCatIdx])
```

In `f.OpenModule`, replace the matching block (the one that ends just before `if cats[1] then`) with:

```lua
            ApplyPageHeaderButtons(cats[1])
```

Run: `git grep -n "AugmentImprovements\|isAugmentAlerts" options/dashboard`
Expected: no output.

- [ ] **Step 2: Register the Augment pages**

The Augment category tables already hold each feature's page fields, and their `setEnabled` functions close over file locals (`applyLootFrameState`, `getDB`, `D`). So the page defs are built from those tables rather than copied by hand.

In `options/OptionsPages.lua`, after `addon.RegisterModulePages`, add:

```lua
-- Fields a page def can take over from a legacy category table.
local CATEGORY_PAGE_FIELDS = {
    "desc", "icon", "accentColor", "enabledKey", "getEnabled", "setEnabled",
    "hidden", "dashboardPreviewMode",
}

--- Build a page def from a legacy category table (Augment's feature pages).
--- @param cat table  The category table
--- @param key string  Page key
--- @param extra table|nil  Extra def fields (headerButtons, allowEmpty, ...)
--- @return table def
function Pages.FromCategory(cat, key, extra)
    local def = { key = key, name = cat.name }
    for _, f in ipairs(CATEGORY_PAGE_FIELDS) do def[f] = cat[f] end
    for k, v in pairs(extra or {}) do def[k] = v end
    return def
end
```

In `options/modules/OptionsAugment.lua`, replace the closing loop (lines 468-470):

```lua
for i = 1, #categories do
    addon.OptionCategories[#addon.OptionCategories + 1] = categories[i]
end
```

with:

```lua
local byKey = {}
for _, cat in ipairs(categories) do byKey[cat.key] = cat end
local FromCategory = addon.OptionsPages.FromCategory

-- One page per Augment feature, in this order. Alerts, Loot Roll and Talking Head
-- replace their placeholder defs from their own files, keeping this order.
addon.RegisterModulePages("augment", {
    FromCategory(byKey.AugmentImprovements, "loot", {
        headerButtons = {
            preview = function() if addon.Augment and addon.Augment.PreviewToasts then addon.Augment.PreviewToasts() end end,
            reset   = function() if addon.Augment and addon.Augment.ResetPosition then addon.Augment.ResetPosition() end end,
            anchor  = function() if addon.Augment and addon.Augment.ToggleAnchorFrame then addon.Augment.ToggleAnchorFrame() end end,
        },
    }),
    { key = "alerts" },
    { key = "lootRoll" },
    { key = "talkingHead" },
    FromCategory(byKey.AugmentVendor, "vendor"),
    FromCategory(byKey.AugmentSelfHighlight, "selfHighlight"),
    -- Its only control is the page's on/off switch, so it is emitted with no cards.
    FromCategory(byKey.AugmentAchievementTracker, "achievementTracker", { allowEmpty = true }),
})

for i = 1, #categories do
    if categories[i].key ~= "AugmentAchievementTracker" then
        addon.OptionCategories[#addon.OptionCategories + 1] = categories[i]
    end
end
```

In each sub-file, directly before its `-- Insert after the last Augment category` block, add one call:

- `options/modules/OptionsAugmentAlerts.lua`:

  ```lua
  addon.RegisterModulePages("augment", {
      addon.OptionsPages.FromCategory(category, "alerts", {
          headerButtons = {
              preview = function() if addon.Augment and addon.Augment.Alerts and addon.Augment.Alerts.PreviewAlerts then addon.Augment.Alerts.PreviewAlerts() end end,
              reset   = function() if addon.Augment and addon.Augment.Alerts and addon.Augment.Alerts.ResetPosition then addon.Augment.Alerts.ResetPosition() end end,
              anchor  = function() if addon.Augment and addon.Augment.Alerts and addon.Augment.Alerts.ToggleEditMode then addon.Augment.Alerts.ToggleEditMode() end end,
          },
      }),
  })
  ```

- `options/modules/OptionsAugmentLootRoll.lua`: `addon.RegisterModulePages("augment", { addon.OptionsPages.FromCategory(category, "lootRoll") })`
- `options/modules/OptionsAugmentTalkingHead.lua`: `addon.RegisterModulePages("augment", { addon.OptionsPages.FromCategory(category, "talkingHead") })`

Check each sub-file names its table `category` (`git grep -n "^local category" options/modules/OptionsAugment*.lua`); use the actual local name if it differs.

Add `options/OptionsPages.lua` to this task's `git add`.

- [ ] **Step 3: Tag the top-level sections**

Nested sections inside `columns` blocks need no tag; they inherit the page from the section above the block.

| File:line | Section | page |
|---|---|---|
| `OptionsAugment.lua:65` | `AUGMENT_LOOT_PARTS_SECTION` | `loot` |
| `OptionsAugment.lua:72` | `AUGMENT_TOAST_SETTINGS` | `loot` |
| `OptionsAugment.lua:226` | `AUGMENT_STYLE_SECTION` | `loot` |
| `OptionsAugment.lua:301` | `AUGMENT_SOUNDS` | `loot` |
| `OptionsAugment.lua:371` | `AUGMENT_VENDOR_SELLER_SECTION` | `vendor` |
| `OptionsAugment.lua:398` | `AUGMENT_VENDOR_REPAIR_SECTION` | `vendor` |
| `OptionsAugment.lua:434` | `AUGMENT_SELF_HIGHLIGHT_BEHAVIOUR` | `selfHighlight` |
| `OptionsAugmentAlerts.lua:110` | `AUGMENT_ALERTS_KINDS` | `alerts` |
| `OptionsAugmentAlerts.lua:259` | `AUGMENT_ALERTS_DISPLAY` | `alerts` |
| `OptionsAugmentAlerts.lua:379` | `AUGMENT_ALERTS_COLOURS` | `alerts` |
| `OptionsAugmentLootRoll.lua:83` | `LOOT_ROLL_PREVIEW` | `lootRoll` |
| `OptionsAugmentLootRoll.lua:99` | `LOOT_ROLL_INFORMATION` | `lootRoll` |
| `OptionsAugmentLootRoll.lua:145` | `LOOT_ROLL_APPEARANCE` | `lootRoll` |
| `OptionsAugmentTalkingHead.lua:66` | `TALKING_HEAD_STYLE` | `talkingHead` |

No `card` tags: each section becomes its own card.

Expected pages: Improvements (Loot) · Alerts · Loot Roll · Talking Head · Vendor · Self Highlight · Achievement Tracker (the last only while Focus is off).

- [ ] **Step 4: Verify** (shared verification). Also check:
  - The Augment landing view still shows the feature rows with icons and on/off pills, and a disabled feature's sidebar row still hides.
  - Loot and Alerts show the Preview, Reset and Anchor header buttons, and each works.
  - Former two-column settings now appear as stacked cards, each searchable.
  - The Achievement Tracker page's enable button turns the tracker on and off.

- [ ] **Step 5: Commit**

```bash
git add options/OptionsPages.lua options/dashboard/DashboardDetailView.lua options/modules/OptionsAugment.lua options/modules/OptionsAugmentAlerts.lua options/modules/OptionsAugmentLootRoll.lua options/modules/OptionsAugmentTalkingHead.lua
```
```bash
git commit -m "refactor(augment): give each Augment feature an assembled page" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 15: Strict mode and the columns code path

Run only after Tasks 7–14 have merged.

**Files:**
- Modify: `options/OptionsAssemble.lua` (`strict = false` → `true`)
- Modify: `options/dashboard/DashboardAccordionBuild.lua` (delete the `columns` branch, about lines 1043-1251)
- Modify: `options/OptionsHelpers.lua` (`addon.PruneOptionsForPlatform` columns recursion)

- [ ] **Step 1: Confirm nothing is untagged or columnar**

Run: `git grep -n 'type = "columns"' options/`
Expected: matches only inside the five Augment files (still authored as columns; the assembler unwraps them).

Add a test above `// --- Summary` proving assembled output never contains columns:

```js
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
```

- [ ] **Step 2: Run to see it fail**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_logic.js`
Expected: `FAIL: strict is on by default  got: false`.

- [ ] **Step 3: Turn strict on**

In `options/OptionsAssemble.lua`, change `strict = false,` to `strict = true,` and update its comment to `-- A category with no tagged section is a load-time error.`

- [ ] **Step 4: Run the tests**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_logic.js`
Expected: `83 passed, 0 failed`.

- [ ] **Step 5: Delete the columns rendering path**

In `options/dashboard/DashboardAccordionBuild.lua`, delete the `elseif opt.type == "columns" then` branch through the line `widget = colFrame` (inclusive), and any local functions used only by it (`MeasureColumns`, `ApplyColumnLayout`, `RefreshColumnVisibility`). Check:

Run: `git grep -n "MeasureColumns\|ApplyColumnLayout\|RefreshColumnVisibility\|\"columns\"" options/dashboard`
Expected: no output.

In `options/OptionsHelpers.lua`, in `addon.PruneOptionsForPlatform`, delete the `if type(row) == "table" and row.type == "columns" then ... end` block and the `Recurses into column layouts` line of its doc comment.

- [ ] **Step 6: Verify**

Push and ask the director to check on Retail and Forever: `/reload` prints no red line; open every module's every page once (no Lua errors); the Augment pages look as they did after Task 14.

- [ ] **Step 7: Commit**

```bash
git add options/OptionsAssemble.lua options/dashboard/DashboardAccordionBuild.lua options/OptionsHelpers.lua tools/test_options_logic.js
```
```bash
git commit -m "refactor(axis): require tagged options and drop the columns path" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```
