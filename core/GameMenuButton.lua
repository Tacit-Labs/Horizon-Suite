--[[
    Horizon Suite - GameMenu Button
    Adds a "Horizon Suite" entry to the in-game menu (Esc) that opens the dashboard.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = addon.L

local function OpenHorizon()
    HideUIPanel(GameMenuFrame)
    if addon.ShowDashboard then
        addon.ShowDashboard()
    end
end

local function FindAddonsButton()
    if _G.GameMenuButtonAddons then return _G.GameMenuButtonAddons end
    if GameMenuFrame.AddonsButton then return GameMenuFrame.AddonsButton end

    local target = _G.ADDONS or "AddOns"
    for _, child in ipairs({ GameMenuFrame:GetChildren() }) do
        if child.GetText and child:GetText() == target then
            return child
        end
    end
end

local function CreateButton()
    if _G.HorizonSuiteGameMenuButton then return end

    local button = CreateFrame("Button", "HorizonSuiteGameMenuButton", GameMenuFrame, "MainMenuFrameButtonTemplate")
    button:SetText(L["GAMEMENU_OPEN_HORIZON"])
    button:SetScript("OnClick", OpenHorizon)

    local addonsBtn = FindAddonsButton()
    if addonsBtn then
        -- Fractional offset slots us between Shop and AddOns regardless of
        -- whether Blizzard uses sequential or sparse layoutIndex values.
        button.layoutIndex = addonsBtn.layoutIndex - 0.5
        button.topPadding = addonsBtn.topPadding
        button:SetSize(addonsBtn:GetWidth(), addonsBtn:GetHeight())
    else
        button.layoutIndex = 100
    end

    GameMenuFrame:Layout()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    GameMenuFrame:HookScript("OnShow", CreateButton)
end)
