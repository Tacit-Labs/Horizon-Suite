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
        local index = GetChannelName and GetChannelName(convKey:sub(4))
        if type(index) ~= "number" or index == 0 then return nil end
        return { chatType = "CHANNEL", target = index }
    elseif GROUP_CHAT_TYPE[kind] then
        return { chatType = GROUP_CHAT_TYPE[kind] }
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

--- Send a reply. Each part is filed as pending; the echo marks it sent. During chat
-- lockdown each part is filed and failed at once, and nothing is sent.
-- @param convKey string
-- @param text string
-- @return boolean sent  false when there was nothing to send or nowhere to send it
function Send.Send(convKey, text)
    if type(text) ~= "string" then return false end
    local route = Send.RouteFor(convKey)
    if not route then return false end
    local parts = Send.Split(text)
    if #parts == 0 then return false end
    local sendChat, sendBN = Send.Resolve()
    local locked = Send.InLockdown()
    for _, part in ipairs(parts) do
        Store.AddPending(convKey, part)
        local ok
        if locked then
            ok = false
        elseif route.chatType == "BN_WHISPER" then
            ok = sendBN and pcall(sendBN, route.target, part)
        else
            ok = sendChat and pcall(sendChat, part, route.chatType, nil, route.target)
        end
        if not ok then Store.MarkFailed(convKey) end
    end
    return true
end
