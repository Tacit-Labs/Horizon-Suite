if GetLocale() ~= "zhCN" then return end

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = setmetatable({}, { __index = addon.L })
addon.L = L
addon.StandardFont = UNIT_NAME_FONT

-- =====================================================================
-- OptionsPanel.lua (deprecated) — remaining strings for that UI
-- Panel title + module short names: addon.BrandDisplay (core/BrandDisplay.lua).
-- =====================================================================
L["OPTIONS_FOCUS_OTHER"]                                              = "其他"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["OPTIONS_FOCUS_QUEST_TYPES"]                                        = "任务类型"
L["OPTIONS_FOCUS_ELEMENT_OVERRIDES"]                                  = "元素颜色"
L["OPTIONS_FOCUS_PER_CATEGORY"]                                       = "每个分类"
L["OPTIONS_FOCUS_GROUPING_OVERRIDES"]                                 = "分组覆盖"
-- L["OPTIONS_FOCUS_SECTION_OVERRIDES"]                               = "Section Overrides"
L["OPTIONS_FOCUS_COLORS"]                                             = "其他颜色"

-- =====================================================================
-- OptionsPanel.lua — Color row labels (collapsible group sub-rows)
-- =====================================================================
L["OPTIONS_FOCUS_SECTION"]                                            = "分类"
L["OPTIONS_FOCUS_TITLE"]                                              = "标题"
L["OPTIONS_FOCUS_ZONE"]                                               = "区域"
L["OPTIONS_FOCUS_OBJECTIVE"]                                          = "目标"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["OPTIONS_FOCUS_READY_TURN_OVERRIDES_BASE_COLOURS"]                  = "准备提交覆盖基础颜色"
L["OPTIONS_FOCUS_READY_TURN_COLOURS_QUESTS"]                          = "准备提交在该分类中使用其颜色"
L["OPTIONS_FOCUS_CURRENT_ZONE_OVERRIDES_BASE_COLOURS"]                = "当前区域使用独立颜色"
L["OPTIONS_FOCUS_CURRENT_ZONE_COLOURS_QUESTS_SEC"]                    = "当前区域章节将使用其自己的颜色."
L["OPTIONS_FOCUS_CURRENT_QUEST_OVERRIDES_BASE_COLOURS"]               = "当前任务覆盖基础颜色"
L["OPTIONS_FOCUS_CURRENT_QUEST_COLOURS_QUESTS_SE"]                    = "当前任务在该分类中使用其颜色."
L["OPTIONS_FOCUS_DISTINCT_COLOR_COMPLETED_OBJECTIVES"]                = "已完成目标使用不同颜色"
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES_E_G_COLOR_B"]                   = "启用时已完成目标(如 1/1)使用下方颜色；禁用时使用与未完成目标相同颜色"
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVE"]                                = "已完成目标"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["OPTIONS_FOCUS_RESET"]                                              = "重置"
L["OPTIONS_FOCUS_RESET_QUEST_TYPES"]                                  = "重置任务类型"
L["OPTIONS_FOCUS_RESET_OVERRIDES"]                                    = "重置覆盖"
L["OPTIONS_FOCUS_RESET_DEFAULTS"]                                     = "全部重置为默认值"
L["OPTIONS_FOCUS_RESET_TO_DEFAULTS"]                                  = "重置为默认值"
L["OPTIONS_FOCUS_RESET_DEFAULT"]                                      = "重置为默认值"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["OPTIONS_FOCUS_SEARCH_SETTINGS"]                                    = "搜索设置..."
L["OPTIONS_FOCUS_SEARCH_FONTS"]                                       = "搜索字体..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["OPTIONS_FOCUS_DRAG_RESIZE"]                                        = "拖动以调整大小"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
L["OPTIONS_AXIS_PROFILES"]                                            = "配置文件"
L["OPTIONS_AXIS_MODULES"]                                             = "模块"
-- L["OPTIONS_AXIS_MODULE_TOGGLES"]                                   = "Module Toggles"
-- L["OPTIONS_MODULE_RELOAD_HINT"]                                    = "Reload the interface to finish applying module changes."
-- L["OPTIONS_MODULE_RELOAD_BUTTON"]                                  = "Reload UI"

-- =====================================================================
-- options/dashboard/HomeWelcome.lua — First-run welcome
-- =====================================================================
-- L["DASH_WHATS_NEW"]                                                = "Patch Notes"
L["DASH_FULL_CHANGELOG"]                                              = "Full changelog"
-- L["DASH_WHATS_NEW_UNREAD_SUFFIX"]                                  = " (New!)"
-- L["DASH_PATCH_NOTES_HEAD_SUB"]                                     = "Release history and recent changes"
-- L["DASH_PATCH_NOTES_EMPTY"]                                        = "No notes available."
-- L["DASH_WELCOME_TAB"]                                              = "Welcome"
-- L["DASH_NEWS_TAB"]                                                 = "News"
-- L["DASH_NEWS_HEAD_SUB"]                                            = "Latest updates & community highlights"
-- L["DASH_NEWS_BADGE_NEW"]                                           = "New"
-- L["DASH_NEWS_BADGE_HIGHLIGHT"]                                     = "Highlight"
-- L["DASH_NEWS_EYEBROW_FEATURE"]                                     = "Feature Update"
-- L["DASH_NEWS_EYEBROW_COMMUNITY"]                                   = "Community"
-- L["DASH_NEWS_EYEBROW_ROADMAP"]                                     = "Roadmap"
-- L["DASH_NEWS_EYEBROW_GET_STARTED"]                                 = "Get Started"
-- L["DASH_NEWS_CTA_OPEN_FOCUS"]                                      = "Open Focus settings"
-- L["DASH_NEWS_CTA_VIEW_ARTIST"]                                     = "View artist link"
-- L["DASH_NEWS_CTA_OPEN_PATCH_NOTES"]                                = "Open Patch Notes"
-- L["DASH_NEWS_EDITORIAL_FOOTER_PREFIX"]                             = "News hub • Editorial layout"
-- L["DASH_NEWS_EDITORIAL_FOOTER_LINK"]                               = "Patch notes"
-- L["DASH_NEWS_CTA_OPEN_GUIDE"]                                      = "Open Quick Start"
-- L["DASH_NEWS_FOCUS_CLICK_PROFILE_TITLE"]                           = "Blizzard+ is now the default click profile"
-- L["DASH_NEWS_FOCUS_CLICK_PROFILE_TAGLINE"]                         = "Focus now lands closer to Blizzard muscle memory while keeping Horizon's convenience options close by."
-- L["DASH_NEWS_FOCUS_CLICK_PROFILE_BODY"]                            = "The updated preset gives quest rows a cleaner default interaction model. If you want to tune it, head into Focus > Interactions to review the profile today and keep an eye out for Horizon+ and deeper Custom shortcuts next."
-- L["DASH_NEWS_FOCUS_CLICK_PROFILE_META"]                            = "Focus • Interaction preset • Available now"
-- L["DASH_NEWS_CLASS_ICONS_TITLE"]                                   = "A full Horizon class icon set is now bundled"
-- L["DASH_NEWS_CLASS_ICONS_BODY"]                                    = "Switch Class icon style to Horizon under Axis > Global Toggles to use the new set across the suite. The dashboard now surfaces the full strip here so the update reads like a release, not a footnote."
-- L["DASH_NEWS_CLASS_ICONS_META"]                                    = "Axis • Global Toggles • Art by Gabriel C"
-- L["DASH_NEWS_COMING_SOON_TITLE"]                                   = "More curated updates will land here next"
-- L["DASH_NEWS_COMING_SOON_BODY"]                                    = "This space is now structured for featured stories, release highlights, and smaller follow-up cards. Until the next round of updates lands, Patch Notes remains the fastest way to catch every change."
-- L["DASH_NEWS_COMING_SOON_META"]                                    = "News hub • Editorial layout • Curated in addon"
-- L["DASH_NEWS_QUICK_START_TITLE"]                                   = "Need the quick tour again?"
-- L["DASH_NEWS_QUICK_START_BODY"]                                    = "Quick Start stays a useful companion to News: use it when you want a fast reminder of what each module does, where to enable it, and which pages are worth opening first after an update."
-- L["DASH_NEWS_QUICK_START_META"]                                    = "Guide • Onboarding • Always available"
-- L["DASH_WELCOME_TITLE"]                                            = "Welcome to Horizon Suite"
L["DASH_WELCOME_HEAD_SUB"]                                            = "What each module does and where to turn them on"
L["DASH_WELCOME_INTRO"]                                               = "Horizon Suite is modular — enable only the pieces you want. Turning a module on or off applies on reload. Expand Contributors or Localisations below for credits and supported languages. Use Open module toggles under Modules, or open Axis, then Modules, in the sidebar. You can return to this Welcome page anytime from the sidebar."
-- L["DASH_WELCOME_HERO_EYEBROW"]                                     = "Welcome"
L["DASH_WELCOME_HERO_TITLE"]                                          = "A modular UI suite that lets you keep only the parts you want."
L["DASH_WELCOME_HERO_TAGLINE"]                                        = "Tune Horizon around your tracker, notifications, minimap, tooltips, and character UI without committing to one giant overhaul."
L["DASH_WELCOME_HERO_BODY"]                                           = "Start by choosing the modules you actually want to run, then use the guide below to understand where everything lives. Patch Notes and News stay close by whenever you want a fast catch-up on what changed."
-- L["DASH_WELCOME_START_HERE"]                                       = "Start Here"
L["DASH_WELCOME_CTA_MODULES"]                                         = "Open Modules"
-- L["DASH_WELCOME_CTA_PATCH_NOTES"]                                  = "Open Patch Notes"
-- L["DASH_WELCOME_CTA_NEWS"]                                         = "Open News"
L["DASH_WELCOME_ACTION_MODULES_TITLE"]                                = "Choose the parts of Horizon you want"
L["DASH_WELCOME_ACTION_MODULES_BODY"]                                 = "Use the dashboard home to turn modules on or off, then reload when you are ready to apply larger setup changes."
L["DASH_WELCOME_ACTION_UPDATES_TITLE"]                                = "Catch up on what changed"
L["DASH_WELCOME_ACTION_UPDATES_BODY"]                                 = "Patch Notes and News are the fastest way to see new presets, art, polish passes, and module changes between releases."
L["DASH_WELCOME_ACTION_NEWS_TITLE"]                                   = "See the editorial update feed"
L["DASH_WELCOME_ACTION_NEWS_BODY"]                                    = "Open News for featured stories, roadmap notes, art highlights, and smaller curated updates in one place."
-- L["DASH_WELCOME_LEARN_TITLE"]                                      = "Learn the Suite"
-- L["DASH_WELCOME_LEARN_BODY"]                                       = "Use this section as the guided overview of Horizon: what each module does, how to get started, and where to go next once the basics are in place."
L["DASH_WELCOME_PATH"]                                                = "%s → %s → %s"
-- L["DASH_WELCOME_FOCUS_BLIZZARD_PLUS_HEADING"]                      = "Blizzard+ click profile"
-- L["DASH_WELCOME_FOCUS_BLIZZARD_PLUS_BODY"]                         = [=[Focus now uses |cffffffffBlizzard+|r by default — Blizzard-style quest row clicks with a few Horizon conveniences. Open |cffaaaaaaFocus > Interactions|r and use |cffaaaaaaClick profile|r to see the preset; |cffffffffHorizon+|r and full |cffffffffCustom|r shortcuts are on the way.]=]
-- L["DASH_WELCOME_COMING_SOON_TITLE"]                                = "Coming Soon"
-- L["DASH_WELCOME_COMING_SOON_TAGLINE"]                              = "New welcome experiences are on the way."
-- L["DASH_WELCOME_COMING_SOON_BODY"]                                 = [=[Watch this space — we will post updates here and in |cffaaaaaaPatch Notes|r. Join |cffaaaaaaDiscord|r from the links below for news and feedback.]=]
L["DASH_WELCOME_CLASS_ICONS_HEADING"]                                 = "Horizon class icons"
L["DASH_WELCOME_CLASS_ICONS_LEAD"]                                    = [=[We have added a bundled set of custom class icons — now the default when you choose |cffaaaaaaHorizon|r under |cffaaaaaaAxis → Global Toggles|r (Class icon style).]=]
-- L["DASH_WELCOME_CLASS_ICONS_THANK_BOOFULS"]                        = [=[Thank you, Boofuls, for commissioning this art and helping bring these icons to everyone.]=]
-- L["DASH_WELCOME_CLASS_ICONS_CREATED_PREFIX"]                       = "• Created by "
-- L["DASH_WELCOME_CLASS_ICONS_ARTIST_NAME"]                          = "Gabriel C"
-- L["DASH_WELCOME_CONTRIBUTORS_HEADING"]                             = "Contributors"
L["DASH_WELCOME_CONTRIBUTORS_BODY"]                                   = [=[Thanks to everyone who has contributed to Horizon Suite:
-- 
-- • feanor21#2847 — Panoramuxa (Tarren Mill - EU) — Development
-- • Marthix — Development
-- • Swift — Coordinator
-- • Boofuls — Moderator
-- • Diva — Innovator
-- • RondoFerrari — RondoMedia (CurseForge addon) — Class icons in Insight tooltips and optional Dashboard header icon when class colors are on (optional)
-- • Aishuu — French localisation (frFR)
-- • 아즈샤라-두녘 — Korean localisation (koKR)
-- • Linho-Gallywix — Brazilian Portuguese localisation (ptBR)
-- • allmoon — Chinese localisation (zhCN)]=]
-- L["DASH_WELCOME_LOCALISATIONS_HEADING"]                            = "Localisations"
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
-- L["DASH_GUIDE_HEAD_SUB"]                                           = "What each part of Horizon does"
-- L["DASH_GUIDE_HERO_TITLE"]                                         = "Getting started with Horizon Suite"
-- L["DASH_GUIDE_HERO_TAGLINE"]                                       = "A modular UI toolkit for quests, notifications, the minimap, and more."
L["DASH_GUIDE_HERO_INTRO"]                                            = "Pick the modules you want, tune them in the sidebar, and reload when you toggle something on or off. This page is always here — open it anytime from the Guide row under Welcome."
-- L["DASH_GUIDE_QUICK_START_HEADING"]                                = "Quick start"
L["DASH_GUIDE_QUICK_START_BODY"]                                      = [=[• Under |cffaaaaaaAxis > Modules|r in the sidebar, turn each module on or off. Changing modules applies after a |cffaaaaaaReload UI|r.
-- • Under |cffaaaaaaAxis > Global Toggles|r, set class-colour tinting for the dashboard and modules, pick a |cffaaaaaaDashboard background|r preset, and adjust |cffaaaaaaUI scale|r (global or per module).]=]
-- L["DASH_GUIDE_HORIZON_HEADING"]                                    = "What is Horizon Suite?"
L["DASH_GUIDE_HORIZON_BULLETS"]                                       = [=[• Axis — Profiles, module on/off, global toggles, typography, and other suite-wide settings.
• Focus — Quest and content tracker: quests, world quests, scenarios, rares, achievements, and more in coloured sections.
• Presence — Large cinematic toasts for zones, quests, scenarios, achievements, level up, and similar moments.
• Vista — Minimap chrome: zone text, coordinates, clock, and a collector for minimap buttons.
• Insight — Richer tooltips for players, NPCs, and items (class colours, spec, icons, extras).
• Cache — Loot toasts and bag presentation.
• Essence — Character sheet with 3D model, item level, stats, and gear grid.
• Meridian — Coming soon.]=]
-- L["DASH_GUIDE_MOD_AXIS_BODY"]                                      = "Axis is the control centre: switch profiles, enable or disable whole modules, open Global Toggles for class colours and UI scale, and reach typography and appearance options that apply across Horizon. Start here when you first install or when you want a lighter footprint by turning modules off."
L["DASH_GUIDE_MOD_FOCUS_BODY"]                                        = [=[Focus replaces the default objective list with a flexible tracker. Tracked quests, world quests, scenarios, rares, achievements, endeavors, decor, recipes, and more are grouped into coloured section headers so you can scan quickly.
Sections only appear when they have something to show — for example Current (recent progress), Current zone, Ready to turn in, World / weekly / daily / Prey, campaign and special quests, delves and scenarios, rare bosses and loot, achievements and collections, and time-limited or zone events.

Use Focus → Sorting & filtering to reorder sections, and Focus → Content to choose which types of content appear.]=]
-- L["DASH_GUIDE_PRESENCE_INTRO"]                                     = "Presence shows large, styled alerts for moments that used to be separate Blizzard popups — zone changes, quest progress, achievements, scenarios, and more. You can turn each type on or off and tune typography in Presence settings."
L["DASH_GUIDE_PRESENCE_BODY"]                                         = [=[Typical Presence toasts include:
• Zone and subzone discovery text when you enter new areas.
• Quest accepted, objective progress, quest complete, and world quest complete.
• Scenario start, progress updates, and completion (including delve-style flow).
• Achievements earned and optional achievement progress ticks.
• Level up, boss emotes, and rare defeated.]=]
-- L["DASH_GUIDE_PRESENCE_BLIZZARD"]                                  = [=[When a Presence type is enabled, Horizon can hide the matching default UI so you don’t get duplicates — for example zone name banners, the level-up frame, boss emote bar, event toast manager, world-quest completion banner, and some objective bonus banners. Turn a Presence type off in settings to let the default game UI show again for that category.]=]
-- L["DASH_GUIDE_MOD_VISTA_BODY"]                                     = "Vista wraps your minimap with readable zone and subzone text, optional coordinates and clock, and a bar that collects stray minimap buttons so they stay tidy. Tune layout and colours under Vista in the sidebar."
-- L["DASH_GUIDE_MOD_INSIGHT_BODY"]                                   = "Insight extends Blizzard tooltips for players, NPCs, and items — class and faction colouring, spec and icon lines, optional Mythic+ score, item level, mount collection hints, and cleaner separators. Each tooltip type has its own category under Insight."
-- L["DASH_GUIDE_MOD_CACHE_BODY"]                                     = "Cache handles loot feedback: styled loot toasts for items, money, currency, and reputation, plus options that tie into how rewards are shown. Enable it when you want Horizon’s presentation instead of the default loot popups."
-- L["DASH_GUIDE_MOD_ESSENCE_BODY"]                                   = "Essence is an optional character sheet: 3D model, item level, primary stats, and a gear grid so you can review your equipment at a glance. Open Essence in the sidebar to adjust layout and visibility."
-- L["DASH_GUIDE_MOD_MERIDIAN_BODY"]                                  = "Coming soon."
-- L["DASH_AXIS_MODULE_SHORT_DESCRIPTION"]                            = "Core settings hub: profiles, modules, and global toggles."
-- L["DASH_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS"]                    = "Objective tracker for quests, world quests, rares, achievements, scenarios."
-- L["DASH_ZONE_TEXT_AND_NOTIFICATIONS"]                              = "Zone text and notifications."
-- L["DASH_MINIMAP_ZONE_TEXT_COORDS_BUTTON"]                          = "Minimap with zone text, coords, time, and button collector."
-- L["DASH_TOOLTIPS_CLASS_COLORS_SPEC_FACTION"]                       = "Tooltips with class colors, spec, and faction icons."
-- L["DASH_LOOT_TOASTS_ITEMS_MONEY_CURRENCY"]                         = "Loot toasts for items, money, currency, reputation, and bag overhaul."
-- L["DASH_ESSENCE_MODULE_SHORT_DESCRIPTION"]                         = "Custom character sheet with 3D model, item level, stats, and gear grid."
-- L["DASH_MERIDIAN_MODULE_SHORT_DESCRIPTION"]                        = "Coming soon."
-- L["DASH_WELCOME_COMMUNITY_HEADING"]                                = "Community & Support"
-- L["DASH_DISCORD"]                                                  = "Discord"
-- L["DASH_KO_FI"]                                                    = "Ko-fi"
-- L["DASH_PATREON"]                                                  = "Patreon"
-- L["DASH_GITLAB"]                                                   = "GitLab"
-- L["DASH_CURSEFORGE"]                                               = "CurseForge"
-- L["DASH_WAGO"]                                                     = "Wago"
-- L["DASH_COPY_LINK_X"]                                              = "Copy link — %s"
-- L["DASH_HOME_HEAD_SUB"]                                            = "Enable and configure your modules"
L["DASH_HOME_MOD_FOCUS_SHORT"]                                        = "Track spells, cooldowns, and procs."
L["DASH_HOME_MOD_PRESENCE_SHORT"]                                     = "Enhance nameplates and unit frames."
L["DASH_HOME_MOD_VISTA_SHORT"]                                        = "Enrich the world map and minimap."
L["DASH_HOME_MOD_INSIGHT_SHORT"]                                      = "Add context to tooltips and inspects."
L["DASH_HOME_MOD_CACHE_SHORT"]                                        = "Smart loot and item management."
L["DASH_HOME_MOD_ESSENCE_SHORT"]                                      = "Custom HUD elements and action bars."
-- L["DASH_HOME_RELOAD_PROMPT"]                                       = "Reload to apply module changes."
-- L["DASH_RELOAD_UI"]                                                = "Reload UI"
L["DASH_LAYOUT"]                                                      = "布局"
L["DASH_VISIBILITY"]                                                  = "可见性"
L["DASH_DISPLAY"]                                                     = "显示"
L["DASH_FEATURES"]                                                    = "功能"
L["DASH_TYPOGRAPHY"]                                                  = "排版"
L["DASH_APPEARANCE"]                                                  = "外观"
L["DASH_COLORS"]                                                      = "颜色"
L["DASH_ORGANIZATION"]                                                = "组织"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["OPTIONS_FOCUS_PANEL_BEHAVIOUR"]                                    = "面板行为"
L["OPTIONS_FOCUS_DIMENSIONS"]                                         = "尺寸"
L["OPTIONS_FOCUS_INSTANCE"]                                           = "副本"
L["OPTIONS_FOCUS_INSTANCES"]                                          = "副本"
L["OPTIONS_FOCUS_COMBAT"]                                             = "战斗"
L["OPTIONS_FOCUS_FILTERING"]                                          = "过滤"
L["OPTIONS_FOCUS_HEADER"]                                             = "标题"
-- L["OPTIONS_FOCUS_SECTIONS_STRUCTURE"]                              = "Sections & structure"
-- L["OPTIONS_FOCUS_ENTRY_DETAILS"]                                   = "Entry details"
-- L["OPTIONS_FOCUS_PROGRESS_TIMERS"]                                 = "Progress & timers"
-- L["OPTIONS_FOCUS_EMPHASIS"]                                        = "Focus emphasis"
L["OPTIONS_FOCUS_LIST"]                                               = "列表"
L["OPTIONS_FOCUS_SPACING"]                                            = "间距"
L["OPTIONS_FOCUS_RARE_BOSSES"]                                        = "稀有首领"
L["OPTIONS_FOCUS_WORLD_QUESTS"]                                       = "世界任务"
L["OPTIONS_FOCUS_FLOATING_QUEST_ITEM"]                                = "浮动任务物品"
L["OPTIONS_FOCUS_MYTHIC"]                                             = "史诗+"
L["OPTIONS_FOCUS_ACHIEVEMENTS"]                                       = "成就"
-- L["OPTIONS_FOCUS_ACHIEVEMENT_PROGRESS_BARS"]                       = "Achievement progress bars"
-- L["OPTIONS_FOCUS_ACHIEVEMENT_PROGRESS_BARS_DESC"]                  = "Show a progress bar under tracked achievements that report numeric criteria (including 0/1 and X/Y). Independent of Quest Progress Bars."
-- L["OPTIONS_FOCUS_ACHIEVEMENT_PROGRESS_BARS_TIP"]                   = "Uses the same bar colors, texture, and font as other Focus progress bars when those options are visible."
L["OPTIONS_FOCUS_ENDEAVORS"]                                          = "宏图"
L["OPTIONS_FOCUS_DECOR"]                                              = "装饰"
-- L["OPTIONS_FOCUS_APPEARANCES"]                                     = "Appearances"
L["OPTIONS_FOCUS_SCENARIO_DELVE"]                                     = "场景和地下堡"
L["OPTIONS_FOCUS_FONT"]                                               = "字体"
-- L["OPTIONS_FOCUS_FONT_FAMILIES"]                                   = "Font families"
-- L["OPTIONS_FOCUS_GLOBAL_FONT_SIZE"]                                = "Global font size"
-- L["OPTIONS_FOCUS_FONT_SIZES"]                                      = "Font sizes"
-- L["OPTIONS_FOCUS_PER_ELEMENT_FONTS"]                               = "Per-element fonts"
L["OPTIONS_FOCUS_TEXT_CASE"]                                          = "文本大小写"
L["OPTIONS_FOCUS_SHADOW"]                                             = "阴影"
L["OPTIONS_FOCUS_PANEL"]                                              = "面板"
L["OPTIONS_FOCUS_HIGHLIGHT"]                                          = "高亮"
L["OPTIONS_FOCUS_COLOR_MATRIX"]                                       = "颜色矩阵"
L["OPTIONS_FOCUS_ORDER"]                                              = "顺序"
L["OPTIONS_FOCUS_SORT"]                                               = "排序"
L["OPTIONS_FOCUS_BEHAVIOUR"]                                          = "行为"
L["OPTIONS_FOCUS_CONTENT_TYPES"]                                      = "内容类型"
L["OPTIONS_FOCUS_DELVES"]                                             = "地下堡"
L["OPTIONS_FOCUS_DELVES_DUNGEONS"]                                    = "地下堡与地下城"
L["OPTIONS_FOCUS_DELVE_COMPLETE"]                                     = "地下堡完成"
L["OPTIONS_FOCUS_INTERACTIONS"]                                       = "交互"
L["OPTIONS_FOCUS_TRACKING"]                                           = "追踪"
L["OPTIONS_FOCUS_SCENARIO_BAR"]                                       = "场景条"

