--[[
    Horizon Suite - Dashboard in-game module guide (quick-start).
    Consumer-friendly overview: coloured module bullets, per-module accordions, Welcome-style footer.
    Wired from DashboardFrame.lua via addon.DashboardModuleGuide_Init(env).
]]

local addon = _G.HorizonSuite
if not addon then return end

local tinsert = table.insert

-- Match Patch Notes / Home tile module colours (DashboardFrame PN_MODULE_COLORS + Meridian accent).
local GUIDE_MODULE_COLORS = {
    ["Essence"]  = "DC143C",
    ["Focus"]    = "FFD133",
    ["Cache"]    = "33CC66",
    ["Presence"] = "33FFDF",
    ["Vista"]    = "B366FF",
    ["Insight"]  = "FF66B3",
    ["Axis"]     = "E0E0E0",
    ["Meridian"] = "8CB2E6",
}

--- Wrap module proper names in |cFF……|r for guide bullets (enUS uses English names per BrandDisplay rule).
--- @param text string
--- @return string
local function ColorGuideModuleNames(text)
    if type(text) ~= "string" or text == "" then return text end
    for name, hex in pairs(GUIDE_MODULE_COLORS) do
        text = text:gsub("%f[%a](" .. name .. ")%f[%A]", "|cFF" .. hex .. "%1|r")
    end
    return text
end

