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

--- Returns dropdown options for a given combo key, delegating to FocusClickConfig.
--- Custom profile uses the full action list on every combo; presets use curated COMBO_OPTIONS.
--- @param comboKey string e.g. "left", "shiftLeft"
--- @return table { {label, value}, ... }
local function GetComboActionOptions(comboKey)
    local cfg = addon.focus and addon.focus.clickConfig
    if not cfg then return {} end
    if getDB("focusClickProfile", "blizzardDefault") == "custom" and cfg.GetAllComboActionOptions then
        return cfg.GetAllComboActionOptions()
    end
    if cfg.GetComboOptions then
        return cfg.GetComboOptions(comboKey)
    end
    return {}
end

--- Returns dropdown options for the shared quest/appearance icon click action.
--- @return table { {label, value}, ... }
local function GetIconClickActionOptions()
    local cfg = addon.focus and addon.focus.clickConfig
    if cfg and cfg.GetIconActionOptions then
        return cfg.GetIconActionOptions()
    end
    return {}
end

--- Resolved action for options UI: per-combo DB when Custom (defaults match Blizzard+); else built-in preset.
--- @param comboKey string
--- @param dbKey string SavedVariables key e.g. focusClick_left
--- @return string
local function GetEffectiveFocusClickAction(comboKey, dbKey)
    local prof = getDB("focusClickProfile", "blizzardDefault")
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

--- Resolved icon click action for options UI: fixed default for presets, DB-backed for Custom.
--- @return string
local function GetEffectiveFocusIconClickAction()
    local prof = getDB("focusClickProfile", "blizzardDefault")
    if prof ~= "custom" then
        return "superTrack"
    end
    local cfg = addon.focus and addon.focus.clickConfig
    local normalizeAction = cfg and cfg.NormalizeIconAction
    local raw = getDB("focusIconClickAction", "superTrack")
    return normalizeAction and normalizeAction(raw) or raw
end

--- When true, per-combo dropdowns are read-only (preset profile selected).
--- @return boolean
local function FocusClickPresetCombosLocked()
    return getDB("focusClickProfile", "blizzardDefault") ~= "custom"
end

--- True while Focus locks click profile to Blizzard (Horizon+ / Custom hidden).
--- @return boolean
local function FocusClickProfileChoiceHidden()
    local c = addon.focus and addon.focus.clickConfig
    return c and c.profilesLockedToBlizzard
end

