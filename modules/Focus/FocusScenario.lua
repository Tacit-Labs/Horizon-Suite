--[[
    Horizon Suite - Focus - Scenario Events
    C_Scenario / C_ScenarioInfo / C_UIWidgetManager data provider for main and bonus steps.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

local function ScenarioDebug(fmt, ...)
    if addon.GetDB and addon.GetDB("scenarioDebug", false) and addon.HSPrint then
        addon.HSPrint("[Scenario] " .. (fmt and string.format(fmt, ...) or ""))
    end
end

-- ============================================================================
-- SCENARIO DATA PROVIDER
-- ============================================================================

--- Extract timerDuration and timerStartTime from criteria. startTime = GetTime() - elapsed.
-- @return duration, startTime or nil, nil
local function GetCriteriaTimerInfo(criteriaInfo)
    if not criteriaInfo then return nil, nil end
    local duration = criteriaInfo.duration
    if not duration or duration <= 0 then return nil, nil end
    local elapsed = criteriaInfo.elapsed
    if elapsed == nil or type(elapsed) ~= "number" then return nil, nil end
    if elapsed >= duration then return nil, nil end -- skip expired (KT-aligned)
    local elapsedSeconds = math.max(0, math.min(elapsed, duration))
    local startTime = GetTime() - elapsedSeconds
    return duration, startTime
end

--- Get timerDuration, timerStartTime from quest APIs. For TaskQuest (mins only): duration = mins*60, startTime = GetTime().
local function GetQuestTimerInfo(questID)
    if not questID or type(questID) ~= "number" or questID <= 0 then return nil, nil end

    -- C_QuestLog.GetTimeAllowed: timeTotal, timeElapsed -> startTime = GetTime() - timeElapsed
    if C_QuestLog and C_QuestLog.GetTimeAllowed then
        local ok, total, elapsed = pcall(C_QuestLog.GetTimeAllowed, questID)
        if ok and total and elapsed and total > 0 and elapsed >= 0 then
            local elapsedCapped = math.min(elapsed, total)
            local startTime = GetTime() - elapsedCapped
            return total, startTime
        end
    end

    -- C_TaskQuest.GetQuestTimeLeftSeconds: seconds remaining (second-precision).
    -- Falls back to GetQuestTimeLeftMinutes if the newer API isn't available.
    if C_TaskQuest then
        if C_TaskQuest.GetQuestTimeLeftSeconds then
            local ok, secs = pcall(C_TaskQuest.GetQuestTimeLeftSeconds, questID)
            if ok and secs and secs > 0 then
                -- secs is time *remaining*, so duration = secs, startTime = GetTime()
                return secs, GetTime()
            end
        elseif C_TaskQuest.GetQuestTimeLeftMinutes then
            local ok, mins = pcall(C_TaskQuest.GetQuestTimeLeftMinutes, questID)
            if ok and mins and mins > 0 then
                return mins * 60, GetTime()
            end
        end
    end

    return nil, nil
end

--- Probe UI widget manager for a scenario header timer (open-world events, prepatch, etc.).
-- Walks the widget set attached to the current scenario step and looks for ScenarioHeaderTimer widgets.
-- @return duration, startTime or nil, nil
local function GetWidgetTimerInfo()
    if not C_UIWidgetManager or not C_UIWidgetManager.GetAllWidgetsBySetID or not C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo then
        return nil, nil
    end
    -- Determine the widget set ID from the current scenario step.
    local setID
    -- Prefer C_ScenarioInfo.GetScenarioStepInfo (structured table with widgetSetID).
    if C_ScenarioInfo and C_ScenarioInfo.GetScenarioStepInfo then
        local siOk, stepInfo = pcall(C_ScenarioInfo.GetScenarioStepInfo)
        if siOk and stepInfo and type(stepInfo) == "table" and stepInfo.widgetSetID and stepInfo.widgetSetID ~= 0 then
            setID = stepInfo.widgetSetID
        end
    end
    -- Fallback: positional extraction from C_Scenario.GetStepInfo.
    if not setID and C_Scenario and C_Scenario.GetStepInfo then
        local sOk, t = pcall(function() return { C_Scenario.GetStepInfo() } end)
        if sOk and t and type(t) == "table" and #t >= 12 then
            local ws = t[12]
            if type(ws) == "number" and ws ~= 0 then setID = ws end
        end
    end
    if not setID and C_UIWidgetManager.GetObjectiveTrackerWidgetSetID then
        local oOk, objSet = pcall(C_UIWidgetManager.GetObjectiveTrackerWidgetSetID)
        if oOk and objSet and type(objSet) == "number" then setID = objSet end
    end
    if not setID then return nil, nil end

    local WIDGET_TIMER = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.ScenarioHeaderTimer) or 20
    local wOk, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, setID)
    if not wOk or not widgets or type(widgets) ~= "table" then return nil, nil end

    for _, wInfo in pairs(widgets) do
        local widgetID = (wInfo and type(wInfo) == "table" and type(wInfo.widgetID) == "number") and wInfo.widgetID
            or (type(wInfo) == "number" and wInfo > 0) and wInfo
        local wType = (wInfo and type(wInfo) == "table") and wInfo.widgetType
        if widgetID and (not wType or wType == WIDGET_TIMER) then
            local tOk, timerInfo = pcall(C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo, widgetID)
            if tOk and timerInfo and type(timerInfo) == "table" and timerInfo.hasTimer then
                local timerMax = timerInfo.timerMax
                local timerValue = timerInfo.timerValue
                if timerMax and timerValue and type(timerMax) == "number" and type(timerValue) == "number" and timerMax > 0 then
                    -- timerValue = seconds remaining; timerMax = total duration.
                    local remaining = math.max(0, timerValue)
                    local elapsed = timerMax - remaining
                    return timerMax, GetTime() - elapsed
                end
            end
        end
    end
    return nil, nil
