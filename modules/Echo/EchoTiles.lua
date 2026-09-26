--[[
    Horizon Suite - Echo - Tiles
    The collapsed column: a tile per open conversation or group (Echo.Groups) on a screen
    edge (top entry highest), a +N overflow tile, the stack button (the drag handle when
    unlocked), the "n in chat" marker for messages Echo could not file, and the preview toast.
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
Tiles.LABEL_MAX = 10  -- a whisper tile's name, shrunk from this size...
Tiles.LABEL_MIN = 7   -- ...down to this before any letters are dropped
Tiles.TOAST_WIDTH = 240
Tiles.TOAST_HEIGHT = 48

local STEP = Tiles.TILE_SIZE + Tiles.GAP

local column, stackButton, overflowTile, marker, toast
local tiles = {}
local pending = {}          -- keys to toast after combat, newest first
local queue                 -- View toast queue, made on first Enable
Tiles.holding = false

--- A FontString in Echo's font.
-- @param parent Frame
-- @param size number
-- @param flags string|nil  "" for none; defaults to "OUTLINE"
-- @return FontString
function Echo.NewText(parent, size, flags)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    Echo.TrackFont(fs, size, flags or "OUTLINE")
    return fs
end

--- Draw a tile spec through one host. Every tile host (column tile, card row tile,
-- stack card tile, toast) shares this painter so a face's rules live in one place.
-- @param face table  { bg, icon, letter, label, size, smallSize } - fields a host omits are nil
-- @param spec table  View.TileSpec
function Echo.PaintTileFace(face, spec)
    if face.bg then
        face.bg:SetColorTexture(Echo.View.FaceBackground(spec))
    end
    if face.icon then
        if spec.face == "tabard" then
            local t = spec.tabard
            -- Blizzard's own tabard painter knows where the emblem sits in its texture
            -- (the raw file isn't centred). It also wants background and border textures;
            -- give it hidden spares so only the emblem shows on Echo's rounded tile.
            local drawn = false
            if type(SetSmallGuildTabardTextures) == "function" and face.icon.GetParent then
                local icon = face.icon
                local parent = icon:GetParent()
                if parent and parent.CreateTexture then
                    -- rawget: test stand-ins answer unknown fields with a function.
                    icon._tabardBg = rawget(icon, "_tabardBg") or parent:CreateTexture(nil, "BACKGROUND")
                    icon._tabardBorder = rawget(icon, "_tabardBorder") or parent:CreateTexture(nil, "BACKGROUND")
                    drawn = pcall(SetSmallGuildTabardTextures, "player", icon, icon._tabardBg, icon._tabardBorder)
                    icon._tabardBg:Hide()
                    icon._tabardBorder:Hide()
                end
            end
            if not drawn then
                face.icon:SetTexture(t.emblem)
                face.icon:SetTexCoord(0, 1, 0, 1)
                face.icon:SetVertexColor(t.er, t.eg, t.eb, 1)
            end
            face.icon:Show()
        elseif spec.face == "icon" then
            face.icon:SetTexture(spec.icon)
            if spec.iconFull then
                face.icon:SetTexCoord(0, 1, 0, 1)
            else
                face.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            end
            face.icon:SetVertexColor(1, 1, 1, 1)
            face.icon:Show()
        elseif spec.face == "class" then
            local classIcon = spec.classIcon
            if classIcon.kind == "atlas" then
                face.icon:SetAtlas(classIcon.atlas)
            else
                face.icon:SetTexture(classIcon.path)
                face.icon:SetTexCoord(0, 1, 0, 1)
            end
            face.icon:SetVertexColor(1, 1, 1, 1)
            face.icon:Show()
        else
            face.icon:SetVertexColor(1, 1, 1, 1)
            face.icon:Hide()
        end
    end
    if face.letter then
        local size = spec.small and face.smallSize or face.size
        local flags = face.flags or ""
        if face.letter._echoSize ~= size or face.letter._echoFlags ~= flags then
            Echo.TrackFont(face.letter, size, flags)
            face.letter._echoSize = size
            face.letter._echoFlags = flags
        end
        if spec.face == "letter" or spec.face == "glyph" then
            face.letter:SetText(spec.letter)
        else
            face.letter:SetText("")
        end
        if spec.face == "glyph" then
            face.letter:SetTextColor(spec.r, spec.g, spec.b, 1)
        else
            face.letter:SetTextColor(0.05, 0.05, 0.07, 1)
        end
    end
    if face.label then
        if face.fitWidth then
            Echo.FitText(face.label, spec.label or "", face.fitWidth, face.labelMax, face.labelMin, "OUTLINE")
        else
            face.label:SetText(spec.label or "")
        end
        face.label:SetTextColor(0.95, 0.96, 1, 1)
    end
end

--- Set readable text in the largest size from maxSize down to minSize that fits width;
-- still too wide at minSize, drop characters from the end until it fits. Only for text
-- Echo owns (a whisper key's name): a secret is set as-is and never measured.
-- @param fs FontString
-- @param text string
-- @param width number
-- @param maxSize number
-- @param minSize number
-- @param flags string
-- @return number size  the size used
function Echo.FitText(fs, text, width, maxSize, minSize, flags)
    if Echo.IsSecret(text) or type(text) ~= "string" then
        Echo.TrackFont(fs, maxSize, flags)
        fs:SetText(text)
        return maxSize
    end
    local function Fits()
        local w = fs:GetStringWidth()
        -- No usable measurement (not laid out yet): accept rather than chop.
        return type(w) ~= "number" or w <= width
    end
    for size = maxSize, minSize, -1 do
        Echo.TrackFont(fs, size, flags)
        fs._echoFitSize = size
        fs:SetText(text)
        if Fits() then return size end
    end
    local chars = {}
    for c in text:gmatch("[\1-\127\194-\244][\128-\191]*") do chars[#chars + 1] = c end
    for n = #chars - 1, 1, -1 do
        fs:SetText(table.concat(chars, "", 1, n))
        if Fits() then return minSize end
    end
    return minSize
end

-- The conversation a tile stands for: its own key, or for a group tile the group's newest
-- member (Groups.Newest). The stack isn't grouped, so it only ever sees conversations.
local function MemberKey(key)
    local index = Echo.Groups and Echo.Groups.IndexOf(key)
    if not index then return key end
    local newest = Echo.Groups.Newest(index)
    return newest and newest.key or nil
end

-- A tile hovers its own conversation to the front; the chat button hovers none (top card).
local function HoverEnter(self)
    if Echo.Stack then Echo.Stack.HoverEnter(MemberKey(self and self.convKey)) end
end

local function HoverLeave()
    if Echo.Stack then Echo.Stack.HoverLeave() end
end

local function PaintGlyphFrame(frame, r, g, b)
    local bg = Echo.View.GLYPH_BG
    Echo.Round.SetColor(frame, bg[1], bg[2], bg[3], bg[4])
    Echo.Round.SetBorderColor(frame, r, g, b, 0.8)
end

local function CreateTile()
    local b = CreateFrame("Button", nil, column)
    b:SetSize(Tiles.TILE_SIZE, Tiles.TILE_SIZE)
    Echo.Round.Apply(b, { radius = Echo.Round.TILE, border = true })
    b.letter = Echo.NewText(b, 16, "")
    b.letter:SetPoint("CENTER", b, "CENTER", 0, 0)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetPoint("TOPLEFT", b, "TOPLEFT", 3, -3)
    b.icon:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -3, 3)
    b.icon:Hide()
    -- The label shade is its own small frame so it can be rounded only at the bottom,
    -- matching the tile's own bottom corners.
    b.labelShade = CreateFrame("Frame", nil, b)
    b.labelShade:SetPoint("BOTTOMLEFT", b, "BOTTOMLEFT", 0, 0)
    b.labelShade:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 0, 0)
    b.labelShade:SetHeight(12)
    Echo.Round.Apply(b.labelShade, {
        corners = { tl = 0, tr = 0, bl = Echo.Round.TILE, br = Echo.Round.TILE },
        layer = "ARTWORK",
    })
    Echo.Round.SetColor(b.labelShade, 0, 0, 0, 0.55)
    b.labelShade:Hide()
    -- Parented to the shade, not the tile: a child draws over its parent's own regions
    -- regardless of layer, so a label parented to the tile would sit under the shade.
    b.label = Echo.NewText(b.labelShade, 9, "OUTLINE")
    b.label:SetPoint("BOTTOM", b, "BOTTOM", 0, 2)
    b.label:SetWordWrap(false)
    local a = Echo.View.ACCENT
    -- The unread dot: one fully round texture (Echo.Round.Dot), not a full 9-slice.
    b.dot = Echo.Round.Dot(b, 8, "OVERLAY")
    b.dot:SetPoint("TOPRIGHT", b, "TOPRIGHT", 3, 3)
    b.dot:SetVertexColor(a.r, a.g, a.b, 1)
    -- A small rounded pill behind the count, in the accent colour, sized to fit the text.
    b.countPill = CreateFrame("Frame", nil, b)
    b.countPill:SetHeight(12)
    Echo.Round.Apply(b.countPill, { radius = 6, layer = "ARTWORK" })
    Echo.Round.SetColor(b.countPill, a.r, a.g, a.b, 1)
    b.countPill:Hide()
    -- Parented to the pill, same reason as the label above: otherwise the pill's own fill
    -- draws over the number.
    b.count = Echo.NewText(b.countPill, 10)
    b.count:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -2, 2)
    b:RegisterForClicks("LeftButtonUp")
    b:SetScript("OnClick", function(self)
        if not self.convKey then return end
        if Echo.Card then
            Echo.Card.Toggle(self.convKey, self)
        elseif Echo.Stack then
            Echo.Stack.Open(MemberKey(self.convKey))
        end
    end)
    b:SetScript("OnEnter", HoverEnter)
    b:SetScript("OnLeave", HoverLeave)
    return b
end

-- The column tile keeps its own backdrop (no face.bg), coloured with FaceBackground so it
-- shares the rule every other host uses.
local function PaintTile(b, conv)
    local View = Echo.View
    local spec = View.TileSpec(conv)
    b.convKey = conv.key
    local face = { icon = b.icon, letter = b.letter, label = b.label, size = 16, smallSize = 10, flags = "",
                   fitWidth = Tiles.TILE_SIZE - 4, labelMax = Tiles.LABEL_MAX, labelMin = Tiles.LABEL_MIN }
    -- A guild emblem sits in a centred square above the name; every other icon fills the tile.
    b.icon:ClearAllPoints()
    if spec.face == "tabard" then
        b.icon:SetPoint("TOPLEFT", b, "TOPLEFT", 8, -3)
        b.icon:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -8, 13)
    else
        b.icon:SetPoint("TOPLEFT", b, "TOPLEFT", 3, -3)
        b.icon:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -3, 3)
    end
    Echo.PaintTileFace(face, spec)
    Echo.Round.SetColor(b, View.FaceBackground(spec))
    if spec.face == "glyph" or spec.face == "icon" then
        Echo.Round.SetBorderColor(b, spec.r, spec.g, spec.b, 0.8)
    else
        Echo.Round.SetBorderColor(b, 0, 0, 0, 0.7)
    end
    local hasLabel = spec.label ~= nil and spec.label ~= ""
    b.labelShade:SetShown(hasLabel)
    b.dot:SetShown(spec.badge == "dot")
    local hasCount = spec.badge == "count"
    b.count:SetText(hasCount and tostring(spec.count) or "")
    -- A shown label sits across the bottom; move the count off it so neither is covered,
    -- and put it back at the bottom corner when there's no label to clash with.
    b.count:ClearAllPoints()
    if hasLabel then
        b.count:SetPoint("TOPLEFT", b, "TOPLEFT", 2, -2)
    else
        b.count:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -2, 2)
    end
    if hasCount then
        local textW = b.count.GetStringWidth and b.count:GetStringWidth()
        if type(textW) ~= "number" or textW <= 0 then textW = 8 end
        b.countPill:ClearAllPoints()
        b.countPill:SetPoint("CENTER", b.count, "CENTER", 0, 0)
        b.countPill:SetSize(math.max(12, textW + 6), 12)
        Echo.Round.Layout(b.countPill)
        b.countPill:Show()
    else
        b.countPill:Hide()
    end
    b:Show()
