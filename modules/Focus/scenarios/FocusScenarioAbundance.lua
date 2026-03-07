--[[
    Horizon Suite - Focus - Scenario Abundance Provider
    Specialized logic for Abundance (TWW open-world) scenarios.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

local AbundanceProvider = setmetatable({}, addon.FocusScenarioDefaultProvider or addon.FocusScenarioBaseProvider)
AbundanceProvider.__index = AbundanceProvider

function AbundanceProvider:New()
    return setmetatable({}, self)
end

local SCENARIO_TRACKER_WIDGET_SET = 252
local SCENARIO_TRACKER_TOP_WIDGET_SET = 514

function AbundanceProvider:ReadEntries()
    -- Use the default logic
    local entries = addon.FocusScenarioDefaultProvider.ReadEntries(self)
    
    -- Add Abundance-specific widget fallbacks for objectives like "Abundance Held"
    for _, entry in ipairs(entries) do
        if entry.isScenarioMain then
            entry.isAbundanceScenario = true
            
            local widgetObjs = self:ParseWidgetObjectives(SCENARIO_TRACKER_WIDGET_SET)
            for _, wo in ipairs(widgetObjs) do
                table.insert(entry.objectives, wo)
            end
            
            local topWidgetObjs = self:ParseWidgetObjectives(SCENARIO_TRACKER_TOP_WIDGET_SET)
            for _, wo in ipairs(topWidgetObjs) do
                table.insert(entry.objectives, wo)
            end
        end
    end
    
    return entries
end

addon.FocusScenarioRegistry:Register("ABUNDANCE", AbundanceProvider:New())
