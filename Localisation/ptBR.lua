if GetLocale() ~= "ptBR" then return end

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
L["OTHER"]                                                    = "Outro"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["QUEST_TYPES"]                                              = "Tipos de Missões"
L["ELEMENT_OVERRIDES"]                                        = "Cores por Elemento"
L["PER_CATEGORY"]                                             = "Cores por Categoria"
L["GROUPING_OVERRIDES"]                                       = "Cores Prioritárias"
-- L["SECTION_OVERRIDES"]                                     = "Section Overrides"
L["OTHER_COLOURS"]                                            = "Outras Cores"

-- =====================================================================
-- OptionsPanel.lua — Colour row labels (collapsible group sub-rows)
-- =====================================================================
L["FOCUS_SECTION"]                                            = "Seção"
L["FOCUS_TITLE"]                                              = "Título"
L["FOCUS_ZONE"]                                               = "Zona"
L["FOCUS_OBJECTIVE"]                                          = "Objetivo"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["FOCUS_READY_TURN_OVERRIDES_BASE_COLOURS"]                  = "Pronto para Entregar substitui as cores base"
L["FOCUS_READY_TURN_COLOURS_QUESTS"]                          = "As missões prontas para entregar usam suas cores nesta seção."
L["FOCUS_CURRENT_ZONE_OVERRIDES_BASE_COLOURS"]                = "Zona Atual substitui as cores base"
L["FOCUS_CURRENT_ZONE_SECTION_COLOURS"]                       = "As missões da zona atual usam suas cores nesta seção."
L["FOCUS_CURRENT_QUEST_OVERRIDES_BASE_COLOURS"]               = "Missão Atual substitui as cores base"
L["FOCUS_CURRENT_QUEST_SECTION_COLOURS"]                      = "As missões da seção Missão Atual usam suas cores nesta seção."
L["FOCUS_DISTINCT_COLOUR_COMPLETED_OBJECTIVES"]               = "Usar cor distinta para objetivos completos"
L["FOCUS_COMPLETED_OBJECTIVES_COLOURS_CHANGE"]                = "Ativado: objetivos completos (ex. 1/1) usam a cor abaixo. Desativado: eles usam a mesma cor que objetivos incompletos."
L["FOCUS_COMPLETED_OBJECTIVE"]                                = "Objetivo Completo"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["FOCUS_RESET"]                                              = "Redefinir"
L["FOCUS_RESET_QUEST_TYPES"]                                  = "Redefinir tipos de missões"
L["FOCUS_RESET_OVERRIDES"]                                    = "Redefinir cores personalizadas"
L["FOCUS_RESET_DEFAULTS"]                                     = "Redefinir tudo para padrões"
L["FOCUS_RESET_TO_DEFAULTS"]                                  = "Redefinir para padrões"
L["FOCUS_RESET_DEFAULT"]                                      = "Redefinir para padrão"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["FOCUS_SEARCH_SETTINGS"]                                    = "Buscar configurações..."
L["SEARCH_FONTS"]                                             = "Buscar fonte..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["FOCUS_DRAG_RESIZE"]                                        = "Arrastar para redimensionar"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
L["PROFILES"]                                                 = "Perfis"
L["MODULES"]                                                  = "Módulos"
-- L["MODULE_TOGGLES"]                                        = "Module Toggles"
-- L["MODULE_PREVIEW_DISCLAIMER"]                             = "This module is currently in an early preview (alpha) state. Daily use is not advised due to bugs or unfinished functionality."
L["AXIS_MODULE_NAME_DISPLAY"]                                 = "Module name style"
-- L["AXIS_MODULE_NAME_DISPLAY_DESC"]                         = "How module names appear in the settings panel navigation and search filter."
-- L["AXIS_MODULE_NAME_HORIZON"]                              = "Horizon"
-- L["AXIS_MODULE_NAME_SUBTITLE"]                             = "Subtitle"
-- L["AXIS_MODULE_NAME_SIMPLE"]                               = "Simple"
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
L["DASH_WELCOME_LOCALISATIONS_BODY"]                          = [=[The options panel is localised for:

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
-- L["DASH_LAYOUT"]                                           = "Layout"
L["DASH_VISIBILITY"]                                          = "Visibilidade"
L["DASH_DISPLAY"]                                             = "Exibição"
L["DASH_FEATURES"]                                            = "Recursos"
L["DASH_TYPOGRAPHY"]                                          = "Tipografia"
L["DASH_APPEARANCE"]                                          = "Aparência"
-- L["DASH_CLICK_OPTIONS"]                                    = "Click Options"
L["DASH_COLOURS"]                                             = "Cores"
L["DASH_ORGANISATION"]                                        = "Organização"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["FOCUS_PANEL_BEHAVIOUR"]                                    = "Comportamento do Painel"
L["FOCUS_DIMENSIONS"]                                         = "Dimensões"
L["FOCUS_INSTANCE"]                                           = "Instância"
-- L["FOCUS_INSTANCES"]                                       = "Instances"
L["FOCUS_COMBAT"]                                             = "Combate"
L["FOCUS_FILTERING"]                                          = "Filtragem"
L["FOCUS_HEADER"]                                             = "Cabeçalho"
L["FOCUS_SECTIONS_STRUCTURE"]                                 = "Sections & structure"
L["FOCUS_ENTRY_DETAILS"]                                      = "Entry details"
L["FOCUS_PROGRESS_TIMERS"]                                    = "Progress & timers"
L["FOCUS_EMPHASIS"]                                           = "Focus emphasis"
L["FOCUS_LIST"]                                               = "Lista"
L["FOCUS_SPACING"]                                            = "Espaçamento"
L["FOCUS_RARE_BOSSES"]                                        = "Chefes Raros"
L["FOCUS_WORLD_QUESTS"]                                       = "Missões Mundiais"
L["FOCUS_FLOATING_QUEST_ITEM"]                                = "Item de Missão Flutuante"
L["FOCUS_MYTHIC"]                                             = "Mítica+"
L["FOCUS_ACHIEVEMENTS"]                                       = "Conquistas"
L["FOCUS_ACHIEVEMENT_PROGRESS_BARS"]                          = "Achievement progress bars"
-- L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_DESC"]                  = "Show a progress bar under tracked achievements that report numeric criteria (including 0/1 and X/Y). Independent of Quest Progress Bars."
-- L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_TIP"]                   = "Uses the same bar colours, texture, and font as other Focus progress bars when those options are visible."
L["FOCUS_ENDEAVORS"]                                          = "Empreendimentos"
L["FOCUS_DECOR"]                                              = "Decoração"
-- L["FOCUS_APPEARANCES"]                                     = "Appearances"
L["FOCUS_SCENARIO_DELVE"]                                     = "Cenário e Delve"
L["FOCUS_FONT"]                                               = "Fonte"
L["FOCUS_FONT_FAMILIES"]                                      = "Font families"
L["FOCUS_GLOBAL_FONT_SIZE"]                                   = "Global font size"
L["FOCUS_FONT_SIZES"]                                         = "Font sizes"
L["FOCUS_PER_ELEMENT_FONTS"]                                  = "Per-element fonts"
L["FOCUS_TEXT_CASE"]                                          = "Caixa de Texto"
L["FOCUS_SHADOW"]                                             = "Sombra"
L["FOCUS_PANEL"]                                              = "Painel"
L["FOCUS_HIGHLIGHT"]                                          = "Destaque"
L["FOCUS_COLOUR_MATRIX"]                                      = "Matriz de Cores"
L["FOCUS_ORDER"]                                              = "Ordem"
L["FOCUS_SORT"]                                               = "Classificação"
L["FOCUS_BEHAVIOUR"]                                          = "Comportamento"
L["FOCUS_CONTENT_TYPES"]                                      = "Tipos de Conteúdo"
-- L["FOCUS_DELVES"]                                          = "Delves"
L["FOCUS_DELVES_DUNGEONS"]                                    = "Delves e Masmorras"
L["FOCUS_DELVE_COMPLETE"]                                     = "Delve concluído"
L["FOCUS_INTERACTIONS"]                                       = "Interações"
-- L["FOCUS_APPEARANCE_TAB_DESC"]                             = "Tracker panel look, fading, and list layout (header, sections, entries, timers, emphasis)."
-- L["FOCUS_CLICK_OPTIONS_TAB_DESC"]                          = "Click profile, per-combo actions, and optional safety toggles for the tracker."
-- L["FOCUS_INTERACTIONS_TAB_DESC"]                           = "Configure quest tracking rules and TomTom integration."
L["FOCUS_TRACKING"]                                           = "Rastreamento"
L["FOCUS_SCENARIO_BAR"]                                       = "Barra de Cenário"

-- =====================================================================
-- OptionsData.lua Profiles
-- =====================================================================
L["AXIS_CURRENT_PROFILE"]                                     = "Perfil atual"
L["AXIS_SELECT_PROFILE_CURRENTLY"]                            = "Selecione o perfil em uso no momento."
L["AXIS_GLOBAL_PROFILE_ACCOUNT_WIDE"]                         = "Usar perfil global (conta inteira)"
L["AXIS_CHARACTERS_SAME_PROFILE"]                             = "Todos os personagens usam o mesmo perfil."
L["AXIS_ENABLE_PER_SPECIALIZATION_PROFILES"]                  = "Ativar perfis por especialização"
L["AXIS_PICK_DIFFERENT_PROFILES_PER_SPEC"]                    = "Escolha perfis diferentes por especialização."
L["AXIS_SPECIALIZATION"]                                      = "Especialização"
-- L["AXIS_SPEC_PROFILES"]                                    = "Spec Profiles"
-- L["AXIS_ENABLE"]                                           = "Enable"
L["AXIS_SHARING"]                                             = "Compartilhamento"
L["AXIS_IMPORT_PROFILE"]                                      = "Importar perfil"
L["AXIS_IMPORT_STRING"]                                       = "String de importação"
L["AXIS_EXPORT_PROFILE"]                                      = "Exportar perfil"
L["AXIS_SELECT_A_PROFILE_EXPORT"]                             = "Selecione um perfil para exportar."
L["AXIS_EXPORT_STRING"]                                       = "String de exportação"
L["AXIS_COPY_PROFILE"]                                        = "Copiar de perfil"
L["AXIS_SOURCE_PROFILE_COPYING"]                              = "Perfil de origem para cópia."
L["AXIS_COPY_SELECTED"]                                       = "Copiar do selecionado"
L["AXIS_CREATE"]                                              = "Criar"
L["AXIS_CREATE_PROFILE_DEFAULT_TEMPLATE"]                     = "Criar novo perfil a partir do modelo Padrão"
L["AXIS_CREATES_A_PROFILE_DEFAULT_SETTINGS"]                  = "Cria um novo perfil com todas as configurações padrão."
L["AXIS_CREATES_A_PROFILE_COPIED_SELECTED_SOURC"]             = "Cria um novo perfil copiado do perfil de origem selecionado."
L["AXIS_DELETE_PROFILE"]                                      = "Excluir perfil"
L["AXIS_SELECT_A_PROFILE_DELETE_CURRENT_DEFAULT"]             = "Selecione um perfil para excluir (atual e Padrão não aparecem)."
L["AXIS_DELETE_SELECTED"]                                     = "Excluir selecionado"
L["AXIS_DELETE_SELECTED_PROFILE"]                             = "Delete selected profile"
L["AXIS_DELETE"]                                              = "Excluir"
L["AXIS_DELETES_SELECTED_PROFILE"]                            = "Exclui o perfil selecionado."
L["AXIS_GLOBAL_PROFILE"]                                      = "Global profile"
L["AXIS_PER_SPEC_PROFILES"]                                   = "Per-spec profiles"

-- =====================================================================
-- OptionsData.lua Modules
-- =====================================================================
L["AXIS_ENABLE_FOCUS_MODULE"]                                 = "Ativar Módulo de Foco"
L["AXIS_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS_R"]             = "Mostra o rastreador de objetivos para missões, missões mundiais, chefes raros, conquistas e cenários."
L["AXIS_ENABLE_PRESENCE_MODULE"]                              = "Ativar Módulo de Presença"
L["AXIS_CINEMATIC_ZONE_TEXT_NOTIFICATIONS_ZONE_CHANGES"]      = "Texto de zona cinematográfico e notificações (mudanças de zona, up de nível, emotes de chefes, conquistas, atualizações de missões)."
L["AXIS_ENABLE_CACHE_MODULE"]                                 = "Ativar Módulo de Rendimento"
L["AXIS_CINEMATIC_LOOT_NOTIFICATIONS_ITEMS_MONEY_CURRENCY"]   = "Notificações cinematográficas de saque (itens, dinheiro, moedas, reputação)."
L["AXIS_ENABLE_VISTA_MODULE"]                                 = "Ativar Módulo Vista"
L["AXIS_CINEMATIC_SQUARE_MINIMAP_ZONE_TEXT_COORDINATES"]      = "Minimapa quadrado cinematográfico com texto de zona, coordenadas e coletor de botões."
L["AXIS_MINIMAP_ZONE_TIME_COLLECTOR"]                         = "Minimapa quadrado cinematográfico com texto de zona, coordenadas, horário e coletor de botões."
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
L["AXIS_GLOBAL_UI_SCALE"]                                     = "Escala global da interface"
L["AXIS_SCALE_SIZES_SPACINGS_FONTS_FACTOR"]                   = "Escala todos os tamanhos, espaçamentos e fontes por este fator (50–200%). Não altera seus valores configurados."
L["AXIS_PER_MODULE_SCALING"]                                  = "Escala por módulo"
L["AXIS_OVERRIDE_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_FO"]         = "Substitui a escala global por controles individuais para cada módulo."
-- L["AXIS_OVERRIDES_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_F"]      = "Overrides the global scale with individual sliders for Focus, Presence, Vista, etc."
-- L["AXIS_DOESN_T_CHANGE_YOUR_CONFIGURED_VALUES"]            = "Doesn't change your configured values, only the effective display scale."
L["FOCUS_SCALE"]                                              = "Escala do Focus"
L["AXIS_SCALE_FOCUS_OBJECTIVE_TRACKER"]                       = "Escala do rastreador de objetivos Focus (50–200%)."
L["PRESENCE_SCALE"]                                           = "Escala do Presence"
L["AXIS_SCALE_PRESENCE_CINEMATIC_TEXT"]                       = "Escala do texto cinemático Presence (50–200%)."
L["VISTA_SCALE"]                                              = "Escala do Vista"
L["AXIS_SCALE_VISTA_MINIMAP_MODULE"]                          = "Escala do módulo de minimapa Vista (50–200%)."
L["INSIGHT_SCALE"]                                            = "Escala do Insight"
L["AXIS_SCALE_INSIGHT_TOOLTIP_MODULE"]                        = "Escala do módulo de tooltip Insight (50–200%)."
L["CACHE_SCALE"]                                              = "Escala do Cache"
L["AXIS_SCALE_CACHE_LOOT_TOAST_MODULE"]                       = "Escala do módulo de notificação de saque Cache (50–200%)."
L["AXIS_ENABLE_HORIZON_INSIGHT_MODULE"]                       = "Ativar Módulo Horizon Insight"
L["AXIS_CINEMATIC_TOOLTIPS_CLASS_COLOURS_SPEC_DISPLAY"]       = "Tooltips cinematográficos com cores de classe, exibição de especialização e ícones de facção."
L["AXIS_TOOLTIP_ANCHOR_MODE"]                                 = "Modo de âncora do tooltip"
L["AXIS_WHERE_TOOLTIPS_APPEAR_FOLLOW_CURSOR_FIXED"]           = "Onde os tooltips aparecem: seguir o cursor ou posição fixa."
-- L["AXIS_CURSOR"]                                           = "Cursor"
L["AXIS_FIXED"]                                               = "Fixo"
L["INSIGHT_CURSOR_SIDE"]                                      = "Cursor side"
-- L["INSIGHT_CURSOR_SIDE_DESC"]                              = "Which side of the cursor the tooltip appears on."
-- L["INSIGHT_CURSOR_SIDE_CENTER"]                            = "Center"
-- L["INSIGHT_CURSOR_SIDE_LEFT"]                              = "Left"
-- L["INSIGHT_CURSOR_SIDE_RIGHT"]                             = "Right"
L["AXIS_ANCHOR_MOVE"]                                         = "Mostrar âncora para mover"
-- L["AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITION"]                  = "Click to show or hide the anchor. Drag to set position, right-click to confirm."
L["AXIS_DRAGGABLE_FRAME_FIXED_TOOLTIP_POSITION_DESC"]         = "Mostra quadro arrastável para definir posição fixa do tooltip. Arraste e clique com o botão direito para confirmar."
L["AXIS_RESET_TOOLTIP_POSITION"]                              = "Redefinir posição do tooltip"
L["AXIS_RESET_FIXED_POSITION_DEFAULT"]                        = "Redefinir posição fixa para o padrão."
L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED"]                           = "Dynamic position for Focus tooltips"
-- L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED_DESC"]                   = "When fixed anchor is on, Focus tracker tooltips still attach to the outer edge of the Horizon panel so they never cover the tracker."
L["INSIGHT_CURSOR_OFFSET_X"]                                  = "Cursor offset X"
L["INSIGHT_CURSOR_OFFSET_X_DESC"]                             = "Horizontal pixel offset from the default cursor tooltip position (cursor anchor only)."
L["INSIGHT_CURSOR_OFFSET_Y"]                                  = "Cursor offset Y"
L["INSIGHT_CURSOR_OFFSET_Y_DESC"]                             = "Vertical pixel offset from the default cursor tooltip position (cursor anchor only)."
L["AXIS_TOOLTIP_BACKGROUND_COLOUR"]                           = "Cor de fundo do tooltip"
L["AXIS_COLOUR_OF_TOOLTIP_BACKGROUND"]                        = "Cor de fundo do tooltip."
L["AXIS_TOOLTIP_BACKGROUND_OPACITY"]                          = "Opacidade do fundo do tooltip"
L["AXIS_TOOLTIP_BG_OPACITY_PCT_DESC"]                         = "Opacidade do fundo do tooltip (0–100%)."
L["AXIS_TOOLTIP_FONT"]                                        = "Fonte do tooltip"
L["AXIS_FONT_FAMILY_TOOLTIP_TEXT"]                            = "Família de fontes usada para todo o texto do tooltip."
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
L["AXIS_ITEM_TOOLTIP"]                                        = "Tooltip de item"
L["AXIS_TRANSMOG_STATUS"]                                     = "Mostrar status de transmog"
L["AXIS_WHETHER_YOU_COLLECTED_APPEARANCE_OF_AN"]              = "Mostra se você já coletou a aparência do item sobre o qual está com o mouse."
L["AXIS_PLAYER_TOOLTIP"]                                      = "Tooltip de jogador"
L["AXIS_GUILD_RANK"]                                          = "Mostrar cargo da guilda"
L["AXIS_APPEND_PLAYER_S_GUILD_RANK_NEXT"]                     = "Adiciona o cargo da guilda do jogador ao lado do nome da guilda."
L["AXIS_MYTHIC_SCORE"]                                        = "Mostrar pontuação de Mítica+"
L["AXIS_PLAYER_S_CURRENT_SEASON_MYTHIC_SCORE"]                = "Mostra a pontuação de Mítica+ da temporada atual do jogador, com cor por faixa."
L["AXIS_ITEM_LEVEL"]                                          = "Mostrar nível de item"
L["AXIS_PLAYER_S_EQUIPPED_ITEM_LEVEL_AFTER"]                  = "Mostra o nível de item equipado do jogador após inspecioná-lo."
L["AXIS_HONOR_LEVEL"]                                         = "Mostrar nível de honra"
L["AXIS_PLAYER_S_PVP_HONOR_LEVEL_TOOLTIP"]                    = "Mostra o nível de honra JxJ do jogador no tooltip."
L["AXIS_PVP_TITLE"]                                           = "Mostrar título JxJ"
L["AXIS_PLAYER_S_PVP_TITLE_E_G"]                              = "Mostra o título JxJ do jogador (ex.: Gladiador) no tooltip."
L["AXIS_CHARACTER_TITLE"]                                     = "Character title"
-- L["AXIS_PLAYER_S_SELECTED_TITLE_ACHIEVEMENT_PVP"]          = "Show the player's selected title (achievement or PvP) in the name line."
L["AXIS_TITLE_COLOUR"]                                        = "Title colour"
-- L["AXIS_COLOUR_OF_CHARACTER_TITLE_PLAYER_TOOLTIP"]         = "Colour of the character title in the player tooltip name line."
L["AXIS_STATUS_BADGES"]                                       = "Mostrar badges de status"
L["AXIS_INLINE_BADGES_COMBAT_AFK_DND_PVP"]                    = "Mostra badges em linha para combate, AUS, NOP, marcação JxJ, grupo/raide, amigos e se o jogador está mirando em você."
L["AXIS_MOUNT_INFO"]                                          = "Mostrar informações da montaria"
L["AXIS_HOVERING_A_MOUNTED_PLAYER_THEIR_MOUNT"]               = "Ao passar o mouse sobre um jogador montado, mostra nome da montaria, origem e se você a possui."
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
L["AXIS_GENERAL"]                                             = "Geral"
L["AXIS_POSITION"]                                            = "Posição"
L["AXIS_RESET_POSITION"]                                      = "Redefinir Posição"
L["AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"]                   = "Redefinir posição das notificações de saque."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["FOCUS_LOCK_POSITION"]                                      = "Travar Posição"
L["FOCUS_PREVENT_DRAGGING_TRACKER"]                           = "Impede de arrastar o rastreador."
L["FOCUS_GROW_UPWARD"]                                        = "Crescer para Cima"
L["FOCUS_GROW_HEADER"]                                        = "Cabeçalho ao crescer"
L["FOCUS_GROWING_UPWARD_KEEP_HEADER_BOTTOM_TOP"]              = "Ao crescer para cima: manter cabeçalho embaixo ou em cima até colapsar."
L["FOCUS_HEADER_BOTTOM"]                                      = "Cabeçalho embaixo"
L["FOCUS_HEADER_SLIDES_COLLAPSE"]                             = "Cabeçalho desliza ao colapsar"
L["FOCUS_ANCHOR_BOTTOM_LIST_GROWS_UPWARD"]                    = "Âncora na parte inferior para que a lista cresça para cima."
L["FOCUS_START_COLLAPSED"]                                    = "Começar Colapsado"
L["FOCUS_START_HEADER_SHOWN_UNTIL_YOU_EXPAND"]                = "Mostrar apenas o cabeçalho até expandir."
L["FOCUS_ALIGN_CONTENT_RIGHT"]                                = "Align content right"
-- L["FOCUS_RIGHT_ALIGN_QUEST_TITLES_OBJECTIVES_WITHIN"]      = "Right-align quest titles and objectives within the panel."
L["FOCUS_PANEL_WIDTH"]                                        = "Largura do Painel"
L["FOCUS_TRACKER_WIDTH_PIXELS"]                               = "Largura do rastreador em pixels."
L["FOCUS_MAX_CONTENT_HEIGHT"]                                 = "Altura Máx. do Conteúdo"
L["FOCUS_MAX_HEIGHT_OF_SCROLLABLE_LIST_PIXELS"]               = "Altura máxima da lista rolável (pixels)."

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["FOCUS_ALWAYS_M_BLOCK"]                                     = "Sempre mostrar bloco M+"
L["FOCUS_M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]                = "Mostrar o bloco M+ sempre que uma Pedra-Chave ativa estiver em andamento."
L["FOCUS_DUNGEON"]                                            = "Mostrar em masmorra"
L["FOCUS_TRACKER_PARTY_DUNGEONS"]                             = "Mostra o rastreador em masmorras de grupo."
L["FOCUS_RAID"]                                               = "Mostrar em raide"
L["FOCUS_TRACKER_RAIDS"]                                      = "Mostra o rastreador em raides."
L["FOCUS_BATTLEGROUND"]                                       = "Mostrar em campo de batalha"
L["FOCUS_TRACKER_BATTLEGROUNDS"]                              = "Mostra o rastreador em campos de batalha."
L["FOCUS_ARENA"]                                              = "Mostrar em arena"
L["FOCUS_TRACKER_ARENAS"]                                     = "Mostra o rastreador em arenas."
L["FOCUS_HIDE_COMBAT"]                                        = "Ocultar em combate"
L["FOCUS_HIDE_TRACKER_FLOATING_QUEST_ITEM_COMBAT"]            = "Oculta o rastreador e o item de missão flutuante em combate."
L["FOCUS_COMBAT_VISIBILITY"]                                  = "Visibilidade em combate"
L["FOCUS_TRACKER_BEHAVES_COMBAT_FADE_REDUC"]                  = "Comportamento do rastreador em combate: mostrar, esmaecer ou ocultar."
L["FOCUS_SHOW"]                                               = "Mostrar"
L["FOCUS_FADE"]                                               = "Esmaecer"
L["FOCUS_HIDE"]                                               = "Ocultar"
L["FOCUS_COMBAT_FADE_OPACITY"]                                = "Opacidade em combate (esmaecer)"
L["FOCUS_VISIBLE_TRACKER_FADED_COMBAT"]                       = "Quão visível o rastreador fica quando esmaecido em combate (0 = invisível). Aplica-se apenas quando a visibilidade em combate é Esmaecer."
L["FOCUS_MOUSEOVER"]                                          = "Passar o mouse"
L["FOCUS_SHOW_ONLY_MOUSEOVER"]                                = "Mostrar somente ao passar o mouse"
L["FOCUS_FADE_TRACKER_HOVERING_MOVE_MOUSE"]                   = "Esmaece o rastreador quando o mouse não está sobre ele; passe o mouse para mostrar."
L["FOCUS_FADED_OPACITY"]                                      = "Opacidade esmaecida"
L["FOCUS_VISIBLE_TRACKER_FADED_INVISIBLE"]                    = "Quão visível o rastreador fica quando esmaecido (0 = invisível)."
L["FOCUS_QUESTS_CURRENT_ZONE"]                                = "Mostrar apenas missões na zona atual"
L["FOCUS_HIDE_QUESTS_OUTSIDE_YOUR_CURRENT_ZONE"]              = "Oculta missões fora da sua zona atual."

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["FOCUS_QUEST_COUNT"]                                        = "Mostrar contagem de missões"
L["FOCUS_QUEST_COUNT_HEADER"]                                 = "Mostra a quantidade de missões no cabeçalho."
L["FOCUS_HEADER_COUNT_FORMAT"]                                = "Formato da contagem do cabeçalho"
L["FOCUS_TRACKED_LOG_LOG_MAX_SLOTS_TRACKED"]                  = "Rastreadas/no diário ou no diário/vagas máximas. Rastreadas excluem missões mundiais/em zona."
L["FOCUS_HEADER_DIVIDER"]                                     = "Mostrar divisor do cabeçalho"
L["FOCUS_LINE_BELOW_HEADER"]                                  = "Mostra a linha abaixo do cabeçalho."
L["FOCUS_HEADER_DIVIDER_COLOUR"]                              = "Cor do divisor do cabeçalho"
L["FOCUS_COLOUR_OF_LINE_BELOW_HEADER"]                        = "Cor da linha abaixo do cabeçalho."
L["FOCUS_SUPER_MINIMAL_MODE"]                                 = "Modo super minimalista"
L["FOCUS_HIDE_HEADER_A_PURE_TEXT_LIST"]                       = "Oculta o cabeçalho para ter apenas uma lista de texto."
L["FOCUS_OPTIONS_BUTTON"]                                     = "Options button"
L["FOCUS_OPTIONS_BUTTON_TRACKER_HEADER"]                      = "Mostra o botão de Opções no cabeçalho do rastreador."
L["FOCUS_HEADER_COLOUR"]                                      = "Cor do cabeçalho"
L["FOCUS_COLOUR_OF_OBJECTIVES_HEADER_TEXT"]                   = "Cor do texto do cabeçalho OBJECTIVES."
L["FOCUS_HEADER_HEIGHT"]                                      = "Altura do cabeçalho"
L["FOCUS_HEIGHT_OF_HEADER_BAR_PIXELS"]                        = "Altura da barra de cabeçalho em pixels (18–48)."

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["FOCUS_SECTION_HEADERS"]                                    = "Mostrar cabeçalhos de seção"
L["FOCUS_CATEGORY_LABELS_ABOVE_GROUP"]                        = "Mostra rótulos de categoria acima de cada grupo."
L["FOCUS_CATEGORY_HEADERS_COLLAPSED"]                         = "Mostrar cabeçalhos ao recolher"
L["FOCUS_KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED_CLICK"]       = "Mantém os cabeçalhos visíveis quando recolhidos; clique para expandir uma categoria."
L["FOCUS_NEARBY_CURRENT_ZONE_GROUP"]                          = "Mostrar grupo Próximo (Zona Atual)"
L["FOCUS_ZONE_QUESTS_A_DEDICATED_CURRENT_ZONE"]               = "Mostra missões da zona em uma seção Zona Atual dedicada. Desativado: elas aparecem na categoria normal."
L["FOCUS_ZONE_LABELS"]                                        = "Mostrar nomes de zona"
L["FOCUS_ZONE_NAME_UNDER_QUEST_TITLE"]                        = "Mostra o nome da zona abaixo de cada título de missão."
L["FOCUS_ACTIVE_QUEST_HIGHLIGHT"]                             = "Destaque da missão ativa"
L["FOCUS_FOCUSED_QUEST_HIGHLIGHTED"]                          = "Como a missão focada é destacada."
L["FOCUS_QUEST_ITEM_BUTTONS"]                                 = "Mostrar botões de item de missão"
L["FOCUS_USABLE_QUEST_ITEM_BUTTON_NEXT_QUEST"]                = "Mostra o botão de item utilizável ao lado de cada missão."
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
L["FOCUS_OBJECTIVE_PREFIX"]                                   = "Prefixo dos objetivos"
L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS"]                  = "Colour objective progress numbers"
L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS_DESC"]             = "Tint X/Y counts: normal colour at 0/n, gold while in progress, green when complete. The slash uses the usual objective colour."
L["FOCUS_PREFIX_OBJECTIVE_A_NUMBER_HYPHEN"]                   = "Prefixa cada objetivo com número ou hífen."
L["FOCUS_NUMBERS"]                                            = "Números (1. 2. 3.)"
L["FOCUS_HYPHENS"]                                            = "Hífens (-)"
L["FOCUS_AFTER_SECTION_HEADER"]                               = "After section header"
L["FOCUS_BEFORE_SECTION_HEADER"]                              = "Before section header"
L["FOCUS_BELOW_HEADER"]                                       = "Below header"
L["FOCUS_INLINE_BELOW_TITLE"]                                 = "Inline below title"
L["FOCUS_PREFIX_OBJECTIVES"]                                  = "Prefixa objetivos com 1., 2., 3."
L["FOCUS_COMPLETED_COUNT"]                                    = "Mostrar contagem de concluídos"
L["FOCUS_X_Y_PROGRESS_QUEST_TITLE"]                           = "Mostra o progresso X/Y no título da missão."
L["FOCUS_OBJECTIVE_PROGRESS_BAR"]                             = "Mostrar barra de progresso do objetivo"
L["FOCUS_A_PROGRESS_BAR_UNDER_OBJECTIVES_NUMER"]              = "Mostra uma barra de progresso sob objetivos com progresso numérico (ex. 3/250). Aplica-se apenas a entradas com um único objetivo aritmético onde a quantidade necessária é maior que 1."
L["FOCUS_CATEGORY_COLOUR_PROGRESS_BAR"]                       = "Usar cor da categoria na barra de progresso"
L["FOCUS_PROGRESS_BAR_MATCHES_QUEST_ACHIEVEME"]               = "Quando ativado: a barra de progresso usa a cor da categoria (missão, conquista). Quando desativado: usa a cor personalizada abaixo."
L["FOCUS_PROGRESS_BAR_TEXTURE"]                               = "Textura da barra de progresso"
L["FOCUS_PROGRESS_BAR_TYPES"]                                 = "Tipos de barra de progresso"
L["FOCUS_TEXTURE_PROGRESS_BAR_FILL"]                          = "Textura do preenchimento da barra."
L["FOCUS_TEXTURE_PROGRESS_BAR_FILL_SOLID_YOUR"]               = "Textura do preenchimento. Sólido usa suas cores. Addons SharedMedia adicionam mais opções."
L["FOCUS_PROGRESS_BAR_X_Y_OBJECTIVES_PERCENT"]                = "Mostrar barra para objetivos X/Y, apenas percentual ou ambos."
L["FOCUS_X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]             = "X/Y: objetivos como 3/10. Percentual: objetivos como 45%."
L["FOCUS_X_Y"]                                                = "Apenas X/Y"
L["FOCUS_PERCENT"]                                            = "Apenas percentual"
L["FOCUS_TICK_COMPLETED_OBJECTIVES"]                          = "Usar marca para objetivos concluídos"
L["FOCUS_COMPLETED_OBJECTIVES_A_CHECKMARK_INSTEA"]            = "Ativado: objetivos concluídos mostram uma marca (✓) em vez de cor verde."
L["FOCUS_ENTRY_NUMBERS"]                                      = "Mostrar números de entrada"
L["FOCUS_PREFIX_QUEST_TITLES_WITHIN_CATEGORY"]                = "Prefixa títulos de missão com 1., 2., 3. em cada categoria."
L["FOCUS_COMPLETED_OBJECTIVES"]                               = "Objetivos concluídos"
L["FOCUS_MULTI_OBJECTIVE_QUESTS_DISPLAY_OBJECTIVES"]          = "Para missões com vários objetivos, como exibir objetivos concluídos (ex. 1/1)."
L["FOCUS_ALL"]                                                = "Mostrar tudo"
L["FOCUS_FADE_COMPLETED"]                                     = "Esmaecer concluídos"
L["FOCUS_HIDE_COMPLETED"]                                     = "Ocultar concluídos"
L["FOCUS_ICON_ZONE_AUTO_TRACKING"]                            = "Mostrar ícone de rastreamento automático na zona"
L["FOCUS_DISPLAY_AN_ICON_NEXT_AUTO_TRACKED"]                  = "Exibe um ícone ao lado de missões mundiais e semanais/diárias rastreadas automaticamente que ainda não estão no seu registro de missões (apenas na zona)."
L["FOCUS_AUTO_TRACK_ICON"]                                    = "Ícone de rastreamento automático"
L["FOCUS_CHOOSE_WHICH_ICON_DISPLAY_NEXT_AUTO"]                = "Escolha qual ícone exibir ao lado das entradas rastreadas automaticamente na zona."
L["FOCUS_APPEND_WORLD_QUESTS_WEEKLIES_DAILIES"]               = "Adiciona ** a missões mundiais e semanais/diárias que ainda não estão no seu diário (apenas na zona)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["FOCUS_COMPACT_MODE"]                                       = "Modo compacto"
L["FOCUS_PRESET_SETS_ENTRY_OBJECTIVE_SPACING_P"]              = "Predefinição: define espaçamento de entradas e objetivos para 4 e 1 px."
L["FOCUS_SPACING_PRESET"]                                     = "Predefinição de espaçamento"
L["FOCUS_PRESET_ENTRY_OBJECTIVE_SPACING_DEFAULT_P"]           = "Predefinição: Padrão (8/2 px), Compacto (4/1 px), Espaçado (12/3 px) ou Personalizado (usar sliders)."
L["FOCUS_COMPACT_VERSION"]                                    = "Versão compacta"
L["FOCUS_SPACED_VERSION"]                                     = "Versão espaçada"
L["FOCUS_SPACING_BETWEEN_QUEST_ENTRIES_PX"]                   = "Espaçamento entre entradas de missão (px)"
L["FOCUS_VERTICAL_GAP_BETWEEN_QUEST_ENTRIES"]                 = "Espaço vertical entre entradas de missão."
L["FOCUS_SPACING_BEFORE_CATEGORY_HEADER_PX"]                  = "Espaçamento antes do cabeçalho da categoria (px)"
L["FOCUS_GAP_BETWEEN_LAST_ENTRY_OF_A"]                        = "Espaço entre a última entrada de um grupo e o próximo rótulo de categoria."
L["FOCUS_SPACING_AFTER_CATEGORY_HEADER_PX"]                   = "Espaçamento após o cabeçalho da categoria (px)"
L["FOCUS_GAP_BETWEEN_CATEGORY_LABEL_FIRST_QUEST"]             = "Espaço entre o rótulo da categoria e a primeira missão abaixo dele."
L["FOCUS_SPACING_BETWEEN_OBJECTIVES_PX"]                      = "Espaçamento entre objetivos (px)"
L["FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVE_LINES_WITHIN"]        = "Espaço vertical entre linhas de objetivos dentro de uma missão."
L["FOCUS_TITLE_CONTENT"]                                      = "Título para conteúdo"
L["FOCUS_VERTICAL_GAP_BETWEEN_QUEST_TITLE_OBJECTIVES"]        = "Espaço vertical entre o título da missão e os objetivos ou zona abaixo."
L["FOCUS_SPACING_BELOW_HEADER_PX"]                            = "Espaçamento abaixo do cabeçalho (px)"
L["FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVES_BAR_QUES"]           = "Espaço vertical entre a barra de objetivos e a lista de missões."
L["FOCUS_RESET_SPACING"]                                      = "Redefinir espaçamento"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["FOCUS_SHOW_QUEST_LEVEL"]                                   = "Mostrar nível da missão"
L["FOCUS_QUEST_LEVEL_NEXT_TITLE"]                             = "Mostra o nível da missão ao lado do título."
L["FOCUS_DIM_FOCUSED_QUESTS"]                                 = "Escurecer missões não focadas"
L["FOCUS_SLIGHTLY_DIM_TITLE_ZONE_OBJECTIVES_SECTION"]         = "Escurece levemente títulos, zonas, objetivos e cabeçalhos de seção que não estão em foco."
L["FOCUS_DIM_UNFOCUSED_ENTRIES"]                              = "Dim unfocused entries"
-- L["FOCUS_CLICK_A_SECTION_HEADER_EXPAND_CATEGORY"]          = "Click a section header to expand that category."

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["UI_SHOW_RARE_BOSSES"]                                      = "Mostrar chefes raros"
L["UI_RARE_BOSS_VIGNETTES_LIST"]                              = "Mostra chefes raros na lista."
L["UI_RARE_LOOT"]                                             = "Saque raro"
L["UI_TREASURE_ITEM_VIGNETTES_RARE_LOOT"]                     = "Mostra tesouros e itens na lista de saque raro."
L["UI_RARE_SOUND_VOLUME"]                                     = "Volume do som de saque raro"
L["UI_VOLUME_OF_RARE_ALERT_SOUND"]                            = "Volume do som de alerta de saque raro (50–200%)."
L["UI_BOOST_REDUCE_RARE_ALERT_VOLUME"]                        = "Aumente ou reduza o volume. 100% = normal; 150% = mais alto."
L["UI_RARE_ADDED_SOUND"]                                      = "Som ao adicionar raro"
L["UI_PLAY_A_SOUND_A_RARE"]                                   = "Reproduz um som quando um raro é adicionado."
-- L["UI_MINIMAP_PATCH_NOTES_UNREAD_HINT"]                    = "New patch notes — open Axis and choose Patch Notes."

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["FOCUS_ZONE_WORLD_QUESTS"]                                  = "Mostrar missões mundiais da zona"
L["FOCUS_AUTO_ADD_WORLD_QUESTS_YOUR_CURRENT"]                 = "Adiciona automaticamente missões mundiais na sua zona atual. Desativado: apenas missões rastreadas ou missões mundiais próximas aparecem (padrão Blizzard)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["FOCUS_SHOW_FLOATING_QUEST_ITEM"]                           = "Mostrar item de missão flutuante"
L["FOCUS_QUICK_BUTTON_FOCUSED_QUEST_S_USABLE"]                = "Mostra botão de uso rápido para o item utilizável da missão focada."
L["FOCUS_LOCK_FLOATING_QUEST_ITEM_POSITION"]                  = "Travar posição do item flutuante"
L["FOCUS_PREVENT_DRAGGING_FLOATING_QUEST_ITEM_BUTTON"]        = "Impede arrastar o botão do item de missão flutuante."
L["FOCUS_FLOATING_QUEST_ITEM_SOURCE"]                         = "Fonte do item de missão flutuante"
L["FOCUS_WHICH_QUEST_S_ITEM_SUPER_TRACKED"]                   = "Qual item de missão mostrar: primeiro o super-rastreado ou primeiro o da zona atual."
L["FOCUS_SUPER_TRACKED_FIRST"]                                = "Super-rastreado, depois primeiro"
L["FOCUS_CURRENT_ZONE_FIRST"]                                 = "Zona atual primeiro"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["FOCUS_MYTHIC_BLOCK"]                                       = "Mostrar bloco Mítica+"
L["FOCUS_TIMER_COMPLETION_AFFIXES_MYTHIC_DUNGEONS"]           = "Mostra cronômetro, % de conclusão e afixos em masmorras Mítica+."
L["FOCUS_M_BLOCK_POSITION"]                                   = "Posição do bloco M+"
L["FOCUS_POSITION_OF_MYTHIC_BLOCK_RELATIVE_QUEST"]            = "Posição do bloco Mítica+ em relação à lista de missões."
L["FOCUS_AFFIX_ICONS"]                                        = "Mostrar ícones de afixos"
L["FOCUS_AFFIX_ICONS_NEXT_MODIFIER_NAMES_M"]                  = "Mostra ícones de afixos ao lado dos modificadores no bloco M+."
L["FOCUS_AFFIX_DESCRIPTIONS_TOOLTIP"]                         = "Mostrar descrições de afixos na dica"
L["FOCUS_AFFIX_DESCRIPTIONS_HOVERING_M_BLO"]                  = "Mostra descrições de afixos ao passar o mouse sobre o bloco M+."
L["FOCUS_M_COMPLETED_BOSS_DISPLAY"]                           = "Exibição de chefes M+ concluídos"
L["FOCUS_DEFEATED_BOSSES_CHECKMARK_ICON_GREEN"]               = "Como mostrar chefes derrotados: ícone de marca ou cor verde."
L["FOCUS_CHECKMARK"]                                          = "Marca"
L["FOCUS_GREEN_COLOUR"]                                       = "Cor verde"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["PRESENCE_ACHIEVEMENTS"]                                    = "Mostrar conquistas"
L["FOCUS_TRACKED_ACHIEVEMENTS_LIST"]                          = "Mostra conquistas rastreadas na lista."
L["FOCUS_COMPLETED_ACHIEVEMENTS"]                             = "Mostrar conquistas concluídas"
L["FOCUS_INCLUDE_COMPLETED_ACHIEVEMENTS_TRACKER_O"]           = "Inclui conquistas concluídas no rastreador. Desativado: só conquistas em andamento são mostradas."
L["FOCUS_ACHIEVEMENT_ICONS"]                                  = "Mostrar ícones de conquistas"
L["FOCUS_ACHIEVEMENT_S_ICON_NEXT_TITLE_REQUI"]                = "Mostra o ícone de cada conquista ao lado do título. Requer \"Mostrar ícones de tipo de missão\" em Exibição."
L["FOCUS_MISSING_REQUIREMENTS"]                               = "Mostrar apenas requisitos faltando"
L["FOCUS_CRITERIA_YOU_HAVEN_T_COMPLETED_TR"]                  = "Mostra apenas critérios que você ainda não concluiu para cada conquista rastreada. Desativado: todos os critérios são mostrados."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["FOCUS_SHOW_ENDEAVORS"]                                     = "Mostrar Empreendimentos"
L["FOCUS_TRACKED_ENDEAVORS_PLAYER_HOUSING_LIST"]              = "Mostra Empreendimentos rastreados (Habitação do Jogador) na lista."
L["FOCUS_COMPLETED_ENDEAVORS"]                                = "Mostrar Empreendimentos concluídos"
L["FOCUS_INCLUDE_COMPLETED_ENDEAVORS_TRACKER"]                = "Inclui Empreendimentos concluídos no rastreador. Desativado: só Empreendimentos em andamento são mostrados."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["FOCUS_SHOW_DECOR"]                                         = "Mostrar decoração"
L["FOCUS_TRACKED_HOUSING_DECOR_LIST"]                         = "Mostra decorações de casa rastreadas na lista."
L["FOCUS_DECOR_ICONS"]                                        = "Mostrar ícones de decoração"
L["FOCUS_DECOR_ITEM_S_ICON_NEXT_TITLE"]                       = "Mostra o ícone de cada decoração ao lado do título. Requer \"Mostrar ícones de tipo de missão\" em Exibição."

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
L["FOCUS_ADVENTURE_GUIDE"]                                    = "Guia de Aventura"
L["FOCUS_TRAVELER_S_LOG"]                                     = "Mostrar Diário do Viajante"
L["FOCUS_TRACKED_TRAVELER_S_LOG_OBJECTIVES_SHIFT"]            = "Mostra objetivos rastreados do Diário do Viajante (Shift+clique no Guia de Aventura) na lista."
L["FOCUS_AUTO_REMOVE_COMPLETED_ACTIVITIES"]                   = "Remover automaticamente atividades concluídas"
L["FOCUS_AUTOMATICALLY_STOP_TRACKING_TRAVELER_S_LOG"]         = "Para automaticamente de rastrear atividades do Diário do Viajante quando concluídas."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["FOCUS_SCENARIO_EVENTS"]                                    = "Mostrar eventos de cenário"
L["FOCUS_ACTIVE_SCENARIO_DELVE_ACTIVITIES_DELVES_APP"]        = "Mostra cenários ativos e atividades de Delve. Delves aparecem em Delves; outros cenários em EVENTOS DE CENÁRIO."
L["FOCUS_TRACK_DELVE_DUNGEON_SCENARIO_ACTIVITIES"]            = "Rastrear atividades de Delves, Masmorras e cenários."
L["FOCUS_DELVES_APPEAR_DELVES_SECTION_DUNGEONS_DUNGEON"]      = "Delves aparecem na seção Delves; masmorras em Masmorra; outros cenários em Eventos de Cenário."
-- L["FOCUS_DELVES_APPEAR_DELVES_SECTION_SCENARIOS"]          = "Delves appear in Delves section; other scenarios in Scenario Events."
L["FOCUS_DELVE_AFFIX_NAMES"]                                  = "Delve affix names"
-- L["FOCUS_DELVE_DUNGEON"]                                   = "Delve/Dungeon only"
-- L["FOCUS_SCENARIO_DEBUG_LOGGING"]                          = "Scenario debug logging"
-- L["FOCUS_LOG_SCENARIO_API_DATA_CHAT_H"]                    = "Log scenario API data to chat. Use /h debug focus scendebug to toggle."
-- L["FOCUS_PRINTS_C_SCENARIOINFO_CRITERIA_WIDGET_DATA"]      = "Prints C_ScenarioInfo criteria and widget data when in a scenario. Helps diagnose display issues like Abundance 46/300."
L["FOCUS_HIDE_CATEGORIES_DELVE_DUNGEON"]                      = "Ocultar outras categorias em Delves ou Masmorras"
L["FOCUS_DELVES_PARTY_DUNGEONS_DELVE_DUNG"]                   = "Em Delves ou masmorras de grupo, mostra apenas a seção de Delve/Masmorra."
L["FOCUS_DELVE_NAME_SECTION_HEADER"]                          = "Usar nome do Delve como cabeçalho de seção"
L["FOCUS_A_DELVE_DELVE_NAME_TIER_AFFIXES"]                    = "Em um Delve, mostra nome, nível e afixos no cabeçalho da seção em vez de um banner separado. Desative para mostrar o bloco de Delve acima da lista."
L["FOCUS_AFFIX_NAMES_DELVES"]                                 = "Mostrar nomes de afixos em Delves"
L["FOCUS_SEASON_AFFIX_NAMES_FIRST_DELVE_ENTRY"]               = "Mostra nomes de afixos da temporada na primeira entrada de Delve. Requer widgets do rastreador de objetivos da Blizzard; pode não aparecer ao usar um rastreador totalmente substituto."
L["FOCUS_CINEMATIC_SCENARIO_BAR"]                             = "Barra de cenário cinematográfica"
L["FOCUS_TIMER_PROGRESS_BAR_SCENARIO_ENTRIES"]                = "Mostra cronômetro e barra de progresso para entradas de cenário."
L["FOCUS_TIMER"]                                              = "Mostrar cronômetro"
L["FOCUS_COUNTDOWN_TIMER_TIMED_QUESTS_EVENTS_SCEN"]           = "Mostra cronômetro em missões, eventos e cenários cronometrados. Desativado, os cronômetros são ocultados."
L["FOCUS_TIMER_SCENARIOS"]                                    = "Timers: scenarios & delves"
L["FOCUS_TIMER_SCENARIOS_DESC"]                               = "Countdown timer for scenario, delve, and dungeon tracker entries."
L["FOCUS_TIMER_WORLD"]                                        = "Timers: world & callings"
L["FOCUS_TIMER_WORLD_DESC"]                                   = "Countdown timer for world quests and callings."
L["FOCUS_TIMER_QUEST_LOG"]                                    = "Timers: quest log (timed)"
L["FOCUS_TIMER_QUEST_LOG_DESC"]                               = "Countdown timer for dailies, weeklies, and other quest log entries with a time limit."
L["FOCUS_TIMER_DISPLAY"]                                      = "Exibição do cronômetro"
L["FOCUS_COLOUR_TIMER_REMAINING"]                             = "Cor do cronômetro por tempo restante"
L["FOCUS_GREEN_PLENTY_OF_LEFT_YELLOW_RUNNING"]                = "Verde quando há tempo, amarelo quando está acabando, vermelho quando crítico."
L["FOCUS_WHERE_COUNTDOWN_BAR_BELOW_OBJECTIVES"]               = "Onde exibir a contagem regressiva: barra abaixo dos objetivos ou texto ao lado do nome da missão."
L["FOCUS_BAR_BELOW"]                                          = "Barra abaixo"
L["FOCUS_INLINE_BESIDE_TITLE"]                                = "Ao lado do título"

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["FOCUS_FONT_FAMILY"]                                        = "Família de fonte."
L["FOCUS_TITLE_FONT"]                                         = "Fonte dos títulos"
L["VISTA_ZONE_FONT"]                                          = "Fonte da zona"
L["FOCUS_OBJECTIVE_FONT"]                                     = "Fonte dos objetivos"
L["FOCUS_SECTION_FONT"]                                       = "Fonte das seções"
L["FOCUS_GLOBAL_FONT"]                                        = "Usar fonte global"
L["FOCUS_FONT_FAMILY_QUEST_TITLES"]                           = "Família de fonte dos títulos de missão."
L["FOCUS_FONT_FAMILY_ZONE_LABELS"]                            = "Família de fonte dos rótulos de zona."
L["FOCUS_FONT_FAMILY_OBJECTIVE_TEXT"]                         = "Família de fonte do texto dos objetivos."
L["FOCUS_FONT_FAMILY_SECTION_HEADERS"]                        = "Família de fonte dos cabeçalhos de seção."
L["FOCUS_HEADER_SIZE"]                                        = "Tamanho do cabeçalho"
L["FOCUS_HEADER_FONT_SIZE"]                                   = "Tamanho da fonte do cabeçalho."
L["FOCUS_TITLE_SIZE"]                                         = "Tamanho do título"
L["FOCUS_QUEST_TITLE_FONT_SIZE"]                              = "Tamanho da fonte dos títulos de missão."
L["FOCUS_OBJECTIVE_SIZE"]                                     = "Tamanho dos objetivos"
L["FOCUS_OBJECTIVE_TEXT_FONT_SIZE"]                           = "Tamanho da fonte do texto dos objetivos."
L["FOCUS_ZONE_SIZE"]                                          = "Tamanho das zonas"
L["FOCUS_ZONE_LABEL_FONT_SIZE"]                               = "Tamanho da fonte dos rótulos de zona."
L["FOCUS_SECTION_SIZE"]                                       = "Tamanho das seções"
L["FOCUS_SECTION_HEADER_FONT_SIZE"]                           = "Tamanho da fonte dos cabeçalhos de seção."
L["FOCUS_PROGRESS_BAR_FONT"]                                  = "Fonte da barra de progresso"
L["FOCUS_FONT_FAMILY_PROGRESS_BAR_LABEL"]                     = "Família de fonte para o texto da barra de progresso."
L["FOCUS_PROGRESS_BAR_TEXT_SIZE"]                             = "Tamanho do texto da barra de progresso"
L["FOCUS_FONT_SIZE_PROGRESS_BAR_LABEL_ADJUSTS"]               = "Tamanho da fonte do texto da barra de progresso. Também ajusta a altura da barra. Afeta objetivos de missões, progresso de cenário e barras de timer."
-- L["FOCUS_TIMER_TEXT_FONT"]                                 = "Timer Font"
-- L["FOCUS_FONT_FAMILY_TIMER_TEXT"]                          = "Font family for quest timer text (inline timers and world quest timers)."
-- L["FOCUS_TIMER_TEXT_SIZE"]                                 = "Timer Text Size"
-- L["FOCUS_TIMER_TEXT_FONT_SIZE"]                            = "Quest timer text font size."
-- L["FOCUS_OPTIONS_FONT"]                                    = "Options Font"
-- L["FOCUS_FONT_FAMILY_OPTIONS"]                             = "Font family for the Options button label in the tracker header."
-- L["FOCUS_OPTIONS_TEXT_SIZE"]                               = "Options Text Size"
-- L["FOCUS_OPTIONS_TEXT_FONT_SIZE"]                          = "Options button label font size."
L["FOCUS_PROGRESS_BAR_FILL"]                                  = "Preenchimento da barra de progresso"
L["FOCUS_PROGRESS_BAR_TEXT"]                                  = "Texto da barra de progresso"
L["FOCUS_OUTLINE"]                                            = "Contorno"
L["FOCUS_FONT_OUTLINE_STYLE"]                                 = "Estilo de contorno da fonte."

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["FOCUS_HEADER_TEXT_CASE"]                                   = "Caixa de texto do cabeçalho"
L["FOCUS_DISPLAY_CASE_HEADER"]                                = "Caixa de exibição para o cabeçalho."
L["FOCUS_SECTION_HEADER_CASE"]                                = "Caixa dos cabeçalhos de seção"
L["FOCUS_DISPLAY_CASE_CATEGORY_LABELS"]                       = "Caixa de exibição para rótulos de categoria."
L["FOCUS_QUEST_TITLE_CASE"]                                   = "Caixa dos títulos de missão"
L["FOCUS_DISPLAY_CASE_QUEST_TITLES"]                          = "Caixa de exibição para títulos de missão."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["FOCUS_TEXT_SHADOW"]                                        = "Mostrar sombra do texto"
L["FOCUS_ENABLE_DROP_SHADOW_TEXT"]                            = "Ativa sombra projetada no texto."
L["FOCUS_SHADOW_X"]                                           = "Sombra X"
L["FOCUS_HORIZONTAL_SHADOW_OFFSET"]                           = "Deslocamento horizontal da sombra."
L["FOCUS_SHADOW_Y"]                                           = "Sombra Y"
L["FOCUS_VERTICAL_SHADOW_OFFSET"]                             = "Deslocamento vertical da sombra."
L["FOCUS_SHADOW_ALPHA"]                                       = "Opacidade da sombra"
L["FOCUS_SHADOW_OPACITY"]                                     = "Opacidade da sombra (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["FOCUS_MYTHIC_TYPOGRAPHY"]                                  = "Tipografia de Mítica+"
L["FOCUS_DUNGEON_NAME_SIZE"]                                  = "Tamanho do nome da masmorra"
L["FOCUS_FONT_SIZE_DUNGEON_NAME_PX"]                          = "Tamanho da fonte do nome da masmorra (8–32 px)."
L["FOCUS_DUNGEON_NAME_COLOUR"]                                = "Cor do nome da masmorra"
L["FOCUS_TEXT_COLOUR_DUNGEON_NAME"]                           = "Cor do texto do nome da masmorra."
L["FOCUS_TIMER_SIZE"]                                         = "Tamanho do cronômetro"
L["FOCUS_FONT_SIZE_TIMER_PX"]                                 = "Tamanho da fonte do cronômetro (8–32 px)."
L["FOCUS_TIMER_COLOUR"]                                       = "Cor do cronômetro"
L["FOCUS_TEXT_COLOUR_TIMER"]                                  = "Cor do texto do cronômetro (no tempo)."
L["FOCUS_TIMER_OVERTIME_COLOUR"]                              = "Cor do cronômetro em atraso"
L["FOCUS_TEXT_COLOUR_TIMER_LIMIT"]                            = "Cor do texto do cronômetro quando o tempo acabou."
L["FOCUS_PROGRESS_SIZE"]                                      = "Tamanho da progressão"
L["FOCUS_FONT_SIZE_ENEMY_FORCES_PX"]                          = "Tamanho da fonte das forças inimigas (8–32 px)."
L["FOCUS_PROGRESS_COLOUR"]                                    = "Cor da progressão"
L["FOCUS_TEXT_COLOUR_ENEMY_FORCES"]                           = "Cor do texto das forças inimigas."
L["FOCUS_BAR_FILL_COLOUR"]                                    = "Cor de preenchimento da barra"
L["FOCUS_PROGRESS_BAR_FILL_COLOUR_PROGRESS"]                  = "Cor de preenchimento da barra de progresso (em andamento)."
L["FOCUS_BAR_COMPLETE_COLOUR"]                                = "Cor da barra concluída"
L["FOCUS_PROGRESS_BAR_FILL_COLOUR_ENEMY_FORCES"]              = "Cor de preenchimento da barra quando as forças inimigas estão em 100%."
L["FOCUS_AFFIX_SIZE"]                                         = "Tamanho dos afixos"
L["FOCUS_FONT_SIZE_AFFIXES_PX"]                               = "Tamanho da fonte dos afixos (8–32 px)."
L["FOCUS_AFFIX_COLOUR"]                                       = "Cor dos afixos"
L["FOCUS_TEXT_COLOUR_AFFIXES"]                                = "Cor do texto dos afixos."
L["FOCUS_BOSS_SIZE"]                                          = "Tamanho dos nomes dos chefes"
L["FOCUS_FONT_SIZE_BOSS_NAMES_PX"]                            = "Tamanho da fonte dos nomes dos chefes (8–32 px)."
L["FOCUS_BOSS_COLOUR"]                                        = "Cor dos nomes dos chefes"
L["FOCUS_TEXT_COLOUR_BOSS_NAMES"]                             = "Cor do texto dos nomes dos chefes."
L["FOCUS_RESET_MYTHIC_TYPOGRAPHY"]                            = "Redefinir tipografia de M+"

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
L["FOCUS_BACKDROP_OPACITY"]                                   = "Opacidade do fundo"
L["FOCUS_PANEL_BACKGROUND_OPACITY"]                           = "Opacidade do fundo do painel (0–1)."
L["FOCUS_BORDER"]                                             = "Mostrar borda"
L["FOCUS_BORDER_AROUND_TRACKER"]                              = "Mostra uma borda ao redor do rastreador."
L["FOCUS_SCROLL_INDICATOR"]                                   = "Mostrar indicador de rolagem"
L["FOCUS_A_VISUAL_HINT_LIST_CONTENT_TH"]                      = "Mostra um indicador visual quando a lista tem mais conteúdo do que o visível."
L["FOCUS_SCROLL_INDICATOR_STYLE"]                             = "Estilo do indicador de rolagem"
L["FOCUS_CHOOSE_BETWEEN_A_FADE_GRADIENT_A"]                   = "Escolha entre um gradiente de desvanecimento ou uma pequena seta para indicar conteúdo rolável."
L["FOCUS_ARROW"]                                              = "Seta"
L["FOCUS_HIGHLIGHT_ALPHA"]                                    = "Opacidade do destaque"
L["FOCUS_OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]                 = "Opacidade do destaque da missão focada (0–1)."
L["FOCUS_BAR_WIDTH"]                                          = "Largura da barra"
L["FOCUS_WIDTH_OF_BAR_STYLE_HIGHLIGHTS_PX"]                   = "Largura dos destaques em forma de barra (2–6 px)."

-- =====================================================================
-- OptionsData.lua Organisation
-- =====================================================================
-- L["FOCUS_ACTIVITY"]                                        = "Activity"
-- L["FOCUS_CONTENT"]                                         = "Content"
-- L["FOCUS_SORTING"]                                         = "Sorting"
-- L["FOCUS_ELEMENTS"]                                        = "Elements"
L["FOCUS_CATEGORY_ORDER"]                                     = "Ordem das categorias de Foco"
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
L["FOCUS_CATEGORY_ORDER"]                                     = "Ordem das categorias de Foco"
L["FOCUS_CATEGORIES_REORDER_EXCEPT_DELVES_SCENARIOS"]         = "Arraste para reordenar categorias. Delves e EVENTOS DE CENÁRIO permanecem primeiro."
-- L["FOCUS_CATEGORIES_REORDER_EXCEPT_DELVES_SCENARIOS_TIP"]  = "Drag to reorder. Delves and Scenarios stay first."
L["FOCUS_SORT_MODE"]                                          = "Modo de ordenação do Foco"
L["FOCUS_ENTRY_NUMBER_IN_CATEGORY"]                           = "Ordem das entradas em cada categoria."
L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS"]                         = "Rastrear automaticamente missões aceitas"
L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS_TIP"]                     = "Ao aceitar uma missão (apenas diário, não missões mundiais), adiciona-a automaticamente ao rastreador."
L["FOCUS_CTRL_FOCUS_REMOVE"]                                  = "Exigir Ctrl para focar e remover"
L["FOCUS_CTRL_FOCUS_REMOVE_MOUSECLICK"]                       = "Exige Ctrl para focar/adicionar (botão esquerdo) e desfocar/parar de rastrear (botão direito) para evitar cliques acidentais."
L["FOCUS_CTRL_FOCUS_UNTRACK"]                                 = "Ctrl for focus / untrack"
L["FOCUS_CTRL_CLICK_COMPLETE"]                                = "Ctrl to click-complete"
L["FOCUS_CLASSIC_CLICK_BEHAVIOUR"]                            = "Usar comportamento de clique clássico"
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
L["FOCUS_SHARE_PARTY"]                                        = "Compartilhar com grupo"
L["FOCUS_ABANDON_QUEST"]                                      = "Abandonar missão"
-- L["FOCUS_CONTEXT_FOCUS_QUEST"]                             = "Focus quest"
L["FOCUS_STOP_TRACKING"]                                      = "Parar de rastrear"
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
L["FOCUS_CANNOT_SHARE_QUEST"]                                 = "Esta missão não pode ser compartilhada."
L["FOCUS_REQUIRE_PARTY_SHARE"]                                = "Você precisa estar em um grupo para compartilhar esta missão."
L["FOCUS_LEFT_CLICK_MAP_RIGHT_CLICK_ABANDON"]                 = "Quando ativado, clique esquerdo abre o mapa da missão e clique direito exibe o menu compartilhar/abandonar (estilo Blizzard). Quando desativado, clique esquerdo foca e clique direito remove rastreamento; Ctrl+clique direito compartilha com o grupo."
L["FOCUS_ANIMATIONS"]                                         = "Focus animations"
L["FOCUS_SLIDE_FADE_QUESTS"]                                  = "Ativa deslizar e esmaecer para missões."
L["FOCUS_OBJECTIVE_PROGRESS_FLASH"]                           = "Flash de progresso de objetivo"
L["FOCUS_FLASH_OBJECTIVE_COMPLETION"]                         = "Mostra um flash quando um objetivo é concluído."
L["FOCUS_FLASH_INTENSITY"]                                    = "Intensidade do flash"
L["FOCUS_OBJECTIVE_PROGRESS_FLASH_VISIBILITY"]                = "Quão perceptível é o flash de conclusão de objetivo."
L["FOCUS_FLASH_COLOUR"]                                       = "Cor do flash"
L["FOCUS_FLASH_COLOUR_DESC"]                                  = "Cor do flash de conclusão de objetivo."
L["FOCUS_SUBTLE"]                                             = "Sutil"
L["FOCUS_MEDIUM"]                                             = "Médio"
L["FOCUS_STRONG"]                                             = "Forte"
L["FOCUS_REQUIRE_CTRL_CLICK_COMPLETE"]                        = "Exigir Ctrl para clicar e concluir"
L["FOCUS_REQUIRES_CTRL_LEFT_CLICK_COMPLETE_AUTO"]             = "Ativado: exige Ctrl+clique esquerdo para concluir missões de auto-conclusão. Desativado: clique esquerdo simples conclui (padrão Blizzard). Afeta apenas missões que podem ser concluídas por clique (sem entregar a um NPC)."
L["FOCUS_SUPPRESS_UNTRACKED_UNTIL_RELOAD"]                    = "Ocultar não rastreadas até recarregar"
L["FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS"]                   = "Ativado: clicar com o botão direito para parar de rastrear missões mundiais e semanais/diárias na zona as oculta até você recarregar ou iniciar uma nova sessão. Desativado: elas reaparecem quando você volta à zona."
L["FOCUS_PERMANENTLY_SUPPRESS_UNTRACKED_QUESTS"]              = "Ocultar permanentemente missões não rastreadas"
L["FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS_DESC"]              = "Ativado: missões mundiais e semanais/diárias na zona marcadas como não rastreadas ficam ocultas permanentemente (persiste entre recargas). Tem prioridade sobre \"Ocultar até recarregar\". Aceitar uma missão oculta a remove da lista negra."
L["FOCUS_KEEP_CAMPAIGN_CATEGORY"]                             = "Manter missões de campanha na categoria"
L["FOCUS_CAMPAIGN_READY_STAY"]                                = "Ativado: missões de campanha prontas para entregar permanecem na categoria Campanha em vez de ir para Concluídas."
L["FOCUS_KEEP_IMPORTANT_QUESTS_CATEGORY"]                     = "Manter missões importantes na categoria"
L["FOCUS_IMPORTANT_READY_STAY"]                               = "Ativado: missões importantes prontas para entregar permanecem na categoria Importante em vez de ir para Concluídas."
L["FOCUS_TOMTOM_QUEST_WAYPOINT"]                              = "Ponto de referência TomTom"
L["FOCUS_TOMTOM_QUEST_WAYPOINT_TIP"]                          = "Definir um ponto de referência TomTom ao focar uma missão."
L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_NEXT_QUEST"]            = "Requer TomTom. Aponta a seta para o próximo objetivo da missão."
L["FOCUS_TOMTOM_RARE_WAYPOINT"]                               = "Ponto de referência TomTom (raro)"
L["FOCUS_TOMTOM_WAYPOINT_RARE_CLICK"]                         = "Definir um ponto de referência TomTom ao clicar em um chefe raro."
L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_RARE"]                  = "Requer TomTom. Aponta a seta para a localização do chefe raro."
L["FOCUS_FIND_GROUP"]                                         = "Encontrar um Grupo"
L["FOCUS_GROUP_QUEST_SEARCH_CLICK"]                           = "Clique para procurar um grupo para esta missao."

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
L["FOCUS_BLACKLIST"]                                          = "Lista negra"
L["FOCUS_BLACKLIST_UNTRACKED"]                                = "Blacklist untracked"
-- L["FOCUS_ENABLE_BLACKLIST_UNTRACKED_BEHAVIOUR_ADD_QUEST"]  = "Enable 'Blacklist untracked' in Behaviour to add quests here."
-- L["FOCUS_HIDDEN_QUESTS"]                                   = "Hidden Quests"
-- L["FOCUS_QUESTS_HIDDEN_RIGHT_CLICK_UNTRACK"]               = "Quests hidden via right-click untrack."
L["FOCUS_BLACKLISTED_QUESTS"]                                 = "Missões na lista negra"
L["FOCUS_PERMANENTLY_SUPPRESSED_QUESTS"]                      = "Missões ocultas permanentemente"
L["FOCUS_RIGHT_CLICK_UNTRACK_QUESTS_PERMANENTLY_SUPPRESS"]    = "Clique com o botão direito para parar de rastrear missões com \"Ocultar permanentemente missões não rastreadas\" ativado para adicioná-las aqui."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["PRESENCE_QUEST_TYPE_ICONS"]                                = "Mostrar ícones de tipo de missão"
L["PRESENCE_QUEST_TYPE_ICON_FOCUS_TRACKER_QUEST"]             = "Mostra ícone de tipo de missão no rastreador Foco (aceitar/concluir missão, missão mundial, atualização de missão)."
L["PRESENCE_QUEST_TYPE_ICONS_TOASTS"]                         = "Mostrar ícones de tipo nas notificações"
L["PRESENCE_QUEST_TYPE_ICON_PRESENCE_TOASTS_QUEST"]           = "Mostra ícone de tipo nas notificações Presence (aceitar/concluir missão, missão mundial, atualização de missão)."
L["PRESENCE_TOAST_ICON_SIZE"]                                 = "Tamanho dos ícones das notificações"
L["PRESENCE_QUEST_ICON_SIZE_PRESENCE_TOASTS_PX"]              = "Tamanho do ícone de missão nas notificações Presence (16–36 px). Padrão 24."
L["PRESENCE_HIDE_QUEST_UPDATE_TITLE"]                         = "Ocultar título no avanço de missão"
L["PRESENCE_OBJECTIVE_LINE_QUEST_PROGRESS_TOAST"]             = "Mostra apenas a linha do objetivo (ex.: 7/10 Peles de javali), sem o nome da missão ou cabeçalho."
L["PRESENCE_SHOW_DISCOVERY_LINE"]                             = "Mostrar linha de descoberta"
L["PRESENCE_DISCOVERY_LINE"]                                  = "Discovery line"
L["PRESENCE_SHOW_DISCOVERED"]                                 = "Mostra \"Descoberto\" sob zona/subzona ao entrar em uma nova área."
L["PRESENCE_FRAME_VERTICAL_POSITION"]                         = "Posição vertical do quadro"
L["PRESENCE_VERTICAL_OFFSET_OF_PRESENCE_FRAME_CENTER"]        = "Deslocamento vertical do quadro Presence a partir do centro (-300 a 0)."
L["PRESENCE_FRAME_SCALE"]                                     = "Escala do quadro"
L["PRESENCE_FRAME_SCALE_TIP"]                                 = "Escala do quadro Presence (0,5–2)."
L["PRESENCE_BOSS_EMOTE_COLOUR"]                               = "Cor dos emotes de chefe"
L["PRESENCE_COLOUR_RAID_DUNGEON_BOSS_EMOTE"]                  = "Cor do texto de emotes de chefes de raide e masmorra."
L["PRESENCE_DISCOVERY_LINE_COLOUR"]                           = "Cor da linha de descoberta"
L["PRESENCE_COLOUR_OF_DISCOVERED_LINE_UNDER_ZONE_TIP"]        = "Cor da linha \"Descoberto\" sob o texto de zona."
L["PRESENCE_NOTIFICATION_TYPES"]                              = "Tipos de notificação"
-- L["PRESENCE_NOTIFICATIONS"]                                = "Notifications"
-- L["PRESENCE_NOTIFICATION_ACHIEVEMENT_CRITERIA_UPDATE"]     = "Show notification when achievement criteria update (tracked achievements always; others when Blizzard provides the achievement ID)."
L["PRESENCE_ZONE_ENTRY"]                                      = "Mostrar entrada em zona"
L["PRESENCE_ZONE_CHANGE_ENTERING_A_AREA"]                     = "Mostra notificação ao entrar em uma nova área."
L["PRESENCE_SUBZONE_CHANGES"]                                 = "Mostrar mudanças de subzona"
L["PRESENCE_SUBZONE_CHANGE_MOVING_WITHIN_SAME_ZONE"]          = "Mostra notificação ao se mover entre subzonas na mesma zona."
L["PRESENCE_HIDE_ZONE_NAME_SUBZONE_CHANGES"]                  = "Ocultar nome da zona para mudanças de subzona"
L["PRESENCE_MOVING_BETWEEN_SUBZONES_WITHIN_SAME_ZONE"]        = "Ao se mover entre subzonas na mesma zona, mostra apenas o nome da subzona. O nome da zona ainda aparece ao entrar em uma nova zona."
-- L["PRESENCE_SUPPRESS_DELVE"]                               = "Suppress in Delve"
-- L["PRESENCE_SUPPRESS_SCENARIO_PROGRESS_NOTIFICATIONS_DELVES"]= "Suppress scenario progress notifications in Delves."
-- L["PRESENCE_HIDE_DELVE_OBJECTIVE_UPDATE"]                  = "When on, hides objective update popups while in a Delve. Zone entry and completion toasts still show."
L["PRESENCE_SUPPRESS_ZONE_CHANGES_MYTHIC"]                    = "Suprimir mudanças de zona em Mítico+"
L["PRESENCE_MYTHICPLUS_SHOW_BOSS_EMOTES_ACHIEVEMENTS_LEVELS"]   = "Em Mítico+, mostra apenas emotes de chefe, conquistas e subida de nível. Oculta notificações de zona, missão e cenário."
L["PRESENCE_LEVEL"]                                           = "Mostrar subir de nível"
L["PRESENCE_LEVEL_NOTIFICATION"]                              = "Mostra notificação de subida de nível."
L["PRESENCE_BOSS_EMOTES"]                                     = "Mostrar emotes de chefe"
L["PRESENCE_RAID_DUNGEON_BOSS_EMOTE_NOTIFICATIONS"]           = "Mostra notificações de emotes de chefes em raides e masmorras."
L["PRESENCE_ACHIEVEMENTS"]                                    = "Mostrar conquistas"
L["PRESENCE_ACHIEVEMENT_EARNED_NOTIFICATIONS"]                = "Mostra notificações de conquistas obtidas."
L["PRESENCE_ACHIEVEMENT_PROGRESS"]                            = "Progresso de conquistas"
L["PRESENCE_SHOW_ACHIEVEMENT_EARNED"]                         = "Conquista obtida"
L["PRESENCE_SHOW_QUEST_ACCEPTED"]                             = "Missão aceita"
L["PRESENCE_SHOW_WORLD_QUEST_ACCEPTED"]                       = "Missão mundial aceita"
L["PRESENCE_SHOW_SCENARIO_COMPLETE"]                          = "Cenário concluído"
L["PRESENCE_SHOW_RARE_DEFEATED"]                              = "Raro derrotado"
L["PRESENCE_NOTIFICATION_TRACKED_ACHIEVEMENT_CRITERIA"]       = "Mostra notificação quando os critérios de uma conquista rastreada são atualizados."
L["PRESENCE_QUEST_ACCEPT"]                                    = "Mostrar aceitação de missão"
L["PRESENCE_NOTIFICATION_ACCEPTING_A_QUEST"]                  = "Mostra notificação ao aceitar uma missão."
L["PRESENCE_WORLD_QUEST_ACCEPT"]                              = "Mostrar aceitação de missão mundial"
L["PRESENCE_NOTIFICATION_ACCEPTING_A_WORLD_QUEST"]            = "Mostra notificação ao aceitar uma missão mundial."
L["PRESENCE_SHOW_QUEST_COMPLETE"]                             = "Mostrar conclusão de missão"
L["PRESENCE_NOTIFICATION_COMPLETING_A_QUEST"]                 = "Mostra notificação ao concluir uma missão."
L["PRESENCE_SHOW_WORLD_QUEST_COMPLETE"]                       = "Mostrar conclusão de missão mundial"
L["PRESENCE_NOTIFICATION_COMPLETING_A_WORLD_QUEST"]           = "Mostra notificação ao concluir uma missão mundial."
L["PRESENCE_QUEST_PROGRESS"]                                  = "Mostrar progresso da missão"
L["PRESENCE_NOTIFICATION_QUEST_OBJECTIVES_UPDATE"]            = "Mostra notificação quando objetivos da missão são atualizados."
L["PRESENCE_OBJECTIVE"]                                       = "Apenas objetivo"
L["PRESENCE_QUEST_PROGRESS_HIDE_TITLE"]                       = "Mostra apenas a linha do objetivo nas notificações de progresso, ocultando o título 'Atualização de Missão'."
L["PRESENCE_SCENARIO_START"]                                  = "Mostrar início de cenário"
L["PRESENCE_NOTIFICATION_ENTERING_A_SCENARIO_DELVE"]          = "Mostra notificação ao entrar em um cenário ou Profundezas."
L["PRESENCE_SCENARIO_PROGRESS"]                               = "Mostrar progresso do cenário"
L["PRESENCE_NOTIFICATION_SCENARIO_DELVE_OBJECTIVES"]          = "Mostra notificação quando objetivos de cenário ou Profundezas são atualizados."
L["PRESENCE_ANIMATION"]                                       = "Animação"
L["PRESENCE_ENABLE_ANIMATIONS"]                               = "Ativar animações"
L["PRESENCE_ENABLE_ENTRANCE_EXIT_ANIMATIONS_PRESENCE"]        = "Ativa animações de entrada e saída para notificações Presence."
L["PRESENCE_ENTRANCE_DURATION"]                               = "Duração da entrada"
L["PRESENCE_DURATION_OF_ENTRANCE_ANIMATION_SECONDS"]          = "Duração da animação de entrada em segundos (0,2–1,5)."
L["PRESENCE_EXIT_DURATION"]                                   = "Duração da saída"
L["PRESENCE_DURATION_OF_EXIT_ANIMATION_SECONDS"]              = "Duração da animação de saída em segundos (0,2–1,5)."
L["PRESENCE_HOLD_DURATION_SCALE"]                             = "Fator de duração em tela"
L["PRESENCE_MULTIPLIER_LONG_NOTIFICATION_STAY"]               = "Multiplicador de quanto tempo cada notificação permanece na tela (0,5–2)."
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
L["DASH_TYPOGRAPHY"]                                          = "Tipografia"
L["PRESENCE_MAIN_TITLE_FONT"]                                 = "Fonte do título principal"
L["PRESENCE_FONT_FAMILY_MAIN_TITLE"]                          = "Família de fontes do título principal."
L["PRESENCE_SUBTITLE_FONT"]                                   = "Fonte do subtítulo"
L["PRESENCE_FONT_FAMILY_SUBTITLE"]                            = "Família de fontes do subtítulo."
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
L["FOCUS_OUTLINE_NONE"]                                       = "Nenhum"
L["FOCUS_THICK_OUTLINE"]                                      = "Contorno espesso"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["FOCUS_HIGHLIGHT_BAR_LEFT_EDGE"]                            = "Barra (borda esquerda)"
L["FOCUS_HIGHLIGHT_BAR_RIGHT_EDGE"]                           = "Barra (borda direita)"
L["FOCUS_HIGHLIGHT_BAR_TOP_EDGE"]                             = "Barra (borda superior)"
L["FOCUS_HIGHLIGHT_BAR_BOTTOM_EDGE"]                          = "Barra (borda inferior)"
L["FOCUS_HIGHLIGHT_OUTLINE_ONLY"]                             = "Apenas contorno"
L["FOCUS_HIGHLIGHT_SOFT_GLOW"]                                = "Brilho suave"
L["FOCUS_HIGHLIGHT_DUAL_EDGE_BARS"]                           = "Barras duplas nas bordas"
L["FOCUS_HIGHLIGHT_PILL_LEFT_ACCENT"]                         = "Realce em pílula à esquerda"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["FOCUS_MYTHICPLUS_POSITION_TOP"]                            = "Topo"
L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"]                         = "Fundo"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["VISTA_LOCATION_POSITION"]                                  = "Posição do nome da zona"
L["VISTA_PLACE_ZONE_NAME_ABOVE_BELOW_MINIMAP"]                = "Coloca o nome da zona acima ou abaixo do minimapa."
L["VISTA_COORDINATES_POSITION"]                               = "Posição das coordenadas"
L["VISTA_PLACE_COORDINATES_ABOVE_BELOW_MINIMAP"]              = "Coloca as coordenadas acima ou abaixo do minimapa."
L["VISTA_CLOCK_POSITION"]                                     = "Posição do relógio"
L["VISTA_PLACE_CLOCK_ABOVE_BELOW_MINIMAP"]                    = "Coloca o relógio acima ou abaixo do minimapa."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["FOCUS_TEXT_LOWER_CASE"]                                    = "Minúsculas"
L["FOCUS_TEXT_UPPER_CASE"]                                    = "Maiúsculas"
L["FOCUS_TEXT_PROPER_CASE"]                                   = "Primeira letra maiúscula"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["FOCUS_TRACKED_LOG"]                                        = "Rastreadas / no diário"
L["FOCUS_LOG_MAX_SLOTS"]                                      = "No diário / vagas máx."

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["FOCUS_ALPHABETICAL"]                                       = "Alfabética"
L["FOCUS_QUEST_TYPE"]                                         = "Tipo de missão"
L["FOCUS_QUEST_LEVEL"]                                        = "Nível da missão"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["FOCUS_CUSTOM"]                                             = "Personalizado"
L["FOCUS_ORDER"]                                              = "Ordem"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["UI_DUNGEON"]                                               = "MASMORRA"
L["UI_RAID"]                                                  = "RAIDE"
-- L["UI_DELVES"]                                             = "Delves"
L["UI_SCENARIO_EVENTS"]                                       = "EVENTOS DE CENÁRIO"
-- L["UI_STAGE"]                                              = "Stage"
-- L["UI_STAGE_X_X"]                                          = "Stage %d: %s"
L["UI_AVAILABLE_IN_ZONE"]                                     = "DISPONÍVEL NA ZONA"
L["UI_EVENTS_IN_ZONE"]                                        = "Eventos na zona"
L["UI_CURRENT_EVENT"]                                         = "Evento atual"
L["UI_CURRENT_QUEST"]                                         = "MISSÃO ATUAL"
L["UI_CURRENT_ZONE"]                                          = "ZONA ATUAL"
L["UI_CAMPAIGN"]                                              = "CAMPANHA"
L["UI_IMPORTANT"]                                             = "IMPORTANTE"
L["UI_LEGENDARY"]                                             = "LENDÁRIA"
L["UI_WORLD_QUESTS"]                                          = "MISSÕES MUNDIAIS"
L["UI_WEEKLY_QUESTS"]                                         = "MISSÕES SEMANAIS"
L["UI_PREY"]                                                  = "Presa"
L["UI_ABUNDANCE"]                                             = "Abundância"
L["UI_ABUNDANCE_BAG"]                                         = "Bolsa de abundância"
L["UI_ABUNDANCE_HELD"]                                        = "abundância retida"
L["UI_DAILY_QUESTS"]                                          = "MISSÕES DIÁRIAS"
L["UI_RARE_BOSSES"]                                           = "CHEFES RAROS"
L["UI_ACHIEVEMENTS"]                                          = "CONQUISTAS"
L["UI_ENDEAVORS"]                                             = "EMPREENDIMENTOS"
L["UI_DECOR"]                                                 = "DECORAÇÃO"
-- L["UI_RECIPES"]                                            = "Recipes"
-- L["UI_ADVENTURE_GUIDE"]                                    = "Adventure Guide"
-- L["UI_APPEARANCES"]                                        = "Appearances"
L["UI_QUESTS"]                                                = "MISSÕES"
L["UI_READY_TO_TURN_IN"]                                      = "PRONTO PARA ENTREGAR"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["PRESENCE_OBJECTIVES"]                                      = "OBJETIVOS"
L["PRESENCE_OPTIONS"]                                         = "Opções"
L["PRESENCE_OPEN_HORIZON_SUITE"]                              = "Abrir Horizon Suite"
L["PRESENCE_OPEN_FULL_HORIZON_SUITE_OPTIONS"]                 = "Abre o painel de opções completo para configurar Focus, Presence, Vista e outros módulos."
L["PRESENCE_MINIMAP_SECTION"]                                 = "Minimap icon"
L["PRESENCE_SHOW_MINIMAP_ICON"]                               = "Mostrar ícone no minimapa"
L["PRESENCE_A_CLICKABLE_ICON_MINIMAP_OPENS"]                  = "Mostra um ícone clicável no minimapa que abre o painel de opções."
L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER"]         = "Fade until minimap hover"
-- L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER_DESC"] = "When on, the icon stays faded until you move the cursor over the minimap. When off, it stays fully visible."
L["PRESENCE_LOCK_MINIMAP_BUTTON_POSITION"]                    = "Lock minimap button position"
-- L["PRESENCE_PREVENT_DRAGGING_HORIZON_MINIMAP_BUTTON"]      = "Prevent dragging the Horizon minimap button."
L["PRESENCE_RESET_MINIMAP_BUTTON_POSITION"]                   = "Reset minimap button position"
-- L["PRESENCE_RESET_MINIMAP_BUTTON_DEFAULT_POSITION"]        = "Reset the minimap button to the default position (bottom-left)."
-- L["PRESENCE_DRAG_TO_MOVE_WHEN_UNLOCKED"]                   = "Drag to move (when unlocked)."
-- L["PRESENCE_LOCKED"]                                       = "Locked"
L["PRESENCE_DISCOVERED"]                                      = "Descoberto"
L["PRESENCE_REFRESH"]                                         = "Atualizar"
L["PRESENCE_BEST_EFFORT_UNACCEPTED_QUESTS_EXPO"]              = "Melhor esforço apenas. Algumas missões não aceitas não são exibidas até você interagir com NPCs ou atender às condições de faseamento."
L["PRESENCE_UNACCEPTED_QUESTS_X_MAP_X"]                       = "Missões não aceitas - %s (mapa %s) - %d correspondência(s)"
L["PRESENCE_LEVEL_UP"]                                        = "SUBIU DE NÍVEL"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_80"]                       = "Você alcançou o nível 80"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_X"]                        = "Você alcançou o nível %s"
L["PRESENCE_ACHIEVEMENT_EARNED"]                              = "CONQUISTA OBTIDA"
L["PRESENCE_EXPLORING_THE_MIDNIGHT_ISLES"]                    = "Explorando as Ilhas da Meia-noite"
L["PRESENCE_EXPLORING_KHAZ_ALGAR"]                            = "Explorando Khaz Algar"
L["PRESENCE_QUEST_COMPLETE"]                                  = "MISSÃO CONCLUÍDA"
L["PRESENCE_OBJECTIVE_SECURED"]                               = "Objetivo Garantido"
L["PRESENCE_AIDING_THE_ACCORD"]                               = "Ajudando o Pacto"
L["PRESENCE_WORLD_QUEST"]                                     = "MISSÃO MUNDIAL"
L["PRESENCE_WORLD_QUEST_COMPLETE"]                            = "MISSÃO MUNDIAL CONCLUÍDA"
L["PRESENCE_AZERITE_MINING"]                                  = "Mineração de Azerita"
L["PRESENCE_WORLD_QUEST_ACCEPTED"]                            = "MISSÃO MUNDIAL ACEITA"
L["PRESENCE_QUEST_ACCEPTED"]                                  = "MISSÃO ACEITA"
L["PRESENCE_THE_FATE_OF_THE_HORDE"]                           = "O Destino da Horda"
L["PRESENCE_NEW_QUEST"]                                       = "Nova Missão"
L["PRESENCE_QUEST_UPDATE"]                                    = "ATUALIZAÇÃO DE MISSÃO"
L["PRESENCE_BOAR_PELTS_7_10"]                                 = "Pelagens de Javali: 7/10"
L["PRESENCE_DRAGON_GLYPHS_3_5"]                               = "Glifos de Dragão: 3/5"
L["PRESENCE_TEST_COMMANDS"]                                   = "Comandos de teste do Presence:"
L["PRESENCE_H_DEBUGTYPES_DUMP_NOTIFICATION"]                  = "  /h presence debugtypes - Exibir toggles de notificação e estado de supressão da Blizzard"
L["PRESENCE_PLAYING_DEMO_REEL_NOTIFICATION"]                  = "Presence: reproduzindo demo (todos os tipos de notificação)..."
L["PRESENCE_H_HELP_TEST_CURRENT"]                             = "  /h presence         - Mostrar ajuda + testar zona atual"
L["PRESENCE_H_ZONE_TEST"]                                     = "  /h presence zone     - Testar Mudança de Zona"
L["PRESENCE_H_SUBZONE_TEST"]                                  = "  /h presence subzone  - Testar Mudança de Subzona"
L["PRESENCE_H_DISCOVER_TEST_ZONE"]                            = "  /h presence discover - Testar Descoberta de Zona"
L["PRESENCE_H_LEVEL_TEST"]                                    = "  /h presence level    - Testar Subir de Nível"
L["PRESENCE_H_BOSS_TEST"]                                     = "  /h presence boss     - Testar Emote de Chefe"
L["PRESENCE_H_ACHIEVEMENT_TEST"]                              = "  /h presence ach      - Testar Conquista"
L["PRESENCE_H_ACCEPT_TEST_QUEST"]                             = "  /h presence accept   - Testar Missão Aceita"
L["PRESENCE_H_WORLD_QUEST_ACCEPT_TEST"]                       = "  /h presence wqaccept - Testar Missão Mundial Aceita"
L["PRESENCE_H_SCENARIO_TEST"]                                 = "  /h presence scenario - Testar Início de Cenário"
L["PRESENCE_H_QUEST_TEST_COMPLETE"]                           = "  /h presence quest    - Testar Missão Concluída"
L["PRESENCE_H_WORLD_QUEST_TEST"]                              = "  /h presence wq       - Testar Missão Mundial"
L["PRESENCE_H_QUEST_UPDATE_TEST"]                             = "  /h presence update   - Testar Atualização de Missão"
L["PRESENCE_H_ACHIEVEMENT_PROGRESS_TEST"]                     = "  /h presence achprogress - Testar Progresso de Conquista"
L["PRESENCE_H_DEMO_REEL_TYPES"]                               = "  /h presence all      - Demo (todos os tipos)"
L["PRESENCE_H_DEBUG_DUMP_STATE"]                              = "  /h presence debug    - Mostrar estado no chat"
L["PRESENCE_H_DEBUGLIVE_TOGGLE_LIVE"]                         = "  /h presence debuglive - Alternar painel de debug ao vivo (logar eventos em tempo real)"

-- =====================================================================
-- OptionsData.lua Vista — General
L["VISTA_POSITION_LAYOUT"]                                    = "Position & layout"

-- =====================================================================
L["VISTA_DESC"]                                               = "Minimapa"
L["VISTA_SIZE"]                                               = "Tamanho do minimapa"
L["VISTA_WIDTH_HEIGHT_OF_MINIMAP_PIXELS"]                     = "Largura e altura do minimapa em pixels (100–400)."
L["VISTA_CIRCULAR_MINIMAP"]                                   = "Minimapa circular"
L["VISTA_CIRCULAR_SHAPE"]                                     = "Circular shape"
L["VISTA_A_CIRCULAR_MINIMAP_INSTEAD_OF_SQUARE"]               = "Usar minimapa circular em vez de quadrado."
L["VISTA_LOCK_MINIMAP_POSITION"]                              = "Bloquear posição do minimapa"
L["VISTA_PREVENT_DRAGGING_MINIMAP"]                           = "Impede arrastar o minimapa."
L["VISTA_RESET_MINIMAP_POSITION"]                             = "Redefinir posição do minimapa"
L["VISTA_RESET_MINIMAP_DEFAULT_POSITION_TOP_RIGHT"]           = "Redefine o minimapa para a posição padrão (canto superior direito)."
L["VISTA_RESET_OVERLAY_POSITIONS"]                            = "Reset overlay positions to defaults"
L["VISTA_RESET_OVERLAY_POSITIONS_DESC"]                       = "Clear saved positions for zone text, coordinates, clock, performance and difficulty text, zoom buttons, tracking, calendar, queue, mail, the addon button bar, drawer button, and right-click panel. The minimap frame position is not changed."
L["VISTA_AUTO_ZOOM"]                                          = "Zoom Automático"
L["VISTA_AUTO_ZOOM_DELAY"]                                    = "Atraso do zoom-out automático"
L["VISTA_SECONDS_AFTER_ZOOMING_BEFORE_AUTO_ZOOM"]             = "Segundos após o zoom antes do zoom-out automático. 0 para desativar."

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["VISTA_ZONE_TEXT_HEADER"]                                   = "Texto da Zona"
L["VISTA_ZONE_FONT"]                                          = "Fonte da zona"
L["VISTA_FONT_ZONE_NAME_BELOW_MINIMAP"]                       = "Fonte do nome da zona abaixo do minimapa."
L["VISTA_ZONE_FONT_SIZE"]                                     = "Tamanho da fonte da zona"
L["VISTA_ZONE_TEXT_COLOUR"]                                   = "Cor do texto da zona"
L["VISTA_COLOUR_OF_ZONE_NAME_TEXT"]                           = "Cor do texto do nome da zona."
L["VISTA_COORDINATES_TEXT"]                                   = "Texto de Coordenadas"
L["VISTA_COORDINATES_FONT"]                                   = "Fonte das coordenadas"
L["VISTA_FONT_COORDINATES_TEXT_BELOW_MINIMAP"]                = "Fonte do texto de coordenadas abaixo do minimapa."
L["VISTA_COORDINATES_FONT_SIZE"]                              = "Tamanho da fonte das coordenadas"
L["VISTA_COORDINATES_TEXT_COLOUR"]                            = "Cor do texto das coordenadas"
L["VISTA_COLOUR_OF_COORDINATES_TEXT"]                         = "Cor do texto das coordenadas."
L["VISTA_COORDINATE_PRECISION"]                               = "Precisão das coordenadas"
L["VISTA_NUMBER_OF_DECIMAL_PLACES_SHOWN_X"]                   = "Número de casas decimais para as coordenadas X e Y."
L["VISTA_COORDS_DECIMALS_OFF"]                                = "Sem decimais (ex.: 52, 37)"
L["VISTA_DECIMAL_E_G"]                                        = "1 decimal (ex.: 52.3, 37.1)"
L["VISTA_DECIMALS_E_G"]                                       = "2 decimais (ex.: 52.34, 37.12)"
L["VISTA_TEXT"]                                               = "Texto do Horário"
L["VISTA_FONT"]                                               = "Fonte do horário"
L["VISTA_FONT_TEXT_BELOW_MINIMAP"]                            = "Fonte do texto de horário abaixo do minimapa."
L["VISTA_FONT_SIZE"]                                          = "Tamanho da fonte do horário"
L["VISTA_TEXT_COLOUR"]                                        = "Cor do texto do horário"
L["VISTA_COLOUR_OF_TEXT"]                                     = "Cor do texto do horário."
-- L["VISTA_PERFORMANCE_TEXT"]                                = "Performance Text"
L["VISTA_PERFORMANCE_FONT"]                                   = "Performance font"
-- L["VISTA_FONT_FPS_LATENCY_TEXT_BELOW_MINIMAP"]             = "Font for the FPS and latency text below the minimap."
L["VISTA_PERFORMANCE_FONT_SIZE"]                              = "Performance font size"
L["VISTA_PERFORMANCE_TEXT_COLOUR"]                            = "Performance text colour"
-- L["VISTA_COLOUR_OF_FPS_LATENCY_TEXT"]                      = "Colour of the FPS and latency text."
L["VISTA_DIFFICULTY_TEXT"]                                    = "Texto de Dificuldade"
L["VISTA_DIFFICULTY_TEXT_COLOUR_FALLBACK"]                    = "Cor do texto de dificuldade (padrão)"
L["VISTA_DEFAULT_COLOUR_PER_DIFFICULTY_COLOUR"]               = "Cor padrão quando nenhuma cor por dificuldade está definida."
L["VISTA_DIFFICULTY_FONT"]                                    = "Fonte de dificuldade"
L["VISTA_FONT_INSTANCE_DIFFICULTY_TEXT"]                      = "Fonte do texto de dificuldade de instância."
L["VISTA_DIFFICULTY_FONT_SIZE"]                               = "Tamanho da fonte de dificuldade"
L["VISTA_PER_DIFFICULTY_COLOURS"]                             = "Cores por Dificuldade"
L["VISTA_MYTHIC_COLOUR"]                                      = "Cor Mítica"
L["VISTA_COLOUR_MYTHIC_DIFFICULTY_TEXT"]                      = "Cor do texto de dificuldade Mítica."
L["VISTA_HEROIC_COLOUR"]                                      = "Cor Heroica"
L["VISTA_COLOUR_HEROIC_DIFFICULTY_TEXT"]                      = "Cor do texto de dificuldade Heroica."
L["VISTA_NORMAL_COLOUR"]                                      = "Cor Normal"
L["VISTA_COLOUR_NORMAL_DIFFICULTY_TEXT"]                      = "Cor do texto de dificuldade Normal."
L["VISTA_LFR_COLOUR"]                                         = "Cor LFR"
L["VISTA_COLOUR_LOOKING_RAID_DIFFICULTY_TEXT"]                = "Cor do texto de dificuldade Procurar Raide."

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["VISTA_TEXT_ELEMENTS"]                                      = "Elementos de Texto"
L["VISTA_ZONE_TEXT"]                                          = "Mostrar texto da zona"
L["VISTA_ZONE_NAME_BELOW_MINIMAP"]                            = "Mostra o nome da zona abaixo do minimapa."
L["VISTA_ZONE_TEXT_DISPLAY_MODE"]                             = "Modo de exibição do texto da zona"
L["VISTA_WHAT_ZONE_SUBZONE"]                                  = "O que mostrar: apenas zona, apenas subzona ou ambas."
L["VISTA_SHOW_ZONE"]                                          = "Apenas zona"
L["VISTA_SHOW_SUBZONE"]                                       = "Apenas subzona"
L["VISTA_SHOW_ZONE_AND_SUBZONE"]                              = "Ambas"
L["VISTA_COORDINATES"]                                        = "Mostrar coordenadas"
L["VISTA_PLAYER_COORDINATES_BELOW_MINIMAP"]                   = "Mostra as coordenadas do jogador abaixo do minimapa."
L["VISTA_TIME"]                                               = "Mostrar horário"
L["VISTA_CURRENT_GAME_BELOW_MINIMAP"]                         = "Mostra o horário do jogo abaixo do minimapa."
L["VISTA_HOUR_CLOCK"]                                         = "24-hour clock"
-- L["VISTA_DISPLAY_HOUR_FORMAT_24"]                          = "Display time in 24-hour format (e.g. 14:30 instead of 2:30 PM)."
L["VISTA_LOCAL_TIME"]                                         = "Usar horário local"
L["VISTA_LOCAL_TIME_TIP"]                                     = "Ativado: mostra o horário local do sistema. Desativado: mostra o horário do servidor."
L["VISTA_FPS_LATENCY"]                                        = "Show FPS and latency"
-- L["VISTA_FPS_LATENCY_MS_BELOW_MINIMAP"]                    = "Show FPS and latency (ms) below the minimap."
L["VISTA_MINIMAP_BUTTONS"]                                    = "Botões do Minimapa"
L["VISTA_QUEUE_STATUS_MAIL_INDICATOR_ALWAYS_SHOWN"]           = "O status da fila e o indicador de correio sempre são exibidos quando relevantes."
L["VISTA_TRACKING_BUTTON"]                                    = "Mostrar botão de rastreamento"
L["VISTA_MINIMAP_TRACKING_BUTTON"]                            = "Mostra o botão de rastreamento no minimapa."
L["VISTA_TRACKING_BUTTON_MOUSEOVER"]                          = "Botão de rastreamento somente ao passar o mouse"
L["VISTA_HIDE_TRACKING_BUTTON_UNTIL_YOU_HOVER"]               = "Oculta o botão de rastreamento até passar o mouse sobre o minimapa."
L["VISTA_CALENDAR_BUTTON"]                                    = "Mostrar botão de calendário"
L["VISTA_MINIMAP_CALENDAR_BUTTON"]                            = "Mostra o botão de calendário no minimapa."
L["VISTA_CALENDAR_BUTTON_MOUSEOVER"]                          = "Botão de calendário somente ao passar o mouse"
L["VISTA_HIDE_CALENDAR_BUTTON_UNTIL_YOU_HOVER"]               = "Oculta o botão de calendário até passar o mouse sobre o minimapa."
L["VISTA_ZOOM_BUTTONS"]                                       = "Mostrar botões de zoom"
L["VISTA_ZOOM_BUTTONS_MINIMAP"]                               = "Mostra os botões de zoom + e - no minimapa."
L["VISTA_ZOOM_BUTTONS_MOUSEOVER"]                             = "Botões de zoom somente ao passar o mouse"
L["VISTA_HIDE_ZOOM_BUTTONS_UNTIL_YOU_HOVER"]                  = "Oculta os botões de zoom até passar o mouse sobre o minimapa."

-- =====================================================================
-- OptionsData.lua Vista — Display (Border / Text Positions / Buttons)
-- =====================================================================
L["VISTA_BORDER"]                                             = "Borda"
L["VISTA_BORDER_TIP"]                                         = "Mostra uma borda ao redor do minimapa."
L["VISTA_BORDER_COLOUR"]                                      = "Cor da borda"
L["VISTA_COLOUR_OPACITY_OF_MINIMAP_BORDER"]                   = "Cor (e opacidade) da borda do minimapa."
L["VISTA_BORDER_THICKNESS"]                                   = "Espessura da borda"
L["VISTA_THICKNESS_OF_MINIMAP_BORDER_PIXELS"]                 = "Espessura da borda do minimapa em pixels (1–8)."
-- L["VISTA_CLASS_COLOURS"]                                   = "Class colours"
-- L["VISTA_TINT_VISTA_BORDER_TEXT_COORDS_FPS"]               = "Tint Vista border and text (coords, time, FPS/MS labels) with your class colour. Numbers use the configured colour."
L["VISTA_TEXT_POSITIONS"]                                     = "Posições do Texto"
L["VISTA_DRAG_TEXT_ELEMENTS_REPOSITION_LOCK_PREVEN"]          = "Arraste os elementos de texto para reposicioná-los. Bloqueie para evitar movimentos acidentais."
L["VISTA_LOCK_ZONE_TEXT_POSITION"]                            = "Bloquear posição do texto da zona"
L["VISTA_ZONE_TEXT_CANNOT_DRAGGED"]                           = "Ativado: o texto da zona não pode ser arrastado."
L["VISTA_LOCK_COORDINATES_POSITION"]                          = "Bloquear posição das coordenadas"
L["VISTA_COORDINATES_TEXT_CANNOT_DRAGGED"]                    = "Ativado: o texto das coordenadas não pode ser arrastado."
L["VISTA_LOCK_POSITION"]                                      = "Bloquear posição do horário"
L["VISTA_TEXT_CANNOT_DRAGGED"]                                = "Ativado: o texto do horário não pode ser arrastado."
L["VISTA_PERFORMANCE_TEXT_POSITION"]                          = "Performance text position"
-- L["VISTA_PLACE_FPS_LATENCY_TEXT_ABOVE_BELOW"]              = "Place the FPS/latency text above or below the minimap."
L["VISTA_LOCK_PERFORMANCE_TEXT_POSITION"]                     = "Lock performance text position"
-- L["VISTA_FPS_LATENCY_TEXT_CANNOT_DRAGGED"]                 = "When on, the FPS/latency text cannot be dragged."
L["VISTA_DIFFICULTY_TEXT_POSITION"]                           = "Difficulty text position"
-- L["VISTA_PLACE_DIFFICULTY_TEXT_ABOVE_BELOW"]               = "Place the instance difficulty text above or below the minimap. It is positioned independently of zone text."
L["VISTA_LOCK_DIFFICULTY_TEXT_POSITION"]                      = "Bloquear posição do texto de dificuldade"
L["VISTA_DIFFICULTY_TEXT_CANNOT_DRAGGED"]                     = "Ativado: o texto de dificuldade não pode ser arrastado."
L["VISTA_BUTTON_POSITIONS"]                                   = "Posições dos Botões"
L["VISTA_DRAG_BUTTONS_REPOSITION_LOCK_PREVENT_MOVE"]          = "Arraste os botões para reposicioná-los. Bloqueie para fixar."
L["VISTA_LOCK_ZOOM_BUTTON"]                                   = "Bloquear botão Zoom +"
L["VISTA_PREVENT_DRAGGING_ZOOM_BUTTON"]                       = "Impede arrastar o botão de zoom +."
L["VISTA_LOCK_ZOOM_OUT_BUTTON"]                               = "Bloquear botão Zoom -"
L["VISTA_LOCK_ZOOM_OUT_DRAG"]                                 = "Impede arrastar o botão de zoom -."
L["VISTA_LOCK_TRACKING_BUTTON"]                               = "Bloquear botão de rastreamento"
L["VISTA_PREVENT_DRAGGING_TRACKING_BUTTON"]                   = "Impede arrastar o botão de rastreamento."
L["VISTA_LOCK_CALENDAR_BUTTON"]                               = "Bloquear botão de calendário"
L["VISTA_PREVENT_DRAGGING_CALENDAR_BUTTON"]                   = "Impede arrastar o botão de calendário."
L["VISTA_LOCK_QUEUE_BUTTON"]                                  = "Bloquear botão de fila"
L["VISTA_PREVENT_DRAGGING_QUEUE_STATUS_BUTTON"]               = "Impede arrastar o botão de status da fila."
L["VISTA_LOCK_MAIL_INDICATOR"]                                = "Bloquear indicador de correio"
L["VISTA_PREVENT_DRAGGING_MAIL_ICON"]                         = "Impede arrastar o ícone de correio."
-- L["VISTA_LOCK_CRAFTING_ORDER_INDICATOR"]                   = "Lock Crafting Order Indicator"
-- L["VISTA_PREVENT_DRAGGING_CRAFTING_ORDER_ICON"]            = "Prevent dragging the crafting order icon."
L["VISTA_DISABLE_QUEUE_HANDLING"]                             = "Disable queue handling"
L["VISTA_DISABLE_QUEUE_BUTTON_HANDLING"]                      = "Desativar gerenciamento do botão de fila"
L["VISTA_TURN_QUEUE_BUTTON_ANCHORING_OFF_ADDON_CONFLICT"]     = "Desativa toda ancoragem do botão de fila (use se outro addon o gerencia)."
L["VISTA_BUTTON_SIZES"]                                       = "Tamanhos dos Botões"
L["VISTA_ADJUST_SIZE_OF_MINIMAP_OVERLAY_BUTTONS"]             = "Ajusta o tamanho dos botões sobrepostos ao minimapa."
L["VISTA_TRACKING_BUTTON_SIZE"]                               = "Tamanho do botão de rastreamento"
L["VISTA_SIZE_OF_TRACKING_BUTTON_PIXELS"]                     = "Tamanho do botão de rastreamento (pixels)."
L["VISTA_CALENDAR_BUTTON_SIZE"]                               = "Tamanho do botão de calendário"
L["VISTA_SIZE_OF_CALENDAR_BUTTON_PIXELS"]                     = "Tamanho do botão de calendário (pixels)."
L["VISTA_QUEUE_BUTTON_SIZE"]                                  = "Tamanho do botão de fila"
L["VISTA_SIZE_OF_QUEUE_STATUS_BUTTON_PIXELS"]                 = "Tamanho do botão de status da fila (pixels)."
L["VISTA_ZOOM_BUTTON_SIZE"]                                   = "Tamanho dos botões de zoom"
L["VISTA_SIZE_OF_ZOOM_ZOOM_BUTTONS_PIXELS"]                   = "Tamanho dos botões de zoom + / - (pixels)."
L["VISTA_MAIL_INDICATOR_SIZE"]                                = "Tamanho do indicador de correio"
L["VISTA_SIZE_OF_MAIL_ICON_PIXELS"]                           = "Tamanho do ícone de novo correio (pixels)."
-- L["VISTA_CRAFTING_ORDER_INDICATOR_SIZE"]                   = "Crafting Order Indicator Size"
-- L["VISTA_SIZE_OF_CRAFTING_ORDER_ICON_PIXELS"]              = "Size of the crafting order icon (pixels)."
L["VISTA_ADDON_BUTTON_SIZE"]                                  = "Tamanho dos botões de addon"
L["VISTA_SIZE_OF_COLLECTED_ADDON_MINIMAP_BUTTONS"]            = "Tamanho dos botões de addon coletados no minimapa (pixels)."

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
L["VISTA_COLLECT_HORIZON_MINIMAP"]                            = "Include Horizon minimap icon"
-- L["VISTA_COLLECT_HORIZON_MINIMAP_DESC"]                    = "Put Horizon's own minimap icon in the managed addon bar, right-click panel, or drawer instead of leaving it on the minimap edge."
-- L["VISTA_SORT_BUTTONS_ALPHA"]                              = "Sort Buttons Alphabetically"
-- L["VISTA_SORT_BUTTONS_ALPHA_DESC"]                         = "Sort collected addon minimap buttons alphabetically by name."
-- L["VISTA_ADDON_BUTTONS"]                                   = "Addon Buttons"
L["VISTA_MINIMAP_ADDON_BUTTONS"]                              = "Botões de Addon no Minimapa"
L["VISTA_BUTTON_MANAGEMENT"]                                  = "Gerenciamento de Botões"
L["VISTA_MANAGE_ADDON_MINIMAP_BUTTONS"]                       = "Gerenciar botões de addon no minimapa"
L["VISTA_TAKES_CONTROL_OF_ADDON_MINIMAP"]                     = "Ativado: Vista assume o controle dos botões de addon e os agrupa pelo modo selecionado."
L["VISTA_BUTTON_MODE"]                                        = "Modo dos botões"
L["VISTA_ADDON_BUTTONS_PRESENTED_HOVER_BAR_BELOW"]            = "Como os botões de addon são apresentados: barra ao passar o mouse, painel ao clicar com o botão direito ou botão gaveta flutuante."
L["VISTA_ALWAYS_BAR"]                                         = "Always show bar"
L["VISTA_ALWAYS_MOUSEOVER_BAR_POSITIONING"]                   = "Sempre mostrar barra ao passar o mouse (para posicionamento)"
L["VISTA_KEEP_MOUSEOVER_BAR_VISIBLE_TIMES_YOU"]               = "Mantém a barra visível o tempo todo para você reposicioná-la. Desative quando terminar."
-- L["VISTA_DISABLE_DONE"]                                    = "Disable when done."
L["VISTA_MOUSEOVER_BAR"]                                      = "Barra ao passar o mouse"
L["VISTA_RIGHT_CLICK_PANEL"]                                  = "Painel com botão direito"
L["VISTA_FLOATING_DRAWER"]                                    = "Gaveta flutuante"
L["VISTA_LOCK_DRAWER_BUTTON_POSITION"]                        = "Bloquear posição do botão gaveta"
L["VISTA_PREVENT_DRAGGING_FLOATING_DRAWER_BUTTON"]            = "Impede arrastar o botão da gaveta flutuante."
L["VISTA_LOCK_MOUSEOVER_BAR_POSITION"]                        = "Bloquear posição da barra ao passar o mouse"
L["VISTA_PREVENT_DRAGGING_MOUSEOVER_BUTTON_BAR"]              = "Impede arrastar a barra de botões ao passar o mouse."
L["VISTA_LOCK_RIGHT_CLICK_PANEL_POSITION"]                    = "Bloquear posição do painel de botão direito"
L["VISTA_PREVENT_DRAGGING_RIGHT_CLICK_PANEL"]                 = "Impede arrastar o painel de botão direito."
L["VISTA_BUTTONS_PER_ROW_COLUMN"]                             = "Botões por linha/coluna"
L["VISTA_CONTROLS_MANY_BUTTONS_APPEAR_BEFORE_WRAPPING"]       = "Controla quantos botões aparecem antes de quebrar. Para esquerda/direita são colunas; para cima/baixo são linhas."
L["VISTA_EXPAND_DIRECTION"]                                   = "Direção de expansão"
L["VISTA_DIRECTION_BUTTONS_FILL_ANCHOR_POINT_LEFT"]           = "Direção de preenchimento a partir do ponto de ancoragem. Esquerda/Direita = linhas horizontais. Cima/Baixo = colunas verticais."
L["VISTA_BUTTONS_FILL_RIGHT"]                                 = "Direita"
L["VISTA_BUTTONS_FILL_LEFT"]                                  = "Esquerda"
L["VISTA_BUTTONS_FILL_DOWN"]                                  = "Baixo"
L["VISTA_BUTTONS_FILL_UP"]                                    = "Cima"
L["VISTA_MOUSEOVER_BAR_APPEARANCE"]                           = "Aparência da barra ao passar o mouse"
L["VISTA_BACKGROUND_BORDER_MOUSEOVER_BUTTON_BAR"]             = "Fundo e borda da barra de botões ao passar o mouse."
L["VISTA_BACKDROP_COLOUR"]                                    = "Cor do fundo"
L["VISTA_BACKGROUND_COLOUR_OF_MOUSEOVER_BUTTON_BAR"]          = "Cor de fundo da barra de botões ao passar o mouse (use alfa para controlar a transparência)."
L["VISTA_BAR_BORDER"]                                         = "Mostrar borda da barra"
L["VISTA_A_BORDER_AROUND_MOUSEOVER_BUTTON_BAR"]               = "Mostra uma borda ao redor da barra de botões ao passar o mouse."
L["VISTA_BAR_BORDER_COLOUR"]                                  = "Cor da borda da barra"
L["VISTA_BORDER_COLOUR_OF_MOUSEOVER_BUTTON_BAR"]              = "Cor da borda da barra de botões ao passar o mouse."
L["VISTA_BAR_BACKGROUND_COLOUR"]                              = "Cor de fundo da barra"
L["VISTA_PANEL_BACKGROUND_COLOUR"]                            = "Cor de fundo do painel."
L["VISTA_CLOSE_FADE_TIMING"]                                  = "Tempo de fechamento/esmaecimento"
L["VISTA_MOUSEOVER_BAR_CLOSE_DELAY_SECONDS"]                  = "Barra ao passar o mouse — atraso para fechar (segundos)"
L["VISTA_LONG_SECONDS_BAR_STAYS_VISIBLE_AFTER"]               = "Por quanto tempo (em segundos) a barra permanece visível após o cursor sair. 0 = esmaecimento instantâneo."
L["VISTA_RIGHT_CLICK_PANEL_CLOSE_DELAY_SECONDS"]              = "Painel de clique direito — atraso para fechar (segundos)"
L["VISTA_LONG_SECONDS_PANEL_STAYS_OPEN_AFTER"]                = "Por quanto tempo (em segundos) o painel fica aberto após o cursor sair. 0 = nunca fechar automaticamente (feche clicando com o botão direito novamente)."
L["VISTA_FLOATING_DRAWER_CLOSE_DELAY_SECONDS"]                = "Gaveta flutuante — atraso para fechar (segundos)"
L["VISTA_DRAWER_CLOSE_DELAY"]                                 = "Drawer close delay"
L["VISTA_LONG_SECONDS_DRAWER_PANEL_STAYS_OPEN"]               = "Por quanto tempo (em segundos) o painel da gaveta permanece aberto após clicar fora. 0 = nunca fechar automaticamente (feche apenas clicando no botão da gaveta novamente)."
L["VISTA_MAIL_ICON_BLINK"]                                    = "Piscar ícone de correio"
L["VISTA_MAIL_ICON_PULSES_DRAW_ATTENTION"]                    = "Ativado: o ícone de correio pulsa para chamar atenção. Desativado: permanece com opacidade total."
-- L["VISTA_CRAFTING_ORDER_ICON_PULSE"]                       = "Crafting Order Icon Pulse"
-- L["VISTA_CRAFTING_ORDER_ICON_PULSES_DRAW_ATTENTION"]       = "When on, the crafting order icon pulses to draw attention. When off, it stays at full opacity."
-- L["VISTA_CRAFTING_ORDER_TOOLTIP"]                          = "Personal Crafting Orders"
-- L["VISTA_CRAFTING_ORDER_PENDING_COUNT"]                    = "%d pending"
-- L["VISTA_CRAFTING_ORDER_PROFESSION_LINE"]                  = "  %s: %d"
L["VISTA_PANEL_APPEARANCE"]                                   = "Aparência do Painel"
L["VISTA_COLOURS_DRAWER_RIGHT_CLICK_BUTTON_PANELS"]           = "Cores para os painéis de botões (gaveta e botão direito)."
L["VISTA_PANEL_BG_COLOUR_LABEL"]                              = "Cor de fundo do painel"
L["VISTA_BACKGROUND_COLOUR_OF_ADDON_BUTTON_PANELS"]           = "Cor de fundo dos painéis de botões de addon."
L["VISTA_PANEL_BORDER_COLOUR"]                                = "Cor da borda do painel"
L["VISTA_BORDER_COLOUR_OF_ADDON_BUTTON_PANELS"]               = "Cor da borda dos painéis de botões de addon."
L["VISTA_MANAGED_BUTTONS"]                                    = "Botões gerenciados"
L["VISTA_BUTTON_COMPLETELY_IGNORED"]                          = "Desativado: este botão é completamente ignorado por este addon."
L["VISTA_ADDON_BUTTONS_DETECTED"]                             = "(Nenhum botão de addon detectado ainda)"
L["VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE"]                      = "Botões visíveis (marque para incluir)"
L["VISTA_ADDON_BUTTONS_DETECTED_OPEN_YOUR_MINIMAP"]           = "(Nenhum botão de addon detectado — abra o minimapa primeiro)"

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





























































































































































