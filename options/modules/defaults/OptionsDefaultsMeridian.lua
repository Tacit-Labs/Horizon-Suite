--[[
    Horizon Suite - Meridian - Option defaults
    Base settings, plus one enabled/side/order row per registered block (block files load
    with the modules, before this file), so the changed-from-default markers find them.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.MERIDIAN_DEFAULTS = {
    meridianEdge                 = "top",
    meridianStyle                = "strip",
    meridianAutoHide             = false,
    meridianKeepShownOutOfCombat = false,
    meridianCombat               = "show",
    meridianCombatFadeOpacity    = 30,
    meridianFontSize             = 12,
    meridianClockLocal           = true,
    meridianClock24Hour          = false,
    meridianCoordPrecision       = 1,
    meridianSeededFromVista      = false,
}

addon.MERIDIAN_LIMITS = {
    meridianFontSize          = { min = 9, max = 18 },
    meridianCombatFadeOpacity = { min = 0, max = 100 },
    meridianBlockOrder        = { min = 1, max = 100 },
}

local M = addon.Meridian
if M and M.All then
    for _, def in ipairs(M.All()) do
        addon.MERIDIAN_DEFAULTS[M.Key(def.id, "enabled")] = def.defaultOn
        addon.MERIDIAN_DEFAULTS[M.Key(def.id, "side")]    = def.defaultSide
        addon.MERIDIAN_DEFAULTS[M.Key(def.id, "order")]   = def.defaultOrder
    end
end

addon.MERIDIAN_KEYS = {}
for key in pairs(addon.MERIDIAN_DEFAULTS) do addon.MERIDIAN_KEYS[key] = true end
