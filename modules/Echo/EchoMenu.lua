--[[
    Horizon Suite - Echo - Menu
    The ⋯ menu on the card: pin, notification tier, close conversation. Its contents come
    from View.MenuSpec; this file turns them into Blizzard's context menu and runs the choice.
    Also the right-click menu on one message: pin or unpin it, or say why it can't be pinned,
    and whisper or invite the player who wrote it.
    Blizzard: MenuUtil.CreateContextMenu, C_PartyInfo.InviteUnit (or InviteUnit), IsInGroup,
    UnitIsGroupLeader, UnitIsGroupAssistant.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Menu = {}
Echo.Menu = Menu

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
function Menu.Build(rootDescription, convKey)
    local conv = Echo.Store.Get(convKey)
    if not conv then return end
    for _, entry in ipairs(Echo.View.MenuSpec(conv)) do
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
    local ok = pcall(MenuUtil.CreateContextMenu, owner, function(_, rootDescription)
        Menu.Build(rootDescription, convKey)
    end)
    return ok
end

-- The disabled button's text for each reason Store.PinMessage can refuse.
local BLOCKED = {
    secret  = "ECHO_PIN_BLOCKED_SECRET",
    chat    = "ECHO_PIN_BLOCKED_CHAT",
    total   = "ECHO_PIN_BLOCKED_TOTAL",
    unsaved = "ECHO_PIN_BLOCKED_UNSAVED",
}

-- The pin entry for one message: Pin message, Unpin message, or a disabled button saying
-- why it can't be pinned.
local function AddPinEntry(rootDescription, convKey, record)
    local Store = Echo.Store
    local L = addon.L
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
    local ok = pcall(MenuUtil.CreateContextMenu, owner, function(_, rootDescription)
        Menu.BuildMessage(rootDescription, convKey, record)
    end)
    return ok
end
