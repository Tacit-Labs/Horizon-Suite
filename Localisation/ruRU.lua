if GetLocale() ~= "ruRU" then return end

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = setmetatable({}, { __index = addon.L })
addon.L = L
addon.StandardFont = UNIT_NAME_FONT

-- =====================================================================
-- OptionsPanel.lua (deprecated) — remaining strings for that UI
-- Panel title + module short names: addon.BrandDisplay (core/BrandDisplay.lua).
-- =====================================================================
L["OPTIONS_FOCUS_OTHER"]                                              = "Прочее"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["OPTIONS_FOCUS_QUEST_TYPES"]                                        = "Типы заданий"
L["OPTIONS_FOCUS_ELEMENT_OVERRIDES"]                                  = "Цвета по элементам"
L["OPTIONS_FOCUS_PER_CATEGORY"]                                       = "Цвета по категориям"
L["OPTIONS_FOCUS_GROUPING_OVERRIDES"]                                 = "Пользовательские цвета"
-- L["OPTIONS_FOCUS_SECTION_OVERRIDES"]                               = "Section Overrides"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_COLORS"]                                             = "Прочие цвета"

-- =====================================================================
-- OptionsPanel.lua — Color row labels (collapsible group sub-rows)
-- =====================================================================
L["OPTIONS_FOCUS_SECTION"]                                            = "Секция"
L["OPTIONS_FOCUS_TITLE"]                                              = "Заголовок"
L["OPTIONS_FOCUS_ZONE"]                                               = "Зона"
L["OPTIONS_FOCUS_OBJECTIVE"]                                          = "Цель"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["OPTIONS_FOCUS_READY_TURN_OVERRIDES_BASE_COLOURS"]                  = "Отдельные цвета для раздела «Готово к сдаче»"
L["OPTIONS_FOCUS_READY_TURN_COLOURS_QUESTS"]                          = "Задания, готовые к сдаче, используют свои цвета в этом разделе."
L["OPTIONS_FOCUS_CURRENT_ZONE_OVERRIDES_BASE_COLOURS"]                = "Отдельные цвета для раздела «Текущая зона»"
L["OPTIONS_FOCUS_CURRENT_ZONE_COLOURS_QUESTS_SEC"]                    = "Задания текущей зоны используют свои цвета в этом разделе."
L["OPTIONS_FOCUS_CURRENT_QUEST_OVERRIDES_BASE_COLOURS"]               = "Отдельные цвета для раздела «Текущий квест»"
L["OPTIONS_FOCUS_CURRENT_QUEST_COLOURS_QUESTS_SE"]                    = "Задания текущего квеста используют свои цвета в этом разделе."
L["OPTIONS_FOCUS_DISTINCT_COLOR_COMPLETED_OBJECTIVES"]                = "Отдельный цвет для выполненных целей"
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES_E_G_COLOR_B"]                   = "Вкл.: выполненные цели (напр. 1/1) используют цвет ниже. Выкл.: тот же цвет, что и у невыполненных."
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVE"]                                = "Выполненная цель"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["OPTIONS_FOCUS_RESET"]                                              = "Сбросить"
L["OPTIONS_FOCUS_RESET_QUEST_TYPES"]                                  = "Сбросить типы заданий"
L["OPTIONS_FOCUS_RESET_OVERRIDES"]                                    = "Сбросить пользовательские цвета"
L["OPTIONS_FOCUS_RESET_DEFAULTS"]                                     = "Сбросить все на значения по умолчанию"
L["OPTIONS_FOCUS_RESET_TO_DEFAULTS"]                                  = "Сбросить на значения по умолчанию"
L["OPTIONS_FOCUS_RESET_DEFAULT"]                                      = "Сбросить на значение по умолчанию"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["OPTIONS_FOCUS_SEARCH_SETTINGS"]                                    = "Поиск настроек..."
L["OPTIONS_FOCUS_SEARCH_FONTS"]                                       = "Поиск шрифта..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["OPTIONS_FOCUS_DRAG_RESIZE"]                                        = "Перетащите для изменения размера"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
-- L["OPTIONS_AXIS_PROFILES"]                                         = "Profiles"  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_MODULES"]                                             = "Модули"
-- L["OPTIONS_AXIS_MODULE_TOGGLES"]                                   = "Module Toggles"  -- NEEDS TRANSLATION

