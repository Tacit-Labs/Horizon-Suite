--[[
    Horizon Suite - Echo - Defaults
    ECHO_DEFAULTS for the settings Echo reads through Echo.Setting; ECHO_KEYS routes a change
    of any of them (options/OptionsData.lua) to Echo.ApplyOptions; ECHO_LIMITS bounds the
    sliders on the options page. echoX / echoY have no default: unset means the default corner.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.ECHO_DEFAULTS = {
    echoColumnEdge         = "right",
    echoLockPosition       = true,
    echoScale              = 1,
    echoFrameStrata        = "MEDIUM",
    echoMaxTiles           = 8,
    echoToastStyle         = "framed",
    echoToastSeconds       = 4,
    echoHoverDelay         = 0.35,
    echoHoldToastsInCombat = true,
    -- Tier per conversation type; mirrors Store.DEFAULT_TIERS.
    echoTierWhisper        = "loud",
    echoTierBnet           = "loud",
    echoTierParty          = "count",
    echoTierRaid           = "count",
    echoTierInstance       = "count",
    echoTierGuild          = "quiet",
    echoTierOfficer        = "quiet",
    echoTierChannel        = "quiet",
    echoTierLoot           = "quiet",
    echoTierProgress       = "quiet",
    echoTierSystem         = "quiet",
    echoKeywords           = "",
    echoFeedLoot           = true,
    echoFeedProgress       = true,
    echoFeedSystem         = true,
    echoSaveHistory        = true,
    echoHideStoredWhispers = false,
    echoCardWidth          = 360,
    echoCardHeight         = 440,
    echoFontPath           = "__global__",
}

addon.ECHO_LIMITS = {
    echoScale        = { min = 0.6, max = 1.6 },
    echoMaxTiles     = { min = 2,   max = 12 },
    echoToastSeconds = { min = 2,   max = 10 },
    echoCardWidth    = { min = 320, max = 520 },
    echoCardHeight   = { min = 320, max = 640 },
}

-- Every setting, plus the dragged position, re-applies Echo when it changes.
addon.ECHO_KEYS = { echoX = true, echoY = true }
for key in pairs(addon.ECHO_DEFAULTS) do addon.ECHO_KEYS[key] = true end
