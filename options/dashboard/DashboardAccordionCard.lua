--[[
    Horizon Suite – Dashboard Accordion Card
    Reusable expand/collapse card chrome for the Detail view option accordion.
    Exposed as addon.Dashboard_CreateAccordionCard(parent, title, headerToggleCfg, p, desc).
    Called from DashboardDetailView.lua via a local wrapper that binds p.
    p fields: GetAccentColor, MakeText, dashAccentRefs, DASHBOARD_CONTENT_CARD_ALPHA_MULT, UpdateDetailLayout

    Look (Docs/Engineering/2026-10-05-dashboard-modern-style-design.md): a filled rounded panel
    with no border; the title in Def.TitleSize, an optional muted one-line description after it,
    and a chevron at the right with the header switch (when there is one) just left of it.
    Rounded shapes come from Echo.Round, a manual 9-slice over bundled textures that runs on
    Retail and Forever; without it the card falls back to a flat square fill.
]]

local addon = _G.HorizonSuite
if not addon then return end

local CHEVRON_SIZE = 16     -- the chevron's hit-free box at the header's right
local CHEVRON_BAR_LEN = 7
local CHEVRON_BAR_W = 2
local CHEVRON_HALF = 2.47   -- half a bar's length projected on one axis at 45°
local HEADER_SWITCH_GAP = 10
local DESC_MIN_WIDTH = 40   -- narrower than this, the description is hidden
local TITLE_LINE_FACTOR = 1.35

-- Paint a frame as a rounded panel when Echo.Round is available, else as a flat fill.
-- @return function(r, g, b, a) that recolours the fill
local function PaintRounded(frame, radius, layer)
    local Round = addon.Echo and addon.Echo.Round
    if Round and Round.Apply and Round.SetColor then
        Round.Apply(frame, { radius = radius, layer = layer or "BACKGROUND" })
        return function(r, g, b, a) Round.SetColor(frame, r, g, b, a) end
    end
    local tex = frame:CreateTexture(nil, layer or "BACKGROUND")
    tex:SetAllPoints()
    tex:SetColorTexture(1, 1, 1, 1)
    return function(r, g, b, a) tex:SetVertexColor(r, g, b, a) end
end

-- A round dot (Echo.Round.Dot) or, without it, a square colour texture.
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

-- Width of a FontString's text, ignoring any width already set on it.
local function TextWidth(fs)
    if not fs then return 0 end
    local w = (fs.GetUnboundedStringWidth and fs:GetUnboundedStringWidth()) or (fs.GetStringWidth and fs:GetStringWidth()) or 0
    return tonumber(w) or 0
end

