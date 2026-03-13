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
    fs:SetFont("Fonts\\FRIZQT__.TTF", size, "OUTLINE")
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
            dragBar:SetScript("OnDragStart", function()
                if not InCombatLockdown() then f:StartMoving() end
            end)
            dragBar:SetScript("OnDragStop", function()
                f:StopMovingOrSizing()
            end)

            if _G.OptionsWidgets_SetDef then
                _G.OptionsWidgets_SetDef({
                    FontPath = "Fonts\\FRIZQT__.TTF",
                    LabelSize = 13,
                    SectionSize = 11,
                })
            end

            local moduleLabels = {
                focus = L["Focus"] or "Focus",
                presence = L["Presence"] or "Presence",
                vista = L["Vista"] or "Vista",
                insight = L["Insight"] or "Insight",
                yield = L["Yield"] or "Yield",
            }

            local categoryIcons = {
                ["Profiles"] = "INV_Misc_GroupNeedMore",
                ["Modules"] = "INV_Misc_Wrench_01",
                ["Focus"] = "INV_Misc_Gear_01",
                ["Presence"] = "INV_Misc_Bell_01",
                ["Vista"] = "INV_Misc_Spyglass_02",
                ["Insight"] = "INV_Misc_Map_01",
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
            sidebarBg:SetColorTexture(0.04, 0.04, 0.055, 1)

            -- Sidebar divider line
            local sidebarDivider = sidebar:CreateTexture(nil, "BORDER")
            sidebarDivider:SetWidth(1)
            sidebarDivider:SetPoint("TOPRIGHT", 0, 0)
            sidebarDivider:SetPoint("BOTTOMRIGHT", 0, 0)
            sidebarDivider:SetColorTexture(0.15, 0.15, 0.2, 1)

            -- Sidebar Logo
            local sidebarLogo = MakeText(sidebar, "HS", 20, 1, 1, 1, "CENTER")
            sidebarLogo:SetPoint("TOP", 0, -18)

            local sidebarLogoSub = MakeText(sidebar, "HORIZON SUITE", 8, 0.4, 0.4, 0.5, "CENTER")
            sidebarLogoSub:SetPoint("TOP", sidebarLogo, "BOTTOM", 0, -3)

            -- Version text
            local versionStr = addon.VERSION or (GetAddOnMetadata and GetAddOnMetadata("HorizonSuite", "Version")) or ""
            if versionStr and versionStr ~= "" then
                local sidebarVersion = MakeText(sidebar, "v" .. versionStr, 7, 0.3, 0.3, 0.4, "CENTER")
                sidebarVersion:SetPoint("TOP", sidebarLogoSub, "BOTTOM", 0, -2)
            end

            -- Sidebar separator under logo
            local logoSep = sidebar:CreateTexture(nil, "ARTWORK")
            logoSep:SetHeight(1)
            logoSep:SetPoint("TOPLEFT", 15, -64)
            logoSep:SetPoint("TOPRIGHT", -15, -64)
            logoSep:SetColorTexture(0.15, 0.15, 0.2, 0.6)

            -- Sidebar scroll area for buttons
            local sidebarScrollFrame = CreateFrame("ScrollFrame", nil, sidebar)
            sidebarScrollFrame:SetPoint("TOPLEFT", 0, -72)
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

            local function CreateSidebarButton(label, iconName, onClick)
                local btn = CreateFrame("Button", nil, sidebarScrollContent)
                btn:SetSize(SIDEBAR_WIDTH - 1, 38)

                local btnBg = btn:CreateTexture(nil, "BACKGROUND")
                btnBg:SetAllPoints()
                btnBg:SetColorTexture(0, 0, 0, 0)
                btn.btnBg = btnBg

                local accentBar = btn:CreateTexture(nil, "ARTWORK")
                accentBar:SetSize(3, 22)
                accentBar:SetPoint("LEFT", 4, 0)
                local ar, ag, ab = GetAccentColor()
                accentBar:SetColorTexture(ar, ag, ab, 1)
                accentBar:Hide()
                btn.accentBar = accentBar

                if iconName then
                    local ic = btn:CreateTexture(nil, "ARTWORK")
                    ic:SetSize(16, 16)
                    ic:SetPoint("LEFT", 14, 0)
                    ic:SetTexture("Interface\\Icons\\" .. iconName)
                    ic:SetVertexColor(0.6, 0.6, 0.65, 1)
                    btn.icon = ic
                end

                local lbl = MakeText(btn, label, 11, 0.65, 0.65, 0.7, "LEFT")
                lbl:SetPoint("LEFT", iconName and 36 or 14, 0)
                lbl:SetPoint("RIGHT", -8, 0)
                lbl:SetWordWrap(false)
                btn.label = lbl

                btn:SetScript("OnEnter", function()
                    if btn ~= activeSidebarBtn then
                        btnBg:SetColorTexture(0.1, 0.1, 0.12, 1)
                        lbl:SetTextColor(0.9, 0.9, 0.95)
                        if btn.icon then btn.icon:SetVertexColor(0.9, 0.9, 0.95, 1) end
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
            local function ApplySmoothScroll(scrollFrame, scrollContent, speed)
                scrollFrame.targetScroll = nil
                scrollFrame.scrollSpeed = speed or 60
                
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
            searchDropdown:SetBackdropBorderColor(0.2, 0.2, 0.25, 1)
            searchDropdown:Hide()

            local searchDropdownScroll = CreateFrame("ScrollFrame", nil, searchDropdown)
            searchDropdownScroll:SetPoint("TOPLEFT", 6, -6)
            searchDropdownScroll:SetPoint("BOTTOMRIGHT", -6, 6)
            local searchDropdownContent = CreateFrame("Frame", nil, searchDropdownScroll)
            searchDropdownContent:SetSize(570, 1)
            searchDropdownScroll:SetScrollChild(searchDropdownContent)

            ApplySmoothScroll(searchDropdownScroll, searchDropdownContent, 30)
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

            ApplySmoothScroll(subCategoryScroll, subCategoryContent, 60)
            local detailTitle = MakeText(detailView, "MODULE SETTINGS", 18, 1, 1, 1, "LEFT")
            detailTitle:SetPoint("TOPLEFT", 180, -45)
            f.detailTitle = detailTitle

            -- Accent underline below detail title
            local detailTitleUnderline = detailView:CreateTexture(nil, "ARTWORK")
            detailTitleUnderline:SetHeight(1)
            detailTitleUnderline:SetPoint("TOPLEFT", detailTitle, "BOTTOMLEFT", 0, -6)
            detailTitleUnderline:SetPoint("RIGHT", detailView, "RIGHT", -40, 0)
            local ar, ag, ab = GetAccentColor()
            detailTitleUnderline:SetColorTexture(ar, ag, ab, 0.35)

            -- Transitions (faster animations per UX feedback)
            local function CrossfadeTo(targetView)
                dashboardView:Hide()
                detailView:Hide()
                subCategoryView:Hide()
                if head then head:Hide() end
                if headSub then headSub:Hide() end

                targetView:SetAlpha(0)
                targetView:Show()
                UIFrameFadeIn(targetView, 0.1, 0, 1)
            end

            f.ShowDashboard = function()
                detailView:Hide()
                subCategoryView:Hide()
                dashboardView:SetAlpha(0)
                dashboardView:Show()
                UIFrameFadeIn(dashboardView, 0.1, 0, 1)
                if head then head:Show() end
                if headSub then
                    headSub:Show()
                    headSub:SetText("Select a module to configure")
                end
                searchBox:Show()
                -- Reset sidebar active state to Home
                if sidebarButtons[1] then SetActiveSidebarButton(sidebarButtons[1]) end
            end

            -- Back Button (Persistent in Detail View)
            local backBtn = CreateFrame("Button", nil, detailView)
            backBtn:SetPoint("TOPLEFT", 35, -30)
            
            -- Back Button (Subcategory View)
            local subBackBtn = CreateFrame("Button", nil, subCategoryView)
            subBackBtn:SetPoint("TOPLEFT", 35, -30)
            
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

            -- Back button in detail view now goes to Subcategory Menu
            backBtn:SetScript("OnClick", function() 
                if f.currentModuleKey then
                    CrossfadeTo(subCategoryView)
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

            ApplySmoothScroll(detailScroll, detailContent, 60)
            local currentDetailCards = {}

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
                    -- Get the module label
                    local modName = targetCat.moduleKey and moduleLabels[targetCat.moduleKey] or targetCat.name

                    -- We first "open" the module so its subcategory tiles are created in the background
                    -- This ensures that hitting the "BACK" button from detail view has a populated subCategoryView.
                    f.OpenModule(modName, targetCat.moduleKey)

                    -- Navigate to the Detail View for that Category
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

                CrossfadeTo(detailView)
                detailContent:Show()
                detailScroll:SetVerticalScroll(0)

                -- Clear previous detail
                for _, card in ipairs(currentDetailCards) do
                    card:Hide()
                end
                wipe(currentDetailCards)

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
                            C_Timer.After(i * 0.02, function()
                                if card:IsShown() then
                                    card:SetPoint("TOPLEFT", detailContent, "TOPLEFT", xVal or 0, yVal)
                                    UIFrameFadeIn(card, 0.1, 0, 1)
                                end
                            end)
                        else
                            card:SetAlpha(1)
                        end
                    end
                end
            end

            f.OpenModule = function(name, moduleKey)
                if searchBox then searchBox:ClearFocus() end

                f.currentModuleKey = moduleKey

                -- Find all matching sub-categories
                local cats = {}
                for _, cat in ipairs(addon.OptionCategories) do
                    local match = false
                    if moduleKey and cat.moduleKey == moduleKey then
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
                    CrossfadeTo(subCategoryView)
                    subCategoryScroll:SetVerticalScroll(0)

                    -- Clear previous subtiles
                    for _, tile in ipairs(currentSubTiles) do
                        tile:Hide()
                    end
                    wipe(currentSubTiles)

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
                                C_Timer.After(i * 0.02, function()
                                    if tile:IsShown() then
                                        tile:SetPoint("TOPLEFT", subCategoryContent, "TOPLEFT", xVal, yVal)
                                        UIFrameFadeIn(tile, 0.1, 0, 1)
                                    end
                                end)
                            else
                                tile:SetAlpha(1)
                            end
                        end
                    end
                    subCategoryContent:SetHeight(math.max(1, tileYOffset))
                else
                    -- Only 1 category (or none), go straight to details
                    CrossfadeTo(detailView)
                    detailContent:Show()
                    detailScroll:SetVerticalScroll(0)
                    
                    -- Clear previous detail
                    for _, card in ipairs(currentDetailCards) do
                        card:Hide()
                    end
                    wipe(currentDetailCards)

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
                                    C_Timer.After(i * 0.02, function()
                                        if card:IsShown() then
                                            card:SetPoint("TOPLEFT", detailContent, "TOPLEFT", xVal or 0, yVal)
                                            UIFrameFadeIn(card, 0.1, 0, 1)
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
                divider:SetColorTexture(0.15, 0.17, 0.22, 0.35)

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

                -- Chevron indicator
                local chevron = MakeText(card, "\226\128\186", 12, 0.5, 0.5, 0.55, "RIGHT")
                chevron:SetPoint("TOPRIGHT", -25, -24)

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
                        chevron:SetText("\226\128\185")
                    else
                        cBg:SetColorTexture(0.06, 0.06, 0.07, 0.95)
                        chevron:SetText("\226\128\186")
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

                    if opt.type == "section" then
                        -- Finalize previous card if any
                        if currentCard then
                            currentCard.fullHeight = currentCard.contentHeight + 80
                        end

                        currentCard = CreateAccordionCard(detailContent, opt.name)
                        currentCard.contentHeight = 0
                        currentCard.optionIds = {}
                        tinsert(currentDetailCards, currentCard)
                    else
                        if not currentCard then
                            currentCard = CreateAccordionCard(detailContent, moduleSubName)
                            currentCard.contentHeight = 0
                            currentCard.optionIds = {}
                            tinsert(currentDetailCards, currentCard)
                        end
                        
                        -- Store the option identifier to track its parent card
                        local optId = opt.dbKey or (moduleSubName .. "_" .. (type(opt.name)=="function" and opt.name() or opt.name or ""):gsub("%s+", "_"))
                        currentCard.optionIds[optId] = true

                        local widget
                        if opt.type == "binary" or opt.type == "toggle" then
                            widget = _G.OptionsWidgets_CreateToggleSwitch(currentCard.settingsContainer, opt.name, opt.desc or "", g, s, opt.disabled, opt.tooltip)
                            if widget and widget.Refresh then detailOptionFrames[optId] = widget end
                        elseif opt.type == "slider" then
                            widget = _G.OptionsWidgets_CreateSlider(currentCard.settingsContainer, opt.name, opt.desc or "", g, s, opt.min or 0, opt.max or 100, opt.disabled, opt.step or 1, opt.tooltip)
                            if widget and widget.Refresh then detailOptionFrames[optId] = widget end
                        elseif opt.type == "dropdown" then
                            widget = _G.OptionsWidgets_CreateCustomDropdown(currentCard.settingsContainer, opt.name, opt.desc or "", opt.options, g, s, opt.displayFn, opt.searchable, opt.disabled, opt.tooltip)
                            if widget and widget.Refresh then detailOptionFrames[optId] = widget end
                        elseif opt.type == "color" then
                            widget = _G.OptionsWidgets_CreateColorSwatch(currentCard.settingsContainer, opt.name, opt.desc or "", g, s, opt.hasAlpha, opt.tooltip)
                            if widget and widget.Refresh then detailOptionFrames[optId] = widget end
                        elseif opt.type == "header" then
                            widget = _G.OptionsWidgets_CreateSectionHeader(currentCard.settingsContainer, opt.name)
                        elseif opt.type == "button" then
                            local onClick = opt.onClick
                            if opt.refreshIds and #opt.refreshIds > 0 then
                                onClick = function()
                                    if opt.onClick then opt.onClick() end
                                    for _, k in ipairs(opt.refreshIds) do
                                        local w = detailOptionFrames[k]
                                        if w and w.Refresh then w:Refresh() end
                                    end
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
                            -- Complex Focus matrix with collapsible categories
                            local cmfContainer = CreateFrame("Frame", nil, currentCard.settingsContainer)
                            local yOff = 0
                            
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
                                if not addon._colorPickerLive and addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                            end

                            local allGroupFrames = {}
                            
                            -- Build Collapsible Group logic
                            local function BuildCollapsibleGroup(containerParent, key, startY)
                                local labelBase = addon.L[(addon.SECTION_LABELS and addon.SECTION_LABELS[key]) or key]
                                local groupY = startY
                                
                                local groupHeader = CreateFrame("Button", nil, cmfContainer)
                                groupHeader:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 10, groupY)
                                groupHeader:SetPoint("RIGHT", cmfContainer, "RIGHT", 0, 0)
                                groupHeader:SetHeight(24)
                                
                                local hdrBg = groupHeader:CreateTexture(nil, "BACKGROUND")
                                hdrBg:SetAllPoints(groupHeader)
                                hdrBg:SetColorTexture(0.10, 0.10, 0.12, 0.5)

                                local chevron = groupHeader:CreateFontString(nil, "OVERLAY")
                                chevron:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", Def.LabelSize or 13, "OUTLINE")
                                chevron:SetTextColor(Def.TextColorSection and Def.TextColorSection[1] or 0.6, Def.TextColorSection and Def.TextColorSection[2] or 0.6, Def.TextColorSection and Def.TextColorSection[3] or 0.6)
                                chevron:SetText("+")
                                chevron:SetPoint("LEFT", groupHeader, "LEFT", 6, 0)

                                local hdrLabel = groupHeader:CreateFontString(nil, "OVERLAY")
                                hdrLabel:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", Def.LabelSize or 13, "OUTLINE")
                                hdrLabel:SetTextColor(Def.TextColorLabel and Def.TextColorLabel[1] or 0.9, Def.TextColorLabel and Def.TextColorLabel[2] or 0.9, Def.TextColorLabel and Def.TextColorLabel[3] or 0.9)
                                hdrLabel:SetText(labelBase)
                                hdrLabel:SetPoint("LEFT", chevron, "RIGHT", 6, 0)
                                hdrLabel:SetJustifyH("LEFT")

                                local questColorKey = (key == "ACHIEVEMENTS" and "ACHIEVEMENT") or (key == "RARES" and "RARE") or key
                                local baseColor = (addon.QUEST_COLORS and addon.QUEST_COLORS[questColorKey]) or (addon.QUEST_COLORS and addon.QUEST_COLORS.DEFAULT) or { 0.9, 0.9, 0.9 }
                                local sectionColor = (addon.SECTION_COLORS and addon.SECTION_COLORS[key]) or (addon.SECTION_COLORS and addon.SECTION_COLORS.DEFAULT) or { 0.9, 0.9, 0.9 }
                                local unifiedDef = (key == "NEARBY" or key == "CURRENT" or key == "CURRENT_EVENT") and sectionColor or baseColor 

                                local resetBtn = _G.OptionsWidgets_CreateButton(groupHeader, L["Reset"], function()
                                    local m = getMatrix()
                                    if m.categories and m.categories[key] then
                                        m.categories[key] = nil
                                        _G.OptionsData_SetDB(opt.dbKey, m)
                                        if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                                        if groupHeader.Refresh then groupHeader:Refresh() end
                                    end
                                end, { width = 50, height = 22 })
                                resetBtn:SetPoint("RIGHT", groupHeader, "RIGHT", -8, 0)

                                local previewSwatch = groupHeader:CreateTexture(nil, "ARTWORK")
                                previewSwatch:SetSize(14, 14)
                                previewSwatch:SetPoint("RIGHT", resetBtn, "LEFT", -8, 0)
                                previewSwatch:SetColorTexture(unifiedDef[1], unifiedDef[2], unifiedDef[3], 1)

                                groupHeader.expanded = false
                                groupHeader.rows = nil

                                local catDefs = {
                                    { subKey = "section",   suffix = "Section",   def = unifiedDef },
                                    { subKey = "title",     suffix = "Title",     def = unifiedDef },
                                    { subKey = "zone",      suffix = "Zone",      def = addon.ZONE_COLOR or { 0.55, 0.65, 0.75 } },
                                    { subKey = "objective", suffix = "Objective", def = unifiedDef },
                                }

                                local function EnsureRows()
                                    if groupHeader.rows then return end
                                    groupHeader.rows = {}
                                    local rY = groupY - 24
                                    for _, cd in ipairs(catDefs) do
                                        local rowLabel = cd.suffix
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
                                            if not addon._colorPickerLive and addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                                        end
                                        local row = _G.OptionsWidgets_CreateColorSwatchRow(cmfContainer, nil, rowLabel, cd.def, getTbl, setKeyVal, function() if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end end)
                                        row:ClearAllPoints()
                                        row:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 20, rY)
                                        row:SetPoint("RIGHT", cmfContainer, "RIGHT", 0, 0)
                                        groupHeader.rows[#groupHeader.rows + 1] = row
                                        rY = rY - 28
                                    end
                                end

                                local function SetExpanded(expand)
                                    groupHeader.expanded = expand
                                    if expand then
                                        EnsureRows()
                                        chevron:SetText("-")
                                        for _, r in ipairs(groupHeader.rows) do r:Show() end
                                        groupHeader.groupHeight = 24 + (4 * 28)
                                    else
                                        chevron:SetText("+")
                                        if groupHeader.rows then
                                            for _, r in ipairs(groupHeader.rows) do r:Hide() end
                                        end
                                        groupHeader.groupHeight = 24
                                    end
                                    -- Trigger full module rebuild to recalculate spacing
                                    f.OpenModule(nil, f.currentModuleKey)  
                                end

                                groupHeader:SetScript("OnClick", function()
                                    SetExpanded(not groupHeader.expanded)
                                end)

                                groupHeader.groupHeight = 24
                                table.insert(allGroupFrames, groupHeader)
                                return groupHeader
                            end
                            
                            local groupOrder = addon.GetGroupOrder and addon.GetGroupOrder() or {}
                            if type(groupOrder) ~= "table" or #groupOrder == 0 then groupOrder = addon.GROUP_ORDER or {} end
                            local GROUPING_OVERRIDE_KEYS = { CURRENT = true, NEARBY = true, COMPLETE = true }
                            
                            local perCatHdr = _G.OptionsWidgets_CreateSectionHeader(cmfContainer, L["Per category"])
                            perCatHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                            yOff = yOff - 24
                            
                            local resetAllBtn = _G.OptionsWidgets_CreateButton(cmfContainer, L["Reset all to defaults"], function()
                                _G.OptionsData_SetDB(opt.dbKey, nil)
                                _G.OptionsData_SetDB("questColors", nil)
                                _G.OptionsData_SetDB("sectionColors", nil)
                                if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                            end, { width = 140, height = 22 })
                            resetAllBtn:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 10, yOff)
                            yOff = yOff - 30

                            for _, key in ipairs(groupOrder) do
                                if not GROUPING_OVERRIDE_KEYS[key] then
                                    local grp = BuildCollapsibleGroup(cmfContainer, key, yOff)
                                    yOff = yOff - grp.groupHeight - 4
                                end
                            end
                            
                            yOff = yOff - 10
                            local goHdr = _G.OptionsWidgets_CreateSectionHeader(cmfContainer, L["Grouping Overrides"])
                            goHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                            yOff = yOff - 24

                            local ovCompleted = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["Ready to Turn In overrides base colours"], L["Ready to Turn In uses its colours for quests in that section."], function() return getOverride("useCompletedOverride") end, function(v) setOverride("useCompletedOverride", v) end)
                            ovCompleted:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 10, yOff)
                            ovCompleted:SetPoint("RIGHT", cmfContainer, "RIGHT", -10, 0)
                            yOff = yOff - 38

                            local ovCurrentZone = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["Current Zone overrides base colours"], L["Current Zone uses its colours for quests in that section."], function() return getOverride("useCurrentZoneOverride") end, function(v) setOverride("useCurrentZoneOverride", v) end)
                            ovCurrentZone:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 10, yOff)
                            ovCurrentZone:SetPoint("RIGHT", cmfContainer, "RIGHT", -10, 0)
                            yOff = yOff - 38

                            local ovCurrentQuest = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["Current Quest overrides base colours"], L["Current Quest uses its colours for quests in that section."], function() return getOverride("useCurrentQuestOverride") end, function(v) setOverride("useCurrentQuestOverride", v) end)
                            ovCurrentQuest:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 10, yOff)
                            ovCurrentQuest:SetPoint("RIGHT", cmfContainer, "RIGHT", -10, 0)
                            yOff = yOff - 38

                            for _, key in ipairs(groupOrder) do
                                if GROUPING_OVERRIDE_KEYS[key] then
                                    local grp = BuildCollapsibleGroup(cmfContainer, key, yOff)
                                    yOff = yOff - grp.groupHeight - 4
                                end
                            end

                            yOff = yOff - 10
                            local otherHdr = _G.OptionsWidgets_CreateSectionHeader(cmfContainer, L["Other colors"])
                            otherHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                            yOff = yOff - 24

                            local ovCompletedObj = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["Use distinct color for completed objectives"], L["When on, completed objectives use the color below."], function() return _G.OptionsData_GetDB("useCompletedObjectiveColor", true) end, function(v) _G.OptionsData_SetDB("useCompletedObjectiveColor", v); if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end end)
                            ovCompletedObj:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 10, yOff)
                            ovCompletedObj:SetPoint("RIGHT", cmfContainer, "RIGHT", -10, 0)
                            yOff = yOff - 38
                            
                            local otherDefs = {
                                { dbKey = "highlightColor", label = L["Highlight"], def = (addon.HIGHLIGHT_COLOR_DEFAULT or { 0.4, 0.7, 1 }) },
                                { dbKey = "completedObjectiveColor", label = L["Completed objective"], def = (addon.OBJ_DONE_COLOR or { 0.20, 1.00, 0.40 }) },
                                { dbKey = "progressBarFillColor", label = L["Progress bar fill"], def = { 0.40, 0.65, 0.90, 0.85 }, disabled = function() return _G.OptionsData_GetDB("progressBarUseCategoryColor", true) end, hasAlpha = true },
                                { dbKey = "progressBarTextColor", label = L["Progress bar text"], def = { 0.95, 0.95, 0.95 } },
                            }
                            
                            for _, od in ipairs(otherDefs) do
                                local getTbl = function() return _G.OptionsData_GetDB(od.dbKey, nil) end
                                local setKeyVal = function(v) _G.OptionsData_SetDB(od.dbKey, v); if not addon._colorPickerLive and addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end end
                                local row = _G.OptionsWidgets_CreateColorSwatchRow(cmfContainer, nil, od.label, od.def, getTbl, setKeyVal, function() if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end end, od.disabled, od.hasAlpha)
                                row:ClearAllPoints()
                                row:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 10, yOff)
                                row:SetPoint("RIGHT", cmfContainer, "RIGHT", 0, 0)
                                yOff = yOff - 28
                            end

                            cmfContainer:SetHeight(-yOff)
                            widget = cmfContainer
                        end

                        if widget then
                            widget:SetParent(currentCard.settingsContainer)
                            widget:Show()
                            
                            local isHeader = opt.type == "header"
                            local topGap = isHeader and 20 or 10
                            
                            widget:SetPoint("TOPLEFT", 30, -(currentCard.contentHeight + topGap))
                            
                            if isHeader then
                                widget:SetPoint("RIGHT", currentCard.settingsContainer, "RIGHT", -30, 0)
                                if widget.SetJustifyH then widget:SetJustifyH("LEFT") end
                                -- Make headers stand out a bit
                                if widget.SetTextColor then
                                    widget:SetTextColor(0.58, 0.64, 0.74, 1)
                                end
                            else
                                widget:SetPoint("RIGHT", currentCard.settingsContainer, "RIGHT", -30, 0)
                            end
                            
                            local widgetH = widget:GetHeight() or 40
                            if isHeader and widgetH < 20 then widgetH = 20 end
                            
                            currentCard.contentHeight = currentCard.contentHeight + widgetH + topGap
                        end
                    end
                end

                if currentCard then
                    currentCard.fullHeight = currentCard.contentHeight + 80
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

            -- Group logic
            local mainTiles = {}
            local seenModules = {}

            -- 1. Profiles & Modules (Core)
            for _, cat in ipairs(addon.OptionCategories) do
                if not cat.moduleKey then
                    tinsert(mainTiles, { name = cat.name })
                end
            end

            -- 2. Module Groups

            for _, cat in ipairs(addon.OptionCategories) do
                local mk = cat.moduleKey
                if mk and not seenModules[mk] then
                    seenModules[mk] = true
                    tinsert(mainTiles, { name = moduleLabels[mk] or mk, moduleKey = mk })
                end
            end

            for i, tileInfo in ipairs(mainTiles) do
                MakeTile(dashboardView, tileInfo.name, nil, i, #mainTiles, tileInfo.moduleKey)
            end

            -- ===== POPULATE SIDEBAR =====
            local yOff = 0

            -- Home button
            local homeBtn = CreateSidebarButton("Home", "INV_Misc_Map_01", function()
                f.ShowDashboard()
            end)
            homeBtn:SetPoint("TOPLEFT", sidebarScrollContent, "TOPLEFT", 0, -yOff)
            tinsert(sidebarButtons, homeBtn)
            yOff = yOff + 38

            -- Separator
            local sbSep = sidebarScrollContent:CreateTexture(nil, "ARTWORK")
            sbSep:SetHeight(1)
            sbSep:SetPoint("TOPLEFT", 15, -(yOff + 4))
            sbSep:SetPoint("TOPRIGHT", -15, -(yOff + 4))
            sbSep:SetColorTexture(0.15, 0.15, 0.2, 1)
            yOff = yOff + 9

            -- Module buttons
            for _, tileInfo in ipairs(mainTiles) do
                local tileName = tileInfo.name
                local tileModKey = tileInfo.moduleKey
                local iconKey = categoryIcons[tileName] or (tileModKey and categoryIcons[moduleLabels[tileModKey] or ""]) or "INV_Misc_Question_01"
                local btn = CreateSidebarButton(tileName, iconKey, function()
                    f.OpenModule(tileName, tileModKey)
                    -- Find this button and highlight it
                    for _, sb in ipairs(sidebarButtons) do
                        if sb.sidebarModuleKey == tileModKey and sb.sidebarName == tileName then
                            SetActiveSidebarButton(sb)
                            break
                        end
                    end
                end)
                btn:SetPoint("TOPLEFT", sidebarScrollContent, "TOPLEFT", 0, -yOff)
                btn.sidebarModuleKey = tileModKey
                btn.sidebarName = tileName
                tinsert(sidebarButtons, btn)
                yOff = yOff + 38
            end

            sidebarScrollContent:SetHeight(math.max(1, yOff))

            -- Set Home as active by default
            SetActiveSidebarButton(sidebarButtons[1])
        end
        f:Show()
    end
end

