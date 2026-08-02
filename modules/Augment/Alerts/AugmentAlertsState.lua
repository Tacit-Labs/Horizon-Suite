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

A.ENTRANCE_DUR = Y.ToastMotion.ENTRANCE_DUR
A.EXIT_DUR     = Y.ToastMotion.EXIT_DUR
A.SLIDE_DIST   = Y.ToastMotion.SLIDE_DIST
A.NUDGE_SPEED  = Y.ToastMotion.NUDGE_SPEED

-- Register this mini-module's DB keys into the shared routing table so
-- OptionsData.lua dispatches writes without a manual allowlist.
Y.DB_KEYS.augmentAlertsEnabled      = true
Y.DB_KEYS.alertsDurabilityEnabled   = true
Y.DB_KEYS.alertsDurabilityThreshold = true
Y.DB_KEYS.alertsDurabilityReminder  = true
Y.DB_KEYS.alertsBagsEnabled         = true
Y.DB_KEYS.alertsBagsThreshold       = true
Y.DB_KEYS.alertsBagsReminder       = true
Y.DB_KEYS.alertsMailEnabled         = true
Y.DB_KEYS.alertsVaultEnabled        = true
Y.DB_KEYS.alertsFriendsEnabled      = true
Y.DB_KEYS.alertsSoundEnabled        = true
Y.DB_KEYS.alertsSoundCooldown       = true
Y.DB_KEYS.alertsMaxVisible          = true
Y.DB_KEYS.alertsScale               = true
Y.DB_KEYS.alertsOpacity             = true
Y.DB_KEYS.alertsFontPath            = true
Y.DB_KEYS.alertsFontSize            = true
Y.DB_KEYS.alertsHoldDuration        = true
Y.DB_KEYS.alertsEditModeShow        = true
Y.DB_KEYS.alertsPoint               = true
Y.DB_KEYS.alertsRelPoint            = true
Y.DB_KEYS.alertsX                   = true
Y.DB_KEYS.alertsY                   = true
Y.DB_KEYS.alertsDebugLive           = true
Y.DB_KEYS.alertsSoundChannel        = true
Y.DB_KEYS.alertsSoundDurability     = true
Y.DB_KEYS.alertsSoundBags           = true
Y.DB_KEYS.alertsSoundMail           = true
Y.DB_KEYS.alertsSoundVault          = true
Y.DB_KEYS.alertsSoundFriends        = true
Y.DB_KEYS.alertsToastStyle          = true
Y.DB_KEYS.alertsTextOutlineType     = true
Y.DB_KEYS.alertsIconSize            = true
Y.DB_KEYS.alertsIconGap             = true
Y.DB_KEYS.alertsIconSide            = true
Y.DB_KEYS.alertsSlideSide           = true
Y.DB_KEYS.alertsGrowDirection       = true

-- Per-kind colours (3 float keys each, mirrors talkingHeadNameColorR/G/B).
for _, prefix in ipairs({
    "alertsDurabilityColor", "alertsBagsColor", "alertsMailColor",
    "alertsVaultColor", "alertsFriendOnColor", "alertsFriendOffColor",
}) do
    Y.DB_KEYS[prefix .. "R"] = true
    Y.DB_KEYS[prefix .. "G"] = true
    Y.DB_KEYS[prefix .. "B"] = true
end

-- Explicit nil-check so a stored `false` is not silently replaced by the default.
local function getDB(k, d)
    if not addon.GetDB then return d end
    local v = addon.GetDB(k, d)
    if v == nil then return d end
    return v
end
A.GetDB = getDB

--- Return the normalized alerts-toast style.
--- @return string styleID "compact", "framed", or "accent"
function A.GetToastStyle()
    local D = addon.AUGMENT_DEFAULTS
    local raw = A.GetDB("alertsToastStyle", D.alertsToastStyle)
    local TS = Y.ToastStyles
    return (TS and TS.Normalize and TS.Normalize(raw)) or "framed"
end

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
    VAULT      = { atlas = "GreatVault-32x32" },
    FRIEND_ON  = "Interface\\FriendsFrame\\StatusIcon-Online",
    FRIEND_OFF = "Interface\\FriendsFrame\\StatusIcon-Offline",
}

