--[[
    Horizon Suite - Cache Module
    Cinematic loot notifications (items, money, currency, reputation). Registers with addon:RegisterModule.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

addon:RegisterModule("cache", {
    title       = "Cache",
    description = "Cinematic loot notifications (items, money, currency, reputation).",
    order       = 30,

    OnInit = function()
        -- Frame/pool created at load in CacheCore; no extra init needed
    end,

    OnEnable = function()
        if addon.Cache then
            if addon.Cache.EnableEvents then addon.Cache.EnableEvents() end
            if addon.Cache.SuppressBlizzard then addon.Cache.SuppressBlizzard() end
            if addon.Cache.SetFrameVisible then addon.Cache.SetFrameVisible(true) end
            if addon.Cache.RestoreSavedPosition then addon.Cache.RestoreSavedPosition() end
            if addon.Cache.ApplyCacheClassChrome then addon.Cache.ApplyCacheClassChrome() end
        end
    end,

    OnDisable = function()
        if addon.Cache then
            if addon.Cache.DisableEvents then addon.Cache.DisableEvents() end
            if addon.Cache.RestoreBlizzard then addon.Cache.RestoreBlizzard() end
            if addon.Cache.ClearActiveToasts then addon.Cache.ClearActiveToasts() end
            if addon.Cache.SetFrameVisible then addon.Cache.SetFrameVisible(false) end
            if addon.Cache.HideAnchorFrame then addon.Cache.HideAnchorFrame() end
        end
        -- Reload is handled by addon:SetModuleEnabled (immediate or user-chosen when dashboard defers).
    end,
})
