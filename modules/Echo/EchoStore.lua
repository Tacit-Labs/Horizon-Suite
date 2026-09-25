--[[
    Horizon Suite - Echo - Store
    Conversation model: keys, tiers, ordering, unread counts and outgoing status.
    No frames, so tools/test_echo_logic.js drives it directly. Views subscribe
    with Store.Subscribe and redraw the one conversation they are told about.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Store = {}
Echo.Store = Store

--- True when v is a Midnight secret value. Never throws; false on clients without secrets.
-- Ask this before calling type(), comparing, concatenating or lowercasing a chat argument.
-- @param v any
-- @return boolean
function Echo.IsSecret(v)
    if v == nil or type(issecretvalue) ~= "function" then return false end
    local ok, secret = pcall(issecretvalue, v)
    return ok and secret == true
end

Store.MAX_MESSAGES = 100

-- Spec "Notification tiers". "muted" is the per-conversation mute: stored, never counted.
Store.DEFAULT_TIERS = {
    whisper = "loud",  bnet = "loud",
    party   = "count", raid = "count", instance = "count",
    guild   = "quiet", officer = "quiet", channel = "quiet",
}
Store.VALID_TIERS = { loud = true, count = true, quiet = true, muted = true }

-- Leader and warning variants fold into their channel.
Store.EVENT_KIND = {
    CHAT_MSG_WHISPER              = "whisper",
    CHAT_MSG_WHISPER_INFORM       = "whisper",
    CHAT_MSG_BN_WHISPER           = "bnet",
    CHAT_MSG_BN_WHISPER_INFORM    = "bnet",
    CHAT_MSG_PARTY                = "party",
    CHAT_MSG_PARTY_LEADER         = "party",
    CHAT_MSG_RAID                 = "raid",
    CHAT_MSG_RAID_LEADER          = "raid",
    CHAT_MSG_RAID_WARNING         = "raid",
    CHAT_MSG_INSTANCE_CHAT        = "instance",
    CHAT_MSG_INSTANCE_CHAT_LEADER = "instance",
    CHAT_MSG_GUILD                = "guild",
    CHAT_MSG_OFFICER              = "officer",
    CHAT_MSG_CHANNEL              = "channel",
}

-- Only whisper kinds are written to history.
Store.PERSISTED_KINDS = { whisper = true, bnet = true }

local conversations = {}
local overrides = {}
local listeners = {}
local unrouted = 0
local seq = 0  -- monotonic: time() has one-second resolution, ordering needs better

--- Current time; tests replace it.
-- @return number
function Store.Now()
    return time and time() or 0
end

--- Build a conversation key.
-- @param kind string  A Store.DEFAULT_TIERS key
-- @param id string|number|nil  "Name-Realm" (whisper), account ID (bnet), base name (channel)
-- @return string|nil convKey  nil when a kind that needs an id has none
function Store.KeyFor(kind, id)
    if kind == "whisper" or kind == "bnet" or kind == "channel" then
        if id == nil or id == "" then return nil end
        local prefix = (kind == "whisper" and "w:") or (kind == "bnet" and "bn:") or "ch:"
        return prefix .. tostring(id)
    end
    if Store.DEFAULT_TIERS[kind] then return kind end
    return nil
end

--- Kind of a conversation key.
-- @param convKey string
-- @return string|nil kind
function Store.KindOf(convKey)
    if type(convKey) ~= "string" then return nil end
    local prefix = convKey:match("^(%a+):.")
    if prefix == "w" then return "whisper" end
    if prefix == "bn" then return "bnet" end
    if prefix == "ch" then return "channel" end
    if prefix or convKey:find(":", 1, true) then return nil end
    if Store.DEFAULT_TIERS[convKey] then return convKey end
    return nil
end

local function Notify(convKey, change)
    local snapshot = {}
    for i = 1, #listeners do snapshot[i] = listeners[i] end
    for _, fn in ipairs(snapshot) do
        local ok, err = pcall(fn, convKey, change)
        if not ok then
            local handler = geterrorhandler and geterrorhandler()
            if handler then handler(err) end
        end
    end
end

--- Register a view.
-- @param fn function(convKey, change)  change: "toast" | "count" | "quiet" | "silent" |
--   "update" | "closed" | "unrouted" | "reset" | "restored"; convKey is nil for "unrouted", "reset" and "restored"
function Store.Subscribe(fn)
    if type(fn) == "function" then listeners[#listeners + 1] = fn end
end

--- Tier for a conversation: its override, else its kind's default.
-- @param convKey string
-- @return string "loud" | "count" | "quiet" | "muted"
function Store.TierOf(convKey)
    local override = overrides[convKey]
    if override then return override end
    local kind = Store.KindOf(convKey)
    return (kind and Store.DEFAULT_TIERS[kind]) or "quiet"
end

--- Override one conversation's tier; nil restores the default.
-- @param convKey string
-- @param tier string|nil
-- @return boolean accepted
function Store.SetTier(convKey, tier)
    if tier ~= nil and not Store.VALID_TIERS[tier] then return false end
    overrides[convKey] = tier
    Notify(convKey, "update")
    return true
end

local function GetOrCreate(convKey)
    local conv = conversations[convKey]
    if conv then return conv end
    seq = seq + 1
    conv = {
        key        = convKey,
        kind       = Store.KindOf(convKey),
        messages   = {},
        unread     = 0,
        createdSeq = seq,
        lastLoud   = 0,
        pinned     = false,
        open       = true,
    }
    if Store.PERSISTED_KINDS[conv.kind] and Echo.History then
        conv.messages = Echo.History.Load(convKey)
    end
    conversations[convKey] = conv
    return conv
end

local function Append(conv, record)
    local messages = conv.messages
    messages[#messages + 1] = record
    while #messages > Store.MAX_MESSAGES do table.remove(messages, 1) end
end

local function Persist(record)
    if Echo.History and Store.PERSISTED_KINDS[Store.KindOf(record.convKey)] then
        Echo.History.Append(record.convKey, record)
    end
end

--- File a message record (spec: Message record).
-- Incoming: unread +1 unless muted; loud, or urgent on a count conversation, moves it up.
-- Outgoing: clears unread; on a loud conversation it moves it up.
-- @param record table
-- @return string|nil change  "toast" | "count" | "quiet" | "silent"; nil when rejected
function Store.Add(record)
    if type(record) ~= "table" or not Store.KindOf(record.convKey) then return nil end
    local conv = GetOrCreate(record.convKey)
    seq = seq + 1
    record.seq = seq
    record.time = record.time or Store.Now()
    Append(conv, record)
    conv.open = true
    if record.channelIndex then conv.channelIndex = record.channelIndex end
    Persist(record)

    local tier = Store.TierOf(record.convKey)
    local change
    if record.outgoing then
        change = "silent"
        if not record.keepUnread then conv.unread = 0 end
        if tier == "loud" then conv.lastLoud = seq end
    elseif tier == "muted" then
        change = "silent"
    else
        conv.unread = conv.unread + 1
        if tier == "loud" or (tier == "count" and record.urgent) then
            change = "toast"
            conv.lastLoud = seq
        elseif tier == "count" then
            change = "count"
        else
            change = "quiet"
        end
    end
    Notify(record.convKey, change)
    return change
end

--- @param convKey string
-- @return table|nil conversation
function Store.Get(convKey)
    return conversations[convKey]
end

--- Open conversations: pinned first, then most recent loud message, then conversations
-- restored from the last session in their saved order, then newest created.
-- Count and quiet messages never change the order.
-- @return table conversations
function Store.List()
    local out = {}
    for _, conv in pairs(conversations) do
        if conv.open then out[#out + 1] = conv end
    end
    table.sort(out, function(a, b)
        if a.pinned ~= b.pinned then return a.pinned end
        if a.lastLoud ~= b.lastLoud then return a.lastLoud > b.lastLoud end
        local ra, rb = a.restoreRank, b.restoreRank
        if (ra ~= nil) ~= (rb ~= nil) then return ra ~= nil end
        if ra and ra ~= rb then return ra < rb end
        return a.createdSeq > b.createdSeq
    end)
    return out
end

function Store.MarkRead(convKey)
    local conv = conversations[convKey]
    if not conv or conv.unread == 0 then return end
    conv.unread = 0
    Notify(convKey, "update")
end

function Store.SetPinned(convKey, pinned)
    local conv = conversations[convKey]
    if not conv then return end
    conv.pinned = pinned and true or false
    Notify(convKey, "update")
end

--- Remove a conversation's tile. Messages are kept, so a new message reopens it with context.
function Store.Close(convKey)
    local conv = conversations[convKey]
    if not conv then return end
    conv.open = false
    conv.unread = 0
    conv.pinned = false
    Notify(convKey, "closed")
end

--- A message Echo could not file (secret sender). Blizzard's chat frame still shows it.
function Store.CountUnrouted()
    unrouted = unrouted + 1
    Notify(nil, "unrouted")
end

function Store.GetUnroutedCount()
    return unrouted
end

function Store.ClearUnrouted()
    unrouted = 0
    Notify(nil, "unrouted")
end

--- File an outgoing message before the server confirms it.
-- @param convKey string
-- @param text string
-- @return table|nil record  status "pending"
function Store.AddPending(convKey, text)
    local record = { convKey = convKey, text = text, outgoing = true, status = "pending" }
    if not Store.Add(record) then return nil end
    return record
end

local function OldestPending(conv, text, anyText)
    for _, m in ipairs(conv.messages) do
        if m.status == "pending" and (anyText or m.text == text) then return m end
    end
    return nil
end

-- The server echoes whispers in send order but may re-encode their text (item links gain
-- fields), so an unmatched whisper echo confirms the oldest pending message.
local FIFO_KINDS = { whisper = true, bnet = true }

--- Confirm an outgoing message from its echo (an _INFORM event, or your own line in a
-- group channel). Matches the oldest pending message with the same text. A secret echo
-- cannot be compared, so it confirms the oldest pending one; so does a whisper or bnet
-- echo whose text matches nothing. Group channels keep exact matching, because your own
-- lines typed in Blizzard's box echo there too. With nothing matched, the message was
-- typed into Blizzard's chat box, so it is filed as a new outgoing message.
-- @param record table  Outgoing record built by EchoEvents
-- @return boolean matched
function Store.ConfirmSent(record)
    local conv = conversations[record.convKey]
    local pending = conv and OldestPending(conv, record.text, record.secret)
    if conv and not pending and FIFO_KINDS[conv.kind] then
        pending = OldestPending(conv, nil, true)
    end
    if not pending then
        record.status = "sent"
        Store.Add(record)
        return false
    end
    pending.status = "sent"
    Persist(pending)
    Notify(record.convKey, "update")
    return true
end

--- Mark the newest pending message in a conversation as failed.
-- @param convKey string
-- @return table|nil record
function Store.MarkFailed(convKey)
    local conv = conversations[convKey]
    if not conv then return nil end
    for i = #conv.messages, 1, -1 do
        local m = conv.messages[i]
        if m.status == "pending" then
            m.status = "failed"
            Notify(convKey, "update")
            return m
        end
    end
    return nil
end

--- Stop a view's notifications.
-- @param fn function  The function passed to Store.Subscribe
function Store.Unsubscribe(fn)
    for i = #listeners, 1, -1 do
        if listeners[i] == fn then table.remove(listeners, i) end
    end
end

--- Open whisper and Battle.net conversations, in List order. Saved at logout so a
-- reload can bring their tiles back; channels are session-only and never saved.
-- @return table keys
function Store.OpenKeys()
    local keys = {}
    for _, conv in ipairs(Store.List()) do
        if Store.PERSISTED_KINDS[conv.kind] then keys[#keys + 1] = conv.key end
    end
    return keys
end

--- Reopen conversations saved at the end of the last session, seeded from history.
-- Each restored conversation is ranked by its position in keys (1 = top): restored tiles
-- sit below anything with a loud message this session but above channels that spoke
-- after login, in their saved order. A conversation that already exists, including one
-- closed this session, is not reopened; one restored earlier takes its rank from this
-- list, so a retry with the full list (Battle.net friends arrive late) keeps the order.
-- @param keys table|nil  convKeys, top first
-- @return number restored
function Store.Restore(keys)
    local restored = 0
    keys = keys or {}
    for i = 1, #keys do
        local key = keys[i]
        local existing = conversations[key]
        if existing then
            if existing.restoreRank then existing.restoreRank = i end
        elseif Store.PERSISTED_KINDS[Store.KindOf(key)] then
            GetOrCreate(key).restoreRank = i
            restored = restored + 1
        end
    end
    if restored > 0 then Notify(nil, "restored") end
    return restored
end

--- Forget every conversation (module disable, tests). Listeners and history are kept.
function Store.Reset()
    conversations = {}
    overrides = {}
    unrouted = 0
    seq = 0
    Notify(nil, "reset")
end
