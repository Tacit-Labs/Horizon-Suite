--[[
    Horizon Suite - Augment / Flight Tracker - options category
    Self-registers into addon.OptionCategories after OptionsData.lua runs.
]]

local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L   = addon.L
local D   = addon.AUGMENT_DEFAULTS
local LIM = addon.AUGMENT_LIMITS

local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end
local function clamp(v, key)
    local lim = LIM[key]
    if not lim then return v end
    return math.max(lim.min, math.min(lim.max, v))
end

local Section = addon.Section
local FontRow = addon.FontRow
local FONT_USE_GLOBAL                  = addon.FONT_USE_GLOBAL
local GetPerElementFontDropdownOptions = addon.GetPerElementFontDropdownOptions
local DisplayPerElementFont            = addon.DisplayPerElementFont

local function Flight() return addon.Augment and addon.Augment.Flight end

local function apply()
    local F = Flight()
    if F and F.ApplyOptions then F.ApplyOptions() end
end

local function isOff()
    return getDB("augmentFlightTrackerEnabled", D.augmentFlightTrackerEnabled) == false
end

local function Toggle(key, nameKey, descKey, extra)
    local row = {
        type = "toggle",
        name = L[nameKey], desc = L[descKey],
        dbKey = key,
        disabled = isOff,
        get = function() return getDB(key, D[key]) ~= false end,
        set = function(v) setDB(key, v and true or false); apply() end,
    }
    if extra then for k, v in pairs(extra) do row[k] = v end end
    return row
end

local function Slider(key, nameKey, descKey, step)
    return {
        type = "slider",
        name = L[nameKey], desc = L[descKey],
        dbKey = key,
        disabled = isOff,
        min = LIM[key].min, max = LIM[key].max, step = step,
        get = function() return clamp(tonumber(getDB(key, D[key])) or D[key], key) end,
        set = function(v) setDB(key, clamp(v, key)); apply() end,
    }
end

