--[[
    Horizon Suite - Augment / FlightTimer - Module
    Enable/Disable surface called from AugmentModule.lua, mirroring the
    Vendor/SelfHighlight/AchievementTracker mini-modules' lifecycle.
]]

local addon = _G.HorizonSuite
local Y = addon and addon.Augment
local F = Y and Y.FlightTimer
if not F then return end

function F.Enable()
    F.enabled = true
    F.EnableEvents()
end

function F.Disable()
    F.enabled = false
    F.DisableEvents()
end
