--[[
    Horizon Suite - Cache - SetDB routing keys
    Exports CACHE_KEYS used by OptionsData_SetDB to trigger
    Cache.ApplyCacheOptions when any loot toast setting changes.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.CACHE_KEYS = {
    cachePoint    = true,
    cacheRelPoint = true,
    cacheX        = true,
    cacheY        = true,
    cacheFontPath = true,
}
