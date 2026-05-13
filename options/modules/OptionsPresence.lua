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
            { type = "section", name = L["DASH_DISPLAY"] },
            { type = "toggle", name = L["TOAST_ICONS"], desc = L["PRESENCE_QUEST_TYPE_ICON_PRESENCE_TOASTS_QUEST"], dbKey = "showPresenceQuestTypeIcons", get = function() return getDB("showPresenceQuestTypeIcons", true) end, set = function(v) setDB("showPresenceQuestTypeIcons", v) end, refreshIds = { "presencePreview" } },
            { type = "slider", name = L["PRESENCE_TOAST_ICON_SIZE"], desc = L["PRESENCE_QUEST_ICON_SIZE_PRESENCE_TOASTS_PX"], dbKey = "presenceIconSize", min = 16, max = 36, get = function() return math.max(16, math.min(36, getDB("presenceIconSize", 24) or 24)) end, set = function(v) setDB("presenceIconSize", math.max(16, math.min(36, v))) end, refreshIds = { "presencePreview" } },
            { type = "toggle", name = L["PRESENCE_HIDE_QUEST_UPDATE_TITLE"], desc = L["OBJECTIVE_LINE"], tooltip = L["PRESENCE_OBJECTIVE_LINE_QUEST_PROGRESS_TOAST"], dbKey = "presenceHideQuestUpdateTitle", get = function() return getDB("presenceHideQuestUpdateTitle", false) end, set = function(v) setDB("presenceHideQuestUpdateTitle", v) end, refreshIds = { "presencePreview" } },
            { type = "toggle", name = L["PRESENCE_DISCOVERY_LINE"], desc = L["PRESENCE_SHOW_DISCOVERED"], dbKey = "showPresenceDiscovery", get = function() return getDB("showPresenceDiscovery", true) end, set = function(v) setDB("showPresenceDiscovery", v) end, refreshIds = { "presencePreview" } },
            { type = "slider", name = L["PRESENCE_FRAME_VERTICAL_POSITION"], desc = L["PRESENCE_VERTICAL_OFFSET_OF_PRESENCE_FRAME_CENTER"], dbKey = "presenceFrameY", min = -300, max = 0, get = function() return math.max(-300, math.min(0, tonumber(getDB("presenceFrameY", -180)) or -180)) end, set = function(v) setDB("presenceFrameY", math.max(-300, math.min(0, v))) end },
            { type = "slider", name = L["PRESENCE_FRAME_SCALE"], desc = L["PRESENCE_FRAME_SCALE_TIP"], dbKey = "presenceFrameScale", min = 0.5, max = 2, step = 0.1, get = function() return math.max(0.5, math.min(2, tonumber(getDB("presenceFrameScale", 1)) or 1)) end, set = function(v) setDB("presenceFrameScale", math.max(0.5, math.min(2, v))) end },
            { type = "section", name = L["PRESENCE_ANIMATION"] },
            { type = "toggle", name = L["FOCUS_ANIMATIONS"], desc = L["PRESENCE_ENABLE_ENTRANCE_EXIT_ANIMATIONS_PRESENCE"], dbKey = "presenceAnimations", get = function() return getDB("presenceAnimations", true) end, set = function(v) setDB("presenceAnimations", v) end },
            { type = "slider", name = L["PRESENCE_ENTRANCE_DURATION"], desc = L["PRESENCE_DURATION_OF_ENTRANCE_ANIMATION_SECONDS"], dbKey = "presenceEntranceDur", min = 0.2, max = 1.5, step = 0.1, get = function() return math.max(0.2, math.min(1.5, tonumber(getDB("presenceEntranceDur", 0.7)) or 0.7)) end, set = function(v) setDB("presenceEntranceDur", math.max(0.2, math.min(1.5, v))) end },
            { type = "slider", name = L["PRESENCE_EXIT_DURATION"], desc = L["PRESENCE_DURATION_OF_EXIT_ANIMATION_SECONDS"], dbKey = "presenceExitDur", min = 0.2, max = 1.5, step = 0.1, get = function() return math.max(0.2, math.min(1.5, tonumber(getDB("presenceExitDur", 0.8)) or 0.8)) end, set = function(v) setDB("presenceExitDur", math.max(0.2, math.min(1.5, v))) end },
            { type = "slider", name = L["PRESENCE_HOLD_DURATION_SCALE"], desc = L["PRESENCE_MULTIPLIER_LONG_NOTIFICATION_STAY"], dbKey = "presenceHoldScale", min = 0.5, max = 2, step = 0.1, get = function() return math.max(0.5, math.min(2, tonumber(getDB("presenceHoldScale", 1)) or 1)) end, set = function(v) setDB("presenceHoldScale", math.max(0.5, math.min(2, v))) end },
        },
    },
    {
        key       = "PresencePreview",
        name      = L["PRESENCE_PREVIEW"],
        desc      = L["PRESENCE_PREVIEW_PRESENCE_TOAST_LAYOUTS_LIVE_OPEN"],
        moduleKey = "presence",
        options = {
            { type = "section", name = L["PRESENCE_PREVIEW"] },
            { type = "presencePreview" },
        },
    },
    {
        key       = "PresenceNotifications",
        name      = L["PRESENCE_NOTIFICATIONS"],
        desc      = L["CHOOSE_WHICH_EVENTS_TRIGGER_SCREEN_ALERTS"],
        moduleKey = "presence",
        options = {
            { type = "section", name = L["PRESENCE_NOTIFICATION_TYPES"] },
            { type = "toggle", name = L["ZONE_ENTRY"], desc = L["PRESENCE_ZONE_CHANGE_ENTERING_A_AREA"], dbKey = "presenceZoneChange", get = function() return getDB("presenceZoneChange", true) end, set = function(v) setDB("presenceZoneChange", v) end, refreshIds = { "presenceSubzoneChange", "presenceHideZoneForSubzone" } },
            { type = "toggle", name = L["SUBZONE_CHANGES"], desc = L["PRESENCE_SUBZONE_CHANGE_MOVING_WITHIN_SAME_ZONE"], dbKey = "presenceSubzoneChange", get = function() local v = getDB("presenceSubzoneChange", nil); if v ~= nil then return v end; return getDB("presenceZoneChange", true) end, set = function(v) setDB("presenceSubzoneChange", v) end, refreshIds = { "presenceHideZoneForSubzone" } },
            { type = "toggle", name = L["VISTA_SHOW_SUBZONE"], desc = L["SUBZONE_NAME_WITHIN_SAME_ZONE"], dbKey = "presenceHideZoneForSubzone", get = function() return getDB("presenceHideZoneForSubzone", false) end, set = function(v) setDB("presenceHideZoneForSubzone", v) end, tooltip = L["ZONE_NAME_NEW_ZONE"], visibleWhen = function() local v = getDB("presenceSubzoneChange", nil); if v ~= nil then return v end; return getDB("presenceZoneChange", true) end },
            { type = "toggle", name = L["SUPPRESS_M"], desc = L["HIDE_ZONE_NOTIFICATIONS_MYTHIC"], tooltip = L["BOSS_EMOTES_ACHIEVEMENTS_LEVEL_HIDES_ZONE"], dbKey = "presenceSuppressZoneInMplus", get = function() return getDB("presenceSuppressZoneInMplus", true) end, set = function(v) setDB("presenceSuppressZoneInMplus", v) end },
            { type = "section", name = L["INSTANCE_SUPPRESSION"] },
            { type = "toggle", name = L["SUPPRESS_DUNGEON"], desc = L["SUPPRESS_NOTIFICATIONS_DUNGEONS"], tooltip = L["SUPPRESS_IN_DUNGEON_DETAIL"], dbKey = "presenceSuppressInDungeon", get = function() return getDB("presenceSuppressInDungeon", false) end, set = function(v) setDB("presenceSuppressInDungeon", v) end },
            { type = "toggle", name = L["PRESENCE_SUPPRESS_DELVE"], desc = L["PRESENCE_SUPPRESS_SCENARIO_PROGRESS_NOTIFICATIONS_DELVES"], tooltip = L["PRESENCE_HIDE_DELVE_OBJECTIVE_UPDATE"], dbKey = "presenceSuppressInDelve", get = function() return getDB("presenceSuppressInDelve", false) end, set = function(v) setDB("presenceSuppressInDelve", v) end },
            { type = "toggle", name = L["SUPPRESS_RAID"], desc = L["SUPPRESS_IN_RAID_DETAIL"], dbKey = "presenceSuppressInRaid", get = function() return getDB("presenceSuppressInRaid", false) end, set = function(v) setDB("presenceSuppressInRaid", v) end },
            { type = "toggle", name = L["SUPPRESS_PVP"], desc = L["SUPPRESS_IN_ARENA_DETAIL"], dbKey = "presenceSuppressInPvP", get = function() return getDB("presenceSuppressInPvP", false) end, set = function(v) setDB("presenceSuppressInPvP", v) end },
            { type = "toggle", name = L["SUPPRESS_BATTLEGROUND"], desc = L["SUPPRESS_PRESENCE_NOTIFICATIONS_WHILE_INSIDE_A"], dbKey = "presenceSuppressInBattleground", get = function() return getDB("presenceSuppressInBattleground", false) end, set = function(v) setDB("presenceSuppressInBattleground", v) end },
            { type = "toggle", name = L["PRESENCE_LEVEL_UP_TOGGLE"], desc = L["PRESENCE_LEVEL_NOTIFICATION"], dbKey = "presenceLevelUp", get = function() return getDB("presenceLevelUp", true) end, set = function(v) setDB("presenceLevelUp", v) end },
            { type = "toggle", name = L["BOSS_EMOTES"], desc = L["PRESENCE_RAID_DUNGEON_BOSS_EMOTE_NOTIFICATIONS"], dbKey = "presenceBossEmote", get = function() return getDB("presenceBossEmote", true) end, set = function(v) setDB("presenceBossEmote", v) end },
            { type = "toggle", name = L["FOCUS_ACHIEVEMENTS"], desc = L["PRESENCE_ACHIEVEMENT_EARNED_NOTIFICATIONS"], dbKey = "presenceAchievement", get = function() return getDB("presenceAchievement", true) end, set = function(v) setDB("presenceAchievement", v) end },
            { type = "toggle", name = L["PRESENCE_ACHIEVEMENT_PROGRESS"], desc = L["NOTIFY_ACHIEVEMENT_CRITERIA_UPDATE"], tooltip = L["PRESENCE_NOTIFICATION_ACHIEVEMENT_CRITERIA_UPDATE"], dbKey = "presenceAchievementProgress", get = function() return getDB("presenceAchievementProgress", false) end, set = function(v) setDB("presenceAchievementProgress", v) end },
            { type = "toggle", name = L["QUEST_ACCEPT"], desc = L["PRESENCE_NOTIFICATION_ACCEPTING_A_QUEST"], dbKey = "presenceQuestAccept", get = function() local v = getDB("presenceQuestAccept", nil); if v ~= nil then return v end; return getDB("presenceQuestEvents", true) end, set = function(v) setDB("presenceQuestAccept", v) end },
            { type = "toggle", name = L["WORLD_QUEST_ACCEPT"], desc = L["PRESENCE_NOTIFICATION_ACCEPTING_A_WORLD_QUEST"], dbKey = "presenceWorldQuestAccept", get = function() local v = getDB("presenceWorldQuestAccept", nil); if v ~= nil then return v end; return getDB("presenceQuestEvents", true) end, set = function(v) setDB("presenceWorldQuestAccept", v) end },
            { type = "toggle", name = L["QUEST_COMPLETE"], desc = L["PRESENCE_NOTIFICATION_COMPLETING_A_QUEST"], dbKey = "presenceQuestComplete", get = function() local v = getDB("presenceQuestComplete", nil); if v ~= nil then return v end; return getDB("presenceQuestEvents", true) end, set = function(v) setDB("presenceQuestComplete", v) end },
            { type = "toggle", name = L["WORLD_QUEST_COMPLETE"], desc = L["PRESENCE_NOTIFICATION_COMPLETING_A_WORLD_QUEST"], dbKey = "presenceWorldQuest", get = function() local v = getDB("presenceWorldQuest", nil); if v ~= nil then return v end; return getDB("presenceQuestEvents", true) end, set = function(v) setDB("presenceWorldQuest", v) end },
            { type = "toggle", name = L["QUEST_PROGRESS"], desc = L["PRESENCE_NOTIFICATION_QUEST_OBJECTIVES_UPDATE"], dbKey = "presenceQuestUpdate", get = function() local v = getDB("presenceQuestUpdate", nil); if v ~= nil then return v end; return getDB("presenceQuestEvents", true) end, set = function(v) setDB("presenceQuestUpdate", v) end },
            { type = "toggle", name = L["PRESENCE_OBJECTIVE"], desc = L["PRESENCE_QUEST_PROGRESS_HIDE_TITLE"], dbKey = "presenceHideQuestUpdateTitle", get = function() return getDB("presenceHideQuestUpdateTitle", false) end, set = function(v) setDB("presenceHideQuestUpdateTitle", v) end },
            { type = "toggle", name = L["SCENARIO_START"], desc = L["PRESENCE_NOTIFICATION_ENTERING_A_SCENARIO_DELVE"], dbKey = "presenceScenarioStart", get = function() local v = getDB("presenceScenarioStart", nil); if v ~= nil then return v end; return getDB("showScenarioEvents", true) end, set = function(v) setDB("presenceScenarioStart", v) end },
            { type = "toggle", name = L["SCENARIO_PROGRESS"], desc = L["PRESENCE_NOTIFICATION_SCENARIO_DELVE_OBJECTIVES"], dbKey = "presenceScenarioUpdate", get = function() local v = getDB("presenceScenarioUpdate", nil); if v ~= nil then return v end; return getDB("showScenarioEvents", true) end, set = function(v) setDB("presenceScenarioUpdate", v) end },
            { type = "toggle", name = L["PRESENCE_SHOW_SCENARIO_COMPLETE"], desc = L["NOTIFICATION_A_SCENARIO_DELVE_FULLY_COM"], dbKey = "presenceScenarioComplete", get = function() local v = getDB("presenceScenarioComplete", nil); if v ~= nil then return v end; return getDB("showScenarioEvents", true) end, set = function(v) setDB("presenceScenarioComplete", v) end },
            { type = "toggle", name = L["PRESENCE_SHOW_RARE_DEFEATED"], desc = L["NOTIFICATION_A_RARE_MOB_DEFEATED_NEARBY"], dbKey = "presenceRareDefeated", get = function() return getDB("presenceRareDefeated", true) end, set = function(v) setDB("presenceRareDefeated", v) end },
        },
    },
    {
        key       = "PresenceTypography",
        name      = L["DASH_TYPOGRAPHY"],
        desc      = L["FONTS_SIZES_COLOURS_PRESENCE_NOTIFICATIONS"],
        moduleKey = "presence",
        options = {
            { type = "section", name = L["DASH_TYPOGRAPHY"] },
            { type = "button", name = L["PRESENCE_RESET_TYPOGRAPHY_DEFAULTS"], desc = L["PRESENCE_RESET_PRESENCE_TYPOGRAPHY_OPTIONS_FONTS_SIZES"], onClick = function()
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
            end, refreshIds = { "presencePreview", "presenceTitleFontPath", "presenceSubtitleFontPath", "presenceTitleFontOutline", "presenceSubtitleFontOutline", "presencePrimaryLargeSz", "presenceSecondaryLargeSz", "presencePrimaryMediumSz", "presenceSecondaryMediumSz", "presencePrimarySmallSz", "presenceSecondarySmallSz", "presenceBossEmoteColor", "presenceDiscoveryColor", "presenceZoneTypeColoring", "presenceZoneColorFriendly", "presenceZoneColorHostile", "presenceZoneColorContested", "presenceZoneColorSanctuary" } },
            { type = "dropdown", name = L["PRESENCE_MAIN_TITLE_FONT"], desc = L["PRESENCE_FONT_FAMILY_MAIN_TITLE"], dbKey = "presenceTitleFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("presenceTitleFontPath") end, get = function() return getDB("presenceTitleFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("presenceTitleFontPath", v) end, displayFn = DisplayPerElementFont, refreshIds = { "presencePreview" }, fontPreviewInList = true },
            { type = "dropdown", name = L["PRESENCE_SUBTITLE_FONT"], desc = L["PRESENCE_FONT_FAMILY_SUBTITLE"], dbKey = "presenceSubtitleFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("presenceSubtitleFontPath") end, get = function() return getDB("presenceSubtitleFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("presenceSubtitleFontPath", v) end, displayFn = DisplayPerElementFont, refreshIds = { "presencePreview" }, fontPreviewInList = true },
            { type = "dropdown", name = L["PRESENCE_MAIN_TITLE_OUTLINE"], desc = L["PRESENCE_FONT_OUTLINE_MAIN_TITLE"], dbKey = "presenceTitleFontOutline", options = OUTLINE_OPTIONS, preserveOrder = true, get = function() return getDB("presenceTitleFontOutline", "OUTLINE") end, set = function(v) setDB("presenceTitleFontOutline", v) end, refreshIds = { "presencePreview" } },
            { type = "dropdown", name = L["PRESENCE_SUBTITLE_OUTLINE"], desc = L["PRESENCE_FONT_OUTLINE_SUBTITLE"], dbKey = "presenceSubtitleFontOutline", options = OUTLINE_OPTIONS, preserveOrder = true, get = function() return getDB("presenceSubtitleFontOutline", "OUTLINE") end, set = function(v) setDB("presenceSubtitleFontOutline", v) end, refreshIds = { "presencePreview" } },
            { type = "section", name = L["PRESENCE_LARGE_NOTIFICATIONS"] },
            { type = "slider", name = L["PRESENCE_LARGE_PRIMARY_SIZE"], desc = L["PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_TITLES_ZONE"], dbKey = "presencePrimaryLargeSz", min = 12, max = 72, get = function() return math.max(12, math.min(72, tonumber(getDB("presencePrimaryLargeSz", 48)) or 48)) end, set = function(v) setDB("presencePrimaryLargeSz", math.max(12, math.min(72, v))) end, refreshIds = { "presencePreview" } },
            { type = "slider", name = L["PRESENCE_LARGE_SECONDARY_SIZE"], desc = L["PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_SUBTITLES"], dbKey = "presenceSecondaryLargeSz", min = 12, max = 40, get = function() return math.max(12, math.min(40, tonumber(getDB("presenceSecondaryLargeSz", 24)) or 24)) end, set = function(v) setDB("presenceSecondaryLargeSz", math.max(12, math.min(40, v))) end, refreshIds = { "presencePreview" } },
            { type = "section", name = L["PRESENCE_MEDIUM_NOTIFICATIONS"] },
            { type = "slider", name = L["PRESENCE_MEDIUM_PRIMARY_SIZE"], desc = L["PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_TITLES_QUEST"], dbKey = "presencePrimaryMediumSz", min = 12, max = 72, get = function() return math.max(12, math.min(72, tonumber(getDB("presencePrimaryMediumSz", 36)) or 36)) end, set = function(v) setDB("presencePrimaryMediumSz", math.max(12, math.min(72, v))) end, refreshIds = { "presencePreview" } },
            { type = "slider", name = L["PRESENCE_MEDIUM_SECONDARY_SIZE"], desc = L["PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_SUBTITLES"], dbKey = "presenceSecondaryMediumSz", min = 12, max = 40, get = function() return math.max(12, math.min(40, tonumber(getDB("presenceSecondaryMediumSz", 22)) or 22)) end, set = function(v) setDB("presenceSecondaryMediumSz", math.max(12, math.min(40, v))) end, refreshIds = { "presencePreview" } },
            { type = "section", name = L["PRESENCE_SMALL_NOTIFICATIONS"] },
            { type = "slider", name = L["PRESENCE_SMALL_PRIMARY_SIZE"], desc = L["PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_TITLES_QUEST"], dbKey = "presencePrimarySmallSz", min = 12, max = 72, get = function() return math.max(12, math.min(72, tonumber(getDB("presencePrimarySmallSz", 28)) or 28)) end, set = function(v) setDB("presencePrimarySmallSz", math.max(12, math.min(72, v))) end, refreshIds = { "presencePreview" } },
            { type = "slider", name = L["PRESENCE_SMALL_SECONDARY_SIZE"], desc = L["PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_SUBTITLES"], dbKey = "presenceSecondarySmallSz", min = 12, max = 40, get = function() return math.max(12, math.min(40, tonumber(getDB("presenceSecondarySmallSz", 20)) or 20)) end, set = function(v) setDB("presenceSecondarySmallSz", math.max(12, math.min(40, v))) end, refreshIds = { "presencePreview" } },
            { type = "section", name = L["DASH_COLOURS"] },
            { type = "color", name = L["PRESENCE_BOSS_EMOTE_COLOUR"], desc = L["PRESENCE_COLOUR_RAID_DUNGEON_BOSS_EMOTE"], dbKey = "presenceBossEmoteColor", default = addon.PRESENCE_BOSS_EMOTE_COLOR, refreshIds = { "presencePreview" } },
            { type = "color", name = L["PRESENCE_DISCOVERY_LINE_COLOUR"], desc = L["PRESENCE_COLOUR_OF_DISCOVERED_LINE_UNDER_ZONE_TIP"], dbKey = "presenceDiscoveryColor", default = addon.PRESENCE_DISCOVERY_COLOR, refreshIds = { "presencePreview" } },
            { type = "section", name = L["ZONE_TYPE_COLOURING"] },
            { type = "toggle", name = L["COLOUR_ZONE_TYPE"], desc = L["COLOUR_ZONE_SUBZONE_TITLES_PVP_ZONE"], dbKey = "presenceZoneTypeColoring", get = function() return getDB("presenceZoneTypeColoring", false) end, set = function(v) setDB("presenceZoneTypeColoring", v) end, refreshIds = { "presencePreview" } },
            { type = "color", name = L["FRIENDLY_ZONE_COLOUR"], desc = L["COLOUR_FRIENDLY_ZONES_GREEN_DEFAULT"], dbKey = "presenceZoneColorFriendly", default = { 0.1, 1.0, 0.1 }, refreshIds = { "presencePreview" } },
            { type = "color", name = L["HOSTILE_ZONE_COLOUR"], desc = L["COLOUR_HOSTILE_ZONES_RED_DEFAULT"], dbKey = "presenceZoneColorHostile", default = { 1.0, 0.1, 0.1 }, refreshIds = { "presencePreview" } },
            { type = "color", name = L["CONTESTED_ZONE_COLOUR"], desc = L["COLOUR_CONTESTED_ZONES_ORANGE_DEFAULT"], dbKey = "presenceZoneColorContested", default = { 1.0, 0.7, 0.0 }, refreshIds = { "presencePreview" } },
            { type = "color", name = L["SANCTUARY_ZONE_COLOUR"], desc = L["COLOUR_SANCTUARY_ZONES_BLUE_DEFAULT"], dbKey = "presenceZoneColorSanctuary", default = { 0.41, 0.8, 0.94 }, refreshIds = { "presencePreview" } },
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
