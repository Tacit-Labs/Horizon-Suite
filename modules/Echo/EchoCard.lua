--[[
    Horizon Suite - Echo - Card
    The expanded card: one conversation in full. A row of tiles for the open conversations
    across the top (the current one outlined), the ⋯ menu and a collapse chevron; the name
    with class, relationship and online status; message bubbles, theirs on the left and
    yours on the right; a status line under your newest message; and a reply box with a
    send button. Opened by clicking a tile, a toast, or the stack's Open button.
    Bubbles are laid out newest-first from the bottom of a clipped area and the wheel
    scrolls by message. Readable text is measured; a secret gets the widest bubble and a
    fixed three lines, so nothing ever reads a size from a FontString holding a secret.
    Blizzard: CreateFrame, UISpecialFrames, MenuUtil (through Echo.Menu).
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo
local L = addon.L

local Card = {}
Echo.Card = Card

Card.WIDTH = 360
Card.HEIGHT = 440
Card.AREA_TOP = 92        -- message area starts this far below the top
Card.AREA_BOTTOM = 52     -- and stops this far above the bottom
Card.AREA_HEIGHT = Card.HEIGHT - Card.AREA_TOP - Card.AREA_BOTTOM
Card.TILES = 8
Card.TILE = 26
Card.PAD = 12
Card.BUBBLE_PAD = 8
Card.BUBBLE_MAX = 250
Card.GAP = 3
Card.GROUP_GAP = 10
Card.SECRET_LINES = 3
Card.LINE_HEIGHT = 14

local root, nameText, metaText, area, edit, send, menuButton, chevron, statusLine
local rowTiles, bubbles, labels = {}, {}, {}
local currentKey, renderedKey
local offset = 0  -- newest messages scrolled past

-- Park the reply box's draft against the conversation it was drawn for, and clear it.
-- Idempotent (renderedKey is nil after the first call), called from both root's OnHide
-- (covers closes that bypass Card.Hide, e.g. Escape via UISpecialFrames calling
-- root:Hide() directly) and Card.Hide itself (stand-in frames in tests don't fire OnHide
-- on Hide()).
local function ParkDraft()
    if edit and renderedKey then
        Echo.ParkDraft(renderedKey, edit:GetText())
        edit:SetText("")
        renderedKey = nil
    end
end

local function FontPath()
    return (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"
end

local function Paint(frame, bg, border)
    frame:SetBackdrop(Echo.FLAT)
    frame:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
    frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
end

-- A flat glyph drawn from thin bars; returns them so hover can tint them.
local function Glyph(button, parts)
    button.bars = {}
    for i, part in ipairs(parts) do
        local bar = button:CreateTexture(nil, "ARTWORK")
        bar:SetSize(part.w, part.h)
        bar:SetPoint("CENTER", button, "CENTER", part.x or 0, part.y or 0)
        bar:SetColorTexture(0.55, 0.60, 0.75, 1)
        if part.angle then bar:SetRotation(part.angle) end
        button.bars[i] = bar
    end
    local function Tint(r, g, b)
        for _, bar in ipairs(button.bars) do bar:SetColorTexture(r, g, b, 1) end
    end
    button:SetScript("OnEnter", function() Tint(0.95, 0.96, 1) end)
    button:SetScript("OnLeave", function() Tint(0.55, 0.60, 0.75) end)
end

local function PaintTile(b, spec)
    local View = Echo.View
    b.letter:SetText(spec.letter)
    if spec.glyph then
        local bg = View.GLYPH_BG
        b:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
        b.letter:SetTextColor(spec.r, spec.g, spec.b, 1)
    else
        b:SetBackdropColor(spec.r, spec.g, spec.b, 0.95)
        b.letter:SetTextColor(0.05, 0.05, 0.07, 1)
    end
end

local function Create()
    local View = Echo.View
    local a = View.ACCENT
    root = CreateFrame("Frame", "HorizonSuiteEchoCard", UIParent, "BackdropTemplate")
    root:SetSize(Card.WIDTH, Card.HEIGHT)
    root:SetClampedToScreen(true)
    root:EnableMouse(true)
    root:Hide()
    Paint(root, View.PANEL_BG, View.PANEL_BORDER)
    table.insert(UISpecialFrames, "HorizonSuiteEchoCard")
    root:SetScript("OnHide", function()
        -- Covers closes that bypass Card.Hide entirely, e.g. Escape via UISpecialFrames
        -- calling root:Hide() directly: leave no stale draft or stuck focus behind.
        ParkDraft()
        if edit then edit:ClearFocus() end
    end)

    local rule = root:CreateTexture(nil, "OVERLAY")
    rule:SetColorTexture(a.r, a.g, a.b, 1)
    rule:SetHeight(2)
    rule:SetPoint("TOPLEFT", root, "TOPLEFT", 0, 0)
    rule:SetPoint("TOPRIGHT", root, "TOPRIGHT", 0, 0)

    chevron = CreateFrame("Button", nil, root)
    chevron:SetSize(22, 22)
    chevron:SetPoint("TOPRIGHT", root, "TOPRIGHT", -8, -12)
    Glyph(chevron, {
        { w = 8, h = 2, x = -3, y = 1, angle = -math.pi / 4 },
        { w = 8, h = 2, x = 3, y = 1, angle = math.pi / 4 },
    })
    chevron:SetScript("OnClick", function() Card.Hide() end)

    menuButton = CreateFrame("Button", nil, root)
    menuButton:SetSize(22, 22)
    menuButton:SetPoint("RIGHT", chevron, "LEFT", -4, 0)
    Glyph(menuButton, {
        { w = 3, h = 3, x = -5 },
        { w = 3, h = 3, x = 0 },
        { w = 3, h = 3, x = 5 },
    })
    menuButton:SetScript("OnClick", function(self)
        if currentKey and Echo.Menu then Echo.Menu.Open(self, currentKey) end
    end)

    for i = 1, Card.TILES do
        local b = CreateFrame("Button", nil, root, "BackdropTemplate")
        b:SetSize(Card.TILE, Card.TILE)
        b:SetPoint("TOPLEFT", root, "TOPLEFT", Card.PAD + (i - 1) * (Card.TILE + 6), -10)
        b:SetBackdrop(Echo.FLAT)
        b.letter = Echo.NewText(b, 12, "")
        b.letter:SetPoint("CENTER", b, "CENTER", 0, 0)
        b.dot = b:CreateTexture(nil, "OVERLAY")
        b.dot:SetSize(6, 6)
        b.dot:SetPoint("TOPRIGHT", b, "TOPRIGHT", 2, 2)
        b.dot:SetColorTexture(a.r, a.g, a.b, 1)
        b:RegisterForClicks("LeftButtonUp")
        b:SetScript("OnClick", function(self)
            if self.convKey then Card.Show(self.convKey) end
        end)
        b:Hide()
        rowTiles[i] = b
    end

    local divider = root:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(View.PANEL_BORDER[1], View.PANEL_BORDER[2], View.PANEL_BORDER[3], View.PANEL_BORDER[4])
    divider:SetHeight(1)
    divider:SetPoint("TOPLEFT", root, "TOPLEFT", Card.PAD, -44)
    divider:SetPoint("TOPRIGHT", root, "TOPRIGHT", -Card.PAD, -44)

    nameText = Echo.NewText(root, 15)
    nameText:SetPoint("TOPLEFT", root, "TOPLEFT", Card.PAD, -54)
    nameText:SetPoint("RIGHT", root, "RIGHT", -Card.PAD, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    metaText = Echo.NewText(root, 10, "")
    metaText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -4)
    metaText:SetTextColor(0.55, 0.60, 0.75, 1)

    area = CreateFrame("Frame", nil, root)
    area:SetPoint("TOPLEFT", root, "TOPLEFT", Card.PAD, -Card.AREA_TOP)
    area:SetPoint("BOTTOMRIGHT", root, "BOTTOMRIGHT", -Card.PAD, Card.AREA_BOTTOM)
    area:SetClipsChildren(true)
    area:EnableMouseWheel(true)
    area:SetScript("OnMouseWheel", function(_, delta) Card.Scroll(delta) end)

    statusLine = CreateFrame("Button", nil, area)
    statusLine:SetSize(180, 14)
    statusLine.text = Echo.NewText(statusLine, 10, "")
    statusLine.text:SetPoint("RIGHT", statusLine, "RIGHT", 0, 0)
    statusLine:RegisterForClicks("LeftButtonUp")
    statusLine:SetScript("OnClick", function(self)
        if self.retry then Card.Retry(self.retry) end
    end)
    statusLine:Hide()

    send = CreateFrame("Button", nil, root, "BackdropTemplate")
    send:SetSize(30, 30)
    send:SetPoint("BOTTOMRIGHT", root, "BOTTOMRIGHT", -Card.PAD, 12)
    Paint(send, { a.r, a.g, a.b, 0.9 }, { a.r, a.g, a.b, 1 })
    send.text = Echo.NewText(send, 14, "")
    send.text:SetPoint("CENTER", send, "CENTER", 1, 0)
    send.text:SetText(">")
    send.text:SetTextColor(0.05, 0.05, 0.07, 1)
    send:RegisterForClicks("LeftButtonUp")
    send:SetScript("OnClick", function() Card.Submit() end)

    edit = CreateFrame("EditBox", nil, root, "BackdropTemplate")
    edit:SetHeight(30)
    edit:SetPoint("BOTTOMLEFT", root, "BOTTOMLEFT", Card.PAD, 12)
    edit:SetPoint("BOTTOMRIGHT", send, "BOTTOMLEFT", -6, 0)
    Paint(edit, { 0.03, 0.03, 0.05, 0.95 }, View.PANEL_BORDER)
    edit:SetFont(FontPath(), 12, "")
    edit:SetTextInsets(8, 8, 0, 0)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(1020)
    edit.placeholder = Echo.NewText(edit, 12, "")
    edit.placeholder:SetPoint("LEFT", edit, "LEFT", 8, 0)
    edit.placeholder:SetTextColor(0.5, 0.52, 0.6, 1)
    edit:SetScript("OnEnterPressed", function(self)
        if self:GetText() == "" then
            self:ClearFocus()
        else
            Card.Submit()
        end
    end)
    edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    edit:SetScript("OnEditFocusGained", function(self)
        self.placeholder:Hide()
        if Echo.Links then Echo.Links.Focus(self) end
    end)
    edit:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then self.placeholder:Show() end
        if Echo.Links then Echo.Links.Blur(self) end
    end)
    edit:SetScript("OnTextChanged", function(self)
        if self:GetText() ~= "" then
            self.placeholder:Hide()
        elseif not self:HasFocus() then
            self.placeholder:Show()
        end
    end)
end

local function Bubble(i)
    local b = bubbles[i]
    if b then return b end
    b = CreateFrame("Frame", nil, area, "BackdropTemplate")
    b:SetBackdrop(Echo.FLAT)
    b.text = Echo.NewText(b, 12, "")
    b.text:SetPoint("TOPLEFT", b, "TOPLEFT", Card.BUBBLE_PAD, -Card.BUBBLE_PAD)
    b.text:SetJustifyH("LEFT")
    b.text:SetJustifyV("TOP")
    b.text:SetWordWrap(true)
    b.text:SetNonSpaceWrap(true)
    bubbles[i] = b
    return b
end

local function Label(i)
    local fs = labels[i]
    if fs then return fs end
    fs = Echo.NewText(area, 10)
    fs:SetJustifyH("LEFT")
    labels[i] = fs
    return fs
end

-- Size a bubble to its text and return its height. Readable text is measured; a secret
-- can't be, so it gets the widest bubble and a fixed number of lines.
local function SizeBubble(b, text, secret)
    local inner = Card.BUBBLE_MAX - Card.BUBBLE_PAD * 2
    b.text:SetWidth(inner)
    b.text:SetMaxLines(secret and Card.SECRET_LINES or 0)
    b.text:SetText(text)
    local width, height
    if secret then
        width = Card.BUBBLE_MAX
        height = Card.SECRET_LINES * Card.LINE_HEIGHT
    else
        local measured
        if b.text.GetUnboundedStringWidth then measured = b.text:GetUnboundedStringWidth() end
        if Echo.IsSecret(measured) or type(measured) ~= "number" or measured <= 0 then measured = nil end
        width = Echo.View.BubbleWidth(measured, Card.BUBBLE_MAX, Card.BUBBLE_PAD)
        b.text:SetWidth(width - Card.BUBBLE_PAD * 2)
        local h = b.text:GetStringHeight()
        if Echo.IsSecret(h) or type(h) ~= "number" or h <= 0 then h = Card.LINE_HEIGHT end
        height = h
    end
    b:SetSize(width, height + Card.BUBBLE_PAD * 2)
    return height + Card.BUBBLE_PAD * 2
end

local function RenderMessages(conv)
    local View = Echo.View
    local a = View.ACCENT
    local messages = conv.messages
    local r, g, b = View.ChatColor(conv.kind)
    local isGroup = conv.kind ~= "whisper" and conv.kind ~= "bnet"
    local newestOut = View.NewestOutgoing(conv)
    offset = math.max(0, math.min(offset, #messages - 1))
    local y = 4
    local used, usedLabels = 0, 0
    statusLine.retry = nil
    statusLine:Hide()
    for i = #messages - offset, 1, -1 do
        if y > Card.AREA_HEIGHT then break end
        local msg = messages[i]
        if i == newestOut and not msg.fromHistory and (msg.status == "pending" or msg.status == "sent" or msg.status == "failed") then
            local failed = msg.status == "failed"
            statusLine.text:SetText(View.StatusText(msg.status) .. (failed and (" · " .. L["ECHO_RETRY"]) or ""))
            if failed then
                statusLine.text:SetTextColor(1, 0.4, 0.4, 1)
            else
                statusLine.text:SetTextColor(0.55, 0.60, 0.75, 1)
            end
            statusLine.retry = failed and msg or nil
            statusLine:ClearAllPoints()
            statusLine:SetPoint("BOTTOMRIGHT", area, "BOTTOMRIGHT", 0, y)
            statusLine:Show()
            y = y + Card.LINE_HEIGHT
        end
        used = used + 1
        local bubble = Bubble(used)
        local secret = msg.secret or Echo.IsSecret(msg.text)
        local height = SizeBubble(bubble, msg.text, secret)
        bubble:ClearAllPoints()
        if msg.outgoing then
            bubble:SetPoint("BOTTOMRIGHT", area, "BOTTOMRIGHT", 0, y)
            local dimmed = msg.status == "pending" or msg.status == "retried"
            bubble:SetBackdropColor(a.r, a.g, a.b, dimmed and 0.14 or 0.24)
            bubble:SetBackdropBorderColor(a.r, a.g, a.b, 0.6)
            if msg.status == "failed" then
                bubble.text:SetTextColor(1, 0.45, 0.45, 1)
            else
                bubble.text:SetTextColor(0.92, 0.93, 0.98, 1)
            end
        else
            bubble:SetPoint("BOTTOMLEFT", area, "BOTTOMLEFT", 0, y)
            bubble:SetBackdropColor(0.11, 0.11, 0.15, 0.95)
            bubble:SetBackdropBorderColor(0.28, 0.30, 0.38, 0.5)
            bubble.text:SetTextColor(r, g, b, 1)
        end
        bubble:Show()
        y = y + height
        local startsGroup = View.StartsGroup(messages, i)
        if startsGroup and isGroup and not msg.outgoing
            and not Echo.IsSecret(msg.sender) and type(msg.sender) == "string" then
            usedLabels = usedLabels + 1
            local label = Label(usedLabels)
            label:SetText(msg.sender:match("^([^-]+)") or msg.sender)
            local cr, cg, cb = View.ClassColor(msg.class)
            label:SetTextColor(cr or r, cg or g, cb or b, 1)
            label:ClearAllPoints()
            label:SetPoint("BOTTOMLEFT", area, "BOTTOMLEFT", 2, y + 2)
            label:Show()
            y = y + Card.LINE_HEIGHT
        end
        y = y + (startsGroup and Card.GROUP_GAP or Card.GAP)
    end
    for j = used + 1, #bubbles do bubbles[j]:Hide() end
    for j = usedLabels + 1, #labels do labels[j]:Hide() end
end

--- Redraw the card around its conversation, and mark that conversation read.
function Card.Render()
    if not root or not root:IsShown() then return end
    local View, Store = Echo.View, Echo.Store
    local list = Store.List()
    local conv = currentKey and Store.Get(currentKey)
    if not conv or not conv.open then conv = list[1] end
    if not conv then
        Card.Hide()
        return
    end
    if renderedKey ~= conv.key then
        if renderedKey then Echo.ParkDraft(renderedKey, edit:GetText()) end
        edit:SetText(Echo.TakeDraft(conv.key))
        offset = 0
    end
    renderedKey = conv.key
    currentKey = conv.key

    local a = View.ACCENT
    for i = 1, Card.TILES do
        local b, other = rowTiles[i], list[i]
        if other then
            local spec = View.TileSpec(other)
            b.convKey = other.key
            PaintTile(b, spec)
            if other.key == conv.key then
                b:SetBackdropBorderColor(a.r, a.g, a.b, 1)
            else
                b:SetBackdropBorderColor(0, 0, 0, 0.7)
            end
            b.dot:SetShown(spec.badge ~= nil and other.key ~= conv.key)
            b:Show()
        else
            b.convKey = nil
            b:Hide()
        end
    end

    local spec = View.TileSpec(conv)
    nameText:SetText(View.DisplayName(conv))
    nameText:SetTextColor(spec.r, spec.g, spec.b, 1)
    metaText:SetText(View.CardMeta(conv):upper())
    if conv.kind == "whisper" then
        edit.placeholder:SetText(L["ECHO_WHISPER_TO"]:format(View.DisplayName(conv)))
    else
        edit.placeholder:SetText(L["ECHO_REPLY"])
    end
    edit.placeholder:SetShown(edit:GetText() == "" and not edit:HasFocus())

    RenderMessages(conv)
    Store.MarkRead(conv.key)
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

--- Open the card on a conversation; the stack closes.
-- @param convKey string|nil  nil for the top conversation
-- @param focus boolean|nil  focus the reply box
function Card.Open(convKey, focus)
    if not root then Create() end
    if #Echo.Store.List() == 0 then return end
    if Echo.Stack then Echo.Stack.Hide() end
    currentKey = convKey
    offset = 0
    Anchor()
    root:Show()
    Card.Render()
    if focus and root:IsShown() then edit:SetFocus() end
end

--- Switch the open card to another conversation (opens it if closed).
-- @param convKey string
function Card.Show(convKey)
    if not root or not root:IsShown() then
        Card.Open(convKey)
        return
    end
    currentKey = convKey
    Card.Render()
end

function Card.Hide()
    if not root then return end
    -- root's OnHide does this too (real frames fire it from Hide()); calling it here as
    -- well keeps the harness's stand-in frames, which don't fire OnHide on Hide(), correct.
    ParkDraft()
    if edit then edit:ClearFocus() end
    root:Hide()
end

--- @return boolean
function Card.IsShown()
    return root ~= nil and root:IsShown()
end

--- The mouse wheel over the messages: up (+1) shows older ones.
-- @param delta number
function Card.Scroll(delta)
    if not root or not root:IsShown() then return end
    offset = offset + delta
    Card.Render()
end

--- Send the reply box's text to the card's conversation.
function Card.Submit()
    local text = edit and edit:GetText()
    if not currentKey or not text or text == "" then return end
    Echo.Send.Send(currentKey, text)
    edit:SetText("")
    offset = 0
end

--- Send a failed message again.
-- @param msg table  the failed record
function Card.Retry(msg)
    if not currentKey or not msg or msg.status ~= "failed" then return end
    if Echo.Send.Send(currentKey, msg.text) then
        -- Send.Send's own Store.AddPending already triggered a re-render (of the newly
        -- filed part, still "failed" here); render again now that this message reads
        -- "retried" so its bubble picks up the dimmed styling.
        msg.status = "retried"
        Card.Render()
    end
end

function Card.OnStoreChange()
    if root and root:IsShown() then Card.Render() end
end

function Card.Enable()
    if not root then Create() end
    if not Card.subscribed then
        Echo.Store.Subscribe(Card.OnStoreChange)
        Card.subscribed = true
    end
end

function Card.Disable()
    if Card.subscribed then
        Echo.Store.Unsubscribe(Card.OnStoreChange)
        Card.subscribed = false
    end
    Card.Hide()
    renderedKey, currentKey = nil, nil
end

-- Test and debug handle.
function Card._frames()
    return {
        root = root, rowTiles = rowTiles, name = nameText, meta = metaText, area = area,
        edit = edit, send = send, menu = menuButton, chevron = chevron,
        bubbles = bubbles, labels = labels, status = statusLine,
    }
end
