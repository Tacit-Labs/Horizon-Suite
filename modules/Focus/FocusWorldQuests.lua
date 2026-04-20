--[[
    Horizon Suite - Focus - World Quest Tracking
    Quests on map (GetNearbyQuestIDs), world/calling watch list, merge into tracker.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- Defensive fallback: ensure addon.GetNearbyQuestIDs exists even if portions of this module fail.
-- This prevents FocusAggregator from crashing and at least returns task quests on the player's current map.
if not addon.GetNearbyQuestIDs then
    addon.GetNearbyQuestIDs = function()
        local nearbySet, taskQuestOnlySet = {}, {}
        if not (addon.ResolvePlayerMapContext and addon.GetTaskQuestsForMap) then
            return nearbySet, taskQuestOnlySet
        end
        local ctx = addon.ResolvePlayerMapContext("player") or {}
        for _, mid in ipairs(ctx.mapIDsToQuery or {}) do
            local taskPOIs = addon.GetTaskQuestsForMap(mid, mid) or addon.GetTaskQuestsForMap(mid)
            if taskPOIs then
                for _, poi in ipairs(taskPOIs) do
                    local qid = (type(poi) == "table" and (poi.questID or poi.questId)) or (type(poi) == "number" and poi)
                    if qid and type(qid) == "number" and qid > 0 then
                        nearbySet[qid] = true
                        taskQuestOnlySet[qid] = true
                    end
                end
            end
        end
        return nearbySet, taskQuestOnlySet
    end
end

-- ============================================================================
-- WORLD QUEST AND QUESTS-ON-MAP LOGIC
-- ============================================================================

--- True when a task/world quest is genuinely active on the server right now.
-- Checks C_TaskQuest.IsActive, time remaining, and completed flag.
-- @param questID number
-- @return boolean
local function IsTaskQuestCurrentlyActive(questID)
    if not questID or questID <= 0 then return false end
    -- Must not have been completed already.
    if C_QuestLog.IsQuestFlaggedCompleted and C_QuestLog.IsQuestFlaggedCompleted(questID) then
        return false
    end
    -- C_TaskQuest.IsActive: definitive server-side check.
    if C_TaskQuest and C_TaskQuest.IsActive then
        if not C_TaskQuest.IsActive(questID) then return false end
    end
    -- Time-left (soft) guard:
    -- Some task quests shown on the map (notably race-style tasks) can report 0/negative here even while still valid.
    -- C_TaskQuest.IsActive is the authoritative flag; only use time-left as an informational hint.
    -- If it's explicitly expired but IsActive is true, we keep it.
    return true
end

--- True when a task/world quest belongs to one of the maps we are checking.
-- Uses C_TaskQuest.GetQuestZoneID and walks up the parent chain so sub-zone
-- quests on the player's zone are correctly included.
-- @param questID number
-- @param mapIDSet table  Set of mapID -> true
-- @return boolean
local function IsTaskQuestOnPlayerMaps(questID, mapIDSet)
    if not questID or not mapIDSet then return false end
    if not (C_TaskQuest and C_TaskQuest.GetQuestZoneID) then return true end  -- no API, assume match
    local ok, zoneMapID = pcall(C_TaskQuest.GetQuestZoneID, questID)
    if not ok or not zoneMapID then return false end
    -- Walk up the map hierarchy: sub-zone → zone → continent, stop at 5 levels to avoid infinite loops.
    local checkID = zoneMapID
    for _ = 1, 5 do
        if not checkID or checkID == 0 then break end
        if mapIDSet[checkID] then return true end
        if not (C_Map and C_Map.GetMapInfo) then break end
        local info = C_Map.GetMapInfo(checkID)
        if not info or not info.parentMapID or info.parentMapID == 0 then break end
        checkID = info.parentMapID
    end
    return false
end

--- Build sets of quest IDs visible on the player's current map(s) and from task/WQ APIs.
-- Results are cached until addon.focus.nearbyQuestCacheDirty is set (done on zone change).
-- When showWorldQuests is off the WQ map scan is skipped entirely; only bonus-objective task
-- quests (non-WQ) are still included because they are zone-entered, not zone-scanned.
-- @return table nearbySet Set of questID -> true for quests on player map or parent/children
-- @return table taskQuestOnlySet Set of questID -> true for quests coming only from task/WQ map APIs
local function GetNearbyQuestIDs()
    -- Return cached result if the zone hasn't changed since the last scan.
    if not addon.focus.nearbyQuestCacheDirty
        and addon.focus.nearbyQuestCache
        and addon.focus.nearbyTaskQuestCache then
        return addon.focus.nearbyQuestCache, addon.focus.nearbyTaskQuestCache
    end
    addon.focus.nearbyQuestCacheDirty = nil
    local nearbySet = {}
    local taskQuestOnlySet = {}

    -- Build mapIDsToCheck first so we can filter by current map.
    -- This prevents stale WQs from the previous zone (e.g. after hearth) from staying in the tracker.
    local ctx = addon.ResolvePlayerMapContext and addon.ResolvePlayerMapContext("player") or nil
    local mapIDsToCheck = (ctx and ctx.mapIDsToQuery and #ctx.mapIDsToQuery > 0) and ctx.mapIDsToQuery or nil
    local mapIDSet = {}
    if mapIDsToCheck then
        for _, id in ipairs(mapIDsToCheck) do mapIDSet[id] = true end
    end

    -- GetTasksTable: Blizzard's authoritative list of active tasks (bonus objectives, etc.).
    -- Same source as BonusObjectiveTracker. Skip world quests (GetTaskQuestsForMap is authoritative for WQs).
    -- Include non-WQ entries when IsActive. Map check is best-effort; if it fails, include anyway
    -- (Blizzard shows it, so e.g. Saltheril's Soiree zone may not match our map hierarchy walk).
    if _G.GetTasksTable and type(_G.GetTasksTable) == "function" then
        local ok, tasks = pcall(_G.GetTasksTable)
        if ok and tasks and type(tasks) == "table" then
            for _, entry in pairs(tasks) do
                local questID = (type(entry) == "number" and entry) or (type(entry) == "table" and entry and entry.questID)
                if questID and type(questID) == "number" and questID > 0 and questID < 10000000 then
                    -- Skip world quests: GetTasksTable can hold stale WQ entries.
                    local isWQ = addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID)
                    if not isWQ and IsTaskQuestCurrentlyActive(questID) then
                        nearbySet[questID] = true
                        taskQuestOnlySet[questID] = true
                    end
                end
            end
        end
    end

    if not C_Map or not C_Map.GetBestMapForUnit or not C_QuestLog.GetQuestsOnMap then
        addon.focus.nearbyQuestCache = nearbySet
        addon.focus.nearbyTaskQuestCache = taskQuestOnlySet
        return nearbySet, taskQuestOnlySet
    end
    if not mapIDsToCheck then
        addon.focus.nearbyQuestCache = nearbySet
        addon.focus.nearbyTaskQuestCache = taskQuestOnlySet
        return nearbySet, taskQuestOnlySet
    end

    local showWQ = addon.GetDB("showWorldQuests", true)
    -- Track which mapIDs have already been queried via GetTaskQuestsForMap so the quest-hub
    -- fallback below cannot re-query a map already handled in the main loop.
    local queriedTaskMaps = {}

    for _, checkMapID in ipairs(mapIDsToCheck) do
        -- C_QuestLog.GetQuestsOnMap: regular quest map pins (accepted quests with POI locations).
        -- Skip any world/task quests; they come from C_TaskQuest APIs below.
        -- Use POI mapID to verify the quest is genuinely on one of our maps.
        local onMap = C_QuestLog.GetQuestsOnMap(checkMapID)
        if onMap then
            for _, info in ipairs(onMap) do
                if info.questID then
                    -- Identify world/task quests and skip them (they come from C_TaskQuest APIs).
                    -- BonusObjective (event quests): add to nearbySet when accepted so they appear in Current Event.
                    local isWQ = addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(info.questID)
                    local isBonusObjective = false
                    if not isWQ and C_QuestInfoSystem and C_QuestInfoSystem.GetQuestClassification then
                        local qc = C_QuestInfoSystem.GetQuestClassification(info.questID)
                        if qc == Enum.QuestClassification.WorldQuest then
                            isWQ = true
                        elseif qc == Enum.QuestClassification.BonusObjective then
                            isBonusObjective = true
                        end
                    end
                    local isTask = not isWQ and C_TaskQuest and C_TaskQuest.IsActive and C_TaskQuest.IsActive(info.questID)
                    if isBonusObjective then
                        nearbySet[info.questID] = true
                        taskQuestOnlySet[info.questID] = true
                    elseif not isWQ and not isTask then
                        nearbySet[info.questID] = true
                    end
                end
            end
        end

        -- C_TaskQuest.GetQuestsOnMap: authoritative source for active task/world quests.
        -- Only run when showWorldQuests is on; this is the expensive per-zone WQ scan.
        if showWQ and addon.GetTaskQuestsForMap and not queriedTaskMaps[checkMapID] then
            queriedTaskMaps[checkMapID] = true
            local taskPOIs = addon.GetTaskQuestsForMap(checkMapID, checkMapID) or addon.GetTaskQuestsForMap(checkMapID)
            if taskPOIs then
                for _, poi in ipairs(taskPOIs) do
                    local questID = (type(poi) == "table" and (poi.questID or poi.questId)) or (type(poi) == "number" and poi)
                    if questID and type(questID) == "number" and questID > 0 then
                        if IsTaskQuestCurrentlyActive(questID) then
                            nearbySet[questID] = true
                            taskQuestOnlySet[questID] = true
                        end
                    end
                end
            end
        end
    end

    -- Quest hub fallback (zone-scoped): only when showWorldQuests is on.
    if showWQ and ctx and ctx.zoneMapID and C_AreaPoiInfo and C_AreaPoiInfo.GetQuestHubsForMap and C_AreaPoiInfo.GetAreaPOIInfo then
        local okHubs, hubs = pcall(C_AreaPoiInfo.GetQuestHubsForMap, ctx.zoneMapID)
        if okHubs and hubs and type(hubs) == "table" then
            for _, areaPoiID in ipairs(hubs) do
                local okInfo, poiInfo = pcall(C_AreaPoiInfo.GetAreaPOIInfo, ctx.zoneMapID, areaPoiID)
                local linkedMapID = okInfo and poiInfo and poiInfo.linkedUiMapID or nil
                -- If the hub links to a map and that map exposes task quests, query it.
                if linkedMapID and addon.GetTaskQuestsForMap and not queriedTaskMaps[linkedMapID] then
                    queriedTaskMaps[linkedMapID] = true
                    local taskPOIs = addon.GetTaskQuestsForMap(linkedMapID, linkedMapID) or addon.GetTaskQuestsForMap(linkedMapID)
                    if taskPOIs then
                        for _, poi in ipairs(taskPOIs) do
                            local questID = (type(poi) == "table" and (poi.questID or poi.questId)) or (type(poi) == "number" and poi)
                            if questID and type(questID) == "number" and questID > 0 then
                                local related = true
                                if C_QuestHub and C_QuestHub.IsQuestCurrentlyRelatedToHub then
                                    local okRel, isRel = pcall(C_QuestHub.IsQuestCurrentlyRelatedToHub, questID, areaPoiID)
                                    if okRel then related = (isRel == true) end
                                end
                                if related and IsTaskQuestCurrentlyActive(questID) then
                                    nearbySet[questID] = true
                                    taskQuestOnlySet[questID] = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if not showWQ and C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetInfo then
        for i = 1, C_QuestLog.GetNumQuestLogEntries() do
            local info = C_QuestLog.GetInfo(i)
            if info and not info.isHeader and info.questID and not nearbySet[info.questID] then
                local questID = info.questID
                local isWQ = (addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID))
                    or (C_QuestLog.IsWorldQuest and C_QuestLog.IsWorldQuest(questID))
                if isWQ and IsTaskQuestCurrentlyActive(questID) then
                    -- Only include if the player is currently inside the quest area.
                    local inArea = C_QuestLog.IsOnQuest and C_QuestLog.IsOnQuest(questID)
                    if inArea then
                        nearbySet[questID] = true
                        taskQuestOnlySet[questID] = true
                    end
                end
            end
        end
    end

    -- Waypoint-based fallback: only when next waypoint is on the player's exact map (not parent),
    -- so we don't pull in quests from other zones that share a hub.
    -- Skip world/task quests here; they are handled by the C_TaskQuest path above.
    if C_QuestLog.GetNextWaypoint then
        local questIDsToCheck = {}
        if C_QuestLog.GetNumQuestWatches and C_QuestLog.GetQuestIDForQuestWatchIndex then
            for i = 1, C_QuestLog.GetNumQuestWatches() do
                local qid = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
                if qid then questIDsToCheck[qid] = true end
            end
        end
        if C_QuestLog.GetNumWorldQuestWatches and C_QuestLog.GetQuestIDForWorldQuestWatchIndex then
            for i = 1, C_QuestLog.GetNumWorldQuestWatches() do
                local qid = C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i)
                if qid then questIDsToCheck[qid] = true end
            end
        end
        if C_QuestLog.GetNumQuestLogEntries then
            for i = 1, C_QuestLog.GetNumQuestLogEntries() do
                local info = C_QuestLog.GetInfo(i)
                if info and not info.isHeader and info.questID then
                    questIDsToCheck[info.questID] = true
                end
            end
        end
        for questID, _ in pairs(questIDsToCheck) do
            if not nearbySet[questID] then
                -- World quests in the waypoint path must also pass active validation.
                local isWQ = addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID)
                if isWQ and not IsTaskQuestCurrentlyActive(questID) then
                    -- stale WQ; skip
                else
                    local waypointMapID = C_QuestLog.GetNextWaypoint(questID)
                    if waypointMapID then
                        for _, checkID in ipairs(mapIDsToCheck) do
                            if waypointMapID == checkID then
                                nearbySet[questID] = true
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    addon.focus.nearbyQuestCache = nearbySet
    addon.focus.nearbyTaskQuestCache = taskQuestOnlySet
    return nearbySet, taskQuestOnlySet
