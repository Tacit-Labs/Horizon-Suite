--[[
    Horizon Suite - Focus - Options categories
    Self-registers into addon.OptionCategories after OptionsData.lua runs.
]]
local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L = addon.L
local function getDB(k, d) return addon.GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end
local OptionsData_NotifyMainAddon      = addon.OptionsData_NotifyMainAddon
local FONT_USE_GLOBAL                  = addon.FONT_USE_GLOBAL
local GetPerElementFontDropdownOptions = addon.GetPerElementFontDropdownOptions
local DisplayPerElementFont            = addon.DisplayPerElementFont
local OUTLINE_OPTIONS                  = addon.OUTLINE_OPTIONS
local Section                          = addon.Section
local Button                           = addon.Button
local Toggle                           = addon.Toggle
local Slider                           = addon.Slider
local Color                            = addon.Color
local D   = addon.FOCUS_DEFAULTS
local LIM = addon.FOCUS_LIMITS
local function clamp(v, key) local lim = LIM[key]; return math.max(lim.min, math.min(lim.max, v)) end

-- Returns dropdown options for a given combo key, delegating to FocusClickConfig.
-- Custom profile uses the full action list on every combo; presets use curated COMBO_OPTIONS.
-- @param comboKey string e.g. "left", "shiftLeft"
-- @return table { {label, value}, ... }
local function GetComboActionOptions(comboKey)
    local cfg = addon.focus and addon.focus.clickConfig
    if not cfg then return {} end
    if getDB("focusClickProfile", D.focusClickProfile) == "custom" and cfg.GetAllComboActionOptions then
        return cfg.GetAllComboActionOptions()
    end
    if cfg.GetComboOptions then
        return cfg.GetComboOptions(comboKey)
    end
    return {}
end

-- Returns dropdown options for the shared quest/appearance icon click action.
-- @return table { {label, value}, ... }
local function GetIconClickActionOptions()
    local cfg = addon.focus and addon.focus.clickConfig
    if cfg and cfg.GetIconActionOptions then
        return cfg.GetIconActionOptions()
    end
    return {}
end

-- Resolved action for options UI: per-combo DB when Custom (defaults match Blizzard+); else built-in preset.
-- @param comboKey string
-- @param dbKey string SavedVariables key e.g. focusClick_left
-- @return string
local function GetEffectiveFocusClickAction(comboKey, dbKey)
    local prof = getDB("focusClickProfile", D.focusClickProfile)
    local cfg = addon.focus and addon.focus.clickConfig
    local normalizeAction = cfg and cfg.NormalizeAction
    local profiles = cfg and cfg.PROFILES
    local blizz = profiles and profiles.blizzardDefault
    local customDefault = (blizz and blizz[comboKey]) or "none"

    if prof == "custom" then
        local raw = getDB(dbKey, customDefault)
        return normalizeAction and normalizeAction(raw) or raw
    end
    if not profiles then return customDefault end
    local t = profiles[prof] or profiles.blizzardDefault
    local v = t and t[comboKey]
    if normalizeAction then
        v = normalizeAction(v)
    end
    if type(v) == "string" and v ~= "" then return v end
    return (t and t[comboKey]) or customDefault
end

-- Resolved icon click action for options UI: fixed default for presets, DB-backed for Custom.
-- @return string
local function GetEffectiveFocusIconClickAction()
    local prof = getDB("focusClickProfile", D.focusClickProfile)
    if prof ~= "custom" then
        return "superTrack"
    end
    local cfg = addon.focus and addon.focus.clickConfig
    local normalizeAction = cfg and cfg.NormalizeIconAction
    local raw = getDB("focusIconClickAction", D.focusIconClickAction)
    return normalizeAction and normalizeAction(raw) or raw
end

-- When true, per-combo dropdowns are read-only (preset profile selected).
-- @return boolean
local function FocusClickPresetCombosLocked()
    return getDB("focusClickProfile", D.focusClickProfile) ~= "custom"
end

-- True while Focus locks click profile to Blizzard (Horizon+ / Custom hidden).
-- @return boolean
local function FocusClickProfileChoiceHidden()
    local c = addon.focus and addon.focus.clickConfig
    return c and c.profilesLockedToBlizzard
end

-- Click profile dropdown: all presets listed; when locked, only Blizzard+ is selectable (others show "Coming soon").
-- @return table
local function GetFocusClickProfileDropdownOptions()
    if FocusClickProfileChoiceHidden() then
        local soon = L["FOCUS_COMING_SOON"]
        return {
            { L["FOCUS_PROFILE_BLIZZARD_DEFAULT"],                           "blizzardDefault" },
            { L["FOCUS_PROFILE_HORIZON_PLUS"] .. " — " .. soon, "horizonPlus", true },
            { L["FOCUS_PROFILE_CUSTOM"] .. " — " .. soon, "custom", true },
        }
    end
    return {
        { L["FOCUS_PROFILE_HORIZON_PLUS"],     "horizonPlus" },
        { L["FOCUS_PROFILE_BLIZZARD_DEFAULT"], "blizzardDefault" },
        { L["FOCUS_PROFILE_CUSTOM"],           "custom" },
    }
end

