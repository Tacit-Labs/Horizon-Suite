--[[
    Horizon Suite - Focus - Aggregator
    Builds context, calls each content provider, normalizes entries, and returns merged quest list.
    APIs: C_QuestLog, C_SuperTrack, GetQuestLogSpecialItemInfo, GetQuestLogTitle.
]]

local addon = _G.HorizonSuite
local L = addon.L
local DEFAULT_SORT_MODE = "questType"
local CATEGORY_SORT_FALLBACK = 99
local DEFAULT_GROUP = "DEFAULT"
local UNKNOWN_TITLE_PLACEHOLDER = "..."

-- Sibling-addon entry providers registered via addon.RegisterFocusEntryProvider.
local externalProviders = {}

-- Integration modules that handle rare/treasure display (suppress built-in scanner when any is active).
local rareProviders = {}

-- Entry sort mode: alpha, questType, zone, level, proximity (DB key entrySortMode, default questType)
local VALID_ENTRY_SORT = { alpha = true, questType = true, zone = true, level = true, proximity = true }

local currentSortGroup  -- set before each table.sort so comparator knows its group

-- Current entry sort mode from DB (alpha, questType, zone, level, or proximity).
-- @return string Sort mode key
local function GetSortMode()
    local mode = addon.GetDB("entrySortMode", DEFAULT_SORT_MODE)
    if type(mode) == "string" and VALID_ENTRY_SORT[mode] then return mode end
    return DEFAULT_SORT_MODE
end

