if GetLocale() ~= "frFR" then return end

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = setmetatable({}, { __index = addon.L })
addon.L = L
addon.StandardFont = UNIT_NAME_FONT

-- =====================================================================
-- OptionsPanel.lua (deprecated) — remaining strings for that UI
-- Panel title + module short names: addon.BrandDisplay (core/BrandDisplay.lua).
-- =====================================================================
L["OPTIONS_FOCUS_OTHER"]                                              = "Autres"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["OPTIONS_FOCUS_QUEST_TYPES"]                                        = "Types de quêtes"
L["OPTIONS_FOCUS_ELEMENT_OVERRIDES"]                                  = "Couleurs par élément"
L["OPTIONS_FOCUS_PER_CATEGORY"]                                       = "Couleurs par catégorie"
L["OPTIONS_FOCUS_GROUPING_OVERRIDES"]                                 = "Couleurs personnalisées"
L["OPTIONS_FOCUS_SECTION_OVERRIDES"]                                  = "Couleurs de section"
L["OPTIONS_FOCUS_COLORS"]                                             = "Autres couleurs"

-- =====================================================================
-- OptionsPanel.lua — Color row labels (collapsible group sub-rows)
-- =====================================================================
-- L["OPTIONS_FOCUS_SECTION"]                                         = "Section"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_TITLE"]                                              = "Titre"
-- L["OPTIONS_FOCUS_ZONE"]                                            = "Zone"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_OBJECTIVE"]                                          = "Objectif"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["OPTIONS_FOCUS_READY_TURN_OVERRIDES_BASE_COLOURS"]                  = "Choisir des couleurs différentes pour la section À Rendre"
L["OPTIONS_FOCUS_READY_TURN_COLOURS_QUESTS"]                          = "La section À Rendre utilisera ses propres couleurs."
L["OPTIONS_FOCUS_CURRENT_ZONE_OVERRIDES_BASE_COLOURS"]                = "Choisir des couleurs différentes pour la section Zone Actuelle"
L["OPTIONS_FOCUS_CURRENT_ZONE_COLOURS_QUESTS_SEC"]                    = "La section Zone Actuelle utilisera ses propres couleurs."
L["OPTIONS_FOCUS_CURRENT_QUEST_OVERRIDES_BASE_COLOURS"]               = "Choisir des couleurs différentes pour la section Quête actuelle"
L["OPTIONS_FOCUS_CURRENT_QUEST_COLOURS_QUESTS_SE"]                    = "La section En Cours utilisera ses propres couleurs."
L["OPTIONS_FOCUS_DISTINCT_COLOR_COMPLETED_OBJECTIVES"]                = "Utiliser une couleur distincte pour les objectifs terminés"
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES_E_G_COLOR_B"]                   = "Activé : les objectifs terminés (ex. 1/1) utilisent la couleur suivante. Désactivé : ils utilisent la même couleur que les objectifs incomplets."
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVE"]                                = "Objectif terminé"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["OPTIONS_FOCUS_RESET"]                                              = "Réinitialiser"
L["OPTIONS_FOCUS_RESET_QUEST_TYPES"]                                  = "Réinitialiser les types de quêtes"
L["OPTIONS_FOCUS_RESET_OVERRIDES"]                                    = "Réinitialiser les couleurs personnalisées"
L["OPTIONS_FOCUS_RESET_DEFAULTS"]                                     = "Tout réinitialiser aux valeurs par défaut"
L["OPTIONS_FOCUS_RESET_TO_DEFAULTS"]                                  = "Réinitialiser les valeurs par défaut"
L["OPTIONS_FOCUS_RESET_DEFAULT"]                                      = "Réinitialiser la valeur par défaut"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["OPTIONS_FOCUS_SEARCH_SETTINGS"]                                    = "Recherche..."
L["OPTIONS_FOCUS_SEARCH_FONTS"]                                       = "Rechercher une police..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["OPTIONS_FOCUS_DRAG_RESIZE"]                                        = "Glisser pour redimensionner"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
L["OPTIONS_AXIS_PROFILES"]                                            = "Profils"
-- L["OPTIONS_AXIS_MODULES"]                                          = "Modules"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_MODULE_TOGGLES"]                                   = "Module Toggles"  -- NEEDS TRANSLATION

-- =====================================================================
-- options/dashboard/HomeWelcome.lua — First-run welcome
-- =====================================================================
-- L["DASH_WHATS_NEW"]                                                = "Patch Notes"  -- NEEDS TRANSLATION
L["DASH_FULL_CHANGELOG"]                                              = "Full changelog"
-- L["DASH_WHATS_NEW_UNREAD_SUFFIX"]                                  = " (New!)"  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_TAB"]                                              = "Welcome"  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_TITLE"]                                            = "Welcome to Horizon Suite"  -- NEEDS TRANSLATION
L["DASH_WELCOME_HEAD_SUB"]                                            = "What each module does and where to turn them on"
L["DASH_WELCOME_INTRO"]                                               = "Horizon Suite is modular — enable only the pieces you want. Turning a module on or off applies on reload. Expand Contributors or Localisations below for credits and supported languages. Use Open module toggles under Modules, or open Axis, then Modules, in the sidebar. You can return to this Welcome page anytime from the sidebar."
L["DASH_WELCOME_PATH"]                                                = "%s → %s → %s"
-- L["DASH_WELCOME_FOCUS_BLIZZARD_PLUS_HEADING"]                      = "Blizzard+ click profile"  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_FOCUS_BLIZZARD_PLUS_BODY"]                         = [=[Focus now uses |cffffffffBlizzard+|r by default — Blizzard-style quest row clicks with a few Horizon conveniences. Open |cffaaaaaaFocus > Interactions|r and use |cffaaaaaaClick profile|r to see the preset; |cffffffffHorizon+|r and full |cffffffffCustom|r shortcuts are on the way.]=]  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_COMING_SOON_TITLE"]                                = "Coming Soon"  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_COMING_SOON_TAGLINE"]                              = "New welcome experiences are on the way."  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_COMING_SOON_BODY"]                                 = [=[Watch this space — we will post updates here and in |cffaaaaaaPatch Notes|r. Join |cffaaaaaaDiscord|r from the links below for news and feedback.]=]  -- NEEDS TRANSLATION
L["DASH_WELCOME_CLASS_ICONS_HEADING"]                                 = "Horizon class icons"
L["DASH_WELCOME_CLASS_ICONS_LEAD"]                                    = [=[We have added a bundled set of custom class icons — now the default when you choose |cffaaaaaaHorizon|r under |cffaaaaaaAxis → Global Toggles|r (Class icon style).]=]
-- L["DASH_WELCOME_CLASS_ICONS_THANK_BOOFULS"]                        = [=[Thank you, Boofuls, for commissioning this art and helping bring these icons to everyone.]=]  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_CLASS_ICONS_CREATED_PREFIX"]                       = "• Created by "  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_CLASS_ICONS_ARTIST_NAME"]                          = "Gabriel C"  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_CONTRIBUTORS_HEADING"]                             = "Contributors"  -- NEEDS TRANSLATION
L["DASH_WELCOME_CONTRIBUTORS_BODY"]                                   = [=[Thanks to everyone who has contributed to Horizon Suite:  -- NEEDS TRANSLATION

• feanor21#2847 — Panoramuxa (Tarren Mill - EU) — Development
• Marthix — Development
• Swift — Coordinator
• Boofuls — Moderator
• RondoFerrari — RondoMedia (CurseForge addon) — Class icons in Insight tooltips and optional Dashboard header icon when class colors are on (optional)
• Aishuu — French localisation (frFR)
• 아즈샤라-두녘 — Korean localisation (koKR)
• Linho-Gallywix — Brazilian Portuguese localisation (ptBR)
• allmoon — Chinese localisation (zhCN)]=]
-- L["DASH_WELCOME_LOCALISATIONS_HEADING"]                            = "Localisations"  -- NEEDS TRANSLATION
L["DASH_WELCOME_LOCALISATIONS_BODY"]                                  = [=[The options panel is localised for:

• Chinese (zhCN) — Localisation/zhCN.lua
• French (frFR) — Localisation/frFR.lua
• German (deDE) — Localisation/deDE.lua
• Korean (koKR) — Localisation/koKR.lua
• Brazilian Portuguese (ptBR) — Localisation/ptBR.lua
• Russian (ruRU) — Localisation/ruRU.lua
• Spanish (esES) — Localisation/esES.lua

Contributions for additional locales are welcome via Discord.]=]


-- =====================================================================
-- options/dashboard/ModuleGuide.lua — In-game module quick-start
-- =====================================================================
L["DASH_GUIDE_TAB"]                                                   = "Guide"
-- L["DASH_GUIDE_HEAD_SUB"]                                           = "What each part of Horizon does"  -- NEEDS TRANSLATION
-- L["DASH_GUIDE_HERO_TITLE"]                                         = "Getting started with Horizon Suite"  -- NEEDS TRANSLATION
-- L["DASH_GUIDE_HERO_TAGLINE"]                                       = "A modular UI toolkit for quests, notifications, the minimap, and more."  -- NEEDS TRANSLATION
L["DASH_GUIDE_HERO_INTRO"]                                            = "Pick the modules you want, tune them in the sidebar, and reload when you toggle something on or off. This page is always here — open it anytime from the Guide row under Welcome."
-- L["DASH_GUIDE_QUICK_START_HEADING"]                                = "Quick start"  -- NEEDS TRANSLATION
L["DASH_GUIDE_QUICK_START_BODY"]                                      = [=[• Under |cffaaaaaaAxis → Modules|r in the sidebar, turn each module on or off. Changing modules applies after a |cffaaaaaaReload UI|r.
-- • Under |cffaaaaaaAxis → Global Toggles|r, set class-colour tinting for the dashboard and modules, pick a |cffaaaaaaDashboard background|r preset, and adjust |cffaaaaaaUI scale|r (global or per module).]=]
-- L["DASH_GUIDE_HORIZON_HEADING"]                                    = "What is Horizon Suite?"  -- NEEDS TRANSLATION
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
-- L["DASH_GUIDE_MOD_MERIDIAN_BODY"]                                  = "Coming soon."  -- NEEDS TRANSLATION
-- L["DASH_AXIS_MODULE_SHORT_DESCRIPTION"]                            = "Core settings hub: profiles, modules, and global toggles."  -- NEEDS TRANSLATION
-- L["DASH_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS"]                    = "Objective tracker for quests, world quests, rares, achievements, scenarios."  -- NEEDS TRANSLATION
-- L["DASH_ZONE_TEXT_AND_NOTIFICATIONS"]                              = "Zone text and notifications."  -- NEEDS TRANSLATION
-- L["DASH_MINIMAP_ZONE_TEXT_COORDS_BUTTON"]                          = "Minimap with zone text, coords, time, and button collector."  -- NEEDS TRANSLATION
-- L["DASH_TOOLTIPS_CLASS_COLORS_SPEC_FACTION"]                       = "Tooltips with class colors, spec, and faction icons."  -- NEEDS TRANSLATION
-- L["DASH_LOOT_TOASTS_ITEMS_MONEY_CURRENCY"]                         = "Loot toasts for items, money, currency, reputation, and bag overhaul."  -- NEEDS TRANSLATION
-- L["DASH_ESSENCE_MODULE_SHORT_DESCRIPTION"]                         = "Custom character sheet with 3D model, item level, stats, and gear grid."  -- NEEDS TRANSLATION
-- L["DASH_MERIDIAN_MODULE_SHORT_DESCRIPTION"]                        = "Coming soon."  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_COMMUNITY_HEADING"]                                = "Community & Support"  -- NEEDS TRANSLATION
-- L["DASH_DISCORD"]                                                  = "Discord"  -- NEEDS TRANSLATION
-- L["DASH_KO_FI"]                                                    = "Ko-fi"  -- NEEDS TRANSLATION
-- L["DASH_PATREON"]                                                  = "Patreon"  -- NEEDS TRANSLATION
-- L["DASH_GITLAB"]                                                   = "GitLab"  -- NEEDS TRANSLATION
-- L["DASH_CURSEFORGE"]                                               = "CurseForge"  -- NEEDS TRANSLATION
-- L["DASH_WAGO"]                                                     = "Wago"  -- NEEDS TRANSLATION
-- L["DASH_COPY_LINK_X"]                                              = "Copy link — %s"  -- NEEDS TRANSLATION
L["DASH_LAYOUT"]                                                      = "Disposition"
L["DASH_VISIBILITY"]                                                  = "Visibilité"
L["DASH_DISPLAY"]                                                     = "Affichage"
L["DASH_FEATURES"]                                                    = "Fonctionnalités"
L["DASH_TYPOGRAPHY"]                                                  = "Textes"
L["DASH_APPEARANCE"]                                                  = "Apparence"
L["DASH_COLORS"]                                                      = "Couleurs"
L["DASH_ORGANIZATION"]                                                = "Organisation"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["OPTIONS_FOCUS_PANEL_BEHAVIOUR"]                                    = "Comportement du panneau"
-- L["OPTIONS_FOCUS_DIMENSIONS"]                                      = "Dimensions"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_INSTANCE"]                                        = "Instance"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_INSTANCES"]                                       = "Instances"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_COMBAT"]                                          = "Combat"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_FILTERING"]                                          = "Filtres"
L["OPTIONS_FOCUS_HEADER"]                                             = "En-tête"
-- L["OPTIONS_FOCUS_SECTIONS_STRUCTURE"]                              = "Sections & structure"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_ENTRY_DETAILS"]                                      = "Détails de l'élément"
L["OPTIONS_FOCUS_PROGRESS_TIMERS"]                                    = "Progressions & décomptes"
L["OPTIONS_FOCUS_EMPHASIS"]                                           = "Mise en évidence"
L["OPTIONS_FOCUS_LIST"]                                               = "Liste"
L["OPTIONS_FOCUS_SPACING"]                                            = "Espacement"
L["OPTIONS_FOCUS_RARE_BOSSES"]                                        = "Boss rares"
L["OPTIONS_FOCUS_WORLD_QUESTS"]                                       = "Expéditions"
L["OPTIONS_FOCUS_FLOATING_QUEST_ITEM"]                                = "Objet de quête flottant"
L["OPTIONS_FOCUS_MYTHIC"]                                             = "Mythique+"
L["OPTIONS_FOCUS_ACHIEVEMENTS"]                                       = "Hauts faits"
L["OPTIONS_FOCUS_ENDEAVORS"]                                          = "Initiatives"
L["OPTIONS_FOCUS_DECOR"]                                              = "Décoration"
-- L["OPTIONS_FOCUS_APPEARANCES"]                                     = "Appearances"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_SCENARIO_DELVE"]                                     = "Scénario et Gouffre"
L["OPTIONS_FOCUS_FONT"]                                               = "Police"
L["OPTIONS_FOCUS_FONT_FAMILIES"]                                      = "Familles de polices"
L["OPTIONS_FOCUS_GLOBAL_FONT_SIZE"]                                   = "Taille du texte global"
L["OPTIONS_FOCUS_FONT_SIZES"]                                         = "Tailles des textes"
L["OPTIONS_FOCUS_PER_ELEMENT_FONTS"]                                  = "Polices par élément"
L["OPTIONS_FOCUS_TEXT_CASE"]                                          = "Casse"
L["OPTIONS_FOCUS_SHADOW"]                                             = "Ombre"
L["OPTIONS_FOCUS_PANEL"]                                              = "Panneau"
L["OPTIONS_FOCUS_HIGHLIGHT"]                                          = "Surbrillance"
L["OPTIONS_FOCUS_COLOR_MATRIX"]                                       = "Matrice de couleurs"
L["OPTIONS_FOCUS_ORDER"]                                              = "Ordre"
L["OPTIONS_FOCUS_SORT"]                                               = "Tri"
L["OPTIONS_FOCUS_BEHAVIOUR"]                                          = "Comportement"
L["OPTIONS_FOCUS_CONTENT_TYPES"]                                      = "Types de contenu"
L["OPTIONS_FOCUS_DELVES"]                                             = "Gouffres"
L["OPTIONS_FOCUS_DELVES_DUNGEONS"]                                    = "Gouffres & Donjons"
L["OPTIONS_FOCUS_DELVE_COMPLETE"]                                     = "Gouffre terminé"
-- L["OPTIONS_FOCUS_INTERACTIONS"]                                    = "Interactions"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_TRACKING"]                                           = "Suivi"
L["OPTIONS_FOCUS_SCENARIO_BAR"]                                       = "Barre de scénario"

-- =====================================================================
-- OptionsData.lua Profiles
-- =====================================================================
-- L["OPTIONS_AXIS_CURRENT_PROFILE"]                                  = "Current profile"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_SELECT_PROFILE_CURRENTLY"]                         = "Select the profile currently in use."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_GLOBAL_PROFILE_ACCOUNT_WIDE"]                      = "Use global profile (account-wide)"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_CHARACTERS_SAME_PROFILE"]                          = "All characters use the same profile."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_ENABLE_PER_SPECIALIZATION_PROFILES"]               = "Enable per specialization profiles"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_PICK_DIFFERENT_PROFILES_PER_SPEC"]                 = "Pick different profiles per spec."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_SPECIALIZATION"]                                   = "Specialization"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_SHARING"]                                          = "Sharing"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_IMPORT_PROFILE"]                                   = "Import profile"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_IMPORT_STRING"]                                    = "Import string"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_EXPORT_PROFILE"]                                   = "Export profile"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_SELECT_A_PROFILE_EXPORT"]                          = "Select a profile to export."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_EXPORT_STRING"]                                    = "Export string"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_COPY_PROFILE"]                                     = "Copy from profile"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_SOURCE_PROFILE_COPYING"]                           = "Source profile for copying."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_COPY_SELECTED"]                                    = "Copy from selected"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_CREATE"]                                           = "Create"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_CREATE_PROFILE_DEFAULT_TEMPLATE"]                  = "Create new profile from Default template"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_CREATES_A_PROFILE_DEFAULT_SETTINGS"]               = "Creates a new profile with all default settings."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_CREATES_A_PROFILE_COPIED_SELECTED_SOURC"]          = "Creates a new profile copied from the selected source profile."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_DELETE_PROFILE"]                                   = "Delete profile"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_SELECT_A_PROFILE_DELETE_CURRENT_DEFAULT"]          = "Select a profile to delete (current and Default not shown)."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_DELETE_SELECTED"]                                  = "Delete selected"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_DELETE_SELECTED_PROFILE"]                          = "Delete selected profile"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_DELETE"]                                           = "Delete"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_DELETES_SELECTED_PROFILE"]                         = "Deletes the selected profile."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_GLOBAL_PROFILE"]                                   = "Global profile"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_PER_SPEC_PROFILES"]                                = "Per-spec profiles"  -- NEEDS TRANSLATION

