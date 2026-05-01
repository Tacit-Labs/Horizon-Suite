--[[
    Horizon Suite — Localisation core
    Initializes addon.L with missing-key fallback before enUS and locale files load.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = {}

addon.L = setmetatable(L, {
    __index = function(t, k)
        if addon.debugLocale then
            print("|cffff6666[HS Locale]|r Missing key: " .. tostring(k))
        end
        return k
    end,
})
