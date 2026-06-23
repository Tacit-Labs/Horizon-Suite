--[[
    Horizon Suite - Augment / FlightTimer - Tooltip
    Adds a duration line to taxi-node and flight-map-pin tooltips before a
    route is taken. Hook installers are called from
    AugmentFlightTimerEvents.lua's source-caching pass, once per button/pin.
]]

local addon = _G.HorizonSuite
local Y = addon and addon.Augment
local F = Y and Y.FlightTimer
if not F then return end

local L = addon.L
local gtt = GameTooltip

F.Tooltip = F.Tooltip or {}
local T = F.Tooltip

local function AddDurationLine(seconds, estimated)
    if seconds and seconds > 0 then
        gtt:AddLine(L["FLIGHT_TIMER_DURATION"] .. (estimated and "~" or "") .. F.Bar.FormatTime(seconds), 1, 1, 1)
    else
        gtt:AddLine(L["FLIGHT_TIMER_DURATION"] .. "-:--", 0.8, 0.8, 0.8)
    end
    gtt:Show()
end

function T.HookTaxiButton(slotIndex)
    local button = _G["TaxiButton" .. slotIndex]
    if not button or button.flightTimerHooked then return end
    button.flightTimerHooked = true

    button:HookScript("OnEnter", function(self)
        if not F.enabled then return end
        local id = self:GetID()
        if TaxiNodeGetType(id) ~= "REACHABLE" then return end

        local dstNodeID = F.GetNodeIDForSlot(id)
        local dstNodes = F.GetDstNodes(F.taxiSrc)
        local duration = dstNodes and dstNodes[dstNodeID]
        if duration then
            AddDurationLine(duration * F.KhazAlgarFlightMasterFactor(dstNodeID), false)
        else
            AddDurationLine(F.GetEstimatedTime(F.taxiSrc, id, F.GetViewedTaxiMapID()), true)
        end
    end)
end

function T.HookFlightMapPin(pin)
    if pin.flightTimerHooked then return end
    pin.flightTimerHooked = true

    pin:HookScript("OnEnter", function(self)
        if not F.enabled then return end
        if self.taxiNodeData.state ~= Enum.FlightPathState.Reachable or GetTaxiMapID() == 994 then return end

        local dstNodeID = self.taxiNodeData.nodeID
        local dstNodes = F.GetDstNodes(F.taxiSrc)
        local duration = dstNodes and dstNodes[dstNodeID]
        if duration then
            AddDurationLine(duration * F.KhazAlgarFlightMasterFactor(dstNodeID), false)
        else
            AddDurationLine(F.GetEstimatedTime(F.taxiSrc, self.taxiNodeData.slotIndex, F.GetViewedTaxiMapID()), true)
        end
    end)
end
