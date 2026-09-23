--[[
    Horizon Suite - Presence - Error Frame & Alert Interception
    UIErrorsFrame hook for "Discovered" and quest text. AlertFrame muting.
    APIs: hooksecurefunc, UIErrorsFrame, AlertFrame.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Presence then return end
local L = addon.L
-- ============================================================================
-- Private helpers
-- ============================================================================

local uiErrorsHooked = false

local function OnUIErrorsAddMessage(self, msg)
    local discoveredStr = L["PRESENCE_DISCOVERED"]
    if msg and msg:find(discoveredStr, 1, true) then
        addon.Presence.SetPendingDiscovery()
        local phase = addon.Presence.animPhase and addon.Presence.animPhase()
        if addon:IsModuleEnabled("presence") and phase and (phase == "entrance" or phase == "hold" or phase == "crossfade") then
            addon.Presence.ShowDiscoveryLine()
            addon.Presence.pendingDiscovery = nil
        end
        if self.Clear then self:Clear() end
        return
    end
    if addon.Presence.IsQuestText and addon.Presence.IsQuestText(msg) then
        if self.Clear then self:Clear() end
    end
end

-- ============================================================================
-- Public functions
-- ============================================================================

-- Hook UIErrorsFrame AddMessage to intercept "Discovered" and quest text. Idempotent.
-- @return nil
local function HookUIErrorsFrame()
    if uiErrorsHooked or not UIErrorsFrame then return end
    if hooksecurefunc then
        hooksecurefunc(UIErrorsFrame, "AddMessage", function(self, msg)
            if not addon:IsModuleEnabled("presence") then return end
            OnUIErrorsAddMessage(self, msg)
        end)
        uiErrorsHooked = true
    end
end

-- Clear hook state. Note: hooksecurefunc cannot be undone; callback no-ops when Presence disabled.
-- @return nil
local function UnhookUIErrorsFrame()
    -- hooksecurefunc cannot be undone; we simply stop acting in the callback when Presence is disabled
    -- The callback will remain but will no-op when addon:IsModuleEnabled("presence") is false
    uiErrorsHooked = false
end

-- ============================================================================
-- ALERT FRAME MUTING
-- ============================================================================

-- AlertFrame events Presence replaces, each paired with the notification type
-- whose option governs it. An event is unregistered only while its type is ON,
-- so switching that type off hands the alert back to Blizzard without needing
-- the whole module disabled. Ordered for deterministic application.
-- Only events AlertFrame itself registers belong here (AlertFrames.lua OnLoad):
-- restoring one it never listened to would hand it an event Blizzard didn't ask for.
-- QUEST_TURNED_IN feeds only WorldQuestCompleteAlertSystem - a regular turn-in
-- never toasts on AlertFrame - so the world quest option governs it.
local ALERT_EVENT_TYPES = {
    { event = "ACHIEVEMENT_EARNED", type = "ACHIEVEMENT" },
    { event = "CRITERIA_EARNED",    type = "ACHIEVEMENT_PROGRESS" },
    { event = "QUEST_TURNED_IN",    type = "WORLD_QUEST" },
}

local alertEventsUnregistered = {}

local function AlertFrameSupportsRegistration()
    return AlertFrame and AlertFrame.RegisterEvent and AlertFrame.UnregisterEvent
end

local function IsAlertTypeEnabled(typeName)
    local P = addon.Presence
    if not (P and P.IsTypeEnabledForType) then return false end
    return P.IsTypeEnabledForType(typeName) and true or false
end

-- Mute or restore each AlertFrame event according to its type's option.
-- Callers gate on the module, not this function: OnEnable runs before EnableModule
-- flags the module on, so an IsModuleEnabled check here would make it a no-op.
-- Idempotent; safe to call on every option change.
-- @return nil
local function ApplyAlertMuting()
    if not AlertFrameSupportsRegistration() then return end
    for _, entry in ipairs(ALERT_EVENT_TYPES) do
        local shouldMute = IsAlertTypeEnabled(entry.type)
        local isMuted = alertEventsUnregistered[entry.event] and true or false
        if shouldMute ~= isMuted then
            -- pcall: AlertFrame methods can throw on some flavours.
            local method = shouldMute and AlertFrame.UnregisterEvent or AlertFrame.RegisterEvent
            local ok, err = pcall(method, AlertFrame, entry.event)
            if ok then
                alertEventsUnregistered[entry.event] = shouldMute or nil
            elseif addon.HSPrint then
                addon.HSPrint("Presence ApplyAlertMuting failed for " .. entry.event .. ": " .. tostring(err))
            end
        end
    end
end

-- True when every AlertFrame event Presence governs is currently muted.
-- Callers that clear AlertFrame wholesale must check this first: once any event
-- is handed back to Blizzard, wiping the queue would swallow the alert instead.
-- @return boolean
local function AreAllAlertsMuted()
    for _, entry in ipairs(ALERT_EVENT_TYPES) do
        if not alertEventsUnregistered[entry.event] then return false end
    end
    return true
end

-- Per-event mute state, read from what was actually (un)registered rather than
-- from the options, so a failed call shows up in the suppression debug dump.
-- @return table Array of { event, type, muted } in application order
local function GetAlertMuteState()
    local out = {}
    for i, entry in ipairs(ALERT_EVENT_TYPES) do
        out[i] = { event = entry.event, type = entry.type, muted = alertEventsUnregistered[entry.event] and true or false }
    end
    return out
end

-- Re-register every muted AlertFrame event when Presence is disabled.
-- @return nil
local function RestoreAlerts()
    if not AlertFrameSupportsRegistration() then return end
    for _, entry in ipairs(ALERT_EVENT_TYPES) do
        if alertEventsUnregistered[entry.event] then
            -- pcall: AlertFrame methods can throw on some flavours.
            local ok, err = pcall(AlertFrame.RegisterEvent, AlertFrame, entry.event)
            if ok then
                alertEventsUnregistered[entry.event] = nil
            elseif addon.HSPrint then
                addon.HSPrint("Presence RestoreAlerts failed for " .. entry.event .. ": " .. tostring(err))
            end
        end
    end
end

-- ============================================================================
-- Exports
-- ============================================================================

addon.Presence.HookUIErrorsFrame   = HookUIErrorsFrame
addon.Presence.UnhookUIErrorsFrame = UnhookUIErrorsFrame
addon.Presence.ApplyAlertMuting    = ApplyAlertMuting
addon.Presence.AreAllAlertsMuted   = AreAllAlertsMuted
addon.Presence.GetAlertMuteState   = GetAlertMuteState
addon.Presence.RestoreAlerts       = RestoreAlerts
