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

function Echo.Init()
    -- The key function resolves lazily: Forever only knows the realm after PLAYER_LOGIN,
    -- and History writes nothing for whispers until it does.
    Echo.History.Bind(_G[addon.DATABASE], addon._GetCurrentCharacterProfileKey)
    Echo.Events.Enable()
end

function Echo.Disable()
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
