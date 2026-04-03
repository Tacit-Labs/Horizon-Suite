--[[
    Horizon Suite — Translation template (not loaded by the addon).
    Copy to Localisation/<yourLocale>.lua, set GetLocale() guard, translate values.
]]

if GetLocale() ~= "LOCALE_CODE" then return end

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = setmetatable({}, { __index = addon.L })
addon.L = L
addon.StandardFont = UNIT_NAME_FONT

-- =====================================================================
-- OptionsPanel.lua (deprecated) — remaining strings for that UI
-- Panel title + module short names: addon.BrandDisplay (core/BrandDisplay.lua).
-- =====================================================================
L["OPTIONS_FOCUS_OTHER"]                                              = "Other"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["OPTIONS_FOCUS_QUEST_TYPES"]                                        = "Quest types"
L["OPTIONS_FOCUS_ELEMENT_OVERRIDES"]                                  = "Element overrides"
L["OPTIONS_FOCUS_PER_CATEGORY"]                                       = "Per category"
L["OPTIONS_FOCUS_GROUPING_OVERRIDES"]                                 = "Grouping Overrides"
L["OPTIONS_FOCUS_SECTION_OVERRIDES"]                                  = "Section Overrides"
L["OPTIONS_FOCUS_COLORS"]                                             = "Other colors"

-- =====================================================================
-- OptionsPanel.lua — Color row labels (collapsible group sub-rows)
-- =====================================================================
L["OPTIONS_FOCUS_SECTION"]                                            = "Section"
L["OPTIONS_FOCUS_TITLE"]                                              = "Title"
L["OPTIONS_FOCUS_ZONE"]                                               = "Zone"
L["OPTIONS_FOCUS_OBJECTIVE"]                                          = "Objective"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["OPTIONS_FOCUS_READY_TURN_OVERRIDES_BASE_COLOURS"]                  = "Ready to Turn In overrides base colours"
L["OPTIONS_FOCUS_READY_TURN_COLOURS_QUESTS"]                          = "Ready to Turn In uses its colours for quests in that section."
L["OPTIONS_FOCUS_CURRENT_ZONE_OVERRIDES_BASE_COLOURS"]                = "Current Zone overrides base colours"
L["OPTIONS_FOCUS_CURRENT_ZONE_COLOURS_QUESTS_SEC"]                    = "Current Zone uses its colours for quests in that section."
L["OPTIONS_FOCUS_CURRENT_QUEST_OVERRIDES_BASE_COLOURS"]               = "Current Quest overrides base colours"
L["OPTIONS_FOCUS_CURRENT_QUEST_COLOURS_QUESTS_SE"]                    = "Current Quest uses its colours for quests in that section."
L["OPTIONS_FOCUS_DISTINCT_COLOR_COMPLETED_OBJECTIVES"]                = "Use distinct color for completed objectives"
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES_E_G_COLOR_B"]                   = "When on, completed objectives (e.g. 1/1) use the color below; when off, they use the same color as incomplete objectives."
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVE"]                                = "Completed objective"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["OPTIONS_FOCUS_RESET"]                                              = "Reset"
L["OPTIONS_FOCUS_RESET_QUEST_TYPES"]                                  = "Reset quest types"
L["OPTIONS_FOCUS_RESET_OVERRIDES"]                                    = "Reset overrides"
L["OPTIONS_FOCUS_RESET_DEFAULTS"]                                     = "Reset all to defaults"
L["OPTIONS_FOCUS_RESET_TO_DEFAULTS"]                                  = "Reset to defaults"
L["OPTIONS_FOCUS_RESET_DEFAULT"]                                      = "Reset to default"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["OPTIONS_FOCUS_SEARCH_SETTINGS"]                                    = "Search settings..."
L["OPTIONS_FOCUS_SEARCH_FONTS"]                                       = "Search fonts..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["OPTIONS_FOCUS_DRAG_RESIZE"]                                        = "Drag to resize"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
L["OPTIONS_AXIS_PROFILES"]                                            = "Profiles"
L["OPTIONS_AXIS_MODULES"]                                             = "Modules"
L["OPTIONS_AXIS_MODULE_TOGGLES"]                                      = "Module Toggles"

-- =====================================================================
-- options/dashboard/HomeWelcome.lua — First-run welcome
-- =====================================================================
L["DASH_WHATS_NEW"]                                                   = "Patch Notes"
L["DASH_FULL_CHANGELOG"]                                              = "Full Changelog"
L["DASH_WHATS_NEW_UNREAD_SUFFIX"]                                     = " (New!)"
L["DASH_WELCOME_TAB"]                                                 = "Welcome"
L["DASH_WELCOME_TITLE"]                                               = "Welcome to Horizon Suite"
L["DASH_WELCOME_HEAD_SUB"]                                            = "Credits, community, and where to find help"
L["DASH_WELCOME_INTRO"]                                               = [=[Welcome to Horizon Suite — modular UI for your tracker, notifications, and more, built so you only run what you want. Turn features on or off under |cffaaaaaaAxis > Modules|r, take the |cffaaaaaaQuick Start|r tour, and see what is new in |cffaaaaaaPatch Notes|r each release.]=]
L["DASH_WELCOME_PATH"]                                                = "%s > %s > %s"
L["DASH_WELCOME_FOCUS_BLIZZARD_PLUS_HEADING"]                         = "Blizzard+ click profile"
L["DASH_WELCOME_FOCUS_BLIZZARD_PLUS_BODY"]                            = [=[Focus now uses |cffffffffBlizzard+|r by default — Blizzard-style quest row clicks with a few Horizon conveniences. Open |cffaaaaaaFocus > Interactions|r and use |cffaaaaaaClick profile|r to see the preset; |cffffffffHorizon+|r and full |cffffffffCustom|r shortcuts are on the way.]=]
L["DASH_WELCOME_COMING_SOON_TITLE"]                                   = "Coming Soon"
L["DASH_WELCOME_COMING_SOON_TAGLINE"]                                 = "New welcome experiences are on the way."
L["DASH_WELCOME_COMING_SOON_BODY"]                                    = [=[Watch this space — we will post updates here and in |cffaaaaaaPatch Notes|r. Join |cffaaaaaaDiscord|r from the links below for news and feedback.]=]
L["DASH_WELCOME_CLASS_ICONS_HEADING"]                                 = "New: Horizon class icons"
L["DASH_WELCOME_CLASS_ICONS_LEAD"]                                    = [=[We have added a bundled set of custom class icons — now the default when you choose |cffaaaaaaHorizon|r under |cffaaaaaaAxis > Global Toggles|r (Class icon style).]=]
L["DASH_WELCOME_CLASS_ICONS_THANK_BOOFULS"]                           = [=[Thank you, Boofuls, for commissioning this art and helping bring these icons to everyone.]=]
L["DASH_WELCOME_CLASS_ICONS_CREATED_PREFIX"]                          = "• Created by "
L["DASH_WELCOME_CLASS_ICONS_ARTIST_NAME"]                             = "Gabriel C"
L["DASH_WELCOME_CONTRIBUTORS_HEADING"]                                = "Contributors"
L["DASH_WELCOME_CONTRIBUTORS_BODY"]                                   = [=[Thanks to everyone who has contributed to Horizon Suite:

• feanor21#2847 — Panoramuxa (Tarren Mill - EU) — Development
• Marthix — Development
• Swift — Coordinator
• Boofuls — Moderator
• RondoFerrari — RondoMedia (CurseForge addon) — Class icons in Insight tooltips and optional Dashboard header icon when class colors are on (optional)
• Aishuu — French localisation (frFR)
• 아즈샤라-두녘 — Korean localisation (koKR)
• Linho-Gallywix — Brazilian Portuguese localisation (ptBR)
• allmoon — Chinese localisation (zhCN)]=]
L["DASH_WELCOME_LOCALISATIONS_HEADING"]                               = "Localisations"
L["DASH_WELCOME_LOCALISATIONS_BODY"]                                  = [=[The addon UI is localised for:

• Chinese (zhCN) — Localisation/zhCN.lua
• French (frFR) — Localisation/frFR.lua
• German (deDE) — Localisation/deDE.lua
• Korean (koKR) — Localisation/koKR.lua
• Brazilian Portuguese (ptBR) — Localisation/ptBR.lua
• Russian (ruRU) — Localisation/ruRU.lua
• Spanish (esES) — Localisation/esES.lua

See TRANSLATING.md in the repo for how to contribute. Additional locales are welcome via Discord.]=]


-- =====================================================================
-- options/dashboard/ModuleGuide.lua — In-game module quick-start
-- =====================================================================
L["DASH_GUIDE_TAB"]                                                   = "Quick Start"
L["DASH_GUIDE_HEAD_SUB"]                                              = "What each part of Horizon does"
L["DASH_GUIDE_HERO_TITLE"]                                            = "Getting started with Horizon Suite"
L["DASH_GUIDE_HERO_TAGLINE"]                                          = "A modular UI toolkit for quests, notifications, the minimap, and more."
L["DASH_GUIDE_HERO_INTRO"]                                            = "Pick the modules you want, tune them in the sidebar, and reload when you toggle something on or off. This page is always here — open it anytime from Quick Start under Welcome."
L["DASH_GUIDE_QUICK_START_HEADING"]                                   = "Quick start"
L["DASH_GUIDE_QUICK_START_BODY"]                                      = [=[• Under |cffaaaaaaAxis → Modules|r in the sidebar, turn each module on or off. Changing modules applies after a |cffaaaaaaReload UI|r.
• Under |cffaaaaaaAxis → Global Toggles|r, set class-colour tinting for the dashboard and modules, pick a |cffaaaaaaDashboard background|r preset, and adjust |cffaaaaaaUI scale|r (global or per module).]=]
L["DASH_GUIDE_HORIZON_HEADING"]                                       = "What is Horizon Suite?"
L["DASH_GUIDE_HORIZON_BULLETS"]                                       = [=[• Axis — Profiles, module on/off, global toggles, typography, and other suite-wide settings.
• Focus — Quest and content tracker: quests, world quests, scenarios, rares, achievements, and more in coloured sections.
• Presence — Large cinematic toasts for zones, quests, scenarios, achievements, level up, and similar moments.
• Vista — Minimap chrome: zone text, coordinates, clock, and a collector for minimap buttons.
• Insight — Richer tooltips for players, NPCs, and items (class colours, spec, icons, extras).
• Cache — Loot toasts and bag presentation.
• Essence — Character sheet with 3D model, item level, stats, and gear grid.
• Meridian — Reserved; no options yet (see tag).]=]
L["DASH_GUIDE_MOD_AXIS_BODY"]                                         = "Axis is the control centre: switch profiles, enable or disable whole modules, open Global Toggles for class colours and UI scale, and reach typography and appearance options that apply across Horizon. Start here when you first install or when you want a lighter footprint by turning modules off."
L["DASH_GUIDE_MOD_FOCUS_BODY"]                                        = [=[Focus replaces the default objective list with a flexible tracker. Tracked quests, world quests, scenarios, rares, achievements, endeavors, decor, recipes, and more are grouped into coloured section headers so you can scan quickly.

Sections only appear when they have something to show — for example Current (recent progress), Current zone, Ready to turn in, World / weekly / daily / Prey, campaign and special quests, delves and scenarios, rare bosses and loot, achievements and collections, and time-limited or zone events.

Use Focus → Sorting & filtering to reorder sections, and Focus → Content to choose which types of content appear.]=]
L["DASH_GUIDE_PRESENCE_INTRO"]                                        = "Presence shows large, styled alerts for moments that used to be separate Blizzard popups — zone changes, quest progress, achievements, scenarios, and more. You can turn each type on or off and tune typography in Presence settings."
L["DASH_GUIDE_PRESENCE_BODY"]                                         = [=[Typical Presence toasts include:

• Zone and subzone discovery text when you enter new areas.
• Quest accepted, objective progress, quest complete, and world quest complete.
• Scenario start, progress updates, and completion (including delve-style flow).
• Achievements earned and optional achievement progress ticks.
• Level up, boss emotes, and rare defeated.]=]
L["DASH_GUIDE_PRESENCE_BLIZZARD"]                                     = [=[When a Presence type is enabled, Horizon can hide the matching default UI so you don’t get duplicates — for example zone name banners, the level-up frame, boss emote bar, event toast manager, world-quest completion banner, and some objective bonus banners. Turn a Presence type off in settings to let the default game UI show again for that category.]=]
L["DASH_GUIDE_MOD_VISTA_BODY"]                                        = "Vista wraps your minimap with readable zone and subzone text, optional coordinates and clock, and a bar that collects stray minimap buttons so they stay tidy. Tune layout and colours under Vista in the sidebar."
L["DASH_GUIDE_MOD_INSIGHT_BODY"]                                      = "Insight extends Blizzard tooltips for players, NPCs, and items — class and faction colouring, spec and icon lines, optional Mythic+ score, item level, mount collection hints, and cleaner separators. Each tooltip type has its own category under Insight."
L["DASH_GUIDE_MOD_CACHE_BODY"]                                        = "Cache handles loot feedback: styled loot toasts for items, money, currency, and reputation, plus options that tie into how rewards are shown. Enable it when you want Horizon’s presentation instead of the default loot popups."
L["DASH_GUIDE_MOD_ESSENCE_BODY"]                                      = "Essence is an optional character sheet: 3D model, item level, primary stats, and a gear grid so you can review your equipment at a glance. Open Essence in the sidebar to adjust layout and visibility."
L["DASH_GUIDE_MOD_MERIDIAN_BODY"]                                     = "Coming soon."
L["DASH_AXIS_MODULE_SHORT_DESCRIPTION"]                               = "Core settings hub: profiles, modules, and global toggles."
L["DASH_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS"]                       = "Objective tracker for quests, world quests, rares, achievements, scenarios."
L["DASH_ZONE_TEXT_AND_NOTIFICATIONS"]                                 = "Zone text and notifications."
L["DASH_MINIMAP_ZONE_TEXT_COORDS_BUTTON"]                             = "Minimap with zone text, coords, time, and button collector."
L["DASH_TOOLTIPS_CLASS_COLORS_SPEC_FACTION"]                          = "Tooltips with class colors, spec, and faction icons."
L["DASH_LOOT_TOASTS_ITEMS_MONEY_CURRENCY"]                            = "Loot toasts for items, money, currency, reputation, and bag overhaul."
L["DASH_ESSENCE_MODULE_SHORT_DESCRIPTION"]                            = "Custom character sheet with 3D model, item level, stats, and gear grid."
L["DASH_MERIDIAN_MODULE_SHORT_DESCRIPTION"]                           = "Coming soon."
L["DASH_WELCOME_COMMUNITY_HEADING"]                                   = "Community & Support"
L["DASH_DISCORD"]                                                     = "Discord"
L["DASH_KO_FI"]                                                       = "Ko-fi"
L["DASH_PATREON"]                                                     = "Patreon"
L["DASH_GITLAB"]                                                      = "GitLab"
L["DASH_CURSEFORGE"]                                                  = "CurseForge"
L["DASH_WAGO"]                                                        = "Wago"
L["DASH_COPY_LINK_X"]                                                 = "Copy link — %s"
L["DASH_LAYOUT"]                                                      = "Layout"
L["DASH_VISIBILITY"]                                                  = "Visibility"
L["DASH_DISPLAY"]                                                     = "Display"
L["DASH_FEATURES"]                                                    = "Features"
L["DASH_TYPOGRAPHY"]                                                  = "Typography"
L["DASH_APPEARANCE"]                                                  = "Appearance"
L["DASH_COLORS"]                                                      = "Colors"
L["DASH_ORGANIZATION"]                                                = "Organization"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["OPTIONS_FOCUS_PANEL_BEHAVIOUR"]                                    = "Panel behaviour"
L["OPTIONS_FOCUS_DIMENSIONS"]                                         = "Dimensions"
L["OPTIONS_FOCUS_INSTANCE"]                                           = "Instance"
L["OPTIONS_FOCUS_INSTANCES"]                                          = "Instances"
L["OPTIONS_FOCUS_COMBAT"]                                             = "Combat"
L["OPTIONS_FOCUS_FILTERING"]                                          = "Filtering"
L["OPTIONS_FOCUS_HEADER"]                                             = "Header"
L["OPTIONS_FOCUS_SECTIONS_STRUCTURE"]                                 = "Sections & structure"
L["OPTIONS_FOCUS_ENTRY_DETAILS"]                                      = "Entry details"
L["OPTIONS_FOCUS_PROGRESS_TIMERS"]                                    = "Progress & timers"
L["OPTIONS_FOCUS_EMPHASIS"]                                           = "Focus emphasis"
L["OPTIONS_FOCUS_LIST"]                                               = "List"
L["OPTIONS_FOCUS_SPACING"]                                            = "Spacing"
L["OPTIONS_FOCUS_RARE_BOSSES"]                                        = "Rare bosses"
L["OPTIONS_FOCUS_WORLD_QUESTS"]                                       = "World quests"
L["OPTIONS_FOCUS_FLOATING_QUEST_ITEM"]                                = "Floating quest item"
L["OPTIONS_FOCUS_MYTHIC"]                                             = "Mythic+"
L["OPTIONS_FOCUS_ACHIEVEMENTS"]                                       = "ACHIEVEMENTS"
L["OPTIONS_FOCUS_ENDEAVORS"]                                          = "ENDEAVORS"
L["OPTIONS_FOCUS_DECOR"]                                              = "Decor"
L["OPTIONS_FOCUS_APPEARANCES"]                                        = "Appearances"
L["OPTIONS_FOCUS_SCENARIO_DELVE"]                                     = "Scenario & Delve"
L["OPTIONS_FOCUS_FONT"]                                               = "Font"
L["OPTIONS_FOCUS_FONT_FAMILIES"]                                      = "Font families"
L["OPTIONS_FOCUS_GLOBAL_FONT_SIZE"]                                   = "Global font size"
L["OPTIONS_FOCUS_FONT_SIZES"]                                         = "Font sizes"
L["OPTIONS_FOCUS_PER_ELEMENT_FONTS"]                                  = "Per-element fonts"
L["OPTIONS_FOCUS_TEXT_CASE"]                                          = "Text case"
L["OPTIONS_FOCUS_SHADOW"]                                             = "Shadow"
L["OPTIONS_FOCUS_PANEL"]                                              = "Panel"
L["OPTIONS_FOCUS_HIGHLIGHT"]                                          = "Highlight"
L["OPTIONS_FOCUS_COLOR_MATRIX"]                                       = "Color matrix"
L["OPTIONS_FOCUS_ORDER"]                                              = "Focus order"
L["OPTIONS_FOCUS_SORT"]                                               = "Sort"
L["OPTIONS_FOCUS_BEHAVIOUR"]                                          = "Behaviour"
L["OPTIONS_FOCUS_CONTENT_TYPES"]                                      = "Content Types"
L["OPTIONS_FOCUS_DELVES"]                                             = "Delves"
L["OPTIONS_FOCUS_DELVES_DUNGEONS"]                                    = "Delves & Dungeons"
L["OPTIONS_FOCUS_DELVE_COMPLETE"]                                     = "Delve Complete"
L["OPTIONS_FOCUS_INTERACTIONS"]                                       = "Interactions"
L["OPTIONS_FOCUS_TRACKING"]                                           = "Tracking"
L["OPTIONS_FOCUS_SCENARIO_BAR"]                                       = "Scenario Bar"

-- =====================================================================
-- OptionsData.lua Profiles
-- =====================================================================
L["OPTIONS_AXIS_CURRENT_PROFILE"]                                     = "Current profile"
L["OPTIONS_AXIS_SELECT_PROFILE_CURRENTLY"]                            = "Select the profile currently in use."
L["OPTIONS_AXIS_GLOBAL_PROFILE_ACCOUNT_WIDE"]                         = "Use global profile (account-wide)"
L["OPTIONS_AXIS_CHARACTERS_SAME_PROFILE"]                             = "All characters use the same profile."
L["OPTIONS_AXIS_ENABLE_PER_SPECIALIZATION_PROFILES"]                  = "Enable per specialization profiles"
L["OPTIONS_AXIS_PICK_DIFFERENT_PROFILES_PER_SPEC"]                    = "Pick different profiles per spec."
L["OPTIONS_AXIS_SPECIALIZATION"]                                      = "Specialization"
L["OPTIONS_AXIS_SHARING"]                                             = "Sharing"
L["OPTIONS_AXIS_IMPORT_PROFILE"]                                      = "Import profile"
L["OPTIONS_AXIS_IMPORT_STRING"]                                       = "Import string"
L["OPTIONS_AXIS_EXPORT_PROFILE"]                                      = "Export profile"
L["OPTIONS_AXIS_SELECT_A_PROFILE_EXPORT"]                             = "Select a profile to export."
L["OPTIONS_AXIS_EXPORT_STRING"]                                       = "Export string"
L["OPTIONS_AXIS_COPY_PROFILE"]                                        = "Copy from profile"
L["OPTIONS_AXIS_SOURCE_PROFILE_COPYING"]                              = "Source profile for copying."
L["OPTIONS_AXIS_COPY_SELECTED"]                                       = "Copy from selected"
L["OPTIONS_AXIS_CREATE"]                                              = "Create"
L["OPTIONS_AXIS_CREATE_PROFILE_DEFAULT_TEMPLATE"]                     = "Create new profile from Default template"
L["OPTIONS_AXIS_CREATES_A_PROFILE_DEFAULT_SETTINGS"]                  = "Creates a new profile with all default settings."
L["OPTIONS_AXIS_CREATES_A_PROFILE_COPIED_SELECTED_SOURC"]             = "Creates a new profile copied from the selected source profile."
L["OPTIONS_AXIS_DELETE_PROFILE"]                                      = "Delete profile"
L["OPTIONS_AXIS_SELECT_A_PROFILE_DELETE_CURRENT_DEFAULT"]             = "Select a profile to delete (current and Default not shown)."
L["OPTIONS_AXIS_DELETE_SELECTED"]                                     = "Delete selected"
L["OPTIONS_AXIS_DELETE_SELECTED_PROFILE"]                             = "Delete selected profile"
L["OPTIONS_AXIS_DELETE"]                                              = "Delete"
L["OPTIONS_AXIS_DELETES_SELECTED_PROFILE"]                            = "Deletes the selected profile."
L["OPTIONS_AXIS_GLOBAL_PROFILE"]                                      = "Global profile"
L["OPTIONS_AXIS_PER_SPEC_PROFILES"]                                   = "Per-spec profiles"

