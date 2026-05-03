--[[
    Horizon Suite - Focus - Event Dispatch
    Event frame, ScheduleRefresh, table-dispatch OnEvent, world-map watch-list sync,
    global API for Options.
]]

local addon = _G.HorizonSuite

-- ============================================================================
-- EVENT DISPATCH
-- ============================================================================

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("QUEST_LOG_UPDATE")
eventFrame:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
eventFrame:RegisterEvent("QUEST_WATCH_UPDATE")
eventFrame:RegisterEvent("QUEST_ACCEPTED")
eventFrame:RegisterEvent("QUEST_REMOVED")
eventFrame:RegisterEvent("QUEST_TURNED_IN")
eventFrame:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
eventFrame:RegisterEvent("SUPER_TRACKING_CHANGED")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("ZONE_CHANGED")
pcall(function() eventFrame:RegisterEvent("ZONE_CHANGED_INDOORS") end)
-- VIGNETTE/POI/TASK events: handlers are intentional no-ops for these noisy events
-- (kept registered so they don't fall through to the ScheduleRefresh else-branch).
eventFrame:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")
eventFrame:RegisterEvent("VIGNETTES_UPDATED")
pcall(function() eventFrame:RegisterEvent("AREA_POIS_UPDATED") end)
pcall(function() eventFrame:RegisterEvent("QUEST_POI_UPDATE") end)
pcall(function() eventFrame:RegisterEvent("TASK_PROGRESS_UPDATE") end)
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("SCENARIO_UPDATE")
eventFrame:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
eventFrame:RegisterEvent("SCENARIO_CRITERIA_SHOW_STATE_UPDATE")
eventFrame:RegisterEvent("SCENARIO_COMPLETED")
eventFrame:RegisterEvent("SCENARIO_SPELL_UPDATE")
pcall(function() eventFrame:RegisterEvent("SCENARIO_BONUS_OBJECTIVE_COMPLETE") end)
pcall(function() eventFrame:RegisterEvent("SCENARIO_BONUS_VISIBILITY_UPDATE") end)
eventFrame:RegisterEvent("CRITERIA_COMPLETE")
eventFrame:RegisterEvent("TRACKED_ACHIEVEMENT_UPDATE")
eventFrame:RegisterEvent("CRITERIA_UPDATE")
eventFrame:RegisterEvent("ACHIEVEMENT_EARNED")
eventFrame:RegisterEvent("CONTENT_TRACKING_UPDATE")
pcall(function() eventFrame:RegisterEvent("CONTENT_TRACKING_LIST_UPDATE") end)
pcall(function() eventFrame:RegisterEvent("PERKS_ACTIVITIES_TRACKED_UPDATED") end)
pcall(function() eventFrame:RegisterEvent("PERKS_ACTIVITY_COMPLETED") end)
pcall(function() eventFrame:RegisterEvent("PERKS_ACTIVITIES_TRACKED_LIST_CHANGED") end)
pcall(function() eventFrame:RegisterEvent("ACTIVE_DELVE_DATA_UPDATE") end)
pcall(function() eventFrame:RegisterEvent("WALK_IN_DATA_UPDATE") end)
pcall(function() eventFrame:RegisterEvent("UPDATE_UI_WIDGET") end)
pcall(function() eventFrame:RegisterEvent("INITIATIVE_TASKS_TRACKED_UPDATED") end)
pcall(function() eventFrame:RegisterEvent("INITIATIVE_TASKS_TRACKED_LIST_CHANGED") end)
pcall(function() eventFrame:RegisterEvent("TRACKING_TARGET_INFO_UPDATE") end)
pcall(function() eventFrame:RegisterEvent("TRACKABLE_INFO_UPDATE") end)
pcall(function() eventFrame:RegisterEvent("QUEST_AUTOCOMPLETE") end)
pcall(function() eventFrame:RegisterEvent("TRACKED_RECIPE_UPDATE") end)
pcall(function() eventFrame:RegisterEvent("BAG_UPDATE_DELAYED") end)
-- CHALLENGE_MODE_START: fires when an M+ run begins. Replaces the instance-state
-- recursive poll for detecting that the player is now inside a dungeon.
pcall(function() eventFrame:RegisterEvent("CHALLENGE_MODE_START") end)
-- WORLD_MAP_OPEN: fires when the world map is opened. Used to sync watch-list state.
eventFrame:RegisterEvent("WORLD_MAP_OPEN")
-- AUCTION_HOUSE_SHOW/CLOSED: show/hide the AH search button on recipe entries.
pcall(function() eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW") end)
pcall(function() eventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED") end)

local VIGNETTE_DEBOUNCE          = 0.5
local UPDATE_UI_WIDGET_DEBOUNCE  = 0.2
local SCENARIO_CRITERIA_DEBOUNCE = 0.12
local QUEST_UPDATE_DEBOUNCE      = 0.08
local NEARBY_POI_DEBOUNCE        = 0.2
local ZONE_CHANGE_DEBOUNCE       = 0.15

local zoneLateRetry04Timer
local zoneLateRetry15Timer
local zoneLateRetry25Timer

-- OnUpdate dirty flag breaks taint chain from event-driven C_QuestLog calls.
local layoutDirtyFrame = CreateFrame("Frame")
layoutDirtyFrame:Hide()
layoutDirtyFrame:SetScript("OnUpdate", function(self)
    self:Hide()
    addon.focus.refreshPending = false
    if not addon.focus.enabled then return end
    addon.focus.layoutPendingAfterCombat = false
    if addon.FullLayout then addon.FullLayout() end
end)

local function ScheduleRefresh()
    if not addon.focus.enabled then return end
    if addon.focus.refreshPending then return end
    addon.focus.refreshPending = true
    layoutDirtyFrame:Show()
end

addon.ScheduleRefresh = ScheduleRefresh

-- Factory: returns a closure that, when called, starts (or restarts) a timer which fires
-- ScheduleRefresh after `duration`. Each call site gets its own timer handle so different
-- event classes debounce independently. Uses C_Timer.NewTimer when available (so we can
-- cancel in-flight timers) and falls back to C_Timer.After for older clients.
local function MakeDebouncedRefresh(duration)
    local timer
    return function()
        if not addon.focus.enabled then return end
        if timer then timer:Cancel() end
        if C_Timer and C_Timer.NewTimer then
            timer = C_Timer.NewTimer(duration, function()
                timer = nil
                if addon.focus.enabled then ScheduleRefresh() end
            end)
        else
            C_Timer.After(duration, function()
                if addon.focus.enabled then ScheduleRefresh() end
            end)
        end
    end
end

local ScheduleVignetteDebouncedRefresh         = MakeDebouncedRefresh(VIGNETTE_DEBOUNCE)
local ScheduleScenarioCriteriaDebouncedRefresh = MakeDebouncedRefresh(SCENARIO_CRITERIA_DEBOUNCE)
local ScheduleQuestUpdateDebouncedRefresh      = MakeDebouncedRefresh(QUEST_UPDATE_DEBOUNCE)
local ScheduleNearbyPoiDebouncedRefresh        = MakeDebouncedRefresh(NEARBY_POI_DEBOUNCE)
local ScheduleZoneChangeDebouncedRefresh       = MakeDebouncedRefresh(ZONE_CHANGE_DEBOUNCE)

local function OnVignettesUpdated()
    if not addon.focus.enabled then return end
    if not addon.GetDB("showRareBosses", true) and not addon.GetDB("showRareLoot", false) then return end
    ScheduleVignetteDebouncedRefresh()
end

local ScheduleUpdateUiWidgetDebouncedRefresh = MakeDebouncedRefresh(UPDATE_UI_WIDGET_DEBOUNCE)
local function OnUpdateUiWidgetDebounced()
    if not addon.focus.enabled then return end
    if not ((addon.IsDelveActive and addon.IsDelveActive())
        or (addon.IsScenarioActive and addon.IsScenarioActive())
        or (addon.IsWorldScenario and addon.IsWorldScenario())) then
        return
    end
    ScheduleUpdateUiWidgetDebouncedRefresh()
end

local RunMplusHeightTransitionCheck  -- forward declaration; defined below

local function CancelZoneLateRetries()
    if zoneLateRetry04Timer then zoneLateRetry04Timer:Cancel(); zoneLateRetry04Timer = nil end
    if zoneLateRetry15Timer then zoneLateRetry15Timer:Cancel(); zoneLateRetry15Timer = nil end
    if zoneLateRetry25Timer then zoneLateRetry25Timer:Cancel(); zoneLateRetry25Timer = nil end
end

-- Late retries catch APIs that lag after a zone change (map pins, WQ propagation). Timers
-- are cancelled-and-restarted on each new zone event so a flight burst fires them once,
-- after the last zone change settles, rather than once per zone change.
local function ScheduleZoneLateRetries()
    CancelZoneLateRetries()
    if not (C_Timer and C_Timer.NewTimer) then
        C_Timer.After(0.4, function()
            if not addon.focus.enabled then return end
            if RunMplusHeightTransitionCheck then RunMplusHeightTransitionCheck() end
            ScheduleRefresh()
        end)
        C_Timer.After(1.5, function() if addon.focus.enabled then ScheduleRefresh() end end)
        C_Timer.After(2.5, function() if addon.focus.enabled then ScheduleRefresh() end end)
        return
    end
    zoneLateRetry04Timer = C_Timer.NewTimer(0.4, function()
        zoneLateRetry04Timer = nil
        if not addon.focus.enabled then return end
        if RunMplusHeightTransitionCheck then RunMplusHeightTransitionCheck() end
        ScheduleRefresh()
    end)
    zoneLateRetry15Timer = C_Timer.NewTimer(1.5, function()
        zoneLateRetry15Timer = nil
        if addon.focus.enabled then ScheduleRefresh() end
    end)
    zoneLateRetry25Timer = C_Timer.NewTimer(2.5, function()
        zoneLateRetry25Timer = nil
        if addon.focus.enabled then ScheduleRefresh() end
    end)
end

_G.HorizonSuite_ApplyTypography  = addon.ApplyTypography
_G.HorizonSuite_ApplyDimensions  = addon.ApplyDimensions
_G.HorizonSuite_RequestRefresh   = ScheduleRefresh
_G.HorizonSuite_FullLayout       = addon.FullLayout

-- ============================================================================
-- OBJECTIVE SIGNATURE CACHE (reliable quest-update flash)
-- ============================================================================

--- Builds a compact signature for quest objectives for change detection.
--- @param questID number
--- @return string|nil Signature string, or nil if no objectives
local function BuildObjectiveSignature(questID)
    if not C_QuestLog or not C_QuestLog.GetQuestObjectives then return nil end
    local objectives = C_QuestLog.GetQuestObjectives(questID) or {}
    if #objectives == 0 then return nil end
    local parts = {}
    for i = 1, #objectives do
        local o = objectives[i]
        local text = (o and o.text) or ""
        local fin = (o and o.finished) and "1" or "0"
        local nf = (o and type(o.numFulfilled) == "number") and tostring(o.numFulfilled) or ""
        local nr = (o and type(o.numRequired) == "number") and tostring(o.numRequired) or ""
        parts[i] = text .. "|" .. fin .. "|" .. nf .. "|" .. nr
    end
    return table.concat(parts, ";")
end

--- Records quest progress for the Current Quest category (recentlyProgressedQuests).
--- @param questID number
local function RecordQuestProgress(questID)
    if not questID or questID <= 0 then return end
    if not addon.focus.recentlyProgressedQuests then addon.focus.recentlyProgressedQuests = {} end
    addon.focus.recentlyProgressedQuests[questID] = GetTime()
end

--- Checks if a quest's objectives changed vs cache; if so, records progress and optionally triggers flash.
--- Records progress for Current Quest category regardless of flash setting.
--- @param questID number
--- @return boolean True if flash was triggered
local function CheckQuestObjectiveChangeAndFlash(questID)
    if not questID or questID <= 0 then return false end

    local cache = addon.focus.lastQuestObjectiveSignature
    local current = BuildObjectiveSignature(questID)
    if not current then return false end

    local prior = cache[questID]
    cache[questID] = current

    -- First time seeing this quest: no "change" to record or flash.
    if prior == nil then return false end
    if prior == current then return false end

    -- Change detected: always record for Current Quest category.
    RecordQuestProgress(questID)

    -- Flash only when the option is on.
    if not addon.GetDB("objectiveProgressFlash", true) then return false end

    for i = 1, addon.POOL_SIZE do
        local e = addon.pool[i]
        if e and e.questID == questID then
            e.flashTime = addon.FLASH_DUR
            if addon.EnsureFocusUpdateRunning then addon.EnsureFocusUpdateRunning() end
            return true
        end
    end
    -- Entry not yet in pool (e.g. layout deferred); flash will not show for this tick.
    return false
end

--- Iterates watched quest IDs and runs objective change check. Used when event has no questID.
local function CheckAllWatchedQuestChanges()
    if not C_QuestLog or not C_QuestLog.GetNumQuestWatches or not C_QuestLog.GetQuestIDForQuestWatchIndex then return end
    local n = C_QuestLog.GetNumQuestWatches()
    for i = 1, n do
        local qid = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
        if qid then CheckQuestObjectiveChangeAndFlash(qid) end
    end
end

-- ============================================================================
-- EVENT HANDLERS (table dispatch)
-- ============================================================================

local function OnAddonLoaded(addonName)
    if addonName == addon.ADDON_NAME then
        addon:EnsureModulesDB()
        local db = _G[addon.DATABASE]
        for key in pairs(addon.modules or {}) do
            local modDb = db and db.modules and db.modules[key]
            if modDb and modDb.enabled ~= false then
                addon:EnableModule(key)
            end
        end
    elseif addonName == "Blizzard_WorldMap" then
        if addon.FocusModuleHooks and addon.FocusModuleHooks.WorldMap then
            addon.FocusModuleHooks.WorldMap()
        end
    elseif addonName == "Blizzard_ObjectiveTracker" then
        if addon:IsModuleEnabled("focus") then
            if addon.TrySuppressTracker then addon.TrySuppressTracker() end
            ScheduleRefresh()
        end
    end
end

local function OnPlayerRegenDisabled()
    local mode = addon.GetCombatVisibility()
    if (mode ~= "hide" and mode ~= "fade") or not addon.focus.enabled then return end
    addon.focus.combat.faded = nil
    addon.focus.combat.fadeFromAlpha = nil
    addon.focus.combat.fadeInFromAlpha = nil
    local useAnim = addon.GetDB("animations", true)
    if useAnim and addon.HS:IsShown() then
        addon.focus.combat.fadeState = "out"
        addon.focus.combat.fadeTime  = 0
        if addon.EnsureFocusUpdateRunning then addon.EnsureFocusUpdateRunning() end
    else
        -- Cannot call HS:Hide() here; we are entering combat (protected action blocked).
        addon.focus.combat.fadeState = "out"
        addon.focus.combat.fadeTime  = 0
        addon.focus.pendingHideAfterCombat = (mode == "hide")
        if addon.EnsureFocusUpdateRunning then addon.EnsureFocusUpdateRunning() end
    end
end

local function OnPlayerRegenEnabled()
    local hadLayoutPending = addon.focus.layoutPendingAfterCombat
    local mode = addon.GetCombatVisibility()
    local combatAffectsTracker = (mode == "hide" or mode == "fade") and addon.focus.enabled
    if addon.focus.pendingDimensionsAfterCombat then
        addon.focus.pendingDimensionsAfterCombat = nil
        if addon.ApplyDimensions then addon.ApplyDimensions() end
    end
    if addon.focus.layoutPendingAfterCombat then
        addon.focus.layoutPendingAfterCombat = nil
        if combatAffectsTracker then
            addon.focus.combat.fadeState = "in"
            addon.focus.combat.fadeTime  = 0
            addon.focus.combat.fadeInFromAlpha = ((mode == "fade") and addon.focus.combat.faded and addon.GetCombatFadeAlpha and addon.GetCombatFadeAlpha()) or 0
            addon.focus.combat.faded = nil
            if addon.EnsureFocusUpdateRunning then addon.EnsureFocusUpdateRunning() end
        end
        ScheduleRefresh()
    end
    if addon.focus.mplusLayoutPendingAfterCombat then
        addon.focus.mplusLayoutPendingAfterCombat = nil
        if addon.UpdateMplusBlock then addon.UpdateMplusBlock() end
    end
    if not hadLayoutPending and (combatAffectsTracker or addon.focus.combat.faded) then
        addon.focus.combat.fadeState = "in"
        addon.focus.combat.fadeTime  = 0
        addon.focus.combat.fadeInFromAlpha = (addon.focus.combat.faded and addon.GetCombatFadeAlpha and addon.GetCombatFadeAlpha()) or 0
        addon.focus.combat.faded = nil
        if addon.EnsureFocusUpdateRunning then addon.EnsureFocusUpdateRunning() end
        ScheduleRefresh()
    end
end

-- When entering a Delve/dungeon, ACTIVE_DELVE_DATA_UPDATE fires at the right moment
-- but Blizzard's scenario-header widget data (notably the delve's affix spells) takes
-- a further few hundred ms to populate. A short retry ladder catches the populate
-- window without waiting on the next unrelated refresh trigger — visible impact is the
-- Nemesis badge appearing ~0.5s after entry instead of ~1s+. Subsequent ScheduleRefresh
-- calls coalesce via the pending flag so the ladder costs at most one extra layout.
local INSTANCE_ENTER_RETRY_DELAYS = { 0.2, 0.5, 1.0 }

local function OnInstanceEntered()
    if not addon.focus.enabled then return end
    for _, delay in ipairs(INSTANCE_ENTER_RETRY_DELAYS) do
        C_Timer.After(delay, function()
            if not addon.focus.enabled then return end
            ScheduleRefresh()
        end)
    end
end

local function OnPlayerLoginOrEnteringWorld()
    if addon.focus.enabled then
        addon.focus.zoneJustChanged = true
        addon.focus.nearbyQuestCacheDirty = true
        addon.TrySuppressTracker()
        ScheduleRefresh()
        C_Timer.After(0.4, function()
            if not addon.focus.enabled then return end
            ScheduleRefresh()
        end)
        C_Timer.After(1.5, function() if addon.focus.enabled then ScheduleRefresh() end end)
        -- Prime endeavor cache so GetInitiativeTaskInfo returns objectives without user opening the panel (Blizz bug workaround)
        C_Timer.After(0.2, function()
            if addon.focus.enabled and addon.GetTrackedEndeavorIDs and addon.RequestEndeavorTaskInfo then
                local idList = addon.GetTrackedEndeavorIDs()
                if #idList > 0 and HousingFramesUtil and HousingFramesUtil.ToggleHousingDashboard then
                    pcall(HousingFramesUtil.ToggleHousingDashboard)
                    pcall(HousingFramesUtil.ToggleHousingDashboard)
                end
                for _, id in ipairs(idList) do
                    addon.RequestEndeavorTaskInfo(id)
                end
            end
        end)
    end
end

local function OnQuestTurnedIn(questID)
    if not addon.focus.enabled then ScheduleRefresh(); return end
    if questID and addon.focus.questTimerCache then addon.focus.questTimerCache[questID] = nil end
    for i = 1, addon.POOL_SIZE do
        if addon.pool[i].questID == questID and addon.pool[i].animState ~= "fadeout" then
            local e = addon.pool[i]
            e.titleText:SetTextColor(addon.QUEST_COLORS.COMPLETE[1], addon.QUEST_COLORS.COMPLETE[2], addon.QUEST_COLORS.COMPLETE[3], 1)
            e.animState = "completing"
            e.animTime  = 0
            addon.activeMap[questID] = nil
        end
    end
    ScheduleRefresh()
end

local function OnQuestWatchUpdate(questID)
    if not addon.focus.enabled then ScheduleRefresh(); return end
    if questID then
        CheckQuestObjectiveChangeAndFlash(questID)
    end
    ScheduleQuestUpdateDebouncedRefresh()
end

local function OnQuestAccepted(questID)
    if not addon.focus.enabled then ScheduleRefresh(); return end
    if not questID or questID <= 0 then ScheduleRefresh(); return end

    -- Quests enter Current Quest only via objective updates (CheckQuestObjectiveChangeAndFlash),
    -- not on acceptance.

    local isWQ = (addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID))
        or (C_QuestLog and C_QuestLog.IsWorldQuest and C_QuestLog.IsWorldQuest(questID))

    if addon.GetDB("autoTrackOnAccept", true) then
        if not isWQ and C_QuestLog and C_QuestLog.AddQuestWatch then
            C_QuestLog.AddQuestWatch(questID)
        end
    end
    if isWQ and not addon.GetDB("showWorldQuests", true) then
        addon.focus.nearbyQuestCacheDirty = true
    end

    ScheduleRefresh()
end

local function OnQuestLogUpdate()
    if not addon.focus.enabled then ScheduleRefresh(); return end
    CheckAllWatchedQuestChanges()
    ScheduleQuestUpdateDebouncedRefresh()
end

local function OnUnitQuestLogChanged(_, unitToken)
    if not addon.focus.enabled then ScheduleRefresh(); return end
    if unitToken == "player" then
        CheckAllWatchedQuestChanges()
    end
    ScheduleQuestUpdateDebouncedRefresh()
end

local function OnQuestWatchListChanged(questID, added)
    if not addon.focus.enabled then ScheduleRefresh(); return end
    if questID and addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID) then
        if not addon.focus.recentlyUntrackedWorldQuests then addon.focus.recentlyUntrackedWorldQuests = {} end
        if added then
            addon.focus.recentlyUntrackedWorldQuests[questID] = nil
        else
            addon.focus.recentlyUntrackedWorldQuests[questID] = true
            if addon.focus.wqtTrackedQuests and addon.focus.wqtTrackedQuests[questID] then
                addon.focus.wqtTrackedQuests[questID] = nil
                local wqtDB = addon.GetDB("wqtTrackedQuests", nil)
                if wqtDB and type(wqtDB) == "table" then
                    wqtDB[questID] = nil
                    addon.SetDB("wqtTrackedQuests", wqtDB)
                end
            end
        end
        -- Persist to DB so suppress-until-reload actually survives reload.
        if addon.GetDB("suppressUntrackedUntilReload", false) then
            addon.SetDB("sessionSuppressedQuests", addon.focus.recentlyUntrackedWorldQuests)
        end
    end
    ScheduleRefresh()
