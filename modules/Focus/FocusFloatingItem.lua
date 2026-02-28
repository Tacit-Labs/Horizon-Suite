--[[
    Horizon Suite - Focus - Floating Quest Item
    Extra Action style button for quest item; keybindable. Source: super-tracked/first or current-zone first.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- ============================================================================
-- FLOATING QUEST ITEM BUTTON
-- ============================================================================

local floatingQuestItemBtn = CreateFrame("Button", "HSFloatingQuestItem", UIParent)
floatingQuestItemBtn:SetSize(addon.GetDB("floatingQuestItemSize", 36) or 36, addon.GetDB("floatingQuestItemSize", 36) or 36)
floatingQuestItemBtn:SetPoint("RIGHT", addon.HS, "LEFT", -12, 0)
floatingQuestItemBtn:RegisterForClicks("AnyDown", "AnyUp")
floatingQuestItemBtn:SetMovable(true)
floatingQuestItemBtn:RegisterForDrag("LeftButton")
floatingQuestItemBtn:SetScript("OnDragStart", function(self)
    if addon.GetDB("lockFloatingQuestItemPosition", false) then return end
    if InCombatLockdown() then return end
    self:StartMoving()
end)
floatingQuestItemBtn:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    self:SetUserPlaced(false)
    if InCombatLockdown() then return end
    addon.EnsureDB()
    local l, b = self:GetLeft(), self:GetBottom()
    if l and b then
        addon.SetDB("floatingQuestItemPoint", "BOTTOMLEFT")
        addon.SetDB("floatingQuestItemRelPoint", "BOTTOMLEFT")
        addon.SetDB("floatingQuestItemX", l)
        addon.SetDB("floatingQuestItemY", b)
        self:ClearAllPoints()
        self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", l, b)
    end
end)
floatingQuestItemBtn:Hide()
local INSET = 0
local floatingQuestItemIcon = floatingQuestItemBtn:CreateTexture(nil, "ARTWORK")
floatingQuestItemIcon:SetPoint("TOPLEFT", floatingQuestItemBtn, "TOPLEFT", INSET, -INSET)
floatingQuestItemIcon:SetPoint("BOTTOMRIGHT", floatingQuestItemBtn, "BOTTOMRIGHT", -INSET, INSET)
floatingQuestItemIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
floatingQuestItemBtn.icon = floatingQuestItemIcon
floatingQuestItemBtn.cooldown = CreateFrame("Cooldown", nil, floatingQuestItemBtn, "CooldownFrameTemplate")
floatingQuestItemBtn.cooldown:SetPoint("TOPLEFT", floatingQuestItemBtn, "TOPLEFT", INSET, -INSET)
floatingQuestItemBtn.cooldown:SetPoint("BOTTOMRIGHT", floatingQuestItemBtn, "BOTTOMRIGHT", -INSET, INSET)
floatingQuestItemBtn:SetScript("OnEnter", function(self)
    self:SetAlpha(1)
    if self._itemLink and GameTooltip then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        pcall(GameTooltip.SetHyperlink, GameTooltip, self._itemLink)
        GameTooltip:Show()
    end
    addon.AttachSecureItemOverlay(self, self._itemLink)
end)
floatingQuestItemBtn:SetScript("OnLeave", function(self)
    self:SetAlpha(0.9)
    if GameTooltip and GameTooltip:GetOwner() == self then GameTooltip:Hide() end
    addon.DetachSecureItemOverlay(self)
end)
floatingQuestItemBtn:SetScript("OnClick", function(self, button)
    local questID = self._questID
    if not questID then return end
    local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
    if not logIndex then return end
    if IsModifiedClick("CHATLINK") and ChatFrameUtil and ChatFrameUtil.GetActiveWindow and ChatFrameUtil.GetActiveWindow() then
        local link = GetQuestLogSpecialItemInfo(logIndex)
        if link and ChatFrameUtil.InsertLink then
            ChatFrameUtil.InsertLink(link)
        end
    end
end)
floatingQuestItemBtn:SetAlpha(0.9)

-- Keybind label: shows the bound key in the top-left corner of the button.
local keybindLabel = floatingQuestItemBtn:CreateFontString(nil, "OVERLAY")
keybindLabel:SetFontObject(NumberFontNormalSmallGray or NumberFontNormal or GameFontNormalSmall)
keybindLabel:SetPoint("TOPLEFT", floatingQuestItemBtn, "TOPLEFT", 2, -2)
keybindLabel:SetPoint("RIGHT", floatingQuestItemBtn, "RIGHT", -2, 0)
keybindLabel:SetJustifyH("LEFT")
keybindLabel:SetWordWrap(false)
keybindLabel:SetTextColor(1, 1, 1, 1)
keybindLabel:SetShadowOffset(1, -1)
keybindLabel:SetShadowColor(0, 0, 0, 1)
floatingQuestItemBtn.keybindLabel = keybindLabel

--- Refresh the keybind label text. Hides if no key is bound.
local function UpdateKeybindLabel()
    if not GetBindingKey then
        keybindLabel:Hide()
        return
    end
    local key = GetBindingKey("CLICK HSFloatingQuestItem:LeftButton")
    if key and key ~= "" then
        -- Shorten common modifier names for display
        local display = key
        display = display:gsub("CTRL%-", "C-")
        display = display:gsub("ALT%-", "A-")
        display = display:gsub("SHIFT%-", "S-")
        display = display:gsub("NUMPAD", "N")
        keybindLabel:SetText(display)
        keybindLabel:Show()
    else
        keybindLabel:SetText("")
        keybindLabel:Hide()
    end
end

-- Deferred style + initial keybind label update.
C_Timer.After(0, function()
    if floatingQuestItemBtn and not floatingQuestItemBtn:IsForbidden() then
        addon.ApplyBlizzardFloatingQuestItemStyle(floatingQuestItemBtn)
        UpdateKeybindLabel()
    end
end)

-- Listen for keybind changes so the label stays current.
local keybindWatcher = CreateFrame("Frame")
keybindWatcher:RegisterEvent("UPDATE_BINDINGS")
keybindWatcher:RegisterEvent("SPELL_UPDATE_COOLDOWN")
keybindWatcher:SetScript("OnEvent", function(_, event)
    if event == "UPDATE_BINDINGS" then
        UpdateKeybindLabel()
    elseif event == "SPELL_UPDATE_COOLDOWN" then
        -- Re-apply cooldown sweep so the timer text stays current during combat.
        if floatingQuestItemBtn:IsShown() and floatingQuestItemBtn._itemLink then
            addon.ApplyItemCooldown(floatingQuestItemBtn.cooldown, floatingQuestItemBtn._itemLink)
        end
    end
end)

local function UpdateFloatingQuestItem(questsFlat)
    if addon.ShouldHideInCombat() or not addon.GetDB("showFloatingQuestItem", false) or (addon.ShouldShowInInstance and not addon.ShouldShowInInstance()) then
        floatingQuestItemBtn:Hide()
        return
    end
    local superTracked = (C_SuperTrack and C_SuperTrack.GetSuperTrackedQuestID) and C_SuperTrack.GetSuperTrackedQuestID() or 0
    local mode = addon.GetDB("floatingQuestItemMode", "superTracked") or "superTracked"
    local playerZone = (addon.GetPlayerCurrentZoneName and addon.GetPlayerCurrentZoneName()) or nil

    local function inCurrentZone(q)
        return q.isNearby or (q.zoneName and playerZone and q.zoneName:lower() == playerZone:lower())
    end

    local chosenLink, chosenTex, chosenQuestID
    if mode == "currentZone" then
        -- Current zone mode: super-tracked in zone first, else first in-zone with item, else first with item
        local superTrackedInZoneLink, superTrackedInZoneTex, superTrackedInZoneQID
        local firstInZoneLink, firstInZoneTex, firstInZoneQID
        local firstAnyLink, firstAnyTex, firstAnyQID
        for _, q in ipairs(questsFlat or {}) do
            if q.questID and q.itemLink and q.itemTexture then
                local inZone = inCurrentZone(q)
                if q.questID == superTracked and inZone then
                    superTrackedInZoneLink, superTrackedInZoneTex, superTrackedInZoneQID = q.itemLink, q.itemTexture, q.questID
                end
                if not firstInZoneLink and inZone then
                    firstInZoneLink, firstInZoneTex, firstInZoneQID = q.itemLink, q.itemTexture, q.questID
                end
                if not firstAnyLink then
                    firstAnyLink, firstAnyTex, firstAnyQID = q.itemLink, q.itemTexture, q.questID
                end
            end
        end
        chosenLink = superTrackedInZoneLink or firstInZoneLink or firstAnyLink
        chosenTex = superTrackedInZoneTex or firstInZoneTex or firstAnyTex
        chosenQuestID = superTrackedInZoneQID or firstInZoneQID or firstAnyQID
    else
        -- Super-tracked mode: super-tracked first, else first with item
        for _, q in ipairs(questsFlat or {}) do
            if q.questID and q.itemLink and q.itemTexture then
                if q.questID == superTracked then
                    chosenLink, chosenTex, chosenQuestID = q.itemLink, q.itemTexture, q.questID
                    break
                end
                if not chosenLink then chosenLink, chosenTex, chosenQuestID = q.itemLink, q.itemTexture, q.questID end
            end
        end
    end
    if chosenLink and chosenTex then
        floatingQuestItemBtn.icon:SetTexture(chosenTex)
        floatingQuestItemBtn._itemLink = chosenLink
        floatingQuestItemBtn._questID = chosenQuestID
        addon.SetSecureItemOverlayItem(chosenLink)
        local sz = (addon.Scaled or function(v) return v end)(tonumber(addon.GetDB("floatingQuestItemSize", 36)) or 36)
        floatingQuestItemBtn:SetSize(sz, sz)
        local savedPoint = addon.GetDB("floatingQuestItemPoint", nil)
        floatingQuestItemBtn:ClearAllPoints()
        if savedPoint then
            local relPoint = addon.GetDB("floatingQuestItemRelPoint", "BOTTOMLEFT") or "BOTTOMLEFT"
            local sx = tonumber(addon.GetDB("floatingQuestItemX", 0)) or 0
            local sy = tonumber(addon.GetDB("floatingQuestItemY", 0)) or 0
            floatingQuestItemBtn:SetPoint(savedPoint, UIParent, relPoint, sx, sy)
        else
            local anchor = addon.GetDB("floatingQuestItemAnchor", "LEFT") or "LEFT"
            local ox = tonumber(addon.GetDB("floatingQuestItemOffsetX", -12)) or -12
            local oy = tonumber(addon.GetDB("floatingQuestItemOffsetY", 0)) or 0
            if anchor == "LEFT" then
                floatingQuestItemBtn:SetPoint("RIGHT", addon.HS, "LEFT", ox, oy)
            elseif anchor == "RIGHT" then
                floatingQuestItemBtn:SetPoint("LEFT", addon.HS, "RIGHT", ox, oy)
            elseif anchor == "TOP" then
                floatingQuestItemBtn:SetPoint("BOTTOM", addon.HS, "TOP", ox, oy)
            else
                floatingQuestItemBtn:SetPoint("TOP", addon.HS, "BOTTOM", ox, oy)
            end
        end
        if addon.focus.combat.fadeState == "in" then
            floatingQuestItemBtn:SetAlpha(0)
        elseif addon.focus.combat.faded and addon.GetCombatFadeAlpha then
            floatingQuestItemBtn:SetAlpha(addon.GetCombatFadeAlpha())
        end
        floatingQuestItemBtn:Show()
        UpdateKeybindLabel()
        addon.ApplyItemCooldown(floatingQuestItemBtn.cooldown, chosenLink)
    else
        floatingQuestItemBtn:Hide()
    end
end

addon.UpdateFloatingQuestItem = UpdateFloatingQuestItem
