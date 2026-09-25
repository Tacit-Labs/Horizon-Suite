--[[
    Horizon Suite - Echo - Tiles
    The collapsed column: a tile per open conversation on a screen edge (top conversation
    highest), a +N overflow tile, the stack button (the drag handle when unlocked), the
    "n in chat" marker for messages Echo could not file, and the preview toast.
    Blizzard: CreateFrame, FCF_SelectDockFrame. Shared: Augment toast chrome and motion.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo
local L = addon.L

local Tiles = {}
Echo.Tiles = Tiles

Tiles.TILE_SIZE = 40
Tiles.GAP = 6
Tiles.TOAST_WIDTH = 240
Tiles.TOAST_HEIGHT = 48

local STEP = Tiles.TILE_SIZE + Tiles.GAP

Echo.FLAT = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
}

local column, stackButton, overflowTile, marker, toast
local tiles = {}
local pending = {}          -- keys to toast after combat, newest first
local queue                 -- View toast queue, made on first Enable
Tiles.holding = false

local function FontPath()
    return (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"
end

--- A FontString in the addon's default font.
-- @param parent Frame
-- @param size number
-- @param flags string|nil  "" for none; defaults to "OUTLINE"
-- @return FontString
function Echo.NewText(parent, size, flags)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetFont(FontPath(), size, flags or "OUTLINE")
    return fs
end

-- A tile hovers its own conversation to the front; the chat button hovers none (top card).
local function HoverEnter(self)
    if Echo.Stack then Echo.Stack.HoverEnter(self and self.convKey) end
end

local function HoverLeave()
    if Echo.Stack then Echo.Stack.HoverLeave() end
end

local function PaintGlyphFrame(frame, r, g, b)
    local bg = Echo.View.GLYPH_BG
    frame:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
    frame:SetBackdropBorderColor(r, g, b, 0.8)
end

local function CreateTile()
    local b = CreateFrame("Button", nil, column, "BackdropTemplate")
    b:SetSize(Tiles.TILE_SIZE, Tiles.TILE_SIZE)
    b:SetBackdrop(Echo.FLAT)
    b.letter = Echo.NewText(b, 16, "")
    b.letter:SetPoint("CENTER", b, "CENTER", 0, 0)
    local a = Echo.View.ACCENT
    b.dot = b:CreateTexture(nil, "OVERLAY")
    b.dot:SetSize(8, 8)
    b.dot:SetPoint("TOPRIGHT", b, "TOPRIGHT", 3, 3)
    b.dot:SetColorTexture(a.r, a.g, a.b, 1)
    b.count = Echo.NewText(b, 10)
    b.count:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -2, 2)
    b:RegisterForClicks("LeftButtonUp")
    b:SetScript("OnClick", function(self)
        if self.convKey and Echo.Stack then Echo.Stack.Open(self.convKey) end
    end)
    b:SetScript("OnEnter", HoverEnter)
    b:SetScript("OnLeave", HoverLeave)
    return b
end

local function PaintTile(b, conv)
    local spec = Echo.View.TileSpec(conv)
    b.convKey = conv.key
    b.letter:SetText(spec.letter)
    if spec.glyph then
        PaintGlyphFrame(b, spec.r, spec.g, spec.b)
        b.letter:SetTextColor(spec.r, spec.g, spec.b, 1)
    else
        b:SetBackdropColor(spec.r, spec.g, spec.b, 0.95)
        b:SetBackdropBorderColor(0, 0, 0, 0.7)
        b.letter:SetTextColor(0.05, 0.05, 0.07, 1)
    end
    b.dot:SetShown(spec.badge == "dot")
    b.count:SetText(spec.badge == "count" and tostring(spec.count) or "")
    b:Show()
end

local function SavePosition()
    local x = column:GetCenter()
    local y = column:GetBottom()
    if not x or not y then return end
    addon.SetDB("echoX", math.floor(x + 0.5))
    addon.SetDB("echoY", math.floor(y + 0.5))
end

--- Anchor, scale and strata from settings. Unmoved, the column sits bottom right and
-- grows upward; once dragged it is anchored by its bottom centre.
function Tiles.ApplyPosition()
    if not column then return end
    column:ClearAllPoints()
    local x, y = tonumber(Echo.Setting("echoX")), tonumber(Echo.Setting("echoY"))
    if x and y then
        column:SetPoint("BOTTOM", UIParent, "BOTTOMLEFT", x, y)
    else
        column:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -24, 240)
    end
    column:SetScale(tonumber(Echo.Setting("echoScale")) or 1)
    column:SetFrameStrata(Echo.Setting("echoFrameStrata") or "MEDIUM")
