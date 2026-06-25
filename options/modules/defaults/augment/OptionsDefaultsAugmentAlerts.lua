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
D.alertsDurabilityReminder    = "threshold"
D.alertsBagsEnabled           = false
D.alertsBagsThreshold         = 90
D.alertsBagsReminder          = "threshold"
D.alertsMailEnabled           = false
D.alertsVaultEnabled          = false
D.alertsFriendsEnabled        = false

-- Sound. Channel default matches LootFrame's augmentSoundChannel ("SFX").
-- The per-kind toggles mute a single kind's sound independently of the
-- master alertsSoundEnabled switch; FRIEND_ON/FRIEND_OFF share one toggle.
D.alertsSoundEnabled          = false
D.alertsSoundCooldown         = 4
D.alertsSoundChannel          = "SFX"
D.alertsSoundDurability       = false
D.alertsSoundBags             = false
D.alertsSoundMail             = false
D.alertsSoundVault            = false
D.alertsSoundFriends          = false

-- Display
D.alertsMaxVisible            = 3
D.alertsScale                 = 1.0
D.alertsOpacity               = 100
D.alertsFontPath              = "__global__"
D.alertsFontSize              = 13
D.alertsHoldDuration          = 4.0
D.alertsEditModeShow          = true
D.alertsStyle                 = "horizon"
D.alertsTextOutlineType       = "OUTLINE"

-- Position keys (alertsPoint/alertsRelPoint/alertsX/alertsY) have no
-- meaningful default — nil means "use A.DEFAULT_ANCHOR/X/Y".

-- Per-kind colours. Values are the same accents the kinds shipped with
-- before they became user-configurable (see AugmentAlertsState.lua's
-- A.GetKindColor) — changing these only changes the fallback, not anyone's
-- already-saved colour.
D.alertsDurabilityColorR, D.alertsDurabilityColorG, D.alertsDurabilityColorB = 0.90, 0.30, 0.20
D.alertsBagsColorR,       D.alertsBagsColorG,       D.alertsBagsColorB       = 0.90, 0.70, 0.20
D.alertsMailColorR,       D.alertsMailColorG,       D.alertsMailColorB       = 0.30, 0.70, 1.00
D.alertsVaultColorR,      D.alertsVaultColorG,      D.alertsVaultColorB      = 0.65, 0.40, 0.95
D.alertsFriendOnColorR,   D.alertsFriendOnColorG,   D.alertsFriendOnColorB   = 0.20, 0.90, 0.30
D.alertsFriendOffColorR,  D.alertsFriendOffColorG,  D.alertsFriendOffColorB  = 0.60, 0.60, 0.60

-- Debug
D.alertsDebugLive             = false

-- Limits
LIM.alertsDurabilityThreshold = { min = 5,   max = 90  }
LIM.alertsBagsThreshold       = { min = 50,  max = 100 }
LIM.alertsSoundCooldown       = { min = 0,   max = 30  }
LIM.alertsMaxVisible          = { min = 1,   max = 6   }
LIM.alertsScale               = { min = 0.5, max = 2.0 }
LIM.alertsOpacity             = { min = 10,  max = 100 }
LIM.alertsFontSize            = { min = 8,   max = 20  }
LIM.alertsHoldDuration        = { min = 1,   max = 12  }
