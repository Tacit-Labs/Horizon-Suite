--[[
    Horizon Suite - Settings Bridge
    Registers Horizon Suite with WoW's addon settings (ESC → Options → AddOns).
    Provides a minimal panel with a button to open the custom options launcher.
]]

local addon = _G.HorizonSuite
if not addon then return end

local L = addon.L or {}

local ADDON_NAME = "Horizon Suite"
local PANEL_NAME = "HorizonSuiteSettingsPanel"

local function ShowOptions()
    if addon.ShowDashboard then
        addon.ShowDashboard()
    elseif _G.HorizonSuite_ShowDashboard then
        _G.HorizonSuite_ShowDashboard()
    end
end

local function CreateSettingsPanel()
    local panel = CreateFrame("Frame", PANEL_NAME, UIParent)
    panel.name = ADDON_NAME
    panel:SetSize(400, 120)

    local btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btn:SetSize(200, 22)
    btn:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -20)
    btn:SetText(L["PRESENCE_OPEN_HORIZON_SUITE"] or "Open Horizon Suite")
    btn:SetScript("OnClick", ShowOptions)

    local label = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -12)
    label:SetPoint("RIGHT", panel, "RIGHT", -20, 0)
    label:SetNonSpaceWrap(true)
    label:SetText(L["PRESENCE_OPEN_FULL_HORIZON_SUITE_OPTIONS"] or "Open the full Horizon Suite options panel to configure Focus, Presence, Vista, and other modules.")

    return panel
end

local function RegisterWithSettings()
    local panel = CreateSettingsPanel()

    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category, layout = Settings.RegisterCanvasLayoutCategory(panel, ADDON_NAME)
        Settings.RegisterAddOnCategory(category)
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end
end

-- Defer registration until the settings system is ready (ADDON_LOADED for our addon)
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName ~= "HorizonSuite" then return end
    self:UnregisterEvent("ADDON_LOADED")
    C_Timer.After(0, RegisterWithSettings)
end)
