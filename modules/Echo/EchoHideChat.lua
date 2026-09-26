--[[
    Horizon Suite - Echo - Hide Blizzard chat
    Plan 12, Task 5: with echoHideBlizzardChat on, Blizzard's chat windows go away and Echo
    stands in for them. Applied one frame after PLAYER_ENTERING_WORLD (or at once when the
    setting comes on later), never in combat: in combat it waits for PLAYER_REGEN_ENABLED.
      - Each window in CHAT_FRAMES and its tab move onto a hidden, unnamed frame Echo owns;
        ChatFrame2 (the combat log) stays while echoKeepCombatLog is on. A post-hook on
        each tab's SetParent moves it back when Blizzard's dock re-parents it.
      - Their events go: UnregisterAllEvents, then UPDATE_CHAT_COLOR again, and on
        ChatFrame1 the whisper events the game needs for R (each only where the client
        has it). A post-hook on RegisterEvent unregisters anything else again.
      - Blizzard's chat buttons move onto the hidden frame too.
      - Applying again (a settings change, a temporary window) only handles windows and
        buttons not yet hidden. A post-hook on FCF_OpenTemporaryWindow hides a new window
        (a pet battle's log, a whisper popout) as it opens.
      - Blizzard's input line is a child of ChatFrame1: when its parent is one of the hidden
        windows, it moves onto UIParent (recorded, and put back when Echo or docking is
        disabled), or it would vanish with the window.
      - whisperMode is set to inline, once per apply. whisperMode is account-wide, so its
        earlier value is saved account-wide (History.SaveAccountCVar), only when none is
        saved yet. Once the world is loaded with the setting off (turned off, or another
        character that doesn't hide chat), a saved value is put back while whisperMode is
        still inline, then forgotten; a whisperMode the player changed meanwhile is kept.
      - While hiding is applied, "Hide whispers Echo has stored" stays off: ChatFrame1 keeps
        its whisper events so Blizzard's own code sets R's target (Echo.ApplyOptions).
      - While hiding is applied, the All view collects even when echoAllView is off
        (Echo.FeedEnabled), since chat Echo has no tile for goes only there.
      - With ChatFrame1's events off, chat types Echo doesn't route would vanish, so Echo's
        own frame here registers every CHAT_MSG_* in ChatTypeGroup that Echo doesn't
        route, runs other addons' filters over it, and files it into the All view.
    Nothing is un-hidden live: turning the setting off, or disabling Echo after it was
    applied, asks for a reload through the dashboard's reload prompt. Everything runs from
    Echo's module code, so a disabled or broken Echo hides nothing.
    Needs the docked input line: while the setting is on, echoDockInput is kept on.
    Blizzard: CHAT_FRAMES, ChatFrameN / ChatFrameNTab (SetParent, GetParent,
    UnregisterAllEvents, RegisterEvent, UnregisterEvent), the chat buttons (SetParent),
    ChatFrame1EditBox (GetParent, SetParent), FCF_OpenTemporaryWindow (post-hook), hooksecurefunc,
    C_EventUtils.IsEventValid, C_CVar.GetCVar / SetCVar (or the GetCVar / SetCVar
    globals), InCombatLockdown, IsLoggedIn, ChatTypeGroup, ChatTypeInfo.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo
local IsSecret = Echo.IsSecret

local HideChat = {}
Echo.HideChat = HideChat

HideChat.COMBAT_LOG = "ChatFrame2"
-- Every hidden window keeps chat colour updates.
HideChat.KEEP_EVENTS = { "UPDATE_CHAT_COLOR" }
-- ChatFrame1 also keeps what the game needs to remember who R replies to.
HideChat.KEEP_MAIN_EVENTS = { "CHAT_MSG_WHISPER", "CHAT_MSG_BN_WHISPER", "CAUTIONARY_CHAT_MESSAGE" }
HideChat.BUTTONS = {
    "ChatFrameMenuButton", "ChatFrameChannelButton", "QuickJoinToastButton",
    "ChatFrameToggleVoiceDeafenButton", "ChatFrameToggleVoiceMuteButton",
}
-- CHAT_MSG_COMBAT_* types are left out of the extra events, except these (and the ones
-- Echo routes itself).
HideChat.COMBAT_KEEP = { CHAT_MSG_COMBAT_HONOR_GAIN = true }

local active = false      -- Echo is enabled
local worldReady = false  -- PLAYER_ENTERING_WORLD has fired (or Echo enabled after login)
local pending = false     -- an apply is waiting for the next frame
local frame               -- Echo's frame: world, combat and the extra chat events
local hiddenParent        -- the unnamed, hidden frame the windows move onto
local hidden = setmetatable({}, { __mode = "k" })   -- window or tab -> true while hidden
local kept = setmetatable({}, { __mode = "k" })     -- hidden window -> { event = true }
local hookedTabs = setmetatable({}, { __mode = "k" })
local hookedWindows = setmetatable({}, { __mode = "k" })
local extra = {}          -- extra chat events registered on frame
local combatLogHidden = false
local handledButtons = setmetatable({}, { __mode = "k" })  -- chat buttons already moved
local whispersSet = false  -- whisperMode has been set this apply-session
local boxParent           -- the input line's parent before Echo moved it onto UIParent
local tempHooked = false   -- FCF_OpenTemporaryWindow is post-hooked

local function Valid(event)
    local utils = _G.C_EventUtils
    if not utils or type(utils.IsEventValid) ~= "function" then return true end
    local ok, valid = pcall(utils.IsEventValid, event)
    return ok and valid == true
end

local function GetCVarValue(name)
    local api = (_G.C_CVar and _G.C_CVar.GetCVar) or _G.GetCVar
    if type(api) ~= "function" then return nil end
    local ok, value = pcall(api, name)
    if not ok or IsSecret(value) or type(value) ~= "string" then return nil end
    return value
end

local function SetCVarValue(name, value)
    local api = (_G.C_CVar and _G.C_CVar.SetCVar) or _G.SetCVar
    if type(api) == "function" then pcall(api, name, value) end
end

--- Ask for a reload through the dashboard's reload prompt: the flag module toggles set,
-- then a refresh so the prompt shows. Hiding Blizzard's chat is never undone live.
function HideChat.AskReload()
    addon._moduleReloadRecommended = true
    if type(addon.Dashboard_Refresh) == "function" then pcall(addon.Dashboard_Refresh) end
end

local function HiddenParent()
    if not hiddenParent then
        hiddenParent = CreateFrame("Frame")
        hiddenParent:Hide()
    end
    return hiddenParent
end

-- Post-hook on a tab's SetParent: Blizzard's dock re-parents tabs as it lays them out.
local function OnTabSetParent(tab, parent)
    if hidden[tab] and hiddenParent and parent ~= hiddenParent then tab:SetParent(hiddenParent) end
end

-- Post-hook on a hidden window's RegisterEvent: anything but its kept events goes again.
local function OnWindowRegisterEvent(window, event)
    local keep = kept[window]
    if keep and not keep[event] then window:UnregisterEvent(event) end
end

local function Silence(window, isMain)
    local keep = {}
    for _, event in ipairs(HideChat.KEEP_EVENTS) do
        if Valid(event) then keep[event] = true end
    end
    if isMain then
        for _, event in ipairs(HideChat.KEEP_MAIN_EVENTS) do
            if Valid(event) then keep[event] = true end
        end
    end
    kept[window] = keep
    window:UnregisterAllEvents()
    for event in pairs(keep) do pcall(window.RegisterEvent, window, event) end
    if not hookedWindows[window] then
        hookedWindows[window] = true
        hooksecurefunc(window, "RegisterEvent", OnWindowRegisterEvent)
    end
end

local function HideWindow(name)
    local window = _G[name]
    if type(window) ~= "table" then return end
    local parent = HiddenParent()
    -- Already handled: its events and tab are Echo's already, and its hooks stay.
    if hidden[window] and (type(window.GetParent) ~= "function" or window:GetParent() == parent) then return end
    hidden[window] = true
    window:SetParent(parent)
    local tab = _G[name .. "Tab"]
    if type(tab) == "table" then
        hidden[tab] = true
        tab:SetParent(parent)
        if not hookedTabs[tab] then
            hookedTabs[tab] = true
            hooksecurefunc(tab, "SetParent", OnTabSetParent)
        end
    end
    Silence(window, name == "ChatFrame1")
    if name == HideChat.COMBAT_LOG then combatLogHidden = true end
end

--- Every CHAT_MSG_* event in ChatTypeGroup that Echo doesn't route and this client has,
-- except combat types (HideChat.COMBAT_KEEP aside).
-- @return table events  sorted
function HideChat.ExtraEvents()
    local out, seen = {}, {}
    local groups = _G.ChatTypeGroup
    if type(groups) ~= "table" then return out end
    local routed = Echo.Store.EVENT_KIND
    for _, list in pairs(groups) do
        if type(list) == "table" then
            for _, event in pairs(list) do
                if type(event) == "string" and not seen[event] and event:sub(1, 9) == "CHAT_MSG_" then
                    seen[event] = true
                    -- Echo keys a few events without CHAT_MSG_ (BN_INLINE_TOAST_ALERT).
                    local isRouted = routed[event] ~= nil or routed[event:sub(10)] ~= nil
                    local combat = event:sub(1, 16) == "CHAT_MSG_COMBAT_" and not HideChat.COMBAT_KEEP[event]
                    if not isRouted and not combat and Valid(event) then out[#out + 1] = event end
                end
            end
        end
    end
    table.sort(out)
    return out
end

local function RegisterExtra()
    for _, event in ipairs(HideChat.ExtraEvents()) do
        if not extra[event] and pcall(frame.RegisterEvent, frame, event) then extra[event] = true end
    end
end

--- One unrouted chat line: other addons' filters first (a blocked line is dropped), then
-- into the All view as a printed line in its chat type's colour, after the sender's short
-- name when it can be read. A secret text is kept as it is and never joined to anything.
-- @param event string
function HideChat.OnChatEvent(event, ...)
    if not active then return end
    local blocked, args = Echo.Events.RunFilters(event, ...)
    if blocked then return end
    local text, sender = args[1], args[2]
    local info = _G.ChatTypeInfo and _G.ChatTypeInfo[event:sub(10)]
    local r, g, b
    if not IsSecret(info) and type(info) == "table" then r, g, b = info.r, info.g, info.b end
    local name
    if not IsSecret(sender) and type(sender) == "string" and sender ~= "" then
        -- A Battle.net |K name is used whole, never cut.
        if event:sub(1, 12) == "CHAT_MSG_BN_" then
            name = sender
        else
            name = sender:match("^([^-]+)") or sender
        end
    end
    local prefix = name and (name .. ":") or nil
    -- NPC and boss emotes and whispers read "%s roars!": fill in the speaker, as
    -- Blizzard's chat does, and drop the prefix.
    if not IsSecret(text) and type(text) == "string" and text:find("%s", 1, true) then
        local ok, formatted = pcall(string.format, text, name or addon.L["ECHO_SOMEONE"])
        if ok then text, prefix = formatted, nil end
    end
    if Echo.All and Echo.All.AddLine then Echo.All.AddLine(text, r, g, b, prefix) end
end

-- Once per apply-session: a whisperMode the player changes while hiding is on is kept.
local function SetWhispersInline()
    if whispersSet then return end
    local current = GetCVarValue("whisperMode")
    if not current then return end
    local History = Echo.History
    if History.SavedAccountCVar("whisperMode") == nil then
        -- Nowhere to keep the old value (not bound yet): leave it alone rather than
        -- change it for good.
        if not History.SaveAccountCVar("whisperMode", current) then return end
    end
    whispersSet = true
    if current ~= "inline" then SetCVarValue("whisperMode", "inline") end
end

--- Put whisperMode back to the value saved when hiding was applied, and forget it. Only
-- while it still reads inline: a value the player chose meanwhile is theirs. An unreadable
-- whisperMode keeps the saved value for next time.
-- @return boolean restored
function HideChat.RestoreWhisperMode()
    whispersSet = false
    local History = Echo.History
    local previous = History.SavedAccountCVar("whisperMode")
    -- Task 5 saved it per character; take that one too, once.
    local legacy = History.SavedCVar and History.SavedCVar("whisperMode")
    if previous == nil then previous = legacy end
    if previous == nil then return false end
    local current = GetCVarValue("whisperMode")
    if current == nil then return false end
    local restored = false
    if current == "inline" and previous ~= "inline" then
        SetCVarValue("whisperMode", previous)
        restored = true
    end
    History.SaveAccountCVar("whisperMode", nil)
    if legacy ~= nil then History.SaveCVar("whisperMode", nil) end
    return restored
end

--- Put Blizzard's input line back on the parent it had before Apply moved it onto
-- UIParent. Input.Disable and HideChat.Disable call this; it does nothing otherwise.
function HideChat.RestoreBoxParent()
    local previous = boxParent
    boxParent = nil
    local box = _G.ChatFrame1EditBox
    if previous and type(box) == "table" and type(box.SetParent) == "function" then box:SetParent(previous) end
end

--- The input line's parent was one of the windows just hidden: move it onto UIParent, so
-- it stays on screen, and re-anchor it there.
local function RescueBox()
    local box = _G.ChatFrame1EditBox
    if type(box) ~= "table" or type(box.GetParent) ~= "function" or type(box.SetParent) ~= "function" then return end
    local parent = box:GetParent()
    if parent == nil or not hidden[parent] then return end
    boxParent = parent
    box:SetParent(UIParent)
    if Echo.Input and Echo.Input.Reanchor then Echo.Input.Reanchor() end
end

local function On()
    return Echo.Setting("echoHideBlizzardChat") == true
end

--- True once any window has been hidden this session.
function HideChat.IsApplied()
    return next(hidden) ~= nil
end

--- Hide the windows, their events and the buttons now. Callers keep it out of combat.
-- Safe to call again: only what isn't handled yet is touched.
function HideChat.Apply()
    local first = not HideChat.IsApplied()
    local keepCombatLog = Echo.Setting("echoKeepCombatLog") ~= false
    local names = _G.CHAT_FRAMES
    if type(names) == "table" then
        for _, name in ipairs(names) do
            if not (keepCombatLog and name == HideChat.COMBAT_LOG) then HideWindow(name) end
        end
    end
    local parent = HiddenParent()
    for _, name in ipairs(HideChat.BUTTONS) do
        local button = _G[name]
        if type(button) == "table" and type(button.SetParent) == "function" and not handledButtons[button] then
            handledButtons[button] = true
            button:SetParent(parent)
        end
    end
    RescueBox()
    SetWhispersInline()
    RegisterExtra()
    if not HideChat.IsApplied() then return end
    -- ChatFrame1 keeps its whisper events so Blizzard sets R's target: the whisper filter
    -- goes off (Echo.ApplyOptions keeps it off from now on).
    if Echo.Filter and Echo.Filter.active then Echo.Filter.Apply(false) end
    -- The All view collects from now on even with echoAllView off (Echo.FeedEnabled), so a
    -- tile switched off earlier comes back for its next line.
    if first and Echo.Setting("echoAllView") == false then Echo.Store.Undismiss(Echo.All and Echo.All.KEY or "all") end
end

-- The frame after it was asked for: still wanted, and out of combat, else after combat.
local function TryApply()
    if not active or not On() then return end
    if type(InCombatLockdown) == "function" and InCombatLockdown() then
        frame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    HideChat.Apply()
end

local function Schedule()
    if pending then return end
    pending = true
    C_Timer.After(0, function()
        pending = false
        TryApply()
    end)
end

-- Post-hook on FCF_OpenTemporaryWindow: a new window (a pet battle's log, a whisper
-- popout) joins CHAT_FRAMES; while hiding is applied, it goes too (out of combat).
local function OnTemporaryWindow()
    if active and On() and HideChat.IsApplied() then TryApply() end
end

local function OnEvent(_, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        worldReady = true
        frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        if On() then
            Schedule()
        else
            -- Another character hid chat and set whisperMode inline account-wide.
            HideChat.RestoreWhisperMode()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        TryApply()
    else
        HideChat.OnChatEvent(event, ...)
    end
end

--- Push the setting: hide (next frame, out of combat) when on; when off, put whisperMode
-- back and, if anything was hidden, ask for a reload. Echo.ApplyOptions calls this on
-- every settings change, before docking is applied.
function HideChat.Refresh()
    if not active then return end
    if On() then
        -- The hidden main window takes the undocked input line's home with it.
        if Echo.Setting("echoDockInput") == false and type(addon.SetDB) == "function" then
            addon.SetDB("echoDockInput", true)
        end
        -- Keeping the combat log again can't bring it back live.
        if combatLogHidden and Echo.Setting("echoKeepCombatLog") ~= false then HideChat.AskReload() end
        if worldReady then Schedule() end
        return
    end
    -- Before the world is loaded, PLAYER_ENTERING_WORLD does this, with CVars in place.
    if worldReady then HideChat.RestoreWhisperMode() end
    if HideChat.IsApplied() then HideChat.AskReload() end
end

--- Start: wait for the world (or go now, after login). Echo.Init calls this.
function HideChat.Enable()
    active = true
    if not frame then
        frame = CreateFrame("Frame")
        frame:SetScript("OnEvent", OnEvent)
    end
    if not tempHooked and type(_G.FCF_OpenTemporaryWindow) == "function" and type(hooksecurefunc) == "function" then
        tempHooked = true
        hooksecurefunc("FCF_OpenTemporaryWindow", OnTemporaryWindow)
    end
    if type(IsLoggedIn) == "function" and IsLoggedIn() then
        worldReady = true
    else
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    end
end

--- Stop: drop the extra chat events, put whisperMode and the input line's parent back,
-- and ask for a reload if anything was hidden. The post-hooks stay (they can't be
-- removed) and keep the windows hidden until the reload.
function HideChat.Disable()
    active = false
    worldReady = false
    if frame then
        frame:UnregisterAllEvents()
        extra = {}
    end
    HideChat.RestoreWhisperMode()
    HideChat.RestoreBoxParent()
    if HideChat.IsApplied() then HideChat.AskReload() end
end

-- Test and debug handles. _reset forgets what was hidden, as a reload would.
function HideChat._frame() return frame end
function HideChat._reset()
    for k in pairs(hidden) do hidden[k] = nil end
    for k in pairs(kept) do kept[k] = nil end
    for k in pairs(handledButtons) do handledButtons[k] = nil end
    combatLogHidden, whispersSet, boxParent = false, false, nil
end
