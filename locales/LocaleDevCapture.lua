--[[
    Horizon Suite — Locale dev mode snapshot
    Saves a copy of addon.L after enUS loads but before other locale files run.
    Used by LocaleCore.lua at PLAYER_LOGIN to detect which keys were not translated.
]]

local addon = _G.HorizonSuite
if not addon then return end

local snap = {}
for k, v in pairs(addon.L) do snap[k] = v end
addon._localeDevEnUS = snap