-- =====================================================================
-- OptionsData.lua Modules
-- =====================================================================
L["OPTIONS_AXIS_ENABLE_FOCUS_MODULE"]                                 = "Enable Focus module"
L["OPTIONS_AXIS_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS_R"]             = "Show the objective tracker for quests, world quests, rares, achievements, and scenarios."
L["OPTIONS_AXIS_ENABLE_PRESENCE_MODULE"]                              = "Enable Presence module"
L["OPTIONS_AXIS_CINEMATIC_ZONE_TEXT_NOTIFICATIONS_ZONE_CHANGES"]      = "Cinematic zone text and notifications (zone changes, level up, boss emotes, achievements, quest updates)."
L["OPTIONS_AXIS_ENABLE_CACHE_MODULE"]                                 = "Enable Cache module"
L["OPTIONS_AXIS_CINEMATIC_LOOT_NOTIFICATIONS_ITEMS_MONEY_CURRENCY"]   = "Cinematic loot notifications (items, money, currency, reputation)."
L["OPTIONS_AXIS_ENABLE_VISTA_MODULE"]                                 = "Enable Vista module"
L["OPTIONS_AXIS_CINEMATIC_SQUARE_MINIMAP_ZONE_TEXT_COORDINATES"]      = "Cinematic square minimap with zone text, coordinates, and button collector."
L["OPTIONS_AXIS_MINIMAP_ZONE_TIME_COLLECTOR"]                         = "Cinematic square minimap with zone text, coordinates, time, and button collector."
L["OPTIONS_AXIS_BETA"]                                                = "Beta"
L["OPTIONS_AXIS_SCALING"]                                             = "Scaling"
L["OPTIONS_AXIS_GLOBAL_TOGGLES"]                                      = "Global Toggles"
L["OPTIONS_AXIS_PATCH_NOTES_SECTION"]                                 = "Patch notes"
L["OPTIONS_AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN"]                      = "Show Patch Notes automatically after an update"
L["OPTIONS_AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN_DESC"]                 = "When on, Axis opens to Patch Notes once after each new addon version. When off, a green dot appears on the Horizon minimap icon until you open Patch Notes."
L["OPTIONS_AXIS_SUITE_WIDE_CLASS_COLOUR_TINTING_UI"]                  = "Dashboard background theme, class colour tinting, and UI scale (global or per module)."
L["OPTIONS_AXIS_GLOBAL_UI_SCALE"]                                     = "Global UI scale"
L["OPTIONS_AXIS_SCALE_SIZES_SPACINGS_FONTS_FACTOR"]                   = "Scale all sizes, spacings, and fonts by this factor (50–200%). Does not change your configured values."
L["OPTIONS_AXIS_PER_MODULE_SCALING"]                                  = "Per-module scaling"
L["OPTIONS_AXIS_OVERRIDE_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_FO"]         = "Override the global scale with individual sliders for each module."
L["OPTIONS_AXIS_OVERRIDES_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_F"]         = "Overrides the global scale with individual sliders for Focus, Presence, Vista, etc."
L["OPTIONS_AXIS_DOESN_T_CHANGE_YOUR_CONFIGURED_VALUES"]               = "Doesn't change your configured values, only the effective display scale."
L["OPTIONS_FOCUS_SCALE"]                                              = "Focus scale"
L["OPTIONS_AXIS_SCALE_FOCUS_OBJECTIVE_TRACKER"]                       = "Scale for the Focus objective tracker (50–200%)."
L["OPTIONS_PRESENCE_SCALE"]                                           = "Presence scale"
L["OPTIONS_AXIS_SCALE_PRESENCE_CINEMATIC_TEXT"]                       = "Scale for the Presence cinematic text (50–200%)."
L["OPTIONS_VISTA_SCALE"]                                              = "Vista scale"
L["OPTIONS_AXIS_SCALE_VISTA_MINIMAP_MODULE"]                          = "Scale for the Vista minimap module (50–200%)."
L["OPTIONS_INSIGHT_SCALE"]                                            = "Insight scale"
L["OPTIONS_AXIS_SCALE_INSIGHT_TOOLTIP_MODULE"]                        = "Scale for the Insight tooltip module (50–200%)."
L["OPTIONS_CACHE_SCALE"]                                              = "Cache scale"
L["OPTIONS_AXIS_SCALE_CACHE_LOOT_TOAST_MODULE"]                       = "Scale for the Cache loot toast module (50–200%)."
L["OPTIONS_AXIS_ENABLE_HORIZON_INSIGHT_MODULE"]                       = "Enable Horizon Insight module"
L["OPTIONS_AXIS_CINEMATIC_TOOLTIPS_CLASS_COLORS_SPEC_DISPLAY"]        = "Cinematic tooltips with class colors, spec display, and faction icons."
L["OPTIONS_AXIS_TOOLTIP_ANCHOR_MODE"]                                 = "Tooltip anchor mode"
L["OPTIONS_AXIS_WHERE_TOOLTIPS_APPEAR_FOLLOW_CURSOR_FIXED"]           = "Where tooltips appear: follow cursor or fixed position."
L["OPTIONS_AXIS_CURSOR"]                                              = "Cursor"
L["OPTIONS_AXIS_FIXED"]                                               = "Fixed"
L["OPTIONS_AXIS_ANCHOR_MOVE"]                                         = "Show anchor to move"
L["OPTIONS_AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITIO"]                      = "Click to show or hide the anchor. Drag to set position, right-click to confirm."
L["OPTIONS_AXIS_DRAGGABLE_FRAME_FIXED_TOOLTIP_POSITION_D"]            = "Show draggable frame to set fixed tooltip position. Drag, then right-click to confirm."
L["OPTIONS_AXIS_RESET_TOOLTIP_POSITION"]                              = "Reset tooltip position"
L["OPTIONS_AXIS_RESET_FIXED_POSITION_DEFAULT"]                        = "Reset fixed position to default."
L["OPTIONS_INSIGHT_CURSOR_OFFSET_X"]                                  = "Cursor offset X"
L["OPTIONS_INSIGHT_CURSOR_OFFSET_X_DESC"]                             = "Horizontal pixel offset from the default cursor tooltip position (cursor anchor only)."
L["OPTIONS_INSIGHT_CURSOR_OFFSET_Y"]                                  = "Cursor offset Y"
L["OPTIONS_INSIGHT_CURSOR_OFFSET_Y_DESC"]                             = "Vertical pixel offset from the default cursor tooltip position (cursor anchor only)."
L["OPTIONS_AXIS_TOOLTIP_BACKGROUND_COLOR"]                            = "Tooltip background color"
L["OPTIONS_AXIS_COLOR_OF_TOOLTIP_BACKGROUND"]                         = "Color of the tooltip background."
L["OPTIONS_AXIS_TOOLTIP_BACKGROUND_OPACITY"]                          = "Tooltip background opacity"
L["OPTIONS_AXIS_TOOLTIP_BG_OPACITY_PCT_DESC"]                         = "Tooltip background opacity (0–100%)."
L["OPTIONS_AXIS_TOOLTIP_FONT"]                                        = "Tooltip font"
L["OPTIONS_AXIS_FONT_FAMILY_TOOLTIP_TEXT"]                            = "Font family used for all tooltip text."
L["OPTIONS_INSIGHT_BODY_SIZE"]                                        = "Body size"
L["OPTIONS_INSIGHT_BODY_FONT_SIZE"]                                   = "Body font size."
L["OPTIONS_INSIGHT_BADGES_SIZE"]                                      = "Badges size"
L["OPTIONS_INSIGHT_BADGES_FONT_SIZE"]                                 = "Status badges font size."
L["OPTIONS_INSIGHT_STATS_SIZE"]                                       = "Stats size"
L["OPTIONS_INSIGHT_STATS_FONT_SIZE"]                                  = "M+ score, item level, and honor level font size."
L["OPTIONS_INSIGHT_MOUNT_SIZE"]                                       = "Mount size"
L["OPTIONS_INSIGHT_MOUNT_FONT_SIZE"]                                  = "Mount name, source, and ownership font size."
L["OPTIONS_INSIGHT_MOUNT_OWNERSHIP_DISPLAY"]                          = "Mount collection indicator"
L["OPTIONS_INSIGHT_MOUNT_OWNERSHIP_DISPLAY_DESC"]                     = "How to show whether you have collected the hovered player's mount."
L["OPTIONS_INSIGHT_MOUNT_OWNERSHIP_TEXT"]                             = "Full text"
L["OPTIONS_INSIGHT_MOUNT_OWNERSHIP_ICONS"]                            = "Tick / cross"
L["INSIGHT_MOUNT_OWNED"]                                              = "You own this mount"
L["INSIGHT_MOUNT_NOT_OWNED"]                                          = "You don't own this mount"
L["OPTIONS_INSIGHT_TRANSMOG_SIZE"]                                    = "Transmog size"
L["OPTIONS_INSIGHT_TRANSMOG_FONT_SIZE"]                               = "Item appearance status font size."
L["OPTIONS_AXIS_TOOLTIPS"]                                            = "Tooltips"
L["OPTIONS_INSIGHT_CATEGORY_GLOBAL"]                                  = "Global Tooltips"
L["OPTIONS_INSIGHT_CATEGORY_GLOBAL_DESC"]                             = "Anchor, backdrop, font family, and display options shared across tooltip types."
L["OPTIONS_INSIGHT_CATEGORY_PLAYER"]                                  = "Player Characters"
L["OPTIONS_INSIGHT_CATEGORY_PLAYER_DESC"]                             = "Guild rank, titles, badges, PvP, ratings, gear, mount lines, icons, and section separators on player tooltips."
L["OPTIONS_INSIGHT_CATEGORY_NPC"]                                     = "NPCs"
L["OPTIONS_INSIGHT_CATEGORY_NPC_DESC"]                                = "Reaction colours, level line, icons, and font sizes for NPC tooltips."
L["OPTIONS_INSIGHT_CATEGORY_ITEM"]                                    = "Items"
L["OPTIONS_INSIGHT_CATEGORY_ITEM_DESC"]                               = "Item tooltip options such as transmog collection status."
L["OPTIONS_INSIGHT_SECTION_IDENTITY"]                                 = "Identity"
L["OPTIONS_INSIGHT_PLAYER_NAME_COLOR"]                                = "Player name colour"
L["OPTIONS_INSIGHT_PLAYER_NAME_COLOR_DESC"]                           = "Colour for the player's name on the first tooltip line: faction (Alliance blue, Horde red) or class."
L["OPTIONS_INSIGHT_PLAYER_NAME_COLOR_FACTION"]                        = "Faction"
L["OPTIONS_INSIGHT_PLAYER_NAME_COLOR_CLASS"]                          = "Class"
L["OPTIONS_INSIGHT_SECTION_STATUS_PVP"]                               = "Status & PvP"
L["OPTIONS_INSIGHT_SECTION_RATINGS_GEAR"]                             = "Ratings & gear"
L["OPTIONS_INSIGHT_SECTION_MOUNT"]                                    = "Mount"
L["OPTIONS_INSIGHT_SECTION_DISMISS"]                                  = "Unit tooltip dismiss"
L["OPTIONS_INSIGHT_DISMISS_GRACE"]                                    = "Dismiss grace"
L["OPTIONS_INSIGHT_DISMISS_GRACE_DESC"]                               = "How long to wait after the mouse leaves a unit before dismiss begins. This is separate from fade-out duration, which only runs after dismiss starts. Longer grace reduces flicker from brief cursor gaps."
L["OPTIONS_INSIGHT_DISMISS_GRACE_INSTANT"]                            = "Instant"
L["OPTIONS_INSIGHT_DISMISS_GRACE_DEFAULT"]                            = "Normal"
L["OPTIONS_INSIGHT_DISMISS_GRACE_RELAXED"]                            = "Relaxed"
L["OPTIONS_INSIGHT_SECTION_COMBAT"]                                   = "Combat"
L["OPTIONS_INSIGHT_HIDE_IN_COMBAT"]                                   = "Hide tooltips in combat"
L["OPTIONS_INSIGHT_HIDE_IN_COMBAT_DESC"]                              = "While in combat, close GameTooltip and other Insight-styled tooltip frames and block them from staying open. Applies only when the Insight module is enabled."
L["OPTIONS_INSIGHT_FADE_OUT_SEC"]                                     = "Fade-out duration"
L["OPTIONS_INSIGHT_FADE_OUT_SEC_DESC"]                                = "How long the unit tooltip takes to fade out after dismiss has started (not the delay before dismiss). Zero hides immediately with no fade. Applies to GameTooltip unit tips only."
L["OPTIONS_INSIGHT_SECTION_ICONS_AND_SEPARATORS"]                     = "Icons & separators"
L["OPTIONS_INSIGHT_SECTION_NPC_TOOLTIP"]                              = "NPC tooltip"
L["OPTIONS_INSIGHT_SECTION_TRANSMOG"]                                 = "Transmog"
L["OPTIONS_INSIGHT_NPC_PLACEHOLDER"]                                  = "NPC-specific options will appear here when available. Reaction colours and level lines still apply in-game."
L["OPTIONS_INSIGHT_NPC_REACTION_BORDER"]                              = "Reaction border"
L["OPTIONS_INSIGHT_NPC_REACTION_BORDER_DESC"]                         = "Tint the tooltip border to the NPC's faction reaction (hostile red, friendly green, neutral yellow)."
L["OPTIONS_INSIGHT_NPC_REACTION_NAME"]                                = "Reaction name colour"
L["OPTIONS_INSIGHT_NPC_REACTION_NAME_DESC"]                           = "Colour the NPC's name to match their faction reaction."
L["OPTIONS_INSIGHT_NPC_LEVEL_LINE"]                                   = "Level line"
L["OPTIONS_INSIGHT_NPC_LEVEL_LINE_DESC"]                              = "Show the NPC's level, classification (Elite, Rare, etc.), and creature type beneath their name."
L["OPTIONS_INSIGHT_NPC_ICONS_DESC"]                                   = "Show an icon instead of '??' for NPCs with an unknown level."
L["OPTIONS_INSIGHT_SECTION_ITEM_STYLING"]                             = "Item styling"
L["OPTIONS_INSIGHT_ITEM_QUALITY_BORDER"]                              = "Quality border"
L["OPTIONS_INSIGHT_ITEM_QUALITY_BORDER_DESC"]                         = "Tint the tooltip border to the item's quality colour (Uncommon green, Rare blue, Epic purple, etc.)."
L["OPTIONS_INSIGHT_ITEM_SECTION_SPACING"]                             = "Blank line before blocks"
L["OPTIONS_INSIGHT_ITEM_SECTION_SPACING_DESC"]                        = "Insert a blank line before Insight blocks on item tooltips instead of a tinted separator line."
L["OPTIONS_AXIS_ITEM_TOOLTIP"]                                        = "Item Tooltip"
L["OPTIONS_AXIS_TRANSMOG_STATUS"]                                     = "Show transmog status"
L["OPTIONS_AXIS_WHETHER_YOU_COLLECTED_APPEARANCE_OF_AN"]              = "Show whether you have collected the appearance of an item you hover over."
L["OPTIONS_AXIS_PLAYER_TOOLTIP"]                                      = "Player Tooltip"
L["OPTIONS_AXIS_GUILD_RANK"]                                          = "Show guild rank"
L["OPTIONS_AXIS_APPEND_PLAYER_S_GUILD_RANK_NEXT"]                     = "Append the player's guild rank next to their guild name."
L["OPTIONS_AXIS_MYTHIC_SCORE"]                                        = "Show Mythic+ score"
L["OPTIONS_AXIS_PLAYER_S_CURRENT_SEASON_MYTHIC_SCORE"]                = "Show the player's current season Mythic+ score, colour-coded by tier."
L["OPTIONS_AXIS_ITEM_LEVEL"]                                          = "Show item level"
L["OPTIONS_AXIS_PLAYER_S_EQUIPPED_ITEM_LEVEL_AFTER"]                  = "Show the player's equipped item level after inspecting them."
L["OPTIONS_AXIS_HONOR_LEVEL"]                                         = "Show honor level"
L["OPTIONS_AXIS_PLAYER_S_PVP_HONOR_LEVEL_TOOLTIP"]                    = "Show the player's PvP honor level in the tooltip."
L["OPTIONS_AXIS_PVP_TITLE"]                                           = "Show PvP title"
L["OPTIONS_AXIS_PLAYER_S_PVP_TITLE_E_G"]                              = "Show the player's PvP title (e.g. Gladiator) in the tooltip."
L["OPTIONS_AXIS_CHARACTER_TITLE"]                                     = "Character title"
L["OPTIONS_AXIS_PLAYER_S_SELECTED_TITLE_ACHIEVEMENT_PVP"]             = "Show the player's selected title (achievement or PvP) in the name line."
L["OPTIONS_AXIS_TITLE_COLOR"]                                         = "Title color"
L["OPTIONS_AXIS_COLOR_OF_CHARACTER_TITLE_PLAYER_TOOLTIP"]             = "Color of the character title in the player tooltip name line."
L["OPTIONS_AXIS_STATUS_BADGES"]                                       = "Show status badges"
L["OPTIONS_AXIS_INLINE_BADGES_COMBAT_AFK_DND_PVP"]                    = "Show inline badges for combat, AFK, DND, PvP flag, party/raid membership, friends, and whether the player is targeting you."
L["OPTIONS_AXIS_MOUNT_INFO"]                                          = "Show mount info"
L["OPTIONS_AXIS_HOVERING_A_MOUNTED_PLAYER_THEIR_MOUNT"]               = "When hovering a mounted player, show their mount name, source, and whether you own it."
L["OPTIONS_AXIS_BLANK_SEPARATOR"]                                     = "Blank separator"
L["OPTIONS_AXIS_A_BLANK_LINE_INSTEAD_OF_DASHES"]                      = "Use a blank line instead of dashes between tooltip sections."
L["OPTIONS_AXIS_ICONS"]                                               = "Show icons"
L["OPTIONS_AXIS_CLASS_ICON_STYLE"]                                    = "Class icon style"
L["OPTIONS_AXIS_DEFAULT_BLIZZARD_RONDOMEDIA_CLASS_ICONS_TH"]          = "Use Blizzard default, RondoMedia, or Horizon icons from this addon's media folder on the class/spec line."
L["OPTIONS_AXIS_CUSTOM_CLASS_ICONS_LABEL"]                            = "Horizon"
L["OPTIONS_AXIS_CLASS_ICON_SOURCES_TOOLTIP"]                          = "RondoMedia: https://www.curseforge.com/wow/addons/rondomedia — Horizon: bundled icons under media/CustomClassIcons/<CLASS>/<class lower>.tga (e.g. WARRIOR/warrior.tga); replace files and /reload to override."
L["OPTIONS_AXIS_RONDOMEDIA_CLASS_ICONS_RONDOFERRARI_HTTPS_WWW"]       = "RondoMedia class icons by RondoFerrari — https://www.curseforge.com/wow/addons/rondomedia"
L["OPTIONS_AXIS_DEFAULT"]                                             = "Default"
L["OPTIONS_AXIS_FACTION_SPEC_MOUNT_MYTHIC_ICONS_TOOLTIPS"]            = "Show faction, spec, mount, and Mythic+ icons in tooltips."
L["OPTIONS_AXIS_GENERAL"]                                             = "General"
L["OPTIONS_AXIS_POSITION"]                                            = "Position"
L["OPTIONS_AXIS_RESET_POSITION"]                                      = "Reset position"
L["OPTIONS_AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"]                   = "Reset loot toast position to default."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["OPTIONS_FOCUS_LOCK_POSITION"]                                      = "Lock position"
L["OPTIONS_FOCUS_PREVENT_DRAGGING_TRACKER"]                           = "Prevent dragging the tracker."
L["OPTIONS_FOCUS_GROW_UPWARD"]                                        = "Grow upward"
L["OPTIONS_FOCUS_GROW_HEADER"]                                        = "Grow-up header"
L["OPTIONS_FOCUS_GROWING_UPWARD_KEEP_HEADER_BOTTOM_TOP"]              = "When growing upward: keep header at bottom, or at top until collapsed."
L["OPTIONS_FOCUS_HEADER_BOTTOM"]                                      = "Header at bottom"
L["OPTIONS_FOCUS_HEADER_SLIDES_COLLAPSE"]                             = "Header slides on collapse"
L["OPTIONS_FOCUS_ANCHOR_BOTTOM_LIST_GROWS_UPWARD"]                    = "Anchor at bottom so the list grows upward."
L["OPTIONS_FOCUS_START_COLLAPSED"]                                    = "Start collapsed"
L["OPTIONS_FOCUS_START_HEADER_SHOWN_UNTIL_YOU_EXPAND"]                = "Start with only the header shown until you expand."
L["OPTIONS_FOCUS_ALIGN_CONTENT_RIGHT"]                                = "Align content right"
L["OPTIONS_FOCUS_RIGHT_ALIGN_QUEST_TITLES_OBJECTIVES_WITHIN"]         = "Right-align quest titles and objectives within the panel."
L["OPTIONS_FOCUS_PANEL_WIDTH"]                                        = "Panel width"
L["OPTIONS_FOCUS_TRACKER_WIDTH_PIXELS"]                               = "Tracker width in pixels."
L["OPTIONS_FOCUS_MAX_CONTENT_HEIGHT"]                                 = "Max content height"
L["OPTIONS_FOCUS_MAX_HEIGHT_OF_SCROLLABLE_LIST_PIXELS"]               = "Max height of the scrollable list (pixels)."

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["OPTIONS_FOCUS_ALWAYS_M_BLOCK"]                                     = "Always show M+ block"
L["OPTIONS_FOCUS_M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]                = "Show the M+ block whenever an active keystone is running"
L["OPTIONS_FOCUS_DUNGEON"]                                            = "Show in dungeon"
L["OPTIONS_FOCUS_TRACKER_PARTY_DUNGEONS"]                             = "Show tracker in party dungeons."
L["OPTIONS_FOCUS_RAID"]                                               = "Show in raid"
L["OPTIONS_FOCUS_TRACKER_RAIDS"]                                      = "Show tracker in raids."
L["OPTIONS_FOCUS_BATTLEGROUND"]                                       = "Show in battleground"
L["OPTIONS_FOCUS_TRACKER_BATTLEGROUNDS"]                              = "Show tracker in battlegrounds."
L["OPTIONS_FOCUS_ARENA"]                                              = "Show in arena"
L["OPTIONS_FOCUS_TRACKER_ARENAS"]                                     = "Show tracker in arenas."
L["OPTIONS_FOCUS_HIDE_COMBAT"]                                        = "Hide in combat"
L["OPTIONS_FOCUS_HIDE_TRACKER_FLOATING_QUEST_ITEM_COMBAT"]            = "Hide tracker and floating quest item in combat."
L["OPTIONS_FOCUS_COMBAT_VISIBILITY"]                                  = "Combat visibility"
L["OPTIONS_FOCUS_TRACKER_BEHAVES_COMBAT_FADE_REDUC"]                  = "How the tracker behaves in combat: show, fade to reduced opacity, or hide."
L["OPTIONS_FOCUS_SHOW"]                                               = "Show"
L["OPTIONS_FOCUS_FADE"]                                               = "Fade"
L["OPTIONS_FOCUS_HIDE"]                                               = "Hide"
L["OPTIONS_FOCUS_COMBAT_FADE_OPACITY"]                                = "Combat fade opacity"
L["OPTIONS_FOCUS_VISIBLE_TRACKER_FADED_COMBAT"]                       = "How visible the tracker is when faded in combat (0 = invisible). Only applies when Combat visibility is Fade."
L["OPTIONS_FOCUS_MOUSEOVER"]                                          = "Mouseover"
L["OPTIONS_FOCUS_SHOW_ONLY_MOUSEOVER"]                                = "Show only on mouseover"
L["OPTIONS_FOCUS_FADE_TRACKER_HOVERING_MOVE_MOUSE"]                   = "Fade tracker when not hovering; move mouse over it to show."
L["OPTIONS_FOCUS_FADED_OPACITY"]                                      = "Faded opacity"
L["OPTIONS_FOCUS_VISIBLE_TRACKER_FADED_INVISIBLE"]                    = "How visible the tracker is when faded (0 = invisible)."
L["OPTIONS_FOCUS_QUESTS_CURRENT_ZONE"]                                = "Only show quests in current zone"
L["OPTIONS_FOCUS_HIDE_QUESTS_OUTSIDE_YOUR_CURRENT_ZONE"]              = "Hide quests outside your current zone."

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["OPTIONS_FOCUS_QUEST_COUNT"]                                        = "Show quest count"
L["OPTIONS_FOCUS_QUEST_COUNT_HEADER"]                                 = "Show quest count in header."
L["OPTIONS_FOCUS_HEADER_COUNT_FORMAT"]                                = "Header count format"
L["OPTIONS_FOCUS_TRACKED_LOG_LOG_MAX_SLOTS_TRACKED"]                  = "Tracked/in-log or in-log/max-slots. Tracked excludes world/live-in-zone quests."
L["OPTIONS_FOCUS_HEADER_DIVIDER"]                                     = "Show header divider"
L["OPTIONS_FOCUS_LINE_BELOW_HEADER"]                                  = "Show the line below the header."
L["OPTIONS_FOCUS_HEADER_DIVIDER_COLOR"]                               = "Header divider color"
L["OPTIONS_FOCUS_COLOR_OF_LINE_BELOW_HEADER"]                         = "Color of the line below the header."
L["OPTIONS_FOCUS_SUPER_MINIMAL_MODE"]                                 = "Super-minimal mode"
L["OPTIONS_FOCUS_HIDE_HEADER_A_PURE_TEXT_LIST"]                       = "Hide header for a pure text list."
L["OPTIONS_FOCUS_OPTIONS_BUTTON"]                                     = "Show options button"
L["OPTIONS_FOCUS_OPTIONS_BUTTON_TRACKER_HEADER"]                      = "Show the Options button in the tracker header."
L["OPTIONS_FOCUS_HEADER_COLOR"]                                       = "Header color"
L["OPTIONS_FOCUS_COLOR_OF_OBJECTIVES_HEADER_TEXT"]                    = "Color of the OBJECTIVES header text."
L["OPTIONS_FOCUS_HEADER_HEIGHT"]                                      = "Header height"
L["OPTIONS_FOCUS_HEIGHT_OF_HEADER_BAR_PIXELS"]                        = "Height of the header bar in pixels (18–48)."

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["OPTIONS_FOCUS_SECTION_HEADERS"]                                    = "Show section headers"
L["OPTIONS_FOCUS_CATEGORY_LABELS_ABOVE_GROUP"]                        = "Show category labels above each group."
L["OPTIONS_FOCUS_CATEGORY_HEADERS_COLLAPSED"]                         = "Show category headers when collapsed"
L["OPTIONS_FOCUS_KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED_CLICK"]       = "Keep section headers visible when collapsed; click to expand a category."
L["OPTIONS_FOCUS_NEARBY_CURRENT_ZONE_GROUP"]                          = "Show Nearby (Current Zone) group"
L["OPTIONS_FOCUS_ZONE_QUESTS_A_DEDICATED_CURRENT_ZONE"]               = "Show in-zone quests in a dedicated Current Zone section. When off, they appear in their normal category."
L["OPTIONS_FOCUS_ZONE_LABELS"]                                        = "Show zone labels"
L["OPTIONS_FOCUS_ZONE_NAME_UNDER_QUEST_TITLE"]                        = "Show zone name under each quest title."
L["OPTIONS_FOCUS_ACTIVE_QUEST_HIGHLIGHT"]                             = "Active quest highlight"
L["OPTIONS_FOCUS_FOCUSED_QUEST_HIGHLIGHTED"]                          = "How the focused quest is highlighted."
L["OPTIONS_FOCUS_QUEST_ITEM_BUTTONS"]                                 = "Show quest item buttons"
L["OPTIONS_FOCUS_USABLE_QUEST_ITEM_BUTTON_NEXT_QUEST"]                = "Show usable quest item button next to each quest."
L["OPTIONS_FOCUS_TOOLTIPS_HOVER"]                                     = "Tooltips on hover"
L["OPTIONS_FOCUS_TOOLTIPS_HOVERING_TRACKER_ENTRIES_ITE"]              = "Show tooltips when hovering over tracker entries, item buttons, and scenario blocks."
L["OPTIONS_FOCUS_WOWHEAD_LINK_TOOLTIPS"]                              = "Show WoWhead link in tooltips"
L["OPTIONS_FOCUS_A_TOOLTIP_SHOWN_ADD_A_LINK"]                         = "When a tooltip is shown, add a link to open the quest, achievement, or NPC on WoWhead."
L["OPTIONS_FOCUS_VIEW_WOWHEAD"]                                       = "View on WoWhead"
L["OPTIONS_FOCUS_WOWHEAD_ALT_CLICK_HINT"]                             = "Alt + Click"
L["OPTIONS_FOCUS_COPY_LINK"]                                          = "Copy link"
L["OPTIONS_FOCUS_COPY_URL_BELOW_CTRL_C_PASTE"]                        = "Copy the URL below (Ctrl+C) and paste in your browser."
L["OPTIONS_FOCUS_OBJECTIVE_NUMBERS"]                                  = "Show objective numbers"
L["OPTIONS_FOCUS_OBJECTIVE_PREFIX"]                                   = "Objective prefix"
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLORS"]                   = "Color objective progress numbers"
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLORS_DESC"]              = "Tint the full X/Y token: normal color at 0/n, gold while in progress, green when complete (numbers and slash)."
L["OPTIONS_FOCUS_PREFIX_OBJECTIVE_A_NUMBER_HYPHEN"]                   = "Prefix each objective with a number or hyphen."
L["OPTIONS_FOCUS_NUMBERS"]                                            = "Numbers (1. 2. 3.)"
L["OPTIONS_FOCUS_HYPHENS"]                                            = "Hyphens (-)"
L["OPTIONS_FOCUS_AFTER_SECTION_HEADER"]                               = "After section header"
L["OPTIONS_FOCUS_BEFORE_SECTION_HEADER"]                              = "Before section header"
L["OPTIONS_FOCUS_BELOW_HEADER"]                                       = "Below header"
L["OPTIONS_FOCUS_INLINE_BELOW_TITLE"]                                 = "Inline below title"
L["OPTIONS_FOCUS_PREFIX_OBJECTIVES"]                                  = "Prefix objectives with 1., 2., 3."
L["OPTIONS_FOCUS_COMPLETED_COUNT"]                                    = "Show completed count"
L["OPTIONS_FOCUS_X_Y_PROGRESS_QUEST_TITLE"]                           = "Show X/Y progress in quest title."
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_BAR"]                             = "Show objective progress bar"
L["OPTIONS_FOCUS_A_PROGRESS_BAR_UNDER_OBJECTIVES_NUMER"]              = "Show a progress bar under objectives that have numeric progress (e.g. 3/250). Only applies to entries with a single arithmetic objective where the required amount is greater than 1."
L["OPTIONS_FOCUS_CATEGORY_COLOR_PROGRESS_BAR"]                        = "Use category color for progress bar"
L["OPTIONS_FOCUS_PROGRESS_BAR_MATCHES_QUEST_ACHIEVEME"]               = "When on, the progress bar matches the quest/achievement category color. When off, uses the custom fill color below."
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXTURE"]                               = "Progress bar texture"
L["OPTIONS_FOCUS_PROGRESS_BAR_TYPES"]                                 = "Progress bar types"
L["OPTIONS_FOCUS_TEXTURE_PROGRESS_BAR_FILL"]                          = "Texture for the progress bar fill."
L["OPTIONS_FOCUS_TEXTURE_PROGRESS_BAR_FILL_SOLID_YOUR"]               = "Texture for the progress bar fill. Solid uses your chosen colors. SharedMedia addons add more options."
L["OPTIONS_FOCUS_PROGRESS_BAR_X_Y_OBJECTIVES_PERCENT"]                = "Show progress bar for X/Y objectives, percent-only objectives, or both."
L["OPTIONS_FOCUS_X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]             = "X/Y: objectives like 3/10. Percent: objectives like 45%."
L["OPTIONS_FOCUS_X_Y"]                                                = "X/Y only"
L["OPTIONS_FOCUS_PERCENT"]                                            = "Percent only"
L["OPTIONS_FOCUS_TICK_COMPLETED_OBJECTIVES"]                          = "Use tick for completed objectives"
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES_A_CHECKMARK_INSTEA"]            = "When on, completed objectives show a checkmark (✓) instead of green color."
L["OPTIONS_FOCUS_ENTRY_NUMBERS"]                                      = "Show entry numbers"
L["OPTIONS_FOCUS_PREFIX_QUEST_TITLES_WITHIN_CATEGORY"]                = "Prefix quest titles with 1., 2., 3. within each category."
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES"]                               = "Completed objectives"
L["OPTIONS_FOCUS_MULTI_OBJECTIVE_QUESTS_DISPLAY_OBJECTIVES"]          = "For multi-objective quests, how to display objectives you've completed (e.g. 1/1)."
L["OPTIONS_FOCUS_ALL"]                                                = "Show all"
L["OPTIONS_FOCUS_FADE_COMPLETED"]                                     = "Fade completed"
L["OPTIONS_FOCUS_HIDE_COMPLETED"]                                     = "Hide completed"
L["OPTIONS_FOCUS_ICON_ZONE_AUTO_TRACKING"]                            = "Show icon for in-zone auto-tracking"
L["OPTIONS_FOCUS_DISPLAY_AN_ICON_NEXT_AUTO_TRACKED"]                  = "Display an icon next to auto-tracked world quests and weeklies/dailies that are not yet in your quest log (in-zone only)."
L["OPTIONS_FOCUS_AUTO_TRACK_ICON"]                                    = "Auto-track icon"
L["OPTIONS_FOCUS_CHOOSE_WHICH_ICON_DISPLAY_NEXT_AUTO"]                = "Choose which icon to display next to auto-tracked in-zone entries."
L["OPTIONS_FOCUS_APPEND_WORLD_QUESTS_WEEKLIES_DAILIES"]               = "Append ** to world quests and weeklies/dailies that are not yet in your quest log (in-zone only)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["OPTIONS_FOCUS_COMPACT_MODE"]                                       = "Compact mode"
L["OPTIONS_FOCUS_PRESET_SETS_ENTRY_OBJECTIVE_SPACING_P"]              = "Preset: sets entry and objective spacing to 4 and 1 px."
L["OPTIONS_FOCUS_SPACING_PRESET"]                                     = "Spacing preset"
L["OPTIONS_FOCUS_PRESET_ENTRY_OBJECTIVE_SPACING_DEFAULT_P"]           = "Preset for entry and objective spacing: Default (8/2 px), Compact (4/1 px), Spaced (12/3 px), or Custom (use sliders)."
L["OPTIONS_FOCUS_COMPACT_VERSION"]                                    = "Compact version"
L["OPTIONS_FOCUS_SPACED_VERSION"]                                     = "Spaced version"
L["OPTIONS_FOCUS_SPACING_BETWEEN_QUEST_ENTRIES_PX"]                   = "Spacing between quest entries (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_QUEST_ENTRIES"]                 = "Vertical gap between quest entries."
L["OPTIONS_FOCUS_SPACING_BEFORE_CATEGORY_HEADER_PX"]                  = "Spacing before category header (px)"
L["OPTIONS_FOCUS_GAP_BETWEEN_LAST_ENTRY_OF_A"]                        = "Gap between last entry of a group and the next category label."
L["OPTIONS_FOCUS_SPACING_AFTER_CATEGORY_HEADER_PX"]                   = "Spacing after category header (px)"
L["OPTIONS_FOCUS_GAP_BETWEEN_CATEGORY_LABEL_FIRST_QUEST"]             = "Gap between category label and first quest entry below it."
L["OPTIONS_FOCUS_SPACING_BETWEEN_OBJECTIVES_PX"]                      = "Spacing between objectives (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVE_LINES_WITHIN"]        = "Vertical gap between objective lines within a quest."
L["OPTIONS_FOCUS_TITLE_CONTENT"]                                      = "Title to content"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_QUEST_TITLE_OBJECTIVES"]        = "Vertical gap between quest title and objectives or zone below it."
L["OPTIONS_FOCUS_SPACING_BELOW_HEADER_PX"]                            = "Spacing below header (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVES_BAR_QUES"]           = "Vertical gap between the objectives bar and the quest list."
L["OPTIONS_FOCUS_RESET_SPACING"]                                      = "Reset spacing"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_QUEST_LEVEL"]                                   = "Show quest level"
L["OPTIONS_FOCUS_QUEST_LEVEL_NEXT_TITLE"]                             = "Show quest level next to title."
L["OPTIONS_FOCUS_DIM_FOCUSED_QUESTS"]                                 = "Dim non-focused quests"
L["OPTIONS_FOCUS_SLIGHTLY_DIM_TITLE_ZONE_OBJECTIVES_SECTION"]         = "Slightly dim title, zone, objectives, and section headers that are not focused."
L["OPTIONS_FOCUS_DIM_UNFOCUSED_ENTRIES"]                              = "Dim unfocused entries"
L["OPTIONS_FOCUS_CLICK_A_SECTION_HEADER_EXPAND_CATEGORY"]             = "Click a section header to expand that category."

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["UI_SHOW_RARE_BOSSES"]                                              = "Show rare bosses"
L["UI_RARE_BOSS_VIGNETTES_LIST"]                                      = "Show rare boss vignettes in the list."
L["UI_RARE_LOOT"]                                                     = "Rare Loot"
L["UI_TREASURE_ITEM_VIGNETTES_RARE_LOOT"]                             = "Show treasure and item vignettes in the Rare Loot list."
L["UI_RARE_SOUND_VOLUME"]                                             = "Rare sound volume"
L["UI_VOLUME_OF_RARE_ALERT_SOUND"]                                    = "Volume of the rare alert sound (50–200%)."
L["UI_BOOST_REDUCE_RARE_ALERT_VOLUME"]                                = "Boost or reduce the rare alert volume. 100% = normal; 150% = louder."
L["UI_RARE_ADDED_SOUND"]                                              = "Rare added sound"
L["UI_PLAY_A_SOUND_A_RARE"]                                           = "Play a sound when a rare is added."
L["UI_MINIMAP_PATCH_NOTES_UNREAD_HINT"]                               = "New patch notes — open Axis and choose Patch Notes."

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["OPTIONS_FOCUS_ZONE_WORLD_QUESTS"]                                  = "Show in-zone world quests"
L["OPTIONS_FOCUS_AUTO_ADD_WORLD_QUESTS_YOUR_CURRENT"]                 = "Auto-add world quests in your current zone. When off, only quests you've tracked or world quests you're in close proximity to appear (Blizzard default)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_FLOATING_QUEST_ITEM"]                           = "Show floating quest item"
L["OPTIONS_FOCUS_QUICK_BUTTON_FOCUSED_QUEST_S_USABLE"]                = "Show quick-use button for the focused quest's usable item."
L["OPTIONS_FOCUS_LOCK_FLOATING_QUEST_ITEM_POSITION"]                  = "Lock floating quest item position"
L["OPTIONS_FOCUS_PREVENT_DRAGGING_FLOATING_QUEST_ITEM_BUTTON"]        = "Prevent dragging the floating quest item button."
L["OPTIONS_FOCUS_FLOATING_QUEST_ITEM_SOURCE"]                         = "Floating quest item source"
L["OPTIONS_FOCUS_WHICH_QUEST_S_ITEM_SUPER_TRACKED"]                   = "Which quest's item to show: super-tracked first, or current zone first."
L["OPTIONS_FOCUS_SUPER_TRACKED_FIRST"]                                = "Super-tracked, then first"
L["OPTIONS_FOCUS_CURRENT_ZONE_FIRST"]                                 = "Current zone first"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["OPTIONS_FOCUS_MYTHIC_BLOCK"]                                       = "Show Mythic+ block"
L["OPTIONS_FOCUS_TIMER_COMPLETION_AFFIXES_MYTHIC_DUNGEONS"]           = "Show timer, completion %, and affixes in Mythic+ dungeons."
L["OPTIONS_FOCUS_M_BLOCK_POSITION"]                                   = "M+ block position"
L["OPTIONS_FOCUS_POSITION_OF_MYTHIC_BLOCK_RELATIVE_QUEST"]            = "Position of the Mythic+ block relative to the quest list."
L["OPTIONS_FOCUS_AFFIX_ICONS"]                                        = "Show affix icons"
L["OPTIONS_FOCUS_AFFIX_ICONS_NEXT_MODIFIER_NAMES_M"]                  = "Show affix icons next to modifier names in the M+ block."
L["OPTIONS_FOCUS_AFFIX_DESCRIPTIONS_TOOLTIP"]                         = "Show affix descriptions in tooltip"
L["OPTIONS_FOCUS_AFFIX_DESCRIPTIONS_HOVERING_M_BLO"]                  = "Show affix descriptions when hovering over the M+ block."
L["OPTIONS_FOCUS_M_COMPLETED_BOSS_DISPLAY"]                           = "M+ completed boss display"
L["OPTIONS_FOCUS_DEFEATED_BOSSES_CHECKMARK_ICON_GREEN"]               = "How to show defeated bosses: checkmark icon or green color."
L["OPTIONS_FOCUS_CHECKMARK"]                                          = "Checkmark"
L["OPTIONS_FOCUS_GREEN_COLOR"]                                        = "Green color"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["OPTIONS_PRESENCE_ACHIEVEMENTS"]                                    = "Show achievements"
L["OPTIONS_FOCUS_TRACKED_ACHIEVEMENTS_LIST"]                          = "Show tracked achievements in the list."
L["OPTIONS_FOCUS_COMPLETED_ACHIEVEMENTS"]                             = "Show completed achievements"
L["OPTIONS_FOCUS_INCLUDE_COMPLETED_ACHIEVEMENTS_TRACKER_O"]           = "Include completed achievements in the tracker. When off, only in-progress tracked achievements are shown."
L["OPTIONS_FOCUS_ACHIEVEMENT_ICONS"]                                  = "Show achievement icons"
L["OPTIONS_FOCUS_ACHIEVEMENT_S_ICON_NEXT_TITLE_REQUI"]                = "Show each achievement's icon next to the title. Requires 'Show quest type icons' in Display."
L["OPTIONS_FOCUS_MISSING_REQUIREMENTS"]                               = "Only show missing requirements"
L["OPTIONS_FOCUS_CRITERIA_YOU_HAVEN_T_COMPLETED_TR"]                  = "Show only criteria you haven't completed for each tracked achievement. When off, all criteria are shown."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_ENDEAVORS"]                                     = "Show endeavors"
L["OPTIONS_FOCUS_TRACKED_ENDEAVORS_PLAYER_HOUSING_LIST"]              = "Show tracked Endeavors (Player Housing) in the list."
L["OPTIONS_FOCUS_COMPLETED_ENDEAVORS"]                                = "Show completed endeavors"
L["OPTIONS_FOCUS_INCLUDE_COMPLETED_ENDEAVORS_TRACKER"]                = "Include completed Endeavors in the tracker. When off, only in-progress tracked Endeavors are shown."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_DECOR"]                                         = "Show decor"
L["OPTIONS_FOCUS_TRACKED_HOUSING_DECOR_LIST"]                         = "Show tracked housing decor in the list."
L["OPTIONS_FOCUS_DECOR_ICONS"]                                        = "Show decor icons"
L["OPTIONS_FOCUS_DECOR_ITEM_S_ICON_NEXT_TITLE"]                       = "Show each decor item's icon next to the title. Requires 'Show quest type icons' in Display."

