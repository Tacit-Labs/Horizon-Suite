--[[
    Horizon Suite - Focus - Aggregator
    Builds context, calls each content provider, normalizes entries, and returns merged quest list.
    APIs: C_QuestLog, C_SuperTrack, GetQuestLogSpecialItemInfo, GetQuestLogTitle.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

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
    DELVES = 5, SCENARIO = 5, ACHIEVEMENT = 5, RECIPE = 5, DUNGEON = 5, RAID = 5, WORLD = 6, WEEKLY = 7, DAILY = 8, CALLING = 9, RARE = 10, DEFAULT = 11,
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

local function CompareEntriesBySortMode(a, b)
    if currentSortGroup == "NEARBY" and addon.GetDB("nearbyCompleteToBottom", true) then
        local ac = a.isComplete and 1 or 0
        local bc = b.isComplete and 1 or 0
        if ac ~= bc then return ac < bc end  -- non-complete (0) before complete (1)
    end
    if a.category == "WORLD" or a.category == "CALLING" then
        -- Priority: tracked/accepted (2) > proximity/in-quest-area (1) > zone-only (0)
        local pa = ((a.isTracked or a.isAccepted) and 2) or ((a.isInQuestArea and 1) or 0)
        local pb = ((b.isTracked or b.isAccepted) and 2) or ((b.isInQuestArea and 1) or 0)
        if pa ~= pb then return pa > pb end
    elseif a.category == "WEEKLY" or a.category == "DAILY" then
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

    local showCurrent = addon.GetDB("showCurrentQuestCategory", true) and groups["CURRENT"]
    local playerZone = (addon.GetPlayerCurrentZoneName and addon.GetPlayerCurrentZoneName()) or nil
    for _, q in ipairs(quests) do
        if showCurrent and q.questID and IsQuestRecentlyProgressed(q.questID) then
            groups["CURRENT"][#groups["CURRENT"] + 1] = q
        elseif addon.GetDB("showNearbyGroup", true) and groups["NEARBY"]
            and q.questID and q.isAccepted
            and IsQuestRecentlyExpiredFromCurrent(q.questID)
            and (q.isNearby or (q.zoneName and playerZone and q.zoneName:lower() == playerZone:lower()))
        then
            groups["NEARBY"][#groups["NEARBY"] + 1] = q
        elseif q.isRare or q.category == "RARE" then
            groups["RARES"][#groups["RARES"] + 1] = q
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
        elseif q.category == "RECIPE" or q.isRecipe then
            groups["RECIPES"][#groups["RECIPES"] + 1] = q
        elseif q.category == "ADVENTURE" or q.isAdventureGuide then
            groups["ADVENTURE"][#groups["ADVENTURE"] + 1] = q
        elseif q.category == "WORLD" or q.category == "CALLING" then
            groups["WORLD"][#groups["WORLD"] + 1] = q
        elseif q.isNearby and not q.isAccepted then
            groups["AVAILABLE"][#groups["AVAILABLE"] + 1] = q
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
    return result
end

--- Build the full list of quests by calling each provider and normalizing.
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

    local function questMapMatchesPlayer(questID)
        if not filterByZone then return true end
        if not questID or questID <= 0 then return false end
        if not zoneMapID or not C_TaskQuest or not C_TaskQuest.GetQuestZoneID or not C_Map or not C_Map.GetMapInfo then
            -- Fallback to legacy name-based filter when map APIs aren't available.
            local playerZone = (addon.GetPlayerCurrentZoneName and addon.GetPlayerCurrentZoneName()) or nil
            local zn = addon.GetQuestZoneName and addon.GetQuestZoneName(questID)
            return (not zn) or (not playerZone) or zn:lower() == playerZone:lower()
        end

        local ok, qMapID = pcall(C_TaskQuest.GetQuestZoneID, questID)
        if not ok or not qMapID or qMapID == 0 then
            -- If task quest API can't resolve it, don't hard-filter it out.
            return true
        end

        local checkID = qMapID
        for _ = 1, 8 do
            if checkID == zoneMapID then return true end
            local info = C_Map.GetMapInfo(checkID)
            if not info or not info.parentMapID or info.parentMapID == 0 then break end
            checkID = info.parentMapID
        end
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
        if not isAccepted and not isExplicitlyTracked and (category == "WORLD" or category == "CALLING" or category == "WEEKLY" or category == "DAILY") then
            if not IsQuestOnPlayerZoneMap(questID) then return end
        end

        if not isExplicitlyTracked and not questMapMatchesPlayer(questID) then return end
        seen[questID] = true

        local baseCategory = (category == "COMPLETE") and addon.GetQuestBaseCategory(questID) or nil
        local title = C_QuestLog.GetTitleForQuestID(questID) or UNKNOWN_TITLE_PLACEHOLDER
        local objectives = C_QuestLog.GetQuestObjectives(questID) or {}
        local objectivesDoneCount, objectivesTotalCount
        local completedObjDisplay = addon.GetDB("questCompletedObjectiveDisplay", "off")
        if completedObjDisplay == "hide" and #objectives > 0 then
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
        local isComplete = C_QuestLog.IsComplete(questID)
        local isSuper = (questID == superTracked)
        local zoneName = addon.GetQuestZoneName(questID)
        local isNearby = (nearbySet[questID] or false) and (not filterByZone or questMapMatchesPlayer(questID))
        local isDungeonQuest = opts.isDungeonQuest or (addon.IsInPartyDungeon and addon.IsInPartyDungeon() and isNearby)
        local isRaidQuest = opts.isRaidQuest or (category == "RAID")
        local isTracked = opts.isTracked ~= false
        local isAutoAdded = opts.isAutoAdded and true or false
        local isInQuestArea = opts.isInQuestArea and true or false

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
            if C_TaskQuest.GetQuestTimeLeftSeconds then
                local tokS, secs = pcall(C_TaskQuest.GetQuestTimeLeftSeconds, questID)
                if tokS and secs and secs > 0 then
                    timerDuration = secs
                    timerStartTime = GetTime()
                end
            elseif C_TaskQuest.GetQuestTimeLeftMinutes then
                local tokM, mins = pcall(C_TaskQuest.GetQuestTimeLeftMinutes, questID)
                if tokM and mins and mins > 0 then
                    timerDuration = mins * 60
                    timerStartTime = GetTime()
                end
            end
        end

        local entry = {
            entryKey = questID, questID = questID, title = title, objectives = objectives,
            color = color, category = category, baseCategory = baseCategory,
            isComplete = isComplete, isSuperTracked = isSuper, isNearby = isNearby,
            isAccepted = isAccepted, zoneName = zoneName, itemLink = itemLink, itemTexture = itemTexture,
            questTypeAtlas = questTypeAtlas, isDungeonQuest = isDungeonQuest, isRaidQuest = isRaidQuest, isTracked = isTracked, level = questLevel,
            isAutoComplete = isAutoComplete,
            isAutoAdded = isAutoAdded,
            isInQuestArea = isInQuestArea,
            isEventQuest = opts.isEventQuest,
            isGroupQuest = isGroupQuest,
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

        if not seen[e.questID]
            and not isBlacklisted
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
