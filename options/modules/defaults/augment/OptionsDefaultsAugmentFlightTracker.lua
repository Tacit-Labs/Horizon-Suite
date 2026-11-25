--[[
    Horizon Suite - Augment / Flight Tracker - Option defaults and limits
    Populates addon.AUGMENT_DEFAULTS and addon.AUGMENT_LIMITS for the flight
    tracker mini-module. Loaded before OptionsDefaultsAugment.lua.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.AUGMENT_DEFAULTS = addon.AUGMENT_DEFAULTS or {}
addon.AUGMENT_LIMITS   = addon.AUGMENT_LIMITS   or {}

local D   = addon.AUGMENT_DEFAULTS
local LIM = addon.AUGMENT_LIMITS

-- Mini-module master switch (pill). On: it only draws while you are on a
-- flight path and replaces nothing of Blizzard's, so there is nothing to lose
-- by having it on.
D.augmentFlightTrackerEnabled = true

-- What the banner shows
D.flightShowFlyingTo     = true
D.flightShowRoute        = true
D.flightShowStops        = true
D.flightShowOrigin       = true
D.flightShowTimeLeft     = true
D.flightArrivalNotice    = true

-- Look
D.flightScale            = 1.0
D.flightWidth            = 320
D.flightOpacity          = 100
D.flightBackground       = true
D.flightAccentBar        = true
D.flightAccentR          = 0.4
D.flightAccentG          = 0.8
D.flightAccentB          = 1.0

-- Text
D.flightFontPath         = "__global__"
D.flightFontSize         = 12
D.flightTextOutlineType  = "OUTLINE"
D.flightDestinationSize  = 20
D.flightTimeSize         = 15
D.flightArrivalSize      = 28

-- Position keys (flightPoint/flightRelPoint/flightX/flightY) default to nil,
-- meaning "use F.DEFAULT_ANCHOR/X/Y".

LIM.flightScale           = { min = 0.5, max = 2.0 }
LIM.flightWidth           = { min = 200, max = 520 }
LIM.flightOpacity         = { min = 20,  max = 100 }
LIM.flightFontSize        = { min = 8,   max = 20 }
LIM.flightDestinationSize = { min = 12,  max = 36 }
LIM.flightTimeSize        = { min = 10,  max = 28 }
LIM.flightArrivalSize     = { min = 16,  max = 48 }
