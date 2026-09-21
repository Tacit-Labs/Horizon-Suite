--[[
    Horizon Suite - Horizon Essence (Slash)
    /essence and /hse slash commands.
]]

local addon = _G.HorizonSuite
if not addon then return end

local HSPrint = addon.HSPrint or function(msg) print("|cFF00CCFFHorizon Suite - Essence:|r " .. tostring(msg or "")) end

local function HandleEssenceSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "toggle" then
        if InCombatLockdown() then
            HSPrint("Cannot toggle Essence during combat.")
            return
        end
        addon:SetModuleEnabled("essence", not addon:IsModuleEnabled("essence"))
        HSPrint("Essence " .. (addon:IsModuleEnabled("essence") and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r"))
        return
    end

    if not addon:IsModuleEnabled("essence") then
        HSPrint("Horizon Essence is disabled. Use /h essence toggle to enable it.")
        return
    end

    if cmd == "reset" then
        if addon.Essence and addon.Essence.ApplyPosition then
            addon.Essence.ApplyPosition(true)
        end
        HSPrint("Horizon Essence: Position reset to center.")

    elseif cmd == "" or cmd == "help" then
        HSPrint("Essence commands:")
        HSPrint("  /h essence        - Show this help")
        HSPrint("  /h essence toggle - Enable / disable Essence module")
        HSPrint("  /h essence reset  - Reset position to default")

    else
        HSPrint("Unknown command. Use /h essence for help.")
    end
end

local function HandleEssenceDebugSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "" or cmd == "help" then
        HSPrint("Essence debug commands (/h debug essence [cmd]):")
        HSPrint("  debuglive - Toggle live debug log panel (DEV_MODE required)")
        return
    end

    HSPrint("Unknown debug command. Use /h debug essence for help.")
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
