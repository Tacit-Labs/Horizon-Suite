--[[
    Horizon Suite - Focus - Section Headers
    HideAllSectionHeaders, GetFocusedGroupKey, AcquireSectionHeader.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

local sectionPool = addon.sectionPool
local scrollFrame = addon.scrollFrame

--- Hides all section headers. When excludeGroupKeys is set, headers with those groupKeys are
--- left visible to fade out (used for WQ toggle when a category disappears).
--- @param excludeGroupKeys table|nil Optional { [groupKey]=true } for headers to exclude (fade-out instead)
local function HideAllSectionHeaders(excludeGroupKeys)
    for i = 1, addon.SECTION_POOL_SIZE do
        local s = sectionPool[i]
        if excludeGroupKeys and s.groupKey and excludeGroupKeys[s.groupKey] then
            -- Leave visible; will be faded out by UpdateSectionHeaderFadeOut
        else
            s.active = false
            s:Hide()
            s:SetAlpha(0)
        end
    end
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

    local label = addon.L[addon.SECTION_LABELS[groupKey] or groupKey]
    label = addon.ApplyTextCase(label, "sectionHeaderTextCase", "upper")
    local color = addon.GetSectionColor(groupKey)
    if addon.GetDB("dimNonSuperTracked", false) and focusedGroupKey and groupKey ~= focusedGroupKey then
        color = addon.ApplyDimColor(color)
    end
    s.text:SetText(label)
    s.shadow:SetText(label)
    s.text:SetTextColor(color[1], color[2], color[3], addon.SECTION_COLOR_A)

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
            s.chevron:SetText("+")
        elseif addon.IsCategoryCollapsed(groupKey) then
            s.chevron:SetText("+")
        else
            s.chevron:SetText("-")
        end
    end

    s:SetScript("OnEnter", nil)
    s:SetScript("OnLeave", nil)

    s:SetScript("OnClick", function(self)
        local key = self.groupKey
        if not key then return end

        if addon.IsCategoryCollapsed(key) then
            if addon.PrepareGroupExpandSlideDown then addon.PrepareGroupExpandSlideDown(key) end
            addon.SetCategoryCollapsed(key, false)
            if self.chevron then
                self.chevron:SetText("-")
            end
            if addon.focus.collapsed then
                addon.focus.collapsed = false
                addon.EnsureDB()
                addon.SetDB("collapsed", false)
                addon.chevron:SetText("-")
                scrollFrame:Show()
            end
            addon.FullLayout()
            if addon.ApplyGroupExpandSlideDown then addon.ApplyGroupExpandSlideDown() end
        else
            if self.chevron then
                self.chevron:SetText("+")
            end
            if addon.StartGroupCollapse then
                addon.StartGroupCollapse(key)
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