end

--- Handles M+ dungeon enter/exit: snapshot overworld height on enter, restore on exit.
local MIN_SNAPSHOT_HEIGHT = 200
RunMplusHeightTransitionCheck = function()
    if not addon.GetDB or not addon.IsInMythicDungeon then return end
    local inMplus = addon.IsInMythicDungeon()
    if addon.focus.wasInMplusDungeon and not inMplus then
        addon.focus.wasInMplusDungeon = false
        local owH = addon.GetDB("maxContentHeightOverworld", nil)
        if owH and type(owH) == "number" and owH >= MIN_SNAPSHOT_HEIGHT then
            addon.SetDB("maxContentHeight", owH)
        end
    elseif inMplus and not addon.focus.wasInMplusDungeon then
        addon.focus.wasInMplusDungeon = true
        local cur = addon.GetDB("maxContentHeight", nil)
        if cur and type(cur) == "number" and cur >= MIN_SNAPSHOT_HEIGHT then
            addon.SetDB("maxContentHeightOverworld", cur)
        end
    elseif not inMplus then
        addon.focus.wasInMplusDungeon = false
    end
end

local function OnZoneChanged(event)
    addon.focus.zoneJustChanged = true
    addon.focus.lastPlayerMapID = nil
    addon.focus.lastZoneMapID = nil
    -- Nearby WQ cache self-invalidates via zoneMapID compare in GetNearbyQuestIDs.
    -- Without wiping prevGroupKey, FullLayout treats rows as moving into CURRENT/CURRENT_EVENT
    -- and returns early, leaving stale visuals until reload.
    if addon.focus.categoryChange and addon.focus.categoryChange.prevGroupKey then
        wipe(addon.focus.categoryChange.prevGroupKey)
    end
    if addon.focus.questTimerCache then wipe(addon.focus.questTimerCache) end
    RunMplusHeightTransitionCheck()
    if event == "ZONE_CHANGED_NEW_AREA" then
        if not addon.GetDB("suppressUntrackedUntilReload", false) then
            if addon.focus.recentlyUntrackedWorldQuests then wipe(addon.focus.recentlyUntrackedWorldQuests) end
            addon.SetDB("sessionSuppressedQuests", nil)
        end
        if addon.ClearDelveNameCache then addon.ClearDelveNameCache() end
    end
    if addon.zoneTaskQuestCache then wipe(addon.zoneTaskQuestCache) end
    ScheduleZoneChangeDebouncedRefresh()
    ScheduleZoneLateRetries()
