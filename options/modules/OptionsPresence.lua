--[[
    Horizon Suite - Presence - Options categories
    Self-registers into addon.OptionCategories after OptionsData.lua runs.
]]

local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L = addon.L
local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end

local FONT_USE_GLOBAL          = addon.FONT_USE_GLOBAL
local OUTLINE_OPTIONS          = addon.OUTLINE_OPTIONS
local GetPerElementFontDropdownOptions = addon.GetPerElementFontDropdownOptions
local DisplayPerElementFont    = addon.DisplayPerElementFont
local Section                  = addon.Section
local Button                   = addon.Button
local Toggle                   = addon.Toggle
local Color                    = addon.Color
local D   = addon.PRESENCE_DEFAULTS
local LIM = addon.PRESENCE_LIMITS
local function clamp(v, key) local lim = LIM[key]; return math.max(lim.min, math.min(lim.max, v)) end

local function GetPresencePreviewDropdownOptions()
    local Presence = addon.Presence
    if not Presence or not Presence.PREVIEW_TYPE_ORDER or not Presence.PREVIEW_TYPE_LABELS then
        return { { L["PRESENCE_LEVEL_UP_TOGGLE"], "LEVEL_UP" } }
    end
    local out = {}
    for _, typeName in ipairs(Presence.PREVIEW_TYPE_ORDER) do
        local labelKey = Presence.PREVIEW_TYPE_LABELS[typeName]
        local label = labelKey and (L[labelKey] or labelKey) or typeName
        out[#out + 1] = { label, typeName }
    end
    return out
end
addon.GetPresencePreviewDropdownOptions = GetPresencePreviewDropdownOptions

local categories = {
    {
        key       = "PresenceGeneral",
        name      = L["AXIS_GENERAL"],
        desc      = L["SETTINGS_PRESENCE_NOTIFICATION_FRAMEWORK"],
        moduleKey = "presence",
        options = {
            Section(L["DASH_DISPLAY"]),
            Toggle(L["TOAST_ICONS"], L["PRESENCE_QUEST_TYPE_ICON_PRESENCE_TOASTS_QUEST"], "showPresenceQuestTypeIcons", D.showPresenceQuestTypeIcons, { refreshIds = { "presencePreview" } }),
            { type = "slider", name = L["PRESENCE_TOAST_ICON_SIZE"], desc = L["PRESENCE_QUEST_ICON_SIZE_PRESENCE_TOASTS_PX"], dbKey = "presenceIconSize", min = LIM.presenceIconSize.min, max = LIM.presenceIconSize.max, get = function() return math.max(LIM.presenceIconSize.min, math.min(LIM.presenceIconSize.max, getDB("presenceIconSize", D.presenceIconSize) or D.presenceIconSize)) end, set = function(v) setDB("presenceIconSize", clamp(v, "presenceIconSize")) end, refreshIds = { "presencePreview" } },
            Toggle(L["PRESENCE_HIDE_QUEST_UPDATE_TITLE"], L["OBJECTIVE_LINE"], "presenceHideQuestUpdateTitle", D.presenceHideQuestUpdateTitle, { tooltip = L["PRESENCE_OBJECTIVE_LINE_QUEST_PROGRESS_TOAST"], refreshIds = { "presencePreview" } }),
            Toggle(L["PRESENCE_DISCOVERY_LINE"], L["PRESENCE_SHOW_DISCOVERED"], "showPresenceDiscovery", D.showPresenceDiscovery, { refreshIds = { "presencePreview" } }),
            { type = "slider", name = L["PRESENCE_FRAME_VERTICAL_POSITION"], desc = L["PRESENCE_VERTICAL_OFFSET_OF_PRESENCE_FRAME_CENTER"], dbKey = "presenceFrameY", min = LIM.presenceFrameY.min, max = LIM.presenceFrameY.max, get = function() return math.max(LIM.presenceFrameY.min, math.min(LIM.presenceFrameY.max, tonumber(getDB("presenceFrameY", D.presenceFrameY)) or D.presenceFrameY)) end, set = function(v) setDB("presenceFrameY", clamp(v, "presenceFrameY")) end },
            { type = "slider", name = L["PRESENCE_FRAME_SCALE"], desc = L["PRESENCE_FRAME_SCALE_TIP"], dbKey = "presenceFrameScale", min = LIM.presenceFrameScale.min, max = LIM.presenceFrameScale.max, step = 0.1, get = function() return math.max(LIM.presenceFrameScale.min, math.min(LIM.presenceFrameScale.max, tonumber(getDB("presenceFrameScale", D.presenceFrameScale)) or D.presenceFrameScale)) end, set = function(v) setDB("presenceFrameScale", clamp(v, "presenceFrameScale")) end },
            Section(L["PRESENCE_ANIMATION"]),
            Toggle(L["FOCUS_ANIMATIONS"], L["PRESENCE_ENABLE_ENTRANCE_EXIT_ANIMATIONS_PRESENCE"], "presenceAnimations", D.presenceAnimations),
            { type = "slider", name = L["PRESENCE_ENTRANCE_DURATION"], desc = L["PRESENCE_DURATION_OF_ENTRANCE_ANIMATION_SECONDS"], dbKey = "presenceEntranceDur", min = LIM.presenceEntranceDur.min, max = LIM.presenceEntranceDur.max, step = 0.1, get = function() return math.max(LIM.presenceEntranceDur.min, math.min(LIM.presenceEntranceDur.max, tonumber(getDB("presenceEntranceDur", D.presenceEntranceDur)) or D.presenceEntranceDur)) end, set = function(v) setDB("presenceEntranceDur", clamp(v, "presenceEntranceDur")) end },
            { type = "slider", name = L["PRESENCE_EXIT_DURATION"], desc = L["PRESENCE_DURATION_OF_EXIT_ANIMATION_SECONDS"], dbKey = "presenceExitDur", min = LIM.presenceExitDur.min, max = LIM.presenceExitDur.max, step = 0.1, get = function() return math.max(LIM.presenceExitDur.min, math.min(LIM.presenceExitDur.max, tonumber(getDB("presenceExitDur", D.presenceExitDur)) or D.presenceExitDur)) end, set = function(v) setDB("presenceExitDur", clamp(v, "presenceExitDur")) end },
            { type = "slider", name = L["PRESENCE_HOLD_DURATION_SCALE"], desc = L["PRESENCE_MULTIPLIER_LONG_NOTIFICATION_STAY"], dbKey = "presenceHoldScale", min = LIM.presenceHoldScale.min, max = LIM.presenceHoldScale.max, step = 0.1, get = function() return math.max(LIM.presenceHoldScale.min, math.min(LIM.presenceHoldScale.max, tonumber(getDB("presenceHoldScale", D.presenceHoldScale)) or D.presenceHoldScale)) end, set = function(v) setDB("presenceHoldScale", clamp(v, "presenceHoldScale")) end },
        },
    },
    {
        key       = "PresencePreview",
        name      = L["PRESENCE_PREVIEW"],
        desc      = L["PRESENCE_PREVIEW_PRESENCE_TOAST_LAYOUTS_LIVE_OPEN"],
        moduleKey = "presence",
        options = {
            Section(L["PRESENCE_PREVIEW"]),
            { type = "presencePreview" },
        },
    },
    {
        key       = "PresenceNotifications",
        name      = L["PRESENCE_NOTIFICATIONS"],
        desc      = L["CHOOSE_WHICH_EVENTS_TRIGGER_SCREEN_ALERTS"],
        moduleKey = "presence",
        options = {
            Section(L["PRESENCE_NOTIFICATION_TYPES"]),
            Toggle(L["ZONE_ENTRY"], L["PRESENCE_ZONE_CHANGE_ENTERING_A_AREA"], "presenceZoneChange", D.presenceZoneChange, { refreshIds = { "presenceSubzoneChange", "presenceHideZoneForSubzone" } }),
            { type = "toggle", name = L["SUBZONE_CHANGES"], desc = L["PRESENCE_SUBZONE_CHANGE_MOVING_WITHIN_SAME_ZONE"], dbKey = "presenceSubzoneChange", get = function() local v = getDB("presenceSubzoneChange", nil); if v ~= nil then return v end; return getDB("presenceZoneChange", D.presenceZoneChange) end, set = function(v) setDB("presenceSubzoneChange", v) end, refreshIds = { "presenceHideZoneForSubzone" } },
            Toggle(L["VISTA_SHOW_SUBZONE"], L["SUBZONE_NAME_WITHIN_SAME_ZONE"], "presenceHideZoneForSubzone", D.presenceHideZoneForSubzone, { tooltip = L["ZONE_NAME_NEW_ZONE"], visibleWhen = function() local v = getDB("presenceSubzoneChange", nil); if v ~= nil then return v end; return getDB("presenceZoneChange", D.presenceZoneChange) end }),
            Toggle(L["SUPPRESS_M"], L["HIDE_ZONE_NOTIFICATIONS_MYTHIC"], "presenceSuppressZoneInMplus", D.presenceSuppressZoneInMplus, { tooltip = L["BOSS_EMOTES_ACHIEVEMENTS_LEVEL_HIDES_ZONE"] }),
            Section(L["INSTANCE_SUPPRESSION"]),
            Toggle(L["SUPPRESS_DUNGEON"],    L["SUPPRESS_NOTIFICATIONS_DUNGEONS"],                            "presenceSuppressInDungeon",     D.presenceSuppressInDungeon,     { tooltip = L["SUPPRESS_IN_DUNGEON_DETAIL"] }),
            Toggle(L["PRESENCE_SUPPRESS_DELVE"], L["PRESENCE_SUPPRESS_SCENARIO_PROGRESS_NOTIFICATIONS_DELVES"], "presenceSuppressInDelve",    D.presenceSuppressInDelve,    { tooltip = L["PRESENCE_HIDE_DELVE_OBJECTIVE_UPDATE"] }),
            Toggle(L["SUPPRESS_RAID"],       L["SUPPRESS_IN_RAID_DETAIL"],                                    "presenceSuppressInRaid",        D.presenceSuppressInRaid),
            Toggle(L["SUPPRESS_PVP"],        L["SUPPRESS_IN_ARENA_DETAIL"],                                   "presenceSuppressInPvP",         D.presenceSuppressInPvP),
            Toggle(L["SUPPRESS_BATTLEGROUND"], L["SUPPRESS_PRESENCE_NOTIFICATIONS_WHILE_INSIDE_A"],           "presenceSuppressInBattleground", D.presenceSuppressInBattleground),
            Toggle(L["PRESENCE_LEVEL_UP_TOGGLE"], L["PRESENCE_LEVEL_NOTIFICATION"],                           "presenceLevelUp",               D.presenceLevelUp),
            Toggle(L["BOSS_EMOTES"],         L["PRESENCE_RAID_DUNGEON_BOSS_EMOTE_NOTIFICATIONS"],             "presenceBossEmote",             D.presenceBossEmote),
            Toggle(L["FOCUS_ACHIEVEMENTS"],  L["PRESENCE_ACHIEVEMENT_EARNED_NOTIFICATIONS"],                  "presenceAchievement",           D.presenceAchievement),
            Toggle(L["PRESENCE_ACHIEVEMENT_PROGRESS"], L["NOTIFY_ACHIEVEMENT_CRITERIA_UPDATE"],               "presenceAchievementProgress",   D.presenceAchievementProgress, { tooltip = L["PRESENCE_NOTIFICATION_ACHIEVEMENT_CRITERIA_UPDATE"] }),
            { type = "toggle", name = L["QUEST_ACCEPT"],       desc = L["PRESENCE_NOTIFICATION_ACCEPTING_A_QUEST"],         dbKey = "presenceQuestAccept",     get = function() local v = getDB("presenceQuestAccept",     nil); if v ~= nil then return v end; return getDB("presenceQuestEvents",  D.presenceQuestEvents) end, set = function(v) setDB("presenceQuestAccept",     v) end },
            { type = "toggle", name = L["WORLD_QUEST_ACCEPT"], desc = L["PRESENCE_NOTIFICATION_ACCEPTING_A_WORLD_QUEST"],   dbKey = "presenceWorldQuestAccept", get = function() local v = getDB("presenceWorldQuestAccept", nil); if v ~= nil then return v end; return getDB("presenceQuestEvents",  D.presenceQuestEvents) end, set = function(v) setDB("presenceWorldQuestAccept", v) end },
            { type = "toggle", name = L["QUEST_COMPLETE"],     desc = L["PRESENCE_NOTIFICATION_COMPLETING_A_QUEST"],        dbKey = "presenceQuestComplete",   get = function() local v = getDB("presenceQuestComplete",   nil); if v ~= nil then return v end; return getDB("presenceQuestEvents",  D.presenceQuestEvents) end, set = function(v) setDB("presenceQuestComplete",   v) end },
            { type = "toggle", name = L["WORLD_QUEST_COMPLETE"], desc = L["PRESENCE_NOTIFICATION_COMPLETING_A_WORLD_QUEST"], dbKey = "presenceWorldQuest",     get = function() local v = getDB("presenceWorldQuest",     nil); if v ~= nil then return v end; return getDB("presenceQuestEvents",  D.presenceQuestEvents) end, set = function(v) setDB("presenceWorldQuest",     v) end },
            { type = "toggle", name = L["QUEST_PROGRESS"],    desc = L["PRESENCE_NOTIFICATION_QUEST_OBJECTIVES_UPDATE"],   dbKey = "presenceQuestUpdate",     get = function() local v = getDB("presenceQuestUpdate",     nil); if v ~= nil then return v end; return getDB("presenceQuestEvents",  D.presenceQuestEvents) end, set = function(v) setDB("presenceQuestUpdate",     v) end },
            Toggle(L["PRESENCE_OBJECTIVE"], L["PRESENCE_QUEST_PROGRESS_HIDE_TITLE"], "presenceHideQuestUpdateTitle", D.presenceHideQuestUpdateTitle),
            { type = "toggle", name = L["SCENARIO_START"],    desc = L["PRESENCE_NOTIFICATION_ENTERING_A_SCENARIO_DELVE"],  dbKey = "presenceScenarioStart",   get = function() local v = getDB("presenceScenarioStart",   nil); if v ~= nil then return v end; return getDB("showScenarioEvents", true) end, set = function(v) setDB("presenceScenarioStart",   v) end },
            { type = "toggle", name = L["SCENARIO_PROGRESS"], desc = L["PRESENCE_NOTIFICATION_SCENARIO_DELVE_OBJECTIVES"],  dbKey = "presenceScenarioUpdate",  get = function() local v = getDB("presenceScenarioUpdate",  nil); if v ~= nil then return v end; return getDB("showScenarioEvents", true) end, set = function(v) setDB("presenceScenarioUpdate",  v) end },
            { type = "toggle", name = L["PRESENCE_SHOW_SCENARIO_COMPLETE"], desc = L["NOTIFICATION_A_SCENARIO_DELVE_FULLY_COM"], dbKey = "presenceScenarioComplete", get = function() local v = getDB("presenceScenarioComplete", nil); if v ~= nil then return v end; return getDB("showScenarioEvents", true) end, set = function(v) setDB("presenceScenarioComplete", v) end },
            Toggle(L["PRESENCE_SHOW_RARE_DEFEATED"], L["NOTIFICATION_A_RARE_MOB_DEFEATED_NEARBY"], "presenceRareDefeated", D.presenceRareDefeated),
        },
    },
    {
        key       = "PresenceTypography",
        name      = L["DASH_TYPOGRAPHY"],
        desc      = L["FONTS_SIZES_COLOURS_PRESENCE_NOTIFICATIONS"],
        moduleKey = "presence",
        options = {
            Section(L["DASH_TYPOGRAPHY"]),
            Button(L["PRESENCE_RESET_TYPOGRAPHY_DEFAULTS"], L["PRESENCE_RESET_PRESENCE_TYPOGRAPHY_OPTIONS_FONTS_SIZES"], function()
                setDB("presenceTitleFontPath", nil)
                setDB("presenceSubtitleFontPath", nil)
                setDB("presenceTitleFontOutline", nil)
                setDB("presenceSubtitleFontOutline", nil)
                setDB("presencePrimaryLargeSz", nil)
                setDB("presenceSecondaryLargeSz", nil)
                setDB("presencePrimaryMediumSz", nil)
                setDB("presenceSecondaryMediumSz", nil)
                setDB("presencePrimarySmallSz", nil)
                setDB("presenceSecondarySmallSz", nil)
                setDB("presenceDiscoverySize", nil)
                setDB("presenceBossEmoteColor", nil)
                setDB("presenceDiscoveryColor", nil)
                setDB("presenceZoneTypeColoring", nil)
                setDB("presenceZoneColorFriendly", nil)
                setDB("presenceZoneColorHostile", nil)
                setDB("presenceZoneColorContested", nil)
                setDB("presenceZoneColorSanctuary", nil)
                if addon.Presence and addon.Presence.ApplyPresenceOptions then addon.Presence.ApplyPresenceOptions() end
                if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                if C_Timer and C_Timer.After and addon.OptionsPanel_Refresh then
                    C_Timer.After(0, addon.OptionsPanel_Refresh)
                elseif addon.OptionsPanel_Refresh then
                    addon.OptionsPanel_Refresh()
                end
            end, { refreshIds = { "presencePreview", "presenceTitleFontPath", "presenceSubtitleFontPath", "presenceTitleFontOutline", "presenceSubtitleFontOutline", "presencePrimaryLargeSz", "presenceSecondaryLargeSz", "presencePrimaryMediumSz", "presenceSecondaryMediumSz", "presencePrimarySmallSz", "presenceSecondarySmallSz", "presenceDiscoverySize", "presenceBossEmoteColor", "presenceDiscoveryColor", "presenceZoneTypeColoring", "presenceZoneColorFriendly", "presenceZoneColorHostile", "presenceZoneColorContested", "presenceZoneColorSanctuary" } }),
            { type = "dropdown", name = L["PRESENCE_MAIN_TITLE_FONT"], desc = L["PRESENCE_FONT_FAMILY_MAIN_TITLE"], dbKey = "presenceTitleFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("presenceTitleFontPath") end, get = function() return getDB("presenceTitleFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("presenceTitleFontPath", v) end, displayFn = DisplayPerElementFont, refreshIds = { "presencePreview" }, fontPreviewInList = true },
            { type = "dropdown", name = L["PRESENCE_SUBTITLE_FONT"], desc = L["PRESENCE_FONT_FAMILY_SUBTITLE"], dbKey = "presenceSubtitleFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("presenceSubtitleFontPath") end, get = function() return getDB("presenceSubtitleFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("presenceSubtitleFontPath", v) end, displayFn = DisplayPerElementFont, refreshIds = { "presencePreview" }, fontPreviewInList = true },
            { type = "dropdown", name = L["PRESENCE_MAIN_TITLE_OUTLINE"], desc = L["PRESENCE_FONT_OUTLINE_MAIN_TITLE"], dbKey = "presenceTitleFontOutline", options = OUTLINE_OPTIONS, preserveOrder = true, get = function() return getDB("presenceTitleFontOutline", D.presenceTitleFontOutline) end, set = function(v) setDB("presenceTitleFontOutline", v) end, refreshIds = { "presencePreview" } },
            { type = "dropdown", name = L["PRESENCE_SUBTITLE_OUTLINE"], desc = L["PRESENCE_FONT_OUTLINE_SUBTITLE"], dbKey = "presenceSubtitleFontOutline", options = OUTLINE_OPTIONS, preserveOrder = true, get = function() return getDB("presenceSubtitleFontOutline", D.presenceSubtitleFontOutline) end, set = function(v) setDB("presenceSubtitleFontOutline", v) end, refreshIds = { "presencePreview" } },
            { type = "slider", name = L["PRESENCE_DISCOVERY_SIZE"], desc = L["PRESENCE_FONT_SIZE_DISCOVERY"], dbKey = "presenceDiscoverySize", min = LIM.presenceDiscoverySize.min, max = LIM.presenceDiscoverySize.max, get = function() return math.max(LIM.presenceDiscoverySize.min, math.min(LIM.presenceDiscoverySize.max, tonumber(getDB("presenceDiscoverySize", D.presenceDiscoverySize)) or D.presenceDiscoverySize)) end, set = function(v) setDB("presenceDiscoverySize", clamp(v, "presenceDiscoverySize")) if addon.Presence and addon.Presence.ApplyPresenceOptions then addon.Presence.ApplyPresenceOptions() end end, refreshIds = { "presencePreview" } },
            Section(L["PRESENCE_LARGE_NOTIFICATIONS"]),
            { type = "slider", name = L["PRESENCE_LARGE_PRIMARY_SIZE"], desc = L["PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_TITLES_ZONE"], dbKey = "presencePrimaryLargeSz", min = LIM.presencePrimaryLargeSz.min, max = LIM.presencePrimaryLargeSz.max, get = function() return math.max(LIM.presencePrimaryLargeSz.min, math.min(LIM.presencePrimaryLargeSz.max, tonumber(getDB("presencePrimaryLargeSz", D.presencePrimaryLargeSz)) or D.presencePrimaryLargeSz)) end, set = function(v) setDB("presencePrimaryLargeSz", clamp(v, "presencePrimaryLargeSz")) end, refreshIds = { "presencePreview" } },
            { type = "slider", name = L["PRESENCE_LARGE_SECONDARY_SIZE"], desc = L["PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_SUBTITLES"], dbKey = "presenceSecondaryLargeSz", min = LIM.presenceSecondaryLargeSz.min, max = LIM.presenceSecondaryLargeSz.max, get = function() return math.max(LIM.presenceSecondaryLargeSz.min, math.min(LIM.presenceSecondaryLargeSz.max, tonumber(getDB("presenceSecondaryLargeSz", D.presenceSecondaryLargeSz)) or D.presenceSecondaryLargeSz)) end, set = function(v) setDB("presenceSecondaryLargeSz", clamp(v, "presenceSecondaryLargeSz")) end, refreshIds = { "presencePreview" } },
            Section(L["PRESENCE_MEDIUM_NOTIFICATIONS"]),
            { type = "slider", name = L["PRESENCE_MEDIUM_PRIMARY_SIZE"], desc = L["PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_TITLES_QUEST"], dbKey = "presencePrimaryMediumSz", min = LIM.presencePrimaryMediumSz.min, max = LIM.presencePrimaryMediumSz.max, get = function() return math.max(LIM.presencePrimaryMediumSz.min, math.min(LIM.presencePrimaryMediumSz.max, tonumber(getDB("presencePrimaryMediumSz", D.presencePrimaryMediumSz)) or D.presencePrimaryMediumSz)) end, set = function(v) setDB("presencePrimaryMediumSz", clamp(v, "presencePrimaryMediumSz")) end, refreshIds = { "presencePreview" } },
            { type = "slider", name = L["PRESENCE_MEDIUM_SECONDARY_SIZE"], desc = L["PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_SUBTITLES"], dbKey = "presenceSecondaryMediumSz", min = LIM.presenceSecondaryMediumSz.min, max = LIM.presenceSecondaryMediumSz.max, get = function() return math.max(LIM.presenceSecondaryMediumSz.min, math.min(LIM.presenceSecondaryMediumSz.max, tonumber(getDB("presenceSecondaryMediumSz", D.presenceSecondaryMediumSz)) or D.presenceSecondaryMediumSz)) end, set = function(v) setDB("presenceSecondaryMediumSz", clamp(v, "presenceSecondaryMediumSz")) end, refreshIds = { "presencePreview" } },
            Section(L["PRESENCE_SMALL_NOTIFICATIONS"]),
            { type = "slider", name = L["PRESENCE_SMALL_PRIMARY_SIZE"], desc = L["PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_TITLES_QUEST"], dbKey = "presencePrimarySmallSz", min = LIM.presencePrimarySmallSz.min, max = LIM.presencePrimarySmallSz.max, get = function() return math.max(LIM.presencePrimarySmallSz.min, math.min(LIM.presencePrimarySmallSz.max, tonumber(getDB("presencePrimarySmallSz", D.presencePrimarySmallSz)) or D.presencePrimarySmallSz)) end, set = function(v) setDB("presencePrimarySmallSz", clamp(v, "presencePrimarySmallSz")) end, refreshIds = { "presencePreview" } },
            { type = "slider", name = L["PRESENCE_SMALL_SECONDARY_SIZE"], desc = L["PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_SUBTITLES"], dbKey = "presenceSecondarySmallSz", min = LIM.presenceSecondarySmallSz.min, max = LIM.presenceSecondarySmallSz.max, get = function() return math.max(LIM.presenceSecondarySmallSz.min, math.min(LIM.presenceSecondarySmallSz.max, tonumber(getDB("presenceSecondarySmallSz", D.presenceSecondarySmallSz)) or D.presenceSecondarySmallSz)) end, set = function(v) setDB("presenceSecondarySmallSz", clamp(v, "presenceSecondarySmallSz")) end, refreshIds = { "presencePreview" } },
            Section(L["DASH_COLOURS"]),
            Color(L["PRESENCE_BOSS_EMOTE_COLOUR"], L["PRESENCE_COLOUR_RAID_DUNGEON_BOSS_EMOTE"],             "presenceBossEmoteColor",    addon.PRESENCE_BOSS_EMOTE_COLOR, { refreshIds = { "presencePreview" } }),
            Color(L["PRESENCE_DISCOVERY_LINE_COLOUR"], L["PRESENCE_COLOUR_OF_DISCOVERED_LINE_UNDER_ZONE_TIP"], "presenceDiscoveryColor",  addon.PRESENCE_DISCOVERY_COLOR,  { refreshIds = { "presencePreview" } }),
            Section(L["ZONE_TYPE_COLOURING"]),
            Toggle(L["COLOUR_ZONE_TYPE"], L["COLOUR_ZONE_SUBZONE_TITLES_PVP_ZONE"], "presenceZoneTypeColoring", D.presenceZoneTypeColoring, { refreshIds = { "presencePreview" } }),
            Color(L["FRIENDLY_ZONE_COLOUR"],   L["COLOUR_FRIENDLY_ZONES_GREEN_DEFAULT"],  "presenceZoneColorFriendly",   { 0.1,  1.0,  0.1  }, { refreshIds = { "presencePreview" } }),
            Color(L["HOSTILE_ZONE_COLOUR"],    L["COLOUR_HOSTILE_ZONES_RED_DEFAULT"],     "presenceZoneColorHostile",    { 1.0,  0.1,  0.1  }, { refreshIds = { "presencePreview" } }),
            Color(L["CONTESTED_ZONE_COLOUR"],  L["COLOUR_CONTESTED_ZONES_ORANGE_DEFAULT"], "presenceZoneColorContested", { 1.0,  0.7,  0.0  }, { refreshIds = { "presencePreview" } }),
            Color(L["SANCTUARY_ZONE_COLOUR"],  L["COLOUR_SANCTUARY_ZONES_BLUE_DEFAULT"],  "presenceZoneColorSanctuary",  { 0.41, 0.8,  0.94 }, { refreshIds = { "presencePreview" } }),
        },
    },
}

-- Insert after the last Focus category to preserve sidebar order
local insertAt = #addon.OptionCategories + 1
for i, cat in ipairs(addon.OptionCategories) do
    if cat.moduleKey == "focus" then insertAt = i + 1 end
end
for i = 1, #categories do
    table.insert(addon.OptionCategories, insertAt + i - 1, categories[i])
end
