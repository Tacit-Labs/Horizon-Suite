--[[
    Horizon Suite - Dashboard Welcome page: a one-screen showcase.
    Hero, module tiles, a news strip and a credits footer, drawn in the order of
    addon.DashboardWelcomeFeed (DashboardWelcomeFeedData.lua) with the shared helpers in
    DashboardShowcase.lua. Wired from DashboardHomeWelcome_Init via
    addon.DashboardShowcase_InitWelcome(env).
]]

local addon = _G.HorizonSuite
if not addon then return end

local floor, max, min = math.floor, math.max, math.min
local tinsert = table.insert

-- ============================================================================
-- LAYOUT NUMBERS
-- ============================================================================

-- Target sizes: 180 + 20 + (2 x 140 + 10) + 100 + 28 + 4 x 14 = 674.
local GAP = 14
local HERO_H = 180
local LABEL_H = 20
local TILE_H = 140
local TILE_GAP = 10
local TILE_COLS = 4
local NEWS_H = 100
local CREDITS_H = 28
-- When the view is shorter than the targets, gaps shrink first, then the hero, then tiles.
local GAP_MIN = 10
local TILE_MIN_H = 112
local HERO_MIN_H = 150

local HERO_PAD_X = 28
local HERO_PAD_Y = 18
local HERO_ART_FRAC = 0.55   -- art share of the hero width (right side)
local HERO_FADE_FRAC = 0.45  -- fade share of the art width, from the art's left edge
local HERO_TEXT_FRAC = 0.5
local HERO_MIN_TEXT_W = 260
local HERO_ANCHOR_X, HERO_ANCHOR_Y = 1, 0.7
local HERO_CHIP_H = 20
local BUTTON_H = 28

local TILE_STRIP_H = 4
local TILE_TEXT_BAND = 44
local TILE_PAD = 10
local TILE_ICON = 40
local TILE_CHIP_H = 16
local TILE_BORDER_ALPHA = 0.08
local TILE_HOVER_BORDER_ALPHA = 0.6
local TILE_OFF_STRIP_ALPHA = 0.35
local TILE_PLACEHOLDER_ALPHA = 0.12
local OPEN_FADE = 0.12

local NEWS_SIDE_GAP = 10
local NEWS_PANEL_PAD = 12
local NEWS_ROW_H = 18

local LINK_GAP = 16
local MUTED_R, MUTED_G, MUTED_B = 0.62, 0.65, 0.70

-- The page sits just under the header subtitle; Welcome has no search bar.
local BG_TOP_NUDGE = 65
local BG_BOTTOM_INSET = 12
local SCROLL_TO_BG_INSET = 20

local TILE_ART_DIR = "Interface/AddOns/HorizonSuite/media/dashboard/welcome/tiles/"
local INTEGRATIONS_ICON = "INV_Misc_Gear_08"
local FOOTER_LINK_IDS = { "discord", "github", "kofi", "patreon" }

-- ============================================================================
-- HELPERS
-- ============================================================================

local function Loc(key, fallback)
    local L = addon.L
    local v = L and L[key]
    if type(v) == "string" and v ~= "" then return v end
    return fallback
end

local function TrackHeading(env, fs)
    local refs = env and env.dashAccentRefs
    if refs and refs.headingTexts then tinsert(refs.headingTexts, fs) end
end

local function SingleLine(fs)
    if fs.SetWordWrap then fs:SetWordWrap(false) end
    if fs.SetJustifyV then fs:SetJustifyV("MIDDLE") end
    return fs
end

local function Hex(r, g, b)
    return ("%02x%02x%02x"):format(floor(r * 255 + 0.5), floor(g * 255 + 0.5), floor(b * 255 + 0.5))
end

-- A filled MakeButton repainted as an outline: ring only, faint fill on hover.
local function MakeOutline(S, btn)
    local rounded = addon.OptionsWidgets_PaintRounded ~= nil
    function btn:PaintAccent()
        local r, g, b = S.Accent(self._env)
        local hover = self._hover
        local fill = rounded and (hover and 0.14 or 0) or (hover and 0.22 or 0.10)
        self._paint(r, g, b, fill)
        if self._paintRing then self._paintRing(r, g, b, hover and 0.85 or 0.50) end
        self._label:SetTextColor(S.Lighten(r, g, b, hover and 0.85 or 0.65))
    end
    btn:PaintAccent()
    return btn
end

-- Cap a link button's width so long story titles truncate instead of spilling.
local function FitLink(btn, text, maxW)
    btn._label:SetWidth(0)
    btn:SetLabel(text)
    btn:PaintAccent()
    if (btn:GetWidth() or 0) > maxW then
        btn:SetWidth(max(24, maxW))
        btn._label:SetWidth(max(20, maxW - 4))
    end
end

-- ============================================================================
-- HERO
-- ============================================================================

