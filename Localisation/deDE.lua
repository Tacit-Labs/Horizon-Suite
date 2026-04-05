if GetLocale() ~= "deDE" then return end

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = setmetatable({}, { __index = addon.L })
addon.L = L
addon.StandardFont = UNIT_NAME_FONT

-- =====================================================================
-- OptionsPanel.lua (deprecated) — remaining strings for that UI
-- Panel title + module short names: addon.BrandDisplay (core/BrandDisplay.lua).
-- =====================================================================
L["OPTIONS_FOCUS_OTHER"]                                              = "Andere"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["OPTIONS_FOCUS_QUEST_TYPES"]                                        = "Quest-Typen"
L["OPTIONS_FOCUS_ELEMENT_OVERRIDES"]                                  = "Elementübersteuerung"
L["OPTIONS_FOCUS_PER_CATEGORY"]                                       = "Pro Kategorie"
L["OPTIONS_FOCUS_GROUPING_OVERRIDES"]                                 = "Gruppenübersteuerung"
L["OPTIONS_FOCUS_SECTION_OVERRIDES"]                                  = "Sektionübersteuerung"
L["OPTIONS_FOCUS_COLORS"]                                             = "Weitere Farben"

-- =====================================================================
-- OptionsPanel.lua — Color row labels (collapsible group sub-rows)
-- =====================================================================
L["OPTIONS_FOCUS_SECTION"]                                            = "Abschnitt"
L["OPTIONS_FOCUS_TITLE"]                                              = "Titel"
-- L["OPTIONS_FOCUS_ZONE"]                                            = "Zone"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_OBJECTIVE"]                                          = "Ziel"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["OPTIONS_FOCUS_READY_TURN_OVERRIDES_BASE_COLOURS"]                  = "Abgabebereit überschreibt Basis-Farben"
L["OPTIONS_FOCUS_READY_TURN_COLOURS_QUESTS"]                          = "Abgabebereite Quests verwenden ihre Farben in diesem Abschnitt."
L["OPTIONS_FOCUS_CURRENT_ZONE_OVERRIDES_BASE_COLOURS"]                = "Aktuelle Zone überschreibt Basisfarben"
L["OPTIONS_FOCUS_CURRENT_ZONE_COLOURS_QUESTS_SEC"]                    = "Quests der aktuellen Zone verwenden ihre Farben in diesem Abschnitt."
L["OPTIONS_FOCUS_CURRENT_QUEST_OVERRIDES_BASE_COLOURS"]               = "Aktuelle Quest überschreibt Basisfarben"
L["OPTIONS_FOCUS_CURRENT_QUEST_COLOURS_QUESTS_SE"]                    = "Quests der aktuellen Quest verwenden ihre Farben in diesem Abschnitt."
L["OPTIONS_FOCUS_DISTINCT_COLOR_COMPLETED_OBJECTIVES"]                = "Abgeschlossene Ziele hervorheben"
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES_E_G_COLOR_B"]                   = "An: abgeschlossene Ziele (z.B. 1/1) nutzen die Farbe unten. Aus: gleiche Farbe wie unvollständige Ziele."
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVE"]                                = "Abgeschlossenes Ziel"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["OPTIONS_FOCUS_RESET"]                                              = "Zurücksetzen"
L["OPTIONS_FOCUS_RESET_QUEST_TYPES"]                                  = "Quest-Typen zurücksetzen"
L["OPTIONS_FOCUS_RESET_OVERRIDES"]                                    = "Übersteuerungen zurücksetzen"
L["OPTIONS_FOCUS_RESET_DEFAULTS"]                                     = "Alle auf Standard zurücksetzen"
L["OPTIONS_FOCUS_RESET_TO_DEFAULTS"]                                  = "Auf Standard zurücksetzen"
L["OPTIONS_FOCUS_RESET_DEFAULT"]                                      = "Auf Standard zurücksetzen"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["OPTIONS_FOCUS_SEARCH_SETTINGS"]                                    = "Einstellungen durchsuchen..."
L["OPTIONS_FOCUS_SEARCH_FONTS"]                                       = "Schriftarten durchsuchen..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["OPTIONS_FOCUS_DRAG_RESIZE"]                                        = "Zum Verändern der Größe ziehen"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
L["OPTIONS_AXIS_PROFILES"]                                            = "Profile"
L["OPTIONS_AXIS_MODULES"]                                             = "Module"
L["OPTIONS_AXIS_MODULE_TOGGLES"]                                      = "Modulsteuerung"

