--[[
    Horizon Suite - Options Data
    Core DB helpers, per-key routing (SetDB side-effects), empty OptionCategories
    table populated by self-registering module files, and the search index.
]]

local addon = _G.HorizonSuite
if not addon then return end
if not _G[addon.DATABASE] then _G[addon.DATABASE] = {} end

local L = addon.L
local function BrandModule(moduleKey)
    if addon.GetModuleDisplayName then return addon.GetModuleDisplayName(moduleKey) end
    local t = addon.BrandDisplay and addon.BrandDisplay.module
    if not moduleKey or not t then return nil end
    return t[moduleKey]
end
-- ---------------------------------------------------------------------------
-- DB helpers
-- ---------------------------------------------------------------------------

local TYPOGRAPHY_KEYS = {
    fontPath = true,
    usePerElementFonts = true,
    titleFontPath = true,
    presenceTitleFontPath = true,
    presenceSubtitleFontPath = true,
    presenceTitleFontOutline = true,
    presenceSubtitleFontOutline = true,
    zoneFontPath = true,
    objectiveFontPath = true,
    sectionFontPath = true,
    progressBarFontPath = true,
    timerFontPath = true,
    optionsFontPath = true,
    headerFontSize = true,
    titleFontSize = true,
    objectiveFontSize = true,
    zoneFontSize = true,
    sectionFontSize = true,
    progressBarFontSize = true,
    timerFontSize = true,
    optionsFontSize = true,
    fontOutline = true,
}

local CACHE_KEYS = {
    cachePoint    = true,
    cacheRelPoint = true,
    cacheX        = true,
    cacheY        = true,
    cacheFontPath = true,
}

local FOCUS_CLICK_KEYS = {
    focusClickProfile     = true,
    focusIconClickAction  = true,
    focusClick_left       = true,
    focusClick_shiftLeft  = true,
    focusClick_ctrlLeft   = true,
    focusClick_altLeft    = true,
    focusClick_right      = true,
    focusClick_shiftRight = true,
    focusClick_ctrlRight  = true,
    focusClick_altRight   = true,
}