--- @param env table
--- @return nil
function addon.DashboardModuleGuide_Init(env)
    local f = env.f
    local addon = env.addon
    local L = env.L
    local guideView = env.guideView
    local detailView = env.detailView
    local subCategoryView = env.subCategoryView
    local dashboardView = env.dashboardView
    local welcomeView = env.welcomeView
    local patchNotesView = env.patchNotesView
    local dashScrollTopOffset = env.dashScrollTopOffset
    local dashAccentRefs = env.dashAccentRefs
    local GetAccentColor = env.GetAccentColor
    local MakeText = env.MakeText
    local MakeDashboardWelcomeMixedScriptText = env.MakeDashboardWelcomeMixedScriptText
    local HideContextHeader = env.HideContextHeader
    local SetSidebarState = env.setSidebarState
    local CLEAR = env.CLEAR
    local searchBarShell = env.searchBarShell
    local head = env.head
    local headSub = env.headSub
    local PREVIEW_MODULE_KEYS = env.PREVIEW_MODULE_KEYS or {}
    local COMING_SOON_MODULE_KEYS = env.COMING_SOON_MODULE_KEYS or {}

    local WDef = addon.OptionsWidgetsDef
    local DASHBOARD_CONTENT_CARD_ALPHA_MULT = env.DASHBOARD_CONTENT_CARD_ALPHA_MULT or 1
    local SBg = (WDef and WDef.SectionCardBg) or { 0.09, 0.09, 0.11, 0.96 }
    local SBgA = SBg[4] * DASHBOARD_CONTENT_CARD_ALPHA_MULT
    local SBgHoverR, SBgHoverG, SBgHoverB = 0.11, 0.11, 0.13
    local SBgExpandedR, SBgExpandedG, SBgExpandedB = 0.10, 0.10, 0.12

    -- Match DashboardHomeWelcome.lua: bg nudge, scroll insets, scroll–footer gap. Footer layout/anchor matches Patch Notes (full view width).
    local GUIDE_BG_TOP_NUDGE = 50
    local GUIDE_CONTENT_TOP_PAD = 6
    local GUIDE_ACC_HEAD_H = 48
    -- Match DashboardDetailView CreateAccordionCard (options accordion).
    local GUIDE_ACC_ANIM_DURATION = 0.15
    local SCROLL_BODY_X_INSET = 0
    local HERO_TOP_PAD = 0
    local SCROLL_ABOVE_FOOTER_GAP = (addon.DashboardConstants and addon.DashboardConstants.COMMUNITY_FOOTER_SCROLL_GAP) or 24
    local SCROLL_TO_BG_INSET = 20

    local function ShowCopyURL(label, url)
        if addon.ShowURLCopyBox then
            addon.ShowURLCopyBox(url, (L["DASH_COPY_LINK_X"] or "Copy link — %s"):format(label))
        end
    end

    local function BrandMod(mk)
        return addon.Dashboard_BrandModule and addon.Dashboard_BrandModule(mk) or mk
    end

    --- Accordion title: localized module name (uppercase) plus Preview / Coming Soon when applicable (matches Home tiles).
    --- @param moduleKey string
    --- @return string
    local function ModuleGuideSectionTitle(moduleKey)
        local base = (BrandMod(moduleKey) or ""):upper()
        if PREVIEW_MODULE_KEYS[moduleKey] then
            return base .. " |cff228b22(" .. (L["PRESENCE_PREVIEW"] or "Preview") .. ")|r"
        end
        if COMING_SOON_MODULE_KEYS[moduleKey] then
            return base .. " |cff8cb2e6(" .. (L["COMING_SOON"] or "Coming Soon") .. ")|r"
        end
        return base
    end

    --- After ColorGuideModuleNames: append (Preview) / (Coming Soon) next to coloured module names (same rules as Home).
    --- @param text string
    --- @return string
    local function ApplyGuideBulletStatusTags(text)
        if type(text) ~= "string" or text == "" then return text end
        local prevTag = " |cff228b22(" .. (L["PRESENCE_PREVIEW"] or "Preview") .. ")|r"
        local soonTag = " |cff8cb2e6(" .. (L["COMING_SOON"] or "Coming Soon") .. ")|r"
        for _, row in ipairs({
            { key = "cache", label = "Cache", tag = prevTag, when = PREVIEW_MODULE_KEYS },
            { key = "essence", label = "Essence", tag = prevTag, when = PREVIEW_MODULE_KEYS },
            { key = "meridian", label = "Meridian", tag = soonTag, when = COMING_SOON_MODULE_KEYS },
        }) do
            if row.when[row.key] then
                local hex = GUIDE_MODULE_COLORS[row.label]
                if hex then
                    local colored = "|cFF" .. hex .. row.label .. "|r"
                    text = text:gsub(colored, colored .. row.tag, 1)
                end
            end
        end
        return text
    end

    local embeddedInWelcome = env.guideEmbeddedInWelcome and true or false

    local guideBg, footerObj, footerPanel, guideScroll, content
    if not embeddedInWelcome then
        guideBg = guideView:CreateTexture(nil, "BACKGROUND")
        guideBg:SetPoint("TOPLEFT", 28, dashScrollTopOffset + GUIDE_BG_TOP_NUDGE)
        guideBg:SetPoint("BOTTOMRIGHT", guideView, "BOTTOMRIGHT", -28, 20)

        -- Footer: fixed below scroll (shared factory with Welcome)
        footerPanel = CreateFrame("Frame", nil, guideView)
        footerPanel:SetFrameLevel((guideView:GetFrameLevel() or 0) + 10)

        footerObj = addon.Dashboard_CreateCommunityFooter(footerPanel, {
            L = L,
            GetAccentColor = GetAccentColor,
            MakeText = MakeText,
            addon = addon,
        })
        tinsert(dashAccentRefs.communityFooterTopRules, footerObj.footerTopRule)

        guideScroll = CreateFrame("ScrollFrame", nil, guideView, "UIPanelScrollFrameTemplate")
        guideScroll:SetFrameLevel((guideView:GetFrameLevel() or 0) + 2)
        guideScroll.ScrollBar:Hide()
        guideScroll.ScrollBar:ClearAllPoints()

        content = CreateFrame("Frame", nil, guideScroll)
        content:SetSize(400, 1)
        guideScroll:SetScrollChild(content)
        addon.Dashboard_ApplySmoothScroll(guideScroll, content, 60, true)
    else
        content = env.guideScrollContent
    end

    local function CreateGuideAccordionCard(parent, titleText, startExpanded, onLayout)
        local card = CreateFrame("Frame", nil, parent)
        card:SetHeight(GUIDE_ACC_HEAD_H)
        card.expanded = startExpanded and true or false
        card.collapsedHeight = GUIDE_ACC_HEAD_H
        card.fullHeight = GUIDE_ACC_HEAD_H
        card:SetClipsChildren(true)

        local cBg = card:CreateTexture(nil, "BACKGROUND")
        cBg:SetAllPoints()
        cBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)

        local divider = card:CreateTexture(nil, "ARTWORK")
        divider:SetHeight(1)
        divider:SetPoint("BOTTOMLEFT", 14, 0)
        divider:SetPoint("BOTTOMRIGHT", -14, 0)
        local cdr, cdg, cdb = GetAccentColor()
        divider:SetColorTexture(cdr, cdg, cdb, 0.2)

        local accent = card:CreateTexture(nil, "ARTWORK")
        accent:SetSize(3, 20)
        accent:SetPoint("TOPLEFT", 14, -14)
        local cr, cg, cb = GetAccentColor()
        accent:SetColorTexture(cr, cg, cb, 1)

        local chevron = MakeText(card, card.expanded and "-" or "+", 14, 0.5, 0.5, 0.55, "RIGHT")
        chevron:SetPoint("TOPRIGHT", -18, -17)

        local rawTitle = titleText or ""
        local displayTitle = string.find(rawTitle, "|", 1, true) and rawTitle or rawTitle:upper()
        local lbl = MakeText(card, displayTitle, 13, 0.9, 0.9, 0.95, "LEFT")
        lbl:SetPoint("TOPLEFT", 28, -16)

        local headerBtn = CreateFrame("Button", nil, card)
        headerBtn:SetPoint("TOPLEFT", 0, 0)
        headerBtn:SetPoint("TOPRIGHT", 0, 0)
        headerBtn:SetHeight(GUIDE_ACC_HEAD_H)
        headerBtn:SetFrameLevel(card:GetFrameLevel() + 5)

        local sc = CreateFrame("Frame", nil, card)
        sc:SetPoint("TOPLEFT", 0, -GUIDE_ACC_HEAD_H)
        sc:SetPoint("RIGHT", card, "RIGHT", 0, 0)
        sc:SetHeight(1)
        sc:SetAlpha(card.expanded and 1 or 0)
        card.settingsContainer = sc

        local function updateExpandedVisuals()
            if card.expanded then
                cBg:SetColorTexture(SBgExpandedR, SBgExpandedG, SBgExpandedB, SBgA)
                chevron:SetText("-")
            else
                cBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)
                chevron:SetText("+")
            end
        end

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

        -- Same height + body alpha easing as DashboardDetailView CreateAccordionCard.
        card.anim = card:CreateAnimationGroup()
        local sizeAnim = card.anim:CreateAnimation("Animation")
        sizeAnim:SetDuration(GUIDE_ACC_ANIM_DURATION)
        sizeAnim:SetSmoothing("IN_OUT")

        card.anim:SetScript("OnUpdate", function()
            local progress = sizeAnim:GetSmoothProgress()
            local startH = card.expanded and card.collapsedHeight or (card.fullHeight or GUIDE_ACC_HEAD_H)
            local endH = card.expanded and (card.fullHeight or GUIDE_ACC_HEAD_H) or card.collapsedHeight
            local curH = startH + (endH - startH) * progress
            card:SetHeight(curH)
            if card.expanded then
                sc:SetAlpha(progress)
            else
                sc:SetAlpha(1 - progress)
            end
            if onLayout then onLayout() end
        end)

        card.anim:SetScript("OnFinished", function()
            local finalH = card.expanded and (card.fullHeight or GUIDE_ACC_HEAD_H) or card.collapsedHeight
            card:SetHeight(finalH)
            sc:SetAlpha(card.expanded and 1 or 0)
            updateExpandedVisuals()
            if onLayout then onLayout() end
        end)

        headerBtn:SetScript("OnClick", function()
            if card.anim:IsPlaying() then return end
            card.expanded = not card.expanded
            updateExpandedVisuals()
            card.anim:Play()
        end)

        if card.expanded then
            cBg:SetColorTexture(SBgExpandedR, SBgExpandedG, SBgExpandedB, SBgA)
        end

        return card
    end

    -- Hero: title block only (no card chrome — sits on guide background)
    dashAccentRefs.guideHeroRail = nil
    local heroCard = CreateFrame("Frame", nil, content)

    local heroTitle = MakeText(heroCard, L["DASH_GUIDE_HERO_TITLE"] or "Getting started", 22, 1, 1, 1, "LEFT")
    local heroTag = MakeText(heroCard, L["DASH_GUIDE_HERO_TAGLINE"] or "", 14, 0.78, 0.80, 0.85, "LEFT")
    local heroOverview = MakeDashboardWelcomeMixedScriptText(heroCard, L["DASH_WELCOME_LEARN_BODY"] or "", 13, 0.62, 0.65, 0.70, "LEFT")
    heroOverview:SetWordWrap(true)
    heroOverview:SetSpacing(4)
    local heroIntro = MakeDashboardWelcomeMixedScriptText(heroCard, L["DASH_GUIDE_HERO_INTRO"] or "", 13, 0.62, 0.65, 0.70, "LEFT")
    heroIntro:SetWordWrap(true)
    heroIntro:SetSpacing(4)

    -- Class-colour + dashboard theme prompt; SetHyperlinksEnabled on the Frame (not the FontString) enables cursor + OnHyperlinkClick.
    local heroThemeLinkHost = CreateFrame("Frame", nil, heroCard)
    heroThemeLinkHost:SetFrameLevel((heroCard:GetFrameLevel() or 0) + 2)
    heroThemeLinkHost:EnableMouse(true)
    heroThemeLinkHost:SetHyperlinksEnabled(true)
    heroThemeLinkHost:SetScript("OnHyperlinkClick", function(_, linkData, _, button)
        if button ~= "LeftButton" then return end
        if type(linkData) ~= "string" then return end
        if linkData == "hsdash:axis" and f.NavigateToAxisHome then
            f.NavigateToAxisHome()
        elseif linkData == "hsdash:theme" and f.NavigateToDashboardBackground then
            f.NavigateToDashboardBackground()
        elseif linkData == "hsdash:classcolours" and f.NavigateToClassColourTinting then
            f.NavigateToClassColourTinting()
        end
    end)
    local heroThemePrompt = MakeDashboardWelcomeMixedScriptText(heroThemeLinkHost, "", 13, 0.62, 0.65, 0.70, "LEFT")
    heroThemePrompt:SetWordWrap(true)
    heroThemePrompt:SetSpacing(4)

    local doLayout  -- assigned below; routes to LayoutGuideContent (standalone) or welcomeView re-layout (embedded)
    -- Cards are created before doLayout exists; indirection so accordion clicks always invoke the real layout.
    local accordionLayoutSink = { fn = nil }
    local function RunAccordionLayout()
        local fn = accordionLayoutSink.fn
        if fn then fn() end
    end
    local LayoutGuideContent

    local horizonCard = CreateGuideAccordionCard(content, L["DASH_GUIDE_HORIZON_HEADING"] or "Introduction to Modules", false, RunAccordionLayout)
    local horizonBullets = ApplyGuideBulletStatusTags(ColorGuideModuleNames(L["DASH_GUIDE_HORIZON_BULLETS"] or ""))
    local horizonBulletsFs = MakeDashboardWelcomeMixedScriptText(horizonCard.settingsContainer, horizonBullets, 12, 0.62, 0.65, 0.70, "LEFT")
    horizonBulletsFs:SetWordWrap(true)
    horizonBulletsFs:SetSpacing(5)

    -- Per-module detail accordions (order matches bullet list)
    local axisCard = CreateGuideAccordionCard(content, ModuleGuideSectionTitle("axis"), false, RunAccordionLayout)
    local axisBody = MakeDashboardWelcomeMixedScriptText(axisCard.settingsContainer, L["DASH_GUIDE_MOD_AXIS_BODY"] or "", 12, 0.62, 0.65, 0.70, "LEFT")
    axisBody:SetWordWrap(true)
    axisBody:SetSpacing(4)

    local focusCard = CreateGuideAccordionCard(content, ModuleGuideSectionTitle("focus"), false, RunAccordionLayout)
    local focusBody = MakeDashboardWelcomeMixedScriptText(focusCard.settingsContainer, L["DASH_GUIDE_MOD_FOCUS_BODY"] or "", 12, 0.62, 0.65, 0.70, "LEFT")
    focusBody:SetWordWrap(true)
    focusBody:SetSpacing(4)

    local presenceCard = CreateGuideAccordionCard(content, ModuleGuideSectionTitle("presence"), false, RunAccordionLayout)
    local presenceIntro = MakeDashboardWelcomeMixedScriptText(presenceCard.settingsContainer, L["DASH_GUIDE_PRESENCE_INTRO"] or "", 12, 0.62, 0.65, 0.70, "LEFT")
    presenceIntro:SetWordWrap(true)
    presenceIntro:SetSpacing(4)
    local presenceBody = MakeDashboardWelcomeMixedScriptText(presenceCard.settingsContainer, L["DASH_GUIDE_PRESENCE_BODY"] or "", 12, 0.62, 0.65, 0.70, "LEFT")
    presenceBody:SetWordWrap(true)
    presenceBody:SetSpacing(4)
    local presenceBlizzard = MakeDashboardWelcomeMixedScriptText(presenceCard.settingsContainer, L["DASH_GUIDE_PRESENCE_BLIZZARD"] or "", 12, 0.55, 0.58, 0.64, "LEFT")
    presenceBlizzard:SetWordWrap(true)
    presenceBlizzard:SetSpacing(4)

    local vistaCard = CreateGuideAccordionCard(content, ModuleGuideSectionTitle("vista"), false, RunAccordionLayout)
    local vistaBody = MakeDashboardWelcomeMixedScriptText(vistaCard.settingsContainer, L["DASH_GUIDE_MOD_VISTA_BODY"] or "", 12, 0.62, 0.65, 0.70, "LEFT")
    vistaBody:SetWordWrap(true)
    vistaBody:SetSpacing(4)

    local insightCard = CreateGuideAccordionCard(content, ModuleGuideSectionTitle("insight"), false, RunAccordionLayout)
    local insightBody = MakeDashboardWelcomeMixedScriptText(insightCard.settingsContainer, L["DASH_GUIDE_MOD_INSIGHT_BODY"] or "", 12, 0.62, 0.65, 0.70, "LEFT")
    insightBody:SetWordWrap(true)
    insightBody:SetSpacing(4)

    local cacheCard = CreateGuideAccordionCard(content, ModuleGuideSectionTitle("cache"), false, RunAccordionLayout)
    local cacheBody = MakeDashboardWelcomeMixedScriptText(cacheCard.settingsContainer, L["DASH_GUIDE_MOD_CACHE_BODY"] or "", 12, 0.62, 0.65, 0.70, "LEFT")
    cacheBody:SetWordWrap(true)
    cacheBody:SetSpacing(4)

    local essenceCard = CreateGuideAccordionCard(content, ModuleGuideSectionTitle("essence"), false, RunAccordionLayout)
    local essenceBody = MakeDashboardWelcomeMixedScriptText(essenceCard.settingsContainer, L["DASH_GUIDE_MOD_ESSENCE_BODY"] or "", 12, 0.62, 0.65, 0.70, "LEFT")
    essenceBody:SetWordWrap(true)
    essenceBody:SetSpacing(4)

    local meridianCard = CreateGuideAccordionCard(content, ModuleGuideSectionTitle("meridian"), false, RunAccordionLayout)
    local meridianBody = MakeDashboardWelcomeMixedScriptText(meridianCard.settingsContainer, L["DASH_GUIDE_MOD_MERIDIAN_BODY"] or "", 12, 0.62, 0.65, 0.70, "LEFT")
    meridianBody:SetWordWrap(true)
    meridianBody:SetSpacing(4)

    local function doLayoutAccordionCards(w, innerPad, y)
        local function layoutAccordionCard(card, bodyWidgets, extraGapAfterBodies)
            extraGapAfterBodies = extraGapAfterBodies or 0
            local by = 10
            for _, fs in ipairs(bodyWidgets) do
                fs:ClearAllPoints()
                fs:SetWidth(w - innerPad * 2)
                fs:SetPoint("TOPLEFT", card.settingsContainer, "TOPLEFT", innerPad, -by)
                by = by + fs:GetHeight() + (extraGapAfterBodies > 0 and 8 or 6)
            end
            by = by + extraGapAfterBodies
            card.fullHeight = GUIDE_ACC_HEAD_H + by
            -- During expand/collapse animation the card owns height; do not snap (matches DetailView + UpdateDetailLayout).
            if not (card.anim and card.anim:IsPlaying()) then
                card:SetHeight(card.expanded and card.fullHeight or card.collapsedHeight)
            end
            card:SetWidth(w)
            card:ClearAllPoints()
            card:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
            y = y + card:GetHeight() + 8
        end
        layoutAccordionCard(horizonCard, { horizonBulletsFs }, 10)
        layoutAccordionCard(axisCard, { axisBody }, 10)
        layoutAccordionCard(focusCard, { focusBody }, 10)
        layoutAccordionCard(presenceCard, { presenceIntro, presenceBody, presenceBlizzard }, 10)
        layoutAccordionCard(vistaCard, { vistaBody }, 10)
        layoutAccordionCard(insightCard, { insightBody }, 10)
        layoutAccordionCard(cacheCard, { cacheBody }, 10)
        layoutAccordionCard(essenceCard, { essenceBody }, 10)
        layoutAccordionCard(meridianCard, { meridianBody }, 10)
        return y
    end

    local function layoutGuideHero(w, startY)
        horizonBulletsFs:SetText(ApplyGuideBulletStatusTags(ColorGuideModuleNames(L["DASH_GUIDE_HORIZON_BULLETS"] or "")))
        local y = startY

        heroCard:SetWidth(w)
        heroCard:ClearAllPoints()
        heroCard:SetPoint("TOPLEFT", content, "TOPLEFT", SCROLL_BODY_X_INSET, -y)
        heroTitle:SetWidth(w)
        heroTitle:ClearAllPoints()
        heroTitle:SetPoint("TOPLEFT", heroCard, "TOPLEFT", 0, 0)
        local yt = heroTitle:GetHeight() + 10

        local themeText = L["DASH_GUIDE_HERO_THEME_PROMPT"] or ""
        heroThemePrompt:SetText(themeText)
        if themeText ~= "" then
            heroThemePrompt:SetWidth(w)
            heroThemePrompt:ClearAllPoints()
            heroThemePrompt:SetPoint("TOPLEFT", heroThemeLinkHost, "TOPLEFT", 0, 0)
            heroThemeLinkHost:SetWidth(w)
            heroThemeLinkHost:SetHeight(math.max(heroThemePrompt:GetHeight(), 1))
            heroThemeLinkHost:ClearAllPoints()
            heroThemeLinkHost:SetPoint("TOPLEFT", heroCard, "TOPLEFT", 0, -yt)
            heroThemeLinkHost:Show()
            heroThemePrompt:Show()
            yt = yt + heroThemeLinkHost:GetHeight() + 12
        else
            heroThemePrompt:SetText("")
            heroThemeLinkHost:Hide()
        end

        local tagText = L["DASH_GUIDE_HERO_TAGLINE"] or ""
        if tagText ~= "" then
            heroTag:SetText(tagText)
            heroTag:SetWidth(w)
            heroTag:ClearAllPoints()
            heroTag:SetPoint("TOPLEFT", heroCard, "TOPLEFT", 0, -yt)
            heroTag:Show()
            yt = yt + heroTag:GetHeight() + 10
        else
            heroTag:SetText("")
            heroTag:Hide()
        end
        heroOverview:SetText(L["DASH_WELCOME_LEARN_BODY"] or "")
        heroOverview:SetWidth(w)
        heroOverview:ClearAllPoints()
        heroOverview:SetPoint("TOPLEFT", heroCard, "TOPLEFT", 0, -yt)
        yt = yt + heroOverview:GetHeight() + 12
        heroIntro:SetWidth(w)
        heroIntro:ClearAllPoints()
        heroIntro:SetPoint("TOPLEFT", heroCard, "TOPLEFT", 0, -yt)
        yt = yt + heroIntro:GetHeight() + 18
        heroCard:SetHeight(math.max(yt, 100))
        y = y + heroCard:GetHeight() + 20
        return y
    end

    if not embeddedInWelcome then
        LayoutGuideContent = function()
            local rawW = guideBg:GetWidth() or 0
            local w = math.max(280, rawW - 40)
            -- Match Patch Notes: footer anchors to full view + same width math so Community & Support block height matches.
            local viewW = guideView:GetWidth() or 0
            local wFooter = math.max(280, viewW - 40)
            local innerPad = 28

            -- Footer layout (shared factory with Welcome)
            footerObj.layout(wFooter, 0, guideView)

            content:SetWidth(w)
            guideScroll:ClearAllPoints()
            guideScroll:SetPoint("TOPLEFT", guideBg, "TOPLEFT", SCROLL_TO_BG_INSET, -GUIDE_CONTENT_TOP_PAD)
            guideScroll:SetPoint("BOTTOMLEFT", footerPanel, "TOPLEFT", 0, SCROLL_ABOVE_FOOTER_GAP)
            guideScroll:SetPoint("TOPRIGHT", guideBg, "TOPRIGHT", -SCROLL_TO_BG_INSET, -GUIDE_CONTENT_TOP_PAD)
            guideScroll:SetPoint("BOTTOMRIGHT", footerPanel, "TOPRIGHT", 0, SCROLL_ABOVE_FOOTER_GAP)

            local y = layoutGuideHero(w, HERO_TOP_PAD)
            y = doLayoutAccordionCards(w, innerPad, y)
            y = y + 8
            content:SetHeight(math.max(y + 8, 1))

            if guideScroll.UpdateScrollChildRect then
                guideScroll:UpdateScrollChildRect()
            end
            local viewH = guideScroll:GetHeight() or 0
            local contentH = content:GetHeight() or 0
            local maxScroll = math.max(0, contentH - viewH)
            local curScroll = guideScroll:GetVerticalScroll() or 0
            if curScroll > maxScroll then
                guideScroll:SetVerticalScroll(maxScroll)
                guideScroll.targetScroll = nil
            end
        end
        doLayout = LayoutGuideContent
        accordionLayoutSink.fn = doLayout

        guideView:SetScript("OnShow", function()
            LayoutGuideContent()
            if C_Timer and C_Timer.After then
                C_Timer.After(0, LayoutGuideContent)
            end
        end)
        guideView:SetScript("OnSizeChanged", function()
            if guideView:IsShown() then LayoutGuideContent() end
        end)

        f.ShowModuleGuide = function()
            if f.pnChangelogHeaderBtn then f.pnChangelogHeaderBtn:Hide() end
            HideContextHeader()
            detailView:Hide()
            subCategoryView:Hide()
            dashboardView:Hide()
            welcomeView:Hide()
            patchNotesView:Hide()
            guideView:SetAlpha(0)
            guideView:Show()
            UIFrameFadeIn(guideView, 0.2, 0, 1)
            if head then head:Show() end
            if headSub then
                headSub:Show()
                headSub:SetText(L["DASH_GUIDE_HEAD_SUB"] or "What each part of Horizon does")
            end
            if f.searchView then f.searchView:Hide() end
            if searchBarShell then searchBarShell:Hide() end
            if f.HideSearchDropdown then f.HideSearchDropdown() end
            if f.DockSearchDropdownForModule then f.DockSearchDropdownForModule() end
            f.currentModuleKey = nil
            SetSidebarState({ view = "guide", activeModuleKey = CLEAR, activeCategoryIndex = CLEAR })
            if addon.DashboardPreview and addon.DashboardPreview.SetActiveModuleKey then
                addon.DashboardPreview.SetActiveModuleKey(nil)
            end
            if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
        end
    else
        -- Embedded mode: guide content lives inside the Welcome tab scroll area.
        -- LayoutWelcomeContent calls this after positioning feed items; returns updated y.
        addon.DashboardModuleGuide_LayoutEmbedded = function(w, startY, innerPad)
            innerPad = innerPad or 28
            local y = layoutGuideHero(w, startY)
            y = doLayoutAccordionCards(w, innerPad, y)
            y = y + 8
            return y
        end
        doLayout = function()
            if welcomeView and welcomeView._layoutWelcomeContent then
                welcomeView._layoutWelcomeContent()
            end
        end
        accordionLayoutSink.fn = doLayout
    end
end
