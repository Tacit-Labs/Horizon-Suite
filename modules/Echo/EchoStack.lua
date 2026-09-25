--[[
    Horizon Suite - Echo - Stack
    The peek stack beside the tile column: open conversations as cards, the chosen one on
    top showing its last few messages and a quick-reply box, the next ones peeking out
    behind it. The mouse wheel flips cards. Opens on hover, from the stack button, a tile,
    a toast or a keybind; closes when the mouse leaves unless the reply box has focus.
    Blizzard: CreateFrame, C_Timer, UISpecialFrames, UIPanelCloseButton.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo
local L = addon.L

local Stack = {}
Echo.Stack = Stack

Stack.WIDTH = 320
Stack.HEIGHT = 176
Stack.FAN = 10          -- px of each card behind that shows above the one in front
Stack.BEHIND = 2        -- cards drawn behind the top card
Stack.LINES = 3         -- messages on the top card
Stack.HOVER_CLOSE = 0.4

local root, card, edit, more
local behind = {}
local list, cursor = {}, 1
local currentKey            -- the card on top follows its conversation, not its position
local openTimer, closeTimer

local function Paint(frame, alpha)
    local bg, border = Echo.View.PANEL_BG, Echo.View.PANEL_BORDER
    frame:SetBackdrop(Echo.FLAT)
    frame:SetBackdropColor(bg[1], bg[2], bg[3], alpha or bg[4])
    frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
end

local function FontPath()
    return (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"
end

local function CreateEdit()
    edit = CreateFrame("EditBox", nil, card, "BackdropTemplate")
    edit:SetHeight(26)
    edit:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 12, 12)
    edit:SetBackdrop(Echo.FLAT)
    edit:SetBackdropColor(0.03, 0.03, 0.05, 0.95)
    edit:SetBackdropBorderColor(0.28, 0.30, 0.38, 0.65)
    edit:SetFont(FontPath(), 12, "")
    edit:SetTextInsets(8, 8, 0, 0)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(1020)
    edit.placeholder = Echo.NewText(edit, 12, "")
    edit.placeholder:SetPoint("LEFT", edit, "LEFT", 8, 0)
    edit.placeholder:SetTextColor(0.5, 0.52, 0.6, 1)
    edit:SetScript("OnEnterPressed", function(self)
        local text = self:GetText()
        local conv = list[cursor]
        if text == "" or not conv then
            self:ClearFocus()
            return
        end
        Echo.Send.Send(conv.key, text)
        self:SetText("")
    end)
    edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    edit:SetScript("OnEditFocusGained", function(self) self.placeholder:Hide() end)
    edit:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then self.placeholder:Show() end
        Stack.HoverLeave()
    end)
    -- A keybind that focuses the box must not type its own key into it.
    edit:SetScript("OnChar", function(self)
        if self.swallow then
            self.swallow = false
            self:SetText("")
        end
    end)
end

local function Create()
    root = CreateFrame("Frame", "HorizonSuiteEchoStack", UIParent)
    root:SetSize(Stack.WIDTH, Stack.HEIGHT + Stack.FAN * Stack.BEHIND + 18)
    root:SetClampedToScreen(true)
    root:EnableMouse(true)
    root:EnableMouseWheel(true)
    root:Hide()
    root:SetScript("OnMouseWheel", function(_, delta) Stack.Flip(-delta) end)
    root:SetScript("OnEnter", function() Stack.HoverEnter() end)
    root:SetScript("OnLeave", function() Stack.HoverLeave() end)
    table.insert(UISpecialFrames, "HorizonSuiteEchoStack")

    for i = 1, Stack.BEHIND do
        local b = CreateFrame("Frame", nil, root, "BackdropTemplate")
        Paint(b, 0.9)
        b:SetSize(Stack.WIDTH - 16 * i, Stack.HEIGHT)
        b:SetPoint("BOTTOM", root, "BOTTOM", 0, Stack.FAN * i)
        b:SetFrameLevel(root:GetFrameLevel() + Stack.BEHIND - i + 1)
        b.name = Echo.NewText(b, 10)
        b.name:SetPoint("TOPLEFT", b, "TOPLEFT", 10, -1)
        behind[i] = b
    end

    card = CreateFrame("Frame", nil, root, "BackdropTemplate")
    Paint(card)
    card:SetSize(Stack.WIDTH, Stack.HEIGHT)
    card:SetPoint("BOTTOM", root, "BOTTOM", 0, 0)
    card:SetFrameLevel(root:GetFrameLevel() + Stack.BEHIND + 1)
    card:EnableMouse(true)

    local a = Echo.View.ACCENT
    local rule = card:CreateTexture(nil, "OVERLAY")
    rule:SetColorTexture(a.r, a.g, a.b, 1)
    rule:SetHeight(2)
    rule:SetPoint("TOPLEFT", card, "TOPLEFT", 0, 0)
    rule:SetPoint("TOPRIGHT", card, "TOPRIGHT", 0, 0)

    card.tile = card:CreateTexture(nil, "ARTWORK")
    card.tile:SetSize(28, 28)
    card.tile:SetPoint("TOPLEFT", card, "TOPLEFT", 12, -12)
    card.letter = Echo.NewText(card, 14, "")
    card.letter:SetPoint("CENTER", card.tile, "CENTER", 0, 0)
    card.name = Echo.NewText(card, 13)
    card.name:SetPoint("TOPLEFT", card.tile, "TOPRIGHT", 8, 0)
    card.name:SetPoint("RIGHT", card, "RIGHT", -34, 0)
    card.name:SetJustifyH("LEFT")
    card.name:SetWordWrap(false)
    card.meta = Echo.NewText(card, 10, "")
    card.meta:SetPoint("TOPLEFT", card.name, "BOTTOMLEFT", 0, -3)
    card.meta:SetTextColor(0.55, 0.60, 0.75, 1)

    card.close = CreateFrame("Button", nil, card, "UIPanelCloseButton")
    card.close:SetPoint("TOPRIGHT", card, "TOPRIGHT", -2, -2)
    card.close:SetScript("OnClick", function() Stack.CloseCurrent() end)

    card.lines = {}
    for i = 1, Stack.LINES do
        local fs = Echo.NewText(card, 12, "")
        fs:SetWidth(Stack.WIDTH - 24)
        fs:SetJustifyH("LEFT")
        fs:SetWordWrap(true)
        fs:SetMaxLines(2)
        if i == 1 then
            fs:SetPoint("TOPLEFT", card, "TOPLEFT", 12, -52)
        else
            fs:SetPoint("TOPLEFT", card.lines[i - 1], "BOTTOMLEFT", 0, -3)
        end
        card.lines[i] = fs
    end

    CreateEdit()

    card.open = CreateFrame("Button", nil, card, "BackdropTemplate")
    card.open:SetSize(60, 26)
    card.open:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -12, 12)
    Paint(card.open)
    card.open.text = Echo.NewText(card.open, 12, "")
    card.open.text:SetPoint("CENTER", card.open, "CENTER", 0, 0)
    card.open.text:SetText(L["ECHO_OPEN"])
    card.open:SetScript("OnClick", function()
        local conv = list[cursor]
        if conv and Echo.Card then
            Stack.Hide()
            Echo.Card.Open(conv.key)
        end
    end)

    more = Echo.NewText(root, 10, "")
    more:SetPoint("BOTTOMRIGHT", root, "TOPRIGHT", 0, -12)
    more:SetTextColor(0.55, 0.60, 0.75, 1)