end

local function IsScenarioActive()
    if not C_Scenario then return false end
    if C_Scenario.IsInScenario then
        local okIn, inScenario = pcall(C_Scenario.IsInScenario)
        if okIn and not inScenario then return false end
    end

    if C_Scenario.GetInfo then
        local okInfo, name, currentStage = pcall(C_Scenario.GetInfo)
        if okInfo and ((name and name ~= "") or (currentStage and currentStage > 0)) then
            return true
        end
    end

    if C_Scenario.GetStepInfo then
        local sOk, stageName = pcall(C_Scenario.GetStepInfo)
        if sOk and stageName and stageName ~= "" then
            return true
        end
    end
    if C_Scenario.GetBonusSteps then
        local bOk, bonusSteps = pcall(C_Scenario.GetBonusSteps)
        if bOk and bonusSteps and #bonusSteps > 0 then
            return true
        end
    end
    return false
end

-- Resolve delve name using same sources as zone-entry flow; order per Blizzard API docs.
--- @return string|nil Delve name or nil
local function GetDelveNameFromAPIs()
    if not addon.IsDelveActive or not addon.IsDelveActive() then return nil end

    -- 1. C_ScenarioInfo.GetScenarioInfo() returns ScenarioInformation with name, area
    if C_ScenarioInfo and C_ScenarioInfo.GetScenarioInfo then
        local ok, info = pcall(C_ScenarioInfo.GetScenarioInfo)
        if ok and info and type(info) == "table" then
            if info.name and info.name ~= "" then return info.name end
            if info.area and info.area ~= "" then return info.area end
        end
    end

    -- 2. C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo (Blizzard delve header)
    if C_UIWidgetManager and C_UIWidgetManager.GetAllWidgetsBySetID and C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo then
        local setID
        if C_Scenario and C_Scenario.GetStepInfo then
            local sOk, t = pcall(function() return { C_Scenario.GetStepInfo() } end)
            if sOk and t and type(t) == "table" and #t >= 12 then
                local ws = t[12]
                if type(ws) == "number" and ws ~= 0 then setID = ws end
            end
        end
        if not setID and C_UIWidgetManager.GetObjectiveTrackerWidgetSetID then
            local oOk, objSet = pcall(C_UIWidgetManager.GetObjectiveTrackerWidgetSetID)
            if oOk and objSet and type(objSet) == "number" then setID = objSet end
        end
        if setID then
            local wOk, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, setID)
            if wOk and widgets and type(widgets) == "table" then
                local WIDGET_DELVES = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.ScenarioHeaderDelves) or 29
                for _, wInfo in pairs(widgets) do
                    local widgetID = (wInfo and type(wInfo) == "table" and type(wInfo.widgetID) == "number") and wInfo.widgetID
                        or (type(wInfo) == "number" and wInfo > 0) and wInfo
                    local wType = (wInfo and type(wInfo) == "table") and wInfo.widgetType
                    if widgetID and (not wType or wType == WIDGET_DELVES) then
                        local dOk, widgetInfo = pcall(C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo, widgetID)
                        if dOk and widgetInfo and type(widgetInfo) == "table" and widgetInfo.headerText and widgetInfo.headerText ~= "" then
                            return widgetInfo.headerText
                        end
                        break
                    end
                end
            end
        end
    end

    -- 3. GetZoneText / GetSubZoneText (prefer non-"Delves" when parent/delve swap)
    local zone = (GetZoneText and GetZoneText()) or ""
    local sub = (GetSubZoneText and GetSubZoneText()) or ""
    if zone and zone ~= "" and zone ~= "Delves" then return zone end
    if sub and sub ~= "" and sub ~= "Delves" then return sub end
    if zone and zone ~= "" then return zone end
    if sub and sub ~= "" then return sub end

    return nil
