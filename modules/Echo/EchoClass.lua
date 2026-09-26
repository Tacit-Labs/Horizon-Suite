--[[
    Horizon Suite - Echo - Class
    Finds a whisperer's class when no message ever carried one: restored history,
    Battle.net friends and some whispers arrive without a GUID to ask Blizzard directly.
    A whisper's class is looked up in group, guild then friends (first match wins),
    cached on the conversation, and re-tried on the next roster event. A Battle.net
    friend is resolved live every time, never cached, since they can switch characters.
    Blizzard: IsInRaid, UnitName, UnitClass, IsInGuild, GetNumGuildMembers,
    GetGuildRosterInfo, C_FriendList, C_BattleNet, LOCALIZED_CLASS_NAMES_MALE/FEMALE,
    GROUP_ROSTER_UPDATE, GUILD_ROSTER_UPDATE, FRIENDLIST_UPDATE, BN_FRIEND_INFO_CHANGED.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo
local IsSecret = Echo.IsSecret

local Class = {}
Echo.Class = Class

-- A miss (nobody in group/guild/friends matched) isn't re-scanned for this long, so a
-- busy guild roster isn't walked on every repaint.
Class.MISS_SECONDS = 5

--- A readable, non-empty string.
-- @param v any
-- @return boolean
local function Readable(v)
    return not IsSecret(v) and type(v) == "string" and v ~= ""
end

--- "Name" or "Name-Realm" -> "Name-Realm", using the player's own realm when name has
-- none and realm wasn't supplied separately.
-- @param name string
-- @param realm string|nil
-- @return string|nil
local function FullName(name, realm)
    if not Readable(name) then return nil end
    if Readable(realm) then return name .. "-" .. realm end
    if IsSecret(realm) then return nil end
    return Echo.Events and Echo.Events.NormaliseName(name)
end

--- Map a localized class name back to its class file, trying the male then the female
-- table (either may be absent on the test harness or an unusual client).
-- @param localized any
-- @return string|nil
local function ClassFileFromLocalized(localized)
    if not Readable(localized) then return nil end
    local tables = {}
    if type(LOCALIZED_CLASS_NAMES_MALE) == "table" then tables[#tables + 1] = LOCALIZED_CLASS_NAMES_MALE end
    if type(LOCALIZED_CLASS_NAMES_FEMALE) == "table" then tables[#tables + 1] = LOCALIZED_CLASS_NAMES_FEMALE end
    for _, names in ipairs(tables) do
        for file, label in pairs(names) do
            if not IsSecret(label) and label == localized then return file end
        end
    end
    return nil
end

--- A unit's name and realm, preferring `UnitFullName` (splits the two cleanly on every
-- client that has it) and falling back to `UnitName` (whose realm return is nil or empty
-- for your own realm) when it doesn't.
-- @param unit string
-- @return string|nil name, string|nil realm
local function UnitNameAndRealm(unit)
    if type(UnitFullName) == "function" then
        local ok, name, realm = pcall(UnitFullName, unit)
        if ok and Readable(name) then return name, realm end
    end
    if type(UnitName) == "function" then
        local ok, name, realm = pcall(UnitName, unit)
        if ok and Readable(name) then return name, realm end
    end
    return nil, nil
end

--- @param targetName string  "Name-Realm"
-- @return string|nil class, string|nil source
local function GroupClass(targetName)
    if type(UnitClass) ~= "function" then return nil, nil end
    if type(UnitFullName) ~= "function" and type(UnitName) ~= "function" then return nil, nil end
    local inRaid = false
    if type(IsInRaid) == "function" then
        local ok, result = pcall(IsInRaid)
        inRaid = ok and result == true
    end
    local prefix, count = "party", 4
    if inRaid then prefix, count = "raid", 40 end
    for i = 1, count do
        local unit = prefix .. i
        local name, realm = UnitNameAndRealm(unit)
        if Readable(name) then
            -- A readable realm ("Aerie Peak") loses its spaces before joining, matching
            -- the conversation key ("Kaelis-AeriePeak").
            if Readable(realm) then realm = realm:gsub(" ", "") end
            local full = FullName(name, realm)
            if full and full == targetName then
                local okClass, classFile = pcall(function() return select(2, UnitClass(unit)) end)
                if okClass and Readable(classFile) then return classFile, "group" end
            end
        end
    end
    return nil, nil
end

--- @param targetName string  "Name-Realm"
-- @return string|nil class, string|nil source
local function GuildClass(targetName)
    if type(IsInGuild) ~= "function" or type(GetNumGuildMembers) ~= "function"
        or type(GetGuildRosterInfo) ~= "function" then
        return nil, nil
    end
    local okIn, inGuild = pcall(IsInGuild)
    if not okIn or inGuild ~= true then return nil, nil end
    local okNum, num = pcall(GetNumGuildMembers)
    if not okNum or IsSecret(num) or type(num) ~= "number" then return nil, nil end
    for i = 1, num do
        local okRoster, fullName, _, _, _, _, _, _, _, _, _, classFile = pcall(GetGuildRosterInfo, i)
        if okRoster and Readable(fullName) and fullName == targetName and Readable(classFile) then
            return classFile, "guild"
        end
    end
    return nil, nil
end

--- @param targetName string  "Name-Realm"
-- @return string|nil class, string|nil source
local function FriendsClass(targetName)
    local api = C_FriendList
    if type(api) ~= "table" or type(api.GetNumFriends) ~= "function"
        or type(api.GetFriendInfoByIndex) ~= "function" then
        return nil, nil
    end
    local okNum, num = pcall(api.GetNumFriends)
    if not okNum or IsSecret(num) or type(num) ~= "number" then return nil, nil end
    for i = 1, num do
        local okInfo, info = pcall(api.GetFriendInfoByIndex, i)
        if okInfo and not IsSecret(info) and type(info) == "table" then
            local full = FullName(info.name, nil)
            if full and full == targetName then
                local classFile = ClassFileFromLocalized(info.className)
                if classFile then return classFile, "friends" end
            end
        end
    end
    return nil, nil
end

--- A whisper's class: message first (freshest truth), then the cache, then a live
-- group/guild/friends lookup. A miss is remembered so a busy roster isn't re-scanned.
-- @param conv table
-- @return string|nil class, string|nil source
local function ResolveWhisper(conv)
    if conv.resolvedClass then return conv.resolvedClass, conv.classSource end
    local missAt = conv.classMissAt
    if missAt and (Echo.Store.Now() - missAt) < Class.MISS_SECONDS then return nil, nil end
    local name = conv.key
    name = Readable(name) and name:sub(3) or nil
    if not Readable(name) then
        conv.classMissAt = Echo.Store.Now()
        return nil, nil
    end
    local class, source = GroupClass(name)
    if not class then class, source = GuildClass(name) end
    if not class then class, source = FriendsClass(name) end
    if class then
        conv.resolvedClass, conv.classSource = class, source
        conv.classMissAt = nil
        return class, source
    end
    conv.classMissAt = Echo.Store.Now()
    return nil, nil
end

--- A Battle.net friend's class: never cached, since they can switch characters between
-- one lookup and the next.
-- @param conv table
-- @return string|nil class, string|nil source
local function ResolveBnet(conv)
    local id = conv.key
    id = Readable(id) and id:sub(4) or nil
    if not Readable(id) then return nil, nil end
    local api = C_BattleNet
    if type(api) ~= "table" or type(api.GetAccountInfoByID) ~= "function" then return nil, nil end
    local ok, info = pcall(api.GetAccountInfoByID, tonumber(id) or id)
    if not ok or IsSecret(info) or type(info) ~= "table" then return nil, nil end
    local gameInfo = info.gameAccountInfo
    if IsSecret(gameInfo) or type(gameInfo) ~= "table" then return nil, nil end
    local client = gameInfo.clientProgram
    local wowClient = BNET_CLIENT_WOW or "WoW"
    if not Readable(client) or client ~= wowClient then return nil, nil end
    local classFile = ClassFileFromLocalized(gameInfo.className)
    if classFile then return classFile, "bnet" end
    return nil, nil
end

--- A conversation's class without a GUID to ask Blizzard directly.
-- @param conv table
-- @return string|nil class, string|nil source  "message" | "group" | "guild" | "friends" | "bnet"
function Class.Resolve(conv)
    if type(conv) ~= "table" then return nil, nil end
    local view = Echo.View
    local msgClass = view and view.LastClass(conv)
    if Readable(msgClass) then return msgClass, "message" end
    if conv.kind == "whisper" then return ResolveWhisper(conv) end
    if conv.kind == "bnet" then return ResolveBnet(conv) end
    return nil, nil
end

local ROSTER_EVENTS = { "GROUP_ROSTER_UPDATE", "GUILD_ROSTER_UPDATE", "FRIENDLIST_UPDATE" }
local BNET_EVENT = "BN_FRIEND_INFO_CHANGED"
local GUILD_TABARD_EVENT = "PLAYER_GUILD_UPDATE"

local frame

--- Open whisper conversations with no class yet: the ones a group/guild/friends roster
-- event could resolve.
-- @return table conv[]
local function ClasslessWhispers()
    local list = {}
    for _, conv in ipairs(Echo.Store.List()) do
        if conv.kind == "whisper" and not conv.resolvedClass then
            list[#list + 1] = conv
        end
    end
    return list
end

--- Every open Battle.net conversation: a bnet class is never cached, so any of them could
-- read differently once a friend's info changes.
-- @return table conv[]
local function BnetConversations()
    local list = {}
    for _, conv in ipairs(Echo.Store.List()) do
        if conv.kind == "bnet" then list[#list + 1] = conv end
    end
    return list
end

--- A roster or friends event that might resolve one of `qualifying`'s conversations: does
-- nothing when none qualify (there's nothing it could change). Otherwise clears only misses
-- older than the throttle (a fresh miss stays throttled), then marks the views. The shown
-- card is only fully repainted when it's showing one of the affected conversations;
-- otherwise just its row.
-- @param qualifying table conv[]
local function HandleRosterEvent(qualifying)
    if #qualifying == 0 then return end
    local now = Echo.Store.Now()
    for _, conv in ipairs(qualifying) do
        local missAt = conv.classMissAt
        if missAt and (now - missAt) >= Class.MISS_SECONDS then
            conv.classMissAt = nil
        end
    end
    Echo.Redraw.Mark("tiles")
    Echo.Redraw.Mark("stack")
    local shown = Echo.Card and Echo.Card.ShownKey and Echo.Card.ShownKey()
    local affected = false
    if shown then
        for _, conv in ipairs(qualifying) do
            if conv.key == shown then
                affected = true
                break
            end
        end
    end
    if affected then
        Echo.Redraw.Mark("card")
    else
        Echo.Redraw.Mark("cardRow")
    end
end

--- @param _ Frame  the event frame (unused)
-- @param event string
local function OnRosterEvent(_, event)
    if event == GUILD_TABARD_EVENT or event == "GUILD_ROSTER_UPDATE" then
        if Echo.View and Echo.View.ClearGuildTabardCache then Echo.View.ClearGuildTabardCache() end
    end
    if event == BNET_EVENT then
        HandleRosterEvent(BnetConversations())
    else
        HandleRosterEvent(ClasslessWhispers())
    end
end

--- Ask Blizzard to refresh the guild roster once, so `GuildClass`'s lookup has current data
-- to work from instead of whatever it last cached. Guarded: an older client, or one out of
-- a guild, just skips it.
local function RequestGuildRoster()
    if type(IsInGuild) ~= "function" then return end
    local ok, inGuild = pcall(IsInGuild)
    if not ok or IsSecret(inGuild) or inGuild ~= true then return end
    if type(C_GuildInfo) == "table" and type(C_GuildInfo.GuildRoster) == "function" then
        pcall(C_GuildInfo.GuildRoster)
    elseif type(GuildRoster) == "function" then
        pcall(GuildRoster)
    end
end

function Class.Enable()
    if not frame then
        frame = CreateFrame("Frame")
        frame:SetScript("OnEvent", OnRosterEvent)
    end
    for _, event in ipairs(ROSTER_EVENTS) do pcall(frame.RegisterEvent, frame, event) end
    pcall(frame.RegisterEvent, frame, GUILD_TABARD_EVENT)
    if addon.Platform and addon.Platform.Has("bnetWhispers") then
        pcall(frame.RegisterEvent, frame, BNET_EVENT)
    end
    RequestGuildRoster()
end

function Class.Disable()
    if frame then frame:UnregisterAllEvents() end
end

-- Test and debug handle.
function Class._frame()
    return frame
end
