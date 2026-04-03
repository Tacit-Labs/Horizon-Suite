if GetLocale() ~= "esES" then return end

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = setmetatable({}, { __index = addon.L })
addon.L = L
addon.StandardFont = UNIT_NAME_FONT

-- =====================================================================
-- OptionsPanel.lua (deprecated) — remaining strings for that UI
-- Panel title + module short names: addon.BrandDisplay (core/BrandDisplay.lua).
-- =====================================================================
L["OPTIONS_FOCUS_OTHER"]                                              = "Otro"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["OPTIONS_FOCUS_QUEST_TYPES"]                                        = "Tipos de misiones"
L["OPTIONS_FOCUS_ELEMENT_OVERRIDES"]                                  = "Colores por elemento"
L["OPTIONS_FOCUS_PER_CATEGORY"]                                       = "Colores por categoría"
L["OPTIONS_FOCUS_GROUPING_OVERRIDES"]                                 = "Colores personalizados"
-- L["OPTIONS_FOCUS_SECTION_OVERRIDES"]                               = "Section Overrides"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_COLORS"]                                             = "Otros colores"

-- =====================================================================
-- OptionsPanel.lua — Color row labels (collapsible group sub-rows)
-- =====================================================================
L["OPTIONS_FOCUS_SECTION"]                                            = "Sección"
L["OPTIONS_FOCUS_TITLE"]                                              = "Título"
L["OPTIONS_FOCUS_ZONE"]                                               = "Zona"
L["OPTIONS_FOCUS_OBJECTIVE"]                                          = "Objetivo"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["OPTIONS_FOCUS_READY_TURN_OVERRIDES_BASE_COLOURS"]                  = "Usar colores distintos para la sección Listas para entregar"
L["OPTIONS_FOCUS_READY_TURN_COLOURS_QUESTS"]                          = "La sección Listas para entregar usará sus propios colores."
L["OPTIONS_FOCUS_CURRENT_ZONE_OVERRIDES_BASE_COLOURS"]                = "Usar colores distintos para la sección Zona actual"
L["OPTIONS_FOCUS_CURRENT_ZONE_COLOURS_QUESTS_SEC"]                    = "La sección Zona actual usará sus propios colores."
L["OPTIONS_FOCUS_CURRENT_QUEST_OVERRIDES_BASE_COLOURS"]               = "Usar colores distintos para la sección Misión actual"
L["OPTIONS_FOCUS_CURRENT_QUEST_COLOURS_QUESTS_SE"]                    = "La sección Misión actual usará sus propios colores."
L["OPTIONS_FOCUS_DISTINCT_COLOR_COMPLETED_OBJECTIVES"]                = "Usar color distinto para objetivos completados"
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES_E_G_COLOR_B"]                   = "Activado: los objetivos completados (ej. 1/1) usan el color de abajo. Desactivado: usan el mismo color que los incompletos."
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVE"]                                = "Objetivo completado"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["OPTIONS_FOCUS_RESET"]                                              = "Restablecer"
L["OPTIONS_FOCUS_RESET_QUEST_TYPES"]                                  = "Restablecer tipos de misiones"
L["OPTIONS_FOCUS_RESET_OVERRIDES"]                                    = "Restablecer colores personalizados"
L["OPTIONS_FOCUS_RESET_DEFAULTS"]                                     = "Restablecer todo a valores por defecto"
L["OPTIONS_FOCUS_RESET_TO_DEFAULTS"]                                  = "Restablecer valores por defecto"
L["OPTIONS_FOCUS_RESET_DEFAULT"]                                      = "Restablecer valor por defecto"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["OPTIONS_FOCUS_SEARCH_SETTINGS"]                                    = "Buscar opciones..."
L["OPTIONS_FOCUS_SEARCH_FONTS"]                                       = "Buscar fuentes..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["OPTIONS_FOCUS_DRAG_RESIZE"]                                        = "Arrastra para redimensionar"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
-- L["OPTIONS_AXIS_PROFILES"]                                         = "Profiles"  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_MODULES"]                                             = "Módulos"
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
L["DASH_LAYOUT"]                                                      = "Diseño"
L["DASH_VISIBILITY"]                                                  = "Visibilidad"
L["DASH_DISPLAY"]                                                     = "Visualización"
L["DASH_FEATURES"]                                                    = "Características"
L["DASH_TYPOGRAPHY"]                                                  = "Tipografía"
L["DASH_APPEARANCE"]                                                  = "Apariencia"
L["DASH_COLORS"]                                                      = "Colores"
L["DASH_ORGANIZATION"]                                                = "Organización"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["OPTIONS_FOCUS_PANEL_BEHAVIOUR"]                                    = "Comportamiento del panel"
L["OPTIONS_FOCUS_DIMENSIONS"]                                         = "Dimensiones"
L["OPTIONS_FOCUS_INSTANCE"]                                           = "Instancia"
-- L["OPTIONS_FOCUS_INSTANCES"]                                       = "Instances"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_COMBAT"]                                             = "Combate"
L["OPTIONS_FOCUS_FILTERING"]                                          = "Filtros"
L["OPTIONS_FOCUS_HEADER"]                                             = "Encabezado"
-- L["OPTIONS_FOCUS_SECTIONS_STRUCTURE"]                              = "Sections & structure"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_ENTRY_DETAILS"]                                   = "Entry details"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_PROGRESS_TIMERS"]                                 = "Progress & timers"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_EMPHASIS"]                                        = "Focus emphasis"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_LIST"]                                               = "Lista"
L["OPTIONS_FOCUS_SPACING"]                                            = "Espaciado"
L["OPTIONS_FOCUS_RARE_BOSSES"]                                        = "Jefes raros"
L["OPTIONS_FOCUS_WORLD_QUESTS"]                                       = "Misiones de mundo"
L["OPTIONS_FOCUS_FLOATING_QUEST_ITEM"]                                = "Objeto de misión flotante"
L["OPTIONS_FOCUS_MYTHIC"]                                             = "Mítico+"
L["OPTIONS_FOCUS_ACHIEVEMENTS"]                                       = "Logros"
L["OPTIONS_FOCUS_ENDEAVORS"]                                          = "Empeños"
L["OPTIONS_FOCUS_DECOR"]                                              = "Decoración"
-- L["OPTIONS_FOCUS_APPEARANCES"]                                     = "Appearances"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_SCENARIO_DELVE"]                                     = "Escenario y Sima"
L["OPTIONS_FOCUS_FONT"]                                               = "Fuente"
-- L["OPTIONS_FOCUS_FONT_FAMILIES"]                                   = "Font families"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_GLOBAL_FONT_SIZE"]                                = "Global font size"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_FONT_SIZES"]                                      = "Font sizes"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_PER_ELEMENT_FONTS"]                               = "Per-element fonts"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_TEXT_CASE"]                                          = "Mayúsculas/minúsculas"
L["OPTIONS_FOCUS_SHADOW"]                                             = "Sombra"
-- L["OPTIONS_FOCUS_PANEL"]                                           = "Panel"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_HIGHLIGHT"]                                          = "Resaltado"
L["OPTIONS_FOCUS_COLOR_MATRIX"]                                       = "Matriz de colores"
L["OPTIONS_FOCUS_ORDER"]                                              = "Orden"
L["OPTIONS_FOCUS_SORT"]                                               = "Ordenar"
L["OPTIONS_FOCUS_BEHAVIOUR"]                                          = "Comportamiento"
L["OPTIONS_FOCUS_CONTENT_TYPES"]                                      = "Tipos de contenido"
L["OPTIONS_FOCUS_DELVES"]                                             = "Simas"
L["OPTIONS_FOCUS_DELVES_DUNGEONS"]                                    = "Simas y Mazmorras"
L["OPTIONS_FOCUS_DELVE_COMPLETE"]                                     = "Sima completada"
L["OPTIONS_FOCUS_INTERACTIONS"]                                       = "Interacciones"
L["OPTIONS_FOCUS_TRACKING"]                                           = "Seguimiento"
L["OPTIONS_FOCUS_SCENARIO_BAR"]                                       = "Barra de escenario"

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
L["OPTIONS_AXIS_ENABLE_FOCUS_MODULE"]                                 = "Activar módulo Enfoque"
L["OPTIONS_AXIS_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS_R"]             = "Muestra el rastreador de objetivos para misiones, misiones de mundo, raros, logros y escenarios."
L["OPTIONS_AXIS_ENABLE_PRESENCE_MODULE"]                              = "Activar módulo Presencia"
L["OPTIONS_AXIS_CINEMATIC_ZONE_TEXT_NOTIFICATIONS_ZONE_CHANGES"]      = "Texto de zona cinematográfico y notificaciones (cambios de zona, subida de nivel, emotes de jefes, logros, actualizaciones de misiones)."
L["OPTIONS_AXIS_ENABLE_CACHE_MODULE"]                                 = "Activar módulo Cache"
L["OPTIONS_AXIS_CINEMATIC_LOOT_NOTIFICATIONS_ITEMS_MONEY_CURRENCY"]   = "Notificaciones cinematográficas de botín (objetos, oro, monedas, reputación)."
L["OPTIONS_AXIS_ENABLE_VISTA_MODULE"]                                 = "Activar módulo Vista"
L["OPTIONS_AXIS_CINEMATIC_SQUARE_MINIMAP_ZONE_TEXT_COORDINATES"]      = "Minimapa cuadrado cinematográfico con texto de zona, coordenadas y recopilador de botones."
-- L["OPTIONS_AXIS_MINIMAP_ZONE_TIME_COLLECTOR"]                      = "Cinematic square minimap with zone text, coordinates, time, and button collector."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_BETA"]                                             = "Beta"  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_SCALING"]                                             = "Escala"
-- L["OPTIONS_AXIS_GLOBAL_TOGGLES"]                                   = "Global Toggles"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_PATCH_NOTES_SECTION"]                              = "Patch notes"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN"]                   = "Show Patch Notes automatically after an update"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN_DESC"]              = "When on, Axis opens to Patch Notes once after each new addon version. When off, a green dot appears on the Horizon minimap icon until you open Patch Notes."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_SUITE_WIDE_CLASS_COLOUR_TINTING_UI"]               = "Dashboard background theme, class colour tinting, and UI scale (global or per module)."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_GLOBAL_UI_SCALE"]                                     = "Escala global de la interfaz"
L["OPTIONS_AXIS_SCALE_SIZES_SPACINGS_FONTS_FACTOR"]                   = "Escala todos los tamaños, espaciados y fuentes por este factor (50–200%). No cambia tus valores configurados."
L["OPTIONS_AXIS_PER_MODULE_SCALING"]                                  = "Escala por módulo"
L["OPTIONS_AXIS_OVERRIDE_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_FO"]         = "Reemplaza la escala global con controles deslizantes individuales para cada módulo."
-- L["OPTIONS_AXIS_OVERRIDES_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_F"]      = "Overrides the global scale with individual sliders for Focus, Presence, Vista, etc."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_DOESN_T_CHANGE_YOUR_CONFIGURED_VALUES"]            = "Doesn't change your configured values, only the effective display scale."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_SCALE"]                                              = "Escala Enfoque"
L["OPTIONS_AXIS_SCALE_FOCUS_OBJECTIVE_TRACKER"]                       = "Escala del rastreador de objetivos Enfoque (50–200%)."
L["OPTIONS_PRESENCE_SCALE"]                                           = "Escala Presencia"
L["OPTIONS_AXIS_SCALE_PRESENCE_CINEMATIC_TEXT"]                       = "Escala del texto cinematográfico Presencia (50–200%)."
L["OPTIONS_VISTA_SCALE"]                                              = "Escala Vista"
L["OPTIONS_AXIS_SCALE_VISTA_MINIMAP_MODULE"]                          = "Escala del módulo minimapa Vista (50–200%)."
L["OPTIONS_INSIGHT_SCALE"]                                            = "Escala Insight"
L["OPTIONS_AXIS_SCALE_INSIGHT_TOOLTIP_MODULE"]                        = "Escala del módulo de descripción Insight (50–200%)."
L["OPTIONS_CACHE_SCALE"]                                              = "Escala Cache"
L["OPTIONS_AXIS_SCALE_CACHE_LOOT_TOAST_MODULE"]                       = "Escala del módulo de notificaciones de botín Cache (50–200%)."
L["OPTIONS_AXIS_ENABLE_HORIZON_INSIGHT_MODULE"]                       = "Activar módulo Horizon Insight"
L["OPTIONS_AXIS_CINEMATIC_TOOLTIPS_CLASS_COLORS_SPEC_DISPLAY"]        = "Descripciones cinematográficas con colores de clase, especialización e iconos de facción."
L["OPTIONS_AXIS_TOOLTIP_ANCHOR_MODE"]                                 = "Modo de anclaje de descripciones"
L["OPTIONS_AXIS_WHERE_TOOLTIPS_APPEAR_FOLLOW_CURSOR_FIXED"]           = "Dónde aparecen las descripciones: seguir cursor o posición fija."
-- L["OPTIONS_AXIS_CURSOR"]                                           = "Cursor"  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_FIXED"]                                               = "Fijo"
L["OPTIONS_AXIS_ANCHOR_MOVE"]                                         = "Mostrar ancla para mover"
-- L["OPTIONS_AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITIO"]                   = "Click to show or hide the anchor. Drag to set position, right-click to confirm."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_DRAGGABLE_FRAME_FIXED_TOOLTIP_POSITION_D"]            = "Muestra un marco arrastrable para definir la posición fija. Arrastra y haz clic derecho para confirmar."
L["OPTIONS_AXIS_RESET_TOOLTIP_POSITION"]                              = "Restablecer posición de descripciones"
L["OPTIONS_AXIS_RESET_FIXED_POSITION_DEFAULT"]                        = "Restablecer posición fija al valor por defecto."
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_X"]                               = "Cursor offset X"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_X_DESC"]                          = "Horizontal pixel offset from the default cursor tooltip position (cursor anchor only)."  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_Y"]                               = "Cursor offset Y"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_Y_DESC"]                          = "Vertical pixel offset from the default cursor tooltip position (cursor anchor only)."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_TOOLTIP_BACKGROUND_COLOR"]                            = "Color de fondo de descripciones"
L["OPTIONS_AXIS_COLOR_OF_TOOLTIP_BACKGROUND"]                         = "Color de fondo de las descripciones."
L["OPTIONS_AXIS_TOOLTIP_BACKGROUND_OPACITY"]                          = "Opacidad del fondo de descripciones"
L["OPTIONS_AXIS_TOOLTIP_BG_OPACITY_PCT_DESC"]                         = "Opacidad del fondo de descripciones (0–100%)."
L["OPTIONS_AXIS_TOOLTIP_FONT"]                                        = "Fuente de descripciones"
L["OPTIONS_AXIS_FONT_FAMILY_TOOLTIP_TEXT"]                            = "Familia de fuentes usada para todo el texto de descripciones."
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
-- L["OPTIONS_AXIS_ITEM_TOOLTIP"]                                     = "Item Tooltip"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_TRANSMOG_STATUS"]                                  = "Show transmog status"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_WHETHER_YOU_COLLECTED_APPEARANCE_OF_AN"]           = "Show whether you have collected the appearance of an item you hover over."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_PLAYER_TOOLTIP"]                                   = "Player Tooltip"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_GUILD_RANK"]                                       = "Show guild rank"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_APPEND_PLAYER_S_GUILD_RANK_NEXT"]                  = "Append the player's guild rank next to their guild name."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_MYTHIC_SCORE"]                                     = "Show Mythic+ score"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_PLAYER_S_CURRENT_SEASON_MYTHIC_SCORE"]             = "Show the player's current season Mythic+ score, colour-coded by tier."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_ITEM_LEVEL"]                                       = "Show item level"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_PLAYER_S_EQUIPPED_ITEM_LEVEL_AFTER"]               = "Show the player's equipped item level after inspecting them."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_HONOR_LEVEL"]                                      = "Show honor level"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_PLAYER_S_PVP_HONOR_LEVEL_TOOLTIP"]                 = "Show the player's PvP honor level in the tooltip."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_PVP_TITLE"]                                        = "Show PvP title"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_PLAYER_S_PVP_TITLE_E_G"]                           = "Show the player's PvP title (e.g. Gladiator) in the tooltip."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_CHARACTER_TITLE"]                                  = "Character title"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_PLAYER_S_SELECTED_TITLE_ACHIEVEMENT_PVP"]          = "Show the player's selected title (achievement or PvP) in the name line."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_TITLE_COLOR"]                                      = "Title color"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_COLOR_OF_CHARACTER_TITLE_PLAYER_TOOLTIP"]          = "Color of the character title in the player tooltip name line."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_STATUS_BADGES"]                                    = "Show status badges"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_INLINE_BADGES_COMBAT_AFK_DND_PVP"]                 = "Show inline badges for combat, AFK, DND, PvP flag, party/raid membership, friends, and whether the player is targeting you."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_MOUNT_INFO"]                                       = "Show mount info"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_HOVERING_A_MOUNTED_PLAYER_THEIR_MOUNT"]            = "When hovering a mounted player, show their mount name, source, and whether you own it."  -- NEEDS TRANSLATION
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
-- L["OPTIONS_AXIS_GENERAL"]                                          = "General"  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_POSITION"]                                            = "Posición"
L["OPTIONS_AXIS_RESET_POSITION"]                                      = "Restablecer posición"
L["OPTIONS_AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"]                   = "Restablecer posición de notificaciones de botín."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["OPTIONS_FOCUS_LOCK_POSITION"]                                      = "Bloquear posición"
L["OPTIONS_FOCUS_PREVENT_DRAGGING_TRACKER"]                           = "Impide arrastrar el rastreador de objetivos."
L["OPTIONS_FOCUS_GROW_UPWARD"]                                        = "Crecer hacia arriba"
L["OPTIONS_FOCUS_GROW_HEADER"]                                        = "Encabezado al crecer"
L["OPTIONS_FOCUS_GROWING_UPWARD_KEEP_HEADER_BOTTOM_TOP"]              = "Al crecer hacia arriba: mantener encabezado abajo o arriba hasta colapsar."
L["OPTIONS_FOCUS_HEADER_BOTTOM"]                                      = "Encabezado abajo"
L["OPTIONS_FOCUS_HEADER_SLIDES_COLLAPSE"]                             = "Encabezado se desliza al colapsar"
L["OPTIONS_FOCUS_ANCHOR_BOTTOM_LIST_GROWS_UPWARD"]                    = "Anclar abajo para que la lista crezca hacia arriba."
L["OPTIONS_FOCUS_START_COLLAPSED"]                                    = "Iniciar colapsado"
L["OPTIONS_FOCUS_START_HEADER_SHOWN_UNTIL_YOU_EXPAND"]                = "Mostrar solo el encabezado hasta que lo expandas."
-- L["OPTIONS_FOCUS_ALIGN_CONTENT_RIGHT"]                             = "Align content right"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_RIGHT_ALIGN_QUEST_TITLES_OBJECTIVES_WITHIN"]      = "Right-align quest titles and objectives within the panel."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_PANEL_WIDTH"]                                        = "Ancho del panel"
L["OPTIONS_FOCUS_TRACKER_WIDTH_PIXELS"]                               = "Ancho del rastreador de objetivos en píxeles."
L["OPTIONS_FOCUS_MAX_CONTENT_HEIGHT"]                                 = "Altura máxima del contenido"
L["OPTIONS_FOCUS_MAX_HEIGHT_OF_SCROLLABLE_LIST_PIXELS"]               = "Altura máxima de la lista desplazable (píxeles)."

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["OPTIONS_FOCUS_ALWAYS_M_BLOCK"]                                     = "Mostrar siempre el bloque M+"
L["OPTIONS_FOCUS_M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]                = "Muestra el bloque M+ cuando haya una piedra angular activa."
L["OPTIONS_FOCUS_DUNGEON"]                                            = "Mostrar en mazmorra"
L["OPTIONS_FOCUS_TRACKER_PARTY_DUNGEONS"]                             = "Muestra el rastreador en mazmorras de grupo."
L["OPTIONS_FOCUS_RAID"]                                               = "Mostrar en banda"
L["OPTIONS_FOCUS_TRACKER_RAIDS"]                                      = "Muestra el rastreador en bandas."
L["OPTIONS_FOCUS_BATTLEGROUND"]                                       = "Mostrar en campo de batalla"
L["OPTIONS_FOCUS_TRACKER_BATTLEGROUNDS"]                              = "Muestra el rastreador en campos de batalla."
L["OPTIONS_FOCUS_ARENA"]                                              = "Mostrar en arena"
L["OPTIONS_FOCUS_TRACKER_ARENAS"]                                     = "Muestra el rastreador en arenas."
L["OPTIONS_FOCUS_HIDE_COMBAT"]                                        = "Ocultar en combate"
L["OPTIONS_FOCUS_HIDE_TRACKER_FLOATING_QUEST_ITEM_COMBAT"]            = "Oculta el rastreador y el objeto de misión flotante en combate."
L["OPTIONS_FOCUS_COMBAT_VISIBILITY"]                                  = "Visibilidad en combate"
L["OPTIONS_FOCUS_TRACKER_BEHAVES_COMBAT_FADE_REDUC"]                  = "Comportamiento del rastreador en combate: mostrar, atenuar o ocultar."
L["OPTIONS_FOCUS_SHOW"]                                               = "Mostrar"
L["OPTIONS_FOCUS_FADE"]                                               = "Atenuar"
L["OPTIONS_FOCUS_HIDE"]                                               = "Ocultar"
L["OPTIONS_FOCUS_COMBAT_FADE_OPACITY"]                                = "Opacidad atenuada en combate"
L["OPTIONS_FOCUS_VISIBLE_TRACKER_FADED_COMBAT"]                       = "Visibilidad del rastreador cuando está atenuado en combate (0 = invisible). Solo aplica cuando la visibilidad en combate es Atenuar."
L["OPTIONS_FOCUS_MOUSEOVER"]                                          = "Al pasar el ratón"
L["OPTIONS_FOCUS_SHOW_ONLY_MOUSEOVER"]                                = "Mostrar solo al pasar el ratón"
L["OPTIONS_FOCUS_FADE_TRACKER_HOVERING_MOVE_MOUSE"]                   = "Atenúa el rastreador cuando no pasas el ratón; pásalo por encima para mostrarlo."
L["OPTIONS_FOCUS_FADED_OPACITY"]                                      = "Opacidad atenuada"
L["OPTIONS_FOCUS_VISIBLE_TRACKER_FADED_INVISIBLE"]                    = "Visibilidad del rastreador cuando está atenuado (0 = invisible)."
L["OPTIONS_FOCUS_QUESTS_CURRENT_ZONE"]                                = "Solo misiones de la zona actual"
L["OPTIONS_FOCUS_HIDE_QUESTS_OUTSIDE_YOUR_CURRENT_ZONE"]              = "Oculta misiones fuera de tu zona actual."

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["OPTIONS_FOCUS_QUEST_COUNT"]                                        = "Mostrar contador de misiones"
L["OPTIONS_FOCUS_QUEST_COUNT_HEADER"]                                 = "Muestra el contador de misiones en el encabezado."
L["OPTIONS_FOCUS_HEADER_COUNT_FORMAT"]                                = "Formato del contador de misiones"
L["OPTIONS_FOCUS_TRACKED_LOG_LOG_MAX_SLOTS_TRACKED"]                  = "Seguidas/En registro o En registro/Máx. ranuras. Seguidas excluye misiones de mundo y de zona activa."
L["OPTIONS_FOCUS_HEADER_DIVIDER"]                                     = "Mostrar divisor del encabezado"
L["OPTIONS_FOCUS_LINE_BELOW_HEADER"]                                  = "Muestra la línea debajo del encabezado."
L["OPTIONS_FOCUS_HEADER_DIVIDER_COLOR"]                               = "Color del divisor del encabezado"
L["OPTIONS_FOCUS_COLOR_OF_LINE_BELOW_HEADER"]                         = "Color de la línea debajo del encabezado."
L["OPTIONS_FOCUS_SUPER_MINIMAL_MODE"]                                 = "Modo super minimalista"
L["OPTIONS_FOCUS_HIDE_HEADER_A_PURE_TEXT_LIST"]                       = "Oculta el encabezado para una lista de solo texto."
L["OPTIONS_FOCUS_OPTIONS_BUTTON"]                                     = "Mostrar botón de opciones"
L["OPTIONS_FOCUS_OPTIONS_BUTTON_TRACKER_HEADER"]                      = "Muestra el botón de opciones en el encabezado del rastreador."
L["OPTIONS_FOCUS_HEADER_COLOR"]                                       = "Color del encabezado"
L["OPTIONS_FOCUS_COLOR_OF_OBJECTIVES_HEADER_TEXT"]                    = "Color del texto del encabezado OBJETIVOS."
L["OPTIONS_FOCUS_HEADER_HEIGHT"]                                      = "Altura del encabezado"
L["OPTIONS_FOCUS_HEIGHT_OF_HEADER_BAR_PIXELS"]                        = "Altura de la barra del encabezado en píxeles (18–48)."

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["OPTIONS_FOCUS_SECTION_HEADERS"]                                    = "Mostrar encabezados de sección"
L["OPTIONS_FOCUS_CATEGORY_LABELS_ABOVE_GROUP"]                        = "Muestra las etiquetas de categoría encima de cada grupo."
L["OPTIONS_FOCUS_CATEGORY_HEADERS_COLLAPSED"]                         = "Mostrar encabezados de categoría cuando está colapsado"
L["OPTIONS_FOCUS_KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED_CLICK"]       = "Mantiene los encabezados visibles cuando está colapsado; haz clic para expandir una categoría."
L["OPTIONS_FOCUS_NEARBY_CURRENT_ZONE_GROUP"]                          = "Mostrar grupo Zona actual"
L["OPTIONS_FOCUS_ZONE_QUESTS_A_DEDICATED_CURRENT_ZONE"]               = "Muestra las misiones de zona en una sección dedicada. Desactivado: aparecen en su categoría normal."
L["OPTIONS_FOCUS_ZONE_LABELS"]                                        = "Mostrar etiquetas de zona"
L["OPTIONS_FOCUS_ZONE_NAME_UNDER_QUEST_TITLE"]                        = "Muestra el nombre de zona debajo de cada título de misión."
L["OPTIONS_FOCUS_ACTIVE_QUEST_HIGHLIGHT"]                             = "Resaltado de misión activa"
L["OPTIONS_FOCUS_FOCUSED_QUEST_HIGHLIGHTED"]                          = "Cómo se resalta la misión enfocada."
L["OPTIONS_FOCUS_QUEST_ITEM_BUTTONS"]                                 = "Mostrar botones de objeto de misión"
L["OPTIONS_FOCUS_USABLE_QUEST_ITEM_BUTTON_NEXT_QUEST"]                = "Muestra el botón de objeto utilizable junto a cada misión."
-- L["OPTIONS_FOCUS_TOOLTIPS_HOVER"]                                  = "Tooltips on hover"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_TOOLTIPS_HOVERING_TRACKER_ENTRIES_ITE"]           = "Show tooltips when hovering over tracker entries, item buttons, and scenario blocks."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_WOWHEAD_LINK_TOOLTIPS"]                           = "Show WoWhead link in tooltips"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_A_TOOLTIP_SHOWN_ADD_A_LINK"]                      = "When a tooltip is shown, add a link to open the quest, achievement, or NPC on WoWhead."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_VIEW_WOWHEAD"]                                    = "View on WoWhead"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_WOWHEAD_ALT_CLICK_HINT"]                             = "Alt+click row to copy"
-- L["OPTIONS_FOCUS_COPY_LINK"]                                       = "Copy link"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_COPY_URL_BELOW_CTRL_C_PASTE"]                     = "Copy the URL below (Ctrl+C) and paste in your browser."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_OBJECTIVE_NUMBERS"]                                  = "Mostrar números de objetivos"
-- L["OPTIONS_FOCUS_OBJECTIVE_PREFIX"]                                = "Objective prefix"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLORS"]                = "Color objective progress numbers"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLORS_DESC"]           = "Tint X/Y counts: normal color at 0/n, gold while in progress, green when complete. The slash uses the usual objective color."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_PREFIX_OBJECTIVE_A_NUMBER_HYPHEN"]                = "Prefix each objective with a number or hyphen."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_NUMBERS"]                                         = "Numbers (1. 2. 3.)"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_HYPHENS"]                                         = "Hyphens (-)"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_AFTER_SECTION_HEADER"]                            = "After section header"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_BEFORE_SECTION_HEADER"]                           = "Before section header"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_BELOW_HEADER"]                                    = "Below header"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_INLINE_BELOW_TITLE"]                              = "Inline below title"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_PREFIX_OBJECTIVES"]                                  = "Prefijar objetivos con 1., 2., 3."
L["OPTIONS_FOCUS_COMPLETED_COUNT"]                                    = "Mostrar contador de completados"
L["OPTIONS_FOCUS_X_Y_PROGRESS_QUEST_TITLE"]                           = "Muestra el progreso X/Y en el título de la misión."
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_BAR"]                             = "Mostrar barra de progreso de objetivos"
L["OPTIONS_FOCUS_A_PROGRESS_BAR_UNDER_OBJECTIVES_NUMER"]              = "Muestra una barra de progreso bajo objetivos con progreso numérico (ej. 3/250). Solo aplica a entradas con un solo objetivo aritmético donde la cantidad requerida es mayor que 1."
L["OPTIONS_FOCUS_CATEGORY_COLOR_PROGRESS_BAR"]                        = "Usar color de categoría para la barra"
L["OPTIONS_FOCUS_PROGRESS_BAR_MATCHES_QUEST_ACHIEVEME"]               = "Activado: la barra usa el color de la categoría. Desactivado: usa el color personalizado de abajo."
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXTURE"]                               = "Textura de barra de progreso"
L["OPTIONS_FOCUS_PROGRESS_BAR_TYPES"]                                 = "Tipos de barra de progreso"
L["OPTIONS_FOCUS_TEXTURE_PROGRESS_BAR_FILL"]                          = "Textura del relleno de la barra."
L["OPTIONS_FOCUS_TEXTURE_PROGRESS_BAR_FILL_SOLID_YOUR"]               = "Textura del relleno. Sólido usa tus colores. Los addons SharedMedia añaden más opciones."
L["OPTIONS_FOCUS_PROGRESS_BAR_X_Y_OBJECTIVES_PERCENT"]                = "Mostrar barra para objetivos X/Y, solo porcentaje, o ambos."
L["OPTIONS_FOCUS_X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]             = "X/Y: objetivos como 3/10. Porcentaje: objetivos como 45%."
L["OPTIONS_FOCUS_X_Y"]                                                = "Solo X/Y"
L["OPTIONS_FOCUS_PERCENT"]                                            = "Solo porcentaje"
L["OPTIONS_FOCUS_TICK_COMPLETED_OBJECTIVES"]                          = "Usar marca para objetivos completados"
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES_A_CHECKMARK_INSTEA"]            = "Activado: los objetivos completados muestran una marca (✓) en lugar de color verde."
L["OPTIONS_FOCUS_ENTRY_NUMBERS"]                                      = "Mostrar numeración de entradas"
L["OPTIONS_FOCUS_PREFIX_QUEST_TITLES_WITHIN_CATEGORY"]                = "Prefijar títulos de misiones con 1., 2., 3. en cada categoría."
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES"]                               = "Objetivos completados"
L["OPTIONS_FOCUS_MULTI_OBJECTIVE_QUESTS_DISPLAY_OBJECTIVES"]          = "Para misiones con varios objetivos, cómo mostrar los completados (ej. 1/1)."
L["OPTIONS_FOCUS_ALL"]                                                = "Mostrar todo"
L["OPTIONS_FOCUS_FADE_COMPLETED"]                                     = "Atenuar completados"
L["OPTIONS_FOCUS_HIDE_COMPLETED"]                                     = "Ocultar completados"
L["OPTIONS_FOCUS_ICON_ZONE_AUTO_TRACKING"]                            = "Mostrar icono de seguimiento automático en zona"
L["OPTIONS_FOCUS_DISPLAY_AN_ICON_NEXT_AUTO_TRACKED"]                  = "Muestra un icono junto a misiones de mundo y semanales/diarias con seguimiento automático que aún no están en tu registro (solo en zona)."
L["OPTIONS_FOCUS_AUTO_TRACK_ICON"]                                    = "Icono de seguimiento automático"
L["OPTIONS_FOCUS_CHOOSE_WHICH_ICON_DISPLAY_NEXT_AUTO"]                = "Elige qué icono mostrar junto a las entradas con seguimiento automático en zona."
L["OPTIONS_FOCUS_APPEND_WORLD_QUESTS_WEEKLIES_DAILIES"]               = "Añade ** a misiones de mundo y semanales/diarias que aún no están en tu registro (solo en zona)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["OPTIONS_FOCUS_COMPACT_MODE"]                                       = "Modo compacto"
L["OPTIONS_FOCUS_PRESET_SETS_ENTRY_OBJECTIVE_SPACING_P"]              = "Preajuste: espaciado de entradas y objetivos a 4 y 1 px."
L["OPTIONS_FOCUS_SPACING_PRESET"]                                     = "Preajuste de espaciado"
L["OPTIONS_FOCUS_PRESET_ENTRY_OBJECTIVE_SPACING_DEFAULT_P"]           = "Preajuste: Default (8/2 px), Compact (4/1 px), Spaced (12/3 px) o Custom (usar sliders)."
L["OPTIONS_FOCUS_COMPACT_VERSION"]                                    = "Versión compacta"
L["OPTIONS_FOCUS_SPACED_VERSION"]                                     = "Versión espaciada"
L["OPTIONS_FOCUS_SPACING_BETWEEN_QUEST_ENTRIES_PX"]                   = "Espaciado entre misiones (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_QUEST_ENTRIES"]                 = "Espacio vertical entre misiones."
L["OPTIONS_FOCUS_SPACING_BEFORE_CATEGORY_HEADER_PX"]                  = "Espaciado antes del encabezado (px)"
L["OPTIONS_FOCUS_GAP_BETWEEN_LAST_ENTRY_OF_A"]                        = "Espacio entre la última entrada de un grupo y la siguiente etiqueta de categoría."
L["OPTIONS_FOCUS_SPACING_AFTER_CATEGORY_HEADER_PX"]                   = "Espaciado después del encabezado (px)"
L["OPTIONS_FOCUS_GAP_BETWEEN_CATEGORY_LABEL_FIRST_QUEST"]             = "Espacio entre la etiqueta de categoría y la primera misión debajo."
L["OPTIONS_FOCUS_SPACING_BETWEEN_OBJECTIVES_PX"]                      = "Espaciado entre objetivos (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVE_LINES_WITHIN"]        = "Espacio vertical entre líneas de objetivos en una misión."
L["OPTIONS_FOCUS_TITLE_CONTENT"]                                      = "Título a contenido"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_QUEST_TITLE_OBJECTIVES"]        = "Espacio vertical entre el título de la misión y los objetivos o zona debajo."
L["OPTIONS_FOCUS_SPACING_BELOW_HEADER_PX"]                            = "Espaciado debajo del encabezado (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVES_BAR_QUES"]           = "Espacio entre la barra de objetivos y la lista de misiones."
L["OPTIONS_FOCUS_RESET_SPACING"]                                      = "Restablecer espaciado"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_QUEST_LEVEL"]                                   = "Mostrar nivel de misión"
L["OPTIONS_FOCUS_QUEST_LEVEL_NEXT_TITLE"]                             = "Muestra el nivel de misión junto al título."
L["OPTIONS_FOCUS_DIM_FOCUSED_QUESTS"]                                 = "Atenuar misiones no enfocadas"
L["OPTIONS_FOCUS_SLIGHTLY_DIM_TITLE_ZONE_OBJECTIVES_SECTION"]         = "Atenúa ligeramente títulos, zonas, objetivos y encabezados no enfocados."
-- L["OPTIONS_FOCUS_DIM_UNFOCUSED_ENTRIES"]                           = "Dim unfocused entries"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_A_SECTION_HEADER_EXPAND_CATEGORY"]          = "Click a section header to expand that category."  -- NEEDS TRANSLATION

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["UI_SHOW_RARE_BOSSES"]                                              = "Mostrar jefes raros"
L["UI_RARE_BOSS_VIGNETTES_LIST"]                                      = "Muestra los jefes raros en la lista."
L["UI_RARE_LOOT"]                                                     = "Botín raro"
L["UI_TREASURE_ITEM_VIGNETTES_RARE_LOOT"]                             = "Muestra tesoros y objetos en la lista de botín raro."
L["UI_RARE_SOUND_VOLUME"]                                             = "Volumen del sonido de botín raro"
L["UI_VOLUME_OF_RARE_ALERT_SOUND"]                                    = "Volumen del sonido de alerta de botín raro (50–200%)."
L["UI_BOOST_REDUCE_RARE_ALERT_VOLUME"]                                = "Aumenta o reduce el volumen. 100% = normal; 150% = más alto."
L["UI_RARE_ADDED_SOUND"]                                              = "Sonido al añadir raro"
L["UI_PLAY_A_SOUND_A_RARE"]                                           = "Reproduce un sonido cuando se añade un raro."
-- L["UI_MINIMAP_PATCH_NOTES_UNREAD_HINT"]                            = "New patch notes — open Axis and choose Patch Notes."  -- NEEDS TRANSLATION

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["OPTIONS_FOCUS_ZONE_WORLD_QUESTS"]                                  = "Mostrar misiones de mundo en zona"
L["OPTIONS_FOCUS_AUTO_ADD_WORLD_QUESTS_YOUR_CURRENT"]                 = "Añade automáticamente misiones de mundo de tu zona. Desactivado: solo las que sigues o las cercanas (predeterminado Blizzard)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_FLOATING_QUEST_ITEM"]                           = "Mostrar objeto de misión flotante"
L["OPTIONS_FOCUS_QUICK_BUTTON_FOCUSED_QUEST_S_USABLE"]                = "Muestra el botón de uso rápido del objeto utilizable de la misión enfocada."
L["OPTIONS_FOCUS_LOCK_FLOATING_QUEST_ITEM_POSITION"]                  = "Bloquear posición del objeto flotante"
L["OPTIONS_FOCUS_PREVENT_DRAGGING_FLOATING_QUEST_ITEM_BUTTON"]        = "Impide arrastrar el botón del objeto de misión flotante."
L["OPTIONS_FOCUS_FLOATING_QUEST_ITEM_SOURCE"]                         = "Origen del objeto flotante"
L["OPTIONS_FOCUS_WHICH_QUEST_S_ITEM_SUPER_TRACKED"]                   = "Qué objeto mostrar: primero el super-seguido o primero el de zona actual."
L["OPTIONS_FOCUS_SUPER_TRACKED_FIRST"]                                = "Super-seguido primero"
L["OPTIONS_FOCUS_CURRENT_ZONE_FIRST"]                                 = "Zona actual primero"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["OPTIONS_FOCUS_MYTHIC_BLOCK"]                                       = "Mostrar bloque Mítico+"
L["OPTIONS_FOCUS_TIMER_COMPLETION_AFFIXES_MYTHIC_DUNGEONS"]           = "Muestra temporizador, % de completado y afijos en mazmorras Mítico+."
L["OPTIONS_FOCUS_M_BLOCK_POSITION"]                                   = "Posición del bloque M+"
L["OPTIONS_FOCUS_POSITION_OF_MYTHIC_BLOCK_RELATIVE_QUEST"]            = "Posición del bloque M+ respecto a la lista de misiones."
L["OPTIONS_FOCUS_AFFIX_ICONS"]                                        = "Mostrar iconos de afijos"
L["OPTIONS_FOCUS_AFFIX_ICONS_NEXT_MODIFIER_NAMES_M"]                  = "Muestra iconos de afijos junto a los nombres en el bloque M+."
L["OPTIONS_FOCUS_AFFIX_DESCRIPTIONS_TOOLTIP"]                         = "Descripciones de afijos en descripción"
L["OPTIONS_FOCUS_AFFIX_DESCRIPTIONS_HOVERING_M_BLO"]                  = "Muestra descripciones de afijos al pasar el ratón sobre el bloque M+."
L["OPTIONS_FOCUS_M_COMPLETED_BOSS_DISPLAY"]                           = "Visualización de jefes M+ completados"
L["OPTIONS_FOCUS_DEFEATED_BOSSES_CHECKMARK_ICON_GREEN"]               = "Cómo mostrar jefes derrotados: icono de marca o color verde."
L["OPTIONS_FOCUS_CHECKMARK"]                                          = "Marca"
L["OPTIONS_FOCUS_GREEN_COLOR"]                                        = "Color verde"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["OPTIONS_PRESENCE_ACHIEVEMENTS"]                                    = "Mostrar logros"
L["OPTIONS_FOCUS_TRACKED_ACHIEVEMENTS_LIST"]                          = "Muestra los logros seguidos en la lista."
L["OPTIONS_FOCUS_COMPLETED_ACHIEVEMENTS"]                             = "Mostrar logros completados"
L["OPTIONS_FOCUS_INCLUDE_COMPLETED_ACHIEVEMENTS_TRACKER_O"]           = "Incluye logros completados. Desactivado: solo los seguidos en progreso."
L["OPTIONS_FOCUS_ACHIEVEMENT_ICONS"]                                  = "Mostrar iconos de logros"
L["OPTIONS_FOCUS_ACHIEVEMENT_S_ICON_NEXT_TITLE_REQUI"]                = "Muestra el icono de cada logro junto al título. Requiere 'Mostrar iconos de tipo de misión' en Visualización."
L["OPTIONS_FOCUS_MISSING_REQUIREMENTS"]                               = "Solo mostrar requisitos faltantes"
L["OPTIONS_FOCUS_CRITERIA_YOU_HAVEN_T_COMPLETED_TR"]                  = "Muestra solo los criterios no completados. Desactivado: se muestran todos."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_ENDEAVORS"]                                     = "Mostrar empeños"
L["OPTIONS_FOCUS_TRACKED_ENDEAVORS_PLAYER_HOUSING_LIST"]              = "Muestra los empeños seguidos (vivienda) en la lista."
L["OPTIONS_FOCUS_COMPLETED_ENDEAVORS"]                                = "Mostrar empeños completados"
L["OPTIONS_FOCUS_INCLUDE_COMPLETED_ENDEAVORS_TRACKER"]                = "Incluye empeños completados. Desactivado: solo los seguidos en progreso."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_DECOR"]                                         = "Mostrar decoración"
L["OPTIONS_FOCUS_TRACKED_HOUSING_DECOR_LIST"]                         = "Muestra la decoración de vivienda seguida en la lista."
L["OPTIONS_FOCUS_DECOR_ICONS"]                                        = "Mostrar iconos de decoración"
L["OPTIONS_FOCUS_DECOR_ITEM_S_ICON_NEXT_TITLE"]                       = "Muestra el icono de cada decoración junto al título. Requiere 'Mostrar iconos de tipo de misión' en Visualización."

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
L["OPTIONS_FOCUS_ADVENTURE_GUIDE"]                                    = "Guía de aventuras"
L["OPTIONS_FOCUS_TRAVELER_S_LOG"]                                     = "Mostrar Diario del viajero"
L["OPTIONS_FOCUS_TRACKED_TRAVELER_S_LOG_OBJECTIVES_SHIFT"]            = "Muestra los objetivos seguidos del Diario del viajero (Mayús+clic en Guía de aventuras) en la lista."
L["OPTIONS_FOCUS_AUTO_REMOVE_COMPLETED_ACTIVITIES"]                   = "Quitar automáticamente actividades completadas"
L["OPTIONS_FOCUS_AUTOMATICALLY_STOP_TRACKING_TRAVELER_S_LOG"]         = "Deja de seguir automáticamente las actividades del Diario del viajero al completarlas."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["OPTIONS_FOCUS_SCENARIO_EVENTS"]                                    = "Mostrar eventos de escenario"
L["OPTIONS_FOCUS_ACTIVE_SCENARIO_DELVE_ACTIVITIES_DELVES_APP"]        = "Muestra escenarios y Simas activos. Las Simas aparecen en SIMAS; otros en EVENTOS DE ESCENARIO."
L["OPTIONS_FOCUS_TRACK_DELVE_DUNGEON_SCENARIO_ACTIVITIES"]            = "Rastrear actividades de Simas, Mazmorras y escenarios."
L["OPTIONS_FOCUS_DELVES_APPEAR_DELVES_SECTION_DUNGEONS_DUNGEON"]      = "Las Simas en SIMAS; las mazmorras en MAZMORRA; otros en EVENTOS DE ESCENARIO."
-- L["OPTIONS_FOCUS_DELVES_APPEAR_DELVES_SECTION_SCENARIOS_S"]        = "Delves appear in Delves section; other scenarios in Scenario Events."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DELVE_AFFIX_NAMES"]                               = "Delve affix names"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DELVE_DUNGEON"]                                   = "Delve/Dungeon only"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_SCENARIO_DEBUG_LOGGING"]                          = "Scenario debug logging"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_LOG_SCENARIO_API_DATA_CHAT_H"]                    = "Log scenario API data to chat. Use /h debug focus scendebug to toggle."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_PRINTS_C_SCENARIOINFO_CRITERIA_WIDGET_DATA"]      = "Prints C_ScenarioInfo criteria and widget data when in a scenario. Helps diagnose display issues like Abundance 46/300."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_HIDE_CATEGORIES_DELVE_DUNGEON"]                      = "Ocultar otras categorías en Sima o Mazmorra"
L["OPTIONS_FOCUS_DELVES_PARTY_DUNGEONS_DELVE_DUNG"]                   = "En Simas o mazmorras de grupo, muestra solo la sección correspondiente."
L["OPTIONS_FOCUS_DELVE_NAME_SECTION_HEADER"]                          = "Usar nombre de Sima como encabezado"
L["OPTIONS_FOCUS_A_DELVE_DELVE_NAME_TIER_AFFIXES"]                    = "En una Sima: muestra nombre, nivel y afijos en el encabezado. Desactivado: muestra el bloque encima de la lista."
L["OPTIONS_FOCUS_AFFIX_NAMES_DELVES"]                                 = "Mostrar nombres de afijos en Simas"
L["OPTIONS_FOCUS_SEASON_AFFIX_NAMES_FIRST_DELVE_ENTRY"]               = "Muestra nombres de afijos de temporada en la primera entrada de Sima. Requiere widgets de Blizzard; puede no mostrarse con reemplazo completo."
L["OPTIONS_FOCUS_CINEMATIC_SCENARIO_BAR"]                             = "Barra de escenario cinematográfica"
L["OPTIONS_FOCUS_TIMER_PROGRESS_BAR_SCENARIO_ENTRIES"]                = "Muestra temporizador y barra de progreso para escenarios."
L["OPTIONS_FOCUS_TIMER"]                                              = "Mostrar temporizador"
L["OPTIONS_FOCUS_COUNTDOWN_TIMER_TIMED_QUESTS_EVENTS_SCEN"]           = "Muestra cuenta atrás en misiones, eventos y escenarios con tiempo. Desactivado: se ocultan todos los temporizadores."
L["OPTIONS_FOCUS_TIMER_SCENARIOS"]                                    = "Timers: scenarios & delves"
L["OPTIONS_FOCUS_TIMER_SCENARIOS_DESC"]                               = "Countdown timer for scenario, delve, and dungeon tracker entries."
L["OPTIONS_FOCUS_TIMER_WORLD"]                                        = "Timers: world & callings"
L["OPTIONS_FOCUS_TIMER_WORLD_DESC"]                                   = "Countdown timer for world quests and callings."
L["OPTIONS_FOCUS_TIMER_QUEST_LOG"]                                    = "Timers: quest log (timed)"
L["OPTIONS_FOCUS_TIMER_QUEST_LOG_DESC"]                               = "Countdown timer for dailies, weeklies, and other quest log entries with a time limit."
L["OPTIONS_FOCUS_TIMER_DISPLAY"]                                      = "Visualización del temporizador"
L["OPTIONS_FOCUS_COLOR_TIMER_REMAINING"]                              = "Colorear temporizador por tiempo restante"
L["OPTIONS_FOCUS_GREEN_PLENTY_OF_LEFT_YELLOW_RUNNING"]                = "Verde con tiempo de sobra, amarillo cuando queda poco, rojo cuando es crítico."
L["OPTIONS_FOCUS_WHERE_COUNTDOWN_BAR_BELOW_OBJECTIVES"]               = "Dónde mostrar la cuenta atrás: barra bajo objetivos o texto junto al nombre de la misión."
L["OPTIONS_FOCUS_BAR_BELOW"]                                          = "Barra debajo"
L["OPTIONS_FOCUS_INLINE_BESIDE_TITLE"]                                = "Texto junto al título"

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["OPTIONS_FOCUS_FONT_FAMILY"]                                        = "Familia de fuente."
L["OPTIONS_FOCUS_TITLE_FONT"]                                         = "Fuente de títulos"
L["OPTIONS_VISTA_ZONE_FONT"]                                          = "Fuente de zona"
L["OPTIONS_FOCUS_OBJECTIVE_FONT"]                                     = "Fuente de objetivos"
L["OPTIONS_FOCUS_SECTION_FONT"]                                       = "Fuente de secciones"
L["OPTIONS_FOCUS_GLOBAL_FONT"]                                        = "Usar fuente global"
L["OPTIONS_FOCUS_FONT_FAMILY_QUEST_TITLES"]                           = "Familia de fuente para títulos de misiones."
L["OPTIONS_FOCUS_FONT_FAMILY_ZONE_LABELS"]                            = "Familia de fuente para etiquetas de zona."
L["OPTIONS_FOCUS_FONT_FAMILY_OBJECTIVE_TEXT"]                         = "Familia de fuente para texto de objetivos."
L["OPTIONS_FOCUS_FONT_FAMILY_SECTION_HEADERS"]                        = "Familia de fuente para encabezados de sección."
L["OPTIONS_FOCUS_HEADER_SIZE"]                                        = "Tamaño del encabezado"
L["OPTIONS_FOCUS_HEADER_FONT_SIZE"]                                   = "Tamaño de fuente del encabezado."
L["OPTIONS_FOCUS_TITLE_SIZE"]                                         = "Tamaño del título"
L["OPTIONS_FOCUS_QUEST_TITLE_FONT_SIZE"]                              = "Tamaño de fuente de títulos de misiones."
L["OPTIONS_FOCUS_OBJECTIVE_SIZE"]                                     = "Tamaño de objetivos"
L["OPTIONS_FOCUS_OBJECTIVE_TEXT_FONT_SIZE"]                           = "Tamaño de fuente del texto de objetivos."
L["OPTIONS_FOCUS_ZONE_SIZE"]                                          = "Tamaño de zonas"
L["OPTIONS_FOCUS_ZONE_LABEL_FONT_SIZE"]                               = "Tamaño de fuente de etiquetas de zona."
L["OPTIONS_FOCUS_SECTION_SIZE"]                                       = "Tamaño de secciones"
L["OPTIONS_FOCUS_SECTION_HEADER_FONT_SIZE"]                           = "Tamaño de fuente de encabezados de sección."
L["OPTIONS_FOCUS_PROGRESS_BAR_FONT"]                                  = "Fuente de la barra de progreso"
L["OPTIONS_FOCUS_FONT_FAMILY_PROGRESS_BAR_LABEL"]                     = "Familia de fuente para la etiqueta de la barra de progreso."
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXT_SIZE"]                             = "Tamaño del texto de la barra de progreso"
L["OPTIONS_FOCUS_FONT_SIZE_PROGRESS_BAR_LABEL_ADJUSTS"]               = "Tamaño de fuente de la barra de progreso. También ajusta la altura. Afecta objetivos de misiones, progreso de escenarios y barras de temporizador."
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL"]                                  = "Relleno de la barra de progreso"
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXT"]                                  = "Texto de la barra de progreso"
L["OPTIONS_FOCUS_OUTLINE"]                                            = "Contorno"
L["OPTIONS_FOCUS_FONT_OUTLINE_STYLE"]                                 = "Estilo de contorno de fuente."

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["OPTIONS_FOCUS_HEADER_TEXT_CASE"]                                   = "Mayúsculas del encabezado"
L["OPTIONS_FOCUS_DISPLAY_CASE_HEADER"]                                = "Mayúsculas para el encabezado."
L["OPTIONS_FOCUS_SECTION_HEADER_CASE"]                                = "Mayúsculas de encabezados de sección"
L["OPTIONS_FOCUS_DISPLAY_CASE_CATEGORY_LABELS"]                       = "Mayúsculas para etiquetas de categoría."
L["OPTIONS_FOCUS_QUEST_TITLE_CASE"]                                   = "Mayúsculas de títulos de misiones"
L["OPTIONS_FOCUS_DISPLAY_CASE_QUEST_TITLES"]                          = "Mayúsculas para títulos de misiones."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["OPTIONS_FOCUS_TEXT_SHADOW"]                                        = "Mostrar sombra de texto"
L["OPTIONS_FOCUS_ENABLE_DROP_SHADOW_TEXT"]                            = "Activa la sombra del texto."
L["OPTIONS_FOCUS_SHADOW_X"]                                           = "Sombra X"
L["OPTIONS_FOCUS_HORIZONTAL_SHADOW_OFFSET"]                           = "Desplazamiento horizontal de la sombra."
L["OPTIONS_FOCUS_SHADOW_Y"]                                           = "Sombra Y"
L["OPTIONS_FOCUS_VERTICAL_SHADOW_OFFSET"]                             = "Desplazamiento vertical de la sombra."
L["OPTIONS_FOCUS_SHADOW_ALPHA"]                                       = "Opacidad de la sombra"
L["OPTIONS_FOCUS_SHADOW_OPACITY"]                                     = "Opacidad de la sombra (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["OPTIONS_FOCUS_MYTHIC_TYPOGRAPHY"]                                  = "Tipografía Mítico+"
L["OPTIONS_FOCUS_DUNGEON_NAME_SIZE"]                                  = "Tamaño del nombre de mazmorra"
L["OPTIONS_FOCUS_FONT_SIZE_DUNGEON_NAME_PX"]                          = "Tamaño de fuente del nombre de mazmorra (8–32 px)."
L["OPTIONS_FOCUS_DUNGEON_NAME_COLOR"]                                 = "Color del nombre de mazmorra"
L["OPTIONS_FOCUS_TEXT_COLOR_DUNGEON_NAME"]                            = "Color del texto del nombre de mazmorra."
L["OPTIONS_FOCUS_TIMER_SIZE"]                                         = "Tamaño del temporizador"
L["OPTIONS_FOCUS_FONT_SIZE_TIMER_PX"]                                 = "Tamaño de fuente del temporizador (8–32 px)."
L["OPTIONS_FOCUS_TIMER_COLOR"]                                        = "Color del temporizador"
L["OPTIONS_FOCUS_TEXT_COLOR_TIMER"]                                   = "Color del temporizador (dentro del tiempo)."
L["OPTIONS_FOCUS_TIMER_OVERTIME_COLOR"]                               = "Color del temporizador (tiempo excedido)"
L["OPTIONS_FOCUS_TEXT_COLOR_TIMER_LIMIT"]                             = "Color del temporizador cuando se excede el tiempo."
L["OPTIONS_FOCUS_PROGRESS_SIZE"]                                      = "Tamaño del progreso"
L["OPTIONS_FOCUS_FONT_SIZE_ENEMY_FORCES_PX"]                          = "Tamaño de fuente de fuerzas enemigas (8–32 px)."
L["OPTIONS_FOCUS_PROGRESS_COLOR"]                                     = "Color del progreso"
L["OPTIONS_FOCUS_TEXT_COLOR_ENEMY_FORCES"]                            = "Color del texto de fuerzas enemigas."
L["OPTIONS_FOCUS_BAR_FILL_COLOR"]                                     = "Color de relleno de la barra"
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL_COLOR_PROGRESS"]                   = "Color de relleno de la barra (en progreso)."
L["OPTIONS_FOCUS_BAR_COMPLETE_COLOR"]                                 = "Color de barra completada"
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL_COLOR_ENEMY_FORCES"]               = "Color de relleno cuando las fuerzas enemigas están al 100%."
L["OPTIONS_FOCUS_AFFIX_SIZE"]                                         = "Tamaño de afijos"
L["OPTIONS_FOCUS_FONT_SIZE_AFFIXES_PX"]                               = "Tamaño de fuente de afijos (8–32 px)."
L["OPTIONS_FOCUS_AFFIX_COLOR"]                                        = "Color de afijos"
L["OPTIONS_FOCUS_TEXT_COLOR_AFFIXES"]                                 = "Color del texto de afijos."
L["OPTIONS_FOCUS_BOSS_SIZE"]                                          = "Tamaño de nombres de jefes"
L["OPTIONS_FOCUS_FONT_SIZE_BOSS_NAMES_PX"]                            = "Tamaño de fuente de nombres de jefes (8–32 px)."
L["OPTIONS_FOCUS_BOSS_COLOR"]                                         = "Color de nombres de jefes"
L["OPTIONS_FOCUS_TEXT_COLOR_BOSS_NAMES"]                              = "Color del texto de nombres de jefes."
L["OPTIONS_FOCUS_RESET_MYTHIC_TYPOGRAPHY"]                            = "Restablecer tipografía M+"

