#!/usr/bin/env node
/**
 * Executable checks for Augment's shared toast style registry
 * (modules/Augment/ToastStyles/AugmentToastStyles.lua).
 *
 * Why this exists. Four toast stacks (loot, alerts, loot rolls, Echo) and the
 * loot window skin all paint through one ApplyChrome and read their style list
 * from one registry. Toast entries are pooled, so a style switch repaints a
 * frame that still carries the previous style's regions; a region the new
 * style forgets to hide stays on screen. That is easy to miss in-game because
 * it only shows on the second toast after a style change. The frames are
 * stubbed here, so every style transition can be checked.
 *
 * Usage:
 *   npm install fengari     # one dependency, not vendored
 *   node tools/test_toast_styles.js
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

// --- Stub the slice of the WoW/addon environment the module touches --------
run(`
  _G.HorizonSuite = {
    AUGMENT_DEFAULTS = { augmentFramedBorderShape = "rounded", augmentFramedBorderSize = 1 },
    AUGMENT_LIMITS = {},
    db = {},
    GetDB = function(k, d)
      local v = _G.HorizonSuite.db[k]
      if v ~= nil then return v end
      return d
    end,
  }
  PixelUtil = { GetPixelToUIUnitFactor = function() return 1 end }
  CreateColor = function(r, g, b, a) return { r = r, g = g, b = b, a = a } end

  -- A region records the calls that matter for chrome and no-ops the rest.
  local Region = {}
  Region.__index = function(self, k)
    local m = rawget(Region, k)
    if m ~= nil then return m end
    if type(k) == "string" and (k:match("^Set") or k:match("^Clear") or k:match("^Get")) then
      return function() end
    end
    return nil
  end
  -- Retail removed SetGradientAlpha in 10.0; model the current client.
  Region.SetGradientAlpha = false
  function Region:Show() self.shown = true end
  function Region:Hide() self.shown = false end
  function Region:IsShown() return self.shown == true end
  function Region:ClearAllPoints() self.points = {} end
  function Region:SetPoint(...)
    local pts = rawget(self, "points") or {}
    pts[#pts + 1] = { ... }
    rawset(self, "points", pts)
  end
  function Region:SetAllPoints(rel) self.points = { { "ALL", rel } } end
  function Region:SetColorTexture(r, g, b, a) self.color = { r, g, b, a } end
  function Region:SetTextColor(r, g, b, a) self.textColor = { r, g, b, a } end
  function Region:SetGradient(orient, c1, c2) self.gradient = { orient, c1, c2 } end
  function Region:SetWidth(w) self.width = w end
  function Region:SetSize(w, h) self.width, self.height = w, h end
  function Region:GetEffectiveScale() return 1 end
  function Region:SetBackdrop(b) self.backdrop = b end
  function Region:CreateTexture(_, layer, _, sub)
    local t = setmetatable({ layer = layer, sublevel = sub, created = true }, Region)
    local kids = rawget(self, "children") or {}
    kids[#kids + 1] = t
    rawset(self, "children", kids)
    return t
  end
  function NewRegion() return setmetatable({}, Region) end

  function NewEntry(textMode)
    local e = {
      frame = NewRegion(), icon = NewRegion(), iconBg = NewRegion(), iconDark = NewRegion(),
    }
    if textMode == "dual" then
      e.title, e.body = NewRegion(), NewRegion()
    else
      e.text, e.shadow = NewRegion(), NewRegion()
    end
    return e
  end
`, 'stubs');

run(read('modules/Augment/ToastStyles/AugmentToastStyles.lua'), 'ToastStyles');

// --- Assertions -----------------------------------------------------------
run(`
  local TS = HorizonSuite.Augment.ToastStyles
  local M  = HorizonSuite.Augment.ToastMotion
  local pass, fail = 0, 0
  local function check(name, ok, got)
    if ok then pass = pass + 1
    else fail = fail + 1; print("  FAIL: " .. name .. "  got: " .. tostring(got)) end
  end

  -- Registry --------------------------------------------------------------
  local ids = {}
  for _, def in ipairs(TS.List()) do ids[#ids + 1] = def.id end
  check("registry order", table.concat(ids, ",") == "compact,framed,accent,ribbon,rail", table.concat(ids, ","))

  for _, id in ipairs(ids) do
    check("Normalize keeps " .. id, TS.Normalize(id) == id, TS.Normalize(id))
  end
  check("legacy horizon maps to framed", TS.Normalize("horizon") == "framed", TS.Normalize("horizon"))
  check("legacy minimalist maps to accent", TS.Normalize("minimalist") == "accent", TS.Normalize("minimalist"))
  check("unknown falls back to framed", TS.Normalize("nope") == "framed", TS.Normalize("nope"))
  check("nil falls back to framed", TS.Normalize(nil) == "framed", TS.Normalize(nil))

  check("Get resolves legacy IDs", TS.Get("minimalist").id == "accent", TS.Get("minimalist").id)
  check("only Compact fans stacked icons",
        TS.Get("compact").stackFan and not TS.Get("framed").stackFan and not TS.Get("ribbon").stackFan
        and not TS.Get("rail").stackFan and not TS.Get("accent").stackFan, "fan")
  check("only Framed takes border options",
        TS.Get("framed").border and not TS.Get("rail").border and not TS.Get("ribbon").border, "border")
  check("Rail rows have Framed's headroom", TS.Get("rail").heightPad == M.CHROME_HEIGHT_PAD, TS.Get("rail").heightPad)
  check("Compact rows stay tight", TS.Get("compact").heightPad == 0, TS.Get("compact").heightPad)

  local Lstub = setmetatable({}, { __index = function(_, k) return "L:" .. k end })
  local opts = TS.StyleOptions(Lstub)
  check("dropdown lists every style", #opts == 5, #opts)
  check("dropdown values are style IDs", opts[4][2] == "ribbon" and opts[5][2] == "rail", opts[4][2])
  check("dropdown labels are locale keys", opts[4][1] == "L:AUGMENT_TOAST_STYLE_RIBBON", opts[4][1])
  local withMatch = TS.StyleOptions(Lstub, { { "Match", "__loot__" } })
  check("leading options come first", #withMatch == 6 and withMatch[1][2] == "__loot__", #withMatch)

  -- Chrome ----------------------------------------------------------------
  local function scale(v) return v end
  local function layout(mode, side)
    return { textMode = mode, iconSide = side or "left", iconSize = 30, iconGap = 6,
             iconBgPad = 1, textWidth = mode == "single" and 200 or nil, scale = scale,
             border = TS.GetFramedBorder() }
  end
  local quality = { r = 0.64, g = 0.21, b = 0.93 }

  for _, mode in ipairs({ "single", "dual" }) do
    local e = NewEntry(mode)
    TS.ApplyChrome(e, "ribbon", quality, layout(mode))
    check(mode .. " ribbon: backdrop cleared", e.frame.backdrop == nil, e.frame.backdrop)
    check(mode .. " ribbon: wash shown", e._tsWash and e._tsWash.shown, e._tsWash)
    check(mode .. " ribbon: icon chip hidden", e.iconBg.shown == false, e.iconBg.shown)
    local g = e._tsWash.gradient
    check(mode .. " ribbon: wash fades away from the icon",
          g and g[2].a > 0 and g[3].a == 0 and g[2].r == quality.r, g and g[2].a)
    local tc = (mode == "dual" and e.title or e.text).textColor
    check(mode .. " ribbon: text lifted toward white", tc[1] > quality.r and tc[2] > quality.g, tc[1])

    TS.ApplyChrome(e, "rail", quality, layout(mode))
    check(mode .. " ribbon to rail: wash hidden", e._tsWash.shown == false, e._tsWash.shown)
    check(mode .. " rail: plate shown", e._tsPlate and e._tsPlate.shown, e._tsPlate)
    check(mode .. " rail: rail shown", e._tsRail and e._tsRail.shown, e._tsRail)
    check(mode .. " rail: rail on the icon side", e._tsRail.points[1][1] == "TOPLEFT", e._tsRail.points[1][1])
    check(mode .. " rail: rail takes the fill colour", e._tsRail.color[1] == quality.r, e._tsRail.color[1])
    check(mode .. " rail: icon inset by EDGE", e.icon.points[1][4] == M.EDGE, e.icon.points[1][4])
    local tc2 = (mode == "dual" and e.title or e.text).textColor
    check(mode .. " rail: text keeps quality colour", tc2[1] == quality.r, tc2[1])

    TS.ApplyChrome(e, "framed", quality, layout(mode))
    check(mode .. " rail to framed: plate hidden", e._tsPlate.shown == false, e._tsPlate.shown)
    check(mode .. " rail to framed: rail hidden", e._tsRail.shown == false, e._tsRail.shown)
    check(mode .. " framed: backdrop set", e.frame.backdrop ~= nil, e.frame.backdrop)

    TS.ApplyChrome(e, "accent", quality, layout(mode))
    check(mode .. " framed to accent: backdrop cleared", e.frame.backdrop == nil, e.frame.backdrop)
    check(mode .. " accent: icon chip shown", e.iconBg.shown == true, e.iconBg.shown)

    TS.ApplyChrome(e, "ribbon", quality, layout(mode))
    check(mode .. " accent to ribbon: icon chip hidden", e.iconBg.shown == false, e.iconBg.shown)
    check(mode .. " accent to ribbon: under-icon hidden", e.iconDark.shown == false, e.iconDark.shown)
  end

  -- Icon on the right mirrors both new styles.
  local e = NewEntry("dual")
  TS.ApplyChrome(e, "rail", quality, layout("dual", "right"))
  check("right rail: rail on the right edge", e._tsRail.points[1][1] == "TOPRIGHT", e._tsRail.points[1][1])
  TS.ApplyChrome(e, "ribbon", quality, layout("dual", "right"))
  local g = e._tsWash.gradient
  check("right ribbon: wash strongest on the right", g[2].a == 0 and g[3].a > 0, g[3].a)

  -- Echo passes a separate icon fill; the wash and rail follow the fill.
  local echo = { r = 1, g = 1, b = 1, br = 0.2, bg = 0.5, bb = 0.9 }
  TS.ApplyChrome(e, "rail", echo, layout("dual"))
  check("rail uses the fill colour, not the text tint", e._tsRail.color[1] == 0.2, e._tsRail.color[1])
  TS.ApplyChrome(e, "ribbon", echo, layout("dual"))
  check("wash uses the fill colour", e._tsWash.gradient[2].r == 0.2, e._tsWash.gradient[2].r)

  -- Pooled entries reuse their style regions instead of stacking new ones.
  local before = #e.frame.children
  TS.ApplyChrome(e, "rail", quality, layout("dual"))
  TS.ApplyChrome(e, "ribbon", quality, layout("dual"))
  check("style regions created once per entry", #e.frame.children == before, #e.frame.children)

  print(("\\n%d passed, %d failed"):format(pass, fail))
  if fail > 0 then error("assertions failed") end
`, 'assertions');
