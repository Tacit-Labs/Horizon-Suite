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
        if frame.UnregisterAllEvents then frame:UnregisterAllEvents() end
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

-- KillDynamicItemRevealPopup is called from ShowToast (CacheCore) at 0.1s and 0.4s
-- after any epic/legendary toast, so no persistent ticker is needed.
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
