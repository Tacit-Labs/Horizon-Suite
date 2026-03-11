--[[
    Horizon Suite - Presence - Achievement
    Achievement earned and progress notifications. ACHIEVEMENT, ACHIEVEMENT_PROGRESS.
    APIs: C_ContentTracking, GetAchievementInfo, GetAchievementCriteriaInfo, GetAchievementNumCriteria.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.Presence then return end

local ACHIEVEMENT_PROGRESS_DEBOUNCE = 0.6
local ACHIEVEMENT_PROGRESS_DEDUPE = 3

-- ============================================================================
-- State
-- ============================================================================

local achievementProgressCache = {}
local pendingAchievementIDs = {}
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

local function GetAchievementProgressText(achievementID)
    if not GetAchievementCriteriaInfo or not GetAchievementNumCriteria then return nil end
    local ok, numCriteria = pcall(GetAchievementNumCriteria, achievementID)
    if not ok or not numCriteria or numCriteria == 0 then return nil end
    for i = 1, numCriteria do
        local cOk, criteriaString, _, completed, quantity, reqQuantity = pcall(GetAchievementCriteriaInfo, achievementID, i)
        if cOk and not completed and quantity and reqQuantity and tonumber(quantity) and tonumber(reqQuantity) and tonumber(reqQuantity) > 0 and tonumber(quantity) > 0 then
            local name = (criteriaString and criteriaString ~= "") and criteriaString or nil
            if name then
                return ("%d/%d %s"):format(tonumber(quantity), tonumber(reqQuantity), name)
            else
                return ("%d/%d"):format(tonumber(quantity), tonumber(reqQuantity))
            end
        end
    end
    for i = 1, numCriteria do
        local cOk, criteriaString, _, completed, quantity, reqQuantity = pcall(GetAchievementCriteriaInfo, achievementID, i)
        if cOk and completed then
            local name = (criteriaString and criteriaString ~= "") and criteriaString or nil
            if quantity and reqQuantity and tonumber(quantity) and tonumber(reqQuantity) and tonumber(reqQuantity) > 0 then
                if name then
                    return ("%d/%d %s"):format(tonumber(quantity), tonumber(reqQuantity), name)
                else
                    return ("%d/%d"):format(tonumber(quantity), tonumber(reqQuantity))
                end
            elseif name then
                return name
            end
        end
    end
    return nil
end

-- ============================================================================
-- Event handlers
-- ============================================================================

function addon.Presence.Achievement_OnAchievementEarned(achID)
    if not IsTypeEnabled("presenceAchievement", nil, true) then return end
    local _, name = GetAchievementInfo(achID)
    local L = addon.L or {}
    addon.Presence.QueueOrPlay("ACHIEVEMENT", L["ACHIEVEMENT EARNED"], Strip(name or ""))
end

local function ExecuteAchievementProgressCheck(pendingIDs)
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

    for achID, _ in pairs(idsToCheck) do
        local newState = SerializeAchievementProgress(achID)
        if newState then
            local oldState = achievementProgressCache[achID]
            if oldState and oldState ~= newState then
                local progressText = GetAchievementProgressText(achID)
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

function addon.Presence.Achievement_OnCriteriaUpdate(event, achievementID, ...)
    if not IsTypeEnabled("presenceAchievementProgress", nil, false) then return end
    if achievementID and type(achievementID) == "number" and achievementID > 0 then
        pendingAchievementIDs[achievementID] = true
    end
    local function fireAchievementProgress()
        local pending = {}
        for id, _ in pairs(pendingAchievementIDs) do
            pending[id] = true
        end
        wipe(pendingAchievementIDs)
        ExecuteAchievementProgressCheck(pending)
    end
    if addon.Presence.RequestDebounced then
        addon.Presence.RequestDebounced("achievement", ACHIEVEMENT_PROGRESS_DEBOUNCE, fireAchievementProgress)
    end
end

-- ============================================================================
-- Seed (called from OnPlayerEnteringWorld)
-- ============================================================================

function addon.Presence._seedAchievementProgress()
    local trackedIDs = GetTrackedAchievementIDs()
    for _, achID in ipairs(trackedIDs) do
        achievementProgressCache[achID] = SerializeAchievementProgress(achID)
    end
end
