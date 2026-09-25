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

local lifecycle  -- login, combat, logout and late Battle.net events

-- Battle.net friends can arrive after the world loads; their saved tiles are retried on
-- friend updates for this long after the first restore.
local BNET_RETRY_SECONDS = 60
local BNET_EVENTS = { "BN_FRIEND_INFO_CHANGED", "BN_CONNECTED" }

local restoredAt  -- Store.Now() of this session's first restore; nil until it has run

--- Reopen the tiles saved at the end of the last session, if it ended recently.
-- @return number restored
function Echo.RestoreSession()
    return Echo.Store.Restore(Echo.History.SessionKeys(Echo.Store.Now()))
end

local function StopBnetRetry()
    if not lifecycle then return end
    for _, event in ipairs(BNET_EVENTS) do lifecycle:UnregisterEvent(event) end
end

local function FirstRestore()
    if restoredAt then return end
    Echo.RestoreSession()
    restoredAt = Echo.Store.Now()
    lifecycle:UnregisterEvent("PLAYER_ENTERING_WORLD")
    -- Same gate as EchoEvents: no Battle.net whispers, no Battle.net tiles to wait for.
    if not (addon.Platform and addon.Platform.Has("bnetWhispers")) then return end
    for _, event in ipairs(BNET_EVENTS) do lifecycle:RegisterEvent(event) end
    -- Drop the retry even if no friend update ever comes (unless the module was
    -- disabled and re-enabled since, which started a retry window of its own).
    local at = restoredAt
    C_Timer.After(BNET_RETRY_SECONDS, function()
        if restoredAt == at then StopBnetRetry() end
    end)
end

local function OnLifecycleEvent(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        Echo.Stack.Hide()
        Echo.Card.Hide()
        if Echo.Setting("echoHoldToastsInCombat") then Echo.Tiles.Hold(true) end
    elseif event == "PLAYER_REGEN_ENABLED" then
        Echo.Tiles.Hold(false)
    elseif event == "PLAYER_ENTERING_WORLD" then
        FirstRestore()
    elseif event == "BN_FRIEND_INFO_CHANGED" or event == "BN_CONNECTED" then
        if restoredAt and Echo.Store.Now() - restoredAt <= BNET_RETRY_SECONDS then
            Echo.RestoreSession()  -- skips tiles already open
        else
            StopBnetRetry()
        end
    elseif event == "PLAYER_LOGOUT" then
        -- Fires on /reload too; the tiles open now come back if the next session starts
        -- soon. Before this session restored anything, the open list is empty (a reload
        -- during loading), and saving it would wipe the tiles still waiting to come back.
        if restoredAt then
            Echo.History.SaveSession(Echo.Store.OpenKeys(), Echo.Store.Now())
        end
    end
end

function Echo.Init()
    -- The key function resolves lazily: Forever only knows the realm after PLAYER_LOGIN,
    -- and History writes nothing for whispers until it does.
    Echo.History.Bind(_G[addon.DATABASE], addon._GetCurrentCharacterProfileKey)
    Echo.Events.Enable()
    Echo.Tiles.Enable()
    Echo.Stack.Enable()
    Echo.Card.Enable()
    Echo.Links.Hook()
    Echo.ApplyOptions()
    if not lifecycle then
        lifecycle = CreateFrame("Frame")
        lifecycle:SetScript("OnEvent", OnLifecycleEvent)
    end
    lifecycle:RegisterEvent("PLAYER_REGEN_DISABLED")
    lifecycle:RegisterEvent("PLAYER_REGEN_ENABLED")
    lifecycle:RegisterEvent("PLAYER_LOGOUT")
    -- Restore once the player is in the world: now if enabled after login, else on the
    -- first PLAYER_ENTERING_WORLD.
    if IsLoggedIn and IsLoggedIn() then
        FirstRestore()
    else
        lifecycle:RegisterEvent("PLAYER_ENTERING_WORLD")
    end
end

function Echo.Disable()
    if lifecycle then lifecycle:UnregisterAllEvents() end
    Echo.Redraw.Clear()
    restoredAt = nil
    Echo.Card.Disable()
    Echo.Stack.Disable()
    Echo.Tiles.Disable()
    Echo.Filter.Apply(false)
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
