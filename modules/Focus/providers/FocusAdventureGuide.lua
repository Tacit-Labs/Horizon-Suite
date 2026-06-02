--[[
    Horizon Suite - Focus - Adventure Guide (Traveler's Log)
    Direct provider for tracked Traveler's Log activities. Wraps C_PerksActivities.
]]

local addon = _G.HorizonSuite

local DEFAULT_ADVENTURE_COLOR = { 0.85, 0.70, 0.30 }  -- warm gold

--- Get display info for a Traveler's Log activity.
--- @param activityID number
--- @return string name, table objectives, boolean isComplete
local function GetActivityDisplayInfo(activityID)
    local name = "Activity " .. tostring(activityID)
    local objectives = {}
    local isComplete = false

    if C_PerksActivities and C_PerksActivities.GetPerksActivityInfo then
        local ok, info = pcall(C_PerksActivities.GetPerksActivityInfo, activityID)
        if ok and info then
            if info.activityName and info.activityName ~= "" then
                name = info.activityName
            end
            if info.completed then
                isComplete = true
            end
            -- Check for criteria/requirements as objectives
            if info.requirementsList and type(info.requirementsList) == "table" then
                for _, req in ipairs(info.requirementsList) do
                    if req and req.requirementText and req.requirementText ~= "" then
                        objectives[#objectives + 1] = {
                            text = req.requirementText,
                            finished = req.completed or false,
                        }
                    end
                end
            end
        end
    end

    return name, objectives, isComplete
end

--- Build tracker rows from Traveler's Log tracked activities.
--- @return table Array of normalized entry tables
local function ReadTrackedAdventureGuide()
    local out = {}
    if not addon.GetDB("showAdventureGuide", true) then return out end
    if not C_PerksActivities or not C_PerksActivities.GetTrackedPerksActivities then return out end

    local ok, trackedData = pcall(C_PerksActivities.GetTrackedPerksActivities)
    if not ok or not trackedData then return out end

    local idList = trackedData.trackedIDs or trackedData
    if type(idList) ~= "table" then return out end

    local adventureColor = (addon.GetQuestColor and addon.GetQuestColor("ADVENTURE"))
        or (addon.QUEST_COLORS and addon.QUEST_COLORS.ADVENTURE)
        or DEFAULT_ADVENTURE_COLOR

    local autoRemove = addon.GetDB("autoRemoveCompletedAdventureGuide", true)

    for _, activityID in ipairs(idList) do
        if type(activityID) == "number" and activityID > 0 then
            local name, objectives, isComplete = GetActivityDisplayInfo(activityID)

            -- Auto-remove completed activities
            if isComplete and autoRemove then
                if C_PerksActivities.RemoveTrackedPerksActivity then
                    pcall(C_PerksActivities.RemoveTrackedPerksActivity, activityID)
                end
            else
                out[#out + 1] = {
                    entryKey            = "advguide:" .. tostring(activityID),
                    adventureGuideID    = activityID,
                    adventureGuideType  = nil,
                    questID             = nil,
                    title               = name,
                    objectives          = objectives,
                    color               = adventureColor,
                    category            = "ADVENTURE",
                    isComplete          = isComplete,
                    isSuperTracked      = false,
                    isNearby            = false,
                    zoneName            = nil,
                    itemLink            = nil,
                    itemTexture         = nil,
                    isAdventureGuide    = true,
                    isTracked           = true,
                    adventureGuideIcon  = nil,
                }
            end
        end
    end

    return out
end

addon.ReadTrackedAdventureGuide = ReadTrackedAdventureGuide

