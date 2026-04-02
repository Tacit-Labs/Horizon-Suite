--[[
    Horizon Suite - Dashboard small helpers (text, axis category keys, branding).
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

-- Community & Support footer link icons (Welcome + Module Guide); keep paths in sync with media/dashboard/footer/
local DASHBOARD_FOOTER_MEDIA = "Interface/AddOns/HorizonSuite/media/dashboard/footer/"
-- Authoritative pixel size of each bundled footer .tga (aspect ratio). WoW GetTextureFileWidth/Height can reflect
-- GPU-padded dimensions and skew layout; using file dimensions keeps wordmarks uniformly scaled without stretch.
-- Optional maxVisualH raises the height cap for that slot only (still clamped to FOOTER_LINK_ROW_HEIGHT insets).
local FOOTER_WORDMARK_INTRINSIC_PX = {
    [DASHBOARD_FOOTER_MEDIA .. "discord.tga"] = { w = 128, h = 19 },
    [DASHBOARD_FOOTER_MEDIA .. "kofi.tga"] = { w = 128, h = 35 },
    [DASHBOARD_FOOTER_MEDIA .. "patreon.tga"] = { w = 128, h = 29 },
    [DASHBOARD_FOOTER_MEDIA .. "gitlab.tga"] = { w = 90, h = 21 },
    [DASHBOARD_FOOTER_MEDIA .. "CurseForge.tga"] = { w = 728, h = 150, maxVisualH = 22 },
    [DASHBOARD_FOOTER_MEDIA .. "wago.tga"] = { w = 128, h = 74 },
}
-- Footer link row: bright at rest; wordmarks are icon-only (texture includes text). Hover: underline + nudge to white.
local FOOTER_LINK_IDLE_R, FOOTER_LINK_IDLE_G, FOOTER_LINK_IDLE_B = 0.93, 0.95, 0.98
local FOOTER_LINK_HOVER_R, FOOTER_LINK_HOVER_G, FOOTER_LINK_HOVER_B = 1, 1, 1
local FOOTER_LINK_ROW_HEIGHT = 32
local FOOTER_LINK_MAX_VISUAL_H = 16
local FOOTER_LINK_ICON_INSET = 4
local FOOTER_LINK_GAP = 10

--- @param moduleKey string|nil
--- @return string|nil
function addon.Dashboard_BrandModule(moduleKey)
    local t = addon.BrandDisplay and addon.BrandDisplay.module
    if not moduleKey or not t then return nil end
    return t[moduleKey]
end

-- Categories shown under the Axis hub (dashboard + search); keep in sync with OptionCategories keys.
--- @param catKey string
--- @return boolean
function addon.Dashboard_IsAxisCategoryKey(catKey)
    return catKey == "Profiles" or catKey == "Modules" or catKey == "GlobalToggles"
end

--- @param parent Frame
--- @param text string
--- @param size number
--- @param r number
--- @param g number
--- @param b number
--- @param justify string|nil
--- @return FontString
function addon.Dashboard_MakeText(parent, text, size, r, g, b, justify)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    local font = size >= 14 and "Fonts\\FRIZQT__.TTF" or "Fonts\\ARIALN.TTF"
    local flags = size >= 14 and "OUTLINE" or ""
    fs:SetFont(font, size, flags)
    fs:SetText(text)
    fs:SetTextColor(r, g, b)
    if justify then fs:SetJustifyH(justify) end
    return fs
end

-- Welcome contributor / localization bodies may include Hangul or CJK; ARIALN and FRIZQT omit those glyphs on many enUS installs (tofu squares). 2002 is Blizzard's broad-coverage UI font.
--- @param parent Frame
--- @param text string
--- @param size number
--- @param r number
--- @param g number
--- @param b number
--- @param justify string|nil
--- @return FontString
function addon.Dashboard_MakeWelcomeMixedScriptText(parent, text, size, r, g, b, justify)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    local ok = pcall(function()
        fs:SetFont("Fonts\\2002.TTF", size, "")
    end)
    if not ok then
        fs:SetFont("Fonts\\ARIALN.TTF", size, "")
    end
    fs:SetText(text)
    fs:SetTextColor(r, g, b)
    if justify then fs:SetJustifyH(justify) end
    return fs
end

--- Smooth vertical scroll with optional custom thumb track.
--- @param scrollFrame ScrollFrame
--- @param scrollContent Frame
--- @param speed number|nil
--- @param addScrollbar boolean|nil
--- @return nil
function addon.Dashboard_ApplySmoothScroll(scrollFrame, scrollContent, speed, addScrollbar)
    scrollFrame.targetScroll = nil
    scrollFrame.scrollSpeed = speed or 60

    local updateThumb
    if addScrollbar then
        local track = CreateFrame("Frame", nil, scrollFrame)
        track:SetWidth(4)
        track:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 10, 0)
        track:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 10, 0)

        local thumb = track:CreateTexture(nil, "OVERLAY")
        thumb:SetWidth(4)
        thumb:SetColorTexture(1, 1, 1, 0.2)

        updateThumb = function()
            local frameH = scrollFrame:GetHeight() or 1
            if frameH == 0 then frameH = 1 end
            local contentH = scrollContent:GetHeight() or 1
            if contentH <= frameH then
                thumb:Hide()
                return
            end
            thumb:Show()
            local scroll = scrollFrame:GetVerticalScroll() or 0
            local maxScroll = math.max(1, contentH - frameH)
            local thumbPct = frameH / contentH
            local thumbH = math.max(20, frameH * thumbPct)
            thumb:SetHeight(thumbH)
            local trackH = (track:GetHeight() or frameH) - thumbH
            local offset = (scroll / maxScroll) * trackH
            thumb:ClearAllPoints()
            thumb:SetPoint("TOP", track, "TOP", 0, -offset)
        end

        if scrollFrame:GetScript("OnScrollRangeChanged") then
            scrollFrame:HookScript("OnScrollRangeChanged", updateThumb)
        else
            scrollFrame:SetScript("OnScrollRangeChanged", updateThumb)
        end

        if scrollFrame:GetScript("OnVerticalScroll") then
            scrollFrame:HookScript("OnVerticalScroll", updateThumb)
        else
            scrollFrame:SetScript("OnVerticalScroll", updateThumb)
        end
    end

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
                self:SetVerticalScroll(current + diff * 25 * elapsed)
            end
            if updateThumb then updateThumb() end
        end)
    end)
