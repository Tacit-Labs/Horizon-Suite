--[[
    Horizon Suite - Global Toggles - Options categories
    Self-registers into addon.OptionCategories after OptionsData.lua runs.
]]
local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L = addon.L
local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end
local OUTLINE_OPTIONS      = addon.OUTLINE_OPTIONS
local VALID_OUTLINE_VALUES = addon.VALID_OUTLINE_VALUES
local FONT_USE_GLOBAL      = addon.FONT_USE_GLOBAL  -- luacheck: ignore (used inside options fn)
local D                    = addon.AXIS_DEFAULTS

local categories = {
    {
        key = "GlobalToggles",
        name = L["AXIS_GLOBAL_TOGGLES"],
        desc = L["AXIS_SUITE_WIDE_CLASS_COLOUR_TINTING_UI"],
        moduleKey = nil,
        options = function()
            local BM = addon.BrandModule
            local defaultDashboardFontPath = D and D.dashboardFontPath or "__global__"
            local function GetDashboardFontDropdownOptions()
                if addon.RefreshFontList then addon.RefreshFontList() end
                local list = (addon.GetFontList and addon.GetFontList()) or {}
                local out = { { L["FOCUS_GLOBAL_FONT"], FONT_USE_GLOBAL } }
                for i = 1, #list do out[#out + 1] = list[i] end
                local saved = getDB("dashboardFontPath", defaultDashboardFontPath)
                if saved == FONT_USE_GLOBAL then return out end
                for _, o in ipairs(out) do
                    if o[2] == saved then return out end
                end
                out[#out + 1] = { L["FOCUS_CUSTOM"], saved }
                return out
            end
            local opts = {}
            opts[#opts + 1] = { type = "section", name = L["AXIS_DASHBOARD_SECTION"] }
            opts[#opts + 1] = {
                type = "dropdown",
                name = L["AXIS_MODULE_NAME_DISPLAY"],
                desc = L["AXIS_MODULE_NAME_DISPLAY_DESC"],
                dbKey = "moduleNameDisplay",
                options = {
                    { L["AXIS_MODULE_NAME_HORIZON"],     "horizon"     },
                    { L["AXIS_MODULE_NAME_SUBTITLE"],    "subtitle"    },
                    { L["AXIS_MODULE_NAME_SIMPLE"], "simple" },
                },
                get = function() return getDB("moduleNameDisplay", "horizon") end,
                set = function(v)
                    setDB("moduleNameDisplay", v)
                    local dash = _G.HorizonSuiteDashboard
                    if dash and dash.RefreshModuleDisplayNames then
                        dash.RefreshModuleDisplayNames()
                    end
                end,
            }
            local function dashboardBackgroundDropdownOptions()
                local order = addon.DashboardBackgroundThemeOrder or { "horizon", "midnight", "talents" }
                local out = {}
                for _, id in ipairs(order) do
                    local label
                    if id == "horizon" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_MINIMALISTIC"]
                    elseif id == "midnight" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_MIDNIGHT"]
                    elseif id == "teldrassilburns" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_TELDRASSIL_BURNS"]
                    elseif id == "nightfae" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_NIGHTFAE"]
                    elseif id == "ardenweald" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_ARDENWEALD"]
                    elseif id == "zinazshari" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_ZIN_AZSHARI"]
                    elseif id == "suramargarden" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_SURAMAR_GARDEN"]
                    elseif id == "quelthalas" then
                        label = L["DASH_BACKGROUND_QUEL_THALAS"]
                    elseif id == "twilightvineyards" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_TWILIGHT_VINEYARDS"]
                    elseif id == "zulaman" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_ZUL_AMAN"]
                    elseif id == "illidan" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_ILLIDAN"]
                    elseif id == "lichking" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_LICH_KING"]
                    elseif id == "tbcanniversary" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_TBC_ANNIVERSARY"]
                    elseif id == "beledarslight" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_BELEDARS_LIGHT"]
                    elseif id == "talents" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_CLASS_TALENTS"]
                    else
                        label = id
                    end
                    out[#out + 1] = { label, id }
                end
                return out
            end
            opts[#opts + 1] = {
                type = "dropdown",
                name = L["FOCUS_DASHBOARD_BACKGROUND"],
                desc = L["DASH_BACKGROUND"],
                dbKey = "dashboardBackgroundTheme",
                searchable = true,
                options = dashboardBackgroundDropdownOptions,
                get = function()
                    local v = getDB("dashboardBackgroundTheme", "midnight")
                    if v == "solid" then
                        v = "horizon"
                    end
                    if v == "teldrassil" then
                        v = "teldrassilburns"
                    end
                    local order = addon.DashboardBackgroundThemeOrder or { "horizon", "midnight", "talents" }
                    for _, id in ipairs(order) do
                        if v == id then
                            return v
                        end
                    end
                    return "midnight"
                end,
                set = function(v) setDB("dashboardBackgroundTheme", v) end,
                refreshIds = { "dashboardBackgroundTheme" },
            }
            opts[#opts + 1] = {
                type = "slider", name = L["FOCUS_DASHBOARD_BACKGROUND_OPACITY"],
                desc = L["FOCUS_ADJUST_OPACITY_OF_DASHBOARD_BACKGROUND"],
                dbKey = "dashboardBackgroundOpacity", min = 50, max = 100, step = 1,
                get = function()
                    return math.floor((tonumber(getDB("dashboardBackgroundOpacity", 90)) or 90) + 0.5)
                end,
                set = function(v)
                    setDB("dashboardBackgroundOpacity", math.max(50, math.min(100, v)))
                end,
                refreshIds = { "dashboardBackgroundOpacity" },
            }
            local dashboardTypoRefreshIds = {
                "dashboardFontPath",
                "dashboardFontSize",
                "dashboardTextOutline",
                "dashboardTextShadow",
                "dashboardHeadingColor",
            }
            opts[#opts + 1] = {
                type = "dropdown",
                name = L["DASHBOARD_TYPO_FONT"],
                desc = L["DASHBOARD_TYPO_FONT_DESC"],
                dbKey = "dashboardFontPath",
                searchable = true,
                options = GetDashboardFontDropdownOptions,
                get = function() return getDB("dashboardFontPath", defaultDashboardFontPath) end,
                set = function(v) setDB("dashboardFontPath", v) end,
                displayFn = addon.GetFontNameForPath,
                fontPreviewInList = true,
                refreshIds = dashboardTypoRefreshIds,
            }
            opts[#opts + 1] = {
                type = "slider",
                name = L["DASHBOARD_TYPO_SIZE"],
                desc = L["DASHBOARD_TYPO_SIZE_DESC"],
                dbKey = "dashboardFontSize",
                min = 10,
                max = 18,
                step = 1,
                get = function()
                    if addon.Dashboard_GetBodySize then return addon.Dashboard_GetBodySize() end
                    return getDB("dashboardFontSize", 13)
                end,
                set = function(v)
                    setDB("dashboardFontSize", math.max(10, math.min(18, math.floor((tonumber(v) or 13) + 0.5))))
                end,
                refreshIds = dashboardTypoRefreshIds,
            }
            opts[#opts + 1] = {
                type = "dropdown",
                name = L["DASHBOARD_TYPO_OUTLINE"],
                desc = L["DASHBOARD_TYPO_OUTLINE_DESC"],
                dbKey = "dashboardTextOutline",
                options = OUTLINE_OPTIONS,
                preserveOrder = true,
                get = function()
                    local v = getDB("dashboardTextOutline", 1)
                    if VALID_OUTLINE_VALUES[v] then return v end
                    if v == true then return "OUTLINE" end
                    if v == false then return "" end
                    local n = tonumber(v)
                    if not n then return "OUTLINE" end
                    n = math.max(0, math.min(2, math.floor(n + 0.5)))
                    if n == 0 then return "" end
                    if n == 2 then return "THICKOUTLINE" end
                    return "OUTLINE"
                end,
                set = function(v) setDB("dashboardTextOutline", v) end,
                refreshIds = dashboardTypoRefreshIds,
            }
            opts[#opts + 1] = {
                type = "toggle",
                name = L["DASHBOARD_TYPO_SHADOW"],
                desc = L["DASHBOARD_TYPO_SHADOW_DESC"],
                dbKey = "dashboardTextShadow",
                get = function()
                    local v = getDB("dashboardTextShadow", false)
                    if type(v) == "number" then return v > 0 end
                    return v == true
                end,
                set = function(v) setDB("dashboardTextShadow", v) end,
                refreshIds = dashboardTypoRefreshIds,
            }
            opts[#opts + 1] = {
                type = "dropdown",
                name = L["DASHBOARD_TYPO_HEADING_COLOR"],
                desc = L["DASHBOARD_TYPO_HEADING_COLOR_DESC"],
                dbKey = "dashboardHeadingColor",
                options = {
                    { L["DASHBOARD_TYPO_HEADING_COLOR_WHITE"], "white" },
                    { L["DASHBOARD_TYPO_HEADING_COLOR_CYAN"],  "cyan"  },
                    { L["DASHBOARD_TYPO_HEADING_COLOR_GOLD"],  "gold"  },
                },
                preserveOrder = true,
                get = function() return getDB("dashboardHeadingColor", "white") end,
                set = function(v)
                    setDB("dashboardHeadingColor", v)
                    if addon.Dashboard_RefreshHeadingColors then addon.Dashboard_RefreshHeadingColors() end
                end,
                refreshIds = dashboardTypoRefreshIds,
            }
            opts[#opts + 1] = {
                type = "toggle",
                name = L["AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN"],
                desc = L["AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN_DESC"],
                dbKey = "autoShowPatchNotesOnLogin",
                get = function() return getDB("autoShowPatchNotesOnLogin", true) end,
                set = function(v) setDB("autoShowPatchNotesOnLogin", v) end,
            }
            opts[#opts + 1] = { type = "section", name = L["AXIS_CLASS_THEME_SECTION"] }
            local classColorKeys = {
                "classColorDashboard", "classColorVista", "classColorInsight", "classColorEssence",
                "classColorFocus", "classColorPresence", "classColorCache",
            }
            -- Include "_classColorAll" so the master row Refresh() runs after batch (Axis/Dashboard accordion does not use OptionsPanel allRefreshers).
            local classColorAllRefreshIds = { "_classColorAll" }
            for _, k in ipairs(classColorKeys) do
                classColorAllRefreshIds[#classColorAllRefreshIds + 1] = k
            end
            opts[#opts + 1] = {
                type = "toggle",
                name = L["AXIS_GLOBAL_CLASS_THEME"],
                desc = L["DASH_CLASS_COLOURS_MODULES_GLOBAL"],
                dbKey = "_classColorAll",
                refreshIds = classColorAllRefreshIds,
                get = function()
                    for _, k in ipairs(classColorKeys) do
                        if not getDB(k, false) then return false end
                    end
                    return true
                end,
                set = function(v)
                    for _, k in ipairs(classColorKeys) do
                        addon.SetDB(k, v)
                    end
                    if addon.ApplyAllClassColorConsumers then addon.ApplyAllClassColorConsumers() end
                    if addon.OptionsPanel_Refresh then addon.OptionsPanel_Refresh() end
                end,
            }
            local function isDashboardClassThemeOn() return getDB("dashboardClassTheme", false) end
            opts[#opts + 1] = {
                type = "toggle",
                name = L["AXIS_CLASS_THEME_DASHBOARD"],
                desc = L["AXIS_CLASS_THEME_DASHBOARD_DESC"],
                dbKey = "dashboardClassTheme",
                get = isDashboardClassThemeOn,
                set = function(v)
                    setDB("dashboardClassTheme", v)
                    setDB("classColorDashboard", v)
                    setDB("dashboardShowClassIcon", v)
                    setDB("dashboardBackgroundClassOverride", v)
                end,
                refreshIds = { "_classColorAll", "classColorDashboard", "dashboardShowClassIcon", "dashboardClassIconSource", "dashboardBackgroundClassOverride" },
            }
            opts[#opts + 1] = {
                type = "toggle",
                name = L["AXIS_DASHBOARD_CLASS_COLOURS"],
                desc = L["AXIS_CLASS_COLOURS_DESC"],
                dbKey = "classColorDashboard",
                get = function() return getDB("classColorDashboard", false) end,
                set = function(v) setDB("classColorDashboard", v) end,
                visibleWhen = isDashboardClassThemeOn,
                refreshIds = { "_classColorAll" },
            }
            opts[#opts + 1] = {
                type = "toggle",
                name = L["AXIS_DASHBOARD_CLASS_ICON"],
                desc = L["AXIS_DASHBOARD_CLASS_ICON_DESC"],
                dbKey = "dashboardShowClassIcon",
                get = function() return getDB("dashboardShowClassIcon", false) end,
                set = function(v) setDB("dashboardShowClassIcon", v) end,
                visibleWhen = isDashboardClassThemeOn,
                refreshIds = { "dashboardShowClassIcon", "dashboardClassIconSource" },
            }
            opts[#opts + 1] = {
                type = "dropdown",
                name = L["DASHBOARD_CLASS_ICON_STYLE"],
                desc = L["DASH_CLASS_ICONS_RONDOMEDIA"],
                tooltip = L["AXIS_CLASS_ICON_SOURCES_TOOLTIP"],
                dbKey = "dashboardClassIconSource",
                options = {
                    { L["AXIS_CUSTOM_CLASS_ICONS_LABEL"], "custom" },
                    { L["AXIS_DEFAULT"], "default" },
                    { "RondoMedia", "rondomedia" },
                },
                get = function() return getDB("dashboardClassIconSource", "custom") end,
                set = function(v) setDB("dashboardClassIconSource", v) end,
                visibleWhen = function() return isDashboardClassThemeOn() and getDB("dashboardShowClassIcon", false) end,
                refreshIds = { "dashboardShowClassIcon" },
            }
            opts[#opts + 1] = {
                type = "toggle",
                name = L["AXIS_DASHBOARD_BG_CLASS_OVERRIDE"],
                desc = L["AXIS_DASHBOARD_BG_CLASS_OVERRIDE_DESC"],
                dbKey = "dashboardBackgroundClassOverride",
                get = function() return getDB("dashboardBackgroundClassOverride", false) end,
                set = function(v) setDB("dashboardBackgroundClassOverride", v) end,
                visibleWhen = isDashboardClassThemeOn,
                refreshIds = { "dashboardBackgroundTheme" },
            }
            opts[#opts + 1] = { type = "toggle", name = BM and BM("focus"), desc = L["FOCUS_CLASS_COLOURS_DESC"], dbKey = "classColorFocus", get = function() return getDB("classColorFocus", false) end, set = function(v) setDB("classColorFocus", v) end, refreshIds = { "_classColorAll" } }
            opts[#opts + 1] = { type = "toggle", name = BM and BM("presence"), desc = L["PRESENCE_CLASS_COLOURS_DESC"], dbKey = "classColorPresence", get = function() return getDB("classColorPresence", false) end, set = function(v) setDB("classColorPresence", v) end, refreshIds = { "_classColorAll" } }
            opts[#opts + 1] = { type = "toggle", name = BM and BM("vista"), desc = L["VISTA_CLASS_COLOURS_DESC"], dbKey = "classColorVista", get = function() return getDB("classColorVista", false) end, set = function(v) setDB("classColorVista", v) end, refreshIds = { "_classColorAll" } }
            opts[#opts + 1] = { type = "toggle", name = BM and BM("insight"), desc = L["INSIGHT_CLASS_COLOURS_DESC"], dbKey = "classColorInsight", get = function() return getDB("classColorInsight", false) end, set = function(v) setDB("classColorInsight", v) end, refreshIds = { "_classColorAll" } }
            opts[#opts + 1] = { type = "toggle", name = BM and BM("cache"), desc = L["CACHE_CLASS_COLOURS_DESC"], dbKey = "classColorCache", get = function() return getDB("classColorCache", false) end, set = function(v) setDB("classColorCache", v) end, refreshIds = { "_classColorAll" } }
            opts[#opts + 1] = { type = "toggle", name = BM and BM("essence"), desc = L["ESSENCE_CLASS_COLOURS_DESC"], dbKey = "classColorEssence", get = function() return getDB("classColorEssence", false) end, set = function(v) setDB("classColorEssence", v) end, refreshIds = { "_classColorAll" } }
            opts[#opts + 1] = { type = "section", name = L["AXIS_GLOBAL_FONT_SECTION"] }
            local isGlobalFontOn = function() return getDB("useGlobalFont", D and D.useGlobalFont or false) end
            opts[#opts + 1] = {
                type = "toggle",
                name = L["AXIS_USE_GLOBAL_FONT"],
                desc = L["AXIS_USE_GLOBAL_FONT_DESC"],
                dbKey = "useGlobalFont",
                get = isGlobalFontOn,
                set = function(v) setDB("useGlobalFont", v) end,
                refreshIds = { "globalOverrideFontPath" },
            }
            opts[#opts + 1] = {
                type = "dropdown",
                name = L["AXIS_GLOBAL_FONT_PICKER"],
                desc = L["AXIS_GLOBAL_FONT_PICKER_DESC"],
                dbKey = "globalOverrideFontPath",
                searchable = true,
                disabled = function() return not isGlobalFontOn() end,
                options = function()
                    if addon.RefreshFontList then addon.RefreshFontList() end
                    local list = (addon.GetFontList and addon.GetFontList()) or {}
                    local saved = getDB("globalOverrideFontPath", nil)
                    if not saved or saved == "" then return list end
                    for _, o in ipairs(list) do
                        if o[2] == saved then return list end
                    end
                    local out = {}
                    for i = 1, #list do out[i] = list[i] end
                    out[#out + 1] = { L["FOCUS_CUSTOM"], saved }
                    return out
                end,
                get = function() return getDB("globalOverrideFontPath", nil) end,
                set = function(v) setDB("globalOverrideFontPath", v) end,
                displayFn = addon.GetFontNameForPath,
                fontPreviewInList = true,
            }
            opts[#opts + 1] = { type = "section", name = L["AXIS_GLOBAL_SCALE_SECTION"] }
            local function refreshAllScaling()
                if addon.ApplyTypography then addon.ApplyTypography() end
                if addon.ApplyDimensions then addon.ApplyDimensions() end
                if addon.ApplyMplusTypography then addon.ApplyMplusTypography() end
                if addon.Presence and addon.Presence.ApplyPresenceOptions then addon.Presence.ApplyPresenceOptions() end
                if addon.Vista and addon.Vista.ApplyScale then addon.Vista.ApplyScale() end
                if addon.Cache and addon.Cache.ApplyScale then addon.Cache.ApplyScale() end
                local fullLayout = addon.FullLayout or _G.HorizonSuite_FullLayout
                if fullLayout and not InCombatLockdown() then fullLayout() end
            end
            local scalingDebounceTimers = {}
            local SCALE_DEBOUNCE = 0.15
            local function debouncedRefresh(key, applyFn)
                if scalingDebounceTimers[key] then
                    scalingDebounceTimers[key]:Cancel()
                    scalingDebounceTimers[key] = nil
                end
                scalingDebounceTimers[key] = C_Timer.NewTimer(SCALE_DEBOUNCE, function()
                    scalingDebounceTimers[key] = nil
                    applyFn()
                end)
            end
            local function isPerModule() return getDB("perModuleScaling", false) end
            opts[#opts + 1] = { type = "slider", name = L["AXIS_GLOBAL_UI_SCALE"], desc = L["SCALE_UI_ELEMENTS"], dbKey = "globalUIScale_pct", min = 50, max = 200, tooltip = L["AXIS_DOESN_T_CHANGE_YOUR_CONFIGURED_VALUES"],
                disabled = isPerModule,
                get = function()
                    return math.floor((tonumber(getDB("globalUIScale", 1)) or 1) * 100 + 0.5)
                end, set = function(v)
                    local scale = math.max(50, math.min(200, v)) / 100
                    setDB("globalUIScale", scale)
                    debouncedRefresh("global", refreshAllScaling)
                end }
            opts[#opts + 1] = { type = "toggle", name = L["AXIS_PER_MODULE_SCALING"], desc = L["SEPARATE_SCALE_SLIDER_PER_MODULE"], dbKey = "perModuleScaling", tooltip = L["AXIS_OVERRIDES_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_F"], get = function() return isPerModule() end, set = function(v)
                setDB("perModuleScaling", v)
                debouncedRefresh("perModule", refreshAllScaling)
            end,
            refreshIds = { "globalUIScale_pct", "focusUIScale_pct", "presenceUIScale_pct", "vistaUIScale_pct", "insightUIScale_pct", "cacheUIScale_pct" },
            }
            opts[#opts + 1] = { type = "slider", name = L["FOCUS_SCALE"], desc = L["AXIS_SCALE_FOCUS_OBJECTIVE_TRACKER"], dbKey = "focusUIScale_pct", min = 50, max = 200,
                visibleWhen = isPerModule,
                get = function()
                    return math.floor((tonumber(getDB("focusUIScale", 1)) or 1) * 100 + 0.5)
                end, set = function(v)
                    setDB("focusUIScale", math.max(50, math.min(200, v)) / 100)
                    debouncedRefresh("focus", refreshAllScaling)
                end }
            opts[#opts + 1] = { type = "slider", name = L["PRESENCE_SCALE"], desc = L["AXIS_SCALE_PRESENCE_CINEMATIC_TEXT"], dbKey = "presenceUIScale_pct", min = 50, max = 200,
                visibleWhen = isPerModule,
                get = function()
                    return math.floor((tonumber(getDB("presenceUIScale", 1)) or 1) * 100 + 0.5)
                end, set = function(v)
                    setDB("presenceUIScale", math.max(50, math.min(200, v)) / 100)
                    debouncedRefresh("presence", function()
                        if addon.Presence and addon.Presence.ApplyPresenceOptions then addon.Presence.ApplyPresenceOptions() end
                    end)
                end }
            opts[#opts + 1] = { type = "slider", name = L["VISTA_SCALE"], desc = L["AXIS_SCALE_VISTA_MINIMAP_MODULE"], dbKey = "vistaUIScale_pct", min = 50, max = 200,
                visibleWhen = isPerModule,
                get = function()
                    return math.floor((tonumber(getDB("vistaUIScale", 1)) or 1) * 100 + 0.5)
                end, set = function(v)
                    setDB("vistaUIScale", math.max(50, math.min(200, v)) / 100)
                    debouncedRefresh("vista", function()
                        if addon.Vista and addon.Vista.ApplyScale then addon.Vista.ApplyScale() end
                    end)
                end }
            opts[#opts + 1] = { type = "slider", name = L["INSIGHT_SCALE"], desc = L["AXIS_SCALE_INSIGHT_TOOLTIP_MODULE"], dbKey = "insightUIScale_pct", min = 50, max = 200,
                visibleWhen = isPerModule,
                get = function()
                    return math.floor((tonumber(getDB("insightUIScale", 1)) or 1) * 100 + 0.5)
                end, set = function(v)
                    setDB("insightUIScale", math.max(50, math.min(200, v)) / 100)
                end }
            opts[#opts + 1] = { type = "slider", name = L["CACHE_SCALE"], desc = L["AXIS_SCALE_CACHE_LOOT_TOAST_MODULE"], dbKey = "cacheUIScale_pct", min = 50, max = 200,
                visibleWhen = isPerModule,
                get = function()
                    return math.floor((tonumber(getDB("cacheUIScale", 1)) or 1) * 100 + 0.5)
                end, set = function(v)
                    setDB("cacheUIScale", math.max(50, math.min(200, v)) / 100)
                    debouncedRefresh("cache", function()
                        if addon.Cache and addon.Cache.ApplyScale then addon.Cache.ApplyScale() end
                    end)
                end }
            -- Standalone: button is on the minimap, not collected by Vista.
            local function isMinimapStandalone()
                return not getDB("hideMinimapButton", false)
                    and not (addon.IsModuleEnabled and addon:IsModuleEnabled("vista")
                             and getDB("vistaCollectHorizonMinimapButton", true))
            end
            opts[#opts + 1] = { type = "section", name = L["AXIS_MINIMAP_ICON_SECTION"] }
            opts[#opts + 1] = { type = "toggle", name = L["PRESENCE_SHOW_MINIMAP_ICON"], desc = L["PRESENCE_A_CLICKABLE_ICON_MINIMAP_OPENS"], dbKey = "hideMinimapButton", get = function() return not getDB("hideMinimapButton", false) end, set = function(v)
                -- Write DB synchronously so dependents' refreshIds see the new value immediately.
                setDB("hideMinimapButton", not v)
                C_Timer.After(0, function()
                    -- Vista may be collecting the icon into its bar/drawer; re-run collection so the proxy is dropped/re-added.
                    if addon.Vista and addon.Vista.ApplyOptions and addon.IsModuleEnabled and addon:IsModuleEnabled("vista") then
                        addon.Vista.ApplyOptions()
                    end
                    if addon.MinimapButton_UpdateVisibility then addon.MinimapButton_UpdateVisibility() end
                end)
            end,
            refreshIds = { "minimapButtonShowOnlyOnMinimapHover", "minimapButtonLocked", "__minimapButtonReset" },
            }
            opts[#opts + 1] = { type = "toggle", name = L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER"], desc = L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER_DESC"], dbKey = "minimapButtonShowOnlyOnMinimapHover", visibleWhen = isMinimapStandalone, get = function() return getDB("minimapButtonShowOnlyOnMinimapHover", false) end, set = function(v)
                C_Timer.After(0, function()
                    setDB("minimapButtonShowOnlyOnMinimapHover", v)
                    if addon.MinimapButton_UpdateVisibility then addon.MinimapButton_UpdateVisibility() end
                end)
            end }
            opts[#opts + 1] = { type = "toggle", name = L["PRESENCE_LOCK_MINIMAP_BUTTON_POSITION"], desc = L["PRESENCE_PREVENT_DRAGGING_HORIZON_MINIMAP_BUTTON"], dbKey = "minimapButtonLocked", visibleWhen = isMinimapStandalone, get = function() return getDB("minimapButtonLocked", false) end, set = function(v)
                C_Timer.After(0, function() setDB("minimapButtonLocked", v) end)
            end }
            opts[#opts + 1] = { type = "toggle", name = L["AXIS_MINIMAP_ICON_CIRCULAR"],
                desc = L["AXIS_MINIMAP_ICON_CIRCULAR_DESC"],
                dbKey = "minimapButtonCircular", visibleWhen = isMinimapStandalone,
                get = function() return getDB("minimapButtonCircular", false) end,
                set = function(v)
                    setDB("minimapButtonCircular", v)
                    if addon.MinimapButton_ApplyShape then addon.MinimapButton_ApplyShape() end
                    -- Re-place the button: circular reads angle / square reads x/y.
                    if addon.MinimapButton_ApplyPosition then addon.MinimapButton_ApplyPosition() end
                end }
            opts[#opts + 1] = { type = "button", dbKey = "__minimapButtonReset", name = L["PRESENCE_RESET_MINIMAP_BUTTON_POSITION"], desc = L["PRESENCE_RESET_MINIMAP_BUTTON_DEFAULT_POSITION"], visibleWhen = isMinimapStandalone, onClick = function() setDB("minimapButtonX", nil); setDB("minimapButtonY", nil); setDB("minimapButtonAngle", nil); if addon.MinimapButton_ApplyPosition then addon.MinimapButton_ApplyPosition() end end }
            return opts
        end,
    },
}

table.insert(addon.OptionCategories, 2, categories[1])
