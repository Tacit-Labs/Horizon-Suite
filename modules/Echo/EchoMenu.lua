--[[
    Horizon Suite - Echo - Menu
    The ⋯ menu on the card: pin, notification tier, close conversation. Its contents come
    from View.MenuSpec; this file turns them into Blizzard's context menu and runs the choice.
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
-- @param action string  "pin" | "tier" | "close"
-- @param value string|nil  the tier for "tier" ("default" clears the override)
function Menu.Run(convKey, action, value)
    local Store = Echo.Store
    if action == "pin" then
        local conv = Store.Get(convKey)
        if conv then Store.SetPinned(convKey, not conv.pinned) end
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
    MenuUtil.CreateContextMenu(owner, function(_, rootDescription) Menu.Build(rootDescription, convKey) end)
    return true
end
