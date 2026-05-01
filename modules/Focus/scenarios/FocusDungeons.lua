--[[
    Horizon Suite - Focus - Dungeon Provider
    Instance detection (GetInstanceInfo) and dungeon quest collection. Isolated API boundary.
]]

local addon = _G.HorizonSuite

local function IsInMythicDungeon()
    local ok, name, instanceType, difficultyID = pcall(GetInstanceInfo)
    return ok and instanceType == "party" and (difficultyID == 8 or difficultyID == 23)
end

local function GetMythicDungeonName()
    local ok, name = pcall(GetInstanceInfo)
    return ok and name or nil
end

--- Returns nearby non-WQ, non-Calling quests when in a party dungeon.
--- Only shows quests the player has actually accepted in their quest log,
--- filtering out hidden / deprecated / auto-tracked noise regardless of
--- dungeon difficulty.
local function CollectDungeonQuests(ctx)
    if not addon.IsInPartyDungeon() then return {} end
    -- When the M+ block is active, hide the DUNGEON category entirely
    -- (the block already shows bosses, forces, timer, etc.).
    if addon.mplusBlock and addon.mplusBlock:IsShown() then return {} end
    local out = {}
    local nearbySet = ctx.nearbySet or {}
    local seen = ctx.seen or {}
    for questID, _ in pairs(nearbySet) do
        if not seen[questID] and not addon.IsQuestWorldQuest(questID) then
            if not (C_QuestLog.IsQuestCalling and C_QuestLog.IsQuestCalling(questID)) then
                -- Only show quests the player actually has in their log
                local logIdx = C_QuestLog.GetLogIndexForQuestID(questID)
                if logIdx then
                    -- Skip hidden quests (internal tracking quests)
                    local info = C_QuestLog.GetInfo and C_QuestLog.GetInfo(logIdx)
                    if info and not info.isHidden then
                        out[#out + 1] = { questID = questID, opts = { isDungeonQuest = true, isTracked = false, forceCategory = "DUNGEON" } }
                    end
                end
            end
        end
    end
    return out
end

addon.IsInMythicDungeon    = IsInMythicDungeon
addon.GetMythicDungeonName = GetMythicDungeonName
addon.CollectDungeonQuests = CollectDungeonQuests