-- =====================================================================
-- OptionsData.lua Modules
-- =====================================================================
L["OPTIONS_AXIS_ENABLE_FOCUS_MODULE"]                                 = "Activer le module Focus"
L["OPTIONS_AXIS_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS_R"]             = "Affiche le suivi des objectifs pour les quêtes, expéditions, boss rares, hauts faits et scénarios."
L["OPTIONS_AXIS_ENABLE_PRESENCE_MODULE"]                              = "Activer le module Presence"
L["OPTIONS_AXIS_CINEMATIC_ZONE_TEXT_NOTIFICATIONS_ZONE_CHANGES"]      = "Texte de zone cinématique et notifications (changement de zone, montée de niveau, emotes de boss, hauts faits, mises à jour de quêtes)."
L["OPTIONS_AXIS_ENABLE_CACHE_MODULE"]                                 = "Activer le module Cache"
L["OPTIONS_AXIS_CINEMATIC_LOOT_NOTIFICATIONS_ITEMS_MONEY_CURRENCY"]   = "Alertes cinématiques de butin (objets, argent, monnaies, réputation)."
L["OPTIONS_AXIS_ENABLE_VISTA_MODULE"]                                 = "Activer le module Vista"
L["OPTIONS_AXIS_CINEMATIC_SQUARE_MINIMAP_ZONE_TEXT_COORDINATES"]      = "Minicarte carrée cinématique avec texte de zone, coordonnées et rubrique à boutons."
L["OPTIONS_AXIS_MINIMAP_ZONE_TIME_COLLECTOR"]                         = "Minicarte carrée cinématique avec texte de zone, coordonnées, horloge et conteneur de boutons."
-- L["OPTIONS_AXIS_BETA"]                                             = "Beta"  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_SCALING"]                                             = "Mise à l'échelle"
L["OPTIONS_AXIS_GLOBAL_TOGGLES"]                                      = "Réglages globaux"
-- L["OPTIONS_AXIS_PATCH_NOTES_SECTION"]                              = "Patch notes"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN"]                   = "Show Patch Notes automatically after an update"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN_DESC"]              = "When on, Axis opens to Patch Notes once after each new addon version. When off, a green dot appears on the Horizon minimap icon until you open Patch Notes."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_SUITE_WIDE_CLASS_COLOUR_TINTING_UI"]                  = "Teintes de couleur de classe et échelle d'interface pour toute la suite (globale ou par module)."
L["OPTIONS_AXIS_GLOBAL_UI_SCALE"]                                     = "Échelle globale de l'interface"
L["OPTIONS_AXIS_SCALE_SIZES_SPACINGS_FONTS_FACTOR"]                   = "Met à l'échelle toutes les tailles, espacements et polices selon ce facteur (50–200 %). Ne modifie pas vos valeurs configurées."
L["OPTIONS_AXIS_PER_MODULE_SCALING"]                                  = "Échelle par module"
L["OPTIONS_AXIS_OVERRIDE_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_FO"]         = "Remplace l'échelle globale par des curseurs individuels pour chaque module."
L["OPTIONS_AXIS_OVERRIDES_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_F"]         = "Utiliser des glissières d'échelle individuelles pour les modules Focus, Presence, Vista, etc."
L["OPTIONS_AXIS_DOESN_T_CHANGE_YOUR_CONFIGURED_VALUES"]               = "Ne change pas vos valeurs de réglages, seulement la mise à l'échelle de l'interface."
L["OPTIONS_FOCUS_SCALE"]                                              = "Échelle Focus"
L["OPTIONS_AXIS_SCALE_FOCUS_OBJECTIVE_TRACKER"]                       = "Échelle du suivi d'objectifs Focus (50–200 %)."
L["OPTIONS_PRESENCE_SCALE"]                                           = "Échelle Presence"
L["OPTIONS_AXIS_SCALE_PRESENCE_CINEMATIC_TEXT"]                       = "Échelle du texte cinématique Presence (50–200 %)."
L["OPTIONS_VISTA_SCALE"]                                              = "Échelle Vista"
L["OPTIONS_AXIS_SCALE_VISTA_MINIMAP_MODULE"]                          = "Échelle du module de minicarte Vista (50–200 %)."
L["OPTIONS_INSIGHT_SCALE"]                                            = "Échelle Insight"
L["OPTIONS_AXIS_SCALE_INSIGHT_TOOLTIP_MODULE"]                        = "Échelle du module d'infobulle Insight (50–200 %)."
L["OPTIONS_CACHE_SCALE"]                                              = "Échelle Cache"
L["OPTIONS_AXIS_SCALE_CACHE_LOOT_TOAST_MODULE"]                       = "Échelle du module d'alerte de butin Cache (50–200 %)."
L["OPTIONS_AXIS_ENABLE_HORIZON_INSIGHT_MODULE"]                       = "Activer le module Horizon Insight"
L["OPTIONS_AXIS_CINEMATIC_TOOLTIPS_CLASS_COLORS_SPEC_DISPLAY"]        = "Infobulles cinématiques avec couleurs de classe, spécialisation et icônes de faction."
L["OPTIONS_AXIS_TOOLTIP_ANCHOR_MODE"]                                 = "Mode d'ancrage des infobulles"
L["OPTIONS_AXIS_WHERE_TOOLTIPS_APPEAR_FOLLOW_CURSOR_FIXED"]           = "Où les infobulles s'affichent : suivre le curseur ou position fixe."
L["OPTIONS_AXIS_CURSOR"]                                              = "Curseur"
L["OPTIONS_AXIS_FIXED"]                                               = "Fixe"
L["OPTIONS_AXIS_ANCHOR_MOVE"]                                         = "Afficher les poignées de déplacement"
L["OPTIONS_AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITIO"]                      = "Cliquer pour montrer ou cacher l'ancre. Glisser pour positionner, clic droit pour confirmer."
L["OPTIONS_AXIS_DRAGGABLE_FRAME_FIXED_TOOLTIP_POSITION_D"]            = "Affiche un cadre déplaçable pour définir la position fixe. Glisser, puis clic droit pour confirmer."
L["OPTIONS_AXIS_RESET_TOOLTIP_POSITION"]                              = "Réinitialiser la position des infobulles"
L["OPTIONS_AXIS_RESET_FIXED_POSITION_DEFAULT"]                        = "Réinitialiser la position fixe par défaut."
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_X"]                               = "Cursor offset X"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_X_DESC"]                          = "Horizontal pixel offset from the default cursor tooltip position (cursor anchor only)."  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_Y"]                               = "Cursor offset Y"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_Y_DESC"]                          = "Vertical pixel offset from the default cursor tooltip position (cursor anchor only)."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_TOOLTIP_BACKGROUND_COLOR"]                            = "Couleur de fond des infobulles"
L["OPTIONS_AXIS_COLOR_OF_TOOLTIP_BACKGROUND"]                         = "Couleur de fond des infobulles."
L["OPTIONS_AXIS_TOOLTIP_BACKGROUND_OPACITY"]                          = "Opacité du fond des infobulles"
L["OPTIONS_AXIS_TOOLTIP_BG_OPACITY_PCT_DESC"]                         = "Opacité du fond des infobulles (0–100 %)."
L["OPTIONS_AXIS_TOOLTIP_FONT"]                                        = "Police de l'infobulle"
L["OPTIONS_AXIS_FONT_FAMILY_TOOLTIP_TEXT"]                            = "Famille de police utilisée pour le texte de l'infobulle."
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
L["OPTIONS_AXIS_TOOLTIPS"]                                            = "Infobulles"
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
L["OPTIONS_AXIS_ITEM_TOOLTIP"]                                        = "Description d'objet"
L["OPTIONS_AXIS_TRANSMOG_STATUS"]                                     = "Afficher l'état de transmogrification"
L["OPTIONS_AXIS_WHETHER_YOU_COLLECTED_APPEARANCE_OF_AN"]              = "Montrer si l'apparence de l'objet a déjà été collecté."
L["OPTIONS_AXIS_PLAYER_TOOLTIP"]                                      = "Infobulle du joueur"
L["OPTIONS_AXIS_GUILD_RANK"]                                          = "Montrer le rang de guilde"
L["OPTIONS_AXIS_APPEND_PLAYER_S_GUILD_RANK_NEXT"]                     = "Ajouter le rang de la guilde du joueur à la suite de son nom."
L["OPTIONS_AXIS_MYTHIC_SCORE"]                                        = "Montrer le score Mythique+"
L["OPTIONS_AXIS_PLAYER_S_CURRENT_SEASON_MYTHIC_SCORE"]                = "Montrer le score Mythique+ de la saison actuelle du joueur, coloré par palier."
L["OPTIONS_AXIS_ITEM_LEVEL"]                                          = "Montrer le niveau d'objet"
L["OPTIONS_AXIS_PLAYER_S_EQUIPPED_ITEM_LEVEL_AFTER"]                  = "Affiche le niveau d'objet du joueur après l'avoir inspecté."
L["OPTIONS_AXIS_HONOR_LEVEL"]                                         = "Montrer l'honneur"
L["OPTIONS_AXIS_PLAYER_S_PVP_HONOR_LEVEL_TOOLTIP"]                    = "Affiche le niveau d'honneur du joueur dans l'infobulle."
L["OPTIONS_AXIS_PVP_TITLE"]                                           = "Montrer le titre PvP"
L["OPTIONS_AXIS_PLAYER_S_PVP_TITLE_E_G"]                              = "Affiche le titre PvP du joueur (ex: Gladiateur) dans l'infobulle."
L["OPTIONS_AXIS_CHARACTER_TITLE"]                                     = "Titre du personnage"
L["OPTIONS_AXIS_PLAYER_S_SELECTED_TITLE_ACHIEVEMENT_PVP"]             = "Affiche le titre (haut fait ou PvP) à la suite du nom du personnage."
L["OPTIONS_AXIS_TITLE_COLOR"]                                         = "Couleur du titre"
L["OPTIONS_AXIS_COLOR_OF_CHARACTER_TITLE_PLAYER_TOOLTIP"]             = "Couleur du titre sur la ligne du nom du joueur."
L["OPTIONS_AXIS_STATUS_BADGES"]                                       = "Montrer les badges de statut"
L["OPTIONS_AXIS_INLINE_BADGES_COMBAT_AFK_DND_PVP"]                    = "Affiche les différents badges de combat, ABS, NPD, PvP, présence en groupe/raid, amis, ou si le joueur vous cible."
L["OPTIONS_AXIS_MOUNT_INFO"]                                          = "Montrer les informations de monture"
L["OPTIONS_AXIS_HOVERING_A_MOUNTED_PLAYER_THEIR_MOUNT"]               = "Au survol d'un joueur, affiche le nom de sa monture, sa source, et si vous la possédez."
L["OPTIONS_AXIS_BLANK_SEPARATOR"]                                     = "Séparateur vide"
L["OPTIONS_AXIS_A_BLANK_LINE_INSTEAD_OF_DASHES"]                      = "Utilise un séparateur vide à la place des tirets entre les différentes sections de l'infobulle."
L["OPTIONS_AXIS_ICONS"]                                               = "Montrer les icones"
L["OPTIONS_AXIS_CLASS_ICON_STYLE"]                                    = "Style des icones de classe"
L["OPTIONS_AXIS_DEFAULT_BLIZZARD_RONDOMEDIA_CLASS_ICONS_TH"]          = "Utilise les icônes de classe par défaut (Blizzard) ou celles de RondoMedia sur la ligne de la classe/spé."
L["OPTIONS_AXIS_CUSTOM_CLASS_ICONS_LABEL"]                            = "Custom (addon media)"
L["OPTIONS_AXIS_CLASS_ICON_SOURCES_TOOLTIP"]                          = "RondoMedia: https://www.curseforge.com/wow/addons/rondomedia — Custom: place one .tga per class under media/CustomClassIcons/<CLASS>/<class lower>.tga (e.g. WARRIOR/warrior.tga), then /reload."
L["OPTIONS_AXIS_RONDOMEDIA_CLASS_ICONS_RONDOFERRARI_HTTPS_WWW"]       = "Icones de classes créées par RondoFerrari — https://www.curseforge.com/wow/addons/rondomedia"
L["OPTIONS_AXIS_DEFAULT"]                                             = "Par défaut"
L["OPTIONS_AXIS_FACTION_SPEC_MOUNT_MYTHIC_ICONS_TOOLTIPS"]            = "SMontrer la faction, la spécialisation, la monture et les icônes de Mythique+ dans les infobulles."
L["OPTIONS_AXIS_GENERAL"]                                             = "Général"
-- L["OPTIONS_AXIS_POSITION"]                                         = "Position"  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_RESET_POSITION"]                                      = "Réinitialiser la position"
L["OPTIONS_AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"]                   = "Réinitialiser la position des alertes de butin."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["OPTIONS_FOCUS_LOCK_POSITION"]                                      = "Verrouiller la position"
L["OPTIONS_FOCUS_PREVENT_DRAGGING_TRACKER"]                           = "Empêche de déplacer le panneau d'objectifs."
L["OPTIONS_FOCUS_GROW_UPWARD"]                                        = "Croissance vers le haut"
L["OPTIONS_FOCUS_GROW_HEADER"]                                        = "En-tête croissance"
L["OPTIONS_FOCUS_GROWING_UPWARD_KEEP_HEADER_BOTTOM_TOP"]              = "En croissance vers le haut : garder l'en-tête en bas ou en haut jusqu'au repli."
L["OPTIONS_FOCUS_HEADER_BOTTOM"]                                      = "En-tête en bas"
L["OPTIONS_FOCUS_HEADER_SLIDES_COLLAPSE"]                             = "En-tête glisse au repli"
L["OPTIONS_FOCUS_ANCHOR_BOTTOM_LIST_GROWS_UPWARD"]                    = "Ancré en bas pour que la liste s'agrandisse vers le haut."
L["OPTIONS_FOCUS_START_COLLAPSED"]                                    = "Replié par défaut"
L["OPTIONS_FOCUS_START_HEADER_SHOWN_UNTIL_YOU_EXPAND"]                = "N'afficher que l'en-tête par défaut jusqu'au déploiement."
L["OPTIONS_FOCUS_ALIGN_CONTENT_RIGHT"]                                = "Aligner le contenu à droite"
L["OPTIONS_FOCUS_RIGHT_ALIGN_QUEST_TITLES_OBJECTIVES_WITHIN"]         = "Le titre des quêtes les objectifs s'ajustent sur le coté droit du panneau de suivi."
L["OPTIONS_FOCUS_PANEL_WIDTH"]                                        = "Largeur du panneau"
L["OPTIONS_FOCUS_TRACKER_WIDTH_PIXELS"]                               = "Largeur du panneau d'objectifs en pixels."
L["OPTIONS_FOCUS_MAX_CONTENT_HEIGHT"]                                 = "Hauteur max du contenu"
L["OPTIONS_FOCUS_MAX_HEIGHT_OF_SCROLLABLE_LIST_PIXELS"]               = "Hauteur maximale de la liste défilable (pixels)."

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["OPTIONS_FOCUS_ALWAYS_M_BLOCK"]                                     = "Toujours afficher le bloc M+"
L["OPTIONS_FOCUS_M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]                = "Affiche le bloc M+ dès qu'une clé Mythique est active."
L["OPTIONS_FOCUS_DUNGEON"]                                            = "Afficher en Donjon"
L["OPTIONS_FOCUS_TRACKER_PARTY_DUNGEONS"]                             = "Affiche le panneau d'objectifs dans les donjons."
L["OPTIONS_FOCUS_RAID"]                                               = "Afficher en Raid"
L["OPTIONS_FOCUS_TRACKER_RAIDS"]                                      = "Affiche le panneau d'objectifs dans les raids."
L["OPTIONS_FOCUS_BATTLEGROUND"]                                       = "Afficher en Champ de bataille"
L["OPTIONS_FOCUS_TRACKER_BATTLEGROUNDS"]                              = "Affiche le panneau d'objectifs en champs de bataille."
L["OPTIONS_FOCUS_ARENA"]                                              = "Afficher en Arène"
L["OPTIONS_FOCUS_TRACKER_ARENAS"]                                     = "Affiche le panneau d'objectifs en arène."
L["OPTIONS_FOCUS_HIDE_COMBAT"]                                        = "Masquer en combat"
L["OPTIONS_FOCUS_HIDE_TRACKER_FLOATING_QUEST_ITEM_COMBAT"]            = "Masque le panneau d'objectifs et les objets de quête flottants en combat."
L["OPTIONS_FOCUS_COMBAT_VISIBILITY"]                                  = "Visibilité en combat"
L["OPTIONS_FOCUS_TRACKER_BEHAVES_COMBAT_FADE_REDUC"]                  = "Comportement du panneau en combat : afficher, estomper ou masquer."
L["OPTIONS_FOCUS_SHOW"]                                               = "Afficher"
L["OPTIONS_FOCUS_FADE"]                                               = "Estomper"
L["OPTIONS_FOCUS_HIDE"]                                               = "Masquer"
L["OPTIONS_FOCUS_COMBAT_FADE_OPACITY"]                                = "Opacité en combat (estomper)"
L["OPTIONS_FOCUS_VISIBLE_TRACKER_FADED_COMBAT"]                       = "Visibilité du panneau quand estompé en combat (0 = invisible). S'applique uniquement quand la visibilité en combat est « Estomper »."
L["OPTIONS_FOCUS_MOUSEOVER"]                                          = "Survol"
L["OPTIONS_FOCUS_SHOW_ONLY_MOUSEOVER"]                                = "Afficher au survol uniquement"
L["OPTIONS_FOCUS_FADE_TRACKER_HOVERING_MOVE_MOUSE"]                   = "Estompe le panneau quand la souris n'est pas dessus ; survolez pour l'afficher."
L["OPTIONS_FOCUS_FADED_OPACITY"]                                      = "Opacité estompée"
L["OPTIONS_FOCUS_VISIBLE_TRACKER_FADED_INVISIBLE"]                    = "Visibilité du panneau quand estompé (0 = invisible)."
L["OPTIONS_FOCUS_QUESTS_CURRENT_ZONE"]                                = "Quêtes de la Zone Actuelle uniquement"
L["OPTIONS_FOCUS_HIDE_QUESTS_OUTSIDE_YOUR_CURRENT_ZONE"]              = "Masque les quêtes hors de la Zone Actuelle."

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["OPTIONS_FOCUS_QUEST_COUNT"]                                        = "Afficher le nombre de quêtes"
L["OPTIONS_FOCUS_QUEST_COUNT_HEADER"]                                 = "Affiche le nombre de quêtes dans l'en-tête."
L["OPTIONS_FOCUS_HEADER_COUNT_FORMAT"]                                = "Format du compteur de quêtes"
L["OPTIONS_FOCUS_TRACKED_LOG_LOG_MAX_SLOTS_TRACKED"]                  = "Suivies/Dans le journal ou Dans le journal/Quêtes max. Les quêtes suivies ne prennent pas en compte les expéditions et les objectifs de zone bonus."
L["OPTIONS_FOCUS_HEADER_DIVIDER"]                                     = "Afficher le séparateur d'en-tête"
L["OPTIONS_FOCUS_LINE_BELOW_HEADER"]                                  = "Affiche la ligne sous l'en-tête."
L["OPTIONS_FOCUS_HEADER_DIVIDER_COLOR"]                               = "Couleur du séparateur d'en-tête"
L["OPTIONS_FOCUS_COLOR_OF_LINE_BELOW_HEADER"]                         = "Couleur de la ligne sous l'en-tête."
L["OPTIONS_FOCUS_SUPER_MINIMAL_MODE"]                                 = "Mode Super-minimal"
L["OPTIONS_FOCUS_HIDE_HEADER_A_PURE_TEXT_LIST"]                       = "Masque l'en-tête pour une liste de texte simple."
L["OPTIONS_FOCUS_OPTIONS_BUTTON"]                                     = "Afficher le bouton Options"
L["OPTIONS_FOCUS_OPTIONS_BUTTON_TRACKER_HEADER"]                      = "Affiche le bouton Options dans l'en-tête."
L["OPTIONS_FOCUS_HEADER_COLOR"]                                       = "Couleur de l'en-tête"
L["OPTIONS_FOCUS_COLOR_OF_OBJECTIVES_HEADER_TEXT"]                    = "Couleur du texte OBJECTIFS dans l'en-tête."
L["OPTIONS_FOCUS_HEADER_HEIGHT"]                                      = "Hauteur de l'en-tête"
L["OPTIONS_FOCUS_HEIGHT_OF_HEADER_BAR_PIXELS"]                        = "Hauteur de la barre d'en-tête en pixels (18–48)."

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["OPTIONS_FOCUS_SECTION_HEADERS"]                                    = "Afficher les en-têtes de section"
L["OPTIONS_FOCUS_CATEGORY_LABELS_ABOVE_GROUP"]                        = "Affiche les catégories au-dessus de chaque groupe."
L["OPTIONS_FOCUS_CATEGORY_HEADERS_COLLAPSED"]                         = "En-têtes des catégories visibles quand replié"
L["OPTIONS_FOCUS_KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED_CLICK"]       = "Garde les en-têtes visibles quand le panneau est replié ; cliquez pour déployer une catégorie."
L["OPTIONS_FOCUS_NEARBY_CURRENT_ZONE_GROUP"]                          = "Afficher le groupe Zone actuelle"
L["OPTIONS_FOCUS_ZONE_QUESTS_A_DEDICATED_CURRENT_ZONE"]               = "Affiche les quêtes de la Zone Actuelle dans une section dédiée. Quand Désactivé : elles apparaissent dans leur catégorie habituelle."
L["OPTIONS_FOCUS_ZONE_LABELS"]                                        = "Afficher les noms de zone"
L["OPTIONS_FOCUS_ZONE_NAME_UNDER_QUEST_TITLE"]                        = "Affiche le nom de zone sous chaque titre de quête."
L["OPTIONS_FOCUS_ACTIVE_QUEST_HIGHLIGHT"]                             = "Surbrillance de la quête active"
L["OPTIONS_FOCUS_FOCUSED_QUEST_HIGHLIGHTED"]                          = "Règle la surbrillance de la quête active."
L["OPTIONS_FOCUS_QUEST_ITEM_BUTTONS"]                                 = "Afficher les boutons d'objet de quête"
L["OPTIONS_FOCUS_USABLE_QUEST_ITEM_BUTTON_NEXT_QUEST"]                = "Affiche le bouton d'objet utilisable à côté de chaque quête."
L["OPTIONS_FOCUS_TOOLTIPS_HOVER"]                                     = "Infobulles au survol"
L["OPTIONS_FOCUS_TOOLTIPS_HOVERING_TRACKER_ENTRIES_ITE"]              = "Afficher les infobulles au survol des éléments du panneau d'objectifs, des boutons d'objets, et des blocs de scénarios."
L["OPTIONS_FOCUS_WOWHEAD_LINK_TOOLTIPS"]                              = "Afficher le lien WoWhead dans les infobulles"
L["OPTIONS_FOCUS_A_TOOLTIP_SHOWN_ADD_A_LINK"]                         = "Quand l'infobulle est affichée, ajoute un lien vers la page WoWhead de la quête, du haut fait, ou du PNJ."
-- L["OPTIONS_FOCUS_VIEW_WOWHEAD"]                                    = "View on WoWhead"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_WOWHEAD_ALT_CLICK_HINT"]                             = "Alt+click row to copy"
-- L["OPTIONS_FOCUS_COPY_LINK"]                                       = "Copy link"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_COPY_URL_BELOW_CTRL_C_PASTE"]                     = "Copy the URL below (Ctrl+C) and paste in your browser."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_OBJECTIVE_NUMBERS"]                                  = "Afficher les numéros d'objectifs"
L["OPTIONS_FOCUS_OBJECTIVE_PREFIX"]                                   = "Préfixe d'objectif"
-- L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLORS"]                = "Color objective progress numbers"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLORS_DESC"]              = "Tint X/Y counts: normal color at 0/n, gold while in progress, green when complete. The slash uses the usual objective color."
L["OPTIONS_FOCUS_PREFIX_OBJECTIVE_A_NUMBER_HYPHEN"]                   = "Ajoute un chiffre ou un tiret devant chaque objectif."
L["OPTIONS_FOCUS_NUMBERS"]                                            = "Chiffres (1. 2. 3.)"
L["OPTIONS_FOCUS_HYPHENS"]                                            = "Tirets (-)"
L["OPTIONS_FOCUS_AFTER_SECTION_HEADER"]                               = "Après l'en-tête de section"
L["OPTIONS_FOCUS_BEFORE_SECTION_HEADER"]                              = "Avant l'en-tête de section"
L["OPTIONS_FOCUS_BELOW_HEADER"]                                       = "Sous l'en-tête header"
L["OPTIONS_FOCUS_INLINE_BELOW_TITLE"]                                 = "A la ligne sous le titre"
L["OPTIONS_FOCUS_PREFIX_OBJECTIVES"]                                  = "Préfixe les objectifs avec 1., 2., 3."
L["OPTIONS_FOCUS_COMPLETED_COUNT"]                                    = "Afficher le compteur d'objectifs complétés"
L["OPTIONS_FOCUS_X_Y_PROGRESS_QUEST_TITLE"]                           = "Affiche la progression X/Y dans les titres de quête."
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_BAR"]                             = "Afficher la barre de progression"
L["OPTIONS_FOCUS_A_PROGRESS_BAR_UNDER_OBJECTIVES_NUMER"]              = "Affiche une barre de progression sous les objectifs ayant une progression numérique (ex. 3/250). S'applique uniquement aux entrées avec un seul objectif arithmétique dont le montant requis est supérieur à 1."
L["OPTIONS_FOCUS_CATEGORY_COLOR_PROGRESS_BAR"]                        = "Utiliser la couleur de catégorie pour la barre"
L["OPTIONS_FOCUS_PROGRESS_BAR_MATCHES_QUEST_ACHIEVEME"]               = "Quand activé : la barre de progression utilise la couleur de la catégorie (quête, haut fait). Quand désactivé : utilise la couleur personnalisée ci-dessous."
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXTURE"]                               = "Texture de la barre de progression"
L["OPTIONS_FOCUS_PROGRESS_BAR_TYPES"]                                 = "Types de barre de progression"
L["OPTIONS_FOCUS_TEXTURE_PROGRESS_BAR_FILL"]                          = "Texture de remplissage de la barre."
L["OPTIONS_FOCUS_TEXTURE_PROGRESS_BAR_FILL_SOLID_YOUR"]               = "Texture de remplissage. Solide utilise vos couleurs. Les addons SharedMedia ajoutent d'autres options."
L["OPTIONS_FOCUS_PROGRESS_BAR_X_Y_OBJECTIVES_PERCENT"]                = "Afficher la barre pour les objectifs X/Y, les objectifs en pourcentage uniquement, ou les deux."
L["OPTIONS_FOCUS_X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]             = "X/Y : objectifs comme 3/10. Pourcent : objectifs comme 45 %."
L["OPTIONS_FOCUS_X_Y"]                                                = "X/Y uniquement"
L["OPTIONS_FOCUS_PERCENT"]                                            = "Pourcentage uniquement"
L["OPTIONS_FOCUS_TICK_COMPLETED_OBJECTIVES"]                          = "Utiliser une Coche pour les objectifs terminés"
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES_A_CHECKMARK_INSTEA"]            = "Quand Activé : les objectifs terminés affichent une coche (✓) au lieu de la couleur verte."
L["OPTIONS_FOCUS_ENTRY_NUMBERS"]                                      = "Afficher la numérotation des quêtes"
L["OPTIONS_FOCUS_PREFIX_QUEST_TITLES_WITHIN_CATEGORY"]                = "Préfixe les titres de quêtes avec 1., 2., 3. dans chaque catégorie."
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES"]                               = "Objectifs terminés"
L["OPTIONS_FOCUS_MULTI_OBJECTIVE_QUESTS_DISPLAY_OBJECTIVES"]          = "Règle l'affichage des objectifs terminés quand il y en a plusieurs (ex. 1/1)."
L["OPTIONS_FOCUS_ALL"]                                                = "Tout afficher"
L["OPTIONS_FOCUS_FADE_COMPLETED"]                                     = "Estomper les objectifs terminés"
L["OPTIONS_FOCUS_HIDE_COMPLETED"]                                     = "Masquer les objectifs terminés"
L["OPTIONS_FOCUS_ICON_ZONE_AUTO_TRACKING"]                            = "Afficher l'icône de suivi automatique en zone"
L["OPTIONS_FOCUS_DISPLAY_AN_ICON_NEXT_AUTO_TRACKED"]                  = "Affiche une icône à côté des expéditions et hebdomadaires/quotidiennes suivies automatiquement qui ne sont pas encore dans votre journal de quêtes (zone uniquement)."
L["OPTIONS_FOCUS_AUTO_TRACK_ICON"]                                    = "Icône de suivi automatique"
L["OPTIONS_FOCUS_CHOOSE_WHICH_ICON_DISPLAY_NEXT_AUTO"]                = "Choisissez l'icône affichée à côté des entrées suivies automatiquement en zone."
L["OPTIONS_FOCUS_APPEND_WORLD_QUESTS_WEEKLIES_DAILIES"]               = "Ajoute ** aux expéditions et hebdomadaires/journalières non encore dans le journal de quêtes (de la zone actuelle uniquement)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["OPTIONS_FOCUS_COMPACT_MODE"]                                       = "Mode compact"
L["OPTIONS_FOCUS_PRESET_SETS_ENTRY_OBJECTIVE_SPACING_P"]              = "Préréglage : espacement des quêtes et objectifs à 4 et 1 px."
L["OPTIONS_FOCUS_SPACING_PRESET"]                                     = "Préréglage d'espacement"
L["OPTIONS_FOCUS_PRESET_ENTRY_OBJECTIVE_SPACING_DEFAULT_P"]           = "Préréglages : Par défaut (8/2 px), Compact (4/1 px), Espacée (12/3 px) ou Personnalisé (utilise les curseurs)."
L["OPTIONS_FOCUS_COMPACT_VERSION"]                                    = "Version compacte"
L["OPTIONS_FOCUS_SPACED_VERSION"]                                     = "Version espacée"
L["OPTIONS_FOCUS_SPACING_BETWEEN_QUEST_ENTRIES_PX"]                   = "Espace entre les quêtes (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_QUEST_ENTRIES"]                 = "Espace vertical entre les différentes quêtes."
L["OPTIONS_FOCUS_SPACING_BEFORE_CATEGORY_HEADER_PX"]                  = "Espace avant l'en-tête (px)"
L["OPTIONS_FOCUS_GAP_BETWEEN_LAST_ENTRY_OF_A"]                        = "Espace entre la dernière entrée d'un groupe et la catégorie suivante."
L["OPTIONS_FOCUS_SPACING_AFTER_CATEGORY_HEADER_PX"]                   = "Espace après l'en-tête (px)"
L["OPTIONS_FOCUS_GAP_BETWEEN_CATEGORY_LABEL_FIRST_QUEST"]             = "Espace entre le libellé et la première entrée de quête en dessous."
L["OPTIONS_FOCUS_SPACING_BETWEEN_OBJECTIVES_PX"]                      = "Espace entre les objectifs (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVE_LINES_WITHIN"]        = "Espace entre les lignes d'objectifs dans une quête."
L["OPTIONS_FOCUS_TITLE_CONTENT"]                                      = "Titre vers contenu"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_QUEST_TITLE_OBJECTIVES"]        = "Espace vertical entre le titre de quête et les objectifs ou zone en dessous."
L["OPTIONS_FOCUS_SPACING_BELOW_HEADER_PX"]                            = "Espace sous l'en-tête (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVES_BAR_QUES"]           = "Espace entre la barre d'objectifs et la liste de quêtes."
L["OPTIONS_FOCUS_RESET_SPACING"]                                      = "Réinitialiser les espaces"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_QUEST_LEVEL"]                                   = "Afficher le niveau de quête"
L["OPTIONS_FOCUS_QUEST_LEVEL_NEXT_TITLE"]                             = "Affiche le niveau de quête à côté du titre."
L["OPTIONS_FOCUS_DIM_FOCUSED_QUESTS"]                                 = "Estomper les quêtes non actives"
L["OPTIONS_FOCUS_SLIGHTLY_DIM_TITLE_ZONE_OBJECTIVES_SECTION"]         = "Estompe légèrement les titres, zones, objectifs et en-têtes non actifs."
L["OPTIONS_FOCUS_DIM_UNFOCUSED_ENTRIES"]                              = "Estomper les éléments non mis en avant"
L["OPTIONS_FOCUS_CLICK_A_SECTION_HEADER_EXPAND_CATEGORY"]             = "Cliquer sur un en-tête de section pour agrandir la catégorie."

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["UI_SHOW_RARE_BOSSES"]                                              = "Afficher les boss rares"
L["UI_RARE_BOSS_VIGNETTES_LIST"]                                      = "Affiche les boss rares dans la liste."
L["UI_RARE_LOOT"]                                                     = "Butin rare"
L["UI_TREASURE_ITEM_VIGNETTES_RARE_LOOT"]                             = "Affiche les trésors et objets dans la liste de butin rare."
L["UI_RARE_SOUND_VOLUME"]                                             = "Volume du son de butin rare"
L["UI_VOLUME_OF_RARE_ALERT_SOUND"]                                    = "Volume du son d'alerte de butin rare (50–200%)."
L["UI_BOOST_REDUCE_RARE_ALERT_VOLUME"]                                = "Augmente ou réduit le volume. 100% = normal ; 150% = plus fort."
L["UI_RARE_ADDED_SOUND"]                                              = "Son d'ajout de rare"
L["UI_PLAY_A_SOUND_A_RARE"]                                           = "Joue un son quand un rare est ajouté."
-- L["UI_MINIMAP_PATCH_NOTES_UNREAD_HINT"]                            = "New patch notes — open Axis and choose Patch Notes."  -- NEEDS TRANSLATION

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["OPTIONS_FOCUS_ZONE_WORLD_QUESTS"]                                  = "Afficher les expéditions de la zone"
L["OPTIONS_FOCUS_AUTO_ADD_WORLD_QUESTS_YOUR_CURRENT"]                 = "Ajoute automatiquement les expéditions de votre zone. Quand Désactivé : seules les quêtes suivies ou proches sont affichées (réglage par défaut Blizzard)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_FLOATING_QUEST_ITEM"]                           = "Afficher l'objet de quête flottant"
L["OPTIONS_FOCUS_QUICK_BUTTON_FOCUSED_QUEST_S_USABLE"]                = "Affiche le bouton d'utilisation rapide de l'objet de la quête active."
L["OPTIONS_FOCUS_LOCK_FLOATING_QUEST_ITEM_POSITION"]                  = "Verrouiller la position de l'objet flottant"
L["OPTIONS_FOCUS_PREVENT_DRAGGING_FLOATING_QUEST_ITEM_BUTTON"]        = "Empêche de déplacer le bouton d'objet de quête flottant."
L["OPTIONS_FOCUS_FLOATING_QUEST_ITEM_SOURCE"]                         = "Source de l'objet flottant"
L["OPTIONS_FOCUS_WHICH_QUEST_S_ITEM_SUPER_TRACKED"]                   = "Quel objet afficher : Quête Suivie en priorité ou Zone Actuelle en priorité."
L["OPTIONS_FOCUS_SUPER_TRACKED_FIRST"]                                = "Quête Suivie en priorité"
L["OPTIONS_FOCUS_CURRENT_ZONE_FIRST"]                                 = "Zone Actuelle en priorité"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["OPTIONS_FOCUS_MYTHIC_BLOCK"]                                       = "Afficher le bloc Mythique+"
L["OPTIONS_FOCUS_TIMER_COMPLETION_AFFIXES_MYTHIC_DUNGEONS"]           = "Affiche le timer, le % de complétion et les affixes en Mythique+."
L["OPTIONS_FOCUS_M_BLOCK_POSITION"]                                   = "Position du bloc M+"
L["OPTIONS_FOCUS_POSITION_OF_MYTHIC_BLOCK_RELATIVE_QUEST"]            = "Position du bloc Mythique+ par rapport à la liste de quêtes."
L["OPTIONS_FOCUS_AFFIX_ICONS"]                                        = "Afficher les icônes des affixes"
L["OPTIONS_FOCUS_AFFIX_ICONS_NEXT_MODIFIER_NAMES_M"]                  = "Affiche les icônes des affixes à côté des noms dans le bloc M+."
L["OPTIONS_FOCUS_AFFIX_DESCRIPTIONS_TOOLTIP"]                         = "Descriptions des affixes dans l'infobulle"
L["OPTIONS_FOCUS_AFFIX_DESCRIPTIONS_HOVERING_M_BLO"]                  = "Affiche les descriptions des affixes au survol du bloc M+."
L["OPTIONS_FOCUS_M_COMPLETED_BOSS_DISPLAY"]                           = "Affichage des boss M+ terminés"
L["OPTIONS_FOCUS_DEFEATED_BOSSES_CHECKMARK_ICON_GREEN"]               = "Affichage des boss vaincus : icône coche ou couleur verte."
L["OPTIONS_FOCUS_CHECKMARK"]                                          = "Coche"
L["OPTIONS_FOCUS_GREEN_COLOR"]                                        = "Couleur Verte"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["OPTIONS_PRESENCE_ACHIEVEMENTS"]                                    = "Afficher les hauts faits"
L["OPTIONS_FOCUS_TRACKED_ACHIEVEMENTS_LIST"]                          = "Affiche les hauts faits suivis dans la liste."
L["OPTIONS_FOCUS_COMPLETED_ACHIEVEMENTS"]                             = "Afficher les hauts faits terminés"
L["OPTIONS_FOCUS_INCLUDE_COMPLETED_ACHIEVEMENTS_TRACKER_O"]           = "Inclut les hauts faits terminés. Quand Désactivé : seuls les hauts faits en cours sont affichés."
L["OPTIONS_FOCUS_ACHIEVEMENT_ICONS"]                                  = "Afficher les icônes de hauts faits"
L["OPTIONS_FOCUS_ACHIEVEMENT_S_ICON_NEXT_TITLE_REQUI"]                = "Affiche l'icône de chaque haut fait à côté du titre. Nécessite « Afficher les icônes de type de quête » dans Affichage."
L["OPTIONS_FOCUS_MISSING_REQUIREMENTS"]                               = "Afficher uniquement les objectifs manquants"
L["OPTIONS_FOCUS_CRITERIA_YOU_HAVEN_T_COMPLETED_TR"]                  = "Affiche uniquement les critères non terminés pour chaque haut fait suivi. Quand Désactivé : tous les critères sont affichés."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_ENDEAVORS"]                                     = "Afficher les Initiatives"
L["OPTIONS_FOCUS_TRACKED_ENDEAVORS_PLAYER_HOUSING_LIST"]              = "Affiche les Initiatives suivies (logement) dans la liste."
L["OPTIONS_FOCUS_COMPLETED_ENDEAVORS"]                                = "Afficher les Initiatives terminées"
L["OPTIONS_FOCUS_INCLUDE_COMPLETED_ENDEAVORS_TRACKER"]                = "Inclut les Initiatives terminées. Quand Désactivé : seuls les Initiatives en cours sont affichées."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_DECOR"]                                         = "Afficher les décorations"
L["OPTIONS_FOCUS_TRACKED_HOUSING_DECOR_LIST"]                         = "Affiche les décorations de Logis suivies dans la liste."
L["OPTIONS_FOCUS_DECOR_ICONS"]                                        = "Afficher les icônes de décorations"
L["OPTIONS_FOCUS_DECOR_ITEM_S_ICON_NEXT_TITLE"]                       = "Affiche l'icône de chaque décoration à côté du titre. Nécessite « Afficher les icônes de type de quête » dans Affichage."

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
L["OPTIONS_FOCUS_APPEARANCE_HORIZON_CONTROLS_HINT"]                   = "Horizon: Shift-click map, Ctrl-click Collections, Ctrl+Shift-click dressing room. Right-click clears focus or untracks."

