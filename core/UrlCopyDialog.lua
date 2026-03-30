--[[
    Horizon Suite — URL Copy Dialog
    Horizon-themed modal dialog for displaying a copyable URL. Accent colour uses
    Axis option "Class colours - Dashboard" (GetOptionsClassColor) when enabled, else default cyan.
    Extracted from Core.lua.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

-- ==========================================================================
-- URL COPY BOX (Horizon-themed)
-- ==========================================================================

local urlCopyFrame
-- Match core/PatchNotes.lua chrome (What's New) for a consistent dialog.
local URL_COPY_W = 440
local URL_COPY_PAD = 16
local URL_COPY_ACCENT_H = 3
local URL_COPY_TITLE_H = 54
local URL_COPY_RULE_COL = { 0.13, 0.13, 0.17, 1 }
local URL_COPY_BG_COL = { 0.06, 0.06, 0.08, 0.97 }
local URL_COPY_EDGE_COL = { 0.2, 0.2, 0.26, 0.95 }
local URL_COPY_HINT_H = 14
local URL_COPY_EDIT_H = 28
local URL_COPY_BTN_H = 24
local URL_COPY_F_HEAD = "Fonts\\FRIZQT__.TTF"
local URL_COPY_F_BODY = "Fonts\\ARIALN.TTF"

local function GetURLCopyAccentRGB()
    local cc = addon.GetOptionsClassColor and addon.GetOptionsClassColor()
    if cc then return cc[1], cc[2], cc[3] end
    return 0.2, 0.8, 0.9
end

local function BuildURLCopyFrame()
    if urlCopyFrame then return urlCopyFrame end
    local Design = addon.Design
    local ebBg = Design and Design.QUEST_ITEM_BG or { 0.12, 0.12, 0.15, 0.95 }
    local ebBorder = Design and Design.QUEST_ITEM_BORDER or { 0.30, 0.32, 0.38, 0.6 }

    local bodyTop = URL_COPY_TITLE_H + URL_COPY_PAD
    local fH = bodyTop + URL_COPY_HINT_H + 4 + URL_COPY_EDIT_H + URL_COPY_PAD + URL_COPY_BTN_H + URL_COPY_PAD

    local f = CreateFrame("Frame", "HorizonSuiteURLCopyBox", UIParent, "BackdropTemplate")
    f:SetSize(URL_COPY_W, fH)
    f:SetPoint("CENTER", 0, 30)
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
    f:SetBackdropColor(unpack(URL_COPY_BG_COL))
    f:SetBackdropBorderColor(unpack(URL_COPY_EDGE_COL))

    tinsert(UISpecialFrames, "HorizonSuiteURLCopyBox")

    local ar, ag, ab = GetURLCopyAccentRGB()
    local accentStrip = f:CreateTexture(nil, "OVERLAY")
    accentStrip:SetHeight(URL_COPY_ACCENT_H)
    accentStrip:SetPoint("TOPLEFT", 1, -1)
    accentStrip:SetPoint("TOPRIGHT", -1, -1)
    accentStrip:SetColorTexture(ar, ag, ab, 1)
    f.accentStrip = accentStrip

    local dragZone = CreateFrame("Frame", nil, f)
    dragZone:SetPoint("TOPLEFT")
    dragZone:SetPoint("TOPRIGHT")
    dragZone:SetHeight(URL_COPY_TITLE_H)
    dragZone:EnableMouse(true)
    dragZone:RegisterForDrag("LeftButton")
    dragZone:SetScript("OnDragStart", function()
        if not InCombatLockdown() then f:StartMoving() end
    end)
    dragZone:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)

    local suiteLbl = dragZone:CreateFontString(nil, "OVERLAY")
    suiteLbl:SetFont(URL_COPY_F_HEAD, 13, "OUTLINE")
    suiteLbl:SetPoint("TOPLEFT", dragZone, "TOPLEFT", URL_COPY_PAD, -(URL_COPY_ACCENT_H + 10))
    suiteLbl:SetText("HORIZON SUITE")
    suiteLbl:SetTextColor(0.88, 0.88, 0.92)

    local subtitleLbl = dragZone:CreateFontString(nil, "OVERLAY")
    subtitleLbl:SetFont(URL_COPY_F_BODY, 10, "")
    subtitleLbl:SetPoint("TOPLEFT", suiteLbl, "BOTTOMLEFT", 0, -3)
    subtitleLbl:SetText((addon.L and addon.L["OPTIONS_FOCUS_COPY_LINK"]) or "Copy link")
    subtitleLbl:SetTextColor(ar, ag, ab)
    f.subtitleLbl = subtitleLbl

    local closeBtn = CreateFrame("Button", nil, dragZone)
    closeBtn:SetSize(28, 28)
    closeBtn:SetPoint("TOPRIGHT", dragZone, "TOPRIGHT", -4, -(URL_COPY_ACCENT_H + 8))
    local closeBg = closeBtn:CreateTexture(nil, "BACKGROUND")
    closeBg:SetAllPoints()
    closeBg:SetColorTexture(1, 0.3, 0.3, 0)
    local closeX = closeBtn:CreateFontString(nil, "OVERLAY")
    closeX:SetFont(URL_COPY_F_HEAD, 13, "OUTLINE")
    closeX:SetPoint("CENTER")
    closeX:SetText("\195\151")
    closeX:SetTextColor(0.36, 0.36, 0.42)
    closeBtn:SetScript("OnEnter", function()
        closeX:SetTextColor(1, 1, 1)
        closeBg:SetColorTexture(1, 0.3, 0.3, 0.2)
    end)
    closeBtn:SetScript("OnLeave", function()
        closeX:SetTextColor(0.36, 0.36, 0.42)
        closeBg:SetColorTexture(1, 0.3, 0.3, 0)
    end)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    local topRule = f:CreateTexture(nil, "ARTWORK")
    topRule:SetHeight(1)
    topRule:SetPoint("TOPLEFT", URL_COPY_PAD, -URL_COPY_TITLE_H)
    topRule:SetPoint("TOPRIGHT", -URL_COPY_PAD, -URL_COPY_TITLE_H)
    topRule:SetColorTexture(unpack(URL_COPY_RULE_COL))

    local hintLbl = f:CreateFontString(nil, "OVERLAY")
    hintLbl:SetFont(URL_COPY_F_BODY, 10, "")
    hintLbl:SetPoint("TOPLEFT", f, "TOPLEFT", URL_COPY_PAD, -bodyTop)
    hintLbl:SetPoint("RIGHT", f, "RIGHT", -URL_COPY_PAD, 0)
    hintLbl:SetWordWrap(true)
    hintLbl:SetNonSpaceWrap(false)
    hintLbl:SetText((addon.L and addon.L["OPTIONS_FOCUS_COPY_URL_BELOW_CTRL_C_PASTE"]) or "Copy the URL below (Ctrl+C) and paste in your browser.")
    hintLbl:SetTextColor(0.42, 0.42, 0.50)

    local eb = CreateFrame("EditBox", nil, f)
    eb:SetSize(URL_COPY_W - URL_COPY_PAD * 2, URL_COPY_EDIT_H)
    eb:SetPoint("TOPLEFT", hintLbl, "BOTTOMLEFT", 0, -4)
    eb:SetPoint("RIGHT", f, "RIGHT", -URL_COPY_PAD, 0)
    eb:SetFontObject(ChatFontNormal)
    eb:SetFont("Fonts\\ARIALN.TTF", 11, "")
    eb:SetAutoFocus(false)
    eb:SetMaxLetters(2048)
    eb:SetScript("OnEscapePressed", function() eb:ClearFocus() f:Hide() end)
    local ebBgTex = eb:CreateTexture(nil, "BACKGROUND")
    ebBgTex:SetAllPoints()
    ebBgTex:SetColorTexture(ebBg[1], ebBg[2], ebBg[3], ebBg[4] or 1)
    local ebLeft = eb:CreateTexture(nil, "BORDER")
    ebLeft:SetWidth(1)
    ebLeft:SetColorTexture(ebBorder[1], ebBorder[2], ebBorder[3], ebBorder[4] or 1)
    ebLeft:SetPoint("TOPLEFT", 0, 1)
    ebLeft:SetPoint("BOTTOMLEFT", 0, -1)
    local ebRight = eb:CreateTexture(nil, "BORDER")
    ebRight:SetWidth(1)
    ebRight:SetColorTexture(ebBorder[1], ebBorder[2], ebBorder[3], ebBorder[4] or 1)
    ebRight:SetPoint("TOPRIGHT", 0, 1)
    ebRight:SetPoint("BOTTOMRIGHT", 0, -1)
    local ebTop = eb:CreateTexture(nil, "BORDER")
    ebTop:SetHeight(1)
    ebTop:SetColorTexture(ebBorder[1], ebBorder[2], ebBorder[3], ebBorder[4] or 1)
    ebTop:SetPoint("TOPLEFT", 0, 0)
    ebTop:SetPoint("TOPRIGHT", 0, 0)
    local ebBottom = eb:CreateTexture(nil, "BORDER")
    ebBottom:SetHeight(1)
    ebBottom:SetColorTexture(ebBorder[1], ebBorder[2], ebBorder[3], ebBorder[4] or 1)
    ebBottom:SetPoint("BOTTOMLEFT", 0, 0)
    ebBottom:SetPoint("BOTTOMRIGHT", 0, 0)
    f.editBox = eb

    local btn = CreateFrame("Button", nil, f)
    btn:SetSize(72, URL_COPY_BTN_H)
    btn:SetPoint("BOTTOM", f, "BOTTOM", 0, URL_COPY_PAD)
    local btnBg = btn:CreateTexture(nil, "BACKGROUND")
    btnBg:SetAllPoints()
    btnBg:SetColorTexture(URL_COPY_EDGE_COL[1], URL_COPY_EDGE_COL[2], URL_COPY_EDGE_COL[3], 0.6)
    btn:SetNormalTexture(btnBg)
    local btnLabel = btn:CreateFontString(nil, "OVERLAY")
    btnLabel:SetFont(URL_COPY_F_HEAD, 10, "")
    btnLabel:SetPoint("CENTER")
    btnLabel:SetText(_G.OKAY or "Close")
    btnLabel:SetTextColor(0.9, 0.9, 0.92)
    btn:SetScript("OnClick", function() f:Hide() end)
    btn:SetScript("OnEnter", function()
        btnBg:SetColorTexture(ar * 0.5, ag * 0.5, ab * 0.5, 0.5)
    end)
    btn:SetScript("OnLeave", function()
        btnBg:SetColorTexture(URL_COPY_EDGE_COL[1], URL_COPY_EDGE_COL[2], URL_COPY_EDGE_COL[3], 0.6)
    end)

    urlCopyFrame = f
    return f
end

--- Show the URL copy box (same chrome as What's New / Patch Notes). User can Ctrl+C from the edit box and paste in a browser.
--- @param url string Full URL to display and copy
--- @param accentSubtitle string|nil Second header line (accent colour), e.g. "Copy link — Discord"; defaults to L["OPTIONS_FOCUS_COPY_LINK"]
function addon.ShowURLCopyBox(url, accentSubtitle)
    if not url or type(url) ~= "string" or url == "" then return end
    local f = BuildURLCopyFrame()
    if not f or not f.editBox then return end
    local ar, ag, ab = GetURLCopyAccentRGB()
    if f.accentStrip then
        f.accentStrip:SetColorTexture(ar, ag, ab, 1)
    end
    if f.subtitleLbl then
        f.subtitleLbl:SetText(accentSubtitle or ((addon.L and addon.L["OPTIONS_FOCUS_COPY_LINK"]) or "Copy link"))
        f.subtitleLbl:SetTextColor(ar, ag, ab)
    end
    f.editBox:SetText(url)
    f:Show()
    -- Defer focus and highlight so the edit box is ready and Ctrl+C works immediately (WoW quirk).
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            if f:IsShown() and f.editBox then
                f.editBox:SetFocus()
                f.editBox:HighlightText()
            end
        end)
    else
        f.editBox:SetFocus()
        f.editBox:HighlightText()
    end
end

--- Refresh URL copy dialog accent if visible (e.g. when Dashboard class colour option changes).
--- @return nil
function addon.ApplyURLCopyBoxAccent()
    if not urlCopyFrame or not urlCopyFrame:IsShown() then return end
    local ar, ag, ab = GetURLCopyAccentRGB()
    if urlCopyFrame.accentStrip then
        urlCopyFrame.accentStrip:SetColorTexture(ar, ag, ab, 1)
    end
    if urlCopyFrame.subtitleLbl then
        urlCopyFrame.subtitleLbl:SetTextColor(ar, ag, ab)
    end
end