--- Click profile dropdown: all presets listed; when locked, only Blizzard+ is selectable (others show "Coming soon").
--- @return table
local function GetFocusClickProfileDropdownOptions()
    if FocusClickProfileChoiceHidden() then
        local soon = L["FOCUS_COMING_SOON"]
        return {
            { L["FOCUS_PROFILE_BLIZZARD_DEFAULT"],                           "blizzardDefault" },
            { (L["FOCUS_PROFILE_HORIZON_PLUS"]) .. " — " .. soon, "horizonPlus", true },
            { (L["FOCUS_PROFILE_CUSTOM"]) .. " — " .. soon, "custom", true },
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
    local v = addon.NormalizeHighlightStyle(getDB("activeQuestHighlight", "bar-left"))
    if not VALID_HIGHLIGHT_STYLES[v] then return "bar-left" end
    return v
end

local categories = {
    {
        key = "Layout",
        name = L["DASH_LAYOUT"],
        moduleKey = "focus",
        options = {
            Section(L["VISTA_POSITION_LAYOUT"]),
            { type = "toggle", name = L["FOCUS_LOCK_POSITION"], desc = L["FOCUS_PREVENT_DRAGGING_TRACKER"], dbKey = "lockPosition", get = function() return getDB("lockPosition", false) or getDB("focusDynamicWidth", false) end, set = function(v) setDB("lockPosition", v) end },
            { type = "toggle", name = L["FOCUS_GROW_UPWARD"], desc = L["FOCUS_ANCHOR_BOTTOM_LIST_GROWS_UPWARD"], dbKey = "growUp", get = function() return getDB("growUp", false) end, set = function(v) setDB("growUp", v); if addon.focus and addon.focus.layout then addon.focus.layout.scrollOffset = 0; addon.focus.layout.scrollBottomOffset = 0 end; if addon.FullLayout then addon.FullLayout() end end, refreshIds = { "growUpHeaderMode" } },
            { type = "dropdown", name = L["FOCUS_GROW_HEADER"], desc = L["KEEP_HEADER_BOTTOM_TOP_UNTIL_COLLAPSED"], tooltip = L["FOCUS_GROWING_UPWARD_KEEP_HEADER_BOTTOM_TOP"], dbKey = "growUpHeaderMode", options = { { L["FOCUS_HEADER_BOTTOM"], "always" }, { L["FOCUS_HEADER_SLIDES_COLLAPSE"], "collapse" } }, get = function() return getDB("growUpHeaderMode", "always") end, set = function(v) setDB("growUpHeaderMode", v); if addon.FullLayout then addon.FullLayout() end end, visibleWhen = function() return getDB("growUp", false) end },
            { type = "toggle", name = L["FOCUS_START_COLLAPSED"], desc = L["FOCUS_START_HEADER_SHOWN_UNTIL_YOU_EXPAND"], dbKey = "collapsed", get = function() return getDB("collapsed", false) end, set = function(v) setDB("collapsed", v) end },
            Section(L["FOCUS_DIMENSIONS"]),
            { type = "toggle", name = L["FOCUS_DYNAMIC_WIDTH"], desc = L["FOCUS_DYNAMIC_WIDTH_DESC"], dbKey = "focusDynamicWidth", get = function() return getDB("focusDynamicWidth", false) end, set = function(v) setDB("focusDynamicWidth", v); OptionsData_NotifyMainAddon() end, refreshIds = { "panelWidth", "focusDynamicWidthMax", "lockPosition" } },
            { type = "slider", name = L["FOCUS_PANEL_WIDTH"], desc = L["FOCUS_TRACKER_WIDTH_PIXELS"], dbKey = "panelWidth", min = 180, max = 800, get = function() return getDB("panelWidth", 260) end, set = function(v) setDB("panelWidth", math.max(180, math.min(800, v))) end, visibleWhen = function() return not getDB("focusDynamicWidth", false) end },
            { type = "slider", name = L["FOCUS_DYNAMIC_WIDTH_MAX"], desc = L["FOCUS_DYNAMIC_WIDTH_MAX_DESC"], dbKey = "focusDynamicWidthMax", min = 200, max = 800, get = function() return getDB("focusDynamicWidthMax", 400) end, set = function(v) setDB("focusDynamicWidthMax", math.max(200, math.min(800, v))); OptionsData_NotifyMainAddon() end, visibleWhen = function() return getDB("focusDynamicWidth", false) end },
            { type = "slider", name = L["FOCUS_MAX_CONTENT_HEIGHT"], desc = L["FOCUS_MAX_HEIGHT_OF_SCROLLABLE_LIST_PIXELS"], dbKey = "maxContentHeight", min = 200, max = 1500, get = function() return getDB("maxContentHeight", 480) end, set = function(v) setDB("maxContentHeight", math.max(200, math.min(1500, v))) end },
            { type = "toggle", name = L["FOCUS_STATIC_BACKGROUND"], desc = L["FOCUS_STATIC_BACKGROUND_DESC"], dbKey = "staticBackgroundEnabled", get = function() return getDB("staticBackgroundEnabled", false) end, set = function(v) setDB("staticBackgroundEnabled", v); if addon.FullLayout then addon.FullLayout() end end, refreshIds = { "staticPanelHeight" } },
            { type = "slider", name = L["FOCUS_STATIC_PANEL_HEIGHT"], desc = L["FOCUS_STATIC_PANEL_HEIGHT_DESC"], dbKey = "staticPanelHeight", min = 50, max = 1500, get = function() return math.max(50, math.min(1500, tonumber(getDB("staticPanelHeight", 400)) or 400)) end, set = function(v) setDB("staticPanelHeight", math.max(50, math.min(1500, v))); if addon.FullLayout then addon.FullLayout() end end, visibleWhen = function() return getDB("staticBackgroundEnabled", false) end },
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
            { type = "slider", name = L["ENTRY_SPACING"], desc = L["FOCUS_VERTICAL_GAP_BETWEEN_QUEST_ENTRIES"], dbKey = "titleSpacing", min = 2, max = 20,
                get = function()
                    local mode = addon.GetSpacingMode()
                    if mode == "custom" then
                        return math.max(2, math.min(20, tonumber(getDB("customTitleSpacing", 8)) or 8))
                    end
                    local p = addon.SPACING_PRESETS and addon.SPACING_PRESETS[mode]
                    return p and p.titleSpacing or 8
                end,
                set = function(v)
                    setDB("customTitleSpacing", math.max(2, math.min(20, v)))
                    if addon.FullLayout then addon.FullLayout() end
                end,
                disabled = function() return addon.GetSpacingMode() ~= "custom" end,
                refreshIds = { "compactMode", "titleSpacing", "objSpacing", "titleToContentSpacing", "sectionSpacing", "sectionToEntryGap", "headerToContentGap" }
            },
            { type = "slider", name = L["FOCUS_TITLE_CONTENT"], desc = L["FOCUS_VERTICAL_GAP_BETWEEN_QUEST_TITLE_OBJECTIVES"], dbKey = "titleToContentSpacing", min = 0, max = 12,
                get = function()
                    local mode = addon.GetSpacingMode()
                    if mode == "custom" then
                        return math.max(0, math.min(12, tonumber(getDB("customTitleToContentSpacing", 2)) or 2))
                    end
                    local p = addon.SPACING_PRESETS and addon.SPACING_PRESETS[mode]
                    return p and p.titleToContentSpacing or 2
                end,
                set = function(v) setDB("customTitleToContentSpacing", math.max(0, math.min(12, v))); if addon.FullLayout then addon.FullLayout() end end,
                disabled = function() return addon.GetSpacingMode() ~= "custom" end,
                refreshIds = { "compactMode", "titleSpacing", "objSpacing", "titleToContentSpacing", "sectionSpacing", "sectionToEntryGap", "headerToContentGap" }
            },
            { type = "slider", name = L["FOCUS_BEFORE_SECTION_HEADER"], desc = L["FOCUS_GAP_BETWEEN_LAST_ENTRY_OF_A"], dbKey = "sectionSpacing", min = 0, max = 24,
                get = function()
                    local mode = addon.GetSpacingMode()
                    if mode == "custom" then
                        return math.max(0, math.min(24, tonumber(getDB("customSectionSpacing", 10)) or 10))
                    end
                    local p = addon.SPACING_PRESETS and addon.SPACING_PRESETS[mode]
                    return p and p.sectionSpacing or 10
                end,
                set = function(v) setDB("customSectionSpacing", math.max(0, math.min(24, v))); if addon.FullLayout then addon.FullLayout() end end,
                disabled = function() return addon.GetSpacingMode() ~= "custom" end,
                refreshIds = { "compactMode", "titleSpacing", "objSpacing", "titleToContentSpacing", "sectionSpacing", "sectionToEntryGap", "headerToContentGap" }
            },
            { type = "slider", name = L["FOCUS_AFTER_SECTION_HEADER"], desc = L["FOCUS_GAP_BETWEEN_CATEGORY_LABEL_FIRST_QUEST"], dbKey = "sectionToEntryGap", min = 0, max = 16,
                get = function()
                    local mode = addon.GetSpacingMode()
                    if mode == "custom" then
                        return math.max(0, math.min(16, tonumber(getDB("customSectionToEntryGap", 6)) or 6))
                    end
                    local p = addon.SPACING_PRESETS and addon.SPACING_PRESETS[mode]
                    return p and p.sectionToEntryGap or 6
                end,
                set = function(v) setDB("customSectionToEntryGap", math.max(0, math.min(16, v))); if addon.FullLayout then addon.FullLayout() end end,
                disabled = function() return addon.GetSpacingMode() ~= "custom" end,
                refreshIds = { "compactMode", "titleSpacing", "objSpacing", "titleToContentSpacing", "sectionSpacing", "sectionToEntryGap", "headerToContentGap" }
            },
            { type = "slider", name = L["OBJECTIVE_SPACING"], desc = L["FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVE_LINES_WITHIN"], dbKey = "objSpacing", min = 0, max = 8,
                get = function()
                    local mode = addon.GetSpacingMode()
                    if mode == "custom" then
                        return math.max(0, math.min(8, tonumber(getDB("customObjSpacing", 2)) or 2))
                    end
                    local p = addon.SPACING_PRESETS and addon.SPACING_PRESETS[mode]
                    return p and p.objSpacing or 2
                end,
                set = function(v) setDB("customObjSpacing", math.max(0, math.min(8, v))); if addon.FullLayout then addon.FullLayout() end end,
                disabled = function() return addon.GetSpacingMode() ~= "custom" end,
                refreshIds = { "compactMode", "titleSpacing", "objSpacing", "titleToContentSpacing", "sectionSpacing", "sectionToEntryGap", "headerToContentGap" }
            },
            { type = "slider", name = L["FOCUS_BELOW_HEADER"], desc = L["FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVES_BAR_QUES"], dbKey = "headerToContentGap", min = 0, max = 24,
                get = function()
                    local mode = addon.GetSpacingMode()
                    if mode == "custom" then
                        return math.max(0, math.min(24, tonumber(getDB("customHeaderToContentGap", 6)) or 6))
                    end
                    local p = addon.SPACING_PRESETS and addon.SPACING_PRESETS[mode]
                    return p and p.headerToContentGap or 6
                end,
                set = function(v) setDB("customHeaderToContentGap", math.max(0, math.min(24, v))); if addon.FullLayout then addon.FullLayout() end end,
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
            { type = "slider", name = L["FOCUS_BACKDROP_OPACITY"], desc = L["PANEL_BACKGROUND_OPACITY"], dbKey = "backdropOpacity", min = 0, max = 100, get = function() local v = tonumber(getDB("backdropOpacity", 0)) or 0; if v <= 1 and v > 0 then return math.floor(v * 100 + 0.5) end; return math.max(0, math.min(100, v)) end, set = function(v) setDB("backdropOpacity", math.max(0, math.min(100, v)) / 100) end },
            { type = "color", name = L["VISTA_BACKDROP_COLOUR"], desc = L["VISTA_PANEL_BACKGROUND_COLOUR"], dbKey = "backdropColor", get = function() return getDB("backdropColorR", 0.08), getDB("backdropColorG", 0.08), getDB("backdropColorB", 0.12) end, set = function(r, g, b) setDB("backdropColorR", r); setDB("backdropColorG", g); setDB("backdropColorB", b) end },
            Toggle(L["FOCUS_BORDER"], L["FOCUS_BORDER_AROUND_TRACKER"], "showBorder", false),
            Toggle(L["SCROLL_INDICATOR"], L["HINT_LIST_SCROLLABLE"], "showScrollIndicator", false, { refreshIds = { "scrollIndicatorStyle" } }),
            { type = "dropdown", name = L["FOCUS_SCROLL_INDICATOR_STYLE"], desc = L["FOCUS_CHOOSE_BETWEEN_A_FADE_GRADIENT_A"], dbKey = "scrollIndicatorStyle", options = { { L["FOCUS_FADE"], "fade" }, { L["FOCUS_ARROW"], "arrow" } }, get = function() return getDB("scrollIndicatorStyle", "fade") end, set = function(v) setDB("scrollIndicatorStyle", v) end, visibleWhen = function() return getDB("showScrollIndicator", false) end },
            Section(L["VISIBILITY_FADING"]),
            { type = "dropdown", name = L["FOCUS_COMBAT_VISIBILITY"], desc = L["FOCUS_TRACKER_BEHAVES_COMBAT_FADE_REDUC"], dbKey = "combatVisibility", options = { { L["FOCUS_SHOW"], "show" }, { L["FOCUS_FADE"], "fade" }, { L["FOCUS_HIDE"], "hide" } }, get = function() return addon.GetCombatVisibility() end, set = function(v) setDB("combatVisibility", v); if addon.FullLayout then addon.FullLayout() end end, refreshIds = { "combatFadeOpacity" } },
            { type = "slider", name = L["FOCUS_COMBAT_FADE_OPACITY"], desc = L["FOCUS_VISIBLE_TRACKER_FADED_COMBAT"], dbKey = "combatFadeOpacity", min = 0, max = 100, get = function() return math.max(0, math.min(100, tonumber(getDB("combatFadeOpacity", 30)) or 30)) end, set = function(v) setDB("combatFadeOpacity", math.max(0, math.min(100, v))); if addon.FullLayout then addon.FullLayout() end end, visibleWhen = function() return addon.GetCombatVisibility() == "fade" end },
            { type = "toggle", name = L["MOUSEOVER"], desc = L["FADE_HOVERING"], dbKey = "showOnMouseoverOnly", get = function() return getDB("showOnMouseoverOnly", false) end, set = function(v) setDB("showOnMouseoverOnly", v); if addon.FullLayout then addon.FullLayout() end end, refreshIds = { "fadeOnMouseoverOpacity" } },
            { type = "slider", name = L["FOCUS_FADED_OPACITY"], desc = L["FOCUS_VISIBLE_TRACKER_FADED_INVISIBLE"], dbKey = "fadeOnMouseoverOpacity", min = 0, max = 100, get = function() return math.max(0, math.min(100, tonumber(getDB("fadeOnMouseoverOpacity", 10)) or 10)) end, set = function(v) setDB("fadeOnMouseoverOpacity", math.max(0, math.min(100, v))); if addon.FullLayout then addon.FullLayout() end end, visibleWhen = function() return getDB("showOnMouseoverOnly", false) end },
            Section(L["FOCUS_HEADER"]),
            Toggle(L["MINIMAL_MODE"], L["FOCUS_HIDE_HEADER_A_PURE_TEXT_LIST"], "hideObjectivesHeader", false, { refreshIds = { "showQuestCount", "headerCountMode", "showHeaderDivider", "headerDividerColor", "headerColor", "headerHeight", "hideOptionsButton" } }),
            Toggle(L["QUEST_COUNT"], L["FOCUS_QUEST_COUNT_HEADER"], "showQuestCount", true, { refreshIds = { "headerCountMode" }, visibleWhen = function() return not getDB("hideObjectivesHeader", false) end }),
            { type = "dropdown", name = L["FOCUS_HEADER_COUNT_FORMAT"], desc = L["TRACKED_VS_LOG_COUNT"], dbKey = "headerCountMode", options = { { L["FOCUS_TRACKED_LOG"], "trackedLog" }, { L["FOCUS_LOG_MAX_SLOTS"], "logMax" } }, get = function() return getDB("headerCountMode", "trackedLog") end, set = function(v) setDB("headerCountMode", v) end, tooltip = L["TRACKED_LOG_LOG_MAX_TRACKED_EXCLUDES"], visibleWhen = function() return not getDB("hideObjectivesHeader", false) and getDB("showQuestCount", true) end },
            Toggle(L["HEADER_DIVIDER"], L["FOCUS_LINE_BELOW_HEADER"], "showHeaderDivider", true, { refreshIds = { "headerDividerColor" }, visibleWhen = function() return not getDB("hideObjectivesHeader", false) end }),
            Color(L["FOCUS_HEADER_DIVIDER_COLOUR"], L["FOCUS_COLOUR_OF_LINE_BELOW_HEADER"], "headerDividerColor", addon.DIVIDER_COLOR, { hasAlpha = true, visibleWhen = function() return not getDB("hideObjectivesHeader", false) and getDB("showHeaderDivider", true) end }),
            Color(L["FOCUS_HEADER_COLOUR"], L["FOCUS_COLOUR_OF_OBJECTIVES_HEADER_TEXT"], "headerColor", addon.HEADER_COLOR, { visibleWhen = function() return not getDB("hideObjectivesHeader", false) end }),
            { type = "slider", name = L["FOCUS_HEADER_HEIGHT"], desc = L["FOCUS_HEIGHT_OF_HEADER_BAR_PIXELS"], dbKey = "headerHeight", min = 18, max = 48, get = function() return math.max(18, math.min(48, tonumber(getDB("headerHeight", addon.HEADER_HEIGHT)) or addon.HEADER_HEIGHT)) end, set = function(v) setDB("headerHeight", math.max(18, math.min(48, v))) end, visibleWhen = function() return not getDB("hideObjectivesHeader", false) end },
            { type = "toggle", name = L["FOCUS_OPTIONS_BUTTON"], desc = L["FOCUS_OPTIONS_BUTTON_TRACKER_HEADER"], dbKey = "hideOptionsButton", get = function() return not getDB("hideOptionsButton", false) end, set = function(v) setDB("hideOptionsButton", not v) end, visibleWhen = function() return not getDB("hideObjectivesHeader", false) end },
            Section(L["FOCUS_SECTIONS_STRUCTURE"]),
            Toggle(L["SECTION_HEADERS"], L["FOCUS_CATEGORY_LABELS_ABOVE_GROUP"], "showSectionHeaders", true),
            Toggle(L["SECTION_DIVIDERS"], L["A_VISUAL_DIVIDER_LINE_BETWEEN_FOCUS"], "showSectionDividers", false, { refreshIds = { "sectionDividerColor" } }),
            Color(L["SECTION_DIVIDER_COLOUR"], L["COLOUR_OF_DIVIDER_LINES_BETWEEN_SECTIONS"], "sectionDividerColor", { 0.3, 0.3, 0.35, 0.4 }, { hasAlpha = true, visibleWhen = function() return getDB("showSectionDividers", false) end }),
            Toggle(L["SECTIONS_COLLAPSED"], L["KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED"], "showSectionHeadersWhenCollapsed", false, { tooltip = L["FOCUS_CLICK_A_SECTION_HEADER_EXPAND_CATEGORY"] }),
            Toggle(L["ZONE_LABELS"], L["FOCUS_ZONE_NAME_UNDER_QUEST_TITLE"], "showZoneLabels", true),
            Section(L["FOCUS_ENTRY_DETAILS"]),
            Toggle(L["ENTRY_NUMBERS"], L["FOCUS_PREFIX_QUEST_TITLES_WITHIN_CATEGORY"], "showCategoryEntryNumbers", true),
            { type = "dropdown", name = L["FOCUS_OBJECTIVE_PREFIX"], desc = L["FOCUS_PREFIX_OBJECTIVE_A_NUMBER_HYPHEN"], dbKey = "objectivePrefixStyle", options = { { L["FOCUS_OUTLINE_NONE"], "none" }, { L["FOCUS_NUMBERS"], "numbers" }, { L["FOCUS_HYPHENS"], "hyphens" } }, get = function() return getDB("objectivePrefixStyle", "none") end, set = function(v) setDB("objectivePrefixStyle", v) end },
            Toggle(L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS"], L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS_DESC"], "objectiveProgressNumberColors", true),
            Toggle(L["COMPLETED_COUNT"], L["FOCUS_X_Y_PROGRESS_QUEST_TITLE"], "showCompletedCount", false),
            { type = "dropdown", name = L["FOCUS_COMPLETED_OBJECTIVES"], desc = L["DISPLAY_COMPLETED_OBJECTIVES"], tooltip = L["FOCUS_MULTI_OBJECTIVE_QUESTS_DISPLAY_OBJECTIVES"], dbKey = "questCompletedObjectiveDisplay", options = { { L["FOCUS_ALL"], "off" }, { L["FOCUS_FADE_COMPLETED"], "fade" }, { L["FOCUS_HIDE_COMPLETED"], "hide" } }, get = function() return getDB("questCompletedObjectiveDisplay", "off") end, set = function(v) setDB("questCompletedObjectiveDisplay", v) end },
            Toggle(L["FOCUS_CHECKMARK_COMPLETED"], L["CHECKMARK_COMPLETED_OBJECTIVES"], "useTickForCompletedObjectives", false, { tooltip = L["FOCUS_COMPLETED_CHECKMARK"] }),
            Toggle(L["QUEST_LEVEL"], L["FOCUS_QUEST_LEVEL_NEXT_TITLE"], "showQuestLevel", false),
            Toggle(L["QUEST_TYPE_ICONS"], L["PRESENCE_QUEST_TYPE_ICON_FOCUS_TRACKER_QUEST"], "showQuestTypeIcons", true),
            { type = "slider", name = L["FOCUS_QUEST_TYPE_ICON_SIZE"], desc = L["FOCUS_QUEST_TYPE_ICON_SIZE_DESC"], dbKey = "focusIconSize", min = 10, max = 28, get = function() return getDB("focusIconSize", 16) end, set = function(v) setDB("focusIconSize", math.max(10, math.min(28, v))) end, visibleWhen = function() return getDB("showQuestTypeIcons", true) end },
            Toggle(L["FOCUS_AUTO_TRACK_ICON"], L["ICON_NEXT_AUTO_TRACKED_ZONE_ENTRIES"], "showInZoneSuffix", true, { tooltip = L["WORLD_QUESTS_WEEKLIES_YOUR_QUEST_LOG"], refreshIds = { "autoTrackIcon" } }),
            { type = "dropdown", name = L["FOCUS_AUTO_TRACK_ICON"], desc = L["FOCUS_CHOOSE_WHICH_ICON_DISPLAY_NEXT_AUTO"], dbKey = "autoTrackIcon", options = addon.GetRadarIconOptions and addon.GetRadarIconOptions() or {}, get = function() return getDB("autoTrackIcon", "radar1") end, set = function(v) setDB("autoTrackIcon", v) end, visibleWhen = function() return getDB("showInZoneSuffix", true) end },
            { type = "dropdown", name = L["FOCUS_ACTIVE_QUEST_HIGHLIGHT"], desc = L["FOCUS_FOCUSED_QUEST_HIGHLIGHTED"], dbKey = "activeQuestHighlight", options = HIGHLIGHT_OPTIONS, get = getActiveQuestHighlight, set = function(v) setDB("activeQuestHighlight", v) end },
            { type = "toggle", name = L["QUEST_ITEM_BUTTONS"], desc = L["FOCUS_USABLE_QUEST_ITEM_BUTTON_NEXT_QUEST"], dbKey = "showQuestItemButtons", get = function() return getDB("showQuestItemButtons", false) end, set = function(v) setDB("showQuestItemButtons", v) end },
            { type = "toggle", name = L["FOCUS_TOOLTIPS_HOVER"], desc = L["FOCUS_TOOLTIPS_HOVERING_TRACKER_ENTRIES_ITE"], dbKey = "focusShowTooltipOnHover", get = function() return getDB("focusShowTooltipOnHover", false) end, set = function(v) setDB("focusShowTooltipOnHover", v) end },
            { type = "toggle", name = L["FOCUS_WOWHEAD_LINK_TOOLTIPS"], desc = L["FOCUS_A_TOOLTIP_SHOWN_ADD_A_LINK"], dbKey = "focusShowWoWheadLink", get = function() return getDB("focusShowWoWheadLink", true) end, set = function(v) setDB("focusShowWoWheadLink", v) end },
            Section(L["FOCUS_PROGRESS_TIMERS"]),
            { type = "toggle", name = L["SCENARIO_PROGRESS_BAR"], desc = L["FOCUS_BAR_UNDER_NUMERIC_OBJECTIVES"], dbKey = "showProgressBarScenarios", tooltip = L["ENTRIES_A_SINGLE_NUMERIC_OBJECTIVE_WHERE"], get = function() return getDB("showProgressBarScenarios", true) end, set = function(v)
                setDB("showProgressBarScenarios", v)
                if C_Timer and C_Timer.After and addon.OptionsPanel_Refresh then
                    C_Timer.After(0.2, addon.OptionsPanel_Refresh)
                elseif addon.OptionsPanel_Refresh then
                    addon.OptionsPanel_Refresh()
                end
            end, refreshIds = { "progressBarUseCategoryColor", "progressBarTypeFilter", "progressBarTexture" } },
            { type = "toggle", name = L["QUEST_PROGRESS_BAR"], desc = L["FOCUS_BAR_UNDER_NUMERIC_OBJECTIVES"], dbKey = "showProgressBarQuests", tooltip = L["ENTRIES_A_SINGLE_NUMERIC_OBJECTIVE_WHERE"], get = function() return getDB("showProgressBarQuests", true) end, set = function(v)
                setDB("showProgressBarQuests", v)
                if C_Timer and C_Timer.After and addon.OptionsPanel_Refresh then
                    C_Timer.After(0.2, addon.OptionsPanel_Refresh)
                elseif addon.OptionsPanel_Refresh then
                    addon.OptionsPanel_Refresh()
                end
            end, refreshIds = { "progressBarUseCategoryColor", "progressBarTypeFilter", "progressBarTexture" } },
            { type = "toggle", name = L["FOCUS_CATEGORY_COLOUR_BAR"], desc = L["MATCH_BAR_QUEST_CATEGORY_COLOUR"], dbKey = "progressBarUseCategoryColor", get = function() return getDB("progressBarUseCategoryColor", true) end, set = function(v) setDB("progressBarUseCategoryColor", v) end, visibleWhen = function() return getDB("showProgressBarScenarios", true) or getDB("showProgressBarQuests", true) or getDB("showAchievementProgressBars", false) end, tooltip = L["CUSTOM_FILL_COLOUR_BELOW"] },
            { type = "dropdown", name = L["FOCUS_PROGRESS_BAR_TYPES"], desc = L["FOCUS_PROGRESS_BAR_X_Y_OBJECTIVES_PERCENT"], dbKey = "progressBarTypeFilter", options = { { L["VISTA_SHOW_ZONE_AND_SUBZONE"], "both" }, { L["FOCUS_X_Y"], "xy_only" }, { L["FOCUS_PERCENT"], "percent_only" } }, get = function() return getDB("progressBarTypeFilter", "percent_only") end, set = function(v) setDB("progressBarTypeFilter", v) end, visibleWhen = function() return getDB("showProgressBarScenarios", true) or getDB("showProgressBarQuests", true) end, tooltip = L["X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"] },
            { type = "dropdown", name = L["FOCUS_PROGRESS_BAR_TEXTURE"], desc = L["FOCUS_TEXTURE_PROGRESS_BAR_FILL"], dbKey = "progressBarTexture", searchable = true, options = function() return addon.GetStatusbarDropdownOptions and addon.GetStatusbarDropdownOptions() or { { "Solid", "Solid" } } end, get = function() return getDB("progressBarTexture", "Solid") end, set = function(v) setDB("progressBarTexture", v); OptionsData_NotifyMainAddon() end, visibleWhen = function() return getDB("showProgressBarScenarios", true) or getDB("showProgressBarQuests", true) or getDB("showAchievementProgressBars", false) end, tooltip = L["FOCUS_TEXTURE_PROGRESS_BAR_FILL_SOLID_YOUR"] },
            Toggle(L["FOCUS_TIMER"], L["FOCUS_COUNTDOWN_TIMER_TIMED_QUESTS_EVENTS_SCEN"], "showTimerBars", true, { refreshIds = { "showTimerScenario", "showTimerWorld", "showTimerQuestTimed", "timerDisplayMode", "timerColorByRemaining" } }),
            Toggle(L["FOCUS_TIMER_SCENARIOS"], L["FOCUS_TIMER_SCENARIOS_DESC"], "showTimerScenario", true, { id = "showTimerScenario", visibleWhen = function() return getDB("showTimerBars", false) end }),
            Toggle(L["FOCUS_TIMER_WORLD"], L["FOCUS_TIMER_WORLD_DESC"], "showTimerWorld", true, { id = "showTimerWorld", visibleWhen = function() return getDB("showTimerBars", false) end }),
            Toggle(L["FOCUS_TIMER_QUEST_LOG"], L["FOCUS_TIMER_QUEST_LOG_DESC"], "showTimerQuestTimed", true, { id = "showTimerQuestTimed", visibleWhen = function() return getDB("showTimerBars", false) end }),
            { type = "dropdown", name = L["FOCUS_TIMER_DISPLAY"], desc = L["WHERE_COUNTDOWN"], dbKey = "timerDisplayMode", options = { { L["FOCUS_BAR_BELOW"], "bar" }, { L["FOCUS_INLINE_BESIDE_TITLE"], "inline" }, { L["FOCUS_INLINE_BELOW_TITLE"], "inline-below" } }, get = function() return getDB("timerDisplayMode", "inline") end, set = function(v) setDB("timerDisplayMode", v) end, visibleWhen = function() return getDB("showTimerBars", false) end },
            Toggle(L["FOCUS_COLOUR_TIMER_REMAINING"], L["COLOUR_REMAINING"], "timerColorByRemaining", true, { tooltip = L["FOCUS_GREEN_PLENTY_OF_LEFT_YELLOW_RUNNING"], visibleWhen = function() return getDB("showTimerBars", false) end }),
            Section(L["FOCUS_EMPHASIS"]),
            Toggle(L["FOCUS_DIM_UNFOCUSED_ENTRIES"], L["DIM_UNFOCUSED_TRACKER_ENTRIES"], "dimNonSuperTracked", false, { tooltip = L["FOCUS_SLIGHTLY_DIM_TITLE_ZONE_OBJECTIVES_SECTION"], refreshIds = { "dimStrength", "dimAlpha", "dimDesaturate" } }),
            { type = "slider", name = L["DIM_STRENGTH"], desc = L["DIMMING_STRENGTH"], tooltip = L["FOCUS_DIM_UNFOCUSED_ENTRIES_DESC"], dbKey = "dimStrength", min = 0, max = 100, get = function() return math.max(0, math.min(100, tonumber(getDB("dimStrength", 40)) or 40)) end, set = function(v) setDB("dimStrength", math.max(0, math.min(100, v))) end, visibleWhen = function() return getDB("dimNonSuperTracked", false) end },
            { type = "slider", name = L["DIM_ALPHA"], desc = L["OPACITY_OF_UNFOCUSED_ENTRIES"], tooltip = L["REDUCE_OPACITY_OF_FOCUSED_ENTRIES_INVISIBLE"], dbKey = "dimAlpha", min = 0, max = 100, get = function() return math.max(0, math.min(100, tonumber(getDB("dimAlpha", 100)) or 100)) end, set = function(v) setDB("dimAlpha", math.max(0, math.min(100, v))) end, visibleWhen = function() return getDB("dimNonSuperTracked", false) end },
            Toggle(L["DESATURATE_FOCUSED_QUESTS"], L["DESATURATE_FOCUSED_ENTRIES"], "dimDesaturate", false, { tooltip = L["MAKE_FOCUSED_ENTRIES_GREYSCALE_PARTIALLY_DESATURATE"], visibleWhen = function() return getDB("dimNonSuperTracked", false) end }),
            { type = "slider", name = L["FOCUS_HIGHLIGHT_ALPHA"], desc = L["OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"], dbKey = "highlightAlpha", min = 0, max = 100, get = function() local v = tonumber(getDB("highlightAlpha", 0.25)) or 0.25; if v <= 1 and v > 0 then return math.floor(v * 100 + 0.5) end; return math.max(0, math.min(100, v)) end, set = function(v) setDB("highlightAlpha", math.max(0, math.min(100, v)) / 100) end },
            { type = "slider", name = L["FOCUS_BAR_WIDTH"], desc = L["FOCUS_WIDTH_OF_BAR_STYLE_HIGHLIGHTS_PX"], dbKey = "highlightBarWidth", min = 2, max = 6, get = function() return math.max(2, math.min(6, tonumber(getDB("highlightBarWidth", 2)) or 2)) end, set = function(v) setDB("highlightBarWidth", math.max(2, math.min(6, v))) end },
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
                get = function() return getDB("focusClickProfile", "blizzardDefault") end,
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
            Toggle(L["FOCUS_CTRL_FOCUS_UNTRACK"], L["PREVENT_ACCIDENTAL_CLICKS"], "requireCtrlForQuestClicks", false, { tooltip = L["CTRL_LEFT_FOCUS_ADD_CTRL_RIGHT"] }),
            Toggle(L["FOCUS_CTRL_CLICK_COMPLETE"], L["REQUIRE_CTRL_COMPLETE_CLICK_COMPLETABLE_QUESTS"], "requireModifierForClickToComplete", false, { tooltip = L["QUESTS_DON_T_NEED_NPC_TURN"] }),
        },
    },
    {
        key = "SortingFiltering",
        name = L["SORTING_FILTERING"],
        desc = L["ORGANIZE_HIDE_TRACKED_ENTRIES_YOUR_PREFERENCE"],
        moduleKey = "focus",
        options = {
            Section(L["FOCUS_FILTERING"]),
            Toggle(L["CURRENT_ZONE"], L["FOCUS_HIDE_QUESTS_OUTSIDE_YOUR_CURRENT_ZONE"], "filterByZone", false),
            Section(L["GROUPING"]),
            { type = "toggle", name = L["FOCUS_FOCUSED_QUEST_CATEGORY"], desc = L["FOCUS_FOCUSED_QUEST_CATEGORY_DESC"], tooltip = L["FOCUS_FOCUSED_QUEST_CATEGORY_TIP"], dbKey = "showFocusedQuestCategory", isNew = "4.17.7", get = function() return getDB("showFocusedQuestCategory", true) end, set = function(v) setDB("showFocusedQuestCategory", v); if addon.RequestRefresh then addon.RequestRefresh() end; if addon.FullLayout then addon.FullLayout() end end },
            Toggle(L["FOCUS_CURRENT_QUEST_CATEGORY"], L["RECENT_PROGRESS_TOP"], "showCurrentQuestCategory", true, { tooltip = L["FOCUS_QUEST_PROGRESSION_SECTION"], refreshIds = { "currentQuestWindowSec" } }),
            { type = "slider", name = L["FOCUS_CURRENT_QUEST_WINDOW"], desc = L["SECONDS_OF_RECENT_PROGRESS"], dbKey = "currentQuestWindowSec", min = 30, max = 120, get = function() return math.max(30, math.min(120, tonumber(getDB("currentQuestWindowSec", 60)) or 60)) end, set = function(v) setDB("currentQuestWindowSec", math.max(30, math.min(120, v))) end, visibleWhen = function() return getDB("showCurrentQuestCategory", true) end, id = "currentQuestWindowSec" },
            Toggle(L["CURRENT_ZONE_GROUP"], L["DEDICATED_SECTION_ZONE_QUESTS"], "showNearbyGroup", true, { tooltip = L["ZONE_QUESTS_APPEAR_THEIR_NORMAL_CATEGORY"], refreshIds = { "nearbyCompleteToBottom" } }),
            Toggle(L["FOCUS_SHOW_ZONE_EVENTS"], L["FOCUS_SHOW_ZONE_EVENTS_DESC"], "showEventsInZone", true, { id = "showEventsInZone", tooltip = L["FOCUS_SHOW_ZONE_EVENTS_TIP"] }),
            { type = "toggle", name = L["READY_TURN_BOTTOM"], desc = L["MOVE_COMPLETED_QUESTS_BOTTOM_OF_CURRENT"], dbKey = "nearbyCompleteToBottom", get = function() return getDB("nearbyCompleteToBottom", true) end, set = function(v) setDB("nearbyCompleteToBottom", v); OptionsData_NotifyMainAddon() end, visibleWhen = function() return getDB("showNearbyGroup", true) end },
            { type = "toggle", name = L["READY_TURN_GROUP"], desc = L["DEDICATED_SECTION_COMPLETED_QUESTS"], dbKey = "showCompleteGroup", get = function() return getDB("showCompleteGroup", true) end, set = function(v) setDB("showCompleteGroup", v); if addon.RequestRefresh then addon.RequestRefresh() end; if addon.FullLayout then addon.FullLayout() end end, tooltip = L["COMPLETED_QUESTS_STAY_THEIR_ORIGINAL_CATEGO"], refreshIds = { "keepCampaignInCategory", "keepImportantInCategory" } },
            { type = "toggle", name = L["KEEP_CAMPAIGN_CATEGORY"], desc = L["KEEP_CAMPAIGN_READY_TURN"], dbKey = "keepCampaignInCategory", get = function() return getDB("keepCampaignInCategory", false) end, set = function(v) setDB("keepCampaignInCategory", v); if addon.RequestRefresh then addon.RequestRefresh() end; if addon.FullLayout then addon.FullLayout() end end, tooltip = L["THEY_MOVE_COMPLETE_SECTION"], visibleWhen = function() return getDB("showCompleteGroup", true) end, id = "keepCampaignInCategory" },
            { type = "toggle", name = L["KEEP_IMPORTANT_CATEGORY"], desc = L["KEEP_IMPORTANT_READY_TURN"], dbKey = "keepImportantInCategory", get = function() return getDB("keepImportantInCategory", false) end, set = function(v) setDB("keepImportantInCategory", v); if addon.RequestRefresh then addon.RequestRefresh() end; if addon.FullLayout then addon.FullLayout() end end, tooltip = L["THEY_MOVE_COMPLETE_SECTION"], visibleWhen = function() return getDB("showCompleteGroup", true) end, id = "keepImportantInCategory" },
            Section(L["FOCUS_SORTING"]),
            { type = "reorderList", name = L["FOCUS_CATEGORY_ORDER"], labelMap = addon.SECTION_LABELS, presets = addon.GROUP_ORDER_PRESETS, get = function() return addon.GetGroupOrder() end, set = function(order) addon.SetGroupOrder(order) end, desc = L["FOCUS_CATEGORIES_REORDER_EXCEPT_DELVES_SCENARIOS_TIP"] },
            { type = "dropdown", name = L["SORT_MODE"], desc = L["FOCUS_ENTRY_NUMBER_IN_CATEGORY"], dbKey = "entrySortMode", options = { { L["FOCUS_ALPHABETICAL"], "alpha" }, { L["FOCUS_QUEST_TYPE"], "questType" }, { L["FOCUS_ZONE"], "zone" }, { L["FOCUS_QUEST_LEVEL"], "level" } }, get = function() return getDB("entrySortMode", "questType") end, set = function(v) setDB("entrySortMode", v) end },
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
            Toggle(L["FOCUS_PER_ELEMENT_FONTS"], L["OVERRIDE_FONT_PER_ELEMENT"], "usePerElementFonts", false, { refreshIds = { "titleFontPath", "zoneFontPath", "objectiveFontPath", "sectionFontPath", "progressBarFontPath", "timerFontPath", "optionsFontPath" } }),
            { type = "dropdown", name = L["FOCUS_TITLE_FONT"], desc = L["FOCUS_FONT_FAMILY_QUEST_TITLES"], dbKey = "titleFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("titleFontPath") end, get = function() return getDB("titleFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("titleFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", false) end, id = "titleFontPath", fontPreviewInList = true },
            { type = "dropdown", name = L["VISTA_ZONE_FONT"], desc = L["FOCUS_FONT_FAMILY_ZONE_LABELS"], dbKey = "zoneFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("zoneFontPath") end, get = function() return getDB("zoneFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("zoneFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", false) end, id = "zoneFontPath", fontPreviewInList = true },
            { type = "dropdown", name = L["FOCUS_OBJECTIVE_FONT"], desc = L["FOCUS_FONT_FAMILY_OBJECTIVE_TEXT"], dbKey = "objectiveFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("objectiveFontPath") end, get = function() return getDB("objectiveFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("objectiveFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", false) end, id = "objectiveFontPath", fontPreviewInList = true },
            { type = "dropdown", name = L["FOCUS_SECTION_FONT"], desc = L["FOCUS_FONT_FAMILY_SECTION_HEADERS"], dbKey = "sectionFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("sectionFontPath") end, get = function() return getDB("sectionFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("sectionFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", false) end, id = "sectionFontPath", fontPreviewInList = true },
            { type = "dropdown", name = L["FOCUS_PROGRESS_BAR_FONT"], desc = L["FOCUS_FONT_FAMILY_PROGRESS_BAR_LABEL"], dbKey = "progressBarFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("progressBarFontPath") end, get = function() return getDB("progressBarFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("progressBarFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", false) end, id = "progressBarFontPath", fontPreviewInList = true },
            { type = "dropdown", name = L["FOCUS_TIMER_TEXT_FONT"], desc = L["FOCUS_FONT_FAMILY_TIMER_TEXT"], dbKey = "timerFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("timerFontPath") end, get = function() return getDB("timerFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("timerFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", false) end, id = "timerFontPath", fontPreviewInList = true },
            { type = "dropdown", name = L["FOCUS_OPTIONS_FONT"], desc = L["FOCUS_FONT_FAMILY_OPTIONS"], dbKey = "optionsFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("optionsFontPath") end, get = function() return getDB("optionsFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("optionsFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", false) end, id = "optionsFontPath", fontPreviewInList = true },
            Section(L["FOCUS_FONT_SIZES"]),
            Slider(L["FOCUS_GLOBAL_FONT_SIZE"], L["ADJUST_FONT_SIZES_AMOUNT"], "globalFontSizeOffset", -4, 4, 0),
            Slider(L["FOCUS_HEADER_SIZE"], L["FOCUS_HEADER_FONT_SIZE"], "headerFontSize", 8, 32, 16),
            Slider(L["FOCUS_TITLE_SIZE"], L["FOCUS_QUEST_TITLE_FONT_SIZE"], "titleFontSize", 8, 24, 13),
            Slider(L["FOCUS_OBJECTIVE_SIZE"], L["FOCUS_OBJECTIVE_TEXT_FONT_SIZE"], "objectiveFontSize", 8, 20, 11),
            Slider(L["FOCUS_ZONE_SIZE"], L["FOCUS_ZONE_LABEL_FONT_SIZE"], "zoneFontSize", 8, 18, 10),
            Slider(L["FOCUS_SECTION_SIZE"], L["FOCUS_SECTION_HEADER_FONT_SIZE"], "sectionFontSize", 8, 18, 10),
            Slider(L["FOCUS_PROGRESS_BAR_TEXT_SIZE"], L["FONT_SIZE_BAR_LABEL_BAR_HEIGHT"], "progressBarFontSize", 7, 18, 10, { tooltip = L["AFFECTS_SCENARIO_PROGRESS_TIMER_BARS"] }),
            Slider(L["FOCUS_TIMER_TEXT_SIZE"], L["FOCUS_TIMER_TEXT_FONT_SIZE"], "timerFontSize", 8, 24, 13),
            Slider(L["FOCUS_OPTIONS_TEXT_SIZE"], L["FOCUS_OPTIONS_TEXT_FONT_SIZE"], "optionsFontSize", 8, 20, 11),
            { type = "dropdown", name = L["FOCUS_OUTLINE"], desc = L["FOCUS_FONT_OUTLINE_STYLE"], dbKey = "fontOutline", options = OUTLINE_OPTIONS, preserveOrder = true, get = function() return getDB("fontOutline", "OUTLINE") end, set = function(v) setDB("fontOutline", v) end },
            Section(L["FOCUS_TEXT_CASE"]),
            { type = "dropdown", name = L["FOCUS_HEADER_TEXT_CASE"], desc = L["FOCUS_DISPLAY_CASE_HEADER"], dbKey = "headerTextCase", options = TEXT_CASE_OPTIONS, get = function() local v = getDB("headerTextCase", "upper"); return (v == "default") and "upper" or v end, set = function(v) setDB("headerTextCase", v) end },
            { type = "dropdown", name = L["FOCUS_SECTION_HEADER_CASE"], desc = L["FOCUS_DISPLAY_CASE_CATEGORY_LABELS"], dbKey = "sectionHeaderTextCase", options = TEXT_CASE_OPTIONS, get = function() local v = getDB("sectionHeaderTextCase", "proper"); return (v == "default") and "proper" or v end, set = function(v) setDB("sectionHeaderTextCase", v) end },
            { type = "dropdown", name = L["FOCUS_QUEST_TITLE_CASE"], desc = L["FOCUS_DISPLAY_CASE_QUEST_TITLES"], dbKey = "questTitleCase", options = TEXT_CASE_OPTIONS, get = function() local v = getDB("questTitleCase", "proper"); return (v == "default") and "proper" or v end, set = function(v) setDB("questTitleCase", v) end },
            Section(L["FOCUS_SHADOW"]),
            Toggle(L["FOCUS_TEXT_SHADOW"], L["FOCUS_ENABLE_DROP_SHADOW_TEXT"], "showTextShadow", true, { refreshIds = { "shadowOffsetX", "shadowOffsetY", "shadowAlpha" } }),
            Slider(L["FOCUS_SHADOW_X"], L["FOCUS_HORIZONTAL_SHADOW_OFFSET"], "shadowOffsetX", -10, 10, 2, { visibleWhen = function() return getDB("showTextShadow", true) end, id = "shadowOffsetX" }),
            Slider(L["FOCUS_SHADOW_Y"], L["FOCUS_VERTICAL_SHADOW_OFFSET"], "shadowOffsetY", -10, 10, -2, { visibleWhen = function() return getDB("showTextShadow", true) end, id = "shadowOffsetY" }),
            { type = "slider", name = L["FOCUS_SHADOW_ALPHA"], desc = L["SHADOW_OPACITY"], dbKey = "shadowAlpha", min = 0, max = 100, get = function() local v = tonumber(getDB("shadowAlpha", 0.8)) or 0.8; if v <= 1 and v > 0 then return math.floor(v * 100 + 0.5) end; return math.max(0, math.min(100, v)) end, set = function(v) setDB("shadowAlpha", math.max(0, math.min(100, v)) / 100) end, visibleWhen = function() return getDB("showTextShadow", true) end, id = "shadowAlpha" },
        },
    },
    {
        key = "Interactions",
        name = L["FOCUS_INTERACTIONS"],
        desc = L["FOCUS_INTERACTIONS_TAB_DESC"],
        moduleKey = "focus",
        options = {
            Section(L["QUEST_TRACKING"]),
            Toggle(L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS"], L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS_TIP"], "autoTrackOnAccept", true),
            Toggle(L["FOCUS_SUPPRESS_UNTRACKED_UNTIL_RELOAD"], L["HIDE_UNTRACKED_QUESTS_UNTIL_RELOAD"], "suppressUntrackedUntilReload", false, { tooltip = L["FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS"] }),
            Toggle(L["FOCUS_BLACKLIST_UNTRACKED"], L["PERMANENTLY_HIDE_UNTRACKED_QUESTS"], "permanentlySuppressUntracked", false, { tooltip = L["TAKES_PRIORITY_SUPPRESS_UNTIL_RELOAD_ACCEPTING"] }),
            Section(L["NAME_TOMTOM"]),
            Toggle(L["FOCUS_TOMTOM_QUEST_WAYPOINT"], L["FOCUS_TOMTOM_QUEST_WAYPOINT_TIP"], "tomtomQuestWaypoint", false, { tooltip = L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_NEXT_QUEST"] }),
            Toggle(L["FOCUS_TOMTOM_RARE_WAYPOINT"], L["FOCUS_TOMTOM_WAYPOINT_RARE_CLICK"], "tomtomRareWaypoint", true, { tooltip = L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_RARE"] }),
        },
    },
    {
        key = "Animations",
        name = L["FOCUS_ANIMATIONS"],
        desc = L["TUNE_SLIDE_FADE_EFFECTS_PLUS_OBJECTIVE"],
        moduleKey = "focus",
        options = {
            Section(L["FOCUS_ANIMATIONS"]),
            Toggle(L["FOCUS_ANIMATIONS"], L["FOCUS_SLIDE_FADE_QUESTS"], "animations", true),
            Section(L["OBJECTIVE_PROGRESS"]),
            Toggle(L["FOCUS_OBJECTIVE_PROGRESS_FLASH"], L["FOCUS_FLASH_OBJECTIVE_COMPLETION"], "objectiveProgressFlash", true, { refreshIds = { "objectiveProgressFlashIntensity", "objectiveProgressFlashColor" } }),
            { type = "dropdown", name = L["FOCUS_FLASH_INTENSITY"], desc = L["FOCUS_OBJECTIVE_PROGRESS_FLASH_VISIBILITY"], dbKey = "objectiveProgressFlashIntensity", id = "objectiveProgressFlashIntensity", visibleWhen = function() return getDB("objectiveProgressFlash", true) end, options = { { L["FOCUS_SUBTLE"], "subtle" }, { L["FOCUS_MEDIUM"], "medium" }, { L["FOCUS_STRONG"], "strong" } }, get = function() return getDB("objectiveProgressFlashIntensity", "subtle") end, set = function(v) setDB("objectiveProgressFlashIntensity", v) end },
            Color(L["FOCUS_FLASH_COLOUR"], L["FOCUS_FLASH_COLOUR_DESC"], "objectiveProgressFlashColor", { 1, 1, 1 }, { id = "objectiveProgressFlashColor", visibleWhen = function() return getDB("objectiveProgressFlash", true) end }),
        },
    },
    {
        key = "Instances",
        name = L["FOCUS_INSTANCES"],
        desc = L["CONTROL_TRACKER_VISIBILITY_WITHIN_DUNGEONS_RAIDS"],
        moduleKey = "focus",
        options = {
            Section(L["DASH_VISIBILITY"]),
            Toggle(L["DUNGEON"], L["TRACKER_PARTY_DUNGEONS"], "showInDungeon", true, { refreshIds = { "showInDungeonNormal", "showInDungeonHeroic", "showInDungeonMythic", "showInDungeonMythicPlus" } }),
            { type = "toggle", name = L["NORMAL_DUNGEON"], desc = L["NORMAL_DUNGEONS"], tooltip = L["TRACKER_NORMAL_DUNGEONS"], dbKey = "showInDungeonNormal", id = "showInDungeonNormal", visibleWhen = function() return getDB("showInDungeon", true) end, get = function() local v = getDB("showInDungeonNormal", nil); if v ~= nil then return v end; return getDB("showInDungeon", true) end, set = function(v) setDB("showInDungeonNormal", v) end },
            { type = "toggle", name = L["HEROIC_DUNGEON"], desc = L["TRACKER_HEROIC_DUNGEONS"], dbKey = "showInDungeonHeroic", id = "showInDungeonHeroic", visibleWhen = function() return getDB("showInDungeon", true) end, get = function() local v = getDB("showInDungeonHeroic", nil); if v ~= nil then return v end; return getDB("showInDungeon", true) end, set = function(v) setDB("showInDungeonHeroic", v) end },
            { type = "toggle", name = L["MYTHIC_DUNGEON"], desc = L["TRACKER_MYTHIC_DUNGEONS"], dbKey = "showInDungeonMythic", id = "showInDungeonMythic", visibleWhen = function() return getDB("showInDungeon", true) end, get = function() local v = getDB("showInDungeonMythic", nil); if v ~= nil then return v end; return getDB("showInDungeon", true) end, set = function(v) setDB("showInDungeonMythic", v) end },
            { type = "toggle", name = L["MYTHIC_PLUS_DUNGEON"], desc = L["TRACKER_MYTHIC_KEYSTONES"], dbKey = "showInDungeonMythicPlus", id = "showInDungeonMythicPlus", visibleWhen = function() return getDB("showInDungeon", true) end, get = function() local v = getDB("showInDungeonMythicPlus", nil); if v ~= nil then return v end; return getDB("showInDungeon", true) end, set = function(v) setDB("showInDungeonMythicPlus", v) end },
            Toggle(L["RAID"], L["TRACKER_RAIDS_ALL"], "showInRaid", false, { refreshIds = { "showInRaidLFR", "showInRaidNormal", "showInRaidHeroic", "showInRaidMythic" } }),
            { type = "toggle", name = L["LFR"], desc = L["TRACKER_LFR_RAID"], dbKey = "showInRaidLFR", id = "showInRaidLFR", visibleWhen = function() return getDB("showInRaid", false) end, get = function() local v = getDB("showInRaidLFR", nil); if v ~= nil then return v end; return getDB("showInRaid", false) end, set = function(v) setDB("showInRaidLFR", v) end },
            { type = "toggle", name = L["NORMAL_RAID"], desc = L["TRACKER_NORMAL_RAIDS"], dbKey = "showInRaidNormal", id = "showInRaidNormal", visibleWhen = function() return getDB("showInRaid", false) end, get = function() local v = getDB("showInRaidNormal", nil); if v ~= nil then return v end; return getDB("showInRaid", false) end, set = function(v) setDB("showInRaidNormal", v) end },
            { type = "toggle", name = L["HEROIC_RAID"], desc = L["TRACKER_HEROIC_RAIDS"], dbKey = "showInRaidHeroic", id = "showInRaidHeroic", visibleWhen = function() return getDB("showInRaid", false) end, get = function() local v = getDB("showInRaidHeroic", nil); if v ~= nil then return v end; return getDB("showInRaid", false) end, set = function(v) setDB("showInRaidHeroic", v) end },
            { type = "toggle", name = L["MYTHIC_RAID"], desc = L["TRACKER_MYTHIC_RAIDS"], dbKey = "showInRaidMythic", id = "showInRaidMythic", visibleWhen = function() return getDB("showInRaid", false) end, get = function() local v = getDB("showInRaidMythic", nil); if v ~= nil then return v end; return getDB("showInRaid", false) end, set = function(v) setDB("showInRaidMythic", v) end },
            Toggle(L["BATTLEGROUND"], L["FOCUS_TRACKER_BATTLEGROUNDS"], "showInBattleground", false),
            Toggle(L["ARENA"], L["FOCUS_TRACKER_ARENAS"], "showInArena", false),
            Section(L["MYTHIC_BLOCK"]),
            Toggle(L["ENABLE_M_BLOCK"], L["FOCUS_TIMER_COMPLETION_AFFIXES_MYTHIC_DUNGEONS"], "showMythicPlusBlock", true, { refreshIds = { "mplusAlwaysShow", "mplusShowAffixIcons", "mplusShowAffixDescriptions", "mplusShowSplitTimer", "mplusBlockPosition", "mplusBossCompletedDisplay" } }),
            { type = "toggle", name = L["FOCUS_SHOW_SPLIT_TIMER"], desc = L["FOCUS_SHOW_SPLIT_TIMER_DESC"], dbKey = "mplusShowSplitTimer", id = "mplusShowSplitTimer", visibleWhen = function() return getDB("showMythicPlusBlock", true) end, get = function() return getDB("mplusShowSplitTimer", true) end, set = function(v) setDB("mplusShowSplitTimer", v); if addon.UpdateMplusBlock then addon.UpdateMplusBlock() end end },
            { type = "toggle", name = L["ALWAYS"], desc = L["ALWAYS_M_TIMER"], tooltip = L["M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"], dbKey = "mplusAlwaysShow", id = "mplusAlwaysShow", visibleWhen = function() return getDB("showMythicPlusBlock", true) end, get = function() return getDB("mplusAlwaysShow", false) end, set = function(v) setDB("mplusAlwaysShow", v); if addon.FullLayout then addon.FullLayout() end end },
            Toggle(L["AFFIX_ICONS"], L["FOCUS_AFFIX_ICONS_NEXT_MODIFIER_NAMES_M"], "mplusShowAffixIcons", true, { id = "mplusShowAffixIcons", visibleWhen = function() return getDB("showMythicPlusBlock", true) end }),
            Toggle(L["AFFIX_TOOLTIPS"], L["FOCUS_AFFIX_DESCRIPTIONS_HOVERING_M_BLO"], "mplusShowAffixDescriptions", true, { id = "mplusShowAffixDescriptions", visibleWhen = function() return getDB("showMythicPlusBlock", true) end }),
            { type = "dropdown", name = L["BLOCK_POSITION"], desc = L["FOCUS_POSITION_OF_MYTHIC_BLOCK_RELATIVE_QUEST"], dbKey = "mplusBlockPosition", id = "mplusBlockPosition", visibleWhen = function() return getDB("showMythicPlusBlock", true) end, options = MPLUS_POSITION_OPTIONS, get = function() return getDB("mplusBlockPosition", "top") end, set = function(v) setDB("mplusBlockPosition", v) end },
            { type = "dropdown", name = L["COMPLETED_BOSS_STYLE"], desc = L["DEFEATED_BOSS_STYLE"], tooltip = L["FOCUS_DEFEATED_BOSSES_CHECKMARK_ICON_GREEN"], dbKey = "mplusBossCompletedDisplay", id = "mplusBossCompletedDisplay", visibleWhen = function() return getDB("showMythicPlusBlock", true) end, options = { { L["FOCUS_CHECKMARK"], "tick" }, { L["FOCUS_GREEN_COLOUR"], "green" } }, get = function() return getDB("mplusBossCompletedDisplay", "tick") end, set = function(v) setDB("mplusBossCompletedDisplay", v); if addon.UpdateMplusBlock then addon.UpdateMplusBlock() end end },
            Section(L["FOCUS_MYTHIC_TYPOGRAPHY"], { defaultCollapsed = true }),
            { type = "slider", name = L["FOCUS_DUNGEON_NAME_SIZE"], desc = L["FOCUS_FONT_SIZE_DUNGEON_NAME_PX"], dbKey = "mplusDungeonSize", min = 8, max = 32, step = 1, get = function() return math.max(8, math.min(32, tonumber(getDB("mplusDungeonSize", 14)) or 14)) end, set = function(v) setDB("mplusDungeonSize", math.max(8, math.min(32, v))) end },
            { type = "slider", name = L["FOCUS_TIMER_SIZE"], desc = L["FOCUS_FONT_SIZE_TIMER_PX"], dbKey = "mplusTimerSize", min = 8, max = 32, step = 1, get = function() return math.max(8, math.min(32, tonumber(getDB("mplusTimerSize", 13)) or 13)) end, set = function(v) setDB("mplusTimerSize", math.max(8, math.min(32, v))) end },
            { type = "slider", name = L["FOCUS_SPLIT_TIMER_SIZE"], desc = L["FOCUS_FONT_SIZE_SPLIT_TIMER_PX"], dbKey = "mplusSplitSize", min = 8, max = 32, step = 1, get = function() return math.max(8, math.min(32, tonumber(getDB("mplusSplitSize", 12)) or 12)) end, set = function(v) setDB("mplusSplitSize", math.max(8, math.min(32, v))) end },
            { type = "slider", name = L["ENEMY_FORCES_SIZE"], desc = L["FOCUS_FONT_SIZE_ENEMY_FORCES_PX"], dbKey = "mplusProgressSize", min = 8, max = 32, step = 1, get = function() return math.max(8, math.min(32, tonumber(getDB("mplusProgressSize", 12)) or 12)) end, set = function(v) setDB("mplusProgressSize", math.max(8, math.min(32, v))) end },
            { type = "slider", name = L["FOCUS_AFFIX_SIZE"], desc = L["FOCUS_FONT_SIZE_AFFIXES_PX"], dbKey = "mplusAffixSize", min = 8, max = 32, step = 1, get = function() return math.max(8, math.min(32, tonumber(getDB("mplusAffixSize", 12)) or 12)) end, set = function(v) setDB("mplusAffixSize", math.max(8, math.min(32, v))) end },
            { type = "slider", name = L["FOCUS_BOSS_SIZE"], desc = L["FOCUS_FONT_SIZE_BOSS_NAMES_PX"], dbKey = "mplusBossSize", min = 8, max = 32, step = 1, get = function() return math.max(8, math.min(32, tonumber(getDB("mplusBossSize", 12)) or 12)) end, set = function(v) setDB("mplusBossSize", math.max(8, math.min(32, v))) end },
            Section(L["MYTHIC_COLOURS"], { defaultCollapsed = true }),
            { type = "color", name = L["FOCUS_DUNGEON_NAME_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_DUNGEON_NAME"], dbKey = "mplusDungeonColor", get = function() return getDB("mplusDungeonColorR", 0.96), getDB("mplusDungeonColorG", 0.96), getDB("mplusDungeonColorB", 1.0) end, set = function(r, g, b) setDB("mplusDungeonColorR", r); setDB("mplusDungeonColorG", g); setDB("mplusDungeonColorB", b) end },
            { type = "color", name = L["FOCUS_TIMER_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_TIMER"], dbKey = "mplusTimerColor", get = function() return getDB("mplusTimerColorR", 0.6), getDB("mplusTimerColorG", 0.88), getDB("mplusTimerColorB", 1.0) end, set = function(r, g, b) setDB("mplusTimerColorR", r); setDB("mplusTimerColorG", g); setDB("mplusTimerColorB", b) end },
            { type = "color", name = L["FOCUS_TIMER_OVERTIME_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_TIMER_LIMIT"], dbKey = "mplusTimerOvertimeColor", get = function() return getDB("mplusTimerOvertimeColorR", 0.9), getDB("mplusTimerOvertimeColorG", 0.25), getDB("mplusTimerOvertimeColorB", 0.2) end, set = function(r, g, b) setDB("mplusTimerOvertimeColorR", r); setDB("mplusTimerOvertimeColorG", g); setDB("mplusTimerOvertimeColorB", b) end },
            { type = "color", name = L["FOCUS_SPLIT_TIMER_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_SPLIT_TIMER"], dbKey = "mplusSplitColor", get = function() return getDB("mplusSplitColorR", 0.85), getDB("mplusSplitColorG", 0.90), getDB("mplusSplitColorB", 0.55) end, set = function(r, g, b) setDB("mplusSplitColorR", r); setDB("mplusSplitColorG", g); setDB("mplusSplitColorB", b) end },
            { type = "color", name = L["FOCUS_SPLIT_TIMER_PAST_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_SPLIT_TIMER_PAST"], dbKey = "mplusSplitPastColor", get = function() return getDB("mplusSplitPastColorR", 0.40), getDB("mplusSplitPastColorG", 0.40), getDB("mplusSplitPastColorB", 0.40) end, set = function(r, g, b) setDB("mplusSplitPastColorR", r); setDB("mplusSplitPastColorG", g); setDB("mplusSplitPastColorB", b) end },
            { type = "color", name = L["ENEMY_FORCES_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_ENEMY_FORCES"], dbKey = "mplusProgressColor", get = function() return getDB("mplusProgressColorR", 0.72), getDB("mplusProgressColorG", 0.76), getDB("mplusProgressColorB", 0.88) end, set = function(r, g, b) setDB("mplusProgressColorR", r); setDB("mplusProgressColorG", g); setDB("mplusProgressColorB", b) end },
            { type = "color", name = L["FOCUS_BAR_FILL_COLOUR"], desc = L["FOCUS_PROGRESS_BAR_FILL_COLOUR_PROGRESS"], dbKey = "mplusBarColor", get = function() return getDB("mplusBarColorR", 0.20), getDB("mplusBarColorG", 0.45), getDB("mplusBarColorB", 0.60), getDB("mplusBarColorA", 0.90) end, set = function(r, g, b, a) setDB("mplusBarColorR", r); setDB("mplusBarColorG", g); setDB("mplusBarColorB", b); if a then setDB("mplusBarColorA", a) end end, hasAlpha = true },
            { type = "color", name = L["FOCUS_BAR_COMPLETE_COLOUR"], desc = L["FOCUS_PROGRESS_BAR_FILL_COLOUR_ENEMY_FORCES"], dbKey = "mplusBarDoneColor", get = function() return getDB("mplusBarDoneColorR", 0.15), getDB("mplusBarDoneColorG", 0.65), getDB("mplusBarDoneColorB", 0.25), getDB("mplusBarDoneColorA", 0.90) end, set = function(r, g, b, a) setDB("mplusBarDoneColorR", r); setDB("mplusBarDoneColorG", g); setDB("mplusBarDoneColorB", b); if a then setDB("mplusBarDoneColorA", a) end end, hasAlpha = true },
            { type = "color", name = L["FOCUS_AFFIX_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_AFFIXES"], dbKey = "mplusAffixColor", get = function() return getDB("mplusAffixColorR", 0.85), getDB("mplusAffixColorG", 0.85), getDB("mplusAffixColorB", 0.95) end, set = function(r, g, b) setDB("mplusAffixColorR", r); setDB("mplusAffixColorG", g); setDB("mplusAffixColorB", b) end },
            { type = "color", name = L["FOCUS_BOSS_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_BOSS_NAMES"], dbKey = "mplusBossColor", get = function() return getDB("mplusBossColorR", 0.78), getDB("mplusBossColorG", 0.82), getDB("mplusBossColorB", 0.92) end, set = function(r, g, b) setDB("mplusBossColorR", r); setDB("mplusBossColorG", g); setDB("mplusBossColorB", b) end },
            Button(L["RESET_MYTHIC_STYLING"], nil, function()
                setDB("mplusDungeonSize", 14)
                setDB("mplusDungeonColorR", 0.96); setDB("mplusDungeonColorG", 0.96); setDB("mplusDungeonColorB", 1.0)
                setDB("mplusTimerSize", 13)
                setDB("mplusTimerColorR", 0.6); setDB("mplusTimerColorG", 0.88); setDB("mplusTimerColorB", 1.0)
                setDB("mplusTimerOvertimeColorR", 0.9); setDB("mplusTimerOvertimeColorG", 0.25); setDB("mplusTimerOvertimeColorB", 0.2)
                setDB("mplusSplitSize", 12)
                setDB("mplusSplitColorR", 0.85); setDB("mplusSplitColorG", 0.90); setDB("mplusSplitColorB", 0.55)
                setDB("mplusSplitPastColorR", 0.40); setDB("mplusSplitPastColorG", 0.40); setDB("mplusSplitPastColorB", 0.40)
                setDB("mplusProgressSize", 12)
                setDB("mplusProgressColorR", 0.72); setDB("mplusProgressColorG", 0.76); setDB("mplusProgressColorB", 0.88)
                setDB("mplusBarColorR", 0.20); setDB("mplusBarColorG", 0.45); setDB("mplusBarColorB", 0.60); setDB("mplusBarColorA", 0.90)
                setDB("mplusBarDoneColorR", 0.15); setDB("mplusBarDoneColorG", 0.65); setDB("mplusBarDoneColorB", 0.25); setDB("mplusBarDoneColorA", 0.90)
                setDB("mplusAffixSize", 12)
                setDB("mplusAffixColorR", 0.85); setDB("mplusAffixColorG", 0.85); setDB("mplusAffixColorB", 0.95)
                setDB("mplusBossSize", 12)
                setDB("mplusBossColorR", 0.78); setDB("mplusBossColorG", 0.82); setDB("mplusBossColorB", 0.92)
            end, { refreshIds = { "mplusDungeonSize", "mplusDungeonColor", "mplusTimerSize", "mplusTimerColor", "mplusTimerOvertimeColor", "mplusSplitSize", "mplusSplitColor", "mplusSplitPastColor", "mplusProgressSize", "mplusProgressColor", "mplusBarColor", "mplusBarDoneColor", "mplusAffixSize", "mplusAffixColor", "mplusBossSize", "mplusBossColor" } }),
            Section(L["FOCUS_DELVES_DUNGEONS"]),
            Toggle(L["SCENARIO_EVENTS"], L["FOCUS_TRACK_DELVE_DUNGEON_SCENARIO_ACTIVITIES"], "showScenarioEvents", true, { tooltip = L["FOCUS_DELVES_APPEAR_DELVES_SECTION_DUNGEONS_DUNGEON"] }),
            Toggle(L["ACTIVE_INSTANCE"], L["ACTIVE_INSTANCE_SECTION"], "hideOtherCategoriesInDelve", false, { tooltip = L["HIDES_CATEGORIES_WHILE_A_DELVE_PARTY"] }),
            { type = "toggle", name = L["FOCUS_DELVE_AFFIX_NAMES"], desc = L["AFFIX_NAMES_FIRST_DELVE_ENTRY"], dbKey = "showDelveAffixes", get = function() return getDB("showDelveAffixes", getDB("delveBlockShowAffixes", true)) end, set = function(v) setDB("showDelveAffixes", v); if addon.ScheduleRefresh then addon.ScheduleRefresh() end end, tooltip = L["APPEAR_FULL_TRACKER_REPLACEMENTS"] },
            { type = "toggle", name = L["FOCUS_RITUAL_SITE_TITLE_COUNTERS"], desc = L["FOCUS_RITUAL_SITE_TITLE_COUNTERS_DESC"], dbKey = "showScenarioHeaderCurrenciesInTitle", get = function() return getDB("showScenarioHeaderCurrenciesInTitle", true) end, set = function(v) setDB("showScenarioHeaderCurrenciesInTitle", v); if addon.RequestRefresh then addon.RequestRefresh() end; if addon.FullLayout then addon.FullLayout() end end, tooltip = L["FOCUS_RITUAL_SITE_TITLE_COUNTERS_TOOLTIP"] },
            Section(L["FOCUS_SCENARIO_BAR"]),
            Toggle(L["SCENARIO_TIMER_BAR"], L["FOCUS_TIMER_PROGRESS_BAR_SCENARIO_ENTRIES"], "cinematicScenarioBar", true),
        },
    },
    {
        key = "ContentTypes",
        name = L["FOCUS_CONTENT"],
        desc = L["TOGGLE_TRACKING_WORLD_QUESTS_RARES_ACHIEVEMENTS"],
        moduleKey = "focus",
        options = {
            Section(L["FOCUS_WORLD_QUESTS"]),
            Toggle(L["ZONE_WORLD_QUESTS"], L["AUTO_ADD_WQS_YOUR_CURRENT_ZONE"], "showWorldQuests", true, { tooltip = L["TRACKED_NEARBY_WQS_APPEAR_BLIZZARD_DEFAULT"] }),
            Section(L["FOCUS_RARE_BOSSES"]),
            Toggle(L["FOCUS_RARE_BOSSES"], L["UI_RARE_BOSS_VIGNETTES_LIST"], "showRareBosses", true),
            Toggle(L["UI_RARE_LOOT"], L["UI_TREASURE_ITEM_VIGNETTES_RARE_LOOT"], "showRareLoot", false),
            Toggle(L["RARE_SOUND_ALERT"], L["UI_PLAY_A_SOUND_A_RARE"], "rareAddedSound", true, { refreshIds = { "rareAddedSoundChoice", "rareAddedSoundVolume" } }),
            { type = "dropdown", name = L["RARE_ADDED_SOUND_CHOICE"], desc = L["SOUND_PLAYED_A_RARE_BOSS_APPEARS"], tooltip = L["CHOOSE_WHICH_SOUND_PLAY_A_RARE"], dbKey = "rareAddedSoundChoice", options = function() return addon.GetSoundDropdownOptions and addon.GetSoundDropdownOptions() or { { "Default", "default" } } end, get = function() return getDB("rareAddedSoundChoice", "default") end, set = function(v) setDB("rareAddedSoundChoice", v); if addon.PlayRareAddedSound then addon.PlayRareAddedSound() end end, visibleWhen = function() return getDB("rareAddedSound", true) end },
            { type = "slider", name = L["UI_RARE_SOUND_VOLUME"], desc = L["UI_VOLUME_OF_RARE_ALERT_SOUND"], tooltip = L["UI_BOOST_REDUCE_RARE_ALERT_VOLUME"], dbKey = "rareAddedSoundVolume", min = 50, max = 200, get = function() return math.max(50, math.min(200, tonumber(getDB("rareAddedSoundVolume", 100)) or 100)) end, set = function(v) setDB("rareAddedSoundVolume", math.max(50, math.min(200, v))) end, visibleWhen = function() return getDB("rareAddedSound", true) end, id = "rareAddedSoundVolume" },
            Section(L["FOCUS_ACHIEVEMENTS"]),
            Toggle(L["FOCUS_ACHIEVEMENTS"], L["FOCUS_TRACKED_ACHIEVEMENTS_LIST"], "showAchievements", true, { refreshIds = { "showCompletedAchievements", "showAchievementIcons", "achievementOnlyMissingRequirements", "showAchievementProgressBars" } }),
            Toggle(L["INCLUDE_COMPLETED"], L["COMPLETED_ACHIEVEMENTS_LIST"], "showCompletedAchievements", false, { id = "showCompletedAchievements", visibleWhen = function() return getDB("showAchievements", true) end, tooltip = L["PROGRESS_TRACKED_ACHIEVEMENTS_SHOWN"] }),
            Toggle(L["ACHIEVEMENT_ICONS"], L["ICON_NEXT_ACHIEVEMENT_TITLE"], "showAchievementIcons", true, { id = "showAchievementIcons", visibleWhen = function() return getDB("showAchievements", true) end, tooltip = L["REQUIRES_QUEST_TYPE_ICONS_ENABLED_DISPLAY"] }),
            Toggle(L["MISSING_CRITERIA"], L["INCOMPLETE_CRITERIA"], "achievementOnlyMissingRequirements", false, { id = "achievementOnlyMissingRequirements", visibleWhen = function() return getDB("showAchievements", true) end, tooltip = L["FOCUS_CRITERIA_YOU_HAVEN_T_COMPLETED_TR"] }),
            { type = "toggle", name = L["FOCUS_ACHIEVEMENT_PROGRESS_BARS"], desc = L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_DESC"], dbKey = "showAchievementProgressBars", id = "showAchievementProgressBars", visibleWhen = function() return getDB("showAchievements", true) end, get = function() return getDB("showAchievementProgressBars", false) end, set = function(v) setDB("showAchievementProgressBars", v); OptionsData_NotifyMainAddon() end, tooltip = L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_TIP"] },
            Section(L["FOCUS_ENDEAVORS"]),
            Toggle(L["FOCUS_SHOW_ENDEAVORS"], L["FOCUS_TRACKED_ENDEAVORS_PLAYER_HOUSING_LIST"], "showEndeavors", true, { refreshIds = { "showCompletedEndeavors" } }),
            Toggle(L["INCLUDE_COMPLETED"], L["FOCUS_INCLUDE_COMPLETED_ENDEAVORS_TRACKER"], "showCompletedEndeavors", false, { id = "showCompletedEndeavors", visibleWhen = function() return getDB("showEndeavors", true) end }),
            Section(L["FOCUS_DECOR"]),
            Toggle(L["FOCUS_SHOW_DECOR"], L["FOCUS_TRACKED_HOUSING_DECOR_LIST"], "showDecor", true, { refreshIds = { "showDecorIcons" } }),
            Toggle(L["DECOR_ICONS"], L["FOCUS_DECOR_ITEM_S_ICON_NEXT_TITLE"], "showDecorIcons", true, { id = "showDecorIcons", visibleWhen = function() return getDB("showDecor", true) end }),
            Section(L["FOCUS_APPEARANCES"]),
            Toggle(L["FOCUS_SHOW_APPEARANCES"], L["FOCUS_TRACKED_TRANSMOG_APPEARANCES_LIST"], "showAppearances", true, { refreshIds = { "showAppearanceIcons", "showCollectedAppearances" } }),
            Toggle(L["INCLUDE_COMPLETED"], L["FOCUS_INCLUDE_COLLECTED_APPEARANCES_TRACKER"], "showCollectedAppearances", false, { id = "showCollectedAppearances", visibleWhen = function() return getDB("showAppearances", true) end }),
            Toggle(L["FOCUS_APPEARANCE_ICONS"], L["FOCUS_APPEARANCE_ICON_NEXT_TITLE"], "showAppearanceIcons", true, { id = "showAppearanceIcons", visibleWhen = function() return getDB("showAppearances", true) end, tooltip = L["REQUIRES_QUEST_TYPE_ICONS_ENABLED_DISPLAY"] }),
            Toggle(L["FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON"], L["FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON_DESC"], "appearanceIconsUseTransmogTypeIcon", true, { id = "appearanceIconsUseTransmogTypeIcon", visibleWhen = function() return getDB("showAppearances", true) and getDB("showAppearanceIcons", true) end, tooltip = L["REQUIRES_QUEST_TYPE_ICONS_ENABLED_DISPLAY"] }),
            Section(L["RECIPES"]),
            Toggle(L["RECIPES"], L["TRACKED_PROFESSION_RECIPES_LIST"], "showRecipes", true, { refreshIds = { "showRecipeReagents", "recipeReagentsFullDetail", "showOptionalReagents", "showFinishingReagents", "showChoiceSlots", "showRecipeIcons", "recipeRarityColors", "showCraftableCount", "showRecipeQualityInfo", "showRecipeRequirements" } }),
            Toggle(L["REAGENTS"], L["REAGENT_SHOPPING_LIST_RECIPE"], "showRecipeReagents", true, { id = "showRecipeReagents", visibleWhen = function() return getDB("showRecipes", true) end }),
            Toggle(L["FOCUS_RECIPE_REAGENTS_FULL_DETAIL"], L["FOCUS_RECIPE_REAGENTS_FULL_DETAIL_DESC"], "recipeReagentsFullDetail", false, { id = "recipeReagentsFullDetail", visibleWhen = function() return getDB("showRecipes", true) and getDB("showRecipeReagents", true) end, refreshIds = { "showOptionalReagents", "showFinishingReagents", "showChoiceSlots" } }),
            Toggle(L["FOCUS_OPTIONAL_REAGENTS"], L["OPTIONAL_REAGENT_SLOTS"], "showOptionalReagents", true, { id = "showOptionalReagents", visibleWhen = function() return getDB("showRecipes", true) and getDB("recipeReagentsFullDetail", false) end }),
            Toggle(L["FOCUS_FINISHING_REAGENTS"], L["FINISHING_REAGENT_SLOTS"], "showFinishingReagents", true, { id = "showFinishingReagents", visibleWhen = function() return getDB("showRecipes", true) and getDB("recipeReagentsFullDetail", false) end }),
            Toggle(L["CHOICE_SLOTS"], L["COLLAPSIBLE_CHOICE_REAGENT_SLOTS"], "showChoiceSlots", true, { id = "showChoiceSlots", visibleWhen = function() return getDB("showRecipes", true) and getDB("recipeReagentsFullDetail", false) end }),
            Toggle(L["RECIPE_ICONS"], L["RECIPE_ICON_NEXT_TITLE_REQUIRES_QUEST"], "showRecipeIcons", true, { id = "showRecipeIcons", visibleWhen = function() return getDB("showRecipes", true) end }),
            Toggle(L["RARITY_COLOURS"], L["COLOUR_RECIPE_TITLES_OUTPUT_ITEM_RARITY"], "recipeRarityColors", true, { id = "recipeRarityColors", visibleWhen = function() return getDB("showRecipes", true) end }),
            Toggle(L["CRAFTABLE_COUNT"], L["MANY_TIMES_RECIPE_CRAFTED"], "showCraftableCount", true, { id = "showCraftableCount", visibleWhen = function() return getDB("showRecipes", true) end }),
            Toggle(L["QUALITY_INFO"], L["RECIPES_TIER_QUALITY_PIPS"], "showRecipeQualityInfo", false, { id = "showRecipeQualityInfo", visibleWhen = function() return getDB("showRecipes", true) end }),
            Toggle(L["REQUIREMENTS"], L["UNMET_CRAFTING_STATION_REQUIREMENTS"], "showRecipeRequirements", false, { id = "showRecipeRequirements", visibleWhen = function() return getDB("showRecipes", true) end }),
            Toggle(L["FOCUS_AUCTIONATOR_SEARCH"], L["FOCUS_AUCTIONATOR_SEARCH_DESC"], "showAHSearchButton", true, { id = "showAHSearchButton", visibleWhen = function() return getDB("showRecipes", true) end }),
            Section(L["FOCUS_ADVENTURE_GUIDE"]),
            Toggle(L["TRAVELERS_LOG"], L["TRACKED_OBJECTIVES_ADVENTURE_GUIDE"], "showAdventureGuide", true, { refreshIds = { "autoRemoveCompletedAdventureGuide" } }),
            Toggle(L["UNTRACK_COMPLETE"], L["AUTO_UNTRACK_FINISHED_ACTIVITIES"], "autoRemoveCompletedAdventureGuide", true, { id = "autoRemoveCompletedAdventureGuide", visibleWhen = function() return getDB("showAdventureGuide", true) end }),
            Section(L["FOCUS_FLOATING_QUEST_ITEM"]),
            Toggle(L["FOCUS_SHOW_FLOATING_QUEST_ITEM"], L["FOCUS_QUICK_BUTTON_FOCUSED_QUEST_S_USABLE"], "showFloatingQuestItem", false, { refreshIds = { "lockFloatingQuestItemPosition", "floatingQuestItemMode" } }),
            { type = "toggle", name = L["LOCK_ITEM_POSITION"], desc = L["FOCUS_PREVENT_DRAGGING_FLOATING_QUEST_ITEM_BUTTON"], dbKey = "lockFloatingQuestItemPosition", id = "lockFloatingQuestItemPosition", visibleWhen = function() return getDB("showFloatingQuestItem", false) end, get = function() return getDB("lockFloatingQuestItemPosition", false) end, set = function(v) setDB("lockFloatingQuestItemPosition", v); if addon._UpdateFloatingItemDragAnchor then addon._UpdateFloatingItemDragAnchor() end end },
            { type = "dropdown", name = L["ITEM_SOURCE"], desc = L["SUPER_TRACKED_FIRST_CURRENT_ZONE_FIRST"], dbKey = "floatingQuestItemMode", id = "floatingQuestItemMode", visibleWhen = function() return getDB("showFloatingQuestItem", false) end, options = { { L["FOCUS_SUPER_TRACKED_FIRST"], "superTracked" }, { L["FOCUS_CURRENT_ZONE_FIRST"], "currentZone" } }, get = function() return getDB("floatingQuestItemMode", "superTracked") end, set = function(v) setDB("floatingQuestItemMode", v) end },
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