-- =====================================================================
-- OptionsData.lua Features — Appearances
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_APPEARANCES"]                                   = "Show appearances"
L["OPTIONS_FOCUS_TRACKED_TRANSMOG_APPEARANCES_LIST"]                  = "Show tracked transmog appearances in the list."
L["OPTIONS_FOCUS_INCLUDE_COLLECTED_APPEARANCES_TRACKER"]              = "Include collected appearances in the tracker. When off, only appearances you have not yet collected are shown."
L["OPTIONS_FOCUS_APPEARANCE_ICONS"]                                   = "Show appearance icons"
L["OPTIONS_FOCUS_APPEARANCE_ICON_NEXT_TITLE"]                         = "Show each appearance's icon next to the title. Requires 'Show quest type icons' in Display."
L["OPTIONS_FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON"]                  = "Use transmog list icon"
L["OPTIONS_FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON_DESC"]             = "Use the in-game Appearances / transmog list icon for every row instead of each appearance's item icon. If that icon cannot be resolved, the item icon is used."
L["OPTIONS_FOCUS_SHOW_APPEARANCE_WARDROBE"]                           = "Show wardrobe"
L["OPTIONS_FOCUS_OPEN_APPEARANCES_COLLECTIONS"]                       = "Open Collections"
L["OPTIONS_FOCUS_UNTRACK_APPEARANCE"]                                 = "Untrack appearance"
L["OPTIONS_FOCUS_APPEARANCE_HORIZON_CONTROLS_HINT"]                   = "Horizon: Shift-click map; with TomTom waypoints enabled, that click also sets the arrow. Ctrl-click Collections, Alt-click dressing room. Right-click clears focus or untracks."

