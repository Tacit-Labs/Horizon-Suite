--[[
    Horizon Suite - Augment - Slash Commands
    /h augment [cmd] subcommands. Registers with core via addon.RegisterSlashHandler.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment or not addon.RegisterSlashHandler then return end

local Y = addon.Augment
local y = addon.augment

local HSPrint = addon.HSPrint or function(msg) print("|cFF00CCFFHorizon Suite:|r " .. tostring(msg or "")) end

-- ============================================================================
-- SAMPLE DATA
-- Used by both PreviewToasts and individual test commands.
-- ============================================================================

local SAMPLE = {
    item = {
        { kind="item", icon=523897, text="Dragonwrath, Tarecgosa's Rest",
          r=1.00, g=0.502, b=0.00, br=1.00, bg=0.60, bb=0.00, quality=5 },
        { kind="item", icon=2143082, text="Blanchy's Reins",
          r=0.686, g=0.224, b=1, br=0.816, bg=0.38, bb=1.00, quality=4 },
        { kind="item", icon=132926, text="Brilliant Kaliri",
          r=0.00, g=0.506, b=1, br=0.00, bg=0.696, bb=1.00, quality=3 },
        { kind="item", icon=1676424, text="Grey Tricorne Hat x2",
          r=0.118, g=1, b=0, br=0.172, bg=1, bb=0, quality=2 },
        { kind="item", icon=133589, text="Ghost Iron Ore x6",
          r=1.00, g=1.00, b=1.00, br=1.00, bg=1.00, bb=1.00, quality=1 },
        { kind="item", icon=133289, text="Scarlet Pendant",
          r=0.62, g=0.62, b=0.62, br=0.65, bg=0.65, bb=0.65, quality=0 },
    },
    money    = { kind="money",    icon=Y.MONEY_ICON, text=nil,
                 r=Y.MONEY_COLOR[1],    g=Y.MONEY_COLOR[2],    b=Y.MONEY_COLOR[3],
                 br=Y.MONEY_COLOR[1],   bg=Y.MONEY_COLOR[2],   bb=Y.MONEY_COLOR[3] },
    currency = { kind="currency", icon=135884,        text="+150 Conquest",
                 r=Y.CURRENCY_COLOR[1], g=Y.CURRENCY_COLOR[2], b=Y.CURRENCY_COLOR[3],
                 br=Y.CURRENCY_COLOR[1],bg=Y.CURRENCY_COLOR[2],bb=Y.CURRENCY_COLOR[3] },
    rep      = { kind="rep",      icon=Y.REP_ICON,    text="+500 Court of Night",
                 r=Y.REP_GAIN_COLOR[1], g=Y.REP_GAIN_COLOR[2], b=Y.REP_GAIN_COLOR[3],
                 br=Y.REP_GAIN_COLOR[1],bg=Y.REP_GAIN_COLOR[2],bb=Y.REP_GAIN_COLOR[3] },
}

local function MakeToast(tpl)
    local d = {}
    for k, v in pairs(tpl) do d[k] = v end
    d.holdDur = Y.GetHoldDur(d.kind, d.quality)
    if d.kind == "money" and not d.text then
        d.text = Y.FormatMoney and Y.FormatMoney(52, 17, 63) or "52g 17s 63c"
    end
    return d
end

-- ============================================================================
-- PREVIEW  — respects current show-toggles and hold durations
-- ============================================================================

function Y.PreviewToasts()
    if not addon:IsModuleEnabled("augment") then
        HSPrint("Augment: Module is disabled — enable it first.")
        return
    end
    if not Y.IsReady or not Y.IsReady() then
        HSPrint("Augment: Frames not yet initialized.")
        return
    end
    if Y.ClearActiveToasts then Y.ClearActiveToasts() end
    if not addon.GetDB then return end
    local queue = {}
    if addon.GetDB("augmentShowItems", true) ~= false then
        local minQ = tonumber(addon.GetDB("augmentMinQuality", 0)) or 0
        for _, tpl in ipairs(SAMPLE.item) do
            if (tpl.quality or 1) >= minQ then
                queue[#queue + 1] = MakeToast(tpl)
            end
        end
    end
    if addon.GetDB("augmentShowMoney",    true) ~= false then queue[#queue + 1] = MakeToast(SAMPLE.money)    end
    if addon.GetDB("augmentShowCurrency", true) ~= false then queue[#queue + 1] = MakeToast(SAMPLE.currency) end
    if addon.GetDB("augmentShowRep",      true) ~= false then queue[#queue + 1] = MakeToast(SAMPLE.rep)      end
    if #queue == 0 then HSPrint("Augment: All toast types are disabled."); return end
    for i, data in ipairs(queue) do
        C_Timer.After((i - 1) * 0.3, function() Y.ShowToast(data) end)
    end
end

--- Handle /horizon augment [cmd] subcommands. Returns true if handled.
--- @param msg string Subcommand
--- @return boolean
function Y.HandleAugmentSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "item" then
        Y.ShowToast(MakeToast(SAMPLE.item[2]))  -- epic (index 2)
        return true
    end

    if cmd == "gold" or cmd == "money" then
        Y.ShowToast(MakeToast(SAMPLE.money))
        return true
    end

    if cmd == "currency" then
        Y.ShowToast(MakeToast(SAMPLE.currency))
        return true
    end

    if cmd == "rep" then
        Y.ShowToast(MakeToast(SAMPLE.rep))
        return true
    end

    if cmd == "preview" then
        Y.PreviewToasts()
        return true
    end

    if cmd == "all" then
        HSPrint("Augment: Demo reel...")
        local demos = {
            function() Y.ShowToast(MakeToast(SAMPLE.item[2])) end,  -- epic
            function() Y.ShowToast(MakeToast(SAMPLE.item[3])) end,  -- rare
            function() Y.ShowToast(MakeToast(SAMPLE.item[4])) end,  -- common
            function() Y.ShowToast(MakeToast(SAMPLE.money))   end,
            function() Y.ShowToast(MakeToast(SAMPLE.currency)) end,
            function() Y.ShowToast(MakeToast(SAMPLE.rep))     end,
            function() Y.ShowToast(MakeToast(SAMPLE.item[1])) end,  -- legendary last
        }
        for i, fn in ipairs(demos) do
            C_Timer.After((i - 1) * 0.4, fn)
        end
        return true
    end

    if cmd == "toggle" then
        if InCombatLockdown() then
            HSPrint("Cannot toggle Augment during combat.")
            return true
        end
        addon:SetModuleEnabled("augment", not addon:IsModuleEnabled("augment"))
        HSPrint("Augment " .. (addon:IsModuleEnabled("augment") and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r"))
        return true
    end

    if cmd == "reset" then
        Y.ResetPosition()
        HSPrint("Augment position reset to default.")
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
        HSPrint("Augment commands:")
        HSPrint("  /h augment          - Show this help")
        HSPrint("  /h augment preview  - Preview enabled toast types")
        HSPrint("  /h augment item     - Test item toast (epic)")
        HSPrint("  /h augment gold     - Test money toast")
        HSPrint("  /h augment currency - Test currency toast")
        HSPrint("  /h augment rep      - Test reputation toast")
        HSPrint("  /h augment all      - Full demo reel (all types)")
        HSPrint("  /h augment toggle   - Enable / disable Augment module")
        HSPrint("  /h augment edit     - Toggle edit mode (show bounding box)")
        HSPrint("  /h augment move     - Show anchor to set position")
        HSPrint("  /h augment reset    - Reset position to default")
        HSPrint("  /h debug augment debug - Toggle loot event logging")
        return true
    end

    return false
end

local function HandleAugmentDebugSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "" or cmd == "help" then
        HSPrint("Augment debug commands (/h debug augment [cmd]):")
        HSPrint("  debuglive - Toggle live debug log panel")
        HSPrint("  status    - Print loot pattern and GUID state")
        return
    end

    if cmd == "debuglive" then
        if not addon.Log.isDevMode() then
            HSPrint("Debug requires DEV_MODE = true in core/Logger.lua")
            return
        end
        local v = not addon.Log.isEnabled("augment")
        if Y.SetDebugLive then Y.SetDebugLive(v) end
        HSPrint("Augment debug log: " .. (v and "on" or "off"))

    elseif cmd == "status" then
        HSPrint("Augment status:")
        HSPrint("  playerGUID   = " .. tostring(y.playerGUID))
        HSPrint("  patternsOK   = " .. tostring(y.patternsOK))
        HSPrint("  selfLootPats = " .. tostring(y.selfLootPatCount or 0))
    else
        HSPrint("Unknown debug command. Use /h debug augment for help.")
    end
end

addon.RegisterSlashHandler("augment", Y.HandleAugmentSlash)
if addon.RegisterSlashHandlerDebug then
    addon.RegisterSlashHandlerDebug("augment", HandleAugmentDebugSlash)
end
