--[[
    Horizon Suite - Focus - Blizzard Suppression
    Hide default objective tracker when Horizon Suite is enabled.
    APIs: ObjectiveTrackerFrame, C_Timer, C_AddOns, C_QuestLog; hooks WorldQuestTracker.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

local WQT_SUPPRESSION_TICK_INTERVAL = 1.0
local WQT_ADDON_LOAD_DELAY = 0.5
local WQT_ADDON_ALREADY_LOADED_DELAY = 1

-- ============================================================================
-- Private helpers
-- ============================================================================

local hiddenParent = CreateFrame("Frame")
hiddenParent:Hide()

-- Hides a frame by reparenting to hidden parent and blocking OnShow.
local function KillBlizzardFrame(frame)
    if not frame then return end
    -- pcall: frame methods can throw on protected or invalid frames.
    pcall(function()
        frame:UnregisterAllEvents()
        frame:SetParent(hiddenParent)
        frame:Hide()
        frame:SetAlpha(0)
        frame:SetScript("OnShow", function(self) self:Hide() end)
    end)
end

local trackerSuppressed = false
local wqtSuppressed = false
local wqtSuppressionTicker = nil

-- ============================================================================
-- Public functions
-- ============================================================================

--- Suppress the default objective tracker and WQT panel when Focus is enabled.
--- Idempotent; creates ticker to re-hide WQT if it shows again.
--- When focusDevMode is on, skips hiding the Blizzard tracker so both can be compared.
local function TrySuppressTracker()
    local devMode = addon.GetDB and addon.GetDB("focusDevMode", false)
    if devMode then
        -- Dev mode: keep Blizzard tracker visible for comparison. Still suppress WQT.
        if not wqtSuppressed then
            local wqtFrame = _G.WorldQuestTrackerScreenPanel
            if wqtFrame then
                KillBlizzardFrame(wqtFrame)
                wqtSuppressed = true
            end
        end
        if not wqtSuppressionTicker and addon.focus.enabled then
            local wqtLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("WorldQuestTracker"))
                or _G.WorldQuestTrackerAddon or _G.WorldQuestTrackerScreenPanel
            if wqtLoaded then
                wqtSuppressionTicker = C_Timer.NewTicker(WQT_SUPPRESSION_TICK_INTERVAL, function()
                    if not addon.focus.enabled then
                        if wqtSuppressionTicker then
                            wqtSuppressionTicker:Cancel()
                            wqtSuppressionTicker = nil
                        end
                        return
                    end
                    local wqtFrame = _G.WorldQuestTrackerScreenPanel
                    if wqtFrame and wqtFrame:IsShown() and not InCombatLockdown() then
                        wqtFrame:Hide()
                    end
                end)
            end
        end
        return
    end
    if trackerSuppressed then return end
    if ObjectiveTrackerFrame then
        KillBlizzardFrame(ObjectiveTrackerFrame)
        trackerSuppressed = true
    end
    if not wqtSuppressed then
        local wqtFrame = _G.WorldQuestTrackerScreenPanel
        if wqtFrame then
            KillBlizzardFrame(wqtFrame)
            wqtSuppressed = true
        end
    end
    if not wqtSuppressionTicker and addon.focus.enabled then
        local wqtLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("WorldQuestTracker"))
            or _G.WorldQuestTrackerAddon or _G.WorldQuestTrackerScreenPanel
        if wqtLoaded then
            wqtSuppressionTicker = C_Timer.NewTicker(WQT_SUPPRESSION_TICK_INTERVAL, function()
                if not addon.focus.enabled then
                    if wqtSuppressionTicker then
                        wqtSuppressionTicker:Cancel()
                        wqtSuppressionTicker = nil
                    end
                    return
                end
                local wqtFrame = _G.WorldQuestTrackerScreenPanel
                if wqtFrame and wqtFrame:IsShown() and not InCombatLockdown() then
                    wqtFrame:Hide()
                end
            end)
        end
    end
end

--- Restore the default objective tracker and WQT panel when Focus is disabled.
local function RestoreTracker()
    if wqtSuppressionTicker then
        wqtSuppressionTicker:Cancel()
        wqtSuppressionTicker = nil
    end
    if not trackerSuppressed then return end
    if ObjectiveTrackerFrame then
        -- pcall: frame methods can throw on protected or invalid frames.
        pcall(function()
            ObjectiveTrackerFrame:SetParent(UIParent)
            ObjectiveTrackerFrame:ClearAllPoints()
            ObjectiveTrackerFrame:SetPoint("TOPRIGHT", MinimapCluster or UIParent, "BOTTOMRIGHT", 0, 0)
            ObjectiveTrackerFrame:SetAlpha(1)
            ObjectiveTrackerFrame:Show()
            ObjectiveTrackerFrame:SetScript("OnShow", nil)
        end)
        trackerSuppressed = false
    end
    if wqtSuppressed then
        local wqtFrame = _G.WorldQuestTrackerScreenPanel
        if wqtFrame then
            -- pcall: frame methods can throw on protected or invalid frames.
            pcall(function()
                wqtFrame:SetParent(UIParent)
                wqtFrame:SetAlpha(1)
                wqtFrame:Show()
                wqtFrame:SetScript("OnShow", nil)
            end)
            wqtSuppressed = false
        end
    end
