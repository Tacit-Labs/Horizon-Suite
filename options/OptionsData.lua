--[[
    Horizon Suite - Focus - Options Data
    OptionCategories (Insight: InsightGlobal, InsightPlayer, InsightNpc, InsightItem + others), getDB/setDB/notifyMainAddon, search index.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end
if not _G[addon.DB_NAME] then _G[addon.DB_NAME] = {} end

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
    insightShowSpecRole         = true,
    insightShowCharacterTitle   = true,
    insightPlayerNameColor      = true,
    insightPlayerNameGradient   = true,
    insightTitleColor           = true,
    insightTitleColorR          = true,
    insightTitleColorG          = true,
    insightTitleColorB          = true,
    insightShowHonorLevel       = true,
    insightShowStatusBadges     = true,
    insightShowMythicScore  = true,
    insightShowTransmog     = true,
    insightShowGuildRank    = true,
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
    vistaDrawerButtonLocked = true, vistaButtonWhitelist = true,
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
        local soon = L["FOCUS_COMING_SOON"] or "Coming soon"
        return {
            { L["FOCUS_PROFILE_BLIZZARD_DEFAULT"],                           "blizzardDefault" },
            { (L["FOCUS_PROFILE_HORIZON_PLUS"] or "Horizon+") .. " — " .. soon, "horizonPlus", true },
            { (L["FOCUS_PROFILE_CUSTOM"] or "Custom") .. " — " .. soon, "custom", true },
        }
    end
    return {
        { L["FOCUS_PROFILE_HORIZON_PLUS"],     "horizonPlus" },
        { L["FOCUS_PROFILE_BLIZZARD_DEFAULT"], "blizzardDefault" },
        { L["FOCUS_PROFILE_CUSTOM"],           "custom" },
    }
end

local defaultFontPath = (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"
local defaultDashboardFontPath = (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"

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

local function GetPresencePreviewDropdownOptions()
    local Presence = addon.Presence
    if not Presence or not Presence.PREVIEW_TYPE_ORDER or not Presence.PREVIEW_TYPE_LABELS then
        return { { L["PRESENCE_LEVEL_UP_TOGGLE"] or "Level up", "LEVEL_UP" } }
    end
    local out = {}
    for _, typeName in ipairs(Presence.PREVIEW_TYPE_ORDER) do
        local labelKey = Presence.PREVIEW_TYPE_LABELS[typeName]
        local label = labelKey and (L[labelKey] or labelKey) or typeName
        out[#out + 1] = { label, typeName }
    end
    return out
end

local OUTLINE_OPTIONS = {
    { L["FOCUS_OUTLINE_NONE"], "" },
    { L["FOCUS_OUTLINE"], "OUTLINE" },
    { L["FOCUS_THICK_OUTLINE"], "THICKOUTLINE" },
}
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
-- Use addon.QUEST_COLORS from Config as single source for quest type colors.
local COLOR_KEYS_ORDER = { "DEFAULT", "CAMPAIGN", "IMPORTANT", "LEGENDARY", "WORLD", "DELVES", "SCENARIO", "RAID", "ACHIEVEMENT", "APPEARANCE", "WEEKLY", "PREY", "DAILY", "COMPLETE", "RARE" }
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
                get = function()
                    local v = getDB("dashboardTextOutline", 1)
                    if v == "" or v == "OUTLINE" or v == "THICKOUTLINE" then return v end
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
            opts[#opts + 1] = { type = "button", dbKey = "__minimapButtonReset", name = L["PRESENCE_RESET_MINIMAP_BUTTON_POSITION"] or "Reset minimap button position", desc = L["PRESENCE_RESET_MINIMAP_BUTTON_DEFAULT_POSITION"] or "Reset the minimap button to the default position (bottom-left).", visibleWhen = isMinimapStandalone, onClick = function() setDB("minimapButtonX", nil); setDB("minimapButtonY", nil); if addon.MinimapButton_ApplyPosition then addon.MinimapButton_ApplyPosition() end end }
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
    {
        key = "Layout",
        name = L["DASH_LAYOUT"],
        moduleKey = "focus",
        options = {
            { type = "section", name = L["VISTA_POSITION_LAYOUT"] },
            { type = "toggle", name = L["FOCUS_LOCK_POSITION"], desc = L["FOCUS_PREVENT_DRAGGING_TRACKER"], dbKey = "lockPosition", get = function() return getDB("lockPosition", false) end, set = function(v) setDB("lockPosition", v) end },
            { type = "toggle", name = L["FOCUS_GROW_UPWARD"], desc = L["FOCUS_ANCHOR_BOTTOM_LIST_GROWS_UPWARD"], dbKey = "growUp", get = function() return getDB("growUp", false) end, set = function(v) setDB("growUp", v); if addon.focus and addon.focus.layout then addon.focus.layout.scrollOffset = 0; addon.focus.layout.scrollBottomOffset = 0 end; if addon.FullLayout then addon.FullLayout() end end, refreshIds = { "growUpHeaderMode" } },
            { type = "dropdown", name = L["FOCUS_GROW_HEADER"], desc = L["KEEP_HEADER_BOTTOM_TOP_UNTIL_COLLAPSED"], tooltip = L["FOCUS_GROWING_UPWARD_KEEP_HEADER_BOTTOM_TOP"], dbKey = "growUpHeaderMode", options = { { L["FOCUS_HEADER_BOTTOM"], "always" }, { L["FOCUS_HEADER_SLIDES_COLLAPSE"], "collapse" } }, get = function() return getDB("growUpHeaderMode", "always") end, set = function(v) setDB("growUpHeaderMode", v); if addon.FullLayout then addon.FullLayout() end end, visibleWhen = function() return getDB("growUp", false) end },
            { type = "toggle", name = L["FOCUS_START_COLLAPSED"], desc = L["FOCUS_START_HEADER_SHOWN_UNTIL_YOU_EXPAND"], dbKey = "collapsed", get = function() return getDB("collapsed", false) end, set = function(v) setDB("collapsed", v) end },
            { type = "section", name = L["FOCUS_DIMENSIONS"] },
            { type = "slider", name = L["FOCUS_PANEL_WIDTH"], desc = L["FOCUS_TRACKER_WIDTH_PIXELS"], dbKey = "panelWidth", min = 180, max = 800, get = function() return getDB("panelWidth", 260) end, set = function(v) setDB("panelWidth", math.max(180, math.min(800, v))) end },
            { type = "slider", name = L["FOCUS_MAX_CONTENT_HEIGHT"], desc = L["FOCUS_MAX_HEIGHT_OF_SCROLLABLE_LIST_PIXELS"], dbKey = "maxContentHeight", min = 200, max = 1500, get = function() return getDB("maxContentHeight", 480) end, set = function(v) setDB("maxContentHeight", math.max(200, math.min(1500, v))) end },
            { type = "toggle", name = L["FOCUS_STATIC_BACKGROUND"], desc = L["FOCUS_STATIC_BACKGROUND_DESC"], dbKey = "staticBackgroundEnabled", get = function() return getDB("staticBackgroundEnabled", false) end, set = function(v) setDB("staticBackgroundEnabled", v); if addon.FullLayout then addon.FullLayout() end end, refreshIds = { "staticPanelHeight" } },
            { type = "slider", name = L["FOCUS_STATIC_PANEL_HEIGHT"], desc = L["FOCUS_STATIC_PANEL_HEIGHT_DESC"], dbKey = "staticPanelHeight", min = 50, max = 1500, get = function() return math.max(50, math.min(1500, tonumber(getDB("staticPanelHeight", 400)) or 400)) end, set = function(v) setDB("staticPanelHeight", math.max(50, math.min(1500, v))); if addon.FullLayout then addon.FullLayout() end end, visibleWhen = function() return getDB("staticBackgroundEnabled", false) end },
            { type = "section", name = L["FOCUS_SPACING"] },
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
            { type = "section", name = L["DASH_FRAME"] },
            { type = "slider", name = L["FOCUS_BACKDROP_OPACITY"], desc = L["PANEL_BACKGROUND_OPACITY"], dbKey = "backdropOpacity", min = 0, max = 100, get = function() local v = tonumber(getDB("backdropOpacity", 0)) or 0; if v <= 1 and v > 0 then return math.floor(v * 100 + 0.5) end; return math.max(0, math.min(100, v)) end, set = function(v) setDB("backdropOpacity", math.max(0, math.min(100, v)) / 100) end },
            { type = "color", name = L["VISTA_BACKDROP_COLOUR"], desc = L["VISTA_PANEL_BACKGROUND_COLOUR"], dbKey = "backdropColor", get = function() return getDB("backdropColorR", 0.08), getDB("backdropColorG", 0.08), getDB("backdropColorB", 0.12) end, set = function(r, g, b) setDB("backdropColorR", r); setDB("backdropColorG", g); setDB("backdropColorB", b) end },
            { type = "toggle", name = L["FOCUS_BORDER"], desc = L["FOCUS_BORDER_AROUND_TRACKER"], dbKey = "showBorder", get = function() return getDB("showBorder", false) end, set = function(v) setDB("showBorder", v) end },
            { type = "toggle", name = L["SCROLL_INDICATOR"], desc = L["HINT_LIST_SCROLLABLE"], dbKey = "showScrollIndicator", get = function() return getDB("showScrollIndicator", false) end, set = function(v) setDB("showScrollIndicator", v) end, refreshIds = { "scrollIndicatorStyle" } },
            { type = "dropdown", name = L["FOCUS_SCROLL_INDICATOR_STYLE"], desc = L["FOCUS_CHOOSE_BETWEEN_A_FADE_GRADIENT_A"], dbKey = "scrollIndicatorStyle", options = { { L["FOCUS_FADE"], "fade" }, { L["FOCUS_ARROW"], "arrow" } }, get = function() return getDB("scrollIndicatorStyle", "fade") end, set = function(v) setDB("scrollIndicatorStyle", v) end, visibleWhen = function() return getDB("showScrollIndicator", false) end },
            { type = "section", name = L["VISIBILITY_FADING"] },
            { type = "dropdown", name = L["FOCUS_COMBAT_VISIBILITY"], desc = L["FOCUS_TRACKER_BEHAVES_COMBAT_FADE_REDUC"], dbKey = "combatVisibility", options = { { L["FOCUS_SHOW"], "show" }, { L["FOCUS_FADE"], "fade" }, { L["FOCUS_HIDE"], "hide" } }, get = function() return addon.GetCombatVisibility() end, set = function(v) setDB("combatVisibility", v); if addon.FullLayout then addon.FullLayout() end end, refreshIds = { "combatFadeOpacity" } },
            { type = "slider", name = L["FOCUS_COMBAT_FADE_OPACITY"], desc = L["FOCUS_VISIBLE_TRACKER_FADED_COMBAT"], dbKey = "combatFadeOpacity", min = 0, max = 100, get = function() return math.max(0, math.min(100, tonumber(getDB("combatFadeOpacity", 30)) or 30)) end, set = function(v) setDB("combatFadeOpacity", math.max(0, math.min(100, v))); if addon.FullLayout then addon.FullLayout() end end, visibleWhen = function() return addon.GetCombatVisibility() == "fade" end },
            { type = "toggle", name = L["MOUSEOVER"], desc = L["FADE_HOVERING"], dbKey = "showOnMouseoverOnly", get = function() return getDB("showOnMouseoverOnly", false) end, set = function(v) setDB("showOnMouseoverOnly", v); if addon.FullLayout then addon.FullLayout() end end, refreshIds = { "fadeOnMouseoverOpacity" } },
            { type = "slider", name = L["FOCUS_FADED_OPACITY"], desc = L["FOCUS_VISIBLE_TRACKER_FADED_INVISIBLE"], dbKey = "fadeOnMouseoverOpacity", min = 0, max = 100, get = function() return math.max(0, math.min(100, tonumber(getDB("fadeOnMouseoverOpacity", 10)) or 10)) end, set = function(v) setDB("fadeOnMouseoverOpacity", math.max(0, math.min(100, v))); if addon.FullLayout then addon.FullLayout() end end, visibleWhen = function() return getDB("showOnMouseoverOnly", false) end },
            { type = "section", name = L["FOCUS_HEADER"] },
            { type = "toggle", name = L["MINIMAL_MODE"], desc = L["FOCUS_HIDE_HEADER_A_PURE_TEXT_LIST"], dbKey = "hideObjectivesHeader", get = function() return getDB("hideObjectivesHeader", false) end, set = function(v) setDB("hideObjectivesHeader", v) end, refreshIds = { "showQuestCount", "headerCountMode", "showHeaderDivider", "headerDividerColor", "headerColor", "headerHeight", "hideOptionsButton" } },
            { type = "toggle", name = L["QUEST_COUNT"], desc = L["FOCUS_QUEST_COUNT_HEADER"], dbKey = "showQuestCount", get = function() return getDB("showQuestCount", true) end, set = function(v) setDB("showQuestCount", v) end, refreshIds = { "headerCountMode" }, visibleWhen = function() return not getDB("hideObjectivesHeader", false) end },
            { type = "dropdown", name = L["FOCUS_HEADER_COUNT_FORMAT"], desc = L["TRACKED_VS_LOG_COUNT"], dbKey = "headerCountMode", options = { { L["FOCUS_TRACKED_LOG"], "trackedLog" }, { L["FOCUS_LOG_MAX_SLOTS"], "logMax" } }, get = function() return getDB("headerCountMode", "trackedLog") end, set = function(v) setDB("headerCountMode", v) end, tooltip = L["TRACKED_LOG_LOG_MAX_TRACKED_EXCLUDES"], visibleWhen = function() return not getDB("hideObjectivesHeader", false) and getDB("showQuestCount", true) end },
            { type = "toggle", name = L["HEADER_DIVIDER"], desc = L["FOCUS_LINE_BELOW_HEADER"], dbKey = "showHeaderDivider", get = function() return getDB("showHeaderDivider", true) end, set = function(v) setDB("showHeaderDivider", v) end, refreshIds = { "headerDividerColor" }, visibleWhen = function() return not getDB("hideObjectivesHeader", false) end },
            { type = "color", name = L["FOCUS_HEADER_DIVIDER_COLOUR"], desc = L["FOCUS_COLOUR_OF_LINE_BELOW_HEADER"], dbKey = "headerDividerColor", default = addon.DIVIDER_COLOR, hasAlpha = true, visibleWhen = function() return not getDB("hideObjectivesHeader", false) and getDB("showHeaderDivider", true) end },
            { type = "color", name = L["FOCUS_HEADER_COLOUR"], desc = L["FOCUS_COLOUR_OF_OBJECTIVES_HEADER_TEXT"], dbKey = "headerColor", default = addon.HEADER_COLOR, visibleWhen = function() return not getDB("hideObjectivesHeader", false) end },
            { type = "slider", name = L["FOCUS_HEADER_HEIGHT"], desc = L["FOCUS_HEIGHT_OF_HEADER_BAR_PIXELS"], dbKey = "headerHeight", min = 18, max = 48, get = function() return math.max(18, math.min(48, tonumber(getDB("headerHeight", addon.HEADER_HEIGHT)) or addon.HEADER_HEIGHT)) end, set = function(v) setDB("headerHeight", math.max(18, math.min(48, v))) end, visibleWhen = function() return not getDB("hideObjectivesHeader", false) end },
            { type = "toggle", name = L["FOCUS_OPTIONS_BUTTON"], desc = L["FOCUS_OPTIONS_BUTTON_TRACKER_HEADER"], dbKey = "hideOptionsButton", get = function() return not getDB("hideOptionsButton", false) end, set = function(v) setDB("hideOptionsButton", not v) end, visibleWhen = function() return not getDB("hideObjectivesHeader", false) end },
            { type = "section", name = L["FOCUS_SECTIONS_STRUCTURE"] },
            { type = "toggle", name = L["SECTION_HEADERS"], desc = L["FOCUS_CATEGORY_LABELS_ABOVE_GROUP"], dbKey = "showSectionHeaders", get = function() return getDB("showSectionHeaders", true) end, set = function(v) setDB("showSectionHeaders", v) end },
            { type = "toggle", name = L["SECTION_DIVIDERS"], desc = L["A_VISUAL_DIVIDER_LINE_BETWEEN_FOCUS"], dbKey = "showSectionDividers", get = function() return getDB("showSectionDividers", false) end, set = function(v) setDB("showSectionDividers", v) end, refreshIds = { "sectionDividerColor" } },
            { type = "color", name = L["SECTION_DIVIDER_COLOUR"], desc = L["COLOUR_OF_DIVIDER_LINES_BETWEEN_SECTIONS"], dbKey = "sectionDividerColor", default = { 0.3, 0.3, 0.35, 0.4 }, hasAlpha = true, visibleWhen = function() return getDB("showSectionDividers", false) end },
            { type = "toggle", name = L["SECTIONS_COLLAPSED"], desc = L["KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED"], dbKey = "showSectionHeadersWhenCollapsed", get = function() return getDB("showSectionHeadersWhenCollapsed", false) end, set = function(v) setDB("showSectionHeadersWhenCollapsed", v) end, tooltip = L["FOCUS_CLICK_A_SECTION_HEADER_EXPAND_CATEGORY"] },
            { type = "toggle", name = L["ZONE_LABELS"], desc = L["FOCUS_ZONE_NAME_UNDER_QUEST_TITLE"], dbKey = "showZoneLabels", get = function() return getDB("showZoneLabels", true) end, set = function(v) setDB("showZoneLabels", v) end },
            { type = "section", name = L["FOCUS_ENTRY_DETAILS"] },
            { type = "toggle", name = L["ENTRY_NUMBERS"], desc = L["FOCUS_PREFIX_QUEST_TITLES_WITHIN_CATEGORY"], dbKey = "showCategoryEntryNumbers", get = function() return getDB("showCategoryEntryNumbers", true) end, set = function(v) setDB("showCategoryEntryNumbers", v) end },
            { type = "dropdown", name = L["FOCUS_OBJECTIVE_PREFIX"], desc = L["FOCUS_PREFIX_OBJECTIVE_A_NUMBER_HYPHEN"], dbKey = "objectivePrefixStyle", options = { { L["FOCUS_OUTLINE_NONE"], "none" }, { L["FOCUS_NUMBERS"], "numbers" }, { L["FOCUS_HYPHENS"], "hyphens" } }, get = function() return getDB("objectivePrefixStyle", "none") end, set = function(v) setDB("objectivePrefixStyle", v) end },
            { type = "toggle", name = L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS"], desc = L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS_DESC"], dbKey = "objectiveProgressNumberColors", get = function() return getDB("objectiveProgressNumberColors", true) end, set = function(v) setDB("objectiveProgressNumberColors", v) end },
            { type = "toggle", name = L["COMPLETED_COUNT"], desc = L["FOCUS_X_Y_PROGRESS_QUEST_TITLE"], dbKey = "showCompletedCount", get = function() return getDB("showCompletedCount", false) end, set = function(v) setDB("showCompletedCount", v) end },
            { type = "dropdown", name = L["FOCUS_COMPLETED_OBJECTIVES"], desc = L["DISPLAY_COMPLETED_OBJECTIVES"], tooltip = L["FOCUS_MULTI_OBJECTIVE_QUESTS_DISPLAY_OBJECTIVES"], dbKey = "questCompletedObjectiveDisplay", options = { { L["FOCUS_ALL"], "off" }, { L["FOCUS_FADE_COMPLETED"], "fade" }, { L["FOCUS_HIDE_COMPLETED"], "hide" } }, get = function() return getDB("questCompletedObjectiveDisplay", "off") end, set = function(v) setDB("questCompletedObjectiveDisplay", v) end },
            { type = "toggle", name = L["FOCUS_CHECKMARK_COMPLETED"], desc = L["CHECKMARK_COMPLETED_OBJECTIVES"], tooltip = L["FOCUS_COMPLETED_CHECKMARK"], dbKey = "useTickForCompletedObjectives", get = function() return getDB("useTickForCompletedObjectives", false) end, set = function(v) setDB("useTickForCompletedObjectives", v) end },
            { type = "toggle", name = L["QUEST_LEVEL"], desc = L["FOCUS_QUEST_LEVEL_NEXT_TITLE"], dbKey = "showQuestLevel", get = function() return getDB("showQuestLevel", false) end, set = function(v) setDB("showQuestLevel", v) end },
            { type = "toggle", name = L["QUEST_TYPE_ICONS"], desc = L["PRESENCE_QUEST_TYPE_ICON_FOCUS_TRACKER_QUEST"], dbKey = "showQuestTypeIcons", get = function() return getDB("showQuestTypeIcons", true) end, set = function(v) setDB("showQuestTypeIcons", v) end },
            { type = "slider", name = L["FOCUS_QUEST_TYPE_ICON_SIZE"], desc = L["FOCUS_QUEST_TYPE_ICON_SIZE_DESC"], dbKey = "focusIconSize", min = 10, max = 28, get = function() return getDB("focusIconSize", 16) end, set = function(v) setDB("focusIconSize", math.max(10, math.min(28, v))) end, visibleWhen = function() return getDB("showQuestTypeIcons", true) end },
            { type = "toggle", name = L["FOCUS_AUTO_TRACK_ICON"], desc = L["ICON_NEXT_AUTO_TRACKED_ZONE_ENTRIES"], dbKey = "showInZoneSuffix", get = function() return getDB("showInZoneSuffix", true) end, set = function(v) setDB("showInZoneSuffix", v) end, tooltip = L["WORLD_QUESTS_WEEKLIES_YOUR_QUEST_LOG"], refreshIds = { "autoTrackIcon" } },
            { type = "dropdown", name = L["FOCUS_AUTO_TRACK_ICON"], desc = L["FOCUS_CHOOSE_WHICH_ICON_DISPLAY_NEXT_AUTO"], dbKey = "autoTrackIcon", options = addon.GetRadarIconOptions and addon.GetRadarIconOptions() or {}, get = function() return getDB("autoTrackIcon", "radar1") end, set = function(v) setDB("autoTrackIcon", v) end, visibleWhen = function() return getDB("showInZoneSuffix", true) end },
            { type = "dropdown", name = L["FOCUS_ACTIVE_QUEST_HIGHLIGHT"], desc = L["FOCUS_FOCUSED_QUEST_HIGHLIGHTED"], dbKey = "activeQuestHighlight", options = HIGHLIGHT_OPTIONS, get = getActiveQuestHighlight, set = function(v) setDB("activeQuestHighlight", v) end },
            { type = "toggle", name = L["QUEST_ITEM_BUTTONS"], desc = L["FOCUS_USABLE_QUEST_ITEM_BUTTON_NEXT_QUEST"], dbKey = "showQuestItemButtons", get = function() return getDB("showQuestItemButtons", false) end, set = function(v) setDB("showQuestItemButtons", v) end },
            { type = "toggle", name = L["FOCUS_TOOLTIPS_HOVER"], desc = L["FOCUS_TOOLTIPS_HOVERING_TRACKER_ENTRIES_ITE"], dbKey = "focusShowTooltipOnHover", get = function() return getDB("focusShowTooltipOnHover", false) end, set = function(v) setDB("focusShowTooltipOnHover", v) end },
            { type = "toggle", name = L["FOCUS_WOWHEAD_LINK_TOOLTIPS"], desc = L["FOCUS_A_TOOLTIP_SHOWN_ADD_A_LINK"], dbKey = "focusShowWoWheadLink", get = function() return getDB("focusShowWoWheadLink", true) end, set = function(v) setDB("focusShowWoWheadLink", v) end },
            { type = "section", name = L["FOCUS_PROGRESS_TIMERS"] },
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
            { type = "toggle", name = L["FOCUS_TIMER"], desc = L["FOCUS_COUNTDOWN_TIMER_TIMED_QUESTS_EVENTS_SCEN"], dbKey = "showTimerBars", get = function() return getDB("showTimerBars", true) end, set = function(v) setDB("showTimerBars", v) end, refreshIds = { "showTimerScenario", "showTimerWorld", "showTimerQuestTimed", "timerDisplayMode", "timerColorByRemaining" } },
            { type = "toggle", name = L["FOCUS_TIMER_SCENARIOS"], desc = L["FOCUS_TIMER_SCENARIOS_DESC"], dbKey = "showTimerScenario", id = "showTimerScenario", get = function() return getDB("showTimerScenario", true) end, set = function(v) setDB("showTimerScenario", v) end, visibleWhen = function() return getDB("showTimerBars", false) end },
            { type = "toggle", name = L["FOCUS_TIMER_WORLD"], desc = L["FOCUS_TIMER_WORLD_DESC"], dbKey = "showTimerWorld", id = "showTimerWorld", get = function() return getDB("showTimerWorld", true) end, set = function(v) setDB("showTimerWorld", v) end, visibleWhen = function() return getDB("showTimerBars", false) end },
            { type = "toggle", name = L["FOCUS_TIMER_QUEST_LOG"], desc = L["FOCUS_TIMER_QUEST_LOG_DESC"], dbKey = "showTimerQuestTimed", id = "showTimerQuestTimed", get = function() return getDB("showTimerQuestTimed", true) end, set = function(v) setDB("showTimerQuestTimed", v) end, visibleWhen = function() return getDB("showTimerBars", false) end },
            { type = "dropdown", name = L["FOCUS_TIMER_DISPLAY"], desc = L["WHERE_COUNTDOWN"], dbKey = "timerDisplayMode", options = { { L["FOCUS_BAR_BELOW"], "bar" }, { L["FOCUS_INLINE_BESIDE_TITLE"], "inline" }, { L["FOCUS_INLINE_BELOW_TITLE"], "inline-below" } }, get = function() return getDB("timerDisplayMode", "inline") end, set = function(v) setDB("timerDisplayMode", v) end, visibleWhen = function() return getDB("showTimerBars", false) end },
            { type = "toggle", name = L["FOCUS_COLOUR_TIMER_REMAINING"], desc = L["COLOUR_REMAINING"], tooltip = L["FOCUS_GREEN_PLENTY_OF_LEFT_YELLOW_RUNNING"], dbKey = "timerColorByRemaining", get = function() return getDB("timerColorByRemaining", true) end, set = function(v) setDB("timerColorByRemaining", v) end, visibleWhen = function() return getDB("showTimerBars", false) end },
            { type = "section", name = L["FOCUS_EMPHASIS"] },
            { type = "toggle", name = L["FOCUS_DIM_UNFOCUSED_ENTRIES"], desc = L["DIM_UNFOCUSED_TRACKER_ENTRIES"], tooltip = L["FOCUS_SLIGHTLY_DIM_TITLE_ZONE_OBJECTIVES_SECTION"], dbKey = "dimNonSuperTracked", get = function() return getDB("dimNonSuperTracked", false) end, set = function(v) setDB("dimNonSuperTracked", v) end, refreshIds = { "dimStrength", "dimAlpha", "dimDesaturate" } },
            { type = "slider", name = L["DIM_STRENGTH"], desc = L["DIMMING_STRENGTH"], tooltip = L["FOCUS_DIM_UNFOCUSED_ENTRIES_DESC"], dbKey = "dimStrength", min = 0, max = 100, get = function() return math.max(0, math.min(100, tonumber(getDB("dimStrength", 40)) or 40)) end, set = function(v) setDB("dimStrength", math.max(0, math.min(100, v))) end, visibleWhen = function() return getDB("dimNonSuperTracked", false) end },
            { type = "slider", name = L["DIM_ALPHA"], desc = L["OPACITY_OF_UNFOCUSED_ENTRIES"], tooltip = L["REDUCE_OPACITY_OF_FOCUSED_ENTRIES_INVISIBLE"], dbKey = "dimAlpha", min = 0, max = 100, get = function() return math.max(0, math.min(100, tonumber(getDB("dimAlpha", 100)) or 100)) end, set = function(v) setDB("dimAlpha", math.max(0, math.min(100, v))) end, visibleWhen = function() return getDB("dimNonSuperTracked", false) end },
            { type = "toggle", name = L["DESATURATE_FOCUSED_QUESTS"], desc = L["DESATURATE_FOCUSED_ENTRIES"], tooltip = L["MAKE_FOCUSED_ENTRIES_GREYSCALE_PARTIALLY_DESATURATE"], dbKey = "dimDesaturate", get = function() return getDB("dimDesaturate", false) end, set = function(v) setDB("dimDesaturate", v) end, visibleWhen = function() return getDB("dimNonSuperTracked", false) end },
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
            { type = "section", name = L["DASH_CLICK_OPTIONS"] },
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
            { type = "section", name = L["FOCUS_CLICK_SAFETY"] },
            { type = "toggle", name = L["FOCUS_CTRL_FOCUS_UNTRACK"], desc = L["PREVENT_ACCIDENTAL_CLICKS"], dbKey = "requireCtrlForQuestClicks", get = function() return getDB("requireCtrlForQuestClicks", false) end, set = function(v) setDB("requireCtrlForQuestClicks", v) end, tooltip = L["CTRL_LEFT_FOCUS_ADD_CTRL_RIGHT"] },
            { type = "toggle", name = L["FOCUS_CTRL_CLICK_COMPLETE"], desc = L["REQUIRE_CTRL_COMPLETE_CLICK_COMPLETABLE_QUESTS"], dbKey = "requireModifierForClickToComplete", get = function() return getDB("requireModifierForClickToComplete", false) end, set = function(v) setDB("requireModifierForClickToComplete", v) end, tooltip = L["QUESTS_DON_T_NEED_NPC_TURN"] },
        },
    },
    {
        key = "SortingFiltering",
        name = L["SORTING_FILTERING"],
        desc = L["ORGANIZE_HIDE_TRACKED_ENTRIES_YOUR_PREFERENCE"] or "Organize and hide tracked entries to your preference.",
        moduleKey = "focus",
        options = {
            { type = "section", name = L["FOCUS_FILTERING"] },
            { type = "toggle", name = L["CURRENT_ZONE"], desc = L["FOCUS_HIDE_QUESTS_OUTSIDE_YOUR_CURRENT_ZONE"], dbKey = "filterByZone", get = function() return getDB("filterByZone", false) end, set = function(v) setDB("filterByZone", v) end },
            { type = "section", name = L["GROUPING"] },
            { type = "toggle", name = L["FOCUS_CURRENT_QUEST_CATEGORY"], desc = L["RECENT_PROGRESS_TOP"], tooltip = L["FOCUS_QUEST_PROGRESSION_SECTION"], dbKey = "showCurrentQuestCategory", get = function() return getDB("showCurrentQuestCategory", true) end, set = function(v) setDB("showCurrentQuestCategory", v) end, refreshIds = { "currentQuestWindowSec" } },
            { type = "slider", name = L["FOCUS_CURRENT_QUEST_WINDOW"], desc = L["SECONDS_OF_RECENT_PROGRESS"], dbKey = "currentQuestWindowSec", min = 30, max = 120, get = function() return math.max(30, math.min(120, tonumber(getDB("currentQuestWindowSec", 60)) or 60)) end, set = function(v) setDB("currentQuestWindowSec", math.max(30, math.min(120, v))) end, visibleWhen = function() return getDB("showCurrentQuestCategory", true) end, id = "currentQuestWindowSec" },
            { type = "toggle", name = L["CURRENT_ZONE_GROUP"], desc = L["DEDICATED_SECTION_ZONE_QUESTS"], dbKey = "showNearbyGroup", get = function() return getDB("showNearbyGroup", true) end, set = function(v) setDB("showNearbyGroup", v) end, tooltip = L["ZONE_QUESTS_APPEAR_THEIR_NORMAL_CATEGORY"], refreshIds = { "nearbyCompleteToBottom" } },
            { type = "toggle", name = L["FOCUS_SHOW_ZONE_EVENTS"], desc = L["FOCUS_SHOW_ZONE_EVENTS_DESC"], dbKey = "showEventsInZone", id = "showEventsInZone", get = function() return getDB("showEventsInZone", true) end, set = function(v) setDB("showEventsInZone", v) end, tooltip = L["FOCUS_SHOW_ZONE_EVENTS_TIP"] },
            { type = "toggle", name = L["READY_TURN_BOTTOM"], desc = L["MOVE_COMPLETED_QUESTS_BOTTOM_OF_CURRENT"], dbKey = "nearbyCompleteToBottom", get = function() return getDB("nearbyCompleteToBottom", true) end, set = function(v) setDB("nearbyCompleteToBottom", v); OptionsData_NotifyMainAddon() end, visibleWhen = function() return getDB("showNearbyGroup", true) end },
            { type = "toggle", name = L["READY_TURN_GROUP"], desc = L["DEDICATED_SECTION_COMPLETED_QUESTS"], dbKey = "showCompleteGroup", get = function() return getDB("showCompleteGroup", true) end, set = function(v) setDB("showCompleteGroup", v); if addon.RequestRefresh then addon.RequestRefresh() end; if addon.FullLayout then addon.FullLayout() end end, tooltip = L["COMPLETED_QUESTS_STAY_THEIR_ORIGINAL_CATEGO"], refreshIds = { "keepCampaignInCategory", "keepImportantInCategory" } },
            { type = "toggle", name = L["KEEP_CAMPAIGN_CATEGORY"], desc = L["KEEP_CAMPAIGN_READY_TURN"], dbKey = "keepCampaignInCategory", get = function() return getDB("keepCampaignInCategory", false) end, set = function(v) setDB("keepCampaignInCategory", v); if addon.RequestRefresh then addon.RequestRefresh() end; if addon.FullLayout then addon.FullLayout() end end, tooltip = L["THEY_MOVE_COMPLETE_SECTION"], visibleWhen = function() return getDB("showCompleteGroup", true) end, id = "keepCampaignInCategory" },
            { type = "toggle", name = L["KEEP_IMPORTANT_CATEGORY"], desc = L["KEEP_IMPORTANT_READY_TURN"], dbKey = "keepImportantInCategory", get = function() return getDB("keepImportantInCategory", false) end, set = function(v) setDB("keepImportantInCategory", v); if addon.RequestRefresh then addon.RequestRefresh() end; if addon.FullLayout then addon.FullLayout() end end, tooltip = L["THEY_MOVE_COMPLETE_SECTION"], visibleWhen = function() return getDB("showCompleteGroup", true) end, id = "keepImportantInCategory" },
            { type = "section", name = L["FOCUS_SORTING"] },
            { type = "reorderList", name = L["FOCUS_CATEGORY_ORDER"], labelMap = addon.SECTION_LABELS, presets = addon.GROUP_ORDER_PRESETS, get = function() return addon.GetGroupOrder() end, set = function(order) addon.SetGroupOrder(order) end, desc = L["FOCUS_CATEGORIES_REORDER_EXCEPT_DELVES_SCENARIOS_TIP"] },
            { type = "dropdown", name = L["SORT_MODE"], desc = L["FOCUS_ENTRY_NUMBER_IN_CATEGORY"], dbKey = "entrySortMode", options = { { L["FOCUS_ALPHABETICAL"], "alpha" }, { L["FOCUS_QUEST_TYPE"], "questType" }, { L["FOCUS_ZONE"], "zone" }, { L["FOCUS_QUEST_LEVEL"], "level" } }, get = function() return getDB("entrySortMode", "questType") end, set = function(v) setDB("entrySortMode", v) end },
        },
    },
    {
        key = "Typography",
        name = L["DASH_TYPOGRAPHY"],
        desc = L["ADJUST_FONTS_SIZES_CASING_DROP_SHADOWS"] or "Adjust fonts, sizes, casing, and drop shadows.",
        moduleKey = "focus",
        options = {
            { type = "section", name = L["FOCUS_FONT_FAMILIES"] },
            { type = "dropdown", name = L["FOCUS_FONT"], desc = L["FOCUS_FONT_FAMILY"], dbKey = "fontPath", searchable = true, options = GetFontDropdownOptions, get = function() return getDB("fontPath", defaultFontPath) end, set = function(v) setDB("fontPath", v) end, displayFn = addon.GetFontNameForPath, fontPreviewInList = true },
            { type = "toggle", name = L["FOCUS_PER_ELEMENT_FONTS"], desc = L["OVERRIDE_FONT_PER_ELEMENT"], dbKey = "usePerElementFonts", get = function() return getDB("usePerElementFonts", false) end, set = function(v) setDB("usePerElementFonts", v) end, refreshIds = { "titleFontPath", "zoneFontPath", "objectiveFontPath", "sectionFontPath", "progressBarFontPath", "timerFontPath", "optionsFontPath" } },
            { type = "dropdown", name = L["FOCUS_TITLE_FONT"], desc = L["FOCUS_FONT_FAMILY_QUEST_TITLES"], dbKey = "titleFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("titleFontPath") end, get = function() return getDB("titleFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("titleFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", false) end, id = "titleFontPath", fontPreviewInList = true },
            { type = "dropdown", name = L["VISTA_ZONE_FONT"], desc = L["FOCUS_FONT_FAMILY_ZONE_LABELS"], dbKey = "zoneFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("zoneFontPath") end, get = function() return getDB("zoneFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("zoneFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", false) end, id = "zoneFontPath", fontPreviewInList = true },
            { type = "dropdown", name = L["FOCUS_OBJECTIVE_FONT"], desc = L["FOCUS_FONT_FAMILY_OBJECTIVE_TEXT"], dbKey = "objectiveFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("objectiveFontPath") end, get = function() return getDB("objectiveFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("objectiveFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", false) end, id = "objectiveFontPath", fontPreviewInList = true },
            { type = "dropdown", name = L["FOCUS_SECTION_FONT"], desc = L["FOCUS_FONT_FAMILY_SECTION_HEADERS"], dbKey = "sectionFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("sectionFontPath") end, get = function() return getDB("sectionFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("sectionFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", false) end, id = "sectionFontPath", fontPreviewInList = true },
            { type = "dropdown", name = L["FOCUS_PROGRESS_BAR_FONT"], desc = L["FOCUS_FONT_FAMILY_PROGRESS_BAR_LABEL"], dbKey = "progressBarFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("progressBarFontPath") end, get = function() return getDB("progressBarFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("progressBarFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", false) end, id = "progressBarFontPath", fontPreviewInList = true },
            { type = "dropdown", name = L["FOCUS_TIMER_TEXT_FONT"], desc = L["FOCUS_FONT_FAMILY_TIMER_TEXT"], dbKey = "timerFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("timerFontPath") end, get = function() return getDB("timerFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("timerFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", false) end, id = "timerFontPath", fontPreviewInList = true },
            { type = "dropdown", name = L["FOCUS_OPTIONS_FONT"], desc = L["FOCUS_FONT_FAMILY_OPTIONS"], dbKey = "optionsFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("optionsFontPath") end, get = function() return getDB("optionsFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("optionsFontPath", v) end, displayFn = DisplayPerElementFont, visibleWhen = function() return getDB("usePerElementFonts", false) end, id = "optionsFontPath", fontPreviewInList = true },
            { type = "section", name = L["FOCUS_FONT_SIZES"] },
            { type = "slider", name = L["FOCUS_GLOBAL_FONT_SIZE"], desc = L["ADJUST_FONT_SIZES_AMOUNT"], dbKey = "globalFontSizeOffset", min = -4, max = 4, get = function() return getDB("globalFontSizeOffset", 0) end, set = function(v) setDB("globalFontSizeOffset", v) end },
            { type = "slider", name = L["FOCUS_HEADER_SIZE"], desc = L["FOCUS_HEADER_FONT_SIZE"], dbKey = "headerFontSize", min = 8, max = 32, get = function() return getDB("headerFontSize", 16) end, set = function(v) setDB("headerFontSize", v) end },
            { type = "slider", name = L["FOCUS_TITLE_SIZE"], desc = L["FOCUS_QUEST_TITLE_FONT_SIZE"], dbKey = "titleFontSize", min = 8, max = 24, get = function() return getDB("titleFontSize", 13) end, set = function(v) setDB("titleFontSize", v) end },
            { type = "slider", name = L["FOCUS_OBJECTIVE_SIZE"], desc = L["FOCUS_OBJECTIVE_TEXT_FONT_SIZE"], dbKey = "objectiveFontSize", min = 8, max = 20, get = function() return getDB("objectiveFontSize", 11) end, set = function(v) setDB("objectiveFontSize", v) end },
            { type = "slider", name = L["FOCUS_ZONE_SIZE"], desc = L["FOCUS_ZONE_LABEL_FONT_SIZE"], dbKey = "zoneFontSize", min = 8, max = 18, get = function() return getDB("zoneFontSize", 10) end, set = function(v) setDB("zoneFontSize", v) end },
            { type = "slider", name = L["FOCUS_SECTION_SIZE"], desc = L["FOCUS_SECTION_HEADER_FONT_SIZE"], dbKey = "sectionFontSize", min = 8, max = 18, get = function() return getDB("sectionFontSize", 10) end, set = function(v) setDB("sectionFontSize", v) end },
            { type = "slider", name = L["FOCUS_PROGRESS_BAR_TEXT_SIZE"], desc = L["FONT_SIZE_BAR_LABEL_BAR_HEIGHT"], dbKey = "progressBarFontSize", min = 7, max = 18, get = function() return getDB("progressBarFontSize", 10) end, set = function(v) setDB("progressBarFontSize", v) end, tooltip = L["AFFECTS_SCENARIO_PROGRESS_TIMER_BARS"] },
            { type = "slider", name = L["FOCUS_TIMER_TEXT_SIZE"], desc = L["FOCUS_TIMER_TEXT_FONT_SIZE"], dbKey = "timerFontSize", min = 8, max = 24, get = function() return getDB("timerFontSize", 13) end, set = function(v) setDB("timerFontSize", v) end },
            { type = "slider", name = L["FOCUS_OPTIONS_TEXT_SIZE"], desc = L["FOCUS_OPTIONS_TEXT_FONT_SIZE"], dbKey = "optionsFontSize", min = 8, max = 20, get = function() return getDB("optionsFontSize", 11) end, set = function(v) setDB("optionsFontSize", v) end },
            { type = "dropdown", name = L["FOCUS_OUTLINE"], desc = L["FOCUS_FONT_OUTLINE_STYLE"], dbKey = "fontOutline", options = OUTLINE_OPTIONS, get = function() return getDB("fontOutline", "OUTLINE") end, set = function(v) setDB("fontOutline", v) end },
            { type = "section", name = L["FOCUS_TEXT_CASE"] },
            { type = "dropdown", name = L["FOCUS_HEADER_TEXT_CASE"], desc = L["FOCUS_DISPLAY_CASE_HEADER"], dbKey = "headerTextCase", options = TEXT_CASE_OPTIONS, get = function() local v = getDB("headerTextCase", "upper"); return (v == "default") and "upper" or v end, set = function(v) setDB("headerTextCase", v) end },
            { type = "dropdown", name = L["FOCUS_SECTION_HEADER_CASE"], desc = L["FOCUS_DISPLAY_CASE_CATEGORY_LABELS"], dbKey = "sectionHeaderTextCase", options = TEXT_CASE_OPTIONS, get = function() local v = getDB("sectionHeaderTextCase", "proper"); return (v == "default") and "proper" or v end, set = function(v) setDB("sectionHeaderTextCase", v) end },
            { type = "dropdown", name = L["FOCUS_QUEST_TITLE_CASE"], desc = L["FOCUS_DISPLAY_CASE_QUEST_TITLES"], dbKey = "questTitleCase", options = TEXT_CASE_OPTIONS, get = function() local v = getDB("questTitleCase", "proper"); return (v == "default") and "proper" or v end, set = function(v) setDB("questTitleCase", v) end },
            { type = "section", name = L["FOCUS_SHADOW"] },
            { type = "toggle", name = L["FOCUS_TEXT_SHADOW"], desc = L["FOCUS_ENABLE_DROP_SHADOW_TEXT"], dbKey = "showTextShadow", get = function() return getDB("showTextShadow", true) end, set = function(v) setDB("showTextShadow", v) end, refreshIds = { "shadowOffsetX", "shadowOffsetY", "shadowAlpha" } },
            { type = "slider", name = L["FOCUS_SHADOW_X"], desc = L["FOCUS_HORIZONTAL_SHADOW_OFFSET"], dbKey = "shadowOffsetX", min = -10, max = 10, get = function() return getDB("shadowOffsetX", 2) end, set = function(v) setDB("shadowOffsetX", v) end, visibleWhen = function() return getDB("showTextShadow", true) end, id = "shadowOffsetX" },
            { type = "slider", name = L["FOCUS_SHADOW_Y"], desc = L["FOCUS_VERTICAL_SHADOW_OFFSET"], dbKey = "shadowOffsetY", min = -10, max = 10, get = function() return getDB("shadowOffsetY", -2) end, set = function(v) setDB("shadowOffsetY", v) end, visibleWhen = function() return getDB("showTextShadow", true) end, id = "shadowOffsetY" },
            { type = "slider", name = L["FOCUS_SHADOW_ALPHA"], desc = L["SHADOW_OPACITY"], dbKey = "shadowAlpha", min = 0, max = 100, get = function() local v = tonumber(getDB("shadowAlpha", 0.8)) or 0.8; if v <= 1 and v > 0 then return math.floor(v * 100 + 0.5) end; return math.max(0, math.min(100, v)) end, set = function(v) setDB("shadowAlpha", math.max(0, math.min(100, v)) / 100) end, visibleWhen = function() return getDB("showTextShadow", true) end, id = "shadowAlpha" },
        },
    },
    {
        key = "Interactions",
        name = L["FOCUS_INTERACTIONS"],
        desc = L["FOCUS_INTERACTIONS_TAB_DESC"],
        moduleKey = "focus",
        options = {
            { type = "section", name = L["QUEST_TRACKING"] },
            { type = "toggle", name = L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS"], desc = L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS_TIP"], dbKey = "autoTrackOnAccept", get = function() return getDB("autoTrackOnAccept", true) end, set = function(v) setDB("autoTrackOnAccept", v) end },
            { type = "toggle", name = L["FOCUS_SUPPRESS_UNTRACKED_UNTIL_RELOAD"], desc = L["HIDE_UNTRACKED_QUESTS_UNTIL_RELOAD"], tooltip = L["FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS"], dbKey = "suppressUntrackedUntilReload", get = function() return getDB("suppressUntrackedUntilReload", false) end, set = function(v) setDB("suppressUntrackedUntilReload", v) end },
            { type = "toggle", name = L["FOCUS_BLACKLIST_UNTRACKED"], desc = L["PERMANENTLY_HIDE_UNTRACKED_QUESTS"], dbKey = "permanentlySuppressUntracked", get = function() return getDB("permanentlySuppressUntracked", false) end, set = function(v) setDB("permanentlySuppressUntracked", v) end, tooltip = L["TAKES_PRIORITY_SUPPRESS_UNTIL_RELOAD_ACCEPTING"] },
            { type = "section", name = L["NAME_TOMTOM"] },
            { type = "toggle", name = L["FOCUS_TOMTOM_QUEST_WAYPOINT"], desc = L["FOCUS_TOMTOM_QUEST_WAYPOINT_TIP"], dbKey = "tomtomQuestWaypoint", get = function() return getDB("tomtomQuestWaypoint", false) end, set = function(v) setDB("tomtomQuestWaypoint", v) end, tooltip = L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_NEXT_QUEST"] },
            { type = "toggle", name = L["FOCUS_TOMTOM_RARE_WAYPOINT"], desc = L["FOCUS_TOMTOM_WAYPOINT_RARE_CLICK"], dbKey = "tomtomRareWaypoint", get = function() return getDB("tomtomRareWaypoint", true) end, set = function(v) setDB("tomtomRareWaypoint", v) end, tooltip = L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_RARE"] },
        },
    },
    {
        key = "Animations",
        name = L["FOCUS_ANIMATIONS"],
        desc = L["TUNE_SLIDE_FADE_EFFECTS_PLUS_OBJECTIVE"] or "Tune slide and fade effects, plus objective progress flashes.",
        moduleKey = "focus",
        options = {
            { type = "section", name = L["FOCUS_ANIMATIONS"] },
            { type = "toggle", name = L["FOCUS_ANIMATIONS"], desc = L["FOCUS_SLIDE_FADE_QUESTS"], dbKey = "animations", get = function() return getDB("animations", true) end, set = function(v) setDB("animations", v) end },
            { type = "section", name = L["OBJECTIVE_PROGRESS"] },
            { type = "toggle", name = L["FOCUS_OBJECTIVE_PROGRESS_FLASH"], desc = L["FOCUS_FLASH_OBJECTIVE_COMPLETION"], dbKey = "objectiveProgressFlash", get = function() return getDB("objectiveProgressFlash", true) end, set = function(v) setDB("objectiveProgressFlash", v) end, refreshIds = { "objectiveProgressFlashIntensity", "objectiveProgressFlashColor" } },
            { type = "dropdown", name = L["FOCUS_FLASH_INTENSITY"], desc = L["FOCUS_OBJECTIVE_PROGRESS_FLASH_VISIBILITY"], dbKey = "objectiveProgressFlashIntensity", id = "objectiveProgressFlashIntensity", visibleWhen = function() return getDB("objectiveProgressFlash", true) end, options = { { L["FOCUS_SUBTLE"], "subtle" }, { L["FOCUS_MEDIUM"], "medium" }, { L["FOCUS_STRONG"], "strong" } }, get = function() return getDB("objectiveProgressFlashIntensity", "subtle") end, set = function(v) setDB("objectiveProgressFlashIntensity", v) end },
            { type = "color", name = L["FOCUS_FLASH_COLOUR"], desc = L["FOCUS_FLASH_COLOUR_DESC"], dbKey = "objectiveProgressFlashColor", id = "objectiveProgressFlashColor", visibleWhen = function() return getDB("objectiveProgressFlash", true) end, default = { 1, 1, 1 } },
        },
    },
    {
        key = "Instances",
        name = L["FOCUS_INSTANCES"],
        desc = L["CONTROL_TRACKER_VISIBILITY_WITHIN_DUNGEONS_RAIDS"] or "Control tracker visibility within dungeons, raids, and PvP.",
        moduleKey = "focus",
        options = {
            { type = "section", name = L["DASH_VISIBILITY"] },
            { type = "toggle", name = L["DUNGEON"], desc = L["TRACKER_PARTY_DUNGEONS"], dbKey = "showInDungeon", get = function() return getDB("showInDungeon", true) end, set = function(v) setDB("showInDungeon", v) end, refreshIds = { "showInDungeonNormal", "showInDungeonHeroic", "showInDungeonMythic", "showInDungeonMythicPlus" } },
            { type = "toggle", name = L["NORMAL_DUNGEON"], desc = L["NORMAL_DUNGEONS"], tooltip = L["TRACKER_NORMAL_DUNGEONS"], dbKey = "showInDungeonNormal", id = "showInDungeonNormal", visibleWhen = function() return getDB("showInDungeon", true) end, get = function() local v = getDB("showInDungeonNormal", nil); if v ~= nil then return v end; return getDB("showInDungeon", true) end, set = function(v) setDB("showInDungeonNormal", v) end },
            { type = "toggle", name = L["HEROIC_DUNGEON"], desc = L["TRACKER_HEROIC_DUNGEONS"], dbKey = "showInDungeonHeroic", id = "showInDungeonHeroic", visibleWhen = function() return getDB("showInDungeon", true) end, get = function() local v = getDB("showInDungeonHeroic", nil); if v ~= nil then return v end; return getDB("showInDungeon", true) end, set = function(v) setDB("showInDungeonHeroic", v) end },
            { type = "toggle", name = L["MYTHIC_DUNGEON"], desc = L["TRACKER_MYTHIC_DUNGEONS"], dbKey = "showInDungeonMythic", id = "showInDungeonMythic", visibleWhen = function() return getDB("showInDungeon", true) end, get = function() local v = getDB("showInDungeonMythic", nil); if v ~= nil then return v end; return getDB("showInDungeon", true) end, set = function(v) setDB("showInDungeonMythic", v) end },
            { type = "toggle", name = L["MYTHIC_PLUS_DUNGEON"], desc = L["TRACKER_MYTHIC_KEYSTONES"], dbKey = "showInDungeonMythicPlus", id = "showInDungeonMythicPlus", visibleWhen = function() return getDB("showInDungeon", true) end, get = function() local v = getDB("showInDungeonMythicPlus", nil); if v ~= nil then return v end; return getDB("showInDungeon", true) end, set = function(v) setDB("showInDungeonMythicPlus", v) end },
            { type = "toggle", name = L["RAID"], desc = L["TRACKER_RAIDS_ALL"], dbKey = "showInRaid", get = function() return getDB("showInRaid", false) end, set = function(v) setDB("showInRaid", v) end, refreshIds = { "showInRaidLFR", "showInRaidNormal", "showInRaidHeroic", "showInRaidMythic" } },
            { type = "toggle", name = L["LFR"], desc = L["TRACKER_LFR_RAID"], dbKey = "showInRaidLFR", id = "showInRaidLFR", visibleWhen = function() return getDB("showInRaid", false) end, get = function() local v = getDB("showInRaidLFR", nil); if v ~= nil then return v end; return getDB("showInRaid", false) end, set = function(v) setDB("showInRaidLFR", v) end },
            { type = "toggle", name = L["NORMAL_RAID"], desc = L["TRACKER_NORMAL_RAIDS"], dbKey = "showInRaidNormal", id = "showInRaidNormal", visibleWhen = function() return getDB("showInRaid", false) end, get = function() local v = getDB("showInRaidNormal", nil); if v ~= nil then return v end; return getDB("showInRaid", false) end, set = function(v) setDB("showInRaidNormal", v) end },
            { type = "toggle", name = L["HEROIC_RAID"], desc = L["TRACKER_HEROIC_RAIDS"], dbKey = "showInRaidHeroic", id = "showInRaidHeroic", visibleWhen = function() return getDB("showInRaid", false) end, get = function() local v = getDB("showInRaidHeroic", nil); if v ~= nil then return v end; return getDB("showInRaid", false) end, set = function(v) setDB("showInRaidHeroic", v) end },
            { type = "toggle", name = L["MYTHIC_RAID"], desc = L["TRACKER_MYTHIC_RAIDS"], dbKey = "showInRaidMythic", id = "showInRaidMythic", visibleWhen = function() return getDB("showInRaid", false) end, get = function() local v = getDB("showInRaidMythic", nil); if v ~= nil then return v end; return getDB("showInRaid", false) end, set = function(v) setDB("showInRaidMythic", v) end },
            { type = "toggle", name = L["BATTLEGROUND"], desc = L["FOCUS_TRACKER_BATTLEGROUNDS"], dbKey = "showInBattleground", get = function() return getDB("showInBattleground", false) end, set = function(v) setDB("showInBattleground", v) end },
            { type = "toggle", name = L["ARENA"], desc = L["FOCUS_TRACKER_ARENAS"], dbKey = "showInArena", get = function() return getDB("showInArena", false) end, set = function(v) setDB("showInArena", v) end },
            { type = "section", name = L["MYTHIC_BLOCK"] },
            { type = "toggle", name = L["ENABLE_M_BLOCK"], desc = L["FOCUS_TIMER_COMPLETION_AFFIXES_MYTHIC_DUNGEONS"], dbKey = "showMythicPlusBlock", get = function() return getDB("showMythicPlusBlock", true) end, set = function(v) setDB("showMythicPlusBlock", v) end, refreshIds = { "mplusAlwaysShow", "mplusShowAffixIcons", "mplusShowAffixDescriptions", "mplusBlockPosition", "mplusBossCompletedDisplay" } },
            { type = "toggle", name = L["ALWAYS"], desc = L["ALWAYS_M_TIMER"], tooltip = L["M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"], dbKey = "mplusAlwaysShow", id = "mplusAlwaysShow", visibleWhen = function() return getDB("showMythicPlusBlock", true) end, get = function() return getDB("mplusAlwaysShow", false) end, set = function(v) setDB("mplusAlwaysShow", v); if addon.FullLayout then addon.FullLayout() end end },
            { type = "toggle", name = L["AFFIX_ICONS"], desc = L["FOCUS_AFFIX_ICONS_NEXT_MODIFIER_NAMES_M"], dbKey = "mplusShowAffixIcons", id = "mplusShowAffixIcons", visibleWhen = function() return getDB("showMythicPlusBlock", true) end, get = function() return getDB("mplusShowAffixIcons", true) end, set = function(v) setDB("mplusShowAffixIcons", v) end },
            { type = "toggle", name = L["AFFIX_TOOLTIPS"], desc = L["FOCUS_AFFIX_DESCRIPTIONS_HOVERING_M_BLO"], dbKey = "mplusShowAffixDescriptions", id = "mplusShowAffixDescriptions", visibleWhen = function() return getDB("showMythicPlusBlock", true) end, get = function() return getDB("mplusShowAffixDescriptions", true) end, set = function(v) setDB("mplusShowAffixDescriptions", v) end },
            { type = "dropdown", name = L["BLOCK_POSITION"], desc = L["FOCUS_POSITION_OF_MYTHIC_BLOCK_RELATIVE_QUEST"], dbKey = "mplusBlockPosition", id = "mplusBlockPosition", visibleWhen = function() return getDB("showMythicPlusBlock", true) end, options = MPLUS_POSITION_OPTIONS, get = function() return getDB("mplusBlockPosition", "top") end, set = function(v) setDB("mplusBlockPosition", v) end },
            { type = "dropdown", name = L["COMPLETED_BOSS_STYLE"], desc = L["DEFEATED_BOSS_STYLE"], tooltip = L["FOCUS_DEFEATED_BOSSES_CHECKMARK_ICON_GREEN"], dbKey = "mplusBossCompletedDisplay", id = "mplusBossCompletedDisplay", visibleWhen = function() return getDB("showMythicPlusBlock", true) end, options = { { L["FOCUS_CHECKMARK"], "tick" }, { L["FOCUS_GREEN_COLOUR"], "green" } }, get = function() return getDB("mplusBossCompletedDisplay", "tick") end, set = function(v) setDB("mplusBossCompletedDisplay", v); if addon.UpdateMplusBlock then addon.UpdateMplusBlock() end end },
            { type = "section", name = L["FOCUS_MYTHIC_TYPOGRAPHY"], defaultCollapsed = true },
            { type = "slider", name = L["FOCUS_DUNGEON_NAME_SIZE"], desc = L["FOCUS_FONT_SIZE_DUNGEON_NAME_PX"], dbKey = "mplusDungeonSize", min = 8, max = 32, step = 1, get = function() return math.max(8, math.min(32, tonumber(getDB("mplusDungeonSize", 14)) or 14)) end, set = function(v) setDB("mplusDungeonSize", math.max(8, math.min(32, v))) end },
            { type = "slider", name = L["FOCUS_TIMER_SIZE"], desc = L["FOCUS_FONT_SIZE_TIMER_PX"], dbKey = "mplusTimerSize", min = 8, max = 32, step = 1, get = function() return math.max(8, math.min(32, tonumber(getDB("mplusTimerSize", 13)) or 13)) end, set = function(v) setDB("mplusTimerSize", math.max(8, math.min(32, v))) end },
            { type = "slider", name = L["ENEMY_FORCES_SIZE"], desc = L["FOCUS_FONT_SIZE_ENEMY_FORCES_PX"], dbKey = "mplusProgressSize", min = 8, max = 32, step = 1, get = function() return math.max(8, math.min(32, tonumber(getDB("mplusProgressSize", 12)) or 12)) end, set = function(v) setDB("mplusProgressSize", math.max(8, math.min(32, v))) end },
            { type = "slider", name = L["FOCUS_AFFIX_SIZE"], desc = L["FOCUS_FONT_SIZE_AFFIXES_PX"], dbKey = "mplusAffixSize", min = 8, max = 32, step = 1, get = function() return math.max(8, math.min(32, tonumber(getDB("mplusAffixSize", 12)) or 12)) end, set = function(v) setDB("mplusAffixSize", math.max(8, math.min(32, v))) end },
            { type = "slider", name = L["FOCUS_BOSS_SIZE"], desc = L["FOCUS_FONT_SIZE_BOSS_NAMES_PX"], dbKey = "mplusBossSize", min = 8, max = 32, step = 1, get = function() return math.max(8, math.min(32, tonumber(getDB("mplusBossSize", 12)) or 12)) end, set = function(v) setDB("mplusBossSize", math.max(8, math.min(32, v))) end },
            { type = "section", name = L["MYTHIC_COLOURS"], defaultCollapsed = true },
            { type = "color", name = L["FOCUS_DUNGEON_NAME_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_DUNGEON_NAME"], dbKey = "mplusDungeonColor", get = function() return getDB("mplusDungeonColorR", 0.96), getDB("mplusDungeonColorG", 0.96), getDB("mplusDungeonColorB", 1.0) end, set = function(r, g, b) setDB("mplusDungeonColorR", r); setDB("mplusDungeonColorG", g); setDB("mplusDungeonColorB", b) end },
            { type = "color", name = L["FOCUS_TIMER_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_TIMER"], dbKey = "mplusTimerColor", get = function() return getDB("mplusTimerColorR", 0.6), getDB("mplusTimerColorG", 0.88), getDB("mplusTimerColorB", 1.0) end, set = function(r, g, b) setDB("mplusTimerColorR", r); setDB("mplusTimerColorG", g); setDB("mplusTimerColorB", b) end },
            { type = "color", name = L["FOCUS_TIMER_OVERTIME_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_TIMER_LIMIT"], dbKey = "mplusTimerOvertimeColor", get = function() return getDB("mplusTimerOvertimeColorR", 0.9), getDB("mplusTimerOvertimeColorG", 0.25), getDB("mplusTimerOvertimeColorB", 0.2) end, set = function(r, g, b) setDB("mplusTimerOvertimeColorR", r); setDB("mplusTimerOvertimeColorG", g); setDB("mplusTimerOvertimeColorB", b) end },
            { type = "color", name = L["ENEMY_FORCES_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_ENEMY_FORCES"], dbKey = "mplusProgressColor", get = function() return getDB("mplusProgressColorR", 0.72), getDB("mplusProgressColorG", 0.76), getDB("mplusProgressColorB", 0.88) end, set = function(r, g, b) setDB("mplusProgressColorR", r); setDB("mplusProgressColorG", g); setDB("mplusProgressColorB", b) end },
            { type = "color", name = L["FOCUS_BAR_FILL_COLOUR"], desc = L["FOCUS_PROGRESS_BAR_FILL_COLOUR_PROGRESS"], dbKey = "mplusBarColor", get = function() return getDB("mplusBarColorR", 0.20), getDB("mplusBarColorG", 0.45), getDB("mplusBarColorB", 0.60), getDB("mplusBarColorA", 0.90) end, set = function(r, g, b, a) setDB("mplusBarColorR", r); setDB("mplusBarColorG", g); setDB("mplusBarColorB", b); if a then setDB("mplusBarColorA", a) end end, hasAlpha = true },
            { type = "color", name = L["FOCUS_BAR_COMPLETE_COLOUR"], desc = L["FOCUS_PROGRESS_BAR_FILL_COLOUR_ENEMY_FORCES"], dbKey = "mplusBarDoneColor", get = function() return getDB("mplusBarDoneColorR", 0.15), getDB("mplusBarDoneColorG", 0.65), getDB("mplusBarDoneColorB", 0.25), getDB("mplusBarDoneColorA", 0.90) end, set = function(r, g, b, a) setDB("mplusBarDoneColorR", r); setDB("mplusBarDoneColorG", g); setDB("mplusBarDoneColorB", b); if a then setDB("mplusBarDoneColorA", a) end end, hasAlpha = true },
            { type = "color", name = L["FOCUS_AFFIX_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_AFFIXES"], dbKey = "mplusAffixColor", get = function() return getDB("mplusAffixColorR", 0.85), getDB("mplusAffixColorG", 0.85), getDB("mplusAffixColorB", 0.95) end, set = function(r, g, b) setDB("mplusAffixColorR", r); setDB("mplusAffixColorG", g); setDB("mplusAffixColorB", b) end },
            { type = "color", name = L["FOCUS_BOSS_COLOUR"], desc = L["FOCUS_TEXT_COLOUR_BOSS_NAMES"], dbKey = "mplusBossColor", get = function() return getDB("mplusBossColorR", 0.78), getDB("mplusBossColorG", 0.82), getDB("mplusBossColorB", 0.92) end, set = function(r, g, b) setDB("mplusBossColorR", r); setDB("mplusBossColorG", g); setDB("mplusBossColorB", b) end },
            { type = "button", name = L["RESET_MYTHIC_STYLING"], onClick = function()
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
            { type = "section", name = L["FOCUS_DELVES_DUNGEONS"] },
            { type = "toggle", name = L["SCENARIO_EVENTS"], desc = L["FOCUS_TRACK_DELVE_DUNGEON_SCENARIO_ACTIVITIES"], dbKey = "showScenarioEvents", get = function() return getDB("showScenarioEvents", true) end, set = function(v) setDB("showScenarioEvents", v) end, tooltip = L["FOCUS_DELVES_APPEAR_DELVES_SECTION_DUNGEONS_DUNGEON"] },
            { type = "toggle", name = L["ACTIVE_INSTANCE"], desc = L["ACTIVE_INSTANCE_SECTION"], dbKey = "hideOtherCategoriesInDelve", get = function() return getDB("hideOtherCategoriesInDelve", false) end, set = function(v) setDB("hideOtherCategoriesInDelve", v) end, tooltip = L["HIDES_CATEGORIES_WHILE_A_DELVE_PARTY"] },
            { type = "toggle", name = L["FOCUS_DELVE_AFFIX_NAMES"], desc = L["AFFIX_NAMES_FIRST_DELVE_ENTRY"], dbKey = "showDelveAffixes", get = function() return getDB("showDelveAffixes", getDB("delveBlockShowAffixes", true)) end, set = function(v) setDB("showDelveAffixes", v); if addon.ScheduleRefresh then addon.ScheduleRefresh() end end, tooltip = L["APPEAR_FULL_TRACKER_REPLACEMENTS"] },
            { type = "toggle", name = L["FOCUS_RITUAL_SITE_TITLE_COUNTERS"], desc = L["FOCUS_RITUAL_SITE_TITLE_COUNTERS_DESC"], dbKey = "showScenarioHeaderCurrenciesInTitle", get = function() return getDB("showScenarioHeaderCurrenciesInTitle", true) end, set = function(v) setDB("showScenarioHeaderCurrenciesInTitle", v); if addon.RequestRefresh then addon.RequestRefresh() end; if addon.FullLayout then addon.FullLayout() end end, tooltip = L["FOCUS_RITUAL_SITE_TITLE_COUNTERS_TOOLTIP"] },
            { type = "section", name = L["FOCUS_SCENARIO_BAR"] },
            { type = "toggle", name = L["SCENARIO_TIMER_BAR"], desc = L["FOCUS_TIMER_PROGRESS_BAR_SCENARIO_ENTRIES"], dbKey = "cinematicScenarioBar", get = function() return getDB("cinematicScenarioBar", true) end, set = function(v) setDB("cinematicScenarioBar", v) end },
        },
    },
    {
        key = "ContentTypes",
        name = L["FOCUS_CONTENT"],
        desc = L["TOGGLE_TRACKING_WORLD_QUESTS_RARES_ACHIEVEMENTS"] or "Toggle tracking for world quests, rares, achievements, and more.",
        moduleKey = "focus",
        options = {
            { type = "section", name = L["FOCUS_WORLD_QUESTS"] },
            { type = "toggle", name = L["ZONE_WORLD_QUESTS"], desc = L["AUTO_ADD_WQS_YOUR_CURRENT_ZONE"], dbKey = "showWorldQuests", get = function() return getDB("showWorldQuests", true) end, set = function(v) setDB("showWorldQuests", v) end, tooltip = L["TRACKED_NEARBY_WQS_APPEAR_BLIZZARD_DEFAULT"] },
            { type = "section", name = L["FOCUS_RARE_BOSSES"] },
            { type = "toggle", name = L["FOCUS_RARE_BOSSES"], desc = L["UI_RARE_BOSS_VIGNETTES_LIST"], dbKey = "showRareBosses", get = function() return getDB("showRareBosses", true) end, set = function(v) setDB("showRareBosses", v) end },
            { type = "toggle", name = L["UI_RARE_LOOT"], desc = L["UI_TREASURE_ITEM_VIGNETTES_RARE_LOOT"], dbKey = "showRareLoot", get = function() return getDB("showRareLoot", false) end, set = function(v) setDB("showRareLoot", v) end },
            { type = "toggle", name = L["RARE_SOUND_ALERT"], desc = L["UI_PLAY_A_SOUND_A_RARE"], dbKey = "rareAddedSound", get = function() return getDB("rareAddedSound", true) end, set = function(v) setDB("rareAddedSound", v) end, refreshIds = { "rareAddedSoundChoice", "rareAddedSoundVolume" } },
            { type = "dropdown", name = L["RARE_ADDED_SOUND_CHOICE"] or "Rare added sound choice", desc = L["SOUND_PLAYED_A_RARE_BOSS_APPEARS"], tooltip = L["CHOOSE_WHICH_SOUND_PLAY_A_RARE"], dbKey = "rareAddedSoundChoice", options = function() return addon.GetSoundDropdownOptions and addon.GetSoundDropdownOptions() or { { "Default", "default" } } end, get = function() return getDB("rareAddedSoundChoice", "default") end, set = function(v) setDB("rareAddedSoundChoice", v); if addon.PlayRareAddedSound then addon.PlayRareAddedSound() end end, visibleWhen = function() return getDB("rareAddedSound", true) end },
            { type = "slider", name = L["UI_RARE_SOUND_VOLUME"] or "Rare sound volume", desc = L["UI_VOLUME_OF_RARE_ALERT_SOUND"], tooltip = L["UI_BOOST_REDUCE_RARE_ALERT_VOLUME"], dbKey = "rareAddedSoundVolume", min = 50, max = 200, get = function() return math.max(50, math.min(200, tonumber(getDB("rareAddedSoundVolume", 100)) or 100)) end, set = function(v) setDB("rareAddedSoundVolume", math.max(50, math.min(200, v))) end, visibleWhen = function() return getDB("rareAddedSound", true) end, id = "rareAddedSoundVolume" },
            { type = "section", name = L["FOCUS_ACHIEVEMENTS"] },
            { type = "toggle", name = L["FOCUS_ACHIEVEMENTS"], desc = L["FOCUS_TRACKED_ACHIEVEMENTS_LIST"], dbKey = "showAchievements", get = function() return getDB("showAchievements", true) end, set = function(v) setDB("showAchievements", v) end, refreshIds = { "showCompletedAchievements", "showAchievementIcons", "achievementOnlyMissingRequirements", "showAchievementProgressBars" } },
            { type = "toggle", name = L["INCLUDE_COMPLETED"], desc = L["COMPLETED_ACHIEVEMENTS_LIST"], dbKey = "showCompletedAchievements", id = "showCompletedAchievements", visibleWhen = function() return getDB("showAchievements", true) end, get = function() return getDB("showCompletedAchievements", false) end, set = function(v) setDB("showCompletedAchievements", v) end, tooltip = L["PROGRESS_TRACKED_ACHIEVEMENTS_SHOWN"] },
            { type = "toggle", name = L["ACHIEVEMENT_ICONS"], desc = L["ICON_NEXT_ACHIEVEMENT_TITLE"], dbKey = "showAchievementIcons", id = "showAchievementIcons", visibleWhen = function() return getDB("showAchievements", true) end, get = function() return getDB("showAchievementIcons", true) end, set = function(v) setDB("showAchievementIcons", v) end, tooltip = L["REQUIRES_QUEST_TYPE_ICONS_ENABLED_DISPLAY"] },
            { type = "toggle", name = L["MISSING_CRITERIA"], desc = L["INCOMPLETE_CRITERIA"], tooltip = L["FOCUS_CRITERIA_YOU_HAVEN_T_COMPLETED_TR"], dbKey = "achievementOnlyMissingRequirements", id = "achievementOnlyMissingRequirements", visibleWhen = function() return getDB("showAchievements", true) end, get = function() return getDB("achievementOnlyMissingRequirements", false) end, set = function(v) setDB("achievementOnlyMissingRequirements", v) end },
            { type = "toggle", name = L["FOCUS_ACHIEVEMENT_PROGRESS_BARS"], desc = L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_DESC"], dbKey = "showAchievementProgressBars", id = "showAchievementProgressBars", visibleWhen = function() return getDB("showAchievements", true) end, get = function() return getDB("showAchievementProgressBars", false) end, set = function(v) setDB("showAchievementProgressBars", v); OptionsData_NotifyMainAddon() end, tooltip = L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_TIP"] },
            { type = "section", name = L["FOCUS_ENDEAVORS"] },
            { type = "toggle", name = L["FOCUS_SHOW_ENDEAVORS"], desc = L["FOCUS_TRACKED_ENDEAVORS_PLAYER_HOUSING_LIST"], dbKey = "showEndeavors", get = function() return getDB("showEndeavors", true) end, set = function(v) setDB("showEndeavors", v) end, refreshIds = { "showCompletedEndeavors" } },
            { type = "toggle", name = L["INCLUDE_COMPLETED"], desc = L["FOCUS_INCLUDE_COMPLETED_ENDEAVORS_TRACKER"], dbKey = "showCompletedEndeavors", id = "showCompletedEndeavors", visibleWhen = function() return getDB("showEndeavors", true) end, get = function() return getDB("showCompletedEndeavors", false) end, set = function(v) setDB("showCompletedEndeavors", v) end },
            { type = "section", name = L["FOCUS_DECOR"] },
            { type = "toggle", name = L["FOCUS_SHOW_DECOR"], desc = L["FOCUS_TRACKED_HOUSING_DECOR_LIST"], dbKey = "showDecor", get = function() return getDB("showDecor", true) end, set = function(v) setDB("showDecor", v) end, refreshIds = { "showDecorIcons" } },
            { type = "toggle", name = L["DECOR_ICONS"], desc = L["FOCUS_DECOR_ITEM_S_ICON_NEXT_TITLE"], dbKey = "showDecorIcons", id = "showDecorIcons", visibleWhen = function() return getDB("showDecor", true) end, get = function() return getDB("showDecorIcons", true) end, set = function(v) setDB("showDecorIcons", v) end },
            { type = "section", name = L["FOCUS_APPEARANCES"] },
            { type = "toggle", name = L["FOCUS_SHOW_APPEARANCES"], desc = L["FOCUS_TRACKED_TRANSMOG_APPEARANCES_LIST"], dbKey = "showAppearances", get = function() return getDB("showAppearances", true) end, set = function(v) setDB("showAppearances", v) end, refreshIds = { "showAppearanceIcons", "showCollectedAppearances" } },
            { type = "toggle", name = L["INCLUDE_COMPLETED"], desc = L["FOCUS_INCLUDE_COLLECTED_APPEARANCES_TRACKER"], dbKey = "showCollectedAppearances", id = "showCollectedAppearances", visibleWhen = function() return getDB("showAppearances", true) end, get = function() return getDB("showCollectedAppearances", false) end, set = function(v) setDB("showCollectedAppearances", v) end },
            { type = "toggle", name = L["FOCUS_APPEARANCE_ICONS"], desc = L["FOCUS_APPEARANCE_ICON_NEXT_TITLE"], dbKey = "showAppearanceIcons", id = "showAppearanceIcons", visibleWhen = function() return getDB("showAppearances", true) end, get = function() return getDB("showAppearanceIcons", true) end, set = function(v) setDB("showAppearanceIcons", v) end, tooltip = L["REQUIRES_QUEST_TYPE_ICONS_ENABLED_DISPLAY"] },
            { type = "toggle", name = L["FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON"], desc = L["FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON_DESC"], dbKey = "appearanceIconsUseTransmogTypeIcon", id = "appearanceIconsUseTransmogTypeIcon", visibleWhen = function() return getDB("showAppearances", true) and getDB("showAppearanceIcons", true) end, get = function() return getDB("appearanceIconsUseTransmogTypeIcon", true) end, set = function(v) setDB("appearanceIconsUseTransmogTypeIcon", v) end, tooltip = L["REQUIRES_QUEST_TYPE_ICONS_ENABLED_DISPLAY"] },
            { type = "section", name = L["RECIPES"] or "Recipes" },
            { type = "toggle", name = L["RECIPES"] or "Recipes", desc = (L and L["TRACKED_PROFESSION_RECIPES_LIST"]) or "Show tracked profession recipes in the list.", dbKey = "showRecipes", get = function() return getDB("showRecipes", true) end, set = function(v) setDB("showRecipes", v) end, refreshIds = { "showRecipeReagents", "recipeReagentsFullDetail", "showOptionalReagents", "showFinishingReagents", "showChoiceSlots", "showRecipeIcons", "recipeRarityColors", "showCraftableCount", "showRecipeQualityInfo", "showRecipeRequirements" } },
            { type = "toggle", name = L["REAGENTS"] or "Reagents", desc = (L and L["REAGENT_SHOPPING_LIST_RECIPE"]) or "Show reagent shopping list for each recipe.", dbKey = "showRecipeReagents", id = "showRecipeReagents", visibleWhen = function() return getDB("showRecipes", true) end, get = function() return getDB("showRecipeReagents", true) end, set = function(v) setDB("showRecipeReagents", v) end },
            { type = "toggle", name = L["FOCUS_RECIPE_REAGENTS_FULL_DETAIL"] or "Full reagent detail", desc = (L and L["FOCUS_RECIPE_REAGENTS_FULL_DETAIL_DESC"]) or "List every schematic slot.", dbKey = "recipeReagentsFullDetail", id = "recipeReagentsFullDetail", visibleWhen = function() return getDB("showRecipes", true) and getDB("showRecipeReagents", true) end, get = function() return getDB("recipeReagentsFullDetail", false) end, set = function(v) setDB("recipeReagentsFullDetail", v) end, refreshIds = { "showOptionalReagents", "showFinishingReagents", "showChoiceSlots" } },
            { type = "toggle", name = L["FOCUS_OPTIONAL_REAGENTS"] or "Optional reagents", desc = (L and L["OPTIONAL_REAGENT_SLOTS"]) or "Show optional reagent slots.", dbKey = "showOptionalReagents", id = "showOptionalReagents", visibleWhen = function() return getDB("showRecipes", true) and getDB("recipeReagentsFullDetail", false) end, get = function() return getDB("showOptionalReagents", true) end, set = function(v) setDB("showOptionalReagents", v) end },
            { type = "toggle", name = L["FOCUS_FINISHING_REAGENTS"] or "Finishing reagents", desc = (L and L["FINISHING_REAGENT_SLOTS"]) or "Show finishing reagent slots.", dbKey = "showFinishingReagents", id = "showFinishingReagents", visibleWhen = function() return getDB("showRecipes", true) and getDB("recipeReagentsFullDetail", false) end, get = function() return getDB("showFinishingReagents", true) end, set = function(v) setDB("showFinishingReagents", v) end },
            { type = "toggle", name = L["CHOICE_SLOTS"] or "Choice slots", desc = (L and L["COLLAPSIBLE_CHOICE_REAGENT_SLOTS"]) or "Show collapsible choice reagent slots.", dbKey = "showChoiceSlots", id = "showChoiceSlots", visibleWhen = function() return getDB("showRecipes", true) and getDB("recipeReagentsFullDetail", false) end, get = function() return getDB("showChoiceSlots", true) end, set = function(v) setDB("showChoiceSlots", v) end },
            { type = "toggle", name = L["RECIPE_ICONS"] or "Recipe icons", desc = (L and L["RECIPE_ICON_NEXT_TITLE_REQUIRES_QUEST"]) or "Show recipe icon next to title. Requires quest type icons in Display.", dbKey = "showRecipeIcons", id = "showRecipeIcons", visibleWhen = function() return getDB("showRecipes", true) end, get = function() return getDB("showRecipeIcons", true) end, set = function(v) setDB("showRecipeIcons", v) end },
            { type = "toggle", name = L["RARITY_COLOURS"] or "Rarity colors", desc = (L and L["COLOUR_RECIPE_TITLES_OUTPUT_ITEM_RARITY"]) or "Color recipe titles by output item rarity.", dbKey = "recipeRarityColors", id = "recipeRarityColors", visibleWhen = function() return getDB("showRecipes", true) end, get = function() return getDB("recipeRarityColors", true) end, set = function(v) setDB("recipeRarityColors", v) end },
            { type = "toggle", name = L["CRAFTABLE_COUNT"] or "Craftable count", desc = (L and L["MANY_TIMES_RECIPE_CRAFTED"]) or "Show how many times the recipe can be crafted.", dbKey = "showCraftableCount", id = "showCraftableCount", visibleWhen = function() return getDB("showRecipes", true) end, get = function() return getDB("showCraftableCount", true) end, set = function(v) setDB("showCraftableCount", v) end },
            { type = "toggle", name = L["QUALITY_INFO"] or "Quality info", desc = (L and L["RECIPES_TIER_QUALITY_PIPS"]) or "Show quality tier pips for recipes that support qualities.", dbKey = "showRecipeQualityInfo", id = "showRecipeQualityInfo", visibleWhen = function() return getDB("showRecipes", true) end, get = function() return getDB("showRecipeQualityInfo", false) end, set = function(v) setDB("showRecipeQualityInfo", v) end },
            { type = "toggle", name = L["REQUIREMENTS"] or "Requirements", desc = (L and L["UNMET_CRAFTING_STATION_REQUIREMENTS"]) or "Show unmet crafting station requirements.", dbKey = "showRecipeRequirements", id = "showRecipeRequirements", visibleWhen = function() return getDB("showRecipes", true) end, get = function() return getDB("showRecipeRequirements", false) end, set = function(v) setDB("showRecipeRequirements", v) end },
            { type = "toggle", name = L["FOCUS_AUCTIONATOR_SEARCH"] or "Auctionator search button", desc = (L and L["FOCUS_AUCTIONATOR_SEARCH_DESC"]) or "Show a button on recipe entries to search for required reagents in the Auction House (requires Auctionator).", dbKey = "showAHSearchButton", id = "showAHSearchButton", visibleWhen = function() return getDB("showRecipes", true) end, get = function() return getDB("showAHSearchButton", true) end, set = function(v) setDB("showAHSearchButton", v) end },
            { type = "section", name = L["FOCUS_ADVENTURE_GUIDE"] },
            { type = "toggle", name = L["TRAVELERS_LOG"], desc = L["TRACKED_OBJECTIVES_ADVENTURE_GUIDE"], dbKey = "showAdventureGuide", get = function() return getDB("showAdventureGuide", true) end, set = function(v) setDB("showAdventureGuide", v) end, refreshIds = { "autoRemoveCompletedAdventureGuide" } },
            { type = "toggle", name = L["UNTRACK_COMPLETE"], desc = L["AUTO_UNTRACK_FINISHED_ACTIVITIES"], dbKey = "autoRemoveCompletedAdventureGuide", id = "autoRemoveCompletedAdventureGuide", visibleWhen = function() return getDB("showAdventureGuide", true) end, get = function() return getDB("autoRemoveCompletedAdventureGuide", true) end, set = function(v) setDB("autoRemoveCompletedAdventureGuide", v) end },
            { type = "section", name = L["FOCUS_FLOATING_QUEST_ITEM"] },
            { type = "toggle", name = L["FOCUS_SHOW_FLOATING_QUEST_ITEM"], desc = L["FOCUS_QUICK_BUTTON_FOCUSED_QUEST_S_USABLE"], dbKey = "showFloatingQuestItem", get = function() return getDB("showFloatingQuestItem", false) end, set = function(v) setDB("showFloatingQuestItem", v) end, refreshIds = { "lockFloatingQuestItemPosition", "floatingQuestItemMode" } },
            { type = "toggle", name = L["LOCK_ITEM_POSITION"], desc = L["FOCUS_PREVENT_DRAGGING_FLOATING_QUEST_ITEM_BUTTON"], dbKey = "lockFloatingQuestItemPosition", id = "lockFloatingQuestItemPosition", visibleWhen = function() return getDB("showFloatingQuestItem", false) end, get = function() return getDB("lockFloatingQuestItemPosition", false) end, set = function(v) setDB("lockFloatingQuestItemPosition", v); if addon._UpdateFloatingItemDragAnchor then addon._UpdateFloatingItemDragAnchor() end end },
            { type = "dropdown", name = L["ITEM_SOURCE"], desc = L["SUPER_TRACKED_FIRST_CURRENT_ZONE_FIRST"], dbKey = "floatingQuestItemMode", id = "floatingQuestItemMode", visibleWhen = function() return getDB("showFloatingQuestItem", false) end, options = { { L["FOCUS_SUPER_TRACKED_FIRST"], "superTracked" }, { L["FOCUS_CURRENT_ZONE_FIRST"], "currentZone" } }, get = function() return getDB("floatingQuestItemMode", "superTracked") end, set = function(v) setDB("floatingQuestItemMode", v) end },
        },
    },
    {
        key = "Colors",
        name = L["DASH_COLOURS"],
        desc = L["PERSONALIZE_COLOUR_PALETTE_TRACKER_TEXT_ELEMENTS"] or "Personalize the color palette for tracker text elements.",
        moduleKey = "focus",
        options = {
            { type = "colorMatrixFull", name = L["DASH_COLOURS"], dbKey = "colorMatrix" },
        },
    },
    {
        key = "HiddenQuests",
        name = L["FOCUS_HIDDEN_QUESTS"] or "Hidden Quests",
        desc = L["REVIEW_MANAGE_QUESTS_YOU_MANUALLY_UNTRACKED"] or "Review and manage quests you have manually untracked or blacklisted.",
        moduleKey = "focus",
        options = {
            { type = "blacklistGrid", name = L["FOCUS_BLACKLISTED_QUESTS"], desc = L["FOCUS_QUESTS_HIDDEN_RIGHT_CLICK_UNTRACK"], tooltip = L["ENABLE_BLACKLIST_UNTRACKED_INTERACTIONS_ADD_QUEST"] or "Enable 'Blacklist untracked' in Interactions to add quests here." },
        },
    },
    {
        key = "PresenceGeneral",
        name = L["AXIS_GENERAL"] or "General",
        desc = L["SETTINGS_PRESENCE_NOTIFICATION_FRAMEWORK"] or "Core settings for the Presence notification framework.",
        moduleKey = "presence",
        options = {
            { type = "section", name = L["DASH_DISPLAY"] },
            { type = "toggle", name = L["TOAST_ICONS"], desc = L["PRESENCE_QUEST_TYPE_ICON_PRESENCE_TOASTS_QUEST"], dbKey = "showPresenceQuestTypeIcons", get = function() return getDB("showPresenceQuestTypeIcons", true) end, set = function(v) setDB("showPresenceQuestTypeIcons", v) end, refreshIds = { "presencePreview" } },
            { type = "slider", name = L["PRESENCE_TOAST_ICON_SIZE"], desc = L["PRESENCE_QUEST_ICON_SIZE_PRESENCE_TOASTS_PX"], dbKey = "presenceIconSize", min = 16, max = 36, get = function() return math.max(16, math.min(36, getDB("presenceIconSize", 24) or 24)) end, set = function(v) setDB("presenceIconSize", math.max(16, math.min(36, v))) end, refreshIds = { "presencePreview" } },
            { type = "toggle", name = L["PRESENCE_HIDE_QUEST_UPDATE_TITLE"], desc = L["OBJECTIVE_LINE"], tooltip = L["PRESENCE_OBJECTIVE_LINE_QUEST_PROGRESS_TOAST"], dbKey = "presenceHideQuestUpdateTitle", get = function() return getDB("presenceHideQuestUpdateTitle", false) end, set = function(v) setDB("presenceHideQuestUpdateTitle", v) end, refreshIds = { "presencePreview" } },
            { type = "toggle", name = L["PRESENCE_DISCOVERY_LINE"], desc = L["PRESENCE_SHOW_DISCOVERED"], dbKey = "showPresenceDiscovery", get = function() return getDB("showPresenceDiscovery", true) end, set = function(v) setDB("showPresenceDiscovery", v) end, refreshIds = { "presencePreview" } },
            { type = "slider", name = L["PRESENCE_FRAME_VERTICAL_POSITION"], desc = L["PRESENCE_VERTICAL_OFFSET_OF_PRESENCE_FRAME_CENTER"], dbKey = "presenceFrameY", min = -300, max = 0, get = function() return math.max(-300, math.min(0, tonumber(getDB("presenceFrameY", -180)) or -180)) end, set = function(v) setDB("presenceFrameY", math.max(-300, math.min(0, v))) end },
            { type = "slider", name = L["PRESENCE_FRAME_SCALE"], desc = L["PRESENCE_FRAME_SCALE_TIP"], dbKey = "presenceFrameScale", min = 0.5, max = 2, step = 0.1, get = function() return math.max(0.5, math.min(2, tonumber(getDB("presenceFrameScale", 1)) or 1)) end, set = function(v) setDB("presenceFrameScale", math.max(0.5, math.min(2, v))) end },
            { type = "section", name = L["PRESENCE_ANIMATION"] },
            { type = "toggle", name = L["FOCUS_ANIMATIONS"], desc = L["PRESENCE_ENABLE_ENTRANCE_EXIT_ANIMATIONS_PRESENCE"], dbKey = "presenceAnimations", get = function() return getDB("presenceAnimations", true) end, set = function(v) setDB("presenceAnimations", v) end },
            { type = "slider", name = L["PRESENCE_ENTRANCE_DURATION"], desc = L["PRESENCE_DURATION_OF_ENTRANCE_ANIMATION_SECONDS"], dbKey = "presenceEntranceDur", min = 0.2, max = 1.5, step = 0.1, get = function() return math.max(0.2, math.min(1.5, tonumber(getDB("presenceEntranceDur", 0.7)) or 0.7)) end, set = function(v) setDB("presenceEntranceDur", math.max(0.2, math.min(1.5, v))) end },
            { type = "slider", name = L["PRESENCE_EXIT_DURATION"], desc = L["PRESENCE_DURATION_OF_EXIT_ANIMATION_SECONDS"], dbKey = "presenceExitDur", min = 0.2, max = 1.5, step = 0.1, get = function() return math.max(0.2, math.min(1.5, tonumber(getDB("presenceExitDur", 0.8)) or 0.8)) end, set = function(v) setDB("presenceExitDur", math.max(0.2, math.min(1.5, v))) end },
            { type = "slider", name = L["PRESENCE_HOLD_DURATION_SCALE"], desc = L["PRESENCE_MULTIPLIER_LONG_NOTIFICATION_STAY"], dbKey = "presenceHoldScale", min = 0.5, max = 2, step = 0.1, get = function() return math.max(0.5, math.min(2, tonumber(getDB("presenceHoldScale", 1)) or 1)) end, set = function(v) setDB("presenceHoldScale", math.max(0.5, math.min(2, v))) end },
        },
    },
    {
        key = "PresencePreview",
        name = L["PRESENCE_PREVIEW"] or "Preview",
        desc = L["PRESENCE_PREVIEW_PRESENCE_TOAST_LAYOUTS_LIVE_OPEN"] or "Preview Presence toast layouts live and open a detachable sample while adjusting other settings.",
        moduleKey = "presence",
        options = {
            { type = "section", name = L["PRESENCE_PREVIEW"] },
            { type = "presencePreview" },
        },
    },
    {
        key = "PresenceNotifications",
        name = L["PRESENCE_NOTIFICATIONS"],
        desc = L["CHOOSE_WHICH_EVENTS_TRIGGER_SCREEN_ALERTS"] or "Choose which events trigger on-screen alerts.",
        moduleKey = "presence",
        options = {
            { type = "section", name = L["PRESENCE_NOTIFICATION_TYPES"] },
            { type = "toggle", name = L["ZONE_ENTRY"], desc = L["PRESENCE_ZONE_CHANGE_ENTERING_A_AREA"], dbKey = "presenceZoneChange", get = function() return getDB("presenceZoneChange", true) end, set = function(v) setDB("presenceZoneChange", v) end },
            { type = "toggle", name = L["SUBZONE_CHANGES"], desc = L["PRESENCE_SUBZONE_CHANGE_MOVING_WITHIN_SAME_ZONE"], dbKey = "presenceSubzoneChange", get = function() local v = getDB("presenceSubzoneChange", nil); if v ~= nil then return v end; return getDB("presenceZoneChange", true) end, set = function(v) setDB("presenceSubzoneChange", v) end },
            { type = "toggle", name = L["VISTA_SHOW_SUBZONE"], desc = L["SUBZONE_NAME_WITHIN_SAME_ZONE"], dbKey = "presenceHideZoneForSubzone", get = function() return getDB("presenceHideZoneForSubzone", false) end, set = function(v) setDB("presenceHideZoneForSubzone", v) end, tooltip = L["ZONE_NAME_NEW_ZONE"] },
            { type = "toggle", name = L["SUPPRESS_M"], desc = L["HIDE_ZONE_NOTIFICATIONS_MYTHIC"], tooltip = L["BOSS_EMOTES_ACHIEVEMENTS_LEVEL_HIDES_ZONE"], dbKey = "presenceSuppressZoneInMplus", get = function() return getDB("presenceSuppressZoneInMplus", true) end, set = function(v) setDB("presenceSuppressZoneInMplus", v) end },
            { type = "section", name = L["INSTANCE_SUPPRESSION"] },
            { type = "toggle", name = L["SUPPRESS_DUNGEON"], desc = L["SUPPRESS_NOTIFICATIONS_DUNGEONS"], tooltip = L["SUPPRESS_IN_DUNGEON_DETAIL"], dbKey = "presenceSuppressInDungeon", get = function() return getDB("presenceSuppressInDungeon", false) end, set = function(v) setDB("presenceSuppressInDungeon", v) end },
            { type = "toggle", name = L["PRESENCE_SUPPRESS_DELVE"], desc = L["PRESENCE_SUPPRESS_SCENARIO_PROGRESS_NOTIFICATIONS_DELVES"], tooltip = L["PRESENCE_HIDE_DELVE_OBJECTIVE_UPDATE"], dbKey = "presenceSuppressInDelve", get = function() return getDB("presenceSuppressInDelve", false) end, set = function(v) setDB("presenceSuppressInDelve", v) end },
            { type = "toggle", name = L["SUPPRESS_RAID"], desc = L["SUPPRESS_IN_RAID_DETAIL"], dbKey = "presenceSuppressInRaid", get = function() return getDB("presenceSuppressInRaid", false) end, set = function(v) setDB("presenceSuppressInRaid", v) end },
            { type = "toggle", name = L["SUPPRESS_PVP"], desc = L["SUPPRESS_IN_ARENA_DETAIL"], dbKey = "presenceSuppressInPvP", get = function() return getDB("presenceSuppressInPvP", false) end, set = function(v) setDB("presenceSuppressInPvP", v) end },
            { type = "toggle", name = L["SUPPRESS_BATTLEGROUND"], desc = L["SUPPRESS_PRESENCE_NOTIFICATIONS_WHILE_INSIDE_A"], dbKey = "presenceSuppressInBattleground", get = function() return getDB("presenceSuppressInBattleground", false) end, set = function(v) setDB("presenceSuppressInBattleground", v) end },
            { type = "toggle", name = L["PRESENCE_LEVEL_UP_TOGGLE"], desc = L["PRESENCE_LEVEL_NOTIFICATION"], dbKey = "presenceLevelUp", get = function() return getDB("presenceLevelUp", true) end, set = function(v) setDB("presenceLevelUp", v) end },
            { type = "toggle", name = L["BOSS_EMOTES"], desc = L["PRESENCE_RAID_DUNGEON_BOSS_EMOTE_NOTIFICATIONS"], dbKey = "presenceBossEmote", get = function() return getDB("presenceBossEmote", true) end, set = function(v) setDB("presenceBossEmote", v) end },
            { type = "toggle", name = L["FOCUS_ACHIEVEMENTS"], desc = L["PRESENCE_ACHIEVEMENT_EARNED_NOTIFICATIONS"], dbKey = "presenceAchievement", get = function() return getDB("presenceAchievement", true) end, set = function(v) setDB("presenceAchievement", v) end },
            { type = "toggle", name = L["PRESENCE_ACHIEVEMENT_PROGRESS"], desc = L["NOTIFY_ACHIEVEMENT_CRITERIA_UPDATE"], tooltip = L["PRESENCE_NOTIFICATION_ACHIEVEMENT_CRITERIA_UPDATE"], dbKey = "presenceAchievementProgress", get = function() return getDB("presenceAchievementProgress", false) end, set = function(v) setDB("presenceAchievementProgress", v) end },
            { type = "toggle", name = L["QUEST_ACCEPT"], desc = L["PRESENCE_NOTIFICATION_ACCEPTING_A_QUEST"], dbKey = "presenceQuestAccept", get = function() local v = getDB("presenceQuestAccept", nil); if v ~= nil then return v end; return getDB("presenceQuestEvents", true) end, set = function(v) setDB("presenceQuestAccept", v) end },
            { type = "toggle", name = L["WORLD_QUEST_ACCEPT"], desc = L["PRESENCE_NOTIFICATION_ACCEPTING_A_WORLD_QUEST"], dbKey = "presenceWorldQuestAccept", get = function() local v = getDB("presenceWorldQuestAccept", nil); if v ~= nil then return v end; return getDB("presenceQuestEvents", true) end, set = function(v) setDB("presenceWorldQuestAccept", v) end },
            { type = "toggle", name = L["QUEST_COMPLETE"], desc = L["PRESENCE_NOTIFICATION_COMPLETING_A_QUEST"], dbKey = "presenceQuestComplete", get = function() local v = getDB("presenceQuestComplete", nil); if v ~= nil then return v end; return getDB("presenceQuestEvents", true) end, set = function(v) setDB("presenceQuestComplete", v) end },
            { type = "toggle", name = L["WORLD_QUEST_COMPLETE"], desc = L["PRESENCE_NOTIFICATION_COMPLETING_A_WORLD_QUEST"], dbKey = "presenceWorldQuest", get = function() local v = getDB("presenceWorldQuest", nil); if v ~= nil then return v end; return getDB("presenceQuestEvents", true) end, set = function(v) setDB("presenceWorldQuest", v) end },
            { type = "toggle", name = L["QUEST_PROGRESS"], desc = L["PRESENCE_NOTIFICATION_QUEST_OBJECTIVES_UPDATE"], dbKey = "presenceQuestUpdate", get = function() local v = getDB("presenceQuestUpdate", nil); if v ~= nil then return v end; return getDB("presenceQuestEvents", true) end, set = function(v) setDB("presenceQuestUpdate", v) end },
            { type = "toggle", name = L["PRESENCE_OBJECTIVE"], desc = L["PRESENCE_QUEST_PROGRESS_HIDE_TITLE"], dbKey = "presenceHideQuestUpdateTitle", get = function() return getDB("presenceHideQuestUpdateTitle", false) end, set = function(v) setDB("presenceHideQuestUpdateTitle", v) end },
            { type = "toggle", name = L["SCENARIO_START"], desc = L["PRESENCE_NOTIFICATION_ENTERING_A_SCENARIO_DELVE"], dbKey = "presenceScenarioStart", get = function() local v = getDB("presenceScenarioStart", nil); if v ~= nil then return v end; return getDB("showScenarioEvents", true) end, set = function(v) setDB("presenceScenarioStart", v) end },
            { type = "toggle", name = L["SCENARIO_PROGRESS"], desc = L["PRESENCE_NOTIFICATION_SCENARIO_DELVE_OBJECTIVES"], dbKey = "presenceScenarioUpdate", get = function() local v = getDB("presenceScenarioUpdate", nil); if v ~= nil then return v end; return getDB("showScenarioEvents", true) end, set = function(v) setDB("presenceScenarioUpdate", v) end },
            { type = "toggle", name = L["PRESENCE_SHOW_SCENARIO_COMPLETE"], desc = L["NOTIFICATION_A_SCENARIO_DELVE_FULLY_COM"], dbKey = "presenceScenarioComplete", get = function() local v = getDB("presenceScenarioComplete", nil); if v ~= nil then return v end; return getDB("showScenarioEvents", true) end, set = function(v) setDB("presenceScenarioComplete", v) end },
            { type = "toggle", name = L["PRESENCE_SHOW_RARE_DEFEATED"], desc = L["NOTIFICATION_A_RARE_MOB_DEFEATED_NEARBY"], dbKey = "presenceRareDefeated", get = function() return getDB("presenceRareDefeated", true) end, set = function(v) setDB("presenceRareDefeated", v) end },
        },
    },
    {
        key = "PresenceTypography",
        name = L["DASH_TYPOGRAPHY"],
        desc = L["FONTS_SIZES_COLOURS_PRESENCE_NOTIFICATIONS"] or "Fonts, sizes, and colors for Presence notifications.",
        moduleKey = "presence",
        options = {
            { type = "section", name = L["DASH_TYPOGRAPHY"] },
            { type = "button", name = L["PRESENCE_RESET_TYPOGRAPHY_DEFAULTS"], desc = L["PRESENCE_RESET_PRESENCE_TYPOGRAPHY_OPTIONS_FONTS_SIZES"], onClick = function()
                setDB("presenceTitleFontPath", nil)
                setDB("presenceSubtitleFontPath", nil)
                setDB("presencePrimaryLargeSz", nil)
                setDB("presenceSecondaryLargeSz", nil)
                setDB("presencePrimaryMediumSz", nil)
                setDB("presenceSecondaryMediumSz", nil)
                setDB("presencePrimarySmallSz", nil)
                setDB("presenceSecondarySmallSz", nil)
                setDB("presenceBossEmoteColor", nil)
                setDB("presenceDiscoveryColor", nil)
                setDB("presenceZoneTypeColoring", nil)
                setDB("presenceZoneColorFriendly", nil)
                setDB("presenceZoneColorHostile", nil)
                setDB("presenceZoneColorContested", nil)
                setDB("presenceZoneColorSanctuary", nil)
                if addon.Presence and addon.Presence.ApplyPresenceOptions then addon.Presence.ApplyPresenceOptions() end
                if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                if C_Timer and C_Timer.After and addon.OptionsPanel_Refresh then
                    C_Timer.After(0, addon.OptionsPanel_Refresh)
                elseif addon.OptionsPanel_Refresh then
                    addon.OptionsPanel_Refresh()
                end
            end, refreshIds = { "presencePreview", "presenceTitleFontPath", "presenceSubtitleFontPath", "presencePrimaryLargeSz", "presenceSecondaryLargeSz", "presencePrimaryMediumSz", "presenceSecondaryMediumSz", "presencePrimarySmallSz", "presenceSecondarySmallSz", "presenceBossEmoteColor", "presenceDiscoveryColor", "presenceZoneTypeColoring", "presenceZoneColorFriendly", "presenceZoneColorHostile", "presenceZoneColorContested", "presenceZoneColorSanctuary" } },
            { type = "dropdown", name = L["PRESENCE_MAIN_TITLE_FONT"], desc = L["PRESENCE_FONT_FAMILY_MAIN_TITLE"], dbKey = "presenceTitleFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("presenceTitleFontPath") end, get = function() return getDB("presenceTitleFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("presenceTitleFontPath", v) end, displayFn = DisplayPerElementFont, refreshIds = { "presencePreview" }, fontPreviewInList = true },
            { type = "dropdown", name = L["PRESENCE_SUBTITLE_FONT"], desc = L["PRESENCE_FONT_FAMILY_SUBTITLE"], dbKey = "presenceSubtitleFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("presenceSubtitleFontPath") end, get = function() return getDB("presenceSubtitleFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("presenceSubtitleFontPath", v) end, displayFn = DisplayPerElementFont, refreshIds = { "presencePreview" }, fontPreviewInList = true },
            { type = "section", name = L["PRESENCE_LARGE_NOTIFICATIONS"] },
            { type = "slider", name = L["PRESENCE_LARGE_PRIMARY_SIZE"], desc = L["PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_TITLES_ZONE"], dbKey = "presencePrimaryLargeSz", min = 12, max = 72, get = function() return math.max(12, math.min(72, tonumber(getDB("presencePrimaryLargeSz", 48)) or 48)) end, set = function(v) setDB("presencePrimaryLargeSz", math.max(12, math.min(72, v))) end, refreshIds = { "presencePreview" } },
            { type = "slider", name = L["PRESENCE_LARGE_SECONDARY_SIZE"], desc = L["PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_SUBTITLES"], dbKey = "presenceSecondaryLargeSz", min = 12, max = 40, get = function() return math.max(12, math.min(40, tonumber(getDB("presenceSecondaryLargeSz", 24)) or 24)) end, set = function(v) setDB("presenceSecondaryLargeSz", math.max(12, math.min(40, v))) end, refreshIds = { "presencePreview" } },
            { type = "section", name = L["PRESENCE_MEDIUM_NOTIFICATIONS"] },
            { type = "slider", name = L["PRESENCE_MEDIUM_PRIMARY_SIZE"], desc = L["PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_TITLES_QUEST"], dbKey = "presencePrimaryMediumSz", min = 12, max = 72, get = function() return math.max(12, math.min(72, tonumber(getDB("presencePrimaryMediumSz", 36)) or 36)) end, set = function(v) setDB("presencePrimaryMediumSz", math.max(12, math.min(72, v))) end, refreshIds = { "presencePreview" } },
            { type = "slider", name = L["PRESENCE_MEDIUM_SECONDARY_SIZE"], desc = L["PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_SUBTITLES"], dbKey = "presenceSecondaryMediumSz", min = 12, max = 40, get = function() return math.max(12, math.min(40, tonumber(getDB("presenceSecondaryMediumSz", 22)) or 22)) end, set = function(v) setDB("presenceSecondaryMediumSz", math.max(12, math.min(40, v))) end, refreshIds = { "presencePreview" } },
            { type = "section", name = L["PRESENCE_SMALL_NOTIFICATIONS"] },
            { type = "slider", name = L["PRESENCE_SMALL_PRIMARY_SIZE"], desc = L["PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_TITLES_QUEST"], dbKey = "presencePrimarySmallSz", min = 12, max = 72, get = function() return math.max(12, math.min(72, tonumber(getDB("presencePrimarySmallSz", 28)) or 28)) end, set = function(v) setDB("presencePrimarySmallSz", math.max(12, math.min(72, v))) end, refreshIds = { "presencePreview" } },
            { type = "slider", name = L["PRESENCE_SMALL_SECONDARY_SIZE"], desc = L["PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_SUBTITLES"], dbKey = "presenceSecondarySmallSz", min = 12, max = 40, get = function() return math.max(12, math.min(40, tonumber(getDB("presenceSecondarySmallSz", 20)) or 20)) end, set = function(v) setDB("presenceSecondarySmallSz", math.max(12, math.min(40, v))) end, refreshIds = { "presencePreview" } },
            { type = "section", name = L["DASH_COLOURS"] },
            { type = "color", name = L["PRESENCE_BOSS_EMOTE_COLOUR"], desc = L["PRESENCE_COLOUR_RAID_DUNGEON_BOSS_EMOTE"], dbKey = "presenceBossEmoteColor", default = addon.PRESENCE_BOSS_EMOTE_COLOR, refreshIds = { "presencePreview" } },
            { type = "color", name = L["PRESENCE_DISCOVERY_LINE_COLOUR"], desc = L["PRESENCE_COLOUR_OF_DISCOVERED_LINE_UNDER_ZONE_TIP"], dbKey = "presenceDiscoveryColor", default = addon.PRESENCE_DISCOVERY_COLOR, refreshIds = { "presencePreview" } },
            { type = "section", name = L["ZONE_TYPE_COLOURING"] },
            { type = "toggle", name = L["COLOUR_ZONE_TYPE"], desc = L["COLOUR_ZONE_SUBZONE_TITLES_PVP_ZONE"], dbKey = "presenceZoneTypeColoring", get = function() return getDB("presenceZoneTypeColoring", false) end, set = function(v) setDB("presenceZoneTypeColoring", v) end, refreshIds = { "presencePreview" } },
            { type = "color", name = L["FRIENDLY_ZONE_COLOUR"], desc = L["COLOUR_FRIENDLY_ZONES_GREEN_DEFAULT"], dbKey = "presenceZoneColorFriendly", default = { 0.1, 1.0, 0.1 }, refreshIds = { "presencePreview" } },
            { type = "color", name = L["HOSTILE_ZONE_COLOUR"], desc = L["COLOUR_HOSTILE_ZONES_RED_DEFAULT"], dbKey = "presenceZoneColorHostile", default = { 1.0, 0.1, 0.1 }, refreshIds = { "presencePreview" } },
            { type = "color", name = L["CONTESTED_ZONE_COLOUR"], desc = L["COLOUR_CONTESTED_ZONES_ORANGE_DEFAULT"], dbKey = "presenceZoneColorContested", default = { 1.0, 0.7, 0.0 }, refreshIds = { "presencePreview" } },
            { type = "color", name = L["SANCTUARY_ZONE_COLOUR"], desc = L["COLOUR_SANCTUARY_ZONES_BLUE_DEFAULT"], dbKey = "presenceZoneColorSanctuary", default = { 0.41, 0.8, 0.94 }, refreshIds = { "presencePreview" } },
        },
    },
    {
        key = "InsightGlobal",
        name = L["INSIGHT_CATEGORY_GLOBAL"] or "Global Tooltips",
        desc = L["INSIGHT_CATEGORY_GLOBAL_DESC"] or "Anchor, backdrop, font family, and display options shared across tooltip types.",
        moduleKey = "insight",
        dashboardPreviewMode = "global",
        options = {
            { type = "section", name = L["AXIS_POSITION"] or "Position" },
            { type = "dropdown", name = L["TOOLTIP_ANCHOR"] or "Tooltip anchor", desc = L["AXIS_WHERE_TOOLTIPS_APPEAR_FOLLOW_CURSOR_FIXED"] or "Where tooltips appear: follow cursor or fixed position.", dbKey = "insightAnchorMode", options = { { L["AXIS_CURSOR"] or "Cursor", "cursor" }, { L["AXIS_FIXED"] or "Fixed", "fixed" } }, get = function() return getDB("insightAnchorMode", "cursor") end, set = function(v) setDB("insightAnchorMode", v) end, refreshIds = { "insightCursorSide", "insightCursorOffsetX", "insightCursorOffsetY", "insightFocusDynamicInFixed" } },
            { type = "dropdown", name = L["INSIGHT_CURSOR_SIDE"] or "Cursor side", desc = L["INSIGHT_CURSOR_SIDE_DESC"] or "Which side of the cursor the tooltip appears on.", dbKey = "insightCursorSide", options = { { L["INSIGHT_CURSOR_SIDE_CENTER"] or "Center", "center" }, { L["INSIGHT_CURSOR_SIDE_LEFT"] or "Left", "left" }, { L["INSIGHT_CURSOR_SIDE_RIGHT"] or "Right", "right" } }, get = function() return getDB("insightCursorSide", "center") end, set = function(v) setDB("insightCursorSide", v) end, visibleWhen = function() return getDB("insightAnchorMode", "cursor") == "cursor" end, refreshIds = { "insightCursorOffsetX", "insightCursorOffsetY" } },
            { type = "slider", name = L["INSIGHT_CURSOR_OFFSET_X"] or "Cursor offset X", desc = L["INSIGHT_CURSOR_OFFSET_X_DESC"] or "Horizontal pixel offset from the cursor anchor position.", dbKey = "insightCursorOffsetX", min = -100, max = 100, step = 5, get = function() return math.max(-100, math.min(100, math.floor(tonumber(getDB("insightCursorOffsetX", 0)) or 0))) end, set = function(v) setDB("insightCursorOffsetX", math.max(-100, math.min(100, v))) end, visibleWhen = function() return getDB("insightAnchorMode", "cursor") == "cursor" and getDB("insightCursorSide", "center") ~= "center" end },
            { type = "slider", name = L["INSIGHT_CURSOR_OFFSET_Y"] or "Cursor offset Y", desc = L["INSIGHT_CURSOR_OFFSET_Y_DESC"] or "Vertical pixel offset from the cursor anchor position.", dbKey = "insightCursorOffsetY", min = -100, max = 100, step = 5, get = function() return math.max(-100, math.min(100, math.floor(tonumber(getDB("insightCursorOffsetY", 0)) or 0))) end, set = function(v) setDB("insightCursorOffsetY", math.max(-100, math.min(100, v))) end, visibleWhen = function() return getDB("insightAnchorMode", "cursor") == "cursor" and getDB("insightCursorSide", "center") ~= "center" end },
            { type = "button", name = L["AXIS_ANCHOR_MOVE"] or "Show anchor to move", desc = L["AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITION"] or "Click to show or hide the anchor. Drag to set position, right-click to confirm.", onClick = function()
                if addon.Insight and addon.Insight.ToggleAnchorFrame then addon.Insight.ToggleAnchorFrame() end
            end },
            { type = "button", name = L["AXIS_RESET_TOOLTIP_POSITION"] or "Reset tooltip position", desc = L["AXIS_RESET_FIXED_POSITION_DEFAULT"] or "Reset fixed position to default.", onClick = function()
                setDB("insightFixedPoint", "BOTTOMRIGHT")
                setDB("insightFixedX", -60)
                setDB("insightFixedY", 120)
                if addon.Insight and addon.Insight.ApplyInsightOptions then addon.Insight.ApplyInsightOptions() end
            end },
            { type = "toggle", name = L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED"] or "Dynamic position for Focus tooltips", desc = L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED_DESC"] or "When fixed anchor is on, Focus tracker tooltips still attach to the outer edge of the Horizon panel so they never cover the tracker.", dbKey = "insightFocusDynamicInFixed", get = function() return getDB("insightFocusDynamicInFixed", false) end, set = function(v) setDB("insightFocusDynamicInFixed", v) end, visibleWhen = function() return getDB("insightAnchorMode", "cursor") == "fixed" and addon.IsModuleEnabled and addon:IsModuleEnabled("focus") end },
            { type = "section", name = L["DASH_APPEARANCE"] or "Appearance" },
            { type = "slider", name = L["AXIS_TOOLTIP_BACKGROUND_OPACITY"] or "Tooltip background opacity", desc = L["AXIS_TOOLTIP_BG_OPACITY_PCT_DESC"] or "Tooltip background opacity (0–100%).", dbKey = "insightBgOpacity", min = 0, max = 100, get = function() local v = tonumber(getDB("insightBgOpacity", 0.75)) or 0.75; if v <= 1 and v > 0 then return math.floor(v * 100 + 0.5) end; return math.max(0, math.min(100, v)) end, set = function(v) setDB("insightBgOpacity", math.max(0, math.min(100, v)) / 100) end },
            { type = "dropdown", name = L["AXIS_TOOLTIP_FONT"] or "Tooltip font", desc = L["AXIS_FONT_FAMILY_TOOLTIP_TEXT"] or "Font family used for all tooltip text.", dbKey = "insightFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("insightFontPath") end, get = function() return getDB("insightFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("insightFontPath", v) end, displayFn = DisplayPerElementFont, fontPreviewInList = true },
            { type = "section", name = L["INSIGHT_SECTION_COMBAT"] or "Combat" },
            { type = "toggle", name = L["INSIGHT_HIDE_IN_COMBAT"] or "Hide tooltips in combat", desc = L["INSIGHT_HIDE_IN_COMBAT_DESC"] or "While in combat, close GameTooltip and other Insight-styled tooltip frames and block them from staying open. Applies only when the Insight module is enabled.", dbKey = "insightHideTooltipsInCombat", get = function() return getDB("insightHideTooltipsInCombat", false) end, set = function(v) setDB("insightHideTooltipsInCombat", v) end },
            { type = "section", name = L["INSIGHT_SECTION_ICONS_AND_SEPARATORS"] or "Icons & separators" },
            { type = "toggle", name = L["AXIS_ICONS"] or "Show icons", desc = L["AXIS_FACTION_SPEC_MOUNT_MYTHIC_ICONS_TOOLTIPS"] or "Show faction, spec, mount, and Mythic+ icons in tooltips.", dbKey = "insightShowIcons", get = function() return getDB("insightShowIcons", true) end, set = function(v) setDB("insightShowIcons", v) end, refreshIds = { "insightClassIconSource" } },
            { type = "toggle", name = L["AXIS_BLANK_SEPARATOR"] or "Blank separator", desc = L["AXIS_A_BLANK_LINE_INSTEAD_OF_DASHES"] or "Use a blank line instead of dashes between tooltip sections.", dbKey = "insightBlankSeparator", get = function() return getDB("insightBlankSeparator", false) end, set = function(v) setDB("insightBlankSeparator", v) end },
        },
    },
    {
        key = "InsightPlayer",
        name = L["INSIGHT_CATEGORY_PLAYER"] or "Player Characters",
        desc = L["INSIGHT_CATEGORY_PLAYER_DESC"] or "Guild rank, titles, badges, PvP, ratings, gear, mount lines, icons, and section separators on player tooltips.",
        moduleKey = "insight",
        dashboardPreviewMode = "player",
        options = {
            { type = "section", name = L["INSIGHT_SECTION_IDENTITY"] or "Identity" },
            { type = "dropdown", name = L["INSIGHT_PLAYER_NAME_COLOUR"] or "Player name colour", desc = L["INSIGHT_PLAYER_NAME_COLOUR_DESC"] or "Colour for the player's name on the first tooltip line.", dbKey = "insightPlayerNameColor", options = { { L["INSIGHT_PLAYER_NAME_COLOUR_FACTION"] or "Faction", "faction" }, { L["INSIGHT_PLAYER_NAME_COLOUR_CLASS"] or "Class", "class" } }, get = function() local v = getDB("insightPlayerNameColor", "faction"); return v == "class" and "class" or "faction" end, set = function(v) setDB("insightPlayerNameColor", v == "class" and "class" or "faction") end, refreshIds = { "insightPlayerNameGradient" } },
            { type = "toggle", name = L["INSIGHT_PLAYER_NAME_GRADIENT"] or "Class colour gradient", desc = L["INSIGHT_PLAYER_NAME_GRADIENT_DESC"] or "Render the player name as a two-stop gradient of their class colour (only applies when the name colour is set to Class).", dbKey = "insightPlayerNameGradient", isNew = "4.12.6a", get = function() return getDB("insightPlayerNameGradient", false) end, set = function(v) setDB("insightPlayerNameGradient", v) end, visibleWhen = function() return getDB("insightPlayerNameColor", "faction") == "class" end },
            { type = "toggle", name = L["GUILD_RANK"] or "Guild rank", desc = L["AXIS_APPEND_PLAYER_S_GUILD_RANK_NEXT"] or "Append the player's guild rank next to their guild name.", dbKey = "insightShowGuildRank", get = function() return getDB("insightShowGuildRank", true) end, set = function(v) setDB("insightShowGuildRank", v) end },
            { type = "toggle", name = L["AXIS_CHARACTER_TITLE"] or "Character title", desc = L["AXIS_PLAYER_S_SELECTED_TITLE_ACHIEVEMENT_PVP"] or "Show the player's selected title (achievement or PvP) in the name line.", dbKey = "insightShowCharacterTitle", get = function() return getDB("insightShowCharacterTitle", true) end, set = function(v) setDB("insightShowCharacterTitle", v) end, refreshIds = { "insightTitleColor" } },
            { type = "color", name = L["AXIS_TITLE_COLOUR"] or "Title color", desc = L["AXIS_COLOUR_OF_CHARACTER_TITLE_PLAYER_TOOLTIP"] or "Color of the character title in the player tooltip name line.", dbKey = "insightTitleColor", default = { 1.00, 0.82, 0.00 }, visibleWhen = function() return getDB("insightShowCharacterTitle", true) end },
            { type = "section", name = L["INSIGHT_SECTION_STATUS_PVP"] or "Status & PvP" },
            { type = "toggle", name = L["STATUS_BADGES"] or "Status badges", desc = L["COMBAT_AFK_DND_PVP_PARTY_FRIENDS"], dbKey = "insightShowStatusBadges", get = function() return getDB("insightShowStatusBadges", true) end, set = function(v) setDB("insightShowStatusBadges", v) end },
            { type = "toggle", name = L["HONOR_LEVEL"] or "Honor level", desc = L["AXIS_PLAYER_S_PVP_HONOR_LEVEL_TOOLTIP"] or "Show the player's PvP honor level in the tooltip.", dbKey = "insightShowHonorLevel", get = function() return getDB("insightShowHonorLevel", true) end, set = function(v) setDB("insightShowHonorLevel", v) end },
            { type = "section", name = L["INSIGHT_SECTION_RATINGS_GEAR"] or "Ratings & gear" },
            { type = "toggle", name = L["MYTHIC_SCORE"] or "Mythic+ score", desc = L["AXIS_PLAYER_S_CURRENT_SEASON_MYTHIC_SCORE"] or "Show the player's current season Mythic+ score, colour-coded by tier.", dbKey = "insightShowMythicScore", get = function() return getDB("insightShowMythicScore", true) end, set = function(v) setDB("insightShowMythicScore", v) end },
            { type = "toggle", name = L["ITEM_LEVEL"] or "Item level", desc = L["AXIS_PLAYER_S_EQUIPPED_ITEM_LEVEL_AFTER"] or "Show the player's equipped item level after inspecting them.", dbKey = "insightShowIlvl", get = function() return getDB("insightShowIlvl", true) end, set = function(v) setDB("insightShowIlvl", v) end },
            { type = "toggle", name = L["INSIGHT_SPEC_ROLE"] or "Spec icon & role", desc = L["INSIGHT_SPEC_ROLE_DESC"] or "Show the player's specialization icon and role after inspecting them. Disable to stop Insight from calling NotifyInspect on mouseover.", dbKey = "insightShowSpecRole", get = function() return getDB("insightShowSpecRole", true) end, set = function(v) setDB("insightShowSpecRole", v) end },
            { type = "section", name = L["INSIGHT_SECTION_MOUNT"] or "Mount" },
            { type = "toggle", name = L["MOUNT_INFO"] or "Mount info", desc = L["MOUNT_NAME_SOURCE_COLLECTION_STATUS"], dbKey = "insightShowMount", get = function() return getDB("insightShowMount", true) end, set = function(v) setDB("insightShowMount", v) end, tooltip = L["SHOWN_HOVERING_A_MOUNTED_PLAYER"] },
            { type = "dropdown", name = L["INSIGHT_MOUNT_OWNERSHIP_DISPLAY"] or "Mount collection indicator", desc = L["INSIGHT_MOUNT_OWNERSHIP_DISPLAY_DESC"] or "How to show whether you have collected the hovered player's mount.", dbKey = "insightMountOwnershipDisplay", options = { { L["INSIGHT_MOUNT_OWNERSHIP_TEXT"] or "Full text", "text" }, { L["INSIGHT_MOUNT_OWNERSHIP_ICONS"] or "Tick / cross", "icons" } }, get = function() return getDB("insightMountOwnershipDisplay", "text") end, set = function(v) setDB("insightMountOwnershipDisplay", v) end, visibleWhen = function() return getDB("insightShowMount", true) end },
            { type = "section", name = L["AXIS_ICONS"] or "Icons" },
            { type = "dropdown", name = L["AXIS_CLASS_ICON_STYLE"] or "Class icon style", desc = L["AXIS_DEFAULT_BLIZZARD_RONDOMEDIA_CLASS_ICONS_TH"] or "Use Default (Blizzard) or RondoMedia class icons on the class/spec line.", tooltip = L["AXIS_CLASS_ICON_SOURCES_TOOLTIP"], dbKey = "insightClassIconSource", options = { { L["AXIS_CUSTOM_CLASS_ICONS_LABEL"] or "Horizon", "custom" }, { L["AXIS_DEFAULT"] or "Default", "default" }, { "RondoMedia", "rondomedia" } }, get = function() return getDB("insightClassIconSource", "custom") end, set = function(v) setDB("insightClassIconSource", v) end, visibleWhen = function() return getDB("insightShowIcons", true) end },
            { type = "section", name = L["FOCUS_FONT_SIZES"] or "Font sizes" },
            { type = "slider", name = L["FOCUS_HEADER_SIZE"] or "Header size",   desc = L["FOCUS_HEADER_FONT_SIZE"] or "Header font size for player tooltips.",                                dbKey = "insightPlayerHeaderSize",  min = 8, max = 24, get = function() return getDB("insightPlayerHeaderSize",  14) end, set = function(v) setDB("insightPlayerHeaderSize",  v) end },
            { type = "slider", name = L["INSIGHT_BODY_SIZE"] or "Body size",     desc = L["INSIGHT_BODY_FONT_SIZE"] or "Body font size for player tooltips.",                                  dbKey = "insightPlayerBodySize",    min = 8, max = 20, get = function() return getDB("insightPlayerBodySize",    12) end, set = function(v) setDB("insightPlayerBodySize",    v) end },
            { type = "slider", name = L["INSIGHT_BADGES_SIZE"] or "Badges size", desc = L["INSIGHT_BADGES_FONT_SIZE"] or "Status badges font size for player tooltips.",                      dbKey = "insightPlayerBadgesSize",  min = 6, max = 20, get = function() return getDB("insightPlayerBadgesSize",  12) end, set = function(v) setDB("insightPlayerBadgesSize",  v) end },
            { type = "slider", name = L["INSIGHT_STATS_SIZE"] or "Stats size",   desc = L["INSIGHT_STATS_FONT_SIZE"] or "M+ score, item level, and honor level font size for player tooltips.", dbKey = "insightPlayerStatsSize",  min = 6, max = 20, get = function() return getDB("insightPlayerStatsSize",   11) end, set = function(v) setDB("insightPlayerStatsSize",   v) end },
            { type = "slider", name = L["INSIGHT_MOUNT_SIZE"] or "Mount size",   desc = L["INSIGHT_MOUNT_FONT_SIZE"] or "Mount name, source, and ownership font size for player tooltips.",   dbKey = "insightPlayerMountSize",   min = 6, max = 20, get = function() return getDB("insightPlayerMountSize",   11) end, set = function(v) setDB("insightPlayerMountSize",   v) end },
        },
    },
    {
        key = "InsightNpc",
        name = L["INSIGHT_CATEGORY_NPC"] or "NPCs",
        desc = L["INSIGHT_CATEGORY_NPC_DESC"] or "NPC tooltip styling. Extra NPC-only toggles can be added here later.",
        moduleKey = "insight",
        dashboardPreviewMode = "npc",
        options = {
            { type = "section", name = L["INSIGHT_SECTION_NPC_TOOLTIP"] or "NPC tooltip" },
            { type = "toggle", name = L["INSIGHT_NPC_REACTION_BORDER"] or "Reaction border", desc = L["INSIGHT_NPC_REACTION_BORDER_DESC"] or "Tint the tooltip border to the NPC's faction reaction (hostile red, friendly green, neutral yellow).", dbKey = "insightNpcReactionBorder", get = function() return getDB("insightNpcReactionBorder", true) end, set = function(v) setDB("insightNpcReactionBorder", v) end },
            { type = "toggle", name = L["INSIGHT_NPC_REACTION_NAME"] or "Reaction name colour", desc = L["INSIGHT_NPC_REACTION_NAME_DESC"] or "Colour the NPC's name to match their faction reaction.", dbKey = "insightNpcReactionName", get = function() return getDB("insightNpcReactionName", true) end, set = function(v) setDB("insightNpcReactionName", v) end },
            { type = "toggle", name = L["INSIGHT_NPC_LEVEL_LINE"] or "Level line", desc = L["INSIGHT_NPC_LEVEL_LINE_DESC"] or "Show the NPC's level, classification (Elite, Rare, etc.), and creature type beneath their name.", dbKey = "insightNpcShowLevelLine", get = function() return getDB("insightNpcShowLevelLine", true) end, set = function(v) setDB("insightNpcShowLevelLine", v) end },
            { type = "toggle", name = L["AXIS_ICONS"] or "Icons", desc = L["INSIGHT_NPC_ICONS_DESC"] or "Show an icon instead of '??' for NPCs with an unknown level.", dbKey = "insightNpcShowIcons", get = function() return getDB("insightNpcShowIcons", true) end, set = function(v) setDB("insightNpcShowIcons", v) end },
            { type = "section", name = L["FOCUS_FONT_SIZES"] or "Font sizes" },
            { type = "slider", name = L["FOCUS_HEADER_SIZE"] or "Header size", desc = L["FOCUS_HEADER_FONT_SIZE"] or "Header font size for NPC tooltips.", dbKey = "insightNpcHeaderSize", min = 8, max = 24, get = function() return getDB("insightNpcHeaderSize", 14) end, set = function(v) setDB("insightNpcHeaderSize", v) end },
            { type = "slider", name = L["INSIGHT_BODY_SIZE"] or "Body size",   desc = L["INSIGHT_BODY_FONT_SIZE"] or "Body font size for NPC tooltips.",   dbKey = "insightNpcBodySize",   min = 8, max = 20, get = function() return getDB("insightNpcBodySize",   12) end, set = function(v) setDB("insightNpcBodySize",   v) end },
        },
    },
    {
        key = "InsightItem",
        name = L["INSIGHT_CATEGORY_ITEM"] or "Items",
        desc = L["INSIGHT_CATEGORY_ITEM_DESC"] or "Item tooltip options such as transmog collection status.",
        moduleKey = "insight",
        dashboardPreviewMode = "item",
        options = {
            { type = "section", name = L["INSIGHT_SECTION_TRANSMOG"] or "Transmog" },
            { type = "toggle", name = L["TRANSMOG_STATUS"] or "Transmog status", desc = L["AXIS_WHETHER_YOU_COLLECTED_APPEARANCE_OF_AN"] or "Show whether you have collected the appearance of an item you hover over.", dbKey = "insightShowTransmog", get = function() return getDB("insightShowTransmog", true) end, set = function(v) setDB("insightShowTransmog", v) end },
            { type = "section", name = L["INSIGHT_SECTION_ITEM_STYLING"] or "Item styling" },
            { type = "toggle", name = L["INSIGHT_ITEM_QUALITY_BORDER"] or "Quality border", desc = L["INSIGHT_ITEM_QUALITY_BORDER_DESC"] or "Tint the tooltip border to the item's quality colour (Uncommon green, Rare blue, Epic purple, etc.).", dbKey = "insightItemQualityBorder", get = function() return getDB("insightItemQualityBorder", true) end, set = function(v) setDB("insightItemQualityBorder", v) end },
            { type = "toggle", name = L["INSIGHT_ITEM_NAME_GRADIENT"] or "Quality gradient name", desc = L["INSIGHT_ITEM_NAME_GRADIENT_DESC"] or "Render the item name as a two-stop gradient of its quality colour (Uncommon green, Rare blue, Epic purple, etc.).", dbKey = "insightItemNameGradient", isNew = "4.12.6a", get = function() return getDB("insightItemNameGradient", false) end, set = function(v) setDB("insightItemNameGradient", v) end },
            { type = "toggle", name = L["INSIGHT_ITEM_SECTION_SPACING"] or "Blank line before blocks", desc = L["INSIGHT_ITEM_SECTION_SPACING_DESC"] or "Insert a blank line before Insight blocks on item tooltips instead of a tinted separator line.", dbKey = "insightItemSectionSpacing", get = function() return getDB("insightItemSectionSpacing", false) end, set = function(v) setDB("insightItemSectionSpacing", v) end },
            { type = "section", name = L["FOCUS_FONT_SIZES"] or "Font sizes" },
            { type = "slider", name = L["FOCUS_HEADER_SIZE"] or "Header size", desc = L["FOCUS_HEADER_FONT_SIZE"] or "Header font size for item tooltips (item name line).",        dbKey = "insightItemHeaderSize", min = 8, max = 24, get = function() return getDB("insightItemHeaderSize", 14) end, set = function(v) setDB("insightItemHeaderSize", v) end },
            { type = "slider", name = L["INSIGHT_BODY_SIZE"] or "Body size",   desc = L["INSIGHT_BODY_FONT_SIZE"] or "Body font size for item tooltips (stats and middle zone).", dbKey = "insightItemBodySize",   min = 8, max = 20, get = function() return getDB("insightItemBodySize",   12) end, set = function(v) setDB("insightItemBodySize",   v) end },
            { type = "slider", name = L["INSIGHT_TRANSMOG_SIZE"] or "Transmog size", desc = L["INSIGHT_TRANSMOG_FONT_SIZE"] or "Item appearance status font size.", dbKey = "insightItemTransmogSize", min = 6, max = 20, get = function() return getDB("insightItemTransmogSize", getDB("insightTransmogSize", 11)) end, set = function(v) setDB("insightItemTransmogSize", v) end },
        },
    },
    {
        key       = "Essence",
        name      = "Character Sheet",
        desc      = "Custom character panel with 3D model, item level, secondary stats, and gear slots.",
        moduleKey = "essence",
        options   = {
            { type = "section", name = "Position" },
            { type = "toggle", name = "Lock position", desc = "Prevent dragging the panel.", dbKey = "essenceLockPosition", get = function() return getDB("essenceLockPosition", false) end, set = function(v) setDB("essenceLockPosition", v) end },
            { type = "button", name = "Reset position", desc = "Snap the panel back to screen centre.", onClick = function()
                setDB("essencePoint", "CENTER"); setDB("essenceX", 0); setDB("essenceY", 0)
                if addon.Essence and addon.Essence.ApplyPosition then addon.Essence.ApplyPosition(true) end
            end },
            { type = "section", name = "Appearance" },
            { type = "toggle", name = "PvP title", desc = "Show the character's PvP title above the identity line.", dbKey = "essenceShowTitle", get = function() return getDB("essenceShowTitle", true) end, set = function(v) setDB("essenceShowTitle", v) end },
            { type = "toggle", name = "Secondary stat bars", desc = "Show Crit, Haste, Mastery, and Versatility bars.", dbKey = "essenceShowStatBars", get = function() return getDB("essenceShowStatBars", true) end, set = function(v) setDB("essenceShowStatBars", v) end },
            { type = "toggle", name = "Item level badge on gear slots", desc = "Show the item level on each equipped gear slot.", dbKey = "essenceShowIlvlBadge", get = function() return getDB("essenceShowIlvlBadge", true) end, set = function(v) setDB("essenceShowIlvlBadge", v) end },
            { type = "slider", name = "Stat bar cap (%)", desc = "The percentage shown as a full bar. Lower = more detail at common stat values.", dbKey = "essenceStatCap", min = 20, max = 100, step = 5, get = function() return tonumber(getDB("essenceStatCap", 50)) or 50 end, set = function(v) setDB("essenceStatCap", math.max(20, math.min(100, v))) end },
        },
    },
    {
        key = "VistaMinimap",
        name = L["VISTA_DESC"] or "Minimap",
        desc = L["CONFIGURE_MINIMAP_S_SHAPE_SIZE_POSITION"] or "Configure the minimap's shape, size, position, and text overlays.",
        moduleKey = "vista",
        options = {
            { type = "section", name = L["SIZE_SHAPE"] or "Size & shape" },
            { type = "slider", name = L["VISTA_SIZE"] or "Minimap size",
              desc = L["VISTA_WIDTH_HEIGHT_OF_MINIMAP_PIXELS"] or "Width and height of the minimap in pixels (100–400).",
              dbKey = "vistaMapSize", min = 100, max = 400,
              get = function() return math.max(100, math.min(400, tonumber(getDB("vistaMapSize", 200)) or 200)) end,
              set = function(v) setDB("vistaMapSize", math.max(100, math.min(400, v))) end },
            { type = "toggle", name = L["VISTA_CIRCULAR_SHAPE"] or "Circular shape",
              desc = L["VISTA_A_CIRCULAR_MINIMAP_INSTEAD_OF_SQUARE"] or "Use a circular minimap instead of square.",
              dbKey = "vistaCircular",
              get = function() return getDB("vistaCircular", false) end,
              set = function(v) setDB("vistaCircular", v) end },
            { type = "section", name = L["AXIS_POSITION"] or "Position" },
            { type = "toggle", name = L["LOCK_MINIMAP"] or "Lock minimap",
              desc = L["VISTA_PREVENT_DRAGGING_MINIMAP"] or "Prevent dragging the minimap.",
              dbKey = "vistaLock",
              get = function() return getDB("vistaLock", true) end,
              set = function(v) setDB("vistaLock", v) end },
            { type = "button", name = L["VISTA_RESET_MINIMAP_POSITION"] or "Reset minimap position",
              desc = L["VISTA_RESET_MINIMAP_DEFAULT_POSITION_TOP_RIGHT"] or "Reset minimap to its default position (top-right).",
              onClick = function()
                  if addon.Vista and addon.Vista.ResetMinimapPosition then
                      addon.Vista.ResetMinimapPosition()
                  end
              end },
            { type = "section", name = L["VISTA_AUTO_ZOOM"] or "Auto Zoom" },
            { type = "slider", name = L["VISTA_AUTO_ZOOM_DELAY"] or "Auto zoom-out delay",
              desc = L["VISTA_SECONDS_AFTER_ZOOMING_BEFORE_AUTO_ZOOM"] or "Seconds after zooming before auto zoom-out fires. Set to 0 to disable.",
              dbKey = "vistaAutoZoom", min = 0, max = 30,
              get = function() return math.max(0, math.min(30, tonumber(getDB("vistaAutoZoom", 5)) or 5)) end,
              set = function(v) setDB("vistaAutoZoom", math.max(0, math.min(30, v))) end },
            { type = "section", name = L["VISTA_TEXT_ELEMENTS"] or "Text Elements" },
            { type = "toggle", name = L["VISTA_ZONE_TEXT"] or "Show zone text",
              desc = L["VISTA_ZONE_NAME_BELOW_MINIMAP"] or "Show the zone name below the minimap.",
              dbKey = "vistaShowZoneText",
              get = function() return getDB("vistaShowZoneText", true) end,
              set = function(v) setDB("vistaShowZoneText", v) end },
            { type = "dropdown", name = L["VISTA_ZONE_TEXT_DISPLAY_MODE"] or "Zone text display mode",
              desc = L["VISTA_WHAT_ZONE_SUBZONE"] or "What to show: zone only, subzone only, or both.",
              dbKey = "vistaZoneDisplayMode",
              options = function() return {
                  { L["VISTA_SHOW_ZONE"] or "Zone only", "zone" },
                  { L["VISTA_SHOW_SUBZONE"] or "Subzone only", "subzone" },
                  { L["VISTA_SHOW_ZONE_AND_SUBZONE"] or "Both", "both" },
              } end,
              get = function() return getDB("vistaZoneDisplayMode", "zone") end,
              set = function(v) setDB("vistaZoneDisplayMode", v) end,
              disabled = function() return not getDB("vistaShowZoneText", true) end },
            { type = "toggle", name = L["VISTA_COORDINATES"] or "Show coordinates",
              desc = L["VISTA_PLAYER_COORDINATES_BELOW_MINIMAP"] or "Show player coordinates below the minimap.",
              dbKey = "vistaShowCoordText",
              get = function() return getDB("vistaShowCoordText", true) end,
              set = function(v) setDB("vistaShowCoordText", v) end },
            { type = "toggle", name = L["VISTA_TIME"] or "Show time",
              desc = L["VISTA_CURRENT_GAME_BELOW_MINIMAP"] or "Show current game time below the minimap.",
              dbKey = "vistaShowTimeText",
              get = function() return getDB("vistaShowTimeText", true) end,
              set = function(v) setDB("vistaShowTimeText", v) end },
            { type = "toggle", name = L["VISTA_FPS_LATENCY"] or "Show FPS and latency",
              desc = L["VISTA_FPS_LATENCY_MS_BELOW_MINIMAP"] or "Show FPS and latency (ms) below the minimap.",
              dbKey = "vistaShowPerfText",
              get = function() return getDB("vistaShowPerfText", false) end,
              set = function(v) setDB("vistaShowPerfText", v) end },
            { type = "toggle", name = L["VISTA_LOCAL_TIME"] or "Use local time",
              desc = L["LOCAL_SYSTEM"] or "Show local system time.",
              tooltip = L["VISTA_LOCAL_TIME_TIP"] or "When on, shows your local system time. When off, shows server time.",
              dbKey = "vistaTimeUseLocal",
              get = function() return getDB("vistaTimeUseLocal", true) end,
              set = function(v) setDB("vistaTimeUseLocal", v) end,
              disabled = function() return not getDB("vistaShowTimeText", true) end },
            { type = "toggle", name = L["VISTA_HOUR_CLOCK"] or "24-hour clock",
              desc = L["VISTA_DISPLAY_HOUR_FORMAT_24"] or "Display time in 24-hour format (e.g. 14:30 instead of 2:30 PM).",
              dbKey = "vistaTime24Hour",
              get = function() return getDB("vistaTime24Hour", false) end,
              set = function(v) setDB("vistaTime24Hour", v) end,
              disabled = function() return not getDB("vistaShowTimeText", true) end },
            { type = "section", name = L["VISTA_MINIMAP_BUTTONS"] or "Minimap Buttons" },
            { type = "header", name = L["VISTA_QUEUE_STATUS_MAIL_INDICATOR_ALWAYS_SHOWN"] or "Queue status and mail indicator are always shown when relevant." },
            { type = "toggle", name = L["VISTA_TRACKING_BUTTON"] or "Show tracking button",
              desc = L["VISTA_MINIMAP_TRACKING_BUTTON"] or "Show the minimap tracking button.",
              dbKey = "vistaShowTracking",
              get = function() return getDB("vistaShowTracking", true) end,
              set = function(v) setDB("vistaShowTracking", v) end,
              refreshIds = { "vistaMouseoverTracking" } },
            { type = "toggle", name = L["VISTA_TRACKING_BUTTON_MOUSEOVER"] or "Tracking button on mouseover only",
              desc = L["HOVER"] or "Show only on hover.",
              tooltip = L["VISTA_HIDE_TRACKING_BUTTON_UNTIL_YOU_HOVER"] or "Hide tracking button until you hover over the minimap.",
              dbKey = "vistaMouseoverTracking",
              get = function() return getDB("vistaMouseoverTracking", true) end,
              set = function(v) setDB("vistaMouseoverTracking", v) end,
              disabled = function() return not getDB("vistaShowTracking", true) end },
            { type = "toggle", name = L["VISTA_CALENDAR_BUTTON"] or "Show calendar button",
              desc = L["VISTA_MINIMAP_CALENDAR_BUTTON"] or "Show the minimap calendar button.",
              dbKey = "vistaShowCalendar",
              get = function() return getDB("vistaShowCalendar", true) end,
              set = function(v) setDB("vistaShowCalendar", v) end,
              refreshIds = { "vistaMouseoverCalendar" } },
            { type = "toggle", name = L["VISTA_CALENDAR_BUTTON_MOUSEOVER"] or "Calendar button on mouseover only",
              desc = L["VISTA_HIDE_CALENDAR_BUTTON_UNTIL_YOU_HOVER"] or "Hide calendar button until you hover over the minimap.",
              dbKey = "vistaMouseoverCalendar",
              get = function() return getDB("vistaMouseoverCalendar", true) end,
              set = function(v) setDB("vistaMouseoverCalendar", v) end,
              disabled = function() return not getDB("vistaShowCalendar", true) end },
        },
    },
    {
        key = "VistaAppearance",
        name = L["DASH_APPEARANCE"] or "Appearance",
        desc = L["VISTA_CUSTOMISE_BORDERS_COLOURS_POSITIONING"] or "Customize borders, colors, and the positioning of specific minimap elements.",
        moduleKey = "vista",
        options = function()
            local GLOBAL_SENTINEL = "__global__"
            local GLOBAL_LABEL = L["FOCUS_GLOBAL_FONT"] or "Use global font"

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
            { type = "section", name = L["VISTA_BORDER"] or "Border" },
            { type = "toggle", name = L["FOCUS_BORDER"] or "Show border",
              desc = L["VISTA_BORDER_TIP"] or "Show a border around the minimap.",
              dbKey = "vistaBorderShow",
              get = function() return getDB("vistaBorderShow", true) end,
              set = function(v) setDB("vistaBorderShow", v) end },
            { type = "color", name = L["VISTA_BORDER_COLOUR"] or "Border color",
              desc = L["VISTA_COLOUR_OPACITY_OF_MINIMAP_BORDER"] or "Color (and opacity) of the minimap border.",
              dbKey = "vistaBorderColor",
              get = function()
                  return getDB("vistaBorderColorR", 1), getDB("vistaBorderColorG", 1),
                         getDB("vistaBorderColorB", 1), getDB("vistaBorderColorA", 0.15)
              end,
              set = function(r, g, b, a)
                  setDB("vistaBorderColorR", r); setDB("vistaBorderColorG", g)
                  setDB("vistaBorderColorB", b)
                  if a ~= nil then setDB("vistaBorderColorA", a) end
              end,
              hasAlpha = true },
            { type = "slider", name = L["VISTA_BORDER_THICKNESS"] or "Border thickness",
              desc = L["VISTA_THICKNESS_OF_MINIMAP_BORDER_PIXELS"] or "Thickness of the minimap border in pixels (1–8).",
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
            { type = "section", name = L["VISTA_TEXT_POSITIONS"] or "Text Positions" },
            { type = "header", name = L["VISTA_DRAG_TEXT_ELEMENTS_REPOSITION_LOCK_PREVEN"] or "Drag text elements to reposition them. Lock to prevent accidental movement." },
            { type = "dropdown", name = L["VISTA_LOCATION_POSITION"] or "Location position",
              desc = L["VISTA_PLACE_ZONE_NAME_ABOVE_BELOW_MINIMAP"] or "Place the zone name above or below the minimap.",
              dbKey = "vistaZoneVerticalPos",
              options = function() return { { L["FOCUS_MYTHICPLUS_POSITION_TOP"] or "Top", "top" }, { L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"] or "Bottom", "bottom" } } end,
              get = function() return getDB("vistaZoneVerticalPos", "bottom") or "bottom" end,
              set = function(v)
                  setDB("vistaZoneVerticalPos", v)
                  setDB("vistaEX_zone", nil); setDB("vistaEY_zone", nil)
              end },
            { type = "toggle", name = L["VISTA_LOCK_ZONE_TEXT_POSITION"] or "Lock zone text position",
              desc = L["VISTA_ZONE_TEXT_CANNOT_DRAGGED"] or "When on, the zone text cannot be dragged.",
              dbKey = "vistaLocked_zone",
              get = function() return getDB("vistaLocked_zone", true) end,
              set = function(v) setDB("vistaLocked_zone", v) end },
            { type = "dropdown", name = L["VISTA_COORDINATES_POSITION"] or "Coordinates position",
              desc = L["VISTA_PLACE_COORDINATES_ABOVE_BELOW_MINIMAP"] or "Place the coordinates above or below the minimap.",
              dbKey = "vistaCoordVerticalPos",
              options = function() return { { L["FOCUS_MYTHICPLUS_POSITION_TOP"] or "Top", "top" }, { L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"] or "Bottom", "bottom" } } end,
              get = function() return getDB("vistaCoordVerticalPos", "bottom") or "bottom" end,
              set = function(v)
                  setDB("vistaCoordVerticalPos", v)
                  setDB("vistaEX_coord", nil); setDB("vistaEY_coord", nil)
              end },
            { type = "toggle", name = L["VISTA_LOCK_COORDINATES_POSITION"] or "Lock coordinates position",
              desc = L["VISTA_COORDINATES_TEXT_CANNOT_DRAGGED"] or "When on, the coordinates text cannot be dragged.",
              dbKey = "vistaLocked_coord",
              get = function() return getDB("vistaLocked_coord", true) end,
              set = function(v) setDB("vistaLocked_coord", v) end },
            { type = "dropdown", name = L["VISTA_CLOCK_POSITION"] or "Clock position",
              desc = L["VISTA_PLACE_CLOCK_ABOVE_BELOW_MINIMAP"] or "Place the clock above or below the minimap.",
              dbKey = "vistaTimeVerticalPos",
              options = function() return { { L["FOCUS_MYTHICPLUS_POSITION_TOP"] or "Top", "top" }, { L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"] or "Bottom", "bottom" } } end,
              get = function() return getDB("vistaTimeVerticalPos", "bottom") or "bottom" end,
              set = function(v)
                  setDB("vistaTimeVerticalPos", v)
                  setDB("vistaEX_time", nil); setDB("vistaEY_time", nil)
              end },
            { type = "toggle", name = L["VISTA_LOCK_POSITION"] or "Lock time position",
              desc = L["VISTA_TEXT_CANNOT_DRAGGED"] or "When on, the time text cannot be dragged.",
              dbKey = "vistaLocked_time",
              get = function() return getDB("vistaLocked_time", true) end,
              set = function(v) setDB("vistaLocked_time", v) end },
            { type = "dropdown", name = L["VISTA_PERFORMANCE_TEXT_POSITION"] or "Performance text position",
              desc = L["VISTA_PLACE_FPS_LATENCY_TEXT_ABOVE_BELOW"] or "Place the FPS/latency text above or below the minimap.",
              dbKey = "vistaPerfVerticalPos",
              options = function() return { { L["FOCUS_MYTHICPLUS_POSITION_TOP"] or "Top", "top" }, { L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"] or "Bottom", "bottom" } } end,
              get = function() return getDB("vistaPerfVerticalPos", "bottom") or "bottom" end,
              set = function(v)
                  setDB("vistaPerfVerticalPos", v)
                  setDB("vistaEX_perf", nil); setDB("vistaEY_perf", nil)
              end,
              disabled = function() return not getDB("vistaShowPerfText", false) end },
            { type = "toggle", name = L["VISTA_LOCK_PERFORMANCE_TEXT_POSITION"] or "Lock performance text position",
              desc = L["VISTA_FPS_LATENCY_TEXT_CANNOT_DRAGGED"] or "When on, the FPS/latency text cannot be dragged.",
              dbKey = "vistaLocked_perf",
              get = function() return getDB("vistaLocked_perf", true) end,
              set = function(v) setDB("vistaLocked_perf", v) end,
              disabled = function() return not getDB("vistaShowPerfText", false) end },
            { type = "dropdown", name = L["VISTA_DIFFICULTY_TEXT_POSITION"] or "Difficulty text position",
              desc = L["VISTA_PLACE_DIFFICULTY_TEXT_ABOVE_BELOW"] or "Place the instance difficulty text above or below the minimap.",
              dbKey = "vistaDiffVerticalPos",
              options = function() return { { L["FOCUS_MYTHICPLUS_POSITION_TOP"] or "Top", "top" }, { L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"] or "Bottom", "bottom" } } end,
              get = function() return getDB("vistaDiffVerticalPos", "bottom") or "bottom" end,
              set = function(v)
                  setDB("vistaDiffVerticalPos", v)
                  setDB("vistaEX_diff", nil); setDB("vistaEY_diff", nil)
              end },
            { type = "toggle", name = L["VISTA_LOCK_DIFFICULTY_TEXT_POSITION"] or "Lock difficulty text position",
              desc = L["VISTA_DIFFICULTY_TEXT_CANNOT_DRAGGED"] or "When on, the difficulty text cannot be dragged.",
              dbKey = "vistaLocked_diff",
              get = function() return getDB("vistaLocked_diff", false) end,
              set = function(v) setDB("vistaLocked_diff", v) end },
            { type = "section", name = L["VISTA_BUTTON_POSITIONS"] or "Button Positions" },
            { type = "header", name = L["VISTA_DRAG_BUTTONS_REPOSITION_LOCK_PREVENT_MOVE"] or "Drag buttons to reposition them. Lock to prevent movement." },
            { type = "button", name = L["VISTA_RESET_OVERLAY_POSITIONS"] or "Reset overlay positions to defaults",
              desc = L["VISTA_RESET_OVERLAY_POSITIONS_DESC"] or "Clear saved positions for zone text, coordinates, clock, performance and difficulty text, tracking, calendar, queue, mail, the addon button bar, drawer button, and right-click panel. The minimap frame position is not changed.",
              onClick = function()
                  if addon.Vista and addon.Vista.ResetOverlayPositionsToDefaults then
                      addon.Vista.ResetOverlayPositionsToDefaults()
                  end
              end },
            { type = "toggle", name = L["VISTA_LOCK_TRACKING_BUTTON"] or "Lock Tracking button",
              desc = L["VISTA_PREVENT_DRAGGING_TRACKING_BUTTON"] or "Prevent dragging the tracking button.",
              dbKey = "vistaLocked_proxy_tracking",
              get = function() return getDB("vistaLocked_proxy_tracking", true) end,
              set = function(v) setDB("vistaLocked_proxy_tracking", v) end },
            { type = "toggle", name = L["VISTA_LOCK_CALENDAR_BUTTON"] or "Lock Calendar button",
              desc = L["VISTA_PREVENT_DRAGGING_CALENDAR_BUTTON"] or "Prevent dragging the calendar button.",
              dbKey = "vistaLocked_proxy_calendar",
              get = function() return getDB("vistaLocked_proxy_calendar", true) end,
              set = function(v) setDB("vistaLocked_proxy_calendar", v) end },
            { type = "toggle", name = L["VISTA_LOCK_QUEUE_BUTTON"] or "Lock Queue button",
              desc = L["VISTA_PREVENT_DRAGGING_QUEUE_STATUS_BUTTON"] or "Prevent dragging the queue status button.",
              dbKey = "vistaLocked_proxy_queue",
              get = function() return getDB("vistaLocked_proxy_queue", true) end,
              set = function(v) setDB("vistaLocked_proxy_queue", v) end },
            { type = "toggle", name = L["VISTA_LOCK_MAIL_INDICATOR"] or "Lock Mail indicator",
              desc = L["VISTA_PREVENT_DRAGGING_MAIL_ICON"] or "Prevent dragging the mail icon.",
              dbKey = "vistaLocked_proxy_mail",
              get = function() return getDB("vistaLocked_proxy_mail", true) end,
              set = function(v) setDB("vistaLocked_proxy_mail", v) end },
            { type = "toggle", name = L["VISTA_LOCK_CRAFTING_ORDER_INDICATOR"] or "Lock Crafting Order indicator",
              desc = L["VISTA_PREVENT_DRAGGING_CRAFTING_ORDER_ICON"] or "Prevent dragging the crafting order icon.",
              dbKey = "vistaLocked_proxy_craftingOrder",
              get = function() return getDB("vistaLocked_proxy_craftingOrder", true) end,
              set = function(v) setDB("vistaLocked_proxy_craftingOrder", v) end },
            { type = "toggle", name = L["VISTA_DISABLE_QUEUE_HANDLING"] or "Disable queue handling",
              desc = L["VISTA_TURN_QUEUE_BUTTON_ANCHORING_OFF_ADDON_CONFLICT"] or "Turn off all queue button anchoring (use if another addon manages it).",
              dbKey = "vistaQueueHandlingDisabled",
              get = function() return getDB("vistaQueueHandlingDisabled", false) end,
              set = function(v) setDB("vistaQueueHandlingDisabled", v) end },
            { type = "section", name = L["VISTA_BUTTON_SIZES"] or "Button Sizes" },
            { type = "header", name = L["VISTA_ADJUST_SIZE_OF_MINIMAP_OVERLAY_BUTTONS"] or "Adjust the size of minimap overlay buttons." },
            { type = "slider", name = L["VISTA_TRACKING_BUTTON_SIZE"] or "Tracking button size",
              desc = L["VISTA_SIZE_OF_TRACKING_BUTTON_PIXELS"] or "Size of the tracking button (pixels).",
              dbKey = "vistaTrackingBtnSize", min = 14, max = 40,
              get = function() return math.max(14, math.min(40, tonumber(getDB("vistaTrackingBtnSize", 22)) or 22)) end,
              set = function(v) setDB("vistaTrackingBtnSize", math.max(14, math.min(40, v))) end },
            { type = "slider", name = L["VISTA_CALENDAR_BUTTON_SIZE"] or "Calendar button size",
              desc = L["VISTA_SIZE_OF_CALENDAR_BUTTON_PIXELS"] or "Size of the calendar button (pixels).",
              dbKey = "vistaCalendarBtnSize", min = 14, max = 40,
              get = function() return math.max(14, math.min(40, tonumber(getDB("vistaCalendarBtnSize", 22)) or 22)) end,
              set = function(v) setDB("vistaCalendarBtnSize", math.max(14, math.min(40, v))) end },
            { type = "slider", name = L["VISTA_QUEUE_BUTTON_SIZE"] or "Queue button size",
              desc = L["VISTA_SIZE_OF_QUEUE_STATUS_BUTTON_PIXELS"] or "Size of the queue status button (pixels).",
              dbKey = "vistaQueueBtnSize", min = 14, max = 40,
              get = function() return math.max(14, math.min(40, tonumber(getDB("vistaQueueBtnSize", 22)) or 22)) end,
              set = function(v) setDB("vistaQueueBtnSize", math.max(14, math.min(40, v))) end },
            { type = "slider", name = L["VISTA_MAIL_INDICATOR_SIZE"] or "Mail indicator size",
              desc = L["VISTA_SIZE_OF_MAIL_ICON_PIXELS"] or "Size of the new mail icon (pixels).",
              dbKey = "vistaMailIconSize", min = 14, max = 40,
              get = function() return math.max(14, math.min(40, tonumber(getDB("vistaMailIconSize", 20)) or 20)) end,
              set = function(v) setDB("vistaMailIconSize", math.max(14, math.min(40, v))) end },
            { type = "toggle", name = L["MAIL_ICON_PULSE"] or "Mail icon pulse",
              desc = L["VISTA_MAIL_ICON_PULSES_DRAW_ATTENTION"] or "When on, the mail icon pulses to draw attention. When off, it stays at full opacity.",
              dbKey = "vistaMailBlink",
              get = function() return getDB("vistaMailBlink", true) end,
              set = function(v) setDB("vistaMailBlink", v) end },
            { type = "slider", name = L["VISTA_CRAFTING_ORDER_INDICATOR_SIZE"] or "Crafting Order indicator size",
              desc = L["VISTA_SIZE_OF_CRAFTING_ORDER_ICON_PIXELS"] or "Size of the crafting order icon (pixels).",
              dbKey = "vistaCraftingOrderIconSize", min = 14, max = 40,
              get = function() return math.max(14, math.min(40, tonumber(getDB("vistaCraftingOrderIconSize", 20)) or 20)) end,
              set = function(v) setDB("vistaCraftingOrderIconSize", math.max(14, math.min(40, v))) end },
            { type = "toggle", name = L["VISTA_CRAFTING_ORDER_ICON_PULSE"] or "Crafting Order icon pulse",
              desc = L["VISTA_CRAFTING_ORDER_ICON_PULSES_DRAW_ATTENTION"] or "When on, the crafting order icon pulses to draw attention. When off, it stays at full opacity.",
              dbKey = "vistaCraftingOrderBlink",
              get = function() return getDB("vistaCraftingOrderBlink", true) end,
              set = function(v) setDB("vistaCraftingOrderBlink", v) end },
            { type = "slider", name = L["VISTA_ADDON_BUTTON_SIZE"] or "Addon button size",
              desc = L["VISTA_SIZE_OF_COLLECTED_ADDON_MINIMAP_BUTTONS"] or "Size of collected addon minimap buttons (pixels).",
              dbKey = "vistaAddonBtnSize", min = 16, max = 48,
              get = function() return math.max(16, math.min(48, tonumber(getDB("vistaAddonBtnSize", 26)) or 26)) end,
              set = function(v)
                  setDB("vistaAddonBtnSize", math.max(16, math.min(48, v)))
                  if addon._vistaAddonBtnDebounce then addon._vistaAddonBtnDebounce:Cancel() end
                  if C_Timer and C_Timer.NewTimer then
                      addon._vistaAddonBtnDebounce = C_Timer.NewTimer(0.15, function()
                          addon._vistaAddonBtnDebounce = nil
                          if addon.Vista and addon.Vista.ApplyOptions then
                              addon.Vista.ApplyOptions()
                          elseif addon.MinimapButton_ApplyPosition then
                              addon.MinimapButton_ApplyPosition()
                          end
                      end)
                  end
              end },
            { type = "section", name = L["VISTA_ZONE_TEXT_HEADER"] or "Zone Text" },
            { type = "dropdown", name = L["VISTA_ZONE_FONT"] or "Zone font",
              desc = L["VISTA_FONT_ZONE_NAME_BELOW_MINIMAP"] or "Font for the zone name below the minimap.",
              dbKey = "vistaZoneFontPath", searchable = true,
              options = function() return fontOpts("vistaZoneFontPath") end,
              get = function() return getFont("vistaZoneFontPath") end,
              set = function(v) setDB("vistaZoneFontPath", v) end,
              displayFn = displayFont, fontPreviewInList = true },
            { type = "slider", name = L["VISTA_ZONE_FONT_SIZE"] or "Zone font size",
              dbKey = "vistaZoneFontSize", min = 7, max = 24,
              get = function() return math.max(7, math.min(24, tonumber(getDB("vistaZoneFontSize", 12)) or 12)) end,
              set = function(v) setDB("vistaZoneFontSize", math.max(7, math.min(24, v))) end },
            { type = "color", name = L["VISTA_ZONE_TEXT_COLOUR"] or "Zone text color",
              desc = L["VISTA_COLOUR_OF_ZONE_NAME_TEXT"] or "Color of the zone name text.",
              dbKey = "vistaZoneColor",
              get = function()
                  return getDB("vistaZoneColorR", 1), getDB("vistaZoneColorG", 1), getDB("vistaZoneColorB", 1)
              end,
              set = function(r, g, b)
                  setDB("vistaZoneColorR", r); setDB("vistaZoneColorG", g); setDB("vistaZoneColorB", b)
              end },
            { type = "section", name = L["VISTA_COORDINATES_TEXT"] or "Coordinates Text" },
            { type = "dropdown", name = L["VISTA_COORDINATES_FONT"] or "Coordinates font",
              desc = L["VISTA_FONT_COORDINATES_TEXT_BELOW_MINIMAP"] or "Font for the coordinates text below the minimap.",
              dbKey = "vistaCoordFontPath", searchable = true,
              options = function() return fontOpts("vistaCoordFontPath") end,
              get = function() return getFont("vistaCoordFontPath") end,
              set = function(v) setDB("vistaCoordFontPath", v) end,
              displayFn = displayFont, fontPreviewInList = true },
            { type = "slider", name = L["VISTA_COORDINATES_FONT_SIZE"] or "Coordinates font size",
              dbKey = "vistaCoordFontSize", min = 7, max = 20,
              get = function() return math.max(7, math.min(20, tonumber(getDB("vistaCoordFontSize", 10)) or 10)) end,
              set = function(v) setDB("vistaCoordFontSize", math.max(7, math.min(20, v))) end },
            { type = "color", name = L["VISTA_COORDINATES_TEXT_COLOUR"] or "Coordinates text color",
              desc = L["VISTA_COLOUR_OF_COORDINATES_TEXT"] or "Color of the coordinates text.",
              dbKey = "vistaCoordColor",
              get = function()
                  return getDB("vistaCoordColorR", 0.55), getDB("vistaCoordColorG", 0.65), getDB("vistaCoordColorB", 0.75)
              end,
              set = function(r, g, b)
                  setDB("vistaCoordColorR", r); setDB("vistaCoordColorG", g); setDB("vistaCoordColorB", b)
              end },
            { type = "dropdown", name = L["VISTA_COORDINATE_PRECISION"] or "Coordinate precision",
              desc = L["VISTA_NUMBER_OF_DECIMAL_PLACES_SHOWN_X"] or "Number of decimal places shown for X and Y coordinates.",
              dbKey = "vistaCoordPrecision",
              options = function() return {
                  { L["VISTA_COORDS_DECIMALS_OFF"]      or "No decimals (e.g. 52, 37)",      0 },
                  { L["VISTA_DECIMAL_E_G"]    or "1 decimal (e.g. 52.3, 37.1)",    1 },
                  { L["VISTA_DECIMALS_E_G"] or "2 decimals (e.g. 52.34, 37.12)", 2 },
              } end,
              get = function() return tonumber(getDB("vistaCoordPrecision", 1)) or 1 end,
              set = function(v) setDB("vistaCoordPrecision", tonumber(v) or 1) end },
            { type = "section", name = L["VISTA_TEXT"] or "Time Text" },
            { type = "dropdown", name = L["VISTA_FONT"] or "Time font",
              desc = L["VISTA_FONT_TEXT_BELOW_MINIMAP"] or "Font for the time text below the minimap.",
              dbKey = "vistaTimeFontPath", searchable = true,
              options = function() return fontOpts("vistaTimeFontPath") end,
              get = function() return getFont("vistaTimeFontPath") end,
              set = function(v) setDB("vistaTimeFontPath", v) end,
              displayFn = displayFont, fontPreviewInList = true },
            { type = "slider", name = L["VISTA_FONT_SIZE"] or "Time font size",
              dbKey = "vistaTimeFontSize", min = 7, max = 20,
              get = function() return math.max(7, math.min(20, tonumber(getDB("vistaTimeFontSize", 10)) or 10)) end,
              set = function(v) setDB("vistaTimeFontSize", math.max(7, math.min(20, v))) end },
            { type = "color", name = L["VISTA_TEXT_COLOUR"] or "Time text color",
              desc = L["VISTA_COLOUR_OF_TEXT"] or "Color of the time text.",
              dbKey = "vistaTimeColor",
              get = function()
                  return getDB("vistaTimeColorR", 0.55), getDB("vistaTimeColorG", 0.65), getDB("vistaTimeColorB", 0.75)
              end,
              set = function(r, g, b)
                  setDB("vistaTimeColorR", r); setDB("vistaTimeColorG", g); setDB("vistaTimeColorB", b)
              end },
            { type = "section", name = L["VISTA_PERFORMANCE_TEXT"] or "Performance Text" },
            { type = "dropdown", name = L["VISTA_PERFORMANCE_FONT"] or "Performance font",
              desc = L["VISTA_FONT_FPS_LATENCY_TEXT_BELOW_MINIMAP"] or "Font for the FPS and latency text below the minimap.",
              dbKey = "vistaPerfFontPath", searchable = true,
              options = function() return fontOpts("vistaPerfFontPath") end,
              get = function() return getFont("vistaPerfFontPath") end,
              set = function(v) setDB("vistaPerfFontPath", v) end,
              displayFn = displayFont, fontPreviewInList = true,
              disabled = function() return not getDB("vistaShowPerfText", false) end },
            { type = "slider", name = L["VISTA_PERFORMANCE_FONT_SIZE"] or "Performance font size",
              dbKey = "vistaPerfFontSize", min = 7, max = 20,
              get = function() return math.max(7, math.min(20, tonumber(getDB("vistaPerfFontSize", 10)) or 10)) end,
              set = function(v) setDB("vistaPerfFontSize", math.max(7, math.min(20, v))) end,
              disabled = function() return not getDB("vistaShowPerfText", false) end },
            { type = "color", name = L["VISTA_PERFORMANCE_TEXT_COLOUR"] or "Performance text color",
              desc = L["VISTA_COLOUR_OF_FPS_LATENCY_TEXT"] or "Color of the FPS and latency text.",
              dbKey = "vistaPerfColor",
              get = function()
                  return getDB("vistaPerfColorR", 0.55), getDB("vistaPerfColorG", 0.65), getDB("vistaPerfColorB", 0.75)
              end,
              set = function(r, g, b)
                  setDB("vistaPerfColorR", r); setDB("vistaPerfColorG", g); setDB("vistaPerfColorB", b)
              end,
              disabled = function() return not getDB("vistaShowPerfText", false) end },
            { type = "section", name = L["VISTA_DIFFICULTY_TEXT"] or "Difficulty Text" },
            { type = "color", name = L["VISTA_DIFFICULTY_TEXT_COLOUR_FALLBACK"] or "Difficulty text color (fallback)",
              desc = L["VISTA_DEFAULT_COLOUR_PER_DIFFICULTY_COLOUR"] or "Default color when no per-difficulty color is set.",
              dbKey = "vistaDiffColor",
              get = function()
                  return getDB("vistaDiffColorR", 0.55), getDB("vistaDiffColorG", 0.65), getDB("vistaDiffColorB", 0.75)
              end,
              set = function(r, g, b)
                  setDB("vistaDiffColorR", r); setDB("vistaDiffColorG", g); setDB("vistaDiffColorB", b)
              end },
            { type = "dropdown", name = L["VISTA_DIFFICULTY_FONT"] or "Difficulty font",
              desc = L["VISTA_FONT_INSTANCE_DIFFICULTY_TEXT"] or "Font for the instance difficulty text.",
              dbKey = "vistaDiffFontPath", searchable = true,
              options = function() return fontOpts("vistaDiffFontPath") end,
              get = function() return getFont("vistaDiffFontPath") end,
              set = function(v) setDB("vistaDiffFontPath", v) end,
              displayFn = displayFont, fontPreviewInList = true },
            { type = "slider", name = L["VISTA_DIFFICULTY_FONT_SIZE"] or "Difficulty font size",
              dbKey = "vistaDiffFontSize", min = 7, max = 24,
              get = function() return math.max(7, math.min(24, tonumber(getDB("vistaDiffFontSize", 10)) or 10)) end,
              set = function(v) setDB("vistaDiffFontSize", math.max(7, math.min(24, v))) end },
            { type = "section", name = L["VISTA_PER_DIFFICULTY_COLOURS"] or "Per-Difficulty Colors", defaultCollapsed = true },
            { type = "color", name = L["VISTA_MYTHIC_COLOUR"] or "Mythic color",
              desc = L["VISTA_COLOUR_MYTHIC_DIFFICULTY_TEXT"] or "Color for Mythic difficulty text.",
              dbKey = "vistaDiffColor_mythic",
              get = function() return getDB("vistaDiffColor_mythic_R", 0.64), getDB("vistaDiffColor_mythic_G", 0.21), getDB("vistaDiffColor_mythic_B", 0.93) end,
              set = function(r, g, b) setDB("vistaDiffColor_mythic_R", r); setDB("vistaDiffColor_mythic_G", g); setDB("vistaDiffColor_mythic_B", b) end },
            { type = "color", name = L["VISTA_HEROIC_COLOUR"] or "Heroic color",
              desc = L["VISTA_COLOUR_HEROIC_DIFFICULTY_TEXT"] or "Color for Heroic difficulty text.",
              dbKey = "vistaDiffColor_heroic",
              get = function() return getDB("vistaDiffColor_heroic_R", 1.00), getDB("vistaDiffColor_heroic_G", 0.12), getDB("vistaDiffColor_heroic_B", 0.12) end,
              set = function(r, g, b) setDB("vistaDiffColor_heroic_R", r); setDB("vistaDiffColor_heroic_G", g); setDB("vistaDiffColor_heroic_B", b) end },
            { type = "color", name = L["VISTA_NORMAL_COLOUR"] or "Normal color",
              desc = L["VISTA_COLOUR_NORMAL_DIFFICULTY_TEXT"] or "Color for Normal difficulty text.",
              dbKey = "vistaDiffColor_normal",
              get = function() return getDB("vistaDiffColor_normal_R", 0.12), getDB("vistaDiffColor_normal_G", 0.83), getDB("vistaDiffColor_normal_B", 0.12) end,
              set = function(r, g, b) setDB("vistaDiffColor_normal_R", r); setDB("vistaDiffColor_normal_G", g); setDB("vistaDiffColor_normal_B", b) end },
            { type = "color", name = L["VISTA_LFR_COLOUR"] or "LFR color",
              desc = L["VISTA_COLOUR_LOOKING_RAID_DIFFICULTY_TEXT"] or "Color for Looking For Raid difficulty text.",
              dbKey = "vistaDiffColor_lfr",
              get = function() return getDB("vistaDiffColor_looking_for_raid_R", 0.00), getDB("vistaDiffColor_looking_for_raid_G", 0.70), getDB("vistaDiffColor_looking_for_raid_B", 1.00) end,
              set = function(r, g, b) setDB("vistaDiffColor_looking_for_raid_R", r); setDB("vistaDiffColor_looking_for_raid_G", g); setDB("vistaDiffColor_looking_for_raid_B", b) end },
        } end,
    },
    {
        key = "VistaButtons",
        name = L["VISTA_ADDON_BUTTONS"] or "Addon Buttons",
        desc = L["VISTA_ICON_MANAGEMENT"] or "Manage and organize minimap icons from other addons into a tidy drawer or bar.",
        moduleKey = "vista",
        options = function()
            local BUTTON_MODE_OPTIONS = {
                { L["VISTA_MOUSEOVER_BAR"] or "Mouseover bar", "mouseover" },
                { L["VISTA_RIGHT_CLICK_PANEL"] or "Right-click panel", "rightclick" },
                { L["VISTA_FLOATING_DRAWER"] or "Floating drawer", "drawer" },
            }

            local opts = {
                { type = "section", name = L["VISTA_BUTTON_MANAGEMENT"] or "Button Management" },
                { type = "toggle", name = L["MANAGE_ADDON_BUTTONS"] or "Manage addon buttons",
                  desc = L["COLLECT_GROUP_ADDON_MINIMAP_BUTTONS"], tooltip = L["GROUPS_SELECTED_LAYOUT_MODE_BELOW"],
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
                { type = "toggle", name = L["VISTA_COLLECT_HORIZON_MINIMAP"] or "Include Horizon minimap icon",
                  desc = L["VISTA_COLLECT_HORIZON_MINIMAP_DESC"] or "Place Horizon's own minimap icon in the managed addon bar, panel, or drawer instead of leaving it on the minimap edge.",
                  dbKey = "vistaCollectHorizonMinimapButton",
                  get = function() return getDB("vistaCollectHorizonMinimapButton", true) end,
                  set = function(v)
                      if not getDB("vistaHandleAddonButtons", true) then return end
                      if C_Timer and C_Timer.After then
                          C_Timer.After(0, function() setDB("vistaCollectHorizonMinimapButton", v) end)
                      else
                          setDB("vistaCollectHorizonMinimapButton", v)
                      end
                  end,
                  disabled = function() return not getDB("vistaHandleAddonButtons", true) end },
                { type = "toggle", name = L["VISTA_SORT_BUTTONS_ALPHA"] or "Sort buttons alphabetically",
                  desc = L["VISTA_SORT_BUTTONS_ALPHA_DESC"] or "Sort collected addon minimap buttons alphabetically by name.",
                  dbKey = "vistaButtonSortAlpha",
                  get = function() return getDB("vistaButtonSortAlpha", false) end,
                  set = function(v) setDB("vistaButtonSortAlpha", v) end,
                  disabled = function() return not getDB("vistaHandleAddonButtons", true) end },
                { type = "dropdown", name = L["VISTA_BUTTON_MODE"] or "Button mode",
                  desc = L["VISTA_ADDON_BUTTONS_PRESENTED_HOVER_BAR_BELOW"] or "How addon buttons are presented: hover bar below minimap, panel on right-click, or floating drawer button.",
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
                { type = "toggle", name = L["LOCK_DRAWER_BUTTON"] or "Lock drawer button",
                  desc = L["VISTA_PREVENT_DRAGGING_FLOATING_DRAWER_BUTTON"] or "Prevent dragging the floating drawer button.",
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
                { type = "toggle", name = L["LOCK_MOUSEOVER_BAR"] or "Lock mouseover bar",
                  desc = L["VISTA_PREVENT_DRAGGING_MOUSEOVER_BUTTON_BAR"] or "Prevent dragging the mouseover button bar.",
                  dbKey = "vistaMouseoverLocked",
                  get = function() return getDB("vistaMouseoverLocked", true) end,
                  set = function(v) setDB("vistaMouseoverLocked", v) end,
                  disabled = function()
                      return not getDB("vistaHandleAddonButtons", true) or getDB("vistaButtonMode", "mouseover") ~= "mouseover"
                  end },
                { type = "toggle", name = L["VISTA_ALWAYS_BAR"] or "Always show bar",
                  desc = L["KEEP_BAR_VISIBLE_REPOSITIONING"], tooltip = L["VISTA_DISABLE_DONE"],
                  dbKey = "vistaMouseoverBarVisible",
                  get = function() return getDB("vistaMouseoverBarVisible", false) end,
                  set = function(v) setDB("vistaMouseoverBarVisible", v) end,
                  disabled = function()
                      return not getDB("vistaHandleAddonButtons", true) or getDB("vistaButtonMode", "mouseover") ~= "mouseover"
                  end },
                { type = "toggle", name = L["LOCK_RIGHT_CLICK_PANEL"] or "Lock right-click panel",
                  desc = L["VISTA_PREVENT_DRAGGING_RIGHT_CLICK_PANEL"] or "Prevent dragging the right-click panel.",
                  dbKey = "vistaRightClickLocked",
                  get = function() return getDB("vistaRightClickLocked", true) end,
                  set = function(v) setDB("vistaRightClickLocked", v) end,
                  disabled = function()
                      return not getDB("vistaHandleAddonButtons", true) or getDB("vistaButtonMode", "mouseover") ~= "rightclick"
                  end },

                { type = "section", name = L["VISTA_CLOSE_FADE_TIMING"] or "Close / Fade Timing", defaultCollapsed = true },
                { type = "slider", name = L["MOUSEOVER_CLOSE_DELAY"] or "Mouseover close delay",
                  desc = L["VISTA_LONG_SECONDS_BAR_STAYS_VISIBLE_AFTER"] or "How long (in seconds) the bar stays visible after the cursor leaves. 0 = instant fade.",
                  dbKey = "vistaMouseoverCloseDelay", min = 0, max = 10, step = 0.5,
                  get = function() return math.max(0, math.min(10, tonumber(getDB("vistaMouseoverCloseDelay", 0)) or 0)) end,
                  set = function(v) setDB("vistaMouseoverCloseDelay", math.max(0, math.min(10, v))) end,
                  disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
                },
                { type = "slider", name = L["RIGHT_CLICK_CLOSE_DELAY"] or "Right-click close delay",
                  desc = L["VISTA_LONG_SECONDS_PANEL_STAYS_OPEN_AFTER"] or "How long (in seconds) the panel stays open after the cursor leaves. 0 = never auto-close (close by right-clicking again).",
                  dbKey = "vistaRightClickCloseDelay", min = 0, max = 10, step = 0.5,
                  get = function() return math.max(0, math.min(10, tonumber(getDB("vistaRightClickCloseDelay", 2.5)) or 2.5)) end,
                  set = function(v) setDB("vistaRightClickCloseDelay", math.max(0, math.min(10, v))) end,
                  disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
                },
                { type = "slider", name = L["VISTA_DRAWER_CLOSE_DELAY"] or "Drawer close delay",
                  desc = L["AUTO_CLOSE_DELAY_DISABLE"] or "Auto-close delay (0 to disable).",
                  tooltip = L["VISTA_LONG_SECONDS_DRAWER_PANEL_STAYS_OPEN"] or "How long (in seconds) the drawer panel stays open after clicking away. 0 = never auto-close (close only by clicking the drawer button again).",
                  dbKey = "vistaDrawerCloseDelay", min = 0, max = 10, step = 0.5,
                  get = function() return math.max(0, math.min(10, tonumber(getDB("vistaDrawerCloseDelay", 0)) or 0)) end,
                  set = function(v) setDB("vistaDrawerCloseDelay", math.max(0, math.min(10, v))) end,
                  disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
                },

                { type = "section", name = L["DASH_LAYOUT"] or "Layout" },
            }

            local DIR_OPTIONS = function() return {
                { L["VISTA_BUTTONS_FILL_RIGHT"] or "Right", "right" },
                { L["VISTA_BUTTONS_FILL_LEFT"] or "Left",   "left"  },
                { L["VISTA_BUTTONS_FILL_DOWN"] or "Down",   "down"  },
                { L["VISTA_BUTTONS_FILL_UP"] or "Up",       "up"    },
            } end

            -- Shared layout options (apply to all 3 modes)
            opts[#opts + 1] = {
                type = "slider", name = L["VISTA_BUTTONS_PER_ROW_COLUMN"] or "Buttons per row/column",
                desc = L["VISTA_CONTROLS_MANY_BUTTONS_APPEAR_BEFORE_WRAPPING"] or "Controls how many buttons appear before wrapping. For left/right direction this is columns; for up/down it is rows.",
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
                type = "dropdown", name = L["VISTA_EXPAND_DIRECTION"] or "Expand direction",
                desc = L["EXPAND_DIRECTION_ANCHOR"] or "Expand direction from anchor.",
                tooltip = L["VISTA_DIRECTION_BUTTONS_FILL_ANCHOR_POINT_LEFT"] or "Direction buttons fill from the anchor point. Left/Right = horizontal rows. Up/Down = vertical columns.",
                dbKey = "vistaBtnLayoutDir", options = DIR_OPTIONS,
                get = function() return getDB("vistaBtnLayoutDir", "right") end,
                set = function(v) setDB("vistaBtnLayoutDir", v) end,
                disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
            }

            opts[#opts + 1] = { type = "section", name = L["VISTA_PANEL_APPEARANCE"] or "Panel Appearance" }
            opts[#opts + 1] = { type = "header", name = L["VISTA_COLOURS_DRAWER_RIGHT_CLICK_BUTTON_PANELS"] or "Colors for the drawer and right-click button panels." }
            opts[#opts + 1] = {
                type = "color", name = L["VISTA_PANEL_BG_COLOUR_LABEL"] or "Panel background color",
                desc = L["VISTA_BACKGROUND_COLOUR_OF_ADDON_BUTTON_PANELS"] or "Background color of the addon button panels.",
                dbKey = "vistaPanelBg",
                get = function()
                    return getDB("vistaPanelBgR", 0.08), getDB("vistaPanelBgG", 0.08),
                           getDB("vistaPanelBgB", 0.12), getDB("vistaPanelBgA", 0.95)
                end,
                set = function(r, g, b, a)
                    setDB("vistaPanelBgR", r); setDB("vistaPanelBgG", g)
                    setDB("vistaPanelBgB", b)
                    if a ~= nil then setDB("vistaPanelBgA", a) end
                end,
                hasAlpha = true,
            }
            opts[#opts + 1] = {
                type = "color", name = L["VISTA_PANEL_BORDER_COLOUR"] or "Panel border color",
                desc = L["VISTA_BORDER_COLOUR_OF_ADDON_BUTTON_PANELS"] or "Border color of the addon button panels.",
                dbKey = "vistaPanelBorder",
                get = function()
                    return getDB("vistaPanelBorderR", 0.3), getDB("vistaPanelBorderG", 0.4),
                           getDB("vistaPanelBorderB", 0.6), getDB("vistaPanelBorderA", 0.7)
                end,
                set = function(r, g, b, a)
                    setDB("vistaPanelBorderR", r); setDB("vistaPanelBorderG", g)
                    setDB("vistaPanelBorderB", b)
                    if a ~= nil then setDB("vistaPanelBorderA", a) end
                end,
                hasAlpha = true,
            }

            opts[#opts + 1] = { type = "section", name = L["VISTA_MOUSEOVER_BAR_APPEARANCE"] or "Mouseover Bar Appearance" }
            opts[#opts + 1] = { type = "header", name = L["VISTA_BACKGROUND_BORDER_MOUSEOVER_BUTTON_BAR"] or "Background and border for the mouseover button bar." }
            opts[#opts + 1] = {
                type = "color", name = L["VISTA_BAR_BACKGROUND_COLOUR"] or "Bar background color",
                desc = L["VISTA_BACKGROUND_COLOUR_OF_MOUSEOVER_BUTTON_BAR"] or "Background color of the mouseover button bar (use alpha to control transparency).",
                dbKey = "vistaBarBg",
                get = function()
                    return getDB("vistaBarBgR", 0.08), getDB("vistaBarBgG", 0.08),
                           getDB("vistaBarBgB", 0.12), getDB("vistaBarBgA", 0)
                end,
                set = function(r, g, b, a)
                    setDB("vistaBarBgR", r); setDB("vistaBarBgG", g)
                    setDB("vistaBarBgB", b)
                    if a ~= nil then setDB("vistaBarBgA", a) end
                end,
                hasAlpha = true,
                disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
            }
            opts[#opts + 1] = {
                type = "toggle", name = L["VISTA_BAR_BORDER"] or "Show bar border",
                desc = L["VISTA_A_BORDER_AROUND_MOUSEOVER_BUTTON_BAR"] or "Show a border around the mouseover button bar.",
                dbKey = "vistaBarBorderShow",
                get = function() return getDB("vistaBarBorderShow", false) end,
                set = function(v) setDB("vistaBarBorderShow", v) end,
                disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
            }
            opts[#opts + 1] = {
                type = "color", name = L["VISTA_BAR_BORDER_COLOUR"] or "Bar border color",
                desc = L["VISTA_BORDER_COLOUR_OF_MOUSEOVER_BUTTON_BAR"] or "Border color of the mouseover button bar.",
                dbKey = "vistaBarBorder",
                get = function()
                    return getDB("vistaBarBorderR", 0.3), getDB("vistaBarBorderG", 0.4),
                           getDB("vistaBarBorderB", 0.6), getDB("vistaBarBorderA", 0.7)
                end,
                set = function(r, g, b, a)
                    setDB("vistaBarBorderR", r); setDB("vistaBarBorderG", g)
                    setDB("vistaBarBorderB", b)
                    if a ~= nil then setDB("vistaBarBorderA", a) end
                end,
                hasAlpha = true,
                disabled = function() return not getDB("vistaHandleAddonButtons", true) or not getDB("vistaBarBorderShow", false) end,
            }

            -- Managed buttons: per-button toggle — uncheck to fully ignore a button
            opts[#opts + 1] = {
                type = "section",
                name = L["VISTA_MANAGED_BUTTONS"] or "Managed buttons",
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
                    desc = L["VISTA_BUTTON_COMPLETELY_IGNORED"] or "When off, this button is completely ignored by this addon.",
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
                    name = L["VISTA_ADDON_BUTTONS_DETECTED"] or "(No addon buttons detected yet)",
                    dbKey = "_vista_no_managed_placeholder",
                    get = function() return false end, set = function() end,
                    disabled = function() return true end,
                }
            end

            opts[#opts + 1] = {
                type = "section",
                name = L["VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE"] or "Visible buttons (check to include)",
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
                    name = L["VISTA_ADDON_BUTTONS_DETECTED_OPEN_YOUR_MINIMAP"] or "(No addon buttons detected yet — open your minimap first)",
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
        key = "CacheGeneral",
        name = L["AXIS_GENERAL"],
        desc = L["POSITIONING_VISIBILITY_CACHE_LOOT_TOAST_SYS"] or "Positioning and visibility for the Cache loot toast system.",
        moduleKey = "cache",
        options = {
            { type = "section", name = L["AXIS_POSITION"] },
            { type = "button", name = L["AXIS_ANCHOR_MOVE"] or "Show anchor to move", desc = L["AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITION"] or "Click to show or hide the anchor. Drag to set position, right-click to confirm.", onClick = function()
                if addon.Cache and addon.Cache.ToggleAnchorFrame then addon.Cache.ToggleAnchorFrame() end
            end },
            { type = "button", name = L["AXIS_RESET_POSITION"], desc = L["AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"], onClick = function()
                if addon.Cache and addon.Cache.ResetPosition then addon.Cache.ResetPosition() end
            end },
            { type = "section", name = L["DASH_TYPOGRAPHY"] or "Typography" },
            { type = "dropdown",
                name = L["CACHE_FONT"] or "Loot toast font",
                desc = L["CACHE_FONT_FAMILY"] or "Font family used for loot toast text. Use 'Use global font' to follow the addon-wide font.",
                dbKey = "cacheFontPath",
                searchable = true,
                options = function() return GetPerElementFontDropdownOptions("cacheFontPath") end,
                get = function() return getDB("cacheFontPath", FONT_USE_GLOBAL) end,
                set = function(v) setDB("cacheFontPath", v) end,
                displayFn = DisplayPerElementFont,
                fontPreviewInList = true,
            },
        },
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

-- Export for panel
addon.OptionsData_GetDB = OptionsData_GetDB
addon.OptionsData_SetDB = OptionsData_SetDB
addon.OptionsData_NotifyMainAddon = OptionsData_NotifyMainAddon
addon.OptionsData_SetUpdateFontsRef = OptionsData_SetUpdateFontsRef
addon.GetPresencePreviewDropdownOptions = GetPresencePreviewDropdownOptions
addon.OptionCategories = getVisibleCategories()
addon.OptionsData_BuildSearchIndex = OptionsData_BuildSearchIndex
addon.OptionsData_SearchEntryScore = OptionsData_SearchEntryScore
addon.OptionsData_SearchResultDetailText = OptionsData_SearchResultDetailText
addon.COLOR_KEYS_ORDER = COLOR_KEYS_ORDER
addon.ZONE_COLOR_DEFAULT = ZONE_COLOR_DEFAULT
addon.OBJ_COLOR_DEFAULT = OBJ_COLOR_DEFAULT
addon.OBJ_DONE_COLOR_DEFAULT = OBJ_DONE_COLOR_DEFAULT
addon.HIGHLIGHT_COLOR_DEFAULT = HIGHLIGHT_COLOR_DEFAULT