-- =====================================================================
-- OptionsData.lua Appearance
-- =====================================================================
-- L["OPTIONS_FOCUS_FRAME"]                                           = "Frame"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLASS_COLOURS_DASHBOARD"]                         = "Class colours - Dashboard"  -- NEEDS TRANSLATION
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
-- L["OPTIONS_FOCUS_CLASS_COLORS"]                                    = "Class colors"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_TINT_DASHBOARD_ACCENTS_DIVIDERS_HIGHLIGHTS"]      = "Tint dashboard accents, dividers, and highlights with your class colour."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_THEME"]                                           = "Theme"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND"]                            = "Dashboard background"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_BACKGROUND_STYLE_MODULE_DASHBOARD_WINDOW_AXI"]    = "Background style for the module dashboard window (Axis). Default is flat; Midnight uses bundled artwork; Specialisation (auto) uses the in-game talent UI background for your current specialization."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_MIDNIGHT"]                   = "Midnight"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_CLASS_TALENTS"]              = "Specialisation (auto)"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_OPACITY"]                    = "Dashboard background opacity"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_ADJUST_OPACITY_OF_DASHBOARD_BACKGROUND"]          = "Adjust the opacity of the dashboard background (50–100%). Lower values let more of the game world show through."  -- NEEDS TRANSLATION
-- L["DASHBOARD_TYPO_SECTION"]                                        = "Dashboard text"  -- NEEDS TRANSLATION
-- L["DASHBOARD_TYPO_FONT"]                                           = "Dashboard font"  -- NEEDS TRANSLATION
-- L["DASHBOARD_TYPO_FONT_DESC"]                                      = "Font for the Axis settings window (sidebar, search, and option rows). Separate from the Focus tracker font. For CJK or mixed-script welcome text, pick a broad-coverage font (e.g. 2002) if needed."  -- NEEDS TRANSLATION
-- L["DASHBOARD_TYPO_SIZE"]                                           = "Dashboard text size"  -- NEEDS TRANSLATION
-- L["DASHBOARD_TYPO_SIZE_DESC"]                                      = "Nudge all dashboard text larger or smaller (−4 to +4), similar to Focus global font offset."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_BACKDROP_OPACITY"]                                   = "Opacidad del fondo"
L["OPTIONS_FOCUS_PANEL_BACKGROUND_OPACITY"]                           = "Opacidad del fondo del panel (0–1)."
L["OPTIONS_FOCUS_BORDER"]                                             = "Mostrar borde"
L["OPTIONS_FOCUS_BORDER_AROUND_TRACKER"]                              = "Muestra un borde alrededor del rastreador."
L["OPTIONS_FOCUS_SCROLL_INDICATOR"]                                   = "Mostrar indicador de desplazamiento"
L["OPTIONS_FOCUS_A_VISUAL_HINT_LIST_CONTENT_TH"]                      = "Muestra una pista visual cuando la lista tiene más contenido del visible."
L["OPTIONS_FOCUS_SCROLL_INDICATOR_STYLE"]                             = "Estilo del indicador de desplazamiento"
L["OPTIONS_FOCUS_CHOOSE_BETWEEN_A_FADE_GRADIENT_A"]                   = "Elige entre un degradado o una flecha pequeña para indicar contenido desplazable."
L["OPTIONS_FOCUS_ARROW"]                                              = "Flecha"
L["OPTIONS_FOCUS_HIGHLIGHT_ALPHA"]                                    = "Opacidad del resaltado"
L["OPTIONS_FOCUS_OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]                 = "Opacidad del resaltado de misión enfocada (0–1)."
L["OPTIONS_FOCUS_BAR_WIDTH"]                                          = "Ancho de la barra"
L["OPTIONS_FOCUS_WIDTH_OF_BAR_STYLE_HIGHLIGHTS_PX"]                   = "Ancho de las barras de resaltado (2–6 px)."

-- =====================================================================
-- OptionsData.lua Organization
-- =====================================================================
-- L["OPTIONS_FOCUS_ACTIVITY"]                                        = "Activity"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CONTENT"]                                         = "Content"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_SORTING"]                                         = "Sorting"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_ELEMENTS"]                                        = "Elements"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_CATEGORY_ORDER"]                                     = "Orden de categorías de Enfoque"
-- L["OPTIONS_FOCUS_CATEGORY_COLOR_BAR"]                              = "Category color for bar"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CHECKMARK_COMPLETED"]                             = "Checkmark for completed"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CURRENT_QUEST_CATEGORY"]                          = "Current Quest category"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CURRENT_QUEST_WINDOW"]                            = "Current Quest window"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_QUESTS_RECENT_PROGRESS_TOP"]                      = "Show quests with recent progress at the top."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_SECONDS_OF_RECENT_PROGRESS_CURRENT_QUEST"]        = "Seconds of recent progress to show in Current Quest (30–120)."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_QUESTS_YOU_MADE_PROGRESS_LAST_MINUTE"]            = "Quests you made progress on in the last minute appear in a dedicated section."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_CATEGORY_ORDER"]                                     = "Orden de categorías de Enfoque"
L["OPTIONS_FOCUS_DRAG_REORDER_CATEGORIES_DELVES_SCENARIO_EVENT"]      = "Arrastra para reordenar. SIMAS y EVENTOS DE ESCENARIO permanecen primero."
-- L["OPTIONS_FOCUS_DRAG_REORDER_DELVES_SCENARIOS_STAY_FIRST"]        = "Drag to reorder. Delves and Scenarios stay first."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_SORT_MODE"]                                          = "Modo de ordenación de Enfoque"
L["OPTIONS_FOCUS_ORDER_OF_ENTRIES_WITHIN_CATEGORY"]                   = "Orden de entradas dentro de cada categoría."
L["OPTIONS_FOCUS_AUTO_TRACK_ACCEPTED_QUESTS"]                         = "Seguir automáticamente misiones aceptadas"
L["OPTIONS_FOCUS_YOU_ACCEPT_A_QUEST_QUEST_LOG"]                       = "Al aceptar una misión (solo registro, no misiones de mundo), la añade al rastreador automáticamente."
L["OPTIONS_FOCUS_REQUIRE_CTRL_FOCUS_REMOVE"]                          = "Requerir Ctrl para enfocar y quitar"
L["OPTIONS_FOCUS_REQUIRE_CTRL_FOCUS_ADD_LEFT_UNFOCUS"]                = "Requiere Ctrl para enfocar (clic izquierdo) y quitar (clic derecho) para evitar clics accidentales."
-- L["OPTIONS_FOCUS_CTRL_FOCUS_UNTRACK"]                              = "Ctrl for focus / untrack"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CTRL_CLICK_COMPLETE"]                             = "Ctrl to click-complete"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_CLASSIC_CLICK_BEHAVIOUR"]                            = "Usar comportamiento de clic clásico"
-- L["OPTIONS_FOCUS_CLASSIC_CLICKS"]                                  = "Classic clicks"  -- NEEDS TRANSLATION
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
L["OPTIONS_FOCUS_SHARE_PARTY"]                                        = "Compartir con el grupo"
L["OPTIONS_FOCUS_ABANDON_QUEST"]                                      = "Abandonar misión"
L["OPTIONS_FOCUS_STOP_TRACKING"]                                      = "Dejar de seguir"
L["OPTIONS_FOCUS_QUEST_CANNOT_SHARED"]                                = "Esta misión no se puede compartir."
L["OPTIONS_FOCUS_YOU_MUST_A_PARTY_SHARE_QUEST"]                       = "Debes estar en un grupo para compartir esta misión."
L["OPTIONS_FOCUS_LEFT_CLICK_OPENS_QUEST_MAP_RIGHT"]                   = "Activado: clic izquierdo abre el mapa de misión, clic derecho muestra menú compartir/abandonar (estilo Blizzard). Desactivado: clic izquierdo enfoca, clic derecho deja de seguir; Ctrl+Clic derecho comparte con el grupo."
L["OPTIONS_FOCUS_ANIMATIONS"]                                         = "Focus animations"
L["OPTIONS_FOCUS_ENABLE_SLIDE_FADE_QUESTS"]                           = "Activa deslizamiento y fundido para misiones."
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_FLASH"]                           = "Destello de progreso de objetivo"
L["OPTIONS_FOCUS_FLASH_AN_OBJECTIVE_COMPLETES"]                       = "Muestra un destello cuando se completa un objetivo."
L["OPTIONS_FOCUS_FLASH_INTENSITY"]                                    = "Intensidad del destello"
L["OPTIONS_FOCUS_NOTICEABLE_OBJECTIVE_COMPLETE_FLASH"]                = "Qué tan notable es el destello al completar un objetivo."
L["OPTIONS_FOCUS_FLASH_COLOR"]                                        = "Color del destello"
L["OPTIONS_FOCUS_COLOR_OF_OBJECTIVE_COMPLETE_FLASH"]                  = "Color del destello al completar un objetivo."
L["OPTIONS_FOCUS_SUBTLE"]                                             = "Sutil"
L["OPTIONS_FOCUS_MEDIUM"]                                             = "Medio"
L["OPTIONS_FOCUS_STRONG"]                                             = "Fuerte"
L["OPTIONS_FOCUS_REQUIRE_CTRL_CLICK_COMPLETE"]                        = "Requerir Ctrl para clic y completar"
L["OPTIONS_FOCUS_REQUIRES_CTRL_LEFT_CLICK_COMPLETE_AUTO"]             = "Activado: requiere Ctrl+Clic izquierdo para completar. Desactivado: un simple clic izquierdo (predeterminado Blizzard). Solo afecta misiones completables por clic."
L["OPTIONS_FOCUS_SUPPRESS_UNTRACKED_UNTIL_RELOAD"]                    = "Ocultar no seguidas hasta recargar"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS_Z"]                 = "Activado: dejar de seguir oculta hasta recargar. Desactivado: reaparecen al volver a la zona."
L["OPTIONS_FOCUS_PERMANENTLY_SUPPRESS_UNTRACKED_QUESTS"]              = "Ocultar permanentemente misiones no seguidas"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACKED_WORLD_QUESTS_ZO"]              = "Activado: las no seguidas se ocultan permanentemente. Tiene prioridad sobre 'Ocultar hasta recargar'. Aceptar una oculta la quita de la lista negra."
L["OPTIONS_FOCUS_KEEP_CAMPAIGN_QUESTS_CATEGORY"]                      = "Mantener misiones de campaña en categoría"
L["OPTIONS_FOCUS_CAMPAIGN_QUESTS_READY_TURN_RE"]                      = "Activado: las misiones de campaña listas para entregar permanecen en Campaña en lugar de pasar a Completadas."
L["OPTIONS_FOCUS_KEEP_IMPORTANT_QUESTS_CATEGORY"]                     = "Mantener misiones importantes en categoría"
L["OPTIONS_FOCUS_IMPORTANT_QUESTS_READY_TURN_R"]                      = "Activado: las misiones importantes listas para entregar permanecen en Importante en lugar de pasar a Completadas."
L["OPTIONS_FOCUS_TOMTOM_QUEST_WAYPOINT"]                              = "Punto de referencia TomTom"
L["OPTIONS_FOCUS_A_TOMTOM_WAYPOINT_FOCUSING_A_QUEST"]                 = "Establecer un punto de referencia TomTom al enfocar una misión."
L["OPTIONS_FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_NEXT_QUEST"]            = "Requiere TomTom. Apunta la flecha al siguiente objetivo de misión."
L["OPTIONS_FOCUS_TOMTOM_RARE_WAYPOINT"]                               = "Punto de referencia TomTom (raro)"
L["OPTIONS_FOCUS_A_TOMTOM_WAYPOINT_CLICKING_A_RARE"]                  = "Establecer un punto de referencia TomTom al hacer clic en un jefe raro."
L["OPTIONS_FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_RARE_S"]                = "Requiere TomTom. Apunta la flecha a la ubicación del jefe raro."
-- L["OPTIONS_FOCUS_FIND_A_GROUP"]                                    = "Find a Group"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_SEARCH_A_GROUP_QUEST"]                      = "Click to search for a group for this quest."  -- NEEDS TRANSLATION

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
-- L["OPTIONS_FOCUS_BLACKLIST"]                                       = "Blacklist"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_BLACKLIST_UNTRACKED"]                             = "Blacklist untracked"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_ENABLE_BLACKLIST_UNTRACKED_BEHAVIOUR_ADD_QUEST"]  = "Enable 'Blacklist untracked' in Behaviour to add quests here."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_HIDDEN_QUESTS"]                                   = "Hidden Quests"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_QUESTS_HIDDEN_RIGHT_CLICK_UNTRACK"]               = "Quests hidden via right-click untrack."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_BLACKLISTED_QUESTS"]                                 = "Misiones en lista negra"
L["OPTIONS_FOCUS_PERMANENTLY_SUPPRESSED_QUESTS"]                      = "Misiones ocultas permanentemente"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACK_QUESTS_PERMANENTLY_SUPPRESS"]    = "Clic derecho para dejar de seguir con 'Ocultar permanentemente' activado para añadirlas aquí."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["OPTIONS_PRESENCE_QUEST_TYPE_ICONS"]                                = "Mostrar iconos de tipo de misión"
L["OPTIONS_PRESENCE_QUEST_TYPE_ICON_FOCUS_TRACKER_QUEST"]             = "Muestra en el rastreador: misión aceptada/completada, misión de mundo, actualización de misión."
L["OPTIONS_PRESENCE_QUEST_TYPE_ICONS_TOASTS"]                         = "Mostrar iconos de tipo de misión en notificaciones"
L["OPTIONS_PRESENCE_QUEST_TYPE_ICON_PRESENCE_TOASTS_QUEST"]           = "Muestra el icono de tipo de misión en notificaciones: aceptada/completada, misión de mundo, actualización."
L["OPTIONS_PRESENCE_TOAST_ICON_SIZE"]                                 = "Tamaño de iconos en notificaciones"
L["OPTIONS_PRESENCE_QUEST_ICON_SIZE_PRESENCE_TOASTS_PX"]              = "Tamaño de iconos de misión en notificaciones (16–36 px). Por defecto 24."
L["OPTIONS_PRESENCE_HIDE_QUEST_UPDATE_TITLE"]                         = "Ocultar título en avances de misión"
L["OPTIONS_PRESENCE_OBJECTIVE_LINE_QUEST_PROGRESS_TOAST"]             = "Muestra solo la línea de objetivo (ej. 7/10 Pieles de jabalí) sin el nombre de misión ni encabezado."
L["OPTIONS_PRESENCE_SHOW_DISCOVERY_LINE"]                             = "Mostrar línea de descubrimiento"
-- L["OPTIONS_PRESENCE_DISCOVERY_LINE"]                               = "Discovery line"  -- NEEDS TRANSLATION
L["OPTIONS_PRESENCE_DISCOVERED_UNDER_ZONE_SUBZONE_ENTERING_A"]        = "Muestra 'Descubierto' bajo zona/subzona al entrar en un área nueva."
L["OPTIONS_PRESENCE_FRAME_VERTICAL_POSITION"]                         = "Posición vertical del marco"
L["OPTIONS_PRESENCE_VERTICAL_OFFSET_OF_PRESENCE_FRAME_CENTER"]        = "Desplazamiento vertical del marco Presencia desde el centro (-300 a 0)."
L["OPTIONS_PRESENCE_FRAME_SCALE"]                                     = "Escala del marco"
L["OPTIONS_PRESENCE_SCALE_OF_PRESENCE_FRAME"]                         = "Escala del marco Presencia (0.5–2)."
L["OPTIONS_PRESENCE_BOSS_EMOTE_COLOR"]                                = "Color de emotes de jefes"
L["OPTIONS_PRESENCE_COLOR_OF_RAID_DUNGEON_BOSS_EMOTE"]                = "Color del texto de emotes de jefes en banda y mazmorra."
L["OPTIONS_PRESENCE_DISCOVERY_LINE_COLOR"]                            = "Color de la línea de descubrimiento"
L["OPTIONS_PRESENCE_COLOR_OF_DISCOVERED_LINE_UNDER_ZONE"]             = "Color de la línea 'Descubierto' bajo el texto de zona."
L["OPTIONS_PRESENCE_NOTIFICATION_TYPES"]                              = "Tipos de notificación"
-- L["OPTIONS_PRESENCE_NOTIFICATIONS"]                                = "Notifications"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_NOTIFICATION_ACHIEVEMENT_CRITERIA_UPDATE_T"]   = "Show notification when achievement criteria update (tracked achievements always; others when Blizzard provides the achievement ID)."  -- NEEDS TRANSLATION
L["OPTIONS_PRESENCE_ZONE_ENTRY"]                                      = "Mostrar entrada en zona"
L["OPTIONS_PRESENCE_ZONE_CHANGE_ENTERING_A_AREA"]                     = "Muestra notificación al entrar en un área nueva."
L["OPTIONS_PRESENCE_SUBZONE_CHANGES"]                                 = "Mostrar cambios de subzona"
L["OPTIONS_PRESENCE_SUBZONE_CHANGE_MOVING_WITHIN_SAME_ZONE"]          = "Muestra notificación al moverse entre subzonas en la misma zona."
L["OPTIONS_PRESENCE_HIDE_ZONE_NAME_SUBZONE_CHANGES"]                  = "Ocultar nombre de zona para cambios de subzona"
L["OPTIONS_PRESENCE_MOVING_BETWEEN_SUBZONES_WITHIN_SAME_ZONE"]        = "Al moverse entre subzonas, solo muestra el nombre de subzona. El nombre de zona aparece al entrar en una zona nueva."
-- L["OPTIONS_PRESENCE_SUPPRESS_DELVE"]                               = "Suppress in Delve"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_SUPPRESS_SCENARIO_PROGRESS_NOTIFICATIONS_DELVES"]= "Suppress scenario progress notifications in Delves."  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_HIDES_OBJECTIVE_UPDATE_POPUPS_WHILE_A"]        = "When on, hides objective update popups while in a Delve. Zone entry and completion toasts still show."  -- NEEDS TRANSLATION
L["OPTIONS_PRESENCE_SUPPRESS_ZONE_CHANGES_MYTHIC"]                    = "Suprimir cambios de zona en Mítico+"
L["OPTIONS_PRESENCE_MYTHIC_BOSS_EMOTES_ACHIEVEMENTS_LEV"]             = "En Mítico+, solo muestra emotes de jefes, logros y subida de nivel. Oculta notificaciones de zona, misión y escenario."
L["OPTIONS_PRESENCE_LEVEL"]                                           = "Mostrar subida de nivel"
L["OPTIONS_PRESENCE_LEVEL_NOTIFICATION"]                              = "Muestra la notificación de subida de nivel."
L["OPTIONS_PRESENCE_BOSS_EMOTES"]                                     = "Mostrar emotes de jefes"
L["OPTIONS_PRESENCE_RAID_DUNGEON_BOSS_EMOTE_NOTIFICATIONS"]           = "Muestra notificaciones de emotes de jefes en banda y mazmorra."
L["OPTIONS_PRESENCE_ACHIEVEMENTS"]                                    = "Mostrar logros"
L["OPTIONS_PRESENCE_ACHIEVEMENT_EARNED_NOTIFICATIONS"]                = "Muestra notificaciones de logros obtenidos."
L["OPTIONS_PRESENCE_ACHIEVEMENT_PROGRESS"]                            = "Progreso de logros"
L["OPTIONS_PRESENCE_ACHIEVEMENT_EARNED"]                              = "Logro obtenido"
L["OPTIONS_PRESENCE_QUEST_ACCEPTED"]                                  = "Misión aceptada"
L["OPTIONS_PRESENCE_WORLD_QUEST_ACCEPTED"]                            = "Misión de mundo aceptada"
L["OPTIONS_PRESENCE_SCENARIO_COMPLETE"]                               = "Escenario completado"
L["OPTIONS_PRESENCE_RARE_DEFEATED"]                                   = "Raro derrotado"
L["OPTIONS_PRESENCE_NOTIFICATION_TRACKED_ACHIEVEMENT_CRITERIA"]       = "Muestra notificación cuando se actualizan los criterios de un logro rastreado."
L["OPTIONS_PRESENCE_QUEST_ACCEPT"]                                    = "Mostrar aceptación de misión"
L["OPTIONS_PRESENCE_NOTIFICATION_ACCEPTING_A_QUEST"]                  = "Muestra notificación al aceptar una misión."
L["OPTIONS_PRESENCE_WORLD_QUEST_ACCEPT"]                              = "Mostrar aceptación de misión de mundo"
L["OPTIONS_PRESENCE_NOTIFICATION_ACCEPTING_A_WORLD_QUEST"]            = "Muestra notificación al aceptar una misión de mundo."
L["OPTIONS_PRESENCE_QUEST_COMPLETE"]                                  = "Mostrar misión completada"
L["OPTIONS_PRESENCE_NOTIFICATION_COMPLETING_A_QUEST"]                 = "Muestra notificación al completar una misión."
L["OPTIONS_PRESENCE_WORLD_QUEST_COMPLETE"]                            = "Mostrar misión de mundo completada"
L["OPTIONS_PRESENCE_NOTIFICATION_COMPLETING_A_WORLD_QUEST"]           = "Muestra notificación al completar una misión de mundo."
L["OPTIONS_PRESENCE_QUEST_PROGRESS"]                                  = "Mostrar progreso de misiones"
L["OPTIONS_PRESENCE_NOTIFICATION_QUEST_OBJECTIVES_UPDATE"]            = "Muestra notificación cuando se actualizan los objetivos."
L["OPTIONS_PRESENCE_OBJECTIVE"]                                       = "Solo objetivo"
L["OPTIONS_PRESENCE_QUEST_PROGRESS_HIDE_TITLE"]                       = "Muestra solo la línea del objetivo en las notificaciones de progreso, ocultando el título 'Actualización de misión'."
L["OPTIONS_PRESENCE_SCENARIO_START"]                                  = "Mostrar inicio de escenario"
L["OPTIONS_PRESENCE_NOTIFICATION_ENTERING_A_SCENARIO_DELVE"]          = "Muestra notificación al entrar en un escenario o Sima."
L["OPTIONS_PRESENCE_SCENARIO_PROGRESS"]                               = "Mostrar progreso de escenario"
L["OPTIONS_PRESENCE_NOTIFICATION_SCENARIO_DELVE_OBJECTIVES"]          = "Muestra notificación cuando se actualizan objetivos de escenario o Sima."
L["OPTIONS_PRESENCE_ANIMATION"]                                       = "Animación"
L["OPTIONS_PRESENCE_ENABLE_ANIMATIONS"]                               = "Activar animaciones"
L["OPTIONS_PRESENCE_ENABLE_ENTRANCE_EXIT_ANIMATIONS_PRESENCE"]        = "Activa animaciones de entrada y salida para notificaciones."
L["OPTIONS_PRESENCE_ENTRANCE_DURATION"]                               = "Duración de entrada"
L["OPTIONS_PRESENCE_DURATION_OF_ENTRANCE_ANIMATION_SECONDS"]          = "Duración de la animación de entrada en segundos (0.2–1.5)."
L["OPTIONS_PRESENCE_EXIT_DURATION"]                                   = "Duración de salida"
L["OPTIONS_PRESENCE_DURATION_OF_EXIT_ANIMATION_SECONDS"]              = "Duración de la animación de salida en segundos (0.2–1.5)."
L["OPTIONS_PRESENCE_HOLD_DURATION_SCALE"]                             = "Factor de duración de visualización"
L["OPTIONS_PRESENCE_MULTIPLIER_LONG_NOTIFICATION_STAYS_S"]            = "Multiplicador de cuánto tiempo permanece cada notificación en pantalla (0.5–2)."
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
L["DASH_TYPOGRAPHY"]                                                  = "Tipografía"
L["OPTIONS_PRESENCE_MAIN_TITLE_FONT"]                                 = "Fuente del título principal"
L["OPTIONS_PRESENCE_FONT_FAMILY_MAIN_TITLE"]                          = "Familia de fuente para el título principal."
L["OPTIONS_PRESENCE_SUBTITLE_FONT"]                                   = "Fuente del subtítulo"
L["OPTIONS_PRESENCE_FONT_FAMILY_SUBTITLE"]                            = "Familia de fuente para el subtítulo."
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
L["OPTIONS_FOCUS_NONE"]                                               = "Ninguno"
L["OPTIONS_FOCUS_THICK_OUTLINE"]                                      = "Contorno grueso"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["OPTIONS_FOCUS_BAR_LEFT_EDGE"]                                      = "Barra (borde izquierdo)"
L["OPTIONS_FOCUS_BAR_RIGHT_EDGE"]                                     = "Barra (borde derecho)"
L["OPTIONS_FOCUS_BAR_TOP_EDGE"]                                       = "Barra (borde superior)"
L["OPTIONS_FOCUS_BAR_BOTTOM_EDGE"]                                    = "Barra (borde inferior)"
L["OPTIONS_FOCUS_OUTLINE_ONLY_STYLE"]                                 = "Solo contorno"
L["OPTIONS_FOCUS_SOFT_GLOW"]                                          = "Brillo suave"
L["OPTIONS_FOCUS_DUAL_EDGE_BARS"]                                     = "Barras dobles"
L["OPTIONS_FOCUS_PILL_LEFT_ACCENT"]                                   = "Acento píldora izquierdo"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["OPTIONS_FOCUS_TOP"]                                                = "Arriba"
L["OPTIONS_FOCUS_BOTTOM"]                                             = "Abajo"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["OPTIONS_VISTA_LOCATION_POSITION"]                                  = "Posición del nombre de zona"
L["OPTIONS_VISTA_PLACE_ZONE_NAME_ABOVE_BELOW_MINIMAP"]                = "Coloca el nombre de zona encima o debajo del minimapa."
L["OPTIONS_VISTA_COORDINATES_POSITION"]                               = "Posición de coordenadas"
L["OPTIONS_VISTA_PLACE_COORDINATES_ABOVE_BELOW_MINIMAP"]              = "Coloca las coordenadas encima o debajo del minimapa."
L["OPTIONS_VISTA_CLOCK_POSITION"]                                     = "Posición del reloj"
L["OPTIONS_VISTA_PLACE_CLOCK_ABOVE_BELOW_MINIMAP"]                    = "Coloca el reloj encima o debajo del minimapa."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["OPTIONS_FOCUS_LOWER_CASE"]                                         = "Minúsculas"
L["OPTIONS_FOCUS_UPPER_CASE"]                                         = "Mayúsculas"
L["OPTIONS_FOCUS_PROPER"]                                             = "Primera letra mayúscula"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["OPTIONS_FOCUS_TRACKED_LOG"]                                        = "Seguidas / En registro"
L["OPTIONS_FOCUS_LOG_MAX_SLOTS"]                                      = "En registro / Máx. ranuras"

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["OPTIONS_FOCUS_ALPHABETICAL"]                                       = "Alfabético"
L["OPTIONS_FOCUS_QUEST_TYPE"]                                         = "Tipo de misión"
L["OPTIONS_FOCUS_QUEST_LEVEL"]                                        = "Nivel de misión"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["OPTIONS_FOCUS_CUSTOM"]                                             = "Personalizado"
L["OPTIONS_FOCUS_ORDER"]                                              = "Orden"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["UI_DUNGEON"]                                                       = "MAZMORRA"
L["UI_RAID"]                                                          = "BANDA"
L["UI_DELVES"]                                                        = "SIMAS"
L["UI_SCENARIO_EVENTS"]                                               = "EVENTOS DE ESCENARIO"
-- L["UI_STAGE"]                                                      = "Stage"  -- NEEDS TRANSLATION
-- L["UI_STAGE_X_X"]                                                  = "Stage %d: %s"  -- NEEDS TRANSLATION
L["UI_AVAILABLE_IN_ZONE"]                                             = "DISPONIBLE EN LA ZONA"
L["UI_EVENTS_IN_ZONE"]                                                = "Eventos en la zona"
L["UI_CURRENT_EVENT"]                                                 = "Evento actual"
L["UI_CURRENT_QUEST"]                                                 = "MISIÓN ACTUAL"
L["UI_CURRENT_ZONE"]                                                  = "ZONA ACTUAL"
L["UI_CAMPAIGN"]                                                      = "CAMPAÑA"
L["UI_IMPORTANT"]                                                     = "IMPORTANTE"
L["UI_LEGENDARY"]                                                     = "LEGENDARIA"
L["UI_WORLD_QUESTS"]                                                  = "MISIONES DE MUNDO"
L["UI_WEEKLY_QUESTS"]                                                 = "MISIONES SEMANALES"
L["UI_PREY"]                                                          = "Presa"
L["UI_ABUNDANCE"]                                                     = "Abundancia"
L["UI_ABUNDANCE_BAG"]                                                 = "Bolsa de abundancia"
L["UI_ABUNDANCE_HELD"]                                                = "abundancia retenida"
L["UI_DAILY_QUESTS"]                                                  = "MISIONES DIARIAS"
L["UI_RARE_BOSSES"]                                                   = "JEFES RAROS"
L["UI_ACHIEVEMENTS"]                                                  = "LOGROS"
L["UI_ENDEAVORS"]                                                     = "EMPEÑOS"
L["UI_DECOR"]                                                         = "DECORACIÓN"
-- L["UI_RECIPES"]                                                    = "Recipes"  -- NEEDS TRANSLATION
-- L["UI_ADVENTURE_GUIDE"]                                            = "Adventure Guide"  -- NEEDS TRANSLATION
-- L["UI_APPEARANCES"]                                                = "Appearances"  -- NEEDS TRANSLATION
L["UI_QUESTS"]                                                        = "MISIONES"
L["UI_READY_TO_TURN_IN"]                                              = "LISTAS PARA ENTREGAR"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["PRESENCE_OBJECTIVES"]                                              = "OBJETIVOS"
L["PRESENCE_OPTIONS"]                                                 = "Opciones"
L["PRESENCE_OPEN_HORIZON_SUITE"]                                      = "Abrir Horizon Suite"
L["PRESENCE_OPEN_FULL_HORIZON_SUITE_OPTIONS"]                         = "Abre el panel de opciones completo para configurar Focus, Presence, Vista y otros módulos."
L["PRESENCE_SHOW_MINIMAP_ICON"]                                       = "Mostrar icono en el minimapa"
L["PRESENCE_A_CLICKABLE_ICON_MINIMAP_OPENS"]                          = "Muestra un icono clicable en el minimapa que abre el panel de opciones."
-- L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER"]              = "Fade until minimap hover"  -- NEEDS TRANSLATION
-- L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER_DESC"]         = "When on, the icon stays faded until you move the cursor over the minimap. When off, it stays fully visible."  -- NEEDS TRANSLATION
-- L["PRESENCE_LOCK_MINIMAP_BUTTON_POSITION"]                         = "Lock minimap button position"  -- NEEDS TRANSLATION
-- L["PRESENCE_PREVENT_DRAGGING_HORIZON_MINIMAP_BUTTON"]              = "Prevent dragging the Horizon minimap button."  -- NEEDS TRANSLATION
-- L["PRESENCE_RESET_MINIMAP_BUTTON_POSITION"]                        = "Reset minimap button position"  -- NEEDS TRANSLATION
-- L["PRESENCE_RESET_MINIMAP_BUTTON_DEFAULT_POSITION"]                = "Reset the minimap button to the default position (bottom-left)."  -- NEEDS TRANSLATION
-- L["PRESENCE_DRAG_TO_MOVE_WHEN_UNLOCKED"]                           = "Drag to move (when unlocked)."  -- NEEDS TRANSLATION
-- L["PRESENCE_LOCKED"]                                               = "Locked"  -- NEEDS TRANSLATION
L["PRESENCE_DISCOVERED"]                                              = "Descubierto"
L["PRESENCE_REFRESH"]                                                 = "Actualizar"
L["PRESENCE_BEST_EFFORT_UNACCEPTED_QUESTS_EXPO"]                      = "Solo aproximado. Algunas misiones no aceptadas no aparecen hasta interactuar con PNJs o cumplir condiciones de fase."
L["PRESENCE_UNACCEPTED_QUESTS_X_MAP_X"]                               = "Misiones no aceptadas - %s (mapa %s) - %d coincidencia(s)"
L["PRESENCE_LEVEL_UP"]                                                = "SUBIDA DE NIVEL"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_80"]                               = "Has alcanzado el nivel 80"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_X"]                                = "Has alcanzado el nivel %s"
L["PRESENCE_ACHIEVEMENT_EARNED"]                                      = "LOGRO OBTENIDO"
L["PRESENCE_EXPLORING_THE_MIDNIGHT_ISLES"]                            = "Explorando las Islas de Medianoche"
L["PRESENCE_EXPLORING_KHAZ_ALGAR"]                                    = "Explorando Khaz Algar"
L["PRESENCE_QUEST_COMPLETE"]                                          = "MISIÓN COMPLETADA"
L["PRESENCE_OBJECTIVE_SECURED"]                                       = "Objetivo asegurado"
L["PRESENCE_AIDING_THE_ACCORD"]                                       = "Ayudando al Acuerdo"
L["PRESENCE_WORLD_QUEST"]                                             = "MISIÓN DE MUNDO"
L["PRESENCE_WORLD_QUEST_COMPLETE"]                                    = "MISIÓN DE MUNDO COMPLETADA"
L["PRESENCE_AZERITE_MINING"]                                          = "Minería de azerita"
L["PRESENCE_WORLD_QUEST_ACCEPTED"]                                    = "MISIÓN DE MUNDO ACEPTADA"
L["PRESENCE_QUEST_ACCEPTED"]                                          = "MISIÓN ACEPTADA"
L["PRESENCE_THE_FATE_OF_THE_HORDE"]                                   = "El Destino de la Horda"
L["PRESENCE_NEW_QUEST"]                                               = "Nueva misión"
L["PRESENCE_QUEST_UPDATE"]                                            = "ACTUALIZACIÓN DE MISIÓN"
L["PRESENCE_BOAR_PELTS_7_10"]                                         = "Pieles de jabalí: 7/10"
L["PRESENCE_DRAGON_GLYPHS_3_5"]                                       = "Glifos de dragón: 3/5"
L["PRESENCE_PRESENCE_TEST_COMMANDS"]                                  = "Comandos de prueba de Presencia:"
-- L["PRESENCE_H_PRESENCE_DEBUGTYPES_DUMP_NOTIFICATION"]              = "  /h presence debugtypes - Dump notification toggles and Blizzard suppression state"  -- NEEDS TRANSLATION
-- L["PRESENCE_PRESENCE_PLAYING_DEMO_REEL_NOTIFICATION"]              = "Presence: Playing demo reel (all notification types)..."  -- NEEDS TRANSLATION
L["PRESENCE_H_PRESENCE_HELP_TEST_CURRENT"]                            = "  /h presence         - Mostrar ayuda + probar zona actual"
L["PRESENCE_H_PRESENCE_ZONE_TEST_ZONE"]                               = "  /h presence zone     - Probar cambio de zona"
L["PRESENCE_H_PRESENCE_SUBZONE_TEST_SUBZONE"]                         = "  /h presence subzone  - Probar cambio de subzona"
L["PRESENCE_H_PRESENCE_DISCOVER_TEST_ZONE"]                           = "  /h presence discover - Probar descubrimiento de zona"
L["PRESENCE_H_PRESENCE_LEVEL_TEST_LEVEL"]                             = "  /h presence level    - Probar subida de nivel"
L["PRESENCE_H_PRESENCE_BOSS_TEST_BOSS"]                               = "  /h presence boss     - Probar emote de jefe"
L["PRESENCE_H_PRESENCE_ACH_TEST_ACHIEVEMENT"]                         = "  /h presence ach      - Probar logro"
L["PRESENCE_H_PRESENCE_ACCEPT_TEST_QUEST"]                            = "  /h presence accept   - Probar misión aceptada"
L["PRESENCE_H_PRESENCE_WQACCEPT_TEST_WORLD"]                          = "  /h presence wqaccept - Probar misión de mundo aceptada"
L["PRESENCE_H_PRESENCE_SCENARIO_TEST_SCENARIO"]                       = "  /h presence scenario - Probar inicio de escenario"
L["PRESENCE_H_PRESENCE_QUEST_TEST_QUEST"]                             = "  /h presence quest    - Probar misión completada"
L["PRESENCE_H_PRESENCE_WQ_TEST_WORLD"]                                = "  /h presence wq       - Probar misión de mundo"
L["PRESENCE_H_PRESENCE_UPDATE_TEST_QUEST"]                            = "  /h presence update   - Probar actualización de misión"
L["PRESENCE_H_PRESENCE_ACHPROGRESS_TEST_ACHIEVEMENT"]                 = "  /h presence achprogress - Probar progreso de logro"
L["PRESENCE_H_PRESENCE_DEMO_REEL_TYPES"]                              = "  /h presence all      - Demostración (todos los tipos)"
L["PRESENCE_H_PRESENCE_DEBUG_DUMP_STATE"]                             = "  /h presence debug    - Volcar estado al chat"
L["PRESENCE_H_PRESENCE_DEBUGLIVE_TOGGLE_LIVE"]                        = "  /h presence debuglive - Activar/desactivar panel de depuración en vivo (registrar eventos)"

