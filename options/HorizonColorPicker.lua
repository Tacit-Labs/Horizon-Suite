--[[ Horizon Suite — Custom colour picker (replaces Blizzard ColorPickerFrame). ]]
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = addon.L
local Def = addon.OptionsWidgetsDef  -- design tokens exported by OptionsWidgets.lua

local PICKER_W, PICKER_H = 340, 300
local WHEEL_SIZE = 128
local VALUE_W = 24
local THUMB_TEX = "Interface\\Buttons\\UI-ColorPicker-Buttons"

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

local function FireChange()
    local s = state.spec
    if s and s.onChange then s.onChange(state.r, state.g, state.b, state.a) end
end

local function Close(cancelled)
    if not P then return end
    P:Hide()
    if cancelled then
        local s = state.spec
        if s and s.onCancel then s.onCancel() end
    end
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
    titleText:SetFont(Def.FontPath, Def.HeaderSize or 16, Def.WidgetFontFlags or "OUTLINE")
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
    cx:SetFont(Def.FontPath, 16, "OUTLINE"); cx:SetPoint("CENTER"); cx:SetText("\195\151") -- ×
    cx:SetTextColor(Def.TextColorSection[1], Def.TextColorSection[2], Def.TextColorSection[3], 1)
    close:SetScript("OnClick", function() Close(true) end)

    -- Esc closes (cancel). Registered as a special frame.
    f:SetScript("OnKeyDown", function(_, key) if key == "ESCAPE" then Close(true) end end)
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

    local wheelThumb = cs:CreateTexture(nil, "OVERLAY")
    wheelThumb:SetSize(10, 10); wheelThumb:SetTexture(THUMB_TEX)
    cs:SetColorWheelThumbTexture(wheelThumb)

    local value = cs:CreateTexture(nil, "OVERLAY")
    value:SetSize(VALUE_W, WHEEL_SIZE)
    value:SetPoint("TOPLEFT", wheel, "TOPRIGHT", 16, 0)
    cs:SetColorValueTexture(value)

    local valueThumb = cs:CreateTexture(nil, "OVERLAY")
    valueThumb:SetSize(VALUE_W + 4, 10); valueThumb:SetTexture(THUMB_TEX)
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
    newSw:SetPoint("TOPLEFT", cmp, "TOPLEFT", 0, 0); newSw:SetPoint("BOTTOM", cmp, "BOTTOM", 0, 0)
    newSw:SetWidth(60)
    local oldSw = cmp:CreateTexture(nil, "ARTWORK")
    oldSw:SetPoint("TOPLEFT", newSw, "TOPRIGHT", 0, 0); oldSw:SetPoint("BOTTOM", cmp, "BOTTOM", 0, 0)
    oldSw:SetWidth(60)
    if addon.CreateBorder then addon.CreateBorder(cmp, Def.InputBorder) end
    f.newSwatch = newSw
    f.oldSwatch = oldSw

    -- Hex input.
    local hexWrap = CreateFrame("Frame", nil, f)
    hexWrap:SetSize(96, 22)
    hexWrap:SetPoint("TOPLEFT", cmp, "BOTTOMLEFT", 0, -8)
    local hexBg = hexWrap:CreateTexture(nil, "BACKGROUND")
    hexBg:SetAllPoints(hexWrap)
    hexBg:SetColorTexture(Def.InputBg[1], Def.InputBg[2], Def.InputBg[3], Def.InputBg[4])
    if addon.CreateBorder then addon.CreateBorder(hexWrap, Def.InputBorder) end
    local hexHash = hexWrap:CreateFontString(nil, "OVERLAY")
    hexHash:SetFont(Def.FontPath, Def.LabelSize, Def.WidgetFontFlags or "OUTLINE")
    hexHash:SetPoint("LEFT", hexWrap, "LEFT", 6, 0); hexHash:SetText("#")
    hexHash:SetTextColor(Def.TextColorSection[1], Def.TextColorSection[2], Def.TextColorSection[3], 1)
    local hex = CreateFrame("EditBox", nil, hexWrap)
    hex:SetPoint("LEFT", hexHash, "RIGHT", 4, 0); hex:SetPoint("RIGHT", hexWrap, "RIGHT", -4, 0)
    hex:SetHeight(20); hex:SetAutoFocus(false); hex:SetMaxLetters(6)
    hex:SetFont(Def.FontPath, Def.LabelSize, Def.WidgetFontFlags or "OUTLINE")
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
        wrap:SetSize(58, 22)
        if anchorTo then wrap:SetPoint("LEFT", anchorTo, "RIGHT", 6, 0)
        else wrap:SetPoint("TOPLEFT", hexWrap, "BOTTOMLEFT", 0, -8) end
        local lab = wrap:CreateFontString(nil, "OVERLAY")
        lab:SetFont(Def.FontPath, Def.LabelSize, Def.WidgetFontFlags or "OUTLINE")
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
        box:SetFont(Def.FontPath, Def.LabelSize, Def.WidgetFontFlags or "OUTLINE")
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
    end
    P = f
    return P
end

function addon.OpenColorPicker(spec)
    local f = EnsurePicker()
    state.spec = spec or {}
    state.hasAlpha = spec.hasAlpha and true or false
    state.r, state.g, state.b = spec.r or 1, spec.g or 1, spec.b or 1
    state.a = state.hasAlpha and (spec.a or 1) or 1
    state.orig = { r = state.r, g = state.g, b = state.b, a = state.a }
    f.oldSwatch:SetColorTexture(state.r, state.g, state.b, state.a)
    state.suppress = true
    f.colorSelect:SetColorRGB(state.r, state.g, state.b)
    state.suppress = false
    if f.Refresh then f:Refresh() end
    f:ClearAllPoints(); f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:Show(); f:Raise()
end
