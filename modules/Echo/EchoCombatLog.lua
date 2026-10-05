--[[
    Horizon Suite - Echo - Combat log
    With echoCombatLog on "echo", Blizzard's own combat log window (ChatFrame2) lives in
    Echo, whether or not Blizzard's other chat windows are hidden: a "combat" feed tile opens the card, and the card
    shows the real window, filter bar and all, where its messages would be. Addons can't
    read the combat log in Midnight, so Echo never draws its lines: Blizzard parses,
    formats and filters them as it does in its own tab.
      - CombatLog.Host (HideChat.Apply or HideChat.ApplyCombatLog, out of combat) moves the window onto Echo's host
        frame for good, its tab and side buttons onto a hidden frame, and opens the tile
        (Store.EnsureFeed). The window keeps its events.
      - The host frame is the only thing that moves after that. The card parents it and
        fills its message area with it (CombatLog.Show) or hides it (CombatLog.Park), so
        opening the card in combat moves only Echo's own frame.
      - Blizzard's dock code re-anchors, re-parents and hides docked windows, and the
        combat log parents its filter bar to its tab. Post-hooks on the window put it
        back on the next frame, and Place moves the filter bar (Blizzard_CombatLog loads
        on demand; ADDON_LOADED places it once it exists).
      - The window only takes combat log lines while visible (Blizzard's OnShow/OnHide):
        each time the card shows it, Blizzard refills it from the client's log.
    Nothing is put back live: leaving "echo" asks for a reload (HideChat.Refresh).
    Blizzard: ChatFrame2 / ChatFrame2Tab / ChatFrame2ButtonFrame (SetParent, SetPoint,
    ClearAllPoints, SetAllPoints, Show, Hide, SetFrameStrata, SetFrameLevel, ScrollBar),
    CombatLogQuickButtonFrame_Custom, hooksecurefunc, C_Timer.After, ADDON_LOADED.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local CombatLog = {}
Echo.CombatLog = CombatLog

CombatLog.KEY = "combat"
CombatLog.WINDOW = "ChatFrame2"
CombatLog.BAR = "CombatLogQuickButtonFrame_Custom"
CombatLog.ADDON = "Blizzard_CombatLog"
CombatLog.MODES = { echo = true, blizzard = true, hide = true }
CombatLog.DEFAULT_MODE = "echo"

local hosted = false   -- the window lives on host
local host             -- Echo's frame the window sits on; the card parents and shows it
local holder           -- hidden, unnamed: the tab and side buttons sit here
local busy = false     -- Place is moving things: the post-hooks ignore it
local pending = false  -- a Place is waiting for the next frame
local hooked = setmetatable({}, { __mode = "k" })
local watcher          -- ADDON_LOADED, for the filter bar

--- Where the combat log goes: "echo", "blizzard" or "hide". Unset, it is in Echo while
-- Blizzard's chat is hidden and in Blizzard's tab while it shows. A profile from before
-- echoCombatLog that turned "Keep the combat log" off (echoKeepCombatLog false) reads as
-- "hide" while Blizzard's chat is hidden, the only time that setting applied.
-- @param get function|nil  (key, default) -> value; addon.GetDB unless the options page
--   passes its own
-- @return string
function CombatLog.Mode(get)
    get = get or addon.GetDB or function(_, d) return d end
    local mode = get("echoCombatLog", nil)
    if CombatLog.MODES[mode] then return mode end
    local defaults = addon.ECHO_DEFAULTS
    -- As HideChat reads it: anything but true is shown.
    if get("echoHideBlizzardChat", defaults and defaults.echoHideBlizzardChat) ~= true then return "blizzard" end
    if get("echoKeepCombatLog", nil) == false then return "hide" end
    local default = addon.ECHO_DEFAULTS and addon.ECHO_DEFAULTS.echoCombatLog
    if CombatLog.MODES[default] then return default end
    return CombatLog.DEFAULT_MODE
end

--- @return boolean  the window has been moved into Echo this session
function CombatLog.IsHosted()
    return hosted
end

local function Holder()
    if not holder then
        holder = CreateFrame("Frame", nil, UIParent)
        holder:Hide()
    end
    return holder
end

local function Host()
    if not host then
        host = CreateFrame("Frame", nil, UIParent)
        host:Hide()
    end
    return host
end

-- The window's scroll bar sits outside its right edge; the filter bar reaches over it.
local function ScrollWidth(window)
    local bar = window.ScrollBar
    if type(bar) ~= "table" or type(bar.GetWidth) ~= "function" then return 0 end
    local width = bar:GetWidth()
    if Echo.IsSecret(width) or type(width) ~= "number" then return 0 end
    return width
end

local function BarHeight(bar)
    if not bar or type(bar.GetHeight) ~= "function" then return 0 end
    local height = bar:GetHeight()
    if Echo.IsSecret(height) or type(height) ~= "number" then return 0 end
    return height
end

local function MoveTo(frame, parent)
    if type(frame) == "table" and type(frame.SetParent) == "function" and frame:GetParent() ~= parent then
        frame:SetParent(parent)
    end
end

-- Put the window, its filter bar, tab and side buttons where Echo keeps them. The top
-- inset is the filter bar's height exactly: Blizzard's FCF_DockUpdate override sets the
-- docked log's TOPLEFT to that offset from the same anchor, so it moves nothing.
local function Place()
    local window = _G[CombatLog.WINDOW]
    if not hosted or type(window) ~= "table" then return end
    local frame = Host()
    busy = true
    MoveTo(window, frame)
    local bar = _G[CombatLog.BAR]
    window:ClearAllPoints()
    window:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -BarHeight(bar))
    window:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -ScrollWidth(window), 0)
    -- A chat window keeps a strata of its own, which would draw it under the card.
    window:SetFrameStrata(frame:GetFrameStrata())
    window:SetFrameLevel(frame:GetFrameLevel() + 1)
    if not window:IsShown() then window:Show() end
    if bar then
        MoveTo(bar, frame)
        bar:SetFrameStrata(frame:GetFrameStrata())
        bar:SetFrameLevel(frame:GetFrameLevel() + 5)
    end
    MoveTo(_G[CombatLog.WINDOW .. "Tab"], Holder())
    MoveTo(window.buttonFrame or _G[CombatLog.WINDOW .. "ButtonFrame"], Holder())
    busy = false
end

-- Blizzard moved or hid something Echo placed: put it back next frame, once.
local function Replace()
    if busy or not hosted or pending then return end
    pending = true
    C_Timer.After(0, function()
        pending = false
        Place()
    end)
end

local function Hook(frame, methods)
    if type(frame) ~= "table" or hooked[frame] then return end
    hooked[frame] = true
    for _, method in ipairs(methods) do
        if type(frame[method]) == "function" then hooksecurefunc(frame, method, Replace) end
    end
end

local function HookAll()
    local window = _G[CombatLog.WINDOW]
    Hook(window, { "SetParent", "SetPoint", "SetAllPoints", "ClearAllPoints", "Hide" })
    Hook(_G[CombatLog.WINDOW .. "Tab"], { "SetParent" })
    Hook(_G[CombatLog.BAR], { "SetParent" })
end

local function OnAddonLoaded(_, _, name)
    if name ~= CombatLog.ADDON or not hosted then return end
    HookAll()
    Place()
end

--- Move the combat log into Echo and open its tile. Callers keep it out of combat
-- (HideChat.Apply). Safe to call again: it only re-places what is there.
-- @return boolean  the window exists and is hosted
function CombatLog.Host()
    local window = _G[CombatLog.WINDOW]
    if type(window) ~= "table" then return false end
    hosted = true
    HookAll()
    if not watcher then
        watcher = CreateFrame("Frame")
        watcher:SetScript("OnEvent", OnAddonLoaded)
    end
    watcher:RegisterEvent("ADDON_LOADED")
    Place()
    Echo.Store.EnsureFeed(CombatLog.KEY)
    return true
end

--- The card shows the combat log: fill its message area with the host.
-- @param parent Frame  the card
-- @param area Frame  the card's message area, which the host covers
function CombatLog.Show(parent, area)
    if not hosted then return end
    local frame = Host()
    if frame:GetParent() ~= parent then frame:SetParent(parent) end
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", area, "TOPLEFT", 0, 0)
    frame:SetPoint("BOTTOMRIGHT", area, "BOTTOMRIGHT", 0, 0)
    frame:SetFrameStrata(parent:GetFrameStrata())
    frame:SetFrameLevel(parent:GetFrameLevel() + 20)
    frame:Show()
    Place()
end

--- The card shows something else, or closed.
function CombatLog.Park()
    if host then host:Hide() end
end

--- Module disable: park the window. It stays hosted until a reload.
function CombatLog.Disable()
    CombatLog.Park()
    if watcher then watcher:UnregisterEvent("ADDON_LOADED") end
end

-- Tests.
function CombatLog._host() return host end
function CombatLog._holder() return holder end
function CombatLog._watcher() return watcher end
function CombatLog._reset()
    hosted, pending, busy = false, false, false
    host, holder, watcher = nil, nil, nil
    hooked = setmetatable({}, { __mode = "k" })
end
