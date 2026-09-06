--[[
    Horizon Suite - Focus - Tracked Quests Provider
    C_QuestLog watch list iteration. Returns quests from the quest tracker.
]]

local addon = _G.HorizonSuite

-- Returns quests from the watch list (C_QuestLog.GetNumQuestWatches). Respects filterByZone and showWorldQuests.
local function CollectTrackedQuests(ctx)
    local out = {}
    local numWatches = C_QuestLog.GetNumQuestWatches()
    local nearbySet = ctx.nearbySet or {}
    local playerZone = ctx.playerZone
    local filterByZone = ctx.filterByZone or false
    -- A completed quest is actionable wherever the player is standing, and click-to-complete
    -- quests carry no objectives, so they have no map POI to land them in nearbySet either.
    -- Without this bypass "Only show quests in current zone" hides turn-ins the player can
    -- then never find. Controlled by alwaysShowCompleteQuests (default on).
    local alwaysShowComplete = ctx.alwaysShowComplete
    if alwaysShowComplete == nil then
        alwaysShowComplete = addon.GetDB and addon.GetDB("alwaysShowCompleteQuests", true)
    end

    for i = 1, numWatches do
        local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
        if questID then
            -- When "Filter by current zone" is enabled, we *still* want tracked WORLD quests
            -- to remain visible while you're in the broader zone.
            local isWorld = addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID)
            local zoneNameForFilter = addon.GetQuestZoneName and addon.GetQuestZoneName(questID)
            local zoneMatchesFilter = (not zoneNameForFilter or not playerZone or zoneNameForFilter:lower() == playerZone:lower())
            local isComplete = alwaysShowComplete and C_QuestLog.IsComplete and C_QuestLog.IsComplete(questID) or false
            -- Nearby APIs can miss some tracked quests; allow either zone match or nearby presence.
            local passesZoneFilter = (not filterByZone) or isWorld or isComplete or zoneMatchesFilter or nearbySet[questID]
            if passesZoneFilter then
                -- Watch list is explicit user intent; keep it even if "Show in-zone world quests" is off.
                out[#out + 1] = { questID = questID, opts = {} }  -- isTracked = true by default
            end
        end
    end
    return out
end

addon.CollectTrackedQuests = CollectTrackedQuests