-- Keys whose values are baked into a formatted string inside UpdateMplusBlockDisplay
-- (|cff...|r markup) rather than applied via SetTextColor in ApplyMplusTypography.
-- Changing one of these requires re-running the display, not just typography.
local MPLUS_EMBEDDED_MARKUP_KEYS = {
    mplusShowSplitTimer = true,
    mplusSplitColorR = true, mplusSplitColorG = true, mplusSplitColorB = true,
    mplusSplitPastColorR = true, mplusSplitPastColorG = true, mplusSplitPastColorB = true,
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
    mplusShowSplitTimer = true,
    mplusSplitSize = true,
    mplusSplitColorR = true, mplusSplitColorG = true, mplusSplitColorB = true,
    mplusSplitPastColorR = true, mplusSplitPastColorG = true, mplusSplitPastColorB = true,
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
    mplusSplitColorR = true, mplusSplitColorG = true, mplusSplitColorB = true,
    mplusSplitPastColorR = true, mplusSplitPastColorG = true, mplusSplitPastColorB = true,
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
    vistaPerfColorR = true, vistaPerfColorG = true, vistaPerfColorB = true,
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
    vistaPerfFontPath = true, vistaPerfFontSize = true,
    vistaShowZoneText = true, vistaShowCoordText = true, vistaShowTimeText = true,     vistaShowPerfText = true,
    vistaTimeUseLocal = true, vistaTime24Hour = true,
    vistaZoneDisplayMode = true,
    vistaZoneVerticalPos = true, vistaCoordVerticalPos = true, vistaTimeVerticalPos = true, vistaPerfVerticalPos = true, vistaDiffVerticalPos = true,
    vistaShowDefaultMinimapButtons = true,  -- legacy key kept for compatibility
    vistaLock = true,
    vistaPoint = true, vistaRelPoint = true, vistaX = true, vistaY = true,
    vistaDrawerBtnX = true, vistaDrawerBtnY = true,
    vistaShowTracking = true, vistaMouseoverTracking = true,
    vistaShowCalendar = true, vistaMouseoverCalendar = true,
    vistaQueueBtnX = true, vistaQueueBtnY = true,
    -- Draggable element positions (stored by MakeDraggable on drag-stop)
    vistaEX_zone = true, vistaEY_zone = true,
    vistaEX_coord = true, vistaEY_coord = true,
    vistaEX_time = true, vistaEY_time = true,
    vistaEX_perf = true, vistaEY_perf = true,
    vistaEX_diff = true, vistaEY_diff = true,
    -- Proxy button positions (tracking + calendar + queue only; landing page removed)
    ["vistaEX_proxy_tracking"] = true, ["vistaEY_proxy_tracking"] = true,
    ["vistaEX_proxy_calendar"] = true, ["vistaEY_proxy_calendar"] = true,
    ["vistaEX_proxy_queue"]    = true, ["vistaEY_proxy_queue"]    = true,
    ["vistaEX_proxy_mail"]     = true, ["vistaEY_proxy_mail"]     = true,
    ["vistaEX_proxy_craftingOrder"] = true, ["vistaEY_proxy_craftingOrder"] = true,
    -- Lock toggles
    vistaLocked_zone = true, vistaLocked_coord = true, vistaLocked_time = true, vistaLocked_perf = true,
    vistaLocked_diff = true,
    ["vistaLocked_proxy_tracking"] = true,
    ["vistaLocked_proxy_calendar"] = true,
    ["vistaLocked_proxy_queue"]    = true,
    ["vistaLocked_proxy_mail"]     = true,
    ["vistaLocked_proxy_craftingOrder"] = true,
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
    vistaCollectHorizonMinimapButton = true, vistaButtonSortAlpha = true,
    vistaDrawerButtonLocked = true, vistaDrawerIcon = true, vistaButtonWhitelist = true,
    vistaMailBlink = true,
    vistaCraftingOrderBlink = true,
    -- Button sizes (separate per type)
    vistaTrackingBtnSize = true, vistaCalendarBtnSize = true, vistaQueueBtnSize = true,
    vistaMailIconSize = true, vistaCraftingOrderIconSize = true, vistaAddonBtnSize = true,
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
    vistaPerfColorR = true, vistaPerfColorG = true, vistaPerfColorB = true,
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
    cacheUIScale    = true,
    vistaBorderWidth = true,
    vistaAddonBtnSize = true,
    vistaBtnLayoutCols = true,
}

-- Vista-only keys: Vista.ApplyOptions / ApplyLockOnlyOptions already ran above; Focus does not read vista*
-- for layout. Skip OptionsData_NotifyMainAddon (FullLayout) so dashboard toggles stay smooth.
-- Add exceptions here only if a Vista key must still rebuild the tracker or global dimensions.
local VISTA_KEYS_REQUIRE_NOTIFY = {
}

-- Vista position / drag locks: use Vista.ApplyLockOnlyOptions and skip FullLayout (Focus rebuild is unnecessary).
local VISTA_SKIP_FULL_LAYOUT_KEYS = {
    vistaLocked_zone = true,
    vistaLocked_coord = true,
    vistaLocked_time = true,
    vistaLocked_perf = true,
    vistaLocked_diff = true,
    ["vistaLocked_proxy_tracking"] = true,
    ["vistaLocked_proxy_calendar"] = true,
    ["vistaLocked_proxy_queue"]    = true,
    ["vistaLocked_proxy_mail"]     = true,
    ["vistaLocked_proxy_craftingOrder"] = true,
    ["vistaQueueHandlingDisabled"] = true,
    vistaMouseoverLocked = true,
    vistaRightClickLocked = true,
    vistaDrawerButtonLocked = true,
}

