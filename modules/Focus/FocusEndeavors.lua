--[[
    Horizon Suite - Focus - Endeavor Tracking
    C_NeighborhoodInitiative data provider for tracked Initiative Tasks (Endeavors / Player Housing).
    Mirrors FocusAchievements: when the player tracks an Endeavor in-game, it appears in the tracker.
]]

local addon = _G.HorizonSuite

-- ============================================================================
-- ENDEAVOR DATA PROVIDER
-- ============================================================================

--- Resolve tracked Endeavor IDs from C_NeighborhoodInitiative, C_Endeavors, or C_PlayerHousing.
-- @return table Array of endeavor/task IDs
local function GetTrackedEndeavorIDs()
    local idList = {}

    -- C_NeighborhoodInitiative (primary: Initiative Tasks / Endeavors)
    if C_NeighborhoodInitiative and C_NeighborhoodInitiative.GetTrackedInitiativeTasks then
        local ok, result = pcall(C_NeighborhoodInitiative.GetTrackedInitiativeTasks)
        if ok and result and result.trackedIDs and type(result.trackedIDs) == "table" then
            for _, id in ipairs(result.trackedIDs) do
                if type(id) == "number" and id > 0 then
                    idList[#idList + 1] = id
                end
            end
            if #idList > 0 then return idList end
        end
    end

    -- C_Endeavors.GetTrackedIDs (fallback for future API changes)
    if C_Endeavors and C_Endeavors.GetTrackedIDs then
        local ok, ids = pcall(C_Endeavors.GetTrackedIDs)
        if ok and ids and type(ids) == "table" then
            for _, id in ipairs(ids) do
                if type(id) == "number" and id > 0 then
                    idList[#idList + 1] = id
                end
            end
            if #idList > 0 then return idList end
        end
    end

    -- C_PlayerHousing: active Endeavor (fallback)
    if C_PlayerHousing then
        for _, fn in ipairs({ "GetActiveEndeavorID", "GetActiveEndeavor" }) do
            if C_PlayerHousing[fn] then
                local ok, id = pcall(C_PlayerHousing[fn])
                if ok and id and type(id) == "number" and id > 0 then
                    idList[#idList + 1] = id
                    return idList
                end
                break
            end
        end
    end

    return idList
end

--- Request initiative task info from the server (if API exists). May prime the cache for GetInitiativeTaskInfo.
-- @param endeavorID number
local function RequestEndeavorTaskInfo(endeavorID)
    if C_NeighborhoodInitiative and C_NeighborhoodInitiative.RequestInitiativeTaskInfo then
        pcall(C_NeighborhoodInitiative.RequestInitiativeTaskInfo, endeavorID)
    end
end

addon.GetTrackedEndeavorIDs = GetTrackedEndeavorIDs
addon.RequestEndeavorTaskInfo = RequestEndeavorTaskInfo

--- Get endeavor display info. Tries C_NeighborhoodInitiative, C_Endeavors, C_PlayerHousing, or fallbacks.
-- @param endeavorID number
-- @return string name, number|string icon, table objectives, boolean isComplete
local function GetEndeavorDisplayInfo(endeavorID)
    -- C_NeighborhoodInitiative.GetInitiativeTaskInfo (primary)
    if C_NeighborhoodInitiative and C_NeighborhoodInitiative.GetInitiativeTaskInfo then
        local ok, taskInfo = pcall(C_NeighborhoodInitiative.GetInitiativeTaskInfo, endeavorID)
        if ok and taskInfo and type(taskInfo) == "table" then
            local name = taskInfo.taskName
            if (not name or name == "") and C_NeighborhoodInitiative.GetInitiativeTaskChatLink then
                local linkOk, link = pcall(C_NeighborhoodInitiative.GetInitiativeTaskChatLink, endeavorID)
                if linkOk and link and type(link) == "string" then
                    local parsed = link:match("|h%[(.-)%]|h")
                    if parsed and parsed ~= "" then name = parsed end
                end
            end
            name = name or ("Endeavor " .. tostring(endeavorID))
            local icon = taskInfo.icon or taskInfo.texture
            local isComplete = (taskInfo.completed == true)
            local objectives = {}
            if taskInfo.requirementsList and type(taskInfo.requirementsList) == "table" then
                for _, req in ipairs(taskInfo.requirementsList) do
                    local text = (type(req) == "table" and req.requirementText) or tostring(req)
                    if text and text ~= "" then
                        objectives[#objectives + 1] = {
                            text = text,
                            finished = (type(req) == "table" and req.completed == true) or false,
                            percent = nil,
                        }
                    end
                end
            end
            return name, icon, objectives, isComplete
        end
    end

    -- Chat link fallback when GetInitiativeTaskInfo returns nil (data not yet loaded)
    if C_NeighborhoodInitiative and C_NeighborhoodInitiative.GetInitiativeTaskChatLink then
        local linkOk, link = pcall(C_NeighborhoodInitiative.GetInitiativeTaskChatLink, endeavorID)
        if linkOk and link and type(link) == "string" then
            local parsed = link:match("|h%[(.-)%]|h")
            if parsed and parsed ~= "" then
                return parsed, nil, {}, false
            end
        end
    end

    -- C_Endeavors.GetEndeavorInfo (fallback)
    if C_Endeavors and C_Endeavors.GetEndeavorInfo then
        local ok, info = pcall(C_Endeavors.GetEndeavorInfo, endeavorID)
        if ok and info and type(info) == "table" then
            local name = info.name or info.title or ("Endeavor " .. tostring(endeavorID))
            local icon = info.icon or info.texture
            local isComplete = (info.isComplete == true) or (info.completed == true) or (info.complete == true)
            local objectives = {}
            if info.objectives and type(info.objectives) == "table" then
                for _, obj in ipairs(info.objectives) do
                    local text = (type(obj) == "table" and (obj.text or obj.description or obj.label)) or tostring(obj)
                    if text and text ~= "" then
                        objectives[#objectives + 1] = {
                            text = text,
                            finished = (type(obj) == "table" and (obj.finished or obj.completed or obj.done)) or false,
                            percent = (type(obj) == "table" and obj.percent) or nil,
                        }
                    end
                end
            elseif info.description and info.description ~= "" then
                objectives[#objectives + 1] = { text = info.description, finished = isComplete, percent = nil }
            end
            return name, icon, objectives, isComplete
        end
    end

    -- C_Endeavors.GetInfo
    if C_Endeavors and C_Endeavors.GetInfo then
        local ok, name, icon, description, isComplete = pcall(C_Endeavors.GetInfo, endeavorID)
        if ok and name then
            local objectives = {}
            if description and description ~= "" then
                objectives[#objectives + 1] = { text = description, finished = isComplete, percent = nil }
            end
            return name or ("Endeavor " .. tostring(endeavorID)), icon, objectives, isComplete or false
        end
    end

    -- C_PlayerHousing (if Endeavors live there)
    if C_PlayerHousing and C_PlayerHousing.GetEndeavorInfo then
        local ok, info = pcall(C_PlayerHousing.GetEndeavorInfo, endeavorID)
        if ok and info and type(info) == "table" then
            local name = info.name or info.title or ("Endeavor " .. tostring(endeavorID))
            local icon = info.icon or info.texture
            local isComplete = (info.isComplete == true) or (info.completed == true)
            local objectives = {}
            if info.objectives and type(info.objectives) == "table" then
                for _, obj in ipairs(info.objectives) do
                    local text = (type(obj) == "table" and (obj.text or obj.description)) or tostring(obj)
                    if text and text ~= "" then
                        objectives[#objectives + 1] = { text = text, finished = false, percent = nil }
                    end
                end
            end
            return name, icon, objectives, isComplete
        end
    end

    return "Endeavor " .. tostring(endeavorID), nil, {}, false
end

--- Build tracker rows from WoW tracked Endeavors.
-- @return table Array of normalized entry tables for the tracker
local function ReadTrackedEndeavors()
    local out = {}
    if not addon.GetDB("showEndeavors", true) then return out end

    local idList = GetTrackedEndeavorIDs()
    if #idList == 0 then return out end

    local endeavorColor = (addon.GetQuestColor and addon.GetQuestColor("ENDEAVOR")) or (addon.QUEST_COLORS and addon.QUEST_COLORS.ENDEAVOR) or { 0.45, 0.95, 0.75 }

    for _, endeavorID in ipairs(idList) do
        if type(endeavorID) == "number" and endeavorID > 0 then
            local name, _, objectives, isComplete = GetEndeavorDisplayInfo(endeavorID)
            if isComplete and not (addon.GetDB and addon.GetDB("showCompletedEndeavors", false)) then
                -- Skip completed Endeavors unless user opted in (mirror achievements)
            else
                out[#out + 1] = {
                    entryKey       = "endeavor:" .. tostring(endeavorID),
                    endeavorID     = endeavorID,
                    questID        = nil,
                    title          = name or ("Endeavor " .. tostring(endeavorID)),
                    objectives     = objectives or {},
                    color          = endeavorColor,
                    category       = "ENDEAVOR",
                    isComplete     = isComplete,
                    isSuperTracked = false,
                    isNearby       = false,
                    zoneName       = nil,
                    itemLink       = nil,
                    itemTexture    = nil,
                    isEndeavor     = true,
                    isTracked      = true,
                }
            end
        end
    end

    return out
end

addon.ReadTrackedEndeavors = ReadTrackedEndeavors
