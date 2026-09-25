--[[
    Horizon Suite - Echo - Filter
    "Hide whispers Echo has stored": while on, a whisper Echo files in a conversation is
    hidden from Blizzard's chat windows. A whisper Echo could not read (secret text or a
    secret sender) is never hidden, so nothing is lost. Blizzard sets the reply target
    after the filters run, so a hidden incoming whisper sets it here instead.
    Blizzard: ChatFrameUtil.AddMessageEventFilter / RemoveMessageEventFilter (legacy
    ChatFrame_* globals), ChatFrameUtil.SetLastTellTarget / ChatEdit_SetLastTellTarget.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Filter = { active = false }
Echo.Filter = Filter

local EVENTS = { "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM" }
local BN_EVENTS = { "CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_WHISPER_INFORM" }
local INCOMING = { CHAT_MSG_WHISPER = "WHISPER", CHAT_MSG_BN_WHISPER = "BN_WHISPER" }

local registered = {}  -- events this filter is currently registered on

local function AddFn()
    local util = _G.ChatFrameUtil
    return (util and util.AddMessageEventFilter) or _G.ChatFrame_AddMessageEventFilter
end

local function RemoveFn()
    local util = _G.ChatFrameUtil
    return (util and util.RemoveMessageEventFilter) or _G.ChatFrame_RemoveMessageEventFilter
end

local function SetLastTell(sender, chatType)
    if Echo.IsSecret(sender) then return end
    local util = _G.ChatFrameUtil
    local fn = (util and util.SetLastTellTarget) or _G.ChatEdit_SetLastTellTarget
    if fn then pcall(fn, sender, chatType) end
end

--- True when Echo files this whisper as a readable message.
-- @return boolean
function Filter.ShouldHide(event, ...)
    local record = Echo.Events.BuildRecord(event, ...)
    return record ~= nil and not record.secret
end

--- Blizzard's message-filter signature: true hides the line.
function Filter.Handler(_, event, ...)
    if Filter.ShouldHide(event, ...) then
        local chatType = INCOMING[event]
        if chatType then SetLastTell((select(2, ...)), chatType) end
        return true
    end
    return false, ...
end

--- Register or remove the filter.
-- @param on boolean
function Filter.Apply(on)
    local remove = RemoveFn()
    for event in pairs(registered) do
        if remove then remove(event, Filter.Handler) end
    end
    registered = {}
    Filter.active = false
    if not on then return end
    local add = AddFn()
    if not add then return end
    local events = {}
    for _, e in ipairs(EVENTS) do events[#events + 1] = e end
    if addon.Platform and addon.Platform.Has("bnetWhispers") then
        for _, e in ipairs(BN_EVENTS) do events[#events + 1] = e end
    end
    for _, event in ipairs(events) do
        add(event, Filter.Handler)
        registered[event] = true
    end
    Filter.active = true
end
