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
