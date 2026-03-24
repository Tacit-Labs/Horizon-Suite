--[[
    Horizon Suite - Focus - Scenario Default Provider
    Standard logic for generic scenarios and dungeons.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

local DefaultProvider = setmetatable({}, addon.FocusScenarioBaseProvider)
DefaultProvider.__index = DefaultProvider

function DefaultProvider:New()
    return setmetatable({}, self)
end

function DefaultProvider:GetDisplayInfo()
    local isDelve = addon.IsDelveActive and addon.IsDelveActive()
    local inPartyDungeon = addon.IsInPartyDungeon and addon.IsInPartyDungeon()
    local category = isDelve and "DELVES" or (inPartyDungeon and "DUNGEON") or "SCENARIO"

    local scenarioName
    local ok, name = pcall(C_Scenario.GetInfo)
    if ok and name and name ~= "" then scenarioName = name end

    local stageName
    local sOk, sName = pcall(C_Scenario.GetStepInfo)
    if sOk and sName and sName ~= "" then stageName = sName end

    local title = scenarioName
    if inPartyDungeon then
        local instanceName = GetInstanceInfo()
        title = instanceName or "Dungeon"
    elseif not title or title == "" then
        title = "Scenario"
    end

    return title, stageName or "", category
end

function DefaultProvider:ReadEntries()
    local out = {}
    if not addon.GetDB("showScenarioEvents", true) then return out end
    
    local inPartyDungeon = addon.IsInPartyDungeon and addon.IsInPartyDungeon()
    if inPartyDungeon and addon.mplusBlock and addon.mplusBlock:IsShown() then
        return out
    end

    local isDelve = addon.IsDelveActive and addon.IsDelveActive()
    local category = isDelve and "DELVES" or (inPartyDungeon and "DUNGEON") or "SCENARIO"
    local color = addon.GetQuestColor and addon.GetQuestColor(category) or { 0.38, 0.52, 0.88 }

    -- 1. Main Step
    local ok, stageName, _, numCriteria, _, _, _, _, _, _, rewardQuestID, widgetSetID = pcall(C_Scenario.GetStepInfo)
    local scenarioName, stageIndex
    local gOk, gName, currentStage = pcall(C_Scenario.GetInfo)
    if gOk and gName and gName ~= "" then scenarioName = gName end
    if gOk and currentStage and type(currentStage) == "number" and currentStage > 0 then stageIndex = currentStage end
    if ok and stageName and stageName ~= "" then
        local objectives = {}
        local timerDuration, timerStartTime = nil, nil

        -- Main Criteria
        for i = 1, (numCriteria or 0) + 3 do
            local cOk, critInfo = pcall(C_ScenarioInfo.GetCriteriaInfo, i)
            if not cOk or not critInfo then
                cOk, critInfo = pcall(C_ScenarioInfo.GetCriteriaInfoByStep, 1, i)
            end
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

        -- Main Timer Fallbacks
        if not timerDuration then
            timerDuration, timerStartTime = self:GetTimerInfo(nil, rewardQuestID, widgetSetID)
        end

        -- Widget Objective Fallback
        for _, wObj in ipairs(self:ParseWidgetObjectives(widgetSetID)) do
            table.insert(objectives, wObj)
        end

        -- Global Widget Objective Fallback
        local otSet = C_UIWidgetManager.GetObjectiveTrackerWidgetSetID()
        if otSet and otSet ~= 0 and otSet ~= widgetSetID then
            for _, gObj in ipairs(self:ParseWidgetObjectives(otSet)) do
                table.insert(objectives, gObj)
            end
        end

        objectives = self:DeduplicateObjectives(objectives)

        -- Only create entry when it has real content; prevents empty entries from
        -- prematurely suppressing bonus objective quests (Abundance race condition).
        if #objectives > 0 or timerDuration then
            local title = (scenarioName and scenarioName ~= "") and scenarioName or stageName
            table.insert(out, {
                entryKey = "scenario-main",
                title = title,
                stageName = (stageName and stageName ~= "") and stageName or nil,
                stageIndex = stageIndex,
                category = category,
                color = color,
                objectives = objectives,
                timerDuration = timerDuration,
                timerStartTime = timerStartTime,
                isScenarioMain = true,
                rewardQuestID = rewardQuestID,
            })
        end
    end

    -- 2. Bonus Steps
    local bOk, bonusSteps = pcall(C_Scenario.GetBonusSteps)
    if bOk and bonusSteps then
        for _, stepID in ipairs(bonusSteps) do
            local sOk, title, _, nCrit, _, _, _, _, _, _, bonusRewardID, bWidgetID = pcall(C_Scenario.GetStepInfo, stepID)
            if sOk and title and title ~= "" then
                local bObjectives = {}
                local bTimeDur, bTimeStart = nil, nil

                for ci = 1, (nCrit or 10) + 3 do
                    local cOk, crit = pcall(C_ScenarioInfo.GetCriteriaInfoByStep, stepID, ci)
                    if cOk and crit then
                        local bObj = self:BuildObjectiveFromCriteria(crit)
                        if bObj then
                            table.insert(bObjectives, bObj)
                            if bObj.timerDuration and not bTimeDur then
                                bTimeDur, bTimeStart = bObj.timerDuration, bObj.timerStartTime
                            end
                        end
                    end
                end
                
                if not bTimeDur then
                    bTimeDur, bTimeStart = self:GetTimerInfo(nil, bonusRewardID, bWidgetID)
                end

                bObjectives = self:DeduplicateObjectives(bObjectives)

                table.insert(out, {
                    entryKey = "scenario-bonus-" .. stepID,
                    title = title,
                    category = category,
                    color = color,
                    objectives = bObjectives,
                    timerDuration = bTimeDur,
                    timerStartTime = bTimeStart,
                    isScenarioBonus = true,
                    rewardQuestID = bonusRewardID,
                })
            end
        end
    end

    return out
end

addon.FocusScenarioDefaultProvider = DefaultProvider
addon.FocusScenarioRegistry:Register("DEFAULT", DefaultProvider:New())
