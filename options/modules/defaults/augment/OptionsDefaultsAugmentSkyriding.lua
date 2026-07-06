--[[
    Horizon Suite - Augment / Skyriding - Option defaults and limits
    Populates addon.AUGMENT_DEFAULTS and addon.AUGMENT_LIMITS for the
    Skyriding Vigor/Speed display mini-module.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.AUGMENT_DEFAULTS = addon.AUGMENT_DEFAULTS or {}
addon.AUGMENT_LIMITS   = addon.AUGMENT_LIMITS   or {}

local D   = addon.AUGMENT_DEFAULTS
local LIM = addon.AUGMENT_LIMITS

-- Master switch (pill). Defaults off — unlike Vendor/SelfHighlight this
-- replaces a native Blizzard frame and hasn't had in-game verification yet.
D.skyridingEnabled              = false
D.skyridingStyle                = "bar"  -- "bar" | "circular"
D.skyridingScale                = 1.0
D.skyridingEditModeShow         = true
D.skyridingHideWhenGroundedFull = false
D.skyridingShowSpeedText        = true
D.skyridingSoundEnabled         = true

-- Second Wind / Whirling Surge / Derby Racing — sub-toggles for an already
-- opted-in module default on, since the user already chose the replacement.
D.skyridingSecondWindEnabled       = true
D.skyridingWhirlingSurgeEnabled    = true
D.skyridingWhirlingSurgeVisibility = 3  -- 3 = always, 2 = only when ready, 1 = only while charging
D.skyridingDerbyEnabled            = true

-- Bar style
D.skyridingBarWidth        = 28
D.skyridingBarChargeHeight = 18
D.skyridingBarSpeedHeight  = 10
D.skyridingBarPadding      = 4
D.skyridingBarSwapPosition = false

-- Circular style
D.skyridingCircularSize = 64

-- Colours
D.skyridingBarChargeColorR, D.skyridingBarChargeColorG, D.skyridingBarChargeColorB = 0.25, 0.78, 1.0
D.skyridingBarSpeedLowColorR, D.skyridingBarSpeedLowColorG, D.skyridingBarSpeedLowColorB = 0.6, 0.6, 0.6
D.skyridingBarSpeedThrillColorR, D.skyridingBarSpeedThrillColorG, D.skyridingBarSpeedThrillColorB = 0.47, 0.97, 0.51
D.skyridingBarSpeedGroundSkimColorR, D.skyridingBarSpeedGroundSkimColorG, D.skyridingBarSpeedGroundSkimColorB = 0.90, 0.70, 0.20
D.skyridingSecondWindColorR, D.skyridingSecondWindColorG, D.skyridingSecondWindColorB = 0.85, 0.65, 0.95
D.skyridingCircularColorR, D.skyridingCircularColorG, D.skyridingCircularColorB = 0.25, 0.78, 1.0

-- Limits
LIM.skyridingScale          = { min = 0.5, max = 2.0 }
LIM.skyridingBarWidth        = { min = 12, max = 60 }
LIM.skyridingBarChargeHeight = { min = 8,  max = 40 }
LIM.skyridingBarSpeedHeight  = { min = 4,  max = 30 }
LIM.skyridingBarPadding      = { min = 0,  max = 20 }
LIM.skyridingCircularSize    = { min = 32, max = 160 }
