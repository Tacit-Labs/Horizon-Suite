--[[
    Horizon Suite - Augment / Loot Roll - Option defaults and limits
    Populates addon.AUGMENT_DEFAULTS and addon.AUGMENT_LIMITS for the loot roll
    mini-module. Loaded before OptionsDefaultsAugment.lua.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.AUGMENT_DEFAULTS = addon.AUGMENT_DEFAULTS or {}
addon.AUGMENT_LIMITS   = addon.AUGMENT_LIMITS   or {}

local D   = addon.AUGMENT_DEFAULTS
local LIM = addon.AUGMENT_LIMITS

-- Mini-module master switch (pill).
--
-- Ships OFF, following the precedent set by Alerts in
-- OptionsDefaultsAugmentAlerts.lua: the engine is fully wired but nothing here
-- has been seen roll in a real group yet, on either client.
--
-- The stakes are higher here than for a status toast. These frames suppress
-- Blizzard's own roll frame, and a roll you cannot see is a roll you lose. It
-- goes on by default in a follow-up, once the live pass on Retail and Forever
-- says it works.
D.augmentLootRollEnabled       = false

-- Display
D.lootRollScale                = 1.0
D.lootRollOpacity              = 100
D.lootRollToastStyle           = "framed"
D.lootRollFontPath             = "__global__"
D.lootRollFontSize             = 13
D.lootRollTextOutlineType      = "OUTLINE"
D.lootRollIconSize             = 40
D.lootRollIconGap              = 10
D.lootRollIconSide             = "left"
D.lootRollGrowDirection        = "down"
D.lootRollMaxVisible           = 4
-- Wide enough for the badge strip and the tally side by side at the default
-- font; the first live look at 330 truncated both, and the item name too.
D.lootRollWidth                = 420

-- Content. The quality floor draws nothing AND suppresses nothing below it, so
-- a filtered roll still gets Blizzard's frame rather than vanishing. Default 0
-- means every roll gets a Horizon frame.
D.lootRollMinQuality           = 0
D.lootRollShowTally            = true
D.lootRollShowBadgeAppearance  = true
D.lootRollShowBadgeItemLevel   = true
D.lootRollShowBadgeBind        = true

D.lootRollEditModeShow         = true
D.lootRollDebugLive            = false

-- Position keys (lootRollPoint/lootRollRelPoint/lootRollX/lootRollY) have no
-- meaningful default — nil means "use R.DEFAULT_ANCHOR/X/Y".

-- Limits
LIM.lootRollScale       = { min = 0.5, max = 2.0 }
LIM.lootRollOpacity     = { min = 10,  max = 100 }
LIM.lootRollFontSize    = { min = 8,   max = 20  }
LIM.lootRollIconSize    = { min = 16,  max = 64  }
LIM.lootRollIconGap     = { min = 0,   max = 32  }
LIM.lootRollMaxVisible  = { min = 1,   max = 4   }
LIM.lootRollWidth       = { min = 280, max = 640 }
LIM.lootRollMinQuality  = { min = 0,   max = 5   }
