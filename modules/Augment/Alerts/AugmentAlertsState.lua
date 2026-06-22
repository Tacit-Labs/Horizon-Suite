--[[
    Horizon Suite - Augment / Alerts - State
    Shared constants, DB key registry, and safe-string helpers for the Alerts
    mini-module (durability, bags, mail, vault, friends). Architecture is
    modelled on HKDToasts (see Roadmap §8.2 "Notification System"): a single
    Enqueue entry point, per-kind enable flags, a combat-deferral queue, a
    baseline-snapshot pattern so the first event of a session can't fire a
    false alert, and pcall-wrapped string handling for WoW's "secret string"
    values. Sound cooldown is centralised in the queue (AugmentAlertsQueue.lua)
    rather than re-implemented per kind, which HKDToasts did inconsistently.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment then return end

local Y = addon.Augment
Y.Alerts = Y.Alerts or {}
local A = Y.Alerts

-- Register this mini-module's DB keys into the shared routing table so
-- OptionsData.lua dispatches writes without a manual allowlist.
Y.DB_KEYS.augmentAlertsEnabled      = true
Y.DB_KEYS.alertsDurabilityEnabled   = true
Y.DB_KEYS.alertsDurabilityThreshold = true
Y.DB_KEYS.alertsBagsEnabled         = true
Y.DB_KEYS.alertsBagsThreshold       = true
Y.DB_KEYS.alertsMailEnabled         = true
Y.DB_KEYS.alertsVaultEnabled        = true
Y.DB_KEYS.alertsFriendsEnabled      = true
Y.DB_KEYS.alertsSoundEnabled        = true
Y.DB_KEYS.alertsSoundCooldown       = true
Y.DB_KEYS.alertsMaxVisible          = true
Y.DB_KEYS.alertsScale               = true
Y.DB_KEYS.alertsFontPath            = true
Y.DB_KEYS.alertsEditModeShow        = true
Y.DB_KEYS.alertsPoint               = true
Y.DB_KEYS.alertsRelPoint            = true
Y.DB_KEYS.alertsX                   = true
Y.DB_KEYS.alertsY                   = true
Y.DB_KEYS.alertsDebugLive           = true

-- Explicit nil-check so a stored `false` is not silently replaced by the default.
local function getDB(k, d)
    if not addon.GetDB then return d end
    local v = addon.GetDB(k, d)
    if v == nil then return d end
    return v
end
A.GetDB = getDB

-- ============================================================================
-- KNOWN KINDS
-- Every kind module below must be listed here so an unknown/mistyped kind
-- fails safe (Enqueue no-ops) instead of rendering a blank toast.
-- ============================================================================

A.KNOWN_KINDS = {
    DURABILITY = true,
    BAGS       = true,
    MAIL       = true,
    VAULT      = true,
    FRIEND_ON  = true,
    FRIEND_OFF = true,
}

A.KIND_ICONS = {
    DURABILITY = "Interface\\Icons\\Trade_BlackSmithing",
    BAGS       = "Interface\\Icons\\INV_Misc_Bag_08",
    MAIL       = "Interface\\Icons\\INV_Letter_15",
    VAULT      = "Interface\\Icons\\INV_Crate_03",
    FRIEND_ON  = "Interface\\FriendsFrame\\StatusIcon-Online",
    FRIEND_OFF = "Interface\\FriendsFrame\\StatusIcon-Offline",
}

A.KIND_COLORS = {
    DURABILITY = { 0.90, 0.30, 0.20 },
    BAGS       = { 0.90, 0.70, 0.20 },
    MAIL       = { 0.30, 0.70, 1.00 },
    VAULT      = { 0.65, 0.40, 0.95 },
    FRIEND_ON  = { 0.20, 0.90, 0.30 },
    FRIEND_OFF = { 0.60, 0.60, 0.60 },
}

A.KIND_SOUNDS = {
    DURABILITY = (SOUNDKIT and SOUNDKIT.UI_BNET_TOAST_DEFAULT) or 80638,
    BAGS       = (SOUNDKIT and SOUNDKIT.UI_BNET_TOAST_DEFAULT) or 80638,
    MAIL       = (SOUNDKIT and SOUNDKIT.UI_BNET_TOAST_DEFAULT) or 80638,
    VAULT      = (SOUNDKIT and SOUNDKIT.UI_RAID_BOSS_WHISPER_WARNING) or 8959,
    FRIEND_ON  = (SOUNDKIT and SOUNDKIT.FRIEND_LIST_ONLINE) or 7996,
    FRIEND_OFF = (SOUNDKIT and SOUNDKIT.FRIEND_LIST_OFFLINE) or 7997,
}

-- ============================================================================
-- SAFE STRING HELPERS
-- WoW can hand event payloads "secret string" values (combat/instance string
-- hardening) that throw on any string method. Any external string (a friend's
-- name, etc.) must pass through here before touching :lower/:find/concat.
-- ============================================================================

function A.SafeString(v)
    if v == nil then return "" end
    local ok, s = pcall(tostring, v)
    if not ok or type(s) ~= "string" then return "" end
    -- gsub returns a new string; on a "secret" source this fails safely under pcall.
    local ok2, cleaned = pcall(function() return (s:gsub("%z", "")) end)
    if ok2 and type(cleaned) == "string" then return cleaned end
    return ""
end

-- ============================================================================
-- POSITION
-- Mirrors Y.GetPosition/SavePosition (the Loot toast anchor) but with its own
-- DB keys, so the Alerts stack can be anchored independently of loot toasts.
-- ============================================================================

A.DEFAULT_ANCHOR = "TOP"
A.DEFAULT_X      = 0
A.DEFAULT_Y      = -180

function A.GetPosition()
    if not addon.GetDB then
        return nil, nil, A.DEFAULT_X, A.DEFAULT_Y
    end
    local pt = addon.GetDB("alertsPoint", nil)
    local rp = addon.GetDB("alertsRelPoint", nil)
    local px = addon.GetDB("alertsX", A.DEFAULT_X)
    local py = addon.GetDB("alertsY", A.DEFAULT_Y)
    return pt, rp, px, py
end

function A.SavePosition(point, relPoint, x, y)
    if not addon.SetDB then return end
    addon.SetDB("alertsPoint", point)
    addon.SetDB("alertsRelPoint", relPoint)
    addon.SetDB("alertsX", x)
    addon.SetDB("alertsY", y)
end
