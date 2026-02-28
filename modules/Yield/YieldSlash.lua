--[[
    Horizon Suite - Yield - Slash Commands
    /h yield [cmd] subcommands. Registers with core via addon.RegisterSlashHandler.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.Yield or not addon.RegisterSlashHandler then return end

local Y = addon.Yield
local y = addon.yield

local HSPrint = addon.HSPrint or function(msg) print("|cFF00CCFFHorizon Suite:|r " .. tostring(msg or "")) end

--- Handle /horizon yield [cmd] subcommands. Returns true if handled.
--- @param msg string Subcommand (item, gold, currency, rep, all, toggle, edit, reset, debug, help)
--- @return boolean
function Y.HandleYieldSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "item" then
        Y.ShowToast({
            icon = 135349, text = "Ashkandur, Fall of the Brotherhood",
            r = 0.64, g = 0.21, b = 0.93, br = 0.77, bg = 0.25, bb = 1.0,
            holdDur = Y.HOLD_EPIC, quality = 4,
        })
        return true
    end

    if cmd == "gold" or cmd == "money" then
        Y.ShowToast({
            icon = Y.MONEY_ICON, text = Y.FormatMoney(127, 43, 85),
            r = Y.MONEY_COLOR[1], g = Y.MONEY_COLOR[2], b = Y.MONEY_COLOR[3],
            br = Y.MONEY_COLOR[1], bg = Y.MONEY_COLOR[2], bb = Y.MONEY_COLOR[3],
            holdDur = Y.HOLD_MONEY,
        })
        return true
    end

    if cmd == "currency" then
        Y.ShowToast({
            icon = 135884, text = "+150 Conquest",
            r = Y.CURRENCY_COLOR[1], g = Y.CURRENCY_COLOR[2], b = Y.CURRENCY_COLOR[3],
            br = Y.CURRENCY_COLOR[1], bg = Y.CURRENCY_COLOR[2], bb = Y.CURRENCY_COLOR[3],
            holdDur = Y.HOLD_CURRENCY,
        })
        return true
    end

    if cmd == "rep" then
        Y.ShowToast({
            icon = Y.REP_ICON, text = "+200 The Assembly of the Deeps",
            r = Y.REP_GAIN_COLOR[1], g = Y.REP_GAIN_COLOR[2], b = Y.REP_GAIN_COLOR[3],
            br = Y.REP_GAIN_COLOR[1], bg = Y.REP_GAIN_COLOR[2], bb = Y.REP_GAIN_COLOR[3],
            holdDur = Y.HOLD_REP,
        })
        return true
    end

    if cmd == "all" then
        HSPrint("Yield: Demo reel...")
        local demos = {
            function()
                Y.ShowToast({
                    icon = 135349, text = "Ashkandur, Fall of the Brotherhood",
                    r = 0.64, g = 0.21, b = 0.93, br = 0.77, bg = 0.25, bb = 1.0,
                    holdDur = Y.HOLD_EPIC, quality = 4,
                })
            end,
            function()
                Y.ShowToast({
                    icon = 133727, text = "Enchanted Opal x2",
                    r = 0.00, g = 0.44, b = 0.87, br = 0.00, bg = 0.53, bb = 1.00,
                    holdDur = Y.HOLD_ITEM,
                })
            end,
            function()
                Y.ShowToast({
                    icon = 133589, text = "Dreamfoil x5",
                    r = 1, g = 1, b = 1, br = 1, bg = 1, bb = 1,
                    holdDur = Y.HOLD_ITEM,
                })
            end,
            function()
                Y.ShowToast({
                    icon = Y.MONEY_ICON, text = Y.FormatMoney(52, 17, 63),
                    r = Y.MONEY_COLOR[1], g = Y.MONEY_COLOR[2], b = Y.MONEY_COLOR[3],
                    br = Y.MONEY_COLOR[1], bg = Y.MONEY_COLOR[2], bb = Y.MONEY_COLOR[3],
                    holdDur = Y.HOLD_MONEY,
                })
            end,
            function()
                Y.ShowToast({
                    icon = 135884, text = "+150 Conquest",
                    r = Y.CURRENCY_COLOR[1], g = Y.CURRENCY_COLOR[2], b = Y.CURRENCY_COLOR[3],
                    br = Y.CURRENCY_COLOR[1], bg = Y.CURRENCY_COLOR[2], bb = Y.CURRENCY_COLOR[3],
                    holdDur = Y.HOLD_CURRENCY,
                })
            end,
            function()
                Y.ShowToast({
                    icon = Y.REP_ICON, text = "+200 The Assembly of the Deeps",
                    r = Y.REP_GAIN_COLOR[1], g = Y.REP_GAIN_COLOR[2], b = Y.REP_GAIN_COLOR[3],
                    br = Y.REP_GAIN_COLOR[1], bg = Y.REP_GAIN_COLOR[2], bb = Y.REP_GAIN_COLOR[3],
                    holdDur = Y.HOLD_REP,
                })
            end,
            function()
                Y.ShowToast({
                    icon = 135352, text = "Thunderfury, Blessed Blade of the Windseeker",
                    r = 1.00, g = 0.50, b = 0.00, br = 1.00, bg = 0.60, bb = 0.00,
                    holdDur = Y.HOLD_LEGENDARY, quality = 5,
                })
            end,
        }
        for i, fn in ipairs(demos) do
            C_Timer.After((i - 1) * 0.4, fn)
        end
        return true
    end

    if cmd == "toggle" then
        if InCombatLockdown() then
            HSPrint("Cannot toggle Yield during combat.")
            return true
        end
        addon:SetModuleEnabled("yield", not addon:IsModuleEnabled("yield"))
        HSPrint("Yield " .. (addon:IsModuleEnabled("yield") and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r"))
        return true
    end

    if cmd == "reset" then
        Y.ResetPosition()
        HSPrint("Yield position reset to default.")
        return true
    end

    if cmd == "edit" then
        Y.ToggleEditMode()
        return true
    end

    if cmd == "" or cmd == "help" then
        HSPrint("Yield commands:")
        HSPrint("  /h yield          - Show this help")
        HSPrint("  /h yield item     - Test item toast")
        HSPrint("  /h yield gold     - Test money toast")
        HSPrint("  /h yield currency - Test currency toast")
        HSPrint("  /h yield rep      - Test reputation toast")
        HSPrint("  /h yield all      - Demo reel (all types)")
        HSPrint("  /h yield toggle   - Enable / disable Yield module")
        HSPrint("  /h yield edit     - Toggle edit mode (show bounding box)")
        HSPrint("  /h yield reset    - Reset position to default")
        return true
    end

    return false
end

local function HandleYieldDebugSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "" or cmd == "help" then
        HSPrint("Yield debug commands (/h debug yield [cmd]):")
        HSPrint("  debug - Toggle loot-event logging")
        return
    end

    if cmd == "debug" then
        y.debugMode = not y.debugMode
        if y.debugMode then
            HSPrint("Yield debug |cFF00FF00ON|r - loot events will print to chat.")
            HSPrint("  playerGUID = " .. tostring(y.playerGUID))
            HSPrint("  patternsOK = " .. tostring(y.patternsOK))
            HSPrint("  selfLootPats = " .. tostring(y.selfLootPatCount or 0))
        else
            HSPrint("Yield debug |cFFFF0000OFF|r")
        end
    else
        HSPrint("Unknown debug command. Use /h debug yield for help.")
    end
end

addon.RegisterSlashHandler("yield", Y.HandleYieldSlash)
if addon.RegisterSlashHandlerDebug then
    addon.RegisterSlashHandlerDebug("yield", HandleYieldDebugSlash)
end
