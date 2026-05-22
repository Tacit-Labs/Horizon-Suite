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
-- COALESCING QUEUE
-- Loot events arriving in the same tick are staggered so the pool stack
-- animation doesn't receive them all at position 0 simultaneously.
-- ============================================================================

local cachePanel = addon.Log.createPanel("cache", "Cache Debug", { maxLines = 300,
    onClose = function()
        if addon.SetDB then addon.SetDB("cacheDebugLive", false) end
        addon.Log.enableTag("cache", nil)
    end,
})
addon.Log.registerTag("cache", "cacheDebugLive")

local COALESCE_STAGGER = 0.08
local lootQueue        = {}
local lootFlushPending = false

local function FlushLootQueue()
    lootFlushPending = false
    local queue = lootQueue
    lootQueue = {}
    addon.Log.debug("cache", "FlushLootQueue — " .. #queue .. " item(s)")
    for i, data in ipairs(queue) do
        if i == 1 then
            Y.ShowToast(data)
        else
            C_Timer.After((i - 1) * COALESCE_STAGGER, function()
                Y.ShowToast(data)
            end)
        end
    end
end

local function EnqueueLootToast(data)
    lootQueue[#lootQueue + 1] = data
    addon.Log.debug("cache", "Enqueue — type=" .. tostring(data and data.type) .. " q=" .. #lootQueue)
    if not lootFlushPending then
        lootFlushPending = true
        C_Timer.After(0, FlushLootQueue)
    end
end

local function ClearQueues()
    lootQueue        = {}
    lootFlushPending = false
end

-- ============================================================================
-- EVENT HANDLERS
-- ============================================================================

local handlers = {}

handlers.ADDON_LOADED = function(msg)
    -- Re-suppress after lazy Blizzard frames load in.
    if (msg == "Blizzard_AlertFrames" or msg == "Blizzard_LootFrame" or msg == "Blizzard_ContainerOpeningUI")
        and addon:IsModuleEnabled("cache") and Y.ApplyBlizzardSuppression
    then
        Y.ApplyBlizzardSuppression()
    end
end

local function OnPlayerReady()
    y.playerGUID = UnitGUID("player")
    if not y.patternsOK and Y.InitPatterns then Y.InitPatterns() end
    if addon:IsModuleEnabled("cache") and Y.ApplyBlizzardSuppression then Y.ApplyBlizzardSuppression() end
end
handlers.PLAYER_LOGIN          = OnPlayerReady
handlers.PLAYER_ENTERING_WORLD = OnPlayerReady


handlers.CHAT_MSG_LOOT = function(msg, ...)
    if not y.patternsOK then return end
    if addon.GetDB("cacheShowItems", true) == false then return end
    local guid = select(11, ...)
    if guid == "" then guid = nil end
    if guid and y.playerGUID then
        if guid ~= y.playerGUID then return end
    elseif not Y.IsSelfLoot(msg) then
        return
    end
    if Y.IsPushedLoot(msg) and addon.GetDB("cacheShowPushedItems", addon.CACHE_DEFAULTS.cacheShowPushedItems) == false then return end
    addon.Log.debug("cache", "LOOT guid=" .. tostring(guid) .. " match=" .. tostring(guid == y.playerGUID) .. " " .. tostring(msg):sub(1, 80))
    local data = Y.ParseItemLoot(msg)
    if data then
        local minQ = (addon.GetDB and tonumber(addon.GetDB("cacheMinQuality", 0))) or 0
        if (data.quality or 1) >= minQ then
            EnqueueLootToast(data)
        else
            addon.Log.debug("cache", "LOOT filtered — quality=" .. tostring(data.quality) .. " < minQ=" .. minQ)
        end
    end
end

handlers.CHAT_MSG_MONEY = function(msg)
    if not y.patternsOK then return end
    if addon.GetDB("cacheShowMoney", true) == false then return end
    local data = Y.ParseMoney(msg)
    if data then
        addon.Log.debug("cache", "MONEY — " .. tostring(msg):sub(1, 60))
        EnqueueLootToast(data)
    end
end

handlers.CHAT_MSG_CURRENCY = function(msg)
    if not y.patternsOK then return end
    if addon.GetDB("cacheShowCurrency", true) == false then return end
    local data = Y.ParseCurrency(msg)
    if data then
        addon.Log.debug("cache", "CURRENCY — " .. tostring(msg):sub(1, 60))
        EnqueueLootToast(data)
    end
end

handlers.CHAT_MSG_COMBAT_FACTION_CHANGE = function(msg)
    if not y.patternsOK then return end
    if addon.GetDB("cacheShowRep", true) == false then return end
    local data = Y.ParseReputation(msg)
    if data then
        addon.Log.debug("cache", "REP — " .. tostring(msg):sub(1, 60))
        Y.ShowToast(data)
    end
end

-- Rolling kill ticker: fires KillDynamicItemRevealPopup every 0.2s for 5s.
-- Covers animated chests (slow reveal), instant event rewards, and anything
-- in between. Any new loot/reward event resets and extends the window.
local killTicker = nil
local KILL_INTERVAL = 0.2
local KILL_DURATION = 5.0

local function StartKillTicker()
    if not Y.KillDynamicItemRevealPopup then return end
    if killTicker then killTicker:Cancel(); killTicker = nil end
    Y.KillDynamicItemRevealPopup()  -- immediate pass before first tick
    -- Deferred pass: catches frames Blizzard creates in the same event cycle as us,
    -- after all same-tick handlers have finished.
    C_Timer.After(0, function() if Y.KillDynamicItemRevealPopup then Y.KillDynamicItemRevealPopup() end end)
    local elapsed = 0
    killTicker = C_Timer.NewTicker(KILL_INTERVAL, function()
        elapsed = elapsed + KILL_INTERVAL
        Y.KillDynamicItemRevealPopup()
        if elapsed >= KILL_DURATION then
            if killTicker then killTicker:Cancel() end
            killTicker = nil
        end
    end)
end

local function OnBlizzardLootToast()
    if not (addon.GetDB and addon.GetDB("cacheSuppressBlizzard", true)) then return end
    StartKillTicker()
end
handlers.SHOW_LOOT_TOAST                  = OnBlizzardLootToast
handlers.SHOW_LOOT_TOAST_UPGRADE          = OnBlizzardLootToast
handlers.SHOW_LOOT_TOAST_LEGENDARY_LOOTED = OnBlizzardLootToast
handlers.LOOT_ITEM_ROLL_WON               = OnBlizzardLootToast
handlers.BONUS_LOOT_ITEM_RECEIVED         = OnBlizzardLootToast
-- Scenario/quest completions can reward items via popups that bypass SHOW_LOOT_TOAST.
handlers.SCENARIO_COMPLETED               = OnBlizzardLootToast
handlers.QUEST_TURNED_IN                  = OnBlizzardLootToast
-- PvP loot toasts.
handlers.SHOW_PVP_FACTION_LOOT_TOAST      = OnBlizzardLootToast
handlers.SHOW_RATED_PVP_REWARD_TOAST      = OnBlizzardLootToast
-- Quest / specialised loot toasts.
handlers.QUEST_LOOT_RECEIVED              = OnBlizzardLootToast
handlers.AZERITE_EMPOWERED_ITEM_LOOTED    = OnBlizzardLootToast
handlers.PERKS_PROGRAM_CURRENCY_AWARDED   = OnBlizzardLootToast
-- Housing toasts (INITIATIVE_TASK_COMPLETED via AlertFrame; NEW_HOUSING_ITEM_ACQUIRED via EventRegistry).
handlers.INITIATIVE_TASK_COMPLETED        = OnBlizzardLootToast
handlers.NEW_HOUSING_ITEM_ACQUIRED        = OnBlizzardLootToast
-- TWW warband-bank / decoration push.
handlers.HOME_DECORATION_ADDED            = OnBlizzardLootToast
handlers.SHOW_LOOT_TOAST_ITEM_PUSH        = OnBlizzardLootToast

local function OnEvent(_, event, msg, ...)
    local handler = handlers[event]
    if handler then handler(msg, ...) end
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
    eventFrame:RegisterEvent("CHAT_MSG_LOOT")
    eventFrame:RegisterEvent("CHAT_MSG_MONEY")
    eventFrame:RegisterEvent("CHAT_MSG_CURRENCY")
    eventFrame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
    pcall(eventFrame.RegisterEvent, eventFrame, "SHOW_LOOT_TOAST")
    pcall(eventFrame.RegisterEvent, eventFrame, "SHOW_LOOT_TOAST_UPGRADE")
    pcall(eventFrame.RegisterEvent, eventFrame, "SHOW_LOOT_TOAST_LEGENDARY_LOOTED")
    pcall(eventFrame.RegisterEvent, eventFrame, "LOOT_ITEM_ROLL_WON")
    pcall(eventFrame.RegisterEvent, eventFrame, "BONUS_LOOT_ITEM_RECEIVED")
    pcall(eventFrame.RegisterEvent, eventFrame, "SCENARIO_COMPLETED")
    pcall(eventFrame.RegisterEvent, eventFrame, "QUEST_TURNED_IN")
    pcall(eventFrame.RegisterEvent, eventFrame, "SHOW_PVP_FACTION_LOOT_TOAST")
    pcall(eventFrame.RegisterEvent, eventFrame, "SHOW_RATED_PVP_REWARD_TOAST")
    pcall(eventFrame.RegisterEvent, eventFrame, "QUEST_LOOT_RECEIVED")
    pcall(eventFrame.RegisterEvent, eventFrame, "AZERITE_EMPOWERED_ITEM_LOOTED")
    pcall(eventFrame.RegisterEvent, eventFrame, "PERKS_PROGRAM_CURRENCY_AWARDED")
    pcall(eventFrame.RegisterEvent, eventFrame, "INITIATIVE_TASK_COMPLETED")
    -- NEW_HOUSING_ITEM_ACQUIRED fires via EventRegistry; suppressed in CacheBlizzard.lua.
    -- Register it here too so the kill-ticker fires if the EventRegistry path slips through.
    pcall(eventFrame.RegisterEvent, eventFrame, "NEW_HOUSING_ITEM_ACQUIRED")
    pcall(eventFrame.RegisterEvent, eventFrame, "HOME_DECORATION_ADDED")
    pcall(eventFrame.RegisterEvent, eventFrame, "SHOW_LOOT_TOAST_ITEM_PUSH")
    eventsRegistered = true
end

function Y.DisableEvents()
    if not eventsRegistered then return end
    if eventFrame then
        eventFrame:UnregisterAllEvents()
    end
    ClearQueues()
    eventsRegistered = false
end

function Y.SetDebugLive(v)
    if addon.SetDB then addon.SetDB("cacheDebugLive", v) end
    addon.Log.enableTag("cache", v or nil)
    if v then
        cachePanel.Show()
        addon.Log.debug("cache", "Live debug enabled")
    else
        cachePanel.Hide()
    end
end
