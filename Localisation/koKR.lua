if GetLocale() ~= "koKR" then return end

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = setmetatable({}, { __index = addon.L })
addon.L = L
addon.StandardFont = UNIT_NAME_FONT

-- =====================================================================
-- OptionsPanel.lua (deprecated) — remaining strings for that UI
-- Panel title + module short names: addon.BrandDisplay (core/BrandDisplay.lua).
-- =====================================================================
L["OPTIONS_FOCUS_OTHER"]                                              = "기타"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["OPTIONS_FOCUS_QUEST_TYPES"]                                        = "퀘스트 유형"
L["OPTIONS_FOCUS_ELEMENT_OVERRIDES"]                                  = "개별 요소 색상"
L["OPTIONS_FOCUS_PER_CATEGORY"]                                       = "유형별 색상"
L["OPTIONS_FOCUS_GROUPING_OVERRIDES"]                                 = "그룹 우선 색상"
-- L["OPTIONS_FOCUS_SECTION_OVERRIDES"]                               = "Section Overrides"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_COLORS"]                                             = "기타 색상"

-- =====================================================================
-- OptionsPanel.lua — Color row labels (collapsible group sub-rows)
-- =====================================================================
L["OPTIONS_FOCUS_SECTION"]                                            = "구역"
L["OPTIONS_FOCUS_TITLE"]                                              = "제목"
L["OPTIONS_FOCUS_ZONE"]                                               = "지역"
L["OPTIONS_FOCUS_OBJECTIVE"]                                          = "목표 목록"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["OPTIONS_FOCUS_READY_TURN_OVERRIDES_BASE_COLOURS"]                  = "완료 퀘스트 색상을 우선 적용"
L["OPTIONS_FOCUS_READY_TURN_COLOURS_QUESTS"]                          = "완료 가능한 퀘스트가 있으면 해당 구역에 색상을 우선 적용합니다."
L["OPTIONS_FOCUS_CURRENT_ZONE_OVERRIDES_BASE_COLOURS"]                = "현재 지역 색상을 우선 적용"
L["OPTIONS_FOCUS_CURRENT_ZONE_COLOURS_QUESTS_SEC"]                    = "현재 지역에 해당하는 퀘스트가 있으면 해당 구역에 지역 색상을 우선 적용합니다."
L["OPTIONS_FOCUS_CURRENT_QUEST_OVERRIDES_BASE_COLOURS"]               = "현재 퀘스트 색상을 우선 적용"
L["OPTIONS_FOCUS_CURRENT_QUEST_COLOURS_QUESTS_SE"]                    = "현재 퀘스트에 해당하는 퀘스트가 있으면 해당 구역에 퀘스트 색상을 우선 적용합니다."
L["OPTIONS_FOCUS_DISTINCT_COLOR_COMPLETED_OBJECTIVES"]                = "완료된 목표에 다른 색상 사용"
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES_E_G_COLOR_B"]                   = "활성화하면 완료된 목표(예: 1/1)에 아래 색상을 사용하고, 비활성화하면 미완료 목표와 같은 색상을 사용합니다."
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVE"]                                = "완료된 목표"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["OPTIONS_FOCUS_RESET"]                                              = "초기화"
L["OPTIONS_FOCUS_RESET_QUEST_TYPES"]                                  = "퀘스트 유형 초기화"
L["OPTIONS_FOCUS_RESET_OVERRIDES"]                                    = "개별 요소 초기화"
L["OPTIONS_FOCUS_RESET_DEFAULTS"]                                     = "모든 카테고리 기본값으로 초기화"
L["OPTIONS_FOCUS_RESET_TO_DEFAULTS"]                                  = "기본값으로 초기화"
L["OPTIONS_FOCUS_RESET_DEFAULT"]                                      = "기본값으로 초기화"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["OPTIONS_FOCUS_SEARCH_SETTINGS"]                                    = "설정 검색..."
L["OPTIONS_FOCUS_SEARCH_FONTS"]                                       = "글꼴 검색..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["OPTIONS_FOCUS_DRAG_RESIZE"]                                        = "드래그하여 크기 조절"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
-- L["OPTIONS_AXIS_PROFILES"]                                         = "Profiles"  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_MODULES"]                                             = "기능"
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
L["DASH_LAYOUT"]                                                      = "레이아웃"
L["DASH_VISIBILITY"]                                                  = "표시 조건"
L["DASH_DISPLAY"]                                                     = "표시"
L["DASH_FEATURES"]                                                    = "기능"
L["DASH_TYPOGRAPHY"]                                                  = "글꼴"
L["DASH_APPEARANCE"]                                                  = "외형"
L["DASH_COLORS"]                                                      = "색상"
L["DASH_ORGANIZATION"]                                                = "정렬"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["OPTIONS_FOCUS_PANEL_BEHAVIOUR"]                                    = "패널 동작"
L["OPTIONS_FOCUS_DIMENSIONS"]                                         = "크기"
L["OPTIONS_FOCUS_INSTANCE"]                                           = "인스턴스"
-- L["OPTIONS_FOCUS_INSTANCES"]                                       = "Instances"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_COMBAT"]                                             = "전투"
L["OPTIONS_FOCUS_FILTERING"]                                          = "필터"
L["OPTIONS_FOCUS_HEADER"]                                             = "헤더"
-- L["OPTIONS_FOCUS_SECTIONS_STRUCTURE"]                              = "Sections & structure"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_ENTRY_DETAILS"]                                   = "Entry details"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_PROGRESS_TIMERS"]                                 = "Progress & timers"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_EMPHASIS"]                                        = "Focus emphasis"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_LIST"]                                               = "목표 목록"
L["OPTIONS_FOCUS_SPACING"]                                            = "간격"
L["OPTIONS_FOCUS_RARE_BOSSES"]                                        = "희귀 우두머리"
L["OPTIONS_FOCUS_WORLD_QUESTS"]                                       = "전역 퀘스트"
L["OPTIONS_FOCUS_FLOATING_QUEST_ITEM"]                                = "퀘스트 아이템 버튼"
L["OPTIONS_FOCUS_MYTHIC"]                                             = "쐐기"
L["OPTIONS_FOCUS_ACHIEVEMENTS"]                                       = "업적"
-- L["OPTIONS_FOCUS_ACHIEVEMENT_PROGRESS_BARS"]                       = "Achievement progress bars"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_ACHIEVEMENT_PROGRESS_BARS_DESC"]                  = "Show a progress bar under tracked achievements that report numeric criteria (including 0/1 and X/Y). Independent of Quest Progress Bars."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_ACHIEVEMENT_PROGRESS_BARS_TIP"]                   = "Uses the same bar colors, texture, and font as other Focus progress bars when those options are visible."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_ENDEAVORS"]                                          = "활동 과제"
L["OPTIONS_FOCUS_DECOR"]                                              = "장식"
-- L["OPTIONS_FOCUS_APPEARANCES"]                                     = "Appearances"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_SCENARIO_DELVE"]                                     = "시나리오 및 구렁"
L["OPTIONS_FOCUS_FONT"]                                               = "글꼴"
-- L["OPTIONS_FOCUS_FONT_FAMILIES"]                                   = "Font families"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_GLOBAL_FONT_SIZE"]                                = "Global font size"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_FONT_SIZES"]                                      = "Font sizes"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_PER_ELEMENT_FONTS"]                               = "Per-element fonts"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_TEXT_CASE"]                                          = "대소문자"
L["OPTIONS_FOCUS_SHADOW"]                                             = "그림자"
L["OPTIONS_FOCUS_PANEL"]                                              = "패널"
L["OPTIONS_FOCUS_HIGHLIGHT"]                                          = "강조"
L["OPTIONS_FOCUS_COLOR_MATRIX"]                                       = "색상표"
L["OPTIONS_FOCUS_ORDER"]                                              = "순서"
L["OPTIONS_FOCUS_SORT"]                                               = "정렬"
L["OPTIONS_FOCUS_BEHAVIOUR"]                                          = "동작"
L["OPTIONS_FOCUS_CONTENT_TYPES"]                                      = "콘텐츠 유형"
L["OPTIONS_FOCUS_DELVES"]                                             = "구렁"
L["OPTIONS_FOCUS_DELVES_DUNGEONS"]                                    = "구렁 & 던전"
L["OPTIONS_FOCUS_DELVE_COMPLETE"]                                     = "구렁 완료"
L["OPTIONS_FOCUS_INTERACTIONS"]                                       = "상호작용"
L["OPTIONS_FOCUS_TRACKING"]                                           = "추적"
L["OPTIONS_FOCUS_SCENARIO_BAR"]                                       = "시나리오 바"

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
L["OPTIONS_AXIS_ENABLE_FOCUS_MODULE"]                                 = "목표 목록 기능 활성화"
L["OPTIONS_AXIS_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS_R"]             = "퀘스트, 전역 퀘스트, 희귀 몹, 업적, 시나리오를 추적하는 목표 목록창을 표시합니다."
L["OPTIONS_AXIS_ENABLE_PRESENCE_MODULE"]                              = "상황 알림  활성화"
L["OPTIONS_AXIS_CINEMATIC_ZONE_TEXT_NOTIFICATIONS_ZONE_CHANGES"]      = "시네마틱 지역 텍스트 및 알림 (지역 이동, 레벨 업, 우두머리 감정 표현, 업적, 퀘스트 갱신)."
L["OPTIONS_AXIS_ENABLE_CACHE_MODULE"]                                 = "획득 알림 기능 활성화"
L["OPTIONS_AXIS_CINEMATIC_LOOT_NOTIFICATIONS_ITEMS_MONEY_CURRENCY"]   = "보기 좋은 전리품 알림창 (아이템, 금화, 통화, 평판)."
L["OPTIONS_AXIS_ENABLE_VISTA_MODULE"]                                 = "미니맵 기능 활성화"
L["OPTIONS_AXIS_CINEMATIC_SQUARE_MINIMAP_ZONE_TEXT_COORDINATES"]      = "지역 텍스트, 좌표, 버튼 수집기가 있는 보기 좋은(?) 사각형 미니맵."
-- L["OPTIONS_AXIS_MINIMAP_ZONE_TIME_COLLECTOR"]                      = "Cinematic square minimap with zone text, coordinates, time, and button collector."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_BETA"]                                             = "Beta"  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_SCALING"]                                             = "크기 조정"
-- L["OPTIONS_AXIS_GLOBAL_TOGGLES"]                                   = "Global Toggles"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_PATCH_NOTES_SECTION"]                              = "Patch notes"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN"]                   = "Show Patch Notes automatically after an update"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN_DESC"]              = "When on, Axis opens to Patch Notes once after each new addon version. When off, a green dot appears on the Horizon minimap icon until you open Patch Notes."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_SUITE_WIDE_CLASS_COLOUR_TINTING_UI"]               = "Dashboard background theme, class colour tinting, and UI scale (global or per module)."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_GLOBAL_UI_SCALE"]                                     = "전체 UI 크기 조정"
L["OPTIONS_AXIS_SCALE_SIZES_SPACINGS_FONTS_FACTOR"]                   = "모든 크기, 간격, 글꼴을 이 비율로 조정합니다 (50–200%). 설정값은 변경되지 않습니다."
L["OPTIONS_AXIS_PER_MODULE_SCALING"]                                  = "기능별 크기 조정 활성화"
L["OPTIONS_AXIS_OVERRIDE_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_FO"]         = "전체 크기 조정을 무시하고 각 기능별로 개별 슬라이더를 사용합니다."
-- L["OPTIONS_AXIS_OVERRIDES_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_F"]      = "Overrides the global scale with individual sliders for Focus, Presence, Vista, etc."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_DOESN_T_CHANGE_YOUR_CONFIGURED_VALUES"]            = "Doesn't change your configured values, only the effective display scale."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_SCALE"]                                              = "목록"
L["OPTIONS_AXIS_SCALE_FOCUS_OBJECTIVE_TRACKER"]                       = "목표 목록(추적기)의 크기 조정 (50–200%)."
L["OPTIONS_PRESENCE_SCALE"]                                           = "상황 알림"
L["OPTIONS_AXIS_SCALE_PRESENCE_CINEMATIC_TEXT"]                       = "보기 좋은 상황 알림 텍스트의 크기 조정 (50–200%)."
L["OPTIONS_VISTA_SCALE"]                                              = "미니맵"
L["OPTIONS_AXIS_SCALE_VISTA_MINIMAP_MODULE"]                          = "미니맵 기능의 크기 조정 (50–200%)."
L["OPTIONS_INSIGHT_SCALE"]                                            = "툴팁"
L["OPTIONS_AXIS_SCALE_INSIGHT_TOOLTIP_MODULE"]                        = "툴팁 크기 조정 (50–200%)."
L["OPTIONS_CACHE_SCALE"]                                              = "획득 알림"
L["OPTIONS_AXIS_SCALE_CACHE_LOOT_TOAST_MODULE"]                       = "획득 알림 기능의 크기 조정 (50–200%)."
L["OPTIONS_AXIS_ENABLE_HORIZON_INSIGHT_MODULE"]                       = "툴팁 기능 활성화"
L["OPTIONS_AXIS_CINEMATIC_TOOLTIPS_CLASS_COLORS_SPEC_DISPLAY"]        = "직업 색상, 전문화 표시, 진영 아이콘이 있는 시네마틱 툴팁."
L["OPTIONS_AXIS_TOOLTIP_ANCHOR_MODE"]                                 = "툴팁 고정 방식"
L["OPTIONS_AXIS_WHERE_TOOLTIPS_APPEAR_FOLLOW_CURSOR_FIXED"]           = "툴팁 표시 위치: 커서 추적 또는 고정 위치."
L["OPTIONS_AXIS_CURSOR"]                                              = "커서"
L["OPTIONS_AXIS_FIXED"]                                               = "고정"
L["OPTIONS_AXIS_ANCHOR_MOVE"]                                         = "이동용 상자 표시"
-- L["OPTIONS_AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITIO"]                   = "Click to show or hide the anchor. Drag to set position, right-click to confirm."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_DRAGGABLE_FRAME_FIXED_TOOLTIP_POSITION_D"]            = "고정 툴팁 위치를 설정할 드래그 가능한 프레임을 표시합니다. 드래그한 후 우클릭하여 확인(고정)합니다."
L["OPTIONS_AXIS_RESET_TOOLTIP_POSITION"]                              = "툴팁 위치 초기화"
L["OPTIONS_AXIS_RESET_FIXED_POSITION_DEFAULT"]                        = "고정된 위치를 기본값으로 초기화합니다."
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_X"]                               = "Cursor offset X"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_X_DESC"]                          = "Horizontal pixel offset from the default cursor tooltip position (cursor anchor only)."  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_Y"]                               = "Cursor offset Y"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_Y_DESC"]                          = "Vertical pixel offset from the default cursor tooltip position (cursor anchor only)."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_TOOLTIP_BACKGROUND_COLOR"]                            = "툴팁 배경 색상"
L["OPTIONS_AXIS_COLOR_OF_TOOLTIP_BACKGROUND"]                         = "툴팁 배경 색상."
L["OPTIONS_AXIS_TOOLTIP_BACKGROUND_OPACITY"]                          = "툴팁 배경 불투명도"
L["OPTIONS_AXIS_TOOLTIP_BG_OPACITY_PCT_DESC"]                         = "툴팁 배경 불투명도 (0–100%)."
L["OPTIONS_AXIS_TOOLTIP_FONT"]                                        = "툴팁 글꼴"
L["OPTIONS_AXIS_FONT_FAMILY_TOOLTIP_TEXT"]                            = "모든 툴팁 텍스트에 사용되는 글꼴 패밀리."
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
L["OPTIONS_AXIS_ICONS"]                                               = "아이콘 표시"
-- L["OPTIONS_AXIS_CLASS_ICON_STYLE"]                                 = "Class icon style"  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_DEFAULT_BLIZZARD_RONDOMEDIA_CLASS_ICONS_TH"]          = "Use Default (Blizzard) or RondoMedia class icons on the class/spec line."
L["OPTIONS_AXIS_CUSTOM_CLASS_ICONS_LABEL"]                            = "Custom (addon media)"
L["OPTIONS_AXIS_CLASS_ICON_SOURCES_TOOLTIP"]                          = "RondoMedia: https://www.curseforge.com/wow/addons/rondomedia — Custom: place one .tga per class under media/CustomClassIcons/<CLASS>/<class lower>.tga (e.g. WARRIOR/warrior.tga), then /reload."
-- L["OPTIONS_AXIS_RONDOMEDIA_CLASS_ICONS_RONDOFERRARI_HTTPS_WWW"]    = "RondoMedia class icons by RondoFerrari — https://www.curseforge.com/wow/addons/rondomedia"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_DEFAULT"]                                          = "Default"  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_FACTION_SPEC_MOUNT_MYTHIC_ICONS_TOOLTIPS"]            = "툴팁에 진영, 전문화, 탈것, Mythic+ 아이콘 표시."
L["OPTIONS_AXIS_GENERAL"]                                             = "일반"
L["OPTIONS_AXIS_POSITION"]                                            = "위치"
L["OPTIONS_AXIS_RESET_POSITION"]                                      = "위치 초기화"
L["OPTIONS_AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"]                   = "전리품 알림 위치를 기본값으로 초기화합니다."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["OPTIONS_FOCUS_LOCK_POSITION"]                                      = "위치 잠금"
L["OPTIONS_FOCUS_PREVENT_DRAGGING_TRACKER"]                           = "목록을 드래그할 수 없게 합니다."
L["OPTIONS_FOCUS_GROW_UPWARD"]                                        = "위로 확장"
L["OPTIONS_FOCUS_GROW_HEADER"]                                        = "위로 확장 헤더"
L["OPTIONS_FOCUS_GROWING_UPWARD_KEEP_HEADER_BOTTOM_TOP"]              = "위로 확장 시: 헤더를 아래에 두거나 접을 때까지 위에 둡니다."
L["OPTIONS_FOCUS_HEADER_BOTTOM"]                                      = "헤더 아래"
L["OPTIONS_FOCUS_HEADER_SLIDES_COLLAPSE"]                             = "접을 때 헤더 슬라이드"
L["OPTIONS_FOCUS_ANCHOR_BOTTOM_LIST_GROWS_UPWARD"]                    = "아래 기준으로 목록이 위쪽으로 확장됩니다."
L["OPTIONS_FOCUS_START_COLLAPSED"]                                    = "접힌 상태로 시작"
L["OPTIONS_FOCUS_START_HEADER_SHOWN_UNTIL_YOU_EXPAND"]                = "펼치기 전까지 헤더만 표시합니다."
-- L["OPTIONS_FOCUS_ALIGN_CONTENT_RIGHT"]                             = "Align content right"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_RIGHT_ALIGN_QUEST_TITLES_OBJECTIVES_WITHIN"]      = "Right-align quest titles and objectives within the panel."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_PANEL_WIDTH"]                                        = "패널 너비"
L["OPTIONS_FOCUS_TRACKER_WIDTH_PIXELS"]                               = "목록 너비 (픽셀)."
L["OPTIONS_FOCUS_MAX_CONTENT_HEIGHT"]                                 = "최대 콘텐츠 높이"
L["OPTIONS_FOCUS_MAX_HEIGHT_OF_SCROLLABLE_LIST_PIXELS"]               = "스크롤 목록의 최대 높이 (픽셀)."

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["OPTIONS_FOCUS_ALWAYS_M_BLOCK"]                                     = "쐐기 항상 표시"
L["OPTIONS_FOCUS_M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]                = "활성 쐐기 실행 중에는 쐐기 블록을 항상 표시합니다."
L["OPTIONS_FOCUS_DUNGEON"]                                            = "던전에서 표시"
L["OPTIONS_FOCUS_TRACKER_PARTY_DUNGEONS"]                             = "파티 던전에서 추적기를 표시합니다."
L["OPTIONS_FOCUS_RAID"]                                               = "공격대에서 표시"
L["OPTIONS_FOCUS_TRACKER_RAIDS"]                                      = "공격대에서 추적기를 표시합니다."
L["OPTIONS_FOCUS_BATTLEGROUND"]                                       = "전장에서 표시"
L["OPTIONS_FOCUS_TRACKER_BATTLEGROUNDS"]                              = "전장에서 추적기를 표시합니다."
L["OPTIONS_FOCUS_ARENA"]                                              = "투기장에서 표시"
L["OPTIONS_FOCUS_TRACKER_ARENAS"]                                     = "투기장에서 추적기를 표시합니다."
L["OPTIONS_FOCUS_HIDE_COMBAT"]                                        = "전투 중 숨기기"
L["OPTIONS_FOCUS_HIDE_TRACKER_FLOATING_QUEST_ITEM_COMBAT"]            = "전투 중 추적기와 퀘스트 아이템 버튼을 숨깁니다."
L["OPTIONS_FOCUS_COMBAT_VISIBILITY"]                                  = "전투 중 표시"
L["OPTIONS_FOCUS_TRACKER_BEHAVES_COMBAT_FADE_REDUC"]                  = "전투 중 추적기 동작: 표시, 흐리게 표시 또는 숨기기."
L["OPTIONS_FOCUS_SHOW"]                                               = "표시"
L["OPTIONS_FOCUS_FADE"]                                               = "흐리게"
L["OPTIONS_FOCUS_HIDE"]                                               = "숨기기"
L["OPTIONS_FOCUS_COMBAT_FADE_OPACITY"]                                = "전투 중 흐림 투명도"
L["OPTIONS_FOCUS_VISIBLE_TRACKER_FADED_COMBAT"]                       = "전투 중 목록의 투명도 정도 (0 = 완전 투명). 전투 중 표시가 흐리게일 때만 적용됩니다."
L["OPTIONS_FOCUS_MOUSEOVER"]                                          = "마우스 오버"
L["OPTIONS_FOCUS_SHOW_ONLY_MOUSEOVER"]                                = "마우스 오버 시에만 표시"
L["OPTIONS_FOCUS_FADE_TRACKER_HOVERING_MOVE_MOUSE"]                   = "마우스를 올리지 않으면 목록을 흐리게 표시합니다. 마우스를 올리면 표시됩니다."
L["OPTIONS_FOCUS_FADED_OPACITY"]                                      = "흐림 투명도"
L["OPTIONS_FOCUS_VISIBLE_TRACKER_FADED_INVISIBLE"]                    = "흐릿할 때 목록의 표시 정도 (0 = 완전 투명)."
L["OPTIONS_FOCUS_QUESTS_CURRENT_ZONE"]                                = "현재 지역 퀘스트만 표시"
L["OPTIONS_FOCUS_HIDE_QUESTS_OUTSIDE_YOUR_CURRENT_ZONE"]              = "현재 지역 밖의 퀘스트를 숨깁니다."

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["OPTIONS_FOCUS_QUEST_COUNT"]                                        = "퀘스트 수 표시"
L["OPTIONS_FOCUS_QUEST_COUNT_HEADER"]                                 = "헤더에 퀘스트 수를 표시합니다."
L["OPTIONS_FOCUS_HEADER_COUNT_FORMAT"]                                = "헤더 수 표시 형식"
L["OPTIONS_FOCUS_TRACKED_LOG_LOG_MAX_SLOTS_TRACKED"]                  = "추적 중/퀘스트 목록 또는 퀘스트 목록/최대 슬롯. 추적 수에는 전역 퀘스트가 포함되지 않습니다."
L["OPTIONS_FOCUS_HEADER_DIVIDER"]                                     = "헤더 구분선 표시"
L["OPTIONS_FOCUS_LINE_BELOW_HEADER"]                                  = "헤더 아래 구분선을 표시합니다."
L["OPTIONS_FOCUS_HEADER_DIVIDER_COLOR"]                               = "헤더 구분선 색상"
L["OPTIONS_FOCUS_COLOR_OF_LINE_BELOW_HEADER"]                         = "헤더 아래 선의 색상."
L["OPTIONS_FOCUS_SUPER_MINIMAL_MODE"]                                 = "간결하게 표시"
L["OPTIONS_FOCUS_HIDE_HEADER_A_PURE_TEXT_LIST"]                       = "헤더를 숨기고 텍스트 목록만 표시합니다."
L["OPTIONS_FOCUS_OPTIONS_BUTTON"]                                     = "옵션 버튼 표시"
L["OPTIONS_FOCUS_OPTIONS_BUTTON_TRACKER_HEADER"]                      = "추적기 헤더에 옵션 버튼을 표시합니다."
L["OPTIONS_FOCUS_HEADER_COLOR"]                                       = "헤더 색상"
L["OPTIONS_FOCUS_COLOR_OF_OBJECTIVES_HEADER_TEXT"]                    = "목표 헤더 텍스트의 색상."
L["OPTIONS_FOCUS_HEADER_HEIGHT"]                                      = "헤더 높이"
L["OPTIONS_FOCUS_HEIGHT_OF_HEADER_BAR_PIXELS"]                        = "헤더 바 높이 (픽셀, 18–48)."

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["OPTIONS_FOCUS_SECTION_HEADERS"]                                    = "구역 헤더 표시"
L["OPTIONS_FOCUS_CATEGORY_LABELS_ABOVE_GROUP"]                        = "각 그룹 위에 유형 라벨을 표시합니다."
L["OPTIONS_FOCUS_CATEGORY_HEADERS_COLLAPSED"]                         = "접힌 상태에서 구역 헤더 표시"
L["OPTIONS_FOCUS_KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED_CLICK"]       = "접힌 상태에서도 구역 헤더를 표시합니다. 클릭하면 해당 유형을 펼칩니다."
L["OPTIONS_FOCUS_NEARBY_CURRENT_ZONE_GROUP"]                          = "근처(현재 지역) 그룹 표시"
L["OPTIONS_FOCUS_ZONE_QUESTS_A_DEDICATED_CURRENT_ZONE"]               = "현재 지역 퀘스트를 전용 구역으로 표시합니다. 끄면 기존 유형에 그대로 표시됩니다."
L["OPTIONS_FOCUS_ZONE_LABELS"]                                        = "지역명 표시"
L["OPTIONS_FOCUS_ZONE_NAME_UNDER_QUEST_TITLE"]                        = "각 퀘스트 제목 아래에 지역명을 표시합니다."
L["OPTIONS_FOCUS_ACTIVE_QUEST_HIGHLIGHT"]                             = "퀘스트 강조"
L["OPTIONS_FOCUS_FOCUSED_QUEST_HIGHLIGHTED"]                          = "퀘스트의 강조 방식."
L["OPTIONS_FOCUS_QUEST_ITEM_BUTTONS"]                                 = "퀘스트 아이템 버튼 표시"
L["OPTIONS_FOCUS_USABLE_QUEST_ITEM_BUTTON_NEXT_QUEST"]                = "각 퀘스트 옆에 사용 가능한 아이템 버튼을 표시합니다."
-- L["OPTIONS_FOCUS_TOOLTIPS_HOVER"]                                  = "Tooltips on hover"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_TOOLTIPS_HOVERING_TRACKER_ENTRIES_ITE"]           = "Show tooltips when hovering over tracker entries, item buttons, and scenario blocks."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_WOWHEAD_LINK_TOOLTIPS"]                           = "Show WoWhead link in tooltips"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_A_TOOLTIP_SHOWN_ADD_A_LINK"]                      = "When a tooltip is shown, add a link to open the quest, achievement, or NPC on WoWhead."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_VIEW_WOWHEAD"]                                    = "View on WoWhead"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_WOWHEAD_ALT_CLICK_HINT"]                             = "Alt+click row to copy"
-- L["OPTIONS_FOCUS_COPY_LINK"]                                       = "Copy link"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_COPY_URL_BELOW_CTRL_C_PASTE"]                     = "Copy the URL below (Ctrl+C) and paste in your browser."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_OBJECTIVE_NUMBERS"]                                  = "목표 번호 표시"
-- L["OPTIONS_FOCUS_OBJECTIVE_PREFIX"]                                = "Objective prefix"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLORS"]                = "Color objective progress numbers"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLORS_DESC"]              = "Tint X/Y counts: normal color at 0/n, gold while in progress, green when complete. The slash uses the usual objective color."
-- L["OPTIONS_FOCUS_PREFIX_OBJECTIVE_A_NUMBER_HYPHEN"]                = "Prefix each objective with a number or hyphen."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_NUMBERS"]                                         = "Numbers (1. 2. 3.)"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_HYPHENS"]                                         = "Hyphens (-)"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_AFTER_SECTION_HEADER"]                            = "After section header"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_BEFORE_SECTION_HEADER"]                           = "Before section header"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_BELOW_HEADER"]                                    = "Below header"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_INLINE_BELOW_TITLE"]                              = "Inline below title"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_PREFIX_OBJECTIVES"]                                  = "목표 앞에 1., 2., 3. 번호를 붙입니다."
L["OPTIONS_FOCUS_COMPLETED_COUNT"]                                    = "완료 수 표시"
L["OPTIONS_FOCUS_X_Y_PROGRESS_QUEST_TITLE"]                           = "퀘스트 제목에 X/Y 진행도를 표시합니다."
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_BAR"]                             = "목표 진행 바 표시"
L["OPTIONS_FOCUS_A_PROGRESS_BAR_UNDER_OBJECTIVES_NUMER"]              = "숫자 진행도가 있는 목표 아래에 진행 바를 표시합니다 (예: 3/250). 필요 수량이 1보다 큰 단일 산술 목표가 있는 항목에만 적용됩니다."
L["OPTIONS_FOCUS_CATEGORY_COLOR_PROGRESS_BAR"]                        = "진행 바에 카테고리 색상 사용"
L["OPTIONS_FOCUS_PROGRESS_BAR_MATCHES_QUEST_ACHIEVEME"]               = "활성화하면 진행 바가 퀘스트/업적 카테고리 색상과 일치합니다. 비활성화하면 아래의 사용자 지정 채우기 색상을 사용합니다."
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXTURE"]                               = "진행 바 텍스처"
L["OPTIONS_FOCUS_PROGRESS_BAR_TYPES"]                                 = "진행 바 유형"
L["OPTIONS_FOCUS_TEXTURE_PROGRESS_BAR_FILL"]                          = "진행 바 채우기 텍스처."
L["OPTIONS_FOCUS_TEXTURE_PROGRESS_BAR_FILL_SOLID_YOUR"]               = "채우기 텍스처. 단색은 선택한 색상을 사용합니다. SharedMedia 애드온으로 추가 옵션을 사용할 수 있습니다."
L["OPTIONS_FOCUS_PROGRESS_BAR_X_Y_OBJECTIVES_PERCENT"]                = "X/Y 목표, 퍼센트 전용 목표 또는 둘 다에 진행 바를 표시합니다."
L["OPTIONS_FOCUS_X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]             = "X/Y: 3/10 같은 목표. 퍼센트: 45% 같은 목표."
L["OPTIONS_FOCUS_X_Y"]                                                = "X/Y만"
L["OPTIONS_FOCUS_PERCENT"]                                            = "퍼센트만"
L["OPTIONS_FOCUS_TICK_COMPLETED_OBJECTIVES"]                          = "완료된 목표에 체크 표시 사용"
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES_A_CHECKMARK_INSTEA"]            = "활성화하면 완료된 목표에 초록색 대신 체크 표시(✓)가 나타납니다."
L["OPTIONS_FOCUS_ENTRY_NUMBERS"]                                      = "항목 번호 표시"
L["OPTIONS_FOCUS_PREFIX_QUEST_TITLES_WITHIN_CATEGORY"]                = "각 유형 내에서 퀘스트 제목 앞에 1., 2., 3. 번호를 붙입니다."
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES"]                               = "완료된 목표"
L["OPTIONS_FOCUS_MULTI_OBJECTIVE_QUESTS_DISPLAY_OBJECTIVES"]          = "다중 목표 퀘스트에서 완료된 목표(예: 1/1) 표시 방식."
L["OPTIONS_FOCUS_ALL"]                                                = "모두 표시"
L["OPTIONS_FOCUS_FADE_COMPLETED"]                                     = "완료 시 흐리게"
L["OPTIONS_FOCUS_HIDE_COMPLETED"]                                     = "완료 시 숨기기"
L["OPTIONS_FOCUS_ICON_ZONE_AUTO_TRACKING"]                            = "지역 내 자동 추적 아이콘 표시"
L["OPTIONS_FOCUS_DISPLAY_AN_ICON_NEXT_AUTO_TRACKED"]                  = "퀘스트 로그에 없는 자동 추적된 전역 퀘스트 및 주간/일일 퀘스트 옆에 아이콘을 표시합니다 (지역 내에서만)."
L["OPTIONS_FOCUS_AUTO_TRACK_ICON"]                                    = "자동 추적 아이콘"
L["OPTIONS_FOCUS_CHOOSE_WHICH_ICON_DISPLAY_NEXT_AUTO"]                = "지역 내 자동 추적 항목 옆에 표시할 아이콘을 선택합니다."
L["OPTIONS_FOCUS_APPEND_WORLD_QUESTS_WEEKLIES_DAILIES"]               = "퀘스트 목록에 없는 전역 퀘스트/주간·일일 퀘스트에 ** 접미사를 붙입니다 (해당 지역 내에서만)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["OPTIONS_FOCUS_COMPACT_MODE"]                                       = "간결 하게"
L["OPTIONS_FOCUS_PRESET_SETS_ENTRY_OBJECTIVE_SPACING_P"]              = "사전 설정: 퀘스트 간격 4px, 목표 간격 1px로 설정합니다."
L["OPTIONS_FOCUS_SPACING_PRESET"]                                     = "간격 사전 설정"
L["OPTIONS_FOCUS_PRESET_ENTRY_OBJECTIVE_SPACING_DEFAULT_P"]           = "사전 설정: 기본(8/2 px), 간결(4/1 px), 여백(12/3 px) 또는 사용자 지정(슬라이더 사용)."
L["OPTIONS_FOCUS_COMPACT_VERSION"]                                    = "간결 버전"
L["OPTIONS_FOCUS_SPACED_VERSION"]                                     = "여백 버전"
L["OPTIONS_FOCUS_SPACING_BETWEEN_QUEST_ENTRIES_PX"]                   = "퀘스트 항목 간격 (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_QUEST_ENTRIES"]                 = "퀘스트 항목 사이의 세로 간격."
L["OPTIONS_FOCUS_SPACING_BEFORE_CATEGORY_HEADER_PX"]                  = "구역 헤더 위 간격 (px)"
L["OPTIONS_FOCUS_GAP_BETWEEN_LAST_ENTRY_OF_A"]                        = "이전 그룹의 마지막 항목과 다음 구역 라벨 사이의 간격."
L["OPTIONS_FOCUS_SPACING_AFTER_CATEGORY_HEADER_PX"]                   = "구역 헤더 아래 간격 (px)"
L["OPTIONS_FOCUS_GAP_BETWEEN_CATEGORY_LABEL_FIRST_QUEST"]             = "구역 라벨과 첫 번째 퀘스트 항목 사이의 간격."
L["OPTIONS_FOCUS_SPACING_BETWEEN_OBJECTIVES_PX"]                      = "목표 간격 (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVE_LINES_WITHIN"]        = "퀘스트 내 목표 줄 사이의 세로 간격."
L["OPTIONS_FOCUS_TITLE_CONTENT"]                                      = "제목과 내용 간격"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_QUEST_TITLE_OBJECTIVES"]        = "퀘스트 제목과 아래 목표 또는 지역 사이의 세로 간격."
L["OPTIONS_FOCUS_SPACING_BELOW_HEADER_PX"]                            = "헤더 아래 간격 (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVES_BAR_QUES"]           = "목표 바와 퀘스트 목록 사이의 세로 간격."
L["OPTIONS_FOCUS_RESET_SPACING"]                                      = "간격 초기화"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_QUEST_LEVEL"]                                   = "퀘스트 레벨 표시"
L["OPTIONS_FOCUS_QUEST_LEVEL_NEXT_TITLE"]                             = "제목 옆에 퀘스트 레벨을 표시합니다."
L["OPTIONS_FOCUS_DIM_FOCUSED_QUESTS"]                                 = "비활성 퀘스트 흐리게"
L["OPTIONS_FOCUS_SLIGHTLY_DIM_TITLE_ZONE_OBJECTIVES_SECTION"]         = "포커스되지 않은 퀘스트의 제목, 지역, 목표, 구역 헤더를 약간 흐리게 표시합니다."
-- L["OPTIONS_FOCUS_DIM_UNFOCUSED_ENTRIES"]                           = "Dim unfocused entries"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_A_SECTION_HEADER_EXPAND_CATEGORY"]          = "Click a section header to expand that category."  -- NEEDS TRANSLATION

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["UI_SHOW_RARE_BOSSES"]                                              = "희귀 우두머리 표시"
L["UI_RARE_BOSS_VIGNETTES_LIST"]                                      = "목록에 희귀 우두머리를 표시합니다."
L["UI_RARE_LOOT"]                                                     = "희귀 전리품"
L["UI_TREASURE_ITEM_VIGNETTES_RARE_LOOT"]                             = "희귀 전리품 목록에 보물과 아이템을 표시합니다."
L["UI_RARE_SOUND_VOLUME"]                                             = "희귀 전리품 소리 볼륨"
L["UI_VOLUME_OF_RARE_ALERT_SOUND"]                                    = "희귀 전리품 알림 소리 볼륨 (50–200%)."
L["UI_BOOST_REDUCE_RARE_ALERT_VOLUME"]                                = "볼륨 조절. 100% = 기본; 150% = 더 크게."
L["UI_RARE_ADDED_SOUND"]                                              = "희귀 몹 등장 효과음"
L["UI_PLAY_A_SOUND_A_RARE"]                                           = "희귀 몹이 추가되면 효과음을 재생합니다."
-- L["UI_MINIMAP_PATCH_NOTES_UNREAD_HINT"]                            = "New patch notes — open Axis and choose Patch Notes."  -- NEEDS TRANSLATION

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["OPTIONS_FOCUS_ZONE_WORLD_QUESTS"]                                  = "현재 지역 전역 퀘스트 표시"
L["OPTIONS_FOCUS_AUTO_ADD_WORLD_QUESTS_YOUR_CURRENT"]                 = "현재 지역의 전역 퀘스트를 자동으로 표시합니다. 끄면 추적 목록에 있거나 퀘스트 지역에 가까이 있는 전역 퀘스트만 표시됩니다 (블리자드 기본값)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_FLOATING_QUEST_ITEM"]                           = "퀘스트 아이템 버튼 표시"
L["OPTIONS_FOCUS_QUICK_BUTTON_FOCUSED_QUEST_S_USABLE"]                = "고정된 퀘스트의 사용 가능한 아이템을 빠른 사용 버튼으로 표시합니다."
L["OPTIONS_FOCUS_LOCK_FLOATING_QUEST_ITEM_POSITION"]                  = "퀘스트 아이템 버튼 위치 잠금"
L["OPTIONS_FOCUS_PREVENT_DRAGGING_FLOATING_QUEST_ITEM_BUTTON"]        = "퀘스트 아이템 버튼을 드래그할 수 없게 합니다."
L["OPTIONS_FOCUS_FLOATING_QUEST_ITEM_SOURCE"]                         = "퀘스트 아이템 버튼 소스"
L["OPTIONS_FOCUS_WHICH_QUEST_S_ITEM_SUPER_TRACKED"]                   = "표시할 퀘스트 아이템: 초점 퀘스트 우선 또는 현재 지역 우선."
L["OPTIONS_FOCUS_SUPER_TRACKED_FIRST"]                                = "고정 퀘스트 우선"
L["OPTIONS_FOCUS_CURRENT_ZONE_FIRST"]                                 = "현재 지역 우선"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["OPTIONS_FOCUS_MYTHIC_BLOCK"]                                       = "쐐기 정보 표시"
L["OPTIONS_FOCUS_TIMER_COMPLETION_AFFIXES_MYTHIC_DUNGEONS"]           = "쐐기 던전에서 시간, 완료율, 쐐기 속성을 표시합니다."
L["OPTIONS_FOCUS_M_BLOCK_POSITION"]                                   = "쐐기 정보 표시 위치"
L["OPTIONS_FOCUS_POSITION_OF_MYTHIC_BLOCK_RELATIVE_QUEST"]            = "퀘스트 목록에 대한 쐐기 정보 표시의 위치."
L["OPTIONS_FOCUS_AFFIX_ICONS"]                                        = "시즌 효과 아이콘 표시"
L["OPTIONS_FOCUS_AFFIX_ICONS_NEXT_MODIFIER_NAMES_M"]                  = "시즌 효과 이름 옆에 아이콘을 표시합니다."
L["OPTIONS_FOCUS_AFFIX_DESCRIPTIONS_TOOLTIP"]                         = "툴팁에 시즌 효과 설명 표시"
L["OPTIONS_FOCUS_AFFIX_DESCRIPTIONS_HOVERING_M_BLO"]                  = "표시 위에 마우스를 올리면 시즌 효과 설명을 표시합니다."
L["OPTIONS_FOCUS_M_COMPLETED_BOSS_DISPLAY"]                           = "처치 우두머리 표시"
L["OPTIONS_FOCUS_DEFEATED_BOSSES_CHECKMARK_ICON_GREEN"]               = "처치한 우두머리 표시 방식: 체크 아이콘 또는 초록색."
L["OPTIONS_FOCUS_CHECKMARK"]                                          = "체크 표시"
L["OPTIONS_FOCUS_GREEN_COLOR"]                                        = "초록색"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["OPTIONS_PRESENCE_ACHIEVEMENTS"]                                    = "업적 표시"
L["OPTIONS_FOCUS_TRACKED_ACHIEVEMENTS_LIST"]                          = "추적 중인 업적을 목록에 표시합니다."
L["OPTIONS_FOCUS_COMPLETED_ACHIEVEMENTS"]                             = "완료된 업적 표시"
L["OPTIONS_FOCUS_INCLUDE_COMPLETED_ACHIEVEMENTS_TRACKER_O"]           = "완료된 업적도 목록에 표시합니다. 끄면 진행 중인 업적만 표시됩니다."
L["OPTIONS_FOCUS_ACHIEVEMENT_ICONS"]                                  = "업적 아이콘 표시"
L["OPTIONS_FOCUS_ACHIEVEMENT_S_ICON_NEXT_TITLE_REQUI"]                = "각 업적의 아이콘을 제목 옆에 표시합니다. '퀘스트 유형 아이콘 표시' 옵션이 필요합니다."
L["OPTIONS_FOCUS_MISSING_REQUIREMENTS"]                               = "미완료 조건만 표시"
L["OPTIONS_FOCUS_CRITERIA_YOU_HAVEN_T_COMPLETED_TR"]                  = "추적 중인 업적에서 미완료 조건만 표시합니다. 끄면 모든 조건을 표시합니다."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_ENDEAVORS"]                                     = "활동 과제 표시"
L["OPTIONS_FOCUS_TRACKED_ENDEAVORS_PLAYER_HOUSING_LIST"]              = "추적 중인 활동 과제(플레이어 주택)를 목록에 표시합니다."
L["OPTIONS_FOCUS_COMPLETED_ENDEAVORS"]                                = "완료된 활동 과제 표시"
L["OPTIONS_FOCUS_INCLUDE_COMPLETED_ENDEAVORS_TRACKER"]                = "완료된 활동 과제도 추적기에 표시합니다. 끄면 진행 중인 활동 과제만 표시됩니다."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_DECOR"]                                         = "장식 표시"
L["OPTIONS_FOCUS_TRACKED_HOUSING_DECOR_LIST"]                         = "추적 중인 주택 장식을 목록에 표시합니다."
L["OPTIONS_FOCUS_DECOR_ICONS"]                                        = "장식 아이콘 표시"
L["OPTIONS_FOCUS_DECOR_ITEM_S_ICON_NEXT_TITLE"]                       = "각 장식 아이템의 아이콘을 제목 옆에 표시합니다. '퀘스트 유형 아이콘 표시' 옵션이 필요합니다."

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
L["OPTIONS_FOCUS_ADVENTURE_GUIDE"]                                    = "모험 안내서"
L["OPTIONS_FOCUS_TRAVELER_S_LOG"]                                     = "여행자의 기록 표시"
L["OPTIONS_FOCUS_TRACKED_TRAVELER_S_LOG_OBJECTIVES_SHIFT"]            = "추적 중인 여행자의 기록 목표(모험 안내서에서 Shift+클릭)를 목록에 표시합니다."
L["OPTIONS_FOCUS_AUTO_REMOVE_COMPLETED_ACTIVITIES"]                   = "완료된 활동 자동 제거"
L["OPTIONS_FOCUS_AUTOMATICALLY_STOP_TRACKING_TRAVELER_S_LOG"]         = "완료된 여행자의 기록 활동의 추적을 자동으로 중지합니다."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["OPTIONS_FOCUS_SCENARIO_EVENTS"]                                    = "시나리오 표시"
L["OPTIONS_FOCUS_ACTIVE_SCENARIO_DELVE_ACTIVITIES_DELVES_APP"]        = "시나리오와 구렁을 표시합니다. 구렁은 DELVES에, 기타 시나리오는 SCENARIO EVENTS에 표시됩니다."
L["OPTIONS_FOCUS_TRACK_DELVE_DUNGEON_SCENARIO_ACTIVITIES"]            = "구렁, 던전 및 시나리오 활동을 추적합니다."
L["OPTIONS_FOCUS_DELVES_APPEAR_DELVES_SECTION_DUNGEONS_DUNGEON"]      = "구렁은 DELVES에, 던전은 DUNGEON에, 기타 시나리오는 SCENARIO EVENTS에 표시됩니다."
-- L["OPTIONS_FOCUS_DELVES_APPEAR_DELVES_SECTION_SCENARIOS_S"]        = "Delves appear in Delves section; other scenarios in Scenario Events."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DELVE_AFFIX_NAMES"]                               = "Delve affix names"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DELVE_DUNGEON"]                                   = "Delve/Dungeon only"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_SCENARIO_DEBUG_LOGGING"]                          = "Scenario debug logging"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_LOG_SCENARIO_API_DATA_CHAT_H"]                    = "Log scenario API data to chat. Use /h debug focus scendebug to toggle."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_PRINTS_C_SCENARIOINFO_CRITERIA_WIDGET_DATA"]      = "Prints C_ScenarioInfo criteria and widget data when in a scenario. Helps diagnose display issues like Abundance 46/300."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_HIDE_CATEGORIES_DELVE_DUNGEON"]                      = "구렁/던전에서 다른 유형 숨기기"
L["OPTIONS_FOCUS_DELVES_PARTY_DUNGEONS_DELVE_DUNG"]                   = "구렁 또는 파티 던전에서는 해당 구역만 표시합니다."
L["OPTIONS_FOCUS_DELVE_NAME_SECTION_HEADER"]                          = "구렁명을 구역 헤더로 사용"
L["OPTIONS_FOCUS_A_DELVE_DELVE_NAME_TIER_AFFIXES"]                    = "구렁 중일 때 별도 배너 대신 구역 헤더에 구렁명, 난이도 단계, 시즌 효과를 표시합니다. 끄면 목록 위에 구렁 블록이 표시됩니다."
L["OPTIONS_FOCUS_AFFIX_NAMES_DELVES"]                                 = "구렁에 시즌 효과 표시"
L["OPTIONS_FOCUS_SEASON_AFFIX_NAMES_FIRST_DELVE_ENTRY"]               = "첫 번째 구렁 항목에 시즌 효과 이름을 표시합니다. Blizzard 목표 추적기 위젯이 필요하며, 전체 추적기 대체 시 표시되지 않을 수 있습니다."
L["OPTIONS_FOCUS_CINEMATIC_SCENARIO_BAR"]                             = "보기 좋은 시나리오 바"
L["OPTIONS_FOCUS_TIMER_PROGRESS_BAR_SCENARIO_ENTRIES"]                = "시나리오 항목에 시간과 진행 바를 표시합니다."
L["OPTIONS_FOCUS_TIMER"]                                              = "타이머 표시"
L["OPTIONS_FOCUS_COUNTDOWN_TIMER_TIMED_QUESTS_EVENTS_SCEN"]           = "제한 시간 퀘스트, 이벤트, 시나리오에서 카운트다운 타이머 표시. 끄면 모든 유형의 타이머가 숨겨집니다."
L["OPTIONS_FOCUS_TIMER_SCENARIOS"]                                    = "Timers: scenarios & delves"
L["OPTIONS_FOCUS_TIMER_SCENARIOS_DESC"]                               = "Countdown timer for scenario, delve, and dungeon tracker entries."
L["OPTIONS_FOCUS_TIMER_WORLD"]                                        = "Timers: world & callings"
L["OPTIONS_FOCUS_TIMER_WORLD_DESC"]                                   = "Countdown timer for world quests and callings."
L["OPTIONS_FOCUS_TIMER_QUEST_LOG"]                                    = "Timers: quest log (timed)"
L["OPTIONS_FOCUS_TIMER_QUEST_LOG_DESC"]                               = "Countdown timer for dailies, weeklies, and other quest log entries with a time limit."
L["OPTIONS_FOCUS_TIMER_DISPLAY"]                                      = "타이머 표시"
L["OPTIONS_FOCUS_COLOR_TIMER_REMAINING"]                              = "남은 시간에 따른 타이머 색상"
L["OPTIONS_FOCUS_GREEN_PLENTY_OF_LEFT_YELLOW_RUNNING"]                = "여유 있을 때 녹색, 부족할 때 노란색, 위급할 때 빨간색."
L["OPTIONS_FOCUS_WHERE_COUNTDOWN_BAR_BELOW_OBJECTIVES"]               = "카운트다운 표시 위치: 목표 아래 막대 또는 퀘스트 이름 옆 텍스트."
L["OPTIONS_FOCUS_BAR_BELOW"]                                          = "아래 막대"
L["OPTIONS_FOCUS_INLINE_BESIDE_TITLE"]                                = "제목 옆"

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["OPTIONS_FOCUS_FONT_FAMILY"]                                        = "글꼴."
L["OPTIONS_FOCUS_TITLE_FONT"]                                         = "제목 글꼴"
L["OPTIONS_VISTA_ZONE_FONT"]                                          = "지역 글꼴"
L["OPTIONS_FOCUS_OBJECTIVE_FONT"]                                     = "목표 글꼴"
L["OPTIONS_FOCUS_SECTION_FONT"]                                       = "구역 글꼴"
L["OPTIONS_FOCUS_GLOBAL_FONT"]                                        = "전역 글꼴 사용"
L["OPTIONS_FOCUS_FONT_FAMILY_QUEST_TITLES"]                           = "퀘스트 제목 글꼴."
L["OPTIONS_FOCUS_FONT_FAMILY_ZONE_LABELS"]                            = "지역명 글꼴."
L["OPTIONS_FOCUS_FONT_FAMILY_OBJECTIVE_TEXT"]                         = "목표 글꼴."
L["OPTIONS_FOCUS_FONT_FAMILY_SECTION_HEADERS"]                        = "구역 헤더 글꼴."
L["OPTIONS_FOCUS_HEADER_SIZE"]                                        = "헤더 크기"
L["OPTIONS_FOCUS_HEADER_FONT_SIZE"]                                   = "헤더 글자 크기."
L["OPTIONS_FOCUS_TITLE_SIZE"]                                         = "제목 크기"
L["OPTIONS_FOCUS_QUEST_TITLE_FONT_SIZE"]                              = "퀘스트 제목 글자 크기."
L["OPTIONS_FOCUS_OBJECTIVE_SIZE"]                                     = "목표 크기"
L["OPTIONS_FOCUS_OBJECTIVE_TEXT_FONT_SIZE"]                           = "목표 텍스트 글자 크기."
L["OPTIONS_FOCUS_ZONE_SIZE"]                                          = "지역 크기"
L["OPTIONS_FOCUS_ZONE_LABEL_FONT_SIZE"]                               = "지역명 글자 크기."
L["OPTIONS_FOCUS_SECTION_SIZE"]                                       = "구역 크기"
L["OPTIONS_FOCUS_SECTION_HEADER_FONT_SIZE"]                           = "구역 헤더 글자 크기."
L["OPTIONS_FOCUS_PROGRESS_BAR_FONT"]                                  = "진행 바 글꼴"
L["OPTIONS_FOCUS_FONT_FAMILY_PROGRESS_BAR_LABEL"]                     = "진행 바 텍스트의 글자."
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXT_SIZE"]                             = "진행 바 텍스트 크기"
L["OPTIONS_FOCUS_FONT_SIZE_PROGRESS_BAR_LABEL_ADJUSTS"]               = "진행 바 글자 크기. 바 높이도 함께 조정됩니다. 퀘스트 목표, 시나리오 진행 및 시나리오 타이머 바에 적용됩니다."
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL"]                                  = "진행 바 채우기"
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXT"]                                  = "진행 바 글자"
L["OPTIONS_FOCUS_OUTLINE"]                                            = "외곽선"
L["OPTIONS_FOCUS_FONT_OUTLINE_STYLE"]                                 = "글꼴에 적용할 외곽선 종류를 설정합니다."

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["OPTIONS_FOCUS_HEADER_TEXT_CASE"]                                   = "헤더 대소문자"
L["OPTIONS_FOCUS_DISPLAY_CASE_HEADER"]                                = "헤더의 대소문자 표시 방식."
L["OPTIONS_FOCUS_SECTION_HEADER_CASE"]                                = "구역 헤더 대소문자"
L["OPTIONS_FOCUS_DISPLAY_CASE_CATEGORY_LABELS"]                       = "유형 라벨의 대소문자 표시 방식."
L["OPTIONS_FOCUS_QUEST_TITLE_CASE"]                                   = "퀘스트 제목 대소문자"
L["OPTIONS_FOCUS_DISPLAY_CASE_QUEST_TITLES"]                          = "퀘스트 제목의 대소문자 표시 방식."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["OPTIONS_FOCUS_TEXT_SHADOW"]                                        = "글자 그림자 표시"
L["OPTIONS_FOCUS_ENABLE_DROP_SHADOW_TEXT"]                            = "글자에 그림자를 표시합니다."
L["OPTIONS_FOCUS_SHADOW_X"]                                           = "가로"
L["OPTIONS_FOCUS_HORIZONTAL_SHADOW_OFFSET"]                           = "가로 그림자 설정."
L["OPTIONS_FOCUS_SHADOW_Y"]                                           = "세로"
L["OPTIONS_FOCUS_VERTICAL_SHADOW_OFFSET"]                             = "세로 그림자 설정."
L["OPTIONS_FOCUS_SHADOW_ALPHA"]                                       = "그림자 투명도"
L["OPTIONS_FOCUS_SHADOW_OPACITY"]                                     = "그림자 투명도 (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["OPTIONS_FOCUS_MYTHIC_TYPOGRAPHY"]                                  = "쐐기돌 글자"
L["OPTIONS_FOCUS_DUNGEON_NAME_SIZE"]                                  = "던전명 크기"
L["OPTIONS_FOCUS_FONT_SIZE_DUNGEON_NAME_PX"]                          = "던전명 글자 크기 (8–32 px)."
L["OPTIONS_FOCUS_DUNGEON_NAME_COLOR"]                                 = "던전명 색상"
L["OPTIONS_FOCUS_TEXT_COLOR_DUNGEON_NAME"]                            = "던전명 글자 색상."
L["OPTIONS_FOCUS_TIMER_SIZE"]                                         = "타이머 크기"
L["OPTIONS_FOCUS_FONT_SIZE_TIMER_PX"]                                 = "타이머 글자 크기 (8–32 px)."
L["OPTIONS_FOCUS_TIMER_COLOR"]                                        = "타이머 색상"
L["OPTIONS_FOCUS_TEXT_COLOR_TIMER"]                                   = "타이머 글자 색상 (제한 시간 내)."
L["OPTIONS_FOCUS_TIMER_OVERTIME_COLOR"]                               = "타이머 초과 색상"
L["OPTIONS_FOCUS_TEXT_COLOR_TIMER_LIMIT"]                             = "시간 초과 시 타이머 글자 색상."
L["OPTIONS_FOCUS_PROGRESS_SIZE"]                                      = "진행도 크기"
L["OPTIONS_FOCUS_FONT_SIZE_ENEMY_FORCES_PX"]                          = "적 병력 글자 크기 (8–32 px)."
L["OPTIONS_FOCUS_PROGRESS_COLOR"]                                     = "진행도 색상"
L["OPTIONS_FOCUS_TEXT_COLOR_ENEMY_FORCES"]                            = "적 병력 글자 색상."
L["OPTIONS_FOCUS_BAR_FILL_COLOR"]                                     = "진행 바 채우기 색상"
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL_COLOR_PROGRESS"]                   = "진행 바 채우기 색상 (진행 중)."
L["OPTIONS_FOCUS_BAR_COMPLETE_COLOR"]                                 = "바 완료 색상"
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL_COLOR_ENEMY_FORCES"]               = "적 병력 100% 시 진행 바 채우기 색상."
L["OPTIONS_FOCUS_AFFIX_SIZE"]                                         = "시즌 효과 크기"
L["OPTIONS_FOCUS_FONT_SIZE_AFFIXES_PX"]                               = "시즌 효과 글자 크기 (8–32 px)."
L["OPTIONS_FOCUS_AFFIX_COLOR"]                                        = "시즌 효과 색상"
L["OPTIONS_FOCUS_TEXT_COLOR_AFFIXES"]                                 = "시즌 효과 글자 색상."
L["OPTIONS_FOCUS_BOSS_SIZE"]                                          = "우두머리 이름 크기"
L["OPTIONS_FOCUS_FONT_SIZE_BOSS_NAMES_PX"]                            = "우두머리 이름 글자 크기 (8–32 px)."
L["OPTIONS_FOCUS_BOSS_COLOR"]                                         = "우두머리 이름 색상"
L["OPTIONS_FOCUS_TEXT_COLOR_BOSS_NAMES"]                              = "우두머리 이름 글자 색상."
L["OPTIONS_FOCUS_RESET_MYTHIC_TYPOGRAPHY"]                            = "쐐기돌 글자 초기화"

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
L["OPTIONS_FOCUS_BACKGROUND_STYLE_MODULE_DASHBOARD_WINDOW_AXI"]       = "Background style for the module dashboard window (Axis). Default is flat; Midnight uses bundled artwork; Specialisation (auto) uses the in-game talent UI background for your current specialization."
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_MINIMALISTIC"]               = "Minimalistic"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_MIDNIGHT"]                   = "Midnight"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_TELDRASSIL_BURNS"]              = "Teldrassil (burning)"
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_NIGHTFAE"]                   = "Night Fae"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_ARDENWEALD"]                 = "Ardenweald"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_ZIN_AZSHARI"]                = "Zin-Azshari"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_SURAMAR_GARDEN"]                = "Suramar garden"
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_QUELTHALAS"]                 = "Quel'Thalas"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_TWILIGHT_VINEYARDS"]         = "Twilight Vineyards"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_ZUL_AMAN"]                   = "Zul'Aman"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_ILLIDAN"]                    = "Illidan"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_LICH_KING"]                  = "The Lich King"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_TBC_ANNIVERSARY"]            = "TBC Anniversary"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DASHBOARD_BACKGROUND_BELEDARS_LIGHT"]             = "Beledar's Light"  -- NEEDS TRANSLATION
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
L["OPTIONS_FOCUS_BACKDROP_OPACITY"]                                   = "배경 투명도"
L["OPTIONS_FOCUS_PANEL_BACKGROUND_OPACITY"]                           = "패널 배경 투명도 (0–1)."
L["OPTIONS_FOCUS_BORDER"]                                             = "테두리 표시"
L["OPTIONS_FOCUS_BORDER_AROUND_TRACKER"]                              = "목록 주변에 테두리를 표시합니다."
L["OPTIONS_FOCUS_SCROLL_INDICATOR"]                                   = "스크롤 표시기 표시"
L["OPTIONS_FOCUS_A_VISUAL_HINT_LIST_CONTENT_TH"]                      = "목록에 보이는 것보다 더 많은 항목이 있을 때 시각적 힌트를 표시합니다."
L["OPTIONS_FOCUS_SCROLL_INDICATOR_STYLE"]                             = "스크롤 표시기 스타일"
L["OPTIONS_FOCUS_CHOOSE_BETWEEN_A_FADE_GRADIENT_A"]                   = "스크롤 가능한 항목을 나타내는 페이드 그라데이션 또는 작은 화살표 중 선택합니다."
L["OPTIONS_FOCUS_ARROW"]                                              = "화살표"
L["OPTIONS_FOCUS_HIGHLIGHT_ALPHA"]                                    = "강조 투명도"
L["OPTIONS_FOCUS_OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]                 = "고정된 퀘스트 강조의 투명도 (0–1)."
L["OPTIONS_FOCUS_BAR_WIDTH"]                                          = "바 너비"
L["OPTIONS_FOCUS_WIDTH_OF_BAR_STYLE_HIGHLIGHTS_PX"]                   = "바 스타일 강조의 너비 (2–6 px)."

-- =====================================================================
-- OptionsData.lua Organization
-- =====================================================================
-- L["OPTIONS_FOCUS_ACTIVITY"]                                        = "Activity"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CONTENT"]                                         = "Content"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_SORTING"]                                         = "Sorting"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_ELEMENTS"]                                        = "Elements"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_CATEGORY_ORDER"]                                     = "퀘스트 목록 유형 순서"
-- L["OPTIONS_FOCUS_CATEGORY_COLOR_BAR"]                              = "Category color for bar"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CHECKMARK_COMPLETED"]                             = "Checkmark for completed"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CURRENT_QUEST_CATEGORY"]                          = "Current Quest category"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CURRENT_QUEST_WINDOW"]                            = "Current Quest window"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_QUESTS_RECENT_PROGRESS_TOP"]                      = "Show quests with recent progress at the top."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_SECONDS_OF_RECENT_PROGRESS_CURRENT_QUEST"]        = "Seconds of recent progress to show in Current Quest (30–120)."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_QUESTS_YOU_MADE_PROGRESS_LAST_MINUTE"]            = "Quests you made progress on in the last minute appear in a dedicated section."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_SHOW_EVENTS_IN_ZONE"]                             = "Events in Zone section"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_SHOW_EVENTS_IN_ZONE_DESC"]                           = "Show the Events in Zone section for nearby unaccepted quests and zone event quests."
L["OPTIONS_FOCUS_SHOW_EVENTS_IN_ZONE_TIP"]                            = "When off, those quests appear in their normal categories instead."
L["OPTIONS_FOCUS_CATEGORY_ORDER"]                                     = "퀘스트 목록 유형 순서"
L["OPTIONS_FOCUS_DRAG_REORDER_CATEGORIES_DELVES_SCENARIO_EVENT"]      = "드래그하여 유형 순서를 변경합니다. DELVES와 SCENARIO EVENTS는 항상 최상위에 고정됩니다."
-- L["OPTIONS_FOCUS_DRAG_REORDER_DELVES_SCENARIOS_STAY_FIRST"]        = "Drag to reorder. Delves and Scenarios stay first."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_SORT_MODE"]                                          = "퀘스트 목록 정렬 방식"
L["OPTIONS_FOCUS_ORDER_OF_ENTRIES_WITHIN_CATEGORY"]                   = "각 유형 내 항목의 정렬 순서."
L["OPTIONS_FOCUS_AUTO_TRACK_ACCEPTED_QUESTS"]                         = "수락한 퀘스트 자동 추적"
L["OPTIONS_FOCUS_YOU_ACCEPT_A_QUEST_QUEST_LOG"]                       = "퀘스트를 수락하면 목록에 자동으로 추가합니다 (퀘스트 목록만 해당, 전역 퀘스트 제외)."
L["OPTIONS_FOCUS_REQUIRE_CTRL_FOCUS_REMOVE"]                          = "퀘스트 목록/제거 시 Ctrl 필요"
L["OPTIONS_FOCUS_REQUIRE_CTRL_FOCUS_ADD_LEFT_UNFOCUS"]                = "클릭 방지를 위해 퀘스트 목록/추가(좌클릭)와 해제/추적 중지(우클릭) 시 컨트롤 키를 요구합니다."
-- L["OPTIONS_FOCUS_CTRL_FOCUS_UNTRACK"]                              = "Ctrl for focus / untrack"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CTRL_CLICK_COMPLETE"]                             = "Ctrl to click-complete"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_CLASSIC_CLICK_BEHAVIOUR"]                            = "클래식 클릭 동작 사용"
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
L["OPTIONS_FOCUS_SHARE_PARTY"]                                        = "파티에 공유"
L["OPTIONS_FOCUS_ABANDON_QUEST"]                                      = "퀘스트 포기"
L["OPTIONS_FOCUS_STOP_TRACKING"]                                      = "추적 중지"
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
L["OPTIONS_FOCUS_QUEST_CANNOT_SHARED"]                                = "이 퀘스트는 공유할 수 없습니다."
L["OPTIONS_FOCUS_YOU_MUST_A_PARTY_SHARE_QUEST"]                       = "이 퀘스트를 공유하려면 파티에 참여해야 합니다."
L["OPTIONS_FOCUS_LEFT_CLICK_OPENS_QUEST_MAP_RIGHT"]                   = "활성화 시 좌클릭으로 퀘스트 지도 열기, 우클릭으로 공유/포기 메뉴 표시(블리자드 방식). 비활성화 시 좌클릭으로 추적, 우클릭으로 추적 해제; Ctrl+우클릭으로 파티에 공유."
L["OPTIONS_FOCUS_ANIMATIONS"]                                         = "Focus animations"
L["OPTIONS_FOCUS_ENABLE_SLIDE_FADE_QUESTS"]                           = "퀘스트에 슬라이드 및 페이드 효과를 활성화합니다."
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_FLASH"]                           = "목표 완료 효과"
L["OPTIONS_FOCUS_FLASH_AN_OBJECTIVE_COMPLETES"]                       = "목표 완료 시 효과를 표시합니다."
L["OPTIONS_FOCUS_FLASH_INTENSITY"]                                    = "효과 강도"
L["OPTIONS_FOCUS_NOTICEABLE_OBJECTIVE_COMPLETE_FLASH"]                = "목표 완료 시 표시되는 효과의 강도입니다."
L["OPTIONS_FOCUS_FLASH_COLOR"]                                        = "효과 색상"
L["OPTIONS_FOCUS_COLOR_OF_OBJECTIVE_COMPLETE_FLASH"]                  = "목표 완료 시 표시되는 효과의 색상입니다."
L["OPTIONS_FOCUS_SUBTLE"]                                             = "은은함"
L["OPTIONS_FOCUS_MEDIUM"]                                             = "보통"
L["OPTIONS_FOCUS_STRONG"]                                             = "강함"
L["OPTIONS_FOCUS_REQUIRE_CTRL_CLICK_COMPLETE"]                        = "클릭 완료 시 컨트롤 키 필요"
L["OPTIONS_FOCUS_REQUIRES_CTRL_LEFT_CLICK_COMPLETE_AUTO"]             = "활성화하면 자동 완료 퀘스트를 완료할 때 Ctrl+좌클릭이 필요합니다. 비활성화하면 일반 좌클릭으로 완료됩니다 (Blizzard 기본값). NPC 제출 없이 클릭으로 완료 가능한 퀘스트에만 적용됩니다."
L["OPTIONS_FOCUS_SUPPRESS_UNTRACKED_UNTIL_RELOAD"]                    = "재접속 전까지 추적 해제 숨기기"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS_Z"]                 = "활성화하면 전역 퀘스트와 지역 내 주간·일일 퀘스트에서 우클릭 추적 해제 시 재접속할 때까지 숨깁니다. 비활성화하면 해당 지역에 돌아오면 다시 표시됩니다."
L["OPTIONS_FOCUS_PERMANENTLY_SUPPRESS_UNTRACKED_QUESTS"]              = "추적 해제한 퀘스트 영구 숨기기"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACKED_WORLD_QUESTS_ZO"]              = "활성화하면 우클릭 추적 해제한 전역 퀘스트와 지역 내 주간·일일 퀘스트가 영구적으로 숨겨집니다 (재접속 후에도 유지). '재접속 전까지 숨기기'보다 우선합니다. 숨긴 퀘스트를 수락하면 차단 목록에서 제거됩니다."
L["OPTIONS_FOCUS_KEEP_CAMPAIGN_QUESTS_CATEGORY"]                      = "대장정 퀘스트를 카테고리에 유지"
L["OPTIONS_FOCUS_CAMPAIGN_QUESTS_READY_TURN_RE"]                      = "활성화하면 완료 가능한 대장정 퀘스트가 완료 카테고리로 이동하지 않고 캠페인 카테고리에 남습니다."
L["OPTIONS_FOCUS_KEEP_IMPORTANT_QUESTS_CATEGORY"]                     = "중요 퀘스트를 카테고리에 유지"
L["OPTIONS_FOCUS_IMPORTANT_QUESTS_READY_TURN_R"]                      = "활성화하면 완료 가능한 중요 퀘스트가 완료 카테고리로 이동하지 않고 중요 카테고리에 남습니다."
L["OPTIONS_FOCUS_TOMTOM_QUEST_WAYPOINT"]                              = "TomTom 퀘스트 경유지"
L["OPTIONS_FOCUS_A_TOMTOM_WAYPOINT_FOCUSING_A_QUEST"]                 = "퀘스트를 집중할 때 TomTom 경유지를 설정합니다."
L["OPTIONS_FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_NEXT_QUEST"]            = "TomTom이 필요합니다. 화살표가 다음 퀘스트 목표를 가리킵니다."
L["OPTIONS_FOCUS_TOMTOM_RARE_WAYPOINT"]                               = "TomTom 희귀 우두머리 경유지"
L["OPTIONS_FOCUS_A_TOMTOM_WAYPOINT_CLICKING_A_RARE"]                  = "희귀 우두머리를 클릭할 때 TomTom 경유지를 설정합니다."
L["OPTIONS_FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_RARE_S"]                = "TomTom이 필요합니다. 화살표가 희귀 우두머리 위치를 가리킵니다."
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
L["OPTIONS_FOCUS_BLACKLISTED_QUESTS"]                                 = "차단된 퀘스트"
L["OPTIONS_FOCUS_PERMANENTLY_SUPPRESSED_QUESTS"]                      = "영구 숨김 퀘스트"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACK_QUESTS_PERMANENTLY_SUPPRESS"]    = "'추적 해제한 퀘스트 영구 숨기기'가 활성화된 상태에서 우클릭 추적 해제한 퀘스트가 여기에 추가됩니다."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["OPTIONS_PRESENCE_QUEST_TYPE_ICONS"]                                = "퀘스트 유형 아이콘 표시"
L["OPTIONS_PRESENCE_QUEST_TYPE_ICON_FOCUS_TRACKER_QUEST"]             = "목표 추적기에 퀘스트 유형 아이콘을 표시합니다 (퀘스트 수락/완료, 전역 퀘스트, 퀘스트 갱신)."
L["OPTIONS_PRESENCE_QUEST_TYPE_ICONS_TOASTS"]                         = "알림에 퀘스트 유형 아이콘 표시"
L["OPTIONS_PRESENCE_QUEST_TYPE_ICON_PRESENCE_TOASTS_QUEST"]           = "알림에 퀘스트 유형 아이콘을 표시합니다 (퀘스트 수락/완료, 전역 퀘스트, 퀘스트 갱신)."
L["OPTIONS_PRESENCE_TOAST_ICON_SIZE"]                                 = "알림 아이콘 크기"
L["OPTIONS_PRESENCE_QUEST_ICON_SIZE_PRESENCE_TOASTS_PX"]              = "알림의 퀘스트 아이콘 크기 (16–36 px). 기본값 24."
L["OPTIONS_PRESENCE_HIDE_QUEST_UPDATE_TITLE"]                         = "퀘스트 진행 알림에서 제목 숨기기"
L["OPTIONS_PRESENCE_OBJECTIVE_LINE_QUEST_PROGRESS_TOAST"]             = "퀘스트 이름이나 제목 없이 목표 줄만 표시합니다 (예: 7/10 멧돼지 가죽)."
L["OPTIONS_PRESENCE_SHOW_DISCOVERY_LINE"]                             = "발견 텍스트 표시"
-- L["OPTIONS_PRESENCE_DISCOVERY_LINE"]                               = "Discovery line"  -- NEEDS TRANSLATION
L["OPTIONS_PRESENCE_DISCOVERED_UNDER_ZONE_SUBZONE_ENTERING_A"]        = "새 지역에 진입할 때 지역/하위 지역 아래에 '발견' 글자를 표시합니다."
L["OPTIONS_PRESENCE_FRAME_VERTICAL_POSITION"]                         = "알림 세로 위치"
L["OPTIONS_PRESENCE_VERTICAL_OFFSET_OF_PRESENCE_FRAME_CENTER"]        = "중앙 기준 알림 프레임의 세로 위치(-300 ~ 0)."
L["OPTIONS_PRESENCE_FRAME_SCALE"]                                     = "알림 크기"
L["OPTIONS_PRESENCE_SCALE_OF_PRESENCE_FRAME"]                         = "알림 프레임 크기 (0.5–2)."
L["OPTIONS_PRESENCE_BOSS_EMOTE_COLOR"]                                = "우두머리 감정 표현 색상"
L["OPTIONS_PRESENCE_COLOR_OF_RAID_DUNGEON_BOSS_EMOTE"]                = "공격대/던전 우두머리 감정 표현 글자 색상."
L["OPTIONS_PRESENCE_DISCOVERY_LINE_COLOR"]                            = "발견 글자 색상"
L["OPTIONS_PRESENCE_COLOR_OF_DISCOVERED_LINE_UNDER_ZONE"]             = "지역 텍스트 아래 '발견' 글자 색상."
L["OPTIONS_PRESENCE_NOTIFICATION_TYPES"]                              = "알림 유형"
-- L["OPTIONS_PRESENCE_NOTIFICATIONS"]                                = "Notifications"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_NOTIFICATION_ACHIEVEMENT_CRITERIA_UPDATE_T"]   = "Show notification when achievement criteria update (tracked achievements always; others when Blizzard provides the achievement ID)."  -- NEEDS TRANSLATION
L["OPTIONS_PRESENCE_ZONE_ENTRY"]                                      = "지역 입장 표시"
L["OPTIONS_PRESENCE_ZONE_CHANGE_ENTERING_A_AREA"]                     = "새 지역에 입장할 때 알림을 표시합니다."
L["OPTIONS_PRESENCE_SUBZONE_CHANGES"]                                 = "하위 지역 변경 표시"
L["OPTIONS_PRESENCE_SUBZONE_CHANGE_MOVING_WITHIN_SAME_ZONE"]          = "같은 지역 내에서 이동할 때 하위 지역 변경 알림을 표시합니다."
L["OPTIONS_PRESENCE_HIDE_ZONE_NAME_SUBZONE_CHANGES"]                  = "하위 지역 변경 시 지역 이름 숨기기"
L["OPTIONS_PRESENCE_MOVING_BETWEEN_SUBZONES_WITHIN_SAME_ZONE"]        = "같은 지역 내에서 하위 지역 간 이동 시 하위 지역 이름만 표시합니다. 새 지역에 입장할 때는 지역 이름이 여전히 표시됩니다."
-- L["OPTIONS_PRESENCE_SUPPRESS_DELVE"]                               = "Suppress in Delve"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_SUPPRESS_SCENARIO_PROGRESS_NOTIFICATIONS_DELVES"]= "Suppress scenario progress notifications in Delves."  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_HIDES_OBJECTIVE_UPDATE_POPUPS_WHILE_A"]        = "When on, hides objective update popups while in a Delve. Zone entry and completion toasts still show."  -- NEEDS TRANSLATION
L["OPTIONS_PRESENCE_SUPPRESS_ZONE_CHANGES_MYTHIC"]                    = "신화+ 던전에서 지역 변경 숨기기"
L["OPTIONS_PRESENCE_MYTHIC_BOSS_EMOTES_ACHIEVEMENTS_LEV"]             = "쐐기에서는 우두머리 감정 표현, 업적, 레벨 업만 표시합니다. 지역, 퀘스트, 시나리오 알림은 숨깁니다."
L["OPTIONS_PRESENCE_LEVEL"]                                           = "레벨 업 표시"
L["OPTIONS_PRESENCE_LEVEL_NOTIFICATION"]                              = "레벨 업 알림을 표시합니다."
L["OPTIONS_PRESENCE_BOSS_EMOTES"]                                     = "우두머리 감정 표현 표시"
L["OPTIONS_PRESENCE_RAID_DUNGEON_BOSS_EMOTE_NOTIFICATIONS"]           = "공격대 및 던전 우두머리 감정 표현 알림을 표시합니다."
L["OPTIONS_PRESENCE_ACHIEVEMENTS"]                                    = "업적 표시"
L["OPTIONS_PRESENCE_ACHIEVEMENT_EARNED_NOTIFICATIONS"]                = "업적 달성 알림을 표시합니다."
L["OPTIONS_PRESENCE_ACHIEVEMENT_PROGRESS"]                            = "업적 진행도"
L["OPTIONS_PRESENCE_ACHIEVEMENT_EARNED"]                              = "업적 달성"
L["OPTIONS_PRESENCE_QUEST_ACCEPTED"]                                  = "퀘스트 수락"
L["OPTIONS_PRESENCE_WORLD_QUEST_ACCEPTED"]                            = "전역 퀘스트 수락"
L["OPTIONS_PRESENCE_SCENARIO_COMPLETE"]                               = "시나리오 완료"
L["OPTIONS_PRESENCE_RARE_DEFEATED"]                                   = "희귀 몹 처치"
L["OPTIONS_PRESENCE_NOTIFICATION_TRACKED_ACHIEVEMENT_CRITERIA"]       = "추적 중인 업적 기준이 갱신될 때 알림을 표시합니다."
L["OPTIONS_PRESENCE_QUEST_ACCEPT"]                                    = "퀘스트 수락 표시"
L["OPTIONS_PRESENCE_NOTIFICATION_ACCEPTING_A_QUEST"]                  = "퀘스트를 수락할 때 알림을 표시합니다."
L["OPTIONS_PRESENCE_WORLD_QUEST_ACCEPT"]                              = "전역 퀘스트 수락 표시"
L["OPTIONS_PRESENCE_NOTIFICATION_ACCEPTING_A_WORLD_QUEST"]            = "전역 퀘스트를 수락할 때 알림을 표시합니다."
L["OPTIONS_PRESENCE_QUEST_COMPLETE"]                                  = "퀘스트 완료 표시"
L["OPTIONS_PRESENCE_NOTIFICATION_COMPLETING_A_QUEST"]                 = "퀘스트를 완료할 때 알림을 표시합니다."
L["OPTIONS_PRESENCE_WORLD_QUEST_COMPLETE"]                            = "전역 퀘스트 완료 표시"
L["OPTIONS_PRESENCE_NOTIFICATION_COMPLETING_A_WORLD_QUEST"]           = "전역 퀘스트를 완료할 때 알림을 표시합니다."
L["OPTIONS_PRESENCE_QUEST_PROGRESS"]                                  = "퀘스트 진행 표시"
L["OPTIONS_PRESENCE_NOTIFICATION_QUEST_OBJECTIVES_UPDATE"]            = "퀘스트 목표가 갱신될 때 알림을 표시합니다."
L["OPTIONS_PRESENCE_OBJECTIVE"]                                       = "목표만 표시"
L["OPTIONS_PRESENCE_QUEST_PROGRESS_HIDE_TITLE"]                       = "퀘스트 진행 알림에서 '퀘스트 갱신' 제목을 숨기고 목표 줄만 표시합니다."
L["OPTIONS_PRESENCE_SCENARIO_START"]                                  = "시나리오 시작 표시"
L["OPTIONS_PRESENCE_NOTIFICATION_ENTERING_A_SCENARIO_DELVE"]          = "시나리오나 구렁에 입장할 때 알림을 표시합니다."
L["OPTIONS_PRESENCE_SCENARIO_PROGRESS"]                               = "시나리오 진행 표시"
L["OPTIONS_PRESENCE_NOTIFICATION_SCENARIO_DELVE_OBJECTIVES"]          = "시나리오나 구렁 목표가 갱신될 때 알림을 표시합니다."
L["OPTIONS_PRESENCE_ANIMATION"]                                       = "애니메이션"
L["OPTIONS_PRESENCE_ENABLE_ANIMATIONS"]                               = "애니메이션 사용"
L["OPTIONS_PRESENCE_ENABLE_ENTRANCE_EXIT_ANIMATIONS_PRESENCE"]        = "알림의 등장 및 퇴장 애니메이션을 활성화합니다."
L["OPTIONS_PRESENCE_ENTRANCE_DURATION"]                               = "등장 시간"
L["OPTIONS_PRESENCE_DURATION_OF_ENTRANCE_ANIMATION_SECONDS"]          = "등장 애니메이션 시간(초, 0.2–1.5)."
L["OPTIONS_PRESENCE_EXIT_DURATION"]                                   = "퇴장 시간"
L["OPTIONS_PRESENCE_DURATION_OF_EXIT_ANIMATION_SECONDS"]              = "퇴장 애니메이션 시간(초, 0.2–1.5)."
L["OPTIONS_PRESENCE_HOLD_DURATION_SCALE"]                             = "표시 시간 크기 조절"
L["OPTIONS_PRESENCE_MULTIPLIER_LONG_NOTIFICATION_STAYS_S"]            = "각 알림이 화면에 표시되는 시간 크기조절 (0.5–2)."
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
L["DASH_TYPOGRAPHY"]                                                  = "글꼴"
L["OPTIONS_PRESENCE_MAIN_TITLE_FONT"]                                 = "메인 제목 글꼴"
L["OPTIONS_PRESENCE_FONT_FAMILY_MAIN_TITLE"]                          = "메인 제목 글꼴 패밀리."
L["OPTIONS_PRESENCE_SUBTITLE_FONT"]                                   = "부제목 글꼴"
L["OPTIONS_PRESENCE_FONT_FAMILY_SUBTITLE"]                            = "부제목 글꼴 패밀리."
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
L["OPTIONS_FOCUS_NONE"]                                               = "없음"
L["OPTIONS_FOCUS_THICK_OUTLINE"]                                      = "두꺼운 외곽선"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["OPTIONS_FOCUS_BAR_LEFT_EDGE"]                                      = "바 (왼쪽)"
L["OPTIONS_FOCUS_BAR_RIGHT_EDGE"]                                     = "바 (오른쪽)"
L["OPTIONS_FOCUS_BAR_TOP_EDGE"]                                       = "바 (위)"
L["OPTIONS_FOCUS_BAR_BOTTOM_EDGE"]                                    = "바 (아래)"
L["OPTIONS_FOCUS_OUTLINE_ONLY_STYLE"]                                 = "외곽선만"
L["OPTIONS_FOCUS_SOFT_GLOW"]                                          = "은은한 발광"
L["OPTIONS_FOCUS_DUAL_EDGE_BARS"]                                     = "양쪽 바"
L["OPTIONS_FOCUS_PILL_LEFT_ACCENT"]                                   = "알약형 왼쪽 강조"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["OPTIONS_FOCUS_TOP"]                                                = "위"
L["OPTIONS_FOCUS_BOTTOM"]                                             = "아래"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["OPTIONS_VISTA_LOCATION_POSITION"]                                  = "위치 표시"
L["OPTIONS_VISTA_PLACE_ZONE_NAME_ABOVE_BELOW_MINIMAP"]                = "지역 이름을 미니맵 위 또는 아래에 배치합니다."
L["OPTIONS_VISTA_COORDINATES_POSITION"]                               = "좌표 위치"
L["OPTIONS_VISTA_PLACE_COORDINATES_ABOVE_BELOW_MINIMAP"]              = "좌표를 미니맵 위 또는 아래에 배치합니다."
L["OPTIONS_VISTA_CLOCK_POSITION"]                                     = "시계 위치"
L["OPTIONS_VISTA_PLACE_CLOCK_ABOVE_BELOW_MINIMAP"]                    = "시계를 미니맵 위 또는 아래에 배치합니다."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["OPTIONS_FOCUS_LOWER_CASE"]                                         = "소문자"
L["OPTIONS_FOCUS_UPPER_CASE"]                                         = "대문자"
L["OPTIONS_FOCUS_PROPER"]                                             = "첫 글자만 대문자"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["OPTIONS_FOCUS_TRACKED_LOG"]                                        = "추적 중 / 목록"
L["OPTIONS_FOCUS_LOG_MAX_SLOTS"]                                      = "목록 / 최대 목록"

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["OPTIONS_FOCUS_ALPHABETICAL"]                                       = "이름순"
L["OPTIONS_FOCUS_QUEST_TYPE"]                                         = "퀘스트 유형"
L["OPTIONS_FOCUS_QUEST_LEVEL"]                                        = "퀘스트 레벨"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["OPTIONS_FOCUS_CUSTOM"]                                             = "사용자 지정"
L["OPTIONS_FOCUS_ORDER"]                                              = "순서"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["UI_DUNGEON"]                                                       = "던전"
L["UI_RAID"]                                                          = "공격대"
L["UI_DELVES"]                                                        = "구렁"
L["UI_SCENARIO_EVENTS"]                                               = "시나리오"
-- L["UI_STAGE"]                                                      = "Stage"  -- NEEDS TRANSLATION
-- L["UI_STAGE_X_X"]                                                  = "Stage %d: %s"  -- NEEDS TRANSLATION
L["UI_AVAILABLE_IN_ZONE"]                                             = "지역 내 수락 가능"
L["UI_EVENTS_IN_ZONE"]                                                = "지역 내 이벤트"
L["UI_CURRENT_EVENT"]                                                 = "현재 이벤트"
L["UI_CURRENT_QUEST"]                                                 = "현재 퀘스트"
L["UI_CURRENT_ZONE"]                                                  = "현재 지역"
L["UI_CAMPAIGN"]                                                      = "대장정"
L["UI_IMPORTANT"]                                                     = "중요"
L["UI_LEGENDARY"]                                                     = "전설"
L["UI_WORLD_QUESTS"]                                                  = "전역 퀘스트"
L["UI_WEEKLY_QUESTS"]                                                 = "주간 퀘스트"
L["UI_PREY"]                                                          = "먹이"
L["UI_ABUNDANCE"]                                                     = "풍요"
L["UI_ABUNDANCE_BAG"]                                                 = "풍요의 자루"
L["UI_ABUNDANCE_HELD"]                                                = "보유한 풍요"
L["UI_DAILY_QUESTS"]                                                  = "일일 퀘스트"
L["UI_RARE_BOSSES"]                                                   = "희귀 우두머리"
L["UI_ACHIEVEMENTS"]                                                  = "업적"
L["UI_ENDEAVORS"]                                                     = "활동 과제"
L["UI_DECOR"]                                                         = "장식"
-- L["UI_RECIPES"]                                                    = "Recipes"  -- NEEDS TRANSLATION
-- L["UI_ADVENTURE_GUIDE"]                                            = "Adventure Guide"  -- NEEDS TRANSLATION
-- L["UI_APPEARANCES"]                                                = "Appearances"  -- NEEDS TRANSLATION
L["UI_QUESTS"]                                                        = "퀘스트"
L["UI_READY_TO_TURN_IN"]                                              = "완료된 퀘스트"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["PRESENCE_OBJECTIVES"]                                              = "목표"
L["PRESENCE_OPTIONS"]                                                 = "옵션"
L["PRESENCE_OPEN_HORIZON_SUITE"]                                      = "Horizon Suite 열기"
L["PRESENCE_OPEN_FULL_HORIZON_SUITE_OPTIONS"]                         = "Focus, Presence, Vista 및 기타 모듈을 구성하는 전체 Horizon Suite 옵션 패널을 엽니다."
L["PRESENCE_SHOW_MINIMAP_ICON"]                                       = "미니맵 아이콘 표시"
L["PRESENCE_A_CLICKABLE_ICON_MINIMAP_OPENS"]                          = "옵션 패널을 여는 미니맵의 클릭 가능한 아이콘을 표시합니다."
-- L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER"]              = "Fade until minimap hover"  -- NEEDS TRANSLATION
-- L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER_DESC"]         = "When on, the icon stays faded until you move the cursor over the minimap. When off, it stays fully visible."  -- NEEDS TRANSLATION
-- L["PRESENCE_LOCK_MINIMAP_BUTTON_POSITION"]                         = "Lock minimap button position"  -- NEEDS TRANSLATION
-- L["PRESENCE_PREVENT_DRAGGING_HORIZON_MINIMAP_BUTTON"]              = "Prevent dragging the Horizon minimap button."  -- NEEDS TRANSLATION
-- L["PRESENCE_RESET_MINIMAP_BUTTON_POSITION"]                        = "Reset minimap button position"  -- NEEDS TRANSLATION
-- L["PRESENCE_RESET_MINIMAP_BUTTON_DEFAULT_POSITION"]                = "Reset the minimap button to the default position (bottom-left)."  -- NEEDS TRANSLATION
-- L["PRESENCE_DRAG_TO_MOVE_WHEN_UNLOCKED"]                           = "Drag to move (when unlocked)."  -- NEEDS TRANSLATION
-- L["PRESENCE_LOCKED"]                                               = "Locked"  -- NEEDS TRANSLATION
L["PRESENCE_DISCOVERED"]                                              = "발견됨"
L["PRESENCE_REFRESH"]                                                 = "새로고침"
L["PRESENCE_BEST_EFFORT_UNACCEPTED_QUESTS_EXPO"]                      = "최선을 다해 검색합니다. 일부 미수락 퀘스트는 NPC와 상호작용하거나 페이징 조건을 만족해야 노출됩니다."
L["PRESENCE_UNACCEPTED_QUESTS_X_MAP_X"]                               = "미수락 퀘스트 - %s (맵 %s) - %d건 일치"
L["PRESENCE_LEVEL_UP"]                                                = "레벨 업"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_80"]                               = "드디어! 80레벨"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_X"]                                = "%s레벨에 도달했습니다"
L["PRESENCE_ACHIEVEMENT_EARNED"]                                      = "업적 달성"
L["PRESENCE_EXPLORING_THE_MIDNIGHT_ISLES"]                            = "한밤의 섬 탐험"
L["PRESENCE_EXPLORING_KHAZ_ALGAR"]                                    = "카즈 알가르 탐험"
L["PRESENCE_QUEST_COMPLETE"]                                          = "퀘스트 완료"
L["PRESENCE_OBJECTIVE_SECURED"]                                       = "목표 확보"
L["PRESENCE_AIDING_THE_ACCORD"]                                       = "협약 지원"
L["PRESENCE_WORLD_QUEST"]                                             = "전역 퀘스트"
L["PRESENCE_WORLD_QUEST_COMPLETE"]                                    = "전역 퀘스트 완료"
L["PRESENCE_AZERITE_MINING"]                                          = "아제라이트 채굴"
L["PRESENCE_WORLD_QUEST_ACCEPTED"]                                    = "전역 퀘스트 수락"
L["PRESENCE_QUEST_ACCEPTED"]                                          = "퀘스트 수락"
L["PRESENCE_THE_FATE_OF_THE_HORDE"]                                   = "호드의 운명"
L["PRESENCE_NEW_QUEST"]                                               = "새 퀘스트"
L["PRESENCE_QUEST_UPDATE"]                                            = "퀘스트 업데이트"
L["PRESENCE_BOAR_PELTS_7_10"]                                         = "멧돼지 가죽: 7/10"
L["PRESENCE_DRAGON_GLYPHS_3_5"]                                       = "용의 문양: 3/5"
L["PRESENCE_PRESENCE_TEST_COMMANDS"]                                  = "상황 알림 테스트 명령어:"
-- L["PRESENCE_H_PRESENCE_DEBUGTYPES_DUMP_NOTIFICATION"]              = "  /h presence debugtypes - Dump notification toggles and Blizzard suppression state"  -- NEEDS TRANSLATION
-- L["PRESENCE_PRESENCE_PLAYING_DEMO_REEL_NOTIFICATION"]              = "Presence: Playing demo reel (all notification types)..."  -- NEEDS TRANSLATION
L["PRESENCE_H_PRESENCE_HELP_TEST_CURRENT"]                            = "  /h presence         - 도움말 표시 + 현재 지역 테스트"
L["PRESENCE_H_PRESENCE_ZONE_TEST_ZONE"]                               = "  /h presence zone     - 지역 변경 테스트"
L["PRESENCE_H_PRESENCE_SUBZONE_TEST_SUBZONE"]                         = "  /h presence subzone  - 하위 지역 변경 테스트"
L["PRESENCE_H_PRESENCE_DISCOVER_TEST_ZONE"]                           = "  /h presence discover - 지역 발견 테스트"
L["PRESENCE_H_PRESENCE_LEVEL_TEST_LEVEL"]                             = "  /h presence level    - 레벨 업 테스트"
L["PRESENCE_H_PRESENCE_BOSS_TEST_BOSS"]                               = "  /h presence boss     - 우두머리 감정 표현 테스트"
L["PRESENCE_H_PRESENCE_ACH_TEST_ACHIEVEMENT"]                         = "  /h presence ach      - 업적 테스트"
L["PRESENCE_H_PRESENCE_ACCEPT_TEST_QUEST"]                            = "  /h presence accept   - 퀘스트 수락 테스트"
L["PRESENCE_H_PRESENCE_WQACCEPT_TEST_WORLD"]                          = "  /h presence wqaccept - 전역 퀘스트 수락 테스트"
L["PRESENCE_H_PRESENCE_SCENARIO_TEST_SCENARIO"]                       = "  /h presence scenario - 시나리오 시작 테스트"
L["PRESENCE_H_PRESENCE_QUEST_TEST_QUEST"]                             = "  /h presence quest    - 퀘스트 완료 테스트"
L["PRESENCE_H_PRESENCE_WQ_TEST_WORLD"]                                = "  /h presence wq       - 전역 퀘스트 테스트"
L["PRESENCE_H_PRESENCE_UPDATE_TEST_QUEST"]                            = "  /h presence update   - 퀘스트 업데이트 테스트"
L["PRESENCE_H_PRESENCE_ACHPROGRESS_TEST_ACHIEVEMENT"]                 = "  /h presence achprogress - 업적 진행도 테스트"
L["PRESENCE_H_PRESENCE_DEMO_REEL_TYPES"]                              = "  /h presence all      - 데모 (모든 유형)"
L["PRESENCE_H_PRESENCE_DEBUG_DUMP_STATE"]                             = "  /h presence debug    - 상태를 채팅에 출력"
L["PRESENCE_H_PRESENCE_DEBUGLIVE_TOGGLE_LIVE"]                        = "  /h presence debuglive - 실시간 디버그 패널 토글 (이벤트 발생 시 로그)"