-- =====================================================================
-- OptionsData.lua Features — Adventure Guide
-- =====================================================================
L["OPTIONS_FOCUS_ADVENTURE_GUIDE"]                                    = "Guide d'aventure"
L["OPTIONS_FOCUS_TRAVELER_S_LOG"]                                     = "Afficher le Journal du voyageur"
L["OPTIONS_FOCUS_TRACKED_TRAVELER_S_LOG_OBJECTIVES_SHIFT"]            = "Affiche les objectifs suivis du Journal du voyageur (Maj+clic dans le Guide d'aventure) dans la liste."
L["OPTIONS_FOCUS_AUTO_REMOVE_COMPLETED_ACTIVITIES"]                   = "Retirer automatiquement les activités terminées"
L["OPTIONS_FOCUS_AUTOMATICALLY_STOP_TRACKING_TRAVELER_S_LOG"]         = "Arrête automatiquement le suivi des activités du Journal du voyageur une fois terminées."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["OPTIONS_FOCUS_SCENARIO_EVENTS"]                                    = "Afficher les événements de scénario"
L["OPTIONS_FOCUS_ACTIVE_SCENARIO_DELVE_ACTIVITIES_DELVES_APP"]        = "Affiche les Scénarios et les Gouffres actifs. Les Gouffres s'affichent dans GOUFFRES ; les autres dans SCÉNARIO."
L["OPTIONS_FOCUS_TRACK_DELVE_DUNGEON_SCENARIO_ACTIVITIES"]            = "Suivre les activités de Gouffres, Donjons et scénarios."
L["OPTIONS_FOCUS_DELVES_APPEAR_DELVES_SECTION_DUNGEONS_DUNGEON"]      = "Les Gouffres dans GOUFFRES ; les donjons dans DONJON ; les autres dans SCÉNARIO."
L["OPTIONS_FOCUS_DELVES_APPEAR_DELVES_SECTION_SCENARIOS_S"]           = "Les Gouffres apparaissent dans la section Gouffres; les autres scenarios dans la section Scenario."
L["OPTIONS_FOCUS_DELVE_AFFIX_NAMES"]                                  = "Noms des affixes du Gouffre"
L["OPTIONS_FOCUS_DELVE_DUNGEON"]                                      = "Gouffre/Donjon seulement"
L["OPTIONS_FOCUS_SCENARIO_DEBUG_LOGGING"]                             = "Rapport de debug des scenario"
L["OPTIONS_FOCUS_LOG_SCENARIO_API_DATA_CHAT_H"]                       = "Fait le rapport de l'API des scenario dans le chat. Tapper /h debug focus scendebug pour activer."
L["OPTIONS_FOCUS_PRINTS_C_SCENARIOINFO_CRITERIA_WIDGET_DATA"]         = "Affiche les critères de C_ScenarioInfo et les données de widget au cours d'un scenario. Cela aide le diagnostique des erreurs d'affichage comme Abondance 46/300."
L["OPTIONS_FOCUS_HIDE_CATEGORIES_DELVE_DUNGEON"]                      = "Masquer les autres catégories en Donjon ou en Gouffres"
L["OPTIONS_FOCUS_DELVES_PARTY_DUNGEONS_DELVE_DUNG"]                   = "Durant un Donjon ou un Gouffre, affiche uniquement la section correspondante."
L["OPTIONS_FOCUS_DELVE_NAME_SECTION_HEADER"]                          = "Utiliser le nom du Gouffre comme en-tête"
L["OPTIONS_FOCUS_A_DELVE_DELVE_NAME_TIER_AFFIXES"]                    = "Durant un Gouffre : affiche le nom, le palier et les affixes dans l'en-tête. Quand Désactivé : affiche le bloc au-dessus de la liste."
L["OPTIONS_FOCUS_AFFIX_NAMES_DELVES"]                                 = "Afficher le nom des affixes dans les Gouffres"
L["OPTIONS_FOCUS_SEASON_AFFIX_NAMES_FIRST_DELVE_ENTRY"]               = "Affiche les noms des affixes saisonniers sur la première ligne du Gouffre. Nécessite les widgets Blizzard ; peut ne pas s'afficher correctement."
L["OPTIONS_FOCUS_CINEMATIC_SCENARIO_BAR"]                             = "Barre cinématique de scénario"
L["OPTIONS_FOCUS_TIMER_PROGRESS_BAR_SCENARIO_ENTRIES"]                = "Affiche le timer et la barre de progression pour les scénarios."
L["OPTIONS_FOCUS_TIMER"]                                              = "Afficher le timer"
L["OPTIONS_FOCUS_COUNTDOWN_TIMER_TIMED_QUESTS_EVENTS_SCEN"]           = "Affiche le compte à rebours sur les quêtes chronométrées, événements et scénarios. Désactivé, les timers sont masqués."
L["OPTIONS_FOCUS_TIMER_SCENARIOS"]                                    = "Timers: scenarios & delves"
L["OPTIONS_FOCUS_TIMER_SCENARIOS_DESC"]                               = "Countdown timer for scenario, delve, and dungeon tracker entries."
L["OPTIONS_FOCUS_TIMER_WORLD"]                                        = "Timers: world & callings"
L["OPTIONS_FOCUS_TIMER_WORLD_DESC"]                                   = "Countdown timer for world quests and callings."
L["OPTIONS_FOCUS_TIMER_QUEST_LOG"]                                    = "Timers: quest log (timed)"
L["OPTIONS_FOCUS_TIMER_QUEST_LOG_DESC"]                               = "Countdown timer for dailies, weeklies, and other quest log entries with a time limit."
L["OPTIONS_FOCUS_TIMER_DISPLAY"]                                      = "Affichage du timer"
L["OPTIONS_FOCUS_COLOR_TIMER_REMAINING"]                              = "Couleur du timer selon le temps restant"
L["OPTIONS_FOCUS_GREEN_PLENTY_OF_LEFT_YELLOW_RUNNING"]                = "Vert quand il reste du temps, jaune quand il en reste peu, rouge quand c'est critique."
L["OPTIONS_FOCUS_WHERE_COUNTDOWN_BAR_BELOW_OBJECTIVES"]               = "Où afficher le compte à rebours : barre sous les objectifs ou texte à côté du nom de quête."
L["OPTIONS_FOCUS_BAR_BELOW"]                                          = "Barre en dessous"
L["OPTIONS_FOCUS_INLINE_BESIDE_TITLE"]                                = "Texte à côté du titre"

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["OPTIONS_FOCUS_FONT_FAMILY"]                                        = "Police."
L["OPTIONS_FOCUS_TITLE_FONT"]                                         = "Police des titres"
L["OPTIONS_VISTA_ZONE_FONT"]                                          = "Police de zone"
L["OPTIONS_FOCUS_OBJECTIVE_FONT"]                                     = "Police des objectifs"
L["OPTIONS_FOCUS_SECTION_FONT"]                                       = "Police des sections"
L["OPTIONS_FOCUS_GLOBAL_FONT"]                                        = "Utiliser la police globale"
L["OPTIONS_FOCUS_FONT_FAMILY_QUEST_TITLES"]                           = "Police des titres de quête."
L["OPTIONS_FOCUS_FONT_FAMILY_ZONE_LABELS"]                            = "Police des libellés de zone."
L["OPTIONS_FOCUS_FONT_FAMILY_OBJECTIVE_TEXT"]                         = "Police du texte des objectifs."
L["OPTIONS_FOCUS_FONT_FAMILY_SECTION_HEADERS"]                        = "Police des en-têtes de section."
L["OPTIONS_FOCUS_HEADER_SIZE"]                                        = "Taille de l'en-tête"
L["OPTIONS_FOCUS_HEADER_FONT_SIZE"]                                   = "Taille de police de l'en-tête."
L["OPTIONS_FOCUS_TITLE_SIZE"]                                         = "Taille du titre"
L["OPTIONS_FOCUS_QUEST_TITLE_FONT_SIZE"]                              = "Taille de police des titres de quête."
L["OPTIONS_FOCUS_OBJECTIVE_SIZE"]                                     = "Taille des objectifs"
L["OPTIONS_FOCUS_OBJECTIVE_TEXT_FONT_SIZE"]                           = "Taille de police du texte des objectifs."
L["OPTIONS_FOCUS_ZONE_SIZE"]                                          = "Taille des zones"
L["OPTIONS_FOCUS_ZONE_LABEL_FONT_SIZE"]                               = "Taille de police des libellés de zone."
L["OPTIONS_FOCUS_SECTION_SIZE"]                                       = "Taille des sections"
L["OPTIONS_FOCUS_SECTION_HEADER_FONT_SIZE"]                           = "Taille de police des en-têtes de section."
L["OPTIONS_FOCUS_PROGRESS_BAR_FONT"]                                  = "Police de la barre de progression"
L["OPTIONS_FOCUS_FONT_FAMILY_PROGRESS_BAR_LABEL"]                     = "Police du texte de la barre de progression."
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXT_SIZE"]                             = "Taille du texte de la barre de progression"
L["OPTIONS_FOCUS_FONT_SIZE_PROGRESS_BAR_LABEL_ADJUSTS"]               = "Taille de police de la barre de progression. Ajuste également la hauteur. Affecte les objectifs de quêtes, la progression des scénarios et les barres de minuteur."
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL"]                                  = "Remplissage de la barre de progression"
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXT"]                                  = "Texte de la barre de progression"
L["OPTIONS_FOCUS_OUTLINE"]                                            = "Contour"
L["OPTIONS_FOCUS_FONT_OUTLINE_STYLE"]                                 = "Style de contour de police."

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["OPTIONS_FOCUS_HEADER_TEXT_CASE"]                                   = "Casse de l'en-tête"
L["OPTIONS_FOCUS_DISPLAY_CASE_HEADER"]                                = "Casse d'affichage pour l'en-tête."
L["OPTIONS_FOCUS_SECTION_HEADER_CASE"]                                = "Casse des en-têtes de section"
L["OPTIONS_FOCUS_DISPLAY_CASE_CATEGORY_LABELS"]                       = "Casse d'affichage des catégorie."
L["OPTIONS_FOCUS_QUEST_TITLE_CASE"]                                   = "Casse des titres de quête"
L["OPTIONS_FOCUS_DISPLAY_CASE_QUEST_TITLES"]                          = "Casse d'affichage pour les titres de quête."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["OPTIONS_FOCUS_TEXT_SHADOW"]                                        = "Afficher l'ombre du texte"
L["OPTIONS_FOCUS_ENABLE_DROP_SHADOW_TEXT"]                            = "Active l'ombre portée du texte."
L["OPTIONS_FOCUS_SHADOW_X"]                                           = "Ombre X"
L["OPTIONS_FOCUS_HORIZONTAL_SHADOW_OFFSET"]                           = "Décalage horizontal de l'ombre."
L["OPTIONS_FOCUS_SHADOW_Y"]                                           = "Ombre Y"
L["OPTIONS_FOCUS_VERTICAL_SHADOW_OFFSET"]                             = "Décalage vertical de l'ombre."
L["OPTIONS_FOCUS_SHADOW_ALPHA"]                                       = "Opacité de l'ombre"
L["OPTIONS_FOCUS_SHADOW_OPACITY"]                                     = "Opacité de l'ombre (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["OPTIONS_FOCUS_MYTHIC_TYPOGRAPHY"]                                  = "Textes Mythique+"
L["OPTIONS_FOCUS_DUNGEON_NAME_SIZE"]                                  = "Taille du nom du donjon"
L["OPTIONS_FOCUS_FONT_SIZE_DUNGEON_NAME_PX"]                          = "Taille de police du nom du donjon (8–32 px)."
L["OPTIONS_FOCUS_DUNGEON_NAME_COLOR"]                                 = "Couleur du nom du donjon"
L["OPTIONS_FOCUS_TEXT_COLOR_DUNGEON_NAME"]                            = "Couleur du texte du nom du donjon."
L["OPTIONS_FOCUS_TIMER_SIZE"]                                         = "Taille du timer"
L["OPTIONS_FOCUS_FONT_SIZE_TIMER_PX"]                                 = "Taille de police du timer (8–32 px)."
L["OPTIONS_FOCUS_TIMER_COLOR"]                                        = "Couleur du timer"
L["OPTIONS_FOCUS_TEXT_COLOR_TIMER"]                                   = "Couleur du timer (dans les temps)."
L["OPTIONS_FOCUS_TIMER_OVERTIME_COLOR"]                               = "Couleur du timer (temps dépassé)"
L["OPTIONS_FOCUS_TEXT_COLOR_TIMER_LIMIT"]                             = "Couleur du timer quand le temps est écoulé."
L["OPTIONS_FOCUS_PROGRESS_SIZE"]                                      = "Taille de la progression"
L["OPTIONS_FOCUS_FONT_SIZE_ENEMY_FORCES_PX"]                          = "Taille de police des forces ennemies (8–32 px)."
L["OPTIONS_FOCUS_PROGRESS_COLOR"]                                     = "Couleur de la progression"
L["OPTIONS_FOCUS_TEXT_COLOR_ENEMY_FORCES"]                            = "Couleur du texte des forces ennemies."
L["OPTIONS_FOCUS_BAR_FILL_COLOR"]                                     = "Couleur de remplissage de la barre"
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL_COLOR_PROGRESS"]                   = "Couleur de remplissage de la barre (Clé en cours)."
L["OPTIONS_FOCUS_BAR_COMPLETE_COLOR"]                                 = "Couleur de la barre de Clé terminée"
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL_COLOR_ENEMY_FORCES"]               = "Couleur de remplissage quand les forces ennemies sont à 100%."
L["OPTIONS_FOCUS_AFFIX_SIZE"]                                         = "Taille des affixes"
L["OPTIONS_FOCUS_FONT_SIZE_AFFIXES_PX"]                               = "Taille de police des affixes (8–32 px)."
L["OPTIONS_FOCUS_AFFIX_COLOR"]                                        = "Couleur des affixes"
L["OPTIONS_FOCUS_TEXT_COLOR_AFFIXES"]                                 = "Couleur du texte des affixes."
L["OPTIONS_FOCUS_BOSS_SIZE"]                                          = "Taille des noms de boss"
L["OPTIONS_FOCUS_FONT_SIZE_BOSS_NAMES_PX"]                            = "Taille de police des noms de boss (8–32 px)."
L["OPTIONS_FOCUS_BOSS_COLOR"]                                         = "Couleur des noms de boss"
L["OPTIONS_FOCUS_TEXT_COLOR_BOSS_NAMES"]                              = "Couleur du texte des noms de boss."
L["OPTIONS_FOCUS_RESET_MYTHIC_TYPOGRAPHY"]                            = "Réinitialiser les textes M+"

