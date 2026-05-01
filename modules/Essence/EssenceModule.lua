--[[
    Horizon Suite - Horizon Essence Module
    Custom character sheet with 3D model, item level, stats, and gear grid.
    Registers with addon:RegisterModule.
]]

local addon = _G.HorizonSuite

addon:RegisterModule("essence", {
    title       = "Horizon Essence",
    description = "Custom character sheet with 3D model, item level, secondary stats, and gear grid. Replaces the default character frame (C key).",
    order       = 27,

    OnEnable = function()
        if addon.Essence and addon.Essence.Init then
            addon.Essence.Init()
        end
    end,

    OnDisable = function()
        if addon.Essence and addon.Essence.Disable then
            addon.Essence.Disable()
        end
    end,
})