-- =====================================================================
-- OptionsData.lua Profiles
-- =====================================================================
L["OPTIONS_AXIS_CURRENT_PROFILE"]                                     = "当前配置文件"
L["OPTIONS_AXIS_SELECT_PROFILE_CURRENTLY"]                            = "选择当前使用的配置文件"
L["OPTIONS_AXIS_GLOBAL_PROFILE_ACCOUNT_WIDE"]                         = "使用全局配置文件(账号范围)"
L["OPTIONS_AXIS_CHARACTERS_SAME_PROFILE"]                             = "所有角色使用相同的配置文件."
L["OPTIONS_AXIS_ENABLE_PER_SPECIALIZATION_PROFILES"]                  = "启用专精配置文件"
L["OPTIONS_AXIS_PICK_DIFFERENT_PROFILES_PER_SPEC"]                    = "为每项专精选择不同配置文件"
L["OPTIONS_AXIS_SPECIALIZATION"]                                      = "专精"
L["OPTIONS_AXIS_SHARING"]                                             = "分享"
L["OPTIONS_AXIS_IMPORT_PROFILE"]                                      = "导入配置文件"
L["OPTIONS_AXIS_IMPORT_STRING"]                                       = "导入字符串"
L["OPTIONS_AXIS_EXPORT_PROFILE"]                                      = "导出配置文件"
L["OPTIONS_AXIS_SELECT_A_PROFILE_EXPORT"]                             = "选择要导出的配置文件"
L["OPTIONS_AXIS_EXPORT_STRING"]                                       = "导出字符串"
L["OPTIONS_AXIS_COPY_PROFILE"]                                        = "从配置文件复制"
L["OPTIONS_AXIS_SOURCE_PROFILE_COPYING"]                              = "用于复制的源配置文件"
L["OPTIONS_AXIS_COPY_SELECTED"]                                       = "从选中的复制"
L["OPTIONS_AXIS_CREATE"]                                              = "创建"
L["OPTIONS_AXIS_CREATE_PROFILE_DEFAULT_TEMPLATE"]                     = "从默认模板创建新配置文件"
L["OPTIONS_AXIS_CREATES_A_PROFILE_DEFAULT_SETTINGS"]                  = "创建一个包含所有默认设置的新配置文件."
L["OPTIONS_AXIS_CREATES_A_PROFILE_COPIED_SELECTED_SOURC"]             = "创建一个从选定的源配置文件复制的新配置文件."
L["OPTIONS_AXIS_DELETE_PROFILE"]                                      = "删除配置文件"
L["OPTIONS_AXIS_SELECT_A_PROFILE_DELETE_CURRENT_DEFAULT"]             = "选择要删除的配置文件(不显示当前和默认配置文件)"
L["OPTIONS_AXIS_DELETE_SELECTED"]                                     = "删除选中项"
-- L["OPTIONS_AXIS_DELETE_SELECTED_PROFILE"]                          = "Delete selected profile"
L["OPTIONS_AXIS_DELETE"]                                              = "删除"
L["OPTIONS_AXIS_DELETES_SELECTED_PROFILE"]                            = "删除选中的配置文件"
L["OPTIONS_AXIS_GLOBAL_PROFILE"]                                      = "全局配置文件"
L["OPTIONS_AXIS_PER_SPEC_PROFILES"]                                   = "专精配置文件"

