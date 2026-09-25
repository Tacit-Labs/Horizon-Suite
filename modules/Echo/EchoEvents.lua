--[[
    Horizon Suite - Echo - Events
    Turns CHAT_MSG_* payloads into message records and hands them to the Store.
    All of Echo's secret-value handling lives here (spec: Intake and secret values):
      - sender readable, text secret: routed, flagged secret, never persisted
      - sender secret on a whisper: no conversation; counted as unrouted
    Blizzard: CHAT_MSG_* events, GetPlayerInfoByGUID, GetNormalizedRealmName, UnitGUID,
    ERR_CHAT_PLAYER_NOT_FOUND_S.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo
local Store = Echo.Store
local IsSecret = Echo.IsSecret

local Events = {}
Echo.Events = Events

-- Extra mention words (case-insensitive). Options fill this in plan 3.
Events.keywords = {}

local OUTGOING_EVENTS = {
    CHAT_MSG_WHISPER_INFORM    = true,
    CHAT_MSG_BN_WHISPER_INFORM = true,
}
local MENTION_KINDS = { party = true, raid = true, instance = true }

--- "Name" -> "Name-Realm"; a name that already carries a realm is unchanged.
-- @param name string
-- @return string|nil  nil for secret, empty or non-string names
function Events.NormaliseName(name)
    if IsSecret(name) or type(name) ~= "string" or name == "" then return nil end
    if name:find("-", 1, true) then return name end
    local realm = GetNormalizedRealmName and GetNormalizedRealmName()
    if type(realm) == "string" and realm ~= "" then return name .. "-" .. realm end
    return name
end

--- @return string|nil  The player's "Name-Realm"
function Events.PlayerKey()
    return Events.NormaliseName(UnitName and UnitName("player"))
end

--- True when a readable GUID is the player's own. Secret GUIDs are never compared.
-- @param guid any
-- @return boolean
local function IsPlayerGUID(guid)
    if guid == nil or IsSecret(guid) or type(guid) ~= "string" or not UnitGUID then return false end
    local ok, mine = pcall(UnitGUID, "player")
    if not ok or IsSecret(mine) or type(mine) ~= "string" then return false end
    return guid == mine
end

local function ClassFromGUID(guid)
    if IsSecret(guid) or type(guid) ~= "string" or not GetPlayerInfoByGUID then return nil end
    local ok, _, englishClass = pcall(GetPlayerInfoByGUID, guid)
    if ok and not IsSecret(englishClass) and type(englishClass) == "string" then return englishClass end
    return nil
end

--- True when readable text names the player or a configured keyword. Case-insensitive.
-- @param text string
-- @return boolean
function Events.IsMention(text)
    if IsSecret(text) or type(text) ~= "string" then return false end
    local lower = text:lower()
    local me = UnitName and UnitName("player")
    if type(me) == "string" and me ~= "" and lower:find(me:lower(), 1, true) then return true end
    for _, word in ipairs(Events.keywords) do
        if type(word) == "string" and word ~= "" and lower:find(word:lower(), 1, true) then return true end
    end
    return false
end

--- Conversation name for a channel. Zone channels arrive as "General - Zul'Aman"; the zone
-- is dropped so General stays one conversation as you travel. Custom channels keep their name.
-- @param name string  CHAT_MSG_CHANNEL arg 9
-- @param zoneChannelID number  arg 7; 0 for custom channels
-- @return string|nil
function Events.ChannelKeyName(name, zoneChannelID)
    if IsSecret(name) or type(name) ~= "string" or name == "" then return nil end
    if not IsSecret(zoneChannelID) and type(zoneChannelID) == "number" and zoneChannelID > 0 then
        return name:match("^(.-) %- ") or name
    end
    return name
end

--- Build a message record from a CHAT_MSG_* payload.
-- @return table|nil record
-- @return string|nil reason  "ignored" (not an Echo event) | "unrouted" (no conversation can be chosen)
function Events.BuildRecord(event, text, sender, _, _, _, _, zoneChannelID, channelIndex, channelName, _, _, guid, bnSenderID)
    local kind = Store.EVENT_KIND[event]
    if not kind then return nil, "ignored" end

    local id
    if kind == "whisper" then
        id = Events.NormaliseName(sender)
    elseif kind == "bnet" then
        if not IsSecret(bnSenderID) then id = bnSenderID end
    elseif kind == "channel" then
        id = Events.ChannelKeyName(channelName, zoneChannelID)
    end
    local convKey = Store.KeyFor(kind, id)
    if not convKey then return nil, "unrouted" end

    local senderKey = (kind ~= "bnet") and Events.NormaliseName(sender) or nil
    local outgoing = OUTGOING_EVENTS[event] == true
    if not outgoing and kind ~= "whisper" and kind ~= "bnet" then
        if senderKey ~= nil then
            outgoing = senderKey == Events.PlayerKey()
        else
            -- Secret sender: a readable GUID can still say the line is your own.
            outgoing = IsPlayerGUID(guid)
        end
    end

    local textSecret = IsSecret(text)
    local record = {
        convKey  = convKey,
        text     = text,
        secret   = textSecret,
        outgoing = outgoing,
        class    = (not outgoing) and ClassFromGUID(guid) or nil,
        time     = Store.Now(),
    }
    -- A whisper to yourself arrives twice: the received copy, then the sent echo.
    if kind == "whisper" and senderKey ~= nil and senderKey == Events.PlayerKey() then
        record.toSelf = true
    end
    -- The joined slot this line arrived on; Send replies there (it follows you between zones).
    if kind == "channel" and not IsSecret(channelIndex) and type(channelIndex) == "number" and channelIndex > 0 then
        record.channelIndex = channelIndex
    end
    if not outgoing then
        if kind == "bnet" then
            -- Protected |K display string: safe to SetText, never stored.
            if not IsSecret(sender) then record.sender = sender end
        else
            record.sender = senderKey
        end
    end
    record.urgent = (event == "CHAT_MSG_RAID_WARNING")
        or (MENTION_KINDS[kind] == true and not outgoing and not textSecret and Events.IsMention(text))
    return record
end

local notFoundPattern
local function NotFoundPattern()
    if notFoundPattern == nil then
        local fmt = ERR_CHAT_PLAYER_NOT_FOUND_S
        if type(fmt) == "string" and fmt:find("%s", 1, true) then
            local escaped = fmt:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0")
            notFoundPattern = "^" .. escaped:gsub("%%%%s", "(.+)", 1) .. "$"
        else
            notFoundPattern = false
        end
    end
    return notFoundPattern
end

--- Mark the pending whisper to a player who is not online as failed.
-- @param text string  CHAT_MSG_SYSTEM message
function Events.OnSystemMessage(text)
    if IsSecret(text) or type(text) ~= "string" then return end
    local pattern = NotFoundPattern()
    if not pattern then return end
    local name = text:match(pattern)
    local convKey = name and Store.KeyFor("whisper", Events.NormaliseName(name))
    if convKey then Store.MarkFailed(convKey) end
end

local PROBE_ARGS = { { 1, "text" }, { 2, "sender" }, { 7, "zoneChannelID" }, { 8, "channelIndex" }, { 9, "channelName" }, { 12, "guid" }, { 13, "bnSenderID" } }

--- One-line description of a chat payload for the verification probe.
-- Reports only type and secrecy, never values, so it is safe to print mid-encounter.
-- @return string
function Events.DescribeArgs(event, ...)
    local parts = { tostring(event) }
    for _, arg in ipairs(PROBE_ARGS) do
        local v = select(arg[1], ...)
        local state
        if v == nil then
            state = "nil"
        elseif IsSecret(v) then
            state = "SECRET"
        else
            state = type(v)
        end
        parts[#parts + 1] = arg[2] .. "=" .. state
    end
    local record, reason = Events.BuildRecord(event, ...)
    parts[#parts + 1] = "conv=" .. (record and record.convKey or ("none/" .. tostring(reason)))
    if record and Echo.Send then
        local route = Echo.Send.RouteFor(record.convKey)
        parts[#parts + 1] = "route=" .. (route
            and (route.chatType .. (route.target ~= nil and (":" .. tostring(route.target)) or ""))
            or "none")
    end
    return table.concat(parts, " ")
end

--- Describe the next `count` chat messages through outFn (spec: Verification before code).
-- @param count number
-- @param outFn function(string)
function Events.StartProbe(count, outFn)
    Events.probeRemaining = count
    Events.probeOut = outFn
end

--- Route one chat event. Exposed for tests and the probe.
function Events.Dispatch(event, ...)
    if (Events.probeRemaining or 0) > 0 and event ~= "CHAT_MSG_SYSTEM" and Events.probeOut then
        Events.probeRemaining = Events.probeRemaining - 1
        Events.probeOut(Events.DescribeArgs(event, ...))
    end
    if event == "CHAT_MSG_SYSTEM" then
        Events.OnSystemMessage((...))
        return
    end
    local record, reason = Events.BuildRecord(event, ...)
    if not record then
        if reason == "unrouted" then Store.CountUnrouted() end
        return
    end
    -- A conversation with yourself shows each message once. Typed in Blizzard's box, keep
    -- the received copy and drop the echo; sent from Echo, the pending line claims the
    -- received copy and the echo confirms it.
    if record.toSelf then
        if record.outgoing then
            if Store.HasPending(record.convKey) then Store.ConfirmSent(record) end
            return
        elseif Store.ClaimSelfEcho(record.convKey, record.text) then
            return
        end
    end
    if record.outgoing then
        Store.ConfirmSent(record)
    else
        Store.Add(record)
    end
end

local frame

function Events.Enable()
    if not frame then
        frame = CreateFrame("Frame")
        frame:SetScript("OnEvent", function(_, event, ...) Events.Dispatch(event, ...) end)
    end
    local hasBnet = addon.Platform and addon.Platform.Has("bnetWhispers")
    for event, kind in pairs(Store.EVENT_KIND) do
        if kind ~= "bnet" or hasBnet then frame:RegisterEvent(event) end
    end
    frame:RegisterEvent("CHAT_MSG_SYSTEM")
end

function Events.Disable()
    if frame then frame:UnregisterAllEvents() end
end
