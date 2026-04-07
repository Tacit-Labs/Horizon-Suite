--[[
    Horizon Suite - Insight Cursor Anchor (simplified, EnhanceQoL-inspired)
    Minimal implementation: hook GameTooltip_SetDefaultAnchor and apply cursor or fixed positioning.
    No per-frame updates, no manual line clearing, no state tracking.
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

function Insight.HookCursorAnchor()
    GameTooltip:SetClampedToScreen(true)
    hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
        if not Insight.IsInsightEnabled() then return end
        if not tooltip or not tooltip.SetOwner then return end
        if tooltip.IsForbidden and tooltip:IsForbidden() then return end
        if parent and parent.IsForbidden and parent:IsForbidden() then return end

        local mode = GetAnchorMode()
        if mode == "fixed" then
            tooltip:ClearAllPoints()
            tooltip:SetPoint(GetFixedPoint(), UIParent, GetFixedPoint(), GetFixedX(), GetFixedY())
        end
        -- Cursor mode: let Blizzard handle ANCHOR_CURSOR natively (no SetOwner call to avoid clearing lines)
    end)
end