-- =====================================================================
-- OptionsData.lua Modules
-- =====================================================================
L["OPTIONS_AXIS_ENABLE_FOCUS_MODULE"]                                 = "启用聚焦模块"
L["OPTIONS_AXIS_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS_R"]             = "显示任务、世界任务、稀有怪物、成就和场景的目标追踪器"
L["OPTIONS_AXIS_ENABLE_PRESENCE_MODULE"]                              = "启用Presence模块"
L["OPTIONS_AXIS_CINEMATIC_ZONE_TEXT_NOTIFICATIONS_ZONE_CHANGES"]      = "显示电影化区域文本与情境通知（包含区域切换、角色升级、首领喊话、成就达成及任务进度）."
L["OPTIONS_AXIS_ENABLE_CACHE_MODULE"]                                 = "启用Cache模块"
L["OPTIONS_AXIS_CINEMATIC_LOOT_NOTIFICATIONS_ITEMS_MONEY_CURRENCY"]   = "电影级战利品通知(物品, 金币, 货币, 声望)."
L["OPTIONS_AXIS_ENABLE_VISTA_MODULE"]                                 = "启用Vista模块"
L["OPTIONS_AXIS_CINEMATIC_SQUARE_MINIMAP_ZONE_TEXT_COORDINATES"]      = "电影级方形小地图, 带有区域文本, 坐标和按钮收集器."
L["OPTIONS_AXIS_MINIMAP_ZONE_TIME_COLLECTOR"]                         = "带有区域文本, 坐标, 时间和按钮收集器的电影式方形小地图."
L["OPTIONS_AXIS_BETA"]                                                = "测试版"
L["OPTIONS_AXIS_SCALING"]                                             = "缩放"
-- L["OPTIONS_AXIS_GLOBAL_TOGGLES"]                                   = "Global Toggles"
-- L["OPTIONS_AXIS_PATCH_NOTES_SECTION"]                              = "Patch notes"
-- L["OPTIONS_AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN"]                   = "Show Patch Notes automatically after an update"
-- L["OPTIONS_AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN_DESC"]              = "When on, Axis opens to Patch Notes once after each new addon version. When off, a green dot appears on the Horizon minimap icon until you open Patch Notes."
-- L["OPTIONS_AXIS_SUITE_WIDE_CLASS_COLOUR_TINTING_UI"]               = "Dashboard background theme, class colour tinting, and UI scale (global or per module)."
L["OPTIONS_AXIS_GLOBAL_UI_SCALE"]                                     = "全局UI缩放"
L["OPTIONS_AXIS_SCALE_SIZES_SPACINGS_FONTS_FACTOR"]                   = "按此因子缩放所有大小、间距和字体(50-200%)。不改变已配置的数值"
L["OPTIONS_AXIS_PER_MODULE_SCALING"]                                  = "每模块缩放"
L["OPTIONS_AXIS_OVERRIDE_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_FO"]         = "使用各模块单独滑块覆盖全局缩放"
L["OPTIONS_AXIS_OVERRIDES_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_F"]         = "使用目标、情境、Vista等模块单独滑块覆盖全局缩放"
L["OPTIONS_AXIS_DOESN_T_CHANGE_YOUR_CONFIGURED_VALUES"]               = "不改变已配置的数值，仅改变有效显示比例"
L["OPTIONS_FOCUS_SCALE"]                                              = "聚焦缩放"
L["OPTIONS_AXIS_SCALE_FOCUS_OBJECTIVE_TRACKER"]                       = "聚焦目标追踪器缩放(50-200%)"
L["OPTIONS_PRESENCE_SCALE"]                                           = "情境缩放"
L["OPTIONS_AXIS_SCALE_PRESENCE_CINEMATIC_TEXT"]                       = "Presence过场文本缩放(50-200%)"
L["OPTIONS_VISTA_SCALE"]                                              = "Vista缩放"
L["OPTIONS_AXIS_SCALE_VISTA_MINIMAP_MODULE"]                          = "Vista小地图模块缩放(50-200%)"
L["OPTIONS_INSIGHT_SCALE"]                                            = "洞察缩放"
L["OPTIONS_AXIS_SCALE_INSIGHT_TOOLTIP_MODULE"]                        = "洞察提示模块缩放(50-200%)"
L["OPTIONS_CACHE_SCALE"]                                              = "Cache缩放"
L["OPTIONS_AXIS_SCALE_CACHE_LOOT_TOAST_MODULE"]                       = "Cache战利品提示模块缩放(50-200%)"
L["OPTIONS_AXIS_ENABLE_HORIZON_INSIGHT_MODULE"]                       = "启用Horizon洞察模块"
L["OPTIONS_AXIS_CINEMATIC_TOOLTIPS_CLASS_COLORS_SPEC_DISPLAY"]        = "电影级提示框, 带有职业颜色, 专精显示和阵营图标."
L["OPTIONS_AXIS_TOOLTIP_ANCHOR_MODE"]                                 = "提示锚定模式"
L["OPTIONS_AXIS_WHERE_TOOLTIPS_APPEAR_FOLLOW_CURSOR_FIXED"]           = "提示显示位置：跟随光标或固定位置"
L["OPTIONS_AXIS_CURSOR"]                                              = "光标"
L["OPTIONS_AXIS_FIXED"]                                               = "固定"
-- L["OPTIONS_INSIGHT_CURSOR_SIDE"]                                   = "Cursor side"
-- L["OPTIONS_INSIGHT_CURSOR_SIDE_DESC"]                              = "Which side of the cursor the tooltip appears on."
-- L["OPTIONS_INSIGHT_CURSOR_SIDE_CENTER"]                            = "Center"
-- L["OPTIONS_INSIGHT_CURSOR_SIDE_LEFT"]                              = "Left"
-- L["OPTIONS_INSIGHT_CURSOR_SIDE_RIGHT"]                             = "Right"
L["OPTIONS_AXIS_ANCHOR_MOVE"]                                         = "显示锚点以移动"
-- L["OPTIONS_AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITIO"]                   = "Click to show or hide the anchor. Drag to set position, right-click to confirm."
L["OPTIONS_AXIS_DRAGGABLE_FRAME_FIXED_TOOLTIP_POSITION_D"]            = "显示可拖动框架设置固定提示位置。拖动后右键确认"
L["OPTIONS_AXIS_RESET_TOOLTIP_POSITION"]                              = "重置提示位置"
L["OPTIONS_AXIS_RESET_FIXED_POSITION_DEFAULT"]                        = "固定位置重置为默认值"
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_X"]                               = "Cursor offset X"
L["OPTIONS_INSIGHT_CURSOR_OFFSET_X_DESC"]                             = "Horizontal pixel offset from the default cursor tooltip position (cursor anchor only)."
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_Y"]                               = "Cursor offset Y"
L["OPTIONS_INSIGHT_CURSOR_OFFSET_Y_DESC"]                             = "Vertical pixel offset from the default cursor tooltip position (cursor anchor only)."
L["OPTIONS_AXIS_TOOLTIP_BACKGROUND_COLOR"]                            = "提示框背景颜色"
L["OPTIONS_AXIS_COLOR_OF_TOOLTIP_BACKGROUND"]                         = "提示框背景颜色."
L["OPTIONS_AXIS_TOOLTIP_BACKGROUND_OPACITY"]                          = "提示框背景不透明度"
L["OPTIONS_AXIS_TOOLTIP_BG_OPACITY_PCT_DESC"]                         = "提示框背景不透明度 (0–100%)."
L["OPTIONS_AXIS_TOOLTIP_FONT"]                                        = "提示框字体"
L["OPTIONS_AXIS_FONT_FAMILY_TOOLTIP_TEXT"]                            = "用于所有提示框文字的字体。"
-- L["OPTIONS_INSIGHT_BODY_SIZE"]                                     = "Body size"
-- L["OPTIONS_INSIGHT_BODY_FONT_SIZE"]                                = "Body font size."
-- L["OPTIONS_INSIGHT_BADGES_SIZE"]                                   = "Badges size"
-- L["OPTIONS_INSIGHT_BADGES_FONT_SIZE"]                              = "Status badges font size."
-- L["OPTIONS_INSIGHT_STATS_SIZE"]                                    = "Stats size"
-- L["OPTIONS_INSIGHT_STATS_FONT_SIZE"]                               = "M+ score, item level, and honor level font size."
-- L["OPTIONS_INSIGHT_MOUNT_SIZE"]                                    = "Mount size"
-- L["OPTIONS_INSIGHT_MOUNT_FONT_SIZE"]                               = "Mount name, source, and ownership font size."
-- L["OPTIONS_INSIGHT_MOUNT_OWNERSHIP_DISPLAY"]                       = "Mount collection indicator"
-- L["OPTIONS_INSIGHT_MOUNT_OWNERSHIP_DISPLAY_DESC"]                  = "How to show whether you have collected the hovered player's mount."
-- L["OPTIONS_INSIGHT_MOUNT_OWNERSHIP_TEXT"]                          = "Full text"
-- L["OPTIONS_INSIGHT_MOUNT_OWNERSHIP_ICONS"]                         = "Tick / cross"
-- L["INSIGHT_MOUNT_OWNED"]                                           = "You own this mount"
-- L["INSIGHT_MOUNT_NOT_OWNED"]                                       = "You don't own this mount"
-- L["OPTIONS_INSIGHT_TRANSMOG_SIZE"]                                 = "Transmog size"
-- L["OPTIONS_INSIGHT_TRANSMOG_FONT_SIZE"]                            = "Item appearance status font size."
L["OPTIONS_AXIS_TOOLTIPS"]                                            = "提示"
-- L["OPTIONS_INSIGHT_CATEGORY_GLOBAL"]                               = "Global Tooltips"
L["OPTIONS_INSIGHT_CATEGORY_GLOBAL_DESC"]                             = "Anchor, backdrop, fonts, sizes, and display options shared across tooltip types."
-- L["OPTIONS_INSIGHT_CATEGORY_PLAYER"]                               = "Player Characters"
L["OPTIONS_INSIGHT_CATEGORY_PLAYER_DESC"]                             = "Guild rank, titles, badges, PvP, ratings, gear, and mount lines on player tooltips."
-- L["OPTIONS_INSIGHT_CATEGORY_NPC"]                                  = "NPCs"
L["OPTIONS_INSIGHT_CATEGORY_NPC_DESC"]                                = "NPC tooltip styling. Extra NPC-only toggles can be added here later."
-- L["OPTIONS_INSIGHT_CATEGORY_ITEM"]                                 = "Items"
-- L["OPTIONS_INSIGHT_CATEGORY_ITEM_DESC"]                            = "Item tooltip options such as transmog collection status."
-- L["OPTIONS_INSIGHT_SECTION_IDENTITY"]                              = "Identity"
-- L["OPTIONS_INSIGHT_PLAYER_NAME_COLOR"]                             = "Player name colour"
-- L["OPTIONS_INSIGHT_PLAYER_NAME_COLOR_DESC"]                        = "Colour for the player's name on the first tooltip line: faction (Alliance blue, Horde red) or class."
-- L["OPTIONS_INSIGHT_PLAYER_NAME_COLOR_FACTION"]                     = "Faction"
-- L["OPTIONS_INSIGHT_PLAYER_NAME_COLOR_CLASS"]                       = "Class"
-- L["OPTIONS_INSIGHT_SECTION_STATUS_PVP"]                            = "Status & PvP"
-- L["OPTIONS_INSIGHT_SECTION_RATINGS_GEAR"]                          = "Ratings & gear"
-- L["OPTIONS_INSIGHT_SECTION_MOUNT"]                                 = "Mount"
-- L["OPTIONS_INSIGHT_SECTION_DISMISS"]                               = "Unit tooltip dismiss"
-- L["OPTIONS_INSIGHT_DISMISS_GRACE"]                                 = "Dismiss grace"
L["OPTIONS_INSIGHT_DISMISS_GRACE_DESC"]                               = "How long to wait after the mouse leaves a unit before starting to hide the GameTooltip. Longer grace reduces flicker from brief cursor gaps."
-- L["OPTIONS_INSIGHT_DISMISS_GRACE_INSTANT"]                         = "Instant"
-- L["OPTIONS_INSIGHT_DISMISS_GRACE_DEFAULT"]                         = "Normal"
-- L["OPTIONS_INSIGHT_DISMISS_GRACE_RELAXED"]                         = "Relaxed"
-- L["OPTIONS_INSIGHT_SECTION_COMBAT"]                                = "Combat"
-- L["OPTIONS_INSIGHT_HIDE_IN_COMBAT"]                                = "Hide tooltips in combat"
-- L["OPTIONS_INSIGHT_HIDE_IN_COMBAT_DESC"]                           = "While in combat, close GameTooltip and other Insight-styled tooltip frames and block them from staying open. Applies only when the Insight module is enabled."
-- L["OPTIONS_INSIGHT_FADE_OUT_SEC"]                                  = "Fade-out duration"
L["OPTIONS_INSIGHT_FADE_OUT_SEC_DESC"]                                = "Seconds to fade the unit tooltip after dismiss starts. Zero hides immediately (no fade). Applies to GameTooltip unit tips only."
-- L["OPTIONS_INSIGHT_SECTION_ICONS_AND_SEPARATORS"]                  = "Icons & separators"
-- L["OPTIONS_INSIGHT_SECTION_NPC_TOOLTIP"]                           = "NPC tooltip"
-- L["OPTIONS_INSIGHT_SECTION_TRANSMOG"]                              = "Transmog"
-- L["OPTIONS_INSIGHT_NPC_PLACEHOLDER"]                               = "NPC-specific options will appear here when available. Reaction colours and level lines still apply in-game."
-- L["OPTIONS_INSIGHT_NPC_REACTION_BORDER"]                           = "Reaction border"
-- L["OPTIONS_INSIGHT_NPC_REACTION_BORDER_DESC"]                      = "Tint the tooltip border to the NPC's faction reaction (hostile red, friendly green, neutral yellow)."
-- L["OPTIONS_INSIGHT_NPC_REACTION_NAME"]                             = "Reaction name colour"
-- L["OPTIONS_INSIGHT_NPC_REACTION_NAME_DESC"]                        = "Colour the NPC's name to match their faction reaction."
-- L["OPTIONS_INSIGHT_NPC_LEVEL_LINE"]                                = "Level line"
-- L["OPTIONS_INSIGHT_NPC_LEVEL_LINE_DESC"]                           = "Show the NPC's level, classification (Elite, Rare, etc.), and creature type beneath their name."
-- L["OPTIONS_INSIGHT_NPC_ICONS_DESC"]                                = "Show an icon instead of '??' for NPCs with an unknown level."
-- L["OPTIONS_INSIGHT_SECTION_ITEM_STYLING"]                          = "Item styling"
-- L["OPTIONS_INSIGHT_ITEM_QUALITY_BORDER"]                           = "Quality border"
-- L["OPTIONS_INSIGHT_ITEM_QUALITY_BORDER_DESC"]                      = "Tint the tooltip border to the item's quality colour (Uncommon green, Rare blue, Epic purple, etc.)."
-- L["OPTIONS_INSIGHT_ITEM_SECTION_SPACING"]                          = "Blank line before blocks"
-- L["OPTIONS_INSIGHT_ITEM_SECTION_SPACING_DESC"]                     = "Insert a blank line before Insight blocks on item tooltips instead of a tinted separator line."
L["OPTIONS_AXIS_ITEM_TOOLTIP"]                                        = "物品提示"
L["OPTIONS_AXIS_TRANSMOG_STATUS"]                                     = "显示幻化状态"
L["OPTIONS_AXIS_WHETHER_YOU_COLLECTED_APPEARANCE_OF_AN"]              = "显示是否已收集鼠标悬停物品的外观"
L["OPTIONS_AXIS_PLAYER_TOOLTIP"]                                      = "玩家提示"
L["OPTIONS_AXIS_GUILD_RANK"]                                          = "显示公会等级"
L["OPTIONS_AXIS_APPEND_PLAYER_S_GUILD_RANK_NEXT"]                     = "在玩家的公会名称旁边附加其公会等级."
L["OPTIONS_AXIS_MYTHIC_SCORE"]                                        = "显示史诗+分数"
L["OPTIONS_AXIS_PLAYER_S_CURRENT_SEASON_MYTHIC_SCORE"]                = "显示玩家当前赛季史诗+分数，按等级颜色编码"
L["OPTIONS_AXIS_ITEM_LEVEL"]                                          = "显示物品等级"
L["OPTIONS_AXIS_PLAYER_S_EQUIPPED_ITEM_LEVEL_AFTER"]                  = "查看玩家后显示其装备物品等级"
L["OPTIONS_AXIS_HONOR_LEVEL"]                                         = "显示荣誉等级"
L["OPTIONS_AXIS_PLAYER_S_PVP_HONOR_LEVEL_TOOLTIP"]                    = "提示中显示玩家PvP荣誉等级"
L["OPTIONS_AXIS_PVP_TITLE"]                                           = "显示PvP称号"
L["OPTIONS_AXIS_PLAYER_S_PVP_TITLE_E_G"]                              = "提示中显示玩家PvP称号(如角斗士)"
-- L["OPTIONS_AXIS_CHARACTER_TITLE"]                                  = "Character title"
-- L["OPTIONS_AXIS_PLAYER_S_SELECTED_TITLE_ACHIEVEMENT_PVP"]          = "Show the player's selected title (achievement or PvP) in the name line."
-- L["OPTIONS_AXIS_TITLE_COLOR"]                                      = "Title color"
-- L["OPTIONS_AXIS_COLOR_OF_CHARACTER_TITLE_PLAYER_TOOLTIP"]          = "Color of the character title in the player tooltip name line."
L["OPTIONS_AXIS_STATUS_BADGES"]                                       = "显示状态徽章"
L["OPTIONS_AXIS_INLINE_BADGES_COMBAT_AFK_DND_PVP"]                    = "显示战斗、暂离、忙碌、PvP标志、队伍/团队成员、好友以及玩家是否正在瞄准您的状态徽章"
L["OPTIONS_AXIS_MOUNT_INFO"]                                          = "显示坐骑信息"
L["OPTIONS_AXIS_HOVERING_A_MOUNTED_PLAYER_THEIR_MOUNT"]               = "悬停已坐骑玩家时显示其坐骑名称、来源及是否拥有"
-- L["OPTIONS_AXIS_BLANK_SEPARATOR"]                                  = "Blank separator"
-- L["OPTIONS_AXIS_A_BLANK_LINE_INSTEAD_OF_DASHES"]                   = "Use a blank line instead of dashes between tooltip sections."
-- L["OPTIONS_AXIS_ICONS"]                                            = "Show icons"
-- L["OPTIONS_AXIS_CLASS_ICON_STYLE"]                                 = "Class icon style"
L["OPTIONS_AXIS_DEFAULT_BLIZZARD_RONDOMEDIA_CLASS_ICONS_TH"]          = "Use Default (Blizzard) or RondoMedia class icons on the class/spec line."
L["OPTIONS_AXIS_CUSTOM_CLASS_ICONS_LABEL"]                            = "Custom (addon media)"
L["OPTIONS_AXIS_CLASS_ICON_SOURCES_TOOLTIP"]                          = "RondoMedia: https://www.curseforge.com/wow/addons/rondomedia — Custom: place one .tga per class under media/CustomClassIcons/<CLASS>/<class lower>.tga (e.g. WARRIOR/warrior.tga), then /reload."
-- L["OPTIONS_AXIS_RONDOMEDIA_CLASS_ICONS_RONDOFERRARI_HTTPS_WWW"]    = "RondoMedia class icons by RondoFerrari — https://www.curseforge.com/wow/addons/rondomedia"
-- L["OPTIONS_AXIS_DEFAULT"]                                          = "Default"
-- L["OPTIONS_AXIS_FACTION_SPEC_MOUNT_MYTHIC_ICONS_TOOLTIPS"]         = "Show faction, spec, mount, and Mythic+ icons in tooltips."
L["OPTIONS_AXIS_GENERAL"]                                             = "常规"
L["OPTIONS_AXIS_POSITION"]                                            = "位置"
L["OPTIONS_AXIS_RESET_POSITION"]                                      = "重置位置"
L["OPTIONS_AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"]                   = "战利品提示位置重置为默认值"

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["OPTIONS_FOCUS_LOCK_POSITION"]                                      = "锁定位置"
L["OPTIONS_FOCUS_PREVENT_DRAGGING_TRACKER"]                           = "防止拖动追踪器"
L["OPTIONS_FOCUS_GROW_UPWARD"]                                        = "向上增长"
L["OPTIONS_FOCUS_GROW_HEADER"]                                        = "向上增长标题"
L["OPTIONS_FOCUS_GROWING_UPWARD_KEEP_HEADER_BOTTOM_TOP"]              = "向上增长时：标题保持在底部，或折叠前保持在顶部"
L["OPTIONS_FOCUS_HEADER_BOTTOM"]                                      = "标题在底部"
L["OPTIONS_FOCUS_HEADER_SLIDES_COLLAPSE"]                             = "折叠时标题滑动"
L["OPTIONS_FOCUS_ANCHOR_BOTTOM_LIST_GROWS_UPWARD"]                    = "底部锚定,列表向上增长"
L["OPTIONS_FOCUS_START_COLLAPSED"]                                    = "开始时折叠"
L["OPTIONS_FOCUS_START_HEADER_SHOWN_UNTIL_YOU_EXPAND"]                = "开始时仅显示标题，展开后显示内容"
-- L["OPTIONS_FOCUS_ALIGN_CONTENT_RIGHT"]                             = "Align content right"
-- L["OPTIONS_FOCUS_RIGHT_ALIGN_QUEST_TITLES_OBJECTIVES_WITHIN"]      = "Right-align quest titles and objectives within the panel."
L["OPTIONS_FOCUS_PANEL_WIDTH"]                                        = "面板宽度"
L["OPTIONS_FOCUS_TRACKER_WIDTH_PIXELS"]                               = "追踪器宽度(像素)"
L["OPTIONS_FOCUS_MAX_CONTENT_HEIGHT"]                                 = "最大内容高度"
L["OPTIONS_FOCUS_MAX_HEIGHT_OF_SCROLLABLE_LIST_PIXELS"]               = "可滚动列表最大高度(像素)"

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["OPTIONS_FOCUS_ALWAYS_M_BLOCK"]                                     = "始终显示史诗+区块"
L["OPTIONS_FOCUS_M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]                = "有活跃钥石运行时显示史诗+块"
L["OPTIONS_FOCUS_DUNGEON"]                                            = "地下城中显示"
L["OPTIONS_FOCUS_TRACKER_PARTY_DUNGEONS"]                             = "队伍地下城中显示追踪器"
L["OPTIONS_FOCUS_RAID"]                                               = "团队副本中显示"
L["OPTIONS_FOCUS_TRACKER_RAIDS"]                                      = "团队副本中显示追踪器"
L["OPTIONS_FOCUS_BATTLEGROUND"]                                       = "战场中显示"
L["OPTIONS_FOCUS_TRACKER_BATTLEGROUNDS"]                              = "战场中显示追踪器"
L["OPTIONS_FOCUS_ARENA"]                                              = "竞技场中显示"
L["OPTIONS_FOCUS_TRACKER_ARENAS"]                                     = "竞技场中显示追踪器"
L["OPTIONS_FOCUS_HIDE_COMBAT"]                                        = "战斗中隐藏"
L["OPTIONS_FOCUS_HIDE_TRACKER_FLOATING_QUEST_ITEM_COMBAT"]            = "战斗中隐藏任务追踪器和浮动任务物品"
L["OPTIONS_FOCUS_COMBAT_VISIBILITY"]                                  = "战斗可见性"
L["OPTIONS_FOCUS_TRACKER_BEHAVES_COMBAT_FADE_REDUC"]                  = "追踪器在战斗中的行为：显示、淡出或隐藏"
L["OPTIONS_FOCUS_SHOW"]                                               = "显示"
L["OPTIONS_FOCUS_FADE"]                                               = "淡化"
L["OPTIONS_FOCUS_HIDE"]                                               = "隐藏"
L["OPTIONS_FOCUS_COMBAT_FADE_OPACITY"]                                = "战斗淡化透明度"
L["OPTIONS_FOCUS_VISIBLE_TRACKER_FADED_COMBAT"]                       = "战斗中追踪器淡出时的可见程度(0 = 不可见)。仅当战斗可见性为淡出时生效"
L["OPTIONS_FOCUS_MOUSEOVER"]                                          = "鼠标悬停"
L["OPTIONS_FOCUS_SHOW_ONLY_MOUSEOVER"]                                = "仅鼠标悬停时显示"
L["OPTIONS_FOCUS_FADE_TRACKER_HOVERING_MOVE_MOUSE"]                   = "鼠标未悬停时淡化追踪器; 将鼠标移上去以显示."
L["OPTIONS_FOCUS_FADED_OPACITY"]                                      = "淡化透明度"
L["OPTIONS_FOCUS_VISIBLE_TRACKER_FADED_INVISIBLE"]                    = "追踪器淡出时的可见程度(0 = 不可见)"
L["OPTIONS_FOCUS_QUESTS_CURRENT_ZONE"]                                = "仅显示当前区域的任务"
L["OPTIONS_FOCUS_HIDE_QUESTS_OUTSIDE_YOUR_CURRENT_ZONE"]              = "隐藏当前区域外的任务"

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["OPTIONS_FOCUS_QUEST_COUNT"]                                        = "显示任务计数"
L["OPTIONS_FOCUS_QUEST_COUNT_HEADER"]                                 = "标题中显示任务计数"
L["OPTIONS_FOCUS_HEADER_COUNT_FORMAT"]                                = "标题计数格式"
L["OPTIONS_FOCUS_TRACKED_LOG_LOG_MAX_SLOTS_TRACKED"]                  = "已追踪/日志中或日志中/最大槽位。已追踪排除世界/区域内实时任务"
L["OPTIONS_FOCUS_HEADER_DIVIDER"]                                     = "显示标题分隔符"
L["OPTIONS_FOCUS_LINE_BELOW_HEADER"]                                  = "标题下方显示线条"
L["OPTIONS_FOCUS_HEADER_DIVIDER_COLOR"]                               = "标题分隔符颜色"
L["OPTIONS_FOCUS_COLOR_OF_LINE_BELOW_HEADER"]                         = "标题栏下方线条的颜色."
L["OPTIONS_FOCUS_SUPER_MINIMAL_MODE"]                                 = "超极简模式"
L["OPTIONS_FOCUS_HIDE_HEADER_A_PURE_TEXT_LIST"]                       = "纯文本列表隐藏标题"
L["OPTIONS_FOCUS_OPTIONS_BUTTON"]                                     = "显示选项按钮"
L["OPTIONS_FOCUS_OPTIONS_BUTTON_TRACKER_HEADER"]                      = "追踪器标题中显示选项按钮"
L["OPTIONS_FOCUS_HEADER_COLOR"]                                       = "标题颜色"
L["OPTIONS_FOCUS_COLOR_OF_OBJECTIVES_HEADER_TEXT"]                    = "目标标题栏文本的颜色."
L["OPTIONS_FOCUS_HEADER_HEIGHT"]                                      = "标题高度"
L["OPTIONS_FOCUS_HEIGHT_OF_HEADER_BAR_PIXELS"]                        = "标题栏高度(像素)(18-48)"

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["OPTIONS_FOCUS_SECTION_HEADERS"]                                    = "显示分类标题"
L["OPTIONS_FOCUS_CATEGORY_LABELS_ABOVE_GROUP"]                        = "每个分组上方显示分类标签"
L["OPTIONS_FOCUS_CATEGORY_HEADERS_COLLAPSED"]                         = "折叠时显示分类标题"
L["OPTIONS_FOCUS_KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED_CLICK"]       = "折叠时保持分类标题可见；点击展开分类"
L["OPTIONS_FOCUS_NEARBY_CURRENT_ZONE_GROUP"]                          = "显示附近(当前区域)分组"
L["OPTIONS_FOCUS_ZONE_QUESTS_A_DEDICATED_CURRENT_ZONE"]               = "在专用当前区域分类中显示区域内任务。关闭时显示在正常分类中"
L["OPTIONS_FOCUS_ZONE_LABELS"]                                        = "显示区域标签"
L["OPTIONS_FOCUS_ZONE_NAME_UNDER_QUEST_TITLE"]                        = "每个任务标题下方显示区域名称"
L["OPTIONS_FOCUS_ACTIVE_QUEST_HIGHLIGHT"]                             = "当前任务高亮"
L["OPTIONS_FOCUS_FOCUSED_QUEST_HIGHLIGHTED"]                          = "聚焦任务的高亮显示方式"
L["OPTIONS_FOCUS_QUEST_ITEM_BUTTONS"]                                 = "显示任务物品按钮"
L["OPTIONS_FOCUS_USABLE_QUEST_ITEM_BUTTON_NEXT_QUEST"]                = "每个任务旁显示可用任务物品按钮"
-- L["OPTIONS_FOCUS_TOOLTIPS_HOVER"]                                  = "Tooltips on hover"
-- L["OPTIONS_FOCUS_TOOLTIPS_HOVERING_TRACKER_ENTRIES_ITE"]           = "Show tooltips when hovering over tracker entries, item buttons, and scenario blocks."
-- L["OPTIONS_FOCUS_WOWHEAD_LINK_TOOLTIPS"]                           = "Show WoWhead link in tooltips"
-- L["OPTIONS_FOCUS_A_TOOLTIP_SHOWN_ADD_A_LINK"]                      = "When a tooltip is shown, add a link to open the quest, achievement, or NPC on WoWhead."
-- L["OPTIONS_FOCUS_VIEW_WOWHEAD"]                                    = "View on WoWhead"
L["OPTIONS_FOCUS_WOWHEAD_ALT_CLICK_HINT"]                             = "Alt+click row to copy"
-- L["OPTIONS_FOCUS_COPY_LINK"]                                       = "Copy link"
-- L["OPTIONS_FOCUS_COPY_URL_BELOW_CTRL_C_PASTE"]                     = "Copy the URL below (Ctrl+C) and paste in your browser."
L["OPTIONS_FOCUS_OBJECTIVE_NUMBERS"]                                  = "显示目标编号"
L["OPTIONS_FOCUS_OBJECTIVE_PREFIX"]                                   = "目标前缀"
-- L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLORS"]                = "Color objective progress numbers"
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLORS_DESC"]              = "Tint X/Y counts: normal color at 0/n, gold while in progress, green when complete. The slash uses the usual objective color."
L["OPTIONS_FOCUS_PREFIX_OBJECTIVE_A_NUMBER_HYPHEN"]                   = "用数字或连字符作为目标前缀"
L["OPTIONS_FOCUS_NUMBERS"]                                            = "数字(1. 2. 3.)"
L["OPTIONS_FOCUS_HYPHENS"]                                            = "连字符(-)"
-- L["OPTIONS_FOCUS_AFTER_SECTION_HEADER"]                            = "After section header"
-- L["OPTIONS_FOCUS_BEFORE_SECTION_HEADER"]                           = "Before section header"
-- L["OPTIONS_FOCUS_BELOW_HEADER"]                                    = "Below header"
L["OPTIONS_FOCUS_INLINE_BELOW_TITLE"]                                 = "标题下方内联"
L["OPTIONS_FOCUS_PREFIX_OBJECTIVES"]                                  = "用 1.、2.、3. 作为目标前缀"
L["OPTIONS_FOCUS_COMPLETED_COUNT"]                                    = "显示已完成计数"
L["OPTIONS_FOCUS_X_Y_PROGRESS_QUEST_TITLE"]                           = "任务标题中显示X/Y进度"
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_BAR"]                             = "显示目标进度条"
L["OPTIONS_FOCUS_A_PROGRESS_BAR_UNDER_OBJECTIVES_NUMER"]              = "在具有数字进度(例如 3/250)的目标下方显示进度条。仅适用于具有单个算术目标且所需数量大于1的条目"
L["OPTIONS_FOCUS_CATEGORY_COLOR_PROGRESS_BAR"]                        = "使用分类颜色作为进度条"
L["OPTIONS_FOCUS_PROGRESS_BAR_MATCHES_QUEST_ACHIEVEME"]               = "启用时进度条与任务/成就分类颜色匹配。禁用时使用下方自定义填充颜色"
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXTURE"]                               = "进度条纹理"
L["OPTIONS_FOCUS_PROGRESS_BAR_TYPES"]                                 = "进度条类型"
L["OPTIONS_FOCUS_TEXTURE_PROGRESS_BAR_FILL"]                          = "进度条填充纹理."
L["OPTIONS_FOCUS_TEXTURE_PROGRESS_BAR_FILL_SOLID_YOUR"]               = "填充纹理. 纯色使用所选颜色. SharedMedia 插件可提供更多选项."
L["OPTIONS_FOCUS_PROGRESS_BAR_X_Y_OBJECTIVES_PERCENT"]                = "为X/Y目标、仅百分比目标或两者显示进度条"
L["OPTIONS_FOCUS_X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]             = "X/Y：如 3/10 的目标。百分比：如 45% 的目标"
L["OPTIONS_FOCUS_X_Y"]                                                = "仅X/Y"
L["OPTIONS_FOCUS_PERCENT"]                                            = "仅百分比"
L["OPTIONS_FOCUS_TICK_COMPLETED_OBJECTIVES"]                          = "已完成目标使用勾号"
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES_A_CHECKMARK_INSTEA"]            = "启用时已完成目标显示勾号(✓)而非绿色"
L["OPTIONS_FOCUS_ENTRY_NUMBERS"]                                      = "显示条目编号"
L["OPTIONS_FOCUS_PREFIX_QUEST_TITLES_WITHIN_CATEGORY"]                = "各分类中用 1.、2.、3. 作为任务标题前缀"
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES"]                               = "已完成目标"
L["OPTIONS_FOCUS_MULTI_OBJECTIVE_QUESTS_DISPLAY_OBJECTIVES"]          = "多目标任务已完成目标的显示方式(例如 1/1)"
L["OPTIONS_FOCUS_ALL"]                                                = "显示全部"
L["OPTIONS_FOCUS_FADE_COMPLETED"]                                     = "淡出已完成"
L["OPTIONS_FOCUS_HIDE_COMPLETED"]                                     = "隐藏已完成"
L["OPTIONS_FOCUS_ICON_ZONE_AUTO_TRACKING"]                            = "显示区域内自动追踪图标"
L["OPTIONS_FOCUS_DISPLAY_AN_ICON_NEXT_AUTO_TRACKED"]                  = "在自动追踪的世界任务和周常/日常任务旁边显示图标, 这些任务尚未在您的任务日志中(仅限区域内)."
L["OPTIONS_FOCUS_AUTO_TRACK_ICON"]                                    = "自动追踪图标"
L["OPTIONS_FOCUS_CHOOSE_WHICH_ICON_DISPLAY_NEXT_AUTO"]                = "选择在自动追踪的区域条目旁边显示哪个图标."
L["OPTIONS_FOCUS_APPEND_WORLD_QUESTS_WEEKLIES_DAILIES"]               = "在尚未在任务日志中的世界任务和周常/日常任务后附加 **(仅限区域内)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["OPTIONS_FOCUS_COMPACT_MODE"]                                       = "紧凑模式"
L["OPTIONS_FOCUS_PRESET_SETS_ENTRY_OBJECTIVE_SPACING_P"]              = "预设：将条目和目标间距设置为4和1像素"
L["OPTIONS_FOCUS_SPACING_PRESET"]                                     = "间距预设"
L["OPTIONS_FOCUS_PRESET_ENTRY_OBJECTIVE_SPACING_DEFAULT_P"]           = "预设: 默认(8/2 px)、紧凑(4/1 px)、宽松(12/3 px)或自定义(使用滑块)."
L["OPTIONS_FOCUS_COMPACT_VERSION"]                                    = "紧凑版本"
L["OPTIONS_FOCUS_SPACED_VERSION"]                                     = "宽松版本"
L["OPTIONS_FOCUS_SPACING_BETWEEN_QUEST_ENTRIES_PX"]                   = "任务条目间间距(像素)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_QUEST_ENTRIES"]                 = "任务条目间垂直间距"
L["OPTIONS_FOCUS_SPACING_BEFORE_CATEGORY_HEADER_PX"]                  = "分类标题前间距(像素)"
L["OPTIONS_FOCUS_GAP_BETWEEN_LAST_ENTRY_OF_A"]                        = "分组末尾条目与下一分类标签之间的间距"
L["OPTIONS_FOCUS_SPACING_AFTER_CATEGORY_HEADER_PX"]                   = "分类标题后间距(像素)"
L["OPTIONS_FOCUS_GAP_BETWEEN_CATEGORY_LABEL_FIRST_QUEST"]             = "分类标签与下方首个任务条目之间的间距"
L["OPTIONS_FOCUS_SPACING_BETWEEN_OBJECTIVES_PX"]                      = "目标间间距(像素)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVE_LINES_WITHIN"]        = "任务内目标行间垂直间距"
L["OPTIONS_FOCUS_TITLE_CONTENT"]                                      = "标题到内容"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_QUEST_TITLE_OBJECTIVES"]        = "任务标题与下方目标或区域之间的垂直间距."
L["OPTIONS_FOCUS_SPACING_BELOW_HEADER_PX"]                            = "标题下方间距(像素)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVES_BAR_QUES"]           = "目标条和任务列表间垂直间距"
L["OPTIONS_FOCUS_RESET_SPACING"]                                      = "重置间距"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_QUEST_LEVEL"]                                   = "显示任务等级"
L["OPTIONS_FOCUS_QUEST_LEVEL_NEXT_TITLE"]                             = "标题旁显示任务等级"
L["OPTIONS_FOCUS_DIM_FOCUSED_QUESTS"]                                 = "淡化非当前任务"
L["OPTIONS_FOCUS_SLIGHTLY_DIM_TITLE_ZONE_OBJECTIVES_SECTION"]         = "稍微淡化未聚焦的标题、区域、目标和分类标题"
L["OPTIONS_FOCUS_DIM_UNFOCUSED_ENTRIES"]                              = "淡化未聚焦条目"
L["OPTIONS_FOCUS_CLICK_A_SECTION_HEADER_EXPAND_CATEGORY"]             = "点击分类标题展开该分类."

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["UI_SHOW_RARE_BOSSES"]                                              = "显示稀有首领"
L["UI_RARE_BOSS_VIGNETTES_LIST"]                                      = "列表中显示稀有首领标记"
L["UI_RARE_LOOT"]                                                     = "稀有战利品"
L["UI_TREASURE_ITEM_VIGNETTES_RARE_LOOT"]                             = "稀有战利品列表中显示宝藏和物品标记"
L["UI_RARE_SOUND_VOLUME"]                                             = "稀有首领声音音量"
L["UI_VOLUME_OF_RARE_ALERT_SOUND"]                                    = "稀有首领警报声音音量(50-200%)"
L["UI_BOOST_REDUCE_RARE_ALERT_VOLUME"]                                = "提升或降低稀有首领警报音量。100% = 正常；150% = 更大声"
L["UI_RARE_ADDED_SOUND"]                                              = "添加稀有首领声音"
L["UI_PLAY_A_SOUND_A_RARE"]                                           = "添加稀有首领时播放声音"
-- L["UI_MINIMAP_PATCH_NOTES_UNREAD_HINT"]                            = "New patch notes — open Axis and choose Patch Notes."

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["OPTIONS_FOCUS_ZONE_WORLD_QUESTS"]                                  = "显示区域内世界任务"
L["OPTIONS_FOCUS_AUTO_ADD_WORLD_QUESTS_YOUR_CURRENT"]                 = "自动添加当前区域的世界任务. 关闭时, 仅显示您已追踪或靠近的世界任务(暴雪默认)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_FLOATING_QUEST_ITEM"]                           = "显示浮动任务物品"
L["OPTIONS_FOCUS_QUICK_BUTTON_FOCUSED_QUEST_S_USABLE"]                = "为聚焦任务的可用物品显示快速使用按钮"
L["OPTIONS_FOCUS_LOCK_FLOATING_QUEST_ITEM_POSITION"]                  = "锁定浮动任务物品位置"
L["OPTIONS_FOCUS_PREVENT_DRAGGING_FLOATING_QUEST_ITEM_BUTTON"]        = "防止拖动浮动任务物品按钮"
L["OPTIONS_FOCUS_FLOATING_QUEST_ITEM_SOURCE"]                         = "浮动任务物品来源"
L["OPTIONS_FOCUS_WHICH_QUEST_S_ITEM_SUPER_TRACKED"]                   = "显示哪个任务的物品：优先显示超级追踪还是当前区域"
L["OPTIONS_FOCUS_SUPER_TRACKED_FIRST"]                                = "超级追踪，然后首个"
L["OPTIONS_FOCUS_CURRENT_ZONE_FIRST"]                                 = "优先当前区域"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["OPTIONS_FOCUS_MYTHIC_BLOCK"]                                       = "显示史诗+块"
L["OPTIONS_FOCUS_TIMER_COMPLETION_AFFIXES_MYTHIC_DUNGEONS"]           = "史诗+地下城显示计时器、完成百分比和词缀"
L["OPTIONS_FOCUS_M_BLOCK_POSITION"]                                   = "史诗+块位置"
L["OPTIONS_FOCUS_POSITION_OF_MYTHIC_BLOCK_RELATIVE_QUEST"]            = "史诗+块相对于任务列表的位置"
L["OPTIONS_FOCUS_AFFIX_ICONS"]                                        = "显示词缀图标"
L["OPTIONS_FOCUS_AFFIX_ICONS_NEXT_MODIFIER_NAMES_M"]                  = "史诗+块中修饰符名称旁显示词缀图标"
L["OPTIONS_FOCUS_AFFIX_DESCRIPTIONS_TOOLTIP"]                         = "提示中显示词缀描述"
L["OPTIONS_FOCUS_AFFIX_DESCRIPTIONS_HOVERING_M_BLO"]                  = "悬停史诗+块时显示词缀描述"
L["OPTIONS_FOCUS_M_COMPLETED_BOSS_DISPLAY"]                           = "史诗+已击败首领显示"
L["OPTIONS_FOCUS_DEFEATED_BOSSES_CHECKMARK_ICON_GREEN"]               = "已击败首领的显示方式：勾选图标或绿色"
L["OPTIONS_FOCUS_CHECKMARK"]                                          = "勾号"
L["OPTIONS_FOCUS_GREEN_COLOR"]                                        = "绿色"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["OPTIONS_PRESENCE_ACHIEVEMENTS"]                                    = "显示成就"
L["OPTIONS_FOCUS_TRACKED_ACHIEVEMENTS_LIST"]                          = "列表中显示追踪的成就"
L["OPTIONS_FOCUS_COMPLETED_ACHIEVEMENTS"]                             = "显示已完成成就"
L["OPTIONS_FOCUS_INCLUDE_COMPLETED_ACHIEVEMENTS_TRACKER_O"]           = "追踪器中包含已完成成就。关闭时仅显示进行中的追踪成就"
L["OPTIONS_FOCUS_ACHIEVEMENT_ICONS"]                                  = "显示成就图标"
L["OPTIONS_FOCUS_ACHIEVEMENT_S_ICON_NEXT_TITLE_REQUI"]                = "在成就标题旁显示图标。需要在显示中启用'显示任务类型图标'"
L["OPTIONS_FOCUS_MISSING_REQUIREMENTS"]                               = "仅显示缺失的要求"
L["OPTIONS_FOCUS_CRITERIA_YOU_HAVEN_T_COMPLETED_TR"]                  = "仅显示每个追踪成就中未完成的标准。关闭时显示所有标准"

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_ENDEAVORS"]                                     = "显示宏图"
L["OPTIONS_FOCUS_TRACKED_ENDEAVORS_PLAYER_HOUSING_LIST"]              = "列表中显示追踪的宏图(玩家住房)"
L["OPTIONS_FOCUS_COMPLETED_ENDEAVORS"]                                = "显示已完成宏图"
L["OPTIONS_FOCUS_INCLUDE_COMPLETED_ENDEAVORS_TRACKER"]                = "追踪器中包含已完成宏图。关闭时仅显示进行中的追踪宏图"

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_DECOR"]                                         = "显示装饰"
L["OPTIONS_FOCUS_TRACKED_HOUSING_DECOR_LIST"]                         = "列表中显示追踪的住房装饰"
L["OPTIONS_FOCUS_DECOR_ICONS"]                                        = "显示装饰图标"
L["OPTIONS_FOCUS_DECOR_ITEM_S_ICON_NEXT_TITLE"]                       = "在装饰物品标题旁显示图标。需要在显示中启用'显示任务类型图标'"

-- =====================================================================
-- OptionsData.lua Features — Appearances
-- =====================================================================
-- L["OPTIONS_FOCUS_SHOW_APPEARANCES"]                                = "Show appearances"
-- L["OPTIONS_FOCUS_TRACKED_TRANSMOG_APPEARANCES_LIST"]               = "Show tracked transmog appearances in the list."
-- L["OPTIONS_FOCUS_INCLUDE_COLLECTED_APPEARANCES_TRACKER"]           = "Include collected appearances in the tracker. When off, only appearances you have not yet collected are shown."
-- L["OPTIONS_FOCUS_APPEARANCE_ICONS"]                                = "Show appearance icons"
-- L["OPTIONS_FOCUS_APPEARANCE_ICON_NEXT_TITLE"]                      = "Show each appearance's icon next to the title. Requires 'Show quest type icons' in Display."
-- L["OPTIONS_FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON"]               = "Use transmog list icon"
-- L["OPTIONS_FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON_DESC"]          = "Use the in-game Appearances / transmog list icon for every row instead of each appearance's item icon. If that icon cannot be resolved, the item icon is used."
-- L["OPTIONS_FOCUS_SHOW_APPEARANCE_WARDROBE"]                        = "Show wardrobe"
-- L["OPTIONS_FOCUS_OPEN_APPEARANCES_COLLECTIONS"]                    = "Open Collections"
-- L["OPTIONS_FOCUS_UNTRACK_APPEARANCE"]                              = "Untrack appearance"
L["OPTIONS_FOCUS_APPEARANCE_HORIZON_CONTROLS_HINT"]                   = "Horizon: Shift-click map, Ctrl-click Collections, Ctrl+Shift-click dressing room. Right-click clears focus or untracks."