end

--- Get display info for Presence scenario-start toast. Returns nil if not in scenario.
--- @return title, subtitle, category or nil, nil, nil
local function GetScenarioDisplayInfo()
    if not IsScenarioActive() then return nil, nil, nil end
    local isDelve = addon.IsDelveActive and addon.IsDelveActive()
    local inPartyDungeon = addon.IsInPartyDungeon and addon.IsInPartyDungeon()
    local category = isDelve and "DELVES" or (inPartyDungeon and "DUNGEON") or "SCENARIO"

    local scenarioName
    if C_Scenario and C_Scenario.GetInfo then
        local ok, name = pcall(C_Scenario.GetInfo)
        if ok and name and name ~= "" then scenarioName = name end
    end

    local stageName
    if C_Scenario and C_Scenario.GetStepInfo then
        local ok, name = pcall(C_Scenario.GetStepInfo)
        if ok and name and name ~= "" then stageName = name end
    end

    local title = scenarioName
    if inPartyDungeon then
        -- C_Scenario.GetInfo returns step/area name in dungeons; prefer instance name
        local instanceName = GetInstanceInfo()
        if instanceName and instanceName ~= "" then
            title = instanceName
        elseif not title or title == "" then
            title = "Dungeon"
        end
    elseif not title or title == "" then
        if isDelve then
            -- Same system as zone-entry: C_ScenarioInfo, widget headerText, zone/subzone, then fallback
            title = GetDelveNameFromAPIs()
            local tier = addon.GetActiveDelveTier and addon.GetActiveDelveTier()
            if title and title ~= "" then
                if tier then title = title .. " (Tier " .. tier .. ")" end
            else
                title = tier and ("Delves (Tier " .. tier .. ")") or "Delves"
            end
        else
            title = "Scenario"
        end
    elseif isDelve then
        local tier = addon.GetActiveDelveTier and addon.GetActiveDelveTier()
        if tier then title = title .. " (Tier " .. tier .. ")" end
    end

    return title or "Scenario", stageName or "", category
end

