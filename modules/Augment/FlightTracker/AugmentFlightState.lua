--[[
    Horizon Suite - Augment / Flight Tracker - State
    DB key registry, option accessors and the pure logic behind the flight
    tracker: route keys, learned flight times, estimates and formatting.

    HOW TIMES ARE KNOWN. Nothing here ships a table of flight times. Every time
    is learned from flights the player takes, account-wide, at
    HorizonDB.flightTimes:

        routes[key]  whole-route seconds, key = node ids joined by ">"
        legs[key]    one-hop seconds, from a direct flight, or derived from a
                     multi-hop route whose other legs were already known
        pace         { yards, seconds } summed over every learned flight

    A route never flown is estimated per leg: a learned leg time when there is
    one, otherwise the leg's straight-line length over the learned pace (or
    FALLBACK_PACE before anything is learned). Estimates are flagged so the
    banner can mark them with "~"; a route flown once before is exact.

    Everything below the ACCESSORS section is pure: no frames, no events. It is
    exercised by tools/test_flight_logic.js in a plain Lua VM.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment then return end

local Y = addon.Augment
Y.Flight = Y.Flight or {}
local F = Y.Flight

-- ============================================================================
-- DB KEY REGISTRY
-- ============================================================================

local KEYS = {
    "augmentFlightTrackerEnabled",
    "flightShowFlyingTo", "flightShowRoute", "flightShowStops", "flightShowOrigin",
    "flightShowTimeLeft", "flightArrivalNotice",
    "flightScale", "flightWidth", "flightOpacity", "flightBackground", "flightAccentBar",
    "flightFontPath", "flightFontSize", "flightTextOutlineType",
    "flightDestinationSize", "flightTimeSize", "flightArrivalSize",
    "flightAccentR", "flightAccentG", "flightAccentB",
    "flightPoint", "flightRelPoint", "flightX", "flightY",
}
if Y.DB_KEYS then
    for _, k in ipairs(KEYS) do Y.DB_KEYS[k] = true end
end

-- ============================================================================
-- CONSTANTS
-- ============================================================================

F.WIDTH          = 320
F.DEFAULT_ANCHOR = "TOP"
F.DEFAULT_X      = 0
F.DEFAULT_Y      = -140

-- Yards per second used before any flight has been learned. Taxi paths bend
-- around terrain, so the straight-line pace sits below the mount's true speed.
-- Only ever a first guess: the first landing replaces it with a measured pace.
F.FALLBACK_PACE  = 26

-- A flight shorter than this is a mis-detection (a vehicle, a loading hitch),
-- not a route time worth remembering.
F.MIN_LEARN_SECONDS = 8

-- Seconds the arrival notice stays up, before its fade.
F.ARRIVAL_HOLD   = 3.0
F.ARRIVAL_FADE   = 0.8

-- ============================================================================
-- ACCESSORS
-- ============================================================================

local function getDB(k, d)
    if not addon.GetDB then return d end
    local v = addon.GetDB(k, d)
    if v == nil then return d end
    return v
end
F.GetDB = getDB

local function D() return addon.AUGMENT_DEFAULTS or {} end

local function clamped(key, fallback)
    local lim = addon.AUGMENT_LIMITS and addon.AUGMENT_LIMITS[key]
    local v = tonumber(getDB(key, D()[key])) or fallback
    if lim then return math.max(lim.min, math.min(lim.max, v)) end
    return v
end

--- A boolean option, default from AUGMENT_DEFAULTS.
--- @param key string
--- @return boolean
function F.Opt(key)
    return getDB(key, D()[key]) ~= false
end

function F.GetScale()   return clamped("flightScale", 1.0) end
function F.GetWidth()   return clamped("flightWidth", F.WIDTH) end
function F.GetOpacity() return clamped("flightOpacity", 100) / 100 end
function F.GetFontSize()        return clamped("flightFontSize", 12) end
function F.GetDestinationSize() return clamped("flightDestinationSize", 20) end
function F.GetTimeSize()        return clamped("flightTimeSize", 15) end
function F.GetArrivalSize()     return clamped("flightArrivalSize", 28) end

function F.GetFontFlags()
    return getDB("flightTextOutlineType", D().flightTextOutlineType) or "OUTLINE"
end

local FONT_USE_GLOBAL = "__global__"

--- Per-element font, then the global font, then the addon default.
--- @return string
function F.GetFontPath()
    local global = addon.GetActiveGlobalFont and addon.GetActiveGlobalFont()
    if global then return global end
    local raw = getDB("flightFontPath", D().flightFontPath)
    if raw == FONT_USE_GLOBAL or raw == nil or raw == "" then
        raw = addon.GetDB and addon.GetDB("fontPath", nil) or nil
    end
    if not raw or raw == "" or raw == FONT_USE_GLOBAL then
        return (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"
    end
    local resolved = addon.ResolveFontPath and addon.ResolveFontPath(raw)
    return (resolved and resolved ~= "") and resolved or raw
end

--- The accent colour: Augment's class colour when that is on, else the picker.
--- @return number r, number g, number b
function F.GetAccentColor()
    local cc = addon.GetModuleClassColor and addon.GetModuleClassColor("augment")
    if cc then return cc[1], cc[2], cc[3] end
    local d = D()
    return tonumber(getDB("flightAccentR", d.flightAccentR)) or 0.4,
           tonumber(getDB("flightAccentG", d.flightAccentG)) or 0.8,
           tonumber(getDB("flightAccentB", d.flightAccentB)) or 1.0
end

function F.GetPosition()
    return getDB("flightPoint", nil), getDB("flightRelPoint", nil),
           getDB("flightX", F.DEFAULT_X), getDB("flightY", F.DEFAULT_Y)
end

function F.SavePosition(point, relPoint, x, y)
    if not addon.SetDB then return end
    addon.SetDB("flightPoint", point)
    addon.SetDB("flightRelPoint", relPoint)
    addon.SetDB("flightX", x)
    addon.SetDB("flightY", y)
end

function F.ClearPosition()
    F.SavePosition(nil, nil, nil, nil)
end

-- ============================================================================
-- LEARNED TIMES STORE
-- ============================================================================

local store

--- Attach to a store table (HorizonDB.flightTimes, or a test table).
--- @param tbl table
--- @return table store
function F.BindStore(tbl)
    if type(tbl) ~= "table" then return nil end
    tbl.routes = type(tbl.routes) == "table" and tbl.routes or {}
    tbl.legs   = type(tbl.legs)   == "table" and tbl.legs   or {}
    tbl.pace   = type(tbl.pace)   == "table" and tbl.pace   or { yards = 0, seconds = 0 }
    store = tbl
    return store
end

--- The bound store, binding HorizonDB.flightTimes on first use.
--- @return table|nil
function F.Store()
    if store then return store end
    local db = addon.DATABASE and _G[addon.DATABASE]
    if type(db) ~= "table" then return nil end
    db.flightTimes = db.flightTimes or {}
    return F.BindStore(db.flightTimes)
end

--- Forget every learned time.
function F.ForgetLearned()
    local s = F.Store()
    if not s then return end
    s.routes, s.legs = {}, {}
    s.pace = { yards = 0, seconds = 0 }
end

--- @return number routes, number legs
function F.CountLearned()
    local s = F.Store()
    if not s then return 0, 0 end
    local r, l = 0, 0
    for _ in pairs(s.routes) do r = r + 1 end
    for _ in pairs(s.legs) do l = l + 1 end
    return r, l
end

-- ============================================================================
-- ROUTES
-- A route is { nodes = { {id=, name=, x=, y=}, ... } } with the origin first and
-- the destination last. x/y are world yards when the client could give them.
-- ============================================================================

--- Stable key for a node: its taxi node id, else its name.
local function NodeKey(node)
    if node.id ~= nil then return tostring(node.id) end
    return tostring(node.name or "?")
end

--- @param route table
--- @return string
function F.RouteKey(route)
    local parts = {}
    for i, node in ipairs(route.nodes) do parts[i] = NodeKey(node) end
    return table.concat(parts, ">")
end

--- @return string
function F.LegKey(a, b)
    return NodeKey(a) .. ">" .. NodeKey(b)
end

--- Straight-line yards between two nodes, or nil without positions.
local function LegYards(a, b)
    if not (a.x and a.y and b.x and b.y) then return nil end
    local dx, dy = a.x - b.x, a.y - b.y
    return math.sqrt(dx * dx + dy * dy)
end
F.LegYards = LegYards

--- Learned yards per second, or the fallback.
--- @return number
function F.Pace()
    local s = F.Store()
    if s and s.pace.seconds > 0 and s.pace.yards > 0 then
        return s.pace.yards / s.pace.seconds
    end
    return F.FALLBACK_PACE
end

--- Estimate a route.
--- @param route table
--- @return table est { total = seconds|nil, exact = bool, legs = { seconds... }, stops = { fraction... } }
---   stops[i] is how far along the whole flight the i-th intermediate node sits (0..1).
function F.Estimate(route)
    local s = F.Store()
    local nodes = route.nodes
    local legs, sum, known = {}, 0, true
    for i = 1, #nodes - 1 do
        local a, b = nodes[i], nodes[i + 1]
        local t = s and s.legs[F.LegKey(a, b)]
        if not t then
            known = false
            local yards = LegYards(a, b)
            t = yards and (yards / F.Pace()) or nil
        end
        if not t then
            -- No learned time and no position: give every leg the same share.
            legs = nil
            break
        end
        legs[i] = t
        sum = sum + t
    end

    local exactTotal = s and s.routes[F.RouteKey(route)]
    local est = { exact = false, stops = {} }
    if exactTotal then
        est.total, est.exact = exactTotal, true
    elseif legs then
        est.total, est.exact = sum, known
    end

    local hops = #nodes - 1
    if hops > 1 then
        local acc = 0
        for i = 1, hops - 1 do
            if legs and sum > 0 then
                acc = acc + legs[i]
                est.stops[i] = acc / sum
            else
                est.stops[i] = i / hops
            end
        end
    end
    est.legs = legs
    return est
end

--- Record a completed flight.
--- @param route table
--- @param seconds number
--- @return boolean learned
function F.Learn(route, seconds)
    local s = F.Store()
    seconds = tonumber(seconds)
    if not s or not seconds or seconds < F.MIN_LEARN_SECONDS then return false end
    local nodes = route.nodes
    if #nodes < 2 then return false end
    seconds = math.floor(seconds + 0.5)

    s.routes[F.RouteKey(route)] = seconds

    if #nodes == 2 then
        s.legs[F.LegKey(nodes[1], nodes[2])] = seconds
    else
        -- With every leg but one known, the missing one is the remainder.
        local missing, knownSum = nil, 0
        for i = 1, #nodes - 1 do
            local k = F.LegKey(nodes[i], nodes[i + 1])
            if s.legs[k] then
                knownSum = knownSum + s.legs[k]
            elseif missing then
                missing = false
                break
            else
                missing = k
            end
        end
        if missing then
            local rest = seconds - knownSum
            if rest >= 1 then s.legs[missing] = rest end
        end
    end

    -- Pace from the straight-line length of the whole route.
    local yards = 0
    for i = 1, #nodes - 1 do
        local y = LegYards(nodes[i], nodes[i + 1])
        if not y then yards = nil break end
        yards = yards + y
    end
    if yards and yards > 0 then
        s.pace.yards = s.pace.yards + yards
        s.pace.seconds = s.pace.seconds + seconds
    end
    return true
end

-- ============================================================================
-- FORMATTING
-- ============================================================================

--- "Ironforge, Dun Morogh" → "Ironforge". Taxi node names carry their zone.
--- @param name string|nil
--- @return string
function F.ShortName(name)
    if type(name) ~= "string" then return "" end
    local short = name:match("^([^,]+)")
    return short and (short:gsub("%s+$", "")) or name
end

--- Seconds as m:ss, or h:mm:ss past an hour.
--- @param seconds number
--- @return string
function F.FormatTime(seconds)
    seconds = math.max(0, math.floor((tonumber(seconds) or 0) + 0.5))
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local sec = seconds % 60
    if h > 0 then return string.format("%d:%02d:%02d", h, m, sec) end
    return string.format("%d:%02d", m, sec)
end

--- Progress and the time text for a flight in progress.
--- @param est table From F.Estimate
--- @param elapsed number Seconds since take-off
--- @return number progress 0..1 (nil when there is no total to measure against)
--- @return string kind "left"|"due"|"elapsed"
--- @return number|nil seconds For "left" the time remaining, for "elapsed" the time flown
function F.Progress(est, elapsed)
    elapsed = math.max(0, tonumber(elapsed) or 0)
    if not est.total or est.total <= 0 then
        return nil, "elapsed", elapsed
    end
    local remaining = est.total - elapsed
    local progress = math.min(1, elapsed / est.total)
    if remaining <= 0 then return 1, "due", nil end
    return progress, "left", remaining
end
