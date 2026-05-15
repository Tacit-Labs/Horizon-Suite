--[[
    Horizon Suite - Cache - Events
    Event registration and dispatch for loot, money, currency, reputation.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Cache then return end

local Y = addon.Cache
local y = addon.cache

local eventFrame
local eventsRegistered = false

-- Coalescing queue: loot events that fire in the same tick are staggered so
-- the pool animation doesn't eat them all at position 0 simultaneously.
local COALESCE_STAGGER = 0.08  -- seconds between toasts in a burst
local lootQueue = {}
local lootFlushPending = false

local function FlushLootQueue()
    lootFlushPending = false
    for i, data in ipairs(lootQueue) do
        if i == 1 then
            Y.ShowToast(data)
        else
            C_Timer.After((i - 1) * COALESCE_STAGGER, function() Y.ShowToast(data) end)
        end
    end
    lootQueue = {}
end

local function EnqueueLootToast(data)
    lootQueue[#lootQueue + 1] = data
    if not lootFlushPending then
        lootFlushPending = true
        C_Timer.After(0, FlushLootQueue)
    end
end

local function OnEvent(self, event, msg, ...)
    if event == "ADDON_LOADED" then
        local loaded = msg
        if loaded == addon.ADDON_NAME then
            Y.RestoreSavedPosition()
        end
        if loaded == "Blizzard_AlertFrames" or loaded == "Blizzard_LootFrame" then
            if addon:IsModuleEnabled("cache") and Y.SuppressBlizzard then
                Y.SuppressBlizzard()
            end
        end

    elseif event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        y.playerGUID = UnitGUID("player")
        if not y.patternsOK and Y.InitPatterns then
            Y.InitPatterns()
        end
        if addon:IsModuleEnabled("cache") and Y.SuppressBlizzard then
            Y.SuppressBlizzard()
        end

    elseif event == "CHAT_MSG_LOOT" then
        if not y.patternsOK then return end
        if addon.GetDB("cacheShowItems", true) == false then return end
        local guid = select(11, ...)
        if guid == "" then guid = nil end
        if guid and y.playerGUID then
            if guid ~= y.playerGUID then return end
        elseif not Y.IsSelfLoot(msg) then
            return
        end
        if y.debugMode then
            print("|cFF00CCFFCache debug LOOT:|r guid=" .. tostring(guid)
                .. " match=" .. tostring(guid == y.playerGUID)
                .. " msg=" .. tostring(msg):sub(1, 120))
        end
        local data = Y.ParseItemLoot(msg)
        if data then EnqueueLootToast(data) end

    elseif event == "CHAT_MSG_MONEY" then
        if not y.patternsOK then return end
        if addon.GetDB("cacheShowMoney", true) == false then return end
        local data = Y.ParseMoney(msg)
        if data then EnqueueLootToast(data) end

    elseif event == "CHAT_MSG_CURRENCY" then
        if not y.patternsOK then return end
        if addon.GetDB("cacheShowCurrency", true) == false then return end
        local data = Y.ParseCurrency(msg)
        if data then EnqueueLootToast(data) end

    elseif event == "CHAT_MSG_COMBAT_FACTION_CHANGE" then
        if not y.patternsOK then return end
        if addon.GetDB("cacheShowRep", true) == false then return end
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
