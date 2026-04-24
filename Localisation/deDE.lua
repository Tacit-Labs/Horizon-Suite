if GetLocale() ~= "deDE" then return end

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
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
-- L["NAME_ADDON_DASHBOARD"]                                  = "Axis"
-- L["NAME_DISCORD"]                                          = "Discord"
-- L["NAME_KO_FI"]                                            = "Ko-fi"
-- L["NAME_PATREON"]                                          = "Patreon"
L["NAME_GITHUB"]                                              = "GitLab"
-- L["NAME_CURSEFORGE"]                                       = "CurseForge"
-- L["NAME_WAGO"]                                             = "Wago"
-- L["NAME_TOMTOM"]                                           = "TomTom"
L["OTHER"]                                                    = "Andere"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["QUEST_TYPES"]                                              = "Quest-Typen"
L["ELEMENT_OVERRIDES"]                                        = "Elementübersteuerung"
L["PER_CATEGORY"]                                             = "Pro Kategorie"
L["GROUPING_OVERRIDES"]                                       = "Gruppenübersteuerung"
L["SECTION_OVERRIDES"]                                        = "Sektionübersteuerung"
L["OTHER_COLOURS"]                                            = "Weitere Farben"

-- =====================================================================
-- OptionsPanel.lua — Colour row labels (collapsible group sub-rows)
-- =====================================================================
L["FOCUS_SECTION"]                                            = "Abschnitt"
L["FOCUS_TITLE"]                                              = "Titel"
-- L["FOCUS_ZONE"]                                            = "Zone"
L["FOCUS_OBJECTIVE"]                                          = "Ziel"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["FOCUS_READY_TURN_OVERRIDES_BASE_COLOURS"]                  = "Abgabebereit überschreibt Basis-Farben"
L["FOCUS_READY_TURN_COLOURS_QUESTS"]                          = "Abgabebereite Quests verwenden ihre Farben in diesem Abschnitt."
L["FOCUS_CURRENT_ZONE_OVERRIDES_BASE_COLOURS"]                = "Aktuelle Zone überschreibt Basisfarben"
L["FOCUS_CURRENT_ZONE_SECTION_COLOURS"]                       = "Quests der aktuellen Zone verwenden ihre Farben in diesem Abschnitt."
L["FOCUS_CURRENT_QUEST_OVERRIDES_BASE_COLOURS"]               = "Aktuelle Quest überschreibt Basisfarben"
L["FOCUS_CURRENT_QUEST_SECTION_COLOURS"]                      = "Quests der aktuellen Quest verwenden ihre Farben in diesem Abschnitt."
L["FOCUS_DISTINCT_COLOUR_COMPLETED_OBJECTIVES"]               = "Abgeschlossene Ziele hervorheben"
L["FOCUS_COMPLETED_OBJECTIVES_COLOURS_CHANGE"]                = "An: abgeschlossene Ziele (z.B. 1/1) nutzen die Farbe unten. Aus: gleiche Farbe wie unvollständige Ziele."
L["FOCUS_COMPLETED_OBJECTIVE"]                                = "Abgeschlossenes Ziel"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["FOCUS_RESET"]                                              = "Zurücksetzen"
L["FOCUS_RESET_QUEST_TYPES"]                                  = "Quest-Typen zurücksetzen"
L["FOCUS_RESET_OVERRIDES"]                                    = "Übersteuerungen zurücksetzen"
L["FOCUS_RESET_DEFAULTS"]                                     = "Alle auf Standard zurücksetzen"
L["FOCUS_RESET_TO_DEFAULTS"]                                  = "Auf Standard zurücksetzen"
L["FOCUS_RESET_DEFAULT"]                                      = "Auf Standard zurücksetzen"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["FOCUS_SEARCH_SETTINGS"]                                    = "Einstellungen durchsuchen..."
L["SEARCH_FONTS"]                                             = "Schriftarten durchsuchen..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["FOCUS_DRAG_RESIZE"]                                        = "Zum Verändern der Größe ziehen"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
L["PROFILES"]                                                 = "Profile"
L["MODULES"]                                                  = "Module"
L["MODULE_TOGGLES"]                                           = "Modulsteuerung"
-- L["MODULE_PREVIEW_DISCLAIMER"]                             = "This module is currently in an early preview (alpha) state. Daily use is not advised due to bugs or unfinished functionality."
-- L["AXIS_MODULE_NAME_DISPLAY"]                              = "Module name style"
-- L["AXIS_MODULE_NAME_DISPLAY_DESC"]                         = "How module names appear in the settings panel navigation and search filter."
-- L["AXIS_MODULE_NAME_HORIZON"]                              = "Horizon"
-- L["AXIS_MODULE_NAME_SUBTITLE"]                             = "Subtitle"
-- L["AXIS_MODULE_NAME_SIMPLE"]                               = "Simple"
-- L["MODULE_RELOAD_HINT"]                                    = "Reload the interface to finish applying module changes."
-- L["RELOAD_UI"]                                             = "Reload UI"

-- =====================================================================
-- options/dashboard/HomeWelcome.lua — First-run welcome
-- =====================================================================
L["DASH_WHATS_NEW"]                                           = "Änderungen"
L["DASH_FULL_CHANGELOG"]                                      = "Versionshistorie"
L["DASH_WHATS_NEW_UNREAD_SUFFIX"]                             = " (Neu!)"
L["DASH_PATCH_NOTES_HEAD_SUB"]                                = "Versionsverlauf und aktuelle Änderungen"
L["DASH_PATCH_NOTES_EMPTY"]                                   = "Keine Patchnotes verfügbar."
L["DASH_WELCOME_TAB"]                                         = "Willkommen"
L["DASH_NEWS_TAB"]                                            = "Neuigkeiten"
-- L["DASH_SEARCH_TAB"]                                       = "Search"
-- L["DASH_SEARCH_HEAD_SUB"]                                  = "Find any setting quickly"
-- L["DASH_SEARCH_PLACEHOLDER"]                               = "Search settings..."
-- L["DASH_SEARCH_EMPTY_HINT"]                                = "Type at least two characters to search settings, modules, and options."
-- L["DASH_SEARCH_NO_RESULTS"]                                = "No matching settings. Try different words."
-- L["DASH_SEARCH_FILTER_ALL"]                                = "All"
-- L["DASH_SEARCH_FILTER_TOOLTIP"]                            = "Limit search to one module"
-- L["DASH_SEARCH_NO_RESULTS_IN_MODULE"]                      = "No matches in %s. Try All modules or different words."
L["DASH_NEWS_HEAD_SUB"]                                       = "Neueste Updates und Community-Highlights"
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
L["DASH_WELCOME_TITLE"]                                       = "Willkommen bei der Horizon Suite"
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
L["DASH_WELCOME_COMING_SOON_TITLE"]                           = "In Kürze"
-- L["DASH_WELCOME_COMING_SOON_TAGLINE"]                      = "New welcome experiences are on the way."
-- L["DASH_WELCOME_COMING_SOON_BODY"]                         = [=[Watch this space — we will post updates here and in |cffaaaaaaPatch Notes|r. Join |cffaaaaaaDiscord|r from the links below for news and feedback.]=]
L["DASH_WELCOME_CLASS_ICONS_HEADING"]                         = "Horizon class icons"
L["DASH_WELCOME_CLASS_ICONS_LEAD"]                            = [=[We have added a bundled set of custom class icons — now the default when you choose |cffaaaaaaHorizon|r under |cffaaaaaaAxis → Global Toggles|r (Class icon style).]=]
-- L["DASH_WELCOME_CLASS_ICONS_THANK_BOOFULS"]                = [=[Thank you, Boofuls, for commissioning this art and helping bring these icons to everyone.]=]
-- L["DASH_WELCOME_CLASS_ICONS_CREATED_PREFIX"]               = "• Created by "
-- L["DASH_WELCOME_CLASS_ICONS_ARTIST_NAME"]                  = "Gabriel C"
L["DASH_WELCOME_CONTRIBUTORS_HEADING"]                        = "Beitragende"
L["DASH_WELCOME_CONTRIBUTORS_BODY"]                           = [=[Thanks to everyone who has contributed to Horizon Suite:

• Feanor — Entwicklung
• Marthix — Entwicklung
• Swift — Koordinator
• Boofuls — Moderator
• Diva — Innovator
• Rondo Media (CurseForge addon)
• Aishuu — Französische Lokalisierung (frFR)
• 아즈샤라-두녘 — Koreanische Lokalisierung (koKR)
• Linho-Gallywix — Brazilian Portuguese localisation (ptBR)
• allmoon — Chinesische Lokalisierung (zhCN)]=]
L["DASH_WELCOME_SUPPORTERS_HEADING"]                          = "Unterstützer"
L["DASH_WELCOME_SUPPORTERS_BODY"]                             = [=[Vielen Dank an alle, die Horizon Suite über Ko-fi, Patreon und andere Wege unterstützen.]=]
L["DASH_WELCOME_LOCALISATIONS_HEADING"]                       = "Lokalisierungen"
L["DASH_WELCOME_LOCALISATIONS_BODY"]                          = [=[The options panel is localised for:

• Chinesisch (zhCN) — Localisation/zhCN.lua
• Französisch (frFR) — Localisation/frFR.lua
• Deutsch (deDE) — Localisation/deDE.lua
• Koreanisch (koKR) — Localisation/koKR.lua
• Brasilianisch-Portugiesisch (ptBR) — Localisation/ptBR.lua
• Russisch (ruRU) — Localisation/ruRU.lua
• Spanisch (esES) — Localisation/esES.lua

Contributions for additional locales are welcome via Discord.]=]


-- =====================================================================
-- options/dashboard/ModuleGuide.lua — In-game module quick-start
-- =====================================================================
L["DASH_GUIDE_TAB"]                                           = "Anleitung"
-- L["DASH_GUIDE_HEAD_SUB"]                                   = "What each part of Horizon does"
-- L["DASH_GUIDE_HERO_TITLE"]                                 = "Getting started with Horizon Suite"
L["DASH_GUIDE_HERO_TAGLINE"]                                  = "A modular UI toolkit for quests, notifications, the minimap, and more."
L["DASH_GUIDE_HERO_INTRO"]                                    = "Pick the modules you want, tune them in the sidebar, and reload when you toggle something on or off. This page is always here — open it anytime from the Guide row under Welcome."
-- L["DASH_GUIDE_HERO_THEME_PROMPT"]                          = [=[Under |cffaaaaaaAxis > Global Settings|r, set |cff73b4ff|Hhsdash:classcolours|hclass-colour tinting|h|r for the dashboard and modules, and pick a |cff73b4ff|Hhsdash:theme|hDashboard theme|h|r.]=]
L["DASH_GUIDE_HORIZON_HEADING"]                               = "Was ist die Horizon Suite?"
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
L["DASH_GUIDE_MOD_MERIDIAN_BODY"]                             = [=[Der genaue Leistungsumfang steht noch nicht fest; spekuliert ruhig mit, was sich für Horizon gut anfühlen würde. Wenn du mitdenken oder die Idee mitsteuern willst, komm in den |cffaaaaaaDiscord|r (Links unter Community & Support am unteren Rand des Dashboards) und sag uns, wofür du es nutzen würdest.]=]
L["DASH_AXIS_MODULE_SHORT_DESCRIPTION"]                       = "Core settings hub: profiles, modules, and global toggles."
-- L["DASH_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS"]            = "Objective tracker for quests, world quests, rares, achievements, scenarios."
-- L["DASH_ZONE_TEXT_AND_NOTIFICATIONS"]                      = "Zone text and notifications."
-- L["DASH_MINIMAP_ZONE_TEXT_COORDS_BUTTON"]                  = "Minimap with zone text, coords, time, and button collector."
-- L["DASH_TOOLTIPS_CLASS_COLOURS_SPEC_FACTION"]              = "Tooltips with class colours, spec, and faction icons."
-- L["DASH_LOOT_TOASTS_ITEMS_MONEY_CURRENCY"]                 = "Loot toasts for items, money, currency, reputation, and bag overhaul."
-- L["DASH_ESSENCE_MODULE_SHORT_DESCRIPTION"]                 = "Custom character sheet with 3D model, item level, stats, and gear grid."
L["DASH_MERIDIAN_MODULE_SHORT_DESCRIPTION"]                   = "Kompassartige Wegpunkte und Peilungen für Orientierung in der Welt — in Entwicklung."
-- L["DASH_WELCOME_COMMUNITY_HEADING"]                        = "Community & Support"
L["DASH_COPY_LINK_X"]                                         = "Link kopieren — %s"
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
-- L["DASH_LAYOUT"]                                           = "Layout"
L["DASH_VISIBILITY"]                                          = "Sichtbarkeit"
L["DASH_DISPLAY"]                                             = "Anzeige"
L["DASH_FEATURES"]                                            = "Funktionen"
L["DASH_TYPOGRAPHY"]                                          = "Typografie"
L["DASH_APPEARANCE"]                                          = "Design"
-- L["DASH_CLICK_OPTIONS"]                                    = "Click Options"
L["DASH_COLOURS"]                                             = "Farben"
-- L["DASH_ORGANISATION"]                                     = "Organisation"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["FOCUS_PANEL_BEHAVIOUR"]                                    = "Panelverhalten"
L["FOCUS_DIMENSIONS"]                                         = "Abmessungen"
L["FOCUS_INSTANCE"]                                           = "Instanz"
L["FOCUS_INSTANCES"]                                          = "Instanzen"
L["FOCUS_COMBAT"]                                             = "Kampf"
L["FOCUS_FILTERING"]                                          = "Filterung"
L["FOCUS_HEADER"]                                             = "Kopfzeile"
L["FOCUS_SECTIONS_STRUCTURE"]                                 = "Sektionen & Struktur"
L["FOCUS_ENTRY_DETAILS"]                                      = "Eintragsdetails"
L["FOCUS_PROGRESS_TIMERS"]                                    = "Fortschritt & Timer"
L["FOCUS_EMPHASIS"]                                           = "Fokus-Hervorhebung"
L["FOCUS_LIST"]                                               = "Liste"
L["FOCUS_SPACING"]                                            = "Abstände"
L["FOCUS_RARE_BOSSES"]                                        = "Seltene Gegner"
L["FOCUS_WORLD_QUESTS"]                                       = "Welt-Quests"
L["FOCUS_FLOATING_QUEST_ITEM"]                                = "Schwebendes Quest-Item"
L["FOCUS_MYTHIC"]                                             = "Mythisch+"
L["FOCUS_ACHIEVEMENTS"]                                       = "Erfolge"
-- L["FOCUS_ACHIEVEMENT_PROGRESS_BARS"]                       = "Achievement progress bars"
-- L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_DESC"]                  = "Show a progress bar under tracked achievements that report numeric criteria (including 0/1 and X/Y). Independent of Quest Progress Bars."
-- L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_TIP"]                   = "Uses the same bar colours, texture, and font as other Focus progress bars when those options are visible."
L["FOCUS_ENDEAVORS"]                                          = "Bestrebungen"
L["FOCUS_DECOR"]                                              = "Dekoration"
L["FOCUS_APPEARANCES"]                                        = "Vorlagen"
L["FOCUS_SCENARIO_DELVE"]                                     = "Szenarios & Tiefen"
L["FOCUS_FONT"]                                               = "Schriftart"
L["FOCUS_FONT_FAMILIES"]                                      = "Schriftarten"
L["FOCUS_GLOBAL_FONT_SIZE"]                                   = "Globale Schriftgröße"
L["FOCUS_FONT_SIZES"]                                         = "Schriftgrößen"
L["FOCUS_PER_ELEMENT_FONTS"]                                  = "Schriftart pro Element"
L["FOCUS_TEXT_CASE"]                                          = "Groß-/Kleinschreibung"
L["FOCUS_SHADOW"]                                             = "Schatten"
-- L["FOCUS_PANEL"]                                           = "Panel"
L["FOCUS_HIGHLIGHT"]                                          = "Hervorhebung"
L["FOCUS_COLOUR_MATRIX"]                                      = "Farbmatrix"
L["FOCUS_ORDER"]                                              = "Reihenfolge"
L["FOCUS_SORT"]                                               = "Sortierung"
L["FOCUS_BEHAVIOUR"]                                          = "Verhalten"
L["FOCUS_CONTENT_TYPES"]                                      = "Inhaltstypen"
L["FOCUS_DELVES"]                                             = "Tiefen"
L["FOCUS_DELVES_DUNGEONS"]                                    = "Tiefen & Verliese"
L["FOCUS_DELVE_COMPLETE"]                                     = "Tiefe abgeschlossen"
L["FOCUS_INTERACTIONS"]                                       = "Interaktionen"
-- L["FOCUS_APPEARANCE_TAB_DESC"]                             = "Tracker panel look, fading, and list layout (header, sections, entries, timers, emphasis)."
-- L["FOCUS_CLICK_OPTIONS_TAB_DESC"]                          = "Click profile, per-combo actions, and optional safety toggles for the tracker."
-- L["FOCUS_INTERACTIONS_TAB_DESC"]                           = "Configure quest tracking rules and TomTom integration."
L["FOCUS_TRACKING"]                                           = "Verfolgung"
L["FOCUS_SCENARIO_BAR"]                                       = "Szenarioleiste"

-- =====================================================================
-- OptionsData.lua Profiles
-- =====================================================================
L["AXIS_CURRENT_PROFILE"]                                     = "aktuelles Profil"
L["AXIS_SELECT_PROFILE_CURRENTLY"]                            = "Wähle das derzeit verwendete Profil aus"
L["AXIS_GLOBAL_PROFILE_ACCOUNT_WIDE"]                         = "Globales Profil nutzen (accountweit)"
L["AXIS_CHARACTERS_SAME_PROFILE"]                             = "Alle Charaktere nutzen dasselbe Profil"
L["AXIS_ENABLE_PER_SPECIALIZATION_PROFILES"]                  = "Profil pro Spezialisierung aktivieren"
L["AXIS_PICK_DIFFERENT_PROFILES_PER_SPEC"]                    = "Wähle unterschiedliche Profile pro Spec"
L["AXIS_SPECIALIZATION"]                                      = "Spezialisierung"
L["AXIS_SHARING"]                                             = "Teilen"
L["AXIS_IMPORT_PROFILE"]                                      = "Profil importieren"
L["AXIS_IMPORT_STRING"]                                       = "Import String"
L["AXIS_EXPORT_PROFILE"]                                      = "Profil exportieren"
L["AXIS_SELECT_A_PROFILE_EXPORT"]                             = "Wähle ein Profil für den Export"
L["AXIS_EXPORT_STRING"]                                       = "Export-String"
L["AXIS_COPY_PROFILE"]                                        = "Von Profil kopieren"
L["AXIS_SOURCE_PROFILE_COPYING"]                              = "Quell-Profil zum Kopieren"
L["AXIS_COPY_SELECTED"]                                       = "Auswahl kopieren"
L["AXIS_CREATE"]                                              = "Erstellen"
L["AXIS_CREATE_PROFILE_DEFAULT_TEMPLATE"]                     = "Erstelle neues Profil aus Standard-Vorlage"
L["AXIS_CREATES_A_PROFILE_DEFAULT_SETTINGS"]                  = "Erstellt ein neues Profil mit den Standard-Einstellungen"
L["AXIS_CREATES_A_PROFILE_COPIED_SELECTED_SOURC"]             = "Erstellt ein neues Profil mit den Einstellungen des Quell-Profils"
L["AXIS_DELETE_PROFILE"]                                      = "Profil löschen"
L["AXIS_SELECT_A_PROFILE_DELETE_CURRENT_DEFAULT"]             = "Wähle ein Profil zum Löschen (derzeitiges und Standard nicht angezeigt)"
L["AXIS_DELETE_SELECTED"]                                     = "Ausgewähltes löschen"
L["AXIS_DELETE_SELECTED_PROFILE"]                             = "Löscht das ausgewählte Profil"
L["AXIS_DELETE"]                                              = "Löschen"
L["AXIS_DELETES_SELECTED_PROFILE"]                            = "Löscht das ausgewählte Profil"
L["AXIS_GLOBAL_PROFILE"]                                      = "Globales Profil"
L["AXIS_PER_SPEC_PROFILES"]                                   = "Pro-Spec Profile"

