--[[
    Horizon Suite - Augment / FlightTimer - Option defaults and limits
    Populates addon.AUGMENT_DEFAULTS and addon.AUGMENT_LIMITS for the
    FlightTimer mini-module.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.AUGMENT_DEFAULTS = addon.AUGMENT_DEFAULTS or {}
addon.AUGMENT_LIMITS   = addon.AUGMENT_LIMITS   or {}

local D   = addon.AUGMENT_DEFAULTS
local LIM = addon.AUGMENT_LIMITS

-- Master switch - off until verified in-game.
D.flightTimerEnabled = false

-- Behaviour
D.flightTimerCountUp       = true
D.flightTimerConfirmFlight = false
D.flightTimerChatLog       = true

-- Bar appearance
D.flightTimerLayout   = "normal"
D.flightTimerWidth    = 300
D.flightTimerHeight   = 14
D.flightTimerFontPath = "__global__"
D.flightTimerFontSize = 12

D.flightTimerBarColorR, D.flightTimerBarColorG, D.flightTimerBarColorB         = 0.5, 0.5, 0.8
D.flightTimerUnknownColorR, D.flightTimerUnknownColorG, D.flightTimerUnknownColorB = 0.2, 0.2, 0.4
D.flightTimerFontColorR, D.flightTimerFontColorG, D.flightTimerFontColorB      = 1.0, 1.0, 1.0

-- Limits
LIM.flightTimerWidth    = { min = 40,  max = 1000 }
LIM.flightTimerHeight   = { min = 4,   max = 150  }
LIM.flightTimerFontSize = { min = 4,   max = 30   }
