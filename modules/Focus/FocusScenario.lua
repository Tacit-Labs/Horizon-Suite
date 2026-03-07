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
-- Also checks StatusBar widgets with hasTimer (e.g. Singularity, world scenarios).
-- Tries step-based set first, then ObjectiveTracker set as fallback.
-- @return duration, startTime or nil, nil
local function GetWidgetTimerInfo()
    if not C_UIWidgetManager or not C_UIWidgetManager.GetAllWidgetsBySetID then
        return nil, nil
    end
    -- Build ordered list of widget set IDs to try. Step-based first, then ObjectiveTracker (may have timer when step set does not).
    local setsToTry = {}
    local seen = {}
    local function addSet(s)
        if s and type(s) == "number" and s ~= 0 and not seen[s] then
            seen[s] = true
            setsToTry[#setsToTry + 1] = s
        end
    end
    -- Prefer C_ScenarioInfo.GetScenarioStepInfo (structured table with widgetSetID).
    if C_ScenarioInfo and C_ScenarioInfo.GetScenarioStepInfo then
        local siOk, stepInfo = pcall(C_ScenarioInfo.GetScenarioStepInfo)
        if siOk and stepInfo and type(stepInfo) == "table" and stepInfo.widgetSetID then
            addSet(stepInfo.widgetSetID)
        end
    end
    -- Fallback: positional extraction from C_Scenario.GetStepInfo.
    if C_Scenario and C_Scenario.GetStepInfo then
        local sOk, t = pcall(function() return { C_Scenario.GetStepInfo() } end)
        if sOk and t and type(t) == "table" and #t >= 12 then
            local ws = t[12]
            if type(ws) == "number" then addSet(ws) end
        end
    end
    if C_UIWidgetManager.GetObjectiveTrackerWidgetSetID then
        local oOk, objSet = pcall(C_UIWidgetManager.GetObjectiveTrackerWidgetSetID)
        if oOk and objSet and type(objSet) == "number" then addSet(objSet) end
    end
    if #setsToTry == 0 then return nil, nil end

    -- 1. Try ScenarioHeaderTimer on every widget (some scenarios may not set widgetType correctly).
    if C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo then
        for i = 1, #setsToTry do
            local setID = setsToTry[i]
            local wOk, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, setID)
            if wOk and widgets and type(widgets) == "table" then
                for _, wInfo in pairs(widgets) do
                    local widgetID = (wInfo and type(wInfo) == "table" and type(wInfo.widgetID) == "number") and wInfo.widgetID
                        or (type(wInfo) == "number" and wInfo > 0) and wInfo
                    if widgetID then
                        local tOk, timerInfo = pcall(C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo, widgetID)
                        if tOk and timerInfo and type(timerInfo) == "table" and timerInfo.hasTimer then
                            local timerMax = timerInfo.timerMax
                            local timerValue = timerInfo.timerValue
                            if timerMax and timerValue and type(timerMax) == "number" and type(timerValue) == "number" and timerMax > 0 then
                                local remaining = math.max(0, timerValue)
                                local elapsed = timerMax - remaining
                                return timerMax, GetTime() - elapsed
                            end
                        end
                    end
                end
            end
        end
    end

    -- 2. Fallback: StatusBar widgets with hasTimer (e.g. Singularity "Prevent Anchor from reaching zero", world scenarios).
    if C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo then
        for i = 1, #setsToTry do
            local setID = setsToTry[i]
            local wOk, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, setID)
            if wOk and widgets and type(widgets) == "table" then
                for _, wInfo in pairs(widgets) do
                    local widgetID = (wInfo and type(wInfo) == "table" and type(wInfo.widgetID) == "number") and wInfo.widgetID
                        or (type(wInfo) == "number" and wInfo > 0) and wInfo
                    if widgetID then
                        local sOk, info = pcall(C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo, widgetID)
                        if sOk and info and type(info) == "table" and info.hasTimer then
                            local barMax = info.barMax or 0
                            local barValue = info.barValue
                            if barMax and barMax > 0 and barValue ~= nil and type(barMax) == "number" and type(barValue) == "number" then
                                -- barValue = seconds remaining; barMax = total duration (StatusBar timer semantics).
                                local remaining = math.max(0, math.min(barValue, barMax))
                                local elapsed = barMax - remaining
                                return barMax, GetTime() - elapsed
                            end
                        end
                    end
                end
            end
        end
    end

    -- 3. Fallback: scrape timer text from Blizzard's ScenarioObjectiveTracker (widget set returns 0 when tracker hidden).
    -- Walk frame hierarchy to find Timer.Text with "M:SS" format; use as remaining seconds.
    if _G.ScenarioObjectiveTracker and _G.ScenarioObjectiveTracker.ContentsFrame then
        local function findTimerText(frame, depth)
            if not frame or depth > 15 then return nil end
            if frame.GetText and frame.GetObjectType and frame:GetObjectType() == "FontString" then
                local text = frame:GetText()
                if text and type(text) == "string" then
                    local mins, secs = text:match("^(%d+):(%d%d?)$")
                    if mins and secs then
                        local m, s = tonumber(mins), tonumber(secs)
                        if m and s and m >= 0 and s >= 0 and s < 60 then
                            return (m * 60) + s
                        end
                    end
                end
            end
            local children = { frame:GetChildren() }
            for _, child in ipairs(children) do
                local found = findTimerText(child, depth + 1)
                if found then return found end
            end
            return nil
        end
        local remaining = findTimerText(_G.ScenarioObjectiveTracker.ContentsFrame, 0)
        if remaining and remaining > 0 then
            return remaining, GetTime()
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

