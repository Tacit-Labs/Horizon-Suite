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
local DASHBOARD_CHILD_PANEL_ALPHA = DC.CHILD_PANEL_ALPHA
local DASHBOARD_CONTENT_CARD_ALPHA_MULT = DC.CONTENT_CARD_ALPHA_MULT
local DASH_HOME_TILE_W = DC.HOME_TILE_W
local DASH_HOME_TILE_H = DC.HOME_TILE_H
local DASH_HOME_TILE_GAP = DC.HOME_TILE_GAP
local DASH_HOME_TILE_COLS = DC.HOME_TILE_COLS
local DASH_HOME_TILE_BG_ALPHA_MULT = DC.HOME_TILE_BG_ALPHA_MULT
local DASH_HOME_TILE_BORDER_ALPHA_MULT = DC.HOME_TILE_BORDER_ALPHA_MULT
local DASH_HOME_SKELETON_BG_ALPHA_MULT = DC.HOME_SKELETON_BG_ALPHA_MULT
local DASH_HOME_SKELETON_BORDER_ALPHA_MULT = DC.HOME_SKELETON_BORDER_ALPHA_MULT

local function MakeText(parent, text, size, r, g, b, justify)
    return addon.Dashboard_MakeText(parent, text, size, r, g, b, justify)
end

local function MakeDashboardWelcomeMixedScriptText(parent, text, size, r, g, b, justify)
    return addon.Dashboard_MakeWelcomeMixedScriptText(parent, text, size, r, g, b, justify)
end

local function OptionCategoryKeyIsAxis(catKey)
    return addon.Dashboard_IsAxisCategoryKey(catKey)
end

