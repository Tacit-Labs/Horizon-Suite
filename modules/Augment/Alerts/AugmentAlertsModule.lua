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
