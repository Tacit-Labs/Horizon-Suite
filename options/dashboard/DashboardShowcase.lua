--[[
    Horizon Suite - Dashboard showcase helpers and the News page.
    Shared story renderers (hero, featured, card, strip) drawn from the generated story feed
    (DashboardNewsFeed.lua via NewsLogic), and the News page built from them.
    Wired from DashboardHomeWelcome_Init via addon.DashboardShowcase_InitNews(env).
]]

local addon = _G.HorizonSuite
if not addon then return end

local Showcase = {}
addon.Showcase = Showcase

Showcase.HERO_ART = "Interface/AddOns/HorizonSuite/media/dashboard/welcome/hero.png"

local floor, max, min = math.floor, math.max, math.min
local tinsert = table.insert

-- ============================================================================
-- LAYOUT NUMBERS
-- ============================================================================

local PAD = 24               -- inner padding of featured and card panels
local HERO_H = 200           -- minimum hero height; grows if text needs more
local HERO_PAD_X = 28
local HERO_PAD_Y = 24
local HERO_TEXT_FRAC = 0.52  -- text column share of the hero width
local HERO_FADE_FRAC = 0.60  -- gradient overlay share of the hero width
local HERO_MIN_TEXT_W = 260
local FEATURED_H = 150       -- minimum featured height
local FEATURED_IMG_MAX_W = 300
local FEATURED_IMG_FRAC = 0.38
local CARD_GAP = 12          -- gap between the two cards in a row
local CARD_TWO_COL_MIN_W = 560
local BLOCK_GAP = 16         -- vertical gap between rows of blocks
local STRIP_PAD = 14
local STRIP_IMG_W, STRIP_IMG_H = 110, 55
local ART_RATIO = 2          -- story and hero art are 2:1
local TITLE_TO_BODY = 8
local PARA_GAP = 6
local BODY_TO_BUTTON = 16
local BUTTON_H = 28
local LINK_H = 18
local CHIP_H = 20
local BADGE_H = 15
local BADGE_INSET = 12
local BADGE_TITLE_ROOM = 56  -- title width given up so it never runs under the badge
local BODY_R, BODY_G, BODY_B = 0.72, 0.72, 0.76
local BORDER_ALPHA = 0.08
local EMPTY_H = 170

-- Hero art: arcs sit on the right and in the lower half, so crops keep that region.
local HERO_ANCHOR_X, HERO_ANCHOR_Y = 1, 0.7

-- ============================================================================
-- SMALL HELPERS
-- ============================================================================

local function Loc(key, fallback)
    local L = addon.L
    local v = L and L[key]
    if type(v) == "string" and v ~= "" then return v end
    return fallback
end

local function Accent(env)
    if env and env.GetAccentColor then return env.GetAccentColor() end
    return 0.20, 0.80, 0.90
end

local function Lighten(r, g, b, t)
    return r + (1 - r) * t, g + (1 - g) * t, b + (1 - b) * t
end

local function PanelRGBA(env)
    local WDef = addon.OptionsWidgetsDef
    local bg = (WDef and WDef.SectionCardBg) or { 0.09, 0.09, 0.11, 0.96 }
    local mult = (env and env.DASHBOARD_CONTENT_CARD_ALPHA_MULT) or 1
    return bg[1], bg[2], bg[3], min(1, (bg[4] or 1) * mult)
end

local function HeadingRGB()
    if addon.Dashboard_GetHeadingColor then return addon.Dashboard_GetHeadingColor() end
    return 0.98, 0.99, 1.00
end

local function TextHeight(fs)
    if not fs then return 0 end
    local h = fs:GetHeight() or 0
    if h < 1 and fs.GetStringHeight then h = fs:GetStringHeight() or 0 end
    return h
end

local function MakeText(env, parent, text, size, r, g, b, justify)
    local fs
    if env and env.MakeText then
        fs = env.MakeText(parent, text or "", size, r, g, b, justify or "LEFT")
    else
        fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetText(text or "")
        fs:SetTextColor(r, g, b)
        fs:SetJustifyH(justify or "LEFT")
    end
    if fs.SetWordWrap then fs:SetWordWrap(true) end
    if fs.SetJustifyV then fs:SetJustifyV("TOP") end
    return fs
end

-- Rounded fill (Echo.Round on Retail and Forever), else a flat fill.
local function Rounded(frame, radius, withRing)
    if addon.OptionsWidgets_PaintRounded then
        return addon.OptionsWidgets_PaintRounded(frame, radius, "BACKGROUND", withRing)
    end
    local tex = frame:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints(frame)
    tex:SetColorTexture(1, 1, 1, 1)
    return function(r, g, b, a) tex:SetVertexColor(r, g, b, a) end, function() end
end