-- =====================================================================
-- options/dashboard/HomeWelcome.lua — First-run welcome
-- =====================================================================
L["DASH_WHATS_NEW"]                                                   = "Änderungen"
L["DASH_FULL_CHANGELOG"]                                              = "Full changelog"
L["DASH_WHATS_NEW_UNREAD_SUFFIX"]                                     = " (Neu!)"
L["DASH_WELCOME_TAB"]                                                 = "Willkommen"
L["DASH_WELCOME_TITLE"]                                               = "Willkommen bei der Horizon Suite"
L["DASH_WELCOME_HEAD_SUB"]                                            = "What each module does and where to turn them on"
L["DASH_WELCOME_INTRO"]                                               = "Horizon Suite is modular — enable only the pieces you want. Turning a module on or off applies on reload. Expand Contributors or Localisations below for credits and supported languages. Use Open module toggles under Modules, or open Axis, then Modules, in the sidebar. You can return to this Welcome page anytime from the sidebar."
L["DASH_WELCOME_PATH"]                                                = "%s → %s → %s"
-- L["DASH_WELCOME_FOCUS_BLIZZARD_PLUS_HEADING"]                      = "Blizzard+ click profile"  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_FOCUS_BLIZZARD_PLUS_BODY"]                         = [=[Focus now uses |cffffffffBlizzard+|r by default — Blizzard-style quest row clicks with a few Horizon conveniences. Open |cffaaaaaaFocus > Interactions|r and use |cffaaaaaaClick profile|r to see the preset; |cffffffffHorizon+|r and full |cffffffffCustom|r shortcuts are on the way.]=]  -- NEEDS TRANSLATION
L["DASH_WELCOME_COMING_SOON_TITLE"]                                   = "In Kürze"
-- L["DASH_WELCOME_COMING_SOON_TAGLINE"]                              = "New welcome experiences are on the way."  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_COMING_SOON_BODY"]                                 = [=[Watch this space — we will post updates here and in |cffaaaaaaPatch Notes|r. Join |cffaaaaaaDiscord|r from the links below for news and feedback.]=]  -- NEEDS TRANSLATION
L["DASH_WELCOME_CLASS_ICONS_HEADING"]                                 = "Horizon class icons"
L["DASH_WELCOME_CLASS_ICONS_LEAD"]                                    = [=[We have added a bundled set of custom class icons — now the default when you choose |cffaaaaaaHorizon|r under |cffaaaaaaAxis → Global Toggles|r (Class icon style).]=]
-- L["DASH_WELCOME_CLASS_ICONS_THANK_BOOFULS"]                        = [=[Thank you, Boofuls, for commissioning this art and helping bring these icons to everyone.]=]  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_CLASS_ICONS_CREATED_PREFIX"]                       = "• Created by "  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_CLASS_ICONS_ARTIST_NAME"]                          = "Gabriel C"  -- NEEDS TRANSLATION
L["DASH_WELCOME_CONTRIBUTORS_HEADING"]                                = "Beitragende"
L["DASH_WELCOME_CONTRIBUTORS_BODY"]                                   = [=[Thanks to everyone who has contributed to Horizon Suite:

• feanor21#2847 — Panoramuxa (Tarren Mill - EU) — Entwicklung
• Marthix — Entwicklung
• Swift — Koordinator
• Boofuls — Moderator
• RondoFerrari — RondoMedia (CurseForge addon) — Class icons in Insight tooltips and optional Dashboard header icon when class colors are on (optional)
• Aishuu — Französische Lokalisierung (frFR)
• 아즈샤라-두녘 — Koreanische Lokalisierung (koKR)
• Linho-Gallywix — Brazilian Portuguese localisation (ptBR)
• allmoon — Chinesische Lokalisierung (zhCN)]=]
L["DASH_WELCOME_LOCALISATIONS_HEADING"]                               = "Lokalisierungen"
L["DASH_WELCOME_LOCALISATIONS_BODY"]                                  = [=[The options panel is localised for:

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
L["DASH_GUIDE_TAB"]                                                   = "Anleitung"
-- L["DASH_GUIDE_HEAD_SUB"]                                           = "What each part of Horizon does"  -- NEEDS TRANSLATION
-- L["DASH_GUIDE_HERO_TITLE"]                                         = "Getting started with Horizon Suite"  -- NEEDS TRANSLATION
-- L["DASH_GUIDE_HERO_TAGLINE"]                                       = "A modular UI toolkit for quests, notifications, the minimap, and more."  -- NEEDS TRANSLATION
L["DASH_GUIDE_HERO_INTRO"]                                            = "Pick the modules you want, tune them in the sidebar, and reload when you toggle something on or off. This page is always here — open it anytime from the Guide row under Welcome."
L["DASH_GUIDE_QUICK_START_HEADING"]                                   = "Schnellstart"
L["DASH_GUIDE_QUICK_START_BODY"]                                      = [=[• Under |cffaaaaaaAxis → Modules|r in the sidebar, turn each module on or off. Changing modules applies after a |cffaaaaaaReload UI|r.
-- • Under |cffaaaaaaAxis → Global Toggles|r, set class-colour tinting for the dashboard and modules, pick a |cffaaaaaaDashboard background|r preset, and adjust |cffaaaaaaUI scale|r (global or per module).]=]
L["DASH_GUIDE_HORIZON_HEADING"]                                       = "Was ist die Horizon Suite?"
L["DASH_GUIDE_HORIZON_BULLETS"]                                       = [=[• Axis — Profiles, module on/off, global toggles, typography, and other suite-wide settings.  -- NEEDS TRANSLATION
• Focus — Quest and content tracker: quests, world quests, scenarios, rares, achievements, and more in coloured sections.
• Presence — Large cinematic toasts for zones, quests, scenarios, achievements, level up, and similar moments.
• Vista — Minimap chrome: zone text, coordinates, clock, and a collector for minimap buttons.
• Insight — Richer tooltips for players, NPCs, and items (class colours, spec, icons, extras).
• Cache — Loot toasts and bag presentation.
• Essence — Character sheet with 3D model, item level, stats, and gear grid.
• Meridian — Coming soon.]=]
-- L["DASH_GUIDE_MOD_AXIS_BODY"]                                      = "Axis is the control centre: switch profiles, enable or disable whole modules, open Global Toggles for class colours and UI scale, and reach typography and appearance options that apply across Horizon. Start here when you first install or when you want a lighter footprint by turning modules off."  -- NEEDS TRANSLATION
L["DASH_GUIDE_MOD_FOCUS_BODY"]                                        = [=[Focus replaces the default objective list with a flexible tracker. Tracked quests, world quests, scenarios, rares, achievements, endeavors, decor, recipes, and more are grouped into coloured section headers so you can scan quickly.  -- NEEDS TRANSLATION

Sections only appear when they have something to show — for example Current (recent progress), Current zone, Ready to turn in, World / weekly / daily / Prey, campaign and special quests, delves and scenarios, rare bosses and loot, achievements and collections, and time-limited or zone events.

Use Focus → Sorting & filtering to reorder sections, and Focus → Content to choose which types of content appear.]=]
-- L["DASH_GUIDE_PRESENCE_INTRO"]                                     = "Presence shows large, styled alerts for moments that used to be separate Blizzard popups — zone changes, quest progress, achievements, scenarios, and more. You can turn each type on or off and tune typography in Presence settings."  -- NEEDS TRANSLATION
L["DASH_GUIDE_PRESENCE_BODY"]                                         = [=[Typical Presence toasts include:  -- NEEDS TRANSLATION

• Zone and subzone discovery text when you enter new areas.
• Quest accepted, objective progress, quest complete, and world quest complete.
• Scenario start, progress updates, and completion (including delve-style flow).
• Achievements earned and optional achievement progress ticks.
• Level up, boss emotes, and rare defeated.]=]
-- L["DASH_GUIDE_PRESENCE_BLIZZARD"]                                  = [=[When a Presence type is enabled, Horizon can hide the matching default UI so you don’t get duplicates — for example zone name banners, the level-up frame, boss emote bar, event toast manager, world-quest completion banner, and some objective bonus banners. Turn a Presence type off in settings to let the default game UI show again for that category.]=]  -- NEEDS TRANSLATION
-- L["DASH_GUIDE_MOD_VISTA_BODY"]                                     = "Vista wraps your minimap with readable zone and subzone text, optional coordinates and clock, and a bar that collects stray minimap buttons so they stay tidy. Tune layout and colours under Vista in the sidebar."  -- NEEDS TRANSLATION
-- L["DASH_GUIDE_MOD_INSIGHT_BODY"]                                   = "Insight extends Blizzard tooltips for players, NPCs, and items — class and faction colouring, spec and icon lines, optional Mythic+ score, item level, mount collection hints, and cleaner separators. Each tooltip type has its own category under Insight."  -- NEEDS TRANSLATION
-- L["DASH_GUIDE_MOD_CACHE_BODY"]                                     = "Cache handles loot feedback: styled loot toasts for items, money, currency, and reputation, plus options that tie into how rewards are shown. Enable it when you want Horizon’s presentation instead of the default loot popups."  -- NEEDS TRANSLATION
-- L["DASH_GUIDE_MOD_ESSENCE_BODY"]                                   = "Essence is an optional character sheet: 3D model, item level, primary stats, and a gear grid so you can review your equipment at a glance. Open Essence in the sidebar to adjust layout and visibility."  -- NEEDS TRANSLATION
L["DASH_GUIDE_MOD_MERIDIAN_BODY"]                                     = "In Kürze."
-- L["DASH_AXIS_MODULE_SHORT_DESCRIPTION"]                            = "Core settings hub: profiles, modules, and global toggles."  -- NEEDS TRANSLATION
-- L["DASH_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS"]                    = "Objective tracker for quests, world quests, rares, achievements, scenarios."  -- NEEDS TRANSLATION
-- L["DASH_ZONE_TEXT_AND_NOTIFICATIONS"]                              = "Zone text and notifications."  -- NEEDS TRANSLATION
-- L["DASH_MINIMAP_ZONE_TEXT_COORDS_BUTTON"]                          = "Minimap with zone text, coords, time, and button collector."  -- NEEDS TRANSLATION
-- L["DASH_TOOLTIPS_CLASS_COLORS_SPEC_FACTION"]                       = "Tooltips with class colors, spec, and faction icons."  -- NEEDS TRANSLATION
-- L["DASH_LOOT_TOASTS_ITEMS_MONEY_CURRENCY"]                         = "Loot toasts for items, money, currency, reputation, and bag overhaul."  -- NEEDS TRANSLATION
-- L["DASH_ESSENCE_MODULE_SHORT_DESCRIPTION"]                         = "Custom character sheet with 3D model, item level, stats, and gear grid."  -- NEEDS TRANSLATION
L["DASH_MERIDIAN_MODULE_SHORT_DESCRIPTION"]                           = "In Kürze."
-- L["DASH_WELCOME_COMMUNITY_HEADING"]                                = "Community & Support"  -- NEEDS TRANSLATION
-- L["DASH_DISCORD"]                                                  = "Discord"  -- NEEDS TRANSLATION
-- L["DASH_KO_FI"]                                                    = "Ko-fi"  -- NEEDS TRANSLATION
-- L["DASH_PATREON"]                                                  = "Patreon"  -- NEEDS TRANSLATION
-- L["DASH_GITLAB"]                                                   = "GitLab"  -- NEEDS TRANSLATION
-- L["DASH_CURSEFORGE"]                                               = "CurseForge"  -- NEEDS TRANSLATION
-- L["DASH_WAGO"]                                                     = "Wago"  -- NEEDS TRANSLATION
L["DASH_COPY_LINK_X"]                                                 = "Link kopieren — %s"
-- L["DASH_LAYOUT"]                                                   = "Layout"  -- NEEDS TRANSLATION
L["DASH_VISIBILITY"]                                                  = "Sichtbarkeit"
L["DASH_DISPLAY"]                                                     = "Anzeige"
L["DASH_FEATURES"]                                                    = "Funktionen"
L["DASH_TYPOGRAPHY"]                                                  = "Typografie"
L["DASH_APPEARANCE"]                                                  = "Aussehen"
L["DASH_COLORS"]                                                      = "Farben"
L["DASH_ORGANIZATION"]                                                = "Organisation"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["OPTIONS_FOCUS_PANEL_BEHAVIOUR"]                                    = "Panelverhalten"
L["OPTIONS_FOCUS_DIMENSIONS"]                                         = "Abmessungen"
L["OPTIONS_FOCUS_INSTANCE"]                                           = "Instanz"
L["OPTIONS_FOCUS_INSTANCES"]                                          = "Instanzen"
L["OPTIONS_FOCUS_COMBAT"]                                             = "Kampf"
L["OPTIONS_FOCUS_FILTERING"]                                          = "Filterung"
L["OPTIONS_FOCUS_HEADER"]                                             = "Kopfzeile"
L["OPTIONS_FOCUS_SECTIONS_STRUCTURE"]                                 = "Sektionen & Struktur"
L["OPTIONS_FOCUS_ENTRY_DETAILS"]                                      = "Eintragsdetails"
L["OPTIONS_FOCUS_PROGRESS_TIMERS"]                                    = "Fortschritt & Timer"
L["OPTIONS_FOCUS_EMPHASIS"]                                           = "Fokus-Hervorhebung"
L["OPTIONS_FOCUS_LIST"]                                               = "Liste"
L["OPTIONS_FOCUS_SPACING"]                                            = "Abstände"
L["OPTIONS_FOCUS_RARE_BOSSES"]                                        = "Rare Bosse"
L["OPTIONS_FOCUS_WORLD_QUESTS"]                                       = "Welt-Quests"
L["OPTIONS_FOCUS_FLOATING_QUEST_ITEM"]                                = "Schwebendes Quest-Item"
L["OPTIONS_FOCUS_MYTHIC"]                                             = "Mythisch+"
L["OPTIONS_FOCUS_ACHIEVEMENTS"]                                       = "Erfolge"
-- L["OPTIONS_FOCUS_ACHIEVEMENT_PROGRESS_BARS"]                       = "Achievement progress bars"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_ACHIEVEMENT_PROGRESS_BARS_DESC"]                  = "Show a progress bar under tracked achievements that report numeric criteria (including 0/1 and X/Y). Independent of Quest Progress Bars."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_ACHIEVEMENT_PROGRESS_BARS_TIP"]                   = "Uses the same bar colors, texture, and font as other Focus progress bars when those options are visible."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_ENDEAVORS"]                                          = "Bestrebungen"
L["OPTIONS_FOCUS_DECOR"]                                              = "Dekoration"
-- L["OPTIONS_FOCUS_APPEARANCES"]                                     = "Appearances"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_SCENARIO_DELVE"]                                     = "Szenarios & Tiefen"
L["OPTIONS_FOCUS_FONT"]                                               = "Schriftart"
L["OPTIONS_FOCUS_FONT_FAMILIES"]                                      = "Schriftarten"
L["OPTIONS_FOCUS_GLOBAL_FONT_SIZE"]                                   = "Globale Schriftgröße"
L["OPTIONS_FOCUS_FONT_SIZES"]                                         = "Schriftgrößen"
L["OPTIONS_FOCUS_PER_ELEMENT_FONTS"]                                  = "Schriftart pro Element"
L["OPTIONS_FOCUS_TEXT_CASE"]                                          = "Groß-/Kleinschreibung"
L["OPTIONS_FOCUS_SHADOW"]                                             = "Schatten"
-- L["OPTIONS_FOCUS_PANEL"]                                           = "Panel"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_HIGHLIGHT"]                                          = "Hervorhebung"
L["OPTIONS_FOCUS_COLOR_MATRIX"]                                       = "Farbmatrix"
L["OPTIONS_FOCUS_ORDER"]                                              = "Reihenfolge"
L["OPTIONS_FOCUS_SORT"]                                               = "Sortierung"
L["OPTIONS_FOCUS_BEHAVIOUR"]                                          = "Verhalten"
L["OPTIONS_FOCUS_CONTENT_TYPES"]                                      = "Inhaltstypen"
L["OPTIONS_FOCUS_DELVES"]                                             = "Tiefen"
L["OPTIONS_FOCUS_DELVES_DUNGEONS"]                                    = "Tiefen & Verliese"
L["OPTIONS_FOCUS_DELVE_COMPLETE"]                                     = "Tiefe abgeschlossen"
L["OPTIONS_FOCUS_INTERACTIONS"]                                       = "Interaktionen"
L["OPTIONS_FOCUS_TRACKING"]                                           = "Verfolgung"
L["OPTIONS_FOCUS_SCENARIO_BAR"]                                       = "Szenarioleiste"

-- =====================================================================
-- OptionsData.lua Profiles
-- =====================================================================
L["OPTIONS_AXIS_CURRENT_PROFILE"]                                     = "aktuelles Profil"
L["OPTIONS_AXIS_SELECT_PROFILE_CURRENTLY"]                            = "Wähle das derzeit verwendete Profil aus"
L["OPTIONS_AXIS_GLOBAL_PROFILE_ACCOUNT_WIDE"]                         = "Globales Profil nutzen (accountweit)"
L["OPTIONS_AXIS_CHARACTERS_SAME_PROFILE"]                             = "Alle Charaktere nutzen dasselbe Profil"
L["OPTIONS_AXIS_ENABLE_PER_SPECIALIZATION_PROFILES"]                  = "Profil pro Spezialisierung aktivieren"
L["OPTIONS_AXIS_PICK_DIFFERENT_PROFILES_PER_SPEC"]                    = "Wähle unterschiedliche Profile pro Spec"
L["OPTIONS_AXIS_SPECIALIZATION"]                                      = "Spezialisierung"
L["OPTIONS_AXIS_SHARING"]                                             = "Teilen"
L["OPTIONS_AXIS_IMPORT_PROFILE"]                                      = "Profil importieren"
L["OPTIONS_AXIS_IMPORT_STRING"]                                       = "Import String"
L["OPTIONS_AXIS_EXPORT_PROFILE"]                                      = "Profil exportieren"
L["OPTIONS_AXIS_SELECT_A_PROFILE_EXPORT"]                             = "Wähle ein Profil für den Export"
L["OPTIONS_AXIS_EXPORT_STRING"]                                       = "Export-String"
L["OPTIONS_AXIS_COPY_PROFILE"]                                        = "Von Profil kopieren"
L["OPTIONS_AXIS_SOURCE_PROFILE_COPYING"]                              = "Quell-Profil zum Kopieren"
L["OPTIONS_AXIS_COPY_SELECTED"]                                       = "Auswahl kopieren"
L["OPTIONS_AXIS_CREATE"]                                              = "Erstellen"
L["OPTIONS_AXIS_CREATE_PROFILE_DEFAULT_TEMPLATE"]                     = "Erstelle neues Profil aus Standard-Vorlage"
L["OPTIONS_AXIS_CREATES_A_PROFILE_DEFAULT_SETTINGS"]                  = "Erstellt ein neues Profil mit den Standard-Einstellungen"
L["OPTIONS_AXIS_CREATES_A_PROFILE_COPIED_SELECTED_SOURC"]             = "Erstellt ein neues Profil mit den Einstellungen des Quell-Profils"
L["OPTIONS_AXIS_DELETE_PROFILE"]                                      = "Profil löschen"
L["OPTIONS_AXIS_SELECT_A_PROFILE_DELETE_CURRENT_DEFAULT"]             = "Wähle ein Profil zum Löschen (derzeitiges und Standard nicht angezeigt)"
L["OPTIONS_AXIS_DELETE_SELECTED"]                                     = "Ausgewähltes löschen"
L["OPTIONS_AXIS_DELETE_SELECTED_PROFILE"]                             = "Löscht das ausgewählte Profil"
L["OPTIONS_AXIS_DELETE"]                                              = "Löschen"
L["OPTIONS_AXIS_DELETES_SELECTED_PROFILE"]                            = "Löscht das ausgewählte Profil"
L["OPTIONS_AXIS_GLOBAL_PROFILE"]                                      = "Globales Profil"
L["OPTIONS_AXIS_PER_SPEC_PROFILES"]                                   = "Pro-Spec Profile"

-- =====================================================================
-- OptionsData.lua Modules
-- =====================================================================
L["OPTIONS_AXIS_ENABLE_FOCUS_MODULE"]                                 = "Fokus-Modul aktivieren"
L["OPTIONS_AXIS_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS_R"]             = "Zeige die Zielverfolgung für Welt-(Quests), Rares, Erfolge und Szenarien an"
L["OPTIONS_AXIS_ENABLE_PRESENCE_MODULE"]                              = "Presence Modul aktivieren"
L["OPTIONS_AXIS_CINEMATIC_ZONE_TEXT_NOTIFICATIONS_ZONE_CHANGES"]      = "Filmische Zonentext- und Benachrichtigungsanzeige (Zonenänderungen, Level up, Boss Emotes, Erfolge, Quest updates)"
L["OPTIONS_AXIS_ENABLE_CACHE_MODULE"]                                 = "Ertrag-Modul aktivieren"
L["OPTIONS_AXIS_CINEMATIC_LOOT_NOTIFICATIONS_ITEMS_MONEY_CURRENCY"]   = "Filmische Loot-Benachrichtigungen (Items, Gold, Währungen, Ruf)"
L["OPTIONS_AXIS_ENABLE_VISTA_MODULE"]                                 = "Vista-Modul aktivieren"
L["OPTIONS_AXIS_CINEMATIC_SQUARE_MINIMAP_ZONE_TEXT_COORDINATES"]      = "Filmische quadratische Minimap mit Zonentext, Koordinaten und Button-Sammlung"
L["OPTIONS_AXIS_MINIMAP_ZONE_TIME_COLLECTOR"]                         = "Filmische quadratische Minimap mit Zonentext, Koordinaten, Uhrzeit und Button-Sammlung"
-- L["OPTIONS_AXIS_BETA"]                                             = "Beta"  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_SCALING"]                                             = "Skalierung"
-- L["OPTIONS_AXIS_GLOBAL_TOGGLES"]                                   = "Global Toggles"  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_PATCH_NOTES_SECTION"]                                 = "Versionsänderungen"
-- L["OPTIONS_AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN"]                   = "Show Patch Notes automatically after an update"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN_DESC"]              = "When on, Axis opens to Patch Notes once after each new addon version. When off, a green dot appears on the Horizon minimap icon until you open Patch Notes."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_SUITE_WIDE_CLASS_COLOUR_TINTING_UI"]               = "Dashboard background theme, class colour tinting, and UI scale (global or per module)."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_GLOBAL_UI_SCALE"]                                     = "Globale UI-Skalierung"
L["OPTIONS_AXIS_SCALE_SIZES_SPACINGS_FONTS_FACTOR"]                   = "Alle Größen, Abstände und Schriftarten werden um diesen Faktor (50–200 %) skaliert. Deine konfigurierten Werte bleiben dabei unverändert."
L["OPTIONS_AXIS_PER_MODULE_SCALING"]                                  = "Skalierung pro Modul"
L["OPTIONS_AXIS_OVERRIDE_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_FO"]         = "Globale Skalierung durch Einzelschieber je Modul ersetzen."
L["OPTIONS_AXIS_OVERRIDES_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_F"]         = "Überschreibt die globale Skalierung durch individuelle Schieberegler für Focus, Presence, Vista, usw."
L["OPTIONS_AXIS_DOESN_T_CHANGE_YOUR_CONFIGURED_VALUES"]               = "Deine konfigurierten Werte werden dadurch nicht verändert, nur die effektive Anzeigeskalierung"
L["OPTIONS_FOCUS_SCALE"]                                              = "Fokus-Skalierung"
L["OPTIONS_AXIS_SCALE_FOCUS_OBJECTIVE_TRACKER"]                       = "Fokus-Zielverfolungsskalierung (50–200%)"
L["OPTIONS_PRESENCE_SCALE"]                                           = "Presence Skalierung"
L["OPTIONS_AXIS_SCALE_PRESENCE_CINEMATIC_TEXT"]                       = "Skalierung für den filmischen Presence Text (50–200%)"
L["OPTIONS_VISTA_SCALE"]                                              = "Vista-Skalierung"
L["OPTIONS_AXIS_SCALE_VISTA_MINIMAP_MODULE"]                          = "Skalierung für das Vista Minimap-Modul (50–200%)"
L["OPTIONS_INSIGHT_SCALE"]                                            = "Insight Skalierung"
L["OPTIONS_AXIS_SCALE_INSIGHT_TOOLTIP_MODULE"]                        = "Skalierung für das Insight Tooltip-Modul (50–200%)"
L["OPTIONS_CACHE_SCALE"]                                              = "Ertrag-Skalierung"
L["OPTIONS_AXIS_SCALE_CACHE_LOOT_TOAST_MODULE"]                       = "Skalierung des Ertrag-Beute-Toast-Moduls (50–200%)."
L["OPTIONS_AXIS_ENABLE_HORIZON_INSIGHT_MODULE"]                       = "Horizon Insight-Modul aktivieren"
L["OPTIONS_AXIS_CINEMATIC_TOOLTIPS_CLASS_COLORS_SPEC_DISPLAY"]        = "Filmische Tooltips mit Klassenfarben, Spez-Anzeige und Fraktionssymbolen."
L["OPTIONS_AXIS_TOOLTIP_ANCHOR_MODE"]                                 = "Tooltip-Ankermodus"
L["OPTIONS_AXIS_WHERE_TOOLTIPS_APPEAR_FOLLOW_CURSOR_FIXED"]           = "Wo Tooltips erscheinen: Cursor folgen oder feste Position."
L["OPTIONS_AXIS_CURSOR"]                                              = "Zeiger"
L["OPTIONS_AXIS_FIXED"]                                               = "Fixiert"
L["OPTIONS_AXIS_ANCHOR_MOVE"]                                         = "Anker zum Verschieben anzeigen"
-- L["OPTIONS_AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITIO"]                   = "Click to show or hide the anchor. Drag to set position, right-click to confirm."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_DRAGGABLE_FRAME_FIXED_TOOLTIP_POSITION_D"]            = "Ziehbaren Rahmen zur festen Tooltip-Position anzeigen. Ziehen, dann Rechtsklick zum Bestätigen."
L["OPTIONS_AXIS_RESET_TOOLTIP_POSITION"]                              = "Tooltip-Position zurücksetzen"
L["OPTIONS_AXIS_RESET_FIXED_POSITION_DEFAULT"]                        = "Feste Position auf Standard zurücksetzen."
L["OPTIONS_INSIGHT_CURSOR_OFFSET_X"]                                  = "Zeigerversatz X"
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_X_DESC"]                          = "Horizontal pixel offset from the default cursor tooltip position (cursor anchor only)."  -- NEEDS TRANSLATION
L["OPTIONS_INSIGHT_CURSOR_OFFSET_Y"]                                  = "Zeigerversatz Y"
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_Y_DESC"]                          = "Vertical pixel offset from the default cursor tooltip position (cursor anchor only)."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_TOOLTIP_BACKGROUND_COLOR"]                            = "Tooltip-Hintergrundfarbe"
L["OPTIONS_AXIS_COLOR_OF_TOOLTIP_BACKGROUND"]                         = "Farbe des Tooltip-Hintergrunds."
L["OPTIONS_AXIS_TOOLTIP_BACKGROUND_OPACITY"]                          = "Tooltip-Hintergrunddeckkraft"
L["OPTIONS_AXIS_TOOLTIP_BG_OPACITY_PCT_DESC"]                         = "Tooltip-Hintergrunddeckkraft (0–100 %)."
L["OPTIONS_AXIS_TOOLTIP_FONT"]                                        = "Tooltip-Schriftart"
L["OPTIONS_AXIS_FONT_FAMILY_TOOLTIP_TEXT"]                            = "Schriftfamilie für den gesamten Tooltip-Text."
-- L["OPTIONS_INSIGHT_BODY_SIZE"]                                     = "Body size"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_BODY_FONT_SIZE"]                                = "Body font size."  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_BADGES_SIZE"]                                   = "Badges size"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_BADGES_FONT_SIZE"]                              = "Status badges font size."  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_STATS_SIZE"]                                    = "Stats size"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_STATS_FONT_SIZE"]                               = "M+ score, item level, and honor level font size."  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_MOUNT_SIZE"]                                    = "Mount size"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_MOUNT_FONT_SIZE"]                               = "Mount name, source, and ownership font size."  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_MOUNT_OWNERSHIP_DISPLAY"]                       = "Mount collection indicator"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_MOUNT_OWNERSHIP_DISPLAY_DESC"]                  = "How to show whether you have collected the hovered player's mount."  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_MOUNT_OWNERSHIP_TEXT"]                          = "Full text"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_MOUNT_OWNERSHIP_ICONS"]                         = "Tick / cross"  -- NEEDS TRANSLATION
-- L["INSIGHT_MOUNT_OWNED"]                                           = "You own this mount"  -- NEEDS TRANSLATION
-- L["INSIGHT_MOUNT_NOT_OWNED"]                                       = "You don't own this mount"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_TRANSMOG_SIZE"]                                 = "Transmog size"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_TRANSMOG_FONT_SIZE"]                            = "Item appearance status font size."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_TOOLTIPS"]                                         = "Tooltips"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_CATEGORY_GLOBAL"]                               = "Global Tooltips"  -- NEEDS TRANSLATION
L["OPTIONS_INSIGHT_CATEGORY_GLOBAL_DESC"]                             = "Anchor, backdrop, fonts, sizes, and display options shared across tooltip types."
-- L["OPTIONS_INSIGHT_CATEGORY_PLAYER"]                               = "Player Characters"  -- NEEDS TRANSLATION
L["OPTIONS_INSIGHT_CATEGORY_PLAYER_DESC"]                             = "Guild rank, titles, badges, PvP, ratings, gear, and mount lines on player tooltips."
-- L["OPTIONS_INSIGHT_CATEGORY_NPC"]                                  = "NPCs"  -- NEEDS TRANSLATION
L["OPTIONS_INSIGHT_CATEGORY_NPC_DESC"]                                = "NPC tooltip styling. Extra NPC-only toggles can be added here later."
-- L["OPTIONS_INSIGHT_CATEGORY_ITEM"]                                 = "Items"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_CATEGORY_ITEM_DESC"]                            = "Item tooltip options such as transmog collection status."  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_SECTION_IDENTITY"]                              = "Identity"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_PLAYER_NAME_COLOR"]                             = "Player name colour"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_PLAYER_NAME_COLOR_DESC"]                        = "Colour for the player's name on the first tooltip line: faction (Alliance blue, Horde red) or class."  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_PLAYER_NAME_COLOR_FACTION"]                     = "Faction"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_PLAYER_NAME_COLOR_CLASS"]                       = "Class"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_SECTION_STATUS_PVP"]                            = "Status & PvP"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_SECTION_RATINGS_GEAR"]                          = "Ratings & gear"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_SECTION_MOUNT"]                                 = "Mount"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_SECTION_DISMISS"]                               = "Unit tooltip dismiss"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_DISMISS_GRACE"]                                 = "Dismiss grace"  -- NEEDS TRANSLATION
L["OPTIONS_INSIGHT_DISMISS_GRACE_DESC"]                               = "How long to wait after the mouse leaves a unit before starting to hide the GameTooltip. Longer grace reduces flicker from brief cursor gaps."
-- L["OPTIONS_INSIGHT_DISMISS_GRACE_INSTANT"]                         = "Instant"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_DISMISS_GRACE_DEFAULT"]                         = "Normal"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_DISMISS_GRACE_RELAXED"]                         = "Relaxed"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_SECTION_COMBAT"]                                = "Combat"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_HIDE_IN_COMBAT"]                                = "Hide tooltips in combat"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_HIDE_IN_COMBAT_DESC"]                           = "While in combat, close GameTooltip and other Insight-styled tooltip frames and block them from staying open. Applies only when the Insight module is enabled."  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_FADE_OUT_SEC"]                                  = "Fade-out duration"  -- NEEDS TRANSLATION
L["OPTIONS_INSIGHT_FADE_OUT_SEC_DESC"]                                = "Seconds to fade the unit tooltip after dismiss starts. Zero hides immediately (no fade). Applies to GameTooltip unit tips only."
-- L["OPTIONS_INSIGHT_SECTION_ICONS_AND_SEPARATORS"]                  = "Icons & separators"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_SECTION_NPC_TOOLTIP"]                           = "NPC tooltip"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_SECTION_TRANSMOG"]                              = "Transmog"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_NPC_PLACEHOLDER"]                               = "NPC-specific options will appear here when available. Reaction colours and level lines still apply in-game."  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_NPC_REACTION_BORDER"]                           = "Reaction border"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_NPC_REACTION_BORDER_DESC"]                      = "Tint the tooltip border to the NPC's faction reaction (hostile red, friendly green, neutral yellow)."  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_NPC_REACTION_NAME"]                             = "Reaction name colour"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_NPC_REACTION_NAME_DESC"]                        = "Colour the NPC's name to match their faction reaction."  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_NPC_LEVEL_LINE"]                                = "Level line"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_NPC_LEVEL_LINE_DESC"]                           = "Show the NPC's level, classification (Elite, Rare, etc.), and creature type beneath their name."  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_NPC_ICONS_DESC"]                                = "Show an icon instead of '??' for NPCs with an unknown level."  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_SECTION_ITEM_STYLING"]                          = "Item styling"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_ITEM_QUALITY_BORDER"]                           = "Quality border"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_ITEM_QUALITY_BORDER_DESC"]                      = "Tint the tooltip border to the item's quality colour (Uncommon green, Rare blue, Epic purple, etc.)."  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_ITEM_SECTION_SPACING"]                          = "Blank line before blocks"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_ITEM_SECTION_SPACING_DESC"]                     = "Insert a blank line before Insight blocks on item tooltips instead of a tinted separator line."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_ITEM_TOOLTIP"]                                        = "Item-Tooltip"
L["OPTIONS_AXIS_TRANSMOG_STATUS"]                                     = "Transmog-Status anzeigen"
L["OPTIONS_AXIS_WHETHER_YOU_COLLECTED_APPEARANCE_OF_AN"]              = "Anzeigen ob die Erscheinung eines Gegenstands gesammelt wurde."
L["OPTIONS_AXIS_PLAYER_TOOLTIP"]                                      = "Spieler-Tooltip"
L["OPTIONS_AXIS_GUILD_RANK"]                                          = "Gildenrang anzeigen"
L["OPTIONS_AXIS_APPEND_PLAYER_S_GUILD_RANK_NEXT"]                     = "Gildenrang des Spielers neben dem Gildennamen anzeigen."
L["OPTIONS_AXIS_MYTHIC_SCORE"]                                        = "Mythisch+-Punkte anzeigen"
L["OPTIONS_AXIS_PLAYER_S_CURRENT_SEASON_MYTHIC_SCORE"]                = "Aktuelle Saison-Mythisch+-Punkte des Spielers, farbcodiert nach Stufe."
L["OPTIONS_AXIS_ITEM_LEVEL"]                                          = "Gegenstandsstufe anzeigen"
L["OPTIONS_AXIS_PLAYER_S_EQUIPPED_ITEM_LEVEL_AFTER"]                  = "Gegenstandsstufe des Spielers nach Inspektion anzeigen."
L["OPTIONS_AXIS_HONOR_LEVEL"]                                         = "Ehrenstufe anzeigen"
L["OPTIONS_AXIS_PLAYER_S_PVP_HONOR_LEVEL_TOOLTIP"]                    = "PvP-Ehrenstufe des Spielers im Tooltip anzeigen."
L["OPTIONS_AXIS_PVP_TITLE"]                                           = "PvP-Titel anzeigen"
L["OPTIONS_AXIS_PLAYER_S_PVP_TITLE_E_G"]                              = "PvP-Titel des Spielers (z.B. Gladiator) im Tooltip anzeigen."
-- L["OPTIONS_AXIS_CHARACTER_TITLE"]                                  = "Character title"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_PLAYER_S_SELECTED_TITLE_ACHIEVEMENT_PVP"]          = "Show the player's selected title (achievement or PvP) in the name line."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_TITLE_COLOR"]                                      = "Title color"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_COLOR_OF_CHARACTER_TITLE_PLAYER_TOOLTIP"]          = "Color of the character title in the player tooltip name line."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_STATUS_BADGES"]                                       = "Status-Badges anzeigen"
L["OPTIONS_AXIS_INLINE_BADGES_COMBAT_AFK_DND_PVP"]                    = "Inline-Badges für Kampf, AFK, DND, PvP, Schlachtzug/Gruppe, Freunde und Zielanzeige anzeigen."
L["OPTIONS_AXIS_MOUNT_INFO"]                                          = "Reittierinfo anzeigen"
L["OPTIONS_AXIS_HOVERING_A_MOUNTED_PLAYER_THEIR_MOUNT"]               = "Bei Reittier-Spieler: Reittiername, Quelle und ob Sie es besitzen anzeigen."
-- L["OPTIONS_AXIS_BLANK_SEPARATOR"]                                  = "Blank separator"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_A_BLANK_LINE_INSTEAD_OF_DASHES"]                   = "Use a blank line instead of dashes between tooltip sections."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_ICONS"]                                            = "Show icons"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_CLASS_ICON_STYLE"]                                 = "Class icon style"  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_DEFAULT_BLIZZARD_RONDOMEDIA_CLASS_ICONS_TH"]          = "Use Default (Blizzard) or RondoMedia class icons on the class/spec line."
L["OPTIONS_AXIS_CUSTOM_CLASS_ICONS_LABEL"]                            = "Custom (addon media)"
L["OPTIONS_AXIS_CLASS_ICON_SOURCES_TOOLTIP"]                          = "RondoMedia: https://www.curseforge.com/wow/addons/rondomedia — Custom: place one .tga per class under media/CustomClassIcons/<CLASS>/<class lower>.tga (e.g. WARRIOR/warrior.tga), then /reload."
-- L["OPTIONS_AXIS_RONDOMEDIA_CLASS_ICONS_RONDOFERRARI_HTTPS_WWW"]    = "RondoMedia class icons by RondoFerrari — https://www.curseforge.com/wow/addons/rondomedia"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_DEFAULT"]                                          = "Default"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_FACTION_SPEC_MOUNT_MYTHIC_ICONS_TOOLTIPS"]         = "Show faction, spec, mount, and Mythic+ icons in tooltips."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_GENERAL"]                                             = "Allgemein"
-- L["OPTIONS_AXIS_POSITION"]                                         = "Position"  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_RESET_POSITION"]                                      = "Position zurücksetzen"
L["OPTIONS_AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"]                   = "Beute-Toast-Position auf Standard zurücksetzen."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["OPTIONS_FOCUS_LOCK_POSITION"]                                      = "Position sperren"
L["OPTIONS_FOCUS_PREVENT_DRAGGING_TRACKER"]                           = "Verhindert das Verschieben des Trackers"
L["OPTIONS_FOCUS_GROW_UPWARD"]                                        = "Nach oben erweitern"
L["OPTIONS_FOCUS_GROW_HEADER"]                                        = "Kopfzeile nach oben erweitern"
L["OPTIONS_FOCUS_GROWING_UPWARD_KEEP_HEADER_BOTTOM_TOP"]              = "Wenn nach oben erweitert: Behalte die Kopfzeile unten, oder oben bis sie ausgeblendet wird."
L["OPTIONS_FOCUS_HEADER_BOTTOM"]                                      = "Kopfzeile unten"
L["OPTIONS_FOCUS_HEADER_SLIDES_COLLAPSE"]                             = "Header gleitet beim Einklappen"
L["OPTIONS_FOCUS_ANCHOR_BOTTOM_LIST_GROWS_UPWARD"]                    = "Die Liste nach unten ausrichten, damit sie nach oben wächst"
L["OPTIONS_FOCUS_START_COLLAPSED"]                                    = "Eingeklappt starten"
L["OPTIONS_FOCUS_START_HEADER_SHOWN_UNTIL_YOU_EXPAND"]                = "Zeigt zu Beginn nur den Header an, bis du sie aufklappst"
L["OPTIONS_FOCUS_ALIGN_CONTENT_RIGHT"]                                = "Inhalt rechts ausrichten"
L["OPTIONS_FOCUS_RIGHT_ALIGN_QUEST_TITLES_OBJECTIVES_WITHIN"]         = "Richte die Questnamen und -ziele innerhalb des Fensters rechtsbündig aus"
L["OPTIONS_FOCUS_PANEL_WIDTH"]                                        = "Panelbreite"
L["OPTIONS_FOCUS_TRACKER_WIDTH_PIXELS"]                               = "Trackerbreite in Pixel"
L["OPTIONS_FOCUS_MAX_CONTENT_HEIGHT"]                                 = "Maximal Höhe des Inhalts"
L["OPTIONS_FOCUS_MAX_HEIGHT_OF_SCROLLABLE_LIST_PIXELS"]               = "Maximale Höhe der scrollbaren Liste in Pixel"

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["OPTIONS_FOCUS_ALWAYS_M_BLOCK"]                                     = "M+ Block immer anzeigen"
L["OPTIONS_FOCUS_M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]                = "Zeige des M+ Block, immer wenn ein aktiver Schlüsselstein läuft"
L["OPTIONS_FOCUS_DUNGEON"]                                            = "Zeige in Dungeons"
L["OPTIONS_FOCUS_TRACKER_PARTY_DUNGEONS"]                             = "Zeige Tracker in Gruppen-Dungeons"
L["OPTIONS_FOCUS_RAID"]                                               = "Zeige in Schlachtzug"
L["OPTIONS_FOCUS_TRACKER_RAIDS"]                                      = "Zeige den Tracker im Schlachtzug"
L["OPTIONS_FOCUS_BATTLEGROUND"]                                       = "Auf Schlachtfeldern anzeigen"
L["OPTIONS_FOCUS_TRACKER_BATTLEGROUNDS"]                              = "Zeigt den Tracker auf Schlachtfeldern"
L["OPTIONS_FOCUS_ARENA"]                                              = "In Arena anzeigen"
L["OPTIONS_FOCUS_TRACKER_ARENAS"]                                     = "Zeigt den Tracker in Arenen an"
L["OPTIONS_FOCUS_HIDE_COMBAT"]                                        = "Im Kampf verstecken"
L["OPTIONS_FOCUS_HIDE_TRACKER_FLOATING_QUEST_ITEM_COMBAT"]            = "Verstecke Tracker und schwebendes Questitem im Kampf"
L["OPTIONS_FOCUS_COMBAT_VISIBILITY"]                                  = "Kampf Sichtbarkeit"
L["OPTIONS_FOCUS_TRACKER_BEHAVES_COMBAT_FADE_REDUC"]                  = "Wie sich der Tracker im Kampf verhält: anzeigen, verblassen, oder ausblenden"
L["OPTIONS_FOCUS_SHOW"]                                               = "Anzeigen"
L["OPTIONS_FOCUS_FADE"]                                               = "Verblassen"
L["OPTIONS_FOCUS_HIDE"]                                               = "Ausblenden"
L["OPTIONS_FOCUS_COMBAT_FADE_OPACITY"]                                = "Sichtbarkeit im Kampf"
L["OPTIONS_FOCUS_VISIBLE_TRACKER_FADED_COMBAT"]                       = "Wie sichtbar der Tracker ist, wenn er im Kampf verblasst (0 = unsichtbar). Gilt nur, wenn die Sichtbarkeit im Kampf auf „Ausblenden“ eingestellt ist."
L["OPTIONS_FOCUS_MOUSEOVER"]                                          = "Mausüber"
L["OPTIONS_FOCUS_SHOW_ONLY_MOUSEOVER"]                                = "Zeige nur bei mouseover"
L["OPTIONS_FOCUS_FADE_TRACKER_HOVERING_MOVE_MOUSE"]                   = "Tracker verblasst wenn der Mauszeiger nicht darüber schwebt"
L["OPTIONS_FOCUS_FADED_OPACITY"]                                      = "Sichtbarkeit wenn verblasst"
L["OPTIONS_FOCUS_VISIBLE_TRACKER_FADED_INVISIBLE"]                    = "Sichtbarkeit des Trackers wenn er verblasst ist (0 = unsichtbar)"
L["OPTIONS_FOCUS_QUESTS_CURRENT_ZONE"]                                = "Zeige Quests nur aus der aktuellen Zone"
L["OPTIONS_FOCUS_HIDE_QUESTS_OUTSIDE_YOUR_CURRENT_ZONE"]              = "Verstecke Quests außerhalb deiner aktuellen Zone"

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["OPTIONS_FOCUS_QUEST_COUNT"]                                        = "Anzahl der Quests anzeigen"
L["OPTIONS_FOCUS_QUEST_COUNT_HEADER"]                                 = "Zeige die Anzahl der Quests in der Kopfzeile an"
L["OPTIONS_FOCUS_HEADER_COUNT_FORMAT"]                                = "Format des Zählers"
L["OPTIONS_FOCUS_TRACKED_LOG_LOG_MAX_SLOTS_TRACKED"]                  = "Verfolgt/im-Log oder im-Log/max-Plätze. Verfolgt schließt Welt-/Zonen-Quests aus."
L["OPTIONS_FOCUS_HEADER_DIVIDER"]                                     = "Zeige Kopfzeilen-Trennlinie"
L["OPTIONS_FOCUS_LINE_BELOW_HEADER"]                                  = "Zeige die Linie unterhalb der Kopfzeile"
L["OPTIONS_FOCUS_HEADER_DIVIDER_COLOR"]                               = "Farbe der Kopfzeilen-Trennlinie"
L["OPTIONS_FOCUS_COLOR_OF_LINE_BELOW_HEADER"]                         = "Farbe der Linie unter der Kopfzeile."
L["OPTIONS_FOCUS_SUPER_MINIMAL_MODE"]                                 = "Super-Minimal Modus"
L["OPTIONS_FOCUS_HIDE_HEADER_A_PURE_TEXT_LIST"]                       = "Kopfzeile ausblenden, um eine reine Textliste anzuzeigen"
L["OPTIONS_FOCUS_OPTIONS_BUTTON"]                                     = "Zeige Button für Optionen"
L["OPTIONS_FOCUS_OPTIONS_BUTTON_TRACKER_HEADER"]                      = "Zeigt den Options-Button in der Kopfzeile des Trackers"
L["OPTIONS_FOCUS_HEADER_COLOR"]                                       = "Kopfzeilenfarbe"
L["OPTIONS_FOCUS_COLOR_OF_OBJECTIVES_HEADER_TEXT"]                    = "Farbe der ZIEL-Text Kopfzeile"
L["OPTIONS_FOCUS_HEADER_HEIGHT"]                                      = "Kopfzeilenhöhe"
L["OPTIONS_FOCUS_HEIGHT_OF_HEADER_BAR_PIXELS"]                        = "Höhe der Kopfzeilenleiste in Pixel (18–48)"

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["OPTIONS_FOCUS_SECTION_HEADERS"]                                    = "Abschnittsüberschriften anzeigen"
L["OPTIONS_FOCUS_CATEGORY_LABELS_ABOVE_GROUP"]                        = "Kategoriebezeichnungen über jeder Gruppe anzeigen."
L["OPTIONS_FOCUS_CATEGORY_HEADERS_COLLAPSED"]                         = "Kategorieüberschriften anzeigen, wenn ausgeblendet"
L["OPTIONS_FOCUS_KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED_CLICK"]       = "Die Überschriften der Abschnitte bleiben sichtbar wenn eingeklappt ; klicke darauf, um eine Kategorie zu erweitern"
L["OPTIONS_FOCUS_NEARBY_CURRENT_ZONE_GROUP"]                          = "Zeige In der Nähe (aktuelle Zone) Gruppe"
L["OPTIONS_FOCUS_ZONE_QUESTS_A_DEDICATED_CURRENT_ZONE"]               = "Zeige Quests in der aktuellen Zone in einem eigenen Bereich an. Wenn deaktiviert, werden sie in ihrer normalen Kategorie angezeigt."
L["OPTIONS_FOCUS_ZONE_LABELS"]                                        = "Zeige Zonen-Bezeichnung"
L["OPTIONS_FOCUS_ZONE_NAME_UNDER_QUEST_TITLE"]                        = "Zeige den Namen der Zone unter jedem Questtitel an."
L["OPTIONS_FOCUS_ACTIVE_QUEST_HIGHLIGHT"]                             = "Aktive Quest hervorheben"
L["OPTIONS_FOCUS_FOCUSED_QUEST_HIGHLIGHTED"]                          = "Wie die aktuelle Quest hervorgehoben wird"
L["OPTIONS_FOCUS_QUEST_ITEM_BUTTONS"]                                 = "Questitem-Buttons anzeigen"
L["OPTIONS_FOCUS_USABLE_QUEST_ITEM_BUTTON_NEXT_QUEST"]                = "Zeige neben jeder Quest den Button für den nutzbaren Questgegenstand an"
L["OPTIONS_FOCUS_TOOLTIPS_HOVER"]                                     = "Tooltips bei Mouseover"
L["OPTIONS_FOCUS_TOOLTIPS_HOVERING_TRACKER_ENTRIES_ITE"]              = "Tooltips anzeigen, wenn der Mauszeiger über Tracker-Einträge, Item-Buttons und Szenario-Blöcken bewegt wird"
L["OPTIONS_FOCUS_WOWHEAD_LINK_TOOLTIPS"]                              = "Wowhead Links in Tooltips anzeigen"
L["OPTIONS_FOCUS_A_TOOLTIP_SHOWN_ADD_A_LINK"]                         = "Wenn ein Tooltip angezeigt wird, füge einen Link hinzu, über den die Quest, der Erfolg oder der NPC auf WoWhead geöffnet werden kann."
L["OPTIONS_FOCUS_VIEW_WOWHEAD"]                                       = "Auf Wowhead anzeigen"
L["OPTIONS_FOCUS_WOWHEAD_ALT_CLICK_HINT"]                             = "Alt+click row to copy"
L["OPTIONS_FOCUS_COPY_LINK"]                                          = "Link kopieren"
L["OPTIONS_FOCUS_COPY_URL_BELOW_CTRL_C_PASTE"]                        = "Kopiere die folgende URL (STRG+C) und füge sie in deinem Browser ein."
L["OPTIONS_FOCUS_OBJECTIVE_NUMBERS"]                                  = "Zahlen für Ziele anzeigen"
L["OPTIONS_FOCUS_OBJECTIVE_PREFIX"]                                   = "Zielprefix"
-- L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLORS"]                = "Color objective progress numbers"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLORS_DESC"]              = "Tint X/Y counts: normal color at 0/n, gold while in progress, green when complete. The slash uses the usual objective color."
L["OPTIONS_FOCUS_PREFIX_OBJECTIVE_A_NUMBER_HYPHEN"]                   = "Jedem Ziel eine Zahl oder einen Bindestrich voranstellen."
L["OPTIONS_FOCUS_NUMBERS"]                                            = "Nummerierung (1. 2. 3.)"
L["OPTIONS_FOCUS_HYPHENS"]                                            = "Bindestriche (-)"
L["OPTIONS_FOCUS_AFTER_SECTION_HEADER"]                               = "Nach der Abschnittsüberschrift"
L["OPTIONS_FOCUS_BEFORE_SECTION_HEADER"]                              = "Vor der Abschnittsüberschrift"
L["OPTIONS_FOCUS_BELOW_HEADER"]                                       = "Unterhalb der Kopfzeile"
L["OPTIONS_FOCUS_INLINE_BELOW_TITLE"]                                 = "Inline unterhalb des Titels"
L["OPTIONS_FOCUS_PREFIX_OBJECTIVES"]                                  = "Stelle den Zielen die Nummern 1., 2., 3. voran"
L["OPTIONS_FOCUS_COMPLETED_COUNT"]                                    = "Anzahl der abgeschlossenen Aufgaben anzeigen"
L["OPTIONS_FOCUS_X_Y_PROGRESS_QUEST_TITLE"]                           = "Fortschritt (X/Y) im Questitel anzeigen."
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_BAR"]                             = "Ziel-Fortschrittsbalken anzeigen"
L["OPTIONS_FOCUS_A_PROGRESS_BAR_UNDER_OBJECTIVES_NUMER"]              = "Zeige einen Fortschrittsbalken unter Zielen an, die einen numerischen Fortschritt aufweisen (z. B. 3/250). Dies gilt nur für Einträge mit einem einzelnen rechnerischen Ziel, bei denen der erforderliche Wert größer als 1 ist."
L["OPTIONS_FOCUS_CATEGORY_COLOR_PROGRESS_BAR"]                        = "Farbe der Kategorie für den Fortschrittsbalken verwenden"
L["OPTIONS_FOCUS_PROGRESS_BAR_MATCHES_QUEST_ACHIEVEME"]               = "Wenn aktiviert, passt sich der Fortschrittsbalken an die Farbe der Quest-/Erfolgskategorie an. Wenn deaktiviert, wird die unten angegebene benutzerdefinierte Füllfarbe verwendet."
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXTURE"]                               = "Textur für den Fortschrittsbalken"
L["OPTIONS_FOCUS_PROGRESS_BAR_TYPES"]                                 = "Arten von Fortschrittsbalken"
L["OPTIONS_FOCUS_TEXTURE_PROGRESS_BAR_FILL"]                          = "Textur für die Füllung des Fortschrittsbalkens"
L["OPTIONS_FOCUS_TEXTURE_PROGRESS_BAR_FILL_SOLID_YOUR"]               = "Textur für die Füllung des Fortschrittsbalkens. Bei „Solid“ werden die von dir gewählten Farben verwendet. Add-ons wie SharedMedia bieten weitere Optionen."
L["OPTIONS_FOCUS_PROGRESS_BAR_X_Y_OBJECTIVES_PERCENT"]                = "Zeige einen Fortschrittsbalken für X/Y-Ziele, reine Prozentziele oder beides an"
L["OPTIONS_FOCUS_X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]             = "X/Y: Ziele wie 3/10. Prozent: Ziele wie 45 %"
L["OPTIONS_FOCUS_X_Y"]                                                = "nur X/Y"
L["OPTIONS_FOCUS_PERCENT"]                                            = "nur Prozent"
L["OPTIONS_FOCUS_TICK_COMPLETED_OBJECTIVES"]                          = "Häkchen für abgeschlossene Ziele anzeigen"
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES_A_CHECKMARK_INSTEA"]            = "Wenn die Funktion aktiviert ist, werden abgeschlossene Ziele mit einem Häkchen (✓) statt in grüner Farbe angezeigt."
L["OPTIONS_FOCUS_ENTRY_NUMBERS"]                                      = "Nummerierung anzeigen"
L["OPTIONS_FOCUS_PREFIX_QUEST_TITLES_WITHIN_CATEGORY"]                = "Füge den Questtiteln innerhalb jeder Kategorie die Nummern 1., 2., 3. voran"
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES"]                               = "Abgeschlossene Ziele"
L["OPTIONS_FOCUS_MULTI_OBJECTIVE_QUESTS_DISPLAY_OBJECTIVES"]          = "Wie bei Quests mit mehreren Zielen die bereits erfüllten Ziele angezeigt werden (z. B. 1/1)"
L["OPTIONS_FOCUS_ALL"]                                                = "Alle anzeigen"
L["OPTIONS_FOCUS_FADE_COMPLETED"]                                     = "Vollständig ausblenden"
L["OPTIONS_FOCUS_HIDE_COMPLETED"]                                     = "vollständig verstecken"
L["OPTIONS_FOCUS_ICON_ZONE_AUTO_TRACKING"]                            = "Symbol für automatische Verfolgung innerhalb der derzeitigen Zone anzeigen"
L["OPTIONS_FOCUS_DISPLAY_AN_ICON_NEXT_AUTO_TRACKED"]                  = "Zeige ein Symbol neben automatisch verfolgten Weltquests und wöchentlichen/täglichen Quests an, die noch nicht in deinem Questlog stehen (nur innerhalb der Zone)."
L["OPTIONS_FOCUS_AUTO_TRACK_ICON"]                                    = "Symbol für automatische Verfolgung"
L["OPTIONS_FOCUS_CHOOSE_WHICH_ICON_DISPLAY_NEXT_AUTO"]                = "Wähle aus, welches Symbol neben automatisch erfassten Einträgen innerhalb der derzeitigen Zone angezeigt werden soll."
L["OPTIONS_FOCUS_APPEND_WORLD_QUESTS_WEEKLIES_DAILIES"]               = "Füge ** zu Weltquests und wöchentlichen/täglichen Quests hinzu, die noch nicht in deinem Questlog stehen (nur in derzeitiger Zone)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["OPTIONS_FOCUS_COMPACT_MODE"]                                       = "Kompaktmodus"
L["OPTIONS_FOCUS_PRESET_SETS_ENTRY_OBJECTIVE_SPACING_P"]              = "Voreinstellung: Eintrags- und Zielabstand auf 4 und 1 px."
L["OPTIONS_FOCUS_SPACING_PRESET"]                                     = "Abstands-Voreinstellung"
L["OPTIONS_FOCUS_PRESET_ENTRY_OBJECTIVE_SPACING_DEFAULT_P"]           = "Voreinstellung: Standard (8/2 px), Kompakt (4/1 px), Abstand (12/3 px) oder Benutzerdefiniert (Slider)."
L["OPTIONS_FOCUS_COMPACT_VERSION"]                                    = "Kompaktversion"
L["OPTIONS_FOCUS_SPACED_VERSION"]                                     = "Abstandsversion"
L["OPTIONS_FOCUS_SPACING_BETWEEN_QUEST_ENTRIES_PX"]                   = "Abstand zwischen Quest-Einträgen (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_QUEST_ENTRIES"]                 = "Vertikaler Abstand zwischen Quest-Einträgen."
L["OPTIONS_FOCUS_SPACING_BEFORE_CATEGORY_HEADER_PX"]                  = "Abstand vor Kategorie-Header (px)"
L["OPTIONS_FOCUS_GAP_BETWEEN_LAST_ENTRY_OF_A"]                        = "Abstand zwischen letztem Eintrag einer Gruppe und dem nächsten Kategorie-Label."
L["OPTIONS_FOCUS_SPACING_AFTER_CATEGORY_HEADER_PX"]                   = "Abstand nach Kategorie-Header (px)"
L["OPTIONS_FOCUS_GAP_BETWEEN_CATEGORY_LABEL_FIRST_QUEST"]             = "Abstand zwischen Kategorie-Label und erstem Quest-Eintrag darunter."
L["OPTIONS_FOCUS_SPACING_BETWEEN_OBJECTIVES_PX"]                      = "Abstand zwischen Zielen (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVE_LINES_WITHIN"]        = "Vertikaler Abstand zwischen Zielzeilen innerhalb einer Quest."
L["OPTIONS_FOCUS_TITLE_CONTENT"]                                      = "Titel zu Inhalt"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_QUEST_TITLE_OBJECTIVES"]        = "Vertikaler Abstand zwischen Quest-Titel und Zielen oder Zone darunter."
L["OPTIONS_FOCUS_SPACING_BELOW_HEADER_PX"]                            = "Abstand unter Kopfzeile (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVES_BAR_QUES"]           = "Vertikaler Abstand zwischen Ziele-Leiste und Questliste."
L["OPTIONS_FOCUS_RESET_SPACING"]                                      = "Abstände zurücksetzen"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_QUEST_LEVEL"]                                   = "Quest-Stufe anzeigen"
L["OPTIONS_FOCUS_QUEST_LEVEL_NEXT_TITLE"]                             = "Quest-Stufe neben Titel anzeigen."
L["OPTIONS_FOCUS_DIM_FOCUSED_QUESTS"]                                 = "Nicht fokussierte Quests abdunkeln"
L["OPTIONS_FOCUS_SLIGHTLY_DIM_TITLE_ZONE_OBJECTIVES_SECTION"]         = "Nicht fokussierte Titel, Zonen, Ziele und Abschnitts-Header leicht abdunkeln."
L["OPTIONS_FOCUS_DIM_UNFOCUSED_ENTRIES"]                              = "Nicht fokussierte Einträge abdunkeln"
L["OPTIONS_FOCUS_CLICK_A_SECTION_HEADER_EXPAND_CATEGORY"]             = "Abschnittsüberschrift klicken, um Kategorie zu erweitern."

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["UI_SHOW_RARE_BOSSES"]                                              = "Seltene Bosse anzeigen"
L["UI_RARE_BOSS_VIGNETTES_LIST"]                                      = "Seltene-Boss-Vignetten in der Liste anzeigen."
L["UI_RARE_LOOT"]                                                     = "Seltene Beute"
L["UI_TREASURE_ITEM_VIGNETTES_RARE_LOOT"]                             = "Zeigt Schätze und Gegenstände in der Liste seltener Beute."
L["UI_RARE_SOUND_VOLUME"]                                             = "Lautstärke seltener Beute"
L["UI_VOLUME_OF_RARE_ALERT_SOUND"]                                    = "Lautstärke des Alarmsounds für seltene Beute (50–200%)."
L["UI_BOOST_REDUCE_RARE_ALERT_VOLUME"]                                = "Lautstärke anpassen. 100 % = normal; 150 % = lauter."
L["UI_RARE_ADDED_SOUND"]                                              = "Sound bei seltenem Boss"
L["UI_PLAY_A_SOUND_A_RARE"]                                           = "Sound abspielen wenn ein seltener Boss hinzugefügt wird."
-- L["UI_MINIMAP_PATCH_NOTES_UNREAD_HINT"]                            = "New patch notes — open Axis and choose Patch Notes."  -- NEEDS TRANSLATION

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["OPTIONS_FOCUS_ZONE_WORLD_QUESTS"]                                  = "Welt-Quests in Zone anzeigen"
L["OPTIONS_FOCUS_AUTO_ADD_WORLD_QUESTS_YOUR_CURRENT"]                 = "Welt-Quests in Zone automatisch hinzufügen. Aus: nur getrackte Quests oder nahe Weltquests (Blizzard-Standard)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_FLOATING_QUEST_ITEM"]                           = "Schwebendes Quest-Item anzeigen"
L["OPTIONS_FOCUS_QUICK_BUTTON_FOCUSED_QUEST_S_USABLE"]                = "Schnell-Button für nutzbares Item der fokussierten Quest anzeigen."
L["OPTIONS_FOCUS_LOCK_FLOATING_QUEST_ITEM_POSITION"]                  = "Schwebendes Quest-Item sperren"
L["OPTIONS_FOCUS_PREVENT_DRAGGING_FLOATING_QUEST_ITEM_BUTTON"]        = "Schwebendes Quest-Item nicht verschiebbar."
L["OPTIONS_FOCUS_FLOATING_QUEST_ITEM_SOURCE"]                         = "Quelle für schwebendes Quest-Item"
L["OPTIONS_FOCUS_WHICH_QUEST_S_ITEM_SUPER_TRACKED"]                   = "Welches Quest-Item anzeigen: super-verfolgt zuerst oder aktuelle Zone zuerst."
L["OPTIONS_FOCUS_SUPER_TRACKED_FIRST"]                                = "Super-verfolgt, dann zuerst"
L["OPTIONS_FOCUS_CURRENT_ZONE_FIRST"]                                 = "Aktuelle Zone zuerst"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["OPTIONS_FOCUS_MYTHIC_BLOCK"]                                       = "Mythisch+-Block anzeigen"
L["OPTIONS_FOCUS_TIMER_COMPLETION_AFFIXES_MYTHIC_DUNGEONS"]           = "Timer, Abschluss-% und Affixe in Mythisch+-Dungeons anzeigen."
L["OPTIONS_FOCUS_M_BLOCK_POSITION"]                                   = "M+-Block-Position"
L["OPTIONS_FOCUS_POSITION_OF_MYTHIC_BLOCK_RELATIVE_QUEST"]            = "Position des M+-Blocks relativ zur Questliste."
L["OPTIONS_FOCUS_AFFIX_ICONS"]                                        = "Affix-Symbole anzeigen"
L["OPTIONS_FOCUS_AFFIX_ICONS_NEXT_MODIFIER_NAMES_M"]                  = "Affix-Symbole neben Modifikator-Namen im M+-Block anzeigen."
L["OPTIONS_FOCUS_AFFIX_DESCRIPTIONS_TOOLTIP"]                         = "Affix-Beschreibungen im Tooltip anzeigen"
L["OPTIONS_FOCUS_AFFIX_DESCRIPTIONS_HOVERING_M_BLO"]                  = "Affix-Beschreibungen bei Mausüber M+-Block anzeigen."
L["OPTIONS_FOCUS_M_COMPLETED_BOSS_DISPLAY"]                           = "M+ besiegte Boss-Anzeige"
L["OPTIONS_FOCUS_DEFEATED_BOSSES_CHECKMARK_ICON_GREEN"]               = "Besiegte Bosse: Häkchen-Symbol oder grüne Farbe."
L["OPTIONS_FOCUS_CHECKMARK"]                                          = "Häkchen"
L["OPTIONS_FOCUS_GREEN_COLOR"]                                        = "Grün-Farbe"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["OPTIONS_PRESENCE_ACHIEVEMENTS"]                                    = "Erfolge anzeigen"
L["OPTIONS_FOCUS_TRACKED_ACHIEVEMENTS_LIST"]                          = "Verfolgte Erfolge in der Liste anzeigen."
L["OPTIONS_FOCUS_COMPLETED_ACHIEVEMENTS"]                             = "Errungene Erfolge anzeigen"
L["OPTIONS_FOCUS_INCLUDE_COMPLETED_ACHIEVEMENTS_TRACKER_O"]           = "Errungene Erfolge im Zielverfolger anzeigen. Aus: nur verfolgte in Bearbeitung."
L["OPTIONS_FOCUS_ACHIEVEMENT_ICONS"]                                  = "Erfolgssymbole anzeigen"
L["OPTIONS_FOCUS_ACHIEVEMENT_S_ICON_NEXT_TITLE_REQUI"]                = "Erfolgssymbol neben Titel anzeigen. Erfordert „Quest-Typ-Symbole anzeigen\" in Anzeige."
L["OPTIONS_FOCUS_MISSING_REQUIREMENTS"]                               = "Nur fehlende Kriterien anzeigen"
L["OPTIONS_FOCUS_CRITERIA_YOU_HAVEN_T_COMPLETED_TR"]                  = "Nur nicht abgeschlossene Kriterien pro verfolgtem Erfolg. Aus: alle Kriterien."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_ENDEAVORS"]                                     = "Bestrebungen anzeigen"
L["OPTIONS_FOCUS_TRACKED_ENDEAVORS_PLAYER_HOUSING_LIST"]              = "Verfolgte Bestrebungen (Spielerbehausung) in der Liste anzeigen."
L["OPTIONS_FOCUS_COMPLETED_ENDEAVORS"]                                = "Abgeschlossene Bestrebungen anzeigen"
L["OPTIONS_FOCUS_INCLUDE_COMPLETED_ENDEAVORS_TRACKER"]                = "Abgeschlossene Bestrebungen im Zielverfolger anzeigen. Aus: nur verfolgte in Bearbeitung."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_DECOR"]                                         = "Dekoration anzeigen"
L["OPTIONS_FOCUS_TRACKED_HOUSING_DECOR_LIST"]                         = "Verfolgte Behausungsdekoration in der Liste anzeigen."
L["OPTIONS_FOCUS_DECOR_ICONS"]                                        = "Dekorationssymbole anzeigen"
L["OPTIONS_FOCUS_DECOR_ITEM_S_ICON_NEXT_TITLE"]                       = "Dekorationssymbol neben Titel anzeigen. Erfordert „Quest-Typ-Symbole anzeigen\" in Anzeige."