--- True when the current scenario is Abundance (TWW open-world scenario).
--- Used to scope widget fallback sets 252/514 and bar styling to Abundance only.
--- @return boolean
local function IsAbundanceScenario()
    if not C_Scenario or not C_Scenario.GetInfo then return false end
    local ok, name = pcall(C_Scenario.GetInfo)
    if ok and name and type(name) == "string" and name:lower():find("abundance") then
        return true
    end
    if C_ScenarioInfo and C_ScenarioInfo.GetScenarioInfo then
        local siOk, info = pcall(C_ScenarioInfo.GetScenarioInfo)
        if siOk and info and type(info) == "table" then
            local n = (info.name or ""):lower()
            local a = (info.area or ""):lower()
            if n:find("abundance") or a:find("abundance") then return true end
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

--- Read scenario objectives from C_UIWidgetManager (StatusBar, IconAndText widgets).
--- Fallback when C_ScenarioInfo returns percent-only; Blizzard may show "46/300" via widgets.
--- @param setID number Widget set ID from scenario step
--- @return table Array of { text, numFulfilled, numRequired, percent, finished }
local function ReadScenarioObjectivesFromWidgets(setID)
    local out = {}
    if not setID or setID == 0 then return out end
    if not C_UIWidgetManager or not C_UIWidgetManager.GetAllWidgetsBySetID then return out end

    local WIDGET_STATUSBAR = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.StatusBar) or 2
    local WIDGET_ICONANDTEXT = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.IconAndText) or 0
    local VALUE_OVER_MAX = (Enum and Enum.StatusBarValueTextType and Enum.StatusBarValueTextType.ValueOverMax) or 5

    local wOk, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, setID)
    if not wOk or not widgets or type(widgets) ~= "table" then return out end

    for _, wInfo in pairs(widgets) do
        local widgetID = (wInfo and type(wInfo) == "table" and type(wInfo.widgetID) == "number") and wInfo.widgetID
            or (type(wInfo) == "number" and wInfo > 0) and wInfo
        if widgetID then
        local wType = (wInfo and type(wInfo) == "table") and wInfo.widgetType

        if (not wType or wType == WIDGET_STATUSBAR) and C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo then
            local sOk, info = pcall(C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo, widgetID)
            if sOk and info and type(info) == "table" then
                local barMin = info.barMin or 0
                local barMax = info.barMax or 0
                local barValue = info.barValue or 0
                local text = (info.text and info.text ~= "") and info.text or nil
                local overrideBarText = (info.overrideBarText and info.overrideBarText ~= "") and info.overrideBarText or nil
                local displayText = overrideBarText or text or ""

                local numFulfilled, numRequired, percent = nil, nil, nil
                local qsCur, qsMax = displayText:match("(%d+)%s*/%s*(%d+)")
                if qsCur and qsMax then
                    local cur, max = tonumber(qsCur), tonumber(qsMax)
                    if cur and max and max > 0 then
                        numFulfilled, numRequired = cur, max
                        percent = math.floor(100 * math.min(cur, max) / max)
                    end
                elseif barMax and barMax > 0 and (info.barValueTextType == VALUE_OVER_MAX or not info.barValueTextType) then
                    numFulfilled = math.floor(barValue)
                    numRequired = math.floor(barMax)
                    percent = math.floor(100 * math.min(barValue, barMax) / barMax)
                end

                if (numFulfilled or percent) and (text or overrideBarText or displayText ~= "") then
                    out[#out + 1] = {
                        text = text or overrideBarText or ("%d/%d"):format(numFulfilled or 0, numRequired or 0),
                        numFulfilled = numFulfilled,
                        numRequired = numRequired,
                        percent = percent,
                        finished = false,
                    }
                    if ScenarioDebug then
                        ScenarioDebug("widget StatusBar id=%d barValue=%s barMax=%s overrideBarText=%q -> nf=%s nr=%s",
                            widgetID, tostring(barValue), tostring(barMax), tostring(overrideBarText or ""),
                            tostring(numFulfilled), tostring(numRequired))
                    end
                end
            end
        elseif (not wType or wType == WIDGET_ICONANDTEXT) and C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo then
            local iOk, info = pcall(C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo, widgetID)
            if iOk and info and type(info) == "table" and info.text and info.text ~= "" then
                local text = info.text
                local qsCur, qsMax = text:match("(%d+)%s*/%s*(%d+)")
                if qsCur and qsMax then
                    local cur, max = tonumber(qsCur), tonumber(qsMax)
                    if cur and max and max > 0 then
                        out[#out + 1] = {
                            text = text,
                            numFulfilled = cur,
                            numRequired = max,
                            percent = math.floor(100 * math.min(cur, max) / max),
                            finished = false,
                        }
                        if ScenarioDebug then
                            ScenarioDebug("widget IconAndText id=%d text=%q -> nf=%s nr=%s", widgetID, text, tostring(cur), tostring(max))
                        end
                    end
                end
            end
        end
        end
    end

    return out
