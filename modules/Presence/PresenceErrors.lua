--[[
    Horizon Suite - Presence - Error Frame & Alert Interception
    UIErrorsFrame hook for "Discovered" and quest text. AlertFrame muting.
    APIs: hooksecurefunc, UIErrorsFrame, AlertFrame.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- ============================================================================
-- Private helpers
-- ============================================================================

local uiErrorsHooked = false

local function OnUIErrorsAddMessage(self, msg)
    local discoveredStr = (addon.L and addon.L["PRESENCE_DISCOVERED"]) or "Discovered"
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

--- Unregister AlertFrame from achievement/quest/criteria events so Presence can replace them.
--- Includes CRITERIA_UPDATE, TRACKED_ACHIEVEMENT_UPDATE, and CRITERIA_EARNED to suppress
--- Blizzard's default achievement-progress popups (CriteriaAlertSystem). Idempotent.
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
            AlertFrame:UnregisterEvent("CRITERIA_UPDATE")
            alertEventsUnregistered["CRITERIA_UPDATE"] = true
            AlertFrame:UnregisterEvent("TRACKED_ACHIEVEMENT_UPDATE")
            alertEventsUnregistered["TRACKED_ACHIEVEMENT_UPDATE"] = true
            AlertFrame:UnregisterEvent("CRITERIA_EARNED")
            alertEventsUnregistered["CRITERIA_EARNED"] = true
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
            for _, evt in ipairs({
                "ACHIEVEMENT_EARNED",
                "QUEST_TURNED_IN",
                "CRITERIA_UPDATE",
                "TRACKED_ACHIEVEMENT_UPDATE",
                "CRITERIA_EARNED",
            }) do
                if alertEventsUnregistered[evt] then
                    AlertFrame:RegisterEvent(evt)
                    alertEventsUnregistered[evt] = nil
                end
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