-- =====================================================================
-- OptionsData.lua Features — Appearances
-- =====================================================================
-- L["OPTIONS_FOCUS_SHOW_APPEARANCES"]                                = "Show appearances"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_TRACKED_TRANSMOG_APPEARANCES_LIST"]               = "Show tracked transmog appearances in the list."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_INCLUDE_COLLECTED_APPEARANCES_TRACKER"]           = "Include collected appearances in the tracker. When off, only appearances you have not yet collected are shown."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_APPEARANCE_ICONS"]                                = "Show appearance icons"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_APPEARANCE_ICON_NEXT_TITLE"]                      = "Show each appearance's icon next to the title. Requires 'Show quest type icons' in Display."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON"]               = "Use transmog list icon"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON_DESC"]          = "Use the in-game Appearances / transmog list icon for every row instead of each appearance's item icon. If that icon cannot be resolved, the item icon is used."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_SHOW_APPEARANCE_WARDROBE"]                        = "Show wardrobe"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_OPEN_APPEARANCES_COLLECTIONS"]                    = "Open Collections"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_UNTRACK_APPEARANCE"]                              = "Untrack appearance"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_APPEARANCE_HORIZON_CONTROLS_HINT"]                = "Horizon: Shift-click map; with TomTom waypoints enabled, that click also sets the arrow. Ctrl-click Collections, Alt-click dressing room. Right-click clears focus or untracks."  -- NEEDS TRANSLATION

