if GetLocale() ~= "esES" then return end

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
L["OTHER"]                                                    = "Otro"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["QUEST_TYPES"]                                              = "Tipos de misiones"
L["ELEMENT_OVERRIDES"]                                        = "Colores por elemento"
L["PER_CATEGORY"]                                             = "Colores por categoría"
L["GROUPING_OVERRIDES"]                                       = "Colores personalizados"
-- L["SECTION_OVERRIDES"]                                     = "Section Overrides"
L["OTHER_COLOURS"]                                            = "Otros colores"

-- =====================================================================
-- OptionsPanel.lua — Colour row labels (collapsible group sub-rows)
-- =====================================================================
L["FOCUS_SECTION"]                                            = "Sección"
L["FOCUS_TITLE"]                                              = "Título"
L["FOCUS_ZONE"]                                               = "Zona"
L["FOCUS_OBJECTIVE"]                                          = "Objetivo"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["FOCUS_READY_TURN_OVERRIDES_BASE_COLOURS"]                  = "Usar colores distintos para la sección Listas para entregar"
L["FOCUS_READY_TURN_COLOURS_QUESTS"]                          = "La sección Listas para entregar usará sus propios colores."
L["FOCUS_CURRENT_ZONE_OVERRIDES_BASE_COLOURS"]                = "Usar colores distintos para la sección Zona actual"
L["FOCUS_CURRENT_ZONE_SECTION_COLOURS"]                       = "La sección Zona actual usará sus propios colores."
L["FOCUS_CURRENT_QUEST_OVERRIDES_BASE_COLOURS"]               = "Usar colores distintos para la sección Misión actual"
L["FOCUS_CURRENT_QUEST_SECTION_COLOURS"]                      = "La sección Misión actual usará sus propios colores."
L["FOCUS_DISTINCT_COLOUR_COMPLETED_OBJECTIVES"]               = "Usar colour distinto para objetivos completados"
L["FOCUS_COMPLETED_OBJECTIVES_COLOURS_CHANGE"]                = "Activado: los objetivos completados (ej. 1/1) usan el colour de abajo. Desactivado: usan el mismo colour que los incompletos."
L["FOCUS_COMPLETED_OBJECTIVE"]                                = "Objetivo completado"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["FOCUS_RESET"]                                              = "Restablecer"
L["FOCUS_RESET_QUEST_TYPES"]                                  = "Restablecer tipos de misiones"
L["FOCUS_RESET_OVERRIDES"]                                    = "Restablecer colores personalizados"
L["FOCUS_RESET_DEFAULTS"]                                     = "Restablecer todo a valores por defecto"
L["FOCUS_RESET_TO_DEFAULTS"]                                  = "Restablecer valores por defecto"
L["FOCUS_RESET_DEFAULT"]                                      = "Restablecer valor por defecto"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["FOCUS_SEARCH_SETTINGS"]                                    = "Buscar opciones..."
L["SEARCH_FONTS"]                                             = "Buscar fuentes..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["FOCUS_DRAG_RESIZE"]                                        = "Arrastra para redimensionar"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
-- L["PROFILES"]                                              = "Profiles"
L["MODULES"]                                                  = "Módulos"
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
L["DASH_LAYOUT"]                                              = "Diseño"
L["DASH_VISIBILITY"]                                          = "Visibilidad"
L["DASH_DISPLAY"]                                             = "Visualización"
L["DASH_FEATURES"]                                            = "Características"
L["DASH_TYPOGRAPHY"]                                          = "Tipografía"
L["DASH_APPEARANCE"]                                          = "Apariencia"
-- L["DASH_CLICK_OPTIONS"]                                    = "Click Options"
L["DASH_COLOURS"]                                             = "Colores"
L["DASH_ORGANISATION"]                                        = "Organización"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["FOCUS_PANEL_BEHAVIOUR"]                                    = "Comportamiento del panel"
L["FOCUS_DIMENSIONS"]                                         = "Dimensiones"
L["FOCUS_INSTANCE"]                                           = "Instancia"
-- L["FOCUS_INSTANCES"]                                       = "Instances"
L["FOCUS_COMBAT"]                                             = "Combate"
L["FOCUS_FILTERING"]                                          = "Filtros"
L["FOCUS_HEADER"]                                             = "Encabezado"
L["FOCUS_SECTIONS_STRUCTURE"]                                 = "Sections & structure"
L["FOCUS_ENTRY_DETAILS"]                                      = "Entry details"
L["FOCUS_PROGRESS_TIMERS"]                                    = "Progress & timers"
L["FOCUS_EMPHASIS"]                                           = "Focus emphasis"
L["FOCUS_LIST"]                                               = "Lista"
L["FOCUS_SPACING"]                                            = "Espaciado"
L["FOCUS_RARE_BOSSES"]                                        = "Jefes raros"
L["FOCUS_WORLD_QUESTS"]                                       = "Misiones de mundo"
L["FOCUS_FLOATING_QUEST_ITEM"]                                = "Objeto de misión flotante"
L["FOCUS_MYTHIC"]                                             = "Mítico+"
L["FOCUS_ACHIEVEMENTS"]                                       = "Logros"
L["FOCUS_ACHIEVEMENT_PROGRESS_BARS"]                          = "Achievement progress bars"
-- L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_DESC"]                  = "Show a progress bar under tracked achievements that report numeric criteria (including 0/1 and X/Y). Independent of Quest Progress Bars."
-- L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_TIP"]                   = "Uses the same bar colours, texture, and font as other Focus progress bars when those options are visible."
L["FOCUS_ENDEAVORS"]                                          = "Empeños"
L["FOCUS_DECOR"]                                              = "Decoración"
-- L["FOCUS_APPEARANCES"]                                     = "Appearances"
L["FOCUS_SCENARIO_DELVE"]                                     = "Escenario y Sima"
L["FOCUS_FONT"]                                               = "Fuente"
L["FOCUS_FONT_FAMILIES"]                                      = "Font families"
L["FOCUS_GLOBAL_FONT_SIZE"]                                   = "Global font size"
L["FOCUS_FONT_SIZES"]                                         = "Font sizes"
L["FOCUS_PER_ELEMENT_FONTS"]                                  = "Per-element fonts"
L["FOCUS_TEXT_CASE"]                                          = "Mayúsculas/minúsculas"
L["FOCUS_SHADOW"]                                             = "Sombra"
-- L["FOCUS_PANEL"]                                           = "Panel"
L["FOCUS_HIGHLIGHT"]                                          = "Resaltado"
L["FOCUS_COLOUR_MATRIX"]                                      = "Matriz de colores"
L["FOCUS_ORDER"]                                              = "Orden"
L["FOCUS_SORT"]                                               = "Ordenar"
L["FOCUS_BEHAVIOUR"]                                          = "Comportamiento"
L["FOCUS_CONTENT_TYPES"]                                      = "Tipos de contenido"
L["FOCUS_DELVES"]                                             = "Simas"
L["FOCUS_DELVES_DUNGEONS"]                                    = "Simas y Mazmorras"
L["FOCUS_DELVE_COMPLETE"]                                     = "Sima completada"
L["FOCUS_INTERACTIONS"]                                       = "Interacciones"
-- L["FOCUS_LAYOUT_TAB_DESC"]                                 = "Configure and customise settings related to layout."
-- L["FOCUS_APPEARANCE_TAB_DESC"]                             = "Tracker panel look, fading, and list layout (header, sections, entries, timers, emphasis)."
-- L["FOCUS_CLICK_OPTIONS_TAB_DESC"]                          = "Click profile, per-combo actions, and optional safety toggles for the tracker."
-- L["FOCUS_INTERACTIONS_TAB_DESC"]                           = "Configure quest tracking rules and TomTom integration."
L["FOCUS_TRACKING"]                                           = "Seguimiento"
L["FOCUS_SCENARIO_BAR"]                                       = "Barra de escenario"

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
L["AXIS_ENABLE_FOCUS_MODULE"]                                 = "Activar módulo Enfoque"
L["AXIS_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS_R"]             = "Muestra el rastreador de objetivos para misiones, misiones de mundo, raros, logros y escenarios."
L["AXIS_ENABLE_PRESENCE_MODULE"]                              = "Activar módulo Presencia"
L["AXIS_CINEMATIC_ZONE_TEXT_NOTIFICATIONS_ZONE_CHANGES"]      = "Texto de zona cinematográfico y notificaciones (cambios de zona, subida de nivel, emotes de jefes, logros, actualizaciones de misiones)."
L["AXIS_ENABLE_CACHE_MODULE"]                                 = "Activar módulo Cache"
L["AXIS_CINEMATIC_LOOT_NOTIFICATIONS_ITEMS_MONEY_CURRENCY"]   = "Notificaciones cinematográficas de botín (objetos, oro, monedas, reputación)."
L["AXIS_ENABLE_VISTA_MODULE"]                                 = "Activar módulo Vista"
L["AXIS_CINEMATIC_SQUARE_MINIMAP_ZONE_TEXT_COORDINATES"]      = "Minimapa cuadrado cinematográfico con texto de zona, coordenadas y recopilador de botones."
-- L["AXIS_MINIMAP_ZONE_TIME_COLLECTOR"]                      = "Cinematic square minimap with zone text, coordinates, time, and button collector."
-- L["AXIS_BETA"]                                             = "Beta"
L["AXIS_SCALING"]                                             = "Escala"
L["AXIS_GLOBAL_TOGGLES"]                                      = "Global Toggles"
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
-- L["AXIS_SUITE_WIDE_CLASS_COLOUR_TINTING_UI"]               = "Dashboard background theme, class colour tinting, and UI scale (global or per module)."
L["AXIS_GLOBAL_UI_SCALE"]                                     = "Escala global de la interfaz"
L["AXIS_SCALE_SIZES_SPACINGS_FONTS_FACTOR"]                   = "Escala todos los tamaños, espaciados y fuentes por este factor (50–200%). No cambia tus valores configurados."
L["AXIS_PER_MODULE_SCALING"]                                  = "Escala por módulo"
L["AXIS_OVERRIDE_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_FO"]         = "Reemplaza la escala global con controles deslizantes individuales para cada módulo."
-- L["AXIS_OVERRIDES_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_F"]      = "Overrides the global scale with individual sliders for Focus, Presence, Vista, etc."
-- L["AXIS_DOESN_T_CHANGE_YOUR_CONFIGURED_VALUES"]            = "Doesn't change your configured values, only the effective display scale."
L["FOCUS_SCALE"]                                              = "Escala Enfoque"
L["AXIS_SCALE_FOCUS_OBJECTIVE_TRACKER"]                       = "Escala del rastreador de objetivos Enfoque (50–200%)."
L["PRESENCE_SCALE"]                                           = "Escala Presencia"
L["AXIS_SCALE_PRESENCE_CINEMATIC_TEXT"]                       = "Escala del texto cinematográfico Presencia (50–200%)."
L["VISTA_SCALE"]                                              = "Escala Vista"
L["AXIS_SCALE_VISTA_MINIMAP_MODULE"]                          = "Escala del módulo minimapa Vista (50–200%)."
L["INSIGHT_SCALE"]                                            = "Escala Insight"
L["AXIS_SCALE_INSIGHT_TOOLTIP_MODULE"]                        = "Escala del módulo de descripción Insight (50–200%)."
L["CACHE_SCALE"]                                              = "Escala Cache"
L["AXIS_SCALE_CACHE_LOOT_TOAST_MODULE"]                       = "Escala del módulo de notificaciones de botín Cache (50–200%)."
-- L["CACHE_FONT"]                                            = "Loot toast font"
-- L["CACHE_FONT_FAMILY"]                                     = "Font family used for loot toast text. Use 'Use global font' to follow the addon-wide font."
L["AXIS_ENABLE_HORIZON_INSIGHT_MODULE"]                       = "Activar módulo Horizon Insight"
L["AXIS_CINEMATIC_TOOLTIPS_CLASS_COLOURS_SPEC_DISPLAY"]       = "Descripciones cinematográficas con colores de clase, especialización e iconos de facción."
L["AXIS_TOOLTIP_ANCHOR_MODE"]                                 = "Modo de anclaje de descripciones"
L["AXIS_WHERE_TOOLTIPS_APPEAR_FOLLOW_CURSOR_FIXED"]           = "Dónde aparecen las descripciones: seguir cursor o posición fija."
-- L["AXIS_CURSOR"]                                           = "Cursor"
L["AXIS_FIXED"]                                               = "Fijo"
L["INSIGHT_CURSOR_SIDE"]                                      = "Cursor side"
-- L["INSIGHT_CURSOR_SIDE_DESC"]                              = "Which side of the cursor the tooltip appears on."
-- L["INSIGHT_CURSOR_SIDE_CENTER"]                            = "Center"
-- L["INSIGHT_CURSOR_SIDE_LEFT"]                              = "Left"
-- L["INSIGHT_CURSOR_SIDE_RIGHT"]                             = "Right"
L["AXIS_ANCHOR_MOVE"]                                         = "Mostrar ancla para mover"
-- L["AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITION"]                  = "Click to show or hide the anchor. Drag to set position, right-click to confirm."
L["AXIS_DRAGGABLE_FRAME_FIXED_TOOLTIP_POSITION_DESC"]         = "Muestra un marco arrastrable para definir la posición fija. Arrastra y haz clic derecho para confirmar."
L["AXIS_RESET_TOOLTIP_POSITION"]                              = "Restablecer posición de descripciones"
L["AXIS_RESET_FIXED_POSITION_DEFAULT"]                        = "Restablecer posición fija al valor por defecto."
L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED"]                           = "Dynamic position for Focus tooltips"
-- L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED_DESC"]                   = "When fixed anchor is on, Focus tracker tooltips still attach to the outer edge of the Horizon panel so they never cover the tracker."
L["INSIGHT_CURSOR_OFFSET_X"]                                  = "Cursor offset X"
L["INSIGHT_CURSOR_OFFSET_X_DESC"]                             = "Horizontal pixel offset from the default cursor tooltip position (cursor anchor only)."
L["INSIGHT_CURSOR_OFFSET_Y"]                                  = "Cursor offset Y"
L["INSIGHT_CURSOR_OFFSET_Y_DESC"]                             = "Vertical pixel offset from the default cursor tooltip position (cursor anchor only)."
L["AXIS_TOOLTIP_BACKGROUND_COLOUR"]                           = "Colour de fondo de descripciones"
L["AXIS_COLOUR_OF_TOOLTIP_BACKGROUND"]                        = "Colour de fondo de las descripciones."
L["AXIS_TOOLTIP_BACKGROUND_OPACITY"]                          = "Opacidad del fondo de descripciones"
L["AXIS_TOOLTIP_BG_OPACITY_PCT_DESC"]                         = "Opacidad del fondo de descripciones (0–100%)."
L["AXIS_TOOLTIP_FONT"]                                        = "Fuente de descripciones"
L["AXIS_FONT_FAMILY_TOOLTIP_TEXT"]                            = "Familia de fuentes usada para todo el texto de descripciones."
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
-- L["AXIS_TOOLTIPS"]                                         = "Tooltips"
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
-- L["AXIS_ITEM_TOOLTIP"]                                     = "Item Tooltip"
-- L["AXIS_TRANSMOG_STATUS"]                                  = "Show transmog status"
-- L["AXIS_WHETHER_YOU_COLLECTED_APPEARANCE_OF_AN"]           = "Show whether you have collected the appearance of an item you hover over."
-- L["AXIS_PLAYER_TOOLTIP"]                                   = "Player Tooltip"
-- L["AXIS_GUILD_RANK"]                                       = "Show guild rank"
-- L["AXIS_APPEND_PLAYER_S_GUILD_RANK_NEXT"]                  = "Append the player's guild rank next to their guild name."
-- L["AXIS_MYTHIC_SCORE"]                                     = "Show Mythic+ score"
-- L["AXIS_PLAYER_S_CURRENT_SEASON_MYTHIC_SCORE"]             = "Show the player's current season Mythic+ score, colour-coded by tier."
-- L["AXIS_ITEM_LEVEL"]                                       = "Show item level"
-- L["AXIS_PLAYER_S_EQUIPPED_ITEM_LEVEL_AFTER"]               = "Show the player's equipped item level after inspecting them."
L["AXIS_HONOR_LEVEL"]                                         = "Show honor level"
L["AXIS_PLAYER_S_PVP_HONOR_LEVEL_TOOLTIP"]                    = "Show the player's PvP honor level in the tooltip."
-- L["AXIS_PVP_TITLE"]                                        = "Show PvP title"
-- L["AXIS_PLAYER_S_PVP_TITLE_E_G"]                           = "Show the player's PvP title (e.g. Gladiator) in the tooltip."
L["AXIS_CHARACTER_TITLE"]                                     = "Character title"
-- L["AXIS_PLAYER_S_SELECTED_TITLE_ACHIEVEMENT_PVP"]          = "Show the player's selected title (achievement or PvP) in the name line."
L["AXIS_TITLE_COLOUR"]                                        = "Title colour"
-- L["AXIS_COLOUR_OF_CHARACTER_TITLE_PLAYER_TOOLTIP"]         = "Colour of the character title in the player tooltip name line."
L["AXIS_STATUS_BADGES"]                                       = "Show status badges"
-- L["AXIS_INLINE_BADGES_COMBAT_AFK_DND_PVP"]                 = "Show inline badges for combat, AFK, DND, PvP flag, party/raid membership, friends, and whether the player is targeting you."
L["AXIS_MOUNT_INFO"]                                          = "Show mount info"
-- L["AXIS_HOVERING_A_MOUNTED_PLAYER_THEIR_MOUNT"]            = "When hovering a mounted player, show their mount name, source, and whether you own it."
L["AXIS_BLANK_SEPARATOR"]                                     = "Blank separator"
-- L["AXIS_A_BLANK_LINE_INSTEAD_OF_DASHES"]                   = "Use a blank line instead of dashes between tooltip sections."
L["AXIS_ICONS"]                                               = "Show icons"
L["AXIS_CLASS_ICON_STYLE"]                                    = "Class icon style"
L["AXIS_DEFAULT_BLIZZARD_RONDOMEDIA_CLASS_ICONS_TH"]          = "Use Default (Blizzard) or RondoMedia class icons on the class/spec line."
L["AXIS_CUSTOM_CLASS_ICONS_LABEL"]                            = "Custom (addon media)"
L["AXIS_CLASS_ICON_SOURCES_TOOLTIP"]                          = "RondoMedia: https://www.curseforge.com/wow/addons/rondomedia — Custom: place one .tga per class under media/CustomClassIcons/<CLASS>/<class lower>.tga (e.g. WARRIOR/warrior.tga), then /reload."
-- L["AXIS_RONDOMEDIA_CLASS_ICONS_RONDOFERRARI_HTTPS_WWW"]    = "RondoMedia class icons by RondoFerrari — https://www.curseforge.com/wow/addons/rondomedia"
-- L["AXIS_DEFAULT"]                                          = "Default"
-- L["AXIS_FACTION_SPEC_MOUNT_MYTHIC_ICONS_TOOLTIPS"]         = "Show faction, spec, mount, and Mythic+ icons in tooltips."
-- L["AXIS_GENERAL"]                                          = "General"
L["AXIS_POSITION"]                                            = "Posición"
L["AXIS_RESET_POSITION"]                                      = "Restablecer posición"
L["AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"]                   = "Restablecer posición de notificaciones de botín."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["FOCUS_LOCK_POSITION"]                                      = "Bloquear posición"
L["FOCUS_PREVENT_DRAGGING_TRACKER"]                           = "Impide arrastrar el rastreador de objetivos."
L["FOCUS_GROW_UPWARD"]                                        = "Crecer hacia arriba"
L["FOCUS_GROW_HEADER"]                                        = "Encabezado al crecer"
L["FOCUS_GROWING_UPWARD_KEEP_HEADER_BOTTOM_TOP"]              = "Al crecer hacia arriba: mantener encabezado abajo o arriba hasta colapsar."
L["FOCUS_HEADER_BOTTOM"]                                      = "Encabezado abajo"
L["FOCUS_HEADER_SLIDES_COLLAPSE"]                             = "Encabezado se desliza al colapsar"
L["FOCUS_ANCHOR_BOTTOM_LIST_GROWS_UPWARD"]                    = "Anclar abajo para que la lista crezca hacia arriba."
L["FOCUS_START_COLLAPSED"]                                    = "Iniciar colapsado"
L["FOCUS_START_HEADER_SHOWN_UNTIL_YOU_EXPAND"]                = "Mostrar solo el encabezado hasta que lo expandas."
L["FOCUS_ALIGN_CONTENT_RIGHT"]                                = "Align content right"
-- L["FOCUS_RIGHT_ALIGN_QUEST_TITLES_OBJECTIVES_WITHIN"]      = "Right-align quest titles and objectives within the panel."
L["FOCUS_PANEL_WIDTH"]                                        = "Ancho del panel"
L["FOCUS_TRACKER_WIDTH_PIXELS"]                               = "Ancho del rastreador de objetivos en píxeles."
L["FOCUS_MAX_CONTENT_HEIGHT"]                                 = "Altura máxima del contenido"
L["FOCUS_MAX_HEIGHT_OF_SCROLLABLE_LIST_PIXELS"]               = "Altura máxima de la lista desplazable (píxeles)."
-- L["FOCUS_STATIC_BACKGROUND"]                               = "Static Background Size"
-- L["FOCUS_STATIC_BACKGROUND_DESC"]                          = "Lock the panel to a fixed height regardless of tracked content."
-- L["FOCUS_STATIC_PANEL_HEIGHT"]                             = "Static Panel Height"
-- L["FOCUS_STATIC_PANEL_HEIGHT_DESC"]                        = "Pixel height of the panel when static background is enabled."

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["FOCUS_ALWAYS_M_BLOCK"]                                     = "Mostrar siempre el bloque M+"
L["FOCUS_M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]                = "Muestra el bloque M+ cuando haya una piedra angular activa."
L["FOCUS_DUNGEON"]                                            = "Mostrar en mazmorra"
L["FOCUS_TRACKER_PARTY_DUNGEONS"]                             = "Muestra el rastreador en mazmorras de grupo."
L["FOCUS_RAID"]                                               = "Mostrar en banda"
L["FOCUS_TRACKER_RAIDS"]                                      = "Muestra el rastreador en bandas."
L["FOCUS_BATTLEGROUND"]                                       = "Mostrar en campo de batalla"
L["FOCUS_TRACKER_BATTLEGROUNDS"]                              = "Muestra el rastreador en campos de batalla."
L["FOCUS_ARENA"]                                              = "Mostrar en arena"
L["FOCUS_TRACKER_ARENAS"]                                     = "Muestra el rastreador en arenas."
L["FOCUS_HIDE_COMBAT"]                                        = "Ocultar en combate"
L["FOCUS_HIDE_TRACKER_FLOATING_QUEST_ITEM_COMBAT"]            = "Oculta el rastreador y el objeto de misión flotante en combate."
L["FOCUS_COMBAT_VISIBILITY"]                                  = "Visibilidad en combate"
L["FOCUS_TRACKER_BEHAVES_COMBAT_FADE_REDUC"]                  = "Comportamiento del rastreador en combate: mostrar, atenuar o ocultar."
L["FOCUS_SHOW"]                                               = "Mostrar"
L["FOCUS_FADE"]                                               = "Atenuar"
L["FOCUS_HIDE"]                                               = "Ocultar"
L["FOCUS_COMBAT_FADE_OPACITY"]                                = "Opacidad atenuada en combate"
L["FOCUS_VISIBLE_TRACKER_FADED_COMBAT"]                       = "Visibilidad del rastreador cuando está atenuado en combate (0 = invisible). Solo aplica cuando la visibilidad en combate es Atenuar."
L["FOCUS_MOUSEOVER"]                                          = "Al pasar el ratón"
L["FOCUS_SHOW_ONLY_MOUSEOVER"]                                = "Mostrar solo al pasar el ratón"
L["FOCUS_FADE_TRACKER_HOVERING_MOVE_MOUSE"]                   = "Atenúa el rastreador cuando no pasas el ratón; pásalo por encima para mostrarlo."
L["FOCUS_FADED_OPACITY"]                                      = "Opacidad atenuada"
L["FOCUS_VISIBLE_TRACKER_FADED_INVISIBLE"]                    = "Visibilidad del rastreador cuando está atenuado (0 = invisible)."
L["FOCUS_QUESTS_CURRENT_ZONE"]                                = "Solo misiones de la zona actual"
L["FOCUS_HIDE_QUESTS_OUTSIDE_YOUR_CURRENT_ZONE"]              = "Oculta misiones fuera de tu zona actual."

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["FOCUS_QUEST_COUNT"]                                        = "Mostrar contador de misiones"
L["FOCUS_QUEST_COUNT_HEADER"]                                 = "Muestra el contador de misiones en el encabezado."
L["FOCUS_HEADER_COUNT_FORMAT"]                                = "Formato del contador de misiones"
L["FOCUS_TRACKED_LOG_LOG_MAX_SLOTS_TRACKED"]                  = "Seguidas/En registro o En registro/Máx. ranuras. Seguidas excluye misiones de mundo y de zona activa."
L["FOCUS_HEADER_DIVIDER"]                                     = "Mostrar divisor del encabezado"
L["FOCUS_LINE_BELOW_HEADER"]                                  = "Muestra la línea debajo del encabezado."
L["FOCUS_HEADER_DIVIDER_COLOUR"]                              = "Colour del divisor del encabezado"
L["FOCUS_COLOUR_OF_LINE_BELOW_HEADER"]                        = "Colour de la línea debajo del encabezado."
L["FOCUS_SUPER_MINIMAL_MODE"]                                 = "Modo super minimalista"
L["FOCUS_HIDE_HEADER_A_PURE_TEXT_LIST"]                       = "Oculta el encabezado para una lista de solo texto."
L["FOCUS_OPTIONS_BUTTON"]                                     = "Options button"
L["FOCUS_OPTIONS_BUTTON_TRACKER_HEADER"]                      = "Muestra el botón de opciones en el encabezado del rastreador."
L["FOCUS_HEADER_COLOUR"]                                      = "Colour del encabezado"
L["FOCUS_COLOUR_OF_OBJECTIVES_HEADER_TEXT"]                   = "Colour del texto del encabezado OBJETIVOS."
L["FOCUS_HEADER_HEIGHT"]                                      = "Altura del encabezado"
L["FOCUS_HEIGHT_OF_HEADER_BAR_PIXELS"]                        = "Altura de la barra del encabezado en píxeles (18–48)."

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["FOCUS_SECTION_HEADERS"]                                    = "Mostrar encabezados de sección"
L["FOCUS_CATEGORY_LABELS_ABOVE_GROUP"]                        = "Muestra las etiquetas de categoría encima de cada grupo."
L["FOCUS_CATEGORY_HEADERS_COLLAPSED"]                         = "Mostrar encabezados de categoría cuando está colapsado"
L["FOCUS_KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED_CLICK"]       = "Mantiene los encabezados visibles cuando está colapsado; haz clic para expandir una categoría."
L["FOCUS_NEARBY_CURRENT_ZONE_GROUP"]                          = "Mostrar grupo Zona actual"
L["FOCUS_ZONE_QUESTS_A_DEDICATED_CURRENT_ZONE"]               = "Muestra las misiones de zona en una sección dedicada. Desactivado: aparecen en su categoría normal."
L["FOCUS_ZONE_LABELS"]                                        = "Mostrar etiquetas de zona"
L["FOCUS_ZONE_NAME_UNDER_QUEST_TITLE"]                        = "Muestra el nombre de zona debajo de cada título de misión."
L["FOCUS_ACTIVE_QUEST_HIGHLIGHT"]                             = "Resaltado de misión activa"
L["FOCUS_FOCUSED_QUEST_HIGHLIGHTED"]                          = "Cómo se resalta la misión enfocada."
L["FOCUS_QUEST_ITEM_BUTTONS"]                                 = "Mostrar botones de objeto de misión"
L["FOCUS_USABLE_QUEST_ITEM_BUTTON_NEXT_QUEST"]                = "Muestra el botón de objeto utilizable junto a cada misión."
L["FOCUS_TOOLTIPS_HOVER"]                                     = "Tooltips on hover"
-- L["FOCUS_TOOLTIPS_HOVERING_TRACKER_ENTRIES_ITE"]           = "Show tooltips when hovering over tracker entries, item buttons, and scenario blocks."
L["FOCUS_WOWHEAD_LINK_TOOLTIPS"]                              = "Show WoWhead link in tooltips"
-- L["FOCUS_A_TOOLTIP_SHOWN_ADD_A_LINK"]                      = "When a tooltip is shown, add a link to open the quest, achievement, or NPC on WoWhead."
-- L["FOCUS_VIEW_WOWHEAD"]                                    = "View on WoWhead"
L["FOCUS_WOWHEAD_ALT_CLICK_HINT"]                             = "Alt+click row to copy"
-- L["FOCUS_WOWHEAD_HINT_LIST_SEPARATOR"]                     = " · "
-- L["FOCUS_WOWHEAD_TOOLTIP_HINT_FALLBACK"]                   = "Configure in Focus options"
-- L["FOCUS_COPY_LINK"]                                       = "Copy link"
-- L["FOCUS_COPY_URL_BELOW_CTRL_C_PASTE"]                     = "Copy the URL below (Ctrl+C) and paste in your browser."
L["FOCUS_OBJECTIVE_NUMBERS"]                                  = "Mostrar números de objetivos"
L["FOCUS_OBJECTIVE_PREFIX"]                                   = "Objective prefix"
L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS"]                  = "Colour objective progress numbers"
L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS_DESC"]             = "Tint X/Y counts: normal colour at 0/n, gold while in progress, green when complete. The slash uses the usual objective colour."
-- L["FOCUS_PREFIX_OBJECTIVE_A_NUMBER_HYPHEN"]                = "Prefix each objective with a number or hyphen."
-- L["FOCUS_NUMBERS"]                                         = "Numbers (1. 2. 3.)"
-- L["FOCUS_HYPHENS"]                                         = "Hyphens (-)"
L["FOCUS_AFTER_SECTION_HEADER"]                               = "After section header"
L["FOCUS_BEFORE_SECTION_HEADER"]                              = "Before section header"
L["FOCUS_BELOW_HEADER"]                                       = "Below header"
L["FOCUS_INLINE_BELOW_TITLE"]                                 = "Inline below title"
L["FOCUS_PREFIX_OBJECTIVES"]                                  = "Prefijar objetivos con 1., 2., 3."
L["FOCUS_COMPLETED_COUNT"]                                    = "Mostrar contador de completados"
L["FOCUS_X_Y_PROGRESS_QUEST_TITLE"]                           = "Muestra el progreso X/Y en el título de la misión."
L["FOCUS_OBJECTIVE_PROGRESS_BAR"]                             = "Mostrar barra de progreso de objetivos"
L["FOCUS_A_PROGRESS_BAR_UNDER_OBJECTIVES_NUMER"]              = "Muestra una barra de progreso bajo objetivos con progreso numérico (ej. 3/250). Solo aplica a entradas con un solo objetivo aritmético donde la cantidad requerida es mayor que 1."
L["FOCUS_CATEGORY_COLOUR_PROGRESS_BAR"]                       = "Usar colour de categoría para la barra"
L["FOCUS_PROGRESS_BAR_MATCHES_QUEST_ACHIEVEME"]               = "Activado: la barra usa el colour de la categoría. Desactivado: usa el colour personalizado de abajo."
L["FOCUS_PROGRESS_BAR_TEXTURE"]                               = "Textura de barra de progreso"
L["FOCUS_PROGRESS_BAR_TYPES"]                                 = "Tipos de barra de progreso"
L["FOCUS_TEXTURE_PROGRESS_BAR_FILL"]                          = "Textura del relleno de la barra."
L["FOCUS_TEXTURE_PROGRESS_BAR_FILL_SOLID_YOUR"]               = "Textura del relleno. Sólido usa tus colores. Los addons SharedMedia añaden más opciones."
L["FOCUS_PROGRESS_BAR_X_Y_OBJECTIVES_PERCENT"]                = "Mostrar barra para objetivos X/Y, solo porcentaje, o ambos."
L["FOCUS_X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]             = "X/Y: objetivos como 3/10. Porcentaje: objetivos como 45%."
L["FOCUS_X_Y"]                                                = "Solo X/Y"
L["FOCUS_PERCENT"]                                            = "Solo porcentaje"
L["FOCUS_TICK_COMPLETED_OBJECTIVES"]                          = "Usar marca para objetivos completados"
L["FOCUS_COMPLETED_OBJECTIVES_A_CHECKMARK_INSTEA"]            = "Activado: los objetivos completados muestran una marca (✓) en lugar de colour verde."
L["FOCUS_ENTRY_NUMBERS"]                                      = "Mostrar numeración de entradas"
L["FOCUS_PREFIX_QUEST_TITLES_WITHIN_CATEGORY"]                = "Prefijar títulos de misiones con 1., 2., 3. en cada categoría."
L["FOCUS_COMPLETED_OBJECTIVES"]                               = "Objetivos completados"
L["FOCUS_MULTI_OBJECTIVE_QUESTS_DISPLAY_OBJECTIVES"]          = "Para misiones con varios objetivos, cómo mostrar los completados (ej. 1/1)."
L["FOCUS_ALL"]                                                = "Mostrar todo"
L["FOCUS_FADE_COMPLETED"]                                     = "Atenuar completados"
L["FOCUS_HIDE_COMPLETED"]                                     = "Ocultar completados"
L["FOCUS_ICON_ZONE_AUTO_TRACKING"]                            = "Mostrar icono de seguimiento automático en zona"
L["FOCUS_DISPLAY_AN_ICON_NEXT_AUTO_TRACKED"]                  = "Muestra un icono junto a misiones de mundo y semanales/diarias con seguimiento automático que aún no están en tu registro (solo en zona)."
L["FOCUS_AUTO_TRACK_ICON"]                                    = "Icono de seguimiento automático"
L["FOCUS_CHOOSE_WHICH_ICON_DISPLAY_NEXT_AUTO"]                = "Elige qué icono mostrar junto a las entradas con seguimiento automático en zona."
L["FOCUS_APPEND_WORLD_QUESTS_WEEKLIES_DAILIES"]               = "Añade ** a misiones de mundo y semanales/diarias que aún no están en tu registro (solo en zona)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["FOCUS_COMPACT_MODE"]                                       = "Modo compacto"
L["FOCUS_PRESET_SETS_ENTRY_OBJECTIVE_SPACING_P"]              = "Preajuste: espaciado de entradas y objetivos a 4 y 1 px."
L["FOCUS_SPACING_PRESET"]                                     = "Preajuste de espaciado"
L["FOCUS_PRESET_ENTRY_OBJECTIVE_SPACING_DEFAULT_P"]           = "Preajuste: Default (8/2 px), Compact (4/1 px), Spaced (12/3 px) o Custom (usar sliders)."
L["FOCUS_COMPACT_VERSION"]                                    = "Versión compacta"
L["FOCUS_SPACED_VERSION"]                                     = "Versión espaciada"
L["FOCUS_SPACING_BETWEEN_QUEST_ENTRIES_PX"]                   = "Espaciado entre misiones (px)"
L["FOCUS_VERTICAL_GAP_BETWEEN_QUEST_ENTRIES"]                 = "Espacio vertical entre misiones."
L["FOCUS_SPACING_BEFORE_CATEGORY_HEADER_PX"]                  = "Espaciado antes del encabezado (px)"
L["FOCUS_GAP_BETWEEN_LAST_ENTRY_OF_A"]                        = "Espacio entre la última entrada de un grupo y la siguiente etiqueta de categoría."
L["FOCUS_SPACING_AFTER_CATEGORY_HEADER_PX"]                   = "Espaciado después del encabezado (px)"
L["FOCUS_GAP_BETWEEN_CATEGORY_LABEL_FIRST_QUEST"]             = "Espacio entre la etiqueta de categoría y la primera misión debajo."
L["FOCUS_SPACING_BETWEEN_OBJECTIVES_PX"]                      = "Espaciado entre objetivos (px)"
L["FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVE_LINES_WITHIN"]        = "Espacio vertical entre líneas de objetivos en una misión."
L["FOCUS_TITLE_CONTENT"]                                      = "Título a contenido"
L["FOCUS_VERTICAL_GAP_BETWEEN_QUEST_TITLE_OBJECTIVES"]        = "Espacio vertical entre el título de la misión y los objetivos o zona debajo."
L["FOCUS_SPACING_BELOW_HEADER_PX"]                            = "Espaciado debajo del encabezado (px)"
L["FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVES_BAR_QUES"]           = "Espacio entre la barra de objetivos y la lista de misiones."
L["FOCUS_RESET_SPACING"]                                      = "Restablecer espaciado"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["FOCUS_SHOW_QUEST_LEVEL"]                                   = "Mostrar nivel de misión"
L["FOCUS_QUEST_LEVEL_NEXT_TITLE"]                             = "Muestra el nivel de misión junto al título."
L["FOCUS_DIM_FOCUSED_QUESTS"]                                 = "Atenuar misiones no enfocadas"
L["FOCUS_SLIGHTLY_DIM_TITLE_ZONE_OBJECTIVES_SECTION"]         = "Atenúa ligeramente títulos, zonas, objetivos y encabezados no enfocados."
L["FOCUS_DIM_UNFOCUSED_ENTRIES"]                              = "Dim unfocused entries"
-- L["FOCUS_CLICK_A_SECTION_HEADER_EXPAND_CATEGORY"]          = "Click a section header to expand that category."

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["UI_SHOW_RARE_BOSSES"]                                      = "Mostrar jefes raros"
L["UI_RARE_BOSS_VIGNETTES_LIST"]                              = "Muestra los jefes raros en la lista."
L["UI_RARE_LOOT"]                                             = "Botín raro"
L["UI_TREASURE_ITEM_VIGNETTES_RARE_LOOT"]                     = "Muestra tesoros y objetos en la lista de botín raro."
L["UI_RARE_SOUND_VOLUME"]                                     = "Volumen del sonido de botín raro"
L["UI_VOLUME_OF_RARE_ALERT_SOUND"]                            = "Volumen del sonido de alerta de botín raro (50–200%)."
L["UI_BOOST_REDUCE_RARE_ALERT_VOLUME"]                        = "Aumenta o reduce el volumen. 100% = normal; 150% = más alto."
L["UI_RARE_ADDED_SOUND"]                                      = "Sonido al añadir raro"
L["UI_PLAY_A_SOUND_A_RARE"]                                   = "Reproduce un sonido cuando se añade un raro."
-- L["UI_MINIMAP_PATCH_NOTES_UNREAD_HINT"]                    = "New patch notes — open Axis and choose Patch Notes."

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["FOCUS_ZONE_WORLD_QUESTS"]                                  = "Mostrar misiones de mundo en zona"
L["FOCUS_AUTO_ADD_WORLD_QUESTS_YOUR_CURRENT"]                 = "Añade automáticamente misiones de mundo de tu zona. Desactivado: solo las que sigues o las cercanas (predeterminado Blizzard)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["FOCUS_SHOW_FLOATING_QUEST_ITEM"]                           = "Mostrar objeto de misión flotante"
L["FOCUS_QUICK_BUTTON_FOCUSED_QUEST_S_USABLE"]                = "Muestra el botón de uso rápido del objeto utilizable de la misión enfocada."
L["FOCUS_LOCK_FLOATING_QUEST_ITEM_POSITION"]                  = "Bloquear posición del objeto flotante"
L["FOCUS_PREVENT_DRAGGING_FLOATING_QUEST_ITEM_BUTTON"]        = "Impide arrastrar el botón del objeto de misión flotante."
L["FOCUS_FLOATING_QUEST_ITEM_SOURCE"]                         = "Origen del objeto flotante"
L["FOCUS_WHICH_QUEST_S_ITEM_SUPER_TRACKED"]                   = "Qué objeto mostrar: primero el super-seguido o primero el de zona actual."
L["FOCUS_SUPER_TRACKED_FIRST"]                                = "Super-seguido primero"
L["FOCUS_CURRENT_ZONE_FIRST"]                                 = "Zona actual primero"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["FOCUS_MYTHIC_BLOCK"]                                       = "Mostrar bloque Mítico+"
L["FOCUS_TIMER_COMPLETION_AFFIXES_MYTHIC_DUNGEONS"]           = "Muestra temporizador, % de completado y afijos en mazmorras Mítico+."
L["FOCUS_M_BLOCK_POSITION"]                                   = "Posición del bloque M+"
L["FOCUS_POSITION_OF_MYTHIC_BLOCK_RELATIVE_QUEST"]            = "Posición del bloque M+ respecto a la lista de misiones."
L["FOCUS_AFFIX_ICONS"]                                        = "Mostrar iconos de afijos"
L["FOCUS_AFFIX_ICONS_NEXT_MODIFIER_NAMES_M"]                  = "Muestra iconos de afijos junto a los nombres en el bloque M+."
L["FOCUS_AFFIX_DESCRIPTIONS_TOOLTIP"]                         = "Descripciones de afijos en descripción"
L["FOCUS_AFFIX_DESCRIPTIONS_HOVERING_M_BLO"]                  = "Muestra descripciones de afijos al pasar el ratón sobre el bloque M+."
L["FOCUS_M_COMPLETED_BOSS_DISPLAY"]                           = "Visualización de jefes M+ completados"
L["FOCUS_DEFEATED_BOSSES_CHECKMARK_ICON_GREEN"]               = "Cómo mostrar jefes derrotados: icono de marca o colour verde."
L["FOCUS_CHECKMARK"]                                          = "Marca"
L["FOCUS_GREEN_COLOUR"]                                       = "Colour verde"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["PRESENCE_ACHIEVEMENTS"]                                    = "Mostrar logros"
L["FOCUS_TRACKED_ACHIEVEMENTS_LIST"]                          = "Muestra los logros seguidos en la lista."
L["FOCUS_COMPLETED_ACHIEVEMENTS"]                             = "Mostrar logros completados"
L["FOCUS_INCLUDE_COMPLETED_ACHIEVEMENTS_TRACKER_O"]           = "Incluye logros completados. Desactivado: solo los seguidos en progreso."
L["FOCUS_ACHIEVEMENT_ICONS"]                                  = "Mostrar iconos de logros"
L["FOCUS_ACHIEVEMENT_S_ICON_NEXT_TITLE_REQUI"]                = "Muestra el icono de cada logro junto al título. Requiere 'Mostrar iconos de tipo de misión' en Visualización."
L["FOCUS_MISSING_REQUIREMENTS"]                               = "Solo mostrar requisitos faltantes"
L["FOCUS_CRITERIA_YOU_HAVEN_T_COMPLETED_TR"]                  = "Muestra solo los criterios no completados. Desactivado: se muestran todos."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["FOCUS_SHOW_ENDEAVORS"]                                     = "Mostrar empeños"
L["FOCUS_TRACKED_ENDEAVORS_PLAYER_HOUSING_LIST"]              = "Muestra los empeños seguidos (vivienda) en la lista."
L["FOCUS_COMPLETED_ENDEAVORS"]                                = "Mostrar empeños completados"
L["FOCUS_INCLUDE_COMPLETED_ENDEAVORS_TRACKER"]                = "Incluye empeños completados. Desactivado: solo los seguidos en progreso."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["FOCUS_SHOW_DECOR"]                                         = "Mostrar decoración"
L["FOCUS_TRACKED_HOUSING_DECOR_LIST"]                         = "Muestra la decoración de vivienda seguida en la lista."
L["FOCUS_DECOR_ICONS"]                                        = "Mostrar iconos de decoración"
L["FOCUS_DECOR_ITEM_S_ICON_NEXT_TITLE"]                       = "Muestra el icono de cada decoración junto al título. Requiere 'Mostrar iconos de tipo de misión' en Visualización."

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
L["FOCUS_ADVENTURE_GUIDE"]                                    = "Guía de aventuras"
L["FOCUS_TRAVELER_S_LOG"]                                     = "Mostrar Diario del viajero"
L["FOCUS_TRACKED_TRAVELER_S_LOG_OBJECTIVES_SHIFT"]            = "Muestra los objetivos seguidos del Diario del viajero (Mayús+clic en Guía de aventuras) en la lista."
L["FOCUS_AUTO_REMOVE_COMPLETED_ACTIVITIES"]                   = "Quitar automáticamente actividades completadas"
L["FOCUS_AUTOMATICALLY_STOP_TRACKING_TRAVELER_S_LOG"]         = "Deja de seguir automáticamente las actividades del Diario del viajero al completarlas."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["FOCUS_SCENARIO_EVENTS"]                                    = "Mostrar eventos de escenario"
L["FOCUS_ACTIVE_SCENARIO_DELVE_ACTIVITIES_DELVES_APP"]        = "Muestra escenarios y Simas activos. Las Simas aparecen en SIMAS; otros en EVENTOS DE ESCENARIO."
L["FOCUS_TRACK_DELVE_DUNGEON_SCENARIO_ACTIVITIES"]            = "Rastrear actividades de Simas, Mazmorras y escenarios."
L["FOCUS_DELVES_APPEAR_DELVES_SECTION_DUNGEONS_DUNGEON"]      = "Las Simas en SIMAS; las mazmorras en MAZMORRA; otros en EVENTOS DE ESCENARIO."
-- L["FOCUS_DELVES_APPEAR_DELVES_SECTION_SCENARIOS"]          = "Delves appear in Delves section; other scenarios in Scenario Events."
L["FOCUS_DELVE_AFFIX_NAMES"]                                  = "Delve affix names"
-- L["FOCUS_DELVE_DUNGEON"]                                   = "Delve/Dungeon only"
-- L["FOCUS_SCENARIO_DEBUG_LOGGING"]                          = "Scenario debug logging"
-- L["FOCUS_LOG_SCENARIO_API_DATA_CHAT_H"]                    = "Log scenario API data to chat. Use /h debug focus scendebug to toggle."
-- L["FOCUS_PRINTS_C_SCENARIOINFO_CRITERIA_WIDGET_DATA"]      = "Prints C_ScenarioInfo criteria and widget data when in a scenario. Helps diagnose display issues like Abundance 46/300."
L["FOCUS_HIDE_CATEGORIES_DELVE_DUNGEON"]                      = "Ocultar otras categorías en Sima o Mazmorra"
L["FOCUS_DELVES_PARTY_DUNGEONS_DELVE_DUNG"]                   = "En Simas o mazmorras de grupo, muestra solo la sección correspondiente."
L["FOCUS_DELVE_NAME_SECTION_HEADER"]                          = "Usar nombre de Sima como encabezado"
L["FOCUS_A_DELVE_DELVE_NAME_TIER_AFFIXES"]                    = "En una Sima: muestra nombre, nivel y afijos en el encabezado. Desactivado: muestra el bloque encima de la lista."
L["FOCUS_AFFIX_NAMES_DELVES"]                                 = "Mostrar nombres de afijos en Simas"
L["FOCUS_SEASON_AFFIX_NAMES_FIRST_DELVE_ENTRY"]               = "Muestra nombres de afijos de temporada en la primera entrada de Sima. Requiere widgets de Blizzard; puede no mostrarse con reemplazo completo."
L["FOCUS_CINEMATIC_SCENARIO_BAR"]                             = "Barra de escenario cinematográfica"
L["FOCUS_TIMER_PROGRESS_BAR_SCENARIO_ENTRIES"]                = "Muestra temporizador y barra de progreso para escenarios."
L["FOCUS_TIMER"]                                              = "Mostrar temporizador"
L["FOCUS_COUNTDOWN_TIMER_TIMED_QUESTS_EVENTS_SCEN"]           = "Muestra cuenta atrás en misiones, eventos y escenarios con tiempo. Desactivado: se ocultan todos los temporizadores."
L["FOCUS_TIMER_SCENARIOS"]                                    = "Timers: scenarios & delves"
L["FOCUS_TIMER_SCENARIOS_DESC"]                               = "Countdown timer for scenario, delve, and dungeon tracker entries."
L["FOCUS_TIMER_WORLD"]                                        = "Timers: world & callings"
L["FOCUS_TIMER_WORLD_DESC"]                                   = "Countdown timer for world quests and callings."
L["FOCUS_TIMER_QUEST_LOG"]                                    = "Timers: quest log (timed)"
L["FOCUS_TIMER_QUEST_LOG_DESC"]                               = "Countdown timer for dailies, weeklies, and other quest log entries with a time limit."
L["FOCUS_TIMER_DISPLAY"]                                      = "Visualización del temporizador"
L["FOCUS_COLOUR_TIMER_REMAINING"]                             = "Colorear temporizador por tiempo restante"
L["FOCUS_GREEN_PLENTY_OF_LEFT_YELLOW_RUNNING"]                = "Verde con tiempo de sobra, amarillo cuando queda poco, rojo cuando es crítico."
L["FOCUS_WHERE_COUNTDOWN_BAR_BELOW_OBJECTIVES"]               = "Dónde mostrar la cuenta atrás: barra bajo objetivos o texto junto al nombre de la misión."
L["FOCUS_BAR_BELOW"]                                          = "Barra debajo"
L["FOCUS_INLINE_BESIDE_TITLE"]                                = "Texto junto al título"

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["FOCUS_FONT_FAMILY"]                                        = "Familia de fuente."
L["FOCUS_TITLE_FONT"]                                         = "Fuente de títulos"
L["VISTA_ZONE_FONT"]                                          = "Fuente de zona"
L["FOCUS_OBJECTIVE_FONT"]                                     = "Fuente de objetivos"
L["FOCUS_SECTION_FONT"]                                       = "Fuente de secciones"
L["FOCUS_GLOBAL_FONT"]                                        = "Usar fuente global"
L["FOCUS_FONT_FAMILY_QUEST_TITLES"]                           = "Familia de fuente para títulos de misiones."
L["FOCUS_FONT_FAMILY_ZONE_LABELS"]                            = "Familia de fuente para etiquetas de zona."
L["FOCUS_FONT_FAMILY_OBJECTIVE_TEXT"]                         = "Familia de fuente para texto de objetivos."
L["FOCUS_FONT_FAMILY_SECTION_HEADERS"]                        = "Familia de fuente para encabezados de sección."
L["FOCUS_HEADER_SIZE"]                                        = "Tamaño del encabezado"
L["FOCUS_HEADER_FONT_SIZE"]                                   = "Tamaño de fuente del encabezado."
L["FOCUS_TITLE_SIZE"]                                         = "Tamaño del título"
L["FOCUS_QUEST_TITLE_FONT_SIZE"]                              = "Tamaño de fuente de títulos de misiones."
L["FOCUS_OBJECTIVE_SIZE"]                                     = "Tamaño de objetivos"
L["FOCUS_OBJECTIVE_TEXT_FONT_SIZE"]                           = "Tamaño de fuente del texto de objetivos."
L["FOCUS_ZONE_SIZE"]                                          = "Tamaño de zonas"
L["FOCUS_ZONE_LABEL_FONT_SIZE"]                               = "Tamaño de fuente de etiquetas de zona."
L["FOCUS_SECTION_SIZE"]                                       = "Tamaño de secciones"
L["FOCUS_SECTION_HEADER_FONT_SIZE"]                           = "Tamaño de fuente de encabezados de sección."
L["FOCUS_PROGRESS_BAR_FONT"]                                  = "Fuente de la barra de progreso"
L["FOCUS_FONT_FAMILY_PROGRESS_BAR_LABEL"]                     = "Familia de fuente para la etiqueta de la barra de progreso."
L["FOCUS_PROGRESS_BAR_TEXT_SIZE"]                             = "Tamaño del texto de la barra de progreso"
L["FOCUS_FONT_SIZE_PROGRESS_BAR_LABEL_ADJUSTS"]               = "Tamaño de fuente de la barra de progreso. También ajusta la altura. Afecta objetivos de misiones, progreso de escenarios y barras de temporizador."
-- L["FOCUS_TIMER_TEXT_FONT"]                                 = "Timer Font"
-- L["FOCUS_FONT_FAMILY_TIMER_TEXT"]                          = "Font family for quest timer text (inline timers and world quest timers)."
-- L["FOCUS_TIMER_TEXT_SIZE"]                                 = "Timer Text Size"
-- L["FOCUS_TIMER_TEXT_FONT_SIZE"]                            = "Quest timer text font size."
-- L["FOCUS_OPTIONS_FONT"]                                    = "Options Font"
-- L["FOCUS_FONT_FAMILY_OPTIONS"]                             = "Font family for the Options button label in the tracker header."
-- L["FOCUS_OPTIONS_TEXT_SIZE"]                               = "Options Text Size"
-- L["FOCUS_OPTIONS_TEXT_FONT_SIZE"]                          = "Options button label font size."
L["FOCUS_PROGRESS_BAR_FILL"]                                  = "Relleno de la barra de progreso"
L["FOCUS_PROGRESS_BAR_TEXT"]                                  = "Texto de la barra de progreso"
L["FOCUS_OUTLINE"]                                            = "Contorno"
L["FOCUS_FONT_OUTLINE_STYLE"]                                 = "Estilo de contorno de fuente."

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["FOCUS_HEADER_TEXT_CASE"]                                   = "Mayúsculas del encabezado"
L["FOCUS_DISPLAY_CASE_HEADER"]                                = "Mayúsculas para el encabezado."
L["FOCUS_SECTION_HEADER_CASE"]                                = "Mayúsculas de encabezados de sección"
L["FOCUS_DISPLAY_CASE_CATEGORY_LABELS"]                       = "Mayúsculas para etiquetas de categoría."
L["FOCUS_QUEST_TITLE_CASE"]                                   = "Mayúsculas de títulos de misiones"
L["FOCUS_DISPLAY_CASE_QUEST_TITLES"]                          = "Mayúsculas para títulos de misiones."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["FOCUS_TEXT_SHADOW"]                                        = "Mostrar sombra de texto"
L["FOCUS_ENABLE_DROP_SHADOW_TEXT"]                            = "Activa la sombra del texto."
L["FOCUS_SHADOW_X"]                                           = "Sombra X"
L["FOCUS_HORIZONTAL_SHADOW_OFFSET"]                           = "Desplazamiento horizontal de la sombra."
L["FOCUS_SHADOW_Y"]                                           = "Sombra Y"
L["FOCUS_VERTICAL_SHADOW_OFFSET"]                             = "Desplazamiento vertical de la sombra."
L["FOCUS_SHADOW_ALPHA"]                                       = "Opacidad de la sombra"
L["FOCUS_SHADOW_OPACITY"]                                     = "Opacidad de la sombra (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["FOCUS_MYTHIC_TYPOGRAPHY"]                                  = "Tipografía Mítico+"
L["FOCUS_DUNGEON_NAME_SIZE"]                                  = "Tamaño del nombre de mazmorra"
L["FOCUS_FONT_SIZE_DUNGEON_NAME_PX"]                          = "Tamaño de fuente del nombre de mazmorra (8–32 px)."
L["FOCUS_DUNGEON_NAME_COLOUR"]                                = "Colour del nombre de mazmorra"
L["FOCUS_TEXT_COLOUR_DUNGEON_NAME"]                           = "Colour del texto del nombre de mazmorra."
L["FOCUS_TIMER_SIZE"]                                         = "Tamaño del temporizador"
L["FOCUS_FONT_SIZE_TIMER_PX"]                                 = "Tamaño de fuente del temporizador (8–32 px)."
L["FOCUS_TIMER_COLOUR"]                                       = "Colour del temporizador"
L["FOCUS_TEXT_COLOUR_TIMER"]                                  = "Colour del temporizador (dentro del tiempo)."
L["FOCUS_TIMER_OVERTIME_COLOUR"]                              = "Colour del temporizador (tiempo excedido)"
L["FOCUS_TEXT_COLOUR_TIMER_LIMIT"]                            = "Colour del temporizador cuando se excede el tiempo."
L["FOCUS_PROGRESS_SIZE"]                                      = "Tamaño del progreso"
L["FOCUS_FONT_SIZE_ENEMY_FORCES_PX"]                          = "Tamaño de fuente de fuerzas enemigas (8–32 px)."
L["FOCUS_PROGRESS_COLOUR"]                                    = "Colour del progreso"
L["FOCUS_TEXT_COLOUR_ENEMY_FORCES"]                           = "Colour del texto de fuerzas enemigas."
L["FOCUS_BAR_FILL_COLOUR"]                                    = "Colour de relleno de la barra"
L["FOCUS_PROGRESS_BAR_FILL_COLOUR_PROGRESS"]                  = "Colour de relleno de la barra (en progreso)."
L["FOCUS_BAR_COMPLETE_COLOUR"]                                = "Colour de barra completada"
L["FOCUS_PROGRESS_BAR_FILL_COLOUR_ENEMY_FORCES"]              = "Colour de relleno cuando las fuerzas enemigas están al 100%."
L["FOCUS_AFFIX_SIZE"]                                         = "Tamaño de afijos"
L["FOCUS_FONT_SIZE_AFFIXES_PX"]                               = "Tamaño de fuente de afijos (8–32 px)."
L["FOCUS_AFFIX_COLOUR"]                                       = "Colour de afijos"
L["FOCUS_TEXT_COLOUR_AFFIXES"]                                = "Colour del texto de afijos."
L["FOCUS_BOSS_SIZE"]                                          = "Tamaño de nombres de jefes"
L["FOCUS_FONT_SIZE_BOSS_NAMES_PX"]                            = "Tamaño de fuente de nombres de jefes (8–32 px)."
L["FOCUS_BOSS_COLOUR"]                                        = "Colour de nombres de jefes"
L["FOCUS_TEXT_COLOUR_BOSS_NAMES"]                             = "Colour del texto de nombres de jefes."
L["FOCUS_RESET_MYTHIC_TYPOGRAPHY"]                            = "Restablecer tipografía M+"

-- =====================================================================
-- OptionsData.lua Appearance
-- =====================================================================
-- L["DASH_FRAME"]                                            = "Frame"
-- L["FOCUS_CLASS_COLOURS_DASHBOARD"]                         = "Class colours - Dashboard"
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
-- L["AXIS_CLASS_COLOURS_DESC"]                               = "Tint dashboard accents, dividers, and highlights with your class colour."
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
L["FOCUS_BACKDROP_OPACITY"]                                   = "Opacidad del fondo"
L["FOCUS_PANEL_BACKGROUND_OPACITY"]                           = "Opacidad del fondo del panel (0–1)."
L["FOCUS_BORDER"]                                             = "Mostrar borde"
L["FOCUS_BORDER_AROUND_TRACKER"]                              = "Muestra un borde alrededor del rastreador."
L["FOCUS_SCROLL_INDICATOR"]                                   = "Mostrar indicador de desplazamiento"
L["FOCUS_A_VISUAL_HINT_LIST_CONTENT_TH"]                      = "Muestra una pista visual cuando la lista tiene más contenido del visible."
L["FOCUS_SCROLL_INDICATOR_STYLE"]                             = "Estilo del indicador de desplazamiento"
L["FOCUS_CHOOSE_BETWEEN_A_FADE_GRADIENT_A"]                   = "Elige entre un degradado o una flecha pequeña para indicar contenido desplazable."
L["FOCUS_ARROW"]                                              = "Flecha"
L["FOCUS_HIGHLIGHT_ALPHA"]                                    = "Opacidad del resaltado"
L["FOCUS_OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]                 = "Opacidad del resaltado de misión enfocada (0–1)."
L["FOCUS_BAR_WIDTH"]                                          = "Ancho de la barra"
L["FOCUS_WIDTH_OF_BAR_STYLE_HIGHLIGHTS_PX"]                   = "Ancho de las barras de resaltado (2–6 px)."

-- =====================================================================
-- OptionsData.lua Organisation
-- =====================================================================
-- L["FOCUS_ACTIVITY"]                                        = "Activity"
-- L["FOCUS_CONTENT"]                                         = "Content"
-- L["FOCUS_SORTING"]                                         = "Sorting"
-- L["FOCUS_ELEMENTS"]                                        = "Elements"
L["FOCUS_CATEGORY_ORDER"]                                     = "Orden de categorías de Enfoque"
L["FOCUS_CATEGORY_COLOUR_BAR"]                                = "Category colour for bar"
L["FOCUS_CHECKMARK_COMPLETED"]                                = "Checkmark for completed"
L["FOCUS_CURRENT_QUEST_CATEGORY"]                             = "Current Quest category"
L["FOCUS_CURRENT_QUEST_WINDOW"]                               = "Current Quest window"
-- L["FOCUS_QUESTS_RECENT_PROGRESS_TOP"]                      = "Show quests with recent progress at the top."
-- L["FOCUS_RECENT_QUEST_SECONDS"]                            = "Seconds of recent progress to show in Current Quest (30–120)."
-- L["FOCUS_QUEST_PROGRESSION_SECTION"]                       = "Quests you made progress on in the last minute appear in a dedicated section."
L["FOCUS_SHOW_ZONE_EVENTS"]                                   = "Events in Zone section"
L["FOCUS_SHOW_ZONE_EVENTS_DESC"]                              = "Show the Events in Zone section for nearby unaccepted quests and zone event quests."
L["FOCUS_SHOW_ZONE_EVENTS_TIP"]                               = "When off, those quests appear in their normal categories instead."
L["FOCUS_CATEGORY_ORDER"]                                     = "Orden de categorías de Enfoque"
L["FOCUS_CATEGORIES_REORDER_EXCEPT_DELVES_SCENARIOS"]         = "Arrastra para reordenar. SIMAS y EVENTOS DE ESCENARIO permanecen primero."
-- L["FOCUS_CATEGORIES_REORDER_EXCEPT_DELVES_SCENARIOS_TIP"]  = "Drag to reorder. Delves and Scenarios stay first."
L["FOCUS_SORT_MODE"]                                          = "Modo de ordenación de Enfoque"
L["FOCUS_ENTRY_NUMBER_IN_CATEGORY"]                           = "Orden de entradas dentro de cada categoría."
L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS"]                         = "Seguir automáticamente misiones aceptadas"
L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS_TIP"]                     = "Al aceptar una misión (solo registro, no misiones de mundo), la añade al rastreador automáticamente."
L["FOCUS_CTRL_FOCUS_REMOVE"]                                  = "Requerir Ctrl para enfocar y quitar"
L["FOCUS_CTRL_FOCUS_REMOVE_MOUSECLICK"]                       = "Requiere Ctrl para enfocar (clic izquierdo) y quitar (clic derecho) para evitar clics accidentales."
L["FOCUS_CTRL_FOCUS_UNTRACK"]                                 = "Ctrl for focus / untrack"
L["FOCUS_CTRL_CLICK_COMPLETE"]                                = "Ctrl to click-complete"
L["FOCUS_CLASSIC_CLICK_BEHAVIOUR"]                            = "Usar comportamiento de clic clásico"
-- L["FOCUS_CLASSIC_CLICKS"]                                  = "Classic clicks"
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
L["FOCUS_SHARE_PARTY"]                                        = "Compartir con el grupo"
L["FOCUS_ABANDON_QUEST"]                                      = "Abandonar misión"
-- L["FOCUS_CONTEXT_FOCUS_QUEST"]                             = "Focus quest"
L["FOCUS_STOP_TRACKING"]                                      = "Dejar de seguir"
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
L["FOCUS_CANNOT_SHARE_QUEST"]                                 = "Esta misión no se puede compartir."
L["FOCUS_REQUIRE_PARTY_SHARE"]                                = "Debes estar en un grupo para compartir esta misión."
L["FOCUS_LEFT_CLICK_MAP_RIGHT_CLICK_ABANDON"]                 = "Activado: clic izquierdo abre el mapa de misión, clic derecho muestra menú compartir/abandonar (estilo Blizzard). Desactivado: clic izquierdo enfoca, clic derecho deja de seguir; Ctrl+Clic derecho comparte con el grupo."
L["FOCUS_ANIMATIONS"]                                         = "Focus animations"
L["FOCUS_SLIDE_FADE_QUESTS"]                                  = "Activa deslizamiento y fundido para misiones."
L["FOCUS_OBJECTIVE_PROGRESS_FLASH"]                           = "Destello de progreso de objetivo"
L["FOCUS_FLASH_OBJECTIVE_COMPLETION"]                         = "Muestra un destello cuando se completa un objetivo."
L["FOCUS_FLASH_INTENSITY"]                                    = "Intensidad del destello"
L["FOCUS_OBJECTIVE_PROGRESS_FLASH_VISIBILITY"]                = "Qué tan notable es el destello al completar un objetivo."
L["FOCUS_FLASH_COLOUR"]                                       = "Colour del destello"
L["FOCUS_FLASH_COLOUR_DESC"]                                  = "Colour del destello al completar un objetivo."
L["FOCUS_SUBTLE"]                                             = "Sutil"
L["FOCUS_MEDIUM"]                                             = "Medio"
L["FOCUS_STRONG"]                                             = "Fuerte"
L["FOCUS_REQUIRE_CTRL_CLICK_COMPLETE"]                        = "Requerir Ctrl para clic y completar"
L["FOCUS_REQUIRES_CTRL_LEFT_CLICK_COMPLETE_AUTO"]             = "Activado: requiere Ctrl+Clic izquierdo para completar. Desactivado: un simple clic izquierdo (predeterminado Blizzard). Solo afecta misiones completables por clic."
L["FOCUS_SUPPRESS_UNTRACKED_UNTIL_RELOAD"]                    = "Ocultar no seguidas hasta recargar"
L["FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS"]                   = "Activado: dejar de seguir oculta hasta recargar. Desactivado: reaparecen al volver a la zona."
L["FOCUS_PERMANENTLY_SUPPRESS_UNTRACKED_QUESTS"]              = "Ocultar permanentemente misiones no seguidas"
L["FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS_DESC"]              = "Activado: las no seguidas se ocultan permanentemente. Tiene prioridad sobre 'Ocultar hasta recargar'. Aceptar una oculta la quita de la lista negra."
L["FOCUS_KEEP_CAMPAIGN_CATEGORY"]                             = "Mantener misiones de campaña en categoría"
L["FOCUS_CAMPAIGN_READY_STAY"]                                = "Activado: las misiones de campaña listas para entregar permanecen en Campaña en lugar de pasar a Completadas."
L["FOCUS_KEEP_IMPORTANT_QUESTS_CATEGORY"]                     = "Mantener misiones importantes en categoría"
L["FOCUS_IMPORTANT_READY_STAY"]                               = "Activado: las misiones importantes listas para entregar permanecen en Importante en lugar de pasar a Completadas."
L["FOCUS_TOMTOM_QUEST_WAYPOINT"]                              = "Punto de referencia TomTom"
L["FOCUS_TOMTOM_QUEST_WAYPOINT_TIP"]                          = "Establecer un punto de referencia TomTom al enfocar una misión."
L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_NEXT_QUEST"]            = "Requiere TomTom. Apunta la flecha al siguiente objetivo de misión."
L["FOCUS_TOMTOM_RARE_WAYPOINT"]                               = "Punto de referencia TomTom (raro)"
L["FOCUS_TOMTOM_WAYPOINT_RARE_CLICK"]                         = "Establecer un punto de referencia TomTom al hacer clic en un jefe raro."
L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_RARE"]                  = "Requiere TomTom. Apunta la flecha a la ubicación del jefe raro."
-- L["FOCUS_FIND_GROUP"]                                      = "Find a Group"
-- L["FOCUS_GROUP_QUEST_SEARCH_CLICK"]                        = "Click to search for a group for this quest."

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
-- L["FOCUS_BLACKLIST"]                                       = "Blacklist"
L["FOCUS_BLACKLIST_UNTRACKED"]                                = "Blacklist untracked"
-- L["FOCUS_ENABLE_BLACKLIST_UNTRACKED_BEHAVIOUR_ADD_QUEST"]  = "Enable 'Blacklist untracked' in Behaviour to add quests here."
-- L["FOCUS_HIDDEN_QUESTS"]                                   = "Hidden Quests"
-- L["FOCUS_QUESTS_HIDDEN_RIGHT_CLICK_UNTRACK"]               = "Quests hidden via right-click untrack."
L["FOCUS_BLACKLISTED_QUESTS"]                                 = "Misiones en lista negra"
L["FOCUS_PERMANENTLY_SUPPRESSED_QUESTS"]                      = "Misiones ocultas permanentemente"
L["FOCUS_RIGHT_CLICK_UNTRACK_QUESTS_PERMANENTLY_SUPPRESS"]    = "Clic derecho para dejar de seguir con 'Ocultar permanentemente' activado para añadirlas aquí."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["PRESENCE_QUEST_TYPE_ICONS"]                                = "Mostrar iconos de tipo de misión"
L["PRESENCE_QUEST_TYPE_ICON_FOCUS_TRACKER_QUEST"]             = "Muestra en el rastreador: misión aceptada/completada, misión de mundo, actualización de misión."
L["PRESENCE_QUEST_TYPE_ICONS_TOASTS"]                         = "Mostrar iconos de tipo de misión en notificaciones"
L["PRESENCE_QUEST_TYPE_ICON_PRESENCE_TOASTS_QUEST"]           = "Muestra el icono de tipo de misión en notificaciones: aceptada/completada, misión de mundo, actualización."
L["PRESENCE_TOAST_ICON_SIZE"]                                 = "Tamaño de iconos en notificaciones"
L["PRESENCE_QUEST_ICON_SIZE_PRESENCE_TOASTS_PX"]              = "Tamaño de iconos de misión en notificaciones (16–36 px). Por defecto 24."
L["PRESENCE_HIDE_QUEST_UPDATE_TITLE"]                         = "Ocultar título en avances de misión"
L["PRESENCE_OBJECTIVE_LINE_QUEST_PROGRESS_TOAST"]             = "Muestra solo la línea de objetivo (ej. 7/10 Pieles de jabalí) sin el nombre de misión ni encabezado."
L["PRESENCE_SHOW_DISCOVERY_LINE"]                             = "Mostrar línea de descubrimiento"
L["PRESENCE_DISCOVERY_LINE"]                                  = "Discovery line"
L["PRESENCE_SHOW_DISCOVERED"]                                 = "Muestra 'Descubierto' bajo zona/subzona al entrar en un área nueva."
L["PRESENCE_FRAME_VERTICAL_POSITION"]                         = "Posición vertical del marco"
L["PRESENCE_VERTICAL_OFFSET_OF_PRESENCE_FRAME_CENTER"]        = "Desplazamiento vertical del marco Presencia desde el centro (-300 a 0)."
L["PRESENCE_FRAME_SCALE"]                                     = "Escala del marco"
L["PRESENCE_FRAME_SCALE_TIP"]                                 = "Escala del marco Presencia (0.5–2)."
L["PRESENCE_BOSS_EMOTE_COLOUR"]                               = "Colour de emotes de jefes"
L["PRESENCE_COLOUR_RAID_DUNGEON_BOSS_EMOTE"]                  = "Colour del texto de emotes de jefes en banda y mazmorra."
L["PRESENCE_DISCOVERY_LINE_COLOUR"]                           = "Colour de la línea de descubrimiento"
L["PRESENCE_COLOUR_OF_DISCOVERED_LINE_UNDER_ZONE_TIP"]        = "Colour de la línea 'Descubierto' bajo el texto de zona."
L["PRESENCE_NOTIFICATION_TYPES"]                              = "Tipos de notificación"
-- L["PRESENCE_NOTIFICATIONS"]                                = "Notifications"
-- L["PRESENCE_NOTIFICATION_ACHIEVEMENT_CRITERIA_UPDATE"]     = "Show notification when achievement criteria update (tracked achievements always; others when Blizzard provides the achievement ID)."
L["PRESENCE_ZONE_ENTRY"]                                      = "Mostrar entrada en zona"
L["PRESENCE_ZONE_CHANGE_ENTERING_A_AREA"]                     = "Muestra notificación al entrar en un área nueva."
L["PRESENCE_SUBZONE_CHANGES"]                                 = "Mostrar cambios de subzona"
L["PRESENCE_SUBZONE_CHANGE_MOVING_WITHIN_SAME_ZONE"]          = "Muestra notificación al moverse entre subzonas en la misma zona."
L["PRESENCE_HIDE_ZONE_NAME_SUBZONE_CHANGES"]                  = "Ocultar nombre de zona para cambios de subzona"
L["PRESENCE_MOVING_BETWEEN_SUBZONES_WITHIN_SAME_ZONE"]        = "Al moverse entre subzonas, solo muestra el nombre de subzona. El nombre de zona aparece al entrar en una zona nueva."
-- L["PRESENCE_SUPPRESS_DELVE"]                               = "Suppress in Delve"
-- L["PRESENCE_SUPPRESS_SCENARIO_PROGRESS_NOTIFICATIONS_DELVES"]= "Suppress scenario progress notifications in Delves."
-- L["PRESENCE_HIDE_DELVE_OBJECTIVE_UPDATE"]                  = "When on, hides objective update popups while in a Delve. Zone entry and completion toasts still show."
L["PRESENCE_SUPPRESS_ZONE_CHANGES_MYTHIC"]                    = "Suprimir cambios de zona en Mítico+"
L["PRESENCE_MYTHICPLUS_SHOW_BOSS_EMOTES_ACHIEVEMENTS_LEVELS"]   = "En Mítico+, solo muestra emotes de jefes, logros y subida de nivel. Oculta notificaciones de zona, misión y escenario."
L["PRESENCE_LEVEL"]                                           = "Mostrar subida de nivel"
L["PRESENCE_LEVEL_NOTIFICATION"]                              = "Muestra la notificación de subida de nivel."
L["PRESENCE_BOSS_EMOTES"]                                     = "Mostrar emotes de jefes"
L["PRESENCE_RAID_DUNGEON_BOSS_EMOTE_NOTIFICATIONS"]           = "Muestra notificaciones de emotes de jefes en banda y mazmorra."
L["PRESENCE_ACHIEVEMENTS"]                                    = "Mostrar logros"
L["PRESENCE_ACHIEVEMENT_EARNED_NOTIFICATIONS"]                = "Muestra notificaciones de logros obtenidos."
L["PRESENCE_ACHIEVEMENT_PROGRESS"]                            = "Progreso de logros"
L["PRESENCE_SHOW_ACHIEVEMENT_EARNED"]                         = "Logro obtenido"
L["PRESENCE_SHOW_QUEST_ACCEPTED"]                             = "Misión aceptada"
L["PRESENCE_SHOW_WORLD_QUEST_ACCEPTED"]                       = "Misión de mundo aceptada"
L["PRESENCE_SHOW_SCENARIO_COMPLETE"]                          = "Escenario completado"
L["PRESENCE_SHOW_RARE_DEFEATED"]                              = "Raro derrotado"
L["PRESENCE_NOTIFICATION_TRACKED_ACHIEVEMENT_CRITERIA"]       = "Muestra notificación cuando se actualizan los criterios de un logro rastreado."
L["PRESENCE_QUEST_ACCEPT"]                                    = "Mostrar aceptación de misión"
L["PRESENCE_NOTIFICATION_ACCEPTING_A_QUEST"]                  = "Muestra notificación al aceptar una misión."
L["PRESENCE_WORLD_QUEST_ACCEPT"]                              = "Mostrar aceptación de misión de mundo"
L["PRESENCE_NOTIFICATION_ACCEPTING_A_WORLD_QUEST"]            = "Muestra notificación al aceptar una misión de mundo."
L["PRESENCE_SHOW_QUEST_COMPLETE"]                             = "Mostrar misión completada"
L["PRESENCE_NOTIFICATION_COMPLETING_A_QUEST"]                 = "Muestra notificación al completar una misión."
L["PRESENCE_SHOW_WORLD_QUEST_COMPLETE"]                       = "Mostrar misión de mundo completada"
L["PRESENCE_NOTIFICATION_COMPLETING_A_WORLD_QUEST"]           = "Muestra notificación al completar una misión de mundo."
L["PRESENCE_QUEST_PROGRESS"]                                  = "Mostrar progreso de misiones"
L["PRESENCE_NOTIFICATION_QUEST_OBJECTIVES_UPDATE"]            = "Muestra notificación cuando se actualizan los objetivos."
L["PRESENCE_OBJECTIVE"]                                       = "Solo objetivo"
L["PRESENCE_QUEST_PROGRESS_HIDE_TITLE"]                       = "Muestra solo la línea del objetivo en las notificaciones de progreso, ocultando el título 'Actualización de misión'."
L["PRESENCE_SCENARIO_START"]                                  = "Mostrar inicio de escenario"
L["PRESENCE_NOTIFICATION_ENTERING_A_SCENARIO_DELVE"]          = "Muestra notificación al entrar en un escenario o Sima."
L["PRESENCE_SCENARIO_PROGRESS"]                               = "Mostrar progreso de escenario"
L["PRESENCE_NOTIFICATION_SCENARIO_DELVE_OBJECTIVES"]          = "Muestra notificación cuando se actualizan objetivos de escenario o Sima."
L["PRESENCE_ANIMATION"]                                       = "Animación"
L["PRESENCE_ENABLE_ANIMATIONS"]                               = "Activar animaciones"
L["PRESENCE_ENABLE_ENTRANCE_EXIT_ANIMATIONS_PRESENCE"]        = "Activa animaciones de entrada y salida para notificaciones."
L["PRESENCE_ENTRANCE_DURATION"]                               = "Duración de entrada"
L["PRESENCE_DURATION_OF_ENTRANCE_ANIMATION_SECONDS"]          = "Duración de la animación de entrada en segundos (0.2–1.5)."
L["PRESENCE_EXIT_DURATION"]                                   = "Duración de salida"
L["PRESENCE_DURATION_OF_EXIT_ANIMATION_SECONDS"]              = "Duración de la animación de salida en segundos (0.2–1.5)."
L["PRESENCE_HOLD_DURATION_SCALE"]                             = "Factor de duración de visualización"
L["PRESENCE_MULTIPLIER_LONG_NOTIFICATION_STAY"]               = "Multiplicador de cuánto tiempo permanece cada notificación en pantalla (0.5–2)."
-- L["PRESENCE_PREVIEW"]                                      = "Preview"
-- L["PRESENCE_PREVIEW_TOAST_TYPE"]                           = "Preview toast type"
-- L["PRESENCE_SELECT_A_TOAST_TYPE_PREVIEW"]                  = "Select a toast type to preview."
-- L["PRESENCE_SELECTED_TOAST_TYPE"]                          = "Show the selected toast type."
-- L["PRESENCE_PREVIEW_PRESENCE_TOAST_LAYOUTS_LIVE_OPEN"]     = "Preview Presence toast layouts live and open a detachable sample while adjusting other settings."
-- L["PRESENCE_OPEN_DETACHED_PREVIEW"]                        = "Open detached preview"
-- L["PRESENCE_OPEN_A_MOVABLE_PREVIEW_WINDOW_STAYS"]          = "Open a movable preview window that stays visible while you change other Presence settings."
-- L["PRESENCE_ANIMATE_PREVIEW"]                              = "Animate preview"
-- L["PRESENCE_PLAY_SELECTED_TOAST_ANIMATION_INSIDE_PREVIEW"] = "Play the selected toast animation inside this preview window."
-- L["PRESENCE_DETACHED_PREVIEW"]                             = "Detached preview"
-- L["PRESENCE_KEEP_OPEN_WHILE_ADJUSTING_TYPOGRAPHY_COLOURS"] = "Keep this open while adjusting Typography or Colours."
L["DASH_TYPOGRAPHY"]                                          = "Tipografía"
L["PRESENCE_MAIN_TITLE_FONT"]                                 = "Fuente del título principal"
L["PRESENCE_FONT_FAMILY_MAIN_TITLE"]                          = "Familia de fuente para el título principal."
L["PRESENCE_SUBTITLE_FONT"]                                   = "Fuente del subtítulo"
L["PRESENCE_FONT_FAMILY_SUBTITLE"]                            = "Familia de fuente para el subtítulo."
L["PRESENCE_RESET_TYPOGRAPHY_DEFAULTS"]                       = "Reset typography to defaults"
-- L["PRESENCE_RESET_PRESENCE_TYPOGRAPHY_OPTIONS_FONTS_SIZES"]= "Reset all Presence typography options (fonts, sizes, colours) to defaults."
L["PRESENCE_LARGE_NOTIFICATIONS"]                             = "Large notifications"
L["PRESENCE_MEDIUM_NOTIFICATIONS"]                            = "Medium notifications"
L["PRESENCE_SMALL_NOTIFICATIONS"]                             = "Small notifications"
L["PRESENCE_LARGE_PRIMARY_SIZE"]                              = "Large primary size"
-- L["PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_TITLES_ZONE"]     = "Font size for large notification titles (zone, quest complete, achievement, etc.)."
L["PRESENCE_LARGE_SECONDARY_SIZE"]                            = "Large secondary size"
-- L["PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_SUBTITLES"]       = "Font size for large notification subtitles."
L["PRESENCE_MEDIUM_PRIMARY_SIZE"]                             = "Medium primary size"
-- L["PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_TITLES_QUEST"]   = "Font size for medium notification titles (quest accept, subzone, scenario)."
L["PRESENCE_MEDIUM_SECONDARY_SIZE"]                           = "Medium secondary size"
-- L["PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_SUBTITLES"]      = "Font size for medium notification subtitles."
L["PRESENCE_SMALL_PRIMARY_SIZE"]                              = "Small primary size"
-- L["PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_TITLES_QUEST"]    = "Font size for small notification titles (quest progress, achievement progress)."
L["PRESENCE_SMALL_SECONDARY_SIZE"]                            = "Small secondary size"
-- L["PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_SUBTITLES"]       = "Font size for small notification subtitles."

-- =====================================================================
-- OptionsData.lua Dropdown options — Outline
-- =====================================================================
L["FOCUS_OUTLINE_NONE"]                                       = "Ninguno"
L["FOCUS_THICK_OUTLINE"]                                      = "Contorno grueso"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["FOCUS_HIGHLIGHT_BAR_LEFT_EDGE"]                            = "Barra (borde izquierdo)"
L["FOCUS_HIGHLIGHT_BAR_RIGHT_EDGE"]                           = "Barra (borde derecho)"
L["FOCUS_HIGHLIGHT_BAR_TOP_EDGE"]                             = "Barra (borde superior)"
L["FOCUS_HIGHLIGHT_BAR_BOTTOM_EDGE"]                          = "Barra (borde inferior)"
L["FOCUS_HIGHLIGHT_OUTLINE_ONLY"]                             = "Solo contorno"
L["FOCUS_HIGHLIGHT_SOFT_GLOW"]                                = "Brillo suave"
L["FOCUS_HIGHLIGHT_DUAL_EDGE_BARS"]                           = "Barras dobles"
L["FOCUS_HIGHLIGHT_PILL_LEFT_ACCENT"]                         = "Acento píldora izquierdo"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["FOCUS_MYTHICPLUS_POSITION_TOP"]                            = "Arriba"
L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"]                         = "Abajo"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["VISTA_LOCATION_POSITION"]                                  = "Posición del nombre de zona"
L["VISTA_PLACE_ZONE_NAME_ABOVE_BELOW_MINIMAP"]                = "Coloca el nombre de zona encima o debajo del minimapa."
L["VISTA_COORDINATES_POSITION"]                               = "Posición de coordenadas"
L["VISTA_PLACE_COORDINATES_ABOVE_BELOW_MINIMAP"]              = "Coloca las coordenadas encima o debajo del minimapa."
L["VISTA_CLOCK_POSITION"]                                     = "Posición del reloj"
L["VISTA_PLACE_CLOCK_ABOVE_BELOW_MINIMAP"]                    = "Coloca el reloj encima o debajo del minimapa."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["FOCUS_TEXT_LOWER_CASE"]                                    = "Minúsculas"
L["FOCUS_TEXT_UPPER_CASE"]                                    = "Mayúsculas"
L["FOCUS_TEXT_PROPER_CASE"]                                   = "Primera letra mayúscula"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["FOCUS_TRACKED_LOG"]                                        = "Seguidas / En registro"
L["FOCUS_LOG_MAX_SLOTS"]                                      = "En registro / Máx. ranuras"

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["FOCUS_ALPHABETICAL"]                                       = "Alfabético"
L["FOCUS_QUEST_TYPE"]                                         = "Tipo de misión"
L["FOCUS_QUEST_LEVEL"]                                        = "Nivel de misión"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["FOCUS_CUSTOM"]                                             = "Personalizado"
L["FOCUS_ORDER"]                                              = "Orden"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["UI_DUNGEON"]                                               = "MAZMORRA"
L["UI_RAID"]                                                  = "BANDA"
L["UI_DELVES"]                                                = "SIMAS"
L["UI_SCENARIO_EVENTS"]                                       = "EVENTOS DE ESCENARIO"
-- L["UI_STAGE"]                                              = "Stage"
-- L["UI_STAGE_X_X"]                                          = "Stage %d: %s"
L["UI_AVAILABLE_IN_ZONE"]                                     = "DISPONIBLE EN LA ZONA"
L["UI_EVENTS_IN_ZONE"]                                        = "Eventos en la zona"
L["UI_CURRENT_EVENT"]                                         = "Evento actual"
L["UI_CURRENT_QUEST"]                                         = "MISIÓN ACTUAL"
L["UI_CURRENT_ZONE"]                                          = "ZONA ACTUAL"
L["UI_CAMPAIGN"]                                              = "CAMPAÑA"
L["UI_IMPORTANT"]                                             = "IMPORTANTE"
L["UI_LEGENDARY"]                                             = "LEGENDARIA"
L["UI_WORLD_QUESTS"]                                          = "MISIONES DE MUNDO"
L["UI_WEEKLY_QUESTS"]                                         = "MISIONES SEMANALES"
L["UI_PREY"]                                                  = "Presa"
L["UI_ABUNDANCE"]                                             = "Abundancia"
L["UI_ABUNDANCE_BAG"]                                         = "Bolsa de abundancia"
L["UI_ABUNDANCE_HELD"]                                        = "abundancia retenida"
L["UI_DAILY_QUESTS"]                                          = "MISIONES DIARIAS"
L["UI_RARE_BOSSES"]                                           = "JEFES RAROS"
L["UI_ACHIEVEMENTS"]                                          = "LOGROS"
L["UI_ENDEAVORS"]                                             = "EMPEÑOS"
L["UI_DECOR"]                                                 = "DECORACIÓN"
-- L["UI_RECIPES"]                                            = "Recipes"
-- L["UI_ADVENTURE_GUIDE"]                                    = "Adventure Guide"
-- L["UI_APPEARANCES"]                                        = "Appearances"
L["UI_QUESTS"]                                                = "MISIONES"
L["UI_READY_TO_TURN_IN"]                                      = "LISTAS PARA ENTREGAR"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["PRESENCE_OBJECTIVES"]                                      = "OBJETIVOS"
L["PRESENCE_OPTIONS"]                                         = "Opciones"
L["PRESENCE_OPEN_HORIZON_SUITE"]                              = "Abrir Horizon Suite"
L["PRESENCE_OPEN_FULL_HORIZON_SUITE_OPTIONS"]                 = "Abre el panel de opciones completo para configurar Focus, Presence, Vista y otros módulos."
L["PRESENCE_MINIMAP_SECTION"]                                 = "Minimap icon"
L["PRESENCE_SHOW_MINIMAP_ICON"]                               = "Mostrar icono en el minimapa"
L["PRESENCE_A_CLICKABLE_ICON_MINIMAP_OPENS"]                  = "Muestra un icono clicable en el minimapa que abre el panel de opciones."
L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER"]         = "Fade until minimap hover"
-- L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER_DESC"] = "When on, the icon stays faded until you move the cursor over the minimap. When off, it stays fully visible."
L["PRESENCE_LOCK_MINIMAP_BUTTON_POSITION"]                    = "Lock minimap button position"
-- L["PRESENCE_PREVENT_DRAGGING_HORIZON_MINIMAP_BUTTON"]      = "Prevent dragging the Horizon minimap button."
L["PRESENCE_RESET_MINIMAP_BUTTON_POSITION"]                   = "Reset minimap button position"
-- L["PRESENCE_RESET_MINIMAP_BUTTON_DEFAULT_POSITION"]        = "Reset the minimap button to the default position (bottom-left)."
-- L["PRESENCE_DRAG_TO_MOVE_WHEN_UNLOCKED"]                   = "Drag to move (when unlocked)."
-- L["PRESENCE_LOCKED"]                                       = "Locked"
L["PRESENCE_DISCOVERED"]                                      = "Descubierto"
L["PRESENCE_REFRESH"]                                         = "Actualizar"
L["PRESENCE_BEST_EFFORT_UNACCEPTED_QUESTS_EXPO"]              = "Solo aproximado. Algunas misiones no aceptadas no aparecen hasta interactuar con PNJs o cumplir condiciones de fase."
L["PRESENCE_UNACCEPTED_QUESTS_X_MAP_X"]                       = "Misiones no aceptadas - %s (mapa %s) - %d coincidencia(s)"
L["PRESENCE_LEVEL_UP"]                                        = "SUBIDA DE NIVEL"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_80"]                       = "Has alcanzado el nivel 80"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_X"]                        = "Has alcanzado el nivel %s"
L["PRESENCE_ACHIEVEMENT_EARNED"]                              = "LOGRO OBTENIDO"
L["PRESENCE_EXPLORING_THE_MIDNIGHT_ISLES"]                    = "Explorando las Islas de Medianoche"
L["PRESENCE_EXPLORING_KHAZ_ALGAR"]                            = "Explorando Khaz Algar"
L["PRESENCE_QUEST_COMPLETE"]                                  = "MISIÓN COMPLETADA"
L["PRESENCE_OBJECTIVE_SECURED"]                               = "Objetivo asegurado"
L["PRESENCE_AIDING_THE_ACCORD"]                               = "Ayudando al Acuerdo"
L["PRESENCE_WORLD_QUEST"]                                     = "MISIÓN DE MUNDO"
L["PRESENCE_WORLD_QUEST_COMPLETE"]                            = "MISIÓN DE MUNDO COMPLETADA"
L["PRESENCE_AZERITE_MINING"]                                  = "Minería de azerita"
L["PRESENCE_WORLD_QUEST_ACCEPTED"]                            = "MISIÓN DE MUNDO ACEPTADA"
L["PRESENCE_QUEST_ACCEPTED"]                                  = "MISIÓN ACEPTADA"
L["PRESENCE_THE_FATE_OF_THE_HORDE"]                           = "El Destino de la Horda"
L["PRESENCE_NEW_QUEST"]                                       = "Nueva misión"
L["PRESENCE_QUEST_UPDATE"]                                    = "ACTUALIZACIÓN DE MISIÓN"
L["PRESENCE_BOAR_PELTS_7_10"]                                 = "Pieles de jabalí: 7/10"
L["PRESENCE_DRAGON_GLYPHS_3_5"]                               = "Glifos de dragón: 3/5"
L["PRESENCE_TEST_COMMANDS"]                                   = "Comandos de prueba de Presencia:"
-- L["PRESENCE_H_DEBUGTYPES_DUMP_NOTIFICATION"]               = "  /h presence debugtypes - Dump notification toggles and Blizzard suppression state"
-- L["PRESENCE_PLAYING_DEMO_REEL_NOTIFICATION"]               = "Presence: Playing demo reel (all notification types)..."
L["PRESENCE_H_HELP_TEST_CURRENT"]                             = "  /h presence         - Mostrar ayuda + probar zona actual"
L["PRESENCE_H_ZONE_TEST"]                                     = "  /h presence zone     - Probar cambio de zona"
L["PRESENCE_H_SUBZONE_TEST"]                                  = "  /h presence subzone  - Probar cambio de subzona"
L["PRESENCE_H_DISCOVER_TEST_ZONE"]                            = "  /h presence discover - Probar descubrimiento de zona"
L["PRESENCE_H_LEVEL_TEST"]                                    = "  /h presence level    - Probar subida de nivel"
L["PRESENCE_H_BOSS_TEST"]                                     = "  /h presence boss     - Probar emote de jefe"
L["PRESENCE_H_ACHIEVEMENT_TEST"]                              = "  /h presence ach      - Probar logro"
L["PRESENCE_H_ACCEPT_TEST_QUEST"]                             = "  /h presence accept   - Probar misión aceptada"
L["PRESENCE_H_WORLD_QUEST_ACCEPT_TEST"]                       = "  /h presence wqaccept - Probar misión de mundo aceptada"
L["PRESENCE_H_SCENARIO_TEST"]                                 = "  /h presence scenario - Probar inicio de escenario"
L["PRESENCE_H_QUEST_TEST_COMPLETE"]                           = "  /h presence quest    - Probar misión completada"
L["PRESENCE_H_WORLD_QUEST_TEST"]                              = "  /h presence wq       - Probar misión de mundo"
L["PRESENCE_H_QUEST_UPDATE_TEST"]                             = "  /h presence update   - Probar actualización de misión"
L["PRESENCE_H_ACHIEVEMENT_PROGRESS_TEST"]                     = "  /h presence achprogress - Probar progreso de logro"
L["PRESENCE_H_DEMO_REEL_TYPES"]                               = "  /h presence all      - Demostración (todos los tipos)"
L["PRESENCE_H_DEBUG_DUMP_STATE"]                              = "  /h presence debug    - Volcar estado al chat"
L["PRESENCE_H_DEBUGLIVE_TOGGLE_LIVE"]                         = "  /h presence debuglive - Activar/desactivar panel de depuración en vivo (registrar eventos)"

-- =====================================================================
-- OptionsData.lua Vista — General
L["VISTA_POSITION_LAYOUT"]                                    = "Position & layout"

-- =====================================================================
L["VISTA_DESC"]                                               = "Minimapa"
L["VISTA_SIZE"]                                               = "Tamaño del minimapa"
L["VISTA_WIDTH_HEIGHT_OF_MINIMAP_PIXELS"]                     = "Ancho y alto del minimapa en píxeles (100–400)."
L["VISTA_CIRCULAR_MINIMAP"]                                   = "Minimapa circular"
L["VISTA_CIRCULAR_SHAPE"]                                     = "Circular shape"
L["VISTA_A_CIRCULAR_MINIMAP_INSTEAD_OF_SQUARE"]               = "Usa un minimapa circular en lugar de cuadrado."
L["VISTA_LOCK_MINIMAP_POSITION"]                              = "Bloquear posición del minimapa"
L["VISTA_PREVENT_DRAGGING_MINIMAP"]                           = "Impide arrastrar el minimapa."
L["VISTA_RESET_MINIMAP_POSITION"]                             = "Restablecer posición del minimapa"
L["VISTA_RESET_MINIMAP_DEFAULT_POSITION_TOP_RIGHT"]           = "Restablece el minimapa a su posición por defecto (arriba derecha)."
L["VISTA_RESET_OVERLAY_POSITIONS"]                            = "Reset overlay positions to defaults"
L["VISTA_RESET_OVERLAY_POSITIONS_DESC"]                       = "Clear saved positions for zone text, coordinates, clock, performance and difficulty text, zoom buttons, tracking, calendar, queue, mail, the addon button bar, drawer button, and right-click panel. The minimap frame position is not changed."
L["VISTA_AUTO_ZOOM"]                                          = "Zoom automático"
L["VISTA_AUTO_ZOOM_DELAY"]                                    = "Retraso de zoom automático"
L["VISTA_SECONDS_AFTER_ZOOMING_BEFORE_AUTO_ZOOM"]             = "Segundos tras hacer zoom antes del zoom automático. Pon 0 para desactivar."

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["VISTA_ZONE_TEXT_HEADER"]                                   = "Texto de zona"
L["VISTA_ZONE_FONT"]                                          = "Fuente de zona"
L["VISTA_FONT_ZONE_NAME_BELOW_MINIMAP"]                       = "Fuente del nombre de zona debajo del minimapa."
L["VISTA_ZONE_FONT_SIZE"]                                     = "Tamaño de fuente de zona"
L["VISTA_ZONE_TEXT_COLOUR"]                                   = "Colour del texto de zona"
L["VISTA_COLOUR_OF_ZONE_NAME_TEXT"]                           = "Colour del texto del nombre de zona."
L["VISTA_COORDINATES_TEXT"]                                   = "Texto de coordenadas"
L["VISTA_COORDINATES_FONT"]                                   = "Fuente de coordenadas"
L["VISTA_FONT_COORDINATES_TEXT_BELOW_MINIMAP"]                = "Fuente del texto de coordenadas debajo del minimapa."
L["VISTA_COORDINATES_FONT_SIZE"]                              = "Tamaño de fuente de coordenadas"
L["VISTA_COORDINATES_TEXT_COLOUR"]                            = "Colour del texto de coordenadas"
L["VISTA_COLOUR_OF_COORDINATES_TEXT"]                         = "Colour del texto de coordenadas."
L["VISTA_COORDINATE_PRECISION"]                               = "Precisión de coordenadas"
L["VISTA_NUMBER_OF_DECIMAL_PLACES_SHOWN_X"]                   = "Número de decimales mostrados para coordenadas X e Y."
L["VISTA_COORDS_DECIMALS_OFF"]                                = "Sin decimales (ej. 52, 37)"
L["VISTA_DECIMAL_E_G"]                                        = "1 decimal (ej. 52.3, 37.1)"
L["VISTA_DECIMALS_E_G"]                                       = "2 decimales (ej. 52.34, 37.12)"
L["VISTA_TEXT"]                                               = "Texto de hora"
L["VISTA_FONT"]                                               = "Fuente de hora"
L["VISTA_FONT_TEXT_BELOW_MINIMAP"]                            = "Fuente del texto de hora debajo del minimapa."
L["VISTA_FONT_SIZE"]                                          = "Tamaño de fuente de hora"
L["VISTA_TEXT_COLOUR"]                                        = "Colour del texto de hora"
L["VISTA_COLOUR_OF_TEXT"]                                     = "Colour del texto de hora."
-- L["VISTA_PERFORMANCE_TEXT"]                                = "Performance Text"
L["VISTA_PERFORMANCE_FONT"]                                   = "Performance font"
-- L["VISTA_FONT_FPS_LATENCY_TEXT_BELOW_MINIMAP"]             = "Font for the FPS and latency text below the minimap."
L["VISTA_PERFORMANCE_FONT_SIZE"]                              = "Performance font size"
L["VISTA_PERFORMANCE_TEXT_COLOUR"]                            = "Performance text colour"
-- L["VISTA_COLOUR_OF_FPS_LATENCY_TEXT"]                      = "Colour of the FPS and latency text."
L["VISTA_DIFFICULTY_TEXT"]                                    = "Texto de dificultad"
L["VISTA_DIFFICULTY_TEXT_COLOUR_FALLBACK"]                    = "Colour del texto de dificultad (reserva)"
L["VISTA_DEFAULT_COLOUR_PER_DIFFICULTY_COLOUR"]               = "Colour por defecto cuando no hay colour por dificultad."
L["VISTA_DIFFICULTY_FONT"]                                    = "Fuente de dificultad"
L["VISTA_FONT_INSTANCE_DIFFICULTY_TEXT"]                      = "Fuente del texto de dificultad de instancia."
L["VISTA_DIFFICULTY_FONT_SIZE"]                               = "Tamaño de fuente de dificultad"
L["VISTA_PER_DIFFICULTY_COLOURS"]                             = "Colores por dificultad"
L["VISTA_MYTHIC_COLOUR"]                                      = "Colour Mítico"
L["VISTA_COLOUR_MYTHIC_DIFFICULTY_TEXT"]                      = "Colour del texto de dificultad Mítico."
L["VISTA_HEROIC_COLOUR"]                                      = "Colour Heroico"
L["VISTA_COLOUR_HEROIC_DIFFICULTY_TEXT"]                      = "Colour del texto de dificultad Heroico."
L["VISTA_NORMAL_COLOUR"]                                      = "Colour Normal"
L["VISTA_COLOUR_NORMAL_DIFFICULTY_TEXT"]                      = "Colour del texto de dificultad Normal."
L["VISTA_LFR_COLOUR"]                                         = "Colour LFR"
L["VISTA_COLOUR_LOOKING_RAID_DIFFICULTY_TEXT"]                = "Colour del texto de dificultad Búsqueda de banda."

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["VISTA_TEXT_ELEMENTS"]                                      = "Elementos de texto"
L["VISTA_ZONE_TEXT"]                                          = "Mostrar texto de zona"
L["VISTA_ZONE_NAME_BELOW_MINIMAP"]                            = "Muestra el nombre de zona debajo del minimapa."
L["VISTA_ZONE_TEXT_DISPLAY_MODE"]                             = "Modo de visualización del texto de zona"
L["VISTA_WHAT_ZONE_SUBZONE"]                                  = "Qué mostrar: solo zona, solo subzona o ambos."
L["VISTA_SHOW_ZONE"]                                          = "Solo zona"
L["VISTA_SHOW_SUBZONE"]                                       = "Solo subzona"
L["VISTA_SHOW_ZONE_AND_SUBZONE"]                              = "Ambos"
L["VISTA_COORDINATES"]                                        = "Mostrar coordenadas"
L["VISTA_PLAYER_COORDINATES_BELOW_MINIMAP"]                   = "Muestra las coordenadas del jugador debajo del minimapa."
L["VISTA_TIME"]                                               = "Mostrar hora"
L["VISTA_CURRENT_GAME_BELOW_MINIMAP"]                         = "Muestra la hora actual del juego debajo del minimapa."
L["VISTA_HOUR_CLOCK"]                                         = "24-hour clock"
-- L["VISTA_DISPLAY_HOUR_FORMAT_24"]                          = "Display time in 24-hour format (e.g. 14:30 instead of 2:30 PM)."
L["VISTA_LOCAL_TIME"]                                         = "Usar hora local"
L["VISTA_LOCAL_TIME_TIP"]                                     = "Activado: muestra la hora local del sistema. Desactivado: muestra la hora del servidor."
L["VISTA_FPS_LATENCY"]                                        = "Show FPS and latency"
-- L["VISTA_FPS_LATENCY_MS_BELOW_MINIMAP"]                    = "Show FPS and latency (ms) below the minimap."
L["VISTA_MINIMAP_BUTTONS"]                                    = "Botones del minimapa"
L["VISTA_QUEUE_STATUS_MAIL_INDICATOR_ALWAYS_SHOWN"]           = "El estado de cola y el indicador de correo se muestran cuando son relevantes."
L["VISTA_TRACKING_BUTTON"]                                    = "Mostrar botón de seguimiento"
L["VISTA_MINIMAP_TRACKING_BUTTON"]                            = "Muestra el botón de seguimiento en el minimapa."
L["VISTA_TRACKING_BUTTON_MOUSEOVER"]                          = "Botón de seguimiento solo al pasar el ratón"
L["VISTA_HIDE_TRACKING_BUTTON_UNTIL_YOU_HOVER"]               = "Oculta el botón de seguimiento hasta pasar el ratón sobre el minimapa."
L["VISTA_CALENDAR_BUTTON"]                                    = "Mostrar botón de calendario"
L["VISTA_MINIMAP_CALENDAR_BUTTON"]                            = "Muestra el botón de calendario en el minimapa."
L["VISTA_CALENDAR_BUTTON_MOUSEOVER"]                          = "Botón de calendario solo al pasar el ratón"
L["VISTA_HIDE_CALENDAR_BUTTON_UNTIL_YOU_HOVER"]               = "Oculta el botón de calendario hasta pasar el ratón sobre el minimapa."
L["VISTA_ZOOM_BUTTONS"]                                       = "Mostrar botones de zoom"
L["VISTA_ZOOM_BUTTONS_MINIMAP"]                               = "Muestra los botones de zoom + y - en el minimapa."
L["VISTA_ZOOM_BUTTONS_MOUSEOVER"]                             = "Botones de zoom solo al pasar el ratón"
L["VISTA_HIDE_ZOOM_BUTTONS_UNTIL_YOU_HOVER"]                  = "Oculta los botones de zoom hasta pasar el ratón sobre el minimapa."

-- =====================================================================
-- OptionsData.lua Vista — Display (Border / Text Positions / Buttons)
-- =====================================================================
L["VISTA_BORDER"]                                             = "Borde"
L["VISTA_BORDER_TIP"]                                         = "Muestra un borde alrededor del minimapa."
L["VISTA_BORDER_COLOUR"]                                      = "Colour del borde"
L["VISTA_COLOUR_OPACITY_OF_MINIMAP_BORDER"]                   = "Colour (y opacidad) del borde del minimapa."
L["VISTA_BORDER_THICKNESS"]                                   = "Grosor del borde"
L["VISTA_THICKNESS_OF_MINIMAP_BORDER_PIXELS"]                 = "Grosor del borde del minimapa en píxeles (1–8)."
-- L["VISTA_CLASS_COLOURS"]                                   = "Class colours"
-- L["VISTA_TINT_VISTA_BORDER_TEXT_COORDS_FPS"]               = "Tint Vista border and text (coords, time, FPS/MS labels) with your class colour. Numbers use the configured colour."
L["VISTA_TEXT_POSITIONS"]                                     = "Posiciones del texto"
L["VISTA_DRAG_TEXT_ELEMENTS_REPOSITION_LOCK_PREVEN"]          = "Arrastra elementos de texto para reposicionarlos. Bloquea para evitar movimientos accidentales."
L["VISTA_LOCK_ZONE_TEXT_POSITION"]                            = "Bloquear posición del texto de zona"
L["VISTA_ZONE_TEXT_CANNOT_DRAGGED"]                           = "Activado: el texto de zona no se puede arrastrar."
L["VISTA_LOCK_COORDINATES_POSITION"]                          = "Bloquear posición de coordenadas"
L["VISTA_COORDINATES_TEXT_CANNOT_DRAGGED"]                    = "Activado: el texto de coordenadas no se puede arrastrar."
L["VISTA_LOCK_POSITION"]                                      = "Bloquear posición de la hora"
L["VISTA_TEXT_CANNOT_DRAGGED"]                                = "Activado: el texto de hora no se puede arrastrar."
L["VISTA_PERFORMANCE_TEXT_POSITION"]                          = "Performance text position"
-- L["VISTA_PLACE_FPS_LATENCY_TEXT_ABOVE_BELOW"]              = "Place the FPS/latency text above or below the minimap."
L["VISTA_LOCK_PERFORMANCE_TEXT_POSITION"]                     = "Lock performance text position"
-- L["VISTA_FPS_LATENCY_TEXT_CANNOT_DRAGGED"]                 = "When on, the FPS/latency text cannot be dragged."
L["VISTA_DIFFICULTY_TEXT_POSITION"]                           = "Difficulty text position"
-- L["VISTA_PLACE_DIFFICULTY_TEXT_ABOVE_BELOW"]               = "Place the instance difficulty text above or below the minimap. It is positioned independently of zone text."
L["VISTA_LOCK_DIFFICULTY_TEXT_POSITION"]                      = "Bloquear posición del texto de dificultad"
L["VISTA_DIFFICULTY_TEXT_CANNOT_DRAGGED"]                     = "Activado: el texto de dificultad no se puede arrastrar."
L["VISTA_BUTTON_POSITIONS"]                                   = "Posiciones de botones"
L["VISTA_DRAG_BUTTONS_REPOSITION_LOCK_PREVENT_MOVE"]          = "Arrastra botones para reposicionarlos. Bloquea para impedir movimiento."
L["VISTA_LOCK_ZOOM_BUTTON"]                                   = "Bloquear botón Zoom +"
L["VISTA_PREVENT_DRAGGING_ZOOM_BUTTON"]                       = "Impide arrastrar el botón de zoom +."
L["VISTA_LOCK_ZOOM_OUT_BUTTON"]                               = "Bloquear botón Zoom -"
L["VISTA_LOCK_ZOOM_OUT_DRAG"]                                 = "Impide arrastrar el botón de zoom -."
L["VISTA_LOCK_TRACKING_BUTTON"]                               = "Bloquear botón de seguimiento"
L["VISTA_PREVENT_DRAGGING_TRACKING_BUTTON"]                   = "Impide arrastrar el botón de seguimiento."
L["VISTA_LOCK_CALENDAR_BUTTON"]                               = "Bloquear botón de calendario"
L["VISTA_PREVENT_DRAGGING_CALENDAR_BUTTON"]                   = "Impide arrastrar el botón de calendario."
L["VISTA_LOCK_QUEUE_BUTTON"]                                  = "Bloquear botón de cola"
L["VISTA_PREVENT_DRAGGING_QUEUE_STATUS_BUTTON"]               = "Impide arrastrar el botón de estado de cola."
L["VISTA_LOCK_MAIL_INDICATOR"]                                = "Bloquear indicador de correo"
L["VISTA_PREVENT_DRAGGING_MAIL_ICON"]                         = "Impide arrastrar el icono de correo."
-- L["VISTA_LOCK_CRAFTING_ORDER_INDICATOR"]                   = "Lock Crafting Order Indicator"
-- L["VISTA_PREVENT_DRAGGING_CRAFTING_ORDER_ICON"]            = "Prevent dragging the crafting order icon."
L["VISTA_DISABLE_QUEUE_HANDLING"]                             = "Disable queue handling"
L["VISTA_DISABLE_QUEUE_BUTTON_HANDLING"]                      = "Desactivar gestión del botón de cola"
L["VISTA_TURN_QUEUE_BUTTON_ANCHORING_OFF_ADDON_CONFLICT"]     = "Desactiva todo el anclaje del botón de cola (usa si otro addon lo gestiona)."
L["VISTA_BUTTON_SIZES"]                                       = "Tamaños de botones"
L["VISTA_ADJUST_SIZE_OF_MINIMAP_OVERLAY_BUTTONS"]             = "Ajusta el tamaño de los botones superpuestos del minimapa."
L["VISTA_TRACKING_BUTTON_SIZE"]                               = "Tamaño del botón de seguimiento"
L["VISTA_SIZE_OF_TRACKING_BUTTON_PIXELS"]                     = "Tamaño del botón de seguimiento (píxeles)."
L["VISTA_CALENDAR_BUTTON_SIZE"]                               = "Tamaño del botón de calendario"
L["VISTA_SIZE_OF_CALENDAR_BUTTON_PIXELS"]                     = "Tamaño del botón de calendario (píxeles)."
L["VISTA_QUEUE_BUTTON_SIZE"]                                  = "Tamaño del botón de cola"
L["VISTA_SIZE_OF_QUEUE_STATUS_BUTTON_PIXELS"]                 = "Tamaño del botón de estado de cola (píxeles)."
L["VISTA_ZOOM_BUTTON_SIZE"]                                   = "Tamaño de los botones de zoom"
L["VISTA_SIZE_OF_ZOOM_ZOOM_BUTTONS_PIXELS"]                   = "Tamaño de los botones de zoom + / zoom - (píxeles)."
L["VISTA_MAIL_INDICATOR_SIZE"]                                = "Tamaño del indicador de correo"
L["VISTA_SIZE_OF_MAIL_ICON_PIXELS"]                           = "Tamaño del icono de correo nuevo (píxeles)."
-- L["VISTA_CRAFTING_ORDER_INDICATOR_SIZE"]                   = "Crafting Order Indicator Size"
-- L["VISTA_SIZE_OF_CRAFTING_ORDER_ICON_PIXELS"]              = "Size of the crafting order icon (pixels)."
L["VISTA_ADDON_BUTTON_SIZE"]                                  = "Tamaño de botones de addons"
L["VISTA_SIZE_OF_COLLECTED_ADDON_MINIMAP_BUTTONS"]            = "Tamaño de los botones de addons recopilados en el minimapa (píxeles)."

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
L["VISTA_COLLECT_HORIZON_MINIMAP"]                            = "Include Horizon minimap icon"
-- L["VISTA_COLLECT_HORIZON_MINIMAP_DESC"]                    = "Put Horizon's own minimap icon in the managed addon bar, right-click panel, or drawer instead of leaving it on the minimap edge."
-- L["VISTA_SORT_BUTTONS_ALPHA"]                              = "Sort Buttons Alphabetically"
-- L["VISTA_SORT_BUTTONS_ALPHA_DESC"]                         = "Sort collected addon minimap buttons alphabetically by name."
-- L["VISTA_ADDON_BUTTONS"]                                   = "Addon Buttons"
L["VISTA_MINIMAP_ADDON_BUTTONS"]                              = "Botones de addons del minimapa"
L["VISTA_BUTTON_MANAGEMENT"]                                  = "Gestión de botones"
L["VISTA_MANAGE_ADDON_MINIMAP_BUTTONS"]                       = "Gestionar botones de addons del minimapa"
L["VISTA_TAKES_CONTROL_OF_ADDON_MINIMAP"]                     = "Activado: Vista toma el control de los botones de addons y los agrupa según el modo seleccionado."
L["VISTA_BUTTON_MODE"]                                        = "Modo de botones"
L["VISTA_ADDON_BUTTONS_PRESENTED_HOVER_BAR_BELOW"]            = "Cómo se presentan los botones: barra al pasar el ratón, panel al clic derecho o botón de cajón flotante."
L["VISTA_ALWAYS_BAR"]                                         = "Always show bar"
-- L["VISTA_ALWAYS_MOUSEOVER_BAR_POSITIONING"]                = "Always show mouseover bar (for positioning)"
-- L["VISTA_KEEP_MOUSEOVER_BAR_VISIBLE_TIMES_YOU"]            = "Keep the mouseover bar visible at all times so you can reposition it. Disable when done."
-- L["VISTA_DISABLE_DONE"]                                    = "Disable when done."
L["VISTA_MOUSEOVER_BAR"]                                      = "Barra al pasar el ratón"
L["VISTA_RIGHT_CLICK_PANEL"]                                  = "Panel clic derecho"
L["VISTA_FLOATING_DRAWER"]                                    = "Cajón flotante"
-- L["VISTA_DRAWER_BUTTON_ICON"]                              = "Drawer button icon"
L["VISTA_DRAWER_BUTTON_ICON_DESC"]                            = "Enter a Blizzard icon file ID or texture path. Leave blank to use the default drawer icon."
-- L["VISTA_CHOOSE_ICON"]                                     = "Choose icon"
L["VISTA_CHOOSE_DRAWER_ICON"]                                 = "Choose Drawer Icon"
L["VISTA_LOCK_DRAWER_BUTTON_POSITION"]                        = "Bloquear posición del botón del cajón"
L["VISTA_PREVENT_DRAGGING_FLOATING_DRAWER_BUTTON"]            = "Impide arrastrar el botón del cajón flotante."
L["VISTA_LOCK_MOUSEOVER_BAR_POSITION"]                        = "Bloquear posición de la barra al pasar el ratón"
L["VISTA_PREVENT_DRAGGING_MOUSEOVER_BUTTON_BAR"]              = "Impide arrastrar la barra de botones al pasar el ratón."
L["VISTA_LOCK_RIGHT_CLICK_PANEL_POSITION"]                    = "Bloquear posición del panel clic derecho"
L["VISTA_PREVENT_DRAGGING_RIGHT_CLICK_PANEL"]                 = "Impide arrastrar el panel de clic derecho."
L["VISTA_BUTTONS_PER_ROW_COLUMN"]                             = "Botones por fila/columna"
L["VISTA_CONTROLS_MANY_BUTTONS_APPEAR_BEFORE_WRAPPING"]       = "Controla cuántos botones aparecen antes de envolver. Izquierda/derecha: columnas; arriba/abajo: filas."
L["VISTA_EXPAND_DIRECTION"]                                   = "Dirección de expansión"
L["VISTA_DIRECTION_BUTTONS_FILL_ANCHOR_POINT_LEFT"]           = "Dirección de llenado desde el punto de anclaje. Izquierda/Derecha: filas horizontales. Arriba/Abajo: columnas verticales."
L["VISTA_BUTTONS_FILL_RIGHT"]                                 = "Derecha"
L["VISTA_BUTTONS_FILL_LEFT"]                                  = "Izquierda"
L["VISTA_BUTTONS_FILL_DOWN"]                                  = "Abajo"
L["VISTA_BUTTONS_FILL_UP"]                                    = "Arriba"
-- L["VISTA_MOUSEOVER_BAR_APPEARANCE"]                        = "Mouseover Bar Appearance"
L["VISTA_BACKGROUND_BORDER_MOUSEOVER_BUTTON_BAR"]             = "Background and border for the mouseover button bar."
L["VISTA_BACKDROP_COLOUR"]                                    = "Backdrop colour"
-- L["VISTA_BACKGROUND_COLOUR_OF_MOUSEOVER_BUTTON_BAR"]       = "Background colour of the mouseover button bar (use alpha to control transparency)."
L["VISTA_BAR_BORDER"]                                         = "Show bar border"
-- L["VISTA_A_BORDER_AROUND_MOUSEOVER_BUTTON_BAR"]            = "Show a border around the mouseover button bar."
L["VISTA_BAR_BORDER_COLOUR"]                                  = "Bar border colour"
-- L["VISTA_BORDER_COLOUR_OF_MOUSEOVER_BUTTON_BAR"]           = "Border colour of the mouseover button bar."
L["VISTA_BAR_BACKGROUND_COLOUR"]                              = "Bar background colour"
-- L["VISTA_PANEL_BACKGROUND_COLOUR"]                         = "Panel background colour."
-- L["VISTA_CLOSE_FADE_TIMING"]                               = "Close / Fade Timing"
-- L["VISTA_MOUSEOVER_BAR_CLOSE_DELAY_SECONDS"]               = "Mouseover bar — close delay (seconds)"
-- L["VISTA_LONG_SECONDS_BAR_STAYS_VISIBLE_AFTER"]            = "How long (in seconds) the bar stays visible after the cursor leaves. 0 = instant fade."
-- L["VISTA_RIGHT_CLICK_PANEL_CLOSE_DELAY_SECONDS"]           = "Right-click panel — close delay (seconds)"
-- L["VISTA_LONG_SECONDS_PANEL_STAYS_OPEN_AFTER"]             = "How long (in seconds) the panel stays open after the cursor leaves. 0 = never auto-close (close by right-clicking again)."
-- L["VISTA_FLOATING_DRAWER_CLOSE_DELAY_SECONDS"]             = "Floating drawer — close delay (seconds)"
L["VISTA_DRAWER_CLOSE_DELAY"]                                 = "Drawer close delay"
-- L["VISTA_LONG_SECONDS_DRAWER_PANEL_STAYS_OPEN"]            = "How long (in seconds) the drawer panel stays open after clicking away. 0 = never auto-close (close only by clicking the drawer button again)."
-- L["VISTA_MAIL_ICON_BLINK"]                                 = "Mail icon blink"
-- L["VISTA_MAIL_ICON_PULSES_DRAW_ATTENTION"]                 = "When on, the mail icon pulses to draw attention. When off, it stays at full opacity."
-- L["VISTA_CRAFTING_ORDER_ICON_PULSE"]                       = "Crafting Order Icon Pulse"
-- L["VISTA_CRAFTING_ORDER_ICON_PULSES_DRAW_ATTENTION"]       = "When on, the crafting order icon pulses to draw attention. When off, it stays at full opacity."
-- L["VISTA_CRAFTING_ORDER_TOOLTIP"]                          = "Personal Crafting Orders"
-- L["VISTA_CRAFTING_ORDER_PENDING_COUNT"]                    = "%d pending"
-- L["VISTA_CRAFTING_ORDER_PROFESSION_LINE"]                  = "  %s: %d"
L["VISTA_PANEL_APPEARANCE"]                                   = "Apariencia del panel"
L["VISTA_COLOURS_DRAWER_RIGHT_CLICK_BUTTON_PANELS"]           = "Colores para los paneles del cajón y clic derecho."
L["VISTA_PANEL_BG_COLOUR_LABEL"]                              = "Colour de fondo del panel"
L["VISTA_BACKGROUND_COLOUR_OF_ADDON_BUTTON_PANELS"]           = "Colour de fondo de los paneles de botones de addons."
L["VISTA_PANEL_BORDER_COLOUR"]                                = "Colour del borde del panel"
L["VISTA_BORDER_COLOUR_OF_ADDON_BUTTON_PANELS"]               = "Colour del borde de los paneles de botones de addons."
L["VISTA_MANAGED_BUTTONS"]                                    = "Botones gestionados"
L["VISTA_BUTTON_COMPLETELY_IGNORED"]                          = "Desactivado: este botón es ignorado por completo por este addon."
L["VISTA_ADDON_BUTTONS_DETECTED"]                             = "(Aún no se han detectado botones de addons)"
L["VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE"]                      = "Botones visibles (marca para incluir)"
L["VISTA_ADDON_BUTTONS_DETECTED_OPEN_YOUR_MINIMAP"]           = "(Aún no se han detectado botones de addons — abre primero tu minimapa)"

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






























































































































































