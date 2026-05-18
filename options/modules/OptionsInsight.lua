--[[
    Horizon Suite - Insight - Options categories
    Self-registers into addon.OptionCategories after OptionsData.lua runs.
]]
local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L = addon.L
local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end
local FONT_USE_GLOBAL              = addon.FONT_USE_GLOBAL
local GetPerElementFontDropdownOptions = addon.GetPerElementFontDropdownOptions
local DisplayPerElementFont        = addon.DisplayPerElementFont
local Section                      = addon.Section
local Slider                       = addon.Slider
local Color                        = addon.Color
local Toggle                       = addon.Toggle

local INSIGHT_FORCE_MODIFIER_OPTIONS = {
    { L["INSIGHT_DISPLAY_MODE_HIDE"],         "hide" },
    { L["INSIGHT_DISPLAY_MODE_SHOW"],         "force" },
    { L["INSIGHT_DISPLAY_MODE_MODIFIER"], "modifier" },
}

local categories = {
    {
        key = "InsightGlobal",
        name = L["INSIGHT_CATEGORY_GLOBAL"],
        desc = L["INSIGHT_CATEGORY_GLOBAL_DESC"],
        moduleKey = "insight",
        dashboardPreviewMode = "global",
        options = {
            Section(L["AXIS_POSITION"]),
            { type = "dropdown", name = L["TOOLTIP_ANCHOR"], desc = L["AXIS_WHERE_TOOLTIPS_APPEAR_FOLLOW_CURSOR_FIXED"], dbKey = "insightAnchorMode", options = { { L["AXIS_CURSOR"], "cursor" }, { L["AXIS_FIXED"], "fixed" } }, get = function() return getDB("insightAnchorMode", "cursor") end, set = function(v) setDB("insightAnchorMode", v) end, refreshIds = { "insightCursorSide", "insightCursorOffsetX", "insightCursorOffsetY", "insightFocusDynamicInFixed" } },
            { type = "dropdown", name = L["INSIGHT_CURSOR_SIDE"], desc = L["INSIGHT_CURSOR_SIDE_DESC"], dbKey = "insightCursorSide", options = { { L["INSIGHT_CURSOR_SIDE_CENTER"], "center" }, { L["INSIGHT_CURSOR_SIDE_LEFT"], "left" }, { L["INSIGHT_CURSOR_SIDE_RIGHT"], "right" } }, get = function() return getDB("insightCursorSide", "center") end, set = function(v) setDB("insightCursorSide", v) end, visibleWhen = function() return getDB("insightAnchorMode", "cursor") == "cursor" end, refreshIds = { "insightCursorOffsetX", "insightCursorOffsetY" } },
            { type = "slider", name = L["INSIGHT_CURSOR_OFFSET_X"], desc = L["INSIGHT_CURSOR_OFFSET_X_DESC"], dbKey = "insightCursorOffsetX", min = -100, max = 100, step = 5, get = function() return math.max(-100, math.min(100, math.floor(tonumber(getDB("insightCursorOffsetX", 0)) or 0))) end, set = function(v) setDB("insightCursorOffsetX", math.max(-100, math.min(100, v))) end, visibleWhen = function() return getDB("insightAnchorMode", "cursor") == "cursor" and getDB("insightCursorSide", "center") ~= "center" end },
            { type = "slider", name = L["INSIGHT_CURSOR_OFFSET_Y"], desc = L["INSIGHT_CURSOR_OFFSET_Y_DESC"], dbKey = "insightCursorOffsetY", min = -100, max = 100, step = 5, get = function() return math.max(-100, math.min(100, math.floor(tonumber(getDB("insightCursorOffsetY", 0)) or 0))) end, set = function(v) setDB("insightCursorOffsetY", math.max(-100, math.min(100, v))) end, visibleWhen = function() return getDB("insightAnchorMode", "cursor") == "cursor" and getDB("insightCursorSide", "center") ~= "center" end },
            { type = "button", name = L["AXIS_ANCHOR_MOVE"], desc = L["AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITION"], onClick = function()
                if addon.Insight and addon.Insight.ToggleAnchorFrame then addon.Insight.ToggleAnchorFrame() end
            end },
            { type = "button", name = L["AXIS_RESET_TOOLTIP_POSITION"], desc = L["AXIS_RESET_FIXED_POSITION_DEFAULT"], onClick = function()
                setDB("insightFixedPoint", "BOTTOMRIGHT")
                setDB("insightFixedX", -60)
                setDB("insightFixedY", 120)
                if addon.Insight and addon.Insight.ApplyInsightOptions then addon.Insight.ApplyInsightOptions() end
            end },
            Toggle(L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED"], L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED_DESC"], "insightFocusDynamicInFixed", false, { visibleWhen = function() return getDB("insightAnchorMode", "cursor") == "fixed" and addon.IsModuleEnabled and addon:IsModuleEnabled("focus") end }),
            Section(L["DASH_APPEARANCE"]),
            { type = "slider", name = L["AXIS_TOOLTIP_BACKGROUND_OPACITY"], desc = L["AXIS_TOOLTIP_BG_OPACITY_PCT_DESC"], dbKey = "insightBgOpacity", min = 0, max = 100, get = function() local v = tonumber(getDB("insightBgOpacity", 0.75)) or 0.75; if v <= 1 and v > 0 then return math.floor(v * 100 + 0.5) end; return math.max(0, math.min(100, v)) end, set = function(v) setDB("insightBgOpacity", math.max(0, math.min(100, v)) / 100) end },
            { type = "dropdown", name = L["AXIS_TOOLTIP_FONT"], desc = L["AXIS_FONT_FAMILY_TOOLTIP_TEXT"], dbKey = "insightFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("insightFontPath") end, get = function() return getDB("insightFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("insightFontPath", v) end, displayFn = DisplayPerElementFont, fontPreviewInList = true },
            Section(L["INSIGHT_SECTION_COMBAT"]),
            Toggle(L["INSIGHT_HIDE_IN_COMBAT"], L["INSIGHT_HIDE_IN_COMBAT_DESC"], "insightHideTooltipsInCombat", false),
            Section(L["INSIGHT_SECTION_ICONS_AND_SEPARATORS"]),
            Toggle(L["AXIS_ICONS"], L["AXIS_FACTION_SPEC_MOUNT_MYTHIC_ICONS_TOOLTIPS"], "insightShowIcons", true, { refreshIds = { "insightClassIconSource" } }),
            { type = "dropdown", name = L["AXIS_SEPARATION"], desc = L["AXIS_SEPARATION_DESC"], dbKey = "insightSeparatorMode", options = { { L["AXIS_SEPARATION_DIVIDERS"], "divider" }, { L["AXIS_SEPARATION_BLANK"], "blank" }, { L["AXIS_SEPARATION_NONE"], "none" } }, preserveOrder = true, get = function() local v = getDB("insightSeparatorMode", nil); if v == "divider" or v == "blank" or v == "none" then return v end; return getDB("insightBlankSeparator", false) and "blank" or "divider" end, set = function(v) v = (v == "blank") and "blank" or (v == "none") and "none" or "divider"; setDB("insightSeparatorMode", v); setDB("insightBlankSeparator", v == "blank") end, tooltip = L["AXIS_SEPARATION_TOOLTIP"] },
        },
    },
    {
        key = "InsightPlayer",
        name = L["INSIGHT_CATEGORY_PLAYER"],
        desc = L["INSIGHT_CATEGORY_PLAYER_DESC"],
        moduleKey = "insight",
        dashboardPreviewMode = "player",
        options = {
            Section(L["INSIGHT_SECTION_IDENTITY"]),
            { type = "dropdown", name = L["INSIGHT_PLAYER_NAME_COLOUR"], desc = L["INSIGHT_PLAYER_NAME_COLOUR_DESC"], dbKey = "insightPlayerNameColor", options = { { L["INSIGHT_PLAYER_NAME_COLOUR_FACTION"], "faction" }, { L["INSIGHT_PLAYER_NAME_COLOUR_CLASS"], "class" } }, get = function() local v = getDB("insightPlayerNameColor", "faction"); return v == "class" and "class" or "faction" end, set = function(v) setDB("insightPlayerNameColor", v == "class" and "class" or "faction") end, refreshIds = { "insightPlayerNameGradient", "insightTitleColorMode", "insightTitleColor" } },
            Toggle(L["INSIGHT_PLAYER_NAME_GRADIENT"], L["INSIGHT_PLAYER_NAME_GRADIENT_DESC"], "insightPlayerNameGradient", false, { isNew = "4.12.6a", visibleWhen = function() return getDB("insightPlayerNameColor", "faction") == "class" end, refreshIds = { "insightTitleColorMode", "insightTitleColor" } }),
            { type = "dropdown", name = L["INSIGHT_REALM_NAMES"], desc = L["INSIGHT_REALM_NAMES_DESC"], dbKey = "insightRealmNameMode", options = { { L["INSIGHT_REALM_NAMES_FULL"], "full" }, { L["INSIGHT_REALM_NAMES_HIDE"], "hide" }, { L["INSIGHT_REALM_NAMES_MODIFIER"], "modifier" }, { L["INSIGHT_REALM_NAMES_SIMPLIFIED"], "simplified" } }, preserveOrder = true, get = function() local v = getDB("insightRealmNameMode", "full"); return (v == "full" or v == "hide" or v == "modifier" or v == "simplified") and v or "full" end, set = function(v) setDB("insightRealmNameMode", (v == "full" or v == "hide" or v == "modifier" or v == "simplified") and v or "full") end },
            Toggle(L["GUILD_RANK"], L["AXIS_APPEND_PLAYER_S_GUILD_RANK_NEXT"], "insightShowGuildRank", true),
            Toggle(L["AXIS_CHARACTER_TITLE"], L["AXIS_PLAYER_S_SELECTED_TITLE_ACHIEVEMENT_PVP"], "insightShowCharacterTitle", true, { refreshIds = { "insightTitleColorMode", "insightTitleColor" } }),
            { type = "dropdown", name = L["AXIS_TITLE_COLOUR"], desc = L["INSIGHT_TITLE_COLOUR_MODE_DESC"], dbKey = "insightTitleColorMode", options = function()
                local opts = {
                    { L["INSIGHT_TITLE_COLOUR_MATCH_NAME"], "match" },
                }
                if getDB("insightPlayerNameColor", "faction") == "class" and getDB("insightPlayerNameGradient", false) then
                    opts[#opts + 1] = { L["INSIGHT_TITLE_COLOUR_MATCH_NAME_GRADIENT"], "gradient" }
                end
                opts[#opts + 1] = { L["INSIGHT_TITLE_COLOUR_CUSTOM"], "custom" }
                return opts
            end, get = function()
                local v = getDB("insightTitleColorMode", nil)
                if v ~= "match" and v ~= "gradient" and v ~= "custom" then
                    v = getDB("insightTitleMatchNameColor", false) and "match" or "custom"
                end
                if v == "gradient" and not (getDB("insightPlayerNameColor", "faction") == "class" and getDB("insightPlayerNameGradient", false)) then
                    v = "match"
                end
                return v
            end, set = function(v) setDB("insightTitleColorMode", (v == "match" or v == "gradient" or v == "custom") and v or "custom") end, visibleWhen = function() return getDB("insightShowCharacterTitle", true) end, refreshIds = { "insightTitleColor" } },
            Color(L["INSIGHT_TITLE_CUSTOM_COLOUR"], L["AXIS_COLOUR_OF_CHARACTER_TITLE_PLAYER_TOOLTIP"], "insightTitleColor", { 1.00, 0.82, 0.00 }, { visibleWhen = function()
                local mode = getDB("insightTitleColorMode", nil)
                if mode ~= "match" and mode ~= "gradient" and mode ~= "custom" then
                    mode = getDB("insightTitleMatchNameColor", false) and "match" or "custom"
                end
                if mode == "gradient" and not (getDB("insightPlayerNameColor", "faction") == "class" and getDB("insightPlayerNameGradient", false)) then
                    mode = "match"
                end
                return getDB("insightShowCharacterTitle", true) and mode == "custom"
            end }),
            Section(L["INSIGHT_SECTION_STATUS_PVP"]),
            Toggle(L["STATUS_BADGES"], L["COMBAT_AFK_DND_PVP_PARTY_FRIENDS"], "insightShowStatusBadges", true, { refreshIds = { "insightStatusBadgeCombat", "insightStatusBadgeAFK", "insightStatusBadgeDND", "insightStatusBadgePVP", "insightStatusBadgeGroup", "insightStatusBadgeFriend", "insightStatusBadgeTargeting" } }),
            Toggle(L["INSIGHT_STATUS_BADGE_COMBAT"],           L["INSIGHT_STATUS_BADGE_COMBAT_DESC"],                   "insightStatusBadgeCombat",    true, { visibleWhen = function() return getDB("insightShowStatusBadges", true) end }),
            Toggle(L["INSIGHT_STATUS_BADGE_AFK"],                 L["INSIGHT_STATUS_BADGE_AFK_DESC"],                            "insightStatusBadgeAFK",       true, { visibleWhen = function() return getDB("insightShowStatusBadges", true) end }),
            Toggle(L["INSIGHT_STATUS_BADGE_DND"],                 L["INSIGHT_STATUS_BADGE_DND_DESC"],            "insightStatusBadgeDND",       true, { visibleWhen = function() return getDB("insightShowStatusBadges", true) end }),
            Toggle(L["INSIGHT_STATUS_BADGE_PVP"],                 L["INSIGHT_STATUS_BADGE_PVP_DESC"],                 "insightStatusBadgePVP",       true, { visibleWhen = function() return getDB("insightShowStatusBadges", true) end }),
            Toggle(L["INSIGHT_STATUS_BADGE_GROUP"],             L["INSIGHT_STATUS_BADGE_GROUP_DESC"],                              "insightStatusBadgeGroup",     true, { visibleWhen = function() return getDB("insightShowStatusBadges", true) end }),
            Toggle(L["INSIGHT_STATUS_BADGE_FRIEND"],           L["INSIGHT_STATUS_BADGE_FRIEND_DESC"],                       "insightStatusBadgeFriend",    true, { visibleWhen = function() return getDB("insightShowStatusBadges", true) end }),
            Toggle(L["INSIGHT_STATUS_BADGE_TARGETING"], L["INSIGHT_STATUS_BADGE_TARGETING_DESC"],   "insightStatusBadgeTargeting", true, { visibleWhen = function() return getDB("insightShowStatusBadges", true) end }),
            Section(L["INSIGHT_SECTION_RATINGS_GEAR"]),
            { type = "dropdown", name = L["MYTHIC_SCORE"], desc = L["INSIGHT_MYTHIC_SCORE_MODE_DESC"], dbKey = "insightMythicScoreMode", options = INSIGHT_FORCE_MODIFIER_OPTIONS, preserveOrder = true, get = function() local v = getDB("insightMythicScoreMode", nil); if v == "force" or v == "modifier" or v == "hide" then return v end; return getDB("insightShowMythicScore", false) and "force" or "hide" end, set = function(v) v = (v == "modifier") and "modifier" or (v == "force") and "force" or "hide"; setDB("insightMythicScoreMode", v); setDB("insightShowMythicScore", v == "force") end },
            { type = "dropdown", name = L["ITEM_LEVEL"], desc = L["INSIGHT_ITEM_LEVEL_MODE_DESC"], dbKey = "insightItemLevelMode", options = INSIGHT_FORCE_MODIFIER_OPTIONS, preserveOrder = true, get = function() local v = getDB("insightItemLevelMode", nil); if v == "force" or v == "modifier" or v == "hide" then return v end; return getDB("insightShowIlvl", false) and "force" or "hide" end, set = function(v) v = (v == "modifier") and "modifier" or (v == "force") and "force" or "hide"; setDB("insightItemLevelMode", v); setDB("insightShowIlvl", v == "force") end },
            { type = "dropdown", name = L["HONOR_LEVEL"], desc = L["INSIGHT_HONOR_LEVEL_MODE_DESC"], dbKey = "insightHonorLevelMode", options = INSIGHT_FORCE_MODIFIER_OPTIONS, preserveOrder = true, get = function() local v = getDB("insightHonorLevelMode", nil); if v == "force" or v == "modifier" or v == "hide" then return v end; return getDB("insightShowHonorLevel", false) and "force" or "hide" end, set = function(v) v = (v == "modifier") and "modifier" or (v == "force") and "force" or "hide"; setDB("insightHonorLevelMode", v); setDB("insightShowHonorLevel", v == "force") end },
            { type = "dropdown", name = L["INSIGHT_ACHIEVEMENT_POINTS"], desc = L["INSIGHT_ACHIEVEMENT_POINTS_MODE_DESC"], dbKey = "insightAchievementPointsMode", options = INSIGHT_FORCE_MODIFIER_OPTIONS, preserveOrder = true, get = function() local v = getDB("insightAchievementPointsMode", nil); if v == "force" or v == "modifier" or v == "hide" then return v end; return "hide" end, set = function(v) v = (v == "modifier") and "modifier" or (v == "force") and "force" or "hide"; setDB("insightAchievementPointsMode", v) end },
            Toggle(L["INSIGHT_RATINGS_ICONS"], L["INSIGHT_RATINGS_ICONS_DESC"], "insightRatingsIcons", true, { visibleWhen = function() return getDB("insightShowIcons", true) end }),
            Section(L["INSIGHT_SECTION_MOUNT"]),
            Toggle(L["MOUNT_INFO"], L["MOUNT_NAME_SOURCE_COLLECTION_STATUS"], "insightShowMount", true, { tooltip = L["SHOWN_HOVERING_A_MOUNTED_PLAYER"] }),
            { type = "dropdown", name = L["INSIGHT_MOUNT_OWNERSHIP_DISPLAY"], desc = L["INSIGHT_MOUNT_OWNERSHIP_DISPLAY_DESC"], dbKey = "insightMountOwnershipDisplay", options = { { L["INSIGHT_MOUNT_OWNERSHIP_TEXT"], "text" }, { L["INSIGHT_MOUNT_OWNERSHIP_ICONS"], "icons" } }, get = function() return getDB("insightMountOwnershipDisplay", "text") end, set = function(v) setDB("insightMountOwnershipDisplay", v) end, visibleWhen = function() return getDB("insightShowMount", true) end },
            Section(L["INSIGHT_SECTION_CLASS"]),
            Toggle(L["INSIGHT_SPEC_ROLE"], L["INSIGHT_SPEC_ROLE_DESC"], "insightShowSpecRole", true),
            Toggle(L["INSIGHT_RACE_ICONS"], L["INSIGHT_RACE_ICONS_DESC"], "insightRaceIcons", true, { visibleWhen = function() return getDB("insightShowIcons", true) end }),
            { type = "dropdown", name = L["AXIS_CLASS_ICON_STYLE"], desc = L["AXIS_DEFAULT_BLIZZARD_RONDOMEDIA_CLASS_ICONS_TH"], tooltip = (L["AXIS_CLASS_ICON_SOURCES_TOOLTIP"]) .. "\n\n" .. (L["AXIS_SPEC_OVERRIDE_INSPECT_NOTE"]), dbKey = "insightClassIconSource", options = { { L["AXIS_CUSTOM_CLASS_ICONS_LABEL"], "custom" }, { L["AXIS_DEFAULT"], "default" }, { "RondoMedia", "rondomedia" }, { L["AXIS_SPEC_OVERRIDE"], "specoverride" } }, get = function() return getDB("insightClassIconSource", "custom") end, set = function(v) setDB("insightClassIconSource", v) end, visibleWhen = function() return getDB("insightShowIcons", true) end },
            Section(L["FOCUS_FONT_SIZES"]),
            Slider(L["FOCUS_HEADER_SIZE"],         L["FOCUS_HEADER_FONT_SIZE"],                                                 "insightPlayerHeaderSize",  8, 24, 14),
            Slider(L["INSIGHT_BODY_SIZE"],           L["INSIGHT_BODY_FONT_SIZE"],                                                   "insightPlayerBodySize",    8, 20, 12),
            Slider(L["INSIGHT_BADGES_SIZE"], L["INSIGHT_BADGES_FONT_SIZE"],                                    "insightPlayerBadgesSize",  6, 20, 12),
            Slider(L["INSIGHT_STATS_SIZE"],       L["INSIGHT_STATS_FONT_SIZE"],        "insightPlayerStatsSize",   6, 20, 11),
            Slider(L["INSIGHT_MOUNT_SIZE"],         L["INSIGHT_MOUNT_FONT_SIZE"],                    "insightPlayerMountSize",   6, 20, 11),
        },
    },
    {
        key = "InsightNpc",
        name = L["INSIGHT_CATEGORY_NPC"],
        desc = L["INSIGHT_CATEGORY_NPC_DESC"],
        moduleKey = "insight",
        dashboardPreviewMode = "npc",
        options = {
            Section(L["INSIGHT_SECTION_NPC_TOOLTIP"]),
            Toggle(L["INSIGHT_NPC_REACTION_BORDER"], L["INSIGHT_NPC_REACTION_BORDER_DESC"], "insightNpcReactionBorder", true),
            Toggle(L["INSIGHT_NPC_REACTION_NAME"], L["INSIGHT_NPC_REACTION_NAME_DESC"], "insightNpcReactionName", true),
            Toggle(L["INSIGHT_NPC_LEVEL_LINE"], L["INSIGHT_NPC_LEVEL_LINE_DESC"], "insightNpcShowLevelLine", true),
            Toggle(L["AXIS_ICONS"], L["INSIGHT_NPC_ICONS_DESC"], "insightNpcShowIcons", true),
            Section(L["FOCUS_FONT_SIZES"]),
            Slider(L["FOCUS_HEADER_SIZE"], L["FOCUS_HEADER_FONT_SIZE"], "insightNpcHeaderSize", 8, 24, 14),
            Slider(L["INSIGHT_BODY_SIZE"],   L["INSIGHT_BODY_FONT_SIZE"],   "insightNpcBodySize",   8, 20, 12),
        },
    },
    {
        key = "InsightItem",
        name = L["INSIGHT_CATEGORY_ITEM"],
        desc = L["INSIGHT_CATEGORY_ITEM_DESC"],
        moduleKey = "insight",
        dashboardPreviewMode = "item",
        options = {
            Section(L["INSIGHT_SECTION_TRANSMOG"]),
            Toggle(L["TRANSMOG_STATUS"], L["AXIS_WHETHER_YOU_COLLECTED_APPEARANCE_OF_AN"], "insightShowTransmog", true),
            Section(L["INSIGHT_SECTION_ITEM_STYLING"]),
            Toggle(L["INSIGHT_ITEM_QUALITY_BORDER"], L["INSIGHT_ITEM_QUALITY_BORDER_DESC"], "insightItemQualityBorder", true),
            Toggle(L["INSIGHT_ITEM_NAME_GRADIENT"], L["INSIGHT_ITEM_NAME_GRADIENT_DESC"], "insightItemNameGradient", false, { isNew = "4.12.6a" }),
            Toggle(L["INSIGHT_ITEM_SECTION_SPACING"], L["INSIGHT_ITEM_SECTION_SPACING_DESC"], "insightItemSectionSpacing", false),
            Section(L["FOCUS_FONT_SIZES"]),
            Slider(L["FOCUS_HEADER_SIZE"],    L["FOCUS_HEADER_FONT_SIZE"],        "insightItemHeaderSize",   8, 24, 14),
            Slider(L["INSIGHT_BODY_SIZE"],      L["INSIGHT_BODY_FONT_SIZE"],    "insightItemBodySize",     8, 20, 12),
            { type = "slider", name = L["INSIGHT_TRANSMOG_SIZE"], desc = L["INSIGHT_TRANSMOG_FONT_SIZE"], dbKey = "insightItemTransmogSize", min = 6, max = 20, get = function() return getDB("insightItemTransmogSize", getDB("insightTransmogSize", 11)) end, set = function(v) setDB("insightItemTransmogSize", v) end },
        },
    },
}

for i = 1, #categories do
    addon.OptionCategories[#addon.OptionCategories + 1] = categories[i]
end
