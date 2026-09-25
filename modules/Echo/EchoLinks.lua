--[[
    Horizon Suite - Echo - Links
    Shift-clicking an item, spell or achievement while an Echo reply box has focus puts the
    link into that box. The game's own link insertion is post-hooked (hooksecurefunc), so
    nothing of Blizzard's is replaced or tainted. Exactly one function is hooked, so a
    wrapper that calls the other can never insert a link twice.
    Blizzard: ChatFrameUtil.InsertLink (modern) or ChatEdit_InsertLink (older), hooksecurefunc.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Links = {}
Echo.Links = Links

local focused  -- the Echo reply box with keyboard focus, if any

--- An Echo reply box gained focus.
-- @param box EditBox
function Links.Focus(box)
    focused = box
end

--- An Echo reply box lost focus.
-- @param box EditBox
function Links.Blur(box)
    if focused == box then focused = nil end
end

--- Put a link into the focused Echo box.
-- @param text string
-- @return boolean inserted
function Links.Insert(text)
    -- A secret answers type() with "string" in game and can't be compared: refuse it first.
    if Echo.IsSecret(text) then return false end
    if not focused or type(text) ~= "string" or text == "" then return false end
    if focused.HasFocus and not focused:HasFocus() then
        focused = nil
        return false
    end
    focused:Insert(text)
    return true
end

--- Hook the game's link insertion, once.
function Links.Hook()
    if Links.hooked or type(hooksecurefunc) ~= "function" then return end
    if ChatFrameUtil and type(ChatFrameUtil.InsertLink) == "function" then
        hooksecurefunc(ChatFrameUtil, "InsertLink", function(text) Links.Insert(text) end)
        Links.hooked = true
    elseif type(ChatEdit_InsertLink) == "function" then
        hooksecurefunc("ChatEdit_InsertLink", function(text) Links.Insert(text) end)
        Links.hooked = true
    end
end
