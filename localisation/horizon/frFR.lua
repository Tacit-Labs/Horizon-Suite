if GetLocale() ~= "frFR" then return end

local addon = _G.HorizonSuite
if not addon then return end

local L = setmetatable({}, { __index = addon.L })
addon.L = L
addon.StandardFont = UNIT_NAME_FONT

-- =====================================================================
-- Branding — Horizon Suite, module names, and third-party brand names
-- Never user copy; these are product/brand identifiers only.
-- =====================================================================
-- L["NAME_ADDON"]                                            = "Horizon Suite"
-- L["NAME_ADDON_OBJECTIVES"]                                 = "Focus"
-- L["NAME_ADDON_TOASTS"]                                     = "Presence"
-- L["NAME_ADDON_MINIMAP"]                                    = "Vista"
-- L["NAME_ADDON_TOOLTIPS"]                                   = "Insight"
-- L["NAME_ADDON_CHARACTER"]                                  = "Essence"
-- L["NAME_ADDON_LOOT"]                                       = "Cache"
-- L["NAME_ADDON_C-----S"]                                    = "Meridian"
-- L["NAME_ADDON_DASHBOARD"]                                  = "Axis"
-- L["NAME_DISCORD"]                                          = "Discord"
-- L["NAME_KO_FI"]                                            = "Ko-fi"
-- L["NAME_PATREON"]                                          = "Patreon"
L["NAME_GITHUB"]                                              = "GitLab"
-- L["NAME_CURSEFORGE"]                                       = "CurseForge"
-- L["NAME_WAGO"]                                             = "Wago"
-- L["NAME_TOMTOM"]                                           = "TomTom"
L["OTHER"]                                                    = "Autres"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["QUEST_TYPES"]                                              = "Types de quêtes"
L["ELEMENT_OVERRIDES"]                                        = "Couleurs par élément"
L["PER_CATEGORY"]                                             = "Couleurs par catégorie"
L["GROUPING_OVERRIDES"]                                       = "Couleurs personnalisées"
L["SECTION_OVERRIDES"]                                        = "Couleurs de section"
L["OTHER_COLOURS"]                                            = "Autres couleurs"

-- =====================================================================
-- OptionsPanel.lua — Colour row labels (collapsible group sub-rows)
-- =====================================================================
-- L["FOCUS_SECTION"]                                         = "Section"
L["FOCUS_TITLE"]                                              = "Titre"
-- L["FOCUS_ZONE"]                                            = "Zone"
L["FOCUS_OBJECTIVE"]                                          = "Objectif"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["FOCUS_READY_TURN_OVERRIDES_BASE_COLOURS"]                  = "Choisir des couleurs différentes pour la section À Rendre"
L["FOCUS_READY_TURN_COLOURS_QUESTS"]                          = "La section À Rendre utilisera ses propres couleurs."
L["FOCUS_CURRENT_ZONE_OVERRIDES_BASE_COLOURS"]                = "Choisir des couleurs différentes pour la section Zone Actuelle"
L["FOCUS_CURRENT_ZONE_SECTION_COLOURS"]                       = "La section Zone Actuelle utilisera ses propres couleurs."
L["FOCUS_CURRENT_QUEST_OVERRIDES_BASE_COLOURS"]               = "Choisir des couleurs différentes pour la section Quête actuelle"
L["FOCUS_CURRENT_QUEST_SECTION_COLOURS"]                      = "La section En Cours utilisera ses propres couleurs."
L["FOCUS_DISTINCT_COLOUR_COMPLETED_OBJECTIVES"]               = "Utiliser une couleur distincte pour les objectifs terminés"
L["FOCUS_COMPLETED_OBJECTIVES_COLOURS_CHANGE"]                = "Activé : les objectifs terminés (ex. 1/1) utilisent la couleur suivante. Désactivé : ils utilisent la même couleur que les objectifs incomplets."
L["FOCUS_COMPLETED_OBJECTIVE"]                                = "Objectif terminé"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["FOCUS_RESET"]                                              = "Réinitialiser"
L["FOCUS_RESET_QUEST_TYPES"]                                  = "Réinitialiser les types de quêtes"
L["FOCUS_RESET_OVERRIDES"]                                    = "Réinitialiser les couleurs personnalisées"
L["FOCUS_RESET_DEFAULTS"]                                     = "Tout réinitialiser aux valeurs par défaut"
L["FOCUS_RESET_TO_DEFAULTS"]                                  = "Réinitialiser les valeurs par défaut"
L["FOCUS_RESET_DEFAULT"]                                      = "Réinitialiser la valeur par défaut"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["FOCUS_SEARCH_SETTINGS"]                                    = "Recherche..."
L["SEARCH_FONTS"]                                             = "Rechercher une police..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["FOCUS_DRAG_RESIZE"]                                        = "Glisser pour redimensionner"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
L["PROFILES"]                                                 = "Profils"
-- L["MODULES"]                                               = "Modules"
-- L["MODULE_TOGGLES"]                                        = "Module Toggles"
-- L["MODULE_PREVIEW_DISCLAIMER"]                             = "This module is currently in an early preview (alpha) state. Daily use is not advised due to bugs or unfinished functionality."
L["AXIS_MODULE_NAME_DISPLAY"]                                 = "Module name style"
-- L["AXIS_MODULE_NAME_DISPLAY_DESC"]                         = "How module names appear in the settings panel navigation and search filter."
-- L["AXIS_MODULE_NAME_HORIZON"]                              = "Horizon"
-- L["AXIS_MODULE_NAME_SUBTITLE"]                             = "Subtitle"
-- L["AXIS_MODULE_NAME_SIMPLE"]                               = "Simple"
-- L["AXIS_MODULE_NAME_SIMPLE_DASHBOARD"]                     = "Settings"
-- L["AXIS_MODULE_NAME_SIMPLE_OBJECTIVES"]                    = "Objective Tracker"
-- L["AXIS_MODULE_NAME_SIMPLE_NOTIFICATIONS"]                 = "Notifications"
-- L["AXIS_MODULE_NAME_SIMPLE_MINIMAP"]                       = "Minimap"
-- L["AXIS_MODULE_NAME_SIMPLE_TOOLTIPS"]                      = "Tooltips"
-- L["AXIS_MODULE_NAME_SIMPLE_LOOT"]                          = "Loot Toasts"
-- L["AXIS_MODULE_NAME_SIMPLE_CHARACTER"]                     = "Character Sheet"
-- L["AXIS_MODULE_NAME_SIMPLE_C-----S"]                       = "Meridian"
-- L["MODULE_RELOAD_HINT"]                                    = "Reload the interface to finish applying module changes."
-- L["PROFILE_RELOAD_HINT"]                                   = "Reload the interface to finish applying profile changes."
-- L["RELOAD_UI"]                                             = "Reload UI"

-- =====================================================================
-- options/dashboard/HomeWelcome.lua — First-run welcome
-- =====================================================================
-- L["DASH_WHATS_NEW"]                                        = "Patch Notes"
L["DASH_FULL_CHANGELOG"]                                      = "Full changelog"
-- L["DASH_WHATS_NEW_UNREAD_SUFFIX"]                          = " (New!)"
-- L["DASH_PATCH_NOTES_HEAD_SUB"]                             = "Release history and recent changes"
-- L["DASH_PATCH_NOTES_EMPTY"]                                = "No notes available."
-- L["DASH_PATCH_NOTES_DISMISS"]                              = "Dismiss"
-- L["DASH_PATCH_NOTES_VIEW_ALL"]                             = "View all patch notes"
-- L["DASH_WELCOME_TAB"]                                      = "Welcome"
-- L["DASH_NEWS_TAB"]                                         = "News"
-- L["DASH_SEARCH_TAB"]                                       = "Search"
-- L["DASH_SEARCH_HEAD_SUB"]                                  = "Find any setting quickly"
-- L["DASH_SEARCH_PLACEHOLDER"]                               = "Search settings..."
-- L["DASH_SEARCH_EMPTY_HINT"]                                = "Type at least two characters to search settings, modules, and options."
-- L["DASH_SEARCH_NO_RESULTS"]                                = "No matching settings. Try different words."
-- L["DASH_SEARCH_FILTER_ALL"]                                = "All"
-- L["DASH_SEARCH_FILTER_TOOLTIP"]                            = "Limit search to one module"
-- L["DASH_SEARCH_NO_RESULTS_IN_MODULE"]                      = "No matches in %s. Try All modules or different words."
-- L["DASH_NEWS_HEAD_SUB"]                                    = "Latest updates & community highlights"
-- L["DASH_NEWS_BADGE_NEW"]                                   = "New"
-- L["DASH_NEWS_BADGE_HIGHLIGHT"]                             = "Highlight"
-- L["DASH_NEWS_EYEBROW_FEATURE"]                             = "Feature Update"
-- L["DASH_NEWS_EYEBROW_COMMUNITY"]                           = "Community"
-- L["DASH_NEWS_EYEBROW_ROADMAP"]                             = "Roadmap"
-- L["DASH_NEWS_EYEBROW_GET_STARTED"]                         = "Get Started"
-- L["DASH_NEWS_CTA_OPEN_FOCUS"]                              = "Open Focus settings"
-- L["DASH_NEWS_CTA_VIEW_ARTIST"]                             = "View artist link"
-- L["DASH_NEWS_CTA_OPEN_PATCH_NOTES"]                        = "Open Patch Notes"
L["DASH_NEWS_EDITORIAL_FOOTER_PREFIX"]                        = "News hub • Editorial layout"
-- L["DASH_NEWS_EDITORIAL_FOOTER_LINK"]                       = "Patch notes"
-- L["DASH_NEWS_CTA_OPEN_GUIDE"]                              = "Open Quick Start"
L["DASH_NEWS_FOCUS_CLICK_PROFILE_TITLE"]                      = "Blizzard+ is now the default click profile"
L["DASH_NEWS_FOCUS_CLICK_PROFILE_TAGLINE"]                    = "Focus now lands closer to Blizzard muscle memory while keeping Horizon's convenience options close by."
L["DASH_NEWS_FOCUS_CLICK_PROFILE_BODY"]                       = "The updated preset gives quest rows a cleaner default interaction model. If you want to tune it, head into Focus > Interactions to review the profile today and keep an eye out for Horizon+ and deeper Custom shortcuts next."
L["DASH_NEWS_FOCUS_CLICK_PROFILE_META"]                       = "Focus • Interaction preset • Available now"
-- L["DASH_NEWS_GRADIENT_TOOLTIPS_TITLE"]                     = "Gradient Tooltip Fonts, Dynamic Focus Tooltips, a New! Indicator, and Module Name Options"
-- L["DASH_NEWS_GRADIENT_TOOLTIPS_TAGLINE"]                   = "Surprise! Customise your Insight tooltips with gradient font based on class-style character names and item quality. Highlight newly implemented features with a New! indicator, and experience dynamic tooltips in Focus that intelligently shift their anchor left or right based on screen position."
-- L["DASH_NEWS_GRADIENT_TOOLTIPS_BODY"]                      = "Additionally, we've introduced a new |cffaaaaaaAxis > Module Name Style|r setting, allowing you to choose how module names are displayed: Horizon (code-name only, default), Subtitle (e.g., Vista – Minimap), or Simple/Simple (simplified, plain-language names)."
-- L["DASH_NEWS_GRADIENT_TOOLTIPS_META"]                      = "Insight • Dynamic Tooltips • Gradient Font • Available Now"
-- L["DASH_NEWS_CLASS_ICONS_TITLE"]                           = "A full Horizon class icon set is now bundled"
L["DASH_NEWS_CLASS_ICONS_BODY"]                               = "Switch Class icon style to Horizon under Axis > Global Toggles to use the new set across the suite. The dashboard now surfaces the full strip here so the update reads like a release, not a footnote."
L["DASH_NEWS_CLASS_ICONS_META"]                               = "Axis • Global Toggles • Art by Gabriel C"
L["DASH_NEWS_COMING_SOON_TITLE"]                              = "More curated updates will land here next"
L["DASH_NEWS_COMING_SOON_BODY"]                               = "This space is now structured for featured stories, release highlights, and smaller follow-up cards. Until the next round of updates lands, Patch Notes remains the fastest way to catch every change."
L["DASH_NEWS_HANDHELD_TITLE"]                                 = "Handheld support in the works"
L["DASH_NEWS_HANDHELD_BODY"]                                  = "We're planning better support for smaller screens and handheld play—resize-friendly layouts, sensible defaults when the UI is scaled down, and fewer cramped panels. Details will land in |cffaaaaaaPatch Notes|r as pieces ship."
-- L["DASH_NEWS_COMING_SOON_META"]                            = "News hub • Editorial layout • Curated in addon"
-- L["DASH_NEWS_QUICK_START_TITLE"]                           = "Need the quick tour again?"
-- L["DASH_NEWS_QUICK_START_BODY"]                            = "Quick Start stays a useful companion to News: use it when you want a fast reminder of what each module does, where to enable it, and which pages are worth opening first after an update."
-- L["DASH_NEWS_QUICK_START_META"]                            = "Guide • Onboarding • Always available"
-- L["DASH_WELCOME_TITLE"]                                    = "Welcome to Horizon Suite"
L["DASH_WELCOME_HEAD_SUB"]                                    = "What each module does and where to turn them on"
L["DASH_WELCOME_INTRO"]                                       = "Horizon Suite is modular — enable only the pieces you want. Turning a module on or off applies on reload. Expand Contributors or Localisations below for credits and supported languages. Use Open module toggles under Modules, or open Axis, then Modules, in the sidebar. You can return to this Welcome page anytime from the sidebar."
-- L["DASH_WELCOME_HERO_EYEBROW"]                             = "Welcome"
L["DASH_WELCOME_HERO_TITLE"]                                  = "A modular UI suite that lets you keep only the parts you want."
L["DASH_WELCOME_HERO_TAGLINE"]                                = "Tune Horizon around your tracker, notifications, minimap, tooltips, and character UI without committing to one giant overhaul."
L["DASH_WELCOME_HERO_BODY"]                                   = "Start by choosing the modules you actually want to run, then use the guide below to understand where everything lives. Patch Notes and News stay close by whenever you want a fast catch-up on what changed."
-- L["DASH_WELCOME_START_HERE"]                               = "Start Here"
L["DASH_WELCOME_CTA_MODULES"]                                 = "Open Modules"
-- L["DASH_WELCOME_CTA_PATCH_NOTES"]                          = "Open Patch Notes"
-- L["DASH_WELCOME_CTA_NEWS"]                                 = "Open News"
L["DASH_WELCOME_ACTION_MODULES_TITLE"]                        = "Choose the parts of Horizon you want"
L["DASH_WELCOME_ACTION_MODULES_BODY"]                         = "Use the dashboard home to turn modules on or off, then reload when you are ready to apply larger setup changes."
L["DASH_WELCOME_ACTION_UPDATES_TITLE"]                        = "Catch up on what changed"
L["DASH_WELCOME_ACTION_UPDATES_BODY"]                         = "Patch Notes and News are the fastest way to see new presets, art, polish passes, and module changes between releases."
L["DASH_WELCOME_ACTION_NEWS_TITLE"]                           = "See the editorial update feed"
L["DASH_WELCOME_ACTION_NEWS_BODY"]                            = "Open News for featured stories, roadmap notes, art highlights, and smaller curated updates in one place."
L["DASH_WELCOME_LEARN_BODY"]                                  = "Use this section as the guided overview of Horizon: what each module does, how to get started, and where to go next once the basics are in place."
L["DASH_WELCOME_PATH"]                                        = "%s → %s → %s"
-- L["DASH_WELCOME_FOCUS_BLIZZARD_PLUS_HEADING"]              = "Blizzard+ click profile"
L["DASH_WELCOME_FOCUS_BLIZZARD_PLUS_BODY"]                    = [=[Focus now uses |cffffffffBlizzard+|r by default — Blizzard-style quest row clicks with a few Horizon conveniences. Open |cffaaaaaaFocus > Interactions|r and use |cffaaaaaaClick profile|r to see the preset; |cffffffffHorizon+|r and full |cffffffffCustom|r shortcuts are on the way.]=]
-- L["DASH_WELCOME_COMING_SOON_TITLE"]                        = "Coming Soon"
-- L["DASH_WELCOME_COMING_SOON_TAGLINE"]                      = "New welcome experiences are on the way."
-- L["DASH_WELCOME_COMING_SOON_BODY"]                         = [=[Watch this space — we will post updates here and in |cffaaaaaaPatch Notes|r. Join |cffaaaaaaDiscord|r from the links below for news and feedback.]=]
L["DASH_WELCOME_CLASS_ICONS_HEADING"]                         = "Horizon class icons"
L["DASH_WELCOME_CLASS_ICONS_LEAD"]                            = [=[We have added a bundled set of custom class icons — now the default when you choose |cffaaaaaaHorizon|r under |cffaaaaaaAxis → Global Toggles|r (Class icon style).]=]
-- L["DASH_WELCOME_CLASS_ICONS_THANK_BOOFULS"]                = [=[Thank you, Boofuls, for commissioning this art and helping bring these icons to everyone.]=]
-- L["DASH_WELCOME_CLASS_ICONS_CREATED_PREFIX"]               = "• Created by "
-- L["DASH_WELCOME_CLASS_ICONS_ARTIST_NAME"]                  = "Gabriel C"
-- L["DASH_WELCOME_CONTRIBUTORS_HEADING"]                     = "Contributors"
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
-- L["DASH_WELCOME_SUPPORTERS_HEADING"]                       = "Supporters"
-- L["DASH_WELCOME_SUPPORTERS_BODY"]                          = [=[Thank you to everyone who supports Horizon Suite through Ko-fi, Patreon, and other channels.]=]
-- L["DASH_WELCOME_LOCALISATIONS_HEADING"]                    = "Localisations"
-- L["DASH_WELCOME_LOCALISATIONS_BODY"] = ... (falls back to enUS until retranslated against new path layout)


-- =====================================================================
-- options/dashboard/ModuleGuide.lua — In-game module quick-start
-- =====================================================================
L["DASH_GUIDE_TAB"]                                           = "Guide"
-- L["DASH_GUIDE_HEAD_SUB"]                                   = "What each part of Horizon does"
-- L["DASH_GUIDE_HERO_TITLE"]                                 = "Getting started with Horizon Suite"
L["DASH_GUIDE_HERO_TAGLINE"]                                  = "A modular UI toolkit for quests, notifications, the minimap, and more."
L["DASH_GUIDE_HERO_INTRO"]                                    = "Pick the modules you want, tune them in the sidebar, and reload when you toggle something on or off. This page is always here — open it anytime from the Guide row under Welcome."
-- L["DASH_GUIDE_HERO_THEME_PROMPT"]                          = [=[Under |cffaaaaaaAxis > Global Settings|r, set |cff73b4ff|Hhsdash:classcolours|hclass-colour tinting|h|r for the dashboard and modules, and pick a |cff73b4ff|Hhsdash:theme|hDashboard theme|h|r.]=]
L["DASH_GUIDE_HORIZON_HEADING"]                               = "What is Horizon Suite?"
L["DASH_GUIDE_HORIZON_BULLETS"]                               = [=[• Axis — Profiles, module on/off, global toggles, typography, and other suite-wide settings.
• Focus — Quest and content tracker: quests, world quests, scenarios, rares, achievements, and more in coloured sections.
• Presence — Large cinematic toasts for zones, quests, scenarios, achievements, level up, and similar moments.
• Vista — Minimap chrome: zone text, coordinates, clock, and a collector for minimap buttons.
• Insight — Richer tooltips for players, NPCs, and items (class colours, spec, icons, extras).
• Cache — Loot toasts and bag presentation.
• Essence — Character sheet with 3D model, item level, stats, and gear grid.
• Meridian — Coming soon.]=]
L["DASH_GUIDE_MOD_AXIS_BODY"]                                 = "Axis is the control centre: switch profiles, enable or disable whole modules, open Global Toggles for class colours and UI scale, and reach typography and appearance options that apply across Horizon. Start here when you first install or when you want a lighter footprint by turning modules off."
L["DASH_GUIDE_MOD_FOCUS_BODY"]                                = [=[Focus replaces the default objective list with a flexible tracker. Tracked quests, world quests, scenarios, rares, achievements, endeavors, decor, recipes, and more are grouped into coloured section headers so you can scan quickly.
Sections only appear when they have something to show — for example Current (recent progress), Current zone, Ready to turn in, World / weekly / daily / Prey, campaign and special quests, delves and scenarios, rare bosses and loot, achievements and collections, and time-limited or zone events.

Use Focus → Sorting & filtering to reorder sections, and Focus → Content to choose which types of content appear.]=]
-- L["DASH_GUIDE_PRESENCE_INTRO"]                             = "Presence shows large, styled alerts for moments that used to be separate Blizzard popups — zone changes, quest progress, achievements, scenarios, and more. You can turn each type on or off and tune typography in Presence settings."
L["DASH_GUIDE_PRESENCE_BODY"]                                 = [=[Typical Presence toasts include:
• Zone and subzone discovery text when you enter new areas.
• Quest accepted, objective progress, quest complete, and world quest complete.
• Scenario start, progress updates, and completion (including delve-style flow).
• Achievements earned and optional achievement progress ticks.
• Level up, boss emotes, and rare defeated.]=]
-- L["DASH_GUIDE_PRESENCE_BLIZZARD"]                          = [=[When a Presence type is enabled, Horizon can hide the matching default UI so you don’t get duplicates — for example zone name banners, the level-up frame, boss emote bar, event toast manager, world-quest completion banner, and some objective bonus banners. Turn a Presence type off in settings to let the default game UI show again for that category.]=]
-- L["DASH_GUIDE_MOD_VISTA_BODY"]                             = "Vista wraps your minimap with readable zone and subzone text, optional coordinates and clock, and a bar that collects stray minimap buttons so they stay tidy. Tune layout and colours under Vista in the sidebar."
-- L["DASH_GUIDE_MOD_INSIGHT_BODY"]                           = "Insight extends Blizzard tooltips for players, NPCs, and items — class and faction colouring, spec and icon lines, optional Mythic+ score, item level, mount collection hints, and cleaner separators. Each tooltip type has its own category under Insight."
-- L["DASH_GUIDE_MOD_CACHE_BODY"]                             = "Cache handles loot feedback: styled loot toasts for items, money, currency, and reputation, plus options that tie into how rewards are shown. Enable it when you want Horizon’s presentation instead of the default loot popups."
-- L["DASH_GUIDE_MOD_ESSENCE_BODY"]                           = "Essence is an optional character sheet: 3D model, item level, primary stats, and a gear grid so you can review your equipment at a glance. Open Essence in the sidebar to adjust layout and visibility."
L["DASH_GUIDE_MOD_MERIDIAN_BODY"]                             = "Coming soon."
L["DASH_AXIS_MODULE_SHORT_DESCRIPTION"]                       = "Core settings hub: profiles, modules, and global toggles."
-- L["DASH_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS"]            = "Objective tracker for quests, world quests, rares, achievements, scenarios."
-- L["DASH_ZONE_TEXT_AND_NOTIFICATIONS"]                      = "Zone text and notifications."
-- L["DASH_MINIMAP_ZONE_TEXT_COORDS_BUTTON"]                  = "Minimap with zone text, coords, time, and button collector."
-- L["DASH_TOOLTIPS_CLASS_COLOURS_SPEC_FACTION"]              = "Tooltips with class colours, spec, and faction icons."
-- L["DASH_LOOT_TOASTS_ITEMS_MONEY_CURRENCY"]                 = "Loot toasts for items, money, currency, reputation, and bag overhaul."
-- L["DASH_ESSENCE_MODULE_SHORT_DESCRIPTION"]                 = "Custom character sheet with 3D model, item level, stats, and gear grid."
L["DASH_MERIDIAN_MODULE_SHORT_DESCRIPTION"]                   = "Coming soon."
-- L["DASH_WELCOME_COMMUNITY_HEADING"]                        = "Community & Support"
-- L["DASH_COPY_LINK_X"]                                      = "Copy link — %s"
-- L["HOME_HEAD_SUB"]                                         = "Enable and configure your modules"
L["HOME_MOD_FOCUS_SHORT"]                                     = "Track spells, cooldowns, and procs."
L["HOME_MOD_PRESENCE_SHORT"]                                  = "Enhance nameplates and unit frames."
L["HOME_MOD_VISTA_SHORT"]                                     = "Enrich the world map and minimap."
L["HOME_MOD_INSIGHT_SHORT"]                                   = "Add context to tooltips and inspects."
L["HOME_MOD_CACHE_SHORT"]                                     = "Smart loot and item management."
L["HOME_MOD_ESSENCE_SHORT"]                                   = "Custom HUD elements and action bars."
-- L["DASH_RESIZE_TOOLTIP"]                                   = "Drag to resize\nRight-click to reset"
-- L["HOME_RELOAD_PROMPT"]                                    = "Reload to apply module changes."
-- L["RELOAD_UI"]                                             = "Reload UI"
L["DASH_LAYOUT"]                                              = "Disposition"
L["DASH_VISIBILITY"]                                          = "Visibilité"
L["DASH_DISPLAY"]                                             = "Affichage"
L["DASH_FEATURES"]                                            = "Fonctionnalités"
L["DASH_TYPOGRAPHY"]                                          = "Textes"
L["DASH_APPEARANCE"]                                          = "Apparence"
-- L["DASH_CLICK_OPTIONS"]                                    = "Click Options"
L["DASH_COLOURS"]                                             = "Couleurs"
-- L["DASH_ORGANISATION"]                                     = "Organisation"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["FOCUS_PANEL_BEHAVIOUR"]                                    = "Comportement du panneau"
-- L["FOCUS_DIMENSIONS"]                                      = "Dimensions"
-- L["FOCUS_INSTANCE"]                                        = "Instance"
-- L["FOCUS_INSTANCES"]                                       = "Instances"
-- L["FOCUS_COMBAT"]                                          = "Combat"
L["FOCUS_FILTERING"]                                          = "Filtres"
L["FOCUS_HEADER"]                                             = "En-tête"
L["FOCUS_SECTIONS_STRUCTURE"]                                 = "Sections & structure"
L["FOCUS_ENTRY_DETAILS"]                                      = "Détails de l'élément"
L["FOCUS_PROGRESS_TIMERS"]                                    = "Progressions & décomptes"
L["FOCUS_EMPHASIS"]                                           = "Mise en évidence"
L["FOCUS_LIST"]                                               = "Liste"
L["FOCUS_SPACING"]                                            = "Espacement"
L["FOCUS_RARE_BOSSES"]                                        = "Boss rares"
L["FOCUS_WORLD_QUESTS"]                                       = "Expéditions"
L["FOCUS_FLOATING_QUEST_ITEM"]                                = "Objet de quête flottant"
L["FOCUS_MYTHIC"]                                             = "Mythique+"
L["FOCUS_ACHIEVEMENTS"]                                       = "Hauts faits"
L["FOCUS_ACHIEVEMENT_PROGRESS_BARS"]                          = "Achievement progress bars"
-- L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_DESC"]                  = "Show a progress bar under tracked achievements that report numeric criteria (including 0/1 and X/Y). Independent of Quest Progress Bars."
-- L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_TIP"]                   = "Uses the same bar colours, texture, and font as other Focus progress bars when those options are visible."
L["FOCUS_ENDEAVORS"]                                          = "Initiatives"
L["FOCUS_DECOR"]                                              = "Décoration"
-- L["FOCUS_APPEARANCES"]                                     = "Appearances"
L["FOCUS_SCENARIO_DELVE"]                                     = "Scénario et Gouffre"
L["FOCUS_FONT"]                                               = "Police"
L["FOCUS_FONT_FAMILIES"]                                      = "Familles de polices"
L["FOCUS_GLOBAL_FONT_SIZE"]                                   = "Taille du texte global"
L["FOCUS_FONT_SIZES"]                                         = "Tailles des textes"
L["FOCUS_PER_ELEMENT_FONTS"]                                  = "Polices par élément"
L["FOCUS_TEXT_CASE"]                                          = "Casse"
L["FOCUS_SHADOW"]                                             = "Ombre"
L["FOCUS_PANEL"]                                              = "Panneau"
L["FOCUS_HIGHLIGHT"]                                          = "Surbrillance"
L["FOCUS_COLOUR_MATRIX"]                                      = "Matrice de couleurs"
L["FOCUS_ORDER"]                                              = "Ordre"
L["FOCUS_SORT"]                                               = "Tri"
L["FOCUS_BEHAVIOUR"]                                          = "Comportement"
L["FOCUS_CONTENT_TYPES"]                                      = "Types de contenu"
L["FOCUS_DELVES"]                                             = "Gouffres"
L["FOCUS_DELVES_DUNGEONS"]                                    = "Gouffres & Donjons"
L["FOCUS_DELVE_COMPLETE"]                                     = "Gouffre terminé"
-- L["FOCUS_INTERACTIONS"]                                    = "Interactions"
-- L["FOCUS_LAYOUT_TAB_DESC"]                                 = "Configure and customise settings related to layout."
-- L["FOCUS_APPEARANCE_TAB_DESC"]                             = "Tracker panel look, fading, and list layout (header, sections, entries, timers, emphasis)."
-- L["FOCUS_CLICK_OPTIONS_TAB_DESC"]                          = "Click profile, per-combo actions, and optional safety toggles for the tracker."
-- L["FOCUS_INTERACTIONS_TAB_DESC"]                           = "Configure quest tracking rules and TomTom integration."
L["FOCUS_TRACKING"]                                           = "Suivi"
L["FOCUS_SCENARIO_BAR"]                                       = "Barre de scénario"

