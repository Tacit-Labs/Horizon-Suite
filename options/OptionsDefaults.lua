--[[
    Horizon Suite - Options Defaults
    Cross-cutting SetDB routing key tables shared by OptionsData_SetDB.
    Loads before OptionsData.lua so these can be used as upvalues there.
]]
local addon = _G.HorizonSuite
if not addon then return end

-- Keys that drive UpdateFontObjectsFromDB when changed.
addon.TYPOGRAPHY_KEYS = {
    fontPath = true,
    useGlobalFont = true,
    globalOverrideFontPath = true,
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

-- Keys written by color pickers during drag. When _colorPickerLive is true and key is in
-- this list, OptionsData_SetDB skips NotifyMainAddon to avoid FullLayout spam; key-specific
-- handlers (e.g. ApplyBackdropOpacity) still run.
addon.COLOR_LIVE_KEYS = {
    backdropOpacity = true, backdropOpacityMouseover = true, backdropColorR = true, backdropColorG = true, backdropColorB = true,
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
    alertsDurabilityColorR = true, alertsDurabilityColorG = true, alertsDurabilityColorB = true,
    alertsBagsColorR = true, alertsBagsColorG = true, alertsBagsColorB = true,
    alertsMailColorR = true, alertsMailColorG = true, alertsMailColorB = true,
    alertsVaultColorR = true, alertsVaultColorG = true, alertsVaultColorB = true,
    alertsFriendOnColorR = true, alertsFriendOnColorG = true, alertsFriendOnColorB = true,
    alertsFriendOffColorR = true, alertsFriendOffColorG = true, alertsFriendOffColorB = true,
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

-- Scale keys managed by debounced callbacks in the slider set lambdas.
-- OptionsData_SetDB must NOT call OptionsData_NotifyMainAddon for these —
-- doing so triggers FullLayout synchronously on every integer drag step,
-- defeating the debounce entirely.
addon.SCALE_DEBOUNCE_KEYS = {
    globalUIScale    = true,
    focusUIScale     = true,
    presenceUIScale  = true,
    vistaUIScale     = true,
    insightUIScale   = true,
    augmentUIScale     = true,
    vistaBorderWidth = true,
    vistaAddonBtnSize  = true,
    vistaBtnLayoutCols = true,
}

-- Keys that trigger per-module class-colour apply functions.
addon.CLASS_COLOR_KEYS = {
    classColorDashboard = true,
    classColorVista     = true,
    classColorInsight   = true,
    classColorEssence   = true,
    classColorFocus     = true,
    classColorPresence  = true,
    classColorAugment     = true,
}