local function BuildHero(S, env, parent)
    local hero = S.MakePanel(parent, env)

    local art = hero:CreateTexture(nil, "ARTWORK", nil, 0)
    art:SetTexture(S.HERO_ART)

    local pr, pg, pb = S.PanelRGBA(env)
    local fade = hero:CreateTexture(nil, "ARTWORK", nil, 2)
    fade:SetColorTexture(1, 1, 1, 1)
    if CreateColor and fade.SetGradient then
        fade:SetGradient("HORIZONTAL", CreateColor(pr, pg, pb, 1), CreateColor(pr, pg, pb, 0))
    elseif fade.SetGradientAlpha then
        fade:SetGradientAlpha("HORIZONTAL", pr, pg, pb, 1, pr, pg, pb, 0)
    else
        fade:SetColorTexture(pr, pg, pb, 0.6)
    end

    local chip = S.MakeChip(hero, env)
    local title = S.MakeText(env, hero, Loc("DASH_WELCOME_SHOWCASE_TITLE", ""), 22, S.HeadingRGB())
    if title.SetMaxLines then title:SetMaxLines(2) end
    TrackHeading(env, title)
    local body = S.MakeText(env, hero, Loc("DASH_WELCOME_SHOWCASE_BODY", ""), 12, S.BODY_RGB[1], S.BODY_RGB[2], S.BODY_RGB[3])
    if body.SetSpacing then body:SetSpacing(3) end
    if body.SetMaxLines then body:SetMaxLines(3) end

    local openBtn = S.MakeButton(hero, env, Loc("DASH_WELCOME_OPEN_SETTINGS", "Open settings"), true)
    openBtn:SetOnClick(function()
        local f = env.f
        if f and f.ShowDashboard then f.ShowDashboard() end
    end)
    local newBtn = MakeOutline(S, S.MakeButton(hero, env, Loc("DASH_WELCOME_WHATS_NEW", "What's new"), true))
    newBtn:SetOnClick(function()
        local f = env.f
        if f and f.ShowPatchNotes then f.ShowPatchNotes() end
    end)

    local function ChipText()
        local NL = addon.NewsLogic
        local v = NL and NL.CurrentVersion and NL.CurrentVersion() or ""
        if v == "" then return "" end
        local text = Loc("DASH_WELCOME_VERSION_X", "Version %s"):format(v)
        local notes = addon.PATCH_NOTES and addon.PATCH_NOTES[v]
        local dateStr = type(notes) == "table" and addon.PatchNotes_FormatIsoDateLongUK
            and addon.PatchNotes_FormatIsoDateLongUK(notes.date)
        if dateStr then text = text .. " \194\183 " .. dateStr end
        return text
    end

    function hero:Layout(width, targetH)
        width = max(1, floor(width))
        self:SetWidth(width)
        local textW = floor(width * HERO_TEXT_FRAC) - HERO_PAD_X
        if textW < HERO_MIN_TEXT_W then textW = width - HERO_PAD_X * 2 end
        local x, y = HERO_PAD_X, HERO_PAD_Y

        local chipText = ChipText()
        if chipText ~= "" then
            chip:SetLabel(chipText)
            chip:PaintAccent()
            chip:ClearAllPoints()
            chip:SetPoint("TOPLEFT", self, "TOPLEFT", x, -y)
            chip:Show()
            y = y + HERO_CHIP_H + 10
        else
            chip:Hide()
        end

        title:SetWidth(max(1, textW))
        title:SetText(Loc("DASH_WELCOME_SHOWCASE_TITLE", ""))
        title:SetTextColor(S.HeadingRGB())
        title:ClearAllPoints()
        title:SetPoint("TOPLEFT", self, "TOPLEFT", x, -y)
        y = y + S.TextHeight(title) + 6

        body:SetWidth(max(1, textW))
        body:SetText(Loc("DASH_WELCOME_SHOWCASE_BODY", ""))
        body:ClearAllPoints()
        body:SetPoint("TOPLEFT", self, "TOPLEFT", x, -y)
        y = y + S.TextHeight(body) + 14

        openBtn:SetLabel(Loc("DASH_WELCOME_OPEN_SETTINGS", "Open settings"))
        openBtn:PaintAccent()
        openBtn:ClearAllPoints()
        openBtn:SetPoint("TOPLEFT", self, "TOPLEFT", x, -y)
        newBtn:SetLabel(Loc("DASH_WELCOME_WHATS_NEW", "What's new"))
        newBtn:PaintAccent()
        newBtn:ClearAllPoints()
        newBtn:SetPoint("LEFT", openBtn, "RIGHT", 10, 0)
        y = y + BUTTON_H

        local h = max(targetH or HERO_H, floor(y + HERO_PAD_Y + 0.5))

        local artW = max(1, floor(width * HERO_ART_FRAC))
        art:ClearAllPoints()
        art:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
        art:SetSize(artW, h)
        S.CropFill(art, artW, h, HERO_ANCHOR_X, HERO_ANCHOR_Y)
        fade:ClearAllPoints()
        fade:SetPoint("TOPLEFT", art, "TOPLEFT", 0, 0)
        fade:SetPoint("BOTTOMLEFT", art, "BOTTOMLEFT", 0, 0)
        fade:SetWidth(max(1, floor(artW * HERO_FADE_FRAC)))

        self:SetHeight(h)
        return h
    end
    return hero