-- =====================================================================
-- options/dashboard/HomeWelcome.lua — First-run welcome
-- =====================================================================
-- L["DASH_WELCOME_TAB"]                                              = "Welcome"  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_TITLE"]                                            = "Welcome to Horizon Suite"  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_HEAD_SUB"]                                         = "What each module does and where to turn them on"  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_INTRO"]                                            = "Horizon Suite is modular — enable only the pieces you want. Turning a module on or off applies on reload. Expand Contributors or Localisations below for credits and supported languages. Use Open module toggles under Modules, or open Axis, then Modules, in the sidebar. You can return to this Welcome page anytime from the sidebar."  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_PATH"]                                             = "%s → %s → %s"  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_MODULES_HEADING"]                                  = "Modules"  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_CONTRIBUTORS_HEADING"]                             = "Contributors"  -- NEEDS TRANSLATION
L["DASH_WELCOME_CONTRIBUTORS_BODY"]                                   = [=[Thanks to everyone who has contributed to Horizon Suite:

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
-- L["DASH_WELCOME_OPEN_MODULE_TOGGLES_LINK"]                         = "Open module toggles"  -- NEEDS TRANSLATION
-- L["DASH_AXIS_MODULE_SHORT_DESCRIPTION"]                            = "Core settings hub: profiles, modules, and global toggles."  -- NEEDS TRANSLATION
-- L["DASH_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS"]                    = "Objective tracker for quests, world quests, rares, achievements, scenarios."  -- NEEDS TRANSLATION
-- L["DASH_ZONE_TEXT_AND_NOTIFICATIONS"]                              = "Zone text and notifications."  -- NEEDS TRANSLATION
-- L["DASH_MINIMAP_ZONE_TEXT_COORDS_BUTTON"]                          = "Minimap with zone text, coords, time, and button collector."  -- NEEDS TRANSLATION
-- L["DASH_TOOLTIPS_CLASS_COLORS_SPEC_FACTION"]                       = "Tooltips with class colors, spec, and faction icons."  -- NEEDS TRANSLATION
-- L["DASH_LOOT_TOASTS_ITEMS_MONEY_CURRENCY"]                         = "Loot toasts for items, money, currency, reputation, and bag overhaul."  -- NEEDS TRANSLATION
-- L["DASH_ESSENCE_MODULE_SHORT_DESCRIPTION"]                         = "Custom character sheet with 3D model, item level, stats, and gear grid."  -- NEEDS TRANSLATION
-- L["DASH_MERIDIAN_MODULE_SHORT_DESCRIPTION"]                        = "Join the Discord and have a guess!"  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_COMMUNITY_HEADING"]                                = "Community & Support"  -- NEEDS TRANSLATION
-- L["DASH_DISCORD"]                                                  = "Discord"  -- NEEDS TRANSLATION
-- L["DASH_KO_FI"]                                                    = "Ko-fi"  -- NEEDS TRANSLATION
-- L["DASH_PATREON"]                                                  = "Patreon"  -- NEEDS TRANSLATION
-- L["DASH_GITLAB"]                                                   = "GitLab"  -- NEEDS TRANSLATION
-- L["DASH_CURSEFORGE"]                                               = "CurseForge"  -- NEEDS TRANSLATION
-- L["DASH_WAGO"]                                                     = "Wago"  -- NEEDS TRANSLATION
-- L["DASH_COPY_LINK_X"]                                              = "Copy link — %s"  -- NEEDS TRANSLATION
L["DASH_LAYOUT"]                                                      = "Расположение"
L["DASH_VISIBILITY"]                                                  = "Видимость"
L["DASH_DISPLAY"]                                                     = "Отображение"
L["DASH_FEATURES"]                                                    = "Функции"
L["DASH_TYPOGRAPHY"]                                                  = "Типографика"
L["DASH_APPEARANCE"]                                                  = "Внешний вид"
L["DASH_COLORS"]                                                      = "Цвета"
L["DASH_ORGANIZATION"]                                                = "Организация"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["OPTIONS_FOCUS_PANEL_BEHAVIOUR"]                                    = "Поведение панели"
L["OPTIONS_FOCUS_DIMENSIONS"]                                         = "Размеры"
L["OPTIONS_FOCUS_INSTANCE"]                                           = "Подземелье"
-- L["OPTIONS_FOCUS_INSTANCES"]                                       = "Instances"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_COMBAT"]                                             = "Бой"
L["OPTIONS_FOCUS_FILTERING"]                                          = "Фильтры"
L["OPTIONS_FOCUS_HEADER"]                                             = "Заголовок"
-- L["OPTIONS_FOCUS_SECTIONS_STRUCTURE"]                              = "Sections & structure"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_ENTRY_DETAILS"]                                   = "Entry details"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_PROGRESS_TIMERS"]                                 = "Progress & timers"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_EMPHASIS"]                                        = "Focus emphasis"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_LIST"]                                               = "Список"
L["OPTIONS_FOCUS_SPACING"]                                            = "Интервалы"
L["OPTIONS_FOCUS_RARE_BOSSES"]                                        = "Редкие боссы"
L["OPTIONS_FOCUS_WORLD_QUESTS"]                                       = "Локальные задания"
L["OPTIONS_FOCUS_FLOATING_QUEST_ITEM"]                                = "Плавающая кнопка предмета"
L["OPTIONS_FOCUS_MYTHIC"]                                             = "Эпохальный+"
L["OPTIONS_FOCUS_ACHIEVEMENTS"]                                       = "Достижения"
L["OPTIONS_FOCUS_ENDEAVORS"]                                          = "Начинания"
L["OPTIONS_FOCUS_DECOR"]                                              = "Украшения"
L["OPTIONS_FOCUS_SCENARIO_DELVE"]                                     = "Сценарий и Подземелье"
L["OPTIONS_FOCUS_FONT"]                                               = "Шрифт"
-- L["OPTIONS_FOCUS_FONT_FAMILIES"]                                   = "Font families"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_GLOBAL_FONT_SIZE"]                                = "Global font size"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_FONT_SIZES"]                                      = "Font sizes"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_PER_ELEMENT_FONTS"]                               = "Per-element fonts"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_TEXT_CASE"]                                          = "Регистр"
L["OPTIONS_FOCUS_SHADOW"]                                             = "Тень"
L["OPTIONS_FOCUS_PANEL"]                                              = "Панель"
L["OPTIONS_FOCUS_HIGHLIGHT"]                                          = "Выделение"
L["OPTIONS_FOCUS_COLOR_MATRIX"]                                       = "Цветовая матрица"
L["OPTIONS_FOCUS_ORDER"]                                              = "Порядок"
L["OPTIONS_FOCUS_SORT"]                                               = "Сортировка"
L["OPTIONS_FOCUS_BEHAVIOUR"]                                          = "Поведение"
L["OPTIONS_FOCUS_CONTENT_TYPES"]                                      = "Типы контента"
L["OPTIONS_FOCUS_DELVES"]                                             = "Подземелья"
L["OPTIONS_FOCUS_DELVES_DUNGEONS"]                                    = "Бездны и Подземелья"
L["OPTIONS_FOCUS_DELVE_COMPLETE"]                                     = "Подземелье завершено"
L["OPTIONS_FOCUS_INTERACTIONS"]                                       = "Взаимодействия"
L["OPTIONS_FOCUS_TRACKING"]                                           = "Отслеживание"
L["OPTIONS_FOCUS_SCENARIO_BAR"]                                       = "Панель сценария"

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
L["OPTIONS_AXIS_ENABLE_FOCUS_MODULE"]                                 = "Включить модуль Фокус"
L["OPTIONS_AXIS_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS_R"]             = "Отображает трекер целей для заданий, локальных заданий, редких боссов, достижений и сценариев."
L["OPTIONS_AXIS_ENABLE_PRESENCE_MODULE"]                              = "Включить модуль Присутствие"
L["OPTIONS_AXIS_CINEMATIC_ZONE_TEXT_NOTIFICATIONS_ZONE_CHANGES"]      = "Кинематографический текст зоны и уведомления (смена зоны, повышение уровня, эмоции боссов, достижения, обновления заданий)."
L["OPTIONS_AXIS_ENABLE_CACHE_MODULE"]                                 = "Включить модуль Cache"
L["OPTIONS_AXIS_CINEMATIC_LOOT_NOTIFICATIONS_ITEMS_MONEY_CURRENCY"]   = "Кинематографические уведомления о добыче (предметы, золото, валюта, репутация)."
L["OPTIONS_AXIS_ENABLE_VISTA_MODULE"]                                 = "Включить модуль Vista"
L["OPTIONS_AXIS_CINEMATIC_SQUARE_MINIMAP_ZONE_TEXT_COORDINATES"]      = "Кинематографическая квадратная миникарта с текстом зоны, координатами и коллектором кнопок."
-- L["OPTIONS_AXIS_MINIMAP_ZONE_TIME_COLLECTOR"]                      = "Cinematic square minimap with zone text, coordinates, time, and button collector."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_BETA"]                                                = "Бета"
L["OPTIONS_AXIS_SCALING"]                                             = "Масштабирование"
-- L["OPTIONS_AXIS_GLOBAL_TOGGLES"]                                   = "Global Toggles"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_SUITE_WIDE_CLASS_COLOUR_TINTING_UI"]               = "Dashboard background theme, class colour tinting, and UI scale (global or per module)."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_GLOBAL_UI_SCALE"]                                     = "Глобальный масштаб интерфейса"
L["OPTIONS_AXIS_SCALE_SIZES_SPACINGS_FONTS_FACTOR"]                   = "Масштабирует все размеры, интервалы и шрифты (50–200%). Не изменяет ваши настройки."
L["OPTIONS_AXIS_PER_MODULE_SCALING"]                                  = "Масштаб по модулям"
L["OPTIONS_AXIS_OVERRIDE_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_FO"]         = "Заменяет глобальный масштаб отдельными ползунками для каждого модуля."
-- L["OPTIONS_AXIS_OVERRIDES_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_F"]      = "Overrides the global scale with individual sliders for Focus, Presence, Vista, etc."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_DOESN_T_CHANGE_YOUR_CONFIGURED_VALUES"]            = "Doesn't change your configured values, only the effective display scale."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_SCALE"]                                              = "Масштаб Фокуса"
L["OPTIONS_AXIS_SCALE_FOCUS_OBJECTIVE_TRACKER"]                       = "Масштаб трекера целей Фокуса (50–200%)."
L["OPTIONS_PRESENCE_SCALE"]                                           = "Масштаб Присутствия"
L["OPTIONS_AXIS_SCALE_PRESENCE_CINEMATIC_TEXT"]                       = "Масштаб кинематографического текста Присутствия (50–200%)."
L["OPTIONS_VISTA_SCALE"]                                              = "Масштаб Vista"
L["OPTIONS_AXIS_SCALE_VISTA_MINIMAP_MODULE"]                          = "Масштаб модуля миникарты Vista (50–200%)."
L["OPTIONS_INSIGHT_SCALE"]                                            = "Масштаб Insight"
L["OPTIONS_AXIS_SCALE_INSIGHT_TOOLTIP_MODULE"]                        = "Масштаб модуля подсказок Insight (50–200%)."
L["OPTIONS_CACHE_SCALE"]                                              = "Масштаб Cache"
L["OPTIONS_AXIS_SCALE_CACHE_LOOT_TOAST_MODULE"]                       = "Масштаб модуля уведомлений о добыче Cache (50–200%)."
L["OPTIONS_AXIS_ENABLE_HORIZON_INSIGHT_MODULE"]                       = "Включить модуль Horizon Insight"
L["OPTIONS_AXIS_CINEMATIC_TOOLTIPS_CLASS_COLORS_SPEC_DISPLAY"]        = "Кинематографические подсказки с цветами классов, специализацией и иконками фракций."
L["OPTIONS_AXIS_TOOLTIP_ANCHOR_MODE"]                                 = "Режим привязки подсказок"
L["OPTIONS_AXIS_WHERE_TOOLTIPS_APPEAR_FOLLOW_CURSOR_FIXED"]           = "Где отображаются подсказки: следовать за курсором или фиксированная позиция."
L["OPTIONS_AXIS_CURSOR"]                                              = "Курсор"
L["OPTIONS_AXIS_FIXED"]                                               = "Фиксировано"
L["OPTIONS_AXIS_ANCHOR_MOVE"]                                         = "Показать якорь для перемещения"
-- L["OPTIONS_AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITIO"]                   = "Click to show or hide the anchor. Drag to set position, right-click to confirm."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_DRAGGABLE_FRAME_FIXED_TOOLTIP_POSITION_D"]            = "Показывает перетаскиваемый фрейм для фиксированной позиции. Перетащите и нажмите ПКМ для подтверждения."
L["OPTIONS_AXIS_RESET_TOOLTIP_POSITION"]                              = "Сбросить позицию подсказок"
L["OPTIONS_AXIS_RESET_FIXED_POSITION_DEFAULT"]                        = "Сбросить фиксированную позицию по умолчанию."
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_X"]                               = "Cursor offset X"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_X_DESC"]                          = "Horizontal pixel offset from the default cursor tooltip position (cursor anchor only)."  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_Y"]                               = "Cursor offset Y"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_Y_DESC"]                          = "Vertical pixel offset from the default cursor tooltip position (cursor anchor only)."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_TOOLTIP_BACKGROUND_COLOR"]                            = "Цвет фона подсказок"
L["OPTIONS_AXIS_COLOR_OF_TOOLTIP_BACKGROUND"]                         = "Цвет фона подсказок."
L["OPTIONS_AXIS_TOOLTIP_BACKGROUND_OPACITY"]                          = "Прозрачность фона подсказок"
L["OPTIONS_AXIS_TOOLTIP_BG_OPACITY_PCT_DESC"]                         = "Прозрачность фона подсказок (0–100%)."
L["OPTIONS_AXIS_TOOLTIP_FONT"]                                        = "Шрифт подсказок"
L["OPTIONS_AXIS_FONT_FAMILY_TOOLTIP_TEXT"]                            = "Семейство шрифтов для всего текста подсказок."
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
-- L["OPTIONS_INSIGHT_SECTION_STATUS_PVP"]                            = "Status & PvP"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_SECTION_RATINGS_GEAR"]                          = "Ratings & gear"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_SECTION_MOUNT"]                                 = "Mount"  -- NEEDS TRANSLATION
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
L["OPTIONS_AXIS_ICONS"]                                               = "Показывать иконки"
-- L["OPTIONS_AXIS_CLASS_ICON_STYLE"]                                 = "Class icon style"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_DEFAULT_BLIZZARD_RONDOMEDIA_CLASS_ICONS_TH"]       = "Use Default (Blizzard) or RondoMedia class icons on the class/spec line."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_RONDOMEDIA_CLASS_ICONS_RONDOFERRARI_HTTPS_WWW"]    = "RondoMedia class icons by RondoFerrari — https://www.curseforge.com/wow/addons/rondomedia"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_DEFAULT"]                                          = "Default"  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_FACTION_SPEC_MOUNT_MYTHIC_ICONS_TOOLTIPS"]            = "Показывать иконки фракции, специализации, маунта и Mythic+ в подсказках."
L["OPTIONS_AXIS_GENERAL"]                                             = "Общие"
L["OPTIONS_AXIS_POSITION"]                                            = "Позиция"
L["OPTIONS_AXIS_RESET_POSITION"]                                      = "Сбросить позицию"
L["OPTIONS_AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"]                   = "Сбросить позицию уведомлений о добыче."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["OPTIONS_FOCUS_LOCK_POSITION"]                                      = "Заблокировать позицию"
L["OPTIONS_FOCUS_PREVENT_DRAGGING_TRACKER"]                           = "Запрещает перетаскивание трекера."
L["OPTIONS_FOCUS_GROW_UPWARD"]                                        = "Рост вверх"
L["OPTIONS_FOCUS_GROW_HEADER"]                                        = "Заголовок при росте"
L["OPTIONS_FOCUS_GROWING_UPWARD_KEEP_HEADER_BOTTOM_TOP"]              = "При росте вверх: заголовок внизу или вверху до свёртывания."
L["OPTIONS_FOCUS_HEADER_BOTTOM"]                                      = "Заголовок внизу"
L["OPTIONS_FOCUS_HEADER_SLIDES_COLLAPSE"]                             = "Заголовок сдвигается при свёртывании"
L["OPTIONS_FOCUS_ANCHOR_BOTTOM_LIST_GROWS_UPWARD"]                    = "Привязка снизу, список растёт вверх."
L["OPTIONS_FOCUS_START_COLLAPSED"]                                    = "Свёрнуто по умолчанию"
L["OPTIONS_FOCUS_START_HEADER_SHOWN_UNTIL_YOU_EXPAND"]                = "Показывать только заголовок до раскрытия."
-- L["OPTIONS_FOCUS_ALIGN_CONTENT_RIGHT"]                             = "Align content right"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_RIGHT_ALIGN_QUEST_TITLES_OBJECTIVES_WITHIN"]      = "Right-align quest titles and objectives within the panel."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_PANEL_WIDTH"]                                        = "Ширина панели"
L["OPTIONS_FOCUS_TRACKER_WIDTH_PIXELS"]                               = "Ширина трекера в пикселях."
L["OPTIONS_FOCUS_MAX_CONTENT_HEIGHT"]                                 = "Макс. высота контента"
L["OPTIONS_FOCUS_MAX_HEIGHT_OF_SCROLLABLE_LIST_PIXELS"]               = "Максимальная высота прокручиваемого списка (пиксели)."

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["OPTIONS_FOCUS_ALWAYS_M_BLOCK"]                                     = "Всегда показывать блок Эпохального+"
L["OPTIONS_FOCUS_M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]                = "Показывать блок Эпохального+ при активном ключе."
L["OPTIONS_FOCUS_DUNGEON"]                                            = "Показывать в подземелье"
L["OPTIONS_FOCUS_TRACKER_PARTY_DUNGEONS"]                             = "Показывать трекер в групповых подземельях."
L["OPTIONS_FOCUS_RAID"]                                               = "Показывать в рейде"
L["OPTIONS_FOCUS_TRACKER_RAIDS"]                                      = "Показывать трекер в рейдах."
L["OPTIONS_FOCUS_BATTLEGROUND"]                                       = "Показывать на поле боя"
L["OPTIONS_FOCUS_TRACKER_BATTLEGROUNDS"]                              = "Показывать трекер на полях боя."
L["OPTIONS_FOCUS_ARENA"]                                              = "Показывать на арене"
L["OPTIONS_FOCUS_TRACKER_ARENAS"]                                     = "Показывать трекер на аренах."
L["OPTIONS_FOCUS_HIDE_COMBAT"]                                        = "Скрывать в бою"
L["OPTIONS_FOCUS_HIDE_TRACKER_FLOATING_QUEST_ITEM_COMBAT"]            = "Скрывает трекер и плавающую кнопку предмета в бою."
L["OPTIONS_FOCUS_COMBAT_VISIBILITY"]                                  = "Видимость в бою"
L["OPTIONS_FOCUS_TRACKER_BEHAVES_COMBAT_FADE_REDUC"]                  = "Поведение трекера в бою: показывать, затемнять или скрывать."
L["OPTIONS_FOCUS_SHOW"]                                               = "Показывать"
L["OPTIONS_FOCUS_FADE"]                                               = "Затемнять"
L["OPTIONS_FOCUS_HIDE"]                                               = "Скрывать"
L["OPTIONS_FOCUS_COMBAT_FADE_OPACITY"]                                = "Прозрачность в бою (затемнение)"
L["OPTIONS_FOCUS_VISIBLE_TRACKER_FADED_COMBAT"]                       = "Видимость трекера при затемнении в бою (0 = невидим). Только при режиме «Затемнять»."
L["OPTIONS_FOCUS_MOUSEOVER"]                                          = "Наведение"
L["OPTIONS_FOCUS_SHOW_ONLY_MOUSEOVER"]                                = "Показывать только при наведении"
L["OPTIONS_FOCUS_FADE_TRACKER_HOVERING_MOVE_MOUSE"]                   = "Затемняет трекер без наведения; наведите курсор для отображения."
L["OPTIONS_FOCUS_FADED_OPACITY"]                                      = "Прозрачность при затемнении"
L["OPTIONS_FOCUS_VISIBLE_TRACKER_FADED_INVISIBLE"]                    = "Видимость трекера при затемнении (0 = невидим)."
L["OPTIONS_FOCUS_QUESTS_CURRENT_ZONE"]                                = "Только задания текущей зоны"
L["OPTIONS_FOCUS_HIDE_QUESTS_OUTSIDE_YOUR_CURRENT_ZONE"]              = "Скрывает задания вне текущей зоны."

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["OPTIONS_FOCUS_QUEST_COUNT"]                                        = "Показывать количество заданий"
L["OPTIONS_FOCUS_QUEST_COUNT_HEADER"]                                 = "Показывает количество заданий в заголовке."
L["OPTIONS_FOCUS_HEADER_COUNT_FORMAT"]                                = "Формат счётчика заданий"
L["OPTIONS_FOCUS_TRACKED_LOG_LOG_MAX_SLOTS_TRACKED"]                  = "Отслеживаемые/в журнале или в журнале/макс. слотов. Отслеживаемые не включают локальные задания."
L["OPTIONS_FOCUS_HEADER_DIVIDER"]                                     = "Показывать разделитель заголовка"
L["OPTIONS_FOCUS_LINE_BELOW_HEADER"]                                  = "Показывает линию под заголовком."
L["OPTIONS_FOCUS_HEADER_DIVIDER_COLOR"]                               = "Цвет разделителя заголовка"
L["OPTIONS_FOCUS_COLOR_OF_LINE_BELOW_HEADER"]                         = "Цвет линии под заголовком."
L["OPTIONS_FOCUS_SUPER_MINIMAL_MODE"]                                 = "Супер-минимальный режим"
L["OPTIONS_FOCUS_HIDE_HEADER_A_PURE_TEXT_LIST"]                       = "Скрывает заголовок для чистого текстового списка."
L["OPTIONS_FOCUS_OPTIONS_BUTTON"]                                     = "Показывать кнопку настроек"
L["OPTIONS_FOCUS_OPTIONS_BUTTON_TRACKER_HEADER"]                      = "Показывает кнопку настроек в заголовке трекера."
L["OPTIONS_FOCUS_HEADER_COLOR"]                                       = "Цвет заголовка"
L["OPTIONS_FOCUS_COLOR_OF_OBJECTIVES_HEADER_TEXT"]                    = "Цвет текста заголовка ЦЕЛИ."
L["OPTIONS_FOCUS_HEADER_HEIGHT"]                                      = "Высота заголовка"
L["OPTIONS_FOCUS_HEIGHT_OF_HEADER_BAR_PIXELS"]                        = "Высота полосы заголовка в пикселях (18–48)."

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["OPTIONS_FOCUS_SECTION_HEADERS"]                                    = "Показывать заголовки секций"
L["OPTIONS_FOCUS_CATEGORY_LABELS_ABOVE_GROUP"]                        = "Показывает названия категорий над каждой группой."
L["OPTIONS_FOCUS_CATEGORY_HEADERS_COLLAPSED"]                         = "Заголовки категорий при свёрнутом виде"
L["OPTIONS_FOCUS_KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED_CLICK"]       = "Сохраняет заголовки видимыми при свёрнутом виде; клик для раскрытия."
L["OPTIONS_FOCUS_NEARBY_CURRENT_ZONE_GROUP"]                          = "Показывать группу «Текущая зона»"
L["OPTIONS_FOCUS_ZONE_QUESTS_A_DEDICATED_CURRENT_ZONE"]               = "Показывает задания зоны в отдельной секции. Выкл.: в обычной категории."
L["OPTIONS_FOCUS_ZONE_LABELS"]                                        = "Показывать названия зон"
L["OPTIONS_FOCUS_ZONE_NAME_UNDER_QUEST_TITLE"]                        = "Показывает название зоны под каждым заданием."
L["OPTIONS_FOCUS_ACTIVE_QUEST_HIGHLIGHT"]                             = "Выделение активного задания"
L["OPTIONS_FOCUS_FOCUSED_QUEST_HIGHLIGHTED"]                          = "Способ выделения отслеживаемого задания."
L["OPTIONS_FOCUS_QUEST_ITEM_BUTTONS"]                                 = "Показывать кнопки предметов заданий"
L["OPTIONS_FOCUS_USABLE_QUEST_ITEM_BUTTON_NEXT_QUEST"]                = "Показывает кнопку используемого предмета рядом с каждым заданием."
-- L["OPTIONS_FOCUS_TOOLTIPS_HOVER"]                                  = "Tooltips on hover"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_TOOLTIPS_HOVERING_TRACKER_ENTRIES_ITE"]           = "Show tooltips when hovering over tracker entries, item buttons, and scenario blocks."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_WOWHEAD_LINK_TOOLTIPS"]                           = "Show WoWhead link in tooltips"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_A_TOOLTIP_SHOWN_ADD_A_LINK"]                      = "When a tooltip is shown, add a link to open the quest, achievement, or NPC on WoWhead."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_VIEW_WOWHEAD"]                                    = "View on WoWhead"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_COPY_LINK"]                                       = "Copy link"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_COPY_URL_BELOW_CTRL_C_PASTE"]                     = "Copy the URL below (Ctrl+C) and paste in your browser."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_OBJECTIVE_NUMBERS"]                                  = "Показывать номера целей"
-- L["OPTIONS_FOCUS_OBJECTIVE_PREFIX"]                                = "Objective prefix"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_PREFIX_OBJECTIVE_A_NUMBER_HYPHEN"]                = "Prefix each objective with a number or hyphen."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_NUMBERS"]                                         = "Numbers (1. 2. 3.)"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_HYPHENS"]                                         = "Hyphens (-)"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_AFTER_SECTION_HEADER"]                            = "After section header"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_BEFORE_SECTION_HEADER"]                           = "Before section header"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_BELOW_HEADER"]                                    = "Below header"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_INLINE_BELOW_TITLE"]                              = "Inline below title"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_PREFIX_OBJECTIVES"]                                  = "Добавляет 1., 2., 3. перед целями."
L["OPTIONS_FOCUS_COMPLETED_COUNT"]                                    = "Показывать счётчик выполненных"
L["OPTIONS_FOCUS_X_Y_PROGRESS_QUEST_TITLE"]                           = "Показывает прогресс X/Y в названии задания."
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_BAR"]                             = "Показывать полосу прогресса целей"
L["OPTIONS_FOCUS_A_PROGRESS_BAR_UNDER_OBJECTIVES_NUMER"]              = "Показывает полосу под целями с числовым прогрессом (напр. 3/250). Только для одной арифметической цели с требуемым количеством > 1."
L["OPTIONS_FOCUS_CATEGORY_COLOR_PROGRESS_BAR"]                        = "Использовать цвет категории для полосы"
L["OPTIONS_FOCUS_PROGRESS_BAR_MATCHES_QUEST_ACHIEVEME"]               = "Вкл.: полоса использует цвет категории. Выкл.: пользовательский цвет ниже."
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXTURE"]                               = "Текстура полосы прогресса"
L["OPTIONS_FOCUS_PROGRESS_BAR_TYPES"]                                 = "Типы полосы прогресса"
L["OPTIONS_FOCUS_TEXTURE_PROGRESS_BAR_FILL"]                          = "Текстура заливки полосы."
L["OPTIONS_FOCUS_TEXTURE_PROGRESS_BAR_FILL_SOLID_YOUR"]               = "Текстура заливки. Сплошная использует ваши цвета. Аддоны SharedMedia добавляют опции."
L["OPTIONS_FOCUS_PROGRESS_BAR_X_Y_OBJECTIVES_PERCENT"]                = "Показывать полосу для целей X/Y, только процентов или обоих."
L["OPTIONS_FOCUS_X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]             = "X/Y: цели как 3/10. Процент: цели как 45%."
L["OPTIONS_FOCUS_X_Y"]                                                = "Только X/Y"
L["OPTIONS_FOCUS_PERCENT"]                                            = "Только процент"
L["OPTIONS_FOCUS_TICK_COMPLETED_OBJECTIVES"]                          = "Галочка для выполненных целей"
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES_A_CHECKMARK_INSTEA"]            = "Вкл.: выполненные цели показывают галочку (✓) вместо зелёного цвета."
L["OPTIONS_FOCUS_ENTRY_NUMBERS"]                                      = "Показывать нумерацию заданий"
L["OPTIONS_FOCUS_PREFIX_QUEST_TITLES_WITHIN_CATEGORY"]                = "Добавляет 1., 2., 3. перед заданиями в каждой категории."
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES"]                               = "Выполненные цели"
L["OPTIONS_FOCUS_MULTI_OBJECTIVE_QUESTS_DISPLAY_OBJECTIVES"]          = "Как отображать выполненные цели в заданиях с несколькими целями (напр. 1/1)."
L["OPTIONS_FOCUS_ALL"]                                                = "Показывать все"
L["OPTIONS_FOCUS_FADE_COMPLETED"]                                     = "Затемнять выполненные"
L["OPTIONS_FOCUS_HIDE_COMPLETED"]                                     = "Скрывать выполненные"
L["OPTIONS_FOCUS_ICON_ZONE_AUTO_TRACKING"]                            = "Показывать иконку автоотслеживания в зоне"
L["OPTIONS_FOCUS_DISPLAY_AN_ICON_NEXT_AUTO_TRACKED"]                  = "Показывает иконку у автоотслеживаемых локальных и еженедельных/ежедневных заданиях, ещё не в журнале (только в зоне)."
L["OPTIONS_FOCUS_AUTO_TRACK_ICON"]                                    = "Иконка автоотслеживания"
L["OPTIONS_FOCUS_CHOOSE_WHICH_ICON_DISPLAY_NEXT_AUTO"]                = "Выберите иконку для автоотслеживаемых заданий в зоне."
L["OPTIONS_FOCUS_APPEND_WORLD_QUESTS_WEEKLIES_DAILIES"]               = "Добавляет ** к локальным и еженедельным/ежедневным заданиям, ещё не в журнале (только в зоне)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["OPTIONS_FOCUS_COMPACT_MODE"]                                       = "Компактный режим"
L["OPTIONS_FOCUS_PRESET_SETS_ENTRY_OBJECTIVE_SPACING_P"]              = "Пресет: интервалы заданий и целей 4 и 1 px."
L["OPTIONS_FOCUS_SPACING_PRESET"]                                     = "Пресет интервалов"
L["OPTIONS_FOCUS_PRESET_ENTRY_OBJECTIVE_SPACING_DEFAULT_P"]           = "Пресет: По умолчанию (8/2 px), Компактный (4/1 px), С отступами (12/3 px) или Пользовательский (ползунки)."
L["OPTIONS_FOCUS_COMPACT_VERSION"]                                    = "Компактная версия"
L["OPTIONS_FOCUS_SPACED_VERSION"]                                     = "Версия с отступами"
L["OPTIONS_FOCUS_SPACING_BETWEEN_QUEST_ENTRIES_PX"]                   = "Интервал между заданиями (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_QUEST_ENTRIES"]                 = "Вертикальный интервал между заданиями."
L["OPTIONS_FOCUS_SPACING_BEFORE_CATEGORY_HEADER_PX"]                  = "Интервал перед заголовком (px)"
L["OPTIONS_FOCUS_GAP_BETWEEN_LAST_ENTRY_OF_A"]                        = "Интервал между последним заданием группы и следующей категорией."
L["OPTIONS_FOCUS_SPACING_AFTER_CATEGORY_HEADER_PX"]                   = "Интервал после заголовка (px)"
L["OPTIONS_FOCUS_GAP_BETWEEN_CATEGORY_LABEL_FIRST_QUEST"]             = "Интервал между заголовком и первым заданием ниже."
L["OPTIONS_FOCUS_SPACING_BETWEEN_OBJECTIVES_PX"]                      = "Интервал между целями (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVE_LINES_WITHIN"]        = "Вертикальный интервал между целями в задании."
L["OPTIONS_FOCUS_TITLE_CONTENT"]                                      = "Заголовок к содержимому"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_QUEST_TITLE_OBJECTIVES"]        = "Вертикальный интервал между названием задания и целями или зоной ниже."
L["OPTIONS_FOCUS_SPACING_BELOW_HEADER_PX"]                            = "Интервал под заголовком (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVES_BAR_QUES"]           = "Вертикальный интервал между полосой целей и списком заданий."
L["OPTIONS_FOCUS_RESET_SPACING"]                                      = "Сбросить интервалы"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_QUEST_LEVEL"]                                   = "Показывать уровень задания"
L["OPTIONS_FOCUS_QUEST_LEVEL_NEXT_TITLE"]                             = "Показывает уровень задания рядом с названием."
L["OPTIONS_FOCUS_DIM_FOCUSED_QUESTS"]                                 = "Затемнять неактивные задания"
L["OPTIONS_FOCUS_SLIGHTLY_DIM_TITLE_ZONE_OBJECTIVES_SECTION"]         = "Слегка затемняет неактивные названия, зоны, цели и заголовки."
-- L["OPTIONS_FOCUS_DIM_UNFOCUSED_ENTRIES"]                           = "Dim unfocused entries"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_A_SECTION_HEADER_EXPAND_CATEGORY"]          = "Click a section header to expand that category."  -- NEEDS TRANSLATION

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["UI_SHOW_RARE_BOSSES"]                                              = "Показывать редких боссов"
L["UI_RARE_BOSS_VIGNETTES_LIST"]                                      = "Показывает редких боссов в списке."
L["UI_RARE_LOOT"]                                                     = "Редкая добыча"
L["UI_TREASURE_ITEM_VIGNETTES_RARE_LOOT"]                             = "Показывает сокровища и предметы в списке редкой добычи."
L["UI_RARE_SOUND_VOLUME"]                                             = "Громкость звука редкой добычи"
L["UI_VOLUME_OF_RARE_ALERT_SOUND"]                                    = "Громкость звука оповещения о редкой добыче (50–200%)."
L["UI_BOOST_REDUCE_RARE_ALERT_VOLUME"]                                = "Увеличить или уменьшить громкость. 100% = нормально; 150% = громче."
L["UI_RARE_ADDED_SOUND"]                                              = "Звук при добавлении редкого"
L["UI_PLAY_A_SOUND_A_RARE"]                                           = "Воспроизводит звук при добавлении редкого."

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["OPTIONS_FOCUS_ZONE_WORLD_QUESTS"]                                  = "Показывать локальные задания зоны"
L["OPTIONS_FOCUS_AUTO_ADD_WORLD_QUESTS_YOUR_CURRENT"]                 = "Автоматически добавляет локальные задания текущей зоны. Выкл.: только отслеживаемые или рядом (по умолчанию Blizzard)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_FLOATING_QUEST_ITEM"]                           = "Показывать плавающую кнопку предмета"
L["OPTIONS_FOCUS_QUICK_BUTTON_FOCUSED_QUEST_S_USABLE"]                = "Показывает кнопку быстрого использования предмета отслеживаемого задания."
L["OPTIONS_FOCUS_LOCK_FLOATING_QUEST_ITEM_POSITION"]                  = "Заблокировать позицию кнопки предмета"
L["OPTIONS_FOCUS_PREVENT_DRAGGING_FLOATING_QUEST_ITEM_BUTTON"]        = "Запрещает перетаскивание кнопки предмета."
L["OPTIONS_FOCUS_FLOATING_QUEST_ITEM_SOURCE"]                         = "Источник предмета"
L["OPTIONS_FOCUS_WHICH_QUEST_S_ITEM_SUPER_TRACKED"]                   = "Чей предмет показывать: сначала отслеживаемое или текущая зона."
L["OPTIONS_FOCUS_SUPER_TRACKED_FIRST"]                                = "Сначала отслеживаемое"
L["OPTIONS_FOCUS_CURRENT_ZONE_FIRST"]                                 = "Сначала текущая зона"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["OPTIONS_FOCUS_MYTHIC_BLOCK"]                                       = "Показывать блок Эпохального+"
L["OPTIONS_FOCUS_TIMER_COMPLETION_AFFIXES_MYTHIC_DUNGEONS"]           = "Показывает таймер, % выполнения и модификаторы в Эпохальных+ подземельях."
L["OPTIONS_FOCUS_M_BLOCK_POSITION"]                                   = "Позиция блока Эпохального+"
L["OPTIONS_FOCUS_POSITION_OF_MYTHIC_BLOCK_RELATIVE_QUEST"]            = "Позиция блока Эпохального+ относительно списка заданий."
L["OPTIONS_FOCUS_AFFIX_ICONS"]                                        = "Показывать иконки модификаторов"
L["OPTIONS_FOCUS_AFFIX_ICONS_NEXT_MODIFIER_NAMES_M"]                  = "Показывает иконки модификаторов в блоке Эпохального+."
L["OPTIONS_FOCUS_AFFIX_DESCRIPTIONS_TOOLTIP"]                         = "Описания модификаторов в подсказке"
L["OPTIONS_FOCUS_AFFIX_DESCRIPTIONS_HOVERING_M_BLO"]                  = "Показывает описания модификаторов при наведении на блок."
L["OPTIONS_FOCUS_M_COMPLETED_BOSS_DISPLAY"]                           = "Отображение побеждённых боссов"
L["OPTIONS_FOCUS_DEFEATED_BOSSES_CHECKMARK_ICON_GREEN"]               = "Как показывать побеждённых боссов: иконка галочки или зелёный цвет."
L["OPTIONS_FOCUS_CHECKMARK"]                                          = "Галочка"
L["OPTIONS_FOCUS_GREEN_COLOR"]                                        = "Зелёный цвет"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["OPTIONS_PRESENCE_ACHIEVEMENTS"]                                    = "Показывать достижения"
L["OPTIONS_FOCUS_TRACKED_ACHIEVEMENTS_LIST"]                          = "Показывает отслеживаемые достижения в списке."
L["OPTIONS_FOCUS_COMPLETED_ACHIEVEMENTS"]                             = "Показывать выполненные достижения"
L["OPTIONS_FOCUS_INCLUDE_COMPLETED_ACHIEVEMENTS_TRACKER_O"]           = "Включает выполненные достижения. Выкл.: только в процессе."
L["OPTIONS_FOCUS_ACHIEVEMENT_ICONS"]                                  = "Показывать иконки достижений"
L["OPTIONS_FOCUS_ACHIEVEMENT_S_ICON_NEXT_TITLE_REQUI"]                = "Показывает иконку каждого достижения. Требуется «Показывать иконки типов заданий»."
L["OPTIONS_FOCUS_MISSING_REQUIREMENTS"]                               = "Показывать только недостающие критерии"
L["OPTIONS_FOCUS_CRITERIA_YOU_HAVEN_T_COMPLETED_TR"]                  = "Показывает только невыполненные критерии. Выкл.: все критерии."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_ENDEAVORS"]                                     = "Показывать начинания"
L["OPTIONS_FOCUS_TRACKED_ENDEAVORS_PLAYER_HOUSING_LIST"]              = "Показывает отслеживаемые начинания (жилище) в списке."
L["OPTIONS_FOCUS_COMPLETED_ENDEAVORS"]                                = "Показывать выполненные начинания"
L["OPTIONS_FOCUS_INCLUDE_COMPLETED_ENDEAVORS_TRACKER"]                = "Включает выполненные начинания. Выкл.: только в процессе."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_DECOR"]                                         = "Показывать украшения"
L["OPTIONS_FOCUS_TRACKED_HOUSING_DECOR_LIST"]                         = "Показывает отслеживаемые украшения жилища в списке."
L["OPTIONS_FOCUS_DECOR_ICONS"]                                        = "Показывать иконки украшений"
L["OPTIONS_FOCUS_DECOR_ITEM_S_ICON_NEXT_TITLE"]                       = "Показывает иконку каждого украшения. Требуется «Показывать иконки типов заданий»."