local CLASS_COLOR_KEYS = {
    classColorDashboard = true,
    classColorVista = true,
    classColorInsight = true,
    classColorEssence = true,
    classColorFocus = true,
    classColorPresence = true,
    classColorCache = true,
}

local DASHBOARD_CLASS_ICON_KEYS = {
    dashboardClassIconSource = true,
    dashboardShowClassIcon = true,
}

local DASHBOARD_BACKGROUND_KEYS = {
    dashboardBackgroundTheme = true,
    dashboardBackgroundOpacity = true,
    dashboardBackgroundClassOverride = true,
}

local DASHBOARD_TYPOGRAPHY_KEYS = {
    dashboardFontPath = true,
    dashboardFontSize = true,
    dashboardTextOutline = true,
    dashboardTextShadow = true,
    dashboardHeadingColor = true,
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
    if (key == "fontPath" or key == "titleFontPath" or key == "zoneFontPath" or key == "objectiveFontPath" or key == "sectionFontPath" or key == "progressBarFontPath" or key == "timerFontPath" or key == "optionsFontPath" or key == "presenceTitleFontPath" or key == "presenceSubtitleFontPath" or key == "insightFontPath") and updateOptionsPanelFontsRef then
        updateOptionsPanelFontsRef()
    end
    if TYPOGRAPHY_KEYS[key] and addon.UpdateFontObjectsFromDB then
        addon.UpdateFontObjectsFromDB()
    end
    if MPLUS_TYPOGRAPHY_KEYS[key] and addon.ApplyMplusTypography then
        addon.ApplyMplusTypography()
    end
    if MPLUS_EMBEDDED_MARKUP_KEYS[key] and addon.UpdateMplusBlock then
        addon.UpdateMplusBlock()
    end
    if addon.PRESENCE_KEYS and addon.PRESENCE_KEYS[key] and addon.Presence then
        if addon.Presence.ApplyPresenceOptions then addon.Presence.ApplyPresenceOptions() end
        if addon.Presence.ApplyBlizzardSuppression then addon.Presence.ApplyBlizzardSuppression() end
    end
    if addon.INSIGHT_KEYS and addon.INSIGHT_KEYS[key] and addon.Insight and addon.Insight.ApplyInsightOptions then
        addon.Insight.ApplyInsightOptions()
    end
    if addon.ESSENCE_KEYS and addon.ESSENCE_KEYS[key] and addon.Essence and addon.Essence.ApplyEssenceOptions then
        addon.Essence.ApplyEssenceOptions()
    end
    if CACHE_KEYS[key] and addon.Cache and addon.Cache.ApplyCacheOptions then
        addon.Cache.ApplyCacheOptions()
    end
    if DASHBOARD_CLASS_ICON_KEYS[key] then
        if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
    end
    if DASHBOARD_BACKGROUND_KEYS[key] then
        if addon.ApplyDashboardBackground then addon.ApplyDashboardBackground() end
    end
    if DASHBOARD_TYPOGRAPHY_KEYS[key] then
        if addon.ApplyDashboardTypography then addon.ApplyDashboardTypography() end
    end
    if CLASS_COLOR_KEYS[key] then
        if key == "classColorDashboard" then
            if addon.ApplyOptionsClassColor then addon.ApplyOptionsClassColor() end
            if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
            if addon.ApplyPatchNotesAccent then addon.ApplyPatchNotesAccent() end
            if addon.ApplyURLCopyBoxAccent then addon.ApplyURLCopyBoxAccent() end
            if addon.focus.ApplyAuctionCraftDialogAccent then addon.focus.ApplyAuctionCraftDialogAccent() end
        end
        if key == "classColorVista" and addon.Vista and addon.Vista.ApplyColors then
            addon.Vista.ApplyColors()
        end
        if key == "classColorInsight" and addon.Insight and addon.Insight.ApplyInsightOptions then
            addon.Insight.ApplyInsightOptions()
        end
        if key == "classColorEssence" and addon.Essence and addon.Essence.ApplyEssenceOptions then
            addon.Essence.ApplyEssenceOptions()
        end
        if key == "classColorFocus" and addon.ApplyFocusColors then
            addon.ApplyFocusColors()
        end
        if key == "classColorPresence" and addon.Presence and addon.Presence.ApplyPresenceOptions then
            addon.Presence.ApplyPresenceOptions()
        end
        if key == "classColorCache" and addon.Cache and addon.Cache.ApplyCacheOptions then
            addon.Cache.ApplyCacheOptions()
        end
    end
    if VISTA_KEYS[key] and addon.Vista then
        if addon._colorPickerLive and VISTA_COLOR_LIVE_KEYS[key] then
            if addon.Vista.ApplyColors then addon.Vista.ApplyColors() end
        elseif addon.Vista.ApplyOptions or addon.Vista.ApplyLockOnlyOptions then
            local fn
            if VISTA_SKIP_FULL_LAYOUT_KEYS[key] and addon.Vista.ApplyLockOnlyOptions then
                fn = addon.Vista.ApplyLockOnlyOptions
            else
                local vistaKey = key
                fn = function()
                    if addon.Vista and addon.Vista.ApplyOptions then
                        addon.Vista.ApplyOptions(vistaKey)
                    end
                end
            end
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
        local managedKey = key
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                if addon.Vista and addon.Vista.ApplyOptions then
                    addon.Vista.ApplyOptions(managedKey)
                end
            end)
        else
            addon.Vista.ApplyOptions(managedKey)
        end
    end
    if key == "lockPosition" and addon.UpdateResizeHandleVisibility then
        addon.UpdateResizeHandleVisibility()
    end
    if (key == "backdropOpacity" or key == "backdropColorR" or key == "backdropColorG" or key == "backdropColorB") and addon.ApplyBackdropOpacity then
        addon.ApplyBackdropOpacity()
    end
    if key == "insightBgOpacity" and addon.Insight and addon.Insight.ApplyInsightOptions then
        addon.Insight.ApplyInsightOptions()
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
    if key == "minimapButtonShowOnlyOnMinimapHover" and addon.MinimapButton_UpdateVisibility then
        addon.MinimapButton_UpdateVisibility()
    end
    if VISTA_KEYS[key] and not VISTA_KEYS_REQUIRE_NOTIFY[key] then return end
    if key:sub(1, 19) == "vistaButtonManaged_" then return end
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
    if addon.Insight and addon.Insight.ApplyInsightOptions then addon.Insight.ApplyInsightOptions() end
