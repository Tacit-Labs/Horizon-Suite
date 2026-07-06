--[[
    Horizon Suite - Augment / Skyriding - Module
    Enable/Disable surface called from AugmentModule.lua, mirroring the
    Vendor/SelfHighlight/AchievementTracker/Alerts mini-modules' lifecycle.
]]

local addon = _G.HorizonSuite
local Y = addon and addon.Augment
local S = Y and Y.Skyriding
if not S then return end

function S.Enable()
    S.InitFrames()
    S.RestoreSavedPosition()
    S.ApplyActiveStyle()
    S.EnableEvents()
end

function S.Disable()
    S.DisableEvents()
    S.HideAnim()
end
