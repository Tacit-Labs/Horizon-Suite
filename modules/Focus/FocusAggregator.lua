--[[
    Horizon Suite - Focus - Aggregator
    Builds context, calls each content provider, normalizes entries, and returns merged quest list.
    APIs: C_QuestLog, C_SuperTrack, GetQuestLogSpecialItemInfo, GetQuestLogTitle.
]]

local addon = _G.HorizonSuite

local DEFAULT_SORT_MODE = "questType"
local CATEGORY_SORT_FALLBACK = 99
local DEFAULT_GROUP = "DEFAULT"
local UNKNOWN_TITLE_PLACEHOLDER = "..."

-- Entry sort mode: alpha, questType, zone, level (DB key entrySortMode, default questType)
local VALID_ENTRY_SORT = { alpha = true, questType = true, zone = true, level = true }

local currentSortGroup  -- set before each table.sort so comparator knows its group

--- Current entry sort mode from DB (alpha, questType, zone, or level).
--- @return string Sort mode key
local function GetSortMode()
    local mode = addon.GetDB("entrySortMode", DEFAULT_SORT_MODE)
    if type(mode) == "string" and VALID_ENTRY_SORT[mode] then return mode end
    return DEFAULT_SORT_MODE
end

-- Category order for questType sort (lower = earlier)
local CATEGORY_SORT_ORDER = {
    CURRENT = 0, COMPLETE = 1, CAMPAIGN = 2, IMPORTANT = 3, LEGENDARY = 4,
    DELVES = 5, SCENARIO = 5, ACHIEVEMENT = 5, APPEARANCE = 5, RECIPE = 5, DUNGEON = 5, RAID = 5, WORLD = 6, WEEKLY = 7, PREY = 7, DAILY = 8, CALLING = 9, RARE = 10, RARE_LOOT = 10, DEFAULT = 11,
}

local CURRENT_QUEST_WINDOW_DEFAULT = 60
local CURRENT_QUEST_EXPIRED_GRACE_SEC = 600

--- Returns true if the quest had progress (objectives or accept) within the configured window.
--- Lazily removes expired entries from recentlyProgressedQuests.
--- When expiring, records questID in recentlyExpiredFromCurrent for NEARBY routing.
--- @param questID number
--- @return boolean
local function IsQuestRecentlyProgressed(questID)
    if not questID or questID <= 0 then return false end
    local cache = addon.focus and addon.focus.recentlyProgressedQuests
    if type(cache) ~= "table" then return false end

    local window = tonumber(addon.GetDB("currentQuestWindowSec", CURRENT_QUEST_WINDOW_DEFAULT)) or CURRENT_QUEST_WINDOW_DEFAULT
    local now = GetTime()

    local ts = cache[questID]
    if not ts then return false end
    if now - ts >= window then
        if not addon.focus.recentlyExpiredFromCurrent then addon.focus.recentlyExpiredFromCurrent = {} end
        addon.focus.recentlyExpiredFromCurrent[questID] = now
        cache[questID] = nil
        return false
    end
    return true
end

--- Returns true if the quest recently expired from CURRENT and is within the grace period.
--- Lazily removes expired entries from recentlyExpiredFromCurrent.
--- @param questID number
--- @return boolean
local function IsQuestRecentlyExpiredFromCurrent(questID)
    if not questID or questID <= 0 then return false end
    local cache = addon.focus and addon.focus.recentlyExpiredFromCurrent
    if type(cache) ~= "table" then return false end

    local grace = CURRENT_QUEST_EXPIRED_GRACE_SEC
    local now = GetTime()

    local ts = cache[questID]
    if not ts then return false end
    if now - ts >= grace then
        cache[questID] = nil
        return false
    end
    return true
end

--- Returns true if objectives has at least one objective with usable progress (percent or numFulfilled/numRequired).
--- @param objectives table
--- @return boolean
local function HasUsableObjectives(objectives)
    if not objectives or #objectives == 0 then return false end
    for _, o in ipairs(objectives) do
        if (o.percent ~= nil and type(o.percent) == "number") or
           (o.numFulfilled ~= nil and o.numRequired ~= nil) then
            return true
        end
    end
    return false
end