--- Build tracker rows from active scenario main step and bonus steps.
-- @return table Array of normalized entry tables for the tracker
local function ReadScenarioEntries()
    local out = {}
    if not addon.GetDB("showScenarioEvents", true) then return out end
    if not C_Scenario then return out end
    if not IsScenarioActive() then return out end

    local isDelve = addon.IsDelveActive and addon.IsDelveActive()
    local inPartyDungeon = addon.IsInPartyDungeon and addon.IsInPartyDungeon()

    -- When the M+ block is active in a dungeon, suppress the built-in
    -- scenario objectives (bosses/forces are shown in the M+ block).
    if inPartyDungeon and addon.mplusBlock and addon.mplusBlock:IsShown() then
        return out
    end
    local category = isDelve and "DELVES" or (inPartyDungeon and "DUNGEON") or "SCENARIO"
    local scenarioColor = addon.GetQuestColor and addon.GetQuestColor(category) or (addon.QUEST_COLORS and addon.QUEST_COLORS[category]) or { 0.38, 0.52, 0.88 }
    local delveTier = isDelve and (addon.GetActiveDelveTier and addon.GetActiveDelveTier()) or nil

    -- Main step
    if C_Scenario.GetStepInfo and C_ScenarioInfo and C_ScenarioInfo.GetCriteriaInfo then
        local t = { pcall(C_Scenario.GetStepInfo) }
        local ok = t[1]
        local stageName = t[2]
        -- GetStepInfo return order may vary; try fallbacks (3: numCriteria at 4 or 3 or 5).
        local numCriteria = t[4] or t[3] or t[5]
        local rawReward = t[11] or t[10] or t[12]
        local rewardQuestID = (type(rawReward) == "number" and rawReward > 0) and rawReward or nil
        if ScenarioDebug then
            ScenarioDebug("GetStepInfo: ok=%s stageName=%s numCriteria=%s rewardQuestID=%s",
                tostring(ok), tostring(stageName), tostring(numCriteria), tostring(rewardQuestID))
            for i = 1, math.min(#t, 15) do ScenarioDebug("  t[%d]=%s", i, tostring(t[i])) end
        end
        if ok and stageName and stageName ~= "" then
            local objectives = {}
            local timerDuration, timerStartTime = nil, nil

            -- Try 0-based and 1..numCriteria+3 to catch off-by-one and extra timer-only criteria (KT-aligned).
            local maxIdx = math.max((numCriteria or 0), 1) + 3
            for criteriaIndex = 0, maxIdx do
                local cOk, criteriaInfo = pcall(C_ScenarioInfo.GetCriteriaInfo, criteriaIndex)
                -- Option 5: Fallback to GetCriteriaInfoByStep(1, ci) for main step when GetCriteriaInfo returns nil.
                if (not cOk or not criteriaInfo) and C_ScenarioInfo.GetCriteriaInfoByStep then
                    cOk, criteriaInfo = pcall(C_ScenarioInfo.GetCriteriaInfoByStep, 1, criteriaIndex)
                end
                if cOk and criteriaInfo then
                    local d, s = GetCriteriaTimerInfo(criteriaInfo)
                    local hasTimer = (d and s) and not (criteriaInfo.failed or criteriaInfo.completed or criteriaInfo.complete)
                    local text = (criteriaInfo.description and criteriaInfo.description ~= "") and criteriaInfo.description or (criteriaInfo.criteriaString or "")
                    local qty, totalQty = criteriaInfo.quantity, criteriaInfo.totalQuantity
                    local hasQuantity = qty ~= nil and totalQty ~= nil and type(qty) == "number" and type(totalQty) == "number" and totalQty > 0
                    -- Option 4: Include timer-only criteria (no text) as standalone timer objectives.
                    local obj = {
                        text = text ~= "" and text or nil,
                        finished = criteriaInfo.complete or criteriaInfo.completed or false,
                        percent = hasQuantity and math.floor(100 * qty / totalQty) or nil,
                        numFulfilled = hasQuantity and qty or nil,
                        numRequired = hasQuantity and totalQty or nil,
                        timerDuration = hasTimer and d or nil,
                        timerStartTime = hasTimer and s or nil,
                    }
                    objectives[#objectives + 1] = obj
                    if hasTimer and (not timerDuration or not timerStartTime) then
                        timerDuration, timerStartTime = d, s
                    end
                    if ScenarioDebug then
                        ScenarioDebug("crit[%d] dur=%s elapsed=%s hasTimer=%s", criteriaIndex,
                            tostring(criteriaInfo.duration), tostring(criteriaInfo.elapsed), tostring(hasTimer))
                    end
                end
            end

            if not timerDuration or not timerStartTime then
                timerDuration, timerStartTime = GetQuestTimerInfo(rewardQuestID)
                if ScenarioDebug then
                    ScenarioDebug("Quest fallback: rewardQuestID=%s got timer=%s", tostring(rewardQuestID), (timerDuration and timerStartTime) and "yes" or "no")
                end
            end
            if not timerDuration or not timerStartTime then
                timerDuration, timerStartTime = GetWidgetTimerInfo()
                if ScenarioDebug then
                    ScenarioDebug("Widget fallback: got timer=%s", (timerDuration and timerStartTime) and "yes" or "no")
                end
            end
            if ScenarioDebug then
                ScenarioDebug("main: objs=%d timers=%s entryTimer=%s", #objectives,
                    timerDuration and "yes" or "no", (timerDuration and timerStartTime) and "yes" or "no")
            end

            local mainEntry = {
                entryKey          = "scenario-main",
                questID           = rewardQuestID,
                title             = stageName,
                objectives        = objectives,
                color             = scenarioColor,
                category          = category,
                isComplete        = false,
                isSuperTracked    = false,
                isNearby          = true,
                zoneName          = nil,
                itemLink          = nil,
                itemTexture       = nil,
                isTracked         = true,
                isScenarioMain    = true,
                isScenarioBonus   = false,
                scenarioStepIndex = nil,
                rewardQuestID     = rewardQuestID,
                timerDuration     = timerDuration,
                timerStartTime    = timerStartTime,
            }
            if delveTier then mainEntry.delveTier = delveTier end
            out[#out + 1] = mainEntry
        end
    end

    -- Bonus steps
    if C_Scenario.GetBonusSteps and C_Scenario.GetBonusStepRewardQuestID then
        local ok, bonusSteps = pcall(C_Scenario.GetBonusSteps)
        if ok and bonusSteps and #bonusSteps > 0 then
            for _, stepInfo in ipairs(bonusSteps) do
                local stepIndex = (type(stepInfo) == "table" and stepInfo.stepIndex) or (type(stepInfo) == "number" and stepInfo)
                if stepIndex then
                    local rOk, rewardQuestID = pcall(C_Scenario.GetBonusStepRewardQuestID, stepIndex)
                    local bt = { pcall(C_Scenario.GetStepInfo, stepIndex) }
                    local bOk = bt[1]
                    local bonusTitle = bt[2]
                    local bonusNumCriteria = bt[4] or bt[3] or bt[5]
                    local rawBonus = bt[11] or bt[10] or bt[12]
                    local bonusRewardQuestID = (type(rawBonus) == "number" and rawBonus > 0) and rawBonus or nil
                    if ScenarioDebug then
                        ScenarioDebug("Bonus step %d: title=%s numCriteria=%s rewardID=%s", stepIndex,
                            tostring(bonusTitle), tostring(bonusNumCriteria), tostring(bonusRewardQuestID))
                    end
                    local title = (bOk and bonusTitle and bonusTitle ~= "") and bonusTitle
                        or (type(stepInfo) == "table" and stepInfo.name and stepInfo.name ~= "" and stepInfo.name)
                        or (rOk and rewardQuestID and C_QuestLog and C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(rewardQuestID))
                        or ("Bonus " .. tostring(stepIndex))
                    local objectives = {}
                    local timerDuration, timerStartTime = nil, nil

                    if C_ScenarioInfo and C_ScenarioInfo.GetCriteriaInfoByStep then
                        local maxCriteria = math.max((bonusNumCriteria and bonusNumCriteria > 0) and bonusNumCriteria or 10, 1) + 3
                        for ci = 0, maxCriteria do
                            local cOk, criteriaInfo = pcall(C_ScenarioInfo.GetCriteriaInfoByStep, stepIndex, ci)
                            if cOk and criteriaInfo then
                                local d, s = GetCriteriaTimerInfo(criteriaInfo)
                                local hasTimer = (d and s) and not (criteriaInfo.failed or criteriaInfo.completed or criteriaInfo.complete)
                                local text = (criteriaInfo.description and criteriaInfo.description ~= "") and criteriaInfo.description or (criteriaInfo.criteriaString or "")
                                local qty, totalQty = criteriaInfo.quantity, criteriaInfo.totalQuantity
                                local hasQuantity = qty ~= nil and totalQty ~= nil and type(qty) == "number" and type(totalQty) == "number" and totalQty > 0
                                objectives[#objectives + 1] = {
                                    text = text ~= "" and text or nil,
                                    finished = criteriaInfo.complete or criteriaInfo.completed or false,
                                    percent = hasQuantity and math.floor(100 * qty / totalQty) or nil,
                                    numFulfilled = hasQuantity and qty or nil,
                                    numRequired = hasQuantity and totalQty or nil,
                                    timerDuration = hasTimer and d or nil,
                                    timerStartTime = hasTimer and s or nil,
                                }
                                if hasTimer and (not timerDuration or not timerStartTime) then
                                    timerDuration, timerStartTime = d, s
                                end
                                if ScenarioDebug then
                                    ScenarioDebug("bonus[%d] crit[%d] dur=%s elapsed=%s hasTimer=%s", stepIndex, ci,
                                        tostring(criteriaInfo.duration), tostring(criteriaInfo.elapsed), tostring(hasTimer))
                                end
                            end
                        end
                    end

                    if not timerDuration or not timerStartTime then
                        timerDuration, timerStartTime = GetQuestTimerInfo((bOk and bonusRewardQuestID) or (rOk and rewardQuestID))
                        if ScenarioDebug then
                            ScenarioDebug("Bonus step %d quest fallback: timer=%s", stepIndex, (timerDuration and timerStartTime) and "yes" or "no")
                        end
                    end
                    if not timerDuration or not timerStartTime then
                        timerDuration, timerStartTime = GetWidgetTimerInfo()
                    end

                    local bonusEntry = {
                        entryKey          = "scenario-bonus-" .. tostring(stepIndex),
                        questID           = nil,
                        title             = title or ("Bonus " .. tostring(stepIndex)),
                        objectives        = objectives,
                        color             = scenarioColor,
                        category          = category,
                        isComplete        = false,
                        isSuperTracked    = false,
                        isNearby          = true,
                        zoneName          = nil,
                        itemLink          = nil,
                        itemTexture       = nil,
                        isTracked         = true,
                        isScenarioMain    = false,
                        isScenarioBonus   = true,
                        scenarioStepIndex = stepIndex,
                        rewardQuestID     = (bOk and bonusRewardQuestID) or (rOk and rewardQuestID) or nil,
                        timerDuration     = timerDuration,
                        timerStartTime    = timerStartTime,
                    }
                    if delveTier then bonusEntry.delveTier = delveTier end
                    out[#out + 1] = bonusEntry
                end
            end
        end
    end

    return out
end

addon.ReadScenarioEntries    = ReadScenarioEntries
addon.IsScenarioActive      = IsScenarioActive
addon.GetScenarioDisplayInfo = GetScenarioDisplayInfo