-- =====================================================================
-- OptionsData.lua Features — Adventure Guide
-- =====================================================================
L["OPTIONS_FOCUS_ADVENTURE_GUIDE"]                                    = "冒险指南"
L["OPTIONS_FOCUS_TRAVELER_S_LOG"]                                     = "显示旅行者日志"
L["OPTIONS_FOCUS_TRACKED_TRAVELER_S_LOG_OBJECTIVES_SHIFT"]            = "列表中显示追踪的旅行者日志目标(冒险指南中Shift+点击)"
L["OPTIONS_FOCUS_AUTO_REMOVE_COMPLETED_ACTIVITIES"]                   = "自动移除已完成的活动"
L["OPTIONS_FOCUS_AUTOMATICALLY_STOP_TRACKING_TRAVELER_S_LOG"]         = "旅行者日志活动完成后自动停止追踪."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["OPTIONS_FOCUS_SCENARIO_EVENTS"]                                    = "显示场景事件"
L["OPTIONS_FOCUS_ACTIVE_SCENARIO_DELVE_ACTIVITIES_DELVES_APP"]        = "显示活动场景和地下堡活动。地下堡显示在地下堡分类；其他场景显示在场景事件中"
L["OPTIONS_FOCUS_TRACK_DELVE_DUNGEON_SCENARIO_ACTIVITIES"]            = "追踪地下堡、地下城和场景活动"
L["OPTIONS_FOCUS_DELVES_APPEAR_DELVES_SECTION_DUNGEONS_DUNGEON"]      = "地下堡显示在地下堡分类;地下城显示在地下城分类;其他场景显示在场景事件中."
L["OPTIONS_FOCUS_DELVES_APPEAR_DELVES_SECTION_SCENARIOS_S"]           = "地下堡显示在地下堡分类;其他场景显示在场景事件中."
L["OPTIONS_FOCUS_DELVE_AFFIX_NAMES"]                                  = "地下堡词缀名称."
L["OPTIONS_FOCUS_DELVE_DUNGEON"]                                      = "仅地下堡/地下城."
L["OPTIONS_FOCUS_SCENARIO_DEBUG_LOGGING"]                             = "场景调试日志"
L["OPTIONS_FOCUS_LOG_SCENARIO_API_DATA_CHAT_H"]                       = "将场景API数据记录到聊天。使用 /h debug focus scendebug 切换"
L["OPTIONS_FOCUS_PRINTS_C_SCENARIOINFO_CRITERIA_WIDGET_DATA"]         = "场景中打印C_ScenarioInfo条件和小组件数据。有助于诊断显示问题，如丰饶 46/300"
L["OPTIONS_FOCUS_HIDE_CATEGORIES_DELVE_DUNGEON"]                      = "地下堡或地下城中隐藏其他分类"
L["OPTIONS_FOCUS_DELVES_PARTY_DUNGEONS_DELVE_DUNG"]                   = "地下堡或队伍地下城中仅显示地下堡/地下城分类"
L["OPTIONS_FOCUS_DELVE_NAME_SECTION_HEADER"]                          = "使用地下堡名称作为分类标题"
L["OPTIONS_FOCUS_A_DELVE_DELVE_NAME_TIER_AFFIXES"]                    = "地下堡中显示名称、等级和词缀作为分类标题而非单独横幅。禁用以在列表上方显示地下堡块"
L["OPTIONS_FOCUS_AFFIX_NAMES_DELVES"]                                 = "地下堡中显示词缀名称"
L["OPTIONS_FOCUS_SEASON_AFFIX_NAMES_FIRST_DELVE_ENTRY"]               = "首个地下堡条目显示赛季词缀名称。需要暴雪目标追踪器小组件已填充；使用完整追踪器替换时可能不显示"
L["OPTIONS_FOCUS_CINEMATIC_SCENARIO_BAR"]                             = "电影级场景条"
L["OPTIONS_FOCUS_TIMER_PROGRESS_BAR_SCENARIO_ENTRIES"]                = "场景条目显示计时器和进度条"
L["OPTIONS_FOCUS_TIMER"]                                              = "显示计时器"
L["OPTIONS_FOCUS_COUNTDOWN_TIMER_TIMED_QUESTS_EVENTS_SCEN"]           = "计时任务、事件和场景显示倒计时器。关闭时所有条目类型计时器隐藏"
L["OPTIONS_FOCUS_TIMER_SCENARIOS"]                                    = "Timers: scenarios & delves"
L["OPTIONS_FOCUS_TIMER_SCENARIOS_DESC"]                               = "Countdown timer for scenario, delve, and dungeon tracker entries."
L["OPTIONS_FOCUS_TIMER_WORLD"]                                        = "Timers: world & callings"
L["OPTIONS_FOCUS_TIMER_WORLD_DESC"]                                   = "Countdown timer for world quests and callings."
L["OPTIONS_FOCUS_TIMER_QUEST_LOG"]                                    = "Timers: quest log (timed)"
L["OPTIONS_FOCUS_TIMER_QUEST_LOG_DESC"]                               = "Countdown timer for dailies, weeklies, and other quest log entries with a time limit."
L["OPTIONS_FOCUS_TIMER_DISPLAY"]                                      = "计时器显示"
L["OPTIONS_FOCUS_COLOR_TIMER_REMAINING"]                              = "按剩余时间为计时器着色"
L["OPTIONS_FOCUS_GREEN_PLENTY_OF_LEFT_YELLOW_RUNNING"]                = "剩余时间充足为绿色，即将耗尽为黄色，危急为红色"
L["OPTIONS_FOCUS_WHERE_COUNTDOWN_BAR_BELOW_OBJECTIVES"]               = "倒计时显示位置：目标下方条形或任务名称旁文本"
L["OPTIONS_FOCUS_BAR_BELOW"]                                          = "下方条形"
L["OPTIONS_FOCUS_INLINE_BESIDE_TITLE"]                                = "标题旁内联"

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["OPTIONS_FOCUS_FONT_FAMILY"]                                        = "字体"
L["OPTIONS_FOCUS_TITLE_FONT"]                                         = "标题字体"
L["OPTIONS_VISTA_ZONE_FONT"]                                          = "区域字体"
L["OPTIONS_FOCUS_OBJECTIVE_FONT"]                                     = "目标字体"
L["OPTIONS_FOCUS_SECTION_FONT"]                                       = "分类字体"
L["OPTIONS_FOCUS_GLOBAL_FONT"]                                        = "使用全局字体"
L["OPTIONS_FOCUS_FONT_FAMILY_QUEST_TITLES"]                           = "任务标题字体"
L["OPTIONS_FOCUS_FONT_FAMILY_ZONE_LABELS"]                            = "区域标签字体"
L["OPTIONS_FOCUS_FONT_FAMILY_OBJECTIVE_TEXT"]                         = "目标文本字体"
L["OPTIONS_FOCUS_FONT_FAMILY_SECTION_HEADERS"]                        = "分类标题字体"
L["OPTIONS_FOCUS_HEADER_SIZE"]                                        = "标题大小"
L["OPTIONS_FOCUS_HEADER_FONT_SIZE"]                                   = "标题字体大小"
L["OPTIONS_FOCUS_TITLE_SIZE"]                                         = "标题大小"
L["OPTIONS_FOCUS_QUEST_TITLE_FONT_SIZE"]                              = "任务标题字体大小"
L["OPTIONS_FOCUS_OBJECTIVE_SIZE"]                                     = "目标大小"
L["OPTIONS_FOCUS_OBJECTIVE_TEXT_FONT_SIZE"]                           = "目标文本字体大小"
L["OPTIONS_FOCUS_ZONE_SIZE"]                                          = "区域大小"
L["OPTIONS_FOCUS_ZONE_LABEL_FONT_SIZE"]                               = "区域标签字体大小"
L["OPTIONS_FOCUS_SECTION_SIZE"]                                       = "分类大小"
L["OPTIONS_FOCUS_SECTION_HEADER_FONT_SIZE"]                           = "分类标题字体大小"
L["OPTIONS_FOCUS_PROGRESS_BAR_FONT"]                                  = "进度条字体"
L["OPTIONS_FOCUS_FONT_FAMILY_PROGRESS_BAR_LABEL"]                     = "进度条标签字体"
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXT_SIZE"]                             = "进度条文本大小"
L["OPTIONS_FOCUS_FONT_SIZE_PROGRESS_BAR_LABEL_ADJUSTS"]               = "进度条标签字体大小，同时调整进度条高度。影响任务目标、场景进度和场景计时条"
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL"]                                  = "进度条填充"
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXT"]                                  = "进度条文本"
L["OPTIONS_FOCUS_OUTLINE"]                                            = "轮廓"
L["OPTIONS_FOCUS_FONT_OUTLINE_STYLE"]                                 = "字体轮廓样式"

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["OPTIONS_FOCUS_HEADER_TEXT_CASE"]                                   = "标题文本大小写"
L["OPTIONS_FOCUS_DISPLAY_CASE_HEADER"]                                = "标题的大小写格式"
L["OPTIONS_FOCUS_SECTION_HEADER_CASE"]                                = "分类标题大小写"
L["OPTIONS_FOCUS_DISPLAY_CASE_CATEGORY_LABELS"]                       = "分类标签的大小写格式"
L["OPTIONS_FOCUS_QUEST_TITLE_CASE"]                                   = "任务标题大小写"
L["OPTIONS_FOCUS_DISPLAY_CASE_QUEST_TITLES"]                          = "任务标题的大小写格式"

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["OPTIONS_FOCUS_TEXT_SHADOW"]                                        = "显示文本阴影"
L["OPTIONS_FOCUS_ENABLE_DROP_SHADOW_TEXT"]                            = "启用文本阴影."
L["OPTIONS_FOCUS_SHADOW_X"]                                           = "阴影X"
L["OPTIONS_FOCUS_HORIZONTAL_SHADOW_OFFSET"]                           = "水平阴影偏移"
L["OPTIONS_FOCUS_SHADOW_Y"]                                           = "阴影Y"
L["OPTIONS_FOCUS_VERTICAL_SHADOW_OFFSET"]                             = "垂直阴影偏移"
L["OPTIONS_FOCUS_SHADOW_ALPHA"]                                       = "阴影透明度"
L["OPTIONS_FOCUS_SHADOW_OPACITY"]                                     = "阴影不透明度(0-1)"

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["OPTIONS_FOCUS_MYTHIC_TYPOGRAPHY"]                                  = "史诗+排版"
L["OPTIONS_FOCUS_DUNGEON_NAME_SIZE"]                                  = "地下城名称大小"
L["OPTIONS_FOCUS_FONT_SIZE_DUNGEON_NAME_PX"]                          = "地下城名称字体大小(8-32像素)"
L["OPTIONS_FOCUS_DUNGEON_NAME_COLOR"]                                 = "地下城名称颜色"
L["OPTIONS_FOCUS_TEXT_COLOR_DUNGEON_NAME"]                            = "地下城名称文本颜色"
L["OPTIONS_FOCUS_TIMER_SIZE"]                                         = "计时器大小"
L["OPTIONS_FOCUS_FONT_SIZE_TIMER_PX"]                                 = "计时器字体大小(8-32像素)"
L["OPTIONS_FOCUS_TIMER_COLOR"]                                        = "计时器颜色"
L["OPTIONS_FOCUS_TEXT_COLOR_TIMER"]                                   = "计时器文本颜色(在时间内)"
L["OPTIONS_FOCUS_TIMER_OVERTIME_COLOR"]                               = "计时器超时颜色"
L["OPTIONS_FOCUS_TEXT_COLOR_TIMER_LIMIT"]                             = "超时计时器文本颜色"
L["OPTIONS_FOCUS_PROGRESS_SIZE"]                                      = "进度大小"
L["OPTIONS_FOCUS_FONT_SIZE_ENEMY_FORCES_PX"]                          = "敌方部队字体大小(8-32像素)"
L["OPTIONS_FOCUS_PROGRESS_COLOR"]                                     = "进度颜色"
L["OPTIONS_FOCUS_TEXT_COLOR_ENEMY_FORCES"]                            = "敌方部队文本颜色"
L["OPTIONS_FOCUS_BAR_FILL_COLOR"]                                     = "条形填充颜色"
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL_COLOR_PROGRESS"]                   = "进度条填充颜色(进行中)"
L["OPTIONS_FOCUS_BAR_COMPLETE_COLOR"]                                 = "条形完成颜色"
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL_COLOR_ENEMY_FORCES"]               = "敌方部队达到100%时的进度条填充颜色"
L["OPTIONS_FOCUS_AFFIX_SIZE"]                                         = "词缀大小"
L["OPTIONS_FOCUS_FONT_SIZE_AFFIXES_PX"]                               = "词缀字体大小(8-32像素)"
L["OPTIONS_FOCUS_AFFIX_COLOR"]                                        = "词缀颜色"
L["OPTIONS_FOCUS_TEXT_COLOR_AFFIXES"]                                 = "词缀文本颜色"
L["OPTIONS_FOCUS_BOSS_SIZE"]                                          = "首领名称大小"
L["OPTIONS_FOCUS_FONT_SIZE_BOSS_NAMES_PX"]                            = "首领名称字体大小(8-32像素)"
L["OPTIONS_FOCUS_BOSS_COLOR"]                                         = "首领名称颜色"
L["OPTIONS_FOCUS_TEXT_COLOR_BOSS_NAMES"]                              = "首领名称文本颜色"
L["OPTIONS_FOCUS_RESET_MYTHIC_TYPOGRAPHY"]                            = "重置史诗+排版"

