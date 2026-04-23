--[[
    Horizon Suite - Focus - Delve Provider
    ScenarioHeaderDelvesWidget (tierText, currencies, spells), C_PartyInfo.IsDelveInProgress, C_QuestLog.GetQuestTagInfo (QuestTag.Delve).
    Lives remaining: parsed from widget currencies (per-slot textEnabledState or numeric text).
    Nemesis enemy groups: sole source is widgetInfo.spells[i].stackDisplay plus the
        "remaining: N" description pattern (triggered via C_Spell.RequestLoadSpellData +
        SPELL_DATA_LOAD_RESULT). The identified Nemesis spellID is cached for the run so
        `stack == 0` on the same spell is a direct, unambiguous completion signal.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- Scenario step widget set contains Delve header; Objective Tracker set may not when tracker is hidden.
local WIDGET_TYPE_SCENARIO_HEADER_DELVES = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.ScenarioHeaderDelves) or 29

-- Sanity cap for Nemesis group counts (matches lives cap in ParseDelveLivesRemaining).
local NEMESIS_GROUPS_MAX = 30

-- Per-scenario Nemesis cache. Blizzard removes the affix spell from the widget once all packs are
-- cleared, so no parser can fire on completion; we remember the highest `remaining` we've seen this
-- scenario and synthesize `isComplete = true` while the delve is still active.
-- `runLive` gates the "treat as complete" fallback: only true after we have seen at least one live
-- group count this run, so a stale seenMax from a previous run (same map ID) cannot show the tick.
-- `lastLiveRemaining` records the most recent live `remaining > 0` value we observed this
-- run. It gates `isComplete` acceptance: Blizzard can report stackDisplay=0 on the Nemesis
-- spell transiently during widget reload / delve entry / `/reload`, and the only reliable
-- "this is real completion" signal is that we already saw the natural final decrement
-- (remaining==1). `latchedRemaining` keeps the last known live count rendered across
-- transient data gaps so the banner doesn't flicker to nothing mid-run.
local nemesisCache = {
    key = nil, seenMax = 0, completed = false, runLive = false,
    lastLiveRemaining = 0,
    latchedRemaining = nil, latchedTotal = nil,
    -- Identified Nemesis spellID for this run. Once set, the spells parser looks it up
    -- directly so `stackDisplay == 0` on the same spell is a direct completion signal
    -- (rather than inferred from fallback widgets, which can false-positive).
    nemesisSpellID = nil,
}

local function ResetNemesisCache(key)
    nemesisCache.key = key
    nemesisCache.seenMax = 0
    nemesisCache.completed = false
    nemesisCache.runLive = false
    nemesisCache.lastLiveRemaining = 0
    nemesisCache.latchedRemaining = nil
    nemesisCache.latchedTotal = nil
    nemesisCache.nemesisSpellID = nil
end

-- Zone transitions (including delve entry/exit) always invalidate the Nemesis cache.
-- C_Map.GetBestMapForUnit returns the same ID for two runs of the same delve type, so the
-- scenarioKey-based reset alone cannot distinguish "same run" from "fresh run, same delve".
local nemesisCacheResetFrame = CreateFrame("Frame")
nemesisCacheResetFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
nemesisCacheResetFrame:SetScript("OnEvent", function()
    ResetNemesisCache(nil)
end)

--- Get spell name and icon; supports both legacy GetSpellInfo and C_Spell.GetSpellInfo.
--- Exposed on addon so FocusSlash / tooltip helpers can share one implementation.
--- @param spellID number
--- @return string|nil name, number|nil icon
function addon.GetSpellNameAndIcon(spellID)
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
local GetSpellNameAndIcon = addon.GetSpellNameAndIcon

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

--- Every visible ScenarioHeaderDelves widget across the given (or discovered) sets, deduped by widgetID.
--- @param setIDs number[]|nil Optional hoisted list; discovered via GetAllDelveScenarioWidgetSetIDs when omitted.
--- @return table[] array of widgetInfo
local function CollectVisibleDelveHeaders(setIDs)
    local out = {}
    if not (C_UIWidgetManager and C_UIWidgetManager.GetAllWidgetsBySetID and C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo) then
        return out
    end
    local seen = {}
    local WidgetShownState = Enum and Enum.WidgetShownState
    for _, setID in ipairs(setIDs or GetAllDelveScenarioWidgetSetIDs()) do
        local wOk, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, setID)
        if wOk and type(widgets) == "table" then
            for _, wInfo in pairs(widgets) do
                local widgetID = (wInfo and type(wInfo) == "table" and type(wInfo.widgetID) == "number") and wInfo.widgetID
                    or (type(wInfo) == "number" and wInfo > 0) and wInfo
                local wType = (wInfo and type(wInfo) == "table") and wInfo.widgetType
                if widgetID and not seen[widgetID] and (not wType or wType == WIDGET_TYPE_SCENARIO_HEADER_DELVES) then
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
    return out
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