-- =====================================================================
-- OptionsData.lua Features — Adventure Guide
-- =====================================================================
L["OPTIONS_FOCUS_ADVENTURE_GUIDE"]                                    = "Путеводитель"
L["OPTIONS_FOCUS_TRAVELER_S_LOG"]                                     = "Показывать журнал путешественника"
L["OPTIONS_FOCUS_TRACKED_TRAVELER_S_LOG_OBJECTIVES_SHIFT"]            = "Показывает отслеживаемые цели журнала (Shift+клик в Путеводителе) в списке."
L["OPTIONS_FOCUS_AUTO_REMOVE_COMPLETED_ACTIVITIES"]                   = "Автоудаление выполненных активностей"
L["OPTIONS_FOCUS_AUTOMATICALLY_STOP_TRACKING_TRAVELER_S_LOG"]         = "Автоматически прекращает отслеживание выполненных активностей журнала."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["OPTIONS_FOCUS_SCENARIO_EVENTS"]                                    = "Показывать события сценария"
L["OPTIONS_FOCUS_ACTIVE_SCENARIO_DELVE_ACTIVITIES_DELVES_APP"]        = "Показывает активные сценарии и подземелья. Подземелья в ПОДЗЕМЕЛЬЯ; прочие в СОБЫТИЯ СЦЕНАРИЯ."
L["OPTIONS_FOCUS_TRACK_DELVE_DUNGEON_SCENARIO_ACTIVITIES"]            = "Отслеживание активности в подземельях, бездах и сценариях."
L["OPTIONS_FOCUS_DELVES_APPEAR_DELVES_SECTION_DUNGEONS_DUNGEON"]      = "Бездны в секции БЕЗДНЫ; подземелья в ПОДЗЕМЕЛЬЕ; прочие в СОБЫТИЯ СЦЕНАРИЯ."
-- L["OPTIONS_FOCUS_DELVES_APPEAR_DELVES_SECTION_SCENARIOS_S"]        = "Delves appear in Delves section; other scenarios in Scenario Events."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DELVE_AFFIX_NAMES"]                               = "Delve affix names"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DELVE_DUNGEON"]                                   = "Delve/Dungeon only"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_SCENARIO_DEBUG_LOGGING"]                          = "Scenario debug logging"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_LOG_SCENARIO_API_DATA_CHAT_H"]                    = "Log scenario API data to chat. Use /h debug focus scendebug to toggle."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_PRINTS_C_SCENARIOINFO_CRITERIA_WIDGET_DATA"]      = "Prints C_ScenarioInfo criteria and widget data when in a scenario. Helps diagnose display issues like Abundance 46/300."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_HIDE_CATEGORIES_DELVE_DUNGEON"]                      = "Скрывать другие категории в подземелье"
L["OPTIONS_FOCUS_DELVES_PARTY_DUNGEONS_DELVE_DUNG"]                   = "В подземельях показывать только соответствующую секцию."
L["OPTIONS_FOCUS_DELVE_NAME_SECTION_HEADER"]                          = "Использовать название подземелья как заголовок"
L["OPTIONS_FOCUS_A_DELVE_DELVE_NAME_TIER_AFFIXES"]                    = "В подземелье: название, уровень и модификаторы в заголовке. Выкл.: блок над списком."
L["OPTIONS_FOCUS_AFFIX_NAMES_DELVES"]                                 = "Показывать названия модификаторов в подземельях"
L["OPTIONS_FOCUS_SEASON_AFFIX_NAMES_FIRST_DELVE_ENTRY"]               = "Показывает сезонные модификаторы на первой записи. Требуются виджеты Blizzard."
L["OPTIONS_FOCUS_CINEMATIC_SCENARIO_BAR"]                             = "Кинематографическая панель сценария"
L["OPTIONS_FOCUS_TIMER_PROGRESS_BAR_SCENARIO_ENTRIES"]                = "Показывает таймер и полосу прогресса для сценариев."
L["OPTIONS_FOCUS_TIMER"]                                              = "Показывать таймер"
L["OPTIONS_FOCUS_COUNTDOWN_TIMER_TIMED_QUESTS_EVENTS_SCEN"]           = "Показывать обратный отсчёт на квестах с таймером, событиях и сценариях. Выкл. — таймеры скрыты."
L["OPTIONS_FOCUS_TIMER_DISPLAY"]                                      = "Отображение таймера"
L["OPTIONS_FOCUS_COLOR_TIMER_REMAINING"]                              = "Цвет таймера по оставшемуся времени"
L["OPTIONS_FOCUS_GREEN_PLENTY_OF_LEFT_YELLOW_RUNNING"]                = "Зелёный — много времени, жёлтый — мало, красный — критично."
L["OPTIONS_FOCUS_WHERE_COUNTDOWN_BAR_BELOW_OBJECTIVES"]               = "Где показывать обратный отсчёт: панель под целями или текст рядом с названием задания."
L["OPTIONS_FOCUS_BAR_BELOW"]                                          = "Панель внизу"
L["OPTIONS_FOCUS_INLINE_BESIDE_TITLE"]                                = "Текст рядом с названием"

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["OPTIONS_FOCUS_FONT_FAMILY"]                                        = "Семейство шрифта."
L["OPTIONS_FOCUS_TITLE_FONT"]                                         = "Шрифт заголовков"
L["OPTIONS_VISTA_ZONE_FONT"]                                          = "Шрифт зоны"
L["OPTIONS_FOCUS_OBJECTIVE_FONT"]                                     = "Шрифт целей"
L["OPTIONS_FOCUS_SECTION_FONT"]                                       = "Шрифт секций"
L["OPTIONS_FOCUS_GLOBAL_FONT"]                                        = "Использовать глобальный шрифт"
L["OPTIONS_FOCUS_FONT_FAMILY_QUEST_TITLES"]                           = "Семейство шрифта для названий заданий."
L["OPTIONS_FOCUS_FONT_FAMILY_ZONE_LABELS"]                            = "Семейство шрифта для названий зон."
L["OPTIONS_FOCUS_FONT_FAMILY_OBJECTIVE_TEXT"]                         = "Семейство шрифта для текста целей."
L["OPTIONS_FOCUS_FONT_FAMILY_SECTION_HEADERS"]                        = "Семейство шрифта для заголовков секций."
L["OPTIONS_FOCUS_HEADER_SIZE"]                                        = "Размер заголовка"
L["OPTIONS_FOCUS_HEADER_FONT_SIZE"]                                   = "Размер шрифта заголовка."
L["OPTIONS_FOCUS_TITLE_SIZE"]                                         = "Размер названия"
L["OPTIONS_FOCUS_QUEST_TITLE_FONT_SIZE"]                              = "Размер шрифта названий заданий."
L["OPTIONS_FOCUS_OBJECTIVE_SIZE"]                                     = "Размер целей"
L["OPTIONS_FOCUS_OBJECTIVE_TEXT_FONT_SIZE"]                           = "Размер шрифта текста целей."
L["OPTIONS_FOCUS_ZONE_SIZE"]                                          = "Размер зон"
L["OPTIONS_FOCUS_ZONE_LABEL_FONT_SIZE"]                               = "Размер шрифта названий зон."
L["OPTIONS_FOCUS_SECTION_SIZE"]                                       = "Размер секций"
L["OPTIONS_FOCUS_SECTION_HEADER_FONT_SIZE"]                           = "Размер шрифта заголовков секций."
L["OPTIONS_FOCUS_PROGRESS_BAR_FONT"]                                  = "Шрифт полосы прогресса"
L["OPTIONS_FOCUS_FONT_FAMILY_PROGRESS_BAR_LABEL"]                     = "Семейство шрифта для подписи полосы."
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXT_SIZE"]                             = "Размер текста полосы прогресса"
L["OPTIONS_FOCUS_FONT_SIZE_PROGRESS_BAR_LABEL_ADJUSTS"]               = "Размер шрифта подписи полосы. Также регулирует высоту. Влияет на цели заданий, прогресс сценариев и таймеры."
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL"]                                  = "Заливка полосы прогресса"
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXT"]                                  = "Текст полосы прогресса"
L["OPTIONS_FOCUS_OUTLINE"]                                            = "Контур"
L["OPTIONS_FOCUS_FONT_OUTLINE_STYLE"]                                 = "Стиль контура шрифта."

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["OPTIONS_FOCUS_HEADER_TEXT_CASE"]                                   = "Регистр заголовка"
L["OPTIONS_FOCUS_DISPLAY_CASE_HEADER"]                                = "Регистр отображения заголовка."
L["OPTIONS_FOCUS_SECTION_HEADER_CASE"]                                = "Регистр заголовков секций"
L["OPTIONS_FOCUS_DISPLAY_CASE_CATEGORY_LABELS"]                       = "Регистр отображения категорий."
L["OPTIONS_FOCUS_QUEST_TITLE_CASE"]                                   = "Регистр названий заданий"
L["OPTIONS_FOCUS_DISPLAY_CASE_QUEST_TITLES"]                          = "Регистр отображения названий заданий."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["OPTIONS_FOCUS_TEXT_SHADOW"]                                        = "Показывать тень текста"
L["OPTIONS_FOCUS_ENABLE_DROP_SHADOW_TEXT"]                            = "Включает тень текста."
L["OPTIONS_FOCUS_SHADOW_X"]                                           = "Тень X"
L["OPTIONS_FOCUS_HORIZONTAL_SHADOW_OFFSET"]                           = "Горизонтальное смещение тени."
L["OPTIONS_FOCUS_SHADOW_Y"]                                           = "Тень Y"
L["OPTIONS_FOCUS_VERTICAL_SHADOW_OFFSET"]                             = "Вертикальное смещение тени."
L["OPTIONS_FOCUS_SHADOW_ALPHA"]                                       = "Прозрачность тени"
L["OPTIONS_FOCUS_SHADOW_OPACITY"]                                     = "Прозрачность тени (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["OPTIONS_FOCUS_MYTHIC_TYPOGRAPHY"]                                  = "Типографика Эпохального+"
L["OPTIONS_FOCUS_DUNGEON_NAME_SIZE"]                                  = "Размер названия подземелья"
L["OPTIONS_FOCUS_FONT_SIZE_DUNGEON_NAME_PX"]                          = "Размер шрифта названия подземелья (8–32 px)."
L["OPTIONS_FOCUS_DUNGEON_NAME_COLOR"]                                 = "Цвет названия подземелья"
L["OPTIONS_FOCUS_TEXT_COLOR_DUNGEON_NAME"]                            = "Цвет текста названия подземелья."
L["OPTIONS_FOCUS_TIMER_SIZE"]                                         = "Размер таймера"
L["OPTIONS_FOCUS_FONT_SIZE_TIMER_PX"]                                 = "Размер шрифта таймера (8–32 px)."
L["OPTIONS_FOCUS_TIMER_COLOR"]                                        = "Цвет таймера"
L["OPTIONS_FOCUS_TEXT_COLOR_TIMER"]                                   = "Цвет таймера (в пределах времени)."
L["OPTIONS_FOCUS_TIMER_OVERTIME_COLOR"]                               = "Цвет таймера (время вышло)"
L["OPTIONS_FOCUS_TEXT_COLOR_TIMER_LIMIT"]                             = "Цвет таймера при превышении времени."
L["OPTIONS_FOCUS_PROGRESS_SIZE"]                                      = "Размер прогресса"
L["OPTIONS_FOCUS_FONT_SIZE_ENEMY_FORCES_PX"]                          = "Размер шрифта сил противника (8–32 px)."
L["OPTIONS_FOCUS_PROGRESS_COLOR"]                                     = "Цвет прогресса"
L["OPTIONS_FOCUS_TEXT_COLOR_ENEMY_FORCES"]                            = "Цвет текста сил противника."
L["OPTIONS_FOCUS_BAR_FILL_COLOR"]                                     = "Цвет заливки полосы"
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL_COLOR_PROGRESS"]                   = "Цвет заливки полосы (в процессе)."
L["OPTIONS_FOCUS_BAR_COMPLETE_COLOR"]                                 = "Цвет завершённой полосы"
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL_COLOR_ENEMY_FORCES"]               = "Цвет заливки при 100% сил противника."
L["OPTIONS_FOCUS_AFFIX_SIZE"]                                         = "Размер модификаторов"
L["OPTIONS_FOCUS_FONT_SIZE_AFFIXES_PX"]                               = "Размер шрифта модификаторов (8–32 px)."
L["OPTIONS_FOCUS_AFFIX_COLOR"]                                        = "Цвет модификаторов"
L["OPTIONS_FOCUS_TEXT_COLOR_AFFIXES"]                                 = "Цвет текста модификаторов."
L["OPTIONS_FOCUS_BOSS_SIZE"]                                          = "Размер имён боссов"
L["OPTIONS_FOCUS_FONT_SIZE_BOSS_NAMES_PX"]                            = "Размер шрифта имён боссов (8–32 px)."
L["OPTIONS_FOCUS_BOSS_COLOR"]                                         = "Цвет имён боссов"
L["OPTIONS_FOCUS_TEXT_COLOR_BOSS_NAMES"]                              = "Цвет текста имён боссов."
L["OPTIONS_FOCUS_RESET_MYTHIC_TYPOGRAPHY"]                            = "Сбросить типографику Эпохального+"

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
L["OPTIONS_FOCUS_BACKDROP_OPACITY"]                                   = "Прозрачность фона"
L["OPTIONS_FOCUS_PANEL_BACKGROUND_OPACITY"]                           = "Прозрачность фона панели (0–1)."
L["OPTIONS_FOCUS_BORDER"]                                             = "Показывать границу"
L["OPTIONS_FOCUS_BORDER_AROUND_TRACKER"]                              = "Показывает рамку вокруг трекера."
L["OPTIONS_FOCUS_SCROLL_INDICATOR"]                                   = "Показывать индикатор прокрутки"
L["OPTIONS_FOCUS_A_VISUAL_HINT_LIST_CONTENT_TH"]                      = "Показывает подсказку при наличии скрытого контента."
L["OPTIONS_FOCUS_SCROLL_INDICATOR_STYLE"]                             = "Стиль индикатора прокрутки"
L["OPTIONS_FOCUS_CHOOSE_BETWEEN_A_FADE_GRADIENT_A"]                   = "Градиент или стрелка для обозначения прокручиваемого контента."
L["OPTIONS_FOCUS_ARROW"]                                              = "Стрелка"
L["OPTIONS_FOCUS_HIGHLIGHT_ALPHA"]                                    = "Прозрачность выделения"
L["OPTIONS_FOCUS_OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]                 = "Прозрачность выделения активного задания (0–1)."
L["OPTIONS_FOCUS_BAR_WIDTH"]                                          = "Ширина полосы"
L["OPTIONS_FOCUS_WIDTH_OF_BAR_STYLE_HIGHLIGHTS_PX"]                   = "Ширина полосы выделения (2–6 px)."

-- =====================================================================
-- OptionsData.lua Organization
-- =====================================================================
-- L["OPTIONS_FOCUS_ACTIVITY"]                                        = "Activity"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CONTENT"]                                         = "Content"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_SORTING"]                                         = "Sorting"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_ELEMENTS"]                                        = "Elements"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_CATEGORY_ORDER"]                                     = "Порядок категорий Фокуса"
-- L["OPTIONS_FOCUS_CATEGORY_COLOR_BAR"]                              = "Category color for bar"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CHECKMARK_COMPLETED"]                             = "Checkmark for completed"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CURRENT_QUEST_CATEGORY"]                          = "Current Quest category"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CURRENT_QUEST_WINDOW"]                            = "Current Quest window"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_QUESTS_RECENT_PROGRESS_TOP"]                      = "Show quests with recent progress at the top."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_SECONDS_OF_RECENT_PROGRESS_CURRENT_QUEST"]        = "Seconds of recent progress to show in Current Quest (30–120)."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_QUESTS_YOU_MADE_PROGRESS_LAST_MINUTE"]            = "Quests you made progress on in the last minute appear in a dedicated section."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_CATEGORY_ORDER"]                                     = "Порядок категорий Фокуса"
L["OPTIONS_FOCUS_DRAG_REORDER_CATEGORIES_DELVES_SCENARIO_EVENT"]      = "Перетащите для изменения порядка. ПОДЗЕМЕЛЬЯ и СОБЫТИЯ СЦЕНАРИЯ остаются первыми."
-- L["OPTIONS_FOCUS_DRAG_REORDER_DELVES_SCENARIOS_STAY_FIRST"]        = "Drag to reorder. Delves and Scenarios stay first."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_SORT_MODE"]                                          = "Режим сортировки Фокуса"
L["OPTIONS_FOCUS_ORDER_OF_ENTRIES_WITHIN_CATEGORY"]                   = "Порядок записей в каждой категории."
L["OPTIONS_FOCUS_AUTO_TRACK_ACCEPTED_QUESTS"]                         = "Автоотслеживание принятых заданий"
L["OPTIONS_FOCUS_YOU_ACCEPT_A_QUEST_QUEST_LOG"]                       = "Автоматически добавляет принятые задания в трекер (кроме локальных)."
L["OPTIONS_FOCUS_REQUIRE_CTRL_FOCUS_REMOVE"]                          = "Требовать Ctrl для отслеживания/снятия"
L["OPTIONS_FOCUS_REQUIRE_CTRL_FOCUS_ADD_LEFT_UNFOCUS"]                = "Требует Ctrl для добавления (ЛКМ) и снятия (ПКМ) отслеживания."
-- L["OPTIONS_FOCUS_CTRL_FOCUS_UNTRACK"]                              = "Ctrl for focus / untrack"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CTRL_CLICK_COMPLETE"]                             = "Ctrl to click-complete"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_CLASSIC_CLICK_BEHAVIOUR"]                            = "Классическое поведение при клике"
-- L["OPTIONS_FOCUS_CLASSIC_CLICKS"]                                  = "Classic clicks"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_SHARE_PARTY"]                                        = "Поделиться с группой"
L["OPTIONS_FOCUS_ABANDON_QUEST"]                                      = "Отменить квест"
L["OPTIONS_FOCUS_STOP_TRACKING"]                                      = "Прекратить отслеживание"
L["OPTIONS_FOCUS_QUEST_CANNOT_SHARED"]                                = "Эту квесту нельзя поделиться."
L["OPTIONS_FOCUS_YOU_MUST_A_PARTY_SHARE_QUEST"]                       = "Чтобы поделиться квестом, нужно быть в группе."
L["OPTIONS_FOCUS_LEFT_CLICK_OPENS_QUEST_MAP_RIGHT"]                   = "Вкл: ЛКМ открывает карту квеста, ПКМ — меню «поделиться/отменить» (стиль Blizzard). Выкл: ЛКМ — следить, ПКМ — снять; Ctrl+ПКМ — поделиться с группой."
L["OPTIONS_FOCUS_ANIMATIONS"]                                         = "Focus animations"
L["OPTIONS_FOCUS_ENABLE_SLIDE_FADE_QUESTS"]                           = "Включает анимацию появления и исчезновения заданий."
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_FLASH"]                           = "Вспышка при выполнении цели"
L["OPTIONS_FOCUS_FLASH_AN_OBJECTIVE_COMPLETES"]                       = "Показывает вспышку при выполнении цели."
L["OPTIONS_FOCUS_FLASH_INTENSITY"]                                    = "Интенсивность вспышки"
L["OPTIONS_FOCUS_NOTICEABLE_OBJECTIVE_COMPLETE_FLASH"]                = "Заметность вспышки при выполнении цели."
L["OPTIONS_FOCUS_FLASH_COLOR"]                                        = "Цвет вспышки"
L["OPTIONS_FOCUS_COLOR_OF_OBJECTIVE_COMPLETE_FLASH"]                  = "Цвет вспышки при выполнении цели."
L["OPTIONS_FOCUS_SUBTLE"]                                             = "Лёгкая"
L["OPTIONS_FOCUS_MEDIUM"]                                             = "Средняя"
L["OPTIONS_FOCUS_STRONG"]                                             = "Сильная"
L["OPTIONS_FOCUS_REQUIRE_CTRL_CLICK_COMPLETE"]                        = "Требовать Ctrl для завершения кликом"
L["OPTIONS_FOCUS_REQUIRES_CTRL_LEFT_CLICK_COMPLETE_AUTO"]             = "Вкл.: Ctrl+ЛКМ для завершения. Выкл.: ЛКМ (по умолчанию Blizzard). Только для заданий, завершаемых кликом."
L["OPTIONS_FOCUS_SUPPRESS_UNTRACKED_UNTIL_RELOAD"]                    = "Скрывать снятые до перезагрузки"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS_Z"]                 = "Вкл.: снятые с отслеживания скрыты до перезагрузки. Выкл.: появляются при возврате в зону."
L["OPTIONS_FOCUS_PERMANENTLY_SUPPRESS_UNTRACKED_QUESTS"]              = "Постоянно скрывать снятые с отслеживания"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACKED_WORLD_QUESTS_ZO"]              = "Вкл.: снятые скрыты постоянно. Приоритет над «Скрывать до перезагрузки». Принятие снимает с чёрного списка."
L["OPTIONS_FOCUS_KEEP_CAMPAIGN_QUESTS_CATEGORY"]                      = "Оставлять кампанийные задания в категории"
L["OPTIONS_FOCUS_CAMPAIGN_QUESTS_READY_TURN_RE"]                      = "Вкл.: готовые к сдаче кампанийные остаются в категории Кампания."
L["OPTIONS_FOCUS_KEEP_IMPORTANT_QUESTS_CATEGORY"]                     = "Оставлять важные задания в категории"
L["OPTIONS_FOCUS_IMPORTANT_QUESTS_READY_TURN_R"]                      = "Вкл.: готовые к сдаче важные остаются в категории Важные."
L["OPTIONS_FOCUS_TOMTOM_QUEST_WAYPOINT"]                              = "Точка маршрута TomTom"
L["OPTIONS_FOCUS_A_TOMTOM_WAYPOINT_FOCUSING_A_QUEST"]                 = "Устанавливать точку маршрута TomTom при фокусировке на задании."
L["OPTIONS_FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_NEXT_QUEST"]            = "Требуется TomTom. Стрелка указывает на следующую цель задания."
L["OPTIONS_FOCUS_TOMTOM_RARE_WAYPOINT"]                               = "Точка маршрута TomTom (редкий)"
L["OPTIONS_FOCUS_A_TOMTOM_WAYPOINT_CLICKING_A_RARE"]                  = "Устанавливать точку маршрута TomTom при клике на редкого босса."
L["OPTIONS_FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_RARE_S"]                = "Требуется TomTom. Стрелка указывает на местоположение редкого босса."
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
L["OPTIONS_FOCUS_BLACKLISTED_QUESTS"]                                 = "Задания в чёрном списке"
L["OPTIONS_FOCUS_PERMANENTLY_SUPPRESSED_QUESTS"]                      = "Постоянно скрытые задания"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACK_QUESTS_PERMANENTLY_SUPPRESS"]    = "ПКМ снять с отслеживания при включённой опции «Постоянно скрывать» для добавления сюда."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["OPTIONS_PRESENCE_QUEST_TYPE_ICONS"]                                = "Показывать иконки типов заданий"
L["OPTIONS_PRESENCE_QUEST_TYPE_ICON_FOCUS_TRACKER_QUEST"]             = "Показывает иконки в трекере (принятие/завершение, локальные, обновление)."
L["OPTIONS_PRESENCE_QUEST_TYPE_ICONS_TOASTS"]                         = "Показывать иконки типов на уведомлениях"
L["OPTIONS_PRESENCE_QUEST_TYPE_ICON_PRESENCE_TOASTS_QUEST"]           = "Показывает иконки типов на уведомлениях Присутствия."
L["OPTIONS_PRESENCE_TOAST_ICON_SIZE"]                                 = "Размер иконок на уведомлениях"
L["OPTIONS_PRESENCE_QUEST_ICON_SIZE_PRESENCE_TOASTS_PX"]              = "Размер иконок заданий на уведомлениях (16–36 px). По умолчанию 24."
L["OPTIONS_PRESENCE_HIDE_QUEST_UPDATE_TITLE"]                         = "Скрывать заголовок в уведомлениях о прогрессе"
L["OPTIONS_PRESENCE_OBJECTIVE_LINE_QUEST_PROGRESS_TOAST"]             = "Показывать только строку цели (напр., 7/10 Шкур кабана) без названия задания и заголовка."
L["OPTIONS_PRESENCE_SHOW_DISCOVERY_LINE"]                             = "Показывать строку «Обнаружено»"
-- L["OPTIONS_PRESENCE_DISCOVERY_LINE"]                               = "Discovery line"  -- NEEDS TRANSLATION
L["OPTIONS_PRESENCE_DISCOVERED_UNDER_ZONE_SUBZONE_ENTERING_A"]        = "Показывает «Обнаружено» под зоной/подзоной при входе в новую область."
L["OPTIONS_PRESENCE_FRAME_VERTICAL_POSITION"]                         = "Вертикальная позиция фрейма"
L["OPTIONS_PRESENCE_VERTICAL_OFFSET_OF_PRESENCE_FRAME_CENTER"]        = "Вертикальное смещение фрейма от центра (-300 до 0)."
L["OPTIONS_PRESENCE_FRAME_SCALE"]                                     = "Масштаб фрейма"
L["OPTIONS_PRESENCE_SCALE_OF_PRESENCE_FRAME"]                         = "Масштаб фрейма Присутствия (0.5–2)."
L["OPTIONS_PRESENCE_BOSS_EMOTE_COLOR"]                                = "Цвет эмоций боссов"
L["OPTIONS_PRESENCE_COLOR_OF_RAID_DUNGEON_BOSS_EMOTE"]                = "Цвет текста эмоций боссов в рейдах и подземельях."
L["OPTIONS_PRESENCE_DISCOVERY_LINE_COLOR"]                            = "Цвет строки «Обнаружено»"
L["OPTIONS_PRESENCE_COLOR_OF_DISCOVERED_LINE_UNDER_ZONE"]             = "Цвет строки «Обнаружено» под текстом зоны."
L["OPTIONS_PRESENCE_NOTIFICATION_TYPES"]                              = "Типы уведомлений"
-- L["OPTIONS_PRESENCE_NOTIFICATIONS"]                                = "Notifications"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_NOTIFICATION_ACHIEVEMENT_CRITERIA_UPDATE_T"]   = "Show notification when achievement criteria update (tracked achievements always; others when Blizzard provides the achievement ID)."  -- NEEDS TRANSLATION
L["OPTIONS_PRESENCE_ZONE_ENTRY"]                                      = "Показывать вход в зону"
L["OPTIONS_PRESENCE_ZONE_CHANGE_ENTERING_A_AREA"]                     = "Показывает уведомление при входе в новую зону."
L["OPTIONS_PRESENCE_SUBZONE_CHANGES"]                                 = "Показывать смену подзон"
L["OPTIONS_PRESENCE_SUBZONE_CHANGE_MOVING_WITHIN_SAME_ZONE"]          = "Показывает уведомление при перемещении между подзонами в той же зоне."
L["OPTIONS_PRESENCE_HIDE_ZONE_NAME_SUBZONE_CHANGES"]                  = "Скрывать название зоны при смене подзоны"
L["OPTIONS_PRESENCE_MOVING_BETWEEN_SUBZONES_WITHIN_SAME_ZONE"]        = "При переходе между подзонами показывать только подзону. Название зоны при входе в новую зону."
-- L["OPTIONS_PRESENCE_SUPPRESS_DELVE"]                               = "Suppress in Delve"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_SUPPRESS_SCENARIO_PROGRESS_NOTIFICATIONS_DELVES"]= "Suppress scenario progress notifications in Delves."  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_HIDES_OBJECTIVE_UPDATE_POPUPS_WHILE_A"]        = "When on, hides objective update popups while in a Delve. Zone entry and completion toasts still show."  -- NEEDS TRANSLATION
L["OPTIONS_PRESENCE_SUPPRESS_ZONE_CHANGES_MYTHIC"]                    = "Скрывать смену зон в Эпохальном+"
L["OPTIONS_PRESENCE_MYTHIC_BOSS_EMOTES_ACHIEVEMENTS_LEV"]             = "В Эпохальном+: только эмоции боссов, достижения и повышение уровня."
L["OPTIONS_PRESENCE_LEVEL"]                                           = "Показывать повышение уровня"
L["OPTIONS_PRESENCE_LEVEL_NOTIFICATION"]                              = "Показывает уведомление о повышении уровня."
L["OPTIONS_PRESENCE_BOSS_EMOTES"]                                     = "Показывать эмоции боссов"
L["OPTIONS_PRESENCE_RAID_DUNGEON_BOSS_EMOTE_NOTIFICATIONS"]           = "Показывает уведомления об эмоциях боссов в рейдах и подземельях."
L["OPTIONS_PRESENCE_ACHIEVEMENTS"]                                    = "Показывать достижения"
L["OPTIONS_PRESENCE_ACHIEVEMENT_EARNED_NOTIFICATIONS"]                = "Показывает уведомления о полученных достижениях."
L["OPTIONS_PRESENCE_ACHIEVEMENT_PROGRESS"]                            = "Прогресс достижений"
L["OPTIONS_PRESENCE_ACHIEVEMENT_EARNED"]                              = "Достижение получено"
L["OPTIONS_PRESENCE_QUEST_ACCEPTED"]                                  = "Задание принято"
L["OPTIONS_PRESENCE_WORLD_QUEST_ACCEPTED"]                            = "Локальное задание принято"
L["OPTIONS_PRESENCE_SCENARIO_COMPLETE"]                               = "Сценарий завершён"
L["OPTIONS_PRESENCE_RARE_DEFEATED"]                                   = "Редкий побеждён"
L["OPTIONS_PRESENCE_NOTIFICATION_TRACKED_ACHIEVEMENT_CRITERIA"]       = "Показывает уведомление при обновлении критериев отслеживаемого достижения."
L["OPTIONS_PRESENCE_QUEST_ACCEPT"]                                    = "Показывать принятие задания"
L["OPTIONS_PRESENCE_NOTIFICATION_ACCEPTING_A_QUEST"]                  = "Показывает уведомление при принятии задания."
L["OPTIONS_PRESENCE_WORLD_QUEST_ACCEPT"]                              = "Показывать принятие локального задания"
L["OPTIONS_PRESENCE_NOTIFICATION_ACCEPTING_A_WORLD_QUEST"]            = "Показывает уведомление при принятии локального задания."
L["OPTIONS_PRESENCE_QUEST_COMPLETE"]                                  = "Показывать завершение задания"
L["OPTIONS_PRESENCE_NOTIFICATION_COMPLETING_A_QUEST"]                 = "Показывает уведомление при завершении задания."
L["OPTIONS_PRESENCE_WORLD_QUEST_COMPLETE"]                            = "Показывать завершение локального задания"
L["OPTIONS_PRESENCE_NOTIFICATION_COMPLETING_A_WORLD_QUEST"]           = "Показывает уведомление при завершении локального задания."
L["OPTIONS_PRESENCE_QUEST_PROGRESS"]                                  = "Показывать прогресс задания"
L["OPTIONS_PRESENCE_NOTIFICATION_QUEST_OBJECTIVES_UPDATE"]            = "Показывает уведомление при обновлении целей задания."
L["OPTIONS_PRESENCE_OBJECTIVE"]                                       = "Только цель"
L["OPTIONS_PRESENCE_QUEST_PROGRESS_HIDE_TITLE"]                       = "Показывать только строку цели на уведомлениях прогресса, скрывая заголовок «Обновление задания»."
L["OPTIONS_PRESENCE_SCENARIO_START"]                                  = "Показывать начало сценария"
L["OPTIONS_PRESENCE_NOTIFICATION_ENTERING_A_SCENARIO_DELVE"]          = "Показывает уведомление при входе в сценарий или Глубины."
L["OPTIONS_PRESENCE_SCENARIO_PROGRESS"]                               = "Показывать прогресс сценария"
L["OPTIONS_PRESENCE_NOTIFICATION_SCENARIO_DELVE_OBJECTIVES"]          = "Показывает уведомление при обновлении целей сценария или Глубин."
L["OPTIONS_PRESENCE_ANIMATION"]                                       = "Анимация"
L["OPTIONS_PRESENCE_ENABLE_ANIMATIONS"]                               = "Включить анимации"
L["OPTIONS_PRESENCE_ENABLE_ENTRANCE_EXIT_ANIMATIONS_PRESENCE"]        = "Включает анимации появления и исчезновения уведомлений."
L["OPTIONS_PRESENCE_ENTRANCE_DURATION"]                               = "Длительность появления"
L["OPTIONS_PRESENCE_DURATION_OF_ENTRANCE_ANIMATION_SECONDS"]          = "Длительность анимации появления в секундах (0.2–1.5)."
L["OPTIONS_PRESENCE_EXIT_DURATION"]                                   = "Длительность исчезновения"
L["OPTIONS_PRESENCE_DURATION_OF_EXIT_ANIMATION_SECONDS"]              = "Длительность анимации исчезновения в секундах (0.2–1.5)."
L["OPTIONS_PRESENCE_HOLD_DURATION_SCALE"]                             = "Множитель времени показа"
L["OPTIONS_PRESENCE_MULTIPLIER_LONG_NOTIFICATION_STAYS_S"]            = "Множитель времени показа уведомлений (0.5–2)."
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
L["DASH_TYPOGRAPHY"]                                                  = "Типографика"
L["OPTIONS_PRESENCE_MAIN_TITLE_FONT"]                                 = "Шрифт основного заголовка"
L["OPTIONS_PRESENCE_FONT_FAMILY_MAIN_TITLE"]                          = "Семейство шрифтов для основного заголовка."
L["OPTIONS_PRESENCE_SUBTITLE_FONT"]                                   = "Шрифт подзаголовка"
L["OPTIONS_PRESENCE_FONT_FAMILY_SUBTITLE"]                            = "Семейство шрифтов для подзаголовка."
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
L["OPTIONS_FOCUS_NONE"]                                               = "Нет"
L["OPTIONS_FOCUS_THICK_OUTLINE"]                                      = "Толстый контур"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["OPTIONS_FOCUS_BAR_LEFT_EDGE"]                                      = "Полоса (слева)"
L["OPTIONS_FOCUS_BAR_RIGHT_EDGE"]                                     = "Полоса (справа)"
L["OPTIONS_FOCUS_BAR_TOP_EDGE"]                                       = "Полоса (сверху)"
L["OPTIONS_FOCUS_BAR_BOTTOM_EDGE"]                                    = "Полоса (снизу)"
L["OPTIONS_FOCUS_OUTLINE_ONLY_STYLE"]                                 = "Только контур"
L["OPTIONS_FOCUS_SOFT_GLOW"]                                          = "Мягкое свечение"
L["OPTIONS_FOCUS_DUAL_EDGE_BARS"]                                     = "Двойные полосы"
L["OPTIONS_FOCUS_PILL_LEFT_ACCENT"]                                   = "Акцент слева"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["OPTIONS_FOCUS_TOP"]                                                = "Сверху"
L["OPTIONS_FOCUS_BOTTOM"]                                             = "Снизу"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["OPTIONS_VISTA_LOCATION_POSITION"]                                  = "Позиция названия зоны"
L["OPTIONS_VISTA_PLACE_ZONE_NAME_ABOVE_BELOW_MINIMAP"]                = "Размещение названия зоны над или под миникартой."
L["OPTIONS_VISTA_COORDINATES_POSITION"]                               = "Позиция координат"
L["OPTIONS_VISTA_PLACE_COORDINATES_ABOVE_BELOW_MINIMAP"]              = "Размещение координат над или под миникартой."
L["OPTIONS_VISTA_CLOCK_POSITION"]                                     = "Позиция часов"
L["OPTIONS_VISTA_PLACE_CLOCK_ABOVE_BELOW_MINIMAP"]                    = "Размещение часов над или под миникартой."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["OPTIONS_FOCUS_LOWER_CASE"]                                         = "Строчные"
L["OPTIONS_FOCUS_UPPER_CASE"]                                         = "Заглавные"
L["OPTIONS_FOCUS_PROPER"]                                             = "С заглавной буквы"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["OPTIONS_FOCUS_TRACKED_LOG"]                                        = "Отслеживаемые / в журнале"
L["OPTIONS_FOCUS_LOG_MAX_SLOTS"]                                      = "В журнале / макс. слотов"

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["OPTIONS_FOCUS_ALPHABETICAL"]                                       = "По алфавиту"
L["OPTIONS_FOCUS_QUEST_TYPE"]                                         = "По типу задания"
L["OPTIONS_FOCUS_QUEST_LEVEL"]                                        = "По уровню задания"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["OPTIONS_FOCUS_CUSTOM"]                                             = "Пользовательский"
L["OPTIONS_FOCUS_ORDER"]                                              = "Порядок"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["UI_DUNGEON"]                                                       = "ПОДЗЕМЕЛЬЕ"
L["UI_RAID"]                                                          = "РЕЙД"
L["UI_DELVES"]                                                        = "ПОДЗЕМЕЛЬЯ"
L["UI_SCENARIO_EVENTS"]                                               = "СОБЫТИЯ СЦЕНАРИЯ"
-- L["UI_STAGE"]                                                      = "Stage"  -- NEEDS TRANSLATION
-- L["UI_STAGE_X_X"]                                                  = "Stage %d: %s"  -- NEEDS TRANSLATION
L["UI_AVAILABLE_IN_ZONE"]                                             = "ДОСТУПНО В ЗОНЕ"
L["UI_EVENTS_IN_ZONE"]                                                = "События в зоне"
L["UI_CURRENT_EVENT"]                                                 = "Текущее событие"
L["UI_CURRENT_QUEST"]                                                 = "ТЕКУЩИЙ КВЕСТ"
L["UI_CURRENT_ZONE"]                                                  = "ТЕКУЩАЯ ЗОНА"
L["UI_CAMPAIGN"]                                                      = "КАМПАНИЯ"
L["UI_IMPORTANT"]                                                     = "ВАЖНЫЕ"
L["UI_LEGENDARY"]                                                     = "ЛЕГЕНДАРНЫЕ"
L["UI_WORLD_QUESTS"]                                                  = "ЛОКАЛЬНЫЕ ЗАДАНИЯ"
L["UI_WEEKLY_QUESTS"]                                                 = "ЕЖЕНЕДЕЛЬНЫЕ"
L["UI_PREY"]                                                          = "Добыча"
L["UI_ABUNDANCE"]                                                     = "Изобилие"
L["UI_ABUNDANCE_BAG"]                                                 = "Сумка изобилия"
L["UI_ABUNDANCE_HELD"]                                                = "удержанное изобилие"
L["UI_DAILY_QUESTS"]                                                  = "ЕЖЕДНЕВНЫЕ"
L["UI_RARE_BOSSES"]                                                   = "РЕДКИЕ БОССЫ"
L["UI_ACHIEVEMENTS"]                                                  = "ДОСТИЖЕНИЯ"
L["UI_ENDEAVORS"]                                                     = "НАЧИНАНИЯ"
L["UI_DECOR"]                                                         = "УКРАШЕНИЯ"
L["UI_QUESTS"]                                                        = "ЗАДАНИЯ"
L["UI_READY_TO_TURN_IN"]                                              = "ГОТОВО К СДАЧЕ"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["PRESENCE_OBJECTIVES"]                                              = "ЦЕЛИ"
L["PRESENCE_OPTIONS"]                                                 = "Настройки"
L["PRESENCE_OPEN_HORIZON_SUITE"]                                      = "Открыть Horizon Suite"
L["PRESENCE_OPEN_FULL_HORIZON_SUITE_OPTIONS"]                         = "Открывает полную панель настроек Horizon Suite для настройки Focus, Presence, Vista и других модулей."
L["PRESENCE_SHOW_MINIMAP_ICON"]                                       = "Показать значок на миникарте"
L["PRESENCE_A_CLICKABLE_ICON_MINIMAP_OPENS"]                          = "Показывает кликабельный значок на миникарте, открывающий панель настроек."
-- L["PRESENCE_LOCK_MINIMAP_BUTTON_POSITION"]                         = "Lock minimap button position"  -- NEEDS TRANSLATION
-- L["PRESENCE_PREVENT_DRAGGING_HORIZON_MINIMAP_BUTTON"]              = "Prevent dragging the Horizon minimap button."  -- NEEDS TRANSLATION
-- L["PRESENCE_RESET_MINIMAP_BUTTON_POSITION"]                        = "Reset minimap button position"  -- NEEDS TRANSLATION
-- L["PRESENCE_RESET_MINIMAP_BUTTON_DEFAULT_POSITION"]                = "Reset the minimap button to the default position (bottom-left)."  -- NEEDS TRANSLATION
-- L["PRESENCE_DRAG_TO_MOVE_WHEN_UNLOCKED"]                           = "Drag to move (when unlocked)."  -- NEEDS TRANSLATION
-- L["PRESENCE_LOCKED"]                                               = "Locked"  -- NEEDS TRANSLATION
L["PRESENCE_DISCOVERED"]                                              = "Обнаружено"
L["PRESENCE_REFRESH"]                                                 = "Обновить"
L["PRESENCE_BEST_EFFORT_UNACCEPTED_QUESTS_EXPO"]                      = "Поиск приблизительный. Некоторые непринятые задания не отображаются до взаимодействия с НИП или условий фазы."
L["PRESENCE_UNACCEPTED_QUESTS_X_MAP_X"]                               = "Непринятые задания - %s (карта %s) - %d совпадений"
L["PRESENCE_LEVEL_UP"]                                                = "ПОВЫШЕНИЕ УРОВНЯ"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_80"]                               = "Вы достигли 80 уровня"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_X"]                                = "Вы достигли %s уровня"
L["PRESENCE_ACHIEVEMENT_EARNED"]                                      = "ДОСТИЖЕНИЕ ПОЛУЧЕНО"
L["PRESENCE_EXPLORING_THE_MIDNIGHT_ISLES"]                            = "Исследование Полуночных островов"
L["PRESENCE_EXPLORING_KHAZ_ALGAR"]                                    = "Исследование Каз Алгара"
L["PRESENCE_QUEST_COMPLETE"]                                          = "ЗАДАНИЕ ВЫПОЛНЕНО"
L["PRESENCE_OBJECTIVE_SECURED"]                                       = "Цель достигнута"
L["PRESENCE_AIDING_THE_ACCORD"]                                       = "Помощь Согласию"
L["PRESENCE_WORLD_QUEST"]                                             = "ЛОКАЛЬНОЕ ЗАДАНИЕ"
L["PRESENCE_WORLD_QUEST_COMPLETE"]                                    = "ЛОКАЛЬНОЕ ЗАДАНИЕ ВЫПОЛНЕНО"
L["PRESENCE_AZERITE_MINING"]                                          = "Добыча азерита"
L["PRESENCE_WORLD_QUEST_ACCEPTED"]                                    = "ЛОКАЛЬНОЕ ЗАДАНИЕ ПРИНЯТО"
L["PRESENCE_QUEST_ACCEPTED"]                                          = "ЗАДАНИЕ ПРИНЯТО"
L["PRESENCE_THE_FATE_OF_THE_HORDE"]                                   = "Судьба Орды"
L["PRESENCE_NEW_QUEST"]                                               = "Новое задание"
L["PRESENCE_QUEST_UPDATE"]                                            = "ОБНОВЛЕНИЕ ЗАДАНИЯ"
L["PRESENCE_BOAR_PELTS_7_10"]                                         = "Шкуры кабана: 7/10"
L["PRESENCE_DRAGON_GLYPHS_3_5"]                                       = "Драконьи руны: 3/5"
L["PRESENCE_PRESENCE_TEST_COMMANDS"]                                  = "Тестовые команды Присутствия:"
-- L["PRESENCE_H_PRESENCE_DEBUGTYPES_DUMP_NOTIFICATION"]              = "  /h presence debugtypes - Dump notification toggles and Blizzard suppression state"  -- NEEDS TRANSLATION
-- L["PRESENCE_PRESENCE_PLAYING_DEMO_REEL_NOTIFICATION"]              = "Presence: Playing demo reel (all notification types)..."  -- NEEDS TRANSLATION
L["PRESENCE_H_PRESENCE_HELP_TEST_CURRENT"]                            = "  /h presence         - Справка + тест текущей зоны"
L["PRESENCE_H_PRESENCE_ZONE_TEST_ZONE"]                               = "  /h presence zone     - Тест смены зоны"
L["PRESENCE_H_PRESENCE_SUBZONE_TEST_SUBZONE"]                         = "  /h presence subzone  - Тест смены подзоны"
L["PRESENCE_H_PRESENCE_DISCOVER_TEST_ZONE"]                           = "  /h presence discover - Тест обнаружения зоны"
L["PRESENCE_H_PRESENCE_LEVEL_TEST_LEVEL"]                             = "  /h presence level    - Тест повышения уровня"
L["PRESENCE_H_PRESENCE_BOSS_TEST_BOSS"]                               = "  /h presence boss     - Тест эмоции босса"
L["PRESENCE_H_PRESENCE_ACH_TEST_ACHIEVEMENT"]                         = "  /h presence ach      - Тест достижения"
L["PRESENCE_H_PRESENCE_ACCEPT_TEST_QUEST"]                            = "  /h presence accept   - Тест принятия задания"
L["PRESENCE_H_PRESENCE_WQACCEPT_TEST_WORLD"]                          = "  /h presence wqaccept - Тест принятия локального задания"
L["PRESENCE_H_PRESENCE_SCENARIO_TEST_SCENARIO"]                       = "  /h presence scenario - Тест начала сценария"
L["PRESENCE_H_PRESENCE_QUEST_TEST_QUEST"]                             = "  /h presence quest    - Тест завершения задания"
L["PRESENCE_H_PRESENCE_WQ_TEST_WORLD"]                                = "  /h presence wq       - Тест локального задания"
L["PRESENCE_H_PRESENCE_UPDATE_TEST_QUEST"]                            = "  /h presence update   - Тест обновления задания"
L["PRESENCE_H_PRESENCE_ACHPROGRESS_TEST_ACHIEVEMENT"]                 = "  /h presence achprogress - Тест прогресса достижения"
L["PRESENCE_H_PRESENCE_DEMO_REEL_TYPES"]                              = "  /h presence all      - Демо (все типы)"
L["PRESENCE_H_PRESENCE_DEBUG_DUMP_STATE"]                             = "  /h presence debug    - Вывод состояния в чат"
L["PRESENCE_H_PRESENCE_DEBUGLIVE_TOGGLE_LIVE"]                        = "  /h presence debuglive - Вкл/выкл панель отладки (логирование событий)"

