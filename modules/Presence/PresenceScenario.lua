--[[
    Horizon Suite - Presence - Scenario
    Scenario/Delve/Dungeon notification toasts. SCENARIO_START, SCENARIO_UPDATE, SCENARIO_COMPLETE.
    APIs: C_ScenarioInfo, C_Scenario, addon.Presence.IsScenarioActive, addon.Presence.GetScenarioDisplayInfo.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.Presence then return end

local SCENARIO_DEBOUNCE = 0.4
local SCENARIO_UPDATE_BUFFER_TIME = 0.35

-- ============================================================================
-- State
-- ============================================================================

local wasInScenario = false
local scenarioCheckPending = false
local lastScenarioCriteriaCache = nil
local lastScenarioObjectives = nil
local lastScenarioTitle = nil
local lastScenarioCategory = nil
-- Cached delve name (set once on enter, used as primary; cleared on exit)
local cachedDelveName = nil

-- ============================================================================
-- Helpers
-- ============================================================================

local function Strip(s)
    return addon.Presence.Strip and addon.Presence.Strip(s) or (s or "")
end

local function FormatObjective(o)
    return (addon.Presence.FormatObjectiveForDisplay and addon.Presence.FormatObjectiveForDisplay(o)) or (o and o.text) or ""
end

--- Criterion was in the previous snapshot but missing from GetCriteriaInfo (step advanced / cleared).
--- Use full completion counts so we do not show stale 5/6 when the final tick removed the row from API.
--- @param oldO table Objective row from lastScenarioObjectives
--- @return string|nil
local function FormatObjectiveVanishedCompleted(oldO)
    if not oldO then return nil end
    if oldO.percent ~= nil and type(oldO.percent) == "number" then
        local synth = { text = oldO.text, percent = 100 }
        local s = FormatObjective(synth)
        if s and s ~= "" then return s end
    end
    if oldO.numRequired and type(oldO.numRequired) == "number" and oldO.numRequired > 0
        and oldO.numFulfilled ~= nil and type(oldO.numFulfilled) == "number" then
        if oldO.numFulfilled >= oldO.numRequired then
            return FormatObjective(oldO)
        end
        local synth = {
            text = oldO.text,
            quantityString = oldO.quantityString,
            finished = true,
            numFulfilled = oldO.numRequired,
            numRequired = oldO.numRequired,
        }
        local s = FormatObjective(synth)
        if s and s ~= "" then return s end
    end
    if oldO.numRequired == 1 and oldO.text and oldO.text ~= "" then
        return FormatObjective({ text = oldO.text, numFulfilled = 1, numRequired = 1, finished = true })
    end
    return FormatObjective(oldO)
end

--- Fix stale 0/X in objective text (Blizzard API lag on boss kill).
--- @param text string
--- @return string
local function FixStaleZeroProgress(text)
    if not text or text == "" then return text or "" end
    if not text:match("%s%(0/%d+%)$") then return text end
    local base, total = text:match("^(.+)%s%(0%)/(%d+)%)$")
    if not base or not total then return text end
    local n = tonumber(total)
    if n == 1 then
        return strtrim(base)
    end
    return ("%s (%d/%d)"):format(base, n, n)
end

local function ShouldSuppress()
    return addon.Presence.ShouldSuppressType and addon.Presence.ShouldSuppressType()
end

local function IsTypeEnabled(key, fallbackKey, fallbackDefault)
    return addon.Presence.IsTypeEnabled and addon.Presence.IsTypeEnabled(key, fallbackKey, fallbackDefault) or fallbackDefault
end

--- Resolve delve name: use cached value (primary) or resolve from APIs and cache on first success.
--- @return string|nil delve name
local function GetOrResolveDelveName()
    if cachedDelveName and cachedDelveName ~= "" then return cachedDelveName end
    local resolved = addon.GetDelveNameFromAPIs and addon.GetDelveNameFromAPIs()
    if not resolved or resolved == "" then
        local zone = (GetZoneText and GetZoneText()) or ""
        local sub = (GetSubZoneText and GetSubZoneText()) or ""
        if zone ~= "" and zone ~= "Delves" then resolved = zone
        elseif sub ~= "" and sub ~= "Delves" then resolved = sub end
    end
    if resolved and resolved ~= "" then
        cachedDelveName = resolved
    end
    return resolved
end

-- ============================================================================
-- GetMainStepCriteria
-- ============================================================================

--- Fetch main-step criteria from C_ScenarioInfo; build state key and objectives list.
--- Per Blizzard ScenarioInfoDocumentation: description, completed, quantity, totalQuantity, quantityString, criteriaID.
--- @return string|nil stateKey, table objectives
local function GetMainStepCriteria()
    local numCriteria
    if C_ScenarioInfo and C_ScenarioInfo.GetScenarioStepInfo then
        local stepInfo = C_ScenarioInfo.GetScenarioStepInfo()
        if stepInfo and stepInfo.numCriteria ~= nil then
            numCriteria = stepInfo.numCriteria
        end
    end
    if not numCriteria and C_Scenario and C_Scenario.GetStepInfo then
        local t = { pcall(C_Scenario.GetStepInfo) }
        if t[1] and t[2] then
            numCriteria = t[4] or t[3] or t[5]
        end
    end
    if not C_ScenarioInfo or (not C_ScenarioInfo.GetCriteriaInfo and not C_ScenarioInfo.GetCriteriaInfoByStep) then
        return nil, {}
    end
    local maxIdx = math.max((numCriteria or 0), 1) + 3
    local parts = {}
    local objectives = {}
    for criteriaIndex = 0, maxIdx do
        local cOk, criteriaInfo = false, nil
        if C_ScenarioInfo and C_ScenarioInfo.GetCriteriaInfo then
            cOk, criteriaInfo = pcall(C_ScenarioInfo.GetCriteriaInfo, criteriaIndex)
        end
        if (not cOk or not criteriaInfo) and C_ScenarioInfo and C_ScenarioInfo.GetCriteriaInfoByStep then
            cOk, criteriaInfo = pcall(C_ScenarioInfo.GetCriteriaInfoByStep, 1, criteriaIndex)
        end
        if cOk and criteriaInfo then
            local text = (criteriaInfo.description and criteriaInfo.description ~= "") and criteriaInfo.description
                or (criteriaInfo.quantityString and criteriaInfo.quantityString ~= "") and criteriaInfo.quantityString or ""
            local finished = criteriaInfo.complete or criteriaInfo.completed or false
            local qty = criteriaInfo.quantity
            local total = criteriaInfo.totalQuantity
            local isWeighted = criteriaInfo.isWeightedProgress == true
            local percent = nil
            local numFulfilled, numRequired, quantityString = nil, nil, nil
            if isWeighted and qty ~= nil and type(qty) == "number" then
                percent = math.min(100, math.max(0, math.floor(qty)))
            else
                local hasQty = qty ~= nil and total ~= nil and type(qty) == "number" and type(total) == "number" and total > 0
                numFulfilled = hasQty and qty or nil
                numRequired = hasQty and total or nil
                quantityString = (criteriaInfo.quantityString and criteriaInfo.quantityString ~= "") and criteriaInfo.quantityString or nil
            end
            local criteriaID = (criteriaInfo.criteriaID ~= nil) and criteriaInfo.criteriaID or criteriaIndex
            parts[#parts + 1] = (text or "") .. "|" .. (finished and "1" or "0") .. "|" .. (percent ~= nil and percent or numFulfilled or "") .. "|" .. (numRequired or "")
            objectives[#objectives + 1] = {
                criteriaID = criteriaID,
                text = text ~= "" and text or nil,
                quantityString = quantityString,
                finished = finished,
                numFulfilled = numFulfilled,
                numRequired = numRequired,
                percent = percent,
            }
        end
    end
    return table.concat(parts, ";"), objectives
end

-- ============================================================================
-- ExecuteScenarioCriteriaUpdate
-- ============================================================================

local function ExecuteScenarioCriteriaUpdate()
    if not addon.Presence.IsScenarioActive or not addon.Presence.IsScenarioActive() then return end
    if ShouldSuppress() then return end
    if addon.GetDB and not addon.GetDB("showScenarioEvents", true) then return end
    if not IsTypeEnabled("presenceScenarioUpdate", "showScenarioEvents", true) then return end
    if not addon.Presence.GetScenarioDisplayInfo then return end

    local stateKey, objectives = GetMainStepCriteria()
    if not stateKey or stateKey == "" then return end

    if lastScenarioCriteriaCache == stateKey then return end

    local oldObjectives = lastScenarioObjectives
    lastScenarioCriteriaCache = stateKey
    lastScenarioObjectives = objectives

    local msg = nil
    if oldObjectives and #oldObjectives > 0 then
        local oldByID, newByID = {}, {}
        for _, o in ipairs(oldObjectives) do
            if o.criteriaID ~= nil then oldByID[o.criteriaID] = o end
        end
        for _, o in ipairs(objectives) do
            if o.criteriaID ~= nil then newByID[o.criteriaID] = o end
        end

        for id, newO in pairs(newByID) do
            local oldO = oldByID[id]
            if oldO and not oldO.finished and newO.finished then
                msg = FormatObjective(newO)
                break
            end
        end
        if not msg then
            for id, newO in pairs(newByID) do
                local oldO = oldByID[id]
                local progressed = (oldO and (oldO.numFulfilled ~= newO.numFulfilled or oldO.percent ~= newO.percent))
                if progressed then
                    msg = FormatObjective(newO)
                    break
                end
            end
        end
        if not msg then
            for id, oldO in pairs(oldByID) do
                if not oldO.finished and not newByID[id] then
                    msg = FormatObjectiveVanishedCompleted(oldO)
                    break
                end
            end
        end
        if not msg then
            for id, newO in pairs(newByID) do
                if not oldByID[id] then
                    msg = FormatObjective(newO)
                    break
                end
            end
        end
    end
    if not msg and oldObjectives then
        for i = 1, #objectives do
            local oldO = oldObjectives[i]
            local newO = objectives[i]
            if oldO and newO then
                local progressed = (oldO.numFulfilled ~= newO.numFulfilled or oldO.percent ~= newO.percent)
                local finished = (not oldO.finished and newO.finished)
                local textChanged = (oldO.text ~= newO.text)
                if finished or progressed then
                    msg = FormatObjective(newO)
                    break
                elseif textChanged and not oldO.finished then
                    msg = FormatObjective(oldO) or FormatObjective(newO)
                    break
                end
            elseif not oldO and newO then
                msg = FormatObjective(newO)
                break
            end
        end
    end
    if not msg then
        for i = 1, #objectives do
            local o = objectives[i]
            if o and not o.finished then
                msg = FormatObjective(o)
                if msg then break end
            end
        end
    end
    if not msg and #objectives > 0 then
        msg = FormatObjective(objectives[1])
    end
    if not msg or msg == "" or msg == "0" then msg = "Objective updated" end
    msg = FixStaleZeroProgress(msg)

    local title, _, category = addon.Presence.GetScenarioDisplayInfo()
    -- Delve-specific: replace generic "Delves"/"Delve" with actual delve name (cached on enter, primary source)
    if category == "DELVES" and (not title or title == "Delves" or title == "Delve" or title:match("^Delves - Tier ")) then
        local resolvedName = GetOrResolveDelveName()
        if resolvedName and resolvedName ~= "" then
            local tier = title and title:match("Tier (%d+)")
            title = tier and (resolvedName .. " - Tier " .. tier) or resolvedName
        end
    end
    addon.Presence.QueueOrPlay("SCENARIO_UPDATE", Strip(title or "Scenario"), Strip(msg), { category = category or "SCENARIO", source = "SCENARIO_CRITERIA_UPDATE" })
end

local function RequestScenarioCriteriaUpdate()
    if addon.Presence.RequestDebounced then
        addon.Presence.RequestDebounced("scenario", SCENARIO_UPDATE_BUFFER_TIME, ExecuteScenarioCriteriaUpdate)
    end
end

-- ============================================================================
-- TryShowScenarioStart
-- ============================================================================

local function TryShowScenarioStart()
    if scenarioCheckPending then return end
    if not addon.Presence.IsScenarioActive or not addon.Presence.IsScenarioActive() then return end
    if wasInScenario then return end
    -- Delves: return without seeding. TryShowScenarioStart seeds lastScenarioCriteriaCache,
    -- which would cause ExecuteScenarioCriteriaUpdate to see a cache match and skip the popup.
    if addon.IsDelveActive and addon.IsDelveActive() then return end
    if ShouldSuppress() then return end
    if addon.GetDB and not addon.GetDB("showScenarioEvents", true) then return end
    if not IsTypeEnabled("presenceScenarioStart", "showScenarioEvents", true) then return end
    if not addon.Presence.GetScenarioDisplayInfo then return end

    scenarioCheckPending = true
    C_Timer.After(SCENARIO_DEBOUNCE, function()
        scenarioCheckPending = false
        if not addon:IsModuleEnabled("presence") then return end
        if not addon.Presence.IsScenarioActive or not addon.Presence.IsScenarioActive() then return end
        if wasInScenario then return end
        if addon.GetDB and not addon.GetDB("showScenarioEvents", true) then return end
        if not IsTypeEnabled("presenceScenarioStart", "showScenarioEvents", true) then return end

        local title, subtitle, category = addon.Presence.GetScenarioDisplayInfo()
        if not title or title == "" then return end

        wasInScenario = true
        lastScenarioTitle = title
        lastScenarioCategory = category
        local seedKey, seedObjs = GetMainStepCriteria()
        if seedKey then
            lastScenarioCriteriaCache = seedKey
            lastScenarioObjectives = seedObjs
        end
        if addon.Presence.ApplyBlizzardSuppression then addon.Presence.ApplyBlizzardSuppression() end
        addon.Presence.QueueOrPlay("SCENARIO_START", Strip(title), Strip(subtitle or ""), { category = category, source = "SCENARIO_UPDATE" })
    end)
end

-- ============================================================================
-- OnScenarioCompleted
-- ============================================================================

local function OnScenarioCompleted()
    if lastScenarioTitle and addon.GetDB and addon.GetDB("showScenarioEvents", true)
       and IsTypeEnabled("presenceScenarioComplete", "showScenarioEvents", true) then
        local title = lastScenarioTitle
        local category = lastScenarioCategory or "SCENARIO"
        local L = addon.L or {}
        local subtitle
        if lastScenarioObjectives and #lastScenarioObjectives > 0 then
            for i = #lastScenarioObjectives, 1, -1 do
                local o = lastScenarioObjectives[i]
                if o.text and o.text ~= "" then
                    subtitle = FormatObjective(o)
                    break
                end
            end
        end
        if not subtitle or subtitle == "" then
            subtitle = (L["PRESENCE_SCENARIO_COMPLETE"] and L["PRESENCE_SCENARIO_COMPLETE"] ~= "") and L["PRESENCE_SCENARIO_COMPLETE"] or "Scenario Complete"
        end
        if subtitle and subtitle ~= "" then
            subtitle = FixStaleZeroProgress(subtitle)
        end
        if category == "DELVES" then
            local delveComplete = (L["FOCUS_DELVE_COMPLETE"] and L["FOCUS_DELVE_COMPLETE"] ~= "") and L["FOCUS_DELVE_COMPLETE"] or "Delve Complete"
            title = delveComplete
            if not subtitle or subtitle == "" or subtitle == (L["PRESENCE_SCENARIO_COMPLETE"] or "Scenario Complete") then
                local origTitle = lastScenarioTitle
                if not origTitle or origTitle == "Delves" or origTitle:match("^Delves - Tier ") then
                    local resolvedName = GetOrResolveDelveName()
                    if resolvedName and resolvedName ~= "" then
                        local tier = origTitle and origTitle:match("Tier (%d+)")
                        subtitle = tier and (resolvedName .. " - Tier " .. tier) or resolvedName
                    else
                        local tier = origTitle and origTitle:match("Tier (%d+)")
                        subtitle = tier and ("Tier " .. tier) or delveComplete
                    end
                else
                    subtitle = origTitle
                end
            end
        end
        addon.Presence.QueueOrPlay("SCENARIO_COMPLETE", Strip(title), Strip(subtitle), { category = category, source = "SCENARIO_COMPLETED" })
    end
    wasInScenario = false
    lastScenarioCriteriaCache = nil
    lastScenarioObjectives = nil
    lastScenarioTitle = nil
    lastScenarioCategory = nil
    cachedDelveName = nil
    if addon.Presence.CancelDebounced then
        addon.Presence.CancelDebounced("scenario")
    end
end

-- ============================================================================
-- OnScenarioInit (called from PresenceEvents OnPlayerEnteringWorld)
-- ============================================================================

function addon.Presence.Scenario_OnInit()
    if addon.Presence._scenarioInitDone then return end
    addon.Presence._scenarioInitDone = true
    lastScenarioTitle = nil
    lastScenarioCategory = nil
    local inScenario = addon.Presence.IsScenarioActive and addon.Presence.IsScenarioActive()
    if inScenario and addon.IsDelveActive and addon.IsDelveActive() then
        GetOrResolveDelveName() -- seed cache when loading mid-delve
        if addon.Presence.GetScenarioDisplayInfo then
            local title, subtitle, category = addon.Presence.GetScenarioDisplayInfo()
            if title and title ~= "" then
                lastScenarioTitle = title
                lastScenarioCategory = category
                local seedKey, seedObjs = GetMainStepCriteria()
                if seedKey and seedKey ~= "" then
                    lastScenarioCriteriaCache = seedKey
                    lastScenarioObjectives = seedObjs
                end
            end
        end
        inScenario = false
    end
    wasInScenario = inScenario
    if inScenario and addon.Presence.GetScenarioDisplayInfo then
        local title, subtitle, category = addon.Presence.GetScenarioDisplayInfo()
        if title and title ~= "" then
            lastScenarioTitle = title
            lastScenarioCategory = category
        end
        local seedKey, seedObjs = GetMainStepCriteria()
        if seedKey and seedKey ~= "" then
            lastScenarioCriteriaCache = seedKey
            lastScenarioObjectives = seedObjs
        end
    end
end

-- ============================================================================
-- Event handlers (called by PresenceEvents)
-- ============================================================================

function addon.Presence.Scenario_OnScenarioUpdate()
    if IsTypeEnabled("presenceScenarioStart", "showScenarioEvents", true) or IsTypeEnabled("presenceScenarioUpdate", "showScenarioEvents", true) then
        if addon.Presence.ApplyBlizzardSuppression then addon.Presence.ApplyBlizzardSuppression() end
    end
    TryShowScenarioStart()
end

function addon.Presence.Scenario_OnScenarioCriteriaUpdate()
    if addon.IsDelveActive and addon.IsDelveActive() then
        if addon.GetDB and addon.GetDB("presenceSuppressInDelve", false) then return end
        if IsTypeEnabled("presenceScenarioStart", "showScenarioEvents", true) or IsTypeEnabled("presenceScenarioUpdate", "showScenarioEvents", true) then
            if addon.Presence.ApplyBlizzardSuppression then addon.Presence.ApplyBlizzardSuppression() end
        end
        -- Do not call TryShowScenarioStart: it seeds lastScenarioCriteriaCache with current state,
        -- which would cause ExecuteScenarioCriteriaUpdate to see a cache match and skip the popup.
        RequestScenarioCriteriaUpdate()
        return
    end
    if IsTypeEnabled("presenceScenarioStart", "showScenarioEvents", true) or IsTypeEnabled("presenceScenarioUpdate", "showScenarioEvents", true) then
        if addon.Presence.ApplyBlizzardSuppression then addon.Presence.ApplyBlizzardSuppression() end
    end
    TryShowScenarioStart()
    if wasInScenario then
        RequestScenarioCriteriaUpdate()
    end
end

function addon.Presence.Scenario_OnScenarioCompleted()
    OnScenarioCompleted()
end
