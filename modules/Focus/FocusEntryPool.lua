--[[
    Horizon Suite - Focus - Entry Pool
    Quest entry frames, section headers, ApplyTypography, ApplyDimensions.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
local function T(key)
    return (addon.L and addon.L[key]) or key
end

-- ============================================================================
-- ENTRY POOL
-- ============================================================================

local pool      = {}
local activeMap = {}

-- Delve affix row: one FontString pair per name (user font) + one pair per " · " separator (default game font).
local DELVE_AFFIX_MAX_NAMES = 8
addon.DELVE_AFFIX_MAX_NAMES = DELVE_AFFIX_MAX_NAMES

local function CreateQuestEntry(parent, index)
    local e = CreateFrame("Frame", nil, parent)
    local _S = addon.Scaled or function(v) return v end
    local w = addon.GetPanelWidth() - _S(addon.PADDING) * 2
    local textW = w
    e:SetSize(w, 20)

    -- Active-quest bar (left or right; position set in Layout)
    e.trackBar = e:CreateTexture(nil, "OVERLAY")
    e.trackBar:SetColorTexture(0.45, 0.75, 1.00, 0.70)
    e.trackBar:Hide()

    -- Highlight inset
    local highlightInset = 5
    e.highlightBg = e:CreateTexture(nil, "BACKGROUND")
    e.highlightBg:SetPoint("TOPLEFT", e, "TOPLEFT", highlightInset, -highlightInset)
    e.highlightBg:SetPoint("BOTTOMRIGHT", e, "BOTTOMRIGHT", -highlightInset, highlightInset)
    e.highlightBg:SetColorTexture(0.2, 0.4, 0.6, 0.25)
    e.highlightBg:Hide()
    -- Top strip
    e.highlightTop = e:CreateTexture(nil, "BACKGROUND")
    e.highlightTop:SetHeight(2)
    e.highlightTop:SetPoint("TOPLEFT", e, "TOPLEFT", highlightInset, -highlightInset)
    e.highlightTop:SetPoint("TOPRIGHT", e, "TOPRIGHT", -highlightInset, 0)
    e.highlightTop:SetColorTexture(0.35, 0.55, 0.85, 0.4)
    e.highlightTop:Hide()
    -- 1px highlight border
    local borderW = 1
    e.highlightBorderT = e:CreateTexture(nil, "BORDER")
    e.highlightBorderT:SetHeight(borderW)
    e.highlightBorderT:SetPoint("TOPLEFT", e, "TOPLEFT", highlightInset, -highlightInset)
    e.highlightBorderT:SetPoint("TOPRIGHT", e, "TOPRIGHT", -highlightInset, 0)
    e.highlightBorderT:SetColorTexture(0.40, 0.70, 1.00, 0.6)
    e.highlightBorderT:Hide()
    e.highlightBorderB = e:CreateTexture(nil, "BORDER")
    e.highlightBorderB:SetHeight(borderW)
    e.highlightBorderB:SetPoint("BOTTOMLEFT", e, "BOTTOMLEFT", highlightInset, 0)
    e.highlightBorderB:SetPoint("BOTTOMRIGHT", e, "BOTTOMRIGHT", -highlightInset, highlightInset)
    e.highlightBorderB:SetColorTexture(0.40, 0.70, 1.00, 0.6)
    e.highlightBorderB:Hide()
    e.highlightBorderL = e:CreateTexture(nil, "BORDER")
    e.highlightBorderL:SetWidth(borderW)
    e.highlightBorderL:SetPoint("TOPLEFT", e, "TOPLEFT", highlightInset, -highlightInset)
    e.highlightBorderL:SetPoint("BOTTOMLEFT", e, "BOTTOMLEFT", highlightInset, highlightInset)
    e.highlightBorderL:SetColorTexture(0.40, 0.70, 1.00, 0.6)
    e.highlightBorderL:Hide()
    e.highlightBorderR = e:CreateTexture(nil, "BORDER")
    e.highlightBorderR:SetWidth(borderW)
    e.highlightBorderR:SetPoint("TOPRIGHT", e, "TOPRIGHT", -highlightInset, -highlightInset)
    e.highlightBorderR:SetPoint("BOTTOMRIGHT", e, "BOTTOMRIGHT", -highlightInset, highlightInset)
    e.highlightBorderR:SetColorTexture(0.40, 0.70, 1.00, 0.6)
    e.highlightBorderR:Hide()

    local btnName = "HSItemBtn" .. index
    e.itemBtn = CreateFrame("Button", btnName, e)
    e.itemBtn:SetSize(_S(addon.ITEM_BTN_SIZE), _S(addon.ITEM_BTN_SIZE))
    e.itemBtn:SetPoint("TOPRIGHT", e, "TOPRIGHT", 0, 2)
    e.itemBtn:RegisterForClicks("AnyDown", "AnyUp")
    e.itemBtn:SetFrameStrata("MEDIUM")
    e.itemBtn:SetFrameLevel(e:GetFrameLevel() + 10)
    e.itemBtn._ownerEntry = e

    addon.StyleQuestItemButton(e.itemBtn)

    e.itemBtn.icon = e.itemBtn:CreateTexture(nil, "ARTWORK")
    e.itemBtn.icon:SetAllPoints()
    e.itemBtn.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    e.itemBtn.cooldown = CreateFrame("Cooldown", btnName .. "CD", e.itemBtn, "CooldownFrameTemplate")
    e.itemBtn.cooldown:SetAllPoints()

    e.itemBtn:SetScript("OnEnter", function(self)
        self:SetAlpha(1)
        local entry = self._ownerEntry
        -- Item tooltip: HSSecureItemOverlay OnEnter shows GameTooltip once. Do not SetHyperlink here —
        -- duplicate Show() retriggers Insight fade-in (WQ / tracker item hover flicker).
        addon.AttachSecureItemOverlay(self, entry and entry.itemLink)
    end)
    e.itemBtn:SetScript("OnLeave", function(self)
        self:SetAlpha(1)
        if GameTooltip:GetOwner() == self then
            GameTooltip:Hide()
        end
        addon.DetachSecureItemOverlay(self)
    end)
    e.itemBtn:SetAlpha(1)

    e.itemBtn:SetScript("OnClick", function(self, button)
        local entry = self._ownerEntry
        if not entry or not entry.questID then return end
        local logIndex = C_QuestLog.GetLogIndexForQuestID(entry.questID)
        if not logIndex then return end
        if IsModifiedClick("CHATLINK") then
            local link = GetQuestLogSpecialItemInfo(logIndex)
            if not link then return end
            if addon.FocusInsertLinkIntoChat then
                addon.FocusInsertLinkIntoChat(link)
            elseif ChatFrameUtil and ChatFrameUtil.GetActiveWindow and ChatFrameUtil.GetActiveWindow() and ChatFrameUtil.InsertLink then
                ChatFrameUtil.InsertLink(link)
            end
        end
    end)

    e.itemBtn:Hide()

    local _S = addon.Scaled or function(v) return v end
    e.questTypeIcon = e:CreateTexture(nil, "ARTWORK")
    local _qs0 = _S(addon.GetEffectiveQuestIconSize and addon.GetEffectiveQuestIconSize() or addon.QUEST_TYPE_ICON_SIZE)
    e.questTypeIcon:SetSize(_qs0, _qs0)
    local iconRight = _S((addon.BAR_LEFT_OFFSET or 12) + 2)
    e.questTypeIcon:SetPoint("TOPRIGHT", e, "TOPLEFT", -iconRight, 0)
    e.questTypeIcon:Hide()

    -- Quest icon button: overlay for the configured icon-click action. Positioned in Layout.
    -- Use OnMouseDown (not OnClick) to avoid double-handling: OnClick fires on mouse-up and would toggle again.
    local iconSize = _S(addon.GetEffectiveQuestIconSize and addon.GetEffectiveQuestIconSize() or addon.QUEST_TYPE_ICON_SIZE)
    e.questIconBtn = CreateFrame("Button", nil, e)
    e.questIconBtn:SetSize(iconSize, iconSize)
    e.questIconBtn:SetPoint("TOPRIGHT", e, "TOPLEFT", -iconRight, 0)
    e.questIconBtn:SetFrameLevel(e:GetFrameLevel() + 5)
    e.questIconBtn:EnableMouse(true)
    e.questIconBtn._ownerEntry = e
    e.questIconBtn:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
        local entry = self._ownerEntry
        if not entry then return end
        local useIconFocus = addon.focus.UseFocusIconClickButton and addon.focus.UseFocusIconClickButton()
        if not useIconFocus then return end
        if addon.HandleFocusIconMouseDown then
            addon.HandleFocusIconMouseDown(entry)
        end
    end)
    e.questIconBtn:SetScript("OnEnter", function(self)
        local entry = self._ownerEntry
        if addon.GetDB("focusShowTooltipOnHover", false) and entry and entry.questID and addon.focus.UseBlizzardStyleQuestIconClicks and addon.focus.UseBlizzardStyleQuestIconClicks() then
            addon.focus.AnchorTooltip(GameTooltip, self)
            GameTooltip:AddLine(T("Focus quest") or "Focus quest", 1, 1, 1)
            GameTooltip:AddLine(T("Click to super-track this quest.") or "Click to super-track this quest.", 0.7, 0.7, 0.7, true)
            GameTooltip:Show()
        end
    end)
    e.questIconBtn:SetScript("OnLeave", function(self)
        if GameTooltip:GetOwner() == self then
            GameTooltip:Hide()
        end
    end)
    e.questIconBtn:Hide()

    -- Join Group (LFG) button: shown for group-type quests.
    -- Positioned on the RIGHT side of the entry in its own column so it never
    -- overlaps the supertrack bar or gets clipped by the scroll frame.
    local lfgBtnSize = _S(addon.LFG_BTN_SIZE or 26)
    e.lfgBtn = CreateFrame("Button", nil, e)
    e.lfgBtn:SetSize(lfgBtnSize, lfgBtnSize)
    -- Anchor is set dynamically by the renderer; default to top-right of entry.
    e.lfgBtn:SetPoint("TOPRIGHT", e, "TOPRIGHT", 0, 2)
    e.lfgBtn:RegisterForClicks("AnyDown")

    e.lfgBtn.icon = e.lfgBtn:CreateTexture(nil, "ARTWORK")
    e.lfgBtn.icon:SetAllPoints()
    -- Static group finder eye icon (the LFG eye frame from Blizzard's UI).
    e.lfgBtn.icon:SetAtlas("groupfinder-eye-frame")

    e.lfgBtn:SetScript("OnClick", function(self)
        local entry = self:GetParent()
        local questID = entry and entry.questID
        if not questID or questID <= 0 then return end
        -- Open the LFG tool and search for this quest
        if LFGListUtil_FindQuestGroup then
            pcall(LFGListUtil_FindQuestGroup, questID)
        elseif C_LFGList and C_LFGList.Search then
            -- Fallback: open premade groups panel and search for the quest
            if PVEFrame_ShowFrame then pcall(PVEFrame_ShowFrame, "GroupFinderFrame", "LFGListPVEStub") end
        end
    end)
    e.lfgBtn:SetScript("OnEnter", function(self)
        self:SetAlpha(1)
        self.icon:SetAlpha(1)
        if not addon.GetDB("focusShowTooltipOnHover", false) then return end
        addon.focus.AnchorTooltip(GameTooltip, self)
        GameTooltip:AddLine(T("Find a Group"), 1, 1, 1)
        GameTooltip:AddLine(T("Click to search for a group for this quest."), 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    e.lfgBtn:SetScript("OnLeave", function(self)
        self:SetAlpha(1)
        self.icon:SetAlpha(1)
        if GameTooltip:GetOwner() == self then
            GameTooltip:Hide()
        end
    end)
    e.lfgBtn:SetAlpha(1)
    e.lfgBtn.icon:SetAlpha(1)
    e.lfgBtn:Hide()

    -- Auctionator AH search button: shown on recipe entries when Auctionator is loaded.
    local ahBtnSize = _S(addon.AH_BTN_SIZE or 22)
    e.ahBtn = CreateFrame("Button", nil, e)
    e.ahBtn:SetSize(ahBtnSize, ahBtnSize)
    e.ahBtn:SetPoint("TOPRIGHT", e, "TOPRIGHT", 0, 2)
    e.ahBtn:RegisterForClicks("AnyDown")
    e.ahBtn._ownerEntry = e

    e.ahBtn.icon = e.ahBtn:CreateTexture(nil, "ARTWORK")
    e.ahBtn.icon:SetAllPoints()
    e.ahBtn.icon:SetAtlas("common-search-magnifyingglass")
    e.ahBtn:SetAlpha(1)
    e.ahBtn.icon:SetAlpha(1)

    e.ahBtn:SetScript("OnEnter", function(self)
        self:SetAlpha(1)
        self.icon:SetAlpha(1)
        if not addon.GetDB("focusShowTooltipOnHover", false) then return end
        local L = addon.L
        addon.focus.AnchorTooltip(GameTooltip, self)
        GameTooltip:AddLine((L and L["FOCUS_AH_SEARCH_TITLE"]) or "Search Auction House", 1, 1, 1)
        GameTooltip:AddLine((L and L["FOCUS_AH_SEARCH_TOOLTIP"]) or "Left-click: one craft with quality and tier when supported.\nRight-click: craft count and tier menu (1–5, or Any for no filters).\nThe Auction House must be open.", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    e.ahBtn:SetScript("OnLeave", function(self)
        self:SetAlpha(1)
        self.icon:SetAlpha(1)
        if GameTooltip:GetOwner() == self then GameTooltip:Hide() end
    end)
    e.ahBtn:SetScript("OnClick", function(self, button)
        local entry = self._ownerEntry
        if not entry or not entry._ahShoppingParts or #entry._ahShoppingParts == 0 then return end
        if button == "RightButton" then
            if addon.focus.ShowAuctionCraftDialog then
                addon.focus.ShowAuctionCraftDialog(entry)
            elseif StaticPopup_Show then
                StaticPopup_Show("HORIZONSUITE_AH_CRAFT_COUNT", nil, nil, { entry = entry })
            end
            return
        end
        if addon.RunAuctionatorRecipeSearchFromEntry then
            addon.RunAuctionatorRecipeSearchFromEntry(entry, 1)
        end
    end)
    e.ahBtn:Hide()

    -- Small icon for "tracked from other zone" (world quest on watch list but not on current map).
    local iconSz = addon.TRACKED_OTHER_ZONE_ICON_SIZE or 12
    e.trackedFromOtherZoneIcon = e:CreateTexture(nil, "ARTWORK")
    e.trackedFromOtherZoneIcon:SetSize(iconSz, iconSz)
    e.trackedFromOtherZoneIcon:SetPoint("TOPLEFT", e, "TOPLEFT", 0, 0)
    e.trackedFromOtherZoneIcon:Hide()

    e.titleShadow = e:CreateFontString(nil, "BORDER")
    e.titleShadow:SetFontObject(addon.TitleFont)
    e.titleShadow:SetTextColor(0, 0, 0, addon.SHADOW_A)
    e.titleShadow:SetJustifyH("LEFT")
    e.titleShadow:SetWordWrap(true)
    e.titleShadow:SetWidth(textW)

    e.titleText = e:CreateFontString(nil, "OVERLAY")
    e.titleText:SetFontObject(addon.TitleFont)
    e.titleText:SetTextColor(1, 1, 1, 1)
    e.titleText:SetJustifyH("LEFT")
    e.titleText:SetWordWrap(true)
    e.titleText:SetWidth(textW)
    -- Title indent: 1 "space" worth of padding from the left edge.
    -- Use a conservative pixel value; renderer will keep objectives aligned with this.
    local ONE_SPACE_PX = 0
    e.titleText:SetPoint("TOPLEFT", e, "TOPLEFT", ONE_SPACE_PX, 0)
    e.__baseTitlePadPx = ONE_SPACE_PX
    e.titleShadow:SetPoint("CENTER", e.titleText, "CENTER", addon.SHADOW_OX, addon.SHADOW_OY)

    e.zoneShadow = e:CreateFontString(nil, "BORDER")
    e.zoneShadow:SetFontObject(addon.ZoneFont)
    e.zoneShadow:SetTextColor(0, 0, 0, addon.SHADOW_A)
    e.zoneShadow:SetJustifyH("LEFT")

    e.zoneText = e:CreateFontString(nil, "OVERLAY")
    e.zoneText:SetFontObject(addon.ZoneFont)
    e.zoneText:SetTextColor(addon.ZONE_COLOR[1], addon.ZONE_COLOR[2], addon.ZONE_COLOR[3], 1)
    e.zoneText:SetJustifyH("LEFT")
    e.zoneShadow:SetPoint("CENTER", e.zoneText, "CENTER", addon.SHADOW_OX, addon.SHADOW_OY)
    e.zoneText:Hide()
    e.zoneShadow:Hide()

    e.affixNameSegs = {}
    for ai = 1, DELVE_AFFIX_MAX_NAMES do
        local nShadow = e:CreateFontString(nil, "BORDER")
        nShadow:SetFontObject(addon.ZoneFont)
        nShadow:SetTextColor(0, 0, 0, addon.SHADOW_A)
        nShadow:SetJustifyH("LEFT")
        local nText = e:CreateFontString(nil, "OVERLAY")
        nText:SetFontObject(addon.ZoneFont)
        nText:SetTextColor(0.78, 0.85, 0.88, 1)
        nText:SetJustifyH("LEFT")
        nShadow:SetPoint("CENTER", nText, "CENTER", addon.SHADOW_OX, addon.SHADOW_OY)
        nText:Hide()
        nShadow:Hide()
        e.affixNameSegs[ai] = { text = nText, shadow = nShadow }
    end
    e.affixText = e.affixNameSegs[1].text
    e.affixShadow = e.affixNameSegs[1].shadow

    e.affixSepSegs = {}
    for si = 1, DELVE_AFFIX_MAX_NAMES - 1 do
        local sShadow = e:CreateFontString(nil, "BORDER")
        sShadow:SetFontObject(addon.ZoneFont)
        sShadow:SetTextColor(0, 0, 0, addon.SHADOW_A)
        sShadow:SetJustifyH("LEFT")
        local sText = e:CreateFontString(nil, "OVERLAY")
        sText:SetFontObject(addon.ZoneFont)
        sText:SetTextColor(0.78, 0.85, 0.88, 1)
        sText:SetJustifyH("LEFT")
        sShadow:SetPoint("CENTER", sText, "CENTER", addon.SHADOW_OX, addon.SHADOW_OY)
        sText:Hide()
        sShadow:Hide()
        e.affixSepSegs[si] = { text = sText, shadow = sShadow }
    end

    e.objectives = {}
    for j = 1, addon.MAX_OBJECTIVES do
        local objShadow = e:CreateFontString(nil, "BORDER")
        objShadow:SetFontObject(addon.ObjFont)
        objShadow:SetTextColor(0, 0, 0, addon.SHADOW_A)
        objShadow:SetJustifyH("LEFT")
        objShadow:SetWordWrap(true)
        objShadow:SetWidth(textW - addon.OBJ_INDENT)

        local objText = e:CreateFontString(nil, "OVERLAY")
        objText:SetFontObject(addon.ObjFont)
        objText:SetTextColor(addon.OBJ_COLOR[1], addon.OBJ_COLOR[2], addon.OBJ_COLOR[3], 1)
        objText:SetJustifyH("LEFT")
        objText:SetWordWrap(true)
        objText:SetWidth(textW - addon.OBJ_INDENT)

        objShadow:SetPoint("CENTER", objText, "CENTER", addon.SHADOW_OX, addon.SHADOW_OY)

        local tickTex = e:CreateTexture(nil, "OVERLAY")
        tickTex:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
        tickTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        tickTex:Hide()

        local progBg = e:CreateTexture(nil, "BACKGROUND", nil, 2)
        progBg:SetHeight(4)
        progBg:SetColorTexture(0.15, 0.15, 0.18, 0.7)
        progBg:Hide()

        local progFill = e:CreateTexture(nil, "ARTWORK", nil, 2)
        progFill:SetHeight(4)
        progFill:SetColorTexture(0.40, 0.65, 0.90, 0.85)
        progFill:Hide()

        local progLabel = e:CreateFontString(nil, "OVERLAY")
        progLabel:SetFontObject(addon.ProgressBarFont or addon.ObjFont)
        progLabel:SetTextColor(0.9, 0.9, 0.9, 1)
        progLabel:SetJustifyH("CENTER")
        progLabel:Hide()

        -- Collapsible header button for recipe optional/finishing sections.
        local collapseBtn = CreateFrame("Button", nil, e)
        collapseBtn:EnableMouse(true)
        collapseBtn:RegisterForClicks("LeftButtonDown", "RightButtonDown")
        collapseBtn:SetFrameLevel(e:GetFrameLevel() + 10)
        collapseBtn:Hide()

        e.objectives[j] = { text = objText, shadow = objShadow, tick = tickTex, progressBarBg = progBg, progressBarFill = progFill, progressBarLabel = progLabel, collapseBtn = collapseBtn }
        objText:Hide()
        objShadow:Hide()
    end

    e.wqTimerText = e:CreateFontString(nil, "OVERLAY")
    e.wqTimerText:SetFontObject(addon.TimerFont)
    e.wqTimerText:SetTextColor(1, 1, 1, 1)
    e.wqTimerText:SetJustifyH("LEFT")
    e.wqTimerText:Hide()

    e.inlineTimerText = e:CreateFontString(nil, "OVERLAY")
    e.inlineTimerText:SetFontObject(addon.TimerFont)
    e.inlineTimerText:SetJustifyH("LEFT")
    e.inlineTimerText:SetWordWrap(true)
    e.inlineTimerText:SetNonSpaceWrap(true)
    e.inlineTimerText:Hide()

    -- Delve lives (hearts) on the title row; anchored from titleText in FocusEntryRenderer.
    e.delveLivesShadow = e:CreateFontString(nil, "BORDER")
    e.delveLivesShadow:SetFontObject(addon.TitleFont)
    e.delveLivesShadow:SetTextColor(0, 0, 0, addon.SHADOW_A)
    e.delveLivesShadow:SetJustifyH("LEFT")
    e.delveLivesShadow:SetNonSpaceWrap(true)
    e.delveLivesText = e:CreateFontString(nil, "OVERLAY")
    e.delveLivesText:SetFontObject(addon.TitleFont)
    e.delveLivesText:SetJustifyH("LEFT")
    e.delveLivesText:SetNonSpaceWrap(true)
    e.delveLivesShadow:SetPoint("CENTER", e.delveLivesText, "CENTER", addon.SHADOW_OX, addon.SHADOW_OY)
    e.delveLivesText:Hide()
    e.delveLivesShadow:Hide()

    e.titleCurrencyMeasure = e:CreateFontString(nil, "OVERLAY")
    e.titleCurrencyMeasure:SetFontObject(addon.TitleFont)
    e.titleCurrencyMeasure:Hide()
    e.titleCurrencyHitboxes = {}
    for i = 1, 4 do
        local hitbox = CreateFrame("Frame", nil, e)
        hitbox:SetFrameLevel(e:GetFrameLevel() + 8)
        hitbox:EnableMouse(true)
        hitbox:SetScript("OnEnter", function(self)
            if not GameTooltip then return end
            if addon.focus and addon.focus.AnchorTooltip then
                addon.focus.AnchorTooltip(GameTooltip, self)
            else
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            end
            GameTooltip:ClearLines()
            local title = self._tooltipTitle
            local body = self._tooltipBody
            if title and title ~= "" then
                GameTooltip:AddLine(title, 1, 1, 1)
            end
            if body and body ~= "" then
                GameTooltip:AddLine(body, 1, 0.82, 0, true)
            end
            GameTooltip:Show()
        end)
        hitbox:SetScript("OnLeave", function(self)
            if GameTooltip and GameTooltip:GetOwner() == self then
                GameTooltip:Hide()
            end
        end)
        hitbox:Hide()
        e.titleCurrencyHitboxes[i] = hitbox
    end

    -- Delve Nemesis groups / bonus chest (chest + count or check) on the title row; anchored from lives or title in FocusEntryRenderer.
    e.delveGroupsShadow = e:CreateFontString(nil, "BORDER")
    e.delveGroupsShadow:SetFontObject(addon.TitleFont)
    e.delveGroupsShadow:SetTextColor(0, 0, 0, addon.SHADOW_A)
    e.delveGroupsShadow:SetJustifyH("LEFT")
    e.delveGroupsShadow:SetNonSpaceWrap(true)
    e.delveGroupsText = e:CreateFontString(nil, "OVERLAY")
    e.delveGroupsText:SetFontObject(addon.TitleFont)
    e.delveGroupsText:SetJustifyH("LEFT")
    e.delveGroupsText:SetNonSpaceWrap(true)
    e.delveGroupsShadow:SetPoint("CENTER", e.delveGroupsText, "CENTER", addon.SHADOW_OX, addon.SHADOW_OY)
    e.delveGroupsText:Hide()
    e.delveGroupsShadow:Hide()

    e.wqProgressBg = e:CreateTexture(nil, "BACKGROUND")
    e.wqProgressBg:SetHeight(addon.WQ_TIMER_BAR_HEIGHT or 6)
    e.wqProgressBg:SetColorTexture(0.2, 0.2, 0.25, 0.8)
    e.wqProgressBg:Hide()

    e.wqProgressFill = e:CreateTexture(nil, "ARTWORK")
    e.wqProgressFill:SetHeight(addon.WQ_TIMER_BAR_HEIGHT or 6)
    e.wqProgressFill:SetColorTexture(0.45, 0.35, 0.65, 0.9)
    e.wqProgressFill:Hide()

    e.wqProgressText = e:CreateFontString(nil, "OVERLAY")
    e.wqProgressText:SetFontObject(addon.ObjFont)
    e.wqProgressText:SetTextColor(0.9, 0.9, 0.9, 1)
    e.wqProgressText:SetJustifyH("CENTER")
    e.wqProgressText:Hide()

    e.wqProgressLabel = e:CreateFontString(nil, "OVERLAY")
    e.wqProgressLabel:SetFontObject(addon.ObjFont)
    e.wqProgressLabel:SetTextColor(0.9, 0.9, 0.9, 1)
    e.wqProgressLabel:SetJustifyH("RIGHT")
    e.wqProgressLabel:Hide()

    -- Per-criteria scenario timer bars (KT-aligned; 1s tick driven). Same format as quest progress bars.
    local slots = addon.SCENARIO_TIMER_BAR_SLOTS or 5
    e.scenarioTimerBars = {}
    for si = 1, slots do
        local bar = CreateFrame("Frame", nil, e)
        bar:SetHeight(addon.WQ_TIMER_BAR_HEIGHT or 6)
        bar.Bg = bar:CreateTexture(nil, "BACKGROUND")
        bar.Bg:SetAllPoints()
        bar.Bg:SetColorTexture(0.15, 0.15, 0.18, 0.7)
        bar.Fill = bar:CreateTexture(nil, "ARTWORK")
        bar.Fill:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
        bar.Fill:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 0, 0)
        bar.Fill:SetColorTexture(0.40, 0.65, 0.90, 0.85)
        bar.Label = bar:CreateFontString(nil, "OVERLAY")
        bar.Label:SetFontObject(addon.ProgressBarFont or addon.ObjFont)
        bar.Label:SetPoint("CENTER", bar, "CENTER", 0, 0)
        bar.Label:SetJustifyH("CENTER")
        bar.duration = nil
        bar.startTime = nil
        bar._expiredAt = nil
        bar:Hide()
        e.scenarioTimerBars[si] = bar
    end

    e.flash = e:CreateTexture(nil, "OVERLAY")
    e.flash:SetAllPoints(e)
    e.flash:SetColorTexture(1, 1, 1, 0)

    e.animState      = "idle"
    e.animTime       = 0
    e.entryHeight    = 0
    e.questID        = nil
    e.flashTime      = 0
    e.finalX         = 0
    e.finalY         = 0
    e.staggerDelay   = 0
    e.collapseDelay  = 0
    e.groupKey       = nil

    e:SetAlpha(0)
    e:Hide()
    return e
end

local scrollChild = addon.scrollChild
for i = 1, addon.POOL_SIZE do
    pool[i] = CreateQuestEntry(scrollChild, i)
end

local function UpdateScenarioBar(bar, now, entry)
    local category = entry and entry.category
    local isSuperTracked = entry and entry.isSuperTracked
    local d, s = bar.duration, bar.startTime
    if not d or not s then return end
    local remaining = d - (now - s)
    -- Hold at 0 for 1s then trigger refresh and stop (KT-aligned).
    if remaining < 0 then
        if not bar._expiredAt then bar._expiredAt = now end
        if (now - bar._expiredAt) > 1 then
            bar.duration = nil
            bar.startTime = nil
            bar._expiredAt = nil
            if addon.ScheduleRefresh then addon.ScheduleRefresh() end
            return
        end
        remaining = 0
    else
        bar._expiredAt = nil
    end
    local pct = (d > 0) and (remaining / d) or 0
    local w = bar:GetWidth() or 1
    bar.Fill:SetWidth(math.max(2, w * pct))
    local labelText = addon.FormatTimeRemaining(remaining)
    bar.Label:SetText(labelText)
    -- Same format as quest progress bars: use progFillColor and progTextColor
    local colorCat = category or "SCENARIO"
    local progFillColor
    if addon.GetDB("progressBarUseCategoryColor", true) then
        progFillColor = (addon.GetQuestColor and addon.GetQuestColor(colorCat)) or (addon.QUEST_COLORS and addon.QUEST_COLORS[colorCat]) or { 0.55, 0.35, 0.85 }
    else
        progFillColor = addon.GetDB("progressBarFillColor", nil)
        if not progFillColor or type(progFillColor) ~= "table" then progFillColor = { 0.40, 0.65, 0.90 } end
    end
    local useTimerColor = addon.GetDB("timerColorByRemaining", true)
    local fr, fg, fb = progFillColor[1], progFillColor[2], progFillColor[3]
    local fa = progFillColor[4] or 0.85
    if entry and addon.ShouldApplySuperTrackQuestDim(entry) then
        local fc = addon.ApplyDimColor({ fr, fg, fb })
        fr, fg, fb = fc[1], fc[2], fc[3]
        fa = fa * addon.GetDimAlpha()
    end
    addon.ApplyProgressBarFillTexture(bar.Fill, fr, fg, fb, fa)
    local lr, lg, lb = addon.GetTimerTextColor(remaining, d, colorCat, useTimerColor)
    local labelR, labelG, labelB, labelA = addon.GetDimmedTrackerTextColor(lr, lg, lb, isSuperTracked, entry)
    bar.Label:SetTextColor(labelR, labelG, labelB, labelA)
end

function addon.UpdateScenarioTimerBars()
    if not addon.focus.enabled or not addon.pool then return end
    local now = GetTime()
    for i = 1, addon.POOL_SIZE do
        local entry = pool[i]
        if entry.scenarioTimerBars then
            for _, bar in ipairs(entry.scenarioTimerBars) do
                if bar.duration and bar.startTime then
                    UpdateScenarioBar(bar, now, entry)
                end
            end
        end
        if entry._inlineTimerBaseTitle and entry.inlineTimerText and entry._inlineTimerDuration and entry._inlineTimerStartTime then
            local remaining = entry._inlineTimerDuration - (now - entry._inlineTimerStartTime)
            if remaining <= 0 then
                entry.inlineTimerText:Hide()
                entry._inlineTimerBaseTitle, entry._inlineTimerStr, entry._inlineTimerDuration, entry._inlineTimerStartTime = nil, nil, nil, nil
                if addon.ScheduleRefresh then addon.ScheduleRefresh() end
            else
                local labelText = addon.FormatTimeRemaining(remaining)
                if labelText then
                    entry.inlineTimerText:SetText(" (" .. labelText .. ")")
                    local cat = entry.category or entry.groupKey or "DEFAULT"
                    local useTimerColor = addon.GetDB("timerColorByRemaining", true)
                    local r, g, b = addon.GetTimerTextColor(remaining, entry._inlineTimerDuration, cat, useTimerColor)
                    local tr, tg, tb, ta = addon.GetDimmedTrackerTextColor(r, g, b, entry.isSuperTracked, entry)
                    entry.inlineTimerText:SetTextColor(tr, tg, tb, ta)
                end
            end
        end
    end
end

local sectionPool = {}

local function CreateSectionHeader(parent)
    local s = CreateFrame("Button", nil, parent)
    local _S = addon.Scaled or function(v) return v end
    s:SetSize(addon.GetPanelWidth() - _S(addon.PADDING) * 2, addon.GetSectionHeaderHeight())

    s:RegisterForClicks("LeftButtonUp")

    s.shadow = s:CreateFontString(nil, "BORDER")
    s.shadow:SetFontObject(addon.SectionFont)
    s.shadow:SetTextColor(0, 0, 0, addon.SHADOW_A)
    s.shadow:SetJustifyH("LEFT")

    s.text = s:CreateFontString(nil, "OVERLAY")
    s.text:SetFontObject(addon.SectionFont)
    s.text:SetJustifyH("LEFT")
    -- Small chevron indicating expanded/collapsed state for this category.
    -- Keep it inside the header frame so it never renders outside the visible panel.
    s.chevron = s:CreateFontString(nil, "OVERLAY")
    s.chevron:SetFontObject(addon.SectionFont)
    s.chevron:SetJustifyH("LEFT")
    s.chevron:SetPoint("BOTTOMLEFT", s, "BOTTOMLEFT", 0, 0)
    s.chevron:SetText("")

    -- Category label starts two spaces to the right of the chevron.
    -- Use the TITLE font for measurement (per request), so it scales with user typography.
    local twoSpacesW = 8
    do
        local meas = s.__indentMeasure
        if not meas then
            meas = s:CreateFontString(nil, "ARTWORK")
            meas:Hide()
            s.__indentMeasure = meas
        end
        meas:SetFontObject(addon.TitleFont)
        meas:SetText(" ")
        local w = meas:GetStringWidth()
        if w and w > 0 then twoSpacesW = w end
    end
    local labelX = math.floor(twoSpacesW + 0.5)
    s.text:ClearAllPoints()
    s.text:SetPoint("BOTTOMLEFT", s, "BOTTOMLEFT", labelX, 0)
    s.shadow:SetPoint("CENTER", s.text, "CENTER", addon.SHADOW_OX, addon.SHADOW_OY)

    -- Full header clickable area (chevron is inside frame now).
    s:SetHitRectInsets(0, 0, 0, 0)

    s.active = false
    s:SetAlpha(0)
    s:Hide()
    return s
end

for i = 1, addon.SECTION_POOL_SIZE do
    sectionPool[i] = CreateSectionHeader(scrollChild)
end

local function UpdateFontObjectsFromDB()
    local fontPath   = addon.ResolveFontPath and addon.ResolveFontPath(addon.GetDB("fontPath", addon.GetDefaultFontPath())) or addon.GetDB("fontPath", addon.GetDefaultFontPath())
    local outline    = addon.GetDB("fontOutline", "OUTLINE")
    local fontOffset  = tonumber(addon.GetDB("globalFontSizeOffset", 0)) or 0
    local headerSz   = math.max(8, (tonumber(addon.GetDB("headerFontSize", 16)) or 16) + fontOffset)
    local titleSz    = math.max(8, (tonumber(addon.GetDB("titleFontSize", 13)) or 13) + fontOffset)
    local objSz      = math.max(8, (tonumber(addon.GetDB("objectiveFontSize", 11)) or 11) + fontOffset)
    local zoneSz     = math.max(8, (tonumber(addon.GetDB("zoneFontSize", 10)) or 10) + fontOffset)
    local sectionSz  = math.max(8, (tonumber(addon.GetDB("sectionFontSize", 10)) or 10) + fontOffset)

    local GLOBAL_SENTINEL = "__global__"
    local usePer = addon.GetDB("usePerElementFonts", false)
    local titleFontRaw   = addon.GetDB("titleFontPath", GLOBAL_SENTINEL)
    local zoneFontRaw    = addon.GetDB("zoneFontPath", GLOBAL_SENTINEL)
    local objFontRaw     = addon.GetDB("objectiveFontPath", GLOBAL_SENTINEL)
    local sectionFontRaw = addon.GetDB("sectionFontPath", GLOBAL_SENTINEL)
    local progBarFontRaw = addon.GetDB("progressBarFontPath", GLOBAL_SENTINEL)
    local timerFontRaw   = addon.GetDB("timerFontPath", GLOBAL_SENTINEL)
    local optionsFontRaw = addon.GetDB("optionsFontPath", GLOBAL_SENTINEL)

    local function ResolvePer(raw)
        if not usePer then return fontPath end
        if raw and raw ~= GLOBAL_SENTINEL then
            return addon.ResolveFontPath and addon.ResolveFontPath(raw) or raw
        end
        return fontPath
    end

    local titleFont   = ResolvePer(titleFontRaw)
    local zoneFont    = ResolvePer(zoneFontRaw)
    local objFont     = ResolvePer(objFontRaw)
    local sectionFont = ResolvePer(sectionFontRaw)
    local progBarFont = ResolvePer(progBarFontRaw)
    local timerFont   = ResolvePer(timerFontRaw)
    local optionsFont = ResolvePer(optionsFontRaw)
    local progBarSz   = math.max(7, (tonumber(addon.GetDB("progressBarFontSize", 10)) or 10) + fontOffset)
    local timerSz     = math.max(8, (tonumber(addon.GetDB("timerFontSize", 13)) or 13) + fontOffset)
    local optionsSz   = math.max(8, (tonumber(addon.GetDB("optionsFontSize", 11)) or 11) + fontOffset)

    addon.FONT_PATH = fontPath
    local S = addon.Scaled or function(v) return v end
    addon.HeaderFont:SetFont(fontPath, S(headerSz), outline)
    addon.TitleFont:SetFont(titleFont, S(titleSz), outline)
    addon.ObjFont:SetFont(objFont, S(objSz), outline)
    addon.ZoneFont:SetFont(zoneFont, S(zoneSz), outline)
    addon.SectionFont:SetFont(sectionFont, S(sectionSz), outline)
    if addon.ProgressBarFont then
        addon.ProgressBarFont:SetFont(progBarFont, S(progBarSz), outline)
    end
    if addon.TimerFont then
        addon.TimerFont:SetFont(timerFont, S(timerSz), outline)
    end
    if addon.OptionsFont then
        addon.OptionsFont:SetFont(optionsFont, S(optionsSz), outline)
    end
end

local function ApplyTypography()
    UpdateFontObjectsFromDB()

    local shadowOx = tonumber(addon.GetDB("shadowOffsetX", 2)) or 2
    local shadowOy = tonumber(addon.GetDB("shadowOffsetY", -2)) or -2
    local shadowA  = addon.GetDB("showTextShadow", true) and (tonumber(addon.GetDB("shadowAlpha", 0.8)) or 0.8) or 0

    -- Keep Config defaults in sync so FocusEntryRenderer, FocusSectionHeaders, and Utilities use DB values.
    addon.SHADOW_OX = shadowOx
    addon.SHADOW_OY = shadowOy
    addon.SHADOW_A = shadowA

    addon.headerShadow:SetTextColor(0, 0, 0, shadowA)
    addon.headerShadow:SetPoint("CENTER", addon.headerText, "CENTER", shadowOx, shadowOy)

    local headerC = addon.GetHeaderColor()
    addon.headerText:SetTextColor(headerC[1], headerC[2], headerC[3], 1)

    if addon.ApplyHeaderChromeColors then
        addon.ApplyHeaderChromeColors()
    end

    if addon.divider and addon.GetHeaderDividerColor then
        local dc = addon.GetHeaderDividerColor()
        addon.divider:SetColorTexture(dc[1], dc[2], dc[3], dc[4])
    end

    addon.countShadow:SetTextColor(0, 0, 0, shadowA)
    addon.countShadow:SetPoint("CENTER", addon.countText, "CENTER", shadowOx, shadowOy)

    if addon.optionsShadow and addon.optionsLabel then
        addon.optionsShadow:SetTextColor(0, 0, 0, shadowA)
        addon.optionsShadow:SetPoint("CENTER", addon.optionsLabel, "CENTER", shadowOx, shadowOy)
        addon.optionsShadow:SetText(addon.optionsLabel:GetText() or "")
    end

    for i = 1, addon.POOL_SIZE do
        local e = pool[i]
        e.titleShadow:SetTextColor(0, 0, 0, shadowA)
        e.titleShadow:SetPoint("CENTER", e.titleText, "CENTER", shadowOx, shadowOy)
        e.zoneShadow:SetTextColor(0, 0, 0, shadowA)
        e.zoneShadow:SetPoint("CENTER", e.zoneText, "CENTER", shadowOx, shadowOy)
        if e.affixNameSegs then
            for ai = 1, DELVE_AFFIX_MAX_NAMES do
                local seg = e.affixNameSegs[ai]
                seg.shadow:SetTextColor(0, 0, 0, shadowA)
                seg.shadow:SetPoint("CENTER", seg.text, "CENTER", shadowOx, shadowOy)
            end
        end
        if e.affixSepSegs then
            for si = 1, DELVE_AFFIX_MAX_NAMES - 1 do
                local seg = e.affixSepSegs[si]
                seg.shadow:SetTextColor(0, 0, 0, shadowA)
                seg.shadow:SetPoint("CENTER", seg.text, "CENTER", shadowOx, shadowOy)
            end
        end
        if e.delveLivesShadow and e.delveLivesText then
            e.delveLivesShadow:SetPoint("CENTER", e.delveLivesText, "CENTER", shadowOx, shadowOy)
        end
        if e.delveGroupsShadow and e.delveGroupsText then
            e.delveGroupsShadow:SetPoint("CENTER", e.delveGroupsText, "CENTER", shadowOx, shadowOy)
        end
        for j = 1, addon.MAX_OBJECTIVES do
            local obj = e.objectives[j]
            obj.shadow:SetTextColor(0, 0, 0, shadowA)
            obj.shadow:SetPoint("CENTER", obj.text, "CENTER", shadowOx, shadowOy)
        end
    end

    for i = 1, addon.SECTION_POOL_SIZE do
        local s = sectionPool[i]
        s.shadow:SetTextColor(0, 0, 0, shadowA)
        s.shadow:SetPoint("CENTER", s.text, "CENTER", shadowOx, shadowOy)
    end
end

local function ApplyDimensions(widthOverride)
    addon.focus.pendingDimensionsAfterCombat = false
    local S = addon.Scaled or function(v) return v end
    local w = (widthOverride and type(widthOverride) == "number") and widthOverride or addon.GetPanelWidth()
    addon.HS:SetSize(w, addon.HS:GetHeight() or S(addon.MIN_HEIGHT))
    addon.divider:SetSize(w - S(addon.PADDING) * 2, S(addon.DIVIDER_HEIGHT))
    local growUp = addon.GetDB("growUp", false)
    local headerMode = addon.GetDB("growUpHeaderMode", "always")
    local collapsed = addon.focus and addon.focus.collapsed
    local collapseState = addon.focus and addon.focus.collapse
    local pceg = collapseState and collapseState.panelCollapsedExpandedGroups
    local hasPanelCollapsedExpanded = collapsed and pceg and next(pceg) ~= nil
    local effectiveCollapsed = collapsed and not hasPanelCollapsedExpanded
    local dividerAtBottom = growUp and not addon.GetDB("hideObjectivesHeader", false)
        and (headerMode == "always" or (headerMode == "collapse" and (effectiveCollapsed
            or (addon.focus.layout and addon.focus.layout.allCategoriesCollapsed))))
    if dividerAtBottom then
        local pad = S(addon.PADDING)
        local headerH = pad + addon.GetHeaderHeight()
        addon.divider:SetPoint("BOTTOM", addon.HS, "BOTTOMLEFT", w / 2, pad + headerH)
    else
        addon.divider:SetPoint("TOP", addon.HS, "TOPLEFT", w / 2, -(S(addon.PADDING) + addon.GetHeaderHeight()))
    end
    addon.scrollChild:SetWidth(w)
    local leftOffset = addon.GetContentLeftOffset and addon.GetContentLeftOffset() or S(addon.PADDING + addon.ICON_COLUMN_WIDTH)
    for i = 1, addon.POOL_SIZE do
        local e = pool[i]
        local contentW = w - S(addon.PADDING) - leftOffset - S(addon.CONTENT_RIGHT_PADDING or 0)
        local textW = contentW
        e:SetSize(contentW, 20)
        e.titleShadow:SetWidth(textW)
        e.titleText:SetWidth(textW)
        if e.questTypeIcon then
            local qs = S(addon.GetEffectiveQuestIconSize and addon.GetEffectiveQuestIconSize() or addon.QUEST_TYPE_ICON_SIZE)
            e.questTypeIcon:SetSize(qs, qs)
        end
        if e.questIconBtn then
            local qs = S(addon.GetEffectiveQuestIconSize and addon.GetEffectiveQuestIconSize() or addon.QUEST_TYPE_ICON_SIZE)
            e.questIconBtn:SetSize(qs, qs)
        end
        for j = 1, addon.MAX_OBJECTIVES do
            local obj = e.objectives[j]
            local objIndent = addon.GetObjIndent and addon.GetObjIndent() or S(addon.OBJ_INDENT)
            obj.shadow:SetWidth(textW - objIndent)
            obj.text:SetWidth(textW - objIndent)
        end
    end
    for i = 1, addon.SECTION_POOL_SIZE do
        sectionPool[i]:SetSize(w - S(addon.PADDING) - leftOffset - S(addon.CONTENT_RIGHT_PADDING or 0), addon.GetSectionHeaderHeight())
    end
    if addon.UpdateMplusBlock then addon.UpdateMplusBlock() end
    if addon.divider and addon.divider.SetColorTexture and addon.GetHeaderDividerColor then
        local dc = addon.GetHeaderDividerColor()
        addon.divider:SetColorTexture(dc[1], dc[2], dc[3], dc[4])
    end
end

--- Return an entry to the pool; clears data and hides frame. Hide() is guarded during combat and deferred to PLAYER_REGEN_ENABLED.
--- @param entry table Pool entry frame
--- @param full boolean|nil If false, only clear data; if true/nil, also hide frame and children
--- @return nil
local function ClearEntry(entry, full)
    if not entry then return end
    entry.questID    = nil
    entry.entryKey   = nil
    entry.creatureID = nil
    entry.achievementID = nil
    entry.endeavorID = nil
    entry.decorID    = nil
    entry.appearanceID = nil
    entry.appearanceItemLink = nil
    entry.recipeID   = nil
    entry.recipeIsRecraft = nil
    entry.isRecipe   = nil
    entry.outputQuality = nil
    entry.affixData  = nil
    entry.tierSpellID = nil
    entry._affixBlockHeight = nil
    entry.itemLink   = nil
    if entry.itemBtn then entry.itemBtn._itemLink = nil end
    entry.vignetteGUID  = nil
    entry.vignetteID    = nil
    entry.vignetteMapID = nil
    entry.vignetteX     = nil
    entry.vignetteY     = nil
    entry.title         = nil
    entry.animState  = "idle"
    entry.groupKey   = nil
    entry.category   = nil
    entry.baseCategory = nil
    entry.isRare     = nil
    entry.isRareLoot = nil
    entry.isEventQuest = nil
    entry.isComplete = nil
    entry.isSuperTracked = nil
    if entry.questTypeIcon then addon.ApplyDimToTrackerIconTexture(entry.questTypeIcon, true) end
    if entry.itemBtn and entry.itemBtn.icon then
        addon.ApplyDimToTrackerIconTexture(entry.itemBtn.icon, true)
        entry.itemBtn:SetAlpha(1)
    end
    if entry.lfgBtn and entry.lfgBtn.icon then
        addon.ApplyDimToTrackerIconTexture(entry.lfgBtn.icon, true)
        entry.lfgBtn:SetAlpha(1)
    end
    if entry.ahBtn and entry.ahBtn.icon then
        addon.ApplyDimToTrackerIconTexture(entry.ahBtn.icon, true)
        entry.ahBtn:SetAlpha(1)
    end
    entry.isDungeonQuest = nil
    entry.isGroupQuest   = nil
    entry.isAutoComplete = nil
    entry._inlineTimerBaseTitle, entry._inlineTimerStr, entry._inlineTimerDuration, entry._inlineTimerStartTime = nil, nil, nil, nil
    -- Clear cached layout position so the next FullLayout re-applies SetPoint/SetWidth;
    -- without this an entry re-acquired into a different slot would keep stale _lastEntry*.
    entry._lastEntryX     = nil
    entry._lastEntryY     = nil
    entry._lastEntryWidth = nil
    -- Clear PopulateEntry's data signature so an entry re-acquired for a different quest
    -- re-populates from scratch instead of hitting the same-signature fast-path.
    entry._populateSig    = nil
    entry.hoverAnimState = nil
    entry.hoverAnimTime = nil
    entry._baseTitleColor = nil
    entry._hoverFromColor = nil
    entry._hoverToColor = nil
    entry._savedColor = nil
    if full ~= false then
        entry:SetAlpha(0)
        entry:SetHitRectInsets(0, 0, 0, 0)
        if entry.scenarioTimerBars then
            for _, bar in ipairs(entry.scenarioTimerBars) do
                bar.duration = nil
                bar.startTime = nil
                bar._expiredAt = nil
            end
        end
        entry:Hide()
        if entry.itemBtn then
            entry.itemBtn:Hide()
        end
        if entry.lfgBtn then entry.lfgBtn:Hide() end
        if entry.questIconBtn then entry.questIconBtn:Hide() end
        if entry.trackBar then entry.trackBar:Hide() end
        if entry.affixNameSegs then
            for ai = 1, DELVE_AFFIX_MAX_NAMES do
                local seg = entry.affixNameSegs[ai]
                seg.text:SetText("")
                seg.shadow:SetText("")
                seg.text:Hide()
                seg.shadow:Hide()
            end
        end
        if entry.affixSepSegs then
            for si = 1, DELVE_AFFIX_MAX_NAMES - 1 do
                local seg = entry.affixSepSegs[si]
                seg.text:SetText("")
                seg.shadow:SetText("")
                seg.text:Hide()
                seg.shadow:Hide()
            end
        end
        if entry.wqTimerText then entry.wqTimerText:Hide() end
        if entry.inlineTimerText then entry.inlineTimerText:Hide() end
        if entry.delveLivesText then entry.delveLivesText:Hide() end
        if entry.delveLivesShadow then entry.delveLivesShadow:Hide() end
        if entry.titleCurrencyHitboxes then
            for _, hitbox in ipairs(entry.titleCurrencyHitboxes) do
                hitbox:Hide()
                hitbox._tooltipTitle = nil
                hitbox._tooltipBody = nil
            end
        end
        if entry.delveGroupsText then entry.delveGroupsText:Hide() end
        if entry.delveGroupsShadow then entry.delveGroupsShadow:Hide() end
        if entry.wqProgressBg then entry.wqProgressBg:Hide() end
        if entry.wqProgressFill then entry.wqProgressFill:Hide() end
        if entry.wqProgressText then entry.wqProgressText:Hide() end
        if entry.wqProgressLabel then entry.wqProgressLabel:Hide() end
        if entry.scenarioTimerBars then
            for _, bar in ipairs(entry.scenarioTimerBars) do
                bar:Hide()
            end
        end
        if entry.objectives then
            for j = 1, addon.MAX_OBJECTIVES do
                local obj = entry.objectives[j]
                if obj then
                    obj._hsFinished = nil
                    obj._hsAlpha = nil
                    if obj.progressBarBg then obj.progressBarBg:Hide() end
                    if obj.progressBarFill then obj.progressBarFill:Hide() end
                    if obj.progressBarLabel then obj.progressBarLabel:Hide() end
                end
            end
        end
    end
end

addon.pool                   = pool
addon.activeMap             = activeMap
addon.sectionPool           = sectionPool
addon.ClearEntry            = ClearEntry
addon.ApplyTypography       = ApplyTypography
addon.UpdateFontObjectsFromDB = UpdateFontObjectsFromDB
addon.ApplyDimensions       = ApplyDimensions