-- =====================================================================
-- OptionsData.lua Features — Adventure Guide
-- =====================================================================
L["OPTIONS_FOCUS_ADVENTURE_GUIDE"]                                    = "Adventure Guide"
L["OPTIONS_FOCUS_TRAVELER_S_LOG"]                                     = "Show Traveler's Log"
L["OPTIONS_FOCUS_TRACKED_TRAVELER_S_LOG_OBJECTIVES_SHIFT"]            = "Show tracked Traveler's Log objectives (Shift+click in Adventure Guide) in the list."
L["OPTIONS_FOCUS_AUTO_REMOVE_COMPLETED_ACTIVITIES"]                   = "Auto-remove completed activities"
L["OPTIONS_FOCUS_AUTOMATICALLY_STOP_TRACKING_TRAVELER_S_LOG"]         = "Automatically stop tracking Traveler's Log activities once they have been completed."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["OPTIONS_FOCUS_SCENARIO_EVENTS"]                                    = "Show scenario events"
L["OPTIONS_FOCUS_ACTIVE_SCENARIO_DELVE_ACTIVITIES_DELVES_APP"]        = "Show active scenario and Delve activities. Delves appear in DELVES; other scenarios in SCENARIO EVENTS."
L["OPTIONS_FOCUS_TRACK_DELVE_DUNGEON_SCENARIO_ACTIVITIES"]            = "Track Delve, Dungeon, and scenario activities."
L["OPTIONS_FOCUS_DELVES_APPEAR_DELVES_SECTION_DUNGEONS_DUNGEON"]      = "Delves appear in Delves section; dungeons in Dungeon; other scenarios in Scenario Events."
L["OPTIONS_FOCUS_DELVES_APPEAR_DELVES_SECTION_SCENARIOS_S"]           = "Delves appear in Delves section; other scenarios in Scenario Events."
L["OPTIONS_FOCUS_DELVE_AFFIX_NAMES"]                                  = "Delve affix names"
L["OPTIONS_FOCUS_DELVE_DUNGEON"]                                      = "Delve/Dungeon only"
L["OPTIONS_FOCUS_SCENARIO_DEBUG_LOGGING"]                             = "Scenario debug logging"
L["OPTIONS_FOCUS_LOG_SCENARIO_API_DATA_CHAT_H"]                       = "Log scenario API data to chat. Use /h debug focus scendebug to toggle."
L["OPTIONS_FOCUS_PRINTS_C_SCENARIOINFO_CRITERIA_WIDGET_DATA"]         = "Prints C_ScenarioInfo criteria and widget data when in a scenario. Helps diagnose display issues like Abundance 46/300."
L["OPTIONS_FOCUS_HIDE_CATEGORIES_DELVE_DUNGEON"]                      = "Hide other categories in Delve or Dungeon"
L["OPTIONS_FOCUS_DELVES_PARTY_DUNGEONS_DELVE_DUNG"]                   = "In Delves or party dungeons, show only the Delve/Dungeon section."
L["OPTIONS_FOCUS_DELVE_NAME_SECTION_HEADER"]                          = "Use delve name as section header"
L["OPTIONS_FOCUS_A_DELVE_DELVE_NAME_TIER_AFFIXES"]                    = "When in a Delve, show the delve name, tier, and affixes as the section header instead of a separate banner. Disable to show the Delve block above the list."
L["OPTIONS_FOCUS_AFFIX_NAMES_DELVES"]                                 = "Show affix names in Delves"
L["OPTIONS_FOCUS_SEASON_AFFIX_NAMES_FIRST_DELVE_ENTRY"]               = "Show season affix names on the first Delve entry. Requires Blizzard's objective tracker widgets to be populated; may not show when using a full tracker replacement."
L["OPTIONS_FOCUS_CINEMATIC_SCENARIO_BAR"]                             = "Cinematic scenario bar"
L["OPTIONS_FOCUS_TIMER_PROGRESS_BAR_SCENARIO_ENTRIES"]                = "Show timer and progress bar for scenario entries."
L["OPTIONS_FOCUS_TIMER"]                                              = "Show timer"
L["OPTIONS_FOCUS_COUNTDOWN_TIMER_TIMED_QUESTS_EVENTS_SCEN"]           = "Show countdown timer on timed quests, events, and scenarios. When off, timers are hidden for all entry types."
L["OPTIONS_FOCUS_TIMER_SCENARIOS"]                                    = "Scenarios"
L["OPTIONS_FOCUS_TIMER_SCENARIOS_DESC"]                               = "Show countdown timer for scenario, delve, and dungeon tracker entries."
L["OPTIONS_FOCUS_TIMER_WORLD"]                                        = "World Quests"
L["OPTIONS_FOCUS_TIMER_WORLD_DESC"]                                   = "Show countdown timer for world quests and callings."
L["OPTIONS_FOCUS_TIMER_QUEST_LOG"]                                    = "Dailies / Weeklies"
L["OPTIONS_FOCUS_TIMER_QUEST_LOG_DESC"]                               = "Show countdown timer for dailies, weeklies, and other timed quest log entries."
L["OPTIONS_FOCUS_TIMER_DISPLAY"]                                      = "Timer display"
L["OPTIONS_FOCUS_COLOR_TIMER_REMAINING"]                              = "Color timer by remaining time"
L["OPTIONS_FOCUS_GREEN_PLENTY_OF_LEFT_YELLOW_RUNNING"]                = "Green when plenty of time left, yellow when running low, red when critical."
L["OPTIONS_FOCUS_WHERE_COUNTDOWN_BAR_BELOW_OBJECTIVES"]               = "Where to show the countdown: bar below objectives or text beside the quest name."
L["OPTIONS_FOCUS_BAR_BELOW"]                                          = "Bar below"
L["OPTIONS_FOCUS_INLINE_BESIDE_TITLE"]                                = "Inline beside title"

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["OPTIONS_FOCUS_FONT_FAMILY"]                                        = "Font family."
L["OPTIONS_FOCUS_TITLE_FONT"]                                         = "Title font"
L["OPTIONS_VISTA_ZONE_FONT"]                                          = "Zone font"
L["OPTIONS_FOCUS_OBJECTIVE_FONT"]                                     = "Objective font"
L["OPTIONS_FOCUS_SECTION_FONT"]                                       = "Section font"
L["OPTIONS_FOCUS_GLOBAL_FONT"]                                        = "Use global font"
L["OPTIONS_FOCUS_FONT_FAMILY_QUEST_TITLES"]                           = "Font family for quest titles."
L["OPTIONS_FOCUS_FONT_FAMILY_ZONE_LABELS"]                            = "Font family for zone labels."
L["OPTIONS_FOCUS_FONT_FAMILY_OBJECTIVE_TEXT"]                         = "Font family for objective text."
L["OPTIONS_FOCUS_FONT_FAMILY_SECTION_HEADERS"]                        = "Font family for section headers."
L["OPTIONS_FOCUS_HEADER_SIZE"]                                        = "Header size"
L["OPTIONS_FOCUS_HEADER_FONT_SIZE"]                                   = "Header font size."
L["OPTIONS_FOCUS_TITLE_SIZE"]                                         = "Title size"
L["OPTIONS_FOCUS_QUEST_TITLE_FONT_SIZE"]                              = "Quest title font size."
L["OPTIONS_FOCUS_OBJECTIVE_SIZE"]                                     = "Objective size"
L["OPTIONS_FOCUS_OBJECTIVE_TEXT_FONT_SIZE"]                           = "Objective text font size."
L["OPTIONS_FOCUS_ZONE_SIZE"]                                          = "Zone size"
L["OPTIONS_FOCUS_ZONE_LABEL_FONT_SIZE"]                               = "Zone label font size."
L["OPTIONS_FOCUS_SECTION_SIZE"]                                       = "Section size"
L["OPTIONS_FOCUS_SECTION_HEADER_FONT_SIZE"]                           = "Section header font size."
L["OPTIONS_FOCUS_PROGRESS_BAR_FONT"]                                  = "Progress bar font"
L["OPTIONS_FOCUS_FONT_FAMILY_PROGRESS_BAR_LABEL"]                     = "Font family for the progress bar label."
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXT_SIZE"]                             = "Progress bar text size"
L["OPTIONS_FOCUS_FONT_SIZE_PROGRESS_BAR_LABEL_ADJUSTS"]               = "Font size for the progress bar label. Also adjusts bar height. Affects quest objectives, scenario progress, and scenario timer bars."
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL"]                                  = "Progress bar fill"
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXT"]                                  = "Progress bar text"
L["OPTIONS_FOCUS_OUTLINE"]                                            = "Outline"
L["OPTIONS_FOCUS_FONT_OUTLINE_STYLE"]                                 = "Font outline style."

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["OPTIONS_FOCUS_HEADER_TEXT_CASE"]                                   = "Header text case"
L["OPTIONS_FOCUS_DISPLAY_CASE_HEADER"]                                = "Display case for header."
L["OPTIONS_FOCUS_SECTION_HEADER_CASE"]                                = "Section header case"
L["OPTIONS_FOCUS_DISPLAY_CASE_CATEGORY_LABELS"]                       = "Display case for category labels."
L["OPTIONS_FOCUS_QUEST_TITLE_CASE"]                                   = "Quest title case"
L["OPTIONS_FOCUS_DISPLAY_CASE_QUEST_TITLES"]                          = "Display case for quest titles."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["OPTIONS_FOCUS_TEXT_SHADOW"]                                        = "Show text shadow"
L["OPTIONS_FOCUS_ENABLE_DROP_SHADOW_TEXT"]                            = "Enable drop shadow on text."
L["OPTIONS_FOCUS_SHADOW_X"]                                           = "Shadow X"
L["OPTIONS_FOCUS_HORIZONTAL_SHADOW_OFFSET"]                           = "Horizontal shadow offset."
L["OPTIONS_FOCUS_SHADOW_Y"]                                           = "Shadow Y"
L["OPTIONS_FOCUS_VERTICAL_SHADOW_OFFSET"]                             = "Vertical shadow offset."
L["OPTIONS_FOCUS_SHADOW_ALPHA"]                                       = "Shadow alpha"
L["OPTIONS_FOCUS_SHADOW_OPACITY"]                                     = "Shadow opacity (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["OPTIONS_FOCUS_MYTHIC_TYPOGRAPHY"]                                  = "Mythic+ Typography"
L["OPTIONS_FOCUS_DUNGEON_NAME_SIZE"]                                  = "Dungeon name size"
L["OPTIONS_FOCUS_FONT_SIZE_DUNGEON_NAME_PX"]                          = "Font size for dungeon name (8–32 px)."
L["OPTIONS_FOCUS_DUNGEON_NAME_COLOR"]                                 = "Dungeon name color"
L["OPTIONS_FOCUS_TEXT_COLOR_DUNGEON_NAME"]                            = "Text color for dungeon name."
L["OPTIONS_FOCUS_TIMER_SIZE"]                                         = "Timer size"
L["OPTIONS_FOCUS_FONT_SIZE_TIMER_PX"]                                 = "Font size for timer (8–32 px)."
L["OPTIONS_FOCUS_TIMER_COLOR"]                                        = "Timer color"
L["OPTIONS_FOCUS_TEXT_COLOR_TIMER"]                                   = "Text color for timer (in time)."
L["OPTIONS_FOCUS_TIMER_OVERTIME_COLOR"]                               = "Timer overtime color"
L["OPTIONS_FOCUS_TEXT_COLOR_TIMER_LIMIT"]                             = "Text color for timer when over the time limit."
L["OPTIONS_FOCUS_PROGRESS_SIZE"]                                      = "Progress size"
L["OPTIONS_FOCUS_FONT_SIZE_ENEMY_FORCES_PX"]                          = "Font size for enemy forces (8–32 px)."
L["OPTIONS_FOCUS_PROGRESS_COLOR"]                                     = "Progress color"
L["OPTIONS_FOCUS_TEXT_COLOR_ENEMY_FORCES"]                            = "Text color for enemy forces."
L["OPTIONS_FOCUS_BAR_FILL_COLOR"]                                     = "Bar fill color"
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL_COLOR_PROGRESS"]                   = "Progress bar fill color (in progress)."
L["OPTIONS_FOCUS_BAR_COMPLETE_COLOR"]                                 = "Bar complete color"
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL_COLOR_ENEMY_FORCES"]               = "Progress bar fill color when enemy forces are at 100%."
L["OPTIONS_FOCUS_AFFIX_SIZE"]                                         = "Affix size"
L["OPTIONS_FOCUS_FONT_SIZE_AFFIXES_PX"]                               = "Font size for affixes (8–32 px)."
L["OPTIONS_FOCUS_AFFIX_COLOR"]                                        = "Affix color"
L["OPTIONS_FOCUS_TEXT_COLOR_AFFIXES"]                                 = "Text color for affixes."
L["OPTIONS_FOCUS_BOSS_SIZE"]                                          = "Boss size"
L["OPTIONS_FOCUS_FONT_SIZE_BOSS_NAMES_PX"]                            = "Font size for boss names (8–32 px)."
L["OPTIONS_FOCUS_BOSS_COLOR"]                                         = "Boss color"
L["OPTIONS_FOCUS_TEXT_COLOR_BOSS_NAMES"]                              = "Text color for boss names."
L["OPTIONS_FOCUS_RESET_MYTHIC_TYPOGRAPHY"]                            = "Reset Mythic+ typography"