-- =====================================================================
-- OptionsData.lua Features — Adventure Guide
-- =====================================================================
L["OPTIONS_FOCUS_ADVENTURE_GUIDE"]                                    = "Abenteuerführer"
L["OPTIONS_FOCUS_TRAVELER_S_LOG"]                                     = "Reisetagebuch anzeigen"
L["OPTIONS_FOCUS_TRACKED_TRAVELER_S_LOG_OBJECTIVES_SHIFT"]            = "Verfolgte Reisetagebuchziele (Umschalt+Klick im Abenteuerführer) in der Liste anzeigen."
L["OPTIONS_FOCUS_AUTO_REMOVE_COMPLETED_ACTIVITIES"]                   = "Abgeschlossene Aktivitäten automatisch entfernen"
L["OPTIONS_FOCUS_AUTOMATICALLY_STOP_TRACKING_TRAVELER_S_LOG"]         = "Reisetagebuchaktivitäten nach Abschluss automatisch nicht mehr verfolgen."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["OPTIONS_FOCUS_SCENARIO_EVENTS"]                                    = "Szenarioereignisse anzeigen"
L["OPTIONS_FOCUS_ACTIVE_SCENARIO_DELVE_ACTIVITIES_DELVES_APP"]        = "Aktive Szenario- und Tiefen-Aktivitäten anzeigen. Tiefen in Tiefen; andere in Szenario-Ereignisse."
L["OPTIONS_FOCUS_TRACK_DELVE_DUNGEON_SCENARIO_ACTIVITIES"]            = "Tiefen-, Dungeon- und Szenario-Aktivitäten verfolgen."
L["OPTIONS_FOCUS_DELVES_APPEAR_DELVES_SECTION_DUNGEONS_DUNGEON"]      = "Tiefen in Tiefen; Dungeons in Dungeon; andere Szenarien in Szenario-Ereignisse."
L["OPTIONS_FOCUS_DELVES_APPEAR_DELVES_SECTION_SCENARIOS_S"]           = "Tiefen in Tiefen; andere Szenarien in Szenario-Ereignisse."
L["OPTIONS_FOCUS_DELVE_AFFIX_NAMES"]                                  = "Tiefen-Affix-Namen"
L["OPTIONS_FOCUS_DELVE_DUNGEON"]                                      = "Nur Tiefe/Verlies"
L["OPTIONS_FOCUS_SCENARIO_DEBUG_LOGGING"]                             = "Szenario-Debug-Protokoll"
L["OPTIONS_FOCUS_LOG_SCENARIO_API_DATA_CHAT_H"]                       = "Szenario-API-Daten im Chat protokollieren. /h debug focus scendebug zum Umschalten."
L["OPTIONS_FOCUS_PRINTS_C_SCENARIOINFO_CRITERIA_WIDGET_DATA"]         = "Gibt C_ScenarioInfo-Kriterien und Widget-Daten aus. Hilft bei Anzeigeproblemen wie Abundance 46/300."
L["OPTIONS_FOCUS_HIDE_CATEGORIES_DELVE_DUNGEON"]                      = "Andere Kategorien in Tiefe oder Dungeon verbergen"
L["OPTIONS_FOCUS_DELVES_PARTY_DUNGEONS_DELVE_DUNG"]                   = "In Tiefen oder Gruppen-Dungeons nur Tiefe/Dungeon-Abschnitt anzeigen."
L["OPTIONS_FOCUS_DELVE_NAME_SECTION_HEADER"]                          = "Tiefen-Namen als Abschnitts-Header verwenden"
L["OPTIONS_FOCUS_A_DELVE_DELVE_NAME_TIER_AFFIXES"]                    = "In Tiefe: Tiefenname, Stufe und Affixe als Abschnitts-Header statt separatem Banner. Aus: Tiefen-Block über Liste."
L["OPTIONS_FOCUS_AFFIX_NAMES_DELVES"]                                 = "Affix-Namen in Tiefen anzeigen"
L["OPTIONS_FOCUS_SEASON_AFFIX_NAMES_FIRST_DELVE_ENTRY"]               = "Saison-Affix-Namen beim ersten Tiefen-Eintrag anzeigen. Erfordert Blizzard-Widgets; evtl. nicht bei Tracker-Ersatz."
L["OPTIONS_FOCUS_CINEMATIC_SCENARIO_BAR"]                             = "Filmische Szenario-Leiste"
L["OPTIONS_FOCUS_TIMER_PROGRESS_BAR_SCENARIO_ENTRIES"]                = "Timer und Fortschrittsbalken für Szenario-Einträge anzeigen."
L["OPTIONS_FOCUS_TIMER"]                                              = "Timer anzeigen"
L["OPTIONS_FOCUS_COUNTDOWN_TIMER_TIMED_QUESTS_EVENTS_SCEN"]           = "Countdown-Timer bei zeitgesteuerten Quests, Events und Szenarien. Aus: Timer für alle ausgeblendet."
L["OPTIONS_FOCUS_TIMER_SCENARIOS"]                                    = "Timers: scenarios & delves"
L["OPTIONS_FOCUS_TIMER_SCENARIOS_DESC"]                               = "Countdown timer for scenario, delve, and dungeon tracker entries."
L["OPTIONS_FOCUS_TIMER_WORLD"]                                        = "Timers: world & callings"
L["OPTIONS_FOCUS_TIMER_WORLD_DESC"]                                   = "Countdown timer for world quests and callings."
L["OPTIONS_FOCUS_TIMER_QUEST_LOG"]                                    = "Timers: quest log (timed)"
L["OPTIONS_FOCUS_TIMER_QUEST_LOG_DESC"]                               = "Countdown timer for dailies, weeklies, and other quest log entries with a time limit."
L["OPTIONS_FOCUS_TIMER_DISPLAY"]                                      = "Timer-Anzeige"
L["OPTIONS_FOCUS_COLOR_TIMER_REMAINING"]                              = "Timer nach verbleibender Zeit einfärben"
L["OPTIONS_FOCUS_GREEN_PLENTY_OF_LEFT_YELLOW_RUNNING"]                = "Grün bei viel Zeit, gelb bei wenig, rot bei kritisch."
L["OPTIONS_FOCUS_WHERE_COUNTDOWN_BAR_BELOW_OBJECTIVES"]               = "Countdown-Position: Leiste unter Zielen oder Text neben dem Questnamen."
L["OPTIONS_FOCUS_BAR_BELOW"]                                          = "Leiste unten"
L["OPTIONS_FOCUS_INLINE_BESIDE_TITLE"]                                = "Inline neben Titel"

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["OPTIONS_FOCUS_FONT_FAMILY"]                                        = "Schriftart"
L["OPTIONS_FOCUS_TITLE_FONT"]                                         = "Titelschriftart"
L["OPTIONS_VISTA_ZONE_FONT"]                                          = "Zonenschriftart"
L["OPTIONS_FOCUS_OBJECTIVE_FONT"]                                     = "Zielschriftart"
L["OPTIONS_FOCUS_SECTION_FONT"]                                       = "Abschnittsschriftart"
L["OPTIONS_FOCUS_GLOBAL_FONT"]                                        = "Globale Schriftart verwenden"
L["OPTIONS_FOCUS_FONT_FAMILY_QUEST_TITLES"]                           = "Schriftart für Quest-Titel"
L["OPTIONS_FOCUS_FONT_FAMILY_ZONE_LABELS"]                            = "Schriftart für Zonenbezeichnungen"
L["OPTIONS_FOCUS_FONT_FAMILY_OBJECTIVE_TEXT"]                         = "Schriftart für Zieltext"
L["OPTIONS_FOCUS_FONT_FAMILY_SECTION_HEADERS"]                        = "Schriftart für Abschnittsüberschriften"
L["OPTIONS_FOCUS_HEADER_SIZE"]                                        = "Kopfzeilengröße"
L["OPTIONS_FOCUS_HEADER_FONT_SIZE"]                                   = "Größe der Kopfzeilenschriftart"
L["OPTIONS_FOCUS_TITLE_SIZE"]                                         = "Titelgröße"
L["OPTIONS_FOCUS_QUEST_TITLE_FONT_SIZE"]                              = "Größe der Quest-Titelschriftart"
L["OPTIONS_FOCUS_OBJECTIVE_SIZE"]                                     = "Zielgröße"
L["OPTIONS_FOCUS_OBJECTIVE_TEXT_FONT_SIZE"]                           = "Größe der Zielschriftart"
L["OPTIONS_FOCUS_ZONE_SIZE"]                                          = "Zonengröße"
L["OPTIONS_FOCUS_ZONE_LABEL_FONT_SIZE"]                               = "Größe der Zonenbezeichnungsschriftart"
L["OPTIONS_FOCUS_SECTION_SIZE"]                                       = "Abschnittsgröße"
L["OPTIONS_FOCUS_SECTION_HEADER_FONT_SIZE"]                           = "Größe der Schriftart für Abschnitte"
L["OPTIONS_FOCUS_PROGRESS_BAR_FONT"]                                  = "Fortschrittsbalkenschriftart"
L["OPTIONS_FOCUS_FONT_FAMILY_PROGRESS_BAR_LABEL"]                     = "Schriftart für die Fortschrittsbalkensbeschriftung"
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXT_SIZE"]                             = "Fortschrittsbalkentextgröße"
L["OPTIONS_FOCUS_FONT_SIZE_PROGRESS_BAR_LABEL_ADJUSTS"]               = "Schriftgröße für die Beschriftung des Fortschrittsbalkens. Ändert auch die Höhe des Balkens. Betrifft Questziele, den Szenariofortschritt und die Szenario-Zeit-Balken."
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL"]                                  = "Füllung des Fortschrittsbalkens"
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXT"]                                  = "Text des Fortschrittsbalkens"
L["OPTIONS_FOCUS_OUTLINE"]                                            = "Kontur"
L["OPTIONS_FOCUS_FONT_OUTLINE_STYLE"]                                 = "Schriftkonturstil"

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["OPTIONS_FOCUS_HEADER_TEXT_CASE"]                                   = "Kopfzeilen-Groß-/Kleinschreibung"
L["OPTIONS_FOCUS_DISPLAY_CASE_HEADER"]                                = "Groß-/Kleinschreibung für Kopfzeile."
L["OPTIONS_FOCUS_SECTION_HEADER_CASE"]                                = "Abschnitts-Header Groß-/Kleinschreibung"
L["OPTIONS_FOCUS_DISPLAY_CASE_CATEGORY_LABELS"]                       = "Groß-/Kleinschreibung für Kategorie-Labels."
L["OPTIONS_FOCUS_QUEST_TITLE_CASE"]                                   = "Quest-Titel Groß-/Kleinschreibung"
L["OPTIONS_FOCUS_DISPLAY_CASE_QUEST_TITLES"]                          = "Groß-/Kleinschreibung für Quest-Titel."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["OPTIONS_FOCUS_TEXT_SHADOW"]                                        = "Textschatten anzeigen"
L["OPTIONS_FOCUS_ENABLE_DROP_SHADOW_TEXT"]                            = "Schattierung für Text aktivieren."
L["OPTIONS_FOCUS_SHADOW_X"]                                           = "Schatten X"
L["OPTIONS_FOCUS_HORIZONTAL_SHADOW_OFFSET"]                           = "Horizontaler Schattenversatz."
L["OPTIONS_FOCUS_SHADOW_Y"]                                           = "Schatten Y"
L["OPTIONS_FOCUS_VERTICAL_SHADOW_OFFSET"]                             = "Vertikaler Schattenversatz."
L["OPTIONS_FOCUS_SHADOW_ALPHA"]                                       = "Schattendeckkraft"
L["OPTIONS_FOCUS_SHADOW_OPACITY"]                                     = "Schattendeckkraft (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["OPTIONS_FOCUS_MYTHIC_TYPOGRAPHY"]                                  = "Mythisch+-Typografie"
L["OPTIONS_FOCUS_DUNGEON_NAME_SIZE"]                                  = "Verliesnamengröße"
L["OPTIONS_FOCUS_FONT_SIZE_DUNGEON_NAME_PX"]                          = "Schriftgröße für Dungeon-Namen (8–32 px)."
L["OPTIONS_FOCUS_DUNGEON_NAME_COLOR"]                                 = "Verliesnamenfarbe"
L["OPTIONS_FOCUS_TEXT_COLOR_DUNGEON_NAME"]                            = "Textfarbe für Dungeon-Namen."
L["OPTIONS_FOCUS_TIMER_SIZE"]                                         = "Timer-Größe"
L["OPTIONS_FOCUS_FONT_SIZE_TIMER_PX"]                                 = "Schriftgröße für Timer (8–32 px)."
L["OPTIONS_FOCUS_TIMER_COLOR"]                                        = "Timer-Farbe"
L["OPTIONS_FOCUS_TEXT_COLOR_TIMER"]                                   = "Textfarbe für Timer (in Zeit)."
L["OPTIONS_FOCUS_TIMER_OVERTIME_COLOR"]                               = "Timer-Überzeit-Farbe"
L["OPTIONS_FOCUS_TEXT_COLOR_TIMER_LIMIT"]                             = "Textfarbe für Timer bei Überschreitung."
L["OPTIONS_FOCUS_PROGRESS_SIZE"]                                      = "Fortschrittsgröße"
L["OPTIONS_FOCUS_FONT_SIZE_ENEMY_FORCES_PX"]                          = "Schriftgröße für feindliche Streitkräfte (8–32 px)."
L["OPTIONS_FOCUS_PROGRESS_COLOR"]                                     = "Fortschrittsfarbe"
L["OPTIONS_FOCUS_TEXT_COLOR_ENEMY_FORCES"]                            = "Textfarbe für feindliche Streitkräfte."
L["OPTIONS_FOCUS_BAR_FILL_COLOR"]                                     = "Leistenfüllfarbe"
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL_COLOR_PROGRESS"]                   = "Fortschrittsbalken-Füllfarbe (in Bearbeitung)."
L["OPTIONS_FOCUS_BAR_COMPLETE_COLOR"]                                 = "Leistenfarbe (abgeschlossen)"
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL_COLOR_ENEMY_FORCES"]               = "Fortschrittsbalkenfüllfarbe bei 100 % feindlicher Streitkräfte."
L["OPTIONS_FOCUS_AFFIX_SIZE"]                                         = "Affix-Größe"
L["OPTIONS_FOCUS_FONT_SIZE_AFFIXES_PX"]                               = "Schriftgröße für Affixe (8–32 px)."
L["OPTIONS_FOCUS_AFFIX_COLOR"]                                        = "Affix-Farbe"
L["OPTIONS_FOCUS_TEXT_COLOR_AFFIXES"]                                 = "Textfarbe für Affixe."
L["OPTIONS_FOCUS_BOSS_SIZE"]                                          = "Boss-Größe"
L["OPTIONS_FOCUS_FONT_SIZE_BOSS_NAMES_PX"]                            = "Schriftgröße für Boss-Namen (8–32 px)."
L["OPTIONS_FOCUS_BOSS_COLOR"]                                         = "Boss-Farbe"
L["OPTIONS_FOCUS_TEXT_COLOR_BOSS_NAMES"]                              = "Textfarbe für Boss-Namen."
L["OPTIONS_FOCUS_RESET_MYTHIC_TYPOGRAPHY"]                            = "Mythisch+-Typografie zurücksetzen"

