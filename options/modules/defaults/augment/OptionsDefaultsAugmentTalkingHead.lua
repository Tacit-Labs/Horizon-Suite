--[[
    Horizon Suite - Augment / TalkingHead - Option defaults and limits
    Populates addon.AUGMENT_DEFAULTS and addon.AUGMENT_LIMITS for the Talking
    Head mini-module. Loaded before OptionsDefaultsAugment.lua.
    addon.TALKING_HEAD_DEFAULTS / LIMITS are kept as aliases so the runtime
    module (AugmentTalkingHead.lua) can still reference them by that name.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.AUGMENT_DEFAULTS = addon.AUGMENT_DEFAULTS or {}
addon.AUGMENT_LIMITS   = addon.AUGMENT_LIMITS   or {}

local D   = addon.AUGMENT_DEFAULTS
local LIM = addon.AUGMENT_LIMITS

-- Talking Head mini-module master switch (pill)
D.augmentTalkingHeadEnabled        = true

-- Behaviour
D.talkingHeadEnabled               = true
D.talkingHeadCustomise             = true
D.talkingHeadMuteVoice             = false

-- Frame
D.talkingHeadShowPortrait          = true
D.talkingHeadShowPortraitBorder    = true
D.talkingHeadBackground            = false
D.talkingHeadCloseButton           = false
D.talkingHeadScale                 = 1.0

-- Name typography
D.talkingHeadNameFontPath          = "__global__"
D.talkingHeadNameSize              = 16
D.talkingHeadNameOutline           = true
D.talkingHeadNameColorR            = 0.55
D.talkingHeadNameColorG            = 0.65
D.talkingHeadNameColorB            = 0.75

-- Dialogue typography
D.talkingHeadTextFontPath          = "__global__"
D.talkingHeadTextSize              = 14
D.talkingHeadTextOutline           = true

-- Limits
LIM.talkingHeadNameSize  = { min = 10,  max = 24  }
LIM.talkingHeadTextSize  = { min = 10,  max = 20  }
LIM.talkingHeadScale     = { min = 0.5, max = 2.0 }

-- Aliases so AugmentTalkingHead.lua can still use addon.TALKING_HEAD_DEFAULTS
addon.TALKING_HEAD_DEFAULTS = addon.AUGMENT_DEFAULTS
addon.TALKING_HEAD_LIMITS   = addon.AUGMENT_LIMITS
