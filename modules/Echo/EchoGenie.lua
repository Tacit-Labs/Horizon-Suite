--[[
    Horizon Suite - Echo - Genie
    The card's open and close effect: a solid sheet pours out of the clicked tile and
    fills the card's rect, or collapses back into the tile on close. The sheet is a stack
    of horizontal strips. Each strip covers one band of the card and moves from the tile
    to that band with its own progress: the far end leads, the neck by the tile lags, so
    the side away from the column bows in a curve. Height leads width, so the sheet
    reaches the card's far edge before it fills its width.
    The geometry (Slices, StripProgress) and colour (StripColor) are pure; Play drives one
    lazily built overlay of strip textures from OnUpdate.
    Blizzard: CreateFrame, UIParent, Frame:GetLeft/GetRight/GetBottom/GetTop,
    GetEffectiveScale, Texture:SetColorTexture.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Genie = {}
Echo.Genie = Genie

Genie.STRIPS = 32
Genie.DURATION = 0.22
Genie.FLASH = 0.15      -- the tile's bright flash at the end of a close
Genie.LAG = 2           -- how far the neck lags the far end (an exponent on progress)
Genie.Y_EXP = 0.5       -- vertical placement leads...
Genie.X_EXP = 1.6       -- ...the side away from the column, which fills last
Genie.ANCHOR_EXP = 1    -- the column side follows progress directly

local function Clamp01(x)
    if x < 0 then return 0 elseif x > 1 then return 1 end
    return x
end

local function Lerp(a, b, t) return a + (b - a) * t end

-- How far a point at destination height y sits from the tile's vertical centre, as a
-- fraction of the farthest the card reaches from it: 0 at the neck, 1 at the far end.
local function Distance(from, to, y)
    local centre = (from.bottom + from.top) / 2
    local reach = math.max(math.abs(to.bottom - centre), math.abs(to.top - centre), 1e-6)
    return Clamp01(math.abs(y - centre) / reach)
end

--- A strip's own progress. The far end runs at p; the neck lags as p^(1 + LAG), so every
-- strip still reaches 1 exactly when p does.
-- @param from table  tile rect { left, right, bottom, top }
-- @param to table  card rect
-- @param p number  overall progress, 0..1
-- @param v number  the strip's vertical fraction of the card, 0 (bottom) .. 1 (top)
-- @return number q, number d  its progress, and its distance from the neck (0..1)
function Genie.StripProgress(from, to, p, v)
    p = Clamp01(p)
    local d = Distance(from, to, Lerp(to.bottom, to.top, v))
    return p ^ (1 + Genie.LAG * (1 - d)), d
end

--- The strips of the sheet at progress p.
-- Boundaries are placed once and shared by neighbouring strips, so strips never gap or
-- overlap; they are kept in order when a tile sits mid-card.
-- @param from table  tile rect { left, right, bottom, top } in UIParent units
-- @param to table  card rect
-- @param p number  0 = exactly the tile, 1 = exactly the card
-- @param n number  strip count
-- @param edge string  "left" | "right": the column's side, which stays anchored
-- @return table  { { left, right, bottom, top, d }, ... } bottom to top; d is the
--   strip's distance from the neck, 0..1
function Genie.Slices(from, to, p, n, edge)
    p = Clamp01(p)
    local ys = {}
    for j = 0, n do
        local u = j / n
        local q = Genie.StripProgress(from, to, p, u)
        local y = Lerp(Lerp(from.bottom, from.top, u), Lerp(to.bottom, to.top, u), q ^ Genie.Y_EXP)
        if j > 0 and y < ys[j - 1] then y = ys[j - 1] end
        ys[j] = y
    end
    local anchor, far = "left", "right"
    if edge == "right" then anchor, far = "right", "left" end
    local out = {}
    for i = 1, n do
        local q, d = Genie.StripProgress(from, to, p, (i - 0.5) / n)
        local s = { bottom = ys[i - 1], top = ys[i], d = d }
        s[anchor] = Lerp(from[anchor], to[anchor], q ^ Genie.ANCHOR_EXP)
        s[far] = Lerp(from[far], to[far], q ^ Genie.X_EXP)
        out[i] = s
    end
    return out
end

--- A strip's colour: the tile's colour at the neck, the panel background at the far end.
-- The whole sheet starts as the tile's colour and ends as the background.
-- @param tileRGB table  { r, g, b }
-- @param bgRGBA table  { r, g, b, a }
-- @param v number  distance from the neck, 0..1
-- @param p number  overall progress, 0..1
-- @return number r, number g, number b, number a
function Genie.StripColor(tileRGB, bgRGBA, v, p)
    p = Clamp01(p)
    local base = Clamp01(v) * math.min(1, 4 * p)
    local late = Clamp01((p - 0.6) / 0.4)
    local w = base + (1 - base) * late * late
    return Lerp(tileRGB[1], bgRGBA[1], w), Lerp(tileRGB[2], bgRGBA[2], w),
        Lerp(tileRGB[3], bgRGBA[3], w), Lerp(1, bgRGBA[4] or 1, w)
end

local function Scale(frame)
    local s = frame.GetEffectiveScale and frame:GetEffectiveScale()
    if type(s) ~= "number" or s <= 0 then return 1 end
    return s
end

--- A frame's rect in UIParent units, or nil when it can't be measured.
-- @param frame Frame|nil
-- @return table|nil  { left, right, bottom, top }
function Genie.ReadRect(frame)
    if not frame or not frame.GetLeft or not frame.GetRight or not frame.GetBottom or not frame.GetTop then
        return nil
    end
    local l, r, b, t = frame:GetLeft(), frame:GetRight(), frame:GetBottom(), frame:GetTop()
    if type(l) ~= "number" or type(r) ~= "number" or type(b) ~= "number" or type(t) ~= "number" then
        return nil
    end
    if r <= l or t <= b then return nil end
    local k = Scale(frame) / Scale(UIParent)
    return { left = l * k, right = r * k, bottom = b * k, top = t * k }
end

local overlay
local state  -- { opts, t, duration, p, phase = "sheet" | "flash" }

local function Smooth(f) return f * f * (3 - 2 * f) end

local function Finish()
    if overlay then overlay:Hide() end
    state = nil
end

local function Layout(from, to, p, opts)
    local bg = Echo.View and Echo.View.PANEL_BG or { 0.06, 0.06, 0.09, 0.94 }
    local color = opts.color or { 0.56, 0.64, 0.91 }
    local slices = Genie.Slices(from, to, p, Genie.STRIPS, opts.edge)
    for i, s in ipairs(slices) do
        local tex = overlay.strips[i]
        local w, h = s.right - s.left, s.top - s.bottom
        if w > 0.01 and h > 0.01 then
            tex:ClearAllPoints()
            tex:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", s.left, s.bottom)
            tex:SetSize(w, h)
            tex:SetColorTexture(Genie.StripColor(color, bg, s.d, p))
            tex:Show()
        else
            tex:Hide()
        end
    end
end

-- The close's last beat: the tile flashes bright, then fades.
local function LayoutFlash(tile, f, opts)
    local c = opts.color or { 0.56, 0.64, 0.91 }
    for i = 2, #overlay.strips do overlay.strips[i]:Hide() end
    local tex = overlay.strips[1]
    tex:ClearAllPoints()
    tex:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", tile.left, tile.bottom)
    tex:SetSize(tile.right - tile.left, tile.top - tile.bottom)
    tex:SetColorTexture(Lerp(c[1], 1, 0.6), Lerp(c[2], 1, 0.6), Lerp(c[3], 1, 0.6), 0.9 * (1 - f))
    tex:Show()
end

local function Tick(_, elapsed)
    local s = state
    if not s then return end
    s.t = s.t + (elapsed or 0)
    local from = Genie.ReadRect(s.opts.from)
    if s.phase == "flash" then
        local f = Clamp01(s.t / Genie.FLASH)
        if not from or f >= 1 then Finish() return end
        LayoutFlash(from, f, s.opts)
        return
    end
    local to = Genie.ReadRect(s.opts.to)
    local f = Clamp01(s.t / s.duration)
    local e = Smooth(f)
    s.p = s.opts.reverse and 1 - e or e
    if not from or not to then f = 1 end
    if f < 1 then
        Layout(from, to, s.p, s.opts)
        return
    end
    local done = s.opts.onDone
    s.opts.onDone = nil
    if s.opts.reverse and from then
        s.phase, s.t = "flash", 0
        LayoutFlash(from, 0, s.opts)
    else
        Finish()
    end
    if done then done() end
end

local function EnsureOverlay()
    if overlay then return end
    overlay = CreateFrame("Frame", nil, UIParent)
    overlay:Hide()
    if overlay.EnableMouse then overlay:EnableMouse(false) end
    overlay.strips = {}
    for i = 1, Genie.STRIPS do
        local tex = overlay:CreateTexture(nil, "ARTWORK")
        tex:Hide()
        overlay.strips[i] = tex
    end
    overlay:SetScript("OnUpdate", Tick)
end

--- Play the sheet from a tile to a frame (or back, with reverse).
-- When either rect can't be read, onDone runs at once and nothing is drawn.
-- @param opts table  { from = Frame, to = Frame, reverse = bool, color = {r,g,b},
--   edge = "left"|"right" (the column's side), duration = 0.22, onDone = fn }
function Genie.Play(opts)
    Genie.Stop()
    local from, to = Genie.ReadRect(opts.from), Genie.ReadRect(opts.to)
    if not from or not to then
        if opts.onDone then opts.onDone() end
        return
    end
    EnsureOverlay()
    local strata = opts.to.GetFrameStrata and opts.to:GetFrameStrata()
    if type(strata) == "string" then overlay:SetFrameStrata(strata) end
    local level = opts.to.GetFrameLevel and opts.to:GetFrameLevel()
    overlay:SetFrameLevel((type(level) == "number" and level or 1) + 100)
    opts.edge = opts.edge == "left" and "left" or "right"
    state = { opts = opts, t = 0, duration = opts.duration or Genie.DURATION, phase = "sheet" }
    state.p = opts.reverse and 1 or 0
    Layout(from, to, state.p, opts)
    overlay:Show()
end

--- Hide the overlay at once and drop any pending onDone.
function Genie.Stop()
    if state then state.opts.onDone = nil end
    Finish()
end

--- True while the sheet itself is moving (not during the close's closing flash).
-- @return boolean
function Genie.IsPlaying()
    return state ~= nil and state.phase == "sheet"
end

--- The current overall progress, or nil when idle.
-- @return number|nil
function Genie.Progress()
    return state and state.p
end

-- Test and debug handles.
function Genie._overlay() return overlay end
function Genie._current() return state and state.opts end
