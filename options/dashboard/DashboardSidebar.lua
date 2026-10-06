--[[
    Horizon Suite - Dashboard sidebar chrome, scroll area, and sidebar button factories.
    Populate / collapse / state wiring remains in DashboardFrame.lua (same closure as navigation).
]]

local addon = _G.HorizonSuite
if not addon then return end

-- @param p table f, addon, dashAccentRefs, dashSession, DASHBOARD_CHILD_PANEL_ALPHA, MakeText, GetAccentColor, refreshDashboardClassIcon
-- @return table
function addon.DashboardSidebar_CreateChrome(p)
    local f = p.f
    local dashAccentRefs = p.dashAccentRefs
    local dashSession = p.dashSession
    local DASHBOARD_CHILD_PANEL_ALPHA = p.DASHBOARD_CHILD_PANEL_ALPHA
    local MakeText = p.MakeText
    local GetAccentColor = p.GetAccentColor
    local refreshDashboardClassIcon = p.refreshDashboardClassIcon

    -- ===== SIDEBAR =====
    -- The sidebar is always built at the native fixed size regardless of the dashboard
    -- resize ratio.  Dashboard_CommitResize also enforces this via DC.SIDEBAR_NATIVE_W.
    local DC = addon.DashboardConstants
    local SIDEBAR_WIDTH = DC and DC.SIDEBAR_NATIVE_W or 160
    local SIDEBAR_CONTENT_X_INSET = DC and DC.SIDEBAR_CONTENT_X_INSET or 15
    local CONTENT_OFFSET = SIDEBAR_WIDTH + 10

    local sidebar = CreateFrame("Frame", nil, f)
    sidebar:SetPoint("TOPLEFT", 0, 0)
    sidebar:SetPoint("BOTTOMLEFT", 0, 0)
    sidebar:SetWidth(SIDEBAR_WIDTH)
    sidebar:SetFrameLevel(f:GetFrameLevel() + 2)

    local sidebarBg = sidebar:CreateTexture(nil, "BACKGROUND")
    sidebarBg:SetAllPoints()
    sidebarBg:SetColorTexture(0.02, 0.02, 0.02, DASHBOARD_CHILD_PANEL_ALPHA)

    -- Sidebar divider line
    local sidebarDivider = sidebar:CreateTexture(nil, "BORDER")
    sidebarDivider:SetWidth(1)
    sidebarDivider:SetPoint("TOPRIGHT", 0, 0)
    sidebarDivider:SetPoint("BOTTOMRIGHT", 0, 0)
    local ar, ag, ab = GetAccentColor()
    sidebarDivider:SetColorTexture(ar, ag, ab, 0.4)
    dashAccentRefs.sidebarDivider = sidebarDivider

    -- Sidebar Logo
    local sidebarLogoSub = MakeText(sidebar, "HORIZON SUITE", 16, ar, ag, ab, "CENTER")
    sidebarLogoSub:SetPoint("TOP", 0, -18)
    dashAccentRefs.logoText = sidebarLogoSub

    -- Version from TOC (addon version)
    local addonName = addon.ADDON_NAME or "HorizonSuite"
    local getMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    local versionStr = addon.VERSION or (getMetadata and getMetadata(addonName, "Version")) or ""
    local sidebarVersion = MakeText(sidebar, versionStr ~= "" and ("v" .. versionStr) or "", 12, 0.55, 0.55, 0.65, "CENTER")
    sidebarVersion:SetPoint("TOP", sidebarLogoSub, "BOTTOM", 0, -4)

    -- Dev Mode indicator badge
    local devBadge = nil
    local isDevMode = addon.GetDB and addon.GetDB("focusDevMode", false)
    if isDevMode then
        devBadge = MakeText(sidebar, "[ DEV MODE ]", 10, 1, 0.65, 0.1, "CENTER")
        devBadge:SetPoint("TOP", sidebarVersion, "BOTTOM", 0, -2)
    end
    local lastSidebarHeader = devBadge or sidebarVersion

    local dashboardClassIcon = sidebar:CreateTexture(nil, "ARTWORK")
    dashboardClassIcon:SetSize(28, 28)
    dashboardClassIcon:SetPoint("TOP", lastSidebarHeader, "BOTTOM", 0, -6)
    dashboardClassIcon:Hide()
    dashAccentRefs.dashboardClassIcon = dashboardClassIcon

    -- Sidebar separator under logo / class icon (position from layoutUnderHeader)
    local logoSep = sidebar:CreateTexture(nil, "ARTWORK")
    logoSep:SetHeight(1)
    logoSep:SetColorTexture(ar, ag, ab, 0.3)
    dashAccentRefs.logoSep = logoSep

    -- Sidebar scroll area for buttons
    local sidebarScrollFrame = CreateFrame("ScrollFrame", nil, sidebar)
    local sidebarScrollContent = CreateFrame("Frame", nil, sidebarScrollFrame)
    sidebarScrollContent:SetWidth(SIDEBAR_WIDTH - 1)
    sidebarScrollContent:SetHeight(1)
    sidebarScrollFrame:SetScrollChild(sidebarScrollContent)
    sidebarScrollFrame:EnableMouseWheel(true)

    -- Custom scrollbar: 3px track parented to sidebar (not sidebarScrollFrame) so it
    -- sits on top of the divider at the sidebar's outer right edge without eating into
    -- button width.  Right edge aligns with sidebar.right; left edge is 3px inside.
    -- Frame level above sidebar buttons so the thumb renders on top.
    local sbTrack = CreateFrame("Frame", nil, sidebar)
    sbTrack:SetFrameLevel((sidebar:GetFrameLevel() or 0) + 8)
    sbTrack:SetWidth(12)
    sbTrack:SetPoint("TOPRIGHT",    sidebarScrollFrame, "TOPRIGHT",    5, 0)
    sbTrack:SetPoint("BOTTOMRIGHT", sidebarScrollFrame, "BOTTOMRIGHT", 5, 0)
    sbTrack:Hide()

    local sbThumb = sbTrack:CreateTexture(nil, "OVERLAY")
    sbThumb:SetWidth(3)
    sbThumb:SetColorTexture(1, 1, 1, 0.22)

    local sbSlider = CreateFrame("Slider", nil, sbTrack)
    sbSlider:SetAllPoints(sbTrack)
    sbSlider:SetOrientation("VERTICAL")
    sbSlider:SetMinMaxValues(0, 1)
    sbSlider:SetValueStep(1)
    sbSlider:SetObeyStepOnDrag(true)
    sbSlider:SetThumbTexture(sbThumb)
    sbSlider:SetFrameLevel((sbTrack:GetFrameLevel() or 0) + 2)

    local syncingSidebarSlider = false
    local function UpdateSidebarScrollbar()
        local frameH   = sidebarScrollFrame:GetHeight() or 1
        local contentH = sidebarScrollContent:GetHeight() or 1
        if frameH <= 0 then frameH = 1 end
        if contentH <= frameH then
            sbTrack:Hide()
            -- Reset scroll position so content snaps back to top when the frame
            -- grows large enough that scrolling is no longer needed.
            if (sidebarScrollFrame:GetVerticalScroll() or 0) > 0 then
                sidebarScrollFrame:SetVerticalScroll(0)
            end
            return
        end
        sbTrack:Show()
        local scroll    = math.min(sidebarScrollFrame:GetVerticalScroll() or 0, contentH - frameH)
        local maxScroll = math.max(1, contentH - frameH)
        local trackH    = sbTrack:GetHeight() or frameH
        syncingSidebarSlider = true
        sbSlider:SetMinMaxValues(0, maxScroll)
        sbSlider:SetValueStep(1)
        sbSlider:SetValue(scroll)
        syncingSidebarSlider = false
        local thumbPct  = frameH / contentH
        local thumbH    = math.max(20, trackH * thumbPct)
        sbThumb:SetHeight(thumbH)
    end

    sbSlider:SetScript("OnValueChanged", function(_, value)
        if syncingSidebarSlider then return end
        local maxS = math.max(0, sidebarScrollContent:GetHeight() - sidebarScrollFrame:GetHeight())
        sidebarScrollFrame:SetVerticalScroll(math.max(0, math.min(maxS, math.floor((value or 0) + 0.5))))
        UpdateSidebarScrollbar()
    end)

    sbSlider:SetScript("OnMouseWheel", function(_, delta)
        local cur = sidebarScrollFrame:GetVerticalScroll() or 0
        local maxS = math.max(0, sidebarScrollContent:GetHeight() - sidebarScrollFrame:GetHeight())
        sidebarScrollFrame:SetVerticalScroll(math.max(0, math.min(maxS, cur - delta * 30)))
        UpdateSidebarScrollbar()
    end)

    sidebarScrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local cur = self:GetVerticalScroll() or 0
        local maxS = math.max(0, sidebarScrollContent:GetHeight() - self:GetHeight())
        self:SetVerticalScroll(math.max(0, math.min(maxS, cur - delta * 30)))
        UpdateSidebarScrollbar()
    end)

    if sidebarScrollFrame:GetScript("OnScrollRangeChanged") then
        sidebarScrollFrame:HookScript("OnScrollRangeChanged", UpdateSidebarScrollbar)
    else
        sidebarScrollFrame:SetScript("OnScrollRangeChanged", UpdateSidebarScrollbar)
    end
    if sidebarScrollFrame:GetScript("OnVerticalScroll") then
        sidebarScrollFrame:HookScript("OnVerticalScroll", UpdateSidebarScrollbar)
    else
        sidebarScrollFrame:SetScript("OnVerticalScroll", UpdateSidebarScrollbar)
    end

    local TAB_ROW_HEIGHT = 38
    -- Reserve space at sidebar bottom for the pinned rows.
    -- Currently: Patch Notes (y=0), Integrations (y=1*TAB_ROW_HEIGHT), Search (y=2*TAB_ROW_HEIGHT).
    local SIDEBAR_WHATSNEW_RESERVE = TAB_ROW_HEIGHT * 3

    local function layoutUnderHeader()
        logoSep:ClearAllPoints()
        local icon = dashAccentRefs.dashboardClassIcon
        local anchorBelow = (icon and icon:IsShown()) and icon or lastSidebarHeader
        logoSep:SetPoint("TOP", anchorBelow, "BOTTOM", 0, -8)
        logoSep:SetPoint("LEFT", sidebar, "LEFT", SIDEBAR_CONTENT_X_INSET, 0)
        logoSep:SetPoint("RIGHT", sidebar, "RIGHT", -SIDEBAR_CONTENT_X_INSET, 0)
        sidebarScrollFrame:ClearAllPoints()
        -- Full sidebar width (logoSep is inset), so scrolling rows line up with the pinned rows
        -- and their selection fill stays inside the divider.
        sidebarScrollFrame:SetPoint("TOPLEFT", logoSep, "BOTTOMLEFT", -SIDEBAR_CONTENT_X_INSET, -10)
        sidebarScrollFrame:SetPoint("BOTTOMRIGHT", sidebar, "BOTTOMRIGHT", -1, 10 + SIDEBAR_WHATSNEW_RESERVE)
    end

    if refreshDashboardClassIcon then
        refreshDashboardClassIcon()
    end
    layoutUnderHeader()

    local sidebarButtons = {}

    -- Sidebar group collapse (reuse OptionsPanel state for consistency)
    local groupCollapsed = (_G[addon.DATABASE] and _G[addon.DATABASE].optionsSidebarGroupCollapsed) or {}
    local function GetGroupCollapsed(mk) return groupCollapsed[mk] ~= false end
    local function SetGroupCollapsed(mk, v)
        groupCollapsed[mk] = v
        local db = _G[addon.DATABASE]
        if db then db.optionsSidebarGroupCollapsed = groupCollapsed end
    end

    local function SetGroupChildrenShown(g, shown)
        if not g or not g.tabsContainer then return end
        for _, child in pairs({ g.tabsContainer:GetChildren() }) do
            -- A child flagged _subcatDisabled belongs to a mini-module that is turned off;
            -- it must stay hidden even when the parent group is expanded.
            if shown and child._subcatDisabled then
                child:Hide()
            else
                child:SetShown(shown)
            end
        end
    end

    -- Sidebar state controller: single source of truth for view, active selection, expanded groups.
    local sidebarState = {
        view = "dashboard",
        activeModuleKey = nil,
        activeCategoryIndex = nil,
    }
    local CLEAR = {}

    local HEADER_ROW_HEIGHT = 28
    local SIDEBAR_TOP_PAD = 4
    local COLLAPSE_ANIM_DUR = 0.18
    local easeOut = addon.easeOut or function(t) return 1 - (1 - t) * (1 - t) end

    -- Separator texture above the pinned bottom rows (anchored to sidebar)
    local pinnedSep = sidebar:CreateTexture(nil, "ARTWORK")
    pinnedSep:SetHeight(1)
    pinnedSep:SetColorTexture(0.15, 0.15, 0.2, 1)
    pinnedSep:SetPoint("BOTTOMLEFT", sidebar, "BOTTOMLEFT", 0, SIDEBAR_WHATSNEW_RESERVE)
    pinnedSep:SetPoint("BOTTOMRIGHT", sidebar, "BOTTOMRIGHT", -1, SIDEBAR_WHATSNEW_RESERVE)

    -- iconSpec: string = Interface\Icons\<name> (a string holding a backslash is a full path,
    -- used as-is, like the Echo icon), or { atlas = "AtlasName", useAtlasSize = bool?, fallback = "IconFileName" } for SetAtlas
    local function ApplySidebarButtonIconTexture(tex, iconSpec)
        if type(iconSpec) == "table" and iconSpec.atlas and tex.SetAtlas then
            local atlas = iconSpec.atlas
            local gi = C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas)
            if C_Texture and C_Texture.GetAtlasInfo and not gi and type(iconSpec.fallback) == "string" then
                tex:SetAtlas(nil)
                tex:SetTexture("Interface\\Icons\\" .. iconSpec.fallback)
            else
                tex:SetTexture(nil)
                pcall(function()
                    tex:SetAtlas(atlas, iconSpec.useAtlasSize)
                end)
            end
        elseif type(iconSpec) == "string" then
            if tex.SetAtlas then tex:SetAtlas(nil) end
            if iconSpec:find("\\", 1, true) then
                tex:SetTexture(iconSpec)
            else
                tex:SetTexture("Interface\\Icons\\" .. iconSpec)
            end
        end
    end

    -- Motion for the sidebar: hover fills fade, the selection pill slides between rows, group
    -- page lists ease open and shut, and the chevrons turn. All of it runs on the shared
    -- OptionsWidgets tween runner; a hidden sidebar jumps every tween to its end.
    local StartTween = addon.OptionsWidgets_StartTween
    local StopTween = addon.OptionsWidgets_StopTween
    local Lerp = addon.OptionsWidgets_Lerp or function(a, b, t) return a + (b - a) * t end
    local HOVER_DUR = (addon.OptionsWidgetsDef and addon.OptionsWidgetsDef.MotionFast) or 0.12
    local SLIDE_DUR = 0.2
    local function Tween(frame, dur, onStep, onFinish)
        if StartTween then
            StartTween(frame, dur, onStep, onFinish)
        else
            onStep(1)
            if onFinish then onFinish() end
        end
    end

    -- The accent colour as the widgets currently use it (class colour when the theme is on).
    local function AccentRGB()
        local c = addon.OptionsWidgetsDef and addon.OptionsWidgetsDef.AccentColor
        if c then return c[1], c[2], c[3] end
        return GetAccentColor()
    end

    -- Selection and hover fill for a sidebar row: a rounded rect with a margin at each side (the
    -- OptionsWidgets rounded paint, flat when Echo.Round is missing). SetColorTexture(r, g, b, a)
    -- paints at once, as a texture would; FadeTo(r, g, b, a) eases there from what is on screen.
    -- The host sits one level under the button so the button's icon and label draw over it.
    local SIDEBAR_HOVER_FILL = { 1, 1, 1, 0.05 }
    local function MakeSelectionFill(btn, radius)
        local host = CreateFrame("Frame", nil, btn)
        host:SetPoint("TOPLEFT", btn, "TOPLEFT", 6, -1)
        host:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -6, 1)
        host:SetFrameLevel(math.max(0, btn:GetFrameLevel() - 1))
        local paint = addon.OptionsWidgets_PaintRounded(host, radius or 8, "BACKGROUND")
        local cur = { 0, 0, 0, 0 }
        local function set(r, g, b, a)
            cur[1], cur[2], cur[3], cur[4] = r, g, b, a
            paint(r, g, b, a)
        end
        set(0, 0, 0, 0)
        local fill = { host = host }
        function fill:SetColorTexture(r, g, b, a)
            if StopTween then StopTween(host) end
            set(r, g, b, a or 1)
        end
        function fill:FadeTo(r, g, b, a)
            a = a or 1
            local fr, fg, fb, fa = cur[1], cur[2], cur[3], cur[4]
            -- Fading in from clear or out to clear moves only the opacity, never the hue.
            if fa == 0 then fr, fg, fb = r, g, b end
            if a == 0 then r, g, b = fr, fg, fb end
            Tween(host, HOVER_DUR, function(e)
                set(Lerp(fr, r, e), Lerp(fg, g, e), Lerp(fb, b, e), Lerp(fa, a, e))
            end)
        end
        return fill
    end

    -- Unselected sidebar text and icons: the muted token, no box.
    local MUTED_R, MUTED_G, MUTED_B = 0.65, 0.65, 0.7
    do
        local c = addon.OptionsWidgetsDef and addon.OptionsWidgetsDef.TextColorMuted
        if c then MUTED_R, MUTED_G, MUTED_B = c[1], c[2], c[3] end
    end
    local HOVER_R, HOVER_G, HOVER_B = 0.9, 0.9, 0.95
    -- A module header while you are on one of its pages: a step brighter than idle.
    local CURRENT_R, CURRENT_G, CURRENT_B = 0.85, 0.85, 0.9

    -- Colour a row's label, icon and chevron together.
    local function TintRow(btn, r, g, b)
        if btn.label then btn.label:SetTextColor(r, g, b, 1) end
        if btn.icon then btn.icon:SetVertexColor(r, g, b, 1) end
        if btn.chevron then btn.chevron:SetTextColor(r, g, b, 1) end
    end

    -- A row's colours at rest: the module header you are inside is a step brighter.
    local function RestTint(btn)
        if btn._current then return CURRENT_R, CURRENT_G, CURRENT_B end
        return MUTED_R, MUTED_G, MUTED_B
    end

    -- Hover in and out for a row that is not the selected one.
    local function RowHover(btn, over)
        if btn == dashSession.activeSidebarBtn then return end
        if over then
            btn.btnBg:FadeTo(SIDEBAR_HOVER_FILL[1], SIDEBAR_HOVER_FILL[2], SIDEBAR_HOVER_FILL[3], SIDEBAR_HOVER_FILL[4])
        else
            btn.btnBg:FadeTo(0, 0, 0, 0)
        end
        if btn._patchNotesSidebarRowStyle and addon.PatchNotes_ApplyWhatsNewSidebarRowStyle then
            addon.PatchNotes_ApplyWhatsNewSidebarRowStyle(btn, btn.label, btn.icon, over)
        elseif over then
            TintRow(btn, HOVER_R, HOVER_G, HOVER_B)
        else
            TintRow(btn, RestTint(btn))
        end
    end

    -- Badges: a small rounded tag at the right of a row. kind "accent" (New) tints with the
    -- accent; "muted" (Off) is neutral. text nil removes it. A button's label stops short of it.
    local badges = {}
    local function PaintBadge(bd)
        -- Width follows the text, which a dashboard font change can resize.
        bd:SetWidth(math.ceil((bd.text:GetStringWidth() or 20) + 12))
        if bd.kind == "muted" then
            bd.paint(1, 1, 1, 0.08)
            bd.text:SetTextColor(MUTED_R, MUTED_G, MUTED_B, 1)
        else
            local r, g, b = AccentRGB()
            bd.paint(r, g, b, 0.24)
            bd.text:SetTextColor(r + (1 - r) * 0.55, g + (1 - g) * 0.55, b + (1 - b) * 0.55, 1)
        end
    end
    local function SetRowBadge(btn, text, kind)
        if not btn then return end
        local bd = btn.badge
        local lbl = btn.label
        if not text or text == "" then
            if bd then bd:Hide() end
            if lbl and btn._labelRightInset then lbl:SetPoint("RIGHT", btn, "RIGHT", btn._labelRightInset, 0) end
            return
        end
        if not bd then
            bd = CreateFrame("Frame", nil, btn)
            bd:SetHeight(15)
            bd:SetPoint("RIGHT", btn, "RIGHT", -14, 0)
            bd.paint = addon.OptionsWidgets_PaintRounded(bd, 7, "BACKGROUND")
            bd.text = MakeText(bd, "", 9, 1, 1, 1, "CENTER")
            bd.text:SetPoint("CENTER", bd, "CENTER", 0, 0)
            btn.badge = bd
            badges[#badges + 1] = bd
        end
        bd.kind = kind or "accent"
        bd.text:SetText(text)
        PaintBadge(bd)
        bd:Show()
        if lbl and btn._labelRightInset then lbl:SetPoint("RIGHT", bd, "LEFT", -4, 0) end
    end
    addon.DashboardSidebar_SetRowBadge = SetRowBadge

    local function CreateSidebarButton(parent, label, iconName, onClick, indentPx, noHover)
        indentPx = indentPx or 0
        parent = parent or sidebarScrollContent
        local btn = CreateFrame("Button", nil, parent)
        btn:SetSize(SIDEBAR_WIDTH - 1, TAB_ROW_HEIGHT)

        local btnBg = MakeSelectionFill(btn, indentPx > 0 and 6 or 8)
        btn.btnBg = btnBg

        if iconName then
            local ic = btn:CreateTexture(nil, "ARTWORK")
            ic:SetSize(16, 16)
            ic:SetPoint("LEFT", indentPx + 14, 0)
            ApplySidebarButtonIconTexture(ic, iconName)
            ic:SetVertexColor(MUTED_R, MUTED_G, MUTED_B, 1)
            btn.icon = ic
        end

        local lbl = MakeText(btn, label, 11, MUTED_R, MUTED_G, MUTED_B, "LEFT")
        lbl:SetPoint("LEFT", indentPx + (iconName and 36 or 14), 0)
        lbl:SetPoint("RIGHT", -8, 0)
        lbl:SetWordWrap(false)
        btn.label = lbl
        btn._labelRightInset = -8

        if not noHover then
            btn:SetScript("OnEnter", function() RowHover(btn, true) end)
            btn:SetScript("OnLeave", function() RowHover(btn, false) end)
        end
        btn:SetScript("OnClick", function()
            if onClick then onClick() end
        end)

        return btn
    end

    --- @param yFromBottom number|nil Pixels up from sidebar bottom (stack rows: Patch Notes 0, row above TAB_ROW_HEIGHT).
    local function CreateBottomPinnedButton(label, iconName, onClick, yFromBottom)
        yFromBottom = yFromBottom or 0
        local btn = CreateFrame("Button", nil, sidebar)
        btn:SetSize(SIDEBAR_WIDTH - 1, TAB_ROW_HEIGHT)
        btn:SetPoint("BOTTOMLEFT", sidebar, "BOTTOMLEFT", 0, yFromBottom)
        btn:SetPoint("BOTTOMRIGHT", sidebar, "BOTTOMRIGHT", -1, yFromBottom)
        -- Pinned rows sit outside the scroll area, so they keep their own fill and accent bar
        -- for selection instead of the sliding pill.
        btn._pinned = true

        local btnBg = MakeSelectionFill(btn, 8)
        btn.btnBg = btnBg
        local selBar = btnBg.host:CreateTexture(nil, "ARTWORK")
        selBar:SetWidth(3)
        selBar:SetPoint("TOPLEFT", btnBg.host, "TOPLEFT", 2, -9)
        selBar:SetPoint("BOTTOMLEFT", btnBg.host, "BOTTOMLEFT", 2, 9)
        selBar:Hide()
        btn.selBar = selBar

        if iconName then
            local ic = btn:CreateTexture(nil, "ARTWORK")
            ic:SetSize(16, 16)
            ic:SetPoint("LEFT", 14, 0)
            ApplySidebarButtonIconTexture(ic, iconName)
            ic:SetVertexColor(MUTED_R, MUTED_G, MUTED_B, 1)
            btn.icon = ic
        end

        local lbl = MakeText(btn, label, 11, MUTED_R, MUTED_G, MUTED_B, "LEFT")
        lbl:SetPoint("LEFT", iconName and 36 or 14, 0)
        lbl:SetPoint("RIGHT", -8, 0)
        lbl:SetWordWrap(false)
        btn.label = lbl
        btn._labelRightInset = -8

        btn:SetScript("OnEnter", function() RowHover(btn, true) end)
        btn:SetScript("OnLeave", function() RowHover(btn, false) end)
        btn:SetScript("OnClick", function()
            if onClick then onClick() end
        end)

        return btn
    end

    -- One selection pill for every scrolling row (Welcome, News, module headers and pages). It
    -- slides from the row it was on to the new one, growing or shrinking to the new row's height.
    -- It sits at the scroll content's own level, under every row, so labels draw over it.
    local selPill = CreateFrame("Frame", nil, sidebarScrollContent)
    selPill:SetFrameLevel(sidebarScrollContent:GetFrameLevel())
    local paintPill = addon.OptionsWidgets_PaintRounded(selPill, 8, "BACKGROUND")
    local pillBar = selPill:CreateTexture(nil, "ARTWORK")
    pillBar:SetWidth(3)
    pillBar:SetPoint("TOPLEFT", selPill, "TOPLEFT", 2, -9)
    pillBar:SetPoint("BOTTOMLEFT", selPill, "BOTTOMLEFT", 2, 9)
    selPill:Hide()
    local pillTarget, pillSliding

    local function PaintSelection()
        local sel = addon.OptionsWidgetsDef.SidebarSelectedBg
        paintPill(sel[1], sel[2], sel[3], sel[4])
        local r, g, b = AccentRGB()
        pillBar:SetColorTexture(r, g, b, 1)
        local active = dashSession.activeSidebarBtn
        if active and active._pinned then
            active.btnBg:SetColorTexture(sel[1], sel[2], sel[3], sel[4])
            active.selBar:SetColorTexture(r, g, b, 1)
        end
        for _, bd in ipairs(badges) do PaintBadge(bd) end
    end
    -- Called when the class theme changes the accent.
    dashSession.RefreshSidebarSelection = PaintSelection

    -- dy shifts the pill up (positive) from its resting place on btn. With no dy it rests on the
    -- row, anchored top and bottom, so it follows the row if the row's height changes later.
    local function PlacePill(btn, dy, h)
        selPill:ClearAllPoints()
        if not dy then
            selPill:SetPoint("TOPLEFT", btn, "TOPLEFT", 6, -1)
            selPill:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -6, 1)
            return
        end
        selPill:SetPoint("TOPLEFT", btn, "TOPLEFT", 6, -1 + dy)
        selPill:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -6, -1 + dy)
        selPill:SetHeight(math.max(1, h))
    end

    local function MovePill(btn)
        local h = (btn:GetHeight() or 0) - 2
        if pillTarget == btn and selPill:IsShown() then
            if not pillSliding then
                PlacePill(btn)
                selPill:SetAlpha(1)
            end
            return
        end
        local wasShown = selPill:IsShown() and (selPill:GetAlpha() or 0) > 0
        local fromTop, toTop = selPill:GetTop(), btn:GetTop()
        local fromH, fromA = selPill:GetHeight() or h, selPill:GetAlpha() or 0
        pillTarget = btn
        selPill:Show()
        if wasShown and fromTop and toTop then
            -- Slide: start where the pill is on screen, ease to rest on the new row.
            local dy0 = fromTop - (toTop - 1)
            pillSliding = true
            Tween(selPill, SLIDE_DUR, function(e)
                PlacePill(btn, Lerp(dy0, 0, e), Lerp(fromH, h, e))
                selPill:SetAlpha(Lerp(fromA, 1, e))
            end, function()
                pillSliding = nil
                PlacePill(btn)
            end)
        else
            -- Nothing selected in the scroll area before: fade in on the row.
            PlacePill(btn)
            selPill:SetAlpha(0)
            pillSliding = nil
            Tween(selPill, HOVER_DUR, function(e) selPill:SetAlpha(e) end)
        end
    end

    local function HidePill()
        pillTarget, pillSliding = nil, nil
        if not selPill:IsShown() then return end
        local a0 = selPill:GetAlpha() or 1
        Tween(selPill, HOVER_DUR, function(e) selPill:SetAlpha(Lerp(a0, 0, e)) end, function() selPill:Hide() end)
    end

    local function SetActiveSidebarButton(btn)
        local prev = dashSession.activeSidebarBtn
        if prev and prev ~= btn then
            if prev._pinned then
                prev.btnBg:FadeTo(0, 0, 0, 0)
                prev.selBar:Hide()
            else
                prev.btnBg:SetColorTexture(0, 0, 0, 0)
            end
            if prev._patchNotesSidebarRowStyle and addon.PatchNotes_ApplyWhatsNewSidebarRowStyle then
                addon.PatchNotes_ApplyWhatsNewSidebarRowStyle(prev, prev.label, prev.icon, false)
            else
                TintRow(prev, RestTint(prev))
            end
        end
        dashSession.activeSidebarBtn = btn
        if not btn then
            HidePill()
            return
        end
        -- Selected: a rounded accent fill (SidebarSelectedBg, the accent at about 16%) with a
        -- thin accent bar at its left edge, and white text.
        local sel = addon.OptionsWidgetsDef.SidebarSelectedBg
        if btn._pinned then
            HidePill()
            if prev ~= btn then btn.btnBg:FadeTo(sel[1], sel[2], sel[3], sel[4]) end
            local r, g, b = AccentRGB()
            btn.selBar:SetColorTexture(r, g, b, 1)
            btn.selBar:Show()
        else
            btn.btnBg:SetColorTexture(0, 0, 0, 0)
            local r, g, b = AccentRGB()
            paintPill(sel[1], sel[2], sel[3], sel[4])
            pillBar:SetColorTexture(r, g, b, 1)
            MovePill(btn)
        end
        if btn._patchNotesSidebarRowStyle and addon.PatchNotes_ApplyWhatsNewSidebarRowStyle then
            addon.PatchNotes_ApplyWhatsNewSidebarRowStyle(btn, btn.label, btn.icon, false)
        else
            TintRow(btn, 1, 1, 1)
        end
    end

    -- A drawn chevron (two short lines) that turns from pointing right (closed) to pointing down
    -- (open). It answers SetText("+" closed, "-" open) and SetTextColor like the text glyph it
    -- replaces, so the callers need no change. Falls back to that glyph where lines are missing.
    local function CreateChevron(parent)
        local ch = CreateFrame("Frame", nil, parent)
        if not ch.CreateLine then
            ch:Hide()
            local fs = MakeText(parent, "+", 11, MUTED_R, MUTED_G, MUTED_B, "CENTER")
            return fs
        end
        ch:SetSize(10, 10)
        local l1, l2 = ch:CreateLine(nil, "OVERLAY"), ch:CreateLine(nil, "OVERLAY")
        l1:SetThickness(1.5)
        l2:SetThickness(1.5)
        local s = 2.25      -- half the chevron's depth; its arms are 2s long each way
        local turn = 0      -- 0 points right, 1 points down
        local function draw(t)
            turn = t
            local a = t * math.pi / 2
            local c, si = math.cos(a), math.sin(a)
            -- ">" around the centre (tip (s, 0), ends (-s, +-2s)), turned clockwise by a.
            local function pt(x, y) return x * c + y * si, -x * si + y * c end
            local tx, ty = pt(s, 0)
            local ax, ay = pt(-s, 2 * s)
            local bx, by = pt(-s, -2 * s)
            l1:SetStartPoint("CENTER", ch, ax, ay)
            l1:SetEndPoint("CENTER", ch, tx, ty)
            l2:SetStartPoint("CENTER", ch, bx, by)
            l2:SetEndPoint("CENTER", ch, tx, ty)
        end
        local open
        function ch:SetText(txt)
            local want = (txt == "-")
            if want == open then return end
            local first = (open == nil)
            open = want
            local from, to = turn, want and 1 or 0
            if first then draw(to) return end
            Tween(ch, SLIDE_DUR, function(e) draw(Lerp(from, to, e)) end)
        end
        function ch:SetTextColor(r, g, b, a)
            l1:SetColorTexture(r, g, b, a or 1)
            l2:SetColorTexture(r, g, b, a or 1)
        end
        ch:SetTextColor(MUTED_R, MUTED_G, MUTED_B, 1)
        draw(0)
        return ch
    end

    -- Open or close a group's page list by easing its height and fading it, reflowing the
    -- sidebar each frame through relayout. Also stores the state and turns the chevron. A module
    -- that is turned off always stays closed.
    -- noStore leaves the saved open/closed state alone (closing a module that was turned off).
    local function AnimateGroup(g, expand, relayout, noStore)
        local tc = g and g.tabsContainer
        if not tc then return end
        local header = g.header
        if header and header._moduleOff then expand = false end
        if header and header.groupKey and not noStore then SetGroupCollapsed(header.groupKey, not expand) end
        if header and header.chevron then header.chevron:SetText(expand and "-" or "+") end
        local target = expand and (g.fullHeight or 0) or 0
        local from = tc:GetHeight() or 0
        if expand then SetGroupChildrenShown(g, true) end
        local function step(e)
            local h = Lerp(from, target, e)
            tc:SetHeight(h)
            local full = g.fullHeight or 0
            tc:SetAlpha(full > 0 and math.min(1, h / full) or 1)
            if header and header.updateSpacer then header.updateSpacer() end
            if relayout then relayout() end
        end
        local function done()
            tc:SetAlpha(1)
            if not expand then SetGroupChildrenShown(g, false) end
        end
        if math.abs(from - target) < 0.5 then
            if StopTween then StopTween(tc) end
            step(1)
            done()
            return
        end
        Tween(tc, COLLAPSE_ANIM_DUR, step, done)
    end

    -- A module header's icon, left of its label, in the row icon style.
    local function AddRowIcon(btn, iconSpec)
        if not iconSpec then return end
        local ic = btn:CreateTexture(nil, "ARTWORK")
        ic:SetSize(16, 16)
        ic:SetPoint("LEFT", btn, "LEFT", 14, 0)
        ApplySidebarButtonIconTexture(ic, iconSpec)
        ic:SetVertexColor(MUTED_R, MUTED_G, MUTED_B, 1)
        btn.icon = ic
        return ic
    end

    -- Show a module header as turned off (dimmed, "Off" tag, no chevron) or as normal.
    local function SetModuleOff(header, off)
        header._moduleOff = off and true or nil
        header:SetAlpha(off and 0.55 or 1)
        if header.chevron then header.chevron:SetShown(not off) end
        SetRowBadge(header, off and (addon.L and addon.L["DASH_SIDEBAR_OFF_BADGE"] or "Off") or nil, "muted")
    end

    -- ===== END SIDEBAR (chrome) =====
    return {
        CONTENT_OFFSET = CONTENT_OFFSET,
        SIDEBAR_CONTENT_X_INSET = SIDEBAR_CONTENT_X_INSET,
        SIDEBAR_WIDTH = SIDEBAR_WIDTH,
        sidebar = sidebar,
        sidebarScrollFrame = sidebarScrollFrame,
        sidebarScrollContent = sidebarScrollContent,
        sidebarButtons = sidebarButtons,
        GetGroupCollapsed = GetGroupCollapsed,
        SetGroupCollapsed = SetGroupCollapsed,
        SetGroupChildrenShown = SetGroupChildrenShown,
        sidebarState = sidebarState,
        CLEAR = CLEAR,
        HEADER_ROW_HEIGHT = HEADER_ROW_HEIGHT,
        SIDEBAR_TOP_PAD = SIDEBAR_TOP_PAD,
        COLLAPSE_ANIM_DUR = COLLAPSE_ANIM_DUR,
        easeOut = easeOut,
        TAB_ROW_HEIGHT = TAB_ROW_HEIGHT,
        SIDEBAR_WHATSNEW_RESERVE = SIDEBAR_WHATSNEW_RESERVE,
        CreateSidebarButton = CreateSidebarButton,
        MakeSelectionFill = MakeSelectionFill,
        sidebarMuted = { MUTED_R, MUTED_G, MUTED_B },
        CreateBottomPinnedButton = CreateBottomPinnedButton,
        SetActiveSidebarButton = SetActiveSidebarButton,
        TintRow = TintRow,
        RestTint = RestTint,
        RowHover = RowHover,
        CreateChevron = CreateChevron,
        AnimateGroup = AnimateGroup,
        AddRowIcon = AddRowIcon,
        SetModuleOff = SetModuleOff,
        SetRowBadge = SetRowBadge,
        layoutUnderHeader = layoutUnderHeader,
    }
end
