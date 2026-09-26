--[[
    Horizon Suite - Echo - All
    The All view (plan 12): one read-only, quiet feed ("all") holding every line Echo files,
    plus everything else printed to the main chat window (addon prints, Blizzard system
    text that isn't a chat event, /dump). Never persisted, never grouped, capped at
    Store.ALL_CAP. Switched by echoAllView (Echo.FeedKey("all")), and always on while
    Blizzard's chat windows are hidden (Echo.FeedEnabled).
    Its sources, all built into lines by one builder (NewLine):
      - Echo's records, through a Store listener: each becomes an All line with its chat's
        short name and sender in a separate prefix field, and the record's outgoing flag.
        The line keeps its source (sourceKey, sourceRecord), so its menu pins the source.
        A secret text is kept as it is and never joined with the prefix.
      - Other text, through a post-hook on DEFAULT_CHAT_FRAME.AddMessage. A call from
        Blizzard's chat event handlers is skipped (Echo files those lines itself, or this
        file's own events below do), as is one from Echo's own code, and one whose stack
        is secret.
      - Chat types Echo has no tile for: while All collects, Echo's own frame here registers
        every CHAT_MSG_* in ChatTypeGroup that Echo doesn't route (and
        CHAT_MSG_COMMUNITIES_CHANNEL), in the message groups the player gives ChatFrame1
        (GetChatWindowMessages), runs other addons' filters over each, and files it. While
        Blizzard's chat is shown, ChatFrame1 shows them too, and the AddMessage skip above
        keeps them from arriving twice. A type whose text is a code is formatted from
        Blizzard's own template, or skipped; a raw code is never shown.
      - System events that aren't chat, only while Blizzard's chat is hidden (ChatFrame1
        prints them otherwise): /played, the guild's message of the day, chat and
        Battle.net connection notices, a regional send failure. Each only where the client
        has the event and the string Blizzard formats it with.
    Blizzard: hooksecurefunc, DEFAULT_CHAT_FRAME.AddMessage (post-hook only), debugstack,
    UnitName, ChatTypeGroup, ChatTypeInfo, GetChatWindowMessages, C_EventUtils.IsEventValid,
    SecondsToTime, and the global strings named below.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo
local Store = Echo.Store
local IsSecret = Echo.IsSecret
local L = addon.L

local All = {}
Echo.All = All

All.KEY = "all"
All.ICON = "Interface\\Icons\\INV_Misc_Note_01"

-- A stack holding any of these came from a chat event Echo already files, or from Echo.
local ADDON_ROOT = "Interface/AddOns/" .. (addon.ADDON_NAME or "HorizonSuite")
All.SKIP_STACKS = {
    "ChatFrame_OnEvent",
    "MessageEventHandler",
    "Blizzard_Channels",
    ADDON_ROOT .. "/modules/Echo",
    ((ADDON_ROOT .. "/modules/Echo"):gsub("/", "\\")),
}
-- This file's own frame, which sits at the top of the hook's stack.
local OWN_FILE = "modules/Echo/EchoAll.lua"
local OWN_FILE_BACKSLASH = (OWN_FILE:gsub("/", "\\"))

-- CHAT_MSG_COMBAT_* types are left out of the extra events, except these (and the ones
-- Echo routes itself).
All.COMBAT_KEEP = { CHAT_MSG_COMBAT_HONOR_GAIN = true }
-- Left out unless the player's ChatFrame1 message groups name them: a message group, or
-- (for channel joins and leaves) a chat type.
All.EXCLUDED = {
    TRADESKILLS = true, OPENING = true, PET_INFO = true, TARGETICONS = true,
    CHANNEL_JOIN = true, CHANNEL_LEAVE = true,
}
-- Chat events outside ChatTypeGroup that All takes too.
All.MORE_EVENTS = { "CHAT_MSG_COMMUNITIES_CHANNEL" }

local active = false
local subscribed = false
local hookedFrame
local eventFrame      -- Echo's frame for the extra chat and system events
local registered = {} -- event -> true while registered on eventFrame

-- Nearby styles whose text already names the speaker.
local NAMED_STYLES = { textemote = true, npcemote = true }

local function Readable(s)
    if IsSecret(s) or type(s) ~= "string" or s == "" then return nil end
    return s
end

local function Colour(v)
    if IsSecret(v) or type(v) ~= "number" then return nil end
    return v
end

-- A global string Blizzard formats a line with, or nil.
local function Global(name)
    local s = _G[name]
    if IsSecret(s) or type(s) ~= "string" or s == "" then return nil end
    return s
end

-- A chat type's colour from ChatTypeInfo, or nothing.
local function TypeColour(chatType)
    local types = _G.ChatTypeInfo
    local info = type(types) == "table" and types[chatType]
    if IsSecret(info) or type(info) ~= "table" then return nil end
    return info.r, info.g, info.b
end

--- One All line. Every source builds its line here. A secret text is kept as it is and
-- never inspected; an empty or unusable one gives no line. A missing colour is white.
-- @param text any  may be secret
-- @param prefix string|nil  drawn before the text, on its own
-- @return table|nil line
local function NewLine(text, prefix, r, g, b, time)
    local secret = IsSecret(text)
    if not secret then
        if type(text) == "number" then text = tostring(text) end
        if type(text) ~= "string" or text == "" then return nil end
    end
    r, g, b = Colour(r), Colour(g), Colour(b)
    if not (r and g and b) then r, g, b = 1, 1, 1 end
    return {
        convKey = All.KEY,
        text    = text,
        secret  = secret,
        prefix  = Readable(prefix),
        feed    = true,
        r = r, g = g, b = b,
        time    = time or Store.Now(),
    }
end

--- The prefix an All line shows before a record's text: the chat's short name in
-- brackets, then who spoke. nil when nothing readable is left to show.
-- @param conv table  the record's conversation
-- @param record table
-- @return string|nil
function All.PrefixFor(conv, record)
    local View = Echo.View
    if not View or type(conv) ~= "table" or type(record) ~= "table" then return nil end
    local name = Readable(View.DisplayName(conv))
    local kind = conv.kind
    if kind == "whisper" or kind == "bnet" then
        if not name then return nil end
        if record.outgoing then return "[" .. L["ECHO_ALL_TO"]:format(name) .. "]" end
        return "[" .. name .. "]"
    end
    local head = name and ("[" .. name .. "]") or nil
    if Store.FEED_KINDS[kind] or NAMED_STYLES[record.style] then return head end
    local who
    if record.outgoing then
        who = Readable(UnitName and UnitName("player"))
    else
        who = Readable(View.SenderName(record))
    end
    if not who then return head end
    -- A custom emote reads "[Nearby] Brisa dances", with no colon.
    local tail = (record.style == "emote") and who or (who .. ":")
    return head and (head .. " " .. tail) or tail
end

--- The All line for a record Echo filed: its text, prefix and colour, whether it was
-- yours, and where it came from (so its menu can pin the source).
-- @param conv table
-- @param record table
-- @return table|nil line  nil for a record with no text
function All.LineFor(conv, record)
    local r, g, b
    if Echo.View then r, g, b = Echo.View.LineColor(conv, record) end
    local line = NewLine(record.text, All.PrefixFor(conv, record), r, g, b, record.time)
    if not line then return nil end
    line.secret = (line.secret or record.secret) and true or false
    line.outgoing = record.outgoing and true or false
    line.sourceKey = record.convKey
    line.sourceRecord = record
    return line
end

local function Collecting()
    return active and (not Echo.FeedEnabled or Echo.FeedEnabled(All.KEY))
end

--- Whether All is collecting now: enabled, and its setting on (or chat hidden).
-- @return boolean
function All.Collecting()
    return Collecting() and true or false
end

--- Store listener: mirror each record Echo files into All. All's own lines, and changes
-- that carry no new record, are ignored.
-- @param convKey string|nil
-- @param change string|nil
-- @param record table|nil
function All.OnChange(convKey, change, record)
    if not Collecting() or convKey == nil or convKey == All.KEY or type(record) ~= "table" then return end
    local conv = Store.Get(convKey)
    if not conv then return end
    local line = All.LineFor(conv, record)
    if line then Store.Add(line) end
end

-- True when a stack line comes from this file (the hook itself).
local function OwnLine(line)
    return line:find(OWN_FILE, 1, true) ~= nil or line:find(OWN_FILE_BACKSLASH, 1, true) ~= nil
end

--- True when an AddMessage call should be left out: its stack is secret, or it came from a
-- chat event handler or from Echo.
-- @param stack any  debugstack()'s result
-- @return boolean
function All.SkipStack(stack)
    if IsSecret(stack) then return true end
    if type(stack) ~= "string" then return false end
    for line in stack:gmatch("[^\n]+") do
        if not OwnLine(line) then
            for _, marker in ipairs(All.SKIP_STACKS) do
                if line:find(marker, 1, true) then return true end
            end
        end
    end
    return false
end

--- File a printed-style line into All: a secret text is filed as it is, never inspected;
-- the prefix stays a field of its own and is never joined to it.
-- @param text string  may be secret
-- @param r number|nil  colour; white when any part is missing
-- @param g number|nil
-- @param b number|nil
-- @param prefix string|nil  drawn before the text, e.g. the sender's short name
-- @return boolean filed
function All.AddLine(text, r, g, b, prefix)
    if not Collecting() then return false end
    local line = NewLine(text, prefix, r, g, b)
    if not line then return false end
    Store.Add(line)
    return true
end

--- Post-hook on DEFAULT_CHAT_FRAME.AddMessage: file a printed line into All.
function All.OnAddMessage(_, text, r, g, b)
    if not Collecting() then return end
    local stack
    if type(debugstack) == "function" then
        local ok, s = pcall(debugstack, 2)
        if ok then stack = s end
    end
    if All.SkipStack(stack) then return end
    All.AddLine(text, r, g, b)
end

-- ---------------------------------------------------------------------------
-- Chat types Echo has no tile for, and system events while chat is hidden
-- ---------------------------------------------------------------------------

-- The message groups the player gives ChatFrame1, as a set; nil when the client can't
-- say (no API, an error, or no groups yet), and then every group is taken.
local function WindowGroups()
    local api = _G.GetChatWindowMessages
    if type(api) ~= "function" then return nil end
    local ok, list = pcall(function() return { api(1) } end)
    if not ok or type(list) ~= "table" then return nil end
    local set, any = {}, false
    for _, name in ipairs(list) do
        if not IsSecret(name) and type(name) == "string" then
            set[name] = true
            any = true
        end
    end
    return any and set or nil
end

--- Every chat event All takes on its own: each CHAT_MSG_* in ChatTypeGroup that Echo
-- doesn't route and this client has, in a message group the player gives ChatFrame1 (all
-- groups when that can't be read), never one of All.EXCLUDED unless that list names it,
-- and no combat types (All.COMBAT_KEEP aside); plus All.MORE_EVENTS.
-- @return table events  sorted
function All.ExtraEvents()
    local out, keep = {}, {}
    local groups = _G.ChatTypeGroup
    local routed = Store.EVENT_KIND
    local window = WindowGroups()
    local function Wanted(event)
        if routed[event] ~= nil then return false end
        -- Echo keys a few events without CHAT_MSG_ (BN_INLINE_TOAST_ALERT).
        if routed[event:sub(10)] ~= nil then return false end
        if event:sub(1, 16) == "CHAT_MSG_COMBAT_" and not All.COMBAT_KEEP[event] then return false end
        return true
    end
    if type(groups) == "table" then
        for group, list in pairs(groups) do
            if type(group) == "string" and type(list) == "table" then
                local inWindow = window == nil or window[group] == true
                local excluded = All.EXCLUDED[group] and not (window and window[group])
                for _, event in pairs(list) do
                    if type(event) == "string" and event:sub(1, 9) == "CHAT_MSG_" and Wanted(event) then
                        local chatType = event:sub(10)
                        local typeExcluded = All.EXCLUDED[chatType] and not (window and window[chatType])
                        if inWindow and not excluded and not typeExcluded then keep[event] = true end
                    end
                end
            end
        end
    end
    for _, event in ipairs(All.MORE_EVENTS) do
        if Wanted(event) then keep[event] = true end
    end
    for event in pairs(keep) do
        if Echo.IsEventValid(event) then out[#out + 1] = event end
    end
    table.sort(out)
    return out
end

local function Played(seconds)
    if IsSecret(seconds) or type(seconds) ~= "number" then return nil end
    local ok, s = pcall(_G.SecondsToTime, seconds)
    if ok and not IsSecret(s) and type(s) == "string" and s ~= "" then return s end
    return nil
end

-- Format a template with readable values; nil when any is missing or it fails.
local function Format(template, ...)
    if not template then return nil end
    for i = 1, select("#", ...) do
        local v = select(i, ...)
        if IsSecret(v) or (type(v) ~= "string" and type(v) ~= "number") then return nil end
    end
    local ok, s = pcall(string.format, template, ...)
    if ok and type(s) == "string" and s ~= "" then return s end
    return nil
end

-- System events that aren't chat, filed only while Blizzard's chat is hidden. Each names
-- the globals it needs (not registered without them), the chat type it takes its colour
-- from, and the lines it makes from the event's arguments ({ n = count, ... }; a nil
-- line is skipped).
All.SYSTEM_EVENTS = {
    TIME_PLAYED_MSG = { strings = { "TIME_PLAYED_TOTAL", "TIME_PLAYED_LEVEL", "SecondsToTime" }, colour = "SYSTEM",
        lines = function(total, level)
            return { n = 2, Format(Global("TIME_PLAYED_TOTAL"), Played(total)), Format(Global("TIME_PLAYED_LEVEL"), Played(level)) }
        end },
    GUILD_MOTD = { strings = { "GUILD_MOTD_TEMPLATE" }, colour = "GUILD",
        lines = function(motd) return { n = 1, Format(Global("GUILD_MOTD_TEMPLATE"), Readable(motd)) } end },
    CHAT_SERVER_DISCONNECTED = { strings = { "CHAT_SERVER_DISCONNECTED_MESSAGE" }, colour = "SYSTEM",
        lines = function() return { n = 1, Global("CHAT_SERVER_DISCONNECTED_MESSAGE") } end },
    CHAT_SERVER_RECONNECTED = { strings = { "CHAT_SERVER_RECONNECTED_MESSAGE" }, colour = "SYSTEM",
        lines = function() return { n = 1, Global("CHAT_SERVER_RECONNECTED_MESSAGE") } end },
    -- Blizzard stays quiet when the event asks it to (suppressNotification).
    BN_CONNECTED = { strings = { "BN_CHAT_CONNECTED" }, colour = "SYSTEM",
        lines = function(suppress)
            if not IsSecret(suppress) and suppress == true then return { n = 0 } end
            return { n = 1, Global("BN_CHAT_CONNECTED") }
        end },
    BN_DISCONNECTED = { strings = { "BN_CHAT_DISCONNECTED" }, colour = "SYSTEM",
        lines = function(_, suppress)
            if not IsSecret(suppress) and suppress == true then return { n = 0 } end
            return { n = 1, Global("BN_CHAT_DISCONNECTED") }
        end },
    CHAT_REGIONAL_SEND_FAILED = { strings = { "ERR_CHAT_REGIONAL_SEND_FAILED" }, colour = "SYSTEM",
        lines = function() return { n = 1, Global("ERR_CHAT_REGIONAL_SEND_FAILED") } end },
}

local function HasStrings(entry)
    for _, name in ipairs(entry.strings) do
        local v = _G[name]
        if v == nil or IsSecret(v) or (type(v) ~= "string" and type(v) ~= "function") then return false end
    end
    return true
end

local function Hiding()
    return Echo.HideChat ~= nil and Echo.HideChat.IsApplied() == true
end

--- The short name of a readable sender; a Battle.net |K name is used whole, never cut.
local function ShortName(event, sender)
    if IsSecret(sender) or type(sender) ~= "string" or sender == "" then return nil end
    if event:sub(1, 12) == "CHAT_MSG_BN_" or sender:find("|K", 1, true) then return sender end
    return sender:match("^([^-]+)") or sender
end

-- Chat types whose first argument is a code, not text: the line is Blizzard's template
-- for it (CHAT_<code>_NOTICE_BN, else CHAT_<code>_NOTICE), filled in as Blizzard does.
local NOTICE_TYPES = { CHANNEL_NOTICE = true, CHANNEL_NOTICE_USER = true }
-- Chat types with no text of their own: Blizzard's string, with the name when readable.
local TEMPLATE_TYPES = { IGNORED = "CHAT_IGNORED", FILTERED = "CHAT_FILTERED", RESTRICTED = "CHAT_RESTRICTED_TRIAL" }
-- Chat types whose prefix is Blizzard's "Name is Away From Keyboard: " string.
local AWAY_TYPES = { AFK = "CHAT_AFK_GET", DND = "CHAT_DND_GET" }

--- The text and prefix All files for one unrouted chat event's (filtered) arguments, and
-- the chat type whose colour it takes. nil text: nothing is filed. A secret text is kept
-- as it is and never joined to the prefix.
-- @param event string  CHAT_MSG_*
-- @param args table  { n = count, ... }
-- @return any text, string|nil prefix, string colourType
function All.FormatChat(event, args)
    local chatType = event:sub(10)
    local text, sender = args[1], args[2]
    if NOTICE_TYPES[chatType] then
        local code = Readable(text)
        if not code then return nil, nil, chatType end
        local template = Global("CHAT_" .. code .. "_NOTICE_BN") or Global("CHAT_" .. code .. "_NOTICE")
        local number, channel = args[8], args[4]
        local colourType = chatType
        if not IsSecret(number) and type(number) == "number" and TypeColour("CHANNEL" .. number) then
            colourType = "CHANNEL" .. number
        end
        if not Readable(channel) then return nil, nil, colourType end
        -- A notice about a user also names them, third, as Blizzard's does.
        if chatType == "CHANNEL_NOTICE_USER" then
            return Format(template, number, channel, Readable(sender) or ""), nil, colourType
        end
        return Format(template, number, channel), nil, colourType
    end
    if TEMPLATE_TYPES[chatType] then
        local template = Global(TEMPLATE_TYPES[chatType])
        if not template then return nil, nil, chatType end
        if not template:find("%", 1, true) then return template, nil, chatType end
        return Format(template, Readable(sender)), nil, chatType
    end
    local name = ShortName(event, sender)
    local prefix = name and (name .. ":") or nil
    if AWAY_TYPES[chatType] and name then
        local away = Format(Global(AWAY_TYPES[chatType]), name)
        if away then prefix = away:match("^(.-)%s*$") end
    end
    -- NPC and boss speech reads "%s roars!": fill in the speaker, as Blizzard's chat does,
    -- and drop the prefix. No other type is formatted.
    if (chatType:sub(1, 8) == "MONSTER_" or chatType:sub(1, 10) == "RAID_BOSS_")
        and not IsSecret(text) and type(text) == "string" and text:find("%s", 1, true) then
        local ok, formatted = pcall(string.format, text, name or L["ECHO_SOMEONE"])
        if ok then text, prefix = formatted, nil end
    end
    return text, prefix, chatType
end

--- One of All's own events: a system event's lines, or an unrouted chat line after other
-- addons' filters (a blocked one is dropped).
-- @param event string
function All.OnEvent(event, ...)
    if not Collecting() then return end
    local system = All.SYSTEM_EVENTS[event]
    if system then
        if not Hiding() then return end
        local r, g, b = TypeColour(system.colour)
        local lines = system.lines(...)
        for i = 1, lines.n do
            if lines[i] then All.AddLine(lines[i], r, g, b) end
        end
        return
    end
    local blocked, args = Echo.Events.RunFilters(event, ...)
    if blocked then return end
    local text, prefix, colourType = All.FormatChat(event, args)
    if text == nil then return end
    local r, g, b = TypeColour(colourType)
    All.AddLine(text, r, g, b, prefix)
end

--- Register the events All takes on its own, and drop the rest: the extra chat events
-- while All collects, and the system events while Blizzard's chat is hidden too.
-- Echo.ApplyOptions and HideChat.Apply call this.
function All.SyncEvents()
    local want = {}
    if Collecting() then
        for _, event in ipairs(All.ExtraEvents()) do want[event] = true end
        if Hiding() then
            for event, entry in pairs(All.SYSTEM_EVENTS) do
                if HasStrings(entry) and Echo.IsEventValid(event) then want[event] = true end
            end
        end
    end
    if not eventFrame then
        if next(want) == nil then return end
        eventFrame = CreateFrame("Frame")
        eventFrame:SetScript("OnEvent", function(_, event, ...) All.OnEvent(event, ...) end)
    end
    for event in pairs(registered) do
        if not want[event] then
            pcall(eventFrame.UnregisterEvent, eventFrame, event)
            registered[event] = nil
        end
    end
    for event in pairs(want) do
        if not registered[event] and pcall(eventFrame.RegisterEvent, eventFrame, event) then registered[event] = true end
    end
end

--- Start collecting. The Store listener and the hook are installed once; Disable only
-- stops them acting, since a post-hook can't be removed.
function All.Enable()
    active = true
    if not subscribed then
        Store.Subscribe(All.OnChange)
        subscribed = true
    end
    local frame = _G.DEFAULT_CHAT_FRAME
    if not hookedFrame and type(frame) == "table" and type(hooksecurefunc) == "function" then
        hookedFrame = frame
        hooksecurefunc(frame, "AddMessage", All.OnAddMessage)
    end
end

function All.Disable()
    active = false
    if eventFrame then eventFrame:UnregisterAllEvents() end
    registered = {}
end

-- Test and debug handle.
function All._frame() return eventFrame end
