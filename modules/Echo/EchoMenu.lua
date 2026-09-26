--[[
    Horizon Suite - Echo - Menu
    The ⋯ menu on the card: pin, notification tier, close conversation. Its contents come
    from View.MenuSpec; this file turns them into Blizzard's context menu and runs the choice.
    Also the right-click menu on one message: pin or unpin it, or say why it can't be pinned.
    Blizzard: MenuUtil.CreateContextMenu.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Menu = {}
Echo.Menu = Menu

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
        if target then
            local invite = C_PartyInfo and C_PartyInfo.InviteUnit
            if type(invite) ~= "function" then invite = _G.InviteUnit end
            if type(invite) == "function" then pcall(invite, target) end
        end
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

--- Fill a MenuUtil root description for one message: Pin message, Unpin message, or a
-- disabled button saying why it can't be pinned.
-- @param rootDescription table
-- @param convKey string
-- @param record table  the message's Store record
function Menu.BuildMessage(rootDescription, convKey, record)
    local Store = Echo.Store
    local L = addon.L
    if not convKey or type(record) ~= "table" then return end
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
