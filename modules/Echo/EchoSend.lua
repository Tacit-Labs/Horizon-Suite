--[[
    Horizon Suite - Echo - Send
    The one place Echo sends chat. Maps a conversation key to a chat type and target,
    splits long text at spaces outside links, and files each part as pending until
    EchoEvents sees the echo. Blizzard: C_ChatInfo.SendChatMessage (or SendChatMessage),
    BNSendWhisper (or C_BattleNet.SendWhisper), GetChannelName,
    C_ChatInfo.InChatMessagingLockdown.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo
local Store = Echo.Store

local Send = {}
Echo.Send = Send

Send.MAX_BYTES = 255

local GROUP_CHAT_TYPE = {
    party    = "PARTY",
    raid     = "RAID",
    instance = "INSTANCE_CHAT",
    guild    = "GUILD",
    officer  = "OFFICER",
}

-- The joined index for a channel conversation: the slot its last message arrived on, while
-- that slot still holds the same channel, else a lookup by name. Zone channels carry the
-- zone in their joined name ("General - Stormwind City"), so they are compared without it.
local function ChannelIndexFor(convKey)
    if not GetChannelName then return nil end
    local keyName = convKey:sub(4)
    local conv = Store.Get(convKey)
    local remembered = conv and conv.channelIndex
    if remembered then
        local id, joinedName = GetChannelName(remembered)
        if id == remembered and not Echo.IsSecret(joinedName) and type(joinedName) == "string"
            and (joinedName == keyName or joinedName:match("^(.-) %- ") == keyName) then
            return remembered
        end
    end
    local index = GetChannelName(keyName)
    if type(index) == "number" and index > 0 then return index end
    return nil
end

--- Where a reply to this conversation goes.
-- @param convKey string
-- @return table|nil route  { chatType = string, target = string|number|nil }
function Send.RouteFor(convKey)
    local kind = Store.KindOf(convKey)
    if kind == "whisper" then
        return { chatType = "WHISPER", target = convKey:sub(3) }
    elseif kind == "bnet" then
        local id = tonumber(convKey:sub(4))
        return id and { chatType = "BN_WHISPER", target = id } or nil
    elseif kind == "channel" then
        local index = ChannelIndexFor(convKey)
        return index and { chatType = "CHANNEL", target = index } or nil
    elseif GROUP_CHAT_TYPE[kind] then
        return { chatType = GROUP_CHAT_TYPE[kind] }
    elseif kind == "nearby" then
        return { chatType = Store.SendModeOf(convKey) }
    end
    return nil
end

local function LinkRanges(text)
    local ranges, init = {}, 1
    while true do
        local s, e = text:find("|H.-|h.-|h", init)
        if not s then break end
        ranges[#ranges + 1] = { s, e }
        init = e + 1
    end
    return ranges
end

local function InsideLink(ranges, pos)
    for _, r in ipairs(ranges) do
        if pos >= r[1] and pos <= r[2] then return true end
    end
    return false
end

--- Split text into parts of at most limit bytes, breaking at spaces outside links.
-- @param text string
-- @param limit number|nil  Defaults to Send.MAX_BYTES
-- @return table parts  empty when text is blank
function Send.Split(text, limit)
    limit = limit or Send.MAX_BYTES
    local parts = {}
    text = (text:gsub("^%s+", ""):gsub("%s+$", ""))
    while #text > limit do
        local ranges = LinkRanges(text)
        local cut
        for pos = limit + 1, 2, -1 do
            if text:sub(pos, pos):match("%s") and not InsideLink(ranges, pos) then
                cut = pos
                break
            end
        end
        if cut then
            parts[#parts + 1] = (text:sub(1, cut - 1):gsub("%s+$", ""))
            text = (text:sub(cut + 1):gsub("^%s+", ""))
        else
            -- No usable space: hard cut, backing off so a UTF-8 character is never split.
            local stop = limit
            while stop > 1 do
                local b = text:byte(stop + 1)
                if not b or b < 0x80 or b >= 0xC0 then break end
                stop = stop - 1
            end
            parts[#parts + 1] = text:sub(1, stop)
            text = text:sub(stop + 1)
        end
    end
    if text ~= "" then parts[#parts + 1] = text end
    return parts
end

--- The client's send functions, looked up per call so tests and late-loading clients agree.
-- @return function|nil sendChat, function|nil sendBN
function Send.Resolve()
    local sendChat = (C_ChatInfo and C_ChatInfo.SendChatMessage) or SendChatMessage
    local sendBN = BNSendWhisper or (C_BattleNet and C_BattleNet.SendWhisper)
    return sendChat, sendBN
end

--- True while the client blocks addon chat sends (Midnight encounter lockdown).
-- A missing or throwing check counts as unlocked.
-- @return boolean
function Send.InLockdown()
    local check = C_ChatInfo and C_ChatInfo.InChatMessagingLockdown
    if type(check) ~= "function" then return false end
    local ok, locked = pcall(check)
    return ok and locked == true
end

-- The style a Nearby line sent in each mode is drawn with while it waits for its echo.
local MODE_STYLE = { SAY = "say", YELL = "yell", EMOTE = "emote" }

--- Send a reply. Each part is filed as pending; the echo marks it sent. During chat
-- lockdown each part is filed and failed at once, and nothing is sent.
-- A Nearby send the game refuses by throwing (addon Say and Yell are restricted outside
-- instances on some clients) is failed like any other, and reported as "blocked" so the
-- card can say why.
-- @param convKey string
-- @param text string
-- @return boolean sent  false when there was nothing to send or nowhere to send it
-- @return string|nil problem  "blocked" when a Nearby send threw
function Send.Send(convKey, text)
    if type(text) ~= "string" then return false end
    local route = Send.RouteFor(convKey)
    if not route then return false end
    local parts = Send.Split(text)
    if #parts == 0 then return false end
    local sendChat, sendBN = Send.Resolve()
    local locked = Send.InLockdown()
    local nearby = Store.KindOf(convKey) == "nearby"
    local style = nearby and MODE_STYLE[route.chatType] or nil
    local problem
    for _, part in ipairs(parts) do
        Store.AddPending(convKey, part, style)
        local ok
        if locked then
            ok = false
        elseif route.chatType == "BN_WHISPER" then
            ok = sendBN and pcall(sendBN, route.target, part)
        elseif sendChat then
            ok = pcall(sendChat, part, route.chatType, nil, route.target)
            if not ok and nearby then problem = "blocked" end
        end
        if not ok then Store.MarkFailed(convKey) end
    end
    -- A dropped Nearby line never echoes: check once its window has passed.
    if nearby and not locked and C_Timer and type(C_Timer.After) == "function" then
        C_Timer.After(Store.NEARBY_CONFIRM_SECONDS + 0.5, Send.ExpireNearby)
    end
    return true, problem
end

--- Fail Nearby lines that were never confirmed, and let the card say why.
-- @return number failed
function Send.ExpireNearby()
    local failed = Store.ExpirePending(Store.Now())
    if failed > 0 and Echo.Card and Echo.Card.NoteNearbyBlocked then Echo.Card.NoteNearbyBlocked() end
    return failed
end

-- Chat shortcuts typed in a reply box ------------------------------------------------

-- The English forms of each shortcut, lower case, without the slash.
local SHORTCUTS = {
    s = "say", say = "say",
    y = "yell", yell = "yell", sh = "yell", shout = "yell",
    e = "emote", em = "emote", emote = "emote", me = "emote",
    g = "guild", guild = "guild",
    o = "officer", officer = "officer",
    p = "party", party = "party",
    ra = "raid", raid = "raid", rw = "raid",
    i = "instance", instance = "instance", bg = "instance",
    w = "whisper", whisper = "whisper", t = "whisper", tell = "whisper",
    r = "reply", reply = "reply",
    inv = "invite", invite = "invite",
}

-- Blizzard's localised SLASH_<NAME><n> globals for each shortcut. They add to the English
-- forms and never replace one. Numbering can have gaps, so every n up to 20 is read.
local SLASH_GLOBALS = {
    SAY = "say", YELL = "yell", EMOTE = "emote", GUILD = "guild", OFFICER = "officer",
    PARTY = "party", RAID = "raid", RAID_WARNING = "raid", INSTANCE_CHAT = "instance",
    WHISPER = "whisper", REPLY = "reply", INVITE = "invite",
}

local NEARBY_MODE = { say = "SAY", yell = "YELL", emote = "EMOTE" }

-- The shortcut a command word names, or nil. word is lower case, without the slash.
local function ShortcutFor(word)
    if SHORTCUTS[word] then return SHORTCUTS[word] end
    for name, target in pairs(SLASH_GLOBALS) do
        for n = 1, 20 do
            local g = _G["SLASH_" .. name .. n]
            if g ~= nil and not Echo.IsSecret(g) and type(g) == "string" and g:lower() == "/" .. word then return target end
        end
    end
    return nil
end

--- Whether the player can reach a group conversation now. Tests replace it; each check
-- reads the client when it has the function and counts a missing one as reachable.
-- Officer chat asks C_GuildInfo.CanSpeakInOfficerChat where the client has it, else
-- CanEditOfficerNote (C_GuildInfo's or the global), else only whether you are in a guild.
-- @param kind string  "party" | "raid" | "instance" | "guild" | "officer"
-- @return boolean
function Send.CanReach(kind)
    local function ask(fn, ...)
        if type(fn) ~= "function" then return true end
        local ok, v = pcall(fn, ...)
        if not ok or Echo.IsSecret(v) then return false end
        return v and true or false
    end
    -- Home group only: in a group-finder group, party chat goes to instance chat instead.
    if kind == "party" then return ask(IsInGroup, LE_PARTY_CATEGORY_HOME) end
    -- Home raid only: an LFR raid is an instance group, and talks in instance chat.
    if kind == "raid" then return ask(IsInRaid, LE_PARTY_CATEGORY_HOME) end
    -- Without the category, IsInGroup would answer for any group: count none.
    if kind == "instance" then
        if LE_PARTY_CATEGORY_INSTANCE == nil then return false end
        return ask(IsInGroup, LE_PARTY_CATEGORY_INSTANCE)
    end
    if kind == "officer" then
        local canSpeak = C_GuildInfo and C_GuildInfo.CanSpeakInOfficerChat
        if type(canSpeak) == "function" then return ask(canSpeak) end
        local canEdit = (C_GuildInfo and C_GuildInfo.CanEditOfficerNote) or _G.CanEditOfficerNote
        if type(canEdit) == "function" then return ask(canEdit) end
        return ask(IsInGuild)
    end
    if kind == "guild" then return ask(IsInGuild) end
    return true
end

-- The channel conversation joined in slot n, or nil. A zone channel's joined name carries
-- the zone ("General - Stormwind City"), which its key leaves out, as Events does.
local function ChannelKeyForSlot(n)
    if type(GetChannelName) ~= "function" then return nil end
    local ok, id, name = pcall(GetChannelName, n)
    if not ok or Echo.IsSecret(id) or Echo.IsSecret(name) then return nil end
    if type(id) ~= "number" or id <= 0 or type(name) ~= "string" or name == "" then return nil end
    local zone = name:find(" - ", 1, true) and 1 or nil
    local keyName = Echo.Events.ChannelKeyName(name, zone)
    return keyName and Store.KeyFor("channel", keyName) or nil
end
Send.ChannelKeyForSlot = ChannelKeyForSlot

--- The whisper conversation key for a typed name. The realm is added when none is given.
-- An existing whisper wins whatever the case typed; a new name gets a capital first letter
-- when it is ASCII a-z, and is otherwise left as typed. A name with "|" in it (a
-- Battle.net |K name, a link) or with a space is never parsed.
-- Shared by /w and the Whisper... prompt under Start a chat… (the Echo icon's menu).
-- @param name string
-- @return string|nil convKey
function Send.WhisperKeyFor(name)
    if Echo.IsSecret(name) or type(name) ~= "string" or name == "" then return nil end
    if name:find("|", 1, true) or name:find("%s") then return nil end
    local full = Echo.Events.NormaliseName(name)
    local typed = full and Store.KeyFor("whisper", full)
    if not typed then return nil end
    local key = Store.WhisperKeyLike(typed)
    if key then return key end
    local first = full:sub(1, 1)
    if first:match("^[a-z]$") then full = first:upper() .. full:sub(2) end
    return Store.KeyFor("whisper", full)
end

-- A switch result: send rest to key, or just switch when rest is blank.
local function Result(key, rest, mode)
    if rest == "" then return { blocked = "empty", convKey = key, mode = mode } end
    return { convKey = key, text = rest, mode = mode }
end

--- Read a chat shortcut at the start of a reply box's text. Leading spaces are skipped, so
-- " /dance" is still a command. Text that doesn't start with "/" is not a shortcut; any
-- other slash command is blocked, never sent as chat.
-- @param text string
-- @param currentKey string|nil  the conversation the box belongs to: where a bare /inv goes
-- @return table|nil result  nil: send as typed. { convKey, text, mode|nil }: send text
--   there. { action = "invite", name = "Name-Realm" }: invite, send nothing.
--   { blocked = "command" }, { blocked = "empty", convKey, mode|nil } or
--   { blocked = "nowhere" }.
function Send.ParseShortcut(text, currentKey)
    if Echo.IsSecret(text) or type(text) ~= "string" then return nil end
    text = text:gsub("^%s+", "")
    if text:sub(1, 1) ~= "/" then return nil end
    local word, rest = text:match("^/(%S*)%s*(.*)$")
    word = (word or ""):lower()
    rest = rest or ""

    local slot = word:match("^([1-9])$")
    if slot then
        local key = ChannelKeyForSlot(tonumber(slot))
        if not key then return { blocked = "nowhere" } end
        return Result(key, rest)
    end

    local target = ShortcutFor(word)
    if not target then return { blocked = "command" } end
    if NEARBY_MODE[target] then return Result("nearby", rest, NEARBY_MODE[target]) end
    if GROUP_CHAT_TYPE[target] then
        if not Send.CanReach(target) then return { blocked = "nowhere" } end
        return Result(target, rest)
    end
    if target == "invite" then
        -- /inv Name: the name as /w reads it. /inv alone: the whisper the box belongs to.
        local key
        local name = rest:match("^(%S+)")
        if name then
            key = Send.WhisperKeyFor(name)
        elseif not Echo.IsSecret(currentKey) and Store.KindOf(currentKey) == "whisper" then
            key = currentKey
        end
        local full = key and key:sub(3)
        if not full or full == "" or full:find("|", 1, true) or full:find("%s") then
            return { blocked = "nowhere" }
        end
        return { action = "invite", name = full }
    end
    if target == "reply" then
        local key = Store.NewestIncomingWhisper()
        if not key then return { blocked = "nowhere" } end
        return Result(key, rest)
    end
    -- A whisper: the name runs to the first space. A name with "|" in it (a Battle.net
    -- |K name, a link) is never parsed.
    local name, message = rest:match("^(%S+)%s*(.*)$")
    local key = Send.WhisperKeyFor(name)
    if not key then return { blocked = "nowhere" } end
    return Result(key, message or "")
end