-- =====================================================================
-- OptionsData.lua Appearance
-- =====================================================================
-- L["OPTIONS_FOCUS_FRAME"]                                           = "Frame"
-- L["OPTIONS_FOCUS_CLASS_COLOURS_DASHBOARD"]                         = "Class colours - Dashboard"
-- L["OPTIONS_FOCUS_CLASS_COLOURS"]                                   = "Class Colours"
-- L["OPTIONS_FOCUS_ENABLE_CLASS_COLOURS"]                            = "Enable all class colours"
-- L["OPTIONS_FOCUS_TOGGLE_CLASS_COLOURS_MODULES"]                    = "Toggle class colours on or off for all modules at once."
-- L["OPTIONS_FOCUS_DASHBOARD"]                                       = "Dashboard"
-- L["OPTIONS_FOCUS_TINT_FOCUS_HEADER_TITLE_CATEGORY_SECTION"]        = "Tint Focus header title, category section headers, main and between-section dividers, and super-tracked highlight bars and borders with your class colour."
-- L["OPTIONS_FOCUS_TINT_PRESENCE_TOAST_TITLE_DIVIDER_YOUR"]          = "Tint Presence toast title and divider with your class colour."
-- L["OPTIONS_FOCUS_TINT_VISTA_MINIMAP_ADDON_BAR_PANEL"]              = "Tint Vista minimap, addon-bar, and panel borders and text with your class colour."
-- L["OPTIONS_FOCUS_CLASS_COLOUR_PLAYER_TOOLTIP_NAME_CLASS"]          = "Use class colour for player tooltip name, class line, and border."
-- L["OPTIONS_FOCUS_TINT_CACHE_LOOT_ICON_GLOW_EDIT"]                  = "Tint Cache loot icon glow and edit/anchor borders with your class colour."
-- L["OPTIONS_FOCUS_TINT_CHARACTER_NAME_ESSENCE_SHEET_YO"]            = "Tint the character name on the Essence sheet with your class colour."
-- L["OPTIONS_FOCUS_CLASS_COLORS"]                                    = "Class colors"
-- L["OPTIONS_FOCUS_TINT_DASHBOARD_ACCENTS_DIVIDERS_HIGHLIGHTS"]      = "Tint dashboard accents, dividers, and highlights with your class colour."
-- L["OPTIONS_FOCUS_THEME"]                                           = "Theme"
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND"]                            = "Dashboard background"
L["OPTIONS_FOCUS_BACKGROUND_STYLE_MODULE_DASHBOARD_WINDOW_AXI"]       = "Background style for the module dashboard window (Axis). Default is flat; Midnight uses bundled artwork; Specialisation (auto) uses the in-game talent UI background for your current specialization."
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_MINIMALISTIC"]               = "Minimalistic"
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_MIDNIGHT"]                   = "Midnight"
L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_TELDRASSIL_BURNS"]              = "Teldrassil (burning)"
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_NIGHTFAE"]                   = "Night Fae"
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_ARDENWEALD"]                 = "Ardenweald"
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_ZIN_AZSHARI"]                = "Zin-Azshari"
L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_SURAMAR_GARDEN"]                = "Suramar garden"
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_QUELTHALAS"]                 = "Quel'Thalas"
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_TWILIGHT_VINEYARDS"]         = "Twilight Vineyards"
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_ZUL_AMAN"]                   = "Zul'Aman"
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_ILLIDAN"]                    = "Illidan"
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_LICH_KING"]                  = "The Lich King"
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_TBC_ANNIVERSARY"]            = "TBC Anniversary"
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_BELEDARS_LIGHT"]             = "Beledar's Light"
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_CLASS_TALENTS"]              = "Specialisation (auto)"
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_OPACITY"]                    = "Dashboard background opacity"
-- L["OPTIONS_FOCUS_ADJUST_OPACITY_OF_DASHBOARD_BACKGROUND"]          = "Adjust the opacity of the dashboard background (50–100%). Lower values let more of the game world show through."
-- L["DASHBOARD_TYPO_SECTION"]                                        = "Dashboard text"
-- L["DASHBOARD_TYPO_FONT"]                                           = "Dashboard font"
-- L["DASHBOARD_TYPO_FONT_DESC"]                                      = "Font for the Axis settings window (sidebar, search, and option rows). Separate from the Focus tracker font. For CJK or mixed-script welcome text, pick a broad-coverage font (e.g. 2002) if needed."
-- L["DASHBOARD_TYPO_SIZE"]                                           = "Dashboard text size"
-- L["DASHBOARD_TYPO_SIZE_DESC"]                                      = "Nudge all dashboard text larger or smaller (−4 to +4), similar to Focus global font offset."
-- L["DASHBOARD_TYPO_OUTLINE"]                                        = "Dashboard text outline"
L["DASHBOARD_TYPO_OUTLINE_DESC"]                                      = "When on, dashboard UI text uses the standard outlined font style. Turn off for a softer, flat look."
-- L["DASHBOARD_TYPO_SHADOW"]                                         = "Dashboard text shadow"
L["DASHBOARD_TYPO_SHADOW_DESC"]                                       = "Adds a subtle drop shadow behind dashboard text to improve readability on busy backgrounds."
L["OPTIONS_FOCUS_BACKDROP_OPACITY"]                                   = "背景透明度"
L["OPTIONS_FOCUS_PANEL_BACKGROUND_OPACITY"]                           = "面板背景不透明度(0-1)"
L["OPTIONS_FOCUS_BORDER"]                                             = "显示边框"
L["OPTIONS_FOCUS_BORDER_AROUND_TRACKER"]                              = "追踪器周围显示边框"
L["OPTIONS_FOCUS_SCROLL_INDICATOR"]                                   = "显示滚动指示器"
L["OPTIONS_FOCUS_A_VISUAL_HINT_LIST_CONTENT_TH"]                      = "列表有更多内容不可见时显示视觉提示"
L["OPTIONS_FOCUS_SCROLL_INDICATOR_STYLE"]                             = "滚动指示器样式"
L["OPTIONS_FOCUS_CHOOSE_BETWEEN_A_FADE_GRADIENT_A"]                   = "选择渐变或小箭头来指示可滚动内容."
L["OPTIONS_FOCUS_ARROW"]                                              = "箭头"
L["OPTIONS_FOCUS_HIGHLIGHT_ALPHA"]                                    = "高亮透明度"
L["OPTIONS_FOCUS_OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]                 = "聚焦任务高亮的不透明度(0-1)"
L["OPTIONS_FOCUS_BAR_WIDTH"]                                          = "条形宽度"
L["OPTIONS_FOCUS_WIDTH_OF_BAR_STYLE_HIGHLIGHTS_PX"]                   = "进度条高亮宽度(2-6像素)"

-- =====================================================================
-- OptionsData.lua Organization
-- =====================================================================
L["OPTIONS_FOCUS_ACTIVITY"]                                           = "活动"
L["OPTIONS_FOCUS_CONTENT"]                                            = "内容"
L["OPTIONS_FOCUS_SORTING"]                                            = "排序"
-- L["OPTIONS_FOCUS_ELEMENTS"]                                        = "Elements"
L["OPTIONS_FOCUS_CATEGORY_ORDER"]                                     = "聚焦分类顺序"
-- L["OPTIONS_FOCUS_CATEGORY_COLOR_BAR"]                              = "Category color for bar"
-- L["OPTIONS_FOCUS_CHECKMARK_COMPLETED"]                             = "Checkmark for completed"
L["OPTIONS_FOCUS_CURRENT_QUEST_CATEGORY"]                             = "当前任务分类"
L["OPTIONS_FOCUS_CURRENT_QUEST_WINDOW"]                               = "当前任务窗口"
L["OPTIONS_FOCUS_QUESTS_RECENT_PROGRESS_TOP"]                         = "最近有进展的任务显示在顶部"
L["OPTIONS_FOCUS_SECONDS_OF_RECENT_PROGRESS_CURRENT_QUEST"]           = "当前任务中显示的最近进展秒数(30-120)"
L["OPTIONS_FOCUS_QUESTS_YOU_MADE_PROGRESS_LAST_MINUTE"]               = "过去一分钟内有进展的任务显示在专用分类中"
-- L["OPTIONS_FOCUS_SHOW_EVENTS_IN_ZONE"]                             = "Events in Zone section"
L["OPTIONS_FOCUS_SHOW_EVENTS_IN_ZONE_DESC"]                           = "Show the Events in Zone section for nearby unaccepted quests and zone event quests."
L["OPTIONS_FOCUS_SHOW_EVENTS_IN_ZONE_TIP"]                            = "When off, those quests appear in their normal categories instead."
L["OPTIONS_FOCUS_CATEGORY_ORDER"]                                     = "聚焦分类顺序"
L["OPTIONS_FOCUS_DRAG_REORDER_CATEGORIES_DELVES_SCENARIO_EVENT"]      = "拖动以重新排序类别. 地穴和场景事件保持在最前."
-- L["OPTIONS_FOCUS_DRAG_REORDER_DELVES_SCENARIOS_STAY_FIRST"]        = "Drag to reorder. Delves and Scenarios stay first."
L["OPTIONS_FOCUS_SORT_MODE"]                                          = "聚焦排序模式"
L["OPTIONS_FOCUS_ORDER_OF_ENTRIES_WITHIN_CATEGORY"]                   = "各分类中条目的顺序"
L["OPTIONS_FOCUS_AUTO_TRACK_ACCEPTED_QUESTS"]                         = "自动追踪已接受任务"
L["OPTIONS_FOCUS_YOU_ACCEPT_A_QUEST_QUEST_LOG"]                       = "接受任务时(仅任务日志，不包括世界任务)自动添加到追踪器"
L["OPTIONS_FOCUS_REQUIRE_CTRL_FOCUS_REMOVE"]                          = "需要Ctrl键聚焦和移除"
L["OPTIONS_FOCUS_REQUIRE_CTRL_FOCUS_ADD_LEFT_UNFOCUS"]                = "需要Ctrl键聚焦/添加(左键)和取消聚焦/取消追踪(右键)，防止误点击"
L["OPTIONS_FOCUS_CTRL_FOCUS_UNTRACK"]                                 = "Ctrl键用于聚焦/取消追踪"
L["OPTIONS_FOCUS_CTRL_CLICK_COMPLETE"]                                = "Ctrl键点击完成"
L["OPTIONS_FOCUS_CLASSIC_CLICK_BEHAVIOUR"]                            = "使用经典点击行为"
L["OPTIONS_FOCUS_CLASSIC_CLICKS"]                                     = "经典点击模式"
-- === Focus Click Profiles ===
-- L["OPTIONS_FOCUS_CLICK_PROFILE"]                                   = "Click profile"
L["OPTIONS_FOCUS_CLICK_PROFILE_DESC"]                                 = "Choose how mouse clicks on tracker entries behave."
-- L["OPTIONS_FOCUS_PROFILE_HORIZON_PLUS"]                            = "Horizon+"
L["OPTIONS_FOCUS_PROFILE_BLIZZARD_DEFAULT"]                           = "Blizzard Default"
-- L["OPTIONS_FOCUS_PROFILE_CUSTOM"]                                  = "Custom"
-- L["OPTIONS_FOCUS_COMING_SOON"]                                     = "Coming soon"
-- L["OPTIONS_FOCUS_CLICK_COMBOS"]                                    = "Custom bindings"
-- L["OPTIONS_FOCUS_CLICK_COMBO_LOCKED_TOOLTIP"]                      = "Fixed for this profile. Select Custom to edit shortcuts."
-- L["OPTIONS_FOCUS_CLICK_SAFETY"]                                    = "Safety"
-- L["OPTIONS_FOCUS_COMBO_LEFT"]                                      = "Left click"
-- L["OPTIONS_FOCUS_COMBO_SHIFT_LEFT"]                                = "Shift + Left click"
-- L["OPTIONS_FOCUS_COMBO_CTRL_LEFT"]                                 = "Ctrl + Left click"
-- L["OPTIONS_FOCUS_COMBO_ALT_LEFT"]                                  = "Alt + Left click"
-- L["OPTIONS_FOCUS_COMBO_RIGHT"]                                     = "Right click"
-- L["OPTIONS_FOCUS_COMBO_SHIFT_RIGHT"]                               = "Shift + Right click"
-- L["OPTIONS_FOCUS_COMBO_CTRL_RIGHT"]                                = "Ctrl + Right click"
-- L["OPTIONS_FOCUS_CLICK_ACTION_NONE"]                               = "Do nothing"
-- L["OPTIONS_FOCUS_CLICK_ACTION_SUPER_TRACK"]                        = "Focus quest"
-- L["OPTIONS_FOCUS_CLICK_ACTION_OPEN_PROFESSION"]                    = "Open profession or quest details"
-- L["OPTIONS_FOCUS_CLICK_ACTION_OPEN_QUEST_LOG"]                     = "Open quest log"
-- L["OPTIONS_FOCUS_CLICK_ACTION_UNTRACK"]                            = "Untrack"
-- L["OPTIONS_FOCUS_CLICK_ACTION_CONTEXT_MENU"]                       = "Context menu"
-- L["OPTIONS_FOCUS_CLICK_ACTION_SHARE"]                              = "Share with party"
-- L["OPTIONS_FOCUS_CLICK_ACTION_ABANDON"]                            = "Abandon quest"
-- L["OPTIONS_FOCUS_CLICK_ACTION_WOWHEAD"]                            = "WoWhead URL"
-- L["OPTIONS_FOCUS_CLICK_ACTION_CHAT_LINK"]                          = "Link in chat"
-- L["OPTIONS_FOCUS_APPEARANCE_CANNOT_SHARE"]                         = "Appearances cannot be shared like quests."
-- L["OPTIONS_FOCUS_QUEST_DETAILS_AFTER_COMBAT"]                      = "Quest details will open when you leave combat."
L["OPTIONS_FOCUS_SHARE_PARTY"]                                        = "与队伍分享"
L["OPTIONS_FOCUS_ABANDON_QUEST"]                                      = "放弃任务"
L["OPTIONS_FOCUS_STOP_TRACKING"]                                      = "停止追踪"
-- L["OPTIONS_FOCUS_CONTEXT_OPEN_ACHIEVEMENT"]                        = "Open achievement"
-- L["OPTIONS_FOCUS_CONTEXT_OPEN_ENDEAVOR"]                           = "Open endeavor"
-- L["OPTIONS_FOCUS_CONTEXT_OPEN_RECIPE"]                             = "Open recipe"
-- L["OPTIONS_FOCUS_CONTEXT_OPEN_DECOR_CATALOG"]                      = "Open in catalog"
-- L["OPTIONS_FOCUS_CONTEXT_PREVIEW_DECOR"]                           = "Preview decor"
-- L["OPTIONS_FOCUS_CONTEXT_SHOW_DECOR_MAP"]                          = "Show on map"
-- L["OPTIONS_FOCUS_CONTEXT_OPEN_TRAVELERS_LOG"]                      = "Open Traveler's Log"
-- L["OPTIONS_FOCUS_CONTEXT_SET_RARE_WAYPOINT"]                       = "Set waypoint"
-- L["OPTIONS_FOCUS_CONTEXT_CLEAR_RARE_FOCUS"]                        = "Clear map focus"
-- L["OPTIONS_FOCUS_TRACKED_CONTENT_CANNOT_SHARE"]                    = "This entry cannot be shared with the party."
L["OPTIONS_FOCUS_QUEST_CANNOT_SHARED"]                                = "此任务无法分享"
L["OPTIONS_FOCUS_YOU_MUST_A_PARTY_SHARE_QUEST"]                       = "必须在队伍中才能分享此任务"
L["OPTIONS_FOCUS_LEFT_CLICK_OPENS_QUEST_MAP_RIGHT"]                   = "启用时左键打开任务地图，右键显示分享/放弃菜单(暴雪风格)。禁用时左键聚焦，右键取消追踪；Ctrl+右键与队伍分享"
L["OPTIONS_FOCUS_ANIMATIONS"]                                         = "Focus animations"
L["OPTIONS_FOCUS_ENABLE_SLIDE_FADE_QUESTS"]                           = "启用任务滑动和淡出效果"
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_FLASH"]                           = "目标进度闪烁"
L["OPTIONS_FOCUS_FLASH_AN_OBJECTIVE_COMPLETES"]                       = "目标完成时显示闪烁"
L["OPTIONS_FOCUS_FLASH_INTENSITY"]                                    = "闪烁强度"
L["OPTIONS_FOCUS_NOTICEABLE_OBJECTIVE_COMPLETE_FLASH"]                = "目标完成闪烁的明显程度"
L["OPTIONS_FOCUS_FLASH_COLOR"]                                        = "闪烁颜色"
L["OPTIONS_FOCUS_COLOR_OF_OBJECTIVE_COMPLETE_FLASH"]                  = "目标完成闪烁的颜色."
L["OPTIONS_FOCUS_SUBTLE"]                                             = "微妙"
L["OPTIONS_FOCUS_MEDIUM"]                                             = "中等"
L["OPTIONS_FOCUS_STRONG"]                                             = "强"
L["OPTIONS_FOCUS_REQUIRE_CTRL_CLICK_COMPLETE"]                        = "需要Ctrl键点击完成"
L["OPTIONS_FOCUS_REQUIRES_CTRL_LEFT_CLICK_COMPLETE_AUTO"]             = "启用时需要Ctrl+左键完成自动完成任务。禁用时普通左键完成(暴雪默认)。仅影响可通过点击完成的任务(无需NPC提交)"
L["OPTIONS_FOCUS_SUPPRESS_UNTRACKED_UNTIL_RELOAD"]                    = "隐藏未追踪直到重载"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS_Z"]                 = "启用时世界任务和区域内每周/每日任务右键取消追踪会隐藏直到重载或开始新会话。禁用时返回区域时重新出现"
L["OPTIONS_FOCUS_PERMANENTLY_SUPPRESS_UNTRACKED_QUESTS"]              = "永久隐藏未追踪任务"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACKED_WORLD_QUESTS_ZO"]              = "启用时右键取消追踪的世界任务和区域内每周/每日任务永久隐藏(重载后持续)。优先于'隐藏未追踪直到重载'。接受被隐藏任务会从黑名单移除"
L["OPTIONS_FOCUS_KEEP_CAMPAIGN_QUESTS_CATEGORY"]                      = "战役任务保留在分类中"
L["OPTIONS_FOCUS_CAMPAIGN_QUESTS_READY_TURN_RE"]                      = "启用时准备提交的战役任务保留在战役分类而非移动到已完成"
L["OPTIONS_FOCUS_KEEP_IMPORTANT_QUESTS_CATEGORY"]                     = "重要任务保留在分类中"
L["OPTIONS_FOCUS_IMPORTANT_QUESTS_READY_TURN_R"]                      = "启用时准备提交的重要任务保留在重要分类而非移动到已完成"
L["OPTIONS_FOCUS_TOMTOM_QUEST_WAYPOINT"]                              = "TomTom任务航点"
L["OPTIONS_FOCUS_A_TOMTOM_WAYPOINT_FOCUSING_A_QUEST"]                 = "聚焦任务时设置TomTom航点"
L["OPTIONS_FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_NEXT_QUEST"]            = "需要TomTom。箭头指向下一个任务目标"
L["OPTIONS_FOCUS_TOMTOM_RARE_WAYPOINT"]                               = "TomTom稀有航点"
L["OPTIONS_FOCUS_A_TOMTOM_WAYPOINT_CLICKING_A_RARE"]                  = "点击稀有首领时设置TomTom航点"
L["OPTIONS_FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_RARE_S"]                = "需要TomTom。箭头指向稀有首领位置"
L["OPTIONS_FOCUS_FIND_A_GROUP"]                                       = "寻找队伍"
L["OPTIONS_FOCUS_CLICK_SEARCH_A_GROUP_QUEST"]                         = "点击搜索此任务的队伍."

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
L["OPTIONS_FOCUS_BLACKLIST"]                                          = "黑名单"
-- L["OPTIONS_FOCUS_BLACKLIST_UNTRACKED"]                             = "Blacklist untracked"
L["OPTIONS_FOCUS_ENABLE_BLACKLIST_UNTRACKED_BEHAVIOUR_ADD_QUEST"]     = "在行为中启用'黑名单未追踪'添加任务"
L["OPTIONS_FOCUS_HIDDEN_QUESTS"]                                      = "隐藏的任务"
L["OPTIONS_FOCUS_QUESTS_HIDDEN_RIGHT_CLICK_UNTRACK"]                  = "右键取消追踪隐藏的任务"
L["OPTIONS_FOCUS_BLACKLISTED_QUESTS"]                                 = "黑名单任务"
L["OPTIONS_FOCUS_PERMANENTLY_SUPPRESSED_QUESTS"]                      = "永久隐藏的任务"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACK_QUESTS_PERMANENTLY_SUPPRESS"]    = "右键取消追踪任务并启用'永久隐藏未追踪任务'添加到此处"

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["OPTIONS_PRESENCE_QUEST_TYPE_ICONS"]                                = "显示任务类型图标"
L["OPTIONS_PRESENCE_QUEST_TYPE_ICON_FOCUS_TRACKER_QUEST"]             = "聚焦追踪器中显示任务类型图标(任务接受/完成、世界任务、任务更新)"
L["OPTIONS_PRESENCE_QUEST_TYPE_ICONS_TOASTS"]                         = "提示上显示任务类型图标"
L["OPTIONS_PRESENCE_QUEST_TYPE_ICON_PRESENCE_TOASTS_QUEST"]           = "Presence提示上显示任务类型图标(任务接受/完成、世界任务、任务更新)"
L["OPTIONS_PRESENCE_TOAST_ICON_SIZE"]                                 = "提示图标大小"
L["OPTIONS_PRESENCE_QUEST_ICON_SIZE_PRESENCE_TOASTS_PX"]              = "Presence提示上的任务图标大小(16-36像素)。默认24"
L["OPTIONS_PRESENCE_HIDE_QUEST_UPDATE_TITLE"]                         = "隐藏任务更新标题"
L["OPTIONS_PRESENCE_OBJECTIVE_LINE_QUEST_PROGRESS_TOAST"]             = "任务进度提示仅显示目标行(如 7/10 野猪皮)，不显示任务名称或标题"
L["OPTIONS_PRESENCE_SHOW_DISCOVERY_LINE"]                             = "显示发现提示行"
L["OPTIONS_PRESENCE_DISCOVERY_LINE"]                                  = "发现提示行"
L["OPTIONS_PRESENCE_DISCOVERED_UNDER_ZONE_SUBZONE_ENTERING_A"]        = "进入新区域时在区域/子区域下方显示'已发现'"
L["OPTIONS_PRESENCE_FRAME_VERTICAL_POSITION"]                         = "框架垂直位置"
L["OPTIONS_PRESENCE_VERTICAL_OFFSET_OF_PRESENCE_FRAME_CENTER"]        = "Presence框架从中心的垂直偏移(-300到0)"
L["OPTIONS_PRESENCE_FRAME_SCALE"]                                     = "框架缩放"
L["OPTIONS_PRESENCE_SCALE_OF_PRESENCE_FRAME"]                         = "Presence框架缩放(0.5-2)"
L["OPTIONS_PRESENCE_BOSS_EMOTE_COLOR"]                                = "首领表情颜色"
L["OPTIONS_PRESENCE_COLOR_OF_RAID_DUNGEON_BOSS_EMOTE"]                = "团队副本和地下城 Boss 表情文本的颜色"
L["OPTIONS_PRESENCE_DISCOVERY_LINE_COLOR"]                            = "发现提示行颜色"
L["OPTIONS_PRESENCE_COLOR_OF_DISCOVERED_LINE_UNDER_ZONE"]             = "区域文本下方 '已发现' 行的颜色"
L["OPTIONS_PRESENCE_NOTIFICATION_TYPES"]                              = "通知类型"
L["OPTIONS_PRESENCE_NOTIFICATIONS"]                                   = "通知"
L["OPTIONS_PRESENCE_NOTIFICATION_ACHIEVEMENT_CRITERIA_UPDATE_T"]      = "成就条件更新时显示通知(追踪的成就始终显示；其他在暴雪提供成就ID时显示)"
L["OPTIONS_PRESENCE_ZONE_ENTRY"]                                      = "显示区域条目"
L["OPTIONS_PRESENCE_ZONE_CHANGE_ENTERING_A_AREA"]                     = "进入新区域时显示区域变更"
L["OPTIONS_PRESENCE_SUBZONE_CHANGES"]                                 = "显示子区域变更"
L["OPTIONS_PRESENCE_SUBZONE_CHANGE_MOVING_WITHIN_SAME_ZONE"]          = "同一区域内移动时显示子区域变更"
L["OPTIONS_PRESENCE_HIDE_ZONE_NAME_SUBZONE_CHANGES"]                  = "子区域变更时隐藏区域名称"
L["OPTIONS_PRESENCE_MOVING_BETWEEN_SUBZONES_WITHIN_SAME_ZONE"]        = "同一区域内子区域间移动时仅显示子区域名称。进入新区域时区域名称仍会出现"
-- L["OPTIONS_PRESENCE_SUPPRESS_DELVE"]                               = "Suppress in Delve"
-- L["OPTIONS_PRESENCE_SUPPRESS_SCENARIO_PROGRESS_NOTIFICATIONS_DELVES"]= "Suppress scenario progress notifications in Delves."
-- L["OPTIONS_PRESENCE_HIDES_OBJECTIVE_UPDATE_POPUPS_WHILE_A"]        = "When on, hides objective update popups while in a Delve. Zone entry and completion toasts still show."
L["OPTIONS_PRESENCE_SUPPRESS_ZONE_CHANGES_MYTHIC"]                    = "史诗+中隐藏区域变更"
L["OPTIONS_PRESENCE_MYTHIC_BOSS_EMOTES_ACHIEVEMENTS_LEV"]             = "史诗+中仅显示首领表情、成就和升级。隐藏区域、任务和场景通知"
L["OPTIONS_PRESENCE_LEVEL"]                                           = "显示升级"
L["OPTIONS_PRESENCE_LEVEL_NOTIFICATION"]                              = "显示升级通知"
L["OPTIONS_PRESENCE_BOSS_EMOTES"]                                     = "显示首领表情"
L["OPTIONS_PRESENCE_RAID_DUNGEON_BOSS_EMOTE_NOTIFICATIONS"]           = "显示团队副本和地下城首领表情通知"
L["OPTIONS_PRESENCE_ACHIEVEMENTS"]                                    = "显示成就"
L["OPTIONS_PRESENCE_ACHIEVEMENT_EARNED_NOTIFICATIONS"]                = "显示成就获得通知"
L["OPTIONS_PRESENCE_ACHIEVEMENT_PROGRESS"]                            = "成就进度"
L["OPTIONS_PRESENCE_ACHIEVEMENT_EARNED"]                              = "获得成就"
L["OPTIONS_PRESENCE_QUEST_ACCEPTED"]                                  = "任务已接受"
L["OPTIONS_PRESENCE_WORLD_QUEST_ACCEPTED"]                            = "世界任务已接受"
L["OPTIONS_PRESENCE_SCENARIO_COMPLETE"]                               = "场景完成"
L["OPTIONS_PRESENCE_RARE_DEFEATED"]                                   = "稀有精英已击败"
L["OPTIONS_PRESENCE_NOTIFICATION_TRACKED_ACHIEVEMENT_CRITERIA"]       = "追踪成就条件更新时显示通知"
L["OPTIONS_PRESENCE_QUEST_ACCEPT"]                                    = "显示任务接受"
L["OPTIONS_PRESENCE_NOTIFICATION_ACCEPTING_A_QUEST"]                  = "接受任务时显示通知"
L["OPTIONS_PRESENCE_WORLD_QUEST_ACCEPT"]                              = "显示世界任务接受"
L["OPTIONS_PRESENCE_NOTIFICATION_ACCEPTING_A_WORLD_QUEST"]            = "接受世界任务时显示通知"
L["OPTIONS_PRESENCE_QUEST_COMPLETE"]                                  = "显示任务完成"
L["OPTIONS_PRESENCE_NOTIFICATION_COMPLETING_A_QUEST"]                 = "完成任务时显示通知"
L["OPTIONS_PRESENCE_WORLD_QUEST_COMPLETE"]                            = "显示世界任务完成"
L["OPTIONS_PRESENCE_NOTIFICATION_COMPLETING_A_WORLD_QUEST"]           = "完成世界任务时显示通知"
L["OPTIONS_PRESENCE_QUEST_PROGRESS"]                                  = "显示任务进度"
L["OPTIONS_PRESENCE_NOTIFICATION_QUEST_OBJECTIVES_UPDATE"]            = "任务目标更新时显示通知"
L["OPTIONS_PRESENCE_OBJECTIVE"]                                       = "仅目标"
L["OPTIONS_PRESENCE_QUEST_PROGRESS_HIDE_TITLE"]                       = "任务进度提示仅显示目标行，隐藏'任务更新'标题"
L["OPTIONS_PRESENCE_SCENARIO_START"]                                  = "显示场景开始"
L["OPTIONS_PRESENCE_NOTIFICATION_ENTERING_A_SCENARIO_DELVE"]          = "进入场景或地下堡时显示通知"
L["OPTIONS_PRESENCE_SCENARIO_PROGRESS"]                               = "显示场景进度"
L["OPTIONS_PRESENCE_NOTIFICATION_SCENARIO_DELVE_OBJECTIVES"]          = "场景或地下堡目标更新时显示通知"
L["OPTIONS_PRESENCE_ANIMATION"]                                       = "动画"
L["OPTIONS_PRESENCE_ENABLE_ANIMATIONS"]                               = "启用动画"
L["OPTIONS_PRESENCE_ENABLE_ENTRANCE_EXIT_ANIMATIONS_PRESENCE"]        = "为 Presence 通知启用进入和退出动画"
L["OPTIONS_PRESENCE_ENTRANCE_DURATION"]                               = "进入持续时间"
L["OPTIONS_PRESENCE_DURATION_OF_ENTRANCE_ANIMATION_SECONDS"]          = "进入动画的持续时间(秒)(0.2–1.5)"
L["OPTIONS_PRESENCE_EXIT_DURATION"]                                   = "退出持续时间"
L["OPTIONS_PRESENCE_DURATION_OF_EXIT_ANIMATION_SECONDS"]              = "退出动画的持续时间(秒)(0.2–1.5)"
L["OPTIONS_PRESENCE_HOLD_DURATION_SCALE"]                             = "持续时间缩放"
L["OPTIONS_PRESENCE_MULTIPLIER_LONG_NOTIFICATION_STAYS_S"]            = "通知屏幕停留时间倍数(0.5-2)"
-- L["OPTIONS_PRESENCE_PREVIEW"]                                      = "Preview"
-- L["OPTIONS_PRESENCE_PREVIEW_TOAST_TYPE"]                           = "Preview toast type"
-- L["OPTIONS_PRESENCE_SELECT_A_TOAST_TYPE_PREVIEW"]                  = "Select a toast type to preview."
-- L["OPTIONS_PRESENCE_SELECTED_TOAST_TYPE"]                          = "Show the selected toast type."
-- L["OPTIONS_PRESENCE_PREVIEW_PRESENCE_TOAST_LAYOUTS_LIVE_OPEN"]     = "Preview Presence toast layouts live and open a detachable sample while adjusting other settings."
-- L["OPTIONS_PRESENCE_OPEN_DETACHED_PREVIEW"]                        = "Open detached preview"
-- L["OPTIONS_PRESENCE_OPEN_A_MOVABLE_PREVIEW_WINDOW_STAYS"]          = "Open a movable preview window that stays visible while you change other Presence settings."
-- L["OPTIONS_PRESENCE_ANIMATE_PREVIEW"]                              = "Animate preview"
-- L["OPTIONS_PRESENCE_PLAY_SELECTED_TOAST_ANIMATION_INSIDE_PREVIE"]  = "Play the selected toast animation inside this preview window."
-- L["OPTIONS_PRESENCE_DETACHED_PREVIEW"]                             = "Detached preview"
-- L["OPTIONS_PRESENCE_KEEP_OPEN_WHILE_ADJUSTING_TYPOGRAPHY_COLORS"]  = "Keep this open while adjusting Typography or Colors."
L["DASH_TYPOGRAPHY"]                                                  = "排版"
L["OPTIONS_PRESENCE_MAIN_TITLE_FONT"]                                 = "主标题字体"
L["OPTIONS_PRESENCE_FONT_FAMILY_MAIN_TITLE"]                          = "主标题字体"
L["OPTIONS_PRESENCE_SUBTITLE_FONT"]                                   = "副标题字体"
L["OPTIONS_PRESENCE_FONT_FAMILY_SUBTITLE"]                            = "副标题字体"
-- L["OPTIONS_PRESENCE_RESET_TYPOGRAPHY_DEFAULTS"]                    = "Reset typography to defaults"
-- L["OPTIONS_PRESENCE_RESET_PRESENCE_TYPOGRAPHY_OPTIONS_FONTS_SIZES"]= "Reset all Presence typography options (fonts, sizes, colors) to defaults."
-- L["OPTIONS_PRESENCE_LARGE_NOTIFICATIONS"]                          = "Large notifications"
-- L["OPTIONS_PRESENCE_MEDIUM_NOTIFICATIONS"]                         = "Medium notifications"
-- L["OPTIONS_PRESENCE_SMALL_NOTIFICATIONS"]                          = "Small notifications"
-- L["OPTIONS_PRESENCE_LARGE_PRIMARY_SIZE"]                           = "Large primary size"
-- L["OPTIONS_PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_TITLES_ZONE"]     = "Font size for large notification titles (zone, quest complete, achievement, etc.)."
-- L["OPTIONS_PRESENCE_LARGE_SECONDARY_SIZE"]                         = "Large secondary size"
-- L["OPTIONS_PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_SUBTITLES"]       = "Font size for large notification subtitles."
-- L["OPTIONS_PRESENCE_MEDIUM_PRIMARY_SIZE"]                          = "Medium primary size"
-- L["OPTIONS_PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_TITLES_QUEST"]   = "Font size for medium notification titles (quest accept, subzone, scenario)."
-- L["OPTIONS_PRESENCE_MEDIUM_SECONDARY_SIZE"]                        = "Medium secondary size"
-- L["OPTIONS_PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_SUBTITLES"]      = "Font size for medium notification subtitles."
-- L["OPTIONS_PRESENCE_SMALL_PRIMARY_SIZE"]                           = "Small primary size"
-- L["OPTIONS_PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_TITLES_QUEST"]    = "Font size for small notification titles (quest progress, achievement progress)."
-- L["OPTIONS_PRESENCE_SMALL_SECONDARY_SIZE"]                         = "Small secondary size"
-- L["OPTIONS_PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_SUBTITLES"]       = "Font size for small notification subtitles."

-- =====================================================================
-- OptionsData.lua Dropdown options — Outline
-- =====================================================================
L["OPTIONS_FOCUS_NONE"]                                               = "无"
L["OPTIONS_FOCUS_THICK_OUTLINE"]                                      = "粗轮廓"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["OPTIONS_FOCUS_BAR_LEFT_EDGE"]                                      = "条 (左边缘)"
L["OPTIONS_FOCUS_BAR_RIGHT_EDGE"]                                     = "条 (右边缘)"
L["OPTIONS_FOCUS_BAR_TOP_EDGE"]                                       = "条 (上边缘)"
L["OPTIONS_FOCUS_BAR_BOTTOM_EDGE"]                                    = "条 (下边缘)"
L["OPTIONS_FOCUS_OUTLINE_ONLY_STYLE"]                                 = "仅轮廓"
L["OPTIONS_FOCUS_SOFT_GLOW"]                                          = "柔和发光"
L["OPTIONS_FOCUS_DUAL_EDGE_BARS"]                                     = "双边缘条"
L["OPTIONS_FOCUS_PILL_LEFT_ACCENT"]                                   = "标签左侧强调"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["OPTIONS_FOCUS_TOP"]                                                = "顶部"
L["OPTIONS_FOCUS_BOTTOM"]                                             = "底部"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["OPTIONS_VISTA_LOCATION_POSITION"]                                  = "位置"
L["OPTIONS_VISTA_PLACE_ZONE_NAME_ABOVE_BELOW_MINIMAP"]                = "区域名称放置在小地图上方或下方"
L["OPTIONS_VISTA_COORDINATES_POSITION"]                               = "坐标位置"
L["OPTIONS_VISTA_PLACE_COORDINATES_ABOVE_BELOW_MINIMAP"]              = "坐标放置在小地图上方或下方"
L["OPTIONS_VISTA_CLOCK_POSITION"]                                     = "时钟位置"
L["OPTIONS_VISTA_PLACE_CLOCK_ABOVE_BELOW_MINIMAP"]                    = "时钟放置在小地图上方或下方"

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["OPTIONS_FOCUS_LOWER_CASE"]                                         = "小写"
L["OPTIONS_FOCUS_UPPER_CASE"]                                         = "大写"
L["OPTIONS_FOCUS_PROPER"]                                             = "标准"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["OPTIONS_FOCUS_TRACKED_LOG"]                                        = "已追踪/日志中"
L["OPTIONS_FOCUS_LOG_MAX_SLOTS"]                                      = "日志中/最大槽位"

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["OPTIONS_FOCUS_ALPHABETICAL"]                                       = "字母顺序"
L["OPTIONS_FOCUS_QUEST_TYPE"]                                         = "任务类型"
L["OPTIONS_FOCUS_QUEST_LEVEL"]                                        = "任务等级"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["OPTIONS_FOCUS_CUSTOM"]                                             = "自定义"
L["OPTIONS_FOCUS_ORDER"]                                              = "顺序"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["UI_DUNGEON"]                                                       = "地下城"
L["UI_RAID"]                                                          = "团队副本"
L["UI_DELVES"]                                                        = "地下堡"
L["UI_SCENARIO_EVENTS"]                                               = "场景事件"
-- L["UI_STAGE"]                                                      = "Stage"
-- L["UI_STAGE_X_X"]                                                  = "Stage %d: %s"
L["UI_AVAILABLE_IN_ZONE"]                                             = "区域内可用"
L["UI_EVENTS_IN_ZONE"]                                                = "区域内事件"
L["UI_CURRENT_EVENT"]                                                 = "当前事件"
L["UI_CURRENT_QUEST"]                                                 = "当前任务"
L["UI_CURRENT_ZONE"]                                                  = "当前区域"
L["UI_CAMPAIGN"]                                                      = "战役"
L["UI_IMPORTANT"]                                                     = "重要"
L["UI_LEGENDARY"]                                                     = "传说"
L["UI_WORLD_QUESTS"]                                                  = "世界任务"
L["UI_WEEKLY_QUESTS"]                                                 = "每周任务"
L["UI_PREY"]                                                          = "猎物"
L["UI_ABUNDANCE"]                                                     = "丰裕"
L["UI_ABUNDANCE_BAG"]                                                 = "丰裕之袋"
L["UI_ABUNDANCE_HELD"]                                                = "已持有丰裕"
L["UI_DAILY_QUESTS"]                                                  = "日常任务"
L["UI_RARE_BOSSES"]                                                   = "稀有首领"
L["UI_ACHIEVEMENTS"]                                                  = "成就"
L["UI_ENDEAVORS"]                                                     = "宏图"
L["UI_DECOR"]                                                         = "装饰"
-- L["UI_RECIPES"]                                                    = "Recipes"
-- L["UI_ADVENTURE_GUIDE"]                                            = "Adventure Guide"
-- L["UI_APPEARANCES"]                                                = "Appearances"
L["UI_QUESTS"]                                                        = "任务"
L["UI_READY_TO_TURN_IN"]                                              = "准备提交"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["PRESENCE_OBJECTIVES"]                                              = "目标"
L["PRESENCE_OPTIONS"]                                                 = "选项"
L["PRESENCE_OPEN_HORIZON_SUITE"]                                      = "打开 Horizon Suite"
L["PRESENCE_OPEN_FULL_HORIZON_SUITE_OPTIONS"]                         = "打开完整的 Horizon Suite 选项面板以配置 Focus、Presence、Vista 和其他模块。"
L["PRESENCE_SHOW_MINIMAP_ICON"]                                       = "显示小地图图标"
L["PRESENCE_A_CLICKABLE_ICON_MINIMAP_OPENS"]                          = "在小地图上显示可点击的图标以打开选项面板。"
-- L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER"]              = "Fade until minimap hover"
-- L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER_DESC"]         = "When on, the icon stays faded until you move the cursor over the minimap. When off, it stays fully visible."
-- L["PRESENCE_LOCK_MINIMAP_BUTTON_POSITION"]                         = "Lock minimap button position"
-- L["PRESENCE_PREVENT_DRAGGING_HORIZON_MINIMAP_BUTTON"]              = "Prevent dragging the Horizon minimap button."
-- L["PRESENCE_RESET_MINIMAP_BUTTON_POSITION"]                        = "Reset minimap button position"
-- L["PRESENCE_RESET_MINIMAP_BUTTON_DEFAULT_POSITION"]                = "Reset the minimap button to the default position (bottom-left)."
-- L["PRESENCE_DRAG_TO_MOVE_WHEN_UNLOCKED"]                           = "Drag to move (when unlocked)."
-- L["PRESENCE_LOCKED"]                                               = "Locked"
L["PRESENCE_DISCOVERED"]                                              = "已发现"
L["PRESENCE_REFRESH"]                                                 = "刷新"
L["PRESENCE_BEST_EFFORT_UNACCEPTED_QUESTS_EXPO"]                      = "仅尽力而为. 某些未接受的任务直到与NPC交互或满足阶段条件才会显示"
L["PRESENCE_UNACCEPTED_QUESTS_X_MAP_X"]                               = "未接受任务 - %s(地图 %s)- %d 个匹配"
L["PRESENCE_LEVEL_UP"]                                                = "升级"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_80"]                               = "已达到等级80"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_X"]                                = "已达到等级 %s"
L["PRESENCE_ACHIEVEMENT_EARNED"]                                      = "获得成就"
L["PRESENCE_EXPLORING_THE_MIDNIGHT_ISLES"]                            = "探索午夜群岛"
L["PRESENCE_EXPLORING_KHAZ_ALGAR"]                                    = "探索卡兹阿加尔"
L["PRESENCE_QUEST_COMPLETE"]                                          = "任务完成"
L["PRESENCE_OBJECTIVE_SECURED"]                                       = "目标已锁定"
L["PRESENCE_AIDING_THE_ACCORD"]                                       = "援助协定"
L["PRESENCE_WORLD_QUEST"]                                             = "世界任务"
L["PRESENCE_WORLD_QUEST_COMPLETE"]                                    = "世界任务完成"
L["PRESENCE_AZERITE_MINING"]                                          = "艾泽里特矿石"
L["PRESENCE_WORLD_QUEST_ACCEPTED"]                                    = "世界任务已接受"
L["PRESENCE_QUEST_ACCEPTED"]                                          = "任务已接受"
L["PRESENCE_THE_FATE_OF_THE_HORDE"]                                   = "部落的命运"
L["PRESENCE_NEW_QUEST"]                                               = "新任务"
L["PRESENCE_QUEST_UPDATE"]                                            = "任务更新"
L["PRESENCE_BOAR_PELTS_7_10"]                                         = "野猪皮: 7/10"
L["PRESENCE_DRAGON_GLYPHS_3_5"]                                       = "龙之符文: 3/5"
L["PRESENCE_PRESENCE_TEST_COMMANDS"]                                  = "情境测试命令："
L["PRESENCE_H_PRESENCE_DEBUGTYPES_DUMP_NOTIFICATION"]                 = "  /h presence debugtypes - 显示通知开关和暴雪抑制状态"
L["PRESENCE_PRESENCE_PLAYING_DEMO_REEL_NOTIFICATION"]                 = "情境：播放演示(所有通知类型)..."
L["PRESENCE_H_PRESENCE_HELP_TEST_CURRENT"]                            = "  /h presence         - 显示帮助 + 测试当前区域"
L["PRESENCE_H_PRESENCE_ZONE_TEST_ZONE"]                               = "  /h presence zone     - 测试区域变更"
L["PRESENCE_H_PRESENCE_SUBZONE_TEST_SUBZONE"]                         = "  /h presence subzone  - 测试子区域变更"
L["PRESENCE_H_PRESENCE_DISCOVER_TEST_ZONE"]                           = "  /h presence discover - 测试区域发现"
L["PRESENCE_H_PRESENCE_LEVEL_TEST_LEVEL"]                             = "  /h presence level    - 测试升级"
L["PRESENCE_H_PRESENCE_BOSS_TEST_BOSS"]                               = "  /h presence boss     - 测试Boss表情"
L["PRESENCE_H_PRESENCE_ACH_TEST_ACHIEVEMENT"]                         = "  /h presence ach      - 测试成就"
L["PRESENCE_H_PRESENCE_ACCEPT_TEST_QUEST"]                            = "  /h presence accept   - 测试接受任务"
L["PRESENCE_H_PRESENCE_WQACCEPT_TEST_WORLD"]                          = "  /h presence wqaccept - 测试接受世界任务"
L["PRESENCE_H_PRESENCE_SCENARIO_TEST_SCENARIO"]                       = "  /h presence scenario - 测试场景开始"
L["PRESENCE_H_PRESENCE_QUEST_TEST_QUEST"]                             = "  /h presence quest    - 测试任务完成"
L["PRESENCE_H_PRESENCE_WQ_TEST_WORLD"]                                = "  /h presence wq       - 测试世界任务"
L["PRESENCE_H_PRESENCE_UPDATE_TEST_QUEST"]                            = "  /h presence update   - 测试任务更新"
L["PRESENCE_H_PRESENCE_ACHPROGRESS_TEST_ACHIEVEMENT"]                 = "  /h presence achprogress - 测试成就进度"
L["PRESENCE_H_PRESENCE_DEMO_REEL_TYPES"]                              = "  /h presence all      - 演示卷轴(所有类型)"
L["PRESENCE_H_PRESENCE_DEBUG_DUMP_STATE"]                             = "  /h presence debug    - 转储状态到聊天"
L["PRESENCE_H_PRESENCE_DEBUGLIVE_TOGGLE_LIVE"]                        = "  /h presence debuglive - 切换实时调试面板(记录事件)"

