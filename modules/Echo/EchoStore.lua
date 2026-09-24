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
    for _, fn in ipairs(listeners) do
        local ok, err = pcall(fn, convKey, change)
        if not ok then
            local handler = geterrorhandler and geterrorhandler()
            if handler then handler(err) end
        end
    end
end

--- Register a view.
-- @param fn function(convKey, change)  change: "toast" | "count" | "quiet" | "silent" |
--   "update" | "closed" | "unrouted" | "reset"; convKey is nil for "unrouted" and "reset"
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

--- Forget every conversation (module disable, tests). Listeners and history are kept.
function Store.Reset()
    conversations = {}
    overrides = {}
    unrouted = 0
    seq = 0
    Notify(nil, "reset")
end
