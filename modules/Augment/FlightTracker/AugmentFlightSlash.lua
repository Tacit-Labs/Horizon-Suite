--[[
    Horizon Suite - Augment / Flight Tracker - Slash Commands
    /h flight [cmd]. Registers with core via addon.RegisterSlashHandler.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment or not addon.Augment.Flight then return end
if not addon.RegisterSlashHandler then return end

local F = addon.Augment.Flight
local L = addon.L

local HSPrint = addon.HSPrint or function(msg)
    print("|cFF00CCFFHorizon Suite:|r " .. tostring(msg or ""))
end

local function HandleFlightSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "demo" or cmd == "preview" then
        F.Preview()
        return
    end

    if cmd == "edit" or cmd == "move" then
        F.ToggleEditMode()
        return
    end

    if cmd == "reset" then
        F.ResetPosition()
        HSPrint(L["FLIGHT_POSITION_RESET"])
        return
    end

    if cmd == "forget" then
        F.ForgetLearned()
        HSPrint(L["FLIGHT_FORGOT"])
        return
    end

    if cmd == "status" then
        local routes, legs = F.CountLearned()
        local active = F.GetActive()
        HSPrint("Flight tracker status:")
        HSPrint("  enabled        = " .. tostring(F.IsEnabled()))
        HSPrint("  learned routes = " .. routes .. ", legs = " .. legs)
        HSPrint(("  pace           = %.1f yd/s"):format(F.Pace()))
        if active and active.route then
            local est = active.est or {}
            HSPrint("  flying         = " .. F.RouteKey(active.route)
                .. "  est " .. (est.total and F.FormatTime(est.total) or "?")
                .. (est.exact and " (learned)" or " (estimate)"))
        end
        return
    end

    HSPrint("Flight tracker commands:")
    HSPrint("  /h flight demo    - Play a short sample flight")
    HSPrint("  /h flight edit    - Toggle moving the banner")
    HSPrint("  /h flight reset   - Reset its position")
    HSPrint("  /h flight forget  - Forget every learned flight time")
    HSPrint("  /h flight status  - Learned times and the flight in progress")
end

addon.RegisterSlashHandler("flight", HandleFlightSlash)
