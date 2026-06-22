--[[
    Horizon Suite - Augment / Alerts - Great Vault
    Fires once per "rewards became available" transition, mirroring the Mail
    kind's pattern. This naturally re-arms across weekly resets too:
    C_WeeklyRewards.HasAvailableRewards() drops back to false at reset (no
    qualifying activity yet for the new week), so the next time it flips true
    is a genuinely new alert — no reset-time math needed.
]]

local addon = _G.HorizonSuite
local Y = addon and addon.Augment
local A = Y and Y.Alerts
if not A then return end

local M = {}
A.Vault = M

local hadRewards = false

local function HasRewards()
    return C_WeeklyRewards and C_WeeklyRewards.HasAvailableRewards and C_WeeklyRewards.HasAvailableRewards() and true or false
end

function M.SetBaseline()
    hadRewards = HasRewards()
end

function M.CheckAndNotify()
    local D = addon.AUGMENT_DEFAULTS
    if not A.GetDB("alertsVaultEnabled", D.alertsVaultEnabled) then return end

    local has = HasRewards()
    if has and not hadRewards then
        A.Enqueue("VAULT", addon.L["ALERTS_VAULT_TITLE"], addon.L["ALERTS_VAULT_BODY"])
    end
    hadRewards = has
end