end

-- Saved in screen units (the column's own coordinates times its scale), so a scale change
-- leaves the column where it was.
local function SavePosition()
    local x = column:GetCenter()
    local y = column:GetBottom()
    if not x or not y then return end
    local scale = column:GetScale() or 1
    addon.SetDB("echoX", math.floor(x * scale + 0.5))
    addon.SetDB("echoY", math.floor(y * scale + 0.5))
end

--- Anchor, scale and strata from settings. Unmoved, the column sits in the bottom corner
-- of its edge and grows upward; once dragged it is anchored by its bottom centre.
local VALID_STRATA = { BACKGROUND = true, LOW = true, MEDIUM = true, HIGH = true, DIALOG = true }

function Tiles.ApplyPosition()
    if not column then return end
    local scale = tonumber(Echo.Setting("echoScale"))
    local limits = addon.ECHO_LIMITS and addon.ECHO_LIMITS.echoScale
    local minScale, maxScale = (limits and limits.min) or 0.6, (limits and limits.max) or 1.6
    if type(scale) ~= "number" or scale <= 0 then
        scale = 1
    else
        scale = math.max(minScale, math.min(maxScale, scale))
    end
    column:SetScale(scale)
    local strata = Echo.Setting("echoFrameStrata")
    if not VALID_STRATA[strata] then strata = "MEDIUM" end
    column:SetFrameStrata(strata)
    column:ClearAllPoints()
    local x, y = tonumber(Echo.Setting("echoX")), tonumber(Echo.Setting("echoY"))
    if x and y then
        column:SetPoint("BOTTOM", UIParent, "BOTTOMLEFT", x / scale, y / scale)
    elseif Echo.Setting("echoColumnEdge") == "left" then
        column:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 24 / scale, 240 / scale)
    else
        column:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -24 / scale, 240 / scale)
    end
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

    stackButton = CreateFrame("Button", nil, column)
    stackButton:SetSize(Tiles.TILE_SIZE, Tiles.TILE_SIZE)
    stackButton:SetPoint("BOTTOM", column, "BOTTOM", 0, 0)
    -- No panel fill or border here: the Echo icon below is already a rounded tile with
    -- transparent corners, so it carries its own frame.
    local icon = stackButton:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", stackButton, "TOPLEFT", 1, -1)
    icon:SetPoint("BOTTOMRIGHT", stackButton, "BOTTOMRIGHT", -1, 1)
    icon:SetTexture(View.ECHO_ICON)
    stackButton.icon = icon
    -- Hover brightens the icon via an additive OVERLAY highlight (vertex-colour brightening
    -- alone clamps at 1.0 and barely shows), shown on enter and hidden on leave.
    local highlight = stackButton:CreateTexture(nil, "OVERLAY")
    highlight:SetAllPoints(icon)
    highlight:SetTexture(View.ECHO_ICON)
    highlight:SetBlendMode("ADD")
    highlight:SetAlpha(0.25)
    highlight:Hide()
    stackButton.highlight = highlight
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
        -- An Auto edge may have flipped sides; Echo.ApplyOptions re-anchors the column
        -- and re-anchors any open stack or card to match (Tiles.ApplyPosition alone
        -- would leave them on the old side).
        Echo.ApplyOptions()
    end)
    stackButton:SetScript("OnEnter", function(self)
        highlight:Show()
        HoverEnter(self)
    end)
    stackButton:SetScript("OnLeave", function()
        highlight:Hide()
        HoverLeave()
    end)

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
    local visible, overflow, entries = View.Column(list, math.max(2, tonumber(Echo.Setting("echoMaxTiles")) or 8))
    local slot = 1
    if overflow > 0 then
        -- The first hidden entry; a group stands in for its first member (a real conversation).
        local first = entries[#visible + 1]
        overflowTile.convKey = (first.members and first.members[1] or first).key
        overflowTile.letter:SetText("+" .. overflow)
        PaintGlyphFrame(overflowTile, View.ACCENT.r, View.ACCENT.g, View.ACCENT.b)
        overflowTile.letter:SetTextColor(0.85, 0.87, 0.95, 1)
        overflowTile.dot:Hide()
        overflowTile.icon:Hide()
        overflowTile.count:SetText("")
        overflowTile.countPill:Hide()
        overflowTile.label:SetText("")
        overflowTile.labelShade:Hide()
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

local function ShownTile(key)
    for _, b in ipairs(tiles) do
        if b.convKey == key and b:IsShown() then return b end
    end
    return nil
end

--- The frame a conversation's toast (and the card's genie) points at: its tile, or the tile
-- of the group it belongs to, else nil.
-- @param convKey string  a conversation key or a group key
-- @return Frame|nil
function Tiles.TileFor(convKey)
    local tile = ShownTile(convKey)
    if tile then return tile end
    local index = Echo.Groups and Echo.Groups.Of(convKey)
    if index then return ShownTile(Echo.Groups.Key(index)) end
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
    local side = Echo.View.PanelSides(Echo.View.Edge())
    self:SetPoint(side.toast, self.anchor, side.toastRel, side.toastDir * (8 + offset), 0)
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
    -- entry.icon is also the toast's chrome anchor (ApplyChrome positions it); the face's
    -- own icon paints onto this overlay above it instead of onto the anchor itself.
    entry.face = f:CreateTexture(nil, "OVERLAY")
    entry.face:SetAllPoints(entry.icon)
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
        local view = Echo.Card or Echo.Stack
        if self.convKey and view then view.Open(self.convKey) end
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
    local face = { bg = entry.icon, icon = entry.face, letter = entry.letter, size = 14, smallSize = 9, flags = "" }
    Echo.PaintTileFace(face, spec)
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
    local side = View.PanelSides(Echo.View.Edge())
    toast:SetPoint(side.toast, toast.anchor, side.toastRel, side.toastDir * 8, 0)
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

--- Store listener: mark the column for repainting, then toast or hold a loud message.
-- A loud message repaints at once: its toast points at the tile it has just moved to.
function Tiles.OnStoreChange(convKey, change)
    if change == "toast" then
        Tiles.Refresh()
    else
        Echo.Redraw.Mark("tiles")
        return
    end
    if not convKey then return end
    -- The open stack or card already shows the conversation (it re-renders, its tile
    -- badges); a toast over it would only cover it, and a held one would replay stale later.
    local stack = _G.HorizonSuiteEchoStack
    if stack and stack:IsShown() then return end
    local card = _G.HorizonSuiteEchoCard
    if card and card:IsShown() then return end
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
    Echo.Redraw.Register("tiles", Tiles.Refresh)
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
function Tiles._savePosition() SavePosition() end
