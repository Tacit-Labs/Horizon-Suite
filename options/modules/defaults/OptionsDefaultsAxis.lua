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
