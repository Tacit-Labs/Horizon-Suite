--[[
    Horizon Suite - Focus - Delve Provider
    ScenarioHeaderDelvesWidget (tierText, currencies, spells), C_PartyInfo.IsDelveInProgress, C_QuestLog.GetQuestTagInfo (QuestTag.Delve).
    Lives remaining: parsed from widget currencies (per-slot textEnabledState or numeric text).
    Nemesis enemy groups: second contiguous currency run (different icon than hearts), or FillUpFrames / IconAndText / DiscreteProgress sibling widgets in the same widget set — see ParseNemesis* helpers below.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- Scenario step widget set contains Delve header; Objective Tracker set may not when tracker is hidden.
local WIDGET_TYPE_SCENARIO_HEADER_DELVES = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.ScenarioHeaderDelves) or 29

-- Sanity cap for Nemesis group counts (matches lives cap in ParseDelveLivesRemaining).
local NEMESIS_GROUPS_MAX = 30

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

--- All distinct UI widget set IDs that can carry the delve header (step set and objective-tracker set often differ).
--- @return number[]
local function GetAllDelveScenarioWidgetSetIDs()
    local ids = {}
    local seen = {}
    local function add(id)
        if type(id) == "number" and id ~= 0 and not seen[id] then
            seen[id] = true
            ids[#ids + 1] = id
        end
    end
    if C_Scenario and C_Scenario.GetStepInfo then
        local ok, t = pcall(function()
            return { C_Scenario.GetStepInfo() }
        end)
        if ok and t and type(t) == "table" and #t >= 12 then
            add(t[12])
        end
    end
    if C_UIWidgetManager and C_UIWidgetManager.GetObjectiveTrackerWidgetSetID then
        local ok, objSet = pcall(C_UIWidgetManager.GetObjectiveTrackerWidgetSetID)
        if ok then add(objSet) end
    end
    return ids
end

--- Widget set ID from scenario step (preferred) or objective tracker fallback.
--- @return number|nil setID
local function GetDelveScenarioWidgetSetID()
    local all = GetAllDelveScenarioWidgetSetIDs()
    return all[1]
end

--- Visible ScenarioHeaderDelves widget info tables for one set (may be multiple widgets per set).
--- @param setID number
--- @return table[] array of widgetInfo
local function CollectVisibleScenarioHeaderDelvesInfos(setID)
    local list = {}
    if not (setID and C_UIWidgetManager and C_UIWidgetManager.GetAllWidgetsBySetID and C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo) then
        return list
    end
    local wOk, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, setID)
    if not wOk or type(widgets) ~= "table" then return list end
    local WidgetShownState = Enum and Enum.WidgetShownState
    for _, wInfo in pairs(widgets) do
        local widgetID = (wInfo and type(wInfo) == "table" and type(wInfo.widgetID) == "number") and wInfo.widgetID
            or (type(wInfo) == "number" and wInfo > 0) and wInfo
        local wType = (wInfo and type(wInfo) == "table") and wInfo.widgetType
        if widgetID and (not wType or wType == WIDGET_TYPE_SCENARIO_HEADER_DELVES) then
            local dOk, widgetInfo = pcall(C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo, widgetID)
            if dOk and widgetInfo and type(widgetInfo) == "table" then
                local hidden = WidgetShownState and (widgetInfo.shownState == WidgetShownState.Hidden)
                if not hidden then
                    list[#list + 1] = widgetInfo
                end
            end
        end
    end
    return list
end

--- Every visible ScenarioHeaderDelves widget across step + objective tracker sets (deduped by widgetID).
--- @return table[], table  infos, widgetIDSeen
local function CollectAllVisibleScenarioHeaderDelvesInfosDeduped()
    local out = {}
    local seen = {}
    if not (C_UIWidgetManager and C_UIWidgetManager.GetAllWidgetsBySetID and C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo) then
        return out, seen
    end
    for _, setID in ipairs(GetAllDelveScenarioWidgetSetIDs()) do
        local wOk, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, setID)
        if wOk and type(widgets) == "table" then
            local WidgetShownState = Enum and Enum.WidgetShownState
            for _, wInfo in pairs(widgets) do
                local widgetID = (wInfo and type(wInfo) == "table" and type(wInfo.widgetID) == "number") and wInfo.widgetID
                    or (type(wInfo) == "number" and wInfo > 0) and wInfo
                local wType = (wInfo and type(wInfo) == "table") and wInfo.widgetType
                if widgetID and not seen[widgetID] and (not wType or wType == WIDGET_TYPE_SCENARIO_HEADER_DELVES) then
                    if C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo then
                        local dOk, widgetInfo = pcall(C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo, widgetID)
                        if dOk and widgetInfo and type(widgetInfo) == "table" then
                            local hidden = WidgetShownState and (widgetInfo.shownState == WidgetShownState.Hidden)
                            if not hidden then
                                seen[widgetID] = true
                                out[#out + 1] = widgetInfo
                            end
                        end
                    end
                end
            end
        end
    end
    return out, seen
end

--- True when delve widgets should be read: active delve, or reward stage on micro (Delve) map only.
--- (Map type 4 is also "Dungeon" for regular instances — do not read scenario widgets there or M+ can false-match Nemesis heuristics.)
--- @return boolean
local function ShouldReadDelveScenarioWidgets()
    if addon.IsDelveActive() then return true end
    if C_Map and C_Map.GetBestMapForUnit and C_Map.GetMapInfo then
        local mapID = C_Map.GetBestMapForUnit("player")
        local mapInfo = mapID and C_Map.GetMapInfo(mapID) or nil
        local mapType = mapInfo and mapInfo.mapType
        if mapType == 5 then
            local ok, scenarioName = pcall(C_Scenario.GetInfo)
            if ok and scenarioName and type(scenarioName) == "string" and scenarioName ~= "" then
                return true
            end
        end
    end
    return false
end

--- Find first visible ScenarioHeaderDelves widget info from scenario or objective-tracker set.
--- @return table|nil widgetInfo
local function GetDelveHeaderWidgetInfo()
    if not (C_UIWidgetManager and C_UIWidgetManager.GetAllWidgetsBySetID and C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo) then
        return nil
    end
    for _, setID in ipairs(GetAllDelveScenarioWidgetSetIDs()) do
        local list = CollectVisibleScenarioHeaderDelvesInfos(setID)
        if list[1] then return list[1] end
    end
    return nil
end

--- Remaining lives from ScenarioHeaderDelves currencies: Blizzard uses one row per life with textEnabledState, or a single numeric text.
--- @param widgetInfo table
--- @return number|nil
local function ParseDelveLivesRemaining(widgetInfo)
    if not widgetInfo or type(widgetInfo.currencies) ~= "table" then return nil end
    local cur = widgetInfo.currencies
    local n = #cur
    if n == 0 then return nil end

    -- Single aggregate: plain number or "current/max"
    if n == 1 then
        local c = cur[1]
        local t = (c and type(c.text) == "string") and c.text or ""
        local trimmed = t:match("^%s*(.-)%s*$") or ""
        local num = tonumber(trimmed)
        if num ~= nil and num >= 0 and num <= 30 then return num end
        local curLives = trimmed:match("^(%d+)/%d+$")
        if curLives then
            local v = tonumber(curLives)
            if v ~= nil and v >= 0 and v <= 30 then return v end
        end
    end

    -- Multiple slots (typical heart row): count entries whose textEnabledState is not Disabled.
    local Disabled = Enum and Enum.WidgetEnabledState and Enum.WidgetEnabledState.Disabled
    if Disabled ~= nil then
        local sawState = false
        local remaining = 0
        for _, c in ipairs(cur) do
            if type(c) == "table" and c.textEnabledState ~= nil then
                sawState = true
                if c.textEnabledState ~= Disabled then
                    remaining = remaining + 1
                end
            end
        end
        if sawState then return remaining end
    end

    return nil
end

--- Prefer a consistent icon across currency slots for |T embeds in the tracker.
--- @param widgetInfo table
--- @return number|nil fileID
local function GetDelveLivesIconFileID(widgetInfo)
    if not widgetInfo or type(widgetInfo.currencies) ~= "table" then return nil end
    local first
    for _, c in ipairs(widgetInfo.currencies) do
        if type(c) == "table" and type(c.iconFileID) == "number" and c.iconFileID > 0 then
            if not first then
                first = c.iconFileID
            elseif first ~= c.iconFileID then
                return first
            end
        end
    end
    return first
end

--- Contiguous runs in `currencies` grouped by iconFileID (nil/missing treated as sentinel -1 per slot).
--- @param cur table
--- @return table runs { startIdx, endIdx, iconFileID }[]
local function PartitionCurrencyRunsByIcon(cur)
    local runs = {}
    if type(cur) ~= "table" or #cur < 1 then return runs end
    local i = 1
    local n = #cur
    while i <= n do
        local c = cur[i]
        local iconKey = (type(c) == "table" and type(c.iconFileID) == "number" and c.iconFileID > 0)
            and c.iconFileID or -1
        local startIdx = i
        i = i + 1
        while i <= n do
            local c2 = cur[i]
            local ik = (type(c2) == "table" and type(c2.iconFileID) == "number" and c2.iconFileID > 0)
                and c2.iconFileID or -1
            if ik ~= iconKey then break end
            i = i + 1
        end
        local endIdx = i - 1
        local iconFileID = (iconKey ~= -1) and iconKey or nil
        runs[#runs + 1] = { startIdx = startIdx, endIdx = endIdx, iconFileID = iconFileID }
    end
    return runs
end

--- Parse Nemesis / Nemesis-chest row: per-slot textEnabledState (Disabled = group defeated) or single-slot number / cur/max.
--- @param startIdx number
--- @param endIdx number
--- @param cur table currency array
--- @return table|nil { remaining, total, isComplete, iconFileID, hasData }
local function ParseCurrencyRunNemesisLike(startIdx, endIdx, cur)
    if type(cur) ~= "table" or startIdx > endIdx then return nil end
    local Disabled = Enum and Enum.WidgetEnabledState and Enum.WidgetEnabledState.Disabled
    local sawState, remaining, total = false, 0, 0
    local iconFileID
    for idx = startIdx, endIdx do
        local c = cur[idx]
        if type(c) == "table" then
            if type(c.iconFileID) == "number" and c.iconFileID > 0 then
                iconFileID = iconFileID or c.iconFileID
            end
            if c.textEnabledState ~= nil and Disabled ~= nil then
                sawState = true
                total = total + 1
                if c.textEnabledState ~= Disabled then
                    remaining = remaining + 1
                end
            end
        end
    end
    if sawState and total > 0 then
        return {
            remaining    = remaining,
            total        = total,
            isComplete   = (remaining == 0),
            iconFileID   = iconFileID,
            hasData      = true,
        }
    end
    if startIdx == endIdx then
        local c = cur[startIdx]
        if type(c) == "table" then
            if type(c.iconFileID) == "number" and c.iconFileID > 0 then iconFileID = c.iconFileID end
            local t = type(c.text) == "string" and c.text or ""
            local trimmed = t:match("^%s*(.-)%s*$") or ""
            local num = tonumber(trimmed)
            if num ~= nil and num >= 0 and num <= NEMESIS_GROUPS_MAX then
                return {
                    remaining    = num,
                    total        = nil,
                    isComplete   = (num == 0),
                    iconFileID   = iconFileID,
                    hasData      = true,
                }
            end
            local curG, maxG = trimmed:match("^(%d+)/(%d+)$")
            if curG and maxG then
                local a, b = tonumber(curG), tonumber(maxG)
                if a ~= nil and b ~= nil and b >= 1 and b <= NEMESIS_GROUPS_MAX then
                    return {
                        remaining    = a,
                        total        = b,
                        isComplete   = (a == 0),
                        iconFileID   = iconFileID,
                        hasData      = true,
                    }
                end
            end
        end
    end
    return nil
end

--- Second+ icon run, or a single run that is not the same datum as lives (e.g. Nemesis-only row with one slot or chest icons).
--- @param widgetInfo table
--- @return table|nil
local function ParseNemesisFromScenarioHeaderCurrencies(widgetInfo)
    if not widgetInfo or type(widgetInfo.currencies) ~= "table" then return nil end
    local cur = widgetInfo.currencies
    if #cur < 1 then return nil end
    local runs = PartitionCurrencyRunsByIcon(cur)
    if #runs >= 2 then
        for ri = 2, #runs do
            local seg = runs[ri]
            local parsed = ParseCurrencyRunNemesisLike(seg.startIdx, seg.endIdx, cur)
            if parsed and parsed.hasData then return parsed end
        end
        return nil
    end
    -- Single icon run: often Nemesis-only (one slot "3") or one row of chest slots — avoid duplicating the lives aggregate.
    if #runs == 1 then
        local seg = runs[1]
        local parsed = ParseCurrencyRunNemesisLike(seg.startIdx, seg.endIdx, cur)
        if not parsed or not parsed.hasData then return nil end
        local livesRem = ParseDelveLivesRemaining(widgetInfo)
        -- Same single-slot numeric is almost always the lives aggregate, not Nemesis.
        if livesRem ~= nil and parsed.remaining == livesRem and parsed.total == nil and #cur == 1 then
            return nil
        end
        return parsed
    end
    return nil
end

-- Heuristic: tooltip text suggests Nemesis / bonus chest progress (avoid unrelated IconAndText numbers).
local function TooltipLooksLikeNemesisGroups(tip, dtip)
    local lower = ((tip or "") .. " " .. (dtip or "")):lower()
    if lower:find("nemesis", 1, true) then return true end
    if lower:find("enemy", 1, true) and lower:find("group", 1, true) then return true end
    if lower:find("chest", 1, true) and (lower:find("bonus", 1, true) or lower:find("nemesis", 1, true)) then return true end
    if lower:find("bountiful", 1, true) then return true end
    if lower:find("pactsworn", 1, true) then return true end
    if lower:find("wasteland", 1, true) then return true end
    if lower:find("strongbox", 1, true) then return true end
    if lower:find("coffer", 1, true) then return true end
    return false
end

--- Fallback: other widgets in the delve scenario widget set (FillUpFrames, DiscreteProgress, IconAndText).
--- @param setID number
--- @return table|nil
local function ScanDelveWidgetSetForNemesis(setID)
    if not setID or not (C_UIWidgetManager and C_UIWidgetManager.GetAllWidgetsBySetID) then return nil end
    local wOk, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, setID)
    if not wOk or type(widgets) ~= "table" then return nil end
    local bestFill, bestDiscrete, bestIconText

    for _, wInfo in pairs(widgets) do
        local widgetID = (type(wInfo) == "table" and type(wInfo.widgetID) == "number") and wInfo.widgetID
            or (type(wInfo) == "number" and wInfo > 0) and wInfo
        local wType = type(wInfo) == "table" and wInfo.widgetType
        if widgetID and (not wType or wType ~= WIDGET_TYPE_SCENARIO_HEADER_DELVES) then
            if C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo then
                local ok, info = pcall(C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo, widgetID)
                if ok and info and type(info) == "table" and type(info.numTotalFrames) == "number"
                    and info.numTotalFrames >= 1 and info.numTotalFrames <= NEMESIS_GROUPS_MAX then
                    local full = type(info.numFullFrames) == "number" and info.numFullFrames or 0
                    local total = info.numTotalFrames
                    full = math.min(math.max(full, 0), total)
                    local remaining = total - full
                    local hasIcon
                    if type(info.overrideIcon) == "number" and info.overrideIcon > 0 then hasIcon = info.overrideIcon end
                    bestFill = {
                        remaining  = remaining,
                        total      = total,
                        isComplete = (remaining <= 0 and total > 0),
                        iconFileID = hasIcon,
                        hasData    = total > 0,
                    }
                end
            end

            if C_UIWidgetManager.GetDiscreteProgressStepsVisualizationInfo then
                local ok, info = pcall(C_UIWidgetManager.GetDiscreteProgressStepsVisualizationInfo, widgetID)
                if ok and info and type(info) == "table" and type(info.progressMax) == "number"
                    and info.progressMax >= 1 and info.progressMax <= NEMESIS_GROUPS_MAX then
                    local vmin = type(info.progressMin) == "number" and info.progressMin or 0
                    local pv = type(info.progressVal) == "number" and info.progressVal or vmin
                    local total = info.progressMax - vmin
                    if total >= 1 then
                        local completed = math.max(0, math.min(pv - vmin, total))
                        local remaining = math.max(0, total - completed)
                        local tip = TooltipLooksLikeNemesisGroups(info.tooltip, info.dynamicTooltip)
                        if tip then
                            bestDiscrete = {
                                remaining  = remaining,
                                total      = total,
                                isComplete = (remaining <= 0 and total > 0),
                                iconFileID = nil,
                                hasData    = true,
                            }
                        end
                    end
                end
            end

            if C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo then
                local ok, info = pcall(C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo, widgetID)
                if ok and info and type(info) == "table" and type(info.text) == "string" then
                    local trimmed = info.text:match("^%s*(.-)%s*$") or ""
                    local num = tonumber(trimmed)
                    if num ~= nil and num >= 0 and num <= NEMESIS_GROUPS_MAX then
                        local tipOk = TooltipLooksLikeNemesisGroups(info.tooltip, info.dynamicTooltip)
                        local ico = (type(info.iconFileID) == "number" and info.iconFileID > 0) and info.iconFileID
                            or (type(info.icon) == "number" and info.icon > 0) and info.icon or nil
                        if tipOk or num == 0 or (num >= 1 and num <= 15) then
                            bestIconText = {
                                remaining  = num,
                                total      = nil,
                                isComplete = (num == 0),
                                iconFileID = ico,
                                hasData    = true,
                            }
                        end
                    end
                end
            end

            if not bestIconText and C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo then
                local ok, info = pcall(C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo, widgetID)
                if ok and info and type(info) == "table" and type(info.text) == "string" then
                    local trimmed = info.text:match("^%s*(.-)%s*$") or ""
                    local num = tonumber(trimmed)
                    if num ~= nil and num >= 0 and num <= NEMESIS_GROUPS_MAX then
                        local tipOk = TooltipLooksLikeNemesisGroups(info.tooltip, info.dynamicTooltip)
                        if tipOk or num == 0 or (num >= 1 and num <= 15) then
                            bestIconText = {
                                remaining  = num,
                                total      = nil,
                                isComplete = (num == 0),
                                iconFileID  = nil,
                                hasData     = true,
                            }
                        end
                    end
                end
            end
        end
    end

    if bestFill and bestFill.hasData then return bestFill end
    if bestDiscrete and bestDiscrete.hasData then return bestDiscrete end
    if bestIconText and bestIconText.hasData then return bestIconText end
    return nil
end

--- Build affix list and tier tooltip spell from delve header widget.
--- @param widgetInfo table
--- @return table affixes array (may be empty)
--- @return number|nil tierSpellID
local function BuildAffixesFromWidgetInfo(widgetInfo)
    local affixes = {}
    if not widgetInfo then return affixes, nil end
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

--- Season affix fallback when the header widget has no spell list.
--- @return table affixes (may be empty)
local function BuildAffixesFromSeasonFallback()
    local affixes = {}
    if not (C_DelvesUI and C_DelvesUI.GetDelvesAffixSpellsForSeason) then return affixes end
    local ok, spellIDs = pcall(C_DelvesUI.GetDelvesAffixSpellsForSeason)
    if not ok or not spellIDs or type(spellIDs) ~= "table" then return affixes end
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
    return affixes
end

--- True when the quest log tags the quest as Delve (Enum.QuestTag.Delve / C_QuestLog.GetQuestTagInfo).
--- pcall: GetQuestTagInfo can throw on invalid questID.
--- @param questID number
--- @return boolean
local function QuestLogQuestHasDelveTag(questID)
    if type(questID) ~= "number" or questID <= 0 then return false end
    if not (C_QuestLog and C_QuestLog.GetQuestTagInfo) then return false end
    if not (Enum and Enum.QuestTag and Enum.QuestTag.Delve ~= nil) then return false end
    local ok, tagInfo = pcall(C_QuestLog.GetQuestTagInfo, questID)
    if not ok or type(tagInfo) ~= "table" or type(tagInfo.tagID) ~= "number" then return false end
    return tagInfo.tagID == Enum.QuestTag.Delve
end

--- Nearby Delve-tagged log quests while in an active Delve on a dungeon/micro map.
--- Scenario / widget-driven delve UI comes from ReadScenarioEntries; this list is only Delve-tagged quests.
local function CollectDelveQuests(ctx)
    if not addon.IsDelveActive() then return {} end
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
                if QuestLogQuestHasDelveTag(questID) then
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
    end
    return out
end

--- Single read of delve header widget: affixes, tier spell, lives, life icon, Nemesis groups. Safe when not in a delve.
--- @return table { affixes, tierSpellID, livesRemaining, livesIconFileID, nemesisGroupsRemaining, nemesisGroupsTotal, nemesisIconFileID, nemesisIsComplete, nemesisHasData }
function addon.GetDelveScenarioHeaderMetadata()
    local result = {
        affixes                = nil,
        tierSpellID            = nil,
        livesRemaining         = nil,
        livesIconFileID        = nil,
        nemesisGroupsRemaining = nil,
        nemesisGroupsTotal     = nil,
        nemesisIconFileID      = nil,
        nemesisIsComplete      = nil,
        nemesisHasData         = false,
    }
    if not ShouldReadDelveScenarioWidgets() then return result end

    local allHeaders = select(1, CollectAllVisibleScenarioHeaderDelvesInfosDeduped())
    local widgetInfo = (allHeaders and allHeaders[1]) or GetDelveHeaderWidgetInfo()
    if widgetInfo then
        result.livesRemaining = ParseDelveLivesRemaining(widgetInfo)
        result.livesIconFileID = GetDelveLivesIconFileID(widgetInfo)
        local affixes, tierSpellID = BuildAffixesFromWidgetInfo(widgetInfo)
        result.tierSpellID = tierSpellID
        if #affixes > 0 then
            result.affixes = affixes
        end
    end

    local nemoCandidates = (allHeaders and #allHeaders > 0) and allHeaders or (widgetInfo and { widgetInfo } or {})
    for _, wi in ipairs(nemoCandidates) do
        local fromCur = ParseNemesisFromScenarioHeaderCurrencies(wi)
        if fromCur and fromCur.hasData then
            result.nemesisGroupsRemaining = fromCur.remaining
            result.nemesisGroupsTotal = fromCur.total
            result.nemesisIconFileID = fromCur.iconFileID
            result.nemesisIsComplete = fromCur.isComplete
            result.nemesisHasData = true
            break
        end
    end

    if not result.nemesisHasData then
        for _, setID in ipairs(GetAllDelveScenarioWidgetSetIDs()) do
            local fromSet = ScanDelveWidgetSetForNemesis(setID)
            if fromSet and fromSet.hasData then
                result.nemesisGroupsRemaining = fromSet.remaining
                result.nemesisGroupsTotal = fromSet.total
                result.nemesisIconFileID = fromSet.iconFileID
                result.nemesisIsComplete = fromSet.isComplete
                result.nemesisHasData = true
                break
            end
        end
    end

    if not result.affixes then
        local fallback = BuildAffixesFromSeasonFallback()
        if #fallback > 0 then
            result.affixes = fallback
        end
    end

    return result
end

--- Returns season affixes for the current Delve when in an active Delve, or nil.
--- Used by the quest block to show affixes inline. Tries UI Widget (Blizzard's source) first,
--- then C_DelvesUI.GetDelvesAffixSpellsForSeason. May return nil/empty when Blizzard's
--- objective tracker is hidden (Horizon replaces it) as widgets may not be populated.
--- @return table|nil Array of { name, desc, icon } or nil if not in Delve or no affixes
--- @return number|nil tierTooltipSpellID
local function GetDelvesAffixes()
    local meta = addon.GetDelveScenarioHeaderMetadata()
    if not meta then return nil, nil end
    return meta.affixes, meta.tierSpellID
end

--- Single life icon + numeric count for the tracker title row (FontString SetText).
--- @param count number Lives remaining (> 0)
--- @param iconFileID number|nil From widget currency; fallback to red ♥ glyph
--- @return string
function addon.FormatDelveLivesHeartsForTitle(count, iconFileID)
    if type(count) ~= "number" or count < 1 then return "" end
    local sz = tonumber(addon.DELVE_LIFE_EMBED_SIZE) or 13
    local iconSeg
    if type(iconFileID) == "number" and iconFileID > 0 then
        iconSeg = ("|T%d:%d:%d:0:-1|t"):format(iconFileID, sz, sz)
    else
        -- UTF-8 BLACK HEART SUIT (U+2665), tinted red — works on default title fonts.
        iconSeg = "|cffff5555\226\153\165|r"
    end
    return iconSeg .. " " .. tostring(math.floor(count))
end

--- Nemesis bonus-chest: one |T chest|t per remaining group (matches native discrete octagons), or one check per slot when complete.
--- @param remaining number|nil Groups not yet cleared
--- @param total number|nil Total groups when known (optional)
--- @param iconFileID number|nil From widget currency or IconAndText
--- @param isComplete boolean|nil All groups cleared (native UI shows a checkmark)
--- @return string Rich text for FontString SetText; empty when nothing to show
function addon.FormatDelveNemesisGroupsForTitle(remaining, total, iconFileID, isComplete)
    local sz = tonumber(addon.DELVE_LIFE_EMBED_SIZE) or 13
    local checkSeg = ("|TInterface\\RaidFrame\\ReadyCheck-Ready:%d:%d:0:-1|t"):format(sz, sz)
    if isComplete then
        local tc = 1
        if type(total) == "number" and total >= 1 then
            tc = math.min(math.floor(total), NEMESIS_GROUPS_MAX)
        end
        local parts = {}
        for i = 1, tc do
            parts[i] = checkSeg
        end
        return table.concat(parts, " ")
    end
    if type(remaining) ~= "number" or remaining < 1 then return "" end
    local iconSeg
    if type(iconFileID) == "number" and iconFileID > 0 then
        iconSeg = ("|T%d:%d:%d:0:-1|t"):format(iconFileID, sz, sz)
    else
        -- Fallback: gold tone when widget did not provide an icon file id
        iconSeg = "|cffffcc55\226\150\161|r"
    end
    local n = math.min(math.max(math.floor(remaining), 0), NEMESIS_GROUPS_MAX)
    if n < 1 then return "" end
    -- Show chest icon + remaining count (matches native header: one chest + "N").
    return iconSeg .. " " .. tostring(n)
end

--- Debug snapshot for slash commands: whether widgets are readable + set IDs + delve header count.
--- @return table
function addon.GetDelveScenarioWidgetDebugSnapshot()
    local headers = select(1, CollectAllVisibleScenarioHeaderDelvesInfosDeduped())
    local ids = GetAllDelveScenarioWidgetSetIDs()
    local idStr = {}
    for i, id in ipairs(ids) do
        idStr[i] = tostring(id)
    end
    return {
        shouldRead    = ShouldReadDelveScenarioWidgets(),
        isDelveActive = addon.IsDelveActive(),
        setIDs        = table.concat(idStr, ","),
        headerCount   = #headers,
    }
end

addon.CollectDelveQuests = CollectDelveQuests
addon.GetDelvesAffixes   = GetDelvesAffixes
