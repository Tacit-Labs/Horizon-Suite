--[[
    Horizon Suite – Dashboard Accordion Card
    Reusable expand/collapse card chrome for the Detail view option accordion.
    Exposed as addon.Dashboard_CreateAccordionCard(parent, title, headerToggleCfg, p).
    Called from DashboardDetailView.lua via a local wrapper that binds p.
    p fields: GetAccentColor, MakeText, dashAccentRefs, DASHBOARD_CONTENT_CARD_ALPHA_MULT, UpdateDetailLayout
]]

local addon = _G.HorizonSuite
if not addon then return end

--- Creates an accordion card frame for the Detail view.
--- headerToggleCfg (optional): { dbKey=string, default=boolean }
--- Adds a mini pill toggle to the card header wired to a DB key.
--- @param parent frame
--- @param title string
--- @param headerToggleCfg table|nil
--- @param p table  GetAccentColor, MakeText, dashAccentRefs, DASHBOARD_CONTENT_CARD_ALPHA_MULT, UpdateDetailLayout
--- @return frame card
function addon.Dashboard_CreateAccordionCard(parent, title, headerToggleCfg, p)
    local GetAccentColor     = p.GetAccentColor
    local MakeText           = p.MakeText
    local dashAccentRefs     = p.dashAccentRefs
    local UpdateDetailLayout = p.UpdateDetailLayout

    local WDef = addon.OptionsWidgetsDef or {}
    local SBg  = (WDef.SectionCardBg) or { 0.09, 0.09, 0.11, 0.96 }
    local SBgA = SBg[4] * (p.DASHBOARD_CONTENT_CARD_ALPHA_MULT or 1)
    local SBgHoverR,    SBgHoverG,    SBgHoverB    = 0.11, 0.11, 0.13
    local SBgExpandedR, SBgExpandedG, SBgExpandedB = 0.10, 0.10, 0.12

    local card = CreateFrame("Frame", nil, parent)
    card:SetHeight(60)
    card:SetPoint("LEFT", parent, "LEFT", 0, 0)
    card:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
    card.expanded = false
    card.collapsedHeight = 60
    card:SetClipsChildren(true)

    -- Background (same alpha as options section cards)
    local cBg = card:CreateTexture(nil, "BACKGROUND")
    cBg:SetAllPoints()
    cBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)

    -- Bottom divider
    local divider = card:CreateTexture(nil, "ARTWORK")
    divider:SetHeight(1)
    divider:SetPoint("BOTTOMLEFT", 20, 0)
    divider:SetPoint("BOTTOMRIGHT", -20, 0)
    local cdr, cdg, cdb = GetAccentColor()
    divider:SetColorTexture(cdr, cdg, cdb, 0.2)
    tinsert(dashAccentRefs.cardDividers, divider)

    -- Accent
    local accent = card:CreateTexture(nil, "ARTWORK")
    accent:SetSize(3, 24)
    accent:SetPoint("TOPLEFT", 20, -18)
    local cr, cg, cb = GetAccentColor()
    accent:SetColorTexture(cr, cg, cb, 1)
    tinsert(dashAccentRefs.cardAccents, accent)

    -- Title
    local lbl = MakeText(card, title:upper(), 15, 0.9, 0.9, 0.95, "LEFT")
    lbl:SetPoint("TOPLEFT", 35, -22)

    -- Forward-declare so ExpandCollapseCard and headerToggleInit can reference it
    -- before the actual definition (which needs sc/chevron to be in scope).
    local updateExpandedVisuals

    -- Shared expand/collapse logic used by both headerBtn and the header pill toggle
    local function ExpandCollapseCard(targetExpanded)
        if card.anim:IsPlaying() then return end
        if targetExpanded == card.expanded then return end
        card.expanded = targetExpanded
        updateExpandedVisuals()
        card.anim:Play()
    end

    -- Header toggle pill (replaces chevron when headerToggleCfg provided)
    local chevron
    if headerToggleCfg and headerToggleCfg.dbKey then
        local htDbKey   = headerToggleCfg.dbKey
        local htDefault = headerToggleCfg.default
        if htDefault == nil then htDefault = true end

        -- Full-size pill matching OptionsWidgets toggle (48×22, thumb 18, inset 2)
        local tW, tH, tInset, tThumb = 48, 22, 2, 18
        local tFillW   = tW - 2 * tInset
        local pillTravel = tFillW - tThumb

        local pillFrame = CreateFrame("Frame", nil, card)
        pillFrame:SetSize(tW, tH)
        pillFrame:SetPoint("TOPRIGHT", card, "TOPRIGHT", -20, -19)
        pillFrame:SetFrameLevel(card:GetFrameLevel() + 6)

        local tOn  = (WDef and WDef.TrackOn)    or { 0.48, 0.58, 0.82, 0.85 }
        local tOff = (WDef and WDef.TrackOff)   or { 0.14, 0.14, 0.18, 0.95 }
        local tTh  = (WDef and WDef.ThumbColor) or { 1, 1, 1, 0.98 }

        local trackBg = pillFrame:CreateTexture(nil, "BACKGROUND")
        trackBg:SetPoint("TOPLEFT",     pillFrame, "TOPLEFT",     tInset, -tInset)
        trackBg:SetPoint("BOTTOMRIGHT", pillFrame, "BOTTOMRIGHT", -tInset, tInset)
        trackBg:SetColorTexture(tOff[1], tOff[2], tOff[3], tOff[4])

        local trackFill = pillFrame:CreateTexture(nil, "ARTWORK")
        trackFill:SetPoint("TOPLEFT",    pillFrame, "TOPLEFT",    tInset,  -tInset)
        trackFill:SetPoint("BOTTOMLEFT", pillFrame, "BOTTOMLEFT", tInset,   tInset)
        trackFill:SetWidth(0)
        trackFill:SetColorTexture(tOn[1], tOn[2], tOn[3], tOn[4] or 0.85)

        local thumb = pillFrame:CreateTexture(nil, "OVERLAY")
        thumb:SetSize(tThumb, tThumb)
        thumb:SetColorTexture(tTh[1], tTh[2], tTh[3], tTh[4] or 0.98)

        local pillPos = 0
        local pillAnimStart, pillAnimFrom, pillAnimTo

        local function UpdatePillVisuals(t)
            trackFill:SetWidth(t * tFillW)
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
    else
        -- Standard chevron indicator for cards without a header toggle
        chevron = MakeText(card, "+", 14, 0.5, 0.5, 0.55, "RIGHT")
        chevron:SetPoint("TOPRIGHT", -25, -23)
    end

    local headerBtn = CreateFrame("Button", nil, card)
    headerBtn:SetPoint("TOPLEFT", 0, 0)
    headerBtn:SetPoint("TOPRIGHT", 0, 0)
    headerBtn:SetHeight(60)
    headerBtn:SetFrameLevel(card:GetFrameLevel() + 5)
    headerBtn:SetScript("OnEnter", function()
        if not card.expanded then
            cBg:SetColorTexture(SBgHoverR, SBgHoverG, SBgHoverB, SBgA)
        end
    end)
    headerBtn:SetScript("OnLeave", function()
        if not card.expanded then
            cBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)
        end
    end)

    -- Settings Container
    local sc = CreateFrame("Frame", nil, card)
    sc:SetPoint("TOPLEFT", 0, -60)
    sc:SetPoint("RIGHT", card, "RIGHT", 0, 0)
    sc:SetHeight(1)
    sc:SetAlpha(0)
    card.settingsContainer = sc

    updateExpandedVisuals = function()
        if card.expanded then
            cBg:SetColorTexture(SBgExpandedR, SBgExpandedG, SBgExpandedB, SBgA)
            if chevron then chevron:SetText("-") end
        else
            cBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)
            if chevron then chevron:SetText("+") end
        end
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
    end)

    return card
end
