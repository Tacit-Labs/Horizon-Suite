if GetLocale() ~= "ruRU" then return end

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
L["OTHER"]                                                    = "Прочее"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["QUEST_TYPES"]                                              = "Типы заданий"
L["ELEMENT_OVERRIDES"]                                        = "Цвета по элементам"
L["PER_CATEGORY"]                                             = "Цвета по категориям"
L["GROUPING_OVERRIDES"]                                       = "Пользовательские цвета"
-- L["SECTION_OVERRIDES"]                                     = "Section Overrides"
L["OTHER_COLOURS"]                                            = "Прочие цвета"

-- =====================================================================
-- OptionsPanel.lua — Colour row labels (collapsible group sub-rows)
-- =====================================================================
L["FOCUS_SECTION"]                                            = "Секция"
L["FOCUS_TITLE"]                                              = "Заголовок"
L["FOCUS_ZONE"]                                               = "Зона"
L["FOCUS_OBJECTIVE"]                                          = "Цель"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["FOCUS_READY_TURN_OVERRIDES_BASE_COLOURS"]                  = "Отдельные цвета для раздела «Готово к сдаче»"
L["FOCUS_READY_TURN_COLOURS_QUESTS"]                          = "Задания, готовые к сдаче, используют свои цвета в этом разделе."
L["FOCUS_CURRENT_ZONE_OVERRIDES_BASE_COLOURS"]                = "Отдельные цвета для раздела «Текущая зона»"
L["FOCUS_CURRENT_ZONE_SECTION_COLOURS"]                       = "Задания текущей зоны используют свои цвета в этом разделе."
L["FOCUS_CURRENT_QUEST_OVERRIDES_BASE_COLOURS"]               = "Отдельные цвета для раздела «Текущий квест»"
L["FOCUS_CURRENT_QUEST_SECTION_COLOURS"]                      = "Задания текущего квеста используют свои цвета в этом разделе."
L["FOCUS_DISTINCT_COLOUR_COMPLETED_OBJECTIVES"]               = "Отдельный цвет для выполненных целей"
L["FOCUS_COMPLETED_OBJECTIVES_COLOURS_CHANGE"]                = "Вкл.: выполненные цели (напр. 1/1) используют цвет ниже. Выкл.: тот же цвет, что и у невыполненных."
L["FOCUS_COMPLETED_OBJECTIVE"]                                = "Выполненная цель"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["FOCUS_RESET"]                                              = "Сбросить"
L["FOCUS_RESET_QUEST_TYPES"]                                  = "Сбросить типы заданий"
L["FOCUS_RESET_OVERRIDES"]                                    = "Сбросить пользовательские цвета"
L["FOCUS_RESET_DEFAULTS"]                                     = "Сбросить все на значения по умолчанию"
L["FOCUS_RESET_TO_DEFAULTS"]                                  = "Сбросить на значения по умолчанию"
L["FOCUS_RESET_DEFAULT"]                                      = "Сбросить на значение по умолчанию"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["FOCUS_SEARCH_SETTINGS"]                                    = "Поиск настроек..."
L["SEARCH_FONTS"]                                             = "Поиск шрифта..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["FOCUS_DRAG_RESIZE"]                                        = "Перетащите для изменения размера"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
-- L["PROFILES"]                                              = "Profiles"
L["MODULES"]                                                  = "Модули"
-- L["MODULE_TOGGLES"]                                        = "Module Toggles"
-- L["MODULE_PREVIEW_DISCLAIMER"]                             = "This module is currently in an early preview (alpha) state. Daily use is not advised due to bugs or unfinished functionality."
-- L["AXIS_MODULE_NAME_DISPLAY"]                              = "Module name style"
-- L["AXIS_MODULE_NAME_DISPLAY_DESC"]                         = "How module names appear in the settings panel navigation and search filter."
-- L["AXIS_MODULE_NAME_HORIZON"]                              = "Horizon"
-- L["AXIS_MODULE_NAME_SUBTITLE"]                             = "Subtitle"
-- L["AXIS_MODULE_NAME_SIMPLE"]                          = "Simple"
-- L["MODULE_RELOAD_HINT"]                                    = "Reload the interface to finish applying module changes."
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
L["DASH_LAYOUT"]                                              = "Расположение"
L["DASH_VISIBILITY"]                                          = "Видимость"
L["DASH_DISPLAY"]                                             = "Отображение"
L["DASH_FEATURES"]                                            = "Функции"
L["DASH_TYPOGRAPHY"]                                          = "Типографика"
L["DASH_APPEARANCE"]                                          = "Внешний вид"
-- L["DASH_CLICK_OPTIONS"]                                    = "Click Options"
L["DASH_COLOURS"]                                             = "Цвета"
L["DASH_ORGANISATION"]                                        = "Организация"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["FOCUS_PANEL_BEHAVIOUR"]                                    = "Поведение панели"
L["FOCUS_DIMENSIONS"]                                         = "Размеры"
L["FOCUS_INSTANCE"]                                           = "Подземелье"
-- L["FOCUS_INSTANCES"]                                       = "Instances"
L["FOCUS_COMBAT"]                                             = "Бой"
L["FOCUS_FILTERING"]                                          = "Фильтры"
L["FOCUS_HEADER"]                                             = "Заголовок"
-- L["FOCUS_SECTIONS_STRUCTURE"]                              = "Sections & structure"
-- L["FOCUS_ENTRY_DETAILS"]                                   = "Entry details"
-- L["FOCUS_PROGRESS_TIMERS"]                                 = "Progress & timers"
-- L["FOCUS_EMPHASIS"]                                        = "Focus emphasis"
L["FOCUS_LIST"]                                               = "Список"
L["FOCUS_SPACING"]                                            = "Интервалы"
L["FOCUS_RARE_BOSSES"]                                        = "Редкие боссы"
L["FOCUS_WORLD_QUESTS"]                                       = "Локальные задания"
L["FOCUS_FLOATING_QUEST_ITEM"]                                = "Плавающая кнопка предмета"
L["FOCUS_MYTHIC"]                                             = "Эпохальный+"
L["FOCUS_ACHIEVEMENTS"]                                       = "Достижения"
-- L["FOCUS_ACHIEVEMENT_PROGRESS_BARS"]                       = "Achievement progress bars"
-- L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_DESC"]                  = "Show a progress bar under tracked achievements that report numeric criteria (including 0/1 and X/Y). Independent of Quest Progress Bars."
-- L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_TIP"]                   = "Uses the same bar colours, texture, and font as other Focus progress bars when those options are visible."
L["FOCUS_ENDEAVORS"]                                          = "Начинания"
L["FOCUS_DECOR"]                                              = "Украшения"
-- L["FOCUS_APPEARANCES"]                                     = "Appearances"
L["FOCUS_SCENARIO_DELVE"]                                     = "Сценарий и Подземелье"
L["FOCUS_FONT"]                                               = "Шрифт"
-- L["FOCUS_FONT_FAMILIES"]                                   = "Font families"
-- L["FOCUS_GLOBAL_FONT_SIZE"]                                = "Global font size"
-- L["FOCUS_FONT_SIZES"]                                      = "Font sizes"
-- L["FOCUS_PER_ELEMENT_FONTS"]                               = "Per-element fonts"
L["FOCUS_TEXT_CASE"]                                          = "Регистр"
L["FOCUS_SHADOW"]                                             = "Тень"
L["FOCUS_PANEL"]                                              = "Панель"
L["FOCUS_HIGHLIGHT"]                                          = "Выделение"
L["FOCUS_COLOUR_MATRIX"]                                      = "Цветовая матрица"
L["FOCUS_ORDER"]                                              = "Порядок"
L["FOCUS_SORT"]                                               = "Сортировка"
L["FOCUS_BEHAVIOUR"]                                          = "Поведение"
L["FOCUS_CONTENT_TYPES"]                                      = "Типы контента"
L["FOCUS_DELVES"]                                             = "Подземелья"
L["FOCUS_DELVES_DUNGEONS"]                                    = "Бездны и Подземелья"
L["FOCUS_DELVE_COMPLETE"]                                     = "Подземелье завершено"
L["FOCUS_INTERACTIONS"]                                       = "Взаимодействия"
-- L["FOCUS_APPEARANCE_TAB_DESC"]                             = "Tracker panel look, fading, and list layout (header, sections, entries, timers, emphasis)."
-- L["FOCUS_CLICK_OPTIONS_TAB_DESC"]                          = "Click profile, per-combo actions, and optional safety toggles for the tracker."
-- L["FOCUS_INTERACTIONS_TAB_DESC"]                           = "Configure quest tracking rules and TomTom integration."
L["FOCUS_TRACKING"]                                           = "Отслеживание"
L["FOCUS_SCENARIO_BAR"]                                       = "Панель сценария"

-- =====================================================================
-- OptionsData.lua Profiles
-- =====================================================================
-- L["AXIS_CURRENT_PROFILE"]                                  = "Current profile"
-- L["AXIS_SELECT_PROFILE_CURRENTLY"]                         = "Select the profile currently in use."
-- L["AXIS_GLOBAL_PROFILE_ACCOUNT_WIDE"]                      = "Use global profile (account-wide)"
-- L["AXIS_CHARACTERS_SAME_PROFILE"]                          = "All characters use the same profile."
-- L["AXIS_ENABLE_PER_SPECIALIZATION_PROFILES"]               = "Enable per specialization profiles"
-- L["AXIS_PICK_DIFFERENT_PROFILES_PER_SPEC"]                 = "Pick different profiles per spec."
-- L["AXIS_SPECIALIZATION"]                                   = "Specialization"
-- L["AXIS_SHARING"]                                          = "Sharing"
-- L["AXIS_IMPORT_PROFILE"]                                   = "Import profile"
-- L["AXIS_IMPORT_STRING"]                                    = "Import string"
-- L["AXIS_EXPORT_PROFILE"]                                   = "Export profile"
-- L["AXIS_SELECT_A_PROFILE_EXPORT"]                          = "Select a profile to export."
-- L["AXIS_EXPORT_STRING"]                                    = "Export string"
-- L["AXIS_COPY_PROFILE"]                                     = "Copy from profile"
-- L["AXIS_SOURCE_PROFILE_COPYING"]                           = "Source profile for copying."
-- L["AXIS_COPY_SELECTED"]                                    = "Copy from selected"
-- L["AXIS_CREATE"]                                           = "Create"
-- L["AXIS_CREATE_PROFILE_DEFAULT_TEMPLATE"]                  = "Create new profile from Default template"
-- L["AXIS_CREATES_A_PROFILE_DEFAULT_SETTINGS"]               = "Creates a new profile with all default settings."
-- L["AXIS_CREATES_A_PROFILE_COPIED_SELECTED_SOURC"]          = "Creates a new profile copied from the selected source profile."
-- L["AXIS_DELETE_PROFILE"]                                   = "Delete profile"
-- L["AXIS_SELECT_A_PROFILE_DELETE_CURRENT_DEFAULT"]          = "Select a profile to delete (current and Default not shown)."
-- L["AXIS_DELETE_SELECTED"]                                  = "Delete selected"
-- L["AXIS_DELETE_SELECTED_PROFILE"]                          = "Delete selected profile"
-- L["AXIS_DELETE"]                                           = "Delete"
-- L["AXIS_DELETES_SELECTED_PROFILE"]                         = "Deletes the selected profile."
-- L["AXIS_GLOBAL_PROFILE"]                                   = "Global profile"
-- L["AXIS_PER_SPEC_PROFILES"]                                = "Per-spec profiles"