end

--- Build a normalized objective table from criteriaInfo.
--- Handles quantityString "X/Y" parsing, isWeightedProgress, and percent vs count display.
--- @param criteriaInfo table From C_ScenarioInfo.GetCriteriaInfo or GetCriteriaInfoByStep
--- @param criteriaIndex number For debug logging
--- @return table|nil Objective table or nil if invalid
local function BuildObjectiveFromCriteria(criteriaInfo, criteriaIndex)
    if not criteriaInfo then return nil end
    local d, s = GetCriteriaTimerInfo(criteriaInfo)
    local hasTimer = (d and s) and not (criteriaInfo.failed or criteriaInfo.completed or criteriaInfo.complete)
    local text = (criteriaInfo.description and criteriaInfo.description ~= "") and criteriaInfo.description or (criteriaInfo.criteriaString or "")
    local qty, totalQty = criteriaInfo.quantity, criteriaInfo.totalQuantity
    local qtyStr = criteriaInfo.quantityString
    local isWeightedProgress = criteriaInfo.isWeightedProgress == true

    -- Resolve numFulfilled, numRequired, percent from quantity/totalQuantity and quantityString.
    local numFulfilled, numRequired, percent = nil, nil, nil

    -- Parse quantityString for "X/Y" or "X / Y" format (raw count, e.g. Abundance "46/300").
    -- Match anywhere in string to handle "46/300 (33%)" or "31/300 for abundance held".
    -- Prefer parsed X/Y over percent-only: Blizzard often returns both (e.g. "46/300 (33%)"); raw count is more useful.
    local qsCur, qsMax = qtyStr and type(qtyStr) == "string" and qtyStr:match("(%d+)%s*/%s*(%d+)")
    if qsCur and qsMax then
        local parsedCur, parsedMax = tonumber(qsCur), tonumber(qsMax)
        if parsedCur and parsedMax and parsedMax > 0 then
            numFulfilled = parsedCur
            numRequired = parsedMax
            percent = math.floor(100 * math.min(parsedCur, parsedMax) / parsedMax)
        end
    end

    -- When quantityString has "%" but we did NOT parse "X/Y", treat as percent-only (e.g. "84%" or "1.20%").
    -- Do NOT overwrite when we already have numFulfilled/numRequired from "X/Y" (e.g. "46/300 (33%)").
    local isPercentQty = qtyStr and type(qtyStr) == "string" and qtyStr:find("%%")
    if isPercentQty and not numFulfilled and not numRequired then
        local pctFromStr = qtyStr and tonumber(qtyStr:match("(%d+%.?%d*)%%"))
        percent = (pctFromStr and pctFromStr >= 0) and math.floor(pctFromStr) or ((qty and type(qty) == "number") and qty or nil)
    elseif not numFulfilled and not numRequired then
        -- Fallback: use quantity/totalQuantity when not isWeightedProgress (raw count).
        local hasQuantity = qty ~= nil and totalQty ~= nil and type(qty) == "number" and type(totalQty) == "number" and totalQty > 0
        if hasQuantity and not isWeightedProgress then
            numFulfilled = qty
            numRequired = totalQty
            percent = math.floor(100 * qty / totalQty)
        elseif hasQuantity and isWeightedProgress then
            -- isWeightedProgress: quantity is percentage; no raw count from API.
            percent = math.floor(100 * qty / totalQty)
        end
    end

    if ScenarioDebug then
        ScenarioDebug("crit[%d] desc=%q qty=%s totalQty=%s qtyStr=%q isWeighted=%s isFormatted=%s -> nf=%s nr=%s pct=%s",
            criteriaIndex, tostring(text or ""), tostring(qty), tostring(totalQty), tostring(qtyStr or ""),
            tostring(isWeightedProgress), tostring(criteriaInfo.isFormatted), tostring(numFulfilled), tostring(numRequired), tostring(percent))
    end

    return {
        text = text ~= "" and text or nil,
        finished = criteriaInfo.complete or criteriaInfo.completed or false,
        percent = percent,
        numFulfilled = numFulfilled,
        numRequired = numRequired,
        timerDuration = hasTimer and d or nil,
        timerStartTime = hasTimer and s or nil,
    }
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

            -- Blizzard ScenarioObjectiveTracker uses 1-based indexing (for criteriaIndex = 1, numCriteria).
            -- Include +3 to catch extra timer-only criteria.
            local maxIdx = math.max((numCriteria or 0), 1) + 3
            for criteriaIndex = 1, maxIdx do
                local cOk, criteriaInfo = pcall(C_ScenarioInfo.GetCriteriaInfo, criteriaIndex)
                if (not cOk or not criteriaInfo) and C_ScenarioInfo.GetCriteriaInfoByStep then
                    cOk, criteriaInfo = pcall(C_ScenarioInfo.GetCriteriaInfoByStep, 1, criteriaIndex)
                end
                if cOk and criteriaInfo then
                    local obj = BuildObjectiveFromCriteria(criteriaInfo, criteriaIndex)
                    if obj then
                        objectives[#objectives + 1] = obj
                        if obj.timerDuration and obj.timerStartTime and (not timerDuration or not timerStartTime) then
                            timerDuration, timerStartTime = obj.timerDuration, obj.timerStartTime
                        end
                        if ScenarioDebug then
                            ScenarioDebug("crit[%d] dur=%s elapsed=%s hasTimer=%s", criteriaIndex,
                                tostring(criteriaInfo.duration), tostring(criteriaInfo.elapsed),
                                (obj.timerDuration and obj.timerStartTime) and "yes" or "no")
                        end
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
            -- UI Widget fallback: when C_ScenarioInfo returns percent-only (e.g. 33%) but Blizzard shows "46/300"
            -- via widgets, supplement with widget objectives. Try step widget set, ObjectiveTracker set, then fixed sets.
            local widgetSetID = (t[12] and type(t[12]) == "number" and t[12] ~= 0) and t[12] or nil
            if not widgetSetID and C_UIWidgetManager and C_UIWidgetManager.GetObjectiveTrackerWidgetSetID then
                local oOk, objSet = pcall(C_UIWidgetManager.GetObjectiveTrackerWidgetSetID)
                if oOk and objSet and type(objSet) == "number" then widgetSetID = objSet end
            end
            local SCENARIO_TRACKER_WIDGET_SET = 252
            local SCENARIO_TRACKER_TOP_WIDGET_SET = 514
            local function tryWidgetFallback(setID)
                if not setID or setID == 0 then return end
                local hasAnyXy = false
                for _, o in ipairs(objectives) do
                    if o.numFulfilled and o.numRequired then hasAnyXy = true; break end
                end
                local seenNr = {}
                for _, o in ipairs(objectives) do
                    if o.numRequired then seenNr[o.numRequired] = true end
                end
                local setMap = {}
                local function addSet(s) if s and s ~= 0 then setMap[s] = true end end
                addSet(setID)
                if IsAbundanceScenario() then
                    addSet(SCENARIO_TRACKER_WIDGET_SET)
                    addSet(SCENARIO_TRACKER_TOP_WIDGET_SET)
                end
                local setsToTry = {}
                for sid in pairs(setMap) do setsToTry[#setsToTry + 1] = sid end
                for _, sid in ipairs(setsToTry) do
                    local widgetObjs = ReadScenarioObjectivesFromWidgets(sid)
                    for _, wo in ipairs(widgetObjs) do
                        if wo.numFulfilled and wo.numRequired and not seenNr[wo.numRequired] then
                            seenNr[wo.numRequired] = true
                            objectives[#objectives + 1] = wo
                            if ScenarioDebug then
                                ScenarioDebug("widget fallback set=%d: added %s (%d/%d)", sid, tostring(wo.text), wo.numFulfilled, wo.numRequired)
                            end
                        end
                    end
                end
            end
            if widgetSetID then
                tryWidgetFallback(widgetSetID)
            elseif IsAbundanceScenario() then
                tryWidgetFallback(SCENARIO_TRACKER_WIDGET_SET)
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
            mainEntry.isAbundanceScenario = IsAbundanceScenario()
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
                        for ci = 1, maxCriteria do
                            local cOk, criteriaInfo = pcall(C_ScenarioInfo.GetCriteriaInfoByStep, stepIndex, ci)
                            if cOk and criteriaInfo then
                                local obj = BuildObjectiveFromCriteria(criteriaInfo, ci)
                                if obj then
                                    objectives[#objectives + 1] = obj
                                    if obj.timerDuration and obj.timerStartTime and (not timerDuration or not timerStartTime) then
                                        timerDuration, timerStartTime = obj.timerDuration, obj.timerStartTime
                                    end
                                    if ScenarioDebug then
                                        ScenarioDebug("bonus[%d] crit[%d] dur=%s elapsed=%s hasTimer=%s", stepIndex, ci,
                                            tostring(criteriaInfo.duration), tostring(criteriaInfo.elapsed),
                                            (obj.timerDuration and obj.timerStartTime) and "yes" or "no")
                                    end
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
                    bonusEntry.isAbundanceScenario = IsAbundanceScenario()
                    out[#out + 1] = bonusEntry
                end
            end
        end
    end

    return out
end

--- One-shot dump of scenario timer sources to chat. Run in a scenario to diagnose missing timers.
--- @return nil
local function DumpScenarioTimerInfo()
    local HSPrint = addon.HSPrint or function(m) print("|cFF00CCFFHorizon Suite:|r " .. tostring(m or "")) end
    HSPrint("|cFF00CCFF--- Scenario Timer Debug ---|r")
    if not addon.IsScenarioActive or not addon.IsScenarioActive() then
        HSPrint("Not in a scenario. Enter a scenario (e.g. Singularity, Delves) and run again.")
        return
    end
    local stageName, numCriteria, rewardQuestID = "?", nil, nil
    if C_Scenario and C_Scenario.GetStepInfo then
        local t = { pcall(C_Scenario.GetStepInfo) }
        if t[1] then
            stageName = t[2] or "?"
            numCriteria = t[4] or t[3] or t[5]
            local raw = t[11] or t[10] or t[12]
            if type(raw) == "number" and raw > 0 then rewardQuestID = raw end
        end
    end
    HSPrint("Step: " .. tostring(stageName) .. " | rewardQuestID=" .. tostring(rewardQuestID) .. " | numCriteria=" .. tostring(numCriteria))
    local durCrit, startCrit = nil, nil
    if C_ScenarioInfo and C_ScenarioInfo.GetCriteriaInfo then
        for ci = 1, math.max((numCriteria or 0) + 3, 1) do
            local cOk, crit = pcall(C_ScenarioInfo.GetCriteriaInfo, ci)
            if cOk and crit and crit.duration and crit.elapsed then
                durCrit, startCrit = GetCriteriaTimerInfo(crit)
                if durCrit and startCrit then
                    HSPrint("  Criteria[" .. ci .. "]: duration=" .. durCrit .. " (source: criteria)")
                    break
                end
            end
        end
    end
    if not durCrit or not startCrit then
        HSPrint("  Criteria: no timer")
        durCrit, startCrit = GetQuestTimerInfo(rewardQuestID)
        if durCrit and startCrit then
            HSPrint("  Quest: duration=" .. durCrit .. " (source: reward quest)")
        else
            HSPrint("  Quest: no timer")
            durCrit, startCrit = GetWidgetTimerInfo()
            if durCrit and startCrit then
                HSPrint("  Widget: duration=" .. durCrit .. " (source: ScenarioHeaderTimer or StatusBar hasTimer)")
            else
                HSPrint("  Widget: no timer (tried ScenarioHeaderTimer + StatusBar hasTimer)")
                -- Enumerate all candidate widget sets (step + ObjectiveTracker) to diagnose
                local setsToCheck = {}
                if C_Scenario and C_Scenario.GetStepInfo then
                    local st = { pcall(C_Scenario.GetStepInfo) }
                    if st[1] and st[12] and type(st[12]) == "number" then
                        setsToCheck[#setsToCheck + 1] = { id = st[12], label = "GetStepInfo" }
                    end
                end
                if C_UIWidgetManager and C_UIWidgetManager.GetObjectiveTrackerWidgetSetID then
                    local oOk, objSet = pcall(C_UIWidgetManager.GetObjectiveTrackerWidgetSetID)
                    if oOk and objSet and type(objSet) == "number" and objSet ~= 0 then
                        local seen = false
                        for _, s in ipairs(setsToCheck) do if s.id == objSet then seen = true break end end
                        if not seen then
                            setsToCheck[#setsToCheck + 1] = { id = objSet, label = "ObjectiveTracker" }
                        end
                    end
                end
                if C_ScenarioInfo and C_ScenarioInfo.GetScenarioStepInfo then
                    local siOk, stepInfo = pcall(C_ScenarioInfo.GetScenarioStepInfo)
                    if siOk and stepInfo and type(stepInfo) == "table" and stepInfo.widgetSetID and stepInfo.widgetSetID ~= 0 then
                        local seen = false
                        for _, s in ipairs(setsToCheck) do if s.id == stepInfo.widgetSetID then seen = true break end end
                        if not seen then
                            setsToCheck[#setsToCheck + 1] = { id = stepInfo.widgetSetID, label = "ScenarioStepInfo" }
                        end
                    end
                end
                for _, s in ipairs(setsToCheck) do
                    local wOk, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, s.id)
                    if wOk and widgets and type(widgets) == "table" then
                        local n = 0
                        for _ in pairs(widgets) do n = n + 1 end
                        HSPrint("  Widget set " .. s.id .. " (" .. s.label .. "): " .. n .. " widget(s)")
                        for k, wInfo in pairs(widgets) do
                            local wid = (wInfo and type(wInfo) == "table" and wInfo.widgetID) or (type(wInfo) == "number" and wInfo) or nil
                            local wType = (wInfo and type(wInfo) == "table") and wInfo.widgetType
                            if wid then
                                local parts = {}
                                if C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo then
                                    local tOk, ti = pcall(C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo, wid)
                                    if tOk and ti and ti.hasTimer then
                                        parts[#parts + 1] = "ScenarioHeaderTimer hasTimer"
                                    end
                                end
                                if C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo then
                                    local sOk, si = pcall(C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo, wid)
                                    if sOk and si and si.hasTimer then
                                        parts[#parts + 1] = "StatusBar hasTimer barValue=" .. tostring(si.barValue) .. " barMax=" .. tostring(si.barMax)
                                    elseif sOk and si then
                                        parts[#parts + 1] = "StatusBar barValue=" .. tostring(si.barValue) .. " barMax=" .. tostring(si.barMax)
                                    end
                                end
                                HSPrint("    id=" .. tostring(wid) .. " type=" .. tostring(wType) .. (#parts > 0 and (" " .. table.concat(parts, " ")) or ""))
                            end
                        end
                    end
                end
            end
        end
    end
    if durCrit and startCrit then
        local remaining = durCrit - (GetTime() - startCrit)
        HSPrint("|cFF00FF00Timer found: " .. math.floor(remaining) .. "s remaining|r")
    else
        HSPrint("|cFFFF0000No timer data from any source.|r")
    end
end

addon.ReadScenarioEntries      = ReadScenarioEntries
addon.IsScenarioActive        = IsScenarioActive
addon.IsAbundanceScenario     = IsAbundanceScenario
addon.GetScenarioDisplayInfo  = GetScenarioDisplayInfo
addon.GetDelveNameFromAPIs    = GetDelveNameFromAPIs
addon.DumpScenarioTimerInfo   = DumpScenarioTimerInfo
