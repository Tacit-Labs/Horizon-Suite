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
local renderedKey           -- the conversation last drawn onto the shared reply box
local openTimer
local hoverKey              -- the tile hovered last while the open delay runs
local armed, away, pollAccum = false, 0, 0   -- hover-close poll state

local function Paint(frame, alpha)
    local bg, border = Echo.View.PANEL_BG, Echo.View.PANEL_BORDER
    frame:SetBackdrop(Echo.FLAT)
    frame:SetBackdropColor(bg[1], bg[2], bg[3], alpha or bg[4])
    frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
end

local function FontPath()
    return (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"
end

-- Park the shared reply box's draft against the conversation it was drawn for, and clear
-- it. Idempotent (renderedKey is nil after the first call), called from both root's OnHide
-- (covers closes that bypass Stack.Hide, e.g. Escape via UISpecialFrames calling
-- root:Hide() directly) and Stack.Hide itself (stand-in frames in tests don't fire OnHide
-- on Hide()).
local function ParkDraft()
    if edit and renderedKey then
        Echo.ParkDraft(renderedKey, edit:GetText())
        edit:SetText("")
        renderedKey = nil
    end
end

-- Declared here (ahead of Create/Open) so root's OnUpdate poll and Open's arming check
-- can see it as a lexical upvalue rather than a stale forward reference.
local function MouseOverEcho()
    local column = _G.HorizonSuiteEchoColumn
    if root and root:IsShown() and root:IsMouseOver() then return true end
    return column ~= nil and column:IsShown() and column:IsMouseOver()
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
        -- A send that can't route keeps its text in the box, so nothing typed is lost.
        if Echo.Send.Send(conv.key, text) then self:SetText("") end
    end)
    edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    edit:SetScript("OnEditFocusGained", function(self)
        self.placeholder:Hide()
        if Echo.Links then Echo.Links.Focus(self) end
    end)
    edit:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then self.placeholder:Show() end
        if Echo.Links then Echo.Links.Blur(self) end
        Stack.HoverLeave()
    end)
    -- A keybind that focuses the box must not type its own key into it; restore whatever
    -- draft was there before the keybind stole focus, rather than wiping it.
    edit:SetScript("OnChar", function(self)
        if self.swallow then
            self.swallow = false
            self:SetText(self.beforeSwallow or "")
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
    -- Closing on mouse-leave can't be event-driven: card/edit/buttons are mouse-enabled
    -- children with no OnEnter/OnLeave of their own, so root's OnLeave fires the instant the
    -- mouse crosses onto any of them and nothing fires when it later leaves those children.
    -- Poll instead: once armed (the mouse has been over Echo since this open), track how
    -- long it's been continuously away and close after HOVER_CLOSE seconds of that.
    root:SetScript("OnUpdate", function(_, elapsed)
        pollAccum = pollAccum + elapsed
        if pollAccum < 0.1 then return end
        local dt = pollAccum
        pollAccum = 0
        local over = MouseOverEcho()
        local focused = edit and edit:HasFocus()
        if over then armed = true end
        if over or focused then
            away = 0
        elseif armed then
            away = away + dt
            if away >= Stack.HOVER_CLOSE then
                Stack.Hide()
            end
        end
    end)
    root:SetScript("OnHide", function()
        -- Covers closes that bypass Stack.Hide entirely, e.g. Escape via UISpecialFrames
        -- calling root:Hide() directly: leave no pending open timer, stuck focus, or a
        -- stale draft behind.
        if openTimer then
            openTimer:Cancel()
            openTimer = nil
        end
        ParkDraft()
        if edit then edit:ClearFocus() end
    end)
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
    if Echo.Links then Echo.Links.Attach(card) end

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

    -- A flat × drawn from two thin bars, in the card's own grey; brighter on hover.
    card.close = CreateFrame("Button", nil, card)
    card.close:SetSize(20, 20)
    card.close:SetPoint("TOPRIGHT", card, "TOPRIGHT", -8, -8)
    card.close.bars = {}
    for i, angle in ipairs({ math.pi / 4, -math.pi / 4 }) do
        local bar = card.close:CreateTexture(nil, "ARTWORK")
        bar:SetSize(12, 2)
        bar:SetPoint("CENTER", card.close, "CENTER", 0, 0)
        bar:SetColorTexture(0.55, 0.60, 0.75, 1)
        bar:SetRotation(angle)
        card.close.bars[i] = bar
    end
    local function TintClose(r, g, b)
        for _, bar in ipairs(card.close.bars) do bar:SetColorTexture(r, g, b, 1) end
    end
    card.close:SetScript("OnEnter", function() TintClose(0.95, 0.96, 1) end)
    card.close:SetScript("OnLeave", function() TintClose(0.55, 0.60, 0.75) end)
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
    if renderedKey ~= conv.key then
        -- The reply box is shared by whichever card is on top: park the old card's draft
        -- and bring back the new card's, so a draft never bleeds onto another conversation.
        if renderedKey then Echo.ParkDraft(renderedKey, edit:GetText()) end
        edit:SetText(Echo.TakeDraft(conv.key))
    end
    renderedKey = conv.key
    currentKey = conv.key
    local spec = View.TileSpec(conv)

    if spec.icon then
        card.tile:SetTexture(spec.icon)
        card.tile:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        card.letter:SetText("")
    elseif spec.glyph then
        local bg = View.GLYPH_BG
        card.tile:SetColorTexture(bg[1], bg[2], bg[3], 1)
        card.letter:SetTextColor(spec.r, spec.g, spec.b, 1)
        card.letter:SetText(spec.letter)
    else
        card.tile:SetColorTexture(spec.r, spec.g, spec.b, 1)
        card.letter:SetTextColor(0.05, 0.05, 0.07, 1)
        card.letter:SetText(spec.letter)
    end
    card.name:SetText(View.DisplayName(conv))
    card.name:SetTextColor(spec.r, spec.g, spec.b, 1)
    card.meta:SetText(View.MetaLine(conv, Echo.Store.Now()):upper())

    local recent = View.Recent(conv, Stack.LINES)
    for i = 1, Stack.LINES do
        local fs, msg = card.lines[i], recent[i]
        if msg then
            fs:SetText(View.LineText(conv, msg))
            -- Your lines on the right and dimmer, like sent bubbles; theirs on the left.
            fs:SetJustifyH(msg.outgoing and "RIGHT" or "LEFT")
            if msg.status == "failed" then
                fs:SetTextColor(1, 0.35, 0.35, 1)
            elseif msg.status == "pending" then
                fs:SetTextColor(0.55, 0.57, 0.65, 1)
            elseif msg.outgoing then
                fs:SetTextColor(0.72, 0.74, 0.82, 1)
            else
                local lr, lg, lb = View.LineColor(conv, msg)
                fs:SetTextColor(lr, lg, lb, 1)
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

    -- Feeds are read-only: no reply box.
    edit:SetShown(not View.IsFeed(conv.kind))

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
    -- root's own level just moved (e.g. above a raised column); re-assert the card stack's
    -- levels relative to it so the top card and its behind-cards stay correctly ordered.
    for i = 1, Stack.BEHIND do
        behind[i]:SetFrameLevel(root:GetFrameLevel() + Stack.BEHIND - i + 1)
    end
    card:SetFrameLevel(root:GetFrameLevel() + Stack.BEHIND + 1)
end

local function CancelTimer(timer)
    if timer then timer:Cancel() end
end

--- Open the stack.
-- @param convKey string|nil  Card to put on top; nil for the first conversation
-- @param focus boolean|nil  Focus the quick-reply box
function Stack.Open(convKey, focus)
    if not root then Create() end
    if Echo.Card then Echo.Card.Hide() end
    -- A click or keybind during the hover delay wins: the pending hover open must not
    -- fire afterwards and replace the card that was asked for.
    CancelTimer(openTimer)
    openTimer = nil
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
    Anchor()
    root:Show()
    -- Arm the hover-close poll immediately if the mouse is already over Echo (a hover-open);
    -- otherwise a keybind/click open with the mouse elsewhere must stay put until the
    -- director dismisses it explicitly (Escape/toggle/close), never auto-close underneath them.
    armed = MouseOverEcho()
    away = 0
    pollAccum = 0
    Stack.Render()
    if focus then
        edit.beforeSwallow = edit:GetText()
        edit:SetFocus()
        edit.swallow = true
        C_Timer.After(0, function() if edit then edit.swallow = false end end)
    end
end

function Stack.Hide()
    CancelTimer(openTimer)
    openTimer = nil
    armed = false
    away = 0
    -- Park the draft so the card, or the stack when it reopens, can take it back. root's
    -- OnHide does this too (real frames fire it from Hide()); calling it here as well
    -- keeps the harness's stand-in frames, which don't fire OnHide on Hide(), correct.
    ParkDraft()
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

--- Keybind: open on the conversation with the newest incoming loud message, reply box
-- focused. With the card open, the card switches to it instead and focuses its own box.
function Stack.ReplyToNewest()
    local newest = Echo.View.NewestIncomingLoud(Echo.Store.List())
    if not newest then return end
    if Echo.Card and Echo.Card.IsShown() then
        Echo.Card.Show(newest.key)
        Echo.Card.Focus()
        return
    end
    Stack.Open(newest.key, true)
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

--- The mouse entered the column or the stack: open after the hover delay (not in combat).
--- Bring a conversation to the front of an open stack.
-- @param convKey string
function Stack.Select(convKey)
    if not root or not root:IsShown() or not convKey or convKey == currentKey then return end
    currentKey = convKey
    Stack.Render()
end

--- The mouse entered a tile, the chat button or the stack. On a closed stack, open after
-- the hover delay on the last tile hovered (the top card for the chat button); on an open
-- stack, hovering a tile brings its conversation to the front at once. Not in combat.
-- @param convKey string|nil  The hovered tile's conversation
function Stack.HoverEnter(convKey)
    if Echo.Card and Echo.Card.IsShown() then return end
    if root and root:IsShown() then
        Stack.Select(convKey)
        return
    end
    if InCombatLockdown() then return end
    hoverKey = convKey
    if openTimer then return end
    local delay = tonumber(Echo.Setting("echoHoverDelay")) or 0.35
    openTimer = C_Timer.NewTimer(delay, function()
        openTimer = nil
        if root and root:IsShown() then return end
        if MouseOverEcho() then Stack.Open(hoverKey) end
    end)
end

--- The mouse left before the open timer fired: cancel it. Closing once already open is the
-- OnUpdate poll's job now (see Create), since child frames swallow root's own OnLeave.
function Stack.HoverLeave()
    if openTimer and not MouseOverEcho() then
        openTimer:Cancel()
        openTimer = nil
    end
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
    Echo.ClearDrafts()
    renderedKey = nil
    if edit then edit:SetText("") end
end

-- Test and debug handle.
function Stack._frames()
    return { root = root, card = card, edit = edit, more = more, behind = behind }
end