-- =====================================================================
-- OptionsData.lua Appearance
-- =====================================================================
L["OPTIONS_FOCUS_FRAME"]                                              = "Frame"
L["OPTIONS_FOCUS_CLASS_COLOURS_DASHBOARD"]                            = "Class colours - Dashboard"
L["OPTIONS_FOCUS_CLASS_COLOURS"]                                      = "Class Colours"
L["OPTIONS_FOCUS_ENABLE_CLASS_COLOURS"]                               = "Enable all class colours"
L["OPTIONS_FOCUS_TOGGLE_CLASS_COLOURS_MODULES"]                       = "Toggle class colours on or off for all modules at once."
L["OPTIONS_FOCUS_DASHBOARD"]                                          = "Dashboard"
L["OPTIONS_FOCUS_TINT_FOCUS_HEADER_TITLE_CATEGORY_SECTION"]           = "Tint Focus header title, category section headers, main and between-section dividers, and super-tracked highlight bars and borders with your class colour."
L["OPTIONS_FOCUS_TINT_PRESENCE_TOAST_TITLE_DIVIDER_YOUR"]             = "Tint Presence toast title and divider with your class colour."
L["OPTIONS_FOCUS_TINT_VISTA_MINIMAP_ADDON_BAR_PANEL"]                 = "Tint Vista minimap, addon-bar, and panel borders and text with your class colour."
L["OPTIONS_FOCUS_CLASS_COLOUR_PLAYER_TOOLTIP_NAME_CLASS"]             = "Use class colour for player tooltip name, class line, and border."
L["OPTIONS_FOCUS_TINT_CACHE_LOOT_ICON_GLOW_EDIT"]                     = "Tint Cache loot icon glow and edit/anchor borders with your class colour."
L["OPTIONS_FOCUS_TINT_CHARACTER_NAME_ESSENCE_SHEET_YO"]               = "Tint the character name on the Essence sheet with your class colour."
L["OPTIONS_FOCUS_CLASS_COLORS"]                                       = "Class colors"
L["OPTIONS_FOCUS_TINT_DASHBOARD_ACCENTS_DIVIDERS_HIGHLIGHTS"]         = "Tint dashboard accents, dividers, and highlights with your class colour."
L["OPTIONS_FOCUS_THEME"]                                              = "Theme"
L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND"]                               = "Dashboard background"
L["OPTIONS_FOCUS_BACKGROUND_STYLE_MODULE_DASHBOARD_WINDOW_AXI"]       = "Background style for the module dashboard window (Axis). Default is flat; Midnight uses bundled artwork; Specialisation (auto) uses the in-game talent UI background for your current specialization."
L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_MIDNIGHT"]                      = "Midnight"
L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_CLASS_TALENTS"]                 = "Specialisation (auto)"
L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_OPACITY"]                       = "Dashboard background opacity"
L["OPTIONS_FOCUS_ADJUST_OPACITY_OF_DASHBOARD_BACKGROUND"]             = "Adjust the opacity of the dashboard background (50–100%). Lower values let more of the game world show through."
L["DASHBOARD_TYPO_SECTION"]                                           = "Dashboard text"
L["DASHBOARD_TYPO_FONT"]                                              = "Dashboard font"
L["DASHBOARD_TYPO_FONT_DESC"]                                         = "Font for the Axis settings window (sidebar, search, and option rows). Separate from the Focus tracker font. For CJK or mixed-script welcome text, pick a broad-coverage font (e.g. 2002) if needed."
L["DASHBOARD_TYPO_SIZE"]                                              = "Dashboard text size"
L["DASHBOARD_TYPO_SIZE_DESC"]                                         = "Nudge all dashboard text larger or smaller (−4 to +4), similar to Focus global font offset."
L["OPTIONS_FOCUS_BACKDROP_OPACITY"]                                   = "Backdrop opacity"
L["OPTIONS_FOCUS_PANEL_BACKGROUND_OPACITY"]                           = "Panel background opacity (0–1)."
L["OPTIONS_FOCUS_BORDER"]                                             = "Show border"
L["OPTIONS_FOCUS_BORDER_AROUND_TRACKER"]                              = "Show border around the tracker."
L["OPTIONS_FOCUS_SCROLL_INDICATOR"]                                   = "Show scroll indicator"
L["OPTIONS_FOCUS_A_VISUAL_HINT_LIST_CONTENT_TH"]                      = "Show a visual hint when the list has more content than is visible."
L["OPTIONS_FOCUS_SCROLL_INDICATOR_STYLE"]                             = "Scroll indicator style"
L["OPTIONS_FOCUS_CHOOSE_BETWEEN_A_FADE_GRADIENT_A"]                   = "Choose between a fade-out gradient or a small arrow to indicate scrollable content."
L["OPTIONS_FOCUS_ARROW"]                                              = "Arrow"
L["OPTIONS_FOCUS_HIGHLIGHT_ALPHA"]                                    = "Highlight alpha"
L["OPTIONS_FOCUS_OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]                 = "Opacity of focused quest highlight (0–1)."
L["OPTIONS_FOCUS_BAR_WIDTH"]                                          = "Bar width"
L["OPTIONS_FOCUS_WIDTH_OF_BAR_STYLE_HIGHLIGHTS_PX"]                   = "Width of bar-style highlights (2–6 px)."

-- =====================================================================
-- OptionsData.lua Organization
-- =====================================================================
L["OPTIONS_FOCUS_ACTIVITY"]                                           = "Activity"
L["OPTIONS_FOCUS_CONTENT"]                                            = "Content"
L["OPTIONS_FOCUS_SORTING"]                                            = "Sorting"
L["OPTIONS_FOCUS_ELEMENTS"]                                           = "Elements"
L["OPTIONS_FOCUS_CATEGORY_ORDER"]                                     = "Category order"
L["OPTIONS_FOCUS_CATEGORY_COLOR_BAR"]                                 = "Category color for bar"
L["OPTIONS_FOCUS_CHECKMARK_COMPLETED"]                                = "Checkmark for completed"
L["OPTIONS_FOCUS_CURRENT_QUEST_CATEGORY"]                             = "Current Quest category"
L["OPTIONS_FOCUS_CURRENT_QUEST_WINDOW"]                               = "Current Quest window"
L["OPTIONS_FOCUS_QUESTS_RECENT_PROGRESS_TOP"]                         = "Show quests with recent progress at the top."
L["OPTIONS_FOCUS_SECONDS_OF_RECENT_PROGRESS_CURRENT_QUEST"]           = "Seconds of recent progress to show in Current Quest (30–120)."
L["OPTIONS_FOCUS_QUESTS_YOU_MADE_PROGRESS_LAST_MINUTE"]               = "Quests you made progress on in the last minute appear in a dedicated section."
L["OPTIONS_FOCUS_CATEGORY_ORDER"]                                     = "Focus category order"
L["OPTIONS_FOCUS_DRAG_REORDER_CATEGORIES_DELVES_SCENARIO_EVENT"]      = "Drag to reorder categories. DELVES and SCENARIO EVENTS stay first."
L["OPTIONS_FOCUS_DRAG_REORDER_DELVES_SCENARIOS_STAY_FIRST"]           = "Drag to reorder. Delves and Scenarios stay first."
L["OPTIONS_FOCUS_SORT_MODE"]                                          = "Focus sort mode"
L["OPTIONS_FOCUS_ORDER_OF_ENTRIES_WITHIN_CATEGORY"]                   = "Order of entries within each category."
L["OPTIONS_FOCUS_AUTO_TRACK_ACCEPTED_QUESTS"]                         = "Auto-track accepted quests"
L["OPTIONS_FOCUS_YOU_ACCEPT_A_QUEST_QUEST_LOG"]                       = "When you accept a quest (quest log only, not world quests), add it to the tracker automatically."
L["OPTIONS_FOCUS_REQUIRE_CTRL_FOCUS_REMOVE"]                          = "Require Ctrl for focus & remove"
L["OPTIONS_FOCUS_REQUIRE_CTRL_FOCUS_ADD_LEFT_UNFOCUS"]                = "Require Ctrl for focus/add (Left) and unfocus/untrack (Right) to prevent misclicks."
L["OPTIONS_FOCUS_CTRL_FOCUS_UNTRACK"]                                 = "Ctrl for focus / untrack"
L["OPTIONS_FOCUS_CTRL_CLICK_COMPLETE"]                                = "Ctrl to click-complete"
L["OPTIONS_FOCUS_CLASSIC_CLICK_BEHAVIOUR"]                            = "Use classic click behaviour"
L["OPTIONS_FOCUS_CLASSIC_CLICKS"]                                     = "Classic clicks"
-- === Focus Click Profiles ===
L["OPTIONS_FOCUS_CLICK_PROFILE"]                                      = "Click profile"
L["OPTIONS_FOCUS_CLICK_PROFILE_DESC"]                                 = "Pick a preset or Custom. Presets show each shortcut below (locked); choose Custom to change them."
L["OPTIONS_FOCUS_PROFILE_HORIZON_PLUS"]                               = "Horizon+"
L["OPTIONS_FOCUS_PROFILE_BLIZZARD_DEFAULT"]                           = "Blizzard+"
L["OPTIONS_FOCUS_PROFILE_CUSTOM"]                                     = "Custom"
L["OPTIONS_FOCUS_COMING_SOON"]                                        = "Coming soon"
L["OPTIONS_FOCUS_CLICK_COMBOS"]                                       = "Custom bindings"
L["OPTIONS_FOCUS_CLICK_COMBO_LOCKED_TOOLTIP"]                         = "Fixed for this profile. Select Custom to edit shortcuts."
L["OPTIONS_FOCUS_CLICK_SAFETY"]                                       = "Safety"
L["OPTIONS_FOCUS_COMBO_LEFT"]                                         = "Left click"
L["OPTIONS_FOCUS_COMBO_SHIFT_LEFT"]                                   = "Shift + Left click"
L["OPTIONS_FOCUS_COMBO_CTRL_LEFT"]                                    = "Ctrl + Left click"
L["OPTIONS_FOCUS_COMBO_ALT_LEFT"]                                     = "Alt + Left click"
L["OPTIONS_FOCUS_COMBO_RIGHT"]                                        = "Right click"
L["OPTIONS_FOCUS_COMBO_SHIFT_RIGHT"]                                  = "Shift + Right click"
L["OPTIONS_FOCUS_COMBO_CTRL_RIGHT"]                                   = "Ctrl + Right click"
L["OPTIONS_FOCUS_CLICK_ACTION_NONE"]                                  = "Do nothing"
L["OPTIONS_FOCUS_CLICK_ACTION_SUPER_TRACK"]                           = "Focus quest"
L["OPTIONS_FOCUS_CLICK_ACTION_OPEN_QUEST_LOG"]                        = "Open quest log"
L["OPTIONS_FOCUS_CLICK_ACTION_UNTRACK"]                               = "Untrack"
L["OPTIONS_FOCUS_CLICK_ACTION_CONTEXT_MENU"]                          = "Context menu"
L["OPTIONS_FOCUS_CLICK_ACTION_SHARE"]                                 = "Share with party"
L["OPTIONS_FOCUS_CLICK_ACTION_ABANDON"]                               = "Abandon quest"
L["OPTIONS_FOCUS_CLICK_ACTION_WOWHEAD"]                               = "WoWhead URL"
L["OPTIONS_FOCUS_CLICK_ACTION_CHAT_LINK"]                             = "Link in chat"
L["OPTIONS_FOCUS_APPEARANCE_CANNOT_SHARE"]                            = "Appearances cannot be shared like quests."
L["OPTIONS_FOCUS_QUEST_DETAILS_AFTER_COMBAT"]                         = "Quest details will open when you leave combat."
L["OPTIONS_FOCUS_SHARE_PARTY"]                                        = "Share with party"
L["OPTIONS_FOCUS_ABANDON_QUEST"]                                      = "Abandon quest"
L["OPTIONS_FOCUS_STOP_TRACKING"]                                      = "Stop tracking"
L["OPTIONS_FOCUS_QUEST_CANNOT_SHARED"]                                = "This quest cannot be shared."
L["OPTIONS_FOCUS_YOU_MUST_A_PARTY_SHARE_QUEST"]                       = "You must be in a party to share this quest."
L["OPTIONS_FOCUS_LEFT_CLICK_OPENS_QUEST_MAP_RIGHT"]                   = "When on, left-click opens the quest map and right-click shows share/abandon menu (Blizzard-style). When off, left-click focuses and right-click untracks; Ctrl+Right shares with party."
L["OPTIONS_FOCUS_ANIMATIONS"]                                         = "Animations"
L["OPTIONS_FOCUS_ENABLE_SLIDE_FADE_QUESTS"]                           = "Enable slide and fade for quests."
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_FLASH"]                           = "Objective progress flash"
L["OPTIONS_FOCUS_FLASH_AN_OBJECTIVE_COMPLETES"]                       = "Show flash when an objective completes."
L["OPTIONS_FOCUS_FLASH_INTENSITY"]                                    = "Flash intensity"
L["OPTIONS_FOCUS_NOTICEABLE_OBJECTIVE_COMPLETE_FLASH"]                = "How noticeable the objective-complete flash is."
L["OPTIONS_FOCUS_FLASH_COLOR"]                                        = "Flash color"
L["OPTIONS_FOCUS_COLOR_OF_OBJECTIVE_COMPLETE_FLASH"]                  = "Color of the objective-complete flash."
L["OPTIONS_FOCUS_SUBTLE"]                                             = "Subtle"
L["OPTIONS_FOCUS_MEDIUM"]                                             = "Medium"
L["OPTIONS_FOCUS_STRONG"]                                             = "Strong"
L["OPTIONS_FOCUS_REQUIRE_CTRL_CLICK_COMPLETE"]                        = "Require Ctrl for click to complete"
L["OPTIONS_FOCUS_REQUIRES_CTRL_LEFT_CLICK_COMPLETE_AUTO"]             = "When on, requires Ctrl+Left-click to complete auto-complete quests. When off, plain Left-click completes them (Blizzard default). Only affects quests that can be completed by click (no NPC turn-in needed)."
L["OPTIONS_FOCUS_SUPPRESS_UNTRACKED_UNTIL_RELOAD"]                    = "Suppress untracked until reload"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS_Z"]                 = "When on, right-click untrack on world quests and in-zone weeklies/dailies hides them until you reload or start a new session. When off, they reappear when you return to the zone."
L["OPTIONS_FOCUS_PERMANENTLY_SUPPRESS_UNTRACKED_QUESTS"]              = "Permanently suppress untracked quests"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACKED_WORLD_QUESTS_ZO"]              = "When on, right-click untracked world quests and in-zone weeklies/dailies are hidden permanently (persists across reloads). Takes priority over 'Suppress until reload'. Accepting a suppressed quest removes it from the blacklist."
L["OPTIONS_FOCUS_KEEP_CAMPAIGN_QUESTS_CATEGORY"]                      = "Keep campaign quests in category"
L["OPTIONS_FOCUS_CAMPAIGN_QUESTS_READY_TURN_RE"]                      = "When on, campaign quests that are ready to turn in remain in the Campaign category instead of moving to Complete."
L["OPTIONS_FOCUS_KEEP_IMPORTANT_QUESTS_CATEGORY"]                     = "Keep important quests in category"
L["OPTIONS_FOCUS_IMPORTANT_QUESTS_READY_TURN_R"]                      = "When on, important quests that are ready to turn in remain in the Important category instead of moving to Complete."
L["OPTIONS_FOCUS_TOMTOM_QUEST_WAYPOINT"]                              = "TomTom quest & appearance waypoint"
L["OPTIONS_FOCUS_A_TOMTOM_WAYPOINT_FOCUSING_A_QUEST"]                 = "Set a TomTom waypoint when focusing a quest or a tracked transmog appearance."
L["OPTIONS_FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_NEXT_QUEST"]            = "Requires TomTom. Points the arrow to the next quest objective or the next step for a focused appearance."
L["OPTIONS_FOCUS_TOMTOM_RARE_WAYPOINT"]                               = "TomTom rare waypoint"
L["OPTIONS_FOCUS_A_TOMTOM_WAYPOINT_CLICKING_A_RARE"]                  = "Set a TomTom waypoint when clicking a rare boss."
L["OPTIONS_FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_RARE_S"]                = "Requires TomTom. Points the arrow to the rare's location."
L["OPTIONS_FOCUS_FIND_A_GROUP"]                                       = "Find a Group"
L["OPTIONS_FOCUS_CLICK_SEARCH_A_GROUP_QUEST"]                         = "Click to search for a group for this quest."

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
L["OPTIONS_FOCUS_BLACKLIST"]                                          = "Blacklist"
L["OPTIONS_FOCUS_BLACKLIST_UNTRACKED"]                                = "Blacklist untracked"
L["OPTIONS_FOCUS_ENABLE_BLACKLIST_UNTRACKED_BEHAVIOUR_ADD_QUEST"]     = "Enable 'Blacklist untracked' in Behaviour to add quests here."
L["OPTIONS_FOCUS_HIDDEN_QUESTS"]                                      = "Hidden Quests"
L["OPTIONS_FOCUS_QUESTS_HIDDEN_RIGHT_CLICK_UNTRACK"]                  = "Quests hidden via right-click untrack."
L["OPTIONS_FOCUS_BLACKLISTED_QUESTS"]                                 = "Blacklisted quests"
L["OPTIONS_FOCUS_PERMANENTLY_SUPPRESSED_QUESTS"]                      = "Permanently suppressed quests"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACK_QUESTS_PERMANENTLY_SUPPRESS"]    = "Right-click untrack quests with 'Permanently suppress untracked quests' enabled to add them here."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["OPTIONS_PRESENCE_QUEST_TYPE_ICONS"]                                = "Show quest type icons"
L["OPTIONS_PRESENCE_QUEST_TYPE_ICON_FOCUS_TRACKER_QUEST"]             = "Show quest type icon in the Focus tracker (quest accept/complete, world quest, quest update)."
L["OPTIONS_PRESENCE_QUEST_TYPE_ICONS_TOASTS"]                         = "Show quest type icons on toasts"
L["OPTIONS_PRESENCE_QUEST_TYPE_ICON_PRESENCE_TOASTS_QUEST"]           = "Show quest type icon on Presence toasts (quest accept/complete, world quest, quest update)."
L["OPTIONS_PRESENCE_TOAST_ICON_SIZE"]                                 = "Toast icon size"
L["OPTIONS_PRESENCE_QUEST_ICON_SIZE_PRESENCE_TOASTS_PX"]              = "Quest icon size on Presence toasts (16–36 px). Default 24."
L["OPTIONS_PRESENCE_HIDE_QUEST_UPDATE_TITLE"]                         = "Hide quest update title"
L["OPTIONS_PRESENCE_OBJECTIVE_LINE_QUEST_PROGRESS_TOAST"]             = "Show only the objective line on quest progress toasts (e.g. 7/10 Boar Pelts), without the quest name or header."
L["OPTIONS_PRESENCE_SHOW_DISCOVERY_LINE"]                             = "Show discovery line"
L["OPTIONS_PRESENCE_DISCOVERY_LINE"]                                  = "Discovery line"
L["OPTIONS_PRESENCE_DISCOVERED_UNDER_ZONE_SUBZONE_ENTERING_A"]        = "Show 'Discovered' under zone/subzone when entering a new area."
L["OPTIONS_PRESENCE_FRAME_VERTICAL_POSITION"]                         = "Frame vertical position"
L["OPTIONS_PRESENCE_VERTICAL_OFFSET_OF_PRESENCE_FRAME_CENTER"]        = "Vertical offset of the Presence frame from center (-300 to 0)."
L["OPTIONS_PRESENCE_FRAME_SCALE"]                                     = "Frame scale"
L["OPTIONS_PRESENCE_SCALE_OF_PRESENCE_FRAME"]                         = "Scale of the Presence frame (0.5–2)."
L["OPTIONS_PRESENCE_BOSS_EMOTE_COLOR"]                                = "Boss emote color"
L["OPTIONS_PRESENCE_COLOR_OF_RAID_DUNGEON_BOSS_EMOTE"]                = "Color of raid and dungeon boss emote text."
L["OPTIONS_PRESENCE_DISCOVERY_LINE_COLOR"]                            = "Discovery line color"
L["OPTIONS_PRESENCE_COLOR_OF_DISCOVERED_LINE_UNDER_ZONE"]             = "Color of the 'Discovered' line under zone text."
L["OPTIONS_PRESENCE_NOTIFICATION_TYPES"]                              = "Notification types"
L["OPTIONS_PRESENCE_NOTIFICATIONS"]                                   = "Notifications"
L["OPTIONS_PRESENCE_NOTIFICATION_ACHIEVEMENT_CRITERIA_UPDATE_T"]      = "Show notification when achievement criteria update (tracked achievements always; others when Blizzard provides the achievement ID)."
L["OPTIONS_PRESENCE_ZONE_ENTRY"]                                      = "Show zone entry"
L["OPTIONS_PRESENCE_ZONE_CHANGE_ENTERING_A_AREA"]                     = "Show zone change when entering a new area."
L["OPTIONS_PRESENCE_SUBZONE_CHANGES"]                                 = "Show subzone changes"
L["OPTIONS_PRESENCE_SUBZONE_CHANGE_MOVING_WITHIN_SAME_ZONE"]          = "Show subzone change when moving within the same zone."
L["OPTIONS_PRESENCE_HIDE_ZONE_NAME_SUBZONE_CHANGES"]                  = "Hide zone name for subzone changes"
L["OPTIONS_PRESENCE_MOVING_BETWEEN_SUBZONES_WITHIN_SAME_ZONE"]        = "When moving between subzones within the same zone, only show the subzone name. The zone name still appears when entering a new zone."
L["OPTIONS_PRESENCE_SUPPRESS_DELVE"]                                  = "Suppress in Delve"
L["OPTIONS_PRESENCE_SUPPRESS_SCENARIO_PROGRESS_NOTIFICATIONS_DELVES"]   = "Suppress scenario progress notifications in Delves."
L["OPTIONS_PRESENCE_HIDES_OBJECTIVE_UPDATE_POPUPS_WHILE_A"]           = "When on, hides objective update popups while in a Delve. Zone entry and completion toasts still show."
L["OPTIONS_PRESENCE_SUPPRESS_ZONE_CHANGES_MYTHIC"]                    = "Suppress zone changes in Mythic+"
L["OPTIONS_PRESENCE_MYTHIC_BOSS_EMOTES_ACHIEVEMENTS_LEV"]             = "In Mythic+, only show boss emotes, achievements, and level-up. Hide zone, quest, and scenario notifications."
L["OPTIONS_PRESENCE_LEVEL"]                                           = "Show level up"
L["OPTIONS_PRESENCE_LEVEL_NOTIFICATION"]                              = "Show level-up notification."
L["OPTIONS_PRESENCE_BOSS_EMOTES"]                                     = "Show boss emotes"
L["OPTIONS_PRESENCE_RAID_DUNGEON_BOSS_EMOTE_NOTIFICATIONS"]           = "Show raid and dungeon boss emote notifications."
L["OPTIONS_PRESENCE_ACHIEVEMENTS"]                                    = "Show achievements"
L["OPTIONS_PRESENCE_ACHIEVEMENT_EARNED_NOTIFICATIONS"]                = "Show achievement earned notifications."
L["OPTIONS_PRESENCE_ACHIEVEMENT_PROGRESS"]                            = "Achievement progress"
L["OPTIONS_PRESENCE_ACHIEVEMENT_EARNED"]                              = "Achievement earned"
L["OPTIONS_PRESENCE_QUEST_ACCEPTED"]                                  = "Quest accepted"
L["OPTIONS_PRESENCE_WORLD_QUEST_ACCEPTED"]                            = "World quest accepted"
L["OPTIONS_PRESENCE_SCENARIO_COMPLETE"]                               = "Scenario complete"
L["OPTIONS_PRESENCE_RARE_DEFEATED"]                                   = "Rare defeated"
L["OPTIONS_PRESENCE_NOTIFICATION_TRACKED_ACHIEVEMENT_CRITERIA"]       = "Show notification when tracked achievement criteria update."
L["OPTIONS_PRESENCE_QUEST_ACCEPT"]                                    = "Show quest accept"
L["OPTIONS_PRESENCE_NOTIFICATION_ACCEPTING_A_QUEST"]                  = "Show notification when accepting a quest."
L["OPTIONS_PRESENCE_WORLD_QUEST_ACCEPT"]                              = "Show world quest accept"
L["OPTIONS_PRESENCE_NOTIFICATION_ACCEPTING_A_WORLD_QUEST"]            = "Show notification when accepting a world quest."
L["OPTIONS_PRESENCE_QUEST_COMPLETE"]                                  = "Show quest complete"
L["OPTIONS_PRESENCE_NOTIFICATION_COMPLETING_A_QUEST"]                 = "Show notification when completing a quest."
L["OPTIONS_PRESENCE_WORLD_QUEST_COMPLETE"]                            = "Show world quest complete"
L["OPTIONS_PRESENCE_NOTIFICATION_COMPLETING_A_WORLD_QUEST"]           = "Show notification when completing a world quest."
L["OPTIONS_PRESENCE_QUEST_PROGRESS"]                                  = "Show quest progress"
L["OPTIONS_PRESENCE_NOTIFICATION_QUEST_OBJECTIVES_UPDATE"]            = "Show notification when quest objectives update."
L["OPTIONS_PRESENCE_OBJECTIVE"]                                       = "Objective only"
L["OPTIONS_PRESENCE_QUEST_PROGRESS_HIDE_TITLE"]                       = "Show only the objective line on quest progress toasts, hiding the 'Quest Update' title."
L["OPTIONS_PRESENCE_SCENARIO_START"]                                  = "Show scenario start"
L["OPTIONS_PRESENCE_NOTIFICATION_ENTERING_A_SCENARIO_DELVE"]          = "Show notification when entering a scenario or Delve."
L["OPTIONS_PRESENCE_SCENARIO_PROGRESS"]                               = "Show scenario progress"
L["OPTIONS_PRESENCE_NOTIFICATION_SCENARIO_DELVE_OBJECTIVES"]          = "Show notification when scenario or Delve objectives update."
L["OPTIONS_PRESENCE_ANIMATION"]                                       = "Animation"
L["OPTIONS_PRESENCE_ENABLE_ANIMATIONS"]                               = "Enable animations"
L["OPTIONS_PRESENCE_ENABLE_ENTRANCE_EXIT_ANIMATIONS_PRESENCE"]        = "Enable entrance and exit animations for Presence notifications."
L["OPTIONS_PRESENCE_ENTRANCE_DURATION"]                               = "Entrance duration"
L["OPTIONS_PRESENCE_DURATION_OF_ENTRANCE_ANIMATION_SECONDS"]          = "Duration of the entrance animation in seconds (0.2–1.5)."
L["OPTIONS_PRESENCE_EXIT_DURATION"]                                   = "Exit duration"
L["OPTIONS_PRESENCE_DURATION_OF_EXIT_ANIMATION_SECONDS"]              = "Duration of the exit animation in seconds (0.2–1.5)."
L["OPTIONS_PRESENCE_HOLD_DURATION_SCALE"]                             = "Hold duration scale"
L["OPTIONS_PRESENCE_MULTIPLIER_LONG_NOTIFICATION_STAYS_S"]            = "Multiplier for how long each notification stays on screen (0.5–2)."
L["OPTIONS_PRESENCE_PREVIEW"]                                         = "Preview"
L["OPTIONS_PRESENCE_PREVIEW_TOAST_TYPE"]                              = "Preview toast type"
L["OPTIONS_PRESENCE_SELECT_A_TOAST_TYPE_PREVIEW"]                     = "Select a toast type to preview."
L["OPTIONS_PRESENCE_SELECTED_TOAST_TYPE"]                             = "Show the selected toast type."
L["OPTIONS_PRESENCE_PREVIEW_PRESENCE_TOAST_LAYOUTS_LIVE_OPEN"]        = "Preview Presence toast layouts live and open a detachable sample while adjusting other settings."
L["OPTIONS_PRESENCE_OPEN_DETACHED_PREVIEW"]                           = "Open detached preview"
L["OPTIONS_PRESENCE_OPEN_A_MOVABLE_PREVIEW_WINDOW_STAYS"]             = "Open a movable preview window that stays visible while you change other Presence settings."
L["OPTIONS_PRESENCE_ANIMATE_PREVIEW"]                                 = "Animate preview"
L["OPTIONS_PRESENCE_PLAY_SELECTED_TOAST_ANIMATION_INSIDE_PREVIE"]     = "Play the selected toast animation inside this preview window."
L["OPTIONS_PRESENCE_DETACHED_PREVIEW"]                                = "Detached preview"
L["OPTIONS_PRESENCE_KEEP_OPEN_WHILE_ADJUSTING_TYPOGRAPHY_COLORS"]     = "Keep this open while adjusting Typography or Colors."
L["DASH_TYPOGRAPHY"]                                                  = "Typography"
L["OPTIONS_PRESENCE_MAIN_TITLE_FONT"]                                 = "Main title font"
L["OPTIONS_PRESENCE_FONT_FAMILY_MAIN_TITLE"]                          = "Font family for the main title."
L["OPTIONS_PRESENCE_SUBTITLE_FONT"]                                   = "Subtitle font"
L["OPTIONS_PRESENCE_FONT_FAMILY_SUBTITLE"]                            = "Font family for the subtitle."
L["OPTIONS_PRESENCE_RESET_TYPOGRAPHY_DEFAULTS"]                       = "Reset typography to defaults"
L["OPTIONS_PRESENCE_RESET_PRESENCE_TYPOGRAPHY_OPTIONS_FONTS_SIZES"]   = "Reset all Presence typography options (fonts, sizes, colors) to defaults."
L["OPTIONS_PRESENCE_LARGE_NOTIFICATIONS"]                             = "Large notifications"
L["OPTIONS_PRESENCE_MEDIUM_NOTIFICATIONS"]                            = "Medium notifications"
L["OPTIONS_PRESENCE_SMALL_NOTIFICATIONS"]                             = "Small notifications"
L["OPTIONS_PRESENCE_LARGE_PRIMARY_SIZE"]                              = "Large primary size"
L["OPTIONS_PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_TITLES_ZONE"]        = "Font size for large notification titles (zone, quest complete, achievement, etc.)."
L["OPTIONS_PRESENCE_LARGE_SECONDARY_SIZE"]                            = "Large secondary size"
L["OPTIONS_PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_SUBTITLES"]          = "Font size for large notification subtitles."
L["OPTIONS_PRESENCE_MEDIUM_PRIMARY_SIZE"]                             = "Medium primary size"
L["OPTIONS_PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_TITLES_QUEST"]      = "Font size for medium notification titles (quest accept, subzone, scenario)."
L["OPTIONS_PRESENCE_MEDIUM_SECONDARY_SIZE"]                           = "Medium secondary size"
L["OPTIONS_PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_SUBTITLES"]         = "Font size for medium notification subtitles."
L["OPTIONS_PRESENCE_SMALL_PRIMARY_SIZE"]                              = "Small primary size"
L["OPTIONS_PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_TITLES_QUEST"]       = "Font size for small notification titles (quest progress, achievement progress)."
L["OPTIONS_PRESENCE_SMALL_SECONDARY_SIZE"]                            = "Small secondary size"
L["OPTIONS_PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_SUBTITLES"]          = "Font size for small notification subtitles."

-- =====================================================================
-- OptionsData.lua Dropdown options — Outline
-- =====================================================================
L["OPTIONS_FOCUS_NONE"]                                               = "None"
L["OPTIONS_FOCUS_THICK_OUTLINE"]                                      = "Thick Outline"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["OPTIONS_FOCUS_BAR_LEFT_EDGE"]                                      = "Bar (left edge)"
L["OPTIONS_FOCUS_BAR_RIGHT_EDGE"]                                     = "Bar (right edge)"
L["OPTIONS_FOCUS_BAR_TOP_EDGE"]                                       = "Bar (top edge)"
L["OPTIONS_FOCUS_BAR_BOTTOM_EDGE"]                                    = "Bar (bottom edge)"
L["OPTIONS_FOCUS_OUTLINE_ONLY_STYLE"]                                 = "Outline only"
L["OPTIONS_FOCUS_SOFT_GLOW"]                                          = "Soft glow"
L["OPTIONS_FOCUS_DUAL_EDGE_BARS"]                                     = "Dual edge bars"
L["OPTIONS_FOCUS_PILL_LEFT_ACCENT"]                                   = "Pill left accent"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["OPTIONS_FOCUS_TOP"]                                                = "Top"
L["OPTIONS_FOCUS_BOTTOM"]                                             = "Bottom"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["OPTIONS_VISTA_LOCATION_POSITION"]                                  = "Location position"
L["OPTIONS_VISTA_PLACE_ZONE_NAME_ABOVE_BELOW_MINIMAP"]                = "Place the zone name above or below the minimap."
L["OPTIONS_VISTA_COORDINATES_POSITION"]                               = "Coordinates position"
L["OPTIONS_VISTA_PLACE_COORDINATES_ABOVE_BELOW_MINIMAP"]              = "Place the coordinates above or below the minimap."
L["OPTIONS_VISTA_CLOCK_POSITION"]                                     = "Clock position"
L["OPTIONS_VISTA_PLACE_CLOCK_ABOVE_BELOW_MINIMAP"]                    = "Place the clock above or below the minimap."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["OPTIONS_FOCUS_LOWER_CASE"]                                         = "Lower Case"
L["OPTIONS_FOCUS_UPPER_CASE"]                                         = "Upper Case"
L["OPTIONS_FOCUS_PROPER"]                                             = "Proper"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["OPTIONS_FOCUS_TRACKED_LOG"]                                        = "Tracked / in log"
L["OPTIONS_FOCUS_LOG_MAX_SLOTS"]                                      = "In log / max slots"

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["OPTIONS_FOCUS_ALPHABETICAL"]                                       = "Alphabetical"
L["OPTIONS_FOCUS_QUEST_TYPE"]                                         = "Quest Type"
L["OPTIONS_FOCUS_QUEST_LEVEL"]                                        = "Quest Level"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["OPTIONS_FOCUS_CUSTOM"]                                             = "Custom"
L["OPTIONS_FOCUS_ORDER"]                                              = "Order"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["UI_DUNGEON"]                                                       = "DUNGEON"
L["UI_RAID"]                                                          = "RAID"
L["UI_DELVES"]                                                        = "Delves"
L["UI_SCENARIO_EVENTS"]                                               = "SCENARIO EVENTS"
L["UI_STAGE"]                                                         = "Stage"
L["UI_STAGE_X_X"]                                                     = "Stage %d: %s"
L["UI_AVAILABLE_IN_ZONE"]                                             = "AVAILABLE IN ZONE"
L["UI_EVENTS_IN_ZONE"]                                                = "Events in Zone"
L["UI_CURRENT_EVENT"]                                                 = "Current Event"
L["UI_CURRENT_QUEST"]                                                 = "CURRENT QUEST"
L["UI_CURRENT_ZONE"]                                                  = "CURRENT ZONE"
L["UI_CAMPAIGN"]                                                      = "CAMPAIGN"
L["UI_IMPORTANT"]                                                     = "IMPORTANT"
L["UI_LEGENDARY"]                                                     = "LEGENDARY"
L["UI_WORLD_QUESTS"]                                                  = "World quests"
L["UI_WEEKLY_QUESTS"]                                                 = "WEEKLY QUESTS"
L["UI_PREY"]                                                          = "Prey"
L["UI_ABUNDANCE"]                                                     = "Abundance"
L["UI_ABUNDANCE_BAG"]                                                 = "Abundance Bag"
L["UI_ABUNDANCE_HELD"]                                                = "abundance held"
L["UI_DAILY_QUESTS"]                                                  = "DAILY QUESTS"
L["UI_RARE_BOSSES"]                                                   = "Rare bosses"
L["UI_ACHIEVEMENTS"]                                                  = "ACHIEVEMENTS"
L["UI_ENDEAVORS"]                                                     = "ENDEAVORS"
L["UI_DECOR"]                                                         = "Decor"
L["UI_RECIPES"]                                                       = "Recipes"
L["UI_ADVENTURE_GUIDE"]                                               = "Adventure Guide"
L["UI_APPEARANCES"]                                                   = "Appearances"
L["UI_QUESTS"]                                                        = "QUESTS"
L["UI_READY_TO_TURN_IN"]                                              = "READY TO TURN IN"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["PRESENCE_OBJECTIVES"]                                              = "OBJECTIVES"
L["PRESENCE_OPTIONS"]                                                 = "Options"
L["PRESENCE_OPEN_HORIZON_SUITE"]                                      = "Open Horizon Suite"
L["PRESENCE_OPEN_FULL_HORIZON_SUITE_OPTIONS"]                         = "Open the full Horizon Suite options panel to configure Focus, Presence, Vista, and other modules."
L["PRESENCE_SHOW_MINIMAP_ICON"]                                       = "Show minimap icon"
L["PRESENCE_A_CLICKABLE_ICON_MINIMAP_OPENS"]                          = "Show a clickable icon on the minimap that opens the options panel."
L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER"]                 = "Fade until minimap hover"
L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER_DESC"]            = "When on, the icon stays faded until you move the cursor over the minimap. When off, it stays fully visible."
L["PRESENCE_LOCK_MINIMAP_BUTTON_POSITION"]                            = "Lock minimap button position"
L["PRESENCE_PREVENT_DRAGGING_HORIZON_MINIMAP_BUTTON"]                 = "Prevent dragging the Horizon minimap button."
L["PRESENCE_RESET_MINIMAP_BUTTON_POSITION"]                           = "Reset minimap button position"
L["PRESENCE_RESET_MINIMAP_BUTTON_DEFAULT_POSITION"]                   = "Reset the minimap button to the default position (bottom-left)."
L["PRESENCE_DRAG_TO_MOVE_WHEN_UNLOCKED"]                              = "Drag to move (when unlocked)."
L["PRESENCE_LOCKED"]                                                  = "Locked"
L["PRESENCE_DISCOVERED"]                                              = "Discovered"
L["PRESENCE_REFRESH"]                                                 = "Refresh"
L["PRESENCE_BEST_EFFORT_UNACCEPTED_QUESTS_EXPO"]                      = "Best-effort only. Some unaccepted quests are not exposed until you interact with NPCs or meet phasing conditions."
L["PRESENCE_UNACCEPTED_QUESTS_X_MAP_X"]                               = "Unaccepted Quests - %s (map %s) - %d match(es)"
L["PRESENCE_LEVEL_UP"]                                                = "LEVEL UP"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_80"]                               = "You have reached level 80"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_X"]                                = "You have reached level %s"
L["PRESENCE_ACHIEVEMENT_EARNED"]                                      = "ACHIEVEMENT EARNED"
L["PRESENCE_EXPLORING_THE_MIDNIGHT_ISLES"]                            = "Exploring the Midnight Isles"
L["PRESENCE_EXPLORING_KHAZ_ALGAR"]                                    = "Exploring Khaz Algar"
L["PRESENCE_QUEST_COMPLETE"]                                          = "QUEST COMPLETE"
L["PRESENCE_OBJECTIVE_SECURED"]                                       = "Objective Secured"
L["PRESENCE_AIDING_THE_ACCORD"]                                       = "Aiding the Accord"
L["PRESENCE_WORLD_QUEST"]                                             = "WORLD QUEST"
L["PRESENCE_WORLD_QUEST_COMPLETE"]                                    = "WORLD QUEST COMPLETE"
L["PRESENCE_AZERITE_MINING"]                                          = "Azerite Mining"
L["PRESENCE_WORLD_QUEST_ACCEPTED"]                                    = "WORLD QUEST ACCEPTED"
L["PRESENCE_QUEST_ACCEPTED"]                                          = "QUEST ACCEPTED"
L["PRESENCE_THE_FATE_OF_THE_HORDE"]                                   = "The Fate of the Horde"
L["PRESENCE_NEW_QUEST"]                                               = "New Quest"
L["PRESENCE_QUEST_UPDATE"]                                            = "QUEST UPDATE"
L["PRESENCE_BOAR_PELTS_7_10"]                                         = "Boar Pelts: 7/10"
L["PRESENCE_DRAGON_GLYPHS_3_5"]                                       = "Dragon Glyphs: 3/5"
L["PRESENCE_PRESENCE_TEST_COMMANDS"]                                  = "Presence test commands:"
L["PRESENCE_H_PRESENCE_DEBUGTYPES_DUMP_NOTIFICATION"]                 = "  /h presence debugtypes - Dump notification toggles and Blizzard suppression state"
L["PRESENCE_PRESENCE_PLAYING_DEMO_REEL_NOTIFICATION"]                 = "Presence: Playing demo reel (all notification types)..."
L["PRESENCE_H_PRESENCE_HELP_TEST_CURRENT"]                            = "  /h presence         - Show help + test current zone"
L["PRESENCE_H_PRESENCE_ZONE_TEST_ZONE"]                               = "  /h presence zone     - Test Zone Change"
L["PRESENCE_H_PRESENCE_SUBZONE_TEST_SUBZONE"]                         = "  /h presence subzone  - Test Subzone Change"
L["PRESENCE_H_PRESENCE_DISCOVER_TEST_ZONE"]                           = "  /h presence discover - Test Zone Discovery"
L["PRESENCE_H_PRESENCE_LEVEL_TEST_LEVEL"]                             = "  /h presence level    - Test Level Up"
L["PRESENCE_H_PRESENCE_BOSS_TEST_BOSS"]                               = "  /h presence boss     - Test Boss Emote"
L["PRESENCE_H_PRESENCE_ACH_TEST_ACHIEVEMENT"]                         = "  /h presence ach      - Test Achievement"
L["PRESENCE_H_PRESENCE_ACCEPT_TEST_QUEST"]                            = "  /h presence accept   - Test Quest Accepted"
L["PRESENCE_H_PRESENCE_WQACCEPT_TEST_WORLD"]                          = "  /h presence wqaccept - Test World Quest Accepted"
L["PRESENCE_H_PRESENCE_SCENARIO_TEST_SCENARIO"]                       = "  /h presence scenario - Test Scenario Start"
L["PRESENCE_H_PRESENCE_QUEST_TEST_QUEST"]                             = "  /h presence quest    - Test Quest Complete"
L["PRESENCE_H_PRESENCE_WQ_TEST_WORLD"]                                = "  /h presence wq       - Test World Quest"
L["PRESENCE_H_PRESENCE_UPDATE_TEST_QUEST"]                            = "  /h presence update   - Test Quest Update"
L["PRESENCE_H_PRESENCE_ACHPROGRESS_TEST_ACHIEVEMENT"]                 = "  /h presence achprogress - Test Achievement Progress"
L["PRESENCE_H_PRESENCE_DEMO_REEL_TYPES"]                              = "  /h presence all      - Demo reel (all types)"
L["PRESENCE_H_PRESENCE_DEBUG_DUMP_STATE"]                             = "  /h presence debug    - Dump state to chat"
L["PRESENCE_H_PRESENCE_DEBUGLIVE_TOGGLE_LIVE"]                        = "  /h presence debuglive - Toggle live debug panel (log as events happen)"