-- =====================================================================
-- OptionsData.lua Vista — General
-- L["OPTIONS_VISTA_POSITION_LAYOUT"]                                 = "Position & layout"  -- NEEDS TRANSLATION

-- =====================================================================
L["OPTIONS_VISTA_MINIMAP"]                                            = "Миникарта"
L["OPTIONS_VISTA_MINIMAP_SIZE"]                                       = "Размер миникарты"
L["OPTIONS_VISTA_WIDTH_HEIGHT_OF_MINIMAP_PIXELS"]                     = "Ширина и высота миникарты в пикселях (100–400)."
L["OPTIONS_VISTA_CIRCULAR_MINIMAP"]                                   = "Круглая миникарта"
-- L["OPTIONS_VISTA_CIRCULAR_SHAPE"]                                  = "Circular shape"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_A_CIRCULAR_MINIMAP_INSTEAD_OF_SQUARE"]               = "Использовать круглую миникарту вместо квадратной."
L["OPTIONS_VISTA_LOCK_MINIMAP_POSITION"]                              = "Заблокировать позицию миникарты"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MINIMAP"]                           = "Запретить перетаскивание миникарты."
L["OPTIONS_VISTA_RESET_MINIMAP_POSITION"]                             = "Сбросить позицию миникарты"
L["OPTIONS_VISTA_RESET_MINIMAP_DEFAULT_POSITION_TOP_RIGHT"]           = "Вернуть миникарту на стандартное место (правый верхний угол)."
L["OPTIONS_VISTA_AUTO_ZOOM"]                                          = "Авто-зум"
L["OPTIONS_VISTA_AUTO_ZOOM_DELAY"]                                    = "Задержка авто-отдаления"
L["OPTIONS_VISTA_SECONDS_AFTER_ZOOMING_BEFORE_AUTO_ZOOM"]             = "Секунд до авто-отдаления после зума. 0 — отключить."

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["OPTIONS_VISTA_ZONE_TEXT_HEADER"]                                   = "Текст зоны"
L["OPTIONS_VISTA_ZONE_FONT"]                                          = "Шрифт зоны"
L["OPTIONS_VISTA_FONT_ZONE_NAME_BELOW_MINIMAP"]                       = "Шрифт названия зоны под миникартой."
L["OPTIONS_VISTA_ZONE_FONT_SIZE"]                                     = "Размер шрифта зоны"
L["OPTIONS_VISTA_ZONE_TEXT_COLOR"]                                    = "Цвет текста зоны"
L["OPTIONS_VISTA_COLOR_OF_ZONE_NAME_TEXT"]                            = "Цвет текста названия зоны."
L["OPTIONS_VISTA_COORDINATES_TEXT"]                                   = "Текст координат"
L["OPTIONS_VISTA_COORDINATES_FONT"]                                   = "Шрифт координат"
L["OPTIONS_VISTA_FONT_COORDINATES_TEXT_BELOW_MINIMAP"]                = "Шрифт текста координат под миникартой."
L["OPTIONS_VISTA_COORDINATES_FONT_SIZE"]                              = "Размер шрифта координат"
L["OPTIONS_VISTA_COORDINATES_TEXT_COLOR"]                             = "Цвет текста координат"
L["OPTIONS_VISTA_COLOR_OF_COORDINATES_TEXT"]                          = "Цвет текста координат."
L["OPTIONS_VISTA_COORDINATE_PRECISION"]                               = "Точность координат"
L["OPTIONS_VISTA_NUMBER_OF_DECIMAL_PLACES_SHOWN_X"]                   = "Количество знаков после запятой для координат X и Y."
L["OPTIONS_VISTA_COORDS_DECIMALS_OFF"]                                = "Без дробей (напр. 52, 37)"
L["OPTIONS_VISTA_DECIMAL_E_G"]                                        = "1 знак (напр. 52.3, 37.1)"
L["OPTIONS_VISTA_DECIMALS_E_G"]                                       = "2 знака (напр. 52.34, 37.12)"
L["OPTIONS_VISTA_TEXT"]                                               = "Текст времени"
L["OPTIONS_VISTA_FONT"]                                               = "Шрифт времени"
L["OPTIONS_VISTA_FONT_TEXT_BELOW_MINIMAP"]                            = "Шрифт текста времени под миникартой."
L["OPTIONS_VISTA_FONT_SIZE"]                                          = "Размер шрифта времени"
L["OPTIONS_VISTA_TEXT_COLOR"]                                         = "Цвет текста времени"
L["OPTIONS_VISTA_COLOR_OF_TEXT"]                                      = "Цвет текста времени."
-- L["OPTIONS_VISTA_PERFORMANCE_TEXT"]                                = "Performance Text"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_PERFORMANCE_FONT"]                                = "Performance font"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_FONT_FPS_LATENCY_TEXT_BELOW_MINIMAP"]             = "Font for the FPS and latency text below the minimap."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_PERFORMANCE_FONT_SIZE"]                           = "Performance font size"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_PERFORMANCE_TEXT_COLOR"]                          = "Performance text color"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_COLOR_OF_FPS_LATENCY_TEXT"]                       = "Color of the FPS and latency text."  -- NEEDS TRANSLATION

