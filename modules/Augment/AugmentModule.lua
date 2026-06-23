--[[
    Horizon Suite - Augment Module
    Cinematic loot notifications (items, money, currency, reputation). Registers with addon:RegisterModule.
]]

local addon = _G.HorizonSuite
if not addon or not addon.RegisterModule then return end

addon:RegisterModule("augment", {
    title       = "Augment",
    description = "Loot notifications, vendor automation, self-highlight, Talking Head customisation, and achievement tracking.",
    order       = 30,

    OnInit = function()
        if addon.Augment and addon.Augment.InitTalkingHead then
            addon.Augment.InitTalkingHead()
        end
    end,

    OnEnable = function()
        if addon.Augment then
            local GetDB = addon.GetDB
            local lootOn   = not GetDB or GetDB("augmentLootFrameEnabled",          true)  ~= false
            local vendorOn = not GetDB or GetDB("augmentVendorEnabled",            true)  ~= false
            local shOn     = not GetDB or GetDB("augmentSelfHighlightEnabled",     false) ~= false
            local atOn     = (not GetDB or GetDB("augmentAchievementTrackerEnabled", false) ~= false)
                             and not (addon.IsModuleEnabled and addon:IsModuleEnabled("focus"))
            local skyridingOn = not GetDB or GetDB("skyridingEnabled", false) ~= false
            if addon.Augment.InitFrames then addon.Augment.InitFrames() end
            -- Loot Frame mini-module: only register loot events + suppress Blizzard toasts when on.
            if lootOn then
                if addon.Augment.EnableEvents then addon.Augment.EnableEvents() end
                if addon.Augment.ApplyBlizzardSuppression then addon.Augment.ApplyBlizzardSuppression() end
            end
            if addon.Augment.SetFrameVisible then addon.Augment.SetFrameVisible(true) end
            if addon.Augment.RestoreSavedPosition then addon.Augment.RestoreSavedPosition() end
            if addon.Augment.ApplyAugmentClassChrome then addon.Augment.ApplyAugmentClassChrome() end
            if shOn and addon.Augment.SelfHighlight then addon.Augment.SelfHighlight.Enable() end
            if vendorOn and addon.Augment.Vendor then addon.Augment.Vendor.Enable() end
            -- Always call: UpdateTalkingHead self-gates on the pill and restores native when off.
            if addon.Augment.UpdateTalkingHead then addon.Augment.UpdateTalkingHead() end
            if atOn and addon.Augment.AchievementTracker then addon.Augment.AchievementTracker.Enable() end
            if skyridingOn and addon.Augment.Skyriding then addon.Augment.Skyriding.Enable() end
        end
    end,

    OnDisable = function()
        if addon.Augment then
            if addon.Augment.Vendor then addon.Augment.Vendor.Disable() end
            if addon.Augment.SelfHighlight then addon.Augment.SelfHighlight.Disable() end
            if addon.Augment.AchievementTracker then addon.Augment.AchievementTracker.Disable() end
            if addon.Augment.Skyriding then addon.Augment.Skyriding.Disable() end
            if addon.Augment.DisableTalkingHead then addon.Augment.DisableTalkingHead() end
            if addon.Augment.DisableEvents then addon.Augment.DisableEvents() end
            if addon.Augment.RestoreBlizzard then addon.Augment.RestoreBlizzard() end
            if addon.Augment.ClearActiveToasts then addon.Augment.ClearActiveToasts() end
            if addon.Augment.SetFrameVisible then addon.Augment.SetFrameVisible(false) end
            if addon.Augment.HideAnchorFrame then addon.Augment.HideAnchorFrame() end
        end
        -- Reload is handled by addon:SetModuleEnabled (immediate or user-chosen when dashboard defers).
    end,
})
