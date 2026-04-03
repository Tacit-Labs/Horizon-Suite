--[[
    Horizon Suite - Dashboard Welcome tab (scrollable feed from DashboardWelcomeFeedData).
    Wired from DashboardHomeWelcome_Init via addon.DashboardWelcomeView_Init(env).
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then _G.HorizonSuite = {} end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local tinsert = table.insert

-- Playable classes, left-to-right strip (matches core/ClassIconMedia.lua bundled set).
local WELCOME_CLASS_ICON_STRIP_ORDER = {
    "DEATHKNIGHT", "DEMONHUNTER", "DRUID", "EVOKER", "HUNTER", "MAGE", "MONK",
    "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR",
}

--- @return table
local function GetSortedWelcomeFeed()
    local src = addon.DashboardWelcomeFeed
    if not src or #src == 0 then
        return {}
    end
    local t = {}
    for i = 1, #src do
        t[i] = src[i]
    end
    table.sort(t, function(a, b)
        return (a.sort or 0) > (b.sort or 0)
    end)
    return t
end

--- @param env table Same dashboard env as DashboardHomeWelcome_Init (frames, MakeText, L, …).
--- @return nil
function addon.DashboardWelcomeView_Init(env)
    local f = env.f
    local addonRef = env.addon
    local L = env.L
    local welcomeView = env.welcomeView
    local detailView = env.detailView
    local subCategoryView = env.subCategoryView
    local dashboardView = env.dashboardView
    local patchNotesView = env.patchNotesView
    local dashScrollTopOffset = env.dashScrollTopOffset
    local dashAccentRefs = env.dashAccentRefs
    local GetAccentColor = env.GetAccentColor
    local MakeText = env.MakeText
    local MakeDashboardWelcomeMixedScriptText = env.MakeDashboardWelcomeMixedScriptText
    local HideContextHeader = env.HideContextHeader
    local SetSidebarState = env.setSidebarState
    local CLEAR = env.CLEAR
    local searchBox = env.searchBox
    local head = env.head
    local headSub = env.headSub
    local DASHBOARD_CONTENT_CARD_ALPHA_MULT = env.DASHBOARD_CONTENT_CARD_ALPHA_MULT or 1

    local WDef = addonRef.OptionsWidgetsDef
    local SBg = (WDef and WDef.SectionCardBg) or { 0.09, 0.09, 0.11, 0.96 }
    local SBgA = SBg[4] * DASHBOARD_CONTENT_CARD_ALPHA_MULT
    local SBgHoverR, SBgHoverG, SBgHoverB = 0.11, 0.11, 0.13
    local SBgExpandedR, SBgExpandedG, SBgExpandedB = 0.10, 0.10, 0.12

    local WELCOME_BG_TOP_NUDGE = 50
    local WELCOME_CONTENT_TOP_PAD = 6
    local WELCOME_ACC_HEAD_H = 48
    local WELCOME_SCROLL_BODY_X_INSET = 0
    local WELCOME_SCROLL_ABOVE_FOOTER_GAP = (addonRef.DashboardConstants and addonRef.DashboardConstants.COMMUNITY_FOOTER_SCROLL_GAP) or 24
    local SCROLL_TO_BG_INSET = 20
    local WELCOME_COMING_SOON_GIF_MAX_H = 132
    local WELCOME_COMING_SOON_TWO_COL_MIN_W = 440
    local WELCOME_COMING_SOON_GIF_COL_W = 200

    local function ShowCopyURL(label, url)
        if addonRef.ShowURLCopyBox then
            addonRef.ShowURLCopyBox(url, (L["DASH_COPY_LINK_X"] or "Copy link — %s"):format(label))
        end
    end

    local welcomeBg = welcomeView:CreateTexture(nil, "BACKGROUND")
    welcomeBg:SetPoint("TOPLEFT", 28, dashScrollTopOffset + WELCOME_BG_TOP_NUDGE)
    welcomeBg:SetPoint("BOTTOMRIGHT", welcomeView, "BOTTOMRIGHT", -28, 20)

    local footerPanel = CreateFrame("Frame", nil, welcomeView)
    footerPanel:SetFrameLevel((welcomeView:GetFrameLevel() or 0) + 10)

    local welcomeScroll = CreateFrame("ScrollFrame", nil, welcomeView, "UIPanelScrollFrameTemplate")
    welcomeScroll:SetFrameLevel((welcomeView:GetFrameLevel() or 0) + 2)
    welcomeScroll.ScrollBar:Hide()
    welcomeScroll.ScrollBar:ClearAllPoints()

    local content = CreateFrame("Frame", nil, welcomeScroll)
    content:SetSize(400, 1)
    welcomeScroll:SetScrollChild(content)
    addonRef.Dashboard_ApplySmoothScroll(welcomeScroll, content, 60, true)

    local welcomeBlockPool = {}

    local LayoutWelcomeContent

    --- Accordion aligned with detail-view section cards; calls onLayout during resize animation.
    --- @param startExpanded boolean|nil
    --- @return Frame
    local function CreateWelcomeAccordionCard(parent, titleText, onLayout, startExpanded)
        local card = CreateFrame("Frame", nil, parent)
        card:SetHeight(WELCOME_ACC_HEAD_H)
        card.expanded = startExpanded and true or false
        card.collapsedHeight = WELCOME_ACC_HEAD_H
        card.fullHeight = WELCOME_ACC_HEAD_H
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

        local chevron = MakeText(card, "+", 14, 0.5, 0.5, 0.55, "RIGHT")
        chevron:SetPoint("TOPRIGHT", -18, -17)

        local lbl = MakeText(card, (titleText or ""):upper(), 13, 0.9, 0.9, 0.95, "LEFT")
        lbl:SetPoint("TOPLEFT", 28, -16)
        card.titleLabel = lbl

        local headerBtn = CreateFrame("Button", nil, card)
        headerBtn:SetPoint("TOPLEFT", 0, 0)
        headerBtn:SetPoint("TOPRIGHT", 0, 0)
        headerBtn:SetHeight(WELCOME_ACC_HEAD_H)
        headerBtn:SetFrameLevel(card:GetFrameLevel() + 5)

        local sc = CreateFrame("Frame", nil, card)
        sc:SetPoint("TOPLEFT", 0, -WELCOME_ACC_HEAD_H)
        sc:SetPoint("RIGHT", card, "RIGHT", 0, 0)
        sc:SetHeight(1)
        sc:SetAlpha(0)
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

        card.anim = card:CreateAnimationGroup()
        local sizeAnim = card.anim:CreateAnimation("Animation")
        sizeAnim:SetDuration(0.15)
        sizeAnim:SetSmoothing("IN_OUT")

        card.anim:SetScript("OnUpdate", function()
            local progress = sizeAnim:GetSmoothProgress()
            local startH = card.expanded and card.collapsedHeight or (card.fullHeight or WELCOME_ACC_HEAD_H)
            local endH = card.expanded and (card.fullHeight or WELCOME_ACC_HEAD_H) or card.collapsedHeight
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
            local finalH = card.expanded and (card.fullHeight or WELCOME_ACC_HEAD_H) or card.collapsedHeight
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
            sc:SetAlpha(1)
        else
            sc:SetAlpha(0)
        end
        updateExpandedVisuals()

        return card
    end

    local function CreateWelcomeURLLinkButton(parent, text, url, linkLabelForDialog)
        local btn = CreateFrame("Button", nil, parent)
        btn:SetFrameLevel((parent:GetFrameLevel() or 0) + 2)
        local lbl = MakeDashboardWelcomeMixedScriptText(btn, text, 12, 0.45, 0.72, 0.95, "LEFT")
        lbl:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, 0)
        local underline = btn:CreateTexture(nil, "OVERLAY")
        underline:SetHeight(1)
        underline:SetPoint("BOTTOMLEFT", lbl, "BOTTOMLEFT", 0, -1)
        underline:SetPoint("BOTTOMRIGHT", lbl, "BOTTOMRIGHT", 0, -1)
        underline:SetColorTexture(0.45, 0.72, 0.95, 0.65)
        underline:Hide()
        btn:SetScript("OnClick", function()
            local dlg = (lbl.GetText and lbl:GetText()) or linkLabelForDialog or text
            ShowCopyURL(dlg ~= "" and dlg or (linkLabelForDialog or text), url)
        end)
        btn:SetScript("OnEnter", function()
            lbl:SetTextColor(0.65, 0.88, 1, 1)
            underline:Show()
        end)
        btn:SetScript("OnLeave", function()
            lbl:SetTextColor(0.45, 0.72, 0.95, 1)
            underline:Hide()
        end)
        btn._linkLabel = lbl
        local lh = lbl:GetHeight() or 14
        btn:SetSize(math.max(40, (lbl:GetStringWidth() or 0) + 4), math.max(14, lh + 2))
        return btn
    end

    local function ComingSoonImageDisplaySize(tex, boxW, boxH, capScaleOne)
        if not tex or not boxW or not boxH or boxW < 1 or boxH < 1 then
            return math.max(1, boxW or 1), math.max(1, boxH or 1)
        end
        local nw = tex.GetTextureFileWidth and tex:GetTextureFileWidth() or 0
        local nh = tex.GetTextureFileHeight and tex:GetTextureFileHeight() or 0
        if nw < 1 or nh < 1 then
            return boxW, boxH
        end
        local scale = math.min(boxW / nw, boxH / nh)
        if capScaleOne then
            scale = math.min(scale, 1)
        end
        return math.max(1, math.floor(nw * scale + 0.5)), math.max(1, math.floor(nh * scale + 0.5))
    end

    --- Ensure pooled widgets exist for this feed entry.
    --- @param entry table
    --- @return table|nil widget bundle
    local function EnsureWelcomeBlock(entry)
        if not entry or not entry.id or not entry.kind then
            return nil
        end
        local id = entry.id
        local kind = entry.kind
        if welcomeBlockPool[id] then
            return welcomeBlockPool[id]
        end

        if kind == "static_header" then
            local titleFs = MakeText(content, "", 22, 1, 1, 1, "LEFT")
            local introFs = MakeDashboardWelcomeMixedScriptText(content, "", 13, 0.72, 0.74, 0.78, "LEFT")
            introFs:SetWordWrap(true)
            introFs:SetSpacing(4)
            welcomeBlockPool[id] = { kind = kind, titleFs = titleFs, introFs = introFs }
            return welcomeBlockPool[id]
        end

        if kind == "class_icon_strip" then
            local hero = CreateFrame("Frame", nil, content)
            hero:SetClipsChildren(true)
            local classIconsBg = hero:CreateTexture(nil, "BACKGROUND")
            classIconsBg:SetAllPoints()
            classIconsBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)
            local classIconsDivider = hero:CreateTexture(nil, "ARTWORK")
            classIconsDivider:SetHeight(1)
            classIconsDivider:SetPoint("BOTTOMLEFT", 14, 0)
            classIconsDivider:SetPoint("BOTTOMRIGHT", -14, 0)
            local cidr, cidg, cidb = GetAccentColor()
            classIconsDivider:SetColorTexture(cidr, cidg, cidb, 0.2)
            local classIconsAccent = hero:CreateTexture(nil, "ARTWORK")
            classIconsAccent:SetWidth(3)
            local ciar, ciag, ciab = GetAccentColor()
            classIconsAccent:SetColorTexture(ciar, ciag, ciab, 1)
            local classIconsTitleFs = MakeText(hero, "", 22, 1, 1, 1, "LEFT")
            local classIconsLeadFs = MakeDashboardWelcomeMixedScriptText(hero, "", 13, 0.62, 0.65, 0.70, "LEFT")
            classIconsLeadFs:SetWordWrap(true)
            classIconsLeadFs:SetSpacing(4)
            local classIconsThankBoofulsFs = MakeDashboardWelcomeMixedScriptText(hero, "", 13, 0.62, 0.65, 0.70, "LEFT")
            classIconsThankBoofulsFs:SetWordWrap(true)
            classIconsThankBoofulsFs:SetSpacing(4)
            local classIconsCreatedRow = CreateFrame("Frame", nil, hero)
            classIconsCreatedRow:SetHeight(20)
            local classIconsCreatedPrefixFs = MakeDashboardWelcomeMixedScriptText(classIconsCreatedRow, "", 12, 0.62, 0.65, 0.70, "LEFT")
            classIconsCreatedPrefixFs:SetWordWrap(false)
            classIconsCreatedPrefixFs:SetPoint("TOPLEFT", classIconsCreatedRow, "TOPLEFT", 0, 0)
            local artistUrl = entry.artistUrl or ""
            local classIconsArtistBtn = CreateWelcomeURLLinkButton(classIconsCreatedRow, "", artistUrl, "")
            classIconsArtistBtn:SetPoint("BOTTOMLEFT", classIconsCreatedPrefixFs, "BOTTOMRIGHT", 2, 0)
            local classIconsStrip = CreateFrame("Frame", nil, hero)
            classIconsStrip.textures = {}
            for i = 1, #WELCOME_CLASS_ICON_STRIP_ORDER do
                local tex = classIconsStrip:CreateTexture(nil, "ARTWORK", nil, 1)
                tex:SetTexCoord(0, 1, 0, 1)
                classIconsStrip.textures[i] = tex
            end
            welcomeBlockPool[id] = {
                kind = kind,
                root = hero,
                classIconsAccent = classIconsAccent,
                classIconsTitleFs = classIconsTitleFs,
                classIconsLeadFs = classIconsLeadFs,
                classIconsThankBoofulsFs = classIconsThankBoofulsFs,
                classIconsCreatedRow = classIconsCreatedRow,
                classIconsCreatedPrefixFs = classIconsCreatedPrefixFs,
                classIconsArtistBtn = classIconsArtistBtn,
                classIconsStrip = classIconsStrip,
                entry = entry,
            }
            return welcomeBlockPool[id]
        end

        -- Same card chrome and 22pt title as class_icon_strip; title + body only (no accordion, no strip).
        if kind == "text_banner" then
            local hero = CreateFrame("Frame", nil, content)
            hero:SetClipsChildren(true)
            local banBg = hero:CreateTexture(nil, "BACKGROUND")
            banBg:SetAllPoints()
            banBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)
            local banDivider = hero:CreateTexture(nil, "ARTWORK")
            banDivider:SetHeight(1)
            banDivider:SetPoint("BOTTOMLEFT", 14, 0)
            banDivider:SetPoint("BOTTOMRIGHT", -14, 0)
            local bdr, bdg, bdb = GetAccentColor()
            banDivider:SetColorTexture(bdr, bdg, bdb, 0.2)
            local banAccent = hero:CreateTexture(nil, "ARTWORK")
            banAccent:SetWidth(3)
            local bar, bag, bab = GetAccentColor()
            banAccent:SetColorTexture(bar, bag, bab, 1)
            local titleFs = MakeText(hero, "", 22, 1, 1, 1, "LEFT")
            local bodyFs = MakeDashboardWelcomeMixedScriptText(hero, "", 13, 0.62, 0.65, 0.70, "LEFT")
            bodyFs:SetWordWrap(true)
            bodyFs:SetSpacing(4)
            welcomeBlockPool[id] = {
                kind = kind,
                root = hero,
                bannerAccent = banAccent,
                titleFs = titleFs,
                bodyFs = bodyFs,
            }
            return welcomeBlockPool[id]
        end

        if kind == "hero_media" then
            local comingSoonHero = CreateFrame("Frame", nil, content)
            comingSoonHero:SetClipsChildren(true)
            local heroBg = comingSoonHero:CreateTexture(nil, "BACKGROUND")
            heroBg:SetAllPoints()
            heroBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)
            local heroDivider = comingSoonHero:CreateTexture(nil, "ARTWORK")
            heroDivider:SetHeight(1)
            heroDivider:SetPoint("BOTTOMLEFT", 14, 0)
            heroDivider:SetPoint("BOTTOMRIGHT", -14, 0)
            local hdr, hdg, hdb = GetAccentColor()
            heroDivider:SetColorTexture(hdr, hdg, hdb, 0.2)
            local heroAccent = comingSoonHero:CreateTexture(nil, "ARTWORK")
            heroAccent:SetWidth(3)
            local cr, cg, cb = GetAccentColor()
            heroAccent:SetColorTexture(cr, cg, cb, 1)
            local comingSoonGif = comingSoonHero:CreateTexture(nil, "ARTWORK", nil, 1)
            local mediaPath = entry.mediaPath or "Interface/AddOns/HorizonSuite/media/cache.tga"
            comingSoonGif:SetTexture(mediaPath)
            local comingSoonTitleFs = MakeText(comingSoonHero, "", 22, 1, 1, 1, "LEFT")
            local comingSoonTagFs = MakeText(comingSoonHero, "", 14, 0.78, 0.80, 0.85, "LEFT")
            local comingSoonBodyFs = MakeDashboardWelcomeMixedScriptText(comingSoonHero, "", 13, 0.62, 0.65, 0.70, "LEFT")
            comingSoonBodyFs:SetWordWrap(true)
            comingSoonBodyFs:SetSpacing(4)
            welcomeBlockPool[id] = {
                kind = kind,
                root = comingSoonHero,
                heroAccent = heroAccent,
                comingSoonGif = comingSoonGif,
                comingSoonTitleFs = comingSoonTitleFs,
                comingSoonTagFs = comingSoonTagFs,
                comingSoonBodyFs = comingSoonBodyFs,
                entry = entry,
            }
            return welcomeBlockPool[id]
        end

        if kind == "accordion" then
            local card = CreateWelcomeAccordionCard(content, "", function()
                LayoutWelcomeContent()
            end)
            local bodyFs = MakeDashboardWelcomeMixedScriptText(card.settingsContainer, "", 12, 0.62, 0.65, 0.70, "LEFT")
            bodyFs:SetWordWrap(true)
            bodyFs:SetSpacing(4)
            welcomeBlockPool[id] = {
                kind = kind,
                card = card,
                bodyFs = bodyFs,
                entry = entry,
            }
            return welcomeBlockPool[id]
        end

        return nil
    end

    local footerObj = addonRef.Dashboard_CreateCommunityFooter(footerPanel, {
        L = L,
        GetAccentColor = GetAccentColor,
        MakeText = MakeText,
        addon = addonRef,
    })
    tinsert(dashAccentRefs.communityFooterTopRules, footerObj.footerTopRule)

    LayoutWelcomeContent = function()
        local rawW = welcomeBg:GetWidth() or 0
        local w = math.max(280, rawW - 40)
        local viewW = welcomeView:GetWidth() or 0
        local wFooter = math.max(280, viewW - 40)
        local innerPad = 28

        footerObj.layout(wFooter, 0, welcomeView)

        welcomeScroll:ClearAllPoints()
        welcomeScroll:SetPoint("TOPLEFT", welcomeBg, "TOPLEFT", SCROLL_TO_BG_INSET, -WELCOME_CONTENT_TOP_PAD)
        welcomeScroll:SetPoint("BOTTOMLEFT", footerPanel, "TOPLEFT", 0, WELCOME_SCROLL_ABOVE_FOOTER_GAP)
        welcomeScroll:SetPoint("TOPRIGHT", welcomeBg, "TOPRIGHT", -SCROLL_TO_BG_INSET, -WELCOME_CONTENT_TOP_PAD)
        welcomeScroll:SetPoint("BOTTOMRIGHT", footerPanel, "TOPRIGHT", 0, WELCOME_SCROLL_ABOVE_FOOTER_GAP)

        content:SetWidth(w)
        local y = 0
        local feed = GetSortedWelcomeFeed()
        local activeIds = {}

        for fi = 1, #feed do
            local entry = feed[fi]
            local pool = EnsureWelcomeBlock(entry)
            if pool then
                activeIds[entry.id] = true
                local k = entry.kind

                if k == "static_header" then
                    pool.titleFs:SetText(L[entry.titleKey] or "")
                    pool.introFs:SetText(L[entry.introKey] or "")
                    pool.titleFs:SetWidth(w)
                    pool.titleFs:ClearAllPoints()
                    pool.titleFs:SetPoint("TOPLEFT", content, "TOPLEFT", WELCOME_SCROLL_BODY_X_INSET, -y)
                    y = y + pool.titleFs:GetHeight() + 12
                    pool.introFs:SetWidth(w)
                    pool.introFs:ClearAllPoints()
                    pool.introFs:SetPoint("TOPLEFT", content, "TOPLEFT", WELCOME_SCROLL_BODY_X_INSET, -y)
                    y = y + pool.introFs:GetHeight() + 12
                    pool.titleFs:Show()
                    pool.introFs:Show()

                elseif k == "class_icon_strip" then
                    local classHeroPad = 28
                    local classTextW = w - classHeroPad * 2
                    pool.classIconsTitleFs:SetText(L[entry.titleKey] or "")
                    pool.classIconsLeadFs:SetText(L[entry.leadKey] or "")
                    pool.classIconsThankBoofulsFs:SetText(L[entry.thankKey] or "")
                    pool.classIconsCreatedPrefixFs:SetText(L[entry.createdPrefixKey] or "")
                    local artistName = L[entry.artistNameKey] or ""
                    if pool.classIconsArtistBtn._linkLabel then
                        pool.classIconsArtistBtn._linkLabel:SetText(artistName)
                        pool.classIconsArtistBtn:SetWidth(math.max(40, (pool.classIconsArtistBtn._linkLabel:GetStringWidth() or 0) + 4))
                        pool.classIconsArtistBtn:SetHeight(math.max(16, (pool.classIconsArtistBtn._linkLabel:GetHeight() or 14) + 2))
                    end
                    local hero = pool.root
                    hero:SetWidth(w)
                    hero:ClearAllPoints()
                    hero:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
                    pool.classIconsAccent:ClearAllPoints()
                    pool.classIconsAccent:SetPoint("TOPLEFT", hero, "TOPLEFT", 14, -14)
                    local cyt = classHeroPad
                    pool.classIconsTitleFs:SetWidth(classTextW)
                    pool.classIconsTitleFs:ClearAllPoints()
                    pool.classIconsTitleFs:SetPoint("TOPLEFT", hero, "TOPLEFT", classHeroPad, -cyt)
                    cyt = cyt + pool.classIconsTitleFs:GetHeight() + 8
                    pool.classIconsLeadFs:SetWidth(classTextW)
                    pool.classIconsLeadFs:ClearAllPoints()
                    pool.classIconsLeadFs:SetPoint("TOPLEFT", hero, "TOPLEFT", classHeroPad, -cyt)
                    cyt = cyt + pool.classIconsLeadFs:GetHeight() + 6
                    pool.classIconsThankBoofulsFs:SetWidth(classTextW)
                    pool.classIconsThankBoofulsFs:ClearAllPoints()
                    pool.classIconsThankBoofulsFs:SetPoint("TOPLEFT", hero, "TOPLEFT", classHeroPad, -cyt)
                    cyt = cyt + pool.classIconsThankBoofulsFs:GetHeight() + 6
                    pool.classIconsCreatedRow:SetWidth(classTextW)
                    pool.classIconsCreatedRow:ClearAllPoints()
                    pool.classIconsCreatedRow:SetPoint("TOPLEFT", hero, "TOPLEFT", classHeroPad, -cyt)
                    pool.classIconsCreatedPrefixFs:ClearAllPoints()
                    pool.classIconsCreatedPrefixFs:SetPoint("TOPLEFT", pool.classIconsCreatedRow, "TOPLEFT", 0, 0)
                    pool.classIconsArtistBtn:ClearAllPoints()
                    pool.classIconsArtistBtn:SetPoint("BOTTOMLEFT", pool.classIconsCreatedPrefixFs, "BOTTOMRIGHT", 2, 0)
                    local rowH = math.max(pool.classIconsCreatedPrefixFs:GetHeight(), pool.classIconsArtistBtn:GetHeight())
                    pool.classIconsCreatedRow:SetHeight(math.max(rowH, 1))
                    cyt = cyt + rowH + 6
                    local nStrip = #WELCOME_CLASS_ICON_STRIP_ORDER
                    local stripGap = 4
                    local maxStripW = classTextW
                    local iconPx = math.max(8, math.floor((maxStripW - (nStrip - 1) * stripGap) / nStrip))
                    pool.classIconsStrip:ClearAllPoints()
                    pool.classIconsStrip:SetPoint("TOPLEFT", hero, "TOPLEFT", classHeroPad, -cyt)
                    pool.classIconsStrip:SetSize(maxStripW, iconPx + 6)
                    for i = 1, nStrip do
                        local tex = pool.classIconsStrip.textures[i]
                        if tex then
                            local cf = WELCOME_CLASS_ICON_STRIP_ORDER[i]
                            if addonRef.ResolveClassIconDisplay then
                                local disp = addonRef.ResolveClassIconDisplay(cf, "custom")
                                if disp and disp.kind == "file" and disp.path then
                                    tex:SetTexture(disp.path)
                                end
                            end
                            tex:SetSize(iconPx, iconPx)
                            tex:ClearAllPoints()
                            tex:SetPoint("TOPLEFT", pool.classIconsStrip, "TOPLEFT", (i - 1) * (iconPx + stripGap), -2)
                        end
                    end
                    local stripH = iconPx + 10
                    cyt = cyt + stripH
                    hero:SetHeight(math.max(cyt + classHeroPad, 1))
                    pool.classIconsAccent:SetPoint("BOTTOMLEFT", hero, "BOTTOMLEFT", 14, 14)
                    y = y + hero:GetHeight() + 8
                    hero:Show()

                elseif k == "text_banner" then
                    local banPad = 28
                    local textW = w - banPad * 2
                    pool.titleFs:SetText(L[entry.titleKey] or "")
                    pool.bodyFs:SetText(L[entry.bodyKey] or "")
                    local hero = pool.root
                    hero:SetWidth(w)
                    hero:ClearAllPoints()
                    hero:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
                    pool.bannerAccent:ClearAllPoints()
                    pool.bannerAccent:SetPoint("TOPLEFT", hero, "TOPLEFT", 14, -14)
                    local cyt = banPad
                    pool.titleFs:SetWidth(textW)
                    pool.titleFs:ClearAllPoints()
                    pool.titleFs:SetPoint("TOPLEFT", hero, "TOPLEFT", banPad, -cyt)
                    cyt = cyt + pool.titleFs:GetHeight() + 8
                    pool.bodyFs:SetWidth(textW)
                    pool.bodyFs:ClearAllPoints()
                    pool.bodyFs:SetPoint("TOPLEFT", hero, "TOPLEFT", banPad, -cyt)
                    cyt = cyt + pool.bodyFs:GetHeight()
                    hero:SetHeight(math.max(cyt + banPad, 1))
                    pool.bannerAccent:SetPoint("BOTTOMLEFT", hero, "BOTTOMLEFT", 14, 14)
                    y = y + hero:GetHeight() + 8
                    hero:Show()

                elseif k == "hero_media" then
                    local heroPad = 28
                    pool.comingSoonTitleFs:SetText(L[entry.titleKey] or "")
                    pool.comingSoonTagFs:SetText(L[entry.taglineKey] or "")
                    pool.comingSoonBodyFs:SetText(L[entry.bodyKey] or "")
                    if entry.mediaPath and pool.comingSoonGif.SetTexture then
                        pool.comingSoonGif:SetTexture(entry.mediaPath)
                    end
                    local twoCol = w >= WELCOME_COMING_SOON_TWO_COL_MIN_W
                    local gifColW = twoCol and WELCOME_COMING_SOON_GIF_COL_W or math.min(w - heroPad * 2, 300)
                    local textW = twoCol and math.max(120, w - heroPad * 2 - gifColW - 16) or (w - heroPad * 2)
                    local dispW, dispH = ComingSoonImageDisplaySize(pool.comingSoonGif, gifColW, WELCOME_COMING_SOON_GIF_MAX_H, true)
                    pool.comingSoonGif:SetSize(dispW, dispH)
                    local comingSoonHero = pool.root
                    comingSoonHero:SetWidth(w)
                    comingSoonHero:ClearAllPoints()
                    comingSoonHero:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
                    pool.heroAccent:ClearAllPoints()
                    pool.heroAccent:SetPoint("TOPLEFT", comingSoonHero, "TOPLEFT", 14, -14)
                    local heroH
                    if twoCol then
                        pool.comingSoonGif:ClearAllPoints()
                        local imgLeft = heroPad + math.max(0, math.floor((gifColW - dispW) / 2 + 0.5))
                        pool.comingSoonGif:SetPoint("TOPLEFT", comingSoonHero, "TOPLEFT", imgLeft, -heroPad)
                        pool.comingSoonTitleFs:SetWidth(textW)
                        pool.comingSoonTitleFs:ClearAllPoints()
                        pool.comingSoonTitleFs:SetPoint("TOPLEFT", comingSoonHero, "TOPLEFT", heroPad + gifColW + 16, -heroPad)
                        local yt = heroPad + pool.comingSoonTitleFs:GetHeight() + 8
                        pool.comingSoonTagFs:SetWidth(textW)
                        pool.comingSoonTagFs:ClearAllPoints()
                        pool.comingSoonTagFs:SetPoint("TOPLEFT", comingSoonHero, "TOPLEFT", heroPad + gifColW + 16, -yt)
                        yt = yt + pool.comingSoonTagFs:GetHeight() + 10
                        pool.comingSoonBodyFs:SetWidth(textW)
                        pool.comingSoonBodyFs:ClearAllPoints()
                        pool.comingSoonBodyFs:SetPoint("TOPLEFT", comingSoonHero, "TOPLEFT", heroPad + gifColW + 16, -yt)
                        yt = yt + pool.comingSoonBodyFs:GetHeight()
                        heroH = math.max(dispH + heroPad * 2, yt + heroPad)
                        pool.heroAccent:SetPoint("BOTTOMLEFT", comingSoonHero, "BOTTOMLEFT", 14, 14)
                    else
                        pool.comingSoonGif:ClearAllPoints()
                        pool.comingSoonGif:SetPoint("TOP", comingSoonHero, "TOP", 0, -heroPad)
                        local yt = heroPad + dispH + 12
                        pool.comingSoonTitleFs:SetWidth(textW)
                        pool.comingSoonTitleFs:ClearAllPoints()
                        pool.comingSoonTitleFs:SetPoint("TOPLEFT", comingSoonHero, "TOPLEFT", heroPad, -yt)
                        yt = yt + pool.comingSoonTitleFs:GetHeight() + 8
                        pool.comingSoonTagFs:SetWidth(textW)
                        pool.comingSoonTagFs:ClearAllPoints()
                        pool.comingSoonTagFs:SetPoint("TOPLEFT", comingSoonHero, "TOPLEFT", heroPad, -yt)
                        yt = yt + pool.comingSoonTagFs:GetHeight() + 10
                        pool.comingSoonBodyFs:SetWidth(textW)
                        pool.comingSoonBodyFs:ClearAllPoints()
                        pool.comingSoonBodyFs:SetPoint("TOPLEFT", comingSoonHero, "TOPLEFT", heroPad, -yt)
                        yt = yt + pool.comingSoonBodyFs:GetHeight()
                        heroH = yt + heroPad
                        pool.heroAccent:SetPoint("BOTTOMLEFT", comingSoonHero, "BOTTOMLEFT", 14, 14)
                    end
                    comingSoonHero:SetHeight(math.max(heroH, 1))
                    y = y + comingSoonHero:GetHeight() + 16
                    comingSoonHero:Show()

                elseif k == "accordion" then
                    local card = pool.card
                    local bodyFs = pool.bodyFs
                    card.titleLabel:SetText((L[entry.headingKey] or ""):upper())
                    bodyFs:SetText(L[entry.bodyKey] or "")
                    bodyFs:ClearAllPoints()
                    bodyFs:SetPoint("TOPLEFT", card.settingsContainer, "TOPLEFT", innerPad, -10)
                    bodyFs:SetPoint("TOPRIGHT", card.settingsContainer, "TOPRIGHT", -innerPad, -10)
                    local bodyH = bodyFs:GetHeight()
                    card.fullHeight = WELCOME_ACC_HEAD_H + 10 + bodyH + 14
                    if not card.anim:IsPlaying() then
                        if card.expanded then
                            card:SetHeight(card.fullHeight)
                        else
                            card:SetHeight(card.collapsedHeight)
                        end
                    end
                    card:SetWidth(w)
                    card:ClearAllPoints()
                    card:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
                    local accGap = (fi == #feed) and 16 or 8
                    y = y + card:GetHeight() + accGap
                    card:Show()
                    bodyFs:Show()
                end
            end
        end

        for pid, pool in pairs(welcomeBlockPool) do
            if not activeIds[pid] then
                if pool.root then
                    pool.root:Hide()
                elseif pool.titleFs then
                    pool.titleFs:Hide()
                    pool.introFs:Hide()
                elseif pool.card then
                    pool.card:Hide()
                end
            end
        end

        content:SetHeight(math.max(y + 8, 1))

        if welcomeScroll.UpdateScrollChildRect then
            welcomeScroll:UpdateScrollChildRect()
        end
        local viewH = welcomeScroll:GetHeight() or 0
        local contentH = content:GetHeight() or 0
        local maxScroll = math.max(0, contentH - viewH)
        local curScroll = welcomeScroll:GetVerticalScroll() or 0
        if curScroll > maxScroll then
            welcomeScroll:SetVerticalScroll(maxScroll)
            welcomeScroll.targetScroll = nil
        end
    end

    welcomeView:SetScript("OnShow", function()
        LayoutWelcomeContent()
        if C_Timer and C_Timer.After then
            C_Timer.After(0, LayoutWelcomeContent)
            C_Timer.After(0.05, LayoutWelcomeContent)
        end
    end)
    welcomeView:SetScript("OnSizeChanged", function()
        if welcomeView:IsShown() then LayoutWelcomeContent() end
    end)

    f.ShowWelcome = function()
        if f.pnChangelogHeaderBtn then f.pnChangelogHeaderBtn:Hide() end
        HideContextHeader()
        detailView:Hide()
        subCategoryView:Hide()
        dashboardView:Hide()
        if f.guideView then f.guideView:Hide() end
        patchNotesView:Hide()
        welcomeView:SetAlpha(0)
        welcomeView:Show()
        UIFrameFadeIn(welcomeView, 0.2, 0, 1)
        if head then head:Show() end
        if headSub then
            headSub:Show()
            headSub:SetText(L["DASH_WELCOME_HEAD_SUB"] or "Credits, community, and where to find help")
        end
        if searchBox then searchBox:Hide() end
        f.currentModuleKey = nil
        SetSidebarState({ view = "welcome", activeModuleKey = CLEAR, activeCategoryIndex = CLEAR })
        if addonRef.DashboardPreview and addonRef.DashboardPreview.SetActiveModuleKey then
            addonRef.DashboardPreview.SetActiveModuleKey(nil)
        end
        if addonRef.ApplyDashboardClassColor then addonRef.ApplyDashboardClassColor() end
    end
end
