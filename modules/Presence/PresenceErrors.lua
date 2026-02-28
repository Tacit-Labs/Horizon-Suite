--[[
    Horizon Suite - Presence - Error Frame & Alert Interception
    UIErrorsFrame hook for "Discovered" and quest text. AlertFrame muting.
    APIs: hooksecurefunc, UIErrorsFrame, AlertFrame.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.Presence then return end

-- ============================================================================
-- Private helpers
-- ============================================================================

local uiErrorsHooked = false

local function OnUIErrorsAddMessage(self, msg)
    if msg and msg:find("Discovered") then
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

--- Hook UIErrorsFrame AddMessage to intercept "Discovered" and quest text. Idempotent.
--- @return nil
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

--- Clear hook state. Note: hooksecurefunc cannot be undone; callback no-ops when Presence disabled.
--- @return nil
local function UnhookUIErrorsFrame()
    -- hooksecurefunc cannot be undone; we simply stop acting in the callback when Presence is disabled
    -- The callback will remain but will no-op when addon:IsModuleEnabled("presence") is false
    uiErrorsHooked = false
end

-- ============================================================================
-- ALERT FRAME MUTING
-- ============================================================================

local alertsMuted = false
local alertEventsUnregistered = {}

--- Unregister AlertFrame from ACHIEVEMENT_EARNED and QUEST_TURNED_IN so Presence can replace them. Idempotent.
--- @return nil
local function MuteAlerts()
    if alertsMuted then return end
    -- pcall: AlertFrame may not exist or methods may throw.
    pcall(function()
        if AlertFrame and AlertFrame.UnregisterEvent then
            AlertFrame:UnregisterEvent("ACHIEVEMENT_EARNED")
            alertEventsUnregistered["ACHIEVEMENT_EARNED"] = true
            AlertFrame:UnregisterEvent("QUEST_TURNED_IN")
            alertEventsUnregistered["QUEST_TURNED_IN"] = true
        end
    end)
    alertsMuted = true
end

--- Re-register AlertFrame events when Presence is disabled.
--- @return nil
local function RestoreAlerts()
    if not alertsMuted then return end
    -- pcall: AlertFrame may not exist or methods may throw.
    pcall(function()
        if AlertFrame and AlertFrame.RegisterEvent then
            if alertEventsUnregistered["ACHIEVEMENT_EARNED"] then
                AlertFrame:RegisterEvent("ACHIEVEMENT_EARNED")
                alertEventsUnregistered["ACHIEVEMENT_EARNED"] = nil
            end
            if alertEventsUnregistered["QUEST_TURNED_IN"] then
                AlertFrame:RegisterEvent("QUEST_TURNED_IN")
                alertEventsUnregistered["QUEST_TURNED_IN"] = nil
            end
        end
    end)
    alertsMuted = false
end

-- ============================================================================
-- Exports
-- ============================================================================

addon.Presence.HookUIErrorsFrame   = HookUIErrorsFrame
addon.Presence.UnhookUIErrorsFrame = UnhookUIErrorsFrame
addon.Presence.MuteAlerts         = MuteAlerts
addon.Presence.RestoreAlerts      = RestoreAlerts
