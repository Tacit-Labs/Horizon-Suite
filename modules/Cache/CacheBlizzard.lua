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

-- KillDynamicItemRevealPopup is called by the rolling ticker after any loot/reward event.
-- Kills ContainerOpeningUI and any shown UIParent child at elevated strata that belongs
-- to the AlertFrame pool (identified by its anchor to AlertFrame — pool frames have no
-- global name so child-name checks don't work for them).
function Y.KillDynamicItemRevealPopup()
    pcall(function()
        -- Reward cache opening frame (Delve Bountiful Chest, etc.)
        if ContainerOpeningUI then KillBlizzardFrame(ContainerOpeningUI) end

        if not UIParent or not UIParent.GetChildren then return end
        for _, frame in ipairs({ UIParent:GetChildren() }) do
            if frame and frame.GetFrameStrata and POPUP_STRATA[frame:GetFrameStrata()]
                and frame.IsShown and frame:IsShown()
            then
                local killed = false
                -- AlertFrame pool frames (loot/money toasts) are anonymous — GetName()
                -- returns nil. Identify them by their SetPoint anchor to AlertFrame.
                if AlertFrame and frame.GetNumPoints then
                    for p = 1, frame:GetNumPoints() do
                        local ok, _, relativeTo = pcall(frame.GetPoint, frame, p)
                        if ok and relativeTo == AlertFrame then
                            KillBlizzardFrame(frame)
                            killed = true
                            break
                        end
                    end
                end
                -- Fallback: named frames whose children match Item*/lootItem patterns.
                -- "ItemName", "ItemButton", "Item*" — ItemDisplay.xml style
                -- "lootItem" — AlertFrameSystems.xml bonus-loot style
                if not killed then
                    local children = frame.GetChildren and { frame:GetChildren() } or {}
                    for _, sub in ipairs(children) do
                        local name = sub and sub.GetName and sub:GetName()
                        if name and (name == "ItemName" or name == "lootItem" or name:find("^Item")) then
                            KillBlizzardFrame(frame)
                            break
                        end
                    end
                end
            end
        end
    end)
end

-- All alert systems we have suppressed, keyed by system object.
-- Used by RestoreBlizzard to re-enable them without needing to know their names.
local suppressedSystems = {}

-- Tracks which systems already have the re-enablement hook installed
-- so we don't double-hook across multiple SuppressBlizzard calls.
local reenableGuard = {}

local function SuppressAlertSystem(system)
    if not system then return end
    pcall(function()
        if not system.SetEnabled then return end
        system:SetEnabled(false)
        suppressedSystems[system] = true
        -- Intercept any future SetEnabled(true) call Blizzard makes mid-session.
        -- The hook fires after the original; checking suppressedSystems[self] means
        -- we only fight back while suppression is active — RestoreBlizzard clears
        -- the table first so re-enablement during restore is never blocked.
        if not reenableGuard[system] then
            reenableGuard[system] = true
            hooksecurefunc(system, "SetEnabled", function(self, enabled)
                if enabled and suppressedSystems[self] then
                    self:SetEnabled(false)
                end
            end)
        end
    end)
end

-- Hook AlertFrame_RegisterQueuedAlertSystem once so any alert system that loads
-- lazily (e.g. from an addon that initialises after us) is suppressed automatically.
local alertHookInstalled = false

-- Hook AlertFrame_ShowNewAlertFrame so loot-type toasts are hidden the instant
-- Blizzard tries to display them — before the next render cycle.
-- This catches cases where SuppressAlertSystem loses the race (the system
-- re-enables itself synchronously inside SetEnabled, showing the frame before
-- our post-hook fires).
local alertShowHookInstalled = false

local function IsLootAlertFrame(alertFrame)
    if not alertFrame or not alertFrame.GetChildren then return false end
    for _, child in ipairs({ alertFrame:GetChildren() }) do
        -- Check child name patterns (loot/item toast structures)
        local name = child and child.GetName and child:GetName()
        if name and (name == "ItemName" or name == "lootItem"
            or name:find("^Item") or name:lower():find("loot"))
        then
            return true
        end
    end
    return false
end

local function InstallAlertShowHook()
    if alertShowHookInstalled then return end
    alertShowHookInstalled = true
    pcall(function()
        if not AlertFrame_ShowNewAlertFrame then return end
        hooksecurefunc("AlertFrame_ShowNewAlertFrame", function(alertFrame)
            if not alertFrame then return end
            if not addon:IsModuleEnabled("cache") then return end
            if not (addon.GetDB and addon.GetDB("cacheSuppressBlizzard", true)) then return end
            if IsLootAlertFrame(alertFrame) then
                alertFrame:Hide()
                alertFrame:SetAlpha(0)
            end
        end)
    end)
end

local function InstallAlertHook()
    if alertHookInstalled then return end
    alertHookInstalled = true

    -- Suppress any alert system that registers lazily after our initial pass.
    pcall(function()
        if AlertFrame_RegisterQueuedAlertSystem then
            hooksecurefunc("AlertFrame_RegisterQueuedAlertSystem", function(system)
                if addon:IsModuleEnabled("cache")
                    and addon.GetDB and addon.GetDB("cacheSuppressBlizzard", true)
                then
                    SuppressAlertSystem(system)
                end
            end)
        end
    end)

    -- AlertFrame:UpdateAnchors is called every time it positions a new alert frame.
    -- Hooking it lets us kill pool frames (which have no global name) the moment
    -- AlertFrame tries to lay them out — proactive rather than reactive.
    pcall(function()
        if AlertFrame and AlertFrame.UpdateAnchors then
            hooksecurefunc(AlertFrame, "UpdateAnchors", function()
                if not (addon:IsModuleEnabled("cache")
                    and addon.GetDB and addon.GetDB("cacheSuppressBlizzard", true))
                then return end
                pcall(function()
                    if not UIParent or not UIParent.GetChildren then return end
                    for _, frame in ipairs({ UIParent:GetChildren() }) do
                        if frame and frame.IsShown and frame:IsShown() and frame.GetNumPoints then
                            for p = 1, frame:GetNumPoints() do
                                local ok, _, relativeTo = pcall(frame.GetPoint, frame, p)
                                if ok and relativeTo == AlertFrame then
                                    frame:Hide()
                                    frame:SetAlpha(0)
                                    break
                                end
                            end
                        end
                    end
                end)
            end)
        end
    end)
end

function Y.SuppressBlizzard()
    InstallAlertHook()
    InstallAlertShowHook()

    -- Known systems by global name
    SuppressAlertSystem(LootAlertSystem)
    SuppressAlertSystem(LootUpgradeAlertSystem)
    SuppressAlertSystem(MoneyWonAlertSystem)
    SuppressAlertSystem(LootWonAlertSystem)
    SuppressAlertSystem(BonusRollLootWonAlertSystem)

    -- Sweep every system registered with AlertFrame — catches anything not covered above.
    pcall(function()
        if AlertFrame and AlertFrame.alertSystems then
            for _, system in ipairs(AlertFrame.alertSystems) do
                SuppressAlertSystem(system)
            end
        end
    end)

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
    -- Collect first, then clear the table before calling SetEnabled(true) so
    -- the re-enablement hooks installed by SuppressAlertSystem don't fight the restore.
    local toRestore = {}
    for system in pairs(suppressedSystems) do toRestore[#toRestore + 1] = system end
    suppressedSystems = {}
    for _, system in ipairs(toRestore) do
        pcall(function() if system.SetEnabled then system:SetEnabled(true) end end)
    end

    for frame, info in pairs(killedFrames) do
        RestoreBlizzardFrame(frame, info)
    end
    killedFrames = {}
end