-- =====================================================================
-- OptionsData.lua Vista — General
L["OPTIONS_VISTA_POSITION_LAYOUT"]                                    = "Position & layout"

-- =====================================================================
L["OPTIONS_VISTA_MINIMAP"]                                            = "Minimap"
L["OPTIONS_VISTA_MINIMAP_SIZE"]                                       = "Minimap size"
L["OPTIONS_VISTA_WIDTH_HEIGHT_OF_MINIMAP_PIXELS"]                     = "Width and height of the minimap in pixels (100–400)."
L["OPTIONS_VISTA_CIRCULAR_MINIMAP"]                                   = "Circular minimap"
L["OPTIONS_VISTA_CIRCULAR_SHAPE"]                                     = "Circular shape"
L["OPTIONS_VISTA_A_CIRCULAR_MINIMAP_INSTEAD_OF_SQUARE"]               = "Use a circular minimap instead of square."
L["OPTIONS_VISTA_LOCK_MINIMAP_POSITION"]                              = "Lock minimap position"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MINIMAP"]                           = "Prevent dragging the minimap."
L["OPTIONS_VISTA_RESET_MINIMAP_POSITION"]                             = "Reset minimap position"
L["OPTIONS_VISTA_RESET_MINIMAP_DEFAULT_POSITION_TOP_RIGHT"]           = "Reset minimap to its default position (top-right)."
L["OPTIONS_VISTA_RESET_OVERLAY_POSITIONS"]                            = "Reset overlay positions to defaults"
L["OPTIONS_VISTA_RESET_OVERLAY_POSITIONS_DESC"]                       = "Clear saved positions for zone text, coordinates, clock, performance and difficulty text, tracking, calendar, queue, mail, the addon button bar, drawer button, and right-click panel. The minimap frame position is not changed."
L["OPTIONS_VISTA_AUTO_ZOOM"]                                          = "Auto Zoom"
L["OPTIONS_VISTA_AUTO_ZOOM_DELAY"]                                    = "Auto zoom-out delay"
L["OPTIONS_VISTA_SECONDS_AFTER_ZOOMING_BEFORE_AUTO_ZOOM"]             = "Seconds after zooming before auto zoom-out fires. Set to 0 to disable."

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["OPTIONS_VISTA_ZONE_TEXT_HEADER"]                                   = "Zone Text"
L["OPTIONS_VISTA_ZONE_FONT"]                                          = "Zone font"
L["OPTIONS_VISTA_FONT_ZONE_NAME_BELOW_MINIMAP"]                       = "Font for the zone name below the minimap."
L["OPTIONS_VISTA_ZONE_FONT_SIZE"]                                     = "Zone font size"
L["OPTIONS_VISTA_ZONE_TEXT_COLOR"]                                    = "Zone text color"
L["OPTIONS_VISTA_COLOR_OF_ZONE_NAME_TEXT"]                            = "Color of the zone name text."
L["OPTIONS_VISTA_COORDINATES_TEXT"]                                   = "Coordinates Text"
L["OPTIONS_VISTA_COORDINATES_FONT"]                                   = "Coordinates font"
L["OPTIONS_VISTA_FONT_COORDINATES_TEXT_BELOW_MINIMAP"]                = "Font for the coordinates text below the minimap."
L["OPTIONS_VISTA_COORDINATES_FONT_SIZE"]                              = "Coordinates font size"
L["OPTIONS_VISTA_COORDINATES_TEXT_COLOR"]                             = "Coordinates text color"
L["OPTIONS_VISTA_COLOR_OF_COORDINATES_TEXT"]                          = "Color of the coordinates text."
L["OPTIONS_VISTA_COORDINATE_PRECISION"]                               = "Coordinate precision"
L["OPTIONS_VISTA_NUMBER_OF_DECIMAL_PLACES_SHOWN_X"]                   = "Number of decimal places shown for X and Y coordinates."
L["OPTIONS_VISTA_COORDS_DECIMALS_OFF"]                                = "No decimals (e.g. 52, 37)"
L["OPTIONS_VISTA_DECIMAL_E_G"]                                        = "1 decimal (e.g. 52.3, 37.1)"
L["OPTIONS_VISTA_DECIMALS_E_G"]                                       = "2 decimals (e.g. 52.34, 37.12)"
L["OPTIONS_VISTA_TEXT"]                                               = "Time Text"
L["OPTIONS_VISTA_FONT"]                                               = "Time font"
L["OPTIONS_VISTA_FONT_TEXT_BELOW_MINIMAP"]                            = "Font for the time text below the minimap."
L["OPTIONS_VISTA_FONT_SIZE"]                                          = "Time font size"
L["OPTIONS_VISTA_TEXT_COLOR"]                                         = "Time text color"
L["OPTIONS_VISTA_COLOR_OF_TEXT"]                                      = "Color of the time text."
L["OPTIONS_VISTA_PERFORMANCE_TEXT"]                                   = "Performance Text"
L["OPTIONS_VISTA_PERFORMANCE_FONT"]                                   = "Performance font"
L["OPTIONS_VISTA_FONT_FPS_LATENCY_TEXT_BELOW_MINIMAP"]                = "Font for the FPS and latency text below the minimap."
L["OPTIONS_VISTA_PERFORMANCE_FONT_SIZE"]                              = "Performance font size"
L["OPTIONS_VISTA_PERFORMANCE_TEXT_COLOR"]                             = "Performance text color"
L["OPTIONS_VISTA_COLOR_OF_FPS_LATENCY_TEXT"]                          = "Color of the FPS and latency text."
L["OPTIONS_VISTA_DIFFICULTY_TEXT"]                                    = "Difficulty Text"
L["OPTIONS_VISTA_DIFFICULTY_TEXT_COLOR_FALLBACK"]                     = "Difficulty text color (fallback)"
L["OPTIONS_VISTA_DEFAULT_COLOR_PER_DIFFICULTY_COLOR"]                 = "Default color when no per-difficulty color is set."
L["OPTIONS_VISTA_DIFFICULTY_FONT"]                                    = "Difficulty font"
L["OPTIONS_VISTA_FONT_INSTANCE_DIFFICULTY_TEXT"]                      = "Font for the instance difficulty text."
L["OPTIONS_VISTA_DIFFICULTY_FONT_SIZE"]                               = "Difficulty font size"
L["OPTIONS_VISTA_PER_DIFFICULTY_COLORS"]                              = "Per-Difficulty Colors"
L["OPTIONS_VISTA_MYTHIC_COLOR"]                                       = "Mythic color"
L["OPTIONS_VISTA_COLOR_MYTHIC_DIFFICULTY_TEXT"]                       = "Color for Mythic difficulty text."
L["OPTIONS_VISTA_HEROIC_COLOR"]                                       = "Heroic color"
L["OPTIONS_VISTA_COLOR_HEROIC_DIFFICULTY_TEXT"]                       = "Color for Heroic difficulty text."
L["OPTIONS_VISTA_NORMAL_COLOR"]                                       = "Normal color"
L["OPTIONS_VISTA_COLOR_NORMAL_DIFFICULTY_TEXT"]                       = "Color for Normal difficulty text."
L["OPTIONS_VISTA_LFR_COLOR"]                                          = "LFR color"
L["OPTIONS_VISTA_COLOR_LOOKING_RAID_DIFFICULTY_TEXT"]                 = "Color for Looking For Raid difficulty text."

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["OPTIONS_VISTA_TEXT_ELEMENTS"]                                      = "Text Elements"
L["OPTIONS_VISTA_ZONE_TEXT"]                                          = "Show zone text"
L["OPTIONS_VISTA_ZONE_NAME_BELOW_MINIMAP"]                            = "Show the zone name below the minimap."
L["OPTIONS_VISTA_ZONE_TEXT_DISPLAY_MODE"]                             = "Zone text display mode"
L["OPTIONS_VISTA_WHAT_ZONE_SUBZONE"]                                  = "What to show: zone only, subzone only, or both."
L["OPTIONS_VISTA_ZONE"]                                               = "Zone only"
L["OPTIONS_VISTA_SUBZONE"]                                            = "Subzone only"
L["OPTIONS_VISTA_BOTH"]                                               = "Both"
L["OPTIONS_VISTA_COORDINATES"]                                        = "Show coordinates"
L["OPTIONS_VISTA_PLAYER_COORDINATES_BELOW_MINIMAP"]                   = "Show player coordinates below the minimap."
L["OPTIONS_VISTA_TIME"]                                               = "Show time"
L["OPTIONS_VISTA_CURRENT_GAME_BELOW_MINIMAP"]                         = "Show current game time below the minimap."
L["OPTIONS_VISTA_HOUR_CLOCK"]                                         = "24-hour clock"
L["OPTIONS_VISTA_DISPLAY_HOUR_FORMAT_E_G_INSTEAD"]                    = "Display time in 24-hour format (e.g. 14:30 instead of 2:30 PM)."
L["OPTIONS_VISTA_LOCAL"]                                              = "Use local time"
L["OPTIONS_VISTA_YOUR_LOCAL_SYSTEM"]                                  = "When on, shows your local system time. When off, shows server time."
L["OPTIONS_VISTA_FPS_LATENCY"]                                        = "Show FPS and latency"
L["OPTIONS_VISTA_FPS_LATENCY_MS_BELOW_MINIMAP"]                       = "Show FPS and latency (ms) below the minimap."
L["OPTIONS_VISTA_MINIMAP_BUTTONS"]                                    = "Minimap Buttons"
L["OPTIONS_VISTA_QUEUE_STATUS_MAIL_INDICATOR_ALWAYS_SHOWN"]           = "Queue status and mail indicator are always shown when relevant."
L["OPTIONS_VISTA_TRACKING_BUTTON"]                                    = "Show tracking button"
L["OPTIONS_VISTA_MINIMAP_TRACKING_BUTTON"]                            = "Show the minimap tracking button."
L["OPTIONS_VISTA_TRACKING_BUTTON_MOUSEOVER"]                          = "Tracking button on mouseover only"
L["OPTIONS_VISTA_HIDE_TRACKING_BUTTON_UNTIL_YOU_HOVER"]               = "Hide tracking button until you hover over the minimap."
L["OPTIONS_VISTA_CALENDAR_BUTTON"]                                    = "Show calendar button"
L["OPTIONS_VISTA_MINIMAP_CALENDAR_BUTTON"]                            = "Show the minimap calendar button."
L["OPTIONS_VISTA_CALENDAR_BUTTON_MOUSEOVER"]                          = "Calendar button on mouseover only"
L["OPTIONS_VISTA_HIDE_CALENDAR_BUTTON_UNTIL_YOU_HOVER"]               = "Hide calendar button until you hover over the minimap."
L["OPTIONS_VISTA_ZOOM_BUTTONS"]                                       = "Show zoom buttons"
L["OPTIONS_VISTA_ZOOM_BUTTONS_MINIMAP"]                               = "Show the + and - zoom buttons on the minimap."
L["OPTIONS_VISTA_ZOOM_BUTTONS_MOUSEOVER"]                             = "Zoom buttons on mouseover only"
L["OPTIONS_VISTA_HIDE_ZOOM_BUTTONS_UNTIL_YOU_HOVER"]                  = "Hide zoom buttons until you hover over the minimap."

