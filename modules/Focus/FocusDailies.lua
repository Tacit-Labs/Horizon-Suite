--[[
    Horizon Suite - Focus - Daily/Weekly Provider
    C_QuestInfoSystem.GetQuestClassification + Enum.QuestFrequency. Zone-based daily/weekly detection.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

--- Returns weeklies and dailies in zone (nearbySet). Each has questID and opts.forceCategory ("WEEKLY" or "DAILY").
-- Blacklist filtering is applied by the aggregator.
-- Uses addon.GetQuestBaseCategory as the single source of truth for classification.
local function CollectDailiesWeeklies(ctx)
    local nearbySet = ctx.nearbySet or {}
    local out = {}

    local ids = {}
    for questID, _ in pairs(nearbySet) do
        if addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID) then
        elseif C_QuestLog.IsQuestCalling and C_QuestLog.IsQuestCalling(questID) then
        else
            local baseCategory = addon.GetQuestBaseCategory and addon.GetQuestBaseCategory(questID)
            if baseCategory == "WEEKLY" then
                ids[#ids + 1] = { questID = questID, opts = { isTracked = false, forceCategory = "WEEKLY" } }
            elseif baseCategory == "DAILY" then
                ids[#ids + 1] = { questID = questID, opts = { isTracked = false, forceCategory = "DAILY" } }
            end
        end
    end
    table.sort(ids, function(a, b) return a.questID < b.questID end)
    for _, e in ipairs(ids) do
        out[#out + 1] = e
    end
    return out
end

addon.CollectDailiesWeeklies = CollectDailiesWeeklies
