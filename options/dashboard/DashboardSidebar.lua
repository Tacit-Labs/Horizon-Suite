--[[
    Horizon Suite - Dashboard sidebar chrome, scroll area, and sidebar button factories.
    Populate / collapse / state wiring remains in DashboardFrame.lua (same closure as navigation).
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

--- @param p table f, addon, dashAccentRefs, dashSession, DASHBOARD_CHILD_PANEL_ALPHA, MakeText, GetAccentColor, refreshDashboardClassIcon
--- @return table
function addon.DashboardSidebar_CreateChrome(p)
    local f = p.f
    local dashAccentRefs = p.dashAccentRefs
    local dashSession = p.dashSession
    local DASHBOARD_CHILD_PANEL_ALPHA = p.DASHBOARD_CHILD_PANEL_ALPHA
    local MakeText = p.MakeText
    local GetAccentColor = p.GetAccentColor
    local refreshDashboardClassIcon = p.refreshDashboardClassIcon

    -- ===== SIDEBAR =====
    local SIDEBAR_WIDTH = 160
    local SIDEBAR_CONTENT_X_INSET = 15 -- logo separator + scroll list; bottom Patch Notes row uses same X as Welcome/Home
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
    sidebarScrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local cur = self:GetVerticalScroll() or 0
        local maxS = math.max(0, sidebarScrollContent:GetHeight() - self:GetHeight())
        self:SetVerticalScroll(math.max(0, math.min(maxS, cur - delta * 30)))
    end)

    local TAB_ROW_HEIGHT = 38
    -- Space for pinned bottom rows (Search + Patch Notes).
    local SIDEBAR_WHATSNEW_RESERVE = TAB_ROW_HEIGHT * 2

    local function layoutUnderHeader()
        logoSep:ClearAllPoints()
        local icon = dashAccentRefs.dashboardClassIcon
        local anchorBelow = (icon and icon:IsShown()) and icon or lastSidebarHeader
        logoSep:SetPoint("TOP", anchorBelow, "BOTTOM", 0, -8)
        logoSep:SetPoint("LEFT", sidebar, "LEFT", SIDEBAR_CONTENT_X_INSET, 0)
        logoSep:SetPoint("RIGHT", sidebar, "RIGHT", -SIDEBAR_CONTENT_X_INSET, 0)
        sidebarScrollFrame:ClearAllPoints()
        sidebarScrollFrame:SetPoint("TOPLEFT", logoSep, "BOTTOMLEFT", 0, -10)
        sidebarScrollFrame:SetPoint("BOTTOMRIGHT", sidebar, "BOTTOMRIGHT", -1, 10 + SIDEBAR_WHATSNEW_RESERVE)
    end

    if refreshDashboardClassIcon then
        refreshDashboardClassIcon()
    end
    layoutUnderHeader()

    local sidebarButtons = {}

    -- Sidebar group collapse (reuse OptionsPanel state for consistency)
    local groupCollapsed = (_G[addon.DB_NAME] and _G[addon.DB_NAME].optionsSidebarGroupCollapsed) or {}
    local function GetGroupCollapsed(mk) return groupCollapsed[mk] ~= false end
    local function SetGroupCollapsed(mk, v)
        groupCollapsed[mk] = v
        local db = _G[addon.DB_NAME]
        if db then db.optionsSidebarGroupCollapsed = groupCollapsed end
    end

    local function SetGroupChildrenShown(g, shown)
        if not g or not g.tabsContainer then return end
        for _, child in pairs({ g.tabsContainer:GetChildren() }) do
            child:SetShown(shown)
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

    -- iconSpec: string = Interface\Icons\<name>, or { atlas = "AtlasName", useAtlasSize = bool?, fallback = "IconFileName" } for SetAtlas
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
            tex:SetTexture("Interface\\Icons\\" .. iconSpec)
        end
    end

    local function CreateSidebarButton(parent, label, iconName, onClick, indentPx, noHover)
        indentPx = indentPx or 0
        parent = parent or sidebarScrollContent
        local btn = CreateFrame("Button", nil, parent)
        btn:SetSize(SIDEBAR_WIDTH - 1, TAB_ROW_HEIGHT)

        local btnBg = btn:CreateTexture(nil, "BACKGROUND")
        btnBg:SetAllPoints()
        btnBg:SetColorTexture(0, 0, 0, 0)
        btn.btnBg = btnBg

        local accentBar = btn:CreateTexture(nil, "ARTWORK")
        accentBar:SetSize(3, 22)
        accentBar:SetPoint("LEFT", 4 + indentPx, 0)
        local sar, sag, sab = GetAccentColor()
        accentBar:SetColorTexture(sar, sag, sab, 1)
        accentBar:Hide()
        btn.accentBar = accentBar
        tinsert(dashAccentRefs.sidebarBars, accentBar)

        if iconName then
            local ic = btn:CreateTexture(nil, "ARTWORK")
            ic:SetSize(16, 16)
            ic:SetPoint("LEFT", indentPx + 14, 0)
            ApplySidebarButtonIconTexture(ic, iconName)
            ic:SetVertexColor(0.6, 0.6, 0.65, 1)
            btn.icon = ic
        end

        local lbl = MakeText(btn, label, 11, 0.65, 0.65, 0.7, "LEFT")
        lbl:SetPoint("LEFT", indentPx + (iconName and 36 or 14), 0)
        lbl:SetPoint("RIGHT", -8, 0)
        lbl:SetWordWrap(false)
        btn.label = lbl

        if not noHover then
            btn:SetScript("OnEnter", function()
                if btn ~= dashSession.activeSidebarBtn then
                    btnBg:SetColorTexture(0.1, 0.1, 0.12, DASHBOARD_CHILD_PANEL_ALPHA)
                    if btn._patchNotesSidebarRowStyle and addon.PatchNotes_ApplyWhatsNewSidebarRowStyle then
                        addon.PatchNotes_ApplyWhatsNewSidebarRowStyle(btn, lbl, btn.icon, true)
                    else
                        lbl:SetTextColor(0.9, 0.9, 0.95)
                        if btn.icon then btn.icon:SetVertexColor(0.9, 0.9, 0.95, 1) end
                    end
                end
            end)
            btn:SetScript("OnLeave", function()
                if btn ~= dashSession.activeSidebarBtn then
                    btnBg:SetColorTexture(0, 0, 0, 0)
                    if btn._patchNotesSidebarRowStyle and addon.PatchNotes_ApplyWhatsNewSidebarRowStyle then
                        addon.PatchNotes_ApplyWhatsNewSidebarRowStyle(btn, lbl, btn.icon, false)
                    else
                        lbl:SetTextColor(0.65, 0.65, 0.7)
                        if btn.icon then btn.icon:SetVertexColor(0.6, 0.6, 0.65, 1) end
                    end
                end
            end)
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

        local btnBg = btn:CreateTexture(nil, "BACKGROUND")
        btnBg:SetAllPoints()
        btnBg:SetColorTexture(0, 0, 0, 0)
        btn.btnBg = btnBg

        local accentBar = btn:CreateTexture(nil, "ARTWORK")
        accentBar:SetSize(3, 22)
        accentBar:SetPoint("LEFT", 4, 0)
        local sar, sag, sab = GetAccentColor()
        accentBar:SetColorTexture(sar, sag, sab, 1)
        accentBar:Hide()
        btn.accentBar = accentBar
        tinsert(dashAccentRefs.sidebarBars, accentBar)

        if iconName then
            local ic = btn:CreateTexture(nil, "ARTWORK")
            ic:SetSize(16, 16)
            ic:SetPoint("LEFT", 14, 0)
            ApplySidebarButtonIconTexture(ic, iconName)
            ic:SetVertexColor(0.6, 0.6, 0.65, 1)
            btn.icon = ic
        end

        local lbl = MakeText(btn, label, 11, 0.65, 0.65, 0.7, "LEFT")
        lbl:SetPoint("LEFT", iconName and 36 or 14, 0)
        lbl:SetPoint("RIGHT", -8, 0)
        lbl:SetWordWrap(false)
        btn.label = lbl

        btn:SetScript("OnEnter", function()
            if btn ~= dashSession.activeSidebarBtn then
                btnBg:SetColorTexture(0.1, 0.1, 0.12, DASHBOARD_CHILD_PANEL_ALPHA)
                if btn._patchNotesSidebarRowStyle and addon.PatchNotes_ApplyWhatsNewSidebarRowStyle then
                    addon.PatchNotes_ApplyWhatsNewSidebarRowStyle(btn, lbl, btn.icon, true)
                else
                    lbl:SetTextColor(0.9, 0.9, 0.95)
                    if btn.icon then btn.icon:SetVertexColor(0.9, 0.9, 0.95, 1) end
                end
            end
        end)
        btn:SetScript("OnLeave", function()
            if btn ~= dashSession.activeSidebarBtn then
                btnBg:SetColorTexture(0, 0, 0, 0)
                if btn._patchNotesSidebarRowStyle and addon.PatchNotes_ApplyWhatsNewSidebarRowStyle then
                    addon.PatchNotes_ApplyWhatsNewSidebarRowStyle(btn, lbl, btn.icon, false)
                else
                    lbl:SetTextColor(0.65, 0.65, 0.7)
                    if btn.icon then btn.icon:SetVertexColor(0.6, 0.6, 0.65, 1) end
                end
            end
        end)
        btn:SetScript("OnClick", function()
            if onClick then onClick() end
        end)

        return btn
    end

    local function SetActiveSidebarButton(btn)
        if dashSession.activeSidebarBtn then
            local prev = dashSession.activeSidebarBtn
            prev.btnBg:SetColorTexture(0, 0, 0, 0)
            if prev._patchNotesSidebarRowStyle and addon.PatchNotes_ApplyWhatsNewSidebarRowStyle then
                addon.PatchNotes_ApplyWhatsNewSidebarRowStyle(prev, prev.label, prev.icon, false)
            elseif prev.chevron then
                prev.label:SetTextColor(0.55, 0.55, 0.65, 1)
                prev.chevron:SetTextColor(0.55, 0.55, 0.65, 1)
            else
                prev.label:SetTextColor(0.65, 0.65, 0.7)
                if prev.icon then prev.icon:SetVertexColor(0.6, 0.6, 0.65, 1) end
            end
            prev.accentBar:Hide()
        end
        dashSession.activeSidebarBtn = btn
        if btn then
            local bar, bag, bab = GetAccentColor()
            btn.btnBg:SetColorTexture(bar * 0.15, bag * 0.15, bab * 0.15, DASHBOARD_CHILD_PANEL_ALPHA)
            if btn._patchNotesSidebarRowStyle and addon.PatchNotes_ApplyWhatsNewSidebarRowStyle then
                addon.PatchNotes_ApplyWhatsNewSidebarRowStyle(btn, btn.label, btn.icon, false)
            else
                btn.label:SetTextColor(1, 1, 1)
                if btn.icon then btn.icon:SetVertexColor(1, 1, 1, 1) end
                if btn.chevron then
                    btn.chevron:SetTextColor(1, 1, 1, 1)
                end
            end
            btn.accentBar:Show()
        end
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
        CreateBottomPinnedButton = CreateBottomPinnedButton,
        SetActiveSidebarButton = SetActiveSidebarButton,
        layoutUnderHeader = layoutUnderHeader,
    }
end
