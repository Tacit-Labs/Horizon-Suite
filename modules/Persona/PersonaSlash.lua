--[[
    Horizon Suite - Horizon Persona (Slash)
    /persona and /hsp slash commands.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local function HandlePersonaSlash(msg)
    if not addon:IsModuleEnabled("persona") then
        if addon.Print then
            addon.Print("Horizon Persona is disabled. Enable it in Horizon Suite options.")
        end
        return
    end

    local cmd = strtrim(msg or ""):lower()

    if cmd == "reset" then
        if addon.Persona and addon.Persona.ApplyPosition then
            addon.Persona.ApplyPosition(true)
        end
        if addon.Print then addon.Print("Horizon Persona: Position reset to center.") end

    else
        if addon.Persona and addon.Persona.Toggle then
            addon.Persona.Toggle()
        end
    end
end

SLASH_HORIZONSUITEPERSONA1 = "/persona"
SLASH_HORIZONSUITEPERSONA2 = "/hsp"
SlashCmdList["HORIZONSUITEPERSONA"] = HandlePersonaSlash

if addon.RegisterSlashHandler then
    addon.RegisterSlashHandler("persona", HandlePersonaSlash)
end
