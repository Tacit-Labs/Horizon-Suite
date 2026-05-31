--[[
    Horizon Suite - Focus - Section Headers
    HideAllSectionHeaders, GetFocusedGroupKey, AcquireSectionHeader.
]]

local addon = _G.HorizonSuite
local sectionPool = addon.sectionPool
local scrollFrame = addon.scrollFrame

-- Hides all section headers. When excludeGroupKeys is set, headers with those groupKeys are
-- left visible to fade out (used for WQ toggle when a category disappears).
-- @param excludeGroupKeys table|nil Optional { [groupKey]=true } for headers to exclude (fade-out instead)
local function HideAllSectionHeaders(excludeGroupKeys)
    for i = 1, addon.SECTION_POOL_SIZE do
        local s = sectionPool[i]
        if excludeGroupKeys and s.groupKey and excludeGroupKeys[s.groupKey] then
            -- Leave visible; will be faded out by UpdateSectionHeaderFadeOut
        else
            s.active = false
            if s.rarePrevBtn then s.rarePrevBtn:Hide() end
            if s.rareNextBtn then s.rareNextBtn:Hide() end
            s:Hide()
            s:SetAlpha(0)
        end
    end
end

local function ConfigureRareNav(s, groupKey)
    local prevBtn, nextBtn = s.rarePrevBtn, s.rareNextBtn
    if not prevBtn or not nextBtn then return end

    local isExpanded
    if addon.focus.collapsed and addon.GetDB("showSectionHeadersWhenCollapsed", false) then
        local pceg = addon.focus.collapse and addon.focus.collapse.panelCollapsedExpandedGroups
        isExpanded = pceg and pceg[groupKey]
    else
        isExpanded = not addon.IsCategoryCollapsed(groupKey)
    end
    if not isExpanded then
        prevBtn:Hide()
        nextBtn:Hide()
        return
    end

    local provider
    if groupKey == "SILVERDRAGON" then
        provider = rawget(_G, "HorizonSilverDragon")
    elseif groupKey == "RARESCANNER" then
        provider = rawget(_G, "HorizonRareScanner")
    end

    if not provider or not provider.alertOrder or #provider.alertOrder <= 1 then
        prevBtn:Hide()
        nextBtn:Hide()
        return
    end

    local gap = (addon.Scaled and addon.Scaled(3)) or 3
    local r, g, b, a = 1, 1, 1, 1
    if s.text and s.text.GetTextColor then
        r, g, b, a = s.text:GetTextColor()
    end
    prevBtn:ClearAllPoints()
    nextBtn:ClearAllPoints()
    local rightInset = (addon.Scaled and addon.Scaled(2)) or 2
    local rightOffset = ((addon.GetScaledPadding and addon.GetScaledPadding()) or 0) - rightInset
    nextBtn:SetPoint("RIGHT", s, "RIGHT", rightOffset, 0)
    prevBtn:SetPoint("RIGHT", nextBtn, "LEFT", -gap, 0)
    if prevBtn.arrowTex then
        prevBtn.arrowTex:SetDesaturated(true)
        prevBtn.arrowTex:SetVertexColor(r, g, b, a)
    end
    if nextBtn.arrowTex then
        nextBtn.arrowTex:SetDesaturated(true)
        nextBtn.arrowTex:SetVertexColor(r, g, b, a)
    end
    local function setArrowColor(btn, mul)
        if not btn.arrowTex then return end
        btn.arrowTex:SetVertexColor(math.min(r * mul, 1), math.min(g * mul, 1), math.min(b * mul, 1), a)
    end
    prevBtn:SetScript("OnEnter", function(self) setArrowColor(self, 1.25) end)
    prevBtn:SetScript("OnLeave", function(self) setArrowColor(self, 1) end)
    nextBtn:SetScript("OnEnter", function(self) setArrowColor(self, 1.25) end)
    nextBtn:SetScript("OnLeave", function(self) setArrowColor(self, 1) end)

    prevBtn:SetScript("OnClick", function()
        if provider.NavigatePrev then provider.NavigatePrev() end
    end)
    nextBtn:SetScript("OnClick", function()
        if provider.NavigateNext then provider.NavigateNext() end
    end)

    prevBtn:Show()
    nextBtn:Show()
