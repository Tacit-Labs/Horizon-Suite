--[[
    Horizon Suite - Cache - Option defaults and SetDB routing keys
    CACHE_DEFAULTS: single source of truth for all loot toast option defaults.
    CACHE_KEYS: used by OptionsData_SetDB to trigger Cache.ApplyCacheOptions.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.CACHE_DEFAULTS = {
    cacheShowItems     = true,
    cacheShowMoney     = true,
    cacheShowCurrency  = true,
    cacheShowRep       = true,
    cacheMinQuality    = 0,
    cacheToastOpacity  = 100,
    cacheMaxVisible    = 15,   -- matches CacheState.POOL_SIZE
    cacheHoldItem      = 5.0,  -- matches CacheState.HOLD_ITEM
    cacheHoldEpic      = 6.5,  -- matches CacheState.HOLD_EPIC
    cacheHoldLegendary = 8.0,  -- matches CacheState.HOLD_LEGENDARY
    cacheHoldMoney     = 3.0,  -- matches CacheState.HOLD_MONEY
    cacheHoldCurrency  = 3.0,  -- matches CacheState.HOLD_CURRENCY
    cacheHoldRep       = 3.0,  -- matches CacheState.HOLD_REP
    cacheTextOutline   = true,
    cacheSoundEnabled  = true,
    cacheSoundChannel  = "SFX",
    cacheSoundItems    = true,
    cacheSoundMoney    = false,
    cacheSoundCurrency = false,
    cacheSoundRep      = false,
}

addon.CACHE_KEYS = {
    cachePoint         = true,
    cacheRelPoint      = true,
    cacheX             = true,
    cacheY             = true,
    cacheFontPath      = true,
    cacheShowItems     = true,
    cacheShowMoney     = true,
    cacheShowCurrency  = true,
    cacheShowRep       = true,
    cacheMinQuality    = true,
    cacheToastOpacity  = true,
    cacheMaxVisible    = true,
    cacheHoldItem      = true,
    cacheHoldEpic      = true,
    cacheHoldLegendary = true,
    cacheHoldMoney     = true,
    cacheHoldCurrency  = true,
    cacheHoldRep       = true,
    cacheTextOutline   = true,
    cacheSoundEnabled  = true,
    cacheSoundChannel  = true,
    cacheSoundItems    = true,
    cacheSoundMoney    = true,
    cacheSoundCurrency = true,
    cacheSoundRep      = true,
}