-- =====================================================================
-- OptionsData.lua Vista — General
L["OPTIONS_VISTA_POSITION_LAYOUT"]                                    = "位置和布局"

-- =====================================================================
L["OPTIONS_VISTA_MINIMAP"]                                            = "小地图"
L["OPTIONS_VISTA_MINIMAP_SIZE"]                                       = "小地图大小"
L["OPTIONS_VISTA_WIDTH_HEIGHT_OF_MINIMAP_PIXELS"]                     = "小地图宽度和高度(像素)(100-400)"
L["OPTIONS_VISTA_CIRCULAR_MINIMAP"]                                   = "圆形小地图"
L["OPTIONS_VISTA_CIRCULAR_SHAPE"]                                     = "圆形."
L["OPTIONS_VISTA_A_CIRCULAR_MINIMAP_INSTEAD_OF_SQUARE"]               = "使用圆形小地图而非方形"
L["OPTIONS_VISTA_LOCK_MINIMAP_POSITION"]                              = "锁定小地图位置"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MINIMAP"]                           = "防止拖动小地图"
L["OPTIONS_VISTA_RESET_MINIMAP_POSITION"]                             = "重置小地图位置"
L["OPTIONS_VISTA_RESET_MINIMAP_DEFAULT_POSITION_TOP_RIGHT"]           = "小地图重置为默认位置(右上角)"
-- L["OPTIONS_VISTA_RESET_OVERLAY_POSITIONS"]                         = "Reset overlay positions to defaults"
L["OPTIONS_VISTA_RESET_OVERLAY_POSITIONS_DESC"]                       = "Clear saved positions for zone text, coordinates, clock, performance and difficulty text, zoom buttons, tracking, calendar, queue, mail, the addon button bar, drawer button, and right-click panel. The minimap frame position is not changed."
L["OPTIONS_VISTA_AUTO_ZOOM"]                                          = "自动缩放"
L["OPTIONS_VISTA_AUTO_ZOOM_DELAY"]                                    = "自动缩出延迟"
L["OPTIONS_VISTA_SECONDS_AFTER_ZOOMING_BEFORE_AUTO_ZOOM"]             = "缩放后自动缩小的延迟秒数。设置为0禁用"

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["OPTIONS_VISTA_ZONE_TEXT_HEADER"]                                   = "区域文本"
L["OPTIONS_VISTA_ZONE_FONT"]                                          = "区域字体"
L["OPTIONS_VISTA_FONT_ZONE_NAME_BELOW_MINIMAP"]                       = "小地图下方区域名称字体"
L["OPTIONS_VISTA_ZONE_FONT_SIZE"]                                     = "区域字体大小"
L["OPTIONS_VISTA_ZONE_TEXT_COLOR"]                                    = "区域文本颜色"
L["OPTIONS_VISTA_COLOR_OF_ZONE_NAME_TEXT"]                            = "区域名称文本的颜色"
L["OPTIONS_VISTA_COORDINATES_TEXT"]                                   = "坐标文本"
L["OPTIONS_VISTA_COORDINATES_FONT"]                                   = "坐标字体"
L["OPTIONS_VISTA_FONT_COORDINATES_TEXT_BELOW_MINIMAP"]                = "小地图下方坐标文本字体"
L["OPTIONS_VISTA_COORDINATES_FONT_SIZE"]                              = "坐标字体大小"
L["OPTIONS_VISTA_COORDINATES_TEXT_COLOR"]                             = "坐标文本颜色"
L["OPTIONS_VISTA_COLOR_OF_COORDINATES_TEXT"]                          = "坐标文本的颜色"
L["OPTIONS_VISTA_COORDINATE_PRECISION"]                               = "坐标精度"
L["OPTIONS_VISTA_NUMBER_OF_DECIMAL_PLACES_SHOWN_X"]                   = "X和Y坐标显示的小数位数"
L["OPTIONS_VISTA_COORDS_DECIMALS_OFF"]                                = "无小数(例如 52, 37)"
L["OPTIONS_VISTA_DECIMAL_E_G"]                                        = "1 位小数 (例如 52.3, 37.1)"
L["OPTIONS_VISTA_DECIMALS_E_G"]                                       = "2 位小数 (例如 52.34, 37.12)"
L["OPTIONS_VISTA_TEXT"]                                               = "时间文本"
L["OPTIONS_VISTA_FONT"]                                               = "时间字体"
L["OPTIONS_VISTA_FONT_TEXT_BELOW_MINIMAP"]                            = "小地图下方时间文本字体"
L["OPTIONS_VISTA_FONT_SIZE"]                                          = "时间字体大小"
L["OPTIONS_VISTA_TEXT_COLOR"]                                         = "时间文本颜色"
L["OPTIONS_VISTA_COLOR_OF_TEXT"]                                      = "时间文本的颜色"
-- L["OPTIONS_VISTA_PERFORMANCE_TEXT"]                                = "Performance Text"
-- L["OPTIONS_VISTA_PERFORMANCE_FONT"]                                = "Performance font"
-- L["OPTIONS_VISTA_FONT_FPS_LATENCY_TEXT_BELOW_MINIMAP"]             = "Font for the FPS and latency text below the minimap."
-- L["OPTIONS_VISTA_PERFORMANCE_FONT_SIZE"]                           = "Performance font size"
-- L["OPTIONS_VISTA_PERFORMANCE_TEXT_COLOR"]                          = "Performance text color"
-- L["OPTIONS_VISTA_COLOR_OF_FPS_LATENCY_TEXT"]                       = "Color of the FPS and latency text."
L["OPTIONS_VISTA_DIFFICULTY_TEXT"]                                    = "难度文本"
L["OPTIONS_VISTA_DIFFICULTY_TEXT_COLOR_FALLBACK"]                     = "难度文本颜色(备用)"
L["OPTIONS_VISTA_DEFAULT_COLOR_PER_DIFFICULTY_COLOR"]                 = "当没有设置特定难度颜色时的默认颜色"
L["OPTIONS_VISTA_DIFFICULTY_FONT"]                                    = "难度字体"
L["OPTIONS_VISTA_FONT_INSTANCE_DIFFICULTY_TEXT"]                      = "副本难度文本字体"
L["OPTIONS_VISTA_DIFFICULTY_FONT_SIZE"]                               = "难度字体大小"
L["OPTIONS_VISTA_PER_DIFFICULTY_COLORS"]                              = "每难度颜色"
L["OPTIONS_VISTA_MYTHIC_COLOR"]                                       = "史诗颜色"
L["OPTIONS_VISTA_COLOR_MYTHIC_DIFFICULTY_TEXT"]                       = "史诗难度文本的颜色"
L["OPTIONS_VISTA_HEROIC_COLOR"]                                       = "英雄颜色"
L["OPTIONS_VISTA_COLOR_HEROIC_DIFFICULTY_TEXT"]                       = "英雄难度文本的颜色"
L["OPTIONS_VISTA_NORMAL_COLOR"]                                       = "普通颜色"
L["OPTIONS_VISTA_COLOR_NORMAL_DIFFICULTY_TEXT"]                       = "普通难度文本的颜色"
L["OPTIONS_VISTA_LFR_COLOR"]                                          = "随机团队颜色"
L["OPTIONS_VISTA_COLOR_LOOKING_RAID_DIFFICULTY_TEXT"]                 = "随机团队难度文本的颜色"

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["OPTIONS_VISTA_TEXT_ELEMENTS"]                                      = "文本元素"
L["OPTIONS_VISTA_ZONE_TEXT"]                                          = "显示区域文本"
L["OPTIONS_VISTA_ZONE_NAME_BELOW_MINIMAP"]                            = "小地图下方显示区域名称"
L["OPTIONS_VISTA_ZONE_TEXT_DISPLAY_MODE"]                             = "区域文本显示模式"
L["OPTIONS_VISTA_WHAT_ZONE_SUBZONE"]                                  = "显示内容：仅区域、仅子区域或两者"
L["OPTIONS_VISTA_ZONE"]                                               = "仅区域"
L["OPTIONS_VISTA_SUBZONE"]                                            = "仅子区域"
L["OPTIONS_VISTA_BOTH"]                                               = "两者"
L["OPTIONS_VISTA_COORDINATES"]                                        = "显示坐标"
L["OPTIONS_VISTA_PLAYER_COORDINATES_BELOW_MINIMAP"]                   = "小地图下方显示玩家坐标"
L["OPTIONS_VISTA_TIME"]                                               = "显示时间"
L["OPTIONS_VISTA_CURRENT_GAME_BELOW_MINIMAP"]                         = "小地图下方显示当前游戏时间"
-- L["OPTIONS_VISTA_HOUR_CLOCK"]                                      = "24-hour clock"
-- L["OPTIONS_VISTA_DISPLAY_HOUR_FORMAT_E_G_INSTEAD"]                 = "Display time in 24-hour format (e.g. 14:30 instead of 2:30 PM)."
L["OPTIONS_VISTA_LOCAL"]                                              = "使用本地时间"
L["OPTIONS_VISTA_YOUR_LOCAL_SYSTEM"]                                  = "启用时显示本地系统时间。禁用时显示服务器时间"
-- L["OPTIONS_VISTA_FPS_LATENCY"]                                     = "Show FPS and latency"
-- L["OPTIONS_VISTA_FPS_LATENCY_MS_BELOW_MINIMAP"]                    = "Show FPS and latency (ms) below the minimap."
L["OPTIONS_VISTA_MINIMAP_BUTTONS"]                                    = "小地图按钮"
L["OPTIONS_VISTA_QUEUE_STATUS_MAIL_INDICATOR_ALWAYS_SHOWN"]           = "队列状态和邮件指示器在相关时始终显示"
L["OPTIONS_VISTA_TRACKING_BUTTON"]                                    = "显示追踪按钮"
L["OPTIONS_VISTA_MINIMAP_TRACKING_BUTTON"]                            = "显示小地图追踪按钮"
L["OPTIONS_VISTA_TRACKING_BUTTON_MOUSEOVER"]                          = "仅鼠标悬停时显示追踪按钮"
L["OPTIONS_VISTA_HIDE_TRACKING_BUTTON_UNTIL_YOU_HOVER"]               = "悬停小地图时显示追踪按钮"
L["OPTIONS_VISTA_CALENDAR_BUTTON"]                                    = "显示日历按钮"
L["OPTIONS_VISTA_MINIMAP_CALENDAR_BUTTON"]                            = "显示小地图日历按钮"
L["OPTIONS_VISTA_CALENDAR_BUTTON_MOUSEOVER"]                          = "仅鼠标悬停时显示日历按钮"
L["OPTIONS_VISTA_HIDE_CALENDAR_BUTTON_UNTIL_YOU_HOVER"]               = "悬停小地图时显示日历按钮"
L["OPTIONS_VISTA_ZOOM_BUTTONS"]                                       = "显示缩放按钮"
L["OPTIONS_VISTA_ZOOM_BUTTONS_MINIMAP"]                               = "小地图显示+和-缩放按钮"
L["OPTIONS_VISTA_ZOOM_BUTTONS_MOUSEOVER"]                             = "仅鼠标悬停时显示缩放按钮"
L["OPTIONS_VISTA_HIDE_ZOOM_BUTTONS_UNTIL_YOU_HOVER"]                  = "悬停小地图时显示缩放按钮"

