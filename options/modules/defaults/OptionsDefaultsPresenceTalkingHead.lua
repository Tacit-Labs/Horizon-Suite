--[[
    Horizon Suite - Presence Talking Head - Option defaults and limits
    Loaded before PresenceTalkingHead.lua so the runtime module can reference
    addon.TALKING_HEAD_DEFAULTS directly instead of owning the table itself.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.TALKING_HEAD_DEFAULTS = {
    talkingHeadEnabled            = true,
    talkingHeadCustomise          = true,
    talkingHeadShowPortrait       = true,
    talkingHeadShowPortraitBorder = true,
    talkingHeadBackground         = false,
    talkingHeadCloseButton        = false,
    talkingHeadMuteVoice          = false,
    talkingHeadScale              = 1.0,
    talkingHeadNameSize           = 16,
    talkingHeadNameOutline        = true,
    talkingHeadNameColorR         = 0.55,
    talkingHeadNameColorG         = 0.65,
    talkingHeadNameColorB         = 0.75,
    talkingHeadTextSize           = 14,
    talkingHeadTextOutline        = true,
}

addon.TALKING_HEAD_LIMITS = {
    talkingHeadNameSize = { min = 10,  max = 24  },
    talkingHeadTextSize = { min = 10,  max = 20  },
    talkingHeadScale    = { min = 0.5, max = 2.0 },
}
