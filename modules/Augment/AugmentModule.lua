--[[
    Horizon Suite - Augment Module
    Cinematic loot notifications (items, money, currency, reputation). Registers with addon:RegisterModule.
]]

local addon = _G.HorizonSuite
if not addon or not addon.RegisterModule then return end

addon:RegisterModule("augment", {
    title       = "Augment",
    description = "Cinematic loot notifications (items, money, currency, reputation).",
    order       = 30,

    OnInit = function()
    end,

    OnEnable = function()
        if addon.Augment then
            if addon.Augment.InitFrames then addon.Augment.InitFrames() end
            if addon.Augment.EnableEvents then addon.Augment.EnableEvents() end
            if addon.Augment.ApplyBlizzardSuppression then addon.Augment.ApplyBlizzardSuppression() end
            if addon.Augment.SetFrameVisible then addon.Augment.SetFrameVisible(true) end
            if addon.Augment.RestoreSavedPosition then addon.Augment.RestoreSavedPosition() end
            if addon.Augment.ApplyAugmentClassChrome then addon.Augment.ApplyAugmentClassChrome() end
        end
    end,

    OnDisable = function()
        if addon.Augment then
            if addon.Augment.DisableEvents then addon.Augment.DisableEvents() end
            if addon.Augment.RestoreBlizzard then addon.Augment.RestoreBlizzard() end
            if addon.Augment.ClearActiveToasts then addon.Augment.ClearActiveToasts() end
            if addon.Augment.SetFrameVisible then addon.Augment.SetFrameVisible(false) end
            if addon.Augment.HideAnchorFrame then addon.Augment.HideAnchorFrame() end
        end
        -- Reload is handled by addon:SetModuleEnabled (immediate or user-chosen when dashboard defers).
    end,
})