-- =====================================================================
-- OptionsData.lua Vista — General
-- L["OPTIONS_VISTA_POSITION_LAYOUT"]                                 = "Position & layout"  -- NEEDS TRANSLATION

-- =====================================================================
L["OPTIONS_VISTA_MINIMAP"]                                            = "미니맵"
L["OPTIONS_VISTA_MINIMAP_SIZE"]                                       = "미니맵 크기"
L["OPTIONS_VISTA_WIDTH_HEIGHT_OF_MINIMAP_PIXELS"]                     = "미니맵의 가로 및 세로 크기 (픽셀, 100–400)."
L["OPTIONS_VISTA_CIRCULAR_MINIMAP"]                                   = "원형 미니맵"
-- L["OPTIONS_VISTA_CIRCULAR_SHAPE"]                                  = "Circular shape"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_A_CIRCULAR_MINIMAP_INSTEAD_OF_SQUARE"]               = "사각형 대신 원형 미니맵을 사용합니다."
L["OPTIONS_VISTA_LOCK_MINIMAP_POSITION"]                              = "미니맵 위치 잠금"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MINIMAP"]                           = "미니맵을 드래그할 수 없게 합니다."
L["OPTIONS_VISTA_RESET_MINIMAP_POSITION"]                             = "미니맵 위치 초기화"
L["OPTIONS_VISTA_RESET_MINIMAP_DEFAULT_POSITION_TOP_RIGHT"]           = "미니맵을 기본 위치(오른쪽 상단)로 초기화합니다."
-- L["OPTIONS_VISTA_RESET_OVERLAY_POSITIONS"]                         = "Reset overlay positions to defaults"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_RESET_OVERLAY_POSITIONS_DESC"]                       = "Clear saved positions for zone text, coordinates, clock, performance and difficulty text, zoom buttons, tracking, calendar, queue, mail, the addon button bar, drawer button, and right-click panel. The minimap frame position is not changed."
L["OPTIONS_VISTA_AUTO_ZOOM"]                                          = "자동 줌"
L["OPTIONS_VISTA_AUTO_ZOOM_DELAY"]                                    = "자동 줌아웃 지연"
L["OPTIONS_VISTA_SECONDS_AFTER_ZOOMING_BEFORE_AUTO_ZOOM"]             = "줌 후 자동 줌아웃까지의 초. 0으로 설정하면 비활성화됩니다."

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["OPTIONS_VISTA_ZONE_TEXT_HEADER"]                                   = "지역 텍스트"
L["OPTIONS_VISTA_ZONE_FONT"]                                          = "지역 글꼴"
L["OPTIONS_VISTA_FONT_ZONE_NAME_BELOW_MINIMAP"]                       = "미니맵 아래 지역명 글꼴."
L["OPTIONS_VISTA_ZONE_FONT_SIZE"]                                     = "지역 글자 크기"
L["OPTIONS_VISTA_ZONE_TEXT_COLOR"]                                    = "지역 텍스트 색상"
L["OPTIONS_VISTA_COLOR_OF_ZONE_NAME_TEXT"]                            = "지역명 텍스트 색상."
L["OPTIONS_VISTA_COORDINATES_TEXT"]                                   = "좌표 텍스트"
L["OPTIONS_VISTA_COORDINATES_FONT"]                                   = "좌표 글꼴"
L["OPTIONS_VISTA_FONT_COORDINATES_TEXT_BELOW_MINIMAP"]                = "미니맵 아래 좌표 텍스트 글꼴."
L["OPTIONS_VISTA_COORDINATES_FONT_SIZE"]                              = "좌표 글자 크기"
L["OPTIONS_VISTA_COORDINATES_TEXT_COLOR"]                             = "좌표 텍스트 색상"
L["OPTIONS_VISTA_COLOR_OF_COORDINATES_TEXT"]                          = "좌표 텍스트 색상."
L["OPTIONS_VISTA_COORDINATE_PRECISION"]                               = "좌표 정밀도"
L["OPTIONS_VISTA_NUMBER_OF_DECIMAL_PLACES_SHOWN_X"]                   = "X 및 Y 좌표에 표시할 소수 자릿수."
L["OPTIONS_VISTA_COORDS_DECIMALS_OFF"]                                = "소수 없음 (예: 52, 37)"
L["OPTIONS_VISTA_DECIMAL_E_G"]                                        = "소수 1자리 (예: 52.3, 37.1)"
L["OPTIONS_VISTA_DECIMALS_E_G"]                                       = "소수 2자리 (예: 52.34, 37.12)"
L["OPTIONS_VISTA_TEXT"]                                               = "시간 텍스트"
L["OPTIONS_VISTA_FONT"]                                               = "시간 글꼴"
L["OPTIONS_VISTA_FONT_TEXT_BELOW_MINIMAP"]                            = "미니맵 아래 시간 텍스트 글꼴."
L["OPTIONS_VISTA_FONT_SIZE"]                                          = "시간 글자 크기"
L["OPTIONS_VISTA_TEXT_COLOR"]                                         = "시간 텍스트 색상"
L["OPTIONS_VISTA_COLOR_OF_TEXT"]                                      = "시간 텍스트 색상."
-- L["OPTIONS_VISTA_PERFORMANCE_TEXT"]                                = "Performance Text"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_PERFORMANCE_FONT"]                                = "Performance font"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_FONT_FPS_LATENCY_TEXT_BELOW_MINIMAP"]             = "Font for the FPS and latency text below the minimap."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_PERFORMANCE_FONT_SIZE"]                           = "Performance font size"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_PERFORMANCE_TEXT_COLOR"]                          = "Performance text color"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_COLOR_OF_FPS_LATENCY_TEXT"]                       = "Color of the FPS and latency text."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_DIFFICULTY_TEXT"]                                    = "난이도 텍스트"
L["OPTIONS_VISTA_DIFFICULTY_TEXT_COLOR_FALLBACK"]                     = "난이도 텍스트 색상 (기본값)"
L["OPTIONS_VISTA_DEFAULT_COLOR_PER_DIFFICULTY_COLOR"]                 = "난이도별 색상이 설정되지 않았을 때 사용하는 기본 색상."
L["OPTIONS_VISTA_DIFFICULTY_FONT"]                                    = "난이도 글꼴"
L["OPTIONS_VISTA_FONT_INSTANCE_DIFFICULTY_TEXT"]                      = "인스턴스 난이도 텍스트 글꼴."
L["OPTIONS_VISTA_DIFFICULTY_FONT_SIZE"]                               = "난이도 글자 크기"
L["OPTIONS_VISTA_PER_DIFFICULTY_COLORS"]                              = "난이도별 색상"
L["OPTIONS_VISTA_MYTHIC_COLOR"]                                       = "신화 색상"
L["OPTIONS_VISTA_COLOR_MYTHIC_DIFFICULTY_TEXT"]                       = "신화 난이도 텍스트 색상."
L["OPTIONS_VISTA_HEROIC_COLOR"]                                       = "영웅 색상"
L["OPTIONS_VISTA_COLOR_HEROIC_DIFFICULTY_TEXT"]                       = "영웅 난이도 텍스트 색상."
L["OPTIONS_VISTA_NORMAL_COLOR"]                                       = "일반 색상"
L["OPTIONS_VISTA_COLOR_NORMAL_DIFFICULTY_TEXT"]                       = "일반 난이도 텍스트 색상."
L["OPTIONS_VISTA_LFR_COLOR"]                                          = "공격대 찾기 색상"
L["OPTIONS_VISTA_COLOR_LOOKING_RAID_DIFFICULTY_TEXT"]                 = "공격대 찾기 난이도 텍스트 색상."

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["OPTIONS_VISTA_TEXT_ELEMENTS"]                                      = "텍스트 요소"
L["OPTIONS_VISTA_ZONE_TEXT"]                                          = "지역 텍스트 표시"
L["OPTIONS_VISTA_ZONE_NAME_BELOW_MINIMAP"]                            = "미니맵 아래에 지역명을 표시합니다."
L["OPTIONS_VISTA_ZONE_TEXT_DISPLAY_MODE"]                             = "지역 텍스트 표시 방식"
L["OPTIONS_VISTA_WHAT_ZONE_SUBZONE"]                                  = "표시할 내용: 지역만, 하위 지역만, 또는 둘 다."
L["OPTIONS_VISTA_ZONE"]                                               = "지역만"
L["OPTIONS_VISTA_SUBZONE"]                                            = "하위 지역만"
L["OPTIONS_VISTA_BOTH"]                                               = "둘 다"
L["OPTIONS_VISTA_COORDINATES"]                                        = "좌표 표시"
L["OPTIONS_VISTA_PLAYER_COORDINATES_BELOW_MINIMAP"]                   = "미니맵 아래에 플레이어 좌표를 표시합니다."
L["OPTIONS_VISTA_TIME"]                                               = "시간 표시"
L["OPTIONS_VISTA_CURRENT_GAME_BELOW_MINIMAP"]                         = "미니맵 아래에 현재 게임 시간을 표시합니다."
-- L["OPTIONS_VISTA_HOUR_CLOCK"]                                      = "24-hour clock"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_DISPLAY_HOUR_FORMAT_E_G_INSTEAD"]                 = "Display time in 24-hour format (e.g. 14:30 instead of 2:30 PM)."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_LOCAL"]                                              = "로컬 시간 사용"
L["OPTIONS_VISTA_YOUR_LOCAL_SYSTEM"]                                  = "활성화: 로컬 시스템 시간 표시. 비활성화: 서버 시간 표시."
-- L["OPTIONS_VISTA_FPS_LATENCY"]                                     = "Show FPS and latency"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_FPS_LATENCY_MS_BELOW_MINIMAP"]                    = "Show FPS and latency (ms) below the minimap."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_MINIMAP_BUTTONS"]                                    = "미니맵 버튼"
L["OPTIONS_VISTA_QUEUE_STATUS_MAIL_INDICATOR_ALWAYS_SHOWN"]           = "대기열 상태 및 우편 알림은 해당될 때 항상 표시됩니다."
L["OPTIONS_VISTA_TRACKING_BUTTON"]                                    = "추적 버튼 표시"
L["OPTIONS_VISTA_MINIMAP_TRACKING_BUTTON"]                            = "미니맵 추적 버튼을 표시합니다."
L["OPTIONS_VISTA_TRACKING_BUTTON_MOUSEOVER"]                          = "마우스 올릴 때만 추적 버튼 표시"
L["OPTIONS_VISTA_HIDE_TRACKING_BUTTON_UNTIL_YOU_HOVER"]               = "미니맵에 마우스를 올릴 때까지 추적 버튼을 숨깁니다."
L["OPTIONS_VISTA_CALENDAR_BUTTON"]                                    = "달력 버튼 표시"
L["OPTIONS_VISTA_MINIMAP_CALENDAR_BUTTON"]                            = "미니맵 달력 버튼을 표시합니다."
L["OPTIONS_VISTA_CALENDAR_BUTTON_MOUSEOVER"]                          = "마우스 올릴 때만 달력 버튼 표시"
L["OPTIONS_VISTA_HIDE_CALENDAR_BUTTON_UNTIL_YOU_HOVER"]               = "미니맵에 마우스를 올릴 때까지 달력 버튼을 숨깁니다."
L["OPTIONS_VISTA_ZOOM_BUTTONS"]                                       = "줌 버튼 표시"
L["OPTIONS_VISTA_ZOOM_BUTTONS_MINIMAP"]                               = "미니맵에 줌 + 및 - 버튼을 표시합니다."
L["OPTIONS_VISTA_ZOOM_BUTTONS_MOUSEOVER"]                             = "마우스 올릴 때만 줌 버튼 표시"
L["OPTIONS_VISTA_HIDE_ZOOM_BUTTONS_UNTIL_YOU_HOVER"]                  = "미니맵에 마우스를 올릴 때까지 줌 버튼을 숨깁니다."