-- =====================================================================
-- Vista — FPS/latency diagnostics tooltip (minimap performance text)
-- =====================================================================
-- L["UI_VISTA_PERF_DIAG_TITLE"]                                      = "Performance and connection"  -- NEEDS TRANSLATION
-- L["UI_VISTA_PERF_DIAG_FPS"]                                        = "Framerate"  -- NEEDS TRANSLATION
-- L["UI_VISTA_PERF_DIAG_LATENCY_HOME"]                               = "Latency (home)"  -- NEEDS TRANSLATION
-- L["UI_VISTA_PERF_DIAG_LATENCY_WORLD"]                              = "Latency (world)"  -- NEEDS TRANSLATION
-- L["UI_VISTA_PERF_DIAG_BANDWIDTH_DOWN"]                             = "Download"  -- NEEDS TRANSLATION
-- L["UI_VISTA_PERF_DIAG_BANDWIDTH_UP"]                               = "Upload"  -- NEEDS TRANSLATION
-- L["UI_VISTA_PERF_DIAG_CPU_BOUND"]                                  = "Client CPU-bound"  -- NEEDS TRANSLATION
-- L["UI_VISTA_PERF_DIAG_YES"]                                        = "Yes"  -- NEEDS TRANSLATION
-- L["UI_VISTA_PERF_DIAG_NO"]                                         = "No"  -- NEEDS TRANSLATION
-- L["UI_VISTA_PERF_DIAG_COMBAT_NOTE"]                                = "Addon CPU, memory, and profiler details are hidden during combat."  -- NEEDS TRANSLATION
-- L["UI_VISTA_PERF_DIAG_ADDON_CPU"]                                  = "Horizon Suite (CPU time)"  -- NEEDS TRANSLATION
-- L["UI_VISTA_PERF_DIAG_ADDON_MEM"]                                  = "Horizon Suite (memory)"  -- NEEDS TRANSLATION
-- L["UI_VISTA_PERF_DIAG_PROFILER_HEADER"]                            = "Add-on profiler (UI time)"  -- NEEDS TRANSLATION
-- L["UI_VISTA_PERF_DIAG_PROFILER_RECENT"]                            = "Horizon Suite (60-tick avg)"  -- NEEDS TRANSLATION
-- L["UI_VISTA_PERF_DIAG_PROFILER_LAST"]                              = "Horizon Suite (last tick)"  -- NEEDS TRANSLATION
-- L["UI_VISTA_PERF_DIAG_PROFILER_ALL_ADDONS"]                        = "All add-ons (60-tick avg)"  -- NEEDS TRANSLATION
-- L["UI_VISTA_PERF_DIAG_TOP_ADDONS"]                                 = "Top add-ons by recent avg"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_DIFFICULTY_TEXT"]                                    = "Текст сложности"
L["OPTIONS_VISTA_DIFFICULTY_TEXT_COLOR_FALLBACK"]                     = "Цвет текста сложности (по умолчанию)"
L["OPTIONS_VISTA_DEFAULT_COLOR_PER_DIFFICULTY_COLOR"]                 = "Цвет по умолчанию, если не задан цвет для конкретной сложности."
L["OPTIONS_VISTA_DIFFICULTY_FONT"]                                    = "Шрифт сложности"
L["OPTIONS_VISTA_FONT_INSTANCE_DIFFICULTY_TEXT"]                      = "Шрифт текста сложности подземелья."
L["OPTIONS_VISTA_DIFFICULTY_FONT_SIZE"]                               = "Размер шрифта сложности"
L["OPTIONS_VISTA_PER_DIFFICULTY_COLORS"]                              = "Цвета по сложности"
L["OPTIONS_VISTA_MYTHIC_COLOR"]                                       = "Цвет «Эпохальный»"
L["OPTIONS_VISTA_COLOR_MYTHIC_DIFFICULTY_TEXT"]                       = "Цвет текста эпохальной сложности."
L["OPTIONS_VISTA_HEROIC_COLOR"]                                       = "Цвет «Героический»"
L["OPTIONS_VISTA_COLOR_HEROIC_DIFFICULTY_TEXT"]                       = "Цвет текста героической сложности."
L["OPTIONS_VISTA_NORMAL_COLOR"]                                       = "Цвет «Обычный»"
L["OPTIONS_VISTA_COLOR_NORMAL_DIFFICULTY_TEXT"]                       = "Цвет текста обычной сложности."
L["OPTIONS_VISTA_LFR_COLOR"]                                          = "Цвет «Поиск рейда»"
L["OPTIONS_VISTA_COLOR_LOOKING_RAID_DIFFICULTY_TEXT"]                 = "Цвет текста сложности «Поиск рейда»."

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["OPTIONS_VISTA_TEXT_ELEMENTS"]                                      = "Текстовые элементы"
L["OPTIONS_VISTA_ZONE_TEXT"]                                          = "Показывать текст зоны"
L["OPTIONS_VISTA_ZONE_NAME_BELOW_MINIMAP"]                            = "Показывать название зоны под миникартой."
L["OPTIONS_VISTA_ZONE_TEXT_DISPLAY_MODE"]                             = "Режим отображения текста зоны"
L["OPTIONS_VISTA_WHAT_ZONE_SUBZONE"]                                  = "Что показывать: только зону, только подзону или обе."
L["OPTIONS_VISTA_ZONE"]                                               = "Только зона"
L["OPTIONS_VISTA_SUBZONE"]                                            = "Только подзона"
L["OPTIONS_VISTA_BOTH"]                                               = "Обе"
L["OPTIONS_VISTA_COORDINATES"]                                        = "Показывать координаты"
L["OPTIONS_VISTA_PLAYER_COORDINATES_BELOW_MINIMAP"]                   = "Показывать координаты игрока под миникартой."
L["OPTIONS_VISTA_TIME"]                                               = "Показывать время"
L["OPTIONS_VISTA_CURRENT_GAME_BELOW_MINIMAP"]                         = "Показывать текущее игровое время под миникартой."
-- L["OPTIONS_VISTA_HOUR_CLOCK"]                                      = "24-hour clock"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_DISPLAY_HOUR_FORMAT_E_G_INSTEAD"]                 = "Display time in 24-hour format (e.g. 14:30 instead of 2:30 PM)."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_LOCAL"]                                              = "Использовать местное время"
L["OPTIONS_VISTA_YOUR_LOCAL_SYSTEM"]                                  = "Вкл.: местное системное время. Выкл.: серверное время."
-- L["OPTIONS_VISTA_FPS_LATENCY"]                                     = "Show FPS and latency"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_FPS_LATENCY_MS_BELOW_MINIMAP"]                    = "Show FPS and latency (ms) below the minimap."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_MINIMAP_BUTTONS"]                                    = "Кнопки миникарты"
L["OPTIONS_VISTA_QUEUE_STATUS_MAIL_INDICATOR_ALWAYS_SHOWN"]           = "Статус очереди и индикатор почты всегда отображаются при необходимости."
L["OPTIONS_VISTA_TRACKING_BUTTON"]                                    = "Показывать кнопку слежения"
L["OPTIONS_VISTA_MINIMAP_TRACKING_BUTTON"]                            = "Показывать кнопку слежения на миникарте."
L["OPTIONS_VISTA_TRACKING_BUTTON_MOUSEOVER"]                          = "Кнопка слежения только при наведении"
L["OPTIONS_VISTA_HIDE_TRACKING_BUTTON_UNTIL_YOU_HOVER"]               = "Скрывать кнопку слежения до наведения на миникарту."
L["OPTIONS_VISTA_CALENDAR_BUTTON"]                                    = "Показывать кнопку календаря"
L["OPTIONS_VISTA_MINIMAP_CALENDAR_BUTTON"]                            = "Показывать кнопку календаря на миникарте."
L["OPTIONS_VISTA_CALENDAR_BUTTON_MOUSEOVER"]                          = "Кнопка календаря только при наведении"
L["OPTIONS_VISTA_HIDE_CALENDAR_BUTTON_UNTIL_YOU_HOVER"]               = "Скрывать кнопку календаря до наведения на миникарту."
L["OPTIONS_VISTA_ZOOM_BUTTONS"]                                       = "Показывать кнопки зума"
L["OPTIONS_VISTA_ZOOM_BUTTONS_MINIMAP"]                               = "Показывать кнопки + и - зума на миникарте."
L["OPTIONS_VISTA_ZOOM_BUTTONS_MOUSEOVER"]                             = "Кнопки зума только при наведении"
L["OPTIONS_VISTA_HIDE_ZOOM_BUTTONS_UNTIL_YOU_HOVER"]                  = "Скрывать кнопки зума до наведения на миникарту."

