# Horizon Meridian: Phase 1 Implementation Plan (shell and basics)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship Meridian as Horizon's eighth module: an edge-docked info bar with the Strip and Capsules styles, auto-hide, a settings page, the phase 1 blocks (Horizon menu, clock, coordinates, performance, gold, durability, bags, mail, queue, teleports), and Vista handing its clock, coordinates, performance, mail and queue over to it.

**Architecture:** A data-only registry (`MeridianRegistry.lua`) holds block definitions and answers `Owns(id)`. Pure helpers (`MeridianFormat.lua`, `MeridianAutoHide.lua`) format values and run the auto-hide state machine, and are tested in fengari. `MeridianBar.lua` is the only file with frames: it lays blocks out from the registry, refreshes them on events and one shared ticker, and drives the slide. Built-in blocks live in `blocks/`. Vista asks `addon.Meridian.Owns(id)` and steps aside.

**Tech Stack:** WoW Lua 5.1 addon (Retail 120100 and Forever 16001), the fengari harness (`tools/test_meridian_logic.js`, new), `tools/test_options_modules.js`, and `tools/make_module_icons.py` (Pillow).

**Spec:** `Docs/Engineering/2026-10-16-meridian-bar-design.md`, sections "Locked decisions", "Architecture" (including "Handover from Vista"), "Look and behaviour", "Block catalogue" (phase 1 rows), "Error handling" and "Testing".

**Checked before hand-over (2026-10-16):** every Lua file in this plan parses, `tools/test_meridian_logic.js` passes with the counts given per task, and `tools/test_options_modules.js` passes (49) with the Meridian page wired in. The Vista edits (Task 7, step 4) and the dashboard edits (Task 8) were not exercised; they are checked in game.

**Plan series:** **1 Shell and basics (this plan).** 2 Module readouts. 3 Button collector.

## Global Constraints

- **Lua:** Lua 5.1 only, and runnable on fengari's 5.3. Don't use `goto`, `//`, bitwise operators, `unpack` (use explicit indexes), `tinsert` (use `table.insert`) or `%z` in patterns.
- **File header:** every module file starts with `local addon = _G.HorizonSuite` and `if not addon then return end`, and hangs off `addon.Meridian`.
- **Frames** are non-secure. Never reparent Blizzard's queue button in combat: defer to `PLAYER_REGEN_ENABLED`.
- **Frame names:** `HorizonSuiteMeridianBar` and `HorizonSuiteMeridianEdge`. No other new globals.
- **Strings** shown to the player come from `addon.L` (`locales/horizon/enUS.lua`), in the aligned `L["KEY"] = "text"` style, under a `-- ==== Meridian ====` banner. Sentence case. No em dashes in player-facing copy.
- **Colours:**
  - brand pale gold `#E8D9B5` = `{ 232/255, 217/255, 181/255 }` (`Meridian.BRAND`)
  - strip background `0.04, 0.05, 0.06, 0.78`
  - value text `0.85, 0.86, 0.89`; default icon tint `0.54, 0.56, 0.63`
  - capsule fill white at 0.07, border white at 0.12