end

-- ============================================================================
-- MODULE TILES
-- ============================================================================

local function TileAccent(S, env, key)
    if key ~= "integrations" then
        local c = env.TILE_MODULE_LABEL_COLORS and env.TILE_MODULE_LABEL_COLORS[key]
        if c then return c[1], c[2], c[3] end
    end
    return S.Accent(env)
end

local function TileName(key)
    if key == "integrations" then return Loc("DASH_INTEGRATIONS_TAB", "Integrations") end
    return (addon.Dashboard_BrandModule and addon.Dashboard_BrandModule(key)) or key
end

local function TileArtPath(key)
    local art = addon.WelcomeTileArt and addon.WelcomeTileArt[key]
    if not art then return nil end
    if type(art) == "string" then return TILE_ART_DIR .. art end
    return TILE_ART_DIR .. key .. ".png"
end

local function TileIconPath(key)
    local icon = (key == "integrations") and INTEGRATIONS_ICON
        or (addon.DashboardModuleIcons and addon.DashboardModuleIcons[key])
    if addon.DashboardModuleIconPath then return addon.DashboardModuleIconPath(icon) end
    return "Interface\\Icons\\" .. (icon or "INV_Misc_Question_01")
end

local function IsTileOn(key)
    if key == "integrations" then return true end
    if addon.IsModuleEnabled then return addon:IsModuleEnabled(key) and true or false end
    return true
end

-- The On/Off pill. A plain Frame, never mouse-enabled, so clicks reach the tile.
local function MakeTileChip(S, env, parent)
    local chip = CreateFrame("Frame", nil, parent)
    chip:SetHeight(TILE_CHIP_H)
    chip:SetFrameLevel((parent:GetFrameLevel() or 0) + 3)
    chip._paint = S.Rounded(chip, 8, false)
    chip._text = SingleLine(S.MakeText(env, chip, "", 10, 1, 1, 1, "CENTER"))
    chip._text:SetPoint("CENTER", chip, "CENTER", 0, 0)
    function chip:Paint(on, r, g, b)
        self._text:SetText(on and Loc("DASH_WELCOME_ON", "On") or Loc("DASH_WELCOME_OFF", "Off"))
        if on then
            self._paint(r, g, b, 0.9)
            -- Dark text on light accents (Focus yellow), white on dark ones (Essence red).
            local lum = 0.299 * r + 0.587 * g + 0.114 * b
            if lum > 0.55 then self._text:SetTextColor(0.06, 0.06, 0.08) else self._text:SetTextColor(1, 1, 1) end
        else
            self._paint(0.32, 0.33, 0.36, 0.75)
            self._text:SetTextColor(0.78, 0.78, 0.80)
        end
        self:SetWidth(math.ceil((self._text:GetStringWidth() or 16) + 14))
    end
    return chip
end

