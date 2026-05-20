--[[
    Horizon Suite - Horizon Essence (Slash)
    /essence and /hse slash commands.
]]

local addon = _G.HorizonSuite
if not addon then return end

local function HandleEssenceSlash(msg)
    if not addon:IsModuleEnabled("essence") then
        if addon.Print then
            addon.Print("Horizon Essence is disabled. Enable it in Horizon Suite options.")
        end
        return
    end

    local cmd = strtrim(msg or ""):lower()

    if cmd == "reset" then
        if addon.Essence and addon.Essence.ApplyPosition then
            addon.Essence.ApplyPosition(true)
        end
        if addon.Print then addon.Print("Horizon Essence: Position reset to center.") end

    else
        if addon.Essence and addon.Essence.Toggle then
            addon.Essence.Toggle()
        end
    end
end

SLASH_HORIZONSUITEESSENCE1 = "/essence"
SLASH_HORIZONSUITEESSENCE2 = "/hse"
SlashCmdList["HORIZONSUITEESSENCE"] = HandleEssenceSlash

local function HandleEssenceDebugSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "" or cmd == "help" then
        if addon.Print then
            addon.Print("Essence debug commands (/h debug essence [cmd]):")
            addon.Print("  debuglive - Toggle live debug log panel")
        end
        return
    end

    if cmd == "debuglive" then
        if not addon.Log.isDevMode() then
            if addon.Print then addon.Print("Debug requires DEV_MODE = true in core/Logger.lua") end
            return
        end
        local v = not addon.Log.isEnabled("essence")
        if addon.Essence and addon.Essence.SetDebugLive then addon.Essence.SetDebugLive(v) end
        if addon.Print then addon.Print("Essence debug log: " .. (v and "on" or "off")) end
    else
        if addon.Print then addon.Print("Unknown debug command. Use /h debug essence for help.") end
    end
end

if addon.RegisterSlashHandler then
    addon.RegisterSlashHandler("essence", HandleEssenceSlash)
end
if addon.RegisterSlashHandlerDebug then
    addon.RegisterSlashHandlerDebug("essence", HandleEssenceDebugSlash)
end