end

--- True if player is within the quest's active area (can progress it).
-- For world/task quests, entering the area adds the quest to the quest log.
-- C_QuestLog.IsOnQuest is the authoritative check.
-- Falls back to C_QuestLog.GetLogIndexForQuestID if IsOnQuest is unavailable.
local function IsPlayerInQuestArea(questID)
    if not questID or questID <= 0 then return false end
    if C_QuestLog and C_QuestLog.IsOnQuest then
        return C_QuestLog.IsOnQuest(questID)
    end
    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
        return C_QuestLog.GetLogIndexForQuestID(questID) ~= nil
    end
    return false
end

-- World quest watch set for map-close diff.
local function GetCurrentWorldQuestWatchSet()
    local set = {}
    if C_QuestLog.GetNumWorldQuestWatches and C_QuestLog.GetQuestIDForWorldQuestWatchIndex then
        for i = 1, C_QuestLog.GetNumWorldQuestWatches() do
            local questID = C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i)
            if questID then set[questID] = true end
        end
    end
    return set
end

-- True if questID is currently on the world quest watch list (avoids timing: map add can update list after we read it).
local function IsOnWorldQuestWatchList(questID)
    if not questID or not C_QuestLog.GetNumWorldQuestWatches or not C_QuestLog.GetQuestIDForWorldQuestWatchIndex then return false end
    for i = 1, C_QuestLog.GetNumWorldQuestWatches() do
        if C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i) == questID then return true end
    end
    return false
