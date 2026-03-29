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
