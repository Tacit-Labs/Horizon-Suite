--[[
    Horizon Suite - Focus - Scenario World Provider
    Specialized logic for World Scenarios (Singularity, etc.).
]]

local addon = _G.HorizonSuite

local WorldProvider = setmetatable({}, addon.FocusScenarioBaseProvider)
WorldProvider.__index = WorldProvider

function WorldProvider:New()
    return setmetatable({}, self)
end

function WorldProvider:GetDisplayInfo()
    local ok, name = pcall(C_Scenario.GetInfo)
    local _, stageName = C_Scenario.GetStepInfo()
    return name or "World Scenario", stageName or "", "SCENARIO"
end

function WorldProvider:ReadEntries()
    local out = {}
    if not addon.GetDB("showScenarioEvents", true) then return out end

    local function HasRitualSiteObjective(objectives)
        if not objectives then return false end
        for _, obj in ipairs(objectives) do
            local text = obj and obj.text
            local lower = type(text) == "string" and text:lower() or ""
            if lower:find("ritual", 1, true)
                or lower:find("spoil", 1, true)
                or lower:find("loot", 1, true)
                or lower:find("death", 1, true) then
                return true
            end
        end
        return false
    end

    local ok, stageName, _, numCriteria, _, _, _, _, _, _, _, rewardQuestID, widgetSetIDFromStep = pcall(C_Scenario.GetStepInfo)
    -- Prefer C_ScenarioInfo.GetScenarioStepInfo().widgetSetID (verified for Singularity)
    local widgetSetID = nil
    if C_ScenarioInfo and C_ScenarioInfo.GetScenarioStepInfo then
        local stepInfo = C_ScenarioInfo.GetScenarioStepInfo()
        widgetSetID = stepInfo and stepInfo.widgetSetID
    end
    widgetSetID = (widgetSetID and widgetSetID > 0) and widgetSetID or widgetSetIDFromStep

    -- 1. Header widgets. Ritual Sites use ScenarioHeaderCurrenciesAndBackground
    -- for spoils/deaths, and Blizzard displays these above criteria.
    local objectives = {}
    local timerDuration, timerStartTime = nil, nil
    local wObjs = self:ParseWidgetObjectives(widgetSetID)
    for _, wObj in ipairs(wObjs) do table.insert(objectives, wObj) end

    -- 2. Criteria (Standard criteria)
    if ok and numCriteria and numCriteria > 0 then
        for i = 1, numCriteria + 3 do
            local cOk, critInfo = pcall(C_ScenarioInfo.GetCriteriaInfo, i)
            if cOk and critInfo then
                local obj = self:BuildObjectiveFromCriteria(critInfo)
                if obj then
                    table.insert(objectives, obj)
                    if obj.timerDuration and not timerDuration then
                        timerDuration, timerStartTime = obj.timerDuration, obj.timerStartTime
                    end
                end
            end
        end
    end

    -- 3. Global Widgets (Always check objective tracker set)
    local objSetID = C_UIWidgetManager.GetObjectiveTrackerWidgetSetID()
    if objSetID and objSetID ~= 0 and objSetID ~= widgetSetID then
        local gObjs = self:ParseWidgetObjectives(objSetID)
        for _, gObj in ipairs(gObjs) do table.insert(objectives, gObj) end
    end

    objectives = self:DeduplicateObjectives(objectives)
    local scenarioHeaderCurrencies = self:GetScenarioHeaderCurrenciesForTitle(objectives)

    -- 4. Timer (widget:step only for Singularity-style scenarios)
    if not timerDuration then
        timerDuration, timerStartTime = self:GetWidgetStepTimer(widgetSetID)
    end
    
    if #objectives > 0 or timerDuration then
        local scenarioName
        local stageIndex
        local iOk, name, currentStage = pcall(C_Scenario.GetInfo)
        if iOk and name and name ~= "" then scenarioName = name end
        if iOk and currentStage and type(currentStage) == "number" and currentStage > 0 then stageIndex = currentStage end

        local title
        if scenarioName and (stageName and stageName ~= "") then
            title = scenarioName
        elseif stageName and stageName ~= "" then
            title = stageName
        elseif scenarioName then
            title = scenarioName
        elseif HasRitualSiteObjective(objectives) then
            title = "Ritual Sites"
        else
            title = "Objectives"
        end

        table.insert(out, {
            entryKey = "scenario-world",
            title = title,
            stageName = (stageName and stageName ~= "") and stageName or nil,
            stageIndex = stageIndex,
            category = "SCENARIO",
            color = addon.GetQuestColor and addon.GetQuestColor("SCENARIO") or { 0.38, 0.52, 0.88 },
            objectives = objectives,
            scenarioHeaderCurrencies = scenarioHeaderCurrencies,
            timerDuration = timerDuration,
            timerStartTime = timerStartTime,
            isScenarioMain = true,
            rewardQuestID = rewardQuestID,
        })
    end

    return out
end

addon.FocusScenarioRegistry:Register("WORLD", WorldProvider:New())
