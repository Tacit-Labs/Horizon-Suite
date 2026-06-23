--[[
    Horizon Suite - Augment / Skyriding - State
    DB key registry, position get/save/clear, and shared get-with-default
    helpers for the Skyriding Vigor/Speed mini-module. Mirrors the
    State/Core/Events split used by the Alerts mini-module
    (modules/Augment/Alerts/AugmentAlertsState.lua).
]]

local addon = _G.HorizonSuite
local Y = addon and addon.Augment
if not Y then return end

Y.Skyriding = Y.Skyriding or {}
local S = Y.Skyriding

-- Register this mini-module's DB keys into the shared routing table, same
-- convention every other Augment mini-module follows.
Y.DB_KEYS.skyridingEnabled                = true
Y.DB_KEYS.skyridingStyle                  = true
Y.DB_KEYS.skyridingScale                  = true
Y.DB_KEYS.skyridingPoint                  = true
Y.DB_KEYS.skyridingRelPoint                = true
Y.DB_KEYS.skyridingX                      = true
Y.DB_KEYS.skyridingY                      = true
Y.DB_KEYS.skyridingEditModeShow           = true
Y.DB_KEYS.skyridingHideWhenGroundedFull   = true
Y.DB_KEYS.skyridingSecondWindEnabled      = true
Y.DB_KEYS.skyridingWhirlingSurgeEnabled   = true
Y.DB_KEYS.skyridingWhirlingSurgeVisibility = true
Y.DB_KEYS.skyridingDerbyEnabled           = true
Y.DB_KEYS.skyridingSoundEnabled           = true
Y.DB_KEYS.skyridingShowSpeedText          = true
-- Bar style
Y.DB_KEYS.skyridingBarWidth               = true
Y.DB_KEYS.skyridingBarChargeHeight        = true
Y.DB_KEYS.skyridingBarSpeedHeight         = true
Y.DB_KEYS.skyridingBarPadding             = true
Y.DB_KEYS.skyridingBarSwapPosition        = true
-- Circular style
Y.DB_KEYS.skyridingCircularSize           = true

-- Per-style colours (3 float keys each).
for _, prefix in ipairs({
    "skyridingBarChargeColor", "skyridingBarSpeedLowColor", "skyridingBarSpeedThrillColor",
    "skyridingBarSpeedGroundSkimColor", "skyridingSecondWindColor",
    "skyridingCircularColor",
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
S.GetDB = getDB

-- ============================================================================
-- STYLES
-- ============================================================================

S.STYLE_BAR      = "bar"
S.STYLE_CIRCULAR = "circular"

function S.GetStyle()
    local D = addon.AUGMENT_DEFAULTS
    local style = getDB("skyridingStyle", D.skyridingStyle)
    if style ~= S.STYLE_BAR and style ~= S.STYLE_CIRCULAR then return S.STYLE_BAR end
    return style
end

-- Whirling Surge visibility modes (mirrors the "always / only when ready /
-- only while charging" tri-state Falcon exposes as a dropdown).
S.SURGE_VISIBILITY_ALWAYS   = 3
S.SURGE_VISIBILITY_READY    = 2
S.SURGE_VISIBILITY_CHARGING = 1

function S.ShouldShowWhirlingSurge(duration)
    local D = addon.AUGMENT_DEFAULTS
    if not getDB("skyridingWhirlingSurgeEnabled", D.skyridingWhirlingSurgeEnabled) then return false end
    local visibility = tonumber(getDB("skyridingWhirlingSurgeVisibility", D.skyridingWhirlingSurgeVisibility))
        or D.skyridingWhirlingSurgeVisibility
    if visibility == S.SURGE_VISIBILITY_ALWAYS then return true end
    if visibility == S.SURGE_VISIBILITY_READY then return duration == 0 end
    if visibility == S.SURGE_VISIBILITY_CHARGING then return duration > 2 end
    return false
end

-- @param prefix string  colour DB key prefix, e.g. "skyridingBarChargeColor"
-- @return number, number, number  r, g, b
function S.GetColor(prefix)
    local D = addon.AUGMENT_DEFAULTS
    local r = tonumber(getDB(prefix .. "R", D[prefix .. "R"])) or D[prefix .. "R"] or 1
    local g = tonumber(getDB(prefix .. "G", D[prefix .. "G"])) or D[prefix .. "G"] or 1
    local b = tonumber(getDB(prefix .. "B", D[prefix .. "B"])) or D[prefix .. "B"] or 1
    return r, g, b
end

-- ============================================================================
-- POSITION
-- Mirrors Y.GetPosition/SavePosition (the Loot toast anchor) with its own DB
-- keys, so Skyriding can be anchored independently of Loot/Alerts.
-- ============================================================================

S.DEFAULT_ANCHOR = "BOTTOM"
S.DEFAULT_X      = 0
S.DEFAULT_Y      = 220

function S.GetPosition()
    if not addon.GetDB then
        return nil, nil, S.DEFAULT_X, S.DEFAULT_Y
    end
    local pt = addon.GetDB("skyridingPoint", nil)
    local rp = addon.GetDB("skyridingRelPoint", nil)
    local px = addon.GetDB("skyridingX", S.DEFAULT_X)
    local py = addon.GetDB("skyridingY", S.DEFAULT_Y)
    return pt, rp, px, py
end

function S.SavePosition(point, relPoint, x, y)
    if not addon.SetDB then return end
    addon.SetDB("skyridingPoint", point)
    addon.SetDB("skyridingRelPoint", relPoint)
    addon.SetDB("skyridingX", x)
    addon.SetDB("skyridingY", y)
end

function S.ClearPosition()
    if not addon.SetDB then return end
    addon.SetDB("skyridingPoint", nil)
    addon.SetDB("skyridingRelPoint", nil)
    addon.SetDB("skyridingX", nil)
    addon.SetDB("skyridingY", nil)
end
