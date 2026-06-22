--[[
    Horizon Suite - Augment / Alerts - Option defaults and limits
    Populates addon.AUGMENT_DEFAULTS and addon.AUGMENT_LIMITS for the Alerts
    mini-module. Loaded before OptionsDefaultsAugment.lua.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.AUGMENT_DEFAULTS = addon.AUGMENT_DEFAULTS or {}
addon.AUGMENT_LIMITS   = addon.AUGMENT_LIMITS   or {}

local D   = addon.AUGMENT_DEFAULTS
local LIM = addon.AUGMENT_LIMITS

-- Alerts mini-module master switch (pill)
D.augmentAlertsEnabled        = true

-- Per-kind toggles. All default off: the engine and all five kinds are
-- fully wired up, but none has been verified in-game yet (no live test pass
-- has been done on this branch). Flip a kind on here once it's been
-- confirmed working, rather than shipping it live to every profile by default.
D.alertsDurabilityEnabled     = false
D.alertsDurabilityThreshold   = 30
D.alertsBagsEnabled           = false
D.alertsBagsThreshold         = 90
D.alertsMailEnabled           = false
D.alertsVaultEnabled          = false
D.alertsFriendsEnabled        = false

-- Sound
D.alertsSoundEnabled          = true
D.alertsSoundCooldown         = 4

-- Display
D.alertsMaxVisible            = 3
D.alertsScale                 = 1.0
D.alertsFontPath              = "__global__"
D.alertsEditModeShow          = true

-- Position keys (alertsPoint/alertsRelPoint/alertsX/alertsY) have no
-- meaningful default — nil means "use A.DEFAULT_ANCHOR/X/Y".

-- Debug
D.alertsDebugLive             = false

-- Limits
LIM.alertsDurabilityThreshold = { min = 5,   max = 90  }
LIM.alertsBagsThreshold       = { min = 50,  max = 100 }
LIM.alertsSoundCooldown       = { min = 0,   max = 30  }
LIM.alertsMaxVisible          = { min = 1,   max = 6   }
LIM.alertsScale               = { min = 0.5, max = 2.0 }