-- =====================================================================
-- OptionsData.lua Appearance
-- =====================================================================
L["OPTIONS_FOCUS_FRAME"]                                              = "Cadre"
L["OPTIONS_FOCUS_CLASS_COLOURS_DASHBOARD"]                            = "Couleurs de classe - Tableau de bord"
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
L["OPTIONS_FOCUS_CLASS_COLORS"]                                       = "Couleurs de classe"
L["OPTIONS_FOCUS_TINT_DASHBOARD_ACCENTS_DIVIDERS_HIGHLIGHTS"]         = "Colore les éléments du Tableau de bord, des séparateurs et des surlignages avec la couleur de votre classe."
-- L["OPTIONS_FOCUS_THEME"]                                           = "Theme"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND"]                            = "Dashboard background"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_BACKGROUND_STYLE_MODULE_DASHBOARD_WINDOW_AXI"]       = "Background style for the module dashboard window (Axis). Default is flat; Midnight uses bundled artwork; Specialisation (auto) uses the in-game talent UI background for your current specialization."
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_MINIMALISTIC"]               = "Minimalistic"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_MIDNIGHT"]                   = "Midnight"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_NIGHTFAE"]                   = "Night Fae"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_ZIN_AZSHARI"]                = "Zin-Azshari"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_CLASS_TALENTS"]              = "Specialisation (auto)"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_OPACITY"]                    = "Dashboard background opacity"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_ADJUST_OPACITY_OF_DASHBOARD_BACKGROUND"]          = "Adjust the opacity of the dashboard background (50–100%). Lower values let more of the game world show through."  -- NEEDS TRANSLATION
-- L["DASHBOARD_TYPO_SECTION"]                                        = "Dashboard text"  -- NEEDS TRANSLATION
-- L["DASHBOARD_TYPO_FONT"]                                           = "Dashboard font"  -- NEEDS TRANSLATION
-- L["DASHBOARD_TYPO_FONT_DESC"]                                      = "Font for the Axis settings window (sidebar, search, and option rows). Separate from the Focus tracker font. For CJK or mixed-script welcome text, pick a broad-coverage font (e.g. 2002) if needed."  -- NEEDS TRANSLATION
-- L["DASHBOARD_TYPO_SIZE"]                                           = "Dashboard text size"  -- NEEDS TRANSLATION
-- L["DASHBOARD_TYPO_SIZE_DESC"]                                      = "Nudge all dashboard text larger or smaller (−4 to +4), similar to Focus global font offset."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_BACKDROP_OPACITY"]                                   = "Opacité du fond"
L["OPTIONS_FOCUS_PANEL_BACKGROUND_OPACITY"]                           = "Opacité du fond du panneau (0–1)."
L["OPTIONS_FOCUS_BORDER"]                                             = "Afficher la bordure"
L["OPTIONS_FOCUS_BORDER_AROUND_TRACKER"]                              = "Affiche le cadre autour du panneau d'objectifs."
L["OPTIONS_FOCUS_SCROLL_INDICATOR"]                                   = "Afficher l'indicateur de défilement"
L["OPTIONS_FOCUS_A_VISUAL_HINT_LIST_CONTENT_TH"]                      = "Affiche un indice visuel lorsque la liste contient plus de contenu que ce qui est visible."
L["OPTIONS_FOCUS_SCROLL_INDICATOR_STYLE"]                             = "Style de l'indicateur de défilement"
L["OPTIONS_FOCUS_CHOOSE_BETWEEN_A_FADE_GRADIENT_A"]                   = "Choisissez entre un dégradé ou une petite flèche pour indiquer le contenu défilable."
L["OPTIONS_FOCUS_ARROW"]                                              = "Flèche"
L["OPTIONS_FOCUS_HIGHLIGHT_ALPHA"]                                    = "Opacité de la surbrillance"
L["OPTIONS_FOCUS_OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]                 = "Opacité de la quête active (0–1)."
L["OPTIONS_FOCUS_BAR_WIDTH"]                                          = "Largeur de la barre"
L["OPTIONS_FOCUS_WIDTH_OF_BAR_STYLE_HIGHLIGHTS_PX"]                   = "Largeur de la barre de surbrillance (2–6 px)."

-- =====================================================================
-- OptionsData.lua Organization
-- =====================================================================
L["OPTIONS_FOCUS_ACTIVITY"]                                           = "Activité"
L["OPTIONS_FOCUS_CONTENT"]                                            = "Contenu"
L["OPTIONS_FOCUS_SORTING"]                                            = "Tri"
L["OPTIONS_FOCUS_ELEMENTS"]                                           = "Éléments"
L["OPTIONS_FOCUS_CATEGORY_ORDER"]                                     = "Ordre des catégories Focus"
L["OPTIONS_FOCUS_CATEGORY_COLOR_BAR"]                                 = "Couleur de la catégorie pour la barre"
L["OPTIONS_FOCUS_CHECKMARK_COMPLETED"]                                = "Coche pour les objectifs complétés"
L["OPTIONS_FOCUS_CURRENT_QUEST_CATEGORY"]                             = "Catégorie Quête en Cours"
L["OPTIONS_FOCUS_CURRENT_QUEST_WINDOW"]                               = "Fenêtre Quête en Cours"
L["OPTIONS_FOCUS_QUESTS_RECENT_PROGRESS_TOP"]                         = "Afficher en haut du panneau les quêtes avec le progrès le plus récent."
L["OPTIONS_FOCUS_SECONDS_OF_RECENT_PROGRESS_CURRENT_QUEST"]           = "Secondes de progression récentes pour compter comme Quête en Cours (30–120)."
L["OPTIONS_FOCUS_QUESTS_YOU_MADE_PROGRESS_LAST_MINUTE"]               = "Les quêtes qui ont été avancées lors de la dernière minute s'affiche dans une section dédiée."
L["OPTIONS_FOCUS_CATEGORY_ORDER"]                                     = "Ordre des catégories Focus"
L["OPTIONS_FOCUS_DRAG_REORDER_CATEGORIES_DELVES_SCENARIO_EVENT"]      = "Glissez pour réordonner. GOUFFRES et SCÉNARIO restent en premier."
L["OPTIONS_FOCUS_DRAG_REORDER_DELVES_SCENARIOS_STAY_FIRST"]           = "Glisser pour réordonner. Les Gouffres et les Scenario restent en premier."
L["OPTIONS_FOCUS_SORT_MODE"]                                          = "Mode de tri Focus"
L["OPTIONS_FOCUS_ORDER_OF_ENTRIES_WITHIN_CATEGORY"]                   = "Ordre des entrées dans chaque catégorie."
L["OPTIONS_FOCUS_AUTO_TRACK_ACCEPTED_QUESTS"]                         = "Suivi auto des quêtes acceptées"
L["OPTIONS_FOCUS_YOU_ACCEPT_A_QUEST_QUEST_LOG"]                       = "Suivi automatique des nouvelles quêtes (Sauf les expéditions)."
L["OPTIONS_FOCUS_REQUIRE_CTRL_FOCUS_REMOVE"]                          = "Ctrl requis pour suivre / ne plus suivre"
L["OPTIONS_FOCUS_REQUIRE_CTRL_FOCUS_ADD_LEFT_UNFOCUS"]                = "Exige l'appui sur la touche Ctrl pour suivre (clic gauche) et ne plus suivre (clic droit) afin d'éviter les clics accidentels."
L["OPTIONS_FOCUS_CTRL_FOCUS_UNTRACK"]                                 = "Appui sur Ctrl pour suivre / ne plus suivre"
L["OPTIONS_FOCUS_CTRL_CLICK_COMPLETE"]                                = "Appui sur Ctrl pour Rendre en un clic"
L["OPTIONS_FOCUS_CLASSIC_CLICK_BEHAVIOUR"]                            = "Utiliser le comportement de clic classique"
L["OPTIONS_FOCUS_CLASSIC_CLICKS"]                                     = "Clics classiques"
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
-- L["OPTIONS_FOCUS_CLICK_ACTION_OPEN_QUEST_LOG"]                     = "Open quest log"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_ACTION_UNTRACK"]                            = "Untrack"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_ACTION_CONTEXT_MENU"]                       = "Context menu"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_ACTION_SHARE"]                              = "Share with party"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_ACTION_ABANDON"]                            = "Abandon quest"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_ACTION_WOWHEAD"]                            = "WoWhead URL"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_ACTION_CHAT_LINK"]                          = "Link in chat"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_APPEARANCE_CANNOT_SHARE"]                         = "Appearances cannot be shared like quests."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_QUEST_DETAILS_AFTER_COMBAT"]                      = "Quest details will open when you leave combat."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_SHARE_PARTY"]                                        = "Partager avec le groupe"
L["OPTIONS_FOCUS_ABANDON_QUEST"]                                      = "Abandonner la quête"
L["OPTIONS_FOCUS_STOP_TRACKING"]                                      = "Arrêter le suivi"
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
L["OPTIONS_FOCUS_QUEST_CANNOT_SHARED"]                                = "Cette quête ne peut pas être partagée."
L["OPTIONS_FOCUS_YOU_MUST_A_PARTY_SHARE_QUEST"]                       = "Vous devez être en groupe pour partager cette quête."
L["OPTIONS_FOCUS_LEFT_CLICK_OPENS_QUEST_MAP_RIGHT"]                   = "Activé : clic gauche ouvre la carte de quête, clic droit affiche le menu partager/abandonner (style Blizzard). Désactivé : clic gauche suit, clic droit arrête le suivi ; Ctrl+clic droit partage avec le groupe."
L["OPTIONS_FOCUS_ANIMATIONS"]                                         = "Focus animations"
L["OPTIONS_FOCUS_ENABLE_SLIDE_FADE_QUESTS"]                           = "Active le glissement et le fondu pour les quêtes."
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_FLASH"]                           = "Flash de progression d'objectif"
L["OPTIONS_FOCUS_FLASH_AN_OBJECTIVE_COMPLETES"]                       = "Clignote quand un objectif est terminé."
L["OPTIONS_FOCUS_FLASH_INTENSITY"]                                    = "Intensité du flash"
L["OPTIONS_FOCUS_NOTICEABLE_OBJECTIVE_COMPLETE_FLASH"]                = "Intensité du flash à la complétion d'un objectif."
L["OPTIONS_FOCUS_FLASH_COLOR"]                                        = "Couleur du flash"
L["OPTIONS_FOCUS_COLOR_OF_OBJECTIVE_COMPLETE_FLASH"]                  = "Couleur du flash à la complétion d'un objectif."
L["OPTIONS_FOCUS_SUBTLE"]                                             = "Subtil"
L["OPTIONS_FOCUS_MEDIUM"]                                             = "Moyen"
L["OPTIONS_FOCUS_STRONG"]                                             = "Fort"
L["OPTIONS_FOCUS_REQUIRE_CTRL_CLICK_COMPLETE"]                        = "Ctrl requis pour cliquer et terminer"
L["OPTIONS_FOCUS_REQUIRES_CTRL_LEFT_CLICK_COMPLETE_AUTO"]             = "Quand Activé : Ctrl+clic gauche pour terminer. Quand Désactivé : un simple clic gauche (comportement Blizzard par défaut). Affecte uniquement les quêtes terminables par clic. (Sans dialogue avec un PNJ)"
L["OPTIONS_FOCUS_SUPPRESS_UNTRACKED_UNTIL_RELOAD"]                    = "Masquer les quêtes non suivies jusqu'au prochain rechargement"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS_Z"]                 = "Quand Activé : les quêtes non suivies restent masquées jusqu'au rechargement. Désactivé : elles réapparaissent à chaque retour en zone."
L["OPTIONS_FOCUS_PERMANENTLY_SUPPRESS_UNTRACKED_QUESTS"]              = "Masquer définitivement les quêtes non suivies"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACKED_WORLD_QUESTS_ZO"]              = "Quand Activé : les quêtes non suivies restent masquées définitivement. Prioritaire sur « Masquer jusqu'au prochain rechargement ». Accepter une quête masquée la retire de la liste noire."
L["OPTIONS_FOCUS_KEEP_CAMPAIGN_QUESTS_CATEGORY"]                      = "Garder les quêtes de campagne dans leur catégorie"
L["OPTIONS_FOCUS_CAMPAIGN_QUESTS_READY_TURN_RE"]                      = "Quand Activé : les quêtes de campagne prêtes à être rendues restent dans la catégorie Campagne au lieu d'aller dans Terminées."
L["OPTIONS_FOCUS_KEEP_IMPORTANT_QUESTS_CATEGORY"]                     = "Garder les quêtes importantes dans leur catégorie"
L["OPTIONS_FOCUS_IMPORTANT_QUESTS_READY_TURN_R"]                      = "Quand Activé : les quêtes importantes prêtes à être rendues restent dans la catégorie Important au lieu d'aller dans Terminées."
L["OPTIONS_FOCUS_TOMTOM_QUEST_WAYPOINT"]                              = "Point de repère TomTom"
L["OPTIONS_FOCUS_A_TOMTOM_WAYPOINT_FOCUSING_A_QUEST"]                 = "Définir un point de repère TomTom en ciblant une quête."
L["OPTIONS_FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_NEXT_QUEST"]            = "Nécessite TomTom. Dirige la flèche vers le prochain objectif de quête."
L["OPTIONS_FOCUS_TOMTOM_RARE_WAYPOINT"]                               = "Point de repère TomTom (rare)"
L["OPTIONS_FOCUS_A_TOMTOM_WAYPOINT_CLICKING_A_RARE"]                  = "Définir un point de repère TomTom en cliquant sur un boss rare."
L["OPTIONS_FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_RARE_S"]                = "Nécessite TomTom. Dirige la flèche vers l'emplacement du boss rare."
L["OPTIONS_FOCUS_FIND_A_GROUP"]                                       = "Recherche de groupe"
L["OPTIONS_FOCUS_CLICK_SEARCH_A_GROUP_QUEST"]                         = "Cliquer pour rechercher un groupe pour cette quête."

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
L["OPTIONS_FOCUS_BLACKLIST"]                                          = "Liste noire"
L["OPTIONS_FOCUS_BLACKLIST_UNTRACKED"]                                = "Mettre en liste noire les quêtes arrêtées d'être suivies"
L["OPTIONS_FOCUS_ENABLE_BLACKLIST_UNTRACKED_BEHAVIOUR_ADD_QUEST"]     = "Activer 'Mettre en liste noire les quêtes arrêtées d'être suivies' dans Comportement pour ajouter des quêtes ici."
L["OPTIONS_FOCUS_HIDDEN_QUESTS"]                                      = "Quêtes cachées"
L["OPTIONS_FOCUS_QUESTS_HIDDEN_RIGHT_CLICK_UNTRACK"]                  = "Les quêtes cachées avec le clic droit arrêtent d'être suivies."
L["OPTIONS_FOCUS_BLACKLISTED_QUESTS"]                                 = "Quêtes en liste noire"
L["OPTIONS_FOCUS_PERMANENTLY_SUPPRESSED_QUESTS"]                      = "Quêtes supprimées définitivement"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACK_QUESTS_PERMANENTLY_SUPPRESS"]    = "Clic droit pour retirer les quêtes avec « Quêtes supprimées définitivement » activé afin de les ajouter ici."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["OPTIONS_PRESENCE_QUEST_TYPE_ICONS"]                                = "Afficher les icônes du type de quête"
L["OPTIONS_PRESENCE_QUEST_TYPE_ICON_FOCUS_TRACKER_QUEST"]             = "Affiche dans le suivi : quête acceptée/terminée, expéditions, avancement de quête."
L["OPTIONS_PRESENCE_QUEST_TYPE_ICONS_TOASTS"]                         = "Montrer les icônes de type de quêtes sur les notifications"
L["OPTIONS_PRESENCE_QUEST_TYPE_ICON_PRESENCE_TOASTS_QUEST"]           = "Affiche l'icône de type de quête sur les notifications : quête acceptée/terminée, expéditions, avancement de quête."
L["OPTIONS_PRESENCE_TOAST_ICON_SIZE"]                                 = "Taille des icônes sur les notifications"
L["OPTIONS_PRESENCE_QUEST_ICON_SIZE_PRESENCE_TOASTS_PX"]              = "Taille des icônes de quête sur les notifications (16–36 px). Par défaut 24."
L["OPTIONS_PRESENCE_HIDE_QUEST_UPDATE_TITLE"]                         = "Masquer le titre sur les avancements de quête"
L["OPTIONS_PRESENCE_OBJECTIVE_LINE_QUEST_PROGRESS_TOAST"]             = "Affiche uniquement la ligne d'objectif (ex. 7/10 Peaux de sanglier) sans le nom de quête ni l'en-tête."
L["OPTIONS_PRESENCE_SHOW_DISCOVERY_LINE"]                             = "Afficher la ligne de découverte"
L["OPTIONS_PRESENCE_DISCOVERY_LINE"]                                  = "Ligne de Découverte"
L["OPTIONS_PRESENCE_DISCOVERED_UNDER_ZONE_SUBZONE_ENTERING_A"]        = "Affiche « Découverte » sous la zone/sous-zone à l'entrée d'une nouvelle zone."
L["OPTIONS_PRESENCE_FRAME_VERTICAL_POSITION"]                         = "Position verticale du cadre"
L["OPTIONS_PRESENCE_VERTICAL_OFFSET_OF_PRESENCE_FRAME_CENTER"]        = "Décalage vertical depuis le centre (-300 à 0)."
L["OPTIONS_PRESENCE_FRAME_SCALE"]                                     = "Échelle du cadre"
L["OPTIONS_PRESENCE_SCALE_OF_PRESENCE_FRAME"]                         = "Échelle du cadre Présence (0.5–2)."
L["OPTIONS_PRESENCE_BOSS_EMOTE_COLOR"]                                = "Couleur des emotes de boss"
L["OPTIONS_PRESENCE_COLOR_OF_RAID_DUNGEON_BOSS_EMOTE"]                = "Couleur du texte des emotes de boss en raid et donjon."
L["OPTIONS_PRESENCE_DISCOVERY_LINE_COLOR"]                            = "Couleur de la ligne de découverte"
L["OPTIONS_PRESENCE_COLOR_OF_DISCOVERED_LINE_UNDER_ZONE"]             = "Couleur de la ligne « Découverte » sous le texte de zone."
L["OPTIONS_PRESENCE_NOTIFICATION_TYPES"]                              = "Types de notifications"
-- L["OPTIONS_PRESENCE_NOTIFICATIONS"]                                = "Notifications"  -- NEEDS TRANSLATION
L["OPTIONS_PRESENCE_NOTIFICATION_ACHIEVEMENT_CRITERIA_UPDATE_T"]      = "Montre une notification quand un objectif de haut fait progresse (pour tous les hauts faits suivis; et les autres lorsque Blizzard fournit l'ID du haut fait)."
L["OPTIONS_PRESENCE_ZONE_ENTRY"]                                      = "Afficher l'entrée en zone"
L["OPTIONS_PRESENCE_ZONE_CHANGE_ENTERING_A_AREA"]                     = "Affiche la notification lors de l'entrée dans une nouvelle zone."
L["OPTIONS_PRESENCE_SUBZONE_CHANGES"]                                 = "Afficher les changements de sous-zone"
L["OPTIONS_PRESENCE_SUBZONE_CHANGE_MOVING_WITHIN_SAME_ZONE"]          = "Affiche la notification lors du déplacement entre sous-zones dans la même zone."
L["OPTIONS_PRESENCE_HIDE_ZONE_NAME_SUBZONE_CHANGES"]                  = "Masquer le nom de zone pour les sous-zones"
L["OPTIONS_PRESENCE_MOVING_BETWEEN_SUBZONES_WITHIN_SAME_ZONE"]        = "Lors des déplacements entre sous-zones dans la même zone, affiche uniquement le nom de la sous-zone. Le nom de la zone apparaît toujours en entrant dans une nouvelle zone."
L["OPTIONS_PRESENCE_SUPPRESS_DELVE"]                                  = "Sourdine en Gouffre"
L["OPTIONS_PRESENCE_SUPPRESS_SCENARIO_PROGRESS_NOTIFICATIONS_DELVES"]   = "Sourdine les notifications de progrès de scenario en Gouffre."
L["OPTIONS_PRESENCE_HIDES_OBJECTIVE_UPDATE_POPUPS_WHILE_A"]           = "Quand activé, masque les messages de progression des objectifs dans les Gouffres. L'entrée en zone et les alertes de complétion continueront de s'afficher."
L["OPTIONS_PRESENCE_SUPPRESS_ZONE_CHANGES_MYTHIC"]                    = "Supprimer les changements de zone en Mythique+"
L["OPTIONS_PRESENCE_MYTHIC_BOSS_EMOTES_ACHIEVEMENTS_LEV"]             = "En Mythique+, affiche uniquement les emotes de boss, hauts faits et montée de niveau. Masque les notifications de zone, quête et scénario."
L["OPTIONS_PRESENCE_LEVEL"]                                           = "Afficher la montée de niveau"
L["OPTIONS_PRESENCE_LEVEL_NOTIFICATION"]                              = "Affiche la notification de montée de niveau."
L["OPTIONS_PRESENCE_BOSS_EMOTES"]                                     = "Afficher les emotes de boss"
L["OPTIONS_PRESENCE_RAID_DUNGEON_BOSS_EMOTE_NOTIFICATIONS"]           = "Affiche les notifications d'emotes de boss en raid et donjon."
L["OPTIONS_PRESENCE_ACHIEVEMENTS"]                                    = "Afficher les hauts faits"
L["OPTIONS_PRESENCE_ACHIEVEMENT_EARNED_NOTIFICATIONS"]                = "Affiche les notifications de hauts faits obtenus."
L["OPTIONS_PRESENCE_ACHIEVEMENT_PROGRESS"]                            = "Progression des hauts faits"
L["OPTIONS_PRESENCE_ACHIEVEMENT_EARNED"]                              = "Haut fait obtenu"
L["OPTIONS_PRESENCE_QUEST_ACCEPTED"]                                  = "Quête acceptée"
L["OPTIONS_PRESENCE_WORLD_QUEST_ACCEPTED"]                            = "Expédition acceptée"
L["OPTIONS_PRESENCE_SCENARIO_COMPLETE"]                               = "Scénario terminé"
L["OPTIONS_PRESENCE_RARE_DEFEATED"]                                   = "Rare vaincu"
L["OPTIONS_PRESENCE_NOTIFICATION_TRACKED_ACHIEVEMENT_CRITERIA"]       = "Affiche une notification lorsque les critères d'un haut fait suivi sont mis à jour."
L["OPTIONS_PRESENCE_QUEST_ACCEPT"]                                    = "Afficher l'acceptation de quête"
L["OPTIONS_PRESENCE_NOTIFICATION_ACCEPTING_A_QUEST"]                  = "Affiche la notification lors de l'acceptation d'une quête."
L["OPTIONS_PRESENCE_WORLD_QUEST_ACCEPT"]                              = "Afficher l'acceptation d'expédition"
L["OPTIONS_PRESENCE_NOTIFICATION_ACCEPTING_A_WORLD_QUEST"]            = "Affiche la notification lors de l'acceptation d'une expédition."
L["OPTIONS_PRESENCE_QUEST_COMPLETE"]                                  = "Afficher la complétion de quête"
L["OPTIONS_PRESENCE_NOTIFICATION_COMPLETING_A_QUEST"]                 = "Affiche la notification lors de la complétion d'une quête."
L["OPTIONS_PRESENCE_WORLD_QUEST_COMPLETE"]                            = "Afficher la complétion d'expédition"
L["OPTIONS_PRESENCE_NOTIFICATION_COMPLETING_A_WORLD_QUEST"]           = "Affiche la notification lors de la complétion d'une expédition."
L["OPTIONS_PRESENCE_QUEST_PROGRESS"]                                  = "Afficher la progression des quêtes"
L["OPTIONS_PRESENCE_NOTIFICATION_QUEST_OBJECTIVES_UPDATE"]            = "Affiche la notification lors de la mise à jour des objectifs."
L["OPTIONS_PRESENCE_OBJECTIVE"]                                       = "Objectif uniquement"
L["OPTIONS_PRESENCE_QUEST_PROGRESS_HIDE_TITLE"]                       = "Affiche uniquement la ligne d'objectif sur les notifications de progression, en masquant le titre « Mise à jour de quête »."
L["OPTIONS_PRESENCE_SCENARIO_START"]                                  = "Afficher le début de scénario"
L["OPTIONS_PRESENCE_NOTIFICATION_ENTERING_A_SCENARIO_DELVE"]          = "Affiche la notification à l'entrée d'un scénario ou d'un Gouffre."
L["OPTIONS_PRESENCE_SCENARIO_PROGRESS"]                               = "Afficher la progression du scénario"
L["OPTIONS_PRESENCE_NOTIFICATION_SCENARIO_DELVE_OBJECTIVES"]          = "Affiche la notification lors de la mise à jour des objectifs de scénario ou Gouffre."
-- L["OPTIONS_PRESENCE_ANIMATION"]                                    = "Animation"  -- NEEDS TRANSLATION
L["OPTIONS_PRESENCE_ENABLE_ANIMATIONS"]                               = "Activer les animations"
L["OPTIONS_PRESENCE_ENABLE_ENTRANCE_EXIT_ANIMATIONS_PRESENCE"]        = "Active les animations d'entrée et de sortie des notifications."
L["OPTIONS_PRESENCE_ENTRANCE_DURATION"]                               = "Durée d'entrée"
L["OPTIONS_PRESENCE_DURATION_OF_ENTRANCE_ANIMATION_SECONDS"]          = "Durée de l'animation d'entrée en secondes (0.2–1.5)."
L["OPTIONS_PRESENCE_EXIT_DURATION"]                                   = "Durée de sortie"
L["OPTIONS_PRESENCE_DURATION_OF_EXIT_ANIMATION_SECONDS"]              = "Durée de l'animation de sortie en secondes (0.2–1.5)."
L["OPTIONS_PRESENCE_HOLD_DURATION_SCALE"]                             = "Facteur de durée d'affichage"
L["OPTIONS_PRESENCE_MULTIPLIER_LONG_NOTIFICATION_STAYS_S"]            = "Multiplicateur de la durée d'affichage des notifications (0.5–2)."
L["OPTIONS_PRESENCE_PREVIEW"]                                         = "Aperçu"
L["OPTIONS_PRESENCE_PREVIEW_TOAST_TYPE"]                              = "Aperçu des types d'alertes"
L["OPTIONS_PRESENCE_SELECT_A_TOAST_TYPE_PREVIEW"]                     = "Sélectionner un type d'alerte à prévisualiser."
L["OPTIONS_PRESENCE_SELECTED_TOAST_TYPE"]                             = "Afficher le type d'alerte sélectionné."
L["OPTIONS_PRESENCE_PREVIEW_PRESENCE_TOAST_LAYOUTS_LIVE_OPEN"]        = "Prévisualiser les mises en forme d'alertes Presence, et ouvre un échantillon détachable tout en ajustant d'autres options."
L["OPTIONS_PRESENCE_OPEN_DETACHED_PREVIEW"]                           = "Ouvrir l'aperçu détachable"
L["OPTIONS_PRESENCE_OPEN_A_MOVABLE_PREVIEW_WINDOW_STAYS"]             = "Ouvre une fenêtre d'aperçu ajustable qui reste visible pendant le réglage des autres options Presence."
L["OPTIONS_PRESENCE_ANIMATE_PREVIEW"]                                 = "Animer l'aperçu"
L["OPTIONS_PRESENCE_PLAY_SELECTED_TOAST_ANIMATION_INSIDE_PREVIE"]     = "Lire l'animation de l'alerte sélectionnée dans la fenêtre d'aperçu."
L["OPTIONS_PRESENCE_DETACHED_PREVIEW"]                                = "Prévisualisation détachée"
L["OPTIONS_PRESENCE_KEEP_OPEN_WHILE_ADJUSTING_TYPOGRAPHY_COLORS"]     = "Garder cette fenêtre ouverte en réglant les Textes et les Couleurs."
L["DASH_TYPOGRAPHY"]                                                  = "Textes"
L["OPTIONS_PRESENCE_MAIN_TITLE_FONT"]                                 = "Police du titre principal"
L["OPTIONS_PRESENCE_FONT_FAMILY_MAIN_TITLE"]                          = "Famille de police pour le titre principal."
L["OPTIONS_PRESENCE_SUBTITLE_FONT"]                                   = "Police du sous-titre"
L["OPTIONS_PRESENCE_FONT_FAMILY_SUBTITLE"]                            = "Famille de police pour le sous-titre."
L["OPTIONS_PRESENCE_RESET_TYPOGRAPHY_DEFAULTS"]                       = "Réinitialiser les textes."
L["OPTIONS_PRESENCE_RESET_PRESENCE_TYPOGRAPHY_OPTIONS_FONTS_SIZES"]   = "Réinitialise tous les réglages des textes Presence (polices, tailles, couleurs) à leur état par défaut."
L["OPTIONS_PRESENCE_LARGE_NOTIFICATIONS"]                             = "Grandes notifications"
L["OPTIONS_PRESENCE_MEDIUM_NOTIFICATIONS"]                            = "Notifications moyennes"
L["OPTIONS_PRESENCE_SMALL_NOTIFICATIONS"]                             = "Petites notifications"
L["OPTIONS_PRESENCE_LARGE_PRIMARY_SIZE"]                              = "Taille primaire des grandes notifications"
L["OPTIONS_PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_TITLES_ZONE"]        = "Taille du texte des titres de grandes notifications (zones, quête terminée, haut fait, etc.)."
L["OPTIONS_PRESENCE_LARGE_SECONDARY_SIZE"]                            = "Taille secondaire des grandes notifications"
L["OPTIONS_PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_SUBTITLES"]          = "Taille de sous-titres des grandes notifications."
L["OPTIONS_PRESENCE_MEDIUM_PRIMARY_SIZE"]                             = "Taille primaire des notifications moyennes"
-- L["OPTIONS_PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_TITLES_QUEST"]   = "Font size for medium notification titles (quest accept, subzone, scenario)."  -- NEEDS TRANSLATION
L["OPTIONS_PRESENCE_MEDIUM_SECONDARY_SIZE"]                           = "Taille secondaire des notifications moyennes"
L["OPTIONS_PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_SUBTITLES"]         = "Taille de sous-titres des notifications moyennes."
L["OPTIONS_PRESENCE_SMALL_PRIMARY_SIZE"]                              = "Taille primaire des petites notifications"
L["OPTIONS_PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_TITLES_QUEST"]       = "Taille du texte des titres de petites notifications (progression des quêtes et de hauts faits)."
L["OPTIONS_PRESENCE_SMALL_SECONDARY_SIZE"]                            = "Taille secondaire des petites notifications"
L["OPTIONS_PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_SUBTITLES"]          = "Taille de sous-titres des petites notifications."

