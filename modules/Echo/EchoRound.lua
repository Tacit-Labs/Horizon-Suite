--[[
    Horizon Suite - Echo - Round
    Draws a rounded rectangle from two bundled textures: a filled circle and a ring
    outline. Each corner is a quadrant of the texture, sized to that corner's radius;
    edges and the middle are plain colour textures. A manual 9-slice, so it needs no
    newer client API and runs on Retail and Forever alike.
    Blizzard: CreateTexture, SetPoint, SetTexture, SetTexCoord, SetVertexColor.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Round = {}
Echo.Round = Round

-- Shared radii (Docs/Engineering/2026-09-26-echo-rounded-plan.md).
Round.PANEL = 10
Round.BUBBLE = 10
Round.TIGHT = 3
Round.TILE = 8
Round.SMALL = 6

-- Resolved once: the addon's own folder, so this works whatever the addon is installed as.
local FOLDER = "Interface\\AddOns\\" .. (addon.ADDON_NAME or "HorizonSuite") .. "\\media\\echo\\"
local CIRCLE_TEXTURE = FOLDER .. "circle.tga"
local RING_TEXTURE = FOLDER .. "ring.tga"

-- Corner order used throughout.
local CORNERS = { "tl", "tr", "bl", "br" }
local SIDES = { "top", "bottom", "left", "right" }

-- Texcoords for one corner's quadrant of circle.tga / ring.tga: { left, right, top, bottom }.
local QUAD = {
    tl = { 0, 0.5, 0, 0.5 },
    tr = { 0.5, 1, 0, 0.5 },
    bl = { 0, 0.5, 0.5, 1 },
    br = { 0.5, 1, 0.5, 1 },
}

-- The frame anchor point at each corner, and the direction (in SetPoint offset terms)
-- that moves from that anchor inward along x and y.
local ANCHOR = { tl = "TOPLEFT", tr = "TOPRIGHT", bl = "BOTTOMLEFT", br = "BOTTOMRIGHT" }
local INSET_X = { tl = 1, tr = -1, bl = 1, br = -1 }
local INSET_Y = { tl = -1, tr = -1, bl = 1, br = 1 }

--- Creates the fill (and optionally border) textures for a frame, once.
-- @param frame Frame  the host frame; the handle is cached on frame._echoRound
-- @param opts table  { radius, corners = { tl, tr, bl, br }, layer, border }
-- @return table  the cached handle
function Round.Apply(frame, opts)
    local existing = rawget(frame, "_echoRound")
    if existing then return existing end

    opts = opts or {}
    local radius = opts.radius or 0
    local cornersOpt = opts.corners or {}
    local layer = opts.layer or "BACKGROUND"

    local handle = {
        corners = {
            tl = cornersOpt.tl or radius,
            tr = cornersOpt.tr or radius,
            bl = cornersOpt.bl or radius,
            br = cornersOpt.br or radius,
        },
        layer = layer,
        fill = { circle = {}, rect1 = {}, rect2 = {} },
    }

    -- Fill draws at -8 and border at -7 within the layer, so the border always draws above
    -- the fill and a host's own textures (left at the default sublevel 0) draw above both.
    local FILL_SUB = -8
    local BORDER_SUB = -7

    for _, c in ipairs(CORNERS) do
        local circle = frame:CreateTexture(nil, layer)
        circle:SetTexture(CIRCLE_TEXTURE)
        circle:SetDrawLayer(layer, FILL_SUB)
        local q = QUAD[c]
        circle:SetTexCoord(q[1], q[2], q[3], q[4])
        handle.fill.circle[c] = circle

        local rect1 = frame:CreateTexture(nil, layer)
        rect1:SetColorTexture(1, 1, 1, 1)
        rect1:SetDrawLayer(layer, FILL_SUB)
        handle.fill.rect1[c] = rect1

        local rect2 = frame:CreateTexture(nil, layer)
        rect2:SetColorTexture(1, 1, 1, 1)
        rect2:SetDrawLayer(layer, FILL_SUB)
        handle.fill.rect2[c] = rect2
    end

    handle.fill.topBand = frame:CreateTexture(nil, layer)
    handle.fill.topBand:SetColorTexture(1, 1, 1, 1)
    handle.fill.topBand:SetDrawLayer(layer, FILL_SUB)
    handle.fill.bottomBand = frame:CreateTexture(nil, layer)
    handle.fill.bottomBand:SetColorTexture(1, 1, 1, 1)
    handle.fill.bottomBand:SetDrawLayer(layer, FILL_SUB)
    handle.fill.middleBand = frame:CreateTexture(nil, layer)
    handle.fill.middleBand:SetColorTexture(1, 1, 1, 1)
    handle.fill.middleBand:SetDrawLayer(layer, FILL_SUB)

    if opts.border then
        handle.border = { ring = {}, lines = {} }
        handle.borderVisible = true
        for _, c in ipairs(CORNERS) do
            local ring = frame:CreateTexture(nil, layer)
            ring:SetTexture(RING_TEXTURE)
            ring:SetDrawLayer(layer, BORDER_SUB)
            local q = QUAD[c]
            ring:SetTexCoord(q[1], q[2], q[3], q[4])
            handle.border.ring[c] = ring
        end
        for _, side in ipairs(SIDES) do
            local line = frame:CreateTexture(nil, layer)
            line:SetColorTexture(1, 1, 1, 1)
            line:SetDrawLayer(layer, BORDER_SUB)
            handle.border.lines[side] = line
        end
    end

    frame._echoRound = handle
    Round.Layout(frame)
    -- HookScript, not SetScript, so a host's own OnSizeChanged handler survives: a resize
    -- (the card's width/height settings, a bubble sized to its text) re-lays out the fill
    -- and border to the new size without every caller having to remember to call Layout.
    if frame.HookScript then
        frame:HookScript("OnSizeChanged", function(f) Round.Layout(f) end)
    end
    return handle
end

--- Re-lays out the fill (and border) pieces for the frame's current size. Cheap: hosts
-- call it after every SetSize. If the size can't be read (the harness), the radii go
-- unclamped rather than crashing on a nil width/height.
-- @param frame Frame
function Round.Layout(frame)
    local handle = rawget(frame, "_echoRound")
    if not handle then return end

    local w, h = frame:GetWidth(), frame:GetHeight()
    local haveSize = type(w) == "number" and type(h) == "number" and w > 0 and h > 0

    local requested = handle.corners
    local R = math.max(requested.tl, requested.tr, requested.bl, requested.br)
    if haveSize then
        R = math.min(R, math.min(w, h) / 2)
    end

    local rc = {}
    for _, c in ipairs(CORNERS) do
        rc[c] = math.min(requested[c], R)
    end
    handle.R = R
    handle.rc = rc

    for _, c in ipairs(CORNERS) do
        local anchor = ANCHOR[c]
        local size = rc[c]

        local circle = handle.fill.circle[c]
        circle:ClearAllPoints()
        circle:SetPoint(anchor, frame, anchor, 0, 0)
        circle:SetSize(size, size)
        circle:SetShown(size > 0)

        local rect1 = handle.fill.rect1[c]
        local rect1H = R - size
        rect1:ClearAllPoints()
        rect1:SetPoint(anchor, frame, anchor, 0, INSET_Y[c] * size)
        rect1:SetSize(R, rect1H)
        rect1:SetShown(rect1H > 0)

        local rect2 = handle.fill.rect2[c]
        local rect2W = R - size
        rect2:ClearAllPoints()
        rect2:SetPoint(anchor, frame, anchor, INSET_X[c] * size, 0)
        rect2:SetSize(rect2W, size)
        rect2:SetShown(rect2W > 0 and size > 0)
    end

    local bandW = haveSize and math.max(w - 2 * R, 0) or 0
    local bandH = haveSize and math.max(h - 2 * R, 0) or 0
    local fullW = haveSize and w or 0

    handle.fill.topBand:ClearAllPoints()
    handle.fill.topBand:SetPoint("TOPLEFT", frame, "TOPLEFT", R, 0)
    handle.fill.topBand:SetSize(bandW, R)
    handle.fill.topBand:SetShown(bandW > 0 and R > 0)

    handle.fill.bottomBand:ClearAllPoints()
    handle.fill.bottomBand:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", R, 0)
    handle.fill.bottomBand:SetSize(bandW, R)
    handle.fill.bottomBand:SetShown(bandW > 0 and R > 0)

    handle.fill.middleBand:ClearAllPoints()
    handle.fill.middleBand:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -R)
    handle.fill.middleBand:SetSize(fullW, bandH)
    handle.fill.middleBand:SetShown(fullW > 0 and bandH > 0)

    if handle.border then
        -- Rings and lines show only when the border is turned on (borderVisible, set by
        -- SetBorderColor's alpha) and they'd actually have something to draw; a zero-length
        -- line stays hidden rather than showing as a 1px dot or seam.
        local visible = handle.borderVisible ~= false
        for _, c in ipairs(CORNERS) do
            local anchor = ANCHOR[c]
            local ring = handle.border.ring[c]
            ring:ClearAllPoints()
            ring:SetPoint(anchor, frame, anchor, 0, 0)
            ring:SetSize(R, R)
            ring:SetShown(visible and R > 0)
        end

        handle.border.lines.top:ClearAllPoints()
        handle.border.lines.top:SetPoint("TOPLEFT", frame, "TOPLEFT", R, 0)
        handle.border.lines.top:SetSize(bandW, 1)
        handle.border.lines.top:SetShown(visible and bandW > 0)

        handle.border.lines.bottom:ClearAllPoints()
        handle.border.lines.bottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", R, 0)
        handle.border.lines.bottom:SetSize(bandW, 1)
        handle.border.lines.bottom:SetShown(visible and bandW > 0)

        handle.border.lines.left:ClearAllPoints()
        handle.border.lines.left:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -R)
        handle.border.lines.left:SetSize(1, bandH)
        handle.border.lines.left:SetShown(visible and bandH > 0)

        handle.border.lines.right:ClearAllPoints()
        handle.border.lines.right:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -R)
        handle.border.lines.right:SetSize(1, bandH)
        handle.border.lines.right:SetShown(visible and bandH > 0)
    end
end

--- Tints the fill: every corner quarter and every fill rect.
-- @param frame Frame
function Round.SetColor(frame, r, g, b, a)
    local handle = rawget(frame, "_echoRound")
    if not handle then return end

    for _, c in ipairs(CORNERS) do
        handle.fill.circle[c]:SetVertexColor(r, g, b, a)
        handle.fill.rect1[c]:SetVertexColor(r, g, b, a)
        handle.fill.rect2[c]:SetVertexColor(r, g, b, a)
    end
    handle.fill.topBand:SetVertexColor(r, g, b, a)
    handle.fill.bottomBand:SetVertexColor(r, g, b, a)
    handle.fill.middleBand:SetVertexColor(r, g, b, a)
end

--- Tints the border. Alpha 0 hides the border pieces outright.
-- @param frame Frame
function Round.SetBorderColor(frame, r, g, b, a)
    local handle = rawget(frame, "_echoRound")
    if not handle or not handle.border then return end

    -- borderVisible is Layout's source of truth for whether to show rings/lines at all;
    -- Layout also hides a piece that has nothing to draw (R == 0, or a zero-length line)
    -- regardless of this flag.
    handle.borderVisible = (a or 1) > 0
    for _, c in ipairs(CORNERS) do
        handle.border.ring[c]:SetVertexColor(r, g, b, a)
    end
    for _, side in ipairs(SIDES) do
        handle.border.lines[side]:SetVertexColor(r, g, b, a)
    end
    Round.Layout(frame)
end

--- A fully round dot from one texture: the whole circle (texcoords 0-1), tinted with
-- SetVertexColor. Cheap alternative to Apply's 9-slice for a badge with no border and no
-- rectangular part, e.g. the unread dot.
-- @param parent Frame
-- @param size number
-- @param layer string|nil  default "OVERLAY"
-- @return Texture
function Round.Dot(parent, size, layer)
    local tex = parent:CreateTexture(nil, layer or "OVERLAY")
    tex:SetTexture(CIRCLE_TEXTURE)
    tex:SetTexCoord(0, 1, 0, 1)
    tex:SetSize(size, size)
    return tex
end

--- Changes the per-corner radii and re-lays out. Bubbles use this when a bubble
-- switches between incoming and outgoing (the tight corner moves sides).
-- @param frame Frame
function Round.SetCorners(frame, tl, tr, bl, br)
    local handle = rawget(frame, "_echoRound")
    if not handle then return end

    handle.corners = { tl = tl, tr = tr, bl = bl, br = br }
    Round.Layout(frame)
end
