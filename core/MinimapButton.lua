--[[
    Horizon Suite - Minimap Button
    Clickable minimap icon that opens the options panel.
    Excluded from Vista's button collector via INTERNAL_BLACKLIST.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = addon.L or {}
local Minimap = _G.Minimap
if not Minimap then return end

local BUTTON_SIZE = 20
local ICON_PATH = "Interface\\AddOns\\HorizonSuite\\icon"
local FALLBACK_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

local FADE_IN_DUR = 0.2
local FADE_OUT_DUR = 0.3

local btn
local hoverZone  -- invisible frame over minimap to detect hover

local function ShowOptions()
    if addon.ShowDashboard then
        addon.ShowDashboard()
    elseif _G.HorizonSuite_ShowDashboard then
        _G.HorizonSuite_ShowDashboard()
    end
end

local function IsMinimapButtonHidden()
    return addon.GetDB and addon.GetDB("hideMinimapButton", false) or false
end

local function FadeButton(targetAlpha)
    if not btn then return end
    if btn.fadeTo == targetAlpha then return end
    btn.fadeTo = targetAlpha
    btn.fadeFrom = btn:GetAlpha()
    btn.fadeElapsed = 0
    btn.fadeDur = targetAlpha > 0 and FADE_IN_DUR or FADE_OUT_DUR
    btn:SetScript("OnUpdate", function(self, elapsed)
        self.fadeElapsed = self.fadeElapsed + elapsed
        local pct = math.min(self.fadeElapsed / self.fadeDur, 1)
        local alpha = self.fadeFrom + (self.fadeTo - self.fadeFrom) * pct
        self:SetAlpha(alpha)
        if pct >= 1 then
            self:SetScript("OnUpdate", nil)
            if alpha <= 0 then
                self:EnableMouse(false)
            end
        end
    end)
    if targetAlpha > 0 then
        btn:EnableMouse(true)
        btn:Show()
    end
end

local function UpdateVisibility()
    if not btn then return end
    if IsMinimapButtonHidden() then
        btn:Hide()
        if hoverZone then hoverZone:Hide() end
    else
        btn:SetAlpha(0)
        btn:EnableMouse(false)
        btn:Show()
        if hoverZone then hoverZone:Show() end
    end
end

local function CreateButton()
    if btn then return btn end

    btn = CreateFrame("Button", "HorizonSuiteMinimapButton", Minimap)
    btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(Minimap:GetFrameLevel() + 5)
    btn:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 2, 2)
    btn:SetClampedToScreen(true)
    btn:EnableMouse(false)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:SetAlpha(0)

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local ok = pcall(icon.SetTexture, icon, ICON_PATH)
    if not ok then
        icon:SetTexture(FALLBACK_ICON)
    end
    btn.icon = icon

    btn:SetScript("OnClick", function(self, mouseButton)
        ShowOptions()
    end)
    btn:SetScript("OnEnter", function(self)
        FadeButton(1)
        if GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText(L["Options"] or "Options", nil, nil, nil, nil, true)
            GameTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", function()
        if GameTooltip then GameTooltip:Hide() end
        -- Stay visible if mouse is still over the minimap area
        if hoverZone and hoverZone:IsMouseOver() then return end
        FadeButton(0)
    end)

    -- Hover zone: invisible frame covering the minimap to detect mouse enter/leave
    hoverZone = CreateFrame("Frame", nil, Minimap)
    hoverZone:SetAllPoints(Minimap)
    hoverZone:SetFrameStrata("BACKGROUND")
    hoverZone:EnableMouse(false)  -- don't eat clicks
    hoverZone:SetScript("OnUpdate", function(self)
        if IsMinimapButtonHidden() then return end
        if self:IsMouseOver() or (btn and btn:IsMouseOver()) then
            if btn:GetAlpha() < 1 and btn.fadeTo ~= 1 then
                FadeButton(1)
            end
        else
            if btn:GetAlpha() > 0 and btn.fadeTo ~= 0 then
                FadeButton(0)
            end
        end
    end)

    UpdateVisibility()
    return btn
end

-- Create on load; defer slightly so Minimap is fully ready
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        C_Timer.After(0.5, function()
            CreateButton()
        end)
    end
end)

addon.MinimapButton_UpdateVisibility = UpdateVisibility