-- =====================================================================
-- OptionsData.lua Vista — Display (Border / Text Positions / Buttons)
-- =====================================================================
L["OPTIONS_VISTA_BORDER"]                                             = "테두리"
L["OPTIONS_VISTA_A_BORDER_AROUND_MINIMAP"]                            = "미니맵 주위에 테두리를 표시합니다."
L["OPTIONS_VISTA_BORDER_COLOR"]                                       = "테두리 색상"
L["OPTIONS_VISTA_COLOR_OPACITY_OF_MINIMAP_BORDER"]                    = "미니맵 테두리의 색상 (및 불투명도)."
L["OPTIONS_VISTA_BORDER_THICKNESS"]                                   = "테두리 두께"
L["OPTIONS_VISTA_THICKNESS_OF_MINIMAP_BORDER_PIXELS"]                 = "미니맵 테두리 두께 (픽셀, 1–8)."
-- L["OPTIONS_VISTA_CLASS_COLOURS"]                                   = "Class colours"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_TINT_VISTA_BORDER_TEXT_COORDS_FPS"]               = "Tint Vista border and text (coords, time, FPS/MS labels) with your class colour. Numbers use the configured colour."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_TEXT_POSITIONS"]                                     = "텍스트 위치"
L["OPTIONS_VISTA_DRAG_TEXT_ELEMENTS_REPOSITION_LOCK_PREVEN"]          = "텍스트 요소를 드래그하여 위치를 변경합니다. 잠금으로 실수로 움직이는 것을 방지합니다."
L["OPTIONS_VISTA_LOCK_ZONE_TEXT_POSITION"]                            = "지역 텍스트 위치 잠금"
L["OPTIONS_VISTA_ZONE_TEXT_CANNOT_DRAGGED"]                           = "활성화 시 지역 텍스트를 드래그할 수 없습니다."
L["OPTIONS_VISTA_LOCK_COORDINATES_POSITION"]                          = "좌표 위치 잠금"
L["OPTIONS_VISTA_COORDINATES_TEXT_CANNOT_DRAGGED"]                    = "활성화 시 좌표 텍스트를 드래그할 수 없습니다."
L["OPTIONS_VISTA_LOCK_POSITION"]                                      = "시간 위치 잠금"
L["OPTIONS_VISTA_TEXT_CANNOT_DRAGGED"]                                = "활성화 시 시간 텍스트를 드래그할 수 없습니다."
-- L["OPTIONS_VISTA_PERFORMANCE_TEXT_POSITION"]                       = "Performance text position"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_PLACE_FPS_LATENCY_TEXT_ABOVE_BELOW"]              = "Place the FPS/latency text above or below the minimap."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_LOCK_PERFORMANCE_TEXT_POSITION"]                  = "Lock performance text position"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_FPS_LATENCY_TEXT_CANNOT_DRAGGED"]                 = "When on, the FPS/latency text cannot be dragged."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_LOCK_DIFFICULTY_TEXT_POSITION"]                      = "난이도 텍스트 위치 잠금"
L["OPTIONS_VISTA_DIFFICULTY_TEXT_CANNOT_DRAGGED"]                     = "활성화 시 난이도 텍스트를 드래그할 수 없습니다."
L["OPTIONS_VISTA_BUTTON_POSITIONS"]                                   = "버튼 위치"
L["OPTIONS_VISTA_DRAG_BUTTONS_REPOSITION_LOCK_PREVENT_MOVE"]          = "버튼을 드래그하여 위치를 변경합니다. 잠금으로 이동을 방지합니다."
L["OPTIONS_VISTA_LOCK_ZOOM_BUTTON"]                                   = "줌 인 버튼 잠금"
L["OPTIONS_VISTA_PREVENT_DRAGGING_ZOOM_BUTTON"]                       = "줌 + 버튼을 드래그할 수 없게 합니다."
L["OPTIONS_VISTA_LOCK_ZOOM_OUT_BUTTON"]                               = "줌 아웃 버튼 잠금"
L["OPTIONS_VISTA_LOCK_ZOOM_OUT_DRAG"]                                 = "줌 - 버튼을 드래그할 수 없게 합니다."
L["OPTIONS_VISTA_LOCK_TRACKING_BUTTON"]                               = "추적 버튼 잠금"
L["OPTIONS_VISTA_PREVENT_DRAGGING_TRACKING_BUTTON"]                   = "추적 버튼을 드래그할 수 없게 합니다."
L["OPTIONS_VISTA_LOCK_CALENDAR_BUTTON"]                               = "달력 버튼 잠금"
L["OPTIONS_VISTA_PREVENT_DRAGGING_CALENDAR_BUTTON"]                   = "달력 버튼을 드래그할 수 없게 합니다."
L["OPTIONS_VISTA_LOCK_QUEUE_BUTTON"]                                  = "대기열 버튼 잠금"
L["OPTIONS_VISTA_PREVENT_DRAGGING_QUEUE_STATUS_BUTTON"]               = "대기열 상태 버튼을 드래그할 수 없게 합니다."
L["OPTIONS_VISTA_LOCK_MAIL_INDICATOR"]                                = "우편 알림 잠금"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MAIL_ICON"]                         = "우편 아이콘을 드래그할 수 없게 합니다."
-- L["OPTIONS_VISTA_DISABLE_QUEUE_HANDLING"]                          = "Disable queue handling"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_DISABLE_QUEUE_BUTTON_HANDLING"]                      = "대기열 버튼 관리 비활성화"
L["OPTIONS_VISTA_TURN_QUEUE_BUTTON_ANCHORING_ANOTHER_A"]              = "모든 대기열 버튼 고정을 끕니다 (다른 애드온이 관리하는 경우 사용)."
L["OPTIONS_VISTA_BUTTON_SIZES"]                                       = "버튼 크기"
L["OPTIONS_VISTA_ADJUST_SIZE_OF_MINIMAP_OVERLAY_BUTTONS"]             = "미니맵 오버레이 버튼의 크기를 조정합니다."
L["OPTIONS_VISTA_TRACKING_BUTTON_SIZE"]                               = "추적 버튼 크기"
L["OPTIONS_VISTA_SIZE_OF_TRACKING_BUTTON_PIXELS"]                     = "추적 버튼 크기 (픽셀)."
L["OPTIONS_VISTA_CALENDAR_BUTTON_SIZE"]                               = "달력 버튼 크기"
L["OPTIONS_VISTA_SIZE_OF_CALENDAR_BUTTON_PIXELS"]                     = "달력 버튼 크기 (픽셀)."
L["OPTIONS_VISTA_QUEUE_BUTTON_SIZE"]                                  = "대기열 버튼 크기"
L["OPTIONS_VISTA_SIZE_OF_QUEUE_STATUS_BUTTON_PIXELS"]                 = "대기열 상태 버튼 크기 (픽셀)."
L["OPTIONS_VISTA_ZOOM_BUTTON_SIZE"]                                   = "줌 버튼 크기"
L["OPTIONS_VISTA_SIZE_OF_ZOOM_ZOOM_BUTTONS_PIXELS"]                   = "줌 인/줌 아웃 버튼 크기 (픽셀)."
L["OPTIONS_VISTA_MAIL_INDICATOR_SIZE"]                                = "우편 알림 크기"
L["OPTIONS_VISTA_SIZE_OF_MAIL_ICON_PIXELS"]                           = "새 우편 아이콘 크기 (픽셀)."
L["OPTIONS_VISTA_ADDON_BUTTON_SIZE"]                                  = "애드온 버튼 크기"
L["OPTIONS_VISTA_SIZE_OF_COLLECTED_ADDON_MINIMAP_BUTTONS"]            = "수집된 애드온 미니맵 버튼 크기 (픽셀)."

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
-- L["OPTIONS_VISTA_COLLECT_HORIZON_MINIMAP"]                         = "Include Horizon minimap icon"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_COLLECT_HORIZON_MINIMAP_DESC"]                    = "Put Horizon's own minimap icon in the managed addon bar, right-click panel, or drawer instead of leaving it on the minimap edge."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_ADDON_BUTTONS"]                                   = "Addon Buttons"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_MINIMAP_ADDON_BUTTONS"]                              = "미니맵 애드온 버튼"
L["OPTIONS_VISTA_BUTTON_MANAGEMENT"]                                  = "버튼 관리"
L["OPTIONS_VISTA_MANAGE_ADDON_MINIMAP_BUTTONS"]                       = "애드온 미니맵 버튼 관리"
L["OPTIONS_VISTA_VISTA_TAKES_CONTROL_OF_ADDON_MINIMAP"]               = "활성화 시 Vista가 애드온 미니맵 버튼을 제어하고 선택한 모드로 그룹화합니다."
L["OPTIONS_VISTA_BUTTON_MODE"]                                        = "버튼 모드"
L["OPTIONS_VISTA_ADDON_BUTTONS_PRESENTED_HOVER_BAR_BELOW"]            = "애드온 버튼 표시 방식: 미니맵 아래 호버 바, 우클릭 패널, 또는 플로팅 서랍 버튼."
-- L["OPTIONS_VISTA_ALWAYS_BAR"]                                      = "Always show bar"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_ALWAYS_MOUSEOVER_BAR_POSITIONING"]                = "Always show mouseover bar (for positioning)"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_KEEP_MOUSEOVER_BAR_VISIBLE_TIMES_YOU"]            = "Keep the mouseover bar visible at all times so you can reposition it. Disable when done."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_DISABLE_DONE"]                                    = "Disable when done."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_MOUSEOVER_BAR"]                                      = "마우스오버 바"
L["OPTIONS_VISTA_RIGHT_CLICK_PANEL"]                                  = "우클릭 패널"
L["OPTIONS_VISTA_FLOATING_DRAWER"]                                    = "플로팅 서랍"
L["OPTIONS_VISTA_LOCK_DRAWER_BUTTON_POSITION"]                        = "서랍 버튼 위치 잠금"
L["OPTIONS_VISTA_PREVENT_DRAGGING_FLOATING_DRAWER_BUTTON"]            = "플로팅 서랍 버튼을 드래그할 수 없게 합니다."
L["OPTIONS_VISTA_LOCK_MOUSEOVER_BAR_POSITION"]                        = "마우스오버 바 위치 잠금"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MOUSEOVER_BUTTON_BAR"]              = "마우스오버 버튼 바를 드래그할 수 없게 합니다."
L["OPTIONS_VISTA_LOCK_RIGHT_CLICK_PANEL_POSITION"]                    = "우클릭 패널 위치 잠금"
L["OPTIONS_VISTA_PREVENT_DRAGGING_RIGHT_CLICK_PANEL"]                 = "우클릭 패널을 드래그할 수 없게 합니다."
L["OPTIONS_VISTA_BUTTONS_PER_ROW_COLUMN"]                             = "행/열당 버튼 수"
L["OPTIONS_VISTA_CONTROLS_MANY_BUTTONS_APPEAR_BEFORE_WRAPPING"]       = "줄 바꿈 전 버튼 수를 제어합니다. 좌/우 방향은 열, 상/하 방향은 행입니다."
L["OPTIONS_VISTA_EXPAND_DIRECTION"]                                   = "확장 방향"
L["OPTIONS_VISTA_DIRECTION_BUTTONS_FILL_ANCHOR_POINT_LEFT"]           = "앵커 포인트에서 버튼이 채워지는 방향. 좌/우 = 가로 행. 상/하 = 세로 열."
L["OPTIONS_VISTA_RIGHT"]                                              = "오른쪽"
L["OPTIONS_VISTA_LEFT"]                                               = "왼쪽"
L["OPTIONS_VISTA_DOWN"]                                               = "아래"
L["OPTIONS_VISTA_UP"]                                                 = "위"
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
L["OPTIONS_VISTA_PANEL_APPEARANCE"]                                   = "패널 외형"
L["OPTIONS_VISTA_COLORS_DRAWER_RIGHT_CLICK_BUTTON_PANELS"]            = "서랍 및 우클릭 버튼 패널 색상."
L["OPTIONS_VISTA_PANEL_BG_COLOR_LABEL"]                               = "패널 배경 색상"
L["OPTIONS_VISTA_BACKGROUND_COLOR_OF_ADDON_BUTTON_PANELS"]            = "애드온 버튼 패널의 배경 색상."
L["OPTIONS_VISTA_PANEL_BORDER_COLOR"]                                 = "패널 테두리 색상"
L["OPTIONS_VISTA_BORDER_COLOR_OF_ADDON_BUTTON_PANELS"]                = "애드온 버튼 패널의 테두리 색상."
L["OPTIONS_VISTA_MANAGED_BUTTONS"]                                    = "관리 중인 버튼"
L["OPTIONS_VISTA_BUTTON_COMPLETELY_IGNORED_A"]                        = "비활성화 시 이 버튼은 애드온에서 완전히 무시됩니다."
L["OPTIONS_VISTA_ADDON_BUTTONS_DETECTED"]                             = "(아직 감지된 애드온 버튼 없음)"
L["OPTIONS_VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE"]                      = "표시 버튼 (포함하려면 체크)"
L["OPTIONS_VISTA_ADDON_BUTTONS_DETECTED_OPEN_YOUR_MINIMAP"]           = "(아직 감지된 애드온 버튼 없음 — 미니맵을 먼저 여세요)"

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
-- L["FOCUS_AH_SEARCH_TITLE"]                                         = "Search Auction House"  -- NEEDS TRANSLATION
L["FOCUS_AH_SEARCH_TOOLTIP"]                                          = "Left-click: search for one craft worth of reagents.\nRight-click: enter how many crafts to multiply quantities.\nThe Auction House must be open."
-- L["FOCUS_AH_CRAFT_DIALOG_SUBTITLE"]                                = "Auction House shopping list"  -- NEEDS TRANSLATION
-- L["FOCUS_AH_CRAFT_HINT_CRAFT_COUNT"]                               = "Number of crafts to buy materials for (1–999). List quantities are multiplied by this."  -- NEEDS TRANSLATION
L["FOCUS_AH_CRAFT_HINT_TIER"]                                         = "Crafting tier 1, 2, or 3 for every Auctionator row, or leave empty to use each item’s tier."
-- L["FOCUS_AH_CRAFT_TIER_ANY"]                                       = "Any tier"  -- NEEDS TRANSLATION
-- L["FOCUS_AH_CRAFT_TIER_N"]                                         = "Tier %d"  -- NEEDS TRANSLATION
-- L["FOCUS_AH_CRAFT_COUNT_INVALID"]                                  = "Enter a whole number from 1 to 999."  -- NEEDS TRANSLATION
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
-- L["OPTIONS_CORE_X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]           = "X/Y: objectives like 3/10. Percent: objectives like 45%."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ZONE_ENTRY"]                                       = "Zone entry"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ZONE_LABELS"]                                      = "Zone labels"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ZONE_NAME_STILL_APPEARS_ENTERING_A"]               = "Zone name still appears when entering a new zone."  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_ZONE_TYPE_COLORING"]                               = "Zone type coloring"  -- NEEDS TRANSLATION
-- L["OPTIONS_CORE_TINTERFACE_BUTTONS_UI_CHECKBOX_CHECK_T"]           = "|TInterface\\\\Buttons\\\\UI-CheckBox-Check:12:12:0:0|t instead of green for done objectives."  -- NEEDS TRANSLATION













































































