--- Nemesis Strongbox / bonus-chest count rendered as a stack badge on an affix spell icon.
--- Sole authoritative source: `widgetInfo.spells[i].stackDisplay`, with `C_Spell.GetSpellDescription`
--- "remaining: N" as a co-equal identifier (Blizzard formats the same count into the description,
--- and the description arrives asynchronously on initial delve entry).
---
--- The Nemesis spell keeps its slot in `spells` across the entire run; Blizzard decrements
--- `stackDisplay` as packs die and drops it to 0 on completion before the spell icon is
--- removed from the widget. Once we've identified which spellID is the Nemesis, we look
--- up that specific ID on every subsequent read — seeing it present with `stack == 0`
--- gives us a direct, zero-ambiguity completion signal (no inference from sibling widgets
--- that can fire false positives during initial widget reload).
---
--- `RequestLoadSpellData` triggers `SPELL_DATA_LOAD_RESULT` once the server returns the
--- description, which FocusEvents routes back to a refresh so the count appears as soon
--- as the description arrives instead of waiting for an unrelated widget tick.
--- @param widgetInfo table ScenarioHeaderDelves widget visualization info
--- @return table|nil { remaining, total, isComplete, hasData }
local function ParseNemesisFromDelveSpells(widgetInfo)
    if not widgetInfo or type(widgetInfo.spells) ~= "table" or #widgetInfo.spells < 1 then return nil end

    -- Trigger async description load for every affix spell. Cheap & idempotent; pairs with
    -- FocusEvents' SPELL_DATA_LOAD_RESULT handler to re-read as descriptions arrive.
    if C_Spell and C_Spell.RequestLoadSpellData then
        for _, sp in ipairs(widgetInfo.spells) do
            if type(sp) == "table" and type(sp.spellID) == "number" and sp.spellID > 0 then
                pcall(C_Spell.RequestLoadSpellData, sp.spellID)
            end
        end
    end

    --- Extract the live count from a spell entry. Reads `stackDisplay` first, falls back
    --- to the "remaining: N" pattern in the spell description (Blizzard uses a non-breaking
    --- space between the label and the number, so `[^%d]+` is the correct separator class).
    --- @param sp table One entry from widgetInfo.spells
    --- @return number|nil stack
    local function ReadStack(sp)
        local stack = (type(sp.stackDisplay) == "number" and sp.stackDisplay) or nil
        if (not stack or stack <= 0) and C_Spell and C_Spell.GetSpellDescription then
            local dOk, desc = pcall(C_Spell.GetSpellDescription, sp.spellID)
            if dOk and type(desc) == "string" then
                local n = tonumber(desc:match("remaining[^%d]+(%d+)"))
                if n and n >= 0 then stack = n end
            end
        end
        return stack
    end

    -- Fast path: if we've already identified which spell is the Nemesis this run, look it
    -- up directly. This is what lets stack==0 mean "complete" unambiguously.
    local cachedID = nemesisCache.nemesisSpellID
    if type(cachedID) == "number" and cachedID > 0 then
        for _, sp in ipairs(widgetInfo.spells) do
            if type(sp) == "table" and sp.spellID == cachedID then
                local stack = ReadStack(sp) or 0
                if stack > 0 and stack <= NEMESIS_GROUPS_MAX then
                    return { remaining = stack, total = nil, isComplete = false, hasData = true }
                end
                -- Spell still present but stack dropped to 0: Blizzard's direct "complete" signal.
                return { remaining = 0, total = nil, isComplete = true, hasData = true }
            end
        end
        -- Cached ID vanished from the spell list — fall through to re-scan. If nothing
        -- identifies as Nemesis in the new snapshot, GetDelveScenarioHeaderMetadata's
        -- elseif block synthesizes completion once we've seen lastLiveRemaining<=1.
    end

    -- Discovery path: find a spell that identifies itself as the Nemesis. A spell counts
    -- as Nemesis when either stackDisplay > 0 or the description carries the "remaining"
    -- count. Once identified, cache its spellID so subsequent reads take the fast path.
    for _, sp in ipairs(widgetInfo.spells) do
        if type(sp) == "table" and type(sp.spellID) == "number" and sp.spellID > 0 then
            local stack = ReadStack(sp)
            if stack and stack > 0 and stack <= NEMESIS_GROUPS_MAX then
                nemesisCache.nemesisSpellID = sp.spellID
                return { remaining = stack, total = nil, isComplete = false, hasData = true }
            end
        end
    end

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
--- @return table { affixes, tierSpellID, livesRemaining, livesIconFileID, nemesisGroupsRemaining, nemesisGroupsTotal, nemesisIsComplete, nemesisHasData }
function addon.GetDelveScenarioHeaderMetadata()
    local result = {
        affixes                = nil,
        tierSpellID            = nil,
        livesRemaining         = nil,
        livesIconFileID        = nil,
        nemesisGroupsRemaining = nil,
        nemesisGroupsTotal     = nil,
        nemesisIsComplete      = nil,
        nemesisHasData         = false,
    }
    if not ShouldReadDelveScenarioWidgets() then
        -- Left the delve: drop the completion cache so a re-entry starts clean.
        ResetNemesisCache(nil)
        return result
    end

    -- Per-scenario key; reset cache when the player changes delve.
    local scenarioKey = (C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")) or 0
    if scenarioKey ~= nemesisCache.key then
        ResetNemesisCache(scenarioKey)
    end

    local setIDs = GetAllDelveScenarioWidgetSetIDs()
    local allHeaders = CollectVisibleDelveHeaders(setIDs)
    local widgetInfo = allHeaders[1]
    if widgetInfo then
        result.livesRemaining = ParseDelveLivesRemaining(widgetInfo)
        result.livesIconFileID = GetDelveLivesIconFileID(widgetInfo)
        local affixes, tierSpellID = BuildAffixesFromWidgetInfo(widgetInfo)
        result.tierSpellID = tierSpellID
        if #affixes > 0 then
            result.affixes = affixes
        end
    end

    local function AcceptCompletion()
        -- Nemesis groups die one at a time, so the natural kill sequence always passes
        -- through `remaining == 1` before the spell flips to 0 / is removed. We require
        -- that step to have been observed live before accepting any isComplete signal.
        --
        -- An earlier version also accepted after a 1.5s "stability window" regardless of
        -- last-live value, but that turned out to be the exact path that produced the
        -- spurious tick on delve entry / `/reload`: during widget reload Blizzard can
        -- report `stackDisplay = 0` on the Nemesis spell for several seconds before the
        -- real value syncs, which trips the age threshold and synthesizes a false tick.
        -- Requiring `lastLiveRemaining <= 1` is the only signal we can trust.
        --
        -- Trade-off: if the player AoEs multiple groups in one swing and the widget skips
        -- the remaining==1 update (a refresh debounce window missing the intermediate
        -- state), the tick won't render until the next delve run. That's a rare visual
        -- miss vs. a repeated, visible false-positive — accept the miss.
        if not nemesisCache.runLive then return false end
        return (nemesisCache.lastLiveRemaining or 0) <= 1
    end

    local function adopt(parsed)
        if not parsed then return false end
        -- Reject isComplete unless AcceptCompletion agrees we've seen the natural
        -- remaining==1 step live. Blizzard can report stackDisplay=0 on the Nemesis
        -- spell transiently during widget reload, and without this gate we'd flip the
        -- banner to the tick state on delve entry / `/reload`.
        if parsed.isComplete and not AcceptCompletion() then return false end
        result.nemesisGroupsRemaining = parsed.remaining
        result.nemesisGroupsTotal = parsed.total
        result.nemesisIsComplete = parsed.isComplete
        result.nemesisHasData = true
        return true
    end

    -- Sole source: the affix spell in widgetInfo.spells (stackDisplay or the "remaining: N"
    -- description). Earlier builds tried currency runs and sibling widget-set scans as
    -- fallbacks, but those paths cannot distinguish Blizzard's transient "all slots
    -- disabled" state on initial widget reload from a genuine completion, and were the
    -- structural cause of the spurious-tick / delayed-count on initial delve entry.
    for _, wi in ipairs(allHeaders) do
        if adopt(ParseNemesisFromDelveSpells(wi)) then break end
    end

    -- Remember progress so we can render the completed state after Blizzard drops the affix spell.
    if result.nemesisHasData then
        local rem = result.nemesisGroupsRemaining
        if type(rem) == "number" and rem > 0 then
            -- Live, non-complete data: this is a real run with groups still remaining.
            nemesisCache.runLive = true
            nemesisCache.lastLiveRemaining = rem
            nemesisCache.latchedRemaining = rem
            nemesisCache.latchedTotal = result.nemesisGroupsTotal
            if rem > nemesisCache.seenMax then
                nemesisCache.seenMax = rem
            end
        end
        if result.nemesisIsComplete or (type(rem) == "number" and rem <= 0) then
            nemesisCache.completed = true
        end
    elseif nemesisCache.runLive and nemesisCache.seenMax > 0 then
        -- No parser adopted this read. Either the affix spell was removed (legit completion)
        -- or Blizzard is transiently reloading widgets (initial entry, tracker hide/show).
        -- AcceptCompletion gates the tick on lastLiveRemaining<=1 — the natural final step.
        -- Otherwise keep rendering the latched live count so the banner doesn't flicker.
        if AcceptCompletion() then
            result.nemesisGroupsRemaining = 0
            result.nemesisGroupsTotal = nemesisCache.seenMax
            result.nemesisIsComplete = true
            result.nemesisHasData = true
            nemesisCache.completed = true
        elseif type(nemesisCache.latchedRemaining) == "number" and nemesisCache.latchedRemaining > 0 then
            result.nemesisGroupsRemaining = nemesisCache.latchedRemaining
            result.nemesisGroupsTotal = nemesisCache.latchedTotal
            result.nemesisIsComplete = false
            result.nemesisHasData = true
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

--- Bundled Nemesis texture (Interface\AddOns\HorizonSuite\assets\icons\nemesis.tga, 64x64 TGA).
local NEMESIS_CUSTOM_TEXTURE_PATH = "Interface\\AddOns\\HorizonSuite\\assets\\icons\\nemesis"

--- Nemesis bonus-chest: bundled icon + remaining count, or a single ReadyCheck when complete.
--- @param remaining number|nil Groups not yet cleared
--- @param total number|nil Unused (kept for call-site compatibility)
--- @param isComplete boolean|nil All groups cleared — renders a single green checkmark
--- @return string Rich text for FontString SetText; empty when nothing to show
function addon.FormatDelveNemesisGroupsForTitle(remaining, total, isComplete)
    local sz = tonumber(addon.DELVE_LIFE_EMBED_SIZE) or 13
    if isComplete then
        return ("|TInterface\\RaidFrame\\ReadyCheck-Ready:%d:%d:0:-1|t"):format(sz, sz)
    end
    if type(remaining) ~= "number" or remaining < 1 then return "" end
    local n = math.min(math.floor(remaining), NEMESIS_GROUPS_MAX)
    if n < 1 then return "" end
    return ("|T%s:%d:%d:0:-1|t %d"):format(NEMESIS_CUSTOM_TEXTURE_PATH, sz, sz, n)
end

--- Debug snapshot for slash commands: whether widgets are readable + set IDs + delve header count.
--- @return table
function addon.GetDelveScenarioWidgetDebugSnapshot()
    local headers = CollectVisibleDelveHeaders()
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
