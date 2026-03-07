--[[
    Horizon Suite - Focus - Scenario Delve Provider
    Specialized logic for Delves scenarios.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

local DelveProvider = setmetatable({}, addon.FocusScenarioDefaultProvider or addon.FocusScenarioBaseProvider)
DelveProvider.__index = DelveProvider

function DelveProvider:New()
    return setmetatable({}, self)
end

function DelveProvider:GetDisplayInfo()
    local title = addon.GetDelveNameFromAPIs and addon.GetDelveNameFromAPIs() or "Delve"
    local tier = addon.GetActiveDelveTier and addon.GetActiveDelveTier()
    if tier then
        title = string.format("%s (Tier %d)", title, tier)
    end
    
    local ok, stageName = pcall(C_Scenario.GetStepInfo)
    return title, stageName or "", "DELVES"
end

function DelveProvider:ReadEntries()
    -- Use the default logic but ensure category is DELVES and color is correct.
    -- DefaultProvider already handles isDelve check for category/color.
    local entries = (self.super and self.super.ReadEntries or addon.FocusScenarioDefaultProvider.ReadEntries)(self)
    local tier = addon.GetActiveDelveTier and addon.GetActiveDelveTier()
    if tier then
        for _, entry in ipairs(entries) do
            entry.delveTier = tier
        end
    end
    return entries
end

addon.FocusScenarioRegistry:Register("DELVES", DelveProvider:New())
