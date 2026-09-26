--[[
    Horizon Suite - Echo - History
    Whisper history in HorizonDB.echoHistory: per character for whispers, account-wide
    for Battle.net, per guild for guild and officer chat. A bnetAccountID only lasts one
    session, so Battle.net history is keyed by the friend's BattleTag ("bt:Name#1234");
    when the BattleTag cannot be read (no API, no friend, secret) nothing is written or
    loaded for that conversation. Guild chat is keyed by "Guild Name-Realm"; with no
    readable guild, nothing is written or loaded for guild/officer either.
    Never writes secret, pending, failed or demo messages. Channels are never persisted.
    Old conversations are dropped by History.Prune, on a timer the player sets
    (echoHistoryDays); a pinned conversation is always kept.
    Blizzard: C_BattleNet.GetAccountInfoByID, GetGuildInfo, GetNormalizedRealmName.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local History = {}
Echo.History = History

History.CAP = 100
History.GUILD_CAP = 200
History.DEFAULT_MAX_AGE = 30  -- days; matches echoHistoryDays' default. 0 means Forever.
History.PINS_PER_CHAT = 5
History.PINS_TOTAL = 50

local root
local characterKey = function() return nil end
local enabledCheck = function() return true end
local maxAgeDays = History.DEFAULT_MAX_AGE

--- Attach to the SavedVariables root.
-- @param db table  HorizonDB
-- @param keyFn function  Returns "Name-Realm", or nil while the realm is unknown
function History.Bind(db, keyFn)
    if type(db) ~= "table" then return end
    db.echoHistory = db.echoHistory or {}
    root = db.echoHistory
    root.chars = root.chars or {}
    root.bnet = root.bnet or {}
    root.guilds = root.guilds or {}
    root.pins = root.pins or {}
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

--- Options (plan 10) supplies the "Keep history for" setting through this.
-- @param days number  0 means Forever; an unreadable value is ignored
function History.SetMaxAge(days)
    if type(days) == "number" and days >= 0 then maxAgeDays = days end
end

--- The player's guild, "Guild Name-Realm". GetGuildInfo's realm return is nil for a guild on
-- your own realm, so that case falls back to GetNormalizedRealmName. nil when either value
-- can't be read, is secret, or the account has no guild.
-- @return string|nil
function History.GuildKey()
    local api = GetGuildInfo
    if type(api) ~= "function" then return nil end
    local ok, guildName, _, _, guildRealm = pcall(api, "player")
    if not ok then return nil end
    if Echo.IsSecret(guildName) then return nil end
    if type(guildName) ~= "string" or guildName == "" then return nil end
    if Echo.IsSecret(guildRealm) then return nil end
    if guildRealm == nil or guildRealm == "" then
        local realmApi = GetNormalizedRealmName
        if type(realmApi) == "function" then
            local okRealm, realm = pcall(realmApi)
            guildRealm = okRealm and realm or nil
        else
            guildRealm = nil
        end
        if Echo.IsSecret(guildRealm) then return nil end
    end
    if type(guildRealm) ~= "string" or guildRealm == "" then return nil end
    return guildName .. "-" .. guildRealm
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
        elseif (kind == "guild" or kind == "officer") and Echo.Store.IsPersisted(kind) then
            saved[#saved + 1] = key
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
        elseif key == "guild" or key == "officer" then
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

-- The key a conversation's pins are saved under: PrefKey (so Battle.net pins are keyed by
-- BattleTag), except guild and officer chat, whose pins belong to one guild:
-- "g:<Guild Name-Realm>:guild". Nil while the guild is unknown.
local function PinKey(convKey)
    local kind = Echo.Store.KindOf(convKey)
    if kind == "guild" or kind == "officer" then
        local guildKey = History.GuildKey()
        return guildKey and ("g:" .. guildKey .. ":" .. kind) or nil
    end
    return PrefKey(convKey)
end

-- Where a character's pins are saved: root.pins[charKey][PinKey(convKey)] = list, the same
-- charKey the conversation prefs use.
local function PinsBucket(create)
    if not root then return nil end
    local charKey = characterKey()
    if not charKey then return nil end
    if type(root.pins) ~= "table" then
        if not create then return nil end
        root.pins = {}
    end
    local bucket = root.pins[charKey]
    if type(bucket) ~= "table" then
        if not create then return nil end
        bucket = {}
        root.pins[charKey] = bucket
    end
    return bucket
end

--- This character's pinned messages in a conversation, oldest first, as Store records.
-- @param convKey string
-- @return table records  a copy; empty when there are no pins
function History.Pins(convKey)
    local out = {}
    local key = PinKey(convKey)
    local bucket = key and PinsBucket(false)
    local list = bucket and bucket[key]
    if type(list) ~= "table" then return out end
    for i, entry in ipairs(list) do
        out[i] = {
            convKey  = convKey,
            text     = entry.text,
            time     = entry.t,
            outgoing = entry.out == true,
            sender   = entry.s,
        }
    end
    return out
end

-- The sender a pin stores: readable and not a Battle.net |K string, else nil.
local function PinSender(convKey, record)
    local sender = record.sender
    -- A Battle.net sender is a protected |K display string: never stored, whatever the kind.
    if Echo.Store.KindOf(convKey) ~= "bnet" and not Echo.IsSecret(sender) and type(sender) == "string"
       and sender ~= "" and sender:sub(1, 2) ~= "|K" then
        return sender
    end
    return nil
end

-- Whether a record can be pinned, shared by AddPin and PinBlockReason so the menu's
-- disabled reason always matches what a click would do.
-- @return string|nil reason  nil when it can be pinned (or already is)
-- @return string|nil key, table|nil bucket, string|nil sender, table|nil list, boolean|nil already
local function CheckPin(convKey, record, create)
    if type(record) ~= "table" then return "unsaved" end
    if record.secret or Echo.IsSecret(record.text) or type(record.text) ~= "string" then
        return "secret"
    end
    -- A |K string is a Battle.net friend's protected name: it may be shown, never saved.
    if record.text:find("|K", 1, true) then return "secret" end
    -- A demo line, or one of yours not yet sent (or never sent), isn't a real message.
    if record.demo or record.status == "pending" or record.status == "failed" then
        return "unsaved"
    end
    local key = PinKey(convKey)
    if not key or not root or not characterKey() then return "unsaved" end
    local bucket = PinsBucket(create)
    if create and not bucket then return "unsaved" end

    local sender = PinSender(convKey, record)
    local list = bucket and bucket[key]
    if type(list) ~= "table" then list = nil end
    if list then
        for _, entry in ipairs(list) do
            if entry.t == record.time and entry.text == record.text and entry.s == sender then
                return nil, key, bucket, sender, list, true
            end
        end
    end

    if list and #list >= History.PINS_PER_CHAT then return "chat" end

    local total = 0
    if bucket then
        for _, l in pairs(bucket) do
            if type(l) == "table" then total = total + #l end
        end
    end
    if total >= History.PINS_TOTAL then return "total" end
    return nil, key, bucket, sender, list, false
end

--- Pin a message. Pins are the player's explicit choice, so they are saved whatever the
-- history switches say, and Prune never removes them.
-- @param convKey string
-- @param record table  a Store record: text, time, outgoing, sender, secret
-- @return boolean ok
-- @return string|nil reason  "secret" | "chat" | "total" | "unsaved"; nil when ok
function History.AddPin(convKey, record)
    local reason, key, bucket, sender, list, already = CheckPin(convKey, record, true)
    if reason then return false, reason end
    if already then return true end
    if not list then
        list = {}
        bucket[key] = list
    end
    list[#list + 1] = { t = record.time, text = record.text, s = sender, out = record.outgoing and true or nil }
    return true
end

--- Why a record can't be pinned, without writing anything: the reason AddPin would
-- return, or nil when pinning would succeed (including a record already pinned).
-- @param convKey string
-- @param record table
-- @return string|nil reason  "secret" | "chat" | "total" | "unsaved"
function History.PinBlockReason(convKey, record)
    return (CheckPin(convKey, record, false))
end

--- Remove one of this character's pins.
-- @param convKey string
-- @param index number  1-based, into History.Pins(convKey)'s order
-- @return boolean removed
function History.RemovePin(convKey, index)
    local key = PinKey(convKey)
    local bucket = key and PinsBucket(false)
    local list = bucket and bucket[key]
    if type(list) ~= "table" or type(index) ~= "number" or not list[index] then return false end
    table.remove(list, index)
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
    elseif kind == "guild" or kind == "officer" then
        local guildKey = History.GuildKey()
        if not guildKey then return nil end
        root.guilds = root.guilds or {}
        parent = root.guilds[guildKey]
        if not parent and create then
            parent = {}
            root.guilds[guildKey] = parent
        end
        listKey = kind
    end
    if not parent then return nil end
    local list = parent[listKey]
    if not list and create then
        list = {}
        parent[listKey] = list
    end
    return list
end

--- Persist one message. Rejections are silent: the message still shows this session.
-- @param convKey string
-- @param record table
-- @return boolean written
function History.Append(convKey, record)
    if not root or not enabledCheck() then return false end
    if record.secret or record.demo then return false end
    if record.status == "pending" or record.status == "failed" then return false end
    if Echo.IsSecret(record.text) or type(record.text) ~= "string" then return false end
    -- A |K string is a Battle.net friend's protected name: it may be shown, never saved.
    if record.text:find("|K", 1, true) then return false end
    local kind = Echo.Store.KindOf(convKey)
    local list = Bucket(convKey, true)
    if not list then return false end
    local entry = { t = record.time, out = record.outgoing and true or nil, text = record.text }
    -- A Battle.net sender is a protected |K display string: safe to show, never stored.
    if kind ~= "bnet" and not Echo.IsSecret(record.sender) and type(record.sender) == "string" and record.sender ~= "" then
        entry.s = record.sender
    end
    if not Echo.IsSecret(record.class) and type(record.class) == "string" and record.class ~= "" then
        entry.c = record.class
    end
    list[#list + 1] = entry
    local cap = (kind == "guild" or kind == "officer") and History.GUILD_CAP or History.CAP
    while #list > cap do table.remove(list, 1) end
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
            sender      = entry.s,
            class       = entry.c,
            fromHistory = true,
            seq         = 0,
        }
    end
    return out
end

--- Wipe all saved whispers, for every character, Battle.net, guild and officer, and the
-- saved session.
function History.Clear()
    local target = root
    if not target then
        local db = _G[addon.DATABASE]
        target = type(db) == "table" and type(db.echoHistory) == "table" and db.echoHistory or nil
    end
    if not target then return end
    target.chars = {}
    target.bnet = {}
    target.guilds = {}
    target.pins = {}
    target.session = {}
end

-- True when some character has pinned this conversation key. Pins (root.prefs) are keyed
-- the same way conversations are (PrefKey), so a whisper, Battle.net or guild/officer list
-- checks the matching entry across every character's saved prefs.
local function AnyCharPinned(key)
    if type(root.prefs) ~= "table" then return false end
    for _, bucket in pairs(root.prefs) do
        local pref = type(bucket) == "table" and bucket[key]
        if type(pref) == "table" and pref.pinned == true then return true end
    end
    return false
end

-- now - the t of a list's newest (last-appended) entry; huge (always stale) with no
-- readable t, including an empty list.
local function ListAge(list, now)
    local newest = list[#list]
    local t = type(newest) == "table" and newest.t
    if type(t) ~= "number" then return math.huge end
    return now - t
end

--- Age-based cleanup: drop a whisper, Battle.net or guild/officer list whose newest entry is
-- older than echoHistoryDays (History.SetMaxAge). A whisper or Battle.net list any character
-- has pinned is always kept. A guild/officer list is exempt the same way only for the
-- current guild (History.GuildKey()); a stale list left behind under a guild the player has
-- since left is pruned by age alone, even though "guild"/"officer" is pinned for the guild
-- the player is in now. Forever (days == 0) removes nothing. Runs once when Echo enables.
-- @param now number
-- @return number removed
function History.Prune(now)
    if not root then return 0 end
    if not maxAgeDays or maxAgeDays <= 0 then return 0 end
    local cutoff = maxAgeDays * 86400
    local removed = 0

    local function pruneList(parent, key, checkPinned)
        local list = parent[key]
        if type(list) ~= "table" then return end
        if checkPinned and AnyCharPinned(key) then return end
        if ListAge(list, now) > cutoff then
            parent[key] = nil
            removed = removed + 1
        end
    end

    -- SavedVariables can hold anything: skip whatever isn't the shape Echo writes.
    if type(root.chars) == "table" then
        for charKey, bucket in pairs(root.chars) do
            if type(bucket) == "table" then
                for convKey in pairs(bucket) do pruneList(bucket, convKey, true) end
                if next(bucket) == nil then root.chars[charKey] = nil end
            end
        end
    end

    if type(root.bnet) == "table" then
        for key in pairs(root.bnet) do pruneList(root.bnet, key, true) end
    end

    -- At a cold login the guild isn't known yet: with no current guild to exempt, a pinned
    -- guild's own list could be dropped, so leave every guild list alone this time.
    local currentGuildKey = History.GuildKey()
    if type(root.guilds) == "table" and currentGuildKey ~= nil then
        for guildKey, entry in pairs(root.guilds) do
            if type(entry) == "table" then
                local isCurrent = guildKey == currentGuildKey
                pruneList(entry, "guild", isCurrent)
                pruneList(entry, "officer", isCurrent)
                if next(entry) == nil then root.guilds[guildKey] = nil end
            end
        end
    end

    return removed
end
