--[[
    Horizon Suite — English (enUS) source strings
    Symbolic keys; other locales override via metatable chain.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = addon.L

-- =====================================================================
-- Branding — Horizon Suite, module names, and third-party brand names
-- Never user copy; these are product/brand identifiers only.
-- =====================================================================
L["NAME_ADDON"]                                               = "Horizon Suite"
L["NAME_ADDON_OBJECTIVES"]                                    = "Focus"
L["NAME_ADDON_TOASTS"]                                        = "Presence"
L["NAME_ADDON_MINIMAP"]                                       = "Vista"
L["NAME_ADDON_TOOLTIPS"]                                      = "Insight"
L["NAME_ADDON_CHARACTER"]                                     = "Essence"
L["NAME_ADDON_LOOT"]                                          = "Cache"
L["NAME_ADDON_DASHBOARD"]                                     = "Axis"
L["NAME_DISCORD"]                                             = "Discord"
L["NAME_KO_FI"]                                               = "Ko-fi"
L["NAME_PATREON"]                                             = "Patreon"
L["NAME_GITHUB"]                                              = "GitHub"
L["NAME_CURSEFORGE"]                                          = "CurseForge"
L["NAME_WAGO"]                                                = "Wago"
L["NAME_TOMTOM"]                                              = "TomTom"
L["OTHER"]                                                    = "Other"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["QUEST_TYPES"]                                              = "Quest types"
L["ELEMENT_OVERRIDES"]                                        = "Element overrides"
L["PER_CATEGORY"]                                             = "Per category"
L["GROUPING_OVERRIDES"]                                       = "Grouping Overrides"
L["SECTION_OVERRIDES"]                                        = "Section Overrides"
L["OTHER_COLOURS"]                                            = "Other colours"

-- =====================================================================
-- OptionsPanel.lua — Colour row labels (collapsible group sub-rows)
-- =====================================================================
L["FOCUS_SECTION"]                                            = "Section"
L["FOCUS_TITLE"]                                              = "Title"
L["FOCUS_ZONE"]                                               = "Zone"
L["FOCUS_OBJECTIVE"]                                          = "Objective"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["FOCUS_READY_TURN_OVERRIDES_BASE_COLOURS"]                  = "Ready to Turn In overrides base colours"
L["FOCUS_READY_TURN_COLOURS_QUESTS"]                          = "Ready to Turn In uses its colours for quests in that section."
L["FOCUS_CURRENT_ZONE_OVERRIDES_BASE_COLOURS"]                = "Current Zone overrides base colours"
L["FOCUS_CURRENT_ZONE_SECTION_COLOURS"]                       = "Current Zone uses its colours for quests in that section."
L["FOCUS_CURRENT_QUEST_OVERRIDES_BASE_COLOURS"]               = "Current Quest overrides base colours"
L["FOCUS_CURRENT_QUEST_SECTION_COLOURS"]                      = "Current Quest uses its colours for quests in that section."
L["FOCUS_DISTINCT_COLOUR_COMPLETED_OBJECTIVES"]               = "Use distinct colour for completed objectives"
L["FOCUS_COMPLETED_OBJECTIVES_COLOURS_CHANGE"]                = "When on, completed objectives (e.g. 1/1) use the colour below; when off, they use the same colour as incomplete objectives."
L["FOCUS_COMPLETED_OBJECTIVE"]                                = "Completed objective"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["FOCUS_RESET"]                                              = "Reset"
L["FOCUS_RESET_QUEST_TYPES"]                                  = "Reset quest types"
L["FOCUS_RESET_OVERRIDES"]                                    = "Reset overrides"
L["FOCUS_RESET_DEFAULTS"]                                     = "Reset all to defaults"
L["FOCUS_RESET_TO_DEFAULTS"]                                  = "Reset to defaults"
L["FOCUS_RESET_DEFAULT"]                                      = "Reset to default"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["FOCUS_SEARCH_SETTINGS"]                                    = "Search settings..."
L["SEARCH_FONTS"]                                             = "Search fonts..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["FOCUS_DRAG_RESIZE"]                                        = "Drag to resize"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
L["PROFILES"]                                                 = "Profiles"
L["MODULES"]                                                  = "Modules"
L["MODULE_TOGGLES"]                                           = "Module Toggles"
L["MODULE_PREVIEW_DISCLAIMER"]                                = "This module is currently in an early preview (alpha) state. Daily use is not advised due to bugs or unfinished functionality."
L["AXIS_MODULE_NAME_DISPLAY"]                                 = "Module name style"
L["AXIS_MODULE_NAME_DISPLAY_DESC"]                            = "How module names appear in the settings panel navigation and search filter."
L["AXIS_MODULE_NAME_HORIZON"]                                 = "Horizon"
L["AXIS_MODULE_NAME_SUBTITLE"]                                = "Subtitle"
L["AXIS_MODULE_NAME_SIMPLE"]                                  = "Simple"
L["MODULE_RELOAD_HINT"]                                       = "Reload the interface to finish applying module changes."
L["RELOAD_UI"]                                                = "Reload UI"

-- =====================================================================
-- options/dashboard/HomeWelcome.lua — First-run welcome
-- =====================================================================
L["DASH_WHATS_NEW"]                                           = "Patch Notes"
L["DASH_FULL_CHANGELOG"]                                      = "Full Changelog"
L["DASH_WHATS_NEW_UNREAD_SUFFIX"]                             = " (New!)"
L["DASH_PATCH_NOTES_HEAD_SUB"]                                = "Release history and recent changes"
L["DASH_PATCH_NOTES_EMPTY"]                                   = "No notes available."
L["DASH_WELCOME_TAB"]                                         = "Welcome"
L["DASH_NEWS_TAB"]                                            = "News"
L["DASH_SEARCH_TAB"]                                          = "Search"
L["DASH_SEARCH_HEAD_SUB"]                                     = "Find any setting quickly"
L["DASH_SEARCH_PLACEHOLDER"]                                  = "Search settings..."
L["DASH_SEARCH_EMPTY_HINT"]                                   = "Type at least two characters to search settings, modules, and options."
L["DASH_SEARCH_NO_RESULTS"]                                   = "No matching settings. Try different words."
L["DASH_SEARCH_FILTER_ALL"]                                   = "All"
L["DASH_SEARCH_FILTER_TOOLTIP"]                               = "Limit search to one module"
L["DASH_SEARCH_NO_RESULTS_IN_MODULE"]                         = "No matches in %s. Try All modules or different words."
L["DASH_NEWS_HEAD_SUB"]                                       = "Latest updates & community highlights"
L["DASH_NEWS_BADGE_NEW"]                                      = "New"
L["DASH_NEWS_BADGE_HIGHLIGHT"]                                = "Highlight"
L["DASH_NEWS_EYEBROW_FEATURE"]                                = "Feature Update"
L["DASH_NEWS_EYEBROW_COMMUNITY"]                              = "Community"
L["DASH_NEWS_EYEBROW_ROADMAP"]                                = "Roadmap"
L["DASH_NEWS_EYEBROW_GET_STARTED"]                            = "Get Started"
L["DASH_NEWS_CTA_OPEN_FOCUS"]                                 = "Open Focus settings"
L["DASH_NEWS_CTA_VIEW_ARTIST"]                                = "View artist link"
L["DASH_NEWS_CTA_OPEN_PATCH_NOTES"]                           = "Open Patch Notes"
L["DASH_NEWS_EDITORIAL_FOOTER_PREFIX"]                        = "Axis • Coming Soon"
L["DASH_NEWS_EDITORIAL_FOOTER_LINK"]                          = "Patch notes"
L["DASH_NEWS_CTA_OPEN_GUIDE"]                                 = "Open Quick Start"
L["DASH_NEWS_FOCUS_CLICK_PROFILE_TITLE"]                      = "Dashboard Horizon+ and Custom click profiles join Blizzard+"
L["DASH_NEWS_FOCUS_CLICK_PROFILE_TAGLINE"]                    = "Choose how quest rows respond to clicks—familiar Blizzard behaviour, Horizon shortcuts, or your own combo map."
L["DASH_NEWS_FOCUS_CLICK_PROFILE_BODY"]                       = "Blizzard+ stays the default for a classic feel. Horizon+ leans on super-track and quick shortcuts, and Custom lets you tune each combo. Open |cffaaaaaaFocus > Click Options|r and set |cffaaaaaaClick profile|r to the style you want."
L["DASH_NEWS_FOCUS_CLICK_PROFILE_META"]                       = "Focus • Click Options • Available now"
L["DASH_NEWS_GRADIENT_TOOLTIPS_TITLE"]                        = "Gradient Tooltip Fonts, Dynamic Focus Tooltips, a New! Indicator, and Module Name Options"
L["DASH_NEWS_GRADIENT_TOOLTIPS_TAGLINE"]                      = "Surprise! Customise your Insight tooltips with gradient font based on class-style character names and item quality. Highlight newly implemented features with a New! indicator, and experience dynamic tooltips in Focus that intelligently shift their anchor left or right based on screen position."
L["DASH_NEWS_GRADIENT_TOOLTIPS_BODY"]                         = "Additionally, we've introduced a new |cffaaaaaaAxis > Module Name Style|r setting, allowing you to choose how module names are displayed: Horizon (code-name only, default), Subtitle (e.g., Vista – Minimap), or Simple/Simple (simplified, plain-language names)."
L["DASH_NEWS_GRADIENT_TOOLTIPS_META"]                         = "Insight • Dynamic Tooltips • Gradient Font • Available Now"
L["DASH_NEWS_CLASS_ICONS_TITLE"]                              = "A full Horizon class icon set is now bundled"
L["DASH_NEWS_CLASS_ICONS_BODY"]                               = "The Horizon class icon set is in the build and ready to use. Open |cffaaaaaaAxis > Global Settings > Class Colours|r and set |cffaaaaaaDashboard class icon style|r to Horizon (shown when dashboard class colours are on)."
L["DASH_NEWS_CLASS_ICONS_META"]                               = "Axis • Global Settings • Class Colours • Art by Gabriel C"
L["DASH_NEWS_COMING_SOON_TITLE"]                              = "Edit Mode will be joining soon"
L["DASH_NEWS_COMING_SOON_BODY"]                               = "We're lining up Horizon Suite with WoW's Edit Mode so you can place and arrange addon frames next to the rest of your HUD. For everything that has already shipped, |cffaaaaaaPatch Notes|r still has the full list."
L["DASH_NEWS_HANDHELD_TITLE"]                                 = "Handheld device support"
L["DASH_NEWS_HANDHELD_BODY"]                                  = "We're planning better support for smaller screens and handheld play: resize-friendly layouts, sensible defaults when the UI is scaled down, and fewer cramped panels. Details will land in |cffaaaaaaPatch Notes|r as pieces ship."
L["DASH_NEWS_COMING_SOON_META"]                               = "News hub • Editorial layout • Curated in addon"
L["DASH_NEWS_QUICK_START_TITLE"]                              = "Need the quick tour again?"
L["DASH_NEWS_QUICK_START_BODY"]                               = "Quick Start stays a useful companion to News: use it when you want a fast reminder of what each module does, where to enable it, and which pages are worth opening first after an update."
L["DASH_NEWS_QUICK_START_META"]                               = "Guide • Onboarding • Always available"
L["DASH_WELCOME_TITLE"]                                       = "Welcome to Horizon Suite"
L["DASH_WELCOME_HEAD_SUB"]                                    = "Get oriented, choose your modules, and learn where to start"
L["DASH_WELCOME_INTRO"]                                       = [=[Welcome to Horizon Suite — modular UI for your tracker, notifications, and more, built so you only run what you want. Turn features on or off under |cffaaaaaaAxis > Modules|r, use the guided overview below, and see what is new in |cffaaaaaaPatch Notes|r each release.]=]
L["DASH_WELCOME_HERO_EYEBROW"]                                = "Welcome"
L["DASH_WELCOME_HERO_TITLE"]                                  = "Craft your perfect UI, your way with Horizon Suite."
L["DASH_WELCOME_HERO_TAGLINE"]                                = "Shape Horizon around your playstyle with trackers, notifications, minimap, tooltips, and more without committing to a full UI overhaul."
L["DASH_WELCOME_HERO_BODY"]                                   = "Start simple. Choose the modules you want, then follow the guided overview below to see where everything lives. Patch Notes and News are always nearby when you need a quick update."
L["DASH_WELCOME_START_HERE"]                                  = "Start Here"
L["DASH_WELCOME_CTA_MODULES"]                                 = "Open Axis Modules"
L["DASH_WELCOME_CTA_PATCH_NOTES"]                             = "Open Patch Notes"
L["DASH_WELCOME_CTA_NEWS"]                                    = "Open News"
L["DASH_WELCOME_ACTION_MODULES_TITLE"]                        = "Pick your modules"
L["DASH_WELCOME_ACTION_MODULES_BODY"]                         = "Open |cffaaaaaaAxis > Modules|r to choose what Horizon loads—the tracker, notifications, tooltips, and the rest each toggle independently. Keep only the pieces you use, then press the reload button to apply your setup."
L["DASH_WELCOME_ACTION_UPDATES_TITLE"]                        = "See what's changed"
L["DASH_WELCOME_ACTION_UPDATES_BODY"]                         = "Something feels different about your favorite module? Check the Patch Notes menu to keep up to date with improvements, bug fixes, and module changes."
L["DASH_WELCOME_ACTION_NEWS_TITLE"]                           = "Explore highlights"
L["DASH_WELCOME_ACTION_NEWS_BODY"]                            = "Read about what's coming to Horizon Suite. Browse the News menu for featured updates, roadmap notes, community topics, and even critical issues. All in one place."
L["DASH_WELCOME_LEARN_BODY"]                                  = "Use this section as the |cffffffffguided overview|r of Horizon: what each module does, how to get started, and where to go next once the basics are in place."
L["DASH_WELCOME_PATH"]                                        = "%s > %s > %s"
L["DASH_WELCOME_FOCUS_BLIZZARD_PLUS_HEADING"]                 = "Blizzard+ click profile"
L["DASH_WELCOME_FOCUS_BLIZZARD_PLUS_BODY"]                    = [=[Focus uses |cffffffffBlizzard+|r by default — Blizzard-style quest row clicks with a few Horizon conveniences. Open |cffaaaaaaFocus > Click Options|r and use |cffaaaaaaClick profile|r to switch to |cffffffffHorizon+|r (super-track first) or |cffffffffCustom|r to set each shortcut yourself.]=]
L["DASH_WELCOME_COMING_SOON_TITLE"]                           = "Coming Soon"
L["DASH_WELCOME_COMING_SOON_TAGLINE"]                         = "New welcome experiences are on the way."
L["DASH_WELCOME_COMING_SOON_BODY"]                            = [=[Watch this space — we will post updates here and in |cffaaaaaaPatch Notes|r. Join |cffaaaaaaDiscord|r from the links below for news and feedback.]=]
L["DASH_WELCOME_CLASS_ICONS_HEADING"]                         = "New: Horizon class icons"
L["DASH_WELCOME_CLASS_ICONS_LEAD"]                            = [=[We have added a bundled set of custom class icons — now the default when you choose |cffaaaaaaHorizon|r for |cffaaaaaaDashboard class icon style|r under |cffaaaaaaAxis > Global Settings > Class Colours|r (when dashboard class colours are on).]=]
L["DASH_WELCOME_CLASS_ICONS_THANK_BOOFULS"]                   = [=[Thank you, Boofuls, for commissioning this art and helping bring these icons to everyone.]=]
L["DASH_WELCOME_CLASS_ICONS_CREATED_PREFIX"]                  = "• Created by "
L["DASH_WELCOME_CLASS_ICONS_ARTIST_NAME"]                     = "Gabriel C"
L["DASH_WELCOME_CONTRIBUTORS_HEADING"]                        = "Contributors"
L["DASH_WELCOME_CONTRIBUTORS_BODY"]                           = [=[Thanks to everyone who has contributed to Horizon Suite:

• Feanor — Development
• Marthix — Development
• Swift — Coordinator
• Boofuls — Moderator
• Diva — Innovator
• Rondo Media (CurseForge addon)
• Aishuu — French localisation (frFR)
• 아즈샤라-두녘 — Korean localisation (koKR)
• Linho-Gallywix — Brazilian Portuguese localisation (ptBR)
• allmoon — Chinese localisation (zhCN)]=]
L["DASH_WELCOME_SUPPORTERS_HEADING"]                          = "Supporters"
L["DASH_WELCOME_SUPPORTERS_BODY"]                             = [=[Thank you to everyone who supports Horizon Suite through Ko-fi, Patreon, and other channels.]=]
L["DASH_WELCOME_LOCALISATIONS_HEADING"]                       = "Localisations"
L["DASH_WELCOME_LOCALISATIONS_BODY"]                          = [=[The addon UI is localised for:

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
L["DASH_GUIDE_TAB"]                                           = "Quick Start"
L["DASH_GUIDE_HEAD_SUB"]                                      = "What each part of Horizon does"
L["DASH_GUIDE_HERO_TITLE"]                                    = "Getting started with Horizon Suite"
L["DASH_GUIDE_HERO_TAGLINE"]                                  = ""
L["DASH_GUIDE_HERO_INTRO"]                                    = "Pick the modules you want, tune them in the sidebar, and reload when you toggle something on or off. This guided overview stays on the Welcome tab whenever you need it."
L["DASH_GUIDE_HERO_THEME_PROMPT"]                             = [=[Under |cffaaaaaaAxis > Global Settings|r, set |cff73b4ff|Hhsdash:classcolours|hclass-colour tinting|h|r for the dashboard and modules, and pick a |cff73b4ff|Hhsdash:theme|hDashboard theme|h|r.]=]
L["DASH_GUIDE_HORIZON_HEADING"]                               = "Introduction to Modules"
L["DASH_GUIDE_HORIZON_BULLETS"]                               = [=[• Axis — Profiles, module on/off, global settings, typography, and other suite-wide settings.
• Focus — Quest and content tracker: quests, world quests, scenarios, rares, achievements, and more in coloured sections.
• Presence — Large cinematic toasts for zones, quests, scenarios, achievements, level up, and similar moments.
• Vista — Minimap chrome: zone text, coordinates, clock, and a collector for minimap buttons.
• Insight — Richer tooltips for players, NPCs, and items (class colours, spec, icons, extras).
• Cache — Loot toasts and bag presentation.
• Essence — Character sheet with 3D model, item level, stats, and gear grid.
• Meridian — Reserved; no options yet (see tag).]=]
L["DASH_GUIDE_MOD_AXIS_BODY"]                                 = "Axis is the control centre: switch profiles, enable or disable whole modules, open Global Settings for class colours and UI scale, and reach typography and appearance options that apply across Horizon. Start here when you first install or when you want a lighter footprint by turning modules off."
L["DASH_GUIDE_MOD_FOCUS_BODY"]                                = [=[Focus replaces the default objective list with a flexible tracker. Tracked quests, world quests, scenarios, rares, achievements, endeavors, decor, recipes, and more are grouped into coloured section headers so you can scan quickly.

Sections only appear when they have something to show — for example Current (recent progress), Current zone, Ready to turn in, World / weekly / daily / Prey, campaign and special quests, delves and scenarios, rare bosses and loot, achievements and collections, and time-limited or zone events.

Use Focus > Sorting & filtering to reorder sections, and Focus > Content to choose which types of content appear.]=]
L["DASH_GUIDE_PRESENCE_INTRO"]                                = "Presence shows large, styled alerts for moments that used to be separate Blizzard popups — zone changes, quest progress, achievements, scenarios, and more. You can turn each type on or off and tune typography in Presence settings."
L["DASH_GUIDE_PRESENCE_BODY"]                                 = [=[Typical Presence toasts include:

• Zone and subzone discovery text when you enter new areas.
• Quest accepted, objective progress, quest complete, and world quest complete.
• Scenario start, progress updates, and completion (including delve-style flow).
• Achievements earned and optional achievement progress ticks.
• Level up, boss emotes, and rare defeated.]=]
L["DASH_GUIDE_PRESENCE_BLIZZARD"]                             = [=[When a Presence type is enabled, Horizon can hide the matching default UI so you don’t get duplicates — for example zone name banners, the level-up frame, boss emote bar, event toast manager, world-quest completion banner, and some objective bonus banners. Turn a Presence type off in settings to let the default game UI show again for that category.]=]
L["DASH_GUIDE_MOD_VISTA_BODY"]                                = "Vista wraps your minimap with readable zone and subzone text, optional coordinates and clock, and a bar that collects stray minimap buttons so they stay tidy. Tune layout and colours under Vista in the sidebar."
L["DASH_GUIDE_MOD_INSIGHT_BODY"]                              = "Insight extends Blizzard tooltips for players, NPCs, and items — class and faction colouring, spec and icon lines, optional Mythic+ score, item level, mount collection hints, and cleaner separators. Each tooltip type has its own category under Insight."
L["DASH_GUIDE_MOD_CACHE_BODY"]                                = "Cache handles loot feedback: styled loot toasts for items, money, currency, and reputation, plus options that tie into how rewards are shown. Enable it when you want Horizon’s presentation instead of the default loot popups."
L["DASH_GUIDE_MOD_ESSENCE_BODY"]                              = "Essence is an optional character sheet: 3D model, item level, primary stats, and a gear grid so you can review your equipment at a glance. Open Essence in the sidebar to adjust layout and visibility."
L["DASH_GUIDE_MOD_MERIDIAN_BODY"]                             = [=[The exact feature set is still under wraps, so feel free to speculate what would feel right in Horizon. If you want to compare notes or help steer the idea, join |cffaaaaaaDiscord|r from the Community & Support links at the bottom of the dashboard and tell us what you would use it for.]=]
L["DASH_AXIS_MODULE_SHORT_DESCRIPTION"]                       = "Core settings hub: profiles, modules, and global settings."
L["DASH_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS"]               = "Objective tracker for quests, world quests, rares, achievements, scenarios."
L["DASH_ZONE_TEXT_AND_NOTIFICATIONS"]                         = "Zone text and notifications."
L["DASH_MINIMAP_ZONE_TEXT_COORDS_BUTTON"]                     = "Minimap with zone text, coords, time, and button collector."
L["DASH_TOOLTIPS_CLASS_COLOURS_SPEC_FACTION"]                 = "Tooltips with class colours, spec, and faction icons."
L["DASH_LOOT_TOASTS_ITEMS_MONEY_CURRENCY"]                    = "Loot toasts for items, money, currency, reputation, and bag overhaul."
L["DASH_ESSENCE_MODULE_SHORT_DESCRIPTION"]                    = "Custom character sheet with 3D model, item level, stats, and gear grid."
L["DASH_MERIDIAN_MODULE_SHORT_DESCRIPTION"]                   = "Compass-style waypoints and bearings for in-world guidance — in development."
L["DASH_WELCOME_COMMUNITY_HEADING"]                           = "Community & Support"
L["DASH_COPY_LINK_X"]                                         = "Copy link — %s"
L["HOME_HEAD_SUB"]                                            = "Enable and configure your modules"
L["HOME_MOD_FOCUS_SHORT"]                                     = "Quest and achievement objective tracker."
L["HOME_MOD_PRESENCE_SHORT"]                                  = "Cinematic zone text and notification toasts."
L["HOME_MOD_VISTA_SHORT"]                                     = "Custom minimap with zone line, time, and addon buttons."
L["HOME_MOD_INSIGHT_SHORT"]                                   = "Cinematic tooltips with class colours, spec, and faction."
L["HOME_MOD_CACHE_SHORT"]                                     = "Loot, currency, and reputation toasts."
L["HOME_MOD_ESSENCE_SHORT"]                                   = "Character panel with 3D model, item level, and gear."
L["DASH_RESIZE_TOOLTIP"]                                      = "Drag to resize\nRight-click to reset"
L["HOME_RELOAD_PROMPT"]                                       = "Reload to apply module changes."
L["RELOAD_UI"]                                                = "Reload UI"
L["DASH_LAYOUT"]                                              = "Layout"
L["DASH_VISIBILITY"]                                          = "Visibility"
L["DASH_DISPLAY"]                                             = "Display"
L["DASH_FEATURES"]                                            = "Features"
L["DASH_TYPOGRAPHY"]                                          = "Typography"
L["DASH_APPEARANCE"]                                          = "Appearance"
L["DASH_CLICK_OPTIONS"]                                       = "Click Options"
L["DASH_COLOURS"]                                             = "Colours"
L["DASH_ORGANISATION"]                                        = "Organisation"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["FOCUS_PANEL_BEHAVIOUR"]                                    = "Panel behaviour"
L["FOCUS_DIMENSIONS"]                                         = "Dimensions"
L["FOCUS_INSTANCE"]                                           = "Instance"
L["FOCUS_INSTANCES"]                                          = "Instances"
L["FOCUS_COMBAT"]                                             = "Combat"
L["FOCUS_FILTERING"]                                          = "Filtering"
L["FOCUS_HEADER"]                                             = "Header"
L["FOCUS_SECTIONS_STRUCTURE"]                                 = "Sections & structure"
L["FOCUS_ENTRY_DETAILS"]                                      = "Entry details"
L["FOCUS_PROGRESS_TIMERS"]                                    = "Progress & timers"
L["FOCUS_EMPHASIS"]                                           = "Focus emphasis"
L["FOCUS_LIST"]                                               = "List"
L["FOCUS_SPACING"]                                            = "Spacing"
L["FOCUS_RARE_BOSSES"]                                        = "Rare bosses"
L["FOCUS_WORLD_QUESTS"]                                       = "World quests"
L["FOCUS_FLOATING_QUEST_ITEM"]                                = "Floating quest item"
L["FOCUS_MYTHIC"]                                             = "Mythic+"
L["FOCUS_ACHIEVEMENTS"]                                       = "ACHIEVEMENTS"
L["FOCUS_ACHIEVEMENT_PROGRESS_BARS"]                          = "Achievement progress bars"
L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_DESC"]                     = "Show a progress bar under tracked achievements that report numeric criteria (including 0/1 and X/Y). Independent of Quest Progress Bars."
L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_TIP"]                      = "Uses the same bar colours, texture, and font as other Focus progress bars when those options are visible."
L["FOCUS_ENDEAVORS"]                                          = "ENDEAVORS"
L["FOCUS_DECOR"]                                              = "Decor"
L["FOCUS_APPEARANCES"]                                        = "Appearances"
L["FOCUS_SCENARIO_DELVE"]                                     = "Scenario & Delve"
L["FOCUS_FONT"]                                               = "Font"
L["FOCUS_FONT_FAMILIES"]                                      = "Font families"
L["FOCUS_GLOBAL_FONT_SIZE"]                                   = "Global font size"
L["FOCUS_FONT_SIZES"]                                         = "Font sizes"
L["FOCUS_PER_ELEMENT_FONTS"]                                  = "Per-element fonts"
L["FOCUS_TEXT_CASE"]                                          = "Text case"
L["FOCUS_SHADOW"]                                             = "Shadow"
L["FOCUS_PANEL"]                                              = "Panel"
L["FOCUS_HIGHLIGHT"]                                          = "Highlight"
L["FOCUS_COLOUR_MATRIX"]                                      = "Colour matrix"
L["FOCUS_ORDER"]                                              = "Focus order"
L["FOCUS_SORT"]                                               = "Sort"
L["FOCUS_BEHAVIOUR"]                                          = "Behaviour"
L["FOCUS_CONTENT_TYPES"]                                      = "Content Types"
L["FOCUS_DELVES"]                                             = "Delves"
L["FOCUS_DELVES_DUNGEONS"]                                    = "Delves & Dungeons"
L["FOCUS_DELVE_COMPLETE"]                                     = "Delve Complete"
L["FOCUS_INTERACTIONS"]                                       = "Interactions"
L["FOCUS_APPEARANCE_TAB_DESC"]                                = "Tracker panel look, fading, and list layout (header, sections, entries, timers, emphasis)."
L["FOCUS_CLICK_OPTIONS_TAB_DESC"]                             = "Click profile, per-combo actions, and optional safety toggles for the tracker."
L["FOCUS_INTERACTIONS_TAB_DESC"]                              = "Configure quest tracking rules and TomTom integration."
L["FOCUS_TRACKING"]                                           = "Tracking"
L["FOCUS_SCENARIO_BAR"]                                       = "Scenario Bar"

-- =====================================================================
-- OptionsData.lua Profiles
-- =====================================================================
L["AXIS_CURRENT_PROFILE"]                                     = "Current profile"
L["AXIS_SELECT_PROFILE_CURRENTLY"]                            = "Select the profile currently in use."
L["AXIS_GLOBAL_PROFILE_ACCOUNT_WIDE"]                         = "Use global profile (account-wide)"
L["AXIS_CHARACTERS_SAME_PROFILE"]                             = "All characters use the same profile."
L["AXIS_ENABLE_PER_SPECIALIZATION_PROFILES"]                  = "Enable per specialization profiles"
L["AXIS_PICK_DIFFERENT_PROFILES_PER_SPEC"]                    = "Pick different profiles per spec."
L["AXIS_SPECIALIZATION"]                                      = "Specialization"
L["AXIS_SHARING"]                                             = "Sharing"
L["AXIS_IMPORT_PROFILE"]                                      = "Import profile"
L["AXIS_IMPORT_STRING"]                                       = "Import string"
L["AXIS_EXPORT_PROFILE"]                                      = "Export profile"
L["AXIS_SELECT_A_PROFILE_EXPORT"]                             = "Select a profile to export."
L["AXIS_EXPORT_STRING"]                                       = "Export string"
L["AXIS_COPY_PROFILE"]                                        = "Copy from profile"
L["AXIS_SOURCE_PROFILE_COPYING"]                              = "Source profile for copying."
L["AXIS_COPY_SELECTED"]                                       = "Copy from selected"
L["AXIS_CREATE"]                                              = "Create"
L["AXIS_CREATE_PROFILE_DEFAULT_TEMPLATE"]                     = "Create new profile from Default template"
L["AXIS_CREATES_A_PROFILE_DEFAULT_SETTINGS"]                  = "Creates a new profile with all default settings."
L["AXIS_CREATES_A_PROFILE_COPIED_SELECTED_SOURC"]             = "Creates a new profile copied from the selected source profile."
L["AXIS_DELETE_PROFILE"]                                      = "Delete profile"
L["AXIS_SELECT_A_PROFILE_DELETE_CURRENT_DEFAULT"]             = "Select a profile to delete (current and Default not shown)."
L["AXIS_DELETE_SELECTED"]                                     = "Delete selected"
L["AXIS_DELETE_SELECTED_PROFILE"]                             = "Delete selected profile"
L["AXIS_DELETE"]                                              = "Delete"
L["AXIS_DELETES_SELECTED_PROFILE"]                            = "Deletes the selected profile."
L["AXIS_GLOBAL_PROFILE"]                                      = "Global profile"
L["AXIS_PER_SPEC_PROFILES"]                                   = "Per-spec profiles"

-- =====================================================================
-- OptionsData.lua Modules
-- =====================================================================
L["AXIS_ENABLE_FOCUS_MODULE"]                                 = "Enable Focus module"
L["AXIS_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS_R"]             = "Show the objective tracker for quests, world quests, rares, achievements, and scenarios."
L["AXIS_ENABLE_PRESENCE_MODULE"]                              = "Enable Presence module"
L["AXIS_CINEMATIC_ZONE_TEXT_NOTIFICATIONS_ZONE_CHANGES"]      = "Cinematic zone text and notifications (zone changes, level up, boss emotes, achievements, quest updates)."
L["AXIS_ENABLE_CACHE_MODULE"]                                 = "Enable Cache module"
L["AXIS_CINEMATIC_LOOT_NOTIFICATIONS_ITEMS_MONEY_CURRENCY"]   = "Cinematic loot notifications (items, money, currency, reputation)."
L["AXIS_ENABLE_VISTA_MODULE"]                                 = "Enable Vista module"
L["AXIS_CINEMATIC_SQUARE_MINIMAP_ZONE_TEXT_COORDINATES"]      = "Cinematic square minimap with zone text, coordinates, and button collector."
L["AXIS_MINIMAP_ZONE_TIME_COLLECTOR"]                         = "Cinematic square minimap with zone text, coordinates, time, and button collector."
L["AXIS_BETA"]                                                = "Beta"
L["AXIS_SCALING"]                                             = "Scaling"
L["AXIS_GLOBAL_TOGGLES"]                                      = "Global"
L["AXIS_DASHBOARD_SECTION"]                                   = "Dashboard"
L["AXIS_GLOBAL_MODULE_FONT_SECTION"]                          = "Global Module Font"
L["AXIS_GLOBAL_SCALE_SECTION"]                                = "Global Scale"
L["AXIS_MINIMAP_ICON_SECTION"]                                = "Minimap Icon"
L["AXIS_CLASS_THEME_SECTION"]                                 = "Class Theme"
L["AXIS_GLOBAL_CLASS_THEME"]                                  = "Global Class Theme"
L["AXIS_CLASS_THEME_DASHBOARD"]                               = "Dashboard"
L["AXIS_DASHBOARD_CLASS_ICON"]                                = "Dashboard Class Icon"
L["AXIS_DASHBOARD_CLASS_ICON_DESC"]                           = "Show a class icon on the Dashboard. Independent of class colour tinting and of the class background override."
L["AXIS_DASHBOARD_BG_CLASS_OVERRIDE"]                         = "Override Background to Class Background"
L["AXIS_DASHBOARD_BG_CLASS_OVERRIDE_DESC"]                    = "Replace the Dashboard background with a class-themed background. Independent of class colour tinting and of the class icon."
L["AXIS_PATCH_NOTES_SECTION"]                                 = "Patch notes"
L["AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN"]                      = "Show Patch Notes Popup After Update"
L["AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN_DESC"]                 = "When on, Axis opens to Patch Notes once after each new addon version. When off, a green dot appears on the Horizon minimap icon until you open Patch Notes."
L["AXIS_SUITE_WIDE_CLASS_COLOUR_TINTING_UI"]                  = "Dashboard background theme, class colour tinting, and UI scale (global or per module)."
L["AXIS_GLOBAL_UI_SCALE"]                                     = "Global UI scale"
L["AXIS_SCALE_SIZES_SPACINGS_FONTS_FACTOR"]                   = "Scale all sizes, spacings, and fonts by this factor (50–200%). Does not change your configured values."
L["AXIS_PER_MODULE_SCALING"]                                  = "Per-module scaling"
L["AXIS_OVERRIDE_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_FO"]         = "Override the global scale with individual sliders for each module."
L["AXIS_OVERRIDES_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_F"]         = "Overrides the global scale with individual sliders for Focus, Presence, Vista, etc."
L["AXIS_DOESN_T_CHANGE_YOUR_CONFIGURED_VALUES"]               = "Doesn't change your configured values, only the effective display scale."
L["FOCUS_SCALE"]                                              = "Focus scale"
L["AXIS_SCALE_FOCUS_OBJECTIVE_TRACKER"]                       = "Scale for the Focus objective tracker (50–200%)."
L["PRESENCE_SCALE"]                                           = "Presence scale"
L["AXIS_SCALE_PRESENCE_CINEMATIC_TEXT"]                       = "Scale for the Presence cinematic text (50–200%)."
L["VISTA_SCALE"]                                              = "Vista scale"
L["AXIS_SCALE_VISTA_MINIMAP_MODULE"]                          = "Scale for the Vista minimap module (50–200%)."
L["INSIGHT_SCALE"]                                            = "Insight scale"
L["AXIS_SCALE_INSIGHT_TOOLTIP_MODULE"]                        = "Scale for the Insight tooltip module (50–200%)."
L["CACHE_SCALE"]                                              = "Cache scale"
L["AXIS_SCALE_CACHE_LOOT_TOAST_MODULE"]                       = "Scale for the Cache loot toast module (50–200%)."
L["AXIS_ENABLE_HORIZON_INSIGHT_MODULE"]                       = "Enable Horizon Insight module"
L["AXIS_CINEMATIC_TOOLTIPS_CLASS_COLOURS_SPEC_DISPLAY"]       = "Cinematic tooltips with class colours, spec display, and faction icons."
L["AXIS_TOOLTIP_ANCHOR_MODE"]                                 = "Tooltip anchor mode"
L["AXIS_WHERE_TOOLTIPS_APPEAR_FOLLOW_CURSOR_FIXED"]           = "Where tooltips appear: follow cursor or fixed position."
L["AXIS_CURSOR"]                                              = "Cursor"
L["AXIS_FIXED"]                                               = "Fixed"
L["INSIGHT_CURSOR_SIDE"]                                      = "Cursor side"
L["INSIGHT_CURSOR_SIDE_DESC"]                                 = "Which side of the cursor the tooltip appears on."
L["INSIGHT_CURSOR_SIDE_CENTER"]                               = "Center"
L["INSIGHT_CURSOR_SIDE_LEFT"]                                 = "Left"
L["INSIGHT_CURSOR_SIDE_RIGHT"]                                = "Right"
L["AXIS_ANCHOR_MOVE"]                                         = "Show anchor to move"
L["AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITION"]                     = "Click to show or hide the anchor. Drag to set position, right-click to confirm."
L["AXIS_DRAGGABLE_FRAME_FIXED_TOOLTIP_POSITION_DESC"]         = "Show draggable frame to set fixed tooltip position. Drag, then right-click to confirm."
L["AXIS_RESET_TOOLTIP_POSITION"]                              = "Reset tooltip position"
L["AXIS_RESET_FIXED_POSITION_DEFAULT"]                        = "Reset fixed position to default."
L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED"]                           = "Dynamic position for Focus tooltips"
L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED_DESC"]                      = "When fixed anchor is on, Focus tracker tooltips still attach to the outer edge of the Horizon panel so they never cover the tracker."
L["INSIGHT_CURSOR_OFFSET_X"]                                  = "Cursor offset X"
L["INSIGHT_CURSOR_OFFSET_X_DESC"]                             = "Horizontal pixel offset from the cursor anchor position."
L["INSIGHT_CURSOR_OFFSET_Y"]                                  = "Cursor offset Y"
L["INSIGHT_CURSOR_OFFSET_Y_DESC"]                             = "Vertical pixel offset from the cursor anchor position."
L["AXIS_TOOLTIP_BACKGROUND_COLOUR"]                           = "Tooltip background colour"
L["AXIS_COLOUR_OF_TOOLTIP_BACKGROUND"]                        = "Colour of the tooltip background."
L["AXIS_TOOLTIP_BACKGROUND_OPACITY"]                          = "Tooltip background opacity"
L["AXIS_TOOLTIP_BG_OPACITY_PCT_DESC"]                         = "Tooltip background opacity (0–100%)."
L["AXIS_TOOLTIP_FONT"]                                        = "Tooltip font"
L["AXIS_FONT_FAMILY_TOOLTIP_TEXT"]                            = "Font family used for all tooltip text."
L["INSIGHT_BODY_SIZE"]                                        = "Body size"
L["INSIGHT_BODY_FONT_SIZE"]                                   = "Body font size."
L["INSIGHT_BADGES_SIZE"]                                      = "Badges size"
L["INSIGHT_BADGES_FONT_SIZE"]                                 = "Status badges font size."
L["INSIGHT_STATS_SIZE"]                                       = "Stats size"
L["INSIGHT_STATS_FONT_SIZE"]                                  = "M+ score, item level, and honor level font size."
L["INSIGHT_MOUNT_SIZE"]                                       = "Mount size"
L["INSIGHT_MOUNT_FONT_SIZE"]                                  = "Mount name, source, and ownership font size."
L["INSIGHT_MOUNT_OWNERSHIP_DISPLAY"]                          = "Mount collection indicator"
L["INSIGHT_MOUNT_OWNERSHIP_DISPLAY_DESC"]                     = "How to show whether you have collected the hovered player's mount."
L["INSIGHT_MOUNT_OWNERSHIP_TEXT"]                             = "Full text"
L["INSIGHT_MOUNT_OWNERSHIP_ICONS"]                            = "Tick / cross"
L["INSIGHT_MOUNT_OWNED"]                                      = "You own this mount"
L["INSIGHT_MOUNT_NOT_OWNED"]                                  = "You don't own this mount"
L["INSIGHT_TRANSMOG_SIZE"]                                    = "Transmog size"
L["INSIGHT_TRANSMOG_FONT_SIZE"]                               = "Item appearance status font size."
L["AXIS_TOOLTIPS"]                                            = "Tooltips"
L["INSIGHT_CATEGORY_GLOBAL"]                                  = "Global Tooltips"
L["INSIGHT_CATEGORY_GLOBAL_DESC"]                             = "Anchor, backdrop, font family, and display options shared across tooltip types."
L["INSIGHT_CATEGORY_PLAYER"]                                  = "Player Characters"
L["INSIGHT_CATEGORY_PLAYER_DESC"]                             = "Guild rank, titles, badges, PvP, ratings, gear, mount lines, icons, and section separators on player tooltips."
L["INSIGHT_CATEGORY_NPC"]                                     = "NPCs"
L["INSIGHT_CATEGORY_NPC_DESC"]                                = "Reaction colours, level line, icons, and font sizes for NPC tooltips."
L["INSIGHT_CATEGORY_ITEM"]                                    = "Items"
L["INSIGHT_CATEGORY_ITEM_DESC"]                               = "Item tooltip options such as transmog collection status."
L["INSIGHT_SECTION_IDENTITY"]                                 = "Identity"
L["INSIGHT_PLAYER_NAME_COLOUR"]                               = "Player name colour"
L["INSIGHT_PLAYER_NAME_COLOUR_DESC"]                          = "Colour for the player's name on the first tooltip line: faction (Alliance blue, Horde red) or class."
L["INSIGHT_PLAYER_NAME_COLOUR_FACTION"]                       = "Faction"
L["INSIGHT_PLAYER_NAME_COLOUR_CLASS"]                         = "Class"
L["INSIGHT_PLAYER_NAME_GRADIENT"]                             = "Class colour gradient"
L["INSIGHT_PLAYER_NAME_GRADIENT_DESC"]                        = "Render the player name as a two-stop gradient of their class colour (only applies when the name colour is set to Class)."
L["INSIGHT_SECTION_STATUS_PVP"]                               = "Status & PvP"
L["INSIGHT_SECTION_RATINGS_GEAR"]                             = "Ratings & gear"
L["INSIGHT_SPEC_ROLE"]                                        = "Spec icon & role"
L["INSIGHT_SPEC_ROLE_DESC"]                                   = "Show the player's specialization icon and role after inspecting them. Disable to stop Insight from calling NotifyInspect on mouseover."
L["INSIGHT_SECTION_MOUNT"]                                    = "Mount"
L["INSIGHT_SECTION_DISMISS"]                                  = "Unit tooltip dismiss"
L["INSIGHT_DISMISS_GRACE"]                                    = "Dismiss grace"
L["INSIGHT_DISMISS_GRACE_DESC"]                               = "How long to wait after the mouse leaves a unit before dismiss begins. This is separate from fade-out duration, which only runs after dismiss starts. Longer grace reduces flicker from brief cursor gaps."
L["INSIGHT_DISMISS_GRACE_INSTANT"]                            = "Instant"
L["INSIGHT_DISMISS_GRACE_DEFAULT"]                            = "Normal"
L["INSIGHT_DISMISS_GRACE_RELAXED"]                            = "Relaxed"
L["INSIGHT_SECTION_COMBAT"]                                   = "Combat"
L["INSIGHT_HIDE_IN_COMBAT"]                                   = "Hide tooltips in combat"
L["INSIGHT_HIDE_IN_COMBAT_DESC"]                              = "While in combat, close GameTooltip and other Insight-styled tooltip frames and block them from staying open. Applies only when the Insight module is enabled."
L["INSIGHT_FADE_OUT_SEC"]                                     = "Fade-out duration"
L["INSIGHT_FADE_OUT_SEC_DESC"]                                = "How long the unit tooltip takes to fade out after dismiss has started (not the delay before dismiss). Zero hides immediately with no fade. Applies to GameTooltip unit tips only."
L["INSIGHT_SECTION_ICONS_AND_SEPARATORS"]                     = "Icons & separators"
L["INSIGHT_SECTION_NPC_TOOLTIP"]                              = "NPC tooltip"
L["INSIGHT_SECTION_TRANSMOG"]                                 = "Transmog"
L["INSIGHT_NPC_PLACEHOLDER"]                                  = "NPC-specific options will appear here when available. Reaction colours and level lines still apply in-game."
L["INSIGHT_NPC_REACTION_BORDER"]                              = "Reaction border"
L["INSIGHT_NPC_REACTION_BORDER_DESC"]                         = "Tint the tooltip border to the NPC's faction reaction (hostile red, friendly green, neutral yellow)."
L["INSIGHT_NPC_REACTION_NAME"]                                = "Reaction name colour"
L["INSIGHT_NPC_REACTION_NAME_DESC"]                           = "Colour the NPC's name to match their faction reaction."
L["INSIGHT_NPC_LEVEL_LINE"]                                   = "Level line"
L["INSIGHT_NPC_LEVEL_LINE_DESC"]                              = "Show the NPC's level, classification (Elite, Rare, etc.), and creature type beneath their name."
L["INSIGHT_NPC_ICONS_DESC"]                                   = "Show an icon instead of '??' for NPCs with an unknown level."
L["INSIGHT_SECTION_ITEM_STYLING"]                             = "Item styling"
L["INSIGHT_ITEM_QUALITY_BORDER"]                              = "Quality border"
L["INSIGHT_ITEM_QUALITY_BORDER_DESC"]                         = "Tint the tooltip border to the item's quality colour (Uncommon green, Rare blue, Epic purple, etc.)."
L["INSIGHT_ITEM_NAME_GRADIENT"]                               = "Quality gradient name"
L["INSIGHT_ITEM_NAME_GRADIENT_DESC"]                          = "Render the item name as a two-stop gradient of its quality colour (Uncommon green, Rare blue, Epic purple, etc.)."
L["INSIGHT_ITEM_SECTION_SPACING"]                             = "Blank line before blocks"
L["INSIGHT_ITEM_SECTION_SPACING_DESC"]                        = "Insert a blank line before Insight blocks on item tooltips instead of a tinted separator line."
L["AXIS_ITEM_TOOLTIP"]                                        = "Item Tooltip"
L["AXIS_TRANSMOG_STATUS"]                                     = "Show transmog status"
L["AXIS_WHETHER_YOU_COLLECTED_APPEARANCE_OF_AN"]              = "Show whether you have collected the appearance of an item you hover over."
L["AXIS_PLAYER_TOOLTIP"]                                      = "Player Tooltip"
L["AXIS_GUILD_RANK"]                                          = "Show guild rank"
L["AXIS_APPEND_PLAYER_S_GUILD_RANK_NEXT"]                     = "Append the player's guild rank next to their guild name."
L["AXIS_MYTHIC_SCORE"]                                        = "Show Mythic+ score"
L["AXIS_PLAYER_S_CURRENT_SEASON_MYTHIC_SCORE"]                = "Show the player's current season Mythic+ score, colour-coded by tier."
L["AXIS_ITEM_LEVEL"]                                          = "Show item level"
L["AXIS_PLAYER_S_EQUIPPED_ITEM_LEVEL_AFTER"]                  = "Show the player's equipped item level after inspecting them."
L["AXIS_HONOR_LEVEL"]                                         = "Show honor level"
L["AXIS_PLAYER_S_PVP_HONOR_LEVEL_TOOLTIP"]                    = "Show the player's PvP honor level in the tooltip."
L["AXIS_PVP_TITLE"]                                           = "Show PvP title"
L["AXIS_PLAYER_S_PVP_TITLE_E_G"]                              = "Show the player's PvP title (e.g. Gladiator) in the tooltip."
L["AXIS_CHARACTER_TITLE"]                                     = "Character title"
L["AXIS_PLAYER_S_SELECTED_TITLE_ACHIEVEMENT_PVP"]             = "Show the player's selected title (achievement or PvP) in the name line."
L["AXIS_TITLE_COLOUR"]                                        = "Title colour"
L["AXIS_COLOUR_OF_CHARACTER_TITLE_PLAYER_TOOLTIP"]            = "Colour of the character title in the player tooltip name line."
L["AXIS_STATUS_BADGES"]                                       = "Show status badges"
L["AXIS_INLINE_BADGES_COMBAT_AFK_DND_PVP"]                    = "Show inline badges for combat, AFK, DND, PvP flag, party/raid membership, friends, and whether the player is targeting you."
L["AXIS_MOUNT_INFO"]                                          = "Show mount info"
L["AXIS_HOVERING_A_MOUNTED_PLAYER_THEIR_MOUNT"]               = "When hovering a mounted player, show their mount name, source, and whether you own it."
L["AXIS_BLANK_SEPARATOR"]                                     = "Blank separator"
L["AXIS_A_BLANK_LINE_INSTEAD_OF_DASHES"]                      = "Use a blank line instead of dashes between tooltip sections."
L["AXIS_ICONS"]                                               = "Show icons"
L["AXIS_CLASS_ICON_STYLE"]                                    = "Class icon style"
L["AXIS_DEFAULT_BLIZZARD_RONDOMEDIA_CLASS_ICONS_TH"]          = "Use Blizzard default, RondoMedia, or Horizon icons from this addon's media folder on the class/spec line."
L["AXIS_CUSTOM_CLASS_ICONS_LABEL"]                            = "Horizon"
L["AXIS_CLASS_ICON_SOURCES_TOOLTIP"]                          = "RondoMedia: https://www.curseforge.com/wow/addons/rondomedia — Horizon: bundled icons under media/CustomClassIcons/<CLASS>/<class lower>.tga (e.g. WARRIOR/warrior.tga); replace files and /reload to override."
L["AXIS_RONDOMEDIA_CLASS_ICONS_RONDOFERRARI_HTTPS_WWW"]       = "RondoMedia class icons by RondoFerrari — https://www.curseforge.com/wow/addons/rondomedia"
L["AXIS_DEFAULT"]                                             = "Default"
L["AXIS_FACTION_SPEC_MOUNT_MYTHIC_ICONS_TOOLTIPS"]            = "Show faction, spec, mount, and Mythic+ icons in tooltips."
L["AXIS_GENERAL"]                                             = "General"
L["AXIS_POSITION"]                                            = "Position"
L["AXIS_RESET_POSITION"]                                      = "Reset position"
L["AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"]                   = "Reset loot toast position to default."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["FOCUS_LOCK_POSITION"]                                      = "Lock position"
L["FOCUS_PREVENT_DRAGGING_TRACKER"]                           = "Prevent dragging the tracker."
L["FOCUS_GROW_UPWARD"]                                        = "Grow upward"
L["FOCUS_GROW_HEADER"]                                        = "Grow-up header"
L["FOCUS_GROWING_UPWARD_KEEP_HEADER_BOTTOM_TOP"]              = "When growing upward: keep header at bottom, or at top until collapsed."
L["FOCUS_HEADER_BOTTOM"]                                      = "Header at bottom"
L["FOCUS_HEADER_SLIDES_COLLAPSE"]                             = "Header slides on collapse"
L["FOCUS_ANCHOR_BOTTOM_LIST_GROWS_UPWARD"]                    = "Anchor at bottom so the list grows upward."
L["FOCUS_START_COLLAPSED"]                                    = "Start collapsed"
L["FOCUS_START_HEADER_SHOWN_UNTIL_YOU_EXPAND"]                = "Start with only the header shown until you expand."
L["FOCUS_ALIGN_CONTENT_RIGHT"]                                = "Align content right"
L["FOCUS_RIGHT_ALIGN_QUEST_TITLES_OBJECTIVES_WITHIN"]         = "Right-align quest titles and objectives within the panel."
L["FOCUS_PANEL_WIDTH"]                                        = "Panel width"
L["FOCUS_TRACKER_WIDTH_PIXELS"]                               = "Tracker width in pixels."
L["FOCUS_MAX_CONTENT_HEIGHT"]                                 = "Max content height"
L["FOCUS_MAX_HEIGHT_OF_SCROLLABLE_LIST_PIXELS"]               = "Max height of the scrollable list (pixels)."

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["FOCUS_ALWAYS_M_BLOCK"]                                     = "Always show M+ block"
L["FOCUS_M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]                = "Show the M+ block whenever an active keystone is running"
L["FOCUS_DUNGEON"]                                            = "Show in dungeon"
L["FOCUS_TRACKER_PARTY_DUNGEONS"]                             = "Show tracker in party dungeons."
L["FOCUS_RAID"]                                               = "Show in raid"
L["FOCUS_TRACKER_RAIDS"]                                      = "Show tracker in raids."
L["FOCUS_BATTLEGROUND"]                                       = "Show in battleground"
L["FOCUS_TRACKER_BATTLEGROUNDS"]                              = "Show tracker in battlegrounds."
L["FOCUS_ARENA"]                                              = "Show in arena"
L["FOCUS_TRACKER_ARENAS"]                                     = "Show tracker in arenas."
L["FOCUS_HIDE_COMBAT"]                                        = "Hide in combat"
L["FOCUS_HIDE_TRACKER_FLOATING_QUEST_ITEM_COMBAT"]            = "Hide tracker and floating quest item in combat."
L["FOCUS_COMBAT_VISIBILITY"]                                  = "Combat visibility"
L["FOCUS_TRACKER_BEHAVES_COMBAT_FADE_REDUC"]                  = "How the tracker behaves in combat: show, fade to reduced opacity, or hide."
L["FOCUS_SHOW"]                                               = "Show"
L["FOCUS_FADE"]                                               = "Fade"
L["FOCUS_HIDE"]                                               = "Hide"
L["FOCUS_COMBAT_FADE_OPACITY"]                                = "Combat fade opacity"
L["FOCUS_VISIBLE_TRACKER_FADED_COMBAT"]                       = "How visible the tracker is when faded in combat (0 = invisible). Only applies when Combat visibility is Fade."
L["FOCUS_MOUSEOVER"]                                          = "Mouseover"
L["FOCUS_SHOW_ONLY_MOUSEOVER"]                                = "Show only on mouseover"
L["FOCUS_FADE_TRACKER_HOVERING_MOVE_MOUSE"]                   = "Fade tracker when not hovering; move mouse over it to show."
L["FOCUS_FADED_OPACITY"]                                      = "Faded opacity"
L["FOCUS_VISIBLE_TRACKER_FADED_INVISIBLE"]                    = "How visible the tracker is when faded (0 = invisible)."
L["FOCUS_QUESTS_CURRENT_ZONE"]                                = "Only show quests in current zone"
L["FOCUS_HIDE_QUESTS_OUTSIDE_YOUR_CURRENT_ZONE"]              = "Hide quests outside your current zone."

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["FOCUS_QUEST_COUNT"]                                        = "Show quest count"
L["FOCUS_QUEST_COUNT_HEADER"]                                 = "Show quest count in header."
L["FOCUS_HEADER_COUNT_FORMAT"]                                = "Header count format"
L["FOCUS_TRACKED_LOG_LOG_MAX_SLOTS_TRACKED"]                  = "Tracked/in-log or in-log/max-slots. Tracked excludes world/live-in-zone quests."
L["FOCUS_HEADER_DIVIDER"]                                     = "Show header divider"
L["FOCUS_LINE_BELOW_HEADER"]                                  = "Show the line below the header."
L["FOCUS_HEADER_DIVIDER_COLOUR"]                              = "Header divider colour"
L["FOCUS_COLOUR_OF_LINE_BELOW_HEADER"]                        = "Colour of the line below the header."
L["FOCUS_SUPER_MINIMAL_MODE"]                                 = "Super-minimal mode"
L["FOCUS_HIDE_HEADER_A_PURE_TEXT_LIST"]                       = "Hide header for a pure text list."
L["FOCUS_OPTIONS_BUTTON"]                                     = "Show options button"
L["FOCUS_OPTIONS_BUTTON_TRACKER_HEADER"]                      = "Show the Options button in the tracker header."
L["FOCUS_HEADER_COLOUR"]                                      = "Header colour"
L["FOCUS_COLOUR_OF_OBJECTIVES_HEADER_TEXT"]                   = "Colour of the OBJECTIVES header text."
L["FOCUS_HEADER_HEIGHT"]                                      = "Header height"
L["FOCUS_HEIGHT_OF_HEADER_BAR_PIXELS"]                        = "Height of the header bar in pixels (18–48)."

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["FOCUS_SECTION_HEADERS"]                                    = "Show section headers"
L["FOCUS_CATEGORY_LABELS_ABOVE_GROUP"]                        = "Show category labels above each group."
L["FOCUS_CATEGORY_HEADERS_COLLAPSED"]                         = "Show category headers when collapsed"
L["FOCUS_KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED_CLICK"]       = "Keep section headers visible when collapsed; click to expand a category."
L["FOCUS_NEARBY_CURRENT_ZONE_GROUP"]                          = "Show Nearby (Current Zone) group"
L["FOCUS_ZONE_QUESTS_A_DEDICATED_CURRENT_ZONE"]               = "Show in-zone quests in a dedicated Current Zone section. When off, they appear in their normal category."
L["FOCUS_ZONE_LABELS"]                                        = "Show zone labels"
L["FOCUS_ZONE_NAME_UNDER_QUEST_TITLE"]                        = "Show zone name under each quest title."
L["FOCUS_ACTIVE_QUEST_HIGHLIGHT"]                             = "Active quest highlight"
L["FOCUS_FOCUSED_QUEST_HIGHLIGHTED"]                          = "How the focused quest is highlighted."
L["FOCUS_QUEST_ITEM_BUTTONS"]                                 = "Show quest item buttons"
L["FOCUS_USABLE_QUEST_ITEM_BUTTON_NEXT_QUEST"]                = "Show usable quest item button next to each quest."
L["FOCUS_TOOLTIPS_HOVER"]                                     = "Tooltips on hover"
L["FOCUS_TOOLTIPS_HOVERING_TRACKER_ENTRIES_ITE"]              = "Show tooltips when hovering over tracker entries, item buttons, and scenario blocks."
L["FOCUS_WOWHEAD_LINK_TOOLTIPS"]                              = "Show WoWhead link in tooltips"
L["FOCUS_A_TOOLTIP_SHOWN_ADD_A_LINK"]                         = "When a tooltip is shown, add a link to open the quest, achievement, or NPC on WoWhead."
L["FOCUS_VIEW_WOWHEAD"]                                       = "View on WoWhead"
L["FOCUS_WOWHEAD_ALT_CLICK_HINT"]                             = "Alt + Click"
L["FOCUS_WOWHEAD_HINT_LIST_SEPARATOR"]                        = " · "
L["FOCUS_WOWHEAD_TOOLTIP_HINT_FALLBACK"]                      = "Configure in Focus options"
L["FOCUS_COPY_LINK"]                                          = "Copy link"
L["FOCUS_COPY_URL_BELOW_CTRL_C_PASTE"]                        = "Copy the URL below (Ctrl+C) and paste in your browser."
L["FOCUS_OBJECTIVE_NUMBERS"]                                  = "Show objective numbers"
L["FOCUS_OBJECTIVE_PREFIX"]                                   = "Objective prefix"
L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS"]                  = "Colour objective progress numbers"
L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS_DESC"]             = "Tint the full X/Y token: normal colour at 0/n, gold while in progress, green when complete (numbers and slash)."
L["FOCUS_PREFIX_OBJECTIVE_A_NUMBER_HYPHEN"]                   = "Prefix each objective with a number or hyphen."
L["FOCUS_NUMBERS"]                                            = "Numbers (1. 2. 3.)"
L["FOCUS_HYPHENS"]                                            = "Hyphens (-)"
L["FOCUS_AFTER_SECTION_HEADER"]                               = "After section header"
L["FOCUS_BEFORE_SECTION_HEADER"]                              = "Before section header"
L["FOCUS_BELOW_HEADER"]                                       = "Below header"
L["FOCUS_INLINE_BELOW_TITLE"]                                 = "Inline below title"
L["FOCUS_PREFIX_OBJECTIVES"]                                  = "Prefix objectives with 1., 2., 3."
L["FOCUS_COMPLETED_COUNT"]                                    = "Show completed count"
L["FOCUS_X_Y_PROGRESS_QUEST_TITLE"]                           = "Show X/Y progress in quest title."
L["FOCUS_OBJECTIVE_PROGRESS_BAR"]                             = "Show objective progress bar"
L["FOCUS_A_PROGRESS_BAR_UNDER_OBJECTIVES_NUMER"]              = "Show a progress bar under objectives that have numeric progress (e.g. 3/250). Only applies to entries with a single arithmetic objective where the required amount is greater than 1."
L["FOCUS_CATEGORY_COLOUR_PROGRESS_BAR"]                       = "Use category colour for progress bar"
L["FOCUS_PROGRESS_BAR_MATCHES_QUEST_ACHIEVEME"]               = "When on, the progress bar matches the quest/achievement category colour. When off, uses the custom fill colour below."
L["FOCUS_PROGRESS_BAR_TEXTURE"]                               = "Progress bar texture"
L["FOCUS_PROGRESS_BAR_TYPES"]                                 = "Progress bar types"
L["FOCUS_TEXTURE_PROGRESS_BAR_FILL"]                          = "Texture for the progress bar fill."
L["FOCUS_TEXTURE_PROGRESS_BAR_FILL_SOLID_YOUR"]               = "Texture for the progress bar fill. Solid uses your chosen colours. SharedMedia addons add more options."
L["FOCUS_PROGRESS_BAR_X_Y_OBJECTIVES_PERCENT"]                = "Show progress bar for X/Y objectives, percent-only objectives, or both."
L["FOCUS_X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]             = "X/Y: objectives like 3/10. Percent: objectives like 45%."
L["FOCUS_X_Y"]                                                = "X/Y only"
L["FOCUS_PERCENT"]                                            = "Percent only"
L["FOCUS_TICK_COMPLETED_OBJECTIVES"]                          = "Use tick for completed objectives"
L["FOCUS_COMPLETED_OBJECTIVES_A_CHECKMARK_INSTEA"]            = "When on, completed objectives show a checkmark (✓) instead of green colour."
L["FOCUS_ENTRY_NUMBERS"]                                      = "Show entry numbers"
L["FOCUS_PREFIX_QUEST_TITLES_WITHIN_CATEGORY"]                = "Prefix quest titles with 1., 2., 3. within each category."
L["FOCUS_COMPLETED_OBJECTIVES"]                               = "Completed objectives"
L["FOCUS_MULTI_OBJECTIVE_QUESTS_DISPLAY_OBJECTIVES"]          = "For multi-objective quests, how to display objectives you've completed (e.g. 1/1)."
L["FOCUS_ALL"]                                                = "Show all"
L["FOCUS_FADE_COMPLETED"]                                     = "Fade completed"
L["FOCUS_HIDE_COMPLETED"]                                     = "Hide completed"
L["FOCUS_ICON_ZONE_AUTO_TRACKING"]                            = "Show icon for in-zone auto-tracking"
L["FOCUS_DISPLAY_AN_ICON_NEXT_AUTO_TRACKED"]                  = "Display an icon next to auto-tracked world quests and weeklies/dailies that are not yet in your quest log (in-zone only)."
L["FOCUS_AUTO_TRACK_ICON"]                                    = "Auto-track icon"
L["FOCUS_CHOOSE_WHICH_ICON_DISPLAY_NEXT_AUTO"]                = "Choose which icon to display next to auto-tracked in-zone entries."
L["FOCUS_APPEND_WORLD_QUESTS_WEEKLIES_DAILIES"]               = "Append ** to world quests and weeklies/dailies that are not yet in your quest log (in-zone only)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["FOCUS_COMPACT_MODE"]                                       = "Compact mode"
L["FOCUS_PRESET_SETS_ENTRY_OBJECTIVE_SPACING_P"]              = "Preset: sets entry and objective spacing to 4 and 1 px."
L["FOCUS_SPACING_PRESET"]                                     = "Spacing preset"
L["FOCUS_PRESET_ENTRY_OBJECTIVE_SPACING_DEFAULT_P"]           = "Preset for entry and objective spacing: Default (8/2 px), Compact (4/1 px), Spaced (12/3 px), or Custom (use sliders)."
L["FOCUS_COMPACT_VERSION"]                                    = "Compact version"
L["FOCUS_SPACED_VERSION"]                                     = "Spaced version"
L["FOCUS_SPACING_BETWEEN_QUEST_ENTRIES_PX"]                   = "Spacing between quest entries (px)"
L["FOCUS_VERTICAL_GAP_BETWEEN_QUEST_ENTRIES"]                 = "Vertical gap between quest entries."
L["FOCUS_SPACING_BEFORE_CATEGORY_HEADER_PX"]                  = "Spacing before category header (px)"
L["FOCUS_GAP_BETWEEN_LAST_ENTRY_OF_A"]                        = "Gap between last entry of a group and the next category label."
L["FOCUS_SPACING_AFTER_CATEGORY_HEADER_PX"]                   = "Spacing after category header (px)"
L["FOCUS_GAP_BETWEEN_CATEGORY_LABEL_FIRST_QUEST"]             = "Gap between category label and first quest entry below it."
L["FOCUS_SPACING_BETWEEN_OBJECTIVES_PX"]                      = "Spacing between objectives (px)"
L["FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVE_LINES_WITHIN"]        = "Vertical gap between objective lines within a quest."
L["FOCUS_TITLE_CONTENT"]                                      = "Title to content"
L["FOCUS_VERTICAL_GAP_BETWEEN_QUEST_TITLE_OBJECTIVES"]        = "Vertical gap between quest title and objectives or zone below it."
L["FOCUS_SPACING_BELOW_HEADER_PX"]                            = "Spacing below header (px)"
L["FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVES_BAR_QUES"]           = "Vertical gap between the objectives bar and the quest list."
L["FOCUS_RESET_SPACING"]                                      = "Reset spacing"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["FOCUS_SHOW_QUEST_LEVEL"]                                   = "Show quest level"
L["FOCUS_QUEST_LEVEL_NEXT_TITLE"]                             = "Show quest level next to title."
L["FOCUS_DIM_FOCUSED_QUESTS"]                                 = "Dim non-focused quests"
L["FOCUS_SLIGHTLY_DIM_TITLE_ZONE_OBJECTIVES_SECTION"]         = "Slightly dim title, zone, objectives, and section headers that are not focused."
L["FOCUS_DIM_UNFOCUSED_ENTRIES"]                              = "Dim unfocused entries"
L["FOCUS_CLICK_A_SECTION_HEADER_EXPAND_CATEGORY"]             = "Click a section header to expand that category."

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["UI_SHOW_RARE_BOSSES"]                                      = "Show rare bosses"
L["UI_RARE_BOSS_VIGNETTES_LIST"]                              = "Show rare boss vignettes in the list."
L["UI_RARE_LOOT"]                                             = "Rare Loot"
L["UI_TREASURE_ITEM_VIGNETTES_RARE_LOOT"]                     = "Show treasure and item vignettes in the Rare Loot list."
L["UI_RARE_SOUND_VOLUME"]                                     = "Rare sound volume"
L["UI_VOLUME_OF_RARE_ALERT_SOUND"]                            = "Volume of the rare alert sound (50–200%)."
L["UI_BOOST_REDUCE_RARE_ALERT_VOLUME"]                        = "Boost or reduce the rare alert volume. 100% = normal; 150% = louder."
L["UI_RARE_ADDED_SOUND"]                                      = "Rare added sound"
L["UI_PLAY_A_SOUND_A_RARE"]                                   = "Play a sound when a rare is added."
L["UI_MINIMAP_PATCH_NOTES_UNREAD_HINT"]                       = "New patch notes — open Axis and choose Patch Notes."

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["FOCUS_ZONE_WORLD_QUESTS"]                                  = "Show in-zone world quests"
L["FOCUS_AUTO_ADD_WORLD_QUESTS_YOUR_CURRENT"]                 = "Auto-add world quests in your current zone. When off, only quests you've tracked or world quests you're in close proximity to appear (Blizzard default)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["FOCUS_SHOW_FLOATING_QUEST_ITEM"]                           = "Show floating quest item"
L["FOCUS_QUICK_BUTTON_FOCUSED_QUEST_S_USABLE"]                = "Show quick-use button for the focused quest's usable item."
L["FOCUS_LOCK_FLOATING_QUEST_ITEM_POSITION"]                  = "Lock floating quest item position"
L["FOCUS_PREVENT_DRAGGING_FLOATING_QUEST_ITEM_BUTTON"]        = "Prevent dragging the floating quest item button."
L["FOCUS_FLOATING_QUEST_ITEM_SOURCE"]                         = "Floating quest item source"
L["FOCUS_WHICH_QUEST_S_ITEM_SUPER_TRACKED"]                   = "Which quest's item to show: super-tracked first, or current zone first."
L["FOCUS_SUPER_TRACKED_FIRST"]                                = "Super-tracked, then first"
L["FOCUS_CURRENT_ZONE_FIRST"]                                 = "Current zone first"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["FOCUS_MYTHIC_BLOCK"]                                       = "Show Mythic+ block"
L["FOCUS_TIMER_COMPLETION_AFFIXES_MYTHIC_DUNGEONS"]           = "Show timer, completion %, and affixes in Mythic+ dungeons."
L["FOCUS_M_BLOCK_POSITION"]                                   = "M+ block position"
L["FOCUS_POSITION_OF_MYTHIC_BLOCK_RELATIVE_QUEST"]            = "Position of the Mythic+ block relative to the quest list."
L["FOCUS_AFFIX_ICONS"]                                        = "Show affix icons"
L["FOCUS_AFFIX_ICONS_NEXT_MODIFIER_NAMES_M"]                  = "Show affix icons next to modifier names in the M+ block."
L["FOCUS_AFFIX_DESCRIPTIONS_TOOLTIP"]                         = "Show affix descriptions in tooltip"
L["FOCUS_AFFIX_DESCRIPTIONS_HOVERING_M_BLO"]                  = "Show affix descriptions when hovering over the M+ block."
L["FOCUS_M_COMPLETED_BOSS_DISPLAY"]                           = "M+ completed boss display"
L["FOCUS_DEFEATED_BOSSES_CHECKMARK_ICON_GREEN"]               = "How to show defeated bosses: checkmark icon or green colour."
L["FOCUS_CHECKMARK"]                                          = "Checkmark"
L["FOCUS_GREEN_COLOUR"]                                       = "Green colour"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["PRESENCE_ACHIEVEMENTS"]                                    = "Show achievements"
L["FOCUS_TRACKED_ACHIEVEMENTS_LIST"]                          = "Show tracked achievements in the list."
L["FOCUS_COMPLETED_ACHIEVEMENTS"]                             = "Show completed achievements"
L["FOCUS_INCLUDE_COMPLETED_ACHIEVEMENTS_TRACKER_O"]           = "Include completed achievements in the tracker. When off, only in-progress tracked achievements are shown."
L["FOCUS_ACHIEVEMENT_ICONS"]                                  = "Show achievement icons"
L["FOCUS_ACHIEVEMENT_S_ICON_NEXT_TITLE_REQUI"]                = "Show each achievement's icon next to the title. Requires 'Show quest type icons' in Display."
L["FOCUS_MISSING_REQUIREMENTS"]                               = "Only show missing requirements"
L["FOCUS_CRITERIA_YOU_HAVEN_T_COMPLETED_TR"]                  = "Show only criteria you haven't completed for each tracked achievement. When off, all criteria are shown."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["FOCUS_SHOW_ENDEAVORS"]                                     = "Show endeavors"
L["FOCUS_TRACKED_ENDEAVORS_PLAYER_HOUSING_LIST"]              = "Show tracked Endeavors (Player Housing) in the list."
L["FOCUS_COMPLETED_ENDEAVORS"]                                = "Show completed endeavors"
L["FOCUS_INCLUDE_COMPLETED_ENDEAVORS_TRACKER"]                = "Include completed Endeavors in the tracker. When off, only in-progress tracked Endeavors are shown."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["FOCUS_SHOW_DECOR"]                                         = "Show decor"
L["FOCUS_TRACKED_HOUSING_DECOR_LIST"]                         = "Show tracked housing decor in the list."
L["FOCUS_DECOR_ICONS"]                                        = "Show decor icons"
L["FOCUS_DECOR_ITEM_S_ICON_NEXT_TITLE"]                       = "Show each decor item's icon next to the title. Requires 'Show quest type icons' in Display."

-- =====================================================================
-- OptionsData.lua Features — Appearances
-- =====================================================================
L["FOCUS_SHOW_APPEARANCES"]                                   = "Show appearances"
L["FOCUS_TRACKED_TRANSMOG_APPEARANCES_LIST"]                  = "Show tracked transmog appearances in the list."
L["FOCUS_INCLUDE_COLLECTED_APPEARANCES_TRACKER"]              = "Include collected appearances in the tracker. When off, only appearances you have not yet collected are shown."
L["FOCUS_APPEARANCE_ICONS"]                                   = "Show appearance icons"
L["FOCUS_APPEARANCE_ICON_NEXT_TITLE"]                         = "Show each appearance's icon next to the title. Requires 'Show quest type icons' in Display."
L["FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON"]                  = "Use transmog list icon"
L["FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON_DESC"]             = "Use the in-game Appearances / transmog list icon for every row instead of each appearance's item icon. If that icon cannot be resolved, the item icon is used."
L["FOCUS_SHOW_APPEARANCE_WARDROBE"]                           = "Show wardrobe"
L["FOCUS_OPEN_APPEARANCES_COLLECTIONS"]                       = "Open Collections"
L["FOCUS_UNTRACK_APPEARANCE"]                                 = "Untrack appearance"
L["FOCUS_APPEARANCE_HORIZON_CONTROLS_HINT"]                   = "Horizon: Shift-click map; with TomTom waypoints enabled, that click also sets the arrow. Ctrl-click Collections, Alt-click dressing room. Right-click clears focus or untracks."

-- =====================================================================
-- OptionsData.lua Features — Adventure Guide
-- =====================================================================
L["FOCUS_ADVENTURE_GUIDE"]                                    = "Adventure Guide"
L["FOCUS_TRAVELER_S_LOG"]                                     = "Show Traveler's Log"
L["FOCUS_TRACKED_TRAVELER_S_LOG_OBJECTIVES_SHIFT"]            = "Show tracked Traveler's Log objectives (Shift+click in Adventure Guide) in the list."
L["FOCUS_AUTO_REMOVE_COMPLETED_ACTIVITIES"]                   = "Auto-remove completed activities"
L["FOCUS_AUTOMATICALLY_STOP_TRACKING_TRAVELER_S_LOG"]         = "Automatically stop tracking Traveler's Log activities once they have been completed."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["FOCUS_SCENARIO_EVENTS"]                                    = "Show scenario events"
L["FOCUS_ACTIVE_SCENARIO_DELVE_ACTIVITIES_DELVES_APP"]        = "Show active scenario and Delve activities. Delves appear in DELVES; other scenarios in SCENARIO EVENTS."
L["FOCUS_TRACK_DELVE_DUNGEON_SCENARIO_ACTIVITIES"]            = "Track Delve, Dungeon, and scenario activities."
L["FOCUS_DELVES_APPEAR_DELVES_SECTION_DUNGEONS_DUNGEON"]      = "Delves appear in Delves section; dungeons in Dungeon; other scenarios in Scenario Events."
L["FOCUS_DELVES_APPEAR_DELVES_SECTION_SCENARIOS"]             = "Delves appear in Delves section; other scenarios in Scenario Events."
L["FOCUS_DELVE_AFFIX_NAMES"]                                  = "Delve affix names"
L["FOCUS_DELVE_DUNGEON"]                                      = "Delve/Dungeon only"
L["FOCUS_SCENARIO_DEBUG_LOGGING"]                             = "Scenario debug logging"
L["FOCUS_LOG_SCENARIO_API_DATA_CHAT_H"]                       = "Log scenario API data to chat. Use /h debug focus scendebug to toggle."
L["FOCUS_PRINTS_C_SCENARIOINFO_CRITERIA_WIDGET_DATA"]         = "Prints C_ScenarioInfo criteria and widget data when in a scenario. Helps diagnose display issues like Abundance 46/300."
L["FOCUS_HIDE_CATEGORIES_DELVE_DUNGEON"]                      = "Hide other categories in Delve or Dungeon"
L["FOCUS_DELVES_PARTY_DUNGEONS_DELVE_DUNG"]                   = "In Delves or party dungeons, show only the Delve/Dungeon section."
L["FOCUS_DELVE_NAME_SECTION_HEADER"]                          = "Use delve name as section header"
L["FOCUS_A_DELVE_DELVE_NAME_TIER_AFFIXES"]                    = "When in a Delve, show the delve name, tier, and affixes as the section header instead of a separate banner. Disable to show the Delve block above the list."
L["FOCUS_AFFIX_NAMES_DELVES"]                                 = "Show affix names in Delves"
L["FOCUS_SEASON_AFFIX_NAMES_FIRST_DELVE_ENTRY"]               = "Show season affix names on the first Delve entry. Requires Blizzard's objective tracker widgets to be populated; may not show when using a full tracker replacement."
L["FOCUS_CINEMATIC_SCENARIO_BAR"]                             = "Cinematic scenario bar"
L["FOCUS_TIMER_PROGRESS_BAR_SCENARIO_ENTRIES"]                = "Show timer and progress bar for scenario entries."
L["FOCUS_TIMER"]                                              = "Show timer"
L["FOCUS_COUNTDOWN_TIMER_TIMED_QUESTS_EVENTS_SCEN"]           = "Show countdown timer on timed quests, events, and scenarios. When off, timers are hidden for all entry types."
L["FOCUS_TIMER_SCENARIOS"]                                    = "Scenarios"
L["FOCUS_TIMER_SCENARIOS_DESC"]                               = "Show countdown timer for scenario, delve, and dungeon tracker entries."
L["FOCUS_TIMER_WORLD"]                                        = "World Quests"
L["FOCUS_TIMER_WORLD_DESC"]                                   = "Show countdown timer for world quests and callings."
L["FOCUS_TIMER_QUEST_LOG"]                                    = "Dailies / Weeklies"
L["FOCUS_TIMER_QUEST_LOG_DESC"]                               = "Show countdown timer for dailies, weeklies, and other timed quest log entries."
L["FOCUS_TIMER_DISPLAY"]                                      = "Timer display"
L["FOCUS_COLOUR_TIMER_REMAINING"]                             = "Colour timer by remaining time"
L["FOCUS_GREEN_PLENTY_OF_LEFT_YELLOW_RUNNING"]                = "Green when plenty of time left, yellow when running low, red when critical."
L["FOCUS_WHERE_COUNTDOWN_BAR_BELOW_OBJECTIVES"]               = "Where to show the countdown: bar below objectives or text beside the quest name."
L["FOCUS_BAR_BELOW"]                                          = "Bar below"
L["FOCUS_INLINE_BESIDE_TITLE"]                                = "Inline beside title"

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["FOCUS_FONT_FAMILY"]                                        = "Font family."
L["FOCUS_TITLE_FONT"]                                         = "Title font"
L["VISTA_ZONE_FONT"]                                          = "Zone font"
L["FOCUS_OBJECTIVE_FONT"]                                     = "Objective font"
L["FOCUS_SECTION_FONT"]                                       = "Section font"
L["FOCUS_GLOBAL_FONT"]                                        = "Use global font"
L["FOCUS_FONT_FAMILY_QUEST_TITLES"]                           = "Font family for quest titles."
L["FOCUS_FONT_FAMILY_ZONE_LABELS"]                            = "Font family for zone labels."
L["FOCUS_FONT_FAMILY_OBJECTIVE_TEXT"]                         = "Font family for objective text."
L["FOCUS_FONT_FAMILY_SECTION_HEADERS"]                        = "Font family for section headers."
L["FOCUS_HEADER_SIZE"]                                        = "Header size"
L["FOCUS_HEADER_FONT_SIZE"]                                   = "Header font size."
L["FOCUS_TITLE_SIZE"]                                         = "Title size"
L["FOCUS_QUEST_TITLE_FONT_SIZE"]                              = "Quest title font size."
L["FOCUS_OBJECTIVE_SIZE"]                                     = "Objective size"
L["FOCUS_OBJECTIVE_TEXT_FONT_SIZE"]                           = "Objective text font size."
L["FOCUS_ZONE_SIZE"]                                          = "Zone size"
L["FOCUS_ZONE_LABEL_FONT_SIZE"]                               = "Zone label font size."
L["FOCUS_SECTION_SIZE"]                                       = "Section size"
L["FOCUS_SECTION_HEADER_FONT_SIZE"]                           = "Section header font size."
L["FOCUS_PROGRESS_BAR_FONT"]                                  = "Progress bar font"
L["FOCUS_FONT_FAMILY_PROGRESS_BAR_LABEL"]                     = "Font family for the progress bar label."
L["FOCUS_PROGRESS_BAR_TEXT_SIZE"]                             = "Progress bar text size"
L["FOCUS_FONT_SIZE_PROGRESS_BAR_LABEL_ADJUSTS"]               = "Font size for the progress bar label. Also adjusts bar height. Affects quest objectives, scenario progress, and scenario timer bars."
L["FOCUS_PROGRESS_BAR_FILL"]                                  = "Progress bar fill"
L["FOCUS_PROGRESS_BAR_TEXT"]                                  = "Progress bar text"
L["FOCUS_OUTLINE"]                                            = "Outline"
L["FOCUS_FONT_OUTLINE_STYLE"]                                 = "Font outline style."

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["FOCUS_HEADER_TEXT_CASE"]                                   = "Header text case"
L["FOCUS_DISPLAY_CASE_HEADER"]                                = "Display case for header."
L["FOCUS_SECTION_HEADER_CASE"]                                = "Section header case"
L["FOCUS_DISPLAY_CASE_CATEGORY_LABELS"]                       = "Display case for category labels."
L["FOCUS_QUEST_TITLE_CASE"]                                   = "Quest title case"
L["FOCUS_DISPLAY_CASE_QUEST_TITLES"]                          = "Display case for quest titles."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["FOCUS_TEXT_SHADOW"]                                        = "Show text shadow"
L["FOCUS_ENABLE_DROP_SHADOW_TEXT"]                            = "Enable drop shadow on text."
L["FOCUS_SHADOW_X"]                                           = "Shadow X"
L["FOCUS_HORIZONTAL_SHADOW_OFFSET"]                           = "Horizontal shadow offset."
L["FOCUS_SHADOW_Y"]                                           = "Shadow Y"
L["FOCUS_VERTICAL_SHADOW_OFFSET"]                             = "Vertical shadow offset."
L["FOCUS_SHADOW_ALPHA"]                                       = "Shadow alpha"
L["FOCUS_SHADOW_OPACITY"]                                     = "Shadow opacity (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["FOCUS_MYTHIC_TYPOGRAPHY"]                                  = "Mythic+ Typography"
L["FOCUS_DUNGEON_NAME_SIZE"]                                  = "Dungeon name size"
L["FOCUS_FONT_SIZE_DUNGEON_NAME_PX"]                          = "Font size for dungeon name (8–32 px)."
L["FOCUS_DUNGEON_NAME_COLOUR"]                                = "Dungeon name colour"
L["FOCUS_TEXT_COLOUR_DUNGEON_NAME"]                           = "Text colour for dungeon name."
L["FOCUS_TIMER_SIZE"]                                         = "Timer size"
L["FOCUS_FONT_SIZE_TIMER_PX"]                                 = "Font size for timer (8–32 px)."
L["FOCUS_TIMER_COLOUR"]                                       = "Timer colour"
L["FOCUS_TEXT_COLOUR_TIMER"]                                  = "Text colour for timer (in time)."
L["FOCUS_TIMER_OVERTIME_COLOUR"]                              = "Timer overtime colour"
L["FOCUS_TEXT_COLOUR_TIMER_LIMIT"]                            = "Text colour for timer when over the time limit."
L["FOCUS_PROGRESS_SIZE"]                                      = "Progress size"
L["FOCUS_FONT_SIZE_ENEMY_FORCES_PX"]                          = "Font size for enemy forces (8–32 px)."
L["FOCUS_PROGRESS_COLOUR"]                                    = "Progress colour"
L["FOCUS_TEXT_COLOUR_ENEMY_FORCES"]                           = "Text colour for enemy forces."
L["FOCUS_BAR_FILL_COLOUR"]                                    = "Bar fill colour"
L["FOCUS_PROGRESS_BAR_FILL_COLOUR_PROGRESS"]                  = "Progress bar fill colour (in progress)."
L["FOCUS_BAR_COMPLETE_COLOUR"]                                = "Bar complete colour"
L["FOCUS_PROGRESS_BAR_FILL_COLOUR_ENEMY_FORCES"]              = "Progress bar fill colour when enemy forces are at 100%."
L["FOCUS_AFFIX_SIZE"]                                         = "Affix size"
L["FOCUS_FONT_SIZE_AFFIXES_PX"]                               = "Font size for affixes (8–32 px)."
L["FOCUS_AFFIX_COLOUR"]                                       = "Affix colour"
L["FOCUS_TEXT_COLOUR_AFFIXES"]                                = "Text colour for affixes."
L["FOCUS_BOSS_SIZE"]                                          = "Boss size"
L["FOCUS_FONT_SIZE_BOSS_NAMES_PX"]                            = "Font size for boss names (8–32 px)."
L["FOCUS_BOSS_COLOUR"]                                        = "Boss colour"
L["FOCUS_TEXT_COLOUR_BOSS_NAMES"]                             = "Text colour for boss names."
L["FOCUS_RESET_MYTHIC_TYPOGRAPHY"]                            = "Reset Mythic+ typography"

-- =====================================================================
-- OptionsData.lua Appearance
-- =====================================================================
L["DASH_FRAME"]                                               = "Frame"
L["FOCUS_CLASS_COLOURS_DASHBOARD"]                            = "Class colours - Dashboard"
L["FOCUS_CLASS_COLOURS"]                                      = "Class Colours"
L["FOCUS_ENABLE_CLASS_COLOURS"]                               = "Enable all class colours"
L["DASH_CLASS_COLOURS_MODULES_GLOBAL"]                        = "Toggle class colours on or off for all modules at once."
L["FOCUS_DASHBOARD"]                                          = "Dashboard"
L["FOCUS_CLASS_COLOURS_DESC"]                                 = "Tint Focus header title, category section headers, main and between-section dividers, and super-tracked highlight bars and borders with your class colour."
L["PRESENCE_CLASS_COLOURS_DESC"]                              = "Tint Presence toast title and divider with your class colour."
L["VISTA_CLASS_COLOURS_DESC"]                                 = "Tint Vista minimap, addon-bar, and panel borders and text with your class colour."
L["INSIGHT_CLASS_COLOURS_DESC"]                               = "Use class colour for player tooltip name, class line, and border."
L["CACHE_CLASS_COLOURS_DESC"]                                 = "Tint Cache loot icon glow and edit/anchor borders with your class colour."
L["ESSENCE_CLASS_COLOURS_DESC"]                               = "Tint the character name on the Essence sheet with your class colour."
L["AXIS_CLASS_COLOURS_DESC"]                                  = "Tint dashboard accents, dividers, and highlights with your class colour."
L["DASH_THEME"]                                               = "Theme"
L["FOCUS_DASHBOARD_BACKGROUND"]                               = "Dashboard background"
L["DASH_BACKGROUND"]                                          = "Background style for the module dashboard window (Axis). Minimalistic is flat; themed presets use bundled full-bleed art; Specialisation (auto) uses the in-game talent UI background for your current specialization."
L["FOCUS_DASHBOARD_BACKGROUND_MINIMALISTIC"]                  = "Minimalistic"
L["FOCUS_DASHBOARD_BACKGROUND_MIDNIGHT"]                      = "Midnight"
L["FOCUS_DASHBOARD_BACKGROUND_TELDRASSIL_BURNS"]              = "Teldrassil"
L["FOCUS_DASHBOARD_BACKGROUND_NIGHTFAE"]                      = "Night Fae"
L["FOCUS_DASHBOARD_BACKGROUND_ARDENWEALD"]                    = "Ardenweald"
L["FOCUS_DASHBOARD_BACKGROUND_ZIN_AZSHARI"]                   = "Zin-Azshari"
L["FOCUS_DASHBOARD_BACKGROUND_SURAMAR_GARDEN"]                = "Suramar Garden"
L["DASH_BACKGROUND_QUEL_THALAS"]                              = "Quel'Thalas"
L["FOCUS_DASHBOARD_BACKGROUND_TWILIGHT_VINEYARDS"]            = "Twilight Vineyards"
L["FOCUS_DASHBOARD_BACKGROUND_ZUL_AMAN"]                      = "Zul'Aman"
L["FOCUS_DASHBOARD_BACKGROUND_ILLIDAN"]                       = "Illidan"
L["FOCUS_DASHBOARD_BACKGROUND_LICH_KING"]                     = "The Lich King"
L["FOCUS_DASHBOARD_BACKGROUND_TBC_ANNIVERSARY"]               = "TBC Anniversary"
L["FOCUS_DASHBOARD_BACKGROUND_BELEDARS_LIGHT"]                = "Beledar's Light"
L["FOCUS_DASHBOARD_BACKGROUND_CLASS_TALENTS"]                 = "Specialisation (auto)"
L["FOCUS_DASHBOARD_BACKGROUND_OPACITY"]                       = "Dashboard background opacity"
L["FOCUS_ADJUST_OPACITY_OF_DASHBOARD_BACKGROUND"]             = "Adjust the opacity of the dashboard background (50–100%). Lower values let more of the game world show through."
L["DASHBOARD_TYPO_SECTION"]                                   = "Dashboard text"
L["DASHBOARD_TYPO_FONT"]                                      = "Dashboard font"
L["DASHBOARD_TYPO_FONT_DESC"]                                 = "Font for the Axis settings window (sidebar, search, and option rows). Separate from the Focus tracker font. For CJK or mixed-script welcome text, pick a broad-coverage font (e.g. 2002) if needed."
L["DASHBOARD_TYPO_SIZE"]                                      = "Dashboard text size"
L["DASHBOARD_TYPO_SIZE_DESC"]                                 = "Nudge all dashboard text larger or smaller (−4 to +4), similar to Focus global font offset."
L["DASHBOARD_TYPO_OUTLINE"]                                   = "Dashboard text outline"
L["DASHBOARD_TYPO_OUTLINE_DESC"]                              = "0 = no outline, 1 = standard outline, 2 = thick outline. Applies to Axis dashboard text and option rows."
L["DASHBOARD_TYPO_SHADOW"]                                    = "Dashboard text shadow"
L["DASHBOARD_TYPO_SHADOW_DESC"]                               = "Drop shadow strength (0–100%). Higher makes the shadow more visible; 0 turns it off."
L["FOCUS_BACKDROP_OPACITY"]                                   = "Backdrop opacity"
L["FOCUS_PANEL_BACKGROUND_OPACITY"]                           = "Panel background opacity (0–1)."
L["FOCUS_BORDER"]                                             = "Show border"
L["FOCUS_BORDER_AROUND_TRACKER"]                              = "Show border around the tracker."
L["FOCUS_SCROLL_INDICATOR"]                                   = "Show scroll indicator"
L["FOCUS_A_VISUAL_HINT_LIST_CONTENT_TH"]                      = "Show a visual hint when the list has more content than is visible."
L["FOCUS_SCROLL_INDICATOR_STYLE"]                             = "Scroll indicator style"
L["FOCUS_CHOOSE_BETWEEN_A_FADE_GRADIENT_A"]                   = "Choose between a fade-out gradient or a small arrow to indicate scrollable content."
L["FOCUS_ARROW"]                                              = "Arrow"
L["FOCUS_HIGHLIGHT_ALPHA"]                                    = "Highlight alpha"
L["FOCUS_OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]                 = "Opacity of focused quest highlight (0–1)."
L["FOCUS_BAR_WIDTH"]                                          = "Bar width"
L["FOCUS_WIDTH_OF_BAR_STYLE_HIGHLIGHTS_PX"]                   = "Width of bar-style highlights (2–6 px)."

-- =====================================================================
-- OptionsData.lua Organisation
-- =====================================================================
L["FOCUS_ACTIVITY"]                                           = "Activity"
L["FOCUS_CONTENT"]                                            = "Content"
L["FOCUS_SORTING"]                                            = "Sorting"
L["FOCUS_ELEMENTS"]                                           = "Elements"
L["FOCUS_CATEGORY_ORDER"]                                     = "Category order"
L["FOCUS_CATEGORY_COLOUR_BAR"]                                = "Category colour for bar"
L["FOCUS_CHECKMARK_COMPLETED"]                                = "Checkmark for completed"
L["FOCUS_CURRENT_QUEST_CATEGORY"]                             = "Current Quest category"
L["FOCUS_CURRENT_QUEST_WINDOW"]                               = "Current Quest window"
L["FOCUS_QUESTS_RECENT_PROGRESS_TOP"]                         = "Show quests with recent progress at the top."
L["FOCUS_RECENT_QUEST_SECONDS"]                               = "Seconds of recent progress to show in Current Quest (30–120)."
L["FOCUS_QUEST_PROGRESSION_SECTION"]                          = "Quests you made progress on in the last minute appear in a dedicated section."
L["FOCUS_SHOW_ZONE_EVENTS"]                                   = "Events in Zone section"
L["FOCUS_SHOW_ZONE_EVENTS_DESC"]                              = "List nearby unaccepted quests and zone event quests in the Events in Zone section."
L["FOCUS_SHOW_ZONE_EVENTS_TIP"]                               = "When off, those quests are hidden from the tracker (similar to turning off world quests for content you have not accepted)."
L["FOCUS_CATEGORY_ORDER"]                                     = "Focus category order"
L["FOCUS_CATEGORIES_REORDER_EXCEPT_DELVES_SCENARIOS"]         = "Drag to reorder categories. DELVES and SCENARIO EVENTS stay first."
L["FOCUS_CATEGORIES_REORDER_EXCEPT_DELVES_SCENARIOS_TIP"]     = "Drag to reorder. Delves and Scenarios stay first."
L["FOCUS_SORT_MODE"]                                          = "Focus sort mode"
L["FOCUS_ENTRY_NUMBER_IN_CATEGORY"]                           = "Order of entries within each category."
L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS"]                         = "Auto-track accepted quests"
L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS_TIP"]                     = "When you accept a quest (quest log only, not world quests), add it to the tracker automatically."
L["FOCUS_CTRL_FOCUS_REMOVE"]                                  = "Require Ctrl for focus & remove"
L["FOCUS_CTRL_FOCUS_REMOVE_MOUSECLICK"]                       = "Require Ctrl for focus/add (Left) and unfocus/untrack (Right) to prevent misclicks."
L["FOCUS_CTRL_FOCUS_UNTRACK"]                                 = "Ctrl for focus / untrack"
L["FOCUS_CTRL_CLICK_COMPLETE"]                                = "Ctrl to click-complete"
L["FOCUS_CLASSIC_CLICK_BEHAVIOUR"]                            = "Use classic click behaviour"
L["FOCUS_CLASSIC_CLICKS"]                                     = "Classic clicks"
-- === Focus Click Profiles ===
L["FOCUS_CLICK_PROFILE"]                                      = "Click profile"
L["FOCUS_CLICK_PROFILE_DESC"]                                 = "Pick a preset or Custom. Presets show each shortcut below (locked); choose Custom to change them."
L["FOCUS_ICON_CLICK_ACTION"]                                  = "Icon Left Click"
L["FOCUS_ICON_CLICK_ACTION_DESC"]                             = "Choose what happens when you left-click the quest or appearance icon itself, when that icon click behavior is shown."
L["FOCUS_PROFILE_HORIZON_PLUS"]                               = "Horizon+"
L["FOCUS_PROFILE_BLIZZARD_DEFAULT"]                           = "Blizzard+"
L["FOCUS_PROFILE_CUSTOM"]                                     = "Custom"
L["FOCUS_COMING_SOON"]                                        = "Coming soon"
L["FOCUS_CLICK_COMBOS"]                                       = "Custom bindings"
L["FOCUS_CLICK_COMBO_LOCKED_TOOLTIP"]                         = "Fixed for this profile. Select Custom to edit shortcuts."
L["FOCUS_CLICK_SAFETY"]                                       = "Click safety"
L["FOCUS_COMBO_LEFT"]                                         = "Left click"
L["FOCUS_COMBO_SHIFT_LEFT"]                                   = "Shift + Left click"
L["FOCUS_COMBO_CTRL_LEFT"]                                    = "Ctrl + Left click"
L["FOCUS_COMBO_ALT_LEFT"]                                     = "Alt + Left click"
L["FOCUS_COMBO_RIGHT"]                                        = "Right click"
L["FOCUS_COMBO_SHIFT_RIGHT"]                                  = "Shift + Right click"
L["FOCUS_COMBO_CTRL_RIGHT"]                                   = "Ctrl + Right click"
L["FOCUS_COMBO_ALT_RIGHT"]                                    = "Alt + Right click"
L["FOCUS_CLICK_ACTION_NONE"]                                  = "Do nothing"
L["FOCUS_CLICK_ACTION_SUPER_TRACK"]                           = "Focus quest"
L["FOCUS_CLICK_ACTION_OPEN_DETAILS"]                          = "Open relevant details"
L["FOCUS_CLICK_ACTION_OPEN_PROFESSION"]                       = "Open relevant details"
L["FOCUS_CLICK_ACTION_OPEN_QUEST_LOG"]                        = "Open relevant details"
L["FOCUS_CLICK_ACTION_UNTRACK"]                               = "Untrack"
L["FOCUS_CLICK_ACTION_CONTEXT_MENU"]                          = "Context menu"
L["FOCUS_CLICK_ACTION_SHARE"]                                 = "Share with party"
L["FOCUS_CLICK_ACTION_ABANDON"]                               = "Abandon quest"
L["FOCUS_CLICK_ACTION_WOWHEAD"]                               = "WoWhead URL"
L["FOCUS_CLICK_ACTION_CHAT_LINK"]                             = "Link in chat"
L["FOCUS_CLICK_ACTION_PREVIEW"]                               = "Preview"
L["FOCUS_APPEARANCE_CANNOT_SHARE"]                            = "Appearances cannot be shared like quests."
L["FOCUS_QUEST_DETAILS_AFTER_COMBAT"]                         = "Quest details will open when you leave combat."
L["FOCUS_SHARE_PARTY"]                                        = "Share with party"
L["FOCUS_ABANDON_QUEST"]                                      = "Abandon quest"
L["FOCUS_CONTEXT_FOCUS_QUEST"]                                = "Focus quest"
L["FOCUS_STOP_TRACKING"]                                      = "Stop tracking"
L["FOCUS_CONTEXT_OPEN_ACHIEVEMENT"]                           = "Open achievement"
L["FOCUS_CONTEXT_OPEN_ENDEAVOR"]                              = "Open endeavor"
L["FOCUS_CONTEXT_OPEN_RECIPE"]                                = "Open recipe"
L["FOCUS_CONTEXT_OPEN_DECOR_CATALOG"]                         = "Open in catalog"
L["FOCUS_CONTEXT_PREVIEW_DECOR"]                              = "Preview decor"
L["FOCUS_CONTEXT_SHOW_DECOR_MAP"]                             = "Show on map"
L["FOCUS_CONTEXT_OPEN_TRAVELERS_LOG"]                         = "Open Traveler's Log"
L["FOCUS_CONTEXT_SET_RARE_WAYPOINT"]                          = "Set waypoint"
L["FOCUS_CONTEXT_CLEAR_RARE_FOCUS"]                           = "Clear map focus"
L["FOCUS_TRACKED_CONTENT_CANNOT_SHARE"]                       = "This entry cannot be shared with the party."
L["FOCUS_CANNOT_SHARE_QUEST"]                                 = "This quest cannot be shared."
L["FOCUS_REQUIRE_PARTY_SHARE"]                                = "You must be in a party to share this quest."
L["FOCUS_LEFT_CLICK_MAP_RIGHT_CLICK_ABANDON"]                 = "When on, left-click opens the quest map and right-click shows share/abandon menu (Blizzard-style). When off, left-click focuses and right-click untracks; Ctrl+Right shares with party."
L["FOCUS_ANIMATIONS"]                                         = "Animations"
L["FOCUS_SLIDE_FADE_QUESTS"]                                  = "Enable slide and fade for quests."
L["FOCUS_OBJECTIVE_PROGRESS_FLASH"]                           = "Objective progress flash"
L["FOCUS_FLASH_OBJECTIVE_COMPLETION"]                         = "Show flash when an objective completes."
L["FOCUS_FLASH_INTENSITY"]                                    = "Flash intensity"
L["FOCUS_OBJECTIVE_PROGRESS_FLASH_VISIBILITY"]                = "How noticeable the objective-complete flash is."
L["FOCUS_FLASH_COLOUR"]                                       = "Flash colour"
L["FOCUS_FLASH_COLOUR_DESC"]                                  = "Colour of the objective-complete flash."
L["FOCUS_SUBTLE"]                                             = "Subtle"
L["FOCUS_MEDIUM"]                                             = "Medium"
L["FOCUS_STRONG"]                                             = "Strong"
L["FOCUS_REQUIRE_CTRL_CLICK_COMPLETE"]                        = "Require Ctrl for click to complete"
L["FOCUS_REQUIRES_CTRL_LEFT_CLICK_COMPLETE_AUTO"]             = "When on, requires Ctrl+Left-click to complete auto-complete quests. When off, plain Left-click completes them (Blizzard default). Only affects quests that can be completed by click (no NPC turn-in needed)."
L["FOCUS_SUPPRESS_UNTRACKED_UNTIL_RELOAD"]                    = "Suppress untracked until reload"
L["FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS"]                   = "When on, right-click untrack on world quests and in-zone weeklies/dailies hides them until you reload or start a new session. When off, they reappear when you return to the zone."
L["FOCUS_PERMANENTLY_SUPPRESS_UNTRACKED_QUESTS"]              = "Permanently suppress untracked quests"
L["FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS_DESC"]              = "When on, right-click untracked world quests and in-zone weeklies/dailies are hidden permanently (persists across reloads). Takes priority over 'Suppress until reload'. Accepting a suppressed quest removes it from the blacklist."
L["FOCUS_KEEP_CAMPAIGN_CATEGORY"]                             = "Keep campaign quests in category"
L["FOCUS_CAMPAIGN_READY_STAY"]                                = "When on, campaign quests that are ready to turn in remain in the Campaign category instead of moving to Complete."
L["FOCUS_KEEP_IMPORTANT_QUESTS_CATEGORY"]                     = "Keep important quests in category"
L["FOCUS_IMPORTANT_READY_STAY"]                               = "When on, important quests that are ready to turn in remain in the Important category instead of moving to Complete."
L["FOCUS_TOMTOM_QUEST_WAYPOINT"]                              = "TomTom quest & appearance waypoint"
L["FOCUS_TOMTOM_QUEST_WAYPOINT_TIP"]                          = "Set a TomTom waypoint when focusing a quest or a tracked transmog appearance."
L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_NEXT_QUEST"]            = "Requires TomTom. Points the arrow to the next quest objective or the next step for a focused appearance."
L["FOCUS_TOMTOM_RARE_WAYPOINT"]                               = "TomTom rare waypoint"
L["FOCUS_TOMTOM_WAYPOINT_RARE_CLICK"]                         = "Set a TomTom waypoint when clicking a rare boss."
L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_RARE"]                  = "Requires TomTom. Points the arrow to the rare's location."
L["FOCUS_FIND_GROUP"]                                         = "Find a Group"
L["FOCUS_GROUP_QUEST_SEARCH_CLICK"]                           = "Click to search for a group for this quest."

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
L["FOCUS_BLACKLIST"]                                          = "Blacklist"
L["FOCUS_BLACKLIST_UNTRACKED"]                                = "Blacklist untracked"
L["FOCUS_ENABLE_BLACKLIST_UNTRACKED_BEHAVIOUR_ADD_QUEST"]     = "Enable 'Blacklist untracked' in Behaviour to add quests here."
L["FOCUS_HIDDEN_QUESTS"]                                      = "Hidden Quests"
L["FOCUS_QUESTS_HIDDEN_RIGHT_CLICK_UNTRACK"]                  = "Quests hidden via right-click untrack."
L["FOCUS_BLACKLISTED_QUESTS"]                                 = "Blacklisted quests"
L["FOCUS_PERMANENTLY_SUPPRESSED_QUESTS"]                      = "Permanently suppressed quests"
L["FOCUS_RIGHT_CLICK_UNTRACK_QUESTS_PERMANENTLY_SUPPRESS"]    = "Right-click untrack quests with 'Permanently suppress untracked quests' enabled to add them here."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["PRESENCE_QUEST_TYPE_ICONS"]                                = "Show quest type icons"
L["PRESENCE_QUEST_TYPE_ICON_FOCUS_TRACKER_QUEST"]             = "Show quest type icon in the Focus tracker (quest accept/complete, world quest, quest update)."
L["PRESENCE_QUEST_TYPE_ICONS_TOASTS"]                         = "Show quest type icons on toasts"
L["PRESENCE_QUEST_TYPE_ICON_PRESENCE_TOASTS_QUEST"]           = "Show quest type icon on Presence toasts (quest accept/complete, world quest, quest update)."
L["PRESENCE_TOAST_ICON_SIZE"]                                 = "Toast icon size"
L["PRESENCE_QUEST_ICON_SIZE_PRESENCE_TOASTS_PX"]              = "Quest icon size on Presence toasts (16–36 px). Default 24."
L["PRESENCE_HIDE_QUEST_UPDATE_TITLE"]                         = "Hide quest update title"
L["PRESENCE_OBJECTIVE_LINE_QUEST_PROGRESS_TOAST"]             = "Show only the objective line on quest progress toasts (e.g. 7/10 Boar Pelts), without the quest name or header."
L["PRESENCE_SHOW_DISCOVERY_LINE"]                             = "Show discovery line"
L["PRESENCE_DISCOVERY_LINE"]                                  = "Discovery line"
L["PRESENCE_SHOW_DISCOVERED"]                                 = "Show 'Discovered' under zone/subzone when entering a new area."
L["PRESENCE_FRAME_VERTICAL_POSITION"]                         = "Frame vertical position"
L["PRESENCE_VERTICAL_OFFSET_OF_PRESENCE_FRAME_CENTER"]        = "Vertical offset of the Presence frame from center (-300 to 0)."
L["PRESENCE_FRAME_SCALE"]                                     = "Frame scale"
L["PRESENCE_FRAME_SCALE_TIP"]                                 = "Scale of the Presence frame (0.5–2)."
L["PRESENCE_BOSS_EMOTE_COLOUR"]                               = "Boss emote colour"
L["PRESENCE_COLOUR_RAID_DUNGEON_BOSS_EMOTE"]                  = "Colour of raid and dungeon boss emote text."
L["PRESENCE_DISCOVERY_LINE_COLOUR"]                           = "Discovery line colour"
L["PRESENCE_COLOUR_OF_DISCOVERED_LINE_UNDER_ZONE_TIP"]        = "Colour of the 'Discovered' line under zone text."
L["PRESENCE_NOTIFICATION_TYPES"]                              = "Notification types"
L["PRESENCE_NOTIFICATIONS"]                                   = "Notifications"
L["PRESENCE_NOTIFICATION_ACHIEVEMENT_CRITERIA_UPDATE"]        = "Show notification when achievement criteria update (tracked achievements always; others when Blizzard provides the achievement ID)."
L["PRESENCE_ZONE_ENTRY"]                                      = "Show zone entry"
L["PRESENCE_ZONE_CHANGE_ENTERING_A_AREA"]                     = "Show zone change when entering a new area."
L["PRESENCE_SUBZONE_CHANGES"]                                 = "Show subzone changes"
L["PRESENCE_SUBZONE_CHANGE_MOVING_WITHIN_SAME_ZONE"]          = "Show subzone change when moving within the same zone."
L["PRESENCE_HIDE_ZONE_NAME_SUBZONE_CHANGES"]                  = "Hide zone name for subzone changes"
L["PRESENCE_MOVING_BETWEEN_SUBZONES_WITHIN_SAME_ZONE"]        = "When moving between subzones within the same zone, only show the subzone name. The zone name still appears when entering a new zone."
L["PRESENCE_SUPPRESS_DELVE"]                                  = "Suppress in Delve"
L["PRESENCE_SUPPRESS_SCENARIO_PROGRESS_NOTIFICATIONS_DELVES"]   = "Suppress scenario progress notifications in Delves."
L["PRESENCE_HIDE_DELVE_OBJECTIVE_UPDATE"]                     = "When on, hides objective update popups while in a Delve. Zone entry and completion toasts still show."
L["PRESENCE_SUPPRESS_ZONE_CHANGES_MYTHIC"]                    = "Suppress zone changes in Mythic+"
L["PRESENCE_MYTHICPLUS_SHOW_BOSS_EMOTES_ACHIEVEMENTS_LEVELS"]   = "In Mythic+, only show boss emotes, achievements, and level-up. Hide zone, quest, and scenario notifications."
L["PRESENCE_LEVEL"]                                           = "Show level up"
L["PRESENCE_LEVEL_NOTIFICATION"]                              = "Show level-up notification."
L["PRESENCE_BOSS_EMOTES"]                                     = "Show boss emotes"
L["PRESENCE_RAID_DUNGEON_BOSS_EMOTE_NOTIFICATIONS"]           = "Show raid and dungeon boss emote notifications."
L["PRESENCE_ACHIEVEMENTS"]                                    = "Show achievements"
L["PRESENCE_ACHIEVEMENT_EARNED_NOTIFICATIONS"]                = "Show achievement earned notifications."
L["PRESENCE_ACHIEVEMENT_PROGRESS"]                            = "Achievement progress"
L["PRESENCE_SHOW_ACHIEVEMENT_EARNED"]                         = "Achievement earned"
L["PRESENCE_SHOW_QUEST_ACCEPTED"]                             = "Quest accepted"
L["PRESENCE_SHOW_WORLD_QUEST_ACCEPTED"]                       = "World quest accepted"
L["PRESENCE_SHOW_SCENARIO_COMPLETE"]                          = "Scenario complete"
L["PRESENCE_SHOW_RARE_DEFEATED"]                              = "Rare defeated"
L["PRESENCE_NOTIFICATION_TRACKED_ACHIEVEMENT_CRITERIA"]       = "Show notification when tracked achievement criteria update."
L["PRESENCE_QUEST_ACCEPT"]                                    = "Show quest accept"
L["PRESENCE_NOTIFICATION_ACCEPTING_A_QUEST"]                  = "Show notification when accepting a quest."
L["PRESENCE_WORLD_QUEST_ACCEPT"]                              = "Show world quest accept"
L["PRESENCE_NOTIFICATION_ACCEPTING_A_WORLD_QUEST"]            = "Show notification when accepting a world quest."
L["PRESENCE_SHOW_QUEST_COMPLETE"]                             = "Show quest complete"
L["PRESENCE_NOTIFICATION_COMPLETING_A_QUEST"]                 = "Show notification when completing a quest."
L["PRESENCE_SHOW_WORLD_QUEST_COMPLETE"]                       = "Show world quest complete"
L["PRESENCE_NOTIFICATION_COMPLETING_A_WORLD_QUEST"]           = "Show notification when completing a world quest."
L["PRESENCE_QUEST_PROGRESS"]                                  = "Show quest progress"
L["PRESENCE_NOTIFICATION_QUEST_OBJECTIVES_UPDATE"]            = "Show notification when quest objectives update."
L["PRESENCE_OBJECTIVE"]                                       = "Objective only"
L["PRESENCE_QUEST_PROGRESS_HIDE_TITLE"]                       = "Show only the objective line on quest progress toasts, hiding the 'Quest Update' title."
L["PRESENCE_SCENARIO_START"]                                  = "Show scenario start"
L["PRESENCE_NOTIFICATION_ENTERING_A_SCENARIO_DELVE"]          = "Show notification when entering a scenario or Delve."
L["PRESENCE_SCENARIO_PROGRESS"]                               = "Show scenario progress"
L["PRESENCE_NOTIFICATION_SCENARIO_DELVE_OBJECTIVES"]          = "Show notification when scenario or Delve objectives update."
L["PRESENCE_ANIMATION"]                                       = "Animation"
L["PRESENCE_ENABLE_ANIMATIONS"]                               = "Enable animations"
L["PRESENCE_ENABLE_ENTRANCE_EXIT_ANIMATIONS_PRESENCE"]        = "Enable entrance and exit animations for Presence notifications."
L["PRESENCE_ENTRANCE_DURATION"]                               = "Entrance duration"
L["PRESENCE_DURATION_OF_ENTRANCE_ANIMATION_SECONDS"]          = "Duration of the entrance animation in seconds (0.2–1.5)."
L["PRESENCE_EXIT_DURATION"]                                   = "Exit duration"
L["PRESENCE_DURATION_OF_EXIT_ANIMATION_SECONDS"]              = "Duration of the exit animation in seconds (0.2–1.5)."
L["PRESENCE_HOLD_DURATION_SCALE"]                             = "Hold duration scale"
L["PRESENCE_MULTIPLIER_LONG_NOTIFICATION_STAY"]               = "Multiplier for how long each notification stays on screen (0.5–2)."
L["PRESENCE_PREVIEW"]                                         = "Preview"
L["PRESENCE_PREVIEW_TOAST_TYPE"]                              = "Preview toast type"
L["PRESENCE_SELECT_A_TOAST_TYPE_PREVIEW"]                     = "Select a toast type to preview."
L["PRESENCE_SELECTED_TOAST_TYPE"]                             = "Show the selected toast type."
L["PRESENCE_PREVIEW_PRESENCE_TOAST_LAYOUTS_LIVE_OPEN"]        = "Preview Presence toast layouts live and open a detachable sample while adjusting other settings."
L["PRESENCE_OPEN_DETACHED_PREVIEW"]                           = "Open detached preview"
L["PRESENCE_OPEN_A_MOVABLE_PREVIEW_WINDOW_STAYS"]             = "Open a movable preview window that stays visible while you change other Presence settings."
L["PRESENCE_ANIMATE_PREVIEW"]                                 = "Animate preview"
L["PRESENCE_PLAY_SELECTED_TOAST_ANIMATION_INSIDE_PREVIEW"]    = "Play the selected toast animation inside this preview window."
L["PRESENCE_DETACHED_PREVIEW"]                                = "Detached preview"
L["PRESENCE_KEEP_OPEN_WHILE_ADJUSTING_TYPOGRAPHY_COLOURS"]    = "Keep this open while adjusting Typography or Colours."
L["DASH_TYPOGRAPHY"]                                          = "Typography"
L["PRESENCE_MAIN_TITLE_FONT"]                                 = "Main title font"
L["PRESENCE_FONT_FAMILY_MAIN_TITLE"]                          = "Font family for the main title."
L["PRESENCE_SUBTITLE_FONT"]                                   = "Subtitle font"
L["PRESENCE_FONT_FAMILY_SUBTITLE"]                            = "Font family for the subtitle."
L["PRESENCE_RESET_TYPOGRAPHY_DEFAULTS"]                       = "Reset typography to defaults"
L["PRESENCE_RESET_PRESENCE_TYPOGRAPHY_OPTIONS_FONTS_SIZES"]   = "Reset all Presence typography options (fonts, sizes, colours) to defaults."
L["PRESENCE_LARGE_NOTIFICATIONS"]                             = "Large notifications"
L["PRESENCE_MEDIUM_NOTIFICATIONS"]                            = "Medium notifications"
L["PRESENCE_SMALL_NOTIFICATIONS"]                             = "Small notifications"
L["PRESENCE_LARGE_PRIMARY_SIZE"]                              = "Large primary size"
L["PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_TITLES_ZONE"]        = "Font size for large notification titles (zone, quest complete, achievement, etc.)."
L["PRESENCE_LARGE_SECONDARY_SIZE"]                            = "Large secondary size"
L["PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_SUBTITLES"]          = "Font size for large notification subtitles."
L["PRESENCE_MEDIUM_PRIMARY_SIZE"]                             = "Medium primary size"
L["PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_TITLES_QUEST"]      = "Font size for medium notification titles (quest accept, subzone, scenario)."
L["PRESENCE_MEDIUM_SECONDARY_SIZE"]                           = "Medium secondary size"
L["PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_SUBTITLES"]         = "Font size for medium notification subtitles."
L["PRESENCE_SMALL_PRIMARY_SIZE"]                              = "Small primary size"
L["PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_TITLES_QUEST"]       = "Font size for small notification titles (quest progress, achievement progress)."
L["PRESENCE_SMALL_SECONDARY_SIZE"]                            = "Small secondary size"
L["PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_SUBTITLES"]          = "Font size for small notification subtitles."

-- =====================================================================
-- OptionsData.lua Dropdown options — Outline
-- =====================================================================
L["FOCUS_OUTLINE_NONE"]                                       = "None"
L["FOCUS_THICK_OUTLINE"]                                      = "Thick Outline"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["FOCUS_HIGHLIGHT_BAR_LEFT_EDGE"]                            = "Bar (left edge)"
L["FOCUS_HIGHLIGHT_BAR_RIGHT_EDGE"]                           = "Bar (right edge)"
L["FOCUS_HIGHLIGHT_BAR_TOP_EDGE"]                             = "Bar (top edge)"
L["FOCUS_HIGHLIGHT_BAR_BOTTOM_EDGE"]                          = "Bar (bottom edge)"
L["FOCUS_HIGHLIGHT_OUTLINE_ONLY"]                             = "Outline only"
L["FOCUS_HIGHLIGHT_SOFT_GLOW"]                                = "Soft glow"
L["FOCUS_HIGHLIGHT_DUAL_EDGE_BARS"]                           = "Dual edge bars"
L["FOCUS_HIGHLIGHT_PILL_LEFT_ACCENT"]                         = "Pill left accent"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["FOCUS_MYTHICPLUS_POSITION_TOP"]                            = "Top"
L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"]                         = "Bottom"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["VISTA_LOCATION_POSITION"]                                  = "Location position"
L["VISTA_PLACE_ZONE_NAME_ABOVE_BELOW_MINIMAP"]                = "Place the zone name above or below the minimap."
L["VISTA_COORDINATES_POSITION"]                               = "Coordinates position"
L["VISTA_PLACE_COORDINATES_ABOVE_BELOW_MINIMAP"]              = "Place the coordinates above or below the minimap."
L["VISTA_CLOCK_POSITION"]                                     = "Clock position"
L["VISTA_PLACE_CLOCK_ABOVE_BELOW_MINIMAP"]                    = "Place the clock above or below the minimap."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["FOCUS_TEXT_LOWER_CASE"]                                    = "Lower Case"
L["FOCUS_TEXT_UPPER_CASE"]                                    = "Upper Case"
L["FOCUS_TEXT_PROPER_CASE"]                                   = "Proper"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["FOCUS_TRACKED_LOG"]                                        = "Tracked / in log"
L["FOCUS_LOG_MAX_SLOTS"]                                      = "In log / max slots"

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["FOCUS_ALPHABETICAL"]                                       = "Alphabetical"
L["FOCUS_QUEST_TYPE"]                                         = "Quest Type"
L["FOCUS_QUEST_LEVEL"]                                        = "Quest Level"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["FOCUS_CUSTOM"]                                             = "Custom"
L["FOCUS_ORDER"]                                              = "Order"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["UI_DUNGEON"]                                               = "DUNGEON"
L["UI_RAID"]                                                  = "RAID"
L["UI_DELVES"]                                                = "Delves"
L["UI_SCENARIO_EVENTS"]                                       = "SCENARIO EVENTS"
L["UI_STAGE"]                                                 = "Stage"
L["UI_STAGE_X_X"]                                             = "Stage %d: %s"
L["UI_AVAILABLE_IN_ZONE"]                                     = "AVAILABLE IN ZONE"
L["UI_EVENTS_IN_ZONE"]                                        = "Events in Zone"
L["UI_CURRENT_EVENT"]                                         = "Current Event"
L["UI_CURRENT_QUEST"]                                         = "CURRENT QUEST"
L["UI_CURRENT_ZONE"]                                          = "CURRENT ZONE"
L["UI_CAMPAIGN"]                                              = "CAMPAIGN"
L["UI_IMPORTANT"]                                             = "IMPORTANT"
L["UI_LEGENDARY"]                                             = "LEGENDARY"
L["UI_WORLD_QUESTS"]                                          = "World quests"
L["UI_WEEKLY_QUESTS"]                                         = "WEEKLY QUESTS"
L["UI_PREY"]                                                  = "Prey"
L["UI_ABUNDANCE"]                                             = "Abundance"
L["UI_ABUNDANCE_BAG"]                                         = "Abundance Bag"
L["UI_ABUNDANCE_HELD"]                                        = "abundance held"
L["UI_DAILY_QUESTS"]                                          = "DAILY QUESTS"
L["UI_RARE_BOSSES"]                                           = "Rare bosses"
L["UI_ACHIEVEMENTS"]                                          = "ACHIEVEMENTS"
L["UI_ENDEAVORS"]                                             = "ENDEAVORS"
L["UI_DECOR"]                                                 = "Decor"
L["UI_RECIPES"]                                               = "Recipes"
L["UI_ADVENTURE_GUIDE"]                                       = "Adventure Guide"
L["UI_APPEARANCES"]                                           = "Appearances"
L["UI_QUESTS"]                                                = "QUESTS"
L["UI_READY_TO_TURN_IN"]                                      = "READY TO TURN IN"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["PRESENCE_OBJECTIVES"]                                      = "OBJECTIVES"
L["PRESENCE_OPTIONS"]                                         = "Options"
L["PRESENCE_OPEN_HORIZON_SUITE"]                              = "Open Horizon Suite"
L["PRESENCE_OPEN_FULL_HORIZON_SUITE_OPTIONS"]                 = "Open the full Horizon Suite options panel to configure Focus, Presence, Vista, and other modules."
L["PRESENCE_MINIMAP_SECTION"]                                 = "Minimap icon"
L["PRESENCE_SHOW_MINIMAP_ICON"]                               = "Show minimap icon"
L["PRESENCE_A_CLICKABLE_ICON_MINIMAP_OPENS"]                  = "Show a clickable icon on the minimap that opens the options panel."
L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER"]         = "Fade until minimap hover"
L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER_DESC"]    = "When on, the icon stays faded until you move the cursor over the minimap. When off, it stays fully visible."
L["PRESENCE_LOCK_MINIMAP_BUTTON_POSITION"]                    = "Lock minimap button position"
L["PRESENCE_PREVENT_DRAGGING_HORIZON_MINIMAP_BUTTON"]         = "Prevent dragging the Horizon minimap button."
L["PRESENCE_RESET_MINIMAP_BUTTON_POSITION"]                   = "Reset minimap button position"
L["PRESENCE_RESET_MINIMAP_BUTTON_DEFAULT_POSITION"]           = "Reset the minimap button to the default position (bottom-left)."
L["PRESENCE_DRAG_TO_MOVE_WHEN_UNLOCKED"]                      = "Drag to move (when unlocked)."
L["PRESENCE_LOCKED"]                                          = "Locked"
L["PRESENCE_DISCOVERED"]                                      = "Discovered"
L["PRESENCE_REFRESH"]                                         = "Refresh"
L["PRESENCE_BEST_EFFORT_UNACCEPTED_QUESTS_EXPO"]              = "Best-effort only. Some unaccepted quests are not exposed until you interact with NPCs or meet phasing conditions."
L["PRESENCE_UNACCEPTED_QUESTS_X_MAP_X"]                       = "Unaccepted Quests - %s (map %s) - %d match(es)"
L["PRESENCE_LEVEL_UP"]                                        = "LEVEL UP"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_80"]                       = "You have reached level 80"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_X"]                        = "You have reached level %s"
L["PRESENCE_ACHIEVEMENT_EARNED"]                              = "ACHIEVEMENT EARNED"
L["PRESENCE_EXPLORING_THE_MIDNIGHT_ISLES"]                    = "Exploring the Midnight Isles"
L["PRESENCE_EXPLORING_KHAZ_ALGAR"]                            = "Exploring Khaz Algar"
L["PRESENCE_QUEST_COMPLETE"]                                  = "QUEST COMPLETE"
L["PRESENCE_OBJECTIVE_SECURED"]                               = "Objective Secured"
L["PRESENCE_AIDING_THE_ACCORD"]                               = "Aiding the Accord"
L["PRESENCE_WORLD_QUEST"]                                     = "WORLD QUEST"
L["PRESENCE_WORLD_QUEST_COMPLETE"]                            = "WORLD QUEST COMPLETE"
L["PRESENCE_AZERITE_MINING"]                                  = "Azerite Mining"
L["PRESENCE_WORLD_QUEST_ACCEPTED"]                            = "WORLD QUEST ACCEPTED"
L["PRESENCE_QUEST_ACCEPTED"]                                  = "QUEST ACCEPTED"
L["PRESENCE_THE_FATE_OF_THE_HORDE"]                           = "The Fate of the Horde"
L["PRESENCE_NEW_QUEST"]                                       = "New Quest"
L["PRESENCE_QUEST_UPDATE"]                                    = "QUEST UPDATE"
L["PRESENCE_BOAR_PELTS_7_10"]                                 = "Boar Pelts: 7/10"
L["PRESENCE_DRAGON_GLYPHS_3_5"]                               = "Dragon Glyphs: 3/5"
L["PRESENCE_TEST_COMMANDS"]                                   = "Presence test commands:"
L["PRESENCE_H_DEBUGTYPES_DUMP_NOTIFICATION"]                  = "  /h presence debugtypes - Dump notification toggles and Blizzard suppression state"
L["PRESENCE_PLAYING_DEMO_REEL_NOTIFICATION"]                  = "Presence: Playing demo reel (all notification types)..."
L["PRESENCE_H_HELP_TEST_CURRENT"]                             = "  /h presence         - Show help + test current zone"
L["PRESENCE_H_ZONE_TEST"]                                     = "  /h presence zone     - Test Zone Change"
L["PRESENCE_H_SUBZONE_TEST"]                                  = "  /h presence subzone  - Test Subzone Change"
L["PRESENCE_H_DISCOVER_TEST_ZONE"]                            = "  /h presence discover - Test Zone Discovery"
L["PRESENCE_H_LEVEL_TEST"]                                    = "  /h presence level    - Test Level Up"
L["PRESENCE_H_BOSS_TEST"]                                     = "  /h presence boss     - Test Boss Emote"
L["PRESENCE_H_ACHIEVEMENT_TEST"]                              = "  /h presence ach      - Test Achievement"
L["PRESENCE_H_ACCEPT_TEST_QUEST"]                             = "  /h presence accept   - Test Quest Accepted"
L["PRESENCE_H_WORLD_QUEST_ACCEPT_TEST"]                       = "  /h presence wqaccept - Test World Quest Accepted"
L["PRESENCE_H_SCENARIO_TEST"]                                 = "  /h presence scenario - Test Scenario Start"
L["PRESENCE_H_QUEST_TEST_COMPLETE"]                           = "  /h presence quest    - Test Quest Complete"
L["PRESENCE_H_WORLD_QUEST_TEST"]                              = "  /h presence wq       - Test World Quest"
L["PRESENCE_H_QUEST_UPDATE_TEST"]                             = "  /h presence update   - Test Quest Update"
L["PRESENCE_H_ACHIEVEMENT_PROGRESS_TEST"]                     = "  /h presence achprogress - Test Achievement Progress"
L["PRESENCE_H_DEMO_REEL_TYPES"]                               = "  /h presence all      - Demo reel (all types)"
L["PRESENCE_H_DEBUG_DUMP_STATE"]                              = "  /h presence debug    - Dump state to chat"
L["PRESENCE_H_DEBUGLIVE_TOGGLE_LIVE"]                         = "  /h presence debuglive - Toggle live debug panel (log as events happen)"

-- =====================================================================
-- OptionsData.lua Vista — General
L["VISTA_POSITION_LAYOUT"]                                    = "Position & layout"

-- =====================================================================
L["VISTA_DESC"]                                               = "Minimap"
L["VISTA_SIZE"]                                               = "Minimap size"
L["VISTA_WIDTH_HEIGHT_OF_MINIMAP_PIXELS"]                     = "Width and height of the minimap in pixels (100–400)."
L["VISTA_CIRCULAR_MINIMAP"]                                   = "Circular minimap"
L["VISTA_CIRCULAR_SHAPE"]                                     = "Circular shape"
L["VISTA_A_CIRCULAR_MINIMAP_INSTEAD_OF_SQUARE"]               = "Use a circular minimap instead of square."
L["VISTA_LOCK_MINIMAP_POSITION"]                              = "Lock minimap position"
L["VISTA_PREVENT_DRAGGING_MINIMAP"]                           = "Prevent dragging the minimap."
L["VISTA_RESET_MINIMAP_POSITION"]                             = "Reset minimap position"
L["VISTA_RESET_MINIMAP_DEFAULT_POSITION_TOP_RIGHT"]           = "Reset minimap to its default position (top-right)."
L["VISTA_RESET_OVERLAY_POSITIONS"]                            = "Reset overlay positions to defaults"
L["VISTA_RESET_OVERLAY_POSITIONS_DESC"]                       = "Clear saved positions for zone text, coordinates, clock, performance and difficulty text, tracking, calendar, queue, mail, the addon button bar, drawer button, and right-click panel. The minimap frame position is not changed."
L["VISTA_AUTO_ZOOM"]                                          = "Auto Zoom"
L["VISTA_AUTO_ZOOM_DELAY"]                                    = "Auto zoom-out delay"
L["VISTA_SECONDS_AFTER_ZOOMING_BEFORE_AUTO_ZOOM"]             = "Seconds after zooming before auto zoom-out fires. Set to 0 to disable."

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["VISTA_ZONE_TEXT_HEADER"]                                   = "Zone Text"
L["VISTA_ZONE_FONT"]                                          = "Zone font"
L["VISTA_FONT_ZONE_NAME_BELOW_MINIMAP"]                       = "Font for the zone name below the minimap."
L["VISTA_ZONE_FONT_SIZE"]                                     = "Zone font size"
L["VISTA_ZONE_TEXT_COLOUR"]                                   = "Zone text colour"
L["VISTA_COLOUR_OF_ZONE_NAME_TEXT"]                           = "Colour of the zone name text."
L["VISTA_COORDINATES_TEXT"]                                   = "Coordinates Text"
L["VISTA_COORDINATES_FONT"]                                   = "Coordinates font"
L["VISTA_FONT_COORDINATES_TEXT_BELOW_MINIMAP"]                = "Font for the coordinates text below the minimap."
L["VISTA_COORDINATES_FONT_SIZE"]                              = "Coordinates font size"
L["VISTA_COORDINATES_TEXT_COLOUR"]                            = "Coordinates text colour"
L["VISTA_COLOUR_OF_COORDINATES_TEXT"]                         = "Colour of the coordinates text."
L["VISTA_COORDINATE_PRECISION"]                               = "Coordinate precision"
L["VISTA_NUMBER_OF_DECIMAL_PLACES_SHOWN_X"]                   = "Number of decimal places shown for X and Y coordinates."
L["VISTA_COORDS_DECIMALS_OFF"]                                = "No decimals (e.g. 52, 37)"
L["VISTA_DECIMAL_E_G"]                                        = "1 decimal (e.g. 52.3, 37.1)"
L["VISTA_DECIMALS_E_G"]                                       = "2 decimals (e.g. 52.34, 37.12)"
L["VISTA_TEXT"]                                               = "Time Text"
L["VISTA_FONT"]                                               = "Time font"
L["VISTA_FONT_TEXT_BELOW_MINIMAP"]                            = "Font for the time text below the minimap."
L["VISTA_FONT_SIZE"]                                          = "Time font size"
L["VISTA_TEXT_COLOUR"]                                        = "Time text colour"
L["VISTA_COLOUR_OF_TEXT"]                                     = "Colour of the time text."
L["VISTA_PERFORMANCE_TEXT"]                                   = "Performance Text"
L["VISTA_PERFORMANCE_FONT"]                                   = "Performance font"
L["VISTA_FONT_FPS_LATENCY_TEXT_BELOW_MINIMAP"]                = "Font for the FPS and latency text below the minimap."
L["VISTA_PERFORMANCE_FONT_SIZE"]                              = "Performance font size"
L["VISTA_PERFORMANCE_TEXT_COLOUR"]                            = "Performance text colour"
L["VISTA_COLOUR_OF_FPS_LATENCY_TEXT"]                         = "Colour of the FPS and latency text."
L["VISTA_DIFFICULTY_TEXT"]                                    = "Difficulty Text"
L["VISTA_DIFFICULTY_TEXT_COLOUR_FALLBACK"]                    = "Difficulty text colour (fallback)"
L["VISTA_DEFAULT_COLOUR_PER_DIFFICULTY_COLOUR"]               = "Default colour when no per-difficulty colour is set."
L["VISTA_DIFFICULTY_FONT"]                                    = "Difficulty font"
L["VISTA_FONT_INSTANCE_DIFFICULTY_TEXT"]                      = "Font for the instance difficulty text."
L["VISTA_DIFFICULTY_FONT_SIZE"]                               = "Difficulty font size"
L["VISTA_PER_DIFFICULTY_COLOURS"]                             = "Per-Difficulty Colours"
L["VISTA_MYTHIC_COLOUR"]                                      = "Mythic colour"
L["VISTA_COLOUR_MYTHIC_DIFFICULTY_TEXT"]                      = "Colour for Mythic difficulty text."
L["VISTA_HEROIC_COLOUR"]                                      = "Heroic colour"
L["VISTA_COLOUR_HEROIC_DIFFICULTY_TEXT"]                      = "Colour for Heroic difficulty text."
L["VISTA_NORMAL_COLOUR"]                                      = "Normal colour"
L["VISTA_COLOUR_NORMAL_DIFFICULTY_TEXT"]                      = "Colour for Normal difficulty text."
L["VISTA_LFR_COLOUR"]                                         = "LFR colour"
L["VISTA_COLOUR_LOOKING_RAID_DIFFICULTY_TEXT"]                = "Colour for Looking For Raid difficulty text."

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["VISTA_TEXT_ELEMENTS"]                                      = "Text Elements"
L["VISTA_ZONE_TEXT"]                                          = "Show zone text"
L["VISTA_ZONE_NAME_BELOW_MINIMAP"]                            = "Show the zone name below the minimap."
L["VISTA_ZONE_TEXT_DISPLAY_MODE"]                             = "Zone text display mode"
L["VISTA_WHAT_ZONE_SUBZONE"]                                  = "What to show: zone only, subzone only, or both."
L["VISTA_SHOW_ZONE"]                                          = "Zone only"
L["VISTA_SHOW_SUBZONE"]                                       = "Subzone only"
L["VISTA_SHOW_ZONE_AND_SUBZONE"]                              = "Both"
L["VISTA_COORDINATES"]                                        = "Show coordinates"
L["VISTA_PLAYER_COORDINATES_BELOW_MINIMAP"]                   = "Show player coordinates below the minimap."
L["VISTA_TIME"]                                               = "Show time"
L["VISTA_CURRENT_GAME_BELOW_MINIMAP"]                         = "Show current game time below the minimap."
L["VISTA_HOUR_CLOCK"]                                         = "24-hour clock"
L["VISTA_DISPLAY_HOUR_FORMAT_24"]                             = "Display time in 24-hour format (e.g. 14:30 instead of 2:30 PM)."
L["VISTA_LOCAL_TIME"]                                         = "Use local time"
L["VISTA_LOCAL_TIME_TIP"]                                     = "When on, shows your local system time. When off, shows server time."
L["VISTA_FPS_LATENCY"]                                        = "Show FPS and latency"
L["VISTA_FPS_LATENCY_MS_BELOW_MINIMAP"]                       = "Show FPS and latency (ms) below the minimap."
L["VISTA_MINIMAP_BUTTONS"]                                    = "Minimap Buttons"
L["VISTA_QUEUE_STATUS_MAIL_INDICATOR_ALWAYS_SHOWN"]           = "Queue status and mail indicator are always shown when relevant."
L["VISTA_TRACKING_BUTTON"]                                    = "Show tracking button"
L["VISTA_MINIMAP_TRACKING_BUTTON"]                            = "Show the minimap tracking button."
L["VISTA_TRACKING_BUTTON_MOUSEOVER"]                          = "Tracking button on mouseover only"
L["VISTA_HIDE_TRACKING_BUTTON_UNTIL_YOU_HOVER"]               = "Hide tracking button until you hover over the minimap."
L["VISTA_CALENDAR_BUTTON"]                                    = "Show calendar button"
L["VISTA_MINIMAP_CALENDAR_BUTTON"]                            = "Show the minimap calendar button."
L["VISTA_CALENDAR_BUTTON_MOUSEOVER"]                          = "Calendar button on mouseover only"
L["VISTA_HIDE_CALENDAR_BUTTON_UNTIL_YOU_HOVER"]               = "Hide calendar button until you hover over the minimap."
L["VISTA_ZOOM_BUTTONS"]                                       = "Show zoom buttons"
L["VISTA_ZOOM_BUTTONS_MINIMAP"]                               = "Show the + and - zoom buttons on the minimap."
L["VISTA_ZOOM_BUTTONS_MOUSEOVER"]                             = "Zoom buttons on mouseover only"
L["VISTA_HIDE_ZOOM_BUTTONS_UNTIL_YOU_HOVER"]                  = "Hide zoom buttons until you hover over the minimap."

-- =====================================================================
-- OptionsData.lua Vista — Display (Border / Text Positions / Buttons)
-- =====================================================================
L["VISTA_BORDER"]                                             = "Border"
L["VISTA_BORDER_TIP"]                                         = "Show a border around the minimap."
L["VISTA_BORDER_COLOUR"]                                      = "Border colour"
L["VISTA_COLOUR_OPACITY_OF_MINIMAP_BORDER"]                   = "Colour and opacity of the minimap border. With class colours for Vista on, RGB scales your class tint (white = full strength); opacity always applies."
L["VISTA_BORDER_THICKNESS"]                                   = "Border thickness"
L["VISTA_THICKNESS_OF_MINIMAP_BORDER_PIXELS"]                 = "Thickness of the minimap border in pixels (1–8)."
L["VISTA_CLASS_COLOURS"]                                      = "Class colours"
L["VISTA_TINT_VISTA_BORDER_TEXT_COORDS_FPS"]                  = "Tint Vista border and text (coords, time, FPS/MS labels) with your class colour. Numbers use the configured colour."
L["VISTA_TEXT_POSITIONS"]                                     = "Text Positions"
L["VISTA_DRAG_TEXT_ELEMENTS_REPOSITION_LOCK_PREVEN"]          = "Drag text elements to reposition them. Lock to prevent accidental movement."
L["VISTA_LOCK_ZONE_TEXT_POSITION"]                            = "Lock zone text position"
L["VISTA_ZONE_TEXT_CANNOT_DRAGGED"]                           = "When on, the zone text cannot be dragged."
L["VISTA_LOCK_COORDINATES_POSITION"]                          = "Lock coordinates position"
L["VISTA_COORDINATES_TEXT_CANNOT_DRAGGED"]                    = "When on, the coordinates text cannot be dragged."
L["VISTA_LOCK_POSITION"]                                      = "Lock time position"
L["VISTA_TEXT_CANNOT_DRAGGED"]                                = "When on, the time text cannot be dragged."
L["VISTA_PERFORMANCE_TEXT_POSITION"]                          = "Performance text position"
L["VISTA_PLACE_FPS_LATENCY_TEXT_ABOVE_BELOW"]                 = "Place the FPS/latency text above or below the minimap."
L["VISTA_LOCK_PERFORMANCE_TEXT_POSITION"]                     = "Lock performance text position"
L["VISTA_FPS_LATENCY_TEXT_CANNOT_DRAGGED"]                    = "When on, the FPS/latency text cannot be dragged."
L["VISTA_DIFFICULTY_TEXT_POSITION"]                           = "Difficulty text position"
L["VISTA_PLACE_DIFFICULTY_TEXT_ABOVE_BELOW"]                  = "Place the instance difficulty text above or below the minimap. It is positioned independently of zone text."
L["VISTA_LOCK_DIFFICULTY_TEXT_POSITION"]                      = "Lock difficulty text position"
L["VISTA_DIFFICULTY_TEXT_CANNOT_DRAGGED"]                     = "When on, the difficulty text cannot be dragged."
L["VISTA_BUTTON_POSITIONS"]                                   = "Button Positions"
L["VISTA_DRAG_BUTTONS_REPOSITION_LOCK_PREVENT_MOVE"]          = "Drag buttons to reposition them. Lock to prevent movement."
L["VISTA_LOCK_ZOOM_BUTTON"]                                   = "Lock Zoom In button"
L["VISTA_PREVENT_DRAGGING_ZOOM_BUTTON"]                       = "Prevent dragging the + zoom button."
L["VISTA_LOCK_ZOOM_OUT_BUTTON"]                               = "Lock Zoom Out button"
L["VISTA_LOCK_ZOOM_OUT_DRAG"]                                 = "Prevent dragging the - zoom button."
L["VISTA_LOCK_TRACKING_BUTTON"]                               = "Lock Tracking button"
L["VISTA_PREVENT_DRAGGING_TRACKING_BUTTON"]                   = "Prevent dragging the tracking button."
L["VISTA_LOCK_CALENDAR_BUTTON"]                               = "Lock Calendar button"
L["VISTA_PREVENT_DRAGGING_CALENDAR_BUTTON"]                   = "Prevent dragging the calendar button."
L["VISTA_LOCK_QUEUE_BUTTON"]                                  = "Lock Queue button"
L["VISTA_PREVENT_DRAGGING_QUEUE_STATUS_BUTTON"]               = "Prevent dragging the queue status button."
L["VISTA_LOCK_MAIL_INDICATOR"]                                = "Lock Mail indicator"
L["VISTA_PREVENT_DRAGGING_MAIL_ICON"]                         = "Prevent dragging the mail icon."
L["VISTA_DISABLE_QUEUE_HANDLING"]                             = "Disable queue handling"
L["VISTA_DISABLE_QUEUE_BUTTON_HANDLING"]                      = "Disable queue button handling"
L["VISTA_TURN_QUEUE_BUTTON_ANCHORING_OFF_ADDON_CONFLICT"]     = "Turn off all queue button anchoring (use if another addon manages it)."
L["VISTA_BUTTON_SIZES"]                                       = "Button Sizes"
L["VISTA_ADJUST_SIZE_OF_MINIMAP_OVERLAY_BUTTONS"]             = "Adjust the size of minimap overlay buttons."
L["VISTA_TRACKING_BUTTON_SIZE"]                               = "Tracking button size"
L["VISTA_SIZE_OF_TRACKING_BUTTON_PIXELS"]                     = "Size of the tracking button (pixels)."
L["VISTA_CALENDAR_BUTTON_SIZE"]                               = "Calendar button size"
L["VISTA_SIZE_OF_CALENDAR_BUTTON_PIXELS"]                     = "Size of the calendar button (pixels)."
L["VISTA_QUEUE_BUTTON_SIZE"]                                  = "Queue button size"
L["VISTA_SIZE_OF_QUEUE_STATUS_BUTTON_PIXELS"]                 = "Size of the queue status button (pixels)."
L["VISTA_ZOOM_BUTTON_SIZE"]                                   = "Zoom button size"
L["VISTA_SIZE_OF_ZOOM_ZOOM_BUTTONS_PIXELS"]                   = "Size of the zoom in / zoom out buttons (pixels)."
L["VISTA_MAIL_INDICATOR_SIZE"]                                = "Mail indicator size"
L["VISTA_SIZE_OF_MAIL_ICON_PIXELS"]                           = "Size of the new mail icon (pixels)."
L["VISTA_ADDON_BUTTON_SIZE"]                                  = "Addon button size"
L["VISTA_SIZE_OF_COLLECTED_ADDON_MINIMAP_BUTTONS"]            = "Size of collected addon minimap buttons (pixels)."

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
L["VISTA_COLLECT_HORIZON_MINIMAP"]                            = "Include Horizon minimap icon"
L["VISTA_COLLECT_HORIZON_MINIMAP_DESC"]                       = "Put Horizon's own minimap icon in the managed addon bar, right-click panel, or drawer instead of leaving it on the minimap edge."
L["VISTA_SORT_BUTTONS_ALPHA"]                                 = "Sort buttons alphabetically"
L["VISTA_SORT_BUTTONS_ALPHA_DESC"]                            = "Sort collected addon minimap buttons alphabetically by name."
L["VISTA_ADDON_BUTTONS"]                                      = "Addon Buttons"
L["VISTA_MINIMAP_ADDON_BUTTONS"]                              = "Minimap Addon Buttons"
L["VISTA_BUTTON_MANAGEMENT"]                                  = "Button Management"
L["VISTA_MANAGE_ADDON_MINIMAP_BUTTONS"]                       = "Manage addon minimap buttons"
L["VISTA_TAKES_CONTROL_OF_ADDON_MINIMAP"]                     = "When on, Vista takes control of addon minimap buttons and groups them by the selected mode."
L["VISTA_BUTTON_MODE"]                                        = "Button mode"
L["VISTA_ADDON_BUTTONS_PRESENTED_HOVER_BAR_BELOW"]            = "How addon buttons are presented: hover bar below minimap, panel on right-click, or floating drawer button."
L["VISTA_ALWAYS_BAR"]                                         = "Always show bar"
L["VISTA_ALWAYS_MOUSEOVER_BAR_POSITIONING"]                   = "Always show mouseover bar (for positioning)"
L["VISTA_KEEP_MOUSEOVER_BAR_VISIBLE_TIMES_YOU"]               = "Keep the mouseover bar visible at all times so you can reposition it. Disable when done."
L["VISTA_DISABLE_DONE"]                                       = "Disable when done."
L["VISTA_MOUSEOVER_BAR"]                                      = "Mouseover bar"
L["VISTA_RIGHT_CLICK_PANEL"]                                  = "Right-click panel"
L["VISTA_FLOATING_DRAWER"]                                    = "Floating drawer"
L["VISTA_LOCK_DRAWER_BUTTON_POSITION"]                        = "Lock drawer button position"
L["VISTA_PREVENT_DRAGGING_FLOATING_DRAWER_BUTTON"]            = "Prevent dragging the floating drawer button."
L["VISTA_LOCK_MOUSEOVER_BAR_POSITION"]                        = "Lock mouseover bar position"
L["VISTA_PREVENT_DRAGGING_MOUSEOVER_BUTTON_BAR"]              = "Prevent dragging the mouseover button bar."
L["VISTA_LOCK_RIGHT_CLICK_PANEL_POSITION"]                    = "Lock right-click panel position"
L["VISTA_PREVENT_DRAGGING_RIGHT_CLICK_PANEL"]                 = "Prevent dragging the right-click panel."
L["VISTA_BUTTONS_PER_ROW_COLUMN"]                             = "Buttons per row/column"
L["VISTA_CONTROLS_MANY_BUTTONS_APPEAR_BEFORE_WRAPPING"]       = "Controls how many buttons appear before wrapping. For left/right direction this is columns; for up/down it is rows."
L["VISTA_EXPAND_DIRECTION"]                                   = "Expand direction"
L["VISTA_DIRECTION_BUTTONS_FILL_ANCHOR_POINT_LEFT"]           = "Direction buttons fill from the anchor point. Left/Right = horizontal rows. Up/Down = vertical columns."
L["VISTA_BUTTONS_FILL_RIGHT"]                                 = "Right"
L["VISTA_BUTTONS_FILL_LEFT"]                                  = "Left"
L["VISTA_BUTTONS_FILL_DOWN"]                                  = "Down"
L["VISTA_BUTTONS_FILL_UP"]                                    = "Up"
L["VISTA_MOUSEOVER_BAR_APPEARANCE"]                           = "Mouseover Bar Appearance"
L["VISTA_BACKGROUND_BORDER_MOUSEOVER_BUTTON_BAR"]             = "Background and border for the mouseover button bar."
L["VISTA_BACKDROP_COLOUR"]                                    = "Backdrop colour"
L["VISTA_BACKGROUND_COLOUR_OF_MOUSEOVER_BUTTON_BAR"]          = "Background colour of the mouseover button bar (use alpha to control transparency)."
L["VISTA_BAR_BORDER"]                                         = "Show bar border"
L["VISTA_A_BORDER_AROUND_MOUSEOVER_BUTTON_BAR"]               = "Show a border around the mouseover button bar."
L["VISTA_BAR_BORDER_COLOUR"]                                  = "Bar border colour"
L["VISTA_BORDER_COLOUR_OF_MOUSEOVER_BUTTON_BAR"]              = "Border colour of the mouseover button bar."
L["VISTA_BAR_BACKGROUND_COLOUR"]                              = "Bar background colour"
L["VISTA_PANEL_BACKGROUND_COLOUR"]                            = "Panel background colour."
L["VISTA_CLOSE_FADE_TIMING"]                                  = "Close / Fade Timing"
L["VISTA_MOUSEOVER_BAR_CLOSE_DELAY_SECONDS"]                  = "Mouseover bar — close delay (seconds)"
L["VISTA_LONG_SECONDS_BAR_STAYS_VISIBLE_AFTER"]               = "How long (in seconds) the bar stays visible after the cursor leaves. 0 = instant fade."
L["VISTA_RIGHT_CLICK_PANEL_CLOSE_DELAY_SECONDS"]              = "Right-click panel — close delay (seconds)"
L["VISTA_LONG_SECONDS_PANEL_STAYS_OPEN_AFTER"]                = "How long (in seconds) the panel stays open after the cursor leaves. 0 = never auto-close (close by right-clicking again)."
L["VISTA_FLOATING_DRAWER_CLOSE_DELAY_SECONDS"]                = "Floating drawer — close delay (seconds)"
L["VISTA_DRAWER_CLOSE_DELAY"]                                 = "Drawer close delay"
L["VISTA_LONG_SECONDS_DRAWER_PANEL_STAYS_OPEN"]               = "How long (in seconds) the drawer panel stays open after clicking away. 0 = never auto-close (close only by clicking the drawer button again)."
L["VISTA_MAIL_ICON_BLINK"]                                    = "Mail icon blink"
L["VISTA_MAIL_ICON_PULSES_DRAW_ATTENTION"]                    = "When on, the mail icon pulses to draw attention. When off, it stays at full opacity."
L["VISTA_PANEL_APPEARANCE"]                                   = "Panel Appearance"
L["VISTA_COLOURS_DRAWER_RIGHT_CLICK_BUTTON_PANELS"]           = "Colours for the drawer and right-click button panels."
L["VISTA_PANEL_BG_COLOUR_LABEL"]                              = "Panel background colour"
L["VISTA_BACKGROUND_COLOUR_OF_ADDON_BUTTON_PANELS"]           = "Background colour of the addon button panels."
L["VISTA_PANEL_BORDER_COLOUR"]                                = "Panel border colour"
L["VISTA_BORDER_COLOUR_OF_ADDON_BUTTON_PANELS"]               = "Border colour of the addon button panels."
L["VISTA_MANAGED_BUTTONS"]                                    = "Managed buttons"
L["VISTA_BUTTON_COMPLETELY_IGNORED"]                          = "When off, this button is completely ignored by this addon."
L["VISTA_ADDON_BUTTONS_DETECTED"]                             = "(No addon buttons detected yet)"
L["VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE"]                      = "Visible buttons (check to include)"
L["VISTA_ADDON_BUTTONS_DETECTED_OPEN_YOUR_MINIMAP"]           = "(No addon buttons detected yet — open your minimap first)"

-- =====================================================================
-- Inline option / module strings (used in OptionsData / modules; symbolic migration)
-- =====================================================================

L["HEROIC_DUNGEON"]                                           = "Heroic dungeon"
L["HEROIC_RAID"]                                              = "Heroic raid"
L["LFR"]                                                      = "LFR"
L["MYTHIC_DUNGEON"]                                           = "Mythic dungeon"
L["MYTHIC_RAID"]                                              = "Mythic raid"
L["MYTHIC_PLUS_DUNGEON"]                                      = "Mythic+ dungeon"
L["NORMAL_DUNGEON"]                                           = "Normal dungeon"
L["NORMAL_RAID"]                                              = "Normal raid"
L["ACHIEVEMENT_ICONS"]                                        = "Achievement icons"
L["ACTIVE_INSTANCE"]                                          = "Active instance only"
L["ADJUST_FONT_SIZES_AMOUNT"]                                 = "Adjust all font sizes by this amount."
L["ADJUST_FONTS_SIZES_CASING_DROP_SHADOWS"]                   = "Adjust fonts, sizes, casing, and drop shadows."
L["AFFIX_ICONS"]                                              = "Affix icons"
L["AFFIX_TOOLTIPS"]                                           = "Affix tooltips"
L["AFFECTS_SCENARIO_PROGRESS_TIMER_BARS"]                     = "Also affects scenario progress and timer bars."
L["ALWAYS"]                                                   = "Always show"
L["ALWAYS_M_TIMER"]                                           = "Always show M+ timer."
L["AUTO_ADD_WQS_YOUR_CURRENT_ZONE"]                           = "Auto-add WQs in your current zone."
L["AUTO_CLOSE_DELAY_DISABLE"]                                 = "Auto-close delay (0 to disable)."
L["AUTO_UNTRACK_FINISHED_ACTIVITIES"]                         = "Auto-untrack finished activities."
L["FOCUS_BAR_UNDER_NUMERIC_OBJECTIVES"]                       = "Bar under numeric objectives (e.g. 3/250)."
L["DASH_CLASS_ICONS_RONDOMEDIA"]                              = "Blizzard default, RondoMedia, or Horizon class icon on the Dashboard when Dashboard class colours are on. Independent of Insight tooltip class icons."
L["BLOCK_POSITION"]                                           = "Block position"
L["BOSS_EMOTES"]                                              = "Boss emotes"
L["CHOICE_SLOTS"]                                             = "Choice slots"
L["CHOOSE_WHICH_EVENTS_TRIGGER_SCREEN_ALERTS"]                = "Choose which events trigger on-screen alerts."
L["CHOOSE_WHICH_SOUND_PLAY_A_RARE"]                           = "Choose which sound to play when a rare boss appears. Requires LibSharedMedia sounds to be installed for extra options."
L["CLICK_BEHAVIOR"]                                           = "Click behavior"
L["COLLECT_GROUP_ADDON_MINIMAP_BUTTONS"]                      = "Collect and group addon minimap buttons."
L["COLOUR_REMAINING"]                                         = "Colour by remaining time."
L["COLOUR_ZONE_TYPE"]                                         = "Colour by zone type"
L["COLOUR_CONTESTED_ZONES_ORANGE_DEFAULT"]                    = "Colour for contested zones (orange by default)."
L["COLOUR_FRIENDLY_ZONES_GREEN_DEFAULT"]                      = "Colour for friendly zones (green by default)."
L["COLOUR_HOSTILE_ZONES_RED_DEFAULT"]                         = "Colour for hostile zones (red by default)."
L["COLOUR_SANCTUARY_ZONES_BLUE_DEFAULT"]                      = "Colour for sanctuary zones (blue by default)."
L["COLOUR_OF_DIVIDER_LINES_BETWEEN_SECTIONS"]                 = "Colour of the divider lines between sections."
L["COLOUR_RECIPE_TITLES_OUTPUT_ITEM_RARITY"]                  = "Colour recipe titles by output item rarity."
L["COLOUR_ZONE_SUBZONE_TITLES_PVP_ZONE"]                      = "Colour zone/subzone titles by PvP zone type (friendly, hostile, contested, sanctuary). When off, uses the default category colour."
L["COMBAT_AFK_DND_PVP_PARTY_FRIENDS"]                         = "Combat, AFK, DND, PvP, party, friends, targeting."
L["COMING_SOON"]                                              = "Coming Soon"
L["COMPLETED_BOSS_STYLE"]                                     = "Completed boss style"
L["COMPLETED_COUNT"]                                          = "Completed count"
L["FOCUS_TOMTOM_CONFIGURE_DESC"]                              = "Configure tracking rules and TomTom integration."
L["CONFIGURE_MINIMAP_S_SHAPE_SIZE_POSITION"]                  = "Configure the minimap's shape, size, position, and text overlays."
L["CONTESTED_ZONE_COLOUR"]                                    = "Contested zone colour"
L["CONTROL_TRACKER_VISIBILITY_WITHIN_DUNGEONS_RAIDS"]         = "Control tracker visibility within dungeons, raids, and PvP."
L["SETTINGS_PRESENCE_NOTIFICATION_FRAMEWORK"]                 = "Core settings for the Presence notification framework."
L["CRAFTABLE_COUNT"]                                          = "Craftable count"
L["CTRL_LEFT_FOCUS_ADD_CTRL_RIGHT"]                           = "Ctrl+Left = focus/add, Ctrl+Right = unfocus/untrack."
L["CURRENT_ZONE_GROUP"]                                       = "Current Zone group"
L["CURRENT_ZONE"]                                             = "Current zone only"
L["VISTA_CUSTOMISE_BORDERS_COLOURS_POSITIONING"]              = "Customise borders, colours, and the positioning of specific minimap elements."
L["CUSTOMIZE_VISUAL_INTERFACE_LAYOUT_ELEMENTS"]               = "Customise the visual interface and layout elements."
L["DASHBOARD_CLASS_ICON_STYLE"]                               = "Dashboard class icon style"
L["DECOR_ICONS"]                                              = "Decor icons"
L["DEDICATED_SECTION_COMPLETED_QUESTS"]                       = "Dedicated section for completed quests."
L["DEDICATED_SECTION_ZONE_QUESTS"]                            = "Dedicated section for in-zone quests."
L["DEFEATED_BOSS_STYLE"]                                      = "Defeated boss style."
L["DESATURATE_FOCUSED_ENTRIES"]                               = "Desaturate non-focused entries."
L["DESATURATE_FOCUSED_QUESTS"]                                = "Desaturate non-focused quests"
L["DIM_ALPHA"]                                                = "Dim alpha"
L["DIM_STRENGTH"]                                             = "Dim strength"
L["DIM_UNFOCUSED_TRACKER_ENTRIES"]                            = "Dim unfocused tracker entries."
L["DIMMING_STRENGTH"]                                         = "Dimming strength (0-100%)."
L["DISPLAY_COMPLETED_OBJECTIVES"]                             = "Display completed objectives."
L["ENABLE_BLACKLIST_UNTRACKED_INTERACTIONS_ADD_QUEST"]        = "Enable 'Blacklist untracked' in Interactions to add quests here."
L["ENABLE_M_BLOCK"]                                           = "Enable M+ block"
L["ENEMY_FORCES_COLOUR"]                                      = "Enemy forces colour"
L["ENEMY_FORCES_SIZE"]                                        = "Enemy forces size"
L["ENHANCE_PLAYER_ITEM_TOOLTIPS_EXTRA_DETAILS"]               = "Enhance player and item tooltips with extra details like Mythic+ score and transmog status."
L["ENTRY_NUMBERS"]                                            = "Entry numbers"
L["ENTRY_SPACING"]                                            = "Entry spacing"
L["EXPAND_DIRECTION_ANCHOR"]                                  = "Expand direction from anchor."
L["FADE_HOVERING"]                                            = "Fade out when not hovering."
L["FOCUS_FINISHING_REAGENTS"]                                 = "Finishing reagents"
L["FOCUS_ANIMATIONS"]                                         = "Focus animations"
L["FONT_SIZE_BAR_LABEL_BAR_HEIGHT"]                           = "Font size for bar label and bar height."
L["FONTS_SIZES_COLOURS_PRESENCE_NOTIFICATIONS"]               = "Fonts, sizes, and colours for Presence notifications."
L["WORLD_QUESTS_WEEKLIES_YOUR_QUEST_LOG"]                     = "For world quests and weeklies not in your quest log."
L["FRIENDLY_ZONE_COLOUR"]                                     = "Friendly zone colour"
L["GROUPING"]                                                 = "Grouping"
L["GROUPS_SELECTED_LAYOUT_MODE_BELOW"]                        = "Groups them by the selected layout mode below."
L["GUILD_RANK"]                                               = "Guild rank"
L["HEADER_DIVIDER"]                                           = "Header divider"
L["HIDE_UNTRACKED_QUESTS_UNTIL_RELOAD"]                       = "Hide untracked quests until reload."
L["HIDE_ZONE_NOTIFICATIONS_MYTHIC"]                           = "Hide zone notifications in Mythic+."
L["HIDES_CATEGORIES_WHILE_A_DELVE_PARTY"]                     = "Hides other categories while in a Delve or party dungeon."
L["HINT_LIST_SCROLLABLE"]                                     = "Hint when the list is scrollable."
L["HONOR_LEVEL"]                                              = "Honor level"
L["HOSTILE_ZONE_COLOUR"]                                      = "Hostile zone colour"
L["FOCUS_DIM_UNFOCUSED_ENTRIES_DESC"]                         = "How much to dim non-focused entries (0 = no dimming, 100 = fully darkened). Default 40%."
L["ICON_NEXT_ACHIEVEMENT_TITLE"]                              = "Icon next to achievement title."
L["ICON_NEXT_AUTO_TRACKED_ZONE_ENTRIES"]                      = "Icon next to auto-tracked in-zone entries."
L["ARENA"]                                                    = "In arena"
L["BATTLEGROUND"]                                             = "In battleground"
L["DUNGEON"]                                                  = "In dungeon"
L["RAID"]                                                     = "In raid"
L["ZONE_WORLD_QUESTS"]                                        = "In-zone world quests"
L["INCLUDE_COMPLETED"]                                        = "Include completed"
L["INSTANCE_SUPPRESSION"]                                     = "Instance suppression"
L["ITEM_LEVEL"]                                               = "Item level"
L["ITEM_SOURCE"]                                              = "Item source"
L["KEEP_BAR_VISIBLE_REPOSITIONING"]                           = "Keep bar visible for repositioning."
L["KEEP_CAMPAIGN_CATEGORY"]                                   = "Keep campaign in category"
L["KEEP_HEADER_BOTTOM_TOP_UNTIL_COLLAPSED"]                   = "Keep header at bottom, or top until collapsed."
L["KEEP_IMPORTANT_CATEGORY"]                                  = "Keep important in category"
L["KEEP_CAMPAIGN_READY_TURN"]                                 = "Keep in Campaign when ready to turn in."
L["KEEP_IMPORTANT_READY_TURN"]                                = "Keep in Important when ready to turn in."
L["KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED"]                   = "Keep section headers visible when collapsed."
L["L_CLICK_OPENS_MAP_R_CLICK"]                                = "L-click opens map, R-click opens menu."
L["PRESENCE_LEVEL_UP_TOGGLE"]                                 = "Level up"
L["LOCK_DRAWER_BUTTON"]                                       = "Lock drawer button"
L["LOCK_ITEM_POSITION"]                                       = "Lock item position"
L["LOCK_MINIMAP"]                                             = "Lock minimap"
L["LOCK_MOUSEOVER_BAR"]                                       = "Lock mouseover bar"
L["LOCK_RIGHT_CLICK_PANEL"]                                   = "Lock right-click panel"
L["MAIL_ICON_PULSE"]                                          = "Mail icon pulse"
L["MAKE_FOCUSED_ENTRIES_GREYSCALE_PARTIALLY_DESATURATE"]      = "Make non-focused entries greyscale/partially desaturated in addition to dimming."
L["MANAGE_ADDON_BUTTONS"]                                     = "Manage addon buttons"
L["VISTA_ICON_MANAGEMENT"]                                    = "Manage and organise minimap icons from other addons into a tidy drawer or bar."
L["MANAGE_SWITCH_BETWEEN_YOUR_ADDON_CONFIGURATIONS"]          = "Manage and switch between your addon configurations."
L["MATCH_BAR_QUEST_CATEGORY_COLOUR"]                          = "Match bar to quest category colour."
L["APPEAR_FULL_TRACKER_REPLACEMENTS"]                         = "May not appear with full tracker replacements."
L["MINIMAL_MODE"]                                             = "Minimal mode"
L["MISSING_CRITERIA"]                                         = "Missing criteria only"
L["MOUNT_INFO"]                                               = "Mount info"
L["MOUNT_NAME_SOURCE_COLLECTION_STATUS"]                      = "Mount name, source, and collection status."
L["MOUSEOVER_CLOSE_DELAY"]                                    = "Mouseover close delay"
L["MOUSEOVER"]                                                = "Mouseover only"
L["MOVE_COMPLETED_QUESTS_BOTTOM_OF_CURRENT"]                  = "Move completed quests to the bottom of the Current Zone section."
L["MYTHIC_BLOCK"]                                             = "Mythic+ Block"
L["MYTHIC_COLOURS"]                                           = "Mythic+ Colours"
L["MYTHIC_SCORE"]                                             = "Mythic+ score"
L["DEFAULT"]                                                  = "New from Default"
L["HIDDEN_QUESTS"]                                            = "No hidden quests."
L["NOTIFY_ACHIEVEMENT_CRITERIA_UPDATE"]                       = "Notify on achievement criteria update."
L["OBJECTIVE_PROGRESS"]                                       = "Objective progress"
L["OBJECTIVE_SPACING"]                                        = "Objective spacing"
L["L_CLICK_FOCUSES_R_CLICK_UNTRACKS"]                         = "Off: L-click focuses, R-click untracks. Ctrl+Right shares."
L["PROGRESS_TRACKED_ACHIEVEMENTS_SHOWN"]                      = "Off: only in-progress tracked achievements shown."
L["TRACKED_NEARBY_WQS_APPEAR_BLIZZARD_DEFAULT"]               = "Off: only tracked or nearby WQs appear (Blizzard default)."
L["BOSS_EMOTES_ACHIEVEMENTS_LEVEL_HIDES_ZONE"]                = "Only boss emotes, achievements, and level-up. Hides zone, quest, and scenario notifications in Mythic+."
L["ENTRIES_A_SINGLE_NUMERIC_OBJECTIVE_WHERE"]                 = "Only for entries with a single numeric objective where required > 1."
L["QUESTS_DON_T_NEED_NPC_TURN"]                               = "Only for quests that don't need NPC turn-in. Off = Blizzard default."
L["INCOMPLETE_CRITERIA"]                                      = "Only show incomplete criteria."
L["SUBZONE_NAME_WITHIN_SAME_ZONE"]                            = "Only show subzone name within same zone."
L["OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]                       = "Opacity of focused quest highlight (0–100%)."
L["OPACITY_OF_UNFOCUSED_ENTRIES"]                             = "Opacity of unfocused entries."
L["FOCUS_OPTIONAL_REAGENTS"]                                  = "Optional reagents"
L["FOCUS_RECIPE_REAGENTS_FULL_DETAIL"]                        = "Full reagent detail"
L["FOCUS_RECIPE_REAGENTS_FULL_DETAIL_DESC"]                   = "List every schematic slot: optional and finishing sections, choice groups with all variants, and non-Basic reagents. When off, only Basic slots use the first reagent per slot (compact shopping-style list)."
L["ORGANIZE_HIDE_TRACKED_ENTRIES_YOUR_PREFERENCE"]            = "Organise and hide tracked entries to your preference."
L["OVERRIDE_FONT_PER_ELEMENT"]                                = "Override font per element."
L["PANEL_BACKGROUND_OPACITY"]                                 = "Panel background opacity (0–100%)."
L["PERMANENTLY_HIDE_UNTRACKED_QUESTS"]                        = "Permanently hide untracked quests."
L["PERSONALIZE_COLOUR_PALETTE_TRACKER_TEXT_ELEMENTS"]         = "Personalize the colour palette for tracker text elements."
L["POSITIONING_VISIBILITY_CACHE_LOOT_TOAST_SYS"]              = "Positioning and visibility for the Cache loot toast system."
L["PREVENT_ACCIDENTAL_CLICKS"]                                = "Prevent accidental clicks."
L["QUALITY_INFO"]                                             = "Quality info"
L["QUEST_ACCEPT"]                                             = "Quest accept"
L["QUEST_COMPLETE"]                                           = "Quest complete"
L["QUEST_COUNT"]                                              = "Quest count"
L["QUEST_ITEM_BUTTONS"]                                       = "Quest item buttons"
L["QUEST_LEVEL"]                                              = "Quest level"
L["QUEST_PROGRESS"]                                           = "Quest progress"
L["QUEST_PROGRESS_BAR"]                                       = "Quest progress bar"
L["QUEST_TRACKING"]                                           = "Quest tracking"
L["QUEST_TYPE_ICONS"]                                         = "Quest type icons"
L["FOCUS_QUEST_TYPE_ICON_SIZE"]                               = "Quest type icon size"
L["FOCUS_QUEST_TYPE_ICON_SIZE_DESC"]                          = "Pixel size of the quest type icon shown in the left gutter (default 16)."
L["PRESENCE_RARE_DEFEATED"]                                   = "RARE DEFEATED"
L["RARE_ADDED_SOUND_CHOICE"]                                  = "Rare added sound choice"
L["RARE_SOUND_ALERT"]                                         = "Rare sound alert"
L["RARITY_COLOURS"]                                           = "Rarity colours"
L["READY_TURN_GROUP"]                                         = "Ready to Turn In group"
L["READY_TURN_BOTTOM"]                                        = "Ready to turn in at bottom"
L["REAGENTS"]                                                 = "Reagents"
L["RECIPE_ICONS"]                                             = "Recipe icons"
L["RECIPES"]                                                  = "Recipes"
L["REDUCE_OPACITY_OF_FOCUSED_ENTRIES_INVISIBLE"]              = "Reduce opacity of non-focused entries (0 = invisible, 100 = fully opaque). Default 100% (no alpha change)."
L["REQUIRE_CTRL_COMPLETE_CLICK_COMPLETABLE_QUESTS"]           = "Require Ctrl to complete click-completable quests."
L["REQUIREMENTS"]                                             = "Requirements"
L["REQUIRES_QUEST_TYPE_ICONS_ENABLED_DISPLAY"]                = "Requires quest type icons to be enabled in Display."
L["RESET_MYTHIC_STYLING"]                                     = "Reset Mythic+ styling"
L["REVIEW_MANAGE_QUESTS_YOU_MANUALLY_UNTRACKED"]              = "Review and manage quests you have manually untracked or blacklisted."
L["RIGHT_CLICK_CLOSE_DELAY"]                                  = "Right-click close delay"
L["SANCTUARY_ZONE_COLOUR"]                                    = "Sanctuary zone colour"
L["SCALE_UI_ELEMENTS"]                                        = "Scale all UI elements (50–200%)."
L["PRESENCE_SCENARIO_COMPLETE"]                               = "Scenario Complete"
L["SCENARIO_EVENTS"]                                          = "Scenario events"
L["SCENARIO_PROGRESS"]                                        = "Scenario progress"
L["SCENARIO_PROGRESS_BAR"]                                    = "Scenario progress bar"
L["SCENARIO_START"]                                           = "Scenario start"
L["SCENARIO_TIMER_BAR"]                                       = "Scenario timer bar"
L["SCROLL_INDICATOR"]                                         = "Scroll indicator"
L["SECONDS_OF_RECENT_PROGRESS"]                               = "Seconds of recent progress to show."
L["SECTION_DIVIDER_COLOUR"]                                   = "Section divider colour"
L["SECTION_HEADERS"]                                          = "Section headers"
L["SECTIONS_COLLAPSED"]                                       = "Sections when collapsed"
L["SEPARATE_SCALE_SLIDER_PER_MODULE"]                         = "Separate scale slider per module."
L["SHADOW_OPACITY"]                                           = "Shadow opacity (0–100%)."
L["A_VISUAL_DIVIDER_LINE_BETWEEN_FOCUS"]                      = "Show a visual divider line between Focus sections to make categories easier to distinguish."
L["AFFIX_NAMES_FIRST_DELVE_ENTRY"]                            = "Show affix names on first Delve entry."
L["COLLAPSIBLE_CHOICE_REAGENT_SLOTS"]                         = "Show collapsible choice reagent slots."
L["COMPLETED_ACHIEVEMENTS_LIST"]                              = "Show completed achievements in the list."
L["FINISHING_REAGENT_SLOTS"]                                  = "Show finishing reagent slots."
L["MANY_TIMES_RECIPE_CRAFTED"]                                = "Show how many times the recipe can be crafted."
L["NORMAL_DUNGEONS"]                                          = "Show in Normal dungeons."
L["LOCAL_SYSTEM"]                                             = "Show local system time."
L["NOTIFICATION_A_RARE_MOB_DEFEATED_NEARBY"]                  = "Show notification when a rare mob is defeated nearby."
L["NOTIFICATION_A_SCENARIO_DELVE_FULLY_COM"]                  = "Show notification when a scenario or Delve is fully completed."
L["OBJECTIVE_LINE"]                                           = "Show objective line only."
L["HOVER"]                                                    = "Show only on hover."
L["ACTIVE_INSTANCE_SECTION"]                                  = "Show only the active instance section."
L["OPTIONAL_REAGENT_SLOTS"]                                   = "Show optional reagent slots."
L["RECIPES_TIER_QUALITY_PIPS"]                                = "Show quality tier pips for recipes that support qualities."
L["REAGENT_SHOPPING_LIST_RECIPE"]                             = "Show reagent shopping list for each recipe."
L["FOCUS_AH_SEARCH_TITLE"]                                    = "Search Auction House"
L["FOCUS_AH_SEARCH_TOOLTIP"]                                  = "Left-click: search for one craft worth of reagents (item quality and crafting tier when Auctionator supports them).\nRight-click: craft count and optional crafting tier (menu, 1–5) — choose Any for no quality or tier filters on the list.\nThe Auction House must be open."
L["FOCUS_AH_CRAFT_DIALOG_SUBTITLE"]                           = "Auction House shopping list"
L["FOCUS_AH_CRAFT_HINT_CRAFT_COUNT"]                          = "Number of crafts to buy materials for (1–999). List quantities are multiplied by this."
L["FOCUS_AH_CRAFT_HINT_TIER"]                                 = "Optional crafting tier (1–5) on every row. Choose Any for no item-quality or tier filters (widest search)."
L["FOCUS_AH_CRAFT_TIER_ANY"]                                  = "Any tier"
L["FOCUS_AH_CRAFT_TIER_N"]                                    = "Tier %d"
L["FOCUS_AH_CRAFT_COUNT_INVALID"]                             = "Enter a whole number from 1 to 999."
L["RECENT_PROGRESS_TOP"]                                      = "Show recent progress at the top."
L["RECIPE_ICON_NEXT_TITLE_REQUIRES_QUEST"]                    = "Show recipe icon next to title. Requires quest type icons in Display."
L["SECTION_DIVIDERS"]                                         = "Show section dividers"
L["M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]                      = "Show the M+ block whenever an active keystone is running."
L["TRACKED_PROFESSION_RECIPES_LIST"]                          = "Show tracked profession recipes in the list."
L["TRACKER_HEROIC_DUNGEONS"]                                  = "Show tracker in Heroic dungeons. When unset, uses the master dungeon toggle."
L["TRACKER_HEROIC_RAIDS"]                                     = "Show tracker in Heroic raids. When unset, uses the master raid toggle."
L["TRACKER_LFR_RAID"]                                         = "Show tracker in Looking for Raid. When unset, uses the master raid toggle."
L["TRACKER_MYTHIC_KEYSTONES"]                                 = "Show tracker in Mythic Keystone (M+) dungeons. When unset, uses the master dungeon toggle."
L["TRACKER_MYTHIC_DUNGEONS"]                                  = "Show tracker in Mythic dungeons. When unset, uses the master dungeon toggle."
L["TRACKER_MYTHIC_RAIDS"]                                     = "Show tracker in Mythic raids. When unset, uses the master raid toggle."
L["TRACKER_NORMAL_DUNGEONS"]                                  = "Show tracker in Normal dungeons. When unset, uses the master dungeon toggle."
L["TRACKER_NORMAL_RAIDS"]                                     = "Show tracker in Normal raids. When unset, uses the master raid toggle."
L["TRACKER_PARTY_DUNGEONS"]                                   = "Show tracker in party dungeons (master toggle for all dungeon difficulties)."
L["TRACKER_RAIDS_ALL"]                                        = "Show tracker in raids (master toggle for all raid difficulties)."
L["UNMET_CRAFTING_STATION_REQUIREMENTS"]                      = "Show unmet crafting station requirements."
L["SHOWN_HOVERING_A_MOUNTED_PLAYER"]                          = "Shown when hovering a mounted player."
L["SIZE_SHAPE"]                                               = "Size & shape"
L["SIZE_OF_ZOOM_BUTTONS_PIXELS"]                              = "Size of the + and - zoom buttons (pixels)."
L["SORT_MODE"]                                                = "Sort mode"
L["SORTING_FILTERING"]                                        = "Sorting & Filtering"
L["SOUND_PLAYED_A_RARE_BOSS_APPEARS"]                         = "Sound played when a rare boss appears."
L["STATUS_BADGES"]                                            = "Status badges"
L["SUBZONE_CHANGES"]                                          = "Subzone changes"
L["SUPER_TRACKED_FIRST_CURRENT_ZONE_FIRST"]                   = "Super-tracked first, or current zone first."
L["SUPPRESS_IN_ARENA_DETAIL"]                                 = "Suppress all Presence notifications while inside a PvP arena."
L["SUPPRESS_PRESENCE_NOTIFICATIONS_WHILE_INSIDE_A"]           = "Suppress all Presence notifications while inside a battleground."
L["SUPPRESS_IN_DUNGEON_DETAIL"]                               = "Suppress all Presence notifications while inside a dungeon (except boss emotes, achievements, level-up)."
L["SUPPRESS_IN_RAID_DETAIL"]                                  = "Suppress all Presence notifications while inside a raid."
L["SUPPRESS_M"]                                               = "Suppress in M+"
L["SUPPRESS_PVP"]                                             = "Suppress in PvP"
L["SUPPRESS_BATTLEGROUND"]                                    = "Suppress in battleground"
L["SUPPRESS_DUNGEON"]                                         = "Suppress in dungeon"
L["SUPPRESS_RAID"]                                            = "Suppress in raid"
L["SUPPRESS_NOTIFICATIONS_DUNGEONS"]                          = "Suppress notifications in dungeons."
L["TAKES_PRIORITY_SUPPRESS_UNTIL_RELOAD_ACCEPTING"]           = "Takes priority over suppress-until-reload. Accepting removes from blacklist."
L["TOAST_ICONS"]                                              = "Toast icons"
L["TOGGLE_TRACKING_WORLD_QUESTS_RARES_ACHIEVEMENTS"]          = "Toggle tracking for world quests, rares, achievements, and more."
L["TOOLTIP_ANCHOR"]                                           = "Tooltip anchor"
L["TRACKED_OBJECTIVES_ADVENTURE_GUIDE"]                       = "Tracked objectives from Adventure Guide."
L["TRACKED_VS_LOG_COUNT"]                                     = "Tracked vs in-log count."
L["TRACKED_LOG_LOG_MAX_TRACKED_EXCLUDES"]                     = "Tracked/in-log or in-log/max. Tracked excludes world and in-zone quests."
L["TRANSMOG_STATUS"]                                          = "Transmog status"
L["TRAVELERS_LOG"]                                            = "Traveler's Log"
L["TUNE_SLIDE_FADE_EFFECTS_PLUS_OBJECTIVE"]                   = "Tune slide and fade effects, plus objective progress flashes."
L["UNBLOCK"]                                                  = "Unblock"
L["UNTRACK_COMPLETE"]                                         = "Untrack when complete"
L["CHECKMARK_COMPLETED_OBJECTIVES"]                           = "Use checkmark for completed objectives."
L["VISIBILITY_FADING"]                                        = "Visibility & fading"
L["COMPLETED_QUESTS_STAY_THEIR_ORIGINAL_CATEGO"]              = "When off, completed quests stay in their original category."
L["ZONE_QUESTS_APPEAR_THEIR_NORMAL_CATEGORY"]                 = "When off, in-zone quests appear in their normal category."
L["THEY_MOVE_COMPLETE_SECTION"]                               = "When off, they move to the Complete section."
L["CUSTOM_FILL_COLOUR_BELOW"]                                 = "When off, uses the custom fill colour below."
L["COMPLETED_OBJECTIVES_COLOUR_BELOW"]                        = "When on, completed objectives use the colour below."
L["WHERE_COUNTDOWN"]                                          = "Where to show the countdown."
L["WORLD_QUEST_ACCEPT"]                                       = "World quest accept"
L["WORLD_QUEST_COMPLETE"]                                     = "World quest complete"
L["X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]                   = "X/Y: objectives like 3/10. Percent: objectives like 45%."
L["ZONE_ENTRY"]                                               = "Zone entry"
L["ZONE_LABELS"]                                              = "Zone labels"
L["ZONE_NAME_NEW_ZONE"]                                       = "Zone name still appears when entering a new zone."
L["ZONE_TYPE_COLOURING"]                                      = "Zone type colouring"
L["FOCUS_COMPLETED_CHECKMARK"]                                = "|TInterface\\\\Buttons\\\\UI-CheckBox-Check:12:12:0:0|t instead of green for done objectives."























































































































































