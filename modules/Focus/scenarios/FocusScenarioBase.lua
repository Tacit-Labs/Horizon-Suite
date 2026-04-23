--[[
    Horizon Suite - Focus - Scenario Base Provider
    Common utilities and base class for specialized scenario providers.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

local BaseProvider = {}
BaseProvider.__index = BaseProvider

function BaseProvider:New()
    local o = setmetatable({}, self)
    return o
end

--- ScenarioHeaderTimer (widgetType 20) from step's widget set. Verified for Singularity.
--- Uses cache when valid to avoid countdown jump from stale API samples on layout refresh.
--- @param setID number|nil Widget set ID; if nil, uses GetScenarioStepInfo().widgetSetID
--- @return number|nil duration, number|nil startTime
function BaseProvider:GetWidgetStepTimer(setID)
    local wsID = setID
    if not wsID or wsID <= 0 then
        local stepInfo = C_ScenarioInfo and C_ScenarioInfo.GetScenarioStepInfo and C_ScenarioInfo.GetScenarioStepInfo()
        wsID = stepInfo and stepInfo.widgetSetID
    end
    if not wsID or wsID <= 0 then return nil, nil end

    local cache = addon.focus and addon.focus.scenarioTimerCache
    local now = GetTime()
    if cache and cache.widgetSetID == wsID and (now - cache.startTime) < cache.duration then
        return cache.duration, cache.startTime
    end

    if not C_UIWidgetManager or not C_UIWidgetManager.GetAllWidgetsBySetID then return nil, nil end

    local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(wsID)
    for _, w in ipairs(widgets or {}) do
        if w.widgetType == 20 and C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo then
            local ti = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(w.widgetID)
            if ti and ti.shownState == 1 then
                local tMin = ti.timerMin or 0
                local duration = (ti.timerMax or 0) - tMin
                local remaining = (ti.timerValue or 0) - tMin
                if remaining > 0 and duration > 0 then
                    local startTime = GetTime() - (duration - remaining)
                    if addon.focus then
                        addon.focus.scenarioTimerCache = { widgetSetID = wsID, duration = duration, startTime = startTime }
                    end
                    return duration, startTime
                end
            end
        end
    end
    return nil, nil
end

--- Timer extraction: criteria, quest, then widget (ScenarioHeaderTimer type 20).
--- ScenarioHeaderTimer uses zQuestLog formula (timerMin/timerMax/timerValue).
function BaseProvider:GetTimerInfo(criteriaInfo, rewardQuestID, widgetSetID)
    -- 1. Criteria Timer (C_ScenarioInfo)
    if criteriaInfo and criteriaInfo.duration and criteriaInfo.duration > 0 then
        local elapsed = math.max(0, math.min(criteriaInfo.elapsed or 0, criteriaInfo.duration))
        if elapsed < criteriaInfo.duration then
            return criteriaInfo.duration, GetTime() - elapsed
        end
    end

    -- 2. Quest Timer (C_QuestLog)
    if rewardQuestID and C_QuestLog.GetTimeAllowed then
        local ok, total, elapsed = pcall(C_QuestLog.GetTimeAllowed, rewardQuestID)
        if ok and total and elapsed and total > 0 then
            return total, GetTime() - math.min(elapsed, total)
        end
    end

    -- 3. Widget Timer (ScenarioHeaderTimer type 20 only; verified for Singularity)
    local dur, start = self:GetWidgetStepTimer(widgetSetID)
    if dur and start then return dur, start end

    local objSet = C_UIWidgetManager and C_UIWidgetManager.GetObjectiveTrackerWidgetSetID
        and C_UIWidgetManager.GetObjectiveTrackerWidgetSetID()
    if objSet and objSet ~= 0 and objSet ~= widgetSetID then
        dur, start = self:GetWidgetStepTimer(objSet)
        if dur and start then return dur, start end
    end

    return nil, nil
end

--- Modernized widget objective parsing.
function BaseProvider:ParseWidgetObjectives(setID)
    local objectives = {}
    if not setID or setID == 0 then return objectives end

    local WIDGET_STATUSBAR = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.StatusBar) or 2
    local WIDGET_ICONANDTEXT = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.IconAndText) or 0

    local ok, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, setID)
    if not ok or not widgets then return objectives end

    for _, wInfo in pairs(widgets) do
        local widgetID = type(wInfo) == "table" and wInfo.widgetID or (type(wInfo) == "number" and wInfo)
        local wType = type(wInfo) == "table" and wInfo.widgetType or nil
        if widgetID then
            -- Status Bar
            if not wType or wType == WIDGET_STATUSBAR then
                local sOk, sInfo = pcall(C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo, widgetID)
                if sOk and sInfo and sInfo.barMax and sInfo.barMax > 0 then
                    local text = sInfo.overrideBarText or sInfo.text or ""
                    local cur, max = sInfo.barValue, sInfo.barMax
                    objectives[#objectives+1] = {
                        text = text ~= "" and text or (addon.FormatNumberWithGrouping(cur) .. "/" .. addon.FormatNumberWithGrouping(max)),
                        numFulfilled = cur,
                        numRequired = max,
                        percent = math.min(100, math.floor(100 * cur / max)),
                        finished = false,
                        isWeighted = true,
                    }
                end
            end

            -- Icon and Text (parsing X/Y strings)
            if not wType or wType == WIDGET_ICONANDTEXT then
                local iOk, iInfo = pcall(C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo, widgetID)
                if iOk and iInfo and iInfo.text and iInfo.text ~= "" then
                    local curStr, maxStr = iInfo.text:match("(%d+)%s*/%s*(%d+)")
                    if curStr and maxStr then
                        local cur, max = tonumber(curStr), tonumber(maxStr)
                        if cur and max and max > 0 then
                            objectives[#objectives+1] = {
                                text = iInfo.text:gsub("|c........", ""):gsub("|r", ""),
                                numFulfilled = cur,
                                numRequired = max,
                                percent = math.min(100, math.floor(100 * cur / max)),
                                finished = false,
                            }
                        end
                    end
                end
            end
        end
    end
    return objectives
