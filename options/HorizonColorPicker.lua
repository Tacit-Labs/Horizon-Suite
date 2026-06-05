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

    f.colorSelect = cs
    function f:Refresh() end  -- replaced in later tasks
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
    state.suppress = true
    f.colorSelect:SetColorRGB(state.r, state.g, state.b)
    state.suppress = false
    if f.Refresh then f:Refresh() end
    f:ClearAllPoints(); f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:Show(); f:Raise()
end
