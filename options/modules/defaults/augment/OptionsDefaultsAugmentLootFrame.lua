--[[
    Horizon Suite - Augment / LootFrame - Option defaults and limits
    Populates addon.AUGMENT_DEFAULTS and addon.AUGMENT_LIMITS for the Loot
    Frame mini-module. Loaded before OptionsDefaultsAugment.lua, which
    finalises AUGMENT_KEYS after all sub-module files have run.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.AUGMENT_DEFAULTS = addon.AUGMENT_DEFAULTS or {}
addon.AUGMENT_LIMITS   = addon.AUGMENT_LIMITS   or {}

local D   = addon.AUGMENT_DEFAULTS
local LIM = addon.AUGMENT_LIMITS

-- Loot Frame mini-module master switch
D.augmentLootFrameEnabled    = true

-- Toast appearance
D.augmentToastStyle          = "compact"
D.augmentFontPath            = "__global__"
D.augmentFontSize            = 14
D.augmentUIScale             = 1.0
D.augmentIconSize            = 34
D.augmentIconGap             = 10
D.augmentIconSide            = "left"
D.augmentSlideSide           = "right"
D.augmentGrowDirection       = "up"
D.augmentTextOutline         = true
D.augmentTextOutlineType     = "OUTLINE"
D.augmentToastOpacity        = 100
D.augmentMaxVisible          = 15

-- Visible toast types
D.augmentShowItems           = true
D.augmentShowPushedItems     = true
D.augmentShowMoney           = true
D.augmentShowCurrency        = true
D.augmentShowRep             = true
D.augmentMinQuality          = 0

-- Stacking / condensing
D.augmentStackDuplicates     = true
D.augmentStackCountBeforeName = false
D.augmentCondenseJunk        = true

-- Blizzard suppression
D.augmentSuppressBlizzard    = true

-- Hold durations (seconds)
D.augmentHoldItem            = 5.0
D.augmentHoldEpic            = 6.5
D.augmentHoldLegendary       = 8.0
D.augmentHoldMoney           = 3.0
D.augmentHoldCurrency        = 3.0
D.augmentHoldRep             = 3.0

-- Sound
D.augmentSoundEnabled        = true
D.augmentSoundChannel        = "SFX"
D.augmentSoundItems          = true
D.augmentSoundMoney          = false
D.augmentSoundCurrency       = false
D.augmentSoundRep            = false

-- Edit Mode HUD
D.augmentEditModeShow        = true

-- Limits
LIM.augmentToastOpacity      = { min = 10,  max = 100  }
LIM.augmentMaxVisible        = { min = 1,   max = 15   }
LIM.augmentUIScale           = { min = 0.5, max = 2.0  }
LIM.augmentIconSize          = { min = 8,   max = 64   }
LIM.augmentIconGap           = { min = 0,   max = 32   }
LIM.augmentFontSize          = { min = 8,   max = 20   }
LIM.augmentHoldItem          = { min = 1,   max = 12   }
LIM.augmentHoldEpic          = { min = 1,   max = 12   }
LIM.augmentHoldLegendary     = { min = 1,   max = 12   }
LIM.augmentHoldMoney         = { min = 1,   max = 12   }
LIM.augmentHoldCurrency      = { min = 1,   max = 12   }
LIM.augmentHoldRep           = { min = 1,   max = 12   }