function addon.Dashboard_BuildMainFrame()
    local f = CreateFrame("Frame", "HorizonSuiteDashboard", UIParent, "BackdropTemplate")
            -- Shared by ApplyDashboardClassColor (before sidebar exists) and sidebar selection.
            local dashSession = { activeSidebarBtn = nil }
            f:SetSize(DASHBOARD_FRAME_W, DASHBOARD_FRAME_H)
            f:SetPoint("CENTER")
            f:SetFrameStrata("HIGH")
            f:SetToplevel(true)
            f:SetMovable(true)
            f:SetClampedToScreen(true)
            f:EnableMouse(true)
            f:Hide()

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

            if _G.OptionsWidgets_SetDef then
                _G.OptionsWidgets_SetDef({
                    FontPath = "Fonts\\FRIZQT__.TTF",
                    LabelSize = 13,
                    SectionSize = 11,
                })
            end

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
                welcomeAccentStrip = nil,
                guideHeroRail = nil,
                pnFooterRule = nil,
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
                if dashAccentRefs.pnFooterRule and dashAccentRefs.pnFooterRule.SetColorTexture then
                    dashAccentRefs.pnFooterRule:SetColorTexture(ar, ag, ab, 0.3)
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
            f:SetScript("OnEvent", function(self, event)
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
            local COLLAPSE_ANIM_DUR = sb.COLLAPSE_ANIM_DUR
            local easeOut = sb.easeOut
            local TAB_ROW_HEIGHT = sb.TAB_ROW_HEIGHT
            local SIDEBAR_WHATSNEW_RESERVE = sb.SIDEBAR_WHATSNEW_RESERVE
            local SIDEBAR_CONTENT_X_INSET = sb.SIDEBAR_CONTENT_X_INSET
            local CreateSidebarButton = sb.CreateSidebarButton
            local SetActiveSidebarButton = sb.SetActiveSidebarButton
            LayoutDashboardSidebarUnderHeader = sb.layoutUnderHeader

            local SetSidebarState
            local RequestGroupToggle

            -- Header
            local head = MakeText(f, "Horizon Suite", 24, 1, 1, 1, "CENTER")
            head:SetPoint("TOP", CONTENT_OFFSET / 2, DASH_HEAD_TITLE_Y)
            local headSub = MakeText(f, "Select a module to configure", 13, 0.5, 0.5, 0.5, "CENTER")
            headSub:SetPoint("TOP", CONTENT_OFFSET / 2, DASH_HEAD_SUBTITLE_Y)

            -- Search Bar
            local searchBox = CreateFrame("EditBox", nil, f)
            searchBox:SetSize(500, DASH_SEARCH_BOX_H)
            searchBox:SetPoint("TOP", CONTENT_OFFSET / 2, DASH_SEARCH_Y)
            searchBox:SetFont("Fonts\\FRIZQT__.TTF", 14, "")
            searchBox:SetTextInsets(48, 15, 0, 0)
            searchBox:SetAutoFocus(false)
            searchBox:SetFrameLevel(f:GetFrameLevel() + 5)
            
            local sbBorder = searchBox:CreateTexture(nil, "BACKGROUND")
            sbBorder:SetPoint("TOPLEFT", -1, 1)
            sbBorder:SetPoint("BOTTOMRIGHT", 1, -1)
            sbBorder:SetColorTexture(0.18, 0.18, 0.22, 0.6)

            local sbBg = searchBox:CreateTexture(nil, "BORDER")
            sbBg:SetAllPoints()
            sbBg:SetColorTexture(0.10, 0.10, 0.13, DASHBOARD_CHILD_PANEL_ALPHA)
            
            local sbPlaceholder = MakeText(searchBox, "Search settings...", 14, 0.45, 0.45, 0.5, "LEFT")
            sbPlaceholder:SetPoint("LEFT", 48, 0)
            
            local sbIcon = searchBox:CreateTexture(nil, "ARTWORK")
            sbIcon:SetSize(20, 20)
            sbIcon:SetPoint("LEFT", 16, 0)
            sbIcon:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_02")
            sbIcon:SetVertexColor(0.45, 0.45, 0.5, 1)

            searchBox:SetScript("OnEditFocusGained", function(self)
                local ar, ag, ab = GetAccentColor()
                sbBorder:SetColorTexture(ar, ag, ab, 1)
                sbPlaceholder:Hide()
                sbIcon:SetVertexColor(0.8, 0.8, 0.8, 1)
            end)
            searchBox:SetScript("OnEditFocusLost", function(self)
                sbBorder:SetColorTexture(0.2, 0.2, 0.25, 1)
                if self:GetText() == "" then
                    sbPlaceholder:Show()
                    sbIcon:SetVertexColor(0.5, 0.5, 0.5, 1)
                end
            end)
            searchBox:SetScript("OnTextChanged", function(self)
                if self:GetText() == "" and not self:HasFocus() then
                     sbPlaceholder:Show()
                else
                     sbPlaceholder:Hide()
                end
                if f.OnSearchTextChanged then f.OnSearchTextChanged(self:GetText()) end
            end)
            searchBox:SetScript("OnEscapePressed", function(self) 
                self:ClearFocus() 
                self:SetText("")
                if f.HideSearchDropdown then f.HideSearchDropdown() end
            end)


            -- Search Dropdown UI
            local searchDropdown = CreateFrame("Frame", nil, f, "BackdropTemplate")
            searchDropdown:SetSize(600, 300)
            searchDropdown:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", 0, -5)
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
                searchDropdown:Hide()
                searchDropdownCatch:Hide()
            end

            -- Views (offset right to accommodate sidebar)
            local viewWidth = DASHBOARD_FRAME_W - SIDEBAR_WIDTH - 10
            local viewCenterX = CONTENT_OFFSET / 2
            local contentWidth = viewWidth - 80  -- scroll frame uses 40px inset on each side
            local viewTopInset = (DASHBOARD_FRAME_H - DASHBOARD_VIEW_H) / 2
            -- Scroll tops sit just below the search box (same visual band as Home), in each view's local coords.
            local dashScrollTopOffset = -(math.abs(DASH_SEARCH_Y) + DASH_SEARCH_BOX_H + 8 - viewTopInset)
            local dashTitleX = CONTENT_OFFSET + 40

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

            local PN_FOOTER_H    = 44
            local PN_BODY_COL  = { 0.72, 0.72, 0.76, 1 }
            local PN_MUTED_COL = { 0.52, 0.56, 0.62, 1 }
            local PN_SECTION_GAP = 16
            local PN_BULLET_X    = 16
            local PN_LINE_GAP    = 5
            local PN_CHANGELOG_URL = "https://gitlab.com/Crystilac/horizon-suite/-/blob/main/CHANGELOG.md"

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

            -- Footer (fixed, outside scroll — mirrors welcome screen footer style)
            local pnFooter = CreateFrame("Frame", nil, patchNotesView)
            pnFooter:SetPoint("BOTTOMLEFT",  patchNotesView, "BOTTOMLEFT",   40, 0)
            pnFooter:SetPoint("BOTTOMRIGHT", patchNotesView, "BOTTOMRIGHT", -40, 0)
            pnFooter:SetHeight(PN_FOOTER_H)
            pnFooter:SetFrameLevel(patchNotesView:GetFrameLevel() + 10)

            local pnFooterTopRule = pnFooter:CreateTexture(nil, "ARTWORK")
            pnFooterTopRule:SetHeight(1)
            pnFooterTopRule:SetPoint("TOPLEFT",  pnFooter, "TOPLEFT",  0, 0)
            pnFooterTopRule:SetPoint("TOPRIGHT", pnFooter, "TOPRIGHT", 0, 0)
            local pnFar, pnFag, pnFab = GetAccentColor()
            pnFooterTopRule:SetColorTexture(pnFar, pnFag, pnFab, 0.3)
            dashAccentRefs.pnFooterRule = pnFooterTopRule

            local pnClBtn = CreateFrame("Button", nil, pnFooter)
            pnClBtn:SetPoint("BOTTOM", pnFooter, "BOTTOM", 0, 10)
            pnClBtn:SetSize(120, 20)

            local pnClTxt = pnClBtn:CreateFontString(nil, "OVERLAY")
            pnClTxt:SetFont("Fonts\\ARIALN.TTF", 12, "")
            pnClTxt:SetPoint("CENTER", pnClBtn, "CENTER", 0, 0)
            pnClTxt:SetText("Full changelog")
            pnClTxt:SetTextColor(unpack(PN_MUTED_COL))

            local pnClUnderline = pnClBtn:CreateTexture(nil, "OVERLAY")
            pnClUnderline:SetHeight(1)
            pnClUnderline:SetPoint("BOTTOM", pnClBtn, "BOTTOM", 0,  0)
            pnClUnderline:SetPoint("LEFT",   pnClBtn, "LEFT",   0,  0)
            pnClUnderline:SetPoint("RIGHT",  pnClBtn, "RIGHT",  0,  0)
            pnClUnderline:Hide()

            pnClBtn:SetScript("OnEnter", function()
                pnClTxt:SetTextColor(0.88, 0.90, 0.94)
                local r, g, b = GetAccentColor()
                pnClUnderline:SetColorTexture(r, g, b, 0.6)
                pnClUnderline:Show()
                if GameTooltip then
                    GameTooltip:SetOwner(pnClBtn, "ANCHOR_TOP")
                    GameTooltip:SetText(PN_CHANGELOG_URL, 1, 1, 1, 1, true)
                    GameTooltip:Show()
                end
            end)
            pnClBtn:SetScript("OnLeave", function()
                pnClTxt:SetTextColor(unpack(PN_MUTED_COL))
                pnClUnderline:Hide()
                if GameTooltip then GameTooltip:Hide() end
            end)
            pnClBtn:SetScript("OnClick", function()
                if GameTooltip then GameTooltip:Hide() end
                if addon.ShowURLCopyBox then addon.ShowURLCopyBox(PN_CHANGELOG_URL) end
            end)

            local pnScroll = CreateFrame("ScrollFrame", nil, patchNotesView, "UIPanelScrollFrameTemplate")
            pnScroll:SetPoint("TOPLEFT", 40, dashScrollTopOffset)
            pnScroll:SetPoint("BOTTOMRIGHT", -40, PN_FOOTER_H)
            pnScroll.ScrollBar:Hide()
            pnScroll.ScrollBar:ClearAllPoints()

            local pnContent = CreateFrame("Frame", nil, pnScroll)
            pnContent:SetSize(contentWidth, 1)
            pnScroll:SetScrollChild(pnContent)
            addon.Dashboard_ApplySmoothScroll(pnScroll, pnContent, 60, true)

            local pnBuiltVersion = nil

            local function BuildPatchNotesContent(currentVersion)
                -- Orphan previous inner container so its regions don't render
                if pnContent._inner then pnContent._inner:SetParent(nil) end
                wipe(dashAccentRefs.patchNotesSectionLabels)
                wipe(dashAccentRefs.patchNotesBullets)
                wipe(dashAccentRefs.patchNotesRules)

                -- Inner container parented to pnContent (scroll child stays fixed)
                local cW = contentWidth
                local inner = CreateFrame("Frame", nil, pnContent)
                inner:SetWidth(cW)
                inner:SetHeight(1)
                inner:SetPoint("TOPLEFT", pnContent, "TOPLEFT", 0, 0)
                pnContent._inner = inner

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
                    lbl:SetFont("Fonts\\ARIALN.TTF", 12, "")
                    lbl:SetWidth(cW)
                    lbl:SetJustifyH("CENTER")
                    lbl:SetText("No notes available.")
                    lbl:SetTextColor(unpack(PN_MUTED_COL))
                    tinsert(items, { type = "fs", fs = lbl, x = 0, gap = 0 })
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
                                tinsert(items, { type = "tex", tex = sep, gap = 18 })
                            end

                            -- Version header (optional date from PatchNotesData matches CHANGELOG)
                            local vHdr = inner:CreateFontString(nil, "OVERLAY")
                            vHdr:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
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
                                lbl:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
                                lbl:SetWidth(cW)
                                lbl:SetJustifyH("LEFT")
                                lbl:SetText(sec.section:upper())
                                lbl:SetTextColor(ar, ag, ab)
                                tinsert(dashAccentRefs.patchNotesSectionLabels, lbl)
                                tinsert(items, { type = "fs", fs = lbl, x = 0, gap = 9 })

                                for _, bullet in ipairs(sec.bullets) do
                                    local txt = inner:CreateFontString(nil, "OVERLAY")
                                    txt:SetFont("Fonts\\ARIALN.TTF", 12, "")
                                    txt:SetWidth(cW - PN_BULLET_X)
                                    txt:SetJustifyH("LEFT")
                                    txt:SetWordWrap(true)
                                    local coloredBullet = ColorModuleNames(CapitalizeAfterModulePrefix(bullet))
                                    txt:SetText("|cFF"..hex.."\226\128\148|r  "..coloredBullet)
                                    txt:SetTextColor(unpack(PN_BODY_COL))
                                    tinsert(dashAccentRefs.patchNotesBullets, { fs = txt, bullet = bullet, coloredBullet = coloredBullet })
                                    tinsert(items, { type = "fs", fs = txt, x = PN_BULLET_X, gap = PN_LINE_GAP })
                                end
                            end
                        end
                    end
                end

                C_Timer.After(0, function()
                    if not (patchNotesView and patchNotesView:IsShown()) then return end
                    local y = 0
                    for _, item in ipairs(items) do
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
                dashboardView:Hide()
                detailView:Hide()
                subCategoryView:Hide()
                welcomeView:Hide()
                guideView:Hide()
                patchNotesView:Hide()
                if head then head:Hide() end
                if headSub then headSub:Hide() end
                HideContextHeader()

                targetView:SetAlpha(0)
                targetView:Show()
                UIFrameFadeIn(targetView, 0.2, 0, 1)
            end

            f.ShowDashboard = function()
                HideContextHeader()
                detailView:Hide()
                subCategoryView:Hide()
                welcomeView:Hide()
                guideView:Hide()
                patchNotesView:Hide()
                dashboardView:SetAlpha(0)
                dashboardView:Show()
                UIFrameFadeIn(dashboardView, 0.2, 0, 1)
                if head then head:Show() end
                if headSub then
                    headSub:Show()
                    headSub:SetText("Select a module to configure")
                end
                searchBox:Show()
                f.currentModuleKey = nil
                SetSidebarState({ view = "dashboard", activeModuleKey = CLEAR, activeCategoryIndex = CLEAR })
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
            closeTxt:SetFont(addon.GetDefaultFontPath and addon.GetDefaultFontPath() or "Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
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

            -- Key Handling (Escape to Close)
            f:SetPropagateKeyboardInput(true)
            f:SetScript("OnKeyDown", function(self, key)
                if key == "ESCAPE" then
                    self:SetPropagateKeyboardInput(false)
                    self:Hide()
                else
                    self:SetPropagateKeyboardInput(true)
                end
            end)




            local detailEnv = {
                f = f,
                addon = addon,
                L = L,
                detailView = detailView,
                subCategoryView = subCategoryView,
                contentWidth = contentWidth,
                dashScrollTopOffset = dashScrollTopOffset,
                dashAccentRefs = dashAccentRefs,
                GetAccentColor = GetAccentColor,
                MakeText = MakeText,
                OptionCategoryKeyIsAxis = OptionCategoryKeyIsAxis,
                moduleLabels = moduleLabels,
                DASHBOARD_CHILD_PANEL_ALPHA = DASHBOARD_CHILD_PANEL_ALPHA,
                DASHBOARD_CONTENT_CARD_ALPHA_MULT = DASHBOARD_CONTENT_CARD_ALPHA_MULT,
                CLEAR = CLEAR,
                searchBox = searchBox,
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
                dashboardView = dashboardView,
                welcomeView = welcomeView,
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
                DASH_HOME_TILE_BORDER_ALPHA_MULT = DASH_HOME_TILE_BORDER_ALPHA_MULT,
                DASH_HOME_SKELETON_BG_ALPHA_MULT = DASH_HOME_SKELETON_BG_ALPHA_MULT,
                DASH_HOME_SKELETON_BORDER_ALPHA_MULT = DASH_HOME_SKELETON_BORDER_ALPHA_MULT,
                DASHBOARD_CONTENT_CARD_ALPHA_MULT = DASHBOARD_CONTENT_CARD_ALPHA_MULT,
                HideContextHeader = HideContextHeader,
                setSidebarState = function(s) detailEnv.setSidebarState(s) end,
                CLEAR = CLEAR,
                searchBox = searchBox,
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
                head = head,
                headSub = headSub,
                DASHBOARD_CONTENT_CARD_ALPHA_MULT = DASHBOARD_CONTENT_CARD_ALPHA_MULT,
                PREVIEW_MODULE_KEYS = PREVIEW_MODULE_KEYS,
                COMING_SOON_MODULE_KEYS = COMING_SOON_MODULE_KEYS,
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
                patchNotesView:SetAlpha(0)
                patchNotesView:Show()
                UIFrameFadeIn(patchNotesView, 0.2, 0, 1)
                if head then head:Show() end
                if headSub then
                    headSub:Show()
                    headSub:SetText("Release history and recent changes")
                end
                if searchBox then searchBox:Hide() end

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

            -- Quick Start (in-game module guide; scroll icon)
            local guideBtn = CreateSidebarButton(sidebarScrollContent, L["DASH_GUIDE_TAB"] or "Quick Start", "INV_Misc_ScrollUnrolled01", function()
                if f.ShowModuleGuide then f.ShowModuleGuide() end
            end)
            guideBtn:SetPoint("TOPLEFT", welcomeBtn, "BOTTOMLEFT", 0, 0)
            f.guideSidebarBtn = guideBtn
            tinsert(sidebarButtons, guideBtn)
            tinsert(sidebarRows, { type = "guide", frame = guideBtn, bottom = guideBtn, offsetFromPrev = 0 })
            lastSidebarRow = guideBtn
            yOff = yOff + TAB_ROW_HEIGHT

            -- Home
            local homeBtn = CreateSidebarButton(sidebarScrollContent, "Home", "INV_Misc_Map_01", function()
                f.ShowDashboard()
            end)
            homeBtn:SetPoint("TOPLEFT", guideBtn, "BOTTOMLEFT", 0, 0)
            f.homeSidebarBtn = homeBtn
            tinsert(sidebarButtons, homeBtn)
            tinsert(sidebarRows, { type = "home", frame = homeBtn, bottom = homeBtn, offsetFromPrev = 0 })
            lastSidebarRow = homeBtn
            yOff = yOff + TAB_ROW_HEIGHT

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

                    if isStandalone then
                        local catIdx = g.categories[1]
                        local cat = addon.OptionCategories[catIdx]
                        local iconKey = categoryIcons[cat.key] or "INV_Misc_Question_01"
                        local btn = CreateSidebarButton(sidebarScrollContent, cat.name, iconKey, function()
                            f.OpenModule(cat.name, cat.moduleKey)
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
                        header.hoverBg = header:CreateTexture(nil, "BACKGROUND")
                        header.hoverBg:SetAllPoints(header)
                        header.hoverBg:SetColorTexture(1, 1, 1, 0.03)
                        header.hoverBg:Hide()
                        local chevron = header:CreateFontString(nil, "OVERLAY")
                        chevron:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
                        chevron:SetPoint("LEFT", header, "LEFT", 8, 0)
                        chevron:SetTextColor(0.55, 0.55, 0.65, 1)
                        header.chevron = chevron
                        local headerLabel = header:CreateFontString(nil, "OVERLAY")
                        headerLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
                        headerLabel:SetPoint("LEFT", chevron, "RIGHT", 4, 0)
                        headerLabel:SetTextColor(0.55, 0.55, 0.65, 1)
                        local headerLabelText = (g.label or ""):upper()
                        if PREVIEW_MODULE_KEYS[mk] then
                            headerLabelText = headerLabelText .. " |cff228b22(Preview)|r"
                        end
                        headerLabel:SetText(headerLabelText)
                        header.headerLabel = headerLabel

                        local tabsContainer = CreateFrame("Frame", nil, sidebarScrollContent)
                        tabsContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
                        tabsContainer:SetWidth(SIDEBAR_WIDTH - 1)
                        tabsContainer:SetClipsChildren(true)
                        local fullHeight = TAB_ROW_HEIGHT * #g.categories
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
                            RequestGroupToggle(mk)
                        end)
                        header:SetScript("OnEnter", function()
                            header.hoverBg:Show()
                            headerLabel:SetTextColor(0.8, 0.8, 0.85, 1)
                            chevron:SetTextColor(0.8, 0.8, 0.85, 1)
                        end)
                        header:SetScript("OnLeave", function()
                            header.hoverBg:Hide()
                            headerLabel:SetTextColor(0.55, 0.55, 0.65, 1)
                            chevron:SetTextColor(0.55, 0.55, 0.65, 1)
                        end)
                        chevron:SetText(GetGroupCollapsed(mk) and "+" or "-")

                        local containerAnchor = tabsContainer
                        for _, catIdx in ipairs(g.categories) do
                            local cat = addon.OptionCategories[catIdx]
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

                        if startCollapsed then
                            SetGroupChildrenShown(g, false)
                        end
                    end
                end
            end

            -- Patch Notes: pinned to sidebar bottom (outside scroll; see SIDEBAR_WHATSNEW_RESERVE)
            do
                local whatsNewBase = L["DASH_WHATS_NEW"] or "Patch Notes"
                local wnBtn = CreateSidebarButton(sidebar, whatsNewBase, "INV_Scroll_05", function()
                    if addon.PatchNotes_MarkWhatsNewSidebarClicked then
                        addon.PatchNotes_MarkWhatsNewSidebarClicked()
                    end
                    if f.ShowPatchNotes then f.ShowPatchNotes() end
                end)
                -- Same inner width as sidebarScrollFrame (left inset + right -1); full SIDEBAR_WIDTH-1 would spill past the sidebar edge.
                wnBtn:SetWidth(SIDEBAR_WIDTH - SIDEBAR_CONTENT_X_INSET - 1)
                wnBtn:SetPoint("BOTTOMLEFT", sidebar, "BOTTOMLEFT", SIDEBAR_CONTENT_X_INSET, 10)
                wnBtn:SetFrameLevel(sidebarScrollFrame:GetFrameLevel() + 1)
                wnBtn._whatsNewBaseText = whatsNewBase
                wnBtn._patchNotesSidebarRowStyle = true
                wnBtn._sidebarViewGetter = function()
                    return sidebarState.view
                end
                tinsert(sidebarButtons, wnBtn)
                f.whatsnewSidebarBtn = wnBtn
                if addon.PatchNotes_RefreshAttentionIndicators then
                    addon.PatchNotes_RefreshAttentionIndicators()
                end
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
                local targetMk = sidebarState.view ~= "dashboard" and sidebarState.activeModuleKey or nil
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
                local activeBtn = f.homeSidebarBtn or sidebarButtons[1]
                if sidebarState.view == "welcome" and f.welcomeSidebarBtn then
                    activeBtn = f.welcomeSidebarBtn
                elseif sidebarState.view == "guide" and f.guideSidebarBtn then
                    activeBtn = f.guideSidebarBtn
                elseif sidebarState.view == "whatsnew" and f.whatsnewSidebarBtn then
                    activeBtn = f.whatsnewSidebarBtn
                elseif sidebarState.view == "module" or sidebarState.view == "category" then
                    local mk = sidebarState.activeModuleKey or "modules"
                    local wantCatIdx = sidebarState.activeCategoryIndex
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
            end

            --- Toggle a group's collapse state (user header click). Persists and animates.
            RequestGroupToggle = function(mk)
                local g = groups[mk]
                if not g or not g.tabsContainer or not g.fullHeight then return end
                local collapsed = not GetGroupCollapsed(mk)
                SetGroupCollapsed(mk, collapsed)
                if g.header and g.header.chevron then g.header.chevron:SetText(collapsed and "+" or "-") end
                local fromH = g.tabsContainer:GetHeight()
                local toH = collapsed and 0 or g.fullHeight
                if fromH ~= toH then
                    g.tabsContainer.animStart = GetTime()
                    g.tabsContainer.animFrom = fromH
                    g.tabsContainer.animTo = toH
                    g.tabsContainer:SetScript("OnUpdate", function(self)
                        local elapsed = GetTime() - self.animStart
                        local t = math.min(elapsed / COLLAPSE_ANIM_DUR, 1)
                        local h = self.animFrom + (self.animTo - self.animFrom) * easeOut(t)
                        self:SetHeight(math.max(0, h))
                        if g.header and g.header.updateSpacer then g.header.updateSpacer() end
                        LayoutSidebar()
                        if t >= 1 then
                            self:SetScript("OnUpdate", nil)
                            if collapsed then
                                SetGroupChildrenShown(g, false)
                            else
                                SetGroupChildrenShown(g, true)
                            end
                        end
                    end)
                else
                    if collapsed then
                        SetGroupChildrenShown(g, false)
                    else
                        SetGroupChildrenShown(g, true)
                    end
                    if g.header and g.header.updateSpacer then g.header.updateSpacer() end
                    LayoutSidebar()
                end
            end

            LayoutSidebar()
            RefreshSidebar()

    if addon.DashboardCtx then
        addon.DashboardCtx.frame = f
        addon.DashboardCtx.layout = {
            contentWidth = contentWidth,
            dashScrollTopOffset = dashScrollTopOffset,
            viewWidth = viewWidth,
            viewCenterX = viewCenterX,
            dashTitleX = dashTitleX,
        }
    end
    return f
end
