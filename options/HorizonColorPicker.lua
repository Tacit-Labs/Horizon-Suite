--[[ Horizon Suite — Custom colour picker (replaces Blizzard ColorPickerFrame). ]]
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = addon.L
local Def = addon.OptionsWidgetsDef  -- design tokens exported by OptionsWidgets.lua

-- Use the shared widget font setter so our text registers in the same font registry as every other
-- options widget — it then refreshes/shadows with the global dashboard font automatically.
-- Pass nil flags so it adopts Def.WidgetFontFlags and registers for OptionsWidgets_RefreshFonts.
local SafeFont = addon.OptionsWidgets_SetSafeFont or function(fs, path, size, flags)
    if fs and fs.SetFont then fs:SetFont(path, size, flags or "OUTLINE") end
end

local PICKER_W, PICKER_H = 360, 312
local WHEEL_SIZE = 128
local VALUE_W = 24
local ALPHA_TRACK_H = 10
local ALPHA_THUMB = 14

local PRESET_COLS = 4
local PRESET_GAP = 6
local PALETTE_CAP = 6  -- max user-saved colours (class + 6 saved + "+" = 8 cells = 2 rows of 4)
-- Derived widths so the hex+RGB row and the preset grid each fill their column edge-to-edge.
local CONTENT_W = PICKER_W - 28                                            -- usable width (14px pad each side)
local FIELD_GAP = 8
local FIELD_W = math.floor((CONTENT_W - 3 * FIELD_GAP) / 4)                -- hex + R + G + B fill the row
local RIGHTCOL_W = PICKER_W - 14 - (14 + (WHEEL_SIZE + VALUE_W + 24) + 14) -- right column (compare/presets) width
local PRESET_SIZE = math.floor((RIGHTCOL_W - (PRESET_COLS - 1) * PRESET_GAP) / PRESET_COLS)

local function Round(x) return math.floor(x * 255 + 0.5) end

-- Parse a hex colour string ("ff0000", "#ff0000", "f00") to r,g,b in 0-1, or nil. (Moved here from
-- OptionsWidgets.lua; exported so anything else can reuse it.)
local function ParseHexColor(raw)
    if type(raw) ~= "string" then return nil end
    local hex = raw:gsub("^#", ""):gsub("%s+", "")
    if #hex < 3 then return nil end
    if #hex == 3 then hex = hex:gsub("(%x)(%x)(%x)", "%1%1%2%2%3%3") end
    hex = hex:sub(1, 6)
    while #hex < 6 do hex = hex .. "0" end
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    if not r or not g or not b then return nil end
    return r / 255, g / 255, b / 255
end
addon.ParseHexColor = ParseHexColor

-- Singleton state.
local P            -- the picker frame (built lazily)
local state = { spec = nil, r = 1, g = 1, b = 1, a = 1, hasAlpha = false, suppress = false, orig = {} }

-- Account-wide saved palette: an ordered list of hex strings at the SavedVariables root
-- (HorizonDB.customPalette), independent of profiles.
local function PaletteStore()
    local db = _G[addon.DATABASE]
    if not db then return nil end
    db.customPalette = db.customPalette or {}
    return db.customPalette
end

local function ToHex(r, g, b)
    return string.format("%02X%02X%02X", Round(r), Round(g), Round(b))
end

