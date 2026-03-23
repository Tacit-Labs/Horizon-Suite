--[[
    Horizon Suite - Horizon Persona Module
    Custom character sheet with 3D model, item level, stats, and gear grid.
    Registers with addon:RegisterModule.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.RegisterModule then return end

addon:RegisterModule("persona", {
    title       = "Horizon Persona",
    description = "Custom character sheet with 3D model, item level, secondary stats, and gear grid. Replaces the default character frame (C key).",
    order       = 27,

    OnEnable = function()
        if addon.Persona and addon.Persona.Init then
            addon.Persona.Init()
        end
    end,

    OnDisable = function()
        if addon.Persona and addon.Persona.Disable then
            addon.Persona.Disable()
        end
    end,
})
