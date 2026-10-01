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
    L = {},
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
  function Region:SetText(t) rawset(self, "textValue", t) end
  function Region:GetText() return rawget(self, "textValue") end
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
      e.text, e.shadow, e.info = NewRegion(), NewRegion(), NewRegion()
    end
    return e
  end
`, 'stubs');

run(read('locales/horizon/enUS.lua'), 'enUS');
run(read('modules/Augment/ToastStyles/AugmentToastStyles.lua'), 'ToastStyles');

// AugmentParsing needs Augment.state and the item/currency/money APIs.
run(`
  HorizonSuite.Augment.state = {}
  format = string.format
  HorizonSuite.Augment.FONT_SIZE = 14
  INVTYPE_2HWEAPON = "Two-Hand"
  INVTYPE_WRIST = "Wrist"
  ITEMS = {
    sword  = { "Item", "Two-Handed Swords", "INVTYPE_2HWEAPON", 678 },
    wrist  = { "Armor", "Leather", "INVTYPE_WRIST", 642 },
    herb   = { "Tradeskill", "Herb", "", 1 },
    nolvl  = { "Weapon", "Daggers", "INVTYPE_WEAPON", nil },
  }
  C_Item = {
    GetItemInfoInstant = function(link)
      local i = ITEMS[link]; if not i then return nil end
      return 1, i[1], i[2], i[3]
    end,
    GetDetailedItemLevelInfo = function(link)
      local i = ITEMS[link]; return i and i[4]
    end,
  }
  MONEY = 0
  GetMoney = function() return MONEY end
  C_CurrencyInfo = { GetCurrencyInfo = function(id)
    if id == 2245 then return { name = "Flightstones", quantity = 1530 } end
  end }
