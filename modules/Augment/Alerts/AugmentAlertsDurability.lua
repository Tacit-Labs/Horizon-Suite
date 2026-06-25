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
    local pct = GetWorstDurabilityPercent()
    local D = addon.AUGMENT_DEFAULTS
    local threshold = tonumber(A.GetDB("alertsDurabilityThreshold", D.alertsDurabilityThreshold)) or D.alertsDurabilityThreshold
    armed = not (pct and pct < threshold)
end

function M.CheckAndNotify()
    local D = addon.AUGMENT_DEFAULTS
    if not A.GetDB("alertsDurabilityEnabled", D.alertsDurabilityEnabled) then return end

    local pct = GetWorstDurabilityPercent()
    if not pct then return end
    local threshold = tonumber(A.GetDB("alertsDurabilityThreshold", D.alertsDurabilityThreshold)) or D.alertsDurabilityThreshold

    if pct < threshold then
        if armed then
            armed = false
            A.Enqueue("DURABILITY", L["ALERTS_DURABILITY_TITLE"],
                string.format(L["ALERTS_DURABILITY_BODY"], math.floor(pct)))
        end
    else
        armed = true
    end
end