- **Settings keys:** prefix `meridian`, plus `classColorMeridian` and `meridianUIScale` in Axis. Per block: `meridianBlock_<id>_enabled|side|order`.
- **Commits:** Conventional Commits with scope `meridian` (scope `vista` for Task 7's Vista edits, `dashboard` for Task 8), each ending with exactly one `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` trailer. Run `git add` and `git commit` as separate commands.
- **Branch:** `feature/meridian`, in its own worktree (other sessions use the main checkout), cut from `docs/meridian-design` so the spec and this plan travel with it.
- **Line endings:** `.gitattributes` forces CRLF on checkout. Write files normally; git converts. When editing `HorizonSuite.toc` with a script, keep CRLF.
- **Test commands:**
  - `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_meridian_logic.js` (new in Task 1)
  - `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_modules.js` (48 passing before this plan)
  - `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_logic.js` (443 passing before this plan)
  - A bare `node tools/test_*.js` prints `SKIP` and exits 0: that is not a pass.
- **Parse check** (luacheck isn't installed locally):
  `NODE_PATH="$HOME/.cache/hs-test/node_modules" node -e "const {lauxlib,lua,to_luastring,to_jsstring}=require('fengari');const L=lauxlib.luaL_newstate();for(const f of process.argv.slice(1)){const s=require('fs').readFileSync(f,'utf8');console.log(f,lauxlib.luaL_loadbuffer(L,to_luastring(s),null,to_luastring(f))===lua.LUA_OK?'parses':to_jsstring(lua.lua_tostring(L,-1)))}" <files>`
- **Enable order:** modules enable in `pairs` order and `addon:IsModuleEnabled(k)` turns true only after `OnEnable` returns (`HorizonSuite.lua:102-103`). Never evaluate a cross-module gate once at enable; the registry evaluates gates at every call.
- **Vista's 200-local limit:** `VistaCore.lua`'s main chunk is near WoW's 200-local cap. Add helpers as fields (`G.Owned`, `Vista.X = function`) or as locals inside an existing `do ... end` block, never as new top-level locals.

## File map

| File | Status | Responsibility |
|------|--------|----------------|
| `modules/Meridian/MeridianRegistry.lua` | Create | Block registry, settings access, gates, `Owns`, `SafeText`, font, accent, glyph paths |
| `modules/Meridian/MeridianFormat.lua` | Create | Pure value formatting |
| `modules/Meridian/MeridianAutoHide.lua` | Create | Pure auto-hide state machine and edge test |
| `modules/Meridian/MeridianBar.lua` | Create | The bar frame, layout, styles, refresh, tooltips, clicks, menu, Vista notification |
| `modules/Meridian/MeridianModule.lua` | Create | `RegisterModule("meridian", …)`; seeds clock settings from Vista |
| `modules/Meridian/blocks/MeridianBlocksTime.lua` | Create | Clock |
| `modules/Meridian/blocks/MeridianBlocksWorld.lua` | Create | Coordinates, performance |
| `modules/Meridian/blocks/MeridianBlocksCharacter.lua` | Create | Gold, durability, bags |
| `modules/Meridian/blocks/MeridianBlocksNotices.lua` | Create | Mail (Task 5), queue (Task 7) |
| `modules/Meridian/blocks/MeridianBlocksActions.lua` | Create | Horizon menu (Task 5), teleports (Task 7) |
| `options/modules/defaults/OptionsDefaultsMeridian.lua` | Create | `MERIDIAN_DEFAULTS`, `MERIDIAN_LIMITS`, `MERIDIAN_KEYS` |
| `options/modules/OptionsMeridian.lua` | Create | Settings page and the Blocks page |
| `tools/icons/meridian/*.svg`, `media/meridian/*.tga` | Create | Block glyphs |
| `tools/icons/meridian.svg`, `media/icons/meridian.tga` | Create | Module icon |
| `tools/test_meridian_logic.js` | Create | Logic and smoke tests |
| `HorizonSuite.lua` | Modify | `EnsureModulesDB` entries |
| `HorizonSuite.toc` | Modify | Load the new files |
| `modules/Vista/VistaCore.lua` | Modify | Ownership checks; `Vista.UpdateMailIndicator`, `Vista.ReattachQueueButton`, `Vista.ToggleTeleportMenu` |
| `options/OptionsData.lua` | Modify | Route Meridian keys; class colour; global font |
| `options/OptionsDefaults.lua` | Modify | `SCALE_DEBOUNCE_KEYS`, `CLASS_COLOR_KEYS` |
| `options/modules/defaults/OptionsDefaultsAxis.lua` | Modify | `classColorMeridian`, `meridianUIScale` |
| `options/modules/OptionsGlobal.lua` | Modify | Class-colour toggle and scale slider |
| `options/OptionsHelpers.lua` | Modify | `DEFAULT_TABLES` |
| `options/OptionsSearch.lua` | Modify | `MODULE_ALIASES` |
| `options/dashboard/DashboardFrame.lua`, `DashboardHomeWelcome.lua`, `DashboardModuleGuide.lua`, `DashboardPatchNotesContent.lua` | Modify | Meridian goes from "Coming soon" to a live module |
| `core/Config.lua` | Modify | Brand-name locale keys |
| `locales/horizon/*.lua` | Modify | New strings; rewrite the placeholder copy |
| `tools/test_options_modules.js` | Modify | File list, expected pages, prerequisites |
| `.github/workflows/luacheck.yml` | Modify | Check the block glyphs too |
| `Docs/Branding/ColourSchema.md`, `tools/make_update_card.py` | Modify | Brand colour |

---

### Task 1: Block registry

**Files:**
- Create: `modules/Meridian/MeridianRegistry.lua`
- Create: `tools/test_meridian_logic.js`
- Modify: `HorizonSuite.toc` (after `core/GameMenuButton.lua`, line 58)

**Interfaces:**
- Consumes: `addon.GetDB(key, default)`, `addon:IsModuleEnabled(key)`, `addon.Platform.Has(cap)`, `addon.MERIDIAN_DEFAULTS` (read lazily; created in Task 4).
- Produces, on `addon.Meridian`:
  - `RegisterBlock(def) -> boolean`; `Get(id) -> def|nil`; `All() -> def[]` (registration order)
  - `Key(id, field) -> string`; `Setting(key) -> any`
  - `IsBlockOn(id)`, `IsAvailable(id)`, `Owns(id) -> boolean`; `BlockSide(id) -> "left"|"centre"|"right"`; `BlockOrder(id) -> number`
  - `Layout(side) -> def[]` (on and available, sorted by order then id)
  - `SafeText(def) -> string|nil`; `FAILED_TEXT`
  - `SIDES = { "left", "centre", "right" }`; `BRAND = { r, g, b }`; `Accent() -> r, g, b`; `FontPath() -> string`; `Glyph(name) -> string`
  - `_active` (set by the bar), `OnBlocksChanged` (hook the bar sets), `_ResetForTests()`
- Block def fields: `id`, `label`, `icon` (path or function), `iconColor` (table or function), `iconAccent` (boolean), `text` (function, required), `events` (array), `OnEvent`, `tick` (seconds), `width` (minimum px), `OnClick(button)`, `OnTooltipShow(tooltip)`, `OnMenu(rootDescription)`, `Attach(button)`, `Detach(button)`, `combatLocked`, `module`, `requires`, `defaultSide`, `defaultOrder`, `defaultOn`.

- [ ] **Step 1: Write the harness and the failing registry tests**

Create `tools/test_meridian_logic.js`:

```js
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
```

- [ ] **Step 2: Run it to see it fail**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_meridian_logic.js`
Expected: exit 1 with `ENOENT` for `modules/Meridian/MeridianRegistry.lua`.

- [ ] **Step 3: Write the registry**

Create `modules/Meridian/MeridianRegistry.lua`:

```lua
--[[
    Horizon Suite - Meridian - Registry
    The block registry the bar draws from. Data only: no frames. Loads straight after the
    core files, before any module, so every module's files can register blocks.
    Gates (owning module on, platform capability present) are evaluated on every call,
    because modules enable in no fixed order (HorizonSuite.lua EnableModule).
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Meridian = addon.Meridian or {}
local Meridian = addon.Meridian

Meridian.SIDES = { "left", "centre", "right" }
local SIDE_SET = { left = true, centre = true, right = true }

-- Pale gold #E8D9B5.
Meridian.BRAND = { 232 / 255, 217 / 255, 181 / 255 }

-- Shown in place of a block whose text function errors.
Meridian.FAILED_TEXT = "\226\128\147"  -- en dash, as UTF-8 bytes

-- Set true by the bar while it is built and showing blocks.
Meridian._active = false

local blocks, order, warned = {}, {}, {}

local function DB(key, default)
    if addon.GetDB then return addon.GetDB(key, default) end
    return default
end

--- A Meridian setting, defaulting from MERIDIAN_DEFAULTS (read lazily: the defaults file
--- loads with the options, after this file).
-- @param key string
-- @return any
function Meridian.Setting(key)
    local D = addon.MERIDIAN_DEFAULTS
    return DB(key, D and D[key])
end

--- @param id string
--- @param field string "enabled" | "side" | "order"
--- @return string
function Meridian.Key(id, field)
    return "meridianBlock_" .. id .. "_" .. field
end

--- Add a block. The first registration of an id wins.
-- @param def table  see Docs/Engineering/2026-10-16-meridian-bar-plan.md, Task 1
-- @return boolean registered
function Meridian.RegisterBlock(def)
    if type(def) ~= "table" or type(def.id) ~= "string" or def.id == "" then return false end
    if type(def.text) ~= "function" then return false end
    if blocks[def.id] then return false end
    if not SIDE_SET[def.defaultSide] then def.defaultSide = "right" end
    def.defaultOrder = tonumber(def.defaultOrder) or 100
    if def.defaultOn == nil then def.defaultOn = true end
    blocks[def.id] = def
    order[#order + 1] = def.id
    if Meridian.OnBlocksChanged then Meridian.OnBlocksChanged() end
    return true
end

function Meridian.Get(id)
    return blocks[id]
end

--- Every registered block, in registration order.
function Meridian.All()
    local out = {}
    for i = 1, #order do out[i] = blocks[order[i]] end
    return out
end

function Meridian.IsBlockOn(id)
    local def = blocks[id]
    if not def then return false end
    return DB(Meridian.Key(id, "enabled"), def.defaultOn) and true or false
end

function Meridian.BlockSide(id)
    local def = blocks[id]
    if not def then return "right" end
    local v = DB(Meridian.Key(id, "side"), def.defaultSide)
    if SIDE_SET[v] then return v end
    return def.defaultSide
end

function Meridian.BlockOrder(id)
    local def = blocks[id]
    if not def then return 100 end
    return tonumber(DB(Meridian.Key(id, "order"), def.defaultOrder)) or def.defaultOrder
end

--- Whether a block's owning module is on and its platform capability is present.
function Meridian.IsAvailable(id)
    local def = blocks[id]
    if not def then return false end
    if def.module and not (addon.IsModuleEnabled and addon:IsModuleEnabled(def.module)) then return false end
    if def.requires and not (addon.Platform and addon.Platform.Has and addon.Platform.Has(def.requires)) then
        return false
    end
    return true
end

--- Whether Meridian is drawing this block, so another module should hide its own copy.
function Meridian.Owns(id)
    return Meridian._active == true and blocks[id] ~= nil
        and Meridian.IsBlockOn(id) and Meridian.IsAvailable(id)
end

--- The blocks to draw on one side: on, available, sorted by order then id.
-- @param side string
-- @return table def[]
function Meridian.Layout(side)
    local out = {}
    for i = 1, #order do
        local id = order[i]
        if Meridian.IsBlockOn(id) and Meridian.IsAvailable(id) and Meridian.BlockSide(id) == side then
            out[#out + 1] = blocks[id]
        end
    end
    table.sort(out, function(a, b)
        local oa, ob = Meridian.BlockOrder(a.id), Meridian.BlockOrder(b.id)
        if oa ~= ob then return oa < ob end
        return a.id < b.id
    end)
    return out
end

--- A block's text through pcall. nil means "nothing to show" (a contextual block).
-- @param def table
-- @return string|nil
function Meridian.SafeText(def)
    local ok, v = pcall(def.text)
    if not ok then
        if not warned[def.id] then
            warned[def.id] = true
            if addon.Log and addon.Log.warn then addon.Log.warn("meridian", def.id .. ": " .. tostring(v)) end
        end
        return Meridian.FAILED_TEXT
    end
    if v == nil then return nil end
    return tostring(v)
end

--- Accent colour: the class colour when Axis class tint is on for Meridian, else the brand.
function Meridian.Accent()
    local cc = addon.GetModuleClassColor and addon.GetModuleClassColor("meridian")
    if cc then return cc[1], cc[2], cc[3] end
    local b = Meridian.BRAND
    return b[1], b[2], b[3]
end

--- The font every block uses: the global override, else the base font, else the game's.
function Meridian.FontPath()
    local global = addon.GetActiveGlobalFont and addon.GetActiveGlobalFont()
    if global then return global end
    local base = DB("fontPath", nil)
    if type(base) == "string" and base ~= "" then
        return (addon.ResolveFontPath and addon.ResolveFontPath(base)) or base
    end
    return (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"
end

--- Path of a block glyph rendered from tools/icons/meridian/<name>.svg.
function Meridian.Glyph(name)
    return "Interface\\AddOns\\" .. (addon.ADDON_NAME or "HorizonSuite") .. "\\media\\meridian\\" .. name .. ".tga"
end

function Meridian._ResetForTests()
    blocks, order, warned = {}, {}, {}
    Meridian._active = false
end
```

Add to `HorizonSuite.toc`, on the line after `core/GameMenuButton.lua`:

```
modules/Meridian/MeridianRegistry.lua
```

- [ ] **Step 4: Run the tests to see them pass**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_meridian_logic.js`
Expected: `32 passed, 0 failed`.

- [ ] **Step 5: Commit**

```bash
git add modules/Meridian/MeridianRegistry.lua tools/test_meridian_logic.js HorizonSuite.toc
```
```bash
git commit -m "feat(meridian): add the block registry" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: Value formatting

**Files:**
- Create: `modules/Meridian/MeridianFormat.lua`
- Modify: `tools/test_meridian_logic.js` (FILES list; new section above the summary)
- Modify: `HorizonSuite.toc` (after `MeridianRegistry.lua`)

**Interfaces:**
- Produces, on `addon.Meridian.Format`:
  - `Clock(hours, minutes, use24) -> "21:37" | "9:37 PM"`
  - `Coords(x, y, precision) -> "45.2, 61.8" | nil` (nil when x or y is missing, or both are 0)
  - `Perf(fps, ms) -> "60 / 28"`
  - `Thousands(n) -> "12,345"`; `Gold(copper) -> "12,345"`; `GoldDelta(copper) -> "+1,234g" | "-12g" | "0g"`
  - `LowestDurability({ {cur, max}, … }) -> integer percent | nil`; `Percent(n) -> "87%"`

- [ ] **Step 1: Write the failing tests**

Add `'modules/Meridian/MeridianFormat.lua',` to `FILES` after the registry, and add this section above the summary:

```js
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
```

- [ ] **Step 2: Run to see it fail**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_meridian_logic.js`
Expected: exit 1 with `ENOENT` for `MeridianFormat.lua`.

- [ ] **Step 3: Write the helpers**

Create `modules/Meridian/MeridianFormat.lua`:

```lua
--[[
    Horizon Suite - Meridian - Format
    Pure formatting for block values. No WoW API calls, so all of it runs in fengari.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Meridian = addon.Meridian or {}
local Meridian = addon.Meridian

local F = {}
Meridian.Format = F

--- @param hours number 0..23
--- @param minutes number 0..59
--- @param use24 boolean
--- @return string
function F.Clock(hours, minutes, use24)
    hours = math.floor(tonumber(hours) or 0)
    minutes = math.floor(tonumber(minutes) or 0)
    if use24 then return string.format("%02d:%02d", hours, minutes) end
    local period = hours >= 12 and "PM" or "AM"
    local h = hours % 12
    if h == 0 then h = 12 end
    return string.format("%d:%02d %s", h, minutes, period)
end

--- @param x number|nil 0..1
--- @param y number|nil 0..1
--- @param precision number 0, 1 or 2; anything else means 1
--- @return string|nil nil where the map gives no position
function F.Coords(x, y, precision)
    if type(x) ~= "number" or type(y) ~= "number" then return nil end
    if x == 0 and y == 0 then return nil end
    local fmt = "%.1f, %.1f"
    if precision == 0 then fmt = "%.0f, %.0f" elseif precision == 2 then fmt = "%.2f, %.2f" end
    return string.format(fmt, x * 100, y * 100)
end

function F.Perf(fps, ms)
    return string.format("%d / %d", math.floor(tonumber(fps) or 0), math.floor(tonumber(ms) or 0))
end

function F.Thousands(n)
    n = math.floor(tonumber(n) or 0)
    local neg = n < 0
    local s = tostring(neg and -n or n)
    local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if out:sub(1, 1) == "," then out = out:sub(2) end
    return (neg and "-" or "") .. out
end

--- Whole gold carried.
function F.Gold(copper)
    return F.Thousands(math.floor((tonumber(copper) or 0) / 10000))
end

--- Signed whole-gold change.
function F.GoldDelta(copper)
    copper = tonumber(copper) or 0
    local g = math.floor(math.abs(copper) / 10000)
    local sign = ""
    if g > 0 then sign = copper > 0 and "+" or "-" end
    return sign .. F.Thousands(g) .. "g"
end

--- @param slots table array of { current, maximum }
--- @return number|nil the lowest rounded percentage, or nil when no slot has durability
function F.LowestDurability(slots)
    local low
    for i = 1, #slots do
        local cur, max = slots[i][1], slots[i][2]
        if type(cur) == "number" and type(max) == "number" and max > 0 then
            local pct = math.floor(cur / max * 100 + 0.5)
            if not low or pct < low then low = pct end
        end
    end
    return low
end

function F.Percent(n)
    return tostring(math.floor((tonumber(n) or 0) + 0.5)) .. "%"
end
```

Add to `HorizonSuite.toc` after `modules/Meridian/MeridianRegistry.lua`:

```
modules/Meridian/MeridianFormat.lua
```

- [ ] **Step 4: Run the tests**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_meridian_logic.js`
Expected: `56 passed, 0 failed`.

- [ ] **Step 5: Commit**

```bash
git add modules/Meridian/MeridianFormat.lua tools/test_meridian_logic.js HorizonSuite.toc
```
```bash
git commit -m "feat(meridian): add value formatting helpers" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 3: Auto-hide state machine

**Files:**
- Create: `modules/Meridian/MeridianAutoHide.lua`
- Modify: `tools/test_meridian_logic.js`, `HorizonSuite.toc` (after `MeridianFormat.lua`)

**Interfaces:**
- Produces, on `addon.Meridian.AutoHide`:
  - constants `SLIDE_TIME = 0.15`, `HIDE_DELAY = 1.5`, `EDGE_ZONE = 4`
  - `New(shown) -> state` with `state.progress` (0 hidden … 1 out)
  - `Step(state, dt, inputs) -> progress, alpha`, where `inputs = { autoHide, keepOutOfCombat, inCombat, hovering, combatMode = "show"|"fade"|"hide", fadeAlpha }`
  - `CursorInZone(edge, cursorY, screenHeight, zone) -> boolean`

- [ ] **Step 1: Write the failing tests**

Add `'modules/Meridian/MeridianAutoHide.lua',` to `FILES` and this section above the summary:

```js
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
```

- [ ] **Step 2: Run to see it fail**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_meridian_logic.js`
Expected: exit 1, `ENOENT` for `MeridianAutoHide.lua`.

- [ ] **Step 3: Write the state machine**

Create `modules/Meridian/MeridianAutoHide.lua`:

```lua
--[[
    Horizon Suite - Meridian - Auto-hide
    Pure state machine for the bar's slide: whether it should be out, how far out it is,
    and its alpha. The bar feeds it inputs every frame; nothing here touches a frame.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Meridian = addon.Meridian or {}
local Meridian = addon.Meridian

local A = {}
Meridian.AutoHide = A

A.SLIDE_TIME = 0.15  -- seconds for a full slide
A.HIDE_DELAY = 1.5   -- seconds after the mouse leaves before the bar slides away
A.EDGE_ZONE = 4      -- px at the screen edge that bring the bar back

--- @param shown boolean start out (true) or away (false)
function A.New(shown)
    return { progress = shown and 1 or 0, sinceHover = shown and 0 or A.HIDE_DELAY }
end

--- Advance one frame.
-- @param s table state from New
-- @param dt number seconds
-- @param inp table { autoHide, keepOutOfCombat, inCombat, hovering, combatMode, fadeAlpha }
-- @return number progress 0..1, number alpha 0..1
function A.Step(s, dt, inp)
    if inp.hovering then s.sinceHover = 0 else s.sinceHover = (s.sinceHover or A.HIDE_DELAY) + dt end

    local want = (not inp.autoHide) or inp.hovering or s.sinceHover < A.HIDE_DELAY
        or (inp.keepOutOfCombat and not inp.inCombat)
    if inp.inCombat and inp.combatMode == "hide" then want = false end

    local target = want and 1 or 0
    local stepAmount = dt / A.SLIDE_TIME
    if s.progress < target then
        s.progress = math.min(target, s.progress + stepAmount)
    elseif s.progress > target then
        s.progress = math.max(target, s.progress - stepAmount)
    end

    local alpha = 1
    if inp.inCombat and inp.combatMode == "fade" and not inp.hovering then alpha = inp.fadeAlpha or 0.3 end
    return s.progress, alpha
end

--- @param edge string "top" | "bottom"
--- @param cursorY number|nil cursor height in UIParent units, from the bottom
--- @param screenHeight number UIParent height
--- @param zone number px
function A.CursorInZone(edge, cursorY, screenHeight, zone)
    if type(cursorY) ~= "number" then return false end
    if edge == "bottom" then return cursorY <= zone end
    return cursorY >= (screenHeight or 0) - zone
end
```

The "keep shown out of combat: still hides in combat" check runs two one-second steps: the first starts `sinceHover` at the delay (the state was created hidden), so the bar never comes out.

Add to `HorizonSuite.toc` after `modules/Meridian/MeridianFormat.lua`:

```
modules/Meridian/MeridianAutoHide.lua
```

- [ ] **Step 4: Run the tests**

Expected: `73 passed, 0 failed`.

- [ ] **Step 5: Commit**

```bash
git add modules/Meridian/MeridianAutoHide.lua tools/test_meridian_logic.js HorizonSuite.toc
```
```bash
git commit -m "feat(meridian): add the auto-hide state machine" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: The bar, the module, and its defaults

**Files:**
- Create: `modules/Meridian/MeridianBar.lua`, `modules/Meridian/MeridianModule.lua`
- Create: `options/modules/defaults/OptionsDefaultsMeridian.lua`
- Modify: `HorizonSuite.lua` (`EnsureModulesDB`, lines 140-190)
- Modify: `HorizonSuite.toc`: `MeridianBar.lua` and `MeridianModule.lua` after `modules/Echo/EchoModule.lua`; `options/modules/defaults/OptionsDefaultsMeridian.lua` after `options/modules/defaults/OptionsDefaultsEcho.lua`
- Modify: `tools/test_options_modules.js` (`FILES`: add the defaults file in TOC position)
- Modify: `tools/test_meridian_logic.js`
- Modify: `locales/horizon/enUS.lua`

**Interfaces:**
- Consumes: everything Task 1 produces; `Meridian.AutoHide`; `addon.GetModuleScale(name)`; `addon.Echo.Round` (`Apply(frame, { radius, border })`, `SetColor`, `SetBorderColor`, `Layout`), which loads whether or not Echo is enabled.
- Produces, on `addon.Meridian.Bar`: `Enable()`, `Disable()`, `ApplyOptions()`, `Layout()`, `RefreshBlock(def) -> changed`, `RequestRefresh(id)`, `LayoutAfterCombat()`, `ComputeX(widths, barWidth, pad, gap)`, `_buttons`, `_driver`.
- Produces, on `addon.Meridian`: `ApplyOptions()`, `NotifyOwnershipChanged()`, `OpenSettings()`.
- Produces: `addon.MERIDIAN_DEFAULTS`, `addon.MERIDIAN_LIMITS`, `addon.MERIDIAN_KEYS`.

Layout rule: `Attach(button)` runs for every block that is on and available, shown or not; `Detach(button)` runs for every other block that has a button. Block order reads left to right on every side.

- [ ] **Step 1: Write the failing tests**

Add to `FILES`, after the auto-hide file: `'options/modules/defaults/OptionsDefaultsMeridian.lua'` is **not** in `FILES` (it reads the registry at load); the bar section loads it. Add `'modules/Meridian/MeridianBar.lua',` to `FILES`. Then add this frame-stub chunk straight after the `stubs` chunk:

```js
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
```

Add this section above the summary:

```js
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
  M._ResetForTests()
`, 'bar');
```

- [ ] **Step 2: Run to see it fail**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_meridian_logic.js`
Expected: exit 1, `ENOENT` for `MeridianBar.lua`.

- [ ] **Step 3: Write the defaults file**

Create `options/modules/defaults/OptionsDefaultsMeridian.lua`:

```lua
--[[
    Horizon Suite - Meridian - Option defaults
    Base settings, plus one enabled/side/order row per registered block (block files load
    with the modules, before this file), so the changed-from-default markers find them.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.MERIDIAN_DEFAULTS = {
    meridianEdge                 = "top",
    meridianStyle                = "strip",
    meridianAutoHide             = false,
    meridianKeepShownOutOfCombat = false,
    meridianCombat               = "show",
    meridianCombatFadeOpacity    = 30,
    meridianFontSize             = 12,
    meridianClockLocal           = true,
    meridianClock24Hour          = false,
    meridianCoordPrecision       = 1,
    meridianSeededFromVista      = false,
}

addon.MERIDIAN_LIMITS = {
    meridianFontSize          = { min = 9, max = 18 },
    meridianCombatFadeOpacity = { min = 0, max = 100 },
    meridianBlockOrder        = { min = 1, max = 100 },
}

local M = addon.Meridian
if M and M.All then
    for _, def in ipairs(M.All()) do
        addon.MERIDIAN_DEFAULTS[M.Key(def.id, "enabled")] = def.defaultOn
        addon.MERIDIAN_DEFAULTS[M.Key(def.id, "side")]    = def.defaultSide
        addon.MERIDIAN_DEFAULTS[M.Key(def.id, "order")]   = def.defaultOrder
    end
end

addon.MERIDIAN_KEYS = {}
for key in pairs(addon.MERIDIAN_DEFAULTS) do addon.MERIDIAN_KEYS[key] = true end
```

- [ ] **Step 4: Write the bar**

Create `modules/Meridian/MeridianBar.lua`:

```lua
--[[
    Horizon Suite - Meridian - Bar
    The strip: one frame on the top or bottom screen edge, three sections (left, centre,
    right), a button per block, the Strip and Capsules styles, the shared ticker and event
    refresh, tooltips, clicks and the right-click menu. Data comes only from the registry.
    Blizzard: CreateFrame, UIParent, GameTooltip, GetCursorPosition, InCombatLockdown,
    MenuUtil.CreateContextMenu, C_Timer.After.
]]

local addon = _G.HorizonSuite
if not addon then return end
local Meridian = addon.Meridian
if not Meridian then return end

local L = addon.L

local Bar = {}
Meridian.Bar = Bar

Bar.HEIGHT = 26
Bar.PAD = 10        -- inset of the left and right sections from the screen edge
Bar.GAP = 12        -- space between blocks
Bar.ICON = 14
Bar.ICON_GAP = 4
Bar.TICK = 0.25     -- shared ticker resolution, seconds
Bar.PILL_PAD = 8
Bar.PILL_H = 20
Bar.STRIP_BG = { 0.04, 0.05, 0.06, 0.78 }
Bar.TEXT = { 0.85, 0.86, 0.89 }
Bar.ICON_TINT = { 0.54, 0.56, 0.63 }

local frame, bg, accentLine, edgeLine, driver
local buttons = {}
local pills = {}
local state
local cfg = {}
local inp = {}
local tickAcc = 0
local sinceTick = {}
local layoutAfterCombat = false
local disablePending = false

Bar._buttons = buttons

local LAYOUT_EVENTS = { PLAYER_ENTERING_WORLD = true, DISPLAY_SIZE_CHANGED = true, UI_SCALE_CHANGED = true }

local function InCombat()
    return (InCombatLockdown and InCombatLockdown()) and true or false
end

local function ReadConfig()
    cfg.edge = Meridian.Setting("meridianEdge") == "bottom" and "bottom" or "top"
    cfg.capsules = Meridian.Setting("meridianStyle") == "capsules"
    cfg.autoHide = Meridian.Setting("meridianAutoHide") and true or false
    cfg.keepOutOfCombat = Meridian.Setting("meridianKeepShownOutOfCombat") and true or false
    cfg.combatMode = Meridian.Setting("meridianCombat") or "show"
    cfg.fadeAlpha = (tonumber(Meridian.Setting("meridianCombatFadeOpacity")) or 30) / 100
    cfg.fontSize = tonumber(Meridian.Setting("meridianFontSize")) or 12
end

--- Left edge x of each block, per side. Order reads left to right on every side.
-- @param widths table { left = {w...}, centre = {w...}, right = {w...} }
-- @return table { left = {x...}, centre = {x...}, right = {x...} }
function Bar.ComputeX(widths, barWidth, pad, gap)
    local out = { left = {}, centre = {}, right = {} }
    local function total(ws)
        local t = 0
        for i = 1, #ws do t = t + ws[i] end
        if #ws > 1 then t = t + gap * (#ws - 1) end
        return t
    end
    local function place(ws, startX, dest)
        local x = startX
        for i = 1, #ws do dest[i] = x; x = x + ws[i] + gap end
    end
    place(widths.left or {}, pad, out.left)
    local c = widths.centre or {}
    place(c, (barWidth - total(c)) / 2, out.centre)
    local r = widths.right or {}
    place(r, barWidth - pad - total(r), out.right)
    return out
end

local function IconColor(def)
    if def.iconAccent then return Meridian.Accent() end
    local c = def.iconColor
    if type(c) == "function" then
        local ok, v = pcall(c)
        c = ok and v or nil
    end
    c = c or Bar.ICON_TINT
    return c[1], c[2], c[3]
end

local function TooltipBelongsToBar()
    if not (GameTooltip and GameTooltip.IsShown and GameTooltip:IsShown()) then return false end
    local owner = GameTooltip.GetOwner and GameTooltip:GetOwner()
    for _ = 1, 3 do
        if not owner then return false end
        if owner == frame then return true end
        owner = owner.GetParent and owner:GetParent()
    end
    return false
end

-- ---------------------------------------------------------------------------
-- Tooltips, clicks, menu
-- ---------------------------------------------------------------------------

function Bar.OnBlockEnter(b)
    local def = Meridian.Get(b.id)
    if not def or not GameTooltip then return end
    GameTooltip:SetOwner(b, cfg.edge == "bottom" and "ANCHOR_TOP" or "ANCHOR_BOTTOM")
    GameTooltip:ClearLines()
    GameTooltip:SetText(def.label or def.id, 1, 1, 1, 1, false)
    if def.OnTooltipShow then pcall(def.OnTooltipShow, GameTooltip) end
    if def.combatLocked and InCombat() then
        GameTooltip:AddLine(L["MERIDIAN_NOT_IN_COMBAT"], 1, 0.35, 0.35)
    end
    GameTooltip:Show()
end

function Bar.OnBlockLeave()
    if GameTooltip then GameTooltip:Hide() end
end

function Bar.OpenMenu(b, def)
    if not (MenuUtil and type(MenuUtil.CreateContextMenu) == "function") then return end
    pcall(MenuUtil.CreateContextMenu, b, function(_, root)
        if def.OnMenu then
            pcall(def.OnMenu, root)
            root:CreateDivider()
        end
        root:CreateButton(L["MERIDIAN_MENU_HIDE_BLOCK"], function()
            local set = addon.OptionsData_SetDB or addon.SetDB
            if set then set(Meridian.Key(def.id, "enabled"), false) end
            Meridian.ApplyOptions()
        end)
        root:CreateButton(L["MERIDIAN_MENU_SETTINGS"], Meridian.OpenSettings)
    end)
end

function Bar.OnBlockClick(b, mouseButton)
    local def = Meridian.Get(b.id)
    if not def then return end
    if mouseButton == "RightButton" then Bar.OpenMenu(b, def) return end
    if def.combatLocked and InCombat() then return end
    if def.OnClick then pcall(def.OnClick, b) end
end

-- ---------------------------------------------------------------------------
-- Blocks
-- ---------------------------------------------------------------------------

local function CreateBlockButton(id)
    local b = CreateFrame("Button", nil, frame)
    b:SetHeight(Bar.HEIGHT)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetSize(Bar.ICON, Bar.ICON)
    b.text = b:CreateFontString(nil, "OVERLAY")
    b.text:SetFont(Meridian.FontPath(), cfg.fontSize or 12, "")
    b.text:SetShadowOffset(1, -1)
    b.text:SetShadowColor(0, 0, 0, 0.8)
    b.text:SetTextColor(Bar.TEXT[1], Bar.TEXT[2], Bar.TEXT[3])
    b.id = id
    b:SetScript("OnEnter", Bar.OnBlockEnter)
    b:SetScript("OnLeave", Bar.OnBlockLeave)
    b:SetScript("OnClick", Bar.OnBlockClick)
    b:Hide()
    buttons[id] = b
    return b
end

--- Re-read one block's text and icon.
-- @return boolean true when the block's width, or whether it shows, changed
function Bar.RefreshBlock(def)
    if not frame then return false end
    local b = buttons[def.id] or CreateBlockButton(def.id)
    local value = Meridian.SafeText(def)
    local icon = def.icon
    if type(icon) == "function" then
        local ok, v = pcall(icon)
        icon = ok and v or nil
    end

    b.icon:ClearAllPoints()
    b.text:ClearAllPoints()
    local w = 0
    if icon then
        b.icon:SetTexture(icon)
        b.icon:SetVertexColor(IconColor(def))
        b.icon:SetPoint("LEFT", b, "LEFT", 0, 0)
        b.icon:Show()
        w = Bar.ICON
    else
        b.icon:Hide()
    end
    if value and value ~= "" then
        b.text:SetText(value)
        if icon then
            b.text:SetPoint("LEFT", b.icon, "RIGHT", Bar.ICON_GAP, 0)
            w = w + Bar.ICON_GAP
        else
            b.text:SetPoint("LEFT", b, "LEFT", 0, 0)
        end
        b.text:Show()
        w = w + (tonumber(b.text:GetStringWidth()) or 0)
    else
        b.text:SetText("")
        b.text:Hide()
    end
    if def.width then w = math.max(w, def.width) end
    w = math.floor(w + 0.5)

    local changed = ((b.value == nil) ~= (value == nil)) or b._width ~= w
    b.value, b._width = value, w
    return changed
end

function Bar.LayoutPills(lists, xs, widths)
    local Round = addon.Echo and addon.Echo.Round
    for _, side in ipairs(Meridian.SIDES) do
        local pill = pills[side]
        local list = lists[side]
        if cfg.capsules and #list > 0 then
            if not pill then
                pill = CreateFrame("Frame", nil, frame)
                pill:SetFrameLevel(frame:GetFrameLevel())
                if Round then
                    Round.Apply(pill, { radius = Bar.PILL_H / 2, border = true })
                    Round.SetColor(pill, 1, 1, 1, 0.07)
                    Round.SetBorderColor(pill, 1, 1, 1, 0.12)
                else
                    local t = pill:CreateTexture(nil, "BACKGROUND")
                    t:SetAllPoints(pill)
                    t:SetColorTexture(1, 1, 1, 0.07)
                end
                pills[side] = pill
            end
            local first = xs[side][1]
            local last = xs[side][#list] + widths[side][#list]
            pill:ClearAllPoints()
            pill:SetPoint("LEFT", frame, "LEFT", first - Bar.PILL_PAD, 0)
            pill:SetSize(last - first + Bar.PILL_PAD * 2, Bar.PILL_H)
            if Round and Round.Layout then Round.Layout(pill) end
            pill:Show()
        elseif pill then
            pill:Hide()
        end
    end
end

function Bar.Layout()
    if not frame or not Meridian._active then return end
    local lists, widths, available = {}, {}, {}
    for _, side in ipairs(Meridian.SIDES) do
        local list, ws = {}, {}
        for _, def in ipairs(Meridian.Layout(side)) do
            available[def.id] = def
            Bar.RefreshBlock(def)
            local b = buttons[def.id]
            if b.value ~= nil then
                list[#list + 1] = b
                ws[#ws + 1] = b._width
            else
                b:Hide()
            end
        end
        lists[side], widths[side] = list, ws
    end

    local xs = Bar.ComputeX(widths, frame:GetWidth() or 0, Bar.PAD, Bar.GAP)
    for _, side in ipairs(Meridian.SIDES) do
        for i, b in ipairs(lists[side]) do
            b:ClearAllPoints()
            b:SetPoint("LEFT", frame, "LEFT", xs[side][i], 0)
            b:SetWidth(math.max(1, b._width))
            b:Show()
        end
    end

    for id, b in pairs(buttons) do
        local def = Meridian.Get(id)
        if available[id] then
            if def.Attach then pcall(def.Attach, b) end
        else
            b:Hide()
            if def and def.Detach then pcall(def.Detach, b) end
        end
    end

    Bar.LayoutPills(lists, xs, widths)
end

--- Refresh one block now (hooks call this), relaying out when its size changed.
function Bar.RequestRefresh(id)
    local def = Meridian.Get(id)
    if not def or not frame or not Meridian._active then return end
    if Bar.RefreshBlock(def) then Bar.Layout() end
end

--- Run Layout again when combat ends (a block's Attach could not finish in combat).
function Bar.LayoutAfterCombat()
    layoutAfterCombat = true
    if driver then pcall(driver.RegisterEvent, driver, "PLAYER_REGEN_ENABLED") end
end

-- ---------------------------------------------------------------------------
-- Frame, edge, slide
-- ---------------------------------------------------------------------------

function Bar.Create()
    if frame then return frame end
    frame = CreateFrame("Frame", "HorizonSuiteMeridianBar", UIParent)
    frame:SetFrameStrata("HIGH")
    frame:SetHeight(Bar.HEIGHT)

    bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frame)
    bg:SetColorTexture(Bar.STRIP_BG[1], Bar.STRIP_BG[2], Bar.STRIP_BG[3], Bar.STRIP_BG[4])

    accentLine = frame:CreateTexture(nil, "BORDER")
    accentLine:SetHeight(1)

    edgeLine = CreateFrame("Frame", "HorizonSuiteMeridianEdge", UIParent)
    edgeLine:SetFrameStrata("HIGH")
    edgeLine:SetHeight(2)
    edgeLine.tex = edgeLine:CreateTexture(nil, "ARTWORK")
    edgeLine.tex:SetAllPoints(edgeLine)
    edgeLine:Hide()

    driver = CreateFrame("Frame")
    Bar._driver = driver
    driver:SetScript("OnEvent", function(_, event, ...) Bar.OnEvent(event, ...) end)
    return frame
end

function Bar.ApplyEdge()
    if not frame then return end
    local hidden = 1 - ((state and state.progress) or 1)
    local offset = hidden * (Bar.HEIGHT + 2)
    frame:ClearAllPoints()
    accentLine:ClearAllPoints()
    edgeLine:ClearAllPoints()
    if cfg.edge == "bottom" then
        frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, -offset)
        frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, -offset)
        accentLine:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        accentLine:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
        edgeLine:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
        edgeLine:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
    else
        frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, offset)
        frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, offset)
        accentLine:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
        accentLine:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        edgeLine:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
        edgeLine:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
    end
end

local function FillInputs()
    local hovering = false
    if GetCursorPosition and UIParent then
        local _, y = GetCursorPosition()
        local s = (UIParent.GetEffectiveScale and UIParent:GetEffectiveScale()) or 1
        if y and s and s > 0 then
            hovering = Meridian.AutoHide.CursorInZone(cfg.edge, y / s, UIParent:GetHeight() or 0,
                Meridian.AutoHide.EDGE_ZONE)
        end
    end
    if not hovering and frame:IsShown() and frame:IsMouseOver() then hovering = true end
    if not hovering and TooltipBelongsToBar() then hovering = true end
    local inCombat = InCombat() or ((UnitAffectingCombat and UnitAffectingCombat("player")) and true or false)
    inp.autoHide = cfg.autoHide
    inp.keepOutOfCombat = cfg.keepOutOfCombat
    inp.combatMode = cfg.combatMode
    inp.fadeAlpha = cfg.fadeAlpha
    inp.inCombat = inCombat
    inp.hovering = hovering
end

local function OnUpdate(_, elapsed)
    FillInputs()
    local before = state.progress
    local progress, alpha = Meridian.AutoHide.Step(state, elapsed, inp)
    if progress ~= before then Bar.ApplyEdge() end
    frame:SetAlpha(alpha)
    local out = progress > 0
    if out ~= frame:IsShown() then frame:SetShown(out) end
    local showLine = inp.autoHide and progress < 1 and not (inp.inCombat and inp.combatMode == "hide")
    edgeLine:SetShown(showLine)
    if showLine then edgeLine:SetAlpha(1 - progress) end

    tickAcc = tickAcc + elapsed
    if tickAcc < Bar.TICK then return end
    local dt = tickAcc
    tickAcc = 0
    if not out then return end

    local changed = false
    for _, def in ipairs(Meridian.All()) do
        if def.tick and Meridian.IsBlockOn(def.id) and Meridian.IsAvailable(def.id) then
            local t = (sinceTick[def.id] or def.tick) + dt  -- a block's first tick refreshes at once
            if t >= def.tick then
                t = 0
                if Bar.RefreshBlock(def) then changed = true end
            end
            sinceTick[def.id] = t
        end
    end
    if changed then Bar.Layout() end
end

-- ---------------------------------------------------------------------------
-- Events
-- ---------------------------------------------------------------------------

function Bar.RegisterEvents()
    if not driver then return end
    driver:UnregisterAllEvents()
    local seen = {}
    local function reg(ev)
        if seen[ev] then return end
        seen[ev] = true
        pcall(driver.RegisterEvent, driver, ev)  -- an event one client lacks errors at registration
    end
    for ev in pairs(LAYOUT_EVENTS) do reg(ev) end
    reg("PLAYER_REGEN_ENABLED")
    for _, def in ipairs(Meridian.All()) do
        if def.events then
            for _, ev in ipairs(def.events) do reg(ev) end
        end
    end
end

local function DetachAll()
    for id, b in pairs(buttons) do
        local def = Meridian.Get(id)
        if def and def.Detach then pcall(def.Detach, b) end
        b:Hide()
    end
end

function Bar.OnEvent(event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        if disablePending then
            disablePending = false
            DetachAll()
            driver:UnregisterAllEvents()
            return
        end
        if Meridian._ownershipPending then
            Meridian._ownershipPending = false
            Meridian.NotifyOwnershipChanged()
        end
        if layoutAfterCombat then
            layoutAfterCombat = false
            Bar.Layout()
        end
        return
    end
    if LAYOUT_EVENTS[event] then Bar.Layout() return end

    local changed = false
    for _, def in ipairs(Meridian.All()) do
        if def.events and Meridian.IsBlockOn(def.id) and Meridian.IsAvailable(def.id) then
            for _, ev in ipairs(def.events) do
                if ev == event then
                    if def.OnEvent then pcall(def.OnEvent, event, ...) end
                    if Bar.RefreshBlock(def) then changed = true end
                    break
                end
            end
        end
    end
    if changed then Bar.Layout() end
end

-- ---------------------------------------------------------------------------
-- Options, enable, disable
-- ---------------------------------------------------------------------------

function Bar.ApplyOptions()
    if not frame then return end
    ReadConfig()
    local scale = (addon.GetModuleScale and addon.GetModuleScale("meridian")) or 1
    frame:SetScale(scale)
    edgeLine:SetScale(scale)
    local r, g, b = Meridian.Accent()
    accentLine:SetColorTexture(r, g, b, 1)
    edgeLine.tex:SetColorTexture(r, g, b, 0.55)
    bg:SetShown(not cfg.capsules)
    accentLine:SetShown(not cfg.capsules)
    local font = Meridian.FontPath()
    for _, btn in pairs(buttons) do btn.text:SetFont(font, cfg.fontSize, "") end
    if state and not cfg.autoHide then state.progress = 1 end
    Bar.ApplyEdge()
    Bar.Layout()
end

function Bar.Enable()
    Bar.Create()
    ReadConfig()
    disablePending = false
    state = Meridian.AutoHide.New(not cfg.autoHide)
    Meridian._active = true
    Bar.RegisterEvents()
    Bar.ApplyOptions()
    frame:Show()
    driver:SetScript("OnUpdate", OnUpdate)
    -- Other modules may still be enabling; lay out again on the next frame.
    C_Timer.After(0, function() if Meridian._active then Bar.Layout() end end)
    Meridian.NotifyOwnershipChanged()
end

function Bar.Disable()
    Meridian._active = false
    if driver then driver:SetScript("OnUpdate", nil) end
    if InCombat() then
        -- Detaching hands Blizzard's queue button back, which waits for combat to end.
        disablePending = true
        if driver then
            driver:UnregisterAllEvents()
            pcall(driver.RegisterEvent, driver, "PLAYER_REGEN_ENABLED")
        end
    else
        DetachAll()
        if driver then driver:UnregisterAllEvents() end
    end
    for _, btn in pairs(buttons) do btn:Hide() end
    if frame then frame:Hide() end
    if edgeLine then edgeLine:Hide() end
    Meridian.NotifyOwnershipChanged()
end

-- A block registered after the bar is up (a module's own file) gets its events and a slot.
Meridian.OnBlocksChanged = function()
    if Meridian._active then
        Bar.RegisterEvents()
        Bar.Layout()
    end
end

--- Re-apply after any Meridian setting changes (OptionsData routes here).
function Meridian.ApplyOptions()
    if not Meridian._active then return end
    Bar.ApplyOptions()
    Meridian.NotifyOwnershipChanged()
end

--- Tell Vista which readouts Meridian now draws, so it hides or restores its own.
function Meridian.NotifyOwnershipChanged()
    local V = addon.Vista
    if not V then return end
    if InCombat() then
        Meridian._ownershipPending = true
        if driver then pcall(driver.RegisterEvent, driver, "PLAYER_REGEN_ENABLED") end
        return
    end
    C_Timer.After(0, function()
        if V.ApplyOptions then V.ApplyOptions("vistaShowTimeText") end
        if V.UpdateMailIndicator then V.UpdateMailIndicator() end
        if V.RefreshMailAnchor then V.RefreshMailAnchor() end
        if V.RefreshQueueProxies then V.RefreshQueueProxies() end
    end)
end

--- Open the dashboard on Meridian's page.
function Meridian.OpenSettings()
    local dash = _G.HorizonSuiteDashboard
    local shown = dash and type(dash.IsShown) == "function" and dash:IsShown()
    if not shown then
        local show = addon.ShowOptions or _G.HorizonSuite_ShowOptions
        if type(show) ~= "function" then return end
        pcall(show)
        dash = _G.HorizonSuiteDashboard
    end
    if dash and type(dash.OpenModule) == "function" then
        pcall(dash.OpenModule, L["NAME_ADDON_INFOBAR"], "meridian")
    end
end
```

- [ ] **Step 5: Write the module registration**

Create `modules/Meridian/MeridianModule.lua`:

```lua
--[[
    Horizon Suite - Meridian - Module
    An info bar along the screen edge. Registers with addon:RegisterModule.
]]

local addon = _G.HorizonSuite
if not addon or not addon.RegisterModule then return end

addon:RegisterModule("meridian", {
    title       = "Horizon Meridian",
    description = "An info bar along the screen edge: time, gold, durability, mail and shortcuts into the rest of Horizon.",
    order       = 29,

    OnInit = function()
        -- Seed the clock and coordinate settings from Vista's, once per profile, so a player
        -- who chose 24-hour time on the minimap keeps it on the bar.
        if not addon.GetDB or not addon.SetDB then return end
        if addon.GetDB("meridianSeededFromVista", false) then return end
        addon.SetDB("meridianClockLocal", addon.GetDB("vistaTimeUseLocal", true))
        addon.SetDB("meridianClock24Hour", addon.GetDB("vistaTime24Hour", false))
        addon.SetDB("meridianCoordPrecision", addon.GetDB("vistaCoordPrecision", 1))
        addon.SetDB("meridianSeededFromVista", true)
    end,

    OnEnable = function()
        if addon.Meridian and addon.Meridian.Bar then addon.Meridian.Bar.Enable() end
    end,

    OnDisable = function()
        if addon.Meridian and addon.Meridian.Bar then addon.Meridian.Bar.Disable() end
    end,
})
```

In `HorizonSuite.lua` `EnsureModulesDB`, add `db.modules.meridian = { enabled = false }` after `db.modules.echo = { enabled = false }` in the first-install block, and after the echo upgrade guard add:

```lua
    -- Ensure meridian exists for existing installs; off by default like every module
    if not db.modules.meridian then
        db.modules.meridian = { enabled = false }
    end
```

In `HorizonSuite.toc`, add after `modules/Echo/EchoModule.lua`:

```
modules/Meridian/MeridianBar.lua
modules/Meridian/MeridianModule.lua
```

and after `options/modules/defaults/OptionsDefaultsEcho.lua`:

```
options/modules/defaults/OptionsDefaultsMeridian.lua
```

In `tools/test_options_modules.js` `FILES`, add `'options/modules/defaults/OptionsDefaultsMeridian.lua',` after the Echo defaults line.

Add to `locales/horizon/enUS.lua`, at the end, under a new banner:

```lua
-- =====================================================================================
-- Meridian — info bar
-- =====================================================================================
L["NAME_ADDON_INFOBAR"]                                         = "Meridian"
L["MERIDIAN_NOT_IN_COMBAT"]                                     = "Not available in combat"
L["MERIDIAN_MENU_HIDE_BLOCK"]                                   = "Hide this block"
L["MERIDIAN_MENU_SETTINGS"]                                     = "Meridian settings"
```

(Match the file's banner style and `=` column; the em dash in a code comment is fine, it never reaches a player.)

- [ ] **Step 6: Run the tests**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_meridian_logic.js`
Expected: `91 passed, 0 failed`.
Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_modules.js`
Expected: `48 passed` (the file list now includes the Meridian defaults file and still matches the TOC).
Run the parse check on `HorizonSuite.lua` and the five Meridian files. Expected: each `parses`.

- [ ] **Step 7: Commit**

```bash
git add modules/Meridian/MeridianBar.lua modules/Meridian/MeridianModule.lua options/modules/defaults/OptionsDefaultsMeridian.lua HorizonSuite.lua HorizonSuite.toc tools/test_options_modules.js tools/test_meridian_logic.js locales/horizon/enUS.lua
```
```bash
git commit -m "feat(meridian): add the bar frame and module registration" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 5: Phase 1 blocks and glyphs

**Files:**
- Create: `modules/Meridian/blocks/MeridianBlocksTime.lua`, `MeridianBlocksWorld.lua`, `MeridianBlocksCharacter.lua`, `MeridianBlocksNotices.lua`, `MeridianBlocksActions.lua`
- Create: `tools/icons/meridian/{horizon,clock,pin,pulse,coins,shield,bag,mail}.svg` and the rendered `media/meridian/*.tga`
- Modify: `HorizonSuite.toc` (block files after `MeridianAutoHide.lua`, before any module, so `MeridianBar.lua` is not needed at their load)
- Modify: `.github/workflows/luacheck.yml`, `tools/test_meridian_logic.js`, `locales/horizon/enUS.lua`

**Interfaces:**
- Consumes: `Meridian.RegisterBlock`, `Meridian.Setting`, `Meridian.Format`, `Meridian.Glyph`.
- Produces block ids: `horizon`, `clock`, `coords`, `perf`, `gold`, `durability`, `bags`, `mail`.

Default placement:

| id | side | order | on |
|----|------|-------|----|
| horizon | left | 10 | yes |
| clock | centre | 10 | yes |
| coords | right | 10 | yes |
| perf | right | 20 | yes |
| gold | right | 30 | yes |
| durability | right | 40 | yes |
| bags | right | 50 | yes |
| mail | right | 60 | yes (contextual) |

- [ ] **Step 1: Write the failing tests**

Add this section above the summary:

```js
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
  for _, id in ipairs({ "horizon", "clock", "coords", "perf", "gold", "durability", "bags", "mail" }) do
    check("blocks: " .. id .. " registered", M.Get(id) ~= nil)
  end
  check("blocks: clock defaults to the centre", M.BlockSide("clock") == "centre")

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
```

- [ ] **Step 2: Run to see it fail**

Expected: exit 1, `ENOENT` for `MeridianBlocksTime.lua`.

- [ ] **Step 3: Write the glyphs and render them**

Create each file in `tools/icons/meridian/` with this wrapper, replacing `<!-- shapes -->` with the shapes listed:

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
  <!-- shapes -->
</svg>
```

| File | Shapes |
|------|--------|
| `horizon.svg` | `<path d="M3 17h18"/>` `<path d="M6.5 17a5.5 5.5 0 0 1 11 0"/>` `<path d="M12 5v2.5"/>` `<path d="M5.2 8.2l1.6 1.6"/>` `<path d="M18.8 8.2l-1.6 1.6"/>` |
| `clock.svg` | `<circle cx="12" cy="12" r="8.5"/>` `<path d="M12 7.5V12l3 2"/>` |
| `pin.svg` | `<path d="M12 21s-6.5-6.2-6.5-11a6.5 6.5 0 0 1 13 0c0 4.8-6.5 11-6.5 11z"/>` `<circle cx="12" cy="10" r="2.3"/>` |
| `pulse.svg` | `<path d="M3 12h4l2.5-6 5 12 2.5-6h4"/>` |
| `coins.svg` | `<circle cx="9.5" cy="9.5" r="5"/>` `<path d="M14.9 10.6a5 5 0 1 1-4.3 4.3"/>` |
| `shield.svg` | `<path d="M12 3.5l7 2.5v5.5c0 4.4-3 7.6-7 9-4-1.4-7-4.6-7-9V6z"/>` |
| `bag.svg` | `<path d="M5 8.5h14l-1 11.5H6z"/>` `<path d="M9 8.5V7a3 3 0 0 1 6 0v1.5"/>` |
| `mail.svg` | `<path d="M5.5 6h13a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2h-13a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2z"/>` `<path d="M4 7.5l8 6 8-6"/>` |

Render them:

Run: `python3 tools/make_module_icons.py --src tools/icons/meridian --out media/meridian`
Expected: one `.tga` per SVG in `media/meridian/`. Then `python3 tools/make_module_icons.py --check --src tools/icons/meridian --out media/meridian` exits 0.

In `.github/workflows/luacheck.yml`, after the line `python3 tools/make_module_icons.py --check`, add (same indentation):

```yaml
          python3 tools/make_module_icons.py --check --src tools/icons/meridian --out media/meridian
```

- [ ] **Step 4: Write the block files**

Create `modules/Meridian/blocks/MeridianBlocksTime.lua`:

```lua
--[[
    Horizon Suite - Meridian - Clock block
    Blizzard: date, GetGameTime, C_DateAndTime, SecondsToTime, TimeManagerFrame, C_AddOns.
]]

local addon = _G.HorizonSuite
if not addon then return end
local Meridian = addon.Meridian
if not Meridian or not Meridian.RegisterBlock then return end

local F = Meridian.Format
local L = addon.L

local function ClockText()
    local use24 = Meridian.Setting("meridianClock24Hour") and true or false
    if Meridian.Setting("meridianClockLocal") ~= false then
        local t = date("*t")
        return F.Clock(t.hour, t.min, use24)
    end
    if not GetGameTime then return nil end
    local h, m = GetGameTime()
    if h == nil then return nil end
    return F.Clock(h, m, use24)
end

-- Same chain as Vista's clock (VistaCore.lua CreateDecor); loads the time manager on demand.
local function ToggleStopwatch()
    if not TimeManagerFrame and C_AddOns and C_AddOns.LoadAddOn then
        pcall(C_AddOns.LoadAddOn, "Blizzard_TimeManager")
    end
    if TimeManagerFrame then
        if TimeManagerFrame:IsShown() then TimeManagerFrame:Hide() else TimeManagerFrame:Show() end
    elseif type(ToggleTimeManager) == "function" then
        ToggleTimeManager()
    end
end

local function AddReset(tooltip, label, seconds)
    if type(seconds) ~= "number" or seconds <= 0 then return end
    local text = (SecondsToTime and SecondsToTime(seconds, true)) or (math.floor(seconds / 3600) .. "h")
    tooltip:AddDoubleLine(label, text, 0.7, 0.7, 0.7, 1, 1, 1)
end

Meridian.RegisterBlock({
    id = "clock",
    label = L["MERIDIAN_BLOCK_CLOCK"],
    icon = Meridian.Glyph("clock"),
    text = ClockText,
    tick = 1,
    OnClick = ToggleStopwatch,
    OnTooltipShow = function(tooltip)
        local D = C_DateAndTime
        if D and D.GetSecondsUntilDailyReset then AddReset(tooltip, L["MERIDIAN_DAILY_RESET"], D.GetSecondsUntilDailyReset()) end
        if D and D.GetSecondsUntilWeeklyReset then AddReset(tooltip, L["MERIDIAN_WEEKLY_RESET"], D.GetSecondsUntilWeeklyReset()) end
        tooltip:AddLine(L["MERIDIAN_CLICK_STOPWATCH"], 0.6, 0.6, 0.6)
    end,
    defaultSide = "centre", defaultOrder = 10, defaultOn = true,
})
```

Create `modules/Meridian/blocks/MeridianBlocksWorld.lua`:

```lua
--[[
    Horizon Suite - Meridian - Coordinates and performance blocks
    Blizzard: C_Map, GetZoneText, GetSubZoneText, ToggleWorldMap, GetFramerate, GetNetStats.
]]

local addon = _G.HorizonSuite
if not addon then return end
local Meridian = addon.Meridian
if not Meridian or not Meridian.RegisterBlock then return end

local F = Meridian.Format
local L = addon.L

local function CoordsText()
    if not (C_Map and C_Map.GetBestMapForUnit and C_Map.GetPlayerMapPosition) then return nil end
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then return nil end
    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if not pos then return nil end
    local x, y = pos:GetXY()
    return F.Coords(x, y, tonumber(Meridian.Setting("meridianCoordPrecision")) or 1)
end

Meridian.RegisterBlock({
    id = "coords",
    label = L["MERIDIAN_BLOCK_COORDS"],
    icon = Meridian.Glyph("pin"),
    text = CoordsText,
    tick = 0.25,
    OnClick = function() if ToggleWorldMap then ToggleWorldMap() end end,
    OnTooltipShow = function(tooltip)
        local zone = GetZoneText and GetZoneText() or ""
        local sub = GetSubZoneText and GetSubZoneText() or ""
        if zone ~= "" then tooltip:AddLine(zone, 1, 1, 1) end
        if sub ~= "" and sub ~= zone then tooltip:AddLine(sub, 0.8, 0.8, 0.8) end
        tooltip:AddLine(L["MERIDIAN_CLICK_MAP"], 0.6, 0.6, 0.6)
    end,
    defaultSide = "right", defaultOrder = 10, defaultOn = true,
})

local function NetStats()
    if not GetNetStats then return 0, 0 end
    local _, _, home, world = GetNetStats()
    return home or 0, world or home or 0
end

Meridian.RegisterBlock({
    id = "perf",
    label = L["MERIDIAN_BLOCK_PERF"],
    icon = Meridian.Glyph("pulse"),
    text = function()
        local _, world = NetStats()
        return F.Perf(GetFramerate and GetFramerate() or 0, world)
    end,
    tick = 1,
    OnTooltipShow = function(tooltip)
        local home, world = NetStats()
        tooltip:AddDoubleLine(L["MERIDIAN_PERF_FPS"], tostring(math.floor(GetFramerate and GetFramerate() or 0)), 0.7, 0.7, 0.7, 1, 1, 1)
        tooltip:AddDoubleLine(L["MERIDIAN_PERF_HOME"], home .. " ms", 0.7, 0.7, 0.7, 1, 1, 1)
        tooltip:AddDoubleLine(L["MERIDIAN_PERF_WORLD"], world .. " ms", 0.7, 0.7, 0.7, 1, 1, 1)
    end,
    defaultSide = "right", defaultOrder = 20, defaultOn = true,
})
```

Create `modules/Meridian/blocks/MeridianBlocksCharacter.lua`:

```lua
--[[
    Horizon Suite - Meridian - Gold, durability and bag blocks
    Blizzard: GetMoney, GetMoneyString, GetInventoryItemDurability, GetInventoryItemLink,
    C_Container.GetContainerNumFreeSlots, ToggleAllBags, ToggleCharacter.
]]

local addon = _G.HorizonSuite
if not addon then return end
local Meridian = addon.Meridian
if not Meridian or not Meridian.RegisterBlock then return end

local F = Meridian.Format
local L = addon.L

local WARN = { 0.95, 0.70, 0.30 }
local BAD = { 0.90, 0.30, 0.30 }

-- Gold ---------------------------------------------------------------------------

local sessionStart

Meridian.RegisterBlock({
    id = "gold",
    label = L["MERIDIAN_BLOCK_GOLD"],
    icon = Meridian.Glyph("coins"),
    iconColor = { 0.90, 0.76, 0.35 },
    text = function()
        if not GetMoney then return nil end
        local money = GetMoney()
        if sessionStart == nil then sessionStart = money end
        return F.Gold(money)
    end,
    events = { "PLAYER_MONEY", "PLAYER_ENTERING_WORLD" },
    OnClick = function() if ToggleAllBags then ToggleAllBags() end end,
    OnTooltipShow = function(tooltip)
        if not GetMoney then return end
        local money = GetMoney()
        if GetMoneyString then tooltip:AddLine(GetMoneyString(money, true), 1, 1, 1) end
        tooltip:AddDoubleLine(L["MERIDIAN_GOLD_SESSION"], F.GoldDelta(money - (sessionStart or money)), 0.7, 0.7, 0.7, 1, 1, 1)
    end,
    defaultSide = "right", defaultOrder = 30, defaultOn = true,
})

-- Durability ---------------------------------------------------------------------

-- Head, shoulder, chest, waist, legs, feet, wrist, hands, main hand, off hand, ranged.
local SLOTS = { 1, 3, 5, 6, 7, 8, 9, 10, 16, 17, 18 }

local function ReadSlots()
    local out = {}
    for i = 1, #SLOTS do
        local cur, max
        if GetInventoryItemDurability then cur, max = GetInventoryItemDurability(SLOTS[i]) end
        out[#out + 1] = { cur, max, SLOTS[i] }
    end
    return out
end

local function Lowest() return F.LowestDurability(ReadSlots()) end

Meridian.RegisterBlock({
    id = "durability",
    label = L["MERIDIAN_BLOCK_DURABILITY"],
    icon = Meridian.Glyph("shield"),
    iconColor = function()
        local low = Lowest()
        if low and low <= 25 then return BAD end
        if low and low <= 50 then return WARN end
        return nil
    end,
    text = function()
        local low = Lowest()
        return low and F.Percent(low) or nil
    end,
    events = { "UPDATE_INVENTORY_DURABILITY", "PLAYER_ENTERING_WORLD" },
    OnClick = function()
        if addon:IsModuleEnabled("essence") and addon.Essence and addon.Essence.Toggle then
            addon.Essence.Toggle()
        elseif ToggleCharacter then
            ToggleCharacter("PaperDollFrame")
        end
    end,
    OnTooltipShow = function(tooltip)
        local any = false
        for _, s in ipairs(ReadSlots()) do
            local cur, max, slot = s[1], s[2], s[3]
            if type(cur) == "number" and type(max) == "number" and max > 0 and cur < max then
                any = true
                local link = GetInventoryItemLink and GetInventoryItemLink("player", slot)
                tooltip:AddDoubleLine(link or tostring(slot), F.Percent(cur / max * 100), 1, 1, 1, 1, 1, 1)
            end
        end
        if not any then tooltip:AddLine(L["MERIDIAN_DURABILITY_ALL_GOOD"], 0.7, 0.7, 0.7) end
    end,
    defaultSide = "right", defaultOrder = 40, defaultOn = true,
})

-- Bags -------------------------------------------------------------------------

local function FreeSlots()
    local total = 0
    local C = C_Container
    for bag = 0, (NUM_BAG_SLOTS or 4) do
        local free, bagType
        if C and C.GetContainerNumFreeSlots then
            free, bagType = C.GetContainerNumFreeSlots(bag)
        elseif GetContainerNumFreeSlots then
            free, bagType = GetContainerNumFreeSlots(bag)
        end
        -- Only general bags: a profession bag's space doesn't hold just anything.
        if free and (bagType == nil or bagType == 0) then total = total + free end
    end
    return total
end

Meridian.RegisterBlock({
    id = "bags",
    label = L["MERIDIAN_BLOCK_BAGS"],
    icon = Meridian.Glyph("bag"),
    iconColor = function()
        local n = FreeSlots()
        if n == 0 then return BAD end
        if n <= 5 then return WARN end
        return nil
    end,
    text = function() return tostring(FreeSlots()) end,
    events = { "BAG_UPDATE_DELAYED", "PLAYER_ENTERING_WORLD" },
    OnClick = function() if ToggleAllBags then ToggleAllBags() end end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine(string.format(L["MERIDIAN_BAGS_FREE_FMT"], FreeSlots()), 0.7, 0.7, 0.7)
    end,
    defaultSide = "right", defaultOrder = 50, defaultOn = true,
})
```

Create `modules/Meridian/blocks/MeridianBlocksNotices.lua`:

```lua
--[[
    Horizon Suite - Meridian - Mail and queue blocks
    Blizzard: HasNewMail, GetLatestThreeSenders. (The queue block is added in Task 7.)
]]

local addon = _G.HorizonSuite
if not addon then return end
local Meridian = addon.Meridian
if not Meridian or not Meridian.RegisterBlock then return end

local L = addon.L

Meridian.RegisterBlock({
    id = "mail",
    label = L["MERIDIAN_BLOCK_MAIL"],
    icon = Meridian.Glyph("mail"),
    iconAccent = true,
    text = function()
        if HasNewMail and HasNewMail() then return "" end
        return nil
    end,
    events = { "UPDATE_PENDING_MAIL", "PLAYER_ENTERING_WORLD", "MAIL_CLOSED", "MAIL_INBOX_UPDATE" },
    OnTooltipShow = function(tooltip)
        local a, b, c
        if GetLatestThreeSenders then a, b, c = GetLatestThreeSenders() end
        if a then
            tooltip:AddLine(L["MERIDIAN_MAIL_FROM"], 0.7, 0.7, 0.7)
            tooltip:AddLine(a, 1, 1, 1)
            if b then tooltip:AddLine(b, 1, 1, 1) end
            if c then tooltip:AddLine(c, 1, 1, 1) end
        else
            tooltip:AddLine(L["MERIDIAN_MAIL_UNREAD"], 0.7, 0.7, 0.7)
        end
    end,
    defaultSide = "right", defaultOrder = 60, defaultOn = true,
})
```

Create `modules/Meridian/blocks/MeridianBlocksActions.lua`:

```lua
--[[
    Horizon Suite - Meridian - Horizon menu block (teleports are added in Task 7)
    Blizzard: StaticPopupDialogs, StaticPopup_Show, ReloadUI.
]]

local addon = _G.HorizonSuite
if not addon then return end
local Meridian = addon.Meridian
if not Meridian or not Meridian.RegisterBlock then return end

local L = addon.L

local RELOAD_POPUP = "HORIZONSUITE_MERIDIAN_RELOAD"

local function AskReload()
    if not (StaticPopupDialogs and StaticPopup_Show) then return end
    if not StaticPopupDialogs[RELOAD_POPUP] then
        StaticPopupDialogs[RELOAD_POPUP] = {
            text = L["MERIDIAN_RELOAD_PROMPT"],
            button1 = L["RELOAD_UI"],
            button2 = L["MERIDIAN_RELOAD_LATER"],
            OnAccept = function() ReloadUI() end,
            timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
        }
    end
    StaticPopup_Show(RELOAD_POPUP)
end

local function ModuleName(key, m)
    if addon.GetModuleDisplayName then
        local name = addon.GetModuleDisplayName(key)
        if name and name ~= "" then return name end
    end
    return m.title or key
end

Meridian.RegisterBlock({
    id = "horizon",
    label = L["MERIDIAN_BLOCK_HORIZON"],
    icon = Meridian.Glyph("horizon"),
    iconAccent = true,
    text = function() return "" end,
    OnClick = function() if addon.ShowDashboard then addon.ShowDashboard() end end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine(L["MERIDIAN_HORIZON_TOOLTIP"], 0.7, 0.7, 0.7)
    end,
    OnMenu = function(root)
        root:CreateTitle(L["MERIDIAN_MENU_MODULES"])
        if not addon.IterateModules then return end
        for key, m in addon:IterateModules() do
            root:CreateCheckbox(ModuleName(key, m),
                function() return addon:IsModuleEnabled(key) and true or false end,
                function()
                    addon:SetModuleEnabled(key, not addon:IsModuleEnabled(key), { deferReload = true })
                    AskReload()
                end)
        end
    end,
    defaultSide = "left", defaultOrder = 10, defaultOn = true,
})
```

In `HorizonSuite.toc`, after `modules/Meridian/MeridianAutoHide.lua`:

```
modules/Meridian/blocks/MeridianBlocksTime.lua
modules/Meridian/blocks/MeridianBlocksWorld.lua
modules/Meridian/blocks/MeridianBlocksCharacter.lua
modules/Meridian/blocks/MeridianBlocksNotices.lua
modules/Meridian/blocks/MeridianBlocksActions.lua
```

Add to the Meridian banner in `locales/horizon/enUS.lua`:

```lua
L["MERIDIAN_BLOCK_HORIZON"]                                     = "Horizon"
L["MERIDIAN_HORIZON_TOOLTIP"]                                   = "Click to open Horizon. Right-click for your modules."
L["MERIDIAN_MENU_MODULES"]                                      = "Modules"
L["MERIDIAN_RELOAD_PROMPT"]                                     = "Reload the interface to apply your module changes?"
L["MERIDIAN_RELOAD_LATER"]                                      = "Later"
L["MERIDIAN_BLOCK_CLOCK"]                                       = "Clock"
L["MERIDIAN_DAILY_RESET"]                                       = "Daily reset"
L["MERIDIAN_WEEKLY_RESET"]                                      = "Weekly reset"
L["MERIDIAN_CLICK_STOPWATCH"]                                   = "Click for the stopwatch"
L["MERIDIAN_BLOCK_COORDS"]                                      = "Coordinates"
L["MERIDIAN_CLICK_MAP"]                                         = "Click to open the map"
L["MERIDIAN_BLOCK_PERF"]                                        = "Performance"
L["MERIDIAN_PERF_FPS"]                                          = "Frame rate"
L["MERIDIAN_PERF_HOME"]                                         = "Home latency"
L["MERIDIAN_PERF_WORLD"]                                        = "World latency"
L["MERIDIAN_BLOCK_GOLD"]                                        = "Gold"
L["MERIDIAN_GOLD_SESSION"]                                      = "This session"
L["MERIDIAN_BLOCK_DURABILITY"]                                  = "Durability"
L["MERIDIAN_DURABILITY_ALL_GOOD"]                               = "Everything is fully repaired"
L["MERIDIAN_BLOCK_BAGS"]                                        = "Bags"
L["MERIDIAN_BAGS_FREE_FMT"]                                     = "%d free bag slots"
L["MERIDIAN_BLOCK_MAIL"]                                        = "Mail"
L["MERIDIAN_MAIL_FROM"]                                         = "From"
L["MERIDIAN_MAIL_UNREAD"]                                       = "You have unread mail"
```

`L["RELOAD_UI"]` already exists (Echo uses it).

- [ ] **Step 5: Run the tests**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_meridian_logic.js`
Expected: `113 passed, 0 failed`.
Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_modules.js`
Expected: `48 passed`.

- [ ] **Step 6: Commit**

```bash
git add modules/Meridian/blocks tools/icons/meridian media/meridian .github/workflows/luacheck.yml HorizonSuite.toc tools/test_meridian_logic.js locales/horizon/enUS.lua
```
```bash
git commit -m "feat(meridian): add the phase 1 blocks and their glyphs" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 6: Settings page and Axis wiring

**Files:**
- Create: `options/modules/OptionsMeridian.lua`
- Modify: `HorizonSuite.toc` (after `options/modules/OptionsEcho.lua`)
- Modify: `options/OptionsData.lua`, `options/OptionsDefaults.lua`, `options/modules/defaults/OptionsDefaultsAxis.lua`, `options/modules/OptionsGlobal.lua`, `options/OptionsHelpers.lua`, `options/OptionsSearch.lua`
- Modify: `tools/test_options_modules.js`, `locales/horizon/enUS.lua`

**Interfaces:**
- Consumes: `addon.MERIDIAN_DEFAULTS`, `MERIDIAN_LIMITS`, `MERIDIAN_KEYS`; `addon.Meridian.All()`, `Key()`, `ApplyOptions()`; `addon.Section`, `addon.Toggle`, `addon.RegisterModulePages`, `addon.OptionsData_GetDB/SetDB`.
- Produces: a category `{ key = "Meridian", moduleKey = "meridian" }` with pages `meridian:general`, `meridian:layout`, `meridian:look`, `meridian:blocks`.

- [ ] **Step 1: Update the options test first**

In `tools/test_options_modules.js`:
- `PREREQS`: add, in TOC order, `'modules/Meridian/MeridianRegistry.lua'`, `'modules/Meridian/MeridianFormat.lua'` and the five `modules/Meridian/blocks/*.lua` files (the defaults file builds a row per registered block).
- `FILES`: add `'options/modules/OptionsMeridian.lua',` after `'options/modules/OptionsEcho.lua',`.
- `EXPECTED`: add `meridian: ['meridian:general', 'meridian:layout', 'meridian:look', 'meridian:blocks'],`.
- The defaults-table name list near line 359: add `"MERIDIAN_DEFAULTS"`.

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_modules.js`
Expected: FAIL on the TOC file-list check and on the missing `meridian` pages.

- [ ] **Step 2: Write the options page**

Create `options/modules/OptionsMeridian.lua`:

```lua
--[[
    Horizon Suite - Meridian - Options
    Visibility, position, style, readouts, and a Blocks page with one card per block.
]]

local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end
local L = addon.L

local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end
local Section, Toggle = addon.Section, addon.Toggle

local D   = addon.MERIDIAN_DEFAULTS
local LIM = addon.MERIDIAN_LIMITS
local M   = addon.Meridian

local function clamp(v, key)
    local lim = LIM[key]
    return math.max(lim.min, math.min(lim.max, v))
end

addon.RegisterModulePages("meridian", {
    { key = "blocks", name = L["MERIDIAN_PAGE_BLOCKS"] },
})

local options = {
    Section(L["MERIDIAN_SECTION_VISIBILITY"], { page = "general", card = "visibility" }),
    Toggle(L["MERIDIAN_AUTO_HIDE"], L["MERIDIAN_AUTO_HIDE_DESC"], "meridianAutoHide", D.meridianAutoHide),
    Toggle(L["MERIDIAN_KEEP_SHOWN"], L["MERIDIAN_KEEP_SHOWN_DESC"], "meridianKeepShownOutOfCombat",
        D.meridianKeepShownOutOfCombat, { parent = "meridianAutoHide" }),
    { type = "dropdown", name = L["MERIDIAN_COMBAT"], desc = L["MERIDIAN_COMBAT_DESC"], dbKey = "meridianCombat",
      options = { { L["MERIDIAN_COMBAT_SHOW"], "show" }, { L["MERIDIAN_COMBAT_FADE"], "fade" }, { L["MERIDIAN_COMBAT_HIDE"], "hide" } },
      preserveOrder = true,
      get = function() return getDB("meridianCombat", D.meridianCombat) end,
      set = function(v) setDB("meridianCombat", v) end,
      refreshIds = { "meridianCombatFadeOpacity" } },
    { type = "slider", name = L["MERIDIAN_COMBAT_FADE_OPACITY"], desc = L["MERIDIAN_COMBAT_FADE_OPACITY_DESC"],
      dbKey = "meridianCombatFadeOpacity", min = LIM.meridianCombatFadeOpacity.min, max = LIM.meridianCombatFadeOpacity.max, step = 5,
      get = function() return tonumber(getDB("meridianCombatFadeOpacity", D.meridianCombatFadeOpacity)) or D.meridianCombatFadeOpacity end,
      set = function(v) setDB("meridianCombatFadeOpacity", clamp(v, "meridianCombatFadeOpacity")) end,
      visibleWhen = function() return getDB("meridianCombat", D.meridianCombat) == "fade" end },

    Section(L["MERIDIAN_SECTION_READOUTS"], { page = "general", card = "behaviour" }),
    Toggle(L["MERIDIAN_CLOCK_LOCAL"], L["MERIDIAN_CLOCK_LOCAL_DESC"], "meridianClockLocal", D.meridianClockLocal),
    Toggle(L["MERIDIAN_CLOCK_24H"], L["MERIDIAN_CLOCK_24H_DESC"], "meridianClock24Hour", D.meridianClock24Hour),
    { type = "dropdown", name = L["MERIDIAN_COORD_PRECISION"], desc = L["MERIDIAN_COORD_PRECISION_DESC"], dbKey = "meridianCoordPrecision",
      options = { { "45, 62", 0 }, { "45.2, 61.8", 1 }, { "45.22, 61.84", 2 } },
      preserveOrder = true,
      get = function() return tonumber(getDB("meridianCoordPrecision", D.meridianCoordPrecision)) or 1 end,
      set = function(v) setDB("meridianCoordPrecision", tonumber(v) or 1) end },

    Section(L["AXIS_POSITION"], { page = "layout", card = "position" }),
    { type = "dropdown", name = L["MERIDIAN_EDGE"], desc = L["MERIDIAN_EDGE_DESC"], dbKey = "meridianEdge",
      options = { { L["MERIDIAN_EDGE_TOP"], "top" }, { L["MERIDIAN_EDGE_BOTTOM"], "bottom" } },
      preserveOrder = true,
      get = function() return getDB("meridianEdge", D.meridianEdge) end,
      set = function(v) setDB("meridianEdge", v) end },

    Section(L["MERIDIAN_SECTION_SIZE"], { page = "layout", card = "size" }),
    { type = "slider", name = L["MERIDIAN_FONT_SIZE"], desc = L["MERIDIAN_FONT_SIZE_DESC"], dbKey = "meridianFontSize",
      min = LIM.meridianFontSize.min, max = LIM.meridianFontSize.max, step = 1,
      get = function() return tonumber(getDB("meridianFontSize", D.meridianFontSize)) or D.meridianFontSize end,
      set = function(v) setDB("meridianFontSize", clamp(v, "meridianFontSize")) end },

    Section(L["MERIDIAN_SECTION_STYLE"], { page = "look", card = "background" }),
    { type = "dropdown", name = L["MERIDIAN_STYLE"], desc = L["MERIDIAN_STYLE_DESC"], dbKey = "meridianStyle",
      options = { { L["MERIDIAN_STYLE_STRIP"], "strip" }, { L["MERIDIAN_STYLE_CAPSULES"], "capsules" } },
      preserveOrder = true,
      get = function() return getDB("meridianStyle", D.meridianStyle) end,
      set = function(v) setDB("meridianStyle", v) end },
}

-- One card per block on the Blocks page.
local SIDE_OPTIONS = {
    { L["MERIDIAN_SIDE_LEFT"], "left" }, { L["MERIDIAN_SIDE_CENTRE"], "centre" }, { L["MERIDIAN_SIDE_RIGHT"], "right" },
}
if M and M.All then
    for _, def in ipairs(M.All()) do
        local onKey, sideKey, orderKey = M.Key(def.id, "enabled"), M.Key(def.id, "side"), M.Key(def.id, "order")
        options[#options + 1] = Section(def.label or def.id, { page = "blocks", requires = def.requires })
        options[#options + 1] = Toggle(L["MERIDIAN_BLOCK_SHOW"], L["MERIDIAN_BLOCK_SHOW_DESC"], onKey, def.defaultOn,
            { requires = def.requires })
        options[#options + 1] = { type = "dropdown", name = L["MERIDIAN_BLOCK_SIDE"], desc = L["MERIDIAN_BLOCK_SIDE_DESC"],
            dbKey = sideKey, options = SIDE_OPTIONS, preserveOrder = true, parent = onKey, requires = def.requires,
            get = function() return getDB(sideKey, def.defaultSide) end,
            set = function(v) setDB(sideKey, v) end }
        options[#options + 1] = { type = "slider", name = L["MERIDIAN_BLOCK_ORDER"], desc = L["MERIDIAN_BLOCK_ORDER_DESC"],
            dbKey = orderKey, min = LIM.meridianBlockOrder.min, max = LIM.meridianBlockOrder.max, step = 1,
            parent = onKey, requires = def.requires,
            get = function() return tonumber(getDB(orderKey, def.defaultOrder)) or def.defaultOrder end,
            set = function(v) setDB(orderKey, clamp(v, "meridianBlockOrder")) end }
    end
end

addon.OptionCategories[#addon.OptionCategories + 1] = {
    key = "Meridian", name = L["NAME_ADDON_INFOBAR"], desc = L["MERIDIAN_DESC"], moduleKey = "meridian", options = options,
}
```

In `HorizonSuite.toc`, add after `options/modules/OptionsEcho.lua`:

```
options/modules/OptionsMeridian.lua
```

- [ ] **Step 3: Route Meridian settings and add the Axis rows**

`options/OptionsData.lua`, in `OptionsData_SetDB` after the `ECHO_KEYS` block:

```lua
    if (addon.MERIDIAN_KEYS and addon.MERIDIAN_KEYS[key]) or key:sub(1, 14) == "meridianBlock_" then
        if addon.Meridian and addon.Meridian.ApplyOptions then addon.Meridian.ApplyOptions() end
        return  -- nothing outside Meridian reads these; skip the Focus layout notify
    end
```

In the same function's `useGlobalFont` block, add:

```lua
        if addon.Meridian and addon.Meridian.ApplyOptions then addon.Meridian.ApplyOptions() end
```

In its `CLASS_COLOR_KEYS` block, add:

```lua
        if key == "classColorMeridian" and addon.Meridian and addon.Meridian.ApplyOptions then
            addon.Meridian.ApplyOptions()
        end
```

`options/OptionsDefaults.lua`: add `meridianUIScale = true,` to `SCALE_DEBOUNCE_KEYS` and `classColorMeridian = true,` to `CLASS_COLOR_KEYS`.

`options/modules/defaults/OptionsDefaultsAxis.lua`: add `classColorMeridian = false,` after `classColorEcho`, `meridianUIScale = 1.0,` after `augmentUIScale`, and `meridianUIScale_pct = { min = 50, max = 200 },` to `AXIS_LIMITS`.

`options/modules/OptionsGlobal.lua`:
- add `"classColorMeridian"` to the `classColorKeys` list (line 245);
- after the `classColorEcho` toggle row (line 346) add:

```lua
            opts[#opts + 1] = { type = "toggle", name = BM and BM("meridian"), desc = L["MERIDIAN_CLASS_COLOURS_DESC"], dbKey = "classColorMeridian", get = function() return getDB("classColorMeridian", false) end, set = function(v) setDB("classColorMeridian", v) end, refreshIds = { "_classColorAll" } }
```

- in `refreshAllScaling`, add `if addon.Meridian and addon.Meridian.ApplyOptions then addon.Meridian.ApplyOptions() end`;
- after the Insight scale slider add:

```lua
            opts[#opts + 1] = { type = "slider", name = L["MERIDIAN_SCALE"], desc = L["AXIS_SCALE_MERIDIAN"], dbKey = "meridianUIScale_pct", min = 50, max = 200,
                parent = "perModuleScaling",
                get = function()
                    return math.floor((tonumber(getDB("meridianUIScale", 1)) or 1) * 100 + 0.5)
                end, set = function(v)
                    setDB("meridianUIScale", math.max(50, math.min(200, v)) / 100)
                    debouncedRefresh("meridian", function()
                        if addon.Meridian and addon.Meridian.ApplyOptions then addon.Meridian.ApplyOptions() end
                    end)
                end }
```

`options/OptionsHelpers.lua` `DEFAULT_TABLES`: add `"MERIDIAN_DEFAULTS"` before `"AXIS_DEFAULTS"`.

`options/OptionsSearch.lua` `MODULE_ALIASES`: add `meridian = "info bar titan panel clock gold durability bags mail",`.

Add to the Meridian banner in `locales/horizon/enUS.lua`:

```lua
L["MERIDIAN_DESC"]                                              = "An info bar along the screen edge."
L["MERIDIAN_PAGE_BLOCKS"]                                       = "Blocks"
L["MERIDIAN_SECTION_VISIBILITY"]                                = "Visibility"
L["MERIDIAN_AUTO_HIDE"]                                         = "Auto-hide"
L["MERIDIAN_AUTO_HIDE_DESC"]                                    = "Slide the bar away until you point at the screen edge."
L["MERIDIAN_KEEP_SHOWN"]                                        = "Keep shown out of combat"
L["MERIDIAN_KEEP_SHOWN_DESC"]                                   = "Only auto-hide while you're in combat."
L["MERIDIAN_COMBAT"]                                            = "In combat"
L["MERIDIAN_COMBAT_DESC"]                                       = "Show, fade or hide the bar while you're in combat."
L["MERIDIAN_COMBAT_SHOW"]                                       = "Show"
L["MERIDIAN_COMBAT_FADE"]                                       = "Fade"
L["MERIDIAN_COMBAT_HIDE"]                                       = "Hide"
L["MERIDIAN_COMBAT_FADE_OPACITY"]                               = "Combat opacity"
L["MERIDIAN_COMBAT_FADE_OPACITY_DESC"]                          = "How visible the bar stays while faded."
L["MERIDIAN_SECTION_READOUTS"]                                  = "Readouts"
L["MERIDIAN_CLOCK_LOCAL"]                                       = "Use local time"
L["MERIDIAN_CLOCK_LOCAL_DESC"]                                  = "Off shows realm time."
L["MERIDIAN_CLOCK_24H"]                                         = "24-hour clock"
L["MERIDIAN_CLOCK_24H_DESC"]                                    = "Show 21:37 instead of 9:37 PM."
L["MERIDIAN_COORD_PRECISION"]                                   = "Coordinate decimals"
L["MERIDIAN_COORD_PRECISION_DESC"]                              = "How precise the coordinates are."
L["MERIDIAN_EDGE"]                                              = "Screen edge"
L["MERIDIAN_EDGE_DESC"]                                         = "Dock the bar to the top or bottom of the screen."
L["MERIDIAN_EDGE_TOP"]                                          = "Top"
L["MERIDIAN_EDGE_BOTTOM"]                                       = "Bottom"
L["MERIDIAN_SECTION_SIZE"]                                      = "Size"
L["MERIDIAN_FONT_SIZE"]                                         = "Text size"
L["MERIDIAN_FONT_SIZE_DESC"]                                    = "Size of the values on the bar."
L["MERIDIAN_SECTION_STYLE"]                                     = "Style"
L["MERIDIAN_STYLE"]                                             = "Bar style"
L["MERIDIAN_STYLE_DESC"]                                        = "Strip is a dark band across the screen. Capsules puts each group in its own pill."
L["MERIDIAN_STYLE_STRIP"]                                       = "Strip"
L["MERIDIAN_STYLE_CAPSULES"]                                    = "Capsules"
L["MERIDIAN_BLOCK_SHOW"]                                        = "Show"
L["MERIDIAN_BLOCK_SHOW_DESC"]                                   = "Show this block on the bar."
L["MERIDIAN_BLOCK_SIDE"]                                        = "Side"
L["MERIDIAN_BLOCK_SIDE_DESC"]                                   = "Which part of the bar this block sits in."
L["MERIDIAN_SIDE_LEFT"]                                         = "Left"
L["MERIDIAN_SIDE_CENTRE"]                                       = "Centre"
L["MERIDIAN_SIDE_RIGHT"]                                        = "Right"
L["MERIDIAN_BLOCK_ORDER"]                                       = "Order"
L["MERIDIAN_BLOCK_ORDER_DESC"]                                  = "Lower numbers sit further left."
L["MERIDIAN_CLASS_COLOURS_DESC"]                                = "Tint Meridian's accent line and icons."
L["MERIDIAN_SCALE"]                                             = "Meridian scale"
L["AXIS_SCALE_MERIDIAN"]                                        = "Scale the Meridian bar."
```

- [ ] **Step 4: Run the tests**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_modules.js`
Expected: `49 passed, 0 failed`, including "file list matches HorizonSuite.toc" and the Meridian pages on Retail. On the Forever pass the Blocks page has no rows whose `requires` is absent (none of the phase 1 blocks sets one).
Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_logic.js` — expected `443 passed`.
Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_meridian_logic.js` — expected `113 passed`.

If `Assemble.strict` rejects a Section (it errors at load when a category has an untagged Section), the failing Section is named in the error: give it a `page`.

- [ ] **Step 5: Commit**

```bash
git add options/modules/OptionsMeridian.lua options/OptionsData.lua options/OptionsDefaults.lua options/modules/defaults/OptionsDefaultsAxis.lua options/modules/OptionsGlobal.lua options/OptionsHelpers.lua options/OptionsSearch.lua HorizonSuite.toc tools/test_options_modules.js locales/horizon/enUS.lua
```
```bash
git commit -m "feat(meridian): add the settings page and Axis wiring" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 7: Vista hands over; queue and teleport blocks

**Files:**
- Modify: `modules/Vista/VistaCore.lua` (lines 155-161, 1282-1398, 2555-2780, after `LayoutTeleportMenu` ~2158)
- Modify: `modules/Meridian/blocks/MeridianBlocksNotices.lua`, `modules/Meridian/blocks/MeridianBlocksActions.lua`
- Create: `tools/icons/meridian/portal.svg`, `media/meridian/portal.tga`
- Modify: `tools/test_meridian_logic.js`, `locales/horizon/enUS.lua`

**Interfaces:**
- Consumes: `addon.Meridian.Owns(id)`; `Bar.LayoutAfterCombat()`, `Bar.RequestRefresh(id)`.
- Produces, on `addon.Vista`: `UpdateMailIndicator()`, `ReattachQueueButton()`, `ToggleTeleportMenu(owner, point, relativePoint, y) -> boolean`.
- Produces block ids `queue` (right, 70, on, contextual) and `teleports` (left, 20, off, `module = "vista"`, `combatLocked`).

- [ ] **Step 1: Write the failing queue tests**

Add above the summary:

```js
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
  COMBAT = false
  q.Detach(host)
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
```

- [ ] **Step 2: Run to see it fail**

Expected: FAIL on "queue: registered" (and an error on `q.text`, since `q` is nil): the run exits 1 with the `queue` chunk named.

- [ ] **Step 3: Write the queue block**

Append to `modules/Meridian/blocks/MeridianBlocksNotices.lua` (and update its header comment to mention the queue and `hooksecurefunc`):

```lua
-- Queue ------------------------------------------------------------------------
-- Hosts Blizzard's own queue button, as Vista does on the minimap, so its status
-- tooltip and right-click menu keep working. Never reparented in combat.

local QUEUE_SIZE = 20
local Q = { owned = false, host = nil, internal = false, saved = nil, hooked = false }

local function QueueButton()
    return _G["QueueStatusButton"] or _G["QueueStatusMinimapButton"] or _G["MiniMapBattlefieldFrame"]
end

local function InCombat()
    return (InCombatLockdown and InCombatLockdown()) and true or false
end

local function SavePlacement(btn)
    local okP, parent = pcall(btn.GetParent, btn)
    local saved = { parent = (okP and parent) or UIParent, points = {} }
    local okN, n = pcall(btn.GetNumPoints, btn)
    for i = 1, ((okN and n) or 0) do
        local ok, p, rel, rp, x, y = pcall(btn.GetPoint, btn, i)
        if ok and p then saved.points[#saved.points + 1] = { p, rel, rp, x, y } end
    end
    local okS, w, h = pcall(btn.GetSize, btn)
    if okS then saved.w, saved.h = w, h end
    return saved
end

local function Hosted(btn)
    if not Q.host then return false end
    local okP, parent = pcall(btn.GetParent, btn)
    if not okP or parent ~= Q.host then return false end
    local okPt, _, rel = pcall(btn.GetPoint, btn, 1)
    return okPt and rel == Q.host
end

local AttachQueue

local function HookOnce(btn)
    if Q.hooked or not hooksecurefunc then return end
    Q.hooked = true
    local function Recheck()
        if Q.internal or not Q.owned then return end
        if not Hosted(btn) then
            C_Timer.After(0, function() if Q.owned and Q.host then AttachQueue(Q.host) end end)
        end
    end
    hooksecurefunc(btn, "SetParent", Recheck)
    hooksecurefunc(btn, "SetPoint", Recheck)
    local function Changed()
        if Meridian.Bar and Meridian.Bar.RequestRefresh then Meridian.Bar.RequestRefresh("queue") end
    end
    hooksecurefunc(btn, "Show", Changed)
    hooksecurefunc(btn, "Hide", Changed)
end

AttachQueue = function(host)
    local btn = QueueButton()
    if not btn or not host then return end
    if Q.owned and Q.host == host and Hosted(btn) then return end
    if InCombat() then
        if Meridian.Bar and Meridian.Bar.LayoutAfterCombat then Meridian.Bar.LayoutAfterCombat() end
        return
    end
    if not Q.saved then Q.saved = SavePlacement(btn) end
    Q.owned, Q.host, Q.internal = true, host, true
    pcall(btn.SetParent, btn, host)
    pcall(btn.ClearAllPoints, btn)
    pcall(btn.SetPoint, btn, "CENTER", host, "CENTER", 0, 0)
    pcall(btn.SetSize, btn, QUEUE_SIZE, QUEUE_SIZE)
    pcall(btn.SetFrameLevel, btn, host:GetFrameLevel() + 2)
    pcall(btn.SetIgnoreParentAlpha, btn, false)  -- Vista sets it true; on the bar it fades with the bar
    Q.internal = false
    HookOnce(btn)
end

local function DetachQueue()
    if not Q.owned then return end
    if InCombat() then
        if Meridian.Bar and Meridian.Bar.LayoutAfterCombat then Meridian.Bar.LayoutAfterCombat() end
        return
    end
    local btn = QueueButton()
    Q.owned, Q.host = false, nil
    if btn then
        local V = addon.Vista
        if V and V.ReattachQueueButton and addon:IsModuleEnabled("vista") then
            V.ReattachQueueButton()
        elseif Q.saved then
            Q.internal = true
            pcall(btn.SetParent, btn, Q.saved.parent)
            pcall(btn.ClearAllPoints, btn)
            for i = 1, #Q.saved.points do
                local p = Q.saved.points[i]
                pcall(btn.SetPoint, btn, p[1], p[2], p[3], p[4], p[5])
            end
            if Q.saved.w and Q.saved.h then pcall(btn.SetSize, btn, Q.saved.w, Q.saved.h) end
            Q.internal = false
        end
    end
    Q.saved = nil
end

Meridian.RegisterBlock({
    id = "queue",
    label = L["MERIDIAN_BLOCK_QUEUE"],
    text = function()
        local btn = QueueButton()
        if btn and btn:IsShown() then return "" end
        return nil
    end,
    tick = 1,
    width = QUEUE_SIZE,
    Attach = AttachQueue,
    Detach = DetachQueue,
    defaultSide = "right", defaultOrder = 70, defaultOn = true,
})
```

Run the tests. Expected: the queue checks pass.

- [ ] **Step 4: Vista steps aside**

In `modules/Vista/VistaCore.lua`:

(a) Above `-- Visibility toggles` (line 155), add:

```lua
    -- Meridian (the info bar) draws some of these readouts itself when the player puts them on it.
    G.Owned = function(id)
        local M = addon.Meridian
        return (M and M.Owns and M.Owns(id)) and true or false
    end
```

and change three getters to:

```lua
    G.ShowCoord     = function() return DB("vistaShowCoordText",  true) and not G.Owned("coords") end
    G.ShowTime      = function() return DB("vistaShowTimeText",   true) and not G.Owned("clock") end
    G.ShowPerf      = function() return DB("vistaShowPerfText",   false) and not G.Owned("perf") end
```

(b) In `RefreshMailAnchor` (line 1282), straight after `if not mailAnchor then return end`:

```lua
    if G.Owned("mail") then
        mailAnchor:SetAlpha(0)
        mailAnchor._border:Hide()
        mailAnchor:Hide()
        return
    end
```

In `UpdateMailIndicator` (line 1392), straight after `if not mailFrame then return end`:

```lua
    if G.Owned("mail") then
        mailFrame:Hide()
        mailPulsing = false
        RefreshMailAnchor()
        return
    end
```

After the `UpdateMailIndicator` function ends, add:

```lua
Vista.UpdateMailIndicator = function() UpdateMailIndicator() end
```

(c) In the queue `do` block (starts ~line 2555), straight after `Vista._queueReattach = Vista._queueReattach or { internal = false, timer = nil }`:

```lua
    -- Queue handling is off when the player switched it off, or while Meridian hosts the button.
    local function QueueOff()
        return DB("vistaQueueHandlingDisabled", false) or G.Owned("queue")
    end
```

then, within that `do` block only (lines ~2560-2770), replace every `DB("vistaQueueHandlingDisabled", false)` with `QueueOff()`. There are nine (lines 2562, 2616, 2624, 2635, 2664, 2736, 2742, 2748, 2754 before this edit). Confirm with `grep -n 'vistaQueueHandlingDisabled' modules/Vista/VistaCore.lua`: only the `QueueOff` line remains inside the block.

Immediately before the `end` that closes this `do` block, add:

```lua
    -- Meridian calls this when it lets go of the queue button.
    Vista.ReattachQueueButton = function()
        if not queueAnchor then
            if CreateQueueAnchor then CreateQueueAnchor() end
        else
            ScheduleQueueButtonReattach()
        end
        if RefreshQueueAnchor then RefreshQueueAnchor() end
    end
```

(d) After the `LayoutTeleportMenu` function (ends ~line 2158), add:

```lua
--- Open or close the teleport menu beside any frame. Meridian's Teleports block uses it.
-- @return boolean whether it opened or closed
function Vista.ToggleTeleportMenu(owner, point, relativePoint, y)
    if not addon.Vista or not addon.Vista.GetTeleportMenuEntries then return false end
    local inCombat = InCombatLockdown()
    local menu = Vista._teleportMenu
    if menu and menu:IsShown() then
        if not inCombat then menu:Hide() end  -- can't hide a frame parenting secure rows in combat
        return true
    end
    if inCombat then return false end
    menu = EnsureTeleportMenu()
    if not menu then return false end
    menu._page = 1
    LayoutTeleportMenu(menu)
    menu:ClearAllPoints()
    menu:SetPoint(point or "TOPRIGHT", owner, relativePoint or "BOTTOMRIGHT", 0, y or -2)
    menu:Show()
    return true
end
```

Run the parse check on `modules/Vista/VistaCore.lua`. Expected: `parses`. If WoW later reports "too many local variables", one of these additions became a top-level local: move it into a field or a `do` block.

- [ ] **Step 5: Add the teleports block and its glyph**

Create `tools/icons/meridian/portal.svg` with the wrapper from Task 5 and shapes `<circle cx="12" cy="12" r="8"/>` `<path d="M12 7.5a4.5 4.5 0 1 0 4.5 4.5"/>`, then run `python3 tools/make_module_icons.py --src tools/icons/meridian --out media/meridian`.

Append to `modules/Meridian/blocks/MeridianBlocksActions.lua`:

```lua
Meridian.RegisterBlock({
    id = "teleports",
    label = L["MERIDIAN_BLOCK_TELEPORTS"],
    icon = Meridian.Glyph("portal"),
    text = function() return "" end,
    module = "vista",
    combatLocked = true,
    OnClick = function(b)
        local V = addon.Vista
        if not (V and V.ToggleTeleportMenu) then return end
        if Meridian.Setting("meridianEdge") == "bottom" then
            V.ToggleTeleportMenu(b, "BOTTOMLEFT", "TOPLEFT", 2)
        else
            V.ToggleTeleportMenu(b, "TOPLEFT", "BOTTOMLEFT", -2)
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine(L["MERIDIAN_TELEPORTS_TOOLTIP"], 0.7, 0.7, 0.7)
    end,
    defaultSide = "left", defaultOrder = 20, defaultOn = false,
})
```

Add `'teleports'` to the block id list in the Task 5 `blocks` test (with a check `M.Get("teleports").module == "vista"`), and to the Meridian banner in `enUS.lua`:

```lua
L["MERIDIAN_BLOCK_QUEUE"]                                       = "Queue"
L["MERIDIAN_BLOCK_TELEPORTS"]                                   = "Teleports"
L["MERIDIAN_TELEPORTS_TOOLTIP"]                                 = "Click for your teleports"
```

- [ ] **Step 6: Run everything**

Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_meridian_logic.js` — expected `125 passed, 0 failed`.
Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_modules.js` — `49 passed`.
Run: `python3 tools/make_module_icons.py --check --src tools/icons/meridian --out media/meridian` — exit 0.

- [ ] **Step 7: Commit (two commits: Vista, then Meridian)**

```bash
git add modules/Vista/VistaCore.lua
```
```bash
git commit -m "feat(vista): hand readouts to Meridian when it owns them" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```
```bash
git add modules/Meridian/blocks tools/icons/meridian media/meridian tools/test_meridian_logic.js locales/horizon/enUS.lua
```
```bash
git commit -m "feat(meridian): add the queue and teleport blocks" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 8: From "Coming soon" to a live module

**Files:**
- Modify: `core/Config.lua` (lines 712, 724)
- Modify: `locales/horizon/enUS.lua` and the six other `locales/horizon/*.lua`
- Modify: `options/dashboard/DashboardFrame.lua` (lines 135-160, 619, 1701), `options/dashboard/DashboardHomeWelcome.lua` (lines 29, 68-90), `options/dashboard/DashboardModuleGuide.lua` (lines 13-23, 110-116), `options/dashboard/DashboardPatchNotesContent.lua` (`PN_MODULE_COLORS`, ~line 30-42)
- Create: `tools/icons/meridian.svg`, `media/icons/meridian.tga`
- Modify: `Docs/Branding/ColourSchema.md`, `tools/make_update_card.py` (line ~40)

**Interfaces:** none new. Tests: the existing suites, plus `python3 tools/make_module_icons.py --check`.

- [ ] **Step 1: Brand-name keys**

The placeholder keys `NAME_ADDON_C-----S` and `AXIS_MODULE_NAME_SIMPLE_C-----S` become `NAME_ADDON_INFOBAR` and `AXIS_MODULE_NAME_SIMPLE_INFOBAR`.
- `core/Config.lua:712`: `meridian = L["NAME_ADDON_INFOBAR"],`; `:724`: `meridian = L["AXIS_MODULE_NAME_SIMPLE_INFOBAR"],`.
- `enUS.lua`: delete line 23 (`NAME_ADDON_C-----S`; `NAME_ADDON_INFOBAR` already exists from Task 4) and replace line 114 with `L["AXIS_MODULE_NAME_SIMPLE_INFOBAR"] = "Info bar"` (keep the column).
- The six other locale files hold these two keys only as commented stubs (`-- L["NAME_ADDON_C-----S"] …`, lines 21 and 111). Rename them in place:

```bash
sed -i '' -e 's/NAME_ADDON_C-----S/NAME_ADDON_INFOBAR/' -e 's/AXIS_MODULE_NAME_SIMPLE_C-----S/AXIS_MODULE_NAME_SIMPLE_INFOBAR/' -e 's/\(AXIS_MODULE_NAME_SIMPLE_INFOBAR"\][[:space:]]*= \)"Meridian"/\1"Info bar"/' locales/horizon/deDE.lua locales/horizon/esES.lua locales/horizon/frFR.lua locales/horizon/koKR.lua locales/horizon/ptBR.lua locales/horizon/zhCN.lua
```

Confirm `grep -rn 'C-----S' --include=*.lua .` prints nothing.

- [ ] **Step 2: Rewrite the placeholder copy**

In `enUS.lua`, replace the values of these keys and add the Home card line next to `HOME_MOD_ECHO_SHORT`:

```lua
L["DASH_GUIDE_MOD_MERIDIAN_BODY"]                             = "Meridian is a thin bar along the top or bottom of the screen with the time, your gold, durability and bag space, mail, your queue, and a menu into the rest of Horizon. Each block can be switched off or moved, and the bar can slide away until you point at the edge. Open Meridian in the sidebar to arrange it."
L["DASH_MERIDIAN_MODULE_SHORT_DESCRIPTION"]                   = "An info bar along the screen edge."
L["HOME_MOD_MERIDIAN_SHORT"]                                  = "An info bar along the screen edge."
```

In each of the six other locale files, the two keys are **active** lines (`= "Coming soon."`, or the old compass copy in `deDE.lua`), and an active line beats the English fallback. Comment them out and update their English reference text, so every language shows the new English until it is translated:

```bash
for f in deDE esES frFR koKR ptBR zhCN; do sed -i '' -e 's/^L\["DASH_GUIDE_MOD_MERIDIAN_BODY"\].*$/-- L["DASH_GUIDE_MOD_MERIDIAN_BODY"] = "(see enUS)"/' -e 's/^L\["DASH_MERIDIAN_MODULE_SHORT_DESCRIPTION"\].*$/-- L["DASH_MERIDIAN_MODULE_SHORT_DESCRIPTION"] = "(see enUS)"/' locales/horizon/$f.lua; done
```

Confirm with `grep -n 'MERIDIAN' locales/horizon/deDE.lua`: both lines start with `--`. Then run `node tools/restructure_locales.js` and inspect `git diff --stat locales/`. Keep its output only if every changed line is a Meridian key; otherwise `git checkout -- locales/horizon/deDE.lua locales/horizon/esES.lua locales/horizon/frFR.lua locales/horizon/koKR.lua locales/horizon/ptBR.lua locales/horizon/zhCN.lua`, redo the two `sed` commands above, and leave the restructure for a translators' pass.

- [ ] **Step 3: Dashboard lists and colours**

`options/dashboard/DashboardFrame.lua`:
- line 137: `local COMING_SOON_MODULE_KEYS = {}` (keep the variable: the guide and Home still read it).
- line 140: delete the comment "Meridian omitted: no colour assigned yet, falls back to neutral gray."
- `TILE_MODULE_LABEL_COLORS`: add `meridian = { 232/255, 217/255, 181/255 },  -- E8D9B5` after `echo`.
- `categoryIcons`: delete `["Meridian"] = "ability_tracking",` (the module-icon loop below now supplies it).
- line 619 `SEARCH_MODULE_FILTER_GROUP_ORDER` and line 1701 `groupOrder`: insert `"meridian"` after `"echo"`.

`options/dashboard/DashboardHomeWelcome.lua`:
- line 29: add `"meridian"` after `"echo"` in the icon key list.
- `MODULE_ORDER`: append `"meridian"`.
- `MODULE_COLORS`: add `meridian = { 0.91, 0.85, 0.71 },`.
- `MODULE_DESCS`: add `meridian = L["HOME_MOD_MERIDIAN_SHORT"],`.

`options/dashboard/DashboardModuleGuide.lua`:
- `GUIDE_MODULE_COLORS["Meridian"]` becomes `"E8D9B5"`.
- delete the row `{ key = "meridian", label = "Meridian", tag = soonTag, when = COMING_SOON_MODULE_KEYS },`.

`options/dashboard/DashboardPatchNotesContent.lua` `PN_MODULE_COLORS`: add `["Meridian"] = "E8D9B5",`.

`Docs/Branding/ColourSchema.md`: add a row after Echo's: `|Meridian|<span style="color:#E8D9B5;">#E8D9B5</span>|` (match the table's existing columns).

`tools/make_update_card.py`: add `"Meridian": "#E8D9B5",` after `"Echo": "#8FA3E8",`.

- [ ] **Step 4: Module icon**

Create `tools/icons/meridian.svg` with the same shapes as `tools/icons/meridian/horizon.svg` (Task 5). Run `python3 tools/make_module_icons.py`, then `python3 tools/make_module_icons.py --check` (exit 0) and `python3 tools/test_make_module_icons.py` (passes).

- [ ] **Step 5: Run every suite**

Run, each with `NODE_PATH="$HOME/.cache/hs-test/node_modules"`:
- `node tools/test_meridian_logic.js` — `125 passed`
- `node tools/test_options_modules.js` — all pass
- `node tools/test_options_logic.js` — `443 passed`
- `node tools/test_news_logic.js` and `python3 tools/test_build_news.py` — pass (they use "meridian" as their unknown-module example; this plan does not add it to the news module lists, so they are unaffected)

Run the parse check on every Lua file this task touched.

- [ ] **Step 6: Commit**

```bash
git add core/Config.lua locales/horizon options/dashboard tools/icons/meridian.svg media/icons/meridian.tga Docs/Branding/ColourSchema.md tools/make_update_card.py
```
```bash
git commit -m "feat(dashboard): turn Meridian from coming soon into a live module" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 9: In-game verification and hand-over

**Files:**
- Modify: `.luacheckrc` (read globals), `Docs/Engineering/2026-10-16-meridian-bar-design.md` (status line)

- [ ] **Step 1: Read globals**

For each name, check `grep -n '"<name>"' .luacheckrc` and add the missing ones to `read_globals`: `GetGameTime`, `GetFramerate`, `GetNetStats`, `HasNewMail`, `GetLatestThreeSenders`, `GetInventoryItemDurability`, `GetInventoryItemLink`, `C_Container`, `GetContainerNumFreeSlots`, `NUM_BAG_SLOTS`, `ToggleAllBags`, `ToggleCharacter`, `ToggleWorldMap`, `TimeManagerFrame`, `ToggleTimeManager`, `C_DateAndTime`, `SecondsToTime`, `GetMoney`, `GetMoneyString`, `GetCursorPosition`, `GetZoneText`, `GetSubZoneText`, `UnitAffectingCombat`, `StaticPopupDialogs`, `StaticPopup_Show`, `ReloadUI`, `MenuUtil`, `C_AddOns`, `QueueStatusButton`, `QueueStatusMinimapButton`, `MiniMapBattlefieldFrame`, `hooksecurefunc`. Commit:

```bash
git add .luacheckrc
```
```bash
git commit -m "chore(meridian): declare the WoW globals the bar reads" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

- [ ] **Step 2: Push and hand over the Windows pull**

Run: `git push -u origin feature/meridian`. Then give the director this PowerShell line (one line, `;`-separated; `;` carries on past a failed `cd`):

```powershell
cd "C:\Users\chris\HorizonSuite"; git fetch origin; git switch feature/meridian; git pull --rebase --autostash
```

New files were added to the TOC, so the client needs a **full exit and restart**, not `/reload`.

- [ ] **Step 3: Director's in-game checklist (Retail, then Forever)**

1. Axis → Modules: Meridian appears with the pale-gold icon and is off. Turn it on and reload.
2. The strip appears at the top: Horizon mark left; clock centre; coordinates, performance, gold, durability and bags right. Vista's clock, coordinates and FPS are gone from the minimap.
3. Hover each block: a tooltip with its label. Click: the clock opens the stopwatch, gold and bags open bags, durability opens the character panel (Essence's when Essence is on), coordinates open the map, the Horizon mark opens the dashboard.
4. Right-click the Horizon mark: module checkboxes, "Hide this block", "Meridian settings". Untick a module: the reload prompt appears.
5. Right-click gold, "Hide this block": gold disappears and the right side closes up.
6. Get mail (or have some waiting): the mail icon shows on the bar and not on the minimap. Its tooltip lists senders.
7. Queue for something: Blizzard's eye sits on the bar at the right, with its own tooltip and right-click menu. Leave the queue: the block disappears. Turn the Queue block off: the eye goes back to the minimap (Vista on) or its default spot (Vista off).
8. Settings → Meridian → Look → Bar style: Capsules. Each group sits in a soft pill and the dark band is gone.
9. Layout → Screen edge: Bottom. The bar moves to the bottom, accent line on its top edge.
10. General → Auto-hide on: the bar slides away after 1.5s, leaving a thin pale-gold line; pointing at the edge brings it back. "Keep shown out of combat": it stays out until you pull a mob.
11. In combat: set "In combat" to Fade (bar dims to 30%) and Hide (bar gone for the fight).
12. Blocks page: switch Teleports on (Vista on): its icon appears left; click it out of combat for the teleport menu; in combat its tooltip says "Not available in combat".
13. Axis: class tint for Meridian recolours the accent line and Horizon mark; per-module scaling shows a Meridian slider that resizes the bar.
14. Turn Meridian off and reload: Vista's clock, coordinates, FPS, mail and queue are back on the minimap.
15. Forever: repeat 1-3 and 7; nothing errors (`/console scriptErrors 1`).

- [ ] **Step 4: Record the outcome**

When the checklist passes, set the spec's status line to `**Status:** Phase 1 built and verified in game (<date>); phases 2 and 3 not started`, commit it (`docs(meridian): record phase 1 verification`), push, and open the pull request with the `/pr` skill. After it merges, run `/update-card` for the before/after card.
