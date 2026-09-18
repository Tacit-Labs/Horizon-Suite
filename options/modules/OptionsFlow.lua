--[[
    Horizon Suite - Flow - Options categories
    Self-registers into addon.OptionCategories after OptionsData.lua runs.
]]
local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L = addon.L
local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end

local FONT_USE_GLOBAL                  = addon.FONT_USE_GLOBAL
local GetPerElementFontDropdownOptions = addon.GetPerElementFontDropdownOptions
local DisplayPerElementFont            = addon.DisplayPerElementFont
local Section = addon.Section
local Toggle  = addon.Toggle
local Slider  = addon.Slider
local Color   = addon.Color
local D   = addon.FLOW_DEFAULTS
local LIM = addon.FLOW_LIMITS

-- "Follow the dashboard" is offered as a theme rather than a separate toggle,
-- so the picker reads as one decision instead of two.
local FOLLOW_DASHBOARD = (addon.Flow and addon.Flow.THEME_FOLLOW_DASHBOARD) or "__dashboard__"

local function flowBackgroundThemeOptions()
    local out = { { L["FLOW_BACKGROUND_FOLLOW_DASHBOARD"], FOLLOW_DASHBOARD } }
    local shared = addon.HorizonBackgroundDropdownOptions and addon.HorizonBackgroundDropdownOptions()
    if type(shared) == "table" then
        for i = 1, #shared do out[#out + 1] = shared[i] end
    end
    return out
end

local categories = {
    {
        key       = "Flow",
        name      = L["AXIS_MODULE_NAME_SIMPLE_FLOW"],
        desc      = L["FLOW_DESC"],
        moduleKey = "flow",
        options   = {
            Section(L["DASH_APPEARANCE"]),
            Color(L["FLOW_BACKDROP_COLOUR"], L["FLOW_BACKDROP_COLOUR_DESC"],
                "flowBackdropColor", D.flowBackdropColor),
            Slider(L["FLOW_BACKDROP_OPACITY"], L["FLOW_BACKDROP_OPACITY_DESC"],
                "flowBackdropOpacity", LIM.flowBackdropOpacity.min, LIM.flowBackdropOpacity.max,
                D.flowBackdropOpacity),
            Toggle(L["FLOW_SHOW_BORDER"], L["FLOW_SHOW_BORDER_DESC"],
                "flowShowBorder", D.flowShowBorder),
            Toggle(L["FLOW_BACKGROUND_ART"], L["FLOW_BACKGROUND_ART_DESC"],
                "flowShowBackgroundArt", D.flowShowBackgroundArt),
            { type = "dropdown", name = L["FLOW_BACKGROUND_THEME"], desc = L["FLOW_BACKGROUND_THEME_DESC"],
              dbKey = "flowBackgroundTheme", searchable = true,
              options = flowBackgroundThemeOptions,
              get = function() return getDB("flowBackgroundTheme", FOLLOW_DASHBOARD) end,
              set = function(v) setDB("flowBackgroundTheme", v) end,
              visibleWhen = function() return getDB("flowShowBackgroundArt", D.flowShowBackgroundArt) ~= false end },
            Slider(L["FLOW_BACKGROUND_OPACITY"], L["FLOW_BACKGROUND_OPACITY_DESC"],
                "flowBackgroundOpacity", LIM.flowBackgroundOpacity.min, LIM.flowBackgroundOpacity.max,
                D.flowBackgroundOpacity,
                { visibleWhen = function() return getDB("flowShowBackgroundArt", D.flowShowBackgroundArt) ~= false end }),
            { type = "dropdown", name = L["FLOW_FONT"], desc = L["FLOW_FONT_DESC"],
              dbKey = "flowFontPath", searchable = true,
              options = function() return GetPerElementFontDropdownOptions("flowFontPath") end,
              get = function() return getDB("flowFontPath", FONT_USE_GLOBAL) end,
              set = function(v) setDB("flowFontPath", v) end,
              displayFn = DisplayPerElementFont, fontPreviewInList = true },
            Slider(L["FLOW_FONT_SIZE"], L["FLOW_FONT_SIZE_DESC"],
                "flowFontSize", LIM.flowFontSize.min, LIM.flowFontSize.max, D.flowFontSize),

            Section(L["FLOW_BEHAVIOUR"]),
            Toggle(L["FLOW_COLLAPSE_LORE"], L["FLOW_COLLAPSE_LORE_DESC"],
                "flowCollapseLore", D.flowCollapseLore),
            Toggle(L["FLOW_TYPE_PILL"], L["FLOW_TYPE_PILL_DESC"],
                "flowShowTypePill", D.flowShowTypePill),
            Toggle(L["FLOW_ENTRANCE"], L["FLOW_ENTRANCE_DESC"],
                "flowEntrance", D.flowEntrance),
            Toggle(L["FLOW_AUTO_SIZE"], L["FLOW_AUTO_SIZE_DESC"],
                "flowAutoSize", D.flowAutoSize),
            Toggle(L["FLOW_HIDE_CLOSE"], L["FLOW_HIDE_CLOSE_DESC"],
                "flowHideCloseButton", D.flowHideCloseButton),
        },
    },
}

for i = 1, #categories do
    addon.OptionCategories[#addon.OptionCategories + 1] = categories[i]
end
