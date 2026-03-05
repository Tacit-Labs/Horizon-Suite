--[[
    Horizon Suite - Focus - Quest Categories
    Shared classification utilities: IsQuestWorldQuest, GetQuestFrequency, GetQuestCategory,
    GetQuestBaseCategory, GetQuestTypeAtlas, GetQuestZoneName. Used by multiple providers.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- Single source of truth: QuestUtils_IsQuestWorldQuest (Blizzard) or C_QuestLog.IsWorldQuest.
local function IsQuestWorldQuest(questID)
    if not questID or questID <= 0 then return false end
    if _G.QuestUtils_IsQuestWorldQuest and _G.QuestUtils_IsQuestWorldQuest(questID) then return true end
    if C_QuestLog and C_QuestLog.IsWorldQuest and C_QuestLog.IsWorldQuest(questID) then return true end
    return false
end

-- Frequency from quest log (Daily/Weekly). Returns nil if quest not in log or API unavailable.
local function GetQuestFrequency(questID)
    if not questID or not C_QuestLog or not C_QuestLog.GetLogIndexForQuestID then return nil end
    local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
    if not logIndex then return nil end
    if C_QuestLog.GetInfo then
        local ok, info = pcall(C_QuestLog.GetInfo, logIndex)
        if ok and info and info.frequency ~= nil then return info.frequency end
    end
    return nil
end

-- Single source of truth: C_QuestInfoSystem.GetQuestClassification + frequency + IsQuestWorldQuest.
-- Order: COMPLETE (state) -> WORLD (WQ) -> Classification (Calling, Campaign, Recurring, Important, Legendary) -> Frequency (Weekly) -> DEFAULT.
-- Meta and Questline are ignored and fall through to frequency/DEFAULT.
local function GetQuestBaseCategory(questID)
    if not questID or questID <= 0 then return "DEFAULT" end
    if IsQuestWorldQuest(questID) then
        return "WORLD"
    end
    if C_QuestLog.GetQuestTagInfo then
        local ok, tagInfo = pcall(C_QuestLog.GetQuestTagInfo, questID)
        if ok and tagInfo then
            if tagInfo.tagID == 62 then return "RAID" end
            if tagInfo.tagID == 81 then return "DUNGEON" end
        end
    end
    -- Classification (single source): Normal, Important, Legendary, Campaign, Calling, Meta, Recurring, Questline.
    if C_QuestInfoSystem and C_QuestInfoSystem.GetQuestClassification then
        local qc = C_QuestInfoSystem.GetQuestClassification(questID)
        if qc == Enum.QuestClassification.Calling then return "CALLING" end
        if qc == Enum.QuestClassification.Campaign then return "CAMPAIGN" end
        if qc == Enum.QuestClassification.Recurring then return "WEEKLY" end
        if qc == Enum.QuestClassification.Important then return "IMPORTANT" end
        if qc == Enum.QuestClassification.Legendary then return "LEGENDARY" end
        -- Meta, Questline, Normal: fall through to frequency then DEFAULT
    end
    -- Frequency (when in log): Weekly -> WEEKLY; Daily -> DAILY.
    local freq = GetQuestFrequency(questID)
    if freq ~= nil then
        if Enum.QuestFrequency and Enum.QuestFrequency.Weekly and freq == Enum.QuestFrequency.Weekly then
            return "WEEKLY"
        end
        if freq == 2 or (LE_QUEST_FREQUENCY_WEEKLY and freq == LE_QUEST_FREQUENCY_WEEKLY) then
            return "WEEKLY"
        end
        if Enum.QuestFrequency and Enum.QuestFrequency.Daily and freq == Enum.QuestFrequency.Daily then
            return "DAILY"
        end
        if freq == 1 or (LE_QUEST_FREQUENCY_DAILY and freq == LE_QUEST_FREQUENCY_DAILY) then
            return "DAILY"
        end
    end
    return "DEFAULT"
end

local function GetQuestCategory(questID)
    if not questID or questID <= 0 then return "DEFAULT" end
    if C_QuestLog and C_QuestLog.IsComplete and C_QuestLog.IsComplete(questID) then
        -- When the toggle is on, keep Campaign / Important quests in their
        -- original category even when they are ready to turn in.
        local base = GetQuestBaseCategory(questID)
        if base == "CAMPAIGN" and addon.GetDB and addon.GetDB("keepCampaignInCategory", false) then
            return "CAMPAIGN"
        end
        if base == "IMPORTANT" and addon.GetDB and addon.GetDB("keepImportantInCategory", false) then
            return "IMPORTANT"
        end
        return "COMPLETE"
    end
    return GetQuestBaseCategory(questID)
end

local function GetQuestTypeAtlas(questID, category)
    if not questID or questID <= 0 then return nil end
    if C_QuestLog.ReadyForTurnIn and C_QuestLog.ReadyForTurnIn(questID) then
        return "QuestTurnin"
    end
    if C_QuestInfoSystem and C_QuestInfoSystem.GetQuestClassification then
        local qc = C_QuestInfoSystem.GetQuestClassification(questID)
        if qc then
            local atlas = (qc == Enum.QuestClassification.Important and "importantavailablequesticon")
                or (qc == Enum.QuestClassification.Campaign and "Quest-Campaign-Available")
                or (qc == Enum.QuestClassification.Legendary and "UI-QuestPoiLegendary-QuestBang")
                or (qc == Enum.QuestClassification.Calling and "Quest-DailyCampaign-Available")
                or (qc == Enum.QuestClassification.Recurring and "quest-recurring-available")
                or (qc == Enum.QuestClassification.Meta and "quest-wrapper-available")
            if atlas then return atlas end
        end
    end
    if category == "COMPLETE" then return "QuestTurnin" end
    if category == "IMPORTANT" then return "importantavailablequesticon" end
    if category == "CAMPAIGN" then return "Quest-Campaign-Available" end
    if category == "LEGENDARY" then return "UI-QuestPoiLegendary-QuestBang" end
    if category == "CALLING" then return "Quest-DailyCampaign-Available" end
    if category == "WORLD" then return "quest-recurring-available" end
    if category == "WEEKLY" then return "quest-recurring-available" end
    if category == "DAILY" then return "quest-recurring-available" end
    if category == "DUNGEON" then return "questlog-questtypeicon-dungeon" end
    if category == "RAID" then return "questlog-questtypeicon-raid" end
    if C_QuestLog.GetQuestTagInfo then
        local tagInfo = C_QuestLog.GetQuestTagInfo(questID)
        if tagInfo and tagInfo.tagID then
            local tagAtlas = (tagInfo.tagID == 41 and "questlog-questtypeicon-pvp")
                or (tagInfo.tagID == 81 and "questlog-questtypeicon-dungeon")
                or (tagInfo.tagID == 62 and "questlog-questtypeicon-raid")
                or (tagInfo.tagID == 1 and "questlog-questtypeicon-group")
            if tagAtlas then return tagAtlas end
        end
    end
    return "QuestNormal"
end

local function GetQuestZoneName(questID)
    local isWorldQuest = IsQuestWorldQuest(questID)

    -- Helper: normalize any mapID to its zone-level (mapType==3) parent for stable zone labeling.
    local function NormalizeToZoneMapName(mapID)
        if not mapID or not C_Map or not C_Map.GetMapInfo then return nil end
        local info = C_Map.GetMapInfo(mapID)
        local depth = 0
        while info and info.mapType ~= 3 and info.parentMapID and info.parentMapID ~= 0 and depth < 10 do
            mapID = info.parentMapID
            info = C_Map.GetMapInfo(mapID)
            depth = depth + 1
        end
        return info and info.name or nil
    end

     -- For world quests: prefer task-quest APIs (uiMapID). C_TaskQuest.GetQuestInfoByQuestID can return nil
     -- when quest data isn't cached (e.g. tracked WQ from another zone).
     if isWorldQuest and C_TaskQuest and C_TaskQuest.GetQuestInfoByQuestID then
         local info = C_TaskQuest.GetQuestInfoByQuestID(questID)
         local mapID = info and (info.mapID or info.uiMapID)
         local name = NormalizeToZoneMapName(mapID)
         if name then return name end
     end
     -- Waypoint: for world quests when C_TaskQuest fails, waypoint gives quest location. For regular quests,
     -- waypoint often returns player's current map, so we prefer quest log header first.
     if isWorldQuest and C_QuestLog.GetNextWaypoint then
         local mapID = C_QuestLog.GetNextWaypoint(questID)
         local name = NormalizeToZoneMapName(mapID)
         if name then return name end
     end

     -- For non-world quests: prefer quest log header (waypoint often = current zone).
     if C_QuestLog.GetLogIndexForQuestID then
         local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
         if logIndex then
             for i = logIndex - 1, 1, -1 do
                 local info = C_QuestLog.GetInfo(i)
                 if info and info.isHeader then
                     return info.title
                 end
             end
         end
     end
     if C_QuestLog.GetNextWaypoint then
         local mapID = C_QuestLog.GetNextWaypoint(questID)
         local name = NormalizeToZoneMapName(mapID)
         if name then return name end
     end
     return nil
 end
--- button is useful.  This includes explicit Group quests, World Bosses,
--- Elite World Quests, and Raid quests.
--- @param questID number
--- @return boolean
local function IsGroupQuest(questID)
    if not questID or questID <= 0 then return false end

    -- tagID values that indicate group-oriented content:
    --   1   = Group
    --   111 = Elite World Quest (dragon-framed, group recommended)
    --   289 = World Boss
    local GROUP_TAG_IDS = { [1] = true, [111] = true, [289] = true }

    -- worldQuestType values that indicate group content:
    --   1  = Enum.QuestTagType.Group
    --   18 = Threat / World Boss
    local GROUP_WQ_TYPES = { [1] = true, [18] = true }

    -- 1) C_QuestLog.GetQuestTagInfo — works for quests in the log AND world quests.
    if C_QuestLog and C_QuestLog.GetQuestTagInfo then
        local ok, tagInfo = pcall(C_QuestLog.GetQuestTagInfo, questID)
        if ok and tagInfo then
            if tagInfo.tagID and GROUP_TAG_IDS[tagInfo.tagID] then return true end
            if tagInfo.worldQuestType and GROUP_WQ_TYPES[tagInfo.worldQuestType] then return true end
        end
    end

    -- 2) C_TaskQuest.GetQuestInfoByQuestID — for world/task quests not in the log.
    --    NOTE: In modern WoW this may return a string (quest name) instead of a table.
    if C_TaskQuest and C_TaskQuest.GetQuestInfoByQuestID then
        local ok, info = pcall(C_TaskQuest.GetQuestInfoByQuestID, questID)
        if ok and info and type(info) == "table" then
            if info.tagID and GROUP_TAG_IDS[info.tagID] then return true end
            if info.worldQuestType and GROUP_WQ_TYPES[info.worldQuestType] then return true end
        end
    end

    -- 3) GetQuestTagInfo global (legacy, pre-C_QuestLog wrapper).
    if _G.GetQuestTagInfo and type(_G.GetQuestTagInfo) == "function" then
        local ok, tagID = pcall(_G.GetQuestTagInfo, questID)
        if ok and tagID and GROUP_TAG_IDS[tagID] then return true end
    end

    -- 4) suggestedGroup from quest log info (>1 means group content).
    --    Only works for quests that are in the player's quest log.
    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
        local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
        if logIndex and C_QuestLog.GetInfo then
            local ok, info = pcall(C_QuestLog.GetInfo, logIndex)
            if ok and info and info.suggestedGroup and info.suggestedGroup > 1 then return true end
        end
    end

    return false
end

addon.IsQuestWorldQuest    = IsQuestWorldQuest
addon.GetQuestFrequency   = GetQuestFrequency
addon.GetQuestCategory     = GetQuestCategory
addon.GetQuestBaseCategory = GetQuestBaseCategory
addon.GetQuestTypeAtlas    = GetQuestTypeAtlas
addon.GetQuestZoneName     = GetQuestZoneName
addon.IsGroupQuest         = IsGroupQuest
