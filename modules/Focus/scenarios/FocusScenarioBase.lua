--[[
    Horizon Suite - Focus - Scenario Base Provider
    Common utilities and base class for specialized scenario providers.
]]

local addon = _G.HorizonSuite

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
    local WIDGET_TEXTWITHSTATE = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.TextWithState) or 8
    local WIDGET_TEXTUREANDTEXT = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.TextureAndText)
    local WIDGET_DOUBLEICONANDTEXT = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.DoubleIconAndText)
    local WIDGET_TEXTWITHSUBTEXT = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.TextWithSubtext)
    local WIDGET_TEXTCOLUMNROW = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.TextColumnRow)
    local WIDGET_DISCRETEPROGRESS = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.DiscreteProgressSteps)
    local WIDGET_FILLUPFRAMES = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.FillUpFrames)
    local WIDGET_SCENARIOHEADERCURRENCIES = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.ScenarioHeaderCurrenciesAndBackground) or 11

    local function cleanText(text)
        if text == nil then return "" end
        if type(text) ~= "string" then text = tostring(text) end
        return text
            :gsub("|c%x%x%x%x%x%x%x%x", "")
            :gsub("|r", "")
            :gsub("|T.-|t%s*", "")
            :gsub("^%s+", "")
            :gsub("%s+$", "")
    end

    local function firstLine(text)
        text = cleanText(text)
        text = text:gsub("|n", "\n"):gsub("\\n", "\n"):gsub("\\r", "\n")
        return (text:match("^([^%c]+)") or ""):gsub("^%s+", ""):gsub("%s+$", "")
    end

    local function tooltipText(text)
        text = cleanText(text)
        return text:gsub("|n", "\n"):gsub("\\n", "\n"):gsub("\\r", "\n")
    end

    local function isRitualObjectiveText(text)
        local lower = cleanText(text):lower()
        return lower:find("ritual", 1, true)
            or lower:find("spoil", 1, true)
            or lower:find("loot", 1, true)
            or lower:find("death", 1, true)
    end

    local function objectiveFromText(text, allowPlain)
        text = cleanText(text)
        if text == "" then return nil end

        local curStr, maxStr = text:match("(%d[%d,%.]*)%s*/%s*(%d[%d,%.]*)")
        if curStr and maxStr then
            local cur = tonumber((curStr:gsub("[,%.]", "")))
            local max = tonumber((maxStr:gsub("[,%.]", "")))
            if cur and max and max > 0 then
                return {
                    text = text,
                    numFulfilled = cur,
                    numRequired = max,
                    percent = math.min(100, math.floor(100 * cur / max)),
                    finished = cur >= max,
                }
            end
        end

        if not allowPlain then return nil end

        return {
            text = text,
            finished = false,
        }
    end

    local function objectiveFromValues(text, current, maximum)
        text = cleanText(text)
        if text == "" then return nil end
        if type(current) ~= "number" or type(maximum) ~= "number" or maximum <= 0 then
            return objectiveFromText(text, isRitualObjectiveText(text))
        end

        return {
            text = text,
            numFulfilled = current,
            numRequired = maximum,
            percent = math.min(100, math.floor(100 * current / maximum)),
            finished = current >= maximum,
        }
    end

    local function addTextObjective(text)
        local obj = objectiveFromText(text, isRitualObjectiveText(text))
        if obj then
            objectives[#objectives+1] = obj
        end
    end

    local function addValueObjective(text, current, maximum)
        local obj = objectiveFromValues(text, current, maximum)
        if obj then
            objectives[#objectives+1] = obj
        end
    end

    local function addScenarioHeaderCurrency(currencyInfo)
        if type(currencyInfo) ~= "table" then return end
        local rawText = firstLine(currencyInfo.text)
        local valueText = rawText
        if valueText == "" then
            for _, key in ipairs({ "quantity", "count", "amount", "value" }) do
                local value = currencyInfo[key]
                if type(value) == "number" or type(value) == "string" then
                    valueText = cleanText(value)
                    break
                end
            end
        end
        if valueText == "" then return end

        local label = firstLine(currencyInfo.tooltip)
        local tooltip = tooltipText(currencyInfo.tooltip)
        local text = label ~= "" and (label .. ": " .. valueText) or valueText

        local iconFileID = currencyInfo.iconFileID

        objectives[#objectives+1] = {
            text = text,
            finished = false,
            isScenarioHeaderCurrency = true,
            scenarioHeaderCurrencyLabel = label,
            scenarioHeaderCurrencyValue = valueText,
            scenarioHeaderCurrencyTooltip = tooltip,
            iconFileID = iconFileID,
        }
    end

    local ok, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, setID)
    if not ok or not widgets then return objectives end

    for _, wInfo in pairs(widgets) do
        local widgetID = type(wInfo) == "table" and wInfo.widgetID or (type(wInfo) == "number" and wInfo)
        local wType = type(wInfo) == "table" and wInfo.widgetType or nil
        if widgetID then
            local handledHeaderCurrency = false
            if C_UIWidgetManager.GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo
                and (not wType or wType == WIDGET_SCENARIOHEADERCURRENCIES) then
                local hOk, hInfo = pcall(C_UIWidgetManager.GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo, widgetID)
                if hOk and hInfo and type(hInfo.currencies) == "table" then
                    for _, currencyInfo in ipairs(hInfo.currencies) do
                        addScenarioHeaderCurrency(currencyInfo)
                    end
                    handledHeaderCurrency = true
                end
            end

            -- Status Bar
            if not handledHeaderCurrency and (not wType or wType == WIDGET_STATUSBAR) then
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
            if not handledHeaderCurrency and (not wType or wType == WIDGET_ICONANDTEXT) then
                local iOk, iInfo = pcall(C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo, widgetID)
                if iOk and iInfo and iInfo.text and iInfo.text ~= "" then
                    addTextObjective(iInfo.text)
                end
            end

            -- Text widgets used by open-world objective widgets such as Ritual Sites.
            if not handledHeaderCurrency and (not wType or wType == WIDGET_TEXTWITHSTATE) then
                local tOk, tInfo = pcall(C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo, widgetID)
                if tOk and tInfo and tInfo.text and tInfo.text ~= "" then
                    addTextObjective(tInfo.text)
                end
            end

            if not handledHeaderCurrency and C_UIWidgetManager.GetTextureAndTextVisualizationInfo
                and (not wType or not WIDGET_TEXTUREANDTEXT or wType == WIDGET_TEXTUREANDTEXT) then
                local ttOk, ttInfo = pcall(C_UIWidgetManager.GetTextureAndTextVisualizationInfo, widgetID)
                if ttOk and ttInfo and ttInfo.text and ttInfo.text ~= "" then
                    addTextObjective(ttInfo.text)
                end
            end

            if not handledHeaderCurrency and C_UIWidgetManager.GetDoubleIconAndTextWidgetVisualizationInfo
                and (not wType or not WIDGET_DOUBLEICONANDTEXT or wType == WIDGET_DOUBLEICONANDTEXT) then
                local dOk, dInfo = pcall(C_UIWidgetManager.GetDoubleIconAndTextWidgetVisualizationInfo, widgetID)
                if dOk and dInfo then
                    addTextObjective(dInfo.leftText)
                    addTextObjective(dInfo.rightText)
                    addTextObjective(dInfo.label)
                end
            end

            if not handledHeaderCurrency and C_UIWidgetManager.GetTextWithSubtextWidgetVisualizationInfo
                and (not wType or not WIDGET_TEXTWITHSUBTEXT or wType == WIDGET_TEXTWITHSUBTEXT) then
                local tsOk, tsInfo = pcall(C_UIWidgetManager.GetTextWithSubtextWidgetVisualizationInfo, widgetID)
                if tsOk and tsInfo then
                    addTextObjective(tsInfo.text)
                    addTextObjective(tsInfo.subText)
                    if tsInfo.text and tsInfo.subText then
                        addTextObjective(tsInfo.text .. " " .. tsInfo.subText)
                    end
                end
            end

            if not handledHeaderCurrency and C_UIWidgetManager.GetTextColumnRowVisualizationInfo
                and (not wType or not WIDGET_TEXTCOLUMNROW or wType == WIDGET_TEXTCOLUMNROW) then
                local cOk, cInfo = pcall(C_UIWidgetManager.GetTextColumnRowVisualizationInfo, widgetID)
                if cOk and cInfo and type(cInfo.entries) == "table" then
                    for _, entry in ipairs(cInfo.entries) do
                        if type(entry) == "table" then
                            addTextObjective(entry.text)
                            addTextObjective(entry.subText)
                        end
                    end
                end
            end

            if not handledHeaderCurrency and C_UIWidgetManager.GetDiscreteProgressStepsVisualizationInfo
                and (not wType or not WIDGET_DISCRETEPROGRESS or wType == WIDGET_DISCRETEPROGRESS) then
                local dpOk, dpInfo = pcall(C_UIWidgetManager.GetDiscreteProgressStepsVisualizationInfo, widgetID)
                if dpOk and dpInfo then
                    local label = dpInfo.tooltip or dpInfo.text or dpInfo.overrideText
                    addValueObjective(label, dpInfo.progressVal, dpInfo.progressMax)
                end
            end

            if not handledHeaderCurrency and C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo
                and (not wType or not WIDGET_FILLUPFRAMES or wType == WIDGET_FILLUPFRAMES) then
                local fOk, fInfo = pcall(C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo, widgetID)
                if fOk and fInfo then
                    local label = fInfo.tooltip or fInfo.text or fInfo.overrideText
                    addValueObjective(label, fInfo.fillValue, fInfo.fillMax)
                end
            end
        end
    end
    return objectives
end

function BaseProvider:GetScenarioHeaderCurrenciesForTitle(objectives)
    local out = {}
    for _, obj in ipairs(objectives or {}) do
        if obj and obj.isScenarioHeaderCurrency and obj.iconFileID and obj.scenarioHeaderCurrencyValue then
            out[#out+1] = obj
        end
    end
    return #out > 0 and out or nil
end

function addon.FormatScenarioHeaderCurrenciesForTitle(currencies)
    if type(currencies) ~= "table" then return "" end
    local iconSize = tonumber(addon.DELVE_LIFE_EMBED_SIZE) or 13
    local parts = {}
    for _, currency in ipairs(currencies) do
        local iconFileID = currency and tonumber(currency.iconFileID)
        local value = currency and currency.scenarioHeaderCurrencyValue
        if iconFileID and iconFileID > 0 and value and value ~= "" then
            parts[#parts+1] = ("|T%d:%d:%d:0:-1|t %s"):format(iconFileID, iconSize, iconSize, value)
        end
    end
    return table.concat(parts, " ")
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
