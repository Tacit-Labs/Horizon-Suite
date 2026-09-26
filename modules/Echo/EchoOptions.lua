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

--- The setting switching a feed on or off. The All view's is echoAllView.
-- @param kind string
-- @return string
function Echo.FeedKey(kind)
    if kind == "all" then return "echoAllView" end
    return "echoFeed" .. Capitalise(kind)
end

--- False only for a feed the player has switched off.
-- @param kind string
-- @return boolean
function Echo.FeedEnabled(kind)
    if not Echo.Store.FEED_KINDS[kind] then return true end
    return Echo.Setting(Echo.FeedKey(kind)) ~= false
end

-- Last applied enabled state per feed kind, so ApplyOptions can tell an off->on change
-- from a feed that was already on. nil (never applied) never undismisses: a feed the
-- player dismissed by hand before Echo ever ran ApplyOptions stays dismissed.
local feedOn = {}

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

--- Stop re-fonting an object on font changes (a borrowed Blizzard FontString given back).
-- @param obj FontString|EditBox
function Echo.UntrackFont(obj)
    tracked[obj] = nil
end

local appliedPath  -- the path last pushed to every tracked object; Echo.ApplyFont skips a no-op call

--- Re-font every tracked object. Does nothing when the resolved path is unchanged.
function Echo.ApplyFont()
    local path = Echo.FontPath()
    if path == appliedPath then return end
    appliedPath = path
    for obj, f in pairs(tracked) do obj:SetFont(path, f.size, f.flags) end
end

--- Push every setting into the running module.
function Echo.ApplyOptions()
    Echo.History.SetEnabledCheck(function() return Echo.Setting("echoSaveHistory") ~= false end)
    Echo.History.SetMaxAge(Echo.Setting("echoHistoryDays"))
    local Store = Echo.Store
    Store.SetPersisted("guild", Echo.Setting("echoSaveGuild") == true)
    Store.SetPersisted("officer", Echo.Setting("echoSaveOfficer") == true)
    for kind in pairs(Store.DEFAULT_TIERS) do
        local tier = Echo.Setting(Echo.TierKey(kind))
        if not Store.VALID_TIERS[tier] then tier = nil end
        Store.SetKindTier(kind, tier)
    end
    Echo.Events.SetKeywords(Echo.Setting("echoKeywords"))
    for kind in pairs(Store.FEED_KINDS) do
        local on = Echo.FeedEnabled(kind)
        if on then
            -- Off->on: the feed reopens for its next line. A feed dismissed by hand while
            -- staying switched on (feedOn[kind] already true) keeps its dismissal.
            if feedOn[kind] == false then Store.Undismiss(kind) end
        else
            local conv = Store.Get(kind)
            if conv and conv.open then Store.Close(kind) end
        end
        feedOn[kind] = on
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
    local filterOn = Echo.Setting("echoHideStoredWhispers") == true
    if filterOn ~= Echo.Filter.active then Echo.Filter.Apply(filterOn) end
    -- Hide Blizzard's chat windows, or ask for a reload to bring them back. First, as hiding
    -- turns docking on.
    if Echo.HideChat then Echo.HideChat.Refresh() end
    -- Dock or undock Blizzard's input line, and re-anchor it to the new card size and edge.
    if Echo.Input then Echo.Input.Enable() end
end
