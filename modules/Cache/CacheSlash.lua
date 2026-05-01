--[[
    Horizon Suite - Cache - Slash Commands
    /h cache [cmd] subcommands. Registers with core via addon.RegisterSlashHandler.
]]

local addon = _G.HorizonSuite

local Y = addon.Cache
local y = addon.cache

local HSPrint = addon.HSPrint or function(msg) print("|cFF00CCFFHorizon Suite:|r " .. tostring(msg or "")) end

--- Handle /horizon cache [cmd] subcommands. Returns true if handled.
--- @param msg string Subcommand (item, gold, currency, rep, all, toggle, edit, reset, debug, help)
--- @return boolean
function Y.HandleCacheSlash(msg)
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
        HSPrint("Cache: Demo reel...")
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
            HSPrint("Cannot toggle Cache during combat.")
            return true
        end
        addon:SetModuleEnabled("cache", not addon:IsModuleEnabled("cache"))
        HSPrint("Cache " .. (addon:IsModuleEnabled("cache") and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r"))
        return true
    end

    if cmd == "reset" then
        Y.ResetPosition()
        HSPrint("Cache position reset to default.")
        return true
    end

    if cmd == "edit" then
        Y.ToggleEditMode()
        return true
    end

    if cmd == "move" then
        Y.ToggleAnchorFrame()
        return true
    end

    if cmd == "" or cmd == "help" then
        HSPrint("Cache commands:")
        HSPrint("  /h cache          - Show this help")
        HSPrint("  /h cache item     - Test item toast")
        HSPrint("  /h cache gold     - Test money toast")
        HSPrint("  /h cache currency - Test currency toast")
        HSPrint("  /h cache rep      - Test reputation toast")
        HSPrint("  /h cache all      - Demo reel (all types)")
        HSPrint("  /h cache toggle   - Enable / disable Cache module")
        HSPrint("  /h cache edit     - Toggle edit mode (show bounding box)")
        HSPrint("  /h cache move     - Show anchor to set position")
        HSPrint("  /h cache reset    - Reset position to default")
        return true
    end

    return false
end

local function HandleCacheDebugSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "" or cmd == "help" then
        HSPrint("Cache debug commands (/h debug cache [cmd]):")
        HSPrint("  debug - Toggle loot-event logging")
        return
    end

    if cmd == "debug" then
        y.debugMode = not y.debugMode
        if y.debugMode then
            HSPrint("Cache debug |cFF00FF00ON|r - loot events will print to chat.")
            HSPrint("  playerGUID = " .. tostring(y.playerGUID))
            HSPrint("  patternsOK = " .. tostring(y.patternsOK))
            HSPrint("  selfLootPats = " .. tostring(y.selfLootPatCount or 0))
        else
            HSPrint("Cache debug |cFFFF0000OFF|r")
        end
    else
        HSPrint("Unknown debug command. Use /h debug cache for help.")
    end
end

addon.RegisterSlashHandler("cache", Y.HandleCacheSlash)
if addon.RegisterSlashHandlerDebug then
    addon.RegisterSlashHandlerDebug("cache", HandleCacheDebugSlash)
end
