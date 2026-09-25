--[[
    Horizon Suite - Echo - Defaults
    ECHO_DEFAULTS for the settings Echo reads through Echo.Setting. The options page
    arrives in plan 3; until then /h echo lock | unlock | reset covers the column.
    echoX / echoY have no default: unset means the bottom-right anchor.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.ECHO_DEFAULTS = {
    echoLockPosition       = true,
    echoScale              = 1,
    echoFrameStrata        = "MEDIUM",
    echoMaxTiles           = 8,
    echoToastStyle         = "framed",
    echoToastSeconds       = 4,
    echoHoverDelay         = 0.35,
    echoHoldToastsInCombat = true,
}
