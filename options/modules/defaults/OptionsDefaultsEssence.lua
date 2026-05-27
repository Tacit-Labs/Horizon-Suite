--[[
    Horizon Suite - Essence - SetDB routing keys
    Exports ESSENCE_KEYS used by OptionsData_SetDB to trigger
    Essence.ApplyEssenceOptions when any Essence setting changes.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.ESSENCE_KEYS = {
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

addon.ESSENCE_DEFAULTS = {
    essenceLockPosition  = false,
    essenceShowTitle     = true,
    essenceShowStatBars  = true,
    essenceShowIlvlBadge = true,
    essenceStatCap       = 50,
    essencePoint         = "CENTER",
    essenceX             = 0,
    essenceY             = 0,
}

addon.ESSENCE_LIMITS = {
    essenceStatCap = { min = 20, max = 100 },
}
