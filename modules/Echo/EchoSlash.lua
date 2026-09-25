--[[
    Horizon Suite - Horizon Echo (Slash)
    /h echo commands: toggle, status, probe, test, clearhistory.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo
local L = addon.L

local HSPrint = addon.HSPrint or function(msg) print("|cFF00CCFFHorizon Suite:|r " .. tostring(msg or "")) end

-- Sample conversations for /h echo test. Marked demo, so history never stores them.
local TEST_MESSAGES = {
    { convKey = "w:Brisa-Horizon",     sender = "Brisa-Horizon",     class = "DRUID",  text = "got the leather + threads" },
    { convKey = "w:Brisa-Horizon",     sender = "Brisa-Horizon",     class = "DRUID",  text = "can you craft the cloak if I send mats?" },
    { convKey = "w:Thornwick-Horizon", sender = "Thornwick-Horizon", class = "ROGUE",  text = "summon at the stone?" },
    { convKey = "w:Vexa-Horizon",      sender = "Vexa-Horizon",      class = "EVOKER", text = "gz on the mount!" },
    { convKey = "party",               sender = "Thornwick-Horizon", class = "ROGUE",  text = "ready check in 1" },
    { convKey = "guild",               sender = "Vexa-Horizon",      class = "EVOKER", text = "raid tonight at 8" },
}

function Echo.InjectTestConversations()
    for _, m in ipairs(TEST_MESSAGES) do
        Echo.Store.Add({
            convKey = m.convKey, sender = m.sender, class = m.class, text = m.text, demo = true,
        })
    end
end

--- " class=<file>(<source>)", or "" when the conversation has none readable.
-- @param conv table
-- @return string
local function ClassSuffix(conv)
    local resolve = Echo.Class and Echo.Class.Resolve
    if type(resolve) ~= "function" then return "" end
    local class, source = resolve(conv)
    if Echo.IsSecret(class) or type(class) ~= "string" or class == "" then return "" end
    return (" class=%s(%s)"):format(class, source or "")
end

local function PrintStatus()
    local Store = Echo.Store
    local list = Store.List()
    HSPrint(L["ECHO_SLASH_STATUS"]:format(#list, Store.GetUnroutedCount()))
    for _, conv in ipairs(list) do
        HSPrint(L["ECHO_SLASH_STATUS_ROW"]:format(
            conv.key, Store.TierOf(conv.key), conv.unread, #conv.messages,
            conv.pinned and L["ECHO_SLASH_PINNED"] or "", ClassSuffix(conv)))
    end
end

local function StartProbe(rest)
    local count = tonumber(rest) or 10
    local sendChat, sendBN = Echo.Send.Resolve()
    local Platform = addon.Platform
    HSPrint(L["ECHO_SLASH_PROBE"]:format(
        sendChat and L["ECHO_SLASH_YES"] or L["ECHO_SLASH_NO"],
        sendBN and L["ECHO_SLASH_YES"] or L["ECHO_SLASH_NO"],
        tostring(Platform and Platform.Has("secretChat")), tostring(Platform and Platform.Has("bnetWhispers"))))
    Echo.Events.StartProbe(count, HSPrint)
    HSPrint(L["ECHO_SLASH_PROBE_START"]:format(count))
end

local function HandleEchoSlash(msg)
    local cmd, rest = strtrim(msg or ""):match("^(%S*)%s*(.-)$")
    cmd = (cmd or ""):lower()

    if cmd == "toggle" then
        if InCombatLockdown() then
            HSPrint(L["ECHO_SLASH_NO_COMBAT"])
            return
        end
        addon:SetModuleEnabled("echo", not addon:IsModuleEnabled("echo"))
        return
    end

    if not addon:IsModuleEnabled("echo") then
        HSPrint(L["ECHO_SLASH_DISABLED"])
        return
    end

    if cmd == "status" then
        PrintStatus()
    elseif cmd == "probe" then
        StartProbe(rest)
    elseif cmd == "test" then
        Echo.InjectTestConversations()
        HSPrint(L["ECHO_SLASH_TEST"])
    elseif cmd == "clearhistory" then
        Echo.History.Clear()
        HSPrint(L["ECHO_SLASH_CLEARED"])
    elseif cmd == "lock" or cmd == "unlock" then
        addon.SetDB("echoLockPosition", cmd == "lock")
        HSPrint(cmd == "lock" and L["ECHO_SLASH_LOCKED"] or L["ECHO_SLASH_UNLOCKED"])
    elseif cmd == "reset" then
        Echo.Tiles.ResetPosition()
        HSPrint(L["ECHO_SLASH_RESET"])
    elseif cmd == "" or cmd == "help" then
        HSPrint(L["ECHO_SLASH_HELP"])
        HSPrint(L["ECHO_SLASH_HELP_TOGGLE"])
        HSPrint(L["ECHO_SLASH_HELP_STATUS"])
        HSPrint(L["ECHO_SLASH_HELP_PROBE"])
        HSPrint(L["ECHO_SLASH_HELP_UNLOCK"])
        HSPrint(L["ECHO_SLASH_HELP_LOCK"])
        HSPrint(L["ECHO_SLASH_HELP_RESET"])
        HSPrint(L["ECHO_SLASH_HELP_TEST"])
        HSPrint(L["ECHO_SLASH_HELP_CLEAR"])
        HSPrint(L["ECHO_SLASH_HELP_OPTIONS"])
    else
        HSPrint(L["ECHO_SLASH_UNKNOWN"])
    end
end

if addon.RegisterSlashHandler then
    addon.RegisterSlashHandler("echo", HandleEchoSlash)
end