-- =====================================================================
-- OptionsData.lua Profiles
-- =====================================================================
L["AXIS_CURRENT_PROFILE"]                                     = "Current profile"
-- L["AXIS_SELECT_PROFILE_CURRENTLY"]                         = "Select the profile currently in use."
-- L["AXIS_GLOBAL_PROFILE_ACCOUNT_WIDE"]                      = "Use global profile (account-wide)"
-- L["AXIS_CHARACTERS_SAME_PROFILE"]                          = "All characters use the same profile."
-- L["AXIS_ENABLE_PER_SPECIALIZATION_PROFILES"]               = "Enable per specialization profiles"
-- L["AXIS_PICK_DIFFERENT_PROFILES_PER_SPEC"]                 = "Pick different profiles per spec."
-- L["AXIS_SPECIALIZATION"]                                   = "Specialization"
-- L["AXIS_SPEC_PROFILES"]                                    = "Spec Profiles"
-- L["AXIS_ENABLE"]                                           = "Enable"
-- L["AXIS_SHARING"]                                          = "Sharing"
L["AXIS_IMPORT_PROFILE"]                                      = "Import profile"
L["AXIS_IMPORT_STRING"]                                       = "Import string"
L["AXIS_EXPORT_PROFILE"]                                      = "Export profile"
-- L["AXIS_SELECT_A_PROFILE_EXPORT"]                          = "Select a profile to export."
L["AXIS_EXPORT_STRING"]                                       = "Export string"
L["AXIS_COPY_PROFILE"]                                        = "Copy from profile"
L["AXIS_SOURCE_PROFILE_COPYING"]                              = "Source profile for copying."
L["AXIS_COPY_SELECTED"]                                       = "Copy from selected"
-- L["AXIS_CREATE"]                                           = "Create"
-- L["AXIS_CREATE_PROFILE_DEFAULT_TEMPLATE"]                  = "Create new profile from Default template"
-- L["AXIS_CREATES_A_PROFILE_DEFAULT_SETTINGS"]               = "Creates a new profile with all default settings."
-- L["AXIS_CREATES_A_PROFILE_COPIED_SELECTED_SOURC"]          = "Creates a new profile copied from the selected source profile."
L["AXIS_DELETE_PROFILE"]                                      = "Delete profile"
-- L["AXIS_SELECT_A_PROFILE_DELETE_CURRENT_DEFAULT"]          = "Select a profile to delete (current and Default not shown)."
L["AXIS_DELETE_SELECTED"]                                     = "Delete selected"
L["AXIS_DELETE_SELECTED_PROFILE"]                             = "Delete selected profile"
-- L["AXIS_DELETE"]                                           = "Delete"
L["AXIS_DELETES_SELECTED_PROFILE"]                            = "Deletes the selected profile."
L["AXIS_GLOBAL_PROFILE"]                                      = "Global profile"
L["AXIS_PER_SPEC_PROFILES"]                                   = "Per-spec profiles"