-- Returns an array of { r, g, b } from the stored hex list (skipping unparseable entries).
local function LoadPalette()
    local store, out = PaletteStore(), {}
    if store then
        for _, hex in ipairs(store) do
            local r, g, b = ParseHexColor(hex)
            if r then out[#out + 1] = { r, g, b } end
        end
    end
    return out
end

local function AddCurrentToPalette()
    addon.EnsureDB()
    local store = PaletteStore()
    if not store then return end
    if #store >= PALETTE_CAP then return end
    local hex = ToHex(state.r, state.g, state.b)
    for _, h in ipairs(store) do
        if type(h) == "string" and h:upper() == hex then return end  -- dedupe
    end
    store[#store + 1] = hex
    if P and P.BuildPalette then P:BuildPalette() end
end

local function RemoveFromPalette(i)
    local store = PaletteStore()
    if not store or not store[i] then return end
    table.remove(store, i)
    if P and P.BuildPalette then P:BuildPalette() end
end

-- The player's class colour (ungated — always available as a quick-pick).
local function PlayerClassColor()
    local _, classFile = UnitClass("player")
    if not classFile then return nil end
    local cc = C_ClassColor and C_ClassColor.GetClassColor and C_ClassColor.GetClassColor(classFile)
    if cc then return cc.r, cc.g, cc.b end
    local rc = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
    if rc then return rc.r, rc.g, rc.b end
    return nil
end

local function FireChange()
    local s = state.spec
    if s and s.onChange then s.onChange(state.r, state.g, state.b, state.a) end
end

local function ConfirmClose()
    if not P then return end
    state.confirmed = true
    local s = state.spec
    if s and s.onConfirm then s.onConfirm(state.r, state.g, state.b, state.a) end
    P:Hide()
end

local function CancelClose()
    if not P then return end
    P:Hide()   -- OnHide fires onCancel because confirmed is false
end

local function EnsurePicker()
    if P then return P end

    local f = CreateFrame("Frame", "HorizonColorPicker", UIParent, "BackdropTemplate")
    f:SetSize(PICKER_W, PICKER_H)
    f:SetPoint("CENTER")
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetToplevel(true)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:Hide()
    if f.SetBackdrop and addon.OptionsWidgetsSectionCardBackdrop then
        f:SetBackdrop(addon.OptionsWidgetsSectionCardBackdrop)
        f:SetBackdropColor(Def.SectionCardBg[1], Def.SectionCardBg[2], Def.SectionCardBg[3], Def.SectionCardBg[4] or 1)
        f:SetBackdropBorderColor(Def.SectionCardBorder[1], Def.SectionCardBorder[2], Def.SectionCardBorder[3], 1)
    end

    -- Title bar (drag handle) + close button.
    local titleText = f:CreateFontString(nil, "OVERLAY")
    SafeFont(titleText, Def.FontPath, Def.HeaderSize or 16, nil)
    titleText:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -12)
    titleText:SetText((L and L["COLOR_PICKER_TITLE"]) or "Choose a colour")
    titleText:SetTextColor(Def.TextColorTitleBar[1], Def.TextColorTitleBar[2], Def.TextColorTitleBar[3], 1)

    local drag = CreateFrame("Frame", nil, f)
    drag:SetPoint("TOPLEFT", 0, 0); drag:SetPoint("TOPRIGHT", f, "TOPRIGHT", -34, 0); drag:SetHeight(34)
    drag:EnableMouse(true); drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function() f:StartMoving() end)
    drag:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)

    local close = CreateFrame("Button", nil, f)
    close:SetSize(20, 20); close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -10)
    close:SetFrameLevel((f:GetFrameLevel() or 1) + 10)
    local cx = close:CreateFontString(nil, "OVERLAY")
    SafeFont(cx, Def.FontPath, 16, nil); cx:SetPoint("CENTER"); cx:SetText("\195\151") -- ×
    cx:SetTextColor(Def.TextColorSection[1], Def.TextColorSection[2], Def.TextColorSection[3], 1)
    close:SetScript("OnClick", function() CancelClose() end)

    -- Divider under the title bar.
    local titleDivider = f:CreateTexture(nil, "ARTWORK")
    titleDivider:SetHeight(1)
    titleDivider:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -34)
    titleDivider:SetPoint("TOPRIGHT", f, "TOPRIGHT", -12, -34)
    titleDivider:SetColorTexture(Def.SectionCardBorder[1], Def.SectionCardBorder[2], Def.SectionCardBorder[3], 0.6)

    -- Esc closes (cancel). Registered as a special frame.
    f:SetScript("OnKeyDown", function(_, key) if key == "ESCAPE" then CancelClose() end end)
    f:SetPropagateKeyboardInput(true)
    tinsert(UISpecialFrames, "HorizonColorPicker")

    -- ColorSelect: hue/sat wheel + value bar.
    local cs = CreateFrame("ColorSelect", nil, f)
    cs:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -40)
    cs:SetSize(WHEEL_SIZE + VALUE_W + 24, WHEEL_SIZE)

    -- SPIKE: ColorSelect paints the wheel/value art itself; here we hand it created Texture objects.
    -- If the wheel/value renders blank in-game, the alternative is passing a texture *path string*
    -- to SetColorWheelTexture / SetColorValueTexture instead of a Texture object.
    local wheel = cs:CreateTexture(nil, "OVERLAY")
    wheel:SetSize(WHEEL_SIZE, WHEEL_SIZE)
    wheel:SetPoint("TOPLEFT", cs, "TOPLEFT", 0, -7)
    cs:SetColorWheelTexture(wheel)
    -- Circular mask softens the wheel's aliased rim.
    local wheelMask = cs:CreateMaskTexture(nil, "OVERLAY")
    wheelMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    wheelMask:SetAllPoints(wheel)
    wheel:AddMaskTexture(wheelMask)

    -- Clean solid markers (the Blizzard UI-ColorPicker-Buttons sprite sheet drew a stray blob).
    local wheelThumb = cs:CreateTexture(nil, "OVERLAY")
    wheelThumb:SetSize(12, 12); wheelThumb:SetColorTexture(1, 1, 1, 0.95)
    cs:SetColorWheelThumbTexture(wheelThumb)
    -- Circular mask makes the wheel marker a clean circle (not a solid square).
    local wheelThumbMask = cs:CreateMaskTexture(nil, "OVERLAY")
    wheelThumbMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    wheelThumbMask:SetAllPoints(wheelThumb)
    wheelThumb:AddMaskTexture(wheelThumbMask)

    local value = cs:CreateTexture(nil, "OVERLAY")
    value:SetSize(VALUE_W, WHEEL_SIZE)
    value:SetPoint("TOPLEFT", wheel, "TOPRIGHT", 16, 0)
    cs:SetColorValueTexture(value)

    local valueThumb = cs:CreateTexture(nil, "OVERLAY")
    valueThumb:SetSize(VALUE_W + 6, 4); valueThumb:SetColorTexture(1, 1, 1, 0.95)
    cs:SetColorValueThumbTexture(valueThumb)

    cs:SetScript("OnColorSelect", function(_, r, g, b)
        if state.suppress then return end
        state.r, state.g, state.b = r, g, b
        if P and P.Refresh then P:Refresh() end
        FireChange()
    end)

    -- New (live) vs Current (original) comparison.
    local cmp = CreateFrame("Frame", nil, f)
    cmp:SetPoint("TOPLEFT", cs, "TOPRIGHT", 14, -2)
    cmp:SetPoint("RIGHT", f, "RIGHT", -14, 0)
    cmp:SetHeight(26)
    local newSw = cmp:CreateTexture(nil, "ARTWORK")
    newSw:SetPoint("TOPLEFT", cmp, "TOPLEFT", 0, 0)
    newSw:SetPoint("BOTTOM", cmp, "BOTTOM", 0, 0)
    newSw:SetPoint("RIGHT", cmp, "CENTER", 0, 0)
    local oldSw = cmp:CreateTexture(nil, "ARTWORK")
    oldSw:SetPoint("TOPLEFT", newSw, "TOPRIGHT", 0, 0)
    oldSw:SetPoint("BOTTOMRIGHT", cmp, "BOTTOMRIGHT", 0, 0)
    if addon.CreateBorder then addon.CreateBorder(cmp, Def.InputBorder) end
    f.newSwatch = newSw
    f.oldSwatch = oldSw

    -- Hex input.
    local hexWrap = CreateFrame("Frame", nil, f)
    hexWrap:SetSize(FIELD_W, 22)
    hexWrap:SetPoint("TOPLEFT", cs, "BOTTOMLEFT", 0, -16)  -- combined hex + R/G/B row below the wheel
    local hexBg = hexWrap:CreateTexture(nil, "BACKGROUND")
    hexBg:SetAllPoints(hexWrap)
    hexBg:SetColorTexture(Def.InputBg[1], Def.InputBg[2], Def.InputBg[3], Def.InputBg[4])
    if addon.CreateBorder then addon.CreateBorder(hexWrap, Def.InputBorder) end
    local hexHash = hexWrap:CreateFontString(nil, "OVERLAY")
    SafeFont(hexHash, Def.FontPath, Def.LabelSize, nil)
    hexHash:SetPoint("LEFT", hexWrap, "LEFT", 6, 0); hexHash:SetText("#")
    hexHash:SetTextColor(Def.TextColorSection[1], Def.TextColorSection[2], Def.TextColorSection[3], 1)
    local hex = CreateFrame("EditBox", nil, hexWrap)
    hex:SetPoint("LEFT", hexHash, "RIGHT", 4, 0); hex:SetPoint("RIGHT", hexWrap, "RIGHT", -4, 0)
    hex:SetHeight(20); hex:SetAutoFocus(false); hex:SetMaxLetters(6)
    SafeFont(hex, Def.FontPath, Def.LabelSize, nil)
    hex:SetTextColor(Def.TextColorLabel[1], Def.TextColorLabel[2], Def.TextColorLabel[3], 1)
    local function commitHex(self)
        local r, g, b = ParseHexColor(self:GetText())
        if r then f.colorSelect:SetColorRGB(r, g, b) end  -- OnColorSelect refreshes + fires change
        self:ClearFocus()
    end
    hex:SetScript("OnEnterPressed", commitHex)
    hex:SetScript("OnEditFocusLost", commitHex)
    hex:SetScript("OnEscapePressed", function(self) self:ClearFocus(); f:Refresh() end)
    f.hex = hex

    -- R/G/B 0-255 fields.
    local function makeNumField(labelText, anchorTo)
        local wrap = CreateFrame("Frame", nil, f)
        wrap:SetSize(FIELD_W, 22)
        if anchorTo then wrap:SetPoint("LEFT", anchorTo, "RIGHT", FIELD_GAP, 0)
        else wrap:SetPoint("LEFT", hexWrap, "RIGHT", FIELD_GAP, 0) end  -- R right of hex, same line
        local lab = wrap:CreateFontString(nil, "OVERLAY")
        SafeFont(lab, Def.FontPath, Def.LabelSize, nil)
        lab:SetPoint("LEFT", wrap, "LEFT", 0, 0); lab:SetText(labelText)
        lab:SetTextColor(Def.TextColorSection[1], Def.TextColorSection[2], Def.TextColorSection[3], 1)
        local boxWrap = CreateFrame("Frame", nil, wrap)
        boxWrap:SetPoint("LEFT", lab, "RIGHT", 4, 0); boxWrap:SetPoint("RIGHT", wrap, "RIGHT", 0, 0)
        boxWrap:SetHeight(20)
        local bg = boxWrap:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(boxWrap)
        bg:SetColorTexture(Def.InputBg[1], Def.InputBg[2], Def.InputBg[3], Def.InputBg[4])
        if addon.CreateBorder then addon.CreateBorder(boxWrap, Def.InputBorder) end
        local box = CreateFrame("EditBox", nil, boxWrap)
        box:SetPoint("TOPLEFT", 4, 0); box:SetPoint("BOTTOMRIGHT", -4, 0)
        box:SetAutoFocus(false); box:SetNumeric(true); box:SetMaxLetters(3); box:SetJustifyH("CENTER")
        SafeFont(box, Def.FontPath, Def.LabelSize, nil)
        box:SetTextColor(Def.TextColorLabel[1], Def.TextColorLabel[2], Def.TextColorLabel[3], 1)
        return box
    end
    local rBox = makeNumField("R", nil)
    local gBox = makeNumField("G", rBox:GetParent():GetParent())
    local bBox = makeNumField("B", gBox:GetParent():GetParent())

    local function commitRGB()
        local r = math.min(255, math.max(0, tonumber(rBox:GetText()) or Round(state.r)))
        local g = math.min(255, math.max(0, tonumber(gBox:GetText()) or Round(state.g)))
        local b = math.min(255, math.max(0, tonumber(bBox:GetText()) or Round(state.b)))
        f.colorSelect:SetColorRGB(r / 255, g / 255, b / 255)  -- OnColorSelect refreshes + fires change
    end
    for _, box in ipairs({ rBox, gBox, bBox }) do
        box:SetScript("OnEnterPressed", function(self) commitRGB(); self:ClearFocus() end)
        box:SetScript("OnEditFocusLost", function() commitRGB() end)
        box:SetScript("OnEscapePressed", function(self) self:ClearFocus(); f:Refresh() end)
    end
    f.rBox, f.gBox, f.bBox = rBox, gBox, bBox

    -- Alpha row (shown only when hasAlpha).
    local alphaRow = CreateFrame("Frame", nil, f)
    alphaRow:SetPoint("TOPLEFT", hexWrap, "BOTTOMLEFT", 0, -16)
    alphaRow:SetPoint("RIGHT", f, "RIGHT", -14, 0)
    alphaRow:SetHeight(32)
    local alphaLbl = alphaRow:CreateFontString(nil, "OVERLAY")
    SafeFont(alphaLbl, Def.FontPath, Def.LabelSize, nil)
    alphaLbl:SetPoint("TOPLEFT", alphaRow, "TOPLEFT", 0, 0); alphaLbl:SetText((L and L["OPACITY"]) or "Opacity")
    alphaLbl:SetTextColor(Def.TextColorSection[1], Def.TextColorSection[2], Def.TextColorSection[3], 1)
    local alphaPct = alphaRow:CreateFontString(nil, "OVERLAY")
    SafeFont(alphaPct, Def.FontPath, Def.LabelSize, nil)
    alphaPct:SetPoint("TOPRIGHT", alphaRow, "TOPRIGHT", 0, 0)
    alphaPct:SetTextColor(Def.TextColorLabel[1], Def.TextColorLabel[2], Def.TextColorLabel[3], 1)
    local aTrack = CreateFrame("Frame", nil, alphaRow)
    aTrack:SetPoint("BOTTOMLEFT", alphaRow, "BOTTOMLEFT", 0, 0)
    aTrack:SetPoint("BOTTOMRIGHT", alphaRow, "BOTTOMRIGHT", 0, 0)
    aTrack:SetHeight(ALPHA_TRACK_H)
    local aFill = aTrack:CreateTexture(nil, "ARTWORK")
    aFill:SetAllPoints(aTrack)
    local aThumb = CreateFrame("Button", nil, aTrack)
    aThumb:SetSize(ALPHA_THUMB, ALPHA_THUMB)
    local aThumbTex = aThumb:CreateTexture(nil, "OVERLAY")
    aThumbTex:SetAllPoints(aThumb); aThumbTex:SetColorTexture(1, 1, 1, 0.98)

    local function alphaTravel() return aTrack:GetWidth() - ALPHA_THUMB end
    local function placeAlpha()
        aThumb:ClearAllPoints()
        aThumb:SetPoint("CENTER", aTrack, "LEFT", ALPHA_THUMB / 2 + state.a * alphaTravel(), 0)
        aFill:SetColorTexture(state.r, state.g, state.b, 0.85)
        alphaPct:SetText(math.floor(state.a * 100 + 0.5) .. "%")
    end
    aThumb:SetScript("OnMouseDown", function()
        aThumb:SetScript("OnUpdate", function()
            if not IsMouseButtonDown("LeftButton") then aThumb:SetScript("OnUpdate", nil) return end
            local scale = aTrack:GetEffectiveScale()
            local x = (GetCursorPosition() / scale) - aTrack:GetLeft()
            local n = math.max(0, math.min(1, (x - ALPHA_THUMB / 2) / alphaTravel()))
            state.a = n
            placeAlpha()
            f.newSwatch:SetColorTexture(state.r, state.g, state.b, state.a)
            FireChange()
        end)
    end)
    f.alphaRow = alphaRow
    f.placeAlpha = placeAlpha

    -- Palette grid beside the wheel: class colour (auto) + saved colours (hover-× to remove) + "+".
    local paletteRow = CreateFrame("Frame", nil, f)
    paletteRow:SetPoint("TOPLEFT", cmp, "BOTTOMLEFT", 0, -10)
    paletteRow:SetPoint("RIGHT", f, "RIGHT", -14, 0)
    paletteRow:SetHeight(PRESET_SIZE * 2 + PRESET_GAP)
    f.paletteRow = paletteRow
    f.paletteButtons = {}
    local function paletteButton(i)
        local b = f.paletteButtons[i]
        if b then return b end
        b = CreateFrame("Button", nil, paletteRow)
        b:SetSize(PRESET_SIZE, PRESET_SIZE)
        local col = (i - 1) % PRESET_COLS
        local row = math.floor((i - 1) / PRESET_COLS)
        b:SetPoint("TOPLEFT", paletteRow, "TOPLEFT", col * (PRESET_SIZE + PRESET_GAP), -row * (PRESET_SIZE + PRESET_GAP))
        local tex = b:CreateTexture(nil, "ARTWORK"); tex:SetAllPoints(b); b.tex = tex
        if addon.CreateBorder then addon.CreateBorder(b, Def.InputBorder) end
        -- "+" glyph (shown on the add cell only).
        local plus = b:CreateFontString(nil, "OVERLAY")
        SafeFont(plus, Def.FontPath, 16, nil)
        plus:SetPoint("CENTER", b, "CENTER", 0, 0); plus:SetText("+")
        plus:SetTextColor(Def.TextColorSection[1], Def.TextColorSection[2], Def.TextColorSection[3], 1)
        plus:Hide(); b.plus = plus
        -- × remove badge (saved cells only); a child button inside the swatch corner.
        local xbadge = CreateFrame("Button", nil, b)
        xbadge:SetSize(13, 13)
        xbadge:SetPoint("TOPRIGHT", b, "TOPRIGHT", 0, 0)
        xbadge:SetFrameLevel(b:GetFrameLevel() + 5)
        local xbg = xbadge:CreateTexture(nil, "BACKGROUND"); xbg:SetAllPoints(xbadge)
        xbg:SetColorTexture(0.75, 0.22, 0.17, 1)
        local xtx = xbadge:CreateFontString(nil, "OVERLAY")
        SafeFont(xtx, Def.FontPath, 10, nil)
        xtx:SetAllPoints(xbadge)
        xtx:SetJustifyH("CENTER"); xtx:SetJustifyV("MIDDLE")
        xtx:SetText("\195\151")
        xtx:SetTextColor(1, 1, 1, 1)
        xbadge:Hide(); b.xbadge = xbadge
        local function hideBadgeIfAway()
            if not (b:IsMouseOver() or xbadge:IsMouseOver()) then xbadge:Hide() end
        end
        xbadge:SetScript("OnClick", function() if b._index then RemoveFromPalette(b._index) end end)
        xbadge:SetScript("OnLeave", hideBadgeIfAway)
        b:SetScript("OnClick", function()
            if b._kind == "add" then
                AddCurrentToPalette()
            elseif b._color then
                f.colorSelect:SetColorRGB(b._color[1], b._color[2], b._color[3])  -- OnColorSelect refreshes + fires
            end
        end)
        b:SetScript("OnEnter", function()
            if b._kind == "saved" then
                xbadge:Show()
            elseif b._kind == "add" then
                GameTooltip:SetOwner(b, "ANCHOR_RIGHT")
                GameTooltip:SetText((L and L["COLOR_SAVE_CURRENT"]) or "Save current colour", 1, 1, 1, 1, true)
                GameTooltip:Show()
            end
        end)
        b:SetScript("OnLeave", function() GameTooltip:Hide(); hideBadgeIfAway() end)
        f.paletteButtons[i] = b
        return b
    end
    function f:BuildPalette()
        local cells = {}
        local cr, cg, cb = PlayerClassColor()
        if cr then cells[#cells + 1] = { kind = "class", color = { cr, cg, cb } } end
        local saved = LoadPalette()
        for idx = 1, #saved do
            cells[#cells + 1] = { kind = "saved", color = saved[idx], index = idx }
        end
        if #saved < PALETTE_CAP then cells[#cells + 1] = { kind = "add" } end
        for i = 1, #cells do
            local cell = cells[i]
            local b = paletteButton(i)
            b._kind = cell.kind
            b._index = cell.index
            b._color = cell.color
            b.xbadge:Hide()
            if cell.kind == "add" then
                b.tex:SetColorTexture(Def.InputBg[1], Def.InputBg[2], Def.InputBg[3], Def.InputBg[4])
                b.plus:Show()
            else
                b.tex:SetColorTexture(cell.color[1], cell.color[2], cell.color[3], 1)
                b.plus:Hide()
            end
            b:Show()
        end
        for i = #cells + 1, #f.paletteButtons do f.paletteButtons[i]:Hide() end
    end

    -- Footer buttons.
    local function makeButton(text, primary)
        local b = CreateFrame("Button", nil, f)
        b:SetSize(72, 24)
        local bg = b:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(b)
        if primary then bg:SetColorTexture(Def.AccentColor[1] * 0.5, Def.AccentColor[2] * 0.5, Def.AccentColor[3] * 0.6, 1)
        else bg:SetColorTexture(Def.InputBg[1], Def.InputBg[2], Def.InputBg[3], Def.InputBg[4]) end
        if addon.CreateBorder then addon.CreateBorder(b, primary and Def.AccentColor or Def.InputBorder) end
        local hi = b:CreateTexture(nil, "HIGHLIGHT"); hi:SetAllPoints(b); hi:SetColorTexture(1, 1, 1, 0.08)
        local t = b:CreateFontString(nil, "OVERLAY")
        SafeFont(t, Def.FontPath, Def.LabelSize, nil); t:SetPoint("CENTER"); t:SetText(text)
        t:SetTextColor(Def.TextColorLabel[1], Def.TextColorLabel[2], Def.TextColorLabel[3], 1)
        return b
    end

    local okBtn = makeButton((OKAY) or "OK", true)
    okBtn:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -14, 12)
    okBtn:SetScript("OnClick", function() ConfirmClose() end)
    local cancelBtn = makeButton((CANCEL) or "Cancel", false)
    cancelBtn:SetPoint("RIGHT", okBtn, "LEFT", -8, 0)
    cancelBtn:SetScript("OnClick", function() CancelClose() end)
    local resetBtn = makeButton((RESET) or "Reset", false)
    resetBtn:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 14, 12)
    resetBtn:SetScript("OnClick", function()
        local d = state.spec and state.spec.default
        if not d then return end
        if state.hasAlpha and type(d[4]) == "number" then
            state.a = d[4]
            if f.placeAlpha then f.placeAlpha() end
        end
        f.colorSelect:SetColorRGB(d[1], d[2], d[3])  -- OnColorSelect refreshes + fires change
    end)

    -- Fire onCancel when hidden without an explicit confirm (Cancel / ✕ / Esc). Placed after the
    -- initial f:Hide() above so it never fires during construction.
    f:SetScript("OnHide", function()
        if not state.confirmed then
            local s = state.spec
            if s and s.onCancel then s.onCancel() end
        end
    end)

    f.colorSelect = cs
    function f:Refresh()
        local a = state.hasAlpha and state.a or 1
        f.newSwatch:SetColorTexture(state.r, state.g, state.b, a)
        if f.hex and not f.hex:HasFocus() then
            f.hex:SetText(string.format("%02X%02X%02X", Round(state.r), Round(state.g), Round(state.b)))
        end
        if f.rBox and not f.rBox:HasFocus() then f.rBox:SetText(Round(state.r)) end
        if f.gBox and not f.gBox:HasFocus() then f.gBox:SetText(Round(state.g)) end
        if f.bBox and not f.bBox:HasFocus() then f.bBox:SetText(Round(state.b)) end
        if state.hasAlpha and f.placeAlpha then f.placeAlpha() end
    end
    P = f
    return P
end

function addon.OpenColorPicker(spec)
    local f = EnsurePicker()
    state.spec = spec or {}
    state.confirmed = false
    state.hasAlpha = spec.hasAlpha and true or false
    state.r, state.g, state.b = spec.r or 1, spec.g or 1, spec.b or 1
    state.a = state.hasAlpha and (spec.a or 1) or 1
    state.orig = { r = state.r, g = state.g, b = state.b, a = state.a }
    f.oldSwatch:SetColorTexture(state.r, state.g, state.b, state.a)
    state.suppress = true
    f.colorSelect:SetColorRGB(state.r, state.g, state.b)
    state.suppress = false
    if f.Refresh then f:Refresh() end
    f.alphaRow:SetShown(state.hasAlpha)
    if state.hasAlpha and f.placeAlpha then f.placeAlpha() end
    f:BuildPalette()
    f:ClearAllPoints(); f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:Show(); f:Raise()
end
