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
            f:EnableMouse(true)
            f:Hide()

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
            
            -- Header
            local head = MakeText(f, "Horizon Suite", 36, 1, 1, 1, "CENTER")
            head:SetPoint("TOP", 0, -60)
            local headSub = MakeText(f, "Select a module to configure", 16, 0.5, 0.5, 0.5, "CENTER")
            headSub:SetPoint("TOP", 0, -105)

            -- Search Bar
            local searchBox = CreateFrame("EditBox", nil, f)
            searchBox:SetSize(600, 50)
            searchBox:SetPoint("TOP", 0, -150)
            searchBox:SetFont("Fonts\\FRIZQT__.TTF", 16, "")
            searchBox:SetTextInsets(55, 15, 0, 0)
            searchBox:SetAutoFocus(false)
            
            local sbBorder = searchBox:CreateTexture(nil, "BACKGROUND")
            sbBorder:SetPoint("TOPLEFT", -2, 2)
            sbBorder:SetPoint("BOTTOMRIGHT", 2, -2)
            sbBorder:SetColorTexture(0.2, 0.2, 0.25, 1)

            local sbBg = searchBox:CreateTexture(nil, "BORDER")
            sbBg:SetAllPoints()
            sbBg:SetColorTexture(0.12, 0.13, 0.16, 1)
            
            local sbPlaceholder = MakeText(searchBox, "Search settings...", 16, 0.5, 0.5, 0.5, "LEFT")
            sbPlaceholder:SetPoint("LEFT", 55, 0)
            
            local sbIcon = searchBox:CreateTexture(nil, "ARTWORK")
            sbIcon:SetSize(24, 24)
            sbIcon:SetPoint("LEFT", 20, 0)
            sbIcon:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_02")
            sbIcon:SetVertexColor(0.5, 0.5, 0.5, 1)

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
                            self:SetVerticalScroll(current + diff * 15 * elapsed)
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

            -- Views
            local dashboardView = CreateFrame("Frame", nil, f)
            dashboardView:SetSize(950, 680)
            dashboardView:SetPoint("CENTER")
            f.dashboardView = dashboardView

            local detailView = CreateFrame("Frame", nil, f)
            detailView:SetSize(950, 680)
            detailView:SetPoint("CENTER")
            detailView:Hide()
            f.detailView = detailView

            local subCategoryView = CreateFrame("Frame", nil, f)
            subCategoryView:SetSize(950, 680)
            subCategoryView:SetPoint("CENTER")
            subCategoryView:Hide()
            f.subCategoryView = subCategoryView

            local subCategoryScroll = CreateFrame("ScrollFrame", nil, subCategoryView, "UIPanelScrollFrameTemplate")
            subCategoryScroll:SetPoint("TOPLEFT", 40, -110)
            subCategoryScroll:SetPoint("BOTTOMRIGHT", -40, 40)
            subCategoryScroll.ScrollBar:Hide()
            subCategoryScroll.ScrollBar:ClearAllPoints()

            local subCategoryContent = CreateFrame("Frame", nil, subCategoryScroll)
            subCategoryContent:SetSize(870, 1)
            subCategoryScroll:SetScrollChild(subCategoryContent)

            ApplySmoothScroll(subCategoryScroll, subCategoryContent, 60)
            local detailTitle = MakeText(detailView, "MODULE SETTINGS", 20, 1, 1, 1, "LEFT")
            detailTitle:SetPoint("TOPLEFT", 180, -45)
            f.detailTitle = detailTitle

            -- Transitions
            local function CrossfadeTo(targetView)
                dashboardView:Hide()
                detailView:Hide()
                subCategoryView:Hide()
                if head then head:Hide() end
                if headSub then headSub:Hide() end
                if searchBox then searchBox:Hide() end

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
                icon:SetVertexColor(0.6, 0.6, 0.6)

                local txt = MakeText(btn, textStr, 12, 0.6, 0.6, 0.6, "LEFT")
                txt:SetPoint("LEFT", 20, 0)
                
                btn:SetScript("OnEnter", function() 
                    local ar, ag, ab = GetAccentColor()
                    txt:SetTextColor(1, 1, 1)
                    icon:SetDesaturated(false)
                    icon:SetVertexColor(ar, ag, ab)
                end)
                btn:SetScript("OnLeave", function() 
                    txt:SetTextColor(0.6, 0.6, 0.6)
                    icon:SetDesaturated(true)
                    icon:SetVertexColor(0.6, 0.6, 0.6)
                end)
            end

            StyleBackButton(backBtn, "BACK")
            StyleBackButton(subBackBtn, "BACK")

            -- Back button in detail view now goes to Subcategory Menu
            backBtn:SetScript("OnClick", function() 
                detailView:Hide()
                if f.currentModuleKey then
                    subCategoryView:Show()
                else
                    f.ShowDashboard()
                end 
            end)

            subBackBtn:SetScript("OnClick", function() f.ShowDashboard() end)

            -- Close Button
            local closeBtn = CreateFrame("Button", nil, f)
            closeBtn:SetSize(30, 30)
            closeBtn:SetPoint("TOPRIGHT", -15, -15)
            
            local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY")
            closeTxt:SetFont(addon.GetDefaultFontPath and addon.GetDefaultFontPath() or "Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
            closeTxt:SetPoint("CENTER", 1, 0)
            closeTxt:SetText("X")
            closeTxt:SetTextColor(0.6, 0.6, 0.6)
            
            closeBtn:SetScript("OnEnter", function()
                closeTxt:SetTextColor(1, 0.3, 0.3)
            end)
            closeBtn:SetScript("OnLeave", function()
                closeTxt:SetTextColor(0.6, 0.6, 0.6)
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
            detailScroll:SetPoint("TOPLEFT", 40, -110)
            detailScroll:SetPoint("BOTTOMRIGHT", -40, 40)
            detailScroll.ScrollBar:Hide()
            detailScroll.ScrollBar:ClearAllPoints()

            local detailContent = CreateFrame("Frame", nil, detailScroll)
            detailContent:SetSize(870, 1)
            detailScroll:SetScrollChild(detailContent)

            ApplySmoothScroll(detailScroll, detailContent, 60)
            local currentDetailCards = {}

            -- Helper: Update Detail Layout
            local function UpdateDetailLayout()
                local yOffset = 0
                for _, card in ipairs(currentDetailCards) do
                    card:ClearAllPoints()
                    card:SetPoint("TOPLEFT", detailContent, "TOPLEFT", 0, -yOffset)
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
            local function CreateSubCategoryTile(parent, name, index, options, modName, desc)
                local tile = CreateFrame("Button", nil, parent)
                tile:SetSize(400, 110)
                
                local row = math.floor((index-1) / 2)
                local col = (index-1) % 2
                tile:SetPoint("TOPLEFT", parent, "TOPLEFT", 10 + (col * 420), 0 + (row * -130))

                -- Background
                local tBg = tile:CreateTexture(nil, "BACKGROUND")
                tBg:SetPoint("TOPLEFT", 1, -1)
                tBg:SetPoint("BOTTOMRIGHT", -1, 1)
                tBg:SetColorTexture(0.08, 0.08, 0.1, 1)

                -- Border
                local border = tile:CreateTexture(nil, "BORDER")
                border:SetAllPoints()
                border:SetColorTexture(0.15, 0.16, 0.2, 1)

                -- Accent
                local accent = tile:CreateTexture(nil, "ARTWORK")
                accent:SetSize(4, 60)
                accent:SetPoint("LEFT", 0, 0)
                local ar, ag, ab = GetAccentColor()
                accent:SetColorTexture(ar, ag, ab, 1)
                accent:Hide()

                -- Label
                local lbl = MakeText(tile, name, 18, 0.9, 0.9, 0.95, "LEFT")
                lbl:SetPoint("TOPLEFT", 25, -20)
                
                -- Collect subset of option names for description
                local descStr = desc or ("Configure and customize settings related to " .. name:lower() .. ".")

                -- Description Text
                local descLbl = MakeText(tile, descStr, 13, 0.6, 0.65, 0.7, "LEFT")
                descLbl:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", 0, -8)
                descLbl:SetPoint("RIGHT", tile, "RIGHT", -20, 0)
                descLbl:SetWordWrap(true)
                descLbl:SetHeight(40)
                descLbl:SetJustifyV("TOP")

                tile:SetScript("OnEnter", function()
                    tBg:SetColorTexture(0.12, 0.13, 0.16, 1)
                    local ar, ag, ab = GetAccentColor()
                    border:SetColorTexture(ar, ag, ab, 0.8)
                    lbl:SetTextColor(1, 1, 1)
                    descLbl:SetTextColor(0.8, 0.85, 0.9)
                    accent:SetColorTexture(ar, ag, ab, 1)
                    accent:Show()
                end)
                tile:SetScript("OnLeave", function()
                    tBg:SetColorTexture(0.08, 0.08, 0.1, 1)
                    border:SetColorTexture(0.15, 0.16, 0.2, 1)
                    lbl:SetTextColor(0.9, 0.9, 0.95)
                    descLbl:SetTextColor(0.6, 0.65, 0.7)
                    accent:Hide()
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

                -- Cascade effect
                for i, card in ipairs(currentDetailCards) do
                    card:SetAlpha(0)
                    local _, _, _, xVal, yVal = card:GetPoint()
                    if yVal then
                        card:SetPoint("TOPLEFT", detailContent, "TOPLEFT", xVal or 0, yVal - 20)
                        if C_Timer and C_Timer.After then
                            C_Timer.After(i * 0.04, function()
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

                        -- Staggered Cascade Entrance
                        tile:SetAlpha(0)
                        local _, _, _, xVal, yVal = tile:GetPoint()
                        if xVal and yVal then
                            tile:SetPoint("TOPLEFT", subCategoryContent, "TOPLEFT", xVal, yVal - 20)
                            if C_Timer and C_Timer.After then
                                C_Timer.After(i * 0.04, function()
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

                        -- Cascade effect
                        for i, card in ipairs(currentDetailCards) do
                            card:SetAlpha(0)
                            local _, _, _, xVal, yVal = card:GetPoint()
                            if yVal then
                                card:SetPoint("TOPLEFT", detailContent, "TOPLEFT", xVal or 0, yVal - 20)
                                if C_Timer and C_Timer.After then
                                    C_Timer.After(i * 0.04, function()
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
                card:SetSize(870, 60)
                card.expanded = false
                card.collapsedHeight = 60
                card:SetClipsChildren(true)

                -- Background
                local cBg = card:CreateTexture(nil, "BACKGROUND")
                cBg:SetAllPoints()
                cBg:SetColorTexture(0.06, 0.06, 0.07, 0.95)

                card:HookScript("OnEnter", function()
                    if not card.expanded then
                        cBg:SetColorTexture(0.09, 0.09, 0.1, 0.95)
                    end
                end)
                card:HookScript("OnLeave", function()
                    cBg:SetColorTexture(0.06, 0.06, 0.07, 0.95)
                end)

                -- Accent
                local accent = card:CreateTexture(nil, "ARTWORK")
                accent:SetSize(4, 24)
                accent:SetPoint("TOPLEFT", 20, -18)
                local cr, cg, cb = GetAccentColor()
                accent:SetColorTexture(cr, cg, cb, 1)

                -- Title
                local lbl = MakeText(card, title:upper(), 15, 0.9, 0.9, 0.95, "LEFT")
                lbl:SetPoint("TOPLEFT", 35, -22)

                -- Settings Container
                local sc = CreateFrame("Frame", nil, card)
                sc:SetPoint("TOPLEFT", 0, -60)
                sc:SetSize(870, 1)
                sc:SetAlpha(0)
                card.settingsContainer = sc

                -- Animation logic
                card.anim = card:CreateAnimationGroup()
                local sizeAnim = card.anim:CreateAnimation("Animation")
                sizeAnim:SetDuration(0.3)
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
                    UpdateDetailLayout()
                end)

                card:SetScript("OnClick", function()
                    if card.anim:IsPlaying() then return end
                    card.expanded = not card.expanded
                    card.anim:Play()
                end)

                return card
            end

            f.BuildAccordionDetail = function(moduleSubName, options)
                local currentCard = nil

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
                        elseif opt.type == "slider" then
                            widget = _G.OptionsWidgets_CreateSlider(currentCard.settingsContainer, opt.name, opt.desc or "", g, s, opt.min or 0, opt.max or 100, opt.disabled, opt.step or 1, opt.tooltip)
                        elseif opt.type == "dropdown" then
                            widget = _G.OptionsWidgets_CreateCustomDropdown(currentCard.settingsContainer, opt.name, opt.desc or "", opt.options, g, s, opt.displayFn, opt.searchable, opt.disabled, opt.tooltip)
                        elseif opt.type == "color" then
                            widget = _G.OptionsWidgets_CreateColorSwatch(currentCard.settingsContainer, opt.name, opt.desc or "", g, s, opt.hasAlpha, opt.tooltip)
                        elseif opt.type == "header" then
                            widget = _G.OptionsWidgets_CreateSectionHeader(currentCard.settingsContainer, opt.name)
                        elseif opt.type == "button" then
                            widget = _G.OptionsWidgets_CreateButton(currentCard.settingsContainer, opt.name, opt.onClick, { tooltip = opt.tooltip })
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
                                    -- Trigger full module rebuild to recalculate spacing (shortcut)
                                    f.OpenModule(addon.currentModule)  
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
                tile:SetSize(200, 180)
                
                local itemsPerRow = 4
                local row = math.floor((index-1) / itemsPerRow)
                local col = (index-1) % itemsPerRow
                
                local itemsInThisRow = itemsPerRow
                local totalRows = math.ceil(totalTiles / itemsPerRow)
                if row == totalRows - 1 and (totalTiles % itemsPerRow) ~= 0 then
                    itemsInThisRow = totalTiles % itemsPerRow
                end
                
                local rowWidth = (itemsInThisRow * 200) + ((itemsInThisRow - 1) * 20)
                local startX = -rowWidth / 2 + 100
                tile:SetPoint("TOP", parent, "TOP", startX + (col * 220), -260 + (row * -200))

                -- Background
                local tBg = tile:CreateTexture(nil, "BACKGROUND")
                tBg:SetPoint("TOPLEFT", 1, -1)
                tBg:SetPoint("BOTTOMRIGHT", -1, 1)
                tBg:SetColorTexture(0.08, 0.08, 0.1, 1)

                -- Border
                local border = tile:CreateTexture(nil, "BORDER")
                border:SetAllPoints()
                border:SetColorTexture(0.15, 0.16, 0.2, 1)

                -- Icon
                local ic = tile:CreateTexture(nil, "ARTWORK")
                ic:SetSize(60, 60)
                ic:SetPoint("CENTER", 0, 20)
                ic:SetTexture("Interface\\Icons\\" .. (categoryIcons[name] or "INV_Misc_Question_01"))
                ic:SetVertexColor(0.85, 0.85, 0.9, 0.85)

                -- Label
                local lbl = MakeText(tile, name, 16, 0.85, 0.85, 0.9, "CENTER")
                lbl:SetPoint("BOTTOM", 0, 30)

                tile:SetScript("OnEnter", function()
                    tBg:SetColorTexture(0.12, 0.13, 0.16, 1)
                    local ar, ag, ab = GetAccentColor()
                    border:SetColorTexture(ar, ag, ab, 0.8)
                    ic:SetVertexColor(1, 1, 1, 1)
                    lbl:SetTextColor(1, 1, 1)
                end)
                tile:SetScript("OnLeave", function()
                    tBg:SetColorTexture(0.08, 0.08, 0.1, 1)
                    border:SetColorTexture(0.15, 0.16, 0.2, 1)
                    ic:SetVertexColor(0.85, 0.85, 0.9, 0.85)
                    lbl:SetTextColor(0.85, 0.85, 0.9)
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
        end
        f:Show()
    end
end

