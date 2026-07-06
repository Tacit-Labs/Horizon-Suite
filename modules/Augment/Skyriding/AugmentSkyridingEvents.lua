--[[
    Horizon Suite - Augment / Skyriding - Events
    Centralised event registration for the Skyriding mini-module: one frame
    dispatches to Core's main charge/speed refresh, the racing-quest cache in
    API.lua, and the separate Derby Racing widget path. Mirrors Alerts'
    Events.lua (events registered only while enabled, explicitly
    unregistered the moment a feature is turned off).
]]

local addon = _G.HorizonSuite
local Y = addon and addon.Augment
local S = Y and Y.Skyriding
if not S then return end

local ev = CreateFrame("Frame")
local registered = false

local function regOptional(eventName, on)
    if on then
        pcall(ev.RegisterEvent, ev, eventName)
    else
        pcall(ev.UnregisterEvent, ev, eventName)
    end
end

-- Safe to call repeatedly (e.g. from the options page's Derby toggle).
function S.UpdateEventRegistrations()
    local D = addon.AUGMENT_DEFAULTS
    regOptional("UPDATE_UI_WIDGET", S.GetDB("skyridingDerbyEnabled", D.skyridingDerbyEnabled))
end

ev:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" or event == "CLIENT_SCENE_OPENED" or event == "CLIENT_SCENE_CLOSED" then
        if S.API.RefreshRacingQuestState then S.API:RefreshRacingQuestState() end
        if S.Core and S.Core.UpdateUI then S.Core.UpdateUI() end
        return
    end

    if event == "UPDATE_UI_WIDGET" then
        if S.Derby and S.Derby.Update then S.Derby.Update(...) end
        return
    end

    -- ACTIONBAR_UPDATE_COOLDOWN / ACTIONBAR_UPDATE_STATE / UPDATE_BONUS_ACTIONBAR /
    -- PLAYER_CAN_GLIDE_CHANGED / PLAYER_IS_GLIDING_CHANGED all funnel into the same
    -- "re-evaluate everything" refresh.
    if S.Core and S.Core.UpdateUI then S.Core.UpdateUI(event) end
end)

function S.EnableEvents()
    if registered then return end
    registered = true
    ev:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    ev:RegisterEvent("ACTIONBAR_UPDATE_STATE")
    ev:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
    ev:RegisterEvent("PLAYER_CAN_GLIDE_CHANGED")
    ev:RegisterEvent("PLAYER_IS_GLIDING_CHANGED")
    ev:RegisterEvent("PLAYER_LOGIN")
    ev:RegisterEvent("CLIENT_SCENE_OPENED")
    ev:RegisterEvent("CLIENT_SCENE_CLOSED")
    S.UpdateEventRegistrations()
    -- PLAYER_LOGIN already fired once this session if Skyriding was only just
    -- enabled via the options page — take an immediate racing-quest snapshot.
    if S.API.RefreshRacingQuestState then S.API:RefreshRacingQuestState() end
end

function S.DisableEvents()
    if not registered then return end
    registered = false
    ev:UnregisterAllEvents()
end
