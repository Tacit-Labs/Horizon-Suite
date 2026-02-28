--[[
    Horizon Suite - Yield - Blizzard Suppression
    Suppress Blizzard loot/money/currency toasts and epic/legendary popups.
    Scope: loot and money only; does not affect Presence (zone text, achievements, etc).
    Idempotent: safe to call SuppressBlizzard/RestoreBlizzard multiple times.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.Yield then return end

local Y = addon.Yield

local hiddenParent = CreateFrame("Frame")
hiddenParent:Hide()

local popupKillTicker

local function KillBlizzardFrame(frame)
    if not frame then return end
    pcall(function()
        if frame.UnregisterAllEvents then frame:UnregisterAllEvents() end
        frame:SetParent(hiddenParent)
        frame:Hide()
        frame:SetAlpha(0)
    end)
    pcall(function()
        if frame.SetScript then
            frame:SetScript("OnShow", function(self)
                self:Hide()
            end)
        end
    end)
end

function Y.KillDynamicItemRevealPopup()
    pcall(function()
        if not UIParent or not UIParent.GetChildren then return end
        for _, frame in ipairs({ UIParent:GetChildren() }) do
            if frame and frame.GetFrameStrata and frame:GetFrameStrata() == "FULLSCREEN_DIALOG" then
                for _, sub in ipairs({ frame:GetChildren() }) do
                    if sub and sub.GetName and sub:GetName() == "ItemName" then
                        KillBlizzardFrame(frame)
                        break
                    end
                end
            end
        end
    end)
end

local function SuppressAlertSystem(system)
    if not system then return end
    pcall(function()
        if system.SetEnabled then
            system:SetEnabled(false)
        end
    end)
end

function Y.SuppressBlizzard()
    SuppressAlertSystem(LootAlertSystem)
    SuppressAlertSystem(LootUpgradeAlertSystem)
    SuppressAlertSystem(MoneyWonAlertSystem)
    SuppressAlertSystem(LootWonAlertSystem)

    KillBlizzardFrame(LootFrame)
    KillBlizzardFrame(LootAlertFrame)
    KillBlizzardFrame(MoneyWonAlertFrame)
    KillBlizzardFrame(LootUpgradeAlertFrame)
    KillBlizzardFrame(LootWonAlertFrame)

    pcall(function()
        if AlertFrame and AlertFrame.GetChildren then
            for _, child in ipairs({ AlertFrame:GetChildren() }) do
                local name = child and child.GetName and child:GetName()
                if name and (name:match("Loot") or name:match("MoneyWon")) then
                    KillBlizzardFrame(child)
                end
            end
        end
    end)

    Y.KillDynamicItemRevealPopup()
    if not popupKillTicker and C_Timer and C_Timer.NewTicker then
        popupKillTicker = C_Timer.NewTicker(0.5, function()
            Y.KillDynamicItemRevealPopup()
        end)
    end
end

function Y.RestoreBlizzard()
    pcall(function()
        if LootAlertSystem and LootAlertSystem.SetEnabled then
            LootAlertSystem:SetEnabled(true)
        end
        if LootUpgradeAlertSystem and LootUpgradeAlertSystem.SetEnabled then
            LootUpgradeAlertSystem:SetEnabled(true)
        end
        if MoneyWonAlertSystem and MoneyWonAlertSystem.SetEnabled then
            MoneyWonAlertSystem:SetEnabled(true)
        end
        if LootWonAlertSystem and LootWonAlertSystem.SetEnabled then
            LootWonAlertSystem:SetEnabled(true)
        end
    end)

    if popupKillTicker and popupKillTicker.Cancel then
        popupKillTicker:Cancel()
        popupKillTicker = nil
    end
end
