--[[
    Horizon Suite - Focus - Integrations options
    Self-registers an "Integrations" category under the Focus options panel.
    Each integration card is always visible. When the companion addon is absent
    all controls are greyed out and the tooltip says it is not installed.
]]

local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L       = addon.L
local Section = addon.Section
local Toggle  = addon.Toggle
local Slider  = addon.Slider
local Color   = addon.Color

local function setDB(k, v) addon.OptionsData_SetDB(k, v) end

-- ============================================================================
-- SHARED
-- ============================================================================

--- True when TomTom is loaded.
local function TomTomLoaded()
    return rawget(_G, "TomTom") ~= nil
end

--- Tooltip appended when TomTom is not installed.
local function TomTomNotInstalledTooltip()
    if not TomTomLoaded() then
        return L["FOCUS_INTEGRATION_RARE_TOMTOM_INVALID"]
    end
end

-- ============================================================================
-- RARESCANNER GUARDS
-- ============================================================================

--- True when the Horizon-RareScanner companion addon is loaded.
local function RareScannerIntegrationLoaded()
    return rawget(_G, "HorizonRareScanner") ~= nil
end

--- True when the master enable toggle is on (and companion is present).
local function RSEnabled()
    return RareScannerIntegrationLoaded() and addon.GetDB("rs_enabled", false)
end

local RS_MAX_ALERTS_MIN     = 1
local RS_MAX_ALERTS_MAX     = 10
local RS_MAX_ALERTS_DEFAULT = 4

--- disabledFn for all RS widgets: grey out when companion is absent.
local function RSDisabled()
    return not RareScannerIntegrationLoaded()
end

--- visibleWhen for sub-toggles: show when RS absent (greyed placeholders) OR
--- when RS is installed and the master enable is on.
local function RSSubVisible()
    return not RareScannerIntegrationLoaded() or addon.GetDB("rs_enabled", false)
end

--- visibleWhen for the loot quality dropdown: same as RSSubVisible but also
--- requires showLoot to be on (or RS absent, so the greyed placeholder is shown).
local function RSLootSubVisible()
    return not RareScannerIntegrationLoaded()
        or (addon.GetDB("rs_enabled", false) and addon.GetDB("rs_showLoot", true))
end

--- visibleWhen for the TomTom toggle: same as the coord-waypoint sub-toggle.
local function RSTomTomVisible()
    return RSSubVisible() and addon.GetDB("rs_showCoords", true)
        and addon.GetDB("rs_coordWaypoint", true)
end

--- disabledFn for the TomTom toggle: grey out when RS companion or TomTom absent.
local function RSTomTomDisabled()
    return RSDisabled() or not TomTomLoaded()
end

--- Tooltip appended when companion is absent (evaluated lazily at panel open time).
local function RSNotInstalledTooltip()
    if not RareScannerIntegrationLoaded() then
        return L["FOCUS_INTEGRATION_RARESCANNER_INVALID"]
    end
end

-- ============================================================================
-- SILVERDRAGON GUARDS
-- ============================================================================

local function SilverDragonIntegrationLoaded()
    return rawget(_G, "HorizonSilverDragon") ~= nil
end

local function SDEnabled()
    return SilverDragonIntegrationLoaded() and addon.GetDB("sd_enabled", false)
end

local function SDDisabled()
    return not SilverDragonIntegrationLoaded()
end

local function SDSubVisible()
    return not SilverDragonIntegrationLoaded() or addon.GetDB("sd_enabled", false)
end

local function SDTomTomVisible()
    return SDSubVisible()
        and addon.GetDB("sd_showCoords", true)
        and addon.GetDB("sd_coordWaypoint", true)
end

local function SDTomTomDisabled()
    return SDDisabled() or not TomTomLoaded()
end

local function SDNotInstalledTooltip()
    if not SilverDragonIntegrationLoaded() then
        return L["FOCUS_INTEGRATION_SILVERDRAGON_INVALID"]
    end
end

-- ============================================================================
-- CATEGORY
-- ============================================================================

