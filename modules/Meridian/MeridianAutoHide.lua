--[[
    Horizon Suite - Meridian - Auto-hide
    Pure state machine for the bar's slide: whether it should be out, how far out it is,
    and its alpha. The bar feeds it inputs every frame; nothing here touches a frame.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Meridian = addon.Meridian or {}
local Meridian = addon.Meridian

local A = {}
Meridian.AutoHide = A

A.SLIDE_TIME = 0.15  -- seconds for a full slide
A.HIDE_DELAY = 1.5   -- seconds after the mouse leaves before the bar slides away
A.EDGE_ZONE = 4      -- px at the screen edge that bring the bar back

--- @param shown boolean start out (true) or away (false)
function A.New(shown)
    return { progress = shown and 1 or 0, sinceHover = shown and 0 or A.HIDE_DELAY }
end

--- Advance one frame.
-- @param s table state from New
-- @param dt number seconds
-- @param inp table { autoHide, keepOutOfCombat, inCombat, hovering, combatMode, fadeAlpha }
-- @return number progress 0..1, number alpha 0..1
function A.Step(s, dt, inp)
    if inp.hovering then s.sinceHover = 0 else s.sinceHover = (s.sinceHover or A.HIDE_DELAY) + dt end

    local want = (not inp.autoHide) or inp.hovering or s.sinceHover < A.HIDE_DELAY
        or (inp.keepOutOfCombat and not inp.inCombat)
    if inp.inCombat and inp.combatMode == "hide" then want = false end

    local target = want and 1 or 0
    local stepAmount = dt / A.SLIDE_TIME
    if s.progress < target then
        s.progress = math.min(target, s.progress + stepAmount)
    elseif s.progress > target then
        s.progress = math.max(target, s.progress - stepAmount)
    end

    local alpha = 1
    if inp.inCombat and inp.combatMode == "fade" and not inp.hovering then alpha = inp.fadeAlpha or 0.3 end
    return s.progress, alpha
end

--- @param edge string "top" | "bottom"
--- @param cursorY number|nil cursor height in UIParent units, from the bottom
--- @param screenHeight number UIParent height
--- @param zone number px
function A.CursorInZone(edge, cursorY, screenHeight, zone)
    if type(cursorY) ~= "number" then return false end
    if edge == "bottom" then return cursorY <= zone end
    return cursorY >= (screenHeight or 0) - zone
end
