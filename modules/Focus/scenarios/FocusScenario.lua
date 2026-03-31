--[[
    Horizon Suite - Focus - Scenario Interface
    Central entry point for scenario data, delegating to specialized providers.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- ============================================================================
-- SCENARIO UTILS
-- ============================================================================

local function IsScenarioActive()
    if addon.IsWorldScenario and addon.IsWorldScenario() then return true end
    local ok, name, currentStage = pcall(C_Scenario.GetInfo)
    if ok and ((name and name ~= "") or (currentStage and currentStage > 0)) then
        return true
    end
    return false
end

-- Short TTL cache: ReadTrackedQuests / SortAndGroupQuests call ReadScenarioEntries multiple times per layout.
-- Invalidated on scenario step changes (see InvalidateScenarioEntriesCache from FocusEvents).
local SCENARIO_ENTRIES_CACHE_TTL = 0.12
local scenarioEntriesCache = nil
local scenarioEntriesCacheTime = 0

-- Clears ReadScenarioEntries TTL cache; FocusEvents calls this on scenario step changes.
local function InvalidateScenarioEntriesCache()
    scenarioEntriesCache = nil
    scenarioEntriesCacheTime = 0
end

-- ============================================================================
-- INTERFACE METHODS
-- ============================================================================

--- Get display info for Presence scenario-start toast.
--- @return title, subtitle, category or nil, nil, nil
local function GetScenarioDisplayInfo()
    if not IsScenarioActive() then return nil, nil, nil end
    local provider = addon.FocusScenarioRegistry:GetProvider()
    if provider and provider.GetDisplayInfo then
        return provider:GetDisplayInfo()
    end
    return "Scenario", "", "SCENARIO"
end

--- Build tracker rows from active scenario.
--- @return table Array of normalized entry tables for the tracker
local function ReadScenarioEntries()
    if not IsScenarioActive() then
        InvalidateScenarioEntriesCache()
        return {}
    end
    local now = GetTime()
    if scenarioEntriesCache and (now - scenarioEntriesCacheTime) < SCENARIO_ENTRIES_CACHE_TTL then
        return scenarioEntriesCache
    end
    local provider = addon.FocusScenarioRegistry:GetProvider()
    local out = {}
    if provider and provider.ReadEntries then
        out = provider:ReadEntries()
    end
    scenarioEntriesCache = out
    scenarioEntriesCacheTime = now
    return out
end

--- Debug tool to dump scenario timer info.
local function DumpScenarioTimerInfo()
    local HSPrint = addon.HSPrint or function(m) print("|cFF00CCFFHorizon Suite:|r " .. tostring(m or "")) end
    HSPrint("|cFF00CCFF--- Scenario Timer Debug ---|r")
    
    if not IsScenarioActive() then
        HSPrint("Not in a scenario.")
        return
    end

    local provider = addon.FocusScenarioRegistry:GetProvider()
    HSPrint("Current Provider: " .. (provider and (provider == addon.FocusScenarioDefaultProvider and "Default" or "Specialized") or "None"))
    
    -- Logic for deeper debug could be added here or in providers
    HSPrint("Check providers for specific timer parsing.")
end

-- ============================================================================
-- EXPORTS
-- ============================================================================

addon.ReadScenarioEntries      = ReadScenarioEntries
addon.IsScenarioActive         = IsScenarioActive
addon.GetScenarioDisplayInfo   = GetScenarioDisplayInfo
addon.DumpScenarioTimerInfo    = DumpScenarioTimerInfo

--- Drop cached scenario rows so the next ReadScenarioEntries rebuilds from APIs.
--- @return nil
addon.InvalidateScenarioEntriesCache = InvalidateScenarioEntriesCache
