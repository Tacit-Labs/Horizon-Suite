--[[
    Horizon Suite - Cache - Option defaults and SetDB routing keys
    CACHE_DEFAULTS: single source of truth for all loot toast option defaults.
    CACHE_KEYS: derived from CACHE_DEFAULTS plus anchor-position keys (no defaults).
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.CACHE_DEFAULTS = {
    cacheFontPath      = "__global__",
    cacheFontSize      = 16,
    cacheUIScale       = 1.0,
    cacheShowItems     = true,
    cacheShowMoney     = true,
    cacheShowCurrency  = true,
    cacheShowRep       = true,
    cacheMinQuality    = 0,
    cacheToastOpacity  = 100,
    cacheMaxVisible    = 15,
    cacheHoldItem      = 5.0,
    cacheHoldEpic      = 6.5,
    cacheHoldLegendary = 8.0,
    cacheHoldMoney     = 3.0,
    cacheHoldCurrency  = 3.0,
    cacheHoldRep       = 3.0,
    cacheTextOutline   = true,
    cacheSoundEnabled  = true,
    cacheSoundChannel  = "SFX",
    cacheSoundItems    = true,
    cacheSoundMoney    = false,
    cacheSoundCurrency = false,
    cacheSoundRep      = false,
}

-- Position keys have no meaningful defaults (nil = use anchor frame position).
addon.CACHE_KEYS = { cachePoint = true, cacheRelPoint = true, cacheX = true, cacheY = true }
for k in pairs(addon.CACHE_DEFAULTS) do addon.CACHE_KEYS[k] = true end