end

--- Shared Community & Support footer for Welcome and Module Guide tabs.
--- @param parent Frame — frame that will hold the footer (e.g., footerPanel)
--- @param env table — { L, GetAccentColor, MakeText, addon }
--- @return table — { footerPanel, footerLinkButtons, communityHdr, footerTopRule, layout }
function addon.Dashboard_CreateCommunityFooter(parent, env)
    local L = env.L
    local GetAccentColor = env.GetAccentColor
    local MakeText = env.MakeText

    local linkData = {
        { label = L["DASH_DISCORD"] or "Discord", url = "https://discord.gg/nFabdZmvSB", icon = DASHBOARD_FOOTER_MEDIA .. "discord.tga" },
        { label = L["DASH_KO_FI"] or "Ko-fi", url = "https://ko-fi.com/horizonsuite", icon = DASHBOARD_FOOTER_MEDIA .. "kofi.tga" },
        { label = L["DASH_PATREON"] or "Patreon", url = "https://patreon.com/HorizonSuite", icon = DASHBOARD_FOOTER_MEDIA .. "patreon.tga" },
        { label = L["DASH_GITLAB"] or "GitLab", url = "https://gitlab.com/Crystilac/horizon-suite", icon = DASHBOARD_FOOTER_MEDIA .. "gitlab.tga" },
        { label = L["DASH_CURSEFORGE"] or "CurseForge", url = "https://www.curseforge.com/projects/1457844", icon = DASHBOARD_FOOTER_MEDIA .. "CurseForge.tga" },
        { label = L["DASH_WAGO"] or "Wago", url = "https://addons.wago.io/addons/jK8gY56y", icon = DASHBOARD_FOOTER_MEDIA .. "wago.tga" },
    }

    local footerTopRule = parent:CreateTexture(nil, "ARTWORK")
    footerTopRule:SetHeight(1)
    footerTopRule:SetColorTexture(0.22, 0.24, 0.30, 0.85)

    local communityHdr = MakeText(parent, L["DASH_WELCOME_COMMUNITY_HEADING"] or "Community & Support", 14, 0.52, 0.56, 0.62, "LEFT")

    local function ShowCopyURL(label, url)
        if env.addon and env.addon.ShowURLCopyBox then
            env.addon.ShowURLCopyBox(url, (L["DASH_COPY_LINK_X"] or "Copy link — %s"):format(label))
        end
    end

    -- Uniform scale inside max box; cap at 1 so wordmarks are not upscaled (crisp). Centered; no stretch.
    -- intrinsicW/H from FOOTER_WORDMARK_INTRINSIC_PX when set; else GetTextureFile* (may be 0 until load).
    local function FooterWordmarkDisplaySize(tex, boxW, boxH, intrinsicW, intrinsicH)
        if not tex or not boxW or not boxH or boxW < 1 or boxH < 1 then
            return 1, 1
        end
        local nw, nh
        if intrinsicW and intrinsicH and intrinsicW > 0 and intrinsicH > 0 then
            nw, nh = intrinsicW, intrinsicH
        else
            nw = tex.GetTextureFileWidth and tex:GetTextureFileWidth() or 0
            nh = tex.GetTextureFileHeight and tex:GetTextureFileHeight() or 0
        end
        if nw < 1 or nh < 1 then
            return boxW, boxH
        end
        local scale = math.min(boxW / nw, boxH / nh, 1)
        return math.max(1, math.floor(nw * scale + 0.5)), math.max(1, math.floor(nh * scale + 0.5))
    end

    local function FitCommunityFooterWordmarks(buttons)
        for _, btn in ipairs(buttons) do
            local tex = btn.iconTex
            if tex then
                local bw = btn:GetWidth() or 0
                local maxW = bw - 2 * FOOTER_LINK_ICON_INSET
                local visualCap = btn.wordmarkMaxVisualH or FOOTER_LINK_MAX_VISUAL_H
                local maxH = math.min(FOOTER_LINK_ROW_HEIGHT - 2 * FOOTER_LINK_ICON_INSET, visualCap)
                if maxW > 0 and maxH > 0 then
                    local dw, dh = FooterWordmarkDisplaySize(tex, maxW, maxH, btn.wordmarkIntrinsicW, btn.wordmarkIntrinsicH)
                    tex:ClearAllPoints()
                    tex:SetSize(dw, dh)
                    tex:SetPoint("CENTER", btn, "CENTER", 0, 0)
                end
            end
        end
    end

    local function CreateFooterLink(parentFrame, label, onClick, iconPath)
        local btn = CreateFrame("Button", nil, parentFrame)
        btn:SetSize(100, FOOTER_LINK_ROW_HEIGHT)

        local iconTex
        if iconPath then
            iconTex = btn:CreateTexture(nil, "ARTWORK")
            if iconTex.SetBlockingLoadsRequested then
                iconTex:SetBlockingLoadsRequested(true)
            end
            iconTex:SetTexture(iconPath)
            if iconTex.SetBlockingLoadsRequested then
                iconTex:SetBlockingLoadsRequested(false)
            end
            iconTex:SetVertexColor(FOOTER_LINK_IDLE_R, FOOTER_LINK_IDLE_G, FOOTER_LINK_IDLE_B)
            btn.iconTex = iconTex
            local intrinsic = FOOTER_WORDMARK_INTRINSIC_PX[iconPath]
            if intrinsic then
                btn.wordmarkIntrinsicW = intrinsic.w
                btn.wordmarkIntrinsicH = intrinsic.h
                if intrinsic.maxVisualH and intrinsic.maxVisualH > 0 then
                    btn.wordmarkMaxVisualH = intrinsic.maxVisualH
                end
            end
        end

        local lbl = MakeText(btn, label, 12, FOOTER_LINK_IDLE_R, FOOTER_LINK_IDLE_G, FOOTER_LINK_IDLE_B, "CENTER")
        lbl:ClearAllPoints()
        if iconPath then
            lbl:Hide()
        else
            lbl:SetAllPoints()
        end
        btn.label = lbl

        local underline = btn:CreateTexture(nil, "OVERLAY")
        underline:SetHeight(1)
        underline:SetPoint("BOTTOM", btn, "BOTTOM", 0, 0)
        underline:SetPoint("LEFT", btn, "LEFT", 0, 0)
        underline:SetPoint("RIGHT", btn, "RIGHT", 0, 0)
        underline:Hide()
        btn.underline = underline

        btn:SetScript("OnEnter", function()
            if lbl:IsShown() then
                lbl:SetTextColor(FOOTER_LINK_HOVER_R, FOOTER_LINK_HOVER_G, FOOTER_LINK_HOVER_B)
            end
            if iconTex then iconTex:SetVertexColor(FOOTER_LINK_HOVER_R, FOOTER_LINK_HOVER_G, FOOTER_LINK_HOVER_B) end
            local ar, ag, ab = GetAccentColor()
            underline:SetColorTexture(ar, ag, ab, 0.6)
            underline:Show()
        end)
        btn:SetScript("OnLeave", function()
            if lbl:IsShown() then
                lbl:SetTextColor(FOOTER_LINK_IDLE_R, FOOTER_LINK_IDLE_G, FOOTER_LINK_IDLE_B)
            end
            if iconTex then iconTex:SetVertexColor(FOOTER_LINK_IDLE_R, FOOTER_LINK_IDLE_G, FOOTER_LINK_IDLE_B) end
            underline:Hide()
        end)
        btn:SetScript("OnClick", onClick)
        return btn
    end

    local footerLinkButtons = {}
    for _, link in ipairs(linkData) do
        local btn = CreateFooterLink(parent, link.label, function()
            ShowCopyURL(link.label, link.url)
        end, link.icon)
        table.insert(footerLinkButtons, btn)
    end

    local function LayoutFooter(w, fy, bgFrame)
        local ruleH = 1
        -- Heading first, then divider, then links — gap under title is obvious (was: 1px rule above title, easy to miss).
        local titleToRuleGap = 14
        local ruleToButtonsGap = 10

        communityHdr:SetWidth(w)
        communityHdr:ClearAllPoints()
        communityHdr:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -fy)
        local hdrH = communityHdr:GetStringHeight()
        if not hdrH or hdrH < 1 then
            hdrH = math.max(communityHdr:GetHeight(), 18)
        end
        fy = fy + hdrH + titleToRuleGap

        footerTopRule:ClearAllPoints()
        footerTopRule:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -fy)
        footerTopRule:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -fy)
        fy = fy + ruleH + ruleToButtonsGap

        -- Distribute buttons evenly across available width
        local numButtons = #footerLinkButtons
        local availableW = w - 20 - ((numButtons - 1) * FOOTER_LINK_GAP)  -- 20 = left+right margin
        local spacedBtnW = math.floor(availableW / numButtons)
        local btnSpacing = spacedBtnW + FOOTER_LINK_GAP

        for i, btn in ipairs(footerLinkButtons) do
            btn:SetWidth(spacedBtnW)
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10 + (i - 1) * btnSpacing, -fy)
        end
        FitCommunityFooterWordmarks(footerLinkButtons)
        -- GetTextureFileWidth/Height can be 0 until the file resolves.
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                FitCommunityFooterWordmarks(footerLinkButtons)
            end)
            C_Timer.After(0.05, function()
                FitCommunityFooterWordmarks(footerLinkButtons)
            end)
            C_Timer.After(0.15, function()
                FitCommunityFooterWordmarks(footerLinkButtons)
            end)
        end
        fy = fy + FOOTER_LINK_ROW_HEIGHT

        -- Position footer panel itself
        parent:SetWidth(w)
        parent:SetHeight(math.max(fy + 4, 1))
        parent:ClearAllPoints()
        parent:SetPoint("BOTTOMLEFT", bgFrame, "BOTTOMLEFT", 20, 14)
        parent:SetPoint("BOTTOMRIGHT", bgFrame, "BOTTOMRIGHT", -20, 14)

        return fy
    end

    return {
        footerPanel = parent,
        footerLinkButtons = footerLinkButtons,
        communityHdr = communityHdr,
        footerTopRule = footerTopRule,
        layout = LayoutFooter,
    }
end