-- =====================================================================
-- OptionsData.lua Appearance
-- =====================================================================
L["OPTIONS_FOCUS_FRAME"]                                              = "Rahmen"
L["OPTIONS_FOCUS_CLASS_COLOURS_DASHBOARD"]                            = "Klassenfarben – Dashboard"
-- L["OPTIONS_FOCUS_CLASS_COLOURS"]                                   = "Class Colours"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_ENABLE_CLASS_COLOURS"]                            = "Enable all class colours"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_TOGGLE_CLASS_COLOURS_MODULES"]                    = "Toggle class colours on or off for all modules at once."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD"]                                       = "Dashboard"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_TINT_FOCUS_HEADER_TITLE_CATEGORY_SECTION"]        = "Tint Focus header title, category section headers, main and between-section dividers, and super-tracked highlight bars and borders with your class colour."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_TINT_PRESENCE_TOAST_TITLE_DIVIDER_YOUR"]          = "Tint Presence toast title and divider with your class colour."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_TINT_VISTA_MINIMAP_ADDON_BAR_PANEL"]              = "Tint Vista minimap, addon-bar, and panel borders and text with your class colour."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLASS_COLOUR_PLAYER_TOOLTIP_NAME_CLASS"]          = "Use class colour for player tooltip name, class line, and border."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_TINT_CACHE_LOOT_ICON_GLOW_EDIT"]                  = "Tint Cache loot icon glow and edit/anchor borders with your class colour."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_TINT_CHARACTER_NAME_ESSENCE_SHEET_YO"]            = "Tint the character name on the Essence sheet with your class colour."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_CLASS_COLORS"]                                       = "Klassenfarben"
L["OPTIONS_FOCUS_TINT_DASHBOARD_ACCENTS_DIVIDERS_HIGHLIGHTS"]         = "Dashboard-Akzente, Trennlinien und Hervorhebungen mit Klassenfarbe einfärben."
-- L["OPTIONS_FOCUS_THEME"]                                           = "Theme"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND"]                            = "Dashboard background"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_BACKGROUND_STYLE_MODULE_DASHBOARD_WINDOW_AXI"]       = "Background style for the module dashboard window (Axis). Default is flat; Midnight uses bundled artwork; Specialisation (auto) uses the in-game talent UI background for your current specialization."
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_MINIMALISTIC"]               = "Minimalistic"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_MIDNIGHT"]                   = "Midnight"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_TELDRASSIL"]                 = "Teldrassil"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_NIGHTFAE"]                   = "Night Fae"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_ZIN_AZSHARI"]                = "Zin-Azshari"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_ILLIDAN"]                    = "Illidan"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_LICH_KING"]                  = "The Lich King"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_TBC_ANNIVERSARY"]            = "TBC Anniversary"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_CLASS_TALENTS"]              = "Specialisation (auto)"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_OPACITY"]                    = "Dashboard background opacity"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_ADJUST_OPACITY_OF_DASHBOARD_BACKGROUND"]          = "Adjust the opacity of the dashboard background (50–100%). Lower values let more of the game world show through."  -- NEEDS TRANSLATION
-- L["DASHBOARD_TYPO_SECTION"]                                        = "Dashboard text"  -- NEEDS TRANSLATION
-- L["DASHBOARD_TYPO_FONT"]                                           = "Dashboard font"  -- NEEDS TRANSLATION
-- L["DASHBOARD_TYPO_FONT_DESC"]                                      = "Font for the Axis settings window (sidebar, search, and option rows). Separate from the Focus tracker font. For CJK or mixed-script welcome text, pick a broad-coverage font (e.g. 2002) if needed."  -- NEEDS TRANSLATION
-- L["DASHBOARD_TYPO_SIZE"]                                           = "Dashboard text size"  -- NEEDS TRANSLATION
-- L["DASHBOARD_TYPO_SIZE_DESC"]                                      = "Nudge all dashboard text larger or smaller (−4 to +4), similar to Focus global font offset."  -- NEEDS TRANSLATION
-- L["DASHBOARD_TYPO_OUTLINE"]                                        = "Dashboard text outline"  -- NEEDS TRANSLATION
L["DASHBOARD_TYPO_OUTLINE_DESC"]                                      = "When on, dashboard UI text uses the standard outlined font style. Turn off for a softer, flat look."
-- L["DASHBOARD_TYPO_SHADOW"]                                         = "Dashboard text shadow"  -- NEEDS TRANSLATION
L["DASHBOARD_TYPO_SHADOW_DESC"]                                       = "Adds a subtle drop shadow behind dashboard text to improve readability on busy backgrounds."
L["OPTIONS_FOCUS_BACKDROP_OPACITY"]                                   = "Hintergrunddeckkraft"
L["OPTIONS_FOCUS_PANEL_BACKGROUND_OPACITY"]                           = "Panel-Hintergrunddeckkraft (0–1)."
L["OPTIONS_FOCUS_BORDER"]                                             = "Rahmen anzeigen"
L["OPTIONS_FOCUS_BORDER_AROUND_TRACKER"]                              = "Rahmen um den Zielverfolger anzeigen."
L["OPTIONS_FOCUS_SCROLL_INDICATOR"]                                   = "Scroll-Indikator anzeigen"
L["OPTIONS_FOCUS_A_VISUAL_HINT_LIST_CONTENT_TH"]                      = "Visuellen Hinweis anzeigen, wenn mehr Inhalt als sichtbar vorhanden."
L["OPTIONS_FOCUS_SCROLL_INDICATOR_STYLE"]                             = "Scroll-Indikator-Stil"
L["OPTIONS_FOCUS_CHOOSE_BETWEEN_A_FADE_GRADIENT_A"]                   = "Verlauf oder Pfeil für scrollbaren Inhalt wählen."
L["OPTIONS_FOCUS_ARROW"]                                              = "Pfeil"
L["OPTIONS_FOCUS_HIGHLIGHT_ALPHA"]                                    = "Hervorhebungs-Alpha"
L["OPTIONS_FOCUS_OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]                 = "Deckkraft der Quest-Hervorhebung (0–1)."
L["OPTIONS_FOCUS_BAR_WIDTH"]                                          = "Leistenbreite"
L["OPTIONS_FOCUS_WIDTH_OF_BAR_STYLE_HIGHLIGHTS_PX"]                   = "Breite der Leistenhervorhebung (2–6 px)."

-- =====================================================================
-- OptionsData.lua Organization
-- =====================================================================
L["OPTIONS_FOCUS_ACTIVITY"]                                           = "Aktivität"
L["OPTIONS_FOCUS_CONTENT"]                                            = "Inhalt"
L["OPTIONS_FOCUS_SORTING"]                                            = "Sortierung"
L["OPTIONS_FOCUS_ELEMENTS"]                                           = "Elemente"
L["OPTIONS_FOCUS_CATEGORY_ORDER"]                                     = "Fokus-Kategoriereihenfolge"
L["OPTIONS_FOCUS_CATEGORY_COLOR_BAR"]                                 = "Kategoriefarbe für Leiste"
L["OPTIONS_FOCUS_CHECKMARK_COMPLETED"]                                = "Häkchen für abgeschlossen"
L["OPTIONS_FOCUS_CURRENT_QUEST_CATEGORY"]                             = "Aktuelle Quest-Kategorie"
L["OPTIONS_FOCUS_CURRENT_QUEST_WINDOW"]                               = "Aktuelle Quest-Fenster"
L["OPTIONS_FOCUS_QUESTS_RECENT_PROGRESS_TOP"]                         = "Quests mit kürzlichem Fortschritt oben anzeigen."
L["OPTIONS_FOCUS_SECONDS_OF_RECENT_PROGRESS_CURRENT_QUEST"]           = "Sekundenfortschritt für aktuelle Quest (30–120)."
L["OPTIONS_FOCUS_QUESTS_YOU_MADE_PROGRESS_LAST_MINUTE"]               = "Quests mit Fortschritt in der letzten Minute erscheinen in eigenem Abschnitt."
L["OPTIONS_FOCUS_CATEGORY_ORDER"]                                     = "Fokus-Kategoriereihenfolge"
L["OPTIONS_FOCUS_DRAG_REORDER_CATEGORIES_DELVES_SCENARIO_EVENT"]      = "Ziehen zum Ändern der Kategorie-Reihenfolge. Tiefen und Szenario-Ereignisse bleiben zuerst."
L["OPTIONS_FOCUS_DRAG_REORDER_DELVES_SCENARIOS_STAY_FIRST"]           = "Ziehen zum Ändern der Reihenfolge. Tiefen und Szenarien bleiben zuerst."
L["OPTIONS_FOCUS_SORT_MODE"]                                          = "Fokus-Sortiermethode"
L["OPTIONS_FOCUS_ORDER_OF_ENTRIES_WITHIN_CATEGORY"]                   = "Reihenfolge der Einträge innerhalb jeder Kategorie."
L["OPTIONS_FOCUS_AUTO_TRACK_ACCEPTED_QUESTS"]                         = "Angenommene Quests automatisch verfolgen"
L["OPTIONS_FOCUS_YOU_ACCEPT_A_QUEST_QUEST_LOG"]                       = "Angenommene Quests (nur Questlog, nicht Weltquests) automatisch zum Zielverfolger hinzufügen."
L["OPTIONS_FOCUS_REQUIRE_CTRL_FOCUS_REMOVE"]                          = "Strg für Fokus & Entfernen erforderlich"
L["OPTIONS_FOCUS_REQUIRE_CTRL_FOCUS_ADD_LEFT_UNFOCUS"]                = "Strg für Fokus/Hinzufügen (Links) und Entfokussieren/Entfernen (Rechts) erforderlich, um Fehlklicks zu vermeiden."
L["OPTIONS_FOCUS_CTRL_FOCUS_UNTRACK"]                                 = "Strg für Fokus / Nicht verfolgen"
L["OPTIONS_FOCUS_CTRL_CLICK_COMPLETE"]                                = "Strg für Klick-Abschluss"
L["OPTIONS_FOCUS_CLASSIC_CLICK_BEHAVIOUR"]                            = "Klassisches Klick-Verhalten verwenden"
L["OPTIONS_FOCUS_CLASSIC_CLICKS"]                                     = "Klassische Klicks"
-- === Focus Click Profiles ===
-- L["OPTIONS_FOCUS_CLICK_PROFILE"]                                   = "Click profile"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_CLICK_PROFILE_DESC"]                                 = "Choose how mouse clicks on tracker entries behave."
-- L["OPTIONS_FOCUS_PROFILE_HORIZON_PLUS"]                            = "Horizon+"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_PROFILE_BLIZZARD_DEFAULT"]                           = "Blizzard Default"
-- L["OPTIONS_FOCUS_PROFILE_CUSTOM"]                                  = "Custom"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_COMING_SOON"]                                     = "Coming soon"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_COMBOS"]                                    = "Custom bindings"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_COMBO_LOCKED_TOOLTIP"]                      = "Fixed for this profile. Select Custom to edit shortcuts."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_SAFETY"]                                    = "Safety"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_COMBO_LEFT"]                                      = "Left click"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_COMBO_SHIFT_LEFT"]                                = "Shift + Left click"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_COMBO_CTRL_LEFT"]                                 = "Ctrl + Left click"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_COMBO_ALT_LEFT"]                                  = "Alt + Left click"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_COMBO_RIGHT"]                                     = "Right click"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_COMBO_SHIFT_RIGHT"]                               = "Shift + Right click"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_COMBO_CTRL_RIGHT"]                                = "Ctrl + Right click"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_ACTION_NONE"]                               = "Do nothing"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_ACTION_SUPER_TRACK"]                        = "Focus quest"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_ACTION_OPEN_PROFESSION"]                    = "Open profession or quest details"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_ACTION_OPEN_QUEST_LOG"]                     = "Open quest log"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_ACTION_UNTRACK"]                            = "Untrack"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_ACTION_CONTEXT_MENU"]                       = "Context menu"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_ACTION_SHARE"]                              = "Share with party"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_ACTION_ABANDON"]                            = "Abandon quest"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_ACTION_WOWHEAD"]                            = "WoWhead URL"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_ACTION_CHAT_LINK"]                          = "Link in chat"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_APPEARANCE_CANNOT_SHARE"]                         = "Appearances cannot be shared like quests."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_QUEST_DETAILS_AFTER_COMBAT"]                      = "Quest details will open when you leave combat."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_SHARE_PARTY"]                                        = "Mit Gruppe teilen"
L["OPTIONS_FOCUS_ABANDON_QUEST"]                                      = "Quest abbrechen"
L["OPTIONS_FOCUS_STOP_TRACKING"]                                      = "Nicht mehr verfolgen"
-- L["OPTIONS_FOCUS_CONTEXT_OPEN_ACHIEVEMENT"]                        = "Open achievement"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CONTEXT_OPEN_ENDEAVOR"]                           = "Open endeavor"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CONTEXT_OPEN_RECIPE"]                             = "Open recipe"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CONTEXT_OPEN_DECOR_CATALOG"]                      = "Open in catalog"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CONTEXT_PREVIEW_DECOR"]                           = "Preview decor"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CONTEXT_SHOW_DECOR_MAP"]                          = "Show on map"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CONTEXT_OPEN_TRAVELERS_LOG"]                      = "Open Traveler's Log"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CONTEXT_SET_RARE_WAYPOINT"]                       = "Set waypoint"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CONTEXT_CLEAR_RARE_FOCUS"]                        = "Clear map focus"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_TRACKED_CONTENT_CANNOT_SHARE"]                    = "This entry cannot be shared with the party."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_QUEST_CANNOT_SHARED"]                                = "Diese Quest kann nicht geteilt werden."
L["OPTIONS_FOCUS_YOU_MUST_A_PARTY_SHARE_QUEST"]                       = "Ihr müsst in einer Gruppe sein, um diese Quest zu teilen."
L["OPTIONS_FOCUS_LEFT_CLICK_OPENS_QUEST_MAP_RIGHT"]                   = "Ein: Linksklick öffnet Questkarte, Rechtsklick Teilen/Abbruch (Blizzard). Aus: Linksklick fokussiert, Rechtsklick nicht verfolgen; Strg+Rechts teilt."
L["OPTIONS_FOCUS_ANIMATIONS"]                                         = "Focus animations"
L["OPTIONS_FOCUS_ENABLE_SLIDE_FADE_QUESTS"]                           = "Slide- und Fade-Effekte für Quests aktivieren."
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_FLASH"]                           = "Ziel-Fortschrittsfunken"
L["OPTIONS_FOCUS_FLASH_AN_OBJECTIVE_COMPLETES"]                       = "Leuchten bei Ziel-Abschluss anzeigen."
L["OPTIONS_FOCUS_FLASH_INTENSITY"]                                    = "Leuchtintensität"
L["OPTIONS_FOCUS_NOTICEABLE_OBJECTIVE_COMPLETE_FLASH"]                = "Auffälligkeit des Zielabschlussleuchtens."
L["OPTIONS_FOCUS_FLASH_COLOR"]                                        = "Leuchtfarbe"
L["OPTIONS_FOCUS_COLOR_OF_OBJECTIVE_COMPLETE_FLASH"]                  = "Farbe des Zielabschlussleuchtens."
L["OPTIONS_FOCUS_SUBTLE"]                                             = "Dezent"
L["OPTIONS_FOCUS_MEDIUM"]                                             = "Mittel"
L["OPTIONS_FOCUS_STRONG"]                                             = "Stark"
L["OPTIONS_FOCUS_REQUIRE_CTRL_CLICK_COMPLETE"]                        = "Strg für Klick zum Abschließen erforderlich"
L["OPTIONS_FOCUS_REQUIRES_CTRL_LEFT_CLICK_COMPLETE_AUTO"]             = "EIN: Strg+Linksklick für Klick-Abschluss. AUS: einfacher Linksklick (Blizzard-Standard). Nur bei klickbaren Quests."
L["OPTIONS_FOCUS_SUPPRESS_UNTRACKED_UNTIL_RELOAD"]                    = "Nicht verfolgte bis Neuladen unterdrücken"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS_Z"]                 = "EIN: Rechtsklick Nicht verfolgen versteckt bis Neuladen oder neuer Sitzung. AUS: erscheinen wieder bei Zonen-Rückkehr."
L["OPTIONS_FOCUS_PERMANENTLY_SUPPRESS_UNTRACKED_QUESTS"]              = "Nicht verfolgte Quests dauerhaft unterdrücken"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACKED_WORLD_QUESTS_ZO"]              = "An: Rechtsklick Nicht verfolgen versteckt dauerhaft (über Neuladen). Vorrang vor „Bis Neuladen\". Annehmen entfernt von Sperrliste."
L["OPTIONS_FOCUS_KEEP_CAMPAIGN_QUESTS_CATEGORY"]                      = "Kampagnen-Quest in Kategorie bleiben"
L["OPTIONS_FOCUS_CAMPAIGN_QUESTS_READY_TURN_RE"]                      = "An: abgabebereite Kampagnen-Quests bleiben in Kampagne statt in Abgeschlossen."
L["OPTIONS_FOCUS_KEEP_IMPORTANT_QUESTS_CATEGORY"]                     = "Wichtige Quests in Kategorie bleiben"
L["OPTIONS_FOCUS_IMPORTANT_QUESTS_READY_TURN_R"]                      = "An: abgabebereite wichtige Quests bleiben in Wichtig statt in Abgeschlossen."
L["OPTIONS_FOCUS_TOMTOM_QUEST_WAYPOINT"]                              = "TomTom-Quest-Wegpunkt"
L["OPTIONS_FOCUS_A_TOMTOM_WAYPOINT_FOCUSING_A_QUEST"]                 = "TomTom-Wegpunkt setzen beim Fokussieren einer Quest."
L["OPTIONS_FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_NEXT_QUEST"]            = "TomTom erforderlich. Der Pfeil zeigt auf das nächste Questziel."
L["OPTIONS_FOCUS_TOMTOM_RARE_WAYPOINT"]                               = "TomTom-Rare-Boss-Wegpunkt"
L["OPTIONS_FOCUS_A_TOMTOM_WAYPOINT_CLICKING_A_RARE"]                  = "TomTom-Wegpunkt setzen beim Klicken auf einen seltenen Boss."
L["OPTIONS_FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_RARE_S"]                = "TomTom erforderlich. Der Pfeil zeigt auf die Position des seltenen Bosses."
L["OPTIONS_FOCUS_FIND_A_GROUP"]                                       = "Gruppe finden"
L["OPTIONS_FOCUS_CLICK_SEARCH_A_GROUP_QUEST"]                         = "Klicken, um eine Gruppe für diese Quest zu suchen."

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
L["OPTIONS_FOCUS_BLACKLIST"]                                          = "Sperrliste"
L["OPTIONS_FOCUS_BLACKLIST_UNTRACKED"]                                = "Nicht verfolgte sperren"
L["OPTIONS_FOCUS_ENABLE_BLACKLIST_UNTRACKED_BEHAVIOUR_ADD_QUEST"]     = "„Nicht verfolgte sperren\" in Verhalten aktivieren, um Quests hier hinzuzufügen."
L["OPTIONS_FOCUS_HIDDEN_QUESTS"]                                      = "Versteckte Quests"
L["OPTIONS_FOCUS_QUESTS_HIDDEN_RIGHT_CLICK_UNTRACK"]                  = "Quests versteckt durch Rechtsklick Nicht verfolgen."
L["OPTIONS_FOCUS_BLACKLISTED_QUESTS"]                                 = "Gesperrte Quests"
L["OPTIONS_FOCUS_PERMANENTLY_SUPPRESSED_QUESTS"]                      = "Dauerhaft unterdrückte Quests"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACK_QUESTS_PERMANENTLY_SUPPRESS"]    = "Rechtsklick Nicht verfolgen mit „Dauerhaft unterdrücken\" aktiviert fügt Quests hier hinzu."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["OPTIONS_PRESENCE_QUEST_TYPE_ICONS"]                                = "Quest-Typ-Symbole anzeigen"
L["OPTIONS_PRESENCE_QUEST_TYPE_ICON_FOCUS_TRACKER_QUEST"]             = "Quest-Typ-Symbol im Focus-Zielverfolger anzeigen."
L["OPTIONS_PRESENCE_QUEST_TYPE_ICONS_TOASTS"]                         = "Quest-Typ-Symbole auf Toasts anzeigen"
L["OPTIONS_PRESENCE_QUEST_TYPE_ICON_PRESENCE_TOASTS_QUEST"]           = "Quest-Typ-Symbol auf Präsenz-Toasts anzeigen."
L["OPTIONS_PRESENCE_TOAST_ICON_SIZE"]                                 = "Toast-Symbolgröße"
L["OPTIONS_PRESENCE_QUEST_ICON_SIZE_PRESENCE_TOASTS_PX"]              = "Quest-Symbolgröße auf Präsenz-Toasts (16–36 px). Standard 24."
L["OPTIONS_PRESENCE_HIDE_QUEST_UPDATE_TITLE"]                         = "Quest-Update-Titel verbergen"
L["OPTIONS_PRESENCE_OBJECTIVE_LINE_QUEST_PROGRESS_TOAST"]             = "Nur Zielzeile auf Quest-Fortschritt-Toasts (z.B. 7/10 Eberfelle), ohne Questname oder Header."
L["OPTIONS_PRESENCE_SHOW_DISCOVERY_LINE"]                             = "Entdeckungs-Zeile anzeigen"
L["OPTIONS_PRESENCE_DISCOVERY_LINE"]                                  = "Entdeckungs-Zeile"
L["OPTIONS_PRESENCE_DISCOVERED_UNDER_ZONE_SUBZONE_ENTERING_A"]        = "„Entdeckt\" unter Zone/Unterzone bei neuem Gebiet anzeigen."
L["OPTIONS_PRESENCE_FRAME_VERTICAL_POSITION"]                         = "Rahmen vertikale Position"
L["OPTIONS_PRESENCE_VERTICAL_OFFSET_OF_PRESENCE_FRAME_CENTER"]        = "Vertikaler Offset des Präsenz-Rahmens von Mitte (-300 bis 0)."
L["OPTIONS_PRESENCE_FRAME_SCALE"]                                     = "Rahmen-Skalierung"
L["OPTIONS_PRESENCE_SCALE_OF_PRESENCE_FRAME"]                         = "Skalierung des Präsenz-Rahmens (0,5–2)."
L["OPTIONS_PRESENCE_BOSS_EMOTE_COLOR"]                                = "Boss-Emote-Farbe"
L["OPTIONS_PRESENCE_COLOR_OF_RAID_DUNGEON_BOSS_EMOTE"]                = "Farbe von Boss-Emote-Text in Schlachtzügen und Dungeons."
L["OPTIONS_PRESENCE_DISCOVERY_LINE_COLOR"]                            = "Entdeckungs-Zeilen-Farbe"
L["OPTIONS_PRESENCE_COLOR_OF_DISCOVERED_LINE_UNDER_ZONE"]             = "Farbe der „Entdeckt\"-Zeile unter dem Zonentext."
L["OPTIONS_PRESENCE_NOTIFICATION_TYPES"]                              = "Benachrichtigungstypen"
L["OPTIONS_PRESENCE_NOTIFICATIONS"]                                   = "Benachrichtigungen"
L["OPTIONS_PRESENCE_NOTIFICATION_ACHIEVEMENT_CRITERIA_UPDATE_T"]      = "Benachrichtigung bei Erfolgs-Kriterien-Update (verfolgte immer; andere wenn Blizzard ID liefert)."
L["OPTIONS_PRESENCE_ZONE_ENTRY"]                                      = "Zoneneintritt anzeigen"
L["OPTIONS_PRESENCE_ZONE_CHANGE_ENTERING_A_AREA"]                     = "Zonenwechsel bei neuem Gebiet anzeigen."
L["OPTIONS_PRESENCE_SUBZONE_CHANGES"]                                 = "Unterzonenwechsel anzeigen"
L["OPTIONS_PRESENCE_SUBZONE_CHANGE_MOVING_WITHIN_SAME_ZONE"]          = "Unterzonenwechsel bei Bewegung in gleicher Zone anzeigen."
L["OPTIONS_PRESENCE_HIDE_ZONE_NAME_SUBZONE_CHANGES"]                  = "Zonennamen bei Unterzonenwechsel verbergen"
L["OPTIONS_PRESENCE_MOVING_BETWEEN_SUBZONES_WITHIN_SAME_ZONE"]        = "Bei Unterzonenwechsel in gleicher Zone nur Unterzonenname. Zonennamen erscheint bei neuer Zone."
-- L["OPTIONS_PRESENCE_SUPPRESS_DELVE"]                               = "Suppress in Delve"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_SUPPRESS_SCENARIO_PROGRESS_NOTIFICATIONS_DELVES"]= "Suppress scenario progress notifications in Delves."  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_HIDES_OBJECTIVE_UPDATE_POPUPS_WHILE_A"]        = "When on, hides objective update popups while in a Delve. Zone entry and completion toasts still show."  -- NEEDS TRANSLATION
L["OPTIONS_PRESENCE_SUPPRESS_ZONE_CHANGES_MYTHIC"]                    = "Zonenwechsel in Mythisch+ unterdrücken"
L["OPTIONS_PRESENCE_MYTHIC_BOSS_EMOTES_ACHIEVEMENTS_LEV"]             = "In Mythisch+ nur Boss-Emotes, Erfolge und Levelaufstieg. Zone-, Quest- und Szenario-Benachrichtigungen verbergen."
L["OPTIONS_PRESENCE_LEVEL"]                                           = "Levelaufstieg anzeigen"
L["OPTIONS_PRESENCE_LEVEL_NOTIFICATION"]                              = "Levelaufstieg-Benachrichtigung anzeigen."
L["OPTIONS_PRESENCE_BOSS_EMOTES"]                                     = "Boss-Emotes anzeigen"
L["OPTIONS_PRESENCE_RAID_DUNGEON_BOSS_EMOTE_NOTIFICATIONS"]           = "Schlachtzug- und Dungeon-Boss-Emote-Benachrichtigungen anzeigen."
L["OPTIONS_PRESENCE_ACHIEVEMENTS"]                                    = "Erfolge anzeigen"
L["OPTIONS_PRESENCE_ACHIEVEMENT_EARNED_NOTIFICATIONS"]                = "Benachrichtigungen bei erlangten Erfolgen anzeigen."
L["OPTIONS_PRESENCE_ACHIEVEMENT_PROGRESS"]                            = "Erfolgsfortschritt"
L["OPTIONS_PRESENCE_ACHIEVEMENT_EARNED"]                              = "Erfolg erlangt"
L["OPTIONS_PRESENCE_QUEST_ACCEPTED"]                                  = "Quest angenommen"
L["OPTIONS_PRESENCE_WORLD_QUEST_ACCEPTED"]                            = "Weltquest angenommen"
L["OPTIONS_PRESENCE_SCENARIO_COMPLETE"]                               = "Szenario abgeschlossen"
L["OPTIONS_PRESENCE_RARE_DEFEATED"]                                   = "Selten besiegt"
L["OPTIONS_PRESENCE_NOTIFICATION_TRACKED_ACHIEVEMENT_CRITERIA"]       = "Benachrichtigung bei verfolgtem Erfolgs-Kriterien-Update anzeigen."
L["OPTIONS_PRESENCE_QUEST_ACCEPT"]                                    = "Quest-Annahme anzeigen"
L["OPTIONS_PRESENCE_NOTIFICATION_ACCEPTING_A_QUEST"]                  = "Benachrichtigung bei Quest-Annahme anzeigen."
L["OPTIONS_PRESENCE_WORLD_QUEST_ACCEPT"]                              = "Weltquest-Annahme anzeigen"
L["OPTIONS_PRESENCE_NOTIFICATION_ACCEPTING_A_WORLD_QUEST"]            = "Benachrichtigung bei Weltquest-Annahme anzeigen."
L["OPTIONS_PRESENCE_QUEST_COMPLETE"]                                  = "Quest-Abschluss anzeigen"
L["OPTIONS_PRESENCE_NOTIFICATION_COMPLETING_A_QUEST"]                 = "Benachrichtigung bei Quest-Abschluss anzeigen."
L["OPTIONS_PRESENCE_WORLD_QUEST_COMPLETE"]                            = "Weltquest-Abschluss anzeigen"
L["OPTIONS_PRESENCE_NOTIFICATION_COMPLETING_A_WORLD_QUEST"]           = "Benachrichtigung bei Weltquest-Abschluss anzeigen."
L["OPTIONS_PRESENCE_QUEST_PROGRESS"]                                  = "Quest-Fortschritt anzeigen"
L["OPTIONS_PRESENCE_NOTIFICATION_QUEST_OBJECTIVES_UPDATE"]            = "Benachrichtigung bei Quest-Ziel-Update anzeigen."
L["OPTIONS_PRESENCE_OBJECTIVE"]                                       = "Nur Ziel"
L["OPTIONS_PRESENCE_QUEST_PROGRESS_HIDE_TITLE"]                       = "Nur Zielzeile auf Quest-Fortschritt-Toasts, „Quest-Update\"-Titel verbergen."
L["OPTIONS_PRESENCE_SCENARIO_START"]                                  = "Szenario-Start anzeigen"
L["OPTIONS_PRESENCE_NOTIFICATION_ENTERING_A_SCENARIO_DELVE"]          = "Benachrichtigung bei Szenario- oder Tiefen-Eintritt anzeigen."
L["OPTIONS_PRESENCE_SCENARIO_PROGRESS"]                               = "Szenario-Fortschritt anzeigen"
L["OPTIONS_PRESENCE_NOTIFICATION_SCENARIO_DELVE_OBJECTIVES"]          = "Benachrichtigung bei Szenario- oder Tiefen-Ziel-Update anzeigen."
-- L["OPTIONS_PRESENCE_ANIMATION"]                                    = "Animation"  -- NEEDS TRANSLATION
L["OPTIONS_PRESENCE_ENABLE_ANIMATIONS"]                               = "Animationen aktivieren"
L["OPTIONS_PRESENCE_ENABLE_ENTRANCE_EXIT_ANIMATIONS_PRESENCE"]        = "Ein- und Ausblend-Animationen für Präsenz-Benachrichtigungen aktivieren."
L["OPTIONS_PRESENCE_ENTRANCE_DURATION"]                               = "Einblend-Dauer"
L["OPTIONS_PRESENCE_DURATION_OF_ENTRANCE_ANIMATION_SECONDS"]          = "Dauer der Einblend-Animation in Sekunden (0,2–1,5)."
L["OPTIONS_PRESENCE_EXIT_DURATION"]                                   = "Ausblend-Dauer"
L["OPTIONS_PRESENCE_DURATION_OF_EXIT_ANIMATION_SECONDS"]              = "Dauer der Ausblend-Animation in Sekunden (0,2–1,5)."
L["OPTIONS_PRESENCE_HOLD_DURATION_SCALE"]                             = "Anzeige-Dauer-Multiplikator"
L["OPTIONS_PRESENCE_MULTIPLIER_LONG_NOTIFICATION_STAYS_S"]            = "Multiplikator für Anzeige-Dauer jeder Benachrichtigung (0,5–2)."
-- L["OPTIONS_PRESENCE_PREVIEW"]                                      = "Preview"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_PREVIEW_TOAST_TYPE"]                           = "Preview toast type"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_SELECT_A_TOAST_TYPE_PREVIEW"]                  = "Select a toast type to preview."  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_SELECTED_TOAST_TYPE"]                          = "Show the selected toast type."  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_PREVIEW_PRESENCE_TOAST_LAYOUTS_LIVE_OPEN"]     = "Preview Presence toast layouts live and open a detachable sample while adjusting other settings."  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_OPEN_DETACHED_PREVIEW"]                        = "Open detached preview"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_OPEN_A_MOVABLE_PREVIEW_WINDOW_STAYS"]          = "Open a movable preview window that stays visible while you change other Presence settings."  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_ANIMATE_PREVIEW"]                              = "Animate preview"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_PLAY_SELECTED_TOAST_ANIMATION_INSIDE_PREVIE"]  = "Play the selected toast animation inside this preview window."  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_DETACHED_PREVIEW"]                             = "Detached preview"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_KEEP_OPEN_WHILE_ADJUSTING_TYPOGRAPHY_COLORS"]  = "Keep this open while adjusting Typography or Colors."  -- NEEDS TRANSLATION
L["DASH_TYPOGRAPHY"]                                                  = "Typografie"
L["OPTIONS_PRESENCE_MAIN_TITLE_FONT"]                                 = "Haupttitel-Schriftart"
L["OPTIONS_PRESENCE_FONT_FAMILY_MAIN_TITLE"]                          = "Schriftart für den Haupttitel."
L["OPTIONS_PRESENCE_SUBTITLE_FONT"]                                   = "Untertitel-Schriftart"
L["OPTIONS_PRESENCE_FONT_FAMILY_SUBTITLE"]                            = "Schriftart für den Untertitel."
-- L["OPTIONS_PRESENCE_RESET_TYPOGRAPHY_DEFAULTS"]                    = "Reset typography to defaults"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_RESET_PRESENCE_TYPOGRAPHY_OPTIONS_FONTS_SIZES"]= "Reset all Presence typography options (fonts, sizes, colors) to defaults."  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_LARGE_NOTIFICATIONS"]                          = "Large notifications"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_MEDIUM_NOTIFICATIONS"]                         = "Medium notifications"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_SMALL_NOTIFICATIONS"]                          = "Small notifications"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_LARGE_PRIMARY_SIZE"]                           = "Large primary size"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_TITLES_ZONE"]     = "Font size for large notification titles (zone, quest complete, achievement, etc.)."  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_LARGE_SECONDARY_SIZE"]                         = "Large secondary size"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_SUBTITLES"]       = "Font size for large notification subtitles."  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_MEDIUM_PRIMARY_SIZE"]                          = "Medium primary size"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_TITLES_QUEST"]   = "Font size for medium notification titles (quest accept, subzone, scenario)."  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_MEDIUM_SECONDARY_SIZE"]                        = "Medium secondary size"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_SUBTITLES"]      = "Font size for medium notification subtitles."  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_SMALL_PRIMARY_SIZE"]                           = "Small primary size"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_TITLES_QUEST"]    = "Font size for small notification titles (quest progress, achievement progress)."  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_SMALL_SECONDARY_SIZE"]                         = "Small secondary size"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_SUBTITLES"]       = "Font size for small notification subtitles."  -- NEEDS TRANSLATION

