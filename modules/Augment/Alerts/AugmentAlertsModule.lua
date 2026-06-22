--[[
    Horizon Suite - Augment / Alerts - Module
    Enable/Disable surface called from AugmentModule.lua, mirroring the
    Vendor/SelfHighlight/AchievementTracker mini-modules' lifecycle.
]]

local addon = _G.HorizonSuite
local Y = addon and addon.Augment
local A = Y and Y.Alerts
if not A then return end

function A.Enable()
    A.InitFrames()
    A.RestoreSavedPosition()
    A.EnableEvents()
end

function A.Disable()
    A.DisableEvents()
    A.ClearActiveToasts()
end

-- Fires one sample toast per kind, bypassing each kind's own enabled flag.
-- Unlike Augment's loot-toast PreviewToasts() (AugmentSlash.lua), which only
-- previews already-enabled types, every Alerts kind ships disabled by
-- default (see OptionsDefaultsAugmentAlerts.lua) — the point here is to let
-- it be visually verified *before* anything is turned on, not after.
function A.PreviewAlerts()
    if not addon:IsModuleEnabled("augment") then
        if addon.HSPrint then addon.HSPrint("Augment: Module is disabled — enable it first.") end
        return
    end
    A.InitFrames()
    A.RestoreSavedPosition()

    local samples = {
        { "DURABILITY", addon.L["ALERTS_DURABILITY_TITLE"], string.format(addon.L["ALERTS_DURABILITY_BODY"], 25) },
        { "BAGS",       addon.L["ALERTS_BAGS_TITLE"],       string.format(addon.L["ALERTS_BAGS_BODY"], 95) },
        { "MAIL",       addon.L["ALERTS_MAIL_TITLE"],       addon.L["ALERTS_MAIL_BODY"] },
        { "VAULT",      addon.L["ALERTS_VAULT_TITLE"],      addon.L["ALERTS_VAULT_BODY"] },
        { "FRIEND_ON",  "Thrall",                           addon.L["ALERTS_FRIEND_ON_BODY"] },
    }

    for i, s in ipairs(samples) do
        C_Timer.After((i - 1) * 0.3, function()
            A.Enqueue(s[1], s[2], s[3])
        end)
    end
end