addon.OptionCategories[#addon.OptionCategories + 1] = {
    key       = "Integrations",
    name      = L["FOCUS_INTEGRATION"],
    desc      = L["FOCUS_INTEGRATION_DESC"],
    moduleKey = "focus",
    options   = {
        -- ----------------------------------------------------------------
        -- RareScanner — always visible; greyed when companion is absent.
        -- ----------------------------------------------------------------
        Section(L["FOCUS_INTEGRATION_RARESCANNER"]),
        { type = "header", name = L["FOCUS_INTEGRATION_RARESCANNER_COMPANION"] },

        Toggle(
            L["FOCUS_INTEGRATION_RARESCANNER_ENABLE"],
            L["FOCUS_INTEGRATION_RARESCANNER_ENABLE_DESC"],
            "rs_enabled",
            false,
            {
                id         = "rs_enable",
                disabled   = RSDisabled,
                tooltip    = RSNotInstalledTooltip,
                set        = function(v)
                    setDB("rs_enabled", v)
                    local rsAddon = rawget(_G, "HorizonRareScanner")
                    if rsAddon and rsAddon.ApplyPopupSuppression then
                        rsAddon.ApplyPopupSuppression(v)
                    end
                    if addon.focus and addon.focus.rs and addon.focus.rs.SuppressNativePopups then
                        addon.focus.rs.SuppressNativePopups()
                    end
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
                refreshIds = {
                    "rs_maxAlerts", "rs_sectionTitleRares",
                    "rs_showRares", "rs_showTreasures", "rs_showEvents",
                    "rs_showCoords", "rs_autoWaypoint",
                    "rs_showPortrait", "rs_modelPosition", "rs_modelSize", "rs_modelOffsetX",
                    "rs_showLoot", "rs_minLootQuality",
                },
            }
        ),

        Slider(
            L["FOCUS_INTEGRATION_RARE_MAX_ALERTS"],
            L["FOCUS_INTEGRATION_RARE_MAX_ALERTS_DESC"],
            "rs_maxAlerts",
            RS_MAX_ALERTS_MIN,
            RS_MAX_ALERTS_MAX,
            RS_MAX_ALERTS_DEFAULT,
            {
                id          = "rs_maxAlerts",
                disabled    = RSDisabled,
                visibleWhen = RSSubVisible,
                set         = function(v) setDB("rs_maxAlerts", v) end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARE_SECTION_TITLE_RARES"],
            L["FOCUS_INTEGRATION_RARE_SECTION_TITLE_RARES_DESC"],
            "rs_sectionTitleRares",
            false,
            {
                id          = "rs_sectionTitleRares",
                disabled    = RSDisabled,
                visibleWhen = RSSubVisible,
                set         = function(v)
                    setDB("rs_sectionTitleRares", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARESCANNER_SHOW_RARES"],
            L["FOCUS_INTEGRATION_RARESCANNER_SHOW_RARES_DESC"],
            "rs_showRares",
            true,
            {
                id          = "rs_showRares",
                disabled    = RSDisabled,
                visibleWhen = RSSubVisible,
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
                disabled    = RSDisabled,
                visibleWhen = RSSubVisible,
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
                disabled    = RSDisabled,
                visibleWhen = RSSubVisible,
                set         = function(v)
                    setDB("rs_showEvents", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARE_SHOW_COORDS"],
            L["FOCUS_INTEGRATION_RARE_SHOW_COORDS_DESC"],
            "rs_showCoords",
            true,
            {
                id          = "rs_showCoords",
                disabled    = RSDisabled,
                visibleWhen = RSSubVisible,
                refreshIds  = { "rs_coordWaypoint" },
                set         = function(v)
                    setDB("rs_showCoords", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARE_COORD_WAYPOINT"],
            L["FOCUS_INTEGRATION_RARE_COORD_WAYPOINT_DESC"],
            "rs_coordWaypoint",
            true,
            {
                id          = "rs_coordWaypoint",
                disabled    = RSDisabled,
                visibleWhen = function()
                    return RSSubVisible() and addon.GetDB("rs_showCoords", true)
                end,
                set         = function(v)
                    setDB("rs_coordWaypoint", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
                refreshIds  = { "rs_useTomTom" },
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARE_USE_TOMTOM"],
            L["FOCUS_INTEGRATION_RARE_USE_TOMTOM_DESC"],
            "rs_useTomTom",
            false,
            {
                id          = "rs_useTomTom",
                disabled    = RSTomTomDisabled,
                visibleWhen = RSTomTomVisible,
                tooltip     = TomTomNotInstalledTooltip,
                set         = function(v) setDB("rs_useTomTom", v) end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARE_AUTO_WAYPOINT"],
            L["FOCUS_INTEGRATION_RARE_AUTO_WAYPOINT_DESC"],
            "rs_autoWaypoint",
            false,
            {
                id          = "rs_autoWaypoint",
                disabled    = RSDisabled,
                visibleWhen = RSSubVisible,
                set         = function(v) setDB("rs_autoWaypoint", v) end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARE_SHOW_SEEN_AGO"],
            L["FOCUS_INTEGRATION_RARE_SHOW_SEEN_AGO_DESC"],
            "rs_showSeenAgo",
            true,
            {
                id          = "rs_showSeenAgo",
                disabled    = RSDisabled,
                visibleWhen = RSSubVisible,
                set         = function(v)
                    setDB("rs_showSeenAgo", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARE_SHOW_PORTRAIT"],
            L["FOCUS_INTEGRATION_RARE_SHOW_PORTRAIT_DESC"],
            "rs_showPortrait",
            true,
            {
                id          = "rs_showPortrait",
                disabled    = RSDisabled,
                visibleWhen = RSSubVisible,
                refreshIds  = { "rs_modelPosition", "rs_modelSize", "rs_modelOffsetX" },
                set         = function(v)
                    setDB("rs_showPortrait", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),

        {
            type        = "dropdown",
            name        = L["FOCUS_INTEGRATION_RARE_MODEL_POSITION"],
            desc        = L["FOCUS_INTEGRATION_RARE_MODEL_POSITION_DESC"],
            dbKey       = "rs_modelPosition",
            disabled    = RSDisabled,
            visibleWhen = function() return RSSubVisible() and addon.GetDB("rs_showPortrait", true) end,
            options     = function()
                return {
                    { L["FOCUS_INTEGRATION_RARE_MODEL_POSITION_RIGHT"], "right" },
                    { L["FOCUS_INTEGRATION_RARE_MODEL_POSITION_LEFT"],  "left"  },
                }
            end,
            get = function() return addon.GetDB("rs_modelPosition", "right") end,
            set = function(v) setDB("rs_modelPosition", v); addon.ScheduleRefresh() end,
        },

        Slider(
            L["FOCUS_INTEGRATION_RARE_MODEL_SIZE"],
            L["FOCUS_INTEGRATION_RARE_MODEL_SIZE_DESC"],
            "rs_modelSize", 32, 128, 64,
            {
                id          = "rs_modelSize",
                disabled    = RSDisabled,
                visibleWhen = function() return RSSubVisible() and addon.GetDB("rs_showPortrait", true) end,
                set         = function(v) setDB("rs_modelSize", v); addon.ScheduleRefresh() end,
            }
        ),

        Slider(
            L["FOCUS_INTEGRATION_RARE_MODEL_OFFSET_X"],
            L["FOCUS_INTEGRATION_RARE_MODEL_OFFSET_X_DESC"],
            "rs_modelOffsetX", -100, 100, 0,
            {
                id          = "rs_modelOffsetX",
                disabled    = RSDisabled,
                visibleWhen = function() return RSSubVisible() and addon.GetDB("rs_showPortrait", true) end,
                set         = function(v) setDB("rs_modelOffsetX", v); addon.ScheduleRefresh() end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARE_SHOW_VIGNETTE_ICON"],
            L["FOCUS_INTEGRATION_RARE_SHOW_VIGNETTE_ICON_DESC"],
            "rs_showVignetteIcon",
            true,
            {
                id          = "rs_showVignetteIcon",
                disabled    = RSDisabled,
                visibleWhen = RSSubVisible,
                set         = function(v)
                    setDB("rs_showVignetteIcon", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARESCANNER_SHOW_LOOT"],
            L["FOCUS_INTEGRATION_RARESCANNER_SHOW_LOOT_DESC"],
            "rs_showLoot",
            true,
            {
                id          = "rs_showLoot",
                disabled    = RSDisabled,
                visibleWhen = RSSubVisible,
                refreshIds  = { "rs_minLootQuality" },
                set         = function(v)
                    setDB("rs_showLoot", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),

        {
            type        = "dropdown",
            name        = L["FOCUS_INTEGRATION_RARESCANNER_MIN_LOOT_QUALITY"],
            desc        = L["FOCUS_INTEGRATION_RARESCANNER_MIN_LOOT_QUALITY_DESC"],
            dbKey       = "rs_minLootQuality",
            disabled    = RSDisabled,
            visibleWhen = RSLootSubVisible,
            options     = function()
                return {
                    { ITEM_QUALITY0_DESC or "Poor",      0 },
                    { ITEM_QUALITY1_DESC or "Common",    1 },
                    { ITEM_QUALITY2_DESC or "Uncommon",  2 },
                    { ITEM_QUALITY3_DESC or "Rare",      3 },
                    { ITEM_QUALITY4_DESC or "Epic",      4 },
                    { ITEM_QUALITY5_DESC or "Legendary", 5 },
                }
            end,
            get         = function() return tonumber(addon.GetDB("rs_minLootQuality", 2)) or 2 end,
            set         = function(v)
                setDB("rs_minLootQuality", v)
                if addon.ScheduleRefresh then addon.ScheduleRefresh() end
            end,
        },

        Slider(
            L["FOCUS_INTEGRATION_RARESCANNER_LOOT_PER_ROW"],
            L["FOCUS_INTEGRATION_RARESCANNER_LOOT_PER_ROW_DESC"],
            "rs_lootPerRow",
            3, 8, 6,
            {
                id          = "rs_lootPerRow",
                disabled    = RSDisabled,
                visibleWhen = RSLootSubVisible,
                set         = function(v)
                    setDB("rs_lootPerRow", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),

        Color(
            L["FOCUS_INTEGRATION_RARE_COLOR"],
            L["FOCUS_INTEGRATION_RARE_COLOR_DESC"],
            "rs_color",
            { 0.20, 0.85, 0.75 },
            {
                id          = "rs_color",
                disabled    = RSDisabled,
                visibleWhen = RSSubVisible,
                get         = function()
                    local c = addon.GetDB("rs_color")
                    if type(c) == "table" and c[1] then return c[1], c[2], c[3] end
                    return 0.20, 0.85, 0.75
                end,
                set         = function(r, g, b)
                    setDB("rs_color", { r, g, b })
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARE_CLICK_TO_TARGET"],
            L["FOCUS_INTEGRATION_RARE_CLICK_TO_TARGET_DESC"],
            "rs_clickToTarget",
            false,
            {
                id          = "rs_clickToTarget",
                disabled    = RSDisabled,
                visibleWhen = RSSubVisible,
                set         = function(v) setDB("rs_clickToTarget", v) end,
            }
        ),

        addon.Button(
            L["FOCUS_INTEGRATION_RARESCANNER_TEST_BTN"],
            L["FOCUS_INTEGRATION_RARESCANNER_TEST_BTN_DESC"],
            function()
                local rs = rawget(_G, "RareScanner")
                if rs and rs.Test then rs:Test() end
            end,
            {
                disabled    = RSDisabled,
                visibleWhen = RSEnabled,
            }
        ),

        -- ----------------------------------------------------------------
        -- SilverDragon — always visible; greyed when companion is absent.
        -- ----------------------------------------------------------------
        Section(L["FOCUS_INTEGRATION_SILVERDRAGON"]),
        { type = "header", name = L["FOCUS_INTEGRATION_SILVERDRAGON_COMPANION"] },

        Toggle(
            L["FOCUS_INTEGRATION_SILVERDRAGON_ENABLE"],
            L["FOCUS_INTEGRATION_SILVERDRAGON_ENABLE_DESC"],
            "sd_enabled",
            false,
            {
                id         = "sd_enable",
                disabled   = SDDisabled,
                tooltip    = SDNotInstalledTooltip,
                set        = function(v)
                    setDB("sd_enabled", v)
                    local sdAddon = rawget(_G, "HorizonSilverDragon")
                    if sdAddon and sdAddon.ApplyPopupSuppression then
                        sdAddon.ApplyPopupSuppression(v)
                    end
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
                refreshIds = {
                    "sd_maxAlerts", "sd_sectionTitleRares",
                    "sd_showCoords", "sd_coordWaypoint", "sd_useTomTom",
                    "sd_autoWaypoint", "sd_showPortrait", "sd_modelPosition", "sd_modelSize", "sd_modelOffsetX",
                    "sd_clickToTarget", "sd_showRares", "sd_showLoot",
                },
            }
        ),

        Slider(
            L["FOCUS_INTEGRATION_RARE_MAX_ALERTS"],
            L["FOCUS_INTEGRATION_RARE_MAX_ALERTS_DESC"],
            "sd_maxAlerts",
            1, 10, 4,
            {
                id          = "sd_maxAlerts",
                disabled    = SDDisabled,
                visibleWhen = SDSubVisible,
                set         = function(v) setDB("sd_maxAlerts", v) end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARE_SECTION_TITLE_RARES"],
            L["FOCUS_INTEGRATION_RARE_SECTION_TITLE_RARES_DESC"],
            "sd_sectionTitleRares",
            false,
            {
                id          = "sd_sectionTitleRares",
                disabled    = SDDisabled,
                visibleWhen = SDSubVisible,
                set         = function(v)
                    setDB("sd_sectionTitleRares", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARE_SHOW_COORDS"],
            L["FOCUS_INTEGRATION_RARE_SHOW_COORDS_DESC"],
            "sd_showCoords",
            true,
            {
                id          = "sd_showCoords",
                disabled    = SDDisabled,
                visibleWhen = SDSubVisible,
                refreshIds  = { "sd_coordWaypoint" },
                set         = function(v)
                    setDB("sd_showCoords", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARE_COORD_WAYPOINT"],
            L["FOCUS_INTEGRATION_RARE_COORD_WAYPOINT_DESC"],
            "sd_coordWaypoint",
            true,
            {
                id          = "sd_coordWaypoint",
                disabled    = SDDisabled,
                visibleWhen = function()
                    return SDSubVisible() and addon.GetDB("sd_showCoords", true)
                end,
                set        = function(v)
                    setDB("sd_coordWaypoint", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
                refreshIds = { "sd_useTomTom" },
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARE_USE_TOMTOM"],
            L["FOCUS_INTEGRATION_RARE_USE_TOMTOM_DESC"],
            "sd_useTomTom",
            false,
            {
                id          = "sd_useTomTom",
                disabled    = SDTomTomDisabled,
                visibleWhen = SDTomTomVisible,
                tooltip     = TomTomNotInstalledTooltip,
                set         = function(v) setDB("sd_useTomTom", v) end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARE_AUTO_WAYPOINT"],
            L["FOCUS_INTEGRATION_RARE_AUTO_WAYPOINT_DESC"],
            "sd_autoWaypoint",
            false,
            {
                id          = "sd_autoWaypoint",
                disabled    = SDDisabled,
                visibleWhen = SDSubVisible,
                set         = function(v) setDB("sd_autoWaypoint", v) end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARE_SHOW_SEEN_AGO"],
            L["FOCUS_INTEGRATION_RARE_SHOW_SEEN_AGO_DESC"],
            "sd_showSeenAgo",
            true,
            {
                id          = "sd_showSeenAgo",
                disabled    = SDDisabled,
                visibleWhen = SDSubVisible,
                set         = function(v)
                    setDB("sd_showSeenAgo", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARE_SHOW_PORTRAIT"],
            L["FOCUS_INTEGRATION_RARE_SHOW_PORTRAIT_DESC"],
            "sd_showPortrait",
            true,
            {
                id          = "sd_showPortrait",
                disabled    = SDDisabled,
                visibleWhen = SDSubVisible,
                refreshIds  = { "sd_modelPosition", "sd_modelSize", "sd_modelOffsetX" },
                set         = function(v)
                    setDB("sd_showPortrait", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),

        {
            type        = "dropdown",
            name        = L["FOCUS_INTEGRATION_RARE_MODEL_POSITION"],
            desc        = L["FOCUS_INTEGRATION_RARE_MODEL_POSITION_DESC"],
            dbKey       = "sd_modelPosition",
            disabled    = SDDisabled,
            visibleWhen = function() return SDSubVisible() and addon.GetDB("sd_showPortrait", true) end,
            options     = function()
                return {
                    { L["FOCUS_INTEGRATION_RARE_MODEL_POSITION_RIGHT"], "right" },
                    { L["FOCUS_INTEGRATION_RARE_MODEL_POSITION_LEFT"],  "left"  },
                }
            end,
            get = function() return addon.GetDB("sd_modelPosition", "right") end,
            set = function(v) setDB("sd_modelPosition", v); addon.ScheduleRefresh() end,
        },

        Slider(
            L["FOCUS_INTEGRATION_RARE_MODEL_SIZE"],
            L["FOCUS_INTEGRATION_RARE_MODEL_SIZE_DESC"],
            "sd_modelSize", 32, 128, 64,
            {
                id          = "sd_modelSize",
                disabled    = SDDisabled,
                visibleWhen = function() return SDSubVisible() and addon.GetDB("sd_showPortrait", true) end,
                set         = function(v) setDB("sd_modelSize", v); addon.ScheduleRefresh() end,
            }
        ),

        Slider(
            L["FOCUS_INTEGRATION_RARE_MODEL_OFFSET_X"],
            L["FOCUS_INTEGRATION_RARE_MODEL_OFFSET_X_DESC"],
            "sd_modelOffsetX", -100, 100, 0,
            {
                id          = "sd_modelOffsetX",
                disabled    = SDDisabled,
                visibleWhen = function() return SDSubVisible() and addon.GetDB("sd_showPortrait", true) end,
                set         = function(v) setDB("sd_modelOffsetX", v); addon.ScheduleRefresh() end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARE_SHOW_VIGNETTE_ICON"],
            L["FOCUS_INTEGRATION_RARE_SHOW_VIGNETTE_ICON_DESC"],
            "sd_showVignetteIcon",
            true,
            {
                id          = "sd_showVignetteIcon",
                disabled    = SDDisabled,
                visibleWhen = SDSubVisible,
                set         = function(v)
                    setDB("sd_showVignetteIcon", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_SILVERDRAGON_SHOW_RARES"],
            L["FOCUS_INTEGRATION_SILVERDRAGON_SHOW_RARES_DESC"],
            "sd_showRares",
            true,
            {
                id          = "sd_showRares",
                disabled    = SDDisabled,
                visibleWhen = SDSubVisible,
                set         = function(v)
                    setDB("sd_showRares", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_SILVERDRAGON_SHOW_LOOT"],
            L["FOCUS_INTEGRATION_SILVERDRAGON_SHOW_LOOT_DESC"],
            "sd_showLoot",
            true,
            {
                id          = "sd_showLoot",
                disabled    = SDDisabled,
                visibleWhen = SDSubVisible,
                set         = function(v)
                    setDB("sd_showLoot", v)
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),

        Color(
            L["FOCUS_INTEGRATION_RARE_COLOR"],
            L["FOCUS_INTEGRATION_RARE_COLOR_DESC"],
            "sd_color",
            { 0.78, 0.87, 1.00 },
            {
                id          = "sd_color",
                disabled    = SDDisabled,
                visibleWhen = SDSubVisible,
                get         = function()
                    local c = addon.GetDB("sd_color")
                    if type(c) == "table" and c[1] then return c[1], c[2], c[3] end
                    return 0.78, 0.87, 1.00
                end,
                set         = function(r, g, b)
                    setDB("sd_color", { r, g, b })
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end,
            }
        ),

        Toggle(
            L["FOCUS_INTEGRATION_RARE_CLICK_TO_TARGET"],
            L["FOCUS_INTEGRATION_RARE_CLICK_TO_TARGET_DESC"],
            "sd_clickToTarget",
            false,
            {
                id          = "sd_clickToTarget",
                disabled    = SDDisabled,
                visibleWhen = SDSubVisible,
                set         = function(v) setDB("sd_clickToTarget", v) end,
            }
        ),

        addon.Button(
            L["FOCUS_INTEGRATION_SILVERDRAGON_TEST_BTN"],
            L["FOCUS_INTEGRATION_SILVERDRAGON_TEST_BTN_DESC"],
            function()
                local core = rawget(_G, "SilverDragon")
                if not core or not (core.events and core.events.Fire) then return end
                core.events:Fire("Seen", 32491, 120, 0.490, 0.362, false, "fake")
            end,
            {
                disabled    = SDDisabled,
                visibleWhen = SDEnabled,
            }
        ),
    },
}
