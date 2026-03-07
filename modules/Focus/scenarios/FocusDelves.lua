--[[
    Horizon Suite - Focus - Delve Provider
    ScenarioHeaderDelvesWidget (tierText), C_PartyInfo.IsDelveInProgress.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

local TIER_MIN, TIER_MAX = 1, 12
-- Scenario step widget set contains Delve header; Objective Tracker set may not when tracker is hidden.
local WIDGET_TYPE_SCENARIO_HEADER_DELVES = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.ScenarioHeaderDelves) or 29

-- Get spell name and icon; supports both legacy GetSpellInfo and C_Spell.GetSpellInfo.
local function GetSpellNameAndIcon(spellID)
    if type(spellID) ~= "number" or spellID <= 0 then return nil, nil end
    if GetSpellInfo and type(GetSpellInfo) == "function" then
        local name, _, icon = GetSpellInfo(spellID)
        return name, icon
    end
    if C_Spell and C_Spell.GetSpellInfo then
        local ok, info = pcall(C_Spell.GetSpellInfo, spellID)
        if ok and info and type(info) == "table" then
            return info.name, info.iconID
        end
    end
    return nil, nil
end

--- True when the player is in an active Delve (guarded API).
local function IsDelveActive()
    if C_PartyInfo and C_PartyInfo.IsDelveInProgress then
        local ok, inDelve = pcall(C_PartyInfo.IsDelveInProgress)
        if ok and inDelve then return true end
    end
    return false
end

--- Current Delve tier (1-12) or nil if unknown/not in delve. Guarded API.
--- Uses ScenarioHeaderDelvesWidget tierText (always available inside an active delve).
local function GetActiveDelveTier()
    if not IsDelveActive() then return nil end

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
                for _, wInfo in pairs(widgets) do
                    local widgetID = (wInfo and type(wInfo) == "table" and type(wInfo.widgetID) == "number") and wInfo.widgetID
                        or (type(wInfo) == "number" and wInfo > 0) and wInfo
                    local wType = (wInfo and type(wInfo) == "table") and wInfo.widgetType
                    if widgetID and (not wType or wType == WIDGET_TYPE_SCENARIO_HEADER_DELVES) then
                        local dOk, widgetInfo = pcall(C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo, widgetID)
                        if dOk and widgetInfo and type(widgetInfo) == "table" then
                            local tierText = widgetInfo.tierText
                            if tierText and type(tierText) == "string" and tierText ~= "" then
                                local tier = tonumber(tierText:match("%d+"))
                                if tier and tier >= TIER_MIN and tier <= TIER_MAX then
                                    return tier
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return nil
end

--- Returns nearby quests on the delve map when in a Delve. Only adds quests whose map matches player map.
local function CollectDelveQuests(ctx)
    if not IsDelveActive() then return {} end
    local playerMapID = (C_Map and C_Map.GetBestMapForUnit) and C_Map.GetBestMapForUnit("player") or nil
    local mapInfo = (playerMapID and C_Map and C_Map.GetMapInfo) and C_Map.GetMapInfo(playerMapID) or nil
    local mapType = mapInfo and mapInfo.mapType
    local isInstanceMap = (mapType == 4 or mapType == 5)  -- 4 = Dungeon, 5 = Micro (Delve)
    if not playerMapID or not isInstanceMap then return {} end

    local out = {}
    local nearbySet = ctx.nearbySet or {}
    local seen = ctx.seen or {}
    for questID, _ in pairs(nearbySet) do
        if not seen[questID] and not addon.IsQuestWorldQuest(questID) then
            if not (C_QuestLog.IsQuestCalling and C_QuestLog.IsQuestCalling(questID)) then
                -- Only show quests the player actually has in their log
                local logIdx = C_QuestLog.GetLogIndexForQuestID(questID)
                if logIdx then
                    local info = C_QuestLog.GetInfo and C_QuestLog.GetInfo(logIdx)
                    if info and not info.isHidden then
                        out[#out + 1] = { questID = questID, opts = { isTracked = false, forceCategory = "DELVES" } }
                    end
                end
            end
        end
    end
    return out
end

--- Returns season affixes for the current Delve when in an active Delve, or nil.
--- Used by the quest block to show affixes inline. Tries UI Widget (Blizzard's source) first,
--- then C_DelvesUI.GetDelvesAffixSpellsForSeason. May return nil/empty when Blizzard's
--- objective tracker is hidden (Horizon replaces it) as widgets may not be populated.
--- @return table|nil Array of { name, desc, icon } or nil if not in Delve or no affixes
local function GetDelvesAffixes()
    if not IsDelveActive() then return nil end

    local affixes = {}

    -- Primary: UI Widget. Use scenario step widget set (C_Scenario.GetStepInfo) first —
    -- it contains the Delve header with affixes. Objective Tracker set may not when tracker is hidden.
    local WidgetShownState = Enum and Enum.WidgetShownState
    if C_UIWidgetManager and C_UIWidgetManager.GetAllWidgetsBySetID and C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo then
        local setID
        if C_Scenario and C_Scenario.GetStepInfo then
            local ok, t = pcall(function()
                return { C_Scenario.GetStepInfo() }
            end)
            if ok and t and type(t) == "table" and #t >= 12 then
                local ws = t[12]
                if type(ws) == "number" and ws ~= 0 then setID = ws end
            end
        end
        if not setID and C_UIWidgetManager.GetObjectiveTrackerWidgetSetID then
            local ok, objSet = pcall(C_UIWidgetManager.GetObjectiveTrackerWidgetSetID)
            if ok and objSet and type(objSet) == "number" then setID = objSet end
        end
        if setID then
            local wOk, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, setID)
            if wOk and widgets and type(widgets) == "table" then
                for _, wInfo in pairs(widgets) do
                    local widgetID = (wInfo and type(wInfo) == "table" and type(wInfo.widgetID) == "number") and wInfo.widgetID
                        or (type(wInfo) == "number" and wInfo > 0) and wInfo
                    local wType = (wInfo and type(wInfo) == "table") and wInfo.widgetType
                    if widgetID and (not wType or wType == WIDGET_TYPE_SCENARIO_HEADER_DELVES) then
                        local dOk, widgetInfo = pcall(C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo, widgetID)
                        if dOk and widgetInfo and type(widgetInfo) == "table" then
                            local hidden = WidgetShownState and (widgetInfo.shownState == WidgetShownState.Hidden)
                            if not hidden then
                                local tierSpellID = widgetInfo.tierTooltipSpellID
                                if widgetInfo.spells and #widgetInfo.spells > 0 then
                                    for _, spellInfo in ipairs(widgetInfo.spells) do
                                        if spellInfo and type(spellInfo.spellID) == "number" and spellInfo.spellID > 0 then
                                            local name = (spellInfo.text and spellInfo.text ~= "") and spellInfo.text or nil
                                            local icon
                                            if not name then
                                                name, icon = GetSpellNameAndIcon(spellInfo.spellID)
                                            else
                                                _, icon = GetSpellNameAndIcon(spellInfo.spellID)
                                            end
                                            local desc = (spellInfo.tooltip and spellInfo.tooltip ~= "") and spellInfo.tooltip or nil
                                            if not desc and C_Spell and C_Spell.GetSpellDescription then
                                                local spellDescOk, d = pcall(C_Spell.GetSpellDescription, spellInfo.spellID)
                                                if spellDescOk and d and type(d) == "string" and d ~= "" then desc = d end
                                            end
                                            affixes[#affixes + 1] = {
                                                name  = name or ("Spell " .. spellInfo.spellID),
                                                desc  = desc or "",
                                                icon  = icon,
                                            }
                                        end
                                    end
                                end
                                return affixes, tierSpellID
                            end
                        end
                    end
                end
            end
        end
    end

    -- Fallback: C_DelvesUI.GetDelvesAffixSpellsForSeason
    if C_DelvesUI and C_DelvesUI.GetDelvesAffixSpellsForSeason then
        local ok, spellIDs = pcall(C_DelvesUI.GetDelvesAffixSpellsForSeason)
        if ok and spellIDs and type(spellIDs) == "table" then
            for _, spellID in pairs(spellIDs) do
                if type(spellID) == "number" and spellID > 0 then
                    local name, spellIcon = GetSpellNameAndIcon(spellID)
                    local desc = nil
                    if C_Spell and C_Spell.GetSpellDescription then
                        local dOk, d = pcall(C_Spell.GetSpellDescription, spellID)
                        if dOk and d and type(d) == "string" then desc = d end
                    end
                    affixes[#affixes + 1] = {
                        name  = (name and name ~= "") and name or ("Spell " .. spellID),
                        desc  = desc or "",
                        icon  = spellIcon,
                    }
                end
            end
        end
    end

    return (#affixes > 0) and affixes or nil, nil
end

--- Returns the name of the current Delve via C_Scenario.GetInfo.
local function GetDelveNameFromAPIs()
    if not IsDelveActive() then return nil end
    local ok, name = pcall(C_Scenario.GetInfo)
    if ok and name and name ~= "" then return name end
    return nil
end

addon.IsDelveActive        = IsDelveActive
addon.GetActiveDelveTier   = GetActiveDelveTier
addon.GetDelveNameFromAPIs  = GetDelveNameFromAPIs
addon.CollectDelveQuests   = CollectDelveQuests
addon.GetDelvesAffixes     = GetDelvesAffixes
