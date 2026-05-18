--[[
    Horizon Suite - Axis - Options categories
    Self-registers into addon.OptionCategories after OptionsData.lua runs.
    Inserts at the beginning so Axis tabs appear first in the panel.
]]
local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L = addon.L
local function getDB(k, d) return addon.GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end
local BrandModule       = addon.BrandModule
local OUTLINE_OPTIONS   = addon.OUTLINE_OPTIONS
local FONT_USE_GLOBAL   = addon.FONT_USE_GLOBAL
local Section           = addon.Section
local ModuleReloadPrompt = addon.ModuleReloadPrompt
local Button            = addon.Button
local Toggle            = addon.Toggle

local function GetGlobalFontDropdownOptions()
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
end

local function GetDashboardFontDropdownOptions()
    if addon.RefreshFontList then addon.RefreshFontList() end
    local list = (addon.GetFontList and addon.GetFontList()) or {}
    local out = { { L["FOCUS_GLOBAL_FONT"], FONT_USE_GLOBAL } }
    for i = 1, #list do out[#out + 1] = list[i] end
    local saved = getDB("dashboardFontPath", FONT_USE_GLOBAL)
    if saved == FONT_USE_GLOBAL then return out end
    for _, o in ipairs(out) do
        if o[2] == saved then return out end
    end
    out[#out + 1] = { L["FOCUS_CUSTOM"], saved }
    return out
end

local VALID_OUTLINE_VALUES = {
    [""] = true,
    OUTLINE = true,
    THICKOUTLINE = true,
    SLUG = true,
    ["OUTLINE, SLUG"] = true,
    ["THICKOUTLINE, SLUG"] = true,
}

local categories = {
    {
        key = "Modules",
        name = L["MODULES"],
        moduleKey = nil,
        options = (function()
            local previewSuffix = " |cff228b22(" .. (L["PRESENCE_PREVIEW"]) .. ")|r"
            local previewDescSuffix = "\n\n" .. (L["MODULE_PREVIEW_DISCLAIMER"])
            local function setModuleFromOptions(moduleKey, v)
                local dash = _G.HorizonSuiteDashboard
                local defer = dash and dash:IsShown()
                addon:SetModuleEnabled(moduleKey, v, defer and { deferReload = true } or nil)
            end
            local opts = {
                Section(L["MODULE_TOGGLES"]),
                { type = "toggle", name = BrandModule("focus"), desc = L["DASH_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS"], dbKey = "_module_focus", get = function() return addon:IsModuleEnabled("focus") end, set = function(v) setModuleFromOptions("focus", v) end },
                { type = "toggle", name = BrandModule("presence"), desc = L["DASH_ZONE_TEXT_AND_NOTIFICATIONS"], dbKey = "_module_presence", get = function() return addon:IsModuleEnabled("presence") end, set = function(v) setModuleFromOptions("presence", v) end },
                { type = "toggle", name = BrandModule("vista"), desc = L["DASH_MINIMAP_ZONE_TEXT_COORDS_BUTTON"], dbKey = "_module_vista", get = function() return addon:IsModuleEnabled("vista") end, set = function(v) setModuleFromOptions("vista", v) end },
                { type = "toggle", name = BrandModule("insight"), desc = L["DASH_TOOLTIPS_CLASS_COLOURS_SPEC_FACTION"], dbKey = "_module_insight", get = function() return addon:IsModuleEnabled("insight") end, set = function(v) setModuleFromOptions("insight", v) end },
                { type = "toggle", name = (BrandModule("cache") or "Cache") .. previewSuffix, desc = (L["DASH_LOOT_TOASTS_ITEMS_MONEY_CURRENCY"]) .. previewDescSuffix, dbKey = "_module_cache", get = function() return addon:IsModuleEnabled("cache") end, set = function(v) setModuleFromOptions("cache", v) end },
                { type = "toggle", name = (BrandModule("essence") or "Essence") .. previewSuffix, desc = (L["DASH_ESSENCE_MODULE_SHORT_DESCRIPTION"]) .. previewDescSuffix, dbKey = "_module_essence", get = function() return addon:IsModuleEnabled("essence") end, set = function(v) setModuleFromOptions("essence", v) end },
                ModuleReloadPrompt(),
            }
            return opts
        end)(),
    },
    {
        key = "GlobalToggles",
        name = L["AXIS_GLOBAL_TOGGLES"],
        desc = L["AXIS_SUITE_WIDE_CLASS_COLOUR_TINTING_UI"],
        moduleKey = nil,
        options = function()
            local opts = {}
            opts[#opts + 1] = Section(L["AXIS_DASHBOARD_SECTION"])
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
                get = function() return getDB("dashboardFontPath", FONT_USE_GLOBAL) end,
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
            opts[#opts + 1] = Toggle(L["AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN"], L["AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN_DESC"], "autoShowPatchNotesOnLogin", true)
            opts[#opts + 1] = Section(L["AXIS_CLASS_THEME_SECTION"])
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
            opts[#opts + 1] = Toggle(L["AXIS_DASHBOARD_CLASS_COLOURS"], L["AXIS_CLASS_COLOURS_DESC"], "classColorDashboard", false, { visibleWhen = isDashboardClassThemeOn, refreshIds = { "_classColorAll" } })
            opts[#opts + 1] = Toggle(L["AXIS_DASHBOARD_CLASS_ICON"], L["AXIS_DASHBOARD_CLASS_ICON_DESC"], "dashboardShowClassIcon", false, { visibleWhen = isDashboardClassThemeOn, refreshIds = { "dashboardShowClassIcon", "dashboardClassIconSource" } })
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
            opts[#opts + 1] = Toggle(L["AXIS_DASHBOARD_BG_CLASS_OVERRIDE"], L["AXIS_DASHBOARD_BG_CLASS_OVERRIDE_DESC"], "dashboardBackgroundClassOverride", false, { visibleWhen = isDashboardClassThemeOn, refreshIds = { "dashboardBackgroundTheme" } })
            opts[#opts + 1] = Toggle(BrandModule("focus"), L["FOCUS_CLASS_COLOURS_DESC"], "classColorFocus", false, { refreshIds = { "_classColorAll" } })
            opts[#opts + 1] = Toggle(BrandModule("presence"), L["PRESENCE_CLASS_COLOURS_DESC"], "classColorPresence", false, { refreshIds = { "_classColorAll" } })
            opts[#opts + 1] = Toggle(BrandModule("vista"), L["VISTA_CLASS_COLOURS_DESC"], "classColorVista", false, { refreshIds = { "_classColorAll" } })
            opts[#opts + 1] = Toggle(BrandModule("insight"), L["INSIGHT_CLASS_COLOURS_DESC"], "classColorInsight", false, { refreshIds = { "_classColorAll" } })
            opts[#opts + 1] = Toggle(BrandModule("cache"), L["CACHE_CLASS_COLOURS_DESC"], "classColorCache", false, { refreshIds = { "_classColorAll" } })
            opts[#opts + 1] = Toggle(BrandModule("essence"), L["ESSENCE_CLASS_COLOURS_DESC"], "classColorEssence", false, { refreshIds = { "_classColorAll" } })
            opts[#opts + 1] = Section(L["AXIS_GLOBAL_FONT_SECTION"])
            local isGlobalFontOn = function() return getDB("useGlobalFont", false) end
            opts[#opts + 1] = Toggle(L["AXIS_USE_GLOBAL_FONT"], L["AXIS_USE_GLOBAL_FONT_DESC"], "useGlobalFont", false, { refreshIds = { "globalOverrideFontPath" } })
            opts[#opts + 1] = {
                type = "dropdown",
                name = L["AXIS_GLOBAL_FONT_PICKER"],
                desc = L["AXIS_GLOBAL_FONT_PICKER_DESC"],
                dbKey = "globalOverrideFontPath",
                searchable = true,
                disabled = function() return not isGlobalFontOn() end,
                options = GetGlobalFontDropdownOptions,
                get = function() return getDB("globalOverrideFontPath", nil) end,
                set = function(v) setDB("globalOverrideFontPath", v) end,
                displayFn = addon.GetFontNameForPath,
                fontPreviewInList = true,
            }
            opts[#opts + 1] = Section(L["AXIS_GLOBAL_SCALE_SECTION"])
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
            opts[#opts + 1] = Section(L["AXIS_MINIMAP_ICON_SECTION"])
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
            opts[#opts + 1] = Button(L["PRESENCE_RESET_MINIMAP_BUTTON_POSITION"], L["PRESENCE_RESET_MINIMAP_BUTTON_DEFAULT_POSITION"], function() setDB("minimapButtonX", nil); setDB("minimapButtonY", nil); setDB("minimapButtonAngle", nil); if addon.MinimapButton_ApplyPosition then addon.MinimapButton_ApplyPosition() end end, { dbKey = "__minimapButtonReset", visibleWhen = isMinimapStandalone })
            return opts
        end,
    },
    {
        key = "Profiles",
        name = L["PROFILES"],
        desc = L["MANAGE_SWITCH_BETWEEN_YOUR_ADDON_CONFIGURATIONS"],
        moduleKey = nil,
        options = function()
            local opts = {}

            local function profileDropdownOptions()
                local list = addon.ListProfiles and addon.ListProfiles() or {}
                local out = {}
                for _, k in ipairs(list) do
                    if k ~= "Default" then
                        out[#out + 1] = { k, k }
                    end
                end
                return out
            end

            -- Section A: Global switch + current profile
            opts[#opts + 1] = Section(L["PROFILES"])

            opts[#opts + 1] = {
                type = "toggle",
                name = L["AXIS_GLOBAL_PROFILE"],
                desc = L["AXIS_CHARACTERS_SAME_PROFILE"],
                dbKey = "_profiles_useGlobal",
                get = function()
                    local useGlobal = addon.GetProfileModeState and select(1, addon.GetProfileModeState())
                    return useGlobal == true
                end,
                set = function(v)
                    local currentKey = addon.GetActiveProfileKey and addon.GetActiveProfileKey()
                    if addon.SetUseGlobalProfile then addon.SetUseGlobalProfile(v) end
                    if v and currentKey and addon.SetGlobalProfileKey then
                        addon.SetGlobalProfileKey(currentKey)
                    end
                    if addon.OnActiveProfileChangedDeferred then addon.OnActiveProfileChangedDeferred() end
                end,
                refreshIds = {
                    "_profiles_current",
                    "_profiles_usePerSpec",
                    "_profiles_spec_1",
                    "_profiles_spec_2",
                    "_profiles_spec_3",
                    "_profiles_spec_4",
                },
            }

                opts[#opts + 1] = {
                    type = "dropdown",
                    name = L["AXIS_CURRENT_PROFILE"],
                    desc = L["AXIS_SELECT_PROFILE_CURRENTLY"],
                    dbKey = "_profiles_current",
                    options = profileDropdownOptions,
                    disabled = function()
                        if not addon.GetProfileModeState then return false end
                        local useGlobal, usePerSpec = addon.GetProfileModeState()
                        return (useGlobal ~= true) and (usePerSpec == true)
                    end,
                    get = function() return (addon.GetActiveProfileKey and addon.GetActiveProfileKey()) end,
                    set = function(v)
                        if addon.SetActiveProfileKey then addon.SetActiveProfileKey(v) end
                        addon._profileCopyFrom = nil
                        if addon.OnActiveProfileChangedDeferred then addon.OnActiveProfileChangedDeferred() end
                    end,
                }

                opts[#opts + 1] = Button(L["DEFAULT"], L["AXIS_CREATES_A_PROFILE_DEFAULT_SETTINGS"], function()
                    if addon.ShowCreateProfilePopup then addon.ShowCreateProfilePopup("Default") end
                end, { dbKey = "_profiles_create_new" })

                opts[#opts + 1] = {
                    type = "dropdown",
                    name = L["AXIS_COPY_PROFILE"],
                    desc = L["AXIS_SOURCE_PROFILE_COPYING"],
                    dbKey = "_profiles_copyFrom",
                    options = profileDropdownOptions,
                    get = function()
                        local current = addon.GetActiveProfileKey and addon.GetActiveProfileKey() or nil
                        local list = addon.ListProfiles and addon.ListProfiles() or {}
                        if addon._profileCopyFrom and addon._profileCopyFrom ~= "" then
                            for _, k in ipairs(list) do
                                if k == addon._profileCopyFrom then return addon._profileCopyFrom end
                            end
                        end
                        addon._profileCopyFrom = current
                        return current
                    end,
                    set = function(v) addon._profileCopyFrom = v end,
                }

                opts[#opts + 1] = Button(L["AXIS_COPY_SELECTED"], L["AXIS_CREATES_A_PROFILE_COPIED_SELECTED_SOURC"], function()
                    local src = addon._profileCopyFrom or (addon.GetActiveProfileKey and addon.GetActiveProfileKey())
                    if addon.ShowCreateProfilePopup then addon.ShowCreateProfilePopup(src) end
                end, { dbKey = "_profiles_copy_selected" })

                opts[#opts + 1] = {
                    type = "dropdown",
                    name = "|cffff4040!|r " .. (L["AXIS_DELETE_PROFILE"]),
                    desc = L["AXIS_SELECT_A_PROFILE_DELETE_CURRENT_DEFAULT"],
                    dbKey = "_profiles_delete",
                    options = function()
                        local current = addon.GetActiveProfileKey and addon.GetActiveProfileKey() or nil
                        local list = addon.ListProfiles and addon.ListProfiles() or {}
                        local out = {}
                        for _, k in ipairs(list) do
                            if k ~= current and k ~= "Default" then out[#out + 1] = { k, k } end
                        end
                        return out
                    end,
                    get = function()
                        local current = addon.GetActiveProfileKey and addon.GetActiveProfileKey() or nil
                        local list = addon.ListProfiles and addon.ListProfiles() or {}
                        local function exists(k)
                            if not k or k == "" then return false end
                            for _, kk in ipairs(list) do if kk == k then return true end end
                            return false
                        end
                        if exists(addon._profileDeleteKey) and addon._profileDeleteKey ~= current and addon._profileDeleteKey ~= "Default" then
                            return addon._profileDeleteKey
                        end
                        for _, k in ipairs(list) do
                            if k ~= current and k ~= "Default" then
                                addon._profileDeleteKey = k
                                return k
                            end
                        end
                        addon._profileDeleteKey = nil
                        return ""
                    end,
                    set = function(v) addon._profileDeleteKey = v end,
                }

                opts[#opts + 1] = Button(L["AXIS_DELETE_SELECTED_PROFILE"], L["AXIS_DELETES_SELECTED_PROFILE"], function()
                    local k = addon._profileDeleteKey
                    if not k or k == "" then
                        local current = addon.GetActiveProfileKey and addon.GetActiveProfileKey() or nil
                        local list = addon.ListProfiles and addon.ListProfiles() or {}
                        for _, kk in ipairs(list) do
                            if kk ~= current then k = kk; addon._profileDeleteKey = kk; break end
                        end
                    end
                    if not k or k == "" then return end
                    if addon.ShowDeleteProfilePopup then
                        addon.ShowDeleteProfilePopup(k)
                        return
                    end
                    if addon.DeleteProfile and addon.DeleteProfile(k) then
                        addon._profileDeleteKey = nil
                        if addon.OnActiveProfileChanged then addon.OnActiveProfileChanged() end
                    end
                end, { dbKey = "_profiles_delete_btn" })

                opts[#opts + 1] = ModuleReloadPrompt({ hintText = L["PROFILE_RELOAD_HINT"] })

                -- Section B: Per-spec switch + spec dropdowns
                opts[#opts + 1] = Section(L["AXIS_SPEC_PROFILES"])

                opts[#opts + 1] = {
                    type = "toggle",
                    name = L["AXIS_ENABLE"],
                    desc = L["AXIS_PICK_DIFFERENT_PROFILES_PER_SPEC"],
                    dbKey = "_profiles_usePerSpec",
                    refreshIds = {
                        "_profiles_current",
                        "_profiles_spec_1",
                        "_profiles_spec_2",
                        "_profiles_spec_3",
                        "_profiles_spec_4",
                    },
                    disabled = function()
                        local useGlobal = addon.GetProfileModeState and select(1, addon.GetProfileModeState())
                        return useGlobal == true
                    end,
                    get = function()
                        if not addon.GetProfileModeState then return false end
                        local useGlobal, usePerSpec = addon.GetProfileModeState()
                        return (useGlobal ~= true) and (usePerSpec == true)
                    end,
                    set = function(v)
                        if v and addon.GetActiveProfileKey and addon.SetPerSpecProfileKey then
                            local baseKey = addon.GetActiveProfileKey()
                            if baseKey then
                                local currentSpec = PlayerUtil and PlayerUtil.GetCurrentSpecID and PlayerUtil.GetCurrentSpecID() or nil
                                for si = 1, 4 do
                                    if si == currentSpec then
                                        addon.SetPerSpecProfileKey(si, baseKey)
                                    else
                                        local _, _, _, perSpec = addon.GetProfileModeState()
                                        if not (type(perSpec) == "table" and type(perSpec[si]) == "string" and perSpec[si] ~= "") then
                                            addon.SetPerSpecProfileKey(si, baseKey)
                                        end
                                    end
                                end
                            end
                        end
                        if addon.SetUsePerSpecProfiles then addon.SetUsePerSpecProfiles(v) end
                        if addon.OnActiveProfileChangedDeferred then addon.OnActiveProfileChangedDeferred() end
                    end,
                }

                local function specProfileOptions()
                    local list = addon.ListProfiles and addon.ListProfiles() or {}
                    local out = {}
                    for _, k in ipairs(list) do
                        if k ~= "Default" then
                            out[#out + 1] = { k, k }
                        end
                    end
                    return out
                end

                for specIndex = 1, 4 do
                    local function specNameFn()
                        if addon.ListSpecOptions then
                            local specOpts = addon.ListSpecOptions()
                            for _, pair in ipairs(specOpts) do
                                if tonumber(pair[1]) == specIndex then
                                    return pair[2]
                                end
                            end
                        end
                        return ("Spec %d"):format(specIndex)
                    end
                    local function specHiddenFn()
                        local numSpecs = _G.GetNumSpecializations and _G.GetNumSpecializations() or 0
                        if numSpecs < 1 then return false end
                        return specIndex > numSpecs
                    end
                    opts[#opts + 1] = {
                        type = "dropdown",
                        name = specNameFn,
                        dbKey = "_profiles_spec_" .. tostring(specIndex),
                        options = specProfileOptions,
                        hidden = specHiddenFn,
                        disabled = function()
                            if not addon.GetProfileModeState then return true end
                            local useGlobal, usePerSpec = addon.GetProfileModeState()
                            return (useGlobal == true) or (usePerSpec ~= true)
                        end,
                        get = function()
                            if not addon.GetProfileModeState then
                                return (addon.GetActiveProfileKey and addon.GetActiveProfileKey())
                            end
                            local useGlobal, usePerSpec, _, perSpec = addon.GetProfileModeState()
                            if useGlobal ~= true and usePerSpec == true then
                                if type(perSpec) == "table" and type(perSpec[specIndex]) == "string" and perSpec[specIndex] ~= "" then
                                    return perSpec[specIndex]
                                end
                            end
                            return (addon.GetActiveProfileKey and addon.GetActiveProfileKey())
                        end,
                        set = function(v)
                            if addon.SetPerSpecProfileKey then addon.SetPerSpecProfileKey(specIndex, v) end
                            if addon.OnActiveProfileChangedDeferred then addon.OnActiveProfileChangedDeferred() end
                        end,
                    }
                end

                opts[#opts + 1] = ModuleReloadPrompt({ hintText = L["PROFILE_RELOAD_HINT"] })

                -- Section C: Sharing (export / import)
                opts[#opts + 1] = Section(L["AXIS_SHARING"])

                opts[#opts + 1] = {
                    type = "dropdown",
                    name = L["AXIS_EXPORT_PROFILE"],
                    desc = L["AXIS_SELECT_A_PROFILE_EXPORT"],
                    dbKey = "_profiles_export_select",
                    options = function()
                        local list = addon.ListProfiles and addon.ListProfiles() or {}
                        local out = {}
                        for _, k in ipairs(list) do
                            if k ~= "Default" then out[#out + 1] = { k, k } end
                        end
                        return out
                    end,
                    get = function()
                        local list = addon.ListProfiles and addon.ListProfiles() or {}
                        if addon._profileExportKey then
                            for _, k in ipairs(list) do
                                if k == addon._profileExportKey and k ~= "Default" then return k end
                            end
                        end
                        local current = addon.GetActiveProfileKey and addon.GetActiveProfileKey() or nil
                        if current and current ~= "Default" then
                            addon._profileExportKey = current
                            return current
                        end
                        for _, k in ipairs(list) do
                            if k ~= "Default" then addon._profileExportKey = k; return k end
                        end
                        return ""
                    end,
                    set = function(v)
                        addon._profileExportKey = v
                        if addon.OptionsPanel_Refresh then addon.OptionsPanel_Refresh() end
                    end,
                }

                opts[#opts + 1] = {
                    type = "editbox",
                    labelText = L["AXIS_EXPORT_STRING"],
                    dbKey = "_profiles_export_box",
                    height = 60,
                    readonly = true,
                    storeRef = "_profileExportEditBox",
                    get = function()
                        local key = addon._profileExportKey
                        if not key or key == "" then
                            local current = addon.GetActiveProfileKey and addon.GetActiveProfileKey() or nil
                            if current and current ~= "Default" then
                                key = current
                                addon._profileExportKey = key
                            else
                                local list = addon.ListProfiles and addon.ListProfiles() or {}
                                for _, k in ipairs(list) do
                                    if k ~= "Default" then key = k; addon._profileExportKey = k; break end
                                end
                            end
                        end
                        if not key or key == "" then return "" end
                        return (addon.ExportProfile and addon.ExportProfile(key)) or ""
                    end,
                }

                opts[#opts + 1] = {
                    type = "editbox",
                    labelText = L["AXIS_IMPORT_STRING"],
                    dbKey = "_profiles_import_box",
                    height = 60,
                    readonly = false,
                    get = function() return addon._profileImportString or "" end,
                    set = function(v)
                        addon._profileImportString = v
                        local valid = addon.ValidateProfileString and addon.ValidateProfileString(v) or false
                        addon._profileImportValid = valid
                    end,
                }

                opts[#opts + 1] = Button(L["AXIS_IMPORT_PROFILE"], nil, function()
                    local str = addon._profileImportString
                    if not str or str == "" then
                        if addon.HSPrint then addon.HSPrint("No import string provided.") end
                        return
                    end
                    if not (addon.ValidateProfileString and addon.ValidateProfileString(str)) then
                        if addon.HSPrint then addon.HSPrint("Invalid profile string.") end
                        return
                    end
                    addon._profileImportSourceString = str
                    if StaticPopup_Show then
                        StaticPopup_Show("HORIZONSUITE_IMPORT_PROFILE")
                    end
                end, { dbKey = "_profiles_import_btn" })

                return opts
        end,
    },
}

for i = #categories, 1, -1 do
    table.insert(addon.OptionCategories, 1, categories[i])
end
