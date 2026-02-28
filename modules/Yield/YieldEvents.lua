--[[
    Horizon Suite - Yield - Events
    Event registration and dispatch for loot, money, currency, reputation.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.Yield then return end

local Y = addon.Yield
local y = addon.yield

local eventFrame
local eventsRegistered = false

local function OnEvent(self, event, msg, ...)
    if event == "ADDON_LOADED" then
        local loaded = msg
        if loaded == addon.ADDON_NAME then
            Y.RestoreSavedPosition()
        end
        if loaded == "Blizzard_AlertFrames" or loaded == "Blizzard_LootFrame" then
            if addon:IsModuleEnabled("yield") and Y.SuppressBlizzard then
                Y.SuppressBlizzard()
            end
        end

    elseif event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        y.playerGUID = UnitGUID("player")
        if not y.patternsOK and Y.InitPatterns then
            Y.InitPatterns()
        end
        if addon:IsModuleEnabled("yield") and Y.SuppressBlizzard then
            Y.SuppressBlizzard()
        end

    elseif event == "CHAT_MSG_LOOT" then
        if not y.patternsOK then return end
        local guid = select(11, ...)
        if guid == "" then guid = nil end
        if guid and y.playerGUID then
            if guid ~= y.playerGUID then return end
        elseif not Y.IsSelfLoot(msg) then
            return
        end
        if y.debugMode then
            print("|cFF00CCFFYield debug LOOT:|r guid=" .. tostring(guid)
                .. " match=" .. tostring(guid == y.playerGUID)
                .. " msg=" .. tostring(msg):sub(1, 120))
        end
        local data = Y.ParseItemLoot(msg)
        if data then Y.ShowToast(data) end

    elseif event == "CHAT_MSG_MONEY" then
        if not y.patternsOK then return end
        local data = Y.ParseMoney(msg)
        if data then Y.ShowToast(data) end

    elseif event == "CHAT_MSG_CURRENCY" then
        if not y.patternsOK then return end
        local data = Y.ParseCurrency(msg)
        if data then Y.ShowToast(data) end

    elseif event == "CHAT_MSG_COMBAT_FACTION_CHANGE" then
        if not y.patternsOK then return end
        local data = Y.ParseReputation(msg)
        if data then Y.ShowToast(data) end
    end
end

function Y.EnableEvents()
    if eventsRegistered then return end
    if not eventFrame then
        eventFrame = CreateFrame("Frame")
        eventFrame:SetScript("OnEvent", OnEvent)
    end
    -- Init patterns immediately if player already logged in (e.g. module enabled after load)
    y.playerGUID = UnitGUID("player")
    if not y.patternsOK and Y.InitPatterns then
        Y.InitPatterns()
    end
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:RegisterEvent("PLAYER_LOGIN")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("CHAT_MSG_LOOT")
    eventFrame:RegisterEvent("CHAT_MSG_MONEY")
    eventFrame:RegisterEvent("CHAT_MSG_CURRENCY")
    eventFrame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
    eventsRegistered = true
end

function Y.DisableEvents()
    if not eventsRegistered then return end
    if eventFrame then
        eventFrame:UnregisterAllEvents()
    end
    eventsRegistered = false
end
