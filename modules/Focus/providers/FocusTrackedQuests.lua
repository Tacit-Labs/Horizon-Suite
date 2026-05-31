--[[
    Horizon Suite - Focus - Tracked Quests Provider
    C_QuestLog watch list iteration. Returns quests from the quest tracker.
]]

local addon = _G.HorizonSuite

--- Returns quests from the watch list (C_QuestLog.GetNumQuestWatches). Respects filterByZone and showWorldQuests.
local function CollectTrackedQuests(ctx)
    local out = {}
    local numWatches = C_QuestLog.GetNumQuestWatches()
    local nearbySet = ctx.nearbySet or {}
    local playerZone = ctx.playerZone
    local filterByZone = ctx.filterByZone or false

    for i = 1, numWatches do
        local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
        if questID then
            -- When "Filter by current zone" is enabled, we *still* want tracked WORLD quests
            -- to remain visible while you're in the broader zone.
            local isWorld = addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID)
            local zoneNameForFilter = addon.GetQuestZoneName and addon.GetQuestZoneName(questID)
            local zoneMatchesFilter = (not zoneNameForFilter or not playerZone or zoneNameForFilter:lower() == playerZone:lower())
            -- Nearby APIs can miss some tracked quests; allow either zone match or nearby presence.
            local passesZoneFilter = (not filterByZone) or isWorld or zoneMatchesFilter or nearbySet[questID]
            if passesZoneFilter then
                -- Watch list is explicit user intent; keep it even if "Show in-zone world quests" is off.
                out[#out + 1] = { questID = questID, opts = {} }  -- isTracked = true by default
            end
        end
    end
    return out
end

addon.CollectTrackedQuests = CollectTrackedQuests
