--[[
    Horizon Suite - Horizon Essence (Slash)
    /essence and /hse slash commands.
]]

local addon = _G.HorizonSuite
if not addon then return end

local function HandleEssenceSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "toggle" then
        if InCombatLockdown() then
            if addon.Print then addon.Print("Cannot toggle Essence during combat.") end
            return
        end
        addon:SetModuleEnabled("essence", not addon:IsModuleEnabled("essence"))
        if addon.Print then
            addon.Print("Essence " .. (addon:IsModuleEnabled("essence") and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r"))
        end
        return
    end

    if not addon:IsModuleEnabled("essence") then
        if addon.Print then
            addon.Print("Horizon Essence is disabled. Use /h essence toggle to enable it.")
        end
        return
    end

    if cmd == "reset" then
        if addon.Essence and addon.Essence.ApplyPosition then
            addon.Essence.ApplyPosition(true)
        end
        if addon.Print then addon.Print("Horizon Essence: Position reset to center.") end

    elseif cmd == "" or cmd == "help" then
        if addon.Print then
            addon.Print("Essence commands:")
            addon.Print("  /h essence        - Show this help")
            addon.Print("  /h essence toggle - Enable / disable Essence module")
            addon.Print("  /h essence reset  - Reset position to default")
        end

    else
        if addon.Print then addon.Print("Unknown command. Use /h essence for help.") end
    end
end

local function HandleEssenceDebugSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "" or cmd == "help" then
        if addon.Print then
            addon.Print("Essence debug commands (/h debug essence [cmd]):")
            addon.Print("  debuglive - Toggle live debug log panel (DEV_MODE required)")
        end
        return
    end

    if addon.Print then addon.Print("Unknown debug command. Use /h debug essence for help.") end
end

if addon.RegisterSlashHandler then
    addon.RegisterSlashHandler("essence", HandleEssenceSlash)
end
if addon.RegisterSlashHandlerDebug then
    addon.RegisterSlashHandlerDebug("essence", HandleEssenceDebugSlash)
end
if addon.RegisterDebugLive then
    addon.RegisterDebugLive("essence", function(v) if addon.Essence and addon.Essence.SetDebugLive then addon.Essence.SetDebugLive(v) end end)
end
