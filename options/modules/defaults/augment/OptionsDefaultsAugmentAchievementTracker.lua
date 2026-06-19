--[[
    Horizon Suite - Augment / AchievementTracker - Option defaults
    Populates addon.AUGMENT_DEFAULTS for the Achievement Tracker mini-module.
    Loaded before OptionsDefaultsAugment.lua.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.AUGMENT_DEFAULTS = addon.AUGMENT_DEFAULTS or {}

local D = addon.AUGMENT_DEFAULTS

-- Achievement Tracker mini-module master switch (pill)
D.augmentAchievementTrackerEnabled = false
