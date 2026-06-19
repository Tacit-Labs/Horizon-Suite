--[[
    Horizon Suite - Augment - Achievement Tracker
    Automatically removes earned achievements from the tracking list when they
    are completed, and cleans up any already-completed tracked achievements on
    enable.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment then return end

local Y = addon.Augment

Y.DB_KEYS.augmentAchievementTrackerEnabled = true

-- Legacy globals absent from LuaLS WoW stubs; localise so nil-checks work correctly.
---@diagnostic disable-next-line: undefined-field
local GetTrackedAchievements   = _G.GetTrackedAchievements
---@diagnostic disable-next-line: undefined-field
local RemoveTrackedAchievement = _G.RemoveTrackedAchievement

-- ============================================================================
-- API shims — C_ContentTracking (TWW+) with legacy fallbacks
-- ============================================================================

local TRACK_TYPE = (Enum and Enum.ContentTrackingType and Enum.ContentTrackingType.Achievement) or 2
local STOP_TYPE  = (Enum and Enum.ContentTrackingStopType and Enum.ContentTrackingStopType.Manual)

local function UntrackAchievement(id)
    if TRACK_TYPE and STOP_TYPE and C_ContentTracking and C_ContentTracking.StopTracking then
        pcall(C_ContentTracking.StopTracking, TRACK_TYPE, id, STOP_TYPE)
    elseif RemoveTrackedAchievement then
        RemoveTrackedAchievement(id)
    end
end

local function GetTrackedIDs()
    local ids = {}
    if C_ContentTracking and C_ContentTracking.GetTrackedIDs then
        local ok, result = pcall(C_ContentTracking.GetTrackedIDs, TRACK_TYPE)
        if ok and result then
            for _, id in ipairs(result) do
                if type(id) == "number" and id > 0 then ids[#ids + 1] = id end
            end
        end
    elseif GetTrackedAchievements then
        for i = 1, 10 do
            local id = select(i, GetTrackedAchievements())
            if type(id) == "number" and id > 0 then ids[#ids + 1] = id end
        end
    end
    return ids
end

-- ============================================================================
-- Core logic
-- ============================================================================

local function IsCompleted(achievementID)
    local _, _, _, completed = GetAchievementInfo(achievementID)
    return completed == true
end

local function UntrackIfCompleted(achievementID)
    if not achievementID then return end
    if IsCompleted(achievementID) then UntrackAchievement(achievementID) end
end

local function ScanTracked()
    for _, id in ipairs(GetTrackedIDs()) do
        UntrackIfCompleted(id)
    end
end

-- ============================================================================
-- Event frame
-- ============================================================================

local eventFrame = CreateFrame("Frame")

eventFrame:SetScript("OnEvent", function(_, event, achievementID)
    if event == "ACHIEVEMENT_EARNED" then
        UntrackIfCompleted(achievementID)
    end
end)

-- ============================================================================
-- Public API (addon.Augment.AchievementTracker)
-- ============================================================================

local AT = {}
Y.AchievementTracker = AT

function AT.Enable()
    eventFrame:RegisterEvent("ACHIEVEMENT_EARNED")
    ScanTracked()
end

function AT.Disable()
    eventFrame:UnregisterAllEvents()
end
