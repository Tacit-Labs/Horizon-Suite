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

if addon.RegisterSlashHandler then
    addon.RegisterSlashHandler("essence", HandleEssenceSlash)
end
