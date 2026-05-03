--[[
    Horizon Suite - Dashboard home module toggle hub.
    Each module (Focus, Presence, Vista, Insight, Cache, Essence) gets a full-width card of uniform height
    with an animated pill toggle to enable/disable it. Card click navigates to settings.
    Wired from DashboardFrame.lua via addon.DashboardHomeWelcome_Init(env).
]]


local addon = _G.HorizonSuite


local tinsert = table.insert

--- @param env table
--- @return table { RefreshDashboardTiles = function }
function addon.DashboardHomeWelcome_Init(env)
    local f = env.f
    local envAddon = env.addon
    local L = env.L
    local dashboardView = env.dashboardView
    local contentWidth = env.contentWidth
    local dashScrollTopOffset = env.dashScrollTopOffset or -130
    local dashAccentRefs = env.dashAccentRefs
    local GetAccentColor = env.GetAccentColor
    local MakeText = env.MakeText
    local moduleLabels = env.moduleLabels
    local PREVIEW_MODULE_KEYS = env.PREVIEW_MODULE_KEYS or {}
    local DASHBOARD_CONTENT_CARD_ALPHA_MULT = env.DASHBOARD_CONTENT_CARD_ALPHA_MULT

    local C = envAddon.DashboardConstants or {}
    local CARD_H   = C.HOME_TOGGLE_CARD_H   or 88
    local CARD_GAP = C.HOME_TOGGLE_CARD_GAP or 8
    local PILL_W     = C.HOME_TOGGLE_PILL_W     or 44
    local PILL_H     = C.HOME_TOGGLE_PILL_H     or 24
    local PILL_THUMB = C.HOME_TOGGLE_PILL_THUMB or 18
    local ICON_SIZE  = C.HOME_TOGGLE_ICON_SIZE  or 38
    local BANNER_H   = C.HOME_RELOAD_BANNER_H   or 52

    local WDef = envAddon.OptionsWidgetsDef
    local SBg  = (WDef and WDef.SectionCardBg) or { 0.09, 0.09, 0.11, 0.96 }
    local SBgA = SBg[4] * (DASHBOARD_CONTENT_CARD_ALPHA_MULT or 1)

    local MODULE_ORDER = { "focus", "presence", "vista", "insight", "cache", "essence" }

    local MODULE_COLORS = {
        focus    = { 1.00, 0.82, 0.20 },
        presence = { 0.20, 1.00, 0.87 },
        vista    = { 0.70, 0.40, 1.00 },
        insight  = { 1.00, 0.40, 0.70 },
        cache    = { 0.20, 0.80, 0.40 },
        essence  = { 0.86, 0.08, 0.24 },
    }

    local MODULE_ICONS = {
        focus    = "achievement_quests_completed_05",
        presence = "vas_guildnamechange",
        vista    = "ability_hunter_pathfinding",
        insight  = "ui_profession_inscription",
        cache    = "INV_Misc_Coin_01",
        essence  = "achievement_character_human_male",
    }

    local MODULE_DESCS = {
        focus    = L["HOME_MOD_FOCUS_SHORT"]    or "Quest and achievement objective tracker.",
        presence = L["HOME_MOD_PRESENCE_SHORT"] or "Cinematic zone text and notification toasts.",
        vista    = L["HOME_MOD_VISTA_SHORT"]    or "Custom minimap with zone line, time, and addon buttons.",
        insight  = L["HOME_MOD_INSIGHT_SHORT"]  or "Cinematic tooltips with class colors, spec, and faction.",
        cache    = L["HOME_MOD_CACHE_SHORT"]    or "Loot, currency, and reputation toasts.",
        essence  = L["HOME_MOD_ESSENCE_SHORT"]  or "Character panel with 3D model, item level, and gear.",
    }

    -- Horizontal inset is on the scroll frame (match detail/subcategory); cards align to scroll content left.
    local CARD_TOP_PAD = 8
    local HOME_SCROLL_BOTTOM_INSET = 40
    local HOME_CONTENT_BOTTOM_PAD = 16

    local homeScroll = CreateFrame("ScrollFrame", nil, dashboardView, "UIPanelScrollFrameTemplate")
    homeScroll:SetFrameLevel((dashboardView:GetFrameLevel() or 0) + 2)
    homeScroll:SetPoint("TOPLEFT", 40, dashScrollTopOffset)
    homeScroll:SetPoint("BOTTOMRIGHT", -40, HOME_SCROLL_BOTTOM_INSET)
    homeScroll.ScrollBar:Hide()
    homeScroll.ScrollBar:ClearAllPoints()

    local homeContent = CreateFrame("Frame", nil, homeScroll)
    homeContent:SetSize(contentWidth or math.max(200, (dashboardView:GetWidth() or 800) - 80), 1)
    homeScroll:SetScrollChild(homeContent)
    if addon.Dashboard_ApplySmoothScroll then
        addon.Dashboard_ApplySmoothScroll(homeScroll, homeContent, 60, true)
    end

    local function EaseInOutCubic(t)
        if t < 0.5 then
            return 4 * t * t * t
        end
        local f2 = ((2 * t) - 2)
        return 0.5 * f2 * f2 * f2 + 1
    end

    -- Reload banner is anchored to dashboardView (outside the scroll area) so it is
    -- always visible at the top of the card list regardless of scroll position.
    -- LayoutToggleCards shifts homeScroll down when the banner is shown.
    local reloadBanner = CreateFrame("Frame", nil, dashboardView)
    reloadBanner:SetHeight(BANNER_H)
    reloadBanner:SetFrameLevel((dashboardView:GetFrameLevel() or 0) + 10)
    reloadBanner:Hide()

    local reloadBg = reloadBanner:CreateTexture(nil, "BACKGROUND")
    reloadBg:SetAllPoints()
    reloadBg:SetColorTexture(0.12, 0.10, 0.08, 0.85)

    local reloadRail = reloadBanner:CreateTexture(nil, "ARTWORK")
    reloadRail:SetWidth(3)
    reloadRail:SetPoint("TOPLEFT", 0, 0)
    reloadRail:SetPoint("BOTTOMLEFT", 0, 0)
    reloadRail:SetColorTexture(0.90, 0.68, 0.20, 1)

    local reloadText = MakeText(reloadBanner, L["HOME_RELOAD_PROMPT"] or "Reload to apply module changes.", 12, 0.90, 0.82, 0.55, "LEFT")
    reloadText:SetPoint("LEFT", 18, 2)

    local reloadBtn = CreateFrame("Button", nil, reloadBanner)
    reloadBtn:SetSize(80, 24)
    reloadBtn:SetPoint("RIGHT", -12, 0)

    local reloadBtnBg = reloadBtn:CreateTexture(nil, "BACKGROUND")
    reloadBtnBg:SetAllPoints()
    reloadBtnBg:SetColorTexture(0.90, 0.68, 0.20, 0.22)

    local reloadBtnLbl = MakeText(reloadBtn, L["RELOAD_UI"] or "Reload UI", 11, 0.95, 0.88, 0.60, "CENTER")
    reloadBtnLbl:SetAllPoints()

    reloadBtn:SetScript("OnClick", function() ReloadUI() end)
    reloadBtn:SetScript("OnEnter", function() reloadBtnBg:SetColorTexture(0.90, 0.68, 0.20, 0.40) end)
    reloadBtn:SetScript("OnLeave", function() reloadBtnBg:SetColorTexture(0.90, 0.68, 0.20, 0.22) end)

    local toggleCards = {}
    local LayoutToggleCards  -- forward declaration; assigned after MakeToggleCard

    local function MakeToggleCard(parent, moduleKey)
        local mc = MODULE_COLORS[moduleKey] or { 0.6, 0.6, 0.7 }
        local mr, mg, mb = mc[1], mc[2], mc[3]
        local isPreviewModule = PREVIEW_MODULE_KEYS[moduleKey] and true or false
        local previewTitleSuffix = " |cff228b22(" .. (L["PRESENCE_PREVIEW"] or "Preview") .. ")|r"
        local previewDisclaimer = L["MODULE_PREVIEW_DISCLAIMER"] or "This module is currently in an early preview (alpha) state. Daily use is not advised due to bugs or unfinished functionality."
        -- Disclaimer line: distinct from body copy (enabled / disabled module tint)
        local PREVIEW_DISC_ON_R, PREVIEW_DISC_ON_G, PREVIEW_DISC_ON_B = 0.94, 0.62, 0.32
        local PREVIEW_DISC_OFF_R, PREVIEW_DISC_OFF_G, PREVIEW_DISC_OFF_B = 0.50, 0.38, 0.26

        -- Fixed text bands so every row uses CARD_H.
        -- topInset is always derived from the non-preview stack so all rows start at the same Y.
        -- The disclaimer (preview only) flows below and is clipped by the card boundary.
        local TITLE_LINE_H = 16
        local GAP_TITLE_DESC = 3
        local DESC_AREA_H = 24
        local GAP_DESC_DISC = 3
        local DISC_AREA_H = 30
        local DISC_FONT_SIZE = 10
        local baseStackH = TITLE_LINE_H + GAP_TITLE_DESC + DESC_AREA_H
        local blockH = math.max(ICON_SIZE, baseStackH)
        local topInset = math.floor(math.max(5, (CARD_H - blockH) / 2 + 0.5))

        local card = CreateFrame("Button", nil, parent)
        card:SetHeight(CARD_H)
        card:SetClipsChildren(true)

        local cardBg = card:CreateTexture(nil, "BACKGROUND")
        cardBg:SetAllPoints()
        cardBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)
        card.cardBg = cardBg

        local cardInner = card:CreateTexture(nil, "BORDER")
        cardInner:SetPoint("TOPLEFT", 1, -1)
        cardInner:SetPoint("BOTTOMRIGHT", -1, 1)
        cardInner:SetColorTexture(1, 1, 1, 0.02)

        local accentRail = card:CreateTexture(nil, "ARTWORK")
        accentRail:SetWidth(4)
        accentRail:SetPoint("TOPLEFT", 0, 0)
        accentRail:SetPoint("BOTTOMLEFT", 0, 0)
        accentRail:SetColorTexture(mr, mg, mb, 1)
        card.accentRail = accentRail

        local accentGlow = card:CreateTexture(nil, "ARTWORK")
        accentGlow:SetWidth(12)
        accentGlow:SetPoint("TOPLEFT", accentRail, "TOPRIGHT", 0, 0)
        accentGlow:SetPoint("BOTTOMLEFT", accentRail, "BOTTOMRIGHT", 0, 0)
        accentGlow:SetColorTexture(mr, mg, mb, 0.08)

        local toggleWell = card:CreateTexture(nil, "ARTWORK")
        toggleWell:SetPoint("TOPRIGHT", 0, 0)
        toggleWell:SetPoint("BOTTOMRIGHT", 0, 0)
        toggleWell:SetWidth(PILL_W + 40)
        toggleWell:SetColorTexture(mr, mg, mb, 0.05)

        local divider = card:CreateTexture(nil, "ARTWORK")
        divider:SetHeight(1)
        divider:SetPoint("BOTTOMLEFT", 0, 0)
        divider:SetPoint("BOTTOMRIGHT", 0, 0)
        local dar, dag, dab = GetAccentColor()
        divider:SetColorTexture(dar, dag, dab, 0.15)
        tinsert(dashAccentRefs.homeTileDividers, divider)

        local iconTex = card:CreateTexture(nil, "ARTWORK")
        iconTex:SetSize(ICON_SIZE, ICON_SIZE)
        iconTex:SetPoint("TOPLEFT", card, "TOPLEFT", 18, -topInset)
        iconTex:SetTexture("Interface\\Icons\\" .. (MODULE_ICONS[moduleKey] or "INV_Misc_Question_01"))
        card.iconTex = iconTex

        local modName = (moduleLabels and moduleLabels[moduleKey]) or (moduleKey:sub(1, 1):upper() .. moduleKey:sub(2))
        local titleText = modName:upper() .. (isPreviewModule and previewTitleSuffix or "")

        local nameLbl = MakeText(card, titleText, 14, mr, mg, mb, "LEFT")
        nameLbl:SetPoint("TOPLEFT", iconTex, "TOPRIGHT", 10, 0)
        nameLbl:SetPoint("RIGHT", -(PILL_W + 54), 0)
        nameLbl:SetHeight(TITLE_LINE_H)
        nameLbl:SetWordWrap(false)
        card.nameLbl = nameLbl

        local descLbl = MakeText(card, MODULE_DESCS[moduleKey] or "", 11, 0.55, 0.57, 0.62, "LEFT")
        descLbl:SetPoint("TOPLEFT", nameLbl, "BOTTOMLEFT", 0, -GAP_TITLE_DESC)
        descLbl:SetPoint("RIGHT", -(PILL_W + 54), 0)
        descLbl:SetHeight(DESC_AREA_H)
        descLbl:SetWordWrap(true)
        descLbl:SetJustifyV("TOP")
        card.descLbl = descLbl

        local previewDisclaimerLbl = nil
        if isPreviewModule then
            previewDisclaimerLbl = MakeText(card, previewDisclaimer, DISC_FONT_SIZE, PREVIEW_DISC_ON_R, PREVIEW_DISC_ON_G, PREVIEW_DISC_ON_B, "LEFT")
            previewDisclaimerLbl:SetPoint("TOPLEFT", descLbl, "BOTTOMLEFT", 0, -GAP_DESC_DISC)
            previewDisclaimerLbl:SetPoint("RIGHT", -(PILL_W + 54), 0)
            previewDisclaimerLbl:SetHeight(DISC_AREA_H)
            previewDisclaimerLbl:SetWordWrap(true)
            previewDisclaimerLbl:SetJustifyV("TOP")
            card.previewDisclaimerLbl = previewDisclaimerLbl
        end

        local pillBtn = CreateFrame("Button", nil, card)
        pillBtn:SetSize(PILL_W, PILL_H)
        pillBtn:SetPoint("RIGHT", -16, 0)
        pillBtn:SetFrameLevel(card:GetFrameLevel() + 5)

        local chevron = MakeText(card, ">", 14, 0.42, 0.45, 0.50, "CENTER")
        chevron:SetPoint("RIGHT", pillBtn, "LEFT", -14, 0)
        chevron:SetSize(10, 16)

        local pillBg = pillBtn:CreateTexture(nil, "BACKGROUND")
        pillBg:SetAllPoints()
        pillBg:SetColorTexture(0.18, 0.18, 0.22, 0.9)

        local pillBorder = pillBtn:CreateTexture(nil, "BORDER")
        pillBorder:SetPoint("TOPLEFT", -1, 1)
        pillBorder:SetPoint("BOTTOMRIGHT", 1, -1)
        pillBorder:SetColorTexture(1, 1, 1, 0.07)

        local pillGlow = pillBtn:CreateTexture(nil, "BORDER")
        pillGlow:SetPoint("TOPLEFT", -3, 3)
        pillGlow:SetPoint("BOTTOMRIGHT", 3, -3)
        pillGlow:SetColorTexture(mr, mg, mb, 0.08)

        local thumb = pillBtn:CreateTexture(nil, "ARTWORK")
        thumb:SetSize(PILL_THUMB, PILL_THUMB)
        thumb:SetTexture("Interface\\Buttons\\WHITE8X8")
        thumb:SetVertexColor(1, 1, 1, 0.92)
        thumb:SetPoint("LEFT", pillBtn, "LEFT", 3, 0)

        local THUMB_OFF = 3
        local THUMB_ON  = PILL_W - PILL_THUMB - 3

        pillBtn._animTarget = 0
        pillBtn._animStart = 0
        pillBtn._animElapsed = 0
        pillBtn._animDur = 0.20
        pillBtn._animating = false
        pillBtn._visualProgress = 0

        local function ApplyPillProgress(progress)
            pillBtn._visualProgress = progress
            thumb:ClearAllPoints()
            thumb:SetPoint("LEFT", pillBtn, "LEFT", THUMB_OFF + (THUMB_ON - THUMB_OFF) * progress, 0)

            local r = 0.18 + (mr - 0.18) * progress
            local g = 0.18 + (mg - 0.18) * progress
            local b = 0.22 + (mb - 0.22) * progress
            pillBg:SetColorTexture(r, g, b, 0.88 - (0.05 * progress))
            pillBorder:SetColorTexture(1, 1, 1, 0.06 + (0.08 * progress))
            pillGlow:SetColorTexture(mr, mg, mb, 0.04 + (0.16 * progress))
            thumb:SetVertexColor(1, 1, 1, 0.90 + (0.07 * progress))
        end

        local function SetPillImmediate(on)
            local t = on and 1 or 0
            pillBtn._animTarget = t
            pillBtn._animStart = t
            pillBtn._animating = false
            ApplyPillProgress(t)
        end
        pillBtn.SetPillImmediate = SetPillImmediate

        pillBtn:SetScript("OnUpdate", function(self, elapsed)
            if not self._animating then return end
            self._animElapsed = self._animElapsed + elapsed
            local rawT = math.min(1, self._animElapsed / self._animDur)
            local t = EaseInOutCubic(rawT)
            local curP = self._animStart + ((self._animTarget - self._animStart) * t)
            ApplyPillProgress(curP)
            if rawT >= 1 then
                self._animating = false
                SetPillImmediate(self._animTarget == 1)
            end
        end)

        local function ApplyCardState(enabled)
            local hovered = card._hovered
            local bgR, bgG, bgB = SBg[1], SBg[2], SBg[3]
            local bgA = SBgA

            if enabled then
                bgR, bgG, bgB = 0.10, 0.10, 0.12
                bgA = math.min(1, SBgA + 0.02)
            else
                bgR, bgG, bgB = 0.07, 0.07, 0.09
                bgA = math.max(0.70, SBgA - 0.05)
            end

            if hovered then
                bgR = math.min(1, bgR + 0.015)
                bgG = math.min(1, bgG + 0.015)
                bgB = math.min(1, bgB + 0.02)
            end

            cardBg:SetColorTexture(bgR, bgG, bgB, bgA)
            cardInner:SetColorTexture(1, 1, 1, hovered and 0.035 or 0.02)

            if enabled then
                accentRail:SetColorTexture(mr, mg, mb, 1)
                accentGlow:SetColorTexture(mr, mg, mb, hovered and 0.14 or 0.10)
                toggleWell:SetColorTexture(mr, mg, mb, hovered and 0.09 or 0.06)
                if iconTex.SetDesaturated then iconTex:SetDesaturated(false) end
                iconTex:SetVertexColor(1, 1, 1, hovered and 0.98 or 0.92)
                nameLbl:SetTextColor(mr, mg, mb)
                descLbl:SetTextColor(0.62, 0.64, 0.69)
                if previewDisclaimerLbl then
                    local dr, dg, db = PREVIEW_DISC_ON_R, PREVIEW_DISC_ON_G, PREVIEW_DISC_ON_B
                    if hovered then
                        dr = math.min(1, dr + 0.04)
                        dg = math.min(1, dg + 0.04)
                        db = math.min(1, db + 0.06)
                    end
                    previewDisclaimerLbl:SetTextColor(dr, dg, db)
                end
                chevron:SetTextColor(mr, mg, mb, hovered and 0.70 or 0.42)
            else
                accentRail:SetColorTexture(mr, mg, mb, 0.30)
                accentGlow:SetColorTexture(mr, mg, mb, hovered and 0.06 or 0.04)
                toggleWell:SetColorTexture(mr, mg, mb, hovered and 0.04 or 0.025)
                if iconTex.SetDesaturated then iconTex:SetDesaturated(true) end
                iconTex:SetVertexColor(0.50, 0.52, 0.56, 0.72)
                nameLbl:SetTextColor(0.44, 0.46, 0.50)
                descLbl:SetTextColor(0.36, 0.38, 0.42)
                if previewDisclaimerLbl then
                    previewDisclaimerLbl:SetTextColor(PREVIEW_DISC_OFF_R, PREVIEW_DISC_OFF_G, PREVIEW_DISC_OFF_B)
                end
                chevron:SetTextColor(0.36, 0.38, 0.42, hovered and 0.62 or 0.40)
            end

            card._enabledState = enabled
        end

        pillBtn:SetScript("OnClick", function()
            local newOn = pillBtn._animTarget ~= 1
            pillBtn._animStart = pillBtn._visualProgress or (pillBtn._animTarget == 1 and 1 or 0)
            pillBtn._animElapsed = 0
            pillBtn._animTarget = newOn and 1 or 0
            pillBtn._animating = true

            if envAddon.SetModuleEnabled then
                envAddon:SetModuleEnabled(moduleKey, newOn, { deferReload = true })
            end

            if envAddon._moduleReloadRecommended then
                if not reloadBanner:IsShown() then
                    reloadBanner:SetAlpha(0)
                    reloadBanner:Show()
                    -- Shift cardScroll down to make room for the banner above it.
                    LayoutToggleCards()
                end
                UIFrameFadeIn(reloadBanner, 0.25, reloadBanner:GetAlpha(), 1)
            end

            if card.RefreshState then card:RefreshState(newOn, true) end
        end)

        card:SetScript("OnClick", function()
            if f.OpenModule then
                f.OpenModule(modName, moduleKey)
            end
        end)

        card:SetScript("OnEnter", function()
            card._hovered = true
            ApplyCardState(card._enabledState ~= false)
        end)

        card:SetScript("OnLeave", function()
            card._hovered = false
            ApplyCardState(card._enabledState ~= false)
        end)

        card.RefreshState = function(_, enabledOverride, preservePillAnimation)
            local enabled = enabledOverride
            if enabled == nil then
                enabled = true
                if envAddon.IsModuleEnabled then
                    local v = envAddon:IsModuleEnabled(moduleKey)
                    if v ~= nil then enabled = v end
                end
            end

            ApplyCardState(enabled)
            if not preservePillAnimation then
                SetPillImmediate(enabled)
            end
        end

        card.pillBtn = pillBtn
        return card
    end

    for _, mk in ipairs(MODULE_ORDER) do
        local card = MakeToggleCard(homeContent, mk)
        tinsert(toggleCards, { key = mk, card = card })
    end

    LayoutToggleCards = function()
        local viewW = homeScroll:GetWidth() or homeContent:GetWidth() or 0
        local cardW = math.max(200, viewW)
        homeContent:SetWidth(cardW)

        -- Reload banner lives outside the scroll frame (parented to dashboardView).
        -- When visible it occupies a fixed strip just above the scroll content; we
        -- shift homeScroll down by BANNER_H + 4 to make room.
        local bannerShown = reloadBanner:IsShown()
        local scrollTopY = bannerShown and (dashScrollTopOffset - BANNER_H - 4) or dashScrollTopOffset

        homeScroll:ClearAllPoints()
        homeScroll:SetPoint("TOPLEFT",     dashboardView, "TOPLEFT",      40, scrollTopY)
        homeScroll:SetPoint("BOTTOMRIGHT", dashboardView, "BOTTOMRIGHT", -40, HOME_SCROLL_BOTTOM_INSET)

        reloadBanner:SetWidth(cardW)
        reloadBanner:ClearAllPoints()
        reloadBanner:SetPoint("TOPLEFT", dashboardView, "TOPLEFT", 40, dashScrollTopOffset)

        local y = CARD_TOP_PAD

        for _, entry in ipairs(toggleCards) do
            local card = entry.card
            card:SetWidth(cardW)
            card:ClearAllPoints()
            card:SetPoint("TOPLEFT", homeContent, "TOPLEFT", 0, -y)
            card:Show()
            y = y + card:GetHeight() + CARD_GAP
        end

        -- Set content height so the scroll frame knows how far it can scroll.
        local contentH = math.max(1, y + HOME_CONTENT_BOTTOM_PAD)
        homeContent:SetHeight(contentH)
    end

    local function RefreshHomeToggleCards()
        for _, entry in ipairs(toggleCards) do
            if entry.card.RefreshState then
                entry.card:RefreshState()
            end
        end

        if not envAddon._moduleReloadRecommended then
            reloadBanner:Hide()
        end

        LayoutToggleCards()
    end

    homeScroll:SetScript("OnSizeChanged", function()
        if homeScroll:IsShown() then
            LayoutToggleCards()
        end
    end)

    RefreshHomeToggleCards()

    if envAddon.DashboardWelcomeView_Init then
        envAddon.DashboardWelcomeView_Init(env)
    end

    if envAddon.DashboardWelcomeView_Init and env.newsView then
        local newsEnv = {}
        for k, v in pairs(env) do newsEnv[k] = v end
        newsEnv.targetView      = env.newsView
        newsEnv.feedData        = envAddon.DashboardNewsFeed
        newsEnv.targetViewName  = "news"
        newsEnv.headSubKey      = "DASH_NEWS_HEAD_SUB"
        envAddon.DashboardWelcomeView_Init(newsEnv)
    end

    return {
        RefreshDashboardTiles = RefreshHomeToggleCards,
    }
end
