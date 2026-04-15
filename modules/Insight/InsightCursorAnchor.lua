--[[
    Horizon Suite - Insight Cursor Anchor
    Hook GameTooltip_SetDefaultAnchor and apply cursor-side or fixed positioning.
    Anchor changes are deferred to the next tick via C_Timer.NewTimer so the
    secure post-hook never mutates the tooltip synchronously inside Blizzard's
    tooltip-update chain (prevents widget-set taint on map / POI tooltips —
    see modules/Insight/CLAUDE.md).
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then _G.HorizonSuite = {} end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

addon.Insight = addon.Insight or {}
local Insight = addon.Insight

local FIXED_POINT = Insight.FIXED_POINT
local FIXED_X     = Insight.FIXED_X
local FIXED_Y     = Insight.FIXED_Y

local function GetAnchorMode()
    return addon.GetDB("insightAnchorMode", Insight.DEFAULT_ANCHOR)
end

local function GetFixedPoint()
    return addon.GetDB("insightFixedPoint", FIXED_POINT)
end

local function GetFixedX()
    return tonumber(addon.GetDB("insightFixedX", FIXED_X)) or FIXED_X
end

local function GetFixedY()
    return tonumber(addon.GetDB("insightFixedY", FIXED_Y)) or FIXED_Y
end

local function GetCursorSide()
    return addon.GetDB("insightCursorSide", "center")
end

local function GetCursorOffsetX()
    return tonumber(addon.GetDB("insightCursorOffsetX", 0)) or 0
end

local function GetCursorOffsetY()
    return tonumber(addon.GetDB("insightCursorOffsetY", 0)) or 0
end

local function IsOwnedByWorldMap(frame)
    if not frame or not _G.WorldMapFrame then return false end
    local cur = frame
    for _ = 1, 8 do
        if not cur then return false end
        if cur == _G.WorldMapFrame then return true end
        if type(cur.GetParent) ~= "function" then return false end
        cur = cur:GetParent()
    end
    return false
end

local function IsUsable(tooltip)
    if not tooltip or not tooltip.SetOwner then return false end
    if tooltip.IsForbidden and tooltip:IsForbidden() then return false end
    return true
end

function Insight.HookCursorAnchor()
    GameTooltip:SetClampedToScreen(true)
    hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
        if not Insight.IsInsightEnabled() then return end
        if not IsUsable(tooltip) then return end
        if parent and parent.IsForbidden and parent:IsForbidden() then return end

        -- Skip custom anchoring for tooltips owned by the world map: keeps
        -- Blizzard's native anchor and avoids a one-frame jump.
        local ownerForCheck = parent or (tooltip.GetOwner and tooltip:GetOwner())
        if IsOwnedByWorldMap(ownerForCheck) then return end

        local mode = GetAnchorMode()
        if mode ~= "cursor" and mode ~= "fixed" then return end

        -- Capture config now so the deferred closure uses the values that
        -- were in effect at hook time.
        local cursorSide, cursorOffX, cursorOffY
        local fixedPoint, fixedX, fixedY
        if mode == "cursor" then
            cursorSide = GetCursorSide()
            if cursorSide ~= "left" and cursorSide ~= "right" then
                -- "center": let Blizzard handle ANCHOR_CURSOR natively.
                return
            end
            cursorOffX = GetCursorOffsetX()
            cursorOffY = GetCursorOffsetY()
        else -- "fixed"
            fixedPoint = GetFixedPoint()
            fixedX = GetFixedX()
            fixedY = GetFixedY()
        end

        -- Coalesce repeated SetDefaultAnchor calls on the same tooltip.
        local pending = tooltip._insightAnchorTimer
        if pending then
            if type(pending.Cancel) == "function" then
                pending:Cancel()
            end
            tooltip._insightAnchorTimer = nil
        end

        tooltip._insightAnchorTimer = C_Timer.NewTimer(0, function()
            tooltip._insightAnchorTimer = nil
            if not Insight.IsInsightEnabled() then return end
            if not IsUsable(tooltip) then return end

            if mode == "cursor" then
                if not parent then return end
                if parent.IsForbidden and parent:IsForbidden() then return end
                local anchor = (cursorSide == "left") and "ANCHOR_CURSOR_LEFT" or "ANCHOR_CURSOR_RIGHT"
                tooltip:SetOwner(parent, anchor, cursorOffX, cursorOffY)
            else -- "fixed"
                tooltip:ClearAllPoints()
                tooltip:SetPoint(fixedPoint, UIParent, fixedPoint, fixedX, fixedY)
            end
        end)
    end)
end