local defaultFontPath = (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"

local function GetFontDropdownOptions()
    if addon.RefreshFontList then addon.RefreshFontList() end
    local list = (addon.GetFontList and addon.GetFontList()) or {}


    local saved = getDB("fontPath", defaultFontPath)
    -- Back-compat: if saved value is a concrete font file path, try to map it
    -- back to the corresponding LSM key so the dropdown can select it.
    if addon.GetFontNameForPath then
        local mapped = addon.GetFontNameForPath(saved)
        if mapped and mapped ~= "" and mapped ~= "Custom" and mapped ~= saved then
            local path = addon.ResolveFontPath and addon.ResolveFontPath(mapped) or nil
            if path and path == saved then
                saved = mapped
            end
        end
    end
    for _, o in ipairs(list) do
        if o[2] == saved then return list end
    end
    local out = {}
    for i = 1, #list do out[i] = list[i] end
    -- If it's not one of our known choices, keep it selectable as "Custom".
    out[#out + 1] = { L["FOCUS_CUSTOM"], saved }
    return out
end

local HIGHLIGHT_OPTIONS = {
    { L["FOCUS_HIGHLIGHT_BAR_LEFT_EDGE"], "bar-left" },
    { L["FOCUS_HIGHLIGHT_BAR_RIGHT_EDGE"], "bar-right" },
    { L["FOCUS_HIGHLIGHT_BAR_TOP_EDGE"], "bar-top" },
    { L["FOCUS_HIGHLIGHT_BAR_BOTTOM_EDGE"], "bar-bottom" },
    { L["FOCUS_HIGHLIGHT_OUTLINE_ONLY"], "outline" },
    { L["FOCUS_HIGHLIGHT_SOFT_GLOW"], "glow" },
    { L["FOCUS_HIGHLIGHT_DUAL_EDGE_BARS"], "bar-both" },
    { L["FOCUS_HIGHLIGHT_PILL_LEFT_ACCENT"], "pill-left" },
    { L["FOCUS_HIGHLIGHT"], "highlight" },
}
local MPLUS_POSITION_OPTIONS = {
    { L["FOCUS_MYTHICPLUS_POSITION_TOP"], "top" },
    { L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"], "bottom" },
}
local MPLUS_FONT_OPTIONS = {
    { "Title Font", "TitleFont" },
    { "Objective Font", "ObjFont" },
    { "Section Font", "SectionFont" },
    { "Detail Font", "DetailFont" },
}
local TEXT_CASE_OPTIONS = {
    { L["FOCUS_TEXT_LOWER_CASE"], "lower" },
    { L["FOCUS_TEXT_UPPER_CASE"], "upper" },
    { L["FOCUS_TEXT_PROPER_CASE"], "proper" },
}

local VALID_HIGHLIGHT_STYLES = {
    ["bar-left"] = true, ["bar-right"] = true, ["bar-top"] = true, ["bar-bottom"] = true,
    ["outline"] = true, ["glow"] = true, ["bar-both"] = true, ["pill-left"] = true, ["highlight"] = true,
}
local function getActiveQuestHighlight()
    local v = addon.NormalizeHighlightStyle(getDB("activeQuestHighlight", D.activeQuestHighlight))
    if not VALID_HIGHLIGHT_STYLES[v] then return D.activeQuestHighlight end
    return v
end

local categories = {
    {
        key = "Layout",
        name = L["DASH_LAYOUT"],
        moduleKey = "focus",
        options = {
            Section(L["VISTA_POSITION_LAYOUT"]),
            { type = "toggle", name = L["FOCUS_LOCK_POSITION"], desc = L["FOCUS_PREVENT_DRAGGING_TRACKER"], dbKey = "lockPosition", get = function() return getDB("lockPosition", D.lockPosition) or getDB("focusDynamicWidth", D.focusDynamicWidth) end, set = function(v) setDB("lockPosition", v) end },
            { type = "toggle", name = L["FOCUS_GROW_UPWARD"], desc = L["FOCUS_ANCHOR_BOTTOM_LIST_GROWS_UPWARD"], dbKey = "growUp", get = function() return getDB("growUp", D.growUp) end, set = function(v) setDB("growUp", v); if addon.focus and addon.focus.layout then addon.focus.layout.scrollOffset = 0; addon.focus.layout.scrollBottomOffset = 0 end; if addon.FullLayout then addon.FullLayout() end end, refreshIds = { "growUpHeaderMode" } },
            { type = "dropdown", name = L["FOCUS_GROW_HEADER"], desc = L["KEEP_HEADER_BOTTOM_TOP_UNTIL_COLLAPSED"], tooltip = L["FOCUS_GROWING_UPWARD_KEEP_HEADER_BOTTOM_TOP"], dbKey = "growUpHeaderMode", options = { { L["FOCUS_HEADER_BOTTOM"], "always" }, { L["FOCUS_HEADER_SLIDES_COLLAPSE"], "collapse" } }, get = function() return getDB("growUpHeaderMode", D.growUpHeaderMode) end, set = function(v) setDB("growUpHeaderMode", v); if addon.FullLayout then addon.FullLayout() end end, visibleWhen = function() return getDB("growUp", D.growUp) end },
            { type = "toggle", name = L["FOCUS_START_COLLAPSED"], desc = L["FOCUS_START_HEADER_SHOWN_UNTIL_YOU_EXPAND"], dbKey = "collapsed", get = function() return getDB("collapsed", D.collapsed) end, set = function(v) setDB("collapsed", v) end },
            Section(L["FOCUS_DIMENSIONS"]),
            { type = "toggle", name = L["FOCUS_DYNAMIC_WIDTH"], desc = L["FOCUS_DYNAMIC_WIDTH_DESC"], dbKey = "focusDynamicWidth", get = function() return getDB("focusDynamicWidth", D.focusDynamicWidth) end, set = function(v) setDB("focusDynamicWidth", v); OptionsData_NotifyMainAddon() end, refreshIds = { "panelWidth", "focusDynamicWidthMax", "lockPosition" } },
            { type = "slider", name = L["FOCUS_PANEL_WIDTH"], desc = L["FOCUS_TRACKER_WIDTH_PIXELS"], dbKey = "panelWidth", min = LIM.panelWidth.min, max = LIM.panelWidth.max, get = function() return getDB("panelWidth", D.panelWidth) end, set = function(v) setDB("panelWidth", clamp(v, "panelWidth")) end, visibleWhen = function() return not getDB("focusDynamicWidth", D.focusDynamicWidth) end },
            { type = "slider", name = L["FOCUS_DYNAMIC_WIDTH_MAX"], desc = L["FOCUS_DYNAMIC_WIDTH_MAX_DESC"], dbKey = "focusDynamicWidthMax", min = LIM.focusDynamicWidthMax.min, max = LIM.focusDynamicWidthMax.max, get = function() return getDB("focusDynamicWidthMax", D.focusDynamicWidthMax) end, set = function(v) setDB("focusDynamicWidthMax", clamp(v, "focusDynamicWidthMax")); OptionsData_NotifyMainAddon() end, visibleWhen = function() return getDB("focusDynamicWidth", D.focusDynamicWidth) end },
            { type = "slider", name = L["FOCUS_MAX_CONTENT_HEIGHT"], desc = L["FOCUS_MAX_HEIGHT_OF_SCROLLABLE_LIST_PIXELS"], dbKey = "maxContentHeight", min = LIM.maxContentHeight.min, max = LIM.maxContentHeight.max, get = function() return getDB("maxContentHeight", D.maxContentHeight) end, set = function(v) setDB("maxContentHeight", clamp(v, "maxContentHeight")) end },
            { type = "toggle", name = L["FOCUS_STATIC_BACKGROUND"], desc = L["FOCUS_STATIC_BACKGROUND_DESC"], dbKey = "staticBackgroundEnabled", get = function() return getDB("staticBackgroundEnabled", D.staticBackgroundEnabled) end, set = function(v) setDB("staticBackgroundEnabled", v); if addon.FullLayout then addon.FullLayout() end end, refreshIds = { "staticPanelHeight" } },
            { type = "slider", name = L["FOCUS_STATIC_PANEL_HEIGHT"], desc = L["FOCUS_STATIC_PANEL_HEIGHT_DESC"], dbKey = "staticPanelHeight", min = LIM.staticPanelHeight.min, max = LIM.staticPanelHeight.max, get = function() return clamp(tonumber(getDB("staticPanelHeight", D.staticPanelHeight)) or D.staticPanelHeight, "staticPanelHeight") end, set = function(v) setDB("staticPanelHeight", clamp(v, "staticPanelHeight")); if addon.FullLayout then addon.FullLayout() end end, visibleWhen = function() return getDB("staticBackgroundEnabled", D.staticBackgroundEnabled) end },
            Section(L["FOCUS_SPACING"]),
            { type = "dropdown", name = L["FOCUS_SPACING_PRESET"], dbKey = "compactMode",
                options = {
                    { L["AXIS_DEFAULT"], "default" },
                    { L["FOCUS_COMPACT_VERSION"], "compact" },
                    { L["FOCUS_SPACED_VERSION"], "spaced" },
                    { L["FOCUS_CUSTOM"], "custom" },
                },
                get = function()
                    local v = getDB("compactMode", "default")
                    if v == true then return "compact" end
                    if v == false then return "default" end
                    return v or "default"
                end,
                set = function(v)
                    setDB("compactMode", v)
                    if addon.FullLayout then addon.FullLayout() end
                end,
                refreshIds = { "compactMode", "titleSpacing", "objSpacing", "titleToContentSpacing", "sectionSpacing", "sectionToEntryGap", "headerToContentGap" }
            },
            { type = "slider", name = L["ENTRY_SPACING"], desc = L["FOCUS_VERTICAL_GAP_BETWEEN_QUEST_ENTRIES"], dbKey = "titleSpacing", min = LIM.customTitleSpacing.min, max = LIM.customTitleSpacing.max,
                get = function()
                    local mode = addon.GetSpacingMode()
                    if mode == "custom" then
                        return math.max(LIM.customTitleSpacing.min, math.min(LIM.customTitleSpacing.max, tonumber(getDB("customTitleSpacing", D.customTitleSpacing)) or D.customTitleSpacing))
                    end
                    local p = addon.SPACING_PRESETS and addon.SPACING_PRESETS[mode]
                    return p and p.titleSpacing or D.customTitleSpacing
                end,
                set = function(v)
                    setDB("customTitleSpacing", clamp(v, "customTitleSpacing"))
                    if addon.FullLayout then addon.FullLayout() end
                end,
                disabled = function() return addon.GetSpacingMode() ~= "custom" end,
                refreshIds = { "compactMode", "titleSpacing", "objSpacing", "titleToContentSpacing", "sectionSpacing", "sectionToEntryGap", "headerToContentGap" }
            },
            { type = "slider", name = L["FOCUS_TITLE_CONTENT"], desc = L["FOCUS_VERTICAL_GAP_BETWEEN_QUEST_TITLE_OBJECTIVES"], dbKey = "titleToContentSpacing", min = LIM.customTitleToContentSpacing.min, max = LIM.customTitleToContentSpacing.max,
                get = function()
                    local mode = addon.GetSpacingMode()
                    if mode == "custom" then
                        return math.max(LIM.customTitleToContentSpacing.min, math.min(LIM.customTitleToContentSpacing.max, tonumber(getDB("customTitleToContentSpacing", D.customTitleToContentSpacing)) or D.customTitleToContentSpacing))
                    end
                    local p = addon.SPACING_PRESETS and addon.SPACING_PRESETS[mode]
                    return p and p.titleToContentSpacing or D.customTitleToContentSpacing
                end,
                set = function(v) setDB("customTitleToContentSpacing", clamp(v, "customTitleToContentSpacing")); if addon.FullLayout then addon.FullLayout() end end,
                disabled = function() return addon.GetSpacingMode() ~= "custom" end,
                refreshIds = { "compactMode", "titleSpacing", "objSpacing", "titleToContentSpacing", "sectionSpacing", "sectionToEntryGap", "headerToContentGap" }
            },
            { type = "slider", name = L["FOCUS_BEFORE_SECTION_HEADER"], desc = L["FOCUS_GAP_BETWEEN_LAST_ENTRY_OF_A"], dbKey = "sectionSpacing", min = LIM.customSectionSpacing.min, max = LIM.customSectionSpacing.max,
                get = function()
                    local mode = addon.GetSpacingMode()
                    if mode == "custom" then
                        return math.max(LIM.customSectionSpacing.min, math.min(LIM.customSectionSpacing.max, tonumber(getDB("customSectionSpacing", D.customSectionSpacing)) or D.customSectionSpacing))
                    end
                    local p = addon.SPACING_PRESETS and addon.SPACING_PRESETS[mode]
                    return p and p.sectionSpacing or D.customSectionSpacing
                end,
                set = function(v) setDB("customSectionSpacing", clamp(v, "customSectionSpacing")); if addon.FullLayout then addon.FullLayout() end end,
                disabled = function() return addon.GetSpacingMode() ~= "custom" end,
                refreshIds = { "compactMode", "titleSpacing", "objSpacing", "titleToContentSpacing", "sectionSpacing", "sectionToEntryGap", "headerToContentGap" }
            },
            { type = "slider", name = L["FOCUS_AFTER_SECTION_HEADER"], desc = L["FOCUS_GAP_BETWEEN_CATEGORY_LABEL_FIRST_QUEST"], dbKey = "sectionToEntryGap", min = LIM.customSectionToEntryGap.min, max = LIM.customSectionToEntryGap.max,
                get = function()
                    local mode = addon.GetSpacingMode()
                    if mode == "custom" then
                        return math.max(LIM.customSectionToEntryGap.min, math.min(LIM.customSectionToEntryGap.max, tonumber(getDB("customSectionToEntryGap", D.customSectionToEntryGap)) or D.customSectionToEntryGap))
                    end
                    local p = addon.SPACING_PRESETS and addon.SPACING_PRESETS[mode]
                    return p and p.sectionToEntryGap or D.customSectionToEntryGap
                end,
                set = function(v) setDB("customSectionToEntryGap", clamp(v, "customSectionToEntryGap")); if addon.FullLayout then addon.FullLayout() end end,
                disabled = function() return addon.GetSpacingMode() ~= "custom" end,
                refreshIds = { "compactMode", "titleSpacing", "objSpacing", "titleToContentSpacing", "sectionSpacing", "sectionToEntryGap", "headerToContentGap" }
            },
            { type = "slider", name = L["OBJECTIVE_SPACING"], desc = L["FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVE_LINES_WITHIN"], dbKey = "objSpacing", min = LIM.customObjSpacing.min, max = LIM.customObjSpacing.max,
                get = function()
                    local mode = addon.GetSpacingMode()
                    if mode == "custom" then
                        return math.max(LIM.customObjSpacing.min, math.min(LIM.customObjSpacing.max, tonumber(getDB("customObjSpacing", D.customObjSpacing)) or D.customObjSpacing))
                    end
                    local p = addon.SPACING_PRESETS and addon.SPACING_PRESETS[mode]
                    return p and p.objSpacing or D.customObjSpacing
                end,
                set = function(v) setDB("customObjSpacing", clamp(v, "customObjSpacing")); if addon.FullLayout then addon.FullLayout() end end,
                disabled = function() return addon.GetSpacingMode() ~= "custom" end,
                refreshIds = { "compactMode", "titleSpacing", "objSpacing", "titleToContentSpacing", "sectionSpacing", "sectionToEntryGap", "headerToContentGap" }
            },
            { type = "slider", name = L["FOCUS_BELOW_HEADER"], desc = L["FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVES_BAR_QUES"], dbKey = "headerToContentGap", min = LIM.customHeaderToContentGap.min, max = LIM.customHeaderToContentGap.max,
                get = function()
                    local mode = addon.GetSpacingMode()
                    if mode == "custom" then
                        return math.max(LIM.customHeaderToContentGap.min, math.min(LIM.customHeaderToContentGap.max, tonumber(getDB("customHeaderToContentGap", D.customHeaderToContentGap)) or D.customHeaderToContentGap))
                    end
                    local p = addon.SPACING_PRESETS and addon.SPACING_PRESETS[mode]
                    return p and p.headerToContentGap or D.customHeaderToContentGap
                end,
                set = function(v) setDB("customHeaderToContentGap", clamp(v, "customHeaderToContentGap")); if addon.FullLayout then addon.FullLayout() end end,
                disabled = function() return addon.GetSpacingMode() ~= "custom" end,
                refreshIds = { "compactMode", "titleSpacing", "objSpacing", "titleToContentSpacing", "sectionSpacing", "sectionToEntryGap", "headerToContentGap" }
            },
        },
    },
    {
        key = "Appearance",
        name = L["DASH_APPEARANCE"],
        desc = L["FOCUS_APPEARANCE_TAB_DESC"],
        moduleKey = "focus",
        options = {
            Section(L["DASH_FRAME"]),
            { type = "slider", name = L["FOCUS_BACKDROP_OPACITY"], desc = L["PANEL_BACKGROUND_OPACITY"], dbKey = "backdropOpacity", min = LIM.backdropOpacity.min, max = LIM.backdropOpacity.max, get = function() local v = tonumber(getDB("backdropOpacity", D.backdropOpacity)) or D.backdropOpacity; if v <= 1 and v > 0 then return math.floor(v * 100 + 0.5) end; return math.max(LIM.backdropOpacity.min, math.min(LIM.backdropOpacity.max, v)) end, set = function(v) setDB("backdropOpacity", clamp(v, "backdropOpacity") / 100) end },
            { type = "color", name = L["VISTA_BACKDROP_COLOUR"], desc = L["VISTA_PANEL_BACKGROUND_COLOUR"], dbKey = "backdropColor", get = function() return getDB("backdropColorR", D.backdropColorR), getDB("backdropColorG", D.backdropColorG), getDB("backdropColorB", D.backdropColorB) end, set = function(r, g, b) setDB("backdropColorR", r); setDB("backdropColorG", g); setDB("backdropColorB", b) end },
            Toggle(L["FOCUS_BORDER"], L["FOCUS_BORDER_AROUND_TRACKER"], "showBorder", D.showBorder),
            Toggle(L["SCROLL_INDICATOR"], L["HINT_LIST_SCROLLABLE"], "showScrollIndicator", D.showScrollIndicator, { refreshIds = { "scrollIndicatorStyle" } }),
            { type = "dropdown", name = L["FOCUS_SCROLL_INDICATOR_STYLE"], desc = L["FOCUS_CHOOSE_BETWEEN_A_FADE_GRADIENT_A"], dbKey = "scrollIndicatorStyle", options = { { L["FOCUS_FADE"], "fade" }, { L["FOCUS_ARROW"], "arrow" } }, get = function() return getDB("scrollIndicatorStyle", D.scrollIndicatorStyle) end, set = function(v) setDB("scrollIndicatorStyle", v) end, visibleWhen = function() return getDB("showScrollIndicator", D.showScrollIndicator) end },
            Section(L["VISIBILITY_FADING"]),
            { type = "dropdown", name = L["FOCUS_COMBAT_VISIBILITY"], desc = L["FOCUS_TRACKER_BEHAVES_COMBAT_FADE_REDUC"], dbKey = "combatVisibility", options = { { L["FOCUS_SHOW"], "show" }, { L["FOCUS_FADE"], "fade" }, { L["FOCUS_HIDE"], "hide" } }, get = function() return addon.GetCombatVisibility() end, set = function(v) setDB("combatVisibility", v); if addon.FullLayout then addon.FullLayout() end end, refreshIds = { "combatFadeOpacity" } },
            { type = "slider", name = L["FOCUS_COMBAT_FADE_OPACITY"], desc = L["FOCUS_VISIBLE_TRACKER_FADED_COMBAT"], dbKey = "combatFadeOpacity", min = LIM.combatFadeOpacity.min, max = LIM.combatFadeOpacity.max, get = function() return math.max(LIM.combatFadeOpacity.min, math.min(LIM.combatFadeOpacity.max, tonumber(getDB("combatFadeOpacity", D.combatFadeOpacity)) or D.combatFadeOpacity)) end, set = function(v) setDB("combatFadeOpacity", clamp(v, "combatFadeOpacity")); if addon.FullLayout then addon.FullLayout() end end, visibleWhen = function() return addon.GetCombatVisibility() == "fade" end },
            { type = "toggle", name = L["MOUSEOVER"], desc = L["FADE_HOVERING"], dbKey = "showOnMouseoverOnly", get = function() return getDB("showOnMouseoverOnly", D.showOnMouseoverOnly) end, set = function(v) setDB("showOnMouseoverOnly", v); if addon.FullLayout then addon.FullLayout() end end, refreshIds = { "fadeOnMouseoverOpacity" } },
            { type = "slider", name = L["FOCUS_FADED_OPACITY"], desc = L["FOCUS_VISIBLE_TRACKER_FADED_INVISIBLE"], dbKey = "fadeOnMouseoverOpacity", min = LIM.fadeOnMouseoverOpacity.min, max = LIM.fadeOnMouseoverOpacity.max, get = function() return math.max(LIM.fadeOnMouseoverOpacity.min, math.min(LIM.fadeOnMouseoverOpacity.max, tonumber(getDB("fadeOnMouseoverOpacity", D.fadeOnMouseoverOpacity)) or D.fadeOnMouseoverOpacity)) end, set = function(v) setDB("fadeOnMouseoverOpacity", clamp(v, "fadeOnMouseoverOpacity")); if addon.FullLayout then addon.FullLayout() end end, visibleWhen = function() return getDB("showOnMouseoverOnly", D.showOnMouseoverOnly) end },
            Section(L["FOCUS_HEADER"]),
            Toggle(L["MINIMAL_MODE"], L["FOCUS_HIDE_HEADER_A_PURE_TEXT_LIST"], "hideObjectivesHeader", D.hideObjectivesHeader, { refreshIds = { "showQuestCount", "headerCountMode", "showHeaderDivider", "headerDividerColor", "headerColor", "headerHeight", "hideOptionsButton" } }),
            Toggle(L["QUEST_COUNT"], L["FOCUS_QUEST_COUNT_HEADER"], "showQuestCount", D.showQuestCount, { refreshIds = { "headerCountMode" }, visibleWhen = function() return not getDB("hideObjectivesHeader", D.hideObjectivesHeader) end }),
            { type = "dropdown", name = L["FOCUS_HEADER_COUNT_FORMAT"], desc = L["TRACKED_VS_LOG_COUNT"], dbKey = "headerCountMode", options = { { L["FOCUS_TRACKED_LOG"], "trackedLog" }, { L["FOCUS_LOG_MAX_SLOTS"], "logMax" } }, get = function() return getDB("headerCountMode", D.headerCountMode) end, set = function(v) setDB("headerCountMode", v) end, tooltip = L["TRACKED_LOG_LOG_MAX_TRACKED_EXCLUDES"], visibleWhen = function() return not getDB("hideObjectivesHeader", D.hideObjectivesHeader) and getDB("showQuestCount", D.showQuestCount) end },
            Toggle(L["HEADER_DIVIDER"], L["FOCUS_LINE_BELOW_HEADER"], "showHeaderDivider", D.showHeaderDivider, { refreshIds = { "headerDividerColor" }, visibleWhen = function() return not getDB("hideObjectivesHeader", D.hideObjectivesHeader) end }),
            Color(L["FOCUS_HEADER_DIVIDER_COLOUR"], L["FOCUS_COLOUR_OF_LINE_BELOW_HEADER"], "headerDividerColor", addon.DIVIDER_COLOR, { hasAlpha = true, visibleWhen = function() return not getDB("hideObjectivesHeader", D.hideObjectivesHeader) and getDB("showHeaderDivider", D.showHeaderDivider) end }),
            Color(L["FOCUS_HEADER_COLOUR"], L["FOCUS_COLOUR_OF_OBJECTIVES_HEADER_TEXT"], "headerColor", addon.HEADER_COLOR, { visibleWhen = function() return not getDB("hideObjectivesHeader", D.hideObjectivesHeader) end }),
            { type = "slider", name = L["FOCUS_HEADER_HEIGHT"], desc = L["FOCUS_HEIGHT_OF_HEADER_BAR_PIXELS"], dbKey = "headerHeight", min = LIM.headerHeight.min, max = LIM.headerHeight.max, get = function() return math.max(LIM.headerHeight.min, math.min(LIM.headerHeight.max, tonumber(getDB("headerHeight", addon.HEADER_HEIGHT)) or addon.HEADER_HEIGHT)) end, set = function(v) setDB("headerHeight", clamp(v, "headerHeight")) end, visibleWhen = function() return not getDB("hideObjectivesHeader", D.hideObjectivesHeader) end },
            { type = "toggle", name = L["FOCUS_OPTIONS_BUTTON"], desc = L["FOCUS_OPTIONS_BUTTON_TRACKER_HEADER"], dbKey = "hideOptionsButton", get = function() return not getDB("hideOptionsButton", D.hideOptionsButton) end, set = function(v) setDB("hideOptionsButton", not v) end, visibleWhen = function() return not getDB("hideObjectivesHeader", D.hideObjectivesHeader) end },
            Section(L["FOCUS_SECTIONS_STRUCTURE"]),
            Toggle(L["SECTION_HEADERS"], L["FOCUS_CATEGORY_LABELS_ABOVE_GROUP"], "showSectionHeaders", D.showSectionHeaders),
            Toggle(L["SECTION_DIVIDERS"], L["A_VISUAL_DIVIDER_LINE_BETWEEN_FOCUS"], "showSectionDividers", D.showSectionDividers, { refreshIds = { "sectionDividerColor" } }),
            Color(L["SECTION_DIVIDER_COLOUR"], L["COLOUR_OF_DIVIDER_LINES_BETWEEN_SECTIONS"], "sectionDividerColor", { 0.3, 0.3, 0.35, 0.4 }, { hasAlpha = true, visibleWhen = function() return getDB("showSectionDividers", D.showSectionDividers) end }),
            Toggle(L["SECTIONS_COLLAPSED"], L["KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED"], "showSectionHeadersWhenCollapsed", D.showSectionHeadersWhenCollapsed, { tooltip = L["FOCUS_CLICK_A_SECTION_HEADER_EXPAND_CATEGORY"] }),
            Toggle(L["ZONE_LABELS"], L["FOCUS_ZONE_NAME_UNDER_QUEST_TITLE"], "showZoneLabels", D.showZoneLabels),
            Section(L["FOCUS_ENTRY_DETAILS"]),
            Toggle(L["ENTRY_NUMBERS"], L["FOCUS_PREFIX_QUEST_TITLES_WITHIN_CATEGORY"], "showCategoryEntryNumbers", D.showCategoryEntryNumbers),
            { type = "dropdown", name = L["FOCUS_OBJECTIVE_PREFIX"], desc = L["FOCUS_OBJECTIVE_PREFIX_DESC"], dbKey = "objectivePrefixStyle", preserveOrder = true, options = { { L["FOCUS_OUTLINE_NONE"], "none" }, { L["FOCUS_NUMBERS"], "numbers" }, { L["FOCUS_HYPHENS"], "hyphens" }, { L["FOCUS_BULLET_POINTS"], "bulletPoints" } }, get = function() return getDB("objectivePrefixStyle", D.objectivePrefixStyle) end, set = function(v) setDB("objectivePrefixStyle", v); OptionsData_NotifyMainAddon() end },
            Toggle(L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS"], L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS_DESC"], "objectiveProgressNumberColors", D.objectiveProgressNumberColors),
            Toggle(L["COMPLETED_COUNT"], L["FOCUS_X_Y_PROGRESS_QUEST_TITLE"], "showCompletedCount", D.showCompletedCount),
            { type = "dropdown", name = L["FOCUS_COMPLETED_OBJECTIVES"], desc = L["DISPLAY_COMPLETED_OBJECTIVES"], tooltip = L["FOCUS_MULTI_OBJECTIVE_QUESTS_DISPLAY_OBJECTIVES"], dbKey = "questCompletedObjectiveDisplay", options = { { L["FOCUS_ALL"], "off" }, { L["FOCUS_FADE_COMPLETED"], "fade" }, { L["FOCUS_HIDE_COMPLETED"], "hide" } }, get = function() return getDB("questCompletedObjectiveDisplay", D.questCompletedObjectiveDisplay) end, set = function(v) setDB("questCompletedObjectiveDisplay", v) end },
            Toggle(L["FOCUS_CHECKMARK_COMPLETED"], L["CHECKMARK_COMPLETED_OBJECTIVES"], "useTickForCompletedObjectives", D.useTickForCompletedObjectives, { tooltip = L["FOCUS_COMPLETED_CHECKMARK"] }),
            Toggle(L["QUEST_LEVEL"], L["FOCUS_QUEST_LEVEL_NEXT_TITLE"], "showQuestLevel", D.showQuestLevel),
            Toggle(L["QUEST_TYPE_ICONS"], L["PRESENCE_QUEST_TYPE_ICON_FOCUS_TRACKER_QUEST"], "showQuestTypeIcons", D.showQuestTypeIcons),
            { type = "slider", name = L["FOCUS_QUEST_TYPE_ICON_SIZE"], desc = L["FOCUS_QUEST_TYPE_ICON_SIZE_DESC"], dbKey = "focusIconSize", min = LIM.focusIconSize.min, max = LIM.focusIconSize.max, get = function() return getDB("focusIconSize", D.focusIconSize) end, set = function(v) setDB("focusIconSize", clamp(v, "focusIconSize")) end, visibleWhen = function() return getDB("showQuestTypeIcons", D.showQuestTypeIcons) end },
            Toggle(L["FOCUS_AUTO_TRACK_ICON"], L["ICON_NEXT_AUTO_TRACKED_ZONE_ENTRIES"], "showInZoneSuffix", D.showInZoneSuffix, { tooltip = L["WORLD_QUESTS_WEEKLIES_YOUR_QUEST_LOG"], refreshIds = { "autoTrackIcon" } }),
            { type = "dropdown", name = L["FOCUS_AUTO_TRACK_ICON"], desc = L["FOCUS_CHOOSE_WHICH_ICON_DISPLAY_NEXT_AUTO"], dbKey = "autoTrackIcon", options = addon.GetRadarIconOptions and addon.GetRadarIconOptions() or {}, get = function() return getDB("autoTrackIcon", D.autoTrackIcon) end, set = function(v) setDB("autoTrackIcon", v) end, visibleWhen = function() return getDB("showInZoneSuffix", D.showInZoneSuffix) end },
            { type = "dropdown", name = L["FOCUS_ACTIVE_QUEST_HIGHLIGHT"], desc = L["FOCUS_FOCUSED_QUEST_HIGHLIGHTED"], dbKey = "activeQuestHighlight", options = HIGHLIGHT_OPTIONS, get = getActiveQuestHighlight, set = function(v) setDB("activeQuestHighlight", v) end },
            { type = "toggle", name = L["QUEST_ITEM_BUTTONS"], desc = L["FOCUS_USABLE_QUEST_ITEM_BUTTON_NEXT_QUEST"], dbKey = "showQuestItemButtons", get = function() return getDB("showQuestItemButtons", D.showQuestItemButtons) end, set = function(v) setDB("showQuestItemButtons", v) end },
            { type = "toggle", name = L["FOCUS_TOOLTIPS_HOVER"], desc = L["FOCUS_TOOLTIPS_HOVERING_TRACKER_ENTRIES_ITE"], dbKey = "focusShowTooltipOnHover", get = function() return getDB("focusShowTooltipOnHover", D.focusShowTooltipOnHover) end, set = function(v) setDB("focusShowTooltipOnHover", v) end },
            { type = "toggle", name = L["FOCUS_WOWHEAD_LINK_TOOLTIPS"], desc = L["FOCUS_A_TOOLTIP_SHOWN_ADD_A_LINK"], dbKey = "focusShowWoWheadLink", get = function() return getDB("focusShowWoWheadLink", D.focusShowWoWheadLink) end, set = function(v) setDB("focusShowWoWheadLink", v) end },
            Section(L["FOCUS_PROGRESS_TIMERS"]),
            { type = "toggle", name = L["SCENARIO_PROGRESS_BAR"], desc = L["FOCUS_BAR_UNDER_NUMERIC_OBJECTIVES"], dbKey = "showProgressBarScenarios", tooltip = L["ENTRIES_A_SINGLE_NUMERIC_OBJECTIVE_WHERE"], get = function() return getDB("showProgressBarScenarios", D.showProgressBarScenarios) end, set = function(v)
                setDB("showProgressBarScenarios", v)
                if C_Timer and C_Timer.After and addon.OptionsPanel_Refresh then
                    C_Timer.After(0.2, addon.OptionsPanel_Refresh)
                elseif addon.OptionsPanel_Refresh then
                    addon.OptionsPanel_Refresh()
                end
            end, refreshIds = { "progressBarUseCategoryColor", "progressBarTypeFilter", "progressBarTexture" } },
            { type = "toggle", name = L["QUEST_PROGRESS_BAR"], desc = L["FOCUS_BAR_UNDER_NUMERIC_OBJECTIVES"], dbKey = "showProgressBarQuests", tooltip = L["ENTRIES_A_SINGLE_NUMERIC_OBJECTIVE_WHERE"], get = function() return getDB("showProgressBarQuests", D.showProgressBarQuests) end, set = function(v)
                setDB("showProgressBarQuests", v)
                if C_Timer and C_Timer.After and addon.OptionsPanel_Refresh then
                    C_Timer.After(0.2, addon.OptionsPanel_Refresh)
                elseif addon.OptionsPanel_Refresh then
                    addon.OptionsPanel_Refresh()
                end
            end, refreshIds = { "progressBarUseCategoryColor", "progressBarTypeFilter", "progressBarTexture" } },
            { type = "toggle", name = L["FOCUS_CATEGORY_COLOUR_BAR"], desc = L["MATCH_BAR_QUEST_CATEGORY_COLOUR"], dbKey = "progressBarUseCategoryColor", get = function() return getDB("progressBarUseCategoryColor", D.progressBarUseCategoryColor) end, set = function(v) setDB("progressBarUseCategoryColor", v) end, visibleWhen = function() return getDB("showProgressBarScenarios", D.showProgressBarScenarios) or getDB("showProgressBarQuests", D.showProgressBarQuests) or getDB("showAchievementProgressBars", D.showAchievementProgressBars) end, tooltip = L["CUSTOM_FILL_COLOUR_BELOW"] },
            { type = "dropdown", name = L["FOCUS_PROGRESS_BAR_TYPES"], desc = L["FOCUS_PROGRESS_BAR_X_Y_OBJECTIVES_PERCENT"], dbKey = "progressBarTypeFilter", options = { { L["VISTA_SHOW_ZONE_AND_SUBZONE"], "both" }, { L["FOCUS_X_Y"], "xy_only" }, { L["FOCUS_PERCENT"], "percent_only" } }, get = function() return getDB("progressBarTypeFilter", D.progressBarTypeFilter) end, set = function(v) setDB("progressBarTypeFilter", v) end, visibleWhen = function() return getDB("showProgressBarScenarios", D.showProgressBarScenarios) or getDB("showProgressBarQuests", D.showProgressBarQuests) end, tooltip = L["X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"] },
            { type = "dropdown", name = L["FOCUS_PROGRESS_BAR_TEXTURE"], desc = L["FOCUS_TEXTURE_PROGRESS_BAR_FILL"], dbKey = "progressBarTexture", searchable = true, options = function() return addon.GetStatusbarDropdownOptions and addon.GetStatusbarDropdownOptions() or { { "Solid", "Solid" } } end, get = function() return getDB("progressBarTexture", D.progressBarTexture) end, set = function(v) setDB("progressBarTexture", v); OptionsData_NotifyMainAddon() end, visibleWhen = function() return getDB("showProgressBarScenarios", D.showProgressBarScenarios) or getDB("showProgressBarQuests", D.showProgressBarQuests) or getDB("showAchievementProgressBars", D.showAchievementProgressBars) end, tooltip = L["FOCUS_TEXTURE_PROGRESS_BAR_FILL_SOLID_YOUR"] },
            Toggle(L["FOCUS_TIMER"], L["FOCUS_COUNTDOWN_TIMER_TIMED_QUESTS_EVENTS_SCEN"], "showTimerBars", D.showTimerBars, { refreshIds = { "showTimerScenario", "showTimerWorld", "showTimerQuestTimed", "timerDisplayMode", "timerColorByRemaining" } }),
            Toggle(L["FOCUS_TIMER_SCENARIOS"], L["FOCUS_TIMER_SCENARIOS_DESC"], "showTimerScenario", D.showTimerScenario, { id = "showTimerScenario", visibleWhen = function() return getDB("showTimerBars", D.showTimerBars) end }),
            Toggle(L["FOCUS_TIMER_WORLD"], L["FOCUS_TIMER_WORLD_DESC"], "showTimerWorld", D.showTimerWorld, { id = "showTimerWorld", visibleWhen = function() return getDB("showTimerBars", D.showTimerBars) end }),
            Toggle(L["FOCUS_TIMER_QUEST_LOG"], L["FOCUS_TIMER_QUEST_LOG_DESC"], "showTimerQuestTimed", D.showTimerQuestTimed, { id = "showTimerQuestTimed", visibleWhen = function() return getDB("showTimerBars", D.showTimerBars) end }),
            { type = "dropdown", name = L["FOCUS_TIMER_DISPLAY"], desc = L["WHERE_COUNTDOWN"], dbKey = "timerDisplayMode", options = { { L["FOCUS_BAR_BELOW"], "bar" }, { L["FOCUS_INLINE_BESIDE_TITLE"], "inline" }, { L["FOCUS_INLINE_BELOW_TITLE"], "inline-below" } }, get = function() return getDB("timerDisplayMode", D.timerDisplayMode) end, set = function(v) setDB("timerDisplayMode", v) end, visibleWhen = function() return getDB("showTimerBars", D.showTimerBars) end },
            Toggle(L["FOCUS_COLOUR_TIMER_REMAINING"], L["COLOUR_REMAINING"], "timerColorByRemaining", D.timerColorByRemaining, { tooltip = L["FOCUS_GREEN_PLENTY_OF_LEFT_YELLOW_RUNNING"], visibleWhen = function() return getDB("showTimerBars", D.showTimerBars) end }),
            Section(L["FOCUS_EMPHASIS"]),
            Toggle(L["FOCUS_DIM_UNFOCUSED_ENTRIES"], L["DIM_UNFOCUSED_TRACKER_ENTRIES"], "dimNonSuperTracked", D.dimNonSuperTracked, { tooltip = L["FOCUS_SLIGHTLY_DIM_TITLE_ZONE_OBJECTIVES_SECTION"], refreshIds = { "dimStrength", "dimAlpha", "dimDesaturate" } }),
            { type = "slider", name = L["DIM_STRENGTH"], desc = L["DIMMING_STRENGTH"], tooltip = L["FOCUS_DIM_UNFOCUSED_ENTRIES_DESC"], dbKey = "dimStrength", min = LIM.dimStrength.min, max = LIM.dimStrength.max, get = function() return math.max(LIM.dimStrength.min, math.min(LIM.dimStrength.max, tonumber(getDB("dimStrength", D.dimStrength)) or D.dimStrength)) end, set = function(v) setDB("dimStrength", clamp(v, "dimStrength")) end, visibleWhen = function() return getDB("dimNonSuperTracked", D.dimNonSuperTracked) end },
            { type = "slider", name = L["DIM_ALPHA"], desc = L["OPACITY_OF_UNFOCUSED_ENTRIES"], tooltip = L["REDUCE_OPACITY_OF_FOCUSED_ENTRIES_INVISIBLE"], dbKey = "dimAlpha", min = LIM.dimAlpha.min, max = LIM.dimAlpha.max, get = function() return math.max(LIM.dimAlpha.min, math.min(LIM.dimAlpha.max, tonumber(getDB("dimAlpha", D.dimAlpha)) or D.dimAlpha)) end, set = function(v) setDB("dimAlpha", clamp(v, "dimAlpha")) end, visibleWhen = function() return getDB("dimNonSuperTracked", D.dimNonSuperTracked) end },
            Toggle(L["DESATURATE_FOCUSED_QUESTS"], L["DESATURATE_FOCUSED_ENTRIES"], "dimDesaturate", D.dimDesaturate, { tooltip = L["MAKE_FOCUSED_ENTRIES_GREYSCALE_PARTIALLY_DESATURATE"], visibleWhen = function() return getDB("dimNonSuperTracked", D.dimNonSuperTracked) end }),
            { type = "slider", name = L["FOCUS_HIGHLIGHT_ALPHA"], desc = L["OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"], dbKey = "highlightAlpha", min = LIM.highlightAlpha.min, max = LIM.highlightAlpha.max, get = function() local v = tonumber(getDB("highlightAlpha", D.highlightAlpha)) or D.highlightAlpha; if v <= 1 and v > 0 then return math.floor(v * 100 + 0.5) end; return math.max(LIM.highlightAlpha.min, math.min(LIM.highlightAlpha.max, v)) end, set = function(v) setDB("highlightAlpha", clamp(v, "highlightAlpha") / 100) end },
            { type = "slider", name = L["FOCUS_BAR_WIDTH"], desc = L["FOCUS_WIDTH_OF_BAR_STYLE_HIGHLIGHTS_PX"], dbKey = "highlightBarWidth", min = LIM.highlightBarWidth.min, max = LIM.highlightBarWidth.max, get = function() return math.max(LIM.highlightBarWidth.min, math.min(LIM.highlightBarWidth.max, tonumber(getDB("highlightBarWidth", D.highlightBarWidth)) or D.highlightBarWidth)) end, set = function(v) setDB("highlightBarWidth", clamp(v, "highlightBarWidth")) end },
        },
    },
    {
        key = "ClickOptions",
        name = L["DASH_CLICK_OPTIONS"],
        desc = L["FOCUS_CLICK_OPTIONS_TAB_DESC"],
        moduleKey = "focus",
        options = {
            Section(L["DASH_CLICK_OPTIONS"]),
            {
                type    = "dropdown",
                name    = L["FOCUS_CLICK_PROFILE"],
                desc    = L["FOCUS_CLICK_PROFILE_DESC"],
                dbKey   = "focusClickProfile",
                options = GetFocusClickProfileDropdownOptions,
                get = function() return getDB("focusClickProfile", D.focusClickProfile) end,
                set = function(v)
                    if FocusClickProfileChoiceHidden() and v ~= "blizzardDefault" then return end
                    setDB("focusClickProfile", v)
                end,
                refreshIds = {
                    "focusClick_left", "focusClick_shiftLeft", "focusClick_ctrlLeft", "focusClick_altLeft",
                    "focusClick_right", "focusClick_shiftRight", "focusClick_ctrlRight", "focusClick_altRight", "focusIconClickAction",
                },
            },
            {
                type    = "dropdown",
                name    = L["FOCUS_ICON_CLICK_ACTION"],
                desc    = L["FOCUS_ICON_CLICK_ACTION_DESC"],
                dbKey   = "focusIconClickAction",
                options = GetIconClickActionOptions,
                get     = function() return GetEffectiveFocusIconClickAction() end,
                set     = function(v) setDB("focusIconClickAction", v) end,
                disabled = FocusClickPresetCombosLocked,
                tooltip  = L["FOCUS_CLICK_COMBO_LOCKED_TOOLTIP"],
            },
            {
                type        = "dropdown",
                name        = L["FOCUS_COMBO_LEFT"],
                dbKey       = "focusClick_left",
                options     = function() return GetComboActionOptions("left") end,
                get         = function() return GetEffectiveFocusClickAction("left", "focusClick_left") end,
                set         = function(v) setDB("focusClick_left", v) end,
                disabled    = FocusClickPresetCombosLocked,
                tooltip     = L["FOCUS_CLICK_COMBO_LOCKED_TOOLTIP"],
            },
            {
                type        = "dropdown",
                name        = L["FOCUS_COMBO_SHIFT_LEFT"],
                dbKey       = "focusClick_shiftLeft",
                options     = function() return GetComboActionOptions("shiftLeft") end,
                get         = function() return GetEffectiveFocusClickAction("shiftLeft", "focusClick_shiftLeft") end,
                set         = function(v) setDB("focusClick_shiftLeft", v) end,
                disabled    = FocusClickPresetCombosLocked,
                tooltip     = L["FOCUS_CLICK_COMBO_LOCKED_TOOLTIP"],
            },
            {
                type        = "dropdown",
                name        = L["FOCUS_COMBO_CTRL_LEFT"],
                dbKey       = "focusClick_ctrlLeft",
                options     = function() return GetComboActionOptions("ctrlLeft") end,
                get         = function() return GetEffectiveFocusClickAction("ctrlLeft", "focusClick_ctrlLeft") end,
                set         = function(v) setDB("focusClick_ctrlLeft", v) end,
                disabled    = FocusClickPresetCombosLocked,
                tooltip     = L["FOCUS_CLICK_COMBO_LOCKED_TOOLTIP"],
            },
            {
                type        = "dropdown",
                name        = L["FOCUS_COMBO_ALT_LEFT"],
                dbKey       = "focusClick_altLeft",
                options     = function() return GetComboActionOptions("altLeft") end,
                get         = function() return GetEffectiveFocusClickAction("altLeft", "focusClick_altLeft") end,
                set         = function(v) setDB("focusClick_altLeft", v) end,
                disabled    = FocusClickPresetCombosLocked,
                tooltip     = L["FOCUS_CLICK_COMBO_LOCKED_TOOLTIP"],
            },
            {
                type        = "dropdown",
                name        = L["FOCUS_COMBO_RIGHT"],
                dbKey       = "focusClick_right",
                options     = function() return GetComboActionOptions("right") end,
                get         = function() return GetEffectiveFocusClickAction("right", "focusClick_right") end,
                set         = function(v) setDB("focusClick_right", v) end,
                disabled    = FocusClickPresetCombosLocked,
                tooltip     = L["FOCUS_CLICK_COMBO_LOCKED_TOOLTIP"],
            },
            {
                type        = "dropdown",
                name        = L["FOCUS_COMBO_SHIFT_RIGHT"],
                dbKey       = "focusClick_shiftRight",
                options     = function() return GetComboActionOptions("shiftRight") end,
                get         = function() return GetEffectiveFocusClickAction("shiftRight", "focusClick_shiftRight") end,
                set         = function(v) setDB("focusClick_shiftRight", v) end,
                disabled    = FocusClickPresetCombosLocked,
                tooltip     = L["FOCUS_CLICK_COMBO_LOCKED_TOOLTIP"],
            },
            {
                type        = "dropdown",
                name        = L["FOCUS_COMBO_CTRL_RIGHT"],
                dbKey       = "focusClick_ctrlRight",
                options     = function() return GetComboActionOptions("ctrlRight") end,
                get         = function() return GetEffectiveFocusClickAction("ctrlRight", "focusClick_ctrlRight") end,
                set         = function(v) setDB("focusClick_ctrlRight", v) end,
                disabled    = FocusClickPresetCombosLocked,
                tooltip     = L["FOCUS_CLICK_COMBO_LOCKED_TOOLTIP"],
            },
            {
                type        = "dropdown",
                name        = L["FOCUS_COMBO_ALT_RIGHT"],
                dbKey       = "focusClick_altRight",
                options     = function() return GetComboActionOptions("altRight") end,
                get         = function() return GetEffectiveFocusClickAction("altRight", "focusClick_altRight") end,
                set         = function(v) setDB("focusClick_altRight", v) end,
                disabled    = FocusClickPresetCombosLocked,
                tooltip     = L["FOCUS_CLICK_COMBO_LOCKED_TOOLTIP"],
            },
            Section(L["FOCUS_CLICK_SAFETY"]),
            Toggle(L["FOCUS_CTRL_FOCUS_UNTRACK"], L["PREVENT_ACCIDENTAL_CLICKS"], "requireCtrlForQuestClicks", D.requireCtrlForQuestClicks, { tooltip = L["CTRL_LEFT_FOCUS_ADD_CTRL_RIGHT"] }),
            Toggle(L["FOCUS_CTRL_CLICK_COMPLETE"], L["REQUIRE_CTRL_COMPLETE_CLICK_COMPLETABLE_QUESTS"], "requireModifierForClickToComplete", D.requireModifierForClickToComplete, { tooltip = L["QUESTS_DON_T_NEED_NPC_TURN"] }),
        },
    },
    {
        key = "SortingFiltering",
        name = L["SORTING_FILTERING"],
        desc = L["ORGANIZE_HIDE_TRACKED_ENTRIES_YOUR_PREFERENCE"],
        moduleKey = "focus",
        options = {
            Section(L["FOCUS_FILTERING"]),
            Toggle(L["CURRENT_ZONE"], L["FOCUS_HIDE_QUESTS_OUTSIDE_YOUR_CURRENT_ZONE"], "filterByZone", D.filterByZone),
            Section(L["GROUPING"]),
            { type = "toggle", name = L["FOCUS_FOCUSED_QUEST_CATEGORY"], desc = L["FOCUS_FOCUSED_QUEST_CATEGORY_DESC"], tooltip = L["FOCUS_FOCUSED_QUEST_CATEGORY_TIP"], dbKey = "showFocusedQuestCategory", isNew = "4.17.7", get = function() return getDB("showFocusedQuestCategory", D.showFocusedQuestCategory) end, set = function(v) setDB("showFocusedQuestCategory", v); if addon.RequestRefresh then addon.RequestRefresh() end; if addon.FullLayout then addon.FullLayout() end end },
            { type = "toggle", name = L["FOCUS_PROXIMITY_AUTO_SUPERTRACK"], desc = L["FOCUS_PROXIMITY_AUTO_SUPERTRACK_DESC"], tooltip = L["FOCUS_PROXIMITY_AUTO_SUPERTRACK_TIP"], dbKey = "proximityAutoSuperTrack", isNew = "5.1.3", get = function() return getDB("proximityAutoSuperTrack", D.proximityAutoSuperTrack) end, set = function(v) setDB("proximityAutoSuperTrack", v); if addon.RequestRefresh then addon.RequestRefresh() end; if addon.FullLayout then addon.FullLayout() end end, refreshIds = { "proximityAutoIncludeUntracked" } },
            { type = "toggle", name = L["FOCUS_PROXIMITY_INCLUDE_UNTRACKED"], desc = L["FOCUS_PROXIMITY_INCLUDE_UNTRACKED_DESC"], tooltip = L["FOCUS_PROXIMITY_INCLUDE_UNTRACKED_TIP"], dbKey = "proximityAutoIncludeUntracked", isNew = "5.1.3", get = function() return getDB("proximityAutoIncludeUntracked", D.proximityAutoIncludeUntracked) end, set = function(v) setDB("proximityAutoIncludeUntracked", v); if addon.RequestRefresh then addon.RequestRefresh() end; if addon.FullLayout then addon.FullLayout() end end, visibleWhen = function() return getDB("proximityAutoSuperTrack", D.proximityAutoSuperTrack) end, id = "proximityAutoIncludeUntracked" },
            Toggle(L["FOCUS_CURRENT_QUEST_CATEGORY"], L["RECENT_PROGRESS_TOP"], "showCurrentQuestCategory", D.showCurrentQuestCategory, { tooltip = L["FOCUS_QUEST_PROGRESSION_SECTION"], refreshIds = { "currentQuestWindowSec" } }),
            { type = "slider", name = L["FOCUS_CURRENT_QUEST_WINDOW"], desc = L["SECONDS_OF_RECENT_PROGRESS"], dbKey = "currentQuestWindowSec", min = LIM.currentQuestWindowSec.min, max = LIM.currentQuestWindowSec.max, get = function() return math.max(LIM.currentQuestWindowSec.min, math.min(LIM.currentQuestWindowSec.max, tonumber(getDB("currentQuestWindowSec", D.currentQuestWindowSec)) or D.currentQuestWindowSec)) end, set = function(v) setDB("currentQuestWindowSec", clamp(v, "currentQuestWindowSec")) end, visibleWhen = function() return getDB("showCurrentQuestCategory", D.showCurrentQuestCategory) end, id = "currentQuestWindowSec" },
            Toggle(L["CURRENT_ZONE_GROUP"], L["DEDICATED_SECTION_ZONE_QUESTS"], "showNearbyGroup", D.showNearbyGroup, { tooltip = L["ZONE_QUESTS_APPEAR_THEIR_NORMAL_CATEGORY"], refreshIds = { "nearbyCompleteToBottom" } }),
            Toggle(L["FOCUS_SHOW_ZONE_EVENTS"], L["FOCUS_SHOW_ZONE_EVENTS_DESC"], "showEventsInZone", D.showEventsInZone, { id = "showEventsInZone", tooltip = L["FOCUS_SHOW_ZONE_EVENTS_TIP"] }),
            { type = "toggle", name = L["READY_TURN_BOTTOM"], desc = L["MOVE_COMPLETED_QUESTS_BOTTOM_OF_CURRENT"], dbKey = "nearbyCompleteToBottom", get = function() return getDB("nearbyCompleteToBottom", D.nearbyCompleteToBottom) end, set = function(v) setDB("nearbyCompleteToBottom", v); OptionsData_NotifyMainAddon() end, visibleWhen = function() return getDB("showNearbyGroup", D.showNearbyGroup) end },
            { type = "toggle", name = L["READY_TURN_GROUP"], desc = L["DEDICATED_SECTION_COMPLETED_QUESTS"], dbKey = "showCompleteGroup", get = function() return getDB("showCompleteGroup", D.showCompleteGroup) end, set = function(v) setDB("showCompleteGroup", v); if addon.RequestRefresh then addon.RequestRefresh() end; if addon.FullLayout then addon.FullLayout() end end, tooltip = L["COMPLETED_QUESTS_STAY_THEIR_ORIGINAL_CATEGO"], refreshIds = { "keepCampaignInCategory", "keepImportantInCategory" } },
            { type = "toggle", name = L["KEEP_CAMPAIGN_CATEGORY"], desc = L["KEEP_CAMPAIGN_READY_TURN"], dbKey = "keepCampaignInCategory", get = function() return getDB("keepCampaignInCategory", D.keepCampaignInCategory) end, set = function(v) setDB("keepCampaignInCategory", v); if addon.RequestRefresh then addon.RequestRefresh() end; if addon.FullLayout then addon.FullLayout() end end, tooltip = L["THEY_MOVE_COMPLETE_SECTION"], visibleWhen = function() return getDB("showCompleteGroup", D.showCompleteGroup) end, id = "keepCampaignInCategory" },
            { type = "toggle", name = L["KEEP_IMPORTANT_CATEGORY"], desc = L["KEEP_IMPORTANT_READY_TURN"], dbKey = "keepImportantInCategory", get = function() return getDB("keepImportantInCategory", D.keepImportantInCategory) end, set = function(v) setDB("keepImportantInCategory", v); if addon.RequestRefresh then addon.RequestRefresh() end; if addon.FullLayout then addon.FullLayout() end end, tooltip = L["THEY_MOVE_COMPLETE_SECTION"], visibleWhen = function() return getDB("showCompleteGroup", D.showCompleteGroup) end, id = "keepImportantInCategory" },
            Section(L["FOCUS_SORTING"]),
            { type = "reorderList", name = L["FOCUS_CATEGORY_ORDER"], labelMap = addon.SECTION_LABELS, presets = addon.GROUP_ORDER_PRESETS, get = function() return addon.GetGroupOrder() end, set = function(order) addon.SetGroupOrder(order) end, desc = L["FOCUS_CATEGORIES_REORDER_EXCEPT_DELVES_SCENARIOS_TIP"] },
            { type = "dropdown", name = L["SORT_MODE"], desc = L["FOCUS_ENTRY_NUMBER_IN_CATEGORY"], dbKey = "entrySortMode", options = { { L["FOCUS_ALPHABETICAL"], "alpha" }, { L["FOCUS_QUEST_TYPE"], "questType" }, { L["FOCUS_ZONE"], "zone" }, { L["FOCUS_QUEST_LEVEL"], "level" }, { L["FOCUS_PROXIMITY"], "proximity" } }, get = function() return getDB("entrySortMode", D.entrySortMode) end, set = function(v) setDB("entrySortMode", v); if addon.ScheduleRefresh then addon.ScheduleRefresh() end end },
        },
    },
    {
        key = "Typography",
        name = L["DASH_TYPOGRAPHY"],
        desc = L["ADJUST_FONTS_SIZES_CASING_DROP_SHADOWS"],
        moduleKey = "focus",
        options = {
            Section(L["FOCUS_FONT_FAMILIES"]),
            { type = "dropdown", name = L["FOCUS_FONT"], desc = L["FOCUS_FONT_FAMILY"], dbKey = "fontPath", searchable = true, options = GetFontDropdownOptions, get = function() return getDB("fontPath", defaultFontPath) end, set = function(v) setDB("fontPath", v) end, displayFn = addon.GetFontNameForPath, fontPreviewInList = true },
            Toggle(L["FOCUS_PER_ELEMENT_FONTS"], L["OVERRIDE_FONT_PER_ELEMENT"], "usePerElementFonts", D.usePerElementFonts, { refreshIds = { "titleFontPath", "zoneFontPath", "objectiveFontPath", "sectionFontPath", "progressBarFontPath", "timerFontPath", "optionsFontPath" } }),
            { type = "dropdown", name = L["FOCUS_TITLE_FONT"], desc = L["FOCUS_FONT_FAMILY_QUEST_TITLES"], dbKey = "titleFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("titleFontPath") end, get = function() return getDB("titleFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("titleFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", D.usePerElementFonts) end, id = "titleFontPath", fontPreviewInList = true },
            { type = "dropdown", name = L["VISTA_ZONE_FONT"], desc = L["FOCUS_FONT_FAMILY_ZONE_LABELS"], dbKey = "zoneFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("zoneFontPath") end, get = function() return getDB("zoneFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("zoneFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", D.usePerElementFonts) end, id = "zoneFontPath", fontPreviewInList = true },
            { type = "dropdown", name = L["FOCUS_OBJECTIVE_FONT"], desc = L["FOCUS_FONT_FAMILY_OBJECTIVE_TEXT"], dbKey = "objectiveFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("objectiveFontPath") end, get = function() return getDB("objectiveFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("objectiveFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", D.usePerElementFonts) end, id = "objectiveFontPath", fontPreviewInList = true },
            { type = "dropdown", name = L["FOCUS_SECTION_FONT"], desc = L["FOCUS_FONT_FAMILY_SECTION_HEADERS"], dbKey = "sectionFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("sectionFontPath") end, get = function() return getDB("sectionFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("sectionFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", D.usePerElementFonts) end, id = "sectionFontPath", fontPreviewInList = true },
            { type = "dropdown", name = L["FOCUS_PROGRESS_BAR_FONT"], desc = L["FOCUS_FONT_FAMILY_PROGRESS_BAR_LABEL"], dbKey = "progressBarFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("progressBarFontPath") end, get = function() return getDB("progressBarFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("progressBarFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", D.usePerElementFonts) end, id = "progressBarFontPath", fontPreviewInList = true },
            { type = "dropdown", name = L["FOCUS_TIMER_TEXT_FONT"], desc = L["FOCUS_FONT_FAMILY_TIMER_TEXT"], dbKey = "timerFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("timerFontPath") end, get = function() return getDB("timerFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("timerFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", D.usePerElementFonts) end, id = "timerFontPath", fontPreviewInList = true },
            { type = "dropdown", name = L["FOCUS_OPTIONS_FONT"], desc = L["FOCUS_FONT_FAMILY_OPTIONS"], dbKey = "optionsFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("optionsFontPath") end, get = function() return getDB("optionsFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("optionsFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", D.usePerElementFonts) end, id = "optionsFontPath", fontPreviewInList = true },
            Section(L["FOCUS_FONT_SIZES"]),
            Slider(L["FOCUS_GLOBAL_FONT_SIZE"], L["ADJUST_FONT_SIZES_AMOUNT"], "globalFontSizeOffset", LIM.globalFontSizeOffset.min, LIM.globalFontSizeOffset.max, D.globalFontSizeOffset),
            Slider(L["FOCUS_HEADER_SIZE"], L["FOCUS_HEADER_FONT_SIZE"], "headerFontSize", LIM.headerFontSize.min, LIM.headerFontSize.max, D.headerFontSize),
            Slider(L["FOCUS_TITLE_SIZE"], L["FOCUS_QUEST_TITLE_FONT_SIZE"], "titleFontSize", LIM.titleFontSize.min, LIM.titleFontSize.max, D.titleFontSize),
            Slider(L["FOCUS_OBJECTIVE_SIZE"], L["FOCUS_OBJECTIVE_TEXT_FONT_SIZE"], "objectiveFontSize", LIM.objectiveFontSize.min, LIM.objectiveFontSize.max, D.objectiveFontSize),
            Slider(L["FOCUS_ZONE_SIZE"], L["FOCUS_ZONE_LABEL_FONT_SIZE"], "zoneFontSize", LIM.zoneFontSize.min, LIM.zoneFontSize.max, D.zoneFontSize),
            Slider(L["FOCUS_SECTION_SIZE"], L["FOCUS_SECTION_HEADER_FONT_SIZE"], "sectionFontSize", LIM.sectionFontSize.min, LIM.sectionFontSize.max, D.sectionFontSize),
            Slider(L["FOCUS_PROGRESS_BAR_TEXT_SIZE"], L["FONT_SIZE_BAR_LABEL_BAR_HEIGHT"], "progressBarFontSize", LIM.progressBarFontSize.min, LIM.progressBarFontSize.max, D.progressBarFontSize, { tooltip = L["AFFECTS_SCENARIO_PROGRESS_TIMER_BARS"] }),
            Slider(L["FOCUS_TIMER_TEXT_SIZE"], L["FOCUS_TIMER_TEXT_FONT_SIZE"], "timerFontSize", LIM.timerFontSize.min, LIM.timerFontSize.max, D.timerFontSize),
            Slider(L["FOCUS_OPTIONS_TEXT_SIZE"], L["FOCUS_OPTIONS_TEXT_FONT_SIZE"], "optionsFontSize", LIM.optionsFontSize.min, LIM.optionsFontSize.max, D.optionsFontSize),
            { type = "dropdown", name = L["FOCUS_OUTLINE"], desc = L["FOCUS_FONT_OUTLINE_STYLE"], dbKey = "fontOutline", options = OUTLINE_OPTIONS, preserveOrder = true, get = function() return getDB("fontOutline", D.fontOutline) end, set = function(v) setDB("fontOutline", v) end },
            Section(L["FOCUS_TEXT_CASE"]),
            { type = "dropdown", name = L["FOCUS_HEADER_TEXT_CASE"], desc = L["FOCUS_DISPLAY_CASE_HEADER"], dbKey = "headerTextCase", options = TEXT_CASE_OPTIONS, get = function() local v = getDB("headerTextCase", D.headerTextCase); return (v == "default") and D.headerTextCase or v end, set = function(v) setDB("headerTextCase", v) end },
            { type = "dropdown", name = L["FOCUS_SECTION_HEADER_CASE"], desc = L["FOCUS_DISPLAY_CASE_CATEGORY_LABELS"], dbKey = "sectionHeaderTextCase", options = TEXT_CASE_OPTIONS, get = function() local v = getDB("sectionHeaderTextCase", D.sectionHeaderTextCase); return (v == "default") and D.sectionHeaderTextCase or v end, set = function(v) setDB("sectionHeaderTextCase", v) end },
            { type = "dropdown", name = L["FOCUS_QUEST_TITLE_CASE"], desc = L["FOCUS_DISPLAY_CASE_QUEST_TITLES"], dbKey = "questTitleCase", options = TEXT_CASE_OPTIONS, get = function() local v = getDB("questTitleCase", D.questTitleCase); return (v == "default") and D.questTitleCase or v end, set = function(v) setDB("questTitleCase", v) end },
            Section(L["FOCUS_SHADOW"]),
            Toggle(L["FOCUS_TEXT_SHADOW"], L["FOCUS_ENABLE_DROP_SHADOW_TEXT"], "showTextShadow", D.showTextShadow, { refreshIds = { "shadowOffsetX", "shadowOffsetY", "shadowAlpha" } }),
            Slider(L["FOCUS_SHADOW_X"], L["FOCUS_HORIZONTAL_SHADOW_OFFSET"], "shadowOffsetX", LIM.shadowOffsetX.min, LIM.shadowOffsetX.max, D.shadowOffsetX, { visibleWhen = function() return getDB("showTextShadow", D.showTextShadow) end, id = "shadowOffsetX" }),
            Slider(L["FOCUS_SHADOW_Y"], L["FOCUS_VERTICAL_SHADOW_OFFSET"], "shadowOffsetY", LIM.shadowOffsetY.min, LIM.shadowOffsetY.max, D.shadowOffsetY, { visibleWhen = function() return getDB("showTextShadow", D.showTextShadow) end, id = "shadowOffsetY" }),
            { type = "slider", name = L["FOCUS_SHADOW_ALPHA"], desc = L["SHADOW_OPACITY"], dbKey = "shadowAlpha", min = LIM.shadowAlpha.min, max = LIM.shadowAlpha.max, get = function() local v = tonumber(getDB("shadowAlpha", D.shadowAlpha)) or D.shadowAlpha; if v <= 1 and v > 0 then return math.floor(v * 100 + 0.5) end; return math.max(LIM.shadowAlpha.min, math.min(LIM.shadowAlpha.max, v)) end, set = function(v) setDB("shadowAlpha", clamp(v, "shadowAlpha") / 100) end, visibleWhen = function() return getDB("showTextShadow", D.showTextShadow) end, id = "shadowAlpha" },
        },
    },
    {
        key = "Interactions",
        name = L["FOCUS_INTERACTIONS"],
        desc = L["FOCUS_INTERACTIONS_TAB_DESC"],
        moduleKey = "focus",
        options = {
            Section(L["QUEST_TRACKING"]),
            Toggle(L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS"], L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS_TIP"], "autoTrackOnAccept", D.autoTrackOnAccept),
            Toggle(L["FOCUS_SUPPRESS_UNTRACKED_UNTIL_RELOAD"], L["HIDE_UNTRACKED_QUESTS_UNTIL_RELOAD"], "suppressUntrackedUntilReload", D.suppressUntrackedUntilReload, { tooltip = L["FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS"] }),
            Toggle(L["FOCUS_BLACKLIST_UNTRACKED"], L["PERMANENTLY_HIDE_UNTRACKED_QUESTS"], "permanentlySuppressUntracked", D.permanentlySuppressUntracked, { tooltip = L["TAKES_PRIORITY_SUPPRESS_UNTIL_RELOAD_ACCEPTING"] }),
            Section(L["NAME_TOMTOM"]),
            Toggle(L["FOCUS_TOMTOM_QUEST_WAYPOINT"], L["FOCUS_TOMTOM_QUEST_WAYPOINT_TIP"], "tomtomQuestWaypoint", D.tomtomQuestWaypoint, { tooltip = L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_NEXT_QUEST"] }),
            Toggle(L["FOCUS_TOMTOM_RARE_WAYPOINT"], L["FOCUS_TOMTOM_WAYPOINT_RARE_CLICK"], "tomtomRareWaypoint", D.tomtomRareWaypoint, { tooltip = L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_RARE"] }),
        },
    },
    {
        key = "Animations",
        name = L["FOCUS_ANIMATIONS"],
        desc = L["TUNE_SLIDE_FADE_EFFECTS_PLUS_OBJECTIVE"],
        moduleKey = "focus",
        options = {
            Section(L["FOCUS_ANIMATIONS"]),
            Toggle(L["FOCUS_ANIMATIONS"], L["FOCUS_SLIDE_FADE_QUESTS"], "animations", D.animations),
            Section(L["OBJECTIVE_PROGRESS"]),
            Toggle(L["FOCUS_OBJECTIVE_PROGRESS_FLASH"], L["FOCUS_FLASH_OBJECTIVE_COMPLETION"], "objectiveProgressFlash", D.objectiveProgressFlash, { refreshIds = { "objectiveProgressFlashIntensity", "objectiveProgressFlashColor" } }),
            { type = "dropdown", name = L["FOCUS_FLASH_INTENSITY"], desc = L["FOCUS_OBJECTIVE_PROGRESS_FLASH_VISIBILITY"], dbKey = "objectiveProgressFlashIntensity", id = "objectiveProgressFlashIntensity", visibleWhen = function() return getDB("objectiveProgressFlash", D.objectiveProgressFlash) end, options = { { L["FOCUS_SUBTLE"], "subtle" }, { L["FOCUS_MEDIUM"], "medium" }, { L["FOCUS_STRONG"], "strong" } }, get = function() return getDB("objectiveProgressFlashIntensity", D.objectiveProgressFlashIntensity) end, set = function(v) setDB("objectiveProgressFlashIntensity", v) end },
            Color(L["FOCUS_FLASH_COLOUR"], L["FOCUS_FLASH_COLOUR_DESC"], "objectiveProgressFlashColor", { 1, 1, 1 }, { id = "objectiveProgressFlashColor", visibleWhen = function() return getDB("objectiveProgressFlash", D.objectiveProgressFlash) end }),
        },
    },
    {
        key = "Instances",
        name = L["FOCUS_INSTANCES"],
        desc = L["CONTROL_TRACKER_VISIBILITY_WITHIN_DUNGEONS_RAIDS"],
        moduleKey = "focus",
        options = {
            Section(L["DASH_VISIBILITY"]),
            Toggle(L["DUNGEON"], L["TRACKER_PARTY_DUNGEONS"], "showInDungeon", D.showInDungeon, { refreshIds = { "showInDungeonNormal", "showInDungeonHeroic", "showInDungeonMythic", "showInDungeonMythicPlus" } }),
            { type = "toggle", name = L["NORMAL_DUNGEON"], desc = L["NORMAL_DUNGEONS"], tooltip = L["TRACKER_NORMAL_DUNGEONS"], dbKey = "showInDungeonNormal", id = "showInDungeonNormal", visibleWhen = function() return getDB("showInDungeon", D.showInDungeon) end, get = function() local v = getDB("showInDungeonNormal", nil); if v ~= nil then return v end; return getDB("showInDungeon", D.showInDungeon) end, set = function(v) setDB("showInDungeonNormal", v) end },
            { type = "toggle", name = L["HEROIC_DUNGEON"], desc = L["TRACKER_HEROIC_DUNGEONS"], dbKey = "showInDungeonHeroic", id = "showInDungeonHeroic", visibleWhen = function() return getDB("showInDungeon", D.showInDungeon) end, get = function() local v = getDB("showInDungeonHeroic", nil); if v ~= nil then return v end; return getDB("showInDungeon", D.showInDungeon) end, set = function(v) setDB("showInDungeonHeroic", v) end },
            { type = "toggle", name = L["MYTHIC_DUNGEON"], desc = L["TRACKER_MYTHIC_DUNGEONS"], dbKey = "showInDungeonMythic", id = "showInDungeonMythic", visibleWhen = function() return getDB("showInDungeon", D.showInDungeon) end, get = function() local v = getDB("showInDungeonMythic", nil); if v ~= nil then return v end; return getDB("showInDungeon", D.showInDungeon) end, set = function(v) setDB("showInDungeonMythic", v) end },
            { type = "toggle", name = L["MYTHIC_PLUS_DUNGEON"], desc = L["TRACKER_MYTHIC_KEYSTONES"], dbKey = "showInDungeonMythicPlus", id = "showInDungeonMythicPlus", visibleWhen = function() return getDB("showInDungeon", D.showInDungeon) end, get = function() local v = getDB("showInDungeonMythicPlus", nil); if v ~= nil then return v end; return getDB("showInDungeon", D.showInDungeon) end, set = function(v) setDB("showInDungeonMythicPlus", v) end },
            Toggle(L["RAID"], L["TRACKER_RAIDS_ALL"], "showInRaid", D.showInRaid, { refreshIds = { "showInRaidLFR", "showInRaidNormal", "showInRaidHeroic", "showInRaidMythic" } }),
            { type = "toggle", name = L["LFR"], desc = L["TRACKER_LFR_RAID"], dbKey = "showInRaidLFR", id = "showInRaidLFR", visibleWhen = function() return getDB("showInRaid", D.showInRaid) end, get = function() local v = getDB("showInRaidLFR", nil); if v ~= nil then return v end; return getDB("showInRaid", D.showInRaid) end, set = function(v) setDB("showInRaidLFR", v) end },
            { type = "toggle", name = L["NORMAL_RAID"], desc = L["TRACKER_NORMAL_RAIDS"], dbKey = "showInRaidNormal", id = "showInRaidNormal", visibleWhen = function() return getDB("showInRaid", D.showInRaid) end, get = function() local v = getDB("showInRaidNormal", nil); if v ~= nil then return v end; return getDB("showInRaid", D.showInRaid) end, set = function(v) setDB("showInRaidNormal", v) end },
            { type = "toggle", name = L["HEROIC_RAID"], desc = L["TRACKER_HEROIC_RAIDS"], dbKey = "showInRaidHeroic", id = "showInRaidHeroic", visibleWhen = function() return getDB("showInRaid", D.showInRaid) end, get = function() local v = getDB("showInRaidHeroic", nil); if v ~= nil then return v end; return getDB("showInRaid", D.showInRaid) end, set = function(v) setDB("showInRaidHeroic", v) end },
            { type = "toggle", name = L["MYTHIC_RAID"], desc = L["TRACKER_MYTHIC_RAIDS"], dbKey = "showInRaidMythic", id = "showInRaidMythic", visibleWhen = function() return getDB("showInRaid", D.showInRaid) end, get = function() local v = getDB("showInRaidMythic", nil); if v ~= nil then return v end; return getDB("showInRaid", D.showInRaid) end, set = function(v) setDB("showInRaidMythic", v) end },
            Toggle(L["BATTLEGROUND"], L["FOCUS_TRACKER_BATTLEGROUNDS"], "showInBattleground", D.showInBattleground),
            Toggle(L["ARENA"], L["FOCUS_TRACKER_ARENAS"], "showInArena", D.showInArena),
            Section(L["MYTHIC_BLOCK"]),
            Toggle(L["ENABLE_M_BLOCK"], L["FOCUS_TIMER_COMPLETION_AFFIXES_MYTHIC_DUNGEONS"], "showMythicPlusBlock", D.showMythicPlusBlock, { refreshIds = { "mplusAlwaysShow", "mplusShowAffixIcons", "mplusShowAffixDescriptions", "mplusShowSplitTimer", "mplusBlockPosition", "mplusBossCompletedDisplay" } }),
            { type = "toggle", name = L["FOCUS_SHOW_SPLIT_TIMER"], desc = L["FOCUS_SHOW_SPLIT_TIMER_DESC"], dbKey = "mplusShowSplitTimer", id = "mplusShowSplitTimer", visibleWhen = function() return getDB("showMythicPlusBlock", D.showMythicPlusBlock) end, get = function() return getDB("mplusShowSplitTimer", D.mplusShowSplitTimer) end, set = function(v) setDB("mplusShowSplitTimer", v); if addon.UpdateMplusBlock then addon.UpdateMplusBlock() end end },
            { type = "toggle", name = L["ALWAYS"], desc = L["ALWAYS_M_TIMER"], tooltip = L["M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"], dbKey = "mplusAlwaysShow", id = "mplusAlwaysShow", visibleWhen = function() return getDB("showMythicPlusBlock", D.showMythicPlusBlock) end, get = function() return getDB("mplusAlwaysShow", D.mplusAlwaysShow) end, set = function(v) setDB("mplusAlwaysShow", v); if addon.FullLayout then addon.FullLayout() end end },
            Toggle(L["AFFIX_ICONS"], L["FOCUS_AFFIX_ICONS_NEXT_MODIFIER_NAMES_M"], "mplusShowAffixIcons", D.mplusShowAffixIcons, { id = "mplusShowAffixIcons", visibleWhen = function() return getDB("showMythicPlusBlock", D.showMythicPlusBlock) end }),
            Toggle(L["AFFIX_TOOLTIPS"], L["FOCUS_AFFIX_DESCRIPTIONS_HOVERING_M_BLO"], "mplusShowAffixDescriptions", D.mplusShowAffixDescriptions, { id = "mplusShowAffixDescriptions", visibleWhen = function() return getDB("showMythicPlusBlock", D.showMythicPlusBlock) end }),
            { type = "dropdown", name = L["BLOCK_POSITION"], desc = L["FOCUS_POSITION_OF_MYTHIC_BLOCK_RELATIVE_QUEST"], dbKey = "mplusBlockPosition", id = "mplusBlockPosition", visibleWhen = function() return getDB("showMythicPlusBlock", D.showMythicPlusBlock) end, options = MPLUS_POSITION_OPTIONS, get = function() return getDB("mplusBlockPosition", D.mplusBlockPosition) end, set = function(v) setDB("mplusBlockPosition", v) end },
            { type = "dropdown", name = L["COMPLETED_BOSS_STYLE"], desc = L["DEFEATED_BOSS_STYLE"], tooltip = L["FOCUS_DEFEATED_BOSSES_CHECKMARK_ICON_GREEN"], dbKey = "mplusBossCompletedDisplay", id = "mplusBossCompletedDisplay", visibleWhen = function() return getDB("showMythicPlusBlock", D.showMythicPlusBlock) end, options = { { L["FOCUS_CHECKMARK"], "tick" }, { L["FOCUS_GREEN_COLOUR"], "green" } }, get = function() return getDB("mplusBossCompletedDisplay", D.mplusBossCompletedDisplay) end, set = function(v) setDB("mplusBossCompletedDisplay", v); if addon.UpdateMplusBlock then addon.UpdateMplusBlock() end end },
            Section(L["FOCUS_MYTHIC_TYPOGRAPHY"], { defaultCollapsed = true }),
            { type = "slider", name = L["FOCUS_DUNGEON_NAME_SIZE"], desc = L["FOCUS_FONT_SIZE_DUNGEON_NAME_PX"], dbKey = "mplusDungeonSize", min = LIM.mplusDungeonSize.min, max = LIM.mplusDungeonSize.max, step = 1, get = function() return math.max(LIM.mplusDungeonSize.min, math.min(LIM.mplusDungeonSize.max, tonumber(getDB("mplusDungeonSize", D.mplusDungeonSize)) or D.mplusDungeonSize)) end, set = function(v) setDB("mplusDungeonSize", clamp(v, "mplusDungeonSize")) end },
            { type = "slider", name = L["FOCUS_TIMER_SIZE"], desc = L["FOCUS_FONT_SIZE_TIMER_PX"], dbKey = "mplusTimerSize", min = LIM.mplusTimerSize.min, max = LIM.mplusTimerSize.max, step = 1, get = function() return math.max(LIM.mplusTimerSize.min, math.min(LIM.mplusTimerSize.max, tonumber(getDB("mplusTimerSize", D.mplusTimerSize)) or D.mplusTimerSize)) end, set = function(v) setDB("mplusTimerSize", clamp(v, "mplusTimerSize")) end },
            { type = "slider", name = L["FOCUS_SPLIT_TIMER_SIZE"], desc = L["FOCUS_FONT_SIZE_SPLIT_TIMER_PX"], dbKey = "mplusSplitSize", min = LIM.mplusSplitSize.min, max = LIM.mplusSplitSize.max, step = 1, get = function() return math.max(LIM.mplusSplitSize.min, math.min(LIM.mplusSplitSize.max, tonumber(getDB("mplusSplitSize", D.mplusSplitSize)) or D.mplusSplitSize)) end, set = function(v) setDB("mplusSplitSize", clamp(v, "mplusSplitSize")) end },
            { type = "slider", name = L["ENEMY_FORCES_SIZE"], desc = L["FOCUS_FONT_SIZE_ENEMY_FORCES_PX"], dbKey = "mplusProgressSize", min = LIM.mplusProgressSize.min, max = LIM.mplusProgressSize.max, step = 1, get = function() return math.max(LIM.mplusProgressSize.min, math.min(LIM.mplusProgressSize.max, tonumber(getDB("mplusProgressSize", D.mplusProgressSize)) or D.mplusProgressSize)) end, set = function(v) setDB("mplusProgressSize", clamp(v, "mplusProgressSize")) end },
            { type = "slider", name = L["FOCUS_AFFIX_SIZE"], desc = L["FOCUS_FONT_SIZE_AFFIXES_PX"], dbKey = "mplusAffixSize", min = LIM.mplusAffixSize.min, max = LIM.mplusAffixSize.max, step = 1, get = function() return math.max(LIM.mplusAffixSize.min, math.min(LIM.mplusAffixSize.max, tonumber(getDB("mplusAffixSize", D.mplusAffixSize)) or D.mplusAffixSize)) end, set = function(v) setDB("mplusAffixSize", clamp(v, "mplusAffixSize")) end },
            { type = "slider", name = L["FOCUS_BOSS_SIZE"], desc = L["FOCUS_FONT_SIZE_BOSS_NAMES_PX"], dbKey = "mplusBossSize", min = LIM.mplusBossSize.min, max = LIM.mplusBossSize.max, step = 1, get = function() return math.max(LIM.mplusBossSize.min, math.min(LIM.mplusBossSize.max, tonumber(getDB("mplusBossSize", D.mplusBossSize)) or D.mplusBossSize)) end, set = function(v) setDB("mplusBossSize", clamp(v, "mplusBossSize")) end },
            Section(L["MYTHIC_COLOURS"], { defaultCollapsed = true }),
            { type = "color", name = L["FOCUS_DUNGEON_NAME_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_DUNGEON_NAME"], dbKey = "mplusDungeonColor", get = function() return getDB("mplusDungeonColorR", D.mplusDungeonColorR), getDB("mplusDungeonColorG", D.mplusDungeonColorG), getDB("mplusDungeonColorB", D.mplusDungeonColorB) end, set = function(r, g, b) setDB("mplusDungeonColorR", r); setDB("mplusDungeonColorG", g); setDB("mplusDungeonColorB", b) end },
            { type = "color", name = L["FOCUS_TIMER_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_TIMER"], dbKey = "mplusTimerColor", get = function() return getDB("mplusTimerColorR", D.mplusTimerColorR), getDB("mplusTimerColorG", D.mplusTimerColorG), getDB("mplusTimerColorB", D.mplusTimerColorB) end, set = function(r, g, b) setDB("mplusTimerColorR", r); setDB("mplusTimerColorG", g); setDB("mplusTimerColorB", b) end },
            { type = "color", name = L["FOCUS_TIMER_OVERTIME_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_TIMER_LIMIT"], dbKey = "mplusTimerOvertimeColor", get = function() return getDB("mplusTimerOvertimeColorR", D.mplusTimerOvertimeColorR), getDB("mplusTimerOvertimeColorG", D.mplusTimerOvertimeColorG), getDB("mplusTimerOvertimeColorB", D.mplusTimerOvertimeColorB) end, set = function(r, g, b) setDB("mplusTimerOvertimeColorR", r); setDB("mplusTimerOvertimeColorG", g); setDB("mplusTimerOvertimeColorB", b) end },
            { type = "color", name = L["FOCUS_SPLIT_TIMER_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_SPLIT_TIMER"], dbKey = "mplusSplitColor", get = function() return getDB("mplusSplitColorR", D.mplusSplitColorR), getDB("mplusSplitColorG", D.mplusSplitColorG), getDB("mplusSplitColorB", D.mplusSplitColorB) end, set = function(r, g, b) setDB("mplusSplitColorR", r); setDB("mplusSplitColorG", g); setDB("mplusSplitColorB", b) end },
            { type = "color", name = L["FOCUS_SPLIT_TIMER_PAST_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_SPLIT_TIMER_PAST"], dbKey = "mplusSplitPastColor", get = function() return getDB("mplusSplitPastColorR", D.mplusSplitPastColorR), getDB("mplusSplitPastColorG", D.mplusSplitPastColorG), getDB("mplusSplitPastColorB", D.mplusSplitPastColorB) end, set = function(r, g, b) setDB("mplusSplitPastColorR", r); setDB("mplusSplitPastColorG", g); setDB("mplusSplitPastColorB", b) end },
            { type = "color", name = L["ENEMY_FORCES_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_ENEMY_FORCES"], dbKey = "mplusProgressColor", get = function() return getDB("mplusProgressColorR", D.mplusProgressColorR), getDB("mplusProgressColorG", D.mplusProgressColorG), getDB("mplusProgressColorB", D.mplusProgressColorB) end, set = function(r, g, b) setDB("mplusProgressColorR", r); setDB("mplusProgressColorG", g); setDB("mplusProgressColorB", b) end },
            { type = "color", name = L["FOCUS_BAR_FILL_COLOUR"], desc = L["FOCUS_PROGRESS_BAR_FILL_COLOUR_PROGRESS"], dbKey = "mplusBarColor", get = function() return getDB("mplusBarColorR", D.mplusBarColorR), getDB("mplusBarColorG", D.mplusBarColorG), getDB("mplusBarColorB", D.mplusBarColorB), getDB("mplusBarColorA", D.mplusBarColorA) end, set = function(r, g, b, a) setDB("mplusBarColorR", r); setDB("mplusBarColorG", g); setDB("mplusBarColorB", b); if a then setDB("mplusBarColorA", a) end end, hasAlpha = true },
            { type = "color", name = L["FOCUS_BAR_COMPLETE_COLOUR"], desc = L["FOCUS_PROGRESS_BAR_FILL_COLOUR_ENEMY_FORCES"], dbKey = "mplusBarDoneColor", get = function() return getDB("mplusBarDoneColorR", D.mplusBarDoneColorR), getDB("mplusBarDoneColorG", D.mplusBarDoneColorG), getDB("mplusBarDoneColorB", D.mplusBarDoneColorB), getDB("mplusBarDoneColorA", D.mplusBarDoneColorA) end, set = function(r, g, b, a) setDB("mplusBarDoneColorR", r); setDB("mplusBarDoneColorG", g); setDB("mplusBarDoneColorB", b); if a then setDB("mplusBarDoneColorA", a) end end, hasAlpha = true },
            { type = "color", name = L["FOCUS_AFFIX_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_AFFIXES"], dbKey = "mplusAffixColor", get = function() return getDB("mplusAffixColorR", D.mplusAffixColorR), getDB("mplusAffixColorG", D.mplusAffixColorG), getDB("mplusAffixColorB", D.mplusAffixColorB) end, set = function(r, g, b) setDB("mplusAffixColorR", r); setDB("mplusAffixColorG", g); setDB("mplusAffixColorB", b) end },
            { type = "color", name = L["FOCUS_BOSS_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_BOSS_NAMES"], dbKey = "mplusBossColor", get = function() return getDB("mplusBossColorR", D.mplusBossColorR), getDB("mplusBossColorG", D.mplusBossColorG), getDB("mplusBossColorB", D.mplusBossColorB) end, set = function(r, g, b) setDB("mplusBossColorR", r); setDB("mplusBossColorG", g); setDB("mplusBossColorB", b) end },
            Button(L["RESET_MYTHIC_STYLING"], nil, function()
                setDB("mplusDungeonSize", D.mplusDungeonSize)
                setDB("mplusDungeonColorR", D.mplusDungeonColorR); setDB("mplusDungeonColorG", D.mplusDungeonColorG); setDB("mplusDungeonColorB", D.mplusDungeonColorB)
                setDB("mplusTimerSize", D.mplusTimerSize)
                setDB("mplusTimerColorR", D.mplusTimerColorR); setDB("mplusTimerColorG", D.mplusTimerColorG); setDB("mplusTimerColorB", D.mplusTimerColorB)
                setDB("mplusTimerOvertimeColorR", D.mplusTimerOvertimeColorR); setDB("mplusTimerOvertimeColorG", D.mplusTimerOvertimeColorG); setDB("mplusTimerOvertimeColorB", D.mplusTimerOvertimeColorB)
                setDB("mplusSplitSize", D.mplusSplitSize)
                setDB("mplusSplitColorR", D.mplusSplitColorR); setDB("mplusSplitColorG", D.mplusSplitColorG); setDB("mplusSplitColorB", D.mplusSplitColorB)
                setDB("mplusSplitPastColorR", D.mplusSplitPastColorR); setDB("mplusSplitPastColorG", D.mplusSplitPastColorG); setDB("mplusSplitPastColorB", D.mplusSplitPastColorB)
                setDB("mplusProgressSize", D.mplusProgressSize)
                setDB("mplusProgressColorR", D.mplusProgressColorR); setDB("mplusProgressColorG", D.mplusProgressColorG); setDB("mplusProgressColorB", D.mplusProgressColorB)
                setDB("mplusBarColorR", D.mplusBarColorR); setDB("mplusBarColorG", D.mplusBarColorG); setDB("mplusBarColorB", D.mplusBarColorB); setDB("mplusBarColorA", D.mplusBarColorA)
                setDB("mplusBarDoneColorR", D.mplusBarDoneColorR); setDB("mplusBarDoneColorG", D.mplusBarDoneColorG); setDB("mplusBarDoneColorB", D.mplusBarDoneColorB); setDB("mplusBarDoneColorA", D.mplusBarDoneColorA)
                setDB("mplusAffixSize", D.mplusAffixSize)
                setDB("mplusAffixColorR", D.mplusAffixColorR); setDB("mplusAffixColorG", D.mplusAffixColorG); setDB("mplusAffixColorB", D.mplusAffixColorB)
                setDB("mplusBossSize", D.mplusBossSize)
                setDB("mplusBossColorR", D.mplusBossColorR); setDB("mplusBossColorG", D.mplusBossColorG); setDB("mplusBossColorB", D.mplusBossColorB)
            end, { refreshIds = { "mplusDungeonSize", "mplusDungeonColor", "mplusTimerSize", "mplusTimerColor", "mplusTimerOvertimeColor", "mplusSplitSize", "mplusSplitColor", "mplusSplitPastColor", "mplusProgressSize", "mplusProgressColor", "mplusBarColor", "mplusBarDoneColor", "mplusAffixSize", "mplusAffixColor", "mplusBossSize", "mplusBossColor" } }),
            Section(L["FOCUS_DELVES_DUNGEONS"]),
            Toggle(L["SCENARIO_EVENTS"], L["FOCUS_TRACK_DELVE_DUNGEON_SCENARIO_ACTIVITIES"], "showScenarioEvents", D.showScenarioEvents, { tooltip = L["FOCUS_DELVES_APPEAR_DELVES_SECTION_DUNGEONS_DUNGEON"] }),
            Toggle(L["ACTIVE_INSTANCE"], L["ACTIVE_INSTANCE_SECTION"], "hideOtherCategoriesInDelve", D.hideOtherCategoriesInDelve, { tooltip = L["HIDES_CATEGORIES_WHILE_A_DELVE_PARTY"] }),
            { type = "toggle", name = L["FOCUS_DELVE_AFFIX_NAMES"], desc = L["AFFIX_NAMES_FIRST_DELVE_ENTRY"], dbKey = "showDelveAffixes", get = function() return getDB("showDelveAffixes", getDB("delveBlockShowAffixes", true)) end, set = function(v) setDB("showDelveAffixes", v); if addon.ScheduleRefresh then addon.ScheduleRefresh() end end, tooltip = L["APPEAR_FULL_TRACKER_REPLACEMENTS"] },
            { type = "toggle", name = L["FOCUS_RITUAL_SITE_TITLE_COUNTERS"], desc = L["FOCUS_RITUAL_SITE_TITLE_COUNTERS_DESC"], dbKey = "showScenarioHeaderCurrenciesInTitle", get = function() return getDB("showScenarioHeaderCurrenciesInTitle", D.showScenarioHeaderCurrenciesInTitle) end, set = function(v) setDB("showScenarioHeaderCurrenciesInTitle", v); if addon.RequestRefresh then addon.RequestRefresh() end; if addon.FullLayout then addon.FullLayout() end end, tooltip = L["FOCUS_RITUAL_SITE_TITLE_COUNTERS_TOOLTIP"] },
            Section(L["FOCUS_SCENARIO_BAR"]),
            Toggle(L["SCENARIO_TIMER_BAR"], L["FOCUS_TIMER_PROGRESS_BAR_SCENARIO_ENTRIES"], "cinematicScenarioBar", D.cinematicScenarioBar),
        },
    },
    {
        key = "ContentTypes",
        name = L["FOCUS_CONTENT"],
        desc = L["TOGGLE_TRACKING_WORLD_QUESTS_RARES_ACHIEVEMENTS"],
        moduleKey = "focus",
        options = {
            Section(L["FOCUS_WORLD_QUESTS"]),
            Toggle(L["ZONE_WORLD_QUESTS"], L["AUTO_ADD_WQS_YOUR_CURRENT_ZONE"], "focusShowWorldQuests", D.focusShowWorldQuests, { tooltip = L["TRACKED_NEARBY_WQS_APPEAR_BLIZZARD_DEFAULT"] }),
            Section(L["FOCUS_RARE_BOSSES"]),
            Toggle(L["FOCUS_RARE_BOSSES"], L["UI_RARE_BOSS_VIGNETTES_LIST"], "showRareBosses", D.showRareBosses),
            Toggle(L["UI_RARE_LOOT"], L["UI_TREASURE_ITEM_VIGNETTES_RARE_LOOT"], "showRareLoot", D.showRareLoot),
            Toggle(L["RARE_SOUND_ALERT"], L["UI_PLAY_A_SOUND_A_RARE"], "rareAddedSound", D.rareAddedSound, { refreshIds = { "rareAddedSoundChoice", "rareAddedSoundVolume" } }),
            { type = "dropdown", name = L["RARE_ADDED_SOUND_CHOICE"], desc = L["SOUND_PLAYED_A_RARE_BOSS_APPEARS"], tooltip = L["CHOOSE_WHICH_SOUND_PLAY_A_RARE"], dbKey = "rareAddedSoundChoice", options = function() return addon.GetSoundDropdownOptions and addon.GetSoundDropdownOptions() or { { "Default", "default" } } end, get = function() return getDB("rareAddedSoundChoice", D.rareAddedSoundChoice) end, set = function(v) setDB("rareAddedSoundChoice", v); if addon.PlayRareAddedSound then addon.PlayRareAddedSound() end end, visibleWhen = function() return getDB("rareAddedSound", D.rareAddedSound) end },
            { type = "slider", name = L["UI_RARE_SOUND_VOLUME"], desc = L["UI_VOLUME_OF_RARE_ALERT_SOUND"], tooltip = L["UI_BOOST_REDUCE_RARE_ALERT_VOLUME"], dbKey = "rareAddedSoundVolume", min = LIM.rareAddedSoundVolume.min, max = LIM.rareAddedSoundVolume.max, get = function() return math.max(LIM.rareAddedSoundVolume.min, math.min(LIM.rareAddedSoundVolume.max, tonumber(getDB("rareAddedSoundVolume", D.rareAddedSoundVolume)) or D.rareAddedSoundVolume)) end, set = function(v) setDB("rareAddedSoundVolume", clamp(v, "rareAddedSoundVolume")) end, visibleWhen = function() return getDB("rareAddedSound", D.rareAddedSound) end, id = "rareAddedSoundVolume" },
            Section(L["FOCUS_ACHIEVEMENTS"]),
            Toggle(L["FOCUS_ACHIEVEMENTS"], L["FOCUS_TRACKED_ACHIEVEMENTS_LIST"], "showAchievements", D.showAchievements, { refreshIds = { "showCompletedAchievements", "showAchievementIcons", "achievementOnlyMissingRequirements", "showAchievementProgressBars", "showAchievementSectionPoints" } }),
            Toggle(L["INCLUDE_COMPLETED"], L["COMPLETED_ACHIEVEMENTS_LIST"], "showCompletedAchievements", D.showCompletedAchievements, { id = "showCompletedAchievements", visibleWhen = function() return getDB("showAchievements", D.showAchievements) end, tooltip = L["PROGRESS_TRACKED_ACHIEVEMENTS_SHOWN"] }),
            Toggle(L["ACHIEVEMENT_ICONS"], L["ICON_NEXT_ACHIEVEMENT_TITLE"], "showAchievementIcons", D.showAchievementIcons, { id = "showAchievementIcons", visibleWhen = function() return getDB("showAchievements", D.showAchievements) end, tooltip = L["REQUIRES_QUEST_TYPE_ICONS_ENABLED_DISPLAY"] }),
            Toggle(L["MISSING_CRITERIA"], L["INCOMPLETE_CRITERIA"], "achievementOnlyMissingRequirements", D.achievementOnlyMissingRequirements, { id = "achievementOnlyMissingRequirements", visibleWhen = function() return getDB("showAchievements", D.showAchievements) end, tooltip = L["FOCUS_CRITERIA_YOU_HAVEN_T_COMPLETED_TR"] }),
            { type = "toggle", name = L["FOCUS_ACHIEVEMENT_PROGRESS_BARS"], desc = L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_DESC"], dbKey = "showAchievementProgressBars", id = "showAchievementProgressBars", visibleWhen = function() return getDB("showAchievements", D.showAchievements) end, get = function() return getDB("showAchievementProgressBars", D.showAchievementProgressBars) end, set = function(v) setDB("showAchievementProgressBars", v); OptionsData_NotifyMainAddon() end, tooltip = L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_TIP"] },
            Toggle(L["FOCUS_ACHIEVEMENT_POINTS_HEADER"], L["FOCUS_ACHIEVEMENT_POINTS_HEADER_DESC"], "showAchievementSectionPoints", D.showAchievementSectionPoints, { id = "showAchievementSectionPoints", visibleWhen = function() return getDB("showAchievements", D.showAchievements) end, tooltip = L["FOCUS_ACHIEVEMENT_POINTS_HEADER_TIP"] }),
            Section(L["FOCUS_ENDEAVORS"]),
            Toggle(L["FOCUS_SHOW_ENDEAVORS"], L["FOCUS_TRACKED_ENDEAVORS_PLAYER_HOUSING_LIST"], "showEndeavors", D.showEndeavors, { refreshIds = { "showCompletedEndeavors" } }),
            Toggle(L["INCLUDE_COMPLETED"], L["FOCUS_INCLUDE_COMPLETED_ENDEAVORS_TRACKER"], "showCompletedEndeavors", D.showCompletedEndeavors, { id = "showCompletedEndeavors", visibleWhen = function() return getDB("showEndeavors", D.showEndeavors) end }),
            Section(L["FOCUS_DECOR"]),
            Toggle(L["FOCUS_SHOW_DECOR"], L["FOCUS_TRACKED_HOUSING_DECOR_LIST"], "showDecor", D.showDecor, { refreshIds = { "showDecorIcons" } }),
            Toggle(L["DECOR_ICONS"], L["FOCUS_DECOR_ITEM_S_ICON_NEXT_TITLE"], "showDecorIcons", D.showDecorIcons, { id = "showDecorIcons", visibleWhen = function() return getDB("showDecor", D.showDecor) end }),
            Section(L["FOCUS_APPEARANCES"]),
            Toggle(L["FOCUS_SHOW_APPEARANCES"], L["FOCUS_TRACKED_TRANSMOG_APPEARANCES_LIST"], "showAppearances", D.showAppearances, { refreshIds = { "showAppearanceIcons", "showCollectedAppearances" } }),
            Toggle(L["INCLUDE_COMPLETED"], L["FOCUS_INCLUDE_COLLECTED_APPEARANCES_TRACKER"], "showCollectedAppearances", D.showCollectedAppearances, { id = "showCollectedAppearances", visibleWhen = function() return getDB("showAppearances", D.showAppearances) end }),
            Toggle(L["FOCUS_APPEARANCE_ICONS"], L["FOCUS_APPEARANCE_ICON_NEXT_TITLE"], "showAppearanceIcons", D.showAppearanceIcons, { id = "showAppearanceIcons", visibleWhen = function() return getDB("showAppearances", D.showAppearances) end, tooltip = L["REQUIRES_QUEST_TYPE_ICONS_ENABLED_DISPLAY"] }),
            Toggle(L["FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON"], L["FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON_DESC"], "appearanceIconsUseTransmogTypeIcon", D.appearanceIconsUseTransmogTypeIcon, { id = "appearanceIconsUseTransmogTypeIcon", visibleWhen = function() return getDB("showAppearances", D.showAppearances) and getDB("showAppearanceIcons", D.showAppearanceIcons) end, tooltip = L["REQUIRES_QUEST_TYPE_ICONS_ENABLED_DISPLAY"] }),
            Section(L["RECIPES"]),
            Toggle(L["RECIPES"], L["TRACKED_PROFESSION_RECIPES_LIST"], "showRecipes", D.showRecipes, { refreshIds = { "showRecipeReagents", "recipeReagentsFullDetail", "showOptionalReagents", "showFinishingReagents", "showChoiceSlots", "showRecipeIcons", "recipeRarityColors", "showCraftableCount", "showRecipeQualityInfo", "showRecipeRequirements" } }),
            Toggle(L["REAGENTS"], L["REAGENT_SHOPPING_LIST_RECIPE"], "showRecipeReagents", D.showRecipeReagents, { id = "showRecipeReagents", visibleWhen = function() return getDB("showRecipes", D.showRecipes) end }),
            Toggle(L["FOCUS_RECIPE_REAGENTS_FULL_DETAIL"], L["FOCUS_RECIPE_REAGENTS_FULL_DETAIL_DESC"], "recipeReagentsFullDetail", D.recipeReagentsFullDetail, { id = "recipeReagentsFullDetail", visibleWhen = function() return getDB("showRecipes", D.showRecipes) and getDB("showRecipeReagents", D.showRecipeReagents) end, refreshIds = { "showOptionalReagents", "showFinishingReagents", "showChoiceSlots" } }),
            Toggle(L["FOCUS_OPTIONAL_REAGENTS"], L["OPTIONAL_REAGENT_SLOTS"], "showOptionalReagents", D.showOptionalReagents, { id = "showOptionalReagents", visibleWhen = function() return getDB("showRecipes", D.showRecipes) and getDB("recipeReagentsFullDetail", D.recipeReagentsFullDetail) end }),
            Toggle(L["FOCUS_FINISHING_REAGENTS"], L["FINISHING_REAGENT_SLOTS"], "showFinishingReagents", D.showFinishingReagents, { id = "showFinishingReagents", visibleWhen = function() return getDB("showRecipes", D.showRecipes) and getDB("recipeReagentsFullDetail", D.recipeReagentsFullDetail) end }),
            Toggle(L["CHOICE_SLOTS"], L["COLLAPSIBLE_CHOICE_REAGENT_SLOTS"], "showChoiceSlots", D.showChoiceSlots, { id = "showChoiceSlots", visibleWhen = function() return getDB("showRecipes", D.showRecipes) and getDB("recipeReagentsFullDetail", D.recipeReagentsFullDetail) end }),
            Toggle(L["RECIPE_ICONS"], L["RECIPE_ICON_NEXT_TITLE_REQUIRES_QUEST"], "showRecipeIcons", D.showRecipeIcons, { id = "showRecipeIcons", visibleWhen = function() return getDB("showRecipes", D.showRecipes) end }),
            Toggle(L["RARITY_COLOURS"], L["COLOUR_RECIPE_TITLES_OUTPUT_ITEM_RARITY"], "recipeRarityColors", D.recipeRarityColors, { id = "recipeRarityColors", visibleWhen = function() return getDB("showRecipes", D.showRecipes) end }),
            Toggle(L["CRAFTABLE_COUNT"], L["MANY_TIMES_RECIPE_CRAFTED"], "showCraftableCount", D.showCraftableCount, { id = "showCraftableCount", visibleWhen = function() return getDB("showRecipes", D.showRecipes) end }),
            Toggle(L["QUALITY_INFO"], L["RECIPES_TIER_QUALITY_PIPS"], "showRecipeQualityInfo", D.showRecipeQualityInfo, { id = "showRecipeQualityInfo", visibleWhen = function() return getDB("showRecipes", D.showRecipes) end }),
            Toggle(L["REQUIREMENTS"], L["UNMET_CRAFTING_STATION_REQUIREMENTS"], "showRecipeRequirements", D.showRecipeRequirements, { id = "showRecipeRequirements", visibleWhen = function() return getDB("showRecipes", D.showRecipes) end }),
            Toggle(L["FOCUS_AUCTIONATOR_SEARCH"], L["FOCUS_AUCTIONATOR_SEARCH_DESC"], "showAHSearchButton", D.showAHSearchButton, { id = "showAHSearchButton", visibleWhen = function() return getDB("showRecipes", D.showRecipes) end }),
            Section(L["FOCUS_ADVENTURE_GUIDE"]),
            Toggle(L["TRAVELERS_LOG"], L["TRACKED_OBJECTIVES_ADVENTURE_GUIDE"], "showAdventureGuide", D.showAdventureGuide, { refreshIds = { "autoRemoveCompletedAdventureGuide" } }),
            Toggle(L["UNTRACK_COMPLETE"], L["AUTO_UNTRACK_FINISHED_ACTIVITIES"], "autoRemoveCompletedAdventureGuide", D.autoRemoveCompletedAdventureGuide, { id = "autoRemoveCompletedAdventureGuide", visibleWhen = function() return getDB("showAdventureGuide", D.showAdventureGuide) end }),
            Section(L["FOCUS_FLOATING_QUEST_ITEM"]),
            Toggle(L["FOCUS_SHOW_FLOATING_QUEST_ITEM"], L["FOCUS_QUICK_BUTTON_FOCUSED_QUEST_S_USABLE"], "showFloatingQuestItem", D.showFloatingQuestItem, { refreshIds = { "lockFloatingQuestItemPosition", "floatingQuestItemMode" } }),
            { type = "toggle", name = L["LOCK_ITEM_POSITION"], desc = L["FOCUS_PREVENT_DRAGGING_FLOATING_QUEST_ITEM_BUTTON"], dbKey = "lockFloatingQuestItemPosition", id = "lockFloatingQuestItemPosition", visibleWhen = function() return getDB("showFloatingQuestItem", D.showFloatingQuestItem) end, get = function() return getDB("lockFloatingQuestItemPosition", D.lockFloatingQuestItemPosition) end, set = function(v) setDB("lockFloatingQuestItemPosition", v); if addon._UpdateFloatingItemDragAnchor then addon._UpdateFloatingItemDragAnchor() end end },
            { type = "dropdown", name = L["ITEM_SOURCE"], desc = L["SUPER_TRACKED_FIRST_CURRENT_ZONE_FIRST"], dbKey = "floatingQuestItemMode", id = "floatingQuestItemMode", visibleWhen = function() return getDB("showFloatingQuestItem", D.showFloatingQuestItem) end, options = { { L["FOCUS_SUPER_TRACKED_FIRST"], "superTracked" }, { L["FOCUS_CURRENT_ZONE_FIRST"], "currentZone" } }, get = function() return getDB("floatingQuestItemMode", D.floatingQuestItemMode) end, set = function(v) setDB("floatingQuestItemMode", v) end },
        },
    },
    {
        key = "Colors",
        name = L["DASH_COLOURS"],
        desc = L["PERSONALIZE_COLOUR_PALETTE_TRACKER_TEXT_ELEMENTS"],
        moduleKey = "focus",
        options = {
            { type = "colorMatrixFull", name = L["DASH_COLOURS"], dbKey = "colorMatrix" },
        },
    },
    {
        key = "HiddenQuests",
        name = L["FOCUS_HIDDEN_QUESTS"],
        desc = L["REVIEW_MANAGE_QUESTS_YOU_MANUALLY_UNTRACKED"],
        moduleKey = "focus",
        options = {
            { type = "blacklistGrid", name = L["FOCUS_BLACKLISTED_QUESTS"], desc = L["FOCUS_QUESTS_HIDDEN_RIGHT_CLICK_UNTRACK"], tooltip = L["ENABLE_BLACKLIST_UNTRACKED_INTERACTIONS_ADD_QUEST"] },
        },
    },
}

for i = 1, #categories do
    addon.OptionCategories[#addon.OptionCategories + 1] = categories[i]
end
