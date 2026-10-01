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

-- Square alternative to the tooltip border: a flat edge with hard corners.
-- One table per edge width (in UI units): BackdropTemplateMixin:SetBackdrop returns early
-- when handed the table a frame already has, so mutating a shared table's
-- edgeSize would leave pooled toasts at their first thickness.
local squareBackdrops = {}

local function SquareBackdrop(edge)
    local backdrop = squareBackdrops[edge]
    if not backdrop then
        backdrop = {
            bgFile   = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = edge,
            insets   = { left = edge, right = edge, top = edge, bottom = edge },
        }
        squareBackdrops[edge] = backdrop
    end
    return backdrop
end

-- UI units covering `pixels` physical screen pixels on `frame`, so the square
-- edge stays exact whatever the resolution, UI scale or Augment scale.
local function PixelsToUnits(frame, pixels)
    local factor
    if PixelUtil and PixelUtil.GetPixelToUIUnitFactor then
        factor = PixelUtil.GetPixelToUIUnitFactor()
    else
        local _, physicalHeight = GetPhysicalScreenSize()
        factor = 768 / physicalHeight
    end
    local scale = frame.GetEffectiveScale and frame:GetEffectiveScale() or 1
    if not scale or scale <= 0 then scale = 1 end
    return pixels * factor / scale
end

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

-- ============================================================================
-- STYLE REGISTRY
-- ============================================================================
-- Every toast stack (loot, alerts, loot rolls, Echo), the options dropdowns and
-- the loot window skin read their style list and per-style traits from here,
-- so a new style is one TS.Register call plus its locale label.
--
-- Definition fields:
--   id        string    Saved-variable value
--   label     string    Locale key for the dropdown label
--   apply     function  (entry, ctx) paints the chrome; ctx is built in TS.ApplyChrome
--   heightPad number    Unscaled px a loot row needs beyond the icon (0 keeps it tight)
--   stackFan  boolean   Loot's fanned stack of icons for condensed junk
--   border    boolean   The Framed border shape and size options apply
--   window    string    Loot window chrome: "backdrop", "strip", "wash" or "plain"
--   slotPad   table|nil Loot window slot icon pad { extra, alpha }; nil keeps
--                       Blizzard's own slot border

local DEFAULT_STYLE = "framed"
local styles = {}
local styleByID = {}