end

local function GetFocusedGroupKey(grouped)
    if not grouped then return nil end
    for _, grp in ipairs(grouped) do
        for _, qData in ipairs(grp.quests) do
            if qData.isSuperTracked then
                return grp.key
            end
        end
    end
    return nil
end

local function AcquireSectionHeader(groupKey, focusedGroupKey)
    local fadeOutKeys = addon.focus.collapse and addon.focus.collapse.sectionHeadersFadingOutKeys
    local s
    repeat
        addon.focus.layout.sectionIdx = addon.focus.layout.sectionIdx + 1
        if addon.focus.layout.sectionIdx > addon.SECTION_POOL_SIZE then return nil end
        s = sectionPool[addon.focus.layout.sectionIdx]
    until not (fadeOutKeys and s.groupKey and fadeOutKeys[s.groupKey])
    s.groupKey = groupKey

    local labelKey = addon.SECTION_LABELS[groupKey] or groupKey
    if groupKey == "RARESCANNER" and addon.GetDB("rs_sectionTitleRares", false) then
        labelKey = "FOCUS_INTEGRATION_RARE_SECTION_TITLE_LABEL"
    elseif groupKey == "SILVERDRAGON" and addon.GetDB("sd_sectionTitleRares", false) then
        labelKey = "FOCUS_INTEGRATION_RARE_SECTION_TITLE_LABEL"
    end
    local label = addon.L[labelKey]
    label = addon.ApplyTextCase(label, "sectionHeaderTextCase", "upper")
    local color = addon.GetSectionHeaderDisplayColor(groupKey, focusedGroupKey)
    addon.SetTextWithShadow(s.text, s.shadow, label)
    local secA = addon.SECTION_COLOR_A or 1
    if addon.ShouldDimSectionHeaderForSuperTrack(groupKey, focusedGroupKey) then
        secA = secA * addon.GetDimAlpha()
    end
    s.text:SetTextColor(color[1], color[2], color[3], secA)
    local baseSec = addon.SECTION_COLOR_A or 1
    local shadowAlpha = (addon.SHADOW_A or 0.8) * (secA / baseSec)
    if s.chevron then
        s.chevron:SetTextColor(color[1], color[2], color[3], secA)
    end
    s.shadow:SetTextColor(0, 0, 0, shadowAlpha)

    -- Ensure a small visual gap between the chevron and the label text.
    if s.chevron and s.text then
        local CHEVRON_GAP_PX = addon.SECTION_CHEVRON_GAP_PX or 4
        s.text:ClearAllPoints()
        s.shadow:ClearAllPoints()
        s.text:SetPoint("LEFT", s.chevron, "RIGHT", CHEVRON_GAP_PX, 0)
        s.shadow:SetPoint("CENTER", s.text, "CENTER", addon.SHADOW_OX, addon.SHADOW_OY)
    end

    if s.chevron then
        if addon.focus.collapsed and addon.GetDB("showSectionHeadersWhenCollapsed", false) then
            local pceg = addon.focus.collapse.panelCollapsedExpandedGroups
            s.chevron:SetText((pceg and pceg[groupKey]) and "-" or "+")
        elseif addon.IsCategoryCollapsed(groupKey) then
            s.chevron:SetText("+")
        else
            s.chevron:SetText("-")
        end
    end

    ConfigureRareNav(s, groupKey)

    s:SetScript("OnEnter", nil)
    s:SetScript("OnLeave", nil)

    s:SetScript("OnClick", function(self)
        local key = self.groupKey
        if not key then return end

        if addon.focus.collapsed and addon.GetDB("showSectionHeadersWhenCollapsed", false) then
            local pceg = addon.focus.collapse.panelCollapsedExpandedGroups
            if pceg and pceg[key] then
                -- Collapsing a category
                pceg[key] = nil
                if self.chevron then self.chevron:SetText("+") end
                -- If no categories remain expanded, slide header back to bottom
                local anyLeft = false
                for _, v in pairs(pceg) do if v then anyLeft = true; break end end
                if not anyLeft
                    and addon.GetDB("growUp", false)
                    and addon.GetDB("growUpHeaderMode", "always") == "collapse"
                    and addon.GetDB("animations", true)
                then
                    local panelH = addon.HS and addon.HS:GetHeight()
                        or (addon.focus.layout and addon.focus.layout.currentHeight)
                        or addon.GetCollapsedHeight()
                    local minimal = addon.GetDB("hideObjectivesHeader", false)
                    local S = addon.Scaled or function(v) return v end
                    local pad = S(addon.PADDING)
                    local headerH = minimal and addon.GetScaledMinimalHeaderHeight()
                        or (pad + addon.GetHeaderHeight())
                    addon.focus.collapse.headerSlidingToBottom = true
                    addon.focus.collapse.headerSlideStartY = math.max(0, (panelH or 0) - headerH)
                    addon.focus.collapse.headerSlideTime = 0
                    if addon.EnsureFocusUpdateRunning then addon.EnsureFocusUpdateRunning() end
                end
                -- Animate entries out; UpdateGroupCollapseCompletion will call FullLayout.
                if addon.GetDB("animations", true) and addon.StartGroupCollapseVisual then
                    addon.StartGroupCollapseVisual(key)
                    if addon.EnsureFocusUpdateRunning then addon.EnsureFocusUpdateRunning() end
                else
                    addon.FullLayout()
                end
            else
                -- Expanding a category
                if not pceg then
                    addon.focus.collapse.panelCollapsedExpandedGroups = {}
                    pceg = addon.focus.collapse.panelCollapsedExpandedGroups
                end
                -- Check if this is the first category being expanded
                local wasAnyExpanded = false
                for _, v in pairs(pceg) do if v then wasAnyExpanded = true; break end end
                pceg[key] = true
                if self.chevron then self.chevron:SetText("-") end
                -- First expand: slide header from bottom to top
                if not wasAnyExpanded
                    and addon.GetDB("growUp", false)
                    and addon.GetDB("growUpHeaderMode", "always") == "collapse"
                    and addon.GetDB("animations", true)
                then
                    local panelH = addon.focus.layout and addon.focus.layout.targetHeight
                        or (addon.HS and addon.HS:GetHeight()) or addon.MIN_HEIGHT
                    local minimal = addon.GetDB("hideObjectivesHeader", false)
                    local S = addon.Scaled or function(v) return v end
                    local pad = S(addon.PADDING)
                    local headerH = minimal and addon.GetScaledMinimalHeaderHeight()
                        or (pad + addon.GetHeaderHeight())
                    addon.focus.collapse.headerSlidingToTop = true
                    addon.focus.collapse.headerSlideEndY = math.max(0, (panelH or 0) - headerH)
                    addon.focus.collapse.headerSlideTime = 0
                    if addon.EnsureFocusUpdateRunning then addon.EnsureFocusUpdateRunning() end
                end
                addon.FullLayout()
            end
            return
        end

        if addon.IsCategoryCollapsed(key) then
            -- Expanding a category: check if we're coming from all-categories-collapsed state
            local wasAllCollapsed = addon.focus.layout and addon.focus.layout.allCategoriesCollapsed
            if addon.PrepareGroupExpandSlideDown then addon.PrepareGroupExpandSlideDown(key) end
            addon.SetCategoryCollapsed(key, false)
            if self.chevron then
                self.chevron:SetText("-")
            end
            -- Slide header from bottom to top when first category expands
            if wasAllCollapsed
                and addon.GetDB("growUp", false)
                and addon.GetDB("growUpHeaderMode", "always") == "collapse"
                and addon.GetDB("animations", true)
            then
                local panelH = addon.focus.layout and addon.focus.layout.targetHeight
                    or (addon.HS and addon.HS:GetHeight()) or addon.MIN_HEIGHT
                local minimal = addon.GetDB("hideObjectivesHeader", false)
                local S = addon.Scaled or function(v) return v end
                local pad = S(addon.PADDING)
                local headerH = minimal and addon.GetScaledMinimalHeaderHeight()
                    or (pad + addon.GetHeaderHeight())
                addon.focus.collapse.headerSlidingToTop = true
                addon.focus.collapse.headerSlideEndY = math.max(0, (panelH or 0) - headerH)
                addon.focus.collapse.headerSlideTime = 0
                if addon.EnsureFocusUpdateRunning then addon.EnsureFocusUpdateRunning() end
            end
            -- Cancel any in-progress collapse animation so the FullLayout guard is not triggered.
            if addon.CancelGroupCollapse then addon.CancelGroupCollapse(key) end
            addon.FullLayout()
            if addon.ApplyGroupExpandSlideDown then addon.ApplyGroupExpandSlideDown() end
        else
            -- Collapsing a category: check if this will make all categories collapsed
            if self.chevron then
                self.chevron:SetText("+")
            end
            -- Check if after this collapse, all categories will be collapsed
            local willAllBeCollapsed = false
            if addon.GetDB("growUp", false)
                and addon.GetDB("growUpHeaderMode", "always") == "collapse"
                and addon.GetDB("animations", true)
                and addon.GetDB("showSectionHeaders", true)
            then
                -- Check currently visible section headers (includes all entry types)
                willAllBeCollapsed = true
                for i = 1, addon.SECTION_POOL_SIZE do
                    local s = sectionPool[i]
                    if s and s.active and s.groupKey and s.groupKey ~= key then
                        if not addon.IsCategoryCollapsed(s.groupKey) then
                            willAllBeCollapsed = false
                            break
                        end
                    end
                end
            end
            if addon.StartGroupCollapse then
                addon.StartGroupCollapse(key)
            end
            -- Slide header from top to bottom when last category collapses
            if willAllBeCollapsed then
                local panelH = addon.HS and addon.HS:GetHeight()
                    or (addon.focus.layout and addon.focus.layout.currentHeight)
                    or addon.GetCollapsedHeight()
                local minimal = addon.GetDB("hideObjectivesHeader", false)
                local S = addon.Scaled or function(v) return v end
                local pad = S(addon.PADDING)
                local headerH = minimal and addon.GetScaledMinimalHeaderHeight()
                    or (pad + addon.GetHeaderHeight())
                addon.focus.collapse.headerSlidingToBottom = true
                addon.focus.collapse.headerSlideStartY = math.max(0, (panelH or 0) - headerH)
                addon.focus.collapse.headerSlideTime = 0
                if addon.EnsureFocusUpdateRunning then addon.EnsureFocusUpdateRunning() end
            end
        end
    end)

    s.active = true
    if addon.focus.collapse.sectionHeadersFadingIn and addon.GetDB("animations", true) then
        local staggerIdx = addon.focus.layout.sectionIdx - 1
        s.staggerDelay = staggerIdx * (addon.FOCUS_ANIM and addon.FOCUS_ANIM.stagger or 0.05)
        s:SetAlpha(0)
    else
        s.staggerDelay = nil
        s:SetAlpha(1)
    end
    s:Show()
    return s
end

addon.HideAllSectionHeaders = HideAllSectionHeaders
addon.GetFocusedGroupKey    = GetFocusedGroupKey
addon.AcquireSectionHeader  = AcquireSectionHeader
