--[[
    Horizon Suite - Focus - Auctionator craft / filter dialog
    Horizon-themed modal matching core/UrlCopyDialog.lua (link copy popup) chrome:
    WHITE8X8 backdrop, accent strip, ARIALN hints, Design QUEST_ITEM edit borders.
    Craft count plus optional crafting tier 1–5 (atlas dropdown). No tier selected → no item-quality
    or crafting-tier filters in the encoded shopping list (widest search). Left-click AH still uses
    quality + tier defaults.
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then _G.HorizonSuite = {} end
local addon = _G.HorizonSuite

local AH_CRAFT_W        = addon.Scaled(420)
local AH_CRAFT_PAD      = addon.Scaled(16)
local AH_CRAFT_ACCENT_H = addon.Scaled(3)
local AH_CRAFT_TITLE_H  = addon.Scaled(54)
local AH_CRAFT_RULE_COL = { 0.13, 0.13, 0.17, 1 }
local AH_CRAFT_BG_COL   = { 0.06, 0.06, 0.08, 0.97 }
local AH_CRAFT_EDGE_COL = { 0.2, 0.2, 0.26, 0.95 }
local AH_CRAFT_HINT_H   = addon.Scaled(14)
local AH_CRAFT_EDIT_H   = addon.Scaled(28)
local AH_CRAFT_BTN_H    = addon.Scaled(26)
local AH_CRAFT_BTN_W    = addon.Scaled(100)
local AH_CRAFT_F_HEAD = "Fonts\\FRIZQT__.TTF"
local AH_CRAFT_F_BODY = "Fonts\\ARIALN.TTF"

-- Crafting quality tiers (reagent / output); must match AUCTIONATOR_TIER_MAX in FocusEntryRenderer.lua.
local AH_TIER_MAX        = 5
local AH_TIER_MENU_ROW_H = addon.Scaled(26)
local AH_TIER_MENU_PAD   = addon.Scaled(4)
local AH_TIER_MENU_W     = addon.Scaled(236)
local AH_TIER_BTN_W      = addon.Scaled(220)

local ahCraftFrame

local function GetAccentRGB()
    local cc = addon.GetOptionsClassColor and addon.GetOptionsClassColor()
    if cc then return cc[1], cc[2], cc[3] end
    return 0.2, 0.8, 0.9
end

local function TierQualityAtlas(n)
    return "Professions-Icon-Quality-Tier" .. tostring(n) .. "-Small"
end

-- Prefer known atlases so Tier4/Tier5 missing in a patch does not break SetAtlas.
local function TierAtlasExists(atlasName)
    if C_Texture and C_Texture.GetAtlasInfo then
        return C_Texture.GetAtlasInfo(atlasName) ~= nil
    end
    return true
end

-- WoW dropdown arrows (ARIALN lacks many Unicode glyphs — use atlas or FRIZQT fallback).
local DROPDOWN_ARROW_ATLASES = {
    "common-dropdown-icon-arrow",
    "common-dropdown-a-button",
    "auctionhouse-icon-arrow-down",
    "voicechat-channellist-arrow-down",
}

-- Set tier atlas on icon and repoint label relative to whether the icon is visible.
local function ApplyTierIconAndLabel(icon, lbl, parent, tierVal, leftPad, rightPad)
    local atlas = TierQualityAtlas(tierVal)
    if TierAtlasExists(atlas) then
        icon:SetAtlas(atlas)
        icon:Show()
    else
        icon:Hide()
    end
    lbl:ClearAllPoints()
    if icon:IsShown() then
        lbl:SetPoint("LEFT", icon, "RIGHT", addon.Scaled(6), 0)
    else
        lbl:SetPoint("LEFT", parent, "LEFT", leftPad, 0)
    end
    lbl:SetPoint("RIGHT", parent, "RIGHT", rightPad, 0)
end

local function ApplyDropdownArrowTexture(tex)
    for _, a in ipairs(DROPDOWN_ARROW_ATLASES) do
        if TierAtlasExists(a) then
            tex:SetAtlas(a)
            return true
        end
    end
    return false
end

-- Design QUEST_ITEM bg + 1-px border chrome, shared by edit boxes and the tier button.
local function ApplyQuestItemSkin(frame, width, height)
    local Design = addon.Design
    local bg     = Design and Design.QUEST_ITEM_BG     or { 0.12, 0.12, 0.15, 0.95 }
    local border = Design and Design.QUEST_ITEM_BORDER or { 0.30, 0.32, 0.38, 0.6 }
    frame:SetSize(width, height)
    if frame._hsEbBg then frame._hsEbBg:Show() else
        local t = frame:CreateTexture(nil, "BACKGROUND")
        t:SetAllPoints()
        t:SetColorTexture(bg[1], bg[2], bg[3], bg[4] or 1)
        frame._hsEbBg = t
    end
    local function edge(tex, setPts)
        tex:SetColorTexture(border[1], border[2], border[3], border[4] or 1)
        setPts(tex)
    end
    if not frame._hsEbL then
        frame._hsEbL = frame:CreateTexture(nil, "BORDER")
        frame._hsEbR = frame:CreateTexture(nil, "BORDER")
        frame._hsEbT = frame:CreateTexture(nil, "BORDER")
        frame._hsEbB = frame:CreateTexture(nil, "BORDER")
    end
    edge(frame._hsEbL, function(t) t:SetWidth(1);  t:SetPoint("TOPLEFT",    0,  1); t:SetPoint("BOTTOMLEFT",  0, -1) end)
    edge(frame._hsEbR, function(t) t:SetWidth(1);  t:SetPoint("TOPRIGHT",   0,  1); t:SetPoint("BOTTOMRIGHT", 0, -1) end)
    edge(frame._hsEbT, function(t) t:SetHeight(1); t:SetPoint("TOPLEFT",    0,  0); t:SetPoint("TOPRIGHT",    0,  0) end)
    edge(frame._hsEbB, function(t) t:SetHeight(1); t:SetPoint("BOTTOMLEFT", 0,  0); t:SetPoint("BOTTOMRIGHT", 0,  0) end)
end

-- Edit box chrome: same as UrlCopyDialog (ApplyQuestItemSkin + font/input setup).
local function SkinEditLikeUrlCopy(eb, width, height)
    ApplyQuestItemSkin(eb, width, height)
    eb:SetFont(AH_CRAFT_F_BODY, 11, "")
    eb:SetAutoFocus(false)
    eb:SetTextInsets(addon.Scaled(8), addon.Scaled(8), 0, 0)
    eb:SetTextColor(0.9, 0.9, 0.92, 1)
end

local function MakeHintLabel(parent, anchorTo, anchorFrom, offsetX, offsetY)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetFont(AH_CRAFT_F_BODY, 10, "")
    fs:SetJustifyH("LEFT")
    fs:SetWordWrap(true)
    fs:SetTextColor(0.42, 0.42, 0.50, 1)
    fs:SetPoint("TOPLEFT", anchorTo, anchorFrom, offsetX, offsetY)
    fs:SetPoint("RIGHT", parent, "RIGHT", -AH_CRAFT_PAD, 0)
    return fs
end

local function MakeChromeButton(parent, label, anchorFrame, relPoint, x, y, onClick)
    local ar, ag, ab = GetAccentRGB()
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(AH_CRAFT_BTN_W, AH_CRAFT_BTN_H)
    btn:SetPoint(relPoint, anchorFrame, relPoint, x, y)
    local btnBg = btn:CreateTexture(nil, "BACKGROUND")
    btnBg:SetAllPoints()
    btnBg:SetColorTexture(AH_CRAFT_EDGE_COL[1], AH_CRAFT_EDGE_COL[2], AH_CRAFT_EDGE_COL[3], 0.6)
    local btnLabel = btn:CreateFontString(nil, "OVERLAY")
    btnLabel:SetFont(AH_CRAFT_F_HEAD, 10, "")
    btnLabel:SetPoint("CENTER")
    btnLabel:SetText(label)
    btnLabel:SetTextColor(0.9, 0.9, 0.92, 1)
    btn:SetScript("OnClick", onClick)
    btn:SetScript("OnEnter", function()
        btnBg:SetColorTexture(ar * 0.5, ag * 0.5, ab * 0.5, 0.55)
    end)
    btn:SetScript("OnLeave", function()
        btnBg:SetColorTexture(AH_CRAFT_EDGE_COL[1], AH_CRAFT_EDGE_COL[2], AH_CRAFT_EDGE_COL[3], 0.6)
    end)
    -- Plain Button can still get default skin textures on some clients; keep a single flat chrome.
    if btn.SetNormalTexture then pcall(function() btn:SetNormalTexture(nil) end) end
    if btn.SetPushedTexture then pcall(function() btn:SetPushedTexture(nil) end) end
    if btn.SetHighlightTexture then pcall(function() btn:SetHighlightTexture(nil) end) end
    if btn.SetDisabledTexture then pcall(function() btn:SetDisabledTexture(nil) end) end
    return btn
end

local function EnsureAhCraftFrame()
    if ahCraftFrame then return ahCraftFrame end

    local bodyTop = AH_CRAFT_TITLE_H + AH_CRAFT_PAD
    -- hint + edit + gap + hint + tier button + gap + buttons
    local bodyH = (AH_CRAFT_HINT_H + addon.Scaled(4) + AH_CRAFT_EDIT_H + addon.Scaled(10))
        + (AH_CRAFT_HINT_H + addon.Scaled(4) + AH_CRAFT_EDIT_H + addon.Scaled(16))
        + AH_CRAFT_PAD + AH_CRAFT_BTN_H + AH_CRAFT_PAD
    local fH = bodyTop + bodyH

    local f = CreateFrame("Frame", "HorizonSuiteFocusAuctionCraftDlg", UIParent, "BackdropTemplate")
    f:SetSize(AH_CRAFT_W, fH)
    f:SetPoint("CENTER", 0, addon.Scaled(30))
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    f:Hide()
    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    f:SetBackdropColor(unpack(AH_CRAFT_BG_COL))
    f:SetBackdropBorderColor(unpack(AH_CRAFT_EDGE_COL))
    -- Stacking for tier menu: catcher below this frame (outside clicks only); popup above.
    f:SetFrameLevel(100)
    if UISpecialFrames then
        tinsert(UISpecialFrames, "HorizonSuiteFocusAuctionCraftDlg")
    end

    f.selectedCraftingTier = nil

    local ar, ag, ab = GetAccentRGB()
    local accentStrip = f:CreateTexture(nil, "OVERLAY")
    accentStrip:SetHeight(AH_CRAFT_ACCENT_H)
    accentStrip:SetPoint("TOPLEFT", 1, -1)
    accentStrip:SetPoint("TOPRIGHT", -1, -1)
    accentStrip:SetColorTexture(ar, ag, ab, 1)
    f.accentStrip = accentStrip

    local dragZone = CreateFrame("Frame", nil, f)
    dragZone:SetPoint("TOPLEFT")
    dragZone:SetPoint("TOPRIGHT")
    dragZone:SetHeight(AH_CRAFT_TITLE_H)
    dragZone:EnableMouse(true)
    dragZone:RegisterForDrag("LeftButton")
    dragZone:SetScript("OnDragStart", function()
        if not InCombatLockdown() then f:StartMoving() end
    end)
    dragZone:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)

    local suiteLbl = dragZone:CreateFontString(nil, "OVERLAY")
    suiteLbl:SetFont(AH_CRAFT_F_HEAD, 13, "OUTLINE")
    suiteLbl:SetPoint("TOPLEFT", dragZone, "TOPLEFT", AH_CRAFT_PAD, -(AH_CRAFT_ACCENT_H + addon.Scaled(10)))
    suiteLbl:SetText("HORIZON SUITE")
    suiteLbl:SetTextColor(0.88, 0.88, 0.92, 1)

    local subtitleLbl = dragZone:CreateFontString(nil, "OVERLAY")
    subtitleLbl:SetFont(AH_CRAFT_F_BODY, 10, "")
    subtitleLbl:SetPoint("TOPLEFT", suiteLbl, "BOTTOMLEFT", 0, -addon.Scaled(3))
    subtitleLbl:SetTextColor(ar, ag, ab, 1)
    f.subtitleLbl = subtitleLbl

    local closeBtn = CreateFrame("Button", nil, dragZone)
    closeBtn:SetSize(addon.Scaled(28), addon.Scaled(28))
    closeBtn:SetPoint("TOPRIGHT", dragZone, "TOPRIGHT", -addon.Scaled(4), -(AH_CRAFT_ACCENT_H + addon.Scaled(8)))
    local closeBg = closeBtn:CreateTexture(nil, "BACKGROUND")
    closeBg:SetAllPoints()
    closeBg:SetColorTexture(1, 0.3, 0.3, 0)
    local closeX = closeBtn:CreateFontString(nil, "OVERLAY")
    closeX:SetFont(AH_CRAFT_F_HEAD, 13, "OUTLINE")
    closeX:SetPoint("CENTER")
    closeX:SetText("\195\151")
    closeX:SetTextColor(0.36, 0.36, 0.42, 1)
    closeBtn:SetScript("OnEnter", function()
        closeX:SetTextColor(1, 1, 1, 1)
        closeBg:SetColorTexture(1, 0.3, 0.3, 0.2)
    end)
    closeBtn:SetScript("OnLeave", function()
        closeX:SetTextColor(0.36, 0.36, 0.42, 1)
        closeBg:SetColorTexture(1, 0.3, 0.3, 0)
    end)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    local topRule = f:CreateTexture(nil, "ARTWORK")
    topRule:SetHeight(1)
    topRule:SetPoint("TOPLEFT", AH_CRAFT_PAD, -AH_CRAFT_TITLE_H)
    topRule:SetPoint("TOPRIGHT", -AH_CRAFT_PAD, -AH_CRAFT_TITLE_H)
    topRule:SetColorTexture(unpack(AH_CRAFT_RULE_COL))

    local hintCraft = MakeHintLabel(f, f, "TOPLEFT", AH_CRAFT_PAD, -bodyTop)
    f.hintCraft = hintCraft

    local ebCraft = CreateFrame("EditBox", nil, f)
    SkinEditLikeUrlCopy(ebCraft, addon.Scaled(120), AH_CRAFT_EDIT_H)
    ebCraft:SetPoint("TOPLEFT", hintCraft, "BOTTOMLEFT", 0, -addon.Scaled(4))
    ebCraft:SetNumeric(true)
    ebCraft:SetMaxLetters(4)
    ebCraft:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    f.ebCraft = ebCraft

    local hintTier = MakeHintLabel(f, ebCraft, "BOTTOMLEFT", 0, -addon.Scaled(10))
    f.hintTier = hintTier

    local tierBtn = CreateFrame("Button", nil, f)
    ApplyQuestItemSkin(tierBtn, AH_TIER_BTN_W, AH_CRAFT_EDIT_H)
    tierBtn:SetPoint("TOPLEFT", hintTier, "BOTTOMLEFT", 0, -addon.Scaled(4))
    tierBtn:RegisterForClicks("LeftButtonUp")
    tierBtn.icon = tierBtn:CreateTexture(nil, "ARTWORK")
    tierBtn.icon:SetSize(addon.Scaled(20), addon.Scaled(20))
    tierBtn.icon:SetPoint("LEFT", addon.Scaled(8), 0)
    tierBtn.label = tierBtn:CreateFontString(nil, "OVERLAY")
    tierBtn.label:SetFont(AH_CRAFT_F_BODY, 11, "")
    tierBtn.label:SetJustifyH("LEFT")
    tierBtn.label:SetPoint("LEFT", tierBtn.icon, "RIGHT", addon.Scaled(6), 0)
    tierBtn.label:SetPoint("RIGHT", tierBtn, "RIGHT", -addon.Scaled(26), 0)
    tierBtn.label:SetTextColor(0.9, 0.9, 0.92, 1)
    tierBtn.chevTex = tierBtn:CreateTexture(nil, "OVERLAY")
    tierBtn.chevTex:SetSize(addon.Scaled(14), addon.Scaled(14))
    tierBtn.chevTex:SetPoint("RIGHT", -addon.Scaled(6), 0)
    if not ApplyDropdownArrowTexture(tierBtn.chevTex) then
        tierBtn.chevTex:Hide()
        tierBtn.chev = tierBtn:CreateFontString(nil, "OVERLAY")
        tierBtn.chev:SetFont(AH_CRAFT_F_HEAD, 11, "")
        tierBtn.chev:SetPoint("RIGHT", -addon.Scaled(8), 0)
        tierBtn.chev:SetText("v")
        tierBtn.chev:SetTextColor(0.55, 0.55, 0.62, 1)
    end
    f.tierBtn = tierBtn

    local tierCatcher = CreateFrame("Button", nil, UIParent)
    tierCatcher:SetFrameStrata("DIALOG")
    tierCatcher:SetFrameLevel(90)
    tierCatcher:SetAllPoints()
    tierCatcher:EnableMouse(true)
    tierCatcher:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    tierCatcher:Hide()
    f.tierCatcher = tierCatcher

    local numMenuRows = AH_TIER_MAX + 1
    local menuInnerH = numMenuRows * AH_TIER_MENU_ROW_H + AH_TIER_MENU_PAD * 2
    -- Child of dialog so list stacks above SetToplevel dialog (UIParent sibling at fixed level drew behind).
    local tierPopup = CreateFrame("Frame", nil, f, "BackdropTemplate")
    tierPopup:SetSize(AH_TIER_MENU_W, menuInnerH)
    tierPopup:SetFrameLevel(500)
    tierPopup:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    tierPopup:SetBackdropColor(unpack(AH_CRAFT_BG_COL))
    tierPopup:SetBackdropBorderColor(unpack(AH_CRAFT_EDGE_COL))
    tierPopup:Hide()
    f.tierPopup = tierPopup

    -- Popup Frame has no SetFocus; use a hidden EditBox so ESC closes the tier list.
    local function CloseTierMenu()
        if f.tierPopup then f.tierPopup:Hide() end
        if f.tierCatcher then f.tierCatcher:Hide() end
        if f.tierEscSink then f.tierEscSink:ClearFocus() end
    end
    f.CloseTierMenu = CloseTierMenu

    local tierEscSink = CreateFrame("EditBox", nil, f)
    tierEscSink:SetSize(1, 1)
    tierEscSink:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -2)
    tierEscSink:SetAlpha(0)
    tierEscSink:EnableMouse(false)
    tierEscSink:SetAutoFocus(false)
    tierEscSink:SetText("")
    tierEscSink:SetScript("OnChar", function(self)
        self:SetText("")
    end)
    tierEscSink:SetScript("OnEscapePressed", function()
        if f.tierPopup and f.tierPopup:IsShown() then
            CloseTierMenu()
        end
        if f.ebCraft then f.ebCraft:SetFocus() end
    end)
    f.tierEscSink = tierEscSink

    tierCatcher:SetScript("OnClick", function()
        CloseTierMenu()
        if f.ebCraft then f.ebCraft:SetFocus() end
    end)

    local function tierRowLabel(L, tierVal)
        if tierVal == nil then
            return (L and L["FOCUS_AH_CRAFT_TIER_ANY"]) or "Any tier"
        end
        local pat = L and L["FOCUS_AH_CRAFT_TIER_N"]
        if pat and type(pat) == "string" then
            local ok, s = pcall(string.format, pat, tierVal)
            if ok and s then return s end
        end
        return "Tier " .. tostring(tierVal)
    end

    local function refreshTierButtonDisplay()
        local L = addon.L
        local t = f.selectedCraftingTier
        if type(t) ~= "number" or t < 1 or t > AH_TIER_MAX then
            f.tierBtn.icon:Hide()
            f.tierBtn.label:ClearAllPoints()
            f.tierBtn.label:SetPoint("LEFT", f.tierBtn, "LEFT", addon.Scaled(12), 0)
            f.tierBtn.label:SetPoint("RIGHT", f.tierBtn, "RIGHT", -addon.Scaled(28), 0)
            f.tierBtn.label:SetText(tierRowLabel(L, nil))
            return
        end
        ApplyTierIconAndLabel(f.tierBtn.icon, f.tierBtn.label, f.tierBtn, t, addon.Scaled(12), -addon.Scaled(28))
        f.tierBtn.label:SetText(tierRowLabel(L, t))
    end
    f.RefreshTierButtonDisplay = refreshTierButtonDisplay

    f.tierMenuRows = {}
    for idx = 0, AH_TIER_MAX do
        local tierVal = (idx == 0) and nil or idx
        local row = CreateFrame("Button", nil, tierPopup)
        row:SetSize(AH_TIER_MENU_W - AH_TIER_MENU_PAD * 2, AH_TIER_MENU_ROW_H)
        row:SetPoint("TOPLEFT", AH_TIER_MENU_PAD, -AH_TIER_MENU_PAD - idx * AH_TIER_MENU_ROW_H)
        row:RegisterForClicks("LeftButtonUp")
        local hi = row:CreateTexture(nil, "BACKGROUND")
        hi:SetAllPoints()
        hi:SetColorTexture(1, 1, 1, 0.06)
        hi:Hide()
        row:SetScript("OnEnter", function() hi:Show() end)
        row:SetScript("OnLeave", function() hi:Hide() end)
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(addon.Scaled(20), addon.Scaled(20))
        row.icon:SetPoint("LEFT", addon.Scaled(6), 0)
        row.lbl = row:CreateFontString(nil, "OVERLAY")
        row.lbl:SetFont(AH_CRAFT_F_BODY, 11, "")
        row.lbl:SetJustifyH("LEFT")
        row.lbl:SetPoint("LEFT", row.icon, "RIGHT", addon.Scaled(6), 0)
        row.lbl:SetPoint("RIGHT", row, "RIGHT", -addon.Scaled(8), 0)
        row.lbl:SetTextColor(0.9, 0.9, 0.92, 1)
        row:SetScript("OnClick", function()
            f.selectedCraftingTier = tierVal
            refreshTierButtonDisplay()
            CloseTierMenu()
            if f.ebCraft then f.ebCraft:SetFocus() end
        end)
        f.tierMenuRows[idx + 1] = row
    end

    local function syncTierMenuLabels()
        local L = addon.L
        for idx = 0, AH_TIER_MAX do
            local row = f.tierMenuRows[idx + 1]
            if row then
                local tierVal = (idx == 0) and nil or idx
                if tierVal == nil then
                    row.icon:Hide()
                    row.lbl:ClearAllPoints()
                    row.lbl:SetPoint("LEFT", row, "LEFT", addon.Scaled(10), 0)
                    row.lbl:SetPoint("RIGHT", row, "RIGHT", -addon.Scaled(8), 0)
                else
                    ApplyTierIconAndLabel(row.icon, row.lbl, row, tierVal, addon.Scaled(10), -addon.Scaled(8))
                end
                row.lbl:SetText(tierRowLabel(L, tierVal))
            end
        end
    end
    f.SyncTierMenuLabels = syncTierMenuLabels

    tierBtn:SetScript("OnClick", function()
        if f.tierPopup:IsShown() then
            CloseTierMenu()
            if f.ebCraft then f.ebCraft:SetFocus() end
            return
        end
        syncTierMenuLabels()
        f.tierPopup:ClearAllPoints()
        f.tierPopup:SetPoint("TOPLEFT", tierBtn, "BOTTOMLEFT", 0, -addon.Scaled(2))
        f.tierPopup:Raise()
        -- Catcher below dialog frame so in-dialog clicks hit the window; outside hits catcher.
        f.tierCatcher:SetFrameStrata(f:GetFrameStrata())
        f.tierCatcher:SetFrameLevel(math.max(1, f:GetFrameLevel() - 1))
        f.tierCatcher:Show()
        f.tierPopup:Show()
        if f.tierEscSink then f.tierEscSink:SetFocus() end
    end)

    local function DoAccept()
        local entry = f._entry
        if not entry then return end
        CloseTierMenu()
        local L = addon.L
        local text = f.ebCraft:GetText() or ""
        local n = tonumber(text)
        local maxN = addon.AH_AUCTIONATOR_CRAFT_COUNT_MAX or 999
        if not n or n < 1 or n > maxN or n ~= math.floor(n) then
            if addon.HSPrint then
                addon.HSPrint((L and L["FOCUS_AH_CRAFT_COUNT_INVALID"]) or ("Enter a whole number from 1 to " .. tostring(maxN) .. "."))
            end
            return
        end
        local forceTier = f.selectedCraftingTier
        if type(forceTier) == "number" and (forceTier < 1 or forceTier > AH_TIER_MAX) then
            forceTier = nil
        end
        if addon.RunAuctionatorRecipeSearchFromEntry then
            addon.RunAuctionatorRecipeSearchFromEntry(entry, n, {
                useItemQuality = false,
                useCraftingTier = forceTier ~= nil,
                forceCraftingTier = forceTier,
            })
        end
        f:Hide()
    end

    f.btnOk = MakeChromeButton(f, _G.OKAY or "OK", f, "BOTTOMRIGHT", -AH_CRAFT_PAD, AH_CRAFT_PAD, DoAccept)
    f.btnCancel = MakeChromeButton(f, _G.CANCEL or "Cancel", f, "BOTTOMRIGHT", -AH_CRAFT_PAD, AH_CRAFT_PAD, function()
        CloseTierMenu()
        f:Hide()
    end)
    f.btnCancel:ClearAllPoints()
    f.btnCancel:SetPoint("BOTTOMRIGHT", f.btnOk, "BOTTOMLEFT", -addon.Scaled(14), 0)

    ebCraft:SetScript("OnEnterPressed", function() DoAccept() end)

    f:SetScript("OnHide", function()
        CloseTierMenu()
    end)

    ahCraftFrame = f
    return f
