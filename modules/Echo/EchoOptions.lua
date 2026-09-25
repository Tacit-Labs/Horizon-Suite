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

local FONT_USE_GLOBAL = "__global__"
local tracked = setmetatable({}, { __mode = "k" })  -- FontString / EditBox -> { size, flags }

--- Echo's font: its own setting, else the suite's font, else the game's.
-- @return string
function Echo.FontPath()
    local global = addon.GetActiveGlobalFont and addon.GetActiveGlobalFont()
    if global then return global end
    local raw = Echo.Setting("echoFontPath")
    if type(raw) == "string" and raw ~= FONT_USE_GLOBAL and raw ~= "" then
        return (addon.ResolveFontPath and addon.ResolveFontPath(raw)) or raw
    end
    local base = addon.GetDB and addon.GetDB("fontPath", nil)
    if type(base) == "string" and base ~= "" then
        return (addon.ResolveFontPath and addon.ResolveFontPath(base)) or base
    end
    return (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"
end

--- Set an object's font now and again whenever the font setting changes.
-- @param obj FontString|EditBox
-- @param size number
-- @param flags string
function Echo.TrackFont(obj, size, flags)
    tracked[obj] = { size = size, flags = flags }
    obj:SetFont(Echo.FontPath(), size, flags)
end

--- Re-font every tracked object.
function Echo.ApplyFont()
    local path = Echo.FontPath()
    for obj, f in pairs(tracked) do obj:SetFont(path, f.size, f.flags) end
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
    Echo.ApplyFont()
    if Echo.Tiles and Echo.Tiles.ApplyPosition then Echo.Tiles.ApplyPosition() end
    if Echo.Card and Echo.Card.ApplySize then Echo.Card.ApplySize() end
    -- Re-anchor an open stack or card to the column's new scale, strata or edge.
    local stack = _G.HorizonSuiteEchoStack
    if stack and stack:IsShown() and Echo.Stack.Reanchor then Echo.Stack.Reanchor() end
    local card = _G.HorizonSuiteEchoCard
    if card and card:IsShown() and Echo.Card.Reanchor then Echo.Card.Reanchor() end
    if Echo.Redraw then Echo.Redraw.Mark("tiles") end
    Echo.Filter.Apply(Echo.Setting("echoHideStoredWhispers") == true)
end