-- =====================================================================
-- OptionsData.lua Dropdown options — Outline
-- =====================================================================
L["OPTIONS_FOCUS_NONE"]                                               = "Aucun"
L["OPTIONS_FOCUS_THICK_OUTLINE"]                                      = "Contour épais"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["OPTIONS_FOCUS_BAR_LEFT_EDGE"]                                      = "Barre (bord gauche)"
L["OPTIONS_FOCUS_BAR_RIGHT_EDGE"]                                     = "Barre (bord droit)"
L["OPTIONS_FOCUS_BAR_TOP_EDGE"]                                       = "Barre (bord supérieur)"
L["OPTIONS_FOCUS_BAR_BOTTOM_EDGE"]                                    = "Barre (bord inférieur)"
L["OPTIONS_FOCUS_OUTLINE_ONLY_STYLE"]                                 = "Contour uniquement"
L["OPTIONS_FOCUS_SOFT_GLOW"]                                          = "Lueur douce"
L["OPTIONS_FOCUS_DUAL_EDGE_BARS"]                                     = "Barres doubles"
L["OPTIONS_FOCUS_PILL_LEFT_ACCENT"]                                   = "Accent pilule gauche"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["OPTIONS_FOCUS_TOP"]                                                = "Haut"
L["OPTIONS_FOCUS_BOTTOM"]                                             = "Bas"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["OPTIONS_VISTA_LOCATION_POSITION"]                                  = "Position du nom de zone"
L["OPTIONS_VISTA_PLACE_ZONE_NAME_ABOVE_BELOW_MINIMAP"]                = "Place le nom de zone au-dessus ou en dessous de la minicarte."
L["OPTIONS_VISTA_COORDINATES_POSITION"]                               = "Position des coordonnées"
L["OPTIONS_VISTA_PLACE_COORDINATES_ABOVE_BELOW_MINIMAP"]              = "Place les coordonnées au-dessus ou en dessous de la minicarte."
L["OPTIONS_VISTA_CLOCK_POSITION"]                                     = "Position de l'horloge"
L["OPTIONS_VISTA_PLACE_CLOCK_ABOVE_BELOW_MINIMAP"]                    = "Place l'horloge au-dessus ou en dessous de la minicarte."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["OPTIONS_FOCUS_LOWER_CASE"]                                         = "Minuscules"
L["OPTIONS_FOCUS_UPPER_CASE"]                                         = "Majuscules"
L["OPTIONS_FOCUS_PROPER"]                                             = "Première lettre en majuscule"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["OPTIONS_FOCUS_TRACKED_LOG"]                                        = "Suivies / Dans le journal"
L["OPTIONS_FOCUS_LOG_MAX_SLOTS"]                                      = "Dans le journal / Max"

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["OPTIONS_FOCUS_ALPHABETICAL"]                                       = "Alphabétique"
L["OPTIONS_FOCUS_QUEST_TYPE"]                                         = "Type de quête"
L["OPTIONS_FOCUS_QUEST_LEVEL"]                                        = "Niveau de quête"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["OPTIONS_FOCUS_CUSTOM"]                                             = "Personnalisé"
L["OPTIONS_FOCUS_ORDER"]                                              = "Ordre"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["UI_DUNGEON"]                                                       = "DONJON"
-- L["UI_RAID"]                                                       = "RAID"  -- NEEDS TRANSLATION
L["UI_DELVES"]                                                        = "GOUFFRES"
L["UI_SCENARIO_EVENTS"]                                               = "SCENARIO"
L["UI_STAGE"]                                                         = "Niveau"
L["UI_STAGE_X_X"]                                                     = "Niveau %d: %s"
L["UI_AVAILABLE_IN_ZONE"]                                             = "DISPONIBLE DANS LA ZONE"
L["UI_EVENTS_IN_ZONE"]                                                = "ÉVÈNEMENTS DANS LA ZONE"
L["UI_CURRENT_EVENT"]                                                 = "ÉVÈNEMENT EN COURS"
L["UI_CURRENT_QUEST"]                                                 = "QUÊTE EN COURS"
L["UI_CURRENT_ZONE"]                                                  = "ZONE ACTUELLE"
L["UI_CAMPAIGN"]                                                      = "CAMPAGNE"
-- L["UI_IMPORTANT"]                                                  = "IMPORTANT"  -- NEEDS TRANSLATION
L["UI_LEGENDARY"]                                                     = "LEGENDAIRE"
L["UI_WORLD_QUESTS"]                                                  = "EXPÉDITIONS"
L["UI_WEEKLY_QUESTS"]                                                 = "QUÊTES HEBDOMDAIRES"
L["UI_PREY"]                                                          = "Traque"
L["UI_ABUNDANCE"]                                                     = "Abondance"
L["UI_ABUNDANCE_BAG"]                                                 = "Sac d'abondance"
L["UI_ABUNDANCE_HELD"]                                                = "Abondance détenue"
L["UI_DAILY_QUESTS"]                                                  = "QUÊTES JOURNALIÈRES"
L["UI_RARE_BOSSES"]                                                   = "BOSS RARES"
L["UI_ACHIEVEMENTS"]                                                  = "HAUTS FAITS"
L["UI_ENDEAVORS"]                                                     = "INITIATIVES"
L["UI_DECOR"]                                                         = "DÉCORATION"
-- L["UI_RECIPES"]                                                    = "Recipes"  -- NEEDS TRANSLATION
-- L["UI_ADVENTURE_GUIDE"]                                            = "Adventure Guide"  -- NEEDS TRANSLATION
-- L["UI_APPEARANCES"]                                                = "Appearances"  -- NEEDS TRANSLATION
L["UI_QUESTS"]                                                        = "QUÊTES"
L["UI_READY_TO_TURN_IN"]                                              = "À RENDRE"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["PRESENCE_OBJECTIVES"]                                              = "OBJECTIFS"
-- L["PRESENCE_OPTIONS"]                                              = "Options"  -- NEEDS TRANSLATION
L["PRESENCE_OPEN_HORIZON_SUITE"]                                      = "Ouvrir Horizon Suite"
L["PRESENCE_OPEN_FULL_HORIZON_SUITE_OPTIONS"]                         = "Ouvre le panneau d'options complet pour configurer Focus, Presence, Vista et les autres modules."
L["PRESENCE_SHOW_MINIMAP_ICON"]                                       = "Afficher l'icône sur la minicarte"
L["PRESENCE_A_CLICKABLE_ICON_MINIMAP_OPENS"]                          = "Affiche une icône cliquable sur la minicarte qui ouvre le panneau d'options."
-- L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER"]              = "Fade until minimap hover"  -- NEEDS TRANSLATION
-- L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER_DESC"]         = "When on, the icon stays faded until you move the cursor over the minimap. When off, it stays fully visible."  -- NEEDS TRANSLATION
L["PRESENCE_LOCK_MINIMAP_BUTTON_POSITION"]                            = "Verrouiller le bouton de la minicarte"
L["PRESENCE_PREVENT_DRAGGING_HORIZON_MINIMAP_BUTTON"]                 = "Empêche de déplacer le bouton de la minicarte Horizon."
L["PRESENCE_RESET_MINIMAP_BUTTON_POSITION"]                           = "Réinitialiser la position du bouton de la minicarte"
L["PRESENCE_RESET_MINIMAP_BUTTON_DEFAULT_POSITION"]                   = "Replace le bouton de la minimap à sa position par défaut (en bas à gauche)."
L["PRESENCE_DRAG_TO_MOVE_WHEN_UNLOCKED"]                              = "Glisser pour déplacer (quand déverrouillé)."
L["PRESENCE_LOCKED"]                                                  = "Verrouillé"
L["PRESENCE_DISCOVERED"]                                              = "Découverte"
L["PRESENCE_REFRESH"]                                                 = "Actualiser"
L["PRESENCE_BEST_EFFORT_UNACCEPTED_QUESTS_EXPO"]                      = "Recherche approximative. Certaines quêtes non acceptées ne sont pas visibles avant d'interagir avec des PNJ ou dans certaines conditions de phase."
L["PRESENCE_UNACCEPTED_QUESTS_X_MAP_X"]                               = "Quêtes non acceptées - %s (carte %s) - %d correspondante(s)"
L["PRESENCE_LEVEL_UP"]                                                = "MONTÉE DE NIVEAU"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_80"]                               = "Vous avez atteint le niveau 80"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_X"]                                = "Vous avez atteint le niveau %s"
L["PRESENCE_ACHIEVEMENT_EARNED"]                                      = "HAUT FAIT OBTENU"
L["PRESENCE_EXPLORING_THE_MIDNIGHT_ISLES"]                            = "Exploration des Îles de Midnight"
L["PRESENCE_EXPLORING_KHAZ_ALGAR"]                                    = "Exploration de Khaz Algar"
L["PRESENCE_QUEST_COMPLETE"]                                          = "QUÊTE TERMINÉE"
L["PRESENCE_OBJECTIVE_SECURED"]                                       = "Objectif sécurisé"
L["PRESENCE_AIDING_THE_ACCORD"]                                       = "Aider l'Accord"
L["PRESENCE_WORLD_QUEST"]                                             = "EXPÉDITION"
L["PRESENCE_WORLD_QUEST_COMPLETE"]                                    = "EXPÉDITION TERMINÉE"
L["PRESENCE_AZERITE_MINING"]                                          = "Extraction d'azérite"
L["PRESENCE_WORLD_QUEST_ACCEPTED"]                                    = "EXPÉDITION ACCEPTÉE"
L["PRESENCE_QUEST_ACCEPTED"]                                          = "QUÊTE ACCEPTÉE"
L["PRESENCE_THE_FATE_OF_THE_HORDE"]                                   = "Le Destin de la Horde"
L["PRESENCE_NEW_QUEST"]                                               = "Nouvelle quête"
L["PRESENCE_QUEST_UPDATE"]                                            = "MISE À JOUR DE QUÊTE"
L["PRESENCE_BOAR_PELTS_7_10"]                                         = "Peaux de sanglier : 7/10"
L["PRESENCE_DRAGON_GLYPHS_3_5"]                                       = "Glyphes de dragon : 3/5"
L["PRESENCE_PRESENCE_TEST_COMMANDS"]                                  = "Commandes de test Presence :"
L["PRESENCE_H_PRESENCE_DEBUGTYPES_DUMP_NOTIFICATION"]                 = "  /h presence debugtypes - Rapporte toggle de notifications et les états de suppression Blizzard"
L["PRESENCE_PRESENCE_PLAYING_DEMO_REEL_NOTIFICATION"]                 = "Presence: Lecture de la démo (tous les types de notifications)..."
L["PRESENCE_H_PRESENCE_HELP_TEST_CURRENT"]                            = "  /h presence         - Afficher l'aide + test de la zone actuelle"
L["PRESENCE_H_PRESENCE_ZONE_TEST_ZONE"]                               = "  /h presence zone     - Test de changement de zone"
L["PRESENCE_H_PRESENCE_SUBZONE_TEST_SUBZONE"]                         = "  /h presence subzone  - Test de changement de sous-zone"
L["PRESENCE_H_PRESENCE_DISCOVER_TEST_ZONE"]                           = "  /h presence discover - Test de découverte de zone"
L["PRESENCE_H_PRESENCE_LEVEL_TEST_LEVEL"]                             = "  /h presence level    - Test de montée de niveau"
L["PRESENCE_H_PRESENCE_BOSS_TEST_BOSS"]                               = "  /h presence boss     - Test d'emote de boss"
L["PRESENCE_H_PRESENCE_ACH_TEST_ACHIEVEMENT"]                         = "  /h presence ach      - Test de haut fait"
L["PRESENCE_H_PRESENCE_ACCEPT_TEST_QUEST"]                            = "  /h presence accept   - Test de quête acceptée"
L["PRESENCE_H_PRESENCE_WQACCEPT_TEST_WORLD"]                          = "  /h presence wqaccept - Test d'expédition acceptée"
L["PRESENCE_H_PRESENCE_SCENARIO_TEST_SCENARIO"]                       = "  /h presence scenario - Test de début de scénario"
L["PRESENCE_H_PRESENCE_QUEST_TEST_QUEST"]                             = "  /h presence quest    - Test de quête terminée"
L["PRESENCE_H_PRESENCE_WQ_TEST_WORLD"]                                = "  /h presence wq       - Test d'expédition"
L["PRESENCE_H_PRESENCE_UPDATE_TEST_QUEST"]                            = "  /h presence update   - Test de mise à jour de quête"
L["PRESENCE_H_PRESENCE_ACHPROGRESS_TEST_ACHIEVEMENT"]                 = "  /h presence achprogress - Test de progression de haut fait"
L["PRESENCE_H_PRESENCE_DEMO_REEL_TYPES"]                              = "  /h presence all      - Démo (tous les types)"
L["PRESENCE_H_PRESENCE_DEBUG_DUMP_STATE"]                             = "  /h presence debug    - Rapporte les états dans le chat"
L["PRESENCE_H_PRESENCE_DEBUGLIVE_TOGGLE_LIVE"]                        = "  /h presence debuglive - Activer/désactiver le panneau de debug en direct (journaliser les événements)"

