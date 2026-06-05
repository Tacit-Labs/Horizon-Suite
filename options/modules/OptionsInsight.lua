--[[
    Horizon Suite - Insight - Options categories
    Self-registers into addon.OptionCategories after OptionsData.lua runs.
]]
local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L = addon.L
local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end
local GetPerElementFontDropdownOptions = addon.GetPerElementFontDropdownOptions
local DisplayPerElementFont            = addon.DisplayPerElementFont
local Section                          = addon.Section
local Slider                           = addon.Slider
local Color                            = addon.Color
local Toggle                           = addon.Toggle
local D   = addon.INSIGHT_DEFAULTS
local LIM = addon.INSIGHT_LIMITS
local function clamp(v, key) local lim = LIM[key]; return math.max(lim.min, math.min(lim.max, v)) end

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
            { type = "dropdown", name = L["TOOLTIP_ANCHOR"], desc = L["AXIS_WHERE_TOOLTIPS_APPEAR_FOLLOW_CURSOR_FIXED"], dbKey = "insightAnchorMode", options = { { L["AXIS_CURSOR"], "cursor" }, { L["AXIS_FIXED"], "fixed" } }, get = function() return getDB("insightAnchorMode", D.insightAnchorMode) end, set = function(v) setDB("insightAnchorMode", v) end, refreshIds = { "insightCursorSide", "insightCursorOffsetX", "insightCursorOffsetY", "insightFocusDynamicInFixed" } },
            { type = "dropdown", name = L["INSIGHT_CURSOR_SIDE"], desc = L["INSIGHT_CURSOR_SIDE_DESC"], dbKey = "insightCursorSide", options = { { L["INSIGHT_CURSOR_SIDE_CENTER"], "center" }, { L["INSIGHT_CURSOR_SIDE_LEFT"], "left" }, { L["INSIGHT_CURSOR_SIDE_RIGHT"], "right" } }, get = function() return getDB("insightCursorSide", D.insightCursorSide) end, set = function(v) setDB("insightCursorSide", v) end, visibleWhen = function() return getDB("insightAnchorMode", D.insightAnchorMode) == "cursor" end, refreshIds = { "insightCursorOffsetX", "insightCursorOffsetY" } },
            { type = "slider", name = L["INSIGHT_CURSOR_OFFSET_X"], desc = L["INSIGHT_CURSOR_OFFSET_X_DESC"], dbKey = "insightCursorOffsetX", min = LIM.insightCursorOffsetX.min, max = LIM.insightCursorOffsetX.max, step = 5, get = function() return clamp(math.floor(tonumber(getDB("insightCursorOffsetX", D.insightCursorOffsetX)) or D.insightCursorOffsetX), "insightCursorOffsetX") end, set = function(v) setDB("insightCursorOffsetX", clamp(v, "insightCursorOffsetX")) end, visibleWhen = function() return getDB("insightAnchorMode", D.insightAnchorMode) == "cursor" and getDB("insightCursorSide", D.insightCursorSide) ~= "center" end },
            { type = "slider", name = L["INSIGHT_CURSOR_OFFSET_Y"], desc = L["INSIGHT_CURSOR_OFFSET_Y_DESC"], dbKey = "insightCursorOffsetY", min = LIM.insightCursorOffsetY.min, max = LIM.insightCursorOffsetY.max, step = 5, get = function() return clamp(math.floor(tonumber(getDB("insightCursorOffsetY", D.insightCursorOffsetY)) or D.insightCursorOffsetY), "insightCursorOffsetY") end, set = function(v) setDB("insightCursorOffsetY", clamp(v, "insightCursorOffsetY")) end, visibleWhen = function() return getDB("insightAnchorMode", D.insightAnchorMode) == "cursor" and getDB("insightCursorSide", D.insightCursorSide) ~= "center" end },
            { type = "button", name = L["AXIS_ANCHOR_MOVE"], desc = L["AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITION"], onClick = function()
                if addon.Insight and addon.Insight.ToggleAnchorFrame then addon.Insight.ToggleAnchorFrame() end
            end },
            { type = "button", name = L["AXIS_RESET_TOOLTIP_POSITION"], desc = L["AXIS_RESET_FIXED_POSITION_DEFAULT"], onClick = function()
                setDB("insightFixedPoint", D.insightFixedPoint)
                setDB("insightFixedX", D.insightFixedX)
                setDB("insightFixedY", D.insightFixedY)
                if addon.Insight and addon.Insight.ApplyInsightOptions then addon.Insight.ApplyInsightOptions() end
            end },
            Toggle(L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED"], L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED_DESC"], "insightFocusDynamicInFixed", D.insightFocusDynamicInFixed, { visibleWhen = function() return getDB("insightAnchorMode", D.insightAnchorMode) == "fixed" and addon.IsModuleEnabled and addon:IsModuleEnabled("focus") end }),
            Section(L["DASH_APPEARANCE"]),
            { type = "slider", name = L["AXIS_TOOLTIP_BACKGROUND_OPACITY"], desc = L["AXIS_TOOLTIP_BG_OPACITY_PCT_DESC"], dbKey = "insightBgOpacity", min = LIM.insightBgOpacity.min, max = LIM.insightBgOpacity.max, get = function() local v = tonumber(getDB("insightBgOpacity", D.insightBgOpacity)) or D.insightBgOpacity; if v <= 1 and v > 0 then return math.floor(v * 100 + 0.5) end; return clamp(v, "insightBgOpacity") end, set = function(v) setDB("insightBgOpacity", clamp(v, "insightBgOpacity") / 100) end },
            { type = "color", name = L["INSIGHT_CATEGORY_PLAYER"] .. " " .. L["AXIS_TOOLTIP_BACKGROUND_COLOUR"], desc = L["AXIS_COLOUR_OF_TOOLTIP_BACKGROUND"], dbKey = "insightPlayerBgColor", default = { 0, 0, 0 }, get = function() local c = getDB("insightPlayerBgColor", nil); if c and type(c) == "table" and c[1] and c[2] and c[3] then return c[1], c[2], c[3] end; return 0, 0, 0 end, set = function(r, g, b) setDB("insightPlayerBgColor", { r, g, b }) end },
            { type = "color", name = L["INSIGHT_CATEGORY_NPC"]    .. " " .. L["AXIS_TOOLTIP_BACKGROUND_COLOUR"], desc = L["AXIS_COLOUR_OF_TOOLTIP_BACKGROUND"], dbKey = "insightNpcBgColor",    default = { 0, 0, 0 }, get = function() local c = getDB("insightNpcBgColor",    nil); if c and type(c) == "table" and c[1] and c[2] and c[3] then return c[1], c[2], c[3] end; return 0, 0, 0 end, set = function(r, g, b) setDB("insightNpcBgColor",    { r, g, b }) end },
            { type = "color", name = L["INSIGHT_CATEGORY_ITEM"]   .. " " .. L["AXIS_TOOLTIP_BACKGROUND_COLOUR"], desc = L["AXIS_COLOUR_OF_TOOLTIP_BACKGROUND"], dbKey = "insightItemBgColor",   default = { 0, 0, 0 }, get = function() local c = getDB("insightItemBgColor",   nil); if c and type(c) == "table" and c[1] and c[2] and c[3] then return c[1], c[2], c[3] end; return 0, 0, 0 end, set = function(r, g, b) setDB("insightItemBgColor",   { r, g, b }) end },
            { type = "dropdown", name = L["AXIS_TOOLTIP_FONT"], desc = L["AXIS_FONT_FAMILY_TOOLTIP_TEXT"], dbKey = "insightFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("insightFontPath") end, get = function() return getDB("insightFontPath", D.insightFontPath) end, set = function(v) setDB("insightFontPath", v) end, displayFn = DisplayPerElementFont, fontPreviewInList = true },
            Section(L["INSIGHT_SECTION_COMBAT"]),
            Toggle(L["INSIGHT_HIDE_IN_COMBAT"], L["INSIGHT_HIDE_IN_COMBAT_DESC"], "insightHideTooltipsInCombat", D.insightHideTooltipsInCombat),
            Section(L["INSIGHT_SECTION_ICONS_AND_SEPARATORS"]),
            Toggle(L["AXIS_ICONS"], L["AXIS_FACTION_SPEC_MOUNT_MYTHIC_ICONS_TOOLTIPS"], "insightShowIcons", D.insightShowIcons, { refreshIds = { "insightClassIconSource" } }),
            { type = "dropdown", name = L["AXIS_SEPARATION"], desc = L["AXIS_SEPARATION_DESC"], dbKey = "insightSeparatorMode", options = { { L["AXIS_SEPARATION_DIVIDERS"], "divider" }, { L["AXIS_SEPARATION_BLANK"], "blank" }, { L["AXIS_SEPARATION_NONE"], "none" } }, preserveOrder = true, get = function() local v = getDB("insightSeparatorMode", nil); if v == "divider" or v == "blank" or v == "none" then return v end; return getDB("insightBlankSeparator", D.insightBlankSeparator) and "blank" or "divider" end, set = function(v) v = (v == "blank") and "blank" or (v == "none") and "none" or "divider"; setDB("insightSeparatorMode", v); setDB("insightBlankSeparator", v == "blank") end, tooltip = L["AXIS_SEPARATION_TOOLTIP"] },
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
            { type = "dropdown", name = L["INSIGHT_PLAYER_NAME_COLOUR"], desc = L["INSIGHT_PLAYER_NAME_COLOUR_DESC"], dbKey = "insightPlayerNameColor", options = { { L["INSIGHT_PLAYER_NAME_COLOUR_FACTION"], "faction" }, { L["INSIGHT_PLAYER_NAME_COLOUR_CLASS"], "class" } }, get = function() local v = getDB("insightPlayerNameColor", D.insightPlayerNameColor); return v == "class" and "class" or "faction" end, set = function(v) setDB("insightPlayerNameColor", v == "class" and "class" or "faction") end, refreshIds = { "insightPlayerNameGradient", "insightTitleColorMode", "insightTitleColor" } },
            Toggle(L["INSIGHT_PLAYER_NAME_GRADIENT"], L["INSIGHT_PLAYER_NAME_GRADIENT_DESC"], "insightPlayerNameGradient", D.insightPlayerNameGradient, { isNew = "4.12.6a", visibleWhen = function() return getDB("insightPlayerNameColor", D.insightPlayerNameColor) == "class" end, refreshIds = { "insightTitleColorMode", "insightTitleColor" } }),
            Slider(L["INSIGHT_GRADIENT_BIAS"], L["INSIGHT_GRADIENT_BIAS_DESC"], "insightPlayerGradientBias", LIM.insightPlayerGradientBias.min, LIM.insightPlayerGradientBias.max, D.insightPlayerGradientBias, { visibleWhen = function() return getDB("insightPlayerNameColor", D.insightPlayerNameColor) == "class" and getDB("insightPlayerNameGradient", D.insightPlayerNameGradient) end }),
            { type = "dropdown", name = L["INSIGHT_PLAYER_TOOLTIP_BORDER"], desc = L["INSIGHT_PLAYER_TOOLTIP_BORDER_DESC"], dbKey = "insightPlayerTooltipBorder", options = { { L["INSIGHT_PLAYER_TOOLTIP_BORDER_NONE"], "none" }, { L["INSIGHT_PLAYER_TOOLTIP_BORDER_CLASS"], "class" }, { L["INSIGHT_PLAYER_TOOLTIP_BORDER_FACTION"], "faction" } }, preserveOrder = true, get = function() local v = getDB("insightPlayerTooltipBorder", D.insightPlayerTooltipBorder); return (v == "none" or v == "class" or v == "faction") and v or D.insightPlayerTooltipBorder end, set = function(v) setDB("insightPlayerTooltipBorder", (v == "none" or v == "class" or v == "faction") and v or D.insightPlayerTooltipBorder) end },
            { type = "dropdown", name = L["INSIGHT_REALM_NAMES"], desc = L["INSIGHT_REALM_NAMES_DESC"], dbKey = "insightRealmNameMode", options = { { L["INSIGHT_REALM_NAMES_FULL"], "full" }, { L["INSIGHT_REALM_NAMES_HIDE"], "hide" }, { L["INSIGHT_REALM_NAMES_MODIFIER"], "modifier" }, { L["INSIGHT_REALM_NAMES_SIMPLIFIED"], "simplified" } }, preserveOrder = true, get = function() local v = getDB("insightRealmNameMode", D.insightRealmNameMode); return (v == "full" or v == "hide" or v == "modifier" or v == "simplified") and v or D.insightRealmNameMode end, set = function(v) setDB("insightRealmNameMode", (v == "full" or v == "hide" or v == "modifier" or v == "simplified") and v or D.insightRealmNameMode) end },
            Toggle(L["GUILD_RANK"], L["AXIS_APPEND_PLAYER_S_GUILD_RANK_NEXT"], "insightShowGuildRank", D.insightShowGuildRank),
            Toggle(L["AXIS_CHARACTER_TITLE"], L["AXIS_PLAYER_S_SELECTED_TITLE_ACHIEVEMENT_PVP"], "insightShowCharacterTitle", D.insightShowCharacterTitle, { refreshIds = { "insightTitleColorMode", "insightTitleColor" } }),
            { type = "dropdown", name = L["AXIS_TITLE_COLOUR"], desc = L["INSIGHT_TITLE_COLOUR_MODE_DESC"], dbKey = "insightTitleColorMode", options = function()
                local opts = {
                    { L["INSIGHT_TITLE_COLOUR_MATCH_NAME"], "match" },
                }
                if getDB("insightPlayerNameColor", D.insightPlayerNameColor) == "class" and getDB("insightPlayerNameGradient", D.insightPlayerNameGradient) then
                    opts[#opts + 1] = { L["INSIGHT_TITLE_COLOUR_MATCH_NAME_GRADIENT"], "gradient" }
                end
                opts[#opts + 1] = { L["INSIGHT_TITLE_COLOUR_CUSTOM"], "custom" }
                return opts
            end, get = function()
                local v = getDB("insightTitleColorMode", nil)
                if v ~= "match" and v ~= "gradient" and v ~= "custom" then
                    v = getDB("insightTitleMatchNameColor", D.insightTitleMatchNameColor) and "match" or "custom"
                end
                if v == "gradient" and not (getDB("insightPlayerNameColor", D.insightPlayerNameColor) == "class" and getDB("insightPlayerNameGradient", D.insightPlayerNameGradient)) then
                    v = "match"
                end
                return v
            end, set = function(v) setDB("insightTitleColorMode", (v == "match" or v == "gradient" or v == "custom") and v or "custom") end, visibleWhen = function() return getDB("insightShowCharacterTitle", D.insightShowCharacterTitle) end, refreshIds = { "insightTitleColor" } },
            Color(L["INSIGHT_TITLE_CUSTOM_COLOUR"], L["AXIS_COLOUR_OF_CHARACTER_TITLE_PLAYER_TOOLTIP"], "insightTitleColor", { D.insightTitleColorR, D.insightTitleColorG, D.insightTitleColorB }, { visibleWhen = function()
                local mode = getDB("insightTitleColorMode", nil)
                if mode ~= "match" and mode ~= "gradient" and mode ~= "custom" then
                    mode = getDB("insightTitleMatchNameColor", D.insightTitleMatchNameColor) and "match" or "custom"
                end
                if mode == "gradient" and not (getDB("insightPlayerNameColor", D.insightPlayerNameColor) == "class" and getDB("insightPlayerNameGradient", D.insightPlayerNameGradient)) then
                    mode = "match"
                end
                return getDB("insightShowCharacterTitle", D.insightShowCharacterTitle) and mode == "custom"
            end }),
            Section(L["INSIGHT_SECTION_STATUS_PVP"]),
            Toggle(L["STATUS_BADGES"], L["COMBAT_AFK_DND_PVP_PARTY_FRIENDS"], "insightShowStatusBadges", D.insightShowStatusBadges, { refreshIds = { "insightStatusBadgeCombat", "insightStatusBadgeAFK", "insightStatusBadgeAFKInHeader", "insightStatusBadgePVP", "insightStatusBadgeGroup", "insightStatusBadgeFriend", "insightStatusBadgeTargeting" } }),
            Toggle(L["INSIGHT_STATUS_BADGE_COMBAT"],       L["INSIGHT_STATUS_BADGE_COMBAT_DESC"],         "insightStatusBadgeCombat",    D.insightStatusBadgeCombat,    { visibleWhen = function() return getDB("insightShowStatusBadges", D.insightShowStatusBadges) end }),
            Toggle(L["INSIGHT_STATUS_BADGE_AFK"],          L["INSIGHT_STATUS_BADGE_AFK_DESC"],            "insightStatusBadgeAFK",       D.insightStatusBadgeAFK,       { visibleWhen = function() return getDB("insightShowStatusBadges", D.insightShowStatusBadges) end, refreshIds = { "insightStatusBadgeAFKInHeader" } }),
            Toggle(L["INSIGHT_STATUS_BADGE_AFK_IN_HEADER"],L["INSIGHT_STATUS_BADGE_AFK_IN_HEADER_DESC"], "insightStatusBadgeAFKInHeader", D.insightStatusBadgeAFKInHeader, { visibleWhen = function() return getDB("insightShowStatusBadges", D.insightShowStatusBadges) and getDB("insightStatusBadgeAFK", D.insightStatusBadgeAFK) end }),
            Toggle(L["INSIGHT_STATUS_BADGE_PVP"],          L["INSIGHT_STATUS_BADGE_PVP_DESC"],            "insightStatusBadgePVP",       D.insightStatusBadgePVP,       { visibleWhen = function() return getDB("insightShowStatusBadges", D.insightShowStatusBadges) end }),
            Toggle(L["INSIGHT_STATUS_BADGE_GROUP"],        L["INSIGHT_STATUS_BADGE_GROUP_DESC"],          "insightStatusBadgeGroup",     D.insightStatusBadgeGroup,     { visibleWhen = function() return getDB("insightShowStatusBadges", D.insightShowStatusBadges) end }),
            Toggle(L["INSIGHT_STATUS_BADGE_FRIEND"],       L["INSIGHT_STATUS_BADGE_FRIEND_DESC"],         "insightStatusBadgeFriend",    D.insightStatusBadgeFriend,    { visibleWhen = function() return getDB("insightShowStatusBadges", D.insightShowStatusBadges) end }),
            Toggle(L["INSIGHT_STATUS_BADGE_TARGETING"],    L["INSIGHT_STATUS_BADGE_TARGETING_DESC"],      "insightStatusBadgeTargeting", D.insightStatusBadgeTargeting, { visibleWhen = function() return getDB("insightShowStatusBadges", D.insightShowStatusBadges) end }),
            Toggle(L["INSIGHT_TARGETING_LINE"],            L["INSIGHT_TARGETING_LINE_DESC"],              "insightShowTargeting",        D.insightShowTargeting),
            Section(L["INSIGHT_SECTION_RATINGS_GEAR"]),
            { type = "dropdown", name = L["MYTHIC_SCORE"], desc = L["INSIGHT_MYTHIC_SCORE_MODE_DESC"], dbKey = "insightMythicScoreMode", options = INSIGHT_FORCE_MODIFIER_OPTIONS, preserveOrder = true, get = function() local v = getDB("insightMythicScoreMode", nil); if v == "force" or v == "modifier" or v == "hide" then return v end; return getDB("insightShowMythicScore", D.insightShowMythicScore) and "force" or "hide" end, set = function(v) v = (v == "modifier") and "modifier" or (v == "force") and "force" or "hide"; setDB("insightMythicScoreMode", v); setDB("insightShowMythicScore", v == "force") end },
            { type = "dropdown", name = L["ITEM_LEVEL"], desc = L["INSIGHT_ITEM_LEVEL_MODE_DESC"], dbKey = "insightItemLevelMode", options = INSIGHT_FORCE_MODIFIER_OPTIONS, preserveOrder = true, get = function() local v = getDB("insightItemLevelMode", nil); if v == "force" or v == "modifier" or v == "hide" then return v end; return getDB("insightShowIlvl", D.insightShowIlvl) and "force" or "hide" end, set = function(v) v = (v == "modifier") and "modifier" or (v == "force") and "force" or "hide"; setDB("insightItemLevelMode", v); setDB("insightShowIlvl", v == "force") end },
            { type = "dropdown", name = L["HONOR_LEVEL"], desc = L["INSIGHT_HONOR_LEVEL_MODE_DESC"], dbKey = "insightHonorLevelMode", options = INSIGHT_FORCE_MODIFIER_OPTIONS, preserveOrder = true, get = function() local v = getDB("insightHonorLevelMode", nil); if v == "force" or v == "modifier" or v == "hide" then return v end; return getDB("insightShowHonorLevel", D.insightShowHonorLevel) and "force" or "hide" end, set = function(v) v = (v == "modifier") and "modifier" or (v == "force") and "force" or "hide"; setDB("insightHonorLevelMode", v); setDB("insightShowHonorLevel", v == "force") end },
            { type = "dropdown", name = L["INSIGHT_ACHIEVEMENT_POINTS"], desc = L["INSIGHT_ACHIEVEMENT_POINTS_MODE_DESC"], dbKey = "insightAchievementPointsMode", options = INSIGHT_FORCE_MODIFIER_OPTIONS, preserveOrder = true, get = function() local v = getDB("insightAchievementPointsMode", nil); if v == "force" or v == "modifier" or v == "hide" then return v end; return "hide" end, set = function(v) v = (v == "modifier") and "modifier" or (v == "force") and "force" or "hide"; setDB("insightAchievementPointsMode", v) end },
            Toggle(L["INSIGHT_RATINGS_ICONS"], L["INSIGHT_RATINGS_ICONS_DESC"], "insightRatingsIcons", D.insightRatingsIcons, { visibleWhen = function() return getDB("insightShowIcons", D.insightShowIcons) end }),
            Section(L["INSIGHT_SECTION_MOUNT"]),
            Toggle(L["MOUNT_INFO"], L["MOUNT_NAME_SOURCE_COLLECTION_STATUS"], "insightShowMount", D.insightShowMount, { tooltip = L["SHOWN_HOVERING_A_MOUNTED_PLAYER"] }),
            { type = "dropdown", name = L["INSIGHT_MOUNT_OWNERSHIP_DISPLAY"], desc = L["INSIGHT_MOUNT_OWNERSHIP_DISPLAY_DESC"], dbKey = "insightMountOwnershipDisplay", options = { { L["INSIGHT_MOUNT_OWNERSHIP_TEXT"], "text" }, { L["INSIGHT_MOUNT_OWNERSHIP_ICONS"], "icons" } }, get = function() return getDB("insightMountOwnershipDisplay", D.insightMountOwnershipDisplay) end, set = function(v) setDB("insightMountOwnershipDisplay", v) end, visibleWhen = function() return getDB("insightShowMount", D.insightShowMount) end },
            Section(L["INSIGHT_SECTION_CLASS"]),
            Toggle(L["INSIGHT_SPEC_ROLE"], L["INSIGHT_SPEC_ROLE_DESC"], "insightShowSpecRole", D.insightShowSpecRole),
            Toggle(L["INSIGHT_RACE_ICONS"], L["INSIGHT_RACE_ICONS_DESC"], "insightRaceIcons", D.insightRaceIcons, { visibleWhen = function() return getDB("insightShowIcons", D.insightShowIcons) end }),
            { type = "dropdown", name = L["AXIS_CLASS_ICON_STYLE"], desc = L["AXIS_DEFAULT_BLIZZARD_RONDOMEDIA_CLASS_ICONS_TH"], tooltip = (L["AXIS_CLASS_ICON_SOURCES_TOOLTIP"]) .. "\n\n" .. (L["AXIS_SPEC_OVERRIDE_INSPECT_NOTE"]), dbKey = "insightClassIconSource", options = { { L["AXIS_CUSTOM_CLASS_ICONS_LABEL"], "custom" }, { L["AXIS_DEFAULT"], "default" }, { "RondoMedia", "rondomedia" }, { L["AXIS_SPEC_OVERRIDE"], "specoverride" } }, get = function() return getDB("insightClassIconSource", D.insightClassIconSource) end, set = function(v) setDB("insightClassIconSource", v) end, visibleWhen = function() return getDB("insightShowIcons", D.insightShowIcons) end },
            Section(L["FOCUS_FONT_SIZES"]),
            Slider(L["FOCUS_HEADER_SIZE"],  L["FOCUS_HEADER_FONT_SIZE"],   "insightPlayerHeaderSize",  LIM.insightPlayerHeaderSize.min,  LIM.insightPlayerHeaderSize.max,  D.insightPlayerHeaderSize),
            Slider(L["INSIGHT_BODY_SIZE"],  L["INSIGHT_BODY_FONT_SIZE"],   "insightPlayerBodySize",    LIM.insightPlayerBodySize.min,    LIM.insightPlayerBodySize.max,    D.insightPlayerBodySize),
            Slider(L["INSIGHT_BADGES_SIZE"],L["INSIGHT_BADGES_FONT_SIZE"], "insightPlayerBadgesSize",  LIM.insightPlayerBadgesSize.min,  LIM.insightPlayerBadgesSize.max,  D.insightPlayerBadgesSize),
            Slider(L["INSIGHT_STATS_SIZE"], L["INSIGHT_STATS_FONT_SIZE"],  "insightPlayerStatsSize",   LIM.insightPlayerStatsSize.min,   LIM.insightPlayerStatsSize.max,   D.insightPlayerStatsSize),
            Slider(L["INSIGHT_MOUNT_SIZE"], L["INSIGHT_MOUNT_FONT_SIZE"],  "insightPlayerMountSize",   LIM.insightPlayerMountSize.min,   LIM.insightPlayerMountSize.max,   D.insightPlayerMountSize),
        },
    },
    {
        key = "InsightTRP3",
        name = L["INSIGHT_CATEGORY_TRP3"],
        desc = L["INSIGHT_CATEGORY_TRP3_DESC"],
        hidden = function()
            -- Show if TRP3 is already active this session
            if TRP3_API then return false end
            -- Show if TRP3 is installed and enabled (handles HS loading before TRP3)
            if C_AddOns and C_AddOns.GetAddOnInfo then
                local ok, _, _, _, loadable = pcall(C_AddOns.GetAddOnInfo, "totalRP3")
                if ok and loadable then return false end
            end
            return true
        end,
        moduleKey = "insight",
        dashboardPreviewMode = "player",
        options = {
            { type = "section", name = L["INSIGHT_CATEGORY_TRP3"], headerToggle = { dbKey = "insightTRP3Enabled", default = true }, dbKey = "insightTRP3Section" },
            { type = "toggle", name = L["INSIGHT_TRP3_CHARACTER_ICON"],      desc = L["INSIGHT_TRP3_CHARACTER_ICON_DESC"],                          dbKey = "insightTRP3Icon",         get = function() return getDB("insightTRP3Icon",         true)  end, set = function(v) setDB("insightTRP3Icon",         v) end, visibleWhen = function() return getDB("insightTRP3RPName", true) end },
            Toggle(L["INSIGHT_TRP3_TITLE"], L["INSIGHT_TRP3_TITLE_DESC"], "insightTRP3Title", true),
            { type = "toggle", name = L["INSIGHT_TRP3_NAME"],             desc = L["INSIGHT_TRP3_NAME_DESC"],                                   dbKey = "insightTRP3RPName",       get = function() return getDB("insightTRP3RPName",       true)  end, set = function(v) setDB("insightTRP3RPName",       v) end, refreshIds = { "insightTRP3Section" } },
            Toggle(L["INSIGHT_TITLE_CUSTOM_COLOUR"], L["INSIGHT_TRP3_COLOUR_DESC"], "insightTRP3CustomColor", true),
            Toggle(L["INSIGHT_TRP3_BORDER_COLOUR"], L["INSIGHT_TRP3_BORDER_COLOUR_DESC"], "insightTRP3BorderColor", false),
            { type = "toggle", name = L["INSIGHT_TRP3_STATUS"],     desc = L["INSIGHT_TRP3_STATUS_DESC"],                             dbKey = "insightTRP3ICStatus",     get = function() return getDB("insightTRP3ICStatus",    true)  end, set = function(v) setDB("insightTRP3ICStatus",    v) end, refreshIds = { "insightTRP3Section" } },
            { type = "toggle", name = L["INSIGHT_TRP3_STATUS_ICON"],  desc = L["INSIGHT_TRP3_STATUS_ICON_DESC"],                                  dbKey = "insightTRP3ICStatusIcon", get = function() return getDB("insightTRP3ICStatusIcon", false) end, set = function(v) setDB("insightTRP3ICStatusIcon", v) end, visibleWhen = function() return getDB("insightTRP3ICStatus", true) end },
            Toggle(L["INSIGHT_TRP3_PRONOUNS"], L["INSIGHT_TRP3_PRONOUNS_DESC"], "insightTRP3Pronouns", true),
            Toggle(L["INSIGHT_TRP3_RACE_CLASS"], L["INSIGHT_TRP3_RACE_CLASS_DESC"], "insightTRP3RaceClass", true),
            Toggle(L["INSIGHT_TRP3_GUILD"], L["INSIGHT_TRP3_GUILD_DESC"], "insightTRP3Guild", true),
            Toggle(L["INSIGHT_TRP3_CURRENTLY"], L["INSIGHT_TRP3_CURRENTLY_DESC"], "insightTRP3Currently", true),
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
            Toggle(L["INSIGHT_NPC_REACTION_BORDER"], L["INSIGHT_NPC_REACTION_BORDER_DESC"], "insightNpcReactionBorder", D.insightNpcReactionBorder),
            Toggle(L["INSIGHT_NPC_REACTION_NAME"],   L["INSIGHT_NPC_REACTION_NAME_DESC"],   "insightNpcReactionName",   D.insightNpcReactionName),
            Toggle(L["INSIGHT_NPC_LEVEL_LINE"],      L["INSIGHT_NPC_LEVEL_LINE_DESC"],      "insightNpcShowLevelLine",  D.insightNpcShowLevelLine),
            Toggle(L["AXIS_ICONS"],                  L["INSIGHT_NPC_ICONS_DESC"],           "insightNpcShowIcons",      D.insightNpcShowIcons),
            Toggle(L["INSIGHT_TARGETING_LINE"],      L["INSIGHT_TARGETING_LINE_DESC"],      "insightNpcShowTargeting",  D.insightNpcShowTargeting),
            Section(L["FOCUS_FONT_SIZES"]),
            Slider(L["FOCUS_HEADER_SIZE"], L["FOCUS_HEADER_FONT_SIZE"], "insightNpcHeaderSize", LIM.insightNpcHeaderSize.min, LIM.insightNpcHeaderSize.max, D.insightNpcHeaderSize),
            Slider(L["INSIGHT_BODY_SIZE"], L["INSIGHT_BODY_FONT_SIZE"], "insightNpcBodySize",   LIM.insightNpcBodySize.min,   LIM.insightNpcBodySize.max,   D.insightNpcBodySize),
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
            Toggle(L["TRANSMOG_STATUS"],           L["AXIS_WHETHER_YOU_COLLECTED_APPEARANCE_OF_AN"], "insightShowTransmog",       D.insightShowTransmog),
            Section(L["INSIGHT_SECTION_ITEM_STYLING"]),
            Toggle(L["INSIGHT_ITEM_QUALITY_BORDER"],  L["INSIGHT_ITEM_QUALITY_BORDER_DESC"],  "insightItemQualityBorder",  D.insightItemQualityBorder),
            Toggle(L["INSIGHT_ITEM_NAME_GRADIENT"],   L["INSIGHT_ITEM_NAME_GRADIENT_DESC"],   "insightItemNameGradient",   D.insightItemNameGradient,   { isNew = "4.12.6a" }),
            Slider(L["INSIGHT_GRADIENT_BIAS"], L["INSIGHT_GRADIENT_BIAS_DESC"], "insightItemGradientBias", LIM.insightItemGradientBias.min, LIM.insightItemGradientBias.max, D.insightItemGradientBias, { visibleWhen = function() return getDB("insightItemNameGradient", D.insightItemNameGradient) end }),
            Toggle(L["INSIGHT_ITEM_SECTION_SPACING"], L["INSIGHT_ITEM_SECTION_SPACING_DESC"], "insightItemSectionSpacing", D.insightItemSectionSpacing),
            Section(L["FOCUS_FONT_SIZES"]),
            Slider(L["FOCUS_HEADER_SIZE"], L["FOCUS_HEADER_FONT_SIZE"], "insightItemHeaderSize",   LIM.insightItemHeaderSize.min,   LIM.insightItemHeaderSize.max,   D.insightItemHeaderSize),
            Slider(L["INSIGHT_BODY_SIZE"], L["INSIGHT_BODY_FONT_SIZE"], "insightItemBodySize",     LIM.insightItemBodySize.min,     LIM.insightItemBodySize.max,     D.insightItemBodySize),
            { type = "slider", name = L["INSIGHT_TRANSMOG_SIZE"], desc = L["INSIGHT_TRANSMOG_FONT_SIZE"], dbKey = "insightItemTransmogSize", min = LIM.insightItemTransmogSize.min, max = LIM.insightItemTransmogSize.max, get = function() return getDB("insightItemTransmogSize", getDB("insightTransmogSize", D.insightItemTransmogSize)) end, set = function(v) setDB("insightItemTransmogSize", v) end },
        },
    },
}

for i = 1, #categories do
    addon.OptionCategories[#addon.OptionCategories + 1] = categories[i]
end
