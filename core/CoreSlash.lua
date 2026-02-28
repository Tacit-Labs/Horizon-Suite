--[[
    Horizon Suite - Core Slash Commands
    Centralized /h and /horizon handler. Core commands (options, edit, help) and dispatcher to module handlers.
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then _G.HorizonSuite = {} end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

local HSPrint = addon.HSPrint or function(msg) print("|cFF00CCFFHorizon Suite:|r " .. tostring(msg or "")) end

-- ============================================================================
-- MODULE REGISTRY
-- ============================================================================

addon.slashHandlers = addon.slashHandlers or {}
addon.slashHandlersDebug = addon.slashHandlersDebug or {}

--- Register a module's slash handler. Called by each module at load.
--- @param moduleKey string  "focus"|"presence"|"vista"|"yield"|"insight"
--- @param handler function(msg)  Receives remainder after module name (e.g. "toggle" for /h focus toggle)
function addon.RegisterSlashHandler(moduleKey, handler)
    if not moduleKey or type(handler) ~= "function" then return end
    addon.slashHandlers[moduleKey] = handler
end

--- Register a module's debug slash handler. Called for /h debug <module> [cmd].
--- @param moduleKey string  "focus"|"presence"|"vista"|"yield"|"insight"
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
    HSPrint("  /h focus [cmd]       - Tracker (toggle, collapse, test, ...)")
    HSPrint("  /h presence [cmd]    - Zone/notification tests")
    HSPrint("  /h vista [cmd]       - Minimap")
    HSPrint("  /h yield [cmd]       - Loot toasts")
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

    if first == "debug" then
        local moduleKey, subMsg = rest:match("^(%S+)%s*(.*)$")
        moduleKey = (moduleKey or ""):lower()
        subMsg = strtrim(subMsg or "")
        if moduleKey == "" then
            HSPrint("Usage: /h debug <focus|presence|vista|yield|insight> [cmd]")
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

SLASH_HSEDIT1 = "/hedit"
SlashCmdList["HSEDIT"] = function()
    OnSlashCommand("edit")
end

SLASH_HSOPT1 = "/hopt"
SlashCmdList["HSOPT"] = function()
    OnSlashCommand("options")
end
