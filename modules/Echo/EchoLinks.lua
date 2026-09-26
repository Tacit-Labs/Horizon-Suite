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

local function ShowTooltip(frame, link)
    if Echo.IsSecret(link) or type(link) ~= "string" or not GameTooltip then return end
    GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
    if pcall(GameTooltip.SetHyperlink, GameTooltip, link) then
        GameTooltip:Show()
    else
        GameTooltip:Hide()
    end
end

-- Report an error the way the game does, without letting it break the click.
local function Report(err)
    if type(geterrorhandler) ~= "function" then return end
    local handler = geterrorhandler()
    if type(handler) == "function" then pcall(handler, err) end
end

--- Make the links in a frame's text live: hover for the tooltip, click through the game's
-- own handler (so shift-click links and ctrl-click previews work as in Blizzard's chat).
-- @param frame Frame
function Links.Attach(frame)
    if frame.SetHyperlinksEnabled then frame:SetHyperlinksEnabled(true) end
    frame:SetScript("OnHyperlinkEnter", function(self, link) ShowTooltip(self, link) end)
    frame:SetScript("OnHyperlinkLeave", function() if GameTooltip then GameTooltip:Hide() end end)
    frame:SetScript("OnHyperlinkClick", function(self, link, text, button)
        if Echo.IsSecret(link) or type(link) ~= "string" or type(SetItemRef) ~= "function" then return end
        -- Blizzard's player and channel links read chatFrame.editBox, so hand over a real
        -- chat frame; the Echo frame is only the last resort.
        local chatFrame = DEFAULT_CHAT_FRAME or SELECTED_CHAT_FRAME or self
        local ok, err = pcall(SetItemRef, link, text, button, chatFrame)
        if not ok then Report(err) end
    end)
end
