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

local btn

local function ShowOptions()
    if addon.ShowOptions then
        addon.ShowOptions()
    elseif _G.HorizonSuite_ShowOptions then
        _G.HorizonSuite_ShowOptions()
    end
end

local function IsMinimapButtonHidden()
    return addon.GetDB and addon.GetDB("hideMinimapButton", false) or false
end

local function UpdateVisibility()
    if not btn then return end
    if IsMinimapButtonHidden() then
        btn:Hide()
    else
        btn:Show()
    end
end

local function CreateButton()
    if btn then return btn end

    btn = CreateFrame("Button", "HorizonSuiteMinimapButton", Minimap)
    btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(Minimap:GetFrameLevel() + 5)
    btn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 2, -2)
    btn:SetClampedToScreen(true)
    btn:EnableMouse(true)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local ok = pcall(icon.SetTexture, icon, ICON_PATH)
    if not ok then
        icon:SetTexture(FALLBACK_ICON)
    end
    btn.icon = icon

    btn:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "LeftButton" then
            ShowOptions()
        elseif mouseButton == "RightButton" then
            -- Right-click could toggle visibility; for now same as left
            ShowOptions()
        end
    end)
    btn:SetScript("OnEnter", function(self)
        if GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText(L["Options"] or "Options", nil, nil, nil, nil, true)
            GameTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", function()
        if GameTooltip then GameTooltip:Hide() end
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