-- =====================================================================
-- OptionsData.lua Vista — Display (Border / Text Positions / Buttons)
-- =====================================================================
L["OPTIONS_VISTA_BORDER"]                                             = "Border"
L["OPTIONS_VISTA_A_BORDER_AROUND_MINIMAP"]                            = "Show a border around the minimap."
L["OPTIONS_VISTA_BORDER_COLOR"]                                       = "Border color"
L["OPTIONS_VISTA_COLOR_OPACITY_OF_MINIMAP_BORDER"]                    = "Color and opacity of the minimap border. With class colours for Vista on, RGB scales your class tint (white = full strength); opacity always applies."
L["OPTIONS_VISTA_BORDER_THICKNESS"]                                   = "Border thickness"
L["OPTIONS_VISTA_THICKNESS_OF_MINIMAP_BORDER_PIXELS"]                 = "Thickness of the minimap border in pixels (1–8)."
L["OPTIONS_VISTA_CLASS_COLOURS"]                                      = "Class colours"
L["OPTIONS_VISTA_TINT_VISTA_BORDER_TEXT_COORDS_FPS"]                  = "Tint Vista border and text (coords, time, FPS/MS labels) with your class colour. Numbers use the configured colour."
L["OPTIONS_VISTA_TEXT_POSITIONS"]                                     = "Text Positions"
L["OPTIONS_VISTA_DRAG_TEXT_ELEMENTS_REPOSITION_LOCK_PREVEN"]          = "Drag text elements to reposition them. Lock to prevent accidental movement."
L["OPTIONS_VISTA_LOCK_ZONE_TEXT_POSITION"]                            = "Lock zone text position"
L["OPTIONS_VISTA_ZONE_TEXT_CANNOT_DRAGGED"]                           = "When on, the zone text cannot be dragged."
L["OPTIONS_VISTA_LOCK_COORDINATES_POSITION"]                          = "Lock coordinates position"
L["OPTIONS_VISTA_COORDINATES_TEXT_CANNOT_DRAGGED"]                    = "When on, the coordinates text cannot be dragged."
L["OPTIONS_VISTA_LOCK_POSITION"]                                      = "Lock time position"
L["OPTIONS_VISTA_TEXT_CANNOT_DRAGGED"]                                = "When on, the time text cannot be dragged."
L["OPTIONS_VISTA_PERFORMANCE_TEXT_POSITION"]                          = "Performance text position"
L["OPTIONS_VISTA_PLACE_FPS_LATENCY_TEXT_ABOVE_BELOW"]                 = "Place the FPS/latency text above or below the minimap."
L["OPTIONS_VISTA_LOCK_PERFORMANCE_TEXT_POSITION"]                     = "Lock performance text position"
L["OPTIONS_VISTA_FPS_LATENCY_TEXT_CANNOT_DRAGGED"]                    = "When on, the FPS/latency text cannot be dragged."
L["OPTIONS_VISTA_LOCK_DIFFICULTY_TEXT_POSITION"]                      = "Lock difficulty text position"
L["OPTIONS_VISTA_DIFFICULTY_TEXT_CANNOT_DRAGGED"]                     = "When on, the difficulty text cannot be dragged."
L["OPTIONS_VISTA_BUTTON_POSITIONS"]                                   = "Button Positions"
L["OPTIONS_VISTA_DRAG_BUTTONS_REPOSITION_LOCK_PREVENT_MOVE"]          = "Drag buttons to reposition them. Lock to prevent movement."
L["OPTIONS_VISTA_LOCK_ZOOM_BUTTON"]                                   = "Lock Zoom In button"
L["OPTIONS_VISTA_PREVENT_DRAGGING_ZOOM_BUTTON"]                       = "Prevent dragging the + zoom button."
L["OPTIONS_VISTA_LOCK_ZOOM_OUT_BUTTON"]                               = "Lock Zoom Out button"
L["OPTIONS_VISTA_LOCK_ZOOM_OUT_DRAG"]                                 = "Prevent dragging the - zoom button."
L["OPTIONS_VISTA_LOCK_TRACKING_BUTTON"]                               = "Lock Tracking button"
L["OPTIONS_VISTA_PREVENT_DRAGGING_TRACKING_BUTTON"]                   = "Prevent dragging the tracking button."
L["OPTIONS_VISTA_LOCK_CALENDAR_BUTTON"]                               = "Lock Calendar button"
L["OPTIONS_VISTA_PREVENT_DRAGGING_CALENDAR_BUTTON"]                   = "Prevent dragging the calendar button."
L["OPTIONS_VISTA_LOCK_QUEUE_BUTTON"]                                  = "Lock Queue button"
L["OPTIONS_VISTA_PREVENT_DRAGGING_QUEUE_STATUS_BUTTON"]               = "Prevent dragging the queue status button."
L["OPTIONS_VISTA_LOCK_MAIL_INDICATOR"]                                = "Lock Mail indicator"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MAIL_ICON"]                         = "Prevent dragging the mail icon."
L["OPTIONS_VISTA_DISABLE_QUEUE_HANDLING"]                             = "Disable queue handling"
L["OPTIONS_VISTA_DISABLE_QUEUE_BUTTON_HANDLING"]                      = "Disable queue button handling"
L["OPTIONS_VISTA_TURN_QUEUE_BUTTON_ANCHORING_ANOTHER_A"]              = "Turn off all queue button anchoring (use if another addon manages it)."
L["OPTIONS_VISTA_BUTTON_SIZES"]                                       = "Button Sizes"
L["OPTIONS_VISTA_ADJUST_SIZE_OF_MINIMAP_OVERLAY_BUTTONS"]             = "Adjust the size of minimap overlay buttons."
L["OPTIONS_VISTA_TRACKING_BUTTON_SIZE"]                               = "Tracking button size"
L["OPTIONS_VISTA_SIZE_OF_TRACKING_BUTTON_PIXELS"]                     = "Size of the tracking button (pixels)."
L["OPTIONS_VISTA_CALENDAR_BUTTON_SIZE"]                               = "Calendar button size"
L["OPTIONS_VISTA_SIZE_OF_CALENDAR_BUTTON_PIXELS"]                     = "Size of the calendar button (pixels)."
L["OPTIONS_VISTA_QUEUE_BUTTON_SIZE"]                                  = "Queue button size"
L["OPTIONS_VISTA_SIZE_OF_QUEUE_STATUS_BUTTON_PIXELS"]                 = "Size of the queue status button (pixels)."
L["OPTIONS_VISTA_ZOOM_BUTTON_SIZE"]                                   = "Zoom button size"
L["OPTIONS_VISTA_SIZE_OF_ZOOM_ZOOM_BUTTONS_PIXELS"]                   = "Size of the zoom in / zoom out buttons (pixels)."
L["OPTIONS_VISTA_MAIL_INDICATOR_SIZE"]                                = "Mail indicator size"
L["OPTIONS_VISTA_SIZE_OF_MAIL_ICON_PIXELS"]                           = "Size of the new mail icon (pixels)."
L["OPTIONS_VISTA_ADDON_BUTTON_SIZE"]                                  = "Addon button size"
L["OPTIONS_VISTA_SIZE_OF_COLLECTED_ADDON_MINIMAP_BUTTONS"]            = "Size of collected addon minimap buttons (pixels)."

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
L["OPTIONS_VISTA_COLLECT_HORIZON_MINIMAP"]                            = "Include Horizon minimap icon"
L["OPTIONS_VISTA_COLLECT_HORIZON_MINIMAP_DESC"]                       = "Put Horizon's own minimap icon in the managed addon bar, right-click panel, or drawer instead of leaving it on the minimap edge."
L["OPTIONS_VISTA_ADDON_BUTTONS"]                                      = "Addon Buttons"
L["OPTIONS_VISTA_MINIMAP_ADDON_BUTTONS"]                              = "Minimap Addon Buttons"
L["OPTIONS_VISTA_BUTTON_MANAGEMENT"]                                  = "Button Management"
L["OPTIONS_VISTA_MANAGE_ADDON_MINIMAP_BUTTONS"]                       = "Manage addon minimap buttons"
L["OPTIONS_VISTA_VISTA_TAKES_CONTROL_OF_ADDON_MINIMAP"]               = "When on, Vista takes control of addon minimap buttons and groups them by the selected mode."
L["OPTIONS_VISTA_BUTTON_MODE"]                                        = "Button mode"
L["OPTIONS_VISTA_ADDON_BUTTONS_PRESENTED_HOVER_BAR_BELOW"]            = "How addon buttons are presented: hover bar below minimap, panel on right-click, or floating drawer button."
L["OPTIONS_VISTA_ALWAYS_BAR"]                                         = "Always show bar"
L["OPTIONS_VISTA_ALWAYS_MOUSEOVER_BAR_POSITIONING"]                   = "Always show mouseover bar (for positioning)"
L["OPTIONS_VISTA_KEEP_MOUSEOVER_BAR_VISIBLE_TIMES_YOU"]               = "Keep the mouseover bar visible at all times so you can reposition it. Disable when done."
L["OPTIONS_VISTA_DISABLE_DONE"]                                       = "Disable when done."
L["OPTIONS_VISTA_MOUSEOVER_BAR"]                                      = "Mouseover bar"
L["OPTIONS_VISTA_RIGHT_CLICK_PANEL"]                                  = "Right-click panel"
L["OPTIONS_VISTA_FLOATING_DRAWER"]                                    = "Floating drawer"
L["OPTIONS_VISTA_LOCK_DRAWER_BUTTON_POSITION"]                        = "Lock drawer button position"
L["OPTIONS_VISTA_PREVENT_DRAGGING_FLOATING_DRAWER_BUTTON"]            = "Prevent dragging the floating drawer button."
L["OPTIONS_VISTA_LOCK_MOUSEOVER_BAR_POSITION"]                        = "Lock mouseover bar position"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MOUSEOVER_BUTTON_BAR"]              = "Prevent dragging the mouseover button bar."
L["OPTIONS_VISTA_LOCK_RIGHT_CLICK_PANEL_POSITION"]                    = "Lock right-click panel position"
L["OPTIONS_VISTA_PREVENT_DRAGGING_RIGHT_CLICK_PANEL"]                 = "Prevent dragging the right-click panel."
L["OPTIONS_VISTA_BUTTONS_PER_ROW_COLUMN"]                             = "Buttons per row/column"
L["OPTIONS_VISTA_CONTROLS_MANY_BUTTONS_APPEAR_BEFORE_WRAPPING"]       = "Controls how many buttons appear before wrapping. For left/right direction this is columns; for up/down it is rows."
L["OPTIONS_VISTA_EXPAND_DIRECTION"]                                   = "Expand direction"
L["OPTIONS_VISTA_DIRECTION_BUTTONS_FILL_ANCHOR_POINT_LEFT"]           = "Direction buttons fill from the anchor point. Left/Right = horizontal rows. Up/Down = vertical columns."
L["OPTIONS_VISTA_RIGHT"]                                              = "Right"
L["OPTIONS_VISTA_LEFT"]                                               = "Left"
L["OPTIONS_VISTA_DOWN"]                                               = "Down"
L["OPTIONS_VISTA_UP"]                                                 = "Up"
L["OPTIONS_VISTA_MOUSEOVER_BAR_APPEARANCE"]                           = "Mouseover Bar Appearance"
L["OPTIONS_VISTA_BACKGROUND_BORDER_MOUSEOVER_BUTTON_BAR"]             = "Background and border for the mouseover button bar."
L["OPTIONS_VISTA_BACKDROP_COLOR"]                                     = "Backdrop color"
L["OPTIONS_VISTA_BACKGROUND_COLOR_OF_MOUSEOVER_BUTTON_BAR"]           = "Background color of the mouseover button bar (use alpha to control transparency)."
L["OPTIONS_VISTA_BAR_BORDER"]                                         = "Show bar border"
L["OPTIONS_VISTA_A_BORDER_AROUND_MOUSEOVER_BUTTON_BAR"]               = "Show a border around the mouseover button bar."
L["OPTIONS_VISTA_BAR_BORDER_COLOR"]                                   = "Bar border color"
L["OPTIONS_VISTA_BORDER_COLOR_OF_MOUSEOVER_BUTTON_BAR"]               = "Border color of the mouseover button bar."
L["OPTIONS_VISTA_BAR_BACKGROUND_COLOR"]                               = "Bar background color"
L["OPTIONS_VISTA_PANEL_BACKGROUND_COLOR"]                             = "Panel background color."
L["OPTIONS_VISTA_CLOSE_FADE_TIMING"]                                  = "Close / Fade Timing"
L["OPTIONS_VISTA_MOUSEOVER_BAR_CLOSE_DELAY_SECONDS"]                  = "Mouseover bar — close delay (seconds)"
L["OPTIONS_VISTA_LONG_SECONDS_BAR_STAYS_VISIBLE_AFTER"]               = "How long (in seconds) the bar stays visible after the cursor leaves. 0 = instant fade."
L["OPTIONS_VISTA_RIGHT_CLICK_PANEL_CLOSE_DELAY_SECONDS"]              = "Right-click panel — close delay (seconds)"
L["OPTIONS_VISTA_LONG_SECONDS_PANEL_STAYS_OPEN_AFTER"]                = "How long (in seconds) the panel stays open after the cursor leaves. 0 = never auto-close (close by right-clicking again)."
L["OPTIONS_VISTA_FLOATING_DRAWER_CLOSE_DELAY_SECONDS"]                = "Floating drawer — close delay (seconds)"
L["OPTIONS_VISTA_DRAWER_CLOSE_DELAY"]                                 = "Drawer close delay"
L["OPTIONS_VISTA_LONG_SECONDS_DRAWER_PANEL_STAYS_OPEN"]               = "How long (in seconds) the drawer panel stays open after clicking away. 0 = never auto-close (close only by clicking the drawer button again)."
L["OPTIONS_VISTA_MAIL_ICON_BLINK"]                                    = "Mail icon blink"
L["OPTIONS_VISTA_MAIL_ICON_PULSES_DRAW_ATTENTION"]                    = "When on, the mail icon pulses to draw attention. When off, it stays at full opacity."
L["OPTIONS_VISTA_PANEL_APPEARANCE"]                                   = "Panel Appearance"
L["OPTIONS_VISTA_COLORS_DRAWER_RIGHT_CLICK_BUTTON_PANELS"]            = "Colors for the drawer and right-click button panels."
L["OPTIONS_VISTA_PANEL_BG_COLOR_LABEL"]                               = "Panel background color"
L["OPTIONS_VISTA_BACKGROUND_COLOR_OF_ADDON_BUTTON_PANELS"]            = "Background color of the addon button panels."
L["OPTIONS_VISTA_PANEL_BORDER_COLOR"]                                 = "Panel border color"
L["OPTIONS_VISTA_BORDER_COLOR_OF_ADDON_BUTTON_PANELS"]                = "Border color of the addon button panels."
L["OPTIONS_VISTA_MANAGED_BUTTONS"]                                    = "Managed buttons"
L["OPTIONS_VISTA_BUTTON_COMPLETELY_IGNORED_A"]                        = "When off, this button is completely ignored by this addon."
L["OPTIONS_VISTA_ADDON_BUTTONS_DETECTED"]                             = "(No addon buttons detected yet)"
L["OPTIONS_VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE"]                      = "Visible buttons (check to include)"
L["OPTIONS_VISTA_ADDON_BUTTONS_DETECTED_OPEN_YOUR_MINIMAP"]           = "(No addon buttons detected yet — open your minimap first)"

-- =====================================================================
-- Inline option / module strings (used in OptionsData / modules; symbolic migration)
-- =====================================================================