--- Register a toast style. Order of registration is dropdown order.
--- @param def table Style definition (see the field list above)
--- @return nil
function TS.Register(def)
    if not def or not def.id or styleByID[def.id] then return end
    def.heightPad = def.heightPad or 0
    styles[#styles + 1] = def
    styleByID[def.id] = def
end

--- Normalize current and legacy toast style IDs.
--- @param style string|nil Raw toast style
--- @return string styleID A registered style ID; unknown values become "framed"
function TS.Normalize(style)
    if styleByID[style] then return style end
    if LEGACY[style] then return LEGACY[style] end
    return DEFAULT_STYLE
end

--- Look up a style definition, normalizing legacy and unknown IDs first.
--- @param style string|nil Raw toast style
--- @return table def Registered style definition
function TS.Get(style)
    return styleByID[TS.Normalize(style)]
end

--- All registered styles, in dropdown order.
--- @return table styles Array of style definitions (do not modify)
function TS.List()
    return styles
end

--- Dropdown options for a style picker.
--- @param L table Locale table
--- @param leading table|nil Options placed before the styles, e.g. Loot Rolls' "match loot"
--- @return table options Array of { label, value }
function TS.StyleOptions(L, leading)
    local out = {}
    if leading then
        for _, opt in ipairs(leading) do out[#out + 1] = opt end
    end
    for _, def in ipairs(styles) do
        out[#out + 1] = { L[def.label], def.id }
    end
    return out
end

--- Read Augment's Framed border settings.
--- @return table border { shape = "rounded"|"square", size } where size is the square edge in screen pixels
function TS.GetFramedBorder()
    local D = addon.AUGMENT_DEFAULTS or {}
    local getDB = addon.GetDB
    local shape = getDB and getDB("augmentFramedBorderShape", D.augmentFramedBorderShape)
    local border = { shape = (shape == "square") and "square" or "rounded" }
    local lim = addon.AUGMENT_LIMITS and addon.AUGMENT_LIMITS.augmentFramedBorderSize
    local size = tonumber(getDB and getDB("augmentFramedBorderSize", D.augmentFramedBorderSize)) or 1
    if lim then size = math.max(lim.min, math.min(lim.max, size)) end
    border.size = math.floor(size + 0.5)
    return border
end

--- Paint the Framed backdrop onto a BackdropTemplate frame.
--- @param frame Frame Frame with SetBackdrop
--- @param r number Border tint
--- @param g number
--- @param b number
--- @param border table|nil From TS.GetFramedBorder; nil keeps the rounded, tinted default
--- @return nil
function TS.ApplyFramedBackdrop(frame, r, g, b, border)
    if not frame or not frame.SetBackdrop then return end
    if border and border.shape == "square" then
        frame:SetBackdrop(SquareBackdrop(PixelsToUnits(frame, border.size or 1)))
    else
        frame:SetBackdrop(TOOLTIP_BACKDROP)
    end
    frame:SetBackdropColor(0, 0, 0, 0.75)
    frame:SetBackdropBorderColor(r, g, b, 0.7)
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

-- Bare icon inset from the frame edge, no colour chip: the layout Framed,
-- Ribbon and Rail share. Single-text mode uses a fixed textWidth sized for
-- the unframed (0-inset) layout, so shrink it by both insets to keep
-- inset + icon + gap + text inside the frame.
local function ApplyInset(entry, ctx, inset)
    if entry.iconBg then entry.iconBg:Hide() end
    if entry.iconDark then entry.iconDark:Hide() end

    local iconSize = ctx.iconSize
    entry.icon:SetSize(iconSize, iconSize)
    local anchor = entry.iconBgAnchor or entry.icon
    if anchor ~= entry.icon then anchor:SetSize(iconSize, iconSize) end
    AnchorIcon(entry, anchor, ctx.iconSide, inset)
    local textWidth = ctx.textWidth and math.max(0, ctx.textWidth - (2 * inset))
    AnchorText(entry, ctx.textMode, anchor, ctx.iconSide, ctx.gap, textWidth)
end

-- Regions only Ribbon and Rail use, created on first use and kept on the
-- entry so pooled toasts reuse them. Sublevels sit under every caller's own
-- BACKGROUND regions (Echo's icon chip is BACKGROUND 0).
local STYLE_REGIONS = {
    _tsPlate = -8,
    _tsWash  = -7,
    _tsRail  = -6,
}

local function StyleTexture(entry, key)
    local tex = entry[key]
    if not tex then
        tex = entry.frame:CreateTexture(nil, "BACKGROUND", nil, STYLE_REGIONS[key])
        entry[key] = tex
    end
    return tex
end

local function HideStyleRegions(entry)
    for key in pairs(STYLE_REGIONS) do
        if entry[key] then entry[key]:Hide() end
    end
end

local function ClearBackdrop(frame)
    if frame.SetBackdrop then frame:SetBackdrop(nil) end
end

--- Paint a horizontal colour wash that fades from one edge.
--- @param tex Texture
--- @param fromLeft boolean Strongest at the left edge when true
--- @param r number
--- @param g number
--- @param b number
--- @param alpha number Alpha at the strong edge; the far edge is transparent
--- @return nil
function TS.SetWash(tex, fromLeft, r, g, b, alpha)
    local aLeft, aRight = alpha, 0
    if not fromLeft then aLeft, aRight = 0, alpha end
    tex:SetColorTexture(1, 1, 1, 1)
    -- Clients before 10.0 take alpha only through SetGradientAlpha, and their
    -- SetGradient wants plain numbers; 10.0 removed SetGradientAlpha.
    if tex.SetGradientAlpha then
        tex:SetGradientAlpha("HORIZONTAL", r, g, b, aLeft, r, g, b, aRight)
    elseif CreateColor then
        tex:SetGradient("HORIZONTAL", CreateColor(r, g, b, aLeft), CreateColor(r, g, b, aRight))
    end
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

-- Ribbon: how far the text tint is pulled toward white so it reads on the wash.
local RIBBON_TEXT_LIFT = 0.6
local RIBBON_WASH_ALPHA = 0.75
local RIBBON_INSET = 4
local RAIL_WIDTH = 3
local PLATE_ALPHA = 0.75

local function Lift(c)
    return c + (1 - c) * RIBBON_TEXT_LIFT
end

TS.Register({
    id = "compact", label = "AUGMENT_TOAST_STYLE_COMPACT",
    stackFan = true, window = "plain", slotPad = { extra = 1, alpha = 0.8 },
    apply = function(entry, ctx)
        ApplyUnframed(entry, "compact", ctx.textMode, ctx.iconSide, ctx.iconSize, ctx.gap,
            ctx.textWidth, ctx.pad, 0, ctx.fillR, ctx.fillG, ctx.fillB)
    end,
})

TS.Register({
    id = "framed", label = "AUGMENT_TOAST_STYLE_FRAMED",
    heightPad = M.CHROME_HEIGHT_PAD, border = true, window = "backdrop",
    apply = function(entry, ctx)
        TS.ApplyFramedBackdrop(entry.frame, ctx.r, ctx.g, ctx.b, ctx.border)
        ApplyInset(entry, ctx, M.EDGE)
    end,
})

TS.Register({
    id = "accent", label = "AUGMENT_TOAST_STYLE_ACCENT",
    window = "strip", slotPad = { extra = ACCENT_PAD_EXTRA, alpha = 0.85 },
    apply = function(entry, ctx)
        ApplyUnframed(entry, "accent", ctx.textMode, ctx.iconSide, ctx.iconSize, ctx.gap,
            ctx.textWidth, ctx.pad, ctx.scale(ACCENT_PAD_EXTRA), ctx.fillR, ctx.fillG, ctx.fillB)
    end,
})

-- Ribbon: a fill-coloured wash fading away from the icon, light text on top.
TS.Register({
    id = "ribbon", label = "AUGMENT_TOAST_STYLE_RIBBON",
    heightPad = 6, window = "wash",
    apply = function(entry, ctx)
        ClearBackdrop(entry.frame)
        local wash = StyleTexture(entry, "_tsWash")
        wash:ClearAllPoints()
        wash:SetAllPoints(entry.frame)
        TS.SetWash(wash, ctx.iconSide ~= "right", ctx.fillR, ctx.fillG, ctx.fillB, RIBBON_WASH_ALPHA)
        wash:Show()
        SetTextColor(entry, ctx.textMode, Lift(ctx.r), Lift(ctx.g), Lift(ctx.b))
        ApplyInset(entry, ctx, ctx.scale(RIBBON_INSET))
    end,
})

-- Rail: a dark plate with a fill-coloured bar down the icon's edge.
TS.Register({
    id = "rail", label = "AUGMENT_TOAST_STYLE_RAIL",
    heightPad = M.CHROME_HEIGHT_PAD, window = "strip",
    apply = function(entry, ctx)
        ClearBackdrop(entry.frame)
        local plate = StyleTexture(entry, "_tsPlate")
        plate:ClearAllPoints()
        plate:SetAllPoints(entry.frame)
        plate:SetColorTexture(0, 0, 0, PLATE_ALPHA)
        plate:Show()

        local rail = StyleTexture(entry, "_tsRail")
        rail:ClearAllPoints()
        local side = ctx.iconSide == "right" and "RIGHT" or "LEFT"
        rail:SetPoint("TOP" .. side, entry.frame, "TOP" .. side, 0, 0)
        rail:SetPoint("BOTTOM" .. side, entry.frame, "BOTTOM" .. side, 0, 0)
        rail:SetWidth(ctx.scale(RAIL_WIDTH))
        rail:SetColorTexture(ctx.fillR, ctx.fillG, ctx.fillB, 1)
        rail:Show()
        ApplyInset(entry, ctx, M.EDGE)
    end,
})

--- Apply shared toast chrome. Does not set text strings.
--- @param entry table Toast regions and frame
--- @param style string|nil Raw DB style value
--- @param colors table Text tint and optional icon fill RGB (br/bg/bb)
--- @param layout table Text mode, icon placement, dimensions, optional unscaled textWidth, scale helper, and optional Framed border (TS.GetFramedBorder)
--- @return nil
function TS.ApplyChrome(entry, style, colors, layout)
    local def = TS.Get(style)
    local scale = layout.scale
    local iconSide = layout.iconSide == "right" and "right" or "left"
    local ctx = {
        textMode  = layout.textMode,
        iconSide  = iconSide,
        iconSize  = scale(layout.iconSize),
        gap       = scale(layout.iconGap),
        textWidth = layout.textWidth and scale(layout.textWidth),
        pad       = scale(layout.iconBgPad),
        scale     = scale,
        border    = layout.border,
        r = colors.r, g = colors.g, b = colors.b,
        fillR = colors.br or colors.r,
        fillG = colors.bg or colors.g,
        fillB = colors.bb or colors.b,
    }

    SetTextColor(entry, ctx.textMode, ctx.r, ctx.g, ctx.b)
    SetJustification(entry, ctx.textMode, iconSide == "right" and "RIGHT" or "LEFT")
    -- A pooled entry still carries the previous style's regions.
    HideStyleRegions(entry)
    def.apply(entry, ctx)
end
