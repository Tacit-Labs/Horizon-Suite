--[[
    Horizon Suite - Echo - Genie
    Genie technique adapted from Whisper Stack by Devin, who gave the director his code to integrate.
    The card's open and close effect, like a macOS window pouring out of its Dock icon.
    The sheet is sampled at boundaries from the card's bottom to its top. Each boundary
    travels from its spot on the tile to its spot on the card on its own delay: the side
    away from the tile leads and the tile side goes last, which makes the funnel. Between
    two boundaries sits one piece. Where textures take SetVertexOffset, a piece is a
    trapezoid whose corners are pinned to both boundaries, so neighbours share edges
    exactly; elsewhere many hair-thin strips read as one shape. Colour runs as a vertical
    gradient from the tile's colour to the panel's, matching at every shared edge. The real
    card fades in over the sheet only at the very end.
    Grow runs 0 (folded into the tile) .. 1 (the card). A close started mid-open, or an
    open started mid-close, carries on from where the sheet is.
    Blizzard: CreateFrame, UIParent, CreateColor, Texture:SetVertexOffset, SetGradient,
    UPPER_LEFT_VERTEX/LOWER_LEFT_VERTEX/UPPER_RIGHT_VERTEX/LOWER_RIGHT_VERTEX.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Genie = {}
Echo.Genie = Genie

Genie.WARP_PIECES = 16   -- trapezoids with pinned corners: smooth, shared edges
Genie.THIN_PIECES = 64   -- fallback: hair-thin strips
Genie.THIN_OVERLAP = 0.6 -- each thin strip is this much taller, to close seams
Genie.STAGGER = 0.45     -- how far behind the far side the tile side runs
Genie.SHOW_AT = 0.84     -- the real card starts to appear here
Genie.OPEN = 0.55        -- seconds for a full open
Genie.CLOSE = 0.45       -- seconds for a full close
Genie.EDGE = 2           -- the accent line riding the top boundary

local function Clamp(x)
    if x < 0 then return 0 elseif x > 1 then return 1 end
    return x
end

local function Smooth(t) return t * t * (3 - 2 * t) end

--- One boundary's own progress.
-- @param v number  overall grow, 0..1
-- @param f number  the boundary's height in the card, 0 (bottom) .. 1 (top)
-- @param tileBelow boolean  the tile sits below the card's centre
-- @return number  0..1
function Genie.BoundaryProgress(v, f, tileBelow)
    local farness = tileBelow and f or (1 - f)
    return Smooth(Clamp((v - (1 - farness) * Genie.STAGGER) / (1 - Genie.STAGGER)))
end

--- The card's alpha at grow v; the sheet's is 1 minus this.
-- @param v number
-- @return number
function Genie.CardAlpha(v)
    return Clamp((v - Genie.SHOW_AT) / (1 - Genie.SHOW_AT))
end

--- Boundaries 0 (bottom) .. n (top), each lerped from the tile rect to the card rect by
-- its own progress.
-- @param from table  tile rect { x, y, w, h } in UIParent units
-- @param to table  card rect
-- @param v number  grow, 0..1
-- @param n number  pieces
-- @return table  { x = {}, w = {}, y = {}, e = {} }, each indexed 0..n
function Genie.Boundaries(from, to, v, n)
    v = Clamp(v)
    local tileBelow = from.y + from.h / 2 <= to.y + to.h / 2
    local b = { x = {}, w = {}, y = {}, e = {} }
    for j = 0, n do
        local f = j / n
        local e = Genie.BoundaryProgress(v, f, tileBelow)
        local ya, yb = from.y + f * from.h, to.y + f * to.h
        b.e[j] = e
        b.x[j] = from.x + (to.x - from.x) * e
        b.w[j] = math.max(1, from.w + (to.w - from.w) * e)
        b.y[j] = ya + (yb - ya) * e
    end
    return b
end

--- The pieces between boundaries.
-- A warped piece is its bounding box plus the horizontal offset of each corner; a thin
-- strip averages its two boundaries and runs a hair taller.
-- @param b table  from Genie.Boundaries
-- @param n number
-- @param warp boolean
-- @return table  { { left, bottom, width, height, e0, e1, ul, ll, ur, lr }, ... }
function Genie.Pieces(b, n, warp)
    local out = {}
    for i = 1, n do
        local j0, j1 = i - 1, i
        local bottom = b.y[j0]
        local height = math.max(0.5, b.y[j1] - bottom)
        local p = { bottom = bottom, e0 = b.e[j0], e1 = b.e[j1] }
        if warp then
            local left = math.min(b.x[j0], b.x[j1])
            local right = math.max(b.x[j0] + b.w[j0], b.x[j1] + b.w[j1])
            p.left, p.width, p.height = left, right - left, height
            p.ul = b.x[j1] - left
            p.ll = b.x[j0] - left
            p.ur = (b.x[j1] + b.w[j1]) - right
            p.lr = (b.x[j0] + b.w[j0]) - right
        else
            p.left = (b.x[j0] + b.x[j1]) / 2
            p.width = (b.w[j0] + b.w[j1]) / 2
            p.height = height + Genie.THIN_OVERLAP
        end
        out[i] = p
    end
    return out
end

--- The tile's colour mixed toward the panel background by e.
-- @param rgb table  { r, g, b }
-- @param bg table  { r, g, b[, a] }
-- @param e number  0..1
-- @return number r, number g, number b
function Genie.Mix(rgb, bg, e)
    return rgb[1] + (bg[1] - rgb[1]) * e, rgb[2] + (bg[2] - rgb[2]) * e, rgb[3] + (bg[3] - rgb[3]) * e
end

local function Scale(frame)
    local s = frame.GetEffectiveScale and frame:GetEffectiveScale()
    if type(s) ~= "number" or s <= 0 then return 1 end
    return s
end

--- A frame's rect in UIParent units, or nil when the client hasn't placed it yet.
-- @param frame Frame|nil
-- @return table|nil  { x, y, w, h }
function Genie.ReadRect(frame)
    if not frame or not frame.GetLeft or not frame.GetBottom or not frame.GetWidth or not frame.GetHeight then
        return nil
    end
    local l, b, w, h = frame:GetLeft(), frame:GetBottom(), frame:GetWidth(), frame:GetHeight()
    if type(l) ~= "number" or type(b) ~= "number" or type(w) ~= "number" or type(h) ~= "number" then
        return nil
    end
    if w <= 0 or h <= 0 then return nil end
    local k = Scale(frame) / Scale(UIParent)
    return { x = l * k, y = b * k, w = w * k, h = h * k }
end

local overlay
local state  -- { opts, from, to, v, start, target, t, duration }
local grow   -- the sheet's current grow, kept after a stop so a reversal can continue

local function Build()
    overlay = CreateFrame("Frame", nil, UIParent)
    overlay:SetFrameStrata("DIALOG")
    overlay:SetAllPoints(UIParent)
    if overlay.EnableMouse then overlay:EnableMouse(false) end
    overlay:Hide()
    local probe = overlay:CreateTexture(nil, "ARTWORK")
    overlay.warp = type(probe.SetVertexOffset) == "function"
    overlay.n = overlay.warp and Genie.WARP_PIECES or Genie.THIN_PIECES
    overlay.pieces = { probe }
    for i = 2, overlay.n do overlay.pieces[i] = overlay:CreateTexture(nil, "ARTWORK") end
    local a = Echo.View and Echo.View.ACCENT or { r = 0.56, g = 0.64, b = 0.91 }
    overlay.edge = overlay:CreateTexture(nil, "OVERLAY")
    overlay.edge:SetColorTexture(a.r, a.g, a.b, 1)
    overlay.edge:SetHeight(Genie.EDGE)
end

-- Draws the sheet at grow v over the fixed rects.
local function Apply(s, v)
    local target = s.opts.to
    local cardA = Genie.CardAlpha(v)
    if target and target.SetAlpha then target:SetAlpha(cardA) end
    overlay:SetAlpha(1 - cardA)
    overlay:Show()

    local n = overlay.n
    local b = Genie.Boundaries(s.from, s.to, v, n)
    local pieces = Genie.Pieces(b, n, overlay.warp)
    local rgb = s.opts.color or { 0.56, 0.64, 0.91 }
    local bg = Echo.View and Echo.View.PANEL_BG or { 0.06, 0.06, 0.09 }
    local gradients = type(CreateColor) == "function"
    local UL, LL = UPPER_LEFT_VERTEX or 1, LOWER_LEFT_VERTEX or 2
    local UR, LR = UPPER_RIGHT_VERTEX or 3, LOWER_RIGHT_VERTEX or 4
    for i, p in ipairs(pieces) do
        local t = overlay.pieces[i]
        t:ClearAllPoints()
        t:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", p.left, p.bottom)
        t:SetSize(p.width, p.height)
        if overlay.warp then
            t:SetVertexOffset(UL, p.ul, 0)
            t:SetVertexOffset(LL, p.ll, 0)
            t:SetVertexOffset(UR, p.ur, 0)
            t:SetVertexOffset(LR, p.lr, 0)
        end
        local r1, g1, b1 = Genie.Mix(rgb, bg, p.e0)
        local r2, g2, b2 = Genie.Mix(rgb, bg, p.e1)
        if gradients then
            t:SetColorTexture(1, 1, 1, 1)
            t:SetGradient("VERTICAL", CreateColor(r1, g1, b1, 1), CreateColor(r2, g2, b2, 1))
        else
            t:SetColorTexture((r1 + r2) / 2, (g1 + g2) / 2, (b1 + b2) / 2, 1)
        end
        t:Show()
    end

    -- The accent line rides the top boundary, where the card's own top rule will be.
    overlay.edge:ClearAllPoints()
    overlay.edge:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", b.x[n], b.y[n])
    overlay.edge:SetWidth(b.w[n])
    overlay.edge:Show()
end

local function Finish()
    if overlay then overlay:Hide() end
    state = nil
end

local function Step(s, v)
    grow = v
    s.v = v
    -- Done only on reaching the target: an open starts at 0 and a close at 1.
    if v == s.target then
        local done = s.opts.onDone
        s.opts.onDone = nil
        Finish()
        if v >= 1 and s.opts.to and s.opts.to.SetAlpha then s.opts.to:SetAlpha(1) end
        if done then done() end
        return
    end
    Apply(s, v)
end

local function Tick(_, elapsed)
    local s = state
    if not s then return end
    s.t = s.t + (elapsed or 0)
    local f = s.duration > 0 and Clamp(s.t / s.duration) or 1
    Step(s, f >= 1 and s.target or (s.start + (s.target - s.start) * f))
end

--- Grow the card out of a tile (or, with reverse, back into it). Starts from wherever a
-- running or just-stopped sheet is, so reversing mid-way carries on from there.
-- When neither the tile nor the fallback has a rect, or the card has none, onDone runs
-- at once.
-- @param opts table  { from = Frame, fallback = Frame|nil, to = Frame, reverse = bool,
--   color = {r,g,b}, onDone = fn }
function Genie.Play(opts)
    local start = state and state.v or grow
    if state then state.opts.onDone = nil end
    Finish()
    local target = opts.reverse and 0 or 1
    if start == nil then start = opts.reverse and 1 or 0 end
    local from = Genie.ReadRect(opts.from) or Genie.ReadRect(opts.fallback)
    local to = Genie.ReadRect(opts.to)
    if not from or not to then
        grow = nil
        if opts.to and opts.to.SetAlpha then opts.to:SetAlpha(1) end
        if opts.onDone then opts.onDone() end
        return
    end
    if not overlay then Build() end
    local duration = opts.reverse and Genie.CLOSE * start or Genie.OPEN * (1 - start)
    state = { opts = opts, from = from, to = to, v = start, start = start, target = target, t = 0,
              duration = duration }
    overlay:SetScript("OnUpdate", Tick)
    Step(state, start)
end

--- Hide the sheet at once, drop any pending onDone, and forget where it was.
function Genie.Stop()
    if state then state.opts.onDone = nil end
    Finish()
    grow = nil
end

--- @return boolean
function Genie.IsPlaying()
    return state ~= nil
end

--- The current grow, or nil when idle.
-- @return number|nil
function Genie.Progress()
    return state and state.v
end

-- Test and debug handles.
function Genie._overlay() return overlay end
function Genie._current() return state and state.opts end
function Genie._reset() Genie.Stop(); overlay = nil end
