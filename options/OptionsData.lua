--[[
    Horizon Suite - Focus - Options Data
    OptionCategories (Profiles, Modules, Layout, Display, Typography, Interactions, Instances, Content, Colors, Hidden Quests, Presence General/Notifications/Typography, Insight, Vista Minimap/Appearance/Addon Buttons, Yield), getDB/setDB/notifyMainAddon, search index.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end
if not _G[addon.DB_NAME] then _G[addon.DB_NAME] = {} end

local L = addon.L

-- ---------------------------------------------------------------------------
-- DB helpers
-- ---------------------------------------------------------------------------

local TYPOGRAPHY_KEYS = {
    fontPath = true,
    titleFontPath = true,
    presenceTitleFontPath = true,
    presenceSubtitleFontPath = true,
    zoneFontPath = true,
    objectiveFontPath = true,
    sectionFontPath = true,
    progressBarFontPath = true,
    headerFontSize = true,
    titleFontSize = true,
    objectiveFontSize = true,
    zoneFontSize = true,
    sectionFontSize = true,
    progressBarFontSize = true,
    fontOutline = true,
}

local INSIGHT_KEYS = {
    insightAnchorMode       = true,
    insightFixedPoint       = true,
    insightFixedX           = true,
    insightFixedY           = true,
    insightShowMount        = true,
    insightShowIlvl         = true,
    insightShowPvPTitle     = true,
    insightShowHonorLevel   = true,
    insightShowStatusBadges = true,
    insightShowMythicScore  = true,
    insightShowTransmog     = true,
    insightShowGuildRank    = true,
}

local PRESENCE_KEYS = {
    presenceFrameY = true,
    presenceFrameScale = true,
    presenceBossEmoteColor = true,
    presenceDiscoveryColor = true,
    presenceZoneChange = true,
    presenceSubzoneChange = true,
    presenceHideZoneForSubzone = true,
    presenceSuppressZoneInMplus = true,
    presenceLevelUp = true,
    presenceBossEmote = true,
    presenceAchievement = true,
    presenceAchievementProgress = false,
    presenceQuestEvents = true,
    presenceQuestAccept = true,
    presenceWorldQuestAccept = true,
    presenceQuestComplete = true,
    presenceWorldQuest = true,
    presenceQuestUpdate = true,
    presenceScenarioStart = true,
    presenceScenarioUpdate = true,
    presenceScenarioComplete = true,
    presenceRareDefeated = true,
    presenceAnimations = true,
    presenceEntranceDur = true,
    presenceExitDur = true,
    presenceHoldScale = true,
    presenceMainSize = true,
    presenceSubSize = true,
    presenceTitleFontPath = true,
    presenceSubtitleFontPath = true,
    presenceZoneTypeColoring = true,
    presenceZoneColorFriendly = true,
    presenceZoneColorHostile = true,
    presenceZoneColorContested = true,
    presenceZoneColorSanctuary = true,
    presenceSuppressInDungeon = true,
    presenceSuppressInRaid = true,
    presenceSuppressInPvP = true,
    presenceSuppressInBattleground = true,
    presenceHideQuestUpdateTitle = true,
}

local MPLUS_TYPOGRAPHY_KEYS = {
    fontPath = true,
    fontOutline = true,
    shadowOffsetX = true,
    shadowOffsetY = true,
    showTextShadow = true,
    shadowAlpha = true,
    mplusDungeonSize = true,
    mplusDungeonColorR = true, mplusDungeonColorG = true, mplusDungeonColorB = true,
    mplusTimerSize = true,
    mplusTimerColorR = true, mplusTimerColorG = true, mplusTimerColorB = true,
    mplusTimerOvertimeColorR = true, mplusTimerOvertimeColorG = true, mplusTimerOvertimeColorB = true,
    mplusProgressSize = true,
    mplusProgressColorR = true, mplusProgressColorG = true, mplusProgressColorB = true,
    mplusAffixSize = true,
    mplusAffixColorR = true, mplusAffixColorG = true, mplusAffixColorB = true,
    mplusBossSize = true,
    mplusBossColorR = true, mplusBossColorG = true, mplusBossColorB = true,
    mplusBarColorR = true, mplusBarColorG = true, mplusBarColorB = true, mplusBarColorA = true,
    mplusBarDoneColorR = true, mplusBarDoneColorG = true, mplusBarDoneColorB = true, mplusBarDoneColorA = true,
}

-- Keys written by color pickers during drag. When _colorPickerLive is true and key is in this list,
-- we skip NotifyMainAddon to avoid FullLayout spam; key-specific handlers (e.g. ApplyBackdropOpacity) still run.
local COLOR_LIVE_KEYS = {
    backdropOpacity = true, backdropColorR = true, backdropColorG = true, backdropColorB = true,
    headerColor = true, headerDividerColor = true,
    colorMatrix = true,
    highlightColor = true, completedObjectiveColor = true, sectionColors = true,
    objectiveProgressFlashColor = true, presenceBossEmoteColor = true, presenceDiscoveryColor = true,
    mplusDungeonColorR = true, mplusDungeonColorG = true, mplusDungeonColorB = true,
    mplusTimerColorR = true, mplusTimerColorG = true, mplusTimerColorB = true,
    mplusTimerOvertimeColorR = true, mplusTimerOvertimeColorG = true, mplusTimerOvertimeColorB = true,
    mplusProgressColorR = true, mplusProgressColorG = true, mplusProgressColorB = true,
    mplusBarColorR = true, mplusBarColorG = true, mplusBarColorB = true, mplusBarColorA = true,
    mplusBarDoneColorR = true, mplusBarDoneColorG = true, mplusBarDoneColorB = true, mplusBarDoneColorA = true,
    mplusAffixColorR = true, mplusAffixColorG = true, mplusAffixColorB = true,
    mplusBossColorR = true, mplusBossColorG = true, mplusBossColorB = true,
    progressBarFillColor = true, progressBarTextColor = true,
    progressBarUseCategoryColor = true,
    presenceZoneColorFriendly = true, presenceZoneColorHostile = true,
    presenceZoneColorContested = true, presenceZoneColorSanctuary = true,
    sectionDividerColor = true,
    vistaBorderColorR = true, vistaBorderColorG = true, vistaBorderColorB = true, vistaBorderColorA = true,
    vistaZoneColorR = true, vistaZoneColorG = true, vistaZoneColorB = true,
    vistaCoordColorR = true, vistaCoordColorG = true, vistaCoordColorB = true,
    vistaTimeColorR = true, vistaTimeColorG = true, vistaTimeColorB = true,
    vistaDiffColorR = true, vistaDiffColorG = true, vistaDiffColorB = true,
    vistaPanelBgR = true, vistaPanelBgG = true, vistaPanelBgB = true, vistaPanelBgA = true,
    vistaPanelBorderR = true, vistaPanelBorderG = true, vistaPanelBorderB = true, vistaPanelBorderA = true,
    vistaBarBgR = true, vistaBarBgG = true, vistaBarBgB = true, vistaBarBgA = true,
    vistaBarBorderR = true, vistaBarBorderG = true, vistaBarBorderB = true, vistaBarBorderA = true,
}

-- Vista option keys — trigger Vista.ApplyOptions when changed
local VISTA_KEYS = {
    vistaMapSize = true,
    vistaCircular = true,
    vistaBorderShow = true, vistaBorderWidth = true,
    vistaBorderColorR = true, vistaBorderColorG = true, vistaBorderColorB = true, vistaBorderColorA = true,
    vistaZoneFontPath = true, vistaZoneFontSize = true,
    vistaCoordFontPath = true, vistaCoordFontSize = true,
    vistaTimeFontPath = true, vistaTimeFontSize = true,
    vistaShowZoneText = true, vistaShowCoordText = true, vistaShowTimeText = true,
    vistaTimeUseLocal = true, vistaZoneDisplayMode = true,
    vistaZoneVerticalPos = true, vistaCoordVerticalPos = true, vistaTimeVerticalPos = true,
    vistaShowDefaultMinimapButtons = true,  -- legacy key kept for compatibility
    vistaLock = true,
    vistaPoint = true, vistaRelPoint = true, vistaX = true, vistaY = true,
    vistaDrawerBtnX = true, vistaDrawerBtnY = true,
    vistaShowTracking = true, vistaMouseoverTracking = true,
    vistaShowCalendar = true, vistaMouseoverCalendar = true,
    vistaShowZoomBtns = true, vistaMouseoverZoomBtns = true,
    vistaQueueBtnX = true, vistaQueueBtnY = true,
    -- Draggable element positions (stored by MakeDraggable on drag-stop)
    vistaEX_zone = true, vistaEY_zone = true,
    vistaEX_coord = true, vistaEY_coord = true,
    vistaEX_time = true, vistaEY_time = true,
    vistaEX_diff = true, vistaEY_diff = true,
    -- Proxy button positions (tracking + calendar + queue only; landing page removed)
    ["vistaEX_proxy_tracking"] = true, ["vistaEY_proxy_tracking"] = true,
    ["vistaEX_proxy_calendar"] = true, ["vistaEY_proxy_calendar"] = true,
    ["vistaEX_proxy_queue"]    = true, ["vistaEY_proxy_queue"]    = true,
    ["vistaEX_proxy_mail"]     = true, ["vistaEY_proxy_mail"]     = true,
    -- Lock toggles
    vistaLocked_zone = true, vistaLocked_coord = true, vistaLocked_time = true,
    vistaLocked_diff = true,
    vistaLocked_zoomIn = true, vistaLocked_zoomOut = true,
    ["vistaLocked_proxy_tracking"] = true,
    ["vistaLocked_proxy_calendar"] = true,
    ["vistaLocked_proxy_queue"]    = true,
    ["vistaLocked_proxy_mail"]     = true,
    ["vistaQueueHandlingDisabled"] = true,
    ["vistaCoordPrecision"] = true,
    -- Addon button layout
    vistaBtnLayoutCols = true, vistaBtnLayoutDir = true,
    vistaMouseoverLocked = true, vistaMouseoverBarX = true, vistaMouseoverBarY = true,
    vistaMouseoverBarVisible = true,
    vistaMouseoverCloseDelay = true, vistaRightClickCloseDelay = true, vistaDrawerCloseDelay = true,
    vistaBarBgR = true, vistaBarBgG = true, vistaBarBgB = true, vistaBarBgA = true,
    vistaBarBorderShow = true,
    vistaBarBorderR = true, vistaBarBorderG = true, vistaBarBorderB = true, vistaBarBorderA = true,
    vistaRightClickLocked = true, vistaRightClickPanelX = true, vistaRightClickPanelY = true,
    vistaButtonMode = true, vistaHandleAddonButtons = true,
    vistaDrawerButtonLocked = true, vistaButtonWhitelist = true,
    vistaMailBlink = true,
    -- Button sizes (separate per type)
    vistaTrackingBtnSize = true, vistaCalendarBtnSize = true, vistaQueueBtnSize = true,
    vistaZoomBtnSize = true, vistaMailIconSize = true, vistaAddonBtnSize = true,
    -- Text colors
    vistaZoneColorR = true, vistaZoneColorG = true, vistaZoneColorB = true,
    vistaCoordColorR = true, vistaCoordColorG = true, vistaCoordColorB = true,
    vistaTimeColorR = true, vistaTimeColorG = true, vistaTimeColorB = true,
    vistaDiffColorR = true, vistaDiffColorG = true, vistaDiffColorB = true,
    vistaDiffFontPath = true, vistaDiffFontSize = true,
    vistaLocked_diff = true,
    vistaDiffColor_mythic_R = true, vistaDiffColor_mythic_G = true, vistaDiffColor_mythic_B = true,
    vistaDiffColor_heroic_R = true, vistaDiffColor_heroic_G = true, vistaDiffColor_heroic_B = true,
    vistaDiffColor_normal_R = true, vistaDiffColor_normal_G = true, vistaDiffColor_normal_B = true,
    vistaDiffColor_looking_for_raid_R = true, vistaDiffColor_looking_for_raid_G = true, vistaDiffColor_looking_for_raid_B = true,
    -- Panel colors
    vistaPanelBgR = true, vistaPanelBgG = true, vistaPanelBgB = true, vistaPanelBgA = true,
    vistaPanelBorderR = true, vistaPanelBorderG = true, vistaPanelBorderB = true, vistaPanelBorderA = true,
}
-- Vista border color keys: live updates without full layout
local VISTA_COLOR_LIVE_KEYS = {
    vistaBorderColorR = true, vistaBorderColorG = true, vistaBorderColorB = true, vistaBorderColorA = true,
    vistaZoneColorR = true, vistaZoneColorG = true, vistaZoneColorB = true,
    vistaCoordColorR = true, vistaCoordColorG = true, vistaCoordColorB = true,
    vistaTimeColorR = true, vistaTimeColorG = true, vistaTimeColorB = true,
    vistaDiffColorR = true, vistaDiffColorG = true, vistaDiffColorB = true,
    vistaDiffColor_mythic_R = true, vistaDiffColor_mythic_G = true, vistaDiffColor_mythic_B = true,
    vistaDiffColor_heroic_R = true, vistaDiffColor_heroic_G = true, vistaDiffColor_heroic_B = true,
    vistaDiffColor_normal_R = true, vistaDiffColor_normal_G = true, vistaDiffColor_normal_B = true,
    vistaDiffColor_looking_for_raid_R = true, vistaDiffColor_looking_for_raid_G = true, vistaDiffColor_looking_for_raid_B = true,
    vistaPanelBgR = true, vistaPanelBgG = true, vistaPanelBgB = true, vistaPanelBgA = true,
    vistaPanelBorderR = true, vistaPanelBorderG = true, vistaPanelBorderB = true, vistaPanelBorderA = true,
    vistaBarBgR = true, vistaBarBgG = true, vistaBarBgB = true, vistaBarBgA = true,
    vistaBarBorderR = true, vistaBarBorderG = true, vistaBarBorderB = true, vistaBarBorderA = true,
}

-- Scale keys managed by debounced callbacks in the slider set lambdas.
-- OptionsData_SetDB must NOT call OptionsData_NotifyMainAddon for these —
-- doing so would trigger FullLayout synchronously on every integer drag step,
-- defeating the debounce entirely.
local SCALE_DEBOUNCE_KEYS = {
    globalUIScale   = true,
    focusUIScale    = true,
    presenceUIScale = true,
    vistaUIScale    = true,
    insightUIScale  = true,
    yieldUIScale    = true,
    vistaBorderWidth = true,
    vistaAddonBtnSize = true,
    vistaBtnLayoutCols = true,
}

function OptionsData_GetDB(key, default)
    return addon.GetDB(key, default)
end

local updateOptionsPanelFontsRef
function OptionsData_SetUpdateFontsRef(fn)
    updateOptionsPanelFontsRef = fn
end

function OptionsData_SetDB(key, value)
    addon.SetDB(key, value)
    if key == "showWorldQuests" and addon.focus and addon.focus.collapse then
        if value == false then
            addon.focus.collapse.pendingWQCollapse = true
        elseif value == true then
            addon.focus.collapse.pendingWQExpand = true
        end
    end
    -- When the "Show in-zone world quests" toggle is flipped on, invalidate the nearby
    -- WQ scan cache so the next FullLayout immediately re-scans for the current zone.
    if key == "showWorldQuests" and value == true and addon.focus then
        addon.focus.nearbyQuestCacheDirty = true
        addon.focus.nearbyQuestCache = nil
        addon.focus.nearbyTaskQuestCache = nil
    end
    if (key == "fontPath" or key == "titleFontPath" or key == "zoneFontPath" or key == "objectiveFontPath" or key == "sectionFontPath" or key == "progressBarFontPath" or key == "presenceTitleFontPath" or key == "presenceSubtitleFontPath") and updateOptionsPanelFontsRef then
        updateOptionsPanelFontsRef()
    end
    if TYPOGRAPHY_KEYS[key] and addon.UpdateFontObjectsFromDB then
        addon.UpdateFontObjectsFromDB()
    end
    if MPLUS_TYPOGRAPHY_KEYS[key] and addon.ApplyMplusTypography then
        addon.ApplyMplusTypography()
    end
    if PRESENCE_KEYS[key] and addon.Presence then
        if addon.Presence.ApplyPresenceOptions then addon.Presence.ApplyPresenceOptions() end
        if addon.Presence.ApplyBlizzardSuppression then addon.Presence.ApplyBlizzardSuppression() end
    end
    if INSIGHT_KEYS[key] and addon.Insight and addon.Insight.ApplyInsightOptions then
        addon.Insight.ApplyInsightOptions()
    end
    if VISTA_KEYS[key] and addon.Vista then
        if addon._colorPickerLive and VISTA_COLOR_LIVE_KEYS[key] then
            if addon.Vista.ApplyColors then addon.Vista.ApplyColors() end
        elseif addon.Vista.ApplyOptions then
            local fn = addon.Vista.ApplyOptions
            -- vistaLock: apply immediately when not in combat for responsive toggle feedback
            if key == "vistaLock" and not InCombatLockdown() then
                fn()
            elseif C_Timer and C_Timer.After then
                C_Timer.After(0, fn)
            else
                fn()
            end
        end
    end
    -- vistaButtonManaged_* keys trigger a full button re-collect
    if key:sub(1, 19) == "vistaButtonManaged_" and addon.Vista and addon.Vista.ApplyOptions then
        local fn = addon.Vista.ApplyOptions
        if C_Timer and C_Timer.After then C_Timer.After(0, fn) else fn() end
    end
    if key == "lockPosition" and addon.UpdateResizeHandleVisibility then
        addon.UpdateResizeHandleVisibility()
    end
    if (key == "backdropOpacity" or key == "backdropColorR" or key == "backdropColorG" or key == "backdropColorB") and addon.ApplyBackdropOpacity then
        addon.ApplyBackdropOpacity()
    end
    if addon._colorPickerLive and COLOR_LIVE_KEYS[key] then
        OptionsData_NotifyMainAddon_Live()
        return
    end
    -- Scale keys are handled by debounced callbacks in the slider set lambdas.
    -- Do NOT call NotifyMainAddon here or FullLayout runs on every integer drag step.
    if SCALE_DEBOUNCE_KEYS[key] then return end
    -- Current Quest expiry ticker: restart when toggle or window changes.
    if (key == "showCurrentQuestCategory" or key == "currentQuestWindowSec") and addon.StopCurrentQuestExpiryTicker and addon.StartCurrentQuestExpiryTicker then
        addon.StopCurrentQuestExpiryTicker()
        if key == "showCurrentQuestCategory" then
            if value == true and addon.focus and addon.focus.enabled then
                addon.StartCurrentQuestExpiryTicker()
            end
        elseif addon.GetDB("showCurrentQuestCategory", true) and addon.focus and addon.focus.enabled then
            addon.StartCurrentQuestExpiryTicker()
        end
    end
    OptionsData_NotifyMainAddon()
end

--- Lightweight notify for live color picker: updates visuals without FullLayout.
function OptionsData_NotifyMainAddon_Live()
    local applyTy = addon.ApplyTypography or _G.HorizonSuite_ApplyTypography
    if applyTy then applyTy() end
    if addon.ApplyBackdropOpacity then addon.ApplyBackdropOpacity() end
    if addon.ApplyBorderVisibility then addon.ApplyBorderVisibility() end
    if addon.ApplyFocusColors then addon.ApplyFocusColors() end
    if addon.Vista and addon.Vista.ApplyColors then addon.Vista.ApplyColors() end
end

function OptionsData_NotifyMainAddon()
    local applyTy = addon.ApplyTypography or _G.HorizonSuite_ApplyTypography
    if applyTy then applyTy() end
    if addon.ApplyDimensions then addon.ApplyDimensions()
    elseif _G.HorizonSuite_ApplyDimensions then _G.HorizonSuite_ApplyDimensions() end
    if addon.ApplyBackdropOpacity then addon.ApplyBackdropOpacity() end
    if addon.ApplyBorderVisibility then addon.ApplyBorderVisibility() end
    if addon.RequestRefresh then addon.RequestRefresh()
    elseif _G.HorizonSuite_RequestRefresh then _G.HorizonSuite_RequestRefresh() end
    local fullLayout = addon.FullLayout or _G.HorizonSuite_FullLayout
    if fullLayout and not InCombatLockdown() then fullLayout() end
end

-- ---------------------------------------------------------------------------
-- Option value helpers (used in category descriptors)
-- ---------------------------------------------------------------------------

local function getDB(k, d) return addon.GetDB(k, d) end
local function setDB(k, v) return OptionsData_SetDB(k, v) end

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
    out[#out + 1] = { L["Custom"], saved }
    return out
end

local FONT_USE_GLOBAL = "__global__"

local function GetPerElementFontDropdownOptions(dbKey)
    if addon.RefreshFontList then addon.RefreshFontList() end
    local list = (addon.GetFontList and addon.GetFontList()) or {}
    local out = { { L["Use global font"], FONT_USE_GLOBAL } }
    for i = 1, #list do out[#out + 1] = list[i] end
    local saved = getDB(dbKey, FONT_USE_GLOBAL)
    if saved == FONT_USE_GLOBAL then return out end
    for _, o in ipairs(out) do
        if o[2] == saved then return out end
    end
    out[#out + 1] = { L["Custom"], saved }
    return out
end

local function DisplayPerElementFont(value)
    if value == FONT_USE_GLOBAL then return L["Use global font"] end
    if addon.GetFontNameForPath then return addon.GetFontNameForPath(value) end
    return value
end

local OUTLINE_OPTIONS = {
    { L["None"], "" },
    { L["Outline"], "OUTLINE" },
    { L["Thick Outline"], "THICKOUTLINE" },
}
local HIGHLIGHT_OPTIONS = {
    { L["Bar (left edge)"], "bar-left" },
    { L["Bar (right edge)"], "bar-right" },
    { L["Bar (top edge)"], "bar-top" },
    { L["Bar (bottom edge)"], "bar-bottom" },
    { L["Outline only"], "outline" },
    { L["Soft glow"], "glow" },
    { L["Dual edge bars"], "bar-both" },
    { L["Pill left accent"], "pill-left" },
    { L["Highlight"], "highlight" },
}
local MPLUS_POSITION_OPTIONS = {
    { L["Top"], "top" },
    { L["Bottom"], "bottom" },
}
local MPLUS_FONT_OPTIONS = {
    { "Title Font", "TitleFont" },
    { "Objective Font", "ObjFont" },
    { "Section Font", "SectionFont" },
    { "Detail Font", "DetailFont" },
}
local TEXT_CASE_OPTIONS = {
    { L["Lower Case"], "lower" },
    { L["Upper Case"], "upper" },
    { L["Proper"], "proper" },
}
-- Use addon.QUEST_COLORS from Config as single source for quest type colors.
local COLOR_KEYS_ORDER = { "DEFAULT", "CAMPAIGN", "IMPORTANT", "LEGENDARY", "WORLD", "DELVES", "SCENARIO", "RAID", "ACHIEVEMENT", "WEEKLY", "PREY", "DAILY", "COMPLETE", "RARE" }
local ZONE_COLOR_DEFAULT = { 0.55, 0.65, 0.75 }
local OBJ_COLOR_DEFAULT = { 0.78, 0.78, 0.78 }
local OBJ_DONE_COLOR_DEFAULT = { 0.20, 1.00, 0.40 }  -- matches Ready to Turn In #33FF66
local HIGHLIGHT_COLOR_DEFAULT = { 0.4, 0.7, 1 }

local VALID_HIGHLIGHT_STYLES = {
    ["bar-left"] = true, ["bar-right"] = true, ["bar-top"] = true, ["bar-bottom"] = true,
    ["outline"] = true, ["glow"] = true, ["bar-both"] = true, ["pill-left"] = true, ["highlight"] = true,
}
local function getActiveQuestHighlight()
    local v = addon.NormalizeHighlightStyle(getDB("activeQuestHighlight", "bar-left"))
    if not VALID_HIGHLIGHT_STYLES[v] then return "bar-left" end
    return v
end

-- ---------------------------------------------------------------------------
-- OptionCategories: Profiles, Modules, Layout, Display, Typography, Interactions, Instances, Content, Colors, Hidden Quests, Presence (General, Notifications, Typography), Insight, Vista (Minimap, Appearance, Addon Buttons), Yield
-- ---------------------------------------------------------------------------

local OptionCategories = {
    {
        key = "Profiles",
        name = L["Profiles"] or "Profiles",
        desc = L["Manage and switch between your addon configurations."] or "Manage and switch between your addon configurations.",
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
            opts[#opts + 1] = { type = "section", name = L["Profiles"] or "Profiles" }

            opts[#opts + 1] = {
                type = "toggle",
                name = L["Global profile"] or "Global profile",
                desc = L["All characters use the same profile."] or "All characters use the same profile.",
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
                    OptionsData_NotifyMainAddon()
                    if addon.OptionsPanel_Refresh then addon.OptionsPanel_Refresh() end
                end,
            }

                opts[#opts + 1] = {
                    type = "dropdown",
                    name = L["Current profile"] or "Current profile",
                    desc = L["Select the profile currently in use."] or "Select the profile currently in use.",
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
                        OptionsData_NotifyMainAddon()
                        if addon.OptionsPanel_Refresh then addon.OptionsPanel_Refresh() end
                    end,
                }

                -- Section B: Per-spec switch + spec dropdowns
                opts[#opts + 1] = { type = "section", name = L["Specialization"] or "Specialization" }

                opts[#opts + 1] = {
                    type = "toggle",
                    name = L["Per-spec profiles"] or "Per-spec profiles",
                    desc = L["Pick different profiles per spec."] or "Pick different profiles per spec.",
                    dbKey = "_profiles_usePerSpec",
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
                                local currentSpec = GetSpecialization and GetSpecialization() or nil
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
                        OptionsData_NotifyMainAddon()
                        if addon.OptionsPanel_Refresh then addon.OptionsPanel_Refresh() end
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
                            OptionsData_NotifyMainAddon()
                            if addon.OptionsPanel_Refresh then addon.OptionsPanel_Refresh() end
                        end,
                    }
                end

                -- Section C: Create / Copy profile
                opts[#opts + 1] = { type = "section", name = L["Create"] or "Create" }

                opts[#opts + 1] = {
                    type = "button",
                    name = L["New from Default"] or "New from Default",
                    desc = L["Creates a new profile with all default settings."] or "Creates a new profile with all default settings.",
                    dbKey = "_profiles_create_new",
                    onClick = function()
                        if addon.ShowCreateProfilePopup then addon.ShowCreateProfilePopup("Default") end
                    end,
                }

                opts[#opts + 1] = {
                    type = "dropdown",
                    name = L["Copy from profile"] or "Copy from profile",
                    desc = L["Source profile for copying."] or "Source profile for copying.",
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

                opts[#opts + 1] = {
                    type = "button",
                    name = L["Copy from selected"] or "Copy from selected",
                    desc = L["Creates a new profile copied from the selected source profile."] or "Creates a new profile copied from the selected source profile.",
                    dbKey = "_profiles_copy_selected",
                    onClick = function()
                        local src = addon._profileCopyFrom or (addon.GetActiveProfileKey and addon.GetActiveProfileKey())
                        if addon.ShowCreateProfilePopup then addon.ShowCreateProfilePopup(src) end
                    end,
                }

                -- Section D: Delete profile
                opts[#opts + 1] = { type = "section", name = L["Delete"] or "Delete" }

                opts[#opts + 1] = {
                    type = "dropdown",
                    name = L["Delete profile"] or "Delete profile",
                    desc = L["Select a profile to delete (current and Default not shown)."] or "Select a profile to delete (current and Default not shown).",
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

                opts[#opts + 1] = {
                    type = "button",
                    name = L["Delete selected profile"] or "Delete selected profile",
                    desc = L["Deletes the selected profile."] or "Deletes the selected profile.",
                    dbKey = "_profiles_delete_btn",
                    onClick = function()
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
                            OptionsData_NotifyMainAddon()
                            if addon.OptionsPanel_Refresh then addon.OptionsPanel_Refresh() end
                        end
                    end,
                }

                opts[#opts + 1] = { type = "section", name = L["Sharing"] or "Sharing" }

                opts[#opts + 1] = {
                    type = "dropdown",
                    name = L["Export profile"] or "Export profile",
                    desc = L["Select a profile to export."] or "Select a profile to export.",
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
                    labelText = L["Export string"] or "Export string",
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
                    labelText = L["Import string"] or "Import string",
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

                opts[#opts + 1] = {
                    type = "button",
                    name = L["Import profile"] or "Import profile",
                    dbKey = "_profiles_import_btn",
                    onClick = function()
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
                    end,
                }

                return opts
        end,
    },
    {
        key = "Modules",
        name = L["Modules"],
        moduleKey = nil,
        options = (function()
            local dev = _G.HorizonSuiteDevOverride
            local betaSuffix = dev and (" (" .. (L["Beta"] or "Beta") .. ")") or ""
            local opts = {
                { type = "section", name = L["Module Toggles"] or "Module Toggles" },
                { type = "toggle", name = L["Focus"], desc = L["Objective tracker for quests, world quests, rares, achievements, scenarios."], dbKey = "_module_focus", get = function() return addon:IsModuleEnabled("focus") end, set = function(v) addon:SetModuleEnabled("focus", v) end },
                { type = "toggle", name = L["Presence"], desc = L["Zone text and notifications."], dbKey = "_module_presence", get = function() return addon:IsModuleEnabled("presence") end, set = function(v) addon:SetModuleEnabled("presence", v) end },
                { type = "toggle", name = L["Vista"] or "Vista", desc = L["Minimap with zone text, coords, time, and button collector."] or "Minimap with zone text, coords, time, and button collector.", dbKey = "_module_vista", get = function() return addon:IsModuleEnabled("vista") end, set = function(v) addon:SetModuleEnabled("vista", v) end },
            }
            if dev and dev.showInsightToggle then
                opts[#opts + 1] = { type = "toggle", name = L["Insight"] .. betaSuffix, desc = L["Tooltips with class colors, spec, and faction icons."], dbKey = "_module_insight", get = function() return addon:IsModuleEnabled("insight") end, set = function(v) addon:SetModuleEnabled("insight", v) end }
            end
            if dev and dev.showYieldToggle then
                opts[#opts + 1] = { type = "toggle", name = L["Yield"] .. betaSuffix, desc = L["Loot toasts for items, money, currency, reputation."], dbKey = "_module_yield", get = function() return addon:IsModuleEnabled("yield") end, set = function(v) addon:SetModuleEnabled("yield", v) end }
            end
            opts[#opts + 1] = { type = "section", name = L["Appearance"] or "Appearance" }
            opts[#opts + 1] = { type = "toggle", name = L["Class colors"] or "Class colors", desc = L["Tint the options panel accent with your class color."] or "Tint the options panel accent with your class color.", dbKey = "optionsClassColor", get = function() return getDB("optionsClassColor", false) end, set = function(v) setDB("optionsClassColor", v); if addon.ApplyOptionsClassColor then addon.ApplyOptionsClassColor() end end }
            opts[#opts + 1] = { type = "section", name = L["Scaling"] }
            -- helper: refresh all modules after any scale change
            local function refreshAllScaling()
                if addon.ApplyTypography then addon.ApplyTypography() end
                if addon.ApplyDimensions then addon.ApplyDimensions() end
                if addon.ApplyMplusTypography then addon.ApplyMplusTypography() end
                if addon.Presence and addon.Presence.ApplyPresenceOptions then addon.Presence.ApplyPresenceOptions() end
                if addon.Vista and addon.Vista.ApplyScale then addon.Vista.ApplyScale() end
                if addon.Yield and addon.Yield.ApplyScale then addon.Yield.ApplyScale() end
                local fullLayout = addon.FullLayout or _G.HorizonSuite_FullLayout
                if fullLayout and not InCombatLockdown() then fullLayout() end
            end
            -- Debounce: write DB immediately on every slider step, but delay the heavy
            -- apply call (typography, dimensions, FullLayout) until the user pauses.
            -- Each call cancels any in-flight timer and schedules a fresh one.
            local scalingDebounceTimers = {}
            local SCALE_DEBOUNCE = 0.15  -- seconds to wait after last change
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
            local function isNotPerModule() return not isPerModule() end
            opts[#opts + 1] = { type = "slider", name = L["Global UI scale"], desc = L["Scale all UI elements (50–200%)."], dbKey = "globalUIScale_pct", min = 50, max = 200, tooltip = L["Doesn't change your configured values, only the effective display scale."],
                disabled = isPerModule,
                get = function()
                    return math.floor((tonumber(getDB("globalUIScale", 1)) or 1) * 100 + 0.5)
                end, set = function(v)
                    local scale = math.max(50, math.min(200, v)) / 100
                    setDB("globalUIScale", scale)
                    debouncedRefresh("global", refreshAllScaling)
                end }
            opts[#opts + 1] = { type = "toggle", name = L["Per-module scaling"], desc = L["Separate scale slider per module."], dbKey = "perModuleScaling", tooltip = L["Overrides the global scale with individual sliders for Focus, Presence, Vista, etc."], get = function() return isPerModule() end, set = function(v)
                setDB("perModuleScaling", v)
                refreshAllScaling()
                if addon.OptionsPanel_Refresh then addon.OptionsPanel_Refresh() end
            end }
            -- Per-module sliders (visible always, but only active when per-module scaling is on)
            opts[#opts + 1] = { type = "slider", name = L["Focus scale"], desc = L["Scale for the Focus objective tracker (50–200%)."], dbKey = "focusUIScale_pct", min = 50, max = 200,
                disabled = isNotPerModule,
                get = function()
                    return math.floor((tonumber(getDB("focusUIScale", 1)) or 1) * 100 + 0.5)
                end, set = function(v)
                    setDB("focusUIScale", math.max(50, math.min(200, v)) / 100)
                    debouncedRefresh("focus", refreshAllScaling)
                end }
            opts[#opts + 1] = { type = "slider", name = L["Presence scale"], desc = L["Scale for the Presence cinematic text (50–200%)."], dbKey = "presenceUIScale_pct", min = 50, max = 200,
                disabled = isNotPerModule,
                get = function()
                    return math.floor((tonumber(getDB("presenceUIScale", 1)) or 1) * 100 + 0.5)
                end, set = function(v)
                    setDB("presenceUIScale", math.max(50, math.min(200, v)) / 100)
                    debouncedRefresh("presence", function()
                        if addon.Presence and addon.Presence.ApplyPresenceOptions then addon.Presence.ApplyPresenceOptions() end
                    end)
                end }
            opts[#opts + 1] = { type = "slider", name = L["Vista scale"], desc = L["Scale for the Vista minimap module (50–200%)."], dbKey = "vistaUIScale_pct", min = 50, max = 200,
                disabled = isNotPerModule,
                get = function()
                    return math.floor((tonumber(getDB("vistaUIScale", 1)) or 1) * 100 + 0.5)
                end, set = function(v)
                    setDB("vistaUIScale", math.max(50, math.min(200, v)) / 100)
                    debouncedRefresh("vista", function()
                        if addon.Vista and addon.Vista.ApplyScale then addon.Vista.ApplyScale() end
                    end)
                end }
            if dev and dev.showInsightToggle then
                opts[#opts + 1] = { type = "slider", name = L["Insight scale"], desc = L["Scale for the Insight tooltip module (50–200%)."], dbKey = "insightUIScale_pct", min = 50, max = 200,
                    disabled = isNotPerModule,
                    get = function()
                        return math.floor((tonumber(getDB("insightUIScale", 1)) or 1) * 100 + 0.5)
                    end, set = function(v)
                        setDB("insightUIScale", math.max(50, math.min(200, v)) / 100)
                        -- Insight has no heavy apply; no debounce needed.
                    end }
            end
            if dev and dev.showYieldToggle then
                opts[#opts + 1] = { type = "slider", name = L["Yield scale"], desc = L["Scale for the Yield loot toast module (50–200%)."], dbKey = "yieldUIScale_pct", min = 50, max = 200,
                    disabled = isNotPerModule,
                    get = function()
                        return math.floor((tonumber(getDB("yieldUIScale", 1)) or 1) * 100 + 0.5)
                    end, set = function(v)
                        setDB("yieldUIScale", math.max(50, math.min(200, v)) / 100)
                        debouncedRefresh("yield", function()
                            if addon.Yield and addon.Yield.ApplyScale then addon.Yield.ApplyScale() end
                        end)
                    end }
            end
            return opts
        end)(),
    },
    {
        key = "Layout",
        name = L["Layout"],
        moduleKey = "focus",
        options = {
            { type = "section", name = L["Position & layout"] },
            { type = "toggle", name = L["Lock position"], desc = L["Prevent dragging the tracker."], dbKey = "lockPosition", get = function() return getDB("lockPosition", false) end, set = function(v) setDB("lockPosition", v) end },
            { type = "toggle", name = L["Grow upward"], desc = L["Anchor at bottom so the list grows upward."], dbKey = "growUp", get = function() return getDB("growUp", false) end, set = function(v) setDB("growUp", v); if addon.FullLayout then addon.FullLayout() end end, refreshIds = { "growUpHeaderMode" } },
            { type = "dropdown", name = L["Grow-up header"], desc = L["Keep header at bottom, or top until collapsed."], tooltip = L["When growing upward: keep header at bottom, or at top until collapsed."], dbKey = "growUpHeaderMode", options = { { L["Header at bottom"], "always" }, { L["Header slides on collapse"], "collapse" } }, get = function() return getDB("growUpHeaderMode", "always") end, set = function(v) setDB("growUpHeaderMode", v); if addon.FullLayout then addon.FullLayout() end end, disabled = function() return not getDB("growUp", false) end },
            { type = "toggle", name = L["Start collapsed"], desc = L["Start with only the header shown until you expand."], dbKey = "collapsed", get = function() return getDB("collapsed", false) end, set = function(v) setDB("collapsed", v) end },
            { type = "section", name = L["Dimensions"] },
            { type = "slider", name = L["Panel width"], desc = L["Tracker width in pixels."], dbKey = "panelWidth", min = 180, max = 800, get = function() return getDB("panelWidth", 260) end, set = function(v) setDB("panelWidth", math.max(180, math.min(800, v))) end },
            { type = "slider", name = L["Max content height"], desc = L["Max height of the scrollable list (pixels)."], dbKey = "maxContentHeight", min = 200, max = 1500, get = function() return getDB("maxContentHeight", 480) end, set = function(v) setDB("maxContentHeight", math.max(200, math.min(1500, v))) end },
            { type = "section", name = L["Spacing"] },
            { type = "toggle", name = L["Compact mode"], desc = L["Preset: sets entry and objective spacing to 4 and 1 px."], dbKey = "compactMode", get = function() return getDB("compactMode", false) end, set = function(v) setDB("compactMode", v); if v then setDB("titleSpacing", 4); setDB("objSpacing", 1) else setDB("titleSpacing", 8); setDB("objSpacing", 2) end end },
            { type = "slider", name = L["Entry spacing"], desc = L["Vertical gap between quest entries."], dbKey = "titleSpacing", min = 2, max = 20, get = function() return math.max(2, math.min(20, tonumber(getDB("titleSpacing", 8)) or 8)) end, set = function(v) setDB("titleSpacing", math.max(2, math.min(20, v))) end },
            { type = "slider", name = L["Before section header"], desc = L["Gap between last entry of a group and the next category label."], dbKey = "sectionSpacing", min = 0, max = 24, get = function() return math.max(0, math.min(24, tonumber(getDB("sectionSpacing", 10)) or 10)) end, set = function(v) setDB("sectionSpacing", math.max(0, math.min(24, v))) end },
            { type = "slider", name = L["After section header"], desc = L["Gap between category label and first quest entry below it."], dbKey = "sectionToEntryGap", min = 0, max = 16, get = function() return math.max(0, math.min(16, tonumber(getDB("sectionToEntryGap", 6)) or 6)) end, set = function(v) setDB("sectionToEntryGap", math.max(0, math.min(16, v))) end },
            { type = "slider", name = L["Objective spacing"], desc = L["Vertical gap between objective lines within a quest."], dbKey = "objSpacing", min = 0, max = 8, get = function() return math.max(0, math.min(8, tonumber(getDB("objSpacing", 2)) or 2)) end, set = function(v) setDB("objSpacing", math.max(0, math.min(8, v))) end },
            { type = "slider", name = L["Below header"], desc = L["Vertical gap between the objectives bar and the quest list."], dbKey = "headerToContentGap", min = 0, max = 24, get = function() return math.max(0, math.min(24, tonumber(getDB("headerToContentGap", 6)) or 6)) end, set = function(v) setDB("headerToContentGap", math.max(0, math.min(24, v))) end },
            { type = "button", name = L["Reset spacing"], onClick = function()
                setDB("compactMode", false)
                setDB("titleSpacing", 8)
                setDB("sectionSpacing", 10)
                setDB("sectionToEntryGap", 6)
                setDB("objSpacing", 2)
                setDB("headerToContentGap", 6)
            end, refreshIds = { "compactMode", "titleSpacing", "sectionSpacing", "sectionToEntryGap", "objSpacing", "headerToContentGap" } },
        },
    },
    {
        key = "Appearance",
        name = L["Appearance"],
        moduleKey = "focus",
        options = {
            { type = "section", name = L["Panel backdrop"] },
            { type = "slider", name = L["Backdrop opacity"], desc = L["Panel background opacity (0–100%)."], dbKey = "backdropOpacity", min = 0, max = 100, get = function() local v = tonumber(getDB("backdropOpacity", 0)) or 0; if v <= 1 and v > 0 then return math.floor(v * 100 + 0.5) end; return math.max(0, math.min(100, v)) end, set = function(v) setDB("backdropOpacity", math.max(0, math.min(100, v)) / 100) end },
            { type = "color", name = L["Backdrop color"], desc = L["Panel background color."], dbKey = "backdropColor", get = function() return getDB("backdropColorR", 0.08), getDB("backdropColorG", 0.08), getDB("backdropColorB", 0.12) end, set = function(r, g, b) setDB("backdropColorR", r); setDB("backdropColorG", g); setDB("backdropColorB", b) end },
            { type = "toggle", name = L["Show border"], desc = L["Show border around the tracker."], dbKey = "showBorder", get = function() return getDB("showBorder", false) end, set = function(v) setDB("showBorder", v) end },
            { type = "toggle", name = L["Scroll indicator"], desc = L["Hint when the list is scrollable."], dbKey = "showScrollIndicator", get = function() return getDB("showScrollIndicator", false) end, set = function(v) setDB("showScrollIndicator", v) end, refreshIds = { "scrollIndicatorStyle" } },
            { type = "dropdown", name = L["Scroll indicator style"], desc = L["Choose between a fade-out gradient or a small arrow to indicate scrollable content."], dbKey = "scrollIndicatorStyle", options = { { L["Fade"], "fade" }, { L["Arrow"], "arrow" } }, get = function() return getDB("scrollIndicatorStyle", "fade") end, set = function(v) setDB("scrollIndicatorStyle", v) end, disabled = function() return not getDB("showScrollIndicator", false) end },
            { type = "section", name = L["Visibility & fading"] },
            { type = "dropdown", name = L["Combat visibility"], desc = L["How the tracker behaves in combat: show, fade to reduced opacity, or hide."], dbKey = "combatVisibility", options = { { L["Show"], "show" }, { L["Fade"], "fade" }, { L["Hide"], "hide" } }, get = function() return addon.GetCombatVisibility() end, set = function(v) setDB("combatVisibility", v); if addon.FullLayout then addon.FullLayout() end end },
            { type = "slider", name = L["Combat fade opacity"], desc = L["How visible the tracker is when faded in combat (0 = invisible). Only applies when Combat visibility is Fade."], dbKey = "combatFadeOpacity", min = 0, max = 100, get = function() return math.max(0, math.min(100, tonumber(getDB("combatFadeOpacity", 30)) or 30)) end, set = function(v) setDB("combatFadeOpacity", math.max(0, math.min(100, v))); if addon.FullLayout then addon.FullLayout() end end },
            { type = "toggle", name = L["Mouseover only"], desc = L["Fade out when not hovering."], dbKey = "showOnMouseoverOnly", get = function() return getDB("showOnMouseoverOnly", false) end, set = function(v) setDB("showOnMouseoverOnly", v); if addon.FullLayout then addon.FullLayout() end end },
            { type = "slider", name = L["Faded opacity"], desc = L["How visible the tracker is when faded (0 = invisible)."], dbKey = "fadeOnMouseoverOpacity", min = 0, max = 100, get = function() return math.max(0, math.min(100, tonumber(getDB("fadeOnMouseoverOpacity", 10)) or 10)) end, set = function(v) setDB("fadeOnMouseoverOpacity", math.max(0, math.min(100, v))); if addon.FullLayout then addon.FullLayout() end end },
        },
    },
    {
        key = "Display",
        name = L["Display"],
        desc = L["Customize the visual interface and layout elements."] or "Customize the visual interface and layout elements.",
        moduleKey = "focus",
        options = {
            { type = "section", name = L["Header"] },
            { type = "toggle", name = L["Quest count"], desc = L["Show quest count in header."], dbKey = "showQuestCount", get = function() return getDB("showQuestCount", true) end, set = function(v) setDB("showQuestCount", v) end },
            { type = "dropdown", name = L["Header count format"], desc = L["Tracked vs in-log count."], dbKey = "headerCountMode", options = { { L["Tracked / in log"], "trackedLog" }, { L["In log / max slots"], "logMax" } }, get = function() return getDB("headerCountMode", "trackedLog") end, set = function(v) setDB("headerCountMode", v) end, tooltip = L["Tracked/in-log or in-log/max. Tracked excludes world and in-zone quests."] },
            { type = "toggle", name = L["Header divider"], desc = L["Show the line below the header."], dbKey = "showHeaderDivider", get = function() return getDB("showHeaderDivider", true) end, set = function(v) setDB("showHeaderDivider", v) end },
            { type = "color", name = L["Header divider color"], desc = L["Color of the line below the header."], dbKey = "headerDividerColor", default = addon.DIVIDER_COLOR, hasAlpha = true },
            { type = "color", name = L["Header color"], desc = L["Color of the OBJECTIVES header text."], dbKey = "headerColor", default = addon.HEADER_COLOR },
            { type = "slider", name = L["Header height"], desc = L["Height of the header bar in pixels (18–48)."], dbKey = "headerHeight", min = 18, max = 48, get = function() return math.max(18, math.min(48, tonumber(getDB("headerHeight", addon.HEADER_HEIGHT)) or addon.HEADER_HEIGHT)) end, set = function(v) setDB("headerHeight", math.max(18, math.min(48, v))) end },
            { type = "toggle", name = L["Minimal mode"], desc = L["Hide header for a pure text list."], dbKey = "hideObjectivesHeader", get = function() return getDB("hideObjectivesHeader", false) end, set = function(v) setDB("hideObjectivesHeader", v) end },
            { type = "toggle", name = L["Options button"], desc = L["Show the Options button in the tracker header."], dbKey = "hideOptionsButton", get = function() return not getDB("hideOptionsButton", false) end, set = function(v) setDB("hideOptionsButton", not v) end },
            { type = "section", name = L["List elements"] },
            { type = "toggle", name = L["Section headers"], desc = L["Show category labels above each group."], dbKey = "showSectionHeaders", get = function() return getDB("showSectionHeaders", true) end, set = function(v) setDB("showSectionHeaders", v) end },
            { type = "toggle", name = L["Show section dividers"], desc = L["Show a visual divider line between Focus sections to make categories easier to distinguish."], dbKey = "showSectionDividers", get = function() return getDB("showSectionDividers", false) end, set = function(v) setDB("showSectionDividers", v) end },
            { type = "color", name = L["Section divider color"], desc = L["Color of the divider lines between sections."], dbKey = "sectionDividerColor", default = { 0.3, 0.3, 0.35, 0.4 }, hasAlpha = true },
            { type = "toggle", name = L["Sections when collapsed"], desc = L["Keep section headers visible when collapsed."], dbKey = "showSectionHeadersWhenCollapsed", get = function() return getDB("showSectionHeadersWhenCollapsed", false) end, set = function(v) setDB("showSectionHeadersWhenCollapsed", v) end, tooltip = L["Click a section header to expand that category."] },
            { type = "toggle", name = L["Zone labels"], desc = L["Show zone name under each quest title."], dbKey = "showZoneLabels", get = function() return getDB("showZoneLabels", true) end, set = function(v) setDB("showZoneLabels", v) end },
            { type = "dropdown", name = L["Active quest highlight"], desc = L["How the focused quest is highlighted."], dbKey = "activeQuestHighlight", options = HIGHLIGHT_OPTIONS, get = getActiveQuestHighlight, set = function(v) setDB("activeQuestHighlight", v) end },
            { type = "toggle", name = L["Quest item buttons"], desc = L["Show usable quest item button next to each quest."], dbKey = "showQuestItemButtons", get = function() return getDB("showQuestItemButtons", false) end, set = function(v) setDB("showQuestItemButtons", v) end },
            { type = "dropdown", name = L["Objective prefix"], desc = L["Prefix each objective with a number or hyphen."], dbKey = "objectivePrefixStyle", options = { { L["None"], "none" }, { L["Numbers (1. 2. 3.)"], "numbers" }, { L["Hyphens (-)"], "hyphens" } }, get = function() return getDB("objectivePrefixStyle", "none") end, set = function(v) setDB("objectivePrefixStyle", v) end },
            { type = "toggle", name = L["Entry numbers"], desc = L["Prefix quest titles with 1., 2., 3. within each category."], dbKey = "showCategoryEntryNumbers", get = function() return getDB("showCategoryEntryNumbers", true) end, set = function(v) setDB("showCategoryEntryNumbers", v) end },
            { type = "toggle", name = L["Completed count"], desc = L["Show X/Y progress in quest title."], dbKey = "showCompletedCount", get = function() return getDB("showCompletedCount", false) end, set = function(v) setDB("showCompletedCount", v) end },
            { type = "toggle", name = L["Progress bar"], desc = L["Bar under numeric objectives (e.g. 3/250)."], dbKey = "showObjectiveProgressBar", tooltip = L["Only for entries with a single numeric objective where required > 1."], get = function() return getDB("showObjectiveProgressBar", false) end, set = function(v)
                setDB("showObjectiveProgressBar", v)
                -- Defer refresh until after toggle animation (0.15s) so this toggle animates like the others
                if C_Timer and C_Timer.After and addon.OptionsPanel_Refresh then
                    C_Timer.After(0.2, addon.OptionsPanel_Refresh)
                elseif addon.OptionsPanel_Refresh then
                    addon.OptionsPanel_Refresh()
                end
            end, refreshIds = { "progressBarUseCategoryColor", "progressBarTypeFilter" } },
            { type = "toggle", name = L["Category color for bar"], desc = L["Match bar to quest category color."], dbKey = "progressBarUseCategoryColor", get = function() return getDB("progressBarUseCategoryColor", true) end, set = function(v) setDB("progressBarUseCategoryColor", v) end, disabled = function() return not getDB("showObjectiveProgressBar", false) end, tooltip = L["When off, uses the custom fill color below."] },
            { type = "dropdown", name = L["Progress bar types"], desc = L["Show progress bar for X/Y objectives, percent-only objectives, or both."], dbKey = "progressBarTypeFilter", options = { { L["Both"], "both" }, { L["X/Y only"], "xy_only" }, { L["Percent only"], "percent_only" } }, get = function() return getDB("progressBarTypeFilter", "both") end, set = function(v) setDB("progressBarTypeFilter", v) end, disabled = function() return not getDB("showObjectiveProgressBar", false) end, tooltip = L["X/Y: objectives like 3/10. Percent: objectives like 45%%."] },
            { type = "toggle", name = L["Show timer"], desc = L["Show countdown timer on timed quests, events, and scenarios. When off, timers are hidden for all entry types."], dbKey = "showTimerBars", get = function() return getDB("showTimerBars", false) end, set = function(v) setDB("showTimerBars", v) end },
            { type = "dropdown", name = L["Timer display"], desc = L["Where to show the countdown."], dbKey = "timerDisplayMode", options = { { L["Bar below"], "bar" }, { L["Inline beside title"], "inline" } }, get = function() return getDB("timerDisplayMode", "inline") end, set = function(v) setDB("timerDisplayMode", v) end, disabled = function() return not getDB("showTimerBars", false) end },
            { type = "toggle", name = L["Color timer by remaining time"], desc = L["Color by remaining time."], tooltip = L["Green when plenty of time left, yellow when running low, red when critical."], dbKey = "timerColorByRemaining", get = function() return getDB("timerColorByRemaining", false) end, set = function(v) setDB("timerColorByRemaining", v) end, disabled = function() return not getDB("showTimerBars", false) end },
            { type = "dropdown", name = L["Completed objectives"], desc = L["Display completed objectives."], tooltip = L["For multi-objective quests, how to display objectives you've completed (e.g. 1/1)."], dbKey = "questCompletedObjectiveDisplay", options = { { L["Show all"], "off" }, { L["Fade completed"], "fade" }, { L["Hide completed"], "hide" } }, get = function() return getDB("questCompletedObjectiveDisplay", "off") end, set = function(v) setDB("questCompletedObjectiveDisplay", v) end },
            { type = "toggle", name = L["Checkmark for completed"], desc = L["Use checkmark for completed objectives."], tooltip = L["|TInterface\\Buttons\\UI-CheckBox-Check:12:12:0:0|t instead of green for done objectives."], dbKey = "useTickForCompletedObjectives", get = function() return getDB("useTickForCompletedObjectives", false) end, set = function(v) setDB("useTickForCompletedObjectives", v) end },
            { type = "toggle", name = L["Quest type icons"], desc = L["Show quest type icon in the Focus tracker (quest accept/complete, world quest, quest update)."], dbKey = "showQuestTypeIcons", get = function() return getDB("showQuestTypeIcons", false) end, set = function(v) setDB("showQuestTypeIcons", v) end },
            { type = "toggle", name = L["Auto-track icon"], desc = L["Icon next to auto-tracked in-zone entries."], dbKey = "showInZoneSuffix", get = function() return getDB("showInZoneSuffix", true) end, set = function(v) setDB("showInZoneSuffix", v) end, tooltip = L["For world quests and weeklies not in your quest log."] },
            { type = "dropdown", name = L["Auto-track icon"], desc = L["Choose which icon to display next to auto-tracked in-zone entries."], dbKey = "autoTrackIcon", options = addon.GetRadarIconOptions and addon.GetRadarIconOptions() or {}, get = function() return getDB("autoTrackIcon", "radar1") end, set = function(v) setDB("autoTrackIcon", v) end, disabled = function() return not getDB("showInZoneSuffix", true) end },
            { type = "toggle", name = L["Quest level"], desc = L["Show quest level next to title."], dbKey = "showQuestLevel", get = function() return getDB("showQuestLevel", false) end, set = function(v) setDB("showQuestLevel", v) end },
            { type = "section", name = L["Dimming"] },
            { type = "toggle", name = L["Dim unfocused entries"], desc = L["Dim unfocused tracker entries."], tooltip = L["Slightly dim title, zone, objectives, and section headers that are not focused."], dbKey = "dimNonSuperTracked", get = function() return getDB("dimNonSuperTracked", false) end, set = function(v) setDB("dimNonSuperTracked", v) end, refreshIds = { "dimStrength", "dimAlpha", "dimDesaturate" } },
            { type = "slider", name = L["Dim strength"], desc = L["Dimming strength (0-100%)."], tooltip = L["How much to dim non-focused entries (0 = no dimming, 100 = fully darkened). Default 40%."], dbKey = "dimStrength", min = 0, max = 100, get = function() return math.max(0, math.min(100, tonumber(getDB("dimStrength", 40)) or 40)) end, set = function(v) setDB("dimStrength", math.max(0, math.min(100, v))) end, disabled = function() return not getDB("dimNonSuperTracked", false) end },
            { type = "slider", name = L["Dim alpha"], desc = L["Opacity of unfocused entries."], tooltip = L["Reduce opacity of non-focused entries (0 = invisible, 100 = fully opaque). Default 100% (no alpha change)."], dbKey = "dimAlpha", min = 0, max = 100, get = function() return math.max(0, math.min(100, tonumber(getDB("dimAlpha", 100)) or 100)) end, set = function(v) setDB("dimAlpha", math.max(0, math.min(100, v))) end, disabled = function() return not getDB("dimNonSuperTracked", false) end },
            { type = "toggle", name = L["Desaturate non-focused quests"], desc = L["Desaturate non-focused entries."], tooltip = L["Make non-focused entries greyscale/partially desaturated in addition to dimming."], dbKey = "dimDesaturate", get = function() return getDB("dimDesaturate", false) end, set = function(v) setDB("dimDesaturate", v) end, disabled = function() return not getDB("dimNonSuperTracked", false) end },
            { type = "section", name = L["Highlighting"] },
            { type = "slider", name = L["Highlight alpha"], desc = L["Opacity of focused quest highlight (0–100%)."], dbKey = "highlightAlpha", min = 0, max = 100, get = function() local v = tonumber(getDB("highlightAlpha", 0.25)) or 0.25; if v <= 1 and v > 0 then return math.floor(v * 100 + 0.5) end; return math.max(0, math.min(100, v)) end, set = function(v) setDB("highlightAlpha", math.max(0, math.min(100, v)) / 100) end },
            { type = "slider", name = L["Bar width"], desc = L["Width of bar-style highlights (2–6 px)."], dbKey = "highlightBarWidth", min = 2, max = 6, get = function() return math.max(2, math.min(6, tonumber(getDB("highlightBarWidth", 2)) or 2)) end, set = function(v) setDB("highlightBarWidth", math.max(2, math.min(6, v))) end },
        },
    },
    {
        key = "SortingFiltering",
        name = L["Sorting & Filtering"],
        desc = L["Organize and hide tracked entries to your preference."] or "Organize and hide tracked entries to your preference.",
        moduleKey = "focus",
        options = {
            { type = "section", name = L["Filtering"] },
            { type = "toggle", name = L["Current zone only"], desc = L["Hide quests outside your current zone."], dbKey = "filterByZone", get = function() return getDB("filterByZone", false) end, set = function(v) setDB("filterByZone", v) end },
            { type = "section", name = L["Grouping"] },
            { type = "toggle", name = L["Current Quest category"], desc = L["Show recent progress at the top."], tooltip = L["Quests you made progress on in the last minute appear in a dedicated section."], dbKey = "showCurrentQuestCategory", get = function() return getDB("showCurrentQuestCategory", true) end, set = function(v) setDB("showCurrentQuestCategory", v) end, refreshIds = { "currentQuestWindowSec" } },
            { type = "slider", name = L["Current Quest window"], desc = L["Seconds of recent progress to show."], dbKey = "currentQuestWindowSec", min = 30, max = 120, get = function() return math.max(30, math.min(120, tonumber(getDB("currentQuestWindowSec", 60)) or 60)) end, set = function(v) setDB("currentQuestWindowSec", math.max(30, math.min(120, v))) end, disabled = function() return not getDB("showCurrentQuestCategory", true) end, id = "currentQuestWindowSec" },
            { type = "toggle", name = L["Current Zone group"], desc = L["Dedicated section for in-zone quests."], dbKey = "showNearbyGroup", get = function() return getDB("showNearbyGroup", true) end, set = function(v) setDB("showNearbyGroup", v) end, tooltip = L["When off, in-zone quests appear in their normal category."] },
            { type = "toggle", name = L["Ready to turn in at bottom"], desc = L["Move completed quests to the bottom of the Current Zone section."], dbKey = "nearbyCompleteToBottom", get = function() return getDB("nearbyCompleteToBottom", true) end, set = function(v) setDB("nearbyCompleteToBottom", v); OptionsData_NotifyMainAddon() end, disabled = function() return not getDB("showNearbyGroup", true) end },
            { type = "section", name = L["Sorting"] },
            { type = "reorderList", name = L["Category order"], labelMap = addon.SECTION_LABELS, presets = addon.GROUP_ORDER_PRESETS, get = function() return addon.GetGroupOrder() end, set = function(order) addon.SetGroupOrder(order) end, desc = L["Drag to reorder. Delves and Scenarios stay first."] },
            { type = "dropdown", name = L["Sort mode"], desc = L["Order of entries within each category."], dbKey = "entrySortMode", options = { { L["Alphabetical"], "alpha" }, { L["Quest Type"], "questType" }, { L["Zone"], "zone" }, { L["Quest Level"], "level" } }, get = function() return getDB("entrySortMode", "questType") end, set = function(v) setDB("entrySortMode", v) end },
        },
    },
    {
        key = "Typography",
        name = L["Typography"],
        desc = L["Adjust fonts, sizes, casing, and drop shadows."] or "Adjust fonts, sizes, casing, and drop shadows.",
        moduleKey = "focus",
        options = {
            { type = "section", name = L["Font"] },
            { type = "dropdown", name = L["Font"], desc = L["Font family."], dbKey = "fontPath", options = GetFontDropdownOptions, get = function() return getDB("fontPath", defaultFontPath) end, set = function(v) setDB("fontPath", v) end, displayFn = addon.GetFontNameForPath },
            { type = "dropdown", name = L["Title font"], desc = L["Font family for quest titles."], dbKey = "titleFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("titleFontPath") end, get = function() return getDB("titleFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("titleFontPath", v) end, displayFn = DisplayPerElementFont },
            { type = "dropdown", name = L["Zone font"], desc = L["Font family for zone labels."], dbKey = "zoneFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("zoneFontPath") end, get = function() return getDB("zoneFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("zoneFontPath", v) end, displayFn = DisplayPerElementFont },
            { type = "dropdown", name = L["Objective font"], desc = L["Font family for objective text."], dbKey = "objectiveFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("objectiveFontPath") end, get = function() return getDB("objectiveFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("objectiveFontPath", v) end, displayFn = DisplayPerElementFont },
            { type = "dropdown", name = L["Section font"], desc = L["Font family for section headers."], dbKey = "sectionFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("sectionFontPath") end, get = function() return getDB("sectionFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("sectionFontPath", v) end, displayFn = DisplayPerElementFont },
            { type = "dropdown", name = L["Progress bar font"], desc = L["Font family for the progress bar label."], dbKey = "progressBarFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("progressBarFontPath") end, get = function() return getDB("progressBarFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("progressBarFontPath", v) end, displayFn = DisplayPerElementFont },
            { type = "slider", name = L["Header size"], desc = L["Header font size."], dbKey = "headerFontSize", min = 8, max = 32, get = function() return getDB("headerFontSize", 16) end, set = function(v) setDB("headerFontSize", v) end },
            { type = "slider", name = L["Title size"], desc = L["Quest title font size."], dbKey = "titleFontSize", min = 8, max = 24, get = function() return getDB("titleFontSize", 13) end, set = function(v) setDB("titleFontSize", v) end },
            { type = "slider", name = L["Objective size"], desc = L["Objective text font size."], dbKey = "objectiveFontSize", min = 8, max = 20, get = function() return getDB("objectiveFontSize", 11) end, set = function(v) setDB("objectiveFontSize", v) end },
            { type = "slider", name = L["Zone size"], desc = L["Zone label font size."], dbKey = "zoneFontSize", min = 8, max = 18, get = function() return getDB("zoneFontSize", 10) end, set = function(v) setDB("zoneFontSize", v) end },
            { type = "slider", name = L["Section size"], desc = L["Section header font size."], dbKey = "sectionFontSize", min = 8, max = 18, get = function() return getDB("sectionFontSize", 10) end, set = function(v) setDB("sectionFontSize", v) end },
            { type = "slider", name = L["Progress bar text size"], desc = L["Font size for bar label and bar height."], dbKey = "progressBarFontSize", min = 7, max = 18, get = function() return getDB("progressBarFontSize", 10) end, set = function(v) setDB("progressBarFontSize", v) end, tooltip = L["Also affects scenario progress and timer bars."] },
            { type = "dropdown", name = L["Outline"], desc = L["Font outline style."], dbKey = "fontOutline", options = OUTLINE_OPTIONS, get = function() return getDB("fontOutline", "OUTLINE") end, set = function(v) setDB("fontOutline", v) end },
            { type = "section", name = L["Text case"] },
            { type = "dropdown", name = L["Header text case"], desc = L["Display case for header."], dbKey = "headerTextCase", options = TEXT_CASE_OPTIONS, get = function() local v = getDB("headerTextCase", "proper"); return (v == "default") and "proper" or v end, set = function(v) setDB("headerTextCase", v) end },
            { type = "dropdown", name = L["Section header case"], desc = L["Display case for category labels."], dbKey = "sectionHeaderTextCase", options = TEXT_CASE_OPTIONS, get = function() local v = getDB("sectionHeaderTextCase", "proper"); return (v == "default") and "proper" or v end, set = function(v) setDB("sectionHeaderTextCase", v) end },
            { type = "dropdown", name = L["Quest title case"], desc = L["Display case for quest titles."], dbKey = "questTitleCase", options = TEXT_CASE_OPTIONS, get = function() local v = getDB("questTitleCase", "proper"); return (v == "default") and "proper" or v end, set = function(v) setDB("questTitleCase", v) end },
            { type = "section", name = L["Shadow"] },
            { type = "toggle", name = L["Show text shadow"], desc = L["Enable drop shadow on text."], dbKey = "showTextShadow", get = function() return getDB("showTextShadow", true) end, set = function(v) setDB("showTextShadow", v) end },
            { type = "slider", name = L["Shadow X"], desc = L["Horizontal shadow offset."], dbKey = "shadowOffsetX", min = -10, max = 10, get = function() return getDB("shadowOffsetX", 2) end, set = function(v) setDB("shadowOffsetX", v) end },
            { type = "slider", name = L["Shadow Y"], desc = L["Vertical shadow offset."], dbKey = "shadowOffsetY", min = -10, max = 10, get = function() return getDB("shadowOffsetY", -2) end, set = function(v) setDB("shadowOffsetY", v) end },
            { type = "slider", name = L["Shadow alpha"], desc = L["Shadow opacity (0–100%)."], dbKey = "shadowAlpha", min = 0, max = 100, get = function() local v = tonumber(getDB("shadowAlpha", 0.8)) or 0.8; if v <= 1 and v > 0 then return math.floor(v * 100 + 0.5) end; return math.max(0, math.min(100, v)) end, set = function(v) setDB("shadowAlpha", math.max(0, math.min(100, v)) / 100) end },
        },
    },
    {
        key = "Interactions",
        name = L["Interactions"],
        desc = L["Configure click behaviors, tracking rules, and TomTom integration."] or "Configure click behaviors, tracking rules, and TomTom integration.",
        moduleKey = "focus",
        options = {
            { type = "section", name = L["Click behavior"] },
            { type = "toggle", name = L["Ctrl for focus / untrack"], desc = L["Prevent accidental clicks."], dbKey = "requireCtrlForQuestClicks", get = function() return getDB("requireCtrlForQuestClicks", false) end, set = function(v) setDB("requireCtrlForQuestClicks", v) end, tooltip = L["Ctrl+Left = focus/add, Ctrl+Right = unfocus/untrack."] },
            { type = "toggle", name = L["Classic clicks"], desc = L["L-click opens map, R-click opens menu."], dbKey = "useClassicClickBehaviour", get = function() return getDB("useClassicClickBehaviour", false) end, set = function(v) setDB("useClassicClickBehaviour", v) end, tooltip = L["Off: L-click focuses, R-click untracks. Ctrl+Right shares."] },
            { type = "toggle", name = L["Ctrl to click-complete"], desc = L["Require Ctrl to complete click-completable quests."], dbKey = "requireModifierForClickToComplete", get = function() return getDB("requireModifierForClickToComplete", false) end, set = function(v) setDB("requireModifierForClickToComplete", v) end, tooltip = L["Only for quests that don't need NPC turn-in. Off = Blizzard default."] },
            { type = "section", name = L["Quest tracking"] },
            { type = "toggle", name = L["Keep campaign in category"], desc = L["Keep in Campaign when ready to turn in."], dbKey = "keepCampaignInCategory", get = function() return getDB("keepCampaignInCategory", false) end, set = function(v) setDB("keepCampaignInCategory", v); if addon.RequestRefresh then addon.RequestRefresh() end; if addon.FullLayout then addon.FullLayout() end end, tooltip = L["When off, they move to the Complete section."] },
            { type = "toggle", name = L["Keep important in category"], desc = L["Keep in Important when ready to turn in."], dbKey = "keepImportantInCategory", get = function() return getDB("keepImportantInCategory", false) end, set = function(v) setDB("keepImportantInCategory", v); if addon.RequestRefresh then addon.RequestRefresh() end; if addon.FullLayout then addon.FullLayout() end end, tooltip = L["When off, they move to the Complete section."] },
            { type = "toggle", name = L["Auto-track accepted quests"], desc = L["When you accept a quest (quest log only, not world quests), add it to the tracker automatically."], dbKey = "autoTrackOnAccept", get = function() return getDB("autoTrackOnAccept", true) end, set = function(v) setDB("autoTrackOnAccept", v) end },
            { type = "toggle", name = L["Suppress untracked until reload"], desc = L["Hide untracked quests until reload."], tooltip = L["When on, right-click untrack on world quests and in-zone weeklies/dailies hides them until you reload or start a new session. When off, they reappear when you return to the zone."], dbKey = "suppressUntrackedUntilReload", get = function() return getDB("suppressUntrackedUntilReload", false) end, set = function(v) setDB("suppressUntrackedUntilReload", v) end },
            { type = "toggle", name = L["Blacklist untracked"], desc = L["Permanently hide untracked quests."], dbKey = "permanentlySuppressUntracked", get = function() return getDB("permanentlySuppressUntracked", false) end, set = function(v) setDB("permanentlySuppressUntracked", v) end, tooltip = L["Takes priority over suppress-until-reload. Accepting removes from blacklist."] },
            { type = "toggle", name = L["TomTom quest waypoint"], desc = L["Set a TomTom waypoint when focusing a quest."], dbKey = "tomtomQuestWaypoint", get = function() return getDB("tomtomQuestWaypoint", false) end, set = function(v) setDB("tomtomQuestWaypoint", v) end, tooltip = L["Requires TomTom. Points the arrow to the next quest objective."] },
        },
    },
    {
        key = "Animations",
        name = L["Animations"],
        desc = L["Tune slide and fade effects, plus objective progress flashes."] or "Tune slide and fade effects, plus objective progress flashes.",
        moduleKey = "focus",
        options = {
            { type = "section", name = L["Focus animations"] },
            { type = "toggle", name = L["Animations"], desc = L["Enable slide and fade for quests."], dbKey = "animations", get = function() return getDB("animations", true) end, set = function(v) setDB("animations", v) end },
            { type = "section", name = L["Objective progress"] },
            { type = "toggle", name = L["Objective progress flash"], desc = L["Show flash when an objective completes."], dbKey = "objectiveProgressFlash", get = function() return getDB("objectiveProgressFlash", true) end, set = function(v) setDB("objectiveProgressFlash", v) end },
            { type = "dropdown", name = L["Flash intensity"], desc = L["How noticeable the objective-complete flash is."], dbKey = "objectiveProgressFlashIntensity", options = { { L["Subtle"], "subtle" }, { L["Medium"], "medium" }, { L["Strong"], "strong" } }, get = function() return getDB("objectiveProgressFlashIntensity", "subtle") end, set = function(v) setDB("objectiveProgressFlashIntensity", v) end },
            { type = "color", name = L["Flash color"], desc = L["Color of the objective-complete flash."], dbKey = "objectiveProgressFlashColor", default = { 1, 1, 1 } },
        },
    },
    {
        key = "Instances",
        name = L["Instances"],
        desc = L["Control tracker visibility within dungeons, raids, and PvP."] or "Control tracker visibility within dungeons, raids, and PvP.",
        moduleKey = "focus",
        options = {
            { type = "section", name = L["Visibility"] },
            { type = "toggle", name = L["In dungeon"], desc = L["Show tracker in party dungeons (master toggle for all dungeon difficulties)."], dbKey = "showInDungeon", get = function() return getDB("showInDungeon", true) end, set = function(v) setDB("showInDungeon", v) end },
            { type = "toggle", name = L["  Normal dungeon"], desc = L["Show in Normal dungeons."], tooltip = L["Show tracker in Normal dungeons. When unset, uses the master dungeon toggle."], dbKey = "showInDungeonNormal", get = function() local v = getDB("showInDungeonNormal", nil); if v ~= nil then return v end; return getDB("showInDungeon", true) end, set = function(v) setDB("showInDungeonNormal", v) end },
            { type = "toggle", name = L["  Heroic dungeon"], desc = L["Show tracker in Heroic dungeons. When unset, uses the master dungeon toggle."], dbKey = "showInDungeonHeroic", get = function() local v = getDB("showInDungeonHeroic", nil); if v ~= nil then return v end; return getDB("showInDungeon", true) end, set = function(v) setDB("showInDungeonHeroic", v) end },
            { type = "toggle", name = L["  Mythic dungeon"], desc = L["Show tracker in Mythic dungeons. When unset, uses the master dungeon toggle."], dbKey = "showInDungeonMythic", get = function() local v = getDB("showInDungeonMythic", nil); if v ~= nil then return v end; return getDB("showInDungeon", true) end, set = function(v) setDB("showInDungeonMythic", v) end },
            { type = "toggle", name = L["  Mythic+ dungeon"], desc = L["Show tracker in Mythic Keystone (M+) dungeons. When unset, uses the master dungeon toggle."], dbKey = "showInDungeonMythicPlus", get = function() local v = getDB("showInDungeonMythicPlus", nil); if v ~= nil then return v end; return getDB("showInDungeon", true) end, set = function(v) setDB("showInDungeonMythicPlus", v) end },
            { type = "toggle", name = L["In raid"], desc = L["Show tracker in raids (master toggle for all raid difficulties)."], dbKey = "showInRaid", get = function() return getDB("showInRaid", false) end, set = function(v) setDB("showInRaid", v) end },
            { type = "toggle", name = L["  LFR"], desc = L["Show tracker in Looking for Raid. When unset, uses the master raid toggle."], dbKey = "showInRaidLFR", get = function() local v = getDB("showInRaidLFR", nil); if v ~= nil then return v end; return getDB("showInRaid", false) end, set = function(v) setDB("showInRaidLFR", v) end },
            { type = "toggle", name = L["  Normal raid"], desc = L["Show tracker in Normal raids. When unset, uses the master raid toggle."], dbKey = "showInRaidNormal", get = function() local v = getDB("showInRaidNormal", nil); if v ~= nil then return v end; return getDB("showInRaid", false) end, set = function(v) setDB("showInRaidNormal", v) end },
            { type = "toggle", name = L["  Heroic raid"], desc = L["Show tracker in Heroic raids. When unset, uses the master raid toggle."], dbKey = "showInRaidHeroic", get = function() local v = getDB("showInRaidHeroic", nil); if v ~= nil then return v end; return getDB("showInRaid", false) end, set = function(v) setDB("showInRaidHeroic", v) end },
            { type = "toggle", name = L["  Mythic raid"], desc = L["Show tracker in Mythic raids. When unset, uses the master raid toggle."], dbKey = "showInRaidMythic", get = function() local v = getDB("showInRaidMythic", nil); if v ~= nil then return v end; return getDB("showInRaid", false) end, set = function(v) setDB("showInRaidMythic", v) end },
            { type = "toggle", name = L["In battleground"], desc = L["Show tracker in battlegrounds."], dbKey = "showInBattleground", get = function() return getDB("showInBattleground", false) end, set = function(v) setDB("showInBattleground", v) end },
            { type = "toggle", name = L["In arena"], desc = L["Show tracker in arenas."], dbKey = "showInArena", get = function() return getDB("showInArena", false) end, set = function(v) setDB("showInArena", v) end },
            { type = "section", name = L["Mythic+ Block"] },
            { type = "toggle", name = L["Enable M+ block"], desc = L["Show timer, completion %, and affixes in Mythic+ dungeons."], dbKey = "showMythicPlusBlock", get = function() return getDB("showMythicPlusBlock", true) end, set = function(v) setDB("showMythicPlusBlock", v) end },
            { type = "toggle", name = L["Always show"], desc = L["Always show M+ timer."], tooltip = L["Show the M+ block whenever an active keystone is running."], dbKey = "mplusAlwaysShow", get = function() return getDB("mplusAlwaysShow", false) end, set = function(v) setDB("mplusAlwaysShow", v); if addon.FullLayout then addon.FullLayout() end end },
            { type = "toggle", name = L["Affix icons"], desc = L["Show affix icons next to modifier names in the M+ block."], dbKey = "mplusShowAffixIcons", get = function() return getDB("mplusShowAffixIcons", true) end, set = function(v) setDB("mplusShowAffixIcons", v) end },
            { type = "toggle", name = L["Affix tooltips"], desc = L["Show affix descriptions when hovering over the M+ block."], dbKey = "mplusShowAffixDescriptions", get = function() return getDB("mplusShowAffixDescriptions", true) end, set = function(v) setDB("mplusShowAffixDescriptions", v) end },
            { type = "dropdown", name = L["Block position"], desc = L["Position of the Mythic+ block relative to the quest list."], dbKey = "mplusBlockPosition", options = MPLUS_POSITION_OPTIONS, get = function() return getDB("mplusBlockPosition", "top") end, set = function(v) setDB("mplusBlockPosition", v) end },
            { type = "dropdown", name = L["Completed boss style"], desc = L["Defeated boss style."], tooltip = L["How to show defeated bosses: checkmark icon or green color."], dbKey = "mplusBossCompletedDisplay", options = { { L["Checkmark"], "tick" }, { L["Green color"], "green" } }, get = function() return getDB("mplusBossCompletedDisplay", "tick") end, set = function(v) setDB("mplusBossCompletedDisplay", v); if addon.UpdateMplusBlock then addon.UpdateMplusBlock() end end },
            { type = "section", name = L["Mythic+ Typography"], defaultCollapsed = true },
            { type = "slider", name = L["Dungeon name size"], desc = L["Font size for dungeon name (8–32 px)."], dbKey = "mplusDungeonSize", min = 8, max = 32, step = 1, get = function() return math.max(8, math.min(32, tonumber(getDB("mplusDungeonSize", 14)) or 14)) end, set = function(v) setDB("mplusDungeonSize", math.max(8, math.min(32, v))) end },
            { type = "slider", name = L["Timer size"], desc = L["Font size for timer (8–32 px)."], dbKey = "mplusTimerSize", min = 8, max = 32, step = 1, get = function() return math.max(8, math.min(32, tonumber(getDB("mplusTimerSize", 13)) or 13)) end, set = function(v) setDB("mplusTimerSize", math.max(8, math.min(32, v))) end },
            { type = "slider", name = L["Enemy forces size"], desc = L["Font size for enemy forces (8–32 px)."], dbKey = "mplusProgressSize", min = 8, max = 32, step = 1, get = function() return math.max(8, math.min(32, tonumber(getDB("mplusProgressSize", 12)) or 12)) end, set = function(v) setDB("mplusProgressSize", math.max(8, math.min(32, v))) end },
            { type = "slider", name = L["Affix size"], desc = L["Font size for affixes (8–32 px)."], dbKey = "mplusAffixSize", min = 8, max = 32, step = 1, get = function() return math.max(8, math.min(32, tonumber(getDB("mplusAffixSize", 12)) or 12)) end, set = function(v) setDB("mplusAffixSize", math.max(8, math.min(32, v))) end },
            { type = "slider", name = L["Boss size"], desc = L["Font size for boss names (8–32 px)."], dbKey = "mplusBossSize", min = 8, max = 32, step = 1, get = function() return math.max(8, math.min(32, tonumber(getDB("mplusBossSize", 12)) or 12)) end, set = function(v) setDB("mplusBossSize", math.max(8, math.min(32, v))) end },
            { type = "section", name = L["Mythic+ Colors"], defaultCollapsed = true },
            { type = "color", name = L["Dungeon name color"], desc = L["Text color for dungeon name."], dbKey = "mplusDungeonColor", get = function() return getDB("mplusDungeonColorR", 0.96), getDB("mplusDungeonColorG", 0.96), getDB("mplusDungeonColorB", 1.0) end, set = function(r, g, b) setDB("mplusDungeonColorR", r); setDB("mplusDungeonColorG", g); setDB("mplusDungeonColorB", b) end },
            { type = "color", name = L["Timer color"], desc = L["Text color for timer (in time)."], dbKey = "mplusTimerColor", get = function() return getDB("mplusTimerColorR", 0.6), getDB("mplusTimerColorG", 0.88), getDB("mplusTimerColorB", 1.0) end, set = function(r, g, b) setDB("mplusTimerColorR", r); setDB("mplusTimerColorG", g); setDB("mplusTimerColorB", b) end },
            { type = "color", name = L["Timer overtime color"], desc = L["Text color for timer when over the time limit."], dbKey = "mplusTimerOvertimeColor", get = function() return getDB("mplusTimerOvertimeColorR", 0.9), getDB("mplusTimerOvertimeColorG", 0.25), getDB("mplusTimerOvertimeColorB", 0.2) end, set = function(r, g, b) setDB("mplusTimerOvertimeColorR", r); setDB("mplusTimerOvertimeColorG", g); setDB("mplusTimerOvertimeColorB", b) end },
            { type = "color", name = L["Enemy forces color"], desc = L["Text color for enemy forces."], dbKey = "mplusProgressColor", get = function() return getDB("mplusProgressColorR", 0.72), getDB("mplusProgressColorG", 0.76), getDB("mplusProgressColorB", 0.88) end, set = function(r, g, b) setDB("mplusProgressColorR", r); setDB("mplusProgressColorG", g); setDB("mplusProgressColorB", b) end },
            { type = "color", name = L["Bar fill color"], desc = L["Progress bar fill color (in progress)."], dbKey = "mplusBarColor", get = function() return getDB("mplusBarColorR", 0.20), getDB("mplusBarColorG", 0.45), getDB("mplusBarColorB", 0.60), getDB("mplusBarColorA", 0.90) end, set = function(r, g, b, a) setDB("mplusBarColorR", r); setDB("mplusBarColorG", g); setDB("mplusBarColorB", b); if a then setDB("mplusBarColorA", a) end end, hasAlpha = true },
            { type = "color", name = L["Bar complete color"], desc = L["Progress bar fill color when enemy forces are at 100%."], dbKey = "mplusBarDoneColor", get = function() return getDB("mplusBarDoneColorR", 0.15), getDB("mplusBarDoneColorG", 0.65), getDB("mplusBarDoneColorB", 0.25), getDB("mplusBarDoneColorA", 0.90) end, set = function(r, g, b, a) setDB("mplusBarDoneColorR", r); setDB("mplusBarDoneColorG", g); setDB("mplusBarDoneColorB", b); if a then setDB("mplusBarDoneColorA", a) end end, hasAlpha = true },
            { type = "color", name = L["Affix color"], desc = L["Text color for affixes."], dbKey = "mplusAffixColor", get = function() return getDB("mplusAffixColorR", 0.85), getDB("mplusAffixColorG", 0.85), getDB("mplusAffixColorB", 0.95) end, set = function(r, g, b) setDB("mplusAffixColorR", r); setDB("mplusAffixColorG", g); setDB("mplusAffixColorB", b) end },
            { type = "color", name = L["Boss color"], desc = L["Text color for boss names."], dbKey = "mplusBossColor", get = function() return getDB("mplusBossColorR", 0.78), getDB("mplusBossColorG", 0.82), getDB("mplusBossColorB", 0.92) end, set = function(r, g, b) setDB("mplusBossColorR", r); setDB("mplusBossColorG", g); setDB("mplusBossColorB", b) end },
            { type = "button", name = L["Reset Mythic+ styling"], onClick = function()
                setDB("mplusDungeonSize", 14)
                setDB("mplusDungeonColorR", 0.96); setDB("mplusDungeonColorG", 0.96); setDB("mplusDungeonColorB", 1.0)
                setDB("mplusTimerSize", 13)
                setDB("mplusTimerColorR", 0.6); setDB("mplusTimerColorG", 0.88); setDB("mplusTimerColorB", 1.0)
                setDB("mplusTimerOvertimeColorR", 0.9); setDB("mplusTimerOvertimeColorG", 0.25); setDB("mplusTimerOvertimeColorB", 0.2)
                setDB("mplusProgressSize", 12)
                setDB("mplusProgressColorR", 0.72); setDB("mplusProgressColorG", 0.76); setDB("mplusProgressColorB", 0.88)
                setDB("mplusBarColorR", 0.20); setDB("mplusBarColorG", 0.45); setDB("mplusBarColorB", 0.60); setDB("mplusBarColorA", 0.90)
                setDB("mplusBarDoneColorR", 0.15); setDB("mplusBarDoneColorG", 0.65); setDB("mplusBarDoneColorB", 0.25); setDB("mplusBarDoneColorA", 0.90)
                setDB("mplusAffixSize", 12)
                setDB("mplusAffixColorR", 0.85); setDB("mplusAffixColorG", 0.85); setDB("mplusAffixColorB", 0.95)
                setDB("mplusBossSize", 12)
                setDB("mplusBossColorR", 0.78); setDB("mplusBossColorG", 0.82); setDB("mplusBossColorB", 0.92)
            end, refreshIds = { "mplusDungeonSize", "mplusDungeonColor", "mplusTimerSize", "mplusTimerColor", "mplusTimerOvertimeColor", "mplusProgressSize", "mplusProgressColor", "mplusBarColor", "mplusBarDoneColor", "mplusAffixSize", "mplusAffixColor", "mplusBossSize", "mplusBossColor" } },
            { type = "section", name = L["Delves & Dungeons"] },
            { type = "toggle", name = L["Scenario events"], desc = L["Track Delve, Dungeon, and scenario activities."], dbKey = "showScenarioEvents", get = function() return getDB("showScenarioEvents", true) end, set = function(v) setDB("showScenarioEvents", v) end, tooltip = L["Delves appear in Delves section; dungeons in Dungeon; other scenarios in Scenario Events."] },
            { type = "toggle", name = L["Active instance only"], desc = L["Show only the active instance section."], dbKey = "hideOtherCategoriesInDelve", get = function() return getDB("hideOtherCategoriesInDelve", false) end, set = function(v) setDB("hideOtherCategoriesInDelve", v) end, tooltip = L["Hides other categories while in a Delve or party dungeon."] },
            { type = "toggle", name = L["Delve affix names"], desc = L["Show affix names on first Delve entry."], dbKey = "showDelveAffixes", get = function() return getDB("showDelveAffixes", getDB("delveBlockShowAffixes", true)) end, set = function(v) setDB("showDelveAffixes", v); if addon.ScheduleRefresh then addon.ScheduleRefresh() end end, tooltip = L["May not appear with full tracker replacements."] },
            { type = "section", name = L["Scenario Bar"] },
            { type = "toggle", name = L["Scenario timer bar"], desc = L["Show timer and progress bar for scenario entries."], dbKey = "cinematicScenarioBar", get = function() return getDB("cinematicScenarioBar", true) end, set = function(v) setDB("cinematicScenarioBar", v) end },
            { type = "toggle", name = L["Scenario debug logging"], desc = L["Log scenario API data to chat. Use /h debug focus scendebug to toggle."], dbKey = "scenarioDebug", get = function() return getDB("scenarioDebug", false) end, set = function(v) setDB("scenarioDebug", v); if addon.ScheduleRefresh then addon.ScheduleRefresh() end end, tooltip = L["Prints C_ScenarioInfo criteria and widget data when in a scenario. Helps diagnose display issues like Abundance 46/300."] },
        },
    },
    {
        key = "ContentTypes",
        name = L["Content"],
        desc = L["Toggle tracking for world quests, rares, achievements, and more."] or "Toggle tracking for world quests, rares, achievements, and more.",
        moduleKey = "focus",
        options = {
            { type = "section", name = L["World quests"] },
            { type = "toggle", name = L["In-zone world quests"], desc = L["Auto-add WQs in your current zone."], dbKey = "showWorldQuests", get = function() return getDB("showWorldQuests", true) end, set = function(v) setDB("showWorldQuests", v) end, tooltip = L["Off: only tracked or nearby WQs appear (Blizzard default)."] },
            { type = "section", name = L["Rare bosses"] },
            { type = "toggle", name = L["Rare bosses"], desc = L["Show rare boss vignettes in the list."], dbKey = "showRareBosses", get = function() return getDB("showRareBosses", true) end, set = function(v) setDB("showRareBosses", v) end },
            { type = "toggle", name = L["Rare sound alert"], desc = L["Play a sound when a rare is added."], dbKey = "rareAddedSound", get = function() return getDB("rareAddedSound", true) end, set = function(v) setDB("rareAddedSound", v) end, refreshIds = { "rareAddedSoundChoice" } },
            { type = "dropdown", name = L["Rare added sound choice"] or "Rare added sound choice", desc = L["Sound played when a rare boss appears."], tooltip = L["Choose which sound to play when a rare boss appears. Requires LibSharedMedia sounds to be installed for extra options."], dbKey = "rareAddedSoundChoice", options = function() return addon.GetSoundDropdownOptions and addon.GetSoundDropdownOptions() or { { "Default", "default" } } end, get = function() return getDB("rareAddedSoundChoice", "default") end, set = function(v) setDB("rareAddedSoundChoice", v); if addon.PlayRareAddedSound then addon.PlayRareAddedSound() end end, disabled = function() return not getDB("rareAddedSound", true) end },
            { type = "section", name = L["Achievements"] },
            { type = "toggle", name = L["Achievements"], desc = L["Show tracked achievements in the list."], dbKey = "showAchievements", get = function() return getDB("showAchievements", true) end, set = function(v) setDB("showAchievements", v) end },
            { type = "toggle", name = L["Include completed"], desc = L["Show completed achievements in the list."], dbKey = "showCompletedAchievements", get = function() return getDB("showCompletedAchievements", false) end, set = function(v) setDB("showCompletedAchievements", v) end, tooltip = L["Off: only in-progress tracked achievements shown."] },
            { type = "toggle", name = L["Achievement icons"], desc = L["Icon next to achievement title."], dbKey = "showAchievementIcons", get = function() return getDB("showAchievementIcons", true) end, set = function(v) setDB("showAchievementIcons", v) end, tooltip = L["Requires quest type icons to be enabled in Display."] },
            { type = "toggle", name = L["Missing criteria only"], desc = L["Only show incomplete criteria."], tooltip = L["Show only criteria you haven't completed for each tracked achievement. When off, all criteria are shown."], dbKey = "achievementOnlyMissingRequirements", get = function() return getDB("achievementOnlyMissingRequirements", false) end, set = function(v) setDB("achievementOnlyMissingRequirements", v) end },
            { type = "section", name = L["Endeavors"] },
            { type = "toggle", name = L["Endeavors"], desc = L["Show tracked Endeavors (Player Housing) in the list."], dbKey = "showEndeavors", get = function() return getDB("showEndeavors", true) end, set = function(v) setDB("showEndeavors", v) end },
            { type = "toggle", name = L["Include completed"], desc = L["Include completed Endeavors in the tracker. When off, only in-progress tracked Endeavors are shown."], dbKey = "showCompletedEndeavors", get = function() return getDB("showCompletedEndeavors", false) end, set = function(v) setDB("showCompletedEndeavors", v) end },
            { type = "section", name = L["Decor"] },
            { type = "toggle", name = L["Decor"], desc = L["Show tracked housing decor in the list."], dbKey = "showDecor", get = function() return getDB("showDecor", true) end, set = function(v) setDB("showDecor", v) end },
            { type = "toggle", name = L["Decor icons"], desc = L["Show each decor item's icon next to the title. Requires 'Show quest type icons' in Display."], dbKey = "showDecorIcons", get = function() return getDB("showDecorIcons", true) end, set = function(v) setDB("showDecorIcons", v) end },
            { type = "section", name = L["Recipes"] or "Recipes" },
            { type = "toggle", name = L["Recipes"] or "Recipes", desc = (L and L["Show tracked profession recipes in the list."]) or "Show tracked profession recipes in the list.", dbKey = "showRecipes", get = function() return getDB("showRecipes", true) end, set = function(v) setDB("showRecipes", v) end },
            { type = "toggle", name = L["Reagents"] or "Reagents", desc = (L and L["Show reagent shopping list for each recipe."]) or "Show reagent shopping list for each recipe.", dbKey = "showRecipeReagents", get = function() return getDB("showRecipeReagents", true) end, set = function(v) setDB("showRecipeReagents", v) end },
            { type = "toggle", name = L["Optional reagents"] or "Optional reagents", desc = (L and L["Show optional reagent slots."]) or "Show optional reagent slots.", dbKey = "showOptionalReagents", get = function() return getDB("showOptionalReagents", true) end, set = function(v) setDB("showOptionalReagents", v) end },
            { type = "toggle", name = L["Finishing reagents"] or "Finishing reagents", desc = (L and L["Show finishing reagent slots."]) or "Show finishing reagent slots.", dbKey = "showFinishingReagents", get = function() return getDB("showFinishingReagents", true) end, set = function(v) setDB("showFinishingReagents", v) end },
            { type = "toggle", name = L["Choice slots"] or "Choice slots", desc = (L and L["Show collapsible choice reagent slots."]) or "Show collapsible choice reagent slots.", dbKey = "showChoiceSlots", get = function() return getDB("showChoiceSlots", true) end, set = function(v) setDB("showChoiceSlots", v) end },
            { type = "toggle", name = L["Recipe icons"] or "Recipe icons", desc = (L and L["Show recipe icon next to title. Requires quest type icons in Display."]) or "Show recipe icon next to title. Requires quest type icons in Display.", dbKey = "showRecipeIcons", get = function() return getDB("showRecipeIcons", true) end, set = function(v) setDB("showRecipeIcons", v) end },
            { type = "toggle", name = L["Rarity colors"] or "Rarity colors", desc = (L and L["Color recipe titles by output item rarity."]) or "Color recipe titles by output item rarity.", dbKey = "recipeRarityColors", get = function() return getDB("recipeRarityColors", false) end, set = function(v) setDB("recipeRarityColors", v) end },
            { type = "toggle", name = L["Craftable count"] or "Craftable count", desc = (L and L["Show how many times the recipe can be crafted."]) or "Show how many times the recipe can be crafted.", dbKey = "showCraftableCount", get = function() return getDB("showCraftableCount", false) end, set = function(v) setDB("showCraftableCount", v) end },
            { type = "toggle", name = L["Quality info"] or "Quality info", desc = (L and L["Show quality tier pips for recipes that support qualities."]) or "Show quality tier pips for recipes that support qualities.", dbKey = "showRecipeQualityInfo", get = function() return getDB("showRecipeQualityInfo", false) end, set = function(v) setDB("showRecipeQualityInfo", v) end },
            { type = "toggle", name = L["Requirements"] or "Requirements", desc = (L and L["Show unmet crafting station requirements."]) or "Show unmet crafting station requirements.", dbKey = "showRecipeRequirements", get = function() return getDB("showRecipeRequirements", false) end, set = function(v) setDB("showRecipeRequirements", v) end },
            { type = "section", name = L["Adventure Guide"] },
            { type = "toggle", name = L["Traveler's Log"], desc = L["Tracked objectives from Adventure Guide."], dbKey = "showAdventureGuide", get = function() return getDB("showAdventureGuide", true) end, set = function(v) setDB("showAdventureGuide", v) end },
            { type = "toggle", name = L["Untrack when complete"], desc = L["Auto-untrack finished activities."], dbKey = "autoRemoveCompletedAdventureGuide", get = function() return getDB("autoRemoveCompletedAdventureGuide", true) end, set = function(v) setDB("autoRemoveCompletedAdventureGuide", v) end },
            { type = "section", name = L["Floating quest item"] },
            { type = "toggle", name = L["Floating quest item"], desc = L["Show quick-use button for the focused quest's usable item."], dbKey = "showFloatingQuestItem", get = function() return getDB("showFloatingQuestItem", false) end, set = function(v) setDB("showFloatingQuestItem", v) end },
            { type = "toggle", name = L["Lock item position"], desc = L["Prevent dragging the floating quest item button."], dbKey = "lockFloatingQuestItemPosition", get = function() return getDB("lockFloatingQuestItemPosition", false) end, set = function(v) setDB("lockFloatingQuestItemPosition", v); if addon._UpdateFloatingItemDragAnchor then addon._UpdateFloatingItemDragAnchor() end end },
            { type = "dropdown", name = L["Item source"], desc = L["Super-tracked first, or current zone first."], dbKey = "floatingQuestItemMode", options = { { L["Super-tracked, then first"], "superTracked" }, { L["Current zone first"], "currentZone" } }, get = function() return getDB("floatingQuestItemMode", "superTracked") end, set = function(v) setDB("floatingQuestItemMode", v) end },
        },
    },
    {
        key = "Colors",
        name = L["Colors"],
        desc = L["Personalize the color palette for tracker text elements."] or "Personalize the color palette for tracker text elements.",
        moduleKey = "focus",
        options = {
            { type = "colorMatrixFull", name = L["Colors"], dbKey = "colorMatrix" },
        },
    },
    {
        key = "HiddenQuests",
        name = L["Hidden Quests"] or "Hidden Quests",
        desc = L["Review and manage quests you have manually untracked or blacklisted."] or "Review and manage quests you have manually untracked or blacklisted.",
        moduleKey = "focus",
        options = {
            { type = "blacklistGrid", name = L["Blacklisted quests"], desc = L["Quests hidden via right-click untrack."], tooltip = L["Enable 'Blacklist untracked' in Interactions to add quests here."] or "Enable 'Blacklist untracked' in Interactions to add quests here." },
        },
    },
    {
        key = "PresenceGeneral",
        name = L["General"] or "General",
        desc = L["Core settings for the Presence notification framework."] or "Core settings for the Presence notification framework.",
        moduleKey = "presence",
        options = {
            { type = "section", name = L["Display"] },
            { type = "toggle", name = L["Toast icons"], desc = L["Show quest type icon on Presence toasts (quest accept/complete, world quest, quest update)."], dbKey = "showPresenceQuestTypeIcons", get = function() return getDB("showPresenceQuestTypeIcons", true) end, set = function(v) setDB("showPresenceQuestTypeIcons", v) end },
            { type = "slider", name = L["Toast icon size"], desc = L["Quest icon size on Presence toasts (16–36 px). Default 24."], dbKey = "presenceIconSize", min = 16, max = 36, get = function() return math.max(16, math.min(36, getDB("presenceIconSize", 24) or 24)) end, set = function(v) setDB("presenceIconSize", math.max(16, math.min(36, v))) end },
            { type = "toggle", name = L["Hide quest update title"], desc = L["Show objective line only."], tooltip = L["Show only the objective line on quest progress toasts (e.g. 7/10 Boar Pelts), without the quest name or header."], dbKey = "presenceHideQuestUpdateTitle", get = function() return getDB("presenceHideQuestUpdateTitle", false) end, set = function(v) setDB("presenceHideQuestUpdateTitle", v) end },
            { type = "toggle", name = L["Discovery line"], desc = L["Show 'Discovered' under zone/subzone when entering a new area."], dbKey = "showPresenceDiscovery", get = function() return getDB("showPresenceDiscovery", true) end, set = function(v) setDB("showPresenceDiscovery", v) end },
            { type = "slider", name = L["Frame vertical position"], desc = L["Vertical offset of the Presence frame from center (-300 to 0)."], dbKey = "presenceFrameY", min = -300, max = 0, get = function() return math.max(-300, math.min(0, tonumber(getDB("presenceFrameY", -180)) or -180)) end, set = function(v) setDB("presenceFrameY", math.max(-300, math.min(0, v))) end },
            { type = "slider", name = L["Frame scale"], desc = L["Scale of the Presence frame (0.5–2)."], dbKey = "presenceFrameScale", min = 0.5, max = 2, step = 0.1, get = function() return math.max(0.5, math.min(2, tonumber(getDB("presenceFrameScale", 1)) or 1)) end, set = function(v) setDB("presenceFrameScale", math.max(0.5, math.min(2, v))) end },
            { type = "section", name = L["Animation"] },
            { type = "toggle", name = L["Animations"], desc = L["Enable entrance and exit animations for Presence notifications."], dbKey = "presenceAnimations", get = function() return getDB("presenceAnimations", true) end, set = function(v) setDB("presenceAnimations", v) end },
            { type = "slider", name = L["Entrance duration"], desc = L["Duration of the entrance animation in seconds (0.2–1.5)."], dbKey = "presenceEntranceDur", min = 0.2, max = 1.5, step = 0.1, get = function() return math.max(0.2, math.min(1.5, tonumber(getDB("presenceEntranceDur", 0.7)) or 0.7)) end, set = function(v) setDB("presenceEntranceDur", math.max(0.2, math.min(1.5, v))) end },
            { type = "slider", name = L["Exit duration"], desc = L["Duration of the exit animation in seconds (0.2–1.5)."], dbKey = "presenceExitDur", min = 0.2, max = 1.5, step = 0.1, get = function() return math.max(0.2, math.min(1.5, tonumber(getDB("presenceExitDur", 0.8)) or 0.8)) end, set = function(v) setDB("presenceExitDur", math.max(0.2, math.min(1.5, v))) end },
            { type = "slider", name = L["Hold duration scale"], desc = L["Multiplier for how long each notification stays on screen (0.5–2)."], dbKey = "presenceHoldScale", min = 0.5, max = 2, step = 0.1, get = function() return math.max(0.5, math.min(2, tonumber(getDB("presenceHoldScale", 1)) or 1)) end, set = function(v) setDB("presenceHoldScale", math.max(0.5, math.min(2, v))) end },
        },
    },
    {
        key = "PresenceNotifications",
        name = L["Notifications"],
        desc = L["Choose which events trigger on-screen alerts."] or "Choose which events trigger on-screen alerts.",
        moduleKey = "presence",
        options = {
            { type = "section", name = L["Notification types"] },
            { type = "toggle", name = L["Zone entry"], desc = L["Show zone change when entering a new area."], dbKey = "presenceZoneChange", get = function() return getDB("presenceZoneChange", true) end, set = function(v) setDB("presenceZoneChange", v) end },
            { type = "toggle", name = L["Subzone changes"], desc = L["Show subzone change when moving within the same zone."], dbKey = "presenceSubzoneChange", get = function() local v = getDB("presenceSubzoneChange", nil); if v ~= nil then return v end; return getDB("presenceZoneChange", true) end, set = function(v) setDB("presenceSubzoneChange", v) end },
            { type = "toggle", name = L["Subzone only"], desc = L["Only show subzone name within same zone."], dbKey = "presenceHideZoneForSubzone", get = function() return getDB("presenceHideZoneForSubzone", false) end, set = function(v) setDB("presenceHideZoneForSubzone", v) end, tooltip = L["Zone name still appears when entering a new zone."] },
            { type = "toggle", name = L["Suppress in M+"], desc = L["Hide zone notifications in Mythic+."], tooltip = L["Only boss emotes, achievements, and level-up. Hides zone, quest, and scenario notifications in Mythic+."], dbKey = "presenceSuppressZoneInMplus", get = function() return getDB("presenceSuppressZoneInMplus", true) end, set = function(v) setDB("presenceSuppressZoneInMplus", v) end },
            { type = "section", name = L["Instance suppression"] },
            { type = "toggle", name = L["Suppress in dungeon"], desc = L["Suppress notifications in dungeons."], tooltip = L["Suppress all Presence notifications while inside a dungeon (except boss emotes, achievements, level-up)."], dbKey = "presenceSuppressInDungeon", get = function() return getDB("presenceSuppressInDungeon", false) end, set = function(v) setDB("presenceSuppressInDungeon", v) end },
            { type = "toggle", name = L["Suppress in raid"], desc = L["Suppress all Presence notifications while inside a raid."], dbKey = "presenceSuppressInRaid", get = function() return getDB("presenceSuppressInRaid", false) end, set = function(v) setDB("presenceSuppressInRaid", v) end },
            { type = "toggle", name = L["Suppress in PvP"], desc = L["Suppress all Presence notifications while inside a PvP arena."], dbKey = "presenceSuppressInPvP", get = function() return getDB("presenceSuppressInPvP", false) end, set = function(v) setDB("presenceSuppressInPvP", v) end },
            { type = "toggle", name = L["Suppress in battleground"], desc = L["Suppress all Presence notifications while inside a battleground."], dbKey = "presenceSuppressInBattleground", get = function() return getDB("presenceSuppressInBattleground", false) end, set = function(v) setDB("presenceSuppressInBattleground", v) end },
            { type = "toggle", name = L["Level up"], desc = L["Show level-up notification."], dbKey = "presenceLevelUp", get = function() return getDB("presenceLevelUp", true) end, set = function(v) setDB("presenceLevelUp", v) end },
            { type = "toggle", name = L["Boss emotes"], desc = L["Show raid and dungeon boss emote notifications."], dbKey = "presenceBossEmote", get = function() return getDB("presenceBossEmote", true) end, set = function(v) setDB("presenceBossEmote", v) end },
            { type = "toggle", name = L["Achievements"], desc = L["Show achievement earned notifications."], dbKey = "presenceAchievement", get = function() return getDB("presenceAchievement", true) end, set = function(v) setDB("presenceAchievement", v) end },
            { type = "toggle", name = L["Achievement progress"], desc = L["Notify on achievement criteria update."], tooltip = L["Show notification when achievement criteria update (tracked achievements always; others when Blizzard provides the achievement ID)."], dbKey = "presenceAchievementProgress", get = function() return getDB("presenceAchievementProgress", false) end, set = function(v) setDB("presenceAchievementProgress", v) end },
            { type = "toggle", name = L["Quest accept"], desc = L["Show notification when accepting a quest."], dbKey = "presenceQuestAccept", get = function() local v = getDB("presenceQuestAccept", nil); if v ~= nil then return v end; return getDB("presenceQuestEvents", true) end, set = function(v) setDB("presenceQuestAccept", v) end },
            { type = "toggle", name = L["World quest accept"], desc = L["Show notification when accepting a world quest."], dbKey = "presenceWorldQuestAccept", get = function() local v = getDB("presenceWorldQuestAccept", nil); if v ~= nil then return v end; return getDB("presenceQuestEvents", true) end, set = function(v) setDB("presenceWorldQuestAccept", v) end },
            { type = "toggle", name = L["Quest complete"], desc = L["Show notification when completing a quest."], dbKey = "presenceQuestComplete", get = function() local v = getDB("presenceQuestComplete", nil); if v ~= nil then return v end; return getDB("presenceQuestEvents", true) end, set = function(v) setDB("presenceQuestComplete", v) end },
            { type = "toggle", name = L["World quest complete"], desc = L["Show notification when completing a world quest."], dbKey = "presenceWorldQuest", get = function() local v = getDB("presenceWorldQuest", nil); if v ~= nil then return v end; return getDB("presenceQuestEvents", true) end, set = function(v) setDB("presenceWorldQuest", v) end },
            { type = "toggle", name = L["Quest progress"], desc = L["Show notification when quest objectives update."], dbKey = "presenceQuestUpdate", get = function() local v = getDB("presenceQuestUpdate", nil); if v ~= nil then return v end; return getDB("presenceQuestEvents", true) end, set = function(v) setDB("presenceQuestUpdate", v) end },
            { type = "toggle", name = L["Objective only"], desc = L["Show only the objective line on quest progress toasts, hiding the 'Quest Update' title."], dbKey = "presenceHideQuestUpdateTitle", get = function() return getDB("presenceHideQuestUpdateTitle", false) end, set = function(v) setDB("presenceHideQuestUpdateTitle", v) end },
            { type = "toggle", name = L["Scenario start"], desc = L["Show notification when entering a scenario or Delve."], dbKey = "presenceScenarioStart", get = function() local v = getDB("presenceScenarioStart", nil); if v ~= nil then return v end; return getDB("showScenarioEvents", true) end, set = function(v) setDB("presenceScenarioStart", v) end },
            { type = "toggle", name = L["Scenario progress"], desc = L["Show notification when scenario or Delve objectives update."], dbKey = "presenceScenarioUpdate", get = function() local v = getDB("presenceScenarioUpdate", nil); if v ~= nil then return v end; return getDB("showScenarioEvents", true) end, set = function(v) setDB("presenceScenarioUpdate", v) end },
            { type = "toggle", name = L["Show scenario complete"], desc = L["Show notification when a scenario or Delve is fully completed."], dbKey = "presenceScenarioComplete", get = function() local v = getDB("presenceScenarioComplete", nil); if v ~= nil then return v end; return getDB("showScenarioEvents", true) end, set = function(v) setDB("presenceScenarioComplete", v) end },
            { type = "toggle", name = L["Show rare defeated"], desc = L["Show notification when a rare mob is defeated nearby."], dbKey = "presenceRareDefeated", get = function() return getDB("presenceRareDefeated", true) end, set = function(v) setDB("presenceRareDefeated", v) end },
        },
    },
    {
        key = "PresenceTypography",
        name = L["Typography"],
        desc = L["Fonts, sizes, and colors for Presence notifications."] or "Fonts, sizes, and colors for Presence notifications.",
        moduleKey = "presence",
        options = {
            { type = "section", name = L["Typography"] },
            { type = "dropdown", name = L["Main title font"], desc = L["Font family for the main title."], dbKey = "presenceTitleFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("presenceTitleFontPath") end, get = function() return getDB("presenceTitleFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("presenceTitleFontPath", v) end, displayFn = DisplayPerElementFont },
            { type = "dropdown", name = L["Subtitle font"], desc = L["Font family for the subtitle."], dbKey = "presenceSubtitleFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("presenceSubtitleFontPath") end, get = function() return getDB("presenceSubtitleFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("presenceSubtitleFontPath", v) end, displayFn = DisplayPerElementFont },
            { type = "slider", name = L["Main title size"], desc = L["Font size for the main title (24–72 px)."], dbKey = "presenceMainSize", min = 24, max = 72, get = function() return math.max(24, math.min(72, tonumber(getDB("presenceMainSize", 48)) or 48)) end, set = function(v) setDB("presenceMainSize", math.max(24, math.min(72, v))) end },
            { type = "slider", name = L["Subtitle size"], desc = L["Font size for the subtitle (12–40 px)."], dbKey = "presenceSubSize", min = 12, max = 40, get = function() return math.max(12, math.min(40, tonumber(getDB("presenceSubSize", 24)) or 24)) end, set = function(v) setDB("presenceSubSize", math.max(12, math.min(40, v))) end },
            { type = "section", name = L["Colors"] },
            { type = "color", name = L["Boss emote color"], desc = L["Color of raid and dungeon boss emote text."], dbKey = "presenceBossEmoteColor", default = addon.PRESENCE_BOSS_EMOTE_COLOR },
            { type = "color", name = L["Discovery line color"], desc = L["Color of the 'Discovered' line under zone text."], dbKey = "presenceDiscoveryColor", default = addon.PRESENCE_DISCOVERY_COLOR },
            { type = "section", name = L["Zone type coloring"] },
            { type = "toggle", name = L["Color by zone type"], desc = L["Color zone/subzone titles by PvP zone type (friendly, hostile, contested, sanctuary). When off, uses the default category color."], dbKey = "presenceZoneTypeColoring", get = function() return getDB("presenceZoneTypeColoring", false) end, set = function(v) setDB("presenceZoneTypeColoring", v) end },
            { type = "color", name = L["Friendly zone color"], desc = L["Color for friendly zones (green by default)."], dbKey = "presenceZoneColorFriendly", default = { 0.1, 1.0, 0.1 } },
            { type = "color", name = L["Hostile zone color"], desc = L["Color for hostile zones (red by default)."], dbKey = "presenceZoneColorHostile", default = { 1.0, 0.1, 0.1 } },
            { type = "color", name = L["Contested zone color"], desc = L["Color for contested zones (orange by default)."], dbKey = "presenceZoneColorContested", default = { 1.0, 0.7, 0.0 } },
            { type = "color", name = L["Sanctuary zone color"], desc = L["Color for sanctuary zones (blue by default)."], dbKey = "presenceZoneColorSanctuary", default = { 0.41, 0.8, 0.94 } },
        },
    },
    {
        key = "Insight",
        name = L["Tooltips"] or "Tooltips",
        desc = L["Enhance player and item tooltips with extra details like Mythic+ score and transmog status."] or "Enhance player and item tooltips with extra details like Mythic+ score and transmog status.",
        moduleKey = "insight",
        options = {
            { type = "section", name = L["Position"] or "Position" },
            { type = "dropdown", name = L["Tooltip anchor"] or "Tooltip anchor", desc = L["Where tooltips appear: follow cursor or fixed position."] or "Where tooltips appear: follow cursor or fixed position.", dbKey = "insightAnchorMode", options = { { L["Cursor"] or "Cursor", "cursor" }, { L["Fixed"] or "Fixed", "fixed" } }, get = function() return getDB("insightAnchorMode", "cursor") end, set = function(v) setDB("insightAnchorMode", v) end },
            { type = "button", name = L["Show anchor to move"] or "Show anchor to move", desc = L["Drag to set position, right-click to confirm."] or "Drag to set position, right-click to confirm.", onClick = function()
                if addon.Insight and addon.Insight.ShowAnchorFrame then addon.Insight.ShowAnchorFrame() end
            end },
            { type = "button", name = L["Reset tooltip position"] or "Reset tooltip position", desc = L["Reset fixed position to default."] or "Reset fixed position to default.", onClick = function()
                setDB("insightFixedPoint", "BOTTOMRIGHT")
                setDB("insightFixedX", -40)
                setDB("insightFixedY", 120)
                if addon.Insight and addon.Insight.ApplyInsightOptions then addon.Insight.ApplyInsightOptions() end
            end },
            { type = "section", name = L["Player Tooltip"] or "Player Tooltip" },
            { type = "toggle", name = L["Guild rank"] or "Guild rank", desc = L["Append the player's guild rank next to their guild name."] or "Append the player's guild rank next to their guild name.", dbKey = "insightShowGuildRank", get = function() return getDB("insightShowGuildRank", true) end, set = function(v) setDB("insightShowGuildRank", v) end },
            { type = "toggle", name = L["PvP title"] or "PvP title", desc = L["Show the player's PvP title (e.g. Gladiator) in the tooltip."] or "Show the player's PvP title (e.g. Gladiator) in the tooltip.", dbKey = "insightShowPvPTitle", get = function() return getDB("insightShowPvPTitle", true) end, set = function(v) setDB("insightShowPvPTitle", v) end },
            { type = "toggle", name = L["Honor level"] or "Honor level", desc = L["Show the player's PvP honor level in the tooltip."] or "Show the player's PvP honor level in the tooltip.", dbKey = "insightShowHonorLevel", get = function() return getDB("insightShowHonorLevel", true) end, set = function(v) setDB("insightShowHonorLevel", v) end },
            { type = "toggle", name = L["Status badges"] or "Status badges", desc = L["Combat, AFK, DND, PvP, party, friends, targeting."], dbKey = "insightShowStatusBadges", get = function() return getDB("insightShowStatusBadges", true) end, set = function(v) setDB("insightShowStatusBadges", v) end },
            { type = "toggle", name = L["Mythic+ score"] or "Mythic+ score", desc = L["Show the player's current season Mythic+ score, colour-coded by tier."] or "Show the player's current season Mythic+ score, colour-coded by tier.", dbKey = "insightShowMythicScore", get = function() return getDB("insightShowMythicScore", true) end, set = function(v) setDB("insightShowMythicScore", v) end },
            { type = "toggle", name = L["Item level"] or "Item level", desc = L["Show the player's equipped item level after inspecting them."] or "Show the player's equipped item level after inspecting them.", dbKey = "insightShowIlvl", get = function() return getDB("insightShowIlvl", true) end, set = function(v) setDB("insightShowIlvl", v) end },
            { type = "toggle", name = L["Mount info"] or "Mount info", desc = L["Mount name, source, and collection status."], dbKey = "insightShowMount", get = function() return getDB("insightShowMount", true) end, set = function(v) setDB("insightShowMount", v) end, tooltip = L["Shown when hovering a mounted player."] },
            { type = "section", name = L["Item Tooltip"] or "Item Tooltip" },
            { type = "toggle", name = L["Transmog status"] or "Transmog status", desc = L["Show whether you have collected the appearance of an item you hover over."] or "Show whether you have collected the appearance of an item you hover over.", dbKey = "insightShowTransmog", get = function() return getDB("insightShowTransmog", true) end, set = function(v) setDB("insightShowTransmog", v) end },
        },
    },
    {
        key = "VistaMinimap",
        name = L["Minimap"] or "Minimap",
        desc = L["Configure the minimap's shape, size, position, and text overlays."] or "Configure the minimap's shape, size, position, and text overlays.",
        moduleKey = "vista",
        options = {
            { type = "section", name = L["Size & shape"] or "Size & shape" },
            { type = "slider", name = L["Minimap size"] or "Minimap size",
              desc = L["Width and height of the minimap in pixels (100–400)."] or "Width and height of the minimap in pixels (100–400).",
              dbKey = "vistaMapSize", min = 100, max = 400,
              get = function() return math.max(100, math.min(400, tonumber(getDB("vistaMapSize", 200)) or 200)) end,
              set = function(v) setDB("vistaMapSize", math.max(100, math.min(400, v))) end },
            { type = "toggle", name = L["Circular shape"] or "Circular shape",
              desc = L["Use a circular minimap instead of square."] or "Use a circular minimap instead of square.",
              dbKey = "vistaCircular",
              get = function() return getDB("vistaCircular", false) end,
              set = function(v) setDB("vistaCircular", v) end },
            { type = "section", name = L["Position"] or "Position" },
            { type = "toggle", name = L["Lock minimap"] or "Lock minimap",
              desc = L["Prevent dragging the minimap."] or "Prevent dragging the minimap.",
              dbKey = "vistaLock",
              get = function() return getDB("vistaLock", true) end,
              set = function(v) setDB("vistaLock", v) end },
            { type = "button", name = L["Reset minimap position"] or "Reset minimap position",
              desc = L["Reset minimap to its default position (top-right)."] or "Reset minimap to its default position (top-right).",
              onClick = function()
                  if addon.Vista and addon.Vista.ResetMinimapPosition then
                      addon.Vista.ResetMinimapPosition()
                  end
              end },
            { type = "section", name = L["Auto Zoom"] or "Auto Zoom" },
            { type = "slider", name = L["Auto zoom-out delay"] or "Auto zoom-out delay",
              desc = L["Seconds after zooming before auto zoom-out fires. Set to 0 to disable."] or "Seconds after zooming before auto zoom-out fires. Set to 0 to disable.",
              dbKey = "vistaAutoZoom", min = 0, max = 30,
              get = function() return math.max(0, math.min(30, tonumber(getDB("vistaAutoZoom", 5)) or 5)) end,
              set = function(v) setDB("vistaAutoZoom", math.max(0, math.min(30, v))) end },
            { type = "section", name = L["Text Elements"] or "Text Elements" },
            { type = "toggle", name = L["Show zone text"] or "Show zone text",
              desc = L["Show the zone name below the minimap."] or "Show the zone name below the minimap.",
              dbKey = "vistaShowZoneText",
              get = function() return getDB("vistaShowZoneText", true) end,
              set = function(v) setDB("vistaShowZoneText", v) end },
            { type = "dropdown", name = L["Zone text display mode"] or "Zone text display mode",
              desc = L["What to show: zone only, subzone only, or both."] or "What to show: zone only, subzone only, or both.",
              dbKey = "vistaZoneDisplayMode",
              options = function() return {
                  { L["Zone only"] or "Zone only", "zone" },
                  { L["Subzone only"] or "Subzone only", "subzone" },
                  { L["Both"] or "Both", "both" },
              } end,
              get = function() return getDB("vistaZoneDisplayMode", "zone") end,
              set = function(v) setDB("vistaZoneDisplayMode", v) end,
              disabled = function() return not getDB("vistaShowZoneText", true) end },
            { type = "toggle", name = L["Show coordinates"] or "Show coordinates",
              desc = L["Show player coordinates below the minimap."] or "Show player coordinates below the minimap.",
              dbKey = "vistaShowCoordText",
              get = function() return getDB("vistaShowCoordText", true) end,
              set = function(v) setDB("vistaShowCoordText", v) end },
            { type = "toggle", name = L["Show time"] or "Show time",
              desc = L["Show current game time below the minimap."] or "Show current game time below the minimap.",
              dbKey = "vistaShowTimeText",
              get = function() return getDB("vistaShowTimeText", true) end,
              set = function(v) setDB("vistaShowTimeText", v) end },
            { type = "toggle", name = L["Use local time"] or "Use local time",
              desc = L["Show local system time."] or "Show local system time.",
              tooltip = L["When on, shows your local system time. When off, shows server time."] or "When on, shows your local system time. When off, shows server time.",
              dbKey = "vistaTimeUseLocal",
              get = function() return getDB("vistaTimeUseLocal", true) end,
              set = function(v) setDB("vistaTimeUseLocal", v) end,
              disabled = function() return not getDB("vistaShowTimeText", true) end },
            { type = "section", name = L["Minimap Buttons"] or "Minimap Buttons" },
            { type = "header", name = L["Queue status and mail indicator are always shown when relevant."] or "Queue status and mail indicator are always shown when relevant." },
            { type = "toggle", name = L["Show tracking button"] or "Show tracking button",
              desc = L["Show the minimap tracking button."] or "Show the minimap tracking button.",
              dbKey = "vistaShowTracking",
              get = function() return getDB("vistaShowTracking", true) end,
              set = function(v)
                  setDB("vistaShowTracking", v)
                  if addon.OptionsPanel_Refresh and C_Timer and C_Timer.After then
                      C_Timer.After(0, addon.OptionsPanel_Refresh)
                  elseif addon.OptionsPanel_Refresh then
                      addon.OptionsPanel_Refresh()
                  end
              end },
            { type = "toggle", name = L["Tracking button on mouseover only"] or "Tracking button on mouseover only",
              desc = L["Show only on hover."] or "Show only on hover.",
              tooltip = L["Hide tracking button until you hover over the minimap."] or "Hide tracking button until you hover over the minimap.",
              dbKey = "vistaMouseoverTracking",
              get = function() return getDB("vistaMouseoverTracking", true) end,
              set = function(v) setDB("vistaMouseoverTracking", v) end,
              disabled = function() return not getDB("vistaShowTracking", true) end },
            { type = "toggle", name = L["Show calendar button"] or "Show calendar button",
              desc = L["Show the minimap calendar button."] or "Show the minimap calendar button.",
              dbKey = "vistaShowCalendar",
              get = function() return getDB("vistaShowCalendar", true) end,
              set = function(v)
                  setDB("vistaShowCalendar", v)
                  if addon.OptionsPanel_Refresh and C_Timer and C_Timer.After then
                      C_Timer.After(0, addon.OptionsPanel_Refresh)
                  elseif addon.OptionsPanel_Refresh then
                      addon.OptionsPanel_Refresh()
                  end
              end },
            { type = "toggle", name = L["Calendar button on mouseover only"] or "Calendar button on mouseover only",
              desc = L["Hide calendar button until you hover over the minimap."] or "Hide calendar button until you hover over the minimap.",
              dbKey = "vistaMouseoverCalendar",
              get = function() return getDB("vistaMouseoverCalendar", true) end,
              set = function(v) setDB("vistaMouseoverCalendar", v) end,
              disabled = function() return not getDB("vistaShowCalendar", true) end },
            { type = "toggle", name = L["Show zoom buttons"] or "Show zoom buttons",
              desc = L["Show the + and - zoom buttons on the minimap."] or "Show the + and - zoom buttons on the minimap.",
              dbKey = "vistaShowZoomBtns",
              get = function() return getDB("vistaShowZoomBtns", true) end,
              set = function(v)
                  setDB("vistaShowZoomBtns", v)
                  if addon.OptionsPanel_Refresh and C_Timer and C_Timer.After then
                      C_Timer.After(0, addon.OptionsPanel_Refresh)
                  elseif addon.OptionsPanel_Refresh then
                      addon.OptionsPanel_Refresh()
                  end
              end },
            { type = "toggle", name = L["Zoom buttons on mouseover only"] or "Zoom buttons on mouseover only",
              desc = L["Hide zoom buttons until you hover over the minimap."] or "Hide zoom buttons until you hover over the minimap.",
              dbKey = "vistaMouseoverZoomBtns",
              get = function() return getDB("vistaMouseoverZoomBtns", true) end,
              set = function(v) setDB("vistaMouseoverZoomBtns", v) end,
              disabled = function() return not getDB("vistaShowZoomBtns", true) end },
        },
    },
    {
        key = "VistaAppearance",
        name = L["Appearance"] or "Appearance",
        desc = L["Customize borders, colors, and the positioning of specific minimap elements."] or "Customize borders, colors, and the positioning of specific minimap elements.",
        moduleKey = "vista",
        options = function()
            local GLOBAL_SENTINEL = "__global__"
            local GLOBAL_LABEL = L["Use global font"] or "Use global font"

            local function fontOpts(dbKey)
                local list = { { GLOBAL_LABEL, GLOBAL_SENTINEL } }
                local fontList = (addon.GetFontList and addon.GetFontList()) or {}
                for _, f in ipairs(fontList) do list[#list + 1] = f end
                local saved = getDB(dbKey, GLOBAL_SENTINEL)
                if saved and saved ~= GLOBAL_SENTINEL and saved ~= "" then
                    local found = false
                    for _, o in ipairs(list) do if o[2] == saved then found = true; break end end
                    if not found then list[#list + 1] = { "Custom", saved } end
                end
                return list
            end

            local function displayFont(v)
                if v == GLOBAL_SENTINEL or v == nil or v == "" then return GLOBAL_LABEL end
                if addon.GetFontNameForPath then return addon.GetFontNameForPath(v) end
                return v
            end

            local function getFont(dbKey)
                local v = getDB(dbKey, GLOBAL_SENTINEL)
                if v == nil or v == "" then return GLOBAL_SENTINEL end
                return v
            end

            return {
            { type = "section", name = L["Border"] or "Border" },
            { type = "toggle", name = L["Show border"] or "Show border",
              desc = L["Show a border around the minimap."] or "Show a border around the minimap.",
              dbKey = "vistaBorderShow",
              get = function() return getDB("vistaBorderShow", true) end,
              set = function(v) setDB("vistaBorderShow", v) end },
            { type = "color", name = L["Border color"] or "Border color",
              desc = L["Color (and opacity) of the minimap border."] or "Color (and opacity) of the minimap border.",
              dbKey = "vistaBorderColor",
              get = function()
                  return getDB("vistaBorderColorR", 1), getDB("vistaBorderColorG", 1),
                         getDB("vistaBorderColorB", 1), getDB("vistaBorderColorA", 0.15)
              end,
              set = function(r, g, b, a)
                  setDB("vistaBorderColorR", r); setDB("vistaBorderColorG", g)
                  setDB("vistaBorderColorB", b)
                  if a then setDB("vistaBorderColorA", a) end
              end,
              hasAlpha = true },
            { type = "slider", name = L["Border thickness"] or "Border thickness",
              desc = L["Thickness of the minimap border in pixels (1–8)."] or "Thickness of the minimap border in pixels (1–8).",
              dbKey = "vistaBorderWidth", min = 1, max = 8,
              get = function() return math.max(1, math.min(8, tonumber(getDB("vistaBorderWidth", 1)) or 1)) end,
              set = function(v)
                  addon.SetDB("vistaBorderWidth", math.max(1, math.min(8, v)))
                  if addon.Vista then
                      if addon._vistaBorderDebounce then addon._vistaBorderDebounce:Cancel() end
                      addon._vistaBorderDebounce = C_Timer.NewTimer(0.15, function()
                          addon._vistaBorderDebounce = nil
                          if addon.Vista.ApplyOptions then addon.Vista.ApplyOptions() end
                      end)
                  end
              end },

            { type = "section", name = L["Text Positions"] or "Text Positions" },
            { type = "header", name = L["Drag text elements to reposition them. Lock to prevent accidental movement."] or "Drag text elements to reposition them. Lock to prevent accidental movement." },
            { type = "dropdown", name = L["Location position"] or "Location position",
              desc = L["Place the zone name above or below the minimap."] or "Place the zone name above or below the minimap.",
              dbKey = "vistaZoneVerticalPos",
              options = function() return { { L["Top"] or "Top", "top" }, { L["Bottom"] or "Bottom", "bottom" } } end,
              get = function() return getDB("vistaZoneVerticalPos", "bottom") or "bottom" end,
              set = function(v)
                  setDB("vistaZoneVerticalPos", v)
                  setDB("vistaEX_zone", nil); setDB("vistaEY_zone", nil)
              end },
            { type = "toggle", name = L["Lock zone text position"] or "Lock zone text position",
              desc = L["When on, the zone text cannot be dragged."] or "When on, the zone text cannot be dragged.",
              dbKey = "vistaLocked_zone",
              get = function() return getDB("vistaLocked_zone", true) end,
              set = function(v) setDB("vistaLocked_zone", v) end },
            { type = "dropdown", name = L["Coordinates position"] or "Coordinates position",
              desc = L["Place the coordinates above or below the minimap."] or "Place the coordinates above or below the minimap.",
              dbKey = "vistaCoordVerticalPos",
              options = function() return { { L["Top"] or "Top", "top" }, { L["Bottom"] or "Bottom", "bottom" } } end,
              get = function() return getDB("vistaCoordVerticalPos", "bottom") or "bottom" end,
              set = function(v)
                  setDB("vistaCoordVerticalPos", v)
                  setDB("vistaEX_coord", nil); setDB("vistaEY_coord", nil)
              end },
            { type = "toggle", name = L["Lock coordinates position"] or "Lock coordinates position",
              desc = L["When on, the coordinates text cannot be dragged."] or "When on, the coordinates text cannot be dragged.",
              dbKey = "vistaLocked_coord",
              get = function() return getDB("vistaLocked_coord", true) end,
              set = function(v) setDB("vistaLocked_coord", v) end },
            { type = "dropdown", name = L["Clock position"] or "Clock position",
              desc = L["Place the clock above or below the minimap."] or "Place the clock above or below the minimap.",
              dbKey = "vistaTimeVerticalPos",
              options = function() return { { L["Top"] or "Top", "top" }, { L["Bottom"] or "Bottom", "bottom" } } end,
              get = function() return getDB("vistaTimeVerticalPos", "bottom") or "bottom" end,
              set = function(v)
                  setDB("vistaTimeVerticalPos", v)
                  setDB("vistaEX_time", nil); setDB("vistaEY_time", nil)
              end },
            { type = "toggle", name = L["Lock time position"] or "Lock time position",
              desc = L["When on, the time text cannot be dragged."] or "When on, the time text cannot be dragged.",
              dbKey = "vistaLocked_time",
              get = function() return getDB("vistaLocked_time", true) end,
              set = function(v) setDB("vistaLocked_time", v) end },
            { type = "section", name = L["Button Positions"] or "Button Positions" },
            { type = "header", name = L["Drag buttons to reposition them. Lock to prevent movement."] or "Drag buttons to reposition them. Lock to prevent movement." },
            { type = "toggle", name = L["Lock Zoom In button"] or "Lock Zoom In button",
              desc = L["Prevent dragging the + zoom button."] or "Prevent dragging the + zoom button.",
              dbKey = "vistaLocked_zoomIn",
              get = function() return getDB("vistaLocked_zoomIn", true) end,
              set = function(v) setDB("vistaLocked_zoomIn", v) end },
            { type = "toggle", name = L["Lock Zoom Out button"] or "Lock Zoom Out button",
              desc = L["Prevent dragging the - zoom button."] or "Prevent dragging the - zoom button.",
              dbKey = "vistaLocked_zoomOut",
              get = function() return getDB("vistaLocked_zoomOut", true) end,
              set = function(v) setDB("vistaLocked_zoomOut", v) end },
            { type = "toggle", name = L["Lock Tracking button"] or "Lock Tracking button",
              desc = L["Prevent dragging the tracking button."] or "Prevent dragging the tracking button.",
              dbKey = "vistaLocked_proxy_tracking",
              get = function() return getDB("vistaLocked_proxy_tracking", true) end,
              set = function(v) setDB("vistaLocked_proxy_tracking", v) end },
            { type = "toggle", name = L["Lock Calendar button"] or "Lock Calendar button",
              desc = L["Prevent dragging the calendar button."] or "Prevent dragging the calendar button.",
              dbKey = "vistaLocked_proxy_calendar",
              get = function() return getDB("vistaLocked_proxy_calendar", true) end,
              set = function(v) setDB("vistaLocked_proxy_calendar", v) end },
            { type = "toggle", name = L["Lock Queue button"] or "Lock Queue button",
              desc = L["Prevent dragging the queue status button."] or "Prevent dragging the queue status button.",
              dbKey = "vistaLocked_proxy_queue",
              get = function() return getDB("vistaLocked_proxy_queue", true) end,
              set = function(v)
                  setDB("vistaLocked_proxy_queue", v)
                  if addon.Vista and addon.Vista.RefreshQueueProxies then
                      addon.Vista.RefreshQueueProxies()
                  end
              end },
            { type = "toggle", name = L["Lock Mail indicator"] or "Lock Mail indicator",
              desc = L["Prevent dragging the mail icon."] or "Prevent dragging the mail icon.",
              dbKey = "vistaLocked_proxy_mail",
              get = function() return getDB("vistaLocked_proxy_mail", true) end,
              set = function(v)
                  setDB("vistaLocked_proxy_mail", v)
                  if addon.Vista and addon.Vista.RefreshMailAnchor then
                      addon.Vista.RefreshMailAnchor()
                  end
              end },
            { type = "toggle", name = L["Disable queue handling"] or "Disable queue handling",
              desc = L["Turn off all queue button anchoring (use if another addon manages it)."] or "Turn off all queue button anchoring (use if another addon manages it).",
              dbKey = "vistaQueueHandlingDisabled",
              get = function() return getDB("vistaQueueHandlingDisabled", false) end,
              set = function(v)
                  setDB("vistaQueueHandlingDisabled", v)
                  if addon.Vista and addon.Vista.RefreshQueueProxies then
                      addon.Vista.RefreshQueueProxies()
                  end
              end },
            { type = "section", name = L["Button Sizes"] or "Button Sizes" },
            { type = "header", name = L["Adjust the size of minimap overlay buttons."] or "Adjust the size of minimap overlay buttons." },
            { type = "slider", name = L["Tracking button size"] or "Tracking button size",
              desc = L["Size of the tracking button (pixels)."] or "Size of the tracking button (pixels).",
              dbKey = "vistaTrackingBtnSize", min = 14, max = 40,
              get = function() return math.max(14, math.min(40, tonumber(getDB("vistaTrackingBtnSize", 22)) or 22)) end,
              set = function(v) setDB("vistaTrackingBtnSize", math.max(14, math.min(40, v))) end },
            { type = "slider", name = L["Calendar button size"] or "Calendar button size",
              desc = L["Size of the calendar button (pixels)."] or "Size of the calendar button (pixels).",
              dbKey = "vistaCalendarBtnSize", min = 14, max = 40,
              get = function() return math.max(14, math.min(40, tonumber(getDB("vistaCalendarBtnSize", 22)) or 22)) end,
              set = function(v) setDB("vistaCalendarBtnSize", math.max(14, math.min(40, v))) end },
            { type = "slider", name = L["Queue button size"] or "Queue button size",
              desc = L["Size of the queue status button (pixels)."] or "Size of the queue status button (pixels).",
              dbKey = "vistaQueueBtnSize", min = 14, max = 40,
              get = function() return math.max(14, math.min(40, tonumber(getDB("vistaQueueBtnSize", 22)) or 22)) end,
              set = function(v) setDB("vistaQueueBtnSize", math.max(14, math.min(40, v))) end },
            { type = "slider", name = L["Zoom button size"] or "Zoom button size",
              desc = L["Size of the + and - zoom buttons (pixels)."] or "Size of the + and - zoom buttons (pixels).",
              dbKey = "vistaZoomBtnSize", min = 10, max = 32,
              get = function() return math.max(10, math.min(32, tonumber(getDB("vistaZoomBtnSize", 16)) or 16)) end,
              set = function(v) setDB("vistaZoomBtnSize", math.max(10, math.min(32, v))) end },
            { type = "slider", name = L["Mail indicator size"] or "Mail indicator size",
              desc = L["Size of the new mail icon (pixels)."] or "Size of the new mail icon (pixels).",
              dbKey = "vistaMailIconSize", min = 14, max = 40,
              get = function() return math.max(14, math.min(40, tonumber(getDB("vistaMailIconSize", 20)) or 20)) end,
              set = function(v) setDB("vistaMailIconSize", math.max(14, math.min(40, v))) end },
            { type = "toggle", name = L["Mail icon pulse"] or "Mail icon pulse",
              desc = L["When on, the mail icon pulses to draw attention. When off, it stays at full opacity."] or "When on, the mail icon pulses to draw attention. When off, it stays at full opacity.",
              dbKey = "vistaMailBlink",
              get = function() return getDB("vistaMailBlink", true) end,
              set = function(v) setDB("vistaMailBlink", v) end },
            { type = "slider", name = L["Addon button size"] or "Addon button size",
              desc = L["Size of collected addon minimap buttons (pixels)."] or "Size of collected addon minimap buttons (pixels).",
              dbKey = "vistaAddonBtnSize", min = 16, max = 48,
              get = function() return math.max(16, math.min(48, tonumber(getDB("vistaAddonBtnSize", 26)) or 26)) end,
              set = function(v)
                  setDB("vistaAddonBtnSize", math.max(16, math.min(48, v)))
                  if addon._vistaAddonBtnDebounce then addon._vistaAddonBtnDebounce:Cancel() end
                  if C_Timer and C_Timer.NewTimer and addon.Vista and addon.Vista.ApplyOptions then
                      addon._vistaAddonBtnDebounce = C_Timer.NewTimer(0.15, function()
                          addon._vistaAddonBtnDebounce = nil
                          addon.Vista.ApplyOptions()
                      end)
                  end
              end },
            { type = "section", name = L["Zone Text"] or "Zone Text" },
            { type = "dropdown", name = L["Zone font"] or "Zone font",
              desc = L["Font for the zone name below the minimap."] or "Font for the zone name below the minimap.",
              dbKey = "vistaZoneFontPath", searchable = true,
              options = function() return fontOpts("vistaZoneFontPath") end,
              get = function() return getFont("vistaZoneFontPath") end,
              set = function(v) setDB("vistaZoneFontPath", v) end,
              displayFn = displayFont },
            { type = "slider", name = L["Zone font size"] or "Zone font size",
              dbKey = "vistaZoneFontSize", min = 7, max = 24,
              get = function() return math.max(7, math.min(24, tonumber(getDB("vistaZoneFontSize", 12)) or 12)) end,
              set = function(v) setDB("vistaZoneFontSize", math.max(7, math.min(24, v))) end },
            { type = "color", name = L["Zone text color"] or "Zone text color",
              desc = L["Color of the zone name text."] or "Color of the zone name text.",
              dbKey = "vistaZoneColor",
              get = function()
                  return getDB("vistaZoneColorR", 1), getDB("vistaZoneColorG", 1), getDB("vistaZoneColorB", 1)
              end,
              set = function(r, g, b)
                  setDB("vistaZoneColorR", r); setDB("vistaZoneColorG", g); setDB("vistaZoneColorB", b)
              end },
            { type = "section", name = L["Coordinates Text"] or "Coordinates Text" },
            { type = "dropdown", name = L["Coordinates font"] or "Coordinates font",
              desc = L["Font for the coordinates text below the minimap."] or "Font for the coordinates text below the minimap.",
              dbKey = "vistaCoordFontPath", searchable = true,
              options = function() return fontOpts("vistaCoordFontPath") end,
              get = function() return getFont("vistaCoordFontPath") end,
              set = function(v) setDB("vistaCoordFontPath", v) end,
              displayFn = displayFont },
            { type = "slider", name = L["Coordinates font size"] or "Coordinates font size",
              dbKey = "vistaCoordFontSize", min = 7, max = 20,
              get = function() return math.max(7, math.min(20, tonumber(getDB("vistaCoordFontSize", 10)) or 10)) end,
              set = function(v) setDB("vistaCoordFontSize", math.max(7, math.min(20, v))) end },
            { type = "color", name = L["Coordinates text color"] or "Coordinates text color",
              desc = L["Color of the coordinates text."] or "Color of the coordinates text.",
              dbKey = "vistaCoordColor",
              get = function()
                  return getDB("vistaCoordColorR", 0.55), getDB("vistaCoordColorG", 0.65), getDB("vistaCoordColorB", 0.75)
              end,
              set = function(r, g, b)
                  setDB("vistaCoordColorR", r); setDB("vistaCoordColorG", g); setDB("vistaCoordColorB", b)
              end },
            { type = "dropdown", name = L["Coordinate precision"] or "Coordinate precision",
              desc = L["Number of decimal places shown for X and Y coordinates."] or "Number of decimal places shown for X and Y coordinates.",
              dbKey = "vistaCoordPrecision",
              options = function() return {
                  { L["No decimals (e.g. 52, 37)"]      or "No decimals (e.g. 52, 37)",      0 },
                  { L["1 decimal (e.g. 52.3, 37.1)"]    or "1 decimal (e.g. 52.3, 37.1)",    1 },
                  { L["2 decimals (e.g. 52.34, 37.12)"] or "2 decimals (e.g. 52.34, 37.12)", 2 },
              } end,
              get = function() return tonumber(getDB("vistaCoordPrecision", 1)) or 1 end,
              set = function(v) setDB("vistaCoordPrecision", tonumber(v) or 1) end },
            { type = "section", name = L["Time Text"] or "Time Text" },
            { type = "dropdown", name = L["Time font"] or "Time font",
              desc = L["Font for the time text below the minimap."] or "Font for the time text below the minimap.",
              dbKey = "vistaTimeFontPath", searchable = true,
              options = function() return fontOpts("vistaTimeFontPath") end,
              get = function() return getFont("vistaTimeFontPath") end,
              set = function(v) setDB("vistaTimeFontPath", v) end,
              displayFn = displayFont },
            { type = "slider", name = L["Time font size"] or "Time font size",
              dbKey = "vistaTimeFontSize", min = 7, max = 20,
              get = function() return math.max(7, math.min(20, tonumber(getDB("vistaTimeFontSize", 10)) or 10)) end,
              set = function(v) setDB("vistaTimeFontSize", math.max(7, math.min(20, v))) end },
            { type = "color", name = L["Time text color"] or "Time text color",
              desc = L["Color of the time text."] or "Color of the time text.",
              dbKey = "vistaTimeColor",
              get = function()
                  return getDB("vistaTimeColorR", 0.55), getDB("vistaTimeColorG", 0.65), getDB("vistaTimeColorB", 0.75)
              end,
              set = function(r, g, b)
                  setDB("vistaTimeColorR", r); setDB("vistaTimeColorG", g); setDB("vistaTimeColorB", b)
              end },
            { type = "section", name = L["Difficulty Text"] or "Difficulty Text" },
            { type = "color", name = L["Difficulty text color (fallback)"] or "Difficulty text color (fallback)",
              desc = L["Default color when no per-difficulty color is set."] or "Default color when no per-difficulty color is set.",
              dbKey = "vistaDiffColor",
              get = function()
                  return getDB("vistaDiffColorR", 0.55), getDB("vistaDiffColorG", 0.65), getDB("vistaDiffColorB", 0.75)
              end,
              set = function(r, g, b)
                  setDB("vistaDiffColorR", r); setDB("vistaDiffColorG", g); setDB("vistaDiffColorB", b)
              end },
            { type = "dropdown", name = L["Difficulty font"] or "Difficulty font",
              desc = L["Font for the instance difficulty text."] or "Font for the instance difficulty text.",
              dbKey = "vistaDiffFontPath", searchable = true,
              options = function() return fontOpts("vistaDiffFontPath") end,
              get = function() return getFont("vistaDiffFontPath") end,
              set = function(v) setDB("vistaDiffFontPath", v) end,
              displayFn = displayFont },
            { type = "slider", name = L["Difficulty font size"] or "Difficulty font size",
              dbKey = "vistaDiffFontSize", min = 7, max = 24,
              get = function() return math.max(7, math.min(24, tonumber(getDB("vistaDiffFontSize", 10)) or 10)) end,
              set = function(v) setDB("vistaDiffFontSize", math.max(7, math.min(24, v))) end },
            { type = "section", name = L["Per-Difficulty Colors"] or "Per-Difficulty Colors", defaultCollapsed = true },
            { type = "color", name = L["Mythic color"] or "Mythic color",
              desc = L["Color for Mythic difficulty text."] or "Color for Mythic difficulty text.",
              dbKey = "vistaDiffColor_mythic",
              get = function() return getDB("vistaDiffColor_mythic_R", 0.64), getDB("vistaDiffColor_mythic_G", 0.21), getDB("vistaDiffColor_mythic_B", 0.93) end,
              set = function(r, g, b) setDB("vistaDiffColor_mythic_R", r); setDB("vistaDiffColor_mythic_G", g); setDB("vistaDiffColor_mythic_B", b) end },
            { type = "color", name = L["Heroic color"] or "Heroic color",
              desc = L["Color for Heroic difficulty text."] or "Color for Heroic difficulty text.",
              dbKey = "vistaDiffColor_heroic",
              get = function() return getDB("vistaDiffColor_heroic_R", 1.00), getDB("vistaDiffColor_heroic_G", 0.12), getDB("vistaDiffColor_heroic_B", 0.12) end,
              set = function(r, g, b) setDB("vistaDiffColor_heroic_R", r); setDB("vistaDiffColor_heroic_G", g); setDB("vistaDiffColor_heroic_B", b) end },
            { type = "color", name = L["Normal color"] or "Normal color",
              desc = L["Color for Normal difficulty text."] or "Color for Normal difficulty text.",
              dbKey = "vistaDiffColor_normal",
              get = function() return getDB("vistaDiffColor_normal_R", 0.12), getDB("vistaDiffColor_normal_G", 0.83), getDB("vistaDiffColor_normal_B", 0.12) end,
              set = function(r, g, b) setDB("vistaDiffColor_normal_R", r); setDB("vistaDiffColor_normal_G", g); setDB("vistaDiffColor_normal_B", b) end },
            { type = "color", name = L["LFR color"] or "LFR color",
              desc = L["Color for Looking For Raid difficulty text."] or "Color for Looking For Raid difficulty text.",
              dbKey = "vistaDiffColor_lfr",
              get = function() return getDB("vistaDiffColor_looking_for_raid_R", 0.00), getDB("vistaDiffColor_looking_for_raid_G", 0.70), getDB("vistaDiffColor_looking_for_raid_B", 1.00) end,
              set = function(r, g, b) setDB("vistaDiffColor_looking_for_raid_R", r); setDB("vistaDiffColor_looking_for_raid_G", g); setDB("vistaDiffColor_looking_for_raid_B", b) end },
        } end,
    },
    {
        key = "VistaButtons",
        name = L["Addon Buttons"] or "Addon Buttons",
        desc = L["Manage and organize minimap icons from other addons into a tidy drawer or bar."] or "Manage and organize minimap icons from other addons into a tidy drawer or bar.",
        moduleKey = "vista",
        options = function()
            local BUTTON_MODE_OPTIONS = {
                { L["Mouseover bar"] or "Mouseover bar", "mouseover" },
                { L["Right-click panel"] or "Right-click panel", "rightclick" },
                { L["Floating drawer"] or "Floating drawer", "drawer" },
            }

            local opts = {
                { type = "section", name = L["Button Management"] or "Button Management" },
                { type = "toggle", name = L["Manage addon buttons"] or "Manage addon buttons",
                  desc = L["Collect and group addon minimap buttons."], tooltip = L["Groups them by the selected layout mode below."],
                  dbKey = "vistaHandleAddonButtons",
                  get = function() return getDB("vistaHandleAddonButtons", true) end,
                  set = function(v)
                      setDB("vistaHandleAddonButtons", v)
                      if addon.OptionsPanel_Refresh and C_Timer and C_Timer.After then
                          C_Timer.After(0, addon.OptionsPanel_Refresh)
                      elseif addon.OptionsPanel_Refresh then
                          addon.OptionsPanel_Refresh()
                      end
                  end },
                { type = "dropdown", name = L["Button mode"] or "Button mode",
                  desc = L["How addon buttons are presented: hover bar below minimap, panel on right-click, or floating drawer button."] or "How addon buttons are presented: hover bar below minimap, panel on right-click, or floating drawer button.",
                  dbKey = "vistaButtonMode",
                  options = BUTTON_MODE_OPTIONS,
                  get = function() return getDB("vistaButtonMode", "rightclick") end,
                  set = function(v)
                      if not getDB("vistaHandleAddonButtons", true) then return end
                      setDB("vistaButtonMode", v)
                      if addon.OptionsPanel_Refresh and C_Timer and C_Timer.After then
                          C_Timer.After(0, addon.OptionsPanel_Refresh)
                      elseif addon.OptionsPanel_Refresh then
                          addon.OptionsPanel_Refresh()
                      end
                  end,
                  disabled = function() return not getDB("vistaHandleAddonButtons", true) end },
                { type = "toggle", name = L["Lock drawer button"] or "Lock drawer button",
                  desc = L["Prevent dragging the floating drawer button."] or "Prevent dragging the floating drawer button.",
                  dbKey = "vistaDrawerButtonLocked",
                  get = function() return getDB("vistaDrawerButtonLocked", false) end,
                  set = function(v)
                      if not getDB("vistaHandleAddonButtons", true) then return end
                      if getDB("vistaButtonMode", "mouseover") ~= "drawer" then return end
                      setDB("vistaDrawerButtonLocked", v)
                  end,
                  disabled = function()
                      return not getDB("vistaHandleAddonButtons", true) or getDB("vistaButtonMode", "mouseover") ~= "drawer"
                  end },
                { type = "toggle", name = L["Lock mouseover bar"] or "Lock mouseover bar",
                  desc = L["Prevent dragging the mouseover button bar."] or "Prevent dragging the mouseover button bar.",
                  dbKey = "vistaMouseoverLocked",
                  get = function() return getDB("vistaMouseoverLocked", true) end,
                  set = function(v) setDB("vistaMouseoverLocked", v) end,
                  disabled = function()
                      return not getDB("vistaHandleAddonButtons", true) or getDB("vistaButtonMode", "mouseover") ~= "mouseover"
                  end },
                { type = "toggle", name = L["Always show bar"] or "Always show bar",
                  desc = L["Keep bar visible for repositioning."], tooltip = L["Disable when done."],
                  dbKey = "vistaMouseoverBarVisible",
                  get = function() return getDB("vistaMouseoverBarVisible", false) end,
                  set = function(v) setDB("vistaMouseoverBarVisible", v) end,
                  disabled = function()
                      return not getDB("vistaHandleAddonButtons", true) or getDB("vistaButtonMode", "mouseover") ~= "mouseover"
                  end },
                { type = "toggle", name = L["Lock right-click panel"] or "Lock right-click panel",
                  desc = L["Prevent dragging the right-click panel."] or "Prevent dragging the right-click panel.",
                  dbKey = "vistaRightClickLocked",
                  get = function() return getDB("vistaRightClickLocked", true) end,
                  set = function(v) setDB("vistaRightClickLocked", v) end,
                  disabled = function()
                      return not getDB("vistaHandleAddonButtons", true) or getDB("vistaButtonMode", "mouseover") ~= "rightclick"
                  end },

                { type = "section", name = L["Close / Fade Timing"] or "Close / Fade Timing", defaultCollapsed = true },
                { type = "slider", name = L["Mouseover close delay"] or "Mouseover close delay",
                  desc = L["How long (in seconds) the bar stays visible after the cursor leaves. 0 = instant fade."] or "How long (in seconds) the bar stays visible after the cursor leaves. 0 = instant fade.",
                  dbKey = "vistaMouseoverCloseDelay", min = 0, max = 10, step = 0.5,
                  get = function() return math.max(0, math.min(10, tonumber(getDB("vistaMouseoverCloseDelay", 0)) or 0)) end,
                  set = function(v) setDB("vistaMouseoverCloseDelay", math.max(0, math.min(10, v))) end,
                  disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
                },
                { type = "slider", name = L["Right-click close delay"] or "Right-click close delay",
                  desc = L["How long (in seconds) the panel stays open after the cursor leaves. 0 = never auto-close (close by right-clicking again)."] or "How long (in seconds) the panel stays open after the cursor leaves. 0 = never auto-close (close by right-clicking again).",
                  dbKey = "vistaRightClickCloseDelay", min = 0, max = 10, step = 0.5,
                  get = function() return math.max(0, math.min(10, tonumber(getDB("vistaRightClickCloseDelay", 2.5)) or 2.5)) end,
                  set = function(v) setDB("vistaRightClickCloseDelay", math.max(0, math.min(10, v))) end,
                  disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
                },
                { type = "slider", name = L["Drawer close delay"] or "Drawer close delay",
                  desc = L["Auto-close delay (0 to disable)."] or "Auto-close delay (0 to disable).",
                  tooltip = L["How long (in seconds) the drawer panel stays open after clicking away. 0 = never auto-close (close only by clicking the drawer button again)."] or "How long (in seconds) the drawer panel stays open after clicking away. 0 = never auto-close (close only by clicking the drawer button again).",
                  dbKey = "vistaDrawerCloseDelay", min = 0, max = 10, step = 0.5,
                  get = function() return math.max(0, math.min(10, tonumber(getDB("vistaDrawerCloseDelay", 0)) or 0)) end,
                  set = function(v) setDB("vistaDrawerCloseDelay", math.max(0, math.min(10, v))) end,
                  disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
                },

                { type = "section", name = L["Layout"] or "Layout" },
            }

            local DIR_OPTIONS = function() return {
                { L["Right"] or "Right", "right" },
                { L["Left"] or "Left",   "left"  },
                { L["Down"] or "Down",   "down"  },
                { L["Up"] or "Up",       "up"    },
            } end

            -- Shared layout options (apply to all 3 modes)
            opts[#opts + 1] = {
                type = "slider", name = L["Buttons per row/column"] or "Buttons per row/column",
                desc = L["Controls how many buttons appear before wrapping. For left/right direction this is columns; for up/down it is rows."] or "Controls how many buttons appear before wrapping. For left/right direction this is columns; for up/down it is rows.",
                dbKey = "vistaBtnLayoutCols", min = 1, max = 20, step = 1,
                get = function() return math.max(1, math.min(20, tonumber(getDB("vistaBtnLayoutCols", 5)) or 5)) end,
                set = function(v)
                    setDB("vistaBtnLayoutCols", math.max(1, math.min(20, v)))
                    if addon._vistaBtnColsDebounce then addon._vistaBtnColsDebounce:Cancel() end
                    if C_Timer and C_Timer.NewTimer and addon.Vista and addon.Vista.ApplyOptions then
                        addon._vistaBtnColsDebounce = C_Timer.NewTimer(0.15, function()
                            addon._vistaBtnColsDebounce = nil
                            addon.Vista.ApplyOptions()
                        end)
                    end
                end,
                disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
            }
            opts[#opts + 1] = {
                type = "dropdown", name = L["Expand direction"] or "Expand direction",
                desc = L["Expand direction from anchor."] or "Expand direction from anchor.",
                tooltip = L["Direction buttons fill from the anchor point. Left/Right = horizontal rows. Up/Down = vertical columns."] or "Direction buttons fill from the anchor point. Left/Right = horizontal rows. Up/Down = vertical columns.",
                dbKey = "vistaBtnLayoutDir", options = DIR_OPTIONS,
                get = function() return getDB("vistaBtnLayoutDir", "right") end,
                set = function(v) setDB("vistaBtnLayoutDir", v) end,
                disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
            }

            opts[#opts + 1] = { type = "section", name = L["Panel Appearance"] or "Panel Appearance" }
            opts[#opts + 1] = { type = "header", name = L["Colors for the drawer and right-click button panels."] or "Colors for the drawer and right-click button panels." }
            opts[#opts + 1] = {
                type = "color", name = L["Panel background color"] or "Panel background color",
                desc = L["Background color of the addon button panels."] or "Background color of the addon button panels.",
                dbKey = "vistaPanelBg",
                get = function()
                    return getDB("vistaPanelBgR", 0.08), getDB("vistaPanelBgG", 0.08),
                           getDB("vistaPanelBgB", 0.12), getDB("vistaPanelBgA", 0.95)
                end,
                set = function(r, g, b, a)
                    setDB("vistaPanelBgR", r); setDB("vistaPanelBgG", g)
                    setDB("vistaPanelBgB", b)
                    if a then setDB("vistaPanelBgA", a) end
                end,
                hasAlpha = true,
            }
            opts[#opts + 1] = {
                type = "color", name = L["Panel border color"] or "Panel border color",
                desc = L["Border color of the addon button panels."] or "Border color of the addon button panels.",
                dbKey = "vistaPanelBorder",
                get = function()
                    return getDB("vistaPanelBorderR", 0.3), getDB("vistaPanelBorderG", 0.4),
                           getDB("vistaPanelBorderB", 0.6), getDB("vistaPanelBorderA", 0.7)
                end,
                set = function(r, g, b, a)
                    setDB("vistaPanelBorderR", r); setDB("vistaPanelBorderG", g)
                    setDB("vistaPanelBorderB", b)
                    if a then setDB("vistaPanelBorderA", a) end
                end,
                hasAlpha = true,
            }

            opts[#opts + 1] = { type = "section", name = L["Mouseover Bar Appearance"] or "Mouseover Bar Appearance" }
            opts[#opts + 1] = { type = "header", name = L["Background and border for the mouseover button bar."] or "Background and border for the mouseover button bar." }
            opts[#opts + 1] = {
                type = "color", name = L["Bar background color"] or "Bar background color",
                desc = L["Background color of the mouseover button bar (use alpha to control transparency)."] or "Background color of the mouseover button bar (use alpha to control transparency).",
                dbKey = "vistaBarBg",
                get = function()
                    return getDB("vistaBarBgR", 0.08), getDB("vistaBarBgG", 0.08),
                           getDB("vistaBarBgB", 0.12), getDB("vistaBarBgA", 0)
                end,
                set = function(r, g, b, a)
                    setDB("vistaBarBgR", r); setDB("vistaBarBgG", g)
                    setDB("vistaBarBgB", b)
                    if a then setDB("vistaBarBgA", a) end
                end,
                hasAlpha = true,
                disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
            }
            opts[#opts + 1] = {
                type = "toggle", name = L["Show bar border"] or "Show bar border",
                desc = L["Show a border around the mouseover button bar."] or "Show a border around the mouseover button bar.",
                dbKey = "vistaBarBorderShow",
                get = function() return getDB("vistaBarBorderShow", false) end,
                set = function(v) setDB("vistaBarBorderShow", v) end,
                disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
            }
            opts[#opts + 1] = {
                type = "color", name = L["Bar border color"] or "Bar border color",
                desc = L["Border color of the mouseover button bar."] or "Border color of the mouseover button bar.",
                dbKey = "vistaBarBorder",
                get = function()
                    return getDB("vistaBarBorderR", 0.3), getDB("vistaBarBorderG", 0.4),
                           getDB("vistaBarBorderB", 0.6), getDB("vistaBarBorderA", 0.7)
                end,
                set = function(r, g, b, a)
                    setDB("vistaBarBorderR", r); setDB("vistaBarBorderG", g)
                    setDB("vistaBarBorderB", b)
                    if a then setDB("vistaBarBorderA", a) end
                end,
                hasAlpha = true,
                disabled = function() return not getDB("vistaHandleAddonButtons", true) or not getDB("vistaBarBorderShow", false) end,
            }

            -- Managed buttons: per-button toggle — uncheck to fully ignore a button
            opts[#opts + 1] = {
                type = "section",
                name = L["Managed buttons"] or "Managed buttons",
            }

            local function getButtonNames()
                if addon.Vista and addon.Vista.GetDiscoveredButtonNames then
                    return addon.Vista.GetDiscoveredButtonNames()
                end
                return {}
            end

            local managedNames = getButtonNames()
            for _, btnName in ipairs(managedNames) do
                local localName = btnName
                local displayName = localName
                if addon.Vista and addon.Vista.GetButtonDisplayName then
                    displayName = addon.Vista.GetButtonDisplayName(localName) or localName
                end
                opts[#opts + 1] = {
                    type = "toggle",
                    name = (displayName ~= "" and displayName ~= localName) and displayName or localName,
                    desc = L["When off, this button is completely ignored by this addon."] or "When off, this button is completely ignored by this addon.",
                    dbKey = "vistaButtonManaged_" .. localName,
                    disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
                    get = function() return getDB("vistaButtonManaged_" .. localName, true) end,
                    set = function(v)
                        setDB("vistaButtonManaged_" .. localName, v)
                    end,
                }
            end
            if #managedNames == 0 then
                opts[#opts + 1] = {
                    type = "toggle",
                    name = L["(No addon buttons detected yet)"] or "(No addon buttons detected yet)",
                    dbKey = "_vista_no_managed_placeholder",
                    get = function() return false end, set = function() end,
                    disabled = function() return true end,
                }
            end

            opts[#opts + 1] = {
                type = "section",
                name = L["Visible buttons (check to include)"] or "Visible buttons (check to include)",
            }

            local names = getButtonNames()
            for _, btnName in ipairs(names) do
                local localName = btnName
                local displayName = localName
                if addon.Vista and addon.Vista.GetButtonDisplayName then
                    displayName = addon.Vista.GetButtonDisplayName(localName) or localName
                end
                local label = (displayName ~= localName and displayName ~= "") and displayName or localName
                opts[#opts + 1] = {
                    type = "toggle",
                    name = label,
                    dbKey = "vistaBtn_" .. localName,
                    disabled = function()
                        if not getDB("vistaHandleAddonButtons", true) then return true end
                        return not getDB("vistaButtonManaged_" .. localName, true)
                    end,
                    get = function()
                        local wl = getDB("vistaButtonWhitelist", nil)
                        if not wl or type(wl) ~= "table" then return true end
                        return wl[localName] == true
                    end,
                    set = function(v)
                        local wl = getDB("vistaButtonWhitelist", nil)
                        if not wl or type(wl) ~= "table" then
                            local allNames = getButtonNames()
                            wl = {}
                            for _, n in ipairs(allNames) do wl[n] = true end
                        end
                        wl[localName] = v or nil
                        local hasAny = false
                        for _, val in pairs(wl) do
                            if val then hasAny = true; break end
                        end
                        if not hasAny then wl = nil end
                        setDB("vistaButtonWhitelist", wl)
                    end,
                }
            end

            if #names == 0 then
                opts[#opts + 1] = {
                    type = "toggle",
                    name = L["(No addon buttons detected yet — open your minimap first)"] or "(No addon buttons detected yet — open your minimap first)",
                    dbKey = "_vista_no_buttons_placeholder",
                    get = function() return false end,
                    set = function() end,
                    disabled = function() return true end,
                }
            end

            return opts
        end,
    },
    {
        key = "YieldGeneral",
        name = L["General"],
        desc = L["Positioning and visibility for the Yield loot toast system."] or "Positioning and visibility for the Yield loot toast system.",
        moduleKey = "yield",
        options = {
            { type = "section", name = L["Position"] },
            { type = "button", name = L["Reset position"], desc = L["Reset loot toast position to default."], onClick = function()
                if addon.Yield and addon.Yield.ResetPosition then addon.Yield.ResetPosition() end
            end },
        },
    },
}

-- ---------------------------------------------------------------------------
-- Search index: flatten all options for search (name + desc + section)
-- Includes optionId, sectionName, categoryIndex for navigation.
-- ---------------------------------------------------------------------------

function OptionsData_BuildSearchIndex()
    local index = {}
    local cats = addon.OptionCategories
    for catIdx, cat in ipairs(cats) do
        local currentSection = ""
        local moduleKey = cat.moduleKey
        local moduleLabel = (moduleKey == "focus" and L["Focus"]) or (moduleKey == "presence" and L["Presence"]) or (moduleKey == "insight" and (L["Insight"] or "Insight")) or (moduleKey == "yield" and L["Yield"]) or (moduleKey == "vista" and (L["Vista"] or "Vista")) or L["Modules"]
        local catOpts = type(cat.options) == "function" and cat.options() or cat.options
        for _, opt in ipairs(catOpts) do
            if opt.type == "section" then
                currentSection = type(opt.name) == "function" and opt.name() or opt.name or ""
            elseif opt.type ~= "section" then
                local rawName = type(opt.name) == "function" and opt.name() or opt.name
                local name = (rawName or ""):lower()
                local desc = ((opt.desc or "") .. " " .. (opt.tooltip or "")):lower()
                local sectionLower = (currentSection or ""):lower()
                local searchText = name .. " " .. desc .. " " .. sectionLower .. " " .. (moduleLabel or ""):lower()
                local optionId = opt.dbKey or (cat.key .. "_" .. (rawName or ""):gsub("%s+", "_"))
                index[#index + 1] = {
                    categoryKey = cat.key,
                    categoryName = cat.name,
                    categoryIndex = catIdx,
                    moduleKey = moduleKey,
                    moduleLabel = moduleLabel,
                    sectionName = currentSection,
                    option = opt,
                    optionId = optionId,
                    searchText = searchText,
                }
            end
        end
    end
    return index
end

-- Filter out Insight/Yield categories when dev addon does not show their toggles.
local function getVisibleCategories()
    local dev = _G.HorizonSuiteDevOverride
    local showInsight = dev and dev.showInsightToggle
    local showYield = dev and dev.showYieldToggle
    local out = {}
    for _, cat in ipairs(OptionCategories) do
        local mk = cat.moduleKey
        if mk == "insight" and not showInsight then
            -- skip
        elseif mk == "yield" and not showYield then
            -- skip
        else
            out[#out + 1] = cat
        end
    end
    return out
end

-- Export for panel
addon.OptionsData_GetDB = OptionsData_GetDB
addon.OptionsData_SetDB = OptionsData_SetDB
addon.OptionsData_NotifyMainAddon = OptionsData_NotifyMainAddon
addon.OptionsData_SetUpdateFontsRef = OptionsData_SetUpdateFontsRef
addon.OptionCategories = getVisibleCategories()
addon.OptionsData_BuildSearchIndex = OptionsData_BuildSearchIndex
addon.COLOR_KEYS_ORDER = COLOR_KEYS_ORDER
addon.ZONE_COLOR_DEFAULT = ZONE_COLOR_DEFAULT
addon.OBJ_COLOR_DEFAULT = OBJ_COLOR_DEFAULT
addon.OBJ_DONE_COLOR_DEFAULT = OBJ_DONE_COLOR_DEFAULT
addon.HIGHLIGHT_COLOR_DEFAULT = HIGHLIGHT_COLOR_DEFAULT
