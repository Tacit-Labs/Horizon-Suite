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

local INSIGHT_FORCE_MODIFIER_OPTIONS = {
    { L["INSIGHT_DISPLAY_MODE_HIDE"] or "Hide",         "hide" },
    { L["INSIGHT_DISPLAY_MODE_SHOW"] or "Show",         "force" },
    { L["INSIGHT_DISPLAY_MODE_MODIFIER"] or "Modifier", "modifier" },
}

local function Toggle(name, desc, dbKey, default, opts)
    local t = { type = "toggle", name = name, desc = desc, dbKey = dbKey,
        get = function() return getDB(dbKey, default) end,
        set = function(v) setDB(dbKey, v) end,
    }
    if opts then for k, v in pairs(opts) do t[k] = v end end
    return t
end

local categories = {
    {
        key = "InsightGlobal",
        name = L["INSIGHT_CATEGORY_GLOBAL"] or "Global Tooltips",
        desc = L["INSIGHT_CATEGORY_GLOBAL_DESC"] or "Anchor, backdrop, font family, and display options shared across tooltip types.",
        moduleKey = "insight",
        dashboardPreviewMode = "global",
        options = {
            { type = "section", name = L["AXIS_POSITION"] or "Position" },
            { type = "dropdown", name = L["TOOLTIP_ANCHOR"] or "Tooltip anchor", desc = L["AXIS_WHERE_TOOLTIPS_APPEAR_FOLLOW_CURSOR_FIXED"] or "Where tooltips appear: follow cursor or fixed position.", dbKey = "insightAnchorMode", options = { { L["AXIS_CURSOR"] or "Cursor", "cursor" }, { L["AXIS_FIXED"] or "Fixed", "fixed" } }, get = function() return getDB("insightAnchorMode", "cursor") end, set = function(v) setDB("insightAnchorMode", v) end, refreshIds = { "insightCursorSide", "insightCursorOffsetX", "insightCursorOffsetY", "insightFocusDynamicInFixed" } },
            { type = "dropdown", name = L["INSIGHT_CURSOR_SIDE"] or "Cursor side", desc = L["INSIGHT_CURSOR_SIDE_DESC"] or "Which side of the cursor the tooltip appears on.", dbKey = "insightCursorSide", options = { { L["INSIGHT_CURSOR_SIDE_CENTER"] or "Center", "center" }, { L["INSIGHT_CURSOR_SIDE_LEFT"] or "Left", "left" }, { L["INSIGHT_CURSOR_SIDE_RIGHT"] or "Right", "right" } }, get = function() return getDB("insightCursorSide", "center") end, set = function(v) setDB("insightCursorSide", v) end, visibleWhen = function() return getDB("insightAnchorMode", "cursor") == "cursor" end, refreshIds = { "insightCursorOffsetX", "insightCursorOffsetY" } },
            { type = "slider", name = L["INSIGHT_CURSOR_OFFSET_X"] or "Cursor offset X", desc = L["INSIGHT_CURSOR_OFFSET_X_DESC"] or "Horizontal pixel offset from the cursor anchor position.", dbKey = "insightCursorOffsetX", min = -100, max = 100, step = 5, get = function() return math.max(-100, math.min(100, math.floor(tonumber(getDB("insightCursorOffsetX", 0)) or 0))) end, set = function(v) setDB("insightCursorOffsetX", math.max(-100, math.min(100, v))) end, visibleWhen = function() return getDB("insightAnchorMode", "cursor") == "cursor" and getDB("insightCursorSide", "center") ~= "center" end },
            { type = "slider", name = L["INSIGHT_CURSOR_OFFSET_Y"] or "Cursor offset Y", desc = L["INSIGHT_CURSOR_OFFSET_Y_DESC"] or "Vertical pixel offset from the cursor anchor position.", dbKey = "insightCursorOffsetY", min = -100, max = 100, step = 5, get = function() return math.max(-100, math.min(100, math.floor(tonumber(getDB("insightCursorOffsetY", 0)) or 0))) end, set = function(v) setDB("insightCursorOffsetY", math.max(-100, math.min(100, v))) end, visibleWhen = function() return getDB("insightAnchorMode", "cursor") == "cursor" and getDB("insightCursorSide", "center") ~= "center" end },
            { type = "button", name = L["AXIS_ANCHOR_MOVE"] or "Show anchor to move", desc = L["AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITION"] or "Click to show or hide the anchor. Drag to set position, right-click to confirm.", onClick = function()
                if addon.Insight and addon.Insight.ToggleAnchorFrame then addon.Insight.ToggleAnchorFrame() end
            end },
            { type = "button", name = L["AXIS_RESET_TOOLTIP_POSITION"] or "Reset tooltip position", desc = L["AXIS_RESET_FIXED_POSITION_DEFAULT"] or "Reset fixed position to default.", onClick = function()
                setDB("insightFixedPoint", "BOTTOMRIGHT")
                setDB("insightFixedX", -60)
                setDB("insightFixedY", 120)
                if addon.Insight and addon.Insight.ApplyInsightOptions then addon.Insight.ApplyInsightOptions() end
            end },
            Toggle(L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED"] or "Dynamic position for Focus tooltips", L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED_DESC"] or "When fixed anchor is on, Focus tracker tooltips still attach to the outer edge of the Horizon panel so they never cover the tracker.", "insightFocusDynamicInFixed", false, { visibleWhen = function() return getDB("insightAnchorMode", "cursor") == "fixed" and addon.IsModuleEnabled and addon:IsModuleEnabled("focus") end }),
            { type = "section", name = L["DASH_APPEARANCE"] or "Appearance" },
            { type = "slider", name = L["AXIS_TOOLTIP_BACKGROUND_OPACITY"] or "Tooltip background opacity", desc = L["AXIS_TOOLTIP_BG_OPACITY_PCT_DESC"] or "Tooltip background opacity (0–100%).", dbKey = "insightBgOpacity", min = 0, max = 100, get = function() local v = tonumber(getDB("insightBgOpacity", 0.75)) or 0.75; if v <= 1 and v > 0 then return math.floor(v * 100 + 0.5) end; return math.max(0, math.min(100, v)) end, set = function(v) setDB("insightBgOpacity", math.max(0, math.min(100, v)) / 100) end },
            { type = "dropdown", name = L["AXIS_TOOLTIP_FONT"] or "Tooltip font", desc = L["AXIS_FONT_FAMILY_TOOLTIP_TEXT"] or "Font family used for all tooltip text.", dbKey = "insightFontPath", searchable = true, options = function() return GetPerElementFontDropdownOptions("insightFontPath") end, get = function() return getDB("insightFontPath", FONT_USE_GLOBAL) end, set = function(v) setDB("insightFontPath", v) end, displayFn = DisplayPerElementFont, fontPreviewInList = true },
            { type = "section", name = L["INSIGHT_SECTION_COMBAT"] or "Combat" },
            Toggle(L["INSIGHT_HIDE_IN_COMBAT"] or "Hide tooltips in combat", L["INSIGHT_HIDE_IN_COMBAT_DESC"] or "While in combat, close GameTooltip and other Insight-styled tooltip frames and block them from staying open. Applies only when the Insight module is enabled.", "insightHideTooltipsInCombat", false),
            { type = "section", name = L["INSIGHT_SECTION_ICONS_AND_SEPARATORS"] or "Icons & separators" },
            Toggle(L["AXIS_ICONS"] or "Show icons", L["AXIS_FACTION_SPEC_MOUNT_MYTHIC_ICONS_TOOLTIPS"] or "Show faction, spec, mount, and Mythic+ icons in tooltips.", "insightShowIcons", true, { refreshIds = { "insightClassIconSource" } }),
            { type = "dropdown", name = L["AXIS_SEPARATION"] or "Separation", desc = L["AXIS_SEPARATION_DESC"] or "Choose how Insight separates tooltip sections: divider lines, blank spacing, or no separators.", dbKey = "insightSeparatorMode", options = { { L["AXIS_SEPARATION_DIVIDERS"] or "Dividers", "divider" }, { L["AXIS_SEPARATION_BLANK"] or "Blank", "blank" }, { L["AXIS_SEPARATION_NONE"] or "None", "none" } }, preserveOrder = true, get = function() local v = getDB("insightSeparatorMode", nil); if v == "divider" or v == "blank" or v == "none" then return v end; return getDB("insightBlankSeparator", false) and "blank" or "divider" end, set = function(v) v = (v == "blank") and "blank" or (v == "none") and "none" or "divider"; setDB("insightSeparatorMode", v); setDB("insightBlankSeparator", v == "blank") end, tooltip = L["AXIS_SEPARATION_TOOLTIP"] or "Dividers draws a tinted dashed line between sections. Blank inserts a blank line instead. None removes Insight section separators entirely." },
        },
    },
    {
        key = "InsightPlayer",
        name = L["INSIGHT_CATEGORY_PLAYER"] or "Player Characters",
        desc = L["INSIGHT_CATEGORY_PLAYER_DESC"] or "Guild rank, titles, badges, PvP, ratings, gear, mount lines, icons, and section separators on player tooltips.",
        moduleKey = "insight",
        dashboardPreviewMode = "player",
        options = {
            { type = "section", name = L["INSIGHT_SECTION_IDENTITY"] or "Identity" },
            { type = "dropdown", name = L["INSIGHT_PLAYER_NAME_COLOUR"] or "Player name colour", desc = L["INSIGHT_PLAYER_NAME_COLOUR_DESC"] or "Colour for the player's name on the first tooltip line.", dbKey = "insightPlayerNameColor", options = { { L["INSIGHT_PLAYER_NAME_COLOUR_FACTION"] or "Faction", "faction" }, { L["INSIGHT_PLAYER_NAME_COLOUR_CLASS"] or "Class", "class" } }, get = function() local v = getDB("insightPlayerNameColor", "faction"); return v == "class" and "class" or "faction" end, set = function(v) setDB("insightPlayerNameColor", v == "class" and "class" or "faction") end, refreshIds = { "insightPlayerNameGradient", "insightTitleColorMode", "insightTitleColor" } },
            Toggle(L["INSIGHT_PLAYER_NAME_GRADIENT"] or "Class colour gradient", L["INSIGHT_PLAYER_NAME_GRADIENT_DESC"] or "Render the player name as a two-stop gradient of their class colour (only applies when the name colour is set to Class).", "insightPlayerNameGradient", false, { isNew = "4.12.6a", visibleWhen = function() return getDB("insightPlayerNameColor", "faction") == "class" end, refreshIds = { "insightTitleColorMode", "insightTitleColor" } }),
            { type = "dropdown", name = L["INSIGHT_REALM_NAMES"] or "Realm Names", desc = L["INSIGHT_REALM_NAMES_DESC"] or "Choose how realm names display in player tooltip names.", dbKey = "insightRealmNameMode", options = { { L["INSIGHT_REALM_NAMES_FULL"] or "Full", "full" }, { L["INSIGHT_REALM_NAMES_HIDE"] or "Hide", "hide" }, { L["INSIGHT_REALM_NAMES_MODIFIER"] or "Modifier", "modifier" }, { L["INSIGHT_REALM_NAMES_SIMPLIFIED"] or "Simplified", "simplified" } }, preserveOrder = true, get = function() local v = getDB("insightRealmNameMode", "full"); return (v == "full" or v == "hide" or v == "modifier" or v == "simplified") and v or "full" end, set = function(v) setDB("insightRealmNameMode", (v == "full" or v == "hide" or v == "modifier" or v == "simplified") and v or "full") end },
            Toggle(L["GUILD_RANK"] or "Guild rank", L["AXIS_APPEND_PLAYER_S_GUILD_RANK_NEXT"] or "Append the player's guild rank next to their guild name.", "insightShowGuildRank", true),
            Toggle(L["AXIS_CHARACTER_TITLE"] or "Character title", L["AXIS_PLAYER_S_SELECTED_TITLE_ACHIEVEMENT_PVP"] or "Show the player's selected title (achievement or PvP) in the name line.", "insightShowCharacterTitle", true, { refreshIds = { "insightTitleColorMode", "insightTitleColor" } }),
            { type = "dropdown", name = L["AXIS_TITLE_COLOUR"] or "Title Colour", desc = L["INSIGHT_TITLE_COLOUR_MODE_DESC"] or "Choose how character titles are coloured in the player tooltip name line.", dbKey = "insightTitleColorMode", options = function()
                local opts = {
                    { L["INSIGHT_TITLE_COLOUR_MATCH_NAME"] or "Match Name", "match" },
                }
                if getDB("insightPlayerNameColor", "faction") == "class" and getDB("insightPlayerNameGradient", false) then
                    opts[#opts + 1] = { L["INSIGHT_TITLE_COLOUR_MATCH_NAME_GRADIENT"] or "Match Name (Gradient)", "gradient" }
                end
                opts[#opts + 1] = { L["INSIGHT_TITLE_COLOUR_CUSTOM"] or "Custom", "custom" }
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
            { type = "color", name = L["INSIGHT_TITLE_CUSTOM_COLOUR"] or "Custom Color", desc = L["AXIS_COLOUR_OF_CHARACTER_TITLE_PLAYER_TOOLTIP"] or "Color of the character title in the player tooltip name line.", dbKey = "insightTitleColor", default = { 1.00, 0.82, 0.00 }, visibleWhen = function()
                local mode = getDB("insightTitleColorMode", nil)
                if mode ~= "match" and mode ~= "gradient" and mode ~= "custom" then
                    mode = getDB("insightTitleMatchNameColor", false) and "match" or "custom"
                end
                if mode == "gradient" and not (getDB("insightPlayerNameColor", "faction") == "class" and getDB("insightPlayerNameGradient", false)) then
                    mode = "match"
                end
                return getDB("insightShowCharacterTitle", true) and mode == "custom"
            end },
            { type = "section", name = L["INSIGHT_SECTION_STATUS_PVP"] or "Status" },
            Toggle(L["STATUS_BADGES"] or "Status badges", L["COMBAT_AFK_DND_PVP_PARTY_FRIENDS"], "insightShowStatusBadges", true, { refreshIds = { "insightStatusBadgeCombat", "insightStatusBadgeAFK", "insightStatusBadgeDND", "insightStatusBadgePVP", "insightStatusBadgeGroup", "insightStatusBadgeFriend", "insightStatusBadgeTargeting" } }),
            Toggle(L["INSIGHT_STATUS_BADGE_COMBAT"] or "Combat",           L["INSIGHT_STATUS_BADGE_COMBAT_DESC"] or "Show a Combat badge when the hovered player is in combat.",                   "insightStatusBadgeCombat",    true, { visibleWhen = function() return getDB("insightShowStatusBadges", true) end }),
            Toggle(L["INSIGHT_STATUS_BADGE_AFK"] or "AFK",                 L["INSIGHT_STATUS_BADGE_AFK_DESC"] or "Show an AFK badge when the hovered player is away.",                            "insightStatusBadgeAFK",       true, { visibleWhen = function() return getDB("insightShowStatusBadges", true) end }),
            Toggle(L["INSIGHT_STATUS_BADGE_DND"] or "DND",                 L["INSIGHT_STATUS_BADGE_DND_DESC"] or "Show a DND badge when the hovered player is marked do not disturb.",            "insightStatusBadgeDND",       true, { visibleWhen = function() return getDB("insightShowStatusBadges", true) end }),
            Toggle(L["INSIGHT_STATUS_BADGE_PVP"] or "PvP",                 L["INSIGHT_STATUS_BADGE_PVP_DESC"] or "Show a PvP badge when the hovered player is flagged for PvP.",                 "insightStatusBadgePVP",       true, { visibleWhen = function() return getDB("insightShowStatusBadges", true) end }),
            Toggle(L["INSIGHT_STATUS_BADGE_GROUP"] or "Group",             L["INSIGHT_STATUS_BADGE_GROUP_DESC"] or "Show Party or Raid badges for grouped players.",                              "insightStatusBadgeGroup",     true, { visibleWhen = function() return getDB("insightShowStatusBadges", true) end }),
            Toggle(L["INSIGHT_STATUS_BADGE_FRIEND"] or "Friend",           L["INSIGHT_STATUS_BADGE_FRIEND_DESC"] or "Show a Friend badge for players on your friend list.",                       "insightStatusBadgeFriend",    true, { visibleWhen = function() return getDB("insightShowStatusBadges", true) end }),
            Toggle(L["INSIGHT_STATUS_BADGE_TARGETING"] or "Targeting You", L["INSIGHT_STATUS_BADGE_TARGETING_DESC"] or "Show a Targeting You badge when the hovered player has you targeted.",   "insightStatusBadgeTargeting", true, { visibleWhen = function() return getDB("insightShowStatusBadges", true) end }),
            { type = "section", name = L["INSIGHT_SECTION_RATINGS_GEAR"] or "Ratings & gear" },
            { type = "dropdown", name = L["MYTHIC_SCORE"] or "Mythic+ score", desc = L["INSIGHT_MYTHIC_SCORE_MODE_DESC"] or "Choose when to show Mythic+ score. Show always displays it. Modifier shows it only while Shift is held.", dbKey = "insightMythicScoreMode", options = INSIGHT_FORCE_MODIFIER_OPTIONS, preserveOrder = true, get = function() local v = getDB("insightMythicScoreMode", nil); if v == "force" or v == "modifier" or v == "hide" then return v end; return getDB("insightShowMythicScore", false) and "force" or "hide" end, set = function(v) v = (v == "modifier") and "modifier" or (v == "force") and "force" or "hide"; setDB("insightMythicScoreMode", v); setDB("insightShowMythicScore", v == "force") end },
            { type = "dropdown", name = L["ITEM_LEVEL"] or "Item level", desc = L["INSIGHT_ITEM_LEVEL_MODE_DESC"] or "Choose when to show equipped item level. Show requests inspect data on hover and may not appear instantly. Modifier shows it only while Shift is held.", dbKey = "insightItemLevelMode", options = INSIGHT_FORCE_MODIFIER_OPTIONS, preserveOrder = true, get = function() local v = getDB("insightItemLevelMode", nil); if v == "force" or v == "modifier" or v == "hide" then return v end; return getDB("insightShowIlvl", false) and "force" or "hide" end, set = function(v) v = (v == "modifier") and "modifier" or (v == "force") and "force" or "hide"; setDB("insightItemLevelMode", v); setDB("insightShowIlvl", v == "force") end },
            { type = "dropdown", name = L["HONOR_LEVEL"] or "Honor level", desc = L["INSIGHT_HONOR_LEVEL_MODE_DESC"] or "Choose when to show PvP honor level. Show attempts to show it on every player tooltip. Modifier shows it only while Shift is held.", dbKey = "insightHonorLevelMode", options = INSIGHT_FORCE_MODIFIER_OPTIONS, preserveOrder = true, get = function() local v = getDB("insightHonorLevelMode", nil); if v == "force" or v == "modifier" or v == "hide" then return v end; return getDB("insightShowHonorLevel", false) and "force" or "hide" end, set = function(v) v = (v == "modifier") and "modifier" or (v == "force") and "force" or "hide"; setDB("insightHonorLevelMode", v); setDB("insightShowHonorLevel", v == "force") end },
            { type = "dropdown", name = L["INSIGHT_ACHIEVEMENT_POINTS"], desc = L["INSIGHT_ACHIEVEMENT_POINTS_MODE_DESC"], dbKey = "insightAchievementPointsMode", options = INSIGHT_FORCE_MODIFIER_OPTIONS, preserveOrder = true, get = function() local v = getDB("insightAchievementPointsMode", nil); if v == "force" or v == "modifier" or v == "hide" then return v end; return "hide" end, set = function(v) v = (v == "modifier") and "modifier" or (v == "force") and "force" or "hide"; setDB("insightAchievementPointsMode", v) end },
            Toggle(L["INSIGHT_RATINGS_ICONS"] or "Rating icons", L["INSIGHT_RATINGS_ICONS_DESC"], "insightRatingsIcons", true, { visibleWhen = function() return getDB("insightShowIcons", true) end }),
            { type = "section", name = L["INSIGHT_SECTION_MOUNT"] or "Mount" },
            Toggle(L["MOUNT_INFO"] or "Mount info", L["MOUNT_NAME_SOURCE_COLLECTION_STATUS"], "insightShowMount", true, { tooltip = L["SHOWN_HOVERING_A_MOUNTED_PLAYER"] }),
            { type = "dropdown", name = L["INSIGHT_MOUNT_OWNERSHIP_DISPLAY"] or "Mount collection indicator", desc = L["INSIGHT_MOUNT_OWNERSHIP_DISPLAY_DESC"] or "How to show whether you have collected the hovered player's mount.", dbKey = "insightMountOwnershipDisplay", options = { { L["INSIGHT_MOUNT_OWNERSHIP_TEXT"] or "Full text", "text" }, { L["INSIGHT_MOUNT_OWNERSHIP_ICONS"] or "Tick / cross", "icons" } }, get = function() return getDB("insightMountOwnershipDisplay", "text") end, set = function(v) setDB("insightMountOwnershipDisplay", v) end, visibleWhen = function() return getDB("insightShowMount", true) end },
            { type = "section", name = L["INSIGHT_SECTION_CLASS"] or "Class" },
            Toggle(L["INSIGHT_SPEC_ROLE"] or "Role", L["INSIGHT_SPEC_ROLE_DESC"] or "Show the player's role (Tank / Healer / DPS) on the class line. Requires inspect data — appears after hovering for a moment.", "insightShowSpecRole", true),
            Toggle(L["INSIGHT_RACE_ICONS"] or "Race icons", L["INSIGHT_RACE_ICONS_DESC"] or "Show a race icon beside the level and race line.", "insightRaceIcons", true, { visibleWhen = function() return getDB("insightShowIcons", true) end }),
            { type = "dropdown", name = L["AXIS_CLASS_ICON_STYLE"] or "Class icon style", desc = L["AXIS_DEFAULT_BLIZZARD_RONDOMEDIA_CLASS_ICONS_TH"] or "Use Default (Blizzard) or RondoMedia class icons on the class/spec line.", tooltip = (L["AXIS_CLASS_ICON_SOURCES_TOOLTIP"] or "") .. "\n\n" .. (L["AXIS_SPEC_OVERRIDE_INSPECT_NOTE"] or "Spec override requires inspect data — appears after hovering for a moment."), dbKey = "insightClassIconSource", options = { { L["AXIS_CUSTOM_CLASS_ICONS_LABEL"] or "Horizon", "custom" }, { L["AXIS_DEFAULT"] or "Default", "default" }, { "RondoMedia", "rondomedia" }, { L["AXIS_SPEC_OVERRIDE"] or "Spec Override", "specoverride" } }, get = function() return getDB("insightClassIconSource", "custom") end, set = function(v) setDB("insightClassIconSource", v) end, visibleWhen = function() return getDB("insightShowIcons", true) end },
            { type = "section", name = L["FOCUS_FONT_SIZES"] or "Font sizes" },
            { type = "slider", name = L["FOCUS_HEADER_SIZE"] or "Header size",          desc = L["FOCUS_HEADER_FONT_SIZE"] or "Header font size for player tooltips.",                                                              dbKey = "insightPlayerHeaderSize",  min = 8, max = 24, get = function() return getDB("insightPlayerHeaderSize",  14) end, set = function(v) setDB("insightPlayerHeaderSize",  v) end },
            { type = "slider", name = L["INSIGHT_BODY_SIZE"] or "Body size",            desc = L["INSIGHT_BODY_FONT_SIZE"] or "Body font size for player tooltips.",                                                                dbKey = "insightPlayerBodySize",    min = 8, max = 20, get = function() return getDB("insightPlayerBodySize",    12) end, set = function(v) setDB("insightPlayerBodySize",    v) end },
            { type = "slider", name = L["INSIGHT_BADGES_SIZE"] or "Status badge size",  desc = L["INSIGHT_BADGES_FONT_SIZE"] or "Font size for status badges on player tooltips.",                                                 dbKey = "insightPlayerBadgesSize",  min = 6, max = 20, get = function() return getDB("insightPlayerBadgesSize",  12) end, set = function(v) setDB("insightPlayerBadgesSize",  v) end },
            { type = "slider", name = L["INSIGHT_STATS_SIZE"] or "Ratings size",        desc = L["INSIGHT_STATS_FONT_SIZE"] or "Font size for Mythic+ score, item level, and honor level on player tooltips.",                    dbKey = "insightPlayerStatsSize",   min = 6, max = 20, get = function() return getDB("insightPlayerStatsSize",   11) end, set = function(v) setDB("insightPlayerStatsSize",   v) end },
            { type = "slider", name = L["INSIGHT_MOUNT_SIZE"] or "Mount size",          desc = L["INSIGHT_MOUNT_FONT_SIZE"] or "Mount name, source, and ownership font size for player tooltips.",                                dbKey = "insightPlayerMountSize",   min = 6, max = 20, get = function() return getDB("insightPlayerMountSize",   11) end, set = function(v) setDB("insightPlayerMountSize",   v) end },
        },
    },
    {
        key = "InsightNpc",
        name = L["INSIGHT_CATEGORY_NPC"] or "NPCs",
        desc = L["INSIGHT_CATEGORY_NPC_DESC"] or "NPC tooltip styling. Extra NPC-only toggles can be added here later.",
        moduleKey = "insight",
        dashboardPreviewMode = "npc",
        options = {
            { type = "section", name = L["INSIGHT_SECTION_NPC_TOOLTIP"] or "NPC tooltip" },
            Toggle(L["INSIGHT_NPC_REACTION_BORDER"] or "Reaction border", L["INSIGHT_NPC_REACTION_BORDER_DESC"] or "Tint the tooltip border to the NPC's faction reaction (hostile red, friendly green, neutral yellow).", "insightNpcReactionBorder", true),
            Toggle(L["INSIGHT_NPC_REACTION_NAME"] or "Reaction name colour", L["INSIGHT_NPC_REACTION_NAME_DESC"] or "Colour the NPC's name to match their faction reaction.", "insightNpcReactionName", true),
            Toggle(L["INSIGHT_NPC_LEVEL_LINE"] or "Level line", L["INSIGHT_NPC_LEVEL_LINE_DESC"] or "Show the NPC's level, classification (Elite, Rare, etc.), and creature type beneath their name.", "insightNpcShowLevelLine", true),
            Toggle(L["AXIS_ICONS"] or "Icons", L["INSIGHT_NPC_ICONS_DESC"] or "Show an icon instead of '??' for NPCs with an unknown level.", "insightNpcShowIcons", true),
            { type = "section", name = L["FOCUS_FONT_SIZES"] or "Font sizes" },
            { type = "slider", name = L["FOCUS_HEADER_SIZE"] or "Header size", desc = L["FOCUS_HEADER_FONT_SIZE"] or "Header font size for NPC tooltips.", dbKey = "insightNpcHeaderSize", min = 8, max = 24, get = function() return getDB("insightNpcHeaderSize", 14) end, set = function(v) setDB("insightNpcHeaderSize", v) end },
            { type = "slider", name = L["INSIGHT_BODY_SIZE"] or "Body size",   desc = L["INSIGHT_BODY_FONT_SIZE"] or "Body font size for NPC tooltips.",   dbKey = "insightNpcBodySize",   min = 8, max = 20, get = function() return getDB("insightNpcBodySize",   12) end, set = function(v) setDB("insightNpcBodySize",   v) end },
        },
    },
    {
        key = "InsightItem",
        name = L["INSIGHT_CATEGORY_ITEM"] or "Items",
        desc = L["INSIGHT_CATEGORY_ITEM_DESC"] or "Item tooltip options such as transmog collection status.",
        moduleKey = "insight",
        dashboardPreviewMode = "item",
        options = {
            { type = "section", name = L["INSIGHT_SECTION_TRANSMOG"] or "Transmog" },
            Toggle(L["TRANSMOG_STATUS"] or "Transmog status", L["AXIS_WHETHER_YOU_COLLECTED_APPEARANCE_OF_AN"] or "Show whether you have collected the appearance of an item you hover over.", "insightShowTransmog", true),
            { type = "section", name = L["INSIGHT_SECTION_ITEM_STYLING"] or "Item styling" },
            Toggle(L["INSIGHT_ITEM_QUALITY_BORDER"] or "Quality border", L["INSIGHT_ITEM_QUALITY_BORDER_DESC"] or "Tint the tooltip border to the item's quality colour (Uncommon green, Rare blue, Epic purple, etc.).", "insightItemQualityBorder", true),
            Toggle(L["INSIGHT_ITEM_NAME_GRADIENT"] or "Quality gradient name", L["INSIGHT_ITEM_NAME_GRADIENT_DESC"] or "Render the item name as a two-stop gradient of its quality colour (Uncommon green, Rare blue, Epic purple, etc.).", "insightItemNameGradient", false, { isNew = "4.12.6a" }),
            Toggle(L["INSIGHT_ITEM_SECTION_SPACING"] or "Blank line before blocks", L["INSIGHT_ITEM_SECTION_SPACING_DESC"] or "Insert a blank line before Insight blocks on item tooltips instead of a tinted separator line.", "insightItemSectionSpacing", false),
            { type = "section", name = L["FOCUS_FONT_SIZES"] or "Font sizes" },
            { type = "slider", name = L["FOCUS_HEADER_SIZE"] or "Header size", desc = L["FOCUS_HEADER_FONT_SIZE"] or "Header font size for item tooltips (item name line).",        dbKey = "insightItemHeaderSize", min = 8, max = 24, get = function() return getDB("insightItemHeaderSize", 14) end, set = function(v) setDB("insightItemHeaderSize", v) end },
            { type = "slider", name = L["INSIGHT_BODY_SIZE"] or "Body size",   desc = L["INSIGHT_BODY_FONT_SIZE"] or "Body font size for item tooltips (stats and middle zone).", dbKey = "insightItemBodySize",   min = 8, max = 20, get = function() return getDB("insightItemBodySize",   12) end, set = function(v) setDB("insightItemBodySize",   v) end },
            { type = "slider", name = L["INSIGHT_TRANSMOG_SIZE"] or "Transmog size", desc = L["INSIGHT_TRANSMOG_FONT_SIZE"] or "Item appearance status font size.", dbKey = "insightItemTransmogSize", min = 6, max = 20, get = function() return getDB("insightItemTransmogSize", getDB("insightTransmogSize", 11)) end, set = function(v) setDB("insightItemTransmogSize", v) end },
        },
    },
}

for i = 1, #categories do
    addon.OptionCategories[#addon.OptionCategories + 1] = categories[i]
end