-- =====================================================================
-- OptionsData.lua Modules
-- =====================================================================
L["AXIS_ENABLE_FOCUS_MODULE"]                                 = "Включить модуль Фокус"
L["AXIS_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS_R"]             = "Отображает трекер целей для заданий, локальных заданий, редких боссов, достижений и сценариев."
L["AXIS_ENABLE_PRESENCE_MODULE"]                              = "Включить модуль Присутствие"
L["AXIS_CINEMATIC_ZONE_TEXT_NOTIFICATIONS_ZONE_CHANGES"]      = "Кинематографический текст зоны и уведомления (смена зоны, повышение уровня, эмоции боссов, достижения, обновления заданий)."
L["AXIS_ENABLE_CACHE_MODULE"]                                 = "Включить модуль Cache"
L["AXIS_CINEMATIC_LOOT_NOTIFICATIONS_ITEMS_MONEY_CURRENCY"]   = "Кинематографические уведомления о добыче (предметы, золото, валюта, репутация)."
L["AXIS_ENABLE_VISTA_MODULE"]                                 = "Включить модуль Vista"
L["AXIS_CINEMATIC_SQUARE_MINIMAP_ZONE_TEXT_COORDINATES"]      = "Кинематографическая квадратная миникарта с текстом зоны, координатами и коллектором кнопок."
-- L["AXIS_MINIMAP_ZONE_TIME_COLLECTOR"]                      = "Cinematic square minimap with zone text, coordinates, time, and button collector."
L["AXIS_BETA"]                                                = "Бета"
L["AXIS_SCALING"]                                             = "Масштабирование"
L["AXIS_GLOBAL_TOGGLES"]                                      = "Global Toggles"
-- L["AXIS_PATCH_NOTES_SECTION"]                              = "Patch notes"
-- L["AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN"]                   = "Show Patch Notes automatically after an update"
-- L["AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN_DESC"]              = "When on, Axis opens to Patch Notes once after each new addon version. When off, a green dot appears on the Horizon minimap icon until you open Patch Notes."
-- L["AXIS_SUITE_WIDE_CLASS_COLOUR_TINTING_UI"]               = "Dashboard background theme, class colour tinting, and UI scale (global or per module)."
L["AXIS_GLOBAL_UI_SCALE"]                                     = "Глобальный масштаб интерфейса"
L["AXIS_SCALE_SIZES_SPACINGS_FONTS_FACTOR"]                   = "Масштабирует все размеры, интервалы и шрифты (50–200%). Не изменяет ваши настройки."
L["AXIS_PER_MODULE_SCALING"]                                  = "Масштаб по модулям"
L["AXIS_OVERRIDE_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_FO"]         = "Заменяет глобальный масштаб отдельными ползунками для каждого модуля."
-- L["AXIS_OVERRIDES_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_F"]      = "Overrides the global scale with individual sliders for Focus, Presence, Vista, etc."
-- L["AXIS_DOESN_T_CHANGE_YOUR_CONFIGURED_VALUES"]            = "Doesn't change your configured values, only the effective display scale."
L["FOCUS_SCALE"]                                              = "Масштаб Фокуса"
L["AXIS_SCALE_FOCUS_OBJECTIVE_TRACKER"]                       = "Масштаб трекера целей Фокуса (50–200%)."
L["PRESENCE_SCALE"]                                           = "Масштаб Присутствия"
L["AXIS_SCALE_PRESENCE_CINEMATIC_TEXT"]                       = "Масштаб кинематографического текста Присутствия (50–200%)."
L["VISTA_SCALE"]                                              = "Масштаб Vista"
L["AXIS_SCALE_VISTA_MINIMAP_MODULE"]                          = "Масштаб модуля миникарты Vista (50–200%)."
L["INSIGHT_SCALE"]                                            = "Масштаб Insight"
L["AXIS_SCALE_INSIGHT_TOOLTIP_MODULE"]                        = "Масштаб модуля подсказок Insight (50–200%)."
L["CACHE_SCALE"]                                              = "Масштаб Cache"
L["AXIS_SCALE_CACHE_LOOT_TOAST_MODULE"]                       = "Масштаб модуля уведомлений о добыче Cache (50–200%)."
L["AXIS_ENABLE_HORIZON_INSIGHT_MODULE"]                       = "Включить модуль Horizon Insight"
L["AXIS_CINEMATIC_TOOLTIPS_CLASS_COLOURS_SPEC_DISPLAY"]       = "Кинематографические подсказки с цветами классов, специализацией и иконками фракций."
L["AXIS_TOOLTIP_ANCHOR_MODE"]                                 = "Режим привязки подсказок"
L["AXIS_WHERE_TOOLTIPS_APPEAR_FOLLOW_CURSOR_FIXED"]           = "Где отображаются подсказки: следовать за курсором или фиксированная позиция."
L["AXIS_CURSOR"]                                              = "Курсор"
L["AXIS_FIXED"]                                               = "Фиксировано"
-- L["INSIGHT_CURSOR_SIDE"]                                   = "Cursor side"
-- L["INSIGHT_CURSOR_SIDE_DESC"]                              = "Which side of the cursor the tooltip appears on."
-- L["INSIGHT_CURSOR_SIDE_CENTER"]                            = "Center"
-- L["INSIGHT_CURSOR_SIDE_LEFT"]                              = "Left"
-- L["INSIGHT_CURSOR_SIDE_RIGHT"]                             = "Right"
L["AXIS_ANCHOR_MOVE"]                                         = "Показать якорь для перемещения"
-- L["AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITION"]                  = "Click to show or hide the anchor. Drag to set position, right-click to confirm."
L["AXIS_DRAGGABLE_FRAME_FIXED_TOOLTIP_POSITION_DESC"]         = "Показывает перетаскиваемый фрейм для фиксированной позиции. Перетащите и нажмите ПКМ для подтверждения."
L["AXIS_RESET_TOOLTIP_POSITION"]                              = "Сбросить позицию подсказок"
L["AXIS_RESET_FIXED_POSITION_DEFAULT"]                        = "Сбросить фиксированную позицию по умолчанию."
-- L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED"]                        = "Dynamic position for Focus tooltips"
-- L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED_DESC"]                   = "When fixed anchor is on, Focus tracker tooltips still attach to the outer edge of the Horizon panel so they never cover the tracker."
-- L["INSIGHT_CURSOR_OFFSET_X"]                               = "Cursor offset X"
L["INSIGHT_CURSOR_OFFSET_X_DESC"]                             = "Horizontal pixel offset from the default cursor tooltip position (cursor anchor only)."
-- L["INSIGHT_CURSOR_OFFSET_Y"]                               = "Cursor offset Y"
L["INSIGHT_CURSOR_OFFSET_Y_DESC"]                             = "Vertical pixel offset from the default cursor tooltip position (cursor anchor only)."
L["AXIS_TOOLTIP_BACKGROUND_COLOUR"]                           = "Цвет фона подсказок"
L["AXIS_COLOUR_OF_TOOLTIP_BACKGROUND"]                        = "Цвет фона подсказок."
L["AXIS_TOOLTIP_BACKGROUND_OPACITY"]                          = "Прозрачность фона подсказок"
L["AXIS_TOOLTIP_BG_OPACITY_PCT_DESC"]                         = "Прозрачность фона подсказок (0–100%)."
L["AXIS_TOOLTIP_FONT"]                                        = "Шрифт подсказок"
L["AXIS_FONT_FAMILY_TOOLTIP_TEXT"]                            = "Семейство шрифтов для всего текста подсказок."
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
-- L["INSIGHT_ITEM_SECTION_SPACING"]                          = "Blank line before blocks"
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
-- L["AXIS_HONOR_LEVEL"]                                      = "Show honor level"
-- L["AXIS_PLAYER_S_PVP_HONOR_LEVEL_TOOLTIP"]                 = "Show the player's PvP honor level in the tooltip."
-- L["AXIS_PVP_TITLE"]                                        = "Show PvP title"
-- L["AXIS_PLAYER_S_PVP_TITLE_E_G"]                           = "Show the player's PvP title (e.g. Gladiator) in the tooltip."
-- L["AXIS_CHARACTER_TITLE"]                                  = "Character title"
-- L["AXIS_PLAYER_S_SELECTED_TITLE_ACHIEVEMENT_PVP"]          = "Show the player's selected title (achievement or PvP) in the name line."
-- L["AXIS_TITLE_COLOUR"]                                     = "Title colour"
-- L["AXIS_COLOUR_OF_CHARACTER_TITLE_PLAYER_TOOLTIP"]         = "Colour of the character title in the player tooltip name line."
-- L["AXIS_STATUS_BADGES"]                                    = "Show status badges"
-- L["AXIS_INLINE_BADGES_COMBAT_AFK_DND_PVP"]                 = "Show inline badges for combat, AFK, DND, PvP flag, party/raid membership, friends, and whether the player is targeting you."
-- L["AXIS_MOUNT_INFO"]                                       = "Show mount info"
-- L["AXIS_HOVERING_A_MOUNTED_PLAYER_THEIR_MOUNT"]            = "When hovering a mounted player, show their mount name, source, and whether you own it."
-- L["AXIS_BLANK_SEPARATOR"]                                  = "Blank separator"
-- L["AXIS_A_BLANK_LINE_INSTEAD_OF_DASHES"]                   = "Use a blank line instead of dashes between tooltip sections."
L["AXIS_ICONS"]                                               = "Показывать иконки"
-- L["AXIS_CLASS_ICON_STYLE"]                                 = "Class icon style"
L["AXIS_DEFAULT_BLIZZARD_RONDOMEDIA_CLASS_ICONS_TH"]          = "Use Default (Blizzard) or RondoMedia class icons on the class/spec line."
L["AXIS_CUSTOM_CLASS_ICONS_LABEL"]                            = "Custom (addon media)"
L["AXIS_CLASS_ICON_SOURCES_TOOLTIP"]                          = "RondoMedia: https://www.curseforge.com/wow/addons/rondomedia — Custom: place one .tga per class under media/CustomClassIcons/<CLASS>/<class lower>.tga (e.g. WARRIOR/warrior.tga), then /reload."
-- L["AXIS_RONDOMEDIA_CLASS_ICONS_RONDOFERRARI_HTTPS_WWW"]    = "RondoMedia class icons by RondoFerrari — https://www.curseforge.com/wow/addons/rondomedia"
-- L["AXIS_DEFAULT"]                                          = "Default"
L["AXIS_FACTION_SPEC_MOUNT_MYTHIC_ICONS_TOOLTIPS"]            = "Показывать иконки фракции, специализации, маунта и Mythic+ в подсказках."
L["AXIS_GENERAL"]                                             = "Общие"
L["AXIS_POSITION"]                                            = "Позиция"
L["AXIS_RESET_POSITION"]                                      = "Сбросить позицию"
L["AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"]                   = "Сбросить позицию уведомлений о добыче."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["FOCUS_LOCK_POSITION"]                                      = "Заблокировать позицию"
L["FOCUS_PREVENT_DRAGGING_TRACKER"]                           = "Запрещает перетаскивание трекера."
L["FOCUS_GROW_UPWARD"]                                        = "Рост вверх"
L["FOCUS_GROW_HEADER"]                                        = "Заголовок при росте"
L["FOCUS_GROWING_UPWARD_KEEP_HEADER_BOTTOM_TOP"]              = "При росте вверх: заголовок внизу или вверху до свёртывания."
L["FOCUS_HEADER_BOTTOM"]                                      = "Заголовок внизу"
L["FOCUS_HEADER_SLIDES_COLLAPSE"]                             = "Заголовок сдвигается при свёртывании"
L["FOCUS_ANCHOR_BOTTOM_LIST_GROWS_UPWARD"]                    = "Привязка снизу, список растёт вверх."
L["FOCUS_START_COLLAPSED"]                                    = "Свёрнуто по умолчанию"
L["FOCUS_START_HEADER_SHOWN_UNTIL_YOU_EXPAND"]                = "Показывать только заголовок до раскрытия."
-- L["FOCUS_ALIGN_CONTENT_RIGHT"]                             = "Align content right"
-- L["FOCUS_RIGHT_ALIGN_QUEST_TITLES_OBJECTIVES_WITHIN"]      = "Right-align quest titles and objectives within the panel."
L["FOCUS_PANEL_WIDTH"]                                        = "Ширина панели"
L["FOCUS_TRACKER_WIDTH_PIXELS"]                               = "Ширина трекера в пикселях."
L["FOCUS_MAX_CONTENT_HEIGHT"]                                 = "Макс. высота контента"
L["FOCUS_MAX_HEIGHT_OF_SCROLLABLE_LIST_PIXELS"]               = "Максимальная высота прокручиваемого списка (пиксели)."

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["FOCUS_ALWAYS_M_BLOCK"]                                     = "Всегда показывать блок Эпохального+"
L["FOCUS_M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]                = "Показывать блок Эпохального+ при активном ключе."
L["FOCUS_DUNGEON"]                                            = "Показывать в подземелье"
L["FOCUS_TRACKER_PARTY_DUNGEONS"]                             = "Показывать трекер в групповых подземельях."
L["FOCUS_RAID"]                                               = "Показывать в рейде"
L["FOCUS_TRACKER_RAIDS"]                                      = "Показывать трекер в рейдах."
L["FOCUS_BATTLEGROUND"]                                       = "Показывать на поле боя"
L["FOCUS_TRACKER_BATTLEGROUNDS"]                              = "Показывать трекер на полях боя."
L["FOCUS_ARENA"]                                              = "Показывать на арене"
L["FOCUS_TRACKER_ARENAS"]                                     = "Показывать трекер на аренах."
L["FOCUS_HIDE_COMBAT"]                                        = "Скрывать в бою"
L["FOCUS_HIDE_TRACKER_FLOATING_QUEST_ITEM_COMBAT"]            = "Скрывает трекер и плавающую кнопку предмета в бою."
L["FOCUS_COMBAT_VISIBILITY"]                                  = "Видимость в бою"
L["FOCUS_TRACKER_BEHAVES_COMBAT_FADE_REDUC"]                  = "Поведение трекера в бою: показывать, затемнять или скрывать."
L["FOCUS_SHOW"]                                               = "Показывать"
L["FOCUS_FADE"]                                               = "Затемнять"
L["FOCUS_HIDE"]                                               = "Скрывать"
L["FOCUS_COMBAT_FADE_OPACITY"]                                = "Прозрачность в бою (затемнение)"
L["FOCUS_VISIBLE_TRACKER_FADED_COMBAT"]                       = "Видимость трекера при затемнении в бою (0 = невидим). Только при режиме «Затемнять»."
L["FOCUS_MOUSEOVER"]                                          = "Наведение"
L["FOCUS_SHOW_ONLY_MOUSEOVER"]                                = "Показывать только при наведении"
L["FOCUS_FADE_TRACKER_HOVERING_MOVE_MOUSE"]                   = "Затемняет трекер без наведения; наведите курсор для отображения."
L["FOCUS_FADED_OPACITY"]                                      = "Прозрачность при затемнении"
L["FOCUS_VISIBLE_TRACKER_FADED_INVISIBLE"]                    = "Видимость трекера при затемнении (0 = невидим)."
L["FOCUS_QUESTS_CURRENT_ZONE"]                                = "Только задания текущей зоны"
L["FOCUS_HIDE_QUESTS_OUTSIDE_YOUR_CURRENT_ZONE"]              = "Скрывает задания вне текущей зоны."

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["FOCUS_QUEST_COUNT"]                                        = "Показывать количество заданий"
L["FOCUS_QUEST_COUNT_HEADER"]                                 = "Показывает количество заданий в заголовке."
L["FOCUS_HEADER_COUNT_FORMAT"]                                = "Формат счётчика заданий"
L["FOCUS_TRACKED_LOG_LOG_MAX_SLOTS_TRACKED"]                  = "Отслеживаемые/в журнале или в журнале/макс. слотов. Отслеживаемые не включают локальные задания."
L["FOCUS_HEADER_DIVIDER"]                                     = "Показывать разделитель заголовка"
L["FOCUS_LINE_BELOW_HEADER"]                                  = "Показывает линию под заголовком."
L["FOCUS_HEADER_DIVIDER_COLOUR"]                              = "Цвет разделителя заголовка"
L["FOCUS_COLOUR_OF_LINE_BELOW_HEADER"]                        = "Цвет линии под заголовком."
L["FOCUS_SUPER_MINIMAL_MODE"]                                 = "Супер-минимальный режим"
L["FOCUS_HIDE_HEADER_A_PURE_TEXT_LIST"]                       = "Скрывает заголовок для чистого текстового списка."
L["FOCUS_OPTIONS_BUTTON"]                                     = "Options button"
L["FOCUS_OPTIONS_BUTTON_TRACKER_HEADER"]                      = "Показывает кнопку настроек в заголовке трекера."
L["FOCUS_HEADER_COLOUR"]                                      = "Цвет заголовка"
L["FOCUS_COLOUR_OF_OBJECTIVES_HEADER_TEXT"]                   = "Цвет текста заголовка ЦЕЛИ."
L["FOCUS_HEADER_HEIGHT"]                                      = "Высота заголовка"
L["FOCUS_HEIGHT_OF_HEADER_BAR_PIXELS"]                        = "Высота полосы заголовка в пикселях (18–48)."

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["FOCUS_SECTION_HEADERS"]                                    = "Показывать заголовки секций"
L["FOCUS_CATEGORY_LABELS_ABOVE_GROUP"]                        = "Показывает названия категорий над каждой группой."
L["FOCUS_CATEGORY_HEADERS_COLLAPSED"]                         = "Заголовки категорий при свёрнутом виде"
L["FOCUS_KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED_CLICK"]       = "Сохраняет заголовки видимыми при свёрнутом виде; клик для раскрытия."
L["FOCUS_NEARBY_CURRENT_ZONE_GROUP"]                          = "Показывать группу «Текущая зона»"
L["FOCUS_ZONE_QUESTS_A_DEDICATED_CURRENT_ZONE"]               = "Показывает задания зоны в отдельной секции. Выкл.: в обычной категории."
L["FOCUS_ZONE_LABELS"]                                        = "Показывать названия зон"
L["FOCUS_ZONE_NAME_UNDER_QUEST_TITLE"]                        = "Показывает название зоны под каждым заданием."
L["FOCUS_ACTIVE_QUEST_HIGHLIGHT"]                             = "Выделение активного задания"
L["FOCUS_FOCUSED_QUEST_HIGHLIGHTED"]                          = "Способ выделения отслеживаемого задания."
L["FOCUS_QUEST_ITEM_BUTTONS"]                                 = "Показывать кнопки предметов заданий"
L["FOCUS_USABLE_QUEST_ITEM_BUTTON_NEXT_QUEST"]                = "Показывает кнопку используемого предмета рядом с каждым заданием."
-- L["FOCUS_TOOLTIPS_HOVER"]                                  = "Tooltips on hover"
-- L["FOCUS_TOOLTIPS_HOVERING_TRACKER_ENTRIES_ITE"]           = "Show tooltips when hovering over tracker entries, item buttons, and scenario blocks."
-- L["FOCUS_WOWHEAD_LINK_TOOLTIPS"]                           = "Show WoWhead link in tooltips"
-- L["FOCUS_A_TOOLTIP_SHOWN_ADD_A_LINK"]                      = "When a tooltip is shown, add a link to open the quest, achievement, or NPC on WoWhead."
-- L["FOCUS_VIEW_WOWHEAD"]                                    = "View on WoWhead"
L["FOCUS_WOWHEAD_ALT_CLICK_HINT"]                             = "Alt+click row to copy"
-- L["FOCUS_WOWHEAD_HINT_LIST_SEPARATOR"]                     = " · "
-- L["FOCUS_WOWHEAD_TOOLTIP_HINT_FALLBACK"]                   = "Configure in Focus options"
-- L["FOCUS_COPY_LINK"]                                       = "Copy link"
-- L["FOCUS_COPY_URL_BELOW_CTRL_C_PASTE"]                     = "Copy the URL below (Ctrl+C) and paste in your browser."
L["FOCUS_OBJECTIVE_NUMBERS"]                                  = "Показывать номера целей"
-- L["FOCUS_OBJECTIVE_PREFIX"]                                = "Objective prefix"
-- L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS"]               = "Colour objective progress numbers"
L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS_DESC"]             = "Tint X/Y counts: normal colour at 0/n, gold while in progress, green when complete. The slash uses the usual objective colour."
-- L["FOCUS_PREFIX_OBJECTIVE_A_NUMBER_HYPHEN"]                = "Prefix each objective with a number or hyphen."
-- L["FOCUS_NUMBERS"]                                         = "Numbers (1. 2. 3.)"
-- L["FOCUS_HYPHENS"]                                         = "Hyphens (-)"
-- L["FOCUS_AFTER_SECTION_HEADER"]                            = "After section header"
-- L["FOCUS_BEFORE_SECTION_HEADER"]                           = "Before section header"
-- L["FOCUS_BELOW_HEADER"]                                    = "Below header"
-- L["FOCUS_INLINE_BELOW_TITLE"]                              = "Inline below title"
L["FOCUS_PREFIX_OBJECTIVES"]                                  = "Добавляет 1., 2., 3. перед целями."
L["FOCUS_COMPLETED_COUNT"]                                    = "Показывать счётчик выполненных"
L["FOCUS_X_Y_PROGRESS_QUEST_TITLE"]                           = "Показывает прогресс X/Y в названии задания."
L["FOCUS_OBJECTIVE_PROGRESS_BAR"]                             = "Показывать полосу прогресса целей"
L["FOCUS_A_PROGRESS_BAR_UNDER_OBJECTIVES_NUMER"]              = "Показывает полосу под целями с числовым прогрессом (напр. 3/250). Только для одной арифметической цели с требуемым количеством > 1."
L["FOCUS_CATEGORY_COLOUR_PROGRESS_BAR"]                       = "Использовать цвет категории для полосы"
L["FOCUS_PROGRESS_BAR_MATCHES_QUEST_ACHIEVEME"]               = "Вкл.: полоса использует цвет категории. Выкл.: пользовательский цвет ниже."
L["FOCUS_PROGRESS_BAR_TEXTURE"]                               = "Текстура полосы прогресса"
L["FOCUS_PROGRESS_BAR_TYPES"]                                 = "Типы полосы прогресса"
L["FOCUS_TEXTURE_PROGRESS_BAR_FILL"]                          = "Текстура заливки полосы."
L["FOCUS_TEXTURE_PROGRESS_BAR_FILL_SOLID_YOUR"]               = "Текстура заливки. Сплошная использует ваши цвета. Аддоны SharedMedia добавляют опции."
L["FOCUS_PROGRESS_BAR_X_Y_OBJECTIVES_PERCENT"]                = "Показывать полосу для целей X/Y, только процентов или обоих."
L["FOCUS_X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]             = "X/Y: цели как 3/10. Процент: цели как 45%."
L["FOCUS_X_Y"]                                                = "Только X/Y"
L["FOCUS_PERCENT"]                                            = "Только процент"
L["FOCUS_TICK_COMPLETED_OBJECTIVES"]                          = "Галочка для выполненных целей"
L["FOCUS_COMPLETED_OBJECTIVES_A_CHECKMARK_INSTEA"]            = "Вкл.: выполненные цели показывают галочку (✓) вместо зелёного цвета."
L["FOCUS_ENTRY_NUMBERS"]                                      = "Показывать нумерацию заданий"
L["FOCUS_PREFIX_QUEST_TITLES_WITHIN_CATEGORY"]                = "Добавляет 1., 2., 3. перед заданиями в каждой категории."
L["FOCUS_COMPLETED_OBJECTIVES"]                               = "Выполненные цели"
L["FOCUS_MULTI_OBJECTIVE_QUESTS_DISPLAY_OBJECTIVES"]          = "Как отображать выполненные цели в заданиях с несколькими целями (напр. 1/1)."
L["FOCUS_ALL"]                                                = "Показывать все"
L["FOCUS_FADE_COMPLETED"]                                     = "Затемнять выполненные"
L["FOCUS_HIDE_COMPLETED"]                                     = "Скрывать выполненные"
L["FOCUS_ICON_ZONE_AUTO_TRACKING"]                            = "Показывать иконку автоотслеживания в зоне"
L["FOCUS_DISPLAY_AN_ICON_NEXT_AUTO_TRACKED"]                  = "Показывает иконку у автоотслеживаемых локальных и еженедельных/ежедневных заданиях, ещё не в журнале (только в зоне)."
L["FOCUS_AUTO_TRACK_ICON"]                                    = "Иконка автоотслеживания"
L["FOCUS_CHOOSE_WHICH_ICON_DISPLAY_NEXT_AUTO"]                = "Выберите иконку для автоотслеживаемых заданий в зоне."
L["FOCUS_APPEND_WORLD_QUESTS_WEEKLIES_DAILIES"]               = "Добавляет ** к локальным и еженедельным/ежедневным заданиям, ещё не в журнале (только в зоне)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["FOCUS_COMPACT_MODE"]                                       = "Компактный режим"
L["FOCUS_PRESET_SETS_ENTRY_OBJECTIVE_SPACING_P"]              = "Пресет: интервалы заданий и целей 4 и 1 px."
L["FOCUS_SPACING_PRESET"]                                     = "Пресет интервалов"
L["FOCUS_PRESET_ENTRY_OBJECTIVE_SPACING_DEFAULT_P"]           = "Пресет: По умолчанию (8/2 px), Компактный (4/1 px), С отступами (12/3 px) или Пользовательский (ползунки)."
L["FOCUS_COMPACT_VERSION"]                                    = "Компактная версия"
L["FOCUS_SPACED_VERSION"]                                     = "Версия с отступами"
L["FOCUS_SPACING_BETWEEN_QUEST_ENTRIES_PX"]                   = "Интервал между заданиями (px)"
L["FOCUS_VERTICAL_GAP_BETWEEN_QUEST_ENTRIES"]                 = "Вертикальный интервал между заданиями."
L["FOCUS_SPACING_BEFORE_CATEGORY_HEADER_PX"]                  = "Интервал перед заголовком (px)"
L["FOCUS_GAP_BETWEEN_LAST_ENTRY_OF_A"]                        = "Интервал между последним заданием группы и следующей категорией."
L["FOCUS_SPACING_AFTER_CATEGORY_HEADER_PX"]                   = "Интервал после заголовка (px)"
L["FOCUS_GAP_BETWEEN_CATEGORY_LABEL_FIRST_QUEST"]             = "Интервал между заголовком и первым заданием ниже."
L["FOCUS_SPACING_BETWEEN_OBJECTIVES_PX"]                      = "Интервал между целями (px)"
L["FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVE_LINES_WITHIN"]        = "Вертикальный интервал между целями в задании."
L["FOCUS_TITLE_CONTENT"]                                      = "Заголовок к содержимому"
L["FOCUS_VERTICAL_GAP_BETWEEN_QUEST_TITLE_OBJECTIVES"]        = "Вертикальный интервал между названием задания и целями или зоной ниже."
L["FOCUS_SPACING_BELOW_HEADER_PX"]                            = "Интервал под заголовком (px)"
L["FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVES_BAR_QUES"]           = "Вертикальный интервал между полосой целей и списком заданий."
L["FOCUS_RESET_SPACING"]                                      = "Сбросить интервалы"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["FOCUS_SHOW_QUEST_LEVEL"]                                   = "Показывать уровень задания"
L["FOCUS_QUEST_LEVEL_NEXT_TITLE"]                             = "Показывает уровень задания рядом с названием."
L["FOCUS_DIM_FOCUSED_QUESTS"]                                 = "Затемнять неактивные задания"
L["FOCUS_SLIGHTLY_DIM_TITLE_ZONE_OBJECTIVES_SECTION"]         = "Слегка затемняет неактивные названия, зоны, цели и заголовки."
-- L["FOCUS_DIM_UNFOCUSED_ENTRIES"]                           = "Dim unfocused entries"
-- L["FOCUS_CLICK_A_SECTION_HEADER_EXPAND_CATEGORY"]          = "Click a section header to expand that category."

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["UI_SHOW_RARE_BOSSES"]                                      = "Показывать редких боссов"
L["UI_RARE_BOSS_VIGNETTES_LIST"]                              = "Показывает редких боссов в списке."
L["UI_RARE_LOOT"]                                             = "Редкая добыча"
L["UI_TREASURE_ITEM_VIGNETTES_RARE_LOOT"]                     = "Показывает сокровища и предметы в списке редкой добычи."
L["UI_RARE_SOUND_VOLUME"]                                     = "Громкость звука редкой добычи"
L["UI_VOLUME_OF_RARE_ALERT_SOUND"]                            = "Громкость звука оповещения о редкой добыче (50–200%)."
L["UI_BOOST_REDUCE_RARE_ALERT_VOLUME"]                        = "Увеличить или уменьшить громкость. 100% = нормально; 150% = громче."
L["UI_RARE_ADDED_SOUND"]                                      = "Звук при добавлении редкого"
L["UI_PLAY_A_SOUND_A_RARE"]                                   = "Воспроизводит звук при добавлении редкого."
-- L["UI_MINIMAP_PATCH_NOTES_UNREAD_HINT"]                    = "New patch notes — open Axis and choose Patch Notes."

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["FOCUS_ZONE_WORLD_QUESTS"]                                  = "Показывать локальные задания зоны"
L["FOCUS_AUTO_ADD_WORLD_QUESTS_YOUR_CURRENT"]                 = "Автоматически добавляет локальные задания текущей зоны. Выкл.: только отслеживаемые или рядом (по умолчанию Blizzard)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["FOCUS_SHOW_FLOATING_QUEST_ITEM"]                           = "Показывать плавающую кнопку предмета"
L["FOCUS_QUICK_BUTTON_FOCUSED_QUEST_S_USABLE"]                = "Показывает кнопку быстрого использования предмета отслеживаемого задания."
L["FOCUS_LOCK_FLOATING_QUEST_ITEM_POSITION"]                  = "Заблокировать позицию кнопки предмета"
L["FOCUS_PREVENT_DRAGGING_FLOATING_QUEST_ITEM_BUTTON"]        = "Запрещает перетаскивание кнопки предмета."
L["FOCUS_FLOATING_QUEST_ITEM_SOURCE"]                         = "Источник предмета"
L["FOCUS_WHICH_QUEST_S_ITEM_SUPER_TRACKED"]                   = "Чей предмет показывать: сначала отслеживаемое или текущая зона."
L["FOCUS_SUPER_TRACKED_FIRST"]                                = "Сначала отслеживаемое"
L["FOCUS_CURRENT_ZONE_FIRST"]                                 = "Сначала текущая зона"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["FOCUS_MYTHIC_BLOCK"]                                       = "Показывать блок Эпохального+"
L["FOCUS_TIMER_COMPLETION_AFFIXES_MYTHIC_DUNGEONS"]           = "Показывает таймер, % выполнения и модификаторы в Эпохальных+ подземельях."
L["FOCUS_M_BLOCK_POSITION"]                                   = "Позиция блока Эпохального+"
L["FOCUS_POSITION_OF_MYTHIC_BLOCK_RELATIVE_QUEST"]            = "Позиция блока Эпохального+ относительно списка заданий."
L["FOCUS_AFFIX_ICONS"]                                        = "Показывать иконки модификаторов"
L["FOCUS_AFFIX_ICONS_NEXT_MODIFIER_NAMES_M"]                  = "Показывает иконки модификаторов в блоке Эпохального+."
L["FOCUS_AFFIX_DESCRIPTIONS_TOOLTIP"]                         = "Описания модификаторов в подсказке"
L["FOCUS_AFFIX_DESCRIPTIONS_HOVERING_M_BLO"]                  = "Показывает описания модификаторов при наведении на блок."
L["FOCUS_M_COMPLETED_BOSS_DISPLAY"]                           = "Отображение побеждённых боссов"
L["FOCUS_DEFEATED_BOSSES_CHECKMARK_ICON_GREEN"]               = "Как показывать побеждённых боссов: иконка галочки или зелёный цвет."
L["FOCUS_CHECKMARK"]                                          = "Галочка"
L["FOCUS_GREEN_COLOUR"]                                       = "Зелёный цвет"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["PRESENCE_ACHIEVEMENTS"]                                    = "Показывать достижения"
L["FOCUS_TRACKED_ACHIEVEMENTS_LIST"]                          = "Показывает отслеживаемые достижения в списке."
L["FOCUS_COMPLETED_ACHIEVEMENTS"]                             = "Показывать выполненные достижения"
L["FOCUS_INCLUDE_COMPLETED_ACHIEVEMENTS_TRACKER_O"]           = "Включает выполненные достижения. Выкл.: только в процессе."
L["FOCUS_ACHIEVEMENT_ICONS"]                                  = "Показывать иконки достижений"
L["FOCUS_ACHIEVEMENT_S_ICON_NEXT_TITLE_REQUI"]                = "Показывает иконку каждого достижения. Требуется «Показывать иконки типов заданий»."
L["FOCUS_MISSING_REQUIREMENTS"]                               = "Показывать только недостающие критерии"
L["FOCUS_CRITERIA_YOU_HAVEN_T_COMPLETED_TR"]                  = "Показывает только невыполненные критерии. Выкл.: все критерии."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["FOCUS_SHOW_ENDEAVORS"]                                     = "Показывать начинания"
L["FOCUS_TRACKED_ENDEAVORS_PLAYER_HOUSING_LIST"]              = "Показывает отслеживаемые начинания (жилище) в списке."
L["FOCUS_COMPLETED_ENDEAVORS"]                                = "Показывать выполненные начинания"
L["FOCUS_INCLUDE_COMPLETED_ENDEAVORS_TRACKER"]                = "Включает выполненные начинания. Выкл.: только в процессе."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["FOCUS_SHOW_DECOR"]                                         = "Показывать украшения"
L["FOCUS_TRACKED_HOUSING_DECOR_LIST"]                         = "Показывает отслеживаемые украшения жилища в списке."
L["FOCUS_DECOR_ICONS"]                                        = "Показывать иконки украшений"
L["FOCUS_DECOR_ITEM_S_ICON_NEXT_TITLE"]                       = "Показывает иконку каждого украшения. Требуется «Показывать иконки типов заданий»."

-- =====================================================================
-- OptionsData.lua Features — Appearances
-- =====================================================================
-- L["FOCUS_SHOW_APPEARANCES"]                                = "Show appearances"
-- L["FOCUS_TRACKED_TRANSMOG_APPEARANCES_LIST"]               = "Show tracked transmog appearances in the list."
-- L["FOCUS_INCLUDE_COLLECTED_APPEARANCES_TRACKER"]           = "Include collected appearances in the tracker. When off, only appearances you have not yet collected are shown."
-- L["FOCUS_APPEARANCE_ICONS"]                                = "Show appearance icons"
-- L["FOCUS_APPEARANCE_ICON_NEXT_TITLE"]                      = "Show each appearance's icon next to the title. Requires 'Show quest type icons' in Display."
-- L["FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON"]               = "Use transmog list icon"
-- L["FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON_DESC"]          = "Use the in-game Appearances / transmog list icon for every row instead of each appearance's item icon. If that icon cannot be resolved, the item icon is used."
-- L["FOCUS_SHOW_APPEARANCE_WARDROBE"]                        = "Show wardrobe"
-- L["FOCUS_OPEN_APPEARANCES_COLLECTIONS"]                    = "Open Collections"
-- L["FOCUS_UNTRACK_APPEARANCE"]                              = "Untrack appearance"
L["FOCUS_APPEARANCE_HORIZON_CONTROLS_HINT"]                   = "Horizon: Shift-click map, Ctrl-click Collections, Ctrl+Shift-click dressing room. Right-click clears focus or untracks."

-- =====================================================================
-- OptionsData.lua Features — Adventure Guide
-- =====================================================================
L["FOCUS_ADVENTURE_GUIDE"]                                    = "Путеводитель"
L["FOCUS_TRAVELER_S_LOG"]                                     = "Показывать журнал путешественника"
L["FOCUS_TRACKED_TRAVELER_S_LOG_OBJECTIVES_SHIFT"]            = "Показывает отслеживаемые цели журнала (Shift+клик в Путеводителе) в списке."
L["FOCUS_AUTO_REMOVE_COMPLETED_ACTIVITIES"]                   = "Автоудаление выполненных активностей"
L["FOCUS_AUTOMATICALLY_STOP_TRACKING_TRAVELER_S_LOG"]         = "Автоматически прекращает отслеживание выполненных активностей журнала."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["FOCUS_SCENARIO_EVENTS"]                                    = "Показывать события сценария"
L["FOCUS_ACTIVE_SCENARIO_DELVE_ACTIVITIES_DELVES_APP"]        = "Показывает активные сценарии и подземелья. Подземелья в ПОДЗЕМЕЛЬЯ; прочие в СОБЫТИЯ СЦЕНАРИЯ."
L["FOCUS_TRACK_DELVE_DUNGEON_SCENARIO_ACTIVITIES"]            = "Отслеживание активности в подземельях, бездах и сценариях."
L["FOCUS_DELVES_APPEAR_DELVES_SECTION_DUNGEONS_DUNGEON"]      = "Бездны в секции БЕЗДНЫ; подземелья в ПОДЗЕМЕЛЬЕ; прочие в СОБЫТИЯ СЦЕНАРИЯ."
-- L["FOCUS_DELVES_APPEAR_DELVES_SECTION_SCENARIOS"]          = "Delves appear in Delves section; other scenarios in Scenario Events."
-- L["FOCUS_DELVE_AFFIX_NAMES"]                               = "Delve affix names"
-- L["FOCUS_DELVE_DUNGEON"]                                   = "Delve/Dungeon only"
-- L["FOCUS_SCENARIO_DEBUG_LOGGING"]                          = "Scenario debug logging"
-- L["FOCUS_LOG_SCENARIO_API_DATA_CHAT_H"]                    = "Log scenario API data to chat. Use /h debug focus scendebug to toggle."
-- L["FOCUS_PRINTS_C_SCENARIOINFO_CRITERIA_WIDGET_DATA"]      = "Prints C_ScenarioInfo criteria and widget data when in a scenario. Helps diagnose display issues like Abundance 46/300."
L["FOCUS_HIDE_CATEGORIES_DELVE_DUNGEON"]                      = "Скрывать другие категории в подземелье"
L["FOCUS_DELVES_PARTY_DUNGEONS_DELVE_DUNG"]                   = "В подземельях показывать только соответствующую секцию."
L["FOCUS_DELVE_NAME_SECTION_HEADER"]                          = "Использовать название подземелья как заголовок"
L["FOCUS_A_DELVE_DELVE_NAME_TIER_AFFIXES"]                    = "В подземелье: название, уровень и модификаторы в заголовке. Выкл.: блок над списком."
L["FOCUS_AFFIX_NAMES_DELVES"]                                 = "Показывать названия модификаторов в подземельях"
L["FOCUS_SEASON_AFFIX_NAMES_FIRST_DELVE_ENTRY"]               = "Показывает сезонные модификаторы на первой записи. Требуются виджеты Blizzard."
L["FOCUS_CINEMATIC_SCENARIO_BAR"]                             = "Кинематографическая панель сценария"
L["FOCUS_TIMER_PROGRESS_BAR_SCENARIO_ENTRIES"]                = "Показывает таймер и полосу прогресса для сценариев."
L["FOCUS_TIMER"]                                              = "Показывать таймер"
L["FOCUS_COUNTDOWN_TIMER_TIMED_QUESTS_EVENTS_SCEN"]           = "Показывать обратный отсчёт на квестах с таймером, событиях и сценариях. Выкл. — таймеры скрыты."
L["FOCUS_TIMER_SCENARIOS"]                                    = "Timers: scenarios & delves"
L["FOCUS_TIMER_SCENARIOS_DESC"]                               = "Countdown timer for scenario, delve, and dungeon tracker entries."
L["FOCUS_TIMER_WORLD"]                                        = "Timers: world & callings"
L["FOCUS_TIMER_WORLD_DESC"]                                   = "Countdown timer for world quests and callings."
L["FOCUS_TIMER_QUEST_LOG"]                                    = "Timers: quest log (timed)"
L["FOCUS_TIMER_QUEST_LOG_DESC"]                               = "Countdown timer for dailies, weeklies, and other quest log entries with a time limit."
L["FOCUS_TIMER_DISPLAY"]                                      = "Отображение таймера"
L["FOCUS_COLOUR_TIMER_REMAINING"]                             = "Цвет таймера по оставшемуся времени"
L["FOCUS_GREEN_PLENTY_OF_LEFT_YELLOW_RUNNING"]                = "Зелёный — много времени, жёлтый — мало, красный — критично."
L["FOCUS_WHERE_COUNTDOWN_BAR_BELOW_OBJECTIVES"]               = "Где показывать обратный отсчёт: панель под целями или текст рядом с названием задания."
L["FOCUS_BAR_BELOW"]                                          = "Панель внизу"
L["FOCUS_INLINE_BESIDE_TITLE"]                                = "Текст рядом с названием"

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["FOCUS_FONT_FAMILY"]                                        = "Семейство шрифта."
L["FOCUS_TITLE_FONT"]                                         = "Шрифт заголовков"
L["VISTA_ZONE_FONT"]                                          = "Шрифт зоны"
L["FOCUS_OBJECTIVE_FONT"]                                     = "Шрифт целей"
L["FOCUS_SECTION_FONT"]                                       = "Шрифт секций"
L["FOCUS_GLOBAL_FONT"]                                        = "Использовать глобальный шрифт"
L["FOCUS_FONT_FAMILY_QUEST_TITLES"]                           = "Семейство шрифта для названий заданий."
L["FOCUS_FONT_FAMILY_ZONE_LABELS"]                            = "Семейство шрифта для названий зон."
L["FOCUS_FONT_FAMILY_OBJECTIVE_TEXT"]                         = "Семейство шрифта для текста целей."
L["FOCUS_FONT_FAMILY_SECTION_HEADERS"]                        = "Семейство шрифта для заголовков секций."
L["FOCUS_HEADER_SIZE"]                                        = "Размер заголовка"
L["FOCUS_HEADER_FONT_SIZE"]                                   = "Размер шрифта заголовка."
L["FOCUS_TITLE_SIZE"]                                         = "Размер названия"
L["FOCUS_QUEST_TITLE_FONT_SIZE"]                              = "Размер шрифта названий заданий."
L["FOCUS_OBJECTIVE_SIZE"]                                     = "Размер целей"
L["FOCUS_OBJECTIVE_TEXT_FONT_SIZE"]                           = "Размер шрифта текста целей."
L["FOCUS_ZONE_SIZE"]                                          = "Размер зон"
L["FOCUS_ZONE_LABEL_FONT_SIZE"]                               = "Размер шрифта названий зон."
L["FOCUS_SECTION_SIZE"]                                       = "Размер секций"
L["FOCUS_SECTION_HEADER_FONT_SIZE"]                           = "Размер шрифта заголовков секций."
L["FOCUS_PROGRESS_BAR_FONT"]                                  = "Шрифт полосы прогресса"
L["FOCUS_FONT_FAMILY_PROGRESS_BAR_LABEL"]                     = "Семейство шрифта для подписи полосы."
L["FOCUS_PROGRESS_BAR_TEXT_SIZE"]                             = "Размер текста полосы прогресса"
L["FOCUS_FONT_SIZE_PROGRESS_BAR_LABEL_ADJUSTS"]               = "Размер шрифта подписи полосы. Также регулирует высоту. Влияет на цели заданий, прогресс сценариев и таймеры."
L["FOCUS_PROGRESS_BAR_FILL"]                                  = "Заливка полосы прогресса"
L["FOCUS_PROGRESS_BAR_TEXT"]                                  = "Текст полосы прогресса"
L["FOCUS_OUTLINE"]                                            = "Контур"
L["FOCUS_FONT_OUTLINE_STYLE"]                                 = "Стиль контура шрифта."

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["FOCUS_HEADER_TEXT_CASE"]                                   = "Регистр заголовка"
L["FOCUS_DISPLAY_CASE_HEADER"]                                = "Регистр отображения заголовка."
L["FOCUS_SECTION_HEADER_CASE"]                                = "Регистр заголовков секций"
L["FOCUS_DISPLAY_CASE_CATEGORY_LABELS"]                       = "Регистр отображения категорий."
L["FOCUS_QUEST_TITLE_CASE"]                                   = "Регистр названий заданий"
L["FOCUS_DISPLAY_CASE_QUEST_TITLES"]                          = "Регистр отображения названий заданий."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["FOCUS_TEXT_SHADOW"]                                        = "Показывать тень текста"
L["FOCUS_ENABLE_DROP_SHADOW_TEXT"]                            = "Включает тень текста."
L["FOCUS_SHADOW_X"]                                           = "Тень X"
L["FOCUS_HORIZONTAL_SHADOW_OFFSET"]                           = "Горизонтальное смещение тени."
L["FOCUS_SHADOW_Y"]                                           = "Тень Y"
L["FOCUS_VERTICAL_SHADOW_OFFSET"]                             = "Вертикальное смещение тени."
L["FOCUS_SHADOW_ALPHA"]                                       = "Прозрачность тени"
L["FOCUS_SHADOW_OPACITY"]                                     = "Прозрачность тени (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["FOCUS_MYTHIC_TYPOGRAPHY"]                                  = "Типографика Эпохального+"
L["FOCUS_DUNGEON_NAME_SIZE"]                                  = "Размер названия подземелья"
L["FOCUS_FONT_SIZE_DUNGEON_NAME_PX"]                          = "Размер шрифта названия подземелья (8–32 px)."
L["FOCUS_DUNGEON_NAME_COLOUR"]                                = "Цвет названия подземелья"
L["FOCUS_TEXT_COLOUR_DUNGEON_NAME"]                           = "Цвет текста названия подземелья."
L["FOCUS_TIMER_SIZE"]                                         = "Размер таймера"
L["FOCUS_FONT_SIZE_TIMER_PX"]                                 = "Размер шрифта таймера (8–32 px)."
L["FOCUS_TIMER_COLOUR"]                                       = "Цвет таймера"
L["FOCUS_TEXT_COLOUR_TIMER"]                                  = "Цвет таймера (в пределах времени)."
L["FOCUS_TIMER_OVERTIME_COLOUR"]                              = "Цвет таймера (время вышло)"
L["FOCUS_TEXT_COLOUR_TIMER_LIMIT"]                            = "Цвет таймера при превышении времени."
L["FOCUS_PROGRESS_SIZE"]                                      = "Размер прогресса"
L["FOCUS_FONT_SIZE_ENEMY_FORCES_PX"]                          = "Размер шрифта сил противника (8–32 px)."
L["FOCUS_PROGRESS_COLOUR"]                                    = "Цвет прогресса"
L["FOCUS_TEXT_COLOUR_ENEMY_FORCES"]                           = "Цвет текста сил противника."
L["FOCUS_BAR_FILL_COLOUR"]                                    = "Цвет заливки полосы"
L["FOCUS_PROGRESS_BAR_FILL_COLOUR_PROGRESS"]                  = "Цвет заливки полосы (в процессе)."
L["FOCUS_BAR_COMPLETE_COLOUR"]                                = "Цвет завершённой полосы"
L["FOCUS_PROGRESS_BAR_FILL_COLOUR_ENEMY_FORCES"]              = "Цвет заливки при 100% сил противника."
L["FOCUS_AFFIX_SIZE"]                                         = "Размер модификаторов"
L["FOCUS_FONT_SIZE_AFFIXES_PX"]                               = "Размер шрифта модификаторов (8–32 px)."
L["FOCUS_AFFIX_COLOUR"]                                       = "Цвет модификаторов"
L["FOCUS_TEXT_COLOUR_AFFIXES"]                                = "Цвет текста модификаторов."
L["FOCUS_BOSS_SIZE"]                                          = "Размер имён боссов"
L["FOCUS_FONT_SIZE_BOSS_NAMES_PX"]                            = "Размер шрифта имён боссов (8–32 px)."
L["FOCUS_BOSS_COLOUR"]                                        = "Цвет имён боссов"
L["FOCUS_TEXT_COLOUR_BOSS_NAMES"]                             = "Цвет текста имён боссов."
L["FOCUS_RESET_MYTHIC_TYPOGRAPHY"]                            = "Сбросить типографику Эпохального+"

-- =====================================================================
-- OptionsData.lua Appearance
-- =====================================================================
-- L["DASH_FRAME"]                                            = "Frame"
-- L["FOCUS_CLASS_COLOURS_DASHBOARD"]                         = "Class colours - Dashboard"
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
-- L["AXIS_CLASS_COLOURS_DESC"]                               = "Tint dashboard accents, dividers, and highlights with your class colour."
-- L["DASH_THEME"]                                            = "Theme"
-- L["FOCUS_DASHBOARD_BACKGROUND"]                            = "Dashboard background"
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
L["FOCUS_BACKDROP_OPACITY"]                                   = "Прозрачность фона"
L["FOCUS_PANEL_BACKGROUND_OPACITY"]                           = "Прозрачность фона панели (0–1)."
L["FOCUS_BORDER"]                                             = "Показывать границу"
L["FOCUS_BORDER_AROUND_TRACKER"]                              = "Показывает рамку вокруг трекера."
L["FOCUS_SCROLL_INDICATOR"]                                   = "Показывать индикатор прокрутки"
L["FOCUS_A_VISUAL_HINT_LIST_CONTENT_TH"]                      = "Показывает подсказку при наличии скрытого контента."
L["FOCUS_SCROLL_INDICATOR_STYLE"]                             = "Стиль индикатора прокрутки"
L["FOCUS_CHOOSE_BETWEEN_A_FADE_GRADIENT_A"]                   = "Градиент или стрелка для обозначения прокручиваемого контента."
L["FOCUS_ARROW"]                                              = "Стрелка"
L["FOCUS_HIGHLIGHT_ALPHA"]                                    = "Прозрачность выделения"
L["FOCUS_OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]                 = "Прозрачность выделения активного задания (0–1)."
L["FOCUS_BAR_WIDTH"]                                          = "Ширина полосы"
L["FOCUS_WIDTH_OF_BAR_STYLE_HIGHLIGHTS_PX"]                   = "Ширина полосы выделения (2–6 px)."

-- =====================================================================
-- OptionsData.lua Organisation
-- =====================================================================
-- L["FOCUS_ACTIVITY"]                                        = "Activity"
-- L["FOCUS_CONTENT"]                                         = "Content"
-- L["FOCUS_SORTING"]                                         = "Sorting"
-- L["FOCUS_ELEMENTS"]                                        = "Elements"
L["FOCUS_CATEGORY_ORDER"]                                     = "Порядок категорий Фокуса"
-- L["FOCUS_CATEGORY_COLOUR_BAR"]                             = "Category colour for bar"
-- L["FOCUS_CHECKMARK_COMPLETED"]                             = "Checkmark for completed"
-- L["FOCUS_CURRENT_QUEST_CATEGORY"]                          = "Current Quest category"
-- L["FOCUS_CURRENT_QUEST_WINDOW"]                            = "Current Quest window"
-- L["FOCUS_QUESTS_RECENT_PROGRESS_TOP"]                      = "Show quests with recent progress at the top."
-- L["FOCUS_RECENT_QUEST_SECONDS"]                            = "Seconds of recent progress to show in Current Quest (30–120)."
-- L["FOCUS_QUEST_PROGRESSION_SECTION"]                       = "Quests you made progress on in the last minute appear in a dedicated section."
-- L["FOCUS_SHOW_ZONE_EVENTS"]                                = "Events in Zone section"
L["FOCUS_SHOW_ZONE_EVENTS_DESC"]                              = "Show the Events in Zone section for nearby unaccepted quests and zone event quests."
L["FOCUS_SHOW_ZONE_EVENTS_TIP"]                               = "When off, those quests appear in their normal categories instead."
L["FOCUS_CATEGORY_ORDER"]                                     = "Порядок категорий Фокуса"
L["FOCUS_CATEGORIES_REORDER_EXCEPT_DELVES_SCENARIOS"]         = "Перетащите для изменения порядка. ПОДЗЕМЕЛЬЯ и СОБЫТИЯ СЦЕНАРИЯ остаются первыми."
-- L["FOCUS_CATEGORIES_REORDER_EXCEPT_DELVES_SCENARIOS_TIP"]  = "Drag to reorder. Delves and Scenarios stay first."
L["FOCUS_SORT_MODE"]                                          = "Режим сортировки Фокуса"
L["FOCUS_ENTRY_NUMBER_IN_CATEGORY"]                           = "Порядок записей в каждой категории."
L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS"]                         = "Автоотслеживание принятых заданий"
L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS_TIP"]                     = "Автоматически добавляет принятые задания в трекер (кроме локальных)."
L["FOCUS_CTRL_FOCUS_REMOVE"]                                  = "Требовать Ctrl для отслеживания/снятия"
L["FOCUS_CTRL_FOCUS_REMOVE_MOUSECLICK"]                       = "Требует Ctrl для добавления (ЛКМ) и снятия (ПКМ) отслеживания."
-- L["FOCUS_CTRL_FOCUS_UNTRACK"]                              = "Ctrl for focus / untrack"
-- L["FOCUS_CTRL_CLICK_COMPLETE"]                             = "Ctrl to click-complete"
L["FOCUS_CLASSIC_CLICK_BEHAVIOUR"]                            = "Классическое поведение при клике"
-- L["FOCUS_CLASSIC_CLICKS"]                                  = "Classic clicks"
-- === Focus Click Profiles ===
-- L["FOCUS_CLICK_PROFILE"]                                   = "Click profile"
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
-- L["FOCUS_COMBO_LEFT"]                                      = "Left click"
-- L["FOCUS_COMBO_SHIFT_LEFT"]                                = "Shift + Left click"
-- L["FOCUS_COMBO_CTRL_LEFT"]                                 = "Ctrl + Left click"
-- L["FOCUS_COMBO_ALT_LEFT"]                                  = "Alt + Left click"
-- L["FOCUS_COMBO_RIGHT"]                                     = "Right click"
-- L["FOCUS_COMBO_SHIFT_RIGHT"]                               = "Shift + Right click"
-- L["FOCUS_COMBO_CTRL_RIGHT"]                                = "Ctrl + Right click"
-- L["FOCUS_COMBO_ALT_RIGHT"]                                 = "Alt + Right click"
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
L["FOCUS_SHARE_PARTY"]                                        = "Поделиться с группой"
L["FOCUS_ABANDON_QUEST"]                                      = "Отменить квест"
-- L["FOCUS_CONTEXT_FOCUS_QUEST"]                             = "Focus quest"
L["FOCUS_STOP_TRACKING"]                                      = "Прекратить отслеживание"
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
L["FOCUS_CANNOT_SHARE_QUEST"]                                 = "Эту квесту нельзя поделиться."
L["FOCUS_REQUIRE_PARTY_SHARE"]                                = "Чтобы поделиться квестом, нужно быть в группе."
L["FOCUS_LEFT_CLICK_MAP_RIGHT_CLICK_ABANDON"]                 = "Вкл: ЛКМ открывает карту квеста, ПКМ — меню «поделиться/отменить» (стиль Blizzard). Выкл: ЛКМ — следить, ПКМ — снять; Ctrl+ПКМ — поделиться с группой."
L["FOCUS_ANIMATIONS"]                                         = "Focus animations"
L["FOCUS_SLIDE_FADE_QUESTS"]                                  = "Включает анимацию появления и исчезновения заданий."
L["FOCUS_OBJECTIVE_PROGRESS_FLASH"]                           = "Вспышка при выполнении цели"
L["FOCUS_FLASH_OBJECTIVE_COMPLETION"]                         = "Показывает вспышку при выполнении цели."
L["FOCUS_FLASH_INTENSITY"]                                    = "Интенсивность вспышки"
L["FOCUS_OBJECTIVE_PROGRESS_FLASH_VISIBILITY"]                = "Заметность вспышки при выполнении цели."
L["FOCUS_FLASH_COLOUR"]                                       = "Цвет вспышки"
L["FOCUS_FLASH_COLOUR_DESC"]                                  = "Цвет вспышки при выполнении цели."
L["FOCUS_SUBTLE"]                                             = "Лёгкая"
L["FOCUS_MEDIUM"]                                             = "Средняя"
L["FOCUS_STRONG"]                                             = "Сильная"
L["FOCUS_REQUIRE_CTRL_CLICK_COMPLETE"]                        = "Требовать Ctrl для завершения кликом"
L["FOCUS_REQUIRES_CTRL_LEFT_CLICK_COMPLETE_AUTO"]             = "Вкл.: Ctrl+ЛКМ для завершения. Выкл.: ЛКМ (по умолчанию Blizzard). Только для заданий, завершаемых кликом."
L["FOCUS_SUPPRESS_UNTRACKED_UNTIL_RELOAD"]                    = "Скрывать снятые до перезагрузки"
L["FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS"]                   = "Вкл.: снятые с отслеживания скрыты до перезагрузки. Выкл.: появляются при возврате в зону."
L["FOCUS_PERMANENTLY_SUPPRESS_UNTRACKED_QUESTS"]              = "Постоянно скрывать снятые с отслеживания"
L["FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS_DESC"]              = "Вкл.: снятые скрыты постоянно. Приоритет над «Скрывать до перезагрузки». Принятие снимает с чёрного списка."
L["FOCUS_KEEP_CAMPAIGN_CATEGORY"]                             = "Оставлять кампанийные задания в категории"
L["FOCUS_CAMPAIGN_READY_STAY"]                                = "Вкл.: готовые к сдаче кампанийные остаются в категории Кампания."
L["FOCUS_KEEP_IMPORTANT_QUESTS_CATEGORY"]                     = "Оставлять важные задания в категории"
L["FOCUS_IMPORTANT_READY_STAY"]                               = "Вкл.: готовые к сдаче важные остаются в категории Важные."
L["FOCUS_TOMTOM_QUEST_WAYPOINT"]                              = "Точка маршрута TomTom"
L["FOCUS_TOMTOM_QUEST_WAYPOINT_TIP"]                          = "Устанавливать точку маршрута TomTom при фокусировке на задании."
L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_NEXT_QUEST"]            = "Требуется TomTom. Стрелка указывает на следующую цель задания."
L["FOCUS_TOMTOM_RARE_WAYPOINT"]                               = "Точка маршрута TomTom (редкий)"
L["FOCUS_TOMTOM_WAYPOINT_RARE_CLICK"]                         = "Устанавливать точку маршрута TomTom при клике на редкого босса."
L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_RARE"]                  = "Требуется TomTom. Стрелка указывает на местоположение редкого босса."
-- L["FOCUS_FIND_GROUP"]                                      = "Find a Group"
-- L["FOCUS_GROUP_QUEST_SEARCH_CLICK"]                        = "Click to search for a group for this quest."

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
-- L["FOCUS_BLACKLIST"]                                       = "Blacklist"
-- L["FOCUS_BLACKLIST_UNTRACKED"]                             = "Blacklist untracked"
-- L["FOCUS_ENABLE_BLACKLIST_UNTRACKED_BEHAVIOUR_ADD_QUEST"]  = "Enable 'Blacklist untracked' in Behaviour to add quests here."
-- L["FOCUS_HIDDEN_QUESTS"]                                   = "Hidden Quests"
-- L["FOCUS_QUESTS_HIDDEN_RIGHT_CLICK_UNTRACK"]               = "Quests hidden via right-click untrack."
L["FOCUS_BLACKLISTED_QUESTS"]                                 = "Задания в чёрном списке"
L["FOCUS_PERMANENTLY_SUPPRESSED_QUESTS"]                      = "Постоянно скрытые задания"
L["FOCUS_RIGHT_CLICK_UNTRACK_QUESTS_PERMANENTLY_SUPPRESS"]    = "ПКМ снять с отслеживания при включённой опции «Постоянно скрывать» для добавления сюда."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["PRESENCE_QUEST_TYPE_ICONS"]                                = "Показывать иконки типов заданий"
L["PRESENCE_QUEST_TYPE_ICON_FOCUS_TRACKER_QUEST"]             = "Показывает иконки в трекере (принятие/завершение, локальные, обновление)."
L["PRESENCE_QUEST_TYPE_ICONS_TOASTS"]                         = "Показывать иконки типов на уведомлениях"
L["PRESENCE_QUEST_TYPE_ICON_PRESENCE_TOASTS_QUEST"]           = "Показывает иконки типов на уведомлениях Присутствия."
L["PRESENCE_TOAST_ICON_SIZE"]                                 = "Размер иконок на уведомлениях"
L["PRESENCE_QUEST_ICON_SIZE_PRESENCE_TOASTS_PX"]              = "Размер иконок заданий на уведомлениях (16–36 px). По умолчанию 24."
L["PRESENCE_HIDE_QUEST_UPDATE_TITLE"]                         = "Скрывать заголовок в уведомлениях о прогрессе"
L["PRESENCE_OBJECTIVE_LINE_QUEST_PROGRESS_TOAST"]             = "Показывать только строку цели (напр., 7/10 Шкур кабана) без названия задания и заголовка."
L["PRESENCE_SHOW_DISCOVERY_LINE"]                             = "Показывать строку «Обнаружено»"
-- L["PRESENCE_DISCOVERY_LINE"]                               = "Discovery line"
L["PRESENCE_SHOW_DISCOVERED"]                                 = "Показывает «Обнаружено» под зоной/подзоной при входе в новую область."
L["PRESENCE_FRAME_VERTICAL_POSITION"]                         = "Вертикальная позиция фрейма"
L["PRESENCE_VERTICAL_OFFSET_OF_PRESENCE_FRAME_CENTER"]        = "Вертикальное смещение фрейма от центра (-300 до 0)."
L["PRESENCE_FRAME_SCALE"]                                     = "Масштаб фрейма"
L["PRESENCE_FRAME_SCALE_TIP"]                                 = "Масштаб фрейма Присутствия (0.5–2)."
L["PRESENCE_BOSS_EMOTE_COLOUR"]                               = "Цвет эмоций боссов"
L["PRESENCE_COLOUR_RAID_DUNGEON_BOSS_EMOTE"]                  = "Цвет текста эмоций боссов в рейдах и подземельях."
L["PRESENCE_DISCOVERY_LINE_COLOUR"]                           = "Цвет строки «Обнаружено»"
L["PRESENCE_COLOUR_OF_DISCOVERED_LINE_UNDER_ZONE_TIP"]        = "Цвет строки «Обнаружено» под текстом зоны."
L["PRESENCE_NOTIFICATION_TYPES"]                              = "Типы уведомлений"
-- L["PRESENCE_NOTIFICATIONS"]                                = "Notifications"
-- L["PRESENCE_NOTIFICATION_ACHIEVEMENT_CRITERIA_UPDATE"]     = "Show notification when achievement criteria update (tracked achievements always; others when Blizzard provides the achievement ID)."
L["PRESENCE_ZONE_ENTRY"]                                      = "Показывать вход в зону"
L["PRESENCE_ZONE_CHANGE_ENTERING_A_AREA"]                     = "Показывает уведомление при входе в новую зону."
L["PRESENCE_SUBZONE_CHANGES"]                                 = "Показывать смену подзон"
L["PRESENCE_SUBZONE_CHANGE_MOVING_WITHIN_SAME_ZONE"]          = "Показывает уведомление при перемещении между подзонами в той же зоне."
L["PRESENCE_HIDE_ZONE_NAME_SUBZONE_CHANGES"]                  = "Скрывать название зоны при смене подзоны"
L["PRESENCE_MOVING_BETWEEN_SUBZONES_WITHIN_SAME_ZONE"]        = "При переходе между подзонами показывать только подзону. Название зоны при входе в новую зону."
-- L["PRESENCE_SUPPRESS_DELVE"]                               = "Suppress in Delve"
-- L["PRESENCE_SUPPRESS_SCENARIO_PROGRESS_NOTIFICATIONS_DELVES"]= "Suppress scenario progress notifications in Delves."
-- L["PRESENCE_HIDE_DELVE_OBJECTIVE_UPDATE"]                  = "When on, hides objective update popups while in a Delve. Zone entry and completion toasts still show."
L["PRESENCE_SUPPRESS_ZONE_CHANGES_MYTHIC"]                    = "Скрывать смену зон в Эпохальном+"
L["PRESENCE_MYTHICPLUS_SHOW_BOSS_EMOTES_ACHIEVEMENTS_LEVELS"]   = "В Эпохальном+: только эмоции боссов, достижения и повышение уровня."
L["PRESENCE_LEVEL"]                                           = "Показывать повышение уровня"
L["PRESENCE_LEVEL_NOTIFICATION"]                              = "Показывает уведомление о повышении уровня."
L["PRESENCE_BOSS_EMOTES"]                                     = "Показывать эмоции боссов"
L["PRESENCE_RAID_DUNGEON_BOSS_EMOTE_NOTIFICATIONS"]           = "Показывает уведомления об эмоциях боссов в рейдах и подземельях."
L["PRESENCE_ACHIEVEMENTS"]                                    = "Показывать достижения"
L["PRESENCE_ACHIEVEMENT_EARNED_NOTIFICATIONS"]                = "Показывает уведомления о полученных достижениях."
L["PRESENCE_ACHIEVEMENT_PROGRESS"]                            = "Прогресс достижений"
L["PRESENCE_SHOW_ACHIEVEMENT_EARNED"]                         = "Достижение получено"
L["PRESENCE_SHOW_QUEST_ACCEPTED"]                             = "Задание принято"
L["PRESENCE_SHOW_WORLD_QUEST_ACCEPTED"]                       = "Локальное задание принято"
L["PRESENCE_SHOW_SCENARIO_COMPLETE"]                          = "Сценарий завершён"
L["PRESENCE_SHOW_RARE_DEFEATED"]                              = "Редкий побеждён"
L["PRESENCE_NOTIFICATION_TRACKED_ACHIEVEMENT_CRITERIA"]       = "Показывает уведомление при обновлении критериев отслеживаемого достижения."
L["PRESENCE_QUEST_ACCEPT"]                                    = "Показывать принятие задания"
L["PRESENCE_NOTIFICATION_ACCEPTING_A_QUEST"]                  = "Показывает уведомление при принятии задания."
L["PRESENCE_WORLD_QUEST_ACCEPT"]                              = "Показывать принятие локального задания"
L["PRESENCE_NOTIFICATION_ACCEPTING_A_WORLD_QUEST"]            = "Показывает уведомление при принятии локального задания."
L["PRESENCE_SHOW_QUEST_COMPLETE"]                             = "Показывать завершение задания"
L["PRESENCE_NOTIFICATION_COMPLETING_A_QUEST"]                 = "Показывает уведомление при завершении задания."
L["PRESENCE_SHOW_WORLD_QUEST_COMPLETE"]                       = "Показывать завершение локального задания"
L["PRESENCE_NOTIFICATION_COMPLETING_A_WORLD_QUEST"]           = "Показывает уведомление при завершении локального задания."
L["PRESENCE_QUEST_PROGRESS"]                                  = "Показывать прогресс задания"
L["PRESENCE_NOTIFICATION_QUEST_OBJECTIVES_UPDATE"]            = "Показывает уведомление при обновлении целей задания."
L["PRESENCE_OBJECTIVE"]                                       = "Только цель"
L["PRESENCE_QUEST_PROGRESS_HIDE_TITLE"]                       = "Показывать только строку цели на уведомлениях прогресса, скрывая заголовок «Обновление задания»."
L["PRESENCE_SCENARIO_START"]                                  = "Показывать начало сценария"
L["PRESENCE_NOTIFICATION_ENTERING_A_SCENARIO_DELVE"]          = "Показывает уведомление при входе в сценарий или Глубины."
L["PRESENCE_SCENARIO_PROGRESS"]                               = "Показывать прогресс сценария"
L["PRESENCE_NOTIFICATION_SCENARIO_DELVE_OBJECTIVES"]          = "Показывает уведомление при обновлении целей сценария или Глубин."
L["PRESENCE_ANIMATION"]                                       = "Анимация"
L["PRESENCE_ENABLE_ANIMATIONS"]                               = "Включить анимации"
L["PRESENCE_ENABLE_ENTRANCE_EXIT_ANIMATIONS_PRESENCE"]        = "Включает анимации появления и исчезновения уведомлений."
L["PRESENCE_ENTRANCE_DURATION"]                               = "Длительность появления"
L["PRESENCE_DURATION_OF_ENTRANCE_ANIMATION_SECONDS"]          = "Длительность анимации появления в секундах (0.2–1.5)."
L["PRESENCE_EXIT_DURATION"]                                   = "Длительность исчезновения"
L["PRESENCE_DURATION_OF_EXIT_ANIMATION_SECONDS"]              = "Длительность анимации исчезновения в секундах (0.2–1.5)."
L["PRESENCE_HOLD_DURATION_SCALE"]                             = "Множитель времени показа"
L["PRESENCE_MULTIPLIER_LONG_NOTIFICATION_STAY"]               = "Множитель времени показа уведомлений (0.5–2)."
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
L["DASH_TYPOGRAPHY"]                                          = "Типографика"
L["PRESENCE_MAIN_TITLE_FONT"]                                 = "Шрифт основного заголовка"
L["PRESENCE_FONT_FAMILY_MAIN_TITLE"]                          = "Семейство шрифтов для основного заголовка."
L["PRESENCE_SUBTITLE_FONT"]                                   = "Шрифт подзаголовка"
L["PRESENCE_FONT_FAMILY_SUBTITLE"]                            = "Семейство шрифтов для подзаголовка."
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
L["FOCUS_OUTLINE_NONE"]                                       = "Нет"
L["FOCUS_THICK_OUTLINE"]                                      = "Толстый контур"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["FOCUS_HIGHLIGHT_BAR_LEFT_EDGE"]                            = "Полоса (слева)"
L["FOCUS_HIGHLIGHT_BAR_RIGHT_EDGE"]                           = "Полоса (справа)"
L["FOCUS_HIGHLIGHT_BAR_TOP_EDGE"]                             = "Полоса (сверху)"
L["FOCUS_HIGHLIGHT_BAR_BOTTOM_EDGE"]                          = "Полоса (снизу)"
L["FOCUS_HIGHLIGHT_OUTLINE_ONLY"]                             = "Только контур"
L["FOCUS_HIGHLIGHT_SOFT_GLOW"]                                = "Мягкое свечение"
L["FOCUS_HIGHLIGHT_DUAL_EDGE_BARS"]                           = "Двойные полосы"
L["FOCUS_HIGHLIGHT_PILL_LEFT_ACCENT"]                         = "Акцент слева"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["FOCUS_MYTHICPLUS_POSITION_TOP"]                            = "Сверху"
L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"]                         = "Снизу"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["VISTA_LOCATION_POSITION"]                                  = "Позиция названия зоны"
L["VISTA_PLACE_ZONE_NAME_ABOVE_BELOW_MINIMAP"]                = "Размещение названия зоны над или под миникартой."
L["VISTA_COORDINATES_POSITION"]                               = "Позиция координат"
L["VISTA_PLACE_COORDINATES_ABOVE_BELOW_MINIMAP"]              = "Размещение координат над или под миникартой."
L["VISTA_CLOCK_POSITION"]                                     = "Позиция часов"
L["VISTA_PLACE_CLOCK_ABOVE_BELOW_MINIMAP"]                    = "Размещение часов над или под миникартой."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["FOCUS_TEXT_LOWER_CASE"]                                    = "Строчные"
L["FOCUS_TEXT_UPPER_CASE"]                                    = "Заглавные"
L["FOCUS_TEXT_PROPER_CASE"]                                   = "С заглавной буквы"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["FOCUS_TRACKED_LOG"]                                        = "Отслеживаемые / в журнале"
L["FOCUS_LOG_MAX_SLOTS"]                                      = "В журнале / макс. слотов"

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["FOCUS_ALPHABETICAL"]                                       = "По алфавиту"
L["FOCUS_QUEST_TYPE"]                                         = "По типу задания"
L["FOCUS_QUEST_LEVEL"]                                        = "По уровню задания"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["FOCUS_CUSTOM"]                                             = "Пользовательский"
L["FOCUS_ORDER"]                                              = "Порядок"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["UI_DUNGEON"]                                               = "ПОДЗЕМЕЛЬЕ"
L["UI_RAID"]                                                  = "РЕЙД"
L["UI_DELVES"]                                                = "ПОДЗЕМЕЛЬЯ"
L["UI_SCENARIO_EVENTS"]                                       = "СОБЫТИЯ СЦЕНАРИЯ"
-- L["UI_STAGE"]                                              = "Stage"
-- L["UI_STAGE_X_X"]                                          = "Stage %d: %s"
L["UI_AVAILABLE_IN_ZONE"]                                     = "ДОСТУПНО В ЗОНЕ"
L["UI_EVENTS_IN_ZONE"]                                        = "События в зоне"
L["UI_CURRENT_EVENT"]                                         = "Текущее событие"
L["UI_CURRENT_QUEST"]                                         = "ТЕКУЩИЙ КВЕСТ"
L["UI_CURRENT_ZONE"]                                          = "ТЕКУЩАЯ ЗОНА"
L["UI_CAMPAIGN"]                                              = "КАМПАНИЯ"
L["UI_IMPORTANT"]                                             = "ВАЖНЫЕ"
L["UI_LEGENDARY"]                                             = "ЛЕГЕНДАРНЫЕ"
L["UI_WORLD_QUESTS"]                                          = "ЛОКАЛЬНЫЕ ЗАДАНИЯ"
L["UI_WEEKLY_QUESTS"]                                         = "ЕЖЕНЕДЕЛЬНЫЕ"
L["UI_PREY"]                                                  = "Добыча"
L["UI_ABUNDANCE"]                                             = "Изобилие"
L["UI_ABUNDANCE_BAG"]                                         = "Сумка изобилия"
L["UI_ABUNDANCE_HELD"]                                        = "удержанное изобилие"
L["UI_DAILY_QUESTS"]                                          = "ЕЖЕДНЕВНЫЕ"
L["UI_RARE_BOSSES"]                                           = "РЕДКИЕ БОССЫ"
L["UI_ACHIEVEMENTS"]                                          = "ДОСТИЖЕНИЯ"
L["UI_ENDEAVORS"]                                             = "НАЧИНАНИЯ"
L["UI_DECOR"]                                                 = "УКРАШЕНИЯ"
-- L["UI_RECIPES"]                                            = "Recipes"
-- L["UI_ADVENTURE_GUIDE"]                                    = "Adventure Guide"
-- L["UI_APPEARANCES"]                                        = "Appearances"
L["UI_QUESTS"]                                                = "ЗАДАНИЯ"
L["UI_READY_TO_TURN_IN"]                                      = "ГОТОВО К СДАЧЕ"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["PRESENCE_OBJECTIVES"]                                      = "ЦЕЛИ"
L["PRESENCE_OPTIONS"]                                         = "Настройки"
L["PRESENCE_OPEN_HORIZON_SUITE"]                              = "Открыть Horizon Suite"
L["PRESENCE_OPEN_FULL_HORIZON_SUITE_OPTIONS"]                 = "Открывает полную панель настроек Horizon Suite для настройки Focus, Presence, Vista и других модулей."
-- L["PRESENCE_MINIMAP_SECTION"]                              = "Minimap icon"
L["PRESENCE_SHOW_MINIMAP_ICON"]                               = "Показать значок на миникарте"
L["PRESENCE_A_CLICKABLE_ICON_MINIMAP_OPENS"]                  = "Показывает кликабельный значок на миникарте, открывающий панель настроек."
-- L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER"]      = "Fade until minimap hover"
-- L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER_DESC"] = "When on, the icon stays faded until you move the cursor over the minimap. When off, it stays fully visible."
-- L["PRESENCE_LOCK_MINIMAP_BUTTON_POSITION"]                 = "Lock minimap button position"
-- L["PRESENCE_PREVENT_DRAGGING_HORIZON_MINIMAP_BUTTON"]      = "Prevent dragging the Horizon minimap button."
-- L["PRESENCE_RESET_MINIMAP_BUTTON_POSITION"]                = "Reset minimap button position"
-- L["PRESENCE_RESET_MINIMAP_BUTTON_DEFAULT_POSITION"]        = "Reset the minimap button to the default position (bottom-left)."
-- L["PRESENCE_DRAG_TO_MOVE_WHEN_UNLOCKED"]                   = "Drag to move (when unlocked)."
-- L["PRESENCE_LOCKED"]                                       = "Locked"
L["PRESENCE_DISCOVERED"]                                      = "Обнаружено"
L["PRESENCE_REFRESH"]                                         = "Обновить"
L["PRESENCE_BEST_EFFORT_UNACCEPTED_QUESTS_EXPO"]              = "Поиск приблизительный. Некоторые непринятые задания не отображаются до взаимодействия с НИП или условий фазы."
L["PRESENCE_UNACCEPTED_QUESTS_X_MAP_X"]                       = "Непринятые задания - %s (карта %s) - %d совпадений"
L["PRESENCE_LEVEL_UP"]                                        = "ПОВЫШЕНИЕ УРОВНЯ"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_80"]                       = "Вы достигли 80 уровня"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_X"]                        = "Вы достигли %s уровня"
L["PRESENCE_ACHIEVEMENT_EARNED"]                              = "ДОСТИЖЕНИЕ ПОЛУЧЕНО"
L["PRESENCE_EXPLORING_THE_MIDNIGHT_ISLES"]                    = "Исследование Полуночных островов"
L["PRESENCE_EXPLORING_KHAZ_ALGAR"]                            = "Исследование Каз Алгара"
L["PRESENCE_QUEST_COMPLETE"]                                  = "ЗАДАНИЕ ВЫПОЛНЕНО"
L["PRESENCE_OBJECTIVE_SECURED"]                               = "Цель достигнута"
L["PRESENCE_AIDING_THE_ACCORD"]                               = "Помощь Согласию"
L["PRESENCE_WORLD_QUEST"]                                     = "ЛОКАЛЬНОЕ ЗАДАНИЕ"
L["PRESENCE_WORLD_QUEST_COMPLETE"]                            = "ЛОКАЛЬНОЕ ЗАДАНИЕ ВЫПОЛНЕНО"
L["PRESENCE_AZERITE_MINING"]                                  = "Добыча азерита"
L["PRESENCE_WORLD_QUEST_ACCEPTED"]                            = "ЛОКАЛЬНОЕ ЗАДАНИЕ ПРИНЯТО"
L["PRESENCE_QUEST_ACCEPTED"]                                  = "ЗАДАНИЕ ПРИНЯТО"
L["PRESENCE_THE_FATE_OF_THE_HORDE"]                           = "Судьба Орды"
L["PRESENCE_NEW_QUEST"]                                       = "Новое задание"
L["PRESENCE_QUEST_UPDATE"]                                    = "ОБНОВЛЕНИЕ ЗАДАНИЯ"
L["PRESENCE_BOAR_PELTS_7_10"]                                 = "Шкуры кабана: 7/10"
L["PRESENCE_DRAGON_GLYPHS_3_5"]                               = "Драконьи руны: 3/5"
L["PRESENCE_TEST_COMMANDS"]                                   = "Тестовые команды Присутствия:"
-- L["PRESENCE_H_DEBUGTYPES_DUMP_NOTIFICATION"]               = "  /h presence debugtypes - Dump notification toggles and Blizzard suppression state"
-- L["PRESENCE_PLAYING_DEMO_REEL_NOTIFICATION"]               = "Presence: Playing demo reel (all notification types)..."
L["PRESENCE_H_HELP_TEST_CURRENT"]                             = "  /h presence         - Справка + тест текущей зоны"
L["PRESENCE_H_ZONE_TEST"]                                     = "  /h presence zone     - Тест смены зоны"
L["PRESENCE_H_SUBZONE_TEST"]                                  = "  /h presence subzone  - Тест смены подзоны"
L["PRESENCE_H_DISCOVER_TEST_ZONE"]                            = "  /h presence discover - Тест обнаружения зоны"
L["PRESENCE_H_LEVEL_TEST"]                                    = "  /h presence level    - Тест повышения уровня"
L["PRESENCE_H_BOSS_TEST"]                                     = "  /h presence boss     - Тест эмоции босса"
L["PRESENCE_H_ACHIEVEMENT_TEST"]                              = "  /h presence ach      - Тест достижения"
L["PRESENCE_H_ACCEPT_TEST_QUEST"]                             = "  /h presence accept   - Тест принятия задания"
L["PRESENCE_H_WORLD_QUEST_ACCEPT_TEST"]                       = "  /h presence wqaccept - Тест принятия локального задания"
L["PRESENCE_H_SCENARIO_TEST"]                                 = "  /h presence scenario - Тест начала сценария"
L["PRESENCE_H_QUEST_TEST_COMPLETE"]                           = "  /h presence quest    - Тест завершения задания"
L["PRESENCE_H_WORLD_QUEST_TEST"]                              = "  /h presence wq       - Тест локального задания"
L["PRESENCE_H_QUEST_UPDATE_TEST"]                             = "  /h presence update   - Тест обновления задания"
L["PRESENCE_H_ACHIEVEMENT_PROGRESS_TEST"]                     = "  /h presence achprogress - Тест прогресса достижения"
L["PRESENCE_H_DEMO_REEL_TYPES"]                               = "  /h presence all      - Демо (все типы)"
L["PRESENCE_H_DEBUG_DUMP_STATE"]                              = "  /h presence debug    - Вывод состояния в чат"
L["PRESENCE_H_DEBUGLIVE_TOGGLE_LIVE"]                         = "  /h presence debuglive - Вкл/выкл панель отладки (логирование событий)"

-- =====================================================================
-- OptionsData.lua Vista — General
-- L["VISTA_POSITION_LAYOUT"]                                 = "Position & layout"

-- =====================================================================
L["VISTA_DESC"]                                               = "Миникарта"
L["VISTA_SIZE"]                                               = "Размер миникарты"
L["VISTA_WIDTH_HEIGHT_OF_MINIMAP_PIXELS"]                     = "Ширина и высота миникарты в пикселях (100–400)."
L["VISTA_CIRCULAR_MINIMAP"]                                   = "Круглая миникарта"
-- L["VISTA_CIRCULAR_SHAPE"]                                  = "Circular shape"
L["VISTA_A_CIRCULAR_MINIMAP_INSTEAD_OF_SQUARE"]               = "Использовать круглую миникарту вместо квадратной."
L["VISTA_LOCK_MINIMAP_POSITION"]                              = "Заблокировать позицию миникарты"
L["VISTA_PREVENT_DRAGGING_MINIMAP"]                           = "Запретить перетаскивание миникарты."
L["VISTA_RESET_MINIMAP_POSITION"]                             = "Сбросить позицию миникарты"
L["VISTA_RESET_MINIMAP_DEFAULT_POSITION_TOP_RIGHT"]           = "Вернуть миникарту на стандартное место (правый верхний угол)."
-- L["VISTA_RESET_OVERLAY_POSITIONS"]                         = "Reset overlay positions to defaults"
L["VISTA_RESET_OVERLAY_POSITIONS_DESC"]                       = "Clear saved positions for zone text, coordinates, clock, performance and difficulty text, zoom buttons, tracking, calendar, queue, mail, the addon button bar, drawer button, and right-click panel. The minimap frame position is not changed."
L["VISTA_AUTO_ZOOM"]                                          = "Авто-зум"
L["VISTA_AUTO_ZOOM_DELAY"]                                    = "Задержка авто-отдаления"
L["VISTA_SECONDS_AFTER_ZOOMING_BEFORE_AUTO_ZOOM"]             = "Секунд до авто-отдаления после зума. 0 — отключить."

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["VISTA_ZONE_TEXT_HEADER"]                                   = "Текст зоны"
L["VISTA_ZONE_FONT"]                                          = "Шрифт зоны"
L["VISTA_FONT_ZONE_NAME_BELOW_MINIMAP"]                       = "Шрифт названия зоны под миникартой."
L["VISTA_ZONE_FONT_SIZE"]                                     = "Размер шрифта зоны"
L["VISTA_ZONE_TEXT_COLOUR"]                                   = "Цвет текста зоны"
L["VISTA_COLOUR_OF_ZONE_NAME_TEXT"]                           = "Цвет текста названия зоны."
L["VISTA_COORDINATES_TEXT"]                                   = "Текст координат"
L["VISTA_COORDINATES_FONT"]                                   = "Шрифт координат"
L["VISTA_FONT_COORDINATES_TEXT_BELOW_MINIMAP"]                = "Шрифт текста координат под миникартой."
L["VISTA_COORDINATES_FONT_SIZE"]                              = "Размер шрифта координат"
L["VISTA_COORDINATES_TEXT_COLOUR"]                            = "Цвет текста координат"
L["VISTA_COLOUR_OF_COORDINATES_TEXT"]                         = "Цвет текста координат."
L["VISTA_COORDINATE_PRECISION"]                               = "Точность координат"
L["VISTA_NUMBER_OF_DECIMAL_PLACES_SHOWN_X"]                   = "Количество знаков после запятой для координат X и Y."
L["VISTA_COORDS_DECIMALS_OFF"]                                = "Без дробей (напр. 52, 37)"
L["VISTA_DECIMAL_E_G"]                                        = "1 знак (напр. 52.3, 37.1)"
L["VISTA_DECIMALS_E_G"]                                       = "2 знака (напр. 52.34, 37.12)"
L["VISTA_TEXT"]                                               = "Текст времени"
L["VISTA_FONT"]                                               = "Шрифт времени"
L["VISTA_FONT_TEXT_BELOW_MINIMAP"]                            = "Шрифт текста времени под миникартой."
L["VISTA_FONT_SIZE"]                                          = "Размер шрифта времени"
L["VISTA_TEXT_COLOUR"]                                        = "Цвет текста времени"
L["VISTA_COLOUR_OF_TEXT"]                                     = "Цвет текста времени."
-- L["VISTA_PERFORMANCE_TEXT"]                                = "Performance Text"
-- L["VISTA_PERFORMANCE_FONT"]                                = "Performance font"
-- L["VISTA_FONT_FPS_LATENCY_TEXT_BELOW_MINIMAP"]             = "Font for the FPS and latency text below the minimap."
-- L["VISTA_PERFORMANCE_FONT_SIZE"]                           = "Performance font size"
-- L["VISTA_PERFORMANCE_TEXT_COLOUR"]                         = "Performance text colour"
-- L["VISTA_COLOUR_OF_FPS_LATENCY_TEXT"]                      = "Colour of the FPS and latency text."
L["VISTA_DIFFICULTY_TEXT"]                                    = "Текст сложности"
L["VISTA_DIFFICULTY_TEXT_COLOUR_FALLBACK"]                    = "Цвет текста сложности (по умолчанию)"
L["VISTA_DEFAULT_COLOUR_PER_DIFFICULTY_COLOUR"]               = "Цвет по умолчанию, если не задан цвет для конкретной сложности."
L["VISTA_DIFFICULTY_FONT"]                                    = "Шрифт сложности"
L["VISTA_FONT_INSTANCE_DIFFICULTY_TEXT"]                      = "Шрифт текста сложности подземелья."
L["VISTA_DIFFICULTY_FONT_SIZE"]                               = "Размер шрифта сложности"
L["VISTA_PER_DIFFICULTY_COLOURS"]                             = "Цвета по сложности"
L["VISTA_MYTHIC_COLOUR"]                                      = "Цвет «Эпохальный»"
L["VISTA_COLOUR_MYTHIC_DIFFICULTY_TEXT"]                      = "Цвет текста эпохальной сложности."
L["VISTA_HEROIC_COLOUR"]                                      = "Цвет «Героический»"
L["VISTA_COLOUR_HEROIC_DIFFICULTY_TEXT"]                      = "Цвет текста героической сложности."
L["VISTA_NORMAL_COLOUR"]                                      = "Цвет «Обычный»"
L["VISTA_COLOUR_NORMAL_DIFFICULTY_TEXT"]                      = "Цвет текста обычной сложности."
L["VISTA_LFR_COLOUR"]                                         = "Цвет «Поиск рейда»"
L["VISTA_COLOUR_LOOKING_RAID_DIFFICULTY_TEXT"]                = "Цвет текста сложности «Поиск рейда»."

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["VISTA_TEXT_ELEMENTS"]                                      = "Текстовые элементы"
L["VISTA_ZONE_TEXT"]                                          = "Показывать текст зоны"
L["VISTA_ZONE_NAME_BELOW_MINIMAP"]                            = "Показывать название зоны под миникартой."
L["VISTA_ZONE_TEXT_DISPLAY_MODE"]                             = "Режим отображения текста зоны"
L["VISTA_WHAT_ZONE_SUBZONE"]                                  = "Что показывать: только зону, только подзону или обе."
L["VISTA_SHOW_ZONE"]                                          = "Только зона"
L["VISTA_SHOW_SUBZONE"]                                       = "Только подзона"
L["VISTA_SHOW_ZONE_AND_SUBZONE"]                              = "Обе"
L["VISTA_COORDINATES"]                                        = "Показывать координаты"
L["VISTA_PLAYER_COORDINATES_BELOW_MINIMAP"]                   = "Показывать координаты игрока под миникартой."
L["VISTA_TIME"]                                               = "Показывать время"
L["VISTA_CURRENT_GAME_BELOW_MINIMAP"]                         = "Показывать текущее игровое время под миникартой."
-- L["VISTA_HOUR_CLOCK"]                                      = "24-hour clock"
-- L["VISTA_DISPLAY_HOUR_FORMAT_24"]                          = "Display time in 24-hour format (e.g. 14:30 instead of 2:30 PM)."
L["VISTA_LOCAL_TIME"]                                         = "Использовать местное время"
L["VISTA_LOCAL_TIME_TIP"]                                     = "Вкл.: местное системное время. Выкл.: серверное время."
-- L["VISTA_FPS_LATENCY"]                                     = "Show FPS and latency"
-- L["VISTA_FPS_LATENCY_MS_BELOW_MINIMAP"]                    = "Show FPS and latency (ms) below the minimap."
L["VISTA_MINIMAP_BUTTONS"]                                    = "Кнопки миникарты"
L["VISTA_QUEUE_STATUS_MAIL_INDICATOR_ALWAYS_SHOWN"]           = "Статус очереди и индикатор почты всегда отображаются при необходимости."
L["VISTA_TRACKING_BUTTON"]                                    = "Показывать кнопку слежения"
L["VISTA_MINIMAP_TRACKING_BUTTON"]                            = "Показывать кнопку слежения на миникарте."
L["VISTA_TRACKING_BUTTON_MOUSEOVER"]                          = "Кнопка слежения только при наведении"
L["VISTA_HIDE_TRACKING_BUTTON_UNTIL_YOU_HOVER"]               = "Скрывать кнопку слежения до наведения на миникарту."
L["VISTA_CALENDAR_BUTTON"]                                    = "Показывать кнопку календаря"
L["VISTA_MINIMAP_CALENDAR_BUTTON"]                            = "Показывать кнопку календаря на миникарте."
L["VISTA_CALENDAR_BUTTON_MOUSEOVER"]                          = "Кнопка календаря только при наведении"
L["VISTA_HIDE_CALENDAR_BUTTON_UNTIL_YOU_HOVER"]               = "Скрывать кнопку календаря до наведения на миникарту."
L["VISTA_ZOOM_BUTTONS"]                                       = "Показывать кнопки зума"
L["VISTA_ZOOM_BUTTONS_MINIMAP"]                               = "Показывать кнопки + и - зума на миникарте."
L["VISTA_ZOOM_BUTTONS_MOUSEOVER"]                             = "Кнопки зума только при наведении"
L["VISTA_HIDE_ZOOM_BUTTONS_UNTIL_YOU_HOVER"]                  = "Скрывать кнопки зума до наведения на миникарту."

-- =====================================================================
-- OptionsData.lua Vista — Display (Border / Text Positions / Buttons)
-- =====================================================================
L["VISTA_BORDER"]                                             = "Рамка"
L["VISTA_BORDER_TIP"]                                         = "Показывать рамку вокруг миникарты."
L["VISTA_BORDER_COLOUR"]                                      = "Цвет рамки"
L["VISTA_COLOUR_OPACITY_OF_MINIMAP_BORDER"]                   = "Цвет (и прозрачность) рамки миникарты."
L["VISTA_BORDER_THICKNESS"]                                   = "Толщина рамки"
L["VISTA_THICKNESS_OF_MINIMAP_BORDER_PIXELS"]                 = "Толщина рамки миникарты в пикселях (1–8)."
-- L["VISTA_CLASS_COLOURS"]                                   = "Class colours"
-- L["VISTA_TINT_VISTA_BORDER_TEXT_COORDS_FPS"]               = "Tint Vista border and text (coords, time, FPS/MS labels) with your class colour. Numbers use the configured colour."
L["VISTA_TEXT_POSITIONS"]                                     = "Позиции текста"
L["VISTA_DRAG_TEXT_ELEMENTS_REPOSITION_LOCK_PREVEN"]          = "Перетащите текстовые элементы для изменения позиции. Заблокируйте, чтобы избежать случайного перемещения."
L["VISTA_LOCK_ZONE_TEXT_POSITION"]                            = "Зафиксировать позицию текста зоны"
L["VISTA_ZONE_TEXT_CANNOT_DRAGGED"]                           = "Вкл.: текст зоны нельзя перетащить."
L["VISTA_LOCK_COORDINATES_POSITION"]                          = "Зафиксировать позицию координат"
L["VISTA_COORDINATES_TEXT_CANNOT_DRAGGED"]                    = "Вкл.: текст координат нельзя перетащить."
L["VISTA_LOCK_POSITION"]                                      = "Зафиксировать позицию времени"
L["VISTA_TEXT_CANNOT_DRAGGED"]                                = "Вкл.: текст времени нельзя перетащить."
-- L["VISTA_PERFORMANCE_TEXT_POSITION"]                       = "Performance text position"
-- L["VISTA_PLACE_FPS_LATENCY_TEXT_ABOVE_BELOW"]              = "Place the FPS/latency text above or below the minimap."
-- L["VISTA_LOCK_PERFORMANCE_TEXT_POSITION"]                  = "Lock performance text position"
-- L["VISTA_FPS_LATENCY_TEXT_CANNOT_DRAGGED"]                 = "When on, the FPS/latency text cannot be dragged."
-- L["VISTA_DIFFICULTY_TEXT_POSITION"]                        = "Difficulty text position"
-- L["VISTA_PLACE_DIFFICULTY_TEXT_ABOVE_BELOW"]               = "Place the instance difficulty text above or below the minimap. It is positioned independently of zone text."
L["VISTA_LOCK_DIFFICULTY_TEXT_POSITION"]                      = "Зафиксировать позицию текста сложности"
L["VISTA_DIFFICULTY_TEXT_CANNOT_DRAGGED"]                     = "Вкл.: текст сложности нельзя перетащить."
L["VISTA_BUTTON_POSITIONS"]                                   = "Позиции кнопок"
L["VISTA_DRAG_BUTTONS_REPOSITION_LOCK_PREVENT_MOVE"]          = "Перетащите кнопки для изменения позиции. Заблокируйте для фиксации."
L["VISTA_LOCK_ZOOM_BUTTON"]                                   = "Зафиксировать кнопку «Приблизить»"
L["VISTA_PREVENT_DRAGGING_ZOOM_BUTTON"]                       = "Запретить перетаскивание кнопки зума +."
L["VISTA_LOCK_ZOOM_OUT_BUTTON"]                               = "Зафиксировать кнопку «Отдалить»"
L["VISTA_LOCK_ZOOM_OUT_DRAG"]                                 = "Запретить перетаскивание кнопки зума -."
L["VISTA_LOCK_TRACKING_BUTTON"]                               = "Зафиксировать кнопку слежения"
L["VISTA_PREVENT_DRAGGING_TRACKING_BUTTON"]                   = "Запретить перетаскивание кнопки слежения."
L["VISTA_LOCK_CALENDAR_BUTTON"]                               = "Зафиксировать кнопку календаря"
L["VISTA_PREVENT_DRAGGING_CALENDAR_BUTTON"]                   = "Запретить перетаскивание кнопки календаря."
L["VISTA_LOCK_QUEUE_BUTTON"]                                  = "Зафиксировать кнопку очереди"
L["VISTA_PREVENT_DRAGGING_QUEUE_STATUS_BUTTON"]               = "Запретить перетаскивание кнопки статуса очереди."
L["VISTA_LOCK_MAIL_INDICATOR"]                                = "Зафиксировать индикатор почты"
L["VISTA_PREVENT_DRAGGING_MAIL_ICON"]                         = "Запретить перетаскивание значка почты."
-- L["VISTA_DISABLE_QUEUE_HANDLING"]                          = "Disable queue handling"
L["VISTA_DISABLE_QUEUE_BUTTON_HANDLING"]                      = "Отключить управление кнопкой очереди"
L["VISTA_TURN_QUEUE_BUTTON_ANCHORING_OFF_ADDON_CONFLICT"]     = "Отключить привязку кнопки очереди (если ею управляет другой аддон)."
L["VISTA_BUTTON_SIZES"]                                       = "Размеры кнопок"
L["VISTA_ADJUST_SIZE_OF_MINIMAP_OVERLAY_BUTTONS"]             = "Настроить размер кнопок поверх миникарты."
L["VISTA_TRACKING_BUTTON_SIZE"]                               = "Размер кнопки слежения"
L["VISTA_SIZE_OF_TRACKING_BUTTON_PIXELS"]                     = "Размер кнопки слежения (пиксели)."
L["VISTA_CALENDAR_BUTTON_SIZE"]                               = "Размер кнопки календаря"
L["VISTA_SIZE_OF_CALENDAR_BUTTON_PIXELS"]                     = "Размер кнопки календаря (пиксели)."
L["VISTA_QUEUE_BUTTON_SIZE"]                                  = "Размер кнопки очереди"
L["VISTA_SIZE_OF_QUEUE_STATUS_BUTTON_PIXELS"]                 = "Размер кнопки статуса очереди (пиксели)."
L["VISTA_ZOOM_BUTTON_SIZE"]                                   = "Размер кнопок зума"
L["VISTA_SIZE_OF_ZOOM_ZOOM_BUTTONS_PIXELS"]                   = "Размер кнопок зума + / - (пиксели)."
L["VISTA_MAIL_INDICATOR_SIZE"]                                = "Размер индикатора почты"
L["VISTA_SIZE_OF_MAIL_ICON_PIXELS"]                           = "Размер значка новой почты (пиксели)."
L["VISTA_ADDON_BUTTON_SIZE"]                                  = "Размер кнопок аддонов"
L["VISTA_SIZE_OF_COLLECTED_ADDON_MINIMAP_BUTTONS"]            = "Размер собранных кнопок аддонов на миникарте (пиксели)."

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
-- L["VISTA_COLLECT_HORIZON_MINIMAP"]                         = "Include Horizon minimap icon"
-- L["VISTA_COLLECT_HORIZON_MINIMAP_DESC"]                    = "Put Horizon's own minimap icon in the managed addon bar, right-click panel, or drawer instead of leaving it on the minimap edge."
-- L["VISTA_ADDON_BUTTONS"]                                   = "Addon Buttons"
L["VISTA_MINIMAP_ADDON_BUTTONS"]                              = "Кнопки аддонов на миникарте"
L["VISTA_BUTTON_MANAGEMENT"]                                  = "Управление кнопками"
L["VISTA_MANAGE_ADDON_MINIMAP_BUTTONS"]                       = "Управлять кнопками аддонов на миникарте"
L["VISTA_TAKES_CONTROL_OF_ADDON_MINIMAP"]                     = "Вкл.: Vista берёт под контроль кнопки аддонов и группирует их выбранным способом."
L["VISTA_BUTTON_MODE"]                                        = "Режим кнопок"
L["VISTA_ADDON_BUTTONS_PRESENTED_HOVER_BAR_BELOW"]            = "Отображение кнопок аддонов: панель при наведении, панель по правому клику или плавающая кнопка."
-- L["VISTA_ALWAYS_BAR"]                                      = "Always show bar"
-- L["VISTA_ALWAYS_MOUSEOVER_BAR_POSITIONING"]                = "Always show mouseover bar (for positioning)"
-- L["VISTA_KEEP_MOUSEOVER_BAR_VISIBLE_TIMES_YOU"]            = "Keep the mouseover bar visible at all times so you can reposition it. Disable when done."
-- L["VISTA_DISABLE_DONE"]                                    = "Disable when done."
L["VISTA_MOUSEOVER_BAR"]                                      = "Панель при наведении"
L["VISTA_RIGHT_CLICK_PANEL"]                                  = "Панель по ПКМ"
L["VISTA_FLOATING_DRAWER"]                                    = "Плавающая панель"
L["VISTA_LOCK_DRAWER_BUTTON_POSITION"]                        = "Зафиксировать кнопку панели"
L["VISTA_PREVENT_DRAGGING_FLOATING_DRAWER_BUTTON"]            = "Запретить перетаскивание кнопки плавающей панели."
L["VISTA_LOCK_MOUSEOVER_BAR_POSITION"]                        = "Зафиксировать панель при наведении"
L["VISTA_PREVENT_DRAGGING_MOUSEOVER_BUTTON_BAR"]              = "Запретить перетаскивание панели кнопок при наведении."
L["VISTA_LOCK_RIGHT_CLICK_PANEL_POSITION"]                    = "Зафиксировать панель ПКМ"
L["VISTA_PREVENT_DRAGGING_RIGHT_CLICK_PANEL"]                 = "Запретить перетаскивание панели правого клика."
L["VISTA_BUTTONS_PER_ROW_COLUMN"]                             = "Кнопок в строке/столбце"
L["VISTA_CONTROLS_MANY_BUTTONS_APPEAR_BEFORE_WRAPPING"]       = "Количество кнопок до переноса строки. Для направлений влево/вправо — столбцы; вверх/вниз — строки."
L["VISTA_EXPAND_DIRECTION"]                                   = "Направление расширения"
L["VISTA_DIRECTION_BUTTONS_FILL_ANCHOR_POINT_LEFT"]           = "Направление заполнения от точки привязки. Влево/вправо = горизонтальные ряды. Вверх/вниз = вертикальные столбцы."
L["VISTA_BUTTONS_FILL_RIGHT"]                                 = "Вправо"
L["VISTA_BUTTONS_FILL_LEFT"]                                  = "Влево"
L["VISTA_BUTTONS_FILL_DOWN"]                                  = "Вниз"
L["VISTA_BUTTONS_FILL_UP"]                                    = "Вверх"
-- L["VISTA_MOUSEOVER_BAR_APPEARANCE"]                        = "Mouseover Bar Appearance"
-- L["VISTA_BACKGROUND_BORDER_MOUSEOVER_BUTTON_BAR"]          = "Background and border for the mouseover button bar."
-- L["VISTA_BACKDROP_COLOUR"]                                 = "Backdrop colour"
-- L["VISTA_BACKGROUND_COLOUR_OF_MOUSEOVER_BUTTON_BAR"]       = "Background colour of the mouseover button bar (use alpha to control transparency)."
-- L["VISTA_BAR_BORDER"]                                      = "Show bar border"
-- L["VISTA_A_BORDER_AROUND_MOUSEOVER_BUTTON_BAR"]            = "Show a border around the mouseover button bar."
-- L["VISTA_BAR_BORDER_COLOUR"]                               = "Bar border colour"
-- L["VISTA_BORDER_COLOUR_OF_MOUSEOVER_BUTTON_BAR"]           = "Border colour of the mouseover button bar."
-- L["VISTA_BAR_BACKGROUND_COLOUR"]                           = "Bar background colour"
-- L["VISTA_PANEL_BACKGROUND_COLOUR"]                         = "Panel background colour."
-- L["VISTA_CLOSE_FADE_TIMING"]                               = "Close / Fade Timing"
-- L["VISTA_MOUSEOVER_BAR_CLOSE_DELAY_SECONDS"]               = "Mouseover bar — close delay (seconds)"
-- L["VISTA_LONG_SECONDS_BAR_STAYS_VISIBLE_AFTER"]            = "How long (in seconds) the bar stays visible after the cursor leaves. 0 = instant fade."
-- L["VISTA_RIGHT_CLICK_PANEL_CLOSE_DELAY_SECONDS"]           = "Right-click panel — close delay (seconds)"
-- L["VISTA_LONG_SECONDS_PANEL_STAYS_OPEN_AFTER"]             = "How long (in seconds) the panel stays open after the cursor leaves. 0 = never auto-close (close by right-clicking again)."
-- L["VISTA_FLOATING_DRAWER_CLOSE_DELAY_SECONDS"]             = "Floating drawer — close delay (seconds)"
-- L["VISTA_DRAWER_CLOSE_DELAY"]                              = "Drawer close delay"
-- L["VISTA_LONG_SECONDS_DRAWER_PANEL_STAYS_OPEN"]            = "How long (in seconds) the drawer panel stays open after clicking away. 0 = never auto-close (close only by clicking the drawer button again)."
-- L["VISTA_MAIL_ICON_BLINK"]                                 = "Mail icon blink"
-- L["VISTA_MAIL_ICON_PULSES_DRAW_ATTENTION"]                 = "When on, the mail icon pulses to draw attention. When off, it stays at full opacity."
L["VISTA_PANEL_APPEARANCE"]                                   = "Вид панели"
L["VISTA_COLOURS_DRAWER_RIGHT_CLICK_BUTTON_PANELS"]           = "Цвета для панелей кнопок (плавающей и ПКМ)."
L["VISTA_PANEL_BG_COLOUR_LABEL"]                              = "Цвет фона панели"
L["VISTA_BACKGROUND_COLOUR_OF_ADDON_BUTTON_PANELS"]           = "Цвет фона панелей кнопок аддонов."
L["VISTA_PANEL_BORDER_COLOUR"]                                = "Цвет рамки панели"
L["VISTA_BORDER_COLOUR_OF_ADDON_BUTTON_PANELS"]               = "Цвет рамки панелей кнопок аддонов."
L["VISTA_MANAGED_BUTTONS"]                                    = "Управляемые кнопки"
L["VISTA_BUTTON_COMPLETELY_IGNORED"]                          = "Выкл.: кнопка полностью игнорируется этим аддоном."
L["VISTA_ADDON_BUTTONS_DETECTED"]                             = "(Кнопки аддонов пока не обнаружены)"
L["VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE"]                      = "Видимые кнопки (отметьте для включения)"
L["VISTA_ADDON_BUTTONS_DETECTED_OPEN_YOUR_MINIMAP"]           = "(Кнопки аддонов не обнаружены — сначала откройте миникарту)"

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
-- L["GROUPING"]                                              = "Grouping"
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
L["FOCUS_AH_SEARCH_TOOLTIP"]                                  = "Left-click: search for one craft worth of reagents.\nRight-click: enter how many crafts to multiply quantities.\nThe Auction House must be open."
-- L["FOCUS_AH_CRAFT_DIALOG_SUBTITLE"]                        = "Auction House shopping list"
-- L["FOCUS_AH_CRAFT_HINT_CRAFT_COUNT"]                       = "Number of crafts to buy materials for (1–999). List quantities are multiplied by this."
L["FOCUS_AH_CRAFT_HINT_TIER"]                                 = "Crafting tier 1, 2, or 3 for every Auctionator row, or leave empty to use each item’s tier."
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
-- L["SORTING_FILTERING"]                                     = "Sorting & Filtering"
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
-- L["X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]                = "X/Y: objectives like 3/10. Percent: objectives like 45%."
-- L["ZONE_ENTRY"]                                            = "Zone entry"
-- L["ZONE_LABELS"]                                           = "Zone labels"
-- L["ZONE_NAME_NEW_ZONE"]                                    = "Zone name still appears when entering a new zone."
-- L["ZONE_TYPE_COLOURING"]                                   = "Zone type colouring"
-- L["FOCUS_COMPLETED_CHECKMARK"]                             = "|TInterface\\\\Buttons\\\\UI-CheckBox-Check:12:12:0:0|t instead of green for done objectives."
























































































































