end

-- Returns watch-list WQs plus in-zone *active* world quests/callings so they appear in the objective list.
-- Filter out deprecated/expired WQs: only show if on watch list, or calling, or (world/task and currently active or in quest log).
local function GetWorldAndCallingQuestIDsToShow(nearbySet, taskQuestOnlySet)
    local mapCtx = addon.ResolvePlayerMapContext and addon.ResolvePlayerMapContext("player") or nil
    local zoneMapID = mapCtx and mapCtx.zoneMapID or nil

    local function IsQuestAWorldQuest(questID)
        if addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID) then return true end
        if C_QuestLog and C_QuestLog.IsWorldQuest and C_QuestLog.IsWorldQuest(questID) then return true end
        if C_QuestInfoSystem and C_QuestInfoSystem.GetQuestClassification and Enum and Enum.QuestClassification then
            local qc = C_QuestInfoSystem.GetQuestClassification(questID)
            if qc == Enum.QuestClassification.WorldQuest then return true end
        end
        return false
    end

    -- Only accept quests whose map (walked up to mapType=3) matches the player's zoneMapID.
    -- This is stricter than the old name-based filter, but *only* applied for untracked/nearby entries.
    local function IsQuestOnPlayerZoneMap(questID)
        if not questID or questID <= 0 then return false end
        if not zoneMapID or not (C_TaskQuest and C_TaskQuest.GetQuestZoneID) or not (C_Map and C_Map.GetMapInfo) then
            return true
        end
        local ok, qMapID = pcall(C_TaskQuest.GetQuestZoneID, questID)
        if not ok or not qMapID or qMapID == 0 then
            return true
        end
        local checkID = qMapID
        for _ = 1, 10 do
            if checkID == zoneMapID then return true end
            local info = C_Map.GetMapInfo(checkID)
            if not info or not info.parentMapID or info.parentMapID == 0 then break end
            checkID = info.parentMapID
        end
        return false
    end

    local out = {}
    local seen = {}
    if C_QuestLog.GetNumWorldQuestWatches and C_QuestLog.GetQuestIDForWorldQuestWatchIndex then
        addon.focus.lastWorldQuestWatchSet = addon.focus.lastWorldQuestWatchSet or {}
        wipe(addon.focus.lastWorldQuestWatchSet)
        local numWorldWatches = C_QuestLog.GetNumWorldQuestWatches()
        for i = 1, numWorldWatches do
            local questID = C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i)
            if questID and not seen[questID] and IsTaskQuestCurrentlyActive(questID) then
                seen[questID] = true
                addon.focus.lastWorldQuestWatchSet[questID] = true
                out[#out + 1] = { questID = questID, isTracked = true }
            end
        end
    end
    if addon.focus.wqtTrackedQuests then
        for questID, _ in pairs(addon.focus.wqtTrackedQuests) do
            if not seen[questID] and IsTaskQuestCurrentlyActive(questID) then
                -- Skip quests that can't be meaningfully displayed/tracked (hidden/internal).
                local logIdx = (C_QuestLog and C_QuestLog.GetLogIndexForQuestID) and C_QuestLog.GetLogIndexForQuestID(questID) or nil
                if logIdx and C_QuestLog and C_QuestLog.GetInfo then
                    local info = C_QuestLog.GetInfo(logIdx)
                    if info and info.isHidden then
                        -- ignore
                    else
                        seen[questID] = true
                        out[#out + 1] = { questID = questID, isTracked = true }
                    end
                else
                    -- If it's not in the quest log, only include if it's a world quest AND has a title.
                    local title = (C_QuestLog and C_QuestLog.GetTitleForQuestID) and C_QuestLog.GetTitleForQuestID(questID) or nil
                    if title and title ~= "" and IsQuestAWorldQuest(questID) then
                        seen[questID] = true
                        out[#out + 1] = { questID = questID, isTracked = true }
                    end
                end
            end
        end
    end
    if nearbySet and (addon.IsQuestWorldQuest or C_QuestLog.IsWorldQuest) then
        local recentlyUntracked = addon.focus.recentlyUntrackedWorldQuests
        local ids = {}
        for questID, _ in pairs(nearbySet) do
            -- Allow through when in the quest area even if untracked: the quest still
            -- belongs in Current Event when the player is physically inside it.
            -- IsPlayerInQuestArea is only called when the quest is actually blacklisted
            -- (short-circuit or), so the API cost is negligible.
            if not seen[questID] and (not recentlyUntracked or not recentlyUntracked[questID] or IsPlayerInQuestArea(questID)) then
                -- Gate *untracked* map-derived entries by current zone map.
                -- Watch-list WQs are handled above and remain visible if active.
                if not IsQuestOnPlayerZoneMap(questID) then
                    -- skip (wrong map/zone)
                else
                     local isWorld = IsQuestAWorldQuest(questID)
                      local isCalling = C_QuestLog.IsQuestCalling and C_QuestLog.IsQuestCalling(questID)
                      local qc = C_QuestInfoSystem and C_QuestInfoSystem.GetQuestClassification and C_QuestInfoSystem.GetQuestClassification(questID)
                      local isCampaign = (qc == Enum.QuestClassification.Campaign)
                      local isRecurring = (qc == Enum.QuestClassification.Recurring)
                      local fromTaskQuestMap = taskQuestOnlySet and taskQuestOnlySet[questID]

                      -- Debug probes for known-missing IDs.
                      local DEBUG_WQDBG = false
                      if DEBUG_WQDBG and (questID == 82293 or questID == 80243 or questID == 82523) then
                          local dbgIsActive = (C_TaskQuest and C_TaskQuest.IsActive) and C_TaskQuest.IsActive(questID) or nil
                          local dbgIsWQ = isWorld
                          local dbgRecentlyUntracked = recentlyUntracked and recentlyUntracked[questID]
                          local dbgZone = (C_TaskQuest and C_TaskQuest.GetQuestZoneID) and C_TaskQuest.GetQuestZoneID(questID) or nil
                          if addon.HSPrint then
                              addon.HSPrint(("WQDBG q=%d fromTask=%s isWQ=%s isCalling=%s class=%s isCampaign=%s isRecurring=%s isActive=%s zoneMap=%s recentlyUntracked=%s")
                                  :format(questID, tostring(fromTaskQuestMap), tostring(dbgIsWQ), tostring(isCalling), tostring(qc), tostring(isCampaign), tostring(isRecurring), tostring(dbgIsActive), tostring(dbgZone), tostring(dbgRecentlyUntracked)))
                          end
                      end

                      if isCampaign or isRecurring then
                          if isCalling then
                              ids[#ids + 1] = questID
                          end
                      elseif isCalling then
                          ids[#ids + 1] = questID
                      elseif isWorld then
                          if IsTaskQuestCurrentlyActive(questID) then
                              ids[#ids + 1] = questID
                          end
                      elseif fromTaskQuestMap and qc == Enum.QuestClassification.BonusObjective then
                          -- Fallback: zone events (bonus objectives) from map APIs.
                          if IsTaskQuestCurrentlyActive(questID) then
                              ids[#ids + 1] = questID
                          end
                      end
                 end
              end
          end

        table.sort(ids)
        for _, questID in ipairs(ids) do
            seen[questID] = true
            if C_TaskQuest and C_TaskQuest.RequestPreloadRewardData then
                C_TaskQuest.RequestPreloadRewardData(questID)
            end
            local isWorld = IsQuestAWorldQuest(questID)
            local isCalling = C_QuestLog.IsQuestCalling and C_QuestLog.IsQuestCalling(questID)
            local fromTaskQuestMap = taskQuestOnlySet and taskQuestOnlySet[questID]
            local qc = C_QuestInfoSystem and C_QuestInfoSystem.GetQuestClassification and C_QuestInfoSystem.GetQuestClassification(questID)
            local isCampaign = (qc == Enum.QuestClassification.Campaign)
            local isRecurring = (qc == Enum.QuestClassification.Recurring)
            -- Force WORLD for task-map pins that are not already classified as world/calling/campaign/recurring.
            local forceCategory = nil
            -- isInQuestArea: player is inside the quest's active area (quest is in quest log).
            local isInQuestArea = IsPlayerInQuestArea(questID)
            -- Re-check watch list so WQs just added from map get isTracked = true (no **).
            local isTracked = IsOnWorldQuestWatchList(questID)
            local isFromWQT = addon.focus and addon.focus.wqtTrackedQuests and addon.focus.wqtTrackedQuests[questID]
            -- When the player is inside the quest area (can progress it), treat as tracked.
            if isInQuestArea then
                isTracked = true
            end
            local isAutoAdded = (not isTracked) and (not isFromWQT)
            local isEventQuest = (fromTaskQuestMap and not isWorld and not isCalling and qc == Enum.QuestClassification.BonusObjective)
            out[#out + 1] = { questID = questID, isTracked = isTracked, isInQuestArea = isInQuestArea, forceCategory = forceCategory, isAutoAdded = isAutoAdded, isEventQuest = isEventQuest }
        end
    end
    return out
end

--- Provider: returns world quests and callings from GetWorldAndCallingQuestIDsToShow in aggregator format.
-- Blacklist and zone filtering are applied by the aggregator.
local function CollectWorldQuests(ctx)
    local nearbySet = ctx.nearbySet or {}
    local taskQuestOnlySet = ctx.taskQuestOnlySet or {}
    local raw = GetWorldAndCallingQuestIDsToShow(nearbySet, taskQuestOnlySet)
    local out = {}
    for _, entry in ipairs(raw) do
        out[#out + 1] = {
            questID = entry.questID,
            opts = { isTracked = entry.isTracked, isInQuestArea = entry.isInQuestArea, forceCategory = entry.forceCategory, isAutoAdded = entry.isAutoAdded, isEventQuest = entry.isEventQuest }
        }
    end
    return out
end

local function RemoveWorldQuestWatch(questID)
    if not questID then return end
    if (addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID)) and C_QuestLog.RemoveWorldQuestWatch then
        C_QuestLog.RemoveWorldQuestWatch(questID)
    end
end

local function GetNearbyDebugInfo()
    local lines = {}
    if not C_Map or not C_Map.GetBestMapForUnit then
        lines[#lines + 1] = "C_Map.GetBestMapForUnit not available."
        return lines
    end
    local mapID = C_Map.GetBestMapForUnit("player")
    if mapID and C_Map.GetMapInfo then
        local info = C_Map.GetMapInfo(mapID)
        lines[#lines + 1] = ("GetBestMapForUnit mapID: %s, name: %s"):format(tostring(mapID), info and (info.name or "nil") or "nil")
        if info then
            lines[#lines + 1] = ("  mapType: %s, parentMapID: %s"):format(tostring(info.mapType), tostring(info.parentMapID or "nil"))
        end
    else
        lines[#lines + 1] = "GetBestMapForUnit returned nil or GetMapInfo not available."
    end
    if GetZoneText then
        lines[#lines + 1] = ("GetZoneText: %s"):format(tostring(GetZoneText()))
    end
    if GetSubZoneText then
        lines[#lines + 1] = ("GetSubZoneText: %s"):format(tostring(GetSubZoneText()))
    end
    if GetMinimapZoneText then
        lines[#lines + 1] = ("GetMinimapZoneText: %s"):format(tostring(GetMinimapZoneText()))
    end
    lines[#lines + 1] = ("IsDelveActive: %s"):format((addon.IsDelveActive and addon.IsDelveActive()) and "true" or "false")
    lines[#lines + 1] = ("IsInPartyDungeon: %s"):format((addon.IsInPartyDungeon and addon.IsInPartyDungeon()) and "true" or "false")
    if addon.GetPlayerCurrentZoneName then
        local currentZone = addon.GetPlayerCurrentZoneName()
        lines[#lines + 1] = ("GetPlayerCurrentZoneName (resolved): %s"):format(tostring(currentZone or "nil"))
    end
    return lines
end

-- ============================================================================
-- DEBUG: WORLD QUEST DISCOVERY DUMP
-- ============================================================================

local function DumpQuestPOIs(pois)
    local ids = {}
    if not pois then return ids end
    for _, poi in ipairs(pois) do
        local qid = (type(poi) == "table" and (poi.questID or poi.questId)) or (type(poi) == "number" and poi)
        if qid and type(qid) == "number" and qid > 0 then
            ids[#ids + 1] = qid
        end
    end
    table.sort(ids)
    return ids
end

local function SafeMapName(mapID)
    if not mapID or not C_Map or not C_Map.GetMapInfo then return "nil" end
    local ok, info = pcall(C_Map.GetMapInfo, mapID)
    if not ok or not info then return tostring(mapID) end
    return ("%s (%d, type=%s, parent=%s)"):format(tostring(info.name or "?"), mapID, tostring(info.mapType), tostring(info.parentMapID))
end

function addon.DumpWorldQuestDiscovery()
    if not addon.HSPrint then return end
    addon.HSPrint("=== HorizonSuite WQ Discovery Dump ===")

    local ctx = addon.ResolvePlayerMapContext and addon.ResolvePlayerMapContext("player") or {}
    addon.HSPrint("rawMapID: " .. tostring(ctx.rawMapID) .. " | " .. SafeMapName(ctx.rawMapID))
    addon.HSPrint("zoneMapID: " .. tostring(ctx.zoneMapID) .. " | " .. SafeMapName(ctx.zoneMapID))
    addon.HSPrint("mapIDsToQuery: " .. tostring(ctx.mapIDsToQuery and #ctx.mapIDsToQuery or 0))
    if ctx.mapIDsToQuery then
        for i, mid in ipairs(ctx.mapIDsToQuery) do
            addon.HSPrint(("  [%d] %s"):format(i, SafeMapName(mid)))
        end
    end

    -- 1) Task quests by mapID
    if addon.GetTaskQuestsForMap then
        addon.HSPrint("-- C_TaskQuest quests by mapID --")
        for _, mid in ipairs(ctx.mapIDsToQuery or {}) do
            local ok, pois = pcall(function()
                return addon.GetTaskQuestsForMap(mid, mid) or addon.GetTaskQuestsForMap(mid)
            end)
            local ids = ok and DumpQuestPOIs(pois) or {}
            addon.HSPrint(("map %d -> %d task quests"):format(mid, #ids))
            if #ids > 0 then
                addon.HSPrint("  " .. table.concat(ids, ", "))

                -- Per-quest details
                for _, qid in ipairs(ids) do
                    local isWQ = (addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(qid)) or (C_QuestLog and C_QuestLog.IsWorldQuest and C_QuestLog.IsWorldQuest(qid))
                    local qc = (C_QuestInfoSystem and C_QuestInfoSystem.GetQuestClassification) and C_QuestInfoSystem.GetQuestClassification(qid) or nil
                    local timeLeft = (C_TaskQuest and C_TaskQuest.GetQuestTimeLeftSeconds) and C_TaskQuest.GetQuestTimeLeftSeconds(qid) or nil
                    local zone = (C_TaskQuest and C_TaskQuest.GetQuestZoneID) and C_TaskQuest.GetQuestZoneID(qid) or nil
                    addon.HSPrint(("    q=%d | isWQ=%s | class=%s | timeLeft=%s | zoneMap=%s"):format(qid, tostring(isWQ), tostring(qc), tostring(timeLeft), tostring(zone)))
                end
            end
        end
    else
        addon.HSPrint("addon.GetTaskQuestsForMap is nil")
    end

    -- 2) Area POIs: Events and Quest Hubs
    if ctx.zoneMapID and C_AreaPoiInfo and C_AreaPoiInfo.GetEventsForMap then
        addon.HSPrint("-- C_AreaPoiInfo events for zoneMapID --")
        local ok, eventIDs = pcall(C_AreaPoiInfo.GetEventsForMap, ctx.zoneMapID)
        if ok and eventIDs then
            addon.HSPrint("events: " .. tostring(#eventIDs))
            for _, areaPoiID in ipairs(eventIDs) do
                local poiInfo = (C_AreaPoiInfo.GetAreaPOIInfo and select(2, pcall(C_AreaPoiInfo.GetAreaPOIInfo, ctx.zoneMapID, areaPoiID)))
                local name = poiInfo and poiInfo.name or "?"
                local linked = poiInfo and poiInfo.linkedUiMapID
                addon.HSPrint(("  eventPOI %d: %s | linked=%s"):format(areaPoiID, tostring(name), tostring(linked)))
            end
        else
            addon.HSPrint("GetEventsForMap returned nil")
        end
    end

    if ctx.zoneMapID and C_AreaPoiInfo and C_AreaPoiInfo.GetQuestHubsForMap then
        addon.HSPrint("-- C_AreaPoiInfo quest hubs for zoneMapID --")
        local ok, hubIDs = pcall(C_AreaPoiInfo.GetQuestHubsForMap, ctx.zoneMapID)
        if ok and hubIDs then
            addon.HSPrint("hubs: " .. tostring(#hubIDs))
            for _, areaPoiID in ipairs(hubIDs) do
                local poiInfo = (C_AreaPoiInfo.GetAreaPOIInfo and select(2, pcall(C_AreaPoiInfo.GetAreaPOIInfo, ctx.zoneMapID, areaPoiID)))
                local name = poiInfo and poiInfo.name or "?"
                local linked = poiInfo and poiInfo.linkedUiMapID
                addon.HSPrint(("  hubPOI %d: %s | linked=%s"):format(areaPoiID, tostring(name), tostring(linked)))
            end
        else
            addon.HSPrint("GetQuestHubsForMap returned nil")
        end
    end

    addon.HSPrint("=== End WQ Discovery Dump ===")
end

-- /hswqdebug (backwards-compat alias for /h debug focus wqdebug)
SLASH_HSWQDEBUG1 = "/hswqdebug"
SlashCmdList.HSWQDEBUG = function()
    if SlashCmdList["MODERNQUESTTRACKER"] then
        SlashCmdList["MODERNQUESTTRACKER"]("debug focus wqdebug")
    elseif addon.DumpWorldQuestDiscovery then
        addon.DumpWorldQuestDiscovery()
    end
end

addon.GetNearbyQuestIDs          = GetNearbyQuestIDs
addon.GetNearbyDebugInfo         = GetNearbyDebugInfo
addon.GetWorldAndCallingQuestIDsToShow = GetWorldAndCallingQuestIDsToShow
addon.CollectWorldQuests         = CollectWorldQuests
addon.GetCurrentWorldQuestWatchSet = GetCurrentWorldQuestWatchSet
addon.RemoveWorldQuestWatch      = RemoveWorldQuestWatch