-- =====================================================================
-- OptionsData.lua Dropdown options — Outline
-- =====================================================================
L["OPTIONS_FOCUS_NONE"]                                               = "Keine"
L["OPTIONS_FOCUS_THICK_OUTLINE"]                                      = "Dicker Umriss"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["OPTIONS_FOCUS_BAR_LEFT_EDGE"]                                      = "Leiste (linker Rand)"
L["OPTIONS_FOCUS_BAR_RIGHT_EDGE"]                                     = "Leiste (rechter Rand)"
L["OPTIONS_FOCUS_BAR_TOP_EDGE"]                                       = "Leiste (oberer Rand)"
L["OPTIONS_FOCUS_BAR_BOTTOM_EDGE"]                                    = "Leiste (unterer Rand)"
L["OPTIONS_FOCUS_OUTLINE_ONLY_STYLE"]                                 = "Nur Umriss"
L["OPTIONS_FOCUS_SOFT_GLOW"]                                          = "Sanftes Leuchten"
L["OPTIONS_FOCUS_DUAL_EDGE_BARS"]                                     = "Doppelrandleisten"
L["OPTIONS_FOCUS_PILL_LEFT_ACCENT"]                                   = "Akzentpille (links)"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["OPTIONS_FOCUS_TOP"]                                                = "Oben"
L["OPTIONS_FOCUS_BOTTOM"]                                             = "Unten"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["OPTIONS_VISTA_LOCATION_POSITION"]                                  = "Standortposition"
L["OPTIONS_VISTA_PLACE_ZONE_NAME_ABOVE_BELOW_MINIMAP"]                = "Zonennamen über oder unter der Minikarte platzieren."
L["OPTIONS_VISTA_COORDINATES_POSITION"]                               = "Koordinatenposition"
L["OPTIONS_VISTA_PLACE_COORDINATES_ABOVE_BELOW_MINIMAP"]              = "Koordinaten über oder unter der Minikarte platzieren."
L["OPTIONS_VISTA_CLOCK_POSITION"]                                     = "Uhrposition"
L["OPTIONS_VISTA_PLACE_CLOCK_ABOVE_BELOW_MINIMAP"]                    = "Uhr über oder unter der Minikarte platzieren."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["OPTIONS_FOCUS_LOWER_CASE"]                                         = "Kleinbuchstaben"
L["OPTIONS_FOCUS_UPPER_CASE"]                                         = "Großbuchstaben"
L["OPTIONS_FOCUS_PROPER"]                                             = "Große Anfangsbuchstaben"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["OPTIONS_FOCUS_TRACKED_LOG"]                                        = "Verfolgt / im Log"
L["OPTIONS_FOCUS_LOG_MAX_SLOTS"]                                      = "Im Log / max. Plätze"

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["OPTIONS_FOCUS_ALPHABETICAL"]                                       = "Alphabetisch"
L["OPTIONS_FOCUS_QUEST_TYPE"]                                         = "Quest-Typ"
L["OPTIONS_FOCUS_QUEST_LEVEL"]                                        = "Quest-Stufe"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["OPTIONS_FOCUS_CUSTOM"]                                             = "Benutzerdefiniert"
L["OPTIONS_FOCUS_ORDER"]                                              = "Reihenfolge"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["UI_DUNGEON"]                                                       = "Verlies"
L["UI_RAID"]                                                          = "Schlachtzug"
L["UI_DELVES"]                                                        = "Tiefe"
L["UI_SCENARIO_EVENTS"]                                               = "Szenario"
L["UI_STAGE"]                                                         = "Phase"
L["UI_STAGE_X_X"]                                                     = "Phase %d: %s"
L["UI_AVAILABLE_IN_ZONE"]                                             = "In Zone verfügbar"
L["UI_EVENTS_IN_ZONE"]                                                = "Zonenereignisse"
L["UI_CURRENT_EVENT"]                                                 = "Aktuelles Ereignis"
L["UI_CURRENT_QUEST"]                                                 = "Aktuelle Quest"
L["UI_CURRENT_ZONE"]                                                  = "Aktuelle Zone"
L["UI_CAMPAIGN"]                                                      = "Kampagne"
L["UI_IMPORTANT"]                                                     = "Wichtig"
L["UI_LEGENDARY"]                                                     = "Legendär"
L["UI_WORLD_QUESTS"]                                                  = "Welt"
L["UI_WEEKLY_QUESTS"]                                                 = "Wöchentlich"
L["UI_PREY"]                                                          = "Beute"
L["UI_ABUNDANCE"]                                                     = "Überfluss"
L["UI_ABUNDANCE_BAG"]                                                 = "Überflussbeutel"
L["UI_ABUNDANCE_HELD"]                                                = "Überfluss gehalten"
L["UI_DAILY_QUESTS"]                                                  = "Täglich"
L["UI_RARE_BOSSES"]                                                   = "Rare Bosse"
L["UI_ACHIEVEMENTS"]                                                  = "Erfolge"
L["UI_ENDEAVORS"]                                                     = "Bestrebungen"
L["UI_DECOR"]                                                         = "Dekoration"
L["UI_RECIPES"]                                                       = "Rezepte"
L["UI_ADVENTURE_GUIDE"]                                               = "Abenteuerführer"
-- L["UI_APPEARANCES"]                                                = "Appearances"  -- NEEDS TRANSLATION
L["UI_QUESTS"]                                                        = "Quests"
L["UI_READY_TO_TURN_IN"]                                              = "ABGABEBEREIT"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["PRESENCE_OBJECTIVES"]                                              = "ZIELE"
L["PRESENCE_OPTIONS"]                                                 = "Optionen"
L["PRESENCE_OPEN_HORIZON_SUITE"]                                      = "Horizon Suite öffnen"
L["PRESENCE_OPEN_FULL_HORIZON_SUITE_OPTIONS"]                         = "Öffnet das vollständige Horizon Suite-Optionsfenster zur Konfiguration von Focus, Presence, Vista und anderen Modulen."
L["PRESENCE_SHOW_MINIMAP_ICON"]                                       = "Minimap-Symbol anzeigen"
L["PRESENCE_A_CLICKABLE_ICON_MINIMAP_OPENS"]                          = "Zeigt ein klickbares Symbol auf der Minimap, das das Optionsfenster öffnet."
-- L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER"]              = "Fade until minimap hover"  -- NEEDS TRANSLATION
-- L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER_DESC"]         = "When on, the icon stays faded until you move the cursor over the minimap. When off, it stays fully visible."  -- NEEDS TRANSLATION
-- L["PRESENCE_LOCK_MINIMAP_BUTTON_POSITION"]                         = "Lock minimap button position"  -- NEEDS TRANSLATION
-- L["PRESENCE_PREVENT_DRAGGING_HORIZON_MINIMAP_BUTTON"]              = "Prevent dragging the Horizon minimap button."  -- NEEDS TRANSLATION
-- L["PRESENCE_RESET_MINIMAP_BUTTON_POSITION"]                        = "Reset minimap button position"  -- NEEDS TRANSLATION
-- L["PRESENCE_RESET_MINIMAP_BUTTON_DEFAULT_POSITION"]                = "Reset the minimap button to the default position (bottom-left)."  -- NEEDS TRANSLATION
-- L["PRESENCE_DRAG_TO_MOVE_WHEN_UNLOCKED"]                           = "Drag to move (when unlocked)."  -- NEEDS TRANSLATION
L["PRESENCE_LOCKED"]                                                  = "Fixiert"
L["PRESENCE_DISCOVERED"]                                              = "Entdeckt"
L["PRESENCE_REFRESH"]                                                 = "Aktualisieren"
L["PRESENCE_BEST_EFFORT_UNACCEPTED_QUESTS_EXPO"]                      = "Nur bestmöglich. Manche nicht angenommenen Quests werden erst nach NPC-Interaktion oder Phasenbedingungen angezeigt."
L["PRESENCE_UNACCEPTED_QUESTS_X_MAP_X"]                               = "Nicht angenommene Quests - %s (Karte %s) - %d Treffer"
L["PRESENCE_LEVEL_UP"]                                                = "STUFENAUFSTIEG"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_80"]                               = "Ihr habt Stufe 80 erreicht"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_X"]                                = "Ihr habt Stufe %s erreicht"
L["PRESENCE_ACHIEVEMENT_EARNED"]                                      = "ERFOLG ERRUNGEN"
L["PRESENCE_EXPLORING_THE_MIDNIGHT_ISLES"]                            = "Mitternachtsinseln erkunden"
L["PRESENCE_EXPLORING_KHAZ_ALGAR"]                                    = "Khaz Algar erkunden"
L["PRESENCE_QUEST_COMPLETE"]                                          = "QUEST ABGESCHLOSSEN"
L["PRESENCE_OBJECTIVE_SECURED"]                                       = "Ziel gesichert"
L["PRESENCE_AIDING_THE_ACCORD"]                                       = "Dem Abkommen helfen"
L["PRESENCE_WORLD_QUEST"]                                             = "WELT-QUEST"
L["PRESENCE_WORLD_QUEST_COMPLETE"]                                    = "WELT-QUEST ABGESCHLOSSEN"
L["PRESENCE_AZERITE_MINING"]                                          = "Azerit-Abbau"
L["PRESENCE_WORLD_QUEST_ACCEPTED"]                                    = "WELT-QUEST ANGENOMMEN"
L["PRESENCE_QUEST_ACCEPTED"]                                          = "QUEST ANGENOMMEN"
L["PRESENCE_THE_FATE_OF_THE_HORDE"]                                   = "Das Schicksal der Horde"
L["PRESENCE_NEW_QUEST"]                                               = "Neue Quest"
L["PRESENCE_QUEST_UPDATE"]                                            = "QUEST-FORTSCHRITT"
L["PRESENCE_BOAR_PELTS_7_10"]                                         = "Eberfelle: 7/10"
L["PRESENCE_DRAGON_GLYPHS_3_5"]                                       = "Drachenglyphen: 3/5"
L["PRESENCE_PRESENCE_TEST_COMMANDS"]                                  = "Präsenz-Testbefehle:"
L["PRESENCE_H_PRESENCE_DEBUGTYPES_DUMP_NOTIFICATION"]                 = "  /h presence debugtypes - Benachrichtigungsoptionen und Blizzard-Unterdrückungsstatus ausgeben"
L["PRESENCE_PRESENCE_PLAYING_DEMO_REEL_NOTIFICATION"]                 = "Präsenz: Demo wird abgespielt (alle Benachrichtigungstypen)..."
L["PRESENCE_H_PRESENCE_HELP_TEST_CURRENT"]                            = "  /h presence         - Hilfe + aktuelle Zone testen"
L["PRESENCE_H_PRESENCE_ZONE_TEST_ZONE"]                               = "  /h presence zone     - Zonenwechsel testen"
L["PRESENCE_H_PRESENCE_SUBZONE_TEST_SUBZONE"]                         = "  /h presence subzone  - Unterzonenwechsel testen"
L["PRESENCE_H_PRESENCE_DISCOVER_TEST_ZONE"]                           = "  /h presence discover - Zonenentdeckung testen"
L["PRESENCE_H_PRESENCE_LEVEL_TEST_LEVEL"]                             = "  /h presence level    - Levelaufstieg testen"
L["PRESENCE_H_PRESENCE_BOSS_TEST_BOSS"]                               = "  /h presence boss     - Boss-Emote testen"
L["PRESENCE_H_PRESENCE_ACH_TEST_ACHIEVEMENT"]                         = "  /h presence ach      - Erfolg testen"
L["PRESENCE_H_PRESENCE_ACCEPT_TEST_QUEST"]                            = "  /h presence accept   - Quest angenommen testen"
L["PRESENCE_H_PRESENCE_WQACCEPT_TEST_WORLD"]                          = "  /h presence wqaccept - Weltquest angenommen testen"
L["PRESENCE_H_PRESENCE_SCENARIO_TEST_SCENARIO"]                       = "  /h presence scenario - Szenario-Start testen"
L["PRESENCE_H_PRESENCE_QUEST_TEST_QUEST"]                             = "  /h presence quest    - Quest abgeschlossen testen"
L["PRESENCE_H_PRESENCE_WQ_TEST_WORLD"]                                = "  /h presence wq       - Weltquest testen"
L["PRESENCE_H_PRESENCE_UPDATE_TEST_QUEST"]                            = "  /h presence update   - Quest-Update testen"
L["PRESENCE_H_PRESENCE_ACHPROGRESS_TEST_ACHIEVEMENT"]                 = "  /h presence achprogress - Erfolgsfortschritt testen"
L["PRESENCE_H_PRESENCE_DEMO_REEL_TYPES"]                              = "  /h presence all      - Demo (alle Typen)"
L["PRESENCE_H_PRESENCE_DEBUG_DUMP_STATE"]                             = "  /h presence debug    - Status im Chat ausgeben"
L["PRESENCE_H_PRESENCE_DEBUGLIVE_TOGGLE_LIVE"]                        = "  /h presence debuglive - Live-Debug-Panel umschalten"

-- =====================================================================
-- OptionsData.lua Vista — General
L["OPTIONS_VISTA_POSITION_LAYOUT"]                                    = "Position & Layout"

-- =====================================================================
L["OPTIONS_VISTA_MINIMAP"]                                            = "Minikarte"
L["OPTIONS_VISTA_MINIMAP_SIZE"]                                       = "Minikarten-Größe"
L["OPTIONS_VISTA_WIDTH_HEIGHT_OF_MINIMAP_PIXELS"]                     = "Breite und Höhe der Minikarte in Pixeln (100–400)."
L["OPTIONS_VISTA_CIRCULAR_MINIMAP"]                                   = "Runde Minikarte"
L["OPTIONS_VISTA_CIRCULAR_SHAPE"]                                     = "Runde Form"
L["OPTIONS_VISTA_A_CIRCULAR_MINIMAP_INSTEAD_OF_SQUARE"]               = "Runde Minikarte statt quadratisch verwenden."
L["OPTIONS_VISTA_LOCK_MINIMAP_POSITION"]                              = "Minikarten-Position sperren"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MINIMAP"]                           = "Minikarte nicht verschiebbar."
L["OPTIONS_VISTA_RESET_MINIMAP_POSITION"]                             = "Minikarten-Position zurücksetzen"
L["OPTIONS_VISTA_RESET_MINIMAP_DEFAULT_POSITION_TOP_RIGHT"]           = "Minikarte auf Standardposition (oben rechts) zurücksetzen."
-- L["OPTIONS_VISTA_RESET_OVERLAY_POSITIONS"]                         = "Reset overlay positions to defaults"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_RESET_OVERLAY_POSITIONS_DESC"]                       = "Clear saved positions for zone text, coordinates, clock, performance and difficulty text, zoom buttons, tracking, calendar, queue, mail, the addon button bar, drawer button, and right-click panel. The minimap frame position is not changed."
L["OPTIONS_VISTA_AUTO_ZOOM"]                                          = "Auto-Zoom"
L["OPTIONS_VISTA_AUTO_ZOOM_DELAY"]                                    = "Auto-Zoom-Out-Verzögerung"
L["OPTIONS_VISTA_SECONDS_AFTER_ZOOMING_BEFORE_AUTO_ZOOM"]             = "Sekunden nach Zoom bis Auto-Zoom-Out. 0 = deaktiviert."

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["OPTIONS_VISTA_ZONE_TEXT_HEADER"]                                   = "Zonentext"
L["OPTIONS_VISTA_ZONE_FONT"]                                          = "Zonenschriftart"
L["OPTIONS_VISTA_FONT_ZONE_NAME_BELOW_MINIMAP"]                       = "Schriftart für den Zonennamen unter der Minikarte."
L["OPTIONS_VISTA_ZONE_FONT_SIZE"]                                     = "Zonenschriftgröße"
L["OPTIONS_VISTA_ZONE_TEXT_COLOR"]                                    = "Zonentextfarbe"
L["OPTIONS_VISTA_COLOR_OF_ZONE_NAME_TEXT"]                            = "Farbe des Zonennamentexts."
L["OPTIONS_VISTA_COORDINATES_TEXT"]                                   = "Koordinatentext"
L["OPTIONS_VISTA_COORDINATES_FONT"]                                   = "Koordinatenschriftart"
L["OPTIONS_VISTA_FONT_COORDINATES_TEXT_BELOW_MINIMAP"]                = "Schriftart für den Koordinaten-Text unter der Minikarte."
L["OPTIONS_VISTA_COORDINATES_FONT_SIZE"]                              = "Koordinatenschriftgröße"
L["OPTIONS_VISTA_COORDINATES_TEXT_COLOR"]                             = "Koordinatentextfarbe"
L["OPTIONS_VISTA_COLOR_OF_COORDINATES_TEXT"]                          = "Farbe des Koordinatentexts."
L["OPTIONS_VISTA_COORDINATE_PRECISION"]                               = "Koordinatenpräzision"
L["OPTIONS_VISTA_NUMBER_OF_DECIMAL_PLACES_SHOWN_X"]                   = "Anzahl Dezimalstellen für X- und Y-Koordinaten."
L["OPTIONS_VISTA_COORDS_DECIMALS_OFF"]                                = "Keine Dezimalstellen (z.B. 52, 37)"
L["OPTIONS_VISTA_DECIMAL_E_G"]                                        = "1 Dezimalstelle (z.B. 52,3, 37,1)"
L["OPTIONS_VISTA_DECIMALS_E_G"]                                       = "2 Dezimalstellen (z.B. 52,34, 37,12)"
L["OPTIONS_VISTA_TEXT"]                                               = "Zeit-Text"
L["OPTIONS_VISTA_FONT"]                                               = "Zeit-Schriftart"
L["OPTIONS_VISTA_FONT_TEXT_BELOW_MINIMAP"]                            = "Schriftart für den Zeit-Text unter der Minikarte."
L["OPTIONS_VISTA_FONT_SIZE"]                                          = "Zeit-Schriftgröße"
L["OPTIONS_VISTA_TEXT_COLOR"]                                         = "Zeit-Textfarbe"
L["OPTIONS_VISTA_COLOR_OF_TEXT"]                                      = "Farbe des Zeit-Texts."
L["OPTIONS_VISTA_PERFORMANCE_TEXT"]                                   = "Performance-Text"
L["OPTIONS_VISTA_PERFORMANCE_FONT"]                                   = "Performance-Schriftart"
L["OPTIONS_VISTA_FONT_FPS_LATENCY_TEXT_BELOW_MINIMAP"]                = "Schriftart für FPS- und Latenz-Text unter der Minikarte."
L["OPTIONS_VISTA_PERFORMANCE_FONT_SIZE"]                              = "Performance-Schriftgröße"
L["OPTIONS_VISTA_PERFORMANCE_TEXT_COLOR"]                             = "Performance-Textfarbe"
L["OPTIONS_VISTA_COLOR_OF_FPS_LATENCY_TEXT"]                          = "Farbe des FPS- und Latenz-Texts."
L["OPTIONS_VISTA_DIFFICULTY_TEXT"]                                    = "Schwierigkeits-Text"
L["OPTIONS_VISTA_DIFFICULTY_TEXT_COLOR_FALLBACK"]                     = "Schwierigkeits-Textfarbe (Fallback)"
L["OPTIONS_VISTA_DEFAULT_COLOR_PER_DIFFICULTY_COLOR"]                 = "Standardfarbe für nicht gesetzte Schwierigkeitsfarben."
L["OPTIONS_VISTA_DIFFICULTY_FONT"]                                    = "Schwierigkeits-Schriftart"
L["OPTIONS_VISTA_FONT_INSTANCE_DIFFICULTY_TEXT"]                      = "Schriftart für den Instanz-Schwierigkeitstext."
L["OPTIONS_VISTA_DIFFICULTY_FONT_SIZE"]                               = "Schwierigkeits-Schriftgröße"
L["OPTIONS_VISTA_PER_DIFFICULTY_COLORS"]                              = "Farben pro Schwierigkeit"
L["OPTIONS_VISTA_MYTHIC_COLOR"]                                       = "Mythisch-Farbe"
L["OPTIONS_VISTA_COLOR_MYTHIC_DIFFICULTY_TEXT"]                       = "Farbe für Mythisch-Schwierigkeitstext."
L["OPTIONS_VISTA_HEROIC_COLOR"]                                       = "Heroisch-Farbe"
L["OPTIONS_VISTA_COLOR_HEROIC_DIFFICULTY_TEXT"]                       = "Farbe für Heroisch-Schwierigkeitstext."
L["OPTIONS_VISTA_NORMAL_COLOR"]                                       = "Normal-Farbe"
L["OPTIONS_VISTA_COLOR_NORMAL_DIFFICULTY_TEXT"]                       = "Farbe für Normal-Schwierigkeitstext."
L["OPTIONS_VISTA_LFR_COLOR"]                                          = "LFR-Farbe"
L["OPTIONS_VISTA_COLOR_LOOKING_RAID_DIFFICULTY_TEXT"]                 = "Farbe für Suche-nach-Schlachtzug-Text."

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["OPTIONS_VISTA_TEXT_ELEMENTS"]                                      = "Text-Elemente"
L["OPTIONS_VISTA_ZONE_TEXT"]                                          = "Zonentext anzeigen"
L["OPTIONS_VISTA_ZONE_NAME_BELOW_MINIMAP"]                            = "Zonennamen unter der Minikarte anzeigen."
L["OPTIONS_VISTA_ZONE_TEXT_DISPLAY_MODE"]                             = "Zonentext-Anzeigemodus"
L["OPTIONS_VISTA_WHAT_ZONE_SUBZONE"]                                  = "Was anzeigen: nur Zone, nur Unterzone oder beides."
L["OPTIONS_VISTA_ZONE"]                                               = "Nur Zone"
L["OPTIONS_VISTA_SUBZONE"]                                            = "Nur Unterzone"
L["OPTIONS_VISTA_BOTH"]                                               = "Beides"
L["OPTIONS_VISTA_COORDINATES"]                                        = "Koordinaten anzeigen"
L["OPTIONS_VISTA_PLAYER_COORDINATES_BELOW_MINIMAP"]                   = "Spielerkoordinaten unter der Minikarte anzeigen."
L["OPTIONS_VISTA_TIME"]                                               = "Zeit anzeigen"
L["OPTIONS_VISTA_CURRENT_GAME_BELOW_MINIMAP"]                         = "Aktuelle Spielzeit unter der Minikarte anzeigen."
L["OPTIONS_VISTA_HOUR_CLOCK"]                                         = "24-Stunden-Zeit"
L["OPTIONS_VISTA_DISPLAY_HOUR_FORMAT_E_G_INSTEAD"]                    = "Zeit im 24-Stunden-Format anzeigen (z.B. 14:30 statt 2:30 PM)."
L["OPTIONS_VISTA_LOCAL"]                                              = "Lokale Zeit verwenden"
L["OPTIONS_VISTA_YOUR_LOCAL_SYSTEM"]                                  = "An: lokale Systemzeit. Aus: Serverzeit."
L["OPTIONS_VISTA_FPS_LATENCY"]                                        = "FPS und Latenz anzeigen"
L["OPTIONS_VISTA_FPS_LATENCY_MS_BELOW_MINIMAP"]                       = "FPS und Latenz (ms) unter der Minikarte anzeigen."
L["OPTIONS_VISTA_MINIMAP_BUTTONS"]                                    = "Minikarten-Buttons"
L["OPTIONS_VISTA_QUEUE_STATUS_MAIL_INDICATOR_ALWAYS_SHOWN"]           = "Warteschlangen- und Post-Status werden bei Relevanz angezeigt."
L["OPTIONS_VISTA_TRACKING_BUTTON"]                                    = "Verfolgen-Button anzeigen"
L["OPTIONS_VISTA_MINIMAP_TRACKING_BUTTON"]                            = "Minikarten-Verfolgen-Button anzeigen."
L["OPTIONS_VISTA_TRACKING_BUTTON_MOUSEOVER"]                          = "Verfolgen-Button nur bei Mausüber"
L["OPTIONS_VISTA_HIDE_TRACKING_BUTTON_UNTIL_YOU_HOVER"]               = "Verfolgen-Button verbergen bis Maus über Minikarte."
L["OPTIONS_VISTA_CALENDAR_BUTTON"]                                    = "Kalender-Button anzeigen"
L["OPTIONS_VISTA_MINIMAP_CALENDAR_BUTTON"]                            = "Minikarten-Kalender-Button anzeigen."
L["OPTIONS_VISTA_CALENDAR_BUTTON_MOUSEOVER"]                          = "Kalender-Button nur bei Mausüber"
L["OPTIONS_VISTA_HIDE_CALENDAR_BUTTON_UNTIL_YOU_HOVER"]               = "Kalender-Button verbergen bis Maus über Minikarte."
L["OPTIONS_VISTA_ZOOM_BUTTONS"]                                       = "Zoom-Buttons anzeigen"
L["OPTIONS_VISTA_ZOOM_BUTTONS_MINIMAP"]                               = "Zoom-Buttons (+ und -) auf der Minikarte anzeigen."
L["OPTIONS_VISTA_ZOOM_BUTTONS_MOUSEOVER"]                             = "Zoom-Buttons nur bei Mausüber"
L["OPTIONS_VISTA_HIDE_ZOOM_BUTTONS_UNTIL_YOU_HOVER"]                  = "Zoom-Buttons verbergen bis Maus über Minikarte."

