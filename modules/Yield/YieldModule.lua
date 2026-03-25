--[[
    Horizon Suite - Yield Module
    Cinematic loot notifications (items, money, currency, reputation). Registers with addon:RegisterModule.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.RegisterModule then return end

addon:RegisterModule("yield", {
    title       = "Yield",
    description = "Cinematic loot notifications (items, money, currency, reputation).",
    order       = 30,

    OnInit = function()
        -- Frame/pool created at load in YieldCore; no extra init needed
    end,

    OnEnable = function()
        if addon.Yield then
            if addon.Yield.EnableEvents then addon.Yield.EnableEvents() end
            if addon.Yield.SuppressBlizzard then addon.Yield.SuppressBlizzard() end
            if addon.Yield.SetFrameVisible then addon.Yield.SetFrameVisible(true) end
            if addon.Yield.RestoreSavedPosition then addon.Yield.RestoreSavedPosition() end
            if addon.Yield.ApplyYieldClassChrome then addon.Yield.ApplyYieldClassChrome() end
        end
    end,

    OnDisable = function()
        if addon.Yield then
            if addon.Yield.DisableEvents then addon.Yield.DisableEvents() end
            if addon.Yield.RestoreBlizzard then addon.Yield.RestoreBlizzard() end
            if addon.Yield.ClearActiveToasts then addon.Yield.ClearActiveToasts() end
            if addon.Yield.SetFrameVisible then addon.Yield.SetFrameVisible(false) end
            if addon.Yield.HideAnchorFrame then addon.Yield.HideAnchorFrame() end
        end
        ReloadUI()
    end,
})
