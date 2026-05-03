--[[
    Horizon Suite - Vista - Slash Commands
    /h vista [cmd] subcommands. Registers with core via addon.RegisterSlashHandler.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Vista or not addon.RegisterSlashHandler then return end

local Vista = addon.Vista
local HSPrint = addon.HSPrint or function(msg) print("|cFF00CCFFHorizon Suite:|r " .. tostring(msg or "")) end

--- Handle /horizon vista [cmd] subcommands. Returns true if handled.
--- @param msg string Subcommand (reset, toggle, lock, scale, autozoom, buttons, help)
--- @return boolean
local function HandleVistaSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "reset" then
        Vista.ResetMinimapPosition()
        HSPrint("Vista: Minimap position reset.")
        return true
    end

    if cmd == "toggle" then
        if InCombatLockdown() then
            HSPrint("Cannot toggle Vista during combat.")
            return true
        end
        local show = not addon.GetDB("vistaShowMinimap", true)
        addon.SetDB("vistaShowMinimap", show)
        if show then Minimap:Show() else Minimap:Hide() end
        HSPrint("Vista: Minimap " .. (show and "|cFF00FF00shown|r" or "|cFFFF0000hidden|r"))
        return true
    end

    if cmd == "lock" then
        local lock = not addon.GetDB("vistaLock", true)
        addon.SetDB("vistaLock", lock)
        Minimap:SetMovable(not lock)
        HSPrint("Vista: Minimap " .. (lock and "|cFFFF0000locked|r" or "|cFF00FF00unlocked|r"))
        return true
    end

    if cmd:find("^scale") then
        local val = tonumber(cmd:match("scale%s+(.+)"))
        if val then
            local clamped = math.max(0.5, math.min(2.0, val))
            addon.SetDB("vistaScale", clamped)
            Vista.ApplyScale()
            HSPrint("Vista: Scale set to " .. tostring(clamped))
        else
            HSPrint("Vista: Usage: /h vista scale <0.5-2.0>")
        end
        return true
    end

    if cmd:find("^autozoom") then
        local val = tonumber(cmd:match("autozoom%s+(.+)"))
        if val then
            local clamped = math.max(0, math.min(30, math.floor(val)))
            addon.SetDB("vistaAutoZoom", clamped)
            Vista.ScheduleAutoZoom()
            HSPrint("Vista: Auto-zoom delay set to " .. tostring(clamped) .. "s" .. (clamped == 0 and " (disabled)" or ""))
        else
            HSPrint("Vista: Usage: /h vista autozoom <0-30>  (0 = disabled)")
        end
        return true
    end

    if cmd == "" or cmd == "help" then
        HSPrint("Vista commands:")
        HSPrint("  /h vista            - Show this help")
        HSPrint("  /h vista reset      - Reset minimap to default position")
        HSPrint("  /h vista toggle     - Show / hide minimap")
        HSPrint("  /h vista lock       - Toggle drag lock")
        HSPrint("  /h vista scale X    - Set minimap scale (0.5 – 2.0)")
        HSPrint("  /h vista autozoom X - Set auto-zoom delay in seconds (0 = off)")
        return true
    end

    return false
end

local function HandleVistaDebugSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "" or cmd == "help" then
        HSPrint("Vista debug commands (/h debug vista [cmd]):")
        HSPrint("  buttons - Print minimap button count")
        return
    end

    if cmd == "buttons" then
        local n = Vista.CollectButtons()
        HSPrint("Vista: Buttons found: " .. tostring(n))
    else
        HSPrint("Unknown debug command. Use /h debug vista for help.")
    end
end

addon.RegisterSlashHandler("vista", HandleVistaSlash)
Vista.HandleVistaSlash = HandleVistaSlash
if addon.RegisterSlashHandlerDebug then
    addon.RegisterSlashHandlerDebug("vista", HandleVistaDebugSlash)
end