--- Deep copy of objectives array for WQ progress cache (preserves text, percent, numFulfilled, numRequired, finished, type).
--- @param objectives table
--- @return table
local function CopyObjectives(objectives)
    if not objectives or #objectives == 0 then return {} end
    local out = {}
    for i, o in ipairs(objectives) do
        if type(o) == "table" then
            out[i] = {}
            for k, v in pairs(o) do out[i][k] = v end
        end
    end
    return out
end

local function CompareEntriesBySortMode(a, b)
    if currentSortGroup == "NEARBY" and addon.GetDB("nearbyCompleteToBottom", true) then
        local ac = a.isComplete and 1 or 0
        local bc = b.isComplete and 1 or 0
        if ac ~= bc then return ac < bc end  -- non-complete (0) before complete (1)
    end
    if currentSortGroup == "PREY" then
        -- Weeklies (accepted quests) first, then Prey world quests (activities)
        local wa = (a.isPreyWorldQuest and 1) or 0
        local wb = (b.isPreyWorldQuest and 1) or 0
        if wa ~= wb then return wa < wb end
    end
    if a.category == "WORLD" or a.category == "CALLING" then
        -- Priority: tracked/accepted (2) > proximity/in-quest-area (1) > zone-only (0)
        local pa = ((a.isTracked or a.isAccepted) and 2) or ((a.isInQuestArea and 1) or 0)
        local pb = ((b.isTracked or b.isAccepted) and 2) or ((b.isInQuestArea and 1) or 0)
        if pa ~= pb then return pa > pb end
    elseif a.category == "WEEKLY" or a.category == "DAILY" or a.category == "PREY" then
        local pa = (a.isAccepted and 1) or 0
        local pb = (b.isAccepted and 1) or 0
        if pa ~= pb then return pa > pb end
    end

    local mode = GetSortMode()
    local ta, tb = (a.title or ""):lower(), (b.title or ""):lower()

    if mode == "alpha" then return ta < tb end
    if mode == "questType" then
        local ra, rb = CATEGORY_SORT_ORDER[a.category] or CATEGORY_SORT_FALLBACK, CATEGORY_SORT_ORDER[b.category] or CATEGORY_SORT_FALLBACK
        if ra ~= rb then return ra < rb end
        return ta < tb
    end
    if mode == "zone" then
        local za, zb = (a.zoneName or ""):lower(), (b.zoneName or ""):lower()
        if za ~= zb then return za < zb end
        return ta < tb
    end
    if mode == "level" then
        local la, lb = a.level or 0, b.level or 0
        if la ~= lb then return la > lb end
        return ta < tb
    end
    return ta < tb
end