--- Fill a box with art of the given aspect by cropping (never stretching).
--- @param anchorX number 0 keeps the left edge, 1 the right, 0.5 centres
--- @param anchorY number 0 keeps the top edge, 1 the bottom, 0.5 centres
local function CropFill(tex, boxW, boxH, anchorX, anchorY)
    if not tex or not boxW or not boxH or boxW < 1 or boxH < 1 then
        if tex then tex:SetTexCoord(0, 1, 0, 1) end
        return
    end
    local boxRatio = boxW / boxH
    if boxRatio >= ART_RATIO then
        local frac = ART_RATIO / boxRatio
        local top = (1 - frac) * (anchorY or 0.5)
        tex:SetTexCoord(0, 1, top, top + frac)
    else
        local frac = boxRatio / ART_RATIO
        local left = (1 - frac) * (anchorX or 0.5)
        tex:SetTexCoord(left, left + frac, 0, 1)
    end
end

-- Accent elements: each has :PaintAccent(), run at layout and whenever the dashboard
-- recolours. They live in env.dashAccentRefs.showcaseAccents; detail views wipe
-- cardAccents, and its loop forces alpha 1, so these keep a list of their own.
local function RegisterAccent(env, obj)
    local refs = env and env.dashAccentRefs
    if not refs then return end
    refs.showcaseAccents = refs.showcaseAccents or {}
    tinsert(refs.showcaseAccents, obj)
    if not refs._showcaseAccentHooked and hooksecurefunc and addon.ApplyDashboardClassColor then
        refs._showcaseAccentHooked = true
        hooksecurefunc(addon, "ApplyDashboardClassColor", function()
            for _, o in ipairs(refs.showcaseAccents) do
                if o.PaintAccent then o:PaintAccent() end
            end
        end)
    end
end

local function RootDB()
    local name = addon.DATABASE or "HorizonDB"
    if type(_G[name]) ~= "table" then _G[name] = {} end
    return _G[name]
end

-- ============================================================================
-- ACTIONS
-- ============================================================================

--- Run a story's action. Types: module, patch_notes, guide, dashboard, news, integrations, copy_url.
--- @param f Frame the dashboard frame
--- @param action table|nil
--- @param label string|nil shown in the copy-link dialog for copy_url
function Showcase.DispatchAction(f, action, label)
    f = f or _G.HorizonSuiteDashboard
    if not f or type(action) ~= "table" then return end
    local t = action.type

    if t == "module" then
        local mk = action.moduleKey
        if mk and f.OpenModule then
            local modName = action.moduleName
                or (addon.Dashboard_BrandModule and addon.Dashboard_BrandModule(mk))
                or mk
            f.OpenModule(modName, mk)
        end
    elseif t == "patch_notes" then
        if f.ShowPatchNotes then f.ShowPatchNotes() end
    elseif t == "guide" then
        if f.ShowModuleGuide then f.ShowModuleGuide() end
    elseif t == "dashboard" then
        if f.ShowDashboard then f.ShowDashboard() end
    elseif t == "news" then
        if f.ShowNews then f.ShowNews() end
    elseif t == "integrations" then
        if f.ShowIntegrations then f.ShowIntegrations() end
    elseif t == "copy_url" and action.url then
        if addon.ShowURLCopyBox then
            local fmt = Loc("DASH_COPY_LINK_X", "%s")
            addon.ShowURLCopyBox(action.url, fmt:format(label or action.url))
        end
    end
end

-- ============================================================================
-- BUILDING BLOCKS
-- ============================================================================

--- A story panel: section-card fill and a 1px hairline border. Clips its children.
--- @param parent Frame
--- @param env table|nil dashboard env (for the card alpha multiplier)
--- @param frameType string|nil "Frame" (default) or "Button" for a clickable panel
--- @return Frame
function Showcase.MakePanel(parent, env, frameType)
    local panel = CreateFrame(frameType or "Frame", nil, parent)
    panel:SetFrameLevel((parent:GetFrameLevel() or 0) + 1)
    if panel.SetClipsChildren then panel:SetClipsChildren(true) end

    local r, g, b, a = PanelRGBA(env)
    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(r, g, b, a)
    panel._bg = bg

    local function Edge(p1, p2, horizontal)
        local e = panel:CreateTexture(nil, "OVERLAY", nil, 7)
        e:SetColorTexture(1, 1, 1, BORDER_ALPHA)
        e:SetPoint(p1)
        e:SetPoint(p2)
        if horizontal then e:SetHeight(1) else e:SetWidth(1) end
        return e
    end
    panel._edges = {
        Edge("TOPLEFT", "TOPRIGHT", true),
        Edge("BOTTOMLEFT", "BOTTOMRIGHT", true),
        Edge("TOPLEFT", "BOTTOMLEFT", false),
        Edge("TOPRIGHT", "BOTTOMRIGHT", false),
    }
    return panel
