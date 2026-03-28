--[[
    Horizon Suite - Presence - Slash Commands
    /h presence [cmd] subcommands. Registers with core via addon.RegisterSlashHandler.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.Presence or not addon.RegisterSlashHandler then return end

local HSPrint = addon.HSPrint or function(msg) print("|cFF00CCFFHorizon Suite:|r " .. tostring(msg or "")) end

--- Handle /horizon presence [cmd] subcommands. Returns true if handled, false to pass to parent handler.
--- @param msg string Subcommand (zone, subzone, discover, level, boss, ach, quest, wq, wqaccept, accept, update, scenario, all, debug, debuglive, help)
--- @return boolean
local function HandlePresenceSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "level" then
        if addon.Presence.PreviewToast then addon.Presence.PreviewToast("LEVEL_UP") end
    elseif cmd == "boss" then
        if addon.Presence.PreviewToast then addon.Presence.PreviewToast("BOSS_EMOTE") end
    elseif cmd == "ach" then
        if addon.Presence.PreviewToast then addon.Presence.PreviewToast("ACHIEVEMENT") end
    elseif cmd == "quest" then
        if addon.Presence.PreviewToast then addon.Presence.PreviewToast("QUEST_COMPLETE") end
    elseif cmd == "wq" then
        if addon.Presence.PreviewToast then addon.Presence.PreviewToast("WORLD_QUEST") end
    elseif cmd == "wqaccept" then
        if addon.Presence.PreviewToast then addon.Presence.PreviewToast("WORLD_QUEST_ACCEPT") end
    elseif cmd == "accept" then
        if addon.Presence.PreviewToast then addon.Presence.PreviewToast("QUEST_ACCEPT") end
    elseif cmd == "update" then
        if addon.Presence.PreviewToast then addon.Presence.PreviewToast("QUEST_UPDATE") end
    elseif cmd == "achprogress" then
        if addon.Presence.PreviewToast then addon.Presence.PreviewToast("ACHIEVEMENT_PROGRESS") end
    elseif cmd == "scenario" then
        if addon.Presence.GetScenarioDisplayInfo and addon.Presence.IsScenarioActive and addon.Presence.IsScenarioActive() then
            local title, subtitle, category = addon.Presence.GetScenarioDisplayInfo()
            addon.Presence.QueueOrPlay("SCENARIO_START", title or "Scenario", subtitle or "", { category = category })
        elseif addon.Presence.PreviewToast then
            addon.Presence.PreviewToast("SCENARIO_START")
        end
    elseif cmd == "zone" then
        addon.Presence.QueueOrPlay("ZONE_CHANGE", GetZoneText() or "Unknown Zone", GetSubZoneText() or "")
    elseif cmd == "subzone" then
        if addon.Presence.PreviewToast then addon.Presence.PreviewToast("SUBZONE_CHANGE") end
    elseif cmd == "discover" then
        if addon.Presence.PreviewToast then addon.Presence.PreviewToast("ZONE_CHANGE") end
    elseif cmd == "all" then
        local L = addon.L or {}
        HSPrint(L["PRESENCE_PRESENCE_PLAYING_DEMO_REEL_NOTIFICATION"])
        local demos = {
            { "ZONE_CHANGE",         GetZoneText() or "Valdrakken",     GetSubZoneText() or "Thaldraszus" },
            { "SUBZONE_CHANGE",      GetZoneText() or "Valdrakken",     GetSubZoneText() or "The Seat of Aspects" },
            { "ZONE_CHANGE",         "The Waking Shores",               "Obsidian Citadel",  true   },
            { "QUEST_ACCEPT",        L["PRESENCE_QUEST_ACCEPTED"],               L["PRESENCE_THE_FATE_OF_THE_HORDE"] },
            { "WORLD_QUEST_ACCEPT",  L["PRESENCE_WORLD_QUEST_ACCEPTED"],         L["PRESENCE_AZERITE_MINING"] },
            { "QUEST_UPDATE",        L["PRESENCE_QUEST_UPDATE"],                 L["PRESENCE_DRAGON_GLYPHS_3_5"] },
            { "QUEST_COMPLETE",      L["PRESENCE_QUEST_COMPLETE"],               L["PRESENCE_AIDING_THE_ACCORD"] },
            { "WORLD_QUEST",         L["PRESENCE_WORLD_QUEST_COMPLETE"] or "WORLD QUEST COMPLETE", L["PRESENCE_AZERITE_MINING"] },
            { "SCENARIO_START",      "Cinderbrew Meadery",              "Defend the tavern", { category = "SCENARIO" } },
            { "ACHIEVEMENT",         L["PRESENCE_ACHIEVEMENT_EARNED"],           L["PRESENCE_EXPLORING_KHAZ_ALGAR"] },
            { "ACHIEVEMENT_PROGRESS", L["PRESENCE_EXPLORING_THE_MIDNIGHT_ISLES"], L["PRESENCE_DRAGON_GLYPHS_3_5"] },
            { "BOSS_EMOTE",          "Ragnaros",                        "BY FIRE BE PURGED!" },
            { "LEVEL_UP",            L["PRESENCE_LEVEL_UP"],                     L["PRESENCE_YOU_HAVE_REACHED_LEVEL_80"] },
        }
        for i, d in ipairs(demos) do
            C_Timer.After((i - 1) * 3, function()
                if d[4] == true then addon.Presence.SetPendingDiscovery() end
                addon.Presence.QueueOrPlay(d[1], d[2], d[3], type(d[4]) == "table" and d[4] or nil)
            end)
        end
    elseif cmd == "" or cmd == "help" then
        local L = addon.L or {}
        HSPrint(L["PRESENCE_PRESENCE_TEST_COMMANDS"])
        HSPrint(L["PRESENCE_H_PRESENCE_HELP_TEST_CURRENT"])
        HSPrint(L["PRESENCE_H_PRESENCE_ZONE_TEST_ZONE"])
        HSPrint(L["PRESENCE_H_PRESENCE_SUBZONE_TEST_SUBZONE"])
        HSPrint(L["PRESENCE_H_PRESENCE_DISCOVER_TEST_ZONE"])
        HSPrint(L["PRESENCE_H_PRESENCE_LEVEL_TEST_LEVEL"])
        HSPrint(L["PRESENCE_H_PRESENCE_BOSS_TEST_BOSS"])
        HSPrint(L["PRESENCE_H_PRESENCE_ACH_TEST_ACHIEVEMENT"])
        HSPrint(L["PRESENCE_H_PRESENCE_ACCEPT_TEST_QUEST"])
        HSPrint(L["PRESENCE_H_PRESENCE_WQACCEPT_TEST_WORLD"])
        HSPrint(L["PRESENCE_H_PRESENCE_SCENARIO_TEST_SCENARIO"])
        HSPrint(L["PRESENCE_H_PRESENCE_QUEST_TEST_QUEST"])
        HSPrint(L["PRESENCE_H_PRESENCE_WQ_TEST_WORLD"])
        HSPrint(L["PRESENCE_H_PRESENCE_UPDATE_TEST_QUEST"])
        HSPrint(L["PRESENCE_H_PRESENCE_ACHPROGRESS_TEST_ACHIEVEMENT"])
        HSPrint(L["PRESENCE_H_PRESENCE_DEMO_REEL_TYPES"])
        addon.Presence.QueueOrPlay("ZONE_CHANGE", GetZoneText() or "Unknown Zone", GetSubZoneText() or "")
    else
        return false
    end

    return true
end

local function HandlePresenceDebugSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "" or cmd == "help" then
        HSPrint("Presence debug commands (/h debug presence [cmd]):")
        HSPrint("  debug      - Dump state to chat")
        HSPrint("  debugtypes - Dump notification toggles and Blizzard suppression state")
        HSPrint("  debuglive  - Toggle live debug panel (log as events happen)")
        return
    end

    if cmd == "debug" then
        if addon.Presence.DumpDebug then addon.Presence.DumpDebug() end

    elseif cmd == "debugtypes" then
        if addon.Presence.DumpBlizzardSuppression then
            addon.Presence.DumpBlizzardSuppression(HSPrint)
        else
            HSPrint("DumpBlizzardSuppression not available")
        end

    elseif cmd == "debuglive" then
        local on = addon.Presence.ToggleDebugLive and addon.Presence.ToggleDebugLive()
        HSPrint("Presence live debug: " .. (on and "on" or "off"))

    else
        HSPrint("Unknown debug command. Use /h debug presence for help.")
    end
end

addon.RegisterSlashHandler("presence", HandlePresenceSlash)
addon.Presence.HandlePresenceSlash = HandlePresenceSlash
if addon.RegisterSlashHandlerDebug then
    addon.RegisterSlashHandlerDebug("presence", HandlePresenceDebugSlash)
end
