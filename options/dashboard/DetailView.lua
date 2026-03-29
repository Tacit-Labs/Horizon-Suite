--[[
    Horizon Suite - Dashboard detail view: option accordion, subcategory tiles, search navigation hooks.
    Wired from options/dashboard/DashboardFrame.lua via addon.DashboardDetailView_Init(env).
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

--- Build detail and subcategory scroll areas; assign f.OpenModule, f.OpenCategoryDetail, f.BuildAccordionDetail.
--- env fields: f, addon, L, detailView, subCategoryView, contentWidth, dashScrollTopOffset, dashAccentRefs,
--- GetAccentColor, MakeText, OptionCategoryKeyIsAxis, moduleLabels, DASHBOARD_CHILD_PANEL_ALPHA,
--- DASHBOARD_CONTENT_CARD_ALPHA_MULT, CLEAR, searchBox, searchDropdown, searchDropdownScroll,
--- searchDropdownContent, searchDropdownCatch, setSidebarState, crossfadeTo, showDetailHeader, showSubcategoryHeader
--- setSidebarState may be replaced on env after sidebar init (stub no-op until then).
--- @param env table
--- @return table { NavigateToOption = function, NavigateToModuleToggles = function }
function addon.DashboardDetailView_Init(env)
    local f = env.f
    local addon = env.addon
    local L = env.L
    local detailView = env.detailView
    local subCategoryView = env.subCategoryView
    local contentWidth = env.contentWidth
    local dashScrollTopOffset = env.dashScrollTopOffset
    local dashAccentRefs = env.dashAccentRefs
    local GetAccentColor = env.GetAccentColor
    local MakeText = env.MakeText
    local OptionCategoryKeyIsAxis = env.OptionCategoryKeyIsAxis
    local moduleLabels = env.moduleLabels
    local DASHBOARD_CHILD_PANEL_ALPHA = env.DASHBOARD_CHILD_PANEL_ALPHA
    local DASHBOARD_CONTENT_CARD_ALPHA_MULT = env.DASHBOARD_CONTENT_CARD_ALPHA_MULT
    local CLEAR = env.CLEAR
    local searchBox = env.searchBox
    local searchDropdown = env.searchDropdown
    local searchDropdownScroll = env.searchDropdownScroll
    local searchDropdownContent = env.searchDropdownContent
    local searchDropdownCatch = env.searchDropdownCatch

    if not env.setSidebarState then env.setSidebarState = function() end end
    local function SetSidebarState(state) env.setSidebarState(state) end
    local function CrossfadeTo(targetView) env.crossfadeTo(targetView) end
    local function ShowDetailHeader() env.showDetailHeader() end
    local function ShowSubcategoryHeader() env.showSubcategoryHeader() end

    local subCategoryScroll = CreateFrame("ScrollFrame", nil, subCategoryView, "UIPanelScrollFrameTemplate")
    subCategoryScroll:SetPoint("TOPLEFT", 40, dashScrollTopOffset)
    subCategoryScroll:SetPoint("BOTTOMRIGHT", -40, 40)
    subCategoryScroll.ScrollBar:Hide()
    subCategoryScroll.ScrollBar:ClearAllPoints()

    local subCategoryContent = CreateFrame("Frame", nil, subCategoryScroll)
    subCategoryContent:SetSize(contentWidth, 1)
    subCategoryScroll:SetScrollChild(subCategoryContent)

    addon.Dashboard_ApplySmoothScroll(subCategoryScroll, subCategoryContent, 60, true)

    -- Detail Card Container (Scrollable)
    local detailScroll = CreateFrame("ScrollFrame", nil, detailView, "UIPanelScrollFrameTemplate")
    detailScroll:SetPoint("TOPLEFT", 40, dashScrollTopOffset)
    detailScroll:SetPoint("BOTTOMRIGHT", -40, 40)
    detailScroll.ScrollBar:Hide()
    detailScroll.ScrollBar:ClearAllPoints()

    local detailContent = CreateFrame("Frame", nil, detailScroll)
    detailContent:SetSize(contentWidth, 1)
    detailScroll:SetScrollChild(detailContent)

    addon.Dashboard_ApplySmoothScroll(detailScroll, detailContent, 60, true)
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
            if OptionCategoryKeyIsAxis(targetCat.key) then
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

    --- Open Axis → Modules detail with the Module Toggles accordion expanded (same as Welcome “Open module toggles” link).
    --- @return nil
    local function NavigateToModuleToggles()
        local togglesSection = L["OPTIONS_AXIS_MODULE_TOGGLES"] or "Module Toggles"
        local modulesName = L["OPTIONS_AXIS_MODULES"] or "Modules"
        local entryFound
        local idx = addon.OptionsData_BuildSearchIndex and addon.OptionsData_BuildSearchIndex() or {}
        for _, e in ipairs(idx) do
            if e.categoryKey == "Modules" and e.sectionName == togglesSection then
                entryFound = e
                break
            end
        end
        if not entryFound then
            entryFound = {
                categoryKey = "Modules",
                categoryName = modulesName,
                optionId = "_module_focus",
            }
        end
        NavigateToOption(entryFound)
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

    -- Match options section-card transparency (OptionsWidgets SectionCardBg / SectionCardBorder)
    local WDef = addon.OptionsWidgetsDef
    local SBg = (WDef and WDef.SectionCardBg) or { 0.09, 0.09, 0.11, 0.96 }
    local SBd = (WDef and WDef.SectionCardBorder) or { 0.18, 0.2, 0.24, 0.35 }
    local SBgA = SBg[4] * DASHBOARD_CONTENT_CARD_ALPHA_MULT
    -- Hover / expanded fills: shared by module tiles, subcategory tiles, and detail accordions
    local SBgHoverR, SBgHoverG, SBgHoverB = 0.11, 0.11, 0.13
    local SBgExpandedR, SBgExpandedG, SBgExpandedB = 0.10, 0.10, 0.12

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
        tBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)

        -- Border
        local border = tile:CreateTexture(nil, "BORDER")
        border:SetAllPoints()
        border:SetColorTexture(SBd[1], SBd[2], SBd[3], SBd[4])

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
            -- Keep fill = collapsed accordion idle (no header-hover tint)
            local ar, ag, ab = GetAccentColor()
            border:SetColorTexture(ar, ag, ab, 0.6)
            lbl:SetTextColor(1, 1, 1)
            descLbl:SetTextColor(0.75, 0.8, 0.85)
            accent:SetColorTexture(ar, ag, ab, 1)
            accent:Show()
            topAccent:SetColorTexture(ar, ag, ab, 0.3)
        end)
        tile:SetScript("OnLeave", function()
            border:SetColorTexture(SBd[1], SBd[2], SBd[3], SBd[4])
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
            if OptionCategoryKeyIsAxis(cat.key) then
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
        if addon.DashboardPreview and addon.DashboardPreview.SetActiveModuleKey then
            addon.DashboardPreview.SetActiveModuleKey(matchedModuleKey)
        end

        ClearDetailCards()
        CrossfadeTo(detailView)
        ShowDetailHeader()
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
        if addon.DashboardPreview and addon.DashboardPreview.SetActiveModuleKey then
            addon.DashboardPreview.SetActiveModuleKey(mk)
        end

        -- Find all matching sub-categories
        local cats = {}
        for _, cat in ipairs(addon.OptionCategories) do
            local match = false
            if moduleKey == "axis" then
                match = OptionCategoryKeyIsAxis(cat.key)
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
            ShowSubcategoryHeader()
            subCategoryScroll:SetVerticalScroll(0)

            local modName = moduleKey and moduleLabels[moduleKey] or name

            if f.detailTitle then
                f.detailTitle:SetText(modName:upper() .. " CATEGORIES")
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
            ShowDetailHeader()
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
        local card = CreateFrame("Frame", nil, parent)
        card:SetHeight(60)
        card:SetPoint("LEFT", parent, "LEFT", 0, 0)
        card:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
        card.expanded = false
        card.collapsedHeight = 60
        card:SetClipsChildren(true)

        -- Background (same alpha as options section cards)
        local cBg = card:CreateTexture(nil, "BACKGROUND")
        cBg:SetAllPoints()
        cBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)

        -- Bottom divider
        local divider = card:CreateTexture(nil, "ARTWORK")
        divider:SetHeight(1)
        divider:SetPoint("BOTTOMLEFT", 20, 0)
        divider:SetPoint("BOTTOMRIGHT", -20, 0)
        local cdr, cdg, cdb = GetAccentColor()
        divider:SetColorTexture(cdr, cdg, cdb, 0.2)
        tinsert(dashAccentRefs.cardDividers, divider)

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

        local headerBtn = CreateFrame("Button", nil, card)
        headerBtn:SetPoint("TOPLEFT", 0, 0)
        headerBtn:SetPoint("TOPRIGHT", 0, 0)
        headerBtn:SetHeight(60)
        headerBtn:SetFrameLevel(card:GetFrameLevel() + 5)
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

        -- Settings Container
        local sc = CreateFrame("Frame", nil, card)
        sc:SetPoint("TOPLEFT", 0, -60)
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

        headerBtn:SetScript("OnClick", function()
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

        -- skipDbKey: do not Refresh the control that initiated the change — Refresh() snaps the
        -- pill thumb and cancels CreateToggleSwitch's slide animation (feels broken vs other toggles).
        local function RefreshLinkedTargets(refreshIds, skipDbKey)
            if not refreshIds then return end
            for _, k in ipairs(refreshIds) do
                if k ~= skipDbKey then
                    local w = detailOptionFrames[k]
                    if w and w.Refresh then w:Refresh() end
                end
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
                        local t = _G.OptionsData_GetDB(opt.dbKey, nil)
                        if type(t) == "table" and t[1] then
                            return t[1], t[2], t[3], t[4] or 1
                        end
                        if type(opt.default) == "table" then return unpack(opt.default) end
                        return 1, 1, 1, 1
                    end
                else
                    g = function() return _G.OptionsData_GetDB(opt.dbKey, opt.default) end
                end
            end
            if not s and opt.dbKey then
                if opt.type == "color" then
                    s = function(nr, ng, nb, na)
                        local t = { nr, ng, nb }
                        if opt.hasAlpha then t[4] = na end
                        _G.OptionsData_SetDB(opt.dbKey, t)
                    end
                else
                    s = function(v) _G.OptionsData_SetDB(opt.dbKey, v) end
                end
            end
            if opt.refreshIds and s then
                local origSet = s
                local skipKey = opt.dbKey
                if opt.type == "color" then
                    s = function(nr, ng, nb, na)
                        origSet(nr, ng, nb, na)
                        RefreshLinkedTargets(opt.refreshIds, skipKey)
                    end
                else
                    s = function(v)
                        origSet(v)
                        RefreshLinkedTargets(opt.refreshIds, skipKey)
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
                    widget = _G.OptionsWidgets_CreateCustomDropdown(currentCard.settingsContainer, opt.name, opt.desc or "", opt.options, g, s, opt.displayFn, opt.searchable, opt.disabled, opt.tooltip, resetBtn, opt.fontPreviewInList)
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
                    
                    local sub = _G.OptionsWidgets_CreateSectionHeader(cmContainer, L["OPTIONS_FOCUS_QUEST_TYPES"])
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
                    
                    local resetBtn = _G.OptionsWidgets_CreateButton(cmContainer, L["OPTIONS_FOCUS_RESET_QUEST_TYPES"], function()
                        _G.OptionsData_SetDB(opt.dbKey, nil)
                        _G.OptionsData_SetDB("sectionColors", nil)
                        for _, sw in ipairs(swatches) do if sw.Refresh then sw:Refresh() end end
                        if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                    end, { width = 120, height = 22 })
                    resetBtn:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 10, yOff)
                    yOff = yOff - 30

                    local overridesSub = _G.OptionsWidgets_CreateSectionHeader(cmContainer, L["OPTIONS_FOCUS_ELEMENT_OVERRIDES"])
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
                    
                    local resetOv = _G.OptionsWidgets_CreateButton(cmContainer, L["OPTIONS_FOCUS_RESET_OVERRIDES"], function()
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

                        -- Card background (match options section-card transparency)
                        local bg = card:CreateTexture(nil, "BACKGROUND")
                        bg:SetAllPoints(card)
                        bg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)

                        -- Subtle border
                        if addon.CreateBorder then
                            addon.CreateBorder(card, SBd)
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

                        local resetBtn = _G.OptionsWidgets_CreateButton(card, L["OPTIONS_FOCUS_RESET"], function()
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

                        local zoneLabel = (key == "SCENARIO") and ((addon.L and addon.L["UI_STAGE"]) or "Stage") or ((addon.L and addon.L["OPTIONS_FOCUS_ZONE"]) or "Zone")
                        local catDefs = {
                            { subKey = "section",   abbr = L["OPTIONS_FOCUS_SECTION"] or "Section",   full = "Section",   def = unifiedDef },
                            { subKey = "title",     abbr = L["OPTIONS_FOCUS_TITLE"] or "Title",     full = "Title",     def = unifiedDef },
                            { subKey = "zone",      abbr = (key == "SCENARIO") and (L["UI_STAGE"] or "Stage") or (L["OPTIONS_FOCUS_ZONE"] or "Zone"), full = zoneLabel, def = addon.ZONE_COLOR or { 0.55, 0.65, 0.75 } },
                            { subKey = "objective", abbr = L["OPTIONS_FOCUS_OBJECTIVE"] or "Objective", full = "Objective", def = unifiedDef },
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

                    perCatHdr = _G.OptionsWidgets_CreateSectionHeader(cmfContainer, L["OPTIONS_FOCUS_PER_CATEGORY"])
                    perCatHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                    resetAllBtn = _G.OptionsWidgets_CreateButton(cmfContainer, L["OPTIONS_FOCUS_RESET_DEFAULTS"], function()
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
                    goHdr = _G.OptionsWidgets_CreateSectionHeader(cmfContainer, L["OPTIONS_FOCUS_SECTION_OVERRIDES"])
                    goHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                    yOff = yOff - 28

                    ovCompleted = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["OPTIONS_FOCUS_READY_TURN_OVERRIDES_BASE_COLOURS"], L["OPTIONS_FOCUS_READY_TURN_COLOURS_QUESTS"], function() return getOverride("useCompletedOverride") end, function(v)
                        setOverride("useCompletedOverride", v)
                        local gf = overrideGroupMap["COMPLETE"]
                        if gf then gf:SetShown(v and true or false); LayoutAll() end
                    end)
                    ovCompleted:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                    ovCompleted:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                    yOff = yOff - 40

                    ovCurrentZone = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["OPTIONS_FOCUS_CURRENT_ZONE_OVERRIDES_BASE_COLOURS"], L["OPTIONS_FOCUS_CURRENT_ZONE_COLOURS_QUESTS_SEC"], function() return getOverride("useCurrentZoneOverride") end, function(v)
                        setOverride("useCurrentZoneOverride", v)
                        local gf = overrideGroupMap["NEARBY"]
                        if gf then gf:SetShown(v and true or false); LayoutAll() end
                    end)
                    ovCurrentZone:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                    ovCurrentZone:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                    yOff = yOff - 40

                    ovCurrentQuest = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["OPTIONS_FOCUS_CURRENT_QUEST_OVERRIDES_BASE_COLOURS"], L["OPTIONS_FOCUS_CURRENT_QUEST_COLOURS_QUESTS_SE"], function() return getOverride("useCurrentQuestOverride") end, function(v)
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
                    otherHdr = _G.OptionsWidgets_CreateSectionHeader(cmfContainer, L["OPTIONS_FOCUS_COLORS"])
                    otherHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                    yOff = yOff - 28

                    ovCompletedObj = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["OPTIONS_FOCUS_DISTINCT_COLOR_COMPLETED_OBJECTIVES"], L["OPTIONS_CORE_COMPLETED_OBJECTIVES_COLOR_BELOW"], function() return _G.OptionsData_GetDB("useCompletedObjectiveColor", true) end, function(v)
                        _G.OptionsData_SetDB("useCompletedObjectiveColor", v)
                        notifyFn()
                        if completedObjRow then completedObjRow:SetShown(v and true or false); LayoutAll() end
                    end)
                    ovCompletedObj:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                    ovCompletedObj:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                    yOff = yOff - 40

                    local otherDefs = {
                        { dbKey = "highlightColor", label = L["OPTIONS_FOCUS_HIGHLIGHT"], def = (addon.HIGHLIGHT_COLOR_DEFAULT or { 0.4, 0.7, 1 }) },
                        { dbKey = "completedObjectiveColor", label = L["OPTIONS_FOCUS_COMPLETED_OBJECTIVE"], def = (addon.OBJ_DONE_COLOR or { 0.20, 1.00, 0.40 }), isCompletedObj = true },
                        { dbKey = "progressBarFillColor", label = L["OPTIONS_FOCUS_PROGRESS_BAR_FILL"], def = { 0.40, 0.65, 0.90, 0.85 }, disabled = function() return _G.OptionsData_GetDB("progressBarUseCategoryColor", true) end, hasAlpha = true },
                        { dbKey = "progressBarTextColor", label = L["OPTIONS_FOCUS_PROGRESS_BAR_TEXT"], def = { 0.95, 0.95, 0.95 } },
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

    return {
        NavigateToOption = NavigateToOption,
        NavigateToModuleToggles = NavigateToModuleToggles,
    }
end