-- =====================================================================
-- OptionsData.lua Vista — Display (Border / Text Positions / Buttons)
-- =====================================================================
L["OPTIONS_VISTA_BORDER"]                                             = "边框"
L["OPTIONS_VISTA_A_BORDER_AROUND_MINIMAP"]                            = "小地图周围显示边框"
L["OPTIONS_VISTA_BORDER_COLOR"]                                       = "边框颜色"
L["OPTIONS_VISTA_COLOR_OPACITY_OF_MINIMAP_BORDER"]                    = "小地图边框的颜色 (和不透明度)"
L["OPTIONS_VISTA_BORDER_THICKNESS"]                                   = "边框粗细"
L["OPTIONS_VISTA_THICKNESS_OF_MINIMAP_BORDER_PIXELS"]                 = "小地图边框粗细(像素)(1-8)"
-- L["OPTIONS_VISTA_CLASS_COLOURS"]                                   = "Class colours"
-- L["OPTIONS_VISTA_TINT_VISTA_BORDER_TEXT_COORDS_FPS"]               = "Tint Vista border and text (coords, time, FPS/MS labels) with your class colour. Numbers use the configured colour."
L["OPTIONS_VISTA_TEXT_POSITIONS"]                                     = "文本位置"
L["OPTIONS_VISTA_DRAG_TEXT_ELEMENTS_REPOSITION_LOCK_PREVEN"]          = "拖动文本元素重新定位。锁定可防止意外移动"
L["OPTIONS_VISTA_LOCK_ZONE_TEXT_POSITION"]                            = "锁定区域文本位置"
L["OPTIONS_VISTA_ZONE_TEXT_CANNOT_DRAGGED"]                           = "启用时区域文本无法拖动"
L["OPTIONS_VISTA_LOCK_COORDINATES_POSITION"]                          = "锁定坐标位置"
L["OPTIONS_VISTA_COORDINATES_TEXT_CANNOT_DRAGGED"]                    = "启用时坐标文本无法拖动"
L["OPTIONS_VISTA_LOCK_POSITION"]                                      = "锁定时间位置"
L["OPTIONS_VISTA_TEXT_CANNOT_DRAGGED"]                                = "启用时时间文本无法拖动"
-- L["OPTIONS_VISTA_PERFORMANCE_TEXT_POSITION"]                       = "Performance text position"
-- L["OPTIONS_VISTA_PLACE_FPS_LATENCY_TEXT_ABOVE_BELOW"]              = "Place the FPS/latency text above or below the minimap."
-- L["OPTIONS_VISTA_LOCK_PERFORMANCE_TEXT_POSITION"]                  = "Lock performance text position"
-- L["OPTIONS_VISTA_FPS_LATENCY_TEXT_CANNOT_DRAGGED"]                 = "When on, the FPS/latency text cannot be dragged."
-- L["OPTIONS_VISTA_DIFFICULTY_TEXT_POSITION"]                        = "Difficulty text position"
-- L["OPTIONS_VISTA_PLACE_DIFFICULTY_TEXT_ABOVE_BELOW"]               = "Place the instance difficulty text above or below the minimap. It is positioned independently of zone text."
L["OPTIONS_VISTA_LOCK_DIFFICULTY_TEXT_POSITION"]                      = "锁定难度文本位置"
L["OPTIONS_VISTA_DIFFICULTY_TEXT_CANNOT_DRAGGED"]                     = "启用时难度文本无法拖动"
L["OPTIONS_VISTA_BUTTON_POSITIONS"]                                   = "按钮位置"
L["OPTIONS_VISTA_DRAG_BUTTONS_REPOSITION_LOCK_PREVENT_MOVE"]          = "拖动按钮以重新定位. 锁定以防止移动"
L["OPTIONS_VISTA_LOCK_ZOOM_BUTTON"]                                   = "锁定放大按钮"
L["OPTIONS_VISTA_PREVENT_DRAGGING_ZOOM_BUTTON"]                       = "防止拖动放大按钮"
L["OPTIONS_VISTA_LOCK_ZOOM_OUT_BUTTON"]                               = "锁定缩小按钮"
L["OPTIONS_VISTA_LOCK_ZOOM_OUT_DRAG"]                                 = "防止拖动缩小按钮"
L["OPTIONS_VISTA_LOCK_TRACKING_BUTTON"]                               = "锁定追踪按钮"
L["OPTIONS_VISTA_PREVENT_DRAGGING_TRACKING_BUTTON"]                   = "防止拖动追踪按钮"
L["OPTIONS_VISTA_LOCK_CALENDAR_BUTTON"]                               = "锁定日历按钮"
L["OPTIONS_VISTA_PREVENT_DRAGGING_CALENDAR_BUTTON"]                   = "防止拖动日历按钮"
L["OPTIONS_VISTA_LOCK_QUEUE_BUTTON"]                                  = "锁定队列按钮"
L["OPTIONS_VISTA_PREVENT_DRAGGING_QUEUE_STATUS_BUTTON"]               = "防止拖动队列状态按钮"
L["OPTIONS_VISTA_LOCK_MAIL_INDICATOR"]                                = "锁定邮件指示器"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MAIL_ICON"]                         = "防止拖动邮件图标"
-- L["OPTIONS_VISTA_DISABLE_QUEUE_HANDLING"]                          = "Disable queue handling"
L["OPTIONS_VISTA_DISABLE_QUEUE_BUTTON_HANDLING"]                      = "禁用队列按钮处理"
L["OPTIONS_VISTA_TURN_QUEUE_BUTTON_ANCHORING_ANOTHER_A"]              = "关闭所有队列按钮锚定(其他插件管理时使用)"
L["OPTIONS_VISTA_BUTTON_SIZES"]                                       = "按钮大小"
L["OPTIONS_VISTA_ADJUST_SIZE_OF_MINIMAP_OVERLAY_BUTTONS"]             = "调整小地图覆盖按钮的大小"
L["OPTIONS_VISTA_TRACKING_BUTTON_SIZE"]                               = "追踪按钮大小"
L["OPTIONS_VISTA_SIZE_OF_TRACKING_BUTTON_PIXELS"]                     = "追踪按钮大小(像素)"
L["OPTIONS_VISTA_CALENDAR_BUTTON_SIZE"]                               = "日历按钮大小"
L["OPTIONS_VISTA_SIZE_OF_CALENDAR_BUTTON_PIXELS"]                     = "日历按钮大小(像素)"
L["OPTIONS_VISTA_QUEUE_BUTTON_SIZE"]                                  = "队列按钮大小"
L["OPTIONS_VISTA_SIZE_OF_QUEUE_STATUS_BUTTON_PIXELS"]                 = "队列状态按钮大小(像素)"
L["OPTIONS_VISTA_ZOOM_BUTTON_SIZE"]                                   = "缩放按钮大小"
L["OPTIONS_VISTA_SIZE_OF_ZOOM_ZOOM_BUTTONS_PIXELS"]                   = "放大/缩小按钮大小(像素)"
L["OPTIONS_VISTA_MAIL_INDICATOR_SIZE"]                                = "邮件指示器大小"
L["OPTIONS_VISTA_SIZE_OF_MAIL_ICON_PIXELS"]                           = "新邮件图标大小(像素)"
L["OPTIONS_VISTA_ADDON_BUTTON_SIZE"]                                  = "插件按钮大小"
L["OPTIONS_VISTA_SIZE_OF_COLLECTED_ADDON_MINIMAP_BUTTONS"]            = "收集的插件小地图按钮大小(像素)"

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
-- L["OPTIONS_VISTA_COLLECT_HORIZON_MINIMAP"]                         = "Include Horizon minimap icon"
-- L["OPTIONS_VISTA_COLLECT_HORIZON_MINIMAP_DESC"]                    = "Put Horizon's own minimap icon in the managed addon bar, right-click panel, or drawer instead of leaving it on the minimap edge."
-- L["OPTIONS_VISTA_ADDON_BUTTONS"]                                   = "Addon Buttons"
L["OPTIONS_VISTA_MINIMAP_ADDON_BUTTONS"]                              = "小地图插件按钮"
L["OPTIONS_VISTA_BUTTON_MANAGEMENT"]                                  = "按钮管理"
L["OPTIONS_VISTA_MANAGE_ADDON_MINIMAP_BUTTONS"]                       = "管理小地图插件按钮"
L["OPTIONS_VISTA_VISTA_TAKES_CONTROL_OF_ADDON_MINIMAP"]               = "启用时Vista控制插件小地图按钮并按所选模式分组"
L["OPTIONS_VISTA_BUTTON_MODE"]                                        = "按钮模式"
L["OPTIONS_VISTA_ADDON_BUTTONS_PRESENTED_HOVER_BAR_BELOW"]            = "插件按钮显示方式：小地图下方悬停条、右键面板或浮动抽屉按钮"
-- L["OPTIONS_VISTA_ALWAYS_BAR"]                                      = "Always show bar"
L["OPTIONS_VISTA_ALWAYS_MOUSEOVER_BAR_POSITIONING"]                   = "始终显示鼠标悬停栏(用于定位)"
L["OPTIONS_VISTA_KEEP_MOUSEOVER_BAR_VISIBLE_TIMES_YOU"]               = "始终保持鼠标悬停条可见以便重新定位。完成后禁用"
L["OPTIONS_VISTA_DISABLE_DONE"]                                       = "完成后禁用"
L["OPTIONS_VISTA_MOUSEOVER_BAR"]                                      = "鼠标悬停条"
L["OPTIONS_VISTA_RIGHT_CLICK_PANEL"]                                  = "右键面板"
L["OPTIONS_VISTA_FLOATING_DRAWER"]                                    = "浮动抽屉"
L["OPTIONS_VISTA_LOCK_DRAWER_BUTTON_POSITION"]                        = "锁定抽屉按钮位置"
L["OPTIONS_VISTA_PREVENT_DRAGGING_FLOATING_DRAWER_BUTTON"]            = "防止拖动浮动抽屉按钮"
L["OPTIONS_VISTA_LOCK_MOUSEOVER_BAR_POSITION"]                        = "锁定鼠标悬停条位置"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MOUSEOVER_BUTTON_BAR"]              = "防止拖动鼠标悬停按钮条"
L["OPTIONS_VISTA_LOCK_RIGHT_CLICK_PANEL_POSITION"]                    = "锁定右键面板位置"
L["OPTIONS_VISTA_PREVENT_DRAGGING_RIGHT_CLICK_PANEL"]                 = "防止拖动右键面板"
L["OPTIONS_VISTA_BUTTONS_PER_ROW_COLUMN"]                             = "每行/列的按钮数"
L["OPTIONS_VISTA_CONTROLS_MANY_BUTTONS_APPEAR_BEFORE_WRAPPING"]       = "控制换行前显示多少个按钮. 左/右方向为列数; 上/下方向为行数"
L["OPTIONS_VISTA_EXPAND_DIRECTION"]                                   = "展开方向"
L["OPTIONS_VISTA_DIRECTION_BUTTONS_FILL_ANCHOR_POINT_LEFT"]           = "按钮从锚点开始填充的方向. 左/右 = 水平行. 上/下 = 垂直列"
L["OPTIONS_VISTA_RIGHT"]                                              = "右"
L["OPTIONS_VISTA_LEFT"]                                               = "左"
L["OPTIONS_VISTA_DOWN"]                                               = "下"
L["OPTIONS_VISTA_UP"]                                                 = "上"
L["OPTIONS_VISTA_MOUSEOVER_BAR_APPEARANCE"]                           = "鼠标悬停条外观"
L["OPTIONS_VISTA_BACKGROUND_BORDER_MOUSEOVER_BUTTON_BAR"]             = "鼠标悬停按钮栏的背景和边框."
L["OPTIONS_VISTA_BACKDROP_COLOR"]                                     = "背景颜色"
L["OPTIONS_VISTA_BACKGROUND_COLOR_OF_MOUSEOVER_BUTTON_BAR"]           = "鼠标悬停按钮栏的背景颜色(使用alpha控制透明度)."
L["OPTIONS_VISTA_BAR_BORDER"]                                         = "显示条形边框"
L["OPTIONS_VISTA_A_BORDER_AROUND_MOUSEOVER_BUTTON_BAR"]               = "鼠标悬停按钮条周围显示边框"
L["OPTIONS_VISTA_BAR_BORDER_COLOR"]                                   = "栏边框颜色"
L["OPTIONS_VISTA_BORDER_COLOR_OF_MOUSEOVER_BUTTON_BAR"]               = "鼠标悬停按钮栏的边框颜色."
L["OPTIONS_VISTA_BAR_BACKGROUND_COLOR"]                               = "栏背景颜色"
L["OPTIONS_VISTA_PANEL_BACKGROUND_COLOR"]                             = "面板背景颜色"
L["OPTIONS_VISTA_CLOSE_FADE_TIMING"]                                  = "关闭/淡出计时"
L["OPTIONS_VISTA_MOUSEOVER_BAR_CLOSE_DELAY_SECONDS"]                  = "鼠标悬停条 - 关闭延迟(秒)"
L["OPTIONS_VISTA_LONG_SECONDS_BAR_STAYS_VISIBLE_AFTER"]               = "光标离开后条形保持可见的时间(秒)。0 = 立即淡出"
L["OPTIONS_VISTA_RIGHT_CLICK_PANEL_CLOSE_DELAY_SECONDS"]              = "右键面板 - 关闭延迟(秒)"
L["OPTIONS_VISTA_LONG_SECONDS_PANEL_STAYS_OPEN_AFTER"]                = "光标离开后面板保持打开的时间(秒)。0 = 永不自动关闭(通过再次右键关闭)"
L["OPTIONS_VISTA_FLOATING_DRAWER_CLOSE_DELAY_SECONDS"]                = "浮动抽屉 - 关闭延迟(秒)"
L["OPTIONS_VISTA_DRAWER_CLOSE_DELAY"]                                 = "抽屉关闭延迟"
L["OPTIONS_VISTA_LONG_SECONDS_DRAWER_PANEL_STAYS_OPEN"]               = "点击其他位置后抽屉面板保持打开的时间(秒)。0 = 永不自动关闭(仅通过再次点击抽屉按钮关闭)"
L["OPTIONS_VISTA_MAIL_ICON_BLINK"]                                    = "邮件图标闪烁"
L["OPTIONS_VISTA_MAIL_ICON_PULSES_DRAW_ATTENTION"]                    = "启用时邮件图标脉冲引起注意。禁用时保持完全不透明"
L["OPTIONS_VISTA_PANEL_APPEARANCE"]                                   = "面板外观"
L["OPTIONS_VISTA_COLORS_DRAWER_RIGHT_CLICK_BUTTON_PANELS"]            = "抽屉和右键按钮面板的颜色"
L["OPTIONS_VISTA_PANEL_BG_COLOR_LABEL"]                               = "面板背景颜色"
L["OPTIONS_VISTA_BACKGROUND_COLOR_OF_ADDON_BUTTON_PANELS"]            = "插件按钮面板的背景颜色"
L["OPTIONS_VISTA_PANEL_BORDER_COLOR"]                                 = "面板边框颜色"
L["OPTIONS_VISTA_BORDER_COLOR_OF_ADDON_BUTTON_PANELS"]                = "插件按钮面板的边框颜色"
L["OPTIONS_VISTA_MANAGED_BUTTONS"]                                    = "已管理的按钮"
L["OPTIONS_VISTA_BUTTON_COMPLETELY_IGNORED_A"]                        = "关闭时此插件完全忽略此按钮"
L["OPTIONS_VISTA_ADDON_BUTTONS_DETECTED"]                             = "(尚未检测到插件按钮)"
L["OPTIONS_VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE"]                      = "可见按钮(勾选以包含)"
L["OPTIONS_VISTA_ADDON_BUTTONS_DETECTED_OPEN_YOUR_MINIMAP"]           = "(尚未检测到插件按钮 — 请先打开你的小地图)"

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
-- L["OPTIONS_CORE_ACHIEVEMENT_ICONS"]                                = "Achievement icons"
-- L["OPTIONS_CORE_ACTIVE_INSTANCE"]                                  = "Active instance only"
-- L["OPTIONS_CORE_ADJUST_FONT_SIZES_AMOUNT"]                         = "Adjust all font sizes by this amount."
-- L["OPTIONS_CORE_ADJUST_FONTS_SIZES_CASING_DROP_SHADOWS"]           = "Adjust fonts, sizes, casing, and drop shadows."
-- L["OPTIONS_CORE_AFFIX_ICONS"]                                      = "Affix icons"
-- L["OPTIONS_CORE_AFFIX_TOOLTIPS"]                                   = "Affix tooltips"
-- L["OPTIONS_CORE_AFFECTS_SCENARIO_PROGRESS_TIMER_BARS"]             = "Also affects scenario progress and timer bars."
-- L["OPTIONS_CORE_ALWAYS"]                                           = "Always show"
-- L["OPTIONS_CORE_ALWAYS_M_TIMER"]                                   = "Always show M+ timer."
-- L["OPTIONS_CORE_AUTO_ADD_WQS_YOUR_CURRENT_ZONE"]                   = "Auto-add WQs in your current zone."
-- L["OPTIONS_CORE_AUTO_CLOSE_DELAY_DISABLE"]                         = "Auto-close delay (0 to disable)."
-- L["OPTIONS_CORE_AUTO_UNTRACK_FINISHED_ACTIVITIES"]                 = "Auto-untrack finished activities."
-- L["OPTIONS_CORE_BAR_UNDER_NUMERIC_OBJECTIVES_E_G"]                 = "Bar under numeric objectives (e.g. 3/250)."
L["OPTIONS_CORE_BLIZZARD_DEFAULT_RONDOMEDIA_CLASS_ICON_DASHBO"]       = "Blizzard default or RondoMedia class icon on the Dashboard when Dashboard class colours are on. Independent of Insight tooltip class icons."
-- L["OPTIONS_CORE_BLOCK_POSITION"]                                   = "Block position"
-- L["OPTIONS_CORE_BOSS_EMOTES"]                                      = "Boss emotes"
-- L["OPTIONS_CORE_CHOICE_SLOTS"]                                     = "Choice slots"
-- L["OPTIONS_CORE_CHOOSE_WHICH_EVENTS_TRIGGER_SCREEN_ALERTS"]        = "Choose which events trigger on-screen alerts."
-- L["OPTIONS_CORE_CHOOSE_WHICH_SOUND_PLAY_A_RARE"]                   = "Choose which sound to play when a rare boss appears. Requires LibSharedMedia sounds to be installed for extra options."
-- L["OPTIONS_CORE_CLICK_BEHAVIOR"]                                   = "Click behavior"
-- L["OPTIONS_CORE_COLLECT_GROUP_ADDON_MINIMAP_BUTTONS"]              = "Collect and group addon minimap buttons."
-- L["OPTIONS_CORE_COLOR_REMAINING"]                                  = "Color by remaining time."
-- L["OPTIONS_CORE_COLOR_ZONE_TYPE"]                                  = "Color by zone type"
-- L["OPTIONS_CORE_COLOR_CONTESTED_ZONES_ORANGE_DEFAULT"]             = "Color for contested zones (orange by default)."
-- L["OPTIONS_CORE_COLOR_FRIENDLY_ZONES_GREEN_DEFAULT"]               = "Color for friendly zones (green by default)."
-- L["OPTIONS_CORE_COLOR_HOSTILE_ZONES_RED_DEFAULT"]                  = "Color for hostile zones (red by default)."
-- L["OPTIONS_CORE_COLOR_SANCTUARY_ZONES_BLUE_DEFAULT"]               = "Color for sanctuary zones (blue by default)."
-- L["OPTIONS_CORE_COLOR_OF_DIVIDER_LINES_BETWEEN_SECTIONS"]          = "Color of the divider lines between sections."
-- L["OPTIONS_CORE_COLOR_RECIPE_TITLES_OUTPUT_ITEM_RARITY"]           = "Color recipe titles by output item rarity."
-- L["OPTIONS_CORE_COLOR_ZONE_SUBZONE_TITLES_PVP_ZONE"]               = "Color zone/subzone titles by PvP zone type (friendly, hostile, contested, sanctuary). When off, uses the default category color."
-- L["OPTIONS_CORE_COMBAT_AFK_DND_PVP_PARTY_FRIENDS"]                 = "Combat, AFK, DND, PvP, party, friends, targeting."
-- L["OPTIONS_CORE_COMING_SOON"]                                      = "Coming Soon"
-- L["OPTIONS_CORE_COMPLETED_BOSS_STYLE"]                             = "Completed boss style"
-- L["OPTIONS_CORE_COMPLETED_COUNT"]                                  = "Completed count"
-- L["OPTIONS_CORE_CONFIGURE_CLICK_BEHAVIORS_TRACKING_RULES_TOMTOM"]  = "Configure click behaviors, tracking rules, and TomTom integration."
-- L["OPTIONS_CORE_CONFIGURE_MINIMAP_S_SHAPE_SIZE_POSITION"]          = "Configure the minimap's shape, size, position, and text overlays."
-- L["OPTIONS_CORE_CONTESTED_ZONE_COLOR"]                             = "Contested zone color"
-- L["OPTIONS_CORE_CONTROL_TRACKER_VISIBILITY_WITHIN_DUNGEONS_RAIDS"] = "Control tracker visibility within dungeons, raids, and PvP."
-- L["OPTIONS_CORE_SETTINGS_PRESENCE_NOTIFICATION_FRAMEWORK"]         = "Core settings for the Presence notification framework."
-- L["OPTIONS_CORE_CRAFTABLE_COUNT"]                                  = "Craftable count"
-- L["OPTIONS_CORE_CTRL_LEFT_FOCUS_ADD_CTRL_RIGHT"]                   = "Ctrl+Left = focus/add, Ctrl+Right = unfocus/untrack."
-- L["OPTIONS_CORE_CURRENT_ZONE_GROUP"]                               = "Current Zone group"
-- L["OPTIONS_CORE_CURRENT_ZONE"]                                     = "Current zone only"
-- L["OPTIONS_CORE_CUSTOMIZE_BORDERS_COLORS_POSITIONING_OF_SPECIFI"]  = "Customize borders, colors, and the positioning of specific minimap elements."
-- L["OPTIONS_CORE_CUSTOMIZE_VISUAL_INTERFACE_LAYOUT_ELEMENTS"]       = "Customize the visual interface and layout elements."
-- L["OPTIONS_CORE_DASHBOARD_CLASS_ICON_STYLE"]                       = "Dashboard class icon style"
-- L["OPTIONS_CORE_DECOR_ICONS"]                                      = "Decor icons"
-- L["OPTIONS_CORE_DEDICATED_SECTION_COMPLETED_QUESTS"]               = "Dedicated section for completed quests."
-- L["OPTIONS_CORE_DEDICATED_SECTION_ZONE_QUESTS"]                    = "Dedicated section for in-zone quests."
-- L["OPTIONS_CORE_DEFEATED_BOSS_STYLE"]                              = "Defeated boss style."
-- L["OPTIONS_CORE_DESATURATE_FOCUSED_ENTRIES"]                       = "Desaturate non-focused entries."
-- L["OPTIONS_CORE_DESATURATE_FOCUSED_QUESTS"]                        = "Desaturate non-focused quests"
-- L["OPTIONS_CORE_DIM_ALPHA"]                                        = "Dim alpha"
-- L["OPTIONS_CORE_DIM_STRENGTH"]                                     = "Dim strength"
-- L["OPTIONS_CORE_DIM_UNFOCUSED_TRACKER_ENTRIES"]                    = "Dim unfocused tracker entries."
-- L["OPTIONS_CORE_DIMMING_STRENGTH"]                                 = "Dimming strength (0-100%)."
-- L["OPTIONS_CORE_DISPLAY_COMPLETED_OBJECTIVES"]                     = "Display completed objectives."
-- L["OPTIONS_CORE_ENABLE_BLACKLIST_UNTRACKED_INTERACTIONS_ADD_QUEST"]= "Enable 'Blacklist untracked' in Interactions to add quests here."
-- L["OPTIONS_CORE_ENABLE_M_BLOCK"]                                   = "Enable M+ block"
-- L["OPTIONS_CORE_ENEMY_FORCES_COLOR"]                               = "Enemy forces color"
-- L["OPTIONS_CORE_ENEMY_FORCES_SIZE"]                                = "Enemy forces size"
-- L["OPTIONS_CORE_ENHANCE_PLAYER_ITEM_TOOLTIPS_EXTRA_DETAILS"]       = "Enhance player and item tooltips with extra details like Mythic+ score and transmog status."
-- L["OPTIONS_CORE_ENTRY_NUMBERS"]                                    = "Entry numbers"
-- L["OPTIONS_CORE_ENTRY_SPACING"]                                    = "Entry spacing"
-- L["OPTIONS_CORE_EXPAND_DIRECTION_ANCHOR"]                          = "Expand direction from anchor."
-- L["OPTIONS_CORE_FADE_HOVERING"]                                    = "Fade out when not hovering."
-- L["FOCUS_FINISHING_REAGENTS"]                                      = "Finishing reagents"
-- L["OPTIONS_FOCUS_ANIMATIONS"]                                      = "Focus animations"
-- L["OPTIONS_CORE_FONT_SIZE_BAR_LABEL_BAR_HEIGHT"]                   = "Font size for bar label and bar height."
-- L["OPTIONS_CORE_FONTS_SIZES_COLORS_PRESENCE_NOTIFICATIONS"]        = "Fonts, sizes, and colors for Presence notifications."
-- L["OPTIONS_CORE_WORLD_QUESTS_WEEKLIES_YOUR_QUEST_LOG"]             = "For world quests and weeklies not in your quest log."
-- L["OPTIONS_CORE_FRIENDLY_ZONE_COLOR"]                              = "Friendly zone color"
-- L["OPTIONS_CORE_GROUPING"]                                         = "Grouping"
-- L["OPTIONS_CORE_GROUPS_SELECTED_LAYOUT_MODE_BELOW"]                = "Groups them by the selected layout mode below."
-- L["OPTIONS_CORE_GUILD_RANK"]                                       = "Guild rank"
-- L["OPTIONS_CORE_HEADER_DIVIDER"]                                   = "Header divider"
-- L["OPTIONS_CORE_HIDE_UNTRACKED_QUESTS_UNTIL_RELOAD"]               = "Hide untracked quests until reload."
-- L["OPTIONS_CORE_HIDE_ZONE_NOTIFICATIONS_MYTHIC"]                   = "Hide zone notifications in Mythic+."
-- L["OPTIONS_CORE_HIDES_CATEGORIES_WHILE_A_DELVE_PARTY"]             = "Hides other categories while in a Delve or party dungeon."
-- L["OPTIONS_CORE_HINT_LIST_SCROLLABLE"]                             = "Hint when the list is scrollable."
-- L["OPTIONS_CORE_HONOR_LEVEL"]                                      = "Honor level"
-- L["OPTIONS_CORE_HOSTILE_ZONE_COLOR"]                               = "Hostile zone color"
-- L["OPTIONS_CORE_MUCH_DIM_FOCUSED_ENTRIES_DIMMING_FU"]              = "How much to dim non-focused entries (0 = no dimming, 100 = fully darkened). Default 40%."
-- L["OPTIONS_CORE_ICON_NEXT_ACHIEVEMENT_TITLE"]                      = "Icon next to achievement title."
-- L["OPTIONS_CORE_ICON_NEXT_AUTO_TRACKED_ZONE_ENTRIES"]              = "Icon next to auto-tracked in-zone entries."
-- L["OPTIONS_CORE_ARENA"]                                            = "In arena"
-- L["OPTIONS_CORE_BATTLEGROUND"]                                     = "In battleground"
-- L["OPTIONS_CORE_DUNGEON"]                                          = "In dungeon"
-- L["OPTIONS_CORE_RAID"]                                             = "In raid"
-- L["OPTIONS_CORE_ZONE_WORLD_QUESTS"]                                = "In-zone world quests"
-- L["OPTIONS_CORE_INCLUDE_COMPLETED"]                                = "Include completed"
-- L["OPTIONS_CORE_INSTANCE_SUPPRESSION"]                             = "Instance suppression"
-- L["OPTIONS_CORE_ITEM_LEVEL"]                                       = "Item level"
-- L["OPTIONS_CORE_ITEM_SOURCE"]                                      = "Item source"
-- L["OPTIONS_CORE_KEEP_BAR_VISIBLE_REPOSITIONING"]                   = "Keep bar visible for repositioning."
-- L["OPTIONS_CORE_KEEP_CAMPAIGN_CATEGORY"]                           = "Keep campaign in category"
-- L["OPTIONS_CORE_KEEP_HEADER_BOTTOM_TOP_UNTIL_COLLAPSED"]           = "Keep header at bottom, or top until collapsed."
-- L["OPTIONS_CORE_KEEP_IMPORTANT_CATEGORY"]                          = "Keep important in category"
-- L["OPTIONS_CORE_KEEP_CAMPAIGN_READY_TURN"]                         = "Keep in Campaign when ready to turn in."
-- L["OPTIONS_CORE_KEEP_IMPORTANT_READY_TURN"]                        = "Keep in Important when ready to turn in."
-- L["OPTIONS_CORE_KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED"]           = "Keep section headers visible when collapsed."
-- L["OPTIONS_CORE_L_CLICK_OPENS_MAP_R_CLICK"]                        = "L-click opens map, R-click opens menu."
-- L["PRESENCE_LEVEL_UP_TOGGLE"]                                      = "Level up"
-- L["OPTIONS_CORE_LOCK_DRAWER_BUTTON"]                               = "Lock drawer button"
-- L["OPTIONS_CORE_LOCK_ITEM_POSITION"]                               = "Lock item position"
-- L["OPTIONS_CORE_LOCK_MINIMAP"]                                     = "Lock minimap"
-- L["OPTIONS_CORE_LOCK_MOUSEOVER_BAR"]                               = "Lock mouseover bar"
-- L["OPTIONS_CORE_LOCK_RIGHT_CLICK_PANEL"]                           = "Lock right-click panel"
-- L["OPTIONS_CORE_MAIL_ICON_PULSE"]                                  = "Mail icon pulse"
-- L["OPTIONS_CORE_MAKE_FOCUSED_ENTRIES_GREYSCALE_PARTIALLY_DESATURATE"]= "Make non-focused entries greyscale/partially desaturated in addition to dimming."
-- L["OPTIONS_CORE_MANAGE_ADDON_BUTTONS"]                             = "Manage addon buttons"
-- L["OPTIONS_CORE_MANAGE_ORGANIZE_MINIMAP_ICONS_ADDONS_INT"]         = "Manage and organize minimap icons from other addons into a tidy drawer or bar."
-- L["OPTIONS_CORE_MANAGE_SWITCH_BETWEEN_YOUR_ADDON_CONFIGURATIONS"]  = "Manage and switch between your addon configurations."
-- L["OPTIONS_CORE_MATCH_BAR_QUEST_CATEGORY_COLOR"]                   = "Match bar to quest category color."
-- L["OPTIONS_CORE_APPEAR_FULL_TRACKER_REPLACEMENTS"]                 = "May not appear with full tracker replacements."
-- L["OPTIONS_CORE_MINIMAL_MODE"]                                     = "Minimal mode"
-- L["OPTIONS_CORE_MISSING_CRITERIA"]                                 = "Missing criteria only"
-- L["OPTIONS_CORE_MOUNT_INFO"]                                       = "Mount info"
-- L["OPTIONS_CORE_MOUNT_NAME_SOURCE_COLLECTION_STATUS"]              = "Mount name, source, and collection status."
-- L["OPTIONS_CORE_MOUSEOVER_CLOSE_DELAY"]                            = "Mouseover close delay"
-- L["OPTIONS_CORE_MOUSEOVER"]                                        = "Mouseover only"
-- L["OPTIONS_CORE_MOVE_COMPLETED_QUESTS_BOTTOM_OF_CURRENT"]          = "Move completed quests to the bottom of the Current Zone section."
-- L["OPTIONS_CORE_MYTHIC_BLOCK"]                                     = "Mythic+ Block"
-- L["OPTIONS_CORE_MYTHIC_COLORS"]                                    = "Mythic+ Colors"
-- L["OPTIONS_CORE_MYTHIC_SCORE"]                                     = "Mythic+ score"
-- L["OPTIONS_CORE_DEFAULT"]                                          = "New from Default"
-- L["OPTIONS_CORE_HIDDEN_QUESTS"]                                    = "No hidden quests."
-- L["OPTIONS_CORE_NOTIFY_ACHIEVEMENT_CRITERIA_UPDATE"]               = "Notify on achievement criteria update."
-- L["OPTIONS_CORE_OBJECTIVE_PROGRESS"]                               = "Objective progress"
-- L["OPTIONS_CORE_OBJECTIVE_SPACING"]                                = "Objective spacing"
-- L["OPTIONS_CORE_L_CLICK_FOCUSES_R_CLICK_UNTRACKS"]                 = "Off: L-click focuses, R-click untracks. Ctrl+Right shares."
-- L["OPTIONS_CORE_PROGRESS_TRACKED_ACHIEVEMENTS_SHOWN"]              = "Off: only in-progress tracked achievements shown."
-- L["OPTIONS_CORE_TRACKED_NEARBY_WQS_APPEAR_BLIZZARD_DEFAULT"]       = "Off: only tracked or nearby WQs appear (Blizzard default)."
-- L["OPTIONS_CORE_BOSS_EMOTES_ACHIEVEMENTS_LEVEL_HIDES_ZONE"]        = "Only boss emotes, achievements, and level-up. Hides zone, quest, and scenario notifications in Mythic+."
-- L["OPTIONS_CORE_ENTRIES_A_SINGLE_NUMERIC_OBJECTIVE_WHERE"]         = "Only for entries with a single numeric objective where required > 1."
-- L["OPTIONS_CORE_QUESTS_DON_T_NEED_NPC_TURN"]                       = "Only for quests that don't need NPC turn-in. Off = Blizzard default."
-- L["OPTIONS_CORE_INCOMPLETE_CRITERIA"]                              = "Only show incomplete criteria."
-- L["OPTIONS_CORE_SUBZONE_NAME_WITHIN_SAME_ZONE"]                    = "Only show subzone name within same zone."
-- L["OPTIONS_CORE_OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]               = "Opacity of focused quest highlight (0–100%)."
-- L["OPTIONS_CORE_OPACITY_OF_UNFOCUSED_ENTRIES"]                     = "Opacity of unfocused entries."
-- L["FOCUS_OPTIONAL_REAGENTS"]                                       = "Optional reagents"
-- L["FOCUS_RECIPE_REAGENTS_FULL_DETAIL"]                             = "Full reagent detail"
-- L["FOCUS_RECIPE_REAGENTS_FULL_DETAIL_DESC"]                        = "List every schematic slot: optional and finishing sections, choice groups with all variants, and non-Basic reagents. When off, only Basic slots use the first reagent per slot (compact shopping-style list)."
-- L["OPTIONS_CORE_OPTIONS_BUTTON"]                                   = "Options button"
-- L["OPTIONS_CORE_ORGANIZE_HIDE_TRACKED_ENTRIES_YOUR_PREFERENCE"]    = "Organize and hide tracked entries to your preference."
-- L["OPTIONS_CORE_OVERRIDE_FONT_PER_ELEMENT"]                        = "Override font per element."
-- L["OPTIONS_CORE_PANEL_BACKGROUND_OPACITY"]                         = "Panel background opacity (0–100%)."
-- L["OPTIONS_CORE_PERMANENTLY_HIDE_UNTRACKED_QUESTS"]                = "Permanently hide untracked quests."
-- L["OPTIONS_CORE_PERSONALIZE_COLOR_PALETTE_TRACKER_TEXT_ELEMENTS"]  = "Personalize the color palette for tracker text elements."
-- L["OPTIONS_CORE_POSITIONING_VISIBILITY_CACHE_LOOT_TOAST_SYS"]      = "Positioning and visibility for the Cache loot toast system."
-- L["OPTIONS_CORE_PREVENT_ACCIDENTAL_CLICKS"]                        = "Prevent accidental clicks."
-- L["OPTIONS_CORE_QUALITY_INFO"]                                     = "Quality info"
-- L["OPTIONS_CORE_QUEST_ACCEPT"]                                     = "Quest accept"
-- L["OPTIONS_CORE_QUEST_COMPLETE"]                                   = "Quest complete"
-- L["OPTIONS_CORE_QUEST_COUNT"]                                      = "Quest count"
-- L["OPTIONS_CORE_QUEST_ITEM_BUTTONS"]                               = "Quest item buttons"
-- L["OPTIONS_CORE_QUEST_LEVEL"]                                      = "Quest level"
-- L["OPTIONS_CORE_QUEST_PROGRESS"]                                   = "Quest progress"
-- L["OPTIONS_CORE_QUEST_PROGRESS_BAR"]                               = "Quest progress bar"
-- L["OPTIONS_CORE_QUEST_TRACKING"]                                   = "Quest tracking"
-- L["OPTIONS_CORE_QUEST_TYPE_ICONS"]                                 = "Quest type icons"
-- L["OPTIONS_FOCUS_QUEST_TYPE_ICON_SIZE"]                            = "Quest type icon size"
-- L["OPTIONS_FOCUS_QUEST_TYPE_ICON_SIZE_DESC"]                       = "Pixel size of the quest type icon shown in the left gutter (default 16)."
-- L["PRESENCE_RARE_DEFEATED"]                                        = "RARE DEFEATED"
-- L["OPTIONS_CORE_RARE_ADDED_SOUND_CHOICE"]                          = "Rare added sound choice"
-- L["OPTIONS_CORE_RARE_SOUND_ALERT"]                                 = "Rare sound alert"
-- L["OPTIONS_CORE_RARITY_COLORS"]                                    = "Rarity colors"
-- L["OPTIONS_CORE_READY_TURN_GROUP"]                                 = "Ready to Turn In group"
-- L["OPTIONS_CORE_READY_TURN_BOTTOM"]                                = "Ready to turn in at bottom"
-- L["OPTIONS_CORE_REAGENTS"]                                         = "Reagents"
-- L["OPTIONS_CORE_RECIPE_ICONS"]                                     = "Recipe icons"
-- L["OPTIONS_CORE_RECIPES"]                                          = "Recipes"
-- L["OPTIONS_CORE_REDUCE_OPACITY_OF_FOCUSED_ENTRIES_INVISIBLE"]      = "Reduce opacity of non-focused entries (0 = invisible, 100 = fully opaque). Default 100% (no alpha change)."
-- L["OPTIONS_CORE_REQUIRE_CTRL_COMPLETE_CLICK_COMPLETABLE_QUESTS"]   = "Require Ctrl to complete click-completable quests."
-- L["OPTIONS_CORE_REQUIREMENTS"]                                     = "Requirements"
-- L["OPTIONS_CORE_REQUIRES_QUEST_TYPE_ICONS_ENABLED_DISPLAY"]        = "Requires quest type icons to be enabled in Display."
-- L["OPTIONS_CORE_RESET_MYTHIC_STYLING"]                             = "Reset Mythic+ styling"
-- L["OPTIONS_CORE_REVIEW_MANAGE_QUESTS_YOU_MANUALLY_UNTRACKED"]      = "Review and manage quests you have manually untracked or blacklisted."
-- L["OPTIONS_CORE_RIGHT_CLICK_CLOSE_DELAY"]                          = "Right-click close delay"
-- L["OPTIONS_CORE_SANCTUARY_ZONE_COLOR"]                             = "Sanctuary zone color"
-- L["OPTIONS_CORE_SCALE_UI_ELEMENTS"]                                = "Scale all UI elements (50–200%)."
-- L["PRESENCE_SCENARIO_COMPLETE"]                                    = "Scenario Complete"
-- L["OPTIONS_CORE_SCENARIO_EVENTS"]                                  = "Scenario events"
-- L["OPTIONS_CORE_SCENARIO_PROGRESS"]                                = "Scenario progress"
-- L["OPTIONS_CORE_SCENARIO_PROGRESS_BAR"]                            = "Scenario progress bar"
-- L["OPTIONS_CORE_SCENARIO_START"]                                   = "Scenario start"
-- L["OPTIONS_CORE_SCENARIO_TIMER_BAR"]                               = "Scenario timer bar"
-- L["OPTIONS_CORE_SCROLL_INDICATOR"]                                 = "Scroll indicator"
-- L["OPTIONS_CORE_SECONDS_OF_RECENT_PROGRESS"]                       = "Seconds of recent progress to show."
-- L["OPTIONS_CORE_SECTION_DIVIDER_COLOR"]                            = "Section divider color"
-- L["OPTIONS_CORE_SECTION_HEADERS"]                                  = "Section headers"
-- L["OPTIONS_CORE_SECTIONS_COLLAPSED"]                               = "Sections when collapsed"
-- L["OPTIONS_CORE_SEPARATE_SCALE_SLIDER_PER_MODULE"]                 = "Separate scale slider per module."
-- L["OPTIONS_CORE_SHADOW_OPACITY"]                                   = "Shadow opacity (0–100%)."
-- L["OPTIONS_CORE_A_VISUAL_DIVIDER_LINE_BETWEEN_FOCUS"]              = "Show a visual divider line between Focus sections to make categories easier to distinguish."
-- L["OPTIONS_CORE_AFFIX_NAMES_FIRST_DELVE_ENTRY"]                    = "Show affix names on first Delve entry."
-- L["OPTIONS_CORE_COLLAPSIBLE_CHOICE_REAGENT_SLOTS"]                 = "Show collapsible choice reagent slots."
-- L["OPTIONS_CORE_COMPLETED_ACHIEVEMENTS_LIST"]                      = "Show completed achievements in the list."
-- L["OPTIONS_CORE_FINISHING_REAGENT_SLOTS"]                          = "Show finishing reagent slots."
-- L["OPTIONS_CORE_MANY_TIMES_RECIPE_CRAFTED"]                        = "Show how many times the recipe can be crafted."
-- L["OPTIONS_CORE_NORMAL_DUNGEONS"]                                  = "Show in Normal dungeons."
-- L["OPTIONS_CORE_LOCAL_SYSTEM"]                                     = "Show local system time."
-- L["OPTIONS_CORE_NOTIFICATION_A_RARE_MOB_DEFEATED_NEARBY"]          = "Show notification when a rare mob is defeated nearby."
-- L["OPTIONS_CORE_NOTIFICATION_A_SCENARIO_DELVE_FULLY_COM"]          = "Show notification when a scenario or Delve is fully completed."
-- L["OPTIONS_CORE_OBJECTIVE_LINE"]                                   = "Show objective line only."
-- L["OPTIONS_CORE_HOVER"]                                            = "Show only on hover."
-- L["OPTIONS_CORE_ACTIVE_INSTANCE_SECTION"]                          = "Show only the active instance section."
-- L["OPTIONS_CORE_OPTIONAL_REAGENT_SLOTS"]                           = "Show optional reagent slots."
-- L["OPTIONS_CORE_QUALITY_TIER_PIPS_RECIPES_SUPPORT_QUALITI"]        = "Show quality tier pips for recipes that support qualities."
-- L["OPTIONS_CORE_REAGENT_SHOPPING_LIST_RECIPE"]                     = "Show reagent shopping list for each recipe."
-- L["FOCUS_AH_SEARCH_TITLE"]                                         = "Search Auction House"
L["FOCUS_AH_SEARCH_TOOLTIP"]                                          = "Left-click: search for one craft worth of reagents.\nRight-click: enter how many crafts to multiply quantities.\nThe Auction House must be open."
-- L["FOCUS_AH_CRAFT_DIALOG_SUBTITLE"]                                = "Auction House shopping list"
-- L["FOCUS_AH_CRAFT_HINT_CRAFT_COUNT"]                               = "Number of crafts to buy materials for (1–999). List quantities are multiplied by this."
L["FOCUS_AH_CRAFT_HINT_TIER"]                                         = "Crafting tier 1, 2, or 3 for every Auctionator row, or leave empty to use each item’s tier."
-- L["FOCUS_AH_CRAFT_TIER_ANY"]                                       = "Any tier"
-- L["FOCUS_AH_CRAFT_TIER_N"]                                         = "Tier %d"
-- L["FOCUS_AH_CRAFT_COUNT_INVALID"]                                  = "Enter a whole number from 1 to 999."
-- L["OPTIONS_CORE_RECENT_PROGRESS_TOP"]                              = "Show recent progress at the top."
-- L["OPTIONS_CORE_RECIPE_ICON_NEXT_TITLE_REQUIRES_QUEST"]            = "Show recipe icon next to title. Requires quest type icons in Display."
-- L["OPTIONS_CORE_SECTION_DIVIDERS"]                                 = "Show section dividers"
-- L["OPTIONS_CORE_M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]              = "Show the M+ block whenever an active keystone is running."
-- L["OPTIONS_CORE_TRACKED_PROFESSION_RECIPES_LIST"]                  = "Show tracked profession recipes in the list."
-- L["OPTIONS_CORE_TRACKER_HEROIC_DUNGEONS_UNSET_MAS"]                = "Show tracker in Heroic dungeons. When unset, uses the master dungeon toggle."
-- L["OPTIONS_CORE_TRACKER_HEROIC_RAIDS_UNSET_MASTER"]                = "Show tracker in Heroic raids. When unset, uses the master raid toggle."
-- L["OPTIONS_CORE_TRACKER_LOOKING_RAID_UNSET_MA"]                    = "Show tracker in Looking for Raid. When unset, uses the master raid toggle."
-- L["OPTIONS_CORE_TRACKER_MYTHIC_KEYSTONE_M_DUNGEONS_UNSET"]         = "Show tracker in Mythic Keystone (M+) dungeons. When unset, uses the master dungeon toggle."
-- L["OPTIONS_CORE_TRACKER_MYTHIC_DUNGEONS_UNSET_MAS"]                = "Show tracker in Mythic dungeons. When unset, uses the master dungeon toggle."
-- L["OPTIONS_CORE_TRACKER_MYTHIC_RAIDS_UNSET_MASTER"]                = "Show tracker in Mythic raids. When unset, uses the master raid toggle."
-- L["OPTIONS_CORE_TRACKER_NORMAL_DUNGEONS_UNSET_MAS"]                = "Show tracker in Normal dungeons. When unset, uses the master dungeon toggle."
-- L["OPTIONS_CORE_TRACKER_NORMAL_RAIDS_UNSET_MASTER"]                = "Show tracker in Normal raids. When unset, uses the master raid toggle."
-- L["OPTIONS_CORE_TRACKER_PARTY_DUNGEONS_MASTER_TOGGLE_DU"]          = "Show tracker in party dungeons (master toggle for all dungeon difficulties)."
-- L["OPTIONS_CORE_TRACKER_RAIDS_MASTER_TOGGLE_RAID_DIFFIC"]          = "Show tracker in raids (master toggle for all raid difficulties)."
-- L["OPTIONS_CORE_UNMET_CRAFTING_STATION_REQUIREMENTS"]              = "Show unmet crafting station requirements."
-- L["OPTIONS_CORE_SHOWN_HOVERING_A_MOUNTED_PLAYER"]                  = "Shown when hovering a mounted player."
-- L["OPTIONS_CORE_SIZE_SHAPE"]                                       = "Size & shape"
-- L["OPTIONS_CORE_SIZE_OF_ZOOM_BUTTONS_PIXELS"]                      = "Size of the + and - zoom buttons (pixels)."
-- L["OPTIONS_CORE_SORT_MODE"]                                        = "Sort mode"
-- L["OPTIONS_CORE_SORTING_FILTERING"]                                = "Sorting & Filtering"
-- L["OPTIONS_CORE_SOUND_PLAYED_A_RARE_BOSS_APPEARS"]                 = "Sound played when a rare boss appears."
-- L["OPTIONS_CORE_STATUS_BADGES"]                                    = "Status badges"
-- L["OPTIONS_CORE_SUBZONE_CHANGES"]                                  = "Subzone changes"
-- L["OPTIONS_CORE_SUPER_TRACKED_FIRST_CURRENT_ZONE_FIRST"]           = "Super-tracked first, or current zone first."
-- L["OPTIONS_CORE_SUPPRESS_IN_ARENA_DETAIL"]                         = "Suppress all Presence notifications while inside a PvP arena."
-- L["OPTIONS_CORE_SUPPRESS_PRESENCE_NOTIFICATIONS_WHILE_INSIDE_A"]   = "Suppress all Presence notifications while inside a battleground."
-- L["OPTIONS_CORE_SUPPRESS_IN_DUNGEON_DETAIL"]                       = "Suppress all Presence notifications while inside a dungeon (except boss emotes, achievements, level-up)."
-- L["OPTIONS_CORE_SUPPRESS_IN_RAID_DETAIL"]                          = "Suppress all Presence notifications while inside a raid."
-- L["OPTIONS_CORE_SUPPRESS_M"]                                       = "Suppress in M+"
-- L["OPTIONS_CORE_SUPPRESS_PVP"]                                     = "Suppress in PvP"
-- L["OPTIONS_CORE_SUPPRESS_BATTLEGROUND"]                            = "Suppress in battleground"
-- L["OPTIONS_CORE_SUPPRESS_DUNGEON"]                                 = "Suppress in dungeon"
-- L["OPTIONS_CORE_SUPPRESS_RAID"]                                    = "Suppress in raid"
-- L["OPTIONS_CORE_SUPPRESS_NOTIFICATIONS_DUNGEONS"]                  = "Suppress notifications in dungeons."
-- L["OPTIONS_CORE_TAKES_PRIORITY_SUPPRESS_UNTIL_RELOAD_ACCEPTING"]   = "Takes priority over suppress-until-reload. Accepting removes from blacklist."
-- L["OPTIONS_CORE_TOAST_ICONS"]                                      = "Toast icons"
-- L["OPTIONS_CORE_TOGGLE_TRACKING_WORLD_QUESTS_RARES_ACHIEVEMENTS"]  = "Toggle tracking for world quests, rares, achievements, and more."
-- L["OPTIONS_CORE_TOMTOM"]                                           = "TomTom"
-- L["OPTIONS_CORE_TOOLTIP_ANCHOR"]                                   = "Tooltip anchor"
-- L["OPTIONS_CORE_TRACKED_OBJECTIVES_ADVENTURE_GUIDE"]               = "Tracked objectives from Adventure Guide."
-- L["OPTIONS_CORE_TRACKED_VS_LOG_COUNT"]                             = "Tracked vs in-log count."
-- L["OPTIONS_CORE_TRACKED_LOG_LOG_MAX_TRACKED_EXCLUDES"]             = "Tracked/in-log or in-log/max. Tracked excludes world and in-zone quests."
-- L["OPTIONS_CORE_TRANSMOG_STATUS"]                                  = "Transmog status"
-- L["OPTIONS_CORE_TRAVELER_S_LOG"]                                   = "Traveler's Log"
-- L["OPTIONS_CORE_TUNE_SLIDE_FADE_EFFECTS_PLUS_OBJECTIVE"]           = "Tune slide and fade effects, plus objective progress flashes."
-- L["OPTIONS_CORE_UNBLOCK"]                                          = "Unblock"
-- L["OPTIONS_CORE_UNTRACK_COMPLETE"]                                 = "Untrack when complete"
-- L["OPTIONS_CORE_CHECKMARK_COMPLETED_OBJECTIVES"]                   = "Use checkmark for completed objectives."
-- L["OPTIONS_CORE_VISIBILITY_FADING"]                                = "Visibility & fading"
-- L["OPTIONS_CORE_COMPLETED_QUESTS_STAY_THEIR_ORIGINAL_CATEGO"]      = "When off, completed quests stay in their original category."
-- L["OPTIONS_CORE_ZONE_QUESTS_APPEAR_THEIR_NORMAL_CATEGORY"]         = "When off, in-zone quests appear in their normal category."
-- L["OPTIONS_CORE_THEY_MOVE_COMPLETE_SECTION"]                       = "When off, they move to the Complete section."
-- L["OPTIONS_CORE_CUSTOM_FILL_COLOR_BELOW"]                          = "When off, uses the custom fill color below."
-- L["OPTIONS_CORE_COMPLETED_OBJECTIVES_COLOR_BELOW"]                 = "When on, completed objectives use the color below."
-- L["OPTIONS_CORE_WHERE_COUNTDOWN"]                                  = "Where to show the countdown."
-- L["OPTIONS_CORE_WORLD_QUEST_ACCEPT"]                               = "World quest accept"
-- L["OPTIONS_CORE_WORLD_QUEST_COMPLETE"]                             = "World quest complete"
-- L["OPTIONS_CORE_X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]           = "X/Y: objectives like 3/10. Percent: objectives like 45%."
-- L["OPTIONS_CORE_ZONE_ENTRY"]                                       = "Zone entry"
-- L["OPTIONS_CORE_ZONE_LABELS"]                                      = "Zone labels"
-- L["OPTIONS_CORE_ZONE_NAME_STILL_APPEARS_ENTERING_A"]               = "Zone name still appears when entering a new zone."
-- L["OPTIONS_CORE_ZONE_TYPE_COLORING"]                               = "Zone type coloring"
-- L["OPTIONS_CORE_TINTERFACE_BUTTONS_UI_CHECKBOX_CHECK_T"]           = "|TInterface\\\\Buttons\\\\UI-CheckBox-Check:12:12:0:0|t instead of green for done objectives."























































































