-- =====================================================================
-- OptionsData.lua Vista — Display (Border / Text Positions / Buttons)
-- =====================================================================
L["OPTIONS_VISTA_BORDER"]                                             = "Rahmen"
L["OPTIONS_VISTA_A_BORDER_AROUND_MINIMAP"]                            = "Rahmen um die Minikarte anzeigen."
L["OPTIONS_VISTA_BORDER_COLOR"]                                       = "Rahmenfarbe"
L["OPTIONS_VISTA_COLOR_OPACITY_OF_MINIMAP_BORDER"]                    = "Farbe (und Deckkraft) des Minikarten-Rahmens."
L["OPTIONS_VISTA_BORDER_THICKNESS"]                                   = "Rahmenstärke"
L["OPTIONS_VISTA_THICKNESS_OF_MINIMAP_BORDER_PIXELS"]                 = "Stärke des Minikarten-Rahmens in Pixeln (1–8)."
L["OPTIONS_VISTA_CLASS_COLOURS"]                                      = "Klassenfarben"
L["OPTIONS_VISTA_TINT_VISTA_BORDER_TEXT_COORDS_FPS"]                  = "Vista-Rahmen und Text (Koords, Zeit, FPS/MS) mit Klassenfarbe einfärben. Zahlen nutzen die konfigurierte Farbe."
L["OPTIONS_VISTA_TEXT_POSITIONS"]                                     = "Text-Positionen"
L["OPTIONS_VISTA_DRAG_TEXT_ELEMENTS_REPOSITION_LOCK_PREVEN"]          = "Textelemente ziehen zum Verschieben. Sperren verhindert versehentliche Bewegung."
L["OPTIONS_VISTA_LOCK_ZONE_TEXT_POSITION"]                            = "Zonentext-Position sperren"
L["OPTIONS_VISTA_ZONE_TEXT_CANNOT_DRAGGED"]                           = "An: Zonentext nicht verschiebbar."
L["OPTIONS_VISTA_LOCK_COORDINATES_POSITION"]                          = "Koordinaten-Position sperren"
L["OPTIONS_VISTA_COORDINATES_TEXT_CANNOT_DRAGGED"]                    = "An: Koordinaten-Text nicht verschiebbar."
L["OPTIONS_VISTA_LOCK_POSITION"]                                      = "Zeit-Position sperren"
L["OPTIONS_VISTA_TEXT_CANNOT_DRAGGED"]                                = "An: Zeit-Text nicht verschiebbar."
L["OPTIONS_VISTA_PERFORMANCE_TEXT_POSITION"]                          = "Position des Performance-Texts"
L["OPTIONS_VISTA_PLACE_FPS_LATENCY_TEXT_ABOVE_BELOW"]                 = "FPS/ Latenz-Text über oder unter der Minikarte platzieren."
L["OPTIONS_VISTA_LOCK_PERFORMANCE_TEXT_POSITION"]                     = "Position des Performance-Texts sperren"
L["OPTIONS_VISTA_FPS_LATENCY_TEXT_CANNOT_DRAGGED"]                    = "An: FPS/ Latenz-Text kann nicht gezogen werden."
L["OPTIONS_VISTA_LOCK_DIFFICULTY_TEXT_POSITION"]                      = "Schwierigkeits-Text-Position sperren"
L["OPTIONS_VISTA_DIFFICULTY_TEXT_CANNOT_DRAGGED"]                     = "An: Schwierigkeits-Text nicht verschiebbar."
L["OPTIONS_VISTA_BUTTON_POSITIONS"]                                   = "Button-Positionen"
L["OPTIONS_VISTA_DRAG_BUTTONS_REPOSITION_LOCK_PREVENT_MOVE"]          = "Buttons ziehen zum Verschieben. Sperren verhindert Bewegung."
L["OPTIONS_VISTA_LOCK_ZOOM_BUTTON"]                                   = "Vergrößern-Button sperren"
L["OPTIONS_VISTA_PREVENT_DRAGGING_ZOOM_BUTTON"]                       = "Vergrößern-Button nicht verschiebbar."
L["OPTIONS_VISTA_LOCK_ZOOM_OUT_BUTTON"]                               = "Verkleinern-Button sperren"
L["OPTIONS_VISTA_LOCK_ZOOM_OUT_DRAG"]                                 = "Verkleinern-Button nicht verschiebbar."
L["OPTIONS_VISTA_LOCK_TRACKING_BUTTON"]                               = "Verfolgen-Button sperren"
L["OPTIONS_VISTA_PREVENT_DRAGGING_TRACKING_BUTTON"]                   = "Verfolgen-Button nicht verschiebbar."
L["OPTIONS_VISTA_LOCK_CALENDAR_BUTTON"]                               = "Kalender-Button sperren"
L["OPTIONS_VISTA_PREVENT_DRAGGING_CALENDAR_BUTTON"]                   = "Kalender-Button nicht verschiebbar."
L["OPTIONS_VISTA_LOCK_QUEUE_BUTTON"]                                  = "Warteschlangen-Button sperren"
L["OPTIONS_VISTA_PREVENT_DRAGGING_QUEUE_STATUS_BUTTON"]               = "Warteschlangen-Button nicht verschiebbar."
L["OPTIONS_VISTA_LOCK_MAIL_INDICATOR"]                                = "Post-Symbol sperren"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MAIL_ICON"]                         = "Post-Symbol nicht verschiebbar."
L["OPTIONS_VISTA_DISABLE_QUEUE_HANDLING"]                             = "Warteschlangen-Verwaltung deaktivieren"
L["OPTIONS_VISTA_DISABLE_QUEUE_BUTTON_HANDLING"]                      = "Warteschlangen-Button-Verwaltung deaktivieren"
L["OPTIONS_VISTA_TURN_QUEUE_BUTTON_ANCHORING_ANOTHER_A"]              = "Alle Warteschlangen-Button-Ankerungen deaktivieren (wenn anderes Addon verwaltet)."
L["OPTIONS_VISTA_BUTTON_SIZES"]                                       = "Button-Größen"
L["OPTIONS_VISTA_ADJUST_SIZE_OF_MINIMAP_OVERLAY_BUTTONS"]             = "Größe der Minikarten-Overlay-Buttons anpassen."
L["OPTIONS_VISTA_TRACKING_BUTTON_SIZE"]                               = "Verfolgen-Button-Größe"
L["OPTIONS_VISTA_SIZE_OF_TRACKING_BUTTON_PIXELS"]                     = "Größe des Verfolgen-Buttons (Pixel)."
L["OPTIONS_VISTA_CALENDAR_BUTTON_SIZE"]                               = "Kalender-Button-Größe"
L["OPTIONS_VISTA_SIZE_OF_CALENDAR_BUTTON_PIXELS"]                     = "Größe des Kalender-Buttons (Pixel)."
L["OPTIONS_VISTA_QUEUE_BUTTON_SIZE"]                                  = "Warteschlangen-Button-Größe"
L["OPTIONS_VISTA_SIZE_OF_QUEUE_STATUS_BUTTON_PIXELS"]                 = "Größe des Warteschlangen-Buttons (Pixel)."
L["OPTIONS_VISTA_ZOOM_BUTTON_SIZE"]                                   = "Zoom-Button-Größe"
L["OPTIONS_VISTA_SIZE_OF_ZOOM_ZOOM_BUTTONS_PIXELS"]                   = "Größe der Zoom-Buttons (Pixel)."
L["OPTIONS_VISTA_MAIL_INDICATOR_SIZE"]                                = "Post-Symbol-Größe"
L["OPTIONS_VISTA_SIZE_OF_MAIL_ICON_PIXELS"]                           = "Größe des Post-Symbols (Pixel)."
L["OPTIONS_VISTA_ADDON_BUTTON_SIZE"]                                  = "Addon-Button-Größe"
L["OPTIONS_VISTA_SIZE_OF_COLLECTED_ADDON_MINIMAP_BUTTONS"]            = "Größe der gesammelten Addon-Minikarten-Buttons (Pixel)."

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
-- L["OPTIONS_VISTA_COLLECT_HORIZON_MINIMAP"]                         = "Include Horizon minimap icon"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_COLLECT_HORIZON_MINIMAP_DESC"]                    = "Put Horizon's own minimap icon in the managed addon bar, right-click panel, or drawer instead of leaving it on the minimap edge."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_ADDON_BUTTONS"]                                      = "Addon-Buttons"
L["OPTIONS_VISTA_MINIMAP_ADDON_BUTTONS"]                              = "Minikarten-Addon-Buttons"
L["OPTIONS_VISTA_BUTTON_MANAGEMENT"]                                  = "Button-Verwaltung"
L["OPTIONS_VISTA_MANAGE_ADDON_MINIMAP_BUTTONS"]                       = "Addon-Minikarten-Buttons verwalten"
L["OPTIONS_VISTA_VISTA_TAKES_CONTROL_OF_ADDON_MINIMAP"]               = "An: Vista übernimmt Addon-Minikarten-Buttons und gruppiert nach gewähltem Modus."
L["OPTIONS_VISTA_BUTTON_MODE"]                                        = "Button-Modus"
L["OPTIONS_VISTA_ADDON_BUTTONS_PRESENTED_HOVER_BAR_BELOW"]            = "Darstellung der Addon-Buttons: Mausüber-Leiste, Rechtsklick-Panel oder schwebender Schubladen-Button."
L["OPTIONS_VISTA_ALWAYS_BAR"]                                         = "Leiste immer anzeigen"
L["OPTIONS_VISTA_ALWAYS_MOUSEOVER_BAR_POSITIONING"]                   = "Mausüber-Leiste immer anzeigen (zum Positionieren)"
L["OPTIONS_VISTA_KEEP_MOUSEOVER_BAR_VISIBLE_TIMES_YOU"]               = "Mausüber-Leiste immer sichtbar für Positionierung. Deaktivieren wenn fertig."
L["OPTIONS_VISTA_DISABLE_DONE"]                                       = "Deaktivieren wenn fertig."
L["OPTIONS_VISTA_MOUSEOVER_BAR"]                                      = "Mausüber-Leiste"
L["OPTIONS_VISTA_RIGHT_CLICK_PANEL"]                                  = "Rechtsklick-Panel"
L["OPTIONS_VISTA_FLOATING_DRAWER"]                                    = "Schwebende Schublade"
L["OPTIONS_VISTA_LOCK_DRAWER_BUTTON_POSITION"]                        = "Schubladen-Button-Position sperren"
L["OPTIONS_VISTA_PREVENT_DRAGGING_FLOATING_DRAWER_BUTTON"]            = "Schubladen-Button nicht verschiebbar."
L["OPTIONS_VISTA_LOCK_MOUSEOVER_BAR_POSITION"]                        = "Mausüber-Leisten-Position sperren"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MOUSEOVER_BUTTON_BAR"]              = "Mausüber-Leiste nicht verschiebbar."
L["OPTIONS_VISTA_LOCK_RIGHT_CLICK_PANEL_POSITION"]                    = "Rechtsklick-Panel-Position sperren"
L["OPTIONS_VISTA_PREVENT_DRAGGING_RIGHT_CLICK_PANEL"]                 = "Rechtsklick-Panel nicht verschiebbar."
L["OPTIONS_VISTA_BUTTONS_PER_ROW_COLUMN"]                             = "Buttons pro Zeile/Spalte"
L["OPTIONS_VISTA_CONTROLS_MANY_BUTTONS_APPEAR_BEFORE_WRAPPING"]       = "Anzahl Buttons vor Umbruch. Links/Rechts = Spalten; Oben/Unten = Zeilen."
L["OPTIONS_VISTA_EXPAND_DIRECTION"]                                   = "Erweiterungsrichtung"
L["OPTIONS_VISTA_DIRECTION_BUTTONS_FILL_ANCHOR_POINT_LEFT"]           = "Richtung: Buttons füllen vom Anker. Links/Rechts = Zeilen; Oben/Unten = Spalten."
L["OPTIONS_VISTA_RIGHT"]                                              = "Rechts"
L["OPTIONS_VISTA_LEFT"]                                               = "Links"
L["OPTIONS_VISTA_DOWN"]                                               = "Unten"
L["OPTIONS_VISTA_UP"]                                                 = "Oben"
L["OPTIONS_VISTA_MOUSEOVER_BAR_APPEARANCE"]                           = "Mausüber-Leisten-Aussehen"
L["OPTIONS_VISTA_BACKGROUND_BORDER_MOUSEOVER_BUTTON_BAR"]             = "Hintergrund und Rahmen für die Mausüber-Button-Leiste."
L["OPTIONS_VISTA_BACKDROP_COLOR"]                                     = "Hintergrundfarbe"
L["OPTIONS_VISTA_BACKGROUND_COLOR_OF_MOUSEOVER_BUTTON_BAR"]           = "Hintergrundfarbe der Mausüber-Leiste (Alpha für Transparenz)."
L["OPTIONS_VISTA_BAR_BORDER"]                                         = "Leisten-Rahmen anzeigen"
L["OPTIONS_VISTA_A_BORDER_AROUND_MOUSEOVER_BUTTON_BAR"]               = "Rahmen um die Mausüber-Leiste anzeigen."
L["OPTIONS_VISTA_BAR_BORDER_COLOR"]                                   = "Leisten-Rahmenfarbe"
L["OPTIONS_VISTA_BORDER_COLOR_OF_MOUSEOVER_BUTTON_BAR"]               = "Rahmenfarbe der Mausüber-Leiste."
L["OPTIONS_VISTA_BAR_BACKGROUND_COLOR"]                               = "Leisten-Hintergrundfarbe"
L["OPTIONS_VISTA_PANEL_BACKGROUND_COLOR"]                             = "Panel-Hintergrundfarbe."
L["OPTIONS_VISTA_CLOSE_FADE_TIMING"]                                  = "Schließen / Einblend-Timing"
L["OPTIONS_VISTA_MOUSEOVER_BAR_CLOSE_DELAY_SECONDS"]                  = "Mausüber-Leiste — Schließ-Verzögerung (Sekunden)"
L["OPTIONS_VISTA_LONG_SECONDS_BAR_STAYS_VISIBLE_AFTER"]               = "Wie lange (Sekunden) die Leiste sichtbar bleibt nach Verlassen. 0 = sofortiges Ausblenden."
L["OPTIONS_VISTA_RIGHT_CLICK_PANEL_CLOSE_DELAY_SECONDS"]              = "Rechtsklick-Panel — Schließ-Verzögerung (Sekunden)"
L["OPTIONS_VISTA_LONG_SECONDS_PANEL_STAYS_OPEN_AFTER"]                = "Wie lange (Sekunden) das Panel offen bleibt nach Verlassen. 0 = nie automatisch schließen."
L["OPTIONS_VISTA_FLOATING_DRAWER_CLOSE_DELAY_SECONDS"]                = "Schwebende Schublade — Schließ-Verzögerung (Sekunden)"
L["OPTIONS_VISTA_DRAWER_CLOSE_DELAY"]                                 = "Schublade-Schließ-Verzögerung"
L["OPTIONS_VISTA_LONG_SECONDS_DRAWER_PANEL_STAYS_OPEN"]               = "Wie lange (Sekunden) die Schublade offen bleibt nach Wegklicken. 0 = nie automatisch schließen."
L["OPTIONS_VISTA_MAIL_ICON_BLINK"]                                    = "Post-Symbol blinken"
L["OPTIONS_VISTA_MAIL_ICON_PULSES_DRAW_ATTENTION"]                    = "An: Post-Symbol pulsiert. Aus: volle Deckkraft."
L["OPTIONS_VISTA_PANEL_APPEARANCE"]                                   = "Panel-Aussehen"
L["OPTIONS_VISTA_COLORS_DRAWER_RIGHT_CLICK_BUTTON_PANELS"]            = "Farben für Schublade und Rechtsklick-Panels."
L["OPTIONS_VISTA_PANEL_BG_COLOR_LABEL"]                               = "Panel-Hintergrundfarbe"
L["OPTIONS_VISTA_BACKGROUND_COLOR_OF_ADDON_BUTTON_PANELS"]            = "Hintergrundfarbe der Addon-Button-Panels."
L["OPTIONS_VISTA_PANEL_BORDER_COLOR"]                                 = "Panel-Rahmenfarbe"
L["OPTIONS_VISTA_BORDER_COLOR_OF_ADDON_BUTTON_PANELS"]                = "Rahmenfarbe der Addon-Button-Panels."
L["OPTIONS_VISTA_MANAGED_BUTTONS"]                                    = "Verwaltete Buttons"
L["OPTIONS_VISTA_BUTTON_COMPLETELY_IGNORED_A"]                        = "Aus: Dieser Button wird vom Addon ignoriert."
L["OPTIONS_VISTA_ADDON_BUTTONS_DETECTED"]                             = "(Noch keine Addon-Buttons erkannt)"
L["OPTIONS_VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE"]                      = "Sichtbare Buttons (zum Einbinden ankreuzen)"
L["OPTIONS_VISTA_ADDON_BUTTONS_DETECTED_OPEN_YOUR_MINIMAP"]           = "(Noch keine Addon-Buttons erkannt — öffnen Sie zuerst Ihre Minikarte)"

-- =====================================================================
-- Inline option / module strings (used in OptionsData / modules; symbolic migration)
-- =====================================================================

