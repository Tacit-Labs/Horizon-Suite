--[[
    Horizon Suite - Focus - Scenario Delve Provider
    Specialized logic for Delves scenarios.
]]

local addon = _G.HorizonSuite

local DelveProvider = setmetatable({}, addon.FocusScenarioDefaultProvider or addon.FocusScenarioBaseProvider)
DelveProvider.__index = DelveProvider

function DelveProvider:New()
    return setmetatable({}, self)
end

function DelveProvider:GetDisplayInfo()
    -- Read zone/subzone text directly like Vista — no IsDelveActive() guard so name persists on completion.
    local sub  = (GetSubZoneText and GetSubZoneText()) or ""
    local zone = (GetZoneText  and GetZoneText())  or ""
    local title = (sub  ~= "" and sub  ~= "Delves") and sub
               or (zone ~= "" and zone ~= "Delves") and zone
               or (addon.GetDelveNameFromAPIs and addon.GetDelveNameFromAPIs())
               or "Delve"
    local tier = addon.GetActiveDelveTier and addon.GetActiveDelveTier()
    if tier then
        title = string.format("%s - Tier %d", title, tier)
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
    -- Lives + life icon from ScenarioHeaderDelves widget (same pass as affixes); main row only.
    -- Nemesis enemy groups / bonus chest count: affix spell stackDisplay / description first,
    -- then currency runs, then sibling widgets in the same widget set.
    if addon.GetDelveScenarioHeaderMetadata then
        local meta = addon.GetDelveScenarioHeaderMetadata()
        if meta then
            for _, entry in ipairs(entries) do
                if entry.isScenarioMain and entry.category == "DELVES" then
                    if meta.livesRemaining ~= nil then
                        entry.delveLivesRemaining = meta.livesRemaining
                        if type(meta.livesIconFileID) == "number" and meta.livesIconFileID > 0 then
                            entry.delveLivesIconFileID = meta.livesIconFileID
                        end
                    end
                    if meta.nemesisHasData then
                        entry.delveNemesisRemaining = meta.nemesisGroupsRemaining
                        entry.delveNemesisTotal = meta.nemesisGroupsTotal
                        entry.delveNemesisComplete = meta.nemesisIsComplete
                    end
                    break
                end
            end
        end
    end
    -- Override scenario-main title with the actual delve name.
    -- Read zone/subzone text directly like Vista does — no IsDelveActive() guard,
    -- so this persists on the reward stage when IsDelveActive() may return false.
    local sub  = (GetSubZoneText and GetSubZoneText()) or ""
    local zone = (GetZoneText  and GetZoneText())  or ""
    local delveName = (sub  ~= "" and sub  ~= "Delves") and sub
                   or (zone ~= "" and zone ~= "Delves") and zone
                   or (addon.GetDelveNameFromAPIs and addon.GetDelveNameFromAPIs())
    if delveName and delveName ~= "" then
        for _, entry in ipairs(entries) do
            if entry.isScenarioMain and entry.category == "DELVES" then
                entry.title = delveName
                break
            end
        end
    end
    return entries
end

addon.FocusScenarioRegistry:Register("DELVES", DelveProvider:New())