local function BuildTile(S, env, parent, key)
    local tile = S.MakePanel(parent, env, "Button")
    tile.key = key
    tile._env = env
    tile:EnableMouse(true)
    if tile.RegisterForClicks then tile:RegisterForClicks("LeftButtonUp") end

    local strip = tile:CreateTexture(nil, "ARTWORK", nil, 3)
    strip:SetPoint("TOPLEFT", tile, "TOPLEFT", 0, 0)
    strip:SetPoint("TOPRIGHT", tile, "TOPRIGHT", 0, 0)
    strip:SetHeight(TILE_STRIP_H)
    tile._strip = strip

    -- Image area: the shipped screenshot, else an accent wash with the module icon.
    local place = tile:CreateTexture(nil, "ARTWORK", nil, 0)
    tile._place = place
    local art = tile:CreateTexture(nil, "ARTWORK", nil, 1)
    tile._art = art
    local icon = tile:CreateTexture(nil, "ARTWORK", nil, 2)
    icon:SetSize(TILE_ICON, TILE_ICON)
    icon:SetTexture(TileIconPath(key))
    tile._icon = icon

    tile._name = SingleLine(S.MakeText(env, tile, "", 13, S.HeadingRGB()))
    TrackHeading(env, tile._name)
    local descKey = "DASH_WELCOME_TILE_" .. key:upper()
    tile._desc = SingleLine(S.MakeText(env, tile, Loc(descKey, ""), 11, MUTED_R, MUTED_G, MUTED_B))

    if key ~= "integrations" then tile._chip = MakeTileChip(S, env, tile) end

    -- "Open" fades in on hover. Its host is a plain Frame (not mouse-enabled) so the tween's
    -- OnUpdate never touches the tile's own scripts.
    local openHost = CreateFrame("Frame", nil, tile)
    openHost:SetFrameLevel((tile:GetFrameLevel() or 0) + 3)
    openHost:SetSize(60, 14)
    openHost:SetAlpha(0)
    tile._openHost = openHost
    tile._open = SingleLine(S.MakeText(env, openHost, Loc("DASH_WELCOME_OPEN", "Open"), 11, 1, 1, 1, "RIGHT"))
    tile._open:SetPoint("RIGHT", openHost, "RIGHT", 0, 0)

    function tile:PaintAccent()
        local r, g, b = TileAccent(S, self._env, self.key)
        local on = IsTileOn(self.key)
        self._strip:SetColorTexture(r, g, b, on and 1 or TILE_OFF_STRIP_ALPHA)
        self._place:SetColorTexture(r, g, b, TILE_PLACEHOLDER_ALPHA)
        local edgeR, edgeG, edgeB, edgeA = 1, 1, 1, TILE_BORDER_ALPHA
        if self._hover then edgeR, edgeG, edgeB, edgeA = r, g, b, TILE_HOVER_BORDER_ALPHA end
        for _, e in ipairs(self._edges or {}) do e:SetColorTexture(edgeR, edgeG, edgeB, edgeA) end
        self._open:SetTextColor(S.Lighten(r, g, b, 0.45))
        if self._chip then self._chip:Paint(on, r, g, b) end
    end

    local function FadeOpen(to)
        local from = openHost:GetAlpha() or 0
        if addon.OptionsWidgets_StartTween then
            addon.OptionsWidgets_StartTween(openHost, OPEN_FADE, function(e)
                openHost:SetAlpha(from + (to - from) * e)
            end)
        else
            openHost:SetAlpha(to)
        end
    end

    tile:SetScript("OnEnter", function(self)
        self._hover = true
        self:PaintAccent()
        FadeOpen(1)
    end)
    tile:SetScript("OnLeave", function(self)
        self._hover = false
        self:PaintAccent()
        FadeOpen(0)
    end)
    tile:SetScript("OnClick", function(self)
        local f = self._env.f
        if not f then return end
        if self.key == "integrations" then
            if f.ShowIntegrations then f.ShowIntegrations() end
        elseif f.OpenModule then
            f.OpenModule(TileName(self.key), self.key)
        end
    end)
    tile:SetScript("OnHide", function(self)
        self._hover = false
        if addon.OptionsWidgets_StopTween then addon.OptionsWidgets_StopTween(openHost) end
        openHost:SetAlpha(0)
    end)

    function tile:Layout(w, h)
        self:SetSize(w, h)
        local on = IsTileOn(self.key)
        local imgH = max(1, h - TILE_STRIP_H - TILE_TEXT_BAND)

        local path = TileArtPath(self.key)
        if path then
            art:SetTexture(path)
            art:ClearAllPoints()
            art:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -TILE_STRIP_H)
            art:SetSize(w, imgH)
            S.CropFill(art, w, imgH, 0.5, 0.5)
            if art.SetDesaturated then art:SetDesaturated(not on) end
            art:Show()
            place:Hide()
            icon:Hide()
        else
            art:Hide()
            place:ClearAllPoints()
            place:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -TILE_STRIP_H)
            place:SetSize(w, imgH)
            place:Show()
            icon:ClearAllPoints()
            icon:SetPoint("CENTER", place, "CENTER", 0, 0)
            if icon.SetDesaturated then icon:SetDesaturated(not on) end
            icon:SetAlpha(on and 1 or 0.6)
            icon:Show()
        end

        local textTop = TILE_STRIP_H + imgH + 8
        local chipW = 0
        if self._chip then
            self:PaintAccent()
            chipW = (self._chip:GetWidth() or 0) + 8
            self._chip:ClearAllPoints()
            self._chip:SetPoint("TOPRIGHT", self, "TOPRIGHT", -TILE_PAD, -textTop)
        end
        local textW = max(1, w - TILE_PAD * 2)
        self._name:SetText(TileName(self.key))
        self._name:SetTextColor(S.HeadingRGB())
        self._name:SetWidth(max(1, textW - chipW))
        self._name:ClearAllPoints()
        self._name:SetPoint("TOPLEFT", self, "TOPLEFT", TILE_PAD, -textTop)
        self._desc:SetWidth(max(1, textW - 44))
        self._desc:ClearAllPoints()
        self._desc:SetPoint("TOPLEFT", self._name, "BOTTOMLEFT", 0, -3)
        openHost:ClearAllPoints()
        openHost:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -TILE_PAD, 8)
        self:PaintAccent()
    end

    S.RegisterAccent(env, tile)
    return tile
