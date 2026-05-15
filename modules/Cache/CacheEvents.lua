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

-- ============================================================================
-- COMBAT DEFERRAL
-- ============================================================================

local inCombat = false
local combatQueue = {}

local function FlushCombatQueue()
    if #combatQueue == 0 then return end
    local queue = combatQueue
    combatQueue = {}
    for i, data in ipairs(queue) do
        C_Timer.After((i - 1) * 0.08, function() Y.ShowToast(data) end)
    end
end

-- ============================================================================
-- COALESCING QUEUE
-- Loot events arriving in the same tick are staggered so the pool stack
-- animation doesn't receive them all at position 0 simultaneously.
-- ============================================================================

local COALESCE_STAGGER = 0.08
local lootQueue        = {}
local lootFlushPending = false

local function FlushLootQueue()
    lootFlushPending = false
    local queue = lootQueue
    lootQueue = {}
    for i, data in ipairs(queue) do
        if inCombat then
            combatQueue[#combatQueue + 1] = data
        elseif i == 1 then
            Y.ShowToast(data)
        else
            C_Timer.After((i - 1) * COALESCE_STAGGER, function()
                if inCombat then
                    combatQueue[#combatQueue + 1] = data
                else
                    Y.ShowToast(data)
                end
            end)
        end
    end
end

local function EnqueueLootToast(data)
    lootQueue[#lootQueue + 1] = data
    if not lootFlushPending then
        lootFlushPending = true
        C_Timer.After(0, FlushLootQueue)
    end
end

local function ClearQueues()
    lootQueue        = {}
    lootFlushPending = false
    combatQueue      = {}
end

-- ============================================================================
-- EVENT HANDLER
-- ============================================================================

local function OnEvent(self, event, msg, ...)
    if event == "ADDON_LOADED" then
        -- Re-suppress after lazy Blizzard frames load in.
        local loaded = msg
        if (loaded == "Blizzard_AlertFrames" or loaded == "Blizzard_LootFrame")
            and addon:IsModuleEnabled("cache") and Y.SuppressBlizzard
        then
            Y.SuppressBlizzard()
        end

    elseif event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        y.playerGUID = UnitGUID("player")
        if not y.patternsOK and Y.InitPatterns then
            Y.InitPatterns()
        end
        if addon:IsModuleEnabled("cache") and Y.SuppressBlizzard then
            Y.SuppressBlizzard()
        end

    elseif event == "PLAYER_REGEN_DISABLED" then
        inCombat = true

    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
        C_Timer.After(0.5, FlushCombatQueue)

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
        if data then
            if inCombat then
                combatQueue[#combatQueue + 1] = data
            else
                Y.ShowToast(data)
            end
        end

    -- Epic/legendary loot toast events: kill the Blizzard popup without polling.
    elseif event == "SHOW_LOOT_TOAST"
        or event == "SHOW_LOOT_TOAST_UPGRADE"
        or event == "SHOW_LOOT_TOAST_LEGENDARY_LOOTED"
        or event == "LOOT_ITEM_ROLL_WON"
    then
        if Y.KillDynamicItemRevealPopup then
            C_Timer.After(0.1, Y.KillDynamicItemRevealPopup)
            C_Timer.After(0.4, Y.KillDynamicItemRevealPopup)
        end
    end
end

-- ============================================================================
-- ENABLE / DISABLE
-- ============================================================================

function Y.EnableEvents()
    if eventsRegistered then return end
    if not eventFrame then
        eventFrame = CreateFrame("Frame")
        eventFrame:SetScript("OnEvent", OnEvent)
    end
    y.playerGUID = UnitGUID("player")
    if not y.patternsOK and Y.InitPatterns then
        Y.InitPatterns()
    end
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:RegisterEvent("PLAYER_LOGIN")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:RegisterEvent("CHAT_MSG_LOOT")
    eventFrame:RegisterEvent("CHAT_MSG_MONEY")
    eventFrame:RegisterEvent("CHAT_MSG_CURRENCY")
    eventFrame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
    pcall(eventFrame.RegisterEvent, eventFrame, "SHOW_LOOT_TOAST")
    pcall(eventFrame.RegisterEvent, eventFrame, "SHOW_LOOT_TOAST_UPGRADE")
    pcall(eventFrame.RegisterEvent, eventFrame, "SHOW_LOOT_TOAST_LEGENDARY_LOOTED")
    pcall(eventFrame.RegisterEvent, eventFrame, "LOOT_ITEM_ROLL_WON")
    eventsRegistered = true
end

function Y.DisableEvents()
    if not eventsRegistered then return end
    if eventFrame then
        eventFrame:UnregisterAllEvents()
    end
    ClearQueues()
    inCombat = false
    eventsRegistered = false
end