end

local eventHandlers = {
    ADDON_LOADED             = function(_, addonName) OnAddonLoaded(addonName) end,
    PLAYER_REGEN_DISABLED    = function() OnPlayerRegenDisabled() end,
    PLAYER_REGEN_ENABLED     = function() OnPlayerRegenEnabled() end,
    PLAYER_LOGIN             = function() OnPlayerLoginOrEnteringWorld() end,
    PLAYER_ENTERING_WORLD    = function() OnPlayerLoginOrEnteringWorld() end,
    QUEST_TURNED_IN          = function(_, questID) OnQuestTurnedIn(questID) end,
    QUEST_ACCEPTED           = function(_, questID) OnQuestAccepted(questID) end,
    QUEST_REMOVED            = function(_, questID)
        if not addon.focus.enabled then ScheduleRefresh(); return end
        if questID then
            if addon.focus.questTimerCache then addon.focus.questTimerCache[questID] = nil end
            local isWQ = (addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID))
                or (C_QuestLog and C_QuestLog.IsWorldQuest and C_QuestLog.IsWorldQuest(questID))
            if isWQ then
                addon.focus.nearbyQuestCacheDirty = true
            end
        end
        ScheduleRefresh()
    end,
    QUEST_LOG_UPDATE         = function() OnQuestLogUpdate() end,
    UNIT_QUEST_LOG_CHANGED   = function(_, unitToken) OnUnitQuestLogChanged(_, unitToken) end,
    QUEST_WATCH_UPDATE       = function(_, questID) OnQuestWatchUpdate(questID) end,
    QUEST_WATCH_LIST_CHANGED = function(_, questID, added) OnQuestWatchListChanged(questID, added) end,
    SUPER_TRACKING_CHANGED   = function() ScheduleRefresh() end,
    -- VIGNETTES_UPDATED: debounced refresh so rares/treasures appear when they spawn.
    -- VIGNETTE_MINIMAP_UPDATED fires even more often; keep as no-op.
    VIGNETTE_MINIMAP_UPDATED = function() end,
    VIGNETTES_UPDATED        = OnVignettesUpdated,
    -- AREA_POIS_UPDATED: fires when zone events/POIs update (e.g. entering area with bonus objective).
    AREA_POIS_UPDATED        = function()
        if not addon.focus.enabled then return end
        addon.focus.nearbyQuestCacheDirty = true
        ScheduleNearbyPoiDebouncedRefresh()
    end,
    QUEST_POI_UPDATE         = function() end,
    -- 0.5s follow-up catches WQ-leave cases where C_TaskQuest.IsActive lags behind leaving the area.
    TASK_PROGRESS_UPDATE     = function()
        if not addon.focus.enabled then return end
        addon.focus.nearbyQuestCacheDirty = true
        ScheduleNearbyPoiDebouncedRefresh()
        C_Timer.After(0.5, function()
            if not addon.focus.enabled then return end
            addon.focus.nearbyQuestCacheDirty = true
            ScheduleRefresh()
        end)
    end,
    ZONE_CHANGED             = function(evt) OnZoneChanged(evt) end,
    ZONE_CHANGED_NEW_AREA    = function(evt) OnZoneChanged(evt) end,
    ZONE_CHANGED_INDOORS     = function(evt) OnZoneChanged(evt) end,
    -- SCENARIO_UPDATE: fires when a scenario starts/steps/ends. Start the 5s heartbeat
    -- (for timer countdown display) when a scenario becomes active; it self-cancels on end.
    SCENARIO_UPDATE          = function()
        if addon.InvalidateScenarioEntriesCache then addon.InvalidateScenarioEntriesCache() end
        if addon.focus.enabled and addon.IsScenarioActive and addon.IsScenarioActive() then
            if addon.StartScenarioTimerHeartbeat then addon.StartScenarioTimerHeartbeat() end
        end
        ScheduleRefresh()
    end,
    SCENARIO_CRITERIA_UPDATE = function() ScheduleScenarioCriteriaDebouncedRefresh() end,
    SCENARIO_CRITERIA_SHOW_STATE_UPDATE = function() ScheduleScenarioCriteriaDebouncedRefresh() end,
    SCENARIO_COMPLETED       = function()
        if addon.InvalidateScenarioEntriesCache then addon.InvalidateScenarioEntriesCache() end
        if addon.focus then addon.focus.scenarioTimerCache = nil end
        ScheduleRefresh()
    end,
    SCENARIO_SPELL_UPDATE    = function() ScheduleRefresh() end,
    SCENARIO_BONUS_OBJECTIVE_COMPLETE = function()
        if addon.InvalidateScenarioEntriesCache then addon.InvalidateScenarioEntriesCache() end
        ScheduleRefresh()
    end,
    SCENARIO_BONUS_VISIBILITY_UPDATE  = function()
        if not addon.focus.enabled then return end
        if addon.InvalidateScenarioEntriesCache then addon.InvalidateScenarioEntriesCache() end
        addon.focus.nearbyQuestCacheDirty = true
        ScheduleRefresh()
    end,
    CRITERIA_COMPLETE        = function() ScheduleRefresh() end,
    TRACKED_ACHIEVEMENT_UPDATE = function() ScheduleRefresh() end,
    CRITERIA_UPDATE          = function() ScheduleRefresh() end,
    ACHIEVEMENT_EARNED       = function() ScheduleRefresh() end,
    CONTENT_TRACKING_UPDATE  = function() ScheduleRefresh() end,
    CONTENT_TRACKING_LIST_UPDATE = function() ScheduleRefresh() end,
    PERKS_ACTIVITIES_TRACKED_UPDATED = function() ScheduleRefresh() end,
    PERKS_ACTIVITY_COMPLETED = function() ScheduleRefresh() end,
    PERKS_ACTIVITIES_TRACKED_LIST_CHANGED = function() ScheduleRefresh() end,
    -- ACTIVE_DELVE_DATA_UPDATE / WALK_IN_DATA_UPDATE: fire when entering a delve/walk-in.
    -- Replace the old recursive instance-state poll with a single short defer.
    ACTIVE_DELVE_DATA_UPDATE = function() OnInstanceEntered() end,
    WALK_IN_DATA_UPDATE      = function() OnInstanceEntered() end,
    -- CHALLENGE_MODE_START: fires when an M+ key is activated (dungeon begins).
    -- Replaces the recursive instance-state poll for the M+ case.
    CHALLENGE_MODE_START     = function() OnInstanceEntered() end,
    UPDATE_UI_WIDGET         = function() OnUpdateUiWidgetDebounced() end,
    INITIATIVE_TASKS_TRACKED_UPDATED = function() ScheduleRefresh() end,
    INITIATIVE_TASKS_TRACKED_LIST_CHANGED = function() ScheduleRefresh() end,
    TRACKING_TARGET_INFO_UPDATE = function() ScheduleRefresh() end,
    TRACKABLE_INFO_UPDATE = function() ScheduleRefresh() end,
    TRACKED_RECIPE_UPDATE = function()
        if addon.InvalidateRecipeCache then addon.InvalidateRecipeCache() end
        ScheduleRefresh()
    end,
    BAG_UPDATE_DELAYED = function()
        if addon.InvalidateRecipeCache then addon.InvalidateRecipeCache() end
        -- Only refresh if recipes are tracked (avoid extra layouts for non-recipe players).
        if addon.GetDB("showRecipes", true) and addon.GetTrackedRecipeIDs and #addon.GetTrackedRecipeIDs() > 0 then
            ScheduleRefresh()
        end
    end,
    -- QUEST_AUTOCOMPLETE: fires for popup quests (auto-accepted quests that complete via dialog).
    -- Add them to the watch list so they appear in the tracker.
    QUEST_AUTOCOMPLETE = function(_, questID)
        if not addon.focus.enabled then ScheduleRefresh(); return end
        if questID and questID > 0 then
            if C_QuestLog and C_QuestLog.GetLogIndexForQuestID and C_QuestLog.GetLogIndexForQuestID(questID) then
                if C_QuestLog.AddQuestWatch then
                    C_QuestLog.AddQuestWatch(questID)
                end
            end
        end
        ScheduleRefresh()
    end,
    -- WORLD_MAP_OPEN: fires when the world map opens. Sync watch-list state.
    -- Defer to avoid taint chain with Blizzard map pin acquisition (SetPropagateMouseClicks).
    WORLD_MAP_OPEN           = function()
        if addon.focus.enabled then
            C_Timer.After(0, function()
                if addon.focus.enabled then ScheduleRefresh() end
            end)
        end
    end,
    -- AH open/close: refresh so recipe entries show or hide the AH search button.
    AUCTION_HOUSE_SHOW   = function() if addon.focus.enabled then ScheduleRefresh() end end,
    AUCTION_HOUSE_CLOSED = function() if addon.focus.enabled then ScheduleRefresh() end end,
}

