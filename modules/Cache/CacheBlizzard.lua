--[[
    Horizon Suite - Cache - Blizzard Suppression
    Suppress Blizzard loot/money/currency toasts and epic/legendary popups.
    Scope: loot and money only; does not affect Presence (zone text, achievements, etc).
    Idempotent: safe to call SuppressBlizzard/RestoreBlizzard multiple times.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Cache then return end

local Y = addon.Cache

local hiddenParent = CreateFrame("Frame")
hiddenParent:Hide()

-- Track original parents so RestoreBlizzard can fully undo the suppression.
local killedFrames = {}

local function KillBlizzardFrame(frame)
    if not frame then return end
    if killedFrames[frame] then return end  -- already killed; don't double-record
    local originalParent = frame:GetParent()
    killedFrames[frame] = { parent = originalParent or UIParent }
    pcall(function()
        frame:SetParent(hiddenParent)
        frame:Hide()
        frame:SetAlpha(0)
    end)
    -- Patch OnShow so any Blizzard-internal Show() call is a no-op while suppressed.
    pcall(function()
        if frame.SetScript then
            frame:SetScript("OnShow", function(self) self:Hide() end)
        end
    end)
end

local function RestoreBlizzardFrame(frame, info)
    if not frame then return end
    pcall(function()
        frame:SetParent(info.parent or UIParent)
        frame:SetAlpha(1)
        -- Remove our auto-hide patch so Blizzard's own logic can show the frame again.
        if frame.SetScript then
            frame:SetScript("OnShow", nil)
        end
    end)
end

-- Strata levels where item-reveal popups may appear (varies by WoW version/context).
local POPUP_STRATA = { FULLSCREEN_DIALOG = true, DIALOG = true, FULLSCREEN = true }

-- KillDynamicItemRevealPopup is called after SHOW_LOOT_TOAST* events.
-- Scans UIParent children at elevated strata for item reveal popups and
-- explicitly suppresses ContainerOpeningUI (Delve/reward cache opening frame).
function Y.KillDynamicItemRevealPopup()
    pcall(function()
        -- Reward cache opening frame (Delve Bountiful Chest, etc.)
        if ContainerOpeningUI then KillBlizzardFrame(ContainerOpeningUI) end

        if not UIParent or not UIParent.GetChildren then return end
        for _, frame in ipairs({ UIParent:GetChildren() }) do
            if frame and frame.GetFrameStrata and POPUP_STRATA[frame:GetFrameStrata()] then
                local children = frame.GetChildren and { frame:GetChildren() } or {}
                for _, sub in ipairs(children) do
                    local name = sub and sub.GetName and sub:GetName()
                    -- Match "ItemName", "ItemButton", "Item" child patterns used across
                    -- different WoW versions for item reveal popups.
                    if name and (name == "ItemName" or name:find("^Item")) then
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
        if system.SetEnabled then system:SetEnabled(false) end
    end)
end

local function RestoreAlertSystem(system)
    if not system then return end
    pcall(function()
        if system.SetEnabled then system:SetEnabled(true) end
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
    pcall(function() if ContainerOpeningUI then KillBlizzardFrame(ContainerOpeningUI) end end)

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
end

function Y.ApplyBlizzardSuppression()
    if addon.GetDB and addon.GetDB("cacheSuppressBlizzard", true) then
        Y.SuppressBlizzard()
    else
        Y.RestoreBlizzard()
    end
end

function Y.RestoreBlizzard()
    RestoreAlertSystem(LootAlertSystem)
    RestoreAlertSystem(LootUpgradeAlertSystem)
    RestoreAlertSystem(MoneyWonAlertSystem)
    RestoreAlertSystem(LootWonAlertSystem)

    for frame, info in pairs(killedFrames) do
        RestoreBlizzardFrame(frame, info)
    end
    killedFrames = {}
end
