--[[
    Horizon Suite - GameMenu Button
    Adds a "Horizon Suite" entry to the in-game menu (Esc) that opens the
    Horizon Suite dashboard. Anchors above the AddOns button via layoutIndex
    so GameMenuFrame:Layout() places and sizes it natively.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = addon.L or setmetatable({}, { __index = function(_, k) return k end })

local positioned

local function OpenHorizon()
    if GameMenuFrame and GameMenuFrame:IsShown() then
        HideUIPanel(GameMenuFrame)
    end
    if addon.ShowDashboard then
        addon.ShowDashboard()
    elseif _G.HorizonSuite_ShowDashboard then
        _G.HorizonSuite_ShowDashboard()
    end
end

local function FindAddonsButton()
    if _G.GameMenuButtonAddons then return _G.GameMenuButtonAddons end
    if GameMenuFrame and GameMenuFrame.AddonsButton then return GameMenuFrame.AddonsButton end
    if not GameMenuFrame then return nil end

    local target = _G.ADDONS or "AddOns"
    local children = { GameMenuFrame:GetChildren() }
    for i = 1, #children do
        local child = children[i]
        if child.GetText and child:GetText() == target then
            return child
        end
    end
    return nil
end

local function PositionButton(button)
    if positioned or not button then return end
    local addonsBtn = FindAddonsButton()
    if not addonsBtn then return end

    if addonsBtn.layoutIndex then
        -- Fractional offset slots us between Shop and AddOns without colliding
        -- with either, regardless of whether Blizzard uses sequential or sparse
        -- layoutIndex values.
        button.layoutIndex = addonsBtn.layoutIndex - 0.5
    end
    -- Mirror AddOns' topPadding so we get the same gap above us that AddOns
    -- has above itself (preserves the existing visual section break).
    if addonsBtn.topPadding then
        button.topPadding = addonsBtn.topPadding
    end
    local w, h = addonsBtn:GetWidth(), addonsBtn:GetHeight()
    if w and h and w > 0 and h > 0 then
        button:SetSize(w, h)
    end
    positioned = true

    if GameMenuFrame and GameMenuFrame.Layout then
        GameMenuFrame:Layout()
    end
end

local function CreateButton()
    if not GameMenuFrame or _G.HorizonSuiteGameMenuButton then return end

    local button = CreateFrame("Button", "HorizonSuiteGameMenuButton", GameMenuFrame, "MainMenuFrameButtonTemplate")
    button:SetText(L["GAMEMENU_OPEN_HORIZON"])
    button:SetScript("OnClick", OpenHorizon)
    -- Temporary fallback layoutIndex so the button has a valid placement even
    -- before AddOns is found. Replaced on the first menu open.
    button.layoutIndex = 100

    -- Try immediately in case AddOns is already realized.
    PositionButton(button)
    -- Otherwise retry on every menu open until we succeed.
    GameMenuFrame:HookScript("OnShow", function()
        PositionButton(button)
    end)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    CreateButton()
end)
