--[[
    Horizon Suite - Augment / Alerts - Bags
    Warns once when bag space drops to/below the configured free-space
    threshold, and re-arms once space frees back up.
]]

local addon = _G.HorizonSuite
local L = addon.L
local Y = addon and addon.Augment
local A = Y and Y.Alerts
if not A then return end

local M = {}
A.Bags = M

local armed = true
local reminderTimer

local function GetFullPercent()
    local total, free = 0, 0
    for bag = 0, NUM_BAG_SLOTS do
        local slots = C_Container.GetContainerNumSlots(bag)
        if slots and slots > 0 then
            total = total + slots
            free  = free + (C_Container.GetContainerNumFreeSlots(bag) or 0)
        end
    end
    if total == 0 then return nil end
    return ((total - free) / total) * 100
end

local function GetBagStats()
    local total, free = 0, 0
    for bag = 0, NUM_BAG_SLOTS do
        local slots = C_Container.GetContainerNumSlots(bag)
        if slots and slots > 0 then
            total = total + slots
            free = free + (C_Container.GetContainerNumFreeSlots(bag) or 0)
        end
    end
    if total == 0 then return nil end
    return total, free
end

function M.SetBaseline()
    if reminderTimer and reminderTimer.Cancel then reminderTimer:Cancel() end
    reminderTimer = nil
    local fullPct = GetFullPercent()
    local D = addon.AUGMENT_DEFAULTS
    local threshold = tonumber(A.GetDB("alertsBagsThreshold", D.alertsBagsThreshold)) or D.alertsBagsThreshold
    armed = not (fullPct and fullPct >= threshold)
end

local function getReminderMinutes()
    local D = addon.AUGMENT_DEFAULTS
    local mode = A.GetDB("alertsBagsReminder", D.alertsBagsReminder)
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

local function isNearFull()
    local D = addon.AUGMENT_DEFAULTS
    local fullPct = GetFullPercent()
    if not fullPct then return false, nil end
    local threshold = tonumber(A.GetDB("alertsBagsThreshold", D.alertsBagsThreshold)) or D.alertsBagsThreshold
    return fullPct >= threshold, fullPct
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
        if not A.GetDB("alertsBagsEnabled", D.alertsBagsEnabled) then return end
        local nearFull, fullPct = isNearFull()
        if nearFull then
            A.Enqueue("BAGS", L["ALERTS_BAGS_TITLE"], string.format(L["ALERTS_BAGS_BODY"], math.floor(fullPct)))
            maybeScheduleReminder()
        else
            armed = true
        end
    end)
end

function M.CheckAndNotify()
    local D = addon.AUGMENT_DEFAULTS
    if not A.GetDB("alertsBagsEnabled", D.alertsBagsEnabled) then return end

    local nearFull, fullPct = isNearFull()
    if fullPct == nil then return end

    if nearFull then
        if armed then
            armed = false
            A.Enqueue("BAGS", L["ALERTS_BAGS_TITLE"],
                string.format(L["ALERTS_BAGS_BODY"], math.floor(fullPct)))
        end
        maybeScheduleReminder()
    else
        armed = true
        stopReminder()
    end
end

function M.RefreshReminderState()
    local D = addon.AUGMENT_DEFAULTS
    if not A.GetDB("alertsBagsEnabled", D.alertsBagsEnabled) then
        armed = true
        stopReminder()
        return
    end
    local nearFull = isNearFull()
    armed = not nearFull
    if nearFull then
        maybeScheduleReminder()
    else
        stopReminder()
    end
end

function M.GetThresholdHint()
    local D = addon.AUGMENT_DEFAULTS
    local threshold = tonumber(A.GetDB("alertsBagsThreshold", D.alertsBagsThreshold)) or D.alertsBagsThreshold
    local total, free = GetBagStats()
    if not total then
        return L["AUGMENT_ALERTS_BAGS_THRESHOLD_DESC"]
    end

    local maxFree = math.floor(total * (100 - threshold) / 100)
    return string.format(
        "%s\n\nWith your current bag capacity, this triggers at %d or fewer free slots total.\n\nIf you are already above the threshold when you enable Alerts, it waits until bags dip back below it and fill up again.",
        L["AUGMENT_ALERTS_BAGS_THRESHOLD_DESC"],
        maxFree
    )
end
