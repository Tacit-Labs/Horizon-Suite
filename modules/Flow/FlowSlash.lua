--[[
    Horizon Suite - Flow (Slash)
    /h flow slash commands.

    `restore` exists because the failure this module most needs to survive is a
    player stuck mid-quest-chain looking at a broken frame. It tears Flow down
    without touching the module's enabled flag, so the quest is turn-in-able
    again immediately and no reload is required.
]]

local addon = _G.HorizonSuite
if not addon then return end

local HSPrint = addon.HSPrint or function(msg) print("|cFF3399FFHorizon Suite - Flow:|r " .. tostring(msg or "")) end

local function HandleFlowSlash(msg)
    local cmd = strtrim(msg or ""):lower()
    local F = addon.Flow

    if cmd == "toggle" then
        if InCombatLockdown() then
            HSPrint("Cannot toggle Flow during combat.")
            return
        end
        addon:SetModuleEnabled("flow", not addon:IsModuleEnabled("flow"))
        HSPrint("Flow " .. (addon:IsModuleEnabled("flow") and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r"))
        return
    end

    -- Deliberately reachable while the module is off: the point of restore is
    -- recovering a frame that is already wrong.
    if cmd == "restore" then
        if F and F.Disable then F.Disable() end
        HSPrint("Blizzard quest frame restored. Re-enable under Axis, or /reload.")
        return
    end

    if not addon:IsModuleEnabled("flow") then
        HSPrint("Flow is disabled. Use /h flow toggle to enable it.")
        return
    end

    if cmd == "restyle" then
        if F and F.Restyle then F.Restyle() end
        HSPrint("Quest frame repainted.")

    elseif cmd == "status" then
        local activeNow = F and F.IsActive and F.IsActive()
        local templates = F and F.TemplatesInstalled and F.TemplatesInstalled()
        HSPrint("Flow status:")
        HSPrint("  Dressing quest frame: " .. (activeNow and "yes" or "no"))
        HSPrint("  Templates rewritten:  " .. (templates and "yes" or "no"))

    elseif cmd == "" or cmd == "help" then
        HSPrint("Flow commands:")
        HSPrint("  /h flow         - Show this help")
        HSPrint("  /h flow toggle  - Enable / disable Flow module")
        HSPrint("  /h flow status  - Show what Flow is currently doing")
        HSPrint("  /h flow restyle - Repaint the quest frame now")
        HSPrint("  /h flow restore - Put Blizzard's quest frame back without a reload")

    else
        HSPrint("Unknown command. Use /h flow for help.")
    end
end

if addon.RegisterSlashHandler then
    addon.RegisterSlashHandler("flow", HandleFlowSlash)
end
