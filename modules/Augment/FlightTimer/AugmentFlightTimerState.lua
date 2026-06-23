--[[
    Horizon Suite - Augment / FlightTimer - State
    DB key registry, bar position get/save/clear, shared get-with-default
    helper, and the account-wide (non-profile) store for flight times learned
    from actual play. Mirrors the State/Core/Events split used by the
    Skyriding and Alerts mini-modules (modules/Augment/Skyriding/AugmentSkyridingState.lua).
]]

local addon = _G.HorizonSuite
local Y = addon and addon.Augment
if not Y then return end

Y.FlightTimer = Y.FlightTimer or {}
local F = Y.FlightTimer

-- Register this mini-module's DB keys into the shared routing table, same
-- convention every other Augment mini-module follows.
Y.DB_KEYS.flightTimerEnabled          = true
Y.DB_KEYS.flightTimerLayout           = true
Y.DB_KEYS.flightTimerCountUp          = true
Y.DB_KEYS.flightTimerConfirmFlight    = true
Y.DB_KEYS.flightTimerChatLog          = true
Y.DB_KEYS.flightTimerWidth            = true
Y.DB_KEYS.flightTimerHeight           = true
Y.DB_KEYS.flightTimerFontPath         = true
Y.DB_KEYS.flightTimerFontSize         = true
Y.DB_KEYS.flightTimerPoint            = true
Y.DB_KEYS.flightTimerRelPoint         = true
Y.DB_KEYS.flightTimerX                = true
Y.DB_KEYS.flightTimerY                = true

for _, prefix in ipairs({
    "flightTimerBarColor", "flightTimerUnknownColor", "flightTimerFontColor",
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
F.GetDB = getDB

-- ============================================================================
-- LAYOUT
-- ============================================================================

F.LAYOUT_NORMAL  = "normal"   -- source -> dest on one line, time on the next
F.LAYOUT_TWOLINE = "twoline"  -- alias kept distinct from NORMAL for clarity in options
F.LAYOUT_INLINE  = "inline"   -- destination and time share one line

function F.GetLayout()
    local D = addon.AUGMENT_DEFAULTS
    local layout = getDB("flightTimerLayout", D.flightTimerLayout)
    if layout ~= F.LAYOUT_NORMAL and layout ~= F.LAYOUT_TWOLINE and layout ~= F.LAYOUT_INLINE then
        return F.LAYOUT_NORMAL
    end
    return layout
end

-- @param prefix string  colour DB key prefix, e.g. "flightTimerBarColor"
-- @return number, number, number  r, g, b
function F.GetColor(prefix)
    local D = addon.AUGMENT_DEFAULTS
    local r = tonumber(getDB(prefix .. "R", D[prefix .. "R"])) or D[prefix .. "R"] or 1
    local g = tonumber(getDB(prefix .. "G", D[prefix .. "G"])) or D[prefix .. "G"] or 1
    local b = tonumber(getDB(prefix .. "B", D[prefix .. "B"])) or D[prefix .. "B"] or 1
    return r, g, b
end

-- ============================================================================
-- POSITION
-- Mirrors Y.GetPosition/SavePosition (the Loot toast anchor) with its own DB
-- keys, so the FlightTimer bar can be anchored independently.
-- ============================================================================

F.DEFAULT_ANCHOR = "CENTER"
F.DEFAULT_X      = 0
F.DEFAULT_Y      = -170

function F.GetPosition()
    if not addon.GetDB then
        return nil, nil, F.DEFAULT_X, F.DEFAULT_Y
    end
    local pt = addon.GetDB("flightTimerPoint", nil)
    local rp = addon.GetDB("flightTimerRelPoint", nil)
    local px = addon.GetDB("flightTimerX", F.DEFAULT_X)
    local py = addon.GetDB("flightTimerY", F.DEFAULT_Y)
    return pt, rp, px, py
end

function F.SavePosition(point, relPoint, x, y)
    if not addon.SetDB then return end
    addon.SetDB("flightTimerPoint", point)
    addon.SetDB("flightTimerRelPoint", relPoint)
    addon.SetDB("flightTimerX", x)
    addon.SetDB("flightTimerY", y)
end

function F.ClearPosition()
    if not addon.SetDB then return end
    addon.SetDB("flightTimerPoint", nil)
    addon.SetDB("flightTimerRelPoint", nil)
    addon.SetDB("flightTimerX", nil)
    addon.SetDB("flightTimerY", nil)
end

-- ============================================================================
-- LEARNED FLIGHT TIMES
-- Account-wide (not per-profile, like the bundled dataset it overlays), so
-- corrections made on one character/profile benefit every character. Stored
-- directly on the root SavedVariables table rather than through
-- addon.GetDB/SetDB, which are profile-scoped.
-- ============================================================================

local function rootDB()
    if not addon.EnsureDB then return nil end
    addon.EnsureDB()
    return _G[addon.DATABASE]
end

-- @return table|nil  root.flightTimerLearned[faction][srcNodeID][dstNodeID] = seconds
function F.GetLearnedData()
    local db = rootDB()
    if not db then return nil end
    db.flightTimerLearned = db.flightTimerLearned or {}
    return db.flightTimerLearned
end

-- Records (or updates) a single learned flight duration.
function F.SetLearnedTime(faction, srcNodeID, dstNodeID, seconds)
    local learned = F.GetLearnedData()
    if not learned or not faction or not srcNodeID or not dstNodeID then return end
    learned[faction] = learned[faction] or {}
    learned[faction][srcNodeID] = learned[faction][srcNodeID] or {}
    learned[faction][srcNodeID][dstNodeID] = seconds
end

-- Clears all self-learned corrections without touching the bundled dataset.
function F.ResetLearnedData()
    local db = rootDB()
    if not db then return end
    db.flightTimerLearned = {}
end