end

local function BuildTiles(S, env, parent, keys)
    local block = CreateFrame("Frame", nil, parent)
    block:SetFrameLevel((parent:GetFrameLevel() or 0) + 1)
    local label = SingleLine(S.MakeText(env, block, Loc("DASH_WELCOME_MODULES", "The modules"), 13, S.HeadingRGB()))
    label:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
    TrackHeading(env, label)
    local tiles = {}
    for i = 1, #keys do tiles[i] = BuildTile(S, env, block, keys[i]) end

    --- @return number height of the label plus the grid
    function block:Layout(width, tileH, gap)
        local rows = math.ceil(#tiles / TILE_COLS)
        local tw = floor((width - TILE_GAP * (TILE_COLS - 1)) / TILE_COLS)
        label:SetWidth(width)
        label:SetText(Loc("DASH_WELCOME_MODULES", "The modules"))
        label:SetTextColor(S.HeadingRGB())
        local top = LABEL_H + gap
        for i, t in ipairs(tiles) do
            local col = (i - 1) % TILE_COLS
            local row = floor((i - 1) / TILE_COLS)
            t:Layout(tw, tileH)
            t:ClearAllPoints()
            t:SetPoint("TOPLEFT", block, "TOPLEFT", col * (tw + TILE_GAP), -(top + row * (tileH + TILE_GAP)))
            t:Show()
        end
        local h = top + rows * tileH + max(0, rows - 1) * TILE_GAP
        self:SetSize(width, h)
        return h
    end
    return block
end

-- ============================================================================
-- NEWS STRIP
-- ============================================================================

local function BuildNews(S, env, parent)
    local row = CreateFrame("Frame", nil, parent)
    row:SetFrameLevel((parent:GetFrameLevel() or 0) + 1)
    local strips = {}   -- story id -> strip block

    local side = S.MakePanel(row, env)
    local sideHead = SingleLine(S.MakeText(env, side, Loc("DASH_WELCOME_LATEST", "Latest news"), 11, MUTED_R, MUTED_G, MUTED_B))
    sideHead:SetPoint("TOPLEFT", side, "TOPLEFT", NEWS_PANEL_PAD, -NEWS_PANEL_PAD)
    local links = {}
    for i = 1, 2 do
        local btn = S.MakeButton(side, env, "", false)
        btn:SetOnClick(function()
            local s = btn.story
            if not s then return end
            local action = (type(s.action) == "table") and s.action or { type = "news" }
            S.DispatchAction(env.f, action, s.button or s.title)
        end)
        links[i] = btn
    end
    local allNews = S.MakeButton(side, env, Loc("DASH_WELCOME_ALL_NEWS", "All news"), false)
    allNews:SetOnClick(function()
        local f = env.f
        if f and f.ShowNews then f.ShowNews() end
    end)

    --- @return number height, 0 when the feed is empty (the row hides)
    function row:Layout(width, feed)
        if #feed == 0 then
            self:Hide()
            return 0
        end
        local top = feed[1]
        local hasSide = #feed >= 2
        local stripW = hasSide and floor((width - NEWS_SIDE_GAP) * 2 / 3) or width

        local strip = strips[top.id]
        if not strip then
            strip = S.MakeStory(self, env, top, "strip")
            strips[top.id] = strip
        end
        strip.story = top
        for id, b in pairs(strips) do
            if id ~= top.id then b:Hide() end
        end
        local h = max(NEWS_H, strip:Layout(stripW))
        strip:SetHeight(h)
        strip:ClearAllPoints()
        strip:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
        strip:Show()

        if hasSide then
            local sideW = width - stripW - NEWS_SIDE_GAP
            side:ClearAllPoints()
            side:SetPoint("TOPLEFT", self, "TOPLEFT", stripW + NEWS_SIDE_GAP, 0)
            side:SetSize(sideW, h)
            sideHead:SetText(Loc("DASH_WELCOME_LATEST", "Latest news"))
            sideHead:SetWidth(max(1, sideW - NEWS_PANEL_PAD * 2))
            local y = NEWS_PANEL_PAD + 16
            local maxW = max(24, sideW - NEWS_PANEL_PAD * 2)
            for i = 1, 2 do
                local s = feed[i + 1]
                local btn = links[i]
                btn.story = s
                if s then
                    FitLink(btn, s.title or "", maxW)
                    btn:ClearAllPoints()
                    btn:SetPoint("TOPLEFT", side, "TOPLEFT", NEWS_PANEL_PAD, -y)
                    btn:Show()
                    y = y + NEWS_ROW_H + 2
                else
                    btn:Hide()
                end
            end
            allNews:SetLabel(Loc("DASH_WELCOME_ALL_NEWS", "All news"))
            allNews:PaintAccent()
            allNews:ClearAllPoints()
            allNews:SetPoint("BOTTOMLEFT", side, "BOTTOMLEFT", NEWS_PANEL_PAD, NEWS_PANEL_PAD - 2)
            side:Show()
        else
            side:Hide()
        end

        self:SetSize(width, h)
        self:Show()
        return h
    end
    return row
end

-- ============================================================================
-- CREDITS FOOTER
-- ============================================================================

local function ClassColouredName(entry)
    local name = entry.name or ""
    local c = entry.classFile and RAID_CLASS_COLORS and RAID_CLASS_COLORS[entry.classFile]
    if c and c.r then return "|cff" .. Hex(c.r, c.g, c.b) .. name .. "|r" end
    return name
end

local function ShowCreditsTooltip(owner)
    local tip = GameTooltip
    if not tip then return end
    local C = addon.DashboardWelcomeCredits or {}
    local hr, hg, hb = 1, 0.82, 0
    if NORMAL_FONT_COLOR and NORMAL_FONT_COLOR.r then
        hr, hg, hb = NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b
    end
    tip:SetOwner(owner, "ANCHOR_TOPLEFT")
    tip:ClearLines()

    local function Section(headKey, fallback, list, fmt, first)
        if type(list) ~= "table" or #list == 0 then return end
        if not first then tip:AddLine(" ") end
        tip:AddLine(Loc(headKey, fallback), hr, hg, hb)
        local parts = {}
        for i = 1, #list do parts[#parts + 1] = fmt(list[i]) end
        tip:AddLine(table.concat(parts, ", "), 1, 1, 1, true)
    end

    Section("DASH_WELCOME_CONTRIBUTORS_HEADING", "Contributors", C.contributors,
        function(e) return e.name or "" end, true)
    Section("DASH_WELCOME_SUPPORTERS_HEADING", "Supporters", C.supporters, ClassColouredName, false)
    Section("DASH_WELCOME_LOCALISATIONS_HEADING", "Localisations", C.translators,
        function(e) return e.locale and ((e.name or "") .. " (" .. e.locale .. ")") or (e.name or "") end, false)
    tip:Show()
end

local function BuildCredits(S, env, parent)
    local bar = CreateFrame("Frame", nil, parent)
    bar:SetFrameLevel((parent:GetFrameLevel() or 0) + 1)

    local rule = bar:CreateTexture(nil, "ARTWORK")
    rule:SetHeight(1)
    rule:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
    rule:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 0, 0)
    rule:SetColorTexture(1, 1, 1, TILE_BORDER_ALPHA)

    local made = CreateFrame("Button", nil, bar)
    made:SetFrameLevel((bar:GetFrameLevel() or 0) + 2)
    made:SetHeight(CREDITS_H - 6)
    local madeText = SingleLine(S.MakeText(env, made, Loc("DASH_WELCOME_MADE_WITH", ""), 11, MUTED_R, MUTED_G, MUTED_B))
    madeText:SetPoint("LEFT", made, "LEFT", 0, 0)
    made:SetScript("OnEnter", function(self)
        madeText:SetTextColor(1, 1, 1)
        ShowCreditsTooltip(self)
    end)
    made:SetScript("OnLeave", function()
        madeText:SetTextColor(MUTED_R, MUTED_G, MUTED_B)
        if GameTooltip then GameTooltip:Hide() end
    end)

    -- Right side, left to right: Module guide, then the community links.
    local links = {}
    local guide = S.MakeButton(bar, env, Loc("DASH_WELCOME_MODULE_GUIDE", "Module guide"), false)
    guide:SetOnClick(function()
        local f = env.f
        if f and f.ShowModuleGuide then f.ShowModuleGuide() end
    end)
    guide._labelKey, guide._fallback = "DASH_WELCOME_MODULE_GUIDE", "Module guide"
    links[1] = guide
    local byId = {}
    for _, link in ipairs(addon.DashboardCommunityLinks or {}) do byId[link.id] = link end
    for _, id in ipairs(FOOTER_LINK_IDS) do
        local link = byId[id]
        if link then
            local btn = S.MakeButton(bar, env, Loc(link.labelKey, id), false)
            btn._labelKey, btn._fallback = link.labelKey, id
            btn:SetOnClick(function()
                if addon.ShowURLCopyBox then
                    local label = Loc(link.labelKey, id)
                    addon.ShowURLCopyBox(link.url, Loc("DASH_COPY_LINK_X", "%s"):format(label))
                end
            end)
            links[#links + 1] = btn
        end
    end

    function bar:Layout(width)
        self:SetSize(width, CREDITS_H)
        local x = width
        for i = #links, 1, -1 do
            local btn = links[i]
            btn:SetLabel(Loc(btn._labelKey, btn._fallback))
            btn:PaintAccent()
            x = x - (btn:GetWidth() or 0)
            btn:ClearAllPoints()
            btn:SetPoint("LEFT", self, "TOPLEFT", x, -CREDITS_H / 2 - 1)
            x = x - LINK_GAP
        end
        madeText:SetText(Loc("DASH_WELCOME_MADE_WITH", ""))
        local roomW = max(40, x - 8)
        madeText:SetWidth(0)
        local mw = min(roomW, (madeText:GetStringWidth() or 0) + 2)
        madeText:SetWidth(mw)
        made:SetWidth(mw)
        made:ClearAllPoints()
        made:SetPoint("LEFT", self, "TOPLEFT", 0, -CREDITS_H / 2 - 1)
        return CREDITS_H
    end
    return bar
end

-- ============================================================================
-- PAGE
-- ============================================================================

--- Fit the target sizes into the visible height. Gaps shrink first, then the hero (never
--- below what its text needs), then the tile rows, each down to its floor. Whatever still
--- doesn't fit (large text scales) scrolls.
--- @param avail number visible height
--- @param sections number how many sections are drawn (one gap between each, one in the tiles)
--- @param rows number tile rows
--- @param heroNeed number hero height its text needs
--- @param otherH number news + credits heights
--- @return number gap, number tileH, number heroH
local function FitSizes(avail, sections, rows, heroNeed, otherH)
    local gap, tileH, heroH = GAP, TILE_H, max(HERO_H, heroNeed)
    if not avail or avail < 1 then return gap, tileH, heroH end
    local gaps = max(0, sections - 1) + (rows > 0 and 1 or 0)
    local need = heroH + (rows > 0 and LABEL_H or 0) + rows * tileH + max(0, rows - 1) * TILE_GAP
        + otherH + gaps * gap
    local over = need - avail
    if over > 0 and gaps > 0 then
        local d = min(over, gaps * (GAP - GAP_MIN))
        gap = GAP - d / gaps
        over = over - d
    end
    if over > 0 then
        local d = min(over, max(0, heroH - max(HERO_MIN_H, heroNeed)))
        heroH = heroH - d
        over = over - d
    end
    if over > 0 and rows > 0 then
        local d = min(over, rows * (TILE_H - TILE_MIN_H))
        tileH = TILE_H - d / rows
    end
    return floor(gap), floor(tileH), math.ceil(heroH)
end

--- Build the Welcome page into env.welcomeView and define f.ShowWelcome.
--- @param env table DashboardHomeWelcome_Init env
function addon.DashboardShowcase_InitWelcome(env)
    local S = addon.Showcase
    local welcomeView = env and env.welcomeView
    if not (S and welcomeView) then return end
    local f = env.f
    local L = env.L
    local NL = addon.NewsLogic
    local dashScrollTopOffset = env.dashScrollTopOffset or -130

    -- Stories read env.newsSeen; keep the snapshot on a child env, not the shared one.
    local storyEnv = setmetatable({}, { __index = env })

    local bg = welcomeView:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", 28, dashScrollTopOffset + BG_TOP_NUDGE)
    bg:SetPoint("BOTTOMRIGHT", welcomeView, "BOTTOMRIGHT", -28, BG_BOTTOM_INSET)

    local scroll = CreateFrame("ScrollFrame", nil, welcomeView, "UIPanelScrollFrameTemplate")
    scroll:SetFrameLevel((welcomeView:GetFrameLevel() or 0) + 2)
    if scroll.ScrollBar then
        scroll.ScrollBar:Hide()
        scroll.ScrollBar:ClearAllPoints()
    end
    scroll:SetPoint("TOPLEFT", bg, "TOPLEFT", SCROLL_TO_BG_INSET, 0)
    scroll:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -SCROLL_TO_BG_INSET, 0)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(400, 1)
    scroll:SetScrollChild(content)
    if addon.Dashboard_ApplySmoothScroll then
        addon.Dashboard_ApplySmoothScroll(scroll, content, 60, true)
    end
    welcomeView._scrollContent = content

    -- Sections in feed order; only the four showcase kinds are drawn.
    local sections = {}
    local tileRows = 0
    for _, item in ipairs(addon.DashboardWelcomeFeed or {}) do
        local sec
        if item.kind == "showcase_hero" then
            sec = { kind = item.kind, frame = BuildHero(S, storyEnv, content) }
        elseif item.kind == "module_tiles" then
            local keys = item.tiles or {}
            tileRows = math.ceil(#keys / TILE_COLS)
            sec = { kind = item.kind, frame = BuildTiles(S, storyEnv, content, keys) }
        elseif item.kind == "news_strip" then
            sec = { kind = item.kind, frame = BuildNews(S, storyEnv, content) }
        elseif item.kind == "credits_footer" then
            sec = { kind = item.kind, frame = BuildCredits(S, storyEnv, content) }
        end
        if sec then sections[#sections + 1] = sec end
    end

    -- The seen snapshot only matters when the installed version has no patch notes.
    -- Otherwise the strip's top story is the release story, which never shows a New pill.
    local function TakeSeenSnapshot(feed)
        local snap = {}
        if NL then
            for id, v in pairs(NL.EnsureSeen(S.RootDB(), feed)) do snap[id] = v end
        end
        storyEnv.newsSeen = snap
    end

    local function Layout()
        local w = max(280, (bg:GetWidth() or 0) - SCROLL_TO_BG_INSET * 2)
        content:SetWidth(w)
        local feed = NL and NL.CurrentFeed() or {}
        if not storyEnv.newsSeen then TakeSeenSnapshot(feed) end

        -- Measure what can't shrink, then fit the rest to the visible height.
        local heights, drawn, heroNeed, otherH = {}, 0, 0, 0
        for i, sec in ipairs(sections) do
            local fr = sec.frame
            if sec.kind == "showcase_hero" then
                heroNeed = fr:Layout(w, HERO_MIN_H)
                heights[i] = heroNeed
            elseif sec.kind == "news_strip" then
                heights[i] = fr:Layout(w, feed)
                otherH = otherH + heights[i]
            elseif sec.kind == "credits_footer" then
                heights[i] = fr:Layout(w)
                otherH = otherH + heights[i]
            end
            if sec.kind ~= "news_strip" or heights[i] > 0 then drawn = drawn + 1 end
        end
        local gap, tileH, heroH = FitSizes(scroll:GetHeight(), drawn, tileRows, heroNeed, otherH)

        local y = 0
        for i, sec in ipairs(sections) do
            local fr = sec.frame
            local h = heights[i]
            if sec.kind == "showcase_hero" then
                h = fr:Layout(w, heroH)
            elseif sec.kind == "module_tiles" then
                h = fr:Layout(w, tileH, gap)
            end
            if h > 0 then
                fr:ClearAllPoints()
                fr:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
                fr:Show()
                y = y + h + gap
            end
        end
        content:SetHeight(max(1, y - gap))

        if scroll.UpdateScrollChildRect then scroll:UpdateScrollChildRect() end
        local maxScroll = max(0, (content:GetHeight() or 0) - (scroll:GetHeight() or 0))
        if (scroll:GetVerticalScroll() or 0) > maxScroll then
            scroll:SetVerticalScroll(maxScroll)
            scroll.targetScroll = nil
        end
    end

    -- DashboardFrame's resize pass calls this name on the welcome-style views.
    welcomeView._layoutWelcomeContent = Layout

    welcomeView:SetScript("OnShow", function()
        TakeSeenSnapshot(NL and NL.CurrentFeed() or {})
        Layout()
        if C_Timer and C_Timer.After then
            C_Timer.After(0, Layout)
            C_Timer.After(0.05, Layout)
        end
    end)
    welcomeView:SetScript("OnSizeChanged", function()
        if welcomeView:IsShown() then Layout() end
    end)

    local HideContextHeader = env.HideContextHeader
    local SetSidebarState = env.setSidebarState
    local CLEAR = env.CLEAR
    local head, headSub, searchBarShell = env.head, env.headSub, env.searchBarShell

    f.ShowWelcome = function()
        if f.pnChangelogHeaderBtn then f.pnChangelogHeaderBtn:Hide() end
        if HideContextHeader then HideContextHeader() end
        if env.detailView then env.detailView:Hide() end
        if env.subCategoryView then env.subCategoryView:Hide() end
        if env.dashboardView then env.dashboardView:Hide() end
        if f.guideView then f.guideView:Hide() end
        if env.patchNotesView then env.patchNotesView:Hide() end
        if env.newsView then env.newsView:Hide() end
        if env.integrationsView then env.integrationsView:Hide() end
        if f.searchView then f.searchView:Hide() end
        welcomeView:SetAlpha(0)
        welcomeView:Show()
        if UIFrameFadeIn then UIFrameFadeIn(welcomeView, 0.2, 0, 1) else welcomeView:SetAlpha(1) end
        if head then head:Show() end
        if headSub then
            headSub:Show()
            headSub:SetText((L and L["DASH_WELCOME_HEAD_SUB"]) or "")
        end
        if searchBarShell then searchBarShell:Hide() end
        if f.HideSearchDropdown then f.HideSearchDropdown() end
        if f.DockSearchDropdownForModule then f.DockSearchDropdownForModule() end
        f.currentModuleKey = nil
        if SetSidebarState then
            SetSidebarState({ view = "welcome", activeModuleKey = CLEAR, activeCategoryIndex = CLEAR })
        end
        if addon.DashboardPreview and addon.DashboardPreview.SetActiveModuleKey then
            addon.DashboardPreview.SetActiveModuleKey(nil)
        end
        if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
    end
end
