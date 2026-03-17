--[[
    Horizon Suite - Dashboard Options Panel
    New standalone dashboard-style options UI.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end
print("|cff00ff00Horizon Suite: DashboardPanel.lua loaded|r")

local L = addon.L

-- Helper: Create Text
local function MakeText(parent, text, size, r, g, b, justify)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    local font = size >= 14 and "Fonts\\FRIZQT__.TTF" or "Fonts\\ARIALN.TTF"
    local flags = size >= 14 and "OUTLINE" or ""
    fs:SetFont(font, size, flags)
    fs:SetText(text)
    fs:SetTextColor(r, g, b)
    if justify then fs:SetJustifyH(justify) end
    return fs
end

local f = _G.HorizonSuiteDashboard
SLASH_HSDASH1 = "/hsd"
SLASH_HSDASH2 = "/dash"
SlashCmdList["HSDASH"] = function(msg)
    print("|cff00ff00Horizon Suite: /hsd triggered|r")
    f = f or _G.HorizonSuiteDashboard
    if f and f:IsShown() then
        f:Hide()
    else
        if not f then
            f = CreateFrame("Frame", "HorizonSuiteDashboard", UIParent, "BackdropTemplate")
            f:SetSize(1000, 700)
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
                axis = L["Axis"] or "Axis",
                focus = L["Focus"] or "Focus",
                presence = L["Presence"] or "Presence",
                vista = L["Vista"] or "Vista",
                insight = L["Insight"] or "Insight",
                yield = L["Yield"] or "Yield",
            }

            local function ShouldShowModuleOnDashboard(mk)
                if mk == "axis" then return true end
                return addon.IsModuleEnabled and addon:IsModuleEnabled(mk)
            end

            local categoryIcons = {
                ["Axis"] = "INV_Misc_Wrench_01",
                ["Profiles"] = "INV_Misc_GroupNeedMore",
                ["Modules"] = "inv_10_engineering_purchasedparts_color2",
                ["Focus"] = "achievement_quests_completed_05",
                ["Presence"] = "vas_guildnamechange",
                ["Vista"] = "ability_hunter_pathfinding",
                ["Insight"] = "ui_profession_inscription",
                ["Yield"] = "INV_Misc_Coin_01",
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
                underline = nil,
                sidebarDivider = nil,
                logoSep = nil,
                logoText = nil,
                searchDropBorder = nil,
            }

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
                if activeSidebarBtn then
                    activeSidebarBtn.btnBg:SetColorTexture(ar * 0.15, ag * 0.15, ab * 0.15, 1)
                    activeSidebarBtn.accentBar:SetColorTexture(ar, ag, ab, 1)
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
            end

            tinsert(UISpecialFrames, "HorizonSuiteDashboard")
            
            -- Background
            local bg = f:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.05, 0.05, 0.07, 0.98)

            -- ===== SIDEBAR =====
            local SIDEBAR_WIDTH = 160
            local CONTENT_OFFSET = SIDEBAR_WIDTH + 10

            local sidebar = CreateFrame("Frame", nil, f)
            sidebar:SetPoint("TOPLEFT", 0, 0)
            sidebar:SetPoint("BOTTOMLEFT", 0, 0)
            sidebar:SetWidth(SIDEBAR_WIDTH)
            sidebar:SetFrameLevel(f:GetFrameLevel() + 2)

            local sidebarBg = sidebar:CreateTexture(nil, "BACKGROUND")
            sidebarBg:SetAllPoints()
            sidebarBg:SetColorTexture(0.02, 0.02, 0.02, 1)

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
            local isDevMode = addon.GetDB and addon.GetDB("focusDevMode", false)
            if isDevMode then
                local devBadge = MakeText(sidebar, "[ DEV MODE ]", 10, 1, 0.65, 0.1, "CENTER")
                devBadge:SetPoint("TOP", sidebarVersion, "BOTTOM", 0, -2)
            end
            local logoSepYOffset = isDevMode and -74 or -58
            local scrollFrameYOffset = isDevMode and -84 or -68

            -- Sidebar separator under logo
            local logoSep = sidebar:CreateTexture(nil, "ARTWORK")
            logoSep:SetHeight(1)
            logoSep:SetPoint("TOPLEFT", 15, logoSepYOffset)
            logoSep:SetPoint("TOPRIGHT", -15, logoSepYOffset)
            logoSep:SetColorTexture(ar, ag, ab, 0.3)
            dashAccentRefs.logoSep = logoSep

            -- Sidebar scroll area for buttons
            local sidebarScrollFrame = CreateFrame("ScrollFrame", nil, sidebar)
            sidebarScrollFrame:SetPoint("TOPLEFT", 0, scrollFrameYOffset)
            sidebarScrollFrame:SetPoint("BOTTOMRIGHT", -1, 10)
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

            local sidebarButtons = {}
            local activeSidebarBtn = nil

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
                for _, child in pairs({g.tabsContainer:GetChildren()}) do
                    child:SetShown(shown)
                end
            end

            -- Sidebar state controller: single source of truth for view, active selection, expanded groups.
            -- view: "dashboard" | "module" | "category"
            -- activeModuleKey: module key when in module/category view
            -- activeCategoryIndex: OptionCategories index when in category view
            local sidebarState = {
                view = "dashboard",
                activeModuleKey = nil,
                activeCategoryIndex = nil,
            }
            local CLEAR = {}  -- Sentinel for explicitly clearing a state field (nil cannot be passed)

            local SetSidebarState
            local RequestGroupToggle

            local TAB_ROW_HEIGHT = 38
            local HEADER_ROW_HEIGHT = 28
            local SIDEBAR_TOP_PAD = 4
            local COLLAPSE_ANIM_DUR = 0.18
            local easeOut = addon.easeOut or function(t) return 1 - (1-t)*(1-t) end

            local function CreateSidebarButton(parent, label, iconName, onClick, indentPx)
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
                local ar, ag, ab = GetAccentColor()
                accentBar:SetColorTexture(ar, ag, ab, 1)
                accentBar:Hide()
                btn.accentBar = accentBar
                tinsert(dashAccentRefs.sidebarBars, accentBar)

                if iconName then
                    local ic = btn:CreateTexture(nil, "ARTWORK")
                    ic:SetSize(16, 16)
                    ic:SetPoint("LEFT", indentPx + 14, 0)
                    ic:SetTexture("Interface\\Icons\\" .. iconName)
                    ic:SetVertexColor(0.6, 0.6, 0.65, 1)
                    btn.icon = ic
                end

                local lbl = MakeText(btn, label, 11, 0.65, 0.65, 0.7, "LEFT")
                lbl:SetPoint("LEFT", indentPx + (iconName and 36 or 14), 0)
                lbl:SetPoint("RIGHT", -8, 0)
                lbl:SetWordWrap(false)
                btn.label = lbl

                btn:SetScript("OnEnter", function()
                    if btn ~= activeSidebarBtn then
                        btnBg:SetColorTexture(0.1, 0.1, 0.12, 1)
                        lbl:SetTextColor(0.9, 0.9, 0.95)
                        local har, hag, hab = GetAccentColor()
                        if btn.icon then btn.icon:SetVertexColor(har, hag, hab, 1) end
                    end
                end)
                btn:SetScript("OnLeave", function()
                    if btn ~= activeSidebarBtn then
                        btnBg:SetColorTexture(0, 0, 0, 0)
                        lbl:SetTextColor(0.65, 0.65, 0.7)
                        if btn.icon then btn.icon:SetVertexColor(0.6, 0.6, 0.65, 1) end
                    end
                end)
                btn:SetScript("OnClick", function()
                    if onClick then onClick() end
                end)

                return btn
            end

            local function SetActiveSidebarButton(btn)
                -- Deactivate previous
                if activeSidebarBtn then
                    activeSidebarBtn.btnBg:SetColorTexture(0, 0, 0, 0)
                    activeSidebarBtn.label:SetTextColor(0.65, 0.65, 0.7)
                    if activeSidebarBtn.icon then activeSidebarBtn.icon:SetVertexColor(0.6, 0.6, 0.65, 1) end
                    activeSidebarBtn.accentBar:Hide()
                end
                -- Activate new
                activeSidebarBtn = btn
                if btn then
                    local ar, ag, ab = GetAccentColor()
                    btn.btnBg:SetColorTexture(ar * 0.15, ag * 0.15, ab * 0.15, 1)
                    btn.label:SetTextColor(1, 1, 1)
                    if btn.icon then btn.icon:SetVertexColor(1, 1, 1, 1) end
                    btn.accentBar:Show()
                end
            end

            -- ===== END SIDEBAR =====
            
            -- Header
            local head = MakeText(f, "Horizon Suite", 24, 1, 1, 1, "CENTER")
            head:SetPoint("TOP", CONTENT_OFFSET / 2, -30)
            local headSub = MakeText(f, "Select a module to configure", 13, 0.5, 0.5, 0.5, "CENTER")
            headSub:SetPoint("TOP", CONTENT_OFFSET / 2, -58)

            -- Search Bar
            local searchBox = CreateFrame("EditBox", nil, f)
            searchBox:SetSize(500, 36)
            searchBox:SetPoint("TOP", CONTENT_OFFSET / 2, -88)
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
            sbBg:SetColorTexture(0.10, 0.10, 0.13, 1)
            
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

            -- Smooth Scroll Helper
            local function ApplySmoothScroll(scrollFrame, scrollContent, speed, addScrollbar)
                scrollFrame.targetScroll = nil
                scrollFrame.scrollSpeed = speed or 60
                
                local updateThumb
                if addScrollbar then
                    local track = CreateFrame("Frame", nil, scrollFrame)
                    track:SetWidth(4)
                    track:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 10, 0)
                    track:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 10, 0)
                    
                    local thumb = track:CreateTexture(nil, "OVERLAY")
                    thumb:SetWidth(4)
                    thumb:SetColorTexture(1, 1, 1, 0.2)
                    
                    updateThumb = function()
                        local frameH = scrollFrame:GetHeight() or 1
                        if frameH == 0 then frameH = 1 end
                        local contentH = scrollContent:GetHeight() or 1
                        if contentH <= frameH then
                            thumb:Hide()
                            return
                        end
                        thumb:Show()
                        local scroll = scrollFrame:GetVerticalScroll() or 0
                        local maxScroll = math.max(1, contentH - frameH)
                        local thumbPct = frameH / contentH
                        local thumbH = math.max(20, frameH * thumbPct)
                        thumb:SetHeight(thumbH)
                        local trackH = (track:GetHeight() or frameH) - thumbH
                        local offset = (scroll / maxScroll) * trackH
                        thumb:ClearAllPoints()
                        thumb:SetPoint("TOP", track, "TOP", 0, -offset)
                    end
                    
                    if scrollFrame:GetScript("OnScrollRangeChanged") then
                        scrollFrame:HookScript("OnScrollRangeChanged", updateThumb)
                    else
                        scrollFrame:SetScript("OnScrollRangeChanged", updateThumb)
                    end
                    
                    if scrollFrame:GetScript("OnVerticalScroll") then
                        scrollFrame:HookScript("OnVerticalScroll", updateThumb)
                    else
                        scrollFrame:SetScript("OnVerticalScroll", updateThumb)
                    end
                end

                scrollFrame:EnableMouseWheel(true)
                scrollFrame:SetScript("OnMouseWheel", function(self, delta)
                    local cur = self.targetScroll or self:GetVerticalScroll() or 0
                    local childH = scrollContent:GetHeight() or 0
                    local frameH = self:GetHeight() or 0
                    local maxScroll = math.max(0, childH - frameH)
                    
                    local new = math.max(0, math.min(maxScroll, cur - delta * self.scrollSpeed))
                    self.targetScroll = new
                    
                    self:SetScript("OnUpdate", function(self, elapsed)
                        if not self.targetScroll then
                            self:SetScript("OnUpdate", nil)
                            return
                        end
                        local current = self:GetVerticalScroll() or 0
                        local diff = self.targetScroll - current
                        if math.abs(diff) < 0.5 then
                            self:SetVerticalScroll(self.targetScroll)
                            self.targetScroll = nil
                            self:SetScript("OnUpdate", nil)
                        else
                            -- Lerp towards target
                            self:SetVerticalScroll(current + diff * 25 * elapsed)
                        end
                        if updateThumb then updateThumb() end
                    end)
                end)
            end

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
            searchDropdown:SetBackdropColor(0.08, 0.08, 0.09, 0.98)
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

            ApplySmoothScroll(searchDropdownScroll, searchDropdownContent, 30, true)
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
            local viewWidth = 1000 - SIDEBAR_WIDTH - 10
            local viewCenterX = CONTENT_OFFSET / 2
            local contentWidth = viewWidth - 80  -- scroll frame uses 40px inset on each side

            local dashboardView = CreateFrame("Frame", nil, f)
            dashboardView:SetSize(viewWidth, 680)
            dashboardView:SetPoint("CENTER", viewCenterX, 0)
            f.dashboardView = dashboardView

            local detailView = CreateFrame("Frame", nil, f)
            detailView:SetSize(viewWidth, 680)
            detailView:SetPoint("CENTER", viewCenterX, 0)
            detailView:Hide()
            f.detailView = detailView

            local subCategoryView = CreateFrame("Frame", nil, f)
            subCategoryView:SetSize(viewWidth, 680)
            subCategoryView:SetPoint("CENTER", viewCenterX, 0)
            subCategoryView:Hide()
            f.subCategoryView = subCategoryView

            local subCategoryScroll = CreateFrame("ScrollFrame", nil, subCategoryView, "UIPanelScrollFrameTemplate")
            subCategoryScroll:SetPoint("TOPLEFT", 40, -135)
            subCategoryScroll:SetPoint("BOTTOMRIGHT", -40, 40)
            subCategoryScroll.ScrollBar:Hide()
            subCategoryScroll.ScrollBar:ClearAllPoints()

            local subCategoryContent = CreateFrame("Frame", nil, subCategoryScroll)
            subCategoryContent:SetSize(contentWidth, 1)
            subCategoryScroll:SetScrollChild(subCategoryContent)

            ApplySmoothScroll(subCategoryScroll, subCategoryContent, 60, true)
            local detailTitle = MakeText(detailView, "MODULE SETTINGS", 18, 1, 1, 1, "LEFT")
            detailTitle:SetPoint("TOPLEFT", 40, -45)
            f.detailTitle = detailTitle

            -- Accent underline below detail title
            local detailTitleUnderline = detailView:CreateTexture(nil, "ARTWORK")
            detailTitleUnderline:SetHeight(1)
            detailTitleUnderline:SetPoint("TOPLEFT", detailTitle, "BOTTOMLEFT", 0, -6)
            detailTitleUnderline:SetPoint("RIGHT", detailView, "RIGHT", -40, 0)
            local ar, ag, ab = GetAccentColor()
            detailTitleUnderline:SetColorTexture(ar, ag, ab, 0.35)
            dashAccentRefs.underline = detailTitleUnderline

            -- Transitions (faster animations per UX feedback)
            local function CrossfadeTo(targetView)
                dashboardView:Hide()
                detailView:Hide()
                subCategoryView:Hide()
                if head then head:Hide() end
                if headSub then headSub:Hide() end

                targetView:SetAlpha(0)
                targetView:Show()
                UIFrameFadeIn(targetView, 0.2, 0, 1)
            end

            f.ShowDashboard = function()
                detailView:Hide()
                subCategoryView:Hide()
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
                if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
            end

            -- Back Button (Persistent in Detail View)
            local backBtn = CreateFrame("Button", nil, detailView)
            backBtn:SetPoint("TOPLEFT", 40, -5)
            
            -- Back Button (Subcategory View)
            local subBackBtn = CreateFrame("Button", nil, subCategoryView)
            subBackBtn:SetPoint("TOPLEFT", 40, -5)
            
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

            -- Back button in detail view: reopen module groups, but keep core tiles behaving like dashboard entries.
            backBtn:SetScript("OnClick", function()
                if f.currentModuleKey then
                    local mk = f.currentModuleKey
                    local cats = {}
                    for _, cat in ipairs(addon.OptionCategories) do
                        local catMk
                        if cat.key == "Profiles" or cat.key == "Modules" then
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

            -- Detail Card Container (Scrollable)
            local detailScroll = CreateFrame("ScrollFrame", nil, detailView, "UIPanelScrollFrameTemplate")
            detailScroll:SetPoint("TOPLEFT", 40, -135)
            detailScroll:SetPoint("BOTTOMRIGHT", -40, 40)
            detailScroll.ScrollBar:Hide()
            detailScroll.ScrollBar:ClearAllPoints()

            local detailContent = CreateFrame("Frame", nil, detailScroll)
            detailContent:SetSize(contentWidth, 1)
            detailScroll:SetScrollChild(detailContent)

            ApplySmoothScroll(detailScroll, detailContent, 60, true)
            local currentDetailCards = {}

            local function ClearDetailCards()
                for _, card in ipairs(currentDetailCards) do
                    if card.anim and card.anim:IsPlaying() then card.anim:Stop() end
                    if card.relayoutAnimFrame then card.relayoutAnimFrame:SetScript("OnUpdate", nil) end
                    card.relayoutAnim = nil
                    card:Hide()
                end
                wipe(currentDetailCards)
                wipe(dashAccentRefs.cardAccents)
                wipe(dashAccentRefs.cardDividers)
            end

            -- Helper: Update Detail Layout
            local function UpdateDetailLayout()
                local yOffset = 0
                for _, card in ipairs(currentDetailCards) do
                    card:ClearAllPoints()
                    card:SetPoint("TOPLEFT", detailContent, "TOPLEFT", 0, -yOffset)
                    card:SetPoint("RIGHT", detailContent, "RIGHT", 0, 0)
                    yOffset = yOffset + card:GetHeight() + 15
                end
                
                local newHeight = math.max(1, yOffset)
                detailContent:SetHeight(newHeight)
                
                if detailScroll then
                    local frameH = detailScroll:GetHeight() or 1
                    local maxScroll = math.max(0, newHeight - frameH)
                    local curScroll = detailScroll.targetScroll or detailScroll:GetVerticalScroll() or 0
                    if curScroll > maxScroll then
                        -- Instantly adjust the content so it stays attached to bottom edge instead of popping
                        detailScroll.targetScroll = maxScroll
                        if not detailScroll:GetScript("OnUpdate") then
                            detailScroll:SetVerticalScroll(maxScroll)
                            detailScroll.targetScroll = nil
                        end
                    end
                end
            end

            local function NavigateToOption(entry)
                if not entry then return end
                -- Find the target category
                local targetCat = false
                for _, cat in ipairs(addon.OptionCategories) do
                    if cat.key == entry.categoryKey then
                        targetCat = cat
                        break
                    end
                end

                if targetCat then
                    -- Get the effective moduleKey (Profiles/Modules map to "axis")
                    local effectiveMk = targetCat.moduleKey
                    if targetCat.key == "Profiles" or targetCat.key == "Modules" then
                        effectiveMk = "axis"
                    end
                    local modName = effectiveMk and moduleLabels[effectiveMk] or targetCat.name

                    -- Build subcategory tiles (for back button) but skip detail card creation since OpenCategoryDetail handles it
                    f.OpenModule(modName, effectiveMk, true)

                    local options = type(targetCat.options) == "function" and targetCat.options() or targetCat.options
                    f.OpenCategoryDetail(modName, entry.categoryName, options)

                    -- Find and expand the relevant accordion card
                    C_Timer.After(0.1, function()
                        for _, card in ipairs(currentDetailCards) do
                            if card.optionIds and card.optionIds[entry.optionId] then
                                if not card.expanded then
                                    card.expanded = true
                                    card.anim:Play()
                                end
                                
                                -- Scroll to the card
                                local _, _, _, _, yOffset = card:GetPoint()
                                local frameH = detailScroll:GetHeight() or 0
                                local maxScroll = math.max(0, detailContent:GetHeight() - frameH)
                                local targetScroll = math.max(0, math.min(maxScroll, math.abs(yOffset or 0) - 20))
                                detailScroll:SetVerticalScroll(targetScroll)
                                break
                            end
                        end
                    end)
                end
            end

            local searchDropdownButtons = {}
            local SEARCH_DROPDOWN_ROW_HEIGHT = 38

            local function ShowSearchResults(matches)
                if not matches or #matches == 0 then
                    f.HideSearchDropdown()
                    return
                end
                
                local num = math.min(#matches, 12)
                for i = 1, num do
                    if not searchDropdownButtons[i] then
                        local b = CreateFrame("Button", nil, searchDropdownContent)
                        b:SetHeight(SEARCH_DROPDOWN_ROW_HEIGHT)
                        b:SetPoint("LEFT", searchDropdownContent, "LEFT", 0, 0)
                        b:SetPoint("RIGHT", searchDropdownContent, "RIGHT", 0, 0)
                        
                        b.subLabel = MakeText(b, "", 10, 0.58, 0.64, 0.74, "LEFT")
                        b.subLabel:SetPoint("TOPLEFT", b, "TOPLEFT", 8, -4)
                        
                        b.label = MakeText(b, "", 12, 0.9, 0.9, 0.9, "LEFT")
                        b.label:SetPoint("TOPLEFT", b.subLabel, "BOTTOMLEFT", 0, -1)
                        
                        local hi = b:CreateTexture(nil, "BACKGROUND")
                        hi:SetAllPoints(b)
                        hi:SetColorTexture(1, 1, 1, 0.08)
                        hi:Hide()

                        b:SetScript("OnEnter", function()
                            local har, hag, hab = GetAccentColor()
                            hi:SetColorTexture(har, hag, hab, 0.08)
                            hi:Show()
                            b.label:SetTextColor(1, 1, 1)
                        end)
                        b:SetScript("OnLeave", function()
                            hi:Hide()
                            b.label:SetTextColor(0.9, 0.9, 0.9)
                        end)
                        searchDropdownButtons[i] = { btn = b, hi = hi }
                    end
                    
                    local row = searchDropdownButtons[i]
                    local m = matches[i]
                    local breadcrumb
                    if m.moduleLabel and m.moduleLabel ~= "" and m.moduleLabel ~= (m.categoryName or "") then
                        breadcrumb = (m.moduleLabel or "") .. " > " .. (m.categoryName or "") .. " > " .. (m.sectionName or "")
                    else
                        breadcrumb = (m.categoryName or "") .. " > " .. (m.sectionName or "")
                    end
                    
                    local rawName = m.option and (type(m.option.name) == "function" and m.option.name() or m.option.name) or nil
                    local optionName = tostring(rawName or "")
                    
                    row.btn.subLabel:SetText(breadcrumb or "")
                    row.btn.label:SetText(optionName)
                    row.btn.entry = m
                    row.btn:SetPoint("TOP", searchDropdownContent, "TOP", 0, -(i - 1) * SEARCH_DROPDOWN_ROW_HEIGHT)
                    row.btn:SetScript("OnClick", function()
                        NavigateToOption(row.btn.entry)
                        f.HideSearchDropdown()
                        if searchBox then searchBox:ClearFocus() end
                    end)
                    row.btn:Show()
                end
                
                for i = num + 1, #searchDropdownButtons do
                    if searchDropdownButtons[i] then searchDropdownButtons[i].btn:Hide() end
                end
                
                searchDropdownContent:SetHeight(num * SEARCH_DROPDOWN_ROW_HEIGHT)
                searchDropdownScroll:SetVerticalScroll(0)
                searchDropdown:Show()
                searchDropdownCatch:Show()
            end

            local searchDebounceTimer
            f.OnSearchTextChanged = function(text)
                if searchDebounceTimer and searchDebounceTimer.Cancel then
                    searchDebounceTimer:Cancel()
                end
                searchDebounceTimer = nil
                
                local delay = 0.2
                if C_Timer and C_Timer.NewTimer then
                    searchDebounceTimer = C_Timer.NewTimer(delay, function()
                        searchDebounceTimer = nil
                        f.FilterBySearch(text)
                    end)
                elseif C_Timer and C_Timer.After then
                    C_Timer.After(delay, function() f.FilterBySearch(text) end)
                else
                    f.FilterBySearch(text)
                end
            end

            f.FilterBySearch = function(query)
                local searchQuery = query and query:trim():lower() or ""
                if searchQuery == "" or #searchQuery < 2 then
                    f.HideSearchDropdown()
                    return
                end
                
                local index = addon.OptionsData_BuildSearchIndex and addon.OptionsData_BuildSearchIndex() or {}
                local matches = {}
                for _, entry in ipairs(index) do
                    if entry.searchText and entry.searchText:find(searchQuery, 1, true) then
                        matches[#matches + 1] = entry
                    end
                end
                ShowSearchResults(matches)
            end

            local currentSubTiles = {}

            local function ClearSubTiles()
                for _, tile in ipairs(currentSubTiles) do
                    tile:Hide()
                end
                wipe(currentSubTiles)
                wipe(dashAccentRefs.subcatAccents)
            end

            -- Helper: Create Subcategory Tile
            local TILE_PAD = 10
            local TILE_GAP = 10
            local TILE_W = math.floor((contentWidth - TILE_PAD * 2 - TILE_GAP) / 2)
            local TILE_STRIDE = TILE_W + TILE_GAP

            local function CreateSubCategoryTile(parent, name, index, options, modName, desc)
                local tile = CreateFrame("Button", nil, parent)
                tile:SetSize(TILE_W, 110)
                
                local row = math.floor((index-1) / 2)
                local col = (index-1) % 2
                tile:SetPoint("TOPLEFT", parent, "TOPLEFT", TILE_PAD + (col * TILE_STRIDE), 0 + (row * -130))

                -- Background
                local tBg = tile:CreateTexture(nil, "BACKGROUND")
                tBg:SetPoint("TOPLEFT", 1, -1)
                tBg:SetPoint("BOTTOMRIGHT", -1, 1)
                tBg:SetColorTexture(0.08, 0.08, 0.1, 1)

                -- Border
                local border = tile:CreateTexture(nil, "BORDER")
                border:SetAllPoints()
                border:SetColorTexture(0.13, 0.14, 0.18, 0.8)

                -- Top accent highlight (hidden by default)
                local topAccent = tile:CreateTexture(nil, "ARTWORK")
                topAccent:SetHeight(2)
                topAccent:SetPoint("TOPLEFT", 1, -1)
                topAccent:SetPoint("TOPRIGHT", -1, -1)
                topAccent:SetColorTexture(1, 1, 1, 0)

                -- Accent
                local accent = tile:CreateTexture(nil, "ARTWORK")
                accent:SetSize(4, 60)
                accent:SetPoint("LEFT", 0, 0)
                local ar, ag, ab = GetAccentColor()
                accent:SetColorTexture(ar, ag, ab, 1)
                accent:Hide()
                tinsert(dashAccentRefs.subcatAccents, accent)

                -- Label
                local lbl = MakeText(tile, name, 18, 0.9, 0.9, 0.95, "LEFT")
                lbl:SetPoint("TOPLEFT", 28, -22)
                
                -- Collect subset of option names for description
                local descStr = desc or ("Configure and customize settings related to " .. name:lower() .. ".")

                -- Description Text
                local descLbl = MakeText(tile, descStr, 12, 0.55, 0.6, 0.65, "LEFT")
                descLbl:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", 0, -6)
                descLbl:SetPoint("RIGHT", tile, "RIGHT", -22, 0)
                descLbl:SetWordWrap(true)
                descLbl:SetHeight(40)
                descLbl:SetJustifyV("TOP")

                tile:SetScript("OnEnter", function()
                    tBg:SetColorTexture(0.11, 0.12, 0.15, 1)
                    local ar, ag, ab = GetAccentColor()
                    border:SetColorTexture(ar, ag, ab, 0.6)
                    lbl:SetTextColor(1, 1, 1)
                    descLbl:SetTextColor(0.75, 0.8, 0.85)
                    accent:SetColorTexture(ar, ag, ab, 1)
                    accent:Show()
                    topAccent:SetColorTexture(ar, ag, ab, 0.3)
                end)
                tile:SetScript("OnLeave", function()
                    tBg:SetColorTexture(0.08, 0.08, 0.1, 1)
                    border:SetColorTexture(0.13, 0.14, 0.18, 0.8)
                    lbl:SetTextColor(0.9, 0.9, 0.95)
                    descLbl:SetTextColor(0.55, 0.6, 0.65)
                    accent:Hide()
                    topAccent:SetColorTexture(1, 1, 1, 0)
                end)
                tile:SetScript("OnClick", function()
                    f.OpenCategoryDetail(modName, name, options)
                end)

                return tile
            end

            f.OpenCategoryDetail = function(modName, catName, options)
                if searchBox then searchBox:ClearFocus() end

                local matchedModuleKey = f.currentModuleKey or "modules"
                local matchedCatIdx = nil
                for i, cat in ipairs(addon.OptionCategories) do
                    local catMk
                    if cat.key == "Profiles" or cat.key == "Modules" then
                        catMk = "axis"
                    else
                        catMk = cat.moduleKey or "modules"
                    end
                    if cat.name == catName and (not f.currentModuleKey or catMk == f.currentModuleKey) then
                        matchedModuleKey = catMk
                        matchedCatIdx = i
                        break
                    end
                end
                f.currentModuleKey = matchedModuleKey
                SetSidebarState({ view = "category", activeModuleKey = matchedModuleKey, activeCategoryIndex = matchedCatIdx })

                ClearDetailCards()
                CrossfadeTo(detailView)
                detailContent:Show()
                detailScroll:SetVerticalScroll(0)

                if f.detailTitle then 
                    f.detailTitle:SetText(modName:upper() .. "  >  " .. catName:upper())
                end

                f.BuildAccordionDetail(catName, options)

                -- Cascade effect (faster per UX feedback)
                for i, card in ipairs(currentDetailCards) do
                    card:SetAlpha(0)
                    local _, _, _, xVal, yVal = card:GetPoint()
                    if yVal then
                        card:SetPoint("TOPLEFT", detailContent, "TOPLEFT", xVal or 0, yVal - 20)
                        if C_Timer and C_Timer.After then
                            C_Timer.After(i * 0.05, function()
                                if card:IsShown() then
                                    card:SetPoint("TOPLEFT", detailContent, "TOPLEFT", xVal or 0, yVal)
                                    UIFrameFadeIn(card, 0.2, 0, 1)
                                end
                            end)
                        else
                            card:SetAlpha(1)
                        end
                    end
                end
            end

            f.OpenModule = function(name, moduleKey, skipDetailBuild)
                if searchBox then searchBox:ClearFocus() end

                local mk = moduleKey or "modules"
                f.currentModuleKey = mk
                SetSidebarState({ view = "module", activeModuleKey = mk, activeCategoryIndex = CLEAR })

                -- Find all matching sub-categories
                local cats = {}
                for _, cat in ipairs(addon.OptionCategories) do
                    local match = false
                    if moduleKey == "axis" then
                        match = (cat.key == "Profiles" or cat.key == "Modules")
                    elseif moduleKey and cat.moduleKey == moduleKey then
                        match = true
                    elseif not moduleKey and cat.name == name then
                        match = true
                    end
                    if match and cat.options then
                        tinsert(cats, cat)
                    end
                end

                    if #cats > 1 then
                    -- Show SubCategory View
                    ClearSubTiles()
                    CrossfadeTo(subCategoryView)
                    subCategoryScroll:SetVerticalScroll(0)

                    local modName = moduleKey and moduleLabels[moduleKey] or name

                    local subTitle = subCategoryView.title
                    if not subTitle then
                        subTitle = MakeText(subCategoryView, modName:upper() .. " CATEGORIES", 20, 1, 1, 1, "LEFT")
                        subTitle:SetPoint("TOPLEFT", 180, -45)
                        subCategoryView.title = subTitle
                    else
                        subTitle:SetText(modName:upper() .. " CATEGORIES")
                    end

                local tileYOffset = 0
                    for i, cat in ipairs(cats) do
                        local options = type(cat.options) == "function" and cat.options() or cat.options
                        local tile = CreateSubCategoryTile(subCategoryContent, cat.name, i, options, modName, cat.desc)
                        tinsert(currentSubTiles, tile)
                        
                        local row = math.floor((i-1) / 2)
                        tileYOffset = math.max(tileYOffset, (row + 1) * 130)

                        -- Staggered Cascade Entrance (faster per UX feedback)
                        tile:SetAlpha(0)
                        local _, _, _, xVal, yVal = tile:GetPoint()
                        if xVal and yVal then
                            tile:SetPoint("TOPLEFT", subCategoryContent, "TOPLEFT", xVal, yVal - 20)
                            if C_Timer and C_Timer.After then
                                C_Timer.After(i * 0.05, function()
                                    if tile:IsShown() then
                                        tile:SetPoint("TOPLEFT", subCategoryContent, "TOPLEFT", xVal, yVal)
                                        UIFrameFadeIn(tile, 0.2, 0, 1)
                                    end
                                end)
                            else
                                tile:SetAlpha(1)
                            end
                        end
                    end
                    subCategoryContent:SetHeight(math.max(1, tileYOffset))
                elseif not skipDetailBuild then
                    -- Only 1 category (or none), go straight to details
                    ClearDetailCards()
                    CrossfadeTo(detailView)
                    detailContent:Show()
                    detailScroll:SetVerticalScroll(0)

                    if f.detailTitle then 
                        local titleText = name:upper()
                        if moduleKey and moduleLabels[moduleKey] then
                            local modName = moduleLabels[moduleKey]
                            if modName:upper() ~= name:upper() then
                                titleText = modName:upper() .. "  >  " .. name:upper()
                            end
                        end
                        f.detailTitle:SetText(titleText) 
                    end

                    if cats[1] then
                        local options = type(cats[1].options) == "function" and cats[1].options() or cats[1].options
                        f.BuildAccordionDetail(cats[1].name, options)

                        -- Cascade effect (faster per UX feedback)
                        for i, card in ipairs(currentDetailCards) do
                            card:SetAlpha(0)
                            local _, _, _, xVal, yVal = card:GetPoint()
                            if yVal then
                                card:SetPoint("TOPLEFT", detailContent, "TOPLEFT", xVal or 0, yVal - 20)
                                if C_Timer and C_Timer.After then
                                    C_Timer.After(i * 0.05, function()
                                        if card:IsShown() then
                                            card:SetPoint("TOPLEFT", detailContent, "TOPLEFT", xVal or 0, yVal)
                                            UIFrameFadeIn(card, 0.2, 0, 1)
                                        end
                                    end)
                                else
                                    card:SetAlpha(1)
                                end
                            end
                        end
                    end
                end
            end

            local function CreateAccordionCard(parent, title)
                local card = CreateFrame("Button", nil, parent)
                card:SetHeight(60)
                card:SetPoint("LEFT", parent, "LEFT", 0, 0)
                card:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
                card.expanded = false
                card.collapsedHeight = 60
                card:SetClipsChildren(true)

                -- Background
                local cBg = card:CreateTexture(nil, "BACKGROUND")
                cBg:SetAllPoints()
                cBg:SetColorTexture(0.06, 0.06, 0.07, 0.95)

                -- Bottom divider
                local divider = card:CreateTexture(nil, "ARTWORK")
                divider:SetHeight(1)
                divider:SetPoint("BOTTOMLEFT", 20, 0)
                divider:SetPoint("BOTTOMRIGHT", -20, 0)
                local cdr, cdg, cdb = GetAccentColor()
                divider:SetColorTexture(cdr, cdg, cdb, 0.2)
                tinsert(dashAccentRefs.cardDividers, divider)

                card:HookScript("OnEnter", function()
                    if not card.expanded then
                        cBg:SetColorTexture(0.09, 0.09, 0.1, 0.95)
                    end
                end)
                card:HookScript("OnLeave", function()
                    if not card.expanded then
                        cBg:SetColorTexture(0.06, 0.06, 0.07, 0.95)
                    end
                end)

                -- Accent
                local accent = card:CreateTexture(nil, "ARTWORK")
                accent:SetSize(3, 24)
                accent:SetPoint("TOPLEFT", 20, -18)
                local cr, cg, cb = GetAccentColor()
                accent:SetColorTexture(cr, cg, cb, 1)
                tinsert(dashAccentRefs.cardAccents, accent)

                -- Chevron indicator
                local chevron = MakeText(card, "+", 14, 0.5, 0.5, 0.55, "RIGHT")
                chevron:SetPoint("TOPRIGHT", -25, -23)

                -- Title
                local lbl = MakeText(card, title:upper(), 15, 0.9, 0.9, 0.95, "LEFT")
                lbl:SetPoint("TOPLEFT", 35, -22)

                -- Settings Container
                local sc = CreateFrame("Frame", nil, card)
                sc:SetPoint("TOPLEFT", 0, -60)
                sc:SetPoint("RIGHT", card, "RIGHT", 0, 0)
                sc:SetHeight(1)
                sc:SetAlpha(0)
                card.settingsContainer = sc

                local function updateExpandedVisuals()
                    if card.expanded then
                        cBg:SetColorTexture(0.08, 0.08, 0.09, 0.98)
                        chevron:SetText("-")
                    else
                        cBg:SetColorTexture(0.06, 0.06, 0.07, 0.95)
                        chevron:SetText("+")
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

                card:SetScript("OnClick", function()
                    if card.anim:IsPlaying() then return end
                    card.expanded = not card.expanded
                    updateExpandedVisuals()
                    card.anim:Play()
                end)

                return card
            end

            f.BuildAccordionDetail = function(moduleSubName, options)
                local currentCard = nil
                local detailOptionFrames = {}

                local function RefreshLinkedTargets(refreshIds)
                    if not refreshIds then return end
                    for _, k in ipairs(refreshIds) do
                        local w = detailOptionFrames[k]
                        if w and w.Refresh then w:Refresh() end
                    end
                    if addon.Presence and addon.Presence.RefreshPreviewTargets then
                        addon.Presence.RefreshPreviewTargets()
                    end
                end

                local DEPENDENT_FADE_DUR = 0.12
                local DEPENDENT_HEIGHT_DUR = 0.15
                local easeOutDep = addon.easeOut or function(t) return 1 - (1 - t) * (1 - t) end

                local function DoInstantRelayout(card, skipHeightApply)
                    if not card or not card.widgetList then return end
                    local yOff = 0
                    for _, entry in ipairs(card.widgetList) do
                        local visible = true
                        if entry.visibleWhen then
                            visible = entry.visibleWhen()
                        end
                        entry.frame:SetShown(visible)
                        if visible then
                            entry.frame:SetAlpha(1)
                            local topGap = entry.isHeader and 18 or 6
                            entry.frame:ClearAllPoints()
                            entry.frame:SetPoint("TOPLEFT", card.settingsContainer, "TOPLEFT", 30, -(yOff + topGap))
                            entry.frame:SetPoint("RIGHT", card.settingsContainer, "RIGHT", -30, 0)
                            local h = entry.frame:GetHeight() or 40
                            if entry.isHeader and h < 20 then h = 20 end
                            yOff = yOff + h + topGap
                        end
                    end
                    card.contentHeight = yOff
                    card.fullHeight = yOff + 80
                    if not skipHeightApply and card.expanded then
                        card:SetHeight(card.fullHeight)
                    end
                    UpdateDetailLayout()
                end

                local function RelayoutCard(card)
                    if not card or not card.widgetList then return end

                    if card.relayoutAnim then
                        if card.relayoutAnim.toShow then
                            for _, entry in ipairs(card.relayoutAnim.toShow) do
                                entry.frame:Hide()
                                entry.frame:SetAlpha(1)
                            end
                        end
                        if card.relayoutAnim.oldHeight then
                            card:SetHeight(card.relayoutAnim.oldHeight)
                        end
                        card.relayoutAnim = nil
                        if card.relayoutAnimFrame then
                            card.relayoutAnimFrame:SetScript("OnUpdate", nil)
                        end
                    end

                    local toHide, toShow = {}, {}
                    for _, entry in ipairs(card.widgetList) do
                        if entry.visibleWhen then
                            local wasVisible = entry.frame:IsShown()
                            local targetVisible = entry.visibleWhen()
                            if wasVisible and not targetVisible then
                                toHide[#toHide + 1] = entry
                            elseif not wasVisible and targetVisible then
                                toShow[#toShow + 1] = entry
                            end
                        end
                    end

                    local skipAnim = (#toHide == 0 and #toShow == 0) or not card.expanded

                    if skipAnim then
                        DoInstantRelayout(card, false)
                        return
                    end

                    local oldHeight = card:GetHeight()
                    local animFrame = card.relayoutAnimFrame or CreateFrame("Frame", nil, card)
                    animFrame:ClearAllPoints()
                    animFrame:SetAllPoints(card)
                    card.relayoutAnimFrame = animFrame

                    if #toHide > 0 then
                        card.relayoutAnim = { phase = "fadeOut", elapsed = 0, toHide = toHide, oldHeight = oldHeight }
                        animFrame:SetScript("OnUpdate", function(self, dt)
                            local a = card.relayoutAnim
                            if not a then self:SetScript("OnUpdate", nil) return end
                            a.elapsed = a.elapsed + dt
                            if a.phase == "fadeOut" then
                                local t = math.min(1, a.elapsed / DEPENDENT_FADE_DUR)
                                local ep = easeOutDep(t)
                                for _, entry in ipairs(a.toHide) do
                                    entry.frame:SetAlpha(1 - ep)
                                end
                                if t >= 1 then
                                    for _, entry in ipairs(a.toHide) do
                                        entry.frame:Hide()
                                        entry.frame:SetAlpha(1)
                                    end
                                    DoInstantRelayout(card, true)
                                    a.phase = "heightShrink"
                                    a.elapsed = 0
                                    a.targetFullH = card.fullHeight
                                end
                            else
                                local t = math.min(1, a.elapsed / DEPENDENT_HEIGHT_DUR)
                                local ep = easeOutDep(t)
                                local curH = a.oldHeight + (a.targetFullH - a.oldHeight) * ep
                                card:SetHeight(curH)
                                UpdateDetailLayout()
                                if t >= 1 then
                                    DoInstantRelayout(card, false)
                                    card.relayoutAnim = nil
                                    self:SetScript("OnUpdate", nil)
                                end
                            end
                        end)
                    elseif #toShow > 0 then
                        DoInstantRelayout(card, true)
                        for _, entry in ipairs(toShow) do
                            entry.frame:SetAlpha(0)
                        end
                        card:SetHeight(oldHeight)

                        card.relayoutAnim = {
                            phase = "fadeIn",
                            elapsed = 0,
                            toShow = toShow,
                            oldHeight = oldHeight,
                            targetFullH = card.fullHeight,
                        }
                        animFrame:SetScript("OnUpdate", function(self, dt)
                            local a = card.relayoutAnim
                            if not a then self:SetScript("OnUpdate", nil) return end
                            a.elapsed = a.elapsed + dt
                            local fadeT = math.min(1, a.elapsed / DEPENDENT_FADE_DUR)
                            local heightT = math.min(1, a.elapsed / DEPENDENT_HEIGHT_DUR)
                            local fadeEp = easeOutDep(fadeT)
                            local heightEp = easeOutDep(heightT)
                            for _, entry in ipairs(a.toShow) do
                                entry.frame:SetAlpha(fadeEp)
                            end
                            local curH = a.oldHeight + (a.targetFullH - a.oldHeight) * heightEp
                            card:SetHeight(curH)
                            UpdateDetailLayout()
                            if fadeT >= 1 and heightT >= 1 then
                                for _, entry in ipairs(a.toShow) do
                                    entry.frame:SetAlpha(1)
                                end
                                card:SetHeight(a.targetFullH)
                                card.relayoutAnim = nil
                                self:SetScript("OnUpdate", nil)
                                UpdateDetailLayout()
                            end
                        end)
                    end
                end

                for _, opt in ipairs(options) do
                    -- Resolve get/set fallbacks if missing
                    local g = opt.get
                    local s = opt.set
                    if not g and opt.dbKey then
                        if opt.type == "color" then
                            g = function()
                                local r = _G.OptionsData_GetDB(opt.dbKey .. "R")
                                local g = _G.OptionsData_GetDB(opt.dbKey .. "G")
                                local b = _G.OptionsData_GetDB(opt.dbKey .. "B")
                                local a = opt.hasAlpha and _G.OptionsData_GetDB(opt.dbKey .. "A") or 1
                                if r == nil then
                                    if type(opt.default) == "table" then return unpack(opt.default) end
                                    return 1, 1, 1, 1
                                end
                                return r, g, b, a
                            end
                        else
                            g = function() return _G.OptionsData_GetDB(opt.dbKey, opt.default) end
                        end
                    end
                    if not s and opt.dbKey then
                        if opt.type == "color" then
                            s = function(nr, ng, nb, na)
                                _G.OptionsData_SetDB(opt.dbKey .. "R", nr)
                                _G.OptionsData_SetDB(opt.dbKey .. "G", ng)
                                _G.OptionsData_SetDB(opt.dbKey .. "B", nb)
                                if opt.hasAlpha then _G.OptionsData_SetDB(opt.dbKey .. "A", na) end
                            end
                        else
                            s = function(v) _G.OptionsData_SetDB(opt.dbKey, v) end
                        end
                    end
                    if opt.refreshIds and s then
                        local origSet = s
                        if opt.type == "color" then
                            s = function(nr, ng, nb, na)
                                origSet(nr, ng, nb, na)
                                RefreshLinkedTargets(opt.refreshIds)
                            end
                        else
                            s = function(v)
                                origSet(v)
                                RefreshLinkedTargets(opt.refreshIds)
                            end
                        end
                    end

                    if opt.type == "section" then
                        -- Finalize previous card if any (relayout to apply visibility)
                        if currentCard then
                            RelayoutCard(currentCard)
                        end

                        currentCard = CreateAccordionCard(detailContent, opt.name)
                        currentCard.contentHeight = 0
                        currentCard.optionIds = {}
                        currentCard.widgetList = {}
                        tinsert(currentDetailCards, currentCard)
                    else
                        if not currentCard then
                            currentCard = CreateAccordionCard(detailContent, moduleSubName)
                            currentCard.contentHeight = 0
                            currentCard.optionIds = {}
                            currentCard.widgetList = {}
                            tinsert(currentDetailCards, currentCard)
                        end
                        
                        -- Store the option identifier to track its parent card
                        local optId = opt.dbKey or (opt.type == "presencePreview" and "presencePreview") or (moduleSubName .. "_" .. (type(opt.name)=="function" and opt.name() or opt.name or ""):gsub("%s+", "_"))
                        currentCard.optionIds[optId] = true

                        local widget
                        if opt.type == "binary" or opt.type == "toggle" then
                            widget = _G.OptionsWidgets_CreateToggleSwitch(currentCard.settingsContainer, opt.name, opt.desc or "", g, s, opt.disabled, opt.tooltip)
                            if widget then
                                if opt.hidden and type(opt.hidden) == "function" then
                                    local origRefresh = widget.Refresh
                                    widget.Refresh = function(self)
                                        if origRefresh then origRefresh(self) end
                                        if opt.hidden() then self:Hide() else self:Show() end
                                    end
                                    if opt.hidden() then widget:Hide() end
                                end
                                if widget.Refresh then detailOptionFrames[optId] = widget end
                            end
                        elseif opt.type == "slider" then
                            widget = _G.OptionsWidgets_CreateSlider(currentCard.settingsContainer, opt.name, opt.desc or "", g, s, opt.min or 0, opt.max or 100, opt.disabled, opt.step or 1, opt.tooltip)
                            if widget then
                                if opt.hidden and type(opt.hidden) == "function" then
                                    local origRefresh = widget.Refresh
                                    widget.Refresh = function(self)
                                        if origRefresh then origRefresh(self) end
                                        if opt.hidden() then self:Hide() else self:Show() end
                                    end
                                    if opt.hidden() then widget:Hide() end
                                end
                                if widget.Refresh then detailOptionFrames[optId] = widget end
                            end
                        elseif opt.type == "dropdown" then
                            local resetBtn = opt.resetButton
                            if resetBtn and resetBtn.onClick and opt.refreshIds then
                                local origOnClick = resetBtn.onClick
                                resetBtn = {
                                    onClick = function()
                                        origOnClick()
                                        RefreshLinkedTargets(opt.refreshIds)
                                        if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                                    end,
                                    tooltip = resetBtn.tooltip,
                                }
                            end
                            widget = _G.OptionsWidgets_CreateCustomDropdown(currentCard.settingsContainer, opt.name, opt.desc or "", opt.options, g, s, opt.displayFn, opt.searchable, opt.disabled, opt.tooltip, resetBtn)
                            if widget and widget.Refresh then detailOptionFrames[optId] = widget end
                        elseif opt.type == "color" then
                            widget = _G.OptionsWidgets_CreateColorSwatch(currentCard.settingsContainer, opt.name, opt.desc or "", g, s, opt.hasAlpha, opt.tooltip)
                            if widget and widget.Refresh then detailOptionFrames[optId] = widget end
                        elseif opt.type == "presencePreview" then
                            local previewWidget = addon.Presence and addon.Presence.CreatePreviewWidget and addon.Presence.CreatePreviewWidget(currentCard.settingsContainer, {
                                getTypeName = function()
                                    return _G.OptionsData_GetDB("presencePreviewType", "LEVEL_UP")
                                end,
                                setTypeName = function(v)
                                    _G.OptionsData_SetDB("presencePreviewType", v)
                                end,
                                notify = function()
                                    if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                                end,
                                scale = 0.55,
                            })
                            widget = previewWidget and previewWidget.frame or nil
                            if widget and previewWidget.Refresh then
                                widget.Refresh = previewWidget.Refresh
                            end
                            detailOptionFrames[optId] = widget
                        elseif opt.type == "header" then
                            widget = _G.OptionsWidgets_CreateSectionHeader(currentCard.settingsContainer, opt.name)
                        elseif opt.type == "button" then
                            local onClick = opt.onClick
                            if opt.refreshIds and #opt.refreshIds > 0 then
                                onClick = function()
                                    if opt.onClick then opt.onClick() end
                                    RefreshLinkedTargets(opt.refreshIds)
                                end
                            end
                            widget = _G.OptionsWidgets_CreateButton(currentCard.settingsContainer, opt.name, onClick, { tooltip = opt.tooltip })
                        elseif opt.type == "editbox" then
                            if _G.OptionsWidgets_CreateEditBox then
                                widget = _G.OptionsWidgets_CreateEditBox(currentCard.settingsContainer, opt.labelText or opt.name, g, s, {
                                    height = opt.height,
                                    readonly = opt.readonly,
                                    storeRef = opt.storeRef,
                                    tooltip = opt.tooltip,
                                })
                            end
                        elseif opt.type == "reorderList" then
                            if OptionsWidgets_CreateReorderList then
                                widget = OptionsWidgets_CreateReorderList(currentCard.settingsContainer, currentCard.settingsContainer, opt, detailScroll, detailContent, function()
                                    if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                                end)
                            end
                        elseif opt.type == "blacklistGrid" then
                            if _G.OptionsWidgets_CreateBlacklistGrid then
                                widget = _G.OptionsWidgets_CreateBlacklistGrid(currentCard.settingsContainer, opt.name, {
                                    desc = opt.desc or "",
                                    tooltip = opt.tooltip,
                                })
                            end
                        elseif opt.type == "colorMatrix" then
                            -- Emulate a mini-card inside the settings container
                            local cmContainer = CreateFrame("Frame", nil, currentCard.settingsContainer)
                            local yOff = 0
                            
                            local lbl = _G.OptionsWidgets_CreateSectionHeader(cmContainer, opt.name or "Colors")
                            lbl:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 0, yOff)
                            lbl:SetPoint("RIGHT", cmContainer, "RIGHT", 0, 0)
                            yOff = yOff - 24
                            
                            local keys = opt.keys or addon.COLOR_KEYS_ORDER or {}
                            local defaultMap = opt.defaultMap or addon.QUEST_COLORS or {}
                            local swatches = {}
                            
                            local sub = _G.OptionsWidgets_CreateSectionHeader(cmContainer, L["Quest types"])
                            sub:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 0, yOff)
                            yOff = yOff - 20
                            
                            for _, key in ipairs(keys) do
                                local getTbl = function() local db = _G.OptionsData_GetDB(opt.dbKey, nil) return db and db[key] end
                                local setKeyVal = function(v) 
                                    addon.EnsureDB()
                                    local _rdb = _G[addon.DB_NAME]
                                    if not _rdb[opt.dbKey] then _rdb[opt.dbKey] = {} end
                                    _rdb[opt.dbKey][key] = v
                                    if not addon._colorPickerLive and addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                                end
                                local labelText = addon.L[(opt.labelMap and opt.labelMap[key]) or key:gsub("^%l", string.upper)]
                                local row = _G.OptionsWidgets_CreateColorSwatchRow(cmContainer, nil, labelText, defaultMap[key], getTbl, setKeyVal, function() if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end end)
                                row:ClearAllPoints()
                                row:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 10, yOff)
                                row:SetPoint("RIGHT", cmContainer, "RIGHT", 0, 0)
                                yOff = yOff - 28
                                swatches[#swatches+1] = row
                            end
                            
                            local resetBtn = _G.OptionsWidgets_CreateButton(cmContainer, L["Reset quest types"], function()
                                _G.OptionsData_SetDB(opt.dbKey, nil)
                                _G.OptionsData_SetDB("sectionColors", nil)
                                for _, sw in ipairs(swatches) do if sw.Refresh then sw:Refresh() end end
                                if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                            end, { width = 120, height = 22 })
                            resetBtn:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 10, yOff)
                            yOff = yOff - 30

                            local overridesSub = _G.OptionsWidgets_CreateSectionHeader(cmContainer, L["Element overrides"])
                            overridesSub:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 0, yOff - 10)
                            yOff = yOff - 30
                            
                            local overrideRows = {}
                            for _, ov in ipairs(opt.overrides or {}) do
                                local getTbl = function() return _G.OptionsData_GetDB(ov.dbKey, nil) end
                                local setKeyVal = function(v) _G.OptionsData_SetDB(ov.dbKey, v); if not addon._colorPickerLive and addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end end
                                local row = _G.OptionsWidgets_CreateColorSwatchRow(cmContainer, nil, ov.name, ov.default, getTbl, setKeyVal, function() if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end end)
                                row:ClearAllPoints()
                                row:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 10, yOff)
                                row:SetPoint("RIGHT", cmContainer, "RIGHT", 0, 0)
                                yOff = yOff - 28
                                overrideRows[#overrideRows+1] = row
                            end
                            
                            local resetOv = _G.OptionsWidgets_CreateButton(cmContainer, L["Reset overrides"], function()
                                for _, ov in ipairs(opt.overrides or {}) do _G.OptionsData_SetDB(ov.dbKey, nil) end
                                for _, r in ipairs(overrideRows) do if r.Refresh then r:Refresh() end end
                                if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                            end, { width = 120, height = 22 })
                            resetOv:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 10, yOff)
                            yOff = yOff - 28

                        elseif opt.type == "colorMatrixFull" then
                            -- Compact color cards in 3-column grid
                            local cmfContainer = CreateFrame("Frame", nil, currentCard.settingsContainer)
                            local notifyFn = function() if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end end

                            local function getMatrix()
                                addon.EnsureDB()
                                local m = _G.OptionsData_GetDB(opt.dbKey, nil)
                                if type(m) ~= "table" then
                                    m = { categories = {}, overrides = {} }
                                    _G.OptionsData_SetDB(opt.dbKey, m)
                                else
                                    m.categories = m.categories or {}
                                    m.overrides = m.overrides or {}
                                end
                                return m
                            end

                            local function getOverride(key)
                                local m = getMatrix()
                                local v = m.overrides and m.overrides[key]
                                if key == "useCompletedOverride" and v == nil then return true end
                                if key == "useCurrentQuestOverride" and v == nil then return true end
                                return v
                            end
                            local function setOverride(key, v)
                                local m = getMatrix()
                                m.overrides[key] = v
                                _G.OptionsData_SetDB(opt.dbKey, m)
                                if not addon._colorPickerLive then notifyFn() end
                            end

                            -- Grid constants
                            local COLS = 3
                            local CARD_GAP = 12
                            local CARD_H = 108
                            local CARD_PAD = 14
                            local widgetFontPath = (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"
                            local widgetLabelColor = { 0.88, 0.88, 0.92 }

                            local allCards = {}
                            local overrideGroupMap = {}
                            local otherColorRows = {}
                            local completedObjRow

                            -- Build a compact color card for a category
                            local function BuildCompactCard(parentFrame, key)
                                local labelBase = addon.L[(addon.SECTION_LABELS and addon.SECTION_LABELS[key]) or key]
                                local card = CreateFrame("Frame", nil, parentFrame)
                                card:SetHeight(CARD_H)
                                card.groupKey = key

                                -- Card background
                                local bg = card:CreateTexture(nil, "BACKGROUND")
                                bg:SetAllPoints(card)
                                bg:SetColorTexture(0.08, 0.08, 0.10, 0.88)

                                -- Subtle border
                                if addon.CreateBorder then
                                    addon.CreateBorder(card, { 0.30, 0.32, 0.40, 0.85 })
                                end

                                -- 2px accent bar at top using category base color
                                local accentBar = card:CreateTexture(nil, "OVERLAY")
                                accentBar:SetHeight(2)
                                accentBar:SetPoint("TOPLEFT", card, "TOPLEFT", 0, 0)
                                accentBar:SetPoint("TOPRIGHT", card, "TOPRIGHT", 0, 0)
                                card.accentBar = accentBar

                                local nameLabel = card:CreateFontString(nil, "OVERLAY")
                                nameLabel:SetFont(widgetFontPath, 13, "OUTLINE")
                                nameLabel:SetTextColor(widgetLabelColor[1], widgetLabelColor[2], widgetLabelColor[3])
                                nameLabel:SetText((labelBase and labelBase ~= "") and (string.gsub(labelBase, "(%a)([%w_']*)", function(a, b) return string.upper(a) .. string.lower(b) end)) or labelBase)
                                nameLabel:SetPoint("TOPLEFT", card, "TOPLEFT", 10, -8)
                                nameLabel:SetJustifyH("LEFT")

                                local resetBtn = _G.OptionsWidgets_CreateButton(card, L["Reset"], function()
                                    local m = getMatrix()
                                    if m.categories and m.categories[key] then
                                        m.categories[key] = nil
                                        _G.OptionsData_SetDB(opt.dbKey, m)
                                        notifyFn()
                                        card:Refresh()
                                    end
                                end, { width = 52, height = 20 })
                                resetBtn:SetPoint("TOPRIGHT", card, "TOPRIGHT", -8, -7)

                                local questColorKey = (key == "ACHIEVEMENTS" and "ACHIEVEMENT") or (key == "RARES" and "RARE") or key
                                local baseColor = (addon.QUEST_COLORS and addon.QUEST_COLORS[questColorKey]) or (addon.QUEST_COLORS and addon.QUEST_COLORS.DEFAULT) or { 0.9, 0.9, 0.9 }
                                local sectionColor = (addon.SECTION_COLORS and addon.SECTION_COLORS[key]) or (addon.SECTION_COLORS and addon.SECTION_COLORS.DEFAULT) or { 0.9, 0.9, 0.9 }
                                local unifiedDef = (key == "NEARBY" or key == "CURRENT" or key == "CURRENT_EVENT") and sectionColor or baseColor

                                local zoneLabel = (key == "SCENARIO") and ((addon.L and addon.L["Stage"]) or "Stage") or ((addon.L and addon.L["Zone"]) or "Zone")
                                local catDefs = {
                                    { subKey = "section",   abbr = L["Section"] or "Section",   full = "Section",   def = unifiedDef },
                                    { subKey = "title",     abbr = L["Title"] or "Title",     full = "Title",     def = unifiedDef },
                                    { subKey = "zone",      abbr = (key == "SCENARIO") and (L["Stage"] or "Stage") or (L["Zone"] or "Zone"), full = zoneLabel, def = addon.ZONE_COLOR or { 0.55, 0.65, 0.75 } },
                                    { subKey = "objective", abbr = L["Objective"] or "Objective", full = "Objective", def = unifiedDef },
                                }

                                card.swatches = {}
                                -- 2×2 grid: swatch-left layout, more breathing room
                                local SWATCH_ROW_H = 32
                                local SWATCH_GAP_X = 14
                                local SWATCH_W = 90
                                for i, cd in ipairs(catDefs) do
                                    local getTbl = function()
                                        local m = getMatrix()
                                        local cats = m.categories or {}
                                        return cats[key] and cats[key][cd.subKey] or nil
                                    end
                                    local setKeyVal = function(v)
                                        local m = getMatrix()
                                        m.categories[key] = m.categories[key] or {}
                                        m.categories[key][cd.subKey] = (type(v) == "table" and v[1] and v[2] and v[3]) and { v[1], v[2], v[3] } or v
                                        _G.OptionsData_SetDB(opt.dbKey, m)
                                        if not addon._colorPickerLive then notifyFn() end
                                    end
                                    local sw = _G.OptionsWidgets_CreateMiniSwatch(card, cd.abbr, cd.def, getTbl, setKeyVal, notifyFn, cd.full)
                                    local col = (i - 1) % 2
                                    local row = math.floor((i - 1) / 2)
                                    local xOfs = 10 + col * (SWATCH_W + SWATCH_GAP_X)
                                    local yOfs = -(8 + nameLabel:GetStringHeight() + 6 + row * SWATCH_ROW_H)
                                    sw:ClearAllPoints()
                                    sw:SetPoint("TOPLEFT", card, "TOPLEFT", xOfs, yOfs)
                                    card.swatches[#card.swatches + 1] = sw
                                end

                                function card:Refresh()
                                    for _, sw in ipairs(self.swatches) do if sw.Refresh then sw:Refresh() end end
                                    -- Update accent bar from live section color
                                    local m = getMatrix()
                                    local cats = m.categories or {}
                                    local catData = cats[self.groupKey]
                                    local secColor = (catData and catData.section) or unifiedDef
                                    local r, g, b = secColor[1], secColor[2], secColor[3]
                                    self.accentBar:SetColorTexture(r, g, b, 1)
                                end

                                allCards[#allCards + 1] = card
                                card:Refresh()
                                return card
                            end

                            -- Position cards in a grid within a container
                            local function PositionGrid(gridFrame, cards, cols, cardH, gap)
                                local gridW = gridFrame:GetWidth()
                                if gridW < 10 then gridW = 600 end
                                local cardW = math.floor((gridW - (cols - 1) * gap) / cols)
                                for idx, c in ipairs(cards) do
                                    local col = (idx - 1) % cols
                                    local row = math.floor((idx - 1) / cols)
                                    c:ClearAllPoints()
                                    c:SetPoint("TOPLEFT", gridFrame, "TOPLEFT", col * (cardW + gap), -row * (cardH + gap))
                                    c:SetSize(cardW, cardH)
                                end
                            end

                            -- LayoutAll repositions everything and resizes the container
                            local perCatCards = {}
                            local overrideCards = {}
                            local perCatGrid, overrideGrid
                            local perCatHdr, resetAllBtn, goHdr, otherHdr
                            local ovCompleted, ovCurrentZone, ovCurrentQuest, ovCompletedObj

                            local function LayoutAll()
                                local yOff = 0

                                perCatHdr:ClearAllPoints()
                                perCatHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                                resetAllBtn:ClearAllPoints()
                                resetAllBtn:SetPoint("TOPRIGHT", cmfContainer, "TOPRIGHT", 0, yOff)
                                yOff = yOff - 28

                                -- Per-category grid
                                local numRows = math.ceil(#perCatCards / COLS)
                                local gridH = numRows * CARD_H + math.max(0, numRows - 1) * CARD_GAP
                                perCatGrid:ClearAllPoints()
                                perCatGrid:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                perCatGrid:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                                perCatGrid:SetHeight(gridH)
                                PositionGrid(perCatGrid, perCatCards, COLS, CARD_H, CARD_GAP)
                                yOff = yOff - gridH

                                yOff = yOff - 16
                                goHdr:ClearAllPoints()
                                goHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                                yOff = yOff - 28

                                ovCompleted:ClearAllPoints()
                                ovCompleted:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                ovCompleted:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                                yOff = yOff - 40

                                ovCurrentZone:ClearAllPoints()
                                ovCurrentZone:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                ovCurrentZone:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                                yOff = yOff - 40

                                ovCurrentQuest:ClearAllPoints()
                                ovCurrentQuest:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                ovCurrentQuest:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                                yOff = yOff - 40

                                -- Override grid: show only visible cards in a single row
                                local visibleOv = {}
                                for _, c in ipairs(overrideCards) do
                                    if c:IsShown() then visibleOv[#visibleOv + 1] = c end
                                end
                                if #visibleOv > 0 then
                                    overrideGrid:ClearAllPoints()
                                    overrideGrid:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                    overrideGrid:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                                    overrideGrid:SetHeight(CARD_H)
                                    overrideGrid:Show()
                                    PositionGrid(overrideGrid, visibleOv, #visibleOv, CARD_H, CARD_GAP)
                                    yOff = yOff - CARD_H
                                else
                                    overrideGrid:Hide()
                                end

                                yOff = yOff - 16
                                otherHdr:ClearAllPoints()
                                otherHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                                yOff = yOff - 28

                                ovCompletedObj:ClearAllPoints()
                                ovCompletedObj:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                ovCompletedObj:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                                yOff = yOff - 40

                                for _, row in ipairs(otherColorRows) do
                                    if row:IsShown() then
                                        row:ClearAllPoints()
                                        row:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                        row:SetPoint("RIGHT", cmfContainer, "RIGHT", 0, 0)
                                        yOff = yOff - 30
                                    end
                                end

                                local newHeight = math.max(1, -yOff)
                                cmfContainer:SetHeight(newHeight)
                                currentCard.contentHeight = newHeight
                                currentCard.fullHeight = newHeight + 80
                                UpdateDetailLayout()
                            end

                            -- Build the layout
                            local groupOrder = addon.GetGroupOrder and addon.GetGroupOrder() or {}
                            if type(groupOrder) ~= "table" or #groupOrder == 0 then groupOrder = addon.GROUP_ORDER or {} end
                            local GROUPING_OVERRIDE_KEYS = { CURRENT = true, NEARBY = true, COMPLETE = true }
                            local yOff = 0

                            perCatHdr = _G.OptionsWidgets_CreateSectionHeader(cmfContainer, L["Per category"])
                            perCatHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                            resetAllBtn = _G.OptionsWidgets_CreateButton(cmfContainer, L["Reset all to defaults"], function()
                                _G.OptionsData_SetDB(opt.dbKey, nil)
                                _G.OptionsData_SetDB("questColors", nil)
                                _G.OptionsData_SetDB("sectionColors", nil)
                                for _, c in ipairs(allCards) do if c.Refresh then c:Refresh() end end
                                for _, r in ipairs(otherColorRows) do if r.Refresh then r:Refresh() end end
                                notifyFn()
                            end, { width = 140, height = 22 })
                            resetAllBtn:SetPoint("TOPRIGHT", cmfContainer, "TOPRIGHT", 0, yOff)
                            yOff = yOff - 28

                            -- Per-category grid
                            perCatGrid = CreateFrame("Frame", nil, cmfContainer)
                            local perCatKeys = {}
                            for _, key in ipairs(groupOrder) do
                                if not GROUPING_OVERRIDE_KEYS[key] then
                                    tinsert(perCatKeys, key)
                                end
                            end
                            for _, key in ipairs(perCatKeys) do
                                local card = BuildCompactCard(perCatGrid, key)
                                tinsert(perCatCards, card)
                            end
                            local numRows = math.ceil(#perCatCards / COLS)
                            local gridH = numRows * CARD_H + math.max(0, numRows - 1) * CARD_GAP
                            perCatGrid:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                            perCatGrid:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                            perCatGrid:SetHeight(gridH)
                            yOff = yOff - gridH

                            yOff = yOff - 16
                            goHdr = _G.OptionsWidgets_CreateSectionHeader(cmfContainer, L["Section Overrides"])
                            goHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                            yOff = yOff - 28

                            ovCompleted = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["Ready to Turn In overrides base colours"], L["Ready to Turn In uses its colours for quests in that section."], function() return getOverride("useCompletedOverride") end, function(v)
                                setOverride("useCompletedOverride", v)
                                local gf = overrideGroupMap["COMPLETE"]
                                if gf then gf:SetShown(v and true or false); LayoutAll() end
                            end)
                            ovCompleted:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                            ovCompleted:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                            yOff = yOff - 40

                            ovCurrentZone = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["Current Zone overrides base colours"], L["Current Zone uses its colours for quests in that section."], function() return getOverride("useCurrentZoneOverride") end, function(v)
                                setOverride("useCurrentZoneOverride", v)
                                local gf = overrideGroupMap["NEARBY"]
                                if gf then gf:SetShown(v and true or false); LayoutAll() end
                            end)
                            ovCurrentZone:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                            ovCurrentZone:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                            yOff = yOff - 40

                            ovCurrentQuest = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["Current Quest overrides base colours"], L["Current Quest uses its colours for quests in that section."], function() return getOverride("useCurrentQuestOverride") end, function(v)
                                setOverride("useCurrentQuestOverride", v)
                                local gf = overrideGroupMap["CURRENT"]
                                if gf then gf:SetShown(v and true or false); LayoutAll() end
                            end)
                            ovCurrentQuest:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                            ovCurrentQuest:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                            yOff = yOff - 40

                            -- Override color cards in a single-row grid
                            overrideGrid = CreateFrame("Frame", nil, cmfContainer)
                            for _, key in ipairs(groupOrder) do
                                if GROUPING_OVERRIDE_KEYS[key] then
                                    local card = BuildCompactCard(overrideGrid, key)
                                    tinsert(overrideCards, card)
                                    overrideGroupMap[key] = card
                                end
                            end
                            -- Hide override cards whose toggle is OFF
                            if not getOverride("useCompletedOverride") and overrideGroupMap["COMPLETE"] then overrideGroupMap["COMPLETE"]:Hide() end
                            if not getOverride("useCurrentZoneOverride") and overrideGroupMap["NEARBY"] then overrideGroupMap["NEARBY"]:Hide() end
                            if not getOverride("useCurrentQuestOverride") and overrideGroupMap["CURRENT"] then overrideGroupMap["CURRENT"]:Hide() end

                            local visibleOv = {}
                            for _, c in ipairs(overrideCards) do if c:IsShown() then visibleOv[#visibleOv + 1] = c end end
                            if #visibleOv > 0 then
                                overrideGrid:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                overrideGrid:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                                overrideGrid:SetHeight(CARD_H)
                                PositionGrid(overrideGrid, visibleOv, #visibleOv, CARD_H, CARD_GAP)
                                yOff = yOff - CARD_H
                            else
                                overrideGrid:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                overrideGrid:SetHeight(1)
                            end

                            yOff = yOff - 16
                            otherHdr = _G.OptionsWidgets_CreateSectionHeader(cmfContainer, L["Other colors"])
                            otherHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                            yOff = yOff - 28

                            ovCompletedObj = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["Use distinct color for completed objectives"], L["When on, completed objectives use the color below."], function() return _G.OptionsData_GetDB("useCompletedObjectiveColor", true) end, function(v)
                                _G.OptionsData_SetDB("useCompletedObjectiveColor", v)
                                notifyFn()
                                if completedObjRow then completedObjRow:SetShown(v and true or false); LayoutAll() end
                            end)
                            ovCompletedObj:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                            ovCompletedObj:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                            yOff = yOff - 40

                            local otherDefs = {
                                { dbKey = "highlightColor", label = L["Highlight"], def = (addon.HIGHLIGHT_COLOR_DEFAULT or { 0.4, 0.7, 1 }) },
                                { dbKey = "completedObjectiveColor", label = L["Completed objective"], def = (addon.OBJ_DONE_COLOR or { 0.20, 1.00, 0.40 }), isCompletedObj = true },
                                { dbKey = "progressBarFillColor", label = L["Progress bar fill"], def = { 0.40, 0.65, 0.90, 0.85 }, disabled = function() return _G.OptionsData_GetDB("progressBarUseCategoryColor", true) end, hasAlpha = true },
                                { dbKey = "progressBarTextColor", label = L["Progress bar text"], def = { 0.95, 0.95, 0.95 } },
                            }

                            for _, od in ipairs(otherDefs) do
                                local getTbl = function() return _G.OptionsData_GetDB(od.dbKey, nil) end
                                local setKeyVal = function(v) _G.OptionsData_SetDB(od.dbKey, v); if not addon._colorPickerLive then notifyFn() end end
                                local row = _G.OptionsWidgets_CreateColorSwatchRow(cmfContainer, nil, od.label, od.def, getTbl, setKeyVal, notifyFn, od.disabled, od.hasAlpha)
                                row:ClearAllPoints()
                                row:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                row:SetPoint("RIGHT", cmfContainer, "RIGHT", 0, 0)
                                tinsert(otherColorRows, row)
                                if od.isCompletedObj then completedObjRow = row end
                                yOff = yOff - 30
                            end

                            -- Hide completed objective swatch if toggle is OFF
                            if completedObjRow and not _G.OptionsData_GetDB("useCompletedObjectiveColor", true) then
                                completedObjRow:Hide()
                            end

                            cmfContainer:SetHeight(-yOff)
                            -- OnSizeChanged: reposition grid cards when width changes (guard against height-only changes)
                            local lastCmfWidth = 0
                            cmfContainer:SetScript("OnSizeChanged", function(self, w)
                                if math.abs(w - lastCmfWidth) > 0.5 then
                                    lastCmfWidth = w
                                    LayoutAll()
                                end
                            end)
                            widget = cmfContainer
                        end

                        if widget then
                            widget:SetParent(currentCard.settingsContainer)
                            widget:Show()
                            widget._parentCard = currentCard

                            local isHeader = opt.type == "header"
                            if isHeader then
                                if widget.SetJustifyH then widget:SetJustifyH("LEFT") end
                                if widget.SetTextColor then
                                    widget:SetTextColor(0.58, 0.64, 0.74, 1)
                                end
                            end

                            tinsert(currentCard.widgetList, {
                                frame = widget,
                                isHeader = isHeader,
                                visibleWhen = opt.visibleWhen,
                            })

                            if opt.visibleWhen and type(opt.visibleWhen) == "function" and widget.Refresh then
                                local origRefresh = widget.Refresh
                                local cardRef = currentCard
                                widget.Refresh = function(self)
                                    if origRefresh then origRefresh(self) end
                                    RelayoutCard(cardRef)
                                end
                            end
                        end
                    end
                end

                if currentCard then
                    RelayoutCard(currentCard)
                end

                UpdateDetailLayout()
            end


            local function MakeTile(parent, name, icon, index, totalTiles, moduleKey)
                local tile = CreateFrame("Button", nil, parent)
                local TILE_W, TILE_H = 190, 160
                local TILE_GAP = 15
                local TILE_STRIDE = TILE_W + TILE_GAP
                tile:SetSize(TILE_W, TILE_H)
                
                local itemsPerRow = 4
                local row = math.floor((index-1) / itemsPerRow)
                local col = (index-1) % itemsPerRow
                
                local itemsInThisRow = itemsPerRow
                local totalRows = math.ceil(totalTiles / itemsPerRow)
                if row == totalRows - 1 and (totalTiles % itemsPerRow) ~= 0 then
                    itemsInThisRow = totalTiles % itemsPerRow
                end
                
                local rowWidth = (itemsInThisRow * TILE_W) + ((itemsInThisRow - 1) * TILE_GAP)
                local startX = -rowWidth / 2 + TILE_W / 2
                tile:SetPoint("TOP", parent, "TOP", startX + (col * TILE_STRIDE), -170 + (row * -(TILE_H + TILE_GAP)))

                -- Background
                local tBg = tile:CreateTexture(nil, "BACKGROUND")
                tBg:SetPoint("TOPLEFT", 1, -1)
                tBg:SetPoint("BOTTOMRIGHT", -1, 1)
                tBg:SetColorTexture(0.08, 0.08, 0.1, 1)

                -- Border
                local border = tile:CreateTexture(nil, "BORDER")
                border:SetAllPoints()
                border:SetColorTexture(0.13, 0.14, 0.18, 0.8)

                -- Icon
                local ic = tile:CreateTexture(nil, "ARTWORK")
                ic:SetSize(54, 54)
                ic:SetPoint("CENTER", 0, 16)
                ic:SetTexture("Interface\\Icons\\" .. (categoryIcons[name] or "INV_Misc_Question_01"))
                ic:SetVertexColor(0.80, 0.80, 0.85, 0.8)

                -- Soft divider between icon and label
                local tileDivider = tile:CreateTexture(nil, "ARTWORK")
                tileDivider:SetHeight(1)
                tileDivider:SetPoint("LEFT", 20, 0)
                tileDivider:SetPoint("RIGHT", -20, 0)
                tileDivider:SetPoint("BOTTOM", 0, 42)
                tileDivider:SetColorTexture(0.18, 0.18, 0.22, 0.3)

                -- Label
                local lbl = MakeText(tile, name, 13, 0.80, 0.80, 0.85, "CENTER")
                lbl:SetPoint("BOTTOM", 0, 22)
                tile.label = lbl

                -- Preview badge for early-access modules
                if moduleKey == "insight" or moduleKey == "yield" then
                    local prevBadge = MakeText(tile, "(Preview)", 9, 34/255, 139/255, 34/255, "CENTER")
                    prevBadge:SetPoint("TOP", lbl, "BOTTOM", 0, -1)
                    tile.previewBadge = prevBadge
                end

                -- Bottom accent glow (hidden by default, shown on hover)
                local bottomGlow = tile:CreateTexture(nil, "ARTWORK")
                bottomGlow:SetHeight(2)
                bottomGlow:SetPoint("BOTTOMLEFT", 1, 1)
                bottomGlow:SetPoint("BOTTOMRIGHT", -1, 1)
                bottomGlow:SetColorTexture(1, 1, 1, 0)

                tile:SetScript("OnEnter", function()
                    tBg:SetColorTexture(0.11, 0.12, 0.15, 1)
                    local ar, ag, ab = GetAccentColor()
                    border:SetColorTexture(ar, ag, ab, 0.6)
                    ic:SetVertexColor(1, 1, 1, 1)
                    lbl:SetTextColor(1, 1, 1)
                    bottomGlow:SetColorTexture(ar, ag, ab, 0.5)
                end)
                tile:SetScript("OnLeave", function()
                    tBg:SetColorTexture(0.08, 0.08, 0.1, 1)
                    border:SetColorTexture(0.13, 0.14, 0.18, 0.8)
                    ic:SetVertexColor(0.80, 0.80, 0.85, 0.8)
                    lbl:SetTextColor(0.80, 0.80, 0.85)
                    bottomGlow:SetColorTexture(1, 1, 1, 0)
                end)
                tile:SetScript("OnClick", function()
                    f.OpenModule(name, moduleKey)
                end)

                return tile
            end

            -- Group logic (tiles and sidebar; refreshable for live module toggle updates)
            local dashboardTilePool = {}
            local function BuildMainTilesList()
                local out = {}
                local seen = {}
                tinsert(out, { name = moduleLabels.axis or "Axis", moduleKey = "axis" })
                for _, cat in ipairs(addon.OptionCategories) do
                    local mk = cat.moduleKey
                    if mk and not seen[mk] and ShouldShowModuleOnDashboard(mk) then
                        seen[mk] = true
                        tinsert(out, { name = moduleLabels[mk] or mk, moduleKey = mk })
                    end
                end
                return out
            end

            local function RefreshDashboardTiles()
                local mainTiles = BuildMainTilesList()
                local TILE_W, TILE_H, TILE_GAP = 190, 160, 15
                local TILE_STRIDE = TILE_W + TILE_GAP
                local itemsPerRow = 4
                for i, tileInfo in ipairs(mainTiles) do
                    local tile = dashboardTilePool[tileInfo.moduleKey]
                    if not tile then
                        tile = MakeTile(dashboardView, tileInfo.name, nil, i, #mainTiles, tileInfo.moduleKey)
                        tile.moduleKey = tileInfo.moduleKey
                        dashboardTilePool[tileInfo.moduleKey] = tile
                    end
                    if tile.label then tile.label:SetText(tileInfo.name) end
                    local row = math.floor((i - 1) / itemsPerRow)
                    local col = (i - 1) % itemsPerRow
                    local totalRows = math.ceil(#mainTiles / itemsPerRow)
                    local itemsInThisRow = itemsPerRow
                    if row == totalRows - 1 and (#mainTiles % itemsPerRow) ~= 0 then
                        itemsInThisRow = #mainTiles % itemsPerRow
                    end
                    local rowWidth = (itemsInThisRow * TILE_W) + ((itemsInThisRow - 1) * TILE_GAP)
                    local startX = -rowWidth / 2 + TILE_W / 2
                    tile:ClearAllPoints()
                    tile:SetPoint("TOP", dashboardView, "TOP", startX + (col * TILE_STRIDE), -170 + (row * -(TILE_H + TILE_GAP)))
                    tile:Show()
                end
                for mk, tile in pairs(dashboardTilePool) do
                    local inList = false
                    for _, t in ipairs(mainTiles) do if t.moduleKey == mk then inList = true break end end
                    if not inList then tile:Hide() end
                end
            end

            RefreshDashboardTiles()

            -- ===== POPULATE SIDEBAR =====
            -- Group categories by moduleKey; build all groups so we can show/hide on refresh.
            local MODULE_LABELS = { ["axis"] = L["Axis"] or "Axis", ["modules"] = L["Modules"] or "Modules", ["focus"] = L["Focus"] or "Focus", ["presence"] = L["Presence"] or "Presence", ["insight"] = L["Insight"] or "Insight", ["yield"] = L["Yield"] or "Yield", ["vista"] = L["Vista"] or "Vista" }
            local groups = {}
            for i, cat in ipairs(addon.OptionCategories) do
                local mk
                if cat.key == "Profiles" or cat.key == "Modules" then
                    mk = "axis"
                else
                    mk = cat.moduleKey or "modules"
                end
                if not groups[mk] then groups[mk] = { label = MODULE_LABELS[mk] or L["Other"], categories = {} } end
                tinsert(groups[mk].categories, i)
            end
            local groupOrder = { "axis", "focus", "presence", "insight", "yield", "vista" }
            local sidebarRows = {}

            local lastSidebarRow = nil
            local yOff = 0

            -- Home button
            local homeBtn = CreateSidebarButton(sidebarScrollContent, "Home", "INV_Misc_Map_01", function()
                f.ShowDashboard()
            end)
            homeBtn:SetPoint("TOPLEFT", sidebarScrollContent, "TOPLEFT", 0, -SIDEBAR_TOP_PAD)
            lastSidebarRow = homeBtn
            yOff = SIDEBAR_TOP_PAD + TAB_ROW_HEIGHT
            tinsert(sidebarButtons, homeBtn)
            tinsert(sidebarRows, { type = "home", frame = homeBtn, bottom = homeBtn, offsetFromPrev = -SIDEBAR_TOP_PAD })

            -- Separator
            local sbSep = sidebarScrollContent:CreateTexture(nil, "ARTWORK")
            sbSep:SetHeight(1)
            sbSep:SetPoint("TOPLEFT", 15, -(yOff + 4))
            sbSep:SetPoint("TOPRIGHT", -15, -(yOff + 4))
            sbSep:SetColorTexture(0.15, 0.15, 0.2, 1)
            yOff = yOff + 9
            lastSidebarRow = CreateFrame("Frame", nil, sidebarScrollContent)
            lastSidebarRow:SetPoint("TOPLEFT", sidebarScrollContent, "TOPLEFT", 0, -yOff)
            lastSidebarRow:SetSize(1, 1)
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
                        local iconKey = categoryIcons[cat.name] or "INV_Misc_Question_01"
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
                        if mk == "insight" or mk == "yield" then
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
                local activeBtn = sidebarButtons[1]
                if sidebarState.view == "module" or sidebarState.view == "category" then
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
                RefreshDashboardTiles()
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
                if not collapsed then
                    SetGroupChildrenShown(g, true)
                end
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
                            end
                        end
                    end)
                else
                    if collapsed then
                        SetGroupChildrenShown(g, false)
                    end
                    if g.header and g.header.updateSpacer then g.header.updateSpacer() end
                    LayoutSidebar()
                end
            end

            LayoutSidebar()

            -- Set Home as active by default and collapse all groups
            SetActiveSidebarButton(sidebarButtons[1])
            f.ShowDashboard()
        end
        if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
        f:Show()
    end
end