-- =====================================================================
-- OptionsData.lua Vista — General
-- L["OPTIONS_VISTA_POSITION_LAYOUT"]                                 = "Position & layout"  -- NEEDS TRANSLATION

-- =====================================================================
L["OPTIONS_VISTA_MINIMAP"]                                            = "Minimapa"
L["OPTIONS_VISTA_MINIMAP_SIZE"]                                       = "Tamaño del minimapa"
L["OPTIONS_VISTA_WIDTH_HEIGHT_OF_MINIMAP_PIXELS"]                     = "Ancho y alto del minimapa en píxeles (100–400)."
L["OPTIONS_VISTA_CIRCULAR_MINIMAP"]                                   = "Minimapa circular"
-- L["OPTIONS_VISTA_CIRCULAR_SHAPE"]                                  = "Circular shape"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_A_CIRCULAR_MINIMAP_INSTEAD_OF_SQUARE"]               = "Usa un minimapa circular en lugar de cuadrado."
L["OPTIONS_VISTA_LOCK_MINIMAP_POSITION"]                              = "Bloquear posición del minimapa"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MINIMAP"]                           = "Impide arrastrar el minimapa."
L["OPTIONS_VISTA_RESET_MINIMAP_POSITION"]                             = "Restablecer posición del minimapa"
L["OPTIONS_VISTA_RESET_MINIMAP_DEFAULT_POSITION_TOP_RIGHT"]           = "Restablece el minimapa a su posición por defecto (arriba derecha)."
-- L["OPTIONS_VISTA_RESET_OVERLAY_POSITIONS"]                         = "Reset overlay positions to defaults"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_RESET_OVERLAY_POSITIONS_DESC"]                       = "Clear saved positions for zone text, coordinates, clock, performance and difficulty text, zoom buttons, tracking, calendar, queue, mail, the addon button bar, drawer button, and right-click panel. The minimap frame position is not changed."
L["OPTIONS_VISTA_AUTO_ZOOM"]                                          = "Zoom automático"
L["OPTIONS_VISTA_AUTO_ZOOM_DELAY"]                                    = "Retraso de zoom automático"
L["OPTIONS_VISTA_SECONDS_AFTER_ZOOMING_BEFORE_AUTO_ZOOM"]             = "Segundos tras hacer zoom antes del zoom automático. Pon 0 para desactivar."

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["OPTIONS_VISTA_ZONE_TEXT_HEADER"]                                   = "Texto de zona"
L["OPTIONS_VISTA_ZONE_FONT"]                                          = "Fuente de zona"
L["OPTIONS_VISTA_FONT_ZONE_NAME_BELOW_MINIMAP"]                       = "Fuente del nombre de zona debajo del minimapa."
L["OPTIONS_VISTA_ZONE_FONT_SIZE"]                                     = "Tamaño de fuente de zona"
L["OPTIONS_VISTA_ZONE_TEXT_COLOR"]                                    = "Color del texto de zona"
L["OPTIONS_VISTA_COLOR_OF_ZONE_NAME_TEXT"]                            = "Color del texto del nombre de zona."
L["OPTIONS_VISTA_COORDINATES_TEXT"]                                   = "Texto de coordenadas"
L["OPTIONS_VISTA_COORDINATES_FONT"]                                   = "Fuente de coordenadas"
L["OPTIONS_VISTA_FONT_COORDINATES_TEXT_BELOW_MINIMAP"]                = "Fuente del texto de coordenadas debajo del minimapa."
L["OPTIONS_VISTA_COORDINATES_FONT_SIZE"]                              = "Tamaño de fuente de coordenadas"
L["OPTIONS_VISTA_COORDINATES_TEXT_COLOR"]                             = "Color del texto de coordenadas"
L["OPTIONS_VISTA_COLOR_OF_COORDINATES_TEXT"]                          = "Color del texto de coordenadas."
L["OPTIONS_VISTA_COORDINATE_PRECISION"]                               = "Precisión de coordenadas"
L["OPTIONS_VISTA_NUMBER_OF_DECIMAL_PLACES_SHOWN_X"]                   = "Número de decimales mostrados para coordenadas X e Y."
L["OPTIONS_VISTA_COORDS_DECIMALS_OFF"]                                = "Sin decimales (ej. 52, 37)"
L["OPTIONS_VISTA_DECIMAL_E_G"]                                        = "1 decimal (ej. 52.3, 37.1)"
L["OPTIONS_VISTA_DECIMALS_E_G"]                                       = "2 decimales (ej. 52.34, 37.12)"
L["OPTIONS_VISTA_TEXT"]                                               = "Texto de hora"
L["OPTIONS_VISTA_FONT"]                                               = "Fuente de hora"
L["OPTIONS_VISTA_FONT_TEXT_BELOW_MINIMAP"]                            = "Fuente del texto de hora debajo del minimapa."
L["OPTIONS_VISTA_FONT_SIZE"]                                          = "Tamaño de fuente de hora"
L["OPTIONS_VISTA_TEXT_COLOR"]                                         = "Color del texto de hora"
L["OPTIONS_VISTA_COLOR_OF_TEXT"]                                      = "Color del texto de hora."
-- L["OPTIONS_VISTA_PERFORMANCE_TEXT"]                                = "Performance Text"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_PERFORMANCE_FONT"]                                = "Performance font"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_FONT_FPS_LATENCY_TEXT_BELOW_MINIMAP"]             = "Font for the FPS and latency text below the minimap."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_PERFORMANCE_FONT_SIZE"]                           = "Performance font size"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_PERFORMANCE_TEXT_COLOR"]                          = "Performance text color"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_COLOR_OF_FPS_LATENCY_TEXT"]                       = "Color of the FPS and latency text."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_DIFFICULTY_TEXT"]                                    = "Texto de dificultad"
L["OPTIONS_VISTA_DIFFICULTY_TEXT_COLOR_FALLBACK"]                     = "Color del texto de dificultad (reserva)"
L["OPTIONS_VISTA_DEFAULT_COLOR_PER_DIFFICULTY_COLOR"]                 = "Color por defecto cuando no hay color por dificultad."
L["OPTIONS_VISTA_DIFFICULTY_FONT"]                                    = "Fuente de dificultad"
L["OPTIONS_VISTA_FONT_INSTANCE_DIFFICULTY_TEXT"]                      = "Fuente del texto de dificultad de instancia."
L["OPTIONS_VISTA_DIFFICULTY_FONT_SIZE"]                               = "Tamaño de fuente de dificultad"
L["OPTIONS_VISTA_PER_DIFFICULTY_COLORS"]                              = "Colores por dificultad"
L["OPTIONS_VISTA_MYTHIC_COLOR"]                                       = "Color Mítico"
L["OPTIONS_VISTA_COLOR_MYTHIC_DIFFICULTY_TEXT"]                       = "Color del texto de dificultad Mítico."
L["OPTIONS_VISTA_HEROIC_COLOR"]                                       = "Color Heroico"
L["OPTIONS_VISTA_COLOR_HEROIC_DIFFICULTY_TEXT"]                       = "Color del texto de dificultad Heroico."
L["OPTIONS_VISTA_NORMAL_COLOR"]                                       = "Color Normal"
L["OPTIONS_VISTA_COLOR_NORMAL_DIFFICULTY_TEXT"]                       = "Color del texto de dificultad Normal."
L["OPTIONS_VISTA_LFR_COLOR"]                                          = "Color LFR"
L["OPTIONS_VISTA_COLOR_LOOKING_RAID_DIFFICULTY_TEXT"]                 = "Color del texto de dificultad Búsqueda de banda."

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["OPTIONS_VISTA_TEXT_ELEMENTS"]                                      = "Elementos de texto"
L["OPTIONS_VISTA_ZONE_TEXT"]                                          = "Mostrar texto de zona"
L["OPTIONS_VISTA_ZONE_NAME_BELOW_MINIMAP"]                            = "Muestra el nombre de zona debajo del minimapa."
L["OPTIONS_VISTA_ZONE_TEXT_DISPLAY_MODE"]                             = "Modo de visualización del texto de zona"
L["OPTIONS_VISTA_WHAT_ZONE_SUBZONE"]                                  = "Qué mostrar: solo zona, solo subzona o ambos."
L["OPTIONS_VISTA_ZONE"]                                               = "Solo zona"
L["OPTIONS_VISTA_SUBZONE"]                                            = "Solo subzona"
L["OPTIONS_VISTA_BOTH"]                                               = "Ambos"
L["OPTIONS_VISTA_COORDINATES"]                                        = "Mostrar coordenadas"
L["OPTIONS_VISTA_PLAYER_COORDINATES_BELOW_MINIMAP"]                   = "Muestra las coordenadas del jugador debajo del minimapa."
L["OPTIONS_VISTA_TIME"]                                               = "Mostrar hora"
L["OPTIONS_VISTA_CURRENT_GAME_BELOW_MINIMAP"]                         = "Muestra la hora actual del juego debajo del minimapa."
-- L["OPTIONS_VISTA_HOUR_CLOCK"]                                      = "24-hour clock"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_DISPLAY_HOUR_FORMAT_E_G_INSTEAD"]                 = "Display time in 24-hour format (e.g. 14:30 instead of 2:30 PM)."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_LOCAL"]                                              = "Usar hora local"
L["OPTIONS_VISTA_YOUR_LOCAL_SYSTEM"]                                  = "Activado: muestra la hora local del sistema. Desactivado: muestra la hora del servidor."
-- L["OPTIONS_VISTA_FPS_LATENCY"]                                     = "Show FPS and latency"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_FPS_LATENCY_MS_BELOW_MINIMAP"]                    = "Show FPS and latency (ms) below the minimap."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_MINIMAP_BUTTONS"]                                    = "Botones del minimapa"
L["OPTIONS_VISTA_QUEUE_STATUS_MAIL_INDICATOR_ALWAYS_SHOWN"]           = "El estado de cola y el indicador de correo se muestran cuando son relevantes."
L["OPTIONS_VISTA_TRACKING_BUTTON"]                                    = "Mostrar botón de seguimiento"
L["OPTIONS_VISTA_MINIMAP_TRACKING_BUTTON"]                            = "Muestra el botón de seguimiento en el minimapa."
L["OPTIONS_VISTA_TRACKING_BUTTON_MOUSEOVER"]                          = "Botón de seguimiento solo al pasar el ratón"
L["OPTIONS_VISTA_HIDE_TRACKING_BUTTON_UNTIL_YOU_HOVER"]               = "Oculta el botón de seguimiento hasta pasar el ratón sobre el minimapa."
L["OPTIONS_VISTA_CALENDAR_BUTTON"]                                    = "Mostrar botón de calendario"
L["OPTIONS_VISTA_MINIMAP_CALENDAR_BUTTON"]                            = "Muestra el botón de calendario en el minimapa."
L["OPTIONS_VISTA_CALENDAR_BUTTON_MOUSEOVER"]                          = "Botón de calendario solo al pasar el ratón"
L["OPTIONS_VISTA_HIDE_CALENDAR_BUTTON_UNTIL_YOU_HOVER"]               = "Oculta el botón de calendario hasta pasar el ratón sobre el minimapa."
L["OPTIONS_VISTA_ZOOM_BUTTONS"]                                       = "Mostrar botones de zoom"
L["OPTIONS_VISTA_ZOOM_BUTTONS_MINIMAP"]                               = "Muestra los botones de zoom + y - en el minimapa."
L["OPTIONS_VISTA_ZOOM_BUTTONS_MOUSEOVER"]                             = "Botones de zoom solo al pasar el ratón"
L["OPTIONS_VISTA_HIDE_ZOOM_BUTTONS_UNTIL_YOU_HOVER"]                  = "Oculta los botones de zoom hasta pasar el ratón sobre el minimapa."