--- OnEvent: table-dispatch to eventHandlers[event]; falls back to ScheduleRefresh for unhandled events.
-- @param self table Event frame
-- @param event string WoW event name (e.g. QUEST_WATCH_LIST_CHANGED, ADDON_LOADED)
-- @param ... any Event payload (varargs)
eventFrame:SetScript("OnEvent", function(self, event, ...)
    -- Process pending hide before addon.focus.enabled check (handles module disabled in combat).
    if event == "PLAYER_REGEN_ENABLED" then
        if addon.focus.restoreTrackerPendingAfterCombat and addon.RestoreTracker then
            addon.focus.restoreTrackerPendingAfterCombat = nil
            addon.RestoreTracker()
        end
        if addon.focus.pendingHideAfterCombat and addon.HS then
            addon.focus.pendingHideAfterCombat = nil
            addon.HS:Hide()
            local floatingBtn = _G.HSFloatingQuestItem
            if floatingBtn then floatingBtn:Hide() end
            if addon.UpdateFloatingQuestItem then addon.UpdateFloatingQuestItem(nil) end
            if addon.UpdateMplusBlock then addon.UpdateMplusBlock() end
        end
    end
    if event ~= "ADDON_LOADED" and not addon.focus.enabled then
        return
    end
    local fn = eventHandlers[event]
    if fn then
        fn(event, ...)
    else
        ScheduleRefresh()
    end
end)