-- Rebuilds addon.focus.proximityRank by ranking the shown quests by their live squared distance to
-- the player (C_QuestLog.GetDistanceSqToQuest). Nearest quest gets rank 1. Distance is recomputed
-- every pass, so the order tracks the player's position and re-ranks on zone AND sub-zone changes
-- (SortQuestWatches only re-ranks on full map changes, so it is deliberately not used here).
-- Quests with no on-continent position are left unranked and fall to the bottom via the comparator.
-- Also records the nearest quest as addon.focus.proximityClosestQID for the auto super-track driver.
local function RefreshProximityRank(quests)
    local focus = addon.focus
    if not focus then return end
    local rank = focus.proximityRank
    if type(rank) ~= "table" then rank = {}; focus.proximityRank = rank else wipe(rank) end
    focus.proximityClosestQID = nil
    focus.proximityClosestDistSq = nil
    if not (C_QuestLog and C_QuestLog.GetDistanceSqToQuest) then return end
    local ranked, seen = {}, {}
    for _, q in ipairs(quests) do
        local qid = q.questID
        if qid and qid > 0 and not seen[qid] then
            seen[qid] = true
            -- pcall: GetDistanceSqToQuest can throw on invalid/non-quest IDs (achievements, rares).
            local ok, distSq, onContinent = pcall(C_QuestLog.GetDistanceSqToQuest, qid)
            if ok and onContinent and distSq then
                ranked[#ranked + 1] = { qid = qid, dist = distSq }
            end
        end
    end
    table.sort(ranked, function(a, b) return a.dist < b.dist end)
    for i = 1, #ranked do rank[ranked[i].qid] = i end
    local first = ranked[1]
    focus.proximityClosestQID = first and first.qid or nil
    focus.proximityClosestDistSq = first and first.dist or nil
end

local VALID_PROXIMITY_AUTO_BEHAVIOUR = {
    always = true,
    respectManual = true,
    onlyWhenUnfocused = true,
}

local function GetProximityAutoBehaviour()
    local mode = addon.GetDB("proximityAutoBehaviour", "always")
    if type(mode) == "string" and VALID_PROXIMITY_AUTO_BEHAVIOUR[mode] then
        return mode
    end
    return "always"
end

--- Clear Respect Manual override and owned QID bookkeeping.
--- @return nil
local function ClearProximityManualOverride()
    local focus = addon.focus
    if not focus then return end
    focus.proximityManualOverride = false
    focus.proximityAutoOwnedQID = nil
end

--- Record a player-driven focus change for Respect Manual behaviour.
--- questID 0/nil clears override (player cleared focus). Other IDs set override when Auto-Focus
--- is on and behaviour is respectManual, unless the ID is the current closest or already owned.
--- @param questID number|nil
--- @return nil
local function MarkProximityManualOverride(questID)
    local focus = addon.focus
    if not focus then return end
    if not questID or questID <= 0 then
        focus.proximityManualOverride = false
        return
    end
    if not addon.GetDB("proximityAutoSuperTrack", false) then return end
    if GetProximityAutoBehaviour() ~= "respectManual" then return end
    if questID == focus.proximityClosestQID or questID == focus.proximityAutoOwnedQID then
        return
    end
    focus.proximityManualOverride = true
end

local function SetOwnedSuperTrack(closest)
    local focus = addon.focus
    if not focus then return end
    local ok, cur = pcall(C_SuperTrack.GetSuperTrackedQuestID)
    if ok and cur == closest then
        focus.proximityAutoOwnedQID = closest
        return
    end
    local setOk = pcall(C_SuperTrack.SetSuperTrackedQuestID, closest)
    if not setOk then return end
    local verifyOk, verifyCur = pcall(C_SuperTrack.GetSuperTrackedQuestID)
    if verifyOk and verifyCur == closest then
        focus.proximityAutoOwnedQID = closest
    end
end

--- Drive super-track to the nearest quest when Auto-Focus Closest Quest is enabled.
--- Behaviour: always | respectManual | onlyWhenUnfocused (DB proximityAutoBehaviour).
--- @return nil
local function ApplyProximityAutoSuperTrack()
    if not addon.GetDB("proximityAutoSuperTrack", false) then return end
    if not (C_SuperTrack and C_SuperTrack.SetSuperTrackedQuestID and C_SuperTrack.GetSuperTrackedQuestID) then return end
    local focus = addon.focus
    if not focus then return end
    local closest, closestDist = focus.proximityClosestQID, focus.proximityClosestDistSq

    -- Optionally widen the candidate pool to the whole quest log, so an untracked quest that is
    -- physically closer than everything in the tracker wins the focus. Quests already ranked by
    -- RefreshProximityRank are skipped (they were considered above). A winning untracked quest is
    -- displayed via the aggregator's super-tracked catch-all and self-cleans once something else
    -- becomes closer: losing the super-track drops it from the tracker again.
    if addon.GetDB("proximityAutoIncludeUntracked", false)
        and C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetInfo
        and C_QuestLog.GetDistanceSqToQuest then
        local rank = focus.proximityRank
        for i = 1, C_QuestLog.GetNumQuestLogEntries() do
            local info = C_QuestLog.GetInfo(i)
            local qid = info and not info.isHeader and not info.isHidden and info.questID
            if qid and qid > 0 and not (rank and rank[qid]) then
                -- pcall: GetDistanceSqToQuest can throw on quests with no valid map position.
                local ok, distSq, onContinent = pcall(C_QuestLog.GetDistanceSqToQuest, qid)
                if ok and onContinent and distSq and (not closestDist or distSq < closestDist) then
                    closest, closestDist = qid, distSq
                end
            end
        end
    end

    if not closest or closest <= 0 then return end

    local behaviour = GetProximityAutoBehaviour()
    local ok, cur = pcall(C_SuperTrack.GetSuperTrackedQuestID)
    if not ok then return end
    cur = cur or 0

    if behaviour == "always" then
        focus.proximityManualOverride = false
        SetOwnedSuperTrack(closest)
        return
    end

    if behaviour == "onlyWhenUnfocused" then
        if cur and cur > 0 then return end
        SetOwnedSuperTrack(closest)
        return
    end

    -- respectManual
    if focus.proximityManualOverride then
        if not cur or cur <= 0 then
            focus.proximityManualOverride = false
        elseif cur ~= focus.proximityAutoOwnedQID then
            -- Still holding a non-owned focus (or owned quest abandoned: treat as gone).
            local stillValid = true
            if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
                local idx = C_QuestLog.GetLogIndexForQuestID(cur)
                if not idx then stillValid = false end
            end
            if stillValid then return end
            focus.proximityManualOverride = false
        end
    end

    if cur and cur > 0 and cur ~= closest and cur ~= focus.proximityAutoOwnedQID then
        focus.proximityManualOverride = true
        return
    end

    SetOwnedSuperTrack(closest)
end

--- Toggle Auto-Focus Closest Quest (slash and keybinding share this path).
--- Enabling clears Respect Manual override so automation resumes.
--- @return boolean New enabled state
local function ToggleProximityAutoSuperTrack()
    local newVal = not addon.GetDB("proximityAutoSuperTrack", false)
    addon.SetDB("proximityAutoSuperTrack", newVal)
    if newVal then
        ClearProximityManualOverride()
    end
    local L = addon.L
    local HSPrint = addon.HSPrint or function(msg) print("|cFF00CCFFHorizon Suite - Focus:|r " .. tostring(msg or "")) end
    if L then
        HSPrint(newVal and L["FOCUS_SLASH_AUTOFOCUS_ON"] or L["FOCUS_SLASH_AUTOFOCUS_OFF"])
        if addon.ShowFocusToggleToast then
            -- Gold matches the FOCUSED section accent; muted slate for off.
            if newVal then
                addon.ShowFocusToggleToast(L["FOCUS_AUTOFOCUS_TOAST_ON"], 1.00, 0.92, 0.40)
            else
                addon.ShowFocusToggleToast(L["FOCUS_AUTOFOCUS_TOAST_OFF"], 0.75, 0.78, 0.85)
            end
        end
    end
    -- Keep an open options dashboard in sync: sweep every built control's Refresh so the
    -- Auto-Focus pill and the dependent Include Untracked row update without reopening.
    local dash = _G.HorizonSuiteDashboard
    if dash and dash.IsShown and dash:IsShown() and dash._refreshDashboardDetailOptionFonts then
        dash._refreshDashboardDetailOptionFonts()
    end
    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
    if addon.FullLayout then addon.FullLayout() end
    return newVal
end

-- Category order for questType sort (lower = earlier)
local CATEGORY_SORT_ORDER = {
    CURRENT = 0, COMPLETE = 1, CAMPAIGN = 2, IMPORTANT = 3, LEGENDARY = 4,
    DELVES = 5, SCENARIO = 5, ACHIEVEMENT = 5, APPEARANCE = 5, RECIPE = 5, DUNGEON = 5, RAID = 5, WORLD = 6, WEEKLY = 7, PREY = 7, DAILY = 8, CALLING = 9, RARESCANNER = 10, RARE = 10, RARE_LOOT = 10, DEFAULT = 11,
}

local CURRENT_QUEST_WINDOW_DEFAULT = 60
local CURRENT_QUEST_EXPIRED_GRACE_SEC = 600

-- Returns true if the quest had progress (objectives or accept) within the configured window.
-- Lazily removes expired entries from recentlyProgressedQuests.
-- When expiring, records questID in recentlyExpiredFromCurrent for NEARBY routing.
-- @param questID number
-- @return boolean
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

-- Returns true if the quest recently expired from CURRENT and is within the grace period.
-- Lazily removes expired entries from recentlyExpiredFromCurrent.
-- @param questID number
-- @return boolean
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

-- Returns true if objectives has at least one objective with usable progress (percent or numFulfilled/numRequired).
-- @param objectives table
-- @return boolean
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

-- Deep copy of objectives array for WQ progress cache (preserves text, percent, numFulfilled, numRequired, finished, type).
-- @param objectives table
-- @return table
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
    if mode == "proximity" then
        -- Nearest-first by live distance rank (index 1 = closest). Unranked entries
        -- (no on-continent position) sort after ranked ones; alpha breaks ties.
        local rank = addon.focus and addon.focus.proximityRank
        local ra = (rank and a.questID and rank[a.questID]) or math.huge
        local rb = (rank and b.questID and rank[b.questID]) or math.huge
        if ra ~= rb then return ra < rb end
        return ta < tb
    end
    return ta < tb
end

-- Buckets entries by group key, sorts each group, and returns ordered { key, quests } array.
-- @param quests table Array of normalized entry tables
-- @return table Array of { key = string, quests = table }
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
    local showFocused = addon.GetDB("showFocusedQuestCategory", true) and groups["FOCUSED"]
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

        -- Super-tracked (focused) quest is hoisted into its own FOCUSED section so users
        -- can reorder it independently of its base category. Skips event/world-event quests
        -- which prefer CURRENT_EVENT semantics.
        if showFocused and q.isSuperTracked and q.questID and not q.isEventQuest then
            groups["FOCUSED"][#groups["FOCUSED"] + 1] = q
        -- Event quests never participate in Current Quest / expired-from-Current routing.
        -- In-zone events move between Current Event and Events in Zone based on proximity.
        -- When a scenario is active, suppress BonusObjective (event) quests from CURRENT_EVENT
        -- so only the scenario entry is shown (matches Blizzard: quest + scenario widget).
        elseif q.isEventQuest and q.isAccepted and q.isNearby and groups["CURRENT_EVENT"] then
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
        elseif q.category == "SILVERDRAGON" then
            groups["SILVERDRAGON"][#groups["SILVERDRAGON"] + 1] = q
        elseif q.category == "RARESCANNER" then
            groups["RARESCANNER"][#groups["RARESCANNER"] + 1] = q
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

    -- Proximity mode: rank the shown quests by live distance to the player each pass, so the order
    -- tracks position and re-ranks whenever a refresh runs (zone/sub-zone change, quest updates).
    -- Also run the ranker (for its nearest-quest record) when auto super-track is on, so that toggle
    -- works with any sort mode, not just proximity sort.
    if GetSortMode() == "proximity" or addon.GetDB("proximityAutoSuperTrack", false) then
        RefreshProximityRank(quests)
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

-- Respects filterByZone and test data. Merges Collect* providers and ReadScenarioEntries.
-- @return table Array of normalized entry tables (see entry shape in FocusState.lua)
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
            zoneName = L["FOCUS_ACTIVITY"]
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
    local showWorldQuests = addon.GetDB("focusShowWorldQuests", true)
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
    -- For unaccepted world quests, allow zone/toggle guards to run normally rather than
    -- bypassing them with isTracked=true. Blizzard auto-super-tracks Special Assignments
    -- for every character globally — a fresh character nowhere near the zone should not
    -- see it pinned in FOCUSED just because WoW set the super-track automatically.
    -- Accepted WQs and all non-WQ quests keep isTracked=true (explicit user intent).
    if superTracked and superTracked > 0 and not seen[superTracked] and not scenarioRewardQuestIDs[superTracked] then
        local isWQ = addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(superTracked)
        local isAccepted = addon.IsQuestAccepted and addon.IsQuestAccepted(superTracked)
        local stOpts = (isWQ and not isAccepted)
            and {}                  -- unaccepted WQ: let zone/showWorldQuests guards apply
            or  { isTracked = true } -- accepted WQ or regular quest: always show
        addQuest(superTracked, stOpts)
    end

    -- 7. Scenario entries (already normalized)
    if addon.ReadScenarioEntries then
        for _, se in ipairs(addon.ReadScenarioEntries()) do
            quests[#quests + 1] = se
        end
    end

    -- 8. External providers (e.g. Horizon-RareScanner)
    for _, provider in ipairs(externalProviders) do
        local ok, entries = pcall(provider)
        if ok and entries then
            for _, e in ipairs(entries) do
                quests[#quests + 1] = e
            end
        end
    end

    if addon.testQuestItem then
        table.insert(quests, 1, addon.testQuestItem)
    end

    return quests
end

--- Register an external entry provider for the Focus tracker.
--- The provider is a function() → table of normalized entry tables.
--- Called once per tracker refresh; errors are caught and silently dropped.
--- @param fn function
function addon.RegisterFocusEntryProvider(fn)
    if type(fn) == "function" then
        externalProviders[#externalProviders + 1] = fn
    end
end

--- Register an integration that handles rare/treasure display.
--- isActiveFn() should return true when the integration is loaded and enabled.
--- While any registered provider is active the built-in map scanner is suppressed.
--- @param isActiveFn function
function addon.RegisterRareProvider(isActiveFn)
    if type(isActiveFn) == "function" then
        rareProviders[#rareProviders + 1] = isActiveFn
    end
end

--- Returns true when at least one rare-handling integration is currently active.
--- @return boolean
function addon.HasActiveRareProvider()
    for _, fn in ipairs(rareProviders) do
        if fn() then return true end
    end
    return false
end

--- Format a "seen X ago" string from a GetTime() timestamp.
--- Returns nil when seenAt is nil.
--- @param seenAt number|nil  GetTime() value captured at rare detection
--- @return string|nil
function addon.FormatTimeAgo(seenAt)
    if not seenAt then return nil end
    local elapsed = math.floor(GetTime() - seenAt)
    if elapsed < 60 then
        return "< 1m ago"
    end
    local mins = math.floor(elapsed / 60)
    if mins < 60 then
        return string.format("%dm ago", mins)
    end
    local hours = math.floor(mins / 60)
    local rem   = mins % 60
    if rem == 0 then
        return string.format("%dh ago", hours)
    end
    return string.format("%dh %dm ago", hours, rem)
end

-- ---------------------------------------------------------------------------
-- Shared rare-integration helpers
-- ---------------------------------------------------------------------------

--- Insert a location string into the active chat edit box (Shift+Click on coord line).
--- @param name string  NPC or point-of-interest name
--- @param mapID number  UiMapID
--- @param x number  0-1 coordinate
--- @param y number  0-1 coordinate
function addon.ShareLocationInChat(name, mapID, x, y)
    if not (name and mapID and x and y) then return end
    local mapInfo = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(mapID)
    local zoneName = (mapInfo and mapInfo.name) or ""
    local msg = string.format("[%s] %s - %.1f, %.1f", name, zoneName, x * 100, y * 100)
    local getActive = rawget(_G, "ChatEdit_GetActiveWindow")
    local editBox = getActive and getActive()
    if not editBox or not editBox:IsShown() then
        local dcf = rawget(_G, "DEFAULT_CHAT_FRAME")
        editBox = dcf and dcf.editBox
        local activate = rawget(_G, "ChatEdit_ActivateChat")
        if editBox and activate then activate(editBox) end
    end
    if editBox and editBox.Insert then editBox:Insert(msg) end
end

--- Set a map waypoint for a rare entry, honouring TomTom when enabled.
--- @param entry table  Pool entry with vignetteMapID / vignetteX / vignetteY / title fields
--- @param tomTomDBKey string  DB key for the "use TomTom" preference (e.g. "sd_useTomTom")
function addon.SetRareWaypoint(entry, tomTomDBKey)
    local mapID = entry.vignetteMapID
    local x, y  = entry.vignetteX, entry.vignetteY
    local name  = entry.title or "Rare"
    if not mapID or not x or not y then return end

    if addon.GetDB(tomTomDBKey, false) then
        local TomTom = rawget(_G, "TomTom")
        if TomTom and TomTom.AddWaypoint then
            pcall(TomTom.AddWaypoint, TomTom, mapID, x, y,
                { title = name, persistent = false, minimap = true, world = true, crazy = true })
            return
        end
    end

    if C_Map and C_Map.SetUserWaypoint and UiMapPoint then
        local uiMapPoint = UiMapPoint.CreateFromCoordinates(mapID, x, y)
        if uiMapPoint then
            pcall(C_Map.SetUserWaypoint, uiMapPoint)
            if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, true)
            end
        end
    end
end

--- Create a nav arrow button used by rare-integration InitNavWidgets.
--- @param parent Frame
--- @param atlasName string
--- @param btnW number  Scaled width
--- @param btnH number  Scaled height
--- @param arrowSz number  Scaled arrow texture size
--- @return Button
function addon.CreateNavArrowBtn(parent, atlasName, btnW, btnH, arrowSz)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(btnW, btnH)
    btn:RegisterForClicks("AnyDown")
    btn.arrowTex = btn:CreateTexture(nil, "ARTWORK")
    btn.arrowTex:SetPoint("CENTER")
    btn.arrowTex:SetSize(arrowSz, arrowSz)
    btn.arrowTex:SetAtlas(atlasName)
    btn.arrowTex:SetVertexColor(0.6, 0.6, 0.6)
    btn:SetScript("OnEnter", function(self) self.arrowTex:SetVertexColor(1, 1, 1) end)
    btn:SetScript("OnLeave", function(self) self.arrowTex:SetVertexColor(0.6, 0.6, 0.6) end)
    -- Button frames at a raised frame level block mouse-wheel events from
    -- reaching the entry's OnMouseWheel handler.  Forward explicitly.
    btn:EnableMouseWheel(true)
    btn:SetScript("OnMouseWheel", function(_, delta)
        if addon.HandleScroll then addon.HandleScroll(delta) end
    end)
    btn:Hide()
    return btn
end

addon.ReadTrackedQuests   = ReadTrackedQuests
addon.SortAndGroupQuests  = SortAndGroupQuests
addon.ApplyProximityAutoSuperTrack = ApplyProximityAutoSuperTrack
addon.ToggleProximityAutoSuperTrack = ToggleProximityAutoSuperTrack
addon.ClearProximityManualOverride = ClearProximityManualOverride
addon.MarkProximityManualOverride = MarkProximityManualOverride
addon.GetSortMode         = GetSortMode
