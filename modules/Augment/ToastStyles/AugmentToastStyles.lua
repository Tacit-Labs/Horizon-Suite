--[[
    Horizon Suite - Augment - Toast Styles
    Shared motion constants and visual chrome for Augment toast entries.
    Blizzard: BackdropTemplate frame and texture/font-string layout methods.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

addon.Augment = addon.Augment or {}
local Y = addon.Augment
Y.ToastStyles = Y.ToastStyles or {}
local TS = Y.ToastStyles

Y.ToastMotion = Y.ToastMotion or {}
local M = Y.ToastMotion
M.ENTRANCE_DUR = 0.28
M.EXIT_DUR     = 0.45
M.SLIDE_DIST   = 18
M.EXIT_DRIFT   = 10  -- unscaled px drifted during exit (loot + alerts)
M.NUDGE_SPEED  = 10
M.EDGE         = 8
-- Height headroom a Framed backdrop needs beyond the icon so the tooltip-style
-- border/edge doesn't overlap the icon or text. Alerts' fixed HEIGHT (44 for a
-- 34px icon) is the reference ratio; Loot derives its per-style entry height
-- from this same constant (see AugmentCore.lua ApplyScale).
M.CHROME_HEIGHT_PAD = 10

local TOOLTIP_BACKDROP = {
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 10,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 },
}

-- Square alternative to the tooltip border: a flat 1px edge with hard corners.
-- edgeSize is set per call so the edge tracks the caller's scale.
local SQUARE_BACKDROP = {
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
    insets   = { left = 1, right = 1, top = 1, bottom = 1 },
}

local LEGACY = {
    horizon = "framed",
    minimalist = "accent",
}

--- Apply quadratic easing.
--- @param t number Progress from zero to one
--- @param mode string|nil "in", "inOut", or nil for ease-out
--- @return number easedProgress
function M.Ease(t, mode)
    if mode == "in" then return t * t end
    if mode == "inOut" then
        if t < 0.5 then return 2 * t * t end
        return 1 - ((-2 * t + 2) * (-2 * t + 2)) / 2
    end
    return 1 - (1 - t) * (1 - t)
end

--- Normalize current and legacy toast style IDs.
--- @param style string|nil Raw toast style
--- @return string styleID "compact", "framed", or "accent"
function TS.Normalize(style)
    if style == "compact" or style == "framed" or style == "accent" then return style end
    if LEGACY[style] then return LEGACY[style] end
    return "framed"
end

--- Read Augment's Framed border settings.
--- @return table border { shape = "rounded"|"square", r, g, b } where r/g/b are nil when the border follows the toast colour
function TS.GetFramedBorder()
    local D = addon.AUGMENT_DEFAULTS or {}
    local getDB = addon.GetDB
    local shape = getDB and getDB("augmentFramedBorderShape", D.augmentFramedBorderShape)
    local border = { shape = (shape == "square") and "square" or "rounded" }
    local mode = getDB and getDB("augmentFramedBorderColorMode", D.augmentFramedBorderColorMode)
    if mode == "custom" then
        local c = getDB("augmentFramedBorderColor", D.augmentFramedBorderColor)
        if type(c) == "table" and c[1] and c[2] and c[3] then
            border.r, border.g, border.b = c[1], c[2], c[3]
        end
    end
    return border
end

--- Paint the Framed backdrop onto a BackdropTemplate frame.
--- @param frame Frame Frame with SetBackdrop
--- @param r number Border tint used when the border has no custom colour
--- @param g number
--- @param b number
--- @param border table|nil From TS.GetFramedBorder; nil keeps the rounded, tinted default
--- @param scale function|nil Scales the square edge width; rounded ignores it
--- @return nil
function TS.ApplyFramedBackdrop(frame, r, g, b, border, scale)
    if not frame or not frame.SetBackdrop then return end
    if border and border.shape == "square" then
        local edge = math.max(1, scale and scale(1) or 1)
        SQUARE_BACKDROP.edgeSize = edge
        local insets = SQUARE_BACKDROP.insets
        insets.left, insets.right, insets.top, insets.bottom = edge, edge, edge, edge
        frame:SetBackdrop(SQUARE_BACKDROP)
    else
        frame:SetBackdrop(TOOLTIP_BACKDROP)
    end
    frame:SetBackdropColor(0, 0, 0, 0.75)
    if border and border.r then
        -- A colour the user picked shows at full strength; the quality tint
        -- keeps its softer 0.7 so it doesn't overpower the text.
        frame:SetBackdropBorderColor(border.r, border.g, border.b, 1)
    else
        frame:SetBackdropBorderColor(r, g, b, 0.7)
    end
end

local function SetTextColor(entry, textMode, r, g, b)
    if textMode == "dual" then
        entry.title:SetTextColor(r, g, b, 1)
    else
        entry.text:SetTextColor(r, g, b, 1)
    end
end

local function SetJustification(entry, textMode, justify)
    if textMode == "dual" then
        entry.title:SetJustifyH(justify)
        entry.body:SetJustifyH(justify)
    else
        entry.text:SetJustifyH(justify)
        if entry.shadow then entry.shadow:SetJustifyH(justify) end
    end
end

local function AnchorIcon(entry, anchor, iconSide, edge)
    anchor:ClearAllPoints()
    if iconSide == "right" then
        anchor:SetPoint("RIGHT", entry.frame, "RIGHT", -edge, 0)
    else
        anchor:SetPoint("LEFT", entry.frame, "LEFT", edge, 0)
    end

    if anchor ~= entry.icon then
        entry.icon:ClearAllPoints()
        entry.icon:SetPoint("CENTER", anchor, "CENTER", 0, 0)
    end
end

local function AnchorDualText(entry, anchor, iconSide, gap)
    entry.title:ClearAllPoints()
    entry.body:ClearAllPoints()
    if iconSide == "right" then
        entry.title:SetPoint("TOPRIGHT", anchor, "TOPLEFT", -gap, -2)
        entry.title:SetPoint("LEFT", entry.frame, "LEFT", M.EDGE, 0)
        entry.body:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMLEFT", -gap, 2)
        entry.body:SetPoint("LEFT", entry.frame, "LEFT", M.EDGE, 0)
    else
        entry.title:SetPoint("TOPLEFT", anchor, "TOPRIGHT", gap, -2)
        entry.title:SetPoint("RIGHT", entry.frame, "RIGHT", -M.EDGE, 0)
        entry.body:SetPoint("BOTTOMLEFT", anchor, "BOTTOMRIGHT", gap, 2)
        entry.body:SetPoint("RIGHT", entry.frame, "RIGHT", -M.EDGE, 0)
    end
end

local function AnchorSingleText(entry, anchor, iconSide, gap, textWidth)
    local function AnchorFontString(fontString, isShadow)
        if not fontString then return end
        local xOffset = isShadow and (gap + 1) or gap
        local yOffset = isShadow and -1 or 0
        fontString:ClearAllPoints()
        if iconSide == "right" then
            fontString:SetWidth(0)
            fontString:SetPoint("RIGHT", anchor, "LEFT", -xOffset, yOffset)
        else
            if textWidth then fontString:SetWidth(textWidth) end
            fontString:SetPoint("LEFT", anchor, "RIGHT", xOffset, yOffset)
        end
    end

    AnchorFontString(entry.shadow, true)
    AnchorFontString(entry.text, false)
end

local function AnchorText(entry, textMode, anchor, iconSide, gap, textWidth)
    if textMode == "dual" then
        AnchorDualText(entry, anchor, iconSide, gap)
    else
        AnchorSingleText(entry, anchor, iconSide, gap, textWidth)
    end
end

local function ApplyFramed(entry, textMode, iconSide, iconSize, gap, textWidth)
    if entry.iconBg then entry.iconBg:Hide() end
    if entry.iconDark then entry.iconDark:Hide() end

    entry.icon:SetSize(iconSize, iconSize)
    local anchor = entry.iconBgAnchor or entry.icon
    if anchor ~= entry.icon then anchor:SetSize(iconSize, iconSize) end
    AnchorIcon(entry, anchor, iconSide, M.EDGE)
    AnchorText(entry, textMode, anchor, iconSide, gap, textWidth)
end

-- Extra unscaled px per side on Accent's colour square beyond Compact's tight chip.
local ACCENT_PAD_EXTRA = 4

local function ApplyUnframed(entry, style, textMode, iconSide, iconSize, gap, textWidth, pad, accentExtra, r, g, b)
    if entry.frame.SetBackdrop then entry.frame:SetBackdrop(nil) end

    local background = entry.iconBg
    local anchor = entry.iconBgAnchor or background
    -- Compact: tight chip (icon + pad). Accent: larger colour block + dark under-icon.
    local backgroundSize = iconSize + (pad + (accentExtra or 0)) * 2

    if anchor ~= background then anchor:SetSize(backgroundSize, backgroundSize) end
    AnchorIcon(entry, anchor, iconSide, 0)
    background:SetSize(backgroundSize, backgroundSize)
    background:ClearAllPoints()
    if background ~= anchor then
        background:SetPoint("CENTER", anchor, "CENTER", 0, 0)
    elseif iconSide == "right" then
        background:SetPoint("RIGHT", entry.frame, "RIGHT", 0, 0)
    else
        background:SetPoint("LEFT", entry.frame, "LEFT", 0, 0)
    end
    background:SetColorTexture(r, g, b, style == "accent" and 0.85 or 0.8)
    background:Show()

    if entry.iconDark then
        entry.iconDark:SetSize(iconSize, iconSize)
        entry.iconDark:ClearAllPoints()
        entry.iconDark:SetPoint("CENTER", background, "CENTER", 0, 0)
        -- Accent only: dark underlay (stops transparent icons bleeding the
        -- colour fill, and visually separates Accent from Compact's tight chip).
        if style == "accent" then
            entry.iconDark:Show()
        else
            entry.iconDark:Hide()
        end
    end

    entry.icon:SetSize(iconSize, iconSize)
    entry.icon:ClearAllPoints()
    entry.icon:SetPoint("CENTER", background, "CENTER", 0, 0)
    AnchorText(entry, textMode, anchor, iconSide, gap, textWidth)
end

--- Apply shared toast chrome. Does not set text strings.
--- @param entry table Toast regions and frame
--- @param style string|nil Raw DB style value
--- @param colors table Text tint and optional icon fill RGB
--- @param layout table Text mode, icon placement, dimensions, optional unscaled textWidth, scale helper, and optional Framed border (TS.GetFramedBorder)
--- @return nil
function TS.ApplyChrome(entry, style, colors, layout)
    style = TS.Normalize(style)

    local r, g, b = colors.r, colors.g, colors.b
    local fillR = colors.br or r
    local fillG = colors.bg or g
    local fillB = colors.bb or b
    local textMode = layout.textMode
    local iconSide = layout.iconSide == "right" and "right" or "left"
    local justify = iconSide == "right" and "RIGHT" or "LEFT"
    local scale = layout.scale
    local iconSize = scale(layout.iconSize)
    local gap = scale(layout.iconGap)
    local textWidth = layout.textWidth and scale(layout.textWidth)
    local pad = scale(layout.iconBgPad)

    SetTextColor(entry, textMode, r, g, b)
    SetJustification(entry, textMode, justify)

    if style == "framed" then
        -- Framed insets the icon by EDGE on the near side (see ApplyFramed's
        -- AnchorIcon call below) but single-text mode uses a fixed textWidth
        -- sized for the unframed (0-inset) layout. Shrink it by 2*EDGE so
        -- EDGE + icon + gap + text still fits inside the backdrop instead of
        -- overflowing past the frame's visual right edge.
        local framedTextWidth = textWidth and math.max(0, textWidth - (2 * M.EDGE))
        TS.ApplyFramedBackdrop(entry.frame, r, g, b, layout.border, scale)
        ApplyFramed(entry, textMode, iconSide, iconSize, gap, framedTextWidth)
        return
    end

    local accentExtra = (style == "accent") and scale(ACCENT_PAD_EXTRA) or 0
    ApplyUnframed(entry, style, textMode, iconSide, iconSize, gap, textWidth, pad, accentExtra, fillR, fillG, fillB)
end
