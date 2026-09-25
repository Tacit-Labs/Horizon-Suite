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
    for _, names in ipairs({ LOCALIZED_CLASS_NAMES_MALE, LOCALIZED_CLASS_NAMES_FEMALE }) do
        if type(names) == "table" then
            for file, label in pairs(names) do
                if not IsSecret(label) and label == localized then return file end
            end
        end
    end
    return nil
end

--- @param targetName string  "Name-Realm"
-- @return string|nil class, string|nil source
local function GroupClass(targetName)
    if type(UnitName) ~= "function" or type(UnitClass) ~= "function" then return nil, nil end
    local inRaid = false
    if type(IsInRaid) == "function" then
        local ok, result = pcall(IsInRaid)
        inRaid = ok and result == true
    end
    local prefix, count = "party", 4
    if inRaid then prefix, count = "raid", 40 end
    for i = 1, count do
        local unit = prefix .. i
        local ok, name, realm = pcall(UnitName, unit)
        if ok and Readable(name) then
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
        if okInfo and type(info) == "table" and not IsSecret(info) then
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
    if not ok or type(info) ~= "table" or IsSecret(info) then return nil, nil end
    local gameInfo = info.gameAccountInfo
    if type(gameInfo) ~= "table" or IsSecret(gameInfo) then return nil, nil end
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

local frame

--- A roster changed: give every classless open conversation another chance next time
-- it's asked, and repaint the views that might show a class icon.
local function OnRosterEvent()
    for _, conv in ipairs(Echo.Store.List()) do
        if conv.kind == "whisper" and not conv.resolvedClass then
            conv.classMissAt = nil
        end
    end
    Echo.Redraw.Mark("tiles")
    Echo.Redraw.Mark("stack")
    Echo.Redraw.Mark("card")
end

function Class.Enable()
    if not frame then
        frame = CreateFrame("Frame")
        frame:SetScript("OnEvent", OnRosterEvent)
    end
    for _, event in ipairs(ROSTER_EVENTS) do pcall(frame.RegisterEvent, frame, event) end
    if addon.Platform and addon.Platform.Has("bnetWhispers") then
        pcall(frame.RegisterEvent, frame, BNET_EVENT)
    end
end

function Class.Disable()
    if frame then frame:UnregisterAllEvents() end
end

-- Test and debug handle.
function Class._frame()
    return frame
end
