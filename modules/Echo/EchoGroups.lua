--[[
    Horizon Suite - Echo - Groups
    Up to four named groups of chats, each shown as one tile in the column. Membership lives
    in settings: echoGroupNames (a blank name leaves the group unused) and echoGroupOf
    (member id -> group index). A group key ("grp:<i>") is a view key only: it never enters
    the Store, History or Send. No frames, so the logic harness tests it.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Groups = {}
Echo.Groups = Groups

Groups.MAX = 4

-- The kinds a group can hold besides channels. Whispers and Battle.net are never grouped.
local GROUPABLE = {
    guild = true, officer = true, party = true, raid = true, instance = true,
    loot = true, progress = true, system = true,
}

local function ValidIndex(index)
    if Echo.IsSecret(index) or type(index) ~= "number" then return nil end
    if index ~= math.floor(index) or index < 1 or index > Groups.MAX then return nil end
    return index
end

--- A group's name, or "" when it is blank, unreadable or out of range.
-- @param index number
-- @return string
function Groups.Name(index)
    if not ValidIndex(index) then return "" end
    local names = Echo.Setting("echoGroupNames")
    if type(names) ~= "table" then return "" end
    local name = names[index]
    if Echo.IsSecret(name) or type(name) ~= "string" then return "" end
    if not name:find("%S") then return "" end
    return name
end

--- The group index a member id maps to, read without touching the settings table.
local function Lookup(map, id)
    local index = map[id]
    if Echo.IsSecret(index) then return nil end
    return index
end

--- The group a conversation belongs to. nil when groups are off, the kind is never grouped,
-- the group's name is blank or unreadable, or the index is out of 1..4. A channel matches
-- its exact member id first, then "ch:*".
-- @param convKey string
-- @return number|nil
function Groups.Of(convKey)
    if Echo.IsSecret(convKey) or type(convKey) ~= "string" then return nil end
    if Echo.Setting("echoGroupsEnabled") ~= true then return nil end
    local kind = Echo.Store.KindOf(convKey)
    if kind ~= "channel" and not GROUPABLE[kind] then return nil end
    local map = Echo.Setting("echoGroupOf")
    if type(map) ~= "table" then return nil end
    local index = Lookup(map, convKey)
    if index == nil and kind == "channel" then index = Lookup(map, "ch:*") end
    index = ValidIndex(index)
    if not index or Groups.Name(index) == "" then return nil end
    return index
end

--- The icon a group's tile shows: the chosen echoGroupIcons entry (a fileID number > 0, or a
-- non-blank icon path string), else Echo.View.GROUP_ICON.
-- @param index number
-- @return number|string
function Groups.Icon(index)
    if not ValidIndex(index) then return Echo.View.GROUP_ICON end
    local icons = Echo.Setting("echoGroupIcons")
    if type(icons) ~= "table" then return Echo.View.GROUP_ICON end
    local icon = icons[index]
    if Echo.IsSecret(icon) then return Echo.View.GROUP_ICON end
    if type(icon) == "number" and icon > 0 then return icon end
    if type(icon) == "string" and icon:find("%S") then return icon end
    return Echo.View.GROUP_ICON
end

--- The open conversations in a group, in Store order.
-- @param index number
-- @param list table|nil  Store.List(); defaults to it
-- @return table { conv, ... }
function Groups.Members(index, list)
    local out = {}
    if not ValidIndex(index) then return out end
    list = list or Echo.Store.List()
    for _, conv in ipairs(list) do
        if conv.open and Groups.Of(conv.key) == index then out[#out + 1] = conv end
    end
    return out
end

--- @param index number
-- @return string "grp:<index>"
function Groups.Key(index)
    return "grp:" .. tostring(index)
end

--- The group index of a group key, else nil.
-- @param key string
-- @return number|nil
function Groups.IndexOf(key)
    if Echo.IsSecret(key) or type(key) ~= "string" then return nil end
    local digits = key:match("^grp:(%d+)$")
    return ValidIndex(tonumber(digits))
end

--- The member a group opens on when nothing was chosen: the one with the most recent loud
-- message, else the first in Store order. nil when the group has no open members.
-- @param index number
-- @param list table|nil  Store.List(); defaults to it
-- @return table|nil conv
function Groups.Newest(index, list)
    local members = Groups.Members(index, list)
    local best
    for _, conv in ipairs(members) do
        if (conv.lastLoud or 0) > 0 and (not best or conv.lastLoud > best.lastLoud) then best = conv end
    end
    return best or members[1]
end
