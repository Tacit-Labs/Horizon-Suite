--[[
    Horizon Suite - Axis / Dashboard - SetDB routing keys
    Exports DASHBOARD_CLASS_ICON_KEYS, DASHBOARD_BACKGROUND_KEYS and
    DASHBOARD_TYPOGRAPHY_KEYS used by OptionsData_SetDB to trigger the
    corresponding dashboard apply functions when settings change.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.DASHBOARD_CLASS_ICON_KEYS = {
    dashboardClassIconSource = true,
    dashboardShowClassIcon   = true,
}

addon.DASHBOARD_BACKGROUND_KEYS = {
    dashboardBackgroundTheme         = true,
    dashboardBackgroundOpacity       = true,
    dashboardBackgroundClassOverride = true,
}

addon.DASHBOARD_TYPOGRAPHY_KEYS = {
    dashboardFontPath    = true,
    dashboardFontSize    = true,
    dashboardTextOutline = true,
    dashboardTextShadow  = true,
    dashboardHeadingColor = true,
}

addon.AXIS_DEFAULTS = {
    moduleNameDisplay              = "horizon",
    dashboardBackgroundTheme       = "midnight",
    dashboardBackgroundOpacity     = 90,
    dashboardFontPath              = "__global__",
    dashboardFontSize              = 13,
    dashboardTextOutline           = 1,
    dashboardTextShadow            = false,
    dashboardHeadingColor          = "white",
    autoShowPatchNotesOnLogin      = true,
    classColorDashboard            = false,
    classColorVista                = false,
    classColorInsight              = false,
    classColorEssence              = false,
    classColorFocus                = false,
    classColorPresence             = false,
    classColorCache                = false,
    dashboardClassTheme            = false,
    dashboardShowClassIcon         = false,
    dashboardBackgroundClassOverride = false,
    dashboardClassIconSource       = "custom",
    useGlobalFont                  = false,
    globalUIScale                  = 1.0,
    focusUIScale                   = 1.0,
    presenceUIScale                = 1.0,
    vistaUIScale                   = 1.0,
    insightUIScale                 = 1.0,
    cacheUIScale                   = 1.0,
    perModuleScaling               = false,
    hideMinimapButton              = false,
    minimapButtonShowOnlyOnMinimapHover = false,
    minimapButtonLocked            = false,
    minimapButtonCircular          = false,
}

addon.AXIS_LIMITS = {
    dashboardBackgroundOpacity = { min = 50,  max = 100 },
    dashboardFontSize          = { min = 10,  max = 18  },
    globalUIScale_pct          = { min = 50,  max = 200 },
    focusUIScale_pct           = { min = 50,  max = 200 },
    presenceUIScale_pct        = { min = 50,  max = 200 },
    vistaUIScale_pct           = { min = 50,  max = 200 },
    insightUIScale_pct         = { min = 50,  max = 200 },
    cacheUIScale_pct           = { min = 50,  max = 200 },
}