-- Maps each kind to its colour's DB key prefix (see OptionsAugmentAlerts.lua
-- for the matching colour pickers and OptionsDefaultsAugmentAlerts.lua for defaults).
local KIND_COLOR_PREFIX = {
    DURABILITY = "alertsDurabilityColor",
    BAGS       = "alertsBagsColor",
    MAIL       = "alertsMailColor",
    VAULT      = "alertsVaultColor",
    FRIEND_ON  = "alertsFriendOnColor",
    FRIEND_OFF = "alertsFriendOffColor",
}

-- @param kind string  one of A.KNOWN_KINDS
-- @return number, number, number  r, g, b (falls back to white if the kind is unknown)
function A.GetKindColor(kind)
    local prefix = KIND_COLOR_PREFIX[kind]
    if not prefix then return 1, 1, 1 end
    local D = addon.AUGMENT_DEFAULTS
    local r = tonumber(getDB(prefix .. "R", D[prefix .. "R"])) or D[prefix .. "R"] or 1
    local g = tonumber(getDB(prefix .. "G", D[prefix .. "G"])) or D[prefix .. "G"] or 1
    local b = tonumber(getDB(prefix .. "B", D[prefix .. "B"])) or D[prefix .. "B"] or 1
    return r, g, b
end

-- Maps each kind to its own sound-mute DB key. FRIEND_ON/FRIEND_OFF share one
-- key ("Friends") since they're a single toggle in the Alert Types section too.
local KIND_SOUND_KEY = {
    DURABILITY = "alertsSoundDurability",
    BAGS       = "alertsSoundBags",
    MAIL       = "alertsSoundMail",
    VAULT      = "alertsSoundVault",
    FRIEND_ON  = "alertsSoundFriends",
    FRIEND_OFF = "alertsSoundFriends",
}

-- @param kind string  one of A.KNOWN_KINDS
-- @return boolean  whether this kind's sound is muted independently of the master alertsSoundEnabled switch
function A.IsSoundEnabledForKind(kind)
    local key = KIND_SOUND_KEY[kind]
    if not key then return true end
    local D = addon.AUGMENT_DEFAULTS
    return getDB(key, D[key]) ~= false
end

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

-- Layout enums: icon side, slide-in side, stack grow direction.
-- @return number
function A.GetIconSize()
    local D = addon.AUGMENT_DEFAULTS
    local lim = addon.AUGMENT_LIMITS and addon.AUGMENT_LIMITS.alertsIconSize
    local v = tonumber(A.GetDB("alertsIconSize", D.alertsIconSize)) or D.alertsIconSize
    if lim then
        return math.max(lim.min, math.min(lim.max, v))
    end
    return v
end

-- @return number
function A.GetIconGap()
    local D = addon.AUGMENT_DEFAULTS
    local lim = addon.AUGMENT_LIMITS and addon.AUGMENT_LIMITS.alertsIconGap
    local v = tonumber(A.GetDB("alertsIconGap", D.alertsIconGap)) or D.alertsIconGap
    if lim then
        return math.max(lim.min, math.min(lim.max, v))
    end
    return v
end

-- @return string "left"|"right"
function A.GetIconSide()
    local D = addon.AUGMENT_DEFAULTS
    local v = A.GetDB("alertsIconSide", D.alertsIconSide)
    if v == "right" then return "right" end
    return "left"
end

-- @return string "left"|"right"
function A.GetSlideSide()
    local D = addon.AUGMENT_DEFAULTS
    local v = A.GetDB("alertsSlideSide", D.alertsSlideSide)
    if v == "left" then return "left" end
    return "right"
end

-- @return string "up"|"down"
function A.GetGrowDirection()
    local D = addon.AUGMENT_DEFAULTS
    local v = A.GetDB("alertsGrowDirection", D.alertsGrowDirection)
    if v == "up" then return "up" end
    return "down"
end

-- Vertical attach edge for toast entries (TOP or BOTTOM).
-- @return string
function A.GetEntryAttachPoint()
    return (A.GetGrowDirection() == "up") and "BOTTOM" or "TOP"
end

-- Sign for entrance slideX (+1 from right, -1 from left).
-- @return number
function A.GetSlideSign()
    return (A.GetSlideSide() == "left") and -1 or 1
end

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

function A.ClearPosition()
    if not addon.SetDB then return end
    addon.SetDB("alertsPoint", nil)
    addon.SetDB("alertsRelPoint", nil)
    addon.SetDB("alertsX", nil)
    addon.SetDB("alertsY", nil)
end
