--[[
    Horizon Suite - Augment / Loot Roll - Slash Commands
    /h roll [cmd]. Registers with core via addon.RegisterSlashHandler.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment or not addon.Augment.Roll then return end
if not addon.RegisterSlashHandler then return end

local R = addon.Augment.Roll

local HSPrint = addon.HSPrint or function(msg)
    print("|cFF00CCFFHorizon Suite:|r " .. tostring(msg or ""))
end

local function HandleRollSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "demo" then
        R.Demo.Run()
        return
    end

    if cmd == "clear" then
        R.Demo.Clear()
        R.ClearAllRolls()
        return
    end

    if cmd == "edit" or cmd == "move" then
        R.ToggleEditMode()
        return
    end

    if cmd == "reset" then
        R.ResetPosition()
        HSPrint("Loot roll position reset to default.")
        return
    end

    if cmd == "toggle" then
        local D = addon.AUGMENT_DEFAULTS
        local now = R.GetDB("augmentLootRollEnabled", D.augmentLootRollEnabled) ~= false
        if addon.SetDB then addon.SetDB("augmentLootRollEnabled", not now) end
        if not now then R.Enable() else R.Disable() end
        HSPrint("Loot rolls " .. (not now and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r"))
        return
    end

    if cmd == "status" then
        local P = addon.Platform
        HSPrint("Loot roll status:")
        HSPrint("  client         = " .. (P and P.name or "?"))
        HSPrint("  groupLootRolls = " .. tostring(P and P.Has("groupLootRolls")))
        HSPrint("  lootHistory    = " .. tostring(P and P.Has("lootHistory")))
        HSPrint("  specs          = " .. tostring(P and P.Has("specs")) ..
            "  (off-spec Need is collapsed into Need when false)")
        HSPrint("  module enabled = " .. tostring(R.IsEnabled()))
        HSPrint("  frames ready   = " .. tostring(R.IsReady()))
        HSPrint("  rows showing   = " .. tostring(R.HasActiveRows()))
        return
    end

    if cmd == "" or cmd == "help" then
        HSPrint("Loot roll commands:")
        HSPrint("  /h roll          - Show this help")
        HSPrint("  /h roll demo     - Show fabricated rolls (works solo, buttons inert)")
        HSPrint("  /h roll clear    - Clear every roll frame on screen")
        HSPrint("  /h roll edit     - Toggle edit mode to reposition the stack")
        HSPrint("  /h roll reset    - Reset position to default")
        HSPrint("  /h roll toggle   - Enable / disable the loot roll frames")
        HSPrint("  /h roll status   - Print client capabilities and module state")
        HSPrint("  /h platform probe - Ask this client what group loot reports")
        return
    end

    HSPrint("Unknown loot roll command. Use /h roll for help.")
end

addon.RegisterSlashHandler("roll", HandleRollSlash)

if addon.RegisterDebugLive then
    addon.RegisterDebugLive("lootroll", function(v)
        if R.SetDebugLive then R.SetDebugLive(v) end
    end)
end