`, 'parsing-stubs');
run(read('modules/Augment/LootFrame/AugmentParsing.lua'), 'Parsing');

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
  check("registry order", table.concat(ids, ",") == "compact,framed,accent,ribbon,rail,card", table.concat(ids, ","))

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
  check("Framed and Card take border options",
        TS.Get("framed").border and TS.Get("card").border and not TS.Get("rail").border
        and not TS.Get("ribbon").border, "border")
  check("only Card grows the icon", (TS.Get("card").iconGrow or 0) > 0 and (TS.Get("framed").iconGrow or 0) == 0,
        TS.Get("card").iconGrow)
  check("every style names a known window treatment", (function()
    local known = { backdrop = true, strip = true, wash = true, plain = true }
    for _, def in ipairs(TS.List()) do if not known[def.window] then return false end end
    return true
  end)(), "window")
  check("Rail rows have Framed's headroom", TS.Get("rail").heightPad == M.CHROME_HEIGHT_PAD, TS.Get("rail").heightPad)
  check("Compact rows stay tight", TS.Get("compact").heightPad == 0, TS.Get("compact").heightPad)

  local Lstub = setmetatable({}, { __index = function(_, k) return "L:" .. k end })
  local opts = TS.StyleOptions(Lstub)
  check("dropdown lists every style", #opts == 6, #opts)
  check("dropdown values are style IDs", opts[4][2] == "ribbon" and opts[5][2] == "rail", opts[4][2])
  check("dropdown labels are locale keys", opts[4][1] == "L:AUGMENT_TOAST_STYLE_RIBBON", opts[4][1])
  local withMatch = TS.StyleOptions(Lstub, { { "Match", "__loot__" } })
  check("leading options come first", #withMatch == 7 and withMatch[1][2] == "__loot__", #withMatch)

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

  -- Card -------------------------------------------------------------------
  local grow = TS.Get("card").iconGrow
  for _, mode in ipairs({ "single", "dual" }) do
    local e = NewEntry(mode)
    TS.ApplyChrome(e, "card", quality, layout(mode))
    check(mode .. " card: framed backdrop", e.frame.backdrop ~= nil, e.frame.backdrop)
    check(mode .. " card: icon grown", e.icon.width == 30 + grow, e.icon.width)
    TS.ApplyChrome(e, "framed", quality, layout(mode))
    check(mode .. " card to framed: icon back to base size", e.icon.width == 30, e.icon.width)
  end

  local function firstPoint(r) return r.points and r.points[1] and r.points[1][1] end
  local e1 = NewEntry("single")
  e1.info:SetText("678 · Two-Hand")
  TS.ApplyChrome(e1, "card", quality, layout("single"))
  check("card info: shown when it has text", e1.info.shown == true, e1.info.shown)
  check("card info: name on the top line", firstPoint(e1.text) == "TOPLEFT", firstPoint(e1.text))
  check("card info: shadow follows the name", firstPoint(e1.shadow) == "TOPLEFT", firstPoint(e1.shadow))
  check("card info: info on the bottom line", firstPoint(e1.info) == "BOTTOMLEFT", firstPoint(e1.info))
  check("card info: text width keeps clear of the plate", e1.info.width == 200 - 2 * M.EDGE, e1.info.width)
  TS.ApplyChrome(e1, "card", quality, layout("single", "right"))
  check("card info: mirrors with the icon on the right", firstPoint(e1.info) == "BOTTOMRIGHT", firstPoint(e1.info))
  TS.ApplyChrome(e1, "framed", quality, layout("single"))
  check("card to framed: info hidden", e1.info.shown == false, e1.info.shown)
  check("card to framed: name centred again", firstPoint(e1.text) == "LEFT", firstPoint(e1.text))

  local e2 = NewEntry("single")
  e2.info:SetText("")
  TS.ApplyChrome(e2, "card", quality, layout("single"))
  check("card without info: info stays hidden", e2.info.shown ~= true, e2.info.shown)
  check("card without info: name stays centred", firstPoint(e2.text) == "LEFT", firstPoint(e2.text))

  -- Card's second line ------------------------------------------------------
  local Y = HorizonSuite.Augment
  check("info: gear shows level and slot", Y.BuildCardInfo({ kind = "item", link = "sword" }) == "678 · Two-Hand",
        Y.BuildCardInfo({ kind = "item", link = "sword" }))
  check("info: armour shows level and slot", Y.BuildCardInfo({ kind = "item", link = "wrist" }) == "642 · Wrist",
        Y.BuildCardInfo({ kind = "item", link = "wrist" }))
  check("info: non-gear shows its type", Y.BuildCardInfo({ kind = "item", link = "herb" }) == "Herb",
        Y.BuildCardInfo({ kind = "item", link = "herb" }))
  check("info: gear with no level falls back to its type",
        Y.BuildCardInfo({ kind = "item", link = "nolvl" }) == "Daggers", Y.BuildCardInfo({ kind = "item", link = "nolvl" }))
  check("info: unknown item gives nothing", Y.BuildCardInfo({ kind = "item", link = "nope" }) == nil,
        Y.BuildCardInfo({ kind = "item", link = "nope" }))
  check("info: currency shows the amount held",
        Y.BuildCardInfo({ kind = "currency", currencyID = 2245 }) == "Total 1530",
        Y.BuildCardInfo({ kind = "currency", currencyID = 2245 }))
  MONEY = 12345678
  local money = Y.BuildCardInfo({ kind = "money" })
  check("info: money shows the gold total", money and money:find("^Total 1234 ") ~= nil, money)
  check("info: money in gold drops silver and copper", money and not money:find("Silver") and not money:find("Copper"), money)
  MONEY = 4321
  local small = Y.BuildCardInfo({ kind = "money" })
  check("info: money under a gold keeps silver", small and small:find("^Total 43 ") ~= nil, small)
  check("info: rep gives nothing", Y.BuildCardInfo({ kind = "rep" }) == nil, Y.BuildCardInfo({ kind = "rep" }))
  check("info: nil data gives nothing", Y.BuildCardInfo(nil) == nil, "nil")

  print(("\\n%d passed, %d failed"):format(pass, fail))
  if fail > 0 then error("assertions failed") end
`, 'assertions');
