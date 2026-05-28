--[[
    Horizon Suite — Localisation core
    Initializes addon.L with missing-key fallback before enUS and locale files load.
]]

local addon = _G.HorizonSuite
if not addon then return end

local L = {}

addon.L = setmetatable(L, {
    __index = function(_, k)
        if addon.debugLocale then
            print("|cffff6666[HS Locale]|r Missing key: " .. tostring(k))
        end
        return k
    end,
})

-- Locale dev mode: replaces untranslated L[key] entries with an orange "[KEY]" tag
-- so translators can see exactly which strings still need work.
-- Keys already translated by the active locale file are left as-is.
-- Triggered by /hlocaledev (saves to HorizonDB.localeDevMode) or by setting
-- _G.HORIZON_LOCALE_DEV = true from a local-only addon (never committed).
-- Fires on PLAYER_LOGIN so SavedVariables are available before any frame renders.
local devFrame = CreateFrame("Frame")
devFrame:RegisterEvent("PLAYER_LOGIN")
devFrame:SetScript("OnEvent", function()
    local db    = _G[addon.DATABASE]
    local enUS  = addon._localeDevEnUS
    addon._localeDevEnUS = nil  -- free snapshot regardless
    if not ((db and db.localeDevMode) or rawget(_G, "HORIZON_LOCALE_DEV")) then return end
    local isEnUS = GetLocale() == "enUS"
    local count  = 0
    for k, v in pairs(L) do
        -- enUS is the source language: every key is inherently translated.
        -- For other locales, compare against the snapshot to detect overrides.
        if isEnUS or not (enUS and enUS[k] == v) then
            rawset(L, k, "|cff00ff00[" .. tostring(k) .. "] " .. tostring(v) .. "|r")
        else
            rawset(L, k, "|cffff8800[" .. tostring(k) .. "] " .. tostring(v) .. "|r")
            count = count + 1
        end
    end
    -- Keys not in L at all (missing even from enUS) show red via __index.
    -- L[nil] calls are silenced in the UI but printed with a stack trace.
    setmetatable(L, {
        __index = function(_, k)
            if k == nil then
                print("|cffff0000[HS Locale]|r L[nil] called:\n" .. debugstack())
                return ""
            end
            return "|cffff0000[" .. tostring(k) .. "]|r"
        end,
    })
    print("|cFF00CCFFHorizon Suite:|r |cffff8800Locale dev mode ON|r — " .. count .. " untranslated keys shown in orange. /reload to turn off.")
end)
