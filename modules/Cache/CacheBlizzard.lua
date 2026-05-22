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
-- Handles non-AlertFrame popup paths (ContainerOpeningUI, ItemDisplay.xml-style popups).
-- AlertFrame-based toasts are suppressed earlier by InstallAlertShowHook.
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
                    -- "ItemName", "Item*" — ItemDisplay.xml style
                    -- "lootItem"          — AlertFrameSystems.xml bonus-loot style
                    if name and (name == "ItemName" or name == "lootItem" or name:find("^Item")) then
                        KillBlizzardFrame(frame)
                        break
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

-- Per-hook guard flags — separate so a nil global for one hook doesn't block the other.
local alertRegHookInstalled     = false  -- AlertFrame_RegisterQueuedAlertSystem
local alertAnchorsHookInstalled = false  -- AlertFrame:UpdateAnchors
local alertShowHookInstalled    = false  -- AlertFrame_ShowNewAlertFrame
local alertReregHookInstalled   = false  -- AlertFrame:RegisterEvent re-block

-- Events that drive AlertFrame's loot/bonus-loot toast systems.
-- Unregistering these from AlertFrame prevents it from ever creating toast frames
-- in the first place — the same approach used by Plumber's loot suppression.
local ALERT_FRAME_EVENTS = {
    -- Standard loot toasts
    "SHOW_LOOT_TOAST",
    "SHOW_LOOT_TOAST_UPGRADE",
    "SHOW_LOOT_TOAST_LEGENDARY_LOOTED",
    "LOOT_ITEM_ROLL_WON",
    "BONUS_LOOT_ITEM_RECEIVED",
    -- PvP loot
    "SHOW_PVP_FACTION_LOOT_TOAST",
    "SHOW_RATED_PVP_REWARD_TOAST",
    -- Quest / scenario loot
    "QUEST_LOOT_RECEIVED",
    "SCENARIO_COMPLETED",
    -- Specialised loot toasts
    "AZERITE_EMPOWERED_ITEM_LOOTED",
    "PERKS_PROGRAM_CURRENCY_AWARDED",
    -- Housing
    "INITIATIVE_TASK_COMPLETED",
    -- TWW warband-bank item push (newer; safe to list even if absent on older clients)
    "HOME_DECORATION_ADDED",
    "SHOW_LOOT_TOAST_ITEM_PUSH",
}

-- Track which events we successfully unregistered so RestoreBlizzard only
-- re-registers ones it actually removed (avoids double-registering).
local unregisteredAlertEvents = {}

local function IsLootAlertFrame(alertFrame)
    if not alertFrame then return false end
    -- Check the frame's own global name first (covers pool frames that do have names).
    local frameName = alertFrame.GetName and alertFrame:GetName()
    if frameName then
        local nl = frameName:lower()
        if nl:find("loot") or nl:find("moneywon") or nl:find("housing")
           or nl:find("decoration") or nl:find("itempush")
        then
            return true
        end
    end
    if not alertFrame.GetChildren then return false end
    for _, child in ipairs({ alertFrame:GetChildren() }) do
        local name = child and child.GetName and child:GetName()
        if name and (name == "ItemName" or name == "lootItem"
            or name:find("^Item") or name:lower():find("loot")
            or name:lower():find("housing") or name:lower():find("decoration"))
        then
            return true
        end
    end
    return false
end

local function InstallAlertShowHook()
    if alertShowHookInstalled then return end
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
        alertShowHookInstalled = true
    end)
end

local function InstallAlertHook()
    -- Suppress any alert system that registers lazily after our initial pass.
    if not alertRegHookInstalled then
        pcall(function()
            if not AlertFrame_RegisterQueuedAlertSystem then return end
            hooksecurefunc("AlertFrame_RegisterQueuedAlertSystem", function(system)
                if addon:IsModuleEnabled("cache")
                    and addon.GetDB and addon.GetDB("cacheSuppressBlizzard", true)
                then
                    SuppressAlertSystem(system)
                end
            end)
            alertRegHookInstalled = true
        end)
    end

    -- AlertFrame:UpdateAnchors is called every time it positions a new alert frame.
    -- Hooking it lets us kill pool frames (which have no global name) the moment
    -- AlertFrame tries to lay them out — proactive rather than reactive.
    if not alertAnchorsHookInstalled then
        pcall(function()
            if not (AlertFrame and AlertFrame.UpdateAnchors) then return end
            hooksecurefunc(AlertFrame, "UpdateAnchors", function()
                if not (addon:IsModuleEnabled("cache")
                    and addon.GetDB and addon.GetDB("cacheSuppressBlizzard", true))
                then return end
                pcall(function()
                    if not UIParent or not UIParent.GetChildren then return end
                    for _, frame in ipairs({ UIParent:GetChildren() }) do
                        if frame and frame.GetNumPoints then
                            for p = 1, frame:GetNumPoints() do
                                local ok, _, relativeTo = pcall(frame.GetPoint, frame, p)
                                if ok and relativeTo == AlertFrame then
                                    KillBlizzardFrame(frame)
                                    break
                                end
                            end
                        end
                    end
                end)
            end)
            alertAnchorsHookInstalled = true
        end)
    end