end

function Tiles.ResetPosition()
    addon.SetDB("echoX", nil)
    addon.SetDB("echoY", nil)
    Tiles.ApplyPosition()
end

local function CreateColumn()
    local View = Echo.View
    column = CreateFrame("Frame", "HorizonSuiteEchoColumn", UIParent)
    column:SetSize(Tiles.TILE_SIZE, Tiles.TILE_SIZE)
    column:SetMovable(true)
    column:SetClampedToScreen(true)
    -- ApplyPosition owns the anchor; WoW's layout cache restoring a stale one would fight it.
    if column.SetDontSavePosition then column:SetDontSavePosition(true) end

    stackButton = CreateFrame("Button", nil, column, "BackdropTemplate")
    stackButton:SetSize(Tiles.TILE_SIZE, Tiles.TILE_SIZE)
    stackButton:SetPoint("BOTTOM", column, "BOTTOM", 0, 0)
    stackButton:SetBackdrop(Echo.FLAT)
    stackButton:SetBackdropColor(View.PANEL_BG[1], View.PANEL_BG[2], View.PANEL_BG[3], View.PANEL_BG[4])
    stackButton:SetBackdropBorderColor(View.PANEL_BORDER[1], View.PANEL_BORDER[2], View.PANEL_BORDER[3], View.PANEL_BORDER[4])
    local icon = stackButton:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", stackButton, "CENTER", 0, 0)
    icon:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-Chat-Up")
    stackButton:RegisterForClicks("LeftButtonUp")
    stackButton:RegisterForDrag("LeftButton")
    stackButton:SetScript("OnClick", function()
        if Echo.Stack then Echo.Stack.Toggle() end
    end)
    stackButton:SetScript("OnDragStart", function()
        if InCombatLockdown() or Echo.Setting("echoLockPosition") then return end
        column.moving = true
        column:StartMoving()
    end)
    stackButton:SetScript("OnDragStop", function()
        if not column.moving then return end
        column.moving = false
        column:StopMovingOrSizing()
        SavePosition()
        Tiles.ApplyPosition()
    end)
    stackButton:SetScript("OnEnter", HoverEnter)
    stackButton:SetScript("OnLeave", HoverLeave)

    marker = CreateFrame("Button", nil, column)
    marker:SetSize(90, 16)
    marker:SetPoint("RIGHT", stackButton, "LEFT", -6, 0)
    marker.text = Echo.NewText(marker, 11)
    marker.text:SetPoint("RIGHT", marker, "RIGHT", 0, 0)
    marker.text:SetTextColor(0.75, 0.77, 0.85, 1)
    marker:SetScript("OnClick", function()
        Echo.Store.ClearUnrouted()
        if FCF_SelectDockFrame and DEFAULT_CHAT_FRAME then pcall(FCF_SelectDockFrame, DEFAULT_CHAT_FRAME) end
    end)
    marker:Hide()

    overflowTile = CreateTile()
    overflowTile:Hide()
end

