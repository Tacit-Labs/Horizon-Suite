--[[
    Horizon Suite - Augment - Events
    Event registration and dispatch for loot, money, currency, reputation.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment then return end

local Y = addon.Augment
local y = addon.Augment.state

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
    -- The loot window skin watches for Blizzard_LootFrame itself
    -- (AugmentLootWindowSkin.lua), since it can run with these events off.
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

-- Auto-loot opens Blizzard's loot window, empties it and closes it within a
-- fraction of a second, which reads as a second toast beside Augment's own.
-- Keep the window invisible while auto-loot runs. If it is still open after
-- AUTOLOOT_REVEAL_DELAY (full bags, a unique item already owned), show it so
-- no loot is hidden.
local AUTOLOOT_REVEAL_DELAY = 1
local autoLootHidden = false
local autoLootToken  = 0

local function RevealLootWindow()
    if not autoLootHidden then return end
    autoLootHidden = false
    local frame = _G.LootFrame
    if frame then frame:SetAlpha(1) end
end

-- The loot window fades in on open, and a playing alpha animation overrides
-- SetAlpha. Stop any that are playing, and hook each group so one that starts
-- after we hid the window is stopped too.
local alphaHookInstalled = false

local function StopLootWindowFade(frame)
    -- A fade driven by UIFrameFadeIn calls SetAlpha every frame instead.
    if not alphaHookInstalled then
        alphaHookInstalled = true
        hooksecurefunc(frame, "SetAlpha", function(self, alpha)
            if autoLootHidden and alpha ~= 0 then self:SetAlpha(0) end
        end)
    end
    for _, group in ipairs({ frame:GetAnimationGroups() }) do
        if not group._hsAutoLootHooked then
            group._hsAutoLootHooked = true
            group:HookScript("OnPlay", function(self)
                if autoLootHidden then
                    self:Stop()
                    frame:SetAlpha(0)
                end
            end)
        end
        if group:IsPlaying() then group:Stop() end
    end
end

-- LOOT_READY arrives before the window is shown, so setting alpha there means
-- the window is never drawn visible. LOOT_OPENED repeats it as a fallback and
-- re-arms the reveal timer.
local function HideForAutoLoot(autoLoot)
    local frame = _G.LootFrame
    if not (autoLoot and frame) then return end
    autoLootHidden = true
    StopLootWindowFade(frame)
    frame:SetAlpha(0)
    autoLootToken = autoLootToken + 1
    local token = autoLootToken
    C_Timer.After(AUTOLOOT_REVEAL_DELAY, function()
        if token == autoLootToken then RevealLootWindow() end
    end)
end
handlers.LOOT_READY  = HideForAutoLoot
handlers.LOOT_OPENED = HideForAutoLoot
handlers.LOOT_CLOSED = RevealLootWindow

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
    eventFrame:RegisterEvent("LOOT_READY")
    eventFrame:RegisterEvent("LOOT_OPENED")
    eventFrame:RegisterEvent("LOOT_CLOSED")
    eventsRegistered = true
end

function Y.DisableEvents()
    if not eventsRegistered then return end
    if eventFrame then
        eventFrame:UnregisterAllEvents()
    end
    ClearQueues()
    -- LOOT_CLOSED no longer reaches us, so don't leave the window invisible.
    RevealLootWindow()
    eventsRegistered = false
end

--- Bring loot toasts and the loot window skin in line with the Loot Frame
--- master switch and its two parts. Either part can run without the other.
--- Callers check the augment module is on: during OnEnable it is not yet
--- marked enabled, so this cannot ask IsModuleEnabled itself.
--- @return nil
function Y.ApplyLootFrameState()
    local GetDB = addon.GetDB
    local function on(key) return not GetDB or GetDB(key, true) ~= false end
    local masterOn = on("augmentLootFrameEnabled")
    if masterOn and on("augmentLootToastsEnabled") then
        Y.EnableEvents()
        if Y.ApplyBlizzardSuppression then Y.ApplyBlizzardSuppression() end
    else
        Y.DisableEvents()
        if Y.RestoreBlizzard then Y.RestoreBlizzard() end
        if Y.ClearActiveToasts then Y.ClearActiveToasts() end
    end
    if masterOn and on("augmentLootWindowSkinEnabled") then
        if Y.EnableLootWindowSkin then Y.EnableLootWindowSkin() end
    else
        if Y.DisableLootWindowSkin then Y.DisableLootWindowSkin() end
    end
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
