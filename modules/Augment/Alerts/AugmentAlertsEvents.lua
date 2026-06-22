--[[
    Horizon Suite - Augment / Alerts - Events
    Centralised event registration: each kind's event(s) are registered only
    while that kind is enabled, and explicitly unregistered the moment it's
    turned off (Roadmap §8.2 — "disabled module → event explicitly
    unregistered"). Baselines are taken on PLAYER_ENTERING_WORLD so the first
    delta-comparison after login/reload/zone never fires a false alert.
]]

local addon = _G.HorizonSuite
local Y = addon and addon.Augment
local A = Y and Y.Alerts
if not A then return end

addon.Log.registerTag("augmentAlerts", "alertsDebugLive")

local ev = CreateFrame("Frame")
local registered = false

local function regOptional(eventName, on)
    if on then
        pcall(ev.RegisterEvent, ev, eventName)
    else
        pcall(ev.UnregisterEvent, ev, eventName)
    end
end

-- Re-evaluate every kind's event registration against current DB flags. Safe
-- to call repeatedly (e.g. from the options page toggles) — RegisterEvent on
-- an already-registered event, or UnregisterEvent on one that isn't, are both no-ops.
function A.UpdateEventRegistrations()
    local D = addon.AUGMENT_DEFAULTS

    regOptional("UPDATE_INVENTORY_DURABILITY", A.GetDB("alertsDurabilityEnabled", D.alertsDurabilityEnabled))
    regOptional("BAG_UPDATE_DELAYED", A.GetDB("alertsBagsEnabled", D.alertsBagsEnabled))

    local mailOn = A.GetDB("alertsMailEnabled", D.alertsMailEnabled)
    regOptional("UPDATE_PENDING_MAIL", mailOn)
    regOptional("MAIL_INBOX_UPDATE", mailOn)

    regOptional("WEEKLY_REWARDS_UPDATE", A.GetDB("alertsVaultEnabled", D.alertsVaultEnabled))
    regOptional("FRIENDLIST_UPDATE", A.GetDB("alertsFriendsEnabled", D.alertsFriendsEnabled))
end

local function TakeAllBaselines()
    if A.Durability and A.Durability.SetBaseline then A.Durability.SetBaseline() end
    if A.Bags       and A.Bags.SetBaseline       then A.Bags.SetBaseline()       end
    if A.Mail       and A.Mail.SetBaseline       then A.Mail.SetBaseline()       end
    if A.Vault      and A.Vault.SetBaseline      then A.Vault.SetBaseline()      end
    if A.Friends    and A.Friends.SetBaseline    then A.Friends.SetBaseline()    end
end
A.TakeAllBaselines = TakeAllBaselines

ev:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        TakeAllBaselines()
        return
    end

    if event == "PLAYER_REGEN_ENABLED" then
        A.OnCombatEnd()
        return
    end

    if event == "UPDATE_INVENTORY_DURABILITY" then
        if A.Durability then A.Durability.CheckAndNotify() end
        return
    end

    if event == "BAG_UPDATE_DELAYED" then
        if A.Bags then A.Bags.CheckAndNotify() end
        return
    end

    if event == "UPDATE_PENDING_MAIL" or event == "MAIL_INBOX_UPDATE" then
        if A.Mail then A.Mail.CheckAndNotify() end
        return
    end

    if event == "WEEKLY_REWARDS_UPDATE" then
        if A.Vault then A.Vault.CheckAndNotify() end
        return
    end

    if event == "FRIENDLIST_UPDATE" then
        if A.Friends then A.Friends.HandleFriendListUpdate() end
        return
    end
end)

function A.EnableEvents()
    if registered then return end
    registered = true
    ev:RegisterEvent("PLAYER_ENTERING_WORLD")
    ev:RegisterEvent("PLAYER_REGEN_ENABLED")
    A.UpdateEventRegistrations()
    -- Also take an immediate baseline: PLAYER_ENTERING_WORLD already fired
    -- once this session if Alerts was only just turned on via the options page.
    TakeAllBaselines()
end

function A.DisableEvents()
    if not registered then return end
    registered = false
    ev:UnregisterAllEvents()
end