--- Buckets entries by group key, sorts each group, and returns ordered { key, quests } array.
--- @param quests table Array of normalized entry tables
--- @return table Array of { key = string, quests = table }
local function SortAndGroupQuests(quests)
    local groups = {}
    local order = (addon.GetGroupOrder and addon.GetGroupOrder()) or addon.GROUP_ORDER or {}
    if type(order) ~= "table" then order = {} end

    -- Load-order safety: config tables should come from core/Config.lua, but never hard-crash if missing.
    local categoryToGroup = addon.CATEGORY_TO_GROUP
    if type(categoryToGroup) ~= "table" then
        categoryToGroup = {}
        addon.CATEGORY_TO_GROUP = categoryToGroup
    end

    for _, key in ipairs(order) do
        groups[key] = {}
    end

    local showComplete = addon.GetDB("showCompleteGroup", true) and groups["COMPLETE"]
    local keepCampaignInCat = addon.GetDB("keepCampaignInCategory", false)
    local keepImportantInCat = addon.GetDB("keepImportantInCategory", false)
    local showCurrent = addon.GetDB("showCurrentQuestCategory", true) and groups["CURRENT"]
    local showEventsInZone = addon.GetDB("showEventsInZone", true)
    local playerZone = (addon.GetPlayerCurrentZoneName and addon.GetPlayerCurrentZoneName()) or nil
    local scenarioActive = false
    if addon.ReadScenarioEntries then
        local entries = addon.ReadScenarioEntries()
        if entries then
            for _, e in ipairs(entries) do
                if e.objectives and #e.objectives > 0 then
                    scenarioActive = true
                    break
                end
            end
        end
    end
    for _, q in ipairs(quests) do
        local isEventInPlayerZone = q.isEventQuest
            and (q.isNearby or (q.zoneName and playerZone and q.zoneName:lower() == playerZone:lower()))

        -- Event quests never participate in Current Quest / expired-from-Current routing.
        -- In-zone events move between Current Event and Events in Zone based on proximity.
        -- When a scenario is active, suppress BonusObjective (event) quests from CURRENT_EVENT
        -- so only the scenario entry is shown (matches Blizzard: quest + scenario widget).
        if q.isEventQuest and q.isAccepted and q.isNearby and groups["CURRENT_EVENT"] then
            if not scenarioActive then
                groups["CURRENT_EVENT"][#groups["CURRENT_EVENT"] + 1] = q
            end
        elseif (q.category == "WORLD" or q.category == "CALLING") and q.isInQuestArea and groups["CURRENT_EVENT"] then
            groups["CURRENT_EVENT"][#groups["CURRENT_EVENT"] + 1] = q
        elseif isEventInPlayerZone then
            -- When off, omit entirely (do not fall through to other categories)—same as hiding this bucket.
            if showEventsInZone and groups["AVAILABLE"] then
                groups["AVAILABLE"][#groups["AVAILABLE"] + 1] = q
            end
        elseif q.isComplete and showComplete
            and not (q.category == "CAMPAIGN" and keepCampaignInCat)
            and not (q.category == "IMPORTANT" and keepImportantInCat) then
            groups["COMPLETE"][#groups["COMPLETE"] + 1] = q
        elseif not q.isEventQuest
            and not (q.category == "WORLD" or q.category == "CALLING")
            and showCurrent and q.questID and not q.isComplete and IsQuestRecentlyProgressed(q.questID) then
            groups["CURRENT"][#groups["CURRENT"] + 1] = q
        elseif not q.isEventQuest
            and addon.GetDB("showNearbyGroup", true) and groups["NEARBY"]
            and q.questID and q.isAccepted
            and IsQuestRecentlyExpiredFromCurrent(q.questID)
            and (q.isNearby or (q.zoneName and playerZone and q.zoneName:lower() == playerZone:lower()))
        then
            groups["NEARBY"][#groups["NEARBY"] + 1] = q
        elseif q.isRare or q.category == "RARE" then
            groups["RARES"][#groups["RARES"] + 1] = q
        elseif q.isRareLoot or q.category == "RARE_LOOT" then
            groups["RARE_LOOT"][#groups["RARE_LOOT"] + 1] = q
        elseif q.isDungeonQuest or q.category == "DUNGEON" then
            groups["DUNGEON"][#groups["DUNGEON"] + 1] = q
        elseif q.isRaidQuest or q.category == "RAID" then
            groups["RAID"][#groups["RAID"] + 1] = q
        elseif q.category == "DELVES" then
            groups["DELVES"][#groups["DELVES"] + 1] = q
        elseif q.category == "SCENARIO" then
            groups["SCENARIO"][#groups["SCENARIO"] + 1] = q
        elseif q.category == "ACHIEVEMENT" or q.isAchievement then
            groups["ACHIEVEMENTS"][#groups["ACHIEVEMENTS"] + 1] = q
        elseif q.category == "ENDEAVOR" or q.isEndeavor then
            groups["ENDEAVORS"][#groups["ENDEAVORS"] + 1] = q
        elseif q.category == "DECOR" or q.isDecor then
            groups["DECOR"][#groups["DECOR"] + 1] = q
        elseif q.category == "APPEARANCE" or q.isAppearance then
            groups["APPEARANCES"][#groups["APPEARANCES"] + 1] = q
        elseif q.category == "RECIPE" or q.isRecipe then
            groups["RECIPES"][#groups["RECIPES"] + 1] = q
        elseif q.category == "ADVENTURE" or q.isAdventureGuide then
            groups["ADVENTURE"][#groups["ADVENTURE"] + 1] = q
        elseif q.category == "WORLD" or q.category == "CALLING" then
            groups["WORLD"][#groups["WORLD"] + 1] = q
        elseif q.category == "PREY" then
            groups["PREY"][#groups["PREY"] + 1] = q
        elseif q.isNearby and not q.isAccepted then
            if showEventsInZone and groups["AVAILABLE"] then
                groups["AVAILABLE"][#groups["AVAILABLE"] + 1] = q
            end
        elseif q.isNearby and q.isAccepted then
            if addon.GetDB("showNearbyGroup", true) then
                groups["NEARBY"][#groups["NEARBY"] + 1] = q
            else
                local grp = categoryToGroup[q.category] or DEFAULT_GROUP
                groups[grp][#groups[grp] + 1] = q
            end
        else
            local grp = categoryToGroup[q.category] or DEFAULT_GROUP
            groups[grp][#groups[grp] + 1] = q
        end
    end

    for _, key in ipairs(order) do
        if #groups[key] > 0 then
            currentSortGroup = key
            table.sort(groups[key], CompareEntriesBySortMode)
            -- Always assign numbering at the source of truth so renderers can rely on it.
            for i = 1, #groups[key] do
                groups[key][i].categoryIndex = i
            end
        end
    end

    local result = {}
    for _, key in ipairs(order) do
        if #groups[key] > 0 then
            result[#result + 1] = { key = key, quests = groups[key] }
        end
    end

    if addon.GetDB("hideOtherCategoriesInDelve", false) then
        if addon.IsDelveActive and addon.IsDelveActive() then
            for _, grp in ipairs(result) do
                if grp.key == "DELVES" then return { grp } end
            end
            return {}
        end
        if addon.IsInPartyDungeon and addon.IsInPartyDungeon() then
            for _, grp in ipairs(result) do
                if grp.key == "DUNGEON" then return { grp } end
            end
            return {}
        end
    end

    -- When Grow Upwards is on, the Objectives header is anchored at the bottom of the
    -- panel. Reverse section order so the highest-priority section sits closest to the
    -- header (matches grow-down's priority-next-to-header layout). Within-section entry
    -- ordering is unchanged — only section envelopes are reordered.
    if addon.GetDB("growUp", false) then
        local reversed = {}
        for i = #result, 1, -1 do
            reversed[#reversed + 1] = result[i]
        end
        result = reversed
    end

    return result
end

-- Memoises the parent-map walk shared by IsQuestOnPlayerZoneMap / questMapMatchesPlayer.
-- Invalidated when the player's zoneMapID changes.
local questAncestorCacheZoneMapID = nil
local questAncestorCache = {}
local ANCESTOR_WALK_DEPTH = 10

local function QuestAncestorMatchesZone(questID, zoneMapID)
    if not questID or not zoneMapID then return false end
    if questAncestorCacheZoneMapID ~= zoneMapID then
        wipe(questAncestorCache)
        questAncestorCacheZoneMapID = zoneMapID
    end
    local cached = questAncestorCache[questID]
    if cached ~= nil then return cached end
    if not (C_TaskQuest and C_TaskQuest.GetQuestZoneID and C_Map and C_Map.GetMapInfo) then
        return false
    end
    local ok, qMapID = pcall(C_TaskQuest.GetQuestZoneID, questID)
    if not ok or not qMapID or qMapID == 0 then
        -- Leave uncached so we re-check after the API settles.
        return false
    end
    local checkID = qMapID
    for _ = 1, ANCESTOR_WALK_DEPTH do
        if checkID == zoneMapID then
            questAncestorCache[questID] = true
            return true
        end
        local info = C_Map.GetMapInfo(checkID)
        if not info or not info.parentMapID or info.parentMapID == 0 then break end
        checkID = info.parentMapID
    end
    questAncestorCache[questID] = false
    return false
end

--- Respects filterByZone and test data. Merges Collect* providers and ReadScenarioEntries.
--- @return table Array of normalized entry tables (see entry shape in FocusState.lua)
local function ReadTrackedQuests()
    if addon.testQuests then
        return addon.testQuests
    end

    local quests = {}
    local seen = {}
    local scenarioRewardQuestIDs = {}
    if addon.ReadScenarioEntries then
        for _, se in ipairs(addon.ReadScenarioEntries()) do
            local rid = se.rewardQuestID
            if type(rid) == "number" and rid > 0 then
                scenarioRewardQuestIDs[rid] = true
            end
        end
    end

    local superTracked = (C_SuperTrack and C_SuperTrack.GetSuperTrackedQuestID) and C_SuperTrack.GetSuperTrackedQuestID() or 0
    local nearbySet, taskQuestOnlySet = {}, {}
    if addon.GetNearbyQuestIDs then
        nearbySet, taskQuestOnlySet = addon.GetNearbyQuestIDs()
    end
    local playerZone = (addon.GetPlayerCurrentZoneName and addon.GetPlayerCurrentZoneName()) or nil
    local filterByZone = addon.GetDB("filterByZone", false)

    -- Resolve stable map context once per layout tick.
    local mapCtx = addon.ResolvePlayerMapContext and addon.ResolvePlayerMapContext("player") or nil
    local zoneMapID = mapCtx and mapCtx.zoneMapID or nil

    -- Map gate for map-scoped content (world/calling/weekly/daily) even when filterByZone is off.
    -- We only apply this to non-accepted quests. Accepted quests can legitimately be from other zones.
    local function IsQuestOnPlayerZoneMap(questID)
        if not questID or questID <= 0 then return false end
        if not zoneMapID or not (C_TaskQuest and C_TaskQuest.GetQuestZoneID) or not (C_Map and C_Map.GetMapInfo) then
            return true
        end
        -- Short-circuit: API unresolved for questID (matches old "return true" behaviour).
        if C_TaskQuest.GetQuestZoneID then
            local ok, qMapID = pcall(C_TaskQuest.GetQuestZoneID, questID)
            if not ok or not qMapID or qMapID == 0 then return true end
        end
        if QuestAncestorMatchesZone(questID, zoneMapID) then return true end
        -- Fallback: name-based zone check for quests with non-geographic zone IDs (e.g. Prey).
        local zn = addon.GetQuestZoneName and addon.GetQuestZoneName(questID)
        if zn and playerZone and zn:lower() == playerZone:lower() then return true end
        if nearbySet[questID] then return true end
        return false
    end

    local function questMapMatchesPlayer(questID)
        if not filterByZone then return true end
        if not questID or questID <= 0 then return false end
        if not zoneMapID or not C_TaskQuest or not C_TaskQuest.GetQuestZoneID or not C_Map or not C_Map.GetMapInfo then
            -- Fallback to legacy name-based filter when map APIs aren't available.
            local playerZoneLocal = (addon.GetPlayerCurrentZoneName and addon.GetPlayerCurrentZoneName()) or nil
            local zn = addon.GetQuestZoneName and addon.GetQuestZoneName(questID)
            return (not zn) or (not playerZoneLocal) or zn:lower() == playerZoneLocal:lower()
        end
        -- Short-circuit: API unresolved for questID → don't hard-filter.
        local ok, qMapID = pcall(C_TaskQuest.GetQuestZoneID, questID)
        if not ok or not qMapID or qMapID == 0 then return true end
        if QuestAncestorMatchesZone(questID, zoneMapID) then return true end
        -- Fallback: name-based zone check for quests with non-geographic zone IDs (e.g. Prey).
        local zn = addon.GetQuestZoneName and addon.GetQuestZoneName(questID)
        if zn and playerZone and zn:lower() == playerZone:lower() then return true end
        if nearbySet[questID] then return true end
        return false
    end

    local function addQuest(questID, opts)
        opts = opts or {}
        if not questID or questID <= 0 or seen[questID] then return end
        if scenarioRewardQuestIDs[questID] then return end

        -- Always exclude cross-zone map-scoped content that is not in the player's log.
        -- This is separate from the user-facing filterByZone option.
        -- Exception: explicitly tracked (manual watch list, WQT, supertracked) quests bypass the zone gate.
        -- Use IsQuestAccepted (IsOnQuest) so campaign/available entries are not treated as accepted.
        local logIndex = C_QuestLog.GetLogIndexForQuestID and C_QuestLog.GetLogIndexForQuestID(questID) or nil
        local isAccepted = addon.IsQuestAccepted and addon.IsQuestAccepted(questID) or (logIndex ~= nil)
        local isExplicitlyTracked = (opts.isTracked == true) or (superTracked and questID == superTracked)
        local category = opts.forceCategory or addon.GetQuestCategory(questID)
        if not isAccepted and not isExplicitlyTracked and (category == "WORLD" or category == "CALLING" or category == "WEEKLY" or category == "PREY" or category == "DAILY") then
            if not IsQuestOnPlayerZoneMap(questID) then return end
        end

        if not isExplicitlyTracked and not questMapMatchesPlayer(questID) then return end
        seen[questID] = true

        local baseCategory = (category == "COMPLETE") and addon.GetQuestBaseCategory(questID) or nil
        local title = C_QuestLog.GetTitleForQuestID(questID) or UNKNOWN_TITLE_PLACEHOLDER
        if title:find("%[DNT%]") then return end
        local objectives = C_QuestLog.GetQuestObjectives(questID) or {}
        for _, obj in ipairs(objectives) do
            if obj.text and obj.text:find("%[DNT%]") then return end
        end

        -- Compute isInQuestArea for WORLD/CALLING when provider did not set it.
        local isInQuestArea = opts.isInQuestArea
        if isInQuestArea == nil and (category == "WORLD" or category == "CALLING") and C_QuestLog and C_QuestLog.IsOnQuest then
            isInQuestArea = C_QuestLog.IsOnQuest(questID)
        end
        isInQuestArea = isInQuestArea and true or false

        -- Cache/fallback for zone-based world quests: Blizzard returns empty/zeroed when outside zone.
        if category == "WORLD" or category == "CALLING" then
            local cache = addon.focus.cachedWorldQuestObjectives
            if not cache then addon.focus.cachedWorldQuestObjectives = {} cache = addon.focus.cachedWorldQuestObjectives end
            local isCompleteForCache = C_QuestLog.IsComplete and C_QuestLog.IsComplete(questID)

            if isCompleteForCache then
                cache[questID] = nil
            elseif isInQuestArea then
                if HasUsableObjectives(objectives) then
                    cache[questID] = { objectives = CopyObjectives(objectives) }
                end
            else
                if not HasUsableObjectives(objectives) and cache[questID] then
                    objectives = cache[questID].objectives
                end
            end
        end

        local objectivesDoneCount, objectivesTotalCount
        local completedObjDisplay = addon.GetDB("questCompletedObjectiveDisplay", "off")
        -- Ready-to-turn-in fallback in FocusEntryRenderer needs shownObjs == 0; strip finished
        -- objectives when hide always, or when fade and the quest is complete (same as hide for turn-in).
        local isComplete = C_QuestLog.IsComplete and C_QuestLog.IsComplete(questID) or false
        if #objectives > 0
            and (completedObjDisplay == "hide" or (completedObjDisplay == "fade" and isComplete)) then
            objectivesDoneCount, objectivesTotalCount = 0, #objectives
            for _, o in ipairs(objectives) do
                if o.finished then objectivesDoneCount = objectivesDoneCount + 1 end
            end
            local filtered = {}
            for _, o in ipairs(objectives) do
                if not o.finished then filtered[#filtered + 1] = o end
            end
            objectives = filtered
        end
        local color = addon.GetQuestColor(category)
        local isSuper = (questID == superTracked)
        local zoneName = addon.GetQuestZoneName(questID)
        if category == "PREY" and (addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID)) and (not zoneName or zoneName == "") then
            zoneName = (addon.L and addon.L["FOCUS_ACTIVITY"]) or "Activity"
        end
        local isNearby = (nearbySet[questID] or false) and (not filterByZone or questMapMatchesPlayer(questID))
        local isDungeonQuest = opts.isDungeonQuest or (addon.IsInPartyDungeon and addon.IsInPartyDungeon() and isNearby)
        local isRaidQuest = opts.isRaidQuest or (category == "RAID")
        local isTracked = opts.isTracked ~= false
        local isAutoAdded = opts.isAutoAdded and true or false

        local itemLink, itemTexture
        if logIndex and GetQuestLogSpecialItemInfo then
            local link, tex = GetQuestLogSpecialItemInfo(logIndex)
            if link and tex then itemLink, itemTexture = link, tex end
        end

        local questLevel
        local isAutoComplete = false
        if logIndex then
            -- pcall: C_QuestLog.GetInfo can throw on invalid logIndex.
            if C_QuestLog.GetInfo then
                local ok, info = pcall(C_QuestLog.GetInfo, logIndex)
                if ok and info then
                    if info.level then questLevel = info.level end
                    if info.isAutoComplete then isAutoComplete = true end
                end
            end
            if not questLevel and GetQuestLogTitle then
                -- pcall: GetQuestLogTitle can throw on invalid logIndex.
                local ok, _, level = pcall(GetQuestLogTitle, logIndex)
                if ok and level then questLevel = level end
            end
        end

        local questTypeAtlas = addon.GetQuestTypeAtlas(questID, category)
        local isGroupQuest = addon.IsGroupQuest and addon.IsGroupQuest(questID) or false

        -- Derive isEventQuest when provider did not set it (e.g. CollectTrackedQuests, super-tracked).
        -- Event quests from watch list or other sources must still route to CURRENT_EVENT.
        local isEventQuest = opts.isEventQuest
        if isEventQuest == nil and C_QuestInfoSystem and C_QuestInfoSystem.GetQuestClassification and Enum and Enum.QuestClassification then
            local qc = C_QuestInfoSystem.GetQuestClassification(questID)
            local isWorld = (addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID)) or (C_QuestLog and C_QuestLog.IsWorldQuest and C_QuestLog.IsWorldQuest(questID))
            local isCalling = C_QuestLog and C_QuestLog.IsQuestCalling and C_QuestLog.IsQuestCalling(questID)
            if qc == Enum.QuestClassification.BonusObjective and not isWorld and not isCalling then
                isEventQuest = true
            end
        end

        local timerDuration, timerStartTime
        if C_QuestLog and C_QuestLog.GetTimeAllowed then
            local tokT, total, elapsed = pcall(C_QuestLog.GetTimeAllowed, questID)
            if tokT and total and elapsed and total > 0 and elapsed >= 0 then
                local elapsedCapped = math.min(elapsed, total)
                timerDuration = total
                timerStartTime = GetTime() - elapsedCapped
            end
        end
        if not timerDuration and C_TaskQuest then
            local now = GetTime()
            local cache = addon.focus and addon.focus.questTimerCache
            local cached = cache and cache[questID]
            local useCache = cached and (now - cached.startTime) < cached.duration

            if useCache then
                timerDuration = cached.duration
                timerStartTime = cached.startTime
            else
                if C_TaskQuest.GetQuestTimeLeftSeconds then
                    local tokS, secs = pcall(C_TaskQuest.GetQuestTimeLeftSeconds, questID)
                    if tokS and secs and secs > 0 then
                        timerDuration = secs
                        timerStartTime = now
                        if cache then cache[questID] = { duration = secs, startTime = now } end
                    elseif cache and cache[questID] then
                        cache[questID] = nil
                    end
                elseif C_TaskQuest.GetQuestTimeLeftMinutes then
                    local tokM, mins = pcall(C_TaskQuest.GetQuestTimeLeftMinutes, questID)
                    if tokM and mins and mins > 0 then
                        timerDuration = mins * 60
                        timerStartTime = now
                        if cache then cache[questID] = { duration = mins * 60, startTime = now } end
                    elseif cache and cache[questID] then
                        cache[questID] = nil
                    end
                end
            end
        end

        local isPreyWorldQuest = (category == "PREY" and addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID)) or false
        local entry = {
            entryKey = questID, questID = questID, title = title, objectives = objectives,
            color = color, category = category, baseCategory = baseCategory,
            isComplete = isComplete, isSuperTracked = isSuper, isNearby = isNearby,
            isAccepted = isAccepted, zoneName = zoneName, itemLink = itemLink, itemTexture = itemTexture,
            questTypeAtlas = questTypeAtlas, isDungeonQuest = isDungeonQuest, isRaidQuest = isRaidQuest, isTracked = isTracked, level = questLevel,
            isAutoComplete = isAutoComplete,
            isAutoAdded = isAutoAdded,
            isInQuestArea = isInQuestArea,
            isEventQuest = isEventQuest,
            isGroupQuest = isGroupQuest,
            isPreyWorldQuest = isPreyWorldQuest,
            timerDuration = timerDuration,
            timerStartTime = timerStartTime,
        }
        if objectivesDoneCount and objectivesTotalCount then
            entry.objectivesDoneCount = objectivesDoneCount
            entry.objectivesTotalCount = objectivesTotalCount
        end
        quests[#quests + 1] = entry
    end

    local ctx = {
        nearbySet = nearbySet,
        taskQuestOnlySet = taskQuestOnlySet,
        playerZone = playerZone,
        filterByZone = filterByZone,
        seen = seen,
        superTracked = superTracked,
        scenarioRewardQuestIDs = scenarioRewardQuestIDs,
    }

    -- 1. Tracked quests (watch list)
    for _, e in ipairs(addon.CollectTrackedQuests(ctx)) do
        if not seen[e.questID] then addQuest(e.questID, e.opts or {}) end
    end

    -- 2. World quests and callings (with blacklist)
    local permanentBlacklist = addon.GetDB("permanentQuestBlacklist", {}) or {}
    local usePermanent = addon.GetDB("permanentlySuppressUntracked", false)
    local recentlyUntrackedWQ = addon.focus.recentlyUntrackedWorldQuests
    local wqEntries = {}
    if addon.CollectWorldQuests then
        wqEntries = addon.CollectWorldQuests(ctx) or {}
    end
    local showWorldQuests = addon.GetDB("showWorldQuests", true)
    for _, e in ipairs(wqEntries) do
        local opts = e.opts or {}
        local isBlacklisted = (usePermanent and permanentBlacklist[e.questID]) or (not usePermanent and recentlyUntrackedWQ and recentlyUntrackedWQ[e.questID])
        -- Final safety: reject completed WQs that leaked through upstream filters.
        local isCompleted = C_QuestLog.IsQuestFlaggedCompleted and C_QuestLog.IsQuestFlaggedCompleted(e.questID)

        -- If the toggle is OFF: only keep WORLD/CALLING items that are explicitly tracked
        -- (manual watch list, WQT's tracked set), or the current supertracked quest.
        -- Proximity alone is not enough to override the user's toggle.
        local explicitlyKept = (opts.isTracked == true) or (opts.isAutoAdded == false)
            or (superTracked and e.questID == superTracked)

        -- Bypass the untrack blacklist when the player is physically inside the quest area
        -- (must still appear as Current Event) or for BonusObjective event quests
        -- (proximity-only; never belong in the World Quests section anyway).
        local currentEventEligible = opts.isInQuestArea == true or opts.isEventQuest == true
        if not seen[e.questID]
            and (not isBlacklisted or currentEventEligible)
            and not isCompleted
            and (showWorldQuests == true or explicitlyKept) then
             addQuest(e.questID, opts)
        end
    end

    -- 3. Dailies and weeklies (with blacklist)
    local recentlyUntrackedDW = addon.focus.recentlyUntrackedWeekliesAndDailies
    for _, e in ipairs(addon.CollectDailiesWeeklies(ctx)) do
        local opts = e.opts or {}
        local isBlacklisted = (usePermanent and permanentBlacklist[e.questID]) or (not usePermanent and recentlyUntrackedDW and recentlyUntrackedDW[e.questID])
        if not seen[e.questID] and not isBlacklisted then
            addQuest(e.questID, opts)
        end
    end

    -- 4. Dungeon quests
    for _, e in ipairs(addon.CollectDungeonQuests(ctx)) do
        if not seen[e.questID] then addQuest(e.questID, e.opts or {}) end
    end

    -- 5. Delve quests
    for _, e in ipairs(addon.CollectDelveQuests(ctx)) do
        if not seen[e.questID] then addQuest(e.questID, e.opts or {}) end
    end

    -- 6. Super-tracked catch-all
    if superTracked and superTracked > 0 and not seen[superTracked] and not scenarioRewardQuestIDs[superTracked] then
        addQuest(superTracked, { isTracked = true })
    end

    -- 7. Scenario entries (already normalized)
    if addon.ReadScenarioEntries then
        for _, se in ipairs(addon.ReadScenarioEntries()) do
            quests[#quests + 1] = se
        end
    end

    if addon.testQuestItem then
        table.insert(quests, 1, addon.testQuestItem)
    end

    return quests
end

addon.ReadTrackedQuests   = ReadTrackedQuests
addon.SortAndGroupQuests  = SortAndGroupQuests
addon.GetSortMode         = GetSortMode
