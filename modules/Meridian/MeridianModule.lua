--[[
    Horizon Suite - Meridian - Module
    An info bar along the screen edge. Registers with addon:RegisterModule.
]]

local addon = _G.HorizonSuite
if not addon or not addon.RegisterModule then return end

addon:RegisterModule("meridian", {
    title       = "Horizon Meridian",
    description = "An info bar along the screen edge: time, gold, durability, mail and shortcuts into the rest of Horizon.",
    order       = 29,

    OnInit = function()
        -- Seed the clock and coordinate settings from Vista's, once per profile, so a player
        -- who chose 24-hour time on the minimap keeps it on the bar.
        if not addon.GetDB or not addon.SetDB then return end
        if addon.GetDB("meridianSeededFromVista", false) then return end
        addon.SetDB("meridianClockLocal", addon.GetDB("vistaTimeUseLocal", true))
        addon.SetDB("meridianClock24Hour", addon.GetDB("vistaTime24Hour", false))
        addon.SetDB("meridianCoordPrecision", addon.GetDB("vistaCoordPrecision", 1))
        addon.SetDB("meridianSeededFromVista", true)
    end,

    OnEnable = function()
        if addon.Meridian and addon.Meridian.Bar then addon.Meridian.Bar.Enable() end
    end,

    OnDisable = function()
        if addon.Meridian and addon.Meridian.Bar then addon.Meridian.Bar.Disable() end
    end,
})