-- =====================================================================
-- OptionsData.lua Modules
-- =====================================================================
L["AXIS_ENABLE_FOCUS_MODULE"]                                 = "Activer le module Focus"
L["AXIS_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS_R"]             = "Affiche le suivi des objectifs pour les quêtes, expéditions, boss rares, hauts faits et scénarios."
L["AXIS_ENABLE_PRESENCE_MODULE"]                              = "Activer le module Presence"
L["AXIS_CINEMATIC_ZONE_TEXT_NOTIFICATIONS_ZONE_CHANGES"]      = "Texte de zone cinématique et notifications (changement de zone, montée de niveau, emotes de boss, hauts faits, mises à jour de quêtes)."
L["AXIS_ENABLE_CACHE_MODULE"]                                 = "Activer le module Cache"
L["AXIS_CINEMATIC_LOOT_NOTIFICATIONS_ITEMS_MONEY_CURRENCY"]   = "Alertes cinématiques de butin (objets, argent, monnaies, réputation)."
L["AXIS_ENABLE_VISTA_MODULE"]                                 = "Activer le module Vista"
L["AXIS_CINEMATIC_SQUARE_MINIMAP_ZONE_TEXT_COORDINATES"]      = "Minicarte carrée cinématique avec texte de zone, coordonnées et rubrique à boutons."
L["AXIS_MINIMAP_ZONE_TIME_COLLECTOR"]                         = "Minicarte carrée cinématique avec texte de zone, coordonnées, horloge et conteneur de boutons."
L["AXIS_SCALING"]                                             = "Mise à l'échelle"
L["AXIS_GLOBAL_TOGGLES"]                                      = "Réglages globaux"
-- L["AXIS_DASHBOARD_SECTION"]                                = "Dashboard"
-- L["AXIS_GLOBAL_FONT_SECTION"]                              = "Global Font (Coming Soon!)"
-- L["AXIS_GLOBAL_SCALE_SECTION"]                             = "Global Scale"
-- L["AXIS_MINIMAP_ICON_SECTION"]                             = "Minimap Icon"
-- L["AXIS_CLASS_THEME_SECTION"]                              = "Class Theme"
-- L["AXIS_GLOBAL_CLASS_THEME"]                               = "Global Class Theme"
-- L["AXIS_CLASS_THEME_DASHBOARD"]                            = "Dashboard"
-- L["AXIS_CLASS_THEME_DASHBOARD_DESC"]                       = "Enables Dashboard class theming. Flipping it on turns on Class Colours, Dashboard Class Icon, and Override Background; each sub-option can then be adjusted independently while the master stays on."
-- L["AXIS_DASHBOARD_CLASS_COLOURS"]                          = "Class Colours"
-- L["AXIS_DASHBOARD_CLASS_ICON"]                             = "Dashboard Class Icon"
-- L["AXIS_DASHBOARD_CLASS_ICON_DESC"]                        = "Show a class icon on the Dashboard. Independent of class colour tinting and of the class background override."
-- L["AXIS_DASHBOARD_BG_CLASS_OVERRIDE"]                      = "Override Background to Class Background"
-- L["AXIS_DASHBOARD_BG_CLASS_OVERRIDE_DESC"]                 = "Replace the Dashboard background with a class-themed background. Independent of class colour tinting and of the class icon."
L["AXIS_PATCH_NOTES_SECTION"]                                 = "Patch notes"
L["AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN"]                      = "Show Patch Notes automatically after an update"
-- L["AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN_DESC"]              = "When on, Axis opens to Patch Notes once after each new addon version. When off, a green dot appears on the Horizon minimap icon until you open Patch Notes."
L["AXIS_SUITE_WIDE_CLASS_COLOUR_TINTING_UI"]                  = "Teintes de couleur de classe et échelle d'interface pour toute la suite (globale ou par module)."
L["AXIS_GLOBAL_UI_SCALE"]                                     = "Échelle globale de l'interface"
L["AXIS_SCALE_SIZES_SPACINGS_FONTS_FACTOR"]                   = "Met à l'échelle toutes les tailles, espacements et polices selon ce facteur (50–200 %). Ne modifie pas vos valeurs configurées."
L["AXIS_PER_MODULE_SCALING"]                                  = "Échelle par module"
L["AXIS_OVERRIDE_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_FO"]         = "Remplace l'échelle globale par des curseurs individuels pour chaque module."
L["AXIS_OVERRIDES_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_F"]         = "Utiliser des glissières d'échelle individuelles pour les modules Focus, Presence, Vista, etc."
L["AXIS_DOESN_T_CHANGE_YOUR_CONFIGURED_VALUES"]               = "Ne change pas vos valeurs de réglages, seulement la mise à l'échelle de l'interface."
L["FOCUS_SCALE"]                                              = "Échelle Focus"
L["AXIS_SCALE_FOCUS_OBJECTIVE_TRACKER"]                       = "Échelle du suivi d'objectifs Focus (50–200 %)."
L["PRESENCE_SCALE"]                                           = "Échelle Presence"
L["AXIS_SCALE_PRESENCE_CINEMATIC_TEXT"]                       = "Échelle du texte cinématique Presence (50–200 %)."
L["VISTA_SCALE"]                                              = "Échelle Vista"
L["AXIS_SCALE_VISTA_MINIMAP_MODULE"]                          = "Échelle du module de minicarte Vista (50–200 %)."
L["INSIGHT_SCALE"]                                            = "Échelle Insight"
L["AXIS_SCALE_INSIGHT_TOOLTIP_MODULE"]                        = "Échelle du module d'infobulle Insight (50–200 %)."
L["CACHE_SCALE"]                                              = "Échelle Cache"
L["AXIS_SCALE_CACHE_LOOT_TOAST_MODULE"]                       = "Échelle du module d'alerte de butin Cache (50–200 %)."
-- L["CACHE_FONT"]                                            = "Loot toast font"
-- L["CACHE_FONT_FAMILY"]                                     = "Font family used for loot toast text. Use 'Use global font' to follow the addon-wide font."
L["AXIS_ENABLE_HORIZON_INSIGHT_MODULE"]                       = "Activer le module Horizon Insight"
L["AXIS_CINEMATIC_TOOLTIPS_CLASS_COLOURS_SPEC_DISPLAY"]       = "Infobulles cinématiques avec couleurs de classe, spécialisation et icônes de faction."
L["AXIS_TOOLTIP_ANCHOR_MODE"]                                 = "Mode d'ancrage des infobulles"
L["AXIS_WHERE_TOOLTIPS_APPEAR_FOLLOW_CURSOR_FIXED"]           = "Où les infobulles s'affichent : suivre le curseur ou position fixe."
L["AXIS_CURSOR"]                                              = "Curseur"
L["AXIS_FIXED"]                                               = "Fixe"
L["INSIGHT_CURSOR_SIDE"]                                      = "Cursor side"
-- L["INSIGHT_CURSOR_SIDE_DESC"]                              = "Which side of the cursor the tooltip appears on."
-- L["INSIGHT_CURSOR_SIDE_CENTER"]                            = "Center"
-- L["INSIGHT_CURSOR_SIDE_LEFT"]                              = "Left"
-- L["INSIGHT_CURSOR_SIDE_RIGHT"]                             = "Right"
L["AXIS_ANCHOR_MOVE"]                                         = "Afficher les poignées de déplacement"
L["AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITION"]                     = "Cliquer pour montrer ou cacher l'ancre. Glisser pour positionner, clic droit pour confirmer."
L["AXIS_DRAGGABLE_FRAME_FIXED_TOOLTIP_POSITION_DESC"]         = "Affiche un cadre déplaçable pour définir la position fixe. Glisser, puis clic droit pour confirmer."
L["AXIS_RESET_TOOLTIP_POSITION"]                              = "Réinitialiser la position des infobulles"
L["AXIS_RESET_FIXED_POSITION_DEFAULT"]                        = "Réinitialiser la position fixe par défaut."
L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED"]                           = "Dynamic position for Focus tooltips"
-- L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED_DESC"]                   = "When fixed anchor is on, Focus tracker tooltips still attach to the outer edge of the Horizon panel so they never cover the tracker."
L["INSIGHT_CURSOR_OFFSET_X"]                                  = "Cursor offset X"
L["INSIGHT_CURSOR_OFFSET_X_DESC"]                             = "Horizontal pixel offset from the default cursor tooltip position (cursor anchor only)."
L["INSIGHT_CURSOR_OFFSET_Y"]                                  = "Cursor offset Y"
L["INSIGHT_CURSOR_OFFSET_Y_DESC"]                             = "Vertical pixel offset from the default cursor tooltip position (cursor anchor only)."
L["AXIS_TOOLTIP_BACKGROUND_COLOUR"]                           = "Couleur de fond des infobulles"
L["AXIS_COLOUR_OF_TOOLTIP_BACKGROUND"]                        = "Couleur de fond des infobulles."
L["AXIS_TOOLTIP_BACKGROUND_OPACITY"]                          = "Opacité du fond des infobulles"
L["AXIS_TOOLTIP_BG_OPACITY_PCT_DESC"]                         = "Opacité du fond des infobulles (0–100 %)."
L["AXIS_TOOLTIP_FONT"]                                        = "Police de l'infobulle"
L["AXIS_FONT_FAMILY_TOOLTIP_TEXT"]                            = "Famille de police utilisée pour le texte de l'infobulle."
L["INSIGHT_BODY_SIZE"]                                        = "Body size"
L["INSIGHT_BODY_FONT_SIZE"]                                   = "Body font size."
L["INSIGHT_BADGES_SIZE"]                                      = "Badges size"
L["INSIGHT_BADGES_FONT_SIZE"]                                 = "Status badges font size."
L["INSIGHT_STATS_SIZE"]                                       = "Stats size"
L["INSIGHT_STATS_FONT_SIZE"]                                  = "M+ score, item level, and honor level font size."
L["INSIGHT_MOUNT_SIZE"]                                       = "Mount size"
-- L["INSIGHT_MOUNT_FONT_SIZE"]                               = "Mount name, source, and ownership font size."
L["INSIGHT_MOUNT_OWNERSHIP_DISPLAY"]                          = "Mount collection indicator"
-- L["INSIGHT_MOUNT_OWNERSHIP_DISPLAY_DESC"]                  = "How to show whether you have collected the hovered player's mount."
L["INSIGHT_MOUNT_OWNERSHIP_TEXT"]                             = "Full text"
L["INSIGHT_MOUNT_OWNERSHIP_ICONS"]                            = "Tick / cross"
-- L["INSIGHT_MOUNT_OWNED"]                                   = "You own this mount"
-- L["INSIGHT_MOUNT_NOT_OWNED"]                               = "You don't own this mount"
L["INSIGHT_TRANSMOG_SIZE"]                                    = "Transmog size"
-- L["INSIGHT_TRANSMOG_FONT_SIZE"]                            = "Item appearance status font size."
L["AXIS_TOOLTIPS"]                                            = "Infobulles"
-- L["INSIGHT_CATEGORY_GLOBAL"]                               = "Global Tooltips"
L["INSIGHT_CATEGORY_GLOBAL_DESC"]                             = "Anchor, backdrop, fonts, sizes, and display options shared across tooltip types."
-- L["INSIGHT_CATEGORY_PLAYER"]                               = "Player Characters"
L["INSIGHT_CATEGORY_PLAYER_DESC"]                             = "Guild rank, titles, badges, PvP, ratings, gear, and mount lines on player tooltips."
-- L["INSIGHT_CATEGORY_NPC"]                                  = "NPCs"
L["INSIGHT_CATEGORY_NPC_DESC"]                                = "NPC tooltip styling. Extra NPC-only toggles can be added here later."
-- L["INSIGHT_CATEGORY_ITEM"]                                 = "Items"
-- L["INSIGHT_CATEGORY_ITEM_DESC"]                            = "Item tooltip options such as transmog collection status."
-- L["INSIGHT_SECTION_IDENTITY"]                              = "Identity"
L["INSIGHT_PLAYER_NAME_COLOUR"]                               = "Player name colour"
-- L["INSIGHT_PLAYER_NAME_COLOUR_DESC"]                       = "Colour for the player's name on the first tooltip line: faction (Alliance blue, Horde red) or class."
-- L["INSIGHT_PLAYER_NAME_COLOUR_FACTION"]                    = "Faction"
-- L["INSIGHT_PLAYER_NAME_COLOUR_CLASS"]                      = "Class"
-- L["INSIGHT_PLAYER_NAME_GRADIENT"]                          = "Class Colour Gradient"
-- L["INSIGHT_PLAYER_NAME_GRADIENT_DESC"]                     = "Render the player name as a two-stop gradient of their class colour (only applies when the name colour is set to Class)."
-- L["INSIGHT_SECTION_STATUS_PVP"]                            = "Status & PvP"
L["INSIGHT_SECTION_RATINGS_GEAR"]                             = "Ratings & gear"
L["INSIGHT_SPEC_ROLE"]                                        = "Spec icon & role"
-- L["INSIGHT_SPEC_ROLE_DESC"]                                = "Show the player's specialization icon and role after inspecting them. Disable to stop Insight from calling NotifyInspect on mouseover."
-- L["INSIGHT_SECTION_MOUNT"]                                 = "Mount"
L["INSIGHT_SECTION_DISMISS"]                                  = "Unit tooltip dismiss"
L["INSIGHT_DISMISS_GRACE"]                                    = "Dismiss grace"
L["INSIGHT_DISMISS_GRACE_DESC"]                               = "How long to wait after the mouse leaves a unit before starting to hide the GameTooltip. Longer grace reduces flicker from brief cursor gaps."
-- L["INSIGHT_DISMISS_GRACE_INSTANT"]                         = "Instant"
-- L["INSIGHT_DISMISS_GRACE_DEFAULT"]                         = "Normal"
-- L["INSIGHT_DISMISS_GRACE_RELAXED"]                         = "Relaxed"
-- L["INSIGHT_SECTION_COMBAT"]                                = "Combat"
L["INSIGHT_HIDE_IN_COMBAT"]                                   = "Hide tooltips in combat"
-- L["INSIGHT_HIDE_IN_COMBAT_DESC"]                           = "While in combat, close GameTooltip and other Insight-styled tooltip frames and block them from staying open. Applies only when the Insight module is enabled."
L["INSIGHT_FADE_OUT_SEC"]                                     = "Fade-out duration"
L["INSIGHT_FADE_OUT_SEC_DESC"]                                = "Seconds to fade the unit tooltip after dismiss starts. Zero hides immediately (no fade). Applies to GameTooltip unit tips only."
L["INSIGHT_SECTION_ICONS_AND_SEPARATORS"]                     = "Icons & separators"
L["INSIGHT_SECTION_NPC_TOOLTIP"]                              = "NPC tooltip"
-- L["INSIGHT_SECTION_TRANSMOG"]                              = "Transmog"
-- L["INSIGHT_NPC_PLACEHOLDER"]                               = "NPC-specific options will appear here when available. Reaction colours and level lines still apply in-game."
L["INSIGHT_NPC_REACTION_BORDER"]                              = "Reaction border"
-- L["INSIGHT_NPC_REACTION_BORDER_DESC"]                      = "Tint the tooltip border to the NPC's faction reaction (hostile red, friendly green, neutral yellow)."
L["INSIGHT_NPC_REACTION_NAME"]                                = "Reaction name colour"
-- L["INSIGHT_NPC_REACTION_NAME_DESC"]                        = "Colour the NPC's name to match their faction reaction."
L["INSIGHT_NPC_LEVEL_LINE"]                                   = "Level line"
-- L["INSIGHT_NPC_LEVEL_LINE_DESC"]                           = "Show the NPC's level, classification (Elite, Rare, etc.), and creature type beneath their name."
-- L["INSIGHT_NPC_ICONS_DESC"]                                = "Show an icon instead of '??' for NPCs with an unknown level."
L["INSIGHT_SECTION_ITEM_STYLING"]                             = "Item styling"
L["INSIGHT_ITEM_QUALITY_BORDER"]                              = "Quality border"
-- L["INSIGHT_ITEM_QUALITY_BORDER_DESC"]                      = "Tint the tooltip border to the item's quality colour (Uncommon green, Rare blue, Epic purple, etc.)."
-- L["INSIGHT_ITEM_NAME_GRADIENT"]                            = "Quality Gradient Name"
-- L["INSIGHT_ITEM_NAME_GRADIENT_DESC"]                       = "Render the item name as a two-stop gradient of its quality colour (Uncommon green, Rare blue, Epic purple, etc.)."
L["INSIGHT_ITEM_SECTION_SPACING"]                             = "Blank line before blocks"
-- L["INSIGHT_ITEM_SECTION_SPACING_DESC"]                     = "Insert a blank line before Insight blocks on item tooltips instead of a tinted separator line."
L["AXIS_ITEM_TOOLTIP"]                                        = "Description d'objet"
L["AXIS_TRANSMOG_STATUS"]                                     = "Afficher l'état de transmogrification"
L["AXIS_WHETHER_YOU_COLLECTED_APPEARANCE_OF_AN"]              = "Montrer si l'apparence de l'objet a déjà été collecté."
L["AXIS_PLAYER_TOOLTIP"]                                      = "Infobulle du joueur"
L["AXIS_GUILD_RANK"]                                          = "Montrer le rang de guilde"
L["AXIS_APPEND_PLAYER_S_GUILD_RANK_NEXT"]                     = "Ajouter le rang de la guilde du joueur à la suite de son nom."
L["AXIS_MYTHIC_SCORE"]                                        = "Montrer le score Mythique+"
L["AXIS_PLAYER_S_CURRENT_SEASON_MYTHIC_SCORE"]                = "Montrer le score Mythique+ de la saison actuelle du joueur, colouré par palier."
L["AXIS_ITEM_LEVEL"]                                          = "Montrer le niveau d'objet"
L["AXIS_PLAYER_S_EQUIPPED_ITEM_LEVEL_AFTER"]                  = "Affiche le niveau d'objet du joueur après l'avoir inspecté."
L["AXIS_HONOR_LEVEL"]                                         = "Montrer l'honneur"
L["AXIS_PLAYER_S_PVP_HONOR_LEVEL_TOOLTIP"]                    = "Affiche le niveau d'honneur du joueur dans l'infobulle."
L["AXIS_PVP_TITLE"]                                           = "Montrer le titre PvP"
L["AXIS_PLAYER_S_PVP_TITLE_E_G"]                              = "Affiche le titre PvP du joueur (ex: Gladiateur) dans l'infobulle."
L["AXIS_CHARACTER_TITLE"]                                     = "Titre du personnage"
L["AXIS_PLAYER_S_SELECTED_TITLE_ACHIEVEMENT_PVP"]             = "Affiche le titre (haut fait ou PvP) à la suite du nom du personnage."
L["AXIS_TITLE_COLOUR"]                                        = "Couleur du titre"
L["AXIS_COLOUR_OF_CHARACTER_TITLE_PLAYER_TOOLTIP"]            = "Couleur du titre sur la ligne du nom du joueur."
L["AXIS_STATUS_BADGES"]                                       = "Montrer les badges de statut"
L["AXIS_INLINE_BADGES_COMBAT_AFK_DND_PVP"]                    = "Affiche les différents badges de combat, ABS, NPD, PvP, présence en groupe/raid, amis, ou si le joueur vous cible."
L["AXIS_MOUNT_INFO"]                                          = "Montrer les informations de monture"
L["AXIS_HOVERING_A_MOUNTED_PLAYER_THEIR_MOUNT"]               = "Au survol d'un joueur, affiche le nom de sa monture, sa source, et si vous la possédez."
L["AXIS_BLANK_SEPARATOR"]                                     = "Séparateur vide"
L["AXIS_A_BLANK_LINE_INSTEAD_OF_DASHES"]                      = "Utilise un séparateur vide à la place des tirets entre les différentes sections de l'infobulle."
L["AXIS_ICONS"]                                               = "Montrer les icones"
L["AXIS_CLASS_ICON_STYLE"]                                    = "Style des icones de classe"
L["AXIS_DEFAULT_BLIZZARD_RONDOMEDIA_CLASS_ICONS_TH"]          = "Utilise les icônes de classe par défaut (Blizzard) ou celles de RondoMedia sur la ligne de la classe/spé."
L["AXIS_CUSTOM_CLASS_ICONS_LABEL"]                            = "Custom (addon media)"
L["AXIS_CLASS_ICON_SOURCES_TOOLTIP"]                          = "RondoMedia: https://www.curseforge.com/wow/addons/rondomedia — Custom: place one .tga per class under media/CustomClassIcons/<CLASS>/<class lower>.tga (e.g. WARRIOR/warrior.tga), then /reload."
L["AXIS_RONDOMEDIA_CLASS_ICONS_RONDOFERRARI_HTTPS_WWW"]       = "Icones de classes créées par RondoFerrari — https://www.curseforge.com/wow/addons/rondomedia"
L["AXIS_DEFAULT"]                                             = "Par défaut"
L["AXIS_FACTION_SPEC_MOUNT_MYTHIC_ICONS_TOOLTIPS"]            = "SMontrer la faction, la spécialisation, la monture et les icônes de Mythique+ dans les infobulles."
L["AXIS_GENERAL"]                                             = "Général"
-- L["AXIS_POSITION"]                                         = "Position"
L["AXIS_RESET_POSITION"]                                      = "Réinitialiser la position"
L["AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"]                   = "Réinitialiser la position des alertes de butin."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["FOCUS_LOCK_POSITION"]                                      = "Verrouiller la position"
L["FOCUS_PREVENT_DRAGGING_TRACKER"]                           = "Empêche de déplacer le panneau d'objectifs."
L["FOCUS_GROW_UPWARD"]                                        = "Croissance vers le haut"
L["FOCUS_GROW_HEADER"]                                        = "En-tête croissance"
L["FOCUS_GROWING_UPWARD_KEEP_HEADER_BOTTOM_TOP"]              = "En croissance vers le haut : garder l'en-tête en bas ou en haut jusqu'au repli."
L["FOCUS_HEADER_BOTTOM"]                                      = "En-tête en bas"
L["FOCUS_HEADER_SLIDES_COLLAPSE"]                             = "En-tête glisse au repli"
L["FOCUS_ANCHOR_BOTTOM_LIST_GROWS_UPWARD"]                    = "Ancré en bas pour que la liste s'agrandisse vers le haut."
L["FOCUS_START_COLLAPSED"]                                    = "Replié par défaut"
L["FOCUS_START_HEADER_SHOWN_UNTIL_YOU_EXPAND"]                = "N'afficher que l'en-tête par défaut jusqu'au déploiement."
L["FOCUS_ALIGN_CONTENT_RIGHT"]                                = "Aligner le contenu à droite"
L["FOCUS_RIGHT_ALIGN_QUEST_TITLES_OBJECTIVES_WITHIN"]         = "Le titre des quêtes les objectifs s'ajustent sur le coté droit du panneau de suivi."
L["FOCUS_PANEL_WIDTH"]                                        = "Largeur du panneau"
L["FOCUS_TRACKER_WIDTH_PIXELS"]                               = "Largeur du panneau d'objectifs en pixels."
L["FOCUS_MAX_CONTENT_HEIGHT"]                                 = "Hauteur max du contenu"
L["FOCUS_MAX_HEIGHT_OF_SCROLLABLE_LIST_PIXELS"]               = "Hauteur maximale de la liste défilable (pixels)."
-- L["FOCUS_STATIC_BACKGROUND"]                               = "Static Background Size"
-- L["FOCUS_STATIC_BACKGROUND_DESC"]                          = "Lock the panel to a fixed height regardless of tracked content."
-- L["FOCUS_STATIC_PANEL_HEIGHT"]                             = "Static Panel Height"
-- L["FOCUS_STATIC_PANEL_HEIGHT_DESC"]                        = "Pixel height of the panel when static background is enabled."

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["FOCUS_ALWAYS_M_BLOCK"]                                     = "Toujours afficher le bloc M+"
L["FOCUS_M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]                = "Affiche le bloc M+ dès qu'une clé Mythique est active."
L["FOCUS_DUNGEON"]                                            = "Afficher en Donjon"
L["FOCUS_TRACKER_PARTY_DUNGEONS"]                             = "Affiche le panneau d'objectifs dans les donjons."
L["FOCUS_RAID"]                                               = "Afficher en Raid"
L["FOCUS_TRACKER_RAIDS"]                                      = "Affiche le panneau d'objectifs dans les raids."
L["FOCUS_BATTLEGROUND"]                                       = "Afficher en Champ de bataille"
L["FOCUS_TRACKER_BATTLEGROUNDS"]                              = "Affiche le panneau d'objectifs en champs de bataille."
L["FOCUS_ARENA"]                                              = "Afficher en Arène"
L["FOCUS_TRACKER_ARENAS"]                                     = "Affiche le panneau d'objectifs en arène."
L["FOCUS_HIDE_COMBAT"]                                        = "Masquer en combat"
L["FOCUS_HIDE_TRACKER_FLOATING_QUEST_ITEM_COMBAT"]            = "Masque le panneau d'objectifs et les objets de quête flottants en combat."
L["FOCUS_COMBAT_VISIBILITY"]                                  = "Visibilité en combat"
L["FOCUS_TRACKER_BEHAVES_COMBAT_FADE_REDUC"]                  = "Comportement du panneau en combat : afficher, estomper ou masquer."
L["FOCUS_SHOW"]                                               = "Afficher"
L["FOCUS_FADE"]                                               = "Estomper"
L["FOCUS_HIDE"]                                               = "Masquer"
L["FOCUS_COMBAT_FADE_OPACITY"]                                = "Opacité en combat (estomper)"
L["FOCUS_VISIBLE_TRACKER_FADED_COMBAT"]                       = "Visibilité du panneau quand estompé en combat (0 = invisible). S'applique uniquement quand la visibilité en combat est « Estomper »."
L["FOCUS_MOUSEOVER"]                                          = "Survol"
L["FOCUS_SHOW_ONLY_MOUSEOVER"]                                = "Afficher au survol uniquement"
L["FOCUS_FADE_TRACKER_HOVERING_MOVE_MOUSE"]                   = "Estompe le panneau quand la souris n'est pas dessus ; survolez pour l'afficher."
L["FOCUS_FADED_OPACITY"]                                      = "Opacité estompée"
L["FOCUS_VISIBLE_TRACKER_FADED_INVISIBLE"]                    = "Visibilité du panneau quand estompé (0 = invisible)."
L["FOCUS_QUESTS_CURRENT_ZONE"]                                = "Quêtes de la Zone Actuelle uniquement"
L["FOCUS_HIDE_QUESTS_OUTSIDE_YOUR_CURRENT_ZONE"]              = "Masque les quêtes hors de la Zone Actuelle."

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["FOCUS_QUEST_COUNT"]                                        = "Afficher le nombre de quêtes"
L["FOCUS_QUEST_COUNT_HEADER"]                                 = "Affiche le nombre de quêtes dans l'en-tête."
L["FOCUS_HEADER_COUNT_FORMAT"]                                = "Format du compteur de quêtes"
L["FOCUS_TRACKED_LOG_LOG_MAX_SLOTS_TRACKED"]                  = "Suivies/Dans le journal ou Dans le journal/Quêtes max. Les quêtes suivies ne prennent pas en compte les expéditions et les objectifs de zone bonus."
L["FOCUS_HEADER_DIVIDER"]                                     = "Afficher le séparateur d'en-tête"
L["FOCUS_LINE_BELOW_HEADER"]                                  = "Affiche la ligne sous l'en-tête."
L["FOCUS_HEADER_DIVIDER_COLOUR"]                              = "Couleur du séparateur d'en-tête"
L["FOCUS_COLOUR_OF_LINE_BELOW_HEADER"]                        = "Couleur de la ligne sous l'en-tête."
L["FOCUS_SUPER_MINIMAL_MODE"]                                 = "Mode Super-minimal"
L["FOCUS_HIDE_HEADER_A_PURE_TEXT_LIST"]                       = "Masque l'en-tête pour une liste de texte simple."
L["FOCUS_OPTIONS_BUTTON"]                                     = "Options button"
L["FOCUS_OPTIONS_BUTTON_TRACKER_HEADER"]                      = "Affiche le bouton Options dans l'en-tête."
L["FOCUS_HEADER_COLOUR"]                                      = "Couleur de l'en-tête"
L["FOCUS_COLOUR_OF_OBJECTIVES_HEADER_TEXT"]                   = "Couleur du texte OBJECTIFS dans l'en-tête."
L["FOCUS_HEADER_HEIGHT"]                                      = "Hauteur de l'en-tête"
L["FOCUS_HEIGHT_OF_HEADER_BAR_PIXELS"]                        = "Hauteur de la barre d'en-tête en pixels (18–48)."

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["FOCUS_SECTION_HEADERS"]                                    = "Afficher les en-têtes de section"
L["FOCUS_CATEGORY_LABELS_ABOVE_GROUP"]                        = "Affiche les catégories au-dessus de chaque groupe."
L["FOCUS_CATEGORY_HEADERS_COLLAPSED"]                         = "En-têtes des catégories visibles quand replié"
L["FOCUS_KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED_CLICK"]       = "Garde les en-têtes visibles quand le panneau est replié ; cliquez pour déployer une catégorie."
L["FOCUS_NEARBY_CURRENT_ZONE_GROUP"]                          = "Afficher le groupe Zone actuelle"
L["FOCUS_ZONE_QUESTS_A_DEDICATED_CURRENT_ZONE"]               = "Affiche les quêtes de la Zone Actuelle dans une section dédiée. Quand Désactivé : elles apparaissent dans leur catégorie habituelle."
L["FOCUS_ZONE_LABELS"]                                        = "Afficher les noms de zone"
L["FOCUS_ZONE_NAME_UNDER_QUEST_TITLE"]                        = "Affiche le nom de zone sous chaque titre de quête."
L["FOCUS_ACTIVE_QUEST_HIGHLIGHT"]                             = "Surbrillance de la quête active"
L["FOCUS_FOCUSED_QUEST_HIGHLIGHTED"]                          = "Règle la surbrillance de la quête active."
L["FOCUS_QUEST_ITEM_BUTTONS"]                                 = "Afficher les boutons d'objet de quête"
L["FOCUS_USABLE_QUEST_ITEM_BUTTON_NEXT_QUEST"]                = "Affiche le bouton d'objet utilisable à côté de chaque quête."
L["FOCUS_TOOLTIPS_HOVER"]                                     = "Infobulles au survol"
L["FOCUS_TOOLTIPS_HOVERING_TRACKER_ENTRIES_ITE"]              = "Afficher les infobulles au survol des éléments du panneau d'objectifs, des boutons d'objets, et des blocs de scénarios."
L["FOCUS_WOWHEAD_LINK_TOOLTIPS"]                              = "Afficher le lien WoWhead dans les infobulles"
L["FOCUS_A_TOOLTIP_SHOWN_ADD_A_LINK"]                         = "Quand l'infobulle est affichée, ajoute un lien vers la page WoWhead de la quête, du haut fait, ou du PNJ."
-- L["FOCUS_VIEW_WOWHEAD"]                                    = "View on WoWhead"
L["FOCUS_WOWHEAD_ALT_CLICK_HINT"]                             = "Alt+click row to copy"
-- L["FOCUS_WOWHEAD_HINT_LIST_SEPARATOR"]                     = " · "
-- L["FOCUS_WOWHEAD_TOOLTIP_HINT_FALLBACK"]                   = "Configure in Focus options"
-- L["FOCUS_COPY_LINK"]                                       = "Copy link"
-- L["FOCUS_COPY_URL_BELOW_CTRL_C_PASTE"]                     = "Copy the URL below (Ctrl+C) and paste in your browser."
L["FOCUS_OBJECTIVE_NUMBERS"]                                  = "Afficher les numéros d'objectifs"
L["FOCUS_OBJECTIVE_PREFIX"]                                   = "Préfixe d'objectif"
L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS"]                  = "Colour objective progress numbers"
L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS_DESC"]             = "Tint X/Y counts: normal colour at 0/n, gold while in progress, green when complete. The slash uses the usual objective colour."
L["FOCUS_PREFIX_OBJECTIVE_A_NUMBER_HYPHEN"]                   = "Ajoute un chiffre ou un tiret devant chaque objectif."
L["FOCUS_NUMBERS"]                                            = "Chiffres (1. 2. 3.)"
L["FOCUS_HYPHENS"]                                            = "Tirets (-)"
L["FOCUS_AFTER_SECTION_HEADER"]                               = "Après l'en-tête de section"
L["FOCUS_BEFORE_SECTION_HEADER"]                              = "Avant l'en-tête de section"
L["FOCUS_BELOW_HEADER"]                                       = "Sous l'en-tête header"
L["FOCUS_INLINE_BELOW_TITLE"]                                 = "A la ligne sous le titre"
L["FOCUS_PREFIX_OBJECTIVES"]                                  = "Préfixe les objectifs avec 1., 2., 3."
L["FOCUS_COMPLETED_COUNT"]                                    = "Afficher le compteur d'objectifs complétés"
L["FOCUS_X_Y_PROGRESS_QUEST_TITLE"]                           = "Affiche la progression X/Y dans les titres de quête."
L["FOCUS_OBJECTIVE_PROGRESS_BAR"]                             = "Afficher la barre de progression"
L["FOCUS_A_PROGRESS_BAR_UNDER_OBJECTIVES_NUMER"]              = "Affiche une barre de progression sous les objectifs ayant une progression numérique (ex. 3/250). S'applique uniquement aux entrées avec un seul objectif arithmétique dont le montant requis est supérieur à 1."
L["FOCUS_CATEGORY_COLOUR_PROGRESS_BAR"]                       = "Utiliser la couleur de catégorie pour la barre"
L["FOCUS_PROGRESS_BAR_MATCHES_QUEST_ACHIEVEME"]               = "Quand activé : la barre de progression utilise la couleur de la catégorie (quête, haut fait). Quand désactivé : utilise la couleur personnalisée ci-dessous."
L["FOCUS_PROGRESS_BAR_TEXTURE"]                               = "Texture de la barre de progression"
L["FOCUS_PROGRESS_BAR_TYPES"]                                 = "Types de barre de progression"
L["FOCUS_TEXTURE_PROGRESS_BAR_FILL"]                          = "Texture de remplissage de la barre."
L["FOCUS_TEXTURE_PROGRESS_BAR_FILL_SOLID_YOUR"]               = "Texture de remplissage. Solide utilise vos couleurs. Les addons SharedMedia ajoutent d'autres options."
L["FOCUS_PROGRESS_BAR_X_Y_OBJECTIVES_PERCENT"]                = "Afficher la barre pour les objectifs X/Y, les objectifs en pourcentage uniquement, ou les deux."
L["FOCUS_X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]             = "X/Y : objectifs comme 3/10. Pourcent : objectifs comme 45 %."
L["FOCUS_X_Y"]                                                = "X/Y uniquement"
L["FOCUS_PERCENT"]                                            = "Pourcentage uniquement"
L["FOCUS_TICK_COMPLETED_OBJECTIVES"]                          = "Utiliser une Coche pour les objectifs terminés"
L["FOCUS_COMPLETED_OBJECTIVES_A_CHECKMARK_INSTEA"]            = "Quand Activé : les objectifs terminés affichent une coche (✓) au lieu de la couleur verte."
L["FOCUS_ENTRY_NUMBERS"]                                      = "Afficher la numérotation des quêtes"
L["FOCUS_PREFIX_QUEST_TITLES_WITHIN_CATEGORY"]                = "Préfixe les titres de quêtes avec 1., 2., 3. dans chaque catégorie."
L["FOCUS_COMPLETED_OBJECTIVES"]                               = "Objectifs terminés"
L["FOCUS_MULTI_OBJECTIVE_QUESTS_DISPLAY_OBJECTIVES"]          = "Règle l'affichage des objectifs terminés quand il y en a plusieurs (ex. 1/1)."
L["FOCUS_ALL"]                                                = "Tout afficher"
L["FOCUS_FADE_COMPLETED"]                                     = "Estomper les objectifs terminés"
L["FOCUS_HIDE_COMPLETED"]                                     = "Masquer les objectifs terminés"
L["FOCUS_ICON_ZONE_AUTO_TRACKING"]                            = "Afficher l'icône de suivi automatique en zone"
L["FOCUS_DISPLAY_AN_ICON_NEXT_AUTO_TRACKED"]                  = "Affiche une icône à côté des expéditions et hebdomadaires/quotidiennes suivies automatiquement qui ne sont pas encore dans votre journal de quêtes (zone uniquement)."
L["FOCUS_AUTO_TRACK_ICON"]                                    = "Icône de suivi automatique"
L["FOCUS_CHOOSE_WHICH_ICON_DISPLAY_NEXT_AUTO"]                = "Choisissez l'icône affichée à côté des entrées suivies automatiquement en zone."
L["FOCUS_APPEND_WORLD_QUESTS_WEEKLIES_DAILIES"]               = "Ajoute ** aux expéditions et hebdomadaires/journalières non encore dans le journal de quêtes (de la zone actuelle uniquement)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["FOCUS_COMPACT_MODE"]                                       = "Mode compact"
L["FOCUS_PRESET_SETS_ENTRY_OBJECTIVE_SPACING_P"]              = "Préréglage : espacement des quêtes et objectifs à 4 et 1 px."
L["FOCUS_SPACING_PRESET"]                                     = "Préréglage d'espacement"
L["FOCUS_PRESET_ENTRY_OBJECTIVE_SPACING_DEFAULT_P"]           = "Préréglages : Par défaut (8/2 px), Compact (4/1 px), Espacée (12/3 px) ou Personnalisé (utilise les curseurs)."
L["FOCUS_COMPACT_VERSION"]                                    = "Version compacte"
L["FOCUS_SPACED_VERSION"]                                     = "Version espacée"
L["FOCUS_SPACING_BETWEEN_QUEST_ENTRIES_PX"]                   = "Espace entre les quêtes (px)"
L["FOCUS_VERTICAL_GAP_BETWEEN_QUEST_ENTRIES"]                 = "Espace vertical entre les différentes quêtes."
L["FOCUS_SPACING_BEFORE_CATEGORY_HEADER_PX"]                  = "Espace avant l'en-tête (px)"
L["FOCUS_GAP_BETWEEN_LAST_ENTRY_OF_A"]                        = "Espace entre la dernière entrée d'un groupe et la catégorie suivante."
L["FOCUS_SPACING_AFTER_CATEGORY_HEADER_PX"]                   = "Espace après l'en-tête (px)"
L["FOCUS_GAP_BETWEEN_CATEGORY_LABEL_FIRST_QUEST"]             = "Espace entre le libellé et la première entrée de quête en dessous."
L["FOCUS_SPACING_BETWEEN_OBJECTIVES_PX"]                      = "Espace entre les objectifs (px)"
L["FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVE_LINES_WITHIN"]        = "Espace entre les lignes d'objectifs dans une quête."
L["FOCUS_TITLE_CONTENT"]                                      = "Titre vers contenu"
L["FOCUS_VERTICAL_GAP_BETWEEN_QUEST_TITLE_OBJECTIVES"]        = "Espace vertical entre le titre de quête et les objectifs ou zone en dessous."
L["FOCUS_SPACING_BELOW_HEADER_PX"]                            = "Espace sous l'en-tête (px)"
L["FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVES_BAR_QUES"]           = "Espace entre la barre d'objectifs et la liste de quêtes."
L["FOCUS_RESET_SPACING"]                                      = "Réinitialiser les espaces"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["FOCUS_SHOW_QUEST_LEVEL"]                                   = "Afficher le niveau de quête"
L["FOCUS_QUEST_LEVEL_NEXT_TITLE"]                             = "Affiche le niveau de quête à côté du titre."
L["FOCUS_DIM_FOCUSED_QUESTS"]                                 = "Estomper les quêtes non actives"
L["FOCUS_SLIGHTLY_DIM_TITLE_ZONE_OBJECTIVES_SECTION"]         = "Estompe légèrement les titres, zones, objectifs et en-têtes non actifs."
L["FOCUS_DIM_UNFOCUSED_ENTRIES"]                              = "Estomper les éléments non mis en avant"
L["FOCUS_CLICK_A_SECTION_HEADER_EXPAND_CATEGORY"]             = "Cliquer sur un en-tête de section pour agrandir la catégorie."

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["UI_SHOW_RARE_BOSSES"]                                      = "Afficher les boss rares"
L["UI_RARE_BOSS_VIGNETTES_LIST"]                              = "Affiche les boss rares dans la liste."
L["UI_RARE_LOOT"]                                             = "Butin rare"
L["UI_TREASURE_ITEM_VIGNETTES_RARE_LOOT"]                     = "Affiche les trésors et objets dans la liste de butin rare."
L["UI_RARE_SOUND_VOLUME"]                                     = "Volume du son de butin rare"
L["UI_VOLUME_OF_RARE_ALERT_SOUND"]                            = "Volume du son d'alerte de butin rare (50–200%)."
L["UI_BOOST_REDUCE_RARE_ALERT_VOLUME"]                        = "Augmente ou réduit le volume. 100% = normal ; 150% = plus fort."
L["UI_RARE_ADDED_SOUND"]                                      = "Son d'ajout de rare"
L["UI_PLAY_A_SOUND_A_RARE"]                                   = "Joue un son quand un rare est ajouté."
-- L["UI_MINIMAP_PATCH_NOTES_UNREAD_HINT"]                    = "New patch notes — open Axis and choose Patch Notes."

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["FOCUS_ZONE_WORLD_QUESTS"]                                  = "Afficher les expéditions de la zone"
L["FOCUS_AUTO_ADD_WORLD_QUESTS_YOUR_CURRENT"]                 = "Ajoute automatiquement les expéditions de votre zone. Quand Désactivé : seules les quêtes suivies ou proches sont affichées (réglage par défaut Blizzard)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["FOCUS_SHOW_FLOATING_QUEST_ITEM"]                           = "Afficher l'objet de quête flottant"
L["FOCUS_QUICK_BUTTON_FOCUSED_QUEST_S_USABLE"]                = "Affiche le bouton d'utilisation rapide de l'objet de la quête active."
L["FOCUS_LOCK_FLOATING_QUEST_ITEM_POSITION"]                  = "Verrouiller la position de l'objet flottant"
L["FOCUS_PREVENT_DRAGGING_FLOATING_QUEST_ITEM_BUTTON"]        = "Empêche de déplacer le bouton d'objet de quête flottant."
L["FOCUS_FLOATING_QUEST_ITEM_SOURCE"]                         = "Source de l'objet flottant"
L["FOCUS_WHICH_QUEST_S_ITEM_SUPER_TRACKED"]                   = "Quel objet afficher : Quête Suivie en priorité ou Zone Actuelle en priorité."
L["FOCUS_SUPER_TRACKED_FIRST"]                                = "Quête Suivie en priorité"
L["FOCUS_CURRENT_ZONE_FIRST"]                                 = "Zone Actuelle en priorité"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["FOCUS_MYTHIC_BLOCK"]                                       = "Afficher le bloc Mythique+"
L["FOCUS_TIMER_COMPLETION_AFFIXES_MYTHIC_DUNGEONS"]           = "Affiche le timer, le % de complétion et les affixes en Mythique+."
L["FOCUS_M_BLOCK_POSITION"]                                   = "Position du bloc M+"
L["FOCUS_POSITION_OF_MYTHIC_BLOCK_RELATIVE_QUEST"]            = "Position du bloc Mythique+ par rapport à la liste de quêtes."
L["FOCUS_AFFIX_ICONS"]                                        = "Afficher les icônes des affixes"
L["FOCUS_AFFIX_ICONS_NEXT_MODIFIER_NAMES_M"]                  = "Affiche les icônes des affixes à côté des noms dans le bloc M+."
L["FOCUS_AFFIX_DESCRIPTIONS_TOOLTIP"]                         = "Descriptions des affixes dans l'infobulle"
L["FOCUS_AFFIX_DESCRIPTIONS_HOVERING_M_BLO"]                  = "Affiche les descriptions des affixes au survol du bloc M+."
L["FOCUS_M_COMPLETED_BOSS_DISPLAY"]                           = "Affichage des boss M+ terminés"
L["FOCUS_DEFEATED_BOSSES_CHECKMARK_ICON_GREEN"]               = "Affichage des boss vaincus : icône coche ou couleur verte."
L["FOCUS_CHECKMARK"]                                          = "Coche"
L["FOCUS_GREEN_COLOUR"]                                       = "Couleur Verte"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["PRESENCE_ACHIEVEMENTS"]                                    = "Afficher les hauts faits"
L["FOCUS_TRACKED_ACHIEVEMENTS_LIST"]                          = "Affiche les hauts faits suivis dans la liste."
L["FOCUS_COMPLETED_ACHIEVEMENTS"]                             = "Afficher les hauts faits terminés"
L["FOCUS_INCLUDE_COMPLETED_ACHIEVEMENTS_TRACKER_O"]           = "Inclut les hauts faits terminés. Quand Désactivé : seuls les hauts faits en cours sont affichés."
L["FOCUS_ACHIEVEMENT_ICONS"]                                  = "Afficher les icônes de hauts faits"
L["FOCUS_ACHIEVEMENT_S_ICON_NEXT_TITLE_REQUI"]                = "Affiche l'icône de chaque haut fait à côté du titre. Nécessite « Afficher les icônes de type de quête » dans Affichage."
L["FOCUS_MISSING_REQUIREMENTS"]                               = "Afficher uniquement les objectifs manquants"
L["FOCUS_CRITERIA_YOU_HAVEN_T_COMPLETED_TR"]                  = "Affiche uniquement les critères non terminés pour chaque haut fait suivi. Quand Désactivé : tous les critères sont affichés."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["FOCUS_SHOW_ENDEAVORS"]                                     = "Afficher les Initiatives"
L["FOCUS_TRACKED_ENDEAVORS_PLAYER_HOUSING_LIST"]              = "Affiche les Initiatives suivies (logement) dans la liste."
L["FOCUS_COMPLETED_ENDEAVORS"]                                = "Afficher les Initiatives terminées"
L["FOCUS_INCLUDE_COMPLETED_ENDEAVORS_TRACKER"]                = "Inclut les Initiatives terminées. Quand Désactivé : seuls les Initiatives en cours sont affichées."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["FOCUS_SHOW_DECOR"]                                         = "Afficher les décorations"
L["FOCUS_TRACKED_HOUSING_DECOR_LIST"]                         = "Affiche les décorations de Logis suivies dans la liste."
L["FOCUS_DECOR_ICONS"]                                        = "Afficher les icônes de décorations"
L["FOCUS_DECOR_ITEM_S_ICON_NEXT_TITLE"]                       = "Affiche l'icône de chaque décoration à côté du titre. Nécessite « Afficher les icônes de type de quête » dans Affichage."

-- =====================================================================
-- OptionsData.lua Features — Appearances
-- =====================================================================
L["FOCUS_SHOW_APPEARANCES"]                                   = "Show appearances"
-- L["FOCUS_TRACKED_TRANSMOG_APPEARANCES_LIST"]               = "Show tracked transmog appearances in the list."
-- L["FOCUS_INCLUDE_COLLECTED_APPEARANCES_TRACKER"]           = "Include collected appearances in the tracker. When off, only appearances you have not yet collected are shown."
L["FOCUS_APPEARANCE_ICONS"]                                   = "Show appearance icons"
-- L["FOCUS_APPEARANCE_ICON_NEXT_TITLE"]                      = "Show each appearance's icon next to the title. Requires 'Show quest type icons' in Display."
L["FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON"]                  = "Use transmog list icon"
-- L["FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON_DESC"]          = "Use the in-game Appearances / transmog list icon for every row instead of each appearance's item icon. If that icon cannot be resolved, the item icon is used."
L["FOCUS_SHOW_APPEARANCE_WARDROBE"]                           = "Show wardrobe"
-- L["FOCUS_OPEN_APPEARANCES_COLLECTIONS"]                    = "Open Collections"
L["FOCUS_UNTRACK_APPEARANCE"]                                 = "Untrack appearance"
L["FOCUS_APPEARANCE_HORIZON_CONTROLS_HINT"]                   = "Horizon: Shift-click map, Ctrl-click Collections, Ctrl+Shift-click dressing room. Right-click clears focus or untracks."

-- =====================================================================
-- OptionsData.lua Features — Adventure Guide
-- =====================================================================
L["FOCUS_ADVENTURE_GUIDE"]                                    = "Guide d'aventure"
L["FOCUS_TRAVELER_S_LOG"]                                     = "Afficher le Journal du voyageur"
L["FOCUS_TRACKED_TRAVELER_S_LOG_OBJECTIVES_SHIFT"]            = "Affiche les objectifs suivis du Journal du voyageur (Maj+clic dans le Guide d'aventure) dans la liste."
L["FOCUS_AUTO_REMOVE_COMPLETED_ACTIVITIES"]                   = "Retirer automatiquement les activités terminées"
L["FOCUS_AUTOMATICALLY_STOP_TRACKING_TRAVELER_S_LOG"]         = "Arrête automatiquement le suivi des activités du Journal du voyageur une fois terminées."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["FOCUS_SCENARIO_EVENTS"]                                    = "Afficher les événements de scénario"
L["FOCUS_ACTIVE_SCENARIO_DELVE_ACTIVITIES_DELVES_APP"]        = "Affiche les Scénarios et les Gouffres actifs. Les Gouffres s'affichent dans GOUFFRES ; les autres dans SCÉNARIO."
L["FOCUS_TRACK_DELVE_DUNGEON_SCENARIO_ACTIVITIES"]            = "Suivre les activités de Gouffres, Donjons et scénarios."
L["FOCUS_DELVES_APPEAR_DELVES_SECTION_DUNGEONS_DUNGEON"]      = "Les Gouffres dans GOUFFRES ; les donjons dans DONJON ; les autres dans SCÉNARIO."
L["FOCUS_DELVES_APPEAR_DELVES_SECTION_SCENARIOS"]             = "Les Gouffres apparaissent dans la section Gouffres; les autres scenarios dans la section Scenario."
L["FOCUS_DELVE_AFFIX_NAMES"]                                  = "Noms des affixes du Gouffre"
L["FOCUS_DELVE_DUNGEON"]                                      = "Gouffre/Donjon seulement"
L["FOCUS_SCENARIO_DEBUG_LOGGING"]                             = "Rapport de debug des scenario"
L["FOCUS_LOG_SCENARIO_API_DATA_CHAT_H"]                       = "Fait le rapport de l'API des scenario dans le chat. Tapper /h debug focus scendebug pour activer."
L["FOCUS_PRINTS_C_SCENARIOINFO_CRITERIA_WIDGET_DATA"]         = "Affiche les critères de C_ScenarioInfo et les données de widget au cours d'un scenario. Cela aide le diagnostique des erreurs d'affichage comme Abondance 46/300."
L["FOCUS_HIDE_CATEGORIES_DELVE_DUNGEON"]                      = "Masquer les autres catégories en Donjon ou en Gouffres"
L["FOCUS_DELVES_PARTY_DUNGEONS_DELVE_DUNG"]                   = "Durant un Donjon ou un Gouffre, affiche uniquement la section correspondante."
L["FOCUS_DELVE_NAME_SECTION_HEADER"]                          = "Utiliser le nom du Gouffre comme en-tête"
L["FOCUS_A_DELVE_DELVE_NAME_TIER_AFFIXES"]                    = "Durant un Gouffre : affiche le nom, le palier et les affixes dans l'en-tête. Quand Désactivé : affiche le bloc au-dessus de la liste."
L["FOCUS_AFFIX_NAMES_DELVES"]                                 = "Afficher le nom des affixes dans les Gouffres"
L["FOCUS_SEASON_AFFIX_NAMES_FIRST_DELVE_ENTRY"]               = "Affiche les noms des affixes saisonniers sur la première ligne du Gouffre. Nécessite les widgets Blizzard ; peut ne pas s'afficher correctement."
L["FOCUS_CINEMATIC_SCENARIO_BAR"]                             = "Barre cinématique de scénario"
L["FOCUS_TIMER_PROGRESS_BAR_SCENARIO_ENTRIES"]                = "Affiche le timer et la barre de progression pour les scénarios."
L["FOCUS_TIMER"]                                              = "Afficher le timer"
L["FOCUS_COUNTDOWN_TIMER_TIMED_QUESTS_EVENTS_SCEN"]           = "Affiche le compte à rebours sur les quêtes chronométrées, événements et scénarios. Désactivé, les timers sont masqués."
L["FOCUS_TIMER_SCENARIOS"]                                    = "Timers: scenarios & delves"
L["FOCUS_TIMER_SCENARIOS_DESC"]                               = "Countdown timer for scenario, delve, and dungeon tracker entries."
L["FOCUS_TIMER_WORLD"]                                        = "Timers: world & callings"
L["FOCUS_TIMER_WORLD_DESC"]                                   = "Countdown timer for world quests and callings."
L["FOCUS_TIMER_QUEST_LOG"]                                    = "Timers: quest log (timed)"
L["FOCUS_TIMER_QUEST_LOG_DESC"]                               = "Countdown timer for dailies, weeklies, and other quest log entries with a time limit."
L["FOCUS_TIMER_DISPLAY"]                                      = "Affichage du timer"
L["FOCUS_COLOUR_TIMER_REMAINING"]                             = "Couleur du timer selon le temps restant"
L["FOCUS_GREEN_PLENTY_OF_LEFT_YELLOW_RUNNING"]                = "Vert quand il reste du temps, jaune quand il en reste peu, rouge quand c'est critique."
L["FOCUS_WHERE_COUNTDOWN_BAR_BELOW_OBJECTIVES"]               = "Où afficher le compte à rebours : barre sous les objectifs ou texte à côté du nom de quête."
L["FOCUS_BAR_BELOW"]                                          = "Barre en dessous"
L["FOCUS_INLINE_BESIDE_TITLE"]                                = "Texte à côté du titre"

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["FOCUS_FONT_FAMILY"]                                        = "Police."
L["FOCUS_TITLE_FONT"]                                         = "Police des titres"
L["VISTA_ZONE_FONT"]                                          = "Police de zone"
L["FOCUS_OBJECTIVE_FONT"]                                     = "Police des objectifs"
L["FOCUS_SECTION_FONT"]                                       = "Police des sections"
L["FOCUS_GLOBAL_FONT"]                                        = "Utiliser la police globale"
L["FOCUS_FONT_FAMILY_QUEST_TITLES"]                           = "Police des titres de quête."
L["FOCUS_FONT_FAMILY_ZONE_LABELS"]                            = "Police des libellés de zone."
L["FOCUS_FONT_FAMILY_OBJECTIVE_TEXT"]                         = "Police du texte des objectifs."
L["FOCUS_FONT_FAMILY_SECTION_HEADERS"]                        = "Police des en-têtes de section."
L["FOCUS_HEADER_SIZE"]                                        = "Taille de l'en-tête"
L["FOCUS_HEADER_FONT_SIZE"]                                   = "Taille de police de l'en-tête."
L["FOCUS_TITLE_SIZE"]                                         = "Taille du titre"
L["FOCUS_QUEST_TITLE_FONT_SIZE"]                              = "Taille de police des titres de quête."
L["FOCUS_OBJECTIVE_SIZE"]                                     = "Taille des objectifs"
L["FOCUS_OBJECTIVE_TEXT_FONT_SIZE"]                           = "Taille de police du texte des objectifs."
L["FOCUS_ZONE_SIZE"]                                          = "Taille des zones"
L["FOCUS_ZONE_LABEL_FONT_SIZE"]                               = "Taille de police des libellés de zone."
L["FOCUS_SECTION_SIZE"]                                       = "Taille des sections"
L["FOCUS_SECTION_HEADER_FONT_SIZE"]                           = "Taille de police des en-têtes de section."
L["FOCUS_PROGRESS_BAR_FONT"]                                  = "Police de la barre de progression"
L["FOCUS_FONT_FAMILY_PROGRESS_BAR_LABEL"]                     = "Police du texte de la barre de progression."
L["FOCUS_PROGRESS_BAR_TEXT_SIZE"]                             = "Taille du texte de la barre de progression"
L["FOCUS_FONT_SIZE_PROGRESS_BAR_LABEL_ADJUSTS"]               = "Taille de police de la barre de progression. Ajuste également la hauteur. Affecte les objectifs de quêtes, la progression des scénarios et les barres de minuteur."
-- L["FOCUS_TIMER_TEXT_FONT"]                                 = "Timer Font"
-- L["FOCUS_FONT_FAMILY_TIMER_TEXT"]                          = "Font family for quest timer text (inline timers and world quest timers)."
-- L["FOCUS_TIMER_TEXT_SIZE"]                                 = "Timer Text Size"
-- L["FOCUS_TIMER_TEXT_FONT_SIZE"]                            = "Quest timer text font size."
-- L["FOCUS_OPTIONS_FONT"]                                    = "Options Font"
-- L["FOCUS_FONT_FAMILY_OPTIONS"]                             = "Font family for the Options button label in the tracker header."
-- L["FOCUS_OPTIONS_TEXT_SIZE"]                               = "Options Text Size"
-- L["FOCUS_OPTIONS_TEXT_FONT_SIZE"]                          = "Options button label font size."
L["FOCUS_PROGRESS_BAR_FILL"]                                  = "Remplissage de la barre de progression"
L["FOCUS_PROGRESS_BAR_TEXT"]                                  = "Texte de la barre de progression"
L["FOCUS_OUTLINE"]                                            = "Contour"
L["FOCUS_FONT_OUTLINE_STYLE"]                                 = "Style de contour de police."

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["FOCUS_HEADER_TEXT_CASE"]                                   = "Casse de l'en-tête"
L["FOCUS_DISPLAY_CASE_HEADER"]                                = "Casse d'affichage pour l'en-tête."
L["FOCUS_SECTION_HEADER_CASE"]                                = "Casse des en-têtes de section"
L["FOCUS_DISPLAY_CASE_CATEGORY_LABELS"]                       = "Casse d'affichage des catégorie."
L["FOCUS_QUEST_TITLE_CASE"]                                   = "Casse des titres de quête"
L["FOCUS_DISPLAY_CASE_QUEST_TITLES"]                          = "Casse d'affichage pour les titres de quête."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["FOCUS_TEXT_SHADOW"]                                        = "Afficher l'ombre du texte"
L["FOCUS_ENABLE_DROP_SHADOW_TEXT"]                            = "Active l'ombre portée du texte."
L["FOCUS_SHADOW_X"]                                           = "Ombre X"
L["FOCUS_HORIZONTAL_SHADOW_OFFSET"]                           = "Décalage horizontal de l'ombre."
L["FOCUS_SHADOW_Y"]                                           = "Ombre Y"
L["FOCUS_VERTICAL_SHADOW_OFFSET"]                             = "Décalage vertical de l'ombre."
L["FOCUS_SHADOW_ALPHA"]                                       = "Opacité de l'ombre"
L["FOCUS_SHADOW_OPACITY"]                                     = "Opacité de l'ombre (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["FOCUS_MYTHIC_TYPOGRAPHY"]                                  = "Textes Mythique+"
L["FOCUS_DUNGEON_NAME_SIZE"]                                  = "Taille du nom du donjon"
L["FOCUS_FONT_SIZE_DUNGEON_NAME_PX"]                          = "Taille de police du nom du donjon (8–32 px)."
L["FOCUS_DUNGEON_NAME_COLOUR"]                                = "Couleur du nom du donjon"
L["FOCUS_TEXT_COLOUR_DUNGEON_NAME"]                           = "Couleur du texte du nom du donjon."
L["FOCUS_TIMER_SIZE"]                                         = "Taille du timer"
L["FOCUS_FONT_SIZE_TIMER_PX"]                                 = "Taille de police du timer (8–32 px)."
L["FOCUS_TIMER_COLOUR"]                                       = "Couleur du timer"
L["FOCUS_TEXT_COLOUR_TIMER"]                                  = "Couleur du timer (dans les temps)."
L["FOCUS_TIMER_OVERTIME_COLOUR"]                              = "Couleur du timer (temps dépassé)"
L["FOCUS_TEXT_COLOUR_TIMER_LIMIT"]                            = "Couleur du timer quand le temps est écoulé."
L["FOCUS_PROGRESS_SIZE"]                                      = "Taille de la progression"
L["FOCUS_FONT_SIZE_ENEMY_FORCES_PX"]                          = "Taille de police des forces ennemies (8–32 px)."
L["FOCUS_PROGRESS_COLOUR"]                                    = "Couleur de la progression"
L["FOCUS_TEXT_COLOUR_ENEMY_FORCES"]                           = "Couleur du texte des forces ennemies."
L["FOCUS_BAR_FILL_COLOUR"]                                    = "Couleur de remplissage de la barre"
L["FOCUS_PROGRESS_BAR_FILL_COLOUR_PROGRESS"]                  = "Couleur de remplissage de la barre (Clé en cours)."
L["FOCUS_BAR_COMPLETE_COLOUR"]                                = "Couleur de la barre de Clé terminée"
L["FOCUS_PROGRESS_BAR_FILL_COLOUR_ENEMY_FORCES"]              = "Couleur de remplissage quand les forces ennemies sont à 100%."
L["FOCUS_AFFIX_SIZE"]                                         = "Taille des affixes"
L["FOCUS_FONT_SIZE_AFFIXES_PX"]                               = "Taille de police des affixes (8–32 px)."
L["FOCUS_AFFIX_COLOUR"]                                       = "Couleur des affixes"
L["FOCUS_TEXT_COLOUR_AFFIXES"]                                = "Couleur du texte des affixes."
L["FOCUS_BOSS_SIZE"]                                          = "Taille des noms de boss"
L["FOCUS_FONT_SIZE_BOSS_NAMES_PX"]                            = "Taille de police des noms de boss (8–32 px)."
L["FOCUS_BOSS_COLOUR"]                                        = "Couleur des noms de boss"
L["FOCUS_TEXT_COLOUR_BOSS_NAMES"]                             = "Couleur du texte des noms de boss."
L["FOCUS_RESET_MYTHIC_TYPOGRAPHY"]                            = "Réinitialiser les textes M+"

-- =====================================================================
-- OptionsData.lua Appearance
-- =====================================================================
L["DASH_FRAME"]                                               = "Cadre"
L["FOCUS_CLASS_COLOURS_DASHBOARD"]                            = "Couleurs de classe - Tableau de bord"
-- L["FOCUS_CLASS_COLOURS"]                                   = "Class Colours"
L["FOCUS_ENABLE_CLASS_COLOURS"]                               = "Enable all class colours"
-- L["DASH_CLASS_COLOURS_MODULES_GLOBAL"]                     = "Toggle class colours on or off for all modules at once."
-- L["FOCUS_DASHBOARD"]                                       = "Dashboard"
-- L["FOCUS_CLASS_COLOURS_DESC"]                              = "Tint Focus header title, category section headers, main and between-section dividers, and super-tracked highlight bars and borders with your class colour."
-- L["PRESENCE_CLASS_COLOURS_DESC"]                           = "Tint Presence toast title and divider with your class colour."
-- L["VISTA_CLASS_COLOURS_DESC"]                              = "Tint Vista minimap, addon-bar, and panel borders and text with your class colour."
-- L["INSIGHT_CLASS_COLOURS_DESC"]                            = "Use class colour for player tooltip name, class line, and border."
-- L["CACHE_CLASS_COLOURS_DESC"]                              = "Tint Cache loot icon glow and edit/anchor borders with your class colour."
-- L["ESSENCE_CLASS_COLOURS_DESC"]                            = "Tint the character name on the Essence sheet with your class colour."
L["AXIS_CLASS_COLOURS_DESC"]                                  = "Colore les éléments du Tableau de bord, des séparateurs et des surlignages avec la couleur de votre classe."
-- L["DASH_THEME"]                                            = "Theme"
L["FOCUS_DASHBOARD_BACKGROUND"]                               = "Dashboard background"
L["DASH_BACKGROUND"]                                          = "Background style for the module dashboard window (Axis). Default is flat; Midnight uses bundled artwork; Specialisation (auto) uses the in-game talent UI background for your current specialization."
-- L["FOCUS_DASHBOARD_BACKGROUND_MINIMALISTIC"]               = "Minimalistic"
-- L["FOCUS_DASHBOARD_BACKGROUND_MIDNIGHT"]                   = "Midnight"
L["FOCUS_DASHBOARD_BACKGROUND_TELDRASSIL_BURNS"]              = "Teldrassil (burning)"
-- L["FOCUS_DASHBOARD_BACKGROUND_NIGHTFAE"]                   = "Night Fae"
-- L["FOCUS_DASHBOARD_BACKGROUND_ARDENWEALD"]                 = "Ardenweald"
-- L["FOCUS_DASHBOARD_BACKGROUND_ZIN_AZSHARI"]                = "Zin-Azshari"
L["FOCUS_DASHBOARD_BACKGROUND_SURAMAR_GARDEN"]                = "Suramar garden"
-- L["DASH_BACKGROUND_QUEL_THALAS"]                           = "Quel'Thalas"
-- L["FOCUS_DASHBOARD_BACKGROUND_TWILIGHT_VINEYARDS"]         = "Twilight Vineyards"
-- L["FOCUS_DASHBOARD_BACKGROUND_ZUL_AMAN"]                   = "Zul'Aman"
-- L["FOCUS_DASHBOARD_BACKGROUND_ILLIDAN"]                    = "Illidan"
-- L["FOCUS_DASHBOARD_BACKGROUND_LICH_KING"]                  = "The Lich King"
-- L["FOCUS_DASHBOARD_BACKGROUND_TBC_ANNIVERSARY"]            = "TBC Anniversary"
-- L["FOCUS_DASHBOARD_BACKGROUND_BELEDARS_LIGHT"]             = "Beledar's Light"
-- L["FOCUS_DASHBOARD_BACKGROUND_CLASS_TALENTS"]              = "Specialisation (auto)"
L["FOCUS_DASHBOARD_BACKGROUND_OPACITY"]                       = "Dashboard background opacity"
-- L["FOCUS_ADJUST_OPACITY_OF_DASHBOARD_BACKGROUND"]          = "Adjust the opacity of the dashboard background (50–100%). Lower values let more of the game world show through."
L["DASHBOARD_TYPO_SECTION"]                                   = "Dashboard text"
L["DASHBOARD_TYPO_FONT"]                                      = "Dashboard font"
-- L["DASHBOARD_TYPO_FONT_DESC"]                              = "Font for the Axis settings window (sidebar, search, and option rows). Separate from the Focus tracker font. For CJK or mixed-script welcome text, pick a broad-coverage font (e.g. 2002) if needed."
L["DASHBOARD_TYPO_SIZE"]                                      = "Dashboard text size"
-- L["DASHBOARD_TYPO_SIZE_DESC"]                              = "Nudge all dashboard text larger or smaller (−4 to +4), similar to Focus global font offset."
L["DASHBOARD_TYPO_OUTLINE"]                                   = "Dashboard text outline"
L["DASHBOARD_TYPO_OUTLINE_DESC"]                              = "When on, dashboard UI text uses the standard outlined font style. Turn off for a softer, flat look."
L["DASHBOARD_TYPO_SHADOW"]                                    = "Dashboard text shadow"
L["DASHBOARD_TYPO_SHADOW_DESC"]                               = "Adds a subtle drop shadow behind dashboard text to improve readability on busy backgrounds."
L["FOCUS_BACKDROP_OPACITY"]                                   = "Opacité du fond"
L["FOCUS_PANEL_BACKGROUND_OPACITY"]                           = "Opacité du fond du panneau (0–1)."
L["FOCUS_BORDER"]                                             = "Afficher la bordure"
L["FOCUS_BORDER_AROUND_TRACKER"]                              = "Affiche le cadre autour du panneau d'objectifs."
L["FOCUS_SCROLL_INDICATOR"]                                   = "Afficher l'indicateur de défilement"
L["FOCUS_A_VISUAL_HINT_LIST_CONTENT_TH"]                      = "Affiche un indice visuel lorsque la liste contient plus de contenu que ce qui est visible."
L["FOCUS_SCROLL_INDICATOR_STYLE"]                             = "Style de l'indicateur de défilement"
L["FOCUS_CHOOSE_BETWEEN_A_FADE_GRADIENT_A"]                   = "Choisissez entre un dégradé ou une petite flèche pour indiquer le contenu défilable."
L["FOCUS_ARROW"]                                              = "Flèche"
L["FOCUS_HIGHLIGHT_ALPHA"]                                    = "Opacité de la surbrillance"
L["FOCUS_OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]                 = "Opacité de la quête active (0–1)."
L["FOCUS_BAR_WIDTH"]                                          = "Largeur de la barre"
L["FOCUS_WIDTH_OF_BAR_STYLE_HIGHLIGHTS_PX"]                   = "Largeur de la barre de surbrillance (2–6 px)."

-- =====================================================================
-- OptionsData.lua Organisation
-- =====================================================================
L["FOCUS_ACTIVITY"]                                           = "Activité"
L["FOCUS_CONTENT"]                                            = "Contenu"
L["FOCUS_SORTING"]                                            = "Tri"
L["FOCUS_ELEMENTS"]                                           = "Éléments"
L["FOCUS_CATEGORY_ORDER"]                                     = "Ordre des catégories Focus"
L["FOCUS_CATEGORY_COLOUR_BAR"]                                = "Couleur de la catégorie pour la barre"
L["FOCUS_CHECKMARK_COMPLETED"]                                = "Coche pour les objectifs complétés"
L["FOCUS_CURRENT_QUEST_CATEGORY"]                             = "Catégorie Quête en Cours"
L["FOCUS_CURRENT_QUEST_WINDOW"]                               = "Fenêtre Quête en Cours"
L["FOCUS_QUESTS_RECENT_PROGRESS_TOP"]                         = "Afficher en haut du panneau les quêtes avec le progrès le plus récent."
L["FOCUS_RECENT_QUEST_SECONDS"]                               = "Secondes de progression récentes pour compter comme Quête en Cours (30–120)."
L["FOCUS_QUEST_PROGRESSION_SECTION"]                          = "Les quêtes qui ont été avancées lors de la dernière minute s'affiche dans une section dédiée."
L["FOCUS_SHOW_ZONE_EVENTS"]                                   = "Events in Zone section"
L["FOCUS_SHOW_ZONE_EVENTS_DESC"]                              = "Show the Events in Zone section for nearby unaccepted quests and zone event quests."
L["FOCUS_SHOW_ZONE_EVENTS_TIP"]                               = "When off, those quests appear in their normal categories instead."
L["FOCUS_CATEGORY_ORDER"]                                     = "Ordre des catégories Focus"
L["FOCUS_CATEGORIES_REORDER_EXCEPT_DELVES_SCENARIOS"]         = "Glissez pour réordonner. GOUFFRES et SCÉNARIO restent en premier."
L["FOCUS_CATEGORIES_REORDER_EXCEPT_DELVES_SCENARIOS_TIP"]     = "Glisser pour réordonner. Les Gouffres et les Scenario restent en premier."
L["FOCUS_SORT_MODE"]                                          = "Mode de tri Focus"
L["FOCUS_ENTRY_NUMBER_IN_CATEGORY"]                           = "Ordre des entrées dans chaque catégorie."
L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS"]                         = "Suivi auto des quêtes acceptées"
L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS_TIP"]                     = "Suivi automatique des nouvelles quêtes (Sauf les expéditions)."
L["FOCUS_CTRL_FOCUS_REMOVE"]                                  = "Ctrl requis pour suivre / ne plus suivre"
L["FOCUS_CTRL_FOCUS_REMOVE_MOUSECLICK"]                       = "Exige l'appui sur la touche Ctrl pour suivre (clic gauche) et ne plus suivre (clic droit) afin d'éviter les clics accidentels."
L["FOCUS_CTRL_FOCUS_UNTRACK"]                                 = "Appui sur Ctrl pour suivre / ne plus suivre"
L["FOCUS_CTRL_CLICK_COMPLETE"]                                = "Appui sur Ctrl pour Rendre en un clic"
L["FOCUS_CLASSIC_CLICK_BEHAVIOUR"]                            = "Utiliser le comportement de clic classique"
L["FOCUS_CLASSIC_CLICKS"]                                     = "Clics classiques"
-- === Focus Click Profiles ===
L["FOCUS_CLICK_PROFILE"]                                      = "Click profile"
L["FOCUS_CLICK_PROFILE_DESC"]                                 = "Choose how mouse clicks on tracker entries behave."
L["FOCUS_ICON_CLICK_ACTION"]                                  = "Quest/appearance icon click"
L["FOCUS_ICON_CLICK_ACTION_DESC"]                             = "Choose what happens when you click the quest or appearance icon itself, when that icon click behavior is shown."
-- L["FOCUS_PROFILE_HORIZON_PLUS"]                            = "Horizon+"
L["FOCUS_PROFILE_BLIZZARD_DEFAULT"]                           = "Blizzard Default"
-- L["FOCUS_PROFILE_CUSTOM"]                                  = "Custom"
-- L["FOCUS_COMING_SOON"]                                     = "Coming soon"
-- L["FOCUS_CLICK_COMBOS"]                                    = "Custom bindings"
-- L["FOCUS_CLICK_COMBO_LOCKED_TOOLTIP"]                      = "Fixed for this profile. Select Custom to edit shortcuts."
L["FOCUS_CLICK_SAFETY"]                                       = "Safety"
L["FOCUS_COMBO_LEFT"]                                         = "Left click"
L["FOCUS_COMBO_SHIFT_LEFT"]                                   = "Shift + Left click"
L["FOCUS_COMBO_CTRL_LEFT"]                                    = "Ctrl + Left click"
L["FOCUS_COMBO_ALT_LEFT"]                                     = "Alt + Left click"
L["FOCUS_COMBO_RIGHT"]                                        = "Right click"
L["FOCUS_COMBO_SHIFT_RIGHT"]                                  = "Shift + Right click"
L["FOCUS_COMBO_CTRL_RIGHT"]                                   = "Ctrl + Right click"
L["FOCUS_COMBO_ALT_RIGHT"]                                    = "Alt + Right click"
-- L["FOCUS_CLICK_ACTION_NONE"]                               = "Do nothing"
-- L["FOCUS_CLICK_ACTION_SUPER_TRACK"]                        = "Focus quest"
-- L["FOCUS_CLICK_ACTION_OPEN_DETAILS"]                       = "Open relevant details"
L["FOCUS_CLICK_ACTION_OPEN_PROFESSION"]                       = "Open profession or quest details"
L["FOCUS_CLICK_ACTION_OPEN_QUEST_LOG"]                        = "Open quest log"
-- L["FOCUS_CLICK_ACTION_UNTRACK"]                            = "Untrack"
-- L["FOCUS_CLICK_ACTION_CONTEXT_MENU"]                       = "Context menu"
-- L["FOCUS_CLICK_ACTION_SHARE"]                              = "Share with party"
-- L["FOCUS_CLICK_ACTION_ABANDON"]                            = "Abandon quest"
-- L["FOCUS_CLICK_ACTION_WOWHEAD"]                            = "WoWhead URL"
-- L["FOCUS_CLICK_ACTION_CHAT_LINK"]                          = "Link in chat"
-- L["FOCUS_CLICK_ACTION_PREVIEW"]                            = "Preview"
-- L["FOCUS_APPEARANCE_CANNOT_SHARE"]                         = "Appearances cannot be shared like quests."
-- L["FOCUS_QUEST_DETAILS_AFTER_COMBAT"]                      = "Quest details will open when you leave combat."
L["FOCUS_SHARE_PARTY"]                                        = "Partager avec le groupe"
L["FOCUS_ABANDON_QUEST"]                                      = "Abandonner la quête"
-- L["FOCUS_CONTEXT_FOCUS_QUEST"]                             = "Focus quest"
L["FOCUS_STOP_TRACKING"]                                      = "Arrêter le suivi"
-- L["FOCUS_CONTEXT_OPEN_ACHIEVEMENT"]                        = "Open achievement"
-- L["FOCUS_CONTEXT_OPEN_ENDEAVOR"]                           = "Open endeavor"
-- L["FOCUS_CONTEXT_OPEN_RECIPE"]                             = "Open recipe"
-- L["FOCUS_CONTEXT_OPEN_DECOR_CATALOG"]                      = "Open in catalog"
-- L["FOCUS_CONTEXT_PREVIEW_DECOR"]                           = "Preview decor"
-- L["FOCUS_CONTEXT_SHOW_DECOR_MAP"]                          = "Show on map"
-- L["FOCUS_CONTEXT_OPEN_TRAVELERS_LOG"]                      = "Open Traveler's Log"
-- L["FOCUS_CONTEXT_SET_RARE_WAYPOINT"]                       = "Set waypoint"
-- L["FOCUS_CONTEXT_CLEAR_RARE_FOCUS"]                        = "Clear map focus"
-- L["FOCUS_TRACKED_CONTENT_CANNOT_SHARE"]                    = "This entry cannot be shared with the party."
L["FOCUS_CANNOT_SHARE_QUEST"]                                 = "Cette quête ne peut pas être partagée."
L["FOCUS_REQUIRE_PARTY_SHARE"]                                = "Vous devez être en groupe pour partager cette quête."
L["FOCUS_LEFT_CLICK_MAP_RIGHT_CLICK_ABANDON"]                 = "Activé : clic gauche ouvre la carte de quête, clic droit affiche le menu partager/abandonner (style Blizzard). Désactivé : clic gauche suit, clic droit arrête le suivi ; Ctrl+clic droit partage avec le groupe."
L["FOCUS_ANIMATIONS"]                                         = "Focus animations"
L["FOCUS_SLIDE_FADE_QUESTS"]                                  = "Active le glissement et le fondu pour les quêtes."
L["FOCUS_OBJECTIVE_PROGRESS_FLASH"]                           = "Flash de progression d'objectif"
L["FOCUS_FLASH_OBJECTIVE_COMPLETION"]                         = "Clignote quand un objectif est terminé."
L["FOCUS_FLASH_INTENSITY"]                                    = "Intensité du flash"
L["FOCUS_OBJECTIVE_PROGRESS_FLASH_VISIBILITY"]                = "Intensité du flash à la complétion d'un objectif."
L["FOCUS_FLASH_COLOUR"]                                       = "Couleur du flash"
L["FOCUS_FLASH_COLOUR_DESC"]                                  = "Couleur du flash à la complétion d'un objectif."
L["FOCUS_SUBTLE"]                                             = "Subtil"
L["FOCUS_MEDIUM"]                                             = "Moyen"
L["FOCUS_STRONG"]                                             = "Fort"
L["FOCUS_REQUIRE_CTRL_CLICK_COMPLETE"]                        = "Ctrl requis pour cliquer et terminer"
L["FOCUS_REQUIRES_CTRL_LEFT_CLICK_COMPLETE_AUTO"]             = "Quand Activé : Ctrl+clic gauche pour terminer. Quand Désactivé : un simple clic gauche (comportement Blizzard par défaut). Affecte uniquement les quêtes terminables par clic. (Sans dialogue avec un PNJ)"
L["FOCUS_SUPPRESS_UNTRACKED_UNTIL_RELOAD"]                    = "Masquer les quêtes non suivies jusqu'au prochain rechargement"
L["FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS"]                   = "Quand Activé : les quêtes non suivies restent masquées jusqu'au rechargement. Désactivé : elles réapparaissent à chaque retour en zone."
L["FOCUS_PERMANENTLY_SUPPRESS_UNTRACKED_QUESTS"]              = "Masquer définitivement les quêtes non suivies"
L["FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS_DESC"]              = "Quand Activé : les quêtes non suivies restent masquées définitivement. Prioritaire sur « Masquer jusqu'au prochain rechargement ». Accepter une quête masquée la retire de la liste noire."
L["FOCUS_KEEP_CAMPAIGN_CATEGORY"]                             = "Garder les quêtes de campagne dans leur catégorie"
L["FOCUS_CAMPAIGN_READY_STAY"]                                = "Quand Activé : les quêtes de campagne prêtes à être rendues restent dans la catégorie Campagne au lieu d'aller dans Terminées."
L["FOCUS_KEEP_IMPORTANT_QUESTS_CATEGORY"]                     = "Garder les quêtes importantes dans leur catégorie"
L["FOCUS_IMPORTANT_READY_STAY"]                               = "Quand Activé : les quêtes importantes prêtes à être rendues restent dans la catégorie Important au lieu d'aller dans Terminées."
L["FOCUS_TOMTOM_QUEST_WAYPOINT"]                              = "Point de repère TomTom"
L["FOCUS_TOMTOM_QUEST_WAYPOINT_TIP"]                          = "Définir un point de repère TomTom en ciblant une quête."
L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_NEXT_QUEST"]            = "Nécessite TomTom. Dirige la flèche vers le prochain objectif de quête."
L["FOCUS_TOMTOM_RARE_WAYPOINT"]                               = "Point de repère TomTom (rare)"
L["FOCUS_TOMTOM_WAYPOINT_RARE_CLICK"]                         = "Définir un point de repère TomTom en cliquant sur un boss rare."
L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_RARE"]                  = "Nécessite TomTom. Dirige la flèche vers l'emplacement du boss rare."
L["FOCUS_FIND_GROUP"]                                         = "Recherche de groupe"
L["FOCUS_GROUP_QUEST_SEARCH_CLICK"]                           = "Cliquer pour rechercher un groupe pour cette quête."

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
L["FOCUS_BLACKLIST"]                                          = "Liste noire"
L["FOCUS_BLACKLIST_UNTRACKED"]                                = "Mettre en liste noire les quêtes arrêtées d'être suivies"
L["FOCUS_ENABLE_BLACKLIST_UNTRACKED_BEHAVIOUR_ADD_QUEST"]     = "Activer 'Mettre en liste noire les quêtes arrêtées d'être suivies' dans Comportement pour ajouter des quêtes ici."
L["FOCUS_HIDDEN_QUESTS"]                                      = "Quêtes cachées"
L["FOCUS_QUESTS_HIDDEN_RIGHT_CLICK_UNTRACK"]                  = "Les quêtes cachées avec le clic droit arrêtent d'être suivies."
L["FOCUS_BLACKLISTED_QUESTS"]                                 = "Quêtes en liste noire"
L["FOCUS_PERMANENTLY_SUPPRESSED_QUESTS"]                      = "Quêtes supprimées définitivement"
L["FOCUS_RIGHT_CLICK_UNTRACK_QUESTS_PERMANENTLY_SUPPRESS"]    = "Clic droit pour retirer les quêtes avec « Quêtes supprimées définitivement » activé afin de les ajouter ici."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["PRESENCE_QUEST_TYPE_ICONS"]                                = "Afficher les icônes du type de quête"
L["PRESENCE_QUEST_TYPE_ICON_FOCUS_TRACKER_QUEST"]             = "Affiche dans le suivi : quête acceptée/terminée, expéditions, avancement de quête."
L["PRESENCE_QUEST_TYPE_ICONS_TOASTS"]                         = "Montrer les icônes de type de quêtes sur les notifications"
L["PRESENCE_QUEST_TYPE_ICON_PRESENCE_TOASTS_QUEST"]           = "Affiche l'icône de type de quête sur les notifications : quête acceptée/terminée, expéditions, avancement de quête."
L["PRESENCE_TOAST_ICON_SIZE"]                                 = "Taille des icônes sur les notifications"
L["PRESENCE_QUEST_ICON_SIZE_PRESENCE_TOASTS_PX"]              = "Taille des icônes de quête sur les notifications (16–36 px). Par défaut 24."
L["PRESENCE_HIDE_QUEST_UPDATE_TITLE"]                         = "Masquer le titre sur les avancements de quête"
L["PRESENCE_OBJECTIVE_LINE_QUEST_PROGRESS_TOAST"]             = "Affiche uniquement la ligne d'objectif (ex. 7/10 Peaux de sanglier) sans le nom de quête ni l'en-tête."
L["PRESENCE_SHOW_DISCOVERY_LINE"]                             = "Afficher la ligne de découverte"
L["PRESENCE_DISCOVERY_LINE"]                                  = "Ligne de Découverte"
L["PRESENCE_SHOW_DISCOVERED"]                                 = "Affiche « Découverte » sous la zone/sous-zone à l'entrée d'une nouvelle zone."
L["PRESENCE_FRAME_VERTICAL_POSITION"]                         = "Position verticale du cadre"
L["PRESENCE_VERTICAL_OFFSET_OF_PRESENCE_FRAME_CENTER"]        = "Décalage vertical depuis le centre (-300 à 0)."
L["PRESENCE_FRAME_SCALE"]                                     = "Échelle du cadre"
L["PRESENCE_FRAME_SCALE_TIP"]                                 = "Échelle du cadre Présence (0.5–2)."
L["PRESENCE_BOSS_EMOTE_COLOUR"]                               = "Couleur des emotes de boss"
L["PRESENCE_COLOUR_RAID_DUNGEON_BOSS_EMOTE"]                  = "Couleur du texte des emotes de boss en raid et donjon."
L["PRESENCE_DISCOVERY_LINE_COLOUR"]                           = "Couleur de la ligne de découverte"
L["PRESENCE_COLOUR_OF_DISCOVERED_LINE_UNDER_ZONE_TIP"]        = "Couleur de la ligne « Découverte » sous le texte de zone."
L["PRESENCE_NOTIFICATION_TYPES"]                              = "Types de notifications"
-- L["PRESENCE_NOTIFICATIONS"]                                = "Notifications"
L["PRESENCE_NOTIFICATION_ACHIEVEMENT_CRITERIA_UPDATE"]        = "Montre une notification quand un objectif de haut fait progresse (pour tous les hauts faits suivis; et les autres lorsque Blizzard fournit l'ID du haut fait)."
L["PRESENCE_ZONE_ENTRY"]                                      = "Afficher l'entrée en zone"
L["PRESENCE_ZONE_CHANGE_ENTERING_A_AREA"]                     = "Affiche la notification lors de l'entrée dans une nouvelle zone."
L["PRESENCE_SUBZONE_CHANGES"]                                 = "Afficher les changements de sous-zone"
L["PRESENCE_SUBZONE_CHANGE_MOVING_WITHIN_SAME_ZONE"]          = "Affiche la notification lors du déplacement entre sous-zones dans la même zone."
L["PRESENCE_HIDE_ZONE_NAME_SUBZONE_CHANGES"]                  = "Masquer le nom de zone pour les sous-zones"
L["PRESENCE_MOVING_BETWEEN_SUBZONES_WITHIN_SAME_ZONE"]        = "Lors des déplacements entre sous-zones dans la même zone, affiche uniquement le nom de la sous-zone. Le nom de la zone apparaît toujours en entrant dans une nouvelle zone."
L["PRESENCE_SUPPRESS_DELVE"]                                  = "Sourdine en Gouffre"
L["PRESENCE_SUPPRESS_SCENARIO_PROGRESS_NOTIFICATIONS_DELVES"]   = "Sourdine les notifications de progrès de scenario en Gouffre."
L["PRESENCE_HIDE_DELVE_OBJECTIVE_UPDATE"]                     = "Quand activé, masque les messages de progression des objectifs dans les Gouffres. L'entrée en zone et les alertes de complétion continueront de s'afficher."
L["PRESENCE_SUPPRESS_ZONE_CHANGES_MYTHIC"]                    = "Supprimer les changements de zone en Mythique+"
L["PRESENCE_MYTHICPLUS_SHOW_BOSS_EMOTES_ACHIEVEMENTS_LEVELS"]   = "En Mythique+, affiche uniquement les emotes de boss, hauts faits et montée de niveau. Masque les notifications de zone, quête et scénario."
L["PRESENCE_LEVEL"]                                           = "Afficher la montée de niveau"
L["PRESENCE_LEVEL_NOTIFICATION"]                              = "Affiche la notification de montée de niveau."
L["PRESENCE_BOSS_EMOTES"]                                     = "Afficher les emotes de boss"
L["PRESENCE_RAID_DUNGEON_BOSS_EMOTE_NOTIFICATIONS"]           = "Affiche les notifications d'emotes de boss en raid et donjon."
L["PRESENCE_ACHIEVEMENTS"]                                    = "Afficher les hauts faits"
L["PRESENCE_ACHIEVEMENT_EARNED_NOTIFICATIONS"]                = "Affiche les notifications de hauts faits obtenus."
L["PRESENCE_ACHIEVEMENT_PROGRESS"]                            = "Progression des hauts faits"
L["PRESENCE_SHOW_ACHIEVEMENT_EARNED"]                         = "Haut fait obtenu"
L["PRESENCE_SHOW_QUEST_ACCEPTED"]                             = "Quête acceptée"
L["PRESENCE_SHOW_WORLD_QUEST_ACCEPTED"]                       = "Expédition acceptée"
L["PRESENCE_SHOW_SCENARIO_COMPLETE"]                          = "Scénario terminé"
L["PRESENCE_SHOW_RARE_DEFEATED"]                              = "Rare vaincu"
L["PRESENCE_NOTIFICATION_TRACKED_ACHIEVEMENT_CRITERIA"]       = "Affiche une notification lorsque les critères d'un haut fait suivi sont mis à jour."
L["PRESENCE_QUEST_ACCEPT"]                                    = "Afficher l'acceptation de quête"
L["PRESENCE_NOTIFICATION_ACCEPTING_A_QUEST"]                  = "Affiche la notification lors de l'acceptation d'une quête."
L["PRESENCE_WORLD_QUEST_ACCEPT"]                              = "Afficher l'acceptation d'expédition"
L["PRESENCE_NOTIFICATION_ACCEPTING_A_WORLD_QUEST"]            = "Affiche la notification lors de l'acceptation d'une expédition."
L["PRESENCE_SHOW_QUEST_COMPLETE"]                             = "Afficher la complétion de quête"
L["PRESENCE_NOTIFICATION_COMPLETING_A_QUEST"]                 = "Affiche la notification lors de la complétion d'une quête."
L["PRESENCE_SHOW_WORLD_QUEST_COMPLETE"]                       = "Afficher la complétion d'expédition"
L["PRESENCE_NOTIFICATION_COMPLETING_A_WORLD_QUEST"]           = "Affiche la notification lors de la complétion d'une expédition."
L["PRESENCE_QUEST_PROGRESS"]                                  = "Afficher la progression des quêtes"
L["PRESENCE_NOTIFICATION_QUEST_OBJECTIVES_UPDATE"]            = "Affiche la notification lors de la mise à jour des objectifs."
L["PRESENCE_OBJECTIVE"]                                       = "Objectif uniquement"
L["PRESENCE_QUEST_PROGRESS_HIDE_TITLE"]                       = "Affiche uniquement la ligne d'objectif sur les notifications de progression, en masquant le titre « Mise à jour de quête »."
L["PRESENCE_SCENARIO_START"]                                  = "Afficher le début de scénario"
L["PRESENCE_NOTIFICATION_ENTERING_A_SCENARIO_DELVE"]          = "Affiche la notification à l'entrée d'un scénario ou d'un Gouffre."
L["PRESENCE_SCENARIO_PROGRESS"]                               = "Afficher la progression du scénario"
L["PRESENCE_NOTIFICATION_SCENARIO_DELVE_OBJECTIVES"]          = "Affiche la notification lors de la mise à jour des objectifs de scénario ou Gouffre."
-- L["PRESENCE_ANIMATION"]                                    = "Animation"
L["PRESENCE_ENABLE_ANIMATIONS"]                               = "Activer les animations"
L["PRESENCE_ENABLE_ENTRANCE_EXIT_ANIMATIONS_PRESENCE"]        = "Active les animations d'entrée et de sortie des notifications."
L["PRESENCE_ENTRANCE_DURATION"]                               = "Durée d'entrée"
L["PRESENCE_DURATION_OF_ENTRANCE_ANIMATION_SECONDS"]          = "Durée de l'animation d'entrée en secondes (0.2–1.5)."
L["PRESENCE_EXIT_DURATION"]                                   = "Durée de sortie"
L["PRESENCE_DURATION_OF_EXIT_ANIMATION_SECONDS"]              = "Durée de l'animation de sortie en secondes (0.2–1.5)."
L["PRESENCE_HOLD_DURATION_SCALE"]                             = "Facteur de durée d'affichage"
L["PRESENCE_MULTIPLIER_LONG_NOTIFICATION_STAY"]               = "Multiplicateur de la durée d'affichage des notifications (0.5–2)."
L["PRESENCE_PREVIEW"]                                         = "Aperçu"
L["PRESENCE_PREVIEW_TOAST_TYPE"]                              = "Aperçu des types d'alertes"
L["PRESENCE_SELECT_A_TOAST_TYPE_PREVIEW"]                     = "Sélectionner un type d'alerte à prévisualiser."
L["PRESENCE_SELECTED_TOAST_TYPE"]                             = "Afficher le type d'alerte sélectionné."
L["PRESENCE_PREVIEW_PRESENCE_TOAST_LAYOUTS_LIVE_OPEN"]        = "Prévisualiser les mises en forme d'alertes Presence, et ouvre un échantillon détachable tout en ajustant d'autres options."
L["PRESENCE_OPEN_DETACHED_PREVIEW"]                           = "Ouvrir l'aperçu détachable"
L["PRESENCE_OPEN_A_MOVABLE_PREVIEW_WINDOW_STAYS"]             = "Ouvre une fenêtre d'aperçu ajustable qui reste visible pendant le réglage des autres options Presence."
L["PRESENCE_ANIMATE_PREVIEW"]                                 = "Animer l'aperçu"
L["PRESENCE_PLAY_SELECTED_TOAST_ANIMATION_INSIDE_PREVIEW"]    = "Lire l'animation de l'alerte sélectionnée dans la fenêtre d'aperçu."
L["PRESENCE_DETACHED_PREVIEW"]                                = "Prévisualisation détachée"
L["PRESENCE_KEEP_OPEN_WHILE_ADJUSTING_TYPOGRAPHY_COLOURS"]    = "Garder cette fenêtre ouverte en réglant les Textes et les Couleurs."
L["DASH_TYPOGRAPHY"]                                          = "Textes"
L["PRESENCE_MAIN_TITLE_FONT"]                                 = "Police du titre principal"
L["PRESENCE_FONT_FAMILY_MAIN_TITLE"]                          = "Famille de police pour le titre principal."
L["PRESENCE_SUBTITLE_FONT"]                                   = "Police du sous-titre"
L["PRESENCE_FONT_FAMILY_SUBTITLE"]                            = "Famille de police pour le sous-titre."
L["PRESENCE_RESET_TYPOGRAPHY_DEFAULTS"]                       = "Réinitialiser les textes."
L["PRESENCE_RESET_PRESENCE_TYPOGRAPHY_OPTIONS_FONTS_SIZES"]   = "Réinitialise tous les réglages des textes Presence (polices, tailles, couleurs) à leur état par défaut."
L["PRESENCE_LARGE_NOTIFICATIONS"]                             = "Grandes notifications"
L["PRESENCE_MEDIUM_NOTIFICATIONS"]                            = "Notifications moyennes"
L["PRESENCE_SMALL_NOTIFICATIONS"]                             = "Petites notifications"
L["PRESENCE_LARGE_PRIMARY_SIZE"]                              = "Taille primaire des grandes notifications"
L["PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_TITLES_ZONE"]        = "Taille du texte des titres de grandes notifications (zones, quête terminée, haut fait, etc.)."
L["PRESENCE_LARGE_SECONDARY_SIZE"]                            = "Taille secondaire des grandes notifications"
L["PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_SUBTITLES"]          = "Taille de sous-titres des grandes notifications."
L["PRESENCE_MEDIUM_PRIMARY_SIZE"]                             = "Taille primaire des notifications moyennes"
-- L["PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_TITLES_QUEST"]   = "Font size for medium notification titles (quest accept, subzone, scenario)."
L["PRESENCE_MEDIUM_SECONDARY_SIZE"]                           = "Taille secondaire des notifications moyennes"
L["PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_SUBTITLES"]         = "Taille de sous-titres des notifications moyennes."
L["PRESENCE_SMALL_PRIMARY_SIZE"]                              = "Taille primaire des petites notifications"
L["PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_TITLES_QUEST"]       = "Taille du texte des titres de petites notifications (progression des quêtes et de hauts faits)."
L["PRESENCE_SMALL_SECONDARY_SIZE"]                            = "Taille secondaire des petites notifications"
L["PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_SUBTITLES"]          = "Taille de sous-titres des petites notifications."

-- =====================================================================
-- OptionsData.lua Dropdown options — Outline
-- =====================================================================
L["FOCUS_OUTLINE_NONE"]                                       = "Aucun"
L["FOCUS_THICK_OUTLINE"]                                      = "Contour épais"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["FOCUS_HIGHLIGHT_BAR_LEFT_EDGE"]                            = "Barre (bord gauche)"
L["FOCUS_HIGHLIGHT_BAR_RIGHT_EDGE"]                           = "Barre (bord droit)"
L["FOCUS_HIGHLIGHT_BAR_TOP_EDGE"]                             = "Barre (bord supérieur)"
L["FOCUS_HIGHLIGHT_BAR_BOTTOM_EDGE"]                          = "Barre (bord inférieur)"
L["FOCUS_HIGHLIGHT_OUTLINE_ONLY"]                             = "Contour uniquement"
L["FOCUS_HIGHLIGHT_SOFT_GLOW"]                                = "Lueur douce"
L["FOCUS_HIGHLIGHT_DUAL_EDGE_BARS"]                           = "Barres doubles"
L["FOCUS_HIGHLIGHT_PILL_LEFT_ACCENT"]                         = "Accent pilule gauche"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["FOCUS_MYTHICPLUS_POSITION_TOP"]                            = "Haut"
L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"]                         = "Bas"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["VISTA_LOCATION_POSITION"]                                  = "Position du nom de zone"
L["VISTA_PLACE_ZONE_NAME_ABOVE_BELOW_MINIMAP"]                = "Place le nom de zone au-dessus ou en dessous de la minicarte."
L["VISTA_COORDINATES_POSITION"]                               = "Position des coordonnées"
L["VISTA_PLACE_COORDINATES_ABOVE_BELOW_MINIMAP"]              = "Place les coordonnées au-dessus ou en dessous de la minicarte."
L["VISTA_CLOCK_POSITION"]                                     = "Position de l'horloge"
L["VISTA_PLACE_CLOCK_ABOVE_BELOW_MINIMAP"]                    = "Place l'horloge au-dessus ou en dessous de la minicarte."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["FOCUS_TEXT_LOWER_CASE"]                                    = "Minuscules"
L["FOCUS_TEXT_UPPER_CASE"]                                    = "Majuscules"
L["FOCUS_TEXT_PROPER_CASE"]                                   = "Première lettre en majuscule"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["FOCUS_TRACKED_LOG"]                                        = "Suivies / Dans le journal"
L["FOCUS_LOG_MAX_SLOTS"]                                      = "Dans le journal / Max"

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["FOCUS_ALPHABETICAL"]                                       = "Alphabétique"
L["FOCUS_QUEST_TYPE"]                                         = "Type de quête"
L["FOCUS_QUEST_LEVEL"]                                        = "Niveau de quête"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["FOCUS_CUSTOM"]                                             = "Personnalisé"
L["FOCUS_ORDER"]                                              = "Ordre"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["UI_DUNGEON"]                                               = "DONJON"
-- L["UI_RAID"]                                               = "RAID"
L["UI_DELVES"]                                                = "GOUFFRES"
L["UI_SCENARIO_EVENTS"]                                       = "SCENARIO"
L["UI_STAGE"]                                                 = "Niveau"
L["UI_STAGE_X_X"]                                             = "Niveau %d: %s"
L["UI_AVAILABLE_IN_ZONE"]                                     = "DISPONIBLE DANS LA ZONE"
L["UI_EVENTS_IN_ZONE"]                                        = "ÉVÈNEMENTS DANS LA ZONE"
L["UI_CURRENT_EVENT"]                                         = "ÉVÈNEMENT EN COURS"
L["UI_CURRENT_QUEST"]                                         = "QUÊTE EN COURS"
L["UI_CURRENT_ZONE"]                                          = "ZONE ACTUELLE"
L["UI_CAMPAIGN"]                                              = "CAMPAGNE"
-- L["UI_IMPORTANT"]                                          = "IMPORTANT"
L["UI_LEGENDARY"]                                             = "LEGENDAIRE"
L["UI_WORLD_QUESTS"]                                          = "EXPÉDITIONS"
L["UI_WEEKLY_QUESTS"]                                         = "QUÊTES HEBDOMDAIRES"
L["UI_PREY"]                                                  = "Traque"
L["UI_ABUNDANCE"]                                             = "Abondance"
L["UI_ABUNDANCE_BAG"]                                         = "Sac d'abondance"
L["UI_ABUNDANCE_HELD"]                                        = "Abondance détenue"
L["UI_DAILY_QUESTS"]                                          = "QUÊTES JOURNALIÈRES"
L["UI_RARE_BOSSES"]                                           = "BOSS RARES"
L["UI_ACHIEVEMENTS"]                                          = "HAUTS FAITS"
L["UI_ENDEAVORS"]                                             = "INITIATIVES"
L["UI_DECOR"]                                                 = "DÉCORATION"
-- L["UI_RECIPES"]                                            = "Recipes"
-- L["UI_ADVENTURE_GUIDE"]                                    = "Adventure Guide"
-- L["UI_APPEARANCES"]                                        = "Appearances"
L["UI_QUESTS"]                                                = "QUÊTES"
L["UI_READY_TO_TURN_IN"]                                      = "À RENDRE"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["PRESENCE_OBJECTIVES"]                                      = "OBJECTIFS"
-- L["PRESENCE_OPTIONS"]                                      = "Options"
L["PRESENCE_OPEN_HORIZON_SUITE"]                              = "Ouvrir Horizon Suite"
L["PRESENCE_OPEN_FULL_HORIZON_SUITE_OPTIONS"]                 = "Ouvre le panneau d'options complet pour configurer Focus, Presence, Vista et les autres modules."
L["PRESENCE_MINIMAP_SECTION"]                                 = "Minimap icon"
L["PRESENCE_SHOW_MINIMAP_ICON"]                               = "Afficher l'icône sur la minicarte"
L["PRESENCE_A_CLICKABLE_ICON_MINIMAP_OPENS"]                  = "Affiche une icône cliquable sur la minicarte qui ouvre le panneau d'options."
L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER"]         = "Fade until minimap hover"
-- L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER_DESC"] = "When on, the icon stays faded until you move the cursor over the minimap. When off, it stays fully visible."
L["PRESENCE_LOCK_MINIMAP_BUTTON_POSITION"]                    = "Verrouiller le bouton de la minicarte"
L["PRESENCE_PREVENT_DRAGGING_HORIZON_MINIMAP_BUTTON"]         = "Empêche de déplacer le bouton de la minicarte Horizon."
L["PRESENCE_RESET_MINIMAP_BUTTON_POSITION"]                   = "Réinitialiser la position du bouton de la minicarte"
L["PRESENCE_RESET_MINIMAP_BUTTON_DEFAULT_POSITION"]           = "Replace le bouton de la minimap à sa position par défaut (en bas à gauche)."
L["PRESENCE_DRAG_TO_MOVE_WHEN_UNLOCKED"]                      = "Glisser pour déplacer (quand déverrouillé)."
L["PRESENCE_LOCKED"]                                          = "Verrouillé"
L["PRESENCE_DISCOVERED"]                                      = "Découverte"
L["PRESENCE_REFRESH"]                                         = "Actualiser"
L["PRESENCE_BEST_EFFORT_UNACCEPTED_QUESTS_EXPO"]              = "Recherche approximative. Certaines quêtes non acceptées ne sont pas visibles avant d'interagir avec des PNJ ou dans certaines conditions de phase."
L["PRESENCE_UNACCEPTED_QUESTS_X_MAP_X"]                       = "Quêtes non acceptées - %s (carte %s) - %d correspondante(s)"
L["PRESENCE_LEVEL_UP"]                                        = "MONTÉE DE NIVEAU"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_80"]                       = "Vous avez atteint le niveau 80"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_X"]                        = "Vous avez atteint le niveau %s"
L["PRESENCE_ACHIEVEMENT_EARNED"]                              = "HAUT FAIT OBTENU"
L["PRESENCE_EXPLORING_THE_MIDNIGHT_ISLES"]                    = "Exploration des Îles de Midnight"
L["PRESENCE_EXPLORING_KHAZ_ALGAR"]                            = "Exploration de Khaz Algar"
L["PRESENCE_QUEST_COMPLETE"]                                  = "QUÊTE TERMINÉE"
L["PRESENCE_OBJECTIVE_SECURED"]                               = "Objectif sécurisé"
L["PRESENCE_AIDING_THE_ACCORD"]                               = "Aider l'Accord"
L["PRESENCE_WORLD_QUEST"]                                     = "EXPÉDITION"
L["PRESENCE_WORLD_QUEST_COMPLETE"]                            = "EXPÉDITION TERMINÉE"
L["PRESENCE_AZERITE_MINING"]                                  = "Extraction d'azérite"
L["PRESENCE_WORLD_QUEST_ACCEPTED"]                            = "EXPÉDITION ACCEPTÉE"
L["PRESENCE_QUEST_ACCEPTED"]                                  = "QUÊTE ACCEPTÉE"
L["PRESENCE_THE_FATE_OF_THE_HORDE"]                           = "Le Destin de la Horde"
L["PRESENCE_NEW_QUEST"]                                       = "Nouvelle quête"
L["PRESENCE_QUEST_UPDATE"]                                    = "MISE À JOUR DE QUÊTE"
L["PRESENCE_BOAR_PELTS_7_10"]                                 = "Peaux de sanglier : 7/10"
L["PRESENCE_DRAGON_GLYPHS_3_5"]                               = "Glyphes de dragon : 3/5"
L["PRESENCE_TEST_COMMANDS"]                                   = "Commandes de test Presence :"
L["PRESENCE_H_DEBUGTYPES_DUMP_NOTIFICATION"]                  = "  /h presence debugtypes - Rapporte toggle de notifications et les états de suppression Blizzard"
L["PRESENCE_PLAYING_DEMO_REEL_NOTIFICATION"]                  = "Presence: Lecture de la démo (tous les types de notifications)..."
L["PRESENCE_H_HELP_TEST_CURRENT"]                             = "  /h presence         - Afficher l'aide + test de la zone actuelle"
L["PRESENCE_H_ZONE_TEST"]                                     = "  /h presence zone     - Test de changement de zone"
L["PRESENCE_H_SUBZONE_TEST"]                                  = "  /h presence subzone  - Test de changement de sous-zone"
L["PRESENCE_H_DISCOVER_TEST_ZONE"]                            = "  /h presence discover - Test de découverte de zone"
L["PRESENCE_H_LEVEL_TEST"]                                    = "  /h presence level    - Test de montée de niveau"
L["PRESENCE_H_BOSS_TEST"]                                     = "  /h presence boss     - Test d'emote de boss"
L["PRESENCE_H_ACHIEVEMENT_TEST"]                              = "  /h presence ach      - Test de haut fait"
L["PRESENCE_H_ACCEPT_TEST_QUEST"]                             = "  /h presence accept   - Test de quête acceptée"
L["PRESENCE_H_WORLD_QUEST_ACCEPT_TEST"]                       = "  /h presence wqaccept - Test d'expédition acceptée"
L["PRESENCE_H_SCENARIO_TEST"]                                 = "  /h presence scenario - Test de début de scénario"
L["PRESENCE_H_QUEST_TEST_COMPLETE"]                           = "  /h presence quest    - Test de quête terminée"
L["PRESENCE_H_WORLD_QUEST_TEST"]                              = "  /h presence wq       - Test d'expédition"
L["PRESENCE_H_QUEST_UPDATE_TEST"]                             = "  /h presence update   - Test de mise à jour de quête"
L["PRESENCE_H_ACHIEVEMENT_PROGRESS_TEST"]                     = "  /h presence achprogress - Test de progression de haut fait"
L["PRESENCE_H_DEMO_REEL_TYPES"]                               = "  /h presence all      - Démo (tous les types)"
L["PRESENCE_H_DEBUG_DUMP_STATE"]                              = "  /h presence debug    - Rapporte les états dans le chat"
L["PRESENCE_H_DEBUGLIVE_TOGGLE_LIVE"]                         = "  /h presence debuglive - Activer/désactiver le panneau de debug en direct (journaliser les événements)"

-- =====================================================================
-- OptionsData.lua Vista — General
L["VISTA_POSITION_LAYOUT"]                                    = "Position & Mise en forme"

-- =====================================================================
L["VISTA_DESC"]                                               = "Minicarte"
L["VISTA_SIZE"]                                               = "Taille de la minicarte"
L["VISTA_WIDTH_HEIGHT_OF_MINIMAP_PIXELS"]                     = "Largeur et hauteur de la minicarte en pixels (100–400)."
L["VISTA_CIRCULAR_MINIMAP"]                                   = "Minicarte circulaire"
L["VISTA_CIRCULAR_SHAPE"]                                     = "Forme circulaire"
L["VISTA_A_CIRCULAR_MINIMAP_INSTEAD_OF_SQUARE"]               = "Utilise une minicarte circulaire au lieu de carrée."
L["VISTA_LOCK_MINIMAP_POSITION"]                              = "Verrouiller la position de la minicarte"
L["VISTA_PREVENT_DRAGGING_MINIMAP"]                           = "Empêche de déplacer la minicarte."
L["VISTA_RESET_MINIMAP_POSITION"]                             = "Réinitialiser la position de la minicarte"
L["VISTA_RESET_MINIMAP_DEFAULT_POSITION_TOP_RIGHT"]           = "Réinitialise la minicarte à sa position par défaut (en haut à droite)."
L["VISTA_RESET_OVERLAY_POSITIONS"]                            = "Reset overlay positions to defaults"
L["VISTA_RESET_OVERLAY_POSITIONS_DESC"]                       = "Clear saved positions for zone text, coordinates, clock, performance and difficulty text, zoom buttons, tracking, calendar, queue, mail, the addon button bar, drawer button, and right-click panel. The minimap frame position is not changed."
L["VISTA_AUTO_ZOOM"]                                          = "Zoom automatique"
L["VISTA_AUTO_ZOOM_DELAY"]                                    = "Délai de dézoom automatique"
L["VISTA_SECONDS_AFTER_ZOOMING_BEFORE_AUTO_ZOOM"]             = "Secondes après un zoom avant le dézoom automatique. Mettre à 0 pour désactiver."

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["VISTA_ZONE_TEXT_HEADER"]                                   = "Texte de zone"
L["VISTA_ZONE_FONT"]                                          = "Police de zone"
L["VISTA_FONT_ZONE_NAME_BELOW_MINIMAP"]                       = "Police du nom de zone sous la minicarte."
L["VISTA_ZONE_FONT_SIZE"]                                     = "Taille de la police de zone"
L["VISTA_ZONE_TEXT_COLOUR"]                                   = "Couleur du texte de zone"
L["VISTA_COLOUR_OF_ZONE_NAME_TEXT"]                           = "Couleur du texte du nom de zone."
L["VISTA_COORDINATES_TEXT"]                                   = "Texte des coordonnées"
L["VISTA_COORDINATES_FONT"]                                   = "Police des coordonnées"
L["VISTA_FONT_COORDINATES_TEXT_BELOW_MINIMAP"]                = "Police du texte des coordonnées sous la minicarte."
L["VISTA_COORDINATES_FONT_SIZE"]                              = "Taille de la police des coordonnées"
L["VISTA_COORDINATES_TEXT_COLOUR"]                            = "Couleur du texte des coordonnées"
L["VISTA_COLOUR_OF_COORDINATES_TEXT"]                         = "Couleur du texte des coordonnées."
L["VISTA_COORDINATE_PRECISION"]                               = "Précision des coordonnées"
L["VISTA_NUMBER_OF_DECIMAL_PLACES_SHOWN_X"]                   = "Nombre de décimales affichées pour les coordonnées X et Y."
L["VISTA_COORDS_DECIMALS_OFF"]                                = "Sans décimales (ex. 52, 37)"
L["VISTA_DECIMAL_E_G"]                                        = "1 décimale (ex. 52.3, 37.1)"
L["VISTA_DECIMALS_E_G"]                                       = "2 décimales (ex. 52.34, 37.12)"
L["VISTA_TEXT"]                                               = "Texte de l'heure"
L["VISTA_FONT"]                                               = "Police de l'heure"
L["VISTA_FONT_TEXT_BELOW_MINIMAP"]                            = "Police du texte de l'heure sous la minicarte."
L["VISTA_FONT_SIZE"]                                          = "Taille de la police de l'heure"
L["VISTA_TEXT_COLOUR"]                                        = "Couleur du texte de l'heure"
L["VISTA_COLOUR_OF_TEXT"]                                     = "Couleur du texte de l'heure."
L["VISTA_PERFORMANCE_TEXT"]                                   = "Texte de performances"
L["VISTA_PERFORMANCE_FONT"]                                   = "Police de performances"
L["VISTA_FONT_FPS_LATENCY_TEXT_BELOW_MINIMAP"]                = "Police d'affichage des FPS et de la latence sous la minicarte."
L["VISTA_PERFORMANCE_FONT_SIZE"]                              = "Taille de la police de performances"
L["VISTA_PERFORMANCE_TEXT_COLOUR"]                            = "Couleur du texte de performances"
L["VISTA_COLOUR_OF_FPS_LATENCY_TEXT"]                         = "Couleur des FPS et du texte."
L["VISTA_DIFFICULTY_TEXT"]                                    = "Texte de difficulté"
L["VISTA_DIFFICULTY_TEXT_COLOUR_FALLBACK"]                    = "Couleur du texte de difficulté (par défaut)"
L["VISTA_DEFAULT_COLOUR_PER_DIFFICULTY_COLOUR"]               = "Couleur par défaut quand aucune couleur par difficulté n'est définie."
L["VISTA_DIFFICULTY_FONT"]                                    = "Police de difficulté"
L["VISTA_FONT_INSTANCE_DIFFICULTY_TEXT"]                      = "Police du texte de difficulté d'instance."
L["VISTA_DIFFICULTY_FONT_SIZE"]                               = "Taille de la police de difficulté"
L["VISTA_PER_DIFFICULTY_COLOURS"]                             = "Couleurs par difficulté"
L["VISTA_MYTHIC_COLOUR"]                                      = "Couleur Mythique"
L["VISTA_COLOUR_MYTHIC_DIFFICULTY_TEXT"]                      = "Couleur du texte de difficulté Mythique."
L["VISTA_HEROIC_COLOUR"]                                      = "Couleur Héroïque"
L["VISTA_COLOUR_HEROIC_DIFFICULTY_TEXT"]                      = "Couleur du texte de difficulté Héroïque."
L["VISTA_NORMAL_COLOUR"]                                      = "Couleur Normal"
L["VISTA_COLOUR_NORMAL_DIFFICULTY_TEXT"]                      = "Couleur du texte de difficulté Normal."
L["VISTA_LFR_COLOUR"]                                         = "Couleur LFR"
L["VISTA_COLOUR_LOOKING_RAID_DIFFICULTY_TEXT"]                = "Couleur du texte de difficulté Raid aléatoire."

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["VISTA_TEXT_ELEMENTS"]                                      = "Éléments de texte"
L["VISTA_ZONE_TEXT"]                                          = "Afficher le texte de zone"
L["VISTA_ZONE_NAME_BELOW_MINIMAP"]                            = "Affiche le nom de zone sous la minicarte."
L["VISTA_ZONE_TEXT_DISPLAY_MODE"]                             = "Mode d'affichage du texte de zone"
L["VISTA_WHAT_ZONE_SUBZONE"]                                  = "Quoi afficher : zone seulement, sous-zone seulement, ou les deux."
L["VISTA_SHOW_ZONE"]                                          = "Zone seulement"
L["VISTA_SHOW_SUBZONE"]                                       = "Sous-zone seulement"
L["VISTA_SHOW_ZONE_AND_SUBZONE"]                              = "Les deux"
L["VISTA_COORDINATES"]                                        = "Afficher les coordonnées"
L["VISTA_PLAYER_COORDINATES_BELOW_MINIMAP"]                   = "Affiche les coordonnées du joueur sous la minicarte."
L["VISTA_TIME"]                                               = "Afficher l'heure"
L["VISTA_CURRENT_GAME_BELOW_MINIMAP"]                         = "Affiche l'heure actuelle du jeu sous la minicarte."
L["VISTA_HOUR_CLOCK"]                                         = "Affichage 24h"
L["VISTA_DISPLAY_HOUR_FORMAT_24"]                             = "Affiche l'heure dans un format 24h (ex 14:30 au lieu de 2:30 PM)."
L["VISTA_LOCAL_TIME"]                                         = "Utiliser l'heure locale"
L["VISTA_LOCAL_TIME_TIP"]                                     = "Activé : affiche l'heure locale du système. Désactivé : affiche l'heure du serveur."
L["VISTA_FPS_LATENCY"]                                        = "Afficher les FPS et la latence"
L["VISTA_FPS_LATENCY_MS_BELOW_MINIMAP"]                       = "Affiche les FPS et la latence (ms) sous la minicarte."
L["VISTA_MINIMAP_BUTTONS"]                                    = "Boutons de minicarte"
L["VISTA_QUEUE_STATUS_MAIL_INDICATOR_ALWAYS_SHOWN"]           = "Le statut de file et l'indicateur de courrier sont toujours affichés si pertinents."
L["VISTA_TRACKING_BUTTON"]                                    = "Afficher le bouton de suivi"
L["VISTA_MINIMAP_TRACKING_BUTTON"]                            = "Affiche le bouton de suivi sur la minicarte."
L["VISTA_TRACKING_BUTTON_MOUSEOVER"]                          = "Bouton de suivi au survol uniquement"
L["VISTA_HIDE_TRACKING_BUTTON_UNTIL_YOU_HOVER"]               = "Masque le bouton de suivi jusqu'au survol de la minicarte."
L["VISTA_CALENDAR_BUTTON"]                                    = "Afficher le bouton de calendrier"
L["VISTA_MINIMAP_CALENDAR_BUTTON"]                            = "Affiche le bouton de calendrier sur la minicarte."
L["VISTA_CALENDAR_BUTTON_MOUSEOVER"]                          = "Bouton de calendrier au survol uniquement"
L["VISTA_HIDE_CALENDAR_BUTTON_UNTIL_YOU_HOVER"]               = "Masque le bouton de calendrier jusqu'au survol de la minicarte."
L["VISTA_ZOOM_BUTTONS"]                                       = "Afficher les boutons de zoom"
L["VISTA_ZOOM_BUTTONS_MINIMAP"]                               = "Affiche les boutons de zoom + et - sur la minicarte."
L["VISTA_ZOOM_BUTTONS_MOUSEOVER"]                             = "Boutons de zoom au survol uniquement"
L["VISTA_HIDE_ZOOM_BUTTONS_UNTIL_YOU_HOVER"]                  = "Masque les boutons de zoom jusqu'au survol de la minicarte."

-- =====================================================================
-- OptionsData.lua Vista — Display (Border / Text Positions / Buttons)
-- =====================================================================
L["VISTA_BORDER"]                                             = "Bordure"
L["VISTA_BORDER_TIP"]                                         = "Affiche une bordure autour de la minicarte."
L["VISTA_BORDER_COLOUR"]                                      = "Couleur de la bordure"
L["VISTA_COLOUR_OPACITY_OF_MINIMAP_BORDER"]                   = "Couleur (et opacité) de la bordure de la minicarte."
L["VISTA_BORDER_THICKNESS"]                                   = "Épaisseur de la bordure"
L["VISTA_THICKNESS_OF_MINIMAP_BORDER_PIXELS"]                 = "Épaisseur de la bordure de la minicarte en pixels (1–8)."
L["VISTA_CLASS_COLOURS"]                                      = "Couleurs de classe"
L["VISTA_TINT_VISTA_BORDER_TEXT_COORDS_FPS"]                  = "Colore les contours Vista (coordonnées, heure, affichage FPS/MS) avec la couleur de la classe. Les chiffres utilisent la couleur personnalisée."
L["VISTA_TEXT_POSITIONS"]                                     = "Positions du texte"
L["VISTA_DRAG_TEXT_ELEMENTS_REPOSITION_LOCK_PREVEN"]          = "Glissez les éléments de texte pour les repositionner. Verrouillez pour éviter les déplacements accidentels."
L["VISTA_LOCK_ZONE_TEXT_POSITION"]                            = "Verrouiller la position du texte de zone"
L["VISTA_ZONE_TEXT_CANNOT_DRAGGED"]                           = "Activé : le texte de zone ne peut pas être déplacé."
L["VISTA_LOCK_COORDINATES_POSITION"]                          = "Verrouiller la position des coordonnées"
L["VISTA_COORDINATES_TEXT_CANNOT_DRAGGED"]                    = "Activé : le texte des coordonnées ne peut pas être déplacé."
L["VISTA_LOCK_POSITION"]                                      = "Verrouiller la position de l'heure"
L["VISTA_TEXT_CANNOT_DRAGGED"]                                = "Activé : le texte de l'heure ne peut pas être déplacé."
L["VISTA_PERFORMANCE_TEXT_POSITION"]                          = "Position du texte des performances."
L["VISTA_PLACE_FPS_LATENCY_TEXT_ABOVE_BELOW"]                 = "Positionne le texte des FPS/latence au-dessus ou au-dessous de la minicarte."
L["VISTA_LOCK_PERFORMANCE_TEXT_POSITION"]                     = "Verrouiller la position du texte des performances."
L["VISTA_FPS_LATENCY_TEXT_CANNOT_DRAGGED"]                    = "Quand activé, le texte des FPS/latence ne peut plus être déplacé."
L["VISTA_DIFFICULTY_TEXT_POSITION"]                           = "Difficulty text position"
-- L["VISTA_PLACE_DIFFICULTY_TEXT_ABOVE_BELOW"]               = "Place the instance difficulty text above or below the minimap. It is positioned independently of zone text."
L["VISTA_LOCK_DIFFICULTY_TEXT_POSITION"]                      = "Verrouiller la position du texte de difficulté"
L["VISTA_DIFFICULTY_TEXT_CANNOT_DRAGGED"]                     = "Activé : le texte de difficulté ne peut pas être déplacé."
L["VISTA_BUTTON_POSITIONS"]                                   = "Positions des boutons"
L["VISTA_DRAG_BUTTONS_REPOSITION_LOCK_PREVENT_MOVE"]          = "Glissez les boutons pour les repositionner. Verrouillez pour bloquer le déplacement."
L["VISTA_LOCK_ZOOM_BUTTON"]                                   = "Verrouiller le bouton Zoom +"
L["VISTA_PREVENT_DRAGGING_ZOOM_BUTTON"]                       = "Empêche de déplacer le bouton de zoom +."
L["VISTA_LOCK_ZOOM_OUT_BUTTON"]                               = "Verrouiller le bouton Zoom -"
L["VISTA_LOCK_ZOOM_OUT_DRAG"]                                 = "Empêche de déplacer le bouton de zoom -."
L["VISTA_LOCK_TRACKING_BUTTON"]                               = "Verrouiller le bouton de suivi"
L["VISTA_PREVENT_DRAGGING_TRACKING_BUTTON"]                   = "Empêche de déplacer le bouton de suivi."
L["VISTA_LOCK_CALENDAR_BUTTON"]                               = "Verrouiller le bouton de calendrier"
L["VISTA_PREVENT_DRAGGING_CALENDAR_BUTTON"]                   = "Empêche de déplacer le bouton de calendrier."
L["VISTA_LOCK_QUEUE_BUTTON"]                                  = "Verrouiller le bouton de la file d'attente"
L["VISTA_PREVENT_DRAGGING_QUEUE_STATUS_BUTTON"]               = "Empêche de déplacer le bouton de statut de la file d'attente."
L["VISTA_LOCK_MAIL_INDICATOR"]                                = "Verrouiller l'indicateur de courrier"
L["VISTA_PREVENT_DRAGGING_MAIL_ICON"]                         = "Empêche de déplacer l'icône de courrier."
-- L["VISTA_LOCK_CRAFTING_ORDER_INDICATOR"]                   = "Lock Crafting Order Indicator"
-- L["VISTA_PREVENT_DRAGGING_CRAFTING_ORDER_ICON"]            = "Prevent dragging the crafting order icon."
L["VISTA_DISABLE_QUEUE_HANDLING"]                             = "Désactiver la gestion de la file d'attente"
L["VISTA_DISABLE_QUEUE_BUTTON_HANDLING"]                      = "Désactiver la gestion du bouton de la file d'attente"
L["VISTA_TURN_QUEUE_BUTTON_ANCHORING_OFF_ADDON_CONFLICT"]     = "Désactive tout ancrage du bouton de file d'attente (si un autre addon le gère)."
L["VISTA_BUTTON_SIZES"]                                       = "Tailles des boutons"
L["VISTA_ADJUST_SIZE_OF_MINIMAP_OVERLAY_BUTTONS"]             = "Ajuste la taille des boutons superposés à la minicarte."
L["VISTA_TRACKING_BUTTON_SIZE"]                               = "Taille du bouton de suivi"
L["VISTA_SIZE_OF_TRACKING_BUTTON_PIXELS"]                     = "Taille du bouton de suivi (pixels)."
L["VISTA_CALENDAR_BUTTON_SIZE"]                               = "Taille du bouton de calendrier"
L["VISTA_SIZE_OF_CALENDAR_BUTTON_PIXELS"]                     = "Taille du bouton de calendrier (pixels)."
L["VISTA_QUEUE_BUTTON_SIZE"]                                  = "Taille du bouton de file"
L["VISTA_SIZE_OF_QUEUE_STATUS_BUTTON_PIXELS"]                 = "Taille du bouton de statut de la file d'attente (pixels)."
L["VISTA_ZOOM_BUTTON_SIZE"]                                   = "Taille des boutons de zoom"
L["VISTA_SIZE_OF_ZOOM_ZOOM_BUTTONS_PIXELS"]                   = "Taille des boutons zoom + / zoom - (pixels)."
L["VISTA_MAIL_INDICATOR_SIZE"]                                = "Taille de l'indicateur de courrier"
L["VISTA_SIZE_OF_MAIL_ICON_PIXELS"]                           = "Taille de l'icône de nouveau courrier (pixels)."
-- L["VISTA_CRAFTING_ORDER_INDICATOR_SIZE"]                   = "Crafting Order Indicator Size"
-- L["VISTA_SIZE_OF_CRAFTING_ORDER_ICON_PIXELS"]              = "Size of the crafting order icon (pixels)."
L["VISTA_ADDON_BUTTON_SIZE"]                                  = "Taille des boutons d'addon"
L["VISTA_SIZE_OF_COLLECTED_ADDON_MINIMAP_BUTTONS"]            = "Taille des boutons d'addon collectés sur la minicarte (pixels)."

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
L["VISTA_COLLECT_HORIZON_MINIMAP"]                            = "Include Horizon minimap icon"
-- L["VISTA_COLLECT_HORIZON_MINIMAP_DESC"]                    = "Put Horizon's own minimap icon in the managed addon bar, right-click panel, or drawer instead of leaving it on the minimap edge."
-- L["VISTA_SORT_BUTTONS_ALPHA"]                              = "Sort Buttons Alphabetically"
-- L["VISTA_SORT_BUTTONS_ALPHA_DESC"]                         = "Sort collected addon minimap buttons alphabetically by name."
L["VISTA_ADDON_BUTTONS"]                                      = "Boutons d'addons"
L["VISTA_MINIMAP_ADDON_BUTTONS"]                              = "Boutons d'addon sur la minicarte"
L["VISTA_BUTTON_MANAGEMENT"]                                  = "Gestion des boutons"
L["VISTA_MANAGE_ADDON_MINIMAP_BUTTONS"]                       = "Gérer les boutons d'addon sur la minicarte"
L["VISTA_TAKES_CONTROL_OF_ADDON_MINIMAP"]                     = "Activé : Vista prend le contrôle des boutons d'addon et les regroupe selon le mode sélectionné."
L["VISTA_BUTTON_MODE"]                                        = "Mode des boutons"
L["VISTA_ADDON_BUTTONS_PRESENTED_HOVER_BAR_BELOW"]            = "Comment les boutons d'addon sont présentés : barre au survol, panneau au clic droit, ou tiroir flottant."
L["VISTA_ALWAYS_BAR"]                                         = "Toujours montrer la barre"
L["VISTA_ALWAYS_MOUSEOVER_BAR_POSITIONING"]                   = "Toujours montrer la barre au survol (pour déplacer)"
L["VISTA_KEEP_MOUSEOVER_BAR_VISIBLE_TIMES_YOU"]               = "Toujours garder la barre au survol visible pour permettre son déplacement. Désactiver une fois terminé."
L["VISTA_DISABLE_DONE"]                                       = "Désactiver une fois terminé."
L["VISTA_MOUSEOVER_BAR"]                                      = "Barre au survol"
L["VISTA_RIGHT_CLICK_PANEL"]                                  = "Panneau clic droit"
L["VISTA_FLOATING_DRAWER"]                                    = "Tiroir flottant"
-- L["VISTA_DRAWER_BUTTON_ICON"]                              = "Drawer button icon"
L["VISTA_DRAWER_BUTTON_ICON_DESC"]                            = "Enter a Blizzard icon file ID or texture path. Leave blank to use the default drawer icon."
-- L["VISTA_CHOOSE_ICON"]                                     = "Choose icon"
L["VISTA_CHOOSE_DRAWER_ICON"]                                 = "Choose Drawer Icon"
L["VISTA_LOCK_DRAWER_BUTTON_POSITION"]                        = "Verrouiller la position du bouton tiroir"
L["VISTA_PREVENT_DRAGGING_FLOATING_DRAWER_BUTTON"]            = "Empêche de déplacer le bouton du tiroir flottant."
L["VISTA_LOCK_MOUSEOVER_BAR_POSITION"]                        = "Verrouiller la position de la barre au survol"
L["VISTA_PREVENT_DRAGGING_MOUSEOVER_BUTTON_BAR"]              = "Empêche de déplacer la barre de boutons au survol."
L["VISTA_LOCK_RIGHT_CLICK_PANEL_POSITION"]                    = "Verrouiller la position du panneau clic droit"
L["VISTA_PREVENT_DRAGGING_RIGHT_CLICK_PANEL"]                 = "Empêche de déplacer le panneau clic droit."
L["VISTA_BUTTONS_PER_ROW_COLUMN"]                             = "Boutons par ligne/colonne"
L["VISTA_CONTROLS_MANY_BUTTONS_APPEAR_BEFORE_WRAPPING"]       = "Contrôle le nombre de boutons avant retour à la ligne. Pour gauche/droite : colonnes ; pour haut/bas : lignes."
L["VISTA_EXPAND_DIRECTION"]                                   = "Direction d'expansion"
L["VISTA_DIRECTION_BUTTONS_FILL_ANCHOR_POINT_LEFT"]           = "Direction de remplissage depuis le point d'ancrage. Gauche/Droite = lignes horizontales. Haut/Bas = colonnes verticales."
L["VISTA_BUTTONS_FILL_RIGHT"]                                 = "Droite"
L["VISTA_BUTTONS_FILL_LEFT"]                                  = "Gauche"
L["VISTA_BUTTONS_FILL_DOWN"]                                  = "Bas"
L["VISTA_BUTTONS_FILL_UP"]                                    = "Haut"
L["VISTA_MOUSEOVER_BAR_APPEARANCE"]                           = "Apparence de la barre au survol"
L["VISTA_BACKGROUND_BORDER_MOUSEOVER_BUTTON_BAR"]             = "Fond et contour de la barre de boutons au survol."
L["VISTA_BACKDROP_COLOUR"]                                    = "Couleur de fond"
L["VISTA_BACKGROUND_COLOUR_OF_MOUSEOVER_BUTTON_BAR"]          = "Couleur de fond de la barre de boutons au survol (Utiliser l'alpha pour controler la transparence)."
L["VISTA_BAR_BORDER"]                                         = "Afficher les contours de la barre"
L["VISTA_A_BORDER_AROUND_MOUSEOVER_BUTTON_BAR"]               = "Affiche un contour autour de la barre de boutons au survol."
L["VISTA_BAR_BORDER_COLOUR"]                                  = "Couleur de contour de la barre"
L["VISTA_BORDER_COLOUR_OF_MOUSEOVER_BUTTON_BAR"]              = "Couleur du contour de la barre de boutons au survol."
L["VISTA_BAR_BACKGROUND_COLOUR"]                              = "Couleur du fond de la barre"
L["VISTA_PANEL_BACKGROUND_COLOUR"]                            = "Couleur du fond du panneau."
L["VISTA_CLOSE_FADE_TIMING"]                                  = "Timing de Fermeture / Fondu"
L["VISTA_MOUSEOVER_BAR_CLOSE_DELAY_SECONDS"]                  = "Barre au survol — Délai de fermeture (secondes)"
L["VISTA_LONG_SECONDS_BAR_STAYS_VISIBLE_AFTER"]               = "Combien de temps (en secondes) la barre reste visible après que le curseur ne la survole plus. 0 = fondu instantané."
L["VISTA_RIGHT_CLICK_PANEL_CLOSE_DELAY_SECONDS"]              = "Clic droit sur le panneau — Délai de fermeture (secondes)"
L["VISTA_LONG_SECONDS_PANEL_STAYS_OPEN_AFTER"]                = "Combien de temps (en secondes) le panneau reste ouvert après que le curseur ne la survole plus. 0 = ne ferme jamais (Fermer de nouveau avec un clic droit)."
L["VISTA_FLOATING_DRAWER_CLOSE_DELAY_SECONDS"]                = "Conteneur flottant — Délai de fermeture (secondes)"
L["VISTA_DRAWER_CLOSE_DELAY"]                                 = "Délai de fermeture du conteneur"
L["VISTA_LONG_SECONDS_DRAWER_PANEL_STAYS_OPEN"]               = "Combien de temps (en secondes) le conteneur reste ouvert après avoir cliquer ailleurs. 0 = pas de fermeture automatique (ne ferme qu'en recliquant sur le bouton de conteneur)."
L["VISTA_MAIL_ICON_BLINK"]                                    = "Clignotement de l'icône de courrier"
L["VISTA_MAIL_ICON_PULSES_DRAW_ATTENTION"]                    = "Quand activé, l'icône de courrier clignote pour attirer l'attention. Désactivé, il reste fixe et opaque."
-- L["VISTA_CRAFTING_ORDER_ICON_PULSE"]                       = "Crafting Order Icon Pulse"
-- L["VISTA_CRAFTING_ORDER_ICON_PULSES_DRAW_ATTENTION"]       = "When on, the crafting order icon pulses to draw attention. When off, it stays at full opacity."
-- L["VISTA_CRAFTING_ORDER_TOOLTIP"]                          = "Personal Crafting Orders"
-- L["VISTA_CRAFTING_ORDER_PENDING_COUNT"]                    = "%d pending"
-- L["VISTA_CRAFTING_ORDER_PROFESSION_LINE"]                  = "  %s: %d"
L["VISTA_PANEL_APPEARANCE"]                                   = "Apparence du panneau"
L["VISTA_COLOURS_DRAWER_RIGHT_CLICK_BUTTON_PANELS"]           = "Couleurs pour le tiroir et les panneaux du clic droit."
L["VISTA_PANEL_BG_COLOUR_LABEL"]                              = "Couleur de fond du panneau"
L["VISTA_BACKGROUND_COLOUR_OF_ADDON_BUTTON_PANELS"]           = "Couleur de fond des boutons d'addons."
L["VISTA_PANEL_BORDER_COLOUR"]                                = "Couleur de contour du panneau"
L["VISTA_BORDER_COLOUR_OF_ADDON_BUTTON_PANELS"]               = "Couleur de contour des boutons d'addons."
L["VISTA_MANAGED_BUTTONS"]                                    = "Boutons gérés"
L["VISTA_BUTTON_COMPLETELY_IGNORED"]                          = "Désactivé : ce bouton est complètement ignoré par cet addon."
L["VISTA_ADDON_BUTTONS_DETECTED"]                             = "(Aucun bouton d'addon détecté)"
L["VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE"]                      = "Boutons visibles (cocher pour inclure)"
L["VISTA_ADDON_BUTTONS_DETECTED_OPEN_YOUR_MINIMAP"]           = "(Aucun bouton d'addon détecté — ouvrez d'abord votre minicarte)"

-- =====================================================================
-- Inline option / module strings (used in OptionsData / modules; symbolic migration)
-- =====================================================================

L["HEROIC_DUNGEON"]                                           = "  Heroic dungeon"
L["HEROIC_RAID"]                                              = "  Heroic raid"
L["LFR"]                                                      = "  LFR"
L["MYTHIC_DUNGEON"]                                           = "  Mythic dungeon"
L["MYTHIC_RAID"]                                              = "  Mythic raid"
L["MYTHIC_PLUS_DUNGEON"]                                      = "  Mythic+ dungeon"
L["NORMAL_DUNGEON"]                                           = "  Normal dungeon"
L["NORMAL_RAID"]                                              = "  Normal raid"
L["ACHIEVEMENT_ICONS"]                                        = "Achievement icons"
L["ACTIVE_INSTANCE"]                                          = "Active instance only"
-- L["ADJUST_FONT_SIZES_AMOUNT"]                              = "Adjust all font sizes by this amount."
-- L["ADJUST_FONTS_SIZES_CASING_DROP_SHADOWS"]                = "Adjust fonts, sizes, casing, and drop shadows."
L["AFFIX_ICONS"]                                              = "Affix icons"
L["AFFIX_TOOLTIPS"]                                           = "Affix tooltips"
-- L["AFFECTS_SCENARIO_PROGRESS_TIMER_BARS"]                  = "Also affects scenario progress and timer bars."
L["ALWAYS"]                                                   = "Always show"
-- L["ALWAYS_M_TIMER"]                                        = "Always show M+ timer."
-- L["AUTO_ADD_WQS_YOUR_CURRENT_ZONE"]                        = "Auto-add WQs in your current zone."
-- L["AUTO_CLOSE_DELAY_DISABLE"]                              = "Auto-close delay (0 to disable)."
-- L["AUTO_UNTRACK_FINISHED_ACTIVITIES"]                      = "Auto-untrack finished activities."
-- L["FOCUS_BAR_UNDER_NUMERIC_OBJECTIVES"]                    = "Bar under numeric objectives (e.g. 3/250)."
L["DASH_CLASS_ICONS_RONDOMEDIA"]                              = "Blizzard default or RondoMedia class icon on the Dashboard when Dashboard class colours are on. Independent of Insight tooltip class icons."
L["BLOCK_POSITION"]                                           = "Block position"
L["BOSS_EMOTES"]                                              = "Boss emotes"
L["CHOICE_SLOTS"]                                             = "Choice slots"
-- L["CHOOSE_WHICH_EVENTS_TRIGGER_SCREEN_ALERTS"]             = "Choose which events trigger on-screen alerts."
-- L["CHOOSE_WHICH_SOUND_PLAY_A_RARE"]                        = "Choose which sound to play when a rare boss appears. Requires LibSharedMedia sounds to be installed for extra options."
-- L["CLICK_BEHAVIOR"]                                        = "Click behavior"
-- L["COLLECT_GROUP_ADDON_MINIMAP_BUTTONS"]                   = "Collect and group addon minimap buttons."
-- L["COLOUR_REMAINING"]                                      = "Colour by remaining time."
L["COLOUR_ZONE_TYPE"]                                         = "Colour by zone type"
-- L["COLOUR_CONTESTED_ZONES_ORANGE_DEFAULT"]                 = "Colour for contested zones (orange by default)."
-- L["COLOUR_FRIENDLY_ZONES_GREEN_DEFAULT"]                   = "Colour for friendly zones (green by default)."
-- L["COLOUR_HOSTILE_ZONES_RED_DEFAULT"]                      = "Colour for hostile zones (red by default)."
-- L["COLOUR_SANCTUARY_ZONES_BLUE_DEFAULT"]                   = "Colour for sanctuary zones (blue by default)."
-- L["COLOUR_OF_DIVIDER_LINES_BETWEEN_SECTIONS"]              = "Colour of the divider lines between sections."
-- L["COLOUR_RECIPE_TITLES_OUTPUT_ITEM_RARITY"]               = "Colour recipe titles by output item rarity."
-- L["COLOUR_ZONE_SUBZONE_TITLES_PVP_ZONE"]                   = "Colour zone/subzone titles by PvP zone type (friendly, hostile, contested, sanctuary). When off, uses the default category colour."
-- L["COMBAT_AFK_DND_PVP_PARTY_FRIENDS"]                      = "Combat, AFK, DND, PvP, party, friends, targeting."
-- L["COMING_SOON"]                                           = "Coming Soon"
L["COMPLETED_BOSS_STYLE"]                                     = "Completed boss style"
L["COMPLETED_COUNT"]                                          = "Completed count"
L["FOCUS_TOMTOM_CONFIGURE_DESC"]                              = "Configure click behaviors, tracking rules, and TomTom integration."
-- L["CONFIGURE_MINIMAP_S_SHAPE_SIZE_POSITION"]               = "Configure the minimap's shape, size, position, and text overlays."
L["CONTESTED_ZONE_COLOUR"]                                    = "Contested zone colour"
-- L["CONTROL_TRACKER_VISIBILITY_WITHIN_DUNGEONS_RAIDS"]      = "Control tracker visibility within dungeons, raids, and PvP."
-- L["SETTINGS_PRESENCE_NOTIFICATION_FRAMEWORK"]              = "Core settings for the Presence notification framework."
L["CRAFTABLE_COUNT"]                                          = "Craftable count"
-- L["CTRL_LEFT_FOCUS_ADD_CTRL_RIGHT"]                        = "Ctrl+Left = focus/add, Ctrl+Right = unfocus/untrack."
L["CURRENT_ZONE_GROUP"]                                       = "Current Zone group"
L["CURRENT_ZONE"]                                             = "Current zone only"
-- L["VISTA_CUSTOMISE_BORDERS_COLOURS_POSITIONING"]           = "Customise borders, colours, and the positioning of specific minimap elements."
-- L["CUSTOMIZE_VISUAL_INTERFACE_LAYOUT_ELEMENTS"]            = "Customise the visual interface and layout elements."
L["DASHBOARD_CLASS_ICON_STYLE"]                               = "Dashboard class icon style"
L["DECOR_ICONS"]                                              = "Decor icons"
-- L["DEDICATED_SECTION_COMPLETED_QUESTS"]                    = "Dedicated section for completed quests."
-- L["DEDICATED_SECTION_ZONE_QUESTS"]                         = "Dedicated section for in-zone quests."
-- L["DEFEATED_BOSS_STYLE"]                                   = "Defeated boss style."
-- L["DESATURATE_FOCUSED_ENTRIES"]                            = "Desaturate non-focused entries."
L["DESATURATE_FOCUSED_QUESTS"]                                = "Desaturate non-focused quests"
L["DIM_ALPHA"]                                                = "Dim alpha"
L["DIM_STRENGTH"]                                             = "Dim strength"
-- L["DIM_UNFOCUSED_TRACKER_ENTRIES"]                         = "Dim unfocused tracker entries."
-- L["DIMMING_STRENGTH"]                                      = "Dimming strength (0-100%)."
-- L["DISPLAY_COMPLETED_OBJECTIVES"]                          = "Display completed objectives."
-- L["ENABLE_BLACKLIST_UNTRACKED_INTERACTIONS_ADD_QUEST"]     = "Enable 'Blacklist untracked' in Interactions to add quests here."
L["ENABLE_M_BLOCK"]                                           = "Enable M+ block"
L["ENEMY_FORCES_COLOUR"]                                      = "Enemy forces colour"
L["ENEMY_FORCES_SIZE"]                                        = "Enemy forces size"
-- L["ENHANCE_PLAYER_ITEM_TOOLTIPS_EXTRA_DETAILS"]            = "Enhance player and item tooltips with extra details like Mythic+ score and transmog status."
L["ENTRY_NUMBERS"]                                            = "Entry numbers"
L["ENTRY_SPACING"]                                            = "Entry spacing"
-- L["EXPAND_DIRECTION_ANCHOR"]                               = "Expand direction from anchor."
-- L["FADE_HOVERING"]                                         = "Fade out when not hovering."
L["FOCUS_FINISHING_REAGENTS"]                                 = "Finishing reagents"
-- L["FOCUS_ANIMATIONS"]                                      = "Focus animations"
-- L["FONT_SIZE_BAR_LABEL_BAR_HEIGHT"]                        = "Font size for bar label and bar height."
-- L["FONTS_SIZES_COLOURS_PRESENCE_NOTIFICATIONS"]            = "Fonts, sizes, and colours for Presence notifications."
-- L["WORLD_QUESTS_WEEKLIES_YOUR_QUEST_LOG"]                  = "For world quests and weeklies not in your quest log."
L["FRIENDLY_ZONE_COLOUR"]                                     = "Friendly zone colour"
-- L["GROUPING"]                                              = "Grouping"
-- L["GROUPS_SELECTED_LAYOUT_MODE_BELOW"]                     = "Groups them by the selected layout mode below."
L["GUILD_RANK"]                                               = "Guild rank"
L["HEADER_DIVIDER"]                                           = "Header divider"
-- L["HIDE_UNTRACKED_QUESTS_UNTIL_RELOAD"]                    = "Hide untracked quests until reload."
-- L["HIDE_ZONE_NOTIFICATIONS_MYTHIC"]                        = "Hide zone notifications in Mythic+."
-- L["HIDES_CATEGORIES_WHILE_A_DELVE_PARTY"]                  = "Hides other categories while in a Delve or party dungeon."
-- L["HINT_LIST_SCROLLABLE"]                                  = "Hint when the list is scrollable."
L["HONOR_LEVEL"]                                              = "Honor level"
L["HOSTILE_ZONE_COLOUR"]                                      = "Hostile zone colour"
-- L["FOCUS_DIM_UNFOCUSED_ENTRIES_DESC"]                      = "How much to dim non-focused entries (0 = no dimming, 100 = fully darkened). Default 40%."
-- L["ICON_NEXT_ACHIEVEMENT_TITLE"]                           = "Icon next to achievement title."
-- L["ICON_NEXT_AUTO_TRACKED_ZONE_ENTRIES"]                   = "Icon next to auto-tracked in-zone entries."
L["ARENA"]                                                    = "In arena"
L["BATTLEGROUND"]                                             = "In battleground"
L["DUNGEON"]                                                  = "In dungeon"
L["RAID"]                                                     = "In raid"
L["ZONE_WORLD_QUESTS"]                                        = "In-zone world quests"
L["INCLUDE_COMPLETED"]                                        = "Include completed"
L["INSTANCE_SUPPRESSION"]                                     = "Instance suppression"
L["ITEM_LEVEL"]                                               = "Item level"
L["ITEM_SOURCE"]                                              = "Item source"
-- L["KEEP_BAR_VISIBLE_REPOSITIONING"]                        = "Keep bar visible for repositioning."
L["KEEP_CAMPAIGN_CATEGORY"]                                   = "Keep campaign in category"
-- L["KEEP_HEADER_BOTTOM_TOP_UNTIL_COLLAPSED"]                = "Keep header at bottom, or top until collapsed."
L["KEEP_IMPORTANT_CATEGORY"]                                  = "Keep important in category"
-- L["KEEP_CAMPAIGN_READY_TURN"]                              = "Keep in Campaign when ready to turn in."
-- L["KEEP_IMPORTANT_READY_TURN"]                             = "Keep in Important when ready to turn in."
-- L["KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED"]                = "Keep section headers visible when collapsed."
-- L["L_CLICK_OPENS_MAP_R_CLICK"]                             = "L-click opens map, R-click opens menu."
L["PRESENCE_LEVEL_UP_TOGGLE"]                                 = "Level up"
L["LOCK_DRAWER_BUTTON"]                                       = "Lock drawer button"
L["LOCK_ITEM_POSITION"]                                       = "Lock item position"
L["LOCK_MINIMAP"]                                             = "Lock minimap"
L["LOCK_MOUSEOVER_BAR"]                                       = "Lock mouseover bar"
L["LOCK_RIGHT_CLICK_PANEL"]                                   = "Lock right-click panel"
L["MAIL_ICON_PULSE"]                                          = "Mail icon pulse"
-- L["MAKE_FOCUSED_ENTRIES_GREYSCALE_PARTIALLY_DESATURATE"]   = "Make non-focused entries greyscale/partially desaturated in addition to dimming."
L["MANAGE_ADDON_BUTTONS"]                                     = "Manage addon buttons"
-- L["VISTA_ICON_MANAGEMENT"]                                 = "Manage and organise minimap icons from other addons into a tidy drawer or bar."
-- L["MANAGE_SWITCH_BETWEEN_YOUR_ADDON_CONFIGURATIONS"]       = "Manage and switch between your addon configurations."
-- L["MATCH_BAR_QUEST_CATEGORY_COLOUR"]                       = "Match bar to quest category colour."
-- L["APPEAR_FULL_TRACKER_REPLACEMENTS"]                      = "May not appear with full tracker replacements."
L["MINIMAL_MODE"]                                             = "Minimal mode"
L["MISSING_CRITERIA"]                                         = "Missing criteria only"
L["MOUNT_INFO"]                                               = "Mount info"
-- L["MOUNT_NAME_SOURCE_COLLECTION_STATUS"]                   = "Mount name, source, and collection status."
L["MOUSEOVER_CLOSE_DELAY"]                                    = "Mouseover close delay"
L["MOUSEOVER"]                                                = "Mouseover only"
-- L["MOVE_COMPLETED_QUESTS_BOTTOM_OF_CURRENT"]               = "Move completed quests to the bottom of the Current Zone section."
-- L["MYTHIC_BLOCK"]                                          = "Mythic+ Block"
-- L["MYTHIC_COLOURS"]                                        = "Mythic+ Colours"
L["MYTHIC_SCORE"]                                             = "Mythic+ score"
-- L["DEFAULT"]                                               = "New from Default"
-- L["HIDDEN_QUESTS"]                                         = "No hidden quests."
-- L["NOTIFY_ACHIEVEMENT_CRITERIA_UPDATE"]                    = "Notify on achievement criteria update."
L["OBJECTIVE_PROGRESS"]                                       = "Objective progress"
L["OBJECTIVE_SPACING"]                                        = "Objective spacing"
-- L["L_CLICK_FOCUSES_R_CLICK_UNTRACKS"]                      = "Off: L-click focuses, R-click untracks. Ctrl+Right shares."
-- L["PROGRESS_TRACKED_ACHIEVEMENTS_SHOWN"]                   = "Off: only in-progress tracked achievements shown."
-- L["TRACKED_NEARBY_WQS_APPEAR_BLIZZARD_DEFAULT"]            = "Off: only tracked or nearby WQs appear (Blizzard default)."
-- L["BOSS_EMOTES_ACHIEVEMENTS_LEVEL_HIDES_ZONE"]             = "Only boss emotes, achievements, and level-up. Hides zone, quest, and scenario notifications in Mythic+."
-- L["ENTRIES_A_SINGLE_NUMERIC_OBJECTIVE_WHERE"]              = "Only for entries with a single numeric objective where required > 1."
-- L["QUESTS_DON_T_NEED_NPC_TURN"]                            = "Only for quests that don't need NPC turn-in. Off = Blizzard default."
-- L["INCOMPLETE_CRITERIA"]                                   = "Only show incomplete criteria."
-- L["SUBZONE_NAME_WITHIN_SAME_ZONE"]                         = "Only show subzone name within same zone."
-- L["OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]                    = "Opacity of focused quest highlight (0–100%)."
-- L["OPACITY_OF_UNFOCUSED_ENTRIES"]                          = "Opacity of unfocused entries."
L["FOCUS_OPTIONAL_REAGENTS"]                                  = "Optional reagents"
L["FOCUS_RECIPE_REAGENTS_FULL_DETAIL"]                        = "Full reagent detail"
-- L["FOCUS_RECIPE_REAGENTS_FULL_DETAIL_DESC"]                = "List every schematic slot: optional and finishing sections, choice groups with all variants, and non-Basic reagents. When off, only Basic slots use the first reagent per slot (compact shopping-style list)."
-- L["ORGANIZE_HIDE_TRACKED_ENTRIES_YOUR_PREFERENCE"]         = "Organise and hide tracked entries to your preference."
-- L["OVERRIDE_FONT_PER_ELEMENT"]                             = "Override font per element."
-- L["PANEL_BACKGROUND_OPACITY"]                              = "Panel background opacity (0–100%)."
-- L["PERMANENTLY_HIDE_UNTRACKED_QUESTS"]                     = "Permanently hide untracked quests."
-- L["PERSONALIZE_COLOUR_PALETTE_TRACKER_TEXT_ELEMENTS"]      = "Personalize the colour palette for tracker text elements."
-- L["POSITIONING_VISIBILITY_CACHE_LOOT_TOAST_SYS"]           = "Positioning and visibility for the Cache loot toast system."
-- L["PREVENT_ACCIDENTAL_CLICKS"]                             = "Prevent accidental clicks."
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
-- L["FOCUS_QUEST_TYPE_ICON_SIZE_DESC"]                       = "Pixel size of the quest type icon shown in the left gutter (default 16)."
-- L["PRESENCE_RARE_DEFEATED"]                                = "RARE DEFEATED"
L["RARE_ADDED_SOUND_CHOICE"]                                  = "Rare added sound choice"
L["RARE_SOUND_ALERT"]                                         = "Rare sound alert"
L["RARITY_COLOURS"]                                           = "Rarity colours"
L["READY_TURN_GROUP"]                                         = "Ready to Turn In group"
L["READY_TURN_BOTTOM"]                                        = "Ready to turn in at bottom"
-- L["REAGENTS"]                                              = "Reagents"
L["RECIPE_ICONS"]                                             = "Recipe icons"
-- L["RECIPES"]                                               = "Recipes"
-- L["REDUCE_OPACITY_OF_FOCUSED_ENTRIES_INVISIBLE"]           = "Reduce opacity of non-focused entries (0 = invisible, 100 = fully opaque). Default 100% (no alpha change)."
-- L["REQUIRE_CTRL_COMPLETE_CLICK_COMPLETABLE_QUESTS"]        = "Require Ctrl to complete click-completable quests."
-- L["REQUIREMENTS"]                                          = "Requirements"
-- L["REQUIRES_QUEST_TYPE_ICONS_ENABLED_DISPLAY"]             = "Requires quest type icons to be enabled in Display."
L["RESET_MYTHIC_STYLING"]                                     = "Reset Mythic+ styling"
-- L["REVIEW_MANAGE_QUESTS_YOU_MANUALLY_UNTRACKED"]           = "Review and manage quests you have manually untracked or blacklisted."
L["RIGHT_CLICK_CLOSE_DELAY"]                                  = "Right-click close delay"
L["SANCTUARY_ZONE_COLOUR"]                                    = "Sanctuary zone colour"
-- L["SCALE_UI_ELEMENTS"]                                     = "Scale all UI elements (50–200%)."
-- L["PRESENCE_SCENARIO_COMPLETE"]                            = "Scenario Complete"
L["SCENARIO_EVENTS"]                                          = "Scenario events"
L["SCENARIO_PROGRESS"]                                        = "Scenario progress"
L["SCENARIO_PROGRESS_BAR"]                                    = "Scenario progress bar"
L["SCENARIO_START"]                                           = "Scenario start"
L["SCENARIO_TIMER_BAR"]                                       = "Scenario timer bar"
L["SCROLL_INDICATOR"]                                         = "Scroll indicator"
-- L["SECONDS_OF_RECENT_PROGRESS"]                            = "Seconds of recent progress to show."
L["SECTION_DIVIDER_COLOUR"]                                   = "Section divider colour"
L["SECTION_HEADERS"]                                          = "Section headers"
L["SECTIONS_COLLAPSED"]                                       = "Sections when collapsed"
-- L["SEPARATE_SCALE_SLIDER_PER_MODULE"]                      = "Separate scale slider per module."
-- L["SHADOW_OPACITY"]                                        = "Shadow opacity (0–100%)."
-- L["A_VISUAL_DIVIDER_LINE_BETWEEN_FOCUS"]                   = "Show a visual divider line between Focus sections to make categories easier to distinguish."
-- L["AFFIX_NAMES_FIRST_DELVE_ENTRY"]                         = "Show affix names on first Delve entry."
-- L["COLLAPSIBLE_CHOICE_REAGENT_SLOTS"]                      = "Show collapsible choice reagent slots."
-- L["COMPLETED_ACHIEVEMENTS_LIST"]                           = "Show completed achievements in the list."
-- L["FINISHING_REAGENT_SLOTS"]                               = "Show finishing reagent slots."
-- L["MANY_TIMES_RECIPE_CRAFTED"]                             = "Show how many times the recipe can be crafted."
-- L["NORMAL_DUNGEONS"]                                       = "Show in Normal dungeons."
-- L["LOCAL_SYSTEM"]                                          = "Show local system time."
-- L["NOTIFICATION_A_RARE_MOB_DEFEATED_NEARBY"]               = "Show notification when a rare mob is defeated nearby."
-- L["NOTIFICATION_A_SCENARIO_DELVE_FULLY_COM"]               = "Show notification when a scenario or Delve is fully completed."
-- L["OBJECTIVE_LINE"]                                        = "Show objective line only."
-- L["HOVER"]                                                 = "Show only on hover."
-- L["ACTIVE_INSTANCE_SECTION"]                               = "Show only the active instance section."
-- L["OPTIONAL_REAGENT_SLOTS"]                                = "Show optional reagent slots."
-- L["RECIPES_TIER_QUALITY_PIPS"]                             = "Show quality tier pips for recipes that support qualities."
-- L["REAGENT_SHOPPING_LIST_RECIPE"]                          = "Show reagent shopping list for each recipe."
-- L["FOCUS_AH_SEARCH_TITLE"]                                 = "Search Auction House"
L["FOCUS_AH_SEARCH_TOOLTIP"]                                  = "Left-click: search for one craft worth of reagents.\nRight-click: enter how many crafts to multiply quantities.\nThe Auction House must be open."
-- L["FOCUS_AUCTIONATOR_SEARCH"]                              = "Auctionator search button"
-- L["FOCUS_AUCTIONATOR_SEARCH_DESC"]                         = "Show a button on recipe entries to search for required reagents in the Auction House (requires Auctionator)."
-- L["FOCUS_AH_CRAFT_DIALOG_SUBTITLE"]                        = "Auction House shopping list"
-- L["FOCUS_AH_CRAFT_HINT_CRAFT_COUNT"]                       = "Number of crafts to buy materials for (1–999). List quantities are multiplied by this."
L["FOCUS_AH_CRAFT_HINT_TIER"]                                 = "Crafting tier 1, 2, or 3 for every Auctionator row, or leave empty to use each item’s tier."
-- L["FOCUS_AH_CRAFT_TIER_ANY"]                               = "Any tier"
-- L["FOCUS_AH_CRAFT_TIER_N"]                                 = "Tier %d"
-- L["FOCUS_AH_CRAFT_COUNT_INVALID"]                          = "Enter a whole number from 1 to 999."
-- L["RECENT_PROGRESS_TOP"]                                   = "Show recent progress at the top."
-- L["RECIPE_ICON_NEXT_TITLE_REQUIRES_QUEST"]                 = "Show recipe icon next to title. Requires quest type icons in Display."
L["SECTION_DIVIDERS"]                                         = "Show section dividers"
-- L["M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]                   = "Show the M+ block whenever an active keystone is running."
-- L["TRACKED_PROFESSION_RECIPES_LIST"]                       = "Show tracked profession recipes in the list."
-- L["TRACKER_HEROIC_DUNGEONS"]                               = "Show tracker in Heroic dungeons. When unset, uses the master dungeon toggle."
-- L["TRACKER_HEROIC_RAIDS"]                                  = "Show tracker in Heroic raids. When unset, uses the master raid toggle."
-- L["TRACKER_LFR_RAID"]                                      = "Show tracker in Looking for Raid. When unset, uses the master raid toggle."
-- L["TRACKER_MYTHIC_KEYSTONES"]                              = "Show tracker in Mythic Keystone (M+) dungeons. When unset, uses the master dungeon toggle."
-- L["TRACKER_MYTHIC_DUNGEONS"]                               = "Show tracker in Mythic dungeons. When unset, uses the master dungeon toggle."
-- L["TRACKER_MYTHIC_RAIDS"]                                  = "Show tracker in Mythic raids. When unset, uses the master raid toggle."
-- L["TRACKER_NORMAL_DUNGEONS"]                               = "Show tracker in Normal dungeons. When unset, uses the master dungeon toggle."
-- L["TRACKER_NORMAL_RAIDS"]                                  = "Show tracker in Normal raids. When unset, uses the master raid toggle."
-- L["TRACKER_PARTY_DUNGEONS"]                                = "Show tracker in party dungeons (master toggle for all dungeon difficulties)."
-- L["TRACKER_RAIDS_ALL"]                                     = "Show tracker in raids (master toggle for all raid difficulties)."
-- L["UNMET_CRAFTING_STATION_REQUIREMENTS"]                   = "Show unmet crafting station requirements."
-- L["SHOWN_HOVERING_A_MOUNTED_PLAYER"]                       = "Shown when hovering a mounted player."
L["SIZE_SHAPE"]                                               = "Size & shape"
-- L["SIZE_OF_ZOOM_BUTTONS_PIXELS"]                           = "Size of the + and - zoom buttons (pixels)."
L["SORT_MODE"]                                                = "Sort mode"
-- L["SORTING_FILTERING"]                                     = "Sorting & Filtering"
-- L["SOUND_PLAYED_A_RARE_BOSS_APPEARS"]                      = "Sound played when a rare boss appears."
L["STATUS_BADGES"]                                            = "Status badges"
L["SUBZONE_CHANGES"]                                          = "Subzone changes"
-- L["SUPER_TRACKED_FIRST_CURRENT_ZONE_FIRST"]                = "Super-tracked first, or current zone first."
-- L["SUPPRESS_IN_ARENA_DETAIL"]                              = "Suppress all Presence notifications while inside a PvP arena."
-- L["SUPPRESS_PRESENCE_NOTIFICATIONS_WHILE_INSIDE_A"]        = "Suppress all Presence notifications while inside a battleground."
-- L["SUPPRESS_IN_DUNGEON_DETAIL"]                            = "Suppress all Presence notifications while inside a dungeon (except boss emotes, achievements, level-up)."
-- L["SUPPRESS_IN_RAID_DETAIL"]                               = "Suppress all Presence notifications while inside a raid."
-- L["SUPPRESS_M"]                                            = "Suppress in M+"
-- L["SUPPRESS_PVP"]                                          = "Suppress in PvP"
L["SUPPRESS_BATTLEGROUND"]                                    = "Suppress in battleground"
L["SUPPRESS_DUNGEON"]                                         = "Suppress in dungeon"
L["SUPPRESS_RAID"]                                            = "Suppress in raid"
-- L["SUPPRESS_NOTIFICATIONS_DUNGEONS"]                       = "Suppress notifications in dungeons."
-- L["TAKES_PRIORITY_SUPPRESS_UNTIL_RELOAD_ACCEPTING"]        = "Takes priority over suppress-until-reload. Accepting removes from blacklist."
L["TOAST_ICONS"]                                              = "Toast icons"
-- L["TOGGLE_TRACKING_WORLD_QUESTS_RARES_ACHIEVEMENTS"]       = "Toggle tracking for world quests, rares, achievements, and more."
L["TOOLTIP_ANCHOR"]                                           = "Tooltip anchor"
-- L["TRACKED_OBJECTIVES_ADVENTURE_GUIDE"]                    = "Tracked objectives from Adventure Guide."
-- L["TRACKED_VS_LOG_COUNT"]                                  = "Tracked vs in-log count."
-- L["TRACKED_LOG_LOG_MAX_TRACKED_EXCLUDES"]                  = "Tracked/in-log or in-log/max. Tracked excludes world and in-zone quests."
L["TRANSMOG_STATUS"]                                          = "Transmog status"
-- L["TRAVELERS_LOG"]                                         = "Traveler's Log"
-- L["TUNE_SLIDE_FADE_EFFECTS_PLUS_OBJECTIVE"]                = "Tune slide and fade effects, plus objective progress flashes."
-- L["UNBLOCK"]                                               = "Unblock"
L["UNTRACK_COMPLETE"]                                         = "Untrack when complete"
-- L["CHECKMARK_COMPLETED_OBJECTIVES"]                        = "Use checkmark for completed objectives."
L["VISIBILITY_FADING"]                                        = "Visibility & fading"
-- L["COMPLETED_QUESTS_STAY_THEIR_ORIGINAL_CATEGO"]           = "When off, completed quests stay in their original category."
-- L["ZONE_QUESTS_APPEAR_THEIR_NORMAL_CATEGORY"]              = "When off, in-zone quests appear in their normal category."
-- L["THEY_MOVE_COMPLETE_SECTION"]                            = "When off, they move to the Complete section."
-- L["CUSTOM_FILL_COLOUR_BELOW"]                              = "When off, uses the custom fill colour below."
-- L["COMPLETED_OBJECTIVES_COLOUR_BELOW"]                     = "When on, completed objectives use the colour below."
-- L["WHERE_COUNTDOWN"]                                       = "Where to show the countdown."
L["WORLD_QUEST_ACCEPT"]                                       = "World quest accept"
L["WORLD_QUEST_COMPLETE"]                                     = "World quest complete"
-- L["X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]                = "X/Y: objectives like 3/10. Percent: objectives like 45%."
L["ZONE_ENTRY"]                                               = "Zone entry"
L["ZONE_LABELS"]                                              = "Zone labels"
-- L["ZONE_NAME_NEW_ZONE"]                                    = "Zone name still appears when entering a new zone."
L["ZONE_TYPE_COLOURING"]                                      = "Zone type colouring"
-- L["FOCUS_COMPLETED_CHECKMARK"]                             = "|TInterface\\\\Buttons\\\\UI-CheckBox-Check:12:12:0:0|t instead of green for done objectives."






























































































































































