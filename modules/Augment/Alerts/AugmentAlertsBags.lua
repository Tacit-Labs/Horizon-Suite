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

function M.SetBaseline()
    local fullPct = GetFullPercent()
    local D = addon.AUGMENT_DEFAULTS
    local threshold = tonumber(A.GetDB("alertsBagsThreshold", D.alertsBagsThreshold)) or D.alertsBagsThreshold
    armed = not (fullPct and fullPct >= threshold)
end

function M.CheckAndNotify()
    local D = addon.AUGMENT_DEFAULTS
    if not A.GetDB("alertsBagsEnabled", D.alertsBagsEnabled) then return end

    local fullPct = GetFullPercent()
    if not fullPct then return end
    local threshold = tonumber(A.GetDB("alertsBagsThreshold", D.alertsBagsThreshold)) or D.alertsBagsThreshold

    if fullPct >= threshold then
        if armed then
            armed = false
            A.Enqueue("BAGS", L["ALERTS_BAGS_TITLE"],
                string.format(L["ALERTS_BAGS_BODY"], math.floor(fullPct)))
        end
    else
        armed = true
    end
end