-- =====================================================================
-- OptionsData.lua Vista — Display (Border / Text Positions / Buttons)
-- =====================================================================
L["OPTIONS_VISTA_BORDER"]                                             = "Borde"
L["OPTIONS_VISTA_A_BORDER_AROUND_MINIMAP"]                            = "Muestra un borde alrededor del minimapa."
L["OPTIONS_VISTA_BORDER_COLOR"]                                       = "Color del borde"
L["OPTIONS_VISTA_COLOR_OPACITY_OF_MINIMAP_BORDER"]                    = "Color (y opacidad) del borde del minimapa."
L["OPTIONS_VISTA_BORDER_THICKNESS"]                                   = "Grosor del borde"
L["OPTIONS_VISTA_THICKNESS_OF_MINIMAP_BORDER_PIXELS"]                 = "Grosor del borde del minimapa en píxeles (1–8)."
-- L["OPTIONS_VISTA_CLASS_COLOURS"]                                   = "Class colours"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_TINT_VISTA_BORDER_TEXT_COORDS_FPS"]               = "Tint Vista border and text (coords, time, FPS/MS labels) with your class colour. Numbers use the configured colour."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_TEXT_POSITIONS"]                                     = "Posiciones del texto"
L["OPTIONS_VISTA_DRAG_TEXT_ELEMENTS_REPOSITION_LOCK_PREVEN"]          = "Arrastra elementos de texto para reposicionarlos. Bloquea para evitar movimientos accidentales."
L["OPTIONS_VISTA_LOCK_ZONE_TEXT_POSITION"]                            = "Bloquear posición del texto de zona"
L["OPTIONS_VISTA_ZONE_TEXT_CANNOT_DRAGGED"]                           = "Activado: el texto de zona no se puede arrastrar."
L["OPTIONS_VISTA_LOCK_COORDINATES_POSITION"]                          = "Bloquear posición de coordenadas"
L["OPTIONS_VISTA_COORDINATES_TEXT_CANNOT_DRAGGED"]                    = "Activado: el texto de coordenadas no se puede arrastrar."
L["OPTIONS_VISTA_LOCK_POSITION"]                                      = "Bloquear posición de la hora"
L["OPTIONS_VISTA_TEXT_CANNOT_DRAGGED"]                                = "Activado: el texto de hora no se puede arrastrar."
-- L["OPTIONS_VISTA_PERFORMANCE_TEXT_POSITION"]                       = "Performance text position"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_PLACE_FPS_LATENCY_TEXT_ABOVE_BELOW"]              = "Place the FPS/latency text above or below the minimap."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_LOCK_PERFORMANCE_TEXT_POSITION"]                  = "Lock performance text position"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_FPS_LATENCY_TEXT_CANNOT_DRAGGED"]                 = "When on, the FPS/latency text cannot be dragged."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_LOCK_DIFFICULTY_TEXT_POSITION"]                      = "Bloquear posición del texto de dificultad"
L["OPTIONS_VISTA_DIFFICULTY_TEXT_CANNOT_DRAGGED"]                     = "Activado: el texto de dificultad no se puede arrastrar."
L["OPTIONS_VISTA_BUTTON_POSITIONS"]                                   = "Posiciones de botones"
L["OPTIONS_VISTA_DRAG_BUTTONS_REPOSITION_LOCK_PREVENT_MOVE"]          = "Arrastra botones para reposicionarlos. Bloquea para impedir movimiento."
L["OPTIONS_VISTA_LOCK_ZOOM_BUTTON"]                                   = "Bloquear botón Zoom +"
L["OPTIONS_VISTA_PREVENT_DRAGGING_ZOOM_BUTTON"]                       = "Impide arrastrar el botón de zoom +."
L["OPTIONS_VISTA_LOCK_ZOOM_OUT_BUTTON"]                               = "Bloquear botón Zoom -"
L["OPTIONS_VISTA_LOCK_ZOOM_OUT_DRAG"]                                 = "Impide arrastrar el botón de zoom -."
L["OPTIONS_VISTA_LOCK_TRACKING_BUTTON"]                               = "Bloquear botón de seguimiento"
L["OPTIONS_VISTA_PREVENT_DRAGGING_TRACKING_BUTTON"]                   = "Impide arrastrar el botón de seguimiento."
L["OPTIONS_VISTA_LOCK_CALENDAR_BUTTON"]                               = "Bloquear botón de calendario"
L["OPTIONS_VISTA_PREVENT_DRAGGING_CALENDAR_BUTTON"]                   = "Impide arrastrar el botón de calendario."
L["OPTIONS_VISTA_LOCK_QUEUE_BUTTON"]                                  = "Bloquear botón de cola"
L["OPTIONS_VISTA_PREVENT_DRAGGING_QUEUE_STATUS_BUTTON"]               = "Impide arrastrar el botón de estado de cola."
L["OPTIONS_VISTA_LOCK_MAIL_INDICATOR"]                                = "Bloquear indicador de correo"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MAIL_ICON"]                         = "Impide arrastrar el icono de correo."
-- L["OPTIONS_VISTA_DISABLE_QUEUE_HANDLING"]                          = "Disable queue handling"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_DISABLE_QUEUE_BUTTON_HANDLING"]                      = "Desactivar gestión del botón de cola"
L["OPTIONS_VISTA_TURN_QUEUE_BUTTON_ANCHORING_ANOTHER_A"]              = "Desactiva todo el anclaje del botón de cola (usa si otro addon lo gestiona)."
L["OPTIONS_VISTA_BUTTON_SIZES"]                                       = "Tamaños de botones"
L["OPTIONS_VISTA_ADJUST_SIZE_OF_MINIMAP_OVERLAY_BUTTONS"]             = "Ajusta el tamaño de los botones superpuestos del minimapa."
L["OPTIONS_VISTA_TRACKING_BUTTON_SIZE"]                               = "Tamaño del botón de seguimiento"
L["OPTIONS_VISTA_SIZE_OF_TRACKING_BUTTON_PIXELS"]                     = "Tamaño del botón de seguimiento (píxeles)."
L["OPTIONS_VISTA_CALENDAR_BUTTON_SIZE"]                               = "Tamaño del botón de calendario"
L["OPTIONS_VISTA_SIZE_OF_CALENDAR_BUTTON_PIXELS"]                     = "Tamaño del botón de calendario (píxeles)."
L["OPTIONS_VISTA_QUEUE_BUTTON_SIZE"]                                  = "Tamaño del botón de cola"
L["OPTIONS_VISTA_SIZE_OF_QUEUE_STATUS_BUTTON_PIXELS"]                 = "Tamaño del botón de estado de cola (píxeles)."
L["OPTIONS_VISTA_ZOOM_BUTTON_SIZE"]                                   = "Tamaño de los botones de zoom"
L["OPTIONS_VISTA_SIZE_OF_ZOOM_ZOOM_BUTTONS_PIXELS"]                   = "Tamaño de los botones de zoom + / zoom - (píxeles)."
L["OPTIONS_VISTA_MAIL_INDICATOR_SIZE"]                                = "Tamaño del indicador de correo"
L["OPTIONS_VISTA_SIZE_OF_MAIL_ICON_PIXELS"]                           = "Tamaño del icono de correo nuevo (píxeles)."
L["OPTIONS_VISTA_ADDON_BUTTON_SIZE"]                                  = "Tamaño de botones de addons"
L["OPTIONS_VISTA_SIZE_OF_COLLECTED_ADDON_MINIMAP_BUTTONS"]            = "Tamaño de los botones de addons recopilados en el minimapa (píxeles)."

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
-- L["OPTIONS_VISTA_COLLECT_HORIZON_MINIMAP"]                         = "Include Horizon minimap icon"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_COLLECT_HORIZON_MINIMAP_DESC"]                    = "Put Horizon's own minimap icon in the managed addon bar, right-click panel, or drawer instead of leaving it on the minimap edge."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_ADDON_BUTTONS"]                                   = "Addon Buttons"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_MINIMAP_ADDON_BUTTONS"]                              = "Botones de addons del minimapa"
L["OPTIONS_VISTA_BUTTON_MANAGEMENT"]                                  = "Gestión de botones"
L["OPTIONS_VISTA_MANAGE_ADDON_MINIMAP_BUTTONS"]                       = "Gestionar botones de addons del minimapa"
L["OPTIONS_VISTA_VISTA_TAKES_CONTROL_OF_ADDON_MINIMAP"]               = "Activado: Vista toma el control de los botones de addons y los agrupa según el modo seleccionado."
L["OPTIONS_VISTA_BUTTON_MODE"]                                        = "Modo de botones"
L["OPTIONS_VISTA_ADDON_BUTTONS_PRESENTED_HOVER_BAR_BELOW"]            = "Cómo se presentan los botones: barra al pasar el ratón, panel al clic derecho o botón de cajón flotante."
-- L["OPTIONS_VISTA_ALWAYS_BAR"]                                      = "Always show bar"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_ALWAYS_MOUSEOVER_BAR_POSITIONING"]                = "Always show mouseover bar (for positioning)"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_KEEP_MOUSEOVER_BAR_VISIBLE_TIMES_YOU"]            = "Keep the mouseover bar visible at all times so you can reposition it. Disable when done."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_DISABLE_DONE"]                                    = "Disable when done."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_MOUSEOVER_BAR"]                                      = "Barra al pasar el ratón"
L["OPTIONS_VISTA_RIGHT_CLICK_PANEL"]                                  = "Panel clic derecho"
L["OPTIONS_VISTA_FLOATING_DRAWER"]                                    = "Cajón flotante"
L["OPTIONS_VISTA_LOCK_DRAWER_BUTTON_POSITION"]                        = "Bloquear posición del botón del cajón"
L["OPTIONS_VISTA_PREVENT_DRAGGING_FLOATING_DRAWER_BUTTON"]            = "Impide arrastrar el botón del cajón flotante."
L["OPTIONS_VISTA_LOCK_MOUSEOVER_BAR_POSITION"]                        = "Bloquear posición de la barra al pasar el ratón"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MOUSEOVER_BUTTON_BAR"]              = "Impide arrastrar la barra de botones al pasar el ratón."
L["OPTIONS_VISTA_LOCK_RIGHT_CLICK_PANEL_POSITION"]                    = "Bloquear posición del panel clic derecho"
L["OPTIONS_VISTA_PREVENT_DRAGGING_RIGHT_CLICK_PANEL"]                 = "Impide arrastrar el panel de clic derecho."
L["OPTIONS_VISTA_BUTTONS_PER_ROW_COLUMN"]                             = "Botones por fila/columna"
L["OPTIONS_VISTA_CONTROLS_MANY_BUTTONS_APPEAR_BEFORE_WRAPPING"]       = "Controla cuántos botones aparecen antes de envolver. Izquierda/derecha: columnas; arriba/abajo: filas."
L["OPTIONS_VISTA_EXPAND_DIRECTION"]                                   = "Dirección de expansión"
L["OPTIONS_VISTA_DIRECTION_BUTTONS_FILL_ANCHOR_POINT_LEFT"]           = "Dirección de llenado desde el punto de anclaje. Izquierda/Derecha: filas horizontales. Arriba/Abajo: columnas verticales."
L["OPTIONS_VISTA_RIGHT"]                                              = "Derecha"
L["OPTIONS_VISTA_LEFT"]                                               = "Izquierda"
L["OPTIONS_VISTA_DOWN"]                                               = "Abajo"
L["OPTIONS_VISTA_UP"]                                                 = "Arriba"
-- L["OPTIONS_VISTA_MOUSEOVER_BAR_APPEARANCE"]                        = "Mouseover Bar Appearance"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_BACKGROUND_BORDER_MOUSEOVER_BUTTON_BAR"]          = "Background and border for the mouseover button bar."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_BACKDROP_COLOR"]                                  = "Backdrop color"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_BACKGROUND_COLOR_OF_MOUSEOVER_BUTTON_BAR"]        = "Background color of the mouseover button bar (use alpha to control transparency)."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_BAR_BORDER"]                                      = "Show bar border"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_A_BORDER_AROUND_MOUSEOVER_BUTTON_BAR"]            = "Show a border around the mouseover button bar."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_BAR_BORDER_COLOR"]                                = "Bar border color"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_BORDER_COLOR_OF_MOUSEOVER_BUTTON_BAR"]            = "Border color of the mouseover button bar."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_BAR_BACKGROUND_COLOR"]                            = "Bar background color"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_PANEL_BACKGROUND_COLOR"]                          = "Panel background color."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_CLOSE_FADE_TIMING"]                               = "Close / Fade Timing"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_MOUSEOVER_BAR_CLOSE_DELAY_SECONDS"]               = "Mouseover bar — close delay (seconds)"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_LONG_SECONDS_BAR_STAYS_VISIBLE_AFTER"]            = "How long (in seconds) the bar stays visible after the cursor leaves. 0 = instant fade."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_RIGHT_CLICK_PANEL_CLOSE_DELAY_SECONDS"]           = "Right-click panel — close delay (seconds)"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_LONG_SECONDS_PANEL_STAYS_OPEN_AFTER"]             = "How long (in seconds) the panel stays open after the cursor leaves. 0 = never auto-close (close by right-clicking again)."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_FLOATING_DRAWER_CLOSE_DELAY_SECONDS"]             = "Floating drawer — close delay (seconds)"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_DRAWER_CLOSE_DELAY"]                              = "Drawer close delay"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_LONG_SECONDS_DRAWER_PANEL_STAYS_OPEN"]            = "How long (in seconds) the drawer panel stays open after clicking away. 0 = never auto-close (close only by clicking the drawer button again)."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_MAIL_ICON_BLINK"]                                 = "Mail icon blink"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_MAIL_ICON_PULSES_DRAW_ATTENTION"]                 = "When on, the mail icon pulses to draw attention. When off, it stays at full opacity."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_PANEL_APPEARANCE"]                                   = "Apariencia del panel"
L["OPTIONS_VISTA_COLORS_DRAWER_RIGHT_CLICK_BUTTON_PANELS"]            = "Colores para los paneles del cajón y clic derecho."
L["OPTIONS_VISTA_PANEL_BG_COLOR_LABEL"]                               = "Color de fondo del panel"
L["OPTIONS_VISTA_BACKGROUND_COLOR_OF_ADDON_BUTTON_PANELS"]            = "Color de fondo de los paneles de botones de addons."
L["OPTIONS_VISTA_PANEL_BORDER_COLOR"]                                 = "Color del borde del panel"
L["OPTIONS_VISTA_BORDER_COLOR_OF_ADDON_BUTTON_PANELS"]                = "Color del borde de los paneles de botones de addons."
L["OPTIONS_VISTA_MANAGED_BUTTONS"]                                    = "Botones gestionados"
L["OPTIONS_VISTA_BUTTON_COMPLETELY_IGNORED_A"]                        = "Desactivado: este botón es ignorado por completo por este addon."
L["OPTIONS_VISTA_ADDON_BUTTONS_DETECTED"]                             = "(Aún no se han detectado botones de addons)"
L["OPTIONS_VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE"]                      = "Botones visibles (marca para incluir)"
L["OPTIONS_VISTA_ADDON_BUTTONS_DETECTED_OPEN_YOUR_MINIMAP"]           = "(Aún no se han detectado botones de addons — abre primero tu minimapa)"

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

















































































