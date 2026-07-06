--[[
    Horizon Suite - Dashboard detail view: option accordion, subcategory tiles, search navigation hooks.
    Wired from options/dashboard/DashboardFrame.lua via addon.DashboardDetailView_Init(env).
]]

local addon = _G.HorizonSuite
if not addon then return end
local L = addon.L
-- Build detail and subcategory scroll areas; assign f.OpenModule, f.OpenCategoryDetail, f.BuildAccordionDetail.
-- env fields: f, addon, L, detailView, subCategoryView, contentWidth, dashScrollTopOffset, dashScrollTopOffsetModule, dashAccentRefs,
-- GetAccentColor, MakeText, OptionCategoryKeyIsAxis, moduleLabels, DASHBOARD_CHILD_PANEL_ALPHA,
-- DASHBOARD_CONTENT_CARD_ALPHA_MULT, CLEAR, searchBox, searchDropdown, searchDropdownScroll,
-- searchDropdownContent, searchDropdownCatch, searchBarShell, searchView, searchEmptyHint,
-- setSidebarState, crossfadeTo, showDetailHeader, showSubcategoryHeader
-- setSidebarState may be replaced on env after sidebar init (stub no-op until then).
-- @param env table
-- @return table NavigateToOption, NavigateToModuleToggles, NavigateToDashboardBackground, NavigateToAxisHome, NavigateToClassColourTinting
function addon.DashboardDetailView_Init(env)
    local f = env.f
    local addon = env.addon
    local L = env.L
    local detailView = env.detailView
    local subCategoryView = env.subCategoryView
    local contentWidth = env.contentWidth
    local dashScrollTopOffset = env.dashScrollTopOffset
    local dashScrollTopOffsetModule = env.dashScrollTopOffsetModule or env.dashScrollTopOffset
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
    local searchBarShell = env.searchBarShell
    local searchView = env.searchView
    local searchEmptyHint = env.searchEmptyHint

    if not env.setSidebarState then env.setSidebarState = function() end end
    local function SetSidebarState(state) env.setSidebarState(state) end
    local function CrossfadeTo(targetView) env.crossfadeTo(targetView) end
    local function ShowDetailHeader() env.showDetailHeader() end
    local function ShowSubcategoryHeader() env.showSubcategoryHeader() end

    -- Fixed action buttons for detail pages — live outside the scroll frame so they
    -- never scroll away. Created here to avoid the 200-local limit in DashboardFrame.lua.
    -- The first three use OptionsWidgets_CreateButton to match the card button style.
    -- The enable toggle is custom-styled so it can light up when the module is active.
    do
        local DC   = addon.DashboardConstants or {}
        local WDef = addon.OptionsWidgetsDef or {}
        local y    = (DC.HEAD_SUBTITLE_Y or -58) - 2
        local fl   = f:GetFrameLevel() + 12
        local CW   = _G.OptionsWidgets_CreateButton
        if CW then
            local previewBtn = CW(f, L["AUGMENT_PREVIEW"] or "Preview", function()
                if f.detailPreviewBtn and f.detailPreviewBtn._onClick then
                    f.detailPreviewBtn._onClick()
                end
            end, { width = 140, height = 28 })
            previewBtn:SetFrameLevel(fl)
            previewBtn:ClearAllPoints()
            previewBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -48, y)
            previewBtn:Hide()
            f.detailPreviewBtn = previewBtn

            local resetBtn = CW(f, L["AXIS_RESET_POSITION"] or "Reset Position", function()
                if f.detailResetBtn and f.detailResetBtn._onClick then
                    f.detailResetBtn._onClick()
                end
            end, { width = 150, height = 28 })
            resetBtn:SetFrameLevel(fl)
            resetBtn:ClearAllPoints()
            resetBtn:SetPoint("TOPRIGHT", previewBtn, "TOPLEFT", -8, 0)
            resetBtn:Hide()
            f.detailResetBtn = resetBtn

            local anchorBtn = CW(f, L["AXIS_ANCHOR_MOVE"] or "Show Anchor", function()
                if addon.Augment and addon.Augment.ToggleAnchorFrame then addon.Augment.ToggleAnchorFrame() end
            end, { width = 170, height = 28 })
            anchorBtn:SetFrameLevel(fl)
            anchorBtn:ClearAllPoints()
            anchorBtn:SetPoint("TOPRIGHT", resetBtn, "TOPLEFT", -8, 0)
            anchorBtn:Hide()
            f.detailAnchorBtn = anchorBtn

            -- Enable / disable toggle button — lights up in the module's class color.
            local iBg = WDef.InputBg     or { 0.07, 0.07, 0.10, 0.96 }
            local iBd = WDef.InputBorder or { 0.20, 0.22, 0.28, 0.30 }

            local enableBtn = CreateFrame("Button", nil, f, "BackdropTemplate")
            enableBtn:SetSize(120, 28)
            enableBtn:SetFrameLevel(fl)
            enableBtn:SetPoint("TOPRIGHT", anchorBtn, "TOPLEFT", -16, 0)
            enableBtn:SetBackdrop({
                bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true, tileSize = 16, edgeSize = 10,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            })

            local hiTex = enableBtn:CreateTexture(nil, "HIGHLIGHT")
            hiTex:SetAllPoints(enableBtn)
            hiTex:SetColorTexture(1, 1, 1, 0.06)

            local enableLbl = enableBtn:CreateFontString(nil, "OVERLAY")
            do
                local fp = WDef.FontPath or "Fonts\\FRIZQT__.TTF"
                local fs = WDef.LabelSize or 12
                pcall(function() enableLbl:SetFont(fp, fs, "") end)
            end
            enableLbl:SetPoint("CENTER", enableBtn, "CENTER", 0, 0)

            local function GetModuleColor()
                local ycc = addon.GetModuleClassColor and addon.GetModuleClassColor("augment")
                if ycc then return ycc[1], ycc[2], ycc[3] end
                return 0.25, 0.78, 1.0
            end

            local function RefreshEnableBtn()
                local enabled = addon:IsModuleEnabled("augment")
                local r, g, b = GetModuleColor()
                if enabled then
                    enableBtn:SetBackdropColor(r, g, b, 0.18)
                    enableBtn:SetBackdropBorderColor(r, g, b, 0.65)
                    enableLbl:SetTextColor(r, g, b, 1)
                    enableLbl:SetText("● ENABLED")
                else
                    enableBtn:SetBackdropColor(iBg[1], iBg[2], iBg[3], iBg[4])
                    enableBtn:SetBackdropBorderColor(iBd[1], iBd[2], iBd[3], iBd[4])
                    enableLbl:SetTextColor(0.55, 0.57, 0.62, 1)
                    enableLbl:SetText("○ DISABLED")
                end
            end

            enableBtn:SetScript("OnClick", function()
                addon:SetModuleEnabled("augment", not addon:IsModuleEnabled("augment"))
                RefreshEnableBtn()
                if f.setDetailCardsVisible then
                    f.setDetailCardsVisible(addon:IsModuleEnabled("augment"))
                end
            end)

            enableBtn:Hide()
            f.detailEnableBtn = enableBtn
            f.detailEnableBtn._refresh = RefreshEnableBtn
        end
    end

    local subCategoryScroll = CreateFrame("ScrollFrame", nil, subCategoryView, "UIPanelScrollFrameTemplate")
    subCategoryScroll:SetPoint("TOPLEFT", 40, dashScrollTopOffsetModule)
    subCategoryScroll:SetPoint("BOTTOMRIGHT", -40, 40)
    subCategoryScroll.ScrollBar:Hide()
    subCategoryScroll.ScrollBar:ClearAllPoints()

    local subCategoryContent = CreateFrame("Frame", nil, subCategoryScroll)
    subCategoryContent:SetSize(contentWidth, 1)
    subCategoryScroll:SetScrollChild(subCategoryContent)

    addon.Dashboard_ApplySmoothScroll(subCategoryScroll, subCategoryContent, 60, true)

    -- Debounced resize → reflow for the responsive 2-column module-row grid.
    -- f._layoutModuleRows is set while a module-row page is shown; cleared by ClearSubTiles.
    local relayoutTimer = nil
    subCategoryView:SetScript("OnSizeChanged", function()
        if f._layoutModuleRows then
            if relayoutTimer then relayoutTimer:Cancel() end
            relayoutTimer = C_Timer.NewTimer(0.15, function()
                relayoutTimer = nil
                if f._layoutModuleRows then f._layoutModuleRows(false) end
            end)
        end
    end)

    -- Embedded tooltip preview strip: pinned above the scroll area on Insight
    -- option pages (always visible regardless of scroll). Insight mounts its
    -- mock tooltips into this host; mode (global/player/npc/item) follows the
    -- page's dashboardPreviewMode.
    local detailPreviewHost = CreateFrame("Frame", nil, detailView)
    detailPreviewHost:SetPoint("TOPLEFT", 40, dashScrollTopOffsetModule)
    detailPreviewHost:SetPoint("TOPRIGHT", -40, dashScrollTopOffsetModule)
    detailPreviewHost:SetHeight(1)
    detailPreviewHost:Hide()
    do
        local previewRelayout
        local previewLastW
        detailPreviewHost:SetScript("OnSizeChanged", function(self, w)
            -- React to width changes only — each preview's Refresh sets the
            -- height itself, and re-running on that change would loop.
            if not self:IsShown() then return end
            if previewLastW and w and math.abs(w - previewLastW) < 2 then return end
            previewLastW = w
            if previewRelayout then previewRelayout:Cancel() end
            previewRelayout = C_Timer.NewTimer(0.10, function()
                previewRelayout = nil
                if not self:IsShown() then return end
                if addon.Insight and addon.Insight.RefreshEmbeddedPreview then
                    addon.Insight.RefreshEmbeddedPreview()
                end
                if addon.Augment and addon.Augment.RefreshEmbeddedTHPreview then
                    addon.Augment.RefreshEmbeddedTHPreview()
                end
            end)
        end)
    end

    -- Detail Card Container (Scrollable)
    local detailScroll = CreateFrame("ScrollFrame", nil, detailView, "UIPanelScrollFrameTemplate")
    detailScroll:SetPoint("TOPLEFT", 40, dashScrollTopOffsetModule)
    detailScroll:SetPoint("BOTTOMRIGHT", -40, 40)
    detailScroll.ScrollBar:Hide()
    detailScroll.ScrollBar:ClearAllPoints()

    -- Show/hide the preview strip and re-anchor detailScroll below it.
    -- @param previewMode string|nil "global"|"player"|"npc"|"item"|"talkingHead" to show, nil to hide
    local function ApplyDetailPreviewStrip(previewMode)
        -- Hide any previously-mounted preview before switching modes.
        local function HideAllPreviews()
            if addon.Insight and addon.Insight.HideEmbeddedPreview then addon.Insight.HideEmbeddedPreview() end
            if addon.Augment and addon.Augment.HideEmbeddedTHPreview then addon.Augment.HideEmbeddedTHPreview() end
        end

        if previewMode == "talkingHead" then
            local augment = addon.Augment
            if augment and augment.MountEmbeddedTHPreview and augment.RefreshEmbeddedTHPreview then
                HideAllPreviews()
                augment.MountEmbeddedTHPreview(detailPreviewHost)
                detailPreviewHost:Show()
                augment.RefreshEmbeddedTHPreview()
                detailScroll:ClearAllPoints()
                detailScroll:SetPoint("TOPLEFT", detailPreviewHost, "BOTTOMLEFT", 0, -8)
                detailScroll:SetPoint("BOTTOMRIGHT", detailView, "BOTTOMRIGHT", -40, 40)
                return
            end
        end

        local insight = addon.Insight
        if previewMode and insight and insight.MountEmbeddedPreview and insight.SetDashboardPreviewMode then
            HideAllPreviews()
            insight.MountEmbeddedPreview(detailPreviewHost)
            detailPreviewHost:Show()
            insight.SetDashboardPreviewMode(previewMode)  -- refreshes + sizes the host
            detailScroll:ClearAllPoints()
            detailScroll:SetPoint("TOPLEFT", detailPreviewHost, "BOTTOMLEFT", 0, -8)
            detailScroll:SetPoint("BOTTOMRIGHT", detailView, "BOTTOMRIGHT", -40, 40)
        else
            detailPreviewHost:Hide()
            detailScroll:ClearAllPoints()
            detailScroll:SetPoint("TOPLEFT", detailView, "TOPLEFT", 40, dashScrollTopOffsetModule)
            detailScroll:SetPoint("BOTTOMRIGHT", detailView, "BOTTOMRIGHT", -40, 40)
        end
    end

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
        local firstPad = (addon.DashboardConstants and addon.DashboardConstants.DETAIL_FIRST_BLOCK_TOP_PAD) or 0
        local yOffset = 0
        local visibleIndex = 0
        for _, card in ipairs(currentDetailCards) do
            if card:IsShown() and (card:GetHeight() or 0) > 0 then
                visibleIndex = visibleIndex + 1
                card:ClearAllPoints()
                local topExtra = (visibleIndex == 1) and firstPad or 0
                card:SetPoint("TOPLEFT", detailContent, "TOPLEFT", 0, -(yOffset + topExtra))
                card:SetPoint("RIGHT", detailContent, "RIGHT", 0, 0)
                yOffset = yOffset + topExtra + card:GetHeight() + 15
            end
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

    -- Exposed so fixed header buttons can show/hide cards after a module toggle.
    f.setDetailCardsVisible = function(visible)
        for _, card in ipairs(currentDetailCards) do
            if visible then card:Show() else card:Hide() end
        end
        UpdateDetailLayout()
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
            f.OpenCategoryDetail(modName, entry.categoryName, options, true)

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
        local togglesSection = L["MODULE_TOGGLES"]
        local modulesName = L["MODULES"]
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

    --- Open Axis → Global Settings with the Theme accordion expanded (Dashboard background control).
    --- @return nil
    local function NavigateToDashboardBackground()
        local idx = addon.OptionsData_BuildSearchIndex and addon.OptionsData_BuildSearchIndex() or {}
        local entryFound
        for _, e in ipairs(idx) do
            if e.categoryKey == "GlobalToggles" and e.optionId == "dashboardBackgroundTheme" then
                entryFound = e
                break
            end
        end
        if not entryFound then
            local catName = L["AXIS_GLOBAL_TOGGLES"]
            for _, cat in ipairs(addon.OptionCategories) do
                if cat.key == "GlobalToggles" then
                    catName = type(cat.name) == "function" and cat.name() or cat.name or catName
                    break
                end
            end
            entryFound = {
                categoryKey = "GlobalToggles",
                categoryName = catName,
                optionId = "dashboardBackgroundTheme",
            }
        end
        NavigateToOption(entryFound)
    end

    --- Open Axis module category tiles (Profiles, Modules, Global Settings, …).
    --- @return nil
    local function NavigateToAxisHome()
        local axisName = moduleLabels["axis"] or "Axis"
        if addon.Dashboard_BrandModule then
            axisName = addon.Dashboard_BrandModule("axis") or axisName
        end
        f.OpenModule(axisName, "axis", true)
    end

    --- Open Axis → Global Settings with the Class Colours accordion expanded (suite-wide tint toggles).
    --- @return nil
    local function NavigateToClassColourTinting()
        local idx = addon.OptionsData_BuildSearchIndex and addon.OptionsData_BuildSearchIndex() or {}
        local entryFound
        for _, e in ipairs(idx) do
            if e.categoryKey == "GlobalToggles" and e.optionId == "_classColorAll" then
                entryFound = e
                break
            end
        end
        if not entryFound then
            local catName = L["AXIS_GLOBAL_TOGGLES"]
            for _, cat in ipairs(addon.OptionCategories) do
                if cat.key == "GlobalToggles" then
                    catName = type(cat.name) == "function" and cat.name() or cat.name or catName
                    break
                end
            end
            entryFound = {
                categoryKey = "GlobalToggles",
                categoryName = catName,
                optionId = "_classColorAll",
            }
        end
        NavigateToOption(entryFound)
    end

    local searchDropdownButtons = {}
    local SEARCH_DROPDOWN_ROW_HEIGHT = 52
    local detailFn = addon.OptionsData_SearchResultDetailText

    local function ShowSearchResults(matches)
        if not matches or #matches == 0 then
            f.HideSearchDropdown()
            return
        end

        if f.HideSearchModuleFilterMenu then f.HideSearchModuleFilterMenu() end

        local embedded = searchView and searchView:IsShown()
        local maxRows = embedded and 80 or 12

        local num = math.min(#matches, maxRows)
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
                b.descLine = MakeText(b, "", 9, 0.48, 0.52, 0.58, "LEFT")
                b.descLine:SetPoint("TOPLEFT", b.label, "BOTTOMLEFT", 0, -2)
                b.descLine:SetPoint("RIGHT", b, "RIGHT", -8, 0)
                
                local hi = b:CreateTexture(nil, "BACKGROUND")
                hi:SetAllPoints(b)
                hi:SetColorTexture(1, 1, 1, 0.08)
                hi:Hide()

                b:SetScript("OnEnter", function()
                    local har, hag, hab = GetAccentColor()
                    hi:SetColorTexture(har, hag, hab, 0.08)
                    hi:Show()
                    b.label:SetTextColor(1, 1, 1)
                    if b.descLine then b.descLine:SetTextColor(0.62, 0.66, 0.74) end
                end)
                b:SetScript("OnLeave", function()
                    hi:Hide()
                    b.label:SetTextColor(0.9, 0.9, 0.9)
                    if b.descLine then b.descLine:SetTextColor(0.48, 0.52, 0.58) end
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
            local detailText = (detailFn and m.option and detailFn(m.option, 130)) or ""
            if row.btn.descLine then row.btn.descLine:SetText(detailText) end
            row.btn.entry = m
            row.btn:SetPoint("TOP", searchDropdownContent, "TOP", 0, -(i - 1) * SEARCH_DROPDOWN_ROW_HEIGHT)
            row.btn:SetScript("OnClick", function()
                NavigateToOption(row.btn.entry)
                f.HideSearchDropdown()
                if f.DockSearchDropdownForModule then f.DockSearchDropdownForModule() end
                if searchBox then searchBox:ClearFocus() end
            end)
            row.btn:Show()
        end
        
        for i = num + 1, #searchDropdownButtons do
            if searchDropdownButtons[i] then searchDropdownButtons[i].btn:Hide() end
        end
        
        searchDropdownContent:SetHeight(num * SEARCH_DROPDOWN_ROW_HEIGHT)
        searchDropdownScroll:SetVerticalScroll(0)
        local dw = searchDropdown:GetWidth() or 600
        searchDropdownContent:SetWidth(math.max(1, dw - 24))
        searchDropdown:Show()
        if embedded then
            searchDropdownCatch:Hide()
        else
            searchDropdownCatch:Show()
        end
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

    local function SearchEntryPassesModuleFilter(entry)
        local fk = f.dashboardSearchModuleFilter or "all"
        if fk == "all" then
            if OptionCategoryKeyIsAxis(entry.categoryKey) then
                return true
            end
            local mk = entry.moduleKey
            if not mk or mk == "" then
                return true
            end
            return addon.IsModuleEnabled and addon:IsModuleEnabled(mk)
        end
        if fk == "axis" then return OptionCategoryKeyIsAxis(entry.categoryKey) end
        return entry.moduleKey == fk
    end

    local function SearchFilterDisplayLabel(filterKey)
        if not filterKey or filterKey == "all" then return "" end
        if filterKey == "axis" then return moduleLabels.axis or "Axis" end
        return moduleLabels[filterKey] or filterKey
    end

    f.FilterBySearch = function(query)
        if f.UpdateSearchModuleFilterLabel then f.UpdateSearchModuleFilterLabel() end
        local searchQuery = query and query:trim():lower() or ""
        if searchQuery == "" or #searchQuery < 2 then
            f.HideSearchDropdown()
            if searchView and searchView:IsShown() and searchEmptyHint then
                searchEmptyHint:SetText(L["DASH_SEARCH_EMPTY_HINT"])
                searchEmptyHint:Show()
            end
            return
        end

        local index = addon.OptionsData_BuildSearchIndex and addon.OptionsData_BuildSearchIndex() or {}
        local scoreFn = addon.OptionsData_SearchEntryScore
        local scored = {}
        for _, entry in ipairs(index) do
            if SearchEntryPassesModuleFilter(entry) then
                local sc = scoreFn and scoreFn(entry, searchQuery) or nil
                if sc then
                    scored[#scored + 1] = { entry = entry, score = sc }
                end
            end
        end
        table.sort(scored, function(a, b)
            if a.score ~= b.score then
                return a.score > b.score
            end
            return tostring(a.entry.optionId or "") < tostring(b.entry.optionId or "")
        end)
        local matches = {}
        for i = 1, #scored do
            matches[i] = scored[i].entry
        end

        if #matches == 0 then
            f.HideSearchDropdown()
            if searchView and searchView:IsShown() and searchEmptyHint then
                local fk = f.dashboardSearchModuleFilter or "all"
                if fk ~= "all" then
                    local modLab = SearchFilterDisplayLabel(fk)
                    searchEmptyHint:SetText(string.format(L["DASH_SEARCH_NO_RESULTS_IN_MODULE"], modLab))
                else
                    searchEmptyHint:SetText(L["DASH_SEARCH_NO_RESULTS"])
                end
                searchEmptyHint:Show()
            end
            return
        end

        if searchEmptyHint and searchView and searchView:IsShown() then
            searchEmptyHint:Hide()
        end
        ShowSearchResults(matches)
    end

    local currentSubTiles = {}
    local moduleRowWatcher = nil  -- ticker polling for view-width changes on the categories page

    local function ClearSubTiles()
        for _, tile in ipairs(currentSubTiles) do
            tile:Hide()
        end
        wipe(currentSubTiles)
        wipe(dashAccentRefs.subcatAccents)
        wipe(dashAccentRefs.subcatDividers)
        f._layoutModuleRows = nil
        if moduleRowWatcher then moduleRowWatcher:Cancel() end
        moduleRowWatcher = nil
    end

    -- Match options section-card transparency (OptionsWidgets SectionCardBg / SectionCardBorder)
    local WDef = addon.OptionsWidgetsDef
    local SBg = (WDef and WDef.SectionCardBg) or { 0.09, 0.09, 0.11, 0.96 }
    local SBd = (WDef and WDef.SectionCardBorder) or { 0.18, 0.2, 0.24, 0.35 }
    local SBgA = SBg[4] * DASHBOARD_CONTENT_CARD_ALPHA_MULT
    -- Hover fill: shared by module tiles and subcategory tiles.
    local SBgHoverR, SBgHoverG, SBgHoverB = 0.11, 0.11, 0.13

    -- Params bound once; referenced by the CreateAccordionCard wrapper below.
    -- UpdateDetailLayout is defined at the top of this Init; all other fields are from env.
    local accordionCardParams = {
        GetAccentColor              = GetAccentColor,
        MakeText                    = MakeText,
        dashAccentRefs              = dashAccentRefs,
        DASHBOARD_CONTENT_CARD_ALPHA_MULT = DASHBOARD_CONTENT_CARD_ALPHA_MULT,
        UpdateDetailLayout          = UpdateDetailLayout,
    }

    -- Helper: Create Subcategory Tile
    local TILE_PAD = 10
    local TILE_GAP = 10
    local TILE_H   = 110
    local TILE_ROW_STRIDE = 130
    local SUBCAT_TOP_PAD = (addon.DashboardConstants and addon.DashboardConstants.DETAIL_FIRST_BLOCK_TOP_PAD) or 0

    -- Scroll frame is anchored TOPLEFT+40 / BOTTOMRIGHT-40 from subCategoryView,
    -- so its effective width = viewWidth - 80.  We derive it from the view instead
    -- of calling subCategoryScroll:GetWidth() because anchor-sized frames haven't
    -- completed their layout pass when OnSizeChanged fires, so GetWidth() would
    -- return the stale pre-resize value.
    -- SCROLL_INSET must match the anchor offsets on subCategoryScroll (40px each side).
    -- Defined in DashboardConstants as SUBCATEGORY_SCROLL_INSET for single-source-of-truth.
    local DC_const = addon.DashboardConstants
    local SCROLL_INSET = DC_const and DC_const.SUBCATEGORY_SCROLL_INSET or 80

    local function GetTileMetrics()
        local viewW = subCategoryView:GetWidth()
        if not viewW or viewW < 100 then viewW = contentWidth + SCROLL_INSET end
        local scrollW = viewW - SCROLL_INSET
        local tW = math.floor((scrollW - TILE_PAD * 2 - TILE_GAP) / 2)
        return tW, tW + TILE_GAP, scrollW
    end

    -- Reposition and resize all live tiles to match the current scroll width.
    -- Also keeps subCategoryContent width in sync so the scroll child never
    -- drifts out of step with the scroll frame after a resize.
    local function LayoutSubTiles()
        if #currentSubTiles == 0 then return end
        local tileW, tileStride, scrollW = GetTileMetrics()
        subCategoryContent:SetWidth(scrollW)
        local tileYOffset = 0
        for i, tile in ipairs(currentSubTiles) do
            local row = math.floor((i - 1) / 2)
            local col = (i - 1) % 2
            tile:SetWidth(tileW)
            tile:ClearAllPoints()
            tile:SetPoint("TOPLEFT", subCategoryContent, "TOPLEFT", TILE_PAD + (col * tileStride), -SUBCAT_TOP_PAD + (row * -TILE_ROW_STRIDE))
            tileYOffset = math.max(tileYOffset, SUBCAT_TOP_PAD + (row + 1) * TILE_ROW_STRIDE)
        end
        subCategoryContent:SetHeight(math.max(1, tileYOffset))
    end

    subCategoryView:SetScript("OnSizeChanged", function()
        if subCategoryView:IsShown() then
            LayoutSubTiles()
        end
    end)

    local function CreateSubCategoryTile(parent, name, index, options, modName, desc)
        local tileW, tileStride = GetTileMetrics()
        local tile = CreateFrame("Button", nil, parent)
        tile:SetSize(tileW, TILE_H)

        local row = math.floor((index-1) / 2)
        local col = (index-1) % 2
        tile:SetPoint("TOPLEFT", parent, "TOPLEFT", TILE_PAD + (col * tileStride), -SUBCAT_TOP_PAD + (row * -TILE_ROW_STRIDE))

        -- Chrome aligned with CreateAccordionCard: full-bleed fill, left accent, bottom divider (no frame border)
        local tBg = tile:CreateTexture(nil, "BACKGROUND")
        tBg:SetAllPoints()
        tBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)

        local divider = tile:CreateTexture(nil, "ARTWORK")
        divider:SetHeight(1)
        divider:SetPoint("BOTTOMLEFT", 20, 0)
        divider:SetPoint("BOTTOMRIGHT", -20, 0)
        local cdr, cdg, cdb = GetAccentColor()
        divider:SetColorTexture(cdr, cdg, cdb, 0.2)
        tinsert(dashAccentRefs.subcatDividers, divider)

        local accent = tile:CreateTexture(nil, "ARTWORK")
        accent:SetSize(3, 24)
        accent:SetPoint("TOPLEFT", 20, -18)
        local ar, ag, ab = GetAccentColor()
        accent:SetColorTexture(ar, ag, ab, 1)
        tinsert(dashAccentRefs.subcatAccents, accent)

        -- Label (x matches accordion title inset)
        local lbl = MakeText(tile, name, 18, 0.9, 0.9, 0.95, "LEFT")
        lbl:SetPoint("TOPLEFT", 35, -22)

        -- Collect subset of option names for description
        local descStr = desc or (L["FOCUS_LAYOUT_TAB_DESC"])

        -- Description Text
        local descLbl = MakeText(tile, descStr, 12, 0.55, 0.6, 0.65, "LEFT")
        descLbl:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", 0, -6)
        descLbl:SetPoint("RIGHT", tile, "RIGHT", -22, 0)
        descLbl:SetWordWrap(true)
        descLbl:SetHeight(40)
        descLbl:SetJustifyV("TOP")

        tile:SetScript("OnEnter", function()
            tBg:SetColorTexture(SBgHoverR, SBgHoverG, SBgHoverB, SBgA)
        end)
        tile:SetScript("OnLeave", function()
            tBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)
        end)
        tile:SetScript("OnClick", function()
            f.OpenCategoryDetail(modName, name, options)
        end)

        return tile
    end

    -- Full-width module-style row for subcategory navigation.
    -- Used instead of CreateSubCategoryTile when categories carry icon+accentColor metadata.
    -- Visual language matches DashboardHomeWelcome MakeToggleCard (accent rail, glow, icon, name, desc, chevron).
    local function CreateCategoryModuleRow(parent, cat, modName)
        local DC    = addon.DashboardConstants or {}
        local CARD_H    = DC.HOME_TOGGLE_CARD_H   or 88
        local ICON_SIZE = DC.HOME_TOGGLE_ICON_SIZE or 36
        local ac = cat.accentColor or { 0.40, 0.80, 1.0 }
        local mr, mg, mb = ac[1], ac[2], ac[3]
        -- Mini-modules carry getEnabled/setEnabled; those rows get an enable/disable pill.
        local hasToggle = (cat.enabledKey and cat.setEnabled) and true or false

        local card = CreateFrame("Button", nil, parent)
        card:SetHeight(CARD_H)
        card:SetClipsChildren(true)

        local cardBg = card:CreateTexture(nil, "BACKGROUND")
        cardBg:SetAllPoints()
        cardBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)
        card.cardBg = cardBg

        local cardInner = card:CreateTexture(nil, "BORDER")
        cardInner:SetPoint("TOPLEFT", 1, -1)
        cardInner:SetPoint("BOTTOMRIGHT", -1, 1)
        cardInner:SetColorTexture(1, 1, 1, 0.02)

        local accentRail = card:CreateTexture(nil, "ARTWORK")
        accentRail:SetWidth(4)
        accentRail:SetPoint("TOPLEFT", 0, 0)
        accentRail:SetPoint("BOTTOMLEFT", 0, 0)
        accentRail:SetColorTexture(mr, mg, mb, 1)

        local accentGlow = card:CreateTexture(nil, "ARTWORK")
        accentGlow:SetWidth(12)
        accentGlow:SetPoint("TOPLEFT", accentRail, "TOPRIGHT", 0, 0)
        accentGlow:SetPoint("BOTTOMLEFT", accentRail, "BOTTOMRIGHT", 0, 0)
        accentGlow:SetColorTexture(mr, mg, mb, 0.08)

        local chevronWell = card:CreateTexture(nil, "ARTWORK")
        chevronWell:SetPoint("TOPRIGHT", 0, 0)
        chevronWell:SetPoint("BOTTOMRIGHT", 0, 0)
        chevronWell:SetWidth(60)
        chevronWell:SetColorTexture(mr, mg, mb, 0.05)

        local divider = card:CreateTexture(nil, "ARTWORK")
        divider:SetHeight(1)
        divider:SetPoint("BOTTOMLEFT", 0, 0)
        divider:SetPoint("BOTTOMRIGHT", 0, 0)
        local cdr, cdg, cdb = GetAccentColor()
        divider:SetColorTexture(cdr, cdg, cdb, 0.15)
        tinsert(dashAccentRefs.cardDividers, divider)

        local iconTex = card:CreateTexture(nil, "ARTWORK")
        iconTex:SetSize(ICON_SIZE, ICON_SIZE)
        iconTex:SetPoint("LEFT", card, "LEFT", 18, 0)
        if cat.icon then
            if type(cat.icon) == "number" then
                iconTex:SetTexture(cat.icon)
            elseif cat.icon:find("[\\/]") then
                iconTex:SetTexture(cat.icon)
            else
                iconTex:SetTexture("Interface\\Icons\\" .. cat.icon)
            end
        end

        -- Layout: name row shares horizontal space with pill+chevron; desc always spans full width.
        -- This ensures desc is never truncated even on narrow 2-column cards.
        local NAME_H = 18
        local DESC_H = 36   -- tall enough for 2-3 wrapped lines at 11px
        local GAP    = 4
        local baseH  = NAME_H + GAP + DESC_H
        local topInset = math.floor(math.max(6, (CARD_H - math.max(ICON_SIZE, baseH)) / 2 + 0.5))

        -- Labels created without anchors; RIGHT anchors are set after chevron/pill below.
        local nameLbl = MakeText(card, cat.name and cat.name:upper() or "", 13, mr, mg, mb, "LEFT")
        nameLbl:SetHeight(NAME_H)
        nameLbl:SetWordWrap(false)

        local descLbl = MakeText(card, cat.desc or "", 11, 0.55, 0.57, 0.62, "LEFT")
        descLbl:SetHeight(DESC_H)
        descLbl:SetWordWrap(true)
        descLbl:SetJustifyV("TOP")

        -- Chevron created before the reposition block so nameLbl can anchor its RIGHT to it.
        local chevron = MakeText(card, ">", 14, mr, mg, mb, "CENTER")
        chevron:SetSize(12, 18)
        chevron:SetAlpha(0.7)

        -- Optional enable/disable pill (mini-modules only).
        -- Pill is pinned to TOPRIGHT of the name row so it never overlaps the desc text.
        local pillBtn
        if hasToggle then
            local PILL_W, PILL_H, PILL_THUMB = 40, 20, 15
            pillBtn = CreateFrame("Button", nil, card)
            pillBtn:SetSize(PILL_W, PILL_H)
            pillBtn:SetPoint("TOPRIGHT", card, "TOPRIGHT", -12, -(topInset - 1))
            pillBtn:SetFrameLevel(card:GetFrameLevel() + 5)
            -- Chevron sits left of pill, vertically aligned to it
            chevron:SetPoint("RIGHT", pillBtn, "LEFT", -8, 0)
            chevron:SetPoint("TOP",   pillBtn, "TOP",  0,  0)

            local pillBg = pillBtn:CreateTexture(nil, "BACKGROUND")
            pillBg:SetAllPoints()
            pillBg:SetColorTexture(0.18, 0.18, 0.22, 0.9)
            local pillBorder = pillBtn:CreateTexture(nil, "BORDER")
            pillBorder:SetPoint("TOPLEFT", -1, 1)
            pillBorder:SetPoint("BOTTOMRIGHT", 1, -1)
            pillBorder:SetColorTexture(1, 1, 1, 0.07)
            local pillGlow = pillBtn:CreateTexture(nil, "BORDER")
            pillGlow:SetPoint("TOPLEFT", -3, 3)
            pillGlow:SetPoint("BOTTOMRIGHT", 3, -3)
            pillGlow:SetColorTexture(mr, mg, mb, 0.08)
            local thumb = pillBtn:CreateTexture(nil, "ARTWORK")
            thumb:SetSize(PILL_THUMB, PILL_THUMB)
            thumb:SetTexture("Interface\\Buttons\\WHITE8X8")
            thumb:SetVertexColor(1, 1, 1, 0.92)

            local THUMB_OFF, THUMB_ON = 3, PILL_W - PILL_THUMB - 3
            card._applyPill = function(on)
                thumb:ClearAllPoints()
                thumb:SetPoint("LEFT", pillBtn, "LEFT", on and THUMB_ON or THUMB_OFF, 0)
                if on then
                    pillBg:SetColorTexture(mr, mg, mb, 0.85)
                    pillGlow:SetColorTexture(mr, mg, mb, 0.20)
                else
                    pillBg:SetColorTexture(0.18, 0.18, 0.22, 0.9)
                    pillGlow:SetColorTexture(mr, mg, mb, 0.04)
                end
            end
        else
            -- No pill: chevron floats right edge, vertically centered
            chevron:SetPoint("RIGHT",  card, "RIGHT",  -18, 0)
            chevron:SetPoint("CENTER", card, "CENTER",   0, 0)
        end

        -- Now position everything. Name's RIGHT anchors to chevron LEFT (pill/chevron area).
        -- Desc's RIGHT anchors to the card edge — full width, never clipped by pill.
        iconTex:ClearAllPoints()
        iconTex:SetPoint("TOPLEFT", card, "TOPLEFT", 18, -topInset)
        nameLbl:ClearAllPoints()
        nameLbl:SetPoint("TOPLEFT", iconTex, "TOPRIGHT", 10, 0)
        nameLbl:SetPoint("RIGHT", chevron, "LEFT", -6, 0)
        descLbl:ClearAllPoints()
        descLbl:SetPoint("TOPLEFT", nameLbl, "BOTTOMLEFT", 0, -GAP)
        -- Stop desc at the chevronWell boundary (60px from right) so text never bleeds
        -- into the toggle/chevron zone regardless of card width.
        descLbl:SetPoint("RIGHT", card, "RIGHT", -62, 0)

        local function CurrentEnabled()
            if not hasToggle then return true end
            return cat.getEnabled and cat.getEnabled() ~= false
        end

        local function ApplyRowState(enabled)
            if enabled then
                if iconTex.SetDesaturated then iconTex:SetDesaturated(false) end
                iconTex:SetVertexColor(1, 1, 1, 1)
                accentRail:SetColorTexture(mr, mg, mb, 1)
                accentGlow:SetColorTexture(mr, mg, mb, 0.08)
                nameLbl:SetTextColor(mr, mg, mb)
                descLbl:SetTextColor(0.55, 0.57, 0.62)
            else
                if iconTex.SetDesaturated then iconTex:SetDesaturated(true) end
                iconTex:SetVertexColor(0.50, 0.52, 0.56, 0.70)
                accentRail:SetColorTexture(mr, mg, mb, 0.30)
                accentGlow:SetColorTexture(mr, mg, mb, 0.03)
                nameLbl:SetTextColor(0.44, 0.46, 0.50)
                descLbl:SetTextColor(0.36, 0.38, 0.42)
            end
            if card._applyPill then card._applyPill(enabled) end
        end
        ApplyRowState(CurrentEnabled())

        card:SetScript("OnEnter", function()
            cardBg:SetColorTexture(SBgHoverR, SBgHoverG, SBgHoverB, SBgA)
            chevron:SetAlpha(1)
        end)
        card:SetScript("OnLeave", function()
            cardBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)
            chevron:SetAlpha(0.7)
        end)
        card:SetScript("OnClick", function()
            local opts = type(cat.options) == "function" and cat.options() or cat.options
            f.OpenCategoryDetail(modName, cat.name, opts)
        end)

        if pillBtn then
            pillBtn:SetScript("OnClick", function()
                local newOn = not CurrentEnabled()
                if cat.setEnabled then cat.setEnabled(newOn) end
                ApplyRowState(newOn)
                if f.DashboardApplyGroupSubcats then
                    f.DashboardApplyGroupSubcats(cat.moduleKey or f.currentModuleKey or "augment")
                end
            end)
            pillBtn:SetScript("OnEnter", function()
                cardBg:SetColorTexture(SBgHoverR, SBgHoverG, SBgHoverB, SBgA)
            end)
            pillBtn:SetScript("OnLeave", function()
                cardBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)
            end)
        end

        return card, CARD_H
    end

    local function ShouldShowDashboardSubcategory(moduleKey, cat)
        if not cat then return false end
        if moduleKey == "axis" and cat.key == "Modules" then
            return false
        end
        if cat.hidden and cat.hidden() then return false end
        return true
    end

    --- @param skipEntranceCascade boolean|nil When true, skip staggered card entrance (search navigation expands accordions and must not snapshot pre-expand Y positions).
    f.OpenCategoryDetail = function(modName, catName, options, skipEntranceCascade)
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

        do
            local selCat = matchedCatIdx and addon.OptionCategories[matchedCatIdx]
            local previewMode = selCat and selCat.dashboardPreviewMode or nil
            ApplyDetailPreviewStrip(previewMode)
        end

        ClearDetailCards()
        CrossfadeTo(detailView)
        ShowDetailHeader()
        detailContent:Show()
        detailScroll:SetVerticalScroll(0)

        if f.detailTitle then
            f.detailTitle:SetText(modName:upper() .. "  >  " .. catName:upper())
        end

        -- Show fixed header buttons only for pages that expose them.
        do
            local selCat = matchedCatIdx and addon.OptionCategories[matchedCatIdx]
            local isAugment = selCat and selCat.key == "AugmentImprovements"
            local isAugmentFlightTimer = selCat and selCat.key == "AugmentFlightTimer"
            if f.detailPreviewBtn then
                if isAugment then
                    f.detailPreviewBtn._onClick = function()
                        if addon.Augment and addon.Augment.PreviewToasts then addon.Augment.PreviewToasts() end
                    end
                    f.detailPreviewBtn:Show()
                elseif isAugmentFlightTimer then
                    f.detailPreviewBtn._onClick = function()
                        local ft = addon.Augment and addon.Augment.FlightTimer
                        if ft and ft.Bar and ft.Bar.Preview then ft.Bar.Preview() end
                    end
                    f.detailPreviewBtn:Show()
                else
                    f.detailPreviewBtn:Hide()
                end
            end
            if f.detailResetBtn then
                if isAugment then
                    f.detailResetBtn._onClick = function()
                        if addon.Augment and addon.Augment.ResetPosition then addon.Augment.ResetPosition() end
                    end
                    f.detailResetBtn:Show()
                elseif isAugmentFlightTimer then
                    f.detailResetBtn._onClick = function()
                        local ft = addon.Augment and addon.Augment.FlightTimer
                        if ft and ft.Bar and ft.Bar.ResetPosition then ft.Bar.ResetPosition() end
                    end
                    f.detailResetBtn:Show()
                else
                    f.detailResetBtn:Hide()
                end
            end
            if f.detailAnchorBtn then if isAugment then f.detailAnchorBtn:Show() else f.detailAnchorBtn:Hide() end end
            if f.detailEnableBtn then f.detailEnableBtn:Hide() end
        end

        f.BuildAccordionDetail(catName, options)

        if not skipEntranceCascade then
            -- Cascade effect (faster per UX feedback)
            for i, card in ipairs(currentDetailCards) do
                if not card:IsShown() then
                    card:SetAlpha(1)
                else
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

    f.OpenModule = function(name, moduleKey, skipDetailBuild)
        if searchBox then searchBox:ClearFocus() end
        if searchBarShell then searchBarShell:Hide() end
        if f.HideSearchModuleFilterMenu then f.HideSearchModuleFilterMenu() end
        if f.HideSearchDropdown then f.HideSearchDropdown() end

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
            if match and cat.options and ShouldShowDashboardSubcategory(moduleKey, cat) then
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

        -- Use module-style rows if categories carry icon metadata, otherwise use tile grid.
        local useModuleRows = cats[1] and cats[1].icon
        local tileYOffset = 0

        if useModuleRows then
            -- Create all tiles first (no positioning yet)
            for _, cat in ipairs(cats) do
                local tile = CreateCategoryModuleRow(subCategoryContent, cat, modName)
                tinsert(currentSubTiles, tile)
            end

            -- Responsive 2-column layout function. Called on first render (animate=true)
            -- and again on resize (animate=false) via the OnSizeChanged hook above.
            local DC_mod = addon.DashboardConstants or {}
            local CARD_H_MOD = DC_mod.HOME_TOGGLE_CARD_H or 88
            local VGAP = DC_mod.HOME_TOGGLE_CARD_GAP or 8
            local HGAP = 12  -- gap between the two columns

            local function LayoutModuleRows(animate)
                -- Derive available width from the view frame (avoids stale GetWidth on
                -- anchor-sized frames that haven't completed layout when OnSizeChanged fires).
                local viewW = subCategoryView:GetWidth()
                if not viewW or viewW < 100 then viewW = contentWidth + 80 end
                local availW = math.max(200, viewW - 80)  -- match scroll frame 40px insets
                subCategoryContent:SetWidth(availW)

                -- Switch to 1 column when the view is too narrow for two decent cards.
                local MIN_COL_W = 260
                local cols = (availW >= MIN_COL_W * 2 + HGAP) and 2 or 1
                local cardW = math.floor((availW - (cols - 1) * HGAP) / cols)

                for i, tile in ipairs(currentSubTiles) do
                    local col = (i - 1) % cols
                    local row = math.floor((i - 1) / cols)
                    local tx  = col * (cardW + HGAP)
                    local ty  = SUBCAT_TOP_PAD + row * (CARD_H_MOD + VGAP)
                    tile:SetWidth(cardW)
                    tile:ClearAllPoints()
                    if animate then
                        tile:SetAlpha(0)
                        tile:SetPoint("TOPLEFT", subCategoryContent, "TOPLEFT", tx, -(ty + 20))
                        local idx = i
                        if C_Timer and C_Timer.After then
                            C_Timer.After(idx * 0.05, function()
                                if tile:IsShown() then
                                    tile:SetPoint("TOPLEFT", subCategoryContent, "TOPLEFT", tx, -ty)
                                    UIFrameFadeIn(tile, 0.2, 0, 1)
                                end
                            end)
                        else
                            tile:SetAlpha(1)
                            tile:SetPoint("TOPLEFT", subCategoryContent, "TOPLEFT", tx, -ty)
                        end
                    else
                        tile:SetPoint("TOPLEFT", subCategoryContent, "TOPLEFT", tx, -ty)
                    end
                end

                local totalRows = math.ceil(#currentSubTiles / cols)
                subCategoryContent:SetHeight(math.max(1, SUBCAT_TOP_PAD + totalRows * (CARD_H_MOD + VGAP)))
            end

            LayoutModuleRows(true)
            f._layoutModuleRows = LayoutModuleRows

            -- Ticker polls every 0.25s for view-width changes so the grid reflows when
            -- the dashboard is resized — more reliable than OnSizeChanged on hidden views.
            local watchW = subCategoryView:GetWidth() or 0
            if moduleRowWatcher then moduleRowWatcher:Cancel() end
            moduleRowWatcher = C_Timer.NewTicker(0.25, function()
                if not f._layoutModuleRows then
                    if moduleRowWatcher then moduleRowWatcher:Cancel() end
                    moduleRowWatcher = nil
                    return
                end
                local w = subCategoryView:GetWidth() or 0
                if math.abs(w - watchW) > 4 then
                    watchW = w
                    f._layoutModuleRows(false)
                end
            end)
        else
            -- Standard 2-column tile grid (non-Augment modules)
            for i, cat in ipairs(cats) do
                local options = type(cat.options) == "function" and cat.options() or cat.options
                local tile = CreateSubCategoryTile(subCategoryContent, cat.name, i, options, modName, cat.desc)
                tinsert(currentSubTiles, tile)

                local row = math.floor((i-1) / 2)
                tileYOffset = math.max(tileYOffset, SUBCAT_TOP_PAD + (row + 1) * TILE_ROW_STRIDE)

                -- Staggered Cascade Entrance
                tile:SetAlpha(0)
                local _, _, _, xVal, yVal = tile:GetPoint()
                if xVal ~= nil and yVal ~= nil then
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
        end
            if mk == "insight" and addon.Insight and addon.Insight.SetDashboardPreviewMode then
                addon.Insight.SetDashboardPreviewMode("global")
            end
            -- Hide the preview tab when landing on the tiles page (not when skipDetailBuild
            -- is true, which means OpenModule is only being called as a transit step to build
            -- the back-button tile context before OpenCategoryDetail shows the actual detail).
            if not skipDetailBuild and addon.DashboardPreview and addon.DashboardPreview.SetActiveModuleKey then
                addon.DashboardPreview.SetActiveModuleKey(nil)
            end
            -- SetSidebarState above ran before subCategoryView was shown; ApplySidebarState uses
            -- subCategoryView:IsShown() to prefer the module header over the first sub-row.
            SetSidebarState({ view = "module", activeModuleKey = mk, activeCategoryIndex = CLEAR })
        elseif not skipDetailBuild then
            -- Only 1 category (or none), go straight to details
            ClearDetailCards()
            CrossfadeTo(detailView)
            ShowDetailHeader()
            detailContent:Show()
            detailScroll:SetVerticalScroll(0)
            -- Single-category modules carry no Insight preview strip.
            ApplyDetailPreviewStrip(nil)

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

            -- Show fixed header buttons only for pages that expose them.
            do
                local isAugment = cats[1] and cats[1].key == "AugmentImprovements"
                local isAugmentFlightTimer = cats[1] and cats[1].key == "AugmentFlightTimer"
                if f.detailPreviewBtn then
                    if isAugment then
                        f.detailPreviewBtn._onClick = function()
                            if addon.Augment and addon.Augment.PreviewToasts then addon.Augment.PreviewToasts() end
                        end
                        f.detailPreviewBtn:Show()
                    elseif isAugmentFlightTimer then
                        f.detailPreviewBtn._onClick = function()
                            local ft = addon.Augment and addon.Augment.FlightTimer
                            if ft and ft.Bar and ft.Bar.Preview then ft.Bar.Preview() end
                        end
                        f.detailPreviewBtn:Show()
                    else
                        f.detailPreviewBtn:Hide()
                    end
                end
                if f.detailResetBtn then
                    if isAugment then
                        f.detailResetBtn._onClick = function()
                            if addon.Augment and addon.Augment.ResetPosition then addon.Augment.ResetPosition() end
                        end
                        f.detailResetBtn:Show()
                    elseif isAugmentFlightTimer then
                        f.detailResetBtn._onClick = function()
                            local ft = addon.Augment and addon.Augment.FlightTimer
                            if ft and ft.Bar and ft.Bar.ResetPosition then ft.Bar.ResetPosition() end
                        end
                        f.detailResetBtn:Show()
                    else
                        f.detailResetBtn:Hide()
                    end
                end
                if f.detailAnchorBtn then if isAugment then f.detailAnchorBtn:Show() else f.detailAnchorBtn:Hide() end end
                if f.detailEnableBtn then f.detailEnableBtn:Hide() end
            end

            if cats[1] then
                local options = type(cats[1].options) == "function" and cats[1].options() or cats[1].options
                f.BuildAccordionDetail(cats[1].name, options)

                -- Cascade effect (faster per UX feedback)
                for i, card in ipairs(currentDetailCards) do
                    if not card:IsShown() then
                        card:SetAlpha(1)
                    else
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
    end

    addon.DashboardAccordionBuild_Init(f, {
        L                  = L,
        MakeText           = MakeText,
        SBg                = SBg,
        SBd                = SBd,
        SBgA               = SBgA,
        UpdateDetailLayout = UpdateDetailLayout,
        accordionCardParams = accordionCardParams,
        currentDetailCards = currentDetailCards,
        detailContent      = detailContent,
        detailScroll       = detailScroll,
        detailView         = detailView,
    })

    return {
        NavigateToOption = NavigateToOption,
        NavigateToModuleToggles = NavigateToModuleToggles,
        NavigateToDashboardBackground = NavigateToDashboardBackground,
        NavigateToAxisHome = NavigateToAxisHome,
        NavigateToClassColourTinting = NavigateToClassColourTinting,
    }
end
