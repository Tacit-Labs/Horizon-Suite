--[[
    Horizon Suite - Dashboard home grid, module tiles, and welcome tab.
    Wired from DashboardFrame.lua via addon.DashboardHomeWelcome_Init(env).
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

--- @param env table
--- @return table { RefreshDashboardTiles = function }
function addon.DashboardHomeWelcome_Init(env)
    local f = env.f
    local addon = env.addon
    local L = env.L
    local dashboardView = env.dashboardView
    local welcomeView = env.welcomeView
    local detailView = env.detailView
    local subCategoryView = env.subCategoryView
    local patchNotesView = env.patchNotesView
    local dashScrollTopOffset = env.dashScrollTopOffset
    local dashAccentRefs = env.dashAccentRefs
    local GetAccentColor = env.GetAccentColor
    local MakeText = env.MakeText
    local MakeDashboardWelcomeMixedScriptText = env.MakeDashboardWelcomeMixedScriptText
    local moduleLabels = env.moduleLabels
    local categoryIcons = env.categoryIcons
    local PREVIEW_MODULE_KEYS = env.PREVIEW_MODULE_KEYS
    local COMING_SOON_MODULE_KEYS = env.COMING_SOON_MODULE_KEYS
    local TILE_MODULE_LABEL_COLORS = env.TILE_MODULE_LABEL_COLORS
    local ShouldShowModuleOnDashboard = env.ShouldShowModuleOnDashboard
    local DASH_HOME_TILE_W = env.DASH_HOME_TILE_W
    local DASH_HOME_TILE_H = env.DASH_HOME_TILE_H
    local DASH_HOME_TILE_GAP = env.DASH_HOME_TILE_GAP
    local DASH_HOME_TILE_COLS = env.DASH_HOME_TILE_COLS
    local DASH_HOME_TILE_BG_ALPHA_MULT = env.DASH_HOME_TILE_BG_ALPHA_MULT
    local DASH_HOME_TILE_BORDER_ALPHA_MULT = env.DASH_HOME_TILE_BORDER_ALPHA_MULT
    local DASH_HOME_SKELETON_BG_ALPHA_MULT = env.DASH_HOME_SKELETON_BG_ALPHA_MULT
    local DASH_HOME_SKELETON_BORDER_ALPHA_MULT = env.DASH_HOME_SKELETON_BORDER_ALPHA_MULT
    local DASHBOARD_CONTENT_CARD_ALPHA_MULT = env.DASHBOARD_CONTENT_CARD_ALPHA_MULT
    local HideContextHeader = env.HideContextHeader
    local SetSidebarState = env.setSidebarState
    local CLEAR = env.CLEAR
    local searchBox = env.searchBox
    local head = env.head
    local headSub = env.headSub
    local detailNav = env.detailNav

    local WDef = addon.OptionsWidgetsDef
    local SBg = (WDef and WDef.SectionCardBg) or { 0.09, 0.09, 0.11, 0.96 }
    local SBd = (WDef and WDef.SectionCardBorder) or { 0.18, 0.2, 0.24, 0.35 }
    local SBgA = SBg[4] * DASHBOARD_CONTENT_CARD_ALPHA_MULT
    local SBgHoverR, SBgHoverG, SBgHoverB = 0.11, 0.11, 0.13
    local SBgExpandedR, SBgExpandedG, SBgExpandedB = 0.10, 0.10, 0.12

    -- Icons by moduleKey so localized tile titles still resolve art.
    local dashboardTileIconByKey = {
        axis = "INV_Misc_Wrench_01",
        focus = "achievement_quests_completed_05",
        presence = "vas_guildnamechange",
        vista = "ability_hunter_pathfinding",
        insight = "ui_profession_inscription",
        cache = "INV_Misc_Coin_01",
        essence = "achievement_character_human_male",
        meridian = "ability_tracking",
    }

    local function DashboardAxisBentoHeight()
        return DASH_HOME_TILE_H * 3 + DASH_HOME_TILE_GAP * 2
    end

    local function DashboardTileSizeForKey(mk)
        if mk == "axis" then
            return DASH_HOME_TILE_W, DashboardAxisBentoHeight()
        end
        return DASH_HOME_TILE_W, DASH_HOME_TILE_H
    end

    -- Copy-to-clipboard: same custom dialog as Patch Notes "Full changelog" (addon.ShowURLCopyBox in core/Core.lua)
    local function ShowCopyURL(label, url)
        if addon.ShowURLCopyBox then
            addon.ShowURLCopyBox(url, (L["DASH_COPY_LINK_X"] or "Copy link — %s"):format(label))
        end
    end

    local function MakeTile(parent, name, icon, moduleKey)
        local tile = CreateFrame("Button", nil, parent)
        tile.moduleKey = moduleKey
        local tw, th = DashboardTileSizeForKey(moduleKey)
        local isAxis = moduleKey == "axis"
        tile:SetSize(tw, th)

        local tileH = th
        local fillA = SBgA * DASH_HOME_TILE_BG_ALPHA_MULT
        local borderA = SBd[4] * DASH_HOME_TILE_BORDER_ALPHA_MULT

        -- Background (softer than section cards)
        local tBg = tile:CreateTexture(nil, "BACKGROUND", nil, -8)
        tBg:SetPoint("TOPLEFT", 2, -2)
        tBg:SetPoint("BOTTOMRIGHT", -2, 2)
        tBg:SetColorTexture(SBg[1], SBg[2], SBg[3], fillA)

        -- Top sheen (gradient when supported)
        local sheen = tile:CreateTexture(nil, "BACKGROUND", nil, -7)
        sheen:SetPoint("TOPLEFT", tBg, "TOPLEFT", 0, 0)
        sheen:SetPoint("TOPRIGHT", tBg, "TOPRIGHT", 0, 0)
        sheen:SetHeight(math.min(56, math.floor(tileH * 0.38)))
        if sheen.SetGradient and CreateColor then
            sheen:SetGradient("VERTICAL", CreateColor(1, 1, 1, 0.09), CreateColor(0.04, 0.05, 0.08, 0))
        else
            sheen:SetColorTexture(1, 1, 1, 0.04)
        end

        -- Outer border
        local border = tile:CreateTexture(nil, "BORDER")
        border:SetAllPoints()
        border:SetColorTexture(SBd[1], SBd[2], SBd[3], borderA)

        -- Inner hairline (top edge — lifts card off flat fill)
        local innerTop = tile:CreateTexture(nil, "ARTWORK", nil, -8)
        innerTop:SetHeight(1)
        innerTop:SetPoint("TOPLEFT", tBg, "TOPLEFT", 1, -1)
        innerTop:SetPoint("TOPRIGHT", tBg, "TOPRIGHT", -1, -1)
        innerTop:SetColorTexture(1, 1, 1, 0.11)

        -- Axis: subtle class-accent rail (idle)
        local axisRail = nil
        if isAxis then
            axisRail = tile:CreateTexture(nil, "ARTWORK", nil, -7)
            axisRail:SetWidth(3)
            axisRail:SetPoint("TOPLEFT", tBg, "TOPLEFT", 0, 0)
            axisRail:SetPoint("BOTTOMLEFT", tBg, "BOTTOMLEFT", 0, 0)
            local rr, rg, rb = GetAccentColor()
            axisRail:SetColorTexture(rr, rg, rb, 0.35)
            tile.axisRail = axisRail
            tinsert(dashAccentRefs.dashboardAxisRails, axisRail)
        end

        local iconPath = dashboardTileIconByKey[moduleKey] or categoryIcons[name] or "INV_Misc_Question_01"
        local ic = tile:CreateTexture(nil, "ARTWORK")
        ic:SetTexture("Interface\\Icons\\" .. iconPath)
        ic:SetVertexColor(0.80, 0.80, 0.85, 0.82)

        local tileDivider = tile:CreateTexture(nil, "ARTWORK")
        tileDivider:SetHeight(1)
        tileDivider:SetColorTexture(0.20, 0.21, 0.26, 0.28)

        local lbl = MakeText(tile, name, 13, 0.80, 0.80, 0.85, "CENTER")
        tile.label = lbl
        local mc = TILE_MODULE_LABEL_COLORS[moduleKey]
        tile._moduleLabelR = mc and mc[1] or 0.80
        tile._moduleLabelG = mc and mc[2] or 0.80
        tile._moduleLabelB = mc and mc[3] or 0.85
        lbl:SetTextColor(tile._moduleLabelR, tile._moduleLabelG, tile._moduleLabelB)

        if moduleKey and PREVIEW_MODULE_KEYS[moduleKey] then
            local prevLabel = "(" .. (L["OPTIONS_PRESENCE_PREVIEW"] or "Preview") .. ")"
            local prevBadge = MakeText(tile, prevLabel, 9, 34/255, 139/255, 34/255, "CENTER")
            prevBadge:SetPoint("TOP", lbl, "BOTTOM", 0, -1)
            tile.previewBadge = prevBadge
        elseif moduleKey and COMING_SOON_MODULE_KEYS[moduleKey] then
            local csLabel = "(" .. (L["OPTIONS_CORE_COMING_SOON"] or "Coming Soon") .. ")"
            local csBadge = MakeText(tile, csLabel, 9, 0.55, 0.70, 0.90, "CENTER")
            csBadge:SetPoint("TOP", lbl, "BOTTOM", 0, -1)
            tile.previewBadge = csBadge
        end

        local bottomGlow = tile:CreateTexture(nil, "ARTWORK")
        bottomGlow:SetHeight(2)
        bottomGlow:SetPoint("BOTTOMLEFT", 1, 1)
        bottomGlow:SetPoint("BOTTOMRIGHT", -1, 1)
        bottomGlow:SetColorTexture(1, 1, 1, 0)

        local fillANormal = SBgA * DASH_HOME_TILE_BG_ALPHA_MULT
        local borderANormal = SBd[4] * DASH_HOME_TILE_BORDER_ALPHA_MULT
        tile._dashBorderIdleR, tile._dashBorderIdleG, tile._dashBorderIdleB = SBd[1], SBd[2], SBd[3]
        tile._dashBorderIdleA = borderANormal
        tile._isSkeleton = false

        --- Apply disabled-module (skeleton) or normal idle chrome for this Home tile.
        --- @param skeleton boolean
        --- @return nil
        tile.SetDashboardSkeletonMode = function(_, skeleton)
            tile._isSkeleton = skeleton and true or false
            if tile._isSkeleton then
                tBg:SetColorTexture(SBg[1], SBg[2], SBg[3], fillANormal * DASH_HOME_SKELETON_BG_ALPHA_MULT)
                border:SetColorTexture(SBd[1], SBd[2], SBd[3], borderANormal * DASH_HOME_SKELETON_BORDER_ALPHA_MULT)
                tile._dashBorderIdleR, tile._dashBorderIdleG, tile._dashBorderIdleB = SBd[1], SBd[2], SBd[3]
                tile._dashBorderIdleA = borderANormal * DASH_HOME_SKELETON_BORDER_ALPHA_MULT
                if ic.SetDesaturated then ic:SetDesaturated(true) end
                ic:SetVertexColor(0.5, 0.52, 0.56, 0.68)
                lbl:SetTextColor(0.44, 0.46, 0.49)
                if tile.previewBadge then
                    tile.previewBadge:SetTextColor(0.32, 0.58, 0.34, 0.8)
                end
                tileDivider:SetColorTexture(0.14, 0.15, 0.17, 0.22)
                innerTop:SetColorTexture(1, 1, 1, 0.04)
                if sheen.SetGradient and CreateColor then
                    sheen:SetGradient("VERTICAL", CreateColor(1, 1, 1, 0.03), CreateColor(0.04, 0.05, 0.08, 0))
                else
                    sheen:SetColorTexture(1, 1, 1, 0.015)
                end
                bottomGlow:SetColorTexture(1, 1, 1, 0)
                if tile.axisRail then
                    local rr, rg, rb = GetAccentColor()
                    tile.axisRail:SetColorTexture(rr, rg, rb, 0.22)
                end
            else
                tBg:SetColorTexture(SBg[1], SBg[2], SBg[3], fillANormal)
                border:SetColorTexture(SBd[1], SBd[2], SBd[3], borderANormal)
                tile._dashBorderIdleR, tile._dashBorderIdleG, tile._dashBorderIdleB = SBd[1], SBd[2], SBd[3]
                tile._dashBorderIdleA = borderANormal
                if ic.SetDesaturated then ic:SetDesaturated(false) end
                ic:SetVertexColor(0.80, 0.80, 0.85, 0.82)
                lbl:SetTextColor(tile._moduleLabelR, tile._moduleLabelG, tile._moduleLabelB)
                if tile.previewBadge then
                    tile.previewBadge:SetTextColor(34/255, 139/255, 34/255, 1)
                end
                tileDivider:SetColorTexture(0.20, 0.21, 0.26, 0.28)
                innerTop:SetColorTexture(1, 1, 1, 0.11)
                if sheen.SetGradient and CreateColor then
                    sheen:SetGradient("VERTICAL", CreateColor(1, 1, 1, 0.09), CreateColor(0.04, 0.05, 0.08, 0))
                else
                    sheen:SetColorTexture(1, 1, 1, 0.04)
                end
                bottomGlow:SetColorTexture(1, 1, 1, 0)
                if tile.axisRail then
                    local rr, rg, rb = GetAccentColor()
                    tile.axisRail:SetColorTexture(rr, rg, rb, 0.35)
                end
            end
        end

        tile.ApplyDashboardTileLayout = function(_, h)
            h = h or tile:GetHeight() or DASH_HOME_TILE_H
            local axis = tile.moduleKey == "axis"
            local icSize = axis and 72 or 54
            ic:SetSize(icSize, icSize)
            if axis then
                -- Bento block: icon upper-middle, label band at bottom (same stack height as two small tiles).
                ic:SetPoint("CENTER", tile, "CENTER", -4, 28)
                tileDivider:ClearAllPoints()
                tileDivider:SetPoint("LEFT", tile, "LEFT", 28, 0)
                tileDivider:SetPoint("RIGHT", tile, "RIGHT", -28, 0)
                tileDivider:SetPoint("BOTTOM", tile, "BOTTOM", 0, 46)
                lbl:ClearAllPoints()
                lbl:SetPoint("BOTTOM", tile, "BOTTOM", -6, 22)
            else
                ic:SetPoint("CENTER", tile, "CENTER", 0, 12)
                tileDivider:ClearAllPoints()
                tileDivider:SetPoint("LEFT", tile, "LEFT", 20, 0)
                tileDivider:SetPoint("RIGHT", tile, "RIGHT", -22, 0)
                tileDivider:SetPoint("BOTTOM", tile, "BOTTOM", 0, 42)
                lbl:ClearAllPoints()
                lbl:SetPoint("BOTTOM", tile, "BOTTOM", 0, 19)
            end
            sheen:SetHeight(math.min(axis and 100 or 56, math.floor(h * (axis and 0.32 or 0.38))))
        end
        tile.ApplyDashboardTileLayout(tile, tileH)

        tile:SetScript("OnEnter", function()
            if tile._isSkeleton then
                border:SetColorTexture(tile._dashBorderIdleR, tile._dashBorderIdleG, tile._dashBorderIdleB, math.min(1, tile._dashBorderIdleA * 1.2))
                ic:SetVertexColor(0.58, 0.60, 0.64, 0.82)
                lbl:SetTextColor(0.55, 0.57, 0.60)
                bottomGlow:SetColorTexture(tile._dashBorderIdleR, tile._dashBorderIdleG, tile._dashBorderIdleB, 0.22)
                innerTop:SetColorTexture(1, 1, 1, 0.07)
                if tile.previewBadge then
                    tile.previewBadge:SetTextColor(0.38, 0.65, 0.40, 0.9)
                end
                if tile.axisRail then
                    local ar, ag, ab = GetAccentColor()
                    tile.axisRail:SetColorTexture(ar, ag, ab, 0.35)
                end
            else
                local ar, ag, ab = GetAccentColor()
                border:SetColorTexture(ar, ag, ab, 0.55)
                ic:SetVertexColor(1, 1, 1, 1)
                lbl:SetTextColor(1, 1, 1)
                bottomGlow:SetColorTexture(ar, ag, ab, 0.48)
                innerTop:SetColorTexture(1, 1, 1, 0.16)
                if tile.axisRail then
                    tile.axisRail:SetColorTexture(ar, ag, ab, 0.55)
                end
            end
        end)
        tile:SetScript("OnLeave", function()
            if tile.SetDashboardSkeletonMode then
                tile:SetDashboardSkeletonMode(tile._isSkeleton)
            end
        end)
        tile:SetScript("OnClick", function()
            if tile._isComingSoon then
                ShowCopyURL(L["DASH_DISCORD"] or "Discord", "https://discord.com/invite/e7nW2f4VQj")
            elseif tile._isSkeleton then
                detailNav.NavigateToModuleToggles()
            else
                f.OpenModule(name, moduleKey)
            end
        end)

        return tile
    end

    -- Group logic (tiles and sidebar; refreshable for live module toggle updates)
    local dashboardTilePool = {}
    local function BuildMainTilesList()
        local out = {}
        local seen = {}
        tinsert(out, { name = moduleLabels.axis or "Axis", moduleKey = "axis", isSkeleton = false })
        tinsert(out, { name = moduleLabels.meridian or "Meridian", moduleKey = "meridian", isSkeleton = true, isComingSoon = true })
        for _, cat in ipairs(addon.OptionCategories) do
            local mk = cat.moduleKey
            if mk and not seen[mk] then
                seen[mk] = true
                local enabled = ShouldShowModuleOnDashboard(mk)
                tinsert(out, {
                    name = moduleLabels[mk] or mk,
                    moduleKey = mk,
                    -- Disabled modules: same desaturated skeleton chrome + Module Toggles on click as preview modules.
                    isSkeleton = not enabled,
                })
            end
        end
        table.sort(out, function(a, b) return a.name:lower() < b.name:lower() end)
        return out
    end

    -- Bento: Axis occupies column 0 rows 0–1 (same width as other tiles, two rows tall); others fill remaining cells in row-major order.
    local function RefreshDashboardTiles()
        local mainTiles = BuildMainTilesList()
        local TILE_W, TILE_H, TILE_GAP = DASH_HOME_TILE_W, DASH_HOME_TILE_H, DASH_HOME_TILE_GAP
        local STRIDE = TILE_W + TILE_GAP
        local COLS = DASH_HOME_TILE_COLS
        local TOP_Y = -152

        local gridOuterW = COLS * TILE_W + (COLS - 1) * TILE_GAP
        local gridHalfW = gridOuterW / 2

        local function CellCenterX(col)
            return -gridHalfW + TILE_W / 2 + col * STRIDE
        end

        local function CellReservedForAxis(row, col)
            return col == 0 and row <= 2
        end

        local axisInfo = nil
        local others = {}
        for _, info in ipairs(mainTiles) do
            if info.moduleKey == "axis" then
                axisInfo = info
            else
                others[#others + 1] = info
            end
        end

        local slots = {}
        local maxScanRows = math.max(12, math.ceil((#others + 2) / 3) + 6)
        for row = 0, maxScanRows do
            for col = 0, COLS - 1 do
                if not CellReservedForAxis(row, col) then
                    slots[#slots + 1] = { r = row, c = col }
                    if #slots >= #others then
                        break
                    end
                end
            end
            if #slots >= #others then
                break
            end
        end

        local function PlaceTile(tileInfo, centerX, topY)
            local tile = dashboardTilePool[tileInfo.moduleKey]
            if not tile then
                tile = MakeTile(dashboardView, tileInfo.name, nil, tileInfo.moduleKey)
                dashboardTilePool[tileInfo.moduleKey] = tile
            end
            if tile.label then tile.label:SetText(tileInfo.name) end
            local tw, th = DashboardTileSizeForKey(tileInfo.moduleKey)
            tile:SetSize(tw, th)
            if tile.ApplyDashboardTileLayout then
                tile.ApplyDashboardTileLayout(tile, th)
            end
            tile:ClearAllPoints()
            tile:SetPoint("TOP", dashboardView, "TOP", centerX, topY)
            tile._isComingSoon = tileInfo.isComingSoon and true or false
            if tile.SetDashboardSkeletonMode then
                tile:SetDashboardSkeletonMode(tileInfo.isSkeleton and true or false)
            end
            tile:Show()
        end

        if axisInfo then
            PlaceTile(axisInfo, CellCenterX(0), TOP_Y)
        end

        for i = 1, #others do
            local slot = slots[i]
            if slot then
                local topY = TOP_Y - slot.r * (TILE_H + TILE_GAP)
                PlaceTile(others[i], CellCenterX(slot.c), topY)
            end
        end

        local inKeys = {}
        if axisInfo then inKeys.axis = true end
        for _, info in ipairs(others) do
            inKeys[info.moduleKey] = true
        end
        for mk, tile in pairs(dashboardTilePool) do
            if not inKeys[mk] then tile:Hide() end
        end
    end

    RefreshDashboardTiles()

    -- Welcome tab (always in sidebar, above Home; dedicated view)
    do
        -- Match DashboardModuleGuide.lua: bg nudge, scroll insets, footer link row, scroll–footer gap.
        local WELCOME_BG_TOP_NUDGE = 50
        local WELCOME_CONTENT_TOP_PAD = 6
        local WELCOME_ACC_HEAD_H = 48
        local WELCOME_SCROLL_BODY_X_INSET = 0
        local WELCOME_SCROLL_ABOVE_FOOTER_GAP = 10
        local SCROLL_TO_BG_INSET = 20
        local FOOTER_TO_BG_BOTTOM = 14
        local FOOTER_LINK_BTN_W = 82
        local FOOTER_LINK_GAP = 10

        local welcomeBg = welcomeView:CreateTexture(nil, "BACKGROUND")
        welcomeBg:SetPoint("TOPLEFT", 28, dashScrollTopOffset + WELCOME_BG_TOP_NUDGE)
        -- Room for footer links only (bottom buttons removed)
        welcomeBg:SetPoint("BOTTOMRIGHT", welcomeView, "BOTTOMRIGHT", -28, 20)

        -- Scrollable body (title, intro, accordions, shortcuts); footer stays fixed so expanded accordions do not cover Community & Support.
        local footerPanel = CreateFrame("Frame", nil, welcomeView)
        footerPanel:SetFrameLevel((welcomeView:GetFrameLevel() or 0) + 10)

        local welcomeScroll = CreateFrame("ScrollFrame", nil, welcomeView, "UIPanelScrollFrameTemplate")
        welcomeScroll:SetFrameLevel((welcomeView:GetFrameLevel() or 0) + 2)
        welcomeScroll.ScrollBar:Hide()
        welcomeScroll.ScrollBar:ClearAllPoints()

        local content = CreateFrame("Frame", nil, welcomeScroll)
        content:SetSize(400, 1)
        welcomeScroll:SetScrollChild(content)
        addon.Dashboard_ApplySmoothScroll(welcomeScroll, content, 60, true)

        -- Accordion aligned with detail-view section cards; calls onLayout during resize animation.
        local function CreateWelcomeAccordionCard(parent, titleText, onLayout)
            local card = CreateFrame("Frame", nil, parent)
            card:SetHeight(WELCOME_ACC_HEAD_H)
            card.expanded = false
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

            return card
        end

        local function CreateWelcomeTextLink(parent, label, onClick, justify)
            justify = justify or "CENTER"
            local btn = CreateFrame("Button", nil, parent)
            btn:SetSize(100, 20)
            local lbl = MakeText(btn, label, 12, 0.52, 0.56, 0.62, justify)
            lbl:ClearAllPoints()
            if justify == "LEFT" then
                lbl:SetPoint("LEFT", btn, "LEFT", 0, 0)
                lbl:SetPoint("RIGHT", btn, "RIGHT", 0, 0)
            else
                lbl:SetAllPoints()
            end
            btn.label = lbl
            local underline = btn:CreateTexture(nil, "OVERLAY")
            underline:SetHeight(1)
            underline:SetPoint("BOTTOM", btn, "BOTTOM", 0, 0)
            underline:SetPoint("LEFT", btn, "LEFT", 0, 0)
            underline:SetPoint("RIGHT", btn, "RIGHT", 0, 0)
            underline:Hide()
            btn.underline = underline
            btn:SetScript("OnEnter", function()
                lbl:SetTextColor(0.88, 0.90, 0.94)
                local ar, ag, ab = GetAccentColor()
                underline:SetColorTexture(ar, ag, ab, 0.6)
                underline:Show()
            end)
            btn:SetScript("OnLeave", function()
                lbl:SetTextColor(0.52, 0.56, 0.62)
                underline:Hide()
            end)
            btn:SetScript("OnClick", onClick)
            return btn
        end

        local LayoutWelcomeContent
        local contributorsCard = CreateWelcomeAccordionCard(content, L["DASH_WELCOME_CONTRIBUTORS_HEADING"] or "Contributors", function()
            LayoutWelcomeContent()
        end)
        local contributorsBodyFs = MakeDashboardWelcomeMixedScriptText(contributorsCard.settingsContainer, L["DASH_WELCOME_CONTRIBUTORS_BODY"] or "", 12, 0.62, 0.65, 0.70, "LEFT")
        contributorsBodyFs:SetWordWrap(true)
        contributorsBodyFs:SetSpacing(4)

        local localisationsCard = CreateWelcomeAccordionCard(content, L["DASH_WELCOME_LOCALISATIONS_HEADING"] or "Localisations", function()
            LayoutWelcomeContent()
        end)
        local localisationsBodyFs = MakeDashboardWelcomeMixedScriptText(localisationsCard.settingsContainer, L["DASH_WELCOME_LOCALISATIONS_BODY"] or "", 12, 0.62, 0.65, 0.70, "LEFT")
        localisationsBodyFs:SetWordWrap(true)
        localisationsBodyFs:SetSpacing(4)

        local titleFs = MakeText(content, L["DASH_WELCOME_TITLE"] or "Welcome to Horizon Suite", 22, 1, 1, 1, "LEFT")

        local introFs = MakeDashboardWelcomeMixedScriptText(content, L["DASH_WELCOME_INTRO"] or "", 13, 0.72, 0.74, 0.78, "LEFT")
        introFs:SetWordWrap(true)
        introFs:SetSpacing(4)

        local shortcutsHdr = MakeText(content, (L["DASH_WELCOME_QUICK_LINKS_HEADING"] or "Shortcuts"), 16, 0.88, 0.90, 0.94, "LEFT")

        local function DismissWelcomeAndOpenModuleToggles()
            if addon.SetDB then addon.SetDB("dashboardWelcomeSeen", true) end
            detailNav.NavigateToModuleToggles()
        end

        local btnOpenQuickStart = CreateWelcomeTextLink(content, L["DASH_WELCOME_OPEN_QUICK_START_LINK"] or "Open Quick Start", function()
            if f.ShowModuleGuide then
                f.ShowModuleGuide()
            end
        end, "LEFT")

        local btnOpenModuleToggles = CreateWelcomeTextLink(content, L["DASH_WELCOME_OPEN_MODULE_TOGGLES_LINK"] or "Open module toggles", DismissWelcomeAndOpenModuleToggles, "LEFT")

        -- Footer: Community & Support + external links (copy URL)
        local footerTopRule = footerPanel:CreateTexture(nil, "ARTWORK")
        footerTopRule:SetHeight(1)
        footerTopRule:SetColorTexture(0.22, 0.24, 0.30, 0.85)

        local communityHdr = MakeText(footerPanel, L["DASH_WELCOME_COMMUNITY_HEADING"] or "Community & Support", 14, 0.52, 0.56, 0.62, "LEFT")

        local linkData = {
            { label = L["DASH_DISCORD"] or "Discord", url = "https://discord.com/invite/e7nW2f4VQj" },
            { label = L["DASH_KO_FI"] or "Ko-fi", url = "https://ko-fi.com/horizonsuite" },
            { label = L["DASH_PATREON"] or "Patreon", url = "https://patreon.com/HorizonSuite" },
            { label = L["DASH_GITLAB"] or "GitLab", url = "https://gitlab.com/Crystilac/horizon-suite" },
            { label = L["DASH_CURSEFORGE"] or "CurseForge", url = "https://www.curseforge.com/projects/1457844" },
            { label = L["DASH_WAGO"] or "Wago", url = "https://addons.wago.io/addons/jK8gY56y" },
        }

        local linkButtons = {}
        for _, link in ipairs(linkData) do
            local btn = CreateWelcomeTextLink(footerPanel, link.label, function()
                ShowCopyURL(link.label, link.url)
            end, "CENTER")
            tinsert(linkButtons, btn)
        end

        LayoutWelcomeContent = function()
            local rawW = welcomeBg:GetWidth() or 0
            local w = math.max(280, rawW - 40)
            local innerPad = 28

            -- --- Footer (bottom of card) ---
            local fy = 0
            footerTopRule:ClearAllPoints()
            footerTopRule:SetPoint("TOPLEFT", footerPanel, "TOPLEFT", 0, -fy)
            footerTopRule:SetPoint("TOPRIGHT", footerPanel, "TOPRIGHT", 0, -fy)
            fy = fy + 1 + 12

            communityHdr:SetWidth(w)
            communityHdr:ClearAllPoints()
            communityHdr:SetPoint("TOPLEFT", footerPanel, "TOPLEFT", 0, -fy)
            fy = fy + communityHdr:GetHeight() + 8

            local totalLinkWidth = (#linkButtons * FOOTER_LINK_BTN_W) + ((#linkButtons - 1) * FOOTER_LINK_GAP)
            local linkRowX = math.max(0, (w - totalLinkWidth) / 2)

            for i, btn in ipairs(linkButtons) do
                btn:SetWidth(FOOTER_LINK_BTN_W)
                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT", footerPanel, "TOPLEFT", linkRowX + (i - 1) * (FOOTER_LINK_BTN_W + FOOTER_LINK_GAP), -fy)
            end
            fy = fy + 20

            footerPanel:SetWidth(w)
            footerPanel:SetHeight(math.max(fy + 4, 1))
            footerPanel:ClearAllPoints()
            footerPanel:SetPoint("BOTTOMLEFT", welcomeBg, "BOTTOMLEFT", SCROLL_TO_BG_INSET, FOOTER_TO_BG_BOTTOM)
            footerPanel:SetPoint("BOTTOMRIGHT", welcomeBg, "BOTTOMRIGHT", -SCROLL_TO_BG_INSET, FOOTER_TO_BG_BOTTOM)

            welcomeScroll:ClearAllPoints()
            welcomeScroll:SetPoint("TOPLEFT", welcomeBg, "TOPLEFT", SCROLL_TO_BG_INSET, -WELCOME_CONTENT_TOP_PAD)
            welcomeScroll:SetPoint("BOTTOMLEFT", footerPanel, "TOPLEFT", 0, WELCOME_SCROLL_ABOVE_FOOTER_GAP)
            welcomeScroll:SetPoint("TOPRIGHT", welcomeBg, "TOPRIGHT", -SCROLL_TO_BG_INSET, -WELCOME_CONTENT_TOP_PAD)
            welcomeScroll:SetPoint("BOTTOMRIGHT", footerPanel, "TOPRIGHT", 0, WELCOME_SCROLL_ABOVE_FOOTER_GAP)

            -- --- Body (scroll child; height may exceed viewport) ---
            content:SetWidth(w)
            local y = 0
            titleFs:SetWidth(w)
            titleFs:ClearAllPoints()
            titleFs:SetPoint("TOPLEFT", content, "TOPLEFT", WELCOME_SCROLL_BODY_X_INSET, -y)
            y = y + titleFs:GetHeight() + 12
            introFs:SetWidth(w)
            introFs:ClearAllPoints()
            introFs:SetPoint("TOPLEFT", content, "TOPLEFT", WELCOME_SCROLL_BODY_X_INSET, -y)
            y = y + introFs:GetHeight() + 12

            contributorsBodyFs:ClearAllPoints()
            contributorsBodyFs:SetPoint("TOPLEFT", contributorsCard.settingsContainer, "TOPLEFT", innerPad, -10)
            contributorsBodyFs:SetPoint("TOPRIGHT", contributorsCard.settingsContainer, "TOPRIGHT", -innerPad, -10)
            local contribBodyH = contributorsBodyFs:GetHeight()
            contributorsCard.fullHeight = WELCOME_ACC_HEAD_H + 10 + contribBodyH + 14
            if not contributorsCard.anim:IsPlaying() then
                if contributorsCard.expanded then
                    contributorsCard:SetHeight(contributorsCard.fullHeight)
                else
                    contributorsCard:SetHeight(contributorsCard.collapsedHeight)
                end
            end
            contributorsCard:SetWidth(w)
            contributorsCard:ClearAllPoints()
            contributorsCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
            y = y + contributorsCard:GetHeight() + 8

            localisationsBodyFs:ClearAllPoints()
            localisationsBodyFs:SetPoint("TOPLEFT", localisationsCard.settingsContainer, "TOPLEFT", innerPad, -10)
            localisationsBodyFs:SetPoint("TOPRIGHT", localisationsCard.settingsContainer, "TOPRIGHT", -innerPad, -10)
            local locBodyH = localisationsBodyFs:GetHeight()
            localisationsCard.fullHeight = WELCOME_ACC_HEAD_H + 10 + locBodyH + 14
            if not localisationsCard.anim:IsPlaying() then
                if localisationsCard.expanded then
                    localisationsCard:SetHeight(localisationsCard.fullHeight)
                else
                    localisationsCard:SetHeight(localisationsCard.collapsedHeight)
                end
            end
            localisationsCard:SetWidth(w)
            localisationsCard:ClearAllPoints()
            localisationsCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
            y = y + localisationsCard:GetHeight() + 16

            shortcutsHdr:SetWidth(w)
            shortcutsHdr:ClearAllPoints()
            shortcutsHdr:SetPoint("TOPLEFT", content, "TOPLEFT", WELCOME_SCROLL_BODY_X_INSET, -y)
            y = y + shortcutsHdr:GetHeight() + 8

            local qsLabel = L["DASH_WELCOME_OPEN_QUICK_START_LINK"] or "Open Quick Start"
            btnOpenQuickStart.label:SetText(qsLabel)
            local qsw = btnOpenQuickStart.label:GetStringWidth() or 120
            btnOpenQuickStart:SetSize(math.min(w, math.floor(qsw) + 12), 20)
            btnOpenQuickStart:ClearAllPoints()
            btnOpenQuickStart:SetPoint("TOPLEFT", content, "TOPLEFT", WELCOME_SCROLL_BODY_X_INSET, -y)
            y = y + btnOpenQuickStart:GetHeight() + 8

            local togglesLabel = L["DASH_WELCOME_OPEN_MODULE_TOGGLES_LINK"] or "Open module toggles"
            btnOpenModuleToggles.label:SetText(togglesLabel)
            local tw = btnOpenModuleToggles.label:GetStringWidth() or 120
            btnOpenModuleToggles:SetSize(math.min(w, math.floor(tw) + 12), 20)
            btnOpenModuleToggles:ClearAllPoints()
            btnOpenModuleToggles:SetPoint("TOPLEFT", content, "TOPLEFT", WELCOME_SCROLL_BODY_X_INSET, -y)
            y = y + btnOpenModuleToggles:GetHeight() + 16

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
            end
        end)
        welcomeView:SetScript("OnSizeChanged", function()
            if welcomeView:IsShown() then LayoutWelcomeContent() end
        end)

        f.ShowWelcome = function()
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
                headSub:SetText(L["DASH_WELCOME_HEAD_SUB"] or "Credits, shortcuts, and where to find help")
            end
            if searchBox then searchBox:Hide() end
            f.currentModuleKey = nil
            SetSidebarState({ view = "welcome", activeModuleKey = CLEAR, activeCategoryIndex = CLEAR })
            if addon.DashboardPreview and addon.DashboardPreview.SetActiveModuleKey then
                addon.DashboardPreview.SetActiveModuleKey(nil)
            end
            if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
        end
    end

    return {
        RefreshDashboardTiles = RefreshDashboardTiles,
    }
end