--- Creates an accordion card frame for the Detail view.
--- headerToggleCfg (optional): { dbKey=string, default=boolean }
--- Adds a mini pill toggle to the card header wired to a DB key.
--- @param parent frame
--- @param title string
--- @param headerToggleCfg table|nil
--- @param p table  GetAccentColor, MakeText, dashAccentRefs, DASHBOARD_CONTENT_CARD_ALPHA_MULT, UpdateDetailLayout
--- @param desc string|function|nil  Muted one-line description shown after the title
--- @return frame card
function addon.Dashboard_CreateAccordionCard(parent, title, headerToggleCfg, p, desc)
    local MakeText           = p.MakeText
    local UpdateDetailLayout = p.UpdateDetailLayout

    local WDef = addon.OptionsWidgetsDef or {}
    local labelSize = WDef.LabelSize or 13
    local titleSize = WDef.TitleSize or (labelSize + 2)
    local helpSize  = WDef.HelpSize or (labelSize - 2)
    local pad       = WDef.CardPadding or 18
    local padY      = WDef.CardHeaderPadY or 14
    local radius    = WDef.CardRadius or 12
    local descGap   = WDef.CardDescGap or 12
    local alphaMult = p.DASHBOARD_CONTENT_CARD_ALPHA_MULT or 1
    local SBg  = WDef.CardBg or WDef.SectionCardBg or { 0.09, 0.09, 0.114, 0.96 }
    local SHov = WDef.CardBgHover or { 0.11, 0.11, 0.137, 0.96 }
    local SBgA = (SBg[4] or 1) * alphaMult
    local SHovA = (SHov[4] or 1) * alphaMult
    local titleColor = WDef.TextColorTitleBar or { 0.9, 0.92, 0.96 }
    local mutedColor = WDef.TextColorMuted or { 0.54, 0.565, 0.627 }
    local faintColor = WDef.TextColorFaint or { 0.365, 0.384, 0.447 }

    -- Header height follows the title size: the title's line plus padding above and below.
    local headerH = math.floor(titleSize * TITLE_LINE_FACTOR + 0.5) + 2 * padY

    -- MakeText takes a size relative to the 13px base and registers the FontString with the
    -- dashboard typography, so the dashboard font and text size reach it later.
    local titleBase = 13 + (titleSize - labelSize)
    local helpBase  = 13 + (helpSize - labelSize)

    local card = CreateFrame("Frame", nil, parent)
    card:SetHeight(headerH)
    card:SetPoint("LEFT", parent, "LEFT", 0, 0)
    card:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
    card.expanded = false
    card.collapsedHeight = headerH
    card.headerHeight = headerH
    -- Header plus the space below the last row; DashboardAccordionBuild adds the rows' height.
    card.chromeHeight = headerH + (WDef.CardContentBottom or 12)
    card:SetClipsChildren(true)

    -- Background: one filled rounded panel, no border (alpha as the other dashboard cards).
    local paintBg = PaintRounded(card, radius, "BACKGROUND")
    paintBg(SBg[1], SBg[2], SBg[3], SBgA)

    -- Title, vertically centred in the header.
    local lbl = MakeText(card, tostring(title or ""), titleBase, titleColor[1], titleColor[2], titleColor[3], "LEFT")
    lbl:SetPoint("LEFT", card, "TOPLEFT", pad, -headerH / 2)
    if lbl.SetWordWrap then lbl:SetWordWrap(false) end
    if lbl.SetMaxLines then lbl:SetMaxLines(1) end

    -- Optional muted description on the title's line.
    if type(desc) == "function" then desc = desc() end
    local descFs
    if type(desc) == "string" and desc ~= "" then
        descFs = MakeText(card, desc, helpBase, mutedColor[1], mutedColor[2], mutedColor[3], "LEFT")
        descFs:SetPoint("LEFT", lbl, "RIGHT", descGap, 0)
        if descFs.SetWordWrap then descFs:SetWordWrap(false) end
        if descFs.SetNonSpaceWrap then descFs:SetNonSpaceWrap(false) end
        if descFs.SetMaxLines then descFs:SetMaxLines(1) end
    end
    card.titleText = lbl
    card.descText = descFs

    -- Chevron at the right: two thin bars, "v" when open and ">" when closed.
    local chevron = CreateFrame("Frame", nil, card)
    chevron:SetSize(CHEVRON_SIZE, CHEVRON_SIZE)
    chevron:SetPoint("CENTER", card, "TOPRIGHT", -(pad + CHEVRON_SIZE / 2), -headerH / 2)
    chevron:SetFrameLevel(card:GetFrameLevel() + 6)
    local chevBars = {}
    for i = 1, 2 do
        local bar = chevron:CreateTexture(nil, "ARTWORK")
        bar:SetSize(CHEVRON_BAR_LEN, CHEVRON_BAR_W)
        bar:SetColorTexture(faintColor[1], faintColor[2], faintColor[3], 1)
        chevBars[i] = bar
    end
    local function SetChevron(expanded)
        local q = math.pi / 4
        local shape
        if expanded then
            shape = { { -CHEVRON_HALF, 0, -q }, { CHEVRON_HALF, 0, q } }
        else
            shape = { { 0, CHEVRON_HALF, -q }, { 0, -CHEVRON_HALF, q } }
        end
        for i, s in ipairs(shape) do
            local bar = chevBars[i]
            bar:ClearAllPoints()
            bar:SetPoint("CENTER", chevron, "CENTER", s[1], s[2])
            if bar.SetRotation then bar:SetRotation(s[3]) end
        end
    end
    SetChevron(false)

    -- Space the header keeps clear at its right for the chevron and the switch.
    local rightReserve = pad + CHEVRON_SIZE

    -- Forward-declare so ExpandCollapseCard and headerToggleInit can reference it
    -- before the actual definition (which needs sc to be in scope).
    local updateExpandedVisuals

    -- Shared expand/collapse logic used by both headerBtn and the header pill toggle
    local function ExpandCollapseCard(targetExpanded)
        if card.anim:IsPlaying() then return end
        if targetExpanded == card.expanded then return end
        card.expanded = targetExpanded
        updateExpandedVisuals()
        card.anim:Play()
    end

    -- Header switch, just left of the chevron.
    if headerToggleCfg and headerToggleCfg.dbKey then
        local htDbKey   = headerToggleCfg.dbKey
        local htDefault = headerToggleCfg.default
        if htDefault == nil then htDefault = true end

        local tW = WDef.SwitchWidth or 36
        local tH = WDef.SwitchHeight or 20
        local tInset = 2
        local tThumb = tH - 2 * tInset
        local pillTravel = tW - 2 * tInset - tThumb

        local pillFrame = CreateFrame("Frame", nil, card)
        pillFrame:SetSize(tW, tH)
        pillFrame:SetPoint("RIGHT", chevron, "LEFT", -HEADER_SWITCH_GAP, 0)
        pillFrame:SetFrameLevel(card:GetFrameLevel() + 6)
        rightReserve = rightReserve + HEADER_SWITCH_GAP + tW

        local tOn  = WDef.TrackOn    or { 0.48, 0.58, 0.82, 0.85 }
        local tOff = WDef.TrackOff   or { 0.14, 0.14, 0.18, 0.95 }
        local tTh  = WDef.ThumbColor or { 1, 1, 1, 0.98 }

        -- Track: a rounded pill in TrackOff, with a rounded TrackOn fill that grows from the
        -- left as the switch turns on, and a round thumb above both.
        local paintTrack = PaintRounded(pillFrame, tH / 2, "BACKGROUND")
        paintTrack(tOff[1], tOff[2], tOff[3], tOff[4] or 0.95)

        local fillFrame = CreateFrame("Frame", nil, pillFrame)
        fillFrame:SetPoint("TOPLEFT", pillFrame, "TOPLEFT", 0, 0)
        fillFrame:SetPoint("BOTTOMLEFT", pillFrame, "BOTTOMLEFT", 0, 0)
        fillFrame:SetWidth(tH)
        fillFrame:SetFrameLevel(pillFrame:GetFrameLevel() + 1)
        local paintFill = PaintRounded(fillFrame, tH / 2, "BACKGROUND")
        paintFill(tOn[1], tOn[2], tOn[3], tOn[4] or 0.85)

        local thumbHost = CreateFrame("Frame", nil, pillFrame)
        thumbHost:SetAllPoints(pillFrame)
        thumbHost:SetFrameLevel(pillFrame:GetFrameLevel() + 2)
        local thumb = MakeDot(thumbHost, tThumb, "OVERLAY")
        thumb:SetVertexColor(tTh[1], tTh[2], tTh[3], tTh[4] or 0.98)

        local pillPos = 0
        local pillAnimStart, pillAnimFrom, pillAnimTo

        local function UpdatePillVisuals(t)
            fillFrame:SetWidth(tH + t * (tW - tH))
            fillFrame:SetAlpha(t)
            thumb:ClearAllPoints()
            thumb:SetPoint("CENTER", pillFrame, "LEFT", tInset + tThumb / 2 + t * pillTravel, 0)
        end

        local function GetPillValue()
            return _G.OptionsData_GetDB(htDbKey, htDefault)
        end

        local function RefreshPill()
            local on = GetPillValue()
            pillPos = on and 1 or 0
            UpdatePillVisuals(pillPos)
        end
        RefreshPill()

        -- Store handler in a local so re-triggering after nil-clear always works
        local pillOnUpdate
        pillOnUpdate = function(self)
            if not pillAnimStart then return end
            local t = math.min((GetTime() - pillAnimStart) / 0.12, 1)
            UpdatePillVisuals(pillAnimFrom + (pillAnimTo - pillAnimFrom) * t)
            if t >= 1 then
                pillPos       = pillAnimTo
                pillAnimStart = nil
                self:SetScript("OnUpdate", nil)
            end
        end

        local pillBtn = CreateFrame("Button", nil, card)
        pillBtn:SetAllPoints(pillFrame)
        pillBtn:SetFrameLevel(card:GetFrameLevel() + 7)
        pillBtn:SetScript("OnClick", function()
            local newVal = not GetPillValue()
            _G.OptionsData_SetDB(htDbKey, newVal)
            -- Animate pill (re-set from stored ref so it works on every click)
            pillAnimFrom  = pillPos
            pillAnimTo    = newVal and 1 or 0
            pillAnimStart = GetTime()
            pillFrame:SetScript("OnUpdate", pillOnUpdate)
            -- Expand/collapse card to match toggle state
            ExpandCollapseCard(newVal)
            -- Refresh preview
            if addon.Insight and addon.Insight.ApplyInsightOptions then
                addon.Insight.ApplyInsightOptions()
            end
        end)

        card.headerToggleEnabled = GetPillValue

        card.headerToggleRefresh = RefreshPill
        -- Initialize card expanded state from DB value (applied after fullHeight is known)
        card.headerToggleInit = function()
            local on = GetPillValue()
            if on ~= card.expanded then
                card.expanded = on
                local h = on and (card.fullHeight or card.collapsedHeight) or card.collapsedHeight
                card:SetHeight(h)
                card.settingsContainer:SetAlpha(on and 1 or 0)
                card.settingsContainer:SetShown(on)
                updateExpandedVisuals()
                UpdateDetailLayout()
            end
        end
    end

    -- Fit the title and description into the header: the title is truncated only when it
    -- alone overflows; the description takes what is left, ends in an ellipsis when it is
    -- too long and hides when there is no useful room. Re-run when the card's width or the
    -- dashboard font changes (DashboardAccordionBuild calls card.FitHeader on a font change).
    local lastFitW = -1
    local function FitHeader(force)
        local w = card:GetWidth() or 0
        if w <= 0 then return end
        if not force and math.abs(w - lastFitW) < 0.5 then return end
        lastFitW = w
        local avail = math.max(1, w - pad - rightReserve - descGap)
        local titleW = TextWidth(lbl)
        if titleW > avail then
            lbl:SetWidth(avail)
            if descFs then descFs:Hide() end
            return
        end
        -- Width 0 lets a title that fits size itself, so a later font change still shows it whole.
        lbl:SetWidth(0)
        if descFs then
            local room = avail - math.ceil(titleW) - descGap
            if room < DESC_MIN_WIDTH then
                descFs:Hide()
            else
                descFs:Show()
                descFs:SetWidth(TextWidth(descFs) > room and room or 0)
            end
        end
    end
    card.FitHeader = function() FitHeader(true) end
    if card.HookScript then
        card:HookScript("OnSizeChanged", function() FitHeader(false) end)
    end

    local headerBtn = CreateFrame("Button", nil, card)
    headerBtn:SetPoint("TOPLEFT", 0, 0)
    headerBtn:SetPoint("TOPRIGHT", 0, 0)
    headerBtn:SetHeight(headerH)
    headerBtn:SetFrameLevel(card:GetFrameLevel() + 5)
    headerBtn:SetScript("OnEnter", function()
        if not card.expanded then
            paintBg(SHov[1], SHov[2], SHov[3], SHovA)
        end
    end)
    headerBtn:SetScript("OnLeave", function()
        if not card.expanded then
            paintBg(SBg[1], SBg[2], SBg[3], SBgA)
        end
    end)

    -- Settings Container
    local sc = CreateFrame("Frame", nil, card)
    sc:SetPoint("TOPLEFT", 0, -headerH)
    sc:SetPoint("RIGHT", card, "RIGHT", 0, 0)
    sc:SetHeight(1)
    sc:SetAlpha(0)
    card.settingsContainer = sc

    updateExpandedVisuals = function()
        -- One panel colour open or closed; the hover tint only applies while closed.
        paintBg(SBg[1], SBg[2], SBg[3], SBgA)
        SetChevron(card.expanded)
    end

    -- Animation logic
    card.anim = card:CreateAnimationGroup()
    local sizeAnim = card.anim:CreateAnimation("Animation")
    sizeAnim:SetDuration(0.15)
    sizeAnim:SetSmoothing("IN_OUT")

    card.anim:SetScript("OnUpdate", function()
        local progress = sizeAnim:GetSmoothProgress()
        local startH = card.expanded and card.collapsedHeight or (card.fullHeight or 200)
        local endH = card.expanded and (card.fullHeight or 200) or card.collapsedHeight

        local curH = startH + (endH - startH) * progress
        card:SetHeight(curH)

        if card.expanded then
            sc:SetAlpha(progress)
        else
            sc:SetAlpha(1 - progress)
        end
        UpdateDetailLayout()
    end)

    card.anim:SetScript("OnFinished", function()
        local finalH = card.expanded and (card.fullHeight or 200) or card.collapsedHeight
        card:SetHeight(finalH)
        sc:SetAlpha(card.expanded and 1 or 0)
        updateExpandedVisuals()
        UpdateDetailLayout()
    end)

    headerBtn:SetScript("OnClick", function()
        -- Block expand when a header toggle exists and is disabled
        if card.headerToggleEnabled and not card.headerToggleEnabled() then return end
        if card.anim:IsPlaying() then return end
        card.expanded = not card.expanded
        updateExpandedVisuals()
        card.anim:Play()
        if card.onExpandedChanged then card.onExpandedChanged(card.expanded) end
    end)

    --- Open or close without animation (a page opening with a remembered state).
    --- @param expanded boolean
    function card.SetExpandedInstant(expanded)
        expanded = expanded and true or false
        card.expanded = expanded
        card:SetHeight(expanded and (card.fullHeight or card.collapsedHeight) or card.collapsedHeight)
        sc:SetAlpha(expanded and 1 or 0)
        updateExpandedVisuals()
        UpdateDetailLayout()
    end

    -- Fit now in case the width is already resolved (OnSizeChanged then never fires).
    FitHeader(true)

    return card
end
