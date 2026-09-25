--[[
    Horizon Suite - Echo - History
    Whisper history in HorizonDB.echoHistory: per character for whispers, account-wide
    for Battle.net. A bnetAccountID only lasts one session, so Battle.net history is
    keyed by the friend's BattleTag ("bt:Name#1234"); when the BattleTag cannot be read
    (no API, no friend, secret) nothing is written or loaded for that conversation.
    Never writes secret, pending, failed or demo messages. Channels are never persisted.
    Blizzard: C_BattleNet.GetAccountInfoByID.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local History = {}
Echo.History = History

History.CAP = 100

local root
local characterKey = function() return nil end
local enabledCheck = function() return true end

--- Attach to the SavedVariables root.
-- @param db table  HorizonDB
-- @param keyFn function  Returns "Name-Realm", or nil while the realm is unknown
function History.Bind(db, keyFn)
    if type(db) ~= "table" then return end
    db.echoHistory = db.echoHistory or {}
    root = db.echoHistory
    root.chars = root.chars or {}
    root.bnet = root.bnet or {}
    if type(keyFn) == "function" then characterKey = keyFn end
end

function History.Unbind()
    root = nil
end

--- Options (plan 3) supplies the "Save whisper history" setting through this.
-- @param fn function  Returns true when history may be written
function History.SetEnabledCheck(fn)
    if type(fn) == "function" then enabledCheck = fn end
end

--- The friend's BattleTag for a "bn:<accountID>" conversation.
-- @param convKey string
-- @return string|nil battleTag  nil when it cannot be read or is secret
function History.BattleTagFor(convKey)
    if Echo.Store.KindOf(convKey) ~= "bnet" then return nil end
    local id = tonumber(convKey:sub(4))
    local api = C_BattleNet and C_BattleNet.GetAccountInfoByID
    if not id or type(api) ~= "function" then return nil end
    local ok, info = pcall(api, id)
    if not ok or type(info) ~= "table" then return nil end
    local battleTag = info.battleTag
    if Echo.IsSecret(battleTag) or type(battleTag) ~= "string" or battleTag == "" then return nil end
    return battleTag
end

History.SESSION_MAX_AGE = 1800  -- a reload or a quick relog, not yesterday's login

--- The current session-only account ID for a friend's BattleTag, from the friends list.
-- @param battleTag string
-- @return number|nil
function History.AccountIDForTag(battleTag)
    local api = C_BattleNet and C_BattleNet.GetFriendAccountInfo
    if type(BNGetNumFriends) ~= "function" or type(api) ~= "function" then return nil end
    local okCount, count = pcall(BNGetNumFriends)
    if not okCount or Echo.IsSecret(count) or type(count) ~= "number" then return nil end
    for i = 1, count do
        local ok, info = pcall(api, i)
        if ok and type(info) == "table" then
            local tag = info.battleTag
            if not Echo.IsSecret(tag) and tag == battleTag then
                local id = info.bnetAccountID
                if not Echo.IsSecret(id) and type(id) == "number" then return id end
            end
        end
    end
    return nil
end

--- Remember which conversations were open, for this character (PLAYER_LOGOUT, which a
-- reload also fires). Battle.net conversations are saved by BattleTag.
-- @param keys table  Store.OpenKeys()
-- @param now number
-- @return boolean saved
function History.SaveSession(keys, now)
    if not root or not enabledCheck() then return false end
    local charKey = characterKey()
    if not charKey then return false end
    local saved = {}
    for _, key in ipairs(keys or {}) do
        local kind = Echo.Store.KindOf(key)
        if kind == "whisper" then
            saved[#saved + 1] = key
        elseif kind == "bnet" then
            local tag = History.BattleTagFor(key)
            if tag then saved[#saved + 1] = "bt:" .. tag end
        end
    end
    root.session = root.session or {}
    root.session[charKey] = { t = now, keys = saved }
    return true
end

--- The conversations to reopen, if this character's session was saved recently.
-- @param now number
-- @param maxAge number|nil  seconds; defaults to History.SESSION_MAX_AGE
-- @return table keys  top first; Battle.net friends no longer listed are dropped
function History.SessionKeys(now, maxAge)
    local out = {}
    if not root or not enabledCheck() or type(root.session) ~= "table" then return out end
    local charKey = characterKey()
    local session = charKey and root.session[charKey]
    if type(session) ~= "table" or type(session.t) ~= "number" then return out end
    if now - session.t > (maxAge or History.SESSION_MAX_AGE) then return out end
    if type(session.keys) ~= "table" then return out end
    for _, key in ipairs(session.keys) do
        if type(key) == "string" and key:sub(1, 3) == "bt:" then
            local id = History.AccountIDForTag(key:sub(4))
            if id then out[#out + 1] = "bn:" .. id end
        elseif Echo.Store.KindOf(key) == "whisper" then
            out[#out + 1] = key
        end
    end
    return out
end

-- Where a conversation's pin and tier are saved: Battle.net by BattleTag (the account ID
-- only lasts a session), everything else by its conversation key.
local function PrefKey(convKey)
    if Echo.Store.KindOf(convKey) == "bnet" then
        local tag = History.BattleTagFor(convKey)
        return tag and ("bt:" .. tag) or nil
    end
    return convKey
end

local function PrefBucket(create)
    if not root then return nil end
    local charKey = characterKey()
    if not charKey then return nil end
    if type(root.prefs) ~= "table" then
        if not create then return nil end
        root.prefs = {}
    end
    local bucket = root.prefs[charKey]
    if type(bucket) ~= "table" then
        if not create then return nil end
        bucket = {}
        root.prefs[charKey] = bucket
    end
    return bucket
end

--- A conversation's saved pin and tier on this character. Prefs are the player's
-- settings, not chat content, so the history switch doesn't affect them.
-- @param convKey string
-- @return table|nil { tier = string|nil, pinned = boolean|nil }
function History.LoadPref(convKey)
    local key = PrefKey(convKey)
    local bucket = key and PrefBucket(false)
    local pref = bucket and bucket[key]
    if type(pref) ~= "table" then return nil end
    return pref
end

--- Save a conversation's pin and tier on this character; nothing to save removes it.
-- @param convKey string
-- @param tier string|nil  the override, nil for the kind's default
-- @param pinned boolean|nil
-- @return boolean saved
function History.SavePref(convKey, tier, pinned)
    local key = PrefKey(convKey)
    if not key then return false end
    local bucket = PrefBucket(true)
    if not bucket then return false end
    if tier == nil and not pinned then
        bucket[key] = nil
    else
        bucket[key] = { tier = tier, pinned = pinned and true or nil }
    end
    return true
end

local function Bucket(convKey, create)
    if not root then return nil end
    local kind = Echo.Store.KindOf(convKey)
    local parent, listKey = nil, convKey
    if kind == "bnet" then
        local battleTag = History.BattleTagFor(convKey)
        if not battleTag then return nil end
        parent = root.bnet
        listKey = "bt:" .. battleTag
    elseif kind == "whisper" then
        local charKey = characterKey()
        if not charKey then return nil end
        parent = root.chars[charKey]
        if not parent and create then
            parent = {}
            root.chars[charKey] = parent
        end
    end
    if not parent then return nil end
    local list = parent[listKey]
    if not list and create then
        list = {}
        parent[listKey] = list
    end
    return list
end

--- Persist one whisper. Rejections are silent: the message still shows this session.
-- @param convKey string
-- @param record table
-- @return boolean written
function History.Append(convKey, record)
    if not root or not enabledCheck() then return false end
    if record.secret or record.demo then return false end
    if record.status == "pending" or record.status == "failed" then return false end
    if Echo.IsSecret(record.text) or type(record.text) ~= "string" then return false end
    local list = Bucket(convKey, true)
    if not list then return false end
    list[#list + 1] = { t = record.time, out = record.outgoing and true or nil, text = record.text }
    while #list > History.CAP do table.remove(list, 1) end
    return true
end

--- Saved messages for a conversation, oldest first, as Store records.
-- @param convKey string
-- @return table records  empty when there is no history
function History.Load(convKey)
    local out = {}
    local list = Bucket(convKey, false)
    if not list then return out end
    for i, entry in ipairs(list) do
        out[i] = {
            convKey     = convKey,
            text        = entry.text,
            time        = entry.t,
            outgoing    = entry.out == true,
            status      = entry.out and "sent" or nil,
            fromHistory = true,
            seq         = 0,
        }
    end
    return out
end

--- Wipe all saved whispers, for every character and Battle.net, and the saved session.
function History.Clear()
    if not root then return end
    root.chars = {}
    root.bnet = {}
    root.session = {}
end