-- =====================================================================
-- OptionsData.lua Vista — Display (Border / Text Positions / Buttons)
-- =====================================================================
L["OPTIONS_VISTA_BORDER"]                                             = "Рамка"
L["OPTIONS_VISTA_A_BORDER_AROUND_MINIMAP"]                            = "Показывать рамку вокруг миникарты."
L["OPTIONS_VISTA_BORDER_COLOR"]                                       = "Цвет рамки"
L["OPTIONS_VISTA_COLOR_OPACITY_OF_MINIMAP_BORDER"]                    = "Цвет (и прозрачность) рамки миникарты."
L["OPTIONS_VISTA_BORDER_THICKNESS"]                                   = "Толщина рамки"
L["OPTIONS_VISTA_THICKNESS_OF_MINIMAP_BORDER_PIXELS"]                 = "Толщина рамки миникарты в пикселях (1–8)."
-- L["OPTIONS_VISTA_CLASS_COLOURS"]                                   = "Class colours"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_TINT_VISTA_BORDER_TEXT_COORDS_FPS"]               = "Tint Vista border and text (coords, time, FPS/MS labels) with your class colour. Numbers use the configured colour."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_TEXT_POSITIONS"]                                     = "Позиции текста"
L["OPTIONS_VISTA_DRAG_TEXT_ELEMENTS_REPOSITION_LOCK_PREVEN"]          = "Перетащите текстовые элементы для изменения позиции. Заблокируйте, чтобы избежать случайного перемещения."
L["OPTIONS_VISTA_LOCK_ZONE_TEXT_POSITION"]                            = "Зафиксировать позицию текста зоны"
L["OPTIONS_VISTA_ZONE_TEXT_CANNOT_DRAGGED"]                           = "Вкл.: текст зоны нельзя перетащить."
L["OPTIONS_VISTA_LOCK_COORDINATES_POSITION"]                          = "Зафиксировать позицию координат"
L["OPTIONS_VISTA_COORDINATES_TEXT_CANNOT_DRAGGED"]                    = "Вкл.: текст координат нельзя перетащить."
L["OPTIONS_VISTA_LOCK_POSITION"]                                      = "Зафиксировать позицию времени"
L["OPTIONS_VISTA_TEXT_CANNOT_DRAGGED"]                                = "Вкл.: текст времени нельзя перетащить."
-- L["OPTIONS_VISTA_PERFORMANCE_TEXT_POSITION"]                       = "Performance text position"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_PLACE_FPS_LATENCY_TEXT_ABOVE_BELOW"]              = "Place the FPS/latency text above or below the minimap."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_LOCK_PERFORMANCE_TEXT_POSITION"]                  = "Lock performance text position"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_FPS_LATENCY_TEXT_CANNOT_DRAGGED"]                 = "When on, the FPS/latency text cannot be dragged."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_LOCK_DIFFICULTY_TEXT_POSITION"]                      = "Зафиксировать позицию текста сложности"
L["OPTIONS_VISTA_DIFFICULTY_TEXT_CANNOT_DRAGGED"]                     = "Вкл.: текст сложности нельзя перетащить."
L["OPTIONS_VISTA_BUTTON_POSITIONS"]                                   = "Позиции кнопок"
L["OPTIONS_VISTA_DRAG_BUTTONS_REPOSITION_LOCK_PREVENT_MOVE"]          = "Перетащите кнопки для изменения позиции. Заблокируйте для фиксации."
L["OPTIONS_VISTA_LOCK_ZOOM_BUTTON"]                                   = "Зафиксировать кнопку «Приблизить»"
L["OPTIONS_VISTA_PREVENT_DRAGGING_ZOOM_BUTTON"]                       = "Запретить перетаскивание кнопки зума +."
L["OPTIONS_VISTA_LOCK_ZOOM_OUT_BUTTON"]                               = "Зафиксировать кнопку «Отдалить»"
L["OPTIONS_VISTA_LOCK_ZOOM_OUT_DRAG"]                                 = "Запретить перетаскивание кнопки зума -."
L["OPTIONS_VISTA_LOCK_TRACKING_BUTTON"]                               = "Зафиксировать кнопку слежения"
L["OPTIONS_VISTA_PREVENT_DRAGGING_TRACKING_BUTTON"]                   = "Запретить перетаскивание кнопки слежения."
L["OPTIONS_VISTA_LOCK_CALENDAR_BUTTON"]                               = "Зафиксировать кнопку календаря"
L["OPTIONS_VISTA_PREVENT_DRAGGING_CALENDAR_BUTTON"]                   = "Запретить перетаскивание кнопки календаря."
L["OPTIONS_VISTA_LOCK_QUEUE_BUTTON"]                                  = "Зафиксировать кнопку очереди"
L["OPTIONS_VISTA_PREVENT_DRAGGING_QUEUE_STATUS_BUTTON"]               = "Запретить перетаскивание кнопки статуса очереди."
L["OPTIONS_VISTA_LOCK_MAIL_INDICATOR"]                                = "Зафиксировать индикатор почты"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MAIL_ICON"]                         = "Запретить перетаскивание значка почты."
-- L["OPTIONS_VISTA_DISABLE_QUEUE_HANDLING"]                          = "Disable queue handling"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_DISABLE_QUEUE_BUTTON_HANDLING"]                      = "Отключить управление кнопкой очереди"
L["OPTIONS_VISTA_TURN_QUEUE_BUTTON_ANCHORING_ANOTHER_A"]              = "Отключить привязку кнопки очереди (если ею управляет другой аддон)."
L["OPTIONS_VISTA_BUTTON_SIZES"]                                       = "Размеры кнопок"
L["OPTIONS_VISTA_ADJUST_SIZE_OF_MINIMAP_OVERLAY_BUTTONS"]             = "Настроить размер кнопок поверх миникарты."
L["OPTIONS_VISTA_TRACKING_BUTTON_SIZE"]                               = "Размер кнопки слежения"
L["OPTIONS_VISTA_SIZE_OF_TRACKING_BUTTON_PIXELS"]                     = "Размер кнопки слежения (пиксели)."
L["OPTIONS_VISTA_CALENDAR_BUTTON_SIZE"]                               = "Размер кнопки календаря"
L["OPTIONS_VISTA_SIZE_OF_CALENDAR_BUTTON_PIXELS"]                     = "Размер кнопки календаря (пиксели)."
L["OPTIONS_VISTA_QUEUE_BUTTON_SIZE"]                                  = "Размер кнопки очереди"
L["OPTIONS_VISTA_SIZE_OF_QUEUE_STATUS_BUTTON_PIXELS"]                 = "Размер кнопки статуса очереди (пиксели)."
L["OPTIONS_VISTA_ZOOM_BUTTON_SIZE"]                                   = "Размер кнопок зума"
L["OPTIONS_VISTA_SIZE_OF_ZOOM_ZOOM_BUTTONS_PIXELS"]                   = "Размер кнопок зума + / - (пиксели)."
L["OPTIONS_VISTA_MAIL_INDICATOR_SIZE"]                                = "Размер индикатора почты"
L["OPTIONS_VISTA_SIZE_OF_MAIL_ICON_PIXELS"]                           = "Размер значка новой почты (пиксели)."
L["OPTIONS_VISTA_ADDON_BUTTON_SIZE"]                                  = "Размер кнопок аддонов"
L["OPTIONS_VISTA_SIZE_OF_COLLECTED_ADDON_MINIMAP_BUTTONS"]            = "Размер собранных кнопок аддонов на миникарте (пиксели)."

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
-- L["OPTIONS_VISTA_ADDON_BUTTONS"]                                   = "Addon Buttons"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_MINIMAP_ADDON_BUTTONS"]                              = "Кнопки аддонов на миникарте"
L["OPTIONS_VISTA_BUTTON_MANAGEMENT"]                                  = "Управление кнопками"
L["OPTIONS_VISTA_MANAGE_ADDON_MINIMAP_BUTTONS"]                       = "Управлять кнопками аддонов на миникарте"
L["OPTIONS_VISTA_VISTA_TAKES_CONTROL_OF_ADDON_MINIMAP"]               = "Вкл.: Vista берёт под контроль кнопки аддонов и группирует их выбранным способом."
L["OPTIONS_VISTA_BUTTON_MODE"]                                        = "Режим кнопок"
L["OPTIONS_VISTA_ADDON_BUTTONS_PRESENTED_HOVER_BAR_BELOW"]            = "Отображение кнопок аддонов: панель при наведении, панель по правому клику или плавающая кнопка."
-- L["OPTIONS_VISTA_ALWAYS_BAR"]                                      = "Always show bar"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_ALWAYS_MOUSEOVER_BAR_POSITIONING"]                = "Always show mouseover bar (for positioning)"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_KEEP_MOUSEOVER_BAR_VISIBLE_TIMES_YOU"]            = "Keep the mouseover bar visible at all times so you can reposition it. Disable when done."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_DISABLE_DONE"]                                    = "Disable when done."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_MOUSEOVER_BAR"]                                      = "Панель при наведении"
L["OPTIONS_VISTA_RIGHT_CLICK_PANEL"]                                  = "Панель по ПКМ"
L["OPTIONS_VISTA_FLOATING_DRAWER"]                                    = "Плавающая панель"
L["OPTIONS_VISTA_LOCK_DRAWER_BUTTON_POSITION"]                        = "Зафиксировать кнопку панели"
L["OPTIONS_VISTA_PREVENT_DRAGGING_FLOATING_DRAWER_BUTTON"]            = "Запретить перетаскивание кнопки плавающей панели."
L["OPTIONS_VISTA_LOCK_MOUSEOVER_BAR_POSITION"]                        = "Зафиксировать панель при наведении"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MOUSEOVER_BUTTON_BAR"]              = "Запретить перетаскивание панели кнопок при наведении."
L["OPTIONS_VISTA_LOCK_RIGHT_CLICK_PANEL_POSITION"]                    = "Зафиксировать панель ПКМ"
L["OPTIONS_VISTA_PREVENT_DRAGGING_RIGHT_CLICK_PANEL"]                 = "Запретить перетаскивание панели правого клика."
L["OPTIONS_VISTA_BUTTONS_PER_ROW_COLUMN"]                             = "Кнопок в строке/столбце"
L["OPTIONS_VISTA_CONTROLS_MANY_BUTTONS_APPEAR_BEFORE_WRAPPING"]       = "Количество кнопок до переноса строки. Для направлений влево/вправо — столбцы; вверх/вниз — строки."
L["OPTIONS_VISTA_EXPAND_DIRECTION"]                                   = "Направление расширения"
L["OPTIONS_VISTA_DIRECTION_BUTTONS_FILL_ANCHOR_POINT_LEFT"]           = "Направление заполнения от точки привязки. Влево/вправо = горизонтальные ряды. Вверх/вниз = вертикальные столбцы."
L["OPTIONS_VISTA_RIGHT"]                                              = "Вправо"
L["OPTIONS_VISTA_LEFT"]                                               = "Влево"
L["OPTIONS_VISTA_DOWN"]                                               = "Вниз"
L["OPTIONS_VISTA_UP"]                                                 = "Вверх"
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
L["OPTIONS_VISTA_PANEL_APPEARANCE"]                                   = "Вид панели"
L["OPTIONS_VISTA_COLORS_DRAWER_RIGHT_CLICK_BUTTON_PANELS"]            = "Цвета для панелей кнопок (плавающей и ПКМ)."
L["OPTIONS_VISTA_PANEL_BG_COLOR_LABEL"]                               = "Цвет фона панели"
L["OPTIONS_VISTA_BACKGROUND_COLOR_OF_ADDON_BUTTON_PANELS"]            = "Цвет фона панелей кнопок аддонов."
L["OPTIONS_VISTA_PANEL_BORDER_COLOR"]                                 = "Цвет рамки панели"
L["OPTIONS_VISTA_BORDER_COLOR_OF_ADDON_BUTTON_PANELS"]                = "Цвет рамки панелей кнопок аддонов."
L["OPTIONS_VISTA_MANAGED_BUTTONS"]                                    = "Управляемые кнопки"
L["OPTIONS_VISTA_BUTTON_COMPLETELY_IGNORED_A"]                        = "Выкл.: кнопка полностью игнорируется этим аддоном."
L["OPTIONS_VISTA_ADDON_BUTTONS_DETECTED"]                             = "(Кнопки аддонов пока не обнаружены)"
L["OPTIONS_VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE"]                      = "Видимые кнопки (отметьте для включения)"
L["OPTIONS_VISTA_ADDON_BUTTONS_DETECTED_OPEN_YOUR_MINIMAP"]           = "(Кнопки аддонов не обнаружены — сначала откройте миникарту)"

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
-- L["OPTIONS_CORE_BLIZZARD_DEFAULT_RONDOMEDIA_CLASS_ICON_DASHBO"]    = "Blizzard default or RondoMedia class icon on the Dashboard when Dashboard class colours are on. Independent of Insight tooltip class icons."  -- NEEDS TRANSLATION
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



















