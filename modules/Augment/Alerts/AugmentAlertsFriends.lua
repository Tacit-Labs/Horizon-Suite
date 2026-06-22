--[[
    Horizon Suite - Augment / Alerts - Friends
    Diffs the in-game friends list against the previous snapshot on every
    FRIENDLIST_UPDATE to detect online/offline transitions. Battle.net
    friends are intentionally out of scope for this first version — that API
    has more edge cases (cross-game friends, app-only friends) that need live
    testing in-game to get right.
]]

local addon = _G.HorizonSuite
local Y = addon and addon.Augment
local A = Y and Y.Alerts
if not A then return end

local M = {}
A.Friends = M

local onlineSnapshot = {}

local function GetOnlineSet()
    local set = {}
    local num = C_FriendList and C_FriendList.GetNumFriends and C_FriendList.GetNumFriends() or 0
    for i = 1, num do
        local info = C_FriendList.GetFriendInfoByIndex(i)
        if info and info.connected and info.name then
            set[A.SafeString(info.name)] = true
        end
    end
    return set
end

function M.SetBaseline()
    onlineSnapshot = GetOnlineSet()
end

function M.HandleFriendListUpdate()
    local D = addon.AUGMENT_DEFAULTS
    if not A.GetDB("alertsFriendsEnabled", D.alertsFriendsEnabled) then return end

    local current = GetOnlineSet()

    for name in pairs(current) do
        if not onlineSnapshot[name] then
            A.Enqueue("FRIEND_ON", name, addon.L["ALERTS_FRIEND_ON_BODY"])
        end
    end
    for name in pairs(onlineSnapshot) do
        if not current[name] then
            A.Enqueue("FRIEND_OFF", name, addon.L["ALERTS_FRIEND_OFF_BODY"])
        end
    end

    onlineSnapshot = current
end
