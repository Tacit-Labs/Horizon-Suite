--[[
    Horizon Suite - Focus Module
    Registers the Focus (objective tracker) module with the core.
    OnInit/OnEnable/OnDisable route initialization and teardown.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.RegisterModule then return end

-- ============================================================================
-- FOCUS MODULE DEFINITION
-- ============================================================================

-- Poll World Map visibility instead of HookScript to avoid ADDON_ACTION_BLOCKED
-- (Blizzard's map POI code calls protected APIs; hooks put us on that call stack).
local function RunWorldMapVisibilityCheck()
    if not WorldMapFrame then return end
    local shown = WorldMapFrame:IsShown()
    if addon._worldMapWasShown == shown then return end
    addon._worldMapWasShown = shown
    if shown then
        if addon.ScheduleRefresh then addon.ScheduleRefresh() end
    else
        if not addon.GetCurrentWorldQuestWatchSet then return end
        local currentSet = addon.GetCurrentWorldQuestWatchSet()
        local lastSet = addon.focus.lastWorldQuestWatchSet
        if lastSet and next(lastSet) then
            if not addon.focus.recentlyUntrackedWorldQuests then addon.focus.recentlyUntrackedWorldQuests = {} end
            for questID, _ in pairs(lastSet) do
                if not currentSet[questID] then
                    addon.focus.recentlyUntrackedWorldQuests[questID] = true
                end
            end
        end
        addon.focus.lastWorldQuestWatchSet = currentSet
        if addon.ScheduleRefresh then addon.ScheduleRefresh() end
    end
end

local StopScenarioTimerHeartbeat  -- forward declaration

local function StartScenarioTimerHeartbeat()
    if addon._scenarioTimerHeartbeat then return end
    addon._scenarioTimerHeartbeat = C_Timer.NewTicker(5, function()
        if not addon.focus.enabled or addon.focus.collapsed then return end
        if addon.ShouldHideInCombat and addon.ShouldHideInCombat() then return end
        if not addon.GetDB("showScenarioEvents", true) then return end
        if addon.IsScenarioActive and addon.IsScenarioActive() then
            if addon.ScheduleRefresh then addon.ScheduleRefresh() end
        else
            StopScenarioTimerHeartbeat()
        end
    end)
end

StopScenarioTimerHeartbeat = function()
    if addon._scenarioTimerHeartbeat then
        addon._scenarioTimerHeartbeat:Cancel()
        addon._scenarioTimerHeartbeat = nil
    end
    if addon.focus then addon.focus.scenarioTimerCache = nil end
end

local CURRENT_QUEST_WINDOW_DEFAULT = 60

local function StartCurrentQuestExpiryTicker()
    if addon._currentQuestExpiryTicker then
        addon._currentQuestExpiryTicker:Cancel()
        addon._currentQuestExpiryTicker = nil
    end
    local interval = tonumber(addon.GetDB("currentQuestWindowSec", CURRENT_QUEST_WINDOW_DEFAULT)) or CURRENT_QUEST_WINDOW_DEFAULT
    interval = math.max(30, math.min(120, interval))
    addon._currentQuestExpiryTicker = C_Timer.NewTicker(interval, function()
        if not addon.focus.enabled then return end
        if not addon.GetDB("showCurrentQuestCategory", true) then return end
        if addon.ScheduleRefresh then addon.ScheduleRefresh() end
    end)
end

local function StopCurrentQuestExpiryTicker()
    if addon._currentQuestExpiryTicker then
        addon._currentQuestExpiryTicker:Cancel()
        addon._currentQuestExpiryTicker = nil
    end
end

addon.StartCurrentQuestExpiryTicker = StartCurrentQuestExpiryTicker
addon.StopCurrentQuestExpiryTicker = StopCurrentQuestExpiryTicker

local function StartScenarioBarTicker()
    if addon._scenarioBarTicker then return end
    addon._scenarioBarTicker = C_Timer.NewTicker(0.5, function()
        if addon.UpdateScenarioTimerBars then addon.UpdateScenarioTimerBars() end
    end)
end

local function StopScenarioBarTicker()
    if addon._scenarioBarTicker then
        addon._scenarioBarTicker:Cancel()
        addon._scenarioBarTicker = nil
    end
end

-- PLAYER_MAP_CHANGED fires with oldMapID/newMapID whenever the player's UI map
-- changes (subzone, zone, continent). This replaces the 0.5s _mapCheckTicker poll.
local mapChangedFrame = CreateFrame("Frame")
local function StartMapChangedListener()
    if addon._mapChangedListening then return end
    addon._mapChangedListening = true
    mapChangedFrame:RegisterEvent("PLAYER_MAP_CHANGED")
    mapChangedFrame:SetScript("OnEvent", function(_, _, oldMapID, newMapID)
        if not addon.focus.enabled then return end
        -- Delegate to RunMapCheck which handles zone cache invalidation.
        if addon.RunMapCheck then addon.RunMapCheck() end
        -- Defer visibility check to avoid taint chain with Blizzard map pin acquisition (SetPropagateMouseClicks).
        C_Timer.After(0, function()
            if addon.focus.enabled then RunWorldMapVisibilityCheck() end
        end)
    end)
end

local function StopMapChangedListener()
    if not addon._mapChangedListening then return end
    addon._mapChangedListening = nil
    mapChangedFrame:UnregisterEvent("PLAYER_MAP_CHANGED")
end

-- Called when Blizzard_WorldMap loads; reset visibility state so next check resyncs.
local function tryHookWorldMap()
    addon._worldMapWasShown = nil
end

-- Expose for FocusEvents when Blizzard_WorldMap loads after us
addon.FocusModuleHooks = addon.FocusModuleHooks or {}
addon.FocusModuleHooks.WorldMap = tryHookWorldMap
-- Also expose so FocusEvents SCENARIO_UPDATE can start the heartbeat on demand.
addon.StartScenarioTimerHeartbeat = StartScenarioTimerHeartbeat

addon:RegisterModule("focus", {
    title       = "Focus",
    description = "Objective tracker for quests, world quests, rares, achievements, and scenarios.",
    order       = 10,

    OnInit = function()
        -- One-time setup when module is first initialized.
        -- Pools, fonts, and config are created by other files at load.
    end,

    OnEnable = function()
        addon.focus.enabled = true
        local wqtDB = addon.GetDB("wqtTrackedQuests", nil)
        if wqtDB and type(wqtDB) == "table" then
            addon.focus.wqtTrackedQuests = addon.focus.wqtTrackedQuests or {}
            for questID, tracked in pairs(wqtDB) do
                if tracked then
                    addon.focus.wqtTrackedQuests[questID] = true
                end
            end
        end
        -- Restore session-suppressed quests so "suppress until reload" actually survives reload.
        if addon.GetDB("suppressUntrackedUntilReload", false) then
            local saved = addon.GetDB("sessionSuppressedQuests", nil)
            if saved and type(saved) == "table" and next(saved) then
                addon.focus.recentlyUntrackedWorldQuests = addon.focus.recentlyUntrackedWorldQuests or {}
                for questID, v in pairs(saved) do
                    if v then addon.focus.recentlyUntrackedWorldQuests[questID] = true end
                end
            end
        end
        addon.RestoreSavedPosition()
        addon.ApplyTypography()
        addon.ApplyDimensions()
        if addon.ApplyBackdropOpacity then addon.ApplyBackdropOpacity() end
        if addon.ApplyBorderVisibility then addon.ApplyBorderVisibility() end
        if addon.GetDB("collapsed", false) then
            addon.focus.collapsed = true
            addon.chevron:SetText("+")
            addon.scrollFrame:Hide()
            addon.focus.layout.targetHeight  = addon.GetCollapsedHeight()
            addon.focus.layout.currentHeight = addon.GetCollapsedHeight()
        end
        -- Only start the scenario heartbeat if a scenario is already running on enable.
        if addon.IsScenarioActive and addon.IsScenarioActive() then
            StartScenarioTimerHeartbeat()
        end
        if addon.GetDB("showCurrentQuestCategory", true) then
            StartCurrentQuestExpiryTicker()
        end
        StartScenarioBarTicker()
        StartMapChangedListener()
        -- Proximity ticker removed: TASK_PROGRESS_UPDATE fires when the player enters
        -- a WQ area (the exact moment a proximity WQ should appear), and ZONE_CHANGED
        -- handles the broader zone-change WQ cache invalidation.
        if addon.EnsureFocusUpdateRunning then addon.EnsureFocusUpdateRunning() end
        -- tryHookWorldMap: ADDON_LOADED for Blizzard_WorldMap in FocusEvents handles this.
        -- One deferred call covers the case where the map is already loaded at enable time.
        C_Timer.After(0.5, tryHookWorldMap)
        if addon.TrySuppressTracker then addon.TrySuppressTracker() end
        if addon.ScheduleRefresh then addon.ScheduleRefresh() end
    end,

    OnDisable = function()
        addon.focus.enabled = false
        StopScenarioTimerHeartbeat()
        if addon.focus.questTimerCache then wipe(addon.focus.questTimerCache) end
        StopCurrentQuestExpiryTicker()
        StopScenarioBarTicker()
        StopMapChangedListener()
        if addon.HS then addon.HS:SetScript("OnUpdate", nil) end
        if addon.RestoreTracker then
            if InCombatLockdown() then
                addon.focus.restoreTrackerPendingAfterCombat = true
            else
                addon.RestoreTracker()
            end
        end
        addon.HS:Hide()
        if addon.pool then
            for i = 1, addon.POOL_SIZE do
                if addon.ClearEntry then addon.ClearEntry(addon.pool[i]) end
            end
        end
        if addon.activeMap then wipe(addon.activeMap) end
        if addon.HideAllSectionHeaders then addon.HideAllSectionHeaders() end
        addon.focus.layout.sectionIdx = 0
        if addon.UpdateFloatingQuestItem then addon.UpdateFloatingQuestItem(nil) end
        if addon.UpdateMplusBlock then addon.UpdateMplusBlock() end
    end,
})
