--[[
    Horizon Suite - Augment / SelfHighlight - Option defaults
    Populates addon.AUGMENT_DEFAULTS for the Self Highlight mini-module.
    Loaded before OptionsDefaultsAugment.lua.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.AUGMENT_DEFAULTS = addon.AUGMENT_DEFAULTS or {}

local D = addon.AUGMENT_DEFAULTS

-- Self Highlight mini-module master switch (pill)
D.augmentSelfHighlightEnabled = false

D.selfHighlightEnabled        = false
D.selfHighlightMode           = "outlinecircle"
D.selfHighlightHostile        = true
