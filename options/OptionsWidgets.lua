--[[
    Horizon Suite - Focus - Options Widgets
    Reusable widget library: toggle, slider, dropdown, color swatch, search input, reorder list, section card/header.
    Modern Cinematic styling. All widgets expose :Refresh() and .searchText for search indexing.
]]

local addon = _G.HorizonSuite
if not addon then return end

local L = addon.L

-- Design tokens (Cinematic, Modern, Minimalistic). Panel can override FontPath/HeaderSize via SetDef.
local Def = {
    Padding = 18,
    OptionGap = 18,
    SectionGap = 30,
    CardPadding = 18,
    CardBottomPadding = 26,
    BorderEdge = 1,
    CornerRadius = 8,
    LabelSize = 13,
    SectionSize = 11,
    FontPath = (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF",
    HeaderSize = addon.HEADER_SIZE or 16,
    TextColorNormal = { 1, 1, 1 },
    TextColorHighlight = { 0.92, 0.93, 0.96, 1 },   -- neutral hover text; the accent is kept for on/selected states
    TextColorLabel = { 0.84, 0.84, 0.88 },
    TextColorSection = { 0.58, 0.64, 0.74 },
    TextColorTitleBar = { 0.9, 0.92, 0.96, 1 },
    SectionCardBg = { 0.09, 0.09, 0.11, 0.96 },
    SectionCardBorder = { 0.18, 0.2, 0.24, 0.35 },
    SectionCardHeaderHighlight = { 0.96, 0.97, 0.99, 0.015 },
    AccentColor = { 0.48, 0.58, 0.82, 0.9 },
    DividerColor = { 0.35, 0.4, 0.5, 0.25 },
    InputBg = { 0.07, 0.07, 0.1, 0.96 },
    InputBorder = { 0.2, 0.22, 0.28, 0.3 },
    TrackOff = { 0.14, 0.14, 0.18, 0.95 },
    TrackOn = { 0.48, 0.58, 0.82, 0.85 },
    ThumbColor = { 1, 1, 1, 0.98 },
    WidgetFontFlags = "OUTLINE",
    WidgetTextShadow = false,

    -- Modern dashboard style (Docs/Engineering/2026-10-05-dashboard-modern-style-design.md).
    -- Colours follow the approved mockup's CSS variables.
    TextColorMuted = { 0.54, 0.565, 0.627 },        -- descriptions and help (#8a90a0)
    TextColorFaint = { 0.365, 0.384, 0.447 },       -- the card chevron (#5d6272)
    CardBg = { 0.09, 0.09, 0.114, 0.96 },           -- card panel (#17171d)
    CardBgHover = { 0.11, 0.11, 0.137, 0.96 },      -- closed card header under the cursor (#1c1c23)
    CardRadius = 12,
    CardGap = 14,                                   -- space between cards
    CardHeaderPadY = 14,                            -- space above and below the card title
    CardContentBottom = 6,                          -- space below a card's last row (rows pad themselves)
    CardDescGap = 12,                               -- title to description
    RowIndent = 20,                                 -- extra left inset of a dependent row
    RowDivider = { 0.59, 0.63, 0.75, 0.10 },        -- hairline between rows
    RowHover = { 1, 1, 1, 0.025 },
    SegTrackBg = { 0.063, 0.063, 0.082, 0.96 },     -- segmented track (#101015, as InputBg)
    SegSelectedBg = { 0.11, 0.11, 0.137, 1 },       -- raised selected segment (#1c1c23)
    SegSelectedRing = { 0.59, 0.63, 0.75, 0.18 },
    SegTextSelected = { 0.914, 0.918, 0.937 },      -- the selected segment's label (#e9eaef)
    SegTrackPad = 2,                                -- track edge to the segments
    SegGap = 2,                                     -- between segments
    SegPadX = 11,                                   -- label to segment edge, each side
    SegRadius = 6,                                  -- a segment's corners (the track uses ControlRadius)
    SegFitShare = 0.5,                              -- segments must fit in this share of the row's width
    SegDisabledAlpha = 0.45,
    SegSlideDuration = 0.15,                        -- seconds for the selection to slide on a click
    FocusRing = { 0.59, 0.63, 0.75, 0.35 },         -- neutral ring on a focused input (was the accent)
    SidebarSelectedBg = { 0.48, 0.58, 0.82, 0.16 }, -- accent at 16%; the class theme swaps the rgb
    SwitchWidth = 36,
    SwitchHeight = 20,
    SwitchInset = 2,                                -- track edge to thumb

    -- Motion (Docs/Engineering/2026-10-05-dashboard-premium-polish-design.md).
    MotionFast = 0.12,                              -- seconds: switch slide, slider thumb and value
    MotionPress = 0.06,                             -- seconds: a control easing to and from its press scale
    PressScale = 0.97,                              -- a held-down control's scale, about its centre
    RowStagger = 0.02,                              -- seconds between rows starting as a card opens
    RowStaggerCap = 0.25,                           -- seconds: the whole card-opening sequence, at most
    RowRise = 6,                                    -- px a row rises into place as a card opens

    -- Changed-from-default markers (AttachChangedMarker). The dot is the accent colour.
    ChangedDotSize = 6,
    ChangedDotX = 9,                                -- dot centre, left of the label (in the card padding)
    ChangedResetSize = 12,                          -- the hover reset arrow
    ChangedResetGap = 4,                            -- label text to the reset arrow

    -- Card header geometry (DashboardAccordionCard.lua).
    TitleLineFactor = 1.35,                         -- title line height as a multiple of TitleSize
    CardHeaderSwitchGap = 10,                       -- header switch to chevron
    CardChevronSize = 16,
    CardChevronBarLen = 7,
    CardChevronBarW = 2,
    CardDescMinWidth = 40,                          -- narrower than this, the card description hides

    -- Settings rows: grouped, no boxes, a hairline between rows (mockup .row).
    RowHeight = 40,                                 -- the shortest row (one label line, no description)
    RowPadY = 11,                                   -- space above and below a row's text
    RowDescGap = 2,                                 -- label to description
    RowControlGap = 16,                             -- label column to the controls
    RowLabelMaxLines = 2,
    RowDescMaxLines = 2,                            -- then an ellipsis
    LineHeightFactor = 1.2,                         -- line height estimate (x font size) before text is measured
    RowLineCapFactor = 1.5,                         -- per-line cap (x font size) on a measured height
    RowIndentBarX = 2,                              -- dependent-row line, from the parent row's left
    RowIndentBarW = 2,
    RowIndentBarAlpha = 0.3,
    SubheadingTopGap = 16,                          -- mockup .sub-h padding
    SubheadingBottomGap = 6,
    NoteTopGap = 6,
    BlockPadY = 8,                                  -- above and below a custom widget (lists, grids)

    -- Flat controls: InputBg with a radius and no border; a ring only on keyboard focus.
    ControlRadius = 8,
    ControlHeight = 26,
    InputBgHover = { 0.1, 0.1, 0.13, 0.96 },
    SliderTrackH = 4,
    SliderTrackMin = 120,
    SliderTrackMax = 180,
    SliderThumbSize = 14,
    SliderThumbHoverScale = 1.15,                   -- the thumb's size while hovered or dragged
    SliderValueW = 44,
    SliderValueH = 20,
    SliderValueGap = 10,
    SwatchSize = 22,
    SwatchRadius = 6,
    SwatchRing = { 0.59, 0.63, 0.75, 0.18 },        -- mockup --line-strong
}
Def.BorderColor = Def.SectionCardBorder
if addon.StandardFont then
    Def.FontPath = addon.StandardFont
end

-- The type scale: titles sit two sizes above labels and help two below, so the dashboard
-- text-size setting (which sets LabelSize) scales all three. A size the caller sets itself wins.
local TYPE_SCALE_STEP = 2
local TYPE_SCALE_MIN = 8

--- The title and help sizes for a label size. Pure; exposed for the logic tests.
--- @param labelSize number|nil  Default 13
--- @return number titleSize, number helpSize
local function TypeScaleFor(labelSize)
    local label = tonumber(labelSize) or 13
    return label + TYPE_SCALE_STEP, math.max(TYPE_SCALE_MIN, label - TYPE_SCALE_STEP)
end
addon.OptionsWidgets_TypeScaleFor = TypeScaleFor

local function DeriveTypeScale(overrides)
    local title, help = TypeScaleFor(Def.LabelSize)
    if not (overrides and overrides.TitleSize ~= nil) then Def.TitleSize = title end
    if not (overrides and overrides.HelpSize ~= nil) then Def.HelpSize = help end
end
DeriveTypeScale()

function _G.OptionsWidgets_SetDef(overrides)
    if not overrides then return end
    for k, v in pairs(overrides) do Def[k] = v end
    if overrides.LabelSize ~= nil then DeriveTypeScale(overrides) end
end
addon.OptionsWidgetsDef = Def

-- Default accent when the Axis class theme is off (the original AccentColor/TrackOn rgb).
-- Single source: GetAccentColor in DashboardFrame reads it through addon.OptionsAccentDefault.
local ACCENT_DEFAULT = { 0.48, 0.58, 0.82 }
addon.OptionsAccentDefault = ACCENT_DEFAULT

-- Point the accent tokens (AccentColor, TrackOn, SidebarSelectedBg) at the class colour when the
-- Axis class theme is on, else at the default. Widgets pick the new colour up the next time they
-- paint (a switch or slider on its next Refresh, the sidebar on its next selection).
function addon.ApplyOptionsClassColor()
    local cc = addon.GetOptionsClassColor and addon.GetOptionsClassColor()
    local c = cc or ACCENT_DEFAULT
    Def.AccentColor = { c[1], c[2], c[3], 0.9 }
    Def.TrackOn = { c[1], c[2], c[3], 0.85 }
    Def.SidebarSelectedBg = { c[1], c[2], c[3], 0.16 }
end

-- Class color lookup: returns {r, g, b} for player class, nil if unavailable.
local function GetClassColorRaw()
    local _, classFile = UnitClass("player")
    if not classFile then return nil end
    local cc = C_ClassColor and C_ClassColor.GetClassColor(classFile)
    if cc then return { cc.r, cc.g, cc.b } end
    local rc = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
    if rc then return { rc.r, rc.g, rc.b } end
    return nil
end

-- Returns player class RGB when the module's class-colour DB toggle is enabled, else nil.
-- @param moduleKey string Lowercase module id: dashboard, vista, insight, essence, focus, presence, augment, echo
-- @return table|nil { r, g, b } with components in 0–1
function addon.GetModuleClassColor(moduleKey)
    if type(moduleKey) ~= "string" or moduleKey == "" then return nil end
    local cap = moduleKey:sub(1, 1):upper() .. moduleKey:sub(2)
    local dbKey = "classColor" .. cap
    if not (addon.GetDB and addon.GetDB(dbKey, false)) then
        return nil
    end
    return GetClassColorRaw()
end

-- Returns {r, g, b} when dashboard/options panel should use class colour, nil otherwise.
function addon.GetOptionsClassColor()
    return addon.GetModuleClassColor("dashboard")
end

-- Returns {r, g, b} when Vista should use class colour, nil otherwise.
function addon.GetVistaClassColor()
    return addon.GetModuleClassColor("vista")
end

local SetTextColor = addon.SetTextColor or function(obj, color)
    if not color or not obj then return end
    obj:SetTextColor(color[1], color[2], color[3], color[4] or 1)
end

local DEFAULT_FALLBACK_FONT = (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"

-- Registry of widget FontStrings that were set with nil flags (i.e. defer to Def.WidgetFontFlags).
-- Populated by SetSafeFont; consumed by OptionsWidgets_RefreshFonts.
local widgetFontRegistry = {}

-- Re-apply current Def font path and WidgetFontFlags to all registered widget FontStrings.
-- Call after OptionsWidgets_SetDef changes WidgetFontFlags or FontPath.
function _G.OptionsWidgets_RefreshFonts()
    local path = Def.FontPath or DEFAULT_FALLBACK_FONT
    local flags = Def.WidgetFontFlags or "OUTLINE"
    for _, e in ipairs(widgetFontRegistry) do
        local fs = e.fs
        if fs and fs.SetFont then
            pcall(function() fs:SetFont(path, e.size, flags) end)
            if addon.Dashboard_ApplyTextShadow then addon.Dashboard_ApplyTextShadow(fs) end
        end
    end
end

local function SetSafeFont(fs, path, size, flags)
    if not fs then return false end
    path = path or Def.FontPath or DEFAULT_FALLBACK_FONT
    local effFlags = flags
    if effFlags == nil then
        effFlags = Def.WidgetFontFlags or "OUTLINE"
        -- Register so OptionsWidgets_RefreshFonts can re-apply when WidgetFontFlags changes.
        -- Guard against duplicate entries when the same FontString is re-fonted (e.g. on refresh).
        if not fs._horizonFontRegistered then
            fs._horizonFontRegistered = true
            widgetFontRegistry[#widgetFontRegistry + 1] = { fs = fs, size = size }
        end
    end
    local ok = fs:SetFont(path, size, effFlags)
    if not ok then
        if path ~= DEFAULT_FALLBACK_FONT then
            ok = fs:SetFont(DEFAULT_FALLBACK_FONT, size, effFlags)
        end
        if not ok then
            ok = fs:SetFont("Fonts\\FRIZQT__.TTF", size, effFlags)
        end
    end
    if ok and addon.Dashboard_ApplyTextShadow then
        addon.Dashboard_ApplyTextShadow(fs)
    end
    return ok
end
-- Exported so other options UI (e.g. HorizonColorPicker) reuses the same font registry + refresh + shadow.
addon.OptionsWidgets_SetSafeFont = SetSafeFont

local easeOut = addon.easeOut or function(t) return 1 - (1 - t) * (1 - t) end

-- Apply optional hover tooltip to option rows (desc = inline; tooltip = hover detail).
local function ApplyOptionTooltip(frame, tooltip)
    if not tooltip or tooltip == "" then return end
    frame:EnableMouse(true)
    frame:HookScript("OnEnter", function()
        local tt = type(tooltip) == "function" and tooltip() or tooltip
        if not tt or tt == "" then return end
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        -- Split on \n\n so callers can append extra lines (e.g. shift-click hints).
        -- First segment → SetText (white title); subsequent segments → AddLine (grey).
        local segments = {}
        for seg in (tt .. "\n\n"):gmatch("(.-)\n\n") do
            seg = seg:match("^%s*(.-)%s*$")
            if seg ~= "" then segments[#segments + 1] = seg end
        end
        if #segments == 0 then segments[1] = tt end
        GameTooltip:SetText(segments[1], 1, 1, 1, 1, true)
        for i = 2, #segments do
            GameTooltip:AddLine(segments[i], 0.7, 0.7, 0.7, true)
        end
        GameTooltip:Show()
    end)
    frame:HookScript("OnLeave", function()
        if not frame:IsMouseOver() then
            GameTooltip:Hide()
        end
    end)
end

-- Combine an inline description and a hover tooltip into one tooltip string (blank-line separated).
local function JoinTooltip(desc, tip)
    if type(tip) == "function" then
        return function()
            local liveTip = tip()
            return (desc or "") .. (desc and liveTip and "\n\n" or "") .. (liveTip or "")
        end
    end
    return (desc or "") .. (desc and tip and "\n\n" or "") .. (tip or "")
end

local ROW_HOVER_FADE = 0.15

-- Paint a frame as a rounded fill when Echo.Round is available (a manual 9-slice over bundled
-- textures that runs on Retail and Forever), else as a flat square fill. With withRing, the
-- frame also gets a hairline ring, hidden until paintRing gives it an alpha above 0.
-- @param frame Frame  One fill per frame (Echo.Round caches its pieces on the frame)
-- @param radius number
-- @param layer string|nil  Default "BACKGROUND"
-- @param withRing boolean|nil
-- @return function paint(r, g, b, a), function paintRing(r, g, b, a)
local function PaintRounded(frame, radius, layer, withRing)
    layer = layer or "BACKGROUND"
    local Round = addon.Echo and addon.Echo.Round
    if Round and Round.Apply and Round.SetColor then
        Round.Apply(frame, { radius = radius, layer = layer, border = withRing and true or nil })
        local function paint(r, g, b, a) Round.SetColor(frame, r, g, b, a) end
        local function paintRing(r, g, b, a)
            if withRing and Round.SetBorderColor then Round.SetBorderColor(frame, r, g, b, a) end
        end
        paintRing(0, 0, 0, 0)
        return paint, paintRing
    end
    local tex = frame:CreateTexture(nil, layer)
    tex:SetAllPoints(frame)
    tex:SetColorTexture(1, 1, 1, 1)
    local edges = {}
    if withRing and addon.CreateBorder then
        edges = { addon.CreateBorder(frame, { 0, 0, 0, 0 }) }
    end
    local function paint(r, g, b, a) tex:SetVertexColor(r, g, b, a) end
    local function paintRing(r, g, b, a)
        for _, e in ipairs(edges) do
            if e and e.SetColorTexture then e:SetColorTexture(r, g, b, a or 1) end
        end
    end
    return paint, paintRing
end
addon.OptionsWidgets_PaintRounded = PaintRounded

-- A round dot (Echo.Round.Dot) or, without it, a square colour texture. Tint with SetVertexColor.
local function MakeDot(parent, size, layer)
    local Round = addon.Echo and addon.Echo.Round
    local tex
    if Round and Round.Dot then
        tex = Round.Dot(parent, size, layer)
    else
        tex = parent:CreateTexture(nil, layer or "OVERLAY")
        tex:SetColorTexture(1, 1, 1, 1)
        tex:SetSize(size, size)
    end
    return tex
end

-- Paint a token colour through a paint function, with an optional alpha multiplier.
local function PaintToken(paint, c, alphaMult)
    paint(c[1], c[2], c[3], (c[4] or 1) * (alphaMult or 1))
end

-- ---------------------------------------------------------------------------
-- Motion: one small tween runner shared by the switches, the sliders and press feedback.
-- The maths is pure and exposed for the logic tests; frames only drive it from OnUpdate.
-- ---------------------------------------------------------------------------

--- a to b at t. Pure. Exact at the ends (t <= 0 gives a, t >= 1 gives b), so a finished
--- tween never leaves a rounding error behind.
local function Lerp(a, b, t)
    if t <= 0 then return a end
    if t >= 1 then return b end
    return a + (b - a) * t
end
addon.OptionsWidgets_Lerp = Lerp

--- Advance a tween by one frame. Pure.
--- @param t number|nil  Seconds run so far
--- @param elapsed number|nil  Seconds since the last frame (negative counts as 0)
--- @param dur number|nil  Total seconds; 0 or nil finishes at once
--- @param ease function|nil  Default easeOut
--- @return number t, number e (eased progress, exactly 1 when done), boolean done
local function TweenAdvance(t, elapsed, dur, ease)
    t = (tonumber(t) or 0) + math.max(0, tonumber(elapsed) or 0)
    if not dur or dur <= 0 or t >= dur then return t, 1, true end
    return t, (ease or easeOut)(t / dur), false
end
addon.OptionsWidgets_TweenAdvance = TweenAdvance

--- How a control paints a new value: the segmented control's rule, shared. Pure.
--- A player action animates; anything else (a refresh, a profile switch) snaps; the same
--- value again while a tween already heads there lets that tween finish.
--- @param animate boolean|nil  A player click or typed value asked for this paint
--- @param from number|nil  What the control shows now
--- @param to number  The new value
--- @param tweenTo number|nil  Where the running tween heads, if one runs
--- @param canAnimate boolean|nil  The control is visible and the duration is above 0
--- @return string "finish", "animate" or "snap"
local function TweenPlan(animate, from, to, tweenTo, canAnimate)
    if tweenTo ~= nil and tweenTo == to then return "finish" end
    if animate and canAnimate and from ~= nil and from ~= to then return "animate" end
    return "snap"
end
addon.OptionsWidgets_TweenPlan = TweenPlan

--- The scale a pressable control heads to. Pure.
--- @param down boolean  The mouse is held on it
--- @param disabled boolean|nil
--- @return number
local function PressTarget(down, disabled)
    if down and not disabled then return Def.PressScale or 1 end
    return 1
end
addon.OptionsWidgets_PressTarget = PressTarget

--- A slider thumb's drawn size at an active amount e (0 at rest, 1 hovered or dragged). Pure.
--- @param base number  Def.SliderThumbSize
--- @param e number
--- @return number
local function SliderThumbSizeAt(base, e)
    return base * Lerp(1, Def.SliderThumbHoverScale or 1, e)
end
addon.OptionsWidgets_SliderThumbSizeAt = SliderThumbSizeAt

--- The timing of a card's rows staggering in as it opens. Pure. Each row runs for rowDur and
--- starts step after the row above; when that would run past cap, the step shrinks so the last
--- row lands exactly at cap (and rowDur itself never exceeds cap).
--- @param count number  Rows that stagger
--- @param step number  Def.RowStagger
--- @param rowDur number  One row's fade and rise
--- @param cap number|nil  Def.RowStaggerCap
--- @return number step, number rowDur, number total (seconds until the last row is in place)
local function RowStaggerSchedule(count, step, rowDur, cap)
    count = math.max(0, math.floor(tonumber(count) or 0))
    step = math.max(0, tonumber(step) or 0)
    rowDur = math.max(0, tonumber(rowDur) or 0)
    cap = tonumber(cap)
    if cap and cap < 0 then cap = 0 end
    if cap and rowDur > cap then rowDur = cap end
    if count == 0 then return step, rowDur, 0 end
    if cap and count > 1 and (count - 1) * step + rowDur > cap then
        step = (cap - rowDur) / (count - 1)
    end
    return step, rowDur, (count - 1) * step + rowDur
end
addon.OptionsWidgets_RowStaggerSchedule = RowStaggerSchedule

--- One staggered row's look at time t. Pure. Before its start a row is invisible and rise px
--- low; it eases up and in, and is exactly alpha 1 at offset 0 once done.
--- @param index number  1 for the top row
--- @param t number  Seconds since the card started opening
--- @param step number  From RowStaggerSchedule
--- @param rowDur number  From RowStaggerSchedule
--- @param rise number  Def.RowRise
--- @return number alpha, number dy (added to the row's y; negative is lower), boolean done
local function RowStaggerAt(index, t, step, rowDur, rise)
    local start = ((tonumber(index) or 1) - 1) * (tonumber(step) or 0)
    local _, e, done = TweenAdvance(0, (tonumber(t) or 0) - start, rowDur)
    if done then return 1, 0, true end
    return e, -(tonumber(rise) or 0) * (1 - e), false
end
addon.OptionsWidgets_RowStaggerAt = RowStaggerAt

--- Stop frame's tween where it is, without finishing it. Returns the stopped tween, if any.
local function StopTween(frame)
    local tw = frame._hsTween
    if not tw then return nil end
    frame._hsTween = nil
    frame:SetScript("OnUpdate", nil)
    return tw
end

--- Jump frame's tween to its end state: onStep(1), then onFinish.
local function FinishTween(frame)
    local tw = StopTween(frame)
    if not tw then return end
    tw.onStep(1)
    if tw.onFinish then tw.onFinish() end
end

--- Run onStep(e) on frame's OnUpdate, e easing from 0 to exactly 1 over dur, then onFinish().
--- One tween per frame, owning that frame's OnUpdate while it runs: a new tween replaces the
--- old one without finishing it, so the caller restarts from what is on screen. A hidden frame
--- (or a duration of 0) jumps to the end at once. Hiding the frame mid-tween ends it exactly:
--- onHide() when given, else onStep(1) then onFinish().
--- @param frame Frame
--- @param dur number
--- @param onStep function(e)
--- @param onFinish function|nil
--- @param onHide function|nil
local function StartTween(frame, dur, onStep, onFinish, onHide)
    StopTween(frame)
    if not dur or dur <= 0 or not frame:IsVisible() then
        onStep(1)
        if onFinish then onFinish() end
        return
    end
    local tw = { t = 0, dur = dur, onStep = onStep, onFinish = onFinish, onHide = onHide }
    frame._hsTween = tw
    if not frame._hsTweenHooked then
        frame._hsTweenHooked = true
        frame:HookScript("OnHide", function(self)
            local cur = self._hsTween
            if not cur then return end
            if cur.onHide then
                StopTween(self)
                cur.onHide()
            else
                FinishTween(self)
            end
        end)
    end
    frame:SetScript("OnUpdate", function(self, elapsed)
        if self._hsTween ~= tw then return end
        local e, done
        tw.t, e, done = TweenAdvance(tw.t, elapsed, tw.dur)
        tw.onStep(e)
        if done then
            StopTween(self)
            if tw.onFinish then tw.onFinish() end
        end
    end)
end

addon.OptionsWidgets_StartTween = StartTween
addon.OptionsWidgets_StopTween = StopTween

--- A frame for a control's visible parts, anchored by its CENTER alone to host's centre and
--- kept at host's size, so press feedback can scale it about the centre. WoW scales a frame
--- about its anchor point, so scaling host itself (anchored by RIGHT or TOPLEFT) would shift
--- it, and would shrink its click area. Build the fill and the text on the returned frame.
--- @param host Frame
--- @return Frame
local function CreatePressVisual(host)
    local vis = CreateFrame("Frame", nil, host)
    vis:SetPoint("CENTER", host, "CENTER", 0, 0)
    local function sync()
        local w, h = host:GetSize()
        vis:SetSize(math.max(1, w or 1), math.max(1, h or 1))
    end
    sync()
    host:HookScript("OnSizeChanged", sync)
    -- A caller may raise host's frame level after building it (the detail page's fixed buttons
    -- do). Keep vis above host on show, so its fill never drops under host's neighbours.
    host:HookScript("OnShow", function()
        local lvl = host:GetFrameLevel()
        if vis:GetFrameLevel() <= lvl then vis:SetFrameLevel(lvl + 1) end
    end)
    return vis
end

--- Press feedback: while the left button is held on host, visual eases to Def.PressScale over
--- Def.MotionPress and eases back on release; hiding host puts it straight back to 1. Visual
--- only: host's scripts are hooked, never replaced, and host keeps its size, so the click lands
--- exactly as before. A disabled host (isDisabled() true, or a Button that is not enabled)
--- does not react. Visual must be anchored by its CENTER alone (CreatePressVisual).
--- @param host Frame  Receives the mouse
--- @param visual Frame  Scaled
--- @param isDisabled function|nil
local function AttachPress(host, visual, isDisabled)
    if not (host and visual and host.HookScript and visual.SetScale) then return end
    local function rest()
        StopTween(visual)
        visual:SetScale(1)
    end
    local function toward(target)
        local from = visual:GetScale() or 1
        if math.abs(from - target) < 0.0001 then
            StopTween(visual)
            visual:SetScale(target)
            return
        end
        StartTween(visual, Def.MotionPress, function(e)
            visual:SetScale(Lerp(from, target, e))
        end, nil, rest)
    end
    host:HookScript("OnMouseDown", function(_, button)
        if button and button ~= "LeftButton" then return end
        local dis = (isDisabled and isDisabled() == true)
            or (host.IsEnabled and not host:IsEnabled())
        if dis then return end
        toward(PressTarget(true, false))
    end)
    host:HookScript("OnMouseUp", function() toward(1) end)
    host:HookScript("OnHide", rest)
end
addon.OptionsWidgets_AttachPress = AttachPress

-- A faint highlight across the row while the cursor is over it. The texture is kept on
-- row._rowHover; DashboardAccordionBuild stretches it to the card's edges.
local function ApplyRowHoverHighlight(row)
    if not row then return end
    local hiBg = row:CreateTexture(nil, "BACKGROUND", nil, -7) -- Behind track/thumb backgrounds
    hiBg:SetPoint("TOPLEFT", row, "TOPLEFT", -Def.CardPadding, 0)
    hiBg:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", Def.CardPadding, 0)
    local c = Def.RowHover
    hiBg:SetColorTexture(c[1], c[2], c[3], c[4] or 1)
    hiBg:Hide()
    row._rowHover = hiBg

    row:EnableMouse(true)
    row:HookScript("OnEnter", function()
        UIFrameFadeIn(hiBg, ROW_HOVER_FADE, 0, 1)
        hiBg:Show()
    end)
    row:HookScript("OnLeave", function()
        hiBg:Hide()
    end)
end

-- Metrics for addon.SettingsRowHeight from the live Def sizes.
local function RowHeightMetrics()
    return {
        minH = Def.RowHeight,
        padY = Def.RowPadY,
        descGap = Def.RowDescGap,
        labelMaxH = Def.RowLabelMaxLines * Def.LabelSize * Def.RowLineCapFactor,
        descMaxH = Def.RowDescMaxLines * Def.HelpSize * Def.RowLineCapFactor,
    }
end

-- A row's height before its text is measured: one label line, and one description line when
-- there is a description.
local function EstimatedRowHeight(hasDesc)
    local labelH = Def.LabelSize * Def.LineHeightFactor
    local descH = hasDesc and (Def.HelpSize * Def.LineHeightFactor) or 0
    if addon.SettingsRowHeight then return (addon.SettingsRowHeight(labelH, descH, RowHeightMetrics())) end
    return Def.RowHeight
end

-- A description FontString under a row's label: HelpSize, muted, at most Def.RowDescMaxLines
-- lines ending in an ellipsis.
local function CreateRowDesc(row, description)
    local desc = row:CreateFontString(nil, "OVERLAY")
    SetSafeFont(desc, Def.FontPath, Def.HelpSize, nil)
    desc:SetJustifyH("LEFT")
    desc:SetJustifyV("TOP")
    SetTextColor(desc, Def.TextColorMuted)
    desc:SetWordWrap(true)
    if desc.SetNonSpaceWrap then desc:SetNonSpaceWrap(false) end
    if desc.SetMaxLines then desc:SetMaxLines(Def.RowDescMaxLines) end
    local hasDesc = type(description) == "string" and description ~= ""
    desc:SetText(hasDesc and description or "")
    desc:SetShown(hasDesc)
    return desc, hasDesc
end

-- The label and description on the left of a settings row. The label wraps to at most
-- Def.RowLabelMaxLines lines and the description (the row's desc) to Def.RowDescMaxLines, then
-- ends in an ellipsis. The row's height comes from addon.SettingsRowHeight: Def.RowHeight
-- without a description, about 52px with a one-line one and 66px with two; the text block is
-- centred vertically.
-- Marks the row as padding itself (row._rowPadded), so the card adds no gap around it.
-- Re-fits when the row's width changes; call text.Fit(true) after a font or label change.
-- When the height changes, row.onHeightChanged() runs so the card can restack.
-- @param row Frame
-- @param labelText string|nil
-- @param description string|nil
-- @param rightInsetFn function(width) -> number  Space the controls take at the row's right,
--   gap to the label included
-- @return table  { label, desc, hasDesc, Fit }
local function CreateRowText(row, labelText, description, rightInsetFn)
    local label = row:CreateFontString(nil, "OVERLAY")
    SetSafeFont(label, Def.FontPath, Def.LabelSize, nil)
    label:SetJustifyH("LEFT")
    label:SetJustifyV("TOP")
    SetTextColor(label, Def.TextColorLabel)
    label:SetText(labelText or "")
    label:SetWordWrap(true)
    if label.SetMaxLines then label:SetMaxLines(Def.RowLabelMaxLines) end

    local desc, hasDesc = CreateRowDesc(row, description)
    desc:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -Def.RowDescGap)

    -- Until the row has a width: one line, centred (or the pair centred around the middle).
    if hasDesc then
        label:SetPoint("BOTTOMLEFT", row, "LEFT", 0, Def.RowDescGap / 2)
    else
        label:SetPoint("LEFT", row, "LEFT", 0, 0)
    end

    row:SetHeight(EstimatedRowHeight(hasDesc))
    row._rowPadded = true
    row._desc = desc
    row._rowLabel = label   -- AttachChangedMarker places its dot and reset arrow from it

    local lastW = -1
    local function Fit(force)
        local w = row:GetWidth() or 0
        if w <= 0 then return end
        if not force and math.abs(w - lastW) < 0.5 then return end
        lastW = w
        -- An explicit width (rather than a right anchor) makes the wrapped height readable now.
        local textW = math.max(1, w - (rightInsetFn and rightInsetFn(w) or 0))
        label:SetWidth(textW)
        desc:SetWidth(textW)
        local h, blockH = addon.SettingsRowHeight(label:GetStringHeight(),
            hasDesc and desc:GetStringHeight() or 0, RowHeightMetrics())
        label:ClearAllPoints()
        label:SetPoint("TOPLEFT", row, "LEFT", 0, blockH / 2)
        -- SetHeight fires OnSizeChanged again with the same width; lastW stops that here.
        if math.abs((row:GetHeight() or 0) - h) > 0.5 then
            row:SetHeight(h)
            if row.onHeightChanged then row.onHeightChanged() end
        end
    end
    row:HookScript("OnSizeChanged", function() Fit(false) end)

    return { label = label, desc = desc, hasDesc = hasDesc, Fit = Fit }
end

--- The changed-from-default marker on a settings row (row._rowLabel, set by CreateRowText and the
--- font row). A small accent dot sits in the left gutter, centred on the label's first line,
--- inside the card padding, so it never moves the label. While a changed row is hovered (and not
--- disabled), a small reset arrow shows just right of the label's text; clicking it runs onReset.
--- The caller decides what is changed and calls marker.SetChanged after every refresh.
--- @param row Frame
--- @param onReset function
--- @param isDisabled function|nil
--- @return table|nil  { SetChanged(changed), IsChanged() }; nil when the row has no label
local function AttachChangedMarker(row, onReset, isDisabled)
    local label = row and row._rowLabel
    if not label then return nil end
    if row._changedMarker then return row._changedMarker end

    local dot = MakeDot(row, Def.ChangedDotSize, "OVERLAY")
    dot:Hide()

    local reset = CreateFrame("Button", nil, row)
    reset:SetSize(Def.ChangedResetSize, Def.ChangedResetSize)
    reset:SetFrameLevel(row:GetFrameLevel() + 10)
    reset:Hide()
    local vis = CreatePressVisual(reset)
    AttachPress(reset, vis)
    local icon = vis:CreateTexture(nil, "OVERLAY")
    icon:SetAllPoints(vis)
    icon:SetTexture("Interface\\Buttons\\UI-RefreshButton")
    if icon.SetDesaturated then icon:SetDesaturated(true) end   -- so the muted and hover tints read true

    local changed = false
    local function disabled() return isDisabled and isDisabled() == true end
    local function tintIcon(hot)
        local c = hot and Def.TextColorHighlight or Def.TextColorMuted
        icon:SetVertexColor(c[1], c[2], c[3], 1)
    end

    -- Read the label each time: the dashboard text size and the row's width move it.
    local function place()
        local midY = -(Def.LabelSize * Def.LineHeightFactor) / 2
        dot:SetSize(Def.ChangedDotSize, Def.ChangedDotSize)
        dot:ClearAllPoints()
        dot:SetPoint("CENTER", label, "TOPLEFT", -Def.ChangedDotX, midY)
        local ac = Def.AccentColor
        dot:SetVertexColor(ac[1], ac[2], ac[3], 1)
        local textW = label:GetStringWidth() or 0
        local boxW = label:GetWidth() or 0
        if boxW > 0 then
            -- The arrow and its gap must fit in the space right of the label box (the row's gap
            -- to its controls); a label that fills its box gives the arrow its last few px.
            local room = row._rowLabelGap or Def.RowControlGap
            local over = math.max(0, Def.ChangedResetSize + Def.ChangedResetGap - room)
            local maxX = math.max(0, boxW - over)
            if textW > maxX then textW = maxX end
        end
        reset:ClearAllPoints()
        reset:SetPoint("LEFT", label, "TOPLEFT", math.ceil(textW) + Def.ChangedResetGap, midY)
    end

    local function showReset()
        if not changed or disabled() then return end
        if row.IsMouseOver and not row:IsMouseOver() then return end   -- a child reaching outside the row
        place()
        tintIcon(false)
        reset:Show()
    end

    -- Show on entering the row or any of its controls (the switch, the slider's thumb, the
    -- dropdown button, a segment, the swatch, a font row's parts), so moving straight onto a
    -- control shows the arrow too. Only frames that already take the mouse are hooked: giving
    -- a frame an OnEnter script makes the client hit-test it, so hooking a purely visual layer
    -- (a switch's track, a button's press visual) would let it swallow the control's clicks.
    local function takesMouse(frame)
        if frame.IsMouseEnabled and frame:IsMouseEnabled() then return true end
        if frame.IsMouseMotionEnabled and frame:IsMouseMotionEnabled() then return true end
        return false
    end
    local function hookEnter(frame)
        if frame == reset or not frame.HookScript then return end
        if takesMouse(frame) then frame:HookScript("OnEnter", showReset) end
        if frame.GetChildren then
            for _, child in ipairs({ frame:GetChildren() }) do hookEnter(child) end
        end
    end
    hookEnter(row)
    -- The row's OnLeave also fires when the cursor moves onto one of its controls, so the arrow
    -- hides only once the cursor has left the whole row (checked while the arrow shows).
    reset:SetScript("OnUpdate", function(self)
        if not row:IsMouseOver() then self:Hide() end
    end)
    reset:SetScript("OnEnter", function(self)
        tintIcon(true)
        -- Entering a child counts as leaving the row: keep the row's hover band lit.
        if row._rowHover then row._rowHover:Show() end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText((L and L["DASH_RESET_TO_DEFAULT"]) or "Reset to default", 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    reset:SetScript("OnLeave", function()
        tintIcon(false)
        GameTooltip:Hide()
        if row._rowHover and not row:IsMouseOver() then row._rowHover:Hide() end
    end)
    reset:SetScript("OnClick", function()
        if not changed or disabled() then return end
        GameTooltip:Hide()
        if onReset then onReset() end
    end)

    local marker = {}
    --- @param isChanged boolean
    function marker.SetChanged(isChanged)
        changed = isChanged and true or false
        dot:SetShown(changed)
        if changed then
            place()
            if reset:IsShown() and disabled() then reset:Hide() end
        else
            reset:Hide()
        end
    end
    function marker.IsChanged() return changed end
    row._changedMarker = marker
    return marker
end
_G.OptionsWidgets_AttachChangedMarker = AttachChangedMarker

-- A switch pill: a rounded TrackOff track, a rounded TrackOn fill that grows (and fades in)
-- from the left as it turns on, and a round white thumb. pill:SetPosition(t) paints it at t
-- (0 off, 1 on) and picks up the live Def colours each time. pill:SetOn(on, animate) slides
-- there over Def.MotionFast when animate is set (a player click), else snaps; the same value
-- again mid-slide lets the slide finish (TweenPlan). The visible parts sit on pill.body,
-- anchored to the pill's centre, so AttachPress(button, pill.body) scales it in place.
-- @param parent Frame
-- @param frameLevel number|nil  Set before the parts are built, so they stack above it
-- @return Frame pill  Sized Def.SwitchWidth x Def.SwitchHeight; the caller anchors it
local function CreatePill(parent, frameLevel)
    local w, h, inset = Def.SwitchWidth, Def.SwitchHeight, Def.SwitchInset
    local thumbSize = h - 2 * inset
    local travel = w - 2 * inset - thumbSize

    local pill = CreateFrame("Frame", nil, parent)
    pill:SetSize(w, h)
    if frameLevel then pill:SetFrameLevel(frameLevel) end
    local body = CreatePressVisual(pill)
    pill.body = body
    local paintTrack = PaintRounded(body, h / 2, "BACKGROUND")

    local fill = CreateFrame("Frame", nil, body)
    fill:SetPoint("TOPLEFT", body, "TOPLEFT", 0, 0)
    fill:SetPoint("BOTTOMLEFT", body, "BOTTOMLEFT", 0, 0)
    fill:SetWidth(h)
    fill:SetFrameLevel(body:GetFrameLevel() + 1)
    local paintFill = PaintRounded(fill, h / 2, "BACKGROUND")

    local thumbHost = CreateFrame("Frame", nil, body)
    thumbHost:SetAllPoints(body)
    thumbHost:SetFrameLevel(body:GetFrameLevel() + 2)
    local thumb = MakeDot(thumbHost, thumbSize, "OVERLAY")

    local pos = 0
    function pill:SetPosition(t)
        pos = t
        PaintToken(paintTrack, Def.TrackOff)
        PaintToken(paintFill, Def.TrackOn)
        local tc = Def.ThumbColor
        thumb:SetVertexColor(tc[1], tc[2], tc[3], tc[4] or 1)
        fill:SetWidth(h + t * (w - h))
        fill:SetAlpha(t)
        thumb:ClearAllPoints()
        thumb:SetPoint("CENTER", body, "LEFT", inset + thumbSize / 2 + t * travel, 0)
    end

    local tweenTo   -- the slide's target while one runs
    function pill:SetOn(on, animate)
        local target = on and 1 or 0
        local dur = Def.MotionFast or 0
        local plan = TweenPlan(animate, pos, target, tweenTo, dur > 0 and pill:IsVisible())
        if plan == "finish" then return end
        if plan == "snap" then
            StopTween(pill)
            tweenTo = nil
            pill:SetPosition(target)
            return
        end
        -- Start from where the thumb is now, so a slide reversed mid-way carries on smoothly.
        local from = pos
        tweenTo = target
        StartTween(pill, dur, function(e) pill:SetPosition(Lerp(from, target, e)) end,
            function() tweenTo = nil end)
    end

    function pill:IsAnimating() return tweenTo ~= nil end

    pill:SetPosition(0)
    return pill
end
addon.OptionsWidgets_CreatePill = CreatePill

function _G.OptionsWidgets_CreateToggleSwitch(parent, labelText, description, get, set, disabledFn, tooltip, shiftClickFn)
    local row = CreateFrame("Frame", nil, parent)
    local searchText = (labelText or "") .. " " .. (description or "")
    row.searchText = searchText:lower()

    local track = CreatePill(row)
    track:SetPoint("RIGHT", row, "RIGHT", 0, 0)

    local text = CreateRowText(row, labelText, description, function()
        return Def.SwitchWidth + Def.RowControlGap
    end)
    local label, desc = text.label, text.desc

    local btn = CreateFrame("Button", nil, row)
    btn:SetAllPoints(track)

    local function isDisabled()
        return disabledFn and disabledFn() == true
    end

    local function applyDisabledVisuals()
        local alpha = isDisabled() and 0.45 or 1
        label:SetAlpha(alpha)
        desc:SetAlpha(alpha)
        track:SetAlpha(alpha)
    end

    -- Set by a click and consumed by the next paint, so only the player's own change slides;
    -- a Refresh from outside (another row, a profile switch) snaps. SetPosition repaints from
    -- Def.TrackOn every frame, so a colour change made inside set() still shows.
    local animateNext
    local function paint()
        local animate = animateNext
        animateNext = nil
        track:SetOn(get() and true or false, animate)
    end

    btn:SetScript("OnClick", function()
        if IsShiftKeyDown() and shiftClickFn then shiftClickFn(); return end
        if isDisabled() then return end
        if track:IsAnimating() then return end  -- Debounce: ignore clicks during animation (prevents double-click reverting)
        animateNext = true
        set(not get())
        paint()   -- a Refresh inside set() may already have started the slide; this lets it run
    end)
    AttachPress(btn, track.body, isDisabled)

    function row:Refresh()
        paint()
        applyDisabledVisuals()
        text.Fit(true)
    end

    row:Refresh()
    ApplyRowHoverHighlight(row)
    if shiftClickFn then
        -- btn only covers the track/pill; hook the row so shift-clicking the label fires too.
        row:HookScript("OnMouseUp", function(_, button)
            if button == "LeftButton" and IsShiftKeyDown() then shiftClickFn() end
        end)
    end
    local effectiveTooltip = JoinTooltip(description, tooltip)
    if shiftClickFn then
        local hint = "Shift-click to preview."
        effectiveTooltip = (effectiveTooltip ~= "" and (effectiveTooltip .. "\n\n") or "") .. hint
    end
    ApplyOptionTooltip(row, effectiveTooltip)
    return row
end

-- Create a flat action button: a rounded InputBg fill with no border, lighter under the cursor.
-- @param parent table Parent frame
-- @param labelText string Button label
-- @param onClick function Callback on click
-- @param opts table|nil Optional; opts.width, opts.height (default 100x22)
-- @return table Button frame (caller sets position)
function _G.OptionsWidgets_CreateButton(parent, labelText, onClick, opts)
    opts = opts or {}
    local width = opts.width or 100
    local height = opts.height or 22

    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(width, height)
    -- The fill and label sit on a centred visual frame, so a press scales them in place.
    local vis = CreatePressVisual(btn)
    btn._visual = vis

    local paintBg = PaintRounded(vis, Def.ControlRadius, "BACKGROUND")
    PaintToken(paintBg, Def.InputBg)

    local lbl = vis:CreateFontString(nil, "OVERLAY")
    SetSafeFont(lbl, Def.FontPath, Def.LabelSize, nil)
    SetTextColor(lbl, Def.TextColorLabel)
    lbl:SetText(labelText or "")
    lbl:SetPoint("CENTER", vis, "CENTER", 0, 0)
    btn._label = lbl
    function btn:SetLabel(text)
        lbl:SetText(text or "")
    end

    btn:SetScript("OnClick", function()
        if onClick then onClick() end
    end)
    btn:SetScript("OnEnter", function()
        PaintToken(paintBg, Def.InputBgHover)
        SetTextColor(lbl, Def.TextColorHighlight)
    end)
    btn:SetScript("OnLeave", function()
        PaintToken(paintBg, Def.InputBg)
        SetTextColor(lbl, Def.TextColorLabel)
    end)
    AttachPress(btn, vis)

    ApplyOptionTooltip(btn, opts.tooltip)
    return btn
end

-- Slider: a thin rounded track with the accent fill up to a white round thumb, and the value
-- (an editable box) at the right. The track width follows the row: 36% of it, clamped.
local SLIDER_TRACK_SHARE = 0.36

local function SliderTrackWidth(rowWidth)
    local w = math.floor((rowWidth or 0) * SLIDER_TRACK_SHARE)
    return math.max(Def.SliderTrackMin, math.min(Def.SliderTrackMax, w))
end

function _G.OptionsWidgets_CreateSlider(parent, labelText, description, get, set, minVal, maxVal, disabledFn, step, tooltip)
    -- step: snapping increment (default 1 = integer). Use e.g. 0.1 for one decimal place.
    step = step or 1
    local decimals = 0
    if step < 1 then
        -- Determine display decimal places from step (e.g. 0.1 → 1, 0.05 → 2)
        local s = tostring(step)
        local dot = s:find("%.")
        decimals = dot and (#s - dot) or 0
    end
    local function snapToStep(v)
        if step <= 0 then return v end
        return math.floor(v / step + 0.5) * step
    end
    local function formatValue(v)
        if decimals > 0 then
            return string.format("%." .. decimals .. "f", v)
        end
        return tostring((v >= 0) and math.floor(v + 0.5) or -math.floor(-v + 0.5))
    end
    local row = CreateFrame("Frame", nil, parent)
    local searchText = (labelText or "") .. " " .. (description or "")
    row.searchText = searchText:lower()

    local thumbW = Def.SliderThumbSize
    local trackH = Def.SliderTrackH

    -- Value box at the right edge, the track just left of it.
    local editWrap = CreateFrame("Frame", nil, row)
    editWrap:SetSize(Def.SliderValueW, Def.SliderValueH)
    editWrap:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    local paintEditBg, paintEditRing = PaintRounded(editWrap, Def.ControlRadius, "BACKGROUND", true)
    PaintToken(paintEditBg, Def.InputBg)

    local trackWidth = Def.SliderTrackMax
    local track = CreateFrame("Frame", nil, row)
    track:SetSize(trackWidth, trackH)
    track:SetPoint("RIGHT", editWrap, "LEFT", -Def.SliderValueGap, 0)
    local paintTrack = PaintRounded(track, trackH / 2, "BACKGROUND")
    PaintToken(paintTrack, Def.TrackOff)
    local fillHost = CreateFrame("Frame", nil, track)
    fillHost:SetPoint("TOPLEFT", track, "TOPLEFT", 0, 0)
    fillHost:SetPoint("BOTTOMLEFT", track, "BOTTOMLEFT", 0, 0)
    fillHost:SetWidth(thumbW / 2)
    local paintFill = PaintRounded(fillHost, trackH / 2, "ARTWORK")
    PaintToken(paintFill, Def.TrackOn)

    local thumb = CreateFrame("Button", nil, track)
    thumb:SetSize(thumbW, thumbW)
    thumb:SetPoint("CENTER", track, "LEFT", 0, 0)
    thumb:SetFrameLevel(fillHost:GetFrameLevel() + 2)
    -- The drawn dot grows about the thumb's centre on hover and drag; the thumb (its click
    -- area) keeps its size.
    local thumbTex = MakeDot(thumb, thumbW, "ARTWORK")
    thumbTex:ClearAllPoints()
    thumbTex:SetPoint("CENTER", thumb, "CENTER", 0, 0)
    thumbTex:SetSize(thumbW, thumbW)
    local tc0 = Def.ThumbColor
    thumbTex:SetVertexColor(tc0[1], tc0[2], tc0[3], tc0[4] or 1)

    local text = CreateRowText(row, labelText, description, function(w)
        return SliderTrackWidth(w) + Def.SliderValueGap + Def.SliderValueW + Def.RowControlGap
    end)
    local label, desc = text.label, text.desc

    -- Pre-declare so edit scripts and drag handler can reference it before the body is assigned.
    local updateFromValue
    local animateNext   -- set around a typed commit's set(), consumed by the next Refresh

    local edit = CreateFrame("EditBox", nil, editWrap)
    edit:SetPoint("TOPLEFT", editWrap, "TOPLEFT", 4, 0)
    edit:SetPoint("BOTTOMRIGHT", editWrap, "BOTTOMRIGHT", -4, 0)
    edit:SetMaxLetters(7)   -- allow e.g. "-200" (4 chars) plus some headroom
    -- Do NOT use SetNumeric(true) — it blocks negative numbers.
    -- We validate manually in OnEnterPressed / OnEditFocusLost.
    edit:SetAutoFocus(false)
    if edit.SetJustifyH then edit:SetJustifyH("RIGHT") end
    SetSafeFont(edit, Def.FontPath, Def.LabelSize, nil)
    local tc = Def.TextColorLabel
    edit:SetTextColor(tc[1], tc[2], tc[3], tc[4] or 1)
    edit:SetScript("OnEscapePressed", function()
        updateFromValue(get())
        edit:ClearFocus()
    end)
    edit:SetScript("OnEditFocusGained", function()
        if disabledFn and disabledFn() == true then edit:ClearFocus(); return end
        -- Land any value tween first, so the box never changes under the player's typing.
        FinishTween(editWrap)
        PaintToken(paintEditRing, Def.FocusRing)
    end)
    edit:SetScript("OnEditFocusLost", function()
        paintEditRing(0, 0, 0, 0)
        if disabledFn and disabledFn() == true then return end
        local v = tonumber(edit:GetText())
        if v ~= nil then
            v = snapToStep(math.max(minVal, math.min(maxVal, v)))
            -- A set() that refreshes this row at once (the dashboard text size, say) paints
            -- through Refresh: the flag makes that paint ease too, and it is cleared after.
            animateNext = true
            set(v)
            animateNext = nil
            updateFromValue(v, true)   -- typed: the thumb and the number ease there
        else
            updateFromValue(get())
        end
    end)
    -- Enter commits through focus loss above. (It used to commit here as well, then again on
    -- the focus loss; reading the box mid-tween there would commit the wrong number.)
    edit:SetScript("OnEnterPressed", function()
        edit:ClearFocus()
    end)
    -- OnTextChanged intentionally omitted: would call set() on every keystroke,
    -- triggering heavy callbacks (refreshAllScaling → FullLayout) per character.

    local function valueToNorm(v)
        if maxVal <= minVal then return 0 end
        return (v - minVal) / (maxVal - minVal)
    end
    local function normToValue(n)
        return minVal + n * (maxVal - minVal)
    end

    local fillWidth = trackWidth
    local thumbTravel = fillWidth - thumbW
    local function recalcSliderMetrics()
        trackWidth = math.max(track:GetWidth() or Def.SliderTrackMax, 1)
        fillWidth = trackWidth
        thumbTravel = math.max(fillWidth - thumbW, 0)
    end
    local function updateResponsiveTrackWidth()
        local rowWidth = row:GetWidth() or 0
        if rowWidth <= 0 then return end
        local responsiveW = SliderTrackWidth(rowWidth)
        if math.abs((track:GetWidth() or 0) - responsiveW) >= 1 then
            track:SetWidth(responsiveW)
            recalcSliderMetrics()
        end
    end

    -- The value the thumb, fill and number show now; it differs from get() only mid-tween.
    local shownV
    local function paintValue(v)
        shownV = v
        local n = valueToNorm(v)
        local center = thumbW / 2 + n * thumbTravel
        thumb:ClearAllPoints()
        thumb:SetPoint("CENTER", track, "LEFT", center, 0)
        fillHost:SetWidth(center)   -- fill the track up to the thumb centre
        edit:SetText(formatValue(v))
    end

    -- Now assign the body — all closures above that captured the upvalue slot will see this.
    -- byPlayer: a typed value eases there over Def.MotionFast (the number follows the thumb);
    -- anything else snaps, unless it is the value a running tween already heads to (TweenPlan).
    -- A drag paints through dragTo below, so the number follows the thumb exactly.
    local valueTweenTo
    updateFromValue = function(v, byPlayer)
        v = math.max(minVal, math.min(maxVal, v))
        local dur = Def.MotionFast or 0
        local plan = TweenPlan(byPlayer, shownV, v, valueTweenTo, dur > 0 and editWrap:IsVisible())
        if plan == "finish" then return end
        if plan == "snap" then
            StopTween(editWrap)
            valueTweenTo = nil
            paintValue(v)
            return
        end
        local from = shownV
        valueTweenTo = v
        StartTween(editWrap, dur, function(e) paintValue(Lerp(from, v, e)) end,
            function() valueTweenTo = nil end)
    end
    local function dragTo(v)
        StopTween(editWrap)
        valueTweenTo = nil
        paintValue(math.max(minVal, math.min(maxVal, v)))
    end

    -- Active (hover/drag) feedback: the dot eases to Def.SliderThumbHoverScale over
    -- Def.MotionFast, and back. Hiding the thumb puts it straight back to rest.
    local activeCur, activeTarget = 0, 0
    local function applyThumbState(t)
        local w = SliderThumbSizeAt(thumbW, t)
        thumbTex:SetSize(w, w)
    end
    local function restThumb()
        StopTween(thumb)
        activeCur, activeTarget = 0, 0
        applyThumbState(0)
    end
    local function setThumbActive(on)
        if disabledFn and disabledFn() == true then on = false end
        local tgt = on and 1 or 0
        if tgt == activeTarget then return end
        activeTarget = tgt
        local from = activeCur
        StartTween(thumb, Def.MotionFast, function(e)
            activeCur = Lerp(from, tgt, e)
            applyThumbState(activeCur)
        end, nil, restThumb)
    end
    applyThumbState(0)

    local dragging = false
    local rowHovered = false
    -- A row hidden while hovered gets no OnLeave: start from rest when it shows again.
    thumb:HookScript("OnHide", function()
        rowHovered = false
        restThumb()
    end)
    local startNorm, startX
    thumb:SetScript("OnMouseDown", function(_, btn)
        if btn ~= "LeftButton" then return end
        if disabledFn and disabledFn() == true then return end
        dragging = true
        FinishTween(editWrap)   -- a typed value still easing in lands before the drag starts
        setThumbActive(true)
        startNorm = valueToNorm(get())
        local scale = track:GetEffectiveScale()
        startX = GetCursorPosition() / scale
        local dragFillWidth = fillWidth
        local lastCommittedSnapped = snapToStep(normToValue(startNorm))
        thumb:GetParent():SetScript("OnUpdate", function()
            if not IsMouseButtonDown("LeftButton") then
                thumb:GetParent():SetScript("OnUpdate", nil)
                dragging = false
                if not rowHovered then setThumbActive(false) end
                -- Commit final value on release so the DB is up-to-date.
                local finalV = snapToStep(math.max(minVal, math.min(maxVal, normToValue(startNorm))))
                if finalV ~= lastCommittedSnapped then
                    lastCommittedSnapped = finalV
                    set(finalV)
                end
                return
            end
            local x = GetCursorPosition() / scale
            local delta = (x - startX) / dragFillWidth
            local n = math.max(0, math.min(1, startNorm + delta))
            local v = normToValue(n)
            -- During drag, keep the visual responsive but defer the expensive set()
            -- path until release. Many sliders fan out into full module apply/layout
            -- work, which is too costly to run every drag tick.
            -- Update the visual LAST so the smooth position wins over any row:Refresh()
            -- the set() callback may trigger (which would otherwise snap the handle = lag).
            dragTo(v)
            startNorm = n
            startX = x
        end)
    end)

    local function applyDisabledVisuals()
        local dis = disabledFn and disabledFn() == true
        local alpha = dis and 0.35 or 1
        label:SetAlpha(alpha)
        desc:SetAlpha(alpha)
        track:SetAlpha(alpha)
        editWrap:SetAlpha(alpha)
        if dis then
            setThumbActive(false)
            edit:EnableMouse(false)
        else
            edit:EnableMouse(true)
        end
    end

    function row:Refresh()
        updateResponsiveTrackWidth()
        PaintToken(paintFill, Def.TrackOn)
        -- Don't reposition the handle from the DB mid-drag; the drag handler owns it. A typed
        -- commit sets animateNext, so a Refresh its set() causes eases rather than snaps.
        local animate = animateNext
        animateNext = nil
        if not dragging then updateFromValue(get(), animate) end
        applyDisabledVisuals()
        text.Fit(true)
    end

    -- HookScript, not SetScript: CreateRowText and the rounded fills hook this script too.
    row:HookScript("OnSizeChanged", function()
        updateResponsiveTrackWidth()
        if not dragging then updateFromValue(get()) end
    end)

    row:Refresh()
    ApplyRowHoverHighlight(row)
    local function onHoverEnter()
        rowHovered = true
        setThumbActive(true)
    end
    local function onHoverLeave()
        -- The handle is a mouse-enabled child, so moving onto it fires the row's OnLeave even
        -- though the cursor is still within the row. Stay active while over either.
        if row:IsMouseOver() or thumb:IsMouseOver() then return end
        rowHovered = false
        if not dragging then setThumbActive(false) end
    end
    row:HookScript("OnEnter", onHoverEnter)
    row:HookScript("OnLeave", onHoverLeave)
    thumb:HookScript("OnEnter", onHoverEnter)
    thumb:HookScript("OnLeave", onHoverLeave)
    local effectiveTooltip = JoinTooltip(description, tooltip)
    ApplyOptionTooltip(row, effectiveTooltip)
    return row
end

-- Rounded backdrop for section cards and dropdown popups (uses Blizzard edge file for modern look).
local SECTION_CARD_BACKDROP = {
    bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 16,
    edgeSize = 16,
    insets   = { left = 4, right = 4, top = 4, bottom = 4 },
}

-- Sentinel stored in DB for "use global font" per-element pickers (must match OptionsData FONT_USE_GLOBAL / Vista GLOBAL_SENTINEL).
local DROPDOWN_FONT_GLOBAL_SENTINEL = "__global__"

-- Monotonic counter for unique, stable dropdown ESC-catch frame names (was derived from tostring(row)).
local dropdownCatchCounter = 0

-- Dropdown popup layout.
local DROPDOWN_SEARCH_BOX_H = 36   -- height of the search box atop searchable lists
local DROPDOWN_ROW_H        = 22   -- list row height
local DROPDOWN_ROW_H_FONT   = 24   -- list row height when previewing fonts (taller)
local DROPDOWN_MAX_LIST_H   = 330  -- max popup list height before scrolling
-- Inset the row hover highlight so it floats inside the rounded popup instead of bleeding to the edges.
local DROPDOWN_HI_INSET_X   = 4
local DROPDOWN_HI_INSET_Y   = 1
-- Top/bottom breathing room inside the rounded popup so the first/last row clears the corners.
local DROPDOWN_LIST_PAD     = 5

-- Normalise dropdown option input (dense array of {name,value[,disabled]} or a name->value map)
-- into a dense array, alpha-sorted unless preserveOrder (the "__global__" sentinel sorts first).
local function NormalizeDropdownOptions(opts, preserveOrder)
    if type(opts) ~= "table" then return {} end
    local out = {}
    for k, v in pairs(opts) do
        if type(k) == "number" and type(v) == "table" then
            -- Expected shape: { name, value [, disabled] } — [3] truthy = not selectable (grey label, click closes list only).
            out[#out + 1] = v
        elseif type(k) == "string" then
            -- Map shape: name -> value
            out[#out + 1] = { k, v }
        end
    end
    if not preserveOrder then
        table.sort(out, function(a, b)
            local aVal = a and a[2]
            local bVal = b and b[2]
            if aVal == "__global__" then return true end
            if bVal == "__global__" then return false end
            return tostring(a and a[1] or "") < tostring(b and b[1] or "")
        end)
    end
    return out
end

-- Segmented buttons for a short static choice: an inset SegTrackBg track (radius ControlRadius,
-- SegTrackPad padding) holding one segment per option, each sized to its label. The selected
-- segment is a raised SegSelectedBg fill with a SegSelectedRing hairline; the others are muted
-- text. Each segment's tooltip names its full label. Disabled dims the whole control to
-- SegDisabledAlpha and ignores clicks and hover.
-- @param parent Frame
-- @param opts table  Normalised options ({ name, value } in display order)
-- @param onPick function(value, name)  Called on a click while enabled
-- @param isDisabled function() -> boolean
-- @return Frame  The track, with :SetValue(v), :Paint(), :Fits(available) -> fits, width
local function CreateSegmentedControl(parent, opts, onPick, isDisabled)
    local track = CreateFrame("Frame", nil, parent)
    track:SetHeight(Def.ControlHeight)
    -- What shows (the track fill, the pill and the labels) sits on body, anchored to the track's
    -- centre, so a press scales the whole control in place. The segment buttons stay on the
    -- track, so their click areas never move. Everything on body is placed from body's LEFT.
    local body = CreatePressVisual(track)
    local paintTrack = PaintRounded(body, Def.ControlRadius, "BACKGROUND")
    local segs = {}
    local value

    -- One raised pill marks the selection. It sits under the segments' labels and slides to the
    -- picked segment on a click; any other value change (Refresh, profile switch) snaps it.
    local pill = CreateFrame("Frame", nil, body)
    pill:SetFrameLevel(body:GetFrameLevel() + 1)    -- above the track's fill, below the labels
    local labels = CreateFrame("Frame", nil, body)  -- holds the segment labels, above the pill
    labels:SetAllPoints(body)
    labels:SetFrameLevel(body:GetFrameLevel() + 2)
    local paintPill, paintPillRing = PaintRounded(pill, Def.SegRadius, "BACKGROUND", true)
    local slide          -- { fromX, fromW, fromSeg, toSeg, t, e, curX, curW } while sliding
    local animateNext    -- set by a click, consumed by the next SetValue

    local function SelectedSeg()
        for _, sg in ipairs(segs) do
            if sg.value == value then return sg end
        end
    end

    local function SegX(sg)
        return sg._x or 0
    end

    local function PlacePill(x, w)
        pill:ClearAllPoints()
        pill:SetPoint("LEFT", body, "LEFT", x, 0)
        pill:SetSize(math.max(1, w), Def.ControlHeight - 2 * Def.SegTrackPad)
    end

    local function LerpColor(c1, c2, t)
        return { Lerp(c1[1], c2[1], t), Lerp(c1[2], c2[2], t), Lerp(c1[3], c2[3], t) }
    end

    local function TextColorFor(sg, dis)
        if sg.value == value then return Def.SegTextSelected end
        if sg.hovered and not dis then return Def.TextColorLabel end
        return Def.TextColorMuted
    end

    function track:Paint()
        local dis = isDisabled()
        PaintToken(paintTrack, Def.SegTrackBg)
        local sel = SelectedSeg()
        if sel then
            PaintToken(paintPill, Def.SegSelectedBg)
            PaintToken(paintPillRing, Def.SegSelectedRing)
            pill:Show()
            if not slide then PlacePill(SegX(sel), sel:GetWidth()) end
        else
            pill:Hide()
        end
        for _, sg in ipairs(segs) do
            local c = TextColorFor(sg, dis)
            if slide and (sg == slide.fromSeg or sg == slide.toSeg) then
                -- Mid-slide, the old label fades down while the new one fades up.
                local e = slide.e or 0
                if sg == slide.toSeg then c = LerpColor(Def.TextColorMuted, Def.SegTextSelected, e)
                else c = LerpColor(Def.SegTextSelected, Def.TextColorMuted, e) end
            end
            SetTextColor(sg.text, c)
        end
        track:SetAlpha(dis and Def.SegDisabledAlpha or 1)
    end

    local function StopSlide()
        slide = nil
        pill:SetScript("OnUpdate", nil)
    end

    pill:SetScript("OnHide", StopSlide)

    function track:SetValue(v)
        local fromSeg = SelectedSeg()
        local animate = animateNext
        animateNext = nil
        value = v
        local toSeg = SelectedSeg()
        local dur = Def.SegSlideDuration or 0
        if fromSeg == toSeg and slide then
            -- Same value again (a refresh during the slide): let the slide finish.
            self:Paint()
            return
        end
        if animate and fromSeg and toSeg and fromSeg ~= toSeg and dur > 0
            and pill:IsVisible() and toSeg:GetWidth() > 0 then
            -- Start from where the pill is now, so a click mid-slide carries on smoothly.
            local fromX = slide and slide.curX or SegX(fromSeg)
            local fromW = slide and slide.curW or fromSeg:GetWidth()
            slide = { fromX = fromX, fromW = fromW, fromSeg = fromSeg, toSeg = toSeg, t = 0, e = 0 }
            pill:SetScript("OnUpdate", function(_, elapsed)
                local s = slide
                if not s then return end
                s.t = s.t + (elapsed or 0)
                local p = math.min(1, s.t / dur)
                s.e = easeOut(p)
                s.curX = Lerp(s.fromX, SegX(s.toSeg), s.e)
                s.curW = Lerp(s.fromW, s.toSeg:GetWidth(), s.e)
                PlacePill(s.curX, s.curW)
                track:Paint()
                if p >= 1 then
                    StopSlide()
                    track:Paint()
                end
            end)
        else
            StopSlide()
        end
        self:Paint()
    end

    for i, opt in ipairs(opts) do
        local sg = CreateFrame("Button", nil, track)
        sg.value, sg.label = opt[2], tostring(opt[1] or "")
        sg:SetFrameLevel(labels:GetFrameLevel() + 1)
        local text = labels:CreateFontString(nil, "OVERLAY")
        SetSafeFont(text, Def.FontPath, Def.LabelSize, nil)
        if text.SetWordWrap then text:SetWordWrap(false) end
        text:SetPoint("CENTER", body, "CENTER", 0, 0)   -- placed over its segment by Fits
        text:SetText(sg.label)
        sg.text = text
        sg:SetScript("OnClick", function()
            if isDisabled() then return end
            animateNext = true
            onPick(sg.value, sg.label)
            animateNext = nil   -- the pick's SetValue has run; nothing else may animate
        end)
        sg:SetScript("OnEnter", function()
            sg.hovered = true
            track:Paint()
            GameTooltip:SetOwner(sg, "ANCHOR_TOP")
            GameTooltip:SetText(sg.label, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        sg:SetScript("OnLeave", function()
            sg.hovered = false
            track:Paint()
            GameTooltip:Hide()
        end)
        AttachPress(sg, body, isDisabled)
        segs[i] = sg
    end

    -- Measure the labels, place the segments, and size the track to them. The labels' widths
    -- follow the dashboard font, so this runs on every layout pass rather than once.
    function track:Fits(available)
        local widths = {}
        local unmeasured = false
        for i, sg in ipairs(segs) do
            widths[i] = sg.text:GetStringWidth() or 0
            if widths[i] <= 0 then unmeasured = true end
        end
        local fits, natural = addon.SegmentedFits(widths, available,
            { segPadX = Def.SegPadX, trackPad = Def.SegTrackPad, gap = Def.SegGap })
        -- A label that measures 0 has no real width yet (font not loaded): stay a dropdown.
        if unmeasured then fits = false end
        local x = Def.SegTrackPad
        for i, sg in ipairs(segs) do
            local w = math.ceil(widths[i]) + 2 * Def.SegPadX
            sg:SetSize(w, Def.ControlHeight - 2 * Def.SegTrackPad)
            sg:ClearAllPoints()
            sg:SetPoint("LEFT", track, "LEFT", x, 0)
            sg._x = x
            sg.text:ClearAllPoints()
            sg.text:SetPoint("CENTER", body, "LEFT", x + w / 2, 0)
            x = x + w + Def.SegGap
        end
        track:SetWidth(natural)
        body:SetSize(math.max(1, natural), Def.ControlHeight)   -- now, not on the next size event
        local sel = SelectedSeg()
        if sel and not slide then PlacePill(sel._x, sel:GetWidth()) end
        return fits, natural
    end

    track:Paint()
    return track
end

-- Custom dropdown: button + popup list (no UIDropDownMenuTemplate)
-- When searchable is true, adds an EditBox above the list to filter options by name (e.g. font dropdown).
-- resetButton: optional table { onClick, tooltip } — adds a small reset-arrow icon button to the left of the dropdown.
-- fontPreviewInList: when true, each list row (and closed button when a font path is selected) uses ResolveFontPath(value) for SetFont.
-- layout: optional table. { embedded = true } makes the dropdown a control inside a composite row
-- (the font row): no label, no description, no row hover; the button fills the returned frame,
-- which the caller sizes and anchors; description and tooltip become the button's own tooltip;
-- resetButton is ignored. { segmented = true } also builds segmented buttons for a static options
-- table and shows them in place of the button whenever they fit (see OptionsWidgets_CreateSegmented);
-- both can be set. Without layout, nothing changes.
function _G.OptionsWidgets_CreateCustomDropdown(parent, labelText, description, options, get, set, displayFn, searchable, disabledFn, tooltip, resetButton, fontPreviewInList, preserveOrder, layout)
    local embedded = type(layout) == "table" and layout.embedded == true
    local wantSeg = type(layout) == "table" and layout.segmented == true and type(options) == "table"
    if embedded then resetButton = nil end
    local labelFn = type(labelText) == "function" and labelText or nil
    local resolvedLabel = labelFn and labelFn() or labelText
    local row = CreateFrame("Frame", nil, parent)
    if embedded then row:SetHeight(Def.ControlHeight) end
    local searchText = (resolvedLabel or "") .. " " .. (description or "")
    row.searchText = searchText:lower()

    local DROPDOWN_BTN_WIDTH = 180
    local RESET_BTN_SIZE = 24
    local RESET_GAP = 6
    local rightInset = DROPDOWN_BTN_WIDTH + Def.RowControlGap
    if resetButton and resetButton.onClick then
        rightInset = rightInset + RESET_BTN_SIZE + RESET_GAP
    end

    local btn = CreateFrame("Button", nil, row)
    if embedded then
        btn:SetAllPoints(row)
    else
        btn:SetSize(DROPDOWN_BTN_WIDTH, Def.ControlHeight)
        btn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    end
    row.button = btn

    local resetBtn
    if resetButton and resetButton.onClick then
        resetBtn = CreateFrame("Button", nil, row)
        resetBtn:SetSize(RESET_BTN_SIZE, RESET_BTN_SIZE)
        resetBtn:SetPoint("RIGHT", btn, "LEFT", -RESET_GAP, 0)
        resetBtn:SetFrameLevel(row:GetFrameLevel() + 10)
        resetBtn:EnableMouse(true)
        resetBtn:SetScript("OnClick", function()
            resetButton.onClick()
        end)
        local resetIcon = resetBtn:CreateTexture(nil, "OVERLAY")
        resetIcon:SetAllPoints(resetBtn)
        resetIcon:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
        resetIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        local paintResetBg = PaintRounded(resetBtn, Def.ControlRadius, "BACKGROUND")
        PaintToken(paintResetBg, Def.InputBg)
        local resetTt = (resetButton.tooltip or (L and L["FOCUS_RESET_SPACING"])) or "Reset spacing"
        resetBtn:SetScript("OnEnter", function()
            PaintToken(paintResetBg, Def.InputBgHover)
            GameTooltip:SetOwner(resetBtn, "ANCHOR_RIGHT")
            GameTooltip:SetText(resetTt, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        resetBtn:SetScript("OnLeave", function()
            PaintToken(paintResetBg, Def.InputBg)
            GameTooltip:Hide()
        end)
    end

    -- An embedded dropdown has no label or description; label stays nil and is guarded below.
    -- Segmented buttons (layout.segmented), built further down; ChooseControl shows them or the
    -- button. Declared here so the row text's inset function can see them.
    local seg, segShown = nil, false
    local ChooseControl
    local function controlInset(w)
        if seg then ChooseControl(w) end
        if not segShown then return rightInset end
        local inset = seg:GetWidth() + Def.RowControlGap
        if resetBtn then inset = inset + RESET_BTN_SIZE + RESET_GAP end
        return inset
    end

    local label, descFs, rowText
    if not embedded then
        rowText = CreateRowText(row, resolvedLabel, description, controlInset)
        label, descFs = rowText.label, rowText.desc
    end

    -- Flat control: a rounded InputBg fill with no border, lighter under the cursor. The fill and
    -- text sit on a centred visual frame, so a press scales them in place (the button keeps
    -- its size; a disabled button, btn:Disable(), does not react).
    local btnVis = CreatePressVisual(btn)
    AttachPress(btn, btnVis)
    local paintBtnBg = PaintRounded(btnVis, Def.ControlRadius, "BACKGROUND")
    local btnBgAlpha = 1
    local btnHovered = false
    local function paintButton()
        PaintToken(paintBtnBg, btnHovered and Def.InputBgHover or Def.InputBg, btnBgAlpha)
    end
    paintButton()
    -- A disabled dropdown (btn:Disable() in applyDisabledVisuals) keeps its dimmed fill.
    btn:HookScript("OnEnter", function() btnHovered = btn:IsEnabled() and true or false; paintButton() end)
    btn:HookScript("OnLeave", function() btnHovered = false; paintButton() end)

    local btnText = btnVis:CreateFontString(nil, "OVERLAY")
    SetSafeFont(btnText, Def.FontPath, Def.LabelSize, nil)
    SetTextColor(btnText, Def.TextColorLabel)
    btnText:SetPoint("LEFT", btnVis, "LEFT", 10, 0)
    btnText:SetPoint("RIGHT", btnVis, "RIGHT", -24, 0)
    btnText:SetJustifyH("LEFT")
    if btnText.SetWordWrap then btnText:SetWordWrap(false) end

    local chevron = btnVis:CreateFontString(nil, "OVERLAY")
    SetSafeFont(chevron, Def.FontPath, Def.LabelSize, nil)
    SetTextColor(chevron, Def.TextColorFaint)
    chevron:SetText("v")
    chevron:SetPoint("RIGHT", btnVis, "RIGHT", -8, 0)

    local list = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    list:SetFrameStrata("TOOLTIP")
    list:Hide()
    list:SetSize(200, 1)
    list:SetBackdrop(SECTION_CARD_BACKDROP)
    list:SetBackdropColor(Def.SectionCardBg[1], Def.SectionCardBg[2], Def.SectionCardBg[3], Def.SectionCardBg[4])
    list:SetBackdropBorderColor(Def.SectionCardBorder[1], Def.SectionCardBorder[2], Def.SectionCardBorder[3], Def.SectionCardBorder[4])

    local searchEdit
    if searchable then
        searchEdit = CreateFrame("EditBox", nil, list)
        searchEdit:SetHeight(26)
        searchEdit:SetPoint("TOPLEFT", list, "TOPLEFT", 6, -6)
        searchEdit:SetPoint("TOPRIGHT", list, "TOPRIGHT", -6, 0)
        searchEdit:SetAutoFocus(false)
        SetSafeFont(searchEdit, Def.FontPath, Def.LabelSize, nil)
        searchEdit:SetTextInsets(8, 8, 0, 0)
        local tc = Def.TextColorLabel
        searchEdit:SetTextColor(tc[1], tc[2], tc[3], tc[4] or 1)
        local searchBg = searchEdit:CreateTexture(nil, "BACKGROUND")
        searchBg:SetAllPoints(searchEdit)
        searchBg:SetColorTexture(Def.InputBg[1], Def.InputBg[2], Def.InputBg[3], Def.InputBg[4])
        local ph = searchEdit:CreateFontString(nil, "OVERLAY")
        SetSafeFont(ph, Def.FontPath, Def.LabelSize, nil)
        SetTextColor(ph, Def.TextColorSection)
        ph:SetText(L["SEARCH_FONTS"])
        ph:SetPoint("LEFT", searchEdit, "LEFT", 8, 0)
        ph:SetJustifyH("LEFT")
        searchEdit.placeholder = ph
        searchEdit:SetScript("OnEditFocusGained", function() if ph then ph:Hide() end end)
        searchEdit:SetScript("OnEditFocusLost", function() if ph and searchEdit:GetText() == "" then ph:Show() end end)
    end

    local scrollFrame = CreateFrame("ScrollFrame", nil, list)
    if searchable then
        scrollFrame:SetPoint("TOPLEFT", searchEdit, "BOTTOMLEFT", 0, -4)
        scrollFrame:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", -4, 4)
    else
        -- Pad top/bottom so the first/last row (and its highlight) clears the rounded corners.
        scrollFrame:SetPoint("TOPLEFT", list, "TOPLEFT", 0, -DROPDOWN_LIST_PAD)
        scrollFrame:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", 0, DROPDOWN_LIST_PAD)
    end

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetWidth(1)
    scrollChild:SetHeight(1)

    -- Ensure the dropdown list scrolls internally and doesn't forward wheel events to the parent panel.
    scrollFrame:EnableMouseWheel(true)
    list:EnableMouseWheel(true)
    -- Row height for open list; updated in populate when fontPreviewInList (taller rows for glyph clearance).
    local listRowHeight = 22

    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        if not list:IsShown() then return end
        local step = listRowHeight * 3
        local cur = self:GetVerticalScroll() or 0
        local childH = (scrollChild and scrollChild:GetHeight()) or 0
        local frameH = self:GetHeight() or 0
        local maxScroll = math.max(0, childH - frameH)
        local new = math.max(0, math.min(cur - delta * step, maxScroll))
        self:SetVerticalScroll(new)
    end)
    -- Capture mouse wheel on the outer list too, so the options panel underneath doesn't scroll.
    list:SetScript("OnMouseWheel", function() end)

    -- Keep our own list of option buttons; GetNumChildren()/GetChildren() is unreliable.
    local optionButtons = {}

    dropdownCatchCounter = dropdownCatchCounter + 1
    local catch = CreateFrame("Button", "HorizonSuite_DropdownCatch" .. dropdownCatchCounter, UIParent)
    catch:SetFrameStrata("TOOLTIP")
    catch:SetAllPoints(UIParent)
    catch:Hide()

    -- Allow ESC to close an open dropdown.
    -- WoW's CloseSpecialWindows() hides frames listed in UISpecialFrames.
    catch.__horizonDropdownCatch = true
    if _G.UISpecialFrames then
        local n = catch:GetName()
        local exists = false
        for i = 1, #_G.UISpecialFrames do
            if _G.UISpecialFrames[i] == n then exists = true break end
        end
        if not exists then tinsert(_G.UISpecialFrames, n) end
    end

    local function closeList()
        if addon._OnDropdownClosed then addon._OnDropdownClosed(closeList) end
        if addon._DropdownCloseList then addon._DropdownCloseList[closeList] = nil end
        if searchable and searchEdit and searchEdit:HasFocus() then
            searchEdit:ClearFocus()
        end
        list:Hide()
        catch:Hide()
    end
    catch:SetScript("OnClick", closeList)
    catch:SetScript("OnHide", function()
        -- Keep list in sync if the catch is hidden via ESC.
        if list:IsShown() then
            if addon._OnDropdownClosed then addon._OnDropdownClosed(closeList) end
            list:Hide()
        end
    end)

    -- Must be declared before setValue (Lua 5.1: later `local function` is not visible to earlier closures).
    local function isDisabled()
        return disabledFn and disabledFn() == true
    end

    local function applyDisabledVisuals()
        local dis = isDisabled()
        if dis then
            btn:Disable()
            if label then SetTextColor(label, Def.TextColorSection) end
            if descFs then descFs:SetAlpha(0.45) end
            SetTextColor(btnText, Def.TextColorSection)
            chevron:SetAlpha(0.5)
            btnBgAlpha = 0.6
        else
            btn:Enable()
            if label then SetTextColor(label, Def.TextColorLabel) end
            if descFs then descFs:SetAlpha(1) end
            SetTextColor(btnText, Def.TextColorLabel)
            chevron:SetAlpha(1)
            btnBgAlpha = 1
        end
        paintButton()
        if seg then seg:Paint() end
    end

    local function applyBtnTextFontForValue(value)
        if not fontPreviewInList then return end
        if value == nil or value == "" or value == DROPDOWN_FONT_GLOBAL_SENTINEL then
            SetSafeFont(btnText, Def.FontPath, Def.LabelSize, nil)
        else
            local path = (addon.ResolveFontPath and addon.ResolveFontPath(value)) or value
            SetSafeFont(btnText, path, Def.LabelSize, nil)
        end
    end

    local function setValue(value, display)
        set(value)
        btnText:SetText(display or tostring(value))
        applyBtnTextFontForValue(value)
        if seg then seg:SetValue(value) end
        applyDisabledVisuals()
        closeList()
    end

    if wantSeg then
        seg = CreateSegmentedControl(row, NormalizeDropdownOptions(options, preserveOrder), setValue, isDisabled)
        seg:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        seg:Hide()
        -- Show the segments when they fit in Def.SegFitShare of the row's width (a row) or in the
        -- space the composite row offers (embedded: available is passed in), else the button.
        ChooseControl = function(w)
            local available = embedded and w or ((w or 0) * Def.SegFitShare)
            if not embedded and resetBtn then available = available - RESET_BTN_SIZE - RESET_GAP end
            local fits = seg:Fits(available)
            segShown = fits and true or false
            seg:SetShown(segShown)
            btn:SetShown(not segShown)
            if resetBtn then
                resetBtn:ClearAllPoints()
                resetBtn:SetPoint("RIGHT", segShown and seg or btn, "LEFT", -RESET_GAP, 0)
            end
            if segShown and list:IsShown() then closeList() end
            return segShown
        end
        -- For a composite row: the width the segments need within `available`, or nil when the
        -- button shows instead.
        function row:ChooseSegmented(available)
            if ChooseControl(available) then return seg:GetWidth() end
            return nil
        end
    end


    local SEARCH_BOX_HEIGHT = searchable and DROPDOWN_SEARCH_BOX_H or 0

    local function populate()
        list:SetParent(UIParent)
        list:ClearAllPoints()
        list:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -2)

        local fullOpts = NormalizeDropdownOptions((type(options) == "function" and options()) or options or {}, preserveOrder)
        local opts = fullOpts
        if searchable and searchEdit then
            local filterText = searchEdit:GetText()
            if type(filterText) == "string" and filterText ~= "" then
                local lower = filterText:lower()
                opts = {}
                for _, opt in ipairs(fullOpts) do
                    local name = opt and opt[1] or ""
                    if name:lower():find(lower, 1, true) then
                        opts[#opts + 1] = opt
                    end
                end
            end
        end

        local num = #opts

        local rowH = fontPreviewInList and DROPDOWN_ROW_H_FONT or DROPDOWN_ROW_H
        listRowHeight = rowH
        local maxHeight = DROPDOWN_MAX_LIST_H
        local totalHeight = num * rowH

        list:SetWidth(btn:GetWidth())
        local listVPad = searchable and 0 or (2 * DROPDOWN_LIST_PAD)
        list:SetHeight(SEARCH_BOX_HEIGHT + math.min(totalHeight, maxHeight) + listVPad)
        scrollChild:SetWidth(btn:GetWidth())
        scrollChild:SetHeight(math.max(totalHeight, 1))
        scrollFrame:SetVerticalScroll(0)

        if searchable and searchEdit then
            searchEdit:Show()
        end

        local lblColor = Def.TextColorLabel
        for i = 1, num do
            local b = optionButtons[i]
            if not b then
                b = CreateFrame("Button", nil, scrollChild)
                b:SetHeight(rowH)

                local tb = b:CreateFontString(nil, "OVERLAY")
                SetSafeFont(tb, Def.FontPath, Def.LabelSize, nil)
                tb:SetPoint("LEFT", b, "LEFT", 8, 0)
                tb:SetJustifyV("MIDDLE")
                tb:SetJustifyH("LEFT")
                b.text = tb

                local hi = b:CreateTexture(nil, "BACKGROUND")
                hi:SetPoint("TOPLEFT", b, "TOPLEFT", DROPDOWN_HI_INSET_X, -DROPDOWN_HI_INSET_Y)
                hi:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -DROPDOWN_HI_INSET_X, DROPDOWN_HI_INSET_Y)
                hi:SetColorTexture(1, 1, 1, 0.06)
                hi:Hide()
                b._dropdownHi = hi

                optionButtons[i] = b
            end
            b:SetHeight(rowH)
        end

        for i = 1, num do
            local opt = opts[i]
            local name = opt and opt[1]
            local value = opt and opt[2]
            local rowDisabled = opt and opt[3] == true
            local b = optionButtons[i]
            local hi = b._dropdownHi

            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -(i - 1) * rowH)
            b:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, -(i - 1) * rowH)

            if fontPreviewInList then
                if value == nil or value == "" or value == DROPDOWN_FONT_GLOBAL_SENTINEL then
                    SetSafeFont(b.text, Def.FontPath, Def.LabelSize, nil)
                else
                    local path = (addon.ResolveFontPath and addon.ResolveFontPath(value)) or value
                    SetSafeFont(b.text, path, Def.LabelSize, nil)
                end
                SetTextColor(b.text, rowDisabled and Def.TextColorSection or lblColor)
            elseif rowDisabled then
                SetTextColor(b.text, Def.TextColorSection)
            else
                SetTextColor(b.text, lblColor)
            end
            b.text:SetText(name)
            if rowDisabled then
                b:SetScript("OnEnter", function() end)
                b:SetScript("OnLeave", function() end)
                b:SetScript("OnClick", function()
                    closeList()
                end)
            else
                b:SetScript("OnEnter", function()
                    if hi then hi:Show() end
                end)
                b:SetScript("OnLeave", function()
                    if hi then hi:Hide() end
                end)
                b:SetScript("OnClick", function()
                    setValue(value, name)
                end)
            end
            b:Show()
        end

        for i = num + 1, #optionButtons do
            optionButtons[i]:Hide()
        end

    if addon._OnDropdownOpened then addon._OnDropdownOpened(closeList) end
    addon._DropdownCloseList = addon._DropdownCloseList or {}
    addon._DropdownCloseList[closeList] = true
    list:Show()
    catch:Show()
end

    if searchable and searchEdit then
        searchEdit:SetScript("OnTextChanged", function() populate() end)
    end

    btn:SetScript("OnClick", function()
        if isDisabled() then return end
        if list:IsShown() then
            closeList()
            return
        end
        if searchable and searchEdit then
            searchEdit:SetText("")
            if searchEdit.placeholder then searchEdit.placeholder:Show() end
        end
        populate()
        if searchable and searchEdit then
            searchEdit:SetFocus()
        end
    end)

    function row:Refresh()
        if labelFn and label then
            local newLabel = labelFn()
            if newLabel then label:SetText(newLabel) end
        end
        if rowText then rowText.Fit(true) end
        local val = get()
        if seg then seg:SetValue(val) end
        local opts = NormalizeDropdownOptions((type(options) == "function" and options()) or options or {}, preserveOrder)

        for _, opt in ipairs(opts) do
            local optVal = opt[2]
            if optVal == val then
                btnText:SetText(opt[1])
                applyBtnTextFontForValue(val)
                applyDisabledVisuals()
                return
            end
        end

        if searchable and addon.ResolveFontPath then
            local valResolved = addon.ResolveFontPath(val) or val
            for _, opt in ipairs(opts) do
                local optVal = opt[2]
                local optResolved = addon.ResolveFontPath(optVal) or optVal
                if optResolved == valResolved then
                    if displayFn then
                        btnText:SetText(displayFn(optVal))
                    else
                        btnText:SetText(opt[1])
                    end
                    applyBtnTextFontForValue(val)
                    applyDisabledVisuals()
                    return
                end
            end
        end

        if displayFn then
            btnText:SetText(displayFn(val))
        elseif val == nil or val == "" then
            btnText:SetText("")
        else
            btnText:SetText(tostring(val))
        end
        applyBtnTextFontForValue(val)
        applyDisabledVisuals()
    end

    row:Refresh()
    if embedded then
        -- The composite row owns the hover and the row tooltip; the button names what it sets.
        ApplyOptionTooltip(btn, JoinTooltip(description, tooltip))
        return row
    end
    ApplyRowHoverHighlight(row)
    local effectiveTooltip = JoinTooltip(description, tooltip)
    ApplyOptionTooltip(row, effectiveTooltip)
    return row
end

-- A short static choice as segmented buttons (addon.SegmentedEligible decides which rows qualify).
-- The row is a dropdown row that also carries the segments: whenever its width changes it shows the
-- segments if they fit in Def.SegFitShare of the row, else the dropdown button, so a long locale or
-- a narrow window falls back on its own. Get, set, Refresh, disabled visuals and the row tooltip are
-- the dropdown's; each segment adds a tooltip with its full label.
-- @param layout table|nil  As for the dropdown ({ embedded = true } for a composite row, which
--   then calls row:ChooseSegmented(available) during its layout)
-- @return table  The row
function _G.OptionsWidgets_CreateSegmented(parent, labelText, description, options, get, set, displayFn, disabledFn, tooltip, resetButton, preserveOrder, layout)
    local lay = { segmented = true }
    if type(layout) == "table" then for k, v in pairs(layout) do lay[k] = v end end
    return _G.OptionsWidgets_CreateCustomDropdown(parent, labelText, description, options, get, set, displayFn,
        false, disabledFn, tooltip, resetButton, false, preserveOrder, lay)
end

-- ---------------------------------------------------------------------------
-- Font row controls. The geometry lives in addon.FONT_ROW_METRICS and addon.FontRowLayout
-- (OptionsHelpers.lua), so the logic tests can check it without frames. OptionsHelpers loads
-- after this file, so they are read when a row is built, never at load.
-- ---------------------------------------------------------------------------

-- Compact size stepper: [-] value [+]. Typed values and steps snap to `step` and clamp to
-- min/max through addon.FontRowStepSize. Returns a frame (caller anchors it) with Refresh.
-- @param parent table
-- @param get function  Returns the current size
-- @param set function  Receives the new size
-- @param minVal number
-- @param maxVal number
-- @param step number|nil  Default 1
-- @param disabledFn function|nil
-- @param tooltip string|function|nil  Hover text for the buttons and the value
-- @return table
function _G.OptionsWidgets_CreateSizeStepper(parent, get, set, minVal, maxVal, step, disabledFn, tooltip)
    local M = addon.FONT_ROW_METRICS
    minVal = tonumber(minVal) or 0
    maxVal = tonumber(maxVal) or 100
    step = tonumber(step) or 1
    if step <= 0 then step = 1 end
    local BTN_W, GAP = 22, 2
    local H = M.controlH

    local function stepValue(v, delta, fallback)
        return addon.FontRowStepSize(v, delta, minVal, maxVal, step, fallback)
    end
    local function formatValue(v)
        return addon.FontRowFormatSize(tonumber(v) or minVal, step)
    end

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(M.stepperW, H)
    -- One flat rounded control holding [-] value [+]; a ring shows while the value has focus.
    local paintBg, paintRing = PaintRounded(frame, Def.ControlRadius, "BACKGROUND", true)
    PaintToken(paintBg, Def.InputBg)

    local function isDisabled()
        return disabledFn and disabledFn() == true
    end

    local function makeButton(text)
        local b = CreateFrame("Button", nil, frame)
        b:SetSize(BTN_W, H)
        -- The glyph sits on a centred visual frame, so a press scales it in place.
        local vis = CreatePressVisual(b)
        AttachPress(b, vis, isDisabled)
        local fs = vis:CreateFontString(nil, "OVERLAY")
        SetSafeFont(fs, Def.FontPath, Def.LabelSize, nil)
        SetTextColor(fs, Def.TextColorMuted)
        fs:SetText(text)
        fs:SetPoint("CENTER", vis, "CENTER", 0, 0)
        b:SetScript("OnEnter", function()
            if b:IsEnabled() then SetTextColor(fs, Def.TextColorLabel) end
        end)
        b:SetScript("OnLeave", function() SetTextColor(fs, Def.TextColorMuted) end)
        return b
    end
    local minus = makeButton("-")
    minus:SetPoint("LEFT", frame, "LEFT", 0, 0)
    local plus = makeButton("+")
    plus:SetPoint("RIGHT", frame, "RIGHT", 0, 0)

    local editWrap = CreateFrame("Frame", nil, frame)
    editWrap:SetPoint("TOPLEFT", minus, "TOPRIGHT", GAP, 0)
    editWrap:SetPoint("BOTTOMRIGHT", plus, "BOTTOMLEFT", -GAP, 0)
    local function setEditBorderColor(c)
        if c then PaintToken(paintRing, c) else paintRing(0, 0, 0, 0) end
    end

    local edit = CreateFrame("EditBox", nil, editWrap)
    edit:SetPoint("TOPLEFT", editWrap, "TOPLEFT", 2, 0)
    edit:SetPoint("BOTTOMRIGHT", editWrap, "BOTTOMRIGHT", -2, 0)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(6)
    edit:SetJustifyH("CENTER")
    SetSafeFont(edit, Def.FontPath, Def.LabelSize, nil)
    local tc = Def.TextColorLabel
    edit:SetTextColor(tc[1], tc[2], tc[3], tc[4] or 1)

    local function show(v)
        edit:SetText(formatValue(v))
    end
    local function commit(v)
        if v ~= tonumber(get()) then set(v) end
        show(v)
    end
    -- Save typed text only when the player changed it: text that is not a number, or that still
    -- shows the saved value (focus in and out, Escape), puts the saved value back untouched, so
    -- an off-grid or fractional saved value is never re-snapped.
    local reverting = false
    local function applyTyped()
        local cur = get()
        if reverting or isDisabled() then
            show(cur)
            return
        end
        local v = addon.FontRowTypedSize(edit:GetText(), cur, minVal, maxVal, step)
        if v ~= nil then commit(v) else show(cur) end
    end

    edit:SetScript("OnEditFocusGained", function()
        if isDisabled() then edit:ClearFocus(); return end
        setEditBorderColor(Def.FocusRing)
        edit:HighlightText()
    end)
    edit:SetScript("OnEditFocusLost", function()
        setEditBorderColor(nil)
        edit:HighlightText(0, 0)
        applyTyped()
    end)
    edit:SetScript("OnEnterPressed", function()
        applyTyped()
        edit:ClearFocus()
    end)
    edit:SetScript("OnEscapePressed", function()
        reverting = true
        show(get())
        edit:ClearFocus()
        reverting = false
    end)
    -- A stepper hidden mid-edit (card collapsed, dashboard closed) drops focus; focus loss commits
    -- the typed value as usual, so a hidden EditBox never keeps the keyboard.
    edit:SetScript("OnHide", function()
        if edit:HasFocus() then edit:ClearFocus() end
    end)

    local function onStep(delta)
        if isDisabled() then return end
        -- Commit a half-typed value first, so the step starts from what the player sees.
        if edit:HasFocus() then edit:ClearFocus() end
        commit(stepValue(get(), delta, get()))
    end
    minus:SetScript("OnClick", function() onStep(-1) end)
    plus:SetScript("OnClick", function() onStep(1) end)

    local function applyDisabledVisuals()
        local dis = isDisabled()
        frame:SetAlpha(dis and 0.35 or 1)
        if dis then
            minus:Disable()
            plus:Disable()
            if edit:HasFocus() then edit:ClearFocus() end
            edit:EnableMouse(false)
        else
            minus:Enable()
            plus:Enable()
            edit:EnableMouse(true)
        end
    end

    function frame:Refresh()
        if not edit:HasFocus() then show(get()) end
        applyDisabledVisuals()
    end

    -- Tooltips first: ApplyOptionTooltip enables the mouse, and Refresh must have the last word
    -- so a stepper that starts disabled keeps its EditBox mouse-disabled.
    ApplyOptionTooltip(minus, tooltip)
    ApplyOptionTooltip(plus, tooltip)
    ApplyOptionTooltip(edit, tooltip)
    frame:Refresh()
    return frame
end

-- Compact on/off pill with its label on the left, for a control inside a composite row
-- (the font row's outline toggle). Sizes itself to its label; caller anchors it.
-- @param parent table
-- @param labelText string
-- @param get function
-- @param set function
-- @param disabledFn function|nil
-- @param tooltip string|function|nil
-- @return table  Button with Refresh
function _G.OptionsWidgets_CreateCompactToggle(parent, labelText, get, set, disabledFn, tooltip)
    local M = addon.FONT_ROW_METRICS
    local LABEL_GAP = 6
    local btn = CreateFrame("Button", nil, parent)
    btn:SetHeight(M.controlH)

    local label = btn:CreateFontString(nil, "OVERLAY")
    SetSafeFont(label, Def.FontPath, Def.LabelSize, nil)
    SetTextColor(label, Def.TextColorLabel)
    label:SetJustifyH("LEFT")
    label:SetText(labelText or "")
    label:SetPoint("LEFT", btn, "LEFT", 0, 0)

    local track = CreatePill(btn)
    track:SetPoint("RIGHT", btn, "RIGHT", 0, 0)

    local function measure()
        btn:SetWidth(math.ceil(label:GetStringWidth() or 0) + LABEL_GAP + Def.SwitchWidth)
    end
    local function isDisabled()
        return disabledFn and disabledFn() == true
    end
    -- Set by a click and consumed by the next paint: the player's change slides, a Refresh
    -- from outside snaps (as the full-width switch).
    local animateNext
    local function paint()
        local animate = animateNext
        animateNext = nil
        track:SetOn(get() and true or false, animate)
    end

    btn:SetScript("OnClick", function()
        if isDisabled() then return end
        animateNext = true
        set(not get())
        paint()
    end)
    -- Only the switch scales on a press; the label and the click area stay put.
    AttachPress(btn, track.body, isDisabled)

    function btn:Refresh()
        measure()
        paint()
        local alpha = isDisabled() and 0.45 or 1
        label:SetAlpha(alpha)
        track:SetAlpha(alpha)
    end

    btn:Refresh()
    ApplyOptionTooltip(btn, tooltip)
    return btn
end

-- Font row: the label on the left, then the font dropdown, size stepper and outline control
-- right-aligned on one line in that order. Below FONT_ROW_METRICS.wrapBelow it wraps: label and
-- font on the first line, size and outline right-aligned on the second. A missing part leaves no gap.
-- @param parent table
-- @param labelText string|function
-- @param description string|nil  Row tooltip (with tooltip)
-- @param parts table  { family?, size?, outline? }, each with get and set already wired by the caller.
--   family: options, displayFn, searchable (default true), fontPreviewInList (default true), preserveOrder.
--   size: min, max, step. outline: kind ("dropdown" or "toggle"), options (default addon.OUTLINE_OPTIONS).
--   Any part: disabled (ORed with the row's), tooltip (added to the control's own tooltip).
-- @param disabledFn function|nil  The row's disabled state
-- @param tooltip string|function|nil
-- @return table  Frame with Refresh; set row.onHeightChanged to hear when it wraps or unwraps.
function _G.OptionsWidgets_CreateFontRow(parent, labelText, description, parts, disabledFn, tooltip)
    local M = addon.FONT_ROW_METRICS
    parts = parts or {}
    local labelFn = type(labelText) == "function" and labelText or nil
    local resolvedLabel = labelFn and labelFn() or labelText

    local row = CreateFrame("Frame", nil, parent)
    row.searchText = ((resolvedLabel or "") .. " " .. (description or "")):lower()
    row._rowPadded = true

    -- The label on one line, and the row's description under it in the help style.
    local label = row:CreateFontString(nil, "OVERLAY")
    SetSafeFont(label, Def.FontPath, Def.LabelSize, nil)
    label:SetJustifyH("LEFT")
    label:SetJustifyV("TOP")
    SetTextColor(label, Def.TextColorLabel)
    label:SetText(resolvedLabel or "")
    label:SetWordWrap(false)

    local desc, hasDesc = CreateRowDesc(row, description)
    desc:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -Def.RowDescGap)
    row._desc = desc
    row._rowLabel = label   -- AttachChangedMarker places its dot and reset arrow from it
    row._rowLabelGap = M.labelGap   -- the label box to the first control (the arrow must fit)
    row:SetHeight(math.max(M.lineH, EstimatedRowHeight(hasDesc)))

    local function rowDisabled()
        return disabledFn and disabledFn() == true
    end
    local function partDisabled(part)
        return function()
            if rowDisabled() then return true end
            local d = part.disabled
            if type(d) == "function" then return d() == true end
            return d == true
        end
    end

    local controls = {}
    local family, size, outline
    if parts.family then
        local p = parts.family
        family = _G.OptionsWidgets_CreateCustomDropdown(row, nil, L["FOCUS_FONT"], p.options or {}, p.get, p.set,
            p.displayFn, p.searchable ~= false, partDisabled(p), p.tooltip, nil, p.fontPreviewInList ~= false,
            p.preserveOrder, { embedded = true })
        family:SetSize(M.familyMax, M.controlH)
        controls[#controls + 1] = family
    end
    if parts.size then
        local p = parts.size
        size = _G.OptionsWidgets_CreateSizeStepper(row, p.get, p.set, p.min, p.max, p.step, partDisabled(p),
            JoinTooltip(L["AUGMENT_FONT_SIZE"], p.tooltip))
        controls[#controls + 1] = size
    end
    if parts.outline then
        local p = parts.outline
        if p.kind == "toggle" then
            outline = _G.OptionsWidgets_CreateCompactToggle(row, L["FOCUS_OUTLINE"], p.get, p.set, partDisabled(p),
                JoinTooltip(L["FOCUS_OUTLINE"], p.tooltip))
        else
            local opts, keepOrder = p.options, p.preserveOrder
            if opts == nil then opts, keepOrder = addon.OUTLINE_OPTIONS or {}, true end
            -- The same rule as a dropdown row: a short static list shows as segments when they fit
            -- (Layout passes M.outlineSegMax), else the dropdown.
            local segOk = addon.SegmentedEligible and addon.SegmentedEligible({
                options = opts, searchable = p.searchable, fontPreviewInList = p.fontPreviewInList,
                segmented = p.segmented,
            })
            outline = _G.OptionsWidgets_CreateCustomDropdown(row, nil, L["FOCUS_OUTLINE"], opts, p.get, p.set,
                p.displayFn, false, partDisabled(p), p.tooltip, nil, false, keepOrder,
                { embedded = true, segmented = segOk and true or nil })
            outline:SetSize(M.outlineW, M.controlH)
        end
        controls[#controls + 1] = outline
    end

    local has = { family = family ~= nil, size = size ~= nil, outline = outline ~= nil }

    -- Right-align a list of controls in a band `top` px down and `h` tall.
    local function place(list, top, h)
        local x = 0
        for i = #list, 1, -1 do
            local c = list[i]
            c:ClearAllPoints()
            c:SetPoint("RIGHT", row, "TOPRIGHT", -x, -(top + h / 2))
            x = x + (c:GetWidth() or 0)
            if i > 1 then x = x + M.gap end
        end
    end
    -- The width a list of controls takes, gaps between them included.
    local function bandWidth(list)
        local x = 0
        for i, c in ipairs(list) do
            x = x + (c:GetWidth() or 0)
            if i > 1 then x = x + M.gap end
        end
        return x
    end

    local function Layout(w)
        w = w or 0
        local lay = addon.FontRowLayout(w, has)
        if family then family:SetWidth(lay.familyW) end
        if outline and outline.ChooseSegmented then
            outline:SetWidth(outline:ChooseSegmented(M.outlineSegMax or M.outlineW) or M.outlineW)
        end
        local line1, line2 = {}, {}
        if lay.wrapped then
            if family then line1[1] = family end
            if size then line2[#line2 + 1] = size end
            if outline then line2[#line2 + 1] = outline end
        else
            for _, c in ipairs(controls) do line1[#line1 + 1] = c end
        end
        -- The first line is as tall as a settings row (taller with a description); the text
        -- block is centred in it and the controls sit on its middle.
        local used = bandWidth(line1)
        if w > 0 then
            local textW = math.max(1, w - (used > 0 and (used + M.labelGap) or 0))
            label:SetWidth(textW)
            desc:SetWidth(textW)
        end
        local rowH, blockH = addon.SettingsRowHeight(label:GetStringHeight(),
            hasDesc and desc:GetStringHeight() or 0, RowHeightMetrics())
        local line1H = math.max(M.lineH, rowH)
        place(line1, 0, line1H)
        local height = line1H
        if #line2 > 0 then
            place(line2, line1H, M.line2H)
            -- Pad the second line's bottom like a row's, less what the band already leaves.
            height = line1H + M.line2H + math.max(0, Def.RowPadY - (M.line2H - M.controlH) / 2)
        end
        label:ClearAllPoints()
        label:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -(line1H - blockH) / 2)
        if math.abs((row:GetHeight() or 0) - height) > 0.5 then
            row:SetHeight(height)
            if row.onHeightChanged then row.onHeightChanged() end
        end
    end

    -- Re-lay out only when the width moves (0.5px guard, as colorMatrixFull does); the height
    -- change from wrapping fires OnSizeChanged again with the same width.
    local lastW = -1
    row:SetScript("OnSizeChanged", function(_, w)
        w = w or 0
        if math.abs(w - lastW) > 0.5 then
            lastW = w
            Layout(w)
        end
    end)

    function row:Refresh()
        if labelFn then
            local newLabel = labelFn()
            if newLabel then label:SetText(newLabel) end
        end
        for _, c in ipairs(controls) do
            if c.Refresh then c:Refresh() end
        end
        SetTextColor(label, rowDisabled() and Def.TextColorSection or Def.TextColorLabel)
        desc:SetAlpha(rowDisabled() and 0.45 or 1)
        -- The toggle sizes itself to its label in Refresh, and a font change moves the text,
        -- so place the line again.
        Layout(lastW > 0 and lastW or (row:GetWidth() or 0))
    end

    Layout(0)
    row:Refresh()
    ApplyRowHoverHighlight(row)
    ApplyOptionTooltip(row, JoinTooltip(description, tooltip))
    return row
end

-- Color swatch row: label + clickable swatch (for colorMatrix/colorGroup in options panel).
-- defaultTbl: {r,g,b} or nil (nil => {0.5,0.5,0.5}). getTbl() returns current color or nil. setKeyVal({r,g,b}), notify() on change.
-- disabledFn: optional function() return boolean end; when true, greys out and disables the swatch.
function _G.OptionsWidgets_CreateColorSwatchRow(parent, anchor, labelText, defaultTbl, getTbl, setKeyVal, notify, disabledFn, hasAlpha, tooltip)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(280, 24)
    row:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -4)
    local lab = row:CreateFontString(nil, "OVERLAY")
    SetSafeFont(lab, Def.FontPath, Def.LabelSize, nil)
    lab:SetJustifyH("LEFT")
    SetTextColor(lab, Def.TextColorLabel)
    lab:SetText(labelText or "")
    lab:SetPoint("LEFT", row, "LEFT", 0, 0)
    local swatch = CreateFrame("Button", nil, row)
    swatch:SetSize(22, 18)
    swatch:SetPoint("LEFT", lab, "RIGHT", 10, 0)
    local tex = swatch:CreateTexture(nil, "BACKGROUND")
    local swInset = 1
    tex:SetPoint("TOPLEFT", swatch, "TOPLEFT", swInset, -swInset)
    tex:SetPoint("BOTTOMRIGHT", swatch, "BOTTOMRIGHT", -swInset, swInset)
    addon.CreateBorder(swatch, Def.SectionCardBorder)
    swatch.tex = tex
    local def = defaultTbl and #defaultTbl >= 3 and defaultTbl or { 0.5, 0.5, 0.5 }
    -- Decode the current colour from getTbl(): supports {r,g,b[,a]} tables and the legacy
    -- numeric multi-return, falling back to def. Honours hasAlpha.
    local function readColor()
        local r, g, b, a = def[1], def[2], def[3], def[4] or 1
        if getTbl then
            local result = getTbl()
            if type(result) == "table" and type(result[1]) == "number" and type(result[2]) == "number" and type(result[3]) == "number" then
                r, g, b = result[1], result[2], result[3]
                if hasAlpha and type(result[4]) == "number" then a = result[4] end
            elseif type(result) == "number" then
                local rVal, gVal, bVal, aVal = getTbl()
                if type(rVal) == "number" and type(gVal) == "number" and type(bVal) == "number" then
                    r, g, b = rVal, gVal, bVal
                    if hasAlpha and type(aVal) == "number" then a = aVal end
                end
            end
        end
        return r, g, b, a
    end
    function swatch:Refresh()
        local r, g, b, a = readColor()
        if hasAlpha then
            tex:SetColorTexture(r, g, b, a)
        else
            tex:SetColorTexture(r, g, b, 1)
        end
    end
    swatch:SetScript("OnClick", function()
        if disabledFn and disabledFn() then return end
        local r, g, b, a = readColor()
        addon.OpenColorPicker({
            r = r, g = g, b = b, a = a, hasAlpha = hasAlpha,
            default = { def[1], def[2], def[3], def[4] },
            onChange = function(nr, ng, nb, na)
                -- Live drag: setKeyVal self-skips the heavy notify while _colorPickerLive is set.
                setKeyVal(hasAlpha and { nr, ng, nb, na } or { nr, ng, nb })
                if tex then tex:SetColorTexture(nr, ng, nb, hasAlpha and na or 1) end
            end,
            onConfirm = function(nr, ng, nb, na)
                setKeyVal(hasAlpha and { nr, ng, nb, na } or { nr, ng, nb })
                if tex then tex:SetColorTexture(nr, ng, nb, hasAlpha and na or 1) end
                if notify then notify() end
            end,
            onCancel = function()
                setKeyVal(hasAlpha and { r, g, b, a } or { r, g, b })
                if tex then tex:SetColorTexture(r, g, b, hasAlpha and a or 1) end
                if notify then notify() end
            end,
        })
    end)
    row.Refresh = function()
        swatch:Refresh()
        if disabledFn then
            local disabled = disabledFn()
            if disabled then
                swatch:Disable()
                lab:SetAlpha(0.5)
                swatch:SetAlpha(0.5)
            else
                swatch:Enable()
                lab:SetAlpha(1)
                swatch:SetAlpha(1)
            end
        end
    end
    row:Refresh()
    ApplyOptionTooltip(row, tooltip)
    return row
end

-- Compact inline swatch for color matrix cards: swatch on left, label on right (cleaner layout).
-- getTbl() returns {r,g,b} or nil; setKeyVal({r,g,b}) writes to DB.
function _G.OptionsWidgets_CreateMiniSwatch(parent, labelText, defaultTbl, getTbl, setKeyVal, notify, tooltip)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(90, 24)

    local swatch = CreateFrame("Button", nil, frame)
    swatch:SetSize(20, 20)
    swatch:SetPoint("LEFT", frame, "LEFT", 0, 0)
    local lab = frame:CreateFontString(nil, "OVERLAY")
    SetSafeFont(lab, Def.FontPath, 10, "")
    lab:SetJustifyH("LEFT")
    lab:SetTextColor(0.88, 0.88, 0.92, 1)
    lab:SetText(labelText or "")
    lab:SetPoint("LEFT", swatch, "RIGHT", 8, 0)
    lab:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
    local tex = swatch:CreateTexture(nil, "BACKGROUND")
    tex:SetPoint("TOPLEFT", swatch, "TOPLEFT", 1, -1)
    tex:SetPoint("BOTTOMRIGHT", swatch, "BOTTOMRIGHT", -1, 1)
    if addon.CreateBorder then
        addon.CreateBorder(swatch, Def.SectionCardBorder)
    end
    swatch.tex = tex

    local def = defaultTbl and #defaultTbl >= 3 and defaultTbl or { 0.5, 0.5, 0.5 }

    function swatch:Refresh()
        local r, g, b = def[1], def[2], def[3]
        if getTbl then
            local result = getTbl()
            if type(result) == "table" and result[1] then
                r, g, b = result[1], result[2], result[3]
            end
        end
        tex:SetColorTexture(r, g, b, 1)
    end

    swatch:SetScript("OnClick", function()
        local cur = getTbl and getTbl() or def
        local r, g, b = cur[1] or def[1], cur[2] or def[2], cur[3] or def[3]
        addon.OpenColorPicker({
            r = r, g = g, b = b, hasAlpha = false,
            default = { def[1], def[2], def[3] },
            onChange = function(nr, ng, nb)
                -- Live drag: setKeyVal self-skips the heavy notify while _colorPickerLive is set.
                setKeyVal({ nr, ng, nb })
                if tex then tex:SetColorTexture(nr, ng, nb, 1) end
            end,
            onConfirm = function(nr, ng, nb)
                setKeyVal({ nr, ng, nb })
                if tex then tex:SetColorTexture(nr, ng, nb, 1) end
                if notify then notify() end
            end,
            onCancel = function()
                setKeyVal({ r, g, b })
                if tex then tex:SetColorTexture(r, g, b, 1) end
                if notify then notify() end
            end,
        })
    end)

    frame.Refresh = function() swatch:Refresh() end
    frame:Refresh()
    if tooltip then ApplyOptionTooltip(swatch, tooltip) end
    return frame
end

-- Simplified Color Swatch for Dashboard (no anchor required, uses get/set functions)
function _G.OptionsWidgets_CreateColorSwatch(parent, labelText, description, get, set, hasAlpha, tooltip, liveThrottle)
    local row = CreateFrame("Frame", nil, parent)
    local searchText = (labelText or "") .. " " .. (description or "")
    row.searchText = searchText:lower()

    -- A rounded swatch with a hairline ring, at the row's right.
    local swatch = CreateFrame("Button", nil, row)
    swatch:SetSize(Def.SwatchSize, Def.SwatchSize)
    swatch:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    local paintSwatch, paintRing = PaintRounded(swatch, Def.SwatchRadius, "ARTWORK", true)
    PaintToken(paintRing, Def.SwatchRing)

    local text = CreateRowText(row, labelText, description, function()
        return Def.SwatchSize + Def.RowControlGap
    end)

    function swatch:Refresh()
        if type(get) ~= "function" then
            paintSwatch(1, 1, 1, 1)
            return
        end
        local r, g, b, a = get()
        paintSwatch(r or 1, g or 1, b or 1, a or 1)
    end

    swatch:SetScript("OnClick", function()
        if type(get) ~= "function" or type(set) ~= "function" then return end
        local r, g, b, a = get()
        r, g, b, a = r or 1, g or 1, b or 1, a or 1
        addon.OpenColorPicker({
            r = r, g = g, b = b, a = a, hasAlpha = hasAlpha,
            default = { r, g, b, a },
            liveThrottle = liveThrottle,
            onChange = function(nr, ng, nb, na)
                if hasAlpha then set(nr, ng, nb, na) else set(nr, ng, nb, 1) end
                swatch:Refresh()
            end,
            onConfirm = function(nr, ng, nb, na)
                if hasAlpha then set(nr, ng, nb, na) else set(nr, ng, nb, 1) end
                swatch:Refresh()
            end,
            onCancel = function()
                if hasAlpha then set(r, g, b, a) else set(r, g, b, 1) end
                swatch:Refresh()
            end,
        })
    end)

    function row:Refresh()
        swatch:Refresh()
        text.Fit(true)
    end

    row:Refresh()
    ApplyRowHoverHighlight(row)
    local effectiveTooltip = JoinTooltip(description, tooltip)
    ApplyOptionTooltip(row, effectiveTooltip)
    return row
end

-- Search input: card-themed styling (SectionCardBg, SectionCardBorder), search icon, integrated clear, focus state.
-- onTextChanged(text) called on input.
local SEARCH_ICON_LEFT = 28
local SEARCH_CLEAR_SIZE = 20
local SEARCH_BAR_BACKDROP = {
    bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 16,
    edgeSize = 12,
    insets   = { left = 3, right = 3, top = 3, bottom = 3 },
}
function _G.OptionsWidgets_CreateSearchInput(parent, onTextChanged, placeholder)
    local row = CreateFrame("Frame", nil, parent)
    row:SetAllPoints(parent)
    local editWrapper = CreateFrame("Frame", nil, row, "BackdropTemplate")
    editWrapper:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    editWrapper:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, 0)
    editWrapper:SetHeight(32)
    editWrapper:SetBackdrop(SEARCH_BAR_BACKDROP)
    editWrapper:SetBackdropColor(Def.SectionCardBg[1], Def.SectionCardBg[2], Def.SectionCardBg[3], Def.SectionCardBg[4])
    editWrapper:SetBackdropBorderColor(Def.SectionCardBorder[1], Def.SectionCardBorder[2], Def.SectionCardBorder[3], Def.SectionCardBorder[4])

    local function setBorderColor(c)
        editWrapper:SetBackdropBorderColor(c[1], c[2], c[3], c[4] or 1)
    end

    local edit = CreateFrame("EditBox", nil, editWrapper)
    edit:SetAllPoints(editWrapper)
    edit:SetAutoFocus(false)
    edit:EnableMouse(true)
    SetSafeFont(edit, Def.FontPath, Def.LabelSize, nil)
    edit:SetTextInsets(SEARCH_ICON_LEFT, SEARCH_CLEAR_SIZE + 14, 0, 0)
    local tc = Def.TextColorLabel
    edit:SetTextColor(tc[1], tc[2], tc[3], tc[4] or 1)

    local searchIcon = edit:CreateTexture(nil, "OVERLAY")
    searchIcon:SetSize(14, 14)
    searchIcon:SetPoint("LEFT", edit, "LEFT", 10, 0)
    searchIcon:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_03")
    searchIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    if placeholder then
        local ph = edit:CreateFontString(nil, "OVERLAY")
        SetSafeFont(ph, Def.FontPath, Def.LabelSize, nil)
        SetTextColor(ph, Def.TextColorSection)
        ph:SetText(placeholder)
        ph:SetPoint("LEFT", edit, "LEFT", SEARCH_ICON_LEFT, 0)
        ph:SetJustifyH("LEFT")
        edit.placeholder = ph
        edit:SetScript("OnEditFocusGained", function()
            if ph then ph:Hide() end
            setBorderColor(Def.FocusRing)
            if row.clearBtn then row.clearBtn:SetShown(edit:GetText() ~= "") end
        end)
        edit:SetScript("OnEditFocusLost", function()
            if ph and edit:GetText() == "" then ph:Show() end
            setBorderColor(Def.SectionCardBorder)
            if row.clearBtn then row.clearBtn:SetShown(edit:GetText() ~= "") end
        end)
    else
        edit:SetScript("OnEditFocusGained", function()
            setBorderColor(Def.FocusRing)
            if row.clearBtn then row.clearBtn:SetShown(edit:GetText() ~= "") end
        end)
        edit:SetScript("OnEditFocusLost", function()
            setBorderColor(Def.SectionCardBorder)
            if row.clearBtn then row.clearBtn:SetShown(edit:GetText() ~= "") end
        end)
    end
    edit:SetScript("OnEscapePressed", function()
        edit:SetText("")
        if edit.placeholder then edit.placeholder:Show() end
        edit:ClearFocus()
        if onTextChanged then onTextChanged("") end
        if row.clearBtn then row.clearBtn:Hide() end
    end)
    if not placeholder then
        edit:SetScript("OnTextChanged", function(self, userInput)
            if userInput and onTextChanged then onTextChanged(self:GetText()) end
            if row.clearBtn then row.clearBtn:SetShown(self:GetText() ~= "") end
        end)
    else
        edit:SetScript("OnTextChanged", function(self, userInput)
            if edit.placeholder then edit.placeholder:SetShown(self:GetText() == "") end
            if userInput and onTextChanged then onTextChanged(self:GetText()) end
            if row.clearBtn then row.clearBtn:SetShown(self:GetText() ~= "") end
        end)
    end

    local clearBtn = CreateFrame("Button", nil, row)
    clearBtn:SetSize(SEARCH_CLEAR_SIZE, SEARCH_CLEAR_SIZE)
    clearBtn:SetPoint("RIGHT", editWrapper, "RIGHT", -8, 0)
    clearBtn:SetFrameLevel(editWrapper:GetFrameLevel() + 5)
    clearBtn:EnableMouse(true)
    clearBtn:Hide()
    local clearText = clearBtn:CreateFontString(nil, "OVERLAY")
    SetSafeFont(clearText, Def.FontPath, Def.LabelSize - 1, nil)
    SetTextColor(clearText, Def.TextColorSection)
    clearText:SetText("X")
    clearText:SetPoint("CENTER", clearBtn, "CENTER", 0, 0)
    clearBtn:SetScript("OnClick", function()
        edit:SetText("")
        if edit.placeholder then edit.placeholder:Show() end
        if onTextChanged then onTextChanged("") end
        clearBtn:Hide()
    end)
    clearBtn:SetScript("OnEnter", function() SetTextColor(clearText, Def.TextColorHighlight) end)
    clearBtn:SetScript("OnLeave", function() SetTextColor(clearText, Def.TextColorSection) end)

    row.edit = edit
    row.clearBtn = clearBtn
    row.searchText = ""
    return row
end

local CARD_HEADER_H = 24
local CARD_EXPAND_ANIM_DUR = 0.22

-- Section card: rounded corners via SetBackdrop, soft cinematic background.
-- When sectionKey and getCollapsedFn/setCollapsedFn are provided, the card is collapsible.
function _G.OptionsWidgets_CreateSectionCard(parent, anchor, sectionKey, getCollapsedFn, setCollapsedFn)
    local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    card:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -Def.SectionGap)
    card:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    card:SetBackdrop(SECTION_CARD_BACKDROP)
    card:SetBackdropColor(Def.SectionCardBg[1], Def.SectionCardBg[2], Def.SectionCardBg[3], Def.SectionCardBg[4])
    card:SetBackdropBorderColor(Def.SectionCardBorder[1], Def.SectionCardBorder[2], Def.SectionCardBorder[3], Def.SectionCardBorder[4])

    if sectionKey and getCollapsedFn and setCollapsedFn then
        card:SetClipsChildren(true)
        local contentContainer = CreateFrame("Frame", nil, card)
        contentContainer:SetPoint("TOPLEFT", card, "TOPLEFT", Def.CardPadding, -Def.CardPadding - CARD_HEADER_H)
        contentContainer:SetPoint("RIGHT", card, "RIGHT", -Def.CardPadding, 0)
        contentContainer:SetHeight(1)
        contentContainer:SetFrameLevel(card:GetFrameLevel() + 1)
        card.contentContainer = contentContainer
        card.contentAnchor = contentContainer
        card.sectionKey = sectionKey
        card.getCardCollapsed = getCollapsedFn
        card.setCardCollapsed = setCollapsedFn
        card.headerHeight = CARD_HEADER_H + Def.CardPadding
    end

    return card
end

local function SetHeaderCollapsedAnchors(hdr, chevron, hdrLabel, collapsed, cw, lw, parent)
    hdr:ClearAllPoints()
    chevron:ClearAllPoints()
    hdrLabel:ClearAllPoints()
    if collapsed then
        -- Fill full card for centered text
        hdr:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
        hdr:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
        local pad = Def.CardPadding
        chevron:SetPoint("CENTER", hdr, "LEFT", pad + 6 + cw / 2, 0)
        hdrLabel:SetPoint("LEFT", chevron, "RIGHT", 6, 0)
        hdrLabel:SetPoint("CENTER", hdr, "LEFT", pad + 6 + cw + 6 + lw / 2, 0)
    else
        -- Inset header at top of card
        hdr:SetPoint("TOPLEFT", parent, "TOPLEFT", Def.CardPadding, -Def.CardPadding)
        hdr:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -Def.CardPadding, 0)
        hdr:SetHeight(CARD_HEADER_H)
        chevron:SetPoint("CENTER", hdr, "LEFT", 6 + cw / 2, 0)
        hdrLabel:SetPoint("LEFT", chevron, "RIGHT", 6, 0)
        hdrLabel:SetPoint("CENTER", hdr, "LEFT", 6 + cw + 6 + lw / 2, 0)
    end
end

-- Section header: uppercase label, left-aligned. When sectionKey and getCollapsedFn/setCollapsedFn are
-- provided, returns a clickable Button with chevron for collapse; otherwise returns a FontString.
function _G.OptionsWidgets_CreateSectionHeader(parent, text, sectionKey, getCollapsedFn, setCollapsedFn)
    local sk = sectionKey or parent.sectionKey
    local getFn = getCollapsedFn or parent.getCardCollapsed
    local setFn = setCollapsedFn or parent.setCardCollapsed

    if sk and getFn and setFn then
        local hdr = CreateFrame("Button", nil, parent)
        hdr:EnableMouse(true)
        hdr:SetFrameLevel(parent:GetFrameLevel() + 2)

        local hdrBg = hdr:CreateTexture(nil, "BACKGROUND")
        hdrBg:SetAllPoints(hdr)
        hdrBg:SetColorTexture(0.10, 0.10, 0.12, 0.0)

        local chevron = hdr:CreateFontString(nil, "OVERLAY")
        SetSafeFont(chevron, Def.FontPath, Def.LabelSize or 13, nil)
        SetTextColor(chevron, Def.TextColorSection)
        chevron:SetText(getFn(sk) and "+" or "-")
        local cw = chevron:GetStringWidth()
        hdr.chevron = chevron
        parent.header = hdr

        local hdrLabel = hdr:CreateFontString(nil, "OVERLAY")
        SetSafeFont(hdrLabel, Def.FontPath, Def.SectionSize + 1, nil)
        SetTextColor(hdrLabel, Def.TextColorSection)
        hdrLabel:SetText(text and text:upper() or "")
        hdrLabel:SetJustifyH("LEFT")
        local lw = hdrLabel:GetStringWidth()
        SetHeaderCollapsedAnchors(hdr, chevron, hdrLabel, getFn(sk), cw, lw, parent)

        -- Text glow on hover instead of full-card highlight
        local glowColor = { 0, 0, 0 } -- neutral drop shadow; the accent is kept for on/selected states
        hdr:SetScript("OnEnter", function()
            SetTextColor(chevron, Def.TextColorHighlight)
            SetTextColor(hdrLabel, Def.TextColorHighlight)
            chevron:SetShadowColor(glowColor[1], glowColor[2], glowColor[3], 0.75)
            chevron:SetShadowOffset(2, -2)
            hdrLabel:SetShadowColor(glowColor[1], glowColor[2], glowColor[3], 0.75)
            hdrLabel:SetShadowOffset(2, -2)
        end)
        hdr:SetScript("OnLeave", function()
            SetTextColor(chevron, Def.TextColorSection)
            SetTextColor(hdrLabel, Def.TextColorSection)
            if addon.Dashboard_ApplyTextShadow then
                addon.Dashboard_ApplyTextShadow(chevron)
                addon.Dashboard_ApplyTextShadow(hdrLabel)
            else
                chevron:SetShadowColor(0, 0, 0, 0)
                chevron:SetShadowOffset(0, 0)
                hdrLabel:SetShadowColor(0, 0, 0, 0)
                hdrLabel:SetShadowOffset(0, 0)
            end
        end)

        hdr.UpdateCollapsedAnchors = function()
            SetHeaderCollapsedAnchors(hdr, chevron, hdrLabel, getFn(sk), cw, lw, parent)
        end

        hdr:SetScript("OnClick", function()
            local collapsed = not getFn(sk)
            setFn(sk, collapsed)
            chevron:SetText(collapsed and "+" or "-")
            SetHeaderCollapsedAnchors(hdr, chevron, hdrLabel, collapsed, cw, lw, parent)
            local cc = parent.contentContainer
            local headerH = parent.headerHeight or CARD_HEADER_H + Def.CardPadding
            local fullH = parent.contentHeight and (parent.contentHeight + (Def.CardBottomPadding or Def.CardPadding)) or headerH
            local fromH = parent:GetHeight()
            local toH = collapsed and headerH or fullH
            if cc then
                cc:SetShown(not collapsed)
            end
            if fromH == toH then return end
            parent.animStart = GetTime()
            parent.animFrom = fromH
            parent.animTo = toH
            parent:SetScript("OnUpdate", function(self)
                local elapsed = GetTime() - self.animStart
                local t = math.min(elapsed / CARD_EXPAND_ANIM_DUR, 1)
                local h = self.animFrom + (self.animTo - self.animFrom) * easeOut(t)
                self:SetHeight(math.max(headerH, h))
                if t >= 1 then
                    self:SetScript("OnUpdate", nil)
                    -- Resize parent tab frame so scroll stops at content end
                    local tab = self:GetParent()
                    if tab and _G.ResizeTabFrame then _G.ResizeTabFrame(tab) end
                end
            end)
        end)

        return hdr
    end

    local label = parent:CreateFontString(nil, "OVERLAY")
    SetSafeFont(label, Def.FontPath, Def.SectionSize + 1, nil)
    label:SetJustifyH("LEFT")
    SetTextColor(label, Def.TextColorSection)
    label:SetText(text and text:upper() or "")
    return label
end

-- Reorder list: drag rows with ghost and insertion line. scrollFrameRef and panelRef for auto-scroll.
local REORDER_ROW_GAP = 4
local REORDER_ROW_HEIGHT = 24
local REORDER_AUTOSCROLL_MARGIN = 40
local REORDER_HEADER_PAD = 14   -- gap below the card header before the first row
local REORDER_RESET_GAP = 6     -- gap above the reset-to-default button
local REORDER_RESET_H = 22      -- reset button height
local REORDER_AUTOSCROLL_STEP = 10

-- Create a drag-to-reorder list widget (e.g. for Focus category order). Rows show labelMap[key]; opt.get/set provide order array.
-- @param parent table Parent frame
-- @param anchor table Anchor for TOPLEFT
-- @param opt table Option descriptor: get(), set(order), labelMap, name, tooltip
-- @param scrollFrameRef table Scroll frame for auto-scroll during drag
-- @param panelRef table Options panel for scroll region
-- @param notifyMainAddonFn function Called when order changes (e.g. to refresh tracker)
-- @return table Container frame
function _G.OptionsWidgets_CreateReorderList(parent, anchor, opt, scrollFrameRef, panelRef, notifyMainAddonFn)
    local keys = opt.get and opt.get() or {}
    if type(keys) == "function" then keys = keys() end
    if type(keys) ~= "table" then keys = {} end
    local defaultOrder = addon.GROUP_ORDER
    if #keys < #defaultOrder then
        local seen = {}
        for _, k in ipairs(keys) do seen[k] = true end
        for _, k in ipairs(defaultOrder) do
            if not seen[k] then keys[#keys + 1] = k end
        end
    end
    local labelMap = opt.labelMap or {}
    local container = CreateFrame("Frame", nil, parent)
    container:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -Def.SectionGap)
    container:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    local sectionLabel = OptionsWidgets_CreateSectionHeader(container, opt.name or L["FOCUS_ORDER"])
    sectionLabel:SetPoint("TOPLEFT", container, "TOPLEFT", Def.CardPadding, -Def.CardPadding)

    local rows = {}
    local keyToRow = {}
    local state = {
        active = false,
        sourceIndex = nil,
        targetIndex = nil,
        ghostFrame = nil,
        insertionLine = nil,
        sourceRow = nil,
        rows = rows,
        keyToRow = keyToRow,
        get = opt.get,
        set = opt.set,
    }

    local function ensureGhost()
        if state.ghostFrame then return state.ghostFrame end
        local ghost = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        ghost:SetFrameStrata("TOOLTIP")
        ghost:SetSize(240, REORDER_ROW_HEIGHT)
        ghost:SetAlpha(0.85)
        ghost:SetBackdrop(SECTION_CARD_BACKDROP)
        ghost:SetBackdropColor(Def.SectionCardBg[1], Def.SectionCardBg[2], Def.SectionCardBg[3], 0.95)
        ghost:SetBackdropBorderColor(Def.SectionCardBorder[1], Def.SectionCardBorder[2], Def.SectionCardBorder[3], Def.SectionCardBorder[4])
        state.ghostFrame = ghost
        state.ghostLabel = ghost:CreateFontString(nil, "OVERLAY")
        SetSafeFont(state.ghostLabel, Def.FontPath, Def.LabelSize, nil)
        SetTextColor(state.ghostLabel, Def.TextColorLabel)
        state.ghostLabel:SetPoint("LEFT", ghost, "LEFT", 28, 0)
        return ghost
    end

    local function ensureInsertionLine()
        if state.insertionLine then return state.insertionLine end
        local line = container:CreateTexture(nil, "OVERLAY")
        line:SetHeight(3)
        line:SetColorTexture(Def.TextColorHighlight[1], Def.TextColorHighlight[2], Def.TextColorHighlight[3], 1)
        state.insertionLine = line
        return line
    end

    --- Compute insertion index from cursor Y using row screen bounds (avoids IsMouseOver quirks in scroll frames).
    local function getInsertionIndexFromCursor()
        local activeRows = state.rows
        if not activeRows or #activeRows == 0 then return 1 end
        local _, cursorY = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        cursorY = cursorY / scale
        for i = 1, #activeRows do
            local row = activeRows[i]
            local top = row:GetTop()
            local bottom = row:GetBottom()

            if top and bottom then
                local mid = (top + bottom) / 2
                if cursorY > mid then
                    return i
                end
            end
        end
        return #activeRows + 1
    end


    local presetOrder = { "Collection Focused", "Quest Focused", "Campaign Focused", "World / Rare Focused" }
    local presets = (opt.presets and addon.GROUP_ORDER_PRESETS) and opt.presets or nil
    local presetRow = nil
    if presets then
        presetRow = CreateFrame("Frame", nil, container)
        presetRow:SetHeight(56)  -- 2 rows of buttons + gap
        presetRow:SetPoint("TOPLEFT", sectionLabel, "BOTTOMLEFT", 0, -8)
        presetRow:SetPoint("TOPRIGHT", container, "TOPRIGHT", -Def.CardPadding, 0)
        local btnW, btnH, gapH, gapV = 130, 22, 8, 6
        local prevBtn = nil
        for idx, name in ipairs(presetOrder) do
            local presetOrderArr = presets[name]
            if presetOrderArr then
                local btn = OptionsWidgets_CreateButton(presetRow, name:gsub(" / Rare", "/Rare"), function()
                    if opt.set then opt.set(presetOrderArr) end
                    if container.Refresh then container:Refresh() end
                    if notifyMainAddonFn then notifyMainAddonFn() end
                end, { width = btnW, height = btnH })
                if idx == 1 then
                    btn:SetPoint("TOPLEFT", presetRow, "TOPLEFT", 0, 0)
                elseif idx == 2 then
                    btn:SetPoint("TOPLEFT", prevBtn, "TOPRIGHT", gapH, 0)
                elseif idx == 3 then
                    btn:SetPoint("TOPLEFT", presetRow, "TOPLEFT", 0, -(btnH + gapV))
                else
                    btn:SetPoint("TOPLEFT", prevBtn, "TOPRIGHT", gapH, 0)
                end
                prevBtn = btn
            end
        end
    end

    local rowListAnchor = presetRow or sectionLabel
    local function repositionRows(orderedKeys)
        local prev = rowListAnchor
        for i, key in ipairs(orderedKeys) do
            local row = keyToRow[key]
            if row then
                row.index = i
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -REORDER_ROW_GAP)
                prev = row
            end
        end
        local newRows = {}
        for i, key in ipairs(orderedKeys) do
            if keyToRow[key] then newRows[i] = keyToRow[key] end
        end
        state.rows = newRows
        local resetBtn = state.resetBtn
        if resetBtn and orderedKeys[#orderedKeys] then
            local lastRow = keyToRow[orderedKeys[#orderedKeys]]
            if lastRow then
                resetBtn:ClearAllPoints()
                resetBtn:SetPoint("TOPLEFT", lastRow, "BOTTOMLEFT", 0, -6)
            end
        end
    end

    local function applyReorderAndCleanup()
        if not state.active or not state.rows or #state.rows == 0 then return end

        panelRef:SetScript("OnUpdate", nil)
        state.active = false

        local fromIdx = state.sourceIndex
        local toIdx = state.targetIndex or fromIdx

        if state.ghostFrame then state.ghostFrame:Hide() end
        if state.insertionLine then state.insertionLine:Hide() end
        if state.sourceRow then state.sourceRow:SetAlpha(1) end
        if toIdx == fromIdx then return end

        local orderedKeys = {}
        for i, row in ipairs(state.rows) do
            orderedKeys[i] = row.key
        end

        local key = orderedKeys[fromIdx]
        table.remove(orderedKeys, fromIdx)
        local insertAt = (fromIdx < toIdx) and (toIdx - 1) or toIdx
        table.insert(orderedKeys, insertAt, key)
        state.set(orderedKeys)
        repositionRows(orderedKeys)
        if notifyMainAddonFn then
            notifyMainAddonFn()
        end
    end

    local function onReorderUpdate()
        if not state.active or not IsMouseButtonDown("LeftButton") then
            applyReorderAndCleanup()
            return
        end

        local ghost = ensureGhost()
        local line = ensureInsertionLine()

        local x, y = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        x, y = x / scale, y / scale

        ghost:ClearAllPoints()
        ghost:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
        ghost:Show()

        local insertIdx = getInsertionIndexFromCursor()
        state.targetIndex = insertIdx

        local activeRows = state.rows
        if not activeRows or #activeRows == 0 then return end

            if insertIdx <= #activeRows then
                local ref = activeRows[insertIdx]
                line:ClearAllPoints()
                line:SetPoint("LEFT", ref, "LEFT", 0, 0)
                line:SetPoint("RIGHT", ref, "RIGHT", 0, 0)
                line:SetPoint("BOTTOM", ref, "TOP", 0, REORDER_ROW_GAP / 2)
                line:Show()
            else
                local last = activeRows[#activeRows]
                line:ClearAllPoints()
                line:SetPoint("LEFT", last, "LEFT", 0, 0)
                line:SetPoint("RIGHT", last, "RIGHT", 0, 0)
                line:SetPoint("TOP", last, "BOTTOM", 0, -REORDER_ROW_GAP / 2)
                line:Show()
            end

            -- Auto scroll
            if scrollFrameRef then
                local sy = y
                local sfTop = scrollFrameRef:GetTop()
                local sfBottom = scrollFrameRef:GetBottom()
                local cur = scrollFrameRef:GetVerticalScroll()
                local vh = scrollFrameRef:GetHeight()
                local scrollChild = scrollFrameRef:GetScrollChild()
                local maxScroll = math.max(((scrollChild and scrollChild:GetHeight() or 0) - vh), 0)

                if sfTop and sy > sfTop - REORDER_AUTOSCROLL_MARGIN and cur > 0 then
                    scrollFrameRef:SetVerticalScroll(math.max(cur - REORDER_AUTOSCROLL_STEP, 0))
                elseif sfBottom and sy < sfBottom + REORDER_AUTOSCROLL_MARGIN and maxScroll > 0 then
                    scrollFrameRef:SetVerticalScroll(math.min(cur + REORDER_AUTOSCROLL_STEP, maxScroll))
                end
            end
    end

    local prevAnchor = rowListAnchor
    for i, key in ipairs(keys) do
        local row = CreateFrame("Button", nil, container)
        row:SetSize(240, REORDER_ROW_HEIGHT)
        row:SetPoint("TOPLEFT", prevAnchor, "BOTTOMLEFT", 0, -REORDER_ROW_GAP)
        prevAnchor = row
        row.key = key
        row.index = i
        keyToRow[key] = row
        local lab = row:CreateFontString(nil, "OVERLAY")
        SetSafeFont(lab, Def.FontPath, Def.LabelSize, nil)
        lab:SetJustifyH("LEFT")
        SetTextColor(lab, Def.TextColorLabel)
        lab:SetText(L[(labelMap[key]) or key:gsub("^%l", string.upper)])
        lab:SetPoint("LEFT", row, "LEFT", 24, 0)
        row.label = lab
        local grip = row:CreateFontString(nil, "OVERLAY")
        SetSafeFont(grip, Def.FontPath, Def.LabelSize, nil)
        SetTextColor(grip, Def.TextColorSection)
        grip:SetText("::")
        grip:SetPoint("LEFT", row, "LEFT", 4, 0)
        row:SetScript("OnMouseDown", function(_, btn)
            if btn ~= "LeftButton" then return end
            state.active = true
            state.sourceIndex = row.index
            state.targetIndex = row.index
            state.sourceRow = row
            row:SetAlpha(0.5)
            ensureGhost():Show()
            state.ghostLabel:SetText(lab:GetText())
            panelRef:SetScript("OnUpdate", onReorderUpdate)
        end)
        rows[i] = row
    end
    state.rows = rows

    local resetBtn = OptionsWidgets_CreateButton(container, L["FOCUS_RESET_DEFAULT"], function()
        if opt.set then opt.set(nil) end
        if addon.SetDB then addon.SetDB("groupOrder", nil) end
        local newKeys = opt.get and opt.get() or {}
        if type(newKeys) == "function" then newKeys = newKeys() end
        if type(newKeys) == "table" then repositionRows(newKeys) end
        if notifyMainAddonFn then notifyMainAddonFn() end
    end, { width = 100, height = 22 })
    state.resetBtn = resetBtn
    resetBtn:SetPoint("TOPLEFT", prevAnchor, "BOTTOMLEFT", 0, -6)

    local presetH = presetRow and (8 + 56) or 0
    local totalH = Def.CardPadding + REORDER_HEADER_PAD + presetH + (#keys * (REORDER_ROW_HEIGHT + REORDER_ROW_GAP)) + REORDER_RESET_GAP + REORDER_RESET_H + Def.CardPadding
    container:SetHeight(totalH)
    container.searchText = ((opt.name or "order") .. " " .. (opt.desc or "") .. " " .. (opt.tooltip or "")):lower()
    function container:Refresh()
        local newKeys = opt.get and opt.get() or {}
        if type(newKeys) == "function" then newKeys = newKeys() end
        if type(newKeys) == "table" then repositionRows(newKeys) end
    end
    return container
end

-- Edit box: multi-line text input with optional read-only mode (used for profile import/export).
function _G.OptionsWidgets_CreateEditBox(parent, labelText, get, set, opts)
    opts = opts or {}
    local boxH = opts.height or 60
    local readonly = opts.readonly
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(20 + 4 + boxH)
    row.searchText = ((labelText or "") .. " editbox"):lower()

    local label = row:CreateFontString(nil, "OVERLAY")
    SetSafeFont(label, Def.FontPath, Def.LabelSize, nil)
    label:SetJustifyH("LEFT")
    SetTextColor(label, Def.TextColorLabel)
    label:SetText(labelText or "")
    label:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)

    local wrap = CreateFrame("Frame", nil, row)
    wrap:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -4)
    wrap:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    wrap:SetHeight(boxH)
    local paintWrapBg, paintWrapRing = PaintRounded(wrap, Def.ControlRadius, "BACKGROUND", true)
    PaintToken(paintWrapBg, Def.InputBg)

    local scroll = CreateFrame("ScrollFrame", nil, wrap)
    scroll:SetPoint("TOPLEFT", wrap, "TOPLEFT", 4, -4)
    scroll:SetPoint("BOTTOMRIGHT", wrap, "BOTTOMRIGHT", -4, 4)

    local edit = CreateFrame("EditBox", nil, scroll)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetWidth(scroll:GetWidth() or 300)
    SetSafeFont(edit, Def.FontPath, Def.LabelSize, nil)
    local tc = Def.TextColorLabel
    edit:SetTextColor(tc[1], tc[2], tc[3], tc[4] or 1)
    edit:SetMaxLetters(2000)
    scroll:SetScrollChild(edit)

    -- Update width after layout
    C_Timer.After(0, function()
        local w = scroll:GetWidth()
        if w and w > 0 then edit:SetWidth(w) end
    end)

    if readonly then
        edit:SetScript("OnChar", function(self) self:SetText(get and get() or "") end)
        edit:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
        edit:SetScript("OnEditFocusLost", function(self) self:HighlightText(0, 0) end)
    else
        edit:SetScript("OnEditFocusLost", function(self)
            if set then set(self:GetText()) end
        end)
        edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    end

    -- The ring shows only while the box has focus; hooked so the handlers above keep running.
    edit:HookScript("OnEditFocusGained", function() PaintToken(paintWrapRing, Def.FocusRing) end)
    edit:HookScript("OnEditFocusLost", function() paintWrapRing(0, 0, 0, 0) end)

    if opts.storeRef and type(opts.storeRef) == "string" then
        addon[opts.storeRef] = edit
    end

    function row:Refresh()
        if get then edit:SetText(get() or "") end
    end
    row:Refresh()
    ApplyRowHoverHighlight(row)
    ApplyOptionTooltip(row, opts.tooltip)
    return row
end

-- Blacklist grid: shows quests the player has hidden; each row has a name and an Unblock button.
function _G.OptionsWidgets_CreateBlacklistGrid(parent, labelText, opts)
    opts = opts or {}
    local container = CreateFrame("Frame", nil, parent)
    local BLACKLIST_HEADER_H = 34  -- label + gap (desc in tooltip)
    container:SetHeight(BLACKLIST_HEADER_H + 20)
    container.searchText = ((labelText or "") .. " " .. (opts.desc or "") .. " blacklist hidden quests"):lower()

    local label = container:CreateFontString(nil, "OVERLAY")
    SetSafeFont(label, Def.FontPath, Def.LabelSize, nil)
    label:SetJustifyH("LEFT")
    SetTextColor(label, Def.TextColorLabel)
    label:SetText(labelText or "")
    label:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)

    local desc = container:CreateFontString(nil, "OVERLAY")
    SetSafeFont(desc, Def.FontPath, Def.SectionSize, nil)
    desc:SetJustifyH("LEFT")
    SetTextColor(desc, Def.TextColorSection)
    desc:SetText("")
    desc:Hide()
    desc:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)
    desc:SetPoint("RIGHT", container, "RIGHT", 0, 0)
    desc:SetWordWrap(true)

    local listFrame = CreateFrame("Frame", nil, container)
    listFrame:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -10)
    listFrame:SetPoint("RIGHT", container, "RIGHT", 0, 0)
    listFrame:SetHeight(1)

    -- Pooled rows: WoW never GCs CreateFrame objects, so creating fresh rows on every Rebuild()
    -- (fired on each unblock click and on dashboard refresh sweeps) would leak unboundedly.
    -- Rows are reused; each row's unblock button reads row._questID, re-pointed every Rebuild.
    local BLACKLIST_ROW_H    = 24
    local BLACKLIST_ROW_STEP = 28
    local BLACKLIST_EMPTY_H  = 20
    local rowPool = {}
    local emptyRow

    local Rebuild   -- forward declaration (doUnblock calls it)

    local function doUnblock(questID)
        if addon.GetDB then
            local bl = addon.GetDB("questBlacklist", nil)
            if bl and type(bl) == "table" then
                bl[questID] = nil
                if next(bl) == nil then bl = nil end
                if addon.SetDB then addon.SetDB("questBlacklist", bl) end
            end
        end
        Rebuild()
        if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
    end

    local function acquireRow(i)
        local row = rowPool[i]
        if row then return row end
        row = CreateFrame("Frame", nil, listFrame)
        row:SetHeight(BLACKLIST_ROW_H)
        local nameLbl = row:CreateFontString(nil, "OVERLAY")
        SetSafeFont(nameLbl, Def.FontPath, Def.LabelSize, nil)
        SetTextColor(nameLbl, Def.TextColorLabel)
        nameLbl:SetPoint("LEFT", row, "LEFT", 0, 0)
        nameLbl:SetJustifyH("LEFT")
        row.nameLbl = nameLbl
        local unblockBtn = _G.OptionsWidgets_CreateButton(row, L["UNBLOCK"], function()
            doUnblock(row._questID)
        end, { width = 70, height = 20 })
        unblockBtn:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        rowPool[i] = row
        return row
    end

    function Rebuild()
        for _, row in ipairs(rowPool) do row:Hide() end
        if emptyRow then emptyRow:Hide() end

        local blacklist = addon.GetDB and addon.GetDB("questBlacklist", nil) or nil
        if not blacklist or type(blacklist) ~= "table" or next(blacklist) == nil then
            if not emptyRow then
                emptyRow = CreateFrame("Frame", nil, listFrame)
                emptyRow:SetHeight(BLACKLIST_EMPTY_H)
                emptyRow:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 0, 0)
                emptyRow:SetPoint("RIGHT", listFrame, "RIGHT", 0, 0)
                local emptyLabel = emptyRow:CreateFontString(nil, "OVERLAY")
                SetSafeFont(emptyLabel, Def.FontPath, Def.SectionSize, nil)
                SetTextColor(emptyLabel, Def.TextColorSection)
                emptyLabel:SetText(L["HIDDEN_QUESTS"])
                emptyLabel:SetPoint("TOPLEFT", emptyRow, "TOPLEFT", 0, 0)
            end
            emptyRow:Show()
            listFrame:SetHeight(BLACKLIST_EMPTY_H)
            container:SetHeight(BLACKLIST_HEADER_H + BLACKLIST_EMPTY_H)
            return
        end

        local i = 0
        local yOff = 0
        for questID, questName in pairs(blacklist) do
            i = i + 1
            local row = acquireRow(i)
            row._questID = questID
            local displayName = (type(questName) == "string" and questName ~= "" and questName ~= "true") and questName or ("Quest #" .. tostring(questID))
            row.nameLbl:SetText(displayName)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 0, yOff)
            row:SetPoint("RIGHT", listFrame, "RIGHT", 0, 0)
            row:Show()
            yOff = yOff - BLACKLIST_ROW_STEP
        end

        listFrame:SetHeight(-yOff)
        container:SetHeight(BLACKLIST_HEADER_H + (-yOff))
    end

    function container:Refresh()
        Rebuild()
    end
    Rebuild()
    local effectiveTooltip = JoinTooltip(opts.desc, opts.tooltip)
    ApplyOptionTooltip(container, effectiveTooltip)
    return container
end

-- Export Def and shared backdrop for panel (font updates, search dropdown)
addon.OptionsWidgetsDef = Def
addon.OptionsWidgetsSectionCardBackdrop = SECTION_CARD_BACKDROP