end

--- Redraw the stack from the Store around the current card, and mark that card read.
function Stack.Render()
    if not root or not root:IsShown() then return end
    local View = Echo.View
    list = Echo.Store.List()
    if #list == 0 then
        Stack.Hide()
        return
    end
    -- Replying moves a conversation up the list; keep the same card on top.
    if currentKey then
        for i, c in ipairs(list) do
            if c.key == currentKey then
                cursor = i
                break
            end
        end
    end
    cursor = math.max(1, math.min(cursor, #list))
    local conv = list[cursor]
    currentKey = conv.key
    local spec = View.TileSpec(conv)

    if spec.glyph then
        local bg = View.GLYPH_BG
        card.tile:SetColorTexture(bg[1], bg[2], bg[3], 1)
        card.letter:SetTextColor(spec.r, spec.g, spec.b, 1)
    else
        card.tile:SetColorTexture(spec.r, spec.g, spec.b, 1)
        card.letter:SetTextColor(0.05, 0.05, 0.07, 1)
    end
    card.letter:SetText(spec.letter)
    card.name:SetText(View.DisplayName(conv))
    card.name:SetTextColor(spec.r, spec.g, spec.b, 1)
    card.meta:SetText(View.MetaLine(conv, Echo.Store.Now()):upper())

    local recent = View.Recent(conv, Stack.LINES)
    local r, g, b = View.ChatColor(conv.kind)
    for i = 1, Stack.LINES do
        local fs, msg = card.lines[i], recent[i]
        if msg then
            fs:SetText(View.LineText(conv, msg))
            if msg.status == "failed" then
                fs:SetTextColor(1, 0.35, 0.35, 1)
            elseif msg.status == "pending" then
                fs:SetTextColor(0.6, 0.62, 0.7, 1)
            elseif msg.outgoing then
                fs:SetTextColor(0.85, 0.87, 0.95, 1)
            else
                fs:SetTextColor(r, g, b, 1)
            end
            fs:Show()
        else
            fs:SetText("")
            fs:Hide()
        end
    end

    local canOpen = Echo.Card ~= nil
    card.open:SetShown(canOpen)
    edit:SetWidth(Stack.WIDTH - 24 - (canOpen and 68 or 0))
    edit.placeholder:SetText(L["ECHO_QUICK_REPLY"])
    edit.placeholder:SetShown(edit:GetText() == "" and not edit:HasFocus())

    for i = 1, Stack.BEHIND do
        local other = list[cursor + i]
        if other then
            local ospec = View.TileSpec(other)
            behind[i].name:SetText(View.DisplayName(other))
            behind[i].name:SetTextColor(ospec.r, ospec.g, ospec.b, 1)
            behind[i]:Show()
        else
            behind[i]:Hide()
        end
    end
    local hidden = #list - cursor - Stack.BEHIND
    if hidden > 0 then
        more:SetText(L["ECHO_MORE"]:format(hidden))
    else
        more:SetText(#list > 1 and L["ECHO_SCROLL_HINT"] or "")
    end

    Echo.Store.MarkRead(conv.key)
end

local function Anchor()
    local column = _G.HorizonSuiteEchoColumn
    root:ClearAllPoints()
    if column then
        root:SetScale(column:GetScale())
        root:SetFrameStrata(column:GetFrameStrata())
        root:SetFrameLevel(column:GetFrameLevel() + 10)
        root:SetPoint("BOTTOMRIGHT", column, "BOTTOMLEFT", -8, 0)
    else
        root:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

local function CancelTimer(timer)
    if timer then timer:Cancel() end
end

--- Open the stack.
-- @param convKey string|nil  Card to put on top; nil for the first conversation
-- @param focus boolean|nil  Focus the quick-reply box
function Stack.Open(convKey, focus)
    if not root then Create() end
    local conversations = Echo.Store.List()
    if #conversations == 0 then return end
    cursor = 1
    if convKey then
        for i, conv in ipairs(conversations) do
            if conv.key == convKey then
                cursor = i
                break
            end
        end
    end
    currentKey = conversations[cursor].key
    CancelTimer(closeTimer)
    closeTimer = nil
    Anchor()
    root:Show()
    Stack.Render()
    if focus then
        edit:SetFocus()
        edit.swallow = true
        C_Timer.After(0, function() if edit then edit.swallow = false end end)
    end
end

function Stack.Hide()
    CancelTimer(openTimer)
    CancelTimer(closeTimer)
    openTimer, closeTimer = nil, nil
    if edit then edit:ClearFocus() end
    if root then root:Hide() end
end

function Stack.Toggle()
    if root and root:IsShown() then
        Stack.Hide()
    else
        Stack.Open(nil)
    end
end

--- Keybind: open on the conversation with the newest loud message, reply box focused.
function Stack.ReplyToNewest()
    local newest = Echo.View.NewestLoud(Echo.Store.List())
    if newest then Stack.Open(newest.key, true) end
end

--- Move to another card (the mouse wheel).
-- @param step number  +1 for the next card, -1 for the previous
function Stack.Flip(step)
    if not root or not root:IsShown() then return end
    cursor = math.max(1, math.min(cursor + step, #list))
    currentKey = list[cursor] and list[cursor].key
    Stack.Render()
end

--- The × on the top card: close that conversation (its tile goes too).
function Stack.CloseCurrent()
    local conv = list[cursor]
    if conv then Echo.Store.Close(conv.key) end
end

local function MouseOverEcho()
    local column = _G.HorizonSuiteEchoColumn
    if root and root:IsShown() and root:IsMouseOver() then return true end
    return column ~= nil and column:IsShown() and column:IsMouseOver()
end

--- The mouse entered the column or the stack: open after the hover delay (not in combat).
function Stack.HoverEnter()
    CancelTimer(closeTimer)
    closeTimer = nil
    if (root and root:IsShown()) or openTimer or InCombatLockdown() then return end
    local delay = tonumber(Echo.Setting("echoHoverDelay")) or 0.35
    openTimer = C_Timer.NewTimer(delay, function()
        openTimer = nil
        if MouseOverEcho() then Stack.Open(nil) end
    end)
end

--- The mouse left: close shortly unless it came back or the reply box has focus.
function Stack.HoverLeave()
    if openTimer and not MouseOverEcho() then
        openTimer:Cancel()
        openTimer = nil
    end
    if not root or not root:IsShown() then return end
    CancelTimer(closeTimer)
    closeTimer = C_Timer.NewTimer(Stack.HOVER_CLOSE, function()
        closeTimer = nil
        if not MouseOverEcho() and not (edit and edit:HasFocus()) then Stack.Hide() end
    end)
end

function Stack.OnStoreChange()
    if root and root:IsShown() then Stack.Render() end
end

function Stack.Enable()
    if not root then Create() end
    if not Stack.subscribed then
        Echo.Store.Subscribe(Stack.OnStoreChange)
        Stack.subscribed = true
    end
end

function Stack.Disable()
    if Stack.subscribed then
        Echo.Store.Unsubscribe(Stack.OnStoreChange)
        Stack.subscribed = false
    end
    Stack.Hide()
end

-- Test and debug handle.
function Stack._frames()
    return { root = root, card = card, edit = edit, more = more, behind = behind }
end