-- =====================================================================
-- OptionsData.lua Vista — General
L["OPTIONS_VISTA_POSITION_LAYOUT"]                                    = "Position & Mise en forme"

-- =====================================================================
L["OPTIONS_VISTA_MINIMAP"]                                            = "Minicarte"
L["OPTIONS_VISTA_MINIMAP_SIZE"]                                       = "Taille de la minicarte"
L["OPTIONS_VISTA_WIDTH_HEIGHT_OF_MINIMAP_PIXELS"]                     = "Largeur et hauteur de la minicarte en pixels (100–400)."
L["OPTIONS_VISTA_CIRCULAR_MINIMAP"]                                   = "Minicarte circulaire"
L["OPTIONS_VISTA_CIRCULAR_SHAPE"]                                     = "Forme circulaire"
L["OPTIONS_VISTA_A_CIRCULAR_MINIMAP_INSTEAD_OF_SQUARE"]               = "Utilise une minicarte circulaire au lieu de carrée."
L["OPTIONS_VISTA_LOCK_MINIMAP_POSITION"]                              = "Verrouiller la position de la minicarte"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MINIMAP"]                           = "Empêche de déplacer la minicarte."
L["OPTIONS_VISTA_RESET_MINIMAP_POSITION"]                             = "Réinitialiser la position de la minicarte"
L["OPTIONS_VISTA_RESET_MINIMAP_DEFAULT_POSITION_TOP_RIGHT"]           = "Réinitialise la minicarte à sa position par défaut (en haut à droite)."
-- L["OPTIONS_VISTA_RESET_OVERLAY_POSITIONS"]                         = "Reset overlay positions to defaults"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_RESET_OVERLAY_POSITIONS_DESC"]                       = "Clear saved positions for zone text, coordinates, clock, performance and difficulty text, zoom buttons, tracking, calendar, queue, mail, the addon button bar, drawer button, and right-click panel. The minimap frame position is not changed."
L["OPTIONS_VISTA_AUTO_ZOOM"]                                          = "Zoom automatique"
L["OPTIONS_VISTA_AUTO_ZOOM_DELAY"]                                    = "Délai de dézoom automatique"
L["OPTIONS_VISTA_SECONDS_AFTER_ZOOMING_BEFORE_AUTO_ZOOM"]             = "Secondes après un zoom avant le dézoom automatique. Mettre à 0 pour désactiver."

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["OPTIONS_VISTA_ZONE_TEXT_HEADER"]                                   = "Texte de zone"
L["OPTIONS_VISTA_ZONE_FONT"]                                          = "Police de zone"
L["OPTIONS_VISTA_FONT_ZONE_NAME_BELOW_MINIMAP"]                       = "Police du nom de zone sous la minicarte."
L["OPTIONS_VISTA_ZONE_FONT_SIZE"]                                     = "Taille de la police de zone"
L["OPTIONS_VISTA_ZONE_TEXT_COLOR"]                                    = "Couleur du texte de zone"
L["OPTIONS_VISTA_COLOR_OF_ZONE_NAME_TEXT"]                            = "Couleur du texte du nom de zone."
L["OPTIONS_VISTA_COORDINATES_TEXT"]                                   = "Texte des coordonnées"
L["OPTIONS_VISTA_COORDINATES_FONT"]                                   = "Police des coordonnées"
L["OPTIONS_VISTA_FONT_COORDINATES_TEXT_BELOW_MINIMAP"]                = "Police du texte des coordonnées sous la minicarte."
L["OPTIONS_VISTA_COORDINATES_FONT_SIZE"]                              = "Taille de la police des coordonnées"
L["OPTIONS_VISTA_COORDINATES_TEXT_COLOR"]                             = "Couleur du texte des coordonnées"
L["OPTIONS_VISTA_COLOR_OF_COORDINATES_TEXT"]                          = "Couleur du texte des coordonnées."
L["OPTIONS_VISTA_COORDINATE_PRECISION"]                               = "Précision des coordonnées"
L["OPTIONS_VISTA_NUMBER_OF_DECIMAL_PLACES_SHOWN_X"]                   = "Nombre de décimales affichées pour les coordonnées X et Y."
L["OPTIONS_VISTA_COORDS_DECIMALS_OFF"]                                = "Sans décimales (ex. 52, 37)"
L["OPTIONS_VISTA_DECIMAL_E_G"]                                        = "1 décimale (ex. 52.3, 37.1)"
L["OPTIONS_VISTA_DECIMALS_E_G"]                                       = "2 décimales (ex. 52.34, 37.12)"
L["OPTIONS_VISTA_TEXT"]                                               = "Texte de l'heure"
L["OPTIONS_VISTA_FONT"]                                               = "Police de l'heure"
L["OPTIONS_VISTA_FONT_TEXT_BELOW_MINIMAP"]                            = "Police du texte de l'heure sous la minicarte."
L["OPTIONS_VISTA_FONT_SIZE"]                                          = "Taille de la police de l'heure"
L["OPTIONS_VISTA_TEXT_COLOR"]                                         = "Couleur du texte de l'heure"
L["OPTIONS_VISTA_COLOR_OF_TEXT"]                                      = "Couleur du texte de l'heure."
L["OPTIONS_VISTA_PERFORMANCE_TEXT"]                                   = "Texte de performances"
L["OPTIONS_VISTA_PERFORMANCE_FONT"]                                   = "Police de performances"
L["OPTIONS_VISTA_FONT_FPS_LATENCY_TEXT_BELOW_MINIMAP"]                = "Police d'affichage des FPS et de la latence sous la minicarte."
L["OPTIONS_VISTA_PERFORMANCE_FONT_SIZE"]                              = "Taille de la police de performances"
L["OPTIONS_VISTA_PERFORMANCE_TEXT_COLOR"]                             = "Couleur du texte de performances"
L["OPTIONS_VISTA_COLOR_OF_FPS_LATENCY_TEXT"]                          = "Couleur des FPS et du texte."
L["OPTIONS_VISTA_DIFFICULTY_TEXT"]                                    = "Texte de difficulté"
L["OPTIONS_VISTA_DIFFICULTY_TEXT_COLOR_FALLBACK"]                     = "Couleur du texte de difficulté (par défaut)"
L["OPTIONS_VISTA_DEFAULT_COLOR_PER_DIFFICULTY_COLOR"]                 = "Couleur par défaut quand aucune couleur par difficulté n'est définie."
L["OPTIONS_VISTA_DIFFICULTY_FONT"]                                    = "Police de difficulté"
L["OPTIONS_VISTA_FONT_INSTANCE_DIFFICULTY_TEXT"]                      = "Police du texte de difficulté d'instance."
L["OPTIONS_VISTA_DIFFICULTY_FONT_SIZE"]                               = "Taille de la police de difficulté"
L["OPTIONS_VISTA_PER_DIFFICULTY_COLORS"]                              = "Couleurs par difficulté"
L["OPTIONS_VISTA_MYTHIC_COLOR"]                                       = "Couleur Mythique"
L["OPTIONS_VISTA_COLOR_MYTHIC_DIFFICULTY_TEXT"]                       = "Couleur du texte de difficulté Mythique."
L["OPTIONS_VISTA_HEROIC_COLOR"]                                       = "Couleur Héroïque"
L["OPTIONS_VISTA_COLOR_HEROIC_DIFFICULTY_TEXT"]                       = "Couleur du texte de difficulté Héroïque."
L["OPTIONS_VISTA_NORMAL_COLOR"]                                       = "Couleur Normal"
L["OPTIONS_VISTA_COLOR_NORMAL_DIFFICULTY_TEXT"]                       = "Couleur du texte de difficulté Normal."
L["OPTIONS_VISTA_LFR_COLOR"]                                          = "Couleur LFR"
L["OPTIONS_VISTA_COLOR_LOOKING_RAID_DIFFICULTY_TEXT"]                 = "Couleur du texte de difficulté Raid aléatoire."

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["OPTIONS_VISTA_TEXT_ELEMENTS"]                                      = "Éléments de texte"
L["OPTIONS_VISTA_ZONE_TEXT"]                                          = "Afficher le texte de zone"
L["OPTIONS_VISTA_ZONE_NAME_BELOW_MINIMAP"]                            = "Affiche le nom de zone sous la minicarte."
L["OPTIONS_VISTA_ZONE_TEXT_DISPLAY_MODE"]                             = "Mode d'affichage du texte de zone"
L["OPTIONS_VISTA_WHAT_ZONE_SUBZONE"]                                  = "Quoi afficher : zone seulement, sous-zone seulement, ou les deux."
L["OPTIONS_VISTA_ZONE"]                                               = "Zone seulement"
L["OPTIONS_VISTA_SUBZONE"]                                            = "Sous-zone seulement"
L["OPTIONS_VISTA_BOTH"]                                               = "Les deux"
L["OPTIONS_VISTA_COORDINATES"]                                        = "Afficher les coordonnées"
L["OPTIONS_VISTA_PLAYER_COORDINATES_BELOW_MINIMAP"]                   = "Affiche les coordonnées du joueur sous la minicarte."
L["OPTIONS_VISTA_TIME"]                                               = "Afficher l'heure"
L["OPTIONS_VISTA_CURRENT_GAME_BELOW_MINIMAP"]                         = "Affiche l'heure actuelle du jeu sous la minicarte."
L["OPTIONS_VISTA_HOUR_CLOCK"]                                         = "Affichage 24h"
L["OPTIONS_VISTA_DISPLAY_HOUR_FORMAT_E_G_INSTEAD"]                    = "Affiche l'heure dans un format 24h (ex 14:30 au lieu de 2:30 PM)."
L["OPTIONS_VISTA_LOCAL"]                                              = "Utiliser l'heure locale"
L["OPTIONS_VISTA_YOUR_LOCAL_SYSTEM"]                                  = "Activé : affiche l'heure locale du système. Désactivé : affiche l'heure du serveur."
L["OPTIONS_VISTA_FPS_LATENCY"]                                        = "Afficher les FPS et la latence"
L["OPTIONS_VISTA_FPS_LATENCY_MS_BELOW_MINIMAP"]                       = "Affiche les FPS et la latence (ms) sous la minicarte."
L["OPTIONS_VISTA_MINIMAP_BUTTONS"]                                    = "Boutons de minicarte"
L["OPTIONS_VISTA_QUEUE_STATUS_MAIL_INDICATOR_ALWAYS_SHOWN"]           = "Le statut de file et l'indicateur de courrier sont toujours affichés si pertinents."
L["OPTIONS_VISTA_TRACKING_BUTTON"]                                    = "Afficher le bouton de suivi"
L["OPTIONS_VISTA_MINIMAP_TRACKING_BUTTON"]                            = "Affiche le bouton de suivi sur la minicarte."
L["OPTIONS_VISTA_TRACKING_BUTTON_MOUSEOVER"]                          = "Bouton de suivi au survol uniquement"
L["OPTIONS_VISTA_HIDE_TRACKING_BUTTON_UNTIL_YOU_HOVER"]               = "Masque le bouton de suivi jusqu'au survol de la minicarte."
L["OPTIONS_VISTA_CALENDAR_BUTTON"]                                    = "Afficher le bouton de calendrier"
L["OPTIONS_VISTA_MINIMAP_CALENDAR_BUTTON"]                            = "Affiche le bouton de calendrier sur la minicarte."
L["OPTIONS_VISTA_CALENDAR_BUTTON_MOUSEOVER"]                          = "Bouton de calendrier au survol uniquement"
L["OPTIONS_VISTA_HIDE_CALENDAR_BUTTON_UNTIL_YOU_HOVER"]               = "Masque le bouton de calendrier jusqu'au survol de la minicarte."
L["OPTIONS_VISTA_ZOOM_BUTTONS"]                                       = "Afficher les boutons de zoom"
L["OPTIONS_VISTA_ZOOM_BUTTONS_MINIMAP"]                               = "Affiche les boutons de zoom + et - sur la minicarte."
L["OPTIONS_VISTA_ZOOM_BUTTONS_MOUSEOVER"]                             = "Boutons de zoom au survol uniquement"
L["OPTIONS_VISTA_HIDE_ZOOM_BUTTONS_UNTIL_YOU_HOVER"]                  = "Masque les boutons de zoom jusqu'au survol de la minicarte."