L["OPTIONS_CORE_HEROIC_DUNGEON"]                                      = "Heroic dungeon"
L["OPTIONS_CORE_HEROIC_RAID"]                                         = "Heroic raid"
L["OPTIONS_CORE_LFR"]                                                 = "LFR"
L["OPTIONS_CORE_MYTHIC_DUNGEON"]                                      = "Mythic dungeon"
L["OPTIONS_CORE_MYTHIC_RAID"]                                         = "Mythic raid"
L["OPTIONS_CORE_MYTHIC_PLUS_DUNGEON"]                                 = "Mythic+ dungeon"
L["OPTIONS_CORE_NORMAL_DUNGEON"]                                      = "Normal dungeon"
L["OPTIONS_CORE_NORMAL_RAID"]                                         = "Normal raid"
L["OPTIONS_CORE_ACHIEVEMENT_ICONS"]                                   = "Achievement icons"
L["OPTIONS_CORE_ACTIVE_INSTANCE"]                                     = "Active instance only"
L["OPTIONS_CORE_ADJUST_FONT_SIZES_AMOUNT"]                            = "Adjust all font sizes by this amount."
L["OPTIONS_CORE_ADJUST_FONTS_SIZES_CASING_DROP_SHADOWS"]              = "Adjust fonts, sizes, casing, and drop shadows."
L["OPTIONS_CORE_AFFIX_ICONS"]                                         = "Affix icons"
L["OPTIONS_CORE_AFFIX_TOOLTIPS"]                                      = "Affix tooltips"
L["OPTIONS_CORE_AFFECTS_SCENARIO_PROGRESS_TIMER_BARS"]                = "Also affects scenario progress and timer bars."
L["OPTIONS_CORE_ALWAYS"]                                              = "Always show"
L["OPTIONS_CORE_ALWAYS_M_TIMER"]                                      = "Always show M+ timer."
L["OPTIONS_CORE_AUTO_ADD_WQS_YOUR_CURRENT_ZONE"]                      = "Auto-add WQs in your current zone."
L["OPTIONS_CORE_AUTO_CLOSE_DELAY_DISABLE"]                            = "Auto-close delay (0 to disable)."
L["OPTIONS_CORE_AUTO_UNTRACK_FINISHED_ACTIVITIES"]                    = "Auto-untrack finished activities."
L["OPTIONS_CORE_BAR_UNDER_NUMERIC_OBJECTIVES_E_G"]                    = "Bar under numeric objectives (e.g. 3/250)."
L["OPTIONS_CORE_BLIZZARD_DEFAULT_RONDOMEDIA_CLASS_ICON_DASHBO"]       = "Blizzard default, RondoMedia, or Horizon class icon on the Dashboard when Dashboard class colours are on. Independent of Insight tooltip class icons."
L["OPTIONS_CORE_BLOCK_POSITION"]                                      = "Block position"
L["OPTIONS_CORE_BOSS_EMOTES"]                                         = "Boss emotes"
L["OPTIONS_CORE_CHOICE_SLOTS"]                                        = "Choice slots"
L["OPTIONS_CORE_CHOOSE_WHICH_EVENTS_TRIGGER_SCREEN_ALERTS"]           = "Choose which events trigger on-screen alerts."
L["OPTIONS_CORE_CHOOSE_WHICH_SOUND_PLAY_A_RARE"]                      = "Choose which sound to play when a rare boss appears. Requires LibSharedMedia sounds to be installed for extra options."
L["OPTIONS_CORE_CLICK_BEHAVIOR"]                                      = "Click behavior"
L["OPTIONS_CORE_COLLECT_GROUP_ADDON_MINIMAP_BUTTONS"]                 = "Collect and group addon minimap buttons."
L["OPTIONS_CORE_COLOR_REMAINING"]                                     = "Color by remaining time."
L["OPTIONS_CORE_COLOR_ZONE_TYPE"]                                     = "Color by zone type"
L["OPTIONS_CORE_COLOR_CONTESTED_ZONES_ORANGE_DEFAULT"]                = "Color for contested zones (orange by default)."
L["OPTIONS_CORE_COLOR_FRIENDLY_ZONES_GREEN_DEFAULT"]                  = "Color for friendly zones (green by default)."
L["OPTIONS_CORE_COLOR_HOSTILE_ZONES_RED_DEFAULT"]                     = "Color for hostile zones (red by default)."
L["OPTIONS_CORE_COLOR_SANCTUARY_ZONES_BLUE_DEFAULT"]                  = "Color for sanctuary zones (blue by default)."
L["OPTIONS_CORE_COLOR_OF_DIVIDER_LINES_BETWEEN_SECTIONS"]             = "Color of the divider lines between sections."
L["OPTIONS_CORE_COLOR_RECIPE_TITLES_OUTPUT_ITEM_RARITY"]              = "Color recipe titles by output item rarity."
L["OPTIONS_CORE_COLOR_ZONE_SUBZONE_TITLES_PVP_ZONE"]                  = "Color zone/subzone titles by PvP zone type (friendly, hostile, contested, sanctuary). When off, uses the default category color."
L["OPTIONS_CORE_COMBAT_AFK_DND_PVP_PARTY_FRIENDS"]                    = "Combat, AFK, DND, PvP, party, friends, targeting."
L["OPTIONS_CORE_COMING_SOON"]                                         = "Coming Soon"
L["OPTIONS_CORE_COMPLETED_BOSS_STYLE"]                                = "Completed boss style"
L["OPTIONS_CORE_COMPLETED_COUNT"]                                     = "Completed count"
L["OPTIONS_CORE_CONFIGURE_CLICK_BEHAVIORS_TRACKING_RULES_TOMTOM"]     = "Configure click behaviors, tracking rules, and TomTom integration."
L["OPTIONS_CORE_CONFIGURE_MINIMAP_S_SHAPE_SIZE_POSITION"]             = "Configure the minimap's shape, size, position, and text overlays."
L["OPTIONS_CORE_CONTESTED_ZONE_COLOR"]                                = "Contested zone color"
L["OPTIONS_CORE_CONTROL_TRACKER_VISIBILITY_WITHIN_DUNGEONS_RAIDS"]    = "Control tracker visibility within dungeons, raids, and PvP."
L["OPTIONS_CORE_SETTINGS_PRESENCE_NOTIFICATION_FRAMEWORK"]            = "Core settings for the Presence notification framework."
L["OPTIONS_CORE_CRAFTABLE_COUNT"]                                     = "Craftable count"
L["OPTIONS_CORE_CTRL_LEFT_FOCUS_ADD_CTRL_RIGHT"]                      = "Ctrl+Left = focus/add, Ctrl+Right = unfocus/untrack."
L["OPTIONS_CORE_CURRENT_ZONE_GROUP"]                                  = "Current Zone group"
L["OPTIONS_CORE_CURRENT_ZONE"]                                        = "Current zone only"
L["OPTIONS_CORE_CUSTOMIZE_BORDERS_COLORS_POSITIONING_OF_SPECIFI"]     = "Customize borders, colors, and the positioning of specific minimap elements."
L["OPTIONS_CORE_CUSTOMIZE_VISUAL_INTERFACE_LAYOUT_ELEMENTS"]          = "Customize the visual interface and layout elements."
L["OPTIONS_CORE_DASHBOARD_CLASS_ICON_STYLE"]                          = "Dashboard class icon style"
L["OPTIONS_CORE_DECOR_ICONS"]                                         = "Decor icons"
L["OPTIONS_CORE_DEDICATED_SECTION_COMPLETED_QUESTS"]                  = "Dedicated section for completed quests."
L["OPTIONS_CORE_DEDICATED_SECTION_ZONE_QUESTS"]                       = "Dedicated section for in-zone quests."
L["OPTIONS_CORE_DEFEATED_BOSS_STYLE"]                                 = "Defeated boss style."
L["OPTIONS_CORE_DESATURATE_FOCUSED_ENTRIES"]                          = "Desaturate non-focused entries."
L["OPTIONS_CORE_DESATURATE_FOCUSED_QUESTS"]                           = "Desaturate non-focused quests"
L["OPTIONS_CORE_DIM_ALPHA"]                                           = "Dim alpha"
L["OPTIONS_CORE_DIM_STRENGTH"]                                        = "Dim strength"
L["OPTIONS_CORE_DIM_UNFOCUSED_TRACKER_ENTRIES"]                       = "Dim unfocused tracker entries."
L["OPTIONS_CORE_DIMMING_STRENGTH"]                                    = "Dimming strength (0-100%)."
L["OPTIONS_CORE_DISPLAY_COMPLETED_OBJECTIVES"]                        = "Display completed objectives."
L["OPTIONS_CORE_ENABLE_BLACKLIST_UNTRACKED_INTERACTIONS_ADD_QUEST"]   = "Enable 'Blacklist untracked' in Interactions to add quests here."
L["OPTIONS_CORE_ENABLE_M_BLOCK"]                                      = "Enable M+ block"
L["OPTIONS_CORE_ENEMY_FORCES_COLOR"]                                  = "Enemy forces color"
L["OPTIONS_CORE_ENEMY_FORCES_SIZE"]                                   = "Enemy forces size"
L["OPTIONS_CORE_ENHANCE_PLAYER_ITEM_TOOLTIPS_EXTRA_DETAILS"]          = "Enhance player and item tooltips with extra details like Mythic+ score and transmog status."
L["OPTIONS_CORE_ENTRY_NUMBERS"]                                       = "Entry numbers"
L["OPTIONS_CORE_ENTRY_SPACING"]                                       = "Entry spacing"
L["OPTIONS_CORE_EXPAND_DIRECTION_ANCHOR"]                             = "Expand direction from anchor."
L["OPTIONS_CORE_FADE_HOVERING"]                                       = "Fade out when not hovering."
L["FOCUS_FINISHING_REAGENTS"]                                         = "Finishing reagents"
L["OPTIONS_FOCUS_ANIMATIONS"]                                         = "Focus animations"
L["OPTIONS_CORE_FONT_SIZE_BAR_LABEL_BAR_HEIGHT"]                      = "Font size for bar label and bar height."
L["OPTIONS_CORE_FONTS_SIZES_COLORS_PRESENCE_NOTIFICATIONS"]           = "Fonts, sizes, and colors for Presence notifications."
L["OPTIONS_CORE_WORLD_QUESTS_WEEKLIES_YOUR_QUEST_LOG"]                = "For world quests and weeklies not in your quest log."
L["OPTIONS_CORE_FRIENDLY_ZONE_COLOR"]                                 = "Friendly zone color"
L["OPTIONS_CORE_GROUPING"]                                            = "Grouping"
L["OPTIONS_CORE_GROUPS_SELECTED_LAYOUT_MODE_BELOW"]                   = "Groups them by the selected layout mode below."
L["OPTIONS_CORE_GUILD_RANK"]                                          = "Guild rank"
L["OPTIONS_CORE_HEADER_DIVIDER"]                                      = "Header divider"
L["OPTIONS_CORE_HIDE_UNTRACKED_QUESTS_UNTIL_RELOAD"]                  = "Hide untracked quests until reload."
L["OPTIONS_CORE_HIDE_ZONE_NOTIFICATIONS_MYTHIC"]                      = "Hide zone notifications in Mythic+."
L["OPTIONS_CORE_HIDES_CATEGORIES_WHILE_A_DELVE_PARTY"]                = "Hides other categories while in a Delve or party dungeon."
L["OPTIONS_CORE_HINT_LIST_SCROLLABLE"]                                = "Hint when the list is scrollable."
L["OPTIONS_CORE_HONOR_LEVEL"]                                         = "Honor level"
L["OPTIONS_CORE_HOSTILE_ZONE_COLOR"]                                  = "Hostile zone color"
L["OPTIONS_CORE_MUCH_DIM_FOCUSED_ENTRIES_DIMMING_FU"]                 = "How much to dim non-focused entries (0 = no dimming, 100 = fully darkened). Default 40%."
L["OPTIONS_CORE_ICON_NEXT_ACHIEVEMENT_TITLE"]                         = "Icon next to achievement title."
L["OPTIONS_CORE_ICON_NEXT_AUTO_TRACKED_ZONE_ENTRIES"]                 = "Icon next to auto-tracked in-zone entries."
L["OPTIONS_CORE_ARENA"]                                               = "In arena"
L["OPTIONS_CORE_BATTLEGROUND"]                                        = "In battleground"
L["OPTIONS_CORE_DUNGEON"]                                             = "In dungeon"
L["OPTIONS_CORE_RAID"]                                                = "In raid"
L["OPTIONS_CORE_ZONE_WORLD_QUESTS"]                                   = "In-zone world quests"
L["OPTIONS_CORE_INCLUDE_COMPLETED"]                                   = "Include completed"
L["OPTIONS_CORE_INSTANCE_SUPPRESSION"]                                = "Instance suppression"
L["OPTIONS_CORE_ITEM_LEVEL"]                                          = "Item level"
L["OPTIONS_CORE_ITEM_SOURCE"]                                         = "Item source"
L["OPTIONS_CORE_KEEP_BAR_VISIBLE_REPOSITIONING"]                      = "Keep bar visible for repositioning."
L["OPTIONS_CORE_KEEP_CAMPAIGN_CATEGORY"]                              = "Keep campaign in category"
L["OPTIONS_CORE_KEEP_HEADER_BOTTOM_TOP_UNTIL_COLLAPSED"]              = "Keep header at bottom, or top until collapsed."
L["OPTIONS_CORE_KEEP_IMPORTANT_CATEGORY"]                             = "Keep important in category"
L["OPTIONS_CORE_KEEP_CAMPAIGN_READY_TURN"]                            = "Keep in Campaign when ready to turn in."
L["OPTIONS_CORE_KEEP_IMPORTANT_READY_TURN"]                           = "Keep in Important when ready to turn in."
L["OPTIONS_CORE_KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED"]              = "Keep section headers visible when collapsed."
L["OPTIONS_CORE_L_CLICK_OPENS_MAP_R_CLICK"]                           = "L-click opens map, R-click opens menu."
L["PRESENCE_LEVEL_UP_TOGGLE"]                                         = "Level up"
L["OPTIONS_CORE_LOCK_DRAWER_BUTTON"]                                  = "Lock drawer button"
L["OPTIONS_CORE_LOCK_ITEM_POSITION"]                                  = "Lock item position"
L["OPTIONS_CORE_LOCK_MINIMAP"]                                        = "Lock minimap"
L["OPTIONS_CORE_LOCK_MOUSEOVER_BAR"]                                  = "Lock mouseover bar"
L["OPTIONS_CORE_LOCK_RIGHT_CLICK_PANEL"]                              = "Lock right-click panel"
L["OPTIONS_CORE_MAIL_ICON_PULSE"]                                     = "Mail icon pulse"
L["OPTIONS_CORE_MAKE_FOCUSED_ENTRIES_GREYSCALE_PARTIALLY_DESATURATE"]   = "Make non-focused entries greyscale/partially desaturated in addition to dimming."
L["OPTIONS_CORE_MANAGE_ADDON_BUTTONS"]                                = "Manage addon buttons"
L["OPTIONS_CORE_MANAGE_ORGANIZE_MINIMAP_ICONS_ADDONS_INT"]            = "Manage and organize minimap icons from other addons into a tidy drawer or bar."
L["OPTIONS_CORE_MANAGE_SWITCH_BETWEEN_YOUR_ADDON_CONFIGURATIONS"]     = "Manage and switch between your addon configurations."
L["OPTIONS_CORE_MATCH_BAR_QUEST_CATEGORY_COLOR"]                      = "Match bar to quest category color."
L["OPTIONS_CORE_APPEAR_FULL_TRACKER_REPLACEMENTS"]                    = "May not appear with full tracker replacements."
L["OPTIONS_CORE_MINIMAL_MODE"]                                        = "Minimal mode"
L["OPTIONS_CORE_MISSING_CRITERIA"]                                    = "Missing criteria only"
L["OPTIONS_CORE_MOUNT_INFO"]                                          = "Mount info"
L["OPTIONS_CORE_MOUNT_NAME_SOURCE_COLLECTION_STATUS"]                 = "Mount name, source, and collection status."
L["OPTIONS_CORE_MOUSEOVER_CLOSE_DELAY"]                               = "Mouseover close delay"
L["OPTIONS_CORE_MOUSEOVER"]                                           = "Mouseover only"
L["OPTIONS_CORE_MOVE_COMPLETED_QUESTS_BOTTOM_OF_CURRENT"]             = "Move completed quests to the bottom of the Current Zone section."
L["OPTIONS_CORE_MYTHIC_BLOCK"]                                        = "Mythic+ Block"
L["OPTIONS_CORE_MYTHIC_COLORS"]                                       = "Mythic+ Colors"
L["OPTIONS_CORE_MYTHIC_SCORE"]                                        = "Mythic+ score"
L["OPTIONS_CORE_DEFAULT"]                                             = "New from Default"
L["OPTIONS_CORE_HIDDEN_QUESTS"]                                       = "No hidden quests."
L["OPTIONS_CORE_NOTIFY_ACHIEVEMENT_CRITERIA_UPDATE"]                  = "Notify on achievement criteria update."
L["OPTIONS_CORE_OBJECTIVE_PROGRESS"]                                  = "Objective progress"
L["OPTIONS_CORE_OBJECTIVE_SPACING"]                                   = "Objective spacing"
L["OPTIONS_CORE_L_CLICK_FOCUSES_R_CLICK_UNTRACKS"]                    = "Off: L-click focuses, R-click untracks. Ctrl+Right shares."
L["OPTIONS_CORE_PROGRESS_TRACKED_ACHIEVEMENTS_SHOWN"]                 = "Off: only in-progress tracked achievements shown."
L["OPTIONS_CORE_TRACKED_NEARBY_WQS_APPEAR_BLIZZARD_DEFAULT"]          = "Off: only tracked or nearby WQs appear (Blizzard default)."
L["OPTIONS_CORE_BOSS_EMOTES_ACHIEVEMENTS_LEVEL_HIDES_ZONE"]           = "Only boss emotes, achievements, and level-up. Hides zone, quest, and scenario notifications in Mythic+."
L["OPTIONS_CORE_ENTRIES_A_SINGLE_NUMERIC_OBJECTIVE_WHERE"]            = "Only for entries with a single numeric objective where required > 1."
L["OPTIONS_CORE_QUESTS_DON_T_NEED_NPC_TURN"]                          = "Only for quests that don't need NPC turn-in. Off = Blizzard default."
L["OPTIONS_CORE_INCOMPLETE_CRITERIA"]                                 = "Only show incomplete criteria."
L["OPTIONS_CORE_SUBZONE_NAME_WITHIN_SAME_ZONE"]                       = "Only show subzone name within same zone."
L["OPTIONS_CORE_OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]                  = "Opacity of focused quest highlight (0–100%)."
L["OPTIONS_CORE_OPACITY_OF_UNFOCUSED_ENTRIES"]                        = "Opacity of unfocused entries."
L["FOCUS_OPTIONAL_REAGENTS"]                                          = "Optional reagents"
L["OPTIONS_CORE_OPTIONS_BUTTON"]                                      = "Options button"
L["OPTIONS_CORE_ORGANIZE_HIDE_TRACKED_ENTRIES_YOUR_PREFERENCE"]       = "Organize and hide tracked entries to your preference."
L["OPTIONS_CORE_OVERRIDE_FONT_PER_ELEMENT"]                           = "Override font per element."
L["OPTIONS_CORE_PANEL_BACKGROUND_OPACITY"]                            = "Panel background opacity (0–100%)."
L["OPTIONS_CORE_PERMANENTLY_HIDE_UNTRACKED_QUESTS"]                   = "Permanently hide untracked quests."
L["OPTIONS_CORE_PERSONALIZE_COLOR_PALETTE_TRACKER_TEXT_ELEMENTS"]     = "Personalize the color palette for tracker text elements."
L["OPTIONS_CORE_POSITIONING_VISIBILITY_CACHE_LOOT_TOAST_SYS"]         = "Positioning and visibility for the Cache loot toast system."
L["OPTIONS_CORE_PREVENT_ACCIDENTAL_CLICKS"]                           = "Prevent accidental clicks."
L["OPTIONS_CORE_QUALITY_INFO"]                                        = "Quality info"
L["OPTIONS_CORE_QUEST_ACCEPT"]                                        = "Quest accept"
L["OPTIONS_CORE_QUEST_COMPLETE"]                                      = "Quest complete"
L["OPTIONS_CORE_QUEST_COUNT"]                                         = "Quest count"
L["OPTIONS_CORE_QUEST_ITEM_BUTTONS"]                                  = "Quest item buttons"
L["OPTIONS_CORE_QUEST_LEVEL"]                                         = "Quest level"
L["OPTIONS_CORE_QUEST_PROGRESS"]                                      = "Quest progress"
L["OPTIONS_CORE_QUEST_PROGRESS_BAR"]                                  = "Quest progress bar"
L["OPTIONS_CORE_QUEST_TRACKING"]                                      = "Quest tracking"
L["OPTIONS_CORE_QUEST_TYPE_ICONS"]                                    = "Quest type icons"
L["OPTIONS_FOCUS_QUEST_TYPE_ICON_SIZE"]                               = "Quest type icon size"
L["OPTIONS_FOCUS_QUEST_TYPE_ICON_SIZE_DESC"]                          = "Pixel size of the quest type icon shown in the left gutter (default 16)."
L["PRESENCE_RARE_DEFEATED"]                                           = "RARE DEFEATED"
L["OPTIONS_CORE_RARE_ADDED_SOUND_CHOICE"]                             = "Rare added sound choice"
L["OPTIONS_CORE_RARE_SOUND_ALERT"]                                    = "Rare sound alert"
L["OPTIONS_CORE_RARITY_COLORS"]                                       = "Rarity colors"
L["OPTIONS_CORE_READY_TURN_GROUP"]                                    = "Ready to Turn In group"
L["OPTIONS_CORE_READY_TURN_BOTTOM"]                                   = "Ready to turn in at bottom"
L["OPTIONS_CORE_REAGENTS"]                                            = "Reagents"
L["OPTIONS_CORE_RECIPE_ICONS"]                                        = "Recipe icons"
L["OPTIONS_CORE_RECIPES"]                                             = "Recipes"
L["OPTIONS_CORE_REDUCE_OPACITY_OF_FOCUSED_ENTRIES_INVISIBLE"]         = "Reduce opacity of non-focused entries (0 = invisible, 100 = fully opaque). Default 100% (no alpha change)."
L["OPTIONS_CORE_REQUIRE_CTRL_COMPLETE_CLICK_COMPLETABLE_QUESTS"]      = "Require Ctrl to complete click-completable quests."
L["OPTIONS_CORE_REQUIREMENTS"]                                        = "Requirements"
L["OPTIONS_CORE_REQUIRES_QUEST_TYPE_ICONS_ENABLED_DISPLAY"]           = "Requires quest type icons to be enabled in Display."
L["OPTIONS_CORE_RESET_MYTHIC_STYLING"]                                = "Reset Mythic+ styling"
L["OPTIONS_CORE_REVIEW_MANAGE_QUESTS_YOU_MANUALLY_UNTRACKED"]         = "Review and manage quests you have manually untracked or blacklisted."
L["OPTIONS_CORE_RIGHT_CLICK_CLOSE_DELAY"]                             = "Right-click close delay"
L["OPTIONS_CORE_SANCTUARY_ZONE_COLOR"]                                = "Sanctuary zone color"
L["OPTIONS_CORE_SCALE_UI_ELEMENTS"]                                   = "Scale all UI elements (50–200%)."
L["PRESENCE_SCENARIO_COMPLETE"]                                       = "Scenario Complete"
L["OPTIONS_CORE_SCENARIO_EVENTS"]                                     = "Scenario events"
L["OPTIONS_CORE_SCENARIO_PROGRESS"]                                   = "Scenario progress"
L["OPTIONS_CORE_SCENARIO_PROGRESS_BAR"]                               = "Scenario progress bar"
L["OPTIONS_CORE_SCENARIO_START"]                                      = "Scenario start"
L["OPTIONS_CORE_SCENARIO_TIMER_BAR"]                                  = "Scenario timer bar"
L["OPTIONS_CORE_SCROLL_INDICATOR"]                                    = "Scroll indicator"
L["OPTIONS_CORE_SECONDS_OF_RECENT_PROGRESS"]                          = "Seconds of recent progress to show."
L["OPTIONS_CORE_SECTION_DIVIDER_COLOR"]                               = "Section divider color"
L["OPTIONS_CORE_SECTION_HEADERS"]                                     = "Section headers"
L["OPTIONS_CORE_SECTIONS_COLLAPSED"]                                  = "Sections when collapsed"
L["OPTIONS_CORE_SEPARATE_SCALE_SLIDER_PER_MODULE"]                    = "Separate scale slider per module."
L["OPTIONS_CORE_SHADOW_OPACITY"]                                      = "Shadow opacity (0–100%)."
L["OPTIONS_CORE_A_VISUAL_DIVIDER_LINE_BETWEEN_FOCUS"]                 = "Show a visual divider line between Focus sections to make categories easier to distinguish."
L["OPTIONS_CORE_AFFIX_NAMES_FIRST_DELVE_ENTRY"]                       = "Show affix names on first Delve entry."
L["OPTIONS_CORE_COLLAPSIBLE_CHOICE_REAGENT_SLOTS"]                    = "Show collapsible choice reagent slots."
L["OPTIONS_CORE_COMPLETED_ACHIEVEMENTS_LIST"]                         = "Show completed achievements in the list."
L["OPTIONS_CORE_FINISHING_REAGENT_SLOTS"]                             = "Show finishing reagent slots."
L["OPTIONS_CORE_MANY_TIMES_RECIPE_CRAFTED"]                           = "Show how many times the recipe can be crafted."
L["OPTIONS_CORE_NORMAL_DUNGEONS"]                                     = "Show in Normal dungeons."
L["OPTIONS_CORE_LOCAL_SYSTEM"]                                        = "Show local system time."
L["OPTIONS_CORE_NOTIFICATION_A_RARE_MOB_DEFEATED_NEARBY"]             = "Show notification when a rare mob is defeated nearby."
L["OPTIONS_CORE_NOTIFICATION_A_SCENARIO_DELVE_FULLY_COM"]             = "Show notification when a scenario or Delve is fully completed."
L["OPTIONS_CORE_OBJECTIVE_LINE"]                                      = "Show objective line only."
L["OPTIONS_CORE_HOVER"]                                               = "Show only on hover."
L["OPTIONS_CORE_ACTIVE_INSTANCE_SECTION"]                             = "Show only the active instance section."
L["OPTIONS_CORE_OPTIONAL_REAGENT_SLOTS"]                              = "Show optional reagent slots."
L["OPTIONS_CORE_QUALITY_TIER_PIPS_RECIPES_SUPPORT_QUALITI"]           = "Show quality tier pips for recipes that support qualities."
L["OPTIONS_CORE_REAGENT_SHOPPING_LIST_RECIPE"]                        = "Show reagent shopping list for each recipe."
L["OPTIONS_CORE_RECENT_PROGRESS_TOP"]                                 = "Show recent progress at the top."
L["OPTIONS_CORE_RECIPE_ICON_NEXT_TITLE_REQUIRES_QUEST"]               = "Show recipe icon next to title. Requires quest type icons in Display."
L["OPTIONS_CORE_SECTION_DIVIDERS"]                                    = "Show section dividers"
L["OPTIONS_CORE_M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]                 = "Show the M+ block whenever an active keystone is running."
L["OPTIONS_CORE_TRACKED_PROFESSION_RECIPES_LIST"]                     = "Show tracked profession recipes in the list."
L["OPTIONS_CORE_TRACKER_HEROIC_DUNGEONS_UNSET_MAS"]                   = "Show tracker in Heroic dungeons. When unset, uses the master dungeon toggle."
L["OPTIONS_CORE_TRACKER_HEROIC_RAIDS_UNSET_MASTER"]                   = "Show tracker in Heroic raids. When unset, uses the master raid toggle."
L["OPTIONS_CORE_TRACKER_LOOKING_RAID_UNSET_MA"]                       = "Show tracker in Looking for Raid. When unset, uses the master raid toggle."
L["OPTIONS_CORE_TRACKER_MYTHIC_KEYSTONE_M_DUNGEONS_UNSET"]            = "Show tracker in Mythic Keystone (M+) dungeons. When unset, uses the master dungeon toggle."
L["OPTIONS_CORE_TRACKER_MYTHIC_DUNGEONS_UNSET_MAS"]                   = "Show tracker in Mythic dungeons. When unset, uses the master dungeon toggle."
L["OPTIONS_CORE_TRACKER_MYTHIC_RAIDS_UNSET_MASTER"]                   = "Show tracker in Mythic raids. When unset, uses the master raid toggle."
L["OPTIONS_CORE_TRACKER_NORMAL_DUNGEONS_UNSET_MAS"]                   = "Show tracker in Normal dungeons. When unset, uses the master dungeon toggle."
L["OPTIONS_CORE_TRACKER_NORMAL_RAIDS_UNSET_MASTER"]                   = "Show tracker in Normal raids. When unset, uses the master raid toggle."
L["OPTIONS_CORE_TRACKER_PARTY_DUNGEONS_MASTER_TOGGLE_DU"]             = "Show tracker in party dungeons (master toggle for all dungeon difficulties)."
L["OPTIONS_CORE_TRACKER_RAIDS_MASTER_TOGGLE_RAID_DIFFIC"]             = "Show tracker in raids (master toggle for all raid difficulties)."
L["OPTIONS_CORE_UNMET_CRAFTING_STATION_REQUIREMENTS"]                 = "Show unmet crafting station requirements."
L["OPTIONS_CORE_SHOWN_HOVERING_A_MOUNTED_PLAYER"]                     = "Shown when hovering a mounted player."
L["OPTIONS_CORE_SIZE_SHAPE"]                                          = "Size & shape"
L["OPTIONS_CORE_SIZE_OF_ZOOM_BUTTONS_PIXELS"]                         = "Size of the + and - zoom buttons (pixels)."
L["OPTIONS_CORE_SORT_MODE"]                                           = "Sort mode"
L["OPTIONS_CORE_SORTING_FILTERING"]                                   = "Sorting & Filtering"
L["OPTIONS_CORE_SOUND_PLAYED_A_RARE_BOSS_APPEARS"]                    = "Sound played when a rare boss appears."
L["OPTIONS_CORE_STATUS_BADGES"]                                       = "Status badges"
L["OPTIONS_CORE_SUBZONE_CHANGES"]                                     = "Subzone changes"
L["OPTIONS_CORE_SUPER_TRACKED_FIRST_CURRENT_ZONE_FIRST"]              = "Super-tracked first, or current zone first."
L["OPTIONS_CORE_SUPPRESS_IN_ARENA_DETAIL"]                            = "Suppress all Presence notifications while inside a PvP arena."
L["OPTIONS_CORE_SUPPRESS_PRESENCE_NOTIFICATIONS_WHILE_INSIDE_A"]      = "Suppress all Presence notifications while inside a battleground."
L["OPTIONS_CORE_SUPPRESS_IN_DUNGEON_DETAIL"]                          = "Suppress all Presence notifications while inside a dungeon (except boss emotes, achievements, level-up)."
L["OPTIONS_CORE_SUPPRESS_IN_RAID_DETAIL"]                             = "Suppress all Presence notifications while inside a raid."
L["OPTIONS_CORE_SUPPRESS_M"]                                          = "Suppress in M+"
L["OPTIONS_CORE_SUPPRESS_PVP"]                                        = "Suppress in PvP"
L["OPTIONS_CORE_SUPPRESS_BATTLEGROUND"]                               = "Suppress in battleground"
L["OPTIONS_CORE_SUPPRESS_DUNGEON"]                                    = "Suppress in dungeon"
L["OPTIONS_CORE_SUPPRESS_RAID"]                                       = "Suppress in raid"
L["OPTIONS_CORE_SUPPRESS_NOTIFICATIONS_DUNGEONS"]                     = "Suppress notifications in dungeons."
L["OPTIONS_CORE_TAKES_PRIORITY_SUPPRESS_UNTIL_RELOAD_ACCEPTING"]      = "Takes priority over suppress-until-reload. Accepting removes from blacklist."
L["OPTIONS_CORE_TOAST_ICONS"]                                         = "Toast icons"
L["OPTIONS_CORE_TOGGLE_TRACKING_WORLD_QUESTS_RARES_ACHIEVEMENTS"]     = "Toggle tracking for world quests, rares, achievements, and more."
L["OPTIONS_CORE_TOMTOM"]                                              = "TomTom"
L["OPTIONS_CORE_TOOLTIP_ANCHOR"]                                      = "Tooltip anchor"
L["OPTIONS_CORE_TRACKED_OBJECTIVES_ADVENTURE_GUIDE"]                  = "Tracked objectives from Adventure Guide."
L["OPTIONS_CORE_TRACKED_VS_LOG_COUNT"]                                = "Tracked vs in-log count."
L["OPTIONS_CORE_TRACKED_LOG_LOG_MAX_TRACKED_EXCLUDES"]                = "Tracked/in-log or in-log/max. Tracked excludes world and in-zone quests."
L["OPTIONS_CORE_TRANSMOG_STATUS"]                                     = "Transmog status"
L["OPTIONS_CORE_TRAVELER_S_LOG"]                                      = "Traveler's Log"
L["OPTIONS_CORE_TUNE_SLIDE_FADE_EFFECTS_PLUS_OBJECTIVE"]              = "Tune slide and fade effects, plus objective progress flashes."
L["OPTIONS_CORE_UNBLOCK"]                                             = "Unblock"
L["OPTIONS_CORE_UNTRACK_COMPLETE"]                                    = "Untrack when complete"
L["OPTIONS_CORE_CHECKMARK_COMPLETED_OBJECTIVES"]                      = "Use checkmark for completed objectives."
L["OPTIONS_CORE_VISIBILITY_FADING"]                                   = "Visibility & fading"
L["OPTIONS_CORE_COMPLETED_QUESTS_STAY_THEIR_ORIGINAL_CATEGO"]         = "When off, completed quests stay in their original category."
L["OPTIONS_CORE_ZONE_QUESTS_APPEAR_THEIR_NORMAL_CATEGORY"]            = "When off, in-zone quests appear in their normal category."
L["OPTIONS_CORE_THEY_MOVE_COMPLETE_SECTION"]                          = "When off, they move to the Complete section."
L["OPTIONS_CORE_CUSTOM_FILL_COLOR_BELOW"]                             = "When off, uses the custom fill color below."
L["OPTIONS_CORE_COMPLETED_OBJECTIVES_COLOR_BELOW"]                    = "When on, completed objectives use the color below."
L["OPTIONS_CORE_WHERE_COUNTDOWN"]                                     = "Where to show the countdown."
L["OPTIONS_CORE_WORLD_QUEST_ACCEPT"]                                  = "World quest accept"
L["OPTIONS_CORE_WORLD_QUEST_COMPLETE"]                                = "World quest complete"
L["OPTIONS_CORE_X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]              = "X/Y: objectives like 3/10. Percent: objectives like 45%%."
L["OPTIONS_CORE_ZONE_ENTRY"]                                          = "Zone entry"
L["OPTIONS_CORE_ZONE_LABELS"]                                         = "Zone labels"
L["OPTIONS_CORE_ZONE_NAME_STILL_APPEARS_ENTERING_A"]                  = "Zone name still appears when entering a new zone."
L["OPTIONS_CORE_ZONE_TYPE_COLORING"]                                  = "Zone type coloring"
L["OPTIONS_CORE_TINTERFACE_BUTTONS_UI_CHECKBOX_CHECK_T"]              = "|TInterface\\\\Buttons\\\\UI-CheckBox-Check:12:12:0:0|t instead of green for done objectives."


















































































