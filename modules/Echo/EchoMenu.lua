--[[
    Horizon Suite - Echo - Menu
    The ⋯ menu on the card: pin, notification tier, close conversation. Its contents come
    from View.MenuSpec; this file turns them into Blizzard's context menu and runs the choice.
    A column tile's right-click menu (Menu.OpenTile) is the same menu with Close first, or
    for a group tile its name, Close group and a submenu per member.
    Also the right-click menu on one message: pin or unpin it, or say why it can't be pinned,
    and whisper or invite the player who wrote it. Menu.IsOpen tells the card's idle close
    whether either is still open. And the Echo icon's right-click menu (Menu.OpenIcon):
    start a chat, mark all read, the collapse mode, hide Blizzard chat, lock, and settings.
    Its settings are written as the options page writes them; switching Blizzard's chat back
    on asks for a reload with a popup (HORIZON_ECHO_RELOAD).
    Blizzard: MenuUtil.CreateContextMenu, Menu.GetManager():GetOpenMenu (where it exists),
    C_PartyInfo.InviteUnit (or InviteUnit), IsInGroup, UnitIsGroupLeader,
    UnitIsGroupAssistant, StaticPopupDialogs / StaticPopup_Show, ReloadUI.
    Horizon: addon.OptionsData_SetDB (or addon.SetDB), addon.Dashboard_Refresh,
    addon.ShowOptions and the dashboard's OpenModule.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Menu = {}
Echo.Menu = Menu

-- The card's idle close (Echo.Card) asks whether one of these menus is open. MenuUtil hands
-- back the menu it opened on current clients; one that hands back nothing counts as open
-- for Menu.OPEN_GRACE seconds after it was opened. Where Blizzard's menu manager exists
-- (Menu.GetManager():GetOpenMenu()), the menu must also be the one it has open.
Menu.OPEN_GRACE = 1
local openMenu, openedAt

-- Remember the menu CreateContextMenu opened (or when, without a handle).
local function Opened(ok, menu)
    if not ok then return end
    openMenu = (type(menu) == "table" and type(menu.IsShown) == "function") and menu or nil
    openedAt = (not openMenu and type(GetTime) == "function") and GetTime() or nil
end

-- Whether Blizzard's menu manager has another menu (or none) open in place of this one.
-- False when the client has no manager, or asking it fails.
local function ManagerDisowns(menu)
    local api = _G.Menu
    if type(api) ~= "table" or type(api.GetManager) ~= "function" then return false end
    local ok, current = pcall(function()
        local manager = api.GetManager()
        return manager:GetOpenMenu()
    end)
    if not ok or Echo.IsSecret(current) then return false end
    return current ~= menu
end

--- Whether a menu opened from Echo (the card's ⋯ menu, a message's menu or the Echo icon's
-- menu) is still open.
-- @return boolean
function Menu.IsOpen()
    if openMenu then
        local ok, shown = pcall(openMenu.IsShown, openMenu)
        if ok and not Echo.IsSecret(shown) and shown and not ManagerDisowns(openMenu) then return true end
        openMenu = nil
        return false
    end
    if openedAt and type(GetTime) == "function" then
        local now = GetTime()
        if type(now) == "number" and now - openedAt < Menu.OPEN_GRACE then return true end
    end
    return false
end

--- Invite a player to your group. Shared by the ⋯ menu, the message menu and /inv.
-- @param name string  "Name-Realm"
-- @return boolean asked  false when the client has no invite function
function Menu.InviteName(name)
    if Echo.IsSecret(name) or type(name) ~= "string" or name == "" then return false end
    local invite = C_PartyInfo and C_PartyInfo.InviteUnit
    if type(invite) ~= "function" then invite = _G.InviteUnit end
    if type(invite) ~= "function" then return false end
    pcall(invite, name)
    return true
end

--- Whether you may invite now, as Blizzard decides it: out of a group anyone can; in one,
-- only the leader or an assistant. A client without those checks counts as allowed.
-- @return boolean
function Menu.CanInvite()
    local function ask(fn, ...)
        if type(fn) ~= "function" then return nil end
        local ok, v = pcall(fn, ...)
        if not ok or Echo.IsSecret(v) then return false end
        return v and true or false
    end
    if not ask(IsInGroup) then return true end
    local leader = ask(UnitIsGroupLeader, "player")
    local assistant = ask(UnitIsGroupAssistant, "player")
    if leader == nil and assistant == nil then return true end
    return leader == true or assistant == true
end

--- Carry out one menu choice.
-- @param convKey string
-- @param action string  "pin" | "invite" | "tier" | "close"
-- @param value string|nil  the tier for "tier" ("default" clears the override)
function Menu.Run(convKey, action, value)
    local Store = Echo.Store
    if action == "pin" then
        local conv = Store.Get(convKey)
        if conv then Store.SetPinned(convKey, not conv.pinned) end
    elseif action == "invite" then
        local conv = Store.Get(convKey)
        local target = conv and Echo.View.InviteTarget(conv)
        if target then Menu.InviteName(target) end
    elseif action == "tier" then
        Store.SetTier(convKey, (value ~= "default") and value or nil)
    elseif action == "close" then
        Store.Close(convKey)
    end
end

--- Fill a MenuUtil root description for a conversation.
-- @param rootDescription table
-- @param convKey string
-- @param opts table|nil  View.MenuSpec's options ({ closeFirst = true } for a tile's menu)
function Menu.Build(rootDescription, convKey, opts)
    local conv = Echo.Store.Get(convKey)
    if not conv then return end
    for _, entry in ipairs(Echo.View.MenuSpec(conv, opts)) do
        if entry.kind == "button" then
            local action = entry.action
            rootDescription:CreateButton(entry.label, function() Menu.Run(convKey, action) end)
        elseif entry.kind == "title" then
            rootDescription:CreateTitle(entry.label)
        elseif entry.kind == "divider" then
            rootDescription:CreateDivider()
        elseif entry.kind == "radio" then
            local value = entry.value
            rootDescription:CreateRadio(entry.label,
                function() return (Echo.Store.OverrideOf(convKey) or "default") == value end,
                function() Menu.Run(convKey, "tier", value) end)
        end
    end
end

--- Whether the game can show a context menu (MenuUtil).
-- @return boolean
function Menu.Available()
    return MenuUtil ~= nil and type(MenuUtil.CreateContextMenu) == "function"
end

--- Open the menu for a conversation from a button.
-- @param owner Frame
-- @param convKey string
-- @return boolean opened
function Menu.Open(owner, convKey)
    if not Menu.Available() then return false end
    -- pcall: a refused menu is reported as not opened, never raised.
    local ok, menu = pcall(MenuUtil.CreateContextMenu, owner, function(_, rootDescription)
        Menu.Build(rootDescription, convKey)
    end)
    Opened(ok, menu)
    return ok
end

-- A tile's right-click menu (Menu.OpenTile) -------------------------------------------------

local CLOSE_FIRST = { closeFirst = true }

--- Close every open member of a group (a group tile's Close group, or its middle-click).
-- Each close goes through Store.Close, so the card follows it as from the ⋯ menu.
-- @param index number  the group's index
function Menu.CloseGroup(index)
    local Groups = Echo.Groups
    if not Groups then return end
    -- The keys first: each close changes who Groups.Members counts.
    local keys = {}
    for _, conv in ipairs(Groups.Members(index)) do keys[#keys + 1] = conv.key end
    for _, key in ipairs(keys) do Echo.Store.Close(key) end
end

--- Fill a MenuUtil root description for a group tile: the group's name, Close group, then
-- a submenu per open member (View.DisplayName) holding that member's own tile menu.
-- @param rootDescription table
-- @param index number
function Menu.BuildGroup(rootDescription, index)
    local Groups = Echo.Groups
    if not Groups then return end
    local L = addon.L
    local name = Groups.Name(index)
    if name ~= "" then rootDescription:CreateTitle(name) end
    rootDescription:CreateButton(L["ECHO_CLOSE_GROUP"], function() Menu.CloseGroup(index) end)
    local members = Groups.Members(index)
    if #members == 0 then return end
    rootDescription:CreateDivider()
    for _, conv in ipairs(members) do
        local key = conv.key
        local sub = rootDescription:CreateButton(Echo.View.DisplayName(conv))
        if sub and type(sub.CreateButton) == "function" then Menu.Build(sub, key, CLOSE_FIRST) end
    end
end

--- Open a column tile's right-click menu: a conversation's menu with Close first, or a
-- group's menu for a group tile.
-- @param owner Frame  the tile
-- @param key string  the tile's conversation or group key
-- @return boolean opened
function Menu.OpenTile(owner, key)
    if not Menu.Available() then return false end
    local index = Echo.Groups and Echo.Groups.IndexOf(key)
    local ok, menu = pcall(MenuUtil.CreateContextMenu, owner, function(_, rootDescription)
        if index then
            Menu.BuildGroup(rootDescription, index)
        else
            Menu.Build(rootDescription, key, CLOSE_FIRST)
        end
    end)
    Opened(ok, menu)
    return ok
end

-- The disabled button's text for each reason Store.PinMessage can refuse.
local BLOCKED = {
    secret  = "ECHO_PIN_BLOCKED_SECRET",
    chat    = "ECHO_PIN_BLOCKED_CHAT",
    total   = "ECHO_PIN_BLOCKED_TOTAL",
    unsaved = "ECHO_PIN_BLOCKED_UNSAVED",
    all     = "ECHO_PIN_ALL",
}

-- The pin entry for one message: Pin message, Unpin message, or a disabled button saying
-- why it can't be pinned. An All line mirrored from a chat pins its source record, in
-- that chat; a printed All line can't be pinned.
local function AddPinEntry(rootDescription, convKey, record)
    local Store = Echo.Store
    local L = addon.L
    if Store.KindOf(convKey) == "all" and type(record.sourceRecord) == "table" and record.sourceKey
        and Store.KindOf(record.sourceKey) ~= "all" then
        convKey, record = record.sourceKey, record.sourceRecord
    end
    local pins = Store.Pins(convKey)
    if Store.PinIndex(convKey, record, pins) then
        rootDescription:CreateButton(L["ECHO_UNPIN_MESSAGE"], function()
            -- Look the index up again at click time: the pins may have changed since.
            local index = Store.PinIndex(convKey, record)
            if index then Store.UnpinMessage(convKey, index) end
        end)
        return
    end
    local reason = Store.PinBlockReason(convKey, record)
    if reason then
        local b = rootDescription:CreateButton(L[BLOCKED[reason] or BLOCKED.unsaved], function() end)
        if b and b.SetEnabled then b:SetEnabled(false) end
        return
    end
    rootDescription:CreateButton(L["ECHO_PIN_MESSAGE"], function() Store.PinMessage(convKey, record) end)
end

--- Open (or start) the whisper with a player on the card. An existing whisper whose name
-- differs only in case is reused.
-- @param name string  "Name-Realm"
function Menu.WhisperName(name)
    local Store = Echo.Store
    local key = Store.WhisperKeyLike("w:" .. name) or Store.KeyFor("whisper", name)
    if not key or not Store.Start(key) then return end
    if Echo.Card then
        local tile = Echo.Tiles and Echo.Tiles.TileFor and Echo.Tiles.TileFor(key) or nil
        Echo.Card.Open(key, true, tile)
    end
end

--- Fill a MenuUtil root description for one message: the pin entry, then, when a player
-- wrote it (View.MessageSender), Whisper and Invite. Whisper is left out inside that
-- player's own whisper, and Invite while you are in a group you can't invite to.
-- @param rootDescription table
-- @param convKey string
-- @param record table  the message's Store record
function Menu.BuildMessage(rootDescription, convKey, record)
    local Store = Echo.Store
    local L = addon.L
    if not convKey or type(record) ~= "table" then return end
    AddPinEntry(rootDescription, convKey, record)
    local name = Echo.View.MessageSender(convKey, record)
    if not name then return end
    local short = name:match("^([^-]+)") or name
    local whisperKey = Store.WhisperKeyLike("w:" .. name) or ("w:" .. name)
    local whisper = whisperKey ~= convKey
    local invite = Menu.CanInvite()
    if not whisper and not invite then return end
    rootDescription:CreateDivider()
    if whisper then
        rootDescription:CreateButton(L["ECHO_WHISPER_NAME"]:format(short), function() Menu.WhisperName(name) end)
    end
    if invite then
        rootDescription:CreateButton(L["ECHO_INVITE_NAME"]:format(short), function() Menu.InviteName(name) end)
    end
end

--- Open the menu for one message.
-- @param owner Frame  the bubble or feed line clicked
-- @param convKey string
-- @param record table
-- @return boolean opened
function Menu.OpenMessage(owner, convKey, record)
    if not Menu.Available() then return false end
    local ok, menu = pcall(MenuUtil.CreateContextMenu, owner, function(_, rootDescription)
        Menu.BuildMessage(rootDescription, convKey, record)
    end)
    Opened(ok, menu)
    return ok
end

-- The Echo icon's menu (Menu.OpenIcon) ------------------------------------------------------

-- The collapse choices, in the options page's order.
local COLLAPSE_CHOICES = {
    { "ECHO_COLLAPSE_OFF", "off" },
    { "ECHO_COLLAPSE_ALL", "all" },
    { "ECHO_COLLAPSE_KEEPNEW", "keepnew" },
}

Menu.RELOAD_POPUP = "HORIZON_ECHO_RELOAD"

-- Write a setting the way the options page does: through OptionsData_SetDB, which also
-- applies it, or SetDB and Echo.ApplyOptions without it. A shown dashboard is refreshed so
-- its controls (and its reload prompt) follow.
local function SetSetting(key, value)
    if type(addon.OptionsData_SetDB) == "function" then
        addon.OptionsData_SetDB(key, value)
    else
        if type(addon.SetDB) == "function" then addon.SetDB(key, value) end
        if Echo.ApplyOptions then Echo.ApplyOptions() end
    end
    local dash = _G.HorizonSuiteDashboard
    if type(addon.Dashboard_Refresh) == "function" and dash and type(dash.IsShown) == "function" then
        local ok, shown = pcall(dash.IsShown, dash)
        if ok and not Echo.IsSecret(shown) and shown then pcall(addon.Dashboard_Refresh) end
    end
end

--- Ask for a reload with a popup: Reload or Later. Registered on first use.
function Menu.AskReload()
    if type(StaticPopupDialogs) ~= "table" or type(StaticPopup_Show) ~= "function" then return end
    local L = addon.L
    if not StaticPopupDialogs[Menu.RELOAD_POPUP] then
        StaticPopupDialogs[Menu.RELOAD_POPUP] = {
            text = L["ECHO_HIDE_CHAT_RELOAD"],
            button1 = L["RELOAD_UI"], button2 = L["ECHO_RELOAD_LATER"],
            timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
            OnAccept = function() if type(ReloadUI) == "function" then ReloadUI() end end,
        }
    end
    StaticPopup_Show(Menu.RELOAD_POPUP)
end

-- A checkbox bound to a boolean setting; after is run once the setting is written.
local function Checkbox(rootDescription, label, key, after)
    local function IsOn() return Echo.Setting(key) == true end
    rootDescription:CreateCheckbox(label, IsOn, function()
        SetSetting(key, not IsOn())
        if after then after() end
    end)
end

-- Hiding Blizzard's chat is never undone live: once it is switched off with a reload due
-- (the dashboard's flag, or hiding still applied), say so here rather than only on the
-- dashboard.
local function AfterHideChat()
    local hideChat = Echo.HideChat
    local applied = hideChat and hideChat.IsApplied and hideChat.IsApplied()
    -- Only on switching off: the popup's text is about bringing Blizzard's chat back.
    if Echo.Setting("echoHideBlizzardChat") == true then return end
    if addon._moduleReloadRecommended == true or applied then
        Menu.AskReload()
    end
end

--- Open the options on Echo's page: the dashboard's own module opener, after showing the
-- dashboard if it is shut (ShowOptions toggles, so it isn't called on an open one).
-- @return boolean opened
function Menu.OpenSettings()
    local dash = _G.HorizonSuiteDashboard
    local shown = dash and type(dash.IsShown) == "function" and dash:IsShown()
    if not shown then
        local show = addon.ShowOptions or _G.HorizonSuite_ShowOptions
        if type(show) ~= "function" then return false end
        pcall(show)
        dash = _G.HorizonSuiteDashboard
    end
    if dash and type(dash.OpenModule) == "function" then
        pcall(dash.OpenModule, addon.L["NAME_ADDON_CHAT"], "echo")
    end
    return true
end

--- Fill a MenuUtil root description for the Echo icon: Start a chat… (Echo.Compose's menu
-- as a submenu), Mark all as read, the collapse mode, Hide Blizzard chat, Lock position,
-- and Echo settings….
-- @param rootDescription table
function Menu.BuildIcon(rootDescription)
    local L = addon.L
    local start = rootDescription:CreateButton(L["ECHO_ICON_START"])
    if start and Echo.Compose then Echo.Compose.Build(start) end
    rootDescription:CreateButton(L["ECHO_ICON_MARK_READ"], function() Echo.Store.MarkAllRead() end)
    rootDescription:CreateDivider()
    rootDescription:CreateTitle(L["ECHO_COLLAPSE"])
    for _, choice in ipairs(COLLAPSE_CHOICES) do
        local value = choice[2]
        rootDescription:CreateRadio(L[choice[1]],
            function() return Echo.Collapse ~= nil and Echo.Collapse.Mode() == value end,
            function() SetSetting("echoCollapse", value) end)
    end
    Checkbox(rootDescription, L["ECHO_HIDE_CHAT"], "echoHideBlizzardChat", AfterHideChat)
    Checkbox(rootDescription, L["ECHO_LOCK"], "echoLockPosition")
    rootDescription:CreateDivider()
    rootDescription:CreateButton(L["ECHO_ICON_SETTINGS"], function() Menu.OpenSettings() end)
end

--- Open the Echo icon's menu (its right-click).
-- @param owner Frame  the Echo icon
-- @return boolean opened
function Menu.OpenIcon(owner)
    if not Menu.Available() then return false end
    local ok, menu = pcall(MenuUtil.CreateContextMenu, owner, function(_, rootDescription)
        Menu.BuildIcon(rootDescription)
    end)
    Opened(ok, menu)
    return ok
end