-- =====================================================================
-- OptionsData.lua Modules
-- =====================================================================
L["AXIS_ENABLE_FOCUS_MODULE"]                                 = "Fokus-Modul aktivieren"
L["AXIS_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS_R"]             = "Zeige die Zielverfolgung für Welt-(Quests), Rares, Erfolge und Szenarien an"
L["AXIS_ENABLE_PRESENCE_MODULE"]                              = "Presence Modul aktivieren"
L["AXIS_CINEMATIC_ZONE_TEXT_NOTIFICATIONS_ZONE_CHANGES"]      = "Filmische Zonentext- und Benachrichtigungsanzeige (Zonenänderungen, Level up, Boss Emotes, Erfolge, Quest updates)"
L["AXIS_ENABLE_CACHE_MODULE"]                                 = "Ertrag-Modul aktivieren"
L["AXIS_CINEMATIC_LOOT_NOTIFICATIONS_ITEMS_MONEY_CURRENCY"]   = "Filmische Loot-Benachrichtigungen (Items, Gold, Währungen, Ruf)"
L["AXIS_ENABLE_VISTA_MODULE"]                                 = "Vista-Modul aktivieren"
L["AXIS_CINEMATIC_SQUARE_MINIMAP_ZONE_TEXT_COORDINATES"]      = "Filmische quadratische Minimap mit Zonentext, Koordinaten und Button-Sammlung"
L["AXIS_MINIMAP_ZONE_TIME_COLLECTOR"]                         = "Filmische quadratische Minimap mit Zonentext, Koordinaten, Uhrzeit und Button-Sammlung"
-- L["AXIS_BETA"]                                             = "Beta"
L["AXIS_SCALING"]                                             = "Skalierung"
L["AXIS_GLOBAL_TOGGLES"]                                      = "Global Toggles"
L["AXIS_PATCH_NOTES_SECTION"]                                 = "Versionsänderungen"
-- L["AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN"]                   = "Show Patch Notes automatically after an update"
-- L["AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN_DESC"]              = "When on, Axis opens to Patch Notes once after each new addon version. When off, a green dot appears on the Horizon minimap icon until you open Patch Notes."
-- L["AXIS_SUITE_WIDE_CLASS_COLOUR_TINTING_UI"]               = "Dashboard background theme, class colour tinting, and UI scale (global or per module)."
L["AXIS_GLOBAL_UI_SCALE"]                                     = "Globale UI-Skalierung"
L["AXIS_SCALE_SIZES_SPACINGS_FONTS_FACTOR"]                   = "Alle Größen, Abstände und Schriftarten werden um diesen Faktor (50–200 %) skaliert. Deine konfigurierten Werte bleiben dabei unverändert."
L["AXIS_PER_MODULE_SCALING"]                                  = "Skalierung pro Modul"
L["AXIS_OVERRIDE_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_FO"]         = "Globale Skalierung durch Einzelschieber je Modul ersetzen."
L["AXIS_OVERRIDES_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_F"]         = "Überschreibt die globale Skalierung durch individuelle Schieberegler für Focus, Presence, Vista, usw."
L["AXIS_DOESN_T_CHANGE_YOUR_CONFIGURED_VALUES"]               = "Deine konfigurierten Werte werden dadurch nicht verändert, nur die effektive Anzeigeskalierung"
L["FOCUS_SCALE"]                                              = "Fokus-Skalierung"
L["AXIS_SCALE_FOCUS_OBJECTIVE_TRACKER"]                       = "Fokus-Zielverfolungsskalierung (50–200%)"
L["PRESENCE_SCALE"]                                           = "Presence Skalierung"
L["AXIS_SCALE_PRESENCE_CINEMATIC_TEXT"]                       = "Skalierung für den filmischen Presence Text (50–200%)"
L["VISTA_SCALE"]                                              = "Vista-Skalierung"
L["AXIS_SCALE_VISTA_MINIMAP_MODULE"]                          = "Skalierung für das Vista Minimap-Modul (50–200%)"
L["INSIGHT_SCALE"]                                            = "Insight Skalierung"
L["AXIS_SCALE_INSIGHT_TOOLTIP_MODULE"]                        = "Skalierung für das Insight Tooltip-Modul (50–200%)"
L["CACHE_SCALE"]                                              = "Ertrag-Skalierung"
L["AXIS_SCALE_CACHE_LOOT_TOAST_MODULE"]                       = "Skalierung des Ertrag-Beute-Toast-Moduls (50–200%)."
L["AXIS_ENABLE_HORIZON_INSIGHT_MODULE"]                       = "Horizon Insight-Modul aktivieren"
L["AXIS_CINEMATIC_TOOLTIPS_CLASS_COLOURS_SPEC_DISPLAY"]       = "Filmische Tooltips mit Klassenfarben, Spez-Anzeige und Fraktionssymbolen."
L["AXIS_TOOLTIP_ANCHOR_MODE"]                                 = "Tooltip-Ankermodus"
L["AXIS_WHERE_TOOLTIPS_APPEAR_FOLLOW_CURSOR_FIXED"]           = "Wo Tooltips erscheinen: Cursor folgen oder feste Position."
L["AXIS_CURSOR"]                                              = "Zeiger"
L["AXIS_FIXED"]                                               = "Fixiert"
-- L["INSIGHT_CURSOR_SIDE"]                                   = "Cursor side"
-- L["INSIGHT_CURSOR_SIDE_DESC"]                              = "Which side of the cursor the tooltip appears on."
-- L["INSIGHT_CURSOR_SIDE_CENTER"]                            = "Center"
-- L["INSIGHT_CURSOR_SIDE_LEFT"]                              = "Left"
-- L["INSIGHT_CURSOR_SIDE_RIGHT"]                             = "Right"
L["AXIS_ANCHOR_MOVE"]                                         = "Anker zum Verschieben anzeigen"
-- L["AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITION"]                  = "Click to show or hide the anchor. Drag to set position, right-click to confirm."
L["AXIS_DRAGGABLE_FRAME_FIXED_TOOLTIP_POSITION_DESC"]         = "Ziehbaren Rahmen zur festen Tooltip-Position anzeigen. Ziehen, dann Rechtsklick zum Bestätigen."
L["AXIS_RESET_TOOLTIP_POSITION"]                              = "Tooltip-Position zurücksetzen"
L["AXIS_RESET_FIXED_POSITION_DEFAULT"]                        = "Feste Position auf Standard zurücksetzen."
-- L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED"]                        = "Dynamic position for Focus tooltips"
-- L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED_DESC"]                   = "When fixed anchor is on, Focus tracker tooltips still attach to the outer edge of the Horizon panel so they never cover the tracker."
L["INSIGHT_CURSOR_OFFSET_X"]                                  = "Zeigerversatz X"
L["INSIGHT_CURSOR_OFFSET_X_DESC"]                             = "Horizontal pixel offset from the default cursor tooltip position (cursor anchor only)."
L["INSIGHT_CURSOR_OFFSET_Y"]                                  = "Zeigerversatz Y"
L["INSIGHT_CURSOR_OFFSET_Y_DESC"]                             = "Vertical pixel offset from the default cursor tooltip position (cursor anchor only)."
L["AXIS_TOOLTIP_BACKGROUND_COLOUR"]                           = "Tooltip-Hintergrundfarbe"
L["AXIS_COLOUR_OF_TOOLTIP_BACKGROUND"]                        = "Farbe des Tooltip-Hintergrunds."
L["AXIS_TOOLTIP_BACKGROUND_OPACITY"]                          = "Tooltip-Hintergrunddeckkraft"
L["AXIS_TOOLTIP_BG_OPACITY_PCT_DESC"]                         = "Tooltip-Hintergrunddeckkraft (0–100 %)."
L["AXIS_TOOLTIP_FONT"]                                        = "Tooltip-Schriftart"
L["AXIS_FONT_FAMILY_TOOLTIP_TEXT"]                            = "Schriftfamilie für den gesamten Tooltip-Text."
-- L["INSIGHT_BODY_SIZE"]                                     = "Body size"
-- L["INSIGHT_BODY_FONT_SIZE"]                                = "Body font size."
-- L["INSIGHT_BADGES_SIZE"]                                   = "Badges size"
-- L["INSIGHT_BADGES_FONT_SIZE"]                              = "Status badges font size."
-- L["INSIGHT_STATS_SIZE"]                                    = "Stats size"
-- L["INSIGHT_STATS_FONT_SIZE"]                               = "M+ score, item level, and honor level font size."
-- L["INSIGHT_MOUNT_SIZE"]                                    = "Mount size"
-- L["INSIGHT_MOUNT_FONT_SIZE"]                               = "Mount name, source, and ownership font size."
-- L["INSIGHT_MOUNT_OWNERSHIP_DISPLAY"]                       = "Mount collection indicator"
-- L["INSIGHT_MOUNT_OWNERSHIP_DISPLAY_DESC"]                  = "How to show whether you have collected the hovered player's mount."
-- L["INSIGHT_MOUNT_OWNERSHIP_TEXT"]                          = "Full text"
-- L["INSIGHT_MOUNT_OWNERSHIP_ICONS"]                         = "Tick / cross"
-- L["INSIGHT_MOUNT_OWNED"]                                   = "You own this mount"
-- L["INSIGHT_MOUNT_NOT_OWNED"]                               = "You don't own this mount"
-- L["INSIGHT_TRANSMOG_SIZE"]                                 = "Transmog size"
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
-- L["INSIGHT_PLAYER_NAME_COLOUR"]                            = "Player name colour"
-- L["INSIGHT_PLAYER_NAME_COLOUR_DESC"]                       = "Colour for the player's name on the first tooltip line: faction (Alliance blue, Horde red) or class."
-- L["INSIGHT_PLAYER_NAME_COLOUR_FACTION"]                    = "Faction"
-- L["INSIGHT_PLAYER_NAME_COLOUR_CLASS"]                      = "Class"
-- L["INSIGHT_PLAYER_NAME_GRADIENT"]                          = "Class colour gradient"
-- L["INSIGHT_PLAYER_NAME_GRADIENT_DESC"]                     = "Render the player name as a two-stop gradient of their class colour (only applies when the name colour is set to Class)."
-- L["INSIGHT_SECTION_STATUS_PVP"]                            = "Status & PvP"
-- L["INSIGHT_SECTION_RATINGS_GEAR"]                          = "Ratings & gear"
-- L["INSIGHT_SPEC_ROLE"]                                     = "Spec icon & role"
-- L["INSIGHT_SPEC_ROLE_DESC"]                                = "Show the player's specialization icon and role after inspecting them. Disable to stop Insight from calling NotifyInspect on mouseover."
-- L["INSIGHT_SECTION_MOUNT"]                                 = "Mount"
-- L["INSIGHT_SECTION_DISMISS"]                               = "Unit tooltip dismiss"
-- L["INSIGHT_DISMISS_GRACE"]                                 = "Dismiss grace"
L["INSIGHT_DISMISS_GRACE_DESC"]                               = "How long to wait after the mouse leaves a unit before starting to hide the GameTooltip. Longer grace reduces flicker from brief cursor gaps."
-- L["INSIGHT_DISMISS_GRACE_INSTANT"]                         = "Instant"
-- L["INSIGHT_DISMISS_GRACE_DEFAULT"]                         = "Normal"
-- L["INSIGHT_DISMISS_GRACE_RELAXED"]                         = "Relaxed"
-- L["INSIGHT_SECTION_COMBAT"]                                = "Combat"
-- L["INSIGHT_HIDE_IN_COMBAT"]                                = "Hide tooltips in combat"
-- L["INSIGHT_HIDE_IN_COMBAT_DESC"]                           = "While in combat, close GameTooltip and other Insight-styled tooltip frames and block them from staying open. Applies only when the Insight module is enabled."
-- L["INSIGHT_FADE_OUT_SEC"]                                  = "Fade-out duration"
L["INSIGHT_FADE_OUT_SEC_DESC"]                                = "Seconds to fade the unit tooltip after dismiss starts. Zero hides immediately (no fade). Applies to GameTooltip unit tips only."
-- L["INSIGHT_SECTION_ICONS_AND_SEPARATORS"]                  = "Icons & separators"
-- L["INSIGHT_SECTION_NPC_TOOLTIP"]                           = "NPC tooltip"
-- L["INSIGHT_SECTION_TRANSMOG"]                              = "Transmog"
-- L["INSIGHT_NPC_PLACEHOLDER"]                               = "NPC-specific options will appear here when available. Reaction colours and level lines still apply in-game."
-- L["INSIGHT_NPC_REACTION_BORDER"]                           = "Reaction border"
-- L["INSIGHT_NPC_REACTION_BORDER_DESC"]                      = "Tint the tooltip border to the NPC's faction reaction (hostile red, friendly green, neutral yellow)."
-- L["INSIGHT_NPC_REACTION_NAME"]                             = "Reaction name colour"
-- L["INSIGHT_NPC_REACTION_NAME_DESC"]                        = "Colour the NPC's name to match their faction reaction."
-- L["INSIGHT_NPC_LEVEL_LINE"]                                = "Level line"
-- L["INSIGHT_NPC_LEVEL_LINE_DESC"]                           = "Show the NPC's level, classification (Elite, Rare, etc.), and creature type beneath their name."
-- L["INSIGHT_NPC_ICONS_DESC"]                                = "Show an icon instead of '??' for NPCs with an unknown level."
-- L["INSIGHT_SECTION_ITEM_STYLING"]                          = "Item styling"
-- L["INSIGHT_ITEM_QUALITY_BORDER"]                           = "Quality border"
-- L["INSIGHT_ITEM_QUALITY_BORDER_DESC"]                      = "Tint the tooltip border to the item's quality colour (Uncommon green, Rare blue, Epic purple, etc.)."
-- L["INSIGHT_ITEM_NAME_GRADIENT"]                            = "Quality gradient name"
-- L["INSIGHT_ITEM_NAME_GRADIENT_DESC"]                       = "Render the item name as a two-stop gradient of its quality colour (Uncommon green, Rare blue, Epic purple, etc.)."
-- L["INSIGHT_ITEM_SECTION_SPACING"]                          = "Blank line before blocks"
-- L["INSIGHT_ITEM_SECTION_SPACING_DESC"]                     = "Insert a blank line before Insight blocks on item tooltips instead of a tinted separator line."
L["AXIS_ITEM_TOOLTIP"]                                        = "Gegenstands-Tooltip"
L["AXIS_TRANSMOG_STATUS"]                                     = "Transmog-Status anzeigen"
L["AXIS_WHETHER_YOU_COLLECTED_APPEARANCE_OF_AN"]              = "Anzeigen ob die Erscheinung eines Gegenstands gesammelt wurde."
L["AXIS_PLAYER_TOOLTIP"]                                      = "Spieler-Tooltip"
L["AXIS_GUILD_RANK"]                                          = "Gildenrang anzeigen"
L["AXIS_APPEND_PLAYER_S_GUILD_RANK_NEXT"]                     = "Gildenrang des Spielers neben dem Gildennamen anzeigen."
L["AXIS_MYTHIC_SCORE"]                                        = "Mythisch-Plus-Punkte anzeigen"
L["AXIS_PLAYER_S_CURRENT_SEASON_MYTHIC_SCORE"]                = "Aktuelle Saison-Mythisch-Plus-Punkte des Spielers, farbcodiert nach Stufe."
L["AXIS_ITEM_LEVEL"]                                          = "Gegenstandsstufe anzeigen"
L["AXIS_PLAYER_S_EQUIPPED_ITEM_LEVEL_AFTER"]                  = "Gegenstandsstufe des Spielers nach Inspektion anzeigen."
L["AXIS_HONOR_LEVEL"]                                         = "Ehrenstufe anzeigen"
L["AXIS_PLAYER_S_PVP_HONOR_LEVEL_TOOLTIP"]                    = "PvP-Ehrenstufe des Spielers im Tooltip anzeigen."
L["AXIS_PVP_TITLE"]                                           = "PvP-Titel anzeigen"
L["AXIS_PLAYER_S_PVP_TITLE_E_G"]                              = "PvP-Titel des Spielers (z.B. Gladiator) im Tooltip anzeigen."
-- L["AXIS_CHARACTER_TITLE"]                                  = "Character title"
-- L["AXIS_PLAYER_S_SELECTED_TITLE_ACHIEVEMENT_PVP"]          = "Show the player's selected title (achievement or PvP) in the name line."
-- L["AXIS_TITLE_COLOUR"]                                     = "Title colour"
-- L["AXIS_COLOUR_OF_CHARACTER_TITLE_PLAYER_TOOLTIP"]         = "Colour of the character title in the player tooltip name line."
L["AXIS_STATUS_BADGES"]                                       = "Status-Badges anzeigen"
L["AXIS_INLINE_BADGES_COMBAT_AFK_DND_PVP"]                    = "Inline-Badges für Kampf, AFK, DND, PvP, Schlachtzug/Gruppe, Freunde und Zielanzeige anzeigen."
L["AXIS_MOUNT_INFO"]                                          = "Reittierinfo anzeigen"
L["AXIS_HOVERING_A_MOUNTED_PLAYER_THEIR_MOUNT"]               = "Bei Reittier-Spieler: Reittiername, Quelle und ob Sie es besitzen anzeigen."
-- L["AXIS_BLANK_SEPARATOR"]                                  = "Blank separator"
-- L["AXIS_A_BLANK_LINE_INSTEAD_OF_DASHES"]                   = "Use a blank line instead of dashes between tooltip sections."
-- L["AXIS_ICONS"]                                            = "Show icons"
-- L["AXIS_CLASS_ICON_STYLE"]                                 = "Class icon style"
L["AXIS_DEFAULT_BLIZZARD_RONDOMEDIA_CLASS_ICONS_TH"]          = "Use Default (Blizzard) or RondoMedia class icons on the class/spec line."
L["AXIS_CUSTOM_CLASS_ICONS_LABEL"]                            = "Custom (addon media)"
L["AXIS_CLASS_ICON_SOURCES_TOOLTIP"]                          = "RondoMedia: https://www.curseforge.com/wow/addons/rondomedia — Custom: place one .tga per class under media/CustomClassIcons/<CLASS>/<class lower>.tga (e.g. WARRIOR/warrior.tga), then /reload."
-- L["AXIS_RONDOMEDIA_CLASS_ICONS_RONDOFERRARI_HTTPS_WWW"]    = "RondoMedia class icons by RondoFerrari — https://www.curseforge.com/wow/addons/rondomedia"
-- L["AXIS_DEFAULT"]                                          = "Default"
-- L["AXIS_FACTION_SPEC_MOUNT_MYTHIC_ICONS_TOOLTIPS"]         = "Show faction, spec, mount, and Mythic+ icons in tooltips."
L["AXIS_GENERAL"]                                             = "Allgemein"
-- L["AXIS_POSITION"]                                         = "Position"
L["AXIS_RESET_POSITION"]                                      = "Position zurücksetzen"
L["AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"]                   = "Beute-Toast-Position auf Standard zurücksetzen."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["FOCUS_LOCK_POSITION"]                                      = "Position sperren"
L["FOCUS_PREVENT_DRAGGING_TRACKER"]                           = "Verhindert das Verschieben des Trackers"
L["FOCUS_GROW_UPWARD"]                                        = "Nach oben erweitern"
L["FOCUS_GROW_HEADER"]                                        = "Kopfzeile nach oben erweitern"
L["FOCUS_GROWING_UPWARD_KEEP_HEADER_BOTTOM_TOP"]              = "Wenn nach oben erweitert: Behalte die Kopfzeile unten, oder oben bis sie ausgeblendet wird."
L["FOCUS_HEADER_BOTTOM"]                                      = "Kopfzeile unten"
L["FOCUS_HEADER_SLIDES_COLLAPSE"]                             = "Header gleitet beim Einklappen"
L["FOCUS_ANCHOR_BOTTOM_LIST_GROWS_UPWARD"]                    = "Die Liste nach unten ausrichten, damit sie nach oben wächst"
L["FOCUS_START_COLLAPSED"]                                    = "Eingeklappt starten"
L["FOCUS_START_HEADER_SHOWN_UNTIL_YOU_EXPAND"]                = "Zeigt zu Beginn nur den Header an, bis du sie aufklappst"
L["FOCUS_ALIGN_CONTENT_RIGHT"]                                = "Inhalt rechts ausrichten"
L["FOCUS_RIGHT_ALIGN_QUEST_TITLES_OBJECTIVES_WITHIN"]         = "Richte die Questnamen und -ziele innerhalb des Fensters rechtsbündig aus"
L["FOCUS_PANEL_WIDTH"]                                        = "Panelbreite"
L["FOCUS_TRACKER_WIDTH_PIXELS"]                               = "Trackerbreite in Pixel"
L["FOCUS_MAX_CONTENT_HEIGHT"]                                 = "Maximal Höhe des Inhalts"
L["FOCUS_MAX_HEIGHT_OF_SCROLLABLE_LIST_PIXELS"]               = "Maximale Höhe der scrollbaren Liste in Pixel"

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["FOCUS_ALWAYS_M_BLOCK"]                                     = "M+ Block immer anzeigen"
L["FOCUS_M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]                = "Zeige des M+ Block, immer wenn ein aktiver Schlüsselstein läuft"
L["FOCUS_DUNGEON"]                                            = "Zeige in Dungeons"
L["FOCUS_TRACKER_PARTY_DUNGEONS"]                             = "Zeige Zielverfolger in Gruppen-Dungeons"
L["FOCUS_RAID"]                                               = "Zeige in Schlachtzug"
L["FOCUS_TRACKER_RAIDS"]                                      = "Zeige den Tracker im Schlachtzug"
L["FOCUS_BATTLEGROUND"]                                       = "Auf Schlachtfeldern anzeigen"
L["FOCUS_TRACKER_BATTLEGROUNDS"]                              = "Zeigt den Tracker auf Schlachtfeldern"
L["FOCUS_ARENA"]                                              = "In Arena anzeigen"
L["FOCUS_TRACKER_ARENAS"]                                     = "Zeigt den Tracker in Arenen an"
L["FOCUS_HIDE_COMBAT"]                                        = "Im Kampf verstecken"
L["FOCUS_HIDE_TRACKER_FLOATING_QUEST_ITEM_COMBAT"]            = "Verstecke Tracker und schwebendes Questitem im Kampf"
L["FOCUS_COMBAT_VISIBILITY"]                                  = "Kampf Sichtbarkeit"
L["FOCUS_TRACKER_BEHAVES_COMBAT_FADE_REDUC"]                  = "Wie sich der Tracker im Kampf verhält: anzeigen, verblassen, oder ausblenden"
L["FOCUS_SHOW"]                                               = "Anzeigen"
L["FOCUS_FADE"]                                               = "Verblassen"
L["FOCUS_HIDE"]                                               = "Ausblenden"
L["FOCUS_COMBAT_FADE_OPACITY"]                                = "Sichtbarkeit im Kampf"
L["FOCUS_VISIBLE_TRACKER_FADED_COMBAT"]                       = "Wie sichtbar der Tracker ist, wenn er im Kampf verblasst (0 = unsichtbar). Gilt nur, wenn die Sichtbarkeit im Kampf auf „Ausblenden“ eingestellt ist."
L["FOCUS_MOUSEOVER"]                                          = "Mausüber"
L["FOCUS_SHOW_ONLY_MOUSEOVER"]                                = "Zeige nur bei mouseover"
L["FOCUS_FADE_TRACKER_HOVERING_MOVE_MOUSE"]                   = "Tracker verblasst wenn der Mauszeiger nicht darüber schwebt"
L["FOCUS_FADED_OPACITY"]                                      = "Sichtbarkeit wenn verblasst"
L["FOCUS_VISIBLE_TRACKER_FADED_INVISIBLE"]                    = "Sichtbarkeit des Trackers wenn er verblasst ist (0 = unsichtbar)"
L["FOCUS_QUESTS_CURRENT_ZONE"]                                = "Zeige Quests nur aus der aktuellen Zone"
L["FOCUS_HIDE_QUESTS_OUTSIDE_YOUR_CURRENT_ZONE"]              = "Verstecke Quests außerhalb deiner aktuellen Zone"

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["FOCUS_QUEST_COUNT"]                                        = "Anzahl der Quests anzeigen"
L["FOCUS_QUEST_COUNT_HEADER"]                                 = "Zeige die Anzahl der Quests in der Kopfzeile an"
L["FOCUS_HEADER_COUNT_FORMAT"]                                = "Format des Zählers"
L["FOCUS_TRACKED_LOG_LOG_MAX_SLOTS_TRACKED"]                  = "Verfolgt/im-Log oder im-Log/max-Plätze. Verfolgt schließt Welt-/Zonen-Quests aus."
L["FOCUS_HEADER_DIVIDER"]                                     = "Zeige Kopfzeilen-Trennlinie"
L["FOCUS_LINE_BELOW_HEADER"]                                  = "Zeige die Linie unterhalb der Kopfzeile"
L["FOCUS_HEADER_DIVIDER_COLOUR"]                              = "Farbe der Kopfzeilen-Trennlinie"
L["FOCUS_COLOUR_OF_LINE_BELOW_HEADER"]                        = "Farbe der Linie unter der Kopfzeile."
L["FOCUS_SUPER_MINIMAL_MODE"]                                 = "Super-Minimal Modus"
L["FOCUS_HIDE_HEADER_A_PURE_TEXT_LIST"]                       = "Kopfzeile ausblenden, um eine reine Textliste anzuzeigen"
L["FOCUS_OPTIONS_BUTTON"]                                     = "Options button"
L["FOCUS_OPTIONS_BUTTON_TRACKER_HEADER"]                      = "Zeigt den Options-Button in der Kopfzeile des Trackers"
L["FOCUS_HEADER_COLOUR"]                                      = "Kopfzeilenfarbe"
L["FOCUS_COLOUR_OF_OBJECTIVES_HEADER_TEXT"]                   = "Farbe der ZIEL-Text Kopfzeile"
L["FOCUS_HEADER_HEIGHT"]                                      = "Kopfzeilenhöhe"
L["FOCUS_HEIGHT_OF_HEADER_BAR_PIXELS"]                        = "Höhe der Kopfzeilenleiste in Pixel (18–48)"

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["FOCUS_SECTION_HEADERS"]                                    = "Abschnittsüberschriften anzeigen"
L["FOCUS_CATEGORY_LABELS_ABOVE_GROUP"]                        = "Kategoriebezeichnungen über jeder Gruppe anzeigen."
L["FOCUS_CATEGORY_HEADERS_COLLAPSED"]                         = "Kategorieüberschriften anzeigen, wenn ausgeblendet"
L["FOCUS_KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED_CLICK"]       = "Die Überschriften der Abschnitte bleiben sichtbar wenn eingeklappt ; klicke darauf, um eine Kategorie zu erweitern"
L["FOCUS_NEARBY_CURRENT_ZONE_GROUP"]                          = "Zeige In der Nähe (aktuelle Zone) Gruppe"
L["FOCUS_ZONE_QUESTS_A_DEDICATED_CURRENT_ZONE"]               = "Zeige Quests in der aktuellen Zone in einem eigenen Bereich an. Wenn deaktiviert, werden sie in ihrer normalen Kategorie angezeigt."
L["FOCUS_ZONE_LABELS"]                                        = "Zeige Zonen-Bezeichnung"
L["FOCUS_ZONE_NAME_UNDER_QUEST_TITLE"]                        = "Zeige den Namen der Zone unter jedem Questtitel an."
L["FOCUS_ACTIVE_QUEST_HIGHLIGHT"]                             = "Aktive Quest hervorheben"
L["FOCUS_FOCUSED_QUEST_HIGHLIGHTED"]                          = "Wie die aktuelle Quest hervorgehoben wird"
L["FOCUS_QUEST_ITEM_BUTTONS"]                                 = "Questitem-Buttons anzeigen"
L["FOCUS_USABLE_QUEST_ITEM_BUTTON_NEXT_QUEST"]                = "Zeige neben jeder Quest den Button für den nutzbaren Questgegenstand an"
L["FOCUS_TOOLTIPS_HOVER"]                                     = "Tooltips bei Mouseover"
L["FOCUS_TOOLTIPS_HOVERING_TRACKER_ENTRIES_ITE"]              = "Tooltips anzeigen, wenn der Mauszeiger über Tracker-Einträge, Item-Buttons und Szenario-Blöcken bewegt wird"
L["FOCUS_WOWHEAD_LINK_TOOLTIPS"]                              = "Wowhead Links in Tooltips anzeigen"
L["FOCUS_A_TOOLTIP_SHOWN_ADD_A_LINK"]                         = "Wenn ein Tooltip angezeigt wird, füge einen Link hinzu, über den die Quest, der Erfolg oder der NPC auf WoWhead geöffnet werden kann."
L["FOCUS_VIEW_WOWHEAD"]                                       = "Auf Wowhead anzeigen"
L["FOCUS_WOWHEAD_ALT_CLICK_HINT"]                             = "Alt + Klick für Link"
-- L["FOCUS_WOWHEAD_HINT_LIST_SEPARATOR"]                     = " · "
L["FOCUS_WOWHEAD_TOOLTIP_HINT_FALLBACK"]                      = "In den Focus-Optionen festlegen"
L["FOCUS_COPY_LINK"]                                          = "Link kopieren"
L["FOCUS_COPY_URL_BELOW_CTRL_C_PASTE"]                        = "Kopiere die folgende URL (Strg + C) und füge sie in deinem Browser ein."
L["FOCUS_OBJECTIVE_NUMBERS"]                                  = "Zahlen für Ziele anzeigen"
L["FOCUS_OBJECTIVE_PREFIX"]                                   = "Zielprefix"
L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS"]                  = "Zielfortschrittsnummern färben"
L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS_DESC"]             = "Tint X/Y counts: normal colour at 0/n, gold while in progress, green when complete. The slash uses the usual objective colour."
L["FOCUS_PREFIX_OBJECTIVE_A_NUMBER_HYPHEN"]                   = "Jedem Ziel eine Zahl oder einen Bindestrich voranstellen."
L["FOCUS_NUMBERS"]                                            = "Nummerierung (1. 2. 3.)"
L["FOCUS_HYPHENS"]                                            = "Bindestriche (-)"
L["FOCUS_AFTER_SECTION_HEADER"]                               = "Nach der Abschnittsüberschrift"
L["FOCUS_BEFORE_SECTION_HEADER"]                              = "Vor der Abschnittsüberschrift"
L["FOCUS_BELOW_HEADER"]                                       = "Unterhalb der Kopfzeile"
L["FOCUS_INLINE_BELOW_TITLE"]                                 = "Eingebettet unterhalb des Titels"
L["FOCUS_PREFIX_OBJECTIVES"]                                  = "Stelle den Zielen die Nummern 1., 2., 3. voran"
L["FOCUS_COMPLETED_COUNT"]                                    = "Anzahl der abgeschlossenen Aufgaben anzeigen"
L["FOCUS_X_Y_PROGRESS_QUEST_TITLE"]                           = "Fortschritt (X/Y) im Ques-Titel anzeigen."
L["FOCUS_OBJECTIVE_PROGRESS_BAR"]                             = "Zielfortschrittsbalken anzeigen"
L["FOCUS_A_PROGRESS_BAR_UNDER_OBJECTIVES_NUMER"]              = "Zeige einen Fortschrittsbalken unter Zielen an, die einen numerischen Fortschritt aufweisen (z. B. 3/250). Dies gilt nur für Einträge mit einem einzelnen rechnerischen Ziel, bei denen der erforderliche Wert größer als 1 ist."
L["FOCUS_CATEGORY_COLOUR_PROGRESS_BAR"]                       = "Kategoriefarbe für Fortschrittsbalken"
L["FOCUS_PROGRESS_BAR_MATCHES_QUEST_ACHIEVEME"]               = "Wenn aktiviert, passt sich der Fortschrittsbalken an die Farbe der Quest-/Erfolgskategorie an. Wenn deaktiviert, wird die unten angegebene benutzerdefinierte Füllfarbe verwendet."
L["FOCUS_PROGRESS_BAR_TEXTURE"]                               = "Textur für den Fortschrittsbalken"
L["FOCUS_PROGRESS_BAR_TYPES"]                                 = "Arten von Fortschrittsbalken"
L["FOCUS_TEXTURE_PROGRESS_BAR_FILL"]                          = "Textur für die Füllung des Fortschrittsbalkens"
L["FOCUS_TEXTURE_PROGRESS_BAR_FILL_SOLID_YOUR"]               = "Textur für die Füllung des Fortschrittsbalkens. Bei „Solid“ werden die von dir gewählten Farben verwendet. Add-ons wie SharedMedia bieten weitere Optionen."
L["FOCUS_PROGRESS_BAR_X_Y_OBJECTIVES_PERCENT"]                = "Zeige einen Fortschrittsbalken für X/Y-Ziele, reine Prozentziele oder beides an"
L["FOCUS_X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]             = "X/Y: Ziele wie 3/10. Prozent: Ziele wie 45 %"
L["FOCUS_X_Y"]                                                = "nur X/Y"
L["FOCUS_PERCENT"]                                            = "nur Prozent"
L["FOCUS_TICK_COMPLETED_OBJECTIVES"]                          = "Häkchen für abgeschlossene Ziele anzeigen"
L["FOCUS_COMPLETED_OBJECTIVES_A_CHECKMARK_INSTEA"]            = "Wenn die Funktion aktiviert ist, werden abgeschlossene Ziele mit einem Häkchen (✓) statt in grüner Farbe angezeigt."
L["FOCUS_ENTRY_NUMBERS"]                                      = "Nummerierung anzeigen"
L["FOCUS_PREFIX_QUEST_TITLES_WITHIN_CATEGORY"]                = "Füge den Questtiteln innerhalb jeder Kategorie die Nummern 1., 2., 3. voran"
L["FOCUS_COMPLETED_OBJECTIVES"]                               = "Abgeschlossene Ziele"
L["FOCUS_MULTI_OBJECTIVE_QUESTS_DISPLAY_OBJECTIVES"]          = "Wie bei Quests mit mehreren Zielen die bereits erfüllten Ziele angezeigt werden (z. B. 1/1)"
L["FOCUS_ALL"]                                                = "Alle anzeigen"
L["FOCUS_FADE_COMPLETED"]                                     = "Abgeschlossene abblenden"
L["FOCUS_HIDE_COMPLETED"]                                     = "Abgeschlossene ausblenden"
L["FOCUS_ICON_ZONE_AUTO_TRACKING"]                            = "Symbol für automatische Verfolgung innerhalb der derzeitigen Zone anzeigen"
L["FOCUS_DISPLAY_AN_ICON_NEXT_AUTO_TRACKED"]                  = "Zeige ein Symbol neben automatisch verfolgten Weltquests und wöchentlichen/täglichen Quests an, die noch nicht in deinem Questlog stehen (nur innerhalb der Zone)."
L["FOCUS_AUTO_TRACK_ICON"]                                    = "Symbol für automatische Verfolgung"
L["FOCUS_CHOOSE_WHICH_ICON_DISPLAY_NEXT_AUTO"]                = "Wähle aus, welches Symbol neben automatisch erfassten Einträgen innerhalb der derzeitigen Zone angezeigt werden soll."
L["FOCUS_APPEND_WORLD_QUESTS_WEEKLIES_DAILIES"]               = "Füge ** zu Weltquests und wöchentlichen/täglichen Quests hinzu, die noch nicht in deinem Questlog stehen (nur in derzeitiger Zone)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["FOCUS_COMPACT_MODE"]                                       = "Kompaktmodus"
L["FOCUS_PRESET_SETS_ENTRY_OBJECTIVE_SPACING_P"]              = "Voreinstellung: Eintrags- und Zielabstand auf 4 und 1 px."
L["FOCUS_SPACING_PRESET"]                                     = "Abstands-Voreinstellung"
L["FOCUS_PRESET_ENTRY_OBJECTIVE_SPACING_DEFAULT_P"]           = "Voreinstellung: Standard (8/2 px), Kompakt (4/1 px), Abstand (12/3 px) oder Benutzerdefiniert (Slider)."
L["FOCUS_COMPACT_VERSION"]                                    = "Kompaktversion"
L["FOCUS_SPACED_VERSION"]                                     = "Abstandsversion"
L["FOCUS_SPACING_BETWEEN_QUEST_ENTRIES_PX"]                   = "Abstand zwischen Quest-Einträgen (px)"
L["FOCUS_VERTICAL_GAP_BETWEEN_QUEST_ENTRIES"]                 = "Vertikaler Abstand zwischen Quest-Einträgen."
L["FOCUS_SPACING_BEFORE_CATEGORY_HEADER_PX"]                  = "Abstand vor Kategorie-Header (px)"
L["FOCUS_GAP_BETWEEN_LAST_ENTRY_OF_A"]                        = "Abstand zwischen letztem Eintrag einer Gruppe und dem nächsten Kategorie-Label."
L["FOCUS_SPACING_AFTER_CATEGORY_HEADER_PX"]                   = "Abstand nach Kategorie-Header (px)"
L["FOCUS_GAP_BETWEEN_CATEGORY_LABEL_FIRST_QUEST"]             = "Abstand zwischen Kategorie-Label und erstem Quest-Eintrag darunter."
L["FOCUS_SPACING_BETWEEN_OBJECTIVES_PX"]                      = "Abstand zwischen Zielen (px)"
L["FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVE_LINES_WITHIN"]        = "Vertikaler Abstand zwischen Zielzeilen innerhalb einer Quest."
L["FOCUS_TITLE_CONTENT"]                                      = "Titel zu Inhalt"
L["FOCUS_VERTICAL_GAP_BETWEEN_QUEST_TITLE_OBJECTIVES"]        = "Vertikaler Abstand zwischen Quest-Titel und Zielen oder Zone darunter."
L["FOCUS_SPACING_BELOW_HEADER_PX"]                            = "Abstand unter Kopfzeile (px)"
L["FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVES_BAR_QUES"]           = "Vertikaler Abstand zwischen Ziele-Leiste und Questliste."
L["FOCUS_RESET_SPACING"]                                      = "Abstände zurücksetzen"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["FOCUS_SHOW_QUEST_LEVEL"]                                   = "Quest-Stufe anzeigen"
L["FOCUS_QUEST_LEVEL_NEXT_TITLE"]                             = "Quest-Stufe neben Titel anzeigen."
L["FOCUS_DIM_FOCUSED_QUESTS"]                                 = "Nicht fokussierte Quests abdunkeln"
L["FOCUS_SLIGHTLY_DIM_TITLE_ZONE_OBJECTIVES_SECTION"]         = "Nicht fokussierte Titel, Zonen, Ziele und Abschnitts-Header leicht abdunkeln."
L["FOCUS_DIM_UNFOCUSED_ENTRIES"]                              = "Nicht fokussierte Einträge abdunkeln"
L["FOCUS_CLICK_A_SECTION_HEADER_EXPAND_CATEGORY"]             = "Abschnittsüberschrift klicken, um Kategorie zu erweitern."

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["UI_SHOW_RARE_BOSSES"]                                      = "Seltene Gegner anzeigen"
L["UI_RARE_BOSS_VIGNETTES_LIST"]                              = "Vignetten seltener Gegner in der Liste anzeigen."
L["UI_RARE_LOOT"]                                             = "Seltene Beute"
L["UI_TREASURE_ITEM_VIGNETTES_RARE_LOOT"]                     = "Zeigt Schätze und Gegenstände in der Liste seltener Beute."
L["UI_RARE_SOUND_VOLUME"]                                     = "Lautstärke seltener Beute"
L["UI_VOLUME_OF_RARE_ALERT_SOUND"]                            = "Lautstärke des Alarmsounds für seltene Beute (50–200%)."
L["UI_BOOST_REDUCE_RARE_ALERT_VOLUME"]                        = "Lautstärke anpassen. 100 % = normal; 150 % = lauter."
L["UI_RARE_ADDED_SOUND"]                                      = "Audioeffekt bei seltenen Gegnern"
L["UI_PLAY_A_SOUND_A_RARE"]                                   = "Audioeffekt abspielen, wenn ein seltener Gegner hinzugefügt wird."
-- L["UI_MINIMAP_PATCH_NOTES_UNREAD_HINT"]                    = "New patch notes — open Axis and choose Patch Notes."

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["FOCUS_ZONE_WORLD_QUESTS"]                                  = "Welt-Quests in Zone anzeigen"
L["FOCUS_AUTO_ADD_WORLD_QUESTS_YOUR_CURRENT"]                 = "Welt-Quests in Zone automatisch hinzufügen. Aus: nur getrackte Quests oder nahe Weltquests (Blizzard-Standard)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["FOCUS_SHOW_FLOATING_QUEST_ITEM"]                           = "Schwebendes Quest-Item anzeigen"
L["FOCUS_QUICK_BUTTON_FOCUSED_QUEST_S_USABLE"]                = "Schnell-Button für nutzbares Item der fokussierten Quest anzeigen."
L["FOCUS_LOCK_FLOATING_QUEST_ITEM_POSITION"]                  = "Schwebendes Quest-Item sperren"
L["FOCUS_PREVENT_DRAGGING_FLOATING_QUEST_ITEM_BUTTON"]        = "Schwebendes Quest-Item nicht verschiebbar."
L["FOCUS_FLOATING_QUEST_ITEM_SOURCE"]                         = "Quelle für schwebendes Quest-Item"
L["FOCUS_WHICH_QUEST_S_ITEM_SUPER_TRACKED"]                   = "Welches Quest-Item anzeigen: super-verfolgt zuerst oder aktuelle Zone zuerst."
L["FOCUS_SUPER_TRACKED_FIRST"]                                = "Super-verfolgt, dann zuerst"
L["FOCUS_CURRENT_ZONE_FIRST"]                                 = "Aktuelle Zone zuerst"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["FOCUS_MYTHIC_BLOCK"]                                       = "Mythisch-Plus-Block anzeigen"
L["FOCUS_TIMER_COMPLETION_AFFIXES_MYTHIC_DUNGEONS"]           = "Timer, Abschluss-% und Affixe in Mythisch+-Dungeons anzeigen."
L["FOCUS_M_BLOCK_POSITION"]                                   = "M+-Block-Position"
L["FOCUS_POSITION_OF_MYTHIC_BLOCK_RELATIVE_QUEST"]            = "Position des M+-Blocks relativ zur Questliste."
L["FOCUS_AFFIX_ICONS"]                                        = "Affix-Symbole anzeigen"
L["FOCUS_AFFIX_ICONS_NEXT_MODIFIER_NAMES_M"]                  = "Affix-Symbole neben Modifikator-Namen im M+-Block anzeigen."
L["FOCUS_AFFIX_DESCRIPTIONS_TOOLTIP"]                         = "Affix-Beschreibungen im Tooltip anzeigen"
L["FOCUS_AFFIX_DESCRIPTIONS_HOVERING_M_BLO"]                  = "Affix-Beschreibungen bei Mausüber M+-Block anzeigen."
L["FOCUS_M_COMPLETED_BOSS_DISPLAY"]                           = "M+ besiegte Boss-Anzeige"
L["FOCUS_DEFEATED_BOSSES_CHECKMARK_ICON_GREEN"]               = "Besiegte Bosse: Häkchen-Symbol oder grüne Farbe."
L["FOCUS_CHECKMARK"]                                          = "Häkchen"
L["FOCUS_GREEN_COLOUR"]                                       = "Grünfärbung"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["PRESENCE_ACHIEVEMENTS"]                                    = "Erfolge anzeigen"
L["FOCUS_TRACKED_ACHIEVEMENTS_LIST"]                          = "Verfolgte Erfolge in der Liste anzeigen."
L["FOCUS_COMPLETED_ACHIEVEMENTS"]                             = "Errungene Erfolge anzeigen"
L["FOCUS_INCLUDE_COMPLETED_ACHIEVEMENTS_TRACKER_O"]           = "Errungene Erfolge im Zielverfolger anzeigen. Aus: nur verfolgte in Bearbeitung."
L["FOCUS_ACHIEVEMENT_ICONS"]                                  = "Erfolgssymbole anzeigen"
L["FOCUS_ACHIEVEMENT_S_ICON_NEXT_TITLE_REQUI"]                = "Erfolgssymbol neben Titel anzeigen. Erfordert „Quest-Typ-Symbole anzeigen\" in Anzeige."
L["FOCUS_MISSING_REQUIREMENTS"]                               = "Nur fehlende Kriterien anzeigen"
L["FOCUS_CRITERIA_YOU_HAVEN_T_COMPLETED_TR"]                  = "Nur offene Kriterien pro verfolgtem Erfolg. Aus: alle Kriterien."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["FOCUS_SHOW_ENDEAVORS"]                                     = "Unterfangen anzeigen"
L["FOCUS_TRACKED_ENDEAVORS_PLAYER_HOUSING_LIST"]              = "Verfolgte Unterfangen (Spielerbehausung) in der Liste anzeigen."
L["FOCUS_COMPLETED_ENDEAVORS"]                                = "Abgeschlossene Unterfangen anzeigen"
L["FOCUS_INCLUDE_COMPLETED_ENDEAVORS_TRACKER"]                = "Abgeschlossene Unterfangen im Zielverfolger anzeigen. Aus: nur verfolgte in Bearbeitung."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["FOCUS_SHOW_DECOR"]                                         = "Dekoration anzeigen"
L["FOCUS_TRACKED_HOUSING_DECOR_LIST"]                         = "Verfolgte Behausungsdekoration in der Liste anzeigen."
L["FOCUS_DECOR_ICONS"]                                        = "Dekorationssymbole anzeigen"
L["FOCUS_DECOR_ITEM_S_ICON_NEXT_TITLE"]                       = "Dekorationssymbol neben Titel anzeigen. Erfordert „Quest-Typ-Symbole anzeigen\" in Anzeige."

-- =====================================================================
-- OptionsData.lua Features — Appearances
-- =====================================================================
L["FOCUS_SHOW_APPEARANCES"]                                   = "Vorlagen zeigen"
-- L["FOCUS_TRACKED_TRANSMOG_APPEARANCES_LIST"]               = "Show tracked transmog appearances in the list."
-- L["FOCUS_INCLUDE_COLLECTED_APPEARANCES_TRACKER"]           = "Include collected appearances in the tracker. When off, only appearances you have not yet collected are shown."
L["FOCUS_APPEARANCE_ICONS"]                                   = "Vorlagensymbole anzeigen"
-- L["FOCUS_APPEARANCE_ICON_NEXT_TITLE"]                      = "Show each appearance's icon next to the title. Requires 'Show quest type icons' in Display."
-- L["FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON"]               = "Use transmog list icon"
-- L["FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON_DESC"]          = "Use the in-game Appearances / transmog list icon for every row instead of each appearance's item icon. If that icon cannot be resolved, the item icon is used."
-- L["FOCUS_SHOW_APPEARANCE_WARDROBE"]                        = "Show wardrobe"
-- L["FOCUS_OPEN_APPEARANCES_COLLECTIONS"]                    = "Open Collections"
-- L["FOCUS_UNTRACK_APPEARANCE"]                              = "Untrack appearance"
-- L["FOCUS_APPEARANCE_HORIZON_CONTROLS_HINT"]                = "Horizon: Shift-click map; with TomTom waypoints enabled, that click also sets the arrow. Ctrl-click Collections, Alt-click dressing room. Right-click clears focus or untracks."

-- =====================================================================
-- OptionsData.lua Features — Adventure Guide
-- =====================================================================
L["FOCUS_ADVENTURE_GUIDE"]                                    = "Abenteuerführer"
L["FOCUS_TRAVELER_S_LOG"]                                     = "Reisetagebuch anzeigen"
L["FOCUS_TRACKED_TRAVELER_S_LOG_OBJECTIVES_SHIFT"]            = "Verfolgte Reisetagebuchziele (Umschalt+Klick im Abenteuerführer) in der Liste anzeigen."
L["FOCUS_AUTO_REMOVE_COMPLETED_ACTIVITIES"]                   = "Abgeschlossene Aktivitäten automatisch entfernen"
L["FOCUS_AUTOMATICALLY_STOP_TRACKING_TRAVELER_S_LOG"]         = "Reisetagebuchaktivitäten nach Abschluss automatisch nicht mehr verfolgen."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["FOCUS_SCENARIO_EVENTS"]                                    = "Szenarioereignisse anzeigen"
L["FOCUS_ACTIVE_SCENARIO_DELVE_ACTIVITIES_DELVES_APP"]        = "Aktive Szenario- und Tiefen-Aktivitäten anzeigen. Tiefen in Tiefen; andere in Szenario-Ereignisse."
L["FOCUS_TRACK_DELVE_DUNGEON_SCENARIO_ACTIVITIES"]            = "Tiefen-, Dungeon- und Szenarioaktivitäten verfolgen."
L["FOCUS_DELVES_APPEAR_DELVES_SECTION_DUNGEONS_DUNGEON"]      = "Tiefen in Tiefen; Dungeons in Dungeon; andere Szenarien in Szenarioereignisse."
L["FOCUS_DELVES_APPEAR_DELVES_SECTION_SCENARIOS"]             = "Tiefen in Tiefen; andere Szenarien in Szenario-Ereignisse."
L["FOCUS_DELVE_AFFIX_NAMES"]                                  = "Tiefen-Affix-Namen"
L["FOCUS_DELVE_DUNGEON"]                                      = "Nur Tiefen & Dungeons"
L["FOCUS_SCENARIO_DEBUG_LOGGING"]                             = "Szenario-Debug-Protokoll"
L["FOCUS_LOG_SCENARIO_API_DATA_CHAT_H"]                       = "Szenario-API-Daten im Chat protokollieren. /h debug focus scendebug zum Umschalten."
L["FOCUS_PRINTS_C_SCENARIOINFO_CRITERIA_WIDGET_DATA"]         = "Gibt C_ScenarioInfo-Kriterien und Widget-Daten aus. Hilft bei Anzeigeproblemen wie Abundance 46/300."
L["FOCUS_HIDE_CATEGORIES_DELVE_DUNGEON"]                      = "Andere Kategorien in Tiefe oder Dungeon verbergen"
L["FOCUS_DELVES_PARTY_DUNGEONS_DELVE_DUNG"]                   = "In Tiefen oder Gruppen-Dungeons nur Tiefe/Dungeon-Abschnitt anzeigen."
L["FOCUS_DELVE_NAME_SECTION_HEADER"]                          = "Tiefen-Namen als Abschnitts-Header verwenden"
L["FOCUS_A_DELVE_DELVE_NAME_TIER_AFFIXES"]                    = "In Tiefe: Tiefenname, Stufe und Affixe als Abschnitts-Header statt separatem Banner. Aus: Tiefen-Block über Liste."
L["FOCUS_AFFIX_NAMES_DELVES"]                                 = "Zeige Affix-Namen in Tiefen"
L["FOCUS_SEASON_AFFIX_NAMES_FIRST_DELVE_ENTRY"]               = "Saison-Affix-Namen beim ersten Tiefen-Eintrag anzeigen. Erfordert Blizzard-Widgets; evtl. nicht bei Tracker-Ersatz."
L["FOCUS_CINEMATIC_SCENARIO_BAR"]                             = "Filmische Szenarioleiste"
L["FOCUS_TIMER_PROGRESS_BAR_SCENARIO_ENTRIES"]                = "Timer und Fortschrittsbalken für Szenarioeinträge anzeigen."
L["FOCUS_TIMER"]                                              = "Timer anzeigen"
L["FOCUS_COUNTDOWN_TIMER_TIMED_QUESTS_EVENTS_SCEN"]           = "Countdown-Timer bei zeitgesteuerten Quests, Events und Szenarien. Aus: Timer für alle ausgeblendet."
L["FOCUS_TIMER_SCENARIOS"]                                    = "Timer für Szenarien & Tiefen"
L["FOCUS_TIMER_SCENARIOS_DESC"]                               = "Countdown-Timer für Szenario-, Tiefen- und Dungeon-Einträge."
L["FOCUS_TIMER_WORLD"]                                        = "Timer für Welt- & Abgesandten-Quests"
L["FOCUS_TIMER_WORLD_DESC"]                                   = "Countdown timer for world quests and callings."
L["FOCUS_TIMER_QUEST_LOG"]                                    = "Timer für Quest-Log (zeitlich begrenzt)"
L["FOCUS_TIMER_QUEST_LOG_DESC"]                               = "Countdown timer for dailies, weeklies, and other quest log entries with a time limit."
L["FOCUS_TIMER_DISPLAY"]                                      = "Timer-Anzeige"
L["FOCUS_COLOUR_TIMER_REMAINING"]                             = "Timer nach verbleibender Zeit einfärben"
L["FOCUS_GREEN_PLENTY_OF_LEFT_YELLOW_RUNNING"]                = "Grün bei viel Zeit, gelb bei wenig, rot bei kritisch."
L["FOCUS_WHERE_COUNTDOWN_BAR_BELOW_OBJECTIVES"]               = "Countdown-Position: Leiste unter Zielen oder Text neben dem Questnamen."
L["FOCUS_BAR_BELOW"]                                          = "Leiste unten"
L["FOCUS_INLINE_BESIDE_TITLE"]                                = "Eingebettet neben Titel"

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["FOCUS_FONT_FAMILY"]                                        = "Schriftart"
L["FOCUS_TITLE_FONT"]                                         = "Titelschriftart"
L["VISTA_ZONE_FONT"]                                          = "Zonenschriftart"
L["FOCUS_OBJECTIVE_FONT"]                                     = "Zielschriftart"
L["FOCUS_SECTION_FONT"]                                       = "Abschnittsschriftart"
L["FOCUS_GLOBAL_FONT"]                                        = "Globale Schriftart verwenden"
L["FOCUS_FONT_FAMILY_QUEST_TITLES"]                           = "Schriftart für Quest-Titel"
L["FOCUS_FONT_FAMILY_ZONE_LABELS"]                            = "Schriftart für Zonenbezeichnungen"
L["FOCUS_FONT_FAMILY_OBJECTIVE_TEXT"]                         = "Schriftart für Zieltext"
L["FOCUS_FONT_FAMILY_SECTION_HEADERS"]                        = "Schriftart für Abschnittsüberschriften"
L["FOCUS_HEADER_SIZE"]                                        = "Kopfzeilengröße"
L["FOCUS_HEADER_FONT_SIZE"]                                   = "Größe der Kopfzeilenschriftart"
L["FOCUS_TITLE_SIZE"]                                         = "Titelgröße"
L["FOCUS_QUEST_TITLE_FONT_SIZE"]                              = "Größe der Quest-Titelschriftart"
L["FOCUS_OBJECTIVE_SIZE"]                                     = "Zielgröße"
L["FOCUS_OBJECTIVE_TEXT_FONT_SIZE"]                           = "Größe der Zielschriftart"
L["FOCUS_ZONE_SIZE"]                                          = "Zonengröße"
L["FOCUS_ZONE_LABEL_FONT_SIZE"]                               = "Größe der Zonenbezeichnungsschriftart"
L["FOCUS_SECTION_SIZE"]                                       = "Abschnittsgröße"
L["FOCUS_SECTION_HEADER_FONT_SIZE"]                           = "Größe der Schriftart für Abschnitte"
L["FOCUS_PROGRESS_BAR_FONT"]                                  = "Fortschrittsbalkenschriftart"
L["FOCUS_FONT_FAMILY_PROGRESS_BAR_LABEL"]                     = "Schriftart für die Fortschrittsbalkensbeschriftung"
L["FOCUS_PROGRESS_BAR_TEXT_SIZE"]                             = "Fortschrittsbalkentextgröße"
L["FOCUS_FONT_SIZE_PROGRESS_BAR_LABEL_ADJUSTS"]               = "Schriftgröße für die Beschriftung des Fortschrittsbalkens. Ändert auch die Höhe des Balkens. Betrifft Questziele, den Szenariofortschritt und die Szenario-Zeit-Balken."
L["FOCUS_PROGRESS_BAR_FILL"]                                  = "Füllung des Fortschrittsbalkens"
L["FOCUS_PROGRESS_BAR_TEXT"]                                  = "Text des Fortschrittsbalkens"
L["FOCUS_OUTLINE"]                                            = "Kontur"
L["FOCUS_FONT_OUTLINE_STYLE"]                                 = "Schriftkonturstil"

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["FOCUS_HEADER_TEXT_CASE"]                                   = "Kopfzeilen-Groß-/Kleinschreibung"
L["FOCUS_DISPLAY_CASE_HEADER"]                                = "Groß-/Kleinschreibung für Kopfzeile."
L["FOCUS_SECTION_HEADER_CASE"]                                = "Abschnitts-Header Groß-/Kleinschreibung"
L["FOCUS_DISPLAY_CASE_CATEGORY_LABELS"]                       = "Groß-/Kleinschreibung für Kategorie-Labels."
L["FOCUS_QUEST_TITLE_CASE"]                                   = "Quest-Titel Groß-/Kleinschreibung"
L["FOCUS_DISPLAY_CASE_QUEST_TITLES"]                          = "Groß-/Kleinschreibung für Quest-Titel."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["FOCUS_TEXT_SHADOW"]                                        = "Textschatten anzeigen"
L["FOCUS_ENABLE_DROP_SHADOW_TEXT"]                            = "Schattierung für Text aktivieren."
L["FOCUS_SHADOW_X"]                                           = "Schatten X"
L["FOCUS_HORIZONTAL_SHADOW_OFFSET"]                           = "Horizontaler Schattenversatz."
L["FOCUS_SHADOW_Y"]                                           = "Schatten Y"
L["FOCUS_VERTICAL_SHADOW_OFFSET"]                             = "Vertikaler Schattenversatz."
L["FOCUS_SHADOW_ALPHA"]                                       = "Schattendeckkraft"
L["FOCUS_SHADOW_OPACITY"]                                     = "Schattendeckkraft (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["FOCUS_MYTHIC_TYPOGRAPHY"]                                  = "Mythisch+-Typografie"
L["FOCUS_DUNGEON_NAME_SIZE"]                                  = "Verliesnamengröße"
L["FOCUS_FONT_SIZE_DUNGEON_NAME_PX"]                          = "Schriftgröße für Dungeon-Namen (8–32 px)."
L["FOCUS_DUNGEON_NAME_COLOUR"]                                = "Verliesnamenfarbe"
L["FOCUS_TEXT_COLOUR_DUNGEON_NAME"]                           = "Textfarbe für Dungeon-Namen."
L["FOCUS_TIMER_SIZE"]                                         = "Timer-Größe"
L["FOCUS_FONT_SIZE_TIMER_PX"]                                 = "Schriftgröße für Timer (8–32 px)."
L["FOCUS_TIMER_COLOUR"]                                       = "Timer-Farbe"
L["FOCUS_TEXT_COLOUR_TIMER"]                                  = "Textfarbe für Timer (in Zeit)."
L["FOCUS_TIMER_OVERTIME_COLOUR"]                              = "Timer-Überzeit-Farbe"
L["FOCUS_TEXT_COLOUR_TIMER_LIMIT"]                            = "Textfarbe für Timer bei Überschreitung."
L["FOCUS_PROGRESS_SIZE"]                                      = "Fortschrittsgröße"
L["FOCUS_FONT_SIZE_ENEMY_FORCES_PX"]                          = "Schriftgröße für feindliche Streitkräfte (8–32 px)."
L["FOCUS_PROGRESS_COLOUR"]                                    = "Fortschrittsfarbe"
L["FOCUS_TEXT_COLOUR_ENEMY_FORCES"]                           = "Textfarbe für feindliche Streitkräfte."
L["FOCUS_BAR_FILL_COLOUR"]                                    = "Leistenfüllfarbe"
L["FOCUS_PROGRESS_BAR_FILL_COLOUR_PROGRESS"]                  = "Fortschrittsbalken-Füllfarbe (in Bearbeitung)."
L["FOCUS_BAR_COMPLETE_COLOUR"]                                = "Leistenfarbe (abgeschlossen)"
L["FOCUS_PROGRESS_BAR_FILL_COLOUR_ENEMY_FORCES"]              = "Fortschrittsbalkenfüllfarbe bei 100 % feindlicher Streitkräfte."
L["FOCUS_AFFIX_SIZE"]                                         = "Affix-Größe"
L["FOCUS_FONT_SIZE_AFFIXES_PX"]                               = "Schriftgröße für Affixe (8–32 px)."
L["FOCUS_AFFIX_COLOUR"]                                       = "Affix-Farbe"
L["FOCUS_TEXT_COLOUR_AFFIXES"]                                = "Textfarbe für Affixe."
L["FOCUS_BOSS_SIZE"]                                          = "Boss-Größe"
L["FOCUS_FONT_SIZE_BOSS_NAMES_PX"]                            = "Schriftgröße für Boss-Namen (8–32 px)."
L["FOCUS_BOSS_COLOUR"]                                        = "Boss-Farbe"
L["FOCUS_TEXT_COLOUR_BOSS_NAMES"]                             = "Textfarbe für Boss-Namen."
L["FOCUS_RESET_MYTHIC_TYPOGRAPHY"]                            = "Mythisch+-Typografie zurücksetzen"

-- =====================================================================
-- OptionsData.lua Appearance
-- =====================================================================
L["DASH_FRAME"]                                               = "Rahmen"
L["FOCUS_CLASS_COLOURS_DASHBOARD"]                            = "Klassenfarben – Dashboard"
-- L["FOCUS_CLASS_COLOURS"]                                   = "Class Colours"
-- L["FOCUS_ENABLE_CLASS_COLOURS"]                            = "Enable all class colours"
-- L["DASH_CLASS_COLOURS_MODULES_GLOBAL"]                     = "Toggle class colours on or off for all modules at once."
-- L["FOCUS_DASHBOARD"]                                       = "Dashboard"
-- L["FOCUS_CLASS_COLOURS_DESC"]                              = "Tint Focus header title, category section headers, main and between-section dividers, and super-tracked highlight bars and borders with your class colour."
-- L["PRESENCE_CLASS_COLOURS_DESC"]                           = "Tint Presence toast title and divider with your class colour."
-- L["VISTA_CLASS_COLOURS_DESC"]                              = "Tint Vista minimap, addon-bar, and panel borders and text with your class colour."
-- L["INSIGHT_CLASS_COLOURS_DESC"]                            = "Use class colour for player tooltip name, class line, and border."
-- L["CACHE_CLASS_COLOURS_DESC"]                              = "Tint Cache loot icon glow and edit/anchor borders with your class colour."
-- L["ESSENCE_CLASS_COLOURS_DESC"]                            = "Tint the character name on the Essence sheet with your class colour."
L["AXIS_CLASS_COLOURS_DESC"]                                  = "Dashboard-Akzente, Trennlinien und Hervorhebungen mit Klassenfarbe einfärben."
-- L["DASH_THEME"]                                            = "Theme"
-- L["FOCUS_DASHBOARD_BACKGROUND"]                            = "Dashboard background"
L["DASH_BACKGROUND"]                                          = "Background style for the module dashboard window (Axis). Default is flat; Midnight uses bundled artwork; Specialisation (auto) uses the in-game talent UI background for your current specialization."
L["FOCUS_DASHBOARD_BACKGROUND_MINIMALISTIC"]                  = "Minimalistisch"
-- L["FOCUS_DASHBOARD_BACKGROUND_MIDNIGHT"]                   = "Midnight"
L["FOCUS_DASHBOARD_BACKGROUND_TELDRASSIL_BURNS"]              = "Teldrassil (brennend)"
L["FOCUS_DASHBOARD_BACKGROUND_NIGHTFAE"]                      = "Nachtfae"
L["FOCUS_DASHBOARD_BACKGROUND_ARDENWEALD"]                    = "Ardenwald"
-- L["FOCUS_DASHBOARD_BACKGROUND_ZIN_AZSHARI"]                = "Zin-Azshari"
L["FOCUS_DASHBOARD_BACKGROUND_SURAMAR_GARDEN"]                = "Suramar-Gärten"
-- L["DASH_BACKGROUND_QUEL_THALAS"]                           = "Quel'Thalas"
-- L["FOCUS_DASHBOARD_BACKGROUND_TWILIGHT_VINEYARDS"]         = "Twilight Vineyards"
-- L["FOCUS_DASHBOARD_BACKGROUND_ZUL_AMAN"]                   = "Zul'Aman"
-- L["FOCUS_DASHBOARD_BACKGROUND_ILLIDAN"]                    = "Illidan"
L["FOCUS_DASHBOARD_BACKGROUND_LICH_KING"]                     = "Der Lichkönig"
-- L["FOCUS_DASHBOARD_BACKGROUND_TBC_ANNIVERSARY"]            = "TBC Anniversary"
L["FOCUS_DASHBOARD_BACKGROUND_BELEDARS_LIGHT"]                = "Beledars Licht"
L["FOCUS_DASHBOARD_BACKGROUND_CLASS_TALENTS"]                 = "Spezialisierung (automatisch)"
-- L["FOCUS_DASHBOARD_BACKGROUND_OPACITY"]                    = "Dashboard background opacity"
-- L["FOCUS_ADJUST_OPACITY_OF_DASHBOARD_BACKGROUND"]          = "Adjust the opacity of the dashboard background (50–100%). Lower values let more of the game world show through."
-- L["DASHBOARD_TYPO_SECTION"]                                = "Dashboard text"
-- L["DASHBOARD_TYPO_FONT"]                                   = "Dashboard font"
-- L["DASHBOARD_TYPO_FONT_DESC"]                              = "Font for the Axis settings window (sidebar, search, and option rows). Separate from the Focus tracker font. For CJK or mixed-script welcome text, pick a broad-coverage font (e.g. 2002) if needed."
-- L["DASHBOARD_TYPO_SIZE"]                                   = "Dashboard text size"
-- L["DASHBOARD_TYPO_SIZE_DESC"]                              = "Nudge all dashboard text larger or smaller (−4 to +4), similar to Focus global font offset."
-- L["DASHBOARD_TYPO_OUTLINE"]                                = "Dashboard text outline"
L["DASHBOARD_TYPO_OUTLINE_DESC"]                              = "When on, dashboard UI text uses the standard outlined font style. Turn off for a softer, flat look."
-- L["DASHBOARD_TYPO_SHADOW"]                                 = "Dashboard text shadow"
L["DASHBOARD_TYPO_SHADOW_DESC"]                               = "Adds a subtle drop shadow behind dashboard text to improve readability on busy backgrounds."
L["FOCUS_BACKDROP_OPACITY"]                                   = "Hintergrunddeckkraft"
L["FOCUS_PANEL_BACKGROUND_OPACITY"]                           = "Panel-Hintergrunddeckkraft (0–1)."
L["FOCUS_BORDER"]                                             = "Rahmen anzeigen"
L["FOCUS_BORDER_AROUND_TRACKER"]                              = "Rahmen um den Zielverfolger anzeigen."
L["FOCUS_SCROLL_INDICATOR"]                                   = "Scroll-Indikator anzeigen"
L["FOCUS_A_VISUAL_HINT_LIST_CONTENT_TH"]                      = "Visuellen Hinweis anzeigen, wenn mehr Inhalt als sichtbar vorhanden."
L["FOCUS_SCROLL_INDICATOR_STYLE"]                             = "Scroll-Indikator-Stil"
L["FOCUS_CHOOSE_BETWEEN_A_FADE_GRADIENT_A"]                   = "Verlauf oder Pfeil für scrollbaren Inhalt wählen."
L["FOCUS_ARROW"]                                              = "Pfeil"
L["FOCUS_HIGHLIGHT_ALPHA"]                                    = "Hervorhebungs-Alpha"
L["FOCUS_OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]                 = "Deckkraft der Quest-Hervorhebung (0–1)."
L["FOCUS_BAR_WIDTH"]                                          = "Leistenbreite"
L["FOCUS_WIDTH_OF_BAR_STYLE_HIGHLIGHTS_PX"]                   = "Breite der Leistenhervorhebung (2–6 px)."

-- =====================================================================
-- OptionsData.lua Organisation
-- =====================================================================
L["FOCUS_ACTIVITY"]                                           = "Aktivität"
L["FOCUS_CONTENT"]                                            = "Inhalt"
L["FOCUS_SORTING"]                                            = "Sortierung"
L["FOCUS_ELEMENTS"]                                           = "Elemente"
L["FOCUS_CATEGORY_ORDER"]                                     = "Fokus-Kategoriereihenfolge"
L["FOCUS_CATEGORY_COLOUR_BAR"]                                = "Kategoriefarbe für Leiste"
L["FOCUS_CHECKMARK_COMPLETED"]                                = "Häkchen für abgeschlossen"
L["FOCUS_CURRENT_QUEST_CATEGORY"]                             = "Aktuelle Quest-Kategorie"
L["FOCUS_CURRENT_QUEST_WINDOW"]                               = "Aktuelle Quest-Fenster"
L["FOCUS_QUESTS_RECENT_PROGRESS_TOP"]                         = "Quests mit kürzlichem Fortschritt oben anzeigen."
L["FOCUS_RECENT_QUEST_SECONDS"]                               = "Sekundenfortschritt für aktuelle Quest (30–120)."
L["FOCUS_QUEST_PROGRESSION_SECTION"]                          = "Quests mit Fortschritt in der letzten Minute erscheinen in eigenem Abschnitt."
L["FOCUS_SHOW_ZONE_EVENTS"]                                   = "Sektion für Zonenereignisse"
L["FOCUS_SHOW_ZONE_EVENTS_DESC"]                              = "Show the Events in Zone section for nearby unaccepted quests and zone event quests."
L["FOCUS_SHOW_ZONE_EVENTS_TIP"]                               = "When off, those quests appear in their normal categories instead."
L["FOCUS_CATEGORY_ORDER"]                                     = "Fokus-Kategoriereihenfolge"
L["FOCUS_CATEGORIES_REORDER_EXCEPT_DELVES_SCENARIOS"]         = "Ziehen zum Ändern der Kategorie-Reihenfolge. Tiefen und Szenario-Ereignisse bleiben zuerst."
L["FOCUS_CATEGORIES_REORDER_EXCEPT_DELVES_SCENARIOS_TIP"]     = "Ziehen zum Ändern der Reihenfolge. Tiefen und Szenarien bleiben zuerst."
L["FOCUS_SORT_MODE"]                                          = "Fokus-Sortiermethode"
L["FOCUS_ENTRY_NUMBER_IN_CATEGORY"]                           = "Reihenfolge der Einträge innerhalb jeder Kategorie."
L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS"]                         = "Angenommene Quests automatisch verfolgen"
L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS_TIP"]                     = "Angenommene Quests (nur Questlog, nicht Weltquests) automatisch zum Zielverfolger hinzufügen."
L["FOCUS_CTRL_FOCUS_REMOVE"]                                  = "Strg für Fokus & Entfernen erforderlich"
L["FOCUS_CTRL_FOCUS_REMOVE_MOUSECLICK"]                       = "Strg für Fokus/Hinzufügen (Links) und Entfokussieren/Entfernen (Rechts) erforderlich, um Fehlklicks zu vermeiden."
L["FOCUS_CTRL_FOCUS_UNTRACK"]                                 = "Strg für Fokus / Nicht verfolgen"
L["FOCUS_CTRL_CLICK_COMPLETE"]                                = "Strg für Klickabschluss"
L["FOCUS_CLASSIC_CLICK_BEHAVIOUR"]                            = "Klassisches Klick-Verhalten verwenden"
L["FOCUS_CLASSIC_CLICKS"]                                     = "Klassische Klicks"
-- === Focus Click Profiles ===
L["FOCUS_CLICK_PROFILE"]                                      = "Mausklickprofil"
L["FOCUS_CLICK_PROFILE_DESC"]                                 = "Choose how mouse clicks on tracker entries behave."
L["FOCUS_ICON_CLICK_ACTION"]                                  = "Quest/appearance icon click"
L["FOCUS_ICON_CLICK_ACTION_DESC"]                             = "Choose what happens when you click the quest or appearance icon itself, when that icon click behavior is shown."
-- L["FOCUS_PROFILE_HORIZON_PLUS"]                            = "Horizon+"
L["FOCUS_PROFILE_BLIZZARD_DEFAULT"]                           = "Blizzard-Standard"
L["FOCUS_PROFILE_CUSTOM"]                                     = "Angepasst"
L["FOCUS_COMING_SOON"]                                        = "In Kürze"
L["FOCUS_CLICK_COMBOS"]                                       = "Angepasste Belegung"
-- L["FOCUS_CLICK_COMBO_LOCKED_TOOLTIP"]                      = "Fixed for this profile. Select Custom to edit shortcuts."
L["FOCUS_CLICK_SAFETY"]                                       = "Sicherheit"
L["FOCUS_COMBO_LEFT"]                                         = "Linksklick"
L["FOCUS_COMBO_SHIFT_LEFT"]                                   = "UMSCH+Linksklick"
L["FOCUS_COMBO_CTRL_LEFT"]                                    = "STRG+Linksklick"
L["FOCUS_COMBO_ALT_LEFT"]                                     = "ALT+Linksklick"
L["FOCUS_COMBO_RIGHT"]                                        = "Rechtsklick"
L["FOCUS_COMBO_SHIFT_RIGHT"]                                  = "UMSCH+Rechtsklick"
L["FOCUS_COMBO_CTRL_RIGHT"]                                   = "STRG+Rechtsklick"
-- L["FOCUS_COMBO_ALT_RIGHT"]                                 = "Alt + Right click"
L["FOCUS_CLICK_ACTION_NONE"]                                  = "Nichts tun"
L["FOCUS_CLICK_ACTION_SUPER_TRACK"]                           = "Quest fokussieren"
-- L["FOCUS_CLICK_ACTION_OPEN_DETAILS"]                       = "Open relevant details"
L["FOCUS_CLICK_ACTION_OPEN_PROFESSION"]                       = "Berufsfenster oder Quest-Details öffnen"
L["FOCUS_CLICK_ACTION_OPEN_QUEST_LOG"]                        = "Quest-Log öffnen"
L["FOCUS_CLICK_ACTION_UNTRACK"]                               = "Entfolgen"
L["FOCUS_CLICK_ACTION_CONTEXT_MENU"]                          = "Kontextmenü"
L["FOCUS_CLICK_ACTION_SHARE"]                                 = "Mit Gruppe teilen"
L["FOCUS_CLICK_ACTION_ABANDON"]                               = "Quest abbrechen"
L["FOCUS_CLICK_ACTION_WOWHEAD"]                               = "Wowhead-Link"
L["FOCUS_CLICK_ACTION_CHAT_LINK"]                             = "In Chat verlinken"
L["FOCUS_CLICK_ACTION_PREVIEW"]                               = "Vorschau"
L["FOCUS_APPEARANCE_CANNOT_SHARE"]                            = "Vorlagen können nicht wie Quests geteilt werden."
L["FOCUS_QUEST_DETAILS_AFTER_COMBAT"]                         = "Quest-Details werden nach dem Kampf geöffnet."
L["FOCUS_SHARE_PARTY"]                                        = "Mit Gruppe teilen"
L["FOCUS_ABANDON_QUEST"]                                      = "Quest abbrechen"
L["FOCUS_CONTEXT_FOCUS_QUEST"]                                = "Quest fokussieren"
L["FOCUS_STOP_TRACKING"]                                      = "Entfolgen"
L["FOCUS_CONTEXT_OPEN_ACHIEVEMENT"]                           = "Erfolg anzeigen"
L["FOCUS_CONTEXT_OPEN_ENDEAVOR"]                              = "Unterfangen anzeigen"
L["FOCUS_CONTEXT_OPEN_RECIPE"]                                = "Rezept anzeigen"
L["FOCUS_CONTEXT_OPEN_DECOR_CATALOG"]                         = "In Katalog öffnen"
L["FOCUS_CONTEXT_PREVIEW_DECOR"]                              = "Dekorvorschau"
L["FOCUS_CONTEXT_SHOW_DECOR_MAP"]                             = "Auf Karte zeigen"
L["FOCUS_CONTEXT_OPEN_TRAVELERS_LOG"]                         = "Reisetagebuch öffnen"
L["FOCUS_CONTEXT_SET_RARE_WAYPOINT"]                          = "Wegpunkt setzen"
L["FOCUS_CONTEXT_CLEAR_RARE_FOCUS"]                           = "Kartenfokus entfernen"
L["FOCUS_TRACKED_CONTENT_CANNOT_SHARE"]                       = "Dieser Eintrag kann nicht mit der Gruppe geteilt werden."
L["FOCUS_CANNOT_SHARE_QUEST"]                                 = "Diese Quest kann nicht geteilt werden."
L["FOCUS_REQUIRE_PARTY_SHARE"]                                = "Ihr müsst in einer Gruppe sein, um diese Quest zu teilen."
L["FOCUS_LEFT_CLICK_MAP_RIGHT_CLICK_ABANDON"]                 = "Ein: Linksklick öffnet Questkarte, Rechtsklick Teilen/Abbruch (Blizzard). Aus: Linksklick fokussiert, Rechtsklick nicht verfolgen; Strg+Rechts teilt."
L["FOCUS_ANIMATIONS"]                                         = "Focus animations"
L["FOCUS_SLIDE_FADE_QUESTS"]                                  = "Wisch- und Verblassungseffekte für Quests aktivieren."
L["FOCUS_OBJECTIVE_PROGRESS_FLASH"]                           = "Zielfortschrittsleuchten"
L["FOCUS_FLASH_OBJECTIVE_COMPLETION"]                         = "Leuchten bei Ziel-Abschluss anzeigen."
L["FOCUS_FLASH_INTENSITY"]                                    = "Leuchtintensität"
L["FOCUS_OBJECTIVE_PROGRESS_FLASH_VISIBILITY"]                = "Auffälligkeit des Zielabschlussleuchtens."
L["FOCUS_FLASH_COLOUR"]                                       = "Leuchtfarbe"
L["FOCUS_FLASH_COLOUR_DESC"]                                  = "Farbe des Zielabschlussleuchtens."
L["FOCUS_SUBTLE"]                                             = "Dezent"
L["FOCUS_MEDIUM"]                                             = "Mittel"
L["FOCUS_STRONG"]                                             = "Stark"
L["FOCUS_REQUIRE_CTRL_CLICK_COMPLETE"]                        = "Strg für Klick zum Abschließen erforderlich"
L["FOCUS_REQUIRES_CTRL_LEFT_CLICK_COMPLETE_AUTO"]             = "EIN: Strg+Linksklick für Klick-Abschluss. AUS: einfacher Linksklick (Blizzard-Standard). Nur bei klickbaren Quests."
L["FOCUS_SUPPRESS_UNTRACKED_UNTIL_RELOAD"]                    = "Nicht verfolgte bis Neuladen unterdrücken"
L["FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS"]                   = "EIN: Rechtsklick Nicht verfolgen versteckt bis Neuladen oder neuer Sitzung. AUS: erscheinen wieder bei Zonen-Rückkehr."
L["FOCUS_PERMANENTLY_SUPPRESS_UNTRACKED_QUESTS"]              = "Nicht verfolgte Quests dauerhaft unterdrücken"
L["FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS_DESC"]              = "An: Rechtsklick Nicht verfolgen versteckt dauerhaft (über Neuladen). Vorrang vor „Bis Neuladen\". Annehmen entfernt von Sperrliste."
L["FOCUS_KEEP_CAMPAIGN_CATEGORY"]                             = "Kampagnen-Quest in Kategorie bleiben"
L["FOCUS_CAMPAIGN_READY_STAY"]                                = "An: abgabebereite Kampagnen-Quests bleiben in Kampagne statt in Abgeschlossen."
L["FOCUS_KEEP_IMPORTANT_QUESTS_CATEGORY"]                     = "Wichtige Quests in Kategorie bleiben"
L["FOCUS_IMPORTANT_READY_STAY"]                               = "An: abgabebereite wichtige Quests bleiben in Wichtig statt in Abgeschlossen."
L["FOCUS_TOMTOM_QUEST_WAYPOINT"]                              = "TomTom-Quest-Wegpunkt"
L["FOCUS_TOMTOM_QUEST_WAYPOINT_TIP"]                          = "TomTom-Wegpunkt setzen beim Fokussieren einer Quest."
L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_NEXT_QUEST"]            = "TomTom erforderlich. Der Pfeil zeigt auf das nächste Questziel."
L["FOCUS_TOMTOM_RARE_WAYPOINT"]                               = "TomTom-Rare-Boss-Wegpunkt"
L["FOCUS_TOMTOM_WAYPOINT_RARE_CLICK"]                         = "TomTom-Wegpunkt setzen beim Klicken auf einen seltenen Boss."
L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_RARE"]                  = "TomTom erforderlich. Der Pfeil zeigt auf die Position des seltenen Bosses."
L["FOCUS_FIND_GROUP"]                                         = "Gruppe finden"
L["FOCUS_GROUP_QUEST_SEARCH_CLICK"]                           = "Klicken, um eine Gruppe für diese Quest zu suchen."

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
L["FOCUS_BLACKLIST"]                                          = "Sperrliste"
L["FOCUS_BLACKLIST_UNTRACKED"]                                = "Nicht verfolgte sperren"
L["FOCUS_ENABLE_BLACKLIST_UNTRACKED_BEHAVIOUR_ADD_QUEST"]     = "„Nicht verfolgte sperren\" in Verhalten aktivieren, um Quests hier hinzuzufügen."
L["FOCUS_HIDDEN_QUESTS"]                                      = "Versteckte Quests"
L["FOCUS_QUESTS_HIDDEN_RIGHT_CLICK_UNTRACK"]                  = "Quests versteckt durch Rechtsklick Nicht verfolgen."
L["FOCUS_BLACKLISTED_QUESTS"]                                 = "Gesperrte Quests"
L["FOCUS_PERMANENTLY_SUPPRESSED_QUESTS"]                      = "Dauerhaft unterdrückte Quests"
L["FOCUS_RIGHT_CLICK_UNTRACK_QUESTS_PERMANENTLY_SUPPRESS"]    = "Rechtsklick Nicht verfolgen mit „Dauerhaft unterdrücken\" aktiviert fügt Quests hier hinzu."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["PRESENCE_QUEST_TYPE_ICONS"]                                = "Quest-Typsymbole anzeigen"
L["PRESENCE_QUEST_TYPE_ICON_FOCUS_TRACKER_QUEST"]             = "Quest-Typsymbol im Focus-Zielverfolger anzeigen."
L["PRESENCE_QUEST_TYPE_ICONS_TOASTS"]                         = "Quest-Typsymbole auf Toasts anzeigen"
L["PRESENCE_QUEST_TYPE_ICON_PRESENCE_TOASTS_QUEST"]           = "Quest-Typsymbol auf Präsenz-Toasts anzeigen."
L["PRESENCE_TOAST_ICON_SIZE"]                                 = "Toast-Symbolgröße"
L["PRESENCE_QUEST_ICON_SIZE_PRESENCE_TOASTS_PX"]              = "Quest-Symbolgröße auf Präsenz-Toasts (16–36 px). Standard 24."
L["PRESENCE_HIDE_QUEST_UPDATE_TITLE"]                         = "Quest-Update-Titel verbergen"
L["PRESENCE_OBJECTIVE_LINE_QUEST_PROGRESS_TOAST"]             = "Nur Zielzeile auf Quest-Fortschritt-Toasts (z.B. 7/10 Eberfelle), ohne Questname oder Header."
L["PRESENCE_SHOW_DISCOVERY_LINE"]                             = "Entdeckungszeile anzeigen"
L["PRESENCE_DISCOVERY_LINE"]                                  = "Entdeckungszeile"
L["PRESENCE_SHOW_DISCOVERED"]                                 = "„Entdeckt\" unter Zone/Unterzone bei neuem Gebiet anzeigen."
L["PRESENCE_FRAME_VERTICAL_POSITION"]                         = "Rahmen vertikale Position"
L["PRESENCE_VERTICAL_OFFSET_OF_PRESENCE_FRAME_CENTER"]        = "Vertikaler Offset des Präsenz-Rahmens von Mitte (-300 bis 0)."
L["PRESENCE_FRAME_SCALE"]                                     = "Rahmenskalierung"
L["PRESENCE_FRAME_SCALE_TIP"]                                 = "Skalierung des Präsenz-Rahmens (0,5–2)."
L["PRESENCE_BOSS_EMOTE_COLOUR"]                               = "Boss-Emote-Farbe"
L["PRESENCE_COLOUR_RAID_DUNGEON_BOSS_EMOTE"]                  = "Farbe von Boss-Emote-Text in Schlachtzügen und Dungeons."
L["PRESENCE_DISCOVERY_LINE_COLOUR"]                           = "Entdeckungs-Zeilen-Farbe"
L["PRESENCE_COLOUR_OF_DISCOVERED_LINE_UNDER_ZONE_TIP"]        = "Farbe der „Entdeckt\"-Zeile unter dem Zonentext."
L["PRESENCE_NOTIFICATION_TYPES"]                              = "Benachrichtigungstypen"
L["PRESENCE_NOTIFICATIONS"]                                   = "Benachrichtigungen"
L["PRESENCE_NOTIFICATION_ACHIEVEMENT_CRITERIA_UPDATE"]        = "Benachrichtigung bei Erfolgs-Kriterien-Update (verfolgte immer; andere wenn Blizzard ID liefert)."
L["PRESENCE_ZONE_ENTRY"]                                      = "Zoneneintritt anzeigen"
L["PRESENCE_ZONE_CHANGE_ENTERING_A_AREA"]                     = "Zonenwechsel bei neuem Gebiet anzeigen."
L["PRESENCE_SUBZONE_CHANGES"]                                 = "Unterzonenwechsel anzeigen"
L["PRESENCE_SUBZONE_CHANGE_MOVING_WITHIN_SAME_ZONE"]          = "Unterzonenwechsel bei Bewegung in gleicher Zone anzeigen."
L["PRESENCE_HIDE_ZONE_NAME_SUBZONE_CHANGES"]                  = "Zonennamen bei Unterzonenwechsel verbergen"
L["PRESENCE_MOVING_BETWEEN_SUBZONES_WITHIN_SAME_ZONE"]        = "Bei Unterzonenwechsel in gleicher Zone nur Unterzonenname. Zonennamen erscheint bei neuer Zone."
L["PRESENCE_SUPPRESS_DELVE"]                                  = "In Tiefen unterdrücken"
-- L["PRESENCE_SUPPRESS_SCENARIO_PROGRESS_NOTIFICATIONS_DELVES"]= "Suppress scenario progress notifications in Delves."
-- L["PRESENCE_HIDE_DELVE_OBJECTIVE_UPDATE"]                  = "When on, hides objective update popups while in a Delve. Zone entry and completion toasts still show."
L["PRESENCE_SUPPRESS_ZONE_CHANGES_MYTHIC"]                    = "Zonenwechsel in Mythisch+ unterdrücken"
L["PRESENCE_MYTHICPLUS_SHOW_BOSS_EMOTES_ACHIEVEMENTS_LEVELS"]   = "In Mythisch+ nur Boss-Emotes, Erfolge und Levelaufstieg. Zone-, Quest- und Szenario-Benachrichtigungen verbergen."
L["PRESENCE_LEVEL"]                                           = "Stufenaufstieg anzeigen"
L["PRESENCE_LEVEL_NOTIFICATION"]                              = "Benachrichtigungen zu Stufenaufstiege anzeigen."
L["PRESENCE_BOSS_EMOTES"]                                     = "Boss-Emotes anzeigen"
L["PRESENCE_RAID_DUNGEON_BOSS_EMOTE_NOTIFICATIONS"]           = "Schlachtzug- und Dungeon-Boss-Emote-Benachrichtigungen anzeigen."
L["PRESENCE_ACHIEVEMENTS"]                                    = "Erfolge anzeigen"
L["PRESENCE_ACHIEVEMENT_EARNED_NOTIFICATIONS"]                = "Benachrichtigungen bei errungenen Erfolgen anzeigen."
L["PRESENCE_ACHIEVEMENT_PROGRESS"]                            = "Erfolgsfortschritt"
L["PRESENCE_SHOW_ACHIEVEMENT_EARNED"]                         = "Erfolg errungen"
L["PRESENCE_SHOW_QUEST_ACCEPTED"]                             = "Quest angenommen"
L["PRESENCE_SHOW_WORLD_QUEST_ACCEPTED"]                       = "Welt-Quest angenommen"
L["PRESENCE_SHOW_SCENARIO_COMPLETE"]                          = "Szenario abgeschlossen"
L["PRESENCE_SHOW_RARE_DEFEATED"]                              = "Seltener Gegner besiegt"
L["PRESENCE_NOTIFICATION_TRACKED_ACHIEVEMENT_CRITERIA"]       = "Benachrichtigung bei verfolgtem Erfolgs-Kriterien-Update anzeigen."
L["PRESENCE_QUEST_ACCEPT"]                                    = "Quest-Annahme anzeigen"
L["PRESENCE_NOTIFICATION_ACCEPTING_A_QUEST"]                  = "Benachrichtigung bei Quest-Annahme anzeigen."
L["PRESENCE_WORLD_QUEST_ACCEPT"]                              = "Weltquest-Annahme anzeigen"
L["PRESENCE_NOTIFICATION_ACCEPTING_A_WORLD_QUEST"]            = "Benachrichtigung bei Weltquest-Annahme anzeigen."
L["PRESENCE_SHOW_QUEST_COMPLETE"]                             = "Quest-Abschluss anzeigen"
L["PRESENCE_NOTIFICATION_COMPLETING_A_QUEST"]                 = "Benachrichtigung bei Quest-Abschluss anzeigen."
L["PRESENCE_SHOW_WORLD_QUEST_COMPLETE"]                       = "Weltquest-Abschluss anzeigen"
L["PRESENCE_NOTIFICATION_COMPLETING_A_WORLD_QUEST"]           = "Benachrichtigung bei Weltquest-Abschluss anzeigen."
L["PRESENCE_QUEST_PROGRESS"]                                  = "Quest-Fortschritt anzeigen"
L["PRESENCE_NOTIFICATION_QUEST_OBJECTIVES_UPDATE"]            = "Benachrichtigung bei Quest-Ziel-Update anzeigen."
L["PRESENCE_OBJECTIVE"]                                       = "Nur Ziel"
L["PRESENCE_QUEST_PROGRESS_HIDE_TITLE"]                       = "Nur Zielzeile auf Quest-Fortschritt-Toasts, „Quest-Update\"-Titel verbergen."
L["PRESENCE_SCENARIO_START"]                                  = "Szenariobeginn anzeigen"
L["PRESENCE_NOTIFICATION_ENTERING_A_SCENARIO_DELVE"]          = "Benachrichtigung bei Szenario- oder Tiefen-Eintritt anzeigen."
L["PRESENCE_SCENARIO_PROGRESS"]                               = "Szenariofortschritt anzeigen"
L["PRESENCE_NOTIFICATION_SCENARIO_DELVE_OBJECTIVES"]          = "Benachrichtigung bei Szenario- oder Tiefen-Ziel-Update anzeigen."
L["PRESENCE_ANIMATION"]                                       = "Animationen"
L["PRESENCE_ENABLE_ANIMATIONS"]                               = "Animationen aktivieren"
L["PRESENCE_ENABLE_ENTRANCE_EXIT_ANIMATIONS_PRESENCE"]        = "Ein- und Ausblendanimationen für Präsenz-Benachrichtigungen aktivieren."
L["PRESENCE_ENTRANCE_DURATION"]                               = "Einblenddauer"
L["PRESENCE_DURATION_OF_ENTRANCE_ANIMATION_SECONDS"]          = "Dauer der Einblendanimation in Sekunden (0,2–1,5)."
L["PRESENCE_EXIT_DURATION"]                                   = "Ausblenddauer"
L["PRESENCE_DURATION_OF_EXIT_ANIMATION_SECONDS"]              = "Dauer der Ausblendanimation in Sekunden (0,2–1,5)."
L["PRESENCE_HOLD_DURATION_SCALE"]                             = "Anzeigedauer-Multiplikator"
L["PRESENCE_MULTIPLIER_LONG_NOTIFICATION_STAY"]               = "Multiplikator für Anzeige-Dauer jeder Benachrichtigung (0,5–2)."
L["PRESENCE_PREVIEW"]                                         = "Vorschau"
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
L["DASH_TYPOGRAPHY"]                                          = "Typografie"
L["PRESENCE_MAIN_TITLE_FONT"]                                 = "Haupttitel-Schriftart"
L["PRESENCE_FONT_FAMILY_MAIN_TITLE"]                          = "Schriftart für den Haupttitel."
L["PRESENCE_SUBTITLE_FONT"]                                   = "Untertitel-Schriftart"
L["PRESENCE_FONT_FAMILY_SUBTITLE"]                            = "Schriftart für den Untertitel."
-- L["PRESENCE_RESET_TYPOGRAPHY_DEFAULTS"]                    = "Reset typography to defaults"
-- L["PRESENCE_RESET_PRESENCE_TYPOGRAPHY_OPTIONS_FONTS_SIZES"]= "Reset all Presence typography options (fonts, sizes, colours) to defaults."
-- L["PRESENCE_LARGE_NOTIFICATIONS"]                          = "Large notifications"
-- L["PRESENCE_MEDIUM_NOTIFICATIONS"]                         = "Medium notifications"
-- L["PRESENCE_SMALL_NOTIFICATIONS"]                          = "Small notifications"
-- L["PRESENCE_LARGE_PRIMARY_SIZE"]                           = "Large primary size"
-- L["PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_TITLES_ZONE"]     = "Font size for large notification titles (zone, quest complete, achievement, etc.)."
-- L["PRESENCE_LARGE_SECONDARY_SIZE"]                         = "Large secondary size"
-- L["PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_SUBTITLES"]       = "Font size for large notification subtitles."
-- L["PRESENCE_MEDIUM_PRIMARY_SIZE"]                          = "Medium primary size"
-- L["PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_TITLES_QUEST"]   = "Font size for medium notification titles (quest accept, subzone, scenario)."
-- L["PRESENCE_MEDIUM_SECONDARY_SIZE"]                        = "Medium secondary size"
-- L["PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_SUBTITLES"]      = "Font size for medium notification subtitles."
-- L["PRESENCE_SMALL_PRIMARY_SIZE"]                           = "Small primary size"
-- L["PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_TITLES_QUEST"]    = "Font size for small notification titles (quest progress, achievement progress)."
-- L["PRESENCE_SMALL_SECONDARY_SIZE"]                         = "Small secondary size"
-- L["PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_SUBTITLES"]       = "Font size for small notification subtitles."

-- =====================================================================
-- OptionsData.lua Dropdown options — Outline
-- =====================================================================
L["FOCUS_OUTLINE_NONE"]                                       = "Keine"
L["FOCUS_THICK_OUTLINE"]                                      = "Dicker Umriss"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["FOCUS_HIGHLIGHT_BAR_LEFT_EDGE"]                            = "Leiste (linker Rand)"
L["FOCUS_HIGHLIGHT_BAR_RIGHT_EDGE"]                           = "Leiste (rechter Rand)"
L["FOCUS_HIGHLIGHT_BAR_TOP_EDGE"]                             = "Leiste (oberer Rand)"
L["FOCUS_HIGHLIGHT_BAR_BOTTOM_EDGE"]                          = "Leiste (unterer Rand)"
L["FOCUS_HIGHLIGHT_OUTLINE_ONLY"]                             = "Nur Umriss"
L["FOCUS_HIGHLIGHT_SOFT_GLOW"]                                = "Sanftes Leuchten"
L["FOCUS_HIGHLIGHT_DUAL_EDGE_BARS"]                           = "Doppelrandleisten"
L["FOCUS_HIGHLIGHT_PILL_LEFT_ACCENT"]                         = "Akzentpille (links)"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["FOCUS_MYTHICPLUS_POSITION_TOP"]                            = "Oben"
L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"]                         = "Unten"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["VISTA_LOCATION_POSITION"]                                  = "Standortposition"
L["VISTA_PLACE_ZONE_NAME_ABOVE_BELOW_MINIMAP"]                = "Zonennamen über oder unter der Minikarte platzieren."
L["VISTA_COORDINATES_POSITION"]                               = "Koordinatenposition"
L["VISTA_PLACE_COORDINATES_ABOVE_BELOW_MINIMAP"]              = "Koordinaten über oder unter der Minikarte platzieren."
L["VISTA_CLOCK_POSITION"]                                     = "Uhrposition"
L["VISTA_PLACE_CLOCK_ABOVE_BELOW_MINIMAP"]                    = "Uhr über oder unter der Minikarte platzieren."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["FOCUS_TEXT_LOWER_CASE"]                                    = "Kleinbuchstaben"
L["FOCUS_TEXT_UPPER_CASE"]                                    = "Großbuchstaben"
L["FOCUS_TEXT_PROPER_CASE"]                                   = "Große Anfangsbuchstaben"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["FOCUS_TRACKED_LOG"]                                        = "Verfolgt / im Log"
L["FOCUS_LOG_MAX_SLOTS"]                                      = "Im Log / max. Plätze"

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["FOCUS_ALPHABETICAL"]                                       = "Alphabetisch"
L["FOCUS_QUEST_TYPE"]                                         = "Quest-Typ"
L["FOCUS_QUEST_LEVEL"]                                        = "Quest-Stufe"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["FOCUS_CUSTOM"]                                             = "Benutzerdefiniert"
L["FOCUS_ORDER"]                                              = "Reihenfolge"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["UI_DUNGEON"]                                               = "Dungeon"
L["UI_RAID"]                                                  = "Schlachtzug"
L["UI_DELVES"]                                                = "Tiefen"
L["UI_SCENARIO_EVENTS"]                                       = "Szenario"
L["UI_STAGE"]                                                 = "Phase"
L["UI_STAGE_X_X"]                                             = "Phase %d: %s"
L["UI_AVAILABLE_IN_ZONE"]                                     = "In Zone verfügbar"
L["UI_EVENTS_IN_ZONE"]                                        = "Zonenereignisse"
L["UI_CURRENT_EVENT"]                                         = "Aktuelles Ereignis"
L["UI_CURRENT_QUEST"]                                         = "Aktuelle Quest"
L["UI_CURRENT_ZONE"]                                          = "Aktuelle Zone"
L["UI_CAMPAIGN"]                                              = "Kampagne"
L["UI_IMPORTANT"]                                             = "Wichtig"
L["UI_LEGENDARY"]                                             = "Legendär"
L["UI_WORLD_QUESTS"]                                          = "Welt"
L["UI_WEEKLY_QUESTS"]                                         = "Wöchentlich"
L["UI_PREY"]                                                  = "Jagd"
L["UI_ABUNDANCE"]                                             = "Überfluss"
L["UI_ABUNDANCE_BAG"]                                         = "Überflussbeutel"
L["UI_ABUNDANCE_HELD"]                                        = "Überfluss gehalten"
L["UI_DAILY_QUESTS"]                                          = "Täglich"
L["UI_RARE_BOSSES"]                                           = "Seltene Gegner"
L["UI_ACHIEVEMENTS"]                                          = "Erfolge"
L["UI_ENDEAVORS"]                                             = "Unterfangen"
L["UI_DECOR"]                                                 = "Dekoration"
L["UI_RECIPES"]                                               = "Rezepte"
L["UI_ADVENTURE_GUIDE"]                                       = "Reisetagebuch"
L["UI_APPEARANCES"]                                           = "Vorlagen"
L["UI_QUESTS"]                                                = "Quests"
L["UI_READY_TO_TURN_IN"]                                      = "ABGABEBEREIT"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["PRESENCE_OBJECTIVES"]                                      = "ZIELE"
L["PRESENCE_OPTIONS"]                                         = "Optionen"
L["PRESENCE_OPEN_HORIZON_SUITE"]                              = "Horizon Suite öffnen"
L["PRESENCE_OPEN_FULL_HORIZON_SUITE_OPTIONS"]                 = "Öffnet das vollständige Horizon Suite-Optionsfenster zur Konfiguration von Focus, Presence, Vista und anderen Modulen."
-- L["PRESENCE_MINIMAP_SECTION"]                              = "Minimap icon"
L["PRESENCE_SHOW_MINIMAP_ICON"]                               = "Minikartensymbol anzeigen"
L["PRESENCE_A_CLICKABLE_ICON_MINIMAP_OPENS"]                  = "Zeigt ein klickbares Symbol auf der Minikarte, um das Optionsfenster zu öffnen."
-- L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER"]      = "Fade until minimap hover"
-- L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER_DESC"] = "When on, the icon stays faded until you move the cursor over the minimap. When off, it stays fully visible."
-- L["PRESENCE_LOCK_MINIMAP_BUTTON_POSITION"]                 = "Lock minimap button position"
-- L["PRESENCE_PREVENT_DRAGGING_HORIZON_MINIMAP_BUTTON"]      = "Prevent dragging the Horizon minimap button."
-- L["PRESENCE_RESET_MINIMAP_BUTTON_POSITION"]                = "Reset minimap button position"
-- L["PRESENCE_RESET_MINIMAP_BUTTON_DEFAULT_POSITION"]        = "Reset the minimap button to the default position (bottom-left)."
-- L["PRESENCE_DRAG_TO_MOVE_WHEN_UNLOCKED"]                   = "Drag to move (when unlocked)."
L["PRESENCE_LOCKED"]                                          = "Fixiert"
L["PRESENCE_DISCOVERED"]                                      = "Entdeckt"
L["PRESENCE_REFRESH"]                                         = "Aktualisieren"
L["PRESENCE_BEST_EFFORT_UNACCEPTED_QUESTS_EXPO"]              = "Nur bestmöglich. Manche nicht angenommenen Quests werden erst nach NPC-Interaktion oder Phasenbedingungen angezeigt."
L["PRESENCE_UNACCEPTED_QUESTS_X_MAP_X"]                       = "Nicht angenommene Quests - %s (Karte %s) - %d Treffer"
L["PRESENCE_LEVEL_UP"]                                        = "STUFENAUFSTIEG"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_80"]                       = "Ihr habt Stufe 80 erreicht"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_X"]                        = "Ihr habt Stufe %s erreicht"
L["PRESENCE_ACHIEVEMENT_EARNED"]                              = "ERFOLG ERRUNGEN"
L["PRESENCE_EXPLORING_THE_MIDNIGHT_ISLES"]                    = "Mitternachtsinseln erkunden"
L["PRESENCE_EXPLORING_KHAZ_ALGAR"]                            = "Khaz Algar erkunden"
L["PRESENCE_QUEST_COMPLETE"]                                  = "QUEST ABGESCHLOSSEN"
L["PRESENCE_OBJECTIVE_SECURED"]                               = "Ziel gesichert"
L["PRESENCE_AIDING_THE_ACCORD"]                               = "Dem Abkommen helfen"
L["PRESENCE_WORLD_QUEST"]                                     = "WELT-QUEST"
L["PRESENCE_WORLD_QUEST_COMPLETE"]                            = "WELT-QUEST ABGESCHLOSSEN"
L["PRESENCE_AZERITE_MINING"]                                  = "Azerit-Abbau"
L["PRESENCE_WORLD_QUEST_ACCEPTED"]                            = "WELT-QUEST ANGENOMMEN"
L["PRESENCE_QUEST_ACCEPTED"]                                  = "QUEST ANGENOMMEN"
L["PRESENCE_THE_FATE_OF_THE_HORDE"]                           = "Das Schicksal der Horde"
L["PRESENCE_NEW_QUEST"]                                       = "Neue Quest"
L["PRESENCE_QUEST_UPDATE"]                                    = "QUEST-FORTSCHRITT"
L["PRESENCE_BOAR_PELTS_7_10"]                                 = "Eberfelle: 7/10"
L["PRESENCE_DRAGON_GLYPHS_3_5"]                               = "Drachenglyphen: 3/5"
L["PRESENCE_TEST_COMMANDS"]                                   = "Präsenz-Testbefehle:"
L["PRESENCE_H_DEBUGTYPES_DUMP_NOTIFICATION"]                  = "  /h presence debugtypes - Benachrichtigungsoptionen und Blizzard-Unterdrückungsstatus ausgeben"
L["PRESENCE_PLAYING_DEMO_REEL_NOTIFICATION"]                  = "Präsenz: Demo wird abgespielt (alle Benachrichtigungstypen)..."
L["PRESENCE_H_HELP_TEST_CURRENT"]                             = "  /h presence         - Hilfe + aktuelle Zone testen"
L["PRESENCE_H_ZONE_TEST"]                                     = "  /h presence zone     - Zonenwechsel testen"
L["PRESENCE_H_SUBZONE_TEST"]                                  = "  /h presence subzone  - Unterzonenwechsel testen"
L["PRESENCE_H_DISCOVER_TEST_ZONE"]                            = "  /h presence discover - Zonenentdeckung testen"
L["PRESENCE_H_LEVEL_TEST"]                                    = "  /h presence level    - Levelaufstieg testen"
L["PRESENCE_H_BOSS_TEST"]                                     = "  /h presence boss     - Boss-Emote testen"
L["PRESENCE_H_ACHIEVEMENT_TEST"]                              = "  /h presence ach      - Erfolg testen"
L["PRESENCE_H_ACCEPT_TEST_QUEST"]                             = "  /h presence accept   - Quest angenommen testen"
L["PRESENCE_H_WORLD_QUEST_ACCEPT_TEST"]                       = "  /h presence wqaccept - Weltquest angenommen testen"
L["PRESENCE_H_SCENARIO_TEST"]                                 = "  /h presence scenario - Szenario-Start testen"
L["PRESENCE_H_QUEST_TEST_COMPLETE"]                           = "  /h presence quest    - Quest abgeschlossen testen"
L["PRESENCE_H_WORLD_QUEST_TEST"]                              = "  /h presence wq       - Weltquest testen"
L["PRESENCE_H_QUEST_UPDATE_TEST"]                             = "  /h presence update   - Quest-Update testen"
L["PRESENCE_H_ACHIEVEMENT_PROGRESS_TEST"]                     = "  /h presence achprogress - Erfolgsfortschritt testen"
L["PRESENCE_H_DEMO_REEL_TYPES"]                               = "  /h presence all      - Demo (alle Typen)"
L["PRESENCE_H_DEBUG_DUMP_STATE"]                              = "  /h presence debug    - Status im Chat ausgeben"
L["PRESENCE_H_DEBUGLIVE_TOGGLE_LIVE"]                         = "  /h presence debuglive - Live-Debug-Panel umschalten"

-- =====================================================================
-- OptionsData.lua Vista — General
L["VISTA_POSITION_LAYOUT"]                                    = "Position & Layout"

-- =====================================================================
L["VISTA_DESC"]                                               = "Minikarte"
L["VISTA_SIZE"]                                               = "Minikarten-Größe"
L["VISTA_WIDTH_HEIGHT_OF_MINIMAP_PIXELS"]                     = "Breite und Höhe der Minikarte in Pixeln (100–400)."
L["VISTA_CIRCULAR_MINIMAP"]                                   = "Runde Minikarte"
L["VISTA_CIRCULAR_SHAPE"]                                     = "Runde Form"
L["VISTA_A_CIRCULAR_MINIMAP_INSTEAD_OF_SQUARE"]               = "Runde Minikarte statt quadratisch verwenden."
-- L["VISTA_SHAPE"]                                           = "Shape"
-- L["VISTA_SHAPE_DESC"]                                      = "Choose the minimap shape."
-- L["VISTA_SHAPE_SQUARE"]                                    = "Square"
-- L["VISTA_SHAPE_CIRCLE"]                                    = "Circle"
-- L["VISTA_SHAPE_RECTANGLE"]                                 = "Rectangle"
-- L["VISTA_RECTANGLE_WIDTH"]                                 = "Rectangle width"
-- L["VISTA_WIDTH_OF_MINIMAP_PIXELS_DESC"]                    = "Width of the minimap in pixels (rectangle only, 100–800)."
L["VISTA_LOCK_MINIMAP_POSITION"]                              = "Minikarten-Position sperren"
L["VISTA_PREVENT_DRAGGING_MINIMAP"]                           = "Minikarte nicht verschiebbar."
L["VISTA_RESET_MINIMAP_POSITION"]                             = "Minikarten-Position zurücksetzen"
L["VISTA_RESET_MINIMAP_DEFAULT_POSITION_TOP_RIGHT"]           = "Minikarte auf Standardposition (oben rechts) zurücksetzen."
-- L["VISTA_RESET_OVERLAY_POSITIONS"]                         = "Reset overlay positions to defaults"
L["VISTA_RESET_OVERLAY_POSITIONS_DESC"]                       = "Clear saved positions for zone text, coordinates, clock, performance and difficulty text, zoom buttons, tracking, calendar, queue, mail, the addon button bar, drawer button, and right-click panel. The minimap frame position is not changed."
L["VISTA_AUTO_ZOOM"]                                          = "Auto-Zoom"
L["VISTA_AUTO_ZOOM_DELAY"]                                    = "Auto-Zoom-Out-Verzögerung"
L["VISTA_SECONDS_AFTER_ZOOMING_BEFORE_AUTO_ZOOM"]             = "Sekunden nach Zoom bis Auto-Zoom-Out. 0 = deaktiviert."

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["VISTA_ZONE_TEXT_HEADER"]                                   = "Zonentext"
L["VISTA_ZONE_FONT"]                                          = "Zonenschriftart"
L["VISTA_FONT_ZONE_NAME_BELOW_MINIMAP"]                       = "Schriftart für den Zonennamen unter der Minikarte."
L["VISTA_ZONE_FONT_SIZE"]                                     = "Zonenschriftgröße"
L["VISTA_ZONE_TEXT_COLOUR"]                                   = "Zonentextfarbe"
L["VISTA_COLOUR_OF_ZONE_NAME_TEXT"]                           = "Farbe des Zonennamentexts."
L["VISTA_COORDINATES_TEXT"]                                   = "Koordinatentext"
L["VISTA_COORDINATES_FONT"]                                   = "Koordinatenschriftart"
L["VISTA_FONT_COORDINATES_TEXT_BELOW_MINIMAP"]                = "Schriftart für den Koordinaten-Text unter der Minikarte."
L["VISTA_COORDINATES_FONT_SIZE"]                              = "Koordinatenschriftgröße"
L["VISTA_COORDINATES_TEXT_COLOUR"]                            = "Koordinatentextfarbe"
L["VISTA_COLOUR_OF_COORDINATES_TEXT"]                         = "Farbe des Koordinatentexts."
L["VISTA_COORDINATE_PRECISION"]                               = "Koordinatenpräzision"
L["VISTA_NUMBER_OF_DECIMAL_PLACES_SHOWN_X"]                   = "Anzahl Dezimalstellen für X- und Y-Koordinaten."
L["VISTA_COORDS_DECIMALS_OFF"]                                = "Keine Dezimalstellen (z.B. 52, 37)"
L["VISTA_DECIMAL_E_G"]                                        = "1 Dezimalstelle (z.B. 52,3, 37,1)"
L["VISTA_DECIMALS_E_G"]                                       = "2 Dezimalstellen (z.B. 52,34, 37,12)"
L["VISTA_TEXT"]                                               = "Zeit-Text"
L["VISTA_FONT"]                                               = "Zeit-Schriftart"
L["VISTA_FONT_TEXT_BELOW_MINIMAP"]                            = "Schriftart für den Zeit-Text unter der Minikarte."
L["VISTA_FONT_SIZE"]                                          = "Zeit-Schriftgröße"
L["VISTA_TEXT_COLOUR"]                                        = "Zeit-Textfarbe"
L["VISTA_COLOUR_OF_TEXT"]                                     = "Farbe des Zeit-Texts."
L["VISTA_PERFORMANCE_TEXT"]                                   = "Performance-Text"
L["VISTA_PERFORMANCE_FONT"]                                   = "Performance-Schriftart"
L["VISTA_FONT_FPS_LATENCY_TEXT_BELOW_MINIMAP"]                = "Schriftart für FPS- und Latenz-Text unter der Minikarte."
L["VISTA_PERFORMANCE_FONT_SIZE"]                              = "Performance-Schriftgröße"
L["VISTA_PERFORMANCE_TEXT_COLOUR"]                            = "Performance-Textfarbe"
L["VISTA_COLOUR_OF_FPS_LATENCY_TEXT"]                         = "Farbe des FPS- und Latenz-Texts."
L["VISTA_DIFFICULTY_TEXT"]                                    = "Schwierigkeits-Text"
L["VISTA_DIFFICULTY_TEXT_COLOUR_FALLBACK"]                    = "Schwierigkeits-Textfarbe (Fallback)"
L["VISTA_DEFAULT_COLOUR_PER_DIFFICULTY_COLOUR"]               = "Standardfarbe für nicht gesetzte Schwierigkeitsfarben."
L["VISTA_DIFFICULTY_FONT"]                                    = "Schwierigkeits-Schriftart"
L["VISTA_FONT_INSTANCE_DIFFICULTY_TEXT"]                      = "Schriftart für den Instanz-Schwierigkeitstext."
L["VISTA_DIFFICULTY_FONT_SIZE"]                               = "Schwierigkeits-Schriftgröße"
L["VISTA_PER_DIFFICULTY_COLOURS"]                             = "Farben pro Schwierigkeit"
L["VISTA_MYTHIC_COLOUR"]                                      = "Mythisch-Farbe"
L["VISTA_COLOUR_MYTHIC_DIFFICULTY_TEXT"]                      = "Farbe für Mythisch-Schwierigkeitstext."
L["VISTA_HEROIC_COLOUR"]                                      = "Heroisch-Farbe"
L["VISTA_COLOUR_HEROIC_DIFFICULTY_TEXT"]                      = "Farbe für Heroisch-Schwierigkeitstext."
L["VISTA_NORMAL_COLOUR"]                                      = "Normal-Farbe"
L["VISTA_COLOUR_NORMAL_DIFFICULTY_TEXT"]                      = "Farbe für Normal-Schwierigkeitstext."
L["VISTA_LFR_COLOUR"]                                         = "LFR-Farbe"
L["VISTA_COLOUR_LOOKING_RAID_DIFFICULTY_TEXT"]                = "Farbe für Suche-nach-Schlachtzug-Text."

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["VISTA_TEXT_ELEMENTS"]                                      = "Textelemente"
L["VISTA_ZONE_TEXT"]                                          = "Zonentext anzeigen"
L["VISTA_ZONE_NAME_BELOW_MINIMAP"]                            = "Zonennamen unter der Minikarte anzeigen."
L["VISTA_ZONE_TEXT_DISPLAY_MODE"]                             = "Zonentext-Anzeigemodus"
L["VISTA_WHAT_ZONE_SUBZONE"]                                  = "Nur Zone, Unterzone oder beides anzeigen."
L["VISTA_SHOW_ZONE"]                                          = "Nur Zone"
L["VISTA_SHOW_SUBZONE"]                                       = "Nur Unterzone"
L["VISTA_SHOW_ZONE_AND_SUBZONE"]                              = "Beides"
L["VISTA_COORDINATES"]                                        = "Koordinaten anzeigen"
L["VISTA_PLAYER_COORDINATES_BELOW_MINIMAP"]                   = "Spielerkoordinaten unter der Minikarte anzeigen."
L["VISTA_TIME"]                                               = "Zeit anzeigen"
L["VISTA_CURRENT_GAME_BELOW_MINIMAP"]                         = "Aktuelle Spielzeit unter der Minikarte anzeigen."
L["VISTA_HOUR_CLOCK"]                                         = "24-Stunden-Format"
L["VISTA_DISPLAY_HOUR_FORMAT_24"]                             = "Zeit im 24-Stunden-Format anzeigen (z.B. 14:30 statt 2:30 PM)."
L["VISTA_LOCAL_TIME"]                                         = "Lokale Zeit verwenden"
L["VISTA_LOCAL_TIME_TIP"]                                     = "An: lokale Systemzeit. Aus: Serverzeit."
L["VISTA_FPS_LATENCY"]                                        = "FPS und Latenz anzeigen"
L["VISTA_FPS_LATENCY_MS_BELOW_MINIMAP"]                       = "FPS und Latenz (ms) unter der Minikarte anzeigen."
L["VISTA_MINIMAP_BUTTONS"]                                    = "Minikarten-Buttons"
L["VISTA_QUEUE_STATUS_MAIL_INDICATOR_ALWAYS_SHOWN"]           = "Warteschlangen- und Post-Status werden bei Relevanz angezeigt."
L["VISTA_TRACKING_BUTTON"]                                    = "Verfolgen-Button anzeigen"
L["VISTA_MINIMAP_TRACKING_BUTTON"]                            = "Minikarten-Verfolgen-Button anzeigen."
L["VISTA_TRACKING_BUTTON_MOUSEOVER"]                          = "Verfolgen-Button nur bei Mausüber"
L["VISTA_HIDE_TRACKING_BUTTON_UNTIL_YOU_HOVER"]               = "Verfolgen-Button verbergen bis Maus über Minikarte."
L["VISTA_CALENDAR_BUTTON"]                                    = "Kalender-Button anzeigen"
L["VISTA_MINIMAP_CALENDAR_BUTTON"]                            = "Minikarten-Kalender-Button anzeigen."
L["VISTA_CALENDAR_BUTTON_MOUSEOVER"]                          = "Kalender-Button nur bei Mausüber"
L["VISTA_HIDE_CALENDAR_BUTTON_UNTIL_YOU_HOVER"]               = "Kalender-Button verbergen bis Maus über Minikarte."
L["VISTA_ZOOM_BUTTONS"]                                       = "Zoom-Buttons anzeigen"
L["VISTA_ZOOM_BUTTONS_MINIMAP"]                               = "Zoom-Buttons (+ und -) auf der Minikarte anzeigen."
L["VISTA_ZOOM_BUTTONS_MOUSEOVER"]                             = "Zoom-Buttons nur bei Mausüber"
L["VISTA_HIDE_ZOOM_BUTTONS_UNTIL_YOU_HOVER"]                  = "Zoom-Buttons verbergen bis Maus über Minikarte."

-- =====================================================================
-- OptionsData.lua Vista — Display (Border / Text Positions / Buttons)
-- =====================================================================
L["VISTA_BORDER"]                                             = "Rahmen"
L["VISTA_BORDER_TIP"]                                         = "Rahmen um die Minikarte anzeigen."
L["VISTA_BORDER_COLOUR"]                                      = "Rahmenfarbe"
L["VISTA_COLOUR_OPACITY_OF_MINIMAP_BORDER"]                   = "Farbe (und Deckkraft) des Minikarten-Rahmens."
L["VISTA_BORDER_THICKNESS"]                                   = "Rahmenstärke"
L["VISTA_THICKNESS_OF_MINIMAP_BORDER_PIXELS"]                 = "Stärke des Minikarten-Rahmens in Pixeln (1–8)."
L["VISTA_CLASS_COLOURS"]                                      = "Klassenfarben"
L["VISTA_TINT_VISTA_BORDER_TEXT_COORDS_FPS"]                  = "Vista-Rahmen und Text (Koords, Zeit, FPS/MS) mit Klassenfarbe einfärben. Zahlen nutzen die konfigurierte Farbe."
L["VISTA_TEXT_POSITIONS"]                                     = "Text-Positionen"
L["VISTA_DRAG_TEXT_ELEMENTS_REPOSITION_LOCK_PREVEN"]          = "Textelemente ziehen zum Verschieben. Sperren verhindert versehentliche Bewegung."
L["VISTA_LOCK_ZONE_TEXT_POSITION"]                            = "Zonentext-Position sperren"
L["VISTA_ZONE_TEXT_CANNOT_DRAGGED"]                           = "An: Zonentext nicht verschiebbar."
L["VISTA_LOCK_COORDINATES_POSITION"]                          = "Koordinaten-Position sperren"
L["VISTA_COORDINATES_TEXT_CANNOT_DRAGGED"]                    = "An: Koordinaten-Text nicht verschiebbar."
L["VISTA_LOCK_POSITION"]                                      = "Zeit-Position sperren"
L["VISTA_TEXT_CANNOT_DRAGGED"]                                = "An: Zeit-Text nicht verschiebbar."
L["VISTA_PERFORMANCE_TEXT_POSITION"]                          = "Position des Performance-Texts"
L["VISTA_PLACE_FPS_LATENCY_TEXT_ABOVE_BELOW"]                 = "FPS/ Latenz-Text über oder unter der Minikarte platzieren."
L["VISTA_LOCK_PERFORMANCE_TEXT_POSITION"]                     = "Position des Performance-Texts sperren"
L["VISTA_FPS_LATENCY_TEXT_CANNOT_DRAGGED"]                    = "An: FPS/ Latenz-Text kann nicht gezogen werden."
-- L["VISTA_DIFFICULTY_TEXT_POSITION"]                        = "Difficulty text position"
-- L["VISTA_PLACE_DIFFICULTY_TEXT_ABOVE_BELOW"]               = "Place the instance difficulty text above or below the minimap. It is positioned independently of zone text."
L["VISTA_LOCK_DIFFICULTY_TEXT_POSITION"]                      = "Schwierigkeits-Text-Position sperren"
L["VISTA_DIFFICULTY_TEXT_CANNOT_DRAGGED"]                     = "An: Schwierigkeits-Text nicht verschiebbar."
L["VISTA_BUTTON_POSITIONS"]                                   = "Button-Positionen"
L["VISTA_DRAG_BUTTONS_REPOSITION_LOCK_PREVENT_MOVE"]          = "Buttons ziehen zum Verschieben. Sperren verhindert Bewegung."
L["VISTA_LOCK_ZOOM_BUTTON"]                                   = "Vergrößern-Button sperren"
L["VISTA_PREVENT_DRAGGING_ZOOM_BUTTON"]                       = "Vergrößern-Button nicht verschiebbar."
L["VISTA_LOCK_ZOOM_OUT_BUTTON"]                               = "Verkleinern-Button sperren"
L["VISTA_LOCK_ZOOM_OUT_DRAG"]                                 = "Verkleinern-Button nicht verschiebbar."
L["VISTA_LOCK_TRACKING_BUTTON"]                               = "Verfolgen-Button sperren"
L["VISTA_PREVENT_DRAGGING_TRACKING_BUTTON"]                   = "Verfolgen-Button nicht verschiebbar."
L["VISTA_LOCK_CALENDAR_BUTTON"]                               = "Kalender-Button sperren"
L["VISTA_PREVENT_DRAGGING_CALENDAR_BUTTON"]                   = "Kalender-Button nicht verschiebbar."
L["VISTA_LOCK_QUEUE_BUTTON"]                                  = "Warteschlangen-Button sperren"
L["VISTA_PREVENT_DRAGGING_QUEUE_STATUS_BUTTON"]               = "Warteschlangen-Button nicht verschiebbar."
L["VISTA_LOCK_MAIL_INDICATOR"]                                = "Post-Symbol sperren"
L["VISTA_PREVENT_DRAGGING_MAIL_ICON"]                         = "Post-Symbol nicht verschiebbar."
L["VISTA_DISABLE_QUEUE_HANDLING"]                             = "Warteschlangen-Verwaltung deaktivieren"
L["VISTA_DISABLE_QUEUE_BUTTON_HANDLING"]                      = "Warteschlangen-Button-Verwaltung deaktivieren"
L["VISTA_TURN_QUEUE_BUTTON_ANCHORING_OFF_ADDON_CONFLICT"]     = "Alle Warteschlangen-Button-Ankerungen deaktivieren (wenn anderes Addon verwaltet)."
L["VISTA_BUTTON_SIZES"]                                       = "Button-Größen"
L["VISTA_ADJUST_SIZE_OF_MINIMAP_OVERLAY_BUTTONS"]             = "Größe der Minikarten-Overlay-Buttons anpassen."
L["VISTA_TRACKING_BUTTON_SIZE"]                               = "Verfolgen-Button-Größe"
L["VISTA_SIZE_OF_TRACKING_BUTTON_PIXELS"]                     = "Größe des Verfolgen-Buttons (Pixel)."
L["VISTA_CALENDAR_BUTTON_SIZE"]                               = "Kalender-Button-Größe"
L["VISTA_SIZE_OF_CALENDAR_BUTTON_PIXELS"]                     = "Größe des Kalender-Buttons (Pixel)."
L["VISTA_QUEUE_BUTTON_SIZE"]                                  = "Warteschlangen-Button-Größe"
L["VISTA_SIZE_OF_QUEUE_STATUS_BUTTON_PIXELS"]                 = "Größe des Warteschlangen-Buttons (Pixel)."
L["VISTA_ZOOM_BUTTON_SIZE"]                                   = "Zoom-Button-Größe"
L["VISTA_SIZE_OF_ZOOM_ZOOM_BUTTONS_PIXELS"]                   = "Größe der Zoom-Buttons (Pixel)."
L["VISTA_MAIL_INDICATOR_SIZE"]                                = "Post-Symbol-Größe"
L["VISTA_SIZE_OF_MAIL_ICON_PIXELS"]                           = "Größe des Post-Symbols (Pixel)."
L["VISTA_ADDON_BUTTON_SIZE"]                                  = "Addon-Button-Größe"
L["VISTA_SIZE_OF_COLLECTED_ADDON_MINIMAP_BUTTONS"]            = "Größe der gesammelten Addon-Minikarten-Buttons (Pixel)."

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
-- L["VISTA_COLLECT_HORIZON_MINIMAP"]                         = "Include Horizon minimap icon"
-- L["VISTA_COLLECT_HORIZON_MINIMAP_DESC"]                    = "Put Horizon's own minimap icon in the managed addon bar, right-click panel, or drawer instead of leaving it on the minimap edge."
-- L["VISTA_SORT_BUTTONS_ALPHA"]                              = "Sort buttons alphabetically"
-- L["VISTA_SORT_BUTTONS_ALPHA_DESC"]                         = "Sort collected addon minimap buttons alphabetically by name."
L["VISTA_ADDON_BUTTONS"]                                      = "Addon-Buttons"
L["VISTA_MINIMAP_ADDON_BUTTONS"]                              = "Minikarten-Addon-Buttons"
L["VISTA_BUTTON_MANAGEMENT"]                                  = "Button-Verwaltung"
L["VISTA_MANAGE_ADDON_MINIMAP_BUTTONS"]                       = "Addon-Minikarten-Buttons verwalten"
L["VISTA_TAKES_CONTROL_OF_ADDON_MINIMAP"]                     = "An: Vista übernimmt Addon-Minikarten-Buttons und gruppiert nach gewähltem Modus."
L["VISTA_BUTTON_MODE"]                                        = "Button-Modus"
L["VISTA_ADDON_BUTTONS_PRESENTED_HOVER_BAR_BELOW"]            = "Darstellung der Addon-Buttons: Mausüber-Leiste, Rechtsklick-Panel oder schwebender Schubladen-Button."
L["VISTA_ALWAYS_BAR"]                                         = "Leiste immer anzeigen"
L["VISTA_ALWAYS_MOUSEOVER_BAR_POSITIONING"]                   = "Mausüber-Leiste immer anzeigen (zum Positionieren)"
L["VISTA_KEEP_MOUSEOVER_BAR_VISIBLE_TIMES_YOU"]               = "Mausüber-Leiste immer sichtbar für Positionierung. Deaktivieren wenn fertig."
L["VISTA_DISABLE_DONE"]                                       = "Deaktivieren wenn fertig."
L["VISTA_MOUSEOVER_BAR"]                                      = "Mausüber-Leiste"
L["VISTA_RIGHT_CLICK_PANEL"]                                  = "Rechtsklick-Panel"
L["VISTA_FLOATING_DRAWER"]                                    = "Schwebende Schublade"
L["VISTA_LOCK_DRAWER_BUTTON_POSITION"]                        = "Schubladen-Button-Position sperren"
L["VISTA_PREVENT_DRAGGING_FLOATING_DRAWER_BUTTON"]            = "Schubladen-Button nicht verschiebbar."
L["VISTA_LOCK_MOUSEOVER_BAR_POSITION"]                        = "Mausüber-Leisten-Position sperren"
L["VISTA_PREVENT_DRAGGING_MOUSEOVER_BUTTON_BAR"]              = "Mausüber-Leiste nicht verschiebbar."
L["VISTA_LOCK_RIGHT_CLICK_PANEL_POSITION"]                    = "Rechtsklick-Panel-Position sperren"
L["VISTA_PREVENT_DRAGGING_RIGHT_CLICK_PANEL"]                 = "Rechtsklick-Panel nicht verschiebbar."
L["VISTA_BUTTONS_PER_ROW_COLUMN"]                             = "Buttons pro Zeile/Spalte"
L["VISTA_CONTROLS_MANY_BUTTONS_APPEAR_BEFORE_WRAPPING"]       = "Anzahl Buttons vor Umbruch. Links/Rechts = Spalten; Oben/Unten = Zeilen."
L["VISTA_EXPAND_DIRECTION"]                                   = "Erweiterungsrichtung"
L["VISTA_DIRECTION_BUTTONS_FILL_ANCHOR_POINT_LEFT"]           = "Richtung: Buttons füllen vom Anker. Links/Rechts = Zeilen; Oben/Unten = Spalten."
L["VISTA_BUTTONS_FILL_RIGHT"]                                 = "Rechts"
L["VISTA_BUTTONS_FILL_LEFT"]                                  = "Links"
L["VISTA_BUTTONS_FILL_DOWN"]                                  = "Unten"
L["VISTA_BUTTONS_FILL_UP"]                                    = "Oben"
L["VISTA_MOUSEOVER_BAR_APPEARANCE"]                           = "Mausüber-Leisten-Aussehen"
L["VISTA_BACKGROUND_BORDER_MOUSEOVER_BUTTON_BAR"]             = "Hintergrund und Rahmen für die Mausüber-Button-Leiste."
L["VISTA_BACKDROP_COLOUR"]                                    = "Hintergrundfarbe"
L["VISTA_BACKGROUND_COLOUR_OF_MOUSEOVER_BUTTON_BAR"]          = "Hintergrundfarbe der Mausüber-Leiste (Alpha für Transparenz)."
L["VISTA_BAR_BORDER"]                                         = "Leisten-Rahmen anzeigen"
L["VISTA_A_BORDER_AROUND_MOUSEOVER_BUTTON_BAR"]               = "Rahmen um die Mausüber-Leiste anzeigen."
L["VISTA_BAR_BORDER_COLOUR"]                                  = "Leisten-Rahmenfarbe"
L["VISTA_BORDER_COLOUR_OF_MOUSEOVER_BUTTON_BAR"]              = "Rahmenfarbe der Mausüber-Leiste."
L["VISTA_BAR_BACKGROUND_COLOUR"]                              = "Leisten-Hintergrundfarbe"
L["VISTA_PANEL_BACKGROUND_COLOUR"]                            = "Panel-Hintergrundfarbe."
L["VISTA_CLOSE_FADE_TIMING"]                                  = "Schließen / Einblend-Timing"
L["VISTA_MOUSEOVER_BAR_CLOSE_DELAY_SECONDS"]                  = "Mausüber-Leiste — Schließ-Verzögerung (Sekunden)"
L["VISTA_LONG_SECONDS_BAR_STAYS_VISIBLE_AFTER"]               = "Wie lange (Sekunden) die Leiste sichtbar bleibt nach Verlassen. 0 = sofortiges Ausblenden."
L["VISTA_RIGHT_CLICK_PANEL_CLOSE_DELAY_SECONDS"]              = "Rechtsklick-Panel — Schließ-Verzögerung (Sekunden)"
L["VISTA_LONG_SECONDS_PANEL_STAYS_OPEN_AFTER"]                = "Wie lange (Sekunden) das Panel offen bleibt nach Verlassen. 0 = nie automatisch schließen."
L["VISTA_FLOATING_DRAWER_CLOSE_DELAY_SECONDS"]                = "Schwebende Schublade — Schließ-Verzögerung (Sekunden)"
L["VISTA_DRAWER_CLOSE_DELAY"]                                 = "Schublade-Schließ-Verzögerung"
L["VISTA_LONG_SECONDS_DRAWER_PANEL_STAYS_OPEN"]               = "Wie lange (Sekunden) die Schublade offen bleibt nach Wegklicken. 0 = nie automatisch schließen."
L["VISTA_MAIL_ICON_BLINK"]                                    = "Postsymbolblinken"
L["VISTA_MAIL_ICON_PULSES_DRAW_ATTENTION"]                    = "An: Post-Symbol pulsiert. Aus: volle Deckkraft."
L["VISTA_PANEL_APPEARANCE"]                                   = "Panel-Aussehen"
L["VISTA_COLOURS_DRAWER_RIGHT_CLICK_BUTTON_PANELS"]           = "Farben für Schublade und Rechtsklick-Panels."
L["VISTA_PANEL_BG_COLOUR_LABEL"]                              = "Panel-Hintergrundfarbe"
L["VISTA_BACKGROUND_COLOUR_OF_ADDON_BUTTON_PANELS"]           = "Hintergrundfarbe der Addon-Button-Panels."
L["VISTA_PANEL_BORDER_COLOUR"]                                = "Panel-Rahmenfarbe"
L["VISTA_BORDER_COLOUR_OF_ADDON_BUTTON_PANELS"]               = "Rahmenfarbe der Addon-Button-Panels."
L["VISTA_MANAGED_BUTTONS"]                                    = "Verwaltete Buttons"
L["VISTA_BUTTON_COMPLETELY_IGNORED"]                          = "Aus: Dieser Button wird vom Addon ignoriert."
L["VISTA_ADDON_BUTTONS_DETECTED"]                             = "(Noch keine Addon-Buttons erkannt)"
L["VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE"]                      = "Sichtbare Buttons (zum Einbinden ankreuzen)"
L["VISTA_ADDON_BUTTONS_DETECTED_OPEN_YOUR_MINIMAP"]           = "(Noch keine Addon-Buttons erkannt — öffnen Sie zuerst Ihre Minikarte)"

-- =====================================================================
-- Inline option / module strings (used in OptionsData / modules; symbolic migration)
-- =====================================================================

L["HEROIC_DUNGEON"]                                           = "  Heroischer Dungeon"
L["HEROIC_RAID"]                                              = "  Heroischer Schlachtzug"
L["LFR"]                                                      = "  Schlachtzugs-Browser"
L["MYTHIC_DUNGEON"]                                           = "  Mythischer Dungeon"
L["MYTHIC_RAID"]                                              = "  Mythischer Schlachtzug"
L["MYTHIC_PLUS_DUNGEON"]                                      = "  Mythisch-Plus-Dungeon"
L["NORMAL_DUNGEON"]                                           = "  Normaler Dungeon"
L["NORMAL_RAID"]                                              = "  Normaler Schlachtzug"
-- L["ACHIEVEMENT_ICONS"]                                     = "Achievement icons"
-- L["ACTIVE_INSTANCE"]                                       = "Active instance only"
-- L["ADJUST_FONT_SIZES_AMOUNT"]                              = "Adjust all font sizes by this amount."
-- L["ADJUST_FONTS_SIZES_CASING_DROP_SHADOWS"]                = "Adjust fonts, sizes, casing, and drop shadows."
-- L["AFFIX_ICONS"]                                           = "Affix icons"
-- L["AFFIX_TOOLTIPS"]                                        = "Affix tooltips"
-- L["AFFECTS_SCENARIO_PROGRESS_TIMER_BARS"]                  = "Also affects scenario progress and timer bars."
-- L["ALWAYS"]                                                = "Always show"
-- L["ALWAYS_M_TIMER"]                                        = "Always show M+ timer."
-- L["AUTO_ADD_WQS_YOUR_CURRENT_ZONE"]                        = "Auto-add WQs in your current zone."
-- L["AUTO_CLOSE_DELAY_DISABLE"]                              = "Auto-close delay (0 to disable)."
-- L["AUTO_UNTRACK_FINISHED_ACTIVITIES"]                      = "Auto-untrack finished activities."
-- L["FOCUS_BAR_UNDER_NUMERIC_OBJECTIVES"]                    = "Bar under numeric objectives (e.g. 3/250)."
L["DASH_CLASS_ICONS_RONDOMEDIA"]                              = "Blizzard default or RondoMedia class icon on the Dashboard when Dashboard class colours are on. Independent of Insight tooltip class icons."
-- L["BLOCK_POSITION"]                                        = "Block position"
-- L["BOSS_EMOTES"]                                           = "Boss emotes"
-- L["CHOICE_SLOTS"]                                          = "Choice slots"
-- L["CHOOSE_WHICH_EVENTS_TRIGGER_SCREEN_ALERTS"]             = "Choose which events trigger on-screen alerts."
-- L["CHOOSE_WHICH_SOUND_PLAY_A_RARE"]                        = "Choose which sound to play when a rare boss appears. Requires LibSharedMedia sounds to be installed for extra options."
-- L["CLICK_BEHAVIOR"]                                        = "Click behavior"
-- L["COLLECT_GROUP_ADDON_MINIMAP_BUTTONS"]                   = "Collect and group addon minimap buttons."
-- L["COLOUR_REMAINING"]                                      = "Colour by remaining time."
-- L["COLOUR_ZONE_TYPE"]                                      = "Colour by zone type"
-- L["COLOUR_CONTESTED_ZONES_ORANGE_DEFAULT"]                 = "Colour for contested zones (orange by default)."
-- L["COLOUR_FRIENDLY_ZONES_GREEN_DEFAULT"]                   = "Colour for friendly zones (green by default)."
-- L["COLOUR_HOSTILE_ZONES_RED_DEFAULT"]                      = "Colour for hostile zones (red by default)."
-- L["COLOUR_SANCTUARY_ZONES_BLUE_DEFAULT"]                   = "Colour for sanctuary zones (blue by default)."
-- L["COLOUR_OF_DIVIDER_LINES_BETWEEN_SECTIONS"]              = "Colour of the divider lines between sections."
-- L["COLOUR_RECIPE_TITLES_OUTPUT_ITEM_RARITY"]               = "Colour recipe titles by output item rarity."
-- L["COLOUR_ZONE_SUBZONE_TITLES_PVP_ZONE"]                   = "Colour zone/subzone titles by PvP zone type (friendly, hostile, contested, sanctuary). When off, uses the default category colour."
-- L["COMBAT_AFK_DND_PVP_PARTY_FRIENDS"]                      = "Combat, AFK, DND, PvP, party, friends, targeting."
-- L["COMING_SOON"]                                           = "Coming Soon"
-- L["COMPLETED_BOSS_STYLE"]                                  = "Completed boss style"
-- L["COMPLETED_COUNT"]                                       = "Completed count"
L["FOCUS_TOMTOM_CONFIGURE_DESC"]                              = "Configure click behaviors, tracking rules, and TomTom integration."
-- L["CONFIGURE_MINIMAP_S_SHAPE_SIZE_POSITION"]               = "Configure the minimap's shape, size, position, and text overlays."
-- L["CONTESTED_ZONE_COLOUR"]                                 = "Contested zone colour"
-- L["CONTROL_TRACKER_VISIBILITY_WITHIN_DUNGEONS_RAIDS"]      = "Control tracker visibility within dungeons, raids, and PvP."
-- L["SETTINGS_PRESENCE_NOTIFICATION_FRAMEWORK"]              = "Core settings for the Presence notification framework."
-- L["CRAFTABLE_COUNT"]                                       = "Craftable count"
-- L["CTRL_LEFT_FOCUS_ADD_CTRL_RIGHT"]                        = "Ctrl+Left = focus/add, Ctrl+Right = unfocus/untrack."
-- L["CURRENT_ZONE_GROUP"]                                    = "Current Zone group"
-- L["CURRENT_ZONE"]                                          = "Current zone only"
-- L["VISTA_CUSTOMISE_BORDERS_COLOURS_POSITIONING"]           = "Customise borders, colours, and the positioning of specific minimap elements."
-- L["CUSTOMIZE_VISUAL_INTERFACE_LAYOUT_ELEMENTS"]            = "Customise the visual interface and layout elements."
-- L["DASHBOARD_CLASS_ICON_STYLE"]                            = "Dashboard class icon style"
-- L["DECOR_ICONS"]                                           = "Decor icons"
-- L["DEDICATED_SECTION_COMPLETED_QUESTS"]                    = "Dedicated section for completed quests."
-- L["DEDICATED_SECTION_ZONE_QUESTS"]                         = "Dedicated section for in-zone quests."
-- L["DEFEATED_BOSS_STYLE"]                                   = "Defeated boss style."
-- L["DESATURATE_FOCUSED_ENTRIES"]                            = "Desaturate non-focused entries."
-- L["DESATURATE_FOCUSED_QUESTS"]                             = "Desaturate non-focused quests"
-- L["DIM_ALPHA"]                                             = "Dim alpha"
-- L["DIM_STRENGTH"]                                          = "Dim strength"
-- L["DIM_UNFOCUSED_TRACKER_ENTRIES"]                         = "Dim unfocused tracker entries."
-- L["DIMMING_STRENGTH"]                                      = "Dimming strength (0-100%)."
-- L["DISPLAY_COMPLETED_OBJECTIVES"]                          = "Display completed objectives."
-- L["ENABLE_BLACKLIST_UNTRACKED_INTERACTIONS_ADD_QUEST"]     = "Enable 'Blacklist untracked' in Interactions to add quests here."
-- L["ENABLE_M_BLOCK"]                                        = "Enable M+ block"
-- L["ENEMY_FORCES_COLOUR"]                                   = "Enemy forces colour"
-- L["ENEMY_FORCES_SIZE"]                                     = "Enemy forces size"
-- L["ENHANCE_PLAYER_ITEM_TOOLTIPS_EXTRA_DETAILS"]            = "Enhance player and item tooltips with extra details like Mythic+ score and transmog status."
-- L["ENTRY_NUMBERS"]                                         = "Entry numbers"
-- L["ENTRY_SPACING"]                                         = "Entry spacing"
-- L["EXPAND_DIRECTION_ANCHOR"]                               = "Expand direction from anchor."
-- L["FADE_HOVERING"]                                         = "Fade out when not hovering."
-- L["FOCUS_FINISHING_REAGENTS"]                              = "Finishing reagents"
-- L["FOCUS_ANIMATIONS"]                                      = "Focus animations"
-- L["FONT_SIZE_BAR_LABEL_BAR_HEIGHT"]                        = "Font size for bar label and bar height."
-- L["FONTS_SIZES_COLOURS_PRESENCE_NOTIFICATIONS"]            = "Fonts, sizes, and colours for Presence notifications."
-- L["WORLD_QUESTS_WEEKLIES_YOUR_QUEST_LOG"]                  = "For world quests and weeklies not in your quest log."
-- L["FRIENDLY_ZONE_COLOUR"]                                  = "Friendly zone colour"
L["GROUPING"]                                                 = "Gruppierung"
-- L["GROUPS_SELECTED_LAYOUT_MODE_BELOW"]                     = "Groups them by the selected layout mode below."
-- L["GUILD_RANK"]                                            = "Guild rank"
-- L["HEADER_DIVIDER"]                                        = "Header divider"
-- L["HIDE_UNTRACKED_QUESTS_UNTIL_RELOAD"]                    = "Hide untracked quests until reload."
-- L["HIDE_ZONE_NOTIFICATIONS_MYTHIC"]                        = "Hide zone notifications in Mythic+."
-- L["HIDES_CATEGORIES_WHILE_A_DELVE_PARTY"]                  = "Hides other categories while in a Delve or party dungeon."
-- L["HINT_LIST_SCROLLABLE"]                                  = "Hint when the list is scrollable."
-- L["HONOR_LEVEL"]                                           = "Honor level"
-- L["HOSTILE_ZONE_COLOUR"]                                   = "Hostile zone colour"
-- L["FOCUS_DIM_UNFOCUSED_ENTRIES_DESC"]                      = "How much to dim non-focused entries (0 = no dimming, 100 = fully darkened). Default 40%."
-- L["ICON_NEXT_ACHIEVEMENT_TITLE"]                           = "Icon next to achievement title."
-- L["ICON_NEXT_AUTO_TRACKED_ZONE_ENTRIES"]                   = "Icon next to auto-tracked in-zone entries."
-- L["ARENA"]                                                 = "In arena"
-- L["BATTLEGROUND"]                                          = "In battleground"
-- L["DUNGEON"]                                               = "In dungeon"
-- L["RAID"]                                                  = "In raid"
-- L["ZONE_WORLD_QUESTS"]                                     = "In-zone world quests"
-- L["INCLUDE_COMPLETED"]                                     = "Include completed"
-- L["INSTANCE_SUPPRESSION"]                                  = "Instance suppression"
-- L["ITEM_LEVEL"]                                            = "Item level"
-- L["ITEM_SOURCE"]                                           = "Item source"
-- L["KEEP_BAR_VISIBLE_REPOSITIONING"]                        = "Keep bar visible for repositioning."
-- L["KEEP_CAMPAIGN_CATEGORY"]                                = "Keep campaign in category"
-- L["KEEP_HEADER_BOTTOM_TOP_UNTIL_COLLAPSED"]                = "Keep header at bottom, or top until collapsed."
-- L["KEEP_IMPORTANT_CATEGORY"]                               = "Keep important in category"
-- L["KEEP_CAMPAIGN_READY_TURN"]                              = "Keep in Campaign when ready to turn in."
-- L["KEEP_IMPORTANT_READY_TURN"]                             = "Keep in Important when ready to turn in."
-- L["KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED"]                = "Keep section headers visible when collapsed."
-- L["L_CLICK_OPENS_MAP_R_CLICK"]                             = "L-click opens map, R-click opens menu."
-- L["PRESENCE_LEVEL_UP_TOGGLE"]                              = "Level up"
-- L["LOCK_DRAWER_BUTTON"]                                    = "Lock drawer button"
-- L["LOCK_ITEM_POSITION"]                                    = "Lock item position"
-- L["LOCK_MINIMAP"]                                          = "Lock minimap"
-- L["LOCK_MOUSEOVER_BAR"]                                    = "Lock mouseover bar"
-- L["LOCK_RIGHT_CLICK_PANEL"]                                = "Lock right-click panel"
-- L["MAIL_ICON_PULSE"]                                       = "Mail icon pulse"
-- L["MAKE_FOCUSED_ENTRIES_GREYSCALE_PARTIALLY_DESATURATE"]   = "Make non-focused entries greyscale/partially desaturated in addition to dimming."
-- L["MANAGE_ADDON_BUTTONS"]                                  = "Manage addon buttons"
-- L["VISTA_ICON_MANAGEMENT"]                                 = "Manage and organise minimap icons from other addons into a tidy drawer or bar."
-- L["MANAGE_SWITCH_BETWEEN_YOUR_ADDON_CONFIGURATIONS"]       = "Manage and switch between your addon configurations."
-- L["MATCH_BAR_QUEST_CATEGORY_COLOUR"]                       = "Match bar to quest category colour."
-- L["APPEAR_FULL_TRACKER_REPLACEMENTS"]                      = "May not appear with full tracker replacements."
-- L["MINIMAL_MODE"]                                          = "Minimal mode"
-- L["MISSING_CRITERIA"]                                      = "Missing criteria only"
-- L["MOUNT_INFO"]                                            = "Mount info"
-- L["MOUNT_NAME_SOURCE_COLLECTION_STATUS"]                   = "Mount name, source, and collection status."
-- L["MOUSEOVER_CLOSE_DELAY"]                                 = "Mouseover close delay"
-- L["MOUSEOVER"]                                             = "Mouseover only"
-- L["MOVE_COMPLETED_QUESTS_BOTTOM_OF_CURRENT"]               = "Move completed quests to the bottom of the Current Zone section."
-- L["MYTHIC_BLOCK"]                                          = "Mythic+ Block"
-- L["MYTHIC_COLOURS"]                                        = "Mythic+ Colours"
-- L["MYTHIC_SCORE"]                                          = "Mythic+ score"
-- L["DEFAULT"]                                               = "New from Default"
-- L["HIDDEN_QUESTS"]                                         = "No hidden quests."
-- L["NOTIFY_ACHIEVEMENT_CRITERIA_UPDATE"]                    = "Notify on achievement criteria update."
-- L["OBJECTIVE_PROGRESS"]                                    = "Objective progress"
-- L["OBJECTIVE_SPACING"]                                     = "Objective spacing"
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
-- L["FOCUS_OPTIONAL_REAGENTS"]                               = "Optional reagents"
-- L["FOCUS_RECIPE_REAGENTS_FULL_DETAIL"]                     = "Full reagent detail"
-- L["FOCUS_RECIPE_REAGENTS_FULL_DETAIL_DESC"]                = "List every schematic slot: optional and finishing sections, choice groups with all variants, and non-Basic reagents. When off, only Basic slots use the first reagent per slot (compact shopping-style list)."
-- L["ORGANIZE_HIDE_TRACKED_ENTRIES_YOUR_PREFERENCE"]         = "Organise and hide tracked entries to your preference."
-- L["OVERRIDE_FONT_PER_ELEMENT"]                             = "Override font per element."
-- L["PANEL_BACKGROUND_OPACITY"]                              = "Panel background opacity (0–100%)."
-- L["PERMANENTLY_HIDE_UNTRACKED_QUESTS"]                     = "Permanently hide untracked quests."
-- L["PERSONALIZE_COLOUR_PALETTE_TRACKER_TEXT_ELEMENTS"]      = "Personalize the colour palette for tracker text elements."
-- L["POSITIONING_VISIBILITY_CACHE_LOOT_TOAST_SYS"]           = "Positioning and visibility for the Cache loot toast system."
-- L["PREVENT_ACCIDENTAL_CLICKS"]                             = "Prevent accidental clicks."
-- L["QUALITY_INFO"]                                          = "Quality info"
-- L["QUEST_ACCEPT"]                                          = "Quest accept"
-- L["QUEST_COMPLETE"]                                        = "Quest complete"
-- L["QUEST_COUNT"]                                           = "Quest count"
-- L["QUEST_ITEM_BUTTONS"]                                    = "Quest item buttons"
-- L["QUEST_LEVEL"]                                           = "Quest level"
-- L["QUEST_PROGRESS"]                                        = "Quest progress"
-- L["QUEST_PROGRESS_BAR"]                                    = "Quest progress bar"
-- L["QUEST_TRACKING"]                                        = "Quest tracking"
-- L["QUEST_TYPE_ICONS"]                                      = "Quest type icons"
-- L["FOCUS_QUEST_TYPE_ICON_SIZE"]                            = "Quest type icon size"
-- L["FOCUS_QUEST_TYPE_ICON_SIZE_DESC"]                       = "Pixel size of the quest type icon shown in the left gutter (default 16)."
-- L["PRESENCE_RARE_DEFEATED"]                                = "RARE DEFEATED"
-- L["RARE_ADDED_SOUND_CHOICE"]                               = "Rare added sound choice"
-- L["RARE_SOUND_ALERT"]                                      = "Rare sound alert"
-- L["RARITY_COLOURS"]                                        = "Rarity colours"
-- L["READY_TURN_GROUP"]                                      = "Ready to Turn In group"
-- L["READY_TURN_BOTTOM"]                                     = "Ready to turn in at bottom"
-- L["REAGENTS"]                                              = "Reagents"
-- L["RECIPE_ICONS"]                                          = "Recipe icons"
-- L["RECIPES"]                                               = "Recipes"
-- L["REDUCE_OPACITY_OF_FOCUSED_ENTRIES_INVISIBLE"]           = "Reduce opacity of non-focused entries (0 = invisible, 100 = fully opaque). Default 100% (no alpha change)."
-- L["REQUIRE_CTRL_COMPLETE_CLICK_COMPLETABLE_QUESTS"]        = "Require Ctrl to complete click-completable quests."
-- L["REQUIREMENTS"]                                          = "Requirements"
-- L["REQUIRES_QUEST_TYPE_ICONS_ENABLED_DISPLAY"]             = "Requires quest type icons to be enabled in Display."
-- L["RESET_MYTHIC_STYLING"]                                  = "Reset Mythic+ styling"
-- L["REVIEW_MANAGE_QUESTS_YOU_MANUALLY_UNTRACKED"]           = "Review and manage quests you have manually untracked or blacklisted."
-- L["RIGHT_CLICK_CLOSE_DELAY"]                               = "Right-click close delay"
-- L["SANCTUARY_ZONE_COLOUR"]                                 = "Sanctuary zone colour"
-- L["SCALE_UI_ELEMENTS"]                                     = "Scale all UI elements (50–200%)."
-- L["PRESENCE_SCENARIO_COMPLETE"]                            = "Scenario Complete"
-- L["SCENARIO_EVENTS"]                                       = "Scenario events"
-- L["SCENARIO_PROGRESS"]                                     = "Scenario progress"
-- L["SCENARIO_PROGRESS_BAR"]                                 = "Scenario progress bar"
-- L["SCENARIO_START"]                                        = "Scenario start"
-- L["SCENARIO_TIMER_BAR"]                                    = "Scenario timer bar"
-- L["SCROLL_INDICATOR"]                                      = "Scroll indicator"
-- L["SECONDS_OF_RECENT_PROGRESS"]                            = "Seconds of recent progress to show."
-- L["SECTION_DIVIDER_COLOUR"]                                = "Section divider colour"
-- L["SECTION_HEADERS"]                                       = "Section headers"
-- L["SECTIONS_COLLAPSED"]                                    = "Sections when collapsed"
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
-- L["FOCUS_AH_SEARCH_TOOLTIP"]                               = "Left-click: search for one craft worth of reagents (item quality and crafting tier when Auctionator supports them).\nRight-click: craft count and optional crafting tier (menu, 1–5) — choose Any for no quality or tier filters on the list.\nThe Auction House must be open."
-- L["FOCUS_AH_CRAFT_DIALOG_SUBTITLE"]                        = "Auction House shopping list"
-- L["FOCUS_AH_CRAFT_HINT_CRAFT_COUNT"]                       = "Number of crafts to buy materials for (1–999). List quantities are multiplied by this."
-- L["FOCUS_AH_CRAFT_HINT_TIER"]                              = "Optional crafting tier (1–5) on every row. Choose Any for no item-quality or tier filters (widest search)."
-- L["FOCUS_AH_CRAFT_TIER_ANY"]                               = "Any tier"
-- L["FOCUS_AH_CRAFT_TIER_N"]                                 = "Tier %d"
-- L["FOCUS_AH_CRAFT_COUNT_INVALID"]                          = "Enter a whole number from 1 to 999."
-- L["RECENT_PROGRESS_TOP"]                                   = "Show recent progress at the top."
-- L["RECIPE_ICON_NEXT_TITLE_REQUIRES_QUEST"]                 = "Show recipe icon next to title. Requires quest type icons in Display."
-- L["SECTION_DIVIDERS"]                                      = "Show section dividers"
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
-- L["SIZE_SHAPE"]                                            = "Size & shape"
-- L["SIZE_OF_ZOOM_BUTTONS_PIXELS"]                           = "Size of the + and - zoom buttons (pixels)."
-- L["SORT_MODE"]                                             = "Sort mode"
L["SORTING_FILTERING"]                                        = "Sortierung & Filterung"
-- L["SOUND_PLAYED_A_RARE_BOSS_APPEARS"]                      = "Sound played when a rare boss appears."
-- L["STATUS_BADGES"]                                         = "Status badges"
-- L["SUBZONE_CHANGES"]                                       = "Subzone changes"
-- L["SUPER_TRACKED_FIRST_CURRENT_ZONE_FIRST"]                = "Super-tracked first, or current zone first."
-- L["SUPPRESS_IN_ARENA_DETAIL"]                              = "Suppress all Presence notifications while inside a PvP arena."
-- L["SUPPRESS_PRESENCE_NOTIFICATIONS_WHILE_INSIDE_A"]        = "Suppress all Presence notifications while inside a battleground."
-- L["SUPPRESS_IN_DUNGEON_DETAIL"]                            = "Suppress all Presence notifications while inside a dungeon (except boss emotes, achievements, level-up)."
-- L["SUPPRESS_IN_RAID_DETAIL"]                               = "Suppress all Presence notifications while inside a raid."
-- L["SUPPRESS_M"]                                            = "Suppress in M+"
-- L["SUPPRESS_PVP"]                                          = "Suppress in PvP"
-- L["SUPPRESS_BATTLEGROUND"]                                 = "Suppress in battleground"
-- L["SUPPRESS_DUNGEON"]                                      = "Suppress in dungeon"
-- L["SUPPRESS_RAID"]                                         = "Suppress in raid"
-- L["SUPPRESS_NOTIFICATIONS_DUNGEONS"]                       = "Suppress notifications in dungeons."
-- L["TAKES_PRIORITY_SUPPRESS_UNTIL_RELOAD_ACCEPTING"]        = "Takes priority over suppress-until-reload. Accepting removes from blacklist."
-- L["TOAST_ICONS"]                                           = "Toast icons"
-- L["TOGGLE_TRACKING_WORLD_QUESTS_RARES_ACHIEVEMENTS"]       = "Toggle tracking for world quests, rares, achievements, and more."
-- L["TOOLTIP_ANCHOR"]                                        = "Tooltip anchor"
-- L["TRACKED_OBJECTIVES_ADVENTURE_GUIDE"]                    = "Tracked objectives from Adventure Guide."
-- L["TRACKED_VS_LOG_COUNT"]                                  = "Tracked vs in-log count."
-- L["TRACKED_LOG_LOG_MAX_TRACKED_EXCLUDES"]                  = "Tracked/in-log or in-log/max. Tracked excludes world and in-zone quests."
-- L["TRANSMOG_STATUS"]                                       = "Transmog status"
-- L["TRAVELERS_LOG"]                                         = "Traveler's Log"
-- L["TUNE_SLIDE_FADE_EFFECTS_PLUS_OBJECTIVE"]                = "Tune slide and fade effects, plus objective progress flashes."
-- L["UNBLOCK"]                                               = "Unblock"
-- L["UNTRACK_COMPLETE"]                                      = "Untrack when complete"
-- L["CHECKMARK_COMPLETED_OBJECTIVES"]                        = "Use checkmark for completed objectives."
-- L["VISIBILITY_FADING"]                                     = "Visibility & fading"
-- L["COMPLETED_QUESTS_STAY_THEIR_ORIGINAL_CATEGO"]           = "When off, completed quests stay in their original category."
-- L["ZONE_QUESTS_APPEAR_THEIR_NORMAL_CATEGORY"]              = "When off, in-zone quests appear in their normal category."
-- L["THEY_MOVE_COMPLETE_SECTION"]                            = "When off, they move to the Complete section."
-- L["CUSTOM_FILL_COLOUR_BELOW"]                              = "When off, uses the custom fill colour below."
-- L["COMPLETED_OBJECTIVES_COLOUR_BELOW"]                     = "When on, completed objectives use the colour below."
-- L["WHERE_COUNTDOWN"]                                       = "Where to show the countdown."
-- L["WORLD_QUEST_ACCEPT"]                                    = "World quest accept"
-- L["WORLD_QUEST_COMPLETE"]                                  = "World quest complete"
L["X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]                   = "X/Y: objectives like 3/10. Percent: objectives like 45%%."
-- L["ZONE_ENTRY"]                                            = "Zone entry"
-- L["ZONE_LABELS"]                                           = "Zone labels"
-- L["ZONE_NAME_NEW_ZONE"]                                    = "Zone name still appears when entering a new zone."
-- L["ZONE_TYPE_COLOURING"]                                   = "Zone type colouring"
-- L["FOCUS_COMPLETED_CHECKMARK"]                             = "|TInterface\\\\Buttons\\\\UI-CheckBox-Check:12:12:0:0|t instead of green for done objectives."

























































































































































