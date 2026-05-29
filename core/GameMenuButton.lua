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

-- Mirrors the skinning EllesmereUI applies to its own standalone game menu
-- buttons (EllesmereUI.lua ~8432). Their skinner only iterates buttonPool, so
-- standalone frames need to self-apply the same treatment when detected.
local function ApplyEllesmereUISkin(button)
    local EUI = _G.EllesmereUI
    if not EUI then return end
    local RS = EUI.RESKIN
    local PP = EUI.PP
    if not RS or not PP then return end

    local blizzSkinLoaded = C_AddOns and C_AddOns.IsAddOnLoaded and
        C_AddOns.IsAddOnLoaded("EllesmereUIBlizzardSkin")
    if not blizzSkinLoaded then return end

    local db = _G.EllesmereUIDB
    local reskin = db and db.reskinGameMenu
    if reskin == nil then
        reskin = not db or (db.customTooltips ~= false and db.reskinQueuePopup ~= false)
    end
    if not reskin then return end

    for i = 1, select("#", button:GetRegions()) do
        local r = select(i, button:GetRegions())
        if r and r:IsObjectType("Texture") and r ~= button:GetFontString() then
            r:SetAlpha(0)
        end
    end
    for _, key in ipairs({ "Left", "Middle", "Right" }) do
        local tex = button[key]
        if tex then
            tex:SetAlpha(0)
            hooksecurefunc(tex, "SetAlpha", function(self, a)
                if a > 0 then self:SetAlpha(0) end
            end)
        end
    end

    local inset = CreateFrame("Frame", nil, button)
    inset:SetPoint("TOPLEFT", 2, -2)
    inset:SetPoint("BOTTOMRIGHT", -2, 2)
    inset:SetFrameLevel(button:GetFrameLevel())
    local bg = inset:CreateTexture(nil, "BACKGROUND", nil, -6)
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    if PP.CreateBorder then
        PP.CreateBorder(inset, 1, 1, 1, RS.BRD_ALPHA, 1, "OVERLAY", 7)
    end
    local hl = button:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(inset)
    hl:SetColorTexture(1, 1, 1, 0.1)
    local fs = button:GetFontString()
    if fs then
        local euiFont = EUI.GetFontPath and EUI.GetFontPath("blizzardSkin") or nil
        local _, size, flags = fs:GetFont()
        fs:SetFont(euiFont or "Fonts\\FRIZQT__.TTF", (size or 14) - 2, flags or "")
    end
end

-- Mirrors the skinning ElvUI applies to its own standalone game menu button
-- (Misc.lua GameMenuInitButtons). Pool buttons aren't the only ones it handles;
-- it also skins menu.ElvUI directly using the same S:HandleButton call.
local function ApplyElvUISkin(button)
    if not _G.ElvUI then return end
    local E = _G.ElvUI[1]
    if not E then return end
    if not (E.private and E.private.skins and E.private.skins.blizzard
            and E.private.skins.blizzard.enable and E.private.skins.blizzard.misc) then return end
    if E.OtherAddons and E.OtherAddons.ConsolePort then return end
    local S = E:GetModule('Skins')
    if not S then return end
    S:HandleButton(button, nil, nil, nil, true)
    if button.backdrop then button.backdrop:SetInside(nil, 1, 1) end
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

    ApplyEllesmereUISkin(button)
    ApplyElvUISkin(button)
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
    -- Defer so our Layout hook fires after any addon (e.g. EllesmereUI) that
    -- hooked Layout synchronously at PLAYER_LOGIN. Those addons may resize
    -- GameMenuFrame without knowing about our standalone button; we extend
    -- the height to cover the overflow.
    C_Timer.After(0, function()
        hooksecurefunc(GameMenuFrame, "Layout", function()
            local btn = rawget(_G, "HorizonSuiteGameMenuButton")
            if not btn or not btn:IsShown() then return end
            -- Our button causes Layout to shift pool buttons further down than
            -- third-party skinners account for when they resize the frame with
            -- a fixed extraH. Check all visible children for clipping, not just
            -- our own button (which stays inside the frame).
            local frameBottom = GameMenuFrame:GetBottom()
            if not frameBottom then return end
            local overflow = 0
            for _, child in ipairs({ GameMenuFrame:GetChildren() }) do
                if child:IsShown() and child:GetHeight() > 10 then
                    local cB = child:GetBottom()
                    if cB and cB < frameBottom - 1 then
                        local deficit = frameBottom - cB
                        if deficit > overflow then overflow = deficit end
                    end
                end
            end
            if overflow > 0 then
                GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + overflow + 28)
            end
        end)
    end)
    GameMenuFrame:HookScript("OnShow", function()
        -- Defer one frame so all other addons' OnShow/Layout hooks complete
        -- before we create or reposition our button.
        C_Timer.After(0, function()
            CreateButton()
            PositionButton()
        end)
    end)
end)
