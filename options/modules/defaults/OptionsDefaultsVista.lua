--[[
    Horizon Suite - Vista - SetDB routing keys
    Exports VISTA_KEYS, VISTA_COLOR_LIVE_KEYS, VISTA_KEYS_REQUIRE_NOTIFY and
    VISTA_SKIP_FULL_LAYOUT_KEYS used by OptionsData_SetDB to drive Vista.ApplyOptions
    and Vista.ApplyLockOnlyOptions without triggering unnecessary FullLayouts.
]]
local addon = _G.HorizonSuite
if not addon then return end

-- Vista option keys — trigger Vista.ApplyOptions when changed
addon.VISTA_KEYS = {
    vistaMapSize = true,
    vistaCircular = true,
    vistaBorderShow = true, vistaBorderWidth = true,
    vistaBorderColorR = true, vistaBorderColorG = true, vistaBorderColorB = true, vistaBorderColorA = true,
    vistaZoneFontPath = true, vistaZoneFontSize = true,
    vistaCoordFontPath = true, vistaCoordFontSize = true,
    vistaTimeFontPath = true, vistaTimeFontSize = true,
    vistaPerfFontPath = true, vistaPerfFontSize = true,
    vistaShowZoneText = true, vistaShowCoordText = true, vistaShowTimeText = true, vistaShowPerfText = true,
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

-- Vista color keys: live updates via ApplyColors without a full layout pass
addon.VISTA_COLOR_LIVE_KEYS = {
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

-- Vista-only keys: Vista.ApplyOptions already runs, so skip FullLayout (Focus rebuild unnecessary).
-- Add a key here only if it must still rebuild the tracker or global dimensions.
addon.VISTA_KEYS_REQUIRE_NOTIFY = {
}

-- Vista position / drag-lock keys: use Vista.ApplyLockOnlyOptions and skip FullLayout.
addon.VISTA_SKIP_FULL_LAYOUT_KEYS = {
    vistaLocked_zone  = true,
    vistaLocked_coord = true,
    vistaLocked_time  = true,
    vistaLocked_perf  = true,
    vistaLocked_diff  = true,
    ["vistaLocked_proxy_tracking"]     = true,
    ["vistaLocked_proxy_calendar"]     = true,
    ["vistaLocked_proxy_queue"]        = true,
    ["vistaLocked_proxy_mail"]         = true,
    ["vistaLocked_proxy_craftingOrder"] = true,
    ["vistaQueueHandlingDisabled"] = true,
    vistaMouseoverLocked    = true,
    vistaRightClickLocked   = true,
    vistaDrawerButtonLocked = true,
}
