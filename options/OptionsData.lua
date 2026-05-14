--[[
    Horizon Suite - Focus - Options Data
    OptionCategories (Insight: InsightGlobal, InsightPlayer, InsightNpc, InsightItem + others), getDB/setDB/notifyMainAddon, search index.
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

local INSIGHT_KEYS = {
    insightAnchorMode       = true,
    insightCursorSide       = true,
    insightFixedPoint       = true,
    insightFixedX           = true,
    insightFixedY           = true,
    insightCursorOffsetX    = true,
    insightCursorOffsetY    = true,
    insightFocusDynamicInFixed = true,
    insightHideTooltipsInCombat = true,
    insightBgOpacity       = true,
    insightShowMount            = true,
    insightShowIlvl             = true,
    insightItemLevelMode        = true,
    insightShowSpecRole         = true,
    insightShowCharacterTitle   = true,
    insightRealmNameMode        = true,
    insightRaceIcons            = true,
    insightPlayerNameColor      = true,
    insightPlayerNameGradient   = true,
    insightTitleColorMode       = true,
    insightTitleMatchNameColor  = true,
    insightTitleColor           = true,
    insightTitleColorR          = true,
    insightTitleColorG          = true,
    insightTitleColorB          = true,
    insightShowHonorLevel       = true,
    insightHonorLevelMode       = true,
    insightShowStatusBadges     = true,
    insightStatusBadgeCombat    = true,
    insightStatusBadgeAFK       = true,
    insightStatusBadgeDND       = true,
    insightStatusBadgePVP       = true,
    insightStatusBadgeGroup     = true,
    insightStatusBadgeFriend    = true,
    insightStatusBadgeTargeting = true,
    insightShowMythicScore  = true,
    insightMythicScoreMode  = true,
    insightRatingsIcons     = true,
    insightShowTransmog     = true,
    insightShowGuildRank    = true,
    insightSeparatorMode    = true,
    insightBlankSeparator   = true,
    insightShowIcons       = true,
    insightClassIconSource = true,
    insightFontPath        = true,
    insightHeaderSize      = true,
    insightBodySize        = true,
    insightBadgesSize      = true,
    insightStatsSize       = true,
    insightMountSize       = true,
    insightTransmogSize    = true,
    insightMountOwnershipDisplay = true,
    -- NPC tooltip
    insightNpcReactionBorder    = true,
    insightNpcReactionName      = true,
    insightNpcShowLevelLine     = true,
    insightNpcShowIcons         = true,
    insightNpcHeaderSize        = true,
    insightNpcBodySize          = true,
    -- Item tooltip
    insightItemQualityBorder    = true,
    insightItemNameGradient     = true,
    insightItemSectionSpacing   = true,
    insightItemHeaderSize       = true,
    insightItemBodySize         = true,
    insightItemTransmogSize     = true,
    -- Player tooltip (per-type font sizes)
    insightPlayerHeaderSize     = true,
    insightPlayerBodySize       = true,
    insightPlayerBadgesSize     = true,
    insightPlayerStatsSize      = true,
    insightPlayerMountSize      = true,

}

local ESSENCE_KEYS = {
    essenceX             = true,
    essenceY             = true,
    essencePoint         = true,
    essenceScale         = true,
    essenceShowModel     = true,
    essenceLockPosition  = true,
    essenceStatCap       = true,
    essenceShowIlvlBadge = true,
    essenceShowTitle     = true,
    essenceShowStatBars  = true,
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
    presencePrimaryLargeSz = true,
    presenceSecondaryLargeSz = true,
    presencePrimaryMediumSz = true,
    presenceSecondaryMediumSz = true,
    presencePrimarySmallSz = true,
    presenceSecondarySmallSz = true,
    presenceTitleFontPath = true,
    presenceSubtitleFontPath = true,
    presenceTitleFontOutline = true,
    presenceSubtitleFontOutline = true,
    presenceZoneTypeColoring = true,
    presenceZoneColorFriendly = true,
    presenceZoneColorHostile = true,
    presenceZoneColorContested = true,
    presenceZoneColorSanctuary = true,
    presenceSuppressInDungeon = true,
    presenceSuppressInRaid = true,
    presenceSuppressInDelve = false,
    presenceSuppressInPvP = true,
    presenceSuppressInBattleground = true,
    presenceHideQuestUpdateTitle = true,
    presencePreviewType = true,
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
    if PRESENCE_KEYS[key] and addon.Presence then
        if addon.Presence.ApplyPresenceOptions then addon.Presence.ApplyPresenceOptions() end
        if addon.Presence.ApplyBlizzardSuppression then addon.Presence.ApplyBlizzardSuppression() end
    end
    if INSIGHT_KEYS[key] and addon.Insight and addon.Insight.ApplyInsightOptions then
        addon.Insight.ApplyInsightOptions()
    end
    if ESSENCE_KEYS[key] and addon.Essence and addon.Essence.ApplyEssenceOptions then
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
-- Option value helpers (used in category descriptors)
-- ---------------------------------------------------------------------------

local function getDB(k, d) return addon.GetDB(k, d) end
local function setDB(k, v) return OptionsData_SetDB(k, v) end


local defaultDashboardFontPath = (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"


local function GetDashboardFontDropdownOptions()
    if addon.RefreshFontList then addon.RefreshFontList() end
    local list = (addon.GetFontList and addon.GetFontList()) or {}
    local saved = getDB("dashboardFontPath", defaultDashboardFontPath)
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
    out[#out + 1] = { L["FOCUS_CUSTOM"], saved }
    return out
end

local FONT_USE_GLOBAL = "__global__"

local function GetPerElementFontDropdownOptions(dbKey)
    if addon.RefreshFontList then addon.RefreshFontList() end
    local list = (addon.GetFontList and addon.GetFontList()) or {}
    local out = { { L["FOCUS_GLOBAL_FONT"], FONT_USE_GLOBAL } }
    for i = 1, #list do out[#out + 1] = list[i] end
    local saved = getDB(dbKey, FONT_USE_GLOBAL)
    if saved == FONT_USE_GLOBAL then return out end
    for _, o in ipairs(out) do
        if o[2] == saved then return out end
    end
    out[#out + 1] = { L["FOCUS_CUSTOM"], saved }
    return out
end

local function DisplayPerElementFont(value)
    if value == FONT_USE_GLOBAL then return L["FOCUS_GLOBAL_FONT"] end
    if addon.GetFontNameForPath then return addon.GetFontNameForPath(value) end
    return value
end

local OUTLINE_OPTIONS = {
    { L["FOCUS_OUTLINE_NONE"], "" },
    { L["FOCUS_OUTLINE"], "OUTLINE" },
    { L["FOCUS_THICK_OUTLINE"], "THICKOUTLINE" },
    { L["FOCUS_SLUG"] or "SLUG", "SLUG" },
    { L["FOCUS_SLUG_OUTLINE"] or "SLUG Outline", "OUTLINE, SLUG" },
    { L["FOCUS_SLUG_THICK_OUTLINE"] or "SLUG Thick Outline", "THICKOUTLINE, SLUG" },
}
local VALID_OUTLINE_VALUES = {
    [""] = true,
    OUTLINE = true,
    THICKOUTLINE = true,
    SLUG = true,
    ["OUTLINE, SLUG"] = true,
    ["THICKOUTLINE, SLUG"] = true,
}
-- Use addon.QUEST_COLORS from Config as single source for quest type colors.
local COLOR_KEYS_ORDER = { "DEFAULT", "CAMPAIGN", "IMPORTANT", "LEGENDARY", "WORLD", "DELVES", "SCENARIO", "RAID", "ACHIEVEMENT", "APPEARANCE", "WEEKLY", "PREY", "DAILY", "COMPLETE", "RARE" }
local ZONE_COLOR_DEFAULT = { 0.55, 0.65, 0.75 }
local OBJ_COLOR_DEFAULT = { 0.78, 0.78, 0.78 }
local OBJ_DONE_COLOR_DEFAULT = { 0.20, 1.00, 0.40 }  -- matches Ready to Turn In #33FF66
local HIGHLIGHT_COLOR_DEFAULT = { 0.4, 0.7, 1 }


-- ---------------------------------------------------------------------------
-- OptionCategories: Axis hub first (Modules, Global Toggles, Profiles), then per-module tabs
-- (Focus, Presence, …), Insight (Global / Player / NPC / Item), Vista …, Cache
-- ---------------------------------------------------------------------------

local OptionCategories = {
    {
        key = "Modules",
        name = L["MODULES"],
        moduleKey = nil,
        options = (function()
            local previewSuffix = " |cff228b22(" .. (L["PRESENCE_PREVIEW"] or "Preview") .. ")|r"
            local previewDescSuffix = "\n\n" .. (L["MODULE_PREVIEW_DISCLAIMER"] or "This module is currently in an early preview (alpha) state. Daily use is not advised due to bugs or unfinished functionality.")
            local function setModuleFromOptions(moduleKey, v)
                local dash = _G.HorizonSuiteDashboard
                local defer = dash and dash:IsShown()
                addon:SetModuleEnabled(moduleKey, v, defer and { deferReload = true } or nil)
            end
            local opts = {
                { type = "section", name = L["MODULE_TOGGLES"] or "Module Toggles" },
                { type = "toggle", name = BrandModule("focus"), desc = L["DASH_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS"], dbKey = "_module_focus", get = function() return addon:IsModuleEnabled("focus") end, set = function(v) setModuleFromOptions("focus", v) end },
                { type = "toggle", name = BrandModule("presence"), desc = L["DASH_ZONE_TEXT_AND_NOTIFICATIONS"], dbKey = "_module_presence", get = function() return addon:IsModuleEnabled("presence") end, set = function(v) setModuleFromOptions("presence", v) end },
                { type = "toggle", name = BrandModule("vista"), desc = L["DASH_MINIMAP_ZONE_TEXT_COORDS_BUTTON"] or "Minimap with zone text, coords, time, and button collector.", dbKey = "_module_vista", get = function() return addon:IsModuleEnabled("vista") end, set = function(v) setModuleFromOptions("vista", v) end },
                { type = "toggle", name = BrandModule("insight"), desc = L["DASH_TOOLTIPS_CLASS_COLOURS_SPEC_FACTION"], dbKey = "_module_insight", get = function() return addon:IsModuleEnabled("insight") end, set = function(v) setModuleFromOptions("insight", v) end },
                { type = "toggle", name = (BrandModule("cache") or "Cache") .. previewSuffix, desc = (L["DASH_LOOT_TOASTS_ITEMS_MONEY_CURRENCY"] or "") .. previewDescSuffix, dbKey = "_module_cache", get = function() return addon:IsModuleEnabled("cache") end, set = function(v) setModuleFromOptions("cache", v) end },
                { type = "toggle", name = (BrandModule("essence") or "Essence") .. previewSuffix, desc = (L["DASH_ESSENCE_MODULE_SHORT_DESCRIPTION"] or "Custom character sheet with 3D model, item level, stats, and gear grid.") .. previewDescSuffix, dbKey = "_module_essence", get = function() return addon:IsModuleEnabled("essence") end, set = function(v) setModuleFromOptions("essence", v) end },
                { type = "moduleReloadPrompt" },
            }
            return opts
        end)(),
    },
    {
        key = "GlobalToggles",
        name = L["AXIS_GLOBAL_TOGGLES"] or "Global Settings",
        desc = L["AXIS_SUITE_WIDE_CLASS_COLOUR_TINTING_UI"] or "Suite-wide class colour tinting and UI scale (global or per module).",
        moduleKey = nil,
        options = function()
            local opts = {}
            opts[#opts + 1] = { type = "section", name = L["AXIS_DASHBOARD_SECTION"] or "Dashboard" }
            opts[#opts + 1] = {
                type = "dropdown",
                name = L["AXIS_MODULE_NAME_DISPLAY"] or "Module Name Style",
                desc = L["AXIS_MODULE_NAME_DISPLAY_DESC"] or "How module names appear in the settings panel navigation and search filter.",
                dbKey = "moduleNameDisplay",
                options = {
                    { L["AXIS_MODULE_NAME_HORIZON"]     or "Horizon",     "horizon"     },
                    { L["AXIS_MODULE_NAME_SUBTITLE"]    or "Subtitle",    "subtitle"    },
                    { L["AXIS_MODULE_NAME_SIMPLE"] or "Simple", "simple" },
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
                        label = L["FOCUS_DASHBOARD_BACKGROUND_MINIMALISTIC"] or "Minimalistic"
                    elseif id == "midnight" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_MIDNIGHT"] or "Midnight"
                    elseif id == "teldrassilburns" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_TELDRASSIL_BURNS"] or "Teldrassil"
                    elseif id == "nightfae" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_NIGHTFAE"] or "Night Fae"
                    elseif id == "ardenweald" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_ARDENWEALD"] or "Ardenweald"
                    elseif id == "zinazshari" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_ZIN_AZSHARI"] or "Zin-Azshari"
                    elseif id == "suramargarden" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_SURAMAR_GARDEN"] or "Suramar Garden"
                    elseif id == "quelthalas" then
                        label = L["DASH_BACKGROUND_QUEL_THALAS"] or "Quel'Thalas"
                    elseif id == "twilightvineyards" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_TWILIGHT_VINEYARDS"] or "Twilight Vineyards"
                    elseif id == "zulaman" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_ZUL_AMAN"] or "Zul'Aman"
                    elseif id == "illidan" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_ILLIDAN"] or "Illidan"
                    elseif id == "lichking" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_LICH_KING"] or "The Lich King"
                    elseif id == "tbcanniversary" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_TBC_ANNIVERSARY"] or "TBC Anniversary"
                    elseif id == "beledarslight" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_BELEDARS_LIGHT"] or "Beledar's Light"
                    elseif id == "talents" then
                        label = L["FOCUS_DASHBOARD_BACKGROUND_CLASS_TALENTS"] or "Specialisation (auto)"
                    else
                        label = id
                    end
                    out[#out + 1] = { label, id }
                end
                return out
            end
            opts[#opts + 1] = {
                type = "dropdown",
                name = L["FOCUS_DASHBOARD_BACKGROUND"] or "Dashboard background",
                desc = L["DASH_BACKGROUND"] or "Background style for the module dashboard window (Axis). Minimalistic is flat; bundled themes use full-bleed art; Specialisation (auto) uses the in-game talent UI background for your current specialization.",
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
                type = "slider", name = L["FOCUS_DASHBOARD_BACKGROUND_OPACITY"] or "Dashboard background opacity",
                desc = L["FOCUS_ADJUST_OPACITY_OF_DASHBOARD_BACKGROUND"] or "Adjust the opacity of the dashboard background (50–100%). Lower values let more of the game world show through.",
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
                name = L["DASHBOARD_TYPO_FONT"] or "Dashboard Font",
                desc = L["DASHBOARD_TYPO_FONT_DESC"] or "Font for the Axis settings window (sidebar, search, options list). Independent of the Focus tracker font.",
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
                name = L["DASHBOARD_TYPO_SIZE"] or "Dashboard Text Size",
                desc = L["DASHBOARD_TYPO_SIZE_DESC"] or "Size of body text in the Axis settings window. All other dashboard text scales proportionally.",
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
                name = L["DASHBOARD_TYPO_OUTLINE"] or "Dashboard Text Outline",
                desc = L["DASHBOARD_TYPO_OUTLINE_DESC"] or "Outline style for dashboard text.",
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
                name = L["DASHBOARD_TYPO_SHADOW"] or "Dashboard Text Shadow",
                desc = L["DASHBOARD_TYPO_SHADOW_DESC"] or "Add a drop shadow behind dashboard text to improve readability.",
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
                name = L["DASHBOARD_TYPO_HEADING_COLOR"] or "Heading Colour",
                desc = L["DASHBOARD_TYPO_HEADING_COLOR_DESC"] or "Colour of the large headings on the Welcome and News tabs. Use a softer tone if pure white feels too bright on HDR displays.",
                dbKey = "dashboardHeadingColor",
                options = {
                    { L["DASHBOARD_TYPO_HEADING_COLOR_WHITE"] or "White (default)", "white" },
                    { L["DASHBOARD_TYPO_HEADING_COLOR_CYAN"]  or "Cyan (relaxed)",  "cyan"  },
                    { L["DASHBOARD_TYPO_HEADING_COLOR_GOLD"]  or "Gold (relaxed)",  "gold"  },
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
                name = L["AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN"] or "Show Patch Notes Popup After Update",
                desc = L["AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN_DESC"] or "When on, Axis opens to Patch Notes once after each new addon version. When off, a green dot appears on the Horizon minimap icon until you open Patch Notes.",
                dbKey = "autoShowPatchNotesOnLogin",
                get = function() return getDB("autoShowPatchNotesOnLogin", true) end,
                set = function(v) setDB("autoShowPatchNotesOnLogin", v) end,
            }
            opts[#opts + 1] = { type = "section", name = L["AXIS_CLASS_THEME_SECTION"] or "Class Theme" }
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
                name = L["AXIS_GLOBAL_CLASS_THEME"] or "Global Class Theme",
                desc = L["DASH_CLASS_COLOURS_MODULES_GLOBAL"] or "Toggle class colours on or off for all modules at once.",
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
                name = L["AXIS_CLASS_THEME_DASHBOARD"] or "Dashboard",
                desc = L["AXIS_CLASS_THEME_DASHBOARD_DESC"] or "Enables Dashboard class theming. Flipping it on turns on Class Colours, Dashboard Class Icon, and Override Background; each sub-option can then be adjusted independently while the master stays on.",
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
                name = L["AXIS_DASHBOARD_CLASS_COLOURS"] or "Class Colours",
                desc = L["AXIS_CLASS_COLOURS_DESC"] or "Tint dashboard accents, dividers, and highlights with your class colour.",
                dbKey = "classColorDashboard",
                get = function() return getDB("classColorDashboard", false) end,
                set = function(v) setDB("classColorDashboard", v) end,
                visibleWhen = isDashboardClassThemeOn,
                refreshIds = { "_classColorAll" },
            }
            opts[#opts + 1] = {
                type = "toggle",
                name = L["AXIS_DASHBOARD_CLASS_ICON"] or "Dashboard Class Icon",
                desc = L["AXIS_DASHBOARD_CLASS_ICON_DESC"] or "Show a class icon on the Dashboard. Independent of class colour tinting and of the class background override.",
                dbKey = "dashboardShowClassIcon",
                get = function() return getDB("dashboardShowClassIcon", false) end,
                set = function(v) setDB("dashboardShowClassIcon", v) end,
                visibleWhen = isDashboardClassThemeOn,
                refreshIds = { "dashboardShowClassIcon", "dashboardClassIconSource" },
            }
            opts[#opts + 1] = {
                type = "dropdown",
                name = L["DASHBOARD_CLASS_ICON_STYLE"] or "Dashboard Class Icon Style",
                desc = L["DASH_CLASS_ICONS_RONDOMEDIA"] or "Blizzard default or RondoMedia class icon on the Dashboard. Independent of Insight tooltip class icons.",
                tooltip = L["AXIS_CLASS_ICON_SOURCES_TOOLTIP"],
                dbKey = "dashboardClassIconSource",
                options = {
                    { L["AXIS_CUSTOM_CLASS_ICONS_LABEL"] or "Horizon", "custom" },
                    { L["AXIS_DEFAULT"] or "Default", "default" },
                    { "RondoMedia", "rondomedia" },
                },
                get = function() return getDB("dashboardClassIconSource", "custom") end,
                set = function(v) setDB("dashboardClassIconSource", v) end,
                visibleWhen = function() return isDashboardClassThemeOn() and getDB("dashboardShowClassIcon", false) end,
                refreshIds = { "dashboardShowClassIcon" },
            }
            opts[#opts + 1] = {
                type = "toggle",
                name = L["AXIS_DASHBOARD_BG_CLASS_OVERRIDE"] or "Override Background to Class Background",
                desc = L["AXIS_DASHBOARD_BG_CLASS_OVERRIDE_DESC"] or "Replace the Dashboard background with a class-themed background. Independent of class colour tinting and of the class icon.",
                dbKey = "dashboardBackgroundClassOverride",
                get = function() return getDB("dashboardBackgroundClassOverride", false) end,
                set = function(v) setDB("dashboardBackgroundClassOverride", v) end,
                visibleWhen = isDashboardClassThemeOn,
                refreshIds = { "dashboardBackgroundTheme" },
            }
            opts[#opts + 1] = { type = "toggle", name = BrandModule("focus"), desc = L["FOCUS_CLASS_COLOURS_DESC"] or "Tint Focus header title, category section headers, main and between-section dividers, and super-tracked highlight bars and borders with your class colour.", dbKey = "classColorFocus", get = function() return getDB("classColorFocus", false) end, set = function(v) setDB("classColorFocus", v) end, refreshIds = { "_classColorAll" } }
            opts[#opts + 1] = { type = "toggle", name = BrandModule("presence"), desc = L["PRESENCE_CLASS_COLOURS_DESC"] or "Tint Presence toast title and divider with your class colour.", dbKey = "classColorPresence", get = function() return getDB("classColorPresence", false) end, set = function(v) setDB("classColorPresence", v) end, refreshIds = { "_classColorAll" } }
            opts[#opts + 1] = { type = "toggle", name = BrandModule("vista"), desc = L["VISTA_CLASS_COLOURS_DESC"] or "Tint Vista minimap, addon-bar, and panel borders and text with your class colour.", dbKey = "classColorVista", get = function() return getDB("classColorVista", false) end, set = function(v) setDB("classColorVista", v) end, refreshIds = { "_classColorAll" } }
            opts[#opts + 1] = { type = "toggle", name = BrandModule("insight"), desc = L["INSIGHT_CLASS_COLOURS_DESC"] or "Use class colour for player tooltip name, class line, and border.", dbKey = "classColorInsight", get = function() return getDB("classColorInsight", false) end, set = function(v) setDB("classColorInsight", v) end, refreshIds = { "_classColorAll" } }
            opts[#opts + 1] = { type = "toggle", name = BrandModule("cache"), desc = L["CACHE_CLASS_COLOURS_DESC"] or "Tint Cache loot icon glow and edit/anchor borders with your class colour.", dbKey = "classColorCache", get = function() return getDB("classColorCache", false) end, set = function(v) setDB("classColorCache", v) end, refreshIds = { "_classColorAll" } }
            opts[#opts + 1] = { type = "toggle", name = BrandModule("essence"), desc = L["ESSENCE_CLASS_COLOURS_DESC"] or "Tint the character name on the Essence sheet with your class colour.", dbKey = "classColorEssence", get = function() return getDB("classColorEssence", false) end, set = function(v) setDB("classColorEssence", v) end, refreshIds = { "_classColorAll" } }
            opts[#opts + 1] = { type = "section", name = L["AXIS_GLOBAL_FONT_SECTION"] or "Global Font (Coming Soon!)" }
            opts[#opts + 1] = { type = "section", name = L["AXIS_GLOBAL_SCALE_SECTION"] or "Global Scale" }
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
            opts[#opts + 1] = { type = "section", name = L["AXIS_MINIMAP_ICON_SECTION"] or "Minimap Icon" }
            opts[#opts + 1] = { type = "toggle", name = L["PRESENCE_SHOW_MINIMAP_ICON"] or "Show minimap icon", desc = L["PRESENCE_A_CLICKABLE_ICON_MINIMAP_OPENS"] or "Show a clickable icon on the minimap that opens the options panel.", dbKey = "hideMinimapButton", get = function() return not getDB("hideMinimapButton", false) end, set = function(v)
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
            opts[#opts + 1] = { type = "toggle", name = L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER"] or "Fade until minimap hover", desc = L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER_DESC"] or "When on, the icon stays hidden until you move the cursor over the minimap. When off, it stays visible.", dbKey = "minimapButtonShowOnlyOnMinimapHover", visibleWhen = isMinimapStandalone, get = function() return getDB("minimapButtonShowOnlyOnMinimapHover", false) end, set = function(v)
                C_Timer.After(0, function()
                    setDB("minimapButtonShowOnlyOnMinimapHover", v)
                    if addon.MinimapButton_UpdateVisibility then addon.MinimapButton_UpdateVisibility() end
                end)
            end }
            opts[#opts + 1] = { type = "toggle", name = L["PRESENCE_LOCK_MINIMAP_BUTTON_POSITION"] or "Lock minimap button position", desc = L["PRESENCE_PREVENT_DRAGGING_HORIZON_MINIMAP_BUTTON"] or "Prevent dragging the Horizon minimap button.", dbKey = "minimapButtonLocked", visibleWhen = isMinimapStandalone, get = function() return getDB("minimapButtonLocked", false) end, set = function(v)
                C_Timer.After(0, function() setDB("minimapButtonLocked", v) end)
            end }
            opts[#opts + 1] = { type = "toggle", name = L["AXIS_MINIMAP_ICON_CIRCULAR"] or "Circular icon",
                desc = L["AXIS_MINIMAP_ICON_CIRCULAR_DESC"] or "Round the Horizon icon, add a gold ring border, and snap it to the minimap's edge while dragging — matching calendar, clock, and other standard minimap buttons.",
                dbKey = "minimapButtonCircular", visibleWhen = isMinimapStandalone,
                get = function() return getDB("minimapButtonCircular", false) end,
                set = function(v)
                    setDB("minimapButtonCircular", v)
                    if addon.MinimapButton_ApplyShape then addon.MinimapButton_ApplyShape() end
                    -- Re-place the button: circular reads angle / square reads x/y.
                    if addon.MinimapButton_ApplyPosition then addon.MinimapButton_ApplyPosition() end
                end }
            opts[#opts + 1] = { type = "button", dbKey = "__minimapButtonReset", name = L["PRESENCE_RESET_MINIMAP_BUTTON_POSITION"] or "Reset minimap button position", desc = L["PRESENCE_RESET_MINIMAP_BUTTON_DEFAULT_POSITION"] or "Reset the minimap button to the default position (bottom-left).", visibleWhen = isMinimapStandalone, onClick = function() setDB("minimapButtonX", nil); setDB("minimapButtonY", nil); setDB("minimapButtonAngle", nil); if addon.MinimapButton_ApplyPosition then addon.MinimapButton_ApplyPosition() end end }
            return opts
        end,
    },
    {
        key = "Profiles",
        name = L["PROFILES"] or "Profiles",
        desc = L["MANAGE_SWITCH_BETWEEN_YOUR_ADDON_CONFIGURATIONS"] or "Manage and switch between your addon configurations.",
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
            opts[#opts + 1] = { type = "section", name = L["PROFILES"] or "Profiles" }

            opts[#opts + 1] = {
                type = "toggle",
                name = L["AXIS_GLOBAL_PROFILE"] or "Global profile",
                desc = L["AXIS_CHARACTERS_SAME_PROFILE"] or "All characters use the same profile.",
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
                    name = L["AXIS_CURRENT_PROFILE"] or "Current profile",
                    desc = L["AXIS_SELECT_PROFILE_CURRENTLY"] or "Select the profile currently in use.",
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

                opts[#opts + 1] = {
                    type = "button",
                    name = L["DEFAULT"] or "New from Default",
                    desc = L["AXIS_CREATES_A_PROFILE_DEFAULT_SETTINGS"] or "Creates a new profile with all default settings.",
                    dbKey = "_profiles_create_new",
                    onClick = function()
                        if addon.ShowCreateProfilePopup then addon.ShowCreateProfilePopup("Default") end
                    end,
                }

                opts[#opts + 1] = {
                    type = "dropdown",
                    name = L["AXIS_COPY_PROFILE"] or "Copy from profile",
                    desc = L["AXIS_SOURCE_PROFILE_COPYING"] or "Source profile for copying.",
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
                    name = L["AXIS_COPY_SELECTED"] or "Copy from selected",
                    desc = L["AXIS_CREATES_A_PROFILE_COPIED_SELECTED_SOURC"] or "Creates a new profile copied from the selected source profile.",
                    dbKey = "_profiles_copy_selected",
                    onClick = function()
                        local src = addon._profileCopyFrom or (addon.GetActiveProfileKey and addon.GetActiveProfileKey())
                        if addon.ShowCreateProfilePopup then addon.ShowCreateProfilePopup(src) end
                    end,
                }

                opts[#opts + 1] = {
                    type = "dropdown",
                    name = "|cffff4040!|r " .. (L["AXIS_DELETE_PROFILE"] or "Delete profile"),
                    desc = L["AXIS_SELECT_A_PROFILE_DELETE_CURRENT_DEFAULT"] or "Select a profile to delete (current and Default not shown).",
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
                    name = L["AXIS_DELETE_SELECTED_PROFILE"] or "Delete selected profile",
                    desc = L["AXIS_DELETES_SELECTED_PROFILE"] or "Deletes the selected profile.",
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
                            if addon.OnActiveProfileChanged then addon.OnActiveProfileChanged() end
                        end
                    end,
                }

                opts[#opts + 1] = {
                    type = "moduleReloadPrompt",
                    hintText = L["PROFILE_RELOAD_HINT"] or "Reload the interface to finish applying profile changes.",
                }

                -- Section B: Per-spec switch + spec dropdowns
                opts[#opts + 1] = { type = "section", name = L["AXIS_SPEC_PROFILES"] or "Spec Profiles" }

                opts[#opts + 1] = {
                    type = "toggle",
                    name = L["AXIS_ENABLE"] or "Enable",
                    desc = L["AXIS_PICK_DIFFERENT_PROFILES_PER_SPEC"] or "Pick different profiles per spec.",
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

                opts[#opts + 1] = {
                    type = "moduleReloadPrompt",
                    hintText = L["PROFILE_RELOAD_HINT"] or "Reload the interface to finish applying profile changes.",
                }

                -- Section C: Sharing (export / import)
                opts[#opts + 1] = { type = "section", name = L["AXIS_SHARING"] or "Sharing" }

                opts[#opts + 1] = {
                    type = "dropdown",
                    name = L["AXIS_EXPORT_PROFILE"] or "Export profile",
                    desc = L["AXIS_SELECT_A_PROFILE_EXPORT"] or "Select a profile to export.",
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
                    labelText = L["AXIS_EXPORT_STRING"] or "Export string",
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
                    labelText = L["AXIS_IMPORT_STRING"] or "Import string",
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
                    name = L["AXIS_IMPORT_PROFILE"] or "Import profile",
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
addon.OptionsData_GetDB = OptionsData_GetDB
addon.OptionsData_SetDB = OptionsData_SetDB
addon.OptionsData_GetFontList = function()
    if addon.RefreshFontList then addon.RefreshFontList() end
    return (addon.GetFontList and addon.GetFontList()) or {}
end
addon.OptionsData_NotifyMainAddon = OptionsData_NotifyMainAddon
addon.OptionsData_SetUpdateFontsRef = OptionsData_SetUpdateFontsRef
addon.OUTLINE_OPTIONS = OUTLINE_OPTIONS
addon.FONT_USE_GLOBAL = FONT_USE_GLOBAL
addon.GetPerElementFontDropdownOptions = GetPerElementFontDropdownOptions
addon.DisplayPerElementFont = DisplayPerElementFont
addon.OptionCategories = getVisibleCategories()
addon.OptionsData_BuildSearchIndex = OptionsData_BuildSearchIndex
addon.OptionsData_SearchEntryScore = OptionsData_SearchEntryScore
addon.OptionsData_SearchResultDetailText = OptionsData_SearchResultDetailText
addon.COLOR_KEYS_ORDER = COLOR_KEYS_ORDER
addon.ZONE_COLOR_DEFAULT = ZONE_COLOR_DEFAULT
addon.OBJ_COLOR_DEFAULT = OBJ_COLOR_DEFAULT
addon.OBJ_DONE_COLOR_DEFAULT = OBJ_DONE_COLOR_DEFAULT
addon.HIGHLIGHT_COLOR_DEFAULT = HIGHLIGHT_COLOR_DEFAULT