end

function Y.SuppressBlizzard()
    -- Unregister loot events from AlertFrame so it never creates toast frames.
    -- This is the root-cause fix: Blizzard's AlertFrame processes SHOW_LOOT_TOAST
    -- synchronously, creating and showing frames before any post-hook can react.
    -- Removing the event registration prevents that entire path from running.
    pcall(function()
        if AlertFrame and AlertFrame.UnregisterEvent then
            for _, event in ipairs(ALERT_FRAME_EVENTS) do
                if AlertFrame:IsEventRegistered(event) then
                    AlertFrame:UnregisterEvent(event)
                    unregisteredAlertEvents[event] = true
                end
            end
        end
    end)

    InstallAlertHook()
    InstallAlertShowHook()

    -- Prevent AlertFrame from re-registering blacklisted events after our initial sweep.
    -- Blizzard lazily loads some subsystems mid-session; this mirrors LS Toasts' approach.
    if not alertReregHookInstalled then
        pcall(function()
            if not (AlertFrame and AlertFrame.RegisterEvent) then return end
            hooksecurefunc(AlertFrame, "RegisterEvent", function(self, event)
                if unregisteredAlertEvents[event] then
                    self:UnregisterEvent(event)
                end
            end)
            alertReregHookInstalled = true
        end)
    end

    -- Suppress housing item toast fired via EventRegistry (not AlertFrame).
    -- EventRegistry:UnregisterFrameEvent removes frame-based listeners;
    -- nil-ing callback tables removes all Lua-side handlers for the event.
    -- Mirrors the approach used by LS Toasts for NEW_HOUSING_ITEM_ACQUIRED.
    pcall(function()
        if not EventRegistry then return end
        if EventRegistry.UnregisterFrameEvent then
            EventRegistry:UnregisterFrameEvent("NEW_HOUSING_ITEM_ACQUIRED")
        end
        if EventRegistry.GetCallbackTables then
            for _, tbl in ipairs(EventRegistry:GetCallbackTables()) do
                tbl["NEW_HOUSING_ITEM_ACQUIRED"] = nil
            end
        end
    end)

    -- Known systems by global name
    SuppressAlertSystem(LootAlertSystem)
    SuppressAlertSystem(LootUpgradeAlertSystem)
    SuppressAlertSystem(MoneyWonAlertSystem)
    SuppressAlertSystem(LootWonAlertSystem)
    SuppressAlertSystem(BonusRollLootWonAlertSystem)
    -- TWW housing / warband-bank item push systems (may not exist on all client versions).
    pcall(function()
        if _G.PlayerHousingItemAlertSystem then SuppressAlertSystem(_G.PlayerHousingItemAlertSystem) end
        if _G.ItemPushAlertSystem          then SuppressAlertSystem(_G.ItemPushAlertSystem)          end
        if _G.PlayerHousingItemAlertFrame  then KillBlizzardFrame(_G.PlayerHousingItemAlertFrame)    end
        if _G.ItemPushAlertFrame           then KillBlizzardFrame(_G.ItemPushAlertFrame)             end
    end)

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
                if name and (name:match("Loot") or name:match("MoneyWon")
                    or name:match("Housing") or name:match("ItemPush") or name:match("PvP")) then
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
    -- Re-register the loot events we removed from AlertFrame.
    pcall(function()
        if AlertFrame and AlertFrame.RegisterEvent then
            for event in pairs(unregisteredAlertEvents) do
                pcall(function() AlertFrame:RegisterEvent(event) end)
            end
        end
    end)
    unregisteredAlertEvents = {}

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