local category = {
    key         = "AugmentFlightTracker",
    name        = L["AUGMENT_FLIGHT_TRACKER"],
    desc        = L["AUGMENT_FLIGHT_TRACKER_PAGE_DESC"],
    icon        = "Interface\\Icons\\Ability_Mount_Gryphon_01",
    accentColor = { 0.4, 0.8, 1.0 },
    moduleKey   = "augment",
    enabledKey  = "augmentFlightTrackerEnabled",
    getEnabled  = function() return not isOff() end,
    setEnabled  = function(v)
        v = v and true or false
        setDB("augmentFlightTrackerEnabled", v)
        if addon.IsModuleEnabled and not addon:IsModuleEnabled("augment") then return end
        local F = Flight()
        if not F then return end
        if v then F.Enable() else F.Disable() end
    end,
    options = {
        Section(L["FLIGHT_PREVIEW"], { page = "flightTracker" }),
        { type = "button",
          name = L["FLIGHT_DEMO"], desc = L["FLIGHT_DEMO_DESC"],
          onClick = function() local F = Flight(); if F and F.Preview then F.Preview() end end,
        },
        { type = "button",
          name = L["FLIGHT_MOVE"], desc = L["FLIGHT_MOVE_DESC"],
          onClick = function() local F = Flight(); if F and F.ToggleEditMode then F.ToggleEditMode() end end,
        },

        Section(L["FLIGHT_SHOWS"], { page = "flightTracker" }),
        { type = "columns",
            left = { options = {
                Toggle("flightShowFlyingTo", "FLIGHT_SHOW_FLYING_TO", "FLIGHT_SHOW_FLYING_TO_DESC"),
                Toggle("flightShowRoute",    "FLIGHT_SHOW_ROUTE",     "FLIGHT_SHOW_ROUTE_DESC"),
                Toggle("flightShowStops",    "FLIGHT_SHOW_STOPS",     "FLIGHT_SHOW_STOPS_DESC", {
                    disabled = function()
                        return isOff() or getDB("flightShowRoute", D.flightShowRoute) == false
                    end,
                }),
            } },
            right = { options = {
                Toggle("flightShowOrigin",    "FLIGHT_SHOW_ORIGIN",    "FLIGHT_SHOW_ORIGIN_DESC"),
                Toggle("flightShowTimeLeft",  "FLIGHT_SHOW_TIME",      "FLIGHT_SHOW_TIME_DESC"),
                Toggle("flightArrivalNotice", "FLIGHT_ARRIVAL_NOTICE", "FLIGHT_ARRIVAL_NOTICE_DESC"),
            } },
        },

        Section(L["FLIGHT_APPEARANCE"], { page = "flightTracker" }),
        Slider("flightScale",   "FLIGHT_SCALE",   "FLIGHT_SCALE_DESC",   0.05),
        Slider("flightWidth",   "FLIGHT_WIDTH",   "FLIGHT_WIDTH_DESC",   10),
        Slider("flightOpacity", "FLIGHT_OPACITY", "FLIGHT_OPACITY_DESC", 5),
        Toggle("flightBackground", "FLIGHT_BACKGROUND", "FLIGHT_BACKGROUND_DESC"),
        Toggle("flightAccentBar",  "FLIGHT_ACCENT_BAR", "FLIGHT_ACCENT_BAR_DESC"),
        { type = "color",
          name = L["FLIGHT_ACCENT_COLOR"], desc = L["FLIGHT_ACCENT_COLOR_DESC"],
          dbKey = "flightAccent",
          disabled = isOff,
          liveThrottle = 0.08,
          default = { D.flightAccentR, D.flightAccentG, D.flightAccentB },
          get = function()
              return getDB("flightAccentR", D.flightAccentR), getDB("flightAccentG", D.flightAccentG),
                     getDB("flightAccentB", D.flightAccentB)
          end,
          set = function(r, g, b)
              setDB("flightAccentR", r); setDB("flightAccentG", g); setDB("flightAccentB", b)
              apply()
          end,
        },

        Section(L["FLIGHT_TEXT"], { page = "flightTracker" }),
        FontRow(L["AUGMENT_FONT"], L["FLIGHT_FONT_DESC"], {
            family = {
                dbKey = "flightFontPath",
                options = function() return GetPerElementFontDropdownOptions("flightFontPath") end,
                displayFn = DisplayPerElementFont,
                searchable = true,
                fontPreviewInList = true,
                get = function() return getDB("flightFontPath", FONT_USE_GLOBAL) end,
                set = function(v) setDB("flightFontPath", v); apply() end,
            },
            size = {
                dbKey = "flightFontSize",
                tooltip = L["FLIGHT_FONT_SIZE_DESC"],
                min = LIM.flightFontSize.min, max = LIM.flightFontSize.max,
                get = function() return clamp(tonumber(getDB("flightFontSize", D.flightFontSize)) or D.flightFontSize, "flightFontSize") end,
                set = function(v) setDB("flightFontSize", clamp(v, "flightFontSize")); apply() end,
            },
            outline = {
                dbKey = "flightTextOutlineType",
                tooltip = L["FLIGHT_OUTLINE_DESC"],
                options = addon.OUTLINE_OPTIONS, preserveOrder = true,
                get = function() return getDB("flightTextOutlineType", D.flightTextOutlineType) end,
                set = function(v) setDB("flightTextOutlineType", v); apply() end,
            },
        }, { keywords = { L["AUGMENT_FONT_SIZE"], L["AUGMENT_TEXT_OUTLINE"] } }),
        Slider("flightDestinationSize", "FLIGHT_DESTINATION_SIZE", "FLIGHT_DESTINATION_SIZE_DESC", 1),
        Slider("flightTimeSize",        "FLIGHT_TIME_SIZE",        "FLIGHT_TIME_SIZE_DESC",        1),
        Slider("flightArrivalSize",     "FLIGHT_ARRIVAL_SIZE",     "FLIGHT_ARRIVAL_SIZE_DESC",     1),

        Section(L["FLIGHT_LEARNED"], { page = "flightTracker" }),
        { type = "button",
          name = L["FLIGHT_FORGET"], desc = L["FLIGHT_FORGET_DESC"],
          onClick = function()
              local F = Flight()
              if F and F.ForgetLearned then F.ForgetLearned() end
              if addon.HSPrint then addon.HSPrint(L["FLIGHT_FORGOT"]) end
          end,
        },
    },
}

addon.RegisterModulePages("augment", { addon.OptionsPages.FromCategory(category, "flightTracker") })

-- Insert after the last Augment category to preserve sidebar order.
local insertAt = #addon.OptionCategories + 1
for i, cat in ipairs(addon.OptionCategories) do
    if cat.moduleKey == "augment" then insertAt = i + 1 end
end
table.insert(addon.OptionCategories, insertAt, category)
