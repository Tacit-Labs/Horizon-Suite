--[[
    Horizon Suite - Dashboard small helpers (text, axis category keys, branding).
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

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
        { label = L["DASH_DISCORD"] or "Discord", url = "https://discord.com/invite/e7nW2f4VQj", icon = "Interface/AddOns/HorizonSuite/media/discord.tga" },
        { label = L["DASH_KO_FI"] or "Ko-fi", url = "https://ko-fi.com/horizonsuite", icon = "Interface/AddOns/HorizonSuite/media/kofi.tga" },
        { label = L["DASH_PATREON"] or "Patreon", url = "https://patreon.com/HorizonSuite", icon = "Interface/AddOns/HorizonSuite/media/patreon.tga" },
        { label = L["DASH_GITLAB"] or "GitLab", url = "https://gitlab.com/Crystilac/horizon-suite", icon = "Interface/AddOns/HorizonSuite/media/gitlab.tga" },
        { label = L["DASH_CURSEFORGE"] or "CurseForge", url = "https://www.curseforge.com/projects/1457844", icon = "Interface/AddOns/HorizonSuite/media/CurseForge.tga" },
        { label = L["DASH_WAGO"] or "Wago", url = "https://addons.wago.io/addons/jK8gY56y", icon = "Interface/AddOns/HorizonSuite/media/wago.tga" },
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

    local function CreateFooterLink(parentFrame, label, onClick, iconPath)
        local btn = CreateFrame("Button", nil, parentFrame)
        btn:SetSize(100, 20)

        local iconTex
        if iconPath then
            iconTex = btn:CreateTexture(nil, "ARTWORK")
            iconTex:SetSize(14, 14)
            iconTex:SetPoint("LEFT", btn, "LEFT", 12, 0)
            iconTex:SetTexture(iconPath)
            iconTex:SetVertexColor(0.52, 0.56, 0.62)
        end

        local lbl = MakeText(btn, label, 12, 0.52, 0.56, 0.62, iconPath and "CENTER" or "CENTER")
        lbl:ClearAllPoints()
        if iconTex then
            lbl:SetPoint("LEFT", iconTex, "RIGHT", 4, 0)
            lbl:SetPoint("RIGHT", btn, "RIGHT", -12, 0)
        elseif iconPath == nil then
            lbl:SetAllPoints()
        else
            lbl:SetPoint("LEFT", btn, "LEFT", 0, 0)
            lbl:SetPoint("RIGHT", btn, "RIGHT", 0, 0)
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
            lbl:SetTextColor(0.88, 0.90, 0.94)
            if iconTex then iconTex:SetVertexColor(0.88, 0.90, 0.94) end
            local ar, ag, ab = GetAccentColor()
            underline:SetColorTexture(ar, ag, ab, 0.6)
            underline:Show()
        end)
        btn:SetScript("OnLeave", function()
            lbl:SetTextColor(0.52, 0.56, 0.62)
            if iconTex then iconTex:SetVertexColor(0.52, 0.56, 0.62) end
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
        -- Position the separator rule
        footerTopRule:ClearAllPoints()
        footerTopRule:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -fy)
        footerTopRule:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -fy)
        fy = fy + 1 + 12

        -- Position the heading
        communityHdr:SetWidth(w)
        communityHdr:ClearAllPoints()
        communityHdr:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -fy)
        fy = fy + communityHdr:GetHeight() + 8

        -- Distribute buttons evenly across available width
        local numButtons = #footerLinkButtons
        local spacedBtnW = math.floor((w - 20) / numButtons)  -- 20 = left+right margin
        local btnSpacing = spacedBtnW

        for i, btn in ipairs(footerLinkButtons) do
            btn:SetWidth(spacedBtnW - 4)  -- Small margin between buttons
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10 + (i - 1) * btnSpacing, -fy)
        end
        fy = fy + 20

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
