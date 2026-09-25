--[[
    Horizon Suite - Horizon Echo Module
    Conversation-first chat: whispers and group channels as tiles you reply from.
    Blizzard's chat frames stay underneath as the source of truth.
    Design: Docs/Engineering/2026-09-24-echo-chat-design.md
    Registers with addon:RegisterModule.
]]

local addon = _G.HorizonSuite
if not addon or not addon.RegisterModule then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local lifecycle  -- combat and logout events

local function OnLifecycleEvent(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        Echo.Stack.Hide()
        if Echo.Setting("echoHoldToastsInCombat") then Echo.Tiles.Hold(true) end
    elseif event == "PLAYER_REGEN_ENABLED" then
        Echo.Tiles.Hold(false)
    elseif event == "PLAYER_LOGOUT" then
        -- Fires on /reload too; the tiles open now come back if the next session starts soon.
        Echo.History.SaveSession(Echo.Store.OpenKeys(), Echo.Store.Now())
    end
end

--- Reopen the tiles saved at the end of the last session, if it ended recently.
-- @return number restored
function Echo.RestoreSession()
    return Echo.Store.Restore(Echo.History.SessionKeys(Echo.Store.Now()))
end

function Echo.Init()
    -- The key function resolves lazily: Forever only knows the realm after PLAYER_LOGIN,
    -- and History writes nothing for whispers until it does.
    Echo.History.Bind(_G[addon.DATABASE], addon._GetCurrentCharacterProfileKey)
    Echo.RestoreSession()
    Echo.Events.Enable()
    Echo.Tiles.Enable()
    Echo.Stack.Enable()
    if not lifecycle then
        lifecycle = CreateFrame("Frame")
        lifecycle:SetScript("OnEvent", OnLifecycleEvent)
    end
    lifecycle:RegisterEvent("PLAYER_REGEN_DISABLED")
    lifecycle:RegisterEvent("PLAYER_REGEN_ENABLED")
    lifecycle:RegisterEvent("PLAYER_LOGOUT")
    -- The Battle.net friends list can arrive after login; restore those tiles once it has.
    C_Timer.After(5, function()
        if addon:IsModuleEnabled("echo") then Echo.RestoreSession() end
    end)
end

function Echo.Disable()
    if lifecycle then lifecycle:UnregisterAllEvents() end
    Echo.Stack.Disable()
    Echo.Tiles.Disable()
    Echo.Events.Disable()
    Echo.Store.Reset()
    Echo.History.Unbind()
end

addon:RegisterModule("echo", {
    title       = "Horizon Echo",
    description = "Conversation-first chat: whispers and group channels as tiles you can reply from, with whisper history kept between sessions.",
    order       = 28,

    OnEnable = function()
        Echo.Init()
    end,

    OnDisable = function()
        Echo.Disable()
    end,
})
