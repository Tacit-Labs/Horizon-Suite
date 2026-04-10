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
local function GetSortedFeed(feedData)
    local src = feedData or addon.DashboardWelcomeFeed
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

--- @param env table Same dashboard env as DashboardHomeWelcome_Init (frames, MakeText, L, …), plus optional: targetView, feedData, targetViewName, headSubKey, communityFooter.
--- @return nil
function addon.DashboardWelcomeView_Init(env)
    local f = env.f
    local addonRef = env.addon
    local L = env.L
    local targetView = env.targetView or env.welcomeView
    local feedData = env.feedData
    local targetViewName = env.targetViewName or "welcome"
    local headSubKey = env.headSubKey or "DASH_WELCOME_HEAD_SUB"
    local createCommunityFooter = (env.communityFooter ~= false)
    local welcomeView = targetView
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
    local searchBarShell = env.searchBarShell
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
    local WELCOME_LEARN_SECTION_PEEK_PX = 96
    local SCROLL_TO_BG_INSET = 20
    local WELCOME_COMING_SOON_GIF_MAX_H = 132
    local WELCOME_COMING_SOON_TWO_COL_MIN_W = 440
    local WELCOME_COMING_SOON_GIF_COL_W = 200
    local NEWS_FEATURED_MIN_ART_W = 220
    local NEWS_GRID_TWO_COL_MIN_W = 760
    local NEWS_GRID_GAP = 16
    local NEWS_BADGE_EYEBROW_GAP = 10
    local NEWS_FEATURED_BODY_BEFORE_FOOTER_GAP = 8
    local NEWS_CARD_MIN_H = 220
    local NEWS_ICON_STRIP_GAP = 4
    local CLASS_ICON_STRIP_ROW_COUNT = 3
    local CLASS_ICON_STRIP_ROW_VGAP = 10
    local CLASS_ICON_STRIP_MAX_PX = 128
    local NEWS_MEDIA_WRAP_MIN_W = 180
    local NEWS_MEDIA_WRAP_MAX_W = 240
    local NEWS_MEDIA_WRAP_H = 156
    -- Tall or wide art: grow the slot height from intrinsic aspect (cap keeps cards on-screen).
    local NEWS_MEDIA_STACK_MAX_H = 380
    local NEWS_MEDIA_SPLIT_MAX_H = 320
    local NEWS_MEDIA_SPLIT_COL_GAP = 14
    local NEWS_MEDIA_SPLIT_MIN_LEFT_W = 140
    local NEWS_CARD_EDITORIAL_FOOTER_BOTTOM_INSET = 10
    local NEWS_CARD_EDITORIAL_FOOTER_AREA_H = 40
    local NEWS_CARD_EDITORIAL_FOOTER_GAP_ABOVE = 12
    local NEWS_CARD_SECONDARY_BLOCK_GAP = 18
    local WELCOME_ACTION_GRID_GAP = 16
    local WELCOME_SUPPORT_GRID_GAP = 16
    local WELCOME_ACTION_CARD_MIN_H = 148
    local WELCOME_ACTION_CARD_CTA_H = 18
    local WELCOME_ACTION_CARD_FOOTER_GAP = 10
    local WELCOME_ACTION_CARD_FOOTER_BOTTOM_INSET = 18

    --- Place supporter name labels in a wrapping flow with stagger (tag-cloud style).
    --- Uses per-label _supporterGapAfter and _supporterStagger set at create time.
    --- @param host Frame
    --- @param maxWidth number
    --- @param entryList table Array of { name = string }
    --- @param tagLabels table
    --- @return nil
    local function LayoutSupporterTagFlow(host, maxWidth, entryList, tagLabels)
        if not host or not entryList or not tagLabels then return end
        local gapY = 10
        local x = 0
        local y = 0
        local rowH = 0
        for j = 1, #tagLabels do
            if j > #entryList and tagLabels[j] then
                tagLabels[j]:Hide()
            end
        end
        for i = 1, #entryList do
            local fs = tagLabels[i]
            if not fs then break end
            fs:Show()
            local w = fs:GetStringWidth() or 0
            local gapAfter = fs._supporterGapAfter or 10
            if x > 0 and (x + w) > maxWidth then
                y = y + rowH + gapY
                x = 0
                rowH = 0
            end
            local stagger = fs._supporterStagger or 0
            fs:ClearAllPoints()
            fs:SetPoint("TOPLEFT", host, "TOPLEFT", x, -(y + stagger))
            local fh = fs:GetHeight() or 12
            rowH = math.max(rowH, fh + stagger)
            x = x + w + gapAfter
        end
        host:SetHeight(math.max(1, y + rowH))
    end

    -- WoW class tokens (English, uppercase) for RAID_CLASS_COLORS / C_ClassColor.GetClassColor.
    local SUPPORTER_CLASS_FALLBACK_ORDER = {
        "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "DEATHKNIGHT",
        "SHAMAN", "MAGE", "WARLOCK", "MONK", "DRUID", "DEMONHUNTER", "EVOKER",
    }

    --- @param entry table
    --- @return table|nil Array of { name = string, classFile = string|nil }
    local function ResolveSupporterList(entry)
        if not entry then return nil end
        if entry.supporterEntries and #entry.supporterEntries > 0 then
            return entry.supporterEntries
        end
        if entry.supporterNames and #entry.supporterNames > 0 then
            local t = {}
            for i, nm in ipairs(entry.supporterNames) do
                t[i] = {
                    name = nm,
                    classFile = SUPPORTER_CLASS_FALLBACK_ORDER[((i - 1) % #SUPPORTER_CLASS_FALLBACK_ORDER) + 1],
                }
            end
            return t
        end
        return nil
    end

    --- @param classFile string|nil
    --- @return number, number, number
    local function GetSupporterClassRGB(classFile)
        if type(classFile) ~= "string" or classFile == "" then
            return 0.62, 0.66, 0.74
        end
        if C_ClassColor and C_ClassColor.GetClassColor then
            local ok, cc = pcall(function()
                return C_ClassColor.GetClassColor(classFile)
            end)
            if ok and cc and type(cc.r) == "number" then
                return cc.r, cc.g, cc.b
            end
        end
        local rc = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
        if rc and type(rc.r) == "number" then
            return rc.r, rc.g, rc.b
        end
        return 0.62, 0.66, 0.74
    end

    local function ShowCopyURL(label, url)
        if addonRef.ShowURLCopyBox then
            addonRef.ShowURLCopyBox(url, (L["DASH_COPY_LINK_X"] or "Copy link — %s"):format(label))
        end
    end

    local function ResolveNewsTexturePath(entry)
        if not entry then return nil end
        if type(entry.artPath) == "string" and entry.artPath ~= "" then
            return entry.artPath
        end
        if type(entry.icon) == "string" and entry.icon ~= "" then
            if string.find(entry.icon, "\\", 1, true) or string.find(entry.icon, "/", 1, true) then
                return entry.icon
            end
            return "Interface\\Icons\\" .. entry.icon
        end
        return nil
    end

    -- Icon file string, or { atlas, fallback } to match DashboardSidebar ApplySidebarButtonIconTexture.
    local function ApplyWelcomeActionCardIcon(tex, entry)
        if not tex or not entry then return false end
        local icon = entry.icon
        if type(icon) == "table" and icon.atlas and tex.SetAtlas then
            local atlas = icon.atlas
            local gi = C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas)
            if C_Texture and C_Texture.GetAtlasInfo and not gi and type(icon.fallback) == "string" then
                if tex.SetAtlas then tex:SetAtlas(nil) end
                tex:SetTexture("Interface\\Icons\\" .. icon.fallback)
            else
                tex:SetTexture(nil)
                pcall(function()
                    tex:SetAtlas(atlas, false)
                end)
            end
            return true
        end
        local path = ResolveNewsTexturePath(entry)
        if path then
            if tex.SetAtlas then tex:SetAtlas(nil) end
            tex:SetTexture(path)
            return true
        end
        return false
    end

    local function ResolveNewsArtIntrinsicSize(entry, tex, fallbackRatio)
        if type(entry) == "table" then
            local ew = tonumber(entry.artWidth)
            local eh = tonumber(entry.artHeight)
            if ew and eh and ew > 0 and eh > 0 then
                return ew, eh
            end
            if entry.icon then
                return 64, 64
            end
        end

        local nw = tex and tex.GetTextureFileWidth and tex:GetTextureFileWidth() or 0
        local nh = tex and tex.GetTextureFileHeight and tex:GetTextureFileHeight() or 0
        if nw and nh and nw > 0 and nh > 0 then
            return nw, nh
        end

        local ratio = tonumber(fallbackRatio) or (16 / 9)
        ratio = math.max(0.25, math.min(4, ratio))
        return ratio * 100, 100
    end

    local function ComputeNewsContainedSize(entry, tex, boxW, boxH, capScaleOne, fallbackRatio)
        if not boxW or not boxH or boxW < 1 or boxH < 1 then
            return 1, 1
        end

        local nw, nh = ResolveNewsArtIntrinsicSize(entry, tex, fallbackRatio)
        local scale = math.min(boxW / nw, boxH / nh)
        if capScaleOne then
            scale = math.min(scale, 1)
        end
        return math.max(1, math.floor(nw * scale + 0.5)), math.max(1, math.floor(nh * scale + 0.5))
    end

    -- Pick a clip box height so contain-fit preserves aspect (portrait needs more height than NEWS_MEDIA_WRAP_H).
    local function NewsMediaClipBoxHeight(boxW, entry, tex, minH, maxH)
        if not boxW or boxW < 1 then return minH end
        local iw, ih = ResolveNewsArtIntrinsicSize(entry, tex, 16 / 9)
        if not iw or not ih or iw < 1 or ih < 1 then return minH end
        local ideal = math.floor(boxW * ih / iw + 0.5)
        return math.min(maxH, math.max(minH, ideal))
    end

    local function DispatchNewsAction(entry)
        if not entry then return end
        local action = entry.ctaAction
        if type(action) ~= "table" then return end

        if action.type == "module" then
            local mk = action.moduleKey
            if mk and f.OpenModule then
                local modName = action.moduleName
                    or (addonRef.Dashboard_BrandModule and addonRef.Dashboard_BrandModule(mk))
                    or mk
                f.OpenModule(modName, mk)
            end
            return
        end

        if action.type == "patch_notes" then
            if f.ShowPatchNotes then f.ShowPatchNotes() end
            return
        end

        if action.type == "guide" then
            if f.ShowModuleGuide then f.ShowModuleGuide() end
            return
        end

        if action.type == "dashboard" then
            if f.ShowDashboard then f.ShowDashboard() end
            return
        end

        if action.type == "news" then
            if f.ShowNews then f.ShowNews() end
            return
        end

        if action.type == "copy_url" and action.url then
            ShowCopyURL(L[entry.ctaLabelKey] or L[entry.titleKey] or "Link", action.url)
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
    -- Expose scroll content so DashboardModuleGuide_Init can parent embedded guide content here
    welcomeView._scrollContent = content

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

        headerBtn:SetScript("OnClick", function()
            card.expanded = not card.expanded
            updateExpandedVisuals()
            local h = card.expanded and (card.fullHeight or WELCOME_ACC_HEAD_H) or card.collapsedHeight
            card:SetHeight(h)
            sc:SetAlpha(card.expanded and 1 or 0)
            if onLayout then onLayout() end
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

    local function CreateNewsCTAButton(parent, filled)
        local btn = CreateFrame("Button", nil, parent)
        btn:SetHeight(filled and 28 or 18)
        btn:SetFrameLevel((parent:GetFrameLevel() or 0) + 3)

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0)
        btn._bg = bg
        btn._filled = filled and true or false

        local label = MakeText(btn, "", filled and 11 or 12, 0.72, 0.85, 0.95, "CENTER")
        label:SetAllPoints()
        btn._label = label

        if filled then
            bg:SetColorTexture(0.20, 0.80, 0.90, 0.20)
        else
            local underline = btn:CreateTexture(nil, "OVERLAY")
            underline:SetHeight(1)
            underline:SetPoint("BOTTOMLEFT", label, "BOTTOMLEFT", 0, -1)
            underline:SetPoint("BOTTOMRIGHT", label, "BOTTOMRIGHT", 0, -1)
            underline:SetColorTexture(0.45, 0.72, 0.95, 0.75)
            underline:Hide()
            btn._underline = underline
        end

        btn.SetLabel = function(self, text)
            self._label:SetText(text or "")
            local pad = self._filled and 24 or 2
            local minW = self._filled and 120 or 40
            self:SetWidth(math.max(minW, (self._label:GetStringWidth() or 0) + pad))
        end

        btn:SetScript("OnEnter", function(self)
            if self._filled then
                self._bg:SetColorTexture(0.20, 0.80, 0.90, 0.32)
                self._label:SetTextColor(0.93, 0.98, 1, 1)
            else
                self._label:SetTextColor(0.86, 0.94, 1, 1)
                if self._underline then self._underline:Show() end
            end
        end)
        btn:SetScript("OnLeave", function(self)
            if self._filled then
                self._bg:SetColorTexture(0.20, 0.80, 0.90, 0.20)
                self._label:SetTextColor(0.72, 0.85, 0.95, 1)
            else
                self._label:SetTextColor(0.72, 0.85, 0.95, 1)
                if self._underline then self._underline:Hide() end
            end
        end)

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
            local cached = welcomeBlockPool[id]
            if kind == "welcome_support_card" then
                local supList = ResolveSupporterList(entry)
                local needsTagFlow = supList and #supList > 0
                local hasTagFlow = cached.tagHost and cached.tagLabels
                if needsTagFlow and not hasTagFlow then
                    if cached.root then
                        cached.root:Hide()
                    end
                    welcomeBlockPool[id] = nil
                else
                    return cached
                end
            elseif kind == "news_featured" and not cached.editorialFooterRow then
                if cached.root then
                    cached.root:Hide()
                end
                welcomeBlockPool[id] = nil
            else
                return cached
            end
        end

        if kind == "static_header" then
            local titleFs = MakeText(content, "", 22, 1, 1, 1, "LEFT")
            local introFs = MakeDashboardWelcomeMixedScriptText(content, "", 13, 0.72, 0.74, 0.78, "LEFT")
            introFs:SetWordWrap(true)
            introFs:SetSpacing(4)
            welcomeBlockPool[id] = { kind = kind, titleFs = titleFs, introFs = introFs }
            return welcomeBlockPool[id]
        end

        if kind == "welcome_hero" then
            local hero = CreateFrame("Frame", nil, content)
            hero:SetClipsChildren(true)
            local war, wag, wab = GetAccentColor()

            local bg = hero:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.07, 0.08, 0.10, math.min(1, SBgA + 0.10))

            local topGlow = hero:CreateTexture(nil, "ARTWORK")
            topGlow:SetPoint("TOPLEFT", 0, 0)
            topGlow:SetPoint("TOPRIGHT", 0, 0)
            topGlow:SetHeight(92)
            topGlow:SetColorTexture(0, 0, 0, 0)

            local accent = hero:CreateTexture(nil, "ARTWORK")
            accent:SetHeight(3)
            accent:SetPoint("TOPLEFT", 0, 0)
            accent:SetPoint("TOPRIGHT", 0, 0)
            accent:SetColorTexture(war, wag, wab, 0.70)
            tinsert(dashAccentRefs.cardAccents, accent)

            local bottomRule = hero:CreateTexture(nil, "ARTWORK")
            bottomRule:SetHeight(1)
            bottomRule:SetPoint("BOTTOMLEFT", 22, 0)
            bottomRule:SetPoint("BOTTOMRIGHT", -22, 0)
            bottomRule:SetColorTexture(war, wag, wab, 0.16)
            tinsert(dashAccentRefs.cardDividers, bottomRule)

            local eyebrowFs = MakeText(hero, "", 11, 0.56, 0.75, 0.92, "LEFT")
            local titleFs = MakeText(hero, "", 30, 0.98, 0.99, 1, "LEFT")
            local taglineFs = MakeText(hero, "", 15, 0.78, 0.81, 0.87, "LEFT")
            local bodyFs = MakeDashboardWelcomeMixedScriptText(hero, "", 13, 0.70, 0.73, 0.79, "LEFT")
            bodyFs:SetWordWrap(true)
            bodyFs:SetSpacing(4)

            welcomeBlockPool[id] = {
                kind = kind,
                root = hero,
                eyebrowFs = eyebrowFs,
                titleFs = titleFs,
                taglineFs = taglineFs,
                bodyFs = bodyFs,
                entry = entry,
            }
            return welcomeBlockPool[id]
        end

        if kind == "welcome_section_header" then
            local titleFs = MakeText(content, "", 18, 0.98, 0.99, 1, "LEFT")
            local introFs = MakeDashboardWelcomeMixedScriptText(content, "", 12, 0.60, 0.64, 0.70, "LEFT")
            introFs:SetWordWrap(true)
            introFs:SetSpacing(3)
            welcomeBlockPool[id] = { kind = kind, titleFs = titleFs, introFs = introFs }
            return welcomeBlockPool[id]
        end

        if kind == "welcome_action_card" then
            local card = CreateFrame("Frame", nil, content)
            card:SetClipsChildren(true)
            local war, wag, wab = GetAccentColor()

            local bg = card:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.08, 0.09, 0.11, SBgA)

            local accent = card:CreateTexture(nil, "ARTWORK")
            accent:SetHeight(3)
            accent:SetPoint("TOPLEFT", 0, 0)
            accent:SetPoint("TOPRIGHT", 0, 0)
            accent:SetColorTexture(war, wag, wab, 0.70)
            tinsert(dashAccentRefs.cardAccents, accent)

            local bottomRule = card:CreateTexture(nil, "ARTWORK")
            bottomRule:SetHeight(1)
            bottomRule:SetPoint("BOTTOMLEFT", 18, 0)
            bottomRule:SetPoint("BOTTOMRIGHT", -18, 0)
            bottomRule:SetColorTexture(war, wag, wab, 0.12)
            tinsert(dashAccentRefs.cardDividers, bottomRule)

            local icon = card:CreateTexture(nil, "ARTWORK", nil, 1)
            icon:SetTexCoord(0, 1, 0, 1)
            local eyebrowFs = MakeText(card, "", 10, 0.56, 0.75, 0.92, "LEFT")
            local titleFs = MakeText(card, "", 16, 0.97, 0.98, 1, "CENTER")
            local bodyFs = MakeDashboardWelcomeMixedScriptText(card, "", 12, 0.66, 0.69, 0.75, "CENTER")
            bodyFs:SetWordWrap(true)
            bodyFs:SetSpacing(4)
            local ctaBtn = CreateNewsCTAButton(card, false)

            welcomeBlockPool[id] = {
                kind = kind,
                root = card,
                icon = icon,
                eyebrowFs = eyebrowFs,
                titleFs = titleFs,
                bodyFs = bodyFs,
                ctaBtn = ctaBtn,
                entry = entry,
            }
            return welcomeBlockPool[id]
        end

        if kind == "welcome_support_card" then
            local card = CreateFrame("Button", nil, content)
            card:SetClipsChildren(true)
            local war, wag, wab = GetAccentColor()

            local bg = card:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.08, 0.09, 0.11, SBgA)

            -- Top accent bar (same treatment as welcome_action_card) so the row reads as one grid.
            local accent = card:CreateTexture(nil, "ARTWORK")
            accent:SetHeight(3)
            accent:SetPoint("TOPLEFT", 0, 0)
            accent:SetPoint("TOPRIGHT", 0, 0)
            accent:SetColorTexture(war, wag, wab, 0.70)
            tinsert(dashAccentRefs.cardAccents, accent)

            local titleFs = MakeText(card, "", 14, 0.96, 0.98, 1, "LEFT")
            local bodyFs = MakeDashboardWelcomeMixedScriptText(card, "", 12, 0.64, 0.68, 0.74, "LEFT")
            bodyFs:SetWordWrap(true)
            bodyFs:SetSpacing(3)
            local ctaBtn = CreateNewsCTAButton(card, false)

            local tagHost, tagLabels
            local supporterList = ResolveSupporterList(entry)
            if supporterList and #supporterList > 0 then
                tagHost = CreateFrame("Frame", nil, card)
                tagHost:SetFrameLevel((card:GetFrameLevel() or 0) + 2)
                tagHost:EnableMouse(false)
                tagLabels = {}
                local sizes = { 10, 12, 15, 18 }
                for j = 1, #supporterList do
                    local row = supporterList[j]
                    local nm = type(row) == "string" and row or (row.name or "")
                    local cf = type(row) == "table" and row.classFile or nil
                    if not cf or cf == "" then
                        cf = SUPPORTER_CLASS_FALLBACK_ORDER[((j - 1) % #SUPPORTER_CLASS_FALLBACK_ORDER) + 1]
                    end
                    local seed = j * 17
                    for k = 1, #nm do
                        seed = seed + string.byte(nm, k)
                    end
                    local sz = sizes[((seed + j) % 4) + 1]
                    local r, g, b = GetSupporterClassRGB(cf)
                    local fs = MakeText(tagHost, nm, sz, r, g, b, "LEFT")
                    if fs.EnableMouse then
                        fs:EnableMouse(false)
                    end
                    fs._supporterGapAfter = 8 + (seed % 9)
                    fs._supporterStagger = (seed * 3) % 6
                    tagLabels[j] = fs
                end
            end

            welcomeBlockPool[id] = {
                kind = kind,
                root = card,
                titleFs = titleFs,
                bodyFs = bodyFs,
                ctaBtn = ctaBtn,
                tagHost = tagHost,
                tagLabels = tagLabels,
                entry = entry,
            }
            return welcomeBlockPool[id]
        end

        if kind == "news_featured" then
            local hero = CreateFrame("Frame", nil, content)
            hero:SetClipsChildren(true)
            local nar, nag, nab = GetAccentColor()

            local bg = hero:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.07, 0.08, 0.10, math.min(1, SBgA + 0.12))

            local topGlow = hero:CreateTexture(nil, "ARTWORK")
            topGlow:SetPoint("TOPLEFT", 0, 0)
            topGlow:SetPoint("TOPRIGHT", 0, 0)
            topGlow:SetHeight(86)
            topGlow:SetColorTexture(0, 0, 0, 0)

            local bottomRule = hero:CreateTexture(nil, "ARTWORK")
            bottomRule:SetHeight(1)
            bottomRule:SetPoint("BOTTOMLEFT", 22, 0)
            bottomRule:SetPoint("BOTTOMRIGHT", -22, 0)
            bottomRule:SetColorTexture(nar, nag, nab, 0.18)

            local accent = hero:CreateTexture(nil, "ARTWORK")
            accent:SetWidth(4)
            accent:SetPoint("TOPLEFT", 0, 0)
            accent:SetPoint("BOTTOMLEFT", 0, 0)
            accent:SetColorTexture(nar, nag, nab, 1)
            tinsert(dashAccentRefs.cardAccents, accent)
            tinsert(dashAccentRefs.cardDividers, bottomRule)

            local eyebrowFs = MakeText(hero, "", 11, 0.56, 0.75, 0.92, "LEFT")
            local badgeBg = hero:CreateTexture(nil, "ARTWORK")
            badgeBg:SetColorTexture(0.20, 0.80, 0.90, 0.18)
            badgeBg:Hide()
            local badgeFs = MakeText(hero, "", 10, 0.78, 0.91, 1, "CENTER")
            badgeFs:Hide()
            local titleFs = MakeText(hero, "", 28, 0.98, 0.99, 1, "LEFT")
            local taglineFs = MakeText(hero, "", 15, 0.76, 0.80, 0.87, "LEFT")
            local bodyFs = MakeDashboardWelcomeMixedScriptText(hero, "", 13, 0.70, 0.73, 0.79, "LEFT")
            bodyFs:SetWordWrap(true)
            bodyFs:SetSpacing(4)
            local metaFs = MakeText(hero, "", 10, 0.47, 0.52, 0.58, "LEFT")
            local artFrame = CreateFrame("Frame", nil, hero)
            artFrame:SetClipsChildren(true)
            local artBg = artFrame:CreateTexture(nil, "BACKGROUND")
            artBg:SetAllPoints()
            artBg:SetColorTexture(0, 0, 0, 0)
            local art = hero:CreateTexture(nil, "ARTWORK", nil, 1)
            art:SetTexCoord(0, 1, 0, 1)
            local ctaBtn = CreateNewsCTAButton(hero, true)

            local editorialFooterRow = CreateFrame("Frame", nil, hero)
            editorialFooterRow:SetFrameLevel((hero:GetFrameLevel() or 0) + 4)
            local editorialFooterPrefixFs = MakeText(editorialFooterRow, "", 11, 0.47, 0.52, 0.58, "LEFT")
            local editorialFooterLinkBtn = CreateNewsCTAButton(editorialFooterRow, false)

            welcomeBlockPool[id] = {
                kind = kind,
                root = hero,
                topGlow = topGlow,
                bottomRule = bottomRule,
                accent = accent,
                eyebrowFs = eyebrowFs,
                badgeBg = badgeBg,
                badgeFs = badgeFs,
                titleFs = titleFs,
                taglineFs = taglineFs,
                bodyFs = bodyFs,
                metaFs = metaFs,
                artFrame = artFrame,
                artBg = artBg,
                art = art,
                ctaBtn = ctaBtn,
                editorialFooterRow = editorialFooterRow,
                editorialFooterPrefixFs = editorialFooterPrefixFs,
                editorialFooterLinkBtn = editorialFooterLinkBtn,
                entry = entry,
            }
            return welcomeBlockPool[id]
        end

        if kind == "news_card" then
            local card = CreateFrame("Frame", nil, content)
            card:SetClipsChildren(true)
            local nar, nag, nab = GetAccentColor()

            local bg = card:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.08, 0.09, 0.11, SBgA)

            local borderTop = card:CreateTexture(nil, "ARTWORK")
            borderTop:SetHeight(1)
            borderTop:SetPoint("TOPLEFT", 18, 0)
            borderTop:SetPoint("TOPRIGHT", -18, 0)
            borderTop:SetColorTexture(1, 1, 1, 0.03)

            local borderBottom = card:CreateTexture(nil, "ARTWORK")
            borderBottom:SetHeight(1)
            borderBottom:SetPoint("BOTTOMLEFT", 18, 0)
            borderBottom:SetPoint("BOTTOMRIGHT", -18, 0)
            borderBottom:SetColorTexture(nar, nag, nab, 0.12)

            local accent = card:CreateTexture(nil, "ARTWORK")
            accent:SetHeight(3)
            accent:SetPoint("TOPLEFT", 0, 0)
            accent:SetPoint("TOPRIGHT", 0, 0)
            accent:SetColorTexture(nar, nag, nab, 0.70)
            tinsert(dashAccentRefs.cardAccents, accent)
            tinsert(dashAccentRefs.cardDividers, borderBottom)

            local eyebrowFs = MakeText(card, "", 10, 0.56, 0.75, 0.92, "LEFT")
            local badgeBg = card:CreateTexture(nil, "ARTWORK")
            badgeBg:SetColorTexture(0.20, 0.80, 0.90, 0.16)
            badgeBg:Hide()
            local badgeFs = MakeText(card, "", 10, 0.78, 0.91, 1, "CENTER")
            badgeFs:Hide()
            local titleFs = MakeText(card, "", 16, 0.97, 0.98, 1, "LEFT")
            local bodyFs = MakeDashboardWelcomeMixedScriptText(card, "", 12, 0.66, 0.69, 0.75, "LEFT")
            bodyFs:SetWordWrap(true)
            bodyFs:SetSpacing(4)
            local bodyFsOverflow = MakeDashboardWelcomeMixedScriptText(card, "", 12, 0.66, 0.69, 0.75, "LEFT")
            bodyFsOverflow:SetWordWrap(true)
            bodyFsOverflow:SetSpacing(4)
            local secondaryTitleFs = MakeText(card, "", 16, 0.97, 0.98, 1, "LEFT")
            local secondaryBodyFs = MakeDashboardWelcomeMixedScriptText(card, "", 12, 0.66, 0.69, 0.75, "LEFT")
            secondaryBodyFs:SetWordWrap(true)
            secondaryBodyFs:SetSpacing(4)
            local metaFs = MakeText(card, "", 11, 0.47, 0.52, 0.58, "LEFT")
            local artFrame = CreateFrame("Frame", nil, card)
            artFrame:SetClipsChildren(true)
            local artBg = artFrame:CreateTexture(nil, "BACKGROUND")
            artBg:SetAllPoints()
            artBg:SetColorTexture(0, 0, 0, 0)
            local art = card:CreateTexture(nil, "ARTWORK", nil, 1)
            art:SetTexCoord(0, 1, 0, 1)
            local ctaBtn = CreateNewsCTAButton(card, false)

            local classIconsStrip = CreateFrame("Frame", nil, card)
            classIconsStrip:Hide()
            classIconsStrip.textures = {}
            for i = 1, #WELCOME_CLASS_ICON_STRIP_ORDER do
                local tex = classIconsStrip:CreateTexture(nil, "ARTWORK", nil, 1)
                tex:SetTexCoord(0, 1, 0, 1)
                classIconsStrip.textures[i] = tex
            end

            local editorialFooterRow = CreateFrame("Frame", nil, card)
            editorialFooterRow:SetFrameLevel((card:GetFrameLevel() or 0) + 4)
            local editorialFooterPrefixFs = MakeText(editorialFooterRow, "", 11, 0.47, 0.52, 0.58, "LEFT")
            local editorialFooterLinkBtn = CreateNewsCTAButton(editorialFooterRow, false)

            welcomeBlockPool[id] = {
                kind = kind,
                root = card,
                borderTop = borderTop,
                borderBottom = borderBottom,
                accent = accent,
                eyebrowFs = eyebrowFs,
                badgeBg = badgeBg,
                badgeFs = badgeFs,
                titleFs = titleFs,
                bodyFs = bodyFs,
                bodyFsOverflow = bodyFsOverflow,
                secondaryTitleFs = secondaryTitleFs,
                secondaryBodyFs = secondaryBodyFs,
                metaFs = metaFs,
                artFrame = artFrame,
                artBg = artBg,
                art = art,
                ctaBtn = ctaBtn,
                classIconsStrip = classIconsStrip,
                editorialFooterRow = editorialFooterRow,
                editorialFooterPrefixFs = editorialFooterPrefixFs,
                editorialFooterLinkBtn = editorialFooterLinkBtn,
                entry = entry,
            }
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

    local footerObj = nil
    if createCommunityFooter then
        footerObj = addonRef.Dashboard_CreateCommunityFooter(footerPanel, {
            L = L,
            GetAccentColor = GetAccentColor,
            MakeText = MakeText,
            addon = addonRef,
        })
        if footerObj and footerObj.footerTopRule then
            tinsert(dashAccentRefs.communityFooterTopRules, footerObj.footerTopRule)
        end
    end

    local function UpdateNewsBadge(badgeBg, badgeFs, text)
        if not badgeBg or not badgeFs then return end
        if type(text) ~= "string" or text == "" then
            badgeBg:Hide()
            badgeFs:Hide()
            return
        end
        badgeFs:SetText(text)
        local w = math.max(34, (badgeFs:GetStringWidth() or 0) + 18)
        badgeBg:SetSize(w, 18)
        badgeBg:Show()
        badgeFs:Show()
    end

    -- News + welcome hero: wrap class icons across N rows (e.g. 3) so each row has fewer tiles and icons read much larger.
    local function LayoutDashboardClassIconStrip(strip, width, opts)
        opts = opts or {}
        local topTexInset = tonumber(opts.topTexInset) or 0
        local bottomPad = tonumber(opts.bottomPad) or 4
        if not strip or not strip.textures then return 0 end
        local nStrip = #WELCOME_CLASS_ICON_STRIP_ORDER
        if nStrip <= 0 then
            strip:Hide()
            return 0
        end
        local w = math.max(120, width or 0)
        local nRows = math.max(1, math.floor(tonumber(opts.numRows) or CLASS_ICON_STRIP_ROW_COUNT))
        local rowVGap = math.max(4, tonumber(opts.rowVGap) or CLASS_ICON_STRIP_ROW_VGAP)
        local minEdgeGap = 8
        local base = math.floor(nStrip / nRows)
        local extra = nStrip % nRows
        local rowCounts = {}
        for r = 1, nRows do
            rowCounts[r] = base + (r <= extra and 1 or 0)
        end
        local iconPx = CLASS_ICON_STRIP_MAX_PX
        for r = 1, nRows do
            local k = rowCounts[r]
            if k > 0 then
                local cap = math.floor((w - (k + 1) * minEdgeGap) / k)
                if cap < iconPx then
                    iconPx = cap
                end
            end
        end
        if iconPx < 24 then
            minEdgeGap = 4
            iconPx = CLASS_ICON_STRIP_MAX_PX
            for r = 1, nRows do
                local k = rowCounts[r]
                if k > 0 then
                    local cap = math.floor((w - (k + 1) * minEdgeGap) / k)
                    if cap < iconPx then
                        iconPx = cap
                    end
                end
            end
        end
        iconPx = math.max(16, math.min(CLASS_ICON_STRIP_MAX_PX, iconPx))
        local stripH = topTexInset + nRows * iconPx + (nRows - 1) * rowVGap + bottomPad
        strip:SetSize(w, stripH)
        local idx = 0
        local yTop = topTexInset
        for r = 1, nRows do
            local k = rowCounts[r]
            local gapEach = (w - k * iconPx) / (k + 1)
            for j = 1, k do
                idx = idx + 1
                local tex = strip.textures[idx]
                if tex then
                    local cf = WELCOME_CLASS_ICON_STRIP_ORDER[idx]
                    if addonRef.ResolveClassIconDisplay then
                        local disp = addonRef.ResolveClassIconDisplay(cf, "custom")
                        if disp and disp.kind == "file" and disp.path then
                            tex:SetTexture(disp.path)
                        end
                    end
                    tex:SetSize(iconPx, iconPx)
                    tex:ClearAllPoints()
                    tex:SetPoint(
                        "TOPLEFT",
                        strip,
                        "TOPLEFT",
                        gapEach + (j - 1) * (iconPx + gapEach),
                        -yTop
                    )
                    tex:Show()
                end
            end
            yTop = yTop + iconPx + rowVGap
        end
        for i = idx + 1, #strip.textures do
            local tex = strip.textures[i]
            if tex then
                tex:Hide()
            end
        end
        strip:Show()
        return stripH
    end

    local function LayoutNewsClassStrip(strip, width)
        return LayoutDashboardClassIconStrip(strip, width, { topTexInset = 0, bottomPad = 4 })
    end

    LayoutWelcomeContent = function()
        local rawW = welcomeBg:GetWidth() or 0
        local w = math.max(280, rawW - 40)
        local viewW = welcomeView:GetWidth() or 0
        local wFooter = math.max(280, viewW - 40)
        local innerPad = 28
        local learnSectionTopY = nil

        if footerObj and footerObj.layout then
            footerObj.layout(wFooter, 0, welcomeView)
        end

        welcomeScroll:ClearAllPoints()
        welcomeScroll:SetPoint("TOPLEFT", welcomeBg, "TOPLEFT", SCROLL_TO_BG_INSET, -WELCOME_CONTENT_TOP_PAD)
        if createCommunityFooter then
            welcomeScroll:SetPoint("BOTTOMLEFT", footerPanel, "TOPLEFT", 0, WELCOME_SCROLL_ABOVE_FOOTER_GAP)
        else
            welcomeScroll:SetPoint("BOTTOMLEFT", welcomeBg, "BOTTOMLEFT", SCROLL_TO_BG_INSET, 20)
        end
        welcomeScroll:SetPoint("TOPRIGHT", welcomeBg, "TOPRIGHT", -SCROLL_TO_BG_INSET, -WELCOME_CONTENT_TOP_PAD)
        if createCommunityFooter then
            welcomeScroll:SetPoint("BOTTOMRIGHT", footerPanel, "TOPRIGHT", 0, WELCOME_SCROLL_ABOVE_FOOTER_GAP)
        else
            welcomeScroll:SetPoint("BOTTOMRIGHT", welcomeBg, "BOTTOMRIGHT", -SCROLL_TO_BG_INSET, 20)
        end

        content:SetWidth(w)
        local y = 0
        local feed = GetSortedFeed(feedData)
        local activeIds = {}

        if targetViewName == "welcome" then
            local heroEntry = nil
            local actionEntries, supportEntries = {}, {}
            for i = 1, #feed do
                local entry = feed[i]
                if entry.kind == "welcome_hero" then
                    heroEntry = entry
                elseif entry.kind == "welcome_action_card" then
                    actionEntries[#actionEntries + 1] = entry
                elseif entry.kind == "welcome_support_card" then
                    supportEntries[#supportEntries + 1] = entry
                end
            end

            if heroEntry then
                local pool = EnsureWelcomeBlock(heroEntry)
                if pool then
                    activeIds[heroEntry.id] = true
                    local hero = pool.root
                    local pad = 22
                    local textW = w - pad * 2
                    local eyebrowKey = heroEntry.eyebrowKey
                    local eyebrowText = (eyebrowKey and L[eyebrowKey]) or ""
                    if eyebrowText ~= "" then
                        pool.eyebrowFs:SetText(eyebrowText)
                        pool.eyebrowFs:Show()
                    else
                        pool.eyebrowFs:SetText("")
                        pool.eyebrowFs:Hide()
                    end
                    pool.titleFs:SetText(L[heroEntry.titleKey] or "")
                    pool.taglineFs:SetText(L[heroEntry.taglineKey] or "")
                    pool.bodyFs:SetText(L[heroEntry.bodyKey] or "")

                    hero:SetWidth(w)
                    hero:ClearAllPoints()
                    hero:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)

                    local yt = pad
                    if eyebrowText ~= "" then
                        pool.eyebrowFs:SetWidth(textW)
                        pool.eyebrowFs:ClearAllPoints()
                        pool.eyebrowFs:SetPoint("TOPLEFT", hero, "TOPLEFT", pad, -yt)
                        yt = yt + pool.eyebrowFs:GetHeight() + 8
                    end
                    pool.titleFs:SetWidth(textW)
                    pool.titleFs:ClearAllPoints()
                    pool.titleFs:SetPoint("TOPLEFT", hero, "TOPLEFT", pad, -yt)
                    yt = yt + pool.titleFs:GetHeight() + 6
                    pool.taglineFs:SetWidth(textW)
                    pool.taglineFs:ClearAllPoints()
                    pool.taglineFs:SetPoint("TOPLEFT", hero, "TOPLEFT", pad, -yt)
                    yt = yt + pool.taglineFs:GetHeight() + 18
                    pool.bodyFs:SetWidth(textW)
                    pool.bodyFs:ClearAllPoints()
                    pool.bodyFs:SetPoint("TOPLEFT", hero, "TOPLEFT", pad, -yt)
                    yt = yt + pool.bodyFs:GetHeight()

                    hero:SetHeight(yt + pad)
                    hero:Show()
                    y = y + hero:GetHeight() + 16
                end
            end

            if #actionEntries > 0 then
                local cols = (w >= 780) and 3 or ((w >= 560) and 2 or 1)
                local cardW = math.floor((w - (cols - 1) * WELCOME_ACTION_GRID_GAP) / cols)
                local rowY = y
                local pad = 22
                local textW = cardW - pad * 2
                local nAction = #actionEntries

                local function MeasureAndLayoutWelcomeActionCard(entry, pool, card, colIndex, rowYLocal)
                    activeIds[entry.id] = true
                    local hasIcon = ApplyWelcomeActionCardIcon(pool.icon, entry)

                    card:SetWidth(cardW)
                    card:ClearAllPoints()
                    card:SetPoint("TOPLEFT", content, "TOPLEFT", colIndex * (cardW + WELCOME_ACTION_GRID_GAP), -rowYLocal)

                    if hasIcon then
                        pool.icon:SetSize(34, 34)
                        pool.icon:ClearAllPoints()
                        pool.icon:SetPoint("TOP", card, "TOP", 0, -pad)
                        pool.icon:Show()
                    else
                        pool.icon:Hide()
                    end

                    local eyebrowText = (entry.eyebrowKey and L[entry.eyebrowKey]) or ""
                    pool.eyebrowFs:SetText(eyebrowText)
                    pool.titleFs:SetText(L[entry.titleKey] or "")
                    pool.bodyFs:SetText(L[entry.bodyKey] or "")
                    pool.ctaBtn:SetLabel(L[entry.ctaLabelKey] or "")
                    pool.ctaBtn:SetScript("OnClick", function() DispatchNewsAction(entry) end)

                    local titleTopY = pad
                    if hasIcon then
                        titleTopY = pad + 34 + 8
                    end
                    if eyebrowText ~= "" then
                        pool.eyebrowFs:Show()
                        pool.eyebrowFs:SetWidth(textW)
                        pool.eyebrowFs:ClearAllPoints()
                        if pool.eyebrowFs.SetJustifyH then
                            pool.eyebrowFs:SetJustifyH("CENTER")
                        end
                        pool.eyebrowFs:SetPoint("TOP", card, "TOP", 0, -titleTopY)
                        titleTopY = titleTopY + pool.eyebrowFs:GetHeight() + 6
                    else
                        pool.eyebrowFs:Hide()
                    end
                    pool.titleFs:SetWidth(textW)
                    pool.titleFs:ClearAllPoints()
                    pool.titleFs:SetPoint("TOP", card, "TOP", 0, -titleTopY)
                    local yt = titleTopY + pool.titleFs:GetHeight() + 8
                    pool.bodyFs:SetWidth(textW)
                    pool.bodyFs:ClearAllPoints()
                    pool.bodyFs:SetPoint("TOP", card, "TOP", 0, -yt)
                    local contentBottom = yt + pool.bodyFs:GetHeight()
                    local naturalH = contentBottom
                        + WELCOME_ACTION_CARD_FOOTER_GAP
                        + WELCOME_ACTION_CARD_CTA_H
                        + WELCOME_ACTION_CARD_FOOTER_BOTTOM_INSET
                    pool.ctaBtn:Show()
                    return math.max(WELCOME_ACTION_CARD_MIN_H, naturalH)
                end

                local rowStart = 1
                while rowStart <= nAction do
                    local rowEnd = math.min(rowStart + cols - 1, nAction)
                    local rowMax = WELCOME_ACTION_CARD_MIN_H
                    for j = rowStart, rowEnd do
                        local entry = actionEntries[j]
                        local pool = EnsureWelcomeBlock(entry)
                        if pool then
                            local colIndex = j - rowStart
                            local h = MeasureAndLayoutWelcomeActionCard(entry, pool, pool.root, colIndex, rowY)
                            rowMax = math.max(rowMax, h)
                        end
                    end
                    for j = rowStart, rowEnd do
                        local entry = actionEntries[j]
                        local pool = EnsureWelcomeBlock(entry)
                        if pool then
                            local card = pool.root
                            card:SetHeight(rowMax)
                            pool.ctaBtn:ClearAllPoints()
                            pool.ctaBtn:SetPoint("BOTTOM", card, "BOTTOM", 0, WELCOME_ACTION_CARD_FOOTER_BOTTOM_INSET)
                            card:Show()
                        end
                    end
                    rowY = rowY + rowMax + WELCOME_ACTION_GRID_GAP
                    rowStart = rowEnd + 1
                end
                y = rowY + 8
            end

            if addonRef.DashboardModuleGuide_LayoutEmbedded then
                learnSectionTopY = y
                y = addonRef.DashboardModuleGuide_LayoutEmbedded(w, y, innerPad) or y
                y = y + 16
            end

            if #supportEntries > 0 then
                local cols = (w >= 820) and 3 or ((w >= 560) and 2 or 1)
                local cardW = math.floor((w - (cols - 1) * WELCOME_SUPPORT_GRID_GAP) / cols)
                local rowY = y
                local rowH = 0
                for i = 1, #supportEntries do
                    local entry = supportEntries[i]
                    local pool = EnsureWelcomeBlock(entry)
                    if pool then
                        activeIds[entry.id] = true
                        local col = (i - 1) % cols
                        if col == 0 then rowH = 0 end
                        local card = pool.root
                        local pad = 22
                        local textW = cardW - pad * 2

                        pool.titleFs:SetText(L[entry.titleKey] or "")
                        pool.ctaBtn:SetLabel(L[entry.ctaLabelKey] or "")
                        pool.ctaBtn:SetScript("OnClick", function()
                            DispatchNewsAction(entry)
                        end)
                        card:SetScript("OnClick", function()
                            if entry.ctaAction then
                                DispatchNewsAction(entry)
                            end
                        end)

                        card:SetWidth(cardW)
                        card:ClearAllPoints()
                        card:SetPoint("TOPLEFT", content, "TOPLEFT", col * (cardW + WELCOME_SUPPORT_GRID_GAP), -rowY)
                        pool.titleFs:SetWidth(textW)
                        pool.titleFs:ClearAllPoints()
                        pool.titleFs:SetPoint("TOPLEFT", card, "TOPLEFT", pad, -pad)
                        local yt = pad + pool.titleFs:GetHeight() + 8

                        local supporterListLayout = ResolveSupporterList(entry)
                        if pool.tagHost and pool.tagLabels and supporterListLayout and #supporterListLayout > 0 then
                            local intro = L[entry.bodyKey] or ""
                            pool.bodyFs:SetText(intro)
                            pool.bodyFs:SetWidth(textW)
                            pool.bodyFs:ClearAllPoints()
                            pool.bodyFs:SetPoint("TOPLEFT", card, "TOPLEFT", pad, -yt)
                            if intro:find("%S") then
                                pool.bodyFs:Show()
                                if pool.bodyFs.EnableMouse then
                                    pool.bodyFs:EnableMouse(false)
                                end
                                yt = yt + pool.bodyFs:GetHeight() + 10
                            else
                                pool.bodyFs:Hide()
                            end
                            local nSup = #supporterListLayout
                            local tagFlowW = textW
                            if nSup >= 4 then
                                tagFlowW = math.min(textW, math.max(168, math.floor(textW * 0.68)))
                            end
                            if nSup >= 5 then
                                tagFlowW = math.min(tagFlowW, 280)
                            end
                            pool.tagHost:SetWidth(tagFlowW)
                            pool.tagHost:ClearAllPoints()
                            pool.tagHost:SetPoint("TOPLEFT", card, "TOPLEFT", pad, -yt)
                            LayoutSupporterTagFlow(pool.tagHost, tagFlowW, supporterListLayout, pool.tagLabels)
                            yt = yt + pool.tagHost:GetHeight()
                        else
                            pool.bodyFs:Show()
                            pool.bodyFs:SetText(L[entry.bodyKey] or "")
                            pool.bodyFs:SetWidth(textW)
                            pool.bodyFs:ClearAllPoints()
                            pool.bodyFs:SetPoint("TOPLEFT", card, "TOPLEFT", pad, -yt)
                            yt = yt + pool.bodyFs:GetHeight()
                        end
                        if entry.ctaAction and entry.ctaLabelKey then
                            yt = yt + 14
                            pool.ctaBtn:ClearAllPoints()
                            pool.ctaBtn:SetPoint("TOPLEFT", card, "TOPLEFT", pad, -yt)
                            pool.ctaBtn:Show()
                            yt = yt + pool.ctaBtn:GetHeight()
                        else
                            pool.ctaBtn:Hide()
                        end
                        local cardH = yt + pad
                        card:SetHeight(math.max(140, cardH))
                        card:Show()
                        rowH = math.max(rowH, card:GetHeight())
                        if col == cols - 1 or i == #supportEntries then
                            rowY = rowY + rowH + WELCOME_SUPPORT_GRID_GAP
                        end
                    end
                end
                y = rowY
            end
        elseif targetViewName == "news" then
            local featuredEntries = {}
            local secondaryEntries = {}
            for i = 1, #feed do
                local entry = feed[i]
                if entry.kind == "news_featured" then
                    featuredEntries[#featuredEntries + 1] = entry
                elseif entry.kind == "news_card" then
                    secondaryEntries[#secondaryEntries + 1] = entry
                end
            end

            for i = 1, #featuredEntries do
                local entry = featuredEntries[i]
                local pool = EnsureWelcomeBlock(entry)
                if pool then
                    activeIds[entry.id] = true
                    local pad = 30
                    local hero = pool.root
                    local artPath = ResolveNewsTexturePath(entry)
                    local hasArt = artPath and artPath ~= ""
                    local textColW = w - pad * 2
                    local artW, artH = 0, 0

                    if hasArt then
                        artW = math.max(NEWS_FEATURED_MIN_ART_W, math.floor(w * 0.28))
                        artW = math.min(artW, math.max(NEWS_FEATURED_MIN_ART_W, w - pad * 2 - 280))
                        pool.art:SetTexture(artPath)
                        artW, artH = ComputeNewsContainedSize(entry, pool.art, artW, 176, true, 16 / 9)
                        pool.art:SetSize(artW, artH)
                        pool.art:Show()
                        local artBoxW = math.max(NEWS_FEATURED_MIN_ART_W, artW)
                        pool.artFrame:SetSize(artBoxW, 176)
                        pool.artFrame:Show()
                        textColW = math.max(220, w - pad * 2 - artBoxW - 24)
                    else
                        pool.artFrame:Hide()
                        pool.art:Hide()
                    end

                    local badgeText = L[entry.badgeKey] or ""
                    local ctaText = L[entry.ctaLabelKey] or ""
                    local metaStr = L[entry.metaKey] or ""
                    pool.eyebrowFs:SetText(L[entry.eyebrowKey] or "")
                    UpdateNewsBadge(pool.badgeBg, pool.badgeFs, badgeText)
                    pool.titleFs:SetText(L[entry.titleKey] or "")
                    pool.taglineFs:SetText(L[entry.taglineKey] or "")
                    pool.bodyFs:SetText(L[entry.bodyKey] or "")
                    pool.metaFs:SetText(metaStr)
                    pool.ctaBtn:SetScript("OnClick", function() DispatchNewsAction(entry) end)
                    pool.ctaBtn:SetLabel(ctaText)
                    if ctaText ~= "" then pool.ctaBtn:Show() else pool.ctaBtn:Hide() end

                    hero:SetWidth(w)
                    hero:ClearAllPoints()
                    hero:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)

                    local textX = pad
                    local textY = pad
                    pool.eyebrowFs:ClearAllPoints()
                    pool.eyebrowFs:SetPoint("TOPLEFT", hero, "TOPLEFT", textX, -textY)
                    if badgeText ~= "" then
                        pool.badgeBg:ClearAllPoints()
                        pool.badgeBg:SetPoint("LEFT", pool.eyebrowFs, "RIGHT", 12, 0)
                        pool.badgeFs:ClearAllPoints()
                        pool.badgeFs:SetPoint("CENTER", pool.badgeBg, "CENTER", 0, 0)
                    end

                    textY = textY + pool.eyebrowFs:GetHeight() + 10
                    pool.titleFs:SetWidth(textColW)
                    pool.titleFs:ClearAllPoints()
                    pool.titleFs:SetPoint("TOPLEFT", hero, "TOPLEFT", textX, -textY)
                    textY = textY + pool.titleFs:GetHeight() + 8
                    pool.taglineFs:SetWidth(textColW)
                    pool.taglineFs:ClearAllPoints()
                    pool.taglineFs:SetPoint("TOPLEFT", hero, "TOPLEFT", textX, -textY)
                    textY = textY + pool.taglineFs:GetHeight() + 12
                    pool.bodyFs:SetWidth(textColW)
                    pool.bodyFs:ClearAllPoints()
                    pool.bodyFs:SetPoint("TOPLEFT", hero, "TOPLEFT", textX, -textY)
                    textY = textY + pool.bodyFs:GetHeight() + NEWS_FEATURED_BODY_BEFORE_FOOTER_GAP

                    if ctaText ~= "" then
                        pool.ctaBtn:ClearAllPoints()
                        pool.ctaBtn:SetPoint("TOPLEFT", hero, "TOPLEFT", textX, -textY)
                        textY = textY + pool.ctaBtn:GetHeight()
                    end

                    pool.metaFs:Hide()
                    local footerReserve = NEWS_CARD_EDITORIAL_FOOTER_GAP_ABOVE
                        + NEWS_CARD_EDITORIAL_FOOTER_AREA_H
                        + NEWS_CARD_EDITORIAL_FOOTER_BOTTOM_INSET
                    local heroH = textY + footerReserve
                    if hasArt then
                        local artBoxH = pool.artFrame:GetHeight() or artH
                        pool.artFrame:ClearAllPoints()
                        pool.artFrame:SetPoint("TOPRIGHT", hero, "TOPRIGHT", -pad, -pad)
                        pool.art:ClearAllPoints()
                        pool.art:SetPoint("CENTER", pool.artFrame, "CENTER", 0, 0)
                        heroH = math.max(heroH, artBoxH + pad * 2)
                    end

                    hero:SetHeight(math.max(230, heroH))

                    local eRow = pool.editorialFooterRow
                    local ePrefix = pool.editorialFooterPrefixFs
                    local eLink = pool.editorialFooterLinkBtn
                    if eRow and ePrefix and eLink then
                        ePrefix:SetText(metaStr ~= "" and metaStr or (L["DASH_NEWS_EDITORIAL_FOOTER_PREFIX"] or ""))
                        eLink:SetLabel(L["DASH_NEWS_EDITORIAL_FOOTER_LINK"] or "Patch notes")
                        eLink:SetScript("OnClick", function()
                            if f.ShowPatchNotes then f.ShowPatchNotes() end
                        end)
                        local rowW = w - 2 * pad
                        local linkW = eLink:GetWidth()
                        ePrefix:SetWidth(math.max(60, rowW - linkW - 10))
                        ePrefix:ClearAllPoints()
                        ePrefix:SetPoint("BOTTOMLEFT", eRow, "BOTTOMLEFT", 0, 0)
                        eLink:ClearAllPoints()
                        eLink:SetPoint("LEFT", ePrefix, "RIGHT", 6, 0)
                        local fh = math.max(ePrefix:GetHeight(), eLink:GetHeight()) + 4
                        eRow:SetSize(rowW, fh)
                        eRow:ClearAllPoints()
                        eRow:SetPoint("BOTTOMLEFT", hero, "BOTTOMLEFT", pad, NEWS_CARD_EDITORIAL_FOOTER_BOTTOM_INSET)
                        eRow:Show()
                    end
                    hero:Show()
                    y = y + hero:GetHeight() + 18
                end
            end

            local cols = (w >= NEWS_GRID_TWO_COL_MIN_W) and 2 or 1
            local cardW = (cols == 2) and math.floor((w - NEWS_GRID_GAP) / 2) or w
            local rowY = y
            local rowH = 0
            for i = 1, #secondaryEntries do
                local entry = secondaryEntries[i]
                local pool = EnsureWelcomeBlock(entry)
                if pool then
                    activeIds[entry.id] = true
                    local col = (i - 1) % cols
                    if col == 0 then rowH = 0 end

                    local card = pool.root
                    local pad = 22
                    local artPath = ResolveNewsTexturePath(entry)
                    local showArt = artPath and artPath ~= ""
                    local showStrip = entry.showClassIconStrip and true or false
                    local badgeText = L[entry.badgeKey] or ""
                    local ctaText = L[entry.ctaLabelKey] or ""
                    local leftX = col * (cardW + NEWS_GRID_GAP)
                    local ctaInFooterOnly = (entry.id == "class_icons" or entry.id == "coming_soon")

                    pool.eyebrowFs:SetText(L[entry.eyebrowKey] or "")
                    UpdateNewsBadge(pool.badgeBg, pool.badgeFs, badgeText)
                    pool.titleFs:SetText(L[entry.titleKey] or "")
                    local fullBodyText = L[entry.bodyKey] or ""
                    pool.bodyFs:SetText(fullBodyText)
                    pool.bodyFsOverflow:SetText("")
                    if ctaInFooterOnly then
                        pool.ctaBtn:Hide()
                    else
                        pool.ctaBtn:SetScript("OnClick", function() DispatchNewsAction(entry) end)
                        pool.ctaBtn:SetLabel(ctaText)
                        if ctaText ~= "" then pool.ctaBtn:Show() else pool.ctaBtn:Hide() end
                    end

                    card:SetWidth(cardW)
                    card:ClearAllPoints()
                    card:SetPoint("TOPLEFT", content, "TOPLEFT", leftX, -rowY)

                    pool._newsMediaSplitLayout = false
                    pool._newsNaturalCardHeight = nil

                    local textW = cardW - pad * 2
                    local textY = pad
                    local isMediaVariant = showArt and entry.variant == "media"
                    local availForSplit = cardW - 2 * pad - NEWS_MEDIA_SPLIT_COL_GAP
                    local artColW = math.max(
                        NEWS_MEDIA_WRAP_MIN_W,
                        math.min(NEWS_MEDIA_WRAP_MAX_W, math.floor(availForSplit * 0.48))
                    )
                    local leftColW = availForSplit - artColW
                    local useMediaSplit = isMediaVariant and leftColW >= NEWS_MEDIA_SPLIT_MIN_LEFT_W
                    local useMediaStacked = isMediaVariant and not useMediaSplit
                    local copyW = useMediaSplit and leftColW or textW
                    local artBoxHForSplit = NEWS_MEDIA_WRAP_H

                    if showArt then
                        pool.art:SetTexture(artPath)
                        local artBoxW = textW
                        local artBoxH = 96
                        if useMediaSplit then
                            artBoxW = artColW
                            artBoxH = NewsMediaClipBoxHeight(
                                artColW,
                                entry,
                                pool.art,
                                NEWS_MEDIA_WRAP_H,
                                NEWS_MEDIA_SPLIT_MAX_H
                            )
                            artBoxHForSplit = artBoxH
                            pool._newsMediaSplitLayout = true
                            pool.artFrame:SetSize(artBoxW, artBoxH)
                            pool.artFrame:ClearAllPoints()
                            pool.artFrame:SetPoint("TOPRIGHT", card, "TOPRIGHT", -pad, -pad)
                        elseif useMediaStacked then
                            artBoxW = textW
                            artBoxH = NewsMediaClipBoxHeight(
                                textW,
                                entry,
                                pool.art,
                                NEWS_MEDIA_WRAP_H,
                                NEWS_MEDIA_STACK_MAX_H
                            )
                            pool.artFrame:SetSize(artBoxW, artBoxH)
                            pool.artFrame:ClearAllPoints()
                            pool.artFrame:SetPoint("TOPLEFT", card, "TOPLEFT", pad, -pad)
                        else
                            pool.artFrame:SetSize(artBoxW, artBoxH)
                            pool.artFrame:ClearAllPoints()
                            pool.artFrame:SetPoint("TOPLEFT", card, "TOPLEFT", pad, -pad)
                        end
                        pool.artFrame:Show()
                        local dispW, dispH = ComputeNewsContainedSize(entry, pool.art, artBoxW, artBoxH, true, 16 / 9)
                        pool.art:SetSize(dispW, dispH)
                        pool.art:ClearAllPoints()
                        pool.art:SetPoint("CENTER", pool.artFrame, "CENTER", 0, 0)
                        pool.art:Show()
                        if not useMediaSplit then
                            textY = textY + artBoxH + 14
                        end
                    else
                        pool.artFrame:Hide()
                        pool.art:Hide()
                    end

                    pool.bodyFsOverflow:Hide()
                    pool.eyebrowFs:ClearAllPoints()
                    pool.eyebrowFs:SetPoint("TOPLEFT", card, "TOPLEFT", pad, -textY)
                    local eyebrowW = copyW
                    if badgeText ~= "" then
                        local badgeW = pool.badgeBg:GetWidth() or 0
                        eyebrowW = math.max(1, copyW - badgeW - NEWS_BADGE_EYEBROW_GAP)
                    end
                    pool.eyebrowFs:SetWidth(eyebrowW)
                    if badgeText ~= "" then
                        pool.badgeBg:ClearAllPoints()
                        pool.badgeBg:SetPoint("LEFT", pool.eyebrowFs, "RIGHT", NEWS_BADGE_EYEBROW_GAP, 0)
                        pool.badgeFs:ClearAllPoints()
                        pool.badgeFs:SetPoint("CENTER", pool.badgeBg, "CENTER", 0, 0)
                    end

                    textY = textY + pool.eyebrowFs:GetHeight() + 10
                    pool.titleFs:SetWidth(copyW)
                    pool.titleFs:ClearAllPoints()
                    pool.titleFs:SetPoint("TOPLEFT", card, "TOPLEFT", pad, -textY)
                    textY = textY + pool.titleFs:GetHeight() + 8
                    pool.bodyFs:SetWidth(copyW)
                    pool.bodyFs:ClearAllPoints()
                    pool.bodyFs:SetPoint("TOPLEFT", card, "TOPLEFT", pad, -textY)
                    pool.bodyFs:SetText(fullBodyText)
                    textY = textY + pool.bodyFs:GetHeight() + 12

                    local secTitle = (entry.secondaryTitleKey and L[entry.secondaryTitleKey]) or ""
                    local secBody = (entry.secondaryBodyKey and L[entry.secondaryBodyKey]) or ""
                    if secTitle ~= "" and pool.secondaryTitleFs and pool.secondaryBodyFs then
                        textY = textY + NEWS_CARD_SECONDARY_BLOCK_GAP
                        pool.secondaryTitleFs:SetText(secTitle)
                        pool.secondaryTitleFs:SetWidth(copyW)
                        pool.secondaryTitleFs:ClearAllPoints()
                        pool.secondaryTitleFs:SetPoint("TOPLEFT", card, "TOPLEFT", pad, -textY)
                        pool.secondaryTitleFs:Show()
                        textY = textY + pool.secondaryTitleFs:GetHeight() + 8
                        if secBody ~= "" then
                            pool.secondaryBodyFs:SetText(secBody)
                            pool.secondaryBodyFs:SetWidth(copyW)
                            pool.secondaryBodyFs:ClearAllPoints()
                            pool.secondaryBodyFs:SetPoint("TOPLEFT", card, "TOPLEFT", pad, -textY)
                            pool.secondaryBodyFs:Show()
                            textY = textY + pool.secondaryBodyFs:GetHeight() + 12
                        else
                            pool.secondaryBodyFs:SetText("")
                            pool.secondaryBodyFs:Hide()
                        end
                    else
                        if pool.secondaryTitleFs then
                            pool.secondaryTitleFs:SetText("")
                            pool.secondaryTitleFs:Hide()
                        end
                        if pool.secondaryBodyFs then
                            pool.secondaryBodyFs:SetText("")
                            pool.secondaryBodyFs:Hide()
                        end
                    end

                    if showStrip then
                        pool.classIconsStrip:ClearAllPoints()
                        pool.classIconsStrip:SetPoint("TOPLEFT", card, "TOPLEFT", pad, -textY)
                        textY = textY + LayoutNewsClassStrip(pool.classIconsStrip, copyW) + 12
                    else
                        pool.classIconsStrip:Hide()
                    end

                    local storyMeta = (entry.metaKey and L[entry.metaKey]) or ""
                    local metaInFooterOnly = (entry.id == "class_icons")
                    if metaInFooterOnly then
                        pool.metaFs:SetText("")
                        pool.metaFs:Hide()
                    elseif storyMeta ~= "" then
                        pool.metaFs:SetText(storyMeta)
                        pool.metaFs:SetWidth(copyW)
                        pool.metaFs:ClearAllPoints()
                        pool.metaFs:SetPoint("TOPLEFT", card, "TOPLEFT", pad, -textY)
                        pool.metaFs:Show()
                        textY = textY + pool.metaFs:GetHeight() + 12
                    else
                        pool.metaFs:SetText("")
                        pool.metaFs:Hide()
                    end

                    if ctaText ~= "" and not ctaInFooterOnly then
                        pool.ctaBtn:ClearAllPoints()
                        pool.ctaBtn:SetPoint("TOPLEFT", card, "TOPLEFT", pad, -textY)
                        textY = textY + pool.ctaBtn:GetHeight()
                    end

                    local naturalContentBottom = textY
                    if useMediaSplit then
                        naturalContentBottom = math.max(textY, pad + artBoxHForSplit)
                    end
                    local footerReserve = NEWS_CARD_EDITORIAL_FOOTER_GAP_ABOVE
                        + NEWS_CARD_EDITORIAL_FOOTER_AREA_H
                        + NEWS_CARD_EDITORIAL_FOOTER_BOTTOM_INSET
                    local cardH = math.max(NEWS_CARD_MIN_H, naturalContentBottom + footerReserve)
                    pool._newsNaturalCardHeight = cardH
                    pool._newsEditorialFooterReserve = footerReserve
                    card:SetHeight(cardH)
                    card:Show()

                    local eRow = pool.editorialFooterRow
                    local ePrefix = pool.editorialFooterPrefixFs
                    local eLink = pool.editorialFooterLinkBtn
                    if eRow and ePrefix and eLink then
                        local rowEntry = entry
                        if entry.id == "class_icons" then
                            ePrefix:SetText(storyMeta)
                            eLink:SetLabel(ctaText ~= "" and ctaText or (L["DASH_NEWS_CTA_VIEW_ARTIST"] or ""))
                            eLink:SetScript("OnClick", function()
                                DispatchNewsAction(rowEntry)
                            end)
                        else
                            ePrefix:SetText(L["DASH_NEWS_EDITORIAL_FOOTER_PREFIX"] or "")
                            eLink:SetLabel(L["DASH_NEWS_EDITORIAL_FOOTER_LINK"] or "Patch notes")
                            eLink:SetScript("OnClick", function()
                                if f.ShowPatchNotes then f.ShowPatchNotes() end
                            end)
                        end
                        local rowW = cardW - 2 * pad
                        local linkW = eLink:GetWidth()
                        ePrefix:SetWidth(math.max(60, rowW - linkW - 10))
                        ePrefix:ClearAllPoints()
                        ePrefix:SetPoint("BOTTOMLEFT", eRow, "BOTTOMLEFT", 0, 0)
                        eLink:ClearAllPoints()
                        eLink:SetPoint("LEFT", ePrefix, "RIGHT", 6, 0)
                        local fh = math.max(ePrefix:GetHeight(), eLink:GetHeight()) + 4
                        eRow:SetSize(rowW, fh)
                        eRow:ClearAllPoints()
                        eRow:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", pad, NEWS_CARD_EDITORIAL_FOOTER_BOTTOM_INSET)
                        eRow:Show()
                    end

                    rowH = math.max(rowH, cardH)

                    if col == cols - 1 or i == #secondaryEntries then
                        -- Match card heights within the row when multiple columns (news grid).
                        if cols >= 2 then
                            local j0 = i - col
                            for j = j0, i do
                                local rowEntry = secondaryEntries[j]
                                local rowPool = EnsureWelcomeBlock(rowEntry)
                                if rowPool and rowPool.root then
                                    rowPool.root:SetHeight(rowH)
                                    if rowPool._newsMediaSplitLayout then
                                        local p = pad
                                        local naturalH = rowPool._newsNaturalCardHeight or rowH
                                        local af = rowPool.artFrame
                                        if af and af:IsShown() then
                                            local ah = af:GetHeight() or NEWS_MEDIA_WRAP_H
                                            local footerR = rowPool._newsEditorialFooterReserve
                                                or (NEWS_CARD_EDITORIAL_FOOTER_GAP_ABOVE
                                                    + NEWS_CARD_EDITORIAL_FOOTER_AREA_H
                                                    + NEWS_CARD_EDITORIAL_FOOTER_BOTTOM_INSET)
                                            if rowH > naturalH + 0.5 then
                                                local inner = rowH - 2 * p - footerR
                                                local topOff = p + math.max(0, math.floor((inner - ah) / 2 + 0.5))
                                                af:ClearAllPoints()
                                                af:SetPoint("TOPRIGHT", rowPool.root, "TOPRIGHT", -p, -topOff)
                                            else
                                                af:ClearAllPoints()
                                                af:SetPoint("TOPRIGHT", rowPool.root, "TOPRIGHT", -p, -p)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        rowY = rowY + rowH + NEWS_GRID_GAP
                    end
                end
            end

            y = rowY
        else

        for fi = 1, #feed do
            local entry = feed[fi]
            -- Sentinel: embed the module guide below the welcome feed items
            if entry.kind == "module_guide_section" then
                if addonRef.DashboardModuleGuide_LayoutEmbedded then
                    y = addonRef.DashboardModuleGuide_LayoutEmbedded(w, y, innerPad) or y
                end
            else
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
                    local maxStripW = classTextW
                    pool.classIconsStrip:ClearAllPoints()
                    pool.classIconsStrip:SetPoint("TOPLEFT", hero, "TOPLEFT", classHeroPad, -cyt)
                    local stripH = LayoutDashboardClassIconStrip(
                        pool.classIconsStrip,
                        maxStripW,
                        { topTexInset = 2, bottomPad = 8 }
                    )
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
                    if card.expanded then
                        card:SetHeight(card.fullHeight)
                    else
                        card:SetHeight(card.collapsedHeight)
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
            end  -- else (not module_guide_section)
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

        if targetViewName == "welcome" and learnSectionTopY and f and not f._welcomeLearnPeekApplied and maxScroll > 0 and viewH > 80 then
            local targetPeekScroll = learnSectionTopY - viewH + WELCOME_LEARN_SECTION_PEEK_PX
            targetPeekScroll = math.max(0, math.min(maxScroll, targetPeekScroll))
            welcomeScroll:SetVerticalScroll(targetPeekScroll)
            welcomeScroll.targetScroll = nil
            f._welcomeLearnPeekApplied = true
            curScroll = targetPeekScroll
        end

        if curScroll > maxScroll then
            welcomeScroll:SetVerticalScroll(maxScroll)
            welcomeScroll.targetScroll = nil
        end
    end

    -- Expose layout function so embedded guide (DashboardModuleGuide_Init) can trigger re-layout on accordion expand
    welcomeView._layoutWelcomeContent = LayoutWelcomeContent

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

    if targetViewName == "welcome" then
        f.ShowWelcome = function()
            if f.pnChangelogHeaderBtn then f.pnChangelogHeaderBtn:Hide() end
            HideContextHeader()
            detailView:Hide()
            subCategoryView:Hide()
            dashboardView:Hide()
            if f.guideView then f.guideView:Hide() end
            patchNotesView:Hide()
            if env.newsView then env.newsView:Hide() end
            if f.searchView then f.searchView:Hide() end
            welcomeView:SetAlpha(0)
            welcomeView:Show()
            UIFrameFadeIn(welcomeView, 0.2, 0, 1)
            if head then head:Show() end
            if headSub then
                headSub:Show()
                headSub:SetText(L[headSubKey] or L["DASH_WELCOME_HEAD_SUB"] or "Credits, community, and where to find help")
            end
            if searchBarShell then searchBarShell:Hide() end
            if f.HideSearchDropdown then f.HideSearchDropdown() end
            if f.DockSearchDropdownForModule then f.DockSearchDropdownForModule() end
            f.currentModuleKey = nil
            SetSidebarState({ view = "welcome", activeModuleKey = CLEAR, activeCategoryIndex = CLEAR })
            if addonRef.DashboardPreview and addonRef.DashboardPreview.SetActiveModuleKey then
                addonRef.DashboardPreview.SetActiveModuleKey(nil)
            end
            if addonRef.ApplyDashboardClassColor then addonRef.ApplyDashboardClassColor() end
        end
    end
end
