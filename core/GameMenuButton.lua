--[[
    Horizon Suite - GameMenu Button
    Adds a "Horizon Suite" entry to the in-game menu (Esc) that opens the dashboard.
]]

local addon = _G.HorizonSuite
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

    local target = _G.ADDONS
    for _, child in ipairs({ GameMenuFrame:GetChildren() }) do
        if child.GetText and child:GetText() == target then
            return child
        end
    end
end

-- Run one frame after OnShow so all other addons' hooks and Layout calls have
-- settled. Find whichever button is visually directly above AddOns (could be
-- Shop normally, or ElvUI's config button when ElvUI is installed) and anchor
-- ourselves just below it. This is purely position-based so it works regardless
-- of whether the other addon uses layoutIndex or SetPoint.
local function PositionButton()
    local btn = rawget(_G, "HorizonSuiteGameMenuButton")
    if not btn then return end

    local addonsBtn = FindAddonsButton()
    if not addonsBtn then return end

    local addonsTop = addonsBtn:GetTop()
    if not addonsTop then return end

    -- Walk all Button children; find the one whose bottom edge sits closest
    -- above AddOns's top edge (excluding our own button and AddOns itself).
    local prevBtn, prevBtnBottom
    for _, child in ipairs({ GameMenuFrame:GetChildren() }) do
        if child ~= btn and child ~= addonsBtn
        and child:IsShown()
        and child:GetObjectType() == "Button" then
            local cB = child:GetBottom()
            local cH = child:GetHeight()
            if cB and cH and cH > 10 and cB > addonsTop then
                if not prevBtnBottom or cB < prevBtnBottom then
                    prevBtnBottom = cB
                    prevBtn = child
                end
            end
        end
    end

    btn:ClearAllPoints()
    if prevBtn then
        -- Split the available space between prevBtn and AddOns equally so the
        -- gap above and below our button matches the surrounding button spacing.
        local available = prevBtnBottom - addonsTop
        local gap = math.floor(math.max(1, (available - btn:GetHeight()) / 2))
        btn:SetPoint("TOP", prevBtn, "BOTTOM", 0, -gap)
    else
        btn:SetPoint("BOTTOM", addonsBtn, "TOP", 0, btn.topPadding or 2)
    end
end

local function IsEnabled()
    if addon.GetDB then return addon.GetDB("showGameMenuButton", true) end
    local db = _G[addon.DATABASE]
    return not (db and db.showGameMenuButton == false)
end

local function CreateButton()
    if rawget(_G, "HorizonSuiteGameMenuButton") then return end

    local button = CreateFrame("Button", "HorizonSuiteGameMenuButton", GameMenuFrame, "MainMenuFrameButtonTemplate")
    button:SetText(L["AXIS_GAMEMENU_BUTTON"])
    button:SetScript("OnClick", OpenHorizon)

    local addonsBtn = FindAddonsButton()
    if addonsBtn then
        button.layoutIndex = addonsBtn.layoutIndex - 0.5
        button.topPadding  = addonsBtn.topPadding
        button:SetSize(addonsBtn:GetWidth(), addonsBtn:GetHeight())
    else
        button.layoutIndex = 100
    end

    if not IsEnabled() then button:Hide() end
    GameMenuFrame:Layout()
end

function addon.GameMenuButton_UpdateVisibility()
    local btn = rawget(_G, "HorizonSuiteGameMenuButton")
    if not btn then return end
    if IsEnabled() then btn:Show() else btn:Hide() end
    -- If the menu is open while toggling, recompact it so hiding doesn't leave a
    -- blank slot and showing re-anchors the button. Closed-menu toggles are
    -- handled by the next OnShow (CreateButton + PositionButton).
    if GameMenuFrame:IsShown() then
        GameMenuFrame:Layout()
        PositionButton()
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    GameMenuFrame:HookScript("OnShow", function()
        -- Defer one frame so all other addons' OnShow/Layout hooks complete
        -- before we create or reposition our button.
        C_Timer.After(0, function()
            CreateButton()
            PositionButton()
        end)
    end)
end)
