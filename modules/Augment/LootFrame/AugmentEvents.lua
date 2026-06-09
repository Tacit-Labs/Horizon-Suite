--[[
    Horizon Suite - Augment - Events
    Event registration and dispatch for loot, money, currency, reputation.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment then return end

local Y = addon.Augment
local y = addon.augment

local eventFrame
local eventsRegistered = false

-- ============================================================================
-- COALESCING QUEUE
-- Loot events arriving in the same tick are staggered so the pool stack
-- animation doesn't receive them all at position 0 simultaneously.
-- ============================================================================

local augmentPanel = addon.Log.createPanel("augment", "Augment Debug", { maxLines = 300,
    onClose = function()
        if addon.SetDB then addon.SetDB("augmentDebugLive", false) end
        addon.Log.enableTag("augment", nil)
    end,
})
addon.Log.registerTag("augment", "augmentDebugLive")

local COALESCE_STAGGER = 0.08
local lootQueue        = {}
local lootFlushPending = false

local function FlushLootQueue()
    lootFlushPending = false
    local queue = lootQueue
    lootQueue = {}
    addon.Log.debug("augment", "FlushLootQueue — " .. #queue .. " item(s)")
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
    addon.Log.debug("augment", "Enqueue — type=" .. tostring(data and data.type) .. " q=" .. #lootQueue)
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
        and addon:IsModuleEnabled("augment") and Y.ApplyBlizzardSuppression
    then
        Y.ApplyBlizzardSuppression()
    end
end

local function OnPlayerReady()
    y.playerGUID = UnitGUID("player")
    if not y.patternsOK and Y.InitPatterns then Y.InitPatterns() end
    if addon:IsModuleEnabled("augment") and Y.ApplyBlizzardSuppression then Y.ApplyBlizzardSuppression() end
end
handlers.PLAYER_LOGIN          = OnPlayerReady
handlers.PLAYER_ENTERING_WORLD = OnPlayerReady


handlers.CHAT_MSG_LOOT = function(msg, ...)
    if not y.patternsOK then return end
    if addon.GetDB("augmentShowItems", true) == false then return end
    local rawGuid = select(11, ...)
    -- CHAT_MSG_LOOT's 11th arg is a secret string in tainted execution.
    -- tostring() does NOT strip the secret flag, so == / ~= still throw.
    -- Wrap every comparison in pcall to extract plain booleans:
    --   guidKnownMatch    = comparison succeeded and GUIDs are equal
    --   guidKnownMismatch = comparison succeeded and GUIDs differ → skip
    --   both false        = comparison threw (secret string) → fall back to IsSelfLoot
    local guid = nil
    if rawGuid then
        pcall(function()
            if rawGuid ~= "" then guid = rawGuid end
        end)
    end
    local guidKnownMatch    = false
    local guidKnownMismatch = false
    if guid and y.playerGUID then
        pcall(function()
            if guid == y.playerGUID then
                guidKnownMatch = true
            else
                guidKnownMismatch = true
            end
        end)
    end
    if guidKnownMismatch then return end
    if not guidKnownMatch then
        if not Y.IsSelfLoot(msg) then return end
    end
    if Y.IsPushedLoot(msg) and addon.GetDB("augmentShowPushedItems", addon.AUGMENT_DEFAULTS.augmentShowPushedItems) == false then return end
    addon.Log.debug("augment", "LOOT guid=" .. tostring(rawGuid) .. " match=" .. tostring(guidKnownMatch) .. " " .. tostring(msg):sub(1, 80))
    local data = Y.ParseItemLoot(msg)
    if data then
        local minQ = (addon.GetDB and tonumber(addon.GetDB("augmentMinQuality", 0))) or 0
        if (data.quality or 1) >= minQ then
            EnqueueLootToast(data)
        else
            addon.Log.debug("augment", "LOOT filtered — quality=" .. tostring(data.quality) .. " < minQ=" .. minQ)
        end
    end
end

handlers.CHAT_MSG_MONEY = function(msg)
    if not y.patternsOK then return end
    if addon.GetDB("augmentShowMoney", true) == false then return end
    local data = Y.ParseMoney(msg)
    if data then
        addon.Log.debug("augment", "MONEY — " .. tostring(msg):sub(1, 60))
        EnqueueLootToast(data)
    end
end

handlers.CHAT_MSG_CURRENCY = function(msg)
    if not y.patternsOK then return end
    if addon.GetDB("augmentShowCurrency", true) == false then return end
    local data = Y.ParseCurrency(msg)
    if data then
        addon.Log.debug("augment", "CURRENCY — " .. tostring(msg):sub(1, 60))
        EnqueueLootToast(data)
    end
end

handlers.CHAT_MSG_COMBAT_FACTION_CHANGE = function(msg)
    if not y.patternsOK then return end
    if addon.GetDB("augmentShowRep", true) == false then return end
    local data = Y.ParseReputation(msg)
    if data then
        addon.Log.debug("augment", "REP — " .. tostring(msg):sub(1, 60))
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

local function OnBlizzardLootToast() StartKillTicker() end
handlers.SHOW_LOOT_TOAST                  = OnBlizzardLootToast
handlers.SHOW_LOOT_TOAST_UPGRADE          = OnBlizzardLootToast
handlers.SHOW_LOOT_TOAST_LEGENDARY_LOOTED = OnBlizzardLootToast
handlers.LOOT_ITEM_ROLL_WON               = OnBlizzardLootToast
handlers.BONUS_LOOT_ITEM_RECEIVED         = OnBlizzardLootToast
-- Scenario/quest completions can reward items via popups that bypass SHOW_LOOT_TOAST.
handlers.SCENARIO_COMPLETED               = OnBlizzardLootToast
handlers.QUEST_TURNED_IN                  = OnBlizzardLootToast

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
    if addon.SetDB then addon.SetDB("augmentDebugLive", v) end
    addon.Log.enableTag("augment", v or nil)
    if v then
        augmentPanel.Show()
        addon.Log.debug("augment", "Live debug enabled")
    else
        augmentPanel.Hide()
    end
end
