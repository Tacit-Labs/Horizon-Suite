--[[
    Horizon Suite - Meridian - Format
    Pure formatting for block values. No WoW API calls, so all of it runs in fengari.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Meridian = addon.Meridian or {}
local Meridian = addon.Meridian

local F = {}
Meridian.Format = F

--- @param hours number 0..23
--- @param minutes number 0..59
--- @param use24 boolean
--- @return string
function F.Clock(hours, minutes, use24)
    hours = math.floor(tonumber(hours) or 0)
    minutes = math.floor(tonumber(minutes) or 0)
    if use24 then return string.format("%02d:%02d", hours, minutes) end
    local period = hours >= 12 and "PM" or "AM"
    local h = hours % 12
    if h == 0 then h = 12 end
    return string.format("%d:%02d %s", h, minutes, period)
end

--- @param x number|nil 0..1
--- @param y number|nil 0..1
--- @param precision number 0, 1 or 2; anything else means 1
--- @return string|nil nil where the map gives no position
function F.Coords(x, y, precision)
    if type(x) ~= "number" or type(y) ~= "number" then return nil end
    if x == 0 and y == 0 then return nil end
    local fmt = "%.1f, %.1f"
    if precision == 0 then fmt = "%.0f, %.0f" elseif precision == 2 then fmt = "%.2f, %.2f" end
    return string.format(fmt, x * 100, y * 100)
end

function F.Perf(fps, ms)
    return string.format("%d / %d", math.floor(tonumber(fps) or 0), math.floor(tonumber(ms) or 0))
end

function F.Thousands(n)
    n = math.floor(tonumber(n) or 0)
    local neg = n < 0
    local s = tostring(neg and -n or n)
    local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if out:sub(1, 1) == "," then out = out:sub(2) end
    return (neg and "-" or "") .. out
end

--- Whole gold carried.
function F.Gold(copper)
    return F.Thousands(math.floor((tonumber(copper) or 0) / 10000))
end

--- Signed whole-gold change.
function F.GoldDelta(copper)
    copper = tonumber(copper) or 0
    local g = math.floor(math.abs(copper) / 10000)
    local sign = ""
    if g > 0 then sign = copper > 0 and "+" or "-" end
    return sign .. F.Thousands(g) .. "g"
end

--- @param slots table array of { current, maximum }
--- @return number|nil the lowest rounded percentage, or nil when no slot has durability
function F.LowestDurability(slots)
    local low
    for i = 1, #slots do
        local cur, max = slots[i][1], slots[i][2]
        if type(cur) == "number" and type(max) == "number" and max > 0 then
            local pct = math.floor(cur / max * 100 + 0.5)
            if not low or pct < low then low = pct end
        end
    end
    return low
end

function F.Percent(n)
    return tostring(math.floor((tonumber(n) or 0) + 0.5)) .. "%"
end
