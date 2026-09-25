--[[
    Horizon Suite - Horizon Echo (Slash)
    /h echo commands: toggle, status, probe, test, clearhistory.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

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

local function PrintStatus()
    local Store = Echo.Store
    local list = Store.List()
    HSPrint(("Echo: %d conversations, %d messages left in Blizzard chat (unrouted)"):format(
        #list, Store.GetUnroutedCount()))
    for _, conv in ipairs(list) do
        HSPrint(("  %s  tier=%s unread=%d messages=%d%s"):format(
            conv.key, Store.TierOf(conv.key), conv.unread, #conv.messages, conv.pinned and " pinned" or ""))
    end
end

local function StartProbe(rest)
    local count = tonumber(rest) or 10
    local sendChat, sendBN = Echo.Send.Resolve()
    local Platform = addon.Platform
    HSPrint(("Echo probe: sendChat=%s sendBN=%s secretChat=%s bnetWhispers=%s"):format(
        sendChat and "yes" or "no", sendBN and "yes" or "no",
        tostring(Platform and Platform.Has("secretChat")), tostring(Platform and Platform.Has("bnetWhispers"))))
    Echo.Events.StartProbe(count, HSPrint)
    HSPrint(("Echo probe: describing the next %d chat messages (types only, never text)."):format(count))
end

local function HandleEchoSlash(msg)
    local cmd, rest = strtrim(msg or ""):match("^(%S*)%s*(.-)$")
    cmd = (cmd or ""):lower()

    if cmd == "toggle" then
        if InCombatLockdown() then
            HSPrint("Cannot toggle Echo during combat.")
            return
        end
        addon:SetModuleEnabled("echo", not addon:IsModuleEnabled("echo"))
        return
    end

    if not addon:IsModuleEnabled("echo") then
        HSPrint("Horizon Echo is disabled. Use /h echo toggle to enable it.")
        return
    end

    if cmd == "status" then
        PrintStatus()
    elseif cmd == "probe" then
        StartProbe(rest)
    elseif cmd == "test" then
        Echo.InjectTestConversations()
        HSPrint("Echo: added sample conversations. /h echo status lists them.")
    elseif cmd == "clearhistory" then
        Echo.History.Clear()
        HSPrint("Echo: whisper history cleared for every character.")
    elseif cmd == "lock" or cmd == "unlock" then
        addon.SetDB("echoLockPosition", cmd == "lock")
        HSPrint(cmd == "lock" and "Echo: column locked."
            or "Echo: column unlocked. Drag the chat button at its foot to move it, then /h echo lock.")
    elseif cmd == "reset" then
        Echo.Tiles.ResetPosition()
        HSPrint("Echo: column moved back to the bottom right.")
    elseif cmd == "" or cmd == "help" then
        HSPrint("Echo commands:")
        HSPrint("  /h echo toggle       - Enable / disable Echo (reloads the UI)")
        HSPrint("  /h echo status       - List conversations, tiers and unread counts")
        HSPrint("  /h echo probe [n]    - Describe the next n chat messages (default 10)")
        HSPrint("  /h echo unlock       - Let the column be dragged by its chat button")
        HSPrint("  /h echo lock         - Lock the column in place")
        HSPrint("  /h echo reset        - Move the column back to the bottom right")
        HSPrint("  /h echo test         - Add sample conversations")
        HSPrint("  /h echo clearhistory - Delete saved whisper history")
    else
        HSPrint("Unknown command. Use /h echo for help.")
    end
end

if addon.RegisterSlashHandler then
    addon.RegisterSlashHandler("echo", HandleEchoSlash)
end
