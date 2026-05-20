--[[
    Horizon Suite - Focus - Integrations options
    Self-registers an "Integrations" category under the Focus options panel.
    Each entry shows the status of a companion addon and exposes its toggles.
    Controls are disabled when the corresponding addon is not installed.
]]

local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L       = addon.L
local Section = addon.Section
local Toggle  = addon.Toggle

local function getDB(k, d) return addon.GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end

-- ============================================================================
-- GUARDS
-- ============================================================================

--- True when the Horizon-RareScanner companion addon is loaded.
local function RareScannerIntegrationLoaded()
    return _G.HorizonRareScanner ~= nil
end

-- ============================================================================
-- CATEGORY
-- ============================================================================

addon.OptionCategories[#addon.OptionCategories + 1] = {
    key       = "Integrations",
    name      = L["FOCUS_INTEGRATIONS"],
    desc      = L["FOCUS_INTEGRATIONS_DESC"],
    moduleKey = "focus",
    options   = {
        -- ----------------------------------------------------------------
        -- RareScanner
        -- ----------------------------------------------------------------
        Section(L["FOCUS_INTEGRATION_RARESCANNER"]),

        -- Shown only when the companion addon is absent, to guide the user.
        {
            type        = "section",
            name        = L["FOCUS_INTEGRATION_RARESCANNER_NOT_INSTALLED"],
            visibleWhen = function() return not RareScannerIntegrationLoaded() end,
        },

        Toggle(
            L["FOCUS_INTEGRATION_RARESCANNER_SHOW_RARES"],
            L["FOCUS_INTEGRATION_RARESCANNER_SHOW_RARES_DESC"],
            "rs_showRares",
            true,
            {
                id          = "rs_showRares",
                visibleWhen = RareScannerIntegrationLoaded,
                disabled    = function() return not RareScannerIntegrationLoaded() end,
                set         = function(v)
                    setDB("rs_showRares", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARESCANNER_SHOW_TREASURES"],
            L["FOCUS_INTEGRATION_RARESCANNER_SHOW_TREASURES_DESC"],
            "rs_showTreasures",
            true,
            {
                id          = "rs_showTreasures",
                visibleWhen = RareScannerIntegrationLoaded,
                disabled    = function() return not RareScannerIntegrationLoaded() end,
                set         = function(v)
                    setDB("rs_showTreasures", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARESCANNER_SHOW_EVENTS"],
            L["FOCUS_INTEGRATION_RARESCANNER_SHOW_EVENTS_DESC"],
            "rs_showEvents",
            true,
            {
                id          = "rs_showEvents",
                visibleWhen = RareScannerIntegrationLoaded,
                disabled    = function() return not RareScannerIntegrationLoaded() end,
                set         = function(v)
                    setDB("rs_showEvents", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),
    },
}