end

--- An accent button. Filled: rounded accent fill with a ring. Not filled: a text link.
--- Hover handlers sit on the button itself.
--- @return Button with :SetLabel(text), :PaintAccent(), and :SetOnClick(fn)
function Showcase.MakeButton(parent, env, label, filled)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetFrameLevel((parent:GetFrameLevel() or 0) + 3)
    btn._env = env
    btn._filled = filled and true or false
    btn:SetHeight(filled and BUTTON_H or LINK_H)

    if filled then
        btn._paint, btn._paintRing = Rounded(btn, 6, true)
        btn._label = MakeText(env, btn, "", 12, 1, 1, 1, "CENTER")
        btn._label:SetPoint("CENTER", btn, "CENTER", 0, 0)
    else
        btn._label = MakeText(env, btn, "", 12, 1, 1, 1, "LEFT")
        btn._label:SetPoint("LEFT", btn, "LEFT", 0, 0)
        local underline = btn:CreateTexture(nil, "OVERLAY")
        underline:SetHeight(1)
        underline:SetPoint("TOPLEFT", btn._label, "BOTTOMLEFT", 0, -1)
        underline:SetPoint("TOPRIGHT", btn._label, "BOTTOMRIGHT", 0, -1)
        underline:Hide()
        btn._underline = underline
    end
    if btn._label.SetWordWrap then btn._label:SetWordWrap(false) end

    function btn:SetLabel(text)
        self._text = text or ""
        self._label:SetText(self._text)
        local tw = self._label:GetStringWidth() or 0
        if self._filled then
            self:SetWidth(max(96, floor(tw + 36 + 0.5)))
        else
            self:SetWidth(max(24, floor(tw + 4 + 0.5)))
        end
    end

    function btn:PaintAccent()
        local r, g, b = Accent(self._env)
        local hover = self._hover
        if self._filled then
            self._paint(r, g, b, hover and 0.36 or 0.22)
            if self._paintRing then self._paintRing(r, g, b, hover and 0.75 or 0.45) end
            self._label:SetTextColor(Lighten(r, g, b, hover and 0.85 or 0.65))
        else
            self._label:SetTextColor(Lighten(r, g, b, hover and 0.65 or 0.35))
            self._underline:SetColorTexture(r, g, b, 0.75)
            if hover then self._underline:Show() else self._underline:Hide() end
        end
    end

    function btn:SetOnClick(fn) self._onClick = fn end

    btn:SetScript("OnEnter", function(self) self._hover = true; self:PaintAccent() end)
    btn:SetScript("OnLeave", function(self) self._hover = false; self:PaintAccent() end)
    btn:SetScript("OnClick", function(self) if self._onClick then self._onClick() end end)

    RegisterAccent(env, btn)
    btn:SetLabel(label)
    btn:PaintAccent()
    return btn
end

-- The "New" pill: the sidebar row badge's look (accent at 0.24 over the panel), painted
-- opaque so it reads the same over art. Not mouse-enabled.
local function MakeBadge(parent, env)
    local bd = CreateFrame("Frame", nil, parent)
    bd:SetHeight(BADGE_H)
    bd:SetFrameLevel((parent:GetFrameLevel() or 0) + 4)
    bd._env = env
    bd._paint = Rounded(bd, 7, false)
    bd._text = MakeText(env, bd, Loc("DASH_NEWS_BADGE_NEW", "New"), 9, 1, 1, 1, "CENTER")
    bd._text:SetWordWrap(false)
    bd._text:SetPoint("CENTER", bd, "CENTER", 0, 0)
    function bd:PaintAccent()
        local r, g, b = Accent(self._env)
        local pr, pg, pb = PanelRGBA(self._env)
        self._paint(pr + (r - pr) * 0.24, pg + (g - pg) * 0.24, pb + (b - pb) * 0.24, 1)
        self._text:SetTextColor(Lighten(r, g, b, 0.55))
        self:SetWidth(math.ceil((self._text:GetStringWidth() or 20) + 12))
    end
    RegisterAccent(env, bd)
    bd:PaintAccent()
    bd:Hide()
    return bd
end

-- The hero's version chip: a rounded accent pill with "6.6.0 · 5 October 2026".
local function MakeChip(parent, env)
    local chip = CreateFrame("Frame", nil, parent)
    chip:SetHeight(CHIP_H)
    chip:SetFrameLevel((parent:GetFrameLevel() or 0) + 2)
    chip._env = env
    chip._paint, chip._paintRing = Rounded(chip, 9, true)
    chip._text = MakeText(env, chip, "", 10, 1, 1, 1, "CENTER")
    chip._text:SetWordWrap(false)
    chip._text:SetPoint("CENTER", chip, "CENTER", 0, 0)
    function chip:SetLabel(text)
        self._text:SetText(text or "")
        self:SetWidth(math.ceil((self._text:GetStringWidth() or 40) + 20))
    end
    function chip:PaintAccent()
        local r, g, b = Accent(self._env)
        self._paint(r, g, b, 0.16)
        if self._paintRing then self._paintRing(r, g, b, 0.40) end
        self._text:SetTextColor(Lighten(r, g, b, 0.6))
    end
    RegisterAccent(env, chip)
    chip:PaintAccent()
    return chip
