--[[
    Horizon Suite - Cache - Slash Commands
    /h cache [cmd] subcommands. Registers with core via addon.RegisterSlashHandler.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Cache or not addon.RegisterSlashHandler then return end

local Y = addon.Cache
local y = addon.cache

local HSPrint = addon.HSPrint or function(msg) print("|cFF00CCFFHorizon Suite:|r " .. tostring(msg or "")) end

-- ============================================================================
-- SAMPLE DATA
-- Used by both PreviewToasts and individual test commands.
-- ============================================================================

local SAMPLE = {
    item = {
        { kind="item", icon=135352, text="Thunderfury, Blessed Blade of the Windseeker",
          r=1.00, g=0.50, b=0.00, br=1.00, bg=0.60, bb=0.00, quality=5 },
        { kind="item", icon=135349, text="Ashkandur, Fall of the Brotherhood",
          r=0.64, g=0.21, b=0.93, br=0.77, bg=0.25, bb=1.00, quality=4 },
        { kind="item", icon=133727, text="Enchanted Opal x2",
          r=0.00, g=0.44, b=0.87, br=0.00, bg=0.53, bb=1.00, quality=3 },
        { kind="item", icon=133589, text="Dreamfoil x5",
          r=1.00, g=1.00, b=1.00, br=1.00, bg=1.00, bb=1.00, quality=1 },
        { kind="item", icon=134432, text="Cracked Buckler",
          r=0.62, g=0.62, b=0.62, br=0.65, bg=0.65, bb=0.65, quality=0 },
    },
    money    = { kind="money",    icon=Y.MONEY_ICON, text=nil,
                 r=Y.MONEY_COLOR[1],    g=Y.MONEY_COLOR[2],    b=Y.MONEY_COLOR[3],
                 br=Y.MONEY_COLOR[1],   bg=Y.MONEY_COLOR[2],   bb=Y.MONEY_COLOR[3] },
    currency = { kind="currency", icon=135884,        text="+150 Conquest",
                 r=Y.CURRENCY_COLOR[1], g=Y.CURRENCY_COLOR[2], b=Y.CURRENCY_COLOR[3],
                 br=Y.CURRENCY_COLOR[1],bg=Y.CURRENCY_COLOR[2],bb=Y.CURRENCY_COLOR[3] },
    rep      = { kind="rep",      icon=Y.REP_ICON,    text="+350 Valdrakken Accord",
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
    if not addon:IsModuleEnabled("cache") then
        HSPrint("Cache: Module is disabled — enable it first.")
        return
    end
    if not Y.IsReady or not Y.IsReady() then
        HSPrint("Cache: Frames not yet initialized.")
        return
    end
    if Y.ClearActiveToasts then Y.ClearActiveToasts() end
    if not addon.GetDB then return end
    local queue = {}
    if addon.GetDB("cacheShowItems", true) ~= false then
        local minQ = tonumber(addon.GetDB("cacheMinQuality", 0)) or 0
        for _, tpl in ipairs(SAMPLE.item) do
            if (tpl.quality or 1) >= minQ then
                queue[#queue + 1] = MakeToast(tpl)
            end
        end
    end
    if addon.GetDB("cacheShowMoney",    true) ~= false then queue[#queue + 1] = MakeToast(SAMPLE.money)    end
    if addon.GetDB("cacheShowCurrency", true) ~= false then queue[#queue + 1] = MakeToast(SAMPLE.currency) end
    if addon.GetDB("cacheShowRep",      true) ~= false then queue[#queue + 1] = MakeToast(SAMPLE.rep)      end
    if #queue == 0 then HSPrint("Cache: All toast types are disabled."); return end
    for i, data in ipairs(queue) do
        C_Timer.After((i - 1) * 0.3, function() Y.ShowToast(data) end)
    end
end

--- Handle /horizon cache [cmd] subcommands. Returns true if handled.
--- @param msg string Subcommand
--- @return boolean
function Y.HandleCacheSlash(msg)
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
        HSPrint("Cache: Demo reel...")
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
        HSPrint("  /h cache preview  - Preview enabled toast types")
        HSPrint("  /h cache item     - Test item toast (epic)")
        HSPrint("  /h cache gold     - Test money toast")
        HSPrint("  /h cache currency - Test currency toast")
        HSPrint("  /h cache rep      - Test reputation toast")
        HSPrint("  /h cache all      - Full demo reel (all types)")
        HSPrint("  /h cache toggle   - Enable / disable Cache module")
        HSPrint("  /h cache edit     - Toggle edit mode (show bounding box)")
        HSPrint("  /h cache move     - Show anchor to set position")
        HSPrint("  /h cache reset    - Reset position to default")
        HSPrint("  /h debug cache debug - Toggle loot event logging")
        return true
    end

    return false
end

local function HandleCacheDebugSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "" or cmd == "help" then
        HSPrint("Cache debug commands (/h debug cache [cmd]):")
        HSPrint("  debuglive - Toggle live debug log panel")
        HSPrint("  status    - Print loot pattern and GUID state")
        return
    end

    if cmd == "debuglive" then
        if not addon.Log.isDevMode() then
            HSPrint("Debug requires DEV_MODE = true in core/Logger.lua")
            return
        end
        local v = not addon.Log.isEnabled("cache")
        if Y.SetDebugLive then Y.SetDebugLive(v) end
        HSPrint("Cache debug log: " .. (v and "on" or "off"))

    elseif cmd == "status" then
        HSPrint("Cache status:")
        HSPrint("  playerGUID   = " .. tostring(y.playerGUID))
        HSPrint("  patternsOK   = " .. tostring(y.patternsOK))
        HSPrint("  selfLootPats = " .. tostring(y.selfLootPatCount or 0))
    else
        HSPrint("Unknown debug command. Use /h debug cache for help.")
    end
end

addon.RegisterSlashHandler("cache", Y.HandleCacheSlash)
if addon.RegisterSlashHandlerDebug then
    addon.RegisterSlashHandlerDebug("cache", HandleCacheDebugSlash)
end