-- =====================================================================
-- OptionsData.lua Vista — Display (Border / Text Positions / Buttons)
-- =====================================================================
L["OPTIONS_VISTA_BORDER"]                                             = "Bordure"
L["OPTIONS_VISTA_A_BORDER_AROUND_MINIMAP"]                            = "Affiche une bordure autour de la minicarte."
L["OPTIONS_VISTA_BORDER_COLOR"]                                       = "Couleur de la bordure"
L["OPTIONS_VISTA_COLOR_OPACITY_OF_MINIMAP_BORDER"]                    = "Couleur (et opacité) de la bordure de la minicarte."
L["OPTIONS_VISTA_BORDER_THICKNESS"]                                   = "Épaisseur de la bordure"
L["OPTIONS_VISTA_THICKNESS_OF_MINIMAP_BORDER_PIXELS"]                 = "Épaisseur de la bordure de la minicarte en pixels (1–8)."
L["OPTIONS_VISTA_CLASS_COLOURS"]                                      = "Couleurs de classe"
L["OPTIONS_VISTA_TINT_VISTA_BORDER_TEXT_COORDS_FPS"]                  = "Colore les contours Vista (coordonnées, heure, affichage FPS/MS) avec la couleur de la classe. Les chiffres utilisent la couleur personnalisée."
L["OPTIONS_VISTA_TEXT_POSITIONS"]                                     = "Positions du texte"
L["OPTIONS_VISTA_DRAG_TEXT_ELEMENTS_REPOSITION_LOCK_PREVEN"]          = "Glissez les éléments de texte pour les repositionner. Verrouillez pour éviter les déplacements accidentels."
L["OPTIONS_VISTA_LOCK_ZONE_TEXT_POSITION"]                            = "Verrouiller la position du texte de zone"
L["OPTIONS_VISTA_ZONE_TEXT_CANNOT_DRAGGED"]                           = "Activé : le texte de zone ne peut pas être déplacé."
L["OPTIONS_VISTA_LOCK_COORDINATES_POSITION"]                          = "Verrouiller la position des coordonnées"
L["OPTIONS_VISTA_COORDINATES_TEXT_CANNOT_DRAGGED"]                    = "Activé : le texte des coordonnées ne peut pas être déplacé."
L["OPTIONS_VISTA_LOCK_POSITION"]                                      = "Verrouiller la position de l'heure"
L["OPTIONS_VISTA_TEXT_CANNOT_DRAGGED"]                                = "Activé : le texte de l'heure ne peut pas être déplacé."
L["OPTIONS_VISTA_PERFORMANCE_TEXT_POSITION"]                          = "Position du texte des performances."
L["OPTIONS_VISTA_PLACE_FPS_LATENCY_TEXT_ABOVE_BELOW"]                 = "Positionne le texte des FPS/latence au-dessus ou au-dessous de la minicarte."
L["OPTIONS_VISTA_LOCK_PERFORMANCE_TEXT_POSITION"]                     = "Verrouiller la position du texte des performances."
L["OPTIONS_VISTA_FPS_LATENCY_TEXT_CANNOT_DRAGGED"]                    = "Quand activé, le texte des FPS/latence ne peut plus être déplacé."
L["OPTIONS_VISTA_LOCK_DIFFICULTY_TEXT_POSITION"]                      = "Verrouiller la position du texte de difficulté"
L["OPTIONS_VISTA_DIFFICULTY_TEXT_CANNOT_DRAGGED"]                     = "Activé : le texte de difficulté ne peut pas être déplacé."
L["OPTIONS_VISTA_BUTTON_POSITIONS"]                                   = "Positions des boutons"
L["OPTIONS_VISTA_DRAG_BUTTONS_REPOSITION_LOCK_PREVENT_MOVE"]          = "Glissez les boutons pour les repositionner. Verrouillez pour bloquer le déplacement."
L["OPTIONS_VISTA_LOCK_ZOOM_BUTTON"]                                   = "Verrouiller le bouton Zoom +"
L["OPTIONS_VISTA_PREVENT_DRAGGING_ZOOM_BUTTON"]                       = "Empêche de déplacer le bouton de zoom +."
L["OPTIONS_VISTA_LOCK_ZOOM_OUT_BUTTON"]                               = "Verrouiller le bouton Zoom -"
L["OPTIONS_VISTA_LOCK_ZOOM_OUT_DRAG"]                                 = "Empêche de déplacer le bouton de zoom -."
L["OPTIONS_VISTA_LOCK_TRACKING_BUTTON"]                               = "Verrouiller le bouton de suivi"
L["OPTIONS_VISTA_PREVENT_DRAGGING_TRACKING_BUTTON"]                   = "Empêche de déplacer le bouton de suivi."
L["OPTIONS_VISTA_LOCK_CALENDAR_BUTTON"]                               = "Verrouiller le bouton de calendrier"
L["OPTIONS_VISTA_PREVENT_DRAGGING_CALENDAR_BUTTON"]                   = "Empêche de déplacer le bouton de calendrier."
L["OPTIONS_VISTA_LOCK_QUEUE_BUTTON"]                                  = "Verrouiller le bouton de la file d'attente"
L["OPTIONS_VISTA_PREVENT_DRAGGING_QUEUE_STATUS_BUTTON"]               = "Empêche de déplacer le bouton de statut de la file d'attente."
L["OPTIONS_VISTA_LOCK_MAIL_INDICATOR"]                                = "Verrouiller l'indicateur de courrier"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MAIL_ICON"]                         = "Empêche de déplacer l'icône de courrier."
L["OPTIONS_VISTA_DISABLE_QUEUE_HANDLING"]                             = "Désactiver la gestion de la file d'attente"
L["OPTIONS_VISTA_DISABLE_QUEUE_BUTTON_HANDLING"]                      = "Désactiver la gestion du bouton de la file d'attente"
L["OPTIONS_VISTA_TURN_QUEUE_BUTTON_ANCHORING_ANOTHER_A"]              = "Désactive tout ancrage du bouton de file d'attente (si un autre addon le gère)."
L["OPTIONS_VISTA_BUTTON_SIZES"]                                       = "Tailles des boutons"
L["OPTIONS_VISTA_ADJUST_SIZE_OF_MINIMAP_OVERLAY_BUTTONS"]             = "Ajuste la taille des boutons superposés à la minicarte."
L["OPTIONS_VISTA_TRACKING_BUTTON_SIZE"]                               = "Taille du bouton de suivi"
L["OPTIONS_VISTA_SIZE_OF_TRACKING_BUTTON_PIXELS"]                     = "Taille du bouton de suivi (pixels)."
L["OPTIONS_VISTA_CALENDAR_BUTTON_SIZE"]                               = "Taille du bouton de calendrier"
L["OPTIONS_VISTA_SIZE_OF_CALENDAR_BUTTON_PIXELS"]                     = "Taille du bouton de calendrier (pixels)."
L["OPTIONS_VISTA_QUEUE_BUTTON_SIZE"]                                  = "Taille du bouton de file"
L["OPTIONS_VISTA_SIZE_OF_QUEUE_STATUS_BUTTON_PIXELS"]                 = "Taille du bouton de statut de la file d'attente (pixels)."
L["OPTIONS_VISTA_ZOOM_BUTTON_SIZE"]                                   = "Taille des boutons de zoom"
L["OPTIONS_VISTA_SIZE_OF_ZOOM_ZOOM_BUTTONS_PIXELS"]                   = "Taille des boutons zoom + / zoom - (pixels)."
L["OPTIONS_VISTA_MAIL_INDICATOR_SIZE"]                                = "Taille de l'indicateur de courrier"
L["OPTIONS_VISTA_SIZE_OF_MAIL_ICON_PIXELS"]                           = "Taille de l'icône de nouveau courrier (pixels)."
L["OPTIONS_VISTA_ADDON_BUTTON_SIZE"]                                  = "Taille des boutons d'addon"
L["OPTIONS_VISTA_SIZE_OF_COLLECTED_ADDON_MINIMAP_BUTTONS"]            = "Taille des boutons d'addon collectés sur la minicarte (pixels)."

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
-- L["OPTIONS_VISTA_COLLECT_HORIZON_MINIMAP"]                         = "Include Horizon minimap icon"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_COLLECT_HORIZON_MINIMAP_DESC"]                    = "Put Horizon's own minimap icon in the managed addon bar, right-click panel, or drawer instead of leaving it on the minimap edge."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_ADDON_BUTTONS"]                                      = "Boutons d'addons"
L["OPTIONS_VISTA_MINIMAP_ADDON_BUTTONS"]                              = "Boutons d'addon sur la minicarte"
L["OPTIONS_VISTA_BUTTON_MANAGEMENT"]                                  = "Gestion des boutons"
L["OPTIONS_VISTA_MANAGE_ADDON_MINIMAP_BUTTONS"]                       = "Gérer les boutons d'addon sur la minicarte"
L["OPTIONS_VISTA_VISTA_TAKES_CONTROL_OF_ADDON_MINIMAP"]               = "Activé : Vista prend le contrôle des boutons d'addon et les regroupe selon le mode sélectionné."
L["OPTIONS_VISTA_BUTTON_MODE"]                                        = "Mode des boutons"
L["OPTIONS_VISTA_ADDON_BUTTONS_PRESENTED_HOVER_BAR_BELOW"]            = "Comment les boutons d'addon sont présentés : barre au survol, panneau au clic droit, ou tiroir flottant."
L["OPTIONS_VISTA_ALWAYS_BAR"]                                         = "Toujours montrer la barre"
L["OPTIONS_VISTA_ALWAYS_MOUSEOVER_BAR_POSITIONING"]                   = "Toujours montrer la barre au survol (pour déplacer)"
L["OPTIONS_VISTA_KEEP_MOUSEOVER_BAR_VISIBLE_TIMES_YOU"]               = "Toujours garder la barre au survol visible pour permettre son déplacement. Désactiver une fois terminé."
L["OPTIONS_VISTA_DISABLE_DONE"]                                       = "Désactiver une fois terminé."
L["OPTIONS_VISTA_MOUSEOVER_BAR"]                                      = "Barre au survol"
L["OPTIONS_VISTA_RIGHT_CLICK_PANEL"]                                  = "Panneau clic droit"
L["OPTIONS_VISTA_FLOATING_DRAWER"]                                    = "Tiroir flottant"
L["OPTIONS_VISTA_LOCK_DRAWER_BUTTON_POSITION"]                        = "Verrouiller la position du bouton tiroir"
L["OPTIONS_VISTA_PREVENT_DRAGGING_FLOATING_DRAWER_BUTTON"]            = "Empêche de déplacer le bouton du tiroir flottant."
L["OPTIONS_VISTA_LOCK_MOUSEOVER_BAR_POSITION"]                        = "Verrouiller la position de la barre au survol"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MOUSEOVER_BUTTON_BAR"]              = "Empêche de déplacer la barre de boutons au survol."
L["OPTIONS_VISTA_LOCK_RIGHT_CLICK_PANEL_POSITION"]                    = "Verrouiller la position du panneau clic droit"
L["OPTIONS_VISTA_PREVENT_DRAGGING_RIGHT_CLICK_PANEL"]                 = "Empêche de déplacer le panneau clic droit."
L["OPTIONS_VISTA_BUTTONS_PER_ROW_COLUMN"]                             = "Boutons par ligne/colonne"
L["OPTIONS_VISTA_CONTROLS_MANY_BUTTONS_APPEAR_BEFORE_WRAPPING"]       = "Contrôle le nombre de boutons avant retour à la ligne. Pour gauche/droite : colonnes ; pour haut/bas : lignes."
L["OPTIONS_VISTA_EXPAND_DIRECTION"]                                   = "Direction d'expansion"
L["OPTIONS_VISTA_DIRECTION_BUTTONS_FILL_ANCHOR_POINT_LEFT"]           = "Direction de remplissage depuis le point d'ancrage. Gauche/Droite = lignes horizontales. Haut/Bas = colonnes verticales."
L["OPTIONS_VISTA_RIGHT"]                                              = "Droite"
L["OPTIONS_VISTA_LEFT"]                                               = "Gauche"
L["OPTIONS_VISTA_DOWN"]                                               = "Bas"
L["OPTIONS_VISTA_UP"]                                                 = "Haut"
L["OPTIONS_VISTA_MOUSEOVER_BAR_APPEARANCE"]                           = "Apparence de la barre au survol"
L["OPTIONS_VISTA_BACKGROUND_BORDER_MOUSEOVER_BUTTON_BAR"]             = "Fond et contour de la barre de boutons au survol."
L["OPTIONS_VISTA_BACKDROP_COLOR"]                                     = "Couleur de fond"
L["OPTIONS_VISTA_BACKGROUND_COLOR_OF_MOUSEOVER_BUTTON_BAR"]           = "Couleur de fond de la barre de boutons au survol (Utiliser l'alpha pour controler la transparence)."
L["OPTIONS_VISTA_BAR_BORDER"]                                         = "Afficher les contours de la barre"
L["OPTIONS_VISTA_A_BORDER_AROUND_MOUSEOVER_BUTTON_BAR"]               = "Affiche un contour autour de la barre de boutons au survol."
L["OPTIONS_VISTA_BAR_BORDER_COLOR"]                                   = "Couleur de contour de la barre"
L["OPTIONS_VISTA_BORDER_COLOR_OF_MOUSEOVER_BUTTON_BAR"]               = "Couleur du contour de la barre de boutons au survol."
L["OPTIONS_VISTA_BAR_BACKGROUND_COLOR"]                               = "Couleur du fond de la barre"
L["OPTIONS_VISTA_PANEL_BACKGROUND_COLOR"]                             = "Couleur du fond du panneau."
L["OPTIONS_VISTA_CLOSE_FADE_TIMING"]                                  = "Timing de Fermeture / Fondu"
L["OPTIONS_VISTA_MOUSEOVER_BAR_CLOSE_DELAY_SECONDS"]                  = "Barre au survol — Délai de fermeture (secondes)"
L["OPTIONS_VISTA_LONG_SECONDS_BAR_STAYS_VISIBLE_AFTER"]               = "Combien de temps (en secondes) la barre reste visible après que le curseur ne la survole plus. 0 = fondu instantané."
L["OPTIONS_VISTA_RIGHT_CLICK_PANEL_CLOSE_DELAY_SECONDS"]              = "Clic droit sur le panneau — Délai de fermeture (secondes)"
L["OPTIONS_VISTA_LONG_SECONDS_PANEL_STAYS_OPEN_AFTER"]                = "Combien de temps (en secondes) le panneau reste ouvert après que le curseur ne la survole plus. 0 = ne ferme jamais (Fermer de nouveau avec un clic droit)."
L["OPTIONS_VISTA_FLOATING_DRAWER_CLOSE_DELAY_SECONDS"]                = "Conteneur flottant — Délai de fermeture (secondes)"
L["OPTIONS_VISTA_DRAWER_CLOSE_DELAY"]                                 = "Délai de fermeture du conteneur"
L["OPTIONS_VISTA_LONG_SECONDS_DRAWER_PANEL_STAYS_OPEN"]               = "Combien de temps (en secondes) le conteneur reste ouvert après avoir cliquer ailleurs. 0 = pas de fermeture automatique (ne ferme qu'en recliquant sur le bouton de conteneur)."
L["OPTIONS_VISTA_MAIL_ICON_BLINK"]                                    = "Clignotement de l'icône de courrier"
L["OPTIONS_VISTA_MAIL_ICON_PULSES_DRAW_ATTENTION"]                    = "Quand activé, l'icône de courrier clignote pour attirer l'attention. Désactivé, il reste fixe et opaque."
L["OPTIONS_VISTA_PANEL_APPEARANCE"]                                   = "Apparence du panneau"
L["OPTIONS_VISTA_COLORS_DRAWER_RIGHT_CLICK_BUTTON_PANELS"]            = "Couleurs pour le tiroir et les panneaux du clic droit."
L["OPTIONS_VISTA_PANEL_BG_COLOR_LABEL"]                               = "Couleur de fond du panneau"
L["OPTIONS_VISTA_BACKGROUND_COLOR_OF_ADDON_BUTTON_PANELS"]            = "Couleur de fond des boutons d'addons."
L["OPTIONS_VISTA_PANEL_BORDER_COLOR"]                                 = "Couleur de contour du panneau"
L["OPTIONS_VISTA_BORDER_COLOR_OF_ADDON_BUTTON_PANELS"]                = "Couleur de contour des boutons d'addons."
L["OPTIONS_VISTA_MANAGED_BUTTONS"]                                    = "Boutons gérés"
L["OPTIONS_VISTA_BUTTON_COMPLETELY_IGNORED_A"]                        = "Désactivé : ce bouton est complètement ignoré par cet addon."
L["OPTIONS_VISTA_ADDON_BUTTONS_DETECTED"]                             = "(Aucun bouton d'addon détecté)"
L["OPTIONS_VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE"]                      = "Boutons visibles (cocher pour inclure)"
L["OPTIONS_VISTA_ADDON_BUTTONS_DETECTED_OPEN_YOUR_MINIMAP"]           = "(Aucun bouton d'addon détecté — ouvrez d'abord votre minicarte)"

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
-- L["OPTIONS_CORE_GROUPING"]                                         = "Grouping"  -- NEEDS TRANSLATION
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
-- L["OPTIONS_CORE_SORTING_FILTERING"]                                = "Sorting & Filtering"  -- NEEDS TRANSLATION
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























































