--- Redraw every tile from the Store. Cheap: at most echoMaxTiles + 1 frames.
function Tiles.Refresh()
    if not column or not column:IsShown() then return end
    local View = Echo.View
    local list = Echo.Store.List()
    local visible, overflow = View.Column(list, tonumber(Echo.Setting("echoMaxTiles")) or 8)
    local slot = 1
    if overflow > 0 then
        overflowTile.convKey = list[#visible + 1].key
        overflowTile.letter:SetText("+" .. overflow)
        PaintGlyphFrame(overflowTile, View.ACCENT.r, View.ACCENT.g, View.ACCENT.b)
        overflowTile.letter:SetTextColor(0.85, 0.87, 0.95, 1)
        overflowTile.dot:Hide()
        overflowTile.count:SetText("")
        overflowTile:ClearAllPoints()
        overflowTile:SetPoint("BOTTOM", column, "BOTTOM", 0, slot * STEP)
        overflowTile:Show()
        slot = slot + 1
    else
        overflowTile.convKey = nil
        overflowTile:Hide()
    end
    for i = #visible, 1, -1 do
        local b = tiles[i]
        if not b then
            b = CreateTile()
            tiles[i] = b
        end
        PaintTile(b, visible[i])
        b:ClearAllPoints()
        b:SetPoint("BOTTOM", column, "BOTTOM", 0, slot * STEP)
        slot = slot + 1
    end
    for i = #visible + 1, #tiles do
        tiles[i].convKey = nil
        tiles[i]:Hide()
    end
    column:SetHeight(slot * STEP - Tiles.GAP)

    local unrouted = Echo.Store.GetUnroutedCount()
    marker.text:SetText(unrouted > 0 and L["ECHO_IN_CHAT"]:format(unrouted) or "")
    marker:SetShown(unrouted > 0)
end

--- The frame a conversation's toast points at: its tile, else nil.
-- @param convKey string
-- @return Frame|nil
function Tiles.TileFor(convKey)
    for _, b in ipairs(tiles) do
        if b.convKey == convKey and b:IsShown() then return b end
    end
    return nil
end

local function ToastUpdate(self, elapsed)
    local M = addon.Augment and addon.Augment.ToastMotion
    if not M then
        self:Hide()
        return
    end
    local hold = self.hold or 4
    if self:IsMouseOver() and self.t >= M.ENTRANCE_DUR then
        self.t = M.ENTRANCE_DUR  -- hovering keeps it up; the hold restarts on leave
    else
        self.t = self.t + elapsed
    end
    local alpha, offset = 1, 0
    if self.t < M.ENTRANCE_DUR then
        local p = M.Ease(self.t / M.ENTRANCE_DUR)
        alpha, offset = p, (1 - p) * M.SLIDE_DIST
    elseif self.t >= M.ENTRANCE_DUR + hold then
        local p = (self.t - M.ENTRANCE_DUR - hold) / M.EXIT_DUR
        if p >= 1 then
            self:Hide()
            Tiles.NextToast()
            return
        end
        alpha = 1 - M.Ease(p, "in")
    end
    self:SetAlpha(alpha)
    -- A Refresh can hand the tile this toast pointed at to another conversation, or hide
    -- it; follow the conversation, not the frame.
    self.anchor = Tiles.TileFor(self.convKey) or stackButton
    self:ClearAllPoints()
    self:SetPoint("RIGHT", self.anchor, "LEFT", -8 - offset, 0)
end

local function CreateToast()
    local f = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
    f:SetSize(Tiles.TOAST_WIDTH, Tiles.TOAST_HEIGHT)
    f:SetClampedToScreen(true)
    f:Hide()
    local entry = { frame = f }
    entry.iconBg = f:CreateTexture(nil, "BACKGROUND")
    entry.iconDark = f:CreateTexture(nil, "BORDER")
    entry.iconDark:SetColorTexture(0, 0, 0, 0.6)
    entry.icon = f:CreateTexture(nil, "ARTWORK")
    entry.letter = Echo.NewText(f, 14, "")
    entry.letter:SetPoint("CENTER", entry.icon, "CENTER", 0, 0)
    entry.title = Echo.NewText(f, 12)
    entry.title:SetJustifyH("LEFT")
    entry.title:SetWordWrap(false)
    entry.body = Echo.NewText(f, 12, "")
    entry.body:SetJustifyH("LEFT")
    entry.body:SetWordWrap(false)
    entry.body:SetTextColor(0.92, 0.93, 0.97, 1)
    f.entry = entry
    f.t = 0
    f:RegisterForClicks("LeftButtonUp")
    f:SetScript("OnClick", function(self)
        self:Hide()
        -- The player has engaged; toasts still held from combat are stale now.
        pending = {}
        if self.convKey and Echo.Stack then Echo.Stack.Open(self.convKey) end
    end)
    f:SetScript("OnUpdate", ToastUpdate)
    toast = f
end

--- Show a conversation's newest incoming message beside its tile.
-- @param convKey string
-- @return boolean shown
function Tiles.ShowToast(convKey)
    if not column or not column:IsShown() then return false end
    local View = Echo.View
    local conv = Echo.Store.Get(convKey)
    local msg = conv and View.LastIncoming(conv)
    if not msg then return false end
    if not toast then CreateToast() end
    local entry = toast.entry
    local spec = View.TileSpec(conv)
    if spec.glyph then
        local bg = View.GLYPH_BG
        entry.icon:SetColorTexture(bg[1], bg[2], bg[3], 1)
        entry.letter:SetTextColor(spec.r, spec.g, spec.b, 1)
    else
        entry.icon:SetColorTexture(spec.r, spec.g, spec.b, 1)
        entry.letter:SetTextColor(0.05, 0.05, 0.07, 1)
    end
    entry.letter:SetText(spec.letter)
    entry.title:SetText(View.DisplayName(conv))
    if msg.secret or Echo.IsSecret(msg.text) then
        entry.body:SetText(L["ECHO_NEW_MESSAGE"])
    else
        entry.body:SetText(View.LineText(conv, msg))
    end
    local TS = addon.Augment and addon.Augment.ToastStyles
    if TS and TS.ApplyChrome then
        local a = View.ACCENT
        TS.ApplyChrome(entry, Echo.Setting("echoToastStyle"),
            { r = a.r, g = a.g, b = a.b, br = spec.r, bg = spec.g, bb = spec.b },
            { textMode = "dual", iconSide = "left", iconSize = 28, iconGap = 8, iconBgPad = 2,
              scale = function(v) return v end })
    end
    toast:SetScale(column:GetScale())
    toast:SetFrameStrata(column:GetFrameStrata())
    toast.anchor = Tiles.TileFor(convKey) or stackButton
    toast.convKey = convKey
    toast.hold = tonumber(Echo.Setting("echoToastSeconds")) or 4
    toast.t = 0
    toast:SetAlpha(0)
    toast:ClearAllPoints()
    toast:SetPoint("RIGHT", toast.anchor, "LEFT", -8, 0)
    toast:Show()
    return true
end

-- Queue a conversation's toast under its newest message's seq, so release plays newest first.
local function HoldKey(convKey)
    local conv = Echo.Store.Get(convKey)
    local last = conv and conv.messages[#conv.messages]
    queue:Hold(convKey, last and last.seq or 0)
end

--- Play the next toast held over from combat.
function Tiles.NextToast()
    if Tiles.holding then return end
    while #pending > 0 do
        local key = table.remove(pending, 1)
        if Tiles.ShowToast(key) then return end
    end
end

--- Hold loud toasts (combat) or release them, newest first, one per conversation.
-- @param on boolean
function Tiles.Hold(on)
    Tiles.holding = on and true or false
    if not queue then queue = Echo.View.NewToastQueue() end
    if Tiles.holding then
        -- Combat started again before the last release finished playing: hold the rest
        -- so they replay after this fight instead of popping up during it.
        for _, key in ipairs(pending) do HoldKey(key) end
        pending = {}
    else
        pending = queue:Release()
        Tiles.NextToast()
    end
end

--- Store listener: redraw, then toast or hold a loud message.
function Tiles.OnStoreChange(convKey, change)
    Tiles.Refresh()
    if change ~= "toast" or not convKey then return end
    -- The open stack already shows the conversation (its card re-renders, its tile badges);
    -- a toast over it would only cover the stack, and a held one would replay stale later.
    local stack = _G.HorizonSuiteEchoStack
    if stack and stack:IsShown() then return end
    if Tiles.holding then
        HoldKey(convKey)
    else
        Tiles.ShowToast(convKey)
    end
end

function Tiles.Enable()
    if not column then CreateColumn() end
    if not queue then queue = Echo.View.NewToastQueue() end
    if not Tiles.subscribed then
        Echo.Store.Subscribe(Tiles.OnStoreChange)
        Tiles.subscribed = true
    end
    Tiles.ApplyPosition()
    column:Show()
    Tiles.Refresh()
end

function Tiles.Disable()
    if Tiles.subscribed then
        Echo.Store.Unsubscribe(Tiles.OnStoreChange)
        Tiles.subscribed = false
    end
    if toast then toast:Hide() end
    if column then column:Hide() end
    pending = {}
    Tiles.holding = false
end

-- Test and debug handles.
function Tiles._toast() return toast end
function Tiles._overflow() return overflowTile end
function Tiles._marker() return marker end
function Tiles._stackButton() return stackButton end
