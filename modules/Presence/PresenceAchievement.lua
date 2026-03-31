--[[
    Horizon Suite - Presence - Achievement
    Achievement earned and progress notifications. ACHIEVEMENT, ACHIEVEMENT_PROGRESS.
    APIs: C_ContentTracking, GetAchievementInfo, GetAchievementCriteriaInfo, GetAchievementNumCriteria.
    Events: CRITERIA_UPDATE, CRITERIA_EARNED, TRACKED_ACHIEVEMENT_UPDATE (see wowapi/AchievementInfoDocumentation.lua).
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then _G.HorizonSuite = {} end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.Presence then return end

local ACHIEVEMENT_PROGRESS_DEBOUNCE = 0.6
local ACHIEVEMENT_PROGRESS_DEDUPE = 3

-- ============================================================================
-- State
-- ============================================================================

local achievementProgressCache = {}
local pendingAchievementIDs = {}
--- Per-achievement hints from the last criteria-related events (criteriaID, description).
local pendingCriteriaHints = {}
local lastAchProgressText = nil
local lastAchProgressTime = 0

-- ============================================================================
-- Helpers
-- ============================================================================

local function Strip(s)
    return addon.Presence.StripMarkup and addon.Presence.StripMarkup(s) or (s or "")
end

local function IsTypeEnabled(key, fallbackKey, fallbackDefault)
    return addon.Presence.IsTypeEnabled and addon.Presence.IsTypeEnabled(key, fallbackKey, fallbackDefault) or fallbackDefault
end

local function GetTrackedAchievementIDs()
    local ids = {}
    if C_ContentTracking and C_ContentTracking.GetTrackedIDs then
        local achType = (Enum and Enum.ContentTrackingType and Enum.ContentTrackingType.Achievement) or 2
        local ok, tracked = pcall(C_ContentTracking.GetTrackedIDs, achType)
        if ok and tracked then
            for _, id in ipairs(tracked) do ids[#ids + 1] = id end
        end
    end
    if GetTrackedAchievements and #ids == 0 then
        local ok, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10 = pcall(GetTrackedAchievements)
        if ok then
            for _, id in ipairs({ a1, a2, a3, a4, a5, a6, a7, a8, a9, a10 }) do
                if id then ids[#ids + 1] = id end
            end
        end
    end
    return ids
end

local function SerializeAchievementProgress(achievementID)
    if not GetAchievementCriteriaInfo or not GetAchievementNumCriteria then return nil end
    local ok, numCriteria = pcall(GetAchievementNumCriteria, achievementID)
    if not ok or not numCriteria or numCriteria == 0 then return nil end
    local parts = {}
    for i = 1, numCriteria do
        local cOk, _, _, completed, quantity, reqQuantity = pcall(GetAchievementCriteriaInfo, achievementID, i)
        if cOk then
            parts[#parts + 1] = ("%s:%s:%s"):format(tostring(completed), tostring(quantity), tostring(reqQuantity))
        end
    end
    return table.concat(parts, ";")
end

-- Build one subtitle line from criterion fields (matches prior toast formatting).
local function FormatOneCriterionLine(criteriaString, completed, quantity, reqQuantity)
    local cq = tonumber(quantity)
    local crq = tonumber(reqQuantity)
    local name = (criteriaString and criteriaString ~= "") and criteriaString or nil
    local fin = (completed == true) or (completed == 1)
    if not fin and cq and crq and crq > 0 and cq > 0 then
        if name then
            return ("%d/%d %s"):format(cq, crq, name)
        end
        return ("%d/%d"):format(cq, crq)
    end
    if fin then
        if cq and crq and crq > 0 then
            if name then
                return ("%d/%d %s"):format(cq, crq, name)
            end
            return ("%d/%d"):format(cq, crq)
        end
        if name then
            return name
        end
    end
    return nil
end

local function GetCriterionLineAtIndex(achievementID, idx)
    if not GetAchievementCriteriaInfo then return nil end
    local cOk, criteriaString, _, completed, quantity, reqQuantity = pcall(GetAchievementCriteriaInfo, achievementID, idx)
    if not cOk then return nil end
    return FormatOneCriterionLine(criteriaString, completed, quantity, reqQuantity)
end

-- pcall: GetAchievementCriteriaInfo can throw on invalid ID.
local function FindCriterionIndexByCriteriaID(achievementID, targetCritID)
    if not targetCritID or not GetAchievementNumCriteria or not GetAchievementCriteriaInfo then return nil end
    local tid = tonumber(targetCritID)
    if not tid or tid <= 0 then return nil end
    local nOk, numCriteria = pcall(GetAchievementNumCriteria, achievementID)
    if not nOk or not numCriteria or numCriteria == 0 then return nil end
    for index = 1, numCriteria do
        local cOk, _, _, _, _, _, _, _, _, _, critID = pcall(GetAchievementCriteriaInfo, achievementID, index)
        if cOk and critID and tonumber(critID) == tid then
            return index
        end
    end
    return nil
end

local function FindFirstChangedSegmentIndex(oldState, newState)
    if not oldState or not newState or oldState == newState then return nil end
    local oldT = { strsplit(";", oldState) }
    local newT = { strsplit(";", newState) }
    local n = math.max(#oldT, #newT)
    for i = 1, n do
        if (oldT[i] or "") ~= (newT[i] or "") then
            return i
        end
    end
    return nil
end

-- Legacy fallback: first incomplete criterion with numeric progress, else first completed with text.
local function GetAchievementProgressTextHeuristic(achievementID)
    if not GetAchievementCriteriaInfo or not GetAchievementNumCriteria then return nil end
    local ok, numCriteria = pcall(GetAchievementNumCriteria, achievementID)
    if not ok or not numCriteria or numCriteria == 0 then return nil end
    for i = 1, numCriteria do
        local cOk, criteriaString, _, completed, quantity, reqQuantity = pcall(GetAchievementCriteriaInfo, achievementID, i)
        if cOk and not completed and quantity and reqQuantity and tonumber(quantity) and tonumber(reqQuantity) and tonumber(reqQuantity) > 0 and tonumber(quantity) > 0 then
            local name = (criteriaString and criteriaString ~= "") and criteriaString or nil
            if name then
                return ("%d/%d %s"):format(tonumber(quantity), tonumber(reqQuantity), name)
            end
            return ("%d/%d"):format(tonumber(quantity), tonumber(reqQuantity))
        end
    end
    for i = 1, numCriteria do
        local cOk, criteriaString, _, completed, quantity, reqQuantity = pcall(GetAchievementCriteriaInfo, achievementID, i)
        if cOk and completed then
            local name = (criteriaString and criteriaString ~= "") and criteriaString or nil
            if quantity and reqQuantity and tonumber(quantity) and tonumber(reqQuantity) and tonumber(reqQuantity) > 0 then
                if name then
                    return ("%d/%d %s"):format(tonumber(quantity), tonumber(reqQuantity), name)
                end
                return ("%d/%d"):format(tonumber(quantity), tonumber(reqQuantity))
            elseif name then
                return name
            end
        end
    end
    return nil
end

--- Resolve subtitle for a progress toast using event hints, criteriaID mapping, or per-criterion snapshot diff.
--- @param achievementID number
--- @param oldState string|nil
--- @param newState string|nil
--- @param hint table|nil
--- @return string|nil
local function GetAchievementProgressTextForChange(achievementID, oldState, newState, hint)
    if hint and hint.description and hint.description ~= "" and hint.fromEarned then
        return hint.description
    end
    if hint and hint.criteriaID and type(hint.criteriaID) == "number" and hint.criteriaID > 0 then
        local idx = FindCriterionIndexByCriteriaID(achievementID, hint.criteriaID)
        if idx then
            local line = GetCriterionLineAtIndex(achievementID, idx)
            if line then return line end
        end
    end
    local segIdx = FindFirstChangedSegmentIndex(oldState, newState)
    if segIdx then
        local line = GetCriterionLineAtIndex(achievementID, segIdx)
        if line then return line end
    end
    return GetAchievementProgressTextHeuristic(achievementID)
end

-- ============================================================================
-- Event handlers
-- ============================================================================

--- Queue an achievement-earned toast when the player earns an achievement.
--- @param achID number Achievement ID
--- @return nil
function addon.Presence.Achievement_OnAchievementEarned(achID)
    if not IsTypeEnabled("presenceAchievement", nil, true) then return end
    local _, name = GetAchievementInfo(achID)
    local L = addon.L or {}
    addon.Presence.QueueOrPlay("ACHIEVEMENT", L["PRESENCE_ACHIEVEMENT_EARNED"], Strip(name or ""))
end

local function ExecuteAchievementProgressCheck(pendingIDs, hintsByAchID)
    if not IsTypeEnabled("presenceAchievementProgress", nil, false) then return end

    local idsToCheck = {}
    for achID, _ in pairs(pendingIDs or {}) do
        if type(achID) == "number" and achID > 0 then
            idsToCheck[achID] = true
        end
    end
    for _, achID in ipairs(GetTrackedAchievementIDs()) do
        if type(achID) == "number" and achID > 0 then
            idsToCheck[achID] = true
        end
    end

    hintsByAchID = hintsByAchID or {}

    for achID, _ in pairs(idsToCheck) do
        local newState = SerializeAchievementProgress(achID)
        if newState then
            local oldState = achievementProgressCache[achID]
            if oldState and oldState ~= newState then
                local hint = hintsByAchID[achID]
                local progressText = GetAchievementProgressTextForChange(achID, oldState, newState, hint)
                if progressText then
                    local now = GetTime()
                    local isDupe = (lastAchProgressText == progressText and (now - lastAchProgressTime) <= ACHIEVEMENT_PROGRESS_DEDUPE)
                    if not isDupe then
                        lastAchProgressText = progressText
                        lastAchProgressTime = now
                        local aOk, _, achName = pcall(GetAchievementInfo, achID)
                        achName = Strip(tostring(achName or ""))
                        addon.Presence.QueueOrPlay("ACHIEVEMENT_PROGRESS", achName, progressText, { source = "CRITERIA_UPDATE" })
                    end
                end
            end
            achievementProgressCache[achID] = newState
        end
    end
end

--- Handle criteria-related events. Payloads: TRACKED_ACHIEVEMENT_UPDATE (achievementID, criteriaID?, elapsed?, duration?); CRITERIA_EARNED (achievementID, description, ...); CRITERIA_UPDATE (none).
--- @param event string
--- @return nil
function addon.Presence.Achievement_OnCriteriaUpdate(event, ...)
    if not IsTypeEnabled("presenceAchievementProgress", nil, false) then return end

    local achID, arg2, arg3, arg4 = ...

    if event == "TRACKED_ACHIEVEMENT_UPDATE" then
        local criteriaID = arg2
        if achID and type(achID) == "number" and achID > 0 then
            pendingAchievementIDs[achID] = true
            local h = pendingCriteriaHints[achID] or {}
            if criteriaID and type(criteriaID) == "number" and criteriaID > 0 then
                h.criteriaID = criteriaID
            end
            h.event = event
            pendingCriteriaHints[achID] = h
        end
    elseif event == "CRITERIA_EARNED" then
        local description = arg2
        if achID and type(achID) == "number" and achID > 0 then
            pendingAchievementIDs[achID] = true
            local h = pendingCriteriaHints[achID] or {}
            if description and type(description) == "string" and description ~= "" then
                h.description = Strip(description)
            end
            h.fromEarned = true
            h.event = event
            pendingCriteriaHints[achID] = h
        end
    end

    local function fireAchievementProgress()
        local pending = {}
        local hints = {}
        for id, _ in pairs(pendingAchievementIDs) do
            pending[id] = true
            local hint = pendingCriteriaHints[id]
            if hint then
                hints[id] = hint
                pendingCriteriaHints[id] = nil
            end
        end
        wipe(pendingAchievementIDs)
        ExecuteAchievementProgressCheck(pending, hints)
    end
    if addon.Presence.RequestDebounced then
        addon.Presence.RequestDebounced("achievement", ACHIEVEMENT_PROGRESS_DEBOUNCE, fireAchievementProgress)
    end
end

-- ============================================================================
-- Seed (called from OnPlayerEnteringWorld)
-- ============================================================================

--- Initialize cached criterion snapshots for tracked achievements (baseline only; no toasts).
--- @return nil
function addon.Presence._seedAchievementProgress()
    local trackedIDs = GetTrackedAchievementIDs()
    for _, achID in ipairs(trackedIDs) do
        achievementProgressCache[achID] = SerializeAchievementProgress(achID)
    end
end
