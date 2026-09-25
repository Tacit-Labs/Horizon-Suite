--[[
    Horizon Suite - Echo - Options
    Echo.ApplyOptions pushes every setting into the running module. options/OptionsData.lua
    calls it when any ECHO_KEYS setting changes, and Echo.Init calls it on enable.
    Settings are read through Echo.Setting, so a missing profile value is its default.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local function Capitalise(s)
    return s:sub(1, 1):upper() .. s:sub(2)
end

--- The setting holding a conversation kind's tier.
-- @param kind string
-- @return string
function Echo.TierKey(kind)
    return "echoTier" .. Capitalise(kind)
end

--- The setting switching a feed on or off.
-- @param kind string
-- @return string
function Echo.FeedKey(kind)
    return "echoFeed" .. Capitalise(kind)
end

--- False only for a feed the player has switched off.
-- @param kind string
-- @return boolean
function Echo.FeedEnabled(kind)
    if not Echo.Store.FEED_KINDS[kind] then return true end
    return Echo.Setting(Echo.FeedKey(kind)) ~= false
end

--- Push every setting into the running module.
function Echo.ApplyOptions()
    Echo.History.SetEnabledCheck(function() return Echo.Setting("echoSaveHistory") ~= false end)
    local Store = Echo.Store
    for kind in pairs(Store.DEFAULT_TIERS) do
        local tier = Echo.Setting(Echo.TierKey(kind))
        if not Store.VALID_TIERS[tier] then tier = nil end
        Store.SetKindTier(kind, tier)
    end
    Echo.Events.SetKeywords(Echo.Setting("echoKeywords"))
    for kind in pairs(Store.FEED_KINDS) do
        local conv = Store.Get(kind)
        if not Echo.FeedEnabled(kind) and conv and conv.open then Store.Close(kind) end
    end
end
