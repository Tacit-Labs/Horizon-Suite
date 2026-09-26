--[[
    Horizon Suite - Echo - Card
    The expanded card: one conversation in full. A row of tiles for the open conversations
    and groups across the top (the current one outlined), the ⋯ menu and a collapse chevron; the name
    with class, relationship and online status; message bubbles, theirs on the left and
    yours on the right; a status line under your newest message; and a reply box with a
    send button. Opened by clicking a tile, a toast, or the stack's Open button.
    A group (Echo.Groups) opens as one card with a tab per open member under the header;
    everything below the tabs shows the selected member, so drafts, the scroll position
    and read-marking all stay per member.
    Pins: right-click a bubble or feed line to pin or unpin it (Echo.Menu). A pinned
    message carries a small pin marker, and the shown conversation's pins sit in a strip
    under the header (and the tabs): the pinned text, a counter that steps to older pins,
    and a × that unpins. Clicking the text scrolls to the message while it is still there.
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
Card.TEXT_SIZE = 11  -- message text; echoCardTextSize
Card.FEED_TIME_WIDTH = 40
Card.FEED_GAP = 2
Card.TAB_HEIGHT = 18
Card.TAB_GAP = 4
Card.TAB_STRIP = Card.TAB_HEIGHT + Card.TAB_GAP  -- how far a group card's area moves down
Card.TAB_MIN_WIDTH = 24  -- a tab never shrinks below this; below it, tabs overflow into "+N"
Card.PIN_HEIGHT = 22
Card.PIN_STRIP = Card.PIN_HEIGHT + 4  -- how far the area moves down under the pin strip
Card.PIN_MARK = 10    -- the pin marker on a pinned bubble or feed line
Card.PIN_ICON = 12    -- the pin on the strip
Card.PIN_INSET = 3    -- the marker sits this far inside the bubble's top corner
Card.LINK_WINDOW = 0.3  -- seconds: a link click this close to a right-click keeps the pin menu shut
-- On a pinned bubble, the text keeps this far from the marker's side so it never runs under it.
Card.PIN_CLEAR = Card.PIN_INSET + Card.PIN_MARK + 2
Card.PIN_TEXTURE = "Interface\\AddOns\\" .. (addon.ADDON_NAME or "HorizonSuite") .. "\\media\\echo\\pin.tga"

Card.MODE_WIDTH = 42   -- Nearby's Say / Yell / Emote chip at the left end of the reply box
Card.EDIT_INSET = 8    -- the reply box's own text inset

local root, nameText, metaText, area, edit, send, menuButton, chevron, statusLine, hint, rule
local modeChip
local rowTiles, bubbles, labels, tabs = {}, {}, {}, {}
local tabStrip, pinStrip
-- Forward-declared: Create()'s OnHide handler (defined further down) needs to stop the
-- genie, which is defined later in the file.
local StopEffects
local PaintMode  -- defined beside Card.Render
local currentKey, renderedKey
local groupIndex      -- the group the card shows, or nil for a lone conversation
local selected = {}   -- group index -> the member last selected there this session
local offset = 0  -- newest messages scrolled past
local newBelow = 0  -- messages added while scrolled up, shown by the hint
local areaHeight = Card.AREA_HEIGHT  -- the message area's height for the card now shown
local pinIndex  -- the pin the strip shows, an index into Store.Pins(renderedKey); nil = newest

-- Point the pin strip back at the newest pin.
local function ResetPinCursor()
    pinIndex = nil
end

--- Take the card's width and height from the settings and re-derive the sizes built on
-- them. The bubble width keeps the 110px the original 360px card left beside a bubble.
function Card.ApplySize()
    local lim = addon.ECHO_LIMITS
    local function clamp(v, key, fallback)
        v = tonumber(v) or fallback
        local l = lim and lim[key]
        if l then v = math.max(l.min, math.min(l.max, v)) end
        return v
    end
    Card.WIDTH = clamp(Echo.Setting("echoCardWidth"), "echoCardWidth", 360)
    Card.HEIGHT = clamp(Echo.Setting("echoCardHeight"), "echoCardHeight", 440)
    Card.AREA_HEIGHT = Card.HEIGHT - Card.AREA_TOP - Card.AREA_BOTTOM
    Card.BUBBLE_MAX = Card.WIDTH - 110
    local size = clamp(Echo.Setting("echoCardTextSize"), "echoCardTextSize", 11)
    if size ~= Card.TEXT_SIZE then
        Card.TEXT_SIZE = size
        for _, b in ipairs(bubbles) do Echo.TrackFont(b.text, size, "") end
    end
    if root then
        root:SetSize(Card.WIDTH, Card.HEIGHT)
        Echo.Round.Layout(root)
        if root:IsShown() then Card.Render() end
    end
end

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

local function Paint(frame, bg, border, radius, withBorder)
    Echo.Round.Apply(frame, { radius = radius, border = withBorder })
    Echo.Round.SetColor(frame, bg[1], bg[2], bg[3], bg[4])
    if withBorder then
        Echo.Round.SetBorderColor(frame, border[1], border[2], border[3], border[4])
    end
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
    local face = { icon = b.icon, letter = b.letter, size = 12, smallSize = 8, flags = "" }
    Echo.PaintTileFace(face, spec)
    Echo.Round.SetColor(b, View.FaceBackground(spec))
end

-- No MenuUtil (an older client), no ⋯ button: it would open nothing.
local function MenuAvailable()
    return Echo.Menu ~= nil and Echo.Menu.Available()
end

-- The message area runs from under the header (and a group card's tabs, and the pin
-- strip) to the reply box, or, on a read-only feed card with no reply box, down to the
-- card's bottom padding.
local function AnchorArea(feed, grouped, pinned)
    local top = Card.AREA_TOP + (grouped and Card.TAB_STRIP or 0) + (pinned and Card.PIN_STRIP or 0)
    local bottom = feed and Card.PAD or Card.AREA_BOTTOM
    area:ClearAllPoints()
    area:SetPoint("TOPLEFT", root, "TOPLEFT", Card.PAD, -top)
    area:SetPoint("BOTTOMRIGHT", root, "BOTTOMRIGHT", -Card.PAD, bottom)
    areaHeight = Card.HEIGHT - top - bottom
end

local function Create()
    local View = Echo.View
    local a = View.ACCENT
    root = CreateFrame("Frame", "HorizonSuiteEchoCard", UIParent)
    root:SetSize(Card.WIDTH, Card.HEIGHT)
    root:SetClampedToScreen(true)
    root:EnableMouse(true)
    root:Hide()
    Paint(root, View.PANEL_BG, View.PANEL_BORDER, Echo.Round.PANEL, true)
    table.insert(UISpecialFrames, "HorizonSuiteEchoCard")
    root:SetScript("OnHide", function()
        -- Covers closes that bypass Card.Hide entirely, e.g. Escape via UISpecialFrames
        -- calling root:Hide() directly: leave no stale draft or stuck focus behind, and
        -- don't let a genie keep running against a hidden card.
        ParkDraft()
        if edit then edit:ClearFocus() end
        StopEffects()
    end)

    rule = root:CreateTexture(nil, "OVERLAY")
    rule:SetColorTexture(a.r, a.g, a.b, 1)
    rule:SetHeight(2)
    -- Inset by the panel radius on both sides so the rule stays inside the rounded top
    -- corners instead of poking past them.
    rule:SetPoint("TOPLEFT", root, "TOPLEFT", Echo.Round.PANEL, 0)
    rule:SetPoint("TOPRIGHT", root, "TOPRIGHT", -Echo.Round.PANEL, 0)

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
    menuButton:SetShown(MenuAvailable())

    for i = 1, Card.TILES do
        local b = CreateFrame("Button", nil, root)
        b:SetSize(Card.TILE, Card.TILE)
        b:SetPoint("TOPLEFT", root, "TOPLEFT", Card.PAD + (i - 1) * (Card.TILE + 6), -10)
        Echo.Round.Apply(b, { radius = Echo.Round.TILE, border = true })
        b.letter = Echo.NewText(b, 12, "")
        b.letter:SetPoint("CENTER", b, "CENTER", 0, 0)
        b.icon = b:CreateTexture(nil, "ARTWORK")
        b.icon:SetPoint("TOPLEFT", b, "TOPLEFT", 3, -3)
        b.icon:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -3, 3)
        b.icon:Hide()
        -- The unread dot: one fully round texture (Echo.Round.Dot), not a full 9-slice.
        b.dot = Echo.Round.Dot(b, 6, "OVERLAY")
        b.dot:SetPoint("TOPRIGHT", b, "TOPRIGHT", 2, 2)
        b.dot:SetVertexColor(a.r, a.g, a.b, 1)
        b:RegisterForClicks("LeftButtonUp")
        b:SetScript("OnClick", function(self)
            if self.convKey then Card.Toggle(self.convKey, self) end
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

    -- A group card's tabs, one per open member, between the header and the messages.
    tabStrip = CreateFrame("Frame", nil, root)
    tabStrip:SetHeight(Card.TAB_HEIGHT)
    tabStrip:SetPoint("TOPLEFT", root, "TOPLEFT", Card.PAD, -Card.AREA_TOP)
    tabStrip:SetPoint("TOPRIGHT", root, "TOPRIGHT", -Card.PAD, -Card.AREA_TOP)
    tabStrip:Hide()

    -- The shown conversation's pins, between the header (or the tabs) and the messages.
    pinStrip = CreateFrame("Frame", nil, root)
    pinStrip:SetHeight(Card.PIN_HEIGHT)
    Echo.Round.Apply(pinStrip, { radius = Echo.Round.SMALL })
    Echo.Round.SetColor(pinStrip, a.r, a.g, a.b, 0.14)
    pinStrip.icon = pinStrip:CreateTexture(nil, "ARTWORK")
    pinStrip.icon:SetTexture(Card.PIN_TEXTURE)
    pinStrip.icon:SetSize(Card.PIN_ICON, Card.PIN_ICON)
    pinStrip.icon:SetPoint("LEFT", pinStrip, "LEFT", 6, 0)
    pinStrip.icon:SetVertexColor(a.r, a.g, a.b, 1)

    local close = CreateFrame("Button", nil, pinStrip)
    close:SetSize(18, 18)
    close:SetPoint("RIGHT", pinStrip, "RIGHT", -2, 0)
    Glyph(close, {
        { w = 8, h = 1.5, angle = math.pi / 4 },
        { w = 8, h = 1.5, angle = -math.pi / 4 },
    })
    local tint, untint = close:GetScript("OnEnter"), close:GetScript("OnLeave")
    close:SetScript("OnEnter", function(self)
        if tint then tint(self) end
        if GameTooltip and type(GameTooltip.SetOwner) == "function" then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(L["ECHO_UNPIN"])
            GameTooltip:Show()
        end
    end)
    close:SetScript("OnLeave", function(self)
        if untint then untint(self) end
        if GameTooltip and type(GameTooltip.Hide) == "function" then GameTooltip:Hide() end
    end)
    close:RegisterForClicks("LeftButtonUp")
    close:SetScript("OnClick", function() Card.UnpinShown() end)
    pinStrip.close = close

    local counter = CreateFrame("Button", nil, pinStrip)
    counter:SetSize(34, 18)
    counter:SetPoint("RIGHT", close, "LEFT", -2, 0)
    counter.text = Echo.NewText(counter, 10, "")
    counter.text:SetPoint("CENTER", counter, "CENTER", 0, 0)
    counter.text:SetTextColor(a.r, a.g, a.b, 1)
    counter:RegisterForClicks("LeftButtonUp")
    counter:SetScript("OnClick", function() Card.NextPin() end)
    counter:Hide()
    pinStrip.counter = counter

    local label = CreateFrame("Button", nil, pinStrip)
    label:SetHeight(18)
    label.text = Echo.NewText(label, 11, "")
    label.text:SetPoint("LEFT", label, "LEFT", 0, 0)
    label.text:SetPoint("RIGHT", label, "RIGHT", 0, 0)
    label.text:SetJustifyH("LEFT")
    label.text:SetWordWrap(false)
    label.text:SetTextColor(0.92, 0.93, 0.98, 1)
    label:RegisterForClicks("LeftButtonUp")
    label:SetScript("OnClick", function() Card.JumpToPin() end)
    label:SetScript("OnEnter", function(self) Card.ShowPinTooltip(self) end)
    label:SetScript("OnLeave", function()
        if GameTooltip and type(GameTooltip.Hide) == "function" then GameTooltip:Hide() end
    end)
    pinStrip.label = label
    pinStrip:Hide()

    area = CreateFrame("Frame", nil, root)
    AnchorArea(false, false, false)
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

    hint = CreateFrame("Button", nil, area)
    hint:SetSize(90, 20)
    Paint(hint, View.PANEL_BG, View.PANEL_BORDER, Echo.Round.PANEL, true)
    hint:SetPoint("BOTTOM", area, "BOTTOM", 0, 4)
    hint.text = Echo.NewText(hint, 11, "")
    hint.text:SetPoint("CENTER", hint, "CENTER", 0, 0)
    hint.text:SetTextColor(a.r, a.g, a.b, 1)
    hint:RegisterForClicks("LeftButtonUp")
    hint:SetScript("OnClick", function()
        offset = 0
        newBelow = 0
        hint:Hide()
        Card.Render()
    end)
    hint:Hide()

    send = CreateFrame("Button", nil, root)
    send:SetSize(30, 30)
    send:SetPoint("BOTTOMRIGHT", root, "BOTTOMRIGHT", -Card.PAD, 12)
    Paint(send, { a.r, a.g, a.b, 0.9 }, nil, Echo.Round.SMALL, false)
    send.text = Echo.NewText(send, 14, "")
    send.text:SetPoint("CENTER", send, "CENTER", 1, 0)
    send.text:SetText(">")
    send.text:SetTextColor(0.05, 0.05, 0.07, 1)
    send:RegisterForClicks("LeftButtonUp")
    send:SetScript("OnClick", function() Card.Submit() end)

    edit = CreateFrame("EditBox", nil, root)
    edit:SetHeight(30)
    edit:SetPoint("BOTTOMLEFT", root, "BOTTOMLEFT", Card.PAD, 12)
    edit:SetPoint("BOTTOMRIGHT", send, "BOTTOMLEFT", -6, 0)
    Paint(edit, { 0.03, 0.03, 0.05, 0.95 }, nil, Echo.Round.SMALL, false)
    Echo.TrackFont(edit, 12, "")
    edit:SetTextInsets(8, 8, 0, 0)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(1020)
    edit.placeholder = Echo.NewText(edit, 12, "")
    edit.placeholder:SetPoint("LEFT", edit, "LEFT", 8, 0)
    edit.placeholder:SetTextColor(0.5, 0.52, 0.6, 1)
    edit._leftInset = Card.EDIT_INSET

    -- Nearby's send mode: a click steps Say -> Yell -> Emote -> Say. Shown on Nearby only.
    modeChip = CreateFrame("Button", nil, edit)
    modeChip:SetSize(Card.MODE_WIDTH, 22)
    modeChip:SetPoint("LEFT", edit, "LEFT", 4, 0)
    Paint(modeChip, { a.r, a.g, a.b, 0.22 }, nil, Echo.Round.SMALL, false)
    modeChip.text = Echo.NewText(modeChip, 10, "")
    modeChip.text:SetPoint("CENTER", modeChip, "CENTER", 0, 0)
    modeChip.text:SetTextColor(0.92, 0.93, 0.98, 1)
    modeChip:RegisterForClicks("LeftButtonUp")
    modeChip:SetScript("OnClick", function() Card.CycleMode() end)
    modeChip:Hide()
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
    -- A keybind that focuses the box must not type its own key into it; restore whatever
    -- draft was there before the keybind stole focus (as the stack's box does).
    edit:SetScript("OnChar", function(self)
        if self.swallow then
            self.swallow = false
            self:SetText(self.beforeSwallow or "")
        end
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
    b = CreateFrame("Frame", nil, area)
    Echo.Round.Apply(b, { radius = Echo.Round.BUBBLE })
    b.text = Echo.NewText(b, Card.TEXT_SIZE, "")
    b.text:SetPoint("TOPLEFT", b, "TOPLEFT", Card.BUBBLE_PAD, -Card.BUBBLE_PAD)
    b.text:SetJustifyH("LEFT")
    b.text:SetJustifyV("TOP")
    b.text:SetWordWrap(true)
    b.text:SetNonSpaceWrap(true)
    b.time = Echo.NewText(b, 10, "")
    b.time:SetPoint("TOPLEFT", b, "TOPLEFT", 2, -3)
    b.time:SetTextColor(0.55, 0.60, 0.75, 1)
    b.time:Hide()
    -- The pin marker, placed by Mark once the bubble's side is known.
    b.pin = b:CreateTexture(nil, "OVERLAY")
    b.pin:SetTexture(Card.PIN_TEXTURE)
    b.pin:SetSize(Card.PIN_MARK, Card.PIN_MARK)
    local a = Echo.View.ACCENT
    b.pin:SetVertexColor(a.r, a.g, a.b, 1)
    b.pin:Hide()
    b:EnableMouse(true)
    if Echo.Links then Echo.Links.Attach(b) end
    -- A link click goes to OnHyperlinkClick and keeps Blizzard's behaviour; a right-click
    -- anywhere else on the message opens its pin menu. WoW can dispatch the link click and
    -- OnMouseUp in either order, so the link click stamps the time, and the menu opens a
    -- frame later only if no link click landed within Card.LINK_WINDOW of it.
    b:HookScript("OnHyperlinkClick", function(self)
        if type(GetTime) == "function" then self._echoLinkClickAt = GetTime() end
    end)
    b:SetScript("OnMouseUp", function(self, button)
        if button ~= "RightButton" or not self.msgKey or not self.msg or not Echo.Menu then return end
        local function LinkClicked()
            local at = rawget(self, "_echoLinkClickAt")
            local now = type(GetTime) == "function" and GetTime() or nil
            return type(at) == "number" and type(now) == "number" and (now - at) < Card.LINK_WINDOW
        end
        if LinkClicked() then return end
        local key, msg = self.msgKey, self.msg
        local function Open()
            if LinkClicked() then return end
            Echo.Menu.OpenMessage(self, key, msg)
        end
        if C_Timer and type(C_Timer.After) == "function" then
            C_Timer.After(0, Open)
        else
            Open()
        end
    end)
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
-- can't be, so it gets the widest bubble and a fixed number of lines. markSide ("left",
-- "right" or nil) is where a pinned bubble's marker sits: the text keeps clear of it on
-- that side only, and every call resets the insets, so a reused bubble starts plain.
local function SizeBubble(b, text, secret, markSide)
    local extra = markSide and math.max(0, Card.PIN_CLEAR - Card.BUBBLE_PAD) or 0
    local maxWidth = Card.BUBBLE_MAX - extra
    b.time:Hide()
    b.text:ClearAllPoints()
    b.text:SetPoint("TOPLEFT", b, "TOPLEFT", Card.BUBBLE_PAD + (markSide == "left" and extra or 0), -Card.BUBBLE_PAD)
    local inner = maxWidth - Card.BUBBLE_PAD * 2
    b.text:SetWidth(inner)
    b.text:SetMaxLines(secret and Card.SECRET_LINES or 0)
    b.text:SetText(text)
    local width, height
    if secret then
        width = Card.BUBBLE_MAX
        height = Card.SECRET_LINES * (Card.TEXT_SIZE + 3)
    else
        local measured
        if b.text.GetUnboundedStringWidth then measured = b.text:GetUnboundedStringWidth() end
        if Echo.IsSecret(measured) or type(measured) ~= "number" or measured <= 0 then measured = nil end
        width = Echo.View.BubbleWidth(measured, maxWidth, Card.BUBBLE_PAD)
        -- A measured width can round a hair short at some UI scales and wrap the last
        -- word; 2 px of slack keeps a fitted bubble on its lines.
        if measured then width = math.min(maxWidth, width + 2) end
        b.text:SetWidth(width - Card.BUBBLE_PAD * 2)
        width = width + extra
        local h = b.text:GetStringHeight()
        if Echo.IsSecret(h) or type(h) ~= "number" or h <= 0 then h = Card.LINE_HEIGHT end
        height = h
    end
    b:SetSize(width, height + Card.BUBBLE_PAD * 2)
    Echo.Round.Layout(b)
    return height + Card.BUBBLE_PAD * 2
end

-- Lay out one feed line across the card: time, then (when pinned) the pin marker, then
-- text. Readable text is measured; a secret gets a fixed number of lines. Returns its height.
local function SizeFeedLine(b, msg, secret, pinned, text)
    local width = Card.WIDTH - Card.PAD * 2
    local left = Card.FEED_TIME_WIDTH + (pinned and (Card.PIN_MARK + 3) or 0)
    b.time:SetText(Echo.View.FeedTime(msg.time))
    b.time:Show()
    b.pin:ClearAllPoints()
    if pinned then
        b.pin:SetPoint("TOPLEFT", b, "TOPLEFT", Card.FEED_TIME_WIDTH, -4)
        b.pin:Show()
    else
        b.pin:Hide()
    end
    b.text:ClearAllPoints()
    b.text:SetPoint("TOPLEFT", b, "TOPLEFT", left, -3)
    b.text:SetWidth(width - left - 4)
    b.text:SetMaxLines(secret and Card.SECRET_LINES or 0)
    if text == nil then text = msg.text end
    b.text:SetText(text)
    local height
    if secret then
        height = Card.SECRET_LINES * (Card.TEXT_SIZE + 3)
    else
        local h = b.text:GetStringHeight()
        if Echo.IsSecret(h) or type(h) ~= "number" or h <= 0 then h = Card.LINE_HEIGHT end
        height = h
    end
    b:SetSize(width, height + 6)
    Echo.Round.Layout(b)
    return height + 6
end

-- Place a bubble's pin marker at its top corner away from the sender (top-right of theirs,
-- top-left of yours), or clear it for an unpinned message.
local function Mark(b, pinned, outgoing)
    b.pin:ClearAllPoints()
    if not pinned then
        b.pin:Hide()
        return
    end
    if outgoing then
        b.pin:SetPoint("TOPLEFT", b, "TOPLEFT", Card.PIN_INSET, -Card.PIN_INSET)
    else
        b.pin:SetPoint("TOPRIGHT", b, "TOPRIGHT", -Card.PIN_INSET, -Card.PIN_INSET)
    end
    b.pin:Show()
end

-- Whether message i is the last (most recent) of its consecutive-same-sender run: either
-- the newest message overall, or the next one starts a new group. That bubble keeps the
-- tight corner nearest the next speaker; earlier bubbles in the run use full radii.
local function EndsGroup(messages, i)
    if i == #messages then return true end
    return Echo.View.StartsGroup(messages, i + 1)
end

local function RenderMessages(conv)
    local View = Echo.View
    local a = View.ACCENT
    local messages = conv.messages
    local r, g, b = View.ChatColor(conv.kind)
    local isGroup = conv.kind ~= "whisper" and conv.kind ~= "bnet"
    local newestOut = View.NewestOutgoing(conv)
    local Store = Echo.Store
    local pins = Store.Pins(conv.key)
    local function Pinned(msg) return #pins > 0 and Store.IsPinnedMessage(conv.key, msg, pins) end
    offset = math.max(0, math.min(offset, #messages - 1))
    local y = 4
    local used, usedLabels = 0, 0
    statusLine.retry = nil
    statusLine:Hide()
    if View.IsFeed(conv.kind) then
        for i = #messages - offset, 1, -1 do
            if y > areaHeight then break end
            local msg = messages[i]
            used = used + 1
            local line = Bubble(used)
            line.msgKey, line.msg = conv.key, msg
            local height = SizeFeedLine(line, msg, msg.secret or Echo.IsSecret(msg.text), Pinned(msg))
            line:ClearAllPoints()
            line:SetPoint("BOTTOMLEFT", area, "BOTTOMLEFT", 0, y)
            Echo.Round.SetColor(line, 0, 0, 0, 0)
            local lr, lg, lb = View.LineColor(conv, msg)
            line.text:SetTextColor(lr, lg, lb, 1)
            line:Show()
            y = y + height + Card.FEED_GAP
        end
        for j = used + 1, #bubbles do bubbles[j]:Hide() end
        for j = 1, #labels do labels[j]:Hide() end
        return
    end
    for i = #messages - offset, 1, -1 do
        if y > areaHeight then break end
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
        bubble.msgKey, bubble.msg = conv.key, msg
        local secret = msg.secret or Echo.IsSecret(msg.text)
        local pinned = Pinned(msg)
        if View.IsEmoteLine(msg) then
            -- A Nearby emote: a full-width line in its emote colour, like a feed line.
            local height = SizeFeedLine(bubble, msg, secret, pinned, View.LineText(conv, msg))
            bubble:ClearAllPoints()
            bubble:SetPoint("BOTTOMLEFT", area, "BOTTOMLEFT", 0, y)
            Echo.Round.SetColor(bubble, 0, 0, 0, 0)
            if msg.status == "failed" then
                bubble.text:SetTextColor(1, 0.45, 0.45, 1)
            else
                local lr, lg, lb = View.LineColor(conv, msg)
                bubble.text:SetTextColor(lr, lg, lb, 1)
            end
            bubble:Show()
            y = y + height + (View.StartsGroup(messages, i) and Card.GROUP_GAP or Card.GAP)
        else
            local markSide = pinned and (msg.outgoing and "left" or "right") or nil
            local height = SizeBubble(bubble, msg.text, secret, markSide)
            Mark(bubble, pinned, msg.outgoing)
            bubble:ClearAllPoints()
            local Round = Echo.Round
            local ends = EndsGroup(messages, i)
            if msg.outgoing then
                bubble:SetPoint("BOTTOMRIGHT", area, "BOTTOMRIGHT", 0, y)
                local dimmed = msg.status == "pending" or msg.status == "retried"
                Echo.Round.SetColor(bubble, a.r, a.g, a.b, dimmed and 0.14 or 0.24)
                if ends then
                    Round.SetCorners(bubble, Round.BUBBLE, Round.BUBBLE, Round.BUBBLE, Round.TIGHT)
                else
                    Round.SetCorners(bubble, Round.BUBBLE, Round.BUBBLE, Round.BUBBLE, Round.BUBBLE)
                end
                if msg.status == "failed" then
                    bubble.text:SetTextColor(1, 0.45, 0.45, 1)
                elseif msg.style == "yell" then
                    -- Your own yell reads as a yell too.
                    local lr, lg, lb = View.LineColor(conv, msg)
                    bubble.text:SetTextColor(lr, lg, lb, 1)
                else
                    bubble.text:SetTextColor(0.92, 0.93, 0.98, 1)
                end
            else
                bubble:SetPoint("BOTTOMLEFT", area, "BOTTOMLEFT", 0, y)
                Echo.Round.SetColor(bubble, 0.11, 0.11, 0.15, 0.95)
                if ends then
                    Round.SetCorners(bubble, Round.BUBBLE, Round.BUBBLE, Round.TIGHT, Round.BUBBLE)
                else
                    Round.SetCorners(bubble, Round.BUBBLE, Round.BUBBLE, Round.BUBBLE, Round.BUBBLE)
                end
                -- A Nearby line takes its own style's colour (Say, Yell, NPC).
                local lr, lg, lb = r, g, b
                if msg.style then lr, lg, lb = View.LineColor(conv, msg) end
                bubble.text:SetTextColor(lr, lg, lb, 1)
            end
            bubble:Show()
            y = y + height
            local startsGroup = View.StartsGroup(messages, i)
            local name = isGroup and not msg.outgoing and View.SenderName(msg) or nil
            if startsGroup and name then
                usedLabels = usedLabels + 1
                local label = Label(usedLabels)
                label:SetText(name)
                local cr, cg, cb = View.ClassColor(msg.class)
                label:SetTextColor(cr or r, cg or g, cb or b, 1)
                label:ClearAllPoints()
                label:SetPoint("BOTTOMLEFT", area, "BOTTOMLEFT", 2, y + 2)
                label:Show()
                y = y + Card.LINE_HEIGHT
            end
            y = y + (startsGroup and Card.GROUP_GAP or Card.GAP)
        end
    end
    for j = used + 1, #bubbles do bubbles[j]:Hide() end
    for j = usedLabels + 1, #labels do labels[j]:Hide() end
end

-- Whether a column entry (a conversation or a group) is the one the card shows.
local function IsShownEntry(entry)
    if entry.kind == "group" then return entry.group == groupIndex end
    return groupIndex == nil and entry.key == renderedKey
end

-- The row of tiles across the top: the column's entries (View.Entries: groups and
-- ungrouped conversations), the shown one outlined, the others dotted when they have
-- something new.
local function PaintRow(list)
    local View = Echo.View
    local a = View.ACCENT
    local entries = View.Entries(list)
    for i = 1, Card.TILES do
        local b, other = rowTiles[i], entries[i]
        if other then
            local spec = View.TileSpec(other)
            local shown = IsShownEntry(other)
            b.convKey = other.key
            PaintTile(b, spec)
            if shown then
                Echo.Round.SetBorderColor(b, a.r, a.g, a.b, 1)
            else
                Echo.Round.SetBorderColor(b, 0, 0, 0, 0.7)
            end
            b.dot:SetShown(spec.badge ~= nil and not shown)
            b:Show()
        else
            b.convKey = nil
            b:Hide()
        end
    end
end

local function Tab(i)
    local t = tabs[i]
    if t then return t end
    t = CreateFrame("Button", nil, tabStrip)
    t:SetHeight(Card.TAB_HEIGHT)
    Echo.Round.Apply(t, { radius = Echo.Round.SMALL })
    t.text = Echo.NewText(t, 10, "")
    t.text:SetPoint("LEFT", t, "LEFT", 7, 0)
    t.text:SetPoint("RIGHT", t, "RIGHT", -7, 0)
    t.text:SetWordWrap(false)
    local a = Echo.View.ACCENT
    t.dot = Echo.Round.Dot(t, 5, "OVERLAY")
    t.dot:SetPoint("TOPRIGHT", t, "TOPRIGHT", 1, 1)
    t.dot:SetVertexColor(a.r, a.g, a.b, 1)
    t:RegisterForClicks("LeftButtonUp")
    t:SetScript("OnClick", function(self)
        if self.convKey then Card.SelectMember(self.convKey) end
    end)
    tabs[i] = t
    return t
end

-- A member's tab text: its tile's short name, else the first letters of its name.
local function TabLabel(conv)
    local View = Echo.View
    local label = View.TileSpec(conv).label
    if Echo.IsSecret(label) or type(label) ~= "string" or label == "" then
        label = View.ShortName(View.DisplayName(conv), 8)
    end
    return label
end

-- The dim, unselected tab look, shared by a member tab and the "+N" overflow tab.
local function DimTab(t)
    Echo.Round.SetColor(t, 0.11, 0.11, 0.15, 0.95)
    t.text:SetTextColor(0.55, 0.60, 0.75, 1)
end

-- The tab strip for a group card: a small rounded tab per open member, the selected one
-- filled with the accent, the others dim, an unread one dotted. Tabs share the strip's
-- width when their names don't fit side by side, never shrinking below Card.TAB_MIN_WIDTH;
-- past that floor, as many as fit are shown (the selected one always among them) and the
-- rest fold into a trailing "+N" tab that selects the first hidden member. Hidden for a
-- lone conversation.
local function PaintTabs(members)
    if not members then
        tabStrip:Hide()
        for _, t in ipairs(tabs) do
            t.convKey = nil
            t:Hide()
        end
        return
    end
    local minW = Card.TAB_MIN_WIDTH
    local widths, total = {}, 0
    for i, conv in ipairs(members) do
        local t = Tab(i)
        t.convKey = conv.key
        t.text:SetText(TabLabel(conv))
        local w = t.text.GetStringWidth and t.text:GetStringWidth()
        if Echo.IsSecret(w) or type(w) ~= "number" or w <= 0 then w = 30 end
        widths[i] = math.ceil(w) + 14
        total = total + widths[i] + (i > 1 and Card.TAB_GAP or 0)
    end

    local avail = Card.WIDTH - Card.PAD * 2
    local shown, finalWidths = members, widths
    local overflowKey, overflowCount

    if total > avail then
        local even = math.floor((avail - Card.TAB_GAP * (#members - 1)) / #members)
        if even >= minW then
            finalWidths = {}
            for i = 1, #members do finalWidths[i] = even end
        else
            -- Even the floor width doesn't fit everyone: show as many as fit at the floor,
            -- keeping the selected member visible, plus a trailing "+N" tab for the rest.
            local budget = avail - minW - Card.TAB_GAP
            local fit = math.floor((budget + Card.TAB_GAP) / (minW + Card.TAB_GAP))
            fit = math.max(1, math.min(#members - 1, fit))

            shown = {}
            for i = 1, fit do shown[i] = members[i] end
            local haveSelected = false
            for i = 1, fit do
                if shown[i].key == renderedKey then haveSelected = true break end
            end
            if not haveSelected then
                for i = fit + 1, #members do
                    if members[i].key == renderedKey then
                        shown[fit] = members[i]
                        break
                    end
                end
            end

            local shownKeys = {}
            for _, conv in ipairs(shown) do shownKeys[conv.key] = true end
            overflowCount = 0
            for _, conv in ipairs(members) do
                if not shownKeys[conv.key] then
                    overflowCount = overflowCount + 1
                    if not overflowKey then overflowKey = conv.key end
                end
            end

            finalWidths = {}
            for i = 1, #shown do finalWidths[i] = minW end
        end
    end

    local a = Echo.View.ACCENT
    local x, count = 0, #shown
    for i = 1, count do
        local conv = shown[i]
        local t = tabs[i] or Tab(i)
        t.convKey = conv.key
        t.text:SetText(TabLabel(conv))
        local w = finalWidths[i]
        t:SetWidth(w)
        t:ClearAllPoints()
        t:SetPoint("TOPLEFT", tabStrip, "TOPLEFT", x, 0)
        Echo.Round.Layout(t)
        x = x + w + Card.TAB_GAP
        local isSelected = conv.key == renderedKey
        if isSelected then
            Echo.Round.SetColor(t, a.r, a.g, a.b, 0.9)
            t.text:SetTextColor(0.05, 0.05, 0.07, 1)
        else
            DimTab(t)
        end
        t.dot:SetShown((conv.unread or 0) > 0 and not isSelected)
        t:Show()
    end

    if overflowKey then
        count = count + 1
        local t = tabs[count] or Tab(count)
        t.convKey = overflowKey
        t.text:SetText("+" .. overflowCount)
        t:SetWidth(minW)
        t:ClearAllPoints()
        t:SetPoint("TOPLEFT", tabStrip, "TOPLEFT", x, 0)
        Echo.Round.Layout(t)
        DimTab(t)
        t.dot:Hide()
        t:Show()
    end

    for i = count + 1, #tabs do
        tabs[i].convKey = nil
        tabs[i]:Hide()
    end
    tabStrip:Show()
end

-- The pin strip for the shown conversation: hidden with no pins; else the shown pin's
-- text on one line, and a counter (position from the newest) when there are two or more.
-- Returns whether it shows.
local function PaintPins(conv, grouped)
    local pins = Echo.Store.Pins(conv.key)
    local n = #pins
    if n == 0 then
        ResetPinCursor()
        pinStrip:Hide()
        return false
    end
    -- pinIndex stays nil until the counter steps, so a new pin shows as it's made.
    if pinIndex and (pinIndex > n or pinIndex < 1) then ResetPinCursor() end
    local index = pinIndex or n
    local top = Card.AREA_TOP + (grouped and Card.TAB_STRIP or 0)
    pinStrip:ClearAllPoints()
    pinStrip:SetPoint("TOPLEFT", root, "TOPLEFT", Card.PAD, -top)
    pinStrip:SetPoint("TOPRIGHT", root, "TOPRIGHT", -Card.PAD, -top)
    Echo.Round.Layout(pinStrip)

    local label, counter = pinStrip.label, pinStrip.counter
    label.text:SetText(Echo.View.PinText(pins[index].text))
    counter:SetShown(n >= 2)
    if n >= 2 then counter.text:SetText(L["ECHO_PIN_COUNTER"]:format(n - index + 1, n)) end
    label:ClearAllPoints()
    label:SetPoint("LEFT", pinStrip.icon, "RIGHT", 5, 0)
    label:SetPoint("RIGHT", n >= 2 and counter or pinStrip.close, "LEFT", -4, 0)
    pinStrip:Show()
    return true
end

-- The open members of the shown group, or nil for a lone conversation.
local function ShownMembers(list)
    if not groupIndex then return nil end
    return Echo.Groups.Members(groupIndex, list)
end

-- Aim the card at a key: a group key opens that group on its remembered member; a member
-- key opens its group with that member selected; any other key (or nil, the top
-- conversation) opens alone. Card.Render resolves what is actually shown.
local function Target(key)
    local Groups = Echo.Groups
    local asGroup = Groups and Groups.IndexOf(key)
    local ofGroup = not asGroup and Groups and key and Groups.Of(key)
    groupIndex = asGroup or ofGroup or nil
    if ofGroup then selected[ofGroup] = key end
    currentKey = not asGroup and key or nil
end

--- Redraw the card around its conversation, and mark that conversation read.
-- Nearby's send-mode chip: shown, labelled with the current mode, and the reply box's text
-- moved right to clear it; every other conversation gets the plain inset back.
local MODE_LABEL = { SAY = "ECHO_MODE_SAY", YELL = "ECHO_MODE_YELL", EMOTE = "ECHO_MODE_EMOTE" }
function PaintMode(conv)
    local nearby = conv.kind == "nearby"
    local inset = Card.EDIT_INSET
    if nearby then
        modeChip.text:SetText(L[MODE_LABEL[Echo.Store.SendModeOf(conv.key)]])
        inset = 4 + Card.MODE_WIDTH + 6
    end
    modeChip:SetShown(nearby)
    edit._leftInset = inset
    edit:SetTextInsets(inset, Card.EDIT_INSET, 0, 0)
    edit.placeholder:ClearAllPoints()
    edit.placeholder:SetPoint("LEFT", edit, "LEFT", inset, 0)
end

--- The mode chip: step the shown Nearby conversation's send mode Say -> Yell -> Emote -> Say.
local NEXT_MODE = { SAY = "YELL", YELL = "EMOTE", EMOTE = "SAY" }
function Card.CycleMode()
    local conv = renderedKey and Echo.Store.Get(renderedKey)
    if not conv or conv.kind ~= "nearby" then return end
    Echo.Store.SetSendMode(conv.key, NEXT_MODE[Echo.Store.SendModeOf(conv.key)])
    PaintMode(conv)
end

function Card.Render()
    if not root or not root:IsShown() then return end
    local View, Store = Echo.View, Echo.Store
    local Groups = Echo.Groups
    local list = Store.List()
    local conv, members
    if groupIndex then
        members = Groups.Members(groupIndex, list)
        if #members == 0 then
            -- The last member closed: the card goes. A member still open here means the
            -- group itself went (switched off or renamed blank): show it alone.
            local own = currentKey and Store.Get(currentKey)
            if not (own and own.open) then
                Card.Hide()
                return
            end
            groupIndex, members = nil, nil
        else
            local want = selected[groupIndex]
            for _, m in ipairs(members) do
                if m.key == want then conv = m end
            end
            conv = conv or Groups.Newest(groupIndex, list)
        end
    end
    if not groupIndex then
        conv = currentKey and Store.Get(currentKey)
        if not conv or not conv.open then conv = list[1] end
        if not conv then
            Card.Hide()
            return
        end
        -- A grouped conversation always shows inside its group.
        local index = Groups and Groups.Of(conv.key)
        if index then
            groupIndex = index
            members = Groups.Members(index, list)
        end
    end
    if groupIndex then selected[groupIndex] = conv.key end
    if renderedKey ~= conv.key then
        if renderedKey then Echo.ParkDraft(renderedKey, edit:GetText()) end
        edit:SetText(Echo.TakeDraft(conv.key))
        offset = 0
        newBelow = 0
        hint:Hide()
        ResetPinCursor()  -- another conversation: its strip starts on the newest pin
    end
    renderedKey = conv.key
    currentKey = conv.key
    -- A guild tile restored before the guild was known: try its saved history again.
    if conv.historyLoaded == false and Store.RetryHistory then Store.RetryHistory() end

    PaintRow(list)
    PaintTabs(members)
    menuButton:SetShown(MenuAvailable())

    local spec = View.TileSpec(conv)
    if groupIndex then
        local groupName = Groups.Name(groupIndex)
        nameText:SetText(L["ECHO_GROUP_TITLE"]:format(groupName, View.DisplayName(conv)))
    else
        nameText:SetText(View.DisplayName(conv))
    end
    nameText:SetTextColor(spec.r, spec.g, spec.b, 1)
    metaText:SetText(View.Upper(View.CardMeta(conv)))
    if conv.kind == "whisper" then
        edit.placeholder:SetText(L["ECHO_WHISPER_TO"]:format(View.DisplayName(conv)))
    else
        edit.placeholder:SetText(L["ECHO_REPLY"])
    end
    PaintMode(conv)
    edit.placeholder:SetShown(edit:GetText() == "" and not edit:HasFocus())

    -- Feeds are read-only: no reply box or send button.
    local feed = View.IsFeed(conv.kind)
    if feed then edit:ClearFocus() end
    edit:SetShown(not feed)
    send:SetShown(not feed)
    AnchorArea(feed, groupIndex ~= nil, PaintPins(conv, groupIndex ~= nil))

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
        local side = Echo.View.PanelSides(Echo.View.PanelEdge(Card.WIDTH))
        root:SetPoint(side.panel, column, side.rel, side.dx, 0)
    else
        root:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

function Card.Reanchor() Anchor() end

-- The open and close effect: Echo.Genie pours a sheet out of the clicked tile (or back
-- into it); the genie itself fades the card in over the sheet's last stretch.
local closing = false      -- a close genie is running; a second click on the tile waits
local genieHiding = false  -- the close genie's own onDone is hiding the card

-- Stops any genie (unless the close genie is the one hiding the card) and leaves the card
-- at full alpha for the next open.
function StopEffects()
    if Echo.Genie and not genieHiding then Echo.Genie.Stop() end
    closing = false
    if root then root:SetAlpha(1) end
end

local function Animated()
    return Echo.Genie ~= nil and Echo.Setting("echoAnimateCard") and true or false
end

-- The sheet's colour at the neck: the tile's face colour (a class tile's is its class
-- colour; a group card's is its group tile's).
local function GenieColor(convKey)
    local View = Echo.View
    if groupIndex then
        local entry = { kind = "group", group = groupIndex, members = {} }
        local r, g, b = View.FaceBackground(View.TileSpec(entry))
        return { r, g, b }
    end
    local conv = convKey and Echo.Store.Get(convKey)
    if not conv then return nil end
    local r, g, b = View.FaceBackground(View.TileSpec(conv))
    return { r, g, b }
end

local function Visible(frame)
    local v = frame.IsVisible and frame:IsVisible()
    if type(v) == "boolean" then return v end
    return frame:IsShown() and true or false
end

-- The tile a close collapses into: the clicked column tile, or, for a click on the card's
-- own row, that conversation's column tile. Nil when there is none to see.
local function CloseTile(convKey, fromTile)
    if not fromTile then return nil end
    for _, b in ipairs(rowTiles) do
        if b == fromTile then
            fromTile = Echo.Tiles and Echo.Tiles.TileFor and Echo.Tiles.TileFor(convKey)
            break
        end
    end
    if fromTile and Visible(fromTile) then return fromTile end
    return nil
end

local HideNow

-- The column's chat button: where the sheet starts when the tile has no rect yet.
local function StackButton()
    return Echo.Tiles and Echo.Tiles._stackButton and Echo.Tiles._stackButton() or nil
end

local function PlayOpen(fromTile)
    Echo.Genie.Play({
        from = fromTile, fallback = StackButton(), to = root, color = GenieColor(renderedKey),
    })
end

local function PlayClose(tile)
    closing = true
    Echo.Genie.Play({
        from = tile, fallback = StackButton(), to = root, reverse = true,
        color = GenieColor(renderedKey),
        onDone = function()
            genieHiding = true
            HideNow()
            genieHiding = false
        end,
    })
end

--- Open the card on a conversation; the stack closes.
-- @param convKey string|nil  nil for the top conversation
-- @param focus boolean|nil  focus the reply box
-- @param fromTile Frame|nil  the tile clicked to open it; the card grows out of it
function Card.Open(convKey, focus, fromTile)
    if not root then Create() end
    if #Echo.Store.List() == 0 then return end
    if Echo.Stack then Echo.Stack.Hide() end
    local wasShown = root:IsShown()
    if closing then StopEffects() end  -- a close genie running: cancel it, open normally
    local genie = not wasShown and fromTile ~= nil and Animated()
    if not wasShown then
        StopEffects()
        if genie then root:SetAlpha(0) end
    end
    Target(convKey)
    offset = 0
    newBelow = 0
    hint:Hide()
    Anchor()
    root:Show()
    Card.Render()
    if genie then PlayOpen(fromTile) end
    if focus then Card.Focus() end
end

--- Focus the open card's reply box. The key that did it (a keybind) is swallowed: its
-- character, typed in the same frame, doesn't land in the box.
function Card.Focus()
    if not root or not root:IsShown() then return end
    if not edit or not edit:IsShown() then return end
    edit.beforeSwallow = edit:GetText()
    edit:SetFocus()
    edit.swallow = true
    C_Timer.After(0, function() if edit then edit.swallow = false end end)
end

--- Switch the open card to another conversation (opens it if closed).
-- @param convKey string
-- @param fromTile Frame|nil  the tile clicked; the card grows out of it if it was closed
function Card.Show(convKey, fromTile)
    if not root or not root:IsShown() then
        Card.Open(convKey, nil, fromTile)
        return
    end
    if closing then StopEffects() end
    Target(convKey)
    Card.Render()
end

--- A tab click on a group card: show that member.
-- @param convKey string  a member of the shown group
function Card.SelectMember(convKey)
    if not root or not root:IsShown() or not groupIndex or not convKey then return end
    selected[groupIndex] = convKey
    currentKey = convKey
    Card.Render()
end

-- Whether a tile's key is what the card shows now: the conversation itself, or the group
-- the card shows.
local function ShowsKey(convKey)
    if convKey == nil then return false end
    if convKey == renderedKey then return true end
    local index = Echo.Groups and Echo.Groups.IndexOf(convKey)
    return index ~= nil and index == groupIndex
end

--- A tile click: close the card if it already shows this conversation or group, else show it.
-- With the setting on and the tile in view, the close collapses into the tile first; a
-- second click on it during that close is ignored.
-- @param convKey string
-- @param fromTile Frame|nil  the tile clicked; the card grows out of it if it was closed
function Card.Toggle(convKey, fromTile)
    if root and root:IsShown() and ShowsKey(convKey) then
        if closing then return end
        local tile = Animated() and CloseTile(convKey, fromTile)
        if tile then PlayClose(tile) else Card.Hide() end
    else
        Card.Show(convKey, fromTile)
    end
end

function HideNow()
    if not root then return end
    -- root's OnHide does this too (real frames fire it from Hide()); calling it here as
    -- well keeps the harness's stand-in frames, which don't fire OnHide on Hide(), correct.
    ParkDraft()
    if edit then edit:ClearFocus() end
    newBelow = 0
    if hint then hint:Hide() end
    StopEffects()
    root:Hide()
end

--- Close the card at once: Escape, the chevron and combat all need it immediate, so this
-- also cuts short any genie.
function Card.Hide()
    HideNow()
end

--- @return boolean
function Card.IsShown()
    return root ~= nil and root:IsShown()
end

--- The conversation key the card currently has rendered, if any.
-- @return string|nil
function Card.ShownKey()
    return renderedKey
end

-- Show the hint raised above the message area, so it never sits under a bubble, with its
-- text set to the given count.
local function ShowHint(n)
    hint:SetSize(90, 20)
    hint.text:SetWidth(0)
    hint.text:SetText(L["ECHO_NEW_BELOW"]:format(n))
    hint:SetFrameLevel(area:GetFrameLevel() + 5)
    hint:Show()
end

-- The game refused a Nearby send: say why in the hint, widened to hold the sentence.
-- A click dismisses it (and, as for the count, returns to the newest message).
local function ShowBlockedHint()
    local width = Card.WIDTH - Card.PAD * 2 - 16
    hint:SetSize(width, 38)
    hint.text:SetWidth(width - 16)
    hint.text:SetText(L["ECHO_SEND_BLOCKED_NEARBY"])
    hint:SetFrameLevel(area:GetFrameLevel() + 5)
    hint:Show()
end

--- The mouse wheel over the messages: up (+1) shows older ones. Scrolling back down past
-- where the new messages arrived shrinks the count on the hint to match, since some of them
-- are now within reach; it never grows here, only OnStoreChange adds to it.
-- @param delta number
function Card.Scroll(delta)
    if not root or not root:IsShown() then return end
    offset = offset + delta
    Card.Render()
    newBelow = math.min(newBelow, offset)
    if newBelow == 0 then
        hint:Hide()
    else
        ShowHint(newBelow)
    end
end

--- The pin strip's counter: show the next older pin, wrapping round to the newest.
function Card.NextPin()
    if not root or not root:IsShown() or not renderedKey then return end
    local n = #Echo.Store.Pins(renderedKey)
    if n < 2 then return end
    pinIndex = (pinIndex or n) - 1
    if pinIndex < 1 then pinIndex = n end
    Card.Render()
end

-- The pin the strip shows, or nil.
local function ShownPin()
    if not renderedKey then return nil end
    local pins = Echo.Store.Pins(renderedKey)
    local index = pinIndex or #pins
    return pins[index], index
end

--- The pin strip's text: scroll the card so the shown pin's message sits at the bottom of
-- the view, when that message is still in the conversation. Otherwise nothing happens.
function Card.JumpToPin()
    if not root or not root:IsShown() then return end
    local pin, index = ShownPin()
    local conv = pin and Echo.Store.Get(renderedKey)
    if not conv then return end
    local Store = Echo.Store
    local pins = Store.Pins(renderedKey)
    for i = #conv.messages, 1, -1 do
        if Store.PinIndex(renderedKey, conv.messages[i], pins) == index then
            Card.Scroll(#conv.messages - i - offset)
            return
        end
    end
end

--- The pin strip's ×: unpin the pin it shows.
function Card.UnpinShown()
    if not root or not root:IsShown() then return end
    local pin, index = ShownPin()
    if pin then Echo.Store.UnpinMessage(renderedKey, index) end
end

--- The pin strip's tooltip: the whole message, who said it and when.
-- @param owner Frame
function Card.ShowPinTooltip(owner)
    local pin = ShownPin()
    if not pin or not GameTooltip or type(GameTooltip.SetOwner) ~= "function" then return end
    local View = Echo.View
    local who
    if pin.outgoing then
        local name = UnitName and UnitName("player")
        if not Echo.IsSecret(name) and type(name) == "string" then who = name end
    elseif not Echo.IsSecret(pin.sender) and type(pin.sender) == "string" then
        who = pin.sender:match("^([^-]+)") or pin.sender
    end
    if not who then
        -- A Battle.net pin keeps no sender: name the conversation.
        local conv = Echo.Store.Get(renderedKey)
        who = conv and View.DisplayName(conv)
    end
    GameTooltip:SetOwner(owner, "ANCHOR_BOTTOM")
    GameTooltip:ClearLines()
    local a = View.ACCENT
    if not Echo.IsSecret(who) and type(who) == "string" then
        GameTooltip:AddDoubleLine(who, View.PinTime(pin.time), a.r, a.g, a.b, 0.55, 0.60, 0.75)
    else
        GameTooltip:AddLine(View.PinTime(pin.time), 0.55, 0.60, 0.75)
    end
    if not Echo.IsSecret(pin.text) and type(pin.text) == "string" then
        GameTooltip:AddLine(pin.text, 0.92, 0.93, 0.98, true)
    end
    GameTooltip:Show()
end

--- Send the reply box's text to the card's conversation.
function Card.Submit()
    local text = edit and edit:GetText()
    if not currentKey or not text or text == "" then return end
    -- Back to the newest before sending: Send.Send's Store.AddPending marks "card" for
    -- the render that draws the new bubble, which runs on the next frame, so it must
    -- draw at the bottom, not scrolled past.
    offset = 0
    newBelow = 0
    hint:Hide()
    -- A send that can't route keeps its text in the box, so nothing typed is lost. Nothing
    -- was filed either, so no Store change follows to repaint the view around offset 0:
    -- render explicitly so the card doesn't stay showing the scrolled-up messages.
    local sent, problem = Echo.Send.Send(currentKey, text)
    if sent then
        edit:SetText("")
        if problem == "blocked" then ShowBlockedHint() end
    else
        Card.Render()
    end
end

--- Send a failed message again.
-- @param msg table  the failed record
function Card.Retry(msg)
    if not currentKey or not msg or msg.status ~= "failed" then return end
    local sent, problem = Echo.Send.Send(currentKey, msg.text)
    if sent then
        if problem == "blocked" then ShowBlockedHint() end
        -- Send.Send's own Store.AddPending already marked "card" (of the newly filed
        -- part, still "failed" here); mark it again now that this message reads
        -- "retried" so its bubble picks up the dimmed styling once repainted.
        msg.status = "retried"
        Echo.Redraw.Mark("card")
    end
end

--- A Store change. Another conversation's news only touches the tile row; the shown
-- conversation's own changes, a close (which may be the shown one's), and changes with no
-- conversation (reset, restore) redraw the whole card. A message added to the shown
-- conversation while scrolled up keeps the bubbles still and counts it on the hint instead.
-- A close discards that conversation's draft regardless of whether the card is shown.
-- @param convKey string|nil
-- @param change string|nil
function Card.OnStoreChange(convKey, change)
    if change == "closed" then
        Echo.TakeDraft(convKey)
        if convKey == renderedKey then
            edit:SetText("")
            renderedKey = nil
        end
    end
    if not root or not root:IsShown() then return end
    if change == "closed" then
        Echo.Redraw.Mark("card")
        return
    end
    local added = change == "toast" or change == "count" or change == "quiet" or change == "silent"
    if added and convKey == renderedKey and offset > 0 then
        offset = offset + 1
        -- Your own line (an outgoing message, e.g. a retried send) still anchors the view so
        -- it doesn't move, but it isn't news: only an incoming arrival counts on the hint.
        local conv = Echo.Store.Get(convKey)
        local newest = conv and conv.messages[#conv.messages]
        if not (newest and newest.outgoing) then
            newBelow = newBelow + 1
        end
        if newBelow > 0 then
            ShowHint(newBelow)
        else
            hint:Hide()
        end
        Echo.Redraw.Mark("cardRow")
        return
    end
    if convKey and renderedKey and convKey ~= renderedKey then
        Echo.Redraw.Mark("cardRow")
    else
        Echo.Redraw.Mark("card")
    end
end

function Card.Enable()
    if not root then Create() end
    if not Card.subscribed then
        Echo.Store.Subscribe(Card.OnStoreChange)
        Card.subscribed = true
    end
    Echo.Redraw.Register("card", function()
        if root and root:IsShown() then Card.Render() end
    end)
    Echo.Redraw.Register("cardRow", function()
        if root and root:IsShown() and renderedKey then
            local list = Echo.Store.List()
            PaintRow(list)
            local members = ShownMembers(list)
            -- A closed member only reaches here through a full render; an empty group
            -- would be that render's to hide, so leave the tabs as they are.
            if not members or #members > 0 then PaintTabs(members) end
        end
    end)
end

function Card.Disable()
    if Card.subscribed then
        Echo.Store.Unsubscribe(Card.OnStoreChange)
        Card.subscribed = false
    end
    Card.Hide()
    renderedKey, currentKey, groupIndex = nil, nil, nil
    ResetPinCursor()
    selected = {}
end

-- Test and debug handle.
function Card._frames()
    return {
        root = root, rowTiles = rowTiles, name = nameText, meta = metaText, area = area,
        edit = edit, send = send, mode = modeChip, menu = menuButton, chevron = chevron,
        bubbles = bubbles, labels = labels, status = statusLine, hint = hint, rule = rule,
        tabs = tabs, tabStrip = tabStrip, pinStrip = pinStrip,
    }
end
