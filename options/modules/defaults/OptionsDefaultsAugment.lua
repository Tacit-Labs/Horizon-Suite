--[[
    Horizon Suite - Augment - Option defaults and SetDB routing keys
    AUGMENT_DEFAULTS: single source of truth for all loot toast option defaults.
    AUGMENT_KEYS: derived from AUGMENT_DEFAULTS plus anchor-position keys (no defaults).
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.AUGMENT_DEFAULTS = {
    augmentFontPath      = "__global__",
    augmentFontSize      = 16,
    augmentIconSize      = 34,
    augmentIconGap       = 10,
    augmentUIScale       = 1.0,
    augmentShowItems        = true,
    augmentShowPushedItems  = true,
    augmentShowMoney        = true,
    augmentShowCurrency     = true,
    augmentShowRep          = true,
    augmentMinQuality    = 0,
    augmentToastOpacity  = 100,
    augmentMaxVisible    = 15,
    augmentHoldItem      = 5.0,
    augmentHoldEpic      = 6.5,
    augmentHoldLegendary = 8.0,
    augmentHoldMoney     = 3.0,
    augmentHoldCurrency  = 3.0,
    augmentHoldRep       = 3.0,
    augmentTextOutline   = true,
    augmentSoundEnabled  = true,
    augmentSoundChannel  = "SFX",
    augmentSoundItems    = true,
    augmentSoundMoney    = false,
    augmentSoundCurrency = false,
    augmentSoundRep      = false,
    augmentSuppressBlizzard  = true,
    augmentStackDuplicates   = true,
    augmentStackCountBeforeName = false,
    augmentCondenseJunk      = true,
}

addon.AUGMENT_LIMITS = {
    augmentToastOpacity  = { min = 10,  max = 100  },
    augmentMaxVisible    = { min = 1,   max = 15   },
    augmentUIScale       = { min = 0.5, max = 2.0  },
    augmentHoldItem      = { min = 1,   max = 12   },
    augmentHoldEpic      = { min = 1,   max = 12   },
    augmentHoldLegendary = { min = 1,   max = 12   },
    augmentHoldMoney     = { min = 1,   max = 12   },
    augmentHoldCurrency  = { min = 1,   max = 12   },
    augmentHoldRep       = { min = 1,   max = 12   },
    augmentFontSize      = { min = 8,   max = 20   },
    augmentIconSize      = { min = 8,   max = 64   },
    augmentIconGap       = { min = 0,   max = 32   },
}

-- Position keys have no meaningful defaults (nil = use anchor frame position).
addon.AUGMENT_KEYS = { augmentPoint = true, augmentRelPoint = true, augmentX = true, augmentY = true }
for k in pairs(addon.AUGMENT_DEFAULTS) do addon.AUGMENT_KEYS[k] = true end