L["OPTIONS_CORE_HEROIC_DUNGEON"]                                      = "  Heroic dungeon"
L["OPTIONS_CORE_HEROIC_RAID"]                                         = "  Heroic raid"
L["OPTIONS_CORE_LFR"]                                                 = "  LFR"
L["OPTIONS_CORE_MYTHIC_DUNGEON"]                                      = "  Mythic dungeon"
L["OPTIONS_CORE_MYTHIC_RAID"]                                         = "  Mythic raid"
L["OPTIONS_CORE_MYTHIC_PLUS_DUNGEON"]                                 = "  Mythic+ dungeon"
L["OPTIONS_CORE_NORMAL_DUNGEON"]                                      = "  Normal dungeon"
L["OPTIONS_CORE_NORMAL_RAID"]                                         = "  Normal raid"
-- L["OPTIONS_CORE_ACHIEVEMENT_ICONS"]                                = "Achievement icons"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ACTIVE_INSTANCE"]                                  = "Active instance only"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ADJUST_FONT_SIZES_AMOUNT"]                         = "Adjust all font sizes by this amount."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ADJUST_FONTS_SIZES_CASING_DROP_SHADOWS"]           = "Adjust fonts, sizes, casing, and drop shadows."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_AFFIX_ICONS"]                                      = "Affix icons"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_AFFIX_TOOLTIPS"]                                   = "Affix tooltips"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_AFFECTS_SCENARIO_PROGRESS_TIMER_BARS"]             = "Also affects scenario progress and timer bars."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ALWAYS"]                                           = "Always show"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ALWAYS_M_TIMER"]                                   = "Always show M+ timer."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_AUTO_ADD_WQS_YOUR_CURRENT_ZONE"]                   = "Auto-add WQs in your current zone."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_AUTO_CLOSE_DELAY_DISABLE"]                         = "Auto-close delay (0 to disable)."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_AUTO_UNTRACK_FINISHED_ACTIVITIES"]                 = "Auto-untrack finished activities."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_BAR_UNDER_NUMERIC_OBJECTIVES_E_G"]                 = "Bar under numeric objectives (e.g. 3/250)."  -- NEEDS TRANSLATION
L["OPTIONS_CORE_BLIZZARD_DEFAULT_RONDOMEDIA_CLASS_ICON_DASHBO"]       = "Blizzard default or RondoMedia class icon on the Dashboard when Dashboard class colours are on. Independent of Insight tooltip class icons."
-- L["OPTIONS_CORE_BLOCK_POSITION"]                                   = "Block position"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_BOSS_EMOTES"]                                      = "Boss emotes"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_CHOICE_SLOTS"]                                     = "Choice slots"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_CHOOSE_WHICH_EVENTS_TRIGGER_SCREEN_ALERTS"]        = "Choose which events trigger on-screen alerts."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_CHOOSE_WHICH_SOUND_PLAY_A_RARE"]                   = "Choose which sound to play when a rare boss appears. Requires LibSharedMedia sounds to be installed for extra options."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_CLICK_BEHAVIOR"]                                   = "Click behavior"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_COLLECT_GROUP_ADDON_MINIMAP_BUTTONS"]              = "Collect and group addon minimap buttons."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_COLOR_REMAINING"]                                  = "Color by remaining time."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_COLOR_ZONE_TYPE"]                                  = "Color by zone type"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_COLOR_CONTESTED_ZONES_ORANGE_DEFAULT"]             = "Color for contested zones (orange by default)."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_COLOR_FRIENDLY_ZONES_GREEN_DEFAULT"]               = "Color for friendly zones (green by default)."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_COLOR_HOSTILE_ZONES_RED_DEFAULT"]                  = "Color for hostile zones (red by default)."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_COLOR_SANCTUARY_ZONES_BLUE_DEFAULT"]               = "Color for sanctuary zones (blue by default)."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_COLOR_OF_DIVIDER_LINES_BETWEEN_SECTIONS"]          = "Color of the divider lines between sections."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_COLOR_RECIPE_TITLES_OUTPUT_ITEM_RARITY"]           = "Color recipe titles by output item rarity."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_COLOR_ZONE_SUBZONE_TITLES_PVP_ZONE"]               = "Color zone/subzone titles by PvP zone type (friendly, hostile, contested, sanctuary). When off, uses the default category color."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_COMBAT_AFK_DND_PVP_PARTY_FRIENDS"]                 = "Combat, AFK, DND, PvP, party, friends, targeting."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_COMING_SOON"]                                      = "Coming Soon"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_COMPLETED_BOSS_STYLE"]                             = "Completed boss style"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_COMPLETED_COUNT"]                                  = "Completed count"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_CONFIGURE_CLICK_BEHAVIORS_TRACKING_RULES_TOMTOM"]  = "Configure click behaviors, tracking rules, and TomTom integration."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_CONFIGURE_MINIMAP_S_SHAPE_SIZE_POSITION"]          = "Configure the minimap's shape, size, position, and text overlays."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_CONTESTED_ZONE_COLOR"]                             = "Contested zone color"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_CONTROL_TRACKER_VISIBILITY_WITHIN_DUNGEONS_RAIDS"] = "Control tracker visibility within dungeons, raids, and PvP."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SETTINGS_PRESENCE_NOTIFICATION_FRAMEWORK"]         = "Core settings for the Presence notification framework."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_CRAFTABLE_COUNT"]                                  = "Craftable count"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_CTRL_LEFT_FOCUS_ADD_CTRL_RIGHT"]                   = "Ctrl+Left = focus/add, Ctrl+Right = unfocus/untrack."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_CURRENT_ZONE_GROUP"]                               = "Current Zone group"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_CURRENT_ZONE"]                                     = "Current zone only"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_CUSTOMIZE_BORDERS_COLORS_POSITIONING_OF_SPECIFI"]  = "Customize borders, colors, and the positioning of specific minimap elements."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_CUSTOMIZE_VISUAL_INTERFACE_LAYOUT_ELEMENTS"]       = "Customize the visual interface and layout elements."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_DASHBOARD_CLASS_ICON_STYLE"]                       = "Dashboard class icon style"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_DECOR_ICONS"]                                      = "Decor icons"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_DEDICATED_SECTION_COMPLETED_QUESTS"]               = "Dedicated section for completed quests."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_DEDICATED_SECTION_ZONE_QUESTS"]                    = "Dedicated section for in-zone quests."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_DEFEATED_BOSS_STYLE"]                              = "Defeated boss style."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_DESATURATE_FOCUSED_ENTRIES"]                       = "Desaturate non-focused entries."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_DESATURATE_FOCUSED_QUESTS"]                        = "Desaturate non-focused quests"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_DIM_ALPHA"]                                        = "Dim alpha"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_DIM_STRENGTH"]                                     = "Dim strength"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_DIM_UNFOCUSED_TRACKER_ENTRIES"]                    = "Dim unfocused tracker entries."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_DIMMING_STRENGTH"]                                 = "Dimming strength (0-100%)."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_DISPLAY_COMPLETED_OBJECTIVES"]                     = "Display completed objectives."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ENABLE_BLACKLIST_UNTRACKED_INTERACTIONS_ADD_QUEST"]= "Enable 'Blacklist untracked' in Interactions to add quests here."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ENABLE_M_BLOCK"]                                   = "Enable M+ block"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ENEMY_FORCES_COLOR"]                               = "Enemy forces color"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ENEMY_FORCES_SIZE"]                                = "Enemy forces size"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ENHANCE_PLAYER_ITEM_TOOLTIPS_EXTRA_DETAILS"]       = "Enhance player and item tooltips with extra details like Mythic+ score and transmog status."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ENTRY_NUMBERS"]                                    = "Entry numbers"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ENTRY_SPACING"]                                    = "Entry spacing"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_EXPAND_DIRECTION_ANCHOR"]                          = "Expand direction from anchor."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_FADE_HOVERING"]                                    = "Fade out when not hovering."  -- NEEDS TRANSLATION
-- L["FOCUS_FINISHING_REAGENTS"]                                      = "Finishing reagents"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_ANIMATIONS"]                                      = "Focus animations"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_FONT_SIZE_BAR_LABEL_BAR_HEIGHT"]                   = "Font size for bar label and bar height."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_FONTS_SIZES_COLORS_PRESENCE_NOTIFICATIONS"]        = "Fonts, sizes, and colors for Presence notifications."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_WORLD_QUESTS_WEEKLIES_YOUR_QUEST_LOG"]             = "For world quests and weeklies not in your quest log."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_FRIENDLY_ZONE_COLOR"]                              = "Friendly zone color"  -- NEEDS TRANSLATION
L["OPTIONS_CORE_GROUPING"]                                            = "Gruppierung"
-- L["OPTIONS_CORE_GROUPS_SELECTED_LAYOUT_MODE_BELOW"]                = "Groups them by the selected layout mode below."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_GUILD_RANK"]                                       = "Guild rank"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_HEADER_DIVIDER"]                                   = "Header divider"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_HIDE_UNTRACKED_QUESTS_UNTIL_RELOAD"]               = "Hide untracked quests until reload."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_HIDE_ZONE_NOTIFICATIONS_MYTHIC"]                   = "Hide zone notifications in Mythic+."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_HIDES_CATEGORIES_WHILE_A_DELVE_PARTY"]             = "Hides other categories while in a Delve or party dungeon."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_HINT_LIST_SCROLLABLE"]                             = "Hint when the list is scrollable."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_HONOR_LEVEL"]                                      = "Honor level"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_HOSTILE_ZONE_COLOR"]                               = "Hostile zone color"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_MUCH_DIM_FOCUSED_ENTRIES_DIMMING_FU"]              = "How much to dim non-focused entries (0 = no dimming, 100 = fully darkened). Default 40%."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ICON_NEXT_ACHIEVEMENT_TITLE"]                      = "Icon next to achievement title."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ICON_NEXT_AUTO_TRACKED_ZONE_ENTRIES"]              = "Icon next to auto-tracked in-zone entries."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ARENA"]                                            = "In arena"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_BATTLEGROUND"]                                     = "In battleground"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_DUNGEON"]                                          = "In dungeon"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_RAID"]                                             = "In raid"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ZONE_WORLD_QUESTS"]                                = "In-zone world quests"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_INCLUDE_COMPLETED"]                                = "Include completed"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_INSTANCE_SUPPRESSION"]                             = "Instance suppression"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ITEM_LEVEL"]                                       = "Item level"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ITEM_SOURCE"]                                      = "Item source"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_KEEP_BAR_VISIBLE_REPOSITIONING"]                   = "Keep bar visible for repositioning."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_KEEP_CAMPAIGN_CATEGORY"]                           = "Keep campaign in category"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_KEEP_HEADER_BOTTOM_TOP_UNTIL_COLLAPSED"]           = "Keep header at bottom, or top until collapsed."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_KEEP_IMPORTANT_CATEGORY"]                          = "Keep important in category"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_KEEP_CAMPAIGN_READY_TURN"]                         = "Keep in Campaign when ready to turn in."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_KEEP_IMPORTANT_READY_TURN"]                        = "Keep in Important when ready to turn in."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED"]           = "Keep section headers visible when collapsed."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_L_CLICK_OPENS_MAP_R_CLICK"]                        = "L-click opens map, R-click opens menu."  -- NEEDS TRANSLATION
-- L["PRESENCE_LEVEL_UP_TOGGLE"]                                      = "Level up"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_LOCK_DRAWER_BUTTON"]                               = "Lock drawer button"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_LOCK_ITEM_POSITION"]                               = "Lock item position"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_LOCK_MINIMAP"]                                     = "Lock minimap"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_LOCK_MOUSEOVER_BAR"]                               = "Lock mouseover bar"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_LOCK_RIGHT_CLICK_PANEL"]                           = "Lock right-click panel"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_MAIL_ICON_PULSE"]                                  = "Mail icon pulse"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_MAKE_FOCUSED_ENTRIES_GREYSCALE_PARTIALLY_DESATURATE"]= "Make non-focused entries greyscale/partially desaturated in addition to dimming."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_MANAGE_ADDON_BUTTONS"]                             = "Manage addon buttons"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_MANAGE_ORGANIZE_MINIMAP_ICONS_ADDONS_INT"]         = "Manage and organize minimap icons from other addons into a tidy drawer or bar."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_MANAGE_SWITCH_BETWEEN_YOUR_ADDON_CONFIGURATIONS"]  = "Manage and switch between your addon configurations."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_MATCH_BAR_QUEST_CATEGORY_COLOR"]                   = "Match bar to quest category color."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_APPEAR_FULL_TRACKER_REPLACEMENTS"]                 = "May not appear with full tracker replacements."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_MINIMAL_MODE"]                                     = "Minimal mode"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_MISSING_CRITERIA"]                                 = "Missing criteria only"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_MOUNT_INFO"]                                       = "Mount info"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_MOUNT_NAME_SOURCE_COLLECTION_STATUS"]              = "Mount name, source, and collection status."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_MOUSEOVER_CLOSE_DELAY"]                            = "Mouseover close delay"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_MOUSEOVER"]                                        = "Mouseover only"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_MOVE_COMPLETED_QUESTS_BOTTOM_OF_CURRENT"]          = "Move completed quests to the bottom of the Current Zone section."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_MYTHIC_BLOCK"]                                     = "Mythic+ Block"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_MYTHIC_COLORS"]                                    = "Mythic+ Colors"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_MYTHIC_SCORE"]                                     = "Mythic+ score"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_DEFAULT"]                                          = "New from Default"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_HIDDEN_QUESTS"]                                    = "No hidden quests."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_NOTIFY_ACHIEVEMENT_CRITERIA_UPDATE"]               = "Notify on achievement criteria update."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_OBJECTIVE_PROGRESS"]                               = "Objective progress"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_OBJECTIVE_SPACING"]                                = "Objective spacing"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_L_CLICK_FOCUSES_R_CLICK_UNTRACKS"]                 = "Off: L-click focuses, R-click untracks. Ctrl+Right shares."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_PROGRESS_TRACKED_ACHIEVEMENTS_SHOWN"]              = "Off: only in-progress tracked achievements shown."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TRACKED_NEARBY_WQS_APPEAR_BLIZZARD_DEFAULT"]       = "Off: only tracked or nearby WQs appear (Blizzard default)."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_BOSS_EMOTES_ACHIEVEMENTS_LEVEL_HIDES_ZONE"]        = "Only boss emotes, achievements, and level-up. Hides zone, quest, and scenario notifications in Mythic+."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ENTRIES_A_SINGLE_NUMERIC_OBJECTIVE_WHERE"]         = "Only for entries with a single numeric objective where required > 1."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_QUESTS_DON_T_NEED_NPC_TURN"]                       = "Only for quests that don't need NPC turn-in. Off = Blizzard default."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_INCOMPLETE_CRITERIA"]                              = "Only show incomplete criteria."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SUBZONE_NAME_WITHIN_SAME_ZONE"]                    = "Only show subzone name within same zone."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]               = "Opacity of focused quest highlight (0–100%)."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_OPACITY_OF_UNFOCUSED_ENTRIES"]                     = "Opacity of unfocused entries."  -- NEEDS TRANSLATION
-- L["FOCUS_OPTIONAL_REAGENTS"]                                       = "Optional reagents"  -- NEEDS TRANSLATION
-- L["FOCUS_RECIPE_REAGENTS_FULL_DETAIL"]                             = "Full reagent detail"  -- NEEDS TRANSLATION
-- L["FOCUS_RECIPE_REAGENTS_FULL_DETAIL_DESC"]                        = "List every schematic slot: optional and finishing sections, choice groups with all variants, and non-Basic reagents. When off, only Basic slots use the first reagent per slot (compact shopping-style list)."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_OPTIONS_BUTTON"]                                   = "Options button"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ORGANIZE_HIDE_TRACKED_ENTRIES_YOUR_PREFERENCE"]    = "Organize and hide tracked entries to your preference."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_OVERRIDE_FONT_PER_ELEMENT"]                        = "Override font per element."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_PANEL_BACKGROUND_OPACITY"]                         = "Panel background opacity (0–100%)."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_PERMANENTLY_HIDE_UNTRACKED_QUESTS"]                = "Permanently hide untracked quests."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_PERSONALIZE_COLOR_PALETTE_TRACKER_TEXT_ELEMENTS"]  = "Personalize the color palette for tracker text elements."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_POSITIONING_VISIBILITY_CACHE_LOOT_TOAST_SYS"]      = "Positioning and visibility for the Cache loot toast system."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_PREVENT_ACCIDENTAL_CLICKS"]                        = "Prevent accidental clicks."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_QUALITY_INFO"]                                     = "Quality info"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_QUEST_ACCEPT"]                                     = "Quest accept"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_QUEST_COMPLETE"]                                   = "Quest complete"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_QUEST_COUNT"]                                      = "Quest count"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_QUEST_ITEM_BUTTONS"]                               = "Quest item buttons"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_QUEST_LEVEL"]                                      = "Quest level"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_QUEST_PROGRESS"]                                   = "Quest progress"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_QUEST_PROGRESS_BAR"]                               = "Quest progress bar"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_QUEST_TRACKING"]                                   = "Quest tracking"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_QUEST_TYPE_ICONS"]                                 = "Quest type icons"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_QUEST_TYPE_ICON_SIZE"]                            = "Quest type icon size"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_QUEST_TYPE_ICON_SIZE_DESC"]                       = "Pixel size of the quest type icon shown in the left gutter (default 16)."  -- NEEDS TRANSLATION
-- L["PRESENCE_RARE_DEFEATED"]                                        = "RARE DEFEATED"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_RARE_ADDED_SOUND_CHOICE"]                          = "Rare added sound choice"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_RARE_SOUND_ALERT"]                                 = "Rare sound alert"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_RARITY_COLORS"]                                    = "Rarity colors"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_READY_TURN_GROUP"]                                 = "Ready to Turn In group"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_READY_TURN_BOTTOM"]                                = "Ready to turn in at bottom"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_REAGENTS"]                                         = "Reagents"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_RECIPE_ICONS"]                                     = "Recipe icons"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_RECIPES"]                                          = "Recipes"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_REDUCE_OPACITY_OF_FOCUSED_ENTRIES_INVISIBLE"]      = "Reduce opacity of non-focused entries (0 = invisible, 100 = fully opaque). Default 100% (no alpha change)."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_REQUIRE_CTRL_COMPLETE_CLICK_COMPLETABLE_QUESTS"]   = "Require Ctrl to complete click-completable quests."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_REQUIREMENTS"]                                     = "Requirements"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_REQUIRES_QUEST_TYPE_ICONS_ENABLED_DISPLAY"]        = "Requires quest type icons to be enabled in Display."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_RESET_MYTHIC_STYLING"]                             = "Reset Mythic+ styling"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_REVIEW_MANAGE_QUESTS_YOU_MANUALLY_UNTRACKED"]      = "Review and manage quests you have manually untracked or blacklisted."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_RIGHT_CLICK_CLOSE_DELAY"]                          = "Right-click close delay"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SANCTUARY_ZONE_COLOR"]                             = "Sanctuary zone color"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SCALE_UI_ELEMENTS"]                                = "Scale all UI elements (50–200%)."  -- NEEDS TRANSLATION
-- L["PRESENCE_SCENARIO_COMPLETE"]                                    = "Scenario Complete"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SCENARIO_EVENTS"]                                  = "Scenario events"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SCENARIO_PROGRESS"]                                = "Scenario progress"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SCENARIO_PROGRESS_BAR"]                            = "Scenario progress bar"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SCENARIO_START"]                                   = "Scenario start"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SCENARIO_TIMER_BAR"]                               = "Scenario timer bar"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SCROLL_INDICATOR"]                                 = "Scroll indicator"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SECONDS_OF_RECENT_PROGRESS"]                       = "Seconds of recent progress to show."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SECTION_DIVIDER_COLOR"]                            = "Section divider color"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SECTION_HEADERS"]                                  = "Section headers"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SECTIONS_COLLAPSED"]                               = "Sections when collapsed"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SEPARATE_SCALE_SLIDER_PER_MODULE"]                 = "Separate scale slider per module."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SHADOW_OPACITY"]                                   = "Shadow opacity (0–100%)."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_A_VISUAL_DIVIDER_LINE_BETWEEN_FOCUS"]              = "Show a visual divider line between Focus sections to make categories easier to distinguish."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_AFFIX_NAMES_FIRST_DELVE_ENTRY"]                    = "Show affix names on first Delve entry."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_COLLAPSIBLE_CHOICE_REAGENT_SLOTS"]                 = "Show collapsible choice reagent slots."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_COMPLETED_ACHIEVEMENTS_LIST"]                      = "Show completed achievements in the list."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_FINISHING_REAGENT_SLOTS"]                          = "Show finishing reagent slots."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_MANY_TIMES_RECIPE_CRAFTED"]                        = "Show how many times the recipe can be crafted."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_NORMAL_DUNGEONS"]                                  = "Show in Normal dungeons."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_LOCAL_SYSTEM"]                                     = "Show local system time."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_NOTIFICATION_A_RARE_MOB_DEFEATED_NEARBY"]          = "Show notification when a rare mob is defeated nearby."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_NOTIFICATION_A_SCENARIO_DELVE_FULLY_COM"]          = "Show notification when a scenario or Delve is fully completed."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_OBJECTIVE_LINE"]                                   = "Show objective line only."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_HOVER"]                                            = "Show only on hover."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ACTIVE_INSTANCE_SECTION"]                          = "Show only the active instance section."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_OPTIONAL_REAGENT_SLOTS"]                           = "Show optional reagent slots."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_QUALITY_TIER_PIPS_RECIPES_SUPPORT_QUALITI"]        = "Show quality tier pips for recipes that support qualities."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_REAGENT_SHOPPING_LIST_RECIPE"]                     = "Show reagent shopping list for each recipe."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_RECENT_PROGRESS_TOP"]                              = "Show recent progress at the top."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_RECIPE_ICON_NEXT_TITLE_REQUIRES_QUEST"]            = "Show recipe icon next to title. Requires quest type icons in Display."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SECTION_DIVIDERS"]                                 = "Show section dividers"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]              = "Show the M+ block whenever an active keystone is running."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TRACKED_PROFESSION_RECIPES_LIST"]                  = "Show tracked profession recipes in the list."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TRACKER_HEROIC_DUNGEONS_UNSET_MAS"]                = "Show tracker in Heroic dungeons. When unset, uses the master dungeon toggle."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TRACKER_HEROIC_RAIDS_UNSET_MASTER"]                = "Show tracker in Heroic raids. When unset, uses the master raid toggle."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TRACKER_LOOKING_RAID_UNSET_MA"]                    = "Show tracker in Looking for Raid. When unset, uses the master raid toggle."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TRACKER_MYTHIC_KEYSTONE_M_DUNGEONS_UNSET"]         = "Show tracker in Mythic Keystone (M+) dungeons. When unset, uses the master dungeon toggle."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TRACKER_MYTHIC_DUNGEONS_UNSET_MAS"]                = "Show tracker in Mythic dungeons. When unset, uses the master dungeon toggle."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TRACKER_MYTHIC_RAIDS_UNSET_MASTER"]                = "Show tracker in Mythic raids. When unset, uses the master raid toggle."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TRACKER_NORMAL_DUNGEONS_UNSET_MAS"]                = "Show tracker in Normal dungeons. When unset, uses the master dungeon toggle."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TRACKER_NORMAL_RAIDS_UNSET_MASTER"]                = "Show tracker in Normal raids. When unset, uses the master raid toggle."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TRACKER_PARTY_DUNGEONS_MASTER_TOGGLE_DU"]          = "Show tracker in party dungeons (master toggle for all dungeon difficulties)."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TRACKER_RAIDS_MASTER_TOGGLE_RAID_DIFFIC"]          = "Show tracker in raids (master toggle for all raid difficulties)."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_UNMET_CRAFTING_STATION_REQUIREMENTS"]              = "Show unmet crafting station requirements."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SHOWN_HOVERING_A_MOUNTED_PLAYER"]                  = "Shown when hovering a mounted player."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SIZE_SHAPE"]                                       = "Size & shape"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SIZE_OF_ZOOM_BUTTONS_PIXELS"]                      = "Size of the + and - zoom buttons (pixels)."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SORT_MODE"]                                        = "Sort mode"  -- NEEDS TRANSLATION
L["OPTIONS_CORE_SORTING_FILTERING"]                                   = "Sortierung & Filterung"
-- L["OPTIONS_CORE_SOUND_PLAYED_A_RARE_BOSS_APPEARS"]                 = "Sound played when a rare boss appears."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_STATUS_BADGES"]                                    = "Status badges"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SUBZONE_CHANGES"]                                  = "Subzone changes"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SUPER_TRACKED_FIRST_CURRENT_ZONE_FIRST"]           = "Super-tracked first, or current zone first."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SUPPRESS_IN_ARENA_DETAIL"]                         = "Suppress all Presence notifications while inside a PvP arena."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SUPPRESS_PRESENCE_NOTIFICATIONS_WHILE_INSIDE_A"]   = "Suppress all Presence notifications while inside a battleground."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SUPPRESS_IN_DUNGEON_DETAIL"]                       = "Suppress all Presence notifications while inside a dungeon (except boss emotes, achievements, level-up)."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SUPPRESS_IN_RAID_DETAIL"]                          = "Suppress all Presence notifications while inside a raid."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SUPPRESS_M"]                                       = "Suppress in M+"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SUPPRESS_PVP"]                                     = "Suppress in PvP"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SUPPRESS_BATTLEGROUND"]                            = "Suppress in battleground"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SUPPRESS_DUNGEON"]                                 = "Suppress in dungeon"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SUPPRESS_RAID"]                                    = "Suppress in raid"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_SUPPRESS_NOTIFICATIONS_DUNGEONS"]                  = "Suppress notifications in dungeons."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TAKES_PRIORITY_SUPPRESS_UNTIL_RELOAD_ACCEPTING"]   = "Takes priority over suppress-until-reload. Accepting removes from blacklist."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TOAST_ICONS"]                                      = "Toast icons"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TOGGLE_TRACKING_WORLD_QUESTS_RARES_ACHIEVEMENTS"]  = "Toggle tracking for world quests, rares, achievements, and more."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TOMTOM"]                                           = "TomTom"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TOOLTIP_ANCHOR"]                                   = "Tooltip anchor"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TRACKED_OBJECTIVES_ADVENTURE_GUIDE"]               = "Tracked objectives from Adventure Guide."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TRACKED_VS_LOG_COUNT"]                             = "Tracked vs in-log count."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TRACKED_LOG_LOG_MAX_TRACKED_EXCLUDES"]             = "Tracked/in-log or in-log/max. Tracked excludes world and in-zone quests."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TRANSMOG_STATUS"]                                  = "Transmog status"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TRAVELER_S_LOG"]                                   = "Traveler's Log"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TUNE_SLIDE_FADE_EFFECTS_PLUS_OBJECTIVE"]           = "Tune slide and fade effects, plus objective progress flashes."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_UNBLOCK"]                                          = "Unblock"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_UNTRACK_COMPLETE"]                                 = "Untrack when complete"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_CHECKMARK_COMPLETED_OBJECTIVES"]                   = "Use checkmark for completed objectives."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_VISIBILITY_FADING"]                                = "Visibility & fading"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_COMPLETED_QUESTS_STAY_THEIR_ORIGINAL_CATEGO"]      = "When off, completed quests stay in their original category."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ZONE_QUESTS_APPEAR_THEIR_NORMAL_CATEGORY"]         = "When off, in-zone quests appear in their normal category."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_THEY_MOVE_COMPLETE_SECTION"]                       = "When off, they move to the Complete section."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_CUSTOM_FILL_COLOR_BELOW"]                          = "When off, uses the custom fill color below."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_COMPLETED_OBJECTIVES_COLOR_BELOW"]                 = "When on, completed objectives use the color below."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_WHERE_COUNTDOWN"]                                  = "Where to show the countdown."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_WORLD_QUEST_ACCEPT"]                               = "World quest accept"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_WORLD_QUEST_COMPLETE"]                             = "World quest complete"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]           = "X/Y: objectives like 3/10. Percent: objectives like 45%%."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ZONE_ENTRY"]                                       = "Zone entry"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ZONE_LABELS"]                                      = "Zone labels"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ZONE_NAME_STILL_APPEARS_ENTERING_A"]               = "Zone name still appears when entering a new zone."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ZONE_TYPE_COLORING"]                               = "Zone type coloring"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TINTERFACE_BUTTONS_UI_CHECKBOX_CHECK_T"]           = "|TInterface\\\\Buttons\\\\UI-CheckBox-Check:12:12:0:0|t instead of green for done objectives."  -- NEEDS TRANSLATION































































































