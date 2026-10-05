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

-- Rounded fills come from OptionsWidgets (Echo.Round, with a flat fallback); so does the header
-- switch (addon.OptionsWidgets_CreatePill), looked up when a card is built.
local PaintRounded = addon.OptionsWidgets_PaintRounded

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

    local WDef = addon.OptionsWidgetsDef
    local labelSize = WDef.LabelSize
    local titleSize = WDef.TitleSize
    local helpSize  = WDef.HelpSize
    local pad       = WDef.CardPadding
    local padY      = WDef.CardHeaderPadY
    local radius    = WDef.CardRadius
    local descGap   = WDef.CardDescGap
    local chevronSize = WDef.CardChevronSize
    local chevronBarLen = WDef.CardChevronBarLen
    -- Half a bar's length projected on one axis at 45 degrees.
    local chevronHalf = chevronBarLen / 2 * math.cos(math.pi / 4)
    local alphaMult = p.DASHBOARD_CONTENT_CARD_ALPHA_MULT or 1
    local SBg  = WDef.CardBg
    local SHov = WDef.CardBgHover
    local SBgA = SBg[4] * alphaMult
    local SHovA = SHov[4] * alphaMult
    local titleColor = WDef.TextColorTitleBar
    local mutedColor = WDef.TextColorMuted
    local faintColor = WDef.TextColorFaint

    -- Header height follows the title size: the title's line plus padding above and below.
    local headerH = math.floor(titleSize * WDef.TitleLineFactor + 0.5) + 2 * padY

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
    card.chromeHeight = headerH + WDef.CardContentBottom
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
    chevron:SetSize(chevronSize, chevronSize)
    chevron:SetPoint("CENTER", card, "TOPRIGHT", -(pad + chevronSize / 2), -headerH / 2)
    chevron:SetFrameLevel(card:GetFrameLevel() + 6)
    local chevBars = {}
    for i = 1, 2 do
        local bar = chevron:CreateTexture(nil, "ARTWORK")
        bar:SetSize(chevronBarLen, WDef.CardChevronBarW)
        bar:SetColorTexture(faintColor[1], faintColor[2], faintColor[3], 1)
        chevBars[i] = bar
    end
    local function SetChevron(expanded)
        local q = math.pi / 4
        local shape
        if expanded then
            shape = { { -chevronHalf, 0, -q }, { chevronHalf, 0, q } }
        else
            shape = { { 0, chevronHalf, -q }, { 0, -chevronHalf, q } }
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
    local rightReserve = pad + chevronSize

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

        local tW = WDef.SwitchWidth

        -- The shared switch pill (OptionsWidgets CreatePill): it slides and fills over
        -- Def.MotionFast on a click, snaps on an outside refresh, and scales on a press.
        -- The level is set before its parts are built so they stack above the header button.
        local pillFrame = addon.OptionsWidgets_CreatePill(card, card:GetFrameLevel() + 6)
        pillFrame:SetPoint("RIGHT", chevron, "LEFT", -WDef.CardHeaderSwitchGap, 0)
        rightReserve = rightReserve + WDef.CardHeaderSwitchGap + tW

        local function GetPillValue()
            return _G.OptionsData_GetDB(htDbKey, htDefault)
        end

        -- Set by a click, consumed by the next paint: only the player's own change slides.
        local animateNext
        local function RefreshPill()
            local animate = animateNext
            animateNext = nil
            pillFrame:SetOn(GetPillValue() and true or false, animate)
        end
        RefreshPill()

        local pillBtn = CreateFrame("Button", nil, card)
        pillBtn:SetAllPoints(pillFrame)
        pillBtn:SetFrameLevel(card:GetFrameLevel() + 7)
        pillBtn:SetScript("OnClick", function()
            local newVal = not GetPillValue()
            animateNext = true
            _G.OptionsData_SetDB(htDbKey, newVal)
            RefreshPill()   -- slides; a refresh inside SetDB may already have started it
            -- Expand/collapse card to match toggle state
            ExpandCollapseCard(newVal)
            -- Refresh preview
            if addon.Insight and addon.Insight.ApplyInsightOptions then
                addon.Insight.ApplyInsightOptions()
            end
        end)
        if addon.OptionsWidgets_AttachPress then
            addon.OptionsWidgets_AttachPress(pillBtn, pillFrame.body)
        end

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
            if room < WDef.CardDescMinWidth then
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
