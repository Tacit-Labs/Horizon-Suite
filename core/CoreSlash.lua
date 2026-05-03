--[[
    Horizon Suite - Core Slash Commands
    Centralized /h and /horizon handler. Core commands (options, edit, help) and dispatcher to module handlers.
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then _G.HorizonSuite = {} end
local addon = _G.HorizonSuite

local HSPrint = addon.HSPrint or function(msg) print("|cFF00CCFFHorizon Suite:|r " .. tostring(msg or "")) end

-- ============================================================================
-- MODULE REGISTRY
-- ============================================================================

addon.slashHandlers = addon.slashHandlers or {}
addon.slashHandlersDebug = addon.slashHandlersDebug or {}

--- Register a module's slash handler. Called by each module at load.
--- @param moduleKey string  "focus"|"presence"|"vista"|"cache"|"insight"
--- @param handler function(msg)  Receives remainder after module name (e.g. "toggle" for /h focus toggle)
function addon.RegisterSlashHandler(moduleKey, handler)
    if not moduleKey or type(handler) ~= "function" then return end
    addon.slashHandlers[moduleKey] = handler
end

--- Register a module's debug slash handler. Called for /h debug <module> [cmd].
--- @param moduleKey string  "focus"|"presence"|"vista"|"cache"|"insight"
--- @param handler function(msg)  Receives remainder after module name (e.g. "wqdebug" for /h debug focus wqdebug)
function addon.RegisterSlashHandlerDebug(moduleKey, handler)
    if not moduleKey or type(handler) ~= "function" then return end
    addon.slashHandlersDebug[moduleKey] = handler
end

-- ============================================================================
-- CORE HELP
-- ============================================================================

local function ShowCoreHelp()
    HSPrint("Horizon Suite")
    HSPrint("  /h, /horizon         - This help")
    HSPrint("  /hedit, /h edit      - Open edit screen")
    HSPrint("  /hopt, /h options    - Open options")
    HSPrint("  /h notes             - Show latest patch notes")
    HSPrint("  /h devmode           - Toggle Dev Mode (show Blizzard tracker alongside Focus)")
    HSPrint("  /h focus [cmd]       - Tracker (toggle, collapse, test, ...)")
    HSPrint("  /hfs delvedebug      - Delve / Nemesis widget debug (alias: /h debug focus delvedebug)")
    HSPrint("  /h scenario debug    - Scenario timer debug (diagnose missing timers)")
    HSPrint("  /h presence [cmd]    - Zone/notification tests")
    HSPrint("  /h vista [cmd]       - Minimap")
    HSPrint("  /h cache [cmd]       - Loot toasts")
    HSPrint("  /h insight [cmd]     - Tooltips (or /insight)")
end

-- ============================================================================
-- MAIN HANDLER
-- ============================================================================

local function OnSlashCommand(msg)
    local raw = strtrim(msg or "")
    local lower = raw:lower()
    local first, rest = lower:match("^(%S+)%s*(.*)$")
    first = first or lower
    rest = rest or ""

    if lower == "" or lower == "help" then
        ShowCoreHelp()
        return
    end

    if lower == "options" or lower == "config" then
        if addon.ShowOptions then
            addon.ShowOptions()
        elseif _G.HorizonSuite_ShowOptions then
            _G.HorizonSuite_ShowOptions()
        else
            HSPrint("Options not loaded.")
        end
        return
    end

    if lower == "edit" then
        if addon.ShowEditPanel then
            addon.ShowEditPanel()
        elseif _G.HorizonSuite_ShowEditPanel then
            _G.HorizonSuite_ShowEditPanel()
        else
            HSPrint("Edit panel not loaded.")
        end
        return
    end

    if lower == "notes" or lower == "whatsnew" then
        if addon.ShowPatchNotes then
            addon.ShowPatchNotes()
        else
            HSPrint("Patch notes not loaded.")
        end
        return
    end

    if lower == "devmode" then
        local v = not (addon.GetDB and addon.GetDB("focusDevMode", false))
        if addon.SetDB then addon.SetDB("focusDevMode", v) end
        HSPrint("Dev mode (Blizzard tracker): " .. (v and "on" or "off"))
        ReloadUI()
        return
    end

    if first == "debug" then
        local moduleKey, subMsg = rest:match("^(%S+)%s*(.*)$")
        moduleKey = (moduleKey or ""):lower()
        subMsg = strtrim(subMsg or "")
        if moduleKey == "" then
            HSPrint("Usage: /h debug <focus|presence|vista|cache|insight|locale> [cmd]")
            return
        end
        -- Core debug: locale
        if moduleKey == "locale" then
            addon.debugLocale = not addon.debugLocale
            HSPrint("Locale debug " .. (addon.debugLocale and "|cff00ff00ON|r — missing keys will print to chat." or "|cffff0000OFF|r"))
            return
        end
        local debugHandler = addon.slashHandlersDebug[moduleKey]
        if debugHandler then
            debugHandler(subMsg)
        else
            HSPrint("No debug commands for that module.")
        end
        return
    end

    -- Alias: /h scenario debug -> /h debug focus scendebug (scenario timer debug)
    if first == "scenario" then
        local subCmd = strtrim(rest:lower())
        if subCmd == "debug" or subCmd == "scendebug" or subCmd == "" then
            local debugHandler = addon.slashHandlersDebug["focus"]
            if debugHandler then
                debugHandler(subCmd == "" and "scendebug" or "scendebug")
            else
                HSPrint("Focus debug not available.")
            end
            return
        end
    end

    local handler = addon.slashHandlers[first]
    if handler then
        handler(strtrim(rest))
        return
    end

    ShowCoreHelp()
end

-- ============================================================================
-- REGISTER SLASH COMMANDS
-- ============================================================================

SLASH_MODERNQUESTTRACKER1 = "/horizon"
SLASH_MODERNQUESTTRACKER2 = "/h"
SlashCmdList["MODERNQUESTTRACKER"] = OnSlashCommand

-- Short alias for Focus delve diagnostics (many guides say /hfs — core commands are /h and /horizon).
SLASH_HSFOCUSDEBUG1 = "/hfs"
SlashCmdList["HSFOCUSDEBUG"] = function(msg)
    local rest = strtrim(msg or "")
    if rest == "" then
        HSPrint("Usage: |cffffff00/hfs delvedebug|r — same as |cffffff00/h debug focus delvedebug|r")
        return
    end
    local first = (rest:match("^(%S+)") or rest):lower()
    if first == "delvedebug" or rest:lower():find("^delvedebug", 1, true) then
        local debugHandler = addon.slashHandlersDebug and addon.slashHandlersDebug["focus"]
        if debugHandler then
            debugHandler("delvedebug")
        else
            HSPrint("Focus debug not available.")
        end
        return
    end
    HSPrint("Unknown /hfs command. Use |cffffff00/hfs delvedebug|r or |cffffff00/h debug focus delvedebug|r")
end

SLASH_HSEDIT1 = "/hedit"
SlashCmdList["HSEDIT"] = function()
    OnSlashCommand("edit")
end

SLASH_HSOPT1 = "/hopt"
SlashCmdList["HSOPT"] = function()
    OnSlashCommand("options")
end