end

-- Shared with the Welcome page (DashboardWelcomeShowcase.lua).
Showcase.Accent = Accent
Showcase.Lighten = Lighten
Showcase.PanelRGBA = PanelRGBA
Showcase.HeadingRGB = HeadingRGB
Showcase.TextHeight = TextHeight
Showcase.MakeText = MakeText
Showcase.Rounded = Rounded
Showcase.CropFill = CropFill
Showcase.RegisterAccent = RegisterAccent
Showcase.RootDB = RootDB
Showcase.MakeChip = MakeChip
Showcase.BODY_RGB = { BODY_R, BODY_G, BODY_B }

-- ============================================================================
-- STORIES
-- ============================================================================

local function StoryParagraphs(story, limit)
    local out = {}
    local src = (story and story.paragraphs) or {}
    for i = 1, #src do
        if limit and #out >= limit then break end
        if type(src[i]) == "string" and src[i] ~= "" then out[#out + 1] = src[i] end
    end
    return out
end

local function IsUnseen(env, story)
    if not story or story.isRelease then return false end
    local seen = env and env.newsSeen
    return not (seen and seen[story.id])
end

-- Ensure the block has one body FontString per paragraph; place them from y down.
-- @return number y below the last paragraph (y unchanged when there are none)
local function LayoutParagraphs(block, paras, x, y, width, size, maxLines)
    block._paras = block._paras or {}
    local placed = 0
    for i = 1, #paras do
        local fs = block._paras[i]
        if not fs then
            fs = MakeText(block._env, block, "", size, BODY_R, BODY_G, BODY_B, "LEFT")
            if fs.SetSpacing then fs:SetSpacing(3) end
            block._paras[i] = fs
        end
        if maxLines and fs.SetMaxLines then fs:SetMaxLines(maxLines) end
        fs:SetWidth(max(1, width))
        fs:SetText(paras[i])
        fs:ClearAllPoints()
        fs:SetPoint("TOPLEFT", block, "TOPLEFT", x, -y)
        fs:Show()
        y = y + TextHeight(fs) + PARA_GAP
        placed = placed + 1
    end
    for i = #paras + 1, #block._paras do block._paras[i]:Hide() end
    if placed > 0 then y = y - PARA_GAP end
    return y
end

local function PlaceTitle(block, x, y, width)
    local fs = block._title
    local w = width
    if block._badge:IsShown() then w = w - BADGE_TITLE_ROOM end
    fs:SetWidth(max(1, w))
    fs:SetText(block.story.title or "")
    fs:SetTextColor(HeadingRGB())
    fs:ClearAllPoints()
    fs:SetPoint("TOPLEFT", block, "TOPLEFT", x, -y)
    return y + TextHeight(fs)
end

local function RefreshBadge(block)
    local bd = block._badge
    if IsUnseen(block._env, block.story) then
        bd:PaintAccent()
        bd:ClearAllPoints()
        bd:SetPoint("TOPRIGHT", block, "TOPRIGHT", -BADGE_INSET, -BADGE_INSET)
        bd:Show()
    else
        bd:Hide()
    end
end

-- Show the button when the story has a label and an action. @return boolean shown
local function RefreshButton(block, label)
    local btn = block._button
    local story = block.story
    label = label or story.button
    if not (label and label ~= "" and type(story.action) == "table") then
        btn:Hide()
        return false
    end
    btn:SetLabel(label)
    btn:PaintAccent()
    btn:Show()
    return true
end

local function SetArt(block, path)
    local art = block._art
    if type(path) == "string" and path ~= "" then
        art:SetTexture(path)
        art:Show()
        return true
    end
    art:Hide()
    return false
end

local LAYOUT = {}

function LAYOUT.hero(block, width)
    local story = block.story
    SetArt(block, Showcase.HERO_ART)

    local textW = floor(width * HERO_TEXT_FRAC) - HERO_PAD_X
    if textW < HERO_MIN_TEXT_W then textW = width - HERO_PAD_X * 2 end
    local x, y = HERO_PAD_X, HERO_PAD_Y

    local dateStr = addon.PatchNotes_FormatIsoDateLongUK and addon.PatchNotes_FormatIsoDateLongUK(story.date)
    local chipText = story.version or ""
    if dateStr then chipText = (chipText ~= "" and (chipText .. "  \194\183  ") or "") .. dateStr end
    local chip = block._chip
    if chipText ~= "" then
        chip:SetLabel(chipText)
        chip:PaintAccent()
        chip:ClearAllPoints()
        chip:SetPoint("TOPLEFT", block, "TOPLEFT", x, -y)
        chip:Show()
        y = y + CHIP_H + 12
    else
        chip:Hide()
    end

    y = PlaceTitle(block, x, y, textW) + TITLE_TO_BODY
    y = LayoutParagraphs(block, StoryParagraphs(story, 2), x, y, textW, 12)

    local btn = block._button
    if RefreshButton(block) then
        y = y + BODY_TO_BUTTON
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", block, "TOPLEFT", x, -y)
        y = y + BUTTON_H
    end
    local h = max(HERO_H, floor(y + HERO_PAD_Y + 0.5))

    local art = block._art
    art:ClearAllPoints()
    art:SetAllPoints(block)
    CropFill(art, width, h, HERO_ANCHOR_X, HERO_ANCHOR_Y)
    local fade = block._fade
    fade:ClearAllPoints()
    fade:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
    fade:SetPoint("BOTTOMLEFT", block, "BOTTOMLEFT", 0, 0)
    fade:SetWidth(max(1, floor(width * HERO_FADE_FRAC)))
    return h
end

function LAYOUT.featured(block, width)
    local story = block.story
    local hasArt = SetArt(block, story.image)
    local imgW = hasArt and min(FEATURED_IMG_MAX_W, floor(width * FEATURED_IMG_FRAC)) or 0
    local x = imgW + PAD
    local textW = width - x - PAD
    local y = PAD - 2

    y = PlaceTitle(block, x, y, textW) + TITLE_TO_BODY
    y = LayoutParagraphs(block, StoryParagraphs(story), x, y, textW, 12)
    local btn = block._button
    if RefreshButton(block) then
        y = y + BODY_TO_BUTTON
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", block, "TOPLEFT", x, -y)
        y = y + BUTTON_H
    end
    local h = max(FEATURED_H, floor(y + PAD - 2 + 0.5))

    if hasArt then
        local art = block._art
        art:ClearAllPoints()
        art:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
        art:SetSize(imgW, h)
        CropFill(art, imgW, h, 0.5, 0.5)
    end
    return h
end

function LAYOUT.card(block, width)
    local story = block.story
    local hasArt = SetArt(block, story.image)
    local imgH = hasArt and floor(width / ART_RATIO + 0.5) or 0
    if hasArt then
        local art = block._art
        art:ClearAllPoints()
        art:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
        art:SetSize(width, imgH)
        art:SetTexCoord(0, 1, 0, 1)
    end
    local x = PAD - 4
    local textW = width - x * 2
    local y = imgH + PAD - 6

    y = PlaceTitle(block, x, y, textW) + TITLE_TO_BODY
    y = LayoutParagraphs(block, StoryParagraphs(story, 1), x, y, textW, 12)
    local btn = block._button
    -- The button sits on the bottom edge, so cards stretched to a shared row height line up.
    if RefreshButton(block) then
        y = y + BODY_TO_BUTTON + BUTTON_H
        btn:ClearAllPoints()
        btn:SetPoint("BOTTOMLEFT", block, "BOTTOMLEFT", x, PAD - 6)
    end
    return floor(y + PAD - 6 + 0.5)
end

function LAYOUT.strip(block, width)
    local story = block.story
    local hasArt = SetArt(block, story.image)
    if hasArt then
        local art = block._art
        art:ClearAllPoints()
        art:SetPoint("TOPLEFT", block, "TOPLEFT", STRIP_PAD, -STRIP_PAD)
        art:SetSize(STRIP_IMG_W, STRIP_IMG_H)
        CropFill(art, STRIP_IMG_W, STRIP_IMG_H, 0.5, 0.5)
    end
    local x = hasArt and (STRIP_PAD * 2 + STRIP_IMG_W) or STRIP_PAD
    local textW = width - x - STRIP_PAD
    local y = STRIP_PAD - 2

    block._title:SetWordWrap(false)
    y = PlaceTitle(block, x, y, textW) + 4
    y = LayoutParagraphs(block, StoryParagraphs(story, 1), x, y, textW, 11, 2)

    -- "Read more" runs the story's action; a story without one opens News.
    local btn = block._button
    btn:SetLabel(Loc("DASH_NEWS_READ_MORE", "Read more"))
    btn:PaintAccent()
    btn:ClearAllPoints()
    btn:SetPoint("TOPLEFT", block, "TOPLEFT", x, -(y + 6))
    btn:Show()
    y = y + 6 + LINK_H
    local imgBottom = hasArt and (STRIP_PAD * 2 + STRIP_IMG_H) or 0
    return floor(max(imgBottom, y + STRIP_PAD) + 0.5)
end

--- Build one story block.
--- @param parent Frame
--- @param env table dashboard env; env.newsSeen (story id -> true) drives the New badge
--- @param story table a NewsLogic feed entry
--- @param style string "hero" | "featured" | "card" | "strip"
--- @return Frame block with .story, .style and :Layout(width) -> height
function Showcase.MakeStory(parent, env, story, style)
    style = LAYOUT[style] and style or "card"
    local block = Showcase.MakePanel(parent, env)
    block._env = env
    block.story = story
    block.style = style

    local art = block:CreateTexture(nil, "ARTWORK", nil, 0)
    art:Hide()
    block._art = art

    if style == "hero" then
        local pr, pg, pb = PanelRGBA(env)
        local fade = block:CreateTexture(nil, "ARTWORK", nil, 2)
        fade:SetColorTexture(1, 1, 1, 1)
        if CreateColor and fade.SetGradient then
            fade:SetGradient("HORIZONTAL", CreateColor(pr, pg, pb, 1), CreateColor(pr, pg, pb, 0))
        elseif fade.SetGradientAlpha then
            fade:SetGradientAlpha("HORIZONTAL", pr, pg, pb, 1, pr, pg, pb, 0)
        else
            fade:SetColorTexture(pr, pg, pb, 0.6)
        end
        block._fade = fade
        block._chip = MakeChip(block, env)
    end

    local titleSize = (style == "hero" and 20) or (style == "featured" and 16) or (style == "strip" and 13) or 15
    block._title = MakeText(env, block, "", titleSize, HeadingRGB())
    if block._title.SetMaxLines and style ~= "hero" then block._title:SetMaxLines(2) end
    if env and env.dashAccentRefs and env.dashAccentRefs.headingTexts then
        tinsert(env.dashAccentRefs.headingTexts, block._title)
    end

    block._badge = MakeBadge(block, env)
    block._button = Showcase.MakeButton(block, env, "", style ~= "strip")
    block._button:SetOnClick(function()
        local s = block.story
        if not s then return end
        local action = s.action
        if style == "strip" and type(action) ~= "table" then action = { type = "news" } end
        Showcase.DispatchAction(env and env.f, action, s.button or s.title)
    end)

    local layoutFn = LAYOUT[style]
    function block:Layout(width)
        width = max(1, floor(width or self:GetWidth() or 1))
        self:SetWidth(width)
        RefreshBadge(self)
        local h = layoutFn(self, width)
        self:SetHeight(max(1, h))
        return h
    end
    return block
end

-- ============================================================================
-- SIDEBAR BADGE
-- ============================================================================

local newsViewRef

--- Show "New" on the News sidebar row while any visible story is unseen.
function addon.News_RefreshSidebarBadge()
    local dash = _G.HorizonSuiteDashboard
    local NL = addon.NewsLogic
    if not (dash and dash.newsSidebarBtn and NL and addon.DashboardSidebar_SetRowBadge) then return end
    local feed = NL.CurrentFeed()
    local seen = NL.EnsureSeen(RootDB(), feed)
    local text = (NL.UnseenCount(feed, seen) > 0) and Loc("DASH_NEWS_BADGE_NEW", "New") or nil
    addon.DashboardSidebar_SetRowBadge(dash.newsSidebarBtn, text, "accent")
end

--- Mark every visible story seen (opening News). Story badges keep the snapshot taken
--- when the page opened, so they clear on the next open.
function addon.News_MarkAllSeen()
    local NL = addon.NewsLogic
    if not NL then return end
    local feed = NL.CurrentFeed()
    -- Snapshot first: the entry path shows News before its frame is shown, so OnShow can't.
    if newsViewRef and newsViewRef._takeSeenSnapshot then newsViewRef._takeSeenSnapshot(feed) end
    NL.MarkSeen(feed, NL.EnsureSeen(RootDB(), feed))
    addon.News_RefreshSidebarBadge()
    if newsViewRef and newsViewRef:IsShown() and newsViewRef._layoutWelcomeContent then
        newsViewRef._layoutWelcomeContent()
    end
end

-- ============================================================================
-- NEWS PAGE
-- ============================================================================

local function MakeEmptyBlock(parent, env)
    local block = Showcase.MakePanel(parent, env)
    block._title = MakeText(env, block, Loc("DASH_NEWS_EMPTY_TITLE", "No news right now"), 16, HeadingRGB())
    block._title:SetJustifyH("CENTER")
    if env and env.dashAccentRefs and env.dashAccentRefs.headingTexts then
        tinsert(env.dashAccentRefs.headingTexts, block._title)
    end
    block._body = MakeText(env, block, Loc("DASH_NEWS_EMPTY_BODY", ""), 12, BODY_R, BODY_G, BODY_B, "CENTER")
    block._body:SetJustifyH("CENTER")
    block._button = Showcase.MakeButton(block, env, Loc("DASH_NEWS_RELEASE_BUTTON", "Patch notes"), true)
    block._button:SetOnClick(function()
        Showcase.DispatchAction(env and env.f, { type = "patch_notes" }, nil)
    end)
    function block:Layout(width)
        self:SetWidth(width)
        local textW = max(1, width - PAD * 2)
        self._title:SetWidth(textW)
        self._title:SetTextColor(HeadingRGB())
        self._body:SetWidth(textW)
        self._button:SetLabel(Loc("DASH_NEWS_RELEASE_BUTTON", "Patch notes"))
        self._button:PaintAccent()
        local contentH = TextHeight(self._title) + TITLE_TO_BODY + TextHeight(self._body) + BODY_TO_BUTTON + BUTTON_H
        local h = max(EMPTY_H, floor(contentH + PAD * 2 + 0.5))
        local y = floor((h - contentH) / 2)
        self._title:ClearAllPoints()
        self._title:SetPoint("TOP", self, "TOP", 0, -y)
        y = y + TextHeight(self._title) + TITLE_TO_BODY
        self._body:ClearAllPoints()
        self._body:SetPoint("TOP", self, "TOP", 0, -y)
        y = y + TextHeight(self._body) + BODY_TO_BUTTON
        self._button:ClearAllPoints()
        self._button:SetPoint("TOP", self, "TOP", 0, -y)
        self:SetHeight(h)
        return h
    end
    return block
end

--- Build the News page into env.newsView: the release story as a hero, then featured
--- stories at full width, then cards two to a row, then the community footer.
--- @param env table DashboardHomeWelcome_Init env (f, addon, L, newsView, dashScrollTopOffset,
---   dashAccentRefs, GetAccentColor, MakeText, DASHBOARD_CONTENT_CARD_ALPHA_MULT)
function addon.DashboardShowcase_InitNews(env)
    local newsView = env and env.newsView
    if not newsView then return end
    newsViewRef = newsView
    local L = env.L
    local dashAccentRefs = env.dashAccentRefs
    local dashScrollTopOffset = env.dashScrollTopOffset or -130
    local NL = addon.NewsLogic

    -- Stories read env.newsSeen; keep the snapshot on a child env, not the shared one.
    local storyEnv = setmetatable({}, { __index = env })

    -- Same frame as the Welcome page: an anchor texture, a footer panel, a smooth scroll.
    local BG_TOP_NUDGE = 50
    local CONTENT_TOP_PAD = 6
    local SCROLL_TO_BG_INSET = 20
    local SCROLL_ABOVE_FOOTER_GAP = (addon.DashboardConstants and addon.DashboardConstants.COMMUNITY_FOOTER_SCROLL_GAP) or 24

    local newsBg = newsView:CreateTexture(nil, "BACKGROUND")
    newsBg:SetPoint("TOPLEFT", 28, dashScrollTopOffset + BG_TOP_NUDGE)
    newsBg:SetPoint("BOTTOMRIGHT", newsView, "BOTTOMRIGHT", -28, 20)

    local footerPanel = CreateFrame("Frame", nil, newsView)
    footerPanel:SetFrameLevel((newsView:GetFrameLevel() or 0) + 10)

    local scroll = CreateFrame("ScrollFrame", nil, newsView, "UIPanelScrollFrameTemplate")
    scroll:SetFrameLevel((newsView:GetFrameLevel() or 0) + 2)
    if scroll.ScrollBar then
        scroll.ScrollBar:Hide()
        scroll.ScrollBar:ClearAllPoints()
    end

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(400, 1)
    scroll:SetScrollChild(content)
    if addon.Dashboard_ApplySmoothScroll then
        addon.Dashboard_ApplySmoothScroll(scroll, content, 60, true)
    end
    newsView._scrollContent = content

    local footerObj
    if addon.Dashboard_CreateCommunityFooter then
        footerObj = addon.Dashboard_CreateCommunityFooter(footerPanel, {
            L = L,
            GetAccentColor = env.GetAccentColor,
            MakeText = env.MakeText,
            addon = addon,
        })
        if footerObj and footerObj.footerTopRule and dashAccentRefs and dashAccentRefs.communityFooterTopRules then
            tinsert(dashAccentRefs.communityFooterTopRules, footerObj.footerTopRule)
        end
    end

    local blocks = {}   -- story id -> block
    local emptyBlock

    local function TakeSeenSnapshot(feed)
        local snap = {}
        if NL then
            for id, v in pairs(NL.EnsureSeen(RootDB(), feed)) do snap[id] = v end
        end
        storyEnv.newsSeen = snap
    end
    newsView._takeSeenSnapshot = TakeSeenSnapshot

    local function GetBlock(story, style)
        local b = blocks[story.id]
        if b and b.style ~= style then
            b:Hide()
            b = nil
        end
        if not b then
            b = Showcase.MakeStory(content, storyEnv, story, style)
            blocks[story.id] = b
        end
        b.story = story
        return b
    end

    local function Layout()
        local w = max(280, (newsBg:GetWidth() or 0) - 40)
        local wFooter = max(280, (newsView:GetWidth() or 0) - 40)

        if footerObj and footerObj.layout then
            footerObj.layout(wFooter, 0, newsView)
            scroll:ClearAllPoints()
            scroll:SetPoint("TOPLEFT", newsBg, "TOPLEFT", SCROLL_TO_BG_INSET, -CONTENT_TOP_PAD)
            scroll:SetPoint("TOPRIGHT", newsBg, "TOPRIGHT", -SCROLL_TO_BG_INSET, -CONTENT_TOP_PAD)
            scroll:SetPoint("BOTTOMLEFT", footerPanel, "TOPLEFT", 0, SCROLL_ABOVE_FOOTER_GAP)
            scroll:SetPoint("BOTTOMRIGHT", footerPanel, "TOPRIGHT", 0, SCROLL_ABOVE_FOOTER_GAP)
        else
            scroll:ClearAllPoints()
            scroll:SetPoint("TOPLEFT", newsBg, "TOPLEFT", SCROLL_TO_BG_INSET, -CONTENT_TOP_PAD)
            scroll:SetPoint("BOTTOMRIGHT", newsBg, "BOTTOMRIGHT", -SCROLL_TO_BG_INSET, 20)
        end
        content:SetWidth(w)

        local feed = NL and NL.CurrentFeed() or {}
        if not storyEnv.newsSeen then TakeSeenSnapshot(feed) end

        local release, featured, cards = nil, {}, {}
        for i = 1, #feed do
            local s = feed[i]
            if s.isRelease then
                release = release or s
            elseif s.layout == "card" then
                cards[#cards + 1] = s
            else
                featured[#featured + 1] = s
            end
        end

        local active = {}
        local y = 0
        local function Place(story, style, x, width)
            local b = GetBlock(story, style)
            local h = b:Layout(width)
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", content, "TOPLEFT", x, -y)
            b:Show()
            active[story.id] = true
            return b, h
        end

        if release then
            local _, h = Place(release, "hero", 0, w)
            y = y + h + BLOCK_GAP
        end
        for i = 1, #featured do
            local _, h = Place(featured[i], "featured", 0, w)
            y = y + h + BLOCK_GAP
        end
        if w >= CARD_TWO_COL_MIN_W then
            local cw = floor((w - CARD_GAP) / 2)
            for i = 1, #cards, 2 do
                local left, hl = Place(cards[i], "card", 0, cw)
                local rowH = hl
                if cards[i + 1] then
                    local right, hr = Place(cards[i + 1], "card", cw + CARD_GAP, cw)
                    rowH = max(hl, hr)
                    right:SetHeight(rowH)
                end
                left:SetHeight(rowH)
                y = y + rowH + BLOCK_GAP
            end
        else
            for i = 1, #cards do
                local _, h = Place(cards[i], "card", 0, w)
                y = y + h + BLOCK_GAP
            end
        end

        if #feed == 0 then
            emptyBlock = emptyBlock or MakeEmptyBlock(content, storyEnv)
            local h = emptyBlock:Layout(w)
            emptyBlock:ClearAllPoints()
            emptyBlock:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
            emptyBlock:Show()
            y = y + h + BLOCK_GAP
        elseif emptyBlock then
            emptyBlock:Hide()
        end

        for id, b in pairs(blocks) do
            if not active[id] then b:Hide() end
        end

        content:SetHeight(max(y - BLOCK_GAP + 8, 1))

        if scroll.UpdateScrollChildRect then scroll:UpdateScrollChildRect() end
        local maxScroll = max(0, (content:GetHeight() or 0) - (scroll:GetHeight() or 0))
        if (scroll:GetVerticalScroll() or 0) > maxScroll then
            scroll:SetVerticalScroll(maxScroll)
            scroll.targetScroll = nil
        end
    end

    -- DashboardFrame's resize pass calls this name on the welcome and news views.
    newsView._layoutWelcomeContent = Layout

    newsView:SetScript("OnShow", function()
        Layout()
        if C_Timer and C_Timer.After then
            C_Timer.After(0, Layout)
            C_Timer.After(0.05, Layout)
        end
    end)
    newsView:SetScript("OnSizeChanged", function()
        if newsView:IsShown() then Layout() end
    end)
end