end

-- Sync WQT-tracked world quests with HorizonSuite.
local wqtHooked = false
--- Hook WorldQuestTracker to sync its tracked quests with Focus and keep its panel hidden.
--- Called automatically after WQT loads; also exposed for manual re-hook if needed.
local function HookWQTTracking()
    if wqtHooked then return end
    if not addon.focus.enabled then return end
    local WQT = _G.WorldQuestTrackerAddon
    if not WQT then return end
    
    if WQT.RefreshTrackerAnchor then
        hooksecurefunc(WQT, "RefreshTrackerAnchor", function()
            if not addon.focus.enabled then return end
            local wqtPanel = _G.WorldQuestTrackerScreenPanel
            if wqtPanel and wqtPanel:IsShown() then
                wqtPanel:Hide()
            end
        end)
    end
    
    if WQT.AddQuestToTracker then
        hooksecurefunc(WQT, "AddQuestToTracker", function(self, questID, mapID)
            if not addon.focus.enabled then return end
            local qid = self and self.questID or questID
            if not qid then return end
            local isWorldQuest = (C_QuestLog and C_QuestLog.IsWorldQuest and C_QuestLog.IsWorldQuest(qid))
                or (addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(qid))
            if isWorldQuest then
                addon.focus.wqtTrackedQuests = addon.focus.wqtTrackedQuests or {}
                addon.focus.wqtTrackedQuests[qid] = true
                local wqtDB = addon.GetDB("wqtTrackedQuests", nil) or {}
                wqtDB[qid] = true
                addon.SetDB("wqtTrackedQuests", wqtDB)
                -- Also focus (super-track) the quest so it highlights in our list when coming from WQT.
                if C_SuperTrack and C_SuperTrack.SetSuperTrackedQuestID then
                    pcall(C_SuperTrack.SetSuperTrackedQuestID, qid)
                end
            elseif C_QuestLog and C_QuestLog.AddQuestWatch then
                C_QuestLog.AddQuestWatch(qid)
            end
            local wqtPanel = _G.WorldQuestTrackerScreenPanel
            if wqtPanel and wqtPanel:IsShown() then
                wqtPanel:Hide()
            end
            C_Timer.After(0.1, function()
                if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                if addon.FullLayout then C_Timer.After(0.2, addon.FullLayout) end
            end)
        end)
        wqtHooked = true
    end
    
    if WQT.RemoveQuestFromTracker then
        hooksecurefunc(WQT, "RemoveQuestFromTracker", function(questID, noUpdate)
            if not addon.focus.enabled or not questID then return end
            if addon.focus.wqtTrackedQuests and addon.focus.wqtTrackedQuests[questID] then
                addon.focus.wqtTrackedQuests[questID] = nil
                local wqtDB = addon.GetDB("wqtTrackedQuests", nil)
                if wqtDB and type(wqtDB) == "table" then
                    wqtDB[questID] = nil
                    addon.SetDB("wqtTrackedQuests", wqtDB)
                end
                -- If WQT deselected the quest and it's currently super-tracked, clear super-tracking.
                if C_SuperTrack and C_SuperTrack.GetSuperTrackedQuestID and C_SuperTrack.SetSuperTrackedQuestID then
                    local ok, cur = pcall(C_SuperTrack.GetSuperTrackedQuestID)
                    if ok and cur == questID then
                        pcall(C_SuperTrack.SetSuperTrackedQuestID, 0)
                    end
                end
                local wqtPanel = _G.WorldQuestTrackerScreenPanel
                if wqtPanel and wqtPanel:IsShown() then
                    wqtPanel:Hide()
                end
                C_Timer.After(0.1, function()
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                end)
            end
        end)
    end
end

local wqtFrame = CreateFrame("Frame")
wqtFrame:RegisterEvent("ADDON_LOADED")
wqtFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "WorldQuestTracker" then
        C_Timer.After(WQT_ADDON_LOAD_DELAY, HookWQTTracking)
        self:UnregisterEvent("ADDON_LOADED")
    end
end)
if C_AddOns and C_AddOns.IsAddOnLoaded("WorldQuestTracker") then
    C_Timer.After(WQT_ADDON_ALREADY_LOADED_DELAY, HookWQTTracking)
end

addon.TrySuppressTracker = TrySuppressTracker
addon.RestoreTracker     = RestoreTracker
addon.HookWQTTracking    = HookWQTTracking