end

--- Open the Horizon-styled Auctionator craft / filter dialog (UrlCopy-style chrome).
--- @param entry table Pool entry with _ahShoppingParts
--- @return nil
function addon.focus.ShowAuctionCraftDialog(entry)
    if not entry then return end
    local f = EnsureAhCraftFrame()
    local L = addon.L
    local ar, ag, ab = GetAccentRGB()
    if f.accentStrip then f.accentStrip:SetColorTexture(ar, ag, ab, 1) end
    if f.subtitleLbl then
        f.subtitleLbl:SetText((L and L["FOCUS_AH_CRAFT_DIALOG_SUBTITLE"]) or "Auction House shopping list")
        f.subtitleLbl:SetTextColor(ar, ag, ab, 1)
    end
    f.hintCraft:SetText((L and L["FOCUS_AH_CRAFT_HINT_CRAFT_COUNT"])
        or "How many crafts to buy materials for (1–999). Quantities in the list are multiplied by this.")
    f.hintTier:SetText((L and L["FOCUS_AH_CRAFT_HINT_TIER"])
        or "Optional crafting tier on every row. Leave as Any for no quality or tier filters.")

    f.SyncTierMenuLabels()

    f._entry = entry
    f.ebCraft:SetText("1")
    f.selectedCraftingTier = nil
    f.RefreshTierButtonDisplay()
    f.CloseTierMenu()
    f:Show()
    C_Timer.After(0, function()
        if f:IsShown() and f.ebCraft then
            f.ebCraft:SetFocus()
            f.ebCraft:HighlightText()
        end
    end)
end

--- Refresh accent strip / subtitle when dashboard class colour changes (dialog visible).
--- @return nil
function addon.focus.ApplyAuctionCraftDialogAccent()
    if not ahCraftFrame or not ahCraftFrame:IsShown() then return end
    local ar, ag, ab = GetAccentRGB()
    if ahCraftFrame.accentStrip then
        ahCraftFrame.accentStrip:SetColorTexture(ar, ag, ab, 1)
    end
    if ahCraftFrame.subtitleLbl then
        ahCraftFrame.subtitleLbl:SetTextColor(ar, ag, ab, 1)
    end
end