end

--- Normalize objective text for deduplication (strip color codes, trim).
--- @param text string|nil
--- @return string
local function NormalizeObjectiveText(text)
    if not text or type(text) ~= "string" then return "" end
    return text:gsub("|c........", ""):gsub("|r", ""):gsub("^%s+", ""):gsub("%s+$", ""):lower()
end

--- Deduplicate objectives by normalized text. When duplicates exist, keep the one with higher progress.
--- @param objectives table Array of objective tables
--- @return table Deduplicated array (preserves order of first occurrence)
function BaseProvider:DeduplicateObjectives(objectives)
    if not objectives or #objectives == 0 then return objectives end
    local function getProgress(o)
        if o.percent ~= nil then return o.percent end
        if o.numFulfilled and o.numRequired and o.numRequired > 0 then
            return math.floor(100 * o.numFulfilled / o.numRequired)
        end
        return 0
    end
    local seen = {}
    local out = {}
    for _, obj in ipairs(objectives) do
        local key = NormalizeObjectiveText(obj and obj.text or "")
        if key == "" then
            table.insert(out, obj)
        else
            local existingIdx = seen[key]
            if not existingIdx then
                seen[key] = #out + 1
                table.insert(out, obj)
            else
                local curPct = getProgress(obj)
                local existPct = getProgress(out[existingIdx])
                if curPct > existPct then
                    out[existingIdx] = obj
                end
            end
        end
    end
    return out
end

--- Normalized objective builder from CriteriaInfo.
function BaseProvider:BuildObjectiveFromCriteria(criteriaInfo)
    if not criteriaInfo then return nil end
    
    local text = criteriaInfo.description ~= "" and criteriaInfo.description or criteriaInfo.criteriaString or ""
    local numFulfilled, numRequired, percent = nil, nil, nil
    
    -- Parse quantityString for "X/Y" format
    if criteriaInfo.quantityString then
        local curStr, maxStr = criteriaInfo.quantityString:match("(%d+)%s*/%s*(%d+)")
        if curStr and maxStr then
            numFulfilled, numRequired = tonumber(curStr), tonumber(maxStr)
            if numRequired and numRequired > 0 then
                percent = math.min(100, math.floor(100 * math.min(numFulfilled, numRequired) / numRequired))
            end
        end
    end
    
    -- Fallback to numeric values
    if not numFulfilled then
        if criteriaInfo.isWeightedProgress then
            -- For weighted progress, quantity is the displayed percentage (0-100), not a fraction numerator.
            local qty = criteriaInfo.quantity
            if qty ~= nil and type(qty) == "number" then
                percent = math.min(100, math.max(0, math.floor(qty)))
            end
        else
            numFulfilled = criteriaInfo.quantity
            numRequired = criteriaInfo.totalQuantity
            if numRequired and numRequired > 0 then
                percent = math.min(100, math.floor(100 * numFulfilled / numRequired))
            end
        end
    end

    local dur, start = self:GetTimerInfo(criteriaInfo)

    -- Boolean (0/1) objectives are simple — suppress bar data.
    if numRequired and numRequired <= 1 then
        percent = nil
    end

    return {
        text = text ~= "" and text or nil,
        finished = criteriaInfo.completed or false,
        percent = percent,
        numFulfilled = numFulfilled,
        numRequired = numRequired,
        isWeighted = (criteriaInfo.isWeightedProgress and percent ~= nil) or false,
        timerDuration = dur,
        timerStartTime = start,
    }
end

addon.FocusScenarioBaseProvider = BaseProvider
