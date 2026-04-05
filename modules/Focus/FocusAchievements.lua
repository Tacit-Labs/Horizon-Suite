--[[
    Horizon Suite - Focus - Achievement Tracking
    Direct provider: C_ContentTracking.GetTrackedIDs(Achievement) / GetTrackedAchievements + GetAchievementInfo.
    Returns normalized entry tables for the tracker.
    Step-by-step flow notes: modules/Focus/notes/FocusAchievements.md
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

local TRACKING_TYPE_ACHIEVEMENT = (Enum and Enum.ContentTrackingType and Enum.ContentTrackingType.Achievement) or 2
local DEFAULT_ACHIEVEMENT_COLOR = { 0.78, 0.48, 0.22 }
local MAX_LEGACY_TRACKED_ACHIEVEMENTS = 10

-- ============================================================================
-- Private helpers
-- ============================================================================

-- Turns one achievement's criteria into objective rows; respects "only missing" option. Uses pcall for APIs that can throw on invalid ID.
local function GetAchievementCriteria(achievementID)
    local objectives = {}
    local criteriaDone, criteriaTotal = 0, 0
    local onlyMissing = addon.GetDB and addon.GetDB("achievementOnlyMissingRequirements", false)
    if not GetAchievementCriteriaInfo then return objectives, criteriaDone, criteriaTotal end
    -- pcall: GetAchievementNumCriteria and GetAchievementCriteriaInfo can throw on invalid ID.
    local numCriteria = 0
    if GetAchievementNumCriteria then
        local nOk, n = pcall(GetAchievementNumCriteria, achievementID)
        if nOk and type(n) == "number" then numCriteria = n end
    end

    if numCriteria == 0 then
        -- No criteria exposed. Check if the achievement itself carries overall progress
        -- via GetAchievementInfo (some meta achievements and progress-bar achievements).
        -- GetAchievementInfo returns: id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic
        -- We can't get numeric progress from GetAchievementInfo alone, but we can still
        -- indicate progress via description text if present.
        return objectives, criteriaDone, criteriaTotal
    end

    for criteriaIndex = 1, numCriteria do
        -- GetAchievementCriteriaInfo returns:
        -- criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible, duration, elapsed
        local cOk, criteriaString, criteriaType, completedCrit, quantity, reqQuantity, charName, flags, assetID, quantityString =
            pcall(GetAchievementCriteriaInfo, achievementID, criteriaIndex)
        if cOk and criteriaString and criteriaString ~= "" then
            local finished = (completedCrit == true) or (completedCrit == 1)
            criteriaTotal = criteriaTotal + 1
            if finished then criteriaDone = criteriaDone + 1 end
            local include = not onlyMissing or not finished
            if include then
                local percent = nil
                local numFulfilled, numRequired = nil, nil

                -- Ensure quantity and reqQuantity are numbers
                quantity = tonumber(quantity)
                reqQuantity = tonumber(reqQuantity)

                if quantity and reqQuantity and reqQuantity > 0 then
                    percent = math.floor(100 * math.min(quantity, reqQuantity) / reqQuantity)
                    numFulfilled = quantity
                    numRequired = reqQuantity
                elseif quantityString and type(quantityString) == "string" and quantityString ~= "" then
                    -- Some criteria report progress only via quantityString (e.g. "3 / 10").
                    -- Try to parse "X / Y" or "X/Y" from it.
                    local qsCur, qsMax = quantityString:match("^%s*(%d+)%s*/%s*(%d+)%s*$")
                    if qsCur and qsMax then
                        numFulfilled = tonumber(qsCur)
                        numRequired  = tonumber(qsMax)
                        if numFulfilled and numRequired and numRequired > 0 then
                            percent = math.floor(100 * math.min(numFulfilled, numRequired) / numRequired)
                        end
                    end
                end

                objectives[#objectives + 1] = {
                    text = criteriaString,
                    finished = finished,
                    percent = percent,
                    numFulfilled = numFulfilled,
                    numRequired = numRequired,
                }
            end
        elseif cOk and (not criteriaString or criteriaString == "") and quantityString and type(quantityString) == "string" and quantityString ~= "" then
            -- Criteria has no name but has a quantity string — use it as the text.
            local finished = (completedCrit == true) or (completedCrit == 1)
            criteriaTotal = criteriaTotal + 1
            if finished then criteriaDone = criteriaDone + 1 end
            local include = not onlyMissing or not finished
            if include then
                quantity = tonumber(quantity)
                reqQuantity = tonumber(reqQuantity)
                local numFulfilled, numRequired, percent = nil, nil, nil
                if quantity and reqQuantity and reqQuantity > 0 then
                    numFulfilled = quantity
                    numRequired = reqQuantity
                    percent = math.floor(100 * math.min(quantity, reqQuantity) / reqQuantity)
                end
                objectives[#objectives + 1] = {
                    text = quantityString,
                    finished = finished,
                    percent = percent,
                    numFulfilled = numFulfilled,
                    numRequired = numRequired,
                }
            end
        end
    end
    return objectives, criteriaDone, criteriaTotal
end

-- ============================================================================
-- Public functions
-- ============================================================================

--- Build tracker rows from WoW tracked achievements.
--- @return table Array of normalized entry tables (see entry shape in FocusState.lua)
local function ReadTrackedAchievements()
    local out = {}
    local idList = {}

    if C_ContentTracking and C_ContentTracking.GetTrackedIDs then
        local ok, ids = pcall(C_ContentTracking.GetTrackedIDs, TRACKING_TYPE_ACHIEVEMENT)
        if ok and ids and type(ids) == "table" then
            for _, id in ipairs(ids) do
                if type(id) == "number" and id > 0 then
                    idList[#idList + 1] = id
                end
            end
        end
    elseif GetTrackedAchievements then
        for i = 1, MAX_LEGACY_TRACKED_ACHIEVEMENTS do
            local id = select(i, GetTrackedAchievements())
            if type(id) == "number" and id > 0 then
                idList[#idList + 1] = id
            end
        end
    end

    local achievementColor = (addon.GetQuestColor and addon.GetQuestColor("ACHIEVEMENT")) or (addon.QUEST_COLORS and addon.QUEST_COLORS.ACHIEVEMENT) or DEFAULT_ACHIEVEMENT_COLOR

    for _, achievementID in ipairs(idList) do
        if type(achievementID) ~= "number" or achievementID <= 0 then
            -- skip invalid ID
        else
            -- pcall: GetAchievementInfo can throw on invalid ID.
            local aOk, id, name, points, completed, month, day, year, description, flags, icon = pcall(GetAchievementInfo, achievementID)
            if not aOk or not name or name == "" then
                name = "Achievement " .. tostring(achievementID)
            end
            local isComplete = (completed == true) or (completed == 1)
            local showCompleted = addon.GetDB and addon.GetDB("showCompletedAchievements", false)
            if not (isComplete and not showCompleted) then
                local achievementIcon = (icon and (type(icon) == "number" or (type(icon) == "string" and icon ~= ""))) and icon or nil
                local objectives, criteriaDone, criteriaTotal = GetAchievementCriteria(achievementID)
                local numericQuantity, numericRequired = nil, nil
                if #objectives == 1 then
                    local o = objectives[1]
                    if o.numFulfilled ~= nil and o.numRequired ~= nil and type(o.numRequired) == "number" and o.numRequired > 1 then
                        numericQuantity = o.numFulfilled
                        numericRequired = o.numRequired
                        -- Check if the single objective's text is purely a restatement of the
                        -- progress (e.g. "3 / 250", "3/250", or just the achievement name).
                        -- If so, replace with the achievement description to avoid showing
                        -- progress twice (title already shows "Name (3/250)").
                        local oText = (o.text or ""):gsub("%s+", "")
                        local progressStr = tostring(o.numFulfilled) .. "/" .. tostring(o.numRequired)
                        local achName = (name or ""):gsub("%s+", "")
                        if oText == "" or oText == progressStr or oText:lower() == achName:lower() then
                            -- Use the achievement description as the objective text if available
                            if description and type(description) == "string" and description ~= "" then
                                objectives = { { text = description, finished = o.finished, percent = o.percent, numFulfilled = o.numFulfilled, numRequired = o.numRequired } }
                            else
                                objectives = {}
                            end
                        end
                    end
                end

                -- No criteria rows (or all filtered): still show achievement description when present.
                if #objectives == 0 and description and type(description) == "string" and description ~= "" then
                    objectives[1] = { text = description, finished = isComplete }
                end

                -- Single unfinished row with multi-step numeric or non-binary percent: eligible for achievement progress bar.
                -- Skip X/1 (one-step) criteria: no bar; title sanitisation hides (0/1) in FocusEntryRenderer.
                local achievementProgressBarEligible = false
                if #objectives == 1 then
                    local o = objectives[1]
                    if o and not o.finished then
                        local nf, nr = o.numFulfilled, o.numRequired
                        if nf ~= nil and nr ~= nil and type(nf) == "number" and type(nr) == "number" and nr > 1 then
                            achievementProgressBarEligible = true
                        elseif o.percent ~= nil and type(o.percent) == "number" and (nr == nil or nr > 1) then
                            achievementProgressBarEligible = true
                        end
                    end
                end

                -- Normalize percent for multi-step criteria so the renderer bar can use it without quest progressBarTypeFilter.
                if #objectives == 1 then
                    local o = objectives[1]
                    if o and o.percent == nil and o.numFulfilled ~= nil and o.numRequired ~= nil
                        and type(o.numFulfilled) == "number" and type(o.numRequired) == "number" and o.numRequired > 1 then
                        o.percent = math.floor(100 * math.min(o.numFulfilled, o.numRequired) / o.numRequired)
                    end
                end

                out[#out + 1] = {
                    entryKey        = "ach:" .. tostring(achievementID),
                    achievementID   = achievementID,
                    questID         = nil,
                    title           = name or ("Achievement " .. tostring(achievementID)),
                    objectives      = objectives,
                    criteriaDone    = criteriaTotal > 0 and criteriaDone or nil,
                    criteriaTotal   = criteriaTotal > 0 and criteriaTotal or nil,
                    numericQuantity = numericQuantity,
                    numericRequired = numericRequired,
                    color           = achievementColor,
                    category        = "ACHIEVEMENT",
                    isComplete      = isComplete,
                    isSuperTracked  = false,
                    isNearby        = false,
                    zoneName        = nil,
                    itemLink        = nil,
                    itemTexture     = nil,
                    isAchievement   = true,
                    isTracked       = true,
                    achievementIcon = achievementIcon,
                    achievementProgressBarEligible = achievementProgressBarEligible,
                }
            end
        end
    end

    return out
end

addon.ReadTrackedAchievements = ReadTrackedAchievements
