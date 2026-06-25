--[[
    Horizon Suite - Augment / Alerts - Durability
    Warns once when equipped durability drops below the configured threshold,
    and re-arms only after it recovers above it (i.e. after a repair) — a
    single configurable threshold rather than HKDToasts' three fixed tiers
    (70/30/10%).
]]

local addon = _G.HorizonSuite
local L = addon.L
local Y = addon and addon.Augment
local A = Y and Y.Alerts
if not A then return end

local M = {}
A.Durability = M

local armed = true
local reminderTimer

local function GetWorstDurabilityPercent()
    local worst
    for slot = 1, 19 do
        local cur, max = GetInventoryItemDurability(slot)
        if cur and max and max > 0 then
            local pct = (cur / max) * 100
            if not worst or pct < worst then worst = pct end
        end
    end
    return worst
end

-- Snapshot current state at login/zone so the first UPDATE_INVENTORY_DURABILITY
-- of the session can't fire a false alert for gear that was already damaged
-- before Alerts loaded.
function M.SetBaseline()
    if reminderTimer and reminderTimer.Cancel then reminderTimer:Cancel() end
    reminderTimer = nil
    local pct = GetWorstDurabilityPercent()
    local D = addon.AUGMENT_DEFAULTS
    local threshold = tonumber(A.GetDB("alertsDurabilityThreshold", D.alertsDurabilityThreshold)) or D.alertsDurabilityThreshold
    armed = not (pct and pct < threshold)
end

local function getReminderMinutes()
    local D = addon.AUGMENT_DEFAULTS
    local mode = A.GetDB("alertsDurabilityReminder", D.alertsDurabilityReminder)
    if mode == "1min" then return 1 end
    if mode == "5min" then return 5 end
    if mode == "10min" then return 10 end
    if mode == "30min" then return 30 end
    return 0
end

local function stopReminder()
    if reminderTimer and reminderTimer.Cancel then reminderTimer:Cancel() end
    reminderTimer = nil
end

local function isBelowThreshold()
    local D = addon.AUGMENT_DEFAULTS
    local pct = GetWorstDurabilityPercent()
    if not pct then return false, nil end
    local threshold = tonumber(A.GetDB("alertsDurabilityThreshold", D.alertsDurabilityThreshold)) or D.alertsDurabilityThreshold
    return pct < threshold, pct
end

local function maybeScheduleReminder()
    if reminderTimer then return end
    local minutes = getReminderMinutes()
    if minutes <= 0 then
        stopReminder()
        return
    end
    reminderTimer = C_Timer.NewTimer(minutes * 60, function()
        reminderTimer = nil
        local D = addon.AUGMENT_DEFAULTS
        if not A.GetDB("alertsDurabilityEnabled", D.alertsDurabilityEnabled) then return end
        local belowThreshold, pct = isBelowThreshold()
        if belowThreshold then
            A.Enqueue("DURABILITY", L["ALERTS_DURABILITY_TITLE"], string.format(L["ALERTS_DURABILITY_BODY"], math.floor(pct)))
            maybeScheduleReminder()
        else
            armed = true
        end
    end)
end

function M.CheckAndNotify()
    local D = addon.AUGMENT_DEFAULTS
    if not A.GetDB("alertsDurabilityEnabled", D.alertsDurabilityEnabled) then return end

    local belowThreshold, pct = isBelowThreshold()
    if pct == nil then return end

    if belowThreshold then
        if armed then
            armed = false
            A.Enqueue("DURABILITY", L["ALERTS_DURABILITY_TITLE"],
                string.format(L["ALERTS_DURABILITY_BODY"], math.floor(pct)))
        end
        maybeScheduleReminder()
    else
        armed = true
        stopReminder()
    end
end

function M.RefreshReminderState()
    local D = addon.AUGMENT_DEFAULTS
    if not A.GetDB("alertsDurabilityEnabled", D.alertsDurabilityEnabled) then
        armed = true
        stopReminder()
        return
    end
    local belowThreshold = isBelowThreshold()
    armed = not belowThreshold
    if belowThreshold then
        maybeScheduleReminder()
    else
        stopReminder()
    end
end
