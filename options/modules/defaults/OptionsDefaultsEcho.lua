--[[
    Horizon Suite - Echo - Defaults
    ECHO_DEFAULTS for the settings Echo reads through Echo.Setting; ECHO_KEYS routes a change
    of any of them (options/OptionsData.lua) to Echo.ApplyOptions; ECHO_LIMITS bounds the
    sliders on the options page. echoX / echoY have no default: unset means the default corner.
]]
local addon = _G.HorizonSuite
if not addon then return end
local L = addon.L

-- Group 1's default name, localised. enUS.lua loads before this file in the TOC, so L is
-- normally populated; the literal is a defensive fallback for a load order that isn't.
local DEFAULT_GROUP_1_NAME = (L and L["ECHO_GROUP_CHANNELS"]) or "Channels"

addon.ECHO_DEFAULTS = {
    echoColumnEdge         = "auto",
    echoLockPosition       = true,
    echoScale              = 1,
    echoFrameStrata        = "MEDIUM",
    echoMaxTiles           = 8,
    -- Collapse mode (EchoCollapse.lua): "off", "all" or "keepnew".
    echoCollapse           = "off",
    echoToastStyle         = "framed",
    echoToastSeconds       = 4,
    echoHoverDelay         = 0.35,
    echoHoldToastsInCombat = true,
    echoWhisperSound       = "blizzard",
    echoSoundInCombat      = true,
    echoSoundBnet          = true,
    -- Tier per conversation type; mirrors Store.DEFAULT_TIERS, except All, which is always quiet.
    echoTierWhisper        = "loud",
    echoTierBnet           = "loud",
    echoTierParty          = "count",
    echoTierRaid           = "count",
    echoTierInstance       = "count",
    echoTierGuild          = "quiet",
    echoTierOfficer        = "quiet",
    echoTierChannel        = "quiet",
    echoTierNearby         = "quiet",
    echoTierLoot           = "quiet",
    echoTierProgress       = "quiet",
    echoTierSystem         = "quiet",
    echoKeywords           = "",
    echoFeedLoot           = true,
    echoFeedProgress       = true,
    echoFeedSystem         = true,
    echoAllView            = true,
    echoSaveHistory        = true,
    echoHistoryDays        = 30,
    echoSaveGuild          = true,
    echoSaveOfficer        = false,
    echoHideStoredWhispers = false,
    echoDockInput          = true,
    echoInputAlwaysVisible = false,
    echoHideBlizzardChat   = false,
    echoKeepCombatLog      = true,
    echoCardWidth          = 360,
    echoCardHeight         = 440,
    echoCardTextSize       = 11,
    echoFontPath           = "__global__",
    echoAnimateCard        = true,
    -- Chat groups (modules/Echo/EchoGroups.lua). A blank name leaves the group unused;
    -- echoGroupOf maps a member id to its group index. Read through Echo.Setting; never
    -- mutate these tables in place.
    echoGroupsEnabled      = true,
    echoGroupNames         = { DEFAULT_GROUP_1_NAME, "", "", "" },
    echoGroupOf            = {
        ["ch:General"] = 1, ["ch:Trade"] = 1, ["ch:Trade (Services)"] = 1,
        ["ch:LocalDefense"] = 1, ["ch:LookingForGroup"] = 1,
    },
    -- Chosen icon per group, index 1..4 -> fileID (number) or icon path (string). An
    -- absent entry means the group tile keeps View.GROUP_ICON.
    echoGroupIcons         = {},
}

addon.ECHO_LIMITS = {
    echoScale        = { min = 0.6, max = 1.6 },
    echoMaxTiles     = { min = 2,   max = 12 },
    echoToastSeconds = { min = 2,   max = 10 },
    echoCardWidth    = { min = 320, max = 520 },
    echoCardHeight   = { min = 320, max = 640 },
    echoCardTextSize = { min = 9,   max = 16 },
}

-- Every setting, plus the dragged position, re-applies Echo when it changes.
addon.ECHO_KEYS = { echoX = true, echoY = true }
for key in pairs(addon.ECHO_DEFAULTS) do addon.ECHO_KEYS[key] = true end