end

function OptionsData_NotifyMainAddon()
    -- Bust the per-entry populate-signature cache so option changes (objectivePrefixStyle,
    -- showZoneLabels, useTickForCompletedObjectives, etc.) take effect on the next FullLayout
    -- instead of waiting for /reload or a fingerprinted qData field to perturb.
    if addon.focus and addon.focus.InvalidatePopulateCache then addon.focus.InvalidatePopulateCache() end
    local applyTy = addon.ApplyTypography or _G.HorizonSuite_ApplyTypography
    if applyTy then applyTy() end
    if addon.ApplyDimensions then addon.ApplyDimensions()
    elseif _G.HorizonSuite_ApplyDimensions then _G.HorizonSuite_ApplyDimensions() end
    if addon.ApplyBackdropOpacity then addon.ApplyBackdropOpacity() end
    if addon.ApplyBorderVisibility then addon.ApplyBorderVisibility() end
    -- Re-apply colours and bar textures on visible entries; FullLayout repositions
    -- but does not re-run the per-entry renderer that calls SetTexture, so without
    -- this call texture/colour changes wait for an aggregator pass or /reload.
    if addon.ApplyFocusColors then addon.ApplyFocusColors() end
    if addon.RequestRefresh then addon.RequestRefresh()
    elseif _G.HorizonSuite_RequestRefresh then _G.HorizonSuite_RequestRefresh() end
    local fullLayout = addon.FullLayout or _G.HorizonSuite_FullLayout
    if fullLayout and not InCombatLockdown() then fullLayout() end
