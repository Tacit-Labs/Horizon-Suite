--[[
    Horizon Suite - Echo - Filter
    Hides chat Echo has filed from Blizzard's chat windows, for each kind whose route is
    "echo" (Echo.Route; Echo.ApplyOptions passes the set). A line Echo could not read
    (secret text or a secret sender) is never hidden, so nothing is lost. For whispers,
    Blizzard sets the reply target after the filters run, so a hidden incoming whisper sets
    it here instead. Blizzard also plays the whisper sound and flashes the taskbar icon
    after the filters run; a hidden incoming whisper does both here instead, once per chat
    frame, via Echo.Sound.Whisper (EchoSound.lua) and FlashClientIcon. Other kinds need
    neither.
    While C_ChatInfo.InChatMessagingLockdown() is true, nothing is hidden: Blizzard's own
    secure code owns the line, the sound and the reply target during that window.
    Blizzard: ChatFrameUtil.AddMessageEventFilter / RemoveMessageEventFilter (legacy
    ChatFrame_* globals), ChatFrameUtil.SetLastTellTarget / ChatEdit_SetLastTellTarget,
    FlashClientIcon, C_ChatInfo.InChatMessagingLockdown.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Filter = { active = false }
Echo.Filter = Filter

local INCOMING = { CHAT_MSG_WHISPER = "WHISPER", CHAT_MSG_BN_WHISPER = "BN_WHISPER" }

local registered = {}  -- events this filter is currently registered on
Filter.kinds = {}      -- kind -> true: the kinds hidden now

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

local lastAlertAt

--- Play the whisper sound and flash the taskbar icon, once per chat frame: the filter
-- runs once per registered event for the same line within one frame.
local function Alert(event)
    local now = GetTime and GetTime() or 0
    if now == lastAlertAt then return end
    lastAlertAt = now
    Echo.Sound.Whisper(event == "CHAT_MSG_BN_WHISPER")
    if FlashClientIcon then
        pcall(FlashClientIcon)
    end
end

--- True while chat messaging lockdown is in effect. Resolved and pcalled at call time;
-- anything but a plain, non-secret boolean counts as "in lockdown", so the filter fails
-- safe and Blizzard's own secure code keeps handling the line.
local function InLockdown()
    local info = _G.C_ChatInfo
    local fn = info and info.InChatMessagingLockdown
    if not fn then return false end
    local ok, result = pcall(fn)
    if not ok then return true end
    if Echo.IsSecret(result) then return true end
    if type(result) ~= "boolean" then return true end
    return result
end

--- True when Echo files this whisper as a readable message.
-- @return boolean
function Filter.ShouldHide(event, ...)
    if InLockdown() then return false end
    local record = Echo.Events.BuildRecord(event, ...)
    return record ~= nil and not record.secret
end

--- Blizzard's message-filter signature: true hides the line. While Echo runs the filters
-- for its own intake (Events.RunFilters sets Filter.passing), it lets everything through.
function Filter.Handler(_, event, ...)
    if Filter.passing then return false end
    if Filter.ShouldHide(event, ...) then
        local chatType = INCOMING[event]
        if chatType then
            SetLastTell((select(2, ...)), chatType)
            Alert(event)
        end
        return true
    end
    return false
end

--- The chat events hidden for a set of kinds: each event Store.EVENT_KIND gives one of
-- them, never a feed's, Battle.net's only where the client has Battle.net whispers, and
-- only events this client has.
-- @param kinds table|nil  kind -> true
-- @return table events  sorted
function Filter.EventsFor(kinds)
    local out = {}
    if type(kinds) ~= "table" then return out end
    local Store = Echo.Store
    local hasBnet = addon.Platform and addon.Platform.Has("bnetWhispers")
    for event, kind in pairs(Store.EVENT_KIND) do
        if kinds[kind] == true and not Store.FEED_KINDS[kind] and (hasBnet or kind ~= "bnet")
            and Echo.IsEventValid(event) then
            out[#out + 1] = event
        end
    end
    table.sort(out)
    return out
end

--- True when kinds names exactly the kinds hidden now (nil is none).
-- @param kinds table|nil
-- @return boolean
function Filter.SameKinds(kinds)
    if type(kinds) ~= "table" then kinds = {} end
    for kind, on in pairs(kinds) do
        if on == true and not Filter.kinds[kind] then return false end
    end
    for kind in pairs(Filter.kinds) do
        if kinds[kind] ~= true then return false end
    end
    return true
end

--- Hide these kinds' chat from Blizzard's windows, and stop hiding the rest.
-- @param kinds table|nil  kind -> true; nil or empty turns the filter off
function Filter.Apply(kinds)
    local remove = RemoveFn()
    for event in pairs(registered) do
        if remove then remove(event, Filter.Handler) end
    end
    registered = {}
    Filter.kinds = {}
    Filter.active = false
    if type(kinds) ~= "table" then return end
    for kind, on in pairs(kinds) do
        if on == true then Filter.kinds[kind] = true end
    end
    local add = AddFn()
    if not add then return end
    for _, event in ipairs(Filter.EventsFor(Filter.kinds)) do
        add(event, Filter.Handler)
        registered[event] = true
    end
    Filter.active = next(registered) ~= nil
end
