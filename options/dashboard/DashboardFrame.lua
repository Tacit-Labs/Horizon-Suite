--[[
    Horizon Suite - Dashboard main frame construction (lazy init body).
    Orchestrates: Util (smooth scroll), Sidebar chrome, DetailView (options accordion + search results),
    HomeWelcome (tiles + welcome), patch notes + search shell here; see options/dashboard/Navigation.lua.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = addon.L
local DC = addon.DashboardConstants
if not DC then return end

-- Local aliases for readability (match former DASH_* names)
local DASHBOARD_FRAME_W = DC.FRAME_W
local DASHBOARD_FRAME_H = DC.FRAME_H
local DASHBOARD_VIEW_H = DC.VIEW_H
local DASH_HEAD_TITLE_Y = DC.HEAD_TITLE_Y
local DASH_HEAD_SUBTITLE_Y = DC.HEAD_SUBTITLE_Y
local DASH_SEARCH_Y = DC.SEARCH_Y
local DASH_SEARCH_BOX_H = DC.SEARCH_BOX_H
local DASH_SEARCH_SHELL_EXTRA_H = DC.SEARCH_SHELL_EXTRA_H or 6
local DASH_SEARCH_BAR_TOP_NUDGE = DC.SEARCH_BAR_TOP_NUDGE or 3
local DASH_SCROLL_GAP_BELOW_SEARCH = DC.SCROLL_GAP_BELOW_SEARCH or 16
local DASH_SEARCH_BAR_MAX_W = DC.SEARCH_BAR_MAX_W or 640
local DASHBOARD_CHILD_PANEL_ALPHA = DC.CHILD_PANEL_ALPHA
local DASHBOARD_CONTENT_CARD_ALPHA_MULT = DC.CONTENT_CARD_ALPHA_MULT
local DASH_HOME_TILE_W = DC.HOME_TILE_W
local DASH_HOME_TILE_H = DC.HOME_TILE_H
local DASH_HOME_TILE_GAP = DC.HOME_TILE_GAP
local DASH_HOME_TILE_COLS = DC.HOME_TILE_COLS
local DASH_HOME_TILE_BG_ALPHA_MULT = DC.HOME_TILE_BG_ALPHA_MULT
local DASH_HOME_SKELETON_BG_ALPHA_MULT = DC.HOME_SKELETON_BG_ALPHA_MULT

local function OptionCategoryKeyIsAxis(catKey)
    return addon.Dashboard_IsAxisCategoryKey(catKey)
end

function addon.Dashboard_BuildMainFrame()
            -- Read saved resize ratio FIRST — needed for initial SetSize and sidebar width.
            -- Accessed via raw _G[DB_NAME] (not profile-routed GetDB) because it is a root key.
            local _initRatio = (function()
                local db = _G[addon.DB_NAME]
                local r = db and tonumber(db.dashboardSizeRatio)
                if r and r >= 0.5 and r <= 2.0 then return r end
                return 1.0
            end)()

    local f = CreateFrame("Frame", "HorizonSuiteDashboard", UIParent, "BackdropTemplate")
            -- Shared by ApplyDashboardClassColor (before sidebar exists) and sidebar selection.
            local dashSession = { activeSidebarBtn = nil }
            -- Size is driven by the saved ratio; default 1280×720 at ratio 1.0.
            f:SetSize(DC.NATIVE_W * _initRatio, DC.NATIVE_H * _initRatio)
            f:SetPoint("CENTER")
            f:SetFrameStrata("HIGH")
            f:SetToplevel(true)
            f:SetMovable(true)
            f:SetClampedToScreen(true)
            f:EnableMouse(true)
            f:Hide()

            local typoRefs = { fontStrings = {}, editBoxes = {} }
            f._dashboardTypographyRefs = typoRefs

            local function MakeText(parent, text, size, r, g, b, justify)
                return addon.Dashboard_MakeText(parent, text, size, r, g, b, justify, typoRefs)
            end
            local function MakeDashboardWelcomeMixedScriptText(parent, text, size, r, g, b, justify)
                return addon.Dashboard_MakeWelcomeMixedScriptText(parent, text, size, r, g, b, justify, typoRefs)
            end

            -- Drag region: top bar to move the window (header area only; search box remains clickable)
            local dragBar = CreateFrame("Frame", nil, f)
            dragBar:SetPoint("TOPLEFT", 0, 0)
            dragBar:SetPoint("TOPRIGHT", 0, 0)
            dragBar:SetHeight(65)
            dragBar:SetFrameLevel(f:GetFrameLevel() + 1)
            dragBar:EnableMouse(true)
            dragBar:RegisterForDrag("LeftButton")
            local dashClickCount = 0
            local dashClickResetAt = 0
            local dashClickWasDrag = false
            local DASH_CLICK_RESET_SEC = 2
            dragBar:SetScript("OnDragStart", function()
                dashClickWasDrag = true
                if not InCombatLockdown() then f:StartMoving() end
            end)
            dragBar:SetScript("OnDragStop", function()
                f:StopMovingOrSizing()
            end)
            dragBar:SetScript("OnMouseUp", function(self, button)
                if button ~= "LeftButton" then return end
                if dashClickWasDrag then dashClickWasDrag = false return end
                dashClickWasDrag = false
                local now = GetTime()
                if now > dashClickResetAt then dashClickCount = 0 end
                dashClickCount = dashClickCount + 1
                dashClickResetAt = now + DASH_CLICK_RESET_SEC
                if dashClickCount >= 5 then
                    dashClickCount = 0
                    local v = not (addon.GetDB and addon.GetDB("focusDevMode", false))
                    if addon.SetDB then addon.SetDB("focusDevMode", v) end
                    if addon.HSPrint then addon.HSPrint("Dev mode (Blizzard tracker): " .. (v and "on" or "off")) end
                    ReloadUI()
                end
            end)

            local moduleLabels = {
                axis = addon.Dashboard_BrandModule("axis") or "Axis",
                focus = addon.Dashboard_BrandModule("focus"),
                presence = addon.Dashboard_BrandModule("presence"),
                vista = addon.Dashboard_BrandModule("vista"),
                insight = addon.Dashboard_BrandModule("insight"),
                cache = addon.Dashboard_BrandModule("cache"),
                essence = addon.Dashboard_BrandModule("essence"),
                meridian = addon.Dashboard_BrandModule("meridian"),
            }

            -- Preview-labelled modules (tiles, sidebar, welcome); keep in sync with OptionsData Modules toggles.
            local PREVIEW_MODULE_KEYS = { cache = true, essence = true }
            -- Coming-soon modules: planned but with no in-game content yet.
            local COMING_SOON_MODULE_KEYS = { meridian = true }

            -- Per-module label colours for Home tiles, matching PN_MODULE_COLORS hex values.
            -- Meridian omitted: no colour assigned yet, falls back to neutral gray.
            local TILE_MODULE_LABEL_COLORS = {
                axis     = { 224/255, 224/255, 224/255 },  -- E0E0E0
                focus    = { 255/255, 209/255,  51/255 },  -- FFD133
                presence = {  51/255, 255/255, 223/255 },  -- 33FFDF
                vista    = { 179/255, 102/255, 255/255 },  -- B366FF
                insight  = { 255/255, 102/255, 179/255 },  -- FF66B3
                cache    = {  51/255, 204/255, 102/255 },  -- 33CC66
                essence  = { 220/255,  20/255,  60/255 },  -- DC143C
            }

            local function ShouldShowModuleOnDashboard(mk)
                if mk == "axis" then return true end
                return addon.IsModuleEnabled and addon:IsModuleEnabled(mk)
            end

            local categoryIcons = {
                ["Axis"] = "INV_Misc_Wrench_01",
                ["Profiles"] = "INV_Misc_GroupNeedMore",
                ["Modules"] = "inv_10_engineering_purchasedparts_color2",
                ["GlobalToggles"] = "Trade_Engineering",
                ["Focus"] = "achievement_quests_completed_05",
                ["Presence"] = "vas_guildnamechange",
                ["Vista"] = "ability_hunter_pathfinding",
                ["Insight"] = "ui_profession_inscription",
                ["Cache"] = "INV_Misc_Coin_01",
                ["Essence"] = "achievement_character_human_male",
                ["Meridian"] = "ability_tracking",
                ["Typography"] = "INV_Misc_Book_09",
                ["Colors"] = "INV_Misc_Gem_Diamond_01",
                ["General"] = "INV_Misc_Question_01",
                ["Core"] = "INV_Misc_Wrench_01",
            }
            
            local function GetAccentColor()
                if addon.GetOptionsClassColor then
                    local cc = addon.GetOptionsClassColor()
                    if cc then return cc[1], cc[2], cc[3] end
                end
                return 0.2, 0.8, 0.9 -- Default sleek cyan
            end

            -- Track static accent elements for live class-colour refresh
            local dashAccentRefs = {
                sidebarBars = {},
                subcatAccents = {},
                subcatDividers = {},
                homeTileDividers = {},
                cardAccents = {},
                cardDividers = {},
                dashboardAxisRails = {},
                patchNotesSectionLabels = {},
                patchNotesBullets = {},
                patchNotesRules = {},
                underline = nil,
                sidebarDivider = nil,
                logoSep = nil,
                logoText = nil,
                searchDropBorder = nil,
                searchFilterDropBorder = nil,
                welcomeAccentStrip = nil,
                guideHeroRail = nil,
                communityFooterTopRules = {},
                dashboardClassIcon = nil,
            }

            -- Set after sidebar header built; repositions logo separator + scroll under version/dev/class icon.
            local LayoutDashboardSidebarUnderHeader

            local function RefreshDashboardClassIcon()
                local tex = dashAccentRefs.dashboardClassIcon
                if not tex then return end
                if not (addon.GetOptionsClassColor and addon.GetOptionsClassColor()) then
                    tex:Hide()
                    return
                end
                local _, classFile = UnitClass("player")
                local src = (addon.GetDB and addon.GetDB("dashboardClassIconSource", "custom")) or "custom"
                local disp = addon.ResolveClassIconDisplay and addon.ResolveClassIconDisplay(classFile, src)
                if not disp then
                    tex:Hide()
                    return
                end
                tex:SetVertexColor(1, 1, 1, 1)
                local iconPx = (addon.GetDashboardClassIconDisplaySize and addon.GetDashboardClassIconDisplaySize()) or 28
                tex:SetSize(iconPx, iconPx)
                if disp.kind == "atlas" then
                    tex:SetTexture(nil)
                    tex:SetAtlas(disp.atlas)
                elseif disp.kind == "file" then
                    tex:SetAtlas(nil)
                    tex:SetTexture(disp.path)
                else
                    tex:Hide()
                    return
                end
                tex:Show()
            end

            addon.ApplyDashboardClassColor = function()
                local ar, ag, ab = GetAccentColor()
                for _, bar in ipairs(dashAccentRefs.sidebarBars) do
                    if bar.SetColorTexture then bar:SetColorTexture(ar, ag, ab, 1) end
                end
                if dashAccentRefs.underline then
                    dashAccentRefs.underline:SetColorTexture(ar, ag, ab, 0.35)
                end
                for _, acc in ipairs(dashAccentRefs.subcatAccents) do
                    if acc.SetColorTexture then acc:SetColorTexture(ar, ag, ab, 1) end
                end
                for _, div in ipairs(dashAccentRefs.subcatDividers) do
                    if div.SetColorTexture then div:SetColorTexture(ar, ag, ab, 0.2) end
                end
                for _, div in ipairs(dashAccentRefs.homeTileDividers) do
                    if div.SetColorTexture then
                        local p = div:GetParent()
                        if p and p._isSkeleton then
                            div:SetColorTexture(0.14, 0.15, 0.17, 0.22)
                        else
                            div:SetColorTexture(ar, ag, ab, 0.2)
                        end
                    end
                end
                for _, acc in ipairs(dashAccentRefs.cardAccents) do
                    if acc.SetColorTexture then acc:SetColorTexture(ar, ag, ab, 1) end
                end
                for _, div in ipairs(dashAccentRefs.cardDividers) do
                    if div.SetColorTexture then div:SetColorTexture(ar, ag, ab, 0.2) end
                end
                if dashSession.activeSidebarBtn then
                    dashSession.activeSidebarBtn.btnBg:SetColorTexture(ar * 0.15, ag * 0.15, ab * 0.15, DASHBOARD_CHILD_PANEL_ALPHA)
                    dashSession.activeSidebarBtn.accentBar:SetColorTexture(ar, ag, ab, 1)
                end
                if dashAccentRefs.sidebarDivider then
                    dashAccentRefs.sidebarDivider:SetColorTexture(ar, ag, ab, 0.4)
                end
                if dashAccentRefs.logoSep then
                    dashAccentRefs.logoSep:SetColorTexture(ar, ag, ab, 0.3)
                end
                if dashAccentRefs.logoText then
                    dashAccentRefs.logoText:SetTextColor(ar, ag, ab)
                end
                if dashAccentRefs.searchDropBorder and dashAccentRefs.searchDropBorder.SetBackdropBorderColor then
                    dashAccentRefs.searchDropBorder:SetBackdropBorderColor(ar, ag, ab, 0.5)
                end
                if dashAccentRefs.searchFilterDropBorder and dashAccentRefs.searchFilterDropBorder.SetBackdropBorderColor then
                    dashAccentRefs.searchFilterDropBorder:SetBackdropBorderColor(ar, ag, ab, 0.5)
                end
                if dashAccentRefs.welcomeAccentStrip and dashAccentRefs.welcomeAccentStrip.SetColorTexture then
                    dashAccentRefs.welcomeAccentStrip:SetColorTexture(ar, ag, ab, 0.5)
                end
                if dashAccentRefs.guideHeroRail and dashAccentRefs.guideHeroRail.SetColorTexture then
                    dashAccentRefs.guideHeroRail:SetColorTexture(ar, ag, ab, 0.55)
                end
                for _, lbl in ipairs(dashAccentRefs.patchNotesSectionLabels) do
                    if lbl and lbl.SetTextColor then lbl:SetTextColor(ar, ag, ab) end
                end
                for _, rule in ipairs(dashAccentRefs.patchNotesRules) do
                    if rule and rule.SetColorTexture then rule:SetColorTexture(ar, ag, ab, 0.35) end
                end
                for _, rule in ipairs(dashAccentRefs.communityFooterTopRules) do
                    if rule and rule.SetColorTexture then
                        rule:SetColorTexture(ar, ag, ab, 0.3)
                    end
                end
                local pnHex = string.format("%02X%02X%02X",
                    math.floor(ar*255+0.5), math.floor(ag*255+0.5), math.floor(ab*255+0.5))
                for _, entry in ipairs(dashAccentRefs.patchNotesBullets) do
                    if entry and entry.fs and entry.bullet then
                        entry.fs:SetText("|cFF"..pnHex.."\226\128\148|r  "..(entry.coloredBullet or entry.bullet))
                    end
                end
                for _, rail in ipairs(dashAccentRefs.dashboardAxisRails) do
                    if rail and rail.SetColorTexture then
                        local parent = rail:GetParent()
                        local hover = parent and parent.IsMouseOver and parent:IsMouseOver()
                        rail:SetColorTexture(ar, ag, ab, hover and 0.55 or 0.35)
                    end
                end
                if addon.DashboardPreview and addon.DashboardPreview.ApplyAccentColor then
                    addon.DashboardPreview.ApplyAccentColor(ar, ag, ab)
                end
                RefreshDashboardClassIcon()
                if LayoutDashboardSidebarUnderHeader then
                    LayoutDashboardSidebarUnderHeader()
                end
            end

            tinsert(UISpecialFrames, "HorizonSuiteDashboard")

            -- Background: solid base (always) + optional art layer(s) with crossfade between themes
            local bgSolid = f:CreateTexture(nil, "BACKGROUND", nil, -1)
            bgSolid:SetAllPoints()
            bgSolid:SetColorTexture(0.05, 0.05, 0.07, addon.Dashboard_GetBgSolidAlpha(false))
            local bgArt1 = f:CreateTexture(nil, "BACKGROUND", nil, 0)
            local bgArt2 = f:CreateTexture(nil, "BACKGROUND", nil, 0)
            bgArt1:SetAllPoints()
            bgArt2:SetAllPoints()
            bgArt1:Hide()
            bgArt2:Hide()
            local bgFadeDriver = CreateFrame("Frame", nil, f)
            bgFadeDriver:SetSize(1, 1)
            bgFadeDriver:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
            f._dashboardBgSolid = bgSolid
            f._dashboardBgArt1 = bgArt1
            f._dashboardBgArt2 = bgArt2
            f._dashboardBgFadeDriver = bgFadeDriver
            f._dashboardBgActiveLayer = 1
            f._dashboardBgLastSig = nil
            f._dashboardBgFading = false
            if addon.ApplyDashboardBackground then
                addon.ApplyDashboardBackground()
            end

            f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
            f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
            f:RegisterEvent("PLAYER_REGEN_ENABLED")
            f:SetScript("OnEvent", function(self, event)
                if event == "PLAYER_REGEN_ENABLED" then
                    if self:IsShown() and self._dashboardApplyKeyboardPropagation then
                        self._dashboardApplyKeyboardPropagation()
                    end
                    return
                end
                if event == "PLAYER_SPECIALIZATION_CHANGED" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
                    if self:IsShown() and addon.ApplyDashboardBackground then
                        addon.ApplyDashboardBackground()
                    end
                end
            end)

            local sb = addon.DashboardSidebar_CreateChrome({
                f = f,
                addon = addon,
                dashAccentRefs = dashAccentRefs,
                dashSession = dashSession,
                DASHBOARD_CHILD_PANEL_ALPHA = DASHBOARD_CHILD_PANEL_ALPHA,
                MakeText = MakeText,
                GetAccentColor = GetAccentColor,
                refreshDashboardClassIcon = RefreshDashboardClassIcon,
            })
            local CONTENT_OFFSET = sb.CONTENT_OFFSET
            local SIDEBAR_WIDTH = sb.SIDEBAR_WIDTH
            local sidebar = sb.sidebar
            local sidebarScrollFrame = sb.sidebarScrollFrame
            local sidebarScrollContent = sb.sidebarScrollContent
            local sidebarButtons = sb.sidebarButtons
            local GetGroupCollapsed = sb.GetGroupCollapsed
            local SetGroupCollapsed = sb.SetGroupCollapsed
            local SetGroupChildrenShown = sb.SetGroupChildrenShown
            local sidebarState = sb.sidebarState
            local CLEAR = sb.CLEAR
            local HEADER_ROW_HEIGHT = sb.HEADER_ROW_HEIGHT
            local SIDEBAR_TOP_PAD = sb.SIDEBAR_TOP_PAD
            local TAB_ROW_HEIGHT = sb.TAB_ROW_HEIGHT
            local SIDEBAR_WHATSNEW_RESERVE = sb.SIDEBAR_WHATSNEW_RESERVE
            local SIDEBAR_CONTENT_X_INSET = sb.SIDEBAR_CONTENT_X_INSET
            local CreateSidebarButton = sb.CreateSidebarButton
            local CreateBottomPinnedButton = sb.CreateBottomPinnedButton
            local SetActiveSidebarButton = sb.SetActiveSidebarButton
            LayoutDashboardSidebarUnderHeader = sb.layoutUnderHeader

            local SetSidebarState

            -- Header
            local head = MakeText(f, "Horizon Suite", 24, 1, 1, 1, "CENTER")
            head:SetPoint("TOP", CONTENT_OFFSET / 2, DASH_HEAD_TITLE_Y)
            local headSub = MakeText(f, "Select a module to configure", 13, 0.5, 0.5, 0.5, "CENTER")
            headSub:SetPoint("TOP", CONTENT_OFFSET / 2, DASH_HEAD_SUBTITLE_Y)

            -- Content geometry (ratio-aware via DC.GetLayoutConstants so initial layout
            -- matches the saved resize ratio without needing a CommitResize on first open).
            local _lc0 = DC.GetLayoutConstants(_initRatio)
            local viewWidth   = _lc0.viewWidth
            local viewCenterX = _lc0.viewCenterX
            local contentWidth = _lc0.contentWidth
            local dashTitleX  = _lc0.dashTitleX
            -- Accurate scroll offsets: account for the search shell height + gap.
            local viewTopInset = (_lc0.frameH - _lc0.viewH) / 2
            local searchShellTotalH = DASH_SEARCH_BOX_H + DASH_SEARCH_SHELL_EXTRA_H
            local searchBandBelowHeader = searchShellTotalH + DASH_SCROLL_GAP_BELOW_SEARCH
            local dashScrollTopOffset = -(math.abs(DASH_SEARCH_Y) + DASH_SEARCH_BAR_TOP_NUDGE + searchBandBelowHeader - viewTopInset)
            -- Module / category views omit the search bar; reclaim vertical space for scroll content.
            local dashScrollTopOffsetModule = dashScrollTopOffset + searchBandBelowHeader

            -- Search bar: card-style shell (aligned with options SectionCard tokens) + clear control.
            local WDef = addon.OptionsWidgetsDef
            local SCardBg = (WDef and WDef.SectionCardBg) or { 0.09, 0.09, 0.11, 0.96 }
            local SCardBd = (WDef and WDef.SectionCardBorder) or { 0.18, 0.2, 0.24, 0.35 }
            local searchBarW = math.min(DASH_SEARCH_BAR_MAX_W, math.max(280, math.floor(contentWidth * 0.65)))
            local SEARCH_BAR_BACKDROP = {
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true,
                tileSize = 16,
                edgeSize = 12,
                insets = { left = 3, right = 3, top = 3, bottom = 3 },
            }
            local searchBarShell = CreateFrame("Frame", nil, f, "BackdropTemplate")
            searchBarShell:SetSize(searchBarW, DASH_SEARCH_BOX_H + DASH_SEARCH_SHELL_EXTRA_H)
            searchBarShell:SetPoint("TOP", CONTENT_OFFSET / 2, DASH_SEARCH_Y - DASH_SEARCH_BAR_TOP_NUDGE)
            searchBarShell:SetBackdrop(SEARCH_BAR_BACKDROP)
            searchBarShell:SetBackdropColor(SCardBg[1], SCardBg[2], SCardBg[3], SCardBg[4] * DASHBOARD_CONTENT_CARD_ALPHA_MULT)
            searchBarShell:SetBackdropBorderColor(SCardBd[1], SCardBd[2], SCardBd[3], SCardBd[4])
            searchBarShell:SetFrameLevel(f:GetFrameLevel() + 5)
            searchBarShell:Hide()
            f.searchBarShell = searchBarShell
            f.dashboardSearchModuleFilter = "all"

            -- Right chrome: clear (×) + module filter; search field stops before this strip.
            local SEARCH_FILTER_BTN_W = 84
            local SEARCH_RIGHT_CHROME_W = 8 + 22 + 4 + SEARCH_FILTER_BTN_W + 4

            local searchBox = CreateFrame("EditBox", nil, searchBarShell)
            searchBox:SetPoint("TOPLEFT", searchBarShell, "TOPLEFT", 4, -4)
            searchBox:SetPoint("BOTTOMRIGHT", searchBarShell, "BOTTOMRIGHT", -SEARCH_RIGHT_CHROME_W, 4)
            do
                local sp = addon.Dashboard_ResolveSavedDashboardFontPath(
                    (addon.GetDB and addon.GetDB("dashboardFontPath", addon.Dashboard_GetDefaultDashboardFontPath())) or addon.Dashboard_GetDefaultDashboardFontPath()
                )
                local se = addon.Dashboard_EffectiveDashboardFontSize(14)
                local wf = addon.Dashboard_GetWidgetOutlineFlags and addon.Dashboard_GetWidgetOutlineFlags() or "OUTLINE"
                pcall(function()
                    searchBox:SetFont(sp, se, wf)
                end)
            end
            addon.Dashboard_RegisterTypographyEditBox(typoRefs, searchBox, 14, nil, true)
            searchBox:SetTextInsets(36, 6, 0, 0)
            searchBox:SetAutoFocus(false)

            local sbPlaceholder = MakeText(searchBox, L["DASH_SEARCH_PLACEHOLDER"] or "Search settings...", 14, 0.45, 0.45, 0.5, "LEFT")
            sbPlaceholder:SetPoint("LEFT", 36, 0)

            local sbIcon = searchBox:CreateTexture(nil, "ARTWORK")
            sbIcon:SetSize(16, 16)
            sbIcon:SetPoint("LEFT", 12, 0)
            sbIcon:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_03")
            sbIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            sbIcon:SetVertexColor(0.5, 0.52, 0.58, 1)

            local searchClearBtn = CreateFrame("Button", nil, searchBarShell)
            searchClearBtn:SetSize(22, 22)
            searchClearBtn:SetPoint("RIGHT", searchBarShell, "RIGHT", -8, 0)
            searchClearBtn:SetFrameLevel(searchBarShell:GetFrameLevel() + 2)
            searchClearBtn:Hide()
            local searchClearTxt = searchClearBtn:CreateFontString(nil, "OVERLAY")
            do
                local cp = addon.Dashboard_ResolveSavedDashboardFontPath(
                    (addon.GetDB and addon.GetDB("dashboardFontPath", addon.Dashboard_GetDefaultDashboardFontPath())) or addon.Dashboard_GetDefaultDashboardFontPath()
                )
                local ce = addon.Dashboard_EffectiveDashboardFontSize(12)
                pcall(function()
                    searchClearTxt:SetFont(cp, ce, "")
                end)
                if addon.Dashboard_ApplyTextShadow then
                    addon.Dashboard_ApplyTextShadow(searchClearTxt)
                end
            end
            searchClearTxt:SetPoint("CENTER", searchClearBtn, "CENTER", 0, 0)
            searchClearTxt:SetText("×")
            searchClearTxt:SetTextColor(0.5, 0.52, 0.58, 1)
            searchClearBtn:SetScript("OnEnter", function()
                searchClearTxt:SetTextColor(0.92, 0.94, 0.98, 1)
            end)
            searchClearBtn:SetScript("OnLeave", function()
                searchClearTxt:SetTextColor(0.5, 0.52, 0.58, 1)
            end)
            searchClearBtn:SetScript("OnClick", function()
                searchBox:SetText("")
                sbPlaceholder:Show()
                searchClearBtn:Hide()
                if f.OnSearchTextChanged then f.OnSearchTextChanged("") end
                if f.HideSearchDropdown then f.HideSearchDropdown() end
            end)

            local searchFilterDivider = searchBarShell:CreateTexture(nil, "ARTWORK")
            searchFilterDivider:SetWidth(1)
            searchFilterDivider:SetColorTexture(SCardBd[1], SCardBd[2], SCardBd[3], 0.45)

            -- Plain Button without template textures shows a white square on some clients; clear normal/highlight/pushed art.
            local function ClearButtonTemplateArt(btn)
                local tex = "Interface\\Buttons\\WHITE8X8"
                btn:SetNormalTexture(tex)
                btn:SetHighlightTexture(tex)
                btn:SetPushedTexture(tex)
                btn:SetDisabledTexture(tex)
                local function zeroAlpha(t)
                    if t and t.SetVertexColor then t:SetVertexColor(0, 0, 0, 0) end
                end
                zeroAlpha(btn:GetNormalTexture())
                zeroAlpha(btn:GetHighlightTexture())
                zeroAlpha(btn:GetPushedTexture())
                zeroAlpha(btn:GetDisabledTexture())
            end

            local searchModuleFilterBtn = CreateFrame("Button", nil, searchBarShell)
            searchModuleFilterBtn:SetSize(SEARCH_FILTER_BTN_W, 22)
            searchModuleFilterBtn:SetPoint("RIGHT", searchClearBtn, "LEFT", -4, 0)
            searchModuleFilterBtn:SetFrameLevel(searchBarShell:GetFrameLevel() + 2)
            ClearButtonTemplateArt(searchModuleFilterBtn)
            local searchModuleFilterLabel = searchModuleFilterBtn:CreateFontString(nil, "OVERLAY")
            do
                local fp = addon.Dashboard_ResolveSavedDashboardFontPath(
                    (addon.GetDB and addon.GetDB("dashboardFontPath", addon.Dashboard_GetDefaultDashboardFontPath())) or addon.Dashboard_GetDefaultDashboardFontPath()
                )
                local fe = addon.Dashboard_EffectiveDashboardFontSize(11)
                pcall(function()
                    searchModuleFilterLabel:SetFont(fp, fe, "")
                end)
                if addon.Dashboard_ApplyTextShadow then
                    addon.Dashboard_ApplyTextShadow(searchModuleFilterLabel)
                end
            end
            searchModuleFilterLabel:SetPoint("LEFT", searchModuleFilterBtn, "LEFT", 4, 0)
            searchModuleFilterLabel:SetPoint("RIGHT", searchModuleFilterBtn, "RIGHT", -14, 0)
            searchModuleFilterLabel:SetJustifyH("LEFT")
            searchModuleFilterLabel:SetTextColor(0.65, 0.67, 0.72, 1)
            local searchModuleFilterChev = searchModuleFilterBtn:CreateFontString(nil, "OVERLAY")
            do
                local fp = addon.Dashboard_ResolveSavedDashboardFontPath(
                    (addon.GetDB and addon.GetDB("dashboardFontPath", addon.Dashboard_GetDefaultDashboardFontPath())) or addon.Dashboard_GetDefaultDashboardFontPath()
                )
                local fe = addon.Dashboard_EffectiveDashboardFontSize(10)
                pcall(function()
                    searchModuleFilterChev:SetFont(fp, fe, "")
                end)
            end
            searchModuleFilterChev:SetPoint("RIGHT", searchModuleFilterBtn, "RIGHT", -4, 0)
            -- ASCII chevron: Unicode ▾ renders as a square with many dashboard fonts.
            searchModuleFilterChev:SetText("v")
            searchModuleFilterChev:SetTextColor(0.5, 0.52, 0.58, 1)

            searchFilterDivider:SetPoint("TOPRIGHT", searchModuleFilterBtn, "TOPLEFT", -6, 2)
            searchFilterDivider:SetPoint("BOTTOMRIGHT", searchModuleFilterBtn, "BOTTOMLEFT", -6, -2)

            local function SearchFilterMenuIncludeModuleKey(mk)
                if mk == "axis" then return true end
                return addon.IsModuleEnabled and addon:IsModuleEnabled(mk)
            end

            local function UpdateSearchModuleFilterLabel()
                local fk = f.dashboardSearchModuleFilter or "all"
                if fk ~= "all" and fk ~= "axis" and not SearchFilterMenuIncludeModuleKey(fk) then
                    f.dashboardSearchModuleFilter = "all"
                    fk = "all"
                end
                if fk == "all" then
                    searchModuleFilterLabel:SetText(L["DASH_SEARCH_FILTER_ALL"] or "All")
                else
                    searchModuleFilterLabel:SetText(moduleLabels[fk] or fk)
                end
            end
            f.UpdateSearchModuleFilterLabel = UpdateSearchModuleFilterLabel
            UpdateSearchModuleFilterLabel()

            searchModuleFilterBtn:SetScript("OnEnter", function()
                searchModuleFilterLabel:SetTextColor(0.88, 0.9, 0.94, 1)
                searchModuleFilterChev:SetTextColor(0.75, 0.78, 0.85, 1)
                GameTooltip:SetOwner(searchModuleFilterBtn, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["DASH_SEARCH_FILTER_TOOLTIP"] or "Limit search to one module", nil, nil, nil, nil, true)
                GameTooltip:Show()
            end)
            searchModuleFilterBtn:SetScript("OnLeave", function()
                searchModuleFilterLabel:SetTextColor(0.65, 0.67, 0.72, 1)
                searchModuleFilterChev:SetTextColor(0.5, 0.52, 0.58, 1)
                GameTooltip:Hide()
            end)

            local searchModuleFilterMenuRows = {}
            local SEARCH_MODULE_FILTER_ROW_H = 28
            local SEARCH_MODULE_FILTER_GROUP_ORDER = { "axis", "focus", "insight", "essence", "presence", "vista", "cache" }

            local searchModuleFilterMenu = CreateFrame("Frame", nil, f, "BackdropTemplate")
            searchModuleFilterMenu:SetFrameLevel(f:GetFrameLevel() + 12)
            searchModuleFilterMenu:SetBackdrop({
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 12,
                insets = { left = 3, right = 3, top = 3, bottom = 3 },
            })
            searchModuleFilterMenu:SetBackdropColor(0.08, 0.08, 0.09, DASHBOARD_CHILD_PANEL_ALPHA)
            local fmbr, fmbg, fmbb = GetAccentColor()
            searchModuleFilterMenu:SetBackdropBorderColor(fmbr, fmbg, fmbb, 0.5)
            searchModuleFilterMenu:Hide()
            dashAccentRefs.searchFilterDropBorder = searchModuleFilterMenu

            local searchModuleFilterCatch = CreateFrame("Button", nil, f)
            searchModuleFilterCatch:SetAllPoints(f)
            searchModuleFilterCatch:SetFrameLevel(f:GetFrameLevel() + 11)
            searchModuleFilterCatch:Hide()

            local function HideSearchModuleFilterMenu()
                searchModuleFilterMenu:Hide()
                searchModuleFilterCatch:Hide()
            end
            f.HideSearchModuleFilterMenu = HideSearchModuleFilterMenu

            searchModuleFilterCatch:SetScript("OnClick", function()
                HideSearchModuleFilterMenu()
            end)

            local function BuildAndShowSearchModuleFilterMenu()
                local filterBefore = f.dashboardSearchModuleFilter or "all"
                UpdateSearchModuleFilterLabel()
                local filterAfter = f.dashboardSearchModuleFilter or "all"
                if filterBefore ~= filterAfter and f.FilterBySearch and searchBox then
                    f.FilterBySearch(searchBox:GetText())
                end

                local groups = {}
                for _, cat in ipairs(addon.OptionCategories or {}) do
                    local mk = OptionCategoryKeyIsAxis(cat.key) and "axis" or (cat.moduleKey or "modules")
                    groups[mk] = (groups[mk] or 0) + 1
                end

                local moduleEntries = {}
                for _, mk in ipairs(SEARCH_MODULE_FILTER_GROUP_ORDER) do
                    if groups[mk] and groups[mk] > 0 and SearchFilterMenuIncludeModuleKey(mk) then
                        moduleEntries[#moduleEntries + 1] = { key = mk, label = moduleLabels[mk] or mk }
                    end
                end
                table.sort(moduleEntries, function(a, b)
                    return (a.label or ""):lower() < (b.label or ""):lower()
                end)
                local entries = { { key = "all", label = L["DASH_SEARCH_FILTER_ALL"] or "All" } }
                for _, e in ipairs(moduleEntries) do
                    entries[#entries + 1] = e
                end

                local n = #entries
                for i = 1, n do
                    if not searchModuleFilterMenuRows[i] then
                        local row = CreateFrame("Button", nil, searchModuleFilterMenu)
                        row:SetHeight(SEARCH_MODULE_FILTER_ROW_H)
                        row:SetPoint("LEFT", searchModuleFilterMenu, "LEFT", 6, 0)
                        row:SetPoint("RIGHT", searchModuleFilterMenu, "RIGHT", -6, 0)
                        ClearButtonTemplateArt(row)
                        local hi = row:CreateTexture(nil, "BACKGROUND")
                        hi:SetAllPoints(row)
                        hi:SetColorTexture(1, 1, 1, 0.06)
                        hi:Hide()
                        local rl = MakeText(row, "", 12, 0.88, 0.9, 0.93, "LEFT")
                        rl:SetPoint("LEFT", 8, 0)
                        rl:SetPoint("RIGHT", -8, 0)
                        row:SetScript("OnEnter", function()
                            local har, hag, hab = GetAccentColor()
                            hi:SetColorTexture(har, hag, hab, 0.1)
                            hi:Show()
                        end)
                        row:SetScript("OnLeave", function()
                            hi:Hide()
                        end)
                        searchModuleFilterMenuRows[i] = { btn = row, label = rl }
                    end
                    local row = searchModuleFilterMenuRows[i]
                    local e = entries[i]
                    row.label:SetText(e.label)
                    row.btn:ClearAllPoints()
                    row.btn:SetHeight(SEARCH_MODULE_FILTER_ROW_H)
                    row.btn:SetPoint("LEFT", searchModuleFilterMenu, "LEFT", 6, 0)
                    row.btn:SetPoint("RIGHT", searchModuleFilterMenu, "RIGHT", -6, 0)
                    row.btn:SetPoint("TOP", searchModuleFilterMenu, "TOP", 0, -6 - (i - 1) * SEARCH_MODULE_FILTER_ROW_H)
                    row.btn:SetScript("OnClick", function()
                        f.dashboardSearchModuleFilter = e.key
                        UpdateSearchModuleFilterLabel()
                        HideSearchModuleFilterMenu()
                        if f.FilterBySearch and searchBox then
                            f.FilterBySearch(searchBox:GetText())
                        end
                    end)
                    row.btn:Show()
                end
                for j = n + 1, #searchModuleFilterMenuRows do
                    searchModuleFilterMenuRows[j].btn:Hide()
                end

                local mw = math.max(SEARCH_FILTER_BTN_W + 24, 188)
                local mh = 12 + n * SEARCH_MODULE_FILTER_ROW_H + 6
                searchModuleFilterMenu:SetSize(mw, mh)
                searchModuleFilterMenu:ClearAllPoints()
                searchModuleFilterMenu:SetPoint("TOPLEFT", searchModuleFilterBtn, "BOTTOMLEFT", 0, -4)
                searchModuleFilterMenu:Show()
                searchModuleFilterCatch:SetFrameLevel(searchModuleFilterMenu:GetFrameLevel() - 1)
                searchModuleFilterCatch:Show()
            end

            searchModuleFilterBtn:SetScript("OnClick", function()
                if searchModuleFilterMenu:IsShown() then
                    HideSearchModuleFilterMenu()
                else
                    BuildAndShowSearchModuleFilterMenu()
                end
            end)

            local function UpdateSearchBarBorderFocused(focused)
                local ar, ag, ab = GetAccentColor()
                if focused then
                    searchBarShell:SetBackdropBorderColor(ar, ag, ab, 0.95)
                    sbIcon:SetVertexColor(0.85, 0.88, 0.92, 1)
                else
                    searchBarShell:SetBackdropBorderColor(SCardBd[1], SCardBd[2], SCardBd[3], SCardBd[4])
                    if searchBox:GetText() == "" then
                        sbIcon:SetVertexColor(0.5, 0.52, 0.58, 1)
                    end
                end
            end

            searchBox:SetScript("OnEditFocusGained", function()
                UpdateSearchBarBorderFocused(true)
                sbPlaceholder:Hide()
            end)
            searchBox:SetScript("OnEditFocusLost", function(self)
                UpdateSearchBarBorderFocused(false)
                if self:GetText() == "" then
                    sbPlaceholder:Show()
                end
            end)
            searchBox:SetScript("OnTextChanged", function(self)
                local t = self:GetText()
                if t == "" and not self:HasFocus() then
                    sbPlaceholder:Show()
                else
                    sbPlaceholder:Hide()
                end
                searchClearBtn:SetShown(t ~= "")
                if f.OnSearchTextChanged then f.OnSearchTextChanged(t) end
            end)
            searchBox:SetScript("OnEscapePressed", function(self)
                self:ClearFocus()
                self:SetText("")
                sbPlaceholder:Show()
                searchClearBtn:Hide()
                if f.HideSearchModuleFilterMenu then f.HideSearchModuleFilterMenu() end
                if f.HideSearchDropdown then f.HideSearchDropdown() end
            end)

            -- Search results surface (flyout under bar in module views; embedded in Search page).
            local searchDropdown = CreateFrame("Frame", nil, f, "BackdropTemplate")
            searchDropdown:SetSize(600, 300)
            searchDropdown:SetPoint("TOPLEFT", searchBarShell, "BOTTOMLEFT", 0, -6)
            searchDropdown:SetFrameLevel(f:GetFrameLevel() + 10)
            searchDropdown:SetBackdrop({
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 12,
                insets = { left = 3, right = 3, top = 3, bottom = 3 }
            })
            searchDropdown:SetBackdropColor(0.08, 0.08, 0.09, DASHBOARD_CHILD_PANEL_ALPHA)
            local sdar, sdag, sdab = GetAccentColor()
            searchDropdown:SetBackdropBorderColor(sdar, sdag, sdab, 0.5)
            dashAccentRefs.searchDropBorder = searchDropdown
            searchDropdown:Hide()

            local searchDropdownScroll = CreateFrame("ScrollFrame", nil, searchDropdown)
            searchDropdownScroll:SetPoint("TOPLEFT", 6, -6)
            searchDropdownScroll:SetPoint("BOTTOMRIGHT", -6, 6)
            local searchDropdownContent = CreateFrame("Frame", nil, searchDropdownScroll)
            searchDropdownContent:SetSize(570, 1)
            searchDropdownScroll:SetScrollChild(searchDropdownContent)

            addon.Dashboard_ApplySmoothScroll(searchDropdownScroll, searchDropdownContent, 30, true)
            local searchDropdownCatch = CreateFrame("Button", nil, f)
            searchDropdownCatch:SetAllPoints(f)
            searchDropdownCatch:SetFrameLevel(searchDropdown:GetFrameLevel() - 1)
            searchDropdownCatch:Hide()
            searchDropdownCatch:SetScript("OnClick", function()
                if f.HideSearchDropdown then f.HideSearchDropdown() end
            end)

            f.HideSearchDropdown = function()
                if f.HideSearchModuleFilterMenu then f.HideSearchModuleFilterMenu() end
                searchDropdown:Hide()
                searchDropdownCatch:Hide()
                if f.searchEmptyHint and f.searchView and f.searchView:IsShown() then
                    local q = searchBox and searchBox:GetText() and searchBox:GetText():trim() or ""
                    if q == "" or #q < 2 then
                        f.searchEmptyHint:Show()
                    end
                end
            end

            -- Dock search results: flyout under bar (module/settings) vs embedded panel (Search page).
            f.DockSearchDropdownForModule = function()
                if not searchDropdown or not searchBarShell then return end
                searchDropdown:SetParent(f)
                searchDropdown:ClearAllPoints()
                searchDropdown:SetSize(600, 300)
                searchDropdown:SetPoint("TOPLEFT", searchBarShell, "BOTTOMLEFT", 0, -6)
                searchDropdown:SetFrameLevel(f:GetFrameLevel() + 10)
                local w = searchDropdown:GetWidth() or 600
                searchDropdownContent:SetWidth(math.max(1, w - 24))
            end

            local searchView = CreateFrame("Frame", nil, f)
            searchView:SetSize(viewWidth, DASHBOARD_VIEW_H)
            searchView:SetPoint("CENTER", viewCenterX, 0)
            searchView:Hide()
            f.searchView = searchView

            local SEARCH_SCROLL_ABOVE_COMMUNITY_FOOTER = (DC.COMMUNITY_FOOTER_SCROLL_GAP) or 24
            local searchCommunityFooterPanel = CreateFrame("Frame", nil, searchView)
            searchCommunityFooterPanel:SetFrameLevel(searchView:GetFrameLevel() + 10)
            local searchCommunityFooterObj = addon.Dashboard_CreateCommunityFooter(searchCommunityFooterPanel, {
                L = L,
                GetAccentColor = GetAccentColor,
                MakeText = MakeText,
                addon = addon,
            })
            tinsert(dashAccentRefs.communityFooterTopRules, searchCommunityFooterObj.footerTopRule)
            local function LayoutSearchCommunityFooter()
                local rawW = searchView:GetWidth() or 0
                local w = math.max(280, rawW - 40)
                searchCommunityFooterObj.layout(w, 0, searchView)
            end
            LayoutSearchCommunityFooter()

            f.DockSearchDropdownForSearchView = function()
                if not searchDropdown or not f.searchView then return end
                LayoutSearchCommunityFooter()
                searchDropdown:SetParent(f.searchView)
                searchDropdown:ClearAllPoints()
                searchDropdown:SetPoint("TOPLEFT", f.searchView, "TOPLEFT", 40, dashScrollTopOffset)
                searchDropdown:SetPoint("BOTTOMLEFT", searchCommunityFooterPanel, "TOPLEFT", 20, SEARCH_SCROLL_ABOVE_COMMUNITY_FOOTER)
                searchDropdown:SetPoint("BOTTOMRIGHT", searchCommunityFooterPanel, "TOPRIGHT", -20, SEARCH_SCROLL_ABOVE_COMMUNITY_FOOTER)
                searchDropdown:SetFrameLevel(f.searchView:GetFrameLevel() + 5)
                local w = searchDropdown:GetWidth() or 1
                searchDropdownContent:SetWidth(math.max(1, w - 24))
            end

            local searchEmptyHint = MakeText(searchView, L["DASH_SEARCH_EMPTY_HINT"] or "", 14, 0.48, 0.5, 0.56, "CENTER")
            searchEmptyHint:SetPoint("TOP", searchView, "TOP", 0, dashScrollTopOffset - 24)
            searchEmptyHint:SetWidth(math.max(200, contentWidth - 48))
            searchEmptyHint:SetWordWrap(true)
            searchEmptyHint:SetText(L["DASH_SEARCH_EMPTY_HINT"] or "Type at least two characters to search settings, modules, and options.")
            searchEmptyHint:Hide()
            f.searchEmptyHint = searchEmptyHint

            searchView:SetScript("OnSizeChanged", function()
                LayoutSearchCommunityFooter()
                if searchView:IsShown() and f.DockSearchDropdownForSearchView then
                    f.DockSearchDropdownForSearchView()
                end
            end)

            -- Views (viewWidth / contentWidth / dashScrollTopOffset defined above with search bar)
            local detailTitle = MakeText(f, "MODULE SETTINGS", 18, 1, 1, 1, "LEFT")
            detailTitle:SetPoint("TOPLEFT", f, "TOPLEFT", dashTitleX, DASH_HEAD_TITLE_Y)
            detailTitle:Hide()
            f.detailTitle = detailTitle

            local detailTitleUnderline = f:CreateTexture(nil, "ARTWORK")
            detailTitleUnderline:SetHeight(1)
            detailTitleUnderline:SetPoint("TOPLEFT", detailTitle, "BOTTOMLEFT", 0, -6)
            detailTitleUnderline:SetWidth(math.max(1, viewWidth - 80))
            local arU, agU, abU = GetAccentColor()
            detailTitleUnderline:SetColorTexture(arU, agU, abU, 0.35)
            detailTitleUnderline:Hide()
            dashAccentRefs.underline = detailTitleUnderline

            -- Patch Notes only: full changelog link (top-right of frame, aligned with title row).
            local PN_CHANGELOG_URL = "https://gitlab.com/Crystilac/horizon-suite/-/blob/main/CHANGELOG.md"
            local pnChangelogHeaderBtn = CreateFrame("Button", nil, f)
            pnChangelogHeaderBtn:SetFrameLevel(f:GetFrameLevel() + 12)
            pnChangelogHeaderBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -48, DASH_HEAD_TITLE_Y)
            pnChangelogHeaderBtn:SetSize(160, 22)
            local pnClHdrTxt = pnChangelogHeaderBtn:CreateFontString(nil, "OVERLAY")
            do
                local pp = addon.Dashboard_ResolveSavedDashboardFontPath(
                    (addon.GetDB and addon.GetDB("dashboardFontPath", addon.Dashboard_GetDefaultDashboardFontPath())) or addon.Dashboard_GetDefaultDashboardFontPath()
                )
                local pe = addon.Dashboard_EffectiveDashboardFontSize(12)
                pcall(function()
                    pnClHdrTxt:SetFont(pp, pe, "")
                end)
                if addon.Dashboard_ApplyTextShadow then
                    addon.Dashboard_ApplyTextShadow(pnClHdrTxt)
                end
            end
            addon.Dashboard_RegisterTypographyFontString(typoRefs, pnClHdrTxt, 12, "")
            pnClHdrTxt:SetPoint("CENTER", pnChangelogHeaderBtn, "CENTER", 0, 0)
            pnClHdrTxt:SetText(L["DASH_FULL_CHANGELOG"] or "Full changelog")
            pnClHdrTxt:SetTextColor(0.92, 0.94, 0.98, 1)
            pnChangelogHeaderBtn:SetScript("OnEnter", function()
                pnClHdrTxt:SetTextColor(1, 1, 1, 1)
            end)
            pnChangelogHeaderBtn:SetScript("OnLeave", function()
                pnClHdrTxt:SetTextColor(0.92, 0.94, 0.98, 1)
            end)
            pnChangelogHeaderBtn:SetScript("OnClick", function()
                if addon.ShowURLCopyBox then addon.ShowURLCopyBox(PN_CHANGELOG_URL) end
            end)
            pnChangelogHeaderBtn:Hide()
            f.pnChangelogHeaderBtn = pnChangelogHeaderBtn

            local dashboardView = CreateFrame("Frame", nil, f)
            dashboardView:SetSize(viewWidth, DASHBOARD_VIEW_H)
            dashboardView:SetPoint("CENTER", viewCenterX, 0)
            f.dashboardView = dashboardView

            local detailView = CreateFrame("Frame", nil, f)
            detailView:SetSize(viewWidth, DASHBOARD_VIEW_H)
            detailView:SetPoint("CENTER", viewCenterX, 0)
            detailView:Hide()
            f.detailView = detailView

            local subCategoryView = CreateFrame("Frame", nil, f)
            subCategoryView:SetSize(viewWidth, DASHBOARD_VIEW_H)
            subCategoryView:SetPoint("CENTER", viewCenterX, 0)
            subCategoryView:Hide()
            f.subCategoryView = subCategoryView

            local welcomeView = CreateFrame("Frame", nil, f)
            welcomeView:SetSize(viewWidth, DASHBOARD_VIEW_H)
            welcomeView:SetPoint("CENTER", viewCenterX, 0)
            welcomeView:Hide()
            f.welcomeView = welcomeView

            local guideView = CreateFrame("Frame", nil, f)
            guideView:SetSize(viewWidth, DASHBOARD_VIEW_H)
            guideView:SetPoint("CENTER", viewCenterX, 0)
            guideView:Hide()
            f.guideView = guideView

            local patchNotesView = CreateFrame("Frame", nil, f)
            patchNotesView:SetSize(viewWidth, DASHBOARD_VIEW_H)
            patchNotesView:SetPoint("CENTER", viewCenterX, 0)
            patchNotesView:Hide()
            f.patchNotesView = patchNotesView

            local newsView = CreateFrame("Frame", nil, f)
            newsView:SetSize(viewWidth, DASHBOARD_VIEW_H)
            newsView:SetPoint("CENTER", viewCenterX, 0)
            newsView:Hide()
            f.newsView = newsView

            local PN_SCROLL_ABOVE_COMMUNITY_FOOTER = (DC.COMMUNITY_FOOTER_SCROLL_GAP) or 24
            local PN_BODY_COL  = { 0.72, 0.72, 0.76, 1 }
            local PN_MUTED_COL = { 0.52, 0.56, 0.62, 1 }
            local PN_SECTION_GAP = 16
            local PN_BULLET_X    = 16
            local PN_LINE_GAP    = 5

            local PN_MODULE_COLORS = {
                ["Essence"]  = "DC143C",
                ["Focus"]    = "FFD133",
                ["Cache"]    = "33CC66",
                ["Presence"] = "33FFDF",
                ["Flow"]     = "3399FF",
                ["Vista"]    = "B366FF",
                ["Insight"]  = "FF66B3",
                ["Axis"]     = "E0E0E0",
            }

            -- Capitalize first letter after "…: " (module prefix) so in-game bullets read consistently.
            local function CapitalizeAfterModulePrefix(text)
                if type(text) ~= "string" or text == "" then return text end
                local pre, first, rest = text:match("^(.-:%s*)(%a)(.*)$")
                if not pre or not first then return text end
                if first ~= string.lower(first) then return text end
                return pre .. string.upper(first) .. rest
            end

            local function ColorModuleNames(text)
                for name, hex in pairs(PN_MODULE_COLORS) do
                    text = text:gsub("%f[%a](" .. name .. ")%f[%A]", "|cFF" .. hex .. "%1|r")
                end
                return text
            end

            -- Community & Support footer (shared factory with Welcome); scroll stops above it.
            local pnCommunityFooterPanel = CreateFrame("Frame", nil, patchNotesView)
            pnCommunityFooterPanel:SetFrameLevel(patchNotesView:GetFrameLevel() + 10)
            local pnCommunityFooterObj = addon.Dashboard_CreateCommunityFooter(pnCommunityFooterPanel, {
                L = L,
                GetAccentColor = GetAccentColor,
                MakeText = MakeText,
                addon = addon,
            })
            tinsert(dashAccentRefs.communityFooterTopRules, pnCommunityFooterObj.footerTopRule)

            local function LayoutPatchNotesFooter()
                local rawW = patchNotesView:GetWidth() or 0
                local w = math.max(280, rawW - 40)
                pnCommunityFooterObj.layout(w, 0, patchNotesView)
            end

            patchNotesView:SetScript("OnSizeChanged", function()
                if patchNotesView:IsShown() then
                    LayoutPatchNotesFooter()
                end
            end)

            local pnScroll = CreateFrame("ScrollFrame", nil, patchNotesView, "UIPanelScrollFrameTemplate")
            pnScroll:SetPoint("TOPLEFT", 40, dashScrollTopOffset)
            pnScroll:SetPoint("BOTTOMLEFT", pnCommunityFooterPanel, "TOPLEFT", 0, PN_SCROLL_ABOVE_COMMUNITY_FOOTER)
            pnScroll:SetPoint("BOTTOMRIGHT", pnCommunityFooterPanel, "TOPRIGHT", 0, PN_SCROLL_ABOVE_COMMUNITY_FOOTER)
            pnScroll.ScrollBar:Hide()
            pnScroll.ScrollBar:ClearAllPoints()

            local pnContent = CreateFrame("Frame", nil, pnScroll)
            pnContent:SetSize(contentWidth, 1)
            pnScroll:SetScrollChild(pnContent)
            addon.Dashboard_ApplySmoothScroll(pnScroll, pnContent, 60, true)
            LayoutPatchNotesFooter()

            f._patchNotesTypoRefs = {}
            f._layoutPatchNotesScroll = function()
                local inner = pnContent._inner
                local layoutItems = f._patchNotesLayoutItems
                if not inner or not layoutItems then return end
                local y = 0
                for _, item in ipairs(layoutItems) do
                    if item.type == "fs" then
                        item.fs:ClearAllPoints()
                        item.fs:SetPoint("TOPLEFT", inner, "TOPLEFT", item.x, y)
                        y = y - math.max(item.fs:GetStringHeight(), 13) - item.gap
                    elseif item.type == "tex" then
                        item.tex:ClearAllPoints()
                        item.tex:SetPoint("TOPLEFT", inner, "TOPLEFT", 0, y)
                        y = y - 1 - item.gap
                    elseif item.type == "gap" then
                        y = y - item.h
                    end
                end
                local totalH = math.max(1, -y)
                inner:SetHeight(totalH)
                pnContent:SetHeight(totalH)
                pnScroll:SetVerticalScroll(0)
            end

            -- Updates widths of all patch notes items without rebuilding content.
            -- Must be called before _layoutPatchNotesScroll so word-wrap heights are correct.
            f._relayoutPatchNotesWidths = function(newW)
                if f._pnContent then
                    f._pnContent:SetWidth(newW)
                    if f._pnContent._inner then
                        f._pnContent._inner:SetWidth(newW)
                    end
                end
                local items = f._patchNotesLayoutItems
                if not items then return end
                for _, item in ipairs(items) do
                    if item.onResize then item.onResize(newW) end
                end
            end

            local pnBuiltVersion = nil

            local function BuildPatchNotesContent(currentVersion)
                -- Orphan previous inner container so its regions don't render
                if pnContent._inner then pnContent._inner:SetParent(nil) end
                wipe(dashAccentRefs.patchNotesSectionLabels)
                wipe(dashAccentRefs.patchNotesBullets)
                wipe(dashAccentRefs.patchNotesRules)
                wipe(f._patchNotesTypoRefs)

                local function ApplyPatchNoteFontString(fs, base, flagsOrNil, widgetChrome)
                    local path = addon.Dashboard_ResolveSavedDashboardFontPath(
                        (addon.GetDB and addon.GetDB("dashboardFontPath", addon.Dashboard_GetDefaultDashboardFontPath())) or addon.Dashboard_GetDefaultDashboardFontPath()
                    )
                    local eff = addon.Dashboard_EffectiveDashboardFontSize(base)
                    local fl
                    if widgetChrome and addon.Dashboard_GetWidgetOutlineFlags then
                        fl = addon.Dashboard_GetWidgetOutlineFlags()
                    else
                        fl = flagsOrNil or ""
                    end
                    pcall(function()
                        fs:SetFont(path, eff, fl)
                    end)
                    if addon.Dashboard_ApplyTextShadow then
                        addon.Dashboard_ApplyTextShadow(fs)
                    end
                    tinsert(f._patchNotesTypoRefs, {
                        fs = fs,
                        base = base,
                        flags = widgetChrome and nil or flagsOrNil,
                        widgetChrome = widgetChrome and true or nil,
                    })
                end

                -- Inner container parented to pnContent (scroll child stays fixed)
                local cW = contentWidth
                local inner = CreateFrame("Frame", nil, pnContent)
                inner:SetWidth(cW)
                inner:SetHeight(1)
                inner:SetPoint("TOPLEFT", pnContent, "TOPLEFT", 0, 0)
                pnContent._inner = inner
                f._pnContent = pnContent

                local items = {}
                local ar, ag, ab = GetAccentColor()
                local hex = string.format("%02X%02X%02X",
                    math.floor(ar*255+0.5), math.floor(ag*255+0.5), math.floor(ab*255+0.5))

                -- Collect all versions in the current major (e.g. 4.x.x) and sort descending
                local curMajor = tonumber(currentVersion:match("^(%d+)")) or 0
                local versions = {}
                if addon.PATCH_NOTES then
                    for v in pairs(addon.PATCH_NOTES) do
                        if (tonumber(v:match("^(%d+)")) or 0) == curMajor then
                            tinsert(versions, v)
                        end
                    end
                end
                table.sort(versions, function(a, b)
                    local a1,a2,a3 = a:match("^(%d+)%.(%d+)%.(%d+)$")
                    local b1,b2,b3 = b:match("^(%d+)%.(%d+)%.(%d+)$")
                    a1,a2,a3 = tonumber(a1) or 0, tonumber(a2) or 0, tonumber(a3) or 0
                    b1,b2,b3 = tonumber(b1) or 0, tonumber(b2) or 0, tonumber(b3) or 0
                    if a1 ~= b1 then return a1 > b1 end
                    if a2 ~= b2 then return a2 > b2 end
                    return a3 > b3
                end)

                if #versions == 0 then
                    local lbl = inner:CreateFontString(nil, "OVERLAY")
                    ApplyPatchNoteFontString(lbl, 12, "")
                    lbl:SetWidth(cW)
                    lbl:SetJustifyH("CENTER")
                    lbl:SetText(L["DASH_PATCH_NOTES_EMPTY"] or "No notes available.")
                    lbl:SetTextColor(unpack(PN_MUTED_COL))
                    tinsert(items, { type = "fs", fs = lbl, x = 0, gap = 0, onResize = function(w) lbl:SetWidth(w) end })
                else
                    for vi, ver in ipairs(versions) do
                        local notes = addon.PATCH_NOTES[ver]
                        if notes then
                            -- Subtle rule between versions
                            if vi > 1 then
                                tinsert(items, { type = "gap", h = 24 })
                                local sep = inner:CreateTexture(nil, "ARTWORK")
                                sep:SetSize(cW, 1)
                                sep:SetColorTexture(ar, ag, ab, 0.15)
                                tinsert(dashAccentRefs.patchNotesRules, sep)
                                tinsert(items, { type = "tex", tex = sep, gap = 18, onResize = function(w) sep:SetWidth(w) end })
                            end

                            -- Version header (optional date from PatchNotesData matches CHANGELOG)
                            local vHdr = inner:CreateFontString(nil, "OVERLAY")
                            ApplyPatchNoteFontString(vHdr, 14, nil, true)
                            vHdr:SetJustifyH("LEFT")
                            local noteDate = notes.date
                            if type(noteDate) == "string" and noteDate ~= "" then
                                local disp = (addon.PatchNotes_FormatIsoDateLongUK and addon.PatchNotes_FormatIsoDateLongUK(noteDate)) or noteDate
                                vHdr:SetText("v" .. ver .. " (" .. disp .. ")")
                            else
                                vHdr:SetText("v" .. ver)
                            end
                            vHdr:SetTextColor(ar, ag, ab)
                            tinsert(dashAccentRefs.patchNotesSectionLabels, vHdr)
                            tinsert(items, { type = "fs", fs = vHdr, x = 0, gap = 14 })

                            -- Sections (no ruled divider — label + spacing carry the hierarchy)
                            for si, sec in ipairs(notes) do
                                if si > 1 then tinsert(items, { type = "gap", h = PN_SECTION_GAP }) end

                                local lbl = inner:CreateFontString(nil, "OVERLAY")
                                ApplyPatchNoteFontString(lbl, 10, nil, true)
                                lbl:SetWidth(cW)
                                lbl:SetJustifyH("LEFT")
                                lbl:SetText(sec.section:upper())
                                lbl:SetTextColor(ar, ag, ab)
                                tinsert(dashAccentRefs.patchNotesSectionLabels, lbl)
                                tinsert(items, { type = "fs", fs = lbl, x = 0, gap = 9, onResize = function(w) lbl:SetWidth(w) end })

                                for _, bullet in ipairs(sec.bullets) do
                                    local txt = inner:CreateFontString(nil, "OVERLAY")
                                    ApplyPatchNoteFontString(txt, 12, "")
                                    txt:SetWidth(cW - PN_BULLET_X)
                                    txt:SetJustifyH("LEFT")
                                    txt:SetWordWrap(true)
                                    local coloredBullet = ColorModuleNames(CapitalizeAfterModulePrefix(bullet))
                                    txt:SetText("|cFF"..hex.."\226\128\148|r  "..coloredBullet)
                                    txt:SetTextColor(unpack(PN_BODY_COL))
                                    tinsert(dashAccentRefs.patchNotesBullets, { fs = txt, bullet = bullet, coloredBullet = coloredBullet })
                                    tinsert(items, { type = "fs", fs = txt, x = PN_BULLET_X, gap = PN_LINE_GAP, onResize = function(w) txt:SetWidth(w - PN_BULLET_X) end })
                                end
                            end
                        end
                    end
                end

                f._patchNotesLayoutItems = items
                C_Timer.After(0, function()
                    if not (patchNotesView and patchNotesView:IsShown()) then return end
                    if f._layoutPatchNotesScroll then f._layoutPatchNotesScroll() end
                end)

                pnBuiltVersion = currentVersion
            end


            -- Back Button (Persistent in Detail View) — parent is main frame so Y matches headSub row across views
            local backBtn = CreateFrame("Button", nil, f)
            backBtn:SetPoint("TOPLEFT", f, "TOPLEFT", dashTitleX, DASH_HEAD_SUBTITLE_Y)
            backBtn:SetFrameLevel(f:GetFrameLevel() + 6)
            backBtn:Hide()

            -- Back Button (Subcategory View)
            local subBackBtn = CreateFrame("Button", nil, f)
            subBackBtn:SetPoint("TOPLEFT", f, "TOPLEFT", dashTitleX, DASH_HEAD_SUBTITLE_Y)
            subBackBtn:SetFrameLevel(f:GetFrameLevel() + 6)
            subBackBtn:Hide()
            
            local function StyleBackButton(btn, textStr)
                btn:SetSize(160, 32)
                
                local icon = btn:CreateTexture(nil, "ARTWORK")
                icon:SetSize(14, 14)
                icon:SetPoint("LEFT", 0, 0)
                icon:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
                icon:SetDesaturated(true)
                icon:SetVertexColor(0.5, 0.5, 0.55)

                local txt = MakeText(btn, textStr, 12, 0.5, 0.5, 0.55, "LEFT")
                txt:SetPoint("LEFT", icon, "RIGHT", 6, 0)

                -- Underline (hidden by default)
                local underline = btn:CreateTexture(nil, "ARTWORK")
                underline:SetHeight(1)
                underline:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -2)
                underline:SetPoint("RIGHT", txt, "RIGHT", 0, 0)
                underline:SetColorTexture(1, 1, 1, 0)
                
                btn:SetScript("OnEnter", function() 
                    local ar, ag, ab = GetAccentColor()
                    txt:SetTextColor(1, 1, 1)
                    icon:SetDesaturated(false)
                    icon:SetVertexColor(ar, ag, ab)
                    underline:SetColorTexture(ar, ag, ab, 0.5)
                end)
                btn:SetScript("OnLeave", function() 
                    txt:SetTextColor(0.5, 0.5, 0.55)
                    icon:SetDesaturated(true)
                    icon:SetVertexColor(0.5, 0.5, 0.55)
                    underline:SetColorTexture(1, 1, 1, 0)
                end)
            end

            StyleBackButton(backBtn, "BACK")
            StyleBackButton(subBackBtn, "BACK")

            local function HideContextHeader()
                backBtn:Hide()
                subBackBtn:Hide()
                detailTitle:Hide()
                detailTitleUnderline:Hide()
            end

            local function ShowDetailHeader()
                backBtn:Show()
                subBackBtn:Hide()
                detailTitle:Show()
                detailTitleUnderline:Show()
            end

            local function ShowSubcategoryHeader()
                subBackBtn:Show()
                backBtn:Hide()
                detailTitle:Show()
                detailTitleUnderline:Show()
            end

            -- Transitions (faster animations per UX feedback)
            local function CrossfadeTo(targetView)
                if targetView ~= patchNotesView then
                    pnChangelogHeaderBtn:Hide()
                end
                dashboardView:Hide()
                detailView:Hide()
                subCategoryView:Hide()
                welcomeView:Hide()
                guideView:Hide()
                patchNotesView:Hide()
                newsView:Hide()
                searchView:Hide()
                if head then head:Hide() end
                if headSub then headSub:Hide() end
                HideContextHeader()

                targetView:SetAlpha(0)
                targetView:Show()
                UIFrameFadeIn(targetView, 0.2, 0, 1)
            end

            f.ShowDashboard = function()
                pnChangelogHeaderBtn:Hide()
                HideContextHeader()
                detailView:Hide()
                subCategoryView:Hide()
                welcomeView:Hide()
                guideView:Hide()
                patchNotesView:Hide()
                newsView:Hide()
                searchView:Hide()
                if f.HideSearchDropdown then f.HideSearchDropdown() end
                if f.DockSearchDropdownForModule then f.DockSearchDropdownForModule() end
                dashboardView:SetAlpha(0)
                dashboardView:Show()
                UIFrameFadeIn(dashboardView, 0.2, 0, 1)
                if head then head:Show() end
                if headSub then
                    headSub:Show()
                    headSub:SetText(L["DASH_HOME_HEAD_SUB"] or "Enable and configure your modules")
                end
                if searchBarShell then searchBarShell:Hide() end
                f.currentModuleKey = nil
                SetSidebarState({ view = "dashboard", activeModuleKey = "axis", activeCategoryIndex = CLEAR })
                if addon.DashboardPreview and addon.DashboardPreview.SetActiveModuleKey then
                    addon.DashboardPreview.SetActiveModuleKey(nil)
                end
                if addon.ApplyDashboardBackground then addon.ApplyDashboardBackground() end
                if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
            end


            local closeBtn = CreateFrame("Button", nil, f)
            closeBtn:SetSize(28, 28)
            closeBtn:SetPoint("TOPRIGHT", -15, -15)
            closeBtn:SetFrameLevel(f:GetFrameLevel() + 10)

            local closeBg = closeBtn:CreateTexture(nil, "BACKGROUND")
            closeBg:SetAllPoints()
            closeBg:SetColorTexture(1, 0.3, 0.3, 0)
            
            local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY")
            do
                local cp = addon.Dashboard_ResolveSavedDashboardFontPath(
                    (addon.GetDB and addon.GetDB("dashboardFontPath", addon.Dashboard_GetDefaultDashboardFontPath())) or addon.Dashboard_GetDefaultDashboardFontPath()
                )
                local ce = addon.Dashboard_EffectiveDashboardFontSize(16)
                local wf = addon.Dashboard_GetWidgetOutlineFlags and addon.Dashboard_GetWidgetOutlineFlags() or "OUTLINE"
                pcall(function()
                    closeTxt:SetFont(cp, ce, wf)
                end)
                if addon.Dashboard_ApplyTextShadow then
                    addon.Dashboard_ApplyTextShadow(closeTxt)
                end
            end
            addon.Dashboard_RegisterTypographyFontString(typoRefs, closeTxt, 16, nil, true)
            closeTxt:SetPoint("CENTER", 0, 0)
            closeTxt:SetText("\195\151")
            closeTxt:SetTextColor(0.5, 0.5, 0.55)
            
            closeBtn:SetScript("OnEnter", function()
                closeTxt:SetTextColor(1, 1, 1)
                closeBg:SetColorTexture(1, 0.3, 0.3, 0.25)
            end)
            closeBtn:SetScript("OnLeave", function()
                closeTxt:SetTextColor(0.5, 0.5, 0.55)
                closeBg:SetColorTexture(1, 0.3, 0.3, 0)
            end)
            closeBtn:SetScript("OnClick", function() f:Hide() end)

            -- Escape to close. SetPropagateKeyboardInput / EnableKeyboard are protected — calling them
            -- during Dashboard_BuildMainFrame from a secure path (e.g. minimap click) causes ADDON_ACTION_BLOCKED.
            local function DashboardApplyKeyboardPropagation()
                if not f or f:IsForbidden() then return end
                if InCombatLockdown() then return end
                pcall(function()
                    if f.EnableKeyboard then
                        f:EnableKeyboard(true)
                    end
                    f:SetPropagateKeyboardInput(true)
                end)
            end

            f._dashboardApplyKeyboardPropagation = DashboardApplyKeyboardPropagation

            f:SetScript("OnKeyDown", function(self, key)
                if key == "ESCAPE" then
                    pcall(function()
                        self:SetPropagateKeyboardInput(false)
                    end)
                    self:Hide()
                else
                    pcall(function()
                        self:SetPropagateKeyboardInput(true)
                    end)
                end
            end)

            C_Timer.After(0, DashboardApplyKeyboardPropagation)
            f:HookScript("OnShow", function()
                C_Timer.After(0, DashboardApplyKeyboardPropagation)
            end)




            local detailEnv = {
                f = f,
                addon = addon,
                L = L,
                detailView = detailView,
                subCategoryView = subCategoryView,
                contentWidth = contentWidth,
                dashScrollTopOffset = dashScrollTopOffset,
                dashScrollTopOffsetModule = dashScrollTopOffsetModule,
                dashAccentRefs = dashAccentRefs,
                GetAccentColor = GetAccentColor,
                MakeText = MakeText,
                OptionCategoryKeyIsAxis = OptionCategoryKeyIsAxis,
                moduleLabels = moduleLabels,
                DASHBOARD_CHILD_PANEL_ALPHA = DASHBOARD_CHILD_PANEL_ALPHA,
                DASHBOARD_CONTENT_CARD_ALPHA_MULT = DASHBOARD_CONTENT_CARD_ALPHA_MULT,
                CLEAR = CLEAR,
                searchBox = searchBox,
                searchBarShell = searchBarShell,
                searchView = searchView,
                searchEmptyHint = searchEmptyHint,
                searchDropdown = searchDropdown,
                searchDropdownScroll = searchDropdownScroll,
                searchDropdownContent = searchDropdownContent,
                searchDropdownCatch = searchDropdownCatch,
                setSidebarState = function() end,
                crossfadeTo = CrossfadeTo,
                showDetailHeader = ShowDetailHeader,
                showSubcategoryHeader = ShowSubcategoryHeader,
            }
            local detailApi = addon.DashboardDetailView_Init(detailEnv)
            f.NavigateToDashboardBackground = detailApi.NavigateToDashboardBackground
            f.NavigateToAxisHome = detailApi.NavigateToAxisHome
            f.NavigateToClassColourTinting = detailApi.NavigateToClassColourTinting

            backBtn:SetScript("OnClick", function()
                if f.currentModuleKey then
                    local mk = f.currentModuleKey
                    local cats = {}
                    for _, cat in ipairs(addon.OptionCategories) do
                        local catMk
                        if OptionCategoryKeyIsAxis(cat.key) then
                            catMk = "axis"
                        else
                            catMk = cat.moduleKey or "modules"
                        end
                        if catMk == mk and cat.options then
                            tinsert(cats, cat)
                        end
                    end
                    if mk ~= "modules" and #cats > 1 then
                        local modName = moduleLabels[mk] or mk
                        f.OpenModule(modName, mk)
                    else
                        f.ShowDashboard()
                    end
                else
                    f.ShowDashboard()
                end
            end)

            subBackBtn:SetScript("OnClick", function() f.ShowDashboard() end)

            local homeEnv = {
                f = f,
                addon = addon,
                L = L,
                contentWidth = contentWidth,
                dashboardView = dashboardView,
                welcomeView = welcomeView,
                newsView = newsView,
                detailView = detailView,
                subCategoryView = subCategoryView,
                patchNotesView = patchNotesView,
                dashScrollTopOffset = dashScrollTopOffset,
                dashAccentRefs = dashAccentRefs,
                GetAccentColor = GetAccentColor,
                MakeText = MakeText,
                MakeDashboardWelcomeMixedScriptText = MakeDashboardWelcomeMixedScriptText,
                moduleLabels = moduleLabels,
                categoryIcons = categoryIcons,
                PREVIEW_MODULE_KEYS = PREVIEW_MODULE_KEYS,
                COMING_SOON_MODULE_KEYS = COMING_SOON_MODULE_KEYS,
                TILE_MODULE_LABEL_COLORS = TILE_MODULE_LABEL_COLORS,
                ShouldShowModuleOnDashboard = ShouldShowModuleOnDashboard,
                DASH_HOME_TILE_W = DASH_HOME_TILE_W,
                DASH_HOME_TILE_H = DASH_HOME_TILE_H,
                DASH_HOME_TILE_GAP = DASH_HOME_TILE_GAP,
                DASH_HOME_TILE_COLS = DASH_HOME_TILE_COLS,
                DASH_HOME_TILE_BG_ALPHA_MULT = DASH_HOME_TILE_BG_ALPHA_MULT,
                DASH_HOME_SKELETON_BG_ALPHA_MULT = DASH_HOME_SKELETON_BG_ALPHA_MULT,
                DASHBOARD_CONTENT_CARD_ALPHA_MULT = DASHBOARD_CONTENT_CARD_ALPHA_MULT,
                HideContextHeader = HideContextHeader,
                setSidebarState = function(s) detailEnv.setSidebarState(s) end,
                CLEAR = CLEAR,
                searchBox = searchBox,
                searchBarShell = searchBarShell,
                head = head,
                headSub = headSub,
                detailNav = detailApi,
            }
            local homeApi = addon.DashboardHomeWelcome_Init(homeEnv)
            homeApi.RefreshDashboardTiles()

            local guideEnv = {
                f = f,
                addon = addon,
                L = L,
                guideView = guideView,
                detailView = detailView,
                subCategoryView = subCategoryView,
                dashboardView = dashboardView,
                welcomeView = welcomeView,
                patchNotesView = patchNotesView,
                dashScrollTopOffset = dashScrollTopOffset,
                dashAccentRefs = dashAccentRefs,
                GetAccentColor = GetAccentColor,
                MakeText = MakeText,
                MakeDashboardWelcomeMixedScriptText = MakeDashboardWelcomeMixedScriptText,
                HideContextHeader = HideContextHeader,
                setSidebarState = function(s) detailEnv.setSidebarState(s) end,
                CLEAR = CLEAR,
                searchBox = searchBox,
                searchBarShell = searchBarShell,
                head = head,
                headSub = headSub,
                DASHBOARD_CONTENT_CARD_ALPHA_MULT = DASHBOARD_CONTENT_CARD_ALPHA_MULT,
                PREVIEW_MODULE_KEYS = PREVIEW_MODULE_KEYS,
                COMING_SOON_MODULE_KEYS = COMING_SOON_MODULE_KEYS,
                -- Embedded mode: guide content rendered inside welcomeView scroll
                guideEmbeddedInWelcome = true,
                guideScrollContent = welcomeView._scrollContent,
            }
            if addon.DashboardModuleGuide_Init then
                addon.DashboardModuleGuide_Init(guideEnv)
            end

            f.ShowPatchNotes = function()
                if addon.PatchNotes_MarkCurrentVersionViewed then
                    addon.PatchNotes_MarkCurrentVersionViewed()
                end
                HideContextHeader()
                detailView:Hide()
                subCategoryView:Hide()
                dashboardView:Hide()
                welcomeView:Hide()
                guideView:Hide()
                searchView:Hide()
                newsView:Hide()
                patchNotesView:SetAlpha(0)
                patchNotesView:Show()
                UIFrameFadeIn(patchNotesView, 0.2, 0, 1)
                if head then head:Show() end
                if headSub then
                    headSub:Show()
                    headSub:SetText(L["DASH_PATCH_NOTES_HEAD_SUB"] or "Release history and recent changes")
                end
                if searchBarShell then searchBarShell:Hide() end
                if f.HideSearchDropdown then f.HideSearchDropdown() end
                if f.DockSearchDropdownForModule then f.DockSearchDropdownForModule() end

                local gm = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
                local ver = (gm and gm(addon.ADDON_NAME or "HorizonSuite", "Version")) or ""
                local notes = addon.PATCH_NOTES
                local targetVer = ver ~= "" and ver or (notes and next(notes) or "")
                if pnBuiltVersion ~= targetVer then
                    BuildPatchNotesContent(targetVer)
                end

                local patchNotesTitle = string.upper(L["DASH_WHATS_NEW"] or "Patch Notes")
                detailTitle:SetText(patchNotesTitle .. (ver ~= "" and ("  |cFF888899v"..ver.."|r") or ""))
                detailTitle:Show()
                detailTitleUnderline:Show()

                f.currentModuleKey = nil
                SetSidebarState({ view = "whatsnew", activeModuleKey = CLEAR, activeCategoryIndex = CLEAR })
                if addon.DashboardPreview and addon.DashboardPreview.SetActiveModuleKey then
                    addon.DashboardPreview.SetActiveModuleKey(nil)
                end
                if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end

                pnChangelogHeaderBtn:Show()

                -- Hide centered head/headSub when the frame is too narrow; the flanking
                -- detailTitle and pnChangelogHeaderBtn overlap them below 800px.
                if f:GetWidth() < 850 then
                    if head    then head:Hide()    end
                    if headSub then headSub:Hide() end
                end

                LayoutPatchNotesFooter()
                if C_Timer and C_Timer.After then
                    C_Timer.After(0, LayoutPatchNotesFooter)
                    C_Timer.After(0.05, LayoutPatchNotesFooter)
                end
            end

            f.ShowNews = function()
                HideContextHeader()
                detailView:Hide()
                subCategoryView:Hide()
                dashboardView:Hide()
                welcomeView:Hide()
                patchNotesView:Hide()
                guideView:Hide()
                searchView:Hide()
                newsView:SetAlpha(0)
                newsView:Show()
                UIFrameFadeIn(newsView, 0.2, 0, 1)
                if head then head:Show() end
                if headSub then
                    headSub:Show()
                    headSub:SetText(L["DASH_NEWS_HEAD_SUB"] or "Latest updates & community highlights")
                end
                if searchBarShell then searchBarShell:Hide() end
                if f.HideSearchDropdown then f.HideSearchDropdown() end
                if f.DockSearchDropdownForModule then f.DockSearchDropdownForModule() end
                f.currentModuleKey = nil
                SetSidebarState({ view = "news", activeModuleKey = CLEAR, activeCategoryIndex = CLEAR })
                if addon.DashboardPreview and addon.DashboardPreview.SetActiveModuleKey then
                    addon.DashboardPreview.SetActiveModuleKey(nil)
                end
                if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
            end

            --- Dedicated Search page: sidebar entry; embedded results panel under the search bar.
            f.ShowSearch = function()
                pnChangelogHeaderBtn:Hide()
                HideContextHeader()
                detailView:Hide()
                subCategoryView:Hide()
                dashboardView:Hide()
                welcomeView:Hide()
                guideView:Hide()
                patchNotesView:Hide()
                newsView:Hide()
                if f.HideSearchDropdown then f.HideSearchDropdown() end
                if searchBox then
                    searchBox:SetText("")
                    searchBox:ClearFocus()
                end
                if searchClearBtn then searchClearBtn:Hide() end
                if sbPlaceholder then sbPlaceholder:Show() end
                CrossfadeTo(searchView)
                if head then head:Show() end
                if headSub then
                    headSub:Show()
                    headSub:SetText(L["DASH_SEARCH_HEAD_SUB"] or "Find any setting quickly")
                end
                if searchBarShell then searchBarShell:Show() end
                if f.searchEmptyHint then
                    f.searchEmptyHint:SetText(L["DASH_SEARCH_EMPTY_HINT"] or "Type at least two characters to search settings, modules, and options.")
                    f.searchEmptyHint:Show()
                end
                if f.DockSearchDropdownForSearchView then f.DockSearchDropdownForSearchView() end
                detailTitle:Hide()
                detailTitleUnderline:Hide()
                backBtn:Hide()
                subBackBtn:Hide()
                f.currentModuleKey = nil
                SetSidebarState({ view = "search", activeModuleKey = CLEAR, activeCategoryIndex = CLEAR })
                if addon.DashboardPreview and addon.DashboardPreview.SetActiveModuleKey then
                    addon.DashboardPreview.SetActiveModuleKey(nil)
                end
                if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
            end

            -- ===== POPULATE SIDEBAR =====
            -- Group categories by moduleKey; build all groups so we can show/hide on refresh.
            local MODULE_LABELS = { ["axis"] = addon.Dashboard_BrandModule("axis") or "Axis", ["modules"] = L["OPTIONS_AXIS_MODULES"] or "Modules", ["focus"] = addon.Dashboard_BrandModule("focus"), ["presence"] = addon.Dashboard_BrandModule("presence"), ["insight"] = addon.Dashboard_BrandModule("insight"), ["cache"] = addon.Dashboard_BrandModule("cache"), ["vista"] = addon.Dashboard_BrandModule("vista"), ["essence"] = addon.Dashboard_BrandModule("essence"), ["meridian"] = addon.Dashboard_BrandModule("meridian") }
            local groups = {}
            for i, cat in ipairs(addon.OptionCategories) do
                local mk
                if OptionCategoryKeyIsAxis(cat.key) then
                    mk = "axis"
                else
                    mk = cat.moduleKey or "modules"
                end
                if not groups[mk] then groups[mk] = { label = MODULE_LABELS[mk] or L["OPTIONS_FOCUS_OTHER"], categories = {} } end
                tinsert(groups[mk].categories, i)
            end
            local groupOrder = { "axis", "focus", "insight", "essence", "presence", "vista", "cache" }
            local sidebarRows = {}

            local function ShouldShowDashboardSubcategory(mk, cat)
                if not cat then return false end
                if mk == "axis" and cat.key == "Modules" then
                    return false
                end
                return true
            end

            local lastSidebarRow = nil
            local yOff = 0

            -- Welcome (first row — overview for new and returning users)
            local welcomeBtn = CreateSidebarButton(sidebarScrollContent, L["DASH_WELCOME_TAB"] or "Welcome", "INV_Misc_Book_09", function()
                if f.ShowWelcome then f.ShowWelcome() end
            end)
            welcomeBtn:SetPoint("TOPLEFT", sidebarScrollContent, "TOPLEFT", 0, -SIDEBAR_TOP_PAD)
            f.welcomeSidebarBtn = welcomeBtn
            tinsert(sidebarButtons, welcomeBtn)
            tinsert(sidebarRows, { type = "welcome", frame = welcomeBtn, bottom = welcomeBtn, offsetFromPrev = -SIDEBAR_TOP_PAD })
            lastSidebarRow = welcomeBtn
            yOff = SIDEBAR_TOP_PAD + TAB_ROW_HEIGHT

            -- News (Blizzard atlas; same family as Focus campaign quest icon; fallback if atlas fails)
            local newsBtn = CreateSidebarButton(sidebarScrollContent, L["DASH_NEWS_TAB"] or "News", {
                atlas = "Quest-Campaign-Available",
                fallback = "INV_Misc_StarFall_Blue",
            }, function()
                if f.ShowNews then f.ShowNews() end
            end)
            newsBtn:SetPoint("TOPLEFT", welcomeBtn, "BOTTOMLEFT", 0, 0)
            f.newsSidebarBtn = newsBtn
            tinsert(sidebarButtons, newsBtn)
            tinsert(sidebarRows, { type = "news", frame = newsBtn, bottom = newsBtn, offsetFromPrev = 0 })
            lastSidebarRow = newsBtn
            yOff = yOff + TAB_ROW_HEIGHT

            -- Patch Notes (pinned bottom) + Search (pinned above Patch Notes)
            local whatsNewBase = L["DASH_WHATS_NEW"] or "What's New"
            local whatsNewBtn = CreateBottomPinnedButton(whatsNewBase, "INV_Scroll_05", function()
                if addon.PatchNotes_MarkWhatsNewSidebarClicked then
                    addon.PatchNotes_MarkWhatsNewSidebarClicked()
                end
                if f.ShowPatchNotes then f.ShowPatchNotes() end
            end, 0)
            whatsNewBtn._whatsNewBaseText = whatsNewBase
            whatsNewBtn._patchNotesSidebarRowStyle = true
            whatsNewBtn._sidebarViewGetter = function() return sidebarState.view end
            f.whatsnewSidebarBtn = whatsNewBtn

            local searchSidebarBtn = CreateBottomPinnedButton(L["DASH_SEARCH_TAB"] or "Search", "INV_Misc_Spyglass_03", function()
                if f.ShowSearch then f.ShowSearch() end
            end, TAB_ROW_HEIGHT)
            f.searchSidebarBtn = searchSidebarBtn
            -- Note: pinned buttons NOT in sidebarButtons or sidebarRows

            -- Separator (anchored to sep row; reflows with RefreshSidebar)
            yOff = yOff + 9
            lastSidebarRow = CreateFrame("Frame", nil, sidebarScrollContent)
            lastSidebarRow:SetPoint("TOPLEFT", sidebarScrollContent, "TOPLEFT", 0, -yOff)
            lastSidebarRow:SetSize(1, 1)
            local sbSep = sidebarScrollContent:CreateTexture(nil, "ARTWORK")
            sbSep:SetHeight(1)
            sbSep:SetPoint("BOTTOMLEFT", lastSidebarRow, "TOPLEFT", 15, 8)
            sbSep:SetPoint("BOTTOMRIGHT", lastSidebarRow, "TOPRIGHT", -15, 8)
            sbSep:SetColorTexture(0.15, 0.15, 0.2, 1)
            tinsert(sidebarRows, { type = "sep", frame = lastSidebarRow, bottom = lastSidebarRow, offsetFromPrev = -9 })

            -- Per-group: standalone (single category) or header + collapsible sub-buttons
            for _, mk in ipairs(groupOrder) do
                local g = groups[mk]
                if not g or #g.categories == 0 then
                    -- skip empty groups
                else
                    local isStandalone = (mk == "modules" and #g.categories == 1)
                    local modName = MODULE_LABELS[mk] or mk
                    local visibleCategoryCount = 0
                    for _, catIdx in ipairs(g.categories) do
                        local cat = addon.OptionCategories[catIdx]
                        if ShouldShowDashboardSubcategory(mk, cat) then
                            visibleCategoryCount = visibleCategoryCount + 1
                        end
                    end

                    if isStandalone then
                        local catIdx = g.categories[1]
                        local cat = addon.OptionCategories[catIdx]
                        local iconKey = categoryIcons[cat.key] or "INV_Misc_Question_01"
                        local btn = CreateSidebarButton(sidebarScrollContent, cat.name, iconKey, function()
                            f.OpenModule(cat.name, cat.moduleKey or mk)
                        end)
                        btn:SetPoint("TOPLEFT", lastSidebarRow, "BOTTOMLEFT", 0, 0)
                        lastSidebarRow = btn
                        yOff = yOff + TAB_ROW_HEIGHT
                        btn.sidebarModuleKey = cat.moduleKey
                        btn.sidebarName = cat.name
                        btn.sidebarCategoryIndex = catIdx
                        btn:SetShown(ShouldShowModuleOnDashboard(mk))
                        g.row = { type = "group", mk = mk, frame = btn, bottom = btn, offsetFromPrev = 0 }
                        tinsert(sidebarRows, g.row)
                        tinsert(sidebarButtons, btn)
                    else
                        -- Header row (clickable, collapsible)
                        local prevLastRow = lastSidebarRow
                        local header = CreateFrame("Button", nil, sidebarScrollContent)
                        header:SetSize(SIDEBAR_WIDTH - 1, HEADER_ROW_HEIGHT)
                        header:SetPoint("TOPLEFT", lastSidebarRow, "BOTTOMLEFT", 0, 0)
                        lastSidebarRow = header
                        yOff = yOff + HEADER_ROW_HEIGHT
                        header.groupKey = mk
                        g.header = header
                        local headerBtnBg = header:CreateTexture(nil, "BACKGROUND")
                        headerBtnBg:SetAllPoints()
                        headerBtnBg:SetColorTexture(0, 0, 0, 0)
                        header.btnBg = headerBtnBg
                        local headerAccent = header:CreateTexture(nil, "ARTWORK")
                        headerAccent:SetSize(3, 22)
                        headerAccent:SetPoint("LEFT", header, "LEFT", 4, 0)
                        local har, hag, hab = GetAccentColor()
                        headerAccent:SetColorTexture(har, hag, hab, 1)
                        headerAccent:Hide()
                        header.accentBar = headerAccent
                        tinsert(dashAccentRefs.sidebarBars, headerAccent)
                        local chevron = header:CreateFontString(nil, "OVERLAY")
                        do
                            local hp = addon.Dashboard_ResolveSavedDashboardFontPath(
                                (addon.GetDB and addon.GetDB("dashboardFontPath", addon.Dashboard_GetDefaultDashboardFontPath())) or addon.Dashboard_GetDefaultDashboardFontPath()
                            )
                            local he1 = addon.Dashboard_EffectiveDashboardFontSize(11)
                            local wf = addon.Dashboard_GetWidgetOutlineFlags and addon.Dashboard_GetWidgetOutlineFlags() or "OUTLINE"
                            pcall(function()
                                chevron:SetFont(hp, he1, wf)
                            end)
                            if addon.Dashboard_ApplyTextShadow then
                                addon.Dashboard_ApplyTextShadow(chevron)
                            end
                        end
                        addon.Dashboard_RegisterTypographyFontString(typoRefs, chevron, 11, nil, true)
                        chevron:SetPoint("LEFT", header, "LEFT", 8, 0)
                        chevron:SetTextColor(0.55, 0.55, 0.65, 1)
                        header.chevron = chevron
                        local headerLabel = header:CreateFontString(nil, "OVERLAY")
                        do
                            local hp = addon.Dashboard_ResolveSavedDashboardFontPath(
                                (addon.GetDB and addon.GetDB("dashboardFontPath", addon.Dashboard_GetDefaultDashboardFontPath())) or addon.Dashboard_GetDefaultDashboardFontPath()
                            )
                            local he2 = addon.Dashboard_EffectiveDashboardFontSize(12)
                            local wf = addon.Dashboard_GetWidgetOutlineFlags and addon.Dashboard_GetWidgetOutlineFlags() or "OUTLINE"
                            pcall(function()
                                headerLabel:SetFont(hp, he2, wf)
                            end)
                            if addon.Dashboard_ApplyTextShadow then
                                addon.Dashboard_ApplyTextShadow(headerLabel)
                            end
                        end
                        addon.Dashboard_RegisterTypographyFontString(typoRefs, headerLabel, 12, nil, true)
                        headerLabel:SetPoint("LEFT", chevron, "RIGHT", 4, 0)
                        headerLabel:SetTextColor(0.55, 0.55, 0.65, 1)
                        local headerLabelText = (g.label or ""):upper()
                        if PREVIEW_MODULE_KEYS[mk] then
                            headerLabelText = headerLabelText .. " |cff228b22(Preview)|r"
                        end
                        headerLabel:SetText(headerLabelText)
                        header.headerLabel = headerLabel
                        header.label = headerLabel

                        local tabsContainer = CreateFrame("Frame", nil, sidebarScrollContent)
                        tabsContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
                        tabsContainer:SetWidth(SIDEBAR_WIDTH - 1)
                        tabsContainer:SetClipsChildren(true)
                        local fullHeight = TAB_ROW_HEIGHT * visibleCategoryCount
                        local startCollapsed = GetGroupCollapsed(mk)
                        tabsContainer:SetHeight(startCollapsed and 0 or fullHeight)
                        g.tabsContainer = tabsContainer
                        g.fullHeight = fullHeight

                        local spacer = CreateFrame("Frame", nil, sidebarScrollContent)
                        spacer:SetSize(2, 2)
                        spacer:SetAlpha(0)
                        local function UpdateSpacerPosition()
                            spacer:ClearAllPoints()
                            spacer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -tabsContainer:GetHeight())
                        end
                        header.updateSpacer = UpdateSpacerPosition
                        UpdateSpacerPosition()
                        lastSidebarRow = spacer
                        yOff = yOff + tabsContainer:GetHeight()

                        local show = ShouldShowModuleOnDashboard(mk)
                        header:SetShown(show)
                        tabsContainer:SetShown(show)
                        spacer:SetShown(show)
                        if not show then lastSidebarRow = prevLastRow end
                        g.row = { type = "group", mk = mk, header = header, tabsContainer = tabsContainer, spacer = spacer, bottom = spacer, offsetFromPrev = 0 }
                        tinsert(sidebarRows, g.row)

                        header:SetScript("OnClick", function()
                            if mk == "axis" then
                                f.ShowDashboard()
                            else
                                f.OpenModule(modName, mk)
                            end
                        end)
                        header:SetScript("OnEnter", function()
                            if header ~= dashSession.activeSidebarBtn then
                                headerBtnBg:SetColorTexture(0.1, 0.1, 0.12, DASHBOARD_CHILD_PANEL_ALPHA)
                                headerLabel:SetTextColor(0.8, 0.8, 0.85, 1)
                                chevron:SetTextColor(0.8, 0.8, 0.85, 1)
                            end
                        end)
                        header:SetScript("OnLeave", function()
                            if header ~= dashSession.activeSidebarBtn then
                                headerBtnBg:SetColorTexture(0, 0, 0, 0)
                                headerLabel:SetTextColor(0.55, 0.55, 0.65, 1)
                                chevron:SetTextColor(0.55, 0.55, 0.65, 1)
                            end
                        end)
                        chevron:SetText(GetGroupCollapsed(mk) and "+" or "-")

                        local containerAnchor = tabsContainer
                        for _, catIdx in ipairs(g.categories) do
                            local cat = addon.OptionCategories[catIdx]
                            if ShouldShowDashboardSubcategory(mk, cat) then
                                local modLabel = moduleLabels[mk] or (cat.moduleKey and (moduleLabels[cat.moduleKey] or cat.moduleKey)) or modName
                                local catMk = (mk == "axis") and "axis" or cat.moduleKey
                                local btn = CreateSidebarButton(tabsContainer, cat.name, nil, function()
                                    f.OpenModule(modLabel, catMk, true)
                                    local options = type(cat.options) == "function" and cat.options() or cat.options
                                    f.OpenCategoryDetail(modLabel, cat.name, options)
                                end, 12)
                                btn:SetPoint("TOPLEFT", containerAnchor, (containerAnchor == tabsContainer) and "TOPLEFT" or "BOTTOMLEFT", 0, 0)
                                containerAnchor = btn
                                btn.sidebarModuleKey = catMk
                                btn.sidebarName = cat.name
                                btn.sidebarCategoryIndex = catIdx
                                tinsert(sidebarButtons, btn)
                            end
                        end

                        if startCollapsed then
                            SetGroupChildrenShown(g, false)
                        end
                    end
                end
            end

            if addon.PatchNotes_RefreshAttentionIndicators then
                addon.PatchNotes_RefreshAttentionIndicators()
            end

            --- Reflow sidebar scroll content height from top to last row.
            local function LayoutSidebar()
                if not sidebarScrollContent or not lastSidebarRow then return end
                local top = sidebarScrollContent:GetTop()
                local bottom = lastSidebarRow:GetBottom()
                if top and bottom then
                    local h = math.max(1, top - bottom + SIDEBAR_TOP_PAD)
                    sidebarScrollContent:SetHeight(h)
                end
            end

            --- Apply sidebarState to UI: active button, expanded groups, spacers.
            local function ApplySidebarState()
                local targetMk = sidebarState.activeModuleKey
                for _, mk in ipairs(groupOrder) do
                    local g = groups[mk]
                    if g and g.tabsContainer and g.fullHeight then
                        if targetMk and mk == targetMk then
                            SetGroupCollapsed(mk, false)
                            g.tabsContainer:SetScript("OnUpdate", nil)
                            g.tabsContainer:SetHeight(g.fullHeight)
                            SetGroupChildrenShown(g, true)
                            if g.header and g.header.chevron then g.header.chevron:SetText("-") end
                        elseif not GetGroupCollapsed(mk) then
                            SetGroupCollapsed(mk, true)
                            g.tabsContainer:SetScript("OnUpdate", nil)
                            g.tabsContainer:SetHeight(0)
                            SetGroupChildrenShown(g, false)
                            if g.header and g.header.chevron then g.header.chevron:SetText("+") end
                        end
                        if g.header and g.header.updateSpacer then g.header.updateSpacer() end
                    end
                end
                local activeBtn = f.welcomeSidebarBtn or sidebarButtons[1]
                if sidebarState.view == "welcome" and f.welcomeSidebarBtn then
                    activeBtn = f.welcomeSidebarBtn
                elseif sidebarState.view == "news" and f.newsSidebarBtn then
                    activeBtn = f.newsSidebarBtn
                elseif sidebarState.view == "search" and f.searchSidebarBtn then
                    activeBtn = f.searchSidebarBtn
                elseif sidebarState.view == "whatsnew" and f.whatsnewSidebarBtn then
                    activeBtn = f.whatsnewSidebarBtn
                elseif sidebarState.view == "dashboard" then
                    -- Home (module toggles): Axis hub context — expand group via activeModuleKey; highlight Axis header
                    if sidebarState.activeModuleKey == "axis" then
                        local gAxis = groups["axis"]
                        if gAxis and gAxis.header then
                            activeBtn = gAxis.header
                        else
                            activeBtn = nil
                        end
                    else
                        activeBtn = nil
                    end
                elseif sidebarState.view == "module" or sidebarState.view == "category" then
                    local mk = sidebarState.activeModuleKey or "modules"
                    local wantCatIdx = sidebarState.activeCategoryIndex
                    local picked = false
                    -- Module landing (category tiles): highlight the group header, not the first sub-row.
                    if sidebarState.view == "module" and not wantCatIdx and subCategoryView:IsShown() then
                        local g = groups[mk]
                        if g and g.header and g.header.accentBar then
                            activeBtn = g.header
                            picked = true
                        end
                    end
                    if not picked then
                        for _, sb in ipairs(sidebarButtons) do
                            if sb.sidebarCategoryIndex then
                                local sbMk = sb.sidebarModuleKey or "modules"
                                if sbMk == mk then
                                    if wantCatIdx and sb.sidebarCategoryIndex == wantCatIdx then
                                        activeBtn = sb
                                        break
                                    elseif not wantCatIdx then
                                        activeBtn = sb
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                SetActiveSidebarButton(activeBtn)
                if addon.PatchNotes_RefreshAttentionIndicators then
                    addon.PatchNotes_RefreshAttentionIndicators()
                end
                LayoutSidebar()
                if C_Timer and C_Timer.After then
                    C_Timer.After(0, function() LayoutSidebar() end)
                end
            end

            --- Update sidebar state and apply to UI. Single entry point for navigation.
            --- @param state table { view?, activeModuleKey?, activeCategoryIndex? }
            --- Use CLEAR to explicitly clear a field; omit keys to leave unchanged.
            SetSidebarState = function(state)
                if state.view then sidebarState.view = state.view end
                if state.activeModuleKey == CLEAR then sidebarState.activeModuleKey = nil
                elseif state.activeModuleKey ~= nil then sidebarState.activeModuleKey = state.activeModuleKey end
                if state.activeCategoryIndex == CLEAR then sidebarState.activeCategoryIndex = nil
                elseif state.activeCategoryIndex ~= nil then sidebarState.activeCategoryIndex = state.activeCategoryIndex end
                ApplySidebarState()
            end

            detailEnv.setSidebarState = SetSidebarState

            --- Refresh sidebar visibility and reflow when modules are toggled.
            local function RefreshSidebar()
                for _, row in ipairs(sidebarRows) do
                    if row.type == "group" and row.mk then
                        local show = ShouldShowModuleOnDashboard(row.mk)
                        if row.frame then
                            row.frame:SetShown(show)
                        elseif row.header then
                            row.header:SetShown(show)
                            row.tabsContainer:SetShown(show)
                            row.spacer:SetShown(show)
                        end
                        row._visible = show
                    else
                        row._visible = true
                    end
                end
                local prev = sidebarScrollContent
                for _, row in ipairs(sidebarRows) do
                    if not row._visible then
                        -- skip hidden rows
                    else
                        local topFrame = row.frame or row.header
                        local bottomFrame = row.bottom
                        local off = row.offsetFromPrev or 0
                        if topFrame and bottomFrame then
                            topFrame:ClearAllPoints()
                            if prev == sidebarScrollContent then
                                topFrame:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, off)
                            else
                                topFrame:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, off)
                            end
                            prev = bottomFrame
                        end
                    end
                end
                lastSidebarRow = prev
                LayoutSidebar()
                if C_Timer and C_Timer.After then
                    C_Timer.After(0, function() LayoutSidebar() end)
                end
            end

            --- Live refresh when modules are toggled (called from SetModuleEnabled).
            addon.Dashboard_Refresh = function()
                if not f or not f:IsShown() then return end
                homeApi.RefreshDashboardTiles()
                RefreshSidebar()
                if sidebarState.view == "dashboard" and sidebarState.activeModuleKey and not ShouldShowModuleOnDashboard(sidebarState.activeModuleKey) then
                    f.ShowDashboard()
                end
                if f._dashboardRelayoutDetailCards then
                    f._dashboardRelayoutDetailCards()
                end
            end

            LayoutSidebar()
            RefreshSidebar()

            -- ==================================================================
            -- RESIZE GRABBER + Dashboard_CommitResize
            -- ==================================================================

            -- All view sub-frames that must be resized together.
            local _resizeViews = {
                dashboardView, detailView, subCategoryView,
                searchView, welcomeView, guideView, patchNotesView, newsView,
            }

            --- Resize + reflow the dashboard to a new size ratio without navigating.
            --- ratio: 0.5 – 2.0 (1.0 = native 1280×720)
            --- skipHeavy: when true, skips typography walk and detail card reflow (used during
            ---   live drag to reduce per-frame cost; always false on DragStop and panel open).
            --- @param ratio number
            --- @param skipHeavy boolean|nil
            local function Dashboard_CommitResize(ratio, skipHeavy)
                ratio = math.max(0.5, math.min(2.0, ratio or 1.0))

                local lc = DC.GetLayoutConstants(ratio)
                local newW = lc.frameW
                local newH = lc.frameH

                -- 1. Frame size
                f:SetSize(newW, newH)

                -- 2. All view sub-frames
                for _, v in ipairs(_resizeViews) do
                    v:SetSize(lc.viewWidth, lc.viewH)
                    v:ClearAllPoints()
                    v:SetPoint("CENTER", f, "CENTER", lc.viewCenterX, 0)
                end

                -- 3. Sidebar width — fixed; does not scale with the dashboard ratio
                sidebar:SetWidth(DC.SIDEBAR_NATIVE_W)

                -- 4. Content scroll widths and header text re-anchors
                if detailTitleUnderline then
                    detailTitleUnderline:SetWidth(math.max(1, lc.viewWidth - 80))
                end
                if head then
                    head:ClearAllPoints()
                    head:SetPoint("TOP", lc.contentOffset / 2, DASH_HEAD_TITLE_Y)
                end
                if headSub then
                    headSub:ClearAllPoints()
                    headSub:SetPoint("TOP", lc.contentOffset / 2, DASH_HEAD_SUBTITLE_Y)
                end
                -- Patch notes: detailTitle (left) and pnChangelogHeaderBtn (right) overlap
                -- the centered head/headSub below 800px.  Hide them when that narrow.
                if pnChangelogHeaderBtn and pnChangelogHeaderBtn:IsShown() then
                    if lc.frameW < 850 then
                        if head    then head:Hide()    end
                        if headSub then headSub:Hide() end
                    else
                        if head    then head:Show() end
                        if headSub then headSub:Show() end
                    end
                end
                if f.searchBarShell then
                    local searchW = math.min(DASH_SEARCH_BAR_MAX_W, math.max(300, math.floor(lc.viewWidth * 0.65)))
                    f.searchBarShell:SetWidth(searchW)
                    f.searchBarShell:ClearAllPoints()
                    f.searchBarShell:SetPoint("TOP", lc.contentOffset / 2, DASH_SEARCH_Y - DASH_SEARCH_BAR_TOP_NUDGE)
                end
                if searchDropdown then
                    local searchW = math.min(DASH_SEARCH_BAR_MAX_W, math.max(300, math.floor(lc.viewWidth * 0.65)))
                    searchDropdown:SetWidth(searchW)
                    if searchDropdownContent then
                        searchDropdownContent:SetWidth(math.max(1, searchW - 24))
                    end
                end
                if searchEmptyHint then
                    searchEmptyHint:SetWidth(math.max(200, lc.contentWidth - 48))
                end
                if detailTitle then
                    detailTitle:ClearAllPoints()
                    detailTitle:SetPoint("TOPLEFT", f, "TOPLEFT", lc.dashTitleX, DASH_HEAD_TITLE_Y)
                end

                -- 5. Reflow toggle cards and tile grids: dashboardView OnSizeChanged handles them.
                --    Trigger by letting the view report its new width.
                dashboardView:SetWidth(lc.viewWidth)

                -- 5b. Reflow welcome-style views (welcome, news).
                -- OnSizeChanged can fire while anchors are mid-swap in the loop above,
                -- causing welcomeBg:GetWidth() to return 0 and content to snap to
                -- the 280px minimum.  Call _layoutWelcomeContent directly now that
                -- all SetSize/SetPoint calls are settled.
                for _, v in ipairs(_resizeViews) do
                    if v._layoutWelcomeContent and v:IsShown() then
                        v._layoutWelcomeContent()
                    end
                end

                -- 6. Reposition and resize grabber (defined below; forward-ref via f._resizeGrabber)
                local grabber = f._resizeGrabber
                if grabber then
                    grabber:ClearAllPoints()
                    grabber:SetSize(22, 22)
                    grabber:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)
                end

                -- 7. Update DashboardCtx.layout
                if addon.DashboardCtx then
                    addon.DashboardCtx.frame = f
                    addon.DashboardCtx.layout = {
                        contentWidth      = lc.contentWidth,
                        dashScrollTopOffset = lc.dashScrollTopOffset,
                        viewWidth         = lc.viewWidth,
                        viewCenterX       = lc.viewCenterX,
                        dashTitleX        = lc.dashTitleX,
                    }
                end

                -- 8. Typography (skipped during live drag — runs on DragStop)
                if not skipHeavy and addon.ApplyDashboardTypography then
                    addon.ApplyDashboardTypography()
                end

                -- 9. Detail cards reflow (skipped during live drag — runs on DragStop)
                if not skipHeavy and f._dashboardRelayoutDetailCards then
                    f._dashboardRelayoutDetailCards()
                end

                -- 10. Patch notes content reflow (skipped during live drag — runs on DragStop)
                if not skipHeavy then
                    if f._relayoutPatchNotesWidths then
                        f._relayoutPatchNotesWidths(lc.contentWidth)
                    end
                    if f._layoutPatchNotesScroll then
                        f._layoutPatchNotesScroll()
                    end
                end
            end

            f.Dashboard_CommitResize = Dashboard_CommitResize

            -- ------------------------------------------------------------------
            -- Grabber button — bottom-right corner drag handle
            -- Must sit above all descendant content (footer panels are view:GetFrameLevel()+10,
            -- so footer can reach f:GetFrameLevel()+11+).  Use +20 to clear any child stacking.
            -- Strata: HIGH.  NEVER TOOLTIP strata.
            -- ------------------------------------------------------------------
            local grabber = CreateFrame("Button", nil, f)
            grabber:SetSize(22, 22)
            grabber:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)
            grabber:SetFrameStrata("HIGH")
            grabber:SetFrameLevel(f:GetFrameLevel() + 20)
            grabber:RegisterForDrag("LeftButton")
            grabber:EnableMouse(true)
            f._resizeGrabber = grabber

            -- Traditional resize grip: three parallel diagonal lines pointing toward the corner.
            -- Lines run at 45° from upper-left to lower-right (toward the bottom-right corner).
            local _gripLines = {}
            local function makeGripLine(x1, y1, x2, y2)
                local ln = grabber:CreateLine(nil, "OVERLAY")
                ln:SetThickness(1.5)
                ln:SetColorTexture(0.6, 0.6, 0.75, 0.6)
                ln:SetStartPoint("BOTTOMRIGHT", grabber, x1, y1)
                ln:SetEndPoint("BOTTOMRIGHT", grabber, x2, y2)
                _gripLines[#_gripLines + 1] = ln
            end
            makeGripLine(-2, 8,  -8,  2)    -- inner line (nearest corner)
            makeGripLine(-2, 14, -14, 2)    -- middle line
            makeGripLine(-2, 20, -20, 2)    -- outer line

            local function setGripAlpha(a)
                for i = 1, #_gripLines do
                    _gripLines[i]:SetColorTexture(0.6, 0.6, 0.75, a)
                end
            end

            -- Drag state
            local _dragPinX, _dragPinY   -- frame TOPLEFT in UIParent-space at DragStart
            local _dragActive  = false
            local _lastReflow  = 0       -- throttle: GetTime() of last reflow during drag

            grabber:SetScript("OnDragStart", function(self)
                if InCombatLockdown() then return end
                local fl = f:GetLeft()
                local ft = f:GetTop()
                if not fl or not ft then return end  -- frame not yet laid out; abort

                -- Pin the anchor to TOPLEFT so SetSize grows bottom-right only.
                -- The top-left corner stays perfectly still throughout the drag.
                f:ClearAllPoints()
                f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", fl, ft)

                _dragPinX   = fl
                _dragPinY   = ft
                _dragActive = true
                _lastReflow = 0
                setGripAlpha(1.0)
            end)

            grabber:SetScript("OnDragStop", function(self)
                if not _dragActive then return end
                _dragActive = false

                -- Final ratio from cursor position at release.
                local uiScale = UIParent:GetEffectiveScale()
                local cx      = select(1, GetCursorPosition())
                local curX    = cx / uiScale
                local targetW = math.max(640, curX - _dragPinX)
                local ratio   = math.max(0.5, math.min(2.0, targetW / DC.NATIVE_W))

                -- Auto-shrink: clamp so the frame fits within UIParent.
                local maxW = UIParent:GetWidth()
                local maxH = UIParent:GetHeight()
                if maxW and maxW > 0 then ratio = math.min(ratio, maxW / DC.NATIVE_W) end
                if maxH and maxH > 0 then ratio = math.min(ratio, maxH / DC.NATIVE_H) end
                ratio = math.max(0.5, ratio)

                -- Persist to DB (root-level keys, raw access).
                local db = _G[addon.DB_NAME]
                if db then
                    db.dashboardSizeRatio = ratio
                    db.dashboardTopLeftX  = _dragPinX
                    db.dashboardTopLeftY  = _dragPinY
                end

                Dashboard_CommitResize(ratio)
                setGripAlpha(0.6)
            end)

            grabber:SetScript("OnUpdate", function(self)
                if not _dragActive then return end

                -- Throttle reflow to ~20 Hz to keep the drag smooth without
                -- hammering layout every frame.
                local now = GetTime()
                if now - _lastReflow < 0.05 then return end
                _lastReflow = now

                -- Target width = distance from the pinned left edge to the cursor.
                -- No SetScale; the frame is TOPLEFT-anchored so SetSize inside
                -- CommitResize grows it right and down with no anchor drift.
                -- Frame is always 16:9; height is derived from ratio, not cursor Y.
                local uiScale = UIParent:GetEffectiveScale()
                local cx      = select(1, GetCursorPosition())
                local curX    = cx / uiScale
                local targetW = math.max(640, curX - _dragPinX)
                local ratio   = math.max(0.5, math.min(2.0, targetW / DC.NATIVE_W))

                -- skipHeavy=true: skip font walk + detail card reflow during live drag.
                -- Both are applied in full on DragStop.
                Dashboard_CommitResize(ratio, true)
            end)

            grabber:SetScript("OnEnter", function(self)
                if not _dragActive then setGripAlpha(0.9) end
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:SetText(addon.L["DASH_RESIZE_TOOLTIP"], 1, 1, 1, 1)
                GameTooltip:Show()
            end)

            grabber:SetScript("OnLeave", function(self)
                if not _dragActive then setGripAlpha(0.6) end
                GameTooltip:Hide()
            end)

            grabber:SetScript("OnMouseUp", function(self, button)
                if button ~= "RightButton" then return end
                if InCombatLockdown() then return end
                -- Reset to native 1.0 ratio, centered.
                f:ClearAllPoints()
                f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
                local db = _G[addon.DB_NAME]
                if db then
                    db.dashboardSizeRatio = nil
                    db.dashboardTopLeftX  = nil
                    db.dashboardTopLeftY  = nil
                end
                Dashboard_CommitResize(1.0)
            end)

    if addon.DashboardCtx then
        addon.DashboardCtx.frame = f
        addon.DashboardCtx.layout = {
            contentWidth = contentWidth,
            dashScrollTopOffset = dashScrollTopOffset,
            dashScrollTopOffsetModule = dashScrollTopOffsetModule,
            viewWidth = viewWidth,
            viewCenterX = viewCenterX,
            dashTitleX = dashTitleX,
        }
    end
    if addon.ApplyDashboardTypography then
        addon.ApplyDashboardTypography()
    end
    return f
end