end


-- ---------------------------------------------------------------------------
-- OptionCategories: Axis hub first (Modules, Global Toggles, Profiles), then per-module tabs
-- (Focus, Presence, …), Insight (Global / Player / NPC / Item), Vista …, Cache
-- ---------------------------------------------------------------------------

local OptionCategories = {
}

-- ---------------------------------------------------------------------------
-- Search index: flatten all options for search (name + desc + section)
-- Includes optionId, sectionName, categoryIndex for navigation.
-- Match uses word tokens (alphanumeric runs) with prefix matching; see OptionsData_SearchEntryScore.
-- ---------------------------------------------------------------------------

local function TokenizeSearchCorpus(str)
    local t = {}
    if not str or str == "" then return t end
    local lower = str:lower()
    for word in string.gmatch(lower, "%w+") do
        t[#t + 1] = word
    end
    return t
end

local function ParseSearchQueryTerms(query)
    local terms = {}
    if not query or query == "" then return terms end
    local q = query:lower()
    q = q:gsub("^%s+", ""):gsub("%s+$", "")
    for word in string.gmatch(q, "%w+") do
        terms[#terms + 1] = word
    end
    return terms
end

-- Best score for one query term against a token list (exact word or whole-token prefix if term length >= 2).
local function TermScoreAgainstTokens(term, tokens, exactScore, prefixScore)
    local best = 0
    if not tokens then return 0 end
    for i = 1, #tokens do
        local w = tokens[i]
        if w == term then
            if exactScore > best then best = exactScore end
        elseif #term >= 2 and #w >= #term and string.sub(w, 1, #term) == term then
            if prefixScore > best then best = prefixScore end
        end
    end
    return best
end

--- Score an index entry for a lowercased search string; nil if no match.
--- Multi-word queries require every term to match some token (AND). Higher = better (name > section > category > module > option id > desc).
--- @param entry table Row from OptionsData_BuildSearchIndex()
--- @param queryLower string Trimmed, lowercased query
--- @return number|nil
function OptionsData_SearchEntryScore(entry, queryLower)
    if not entry or not queryLower or queryLower == "" then return nil end
    local terms = ParseSearchQueryTerms(queryLower)
    if #terms == 0 then return nil end
    local total = 0
    for ti = 1, #terms do
        local term = terms[ti]
        local best = 0
        local function bump(tokens, exactPts, prefixPts)
            local s = TermScoreAgainstTokens(term, tokens, exactPts, prefixPts)
            if s > best then best = s end
        end
        bump(entry.searchTokensName, 1000, 700)
        bump(entry.searchTokensSection, 400, 280)
        bump(entry.searchTokensCategory, 350, 240)
        bump(entry.searchTokensModule, 300, 200)
        bump(entry.searchTokensOptionId, 180, 120)
        bump(entry.searchTokensDesc, 150, 100)
        if best == 0 then return nil end
        total = total + best
    end
    return total
end

local function StripSearchDisplayFormatting(s)
    if s == nil then return "" end
    s = tostring(s)
    s = s:gsub("|c%x%x%x%x%x%x%x", ""):gsub("|r", "")
    s = s:gsub("|n", " ")
    s = s:gsub("|T[^|]-|t", "")
    return s
end

local function NormalizeSearchDisplayWhitespace(s)
    s = s:gsub("%s+", " ")
    return s:gsub("^%s+", ""):gsub("%s+$", "")
end

--- Plain-text option description and tooltip for search dropdown rows (why this matched).
--- @param opt table Option definition from OptionCategories
--- @param maxLen number|nil Max characters before "..." (default 140)
--- @return string
function OptionsData_SearchResultDetailText(opt, maxLen)
    if not opt then return "" end
    maxLen = maxLen or 140
    local rawD = type(opt.desc) == "function" and opt.desc() or opt.desc
    local rawT = type(opt.tooltip) == "function" and opt.tooltip() or opt.tooltip
    local d = NormalizeSearchDisplayWhitespace(StripSearchDisplayFormatting(rawD))
    local t = NormalizeSearchDisplayWhitespace(StripSearchDisplayFormatting(rawT))
    local combined
    if d ~= "" and t ~= "" and t ~= d then
        combined = d .. " · " .. t
    elseif d ~= "" then
        combined = d
    else
        combined = t
    end
    if #combined <= maxLen then return combined end
    return string.sub(combined, 1, maxLen - 3) .. "..."
end

function OptionsData_BuildSearchIndex()
    local index = {}
    local cats = addon.OptionCategories
    for catIdx, cat in ipairs(cats) do
        local currentSection = ""
        local moduleKey = cat.moduleKey
        local moduleLabel
        if cat.key == "Profiles" or cat.key == "Modules" or cat.key == "GlobalToggles" then
            moduleLabel = BrandModule("axis") or "Axis"
        else
            moduleLabel = BrandModule(moduleKey) or L["MODULES"]
        end
        local catNameRaw = type(cat.name) == "function" and cat.name() or cat.name
        local catNameStr = tostring(catNameRaw or "")
        local catNameLower = catNameStr:lower()
        local catOpts = type(cat.options) == "function" and cat.options() or cat.options
        for _, opt in ipairs(catOpts) do
            if opt.type == "section" then
                currentSection = type(opt.name) == "function" and opt.name() or opt.name or ""
            elseif opt.type ~= "section" and opt.type ~= "header" and opt.type ~= "moduleReloadPrompt" then
                local rawName = type(opt.name) == "function" and opt.name() or opt.name
                local name = (rawName or ""):lower()
                local desc = ((opt.desc or "") .. " " .. (opt.tooltip or "")):lower()
                local sectionLower = (currentSection or ""):lower()
                local moduleLower = (moduleLabel or ""):lower()
                local searchText = name .. " " .. desc .. " " .. sectionLower .. " " .. moduleLower
                local optionId = opt.dbKey or (cat.key .. "_" .. (rawName or ""):gsub("%s+", "_"))
                local idForTokens = tostring(optionId or ""):lower():gsub("_+", " ")
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
                    searchTokensName = TokenizeSearchCorpus(name),
                    searchTokensDesc = TokenizeSearchCorpus(desc),
                    searchTokensSection = TokenizeSearchCorpus(sectionLower),
                    searchTokensModule = TokenizeSearchCorpus(moduleLower),
                    searchTokensCategory = TokenizeSearchCorpus(catNameLower),
                    searchTokensOptionId = TokenizeSearchCorpus(idForTokens),
                }
            end
        end
    end
    return index
end

local function getVisibleCategories()
    local out = {}
    for _, cat in ipairs(OptionCategories) do
        out[#out + 1] = cat
    end
    return out
end

-- Export for panel and module option files
addon.BrandModule = BrandModule
addon.OptionsData_GetDB = OptionsData_GetDB
addon.OptionsData_SetDB = OptionsData_SetDB
addon.OptionsData_GetFontList = function()
    if addon.RefreshFontList then addon.RefreshFontList() end
    return (addon.GetFontList and addon.GetFontList()) or {}
end
addon.OptionsData_NotifyMainAddon = OptionsData_NotifyMainAddon
addon.OptionsData_SetUpdateFontsRef = OptionsData_SetUpdateFontsRef
addon.OptionCategories = getVisibleCategories()
addon.OptionsData_BuildSearchIndex = OptionsData_BuildSearchIndex
addon.OptionsData_SearchEntryScore = OptionsData_SearchEntryScore
addon.OptionsData_SearchResultDetailText = OptionsData_SearchResultDetailText
