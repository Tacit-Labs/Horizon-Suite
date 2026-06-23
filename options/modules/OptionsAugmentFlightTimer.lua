--[[
    Horizon Suite - Augment / FlightTimer - options category
    Self-registers into addon.OptionCategories after OptionsData.lua runs.
]]

local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L   = addon.L
local D   = addon.AUGMENT_DEFAULTS
local LIM = addon.AUGMENT_LIMITS

local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end
local Section = addon.Section
local Toggle  = addon.Toggle
local Slider  = addon.Slider
local Button  = addon.Button

local FONT_USE_GLOBAL          = addon.FONT_USE_GLOBAL
local GetFontOptions           = addon.GetPerElementFontDropdownOptions
local DisplayFont               = addon.DisplayPerElementFont

local function clamp(v, key) local lim = LIM[key]; return math.max(lim.min, math.min(lim.max, v)) end

local function F() return addon.Augment and addon.Augment.FlightTimer end

local function applyLayout()
    local f = F()
    if f and f.Bar and f.Bar.ApplyLayout then f.Bar.ApplyLayout() end
end

local function ColorOption(name, desc, prefix, defaultR, defaultG, defaultB)
    return {
        type = "color", name = name, desc = desc, dbKey = prefix,
        default = { defaultR, defaultG, defaultB },
        get = function()
            return getDB(prefix .. "R", defaultR), getDB(prefix .. "G", defaultG), getDB(prefix .. "B", defaultB)
        end,
        set = function(r, g, b)
            setDB(prefix .. "R", r); setDB(prefix .. "G", g); setDB(prefix .. "B", b)
            applyLayout()
        end,
    }
end

local category = {
    key         = "AugmentFlightTimer",
    name        = L["FLIGHT_TIMER_TITLE"],
    desc        = L["FLIGHT_TIMER_PAGE_DESC"],
    moduleKey   = "augment",
    icon        = "Interface\\Icons\\INV_Misc_PocketWatch_01",
    accentColor = { 0.45, 0.85, 0.65 },
    enabledKey  = "flightTimerEnabled",
    getEnabled  = function() return getDB("flightTimerEnabled", D.flightTimerEnabled) ~= false end,
    setEnabled  = function(v)
        v = v and true or false
        setDB("flightTimerEnabled", v)
        local f = F()
        if not f then return end
        if v then f.Enable() else f.Disable() end
    end,
    options = {
        Section(L["FLIGHT_TIMER_BEHAVIOUR"]),
        Toggle(L["FLIGHT_TIMER_CONFIRM_FLIGHT"], L["FLIGHT_TIMER_CONFIRM_FLIGHT_DESC"],
            "flightTimerConfirmFlight", D.flightTimerConfirmFlight),
        Toggle(L["FLIGHT_TIMER_COUNT_UP"], L["FLIGHT_TIMER_COUNT_UP_DESC"],
            "flightTimerCountUp", D.flightTimerCountUp),
        Toggle(L["FLIGHT_TIMER_CHAT_LOG"], L["FLIGHT_TIMER_CHAT_LOG_DESC"],
            "flightTimerChatLog", D.flightTimerChatLog),

        Section(L["FLIGHT_TIMER_BAR_APPEARANCE"]),
        { type = "dropdown",
          name = L["FLIGHT_TIMER_LAYOUT"], desc = L["FLIGHT_TIMER_LAYOUT_DESC"],
          dbKey = "flightTimerLayout",
          options = {
              { L["FLIGHT_TIMER_LAYOUT_NORMAL"], "normal" },
              { L["FLIGHT_TIMER_LAYOUT_TWOLINE"], "twoline" },
              { L["FLIGHT_TIMER_LAYOUT_INLINE"], "inline" },
          },
          get = function() return getDB("flightTimerLayout", D.flightTimerLayout) end,
          set = function(v) setDB("flightTimerLayout", v); applyLayout() end,
        },
        Slider(L["FLIGHT_TIMER_WIDTH"], L["FLIGHT_TIMER_WIDTH_DESC"], "flightTimerWidth",
            LIM.flightTimerWidth.min, LIM.flightTimerWidth.max, D.flightTimerWidth,
            { set = function(v) setDB("flightTimerWidth", clamp(v, "flightTimerWidth")); applyLayout() end }),
        Slider(L["FLIGHT_TIMER_HEIGHT"], L["FLIGHT_TIMER_HEIGHT_DESC"], "flightTimerHeight",
            LIM.flightTimerHeight.min, LIM.flightTimerHeight.max, D.flightTimerHeight,
            { set = function(v) setDB("flightTimerHeight", clamp(v, "flightTimerHeight")); applyLayout() end }),
        { type = "dropdown",
          name = L["FLIGHT_TIMER_FONT"], desc = L["FLIGHT_TIMER_FONT_DESC"],
          dbKey = "flightTimerFontPath", searchable = true,
          options = function() return GetFontOptions("flightTimerFontPath") end,
          get = function() return getDB("flightTimerFontPath", FONT_USE_GLOBAL) end,
          set = function(v) setDB("flightTimerFontPath", v); applyLayout() end,
          displayFn = DisplayFont, fontPreviewInList = true,
        },
        Slider(L["FLIGHT_TIMER_FONT_SIZE"], L["FLIGHT_TIMER_FONT_SIZE_DESC"], "flightTimerFontSize",
            LIM.flightTimerFontSize.min, LIM.flightTimerFontSize.max, D.flightTimerFontSize,
            { set = function(v) setDB("flightTimerFontSize", clamp(v, "flightTimerFontSize")); applyLayout() end }),
        ColorOption(L["FLIGHT_TIMER_BAR_COLOR"], L["FLIGHT_TIMER_BAR_COLOR_DESC"], "flightTimerBarColor",
            D.flightTimerBarColorR, D.flightTimerBarColorG, D.flightTimerBarColorB),
        ColorOption(L["FLIGHT_TIMER_UNKNOWN_COLOR"], L["FLIGHT_TIMER_UNKNOWN_COLOR_DESC"], "flightTimerUnknownColor",
            D.flightTimerUnknownColorR, D.flightTimerUnknownColorG, D.flightTimerUnknownColorB),
        ColorOption(L["FLIGHT_TIMER_FONT_COLOR"], L["FLIGHT_TIMER_FONT_COLOR_DESC"], "flightTimerFontColor",
            D.flightTimerFontColorR, D.flightTimerFontColorG, D.flightTimerFontColorB),

        Section(L["FLIGHT_TIMER_DATA"]),
        Button(L["FLIGHT_TIMER_RESET_LEARNED"], L["FLIGHT_TIMER_RESET_LEARNED_DESC"], function()
            local f = F()
            if f and f.ResetLearnedData then f.ResetLearnedData() end
        end),
    },
}

-- Insert after the last Augment category to preserve sidebar order.
local insertAt = #addon.OptionCategories + 1
for i, cat in ipairs(addon.OptionCategories) do
    if cat.moduleKey == "augment" then insertAt = i + 1 end
end
table.insert(addon.OptionCategories, insertAt, category)
