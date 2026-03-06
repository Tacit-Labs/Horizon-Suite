if GetLocale() ~= "ruRU" then return end

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = setmetatable({}, { __index = function(t, k) return k end })
addon.L = L
addon.StandardFont = UNIT_NAME_FONT

-- =====================================================================
-- OptionsPanel.lua — Title
-- =====================================================================
L["HORIZON SUITE"]                                                  = "HORIZON SUITE"

-- =====================================================================
-- OptionsPanel.lua — Sidebar module group labels
-- =====================================================================
L["Focus"]                                                          = "Фокус"
L["Presence"]                                                       = "Присутствие"
L["Other"]                                                          = "Прочее"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["Quest types"]                                                    = "Типы заданий"
L["Element overrides"]                                              = "Цвета по элементам"
L["Per category"]                                                   = "Цвета по категориям"
L["Grouping Overrides"]                                             = "Пользовательские цвета"
L["Other colors"]                                                   = "Прочие цвета"

-- =====================================================================
-- OptionsPanel.lua — Color row labels (collapsible group sub-rows)
-- =====================================================================
L["Section"]                                                        = "Секция"
L["Title"]                                                          = "Заголовок"
L["Zone"]                                                           = "Зона"
L["Objective"]                                                      = "Цель"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["Ready to Turn In overrides base colours"]                        = "Отдельные цвета для раздела «Готово к сдаче»"
L["Ready to Turn In uses its colours for quests in that section."]  = "Задания, готовые к сдаче, используют свои цвета в этом разделе."
L["Current Zone overrides base colours"]                            = "Отдельные цвета для раздела «Текущая зона»"
L["Current Zone uses its colours for quests in that section."]      = "Задания текущей зоны используют свои цвета в этом разделе."
L["Current Quest overrides base colours"]                           = "Отдельные цвета для раздела «Текущий квест»"
L["Current Quest uses its colours for quests in that section."]     = "Задания текущего квеста используют свои цвета в этом разделе."
L["Use distinct color for completed objectives"]                     = "Отдельный цвет для выполненных целей"
L["When on, completed objectives (e.g. 1/1) use the color below; when off, they use the same color as incomplete objectives."] = "Вкл.: выполненные цели (напр. 1/1) используют цвет ниже. Выкл.: тот же цвет, что и у невыполненных."
L["Completed objective"]                                           = "Выполненная цель"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["Reset"]                                                          = "Сбросить"
L["Reset quest types"]                                              = "Сбросить типы заданий"
L["Reset overrides"]                                                = "Сбросить пользовательские цвета"
L["Reset all to defaults"]                                           = "Сбросить все на значения по умолчанию"
L["Reset to defaults"]                                              = "Сбросить на значения по умолчанию"
L["Reset to default"]                                               = "Сбросить на значение по умолчанию"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["Search settings..."]                                             = "Поиск настроек..."
L["Search fonts..."]                                                 = "Поиск шрифта..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["Drag to resize"]                                                 = "Перетащите для изменения размера"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
L["Modules"]                                            = "Модули"
L["Layout"]                                             = "Расположение"
L["Visibility"]                                         = "Видимость"
L["Display"]                                            = "Отображение"
L["Features"]                                           = "Функции"
L["Typography"]                                         = "Типографика"
L["Appearance"]                                         = "Внешний вид"
L["Colors"]                                             = "Цвета"
L["Organization"]                                       = "Организация"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["Panel behaviour"]                                    = "Поведение панели"
L["Dimensions"]                                         = "Размеры"
L["Instance"]                                           = "Подземелье"
L["Combat"]                                             = "Бой"
L["Filtering"]                                          = "Фильтры"
L["Header"]                                             = "Заголовок"
L["List"]                                               = "Список"
L["Spacing"]                                            = "Интервалы"
L["Rare bosses"]                                        = "Редкие боссы"
L["World quests"]                                       = "Локальные задания"
L["Floating quest item"]                                = "Плавающая кнопка предмета"
L["Mythic+"]                                            = "Эпохальный+"
L["Achievements"]                                       = "Достижения"
L["Endeavors"]                                          = "Начинания"
L["Decor"]                                              = "Украшения"
L["Scenario & Delve"]                                   = "Сценарий и Подземелье"
L["Font"]                                               = "Шрифт"
L["Text case"]                                          = "Регистр"
L["Shadow"]                                             = "Тень"
L["Panel"]                                              = "Панель"
L["Highlight"]                                          = "Выделение"
L["Color matrix"]                                       = "Цветовая матрица"
L["Focus order"]                                        = "Порядок фокуса"
L["Sort"]                                               = "Сортировка"
L["Behaviour"]                                          = "Поведение"
L["Content Types"]                                      = "Типы контента"
L["Delves"]                                             = "Подземелья"
L["Delves & Dungeons"]                                  = "Бездны и Подземелья"
L["Delve Complete"]                                     = "Подземелье завершено"
L["Interactions"]                                       = "Взаимодействия"
L["Tracking"]                                           = "Отслеживание"
L["Scenario Bar"]                                       = "Панель сценария"

-- =====================================================================
-- OptionsData.lua Modules
-- =====================================================================
L["Enable Focus module"]                                = "Включить модуль Фокус"
L["Show the objective tracker for quests, world quests, rares, achievements, and scenarios."] = "Отображает трекер целей для заданий, локальных заданий, редких боссов, достижений и сценариев."
L["Enable Presence module"]                             = "Включить модуль Присутствие"
L["Cinematic zone text and notifications (zone changes, level up, boss emotes, achievements, quest updates)."] = "Кинематографический текст зоны и уведомления (смена зоны, повышение уровня, эмоции боссов, достижения, обновления заданий)."
L["Enable Yield module"]                                = "Включить модуль Yield"
L["Cinematic loot notifications (items, money, currency, reputation)."] = "Кинематографические уведомления о добыче (предметы, золото, валюта, репутация)."
L["Enable Vista module"]                                = "Включить модуль Vista"
L["Cinematic square minimap with zone text, coordinates, and button collector."] = "Кинематографическая квадратная миникарта с текстом зоны, координатами и коллектором кнопок."
L["Beta"]                                               = "Бета"
L["Scaling"]                                            = "Масштабирование"
L["Global UI scale"]                                    = "Глобальный масштаб интерфейса"
L["Scale all sizes, spacings, and fonts by this factor (50–200%). Does not change your configured values."] = "Масштабирует все размеры, интервалы и шрифты (50–200%). Не изменяет ваши настройки."
L["Per-module scaling"]                                 = "Масштаб по модулям"
L["Override the global scale with individual sliders for each module."] = "Заменяет глобальный масштаб отдельными ползунками для каждого модуля."
L["Focus scale"]                                        = "Масштаб Фокуса"
L["Scale for the Focus objective tracker (50–200%)."]   = "Масштаб трекера целей Фокуса (50–200%)."
L["Presence scale"]                                     = "Масштаб Присутствия"
L["Scale for the Presence cinematic text (50–200%)."]   = "Масштаб кинематографического текста Присутствия (50–200%)."
L["Vista scale"]                                        = "Масштаб Vista"
L["Scale for the Vista minimap module (50–200%)."]      = "Масштаб модуля миникарты Vista (50–200%)."
L["Insight scale"]                                      = "Масштаб Insight"
L["Scale for the Insight tooltip module (50–200%)."]    = "Масштаб модуля подсказок Insight (50–200%)."
L["Yield scale"]                                        = "Масштаб Yield"
L["Scale for the Yield loot toast module (50–200%)."]   = "Масштаб модуля уведомлений о добыче Yield (50–200%)."
L["Enable Horizon Insight module"]                      = "Включить модуль Horizon Insight"
L["Cinematic tooltips with class colors, spec display, and faction icons."] = "Кинематографические подсказки с цветами классов, специализацией и иконками фракций."
L["Horizon Insight"]                                    = "Horizon Insight"
L["Insight"]                                            = "Insight"
L["Tooltip anchor mode"]                                = "Режим привязки подсказок"
L["Where tooltips appear: follow cursor or fixed position."] = "Где отображаются подсказки: следовать за курсором или фиксированная позиция."
L["Cursor"]                                             = "Курсор"
L["Fixed"]                                              = "Фиксировано"
L["Show anchor to move"]                                = "Показать якорь для перемещения"
L["Show draggable frame to set fixed tooltip position. Drag, then right-click to confirm."] = "Показывает перетаскиваемый фрейм для фиксированной позиции. Перетащите и нажмите ПКМ для подтверждения."
L["Reset tooltip position"]                             = "Сбросить позицию подсказок"
L["Reset fixed position to default."]                   = "Сбросить фиксированную позицию по умолчанию."
L["Yield"]                                              = "Yield"
L["General"]                                            = "Общие"
L["Position"]                                           = "Позиция"
L["Reset position"]                                     = "Сбросить позицию"
L["Reset loot toast position to default."]              = "Сбросить позицию уведомлений о добыче."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["Lock position"]                                      = "Заблокировать позицию"
L["Prevent dragging the tracker."]                      = "Запрещает перетаскивание трекера."
L["Grow upward"]                                        = "Рост вверх"
L["Grow-up header"]                                     = "Заголовок при росте"
L["When growing upward: keep header at bottom, or at top until collapsed."] = "При росте вверх: заголовок внизу или вверху до свёртывания."
L["Header at bottom"]                                   = "Заголовок внизу"
L["Header slides on collapse"]                         = "Заголовок сдвигается при свёртывании"
L["Anchor at bottom so the list grows upward."]         = "Привязка снизу, список растёт вверх."
L["Start collapsed"]                                    = "Свёрнуто по умолчанию"
L["Start with only the header shown until you expand."] = "Показывать только заголовок до раскрытия."
L["Panel width"]                                        = "Ширина панели"
L["Tracker width in pixels."]                           = "Ширина трекера в пикселях."
L["Max content height"]                                 = "Макс. высота контента"
L["Max height of the scrollable list (pixels)."]        = "Максимальная высота прокручиваемого списка (пиксели)."

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["Always show M+ block"]                                           = "Всегда показывать блок Эпохального+"
L["Show the M+ block whenever an active keystone is running"]       = "Показывать блок Эпохального+ при активном ключе."
L["Show in dungeon"]                                    = "Показывать в подземелье"
L["Show tracker in party dungeons."]                    = "Показывать трекер в групповых подземельях."
L["Show in raid"]                                       = "Показывать в рейде"
L["Show tracker in raids."]                            = "Показывать трекер в рейдах."
L["Show in battleground"]                               = "Показывать на поле боя"
L["Show tracker in battlegrounds."]                     = "Показывать трекер на полях боя."
L["Show in arena"]                                      = "Показывать на арене"
L["Show tracker in arenas."]                            = "Показывать трекер на аренах."
L["Hide in combat"]                                     = "Скрывать в бою"
L["Hide tracker and floating quest item in combat."]    = "Скрывает трекер и плавающую кнопку предмета в бою."
L["Combat visibility"]                                  = "Видимость в бою"
L["How the tracker behaves in combat: show, fade to reduced opacity, or hide."] = "Поведение трекера в бою: показывать, затемнять или скрывать."
L["Show"]                                               = "Показывать"
L["Fade"]                                               = "Затемнять"
L["Hide"]                                               = "Скрывать"
L["Combat fade opacity"]                                = "Прозрачность в бою (затемнение)"
L["How visible the tracker is when faded in combat (0 = invisible). Only applies when Combat visibility is Fade."] = "Видимость трекера при затемнении в бою (0 = невидим). Только при режиме «Затемнять»."
L["Mouseover"]                                          = "Наведение"
L["Show only on mouseover"]                             = "Показывать только при наведении"
L["Fade tracker when not hovering; move mouse over it to show."] = "Затемняет трекер без наведения; наведите курсор для отображения."
L["Faded opacity"]                                      = "Прозрачность при затемнении"
L["How visible the tracker is when faded (0 = invisible)."] = "Видимость трекера при затемнении (0 = невидим)."
L["Only show quests in current zone"]                   = "Только задания текущей зоны"
L["Hide quests outside your current zone."]             = "Скрывает задания вне текущей зоны."

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["Show quest count"]                                   = "Показывать количество заданий"
L["Show quest count in header."]                        = "Показывает количество заданий в заголовке."
L["Header count format"]                                = "Формат счётчика заданий"
L["Tracked/in-log or in-log/max-slots. Tracked excludes world/live-in-zone quests."] = "Отслеживаемые/в журнале или в журнале/макс. слотов. Отслеживаемые не включают локальные задания."
L["Show header divider"]                                = "Показывать разделитель заголовка"
L["Show the line below the header."]                    = "Показывает линию под заголовком."
L["Header divider color"]                              = "Цвет разделителя заголовка"
L["Color of the line below the header."]               = "Цвет линии под заголовком."
L["Super-minimal mode"]                                 = "Супер-минимальный режим"
L["Hide header for a pure text list."]                  = "Скрывает заголовок для чистого текстового списка."
L["Show options button"]                               = "Показывать кнопку настроек"
L["Show the Options button in the tracker header."]     = "Показывает кнопку настроек в заголовке трекера."
L["Header color"]                                       = "Цвет заголовка"
L["Color of the OBJECTIVES header text."]               = "Цвет текста заголовка ЦЕЛИ."
L["Header height"]                                      = "Высота заголовка"
L["Height of the header bar in pixels (18–48)."]        = "Высота полосы заголовка в пикселях (18–48)."

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["Show section headers"]                               = "Показывать заголовки секций"
L["Show category labels above each group."]             = "Показывает названия категорий над каждой группой."
L["Show category headers when collapsed"]               = "Заголовки категорий при свёрнутом виде"
L["Keep section headers visible when collapsed; click to expand a category."] = "Сохраняет заголовки видимыми при свёрнутом виде; клик для раскрытия."
L["Show Nearby (Current Zone) group"]                   = "Показывать группу «Текущая зона»"
L["Show in-zone quests in a dedicated Current Zone section. When off, they appear in their normal category."] = "Показывает задания зоны в отдельной секции. Выкл.: в обычной категории."
L["Show zone labels"]                                   = "Показывать названия зон"
L["Show zone name under each quest title."]             = "Показывает название зоны под каждым заданием."
L["Active quest highlight"]                             = "Выделение активного задания"
L["How the focused quest is highlighted."]              = "Способ выделения отслеживаемого задания."
L["Show quest item buttons"]                            = "Показывать кнопки предметов заданий"
L["Show usable quest item button next to each quest."]  = "Показывает кнопку используемого предмета рядом с каждым заданием."
L["Show objective numbers"]                             = "Показывать номера целей"
L["Prefix objectives with 1., 2., 3."]                  = "Добавляет 1., 2., 3. перед целями."
L["Show completed count"]                               = "Показывать счётчик выполненных"
L["Show X/Y progress in quest title."]                  = "Показывает прогресс X/Y в названии задания."
L["Show objective progress bar"]                        = "Показывать полосу прогресса целей"
L["Show a progress bar under objectives that have numeric progress (e.g. 3/250). Only applies to entries with a single arithmetic objective where the required amount is greater than 1."] = "Показывает полосу под целями с числовым прогрессом (напр. 3/250). Только для одной арифметической цели с требуемым количеством > 1."
L["Use category color for progress bar"]                = "Использовать цвет категории для полосы"
L["When on, the progress bar matches the quest/achievement category color. When off, uses the custom fill color below."] = "Вкл.: полоса использует цвет категории. Выкл.: пользовательский цвет ниже."
L["Progress bar types"]                                 = "Типы полосы прогресса"
L["Show progress bar for X/Y objectives, percent-only objectives, or both."] = "Показывать полосу для целей X/Y, только процентов или обоих."
L["X/Y: objectives like 3/10. Percent: objectives like 45%."] = "X/Y: цели как 3/10. Процент: цели как 45%."
L["X/Y only"]                                           = "Только X/Y"
L["Percent only"]                                       = "Только процент"
L["Use tick for completed objectives"]                  = "Галочка для выполненных целей"
L["When on, completed objectives show a checkmark (✓) instead of green color."] = "Вкл.: выполненные цели показывают галочку (✓) вместо зелёного цвета."
L["Show entry numbers"]                                 = "Показывать нумерацию заданий"
L["Prefix quest titles with 1., 2., 3. within each category."] = "Добавляет 1., 2., 3. перед заданиями в каждой категории."
L["Completed objectives"]                               = "Выполненные цели"
L["For multi-objective quests, how to display objectives you've completed (e.g. 1/1)."] = "Как отображать выполненные цели в заданиях с несколькими целями (напр. 1/1)."
L["Show all"]                                           = "Показывать все"
L["Fade completed"]                                     = "Затемнять выполненные"
L["Hide completed"]                                     = "Скрывать выполненные"
L["Show icon for in-zone auto-tracking"]                = "Показывать иконку автоотслеживания в зоне"
L["Display an icon next to auto-tracked world quests and weeklies/dailies that are not yet in your quest log (in-zone only)."] = "Показывает иконку у автоотслеживаемых локальных и еженедельных/ежедневных заданиях, ещё не в журнале (только в зоне)."
L["Auto-track icon"]                                    = "Иконка автоотслеживания"
L["Choose which icon to display next to auto-tracked in-zone entries."] = "Выберите иконку для автоотслеживаемых заданий в зоне."
L["Append ** to world quests and weeklies/dailies that are not yet in your quest log (in-zone only)."] = "Добавляет ** к локальным и еженедельным/ежедневным заданиям, ещё не в журнале (только в зоне)." -- deprecated, kept for compat

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["Compact mode"]                                       = "Компактный режим"
L["Preset: sets entry and objective spacing to 4 and 1 px."] = "Пресет: интервалы заданий и целей 4 и 1 px."
L["Spacing between quest entries (px)"]                 = "Интервал между заданиями (px)"
L["Vertical gap between quest entries."]                = "Вертикальный интервал между заданиями."
L["Spacing before category header (px)"]                = "Интервал перед заголовком (px)"
L["Gap between last entry of a group and the next category label."] = "Интервал между последним заданием группы и следующей категорией."
L["Spacing after category header (px)"]                 = "Интервал после заголовка (px)"
L["Gap between category label and first quest entry below it."] = "Интервал между заголовком и первым заданием ниже."
L["Spacing between objectives (px)"]                    = "Интервал между целями (px)"
L["Vertical gap between objective lines within a quest."] = "Вертикальный интервал между целями в задании."
L["Spacing below header (px)"]                          = "Интервал под заголовком (px)"
L["Vertical gap between the objectives bar and the quest list."] = "Вертикальный интервал между полосой целей и списком заданий."
L["Reset spacing"]                                      = "Сбросить интервалы"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["Show quest level"]                                   = "Показывать уровень задания"
L["Show quest level next to title."]                    = "Показывает уровень задания рядом с названием."
L["Dim non-focused quests"]                             = "Затемнять неактивные задания"
L["Slightly dim title, zone, objectives, and section headers that are not focused."] = "Слегка затемняет неактивные названия, зоны, цели и заголовки."

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["Show rare bosses"]                                   = "Показывать редких боссов"
L["Show rare boss vignettes in the list."]              = "Показывает редких боссов в списке."
L["Rare added sound"]                                   = "Звук при добавлении редкого"
L["Play a sound when a rare is added."]                 = "Воспроизводит звук при добавлении редкого."
L["Rare added sound choice"]                            = "Выбор звука редкого"
L["Choose which sound to play when a rare boss appears. Requires LibSharedMedia sounds to be installed for extra options."] = "Выберите звук при появлении редкого босса. Для дополнительных вариантов нужны звуки LibSharedMedia."

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["Show in-zone world quests"]                          = "Показывать локальные задания зоны"
L["Auto-add world quests in your current zone. When off, only quests you've tracked or world quests you're in close proximity to appear (Blizzard default)."] = "Автоматически добавляет локальные задания текущей зоны. Выкл.: только отслеживаемые или рядом (по умолчанию Blizzard)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["Show floating quest item"]                           = "Показывать плавающую кнопку предмета"
L["Show quick-use button for the focused quest's usable item."] = "Показывает кнопку быстрого использования предмета отслеживаемого задания."
L["Lock floating quest item position"]                  = "Заблокировать позицию кнопки предмета"
L["Prevent dragging the floating quest item button."]   = "Запрещает перетаскивание кнопки предмета."
L["Floating quest item source"]                         = "Источник предмета"
L["Which quest's item to show: super-tracked first, or current zone first."] = "Чей предмет показывать: сначала отслеживаемое или текущая зона."
L["Super-tracked, then first"]                          = "Сначала отслеживаемое"
L["Current zone first"]                                 = "Сначала текущая зона"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["Show Mythic+ block"]                                 = "Показывать блок Эпохального+"
L["Show timer, completion %, and affixes in Mythic+ dungeons."] = "Показывает таймер, % выполнения и модификаторы в Эпохальных+ подземельях."
L["M+ block position"]                                  = "Позиция блока Эпохального+"
L["Position of the Mythic+ block relative to the quest list."] = "Позиция блока Эпохального+ относительно списка заданий."
L["Show affix icons"]                                    = "Показывать иконки модификаторов"
L["Show affix icons next to modifier names in the M+ block."] = "Показывает иконки модификаторов в блоке Эпохального+."
L["Show affix descriptions in tooltip"]                  = "Описания модификаторов в подсказке"
L["Show affix descriptions when hovering over the M+ block."] = "Показывает описания модификаторов при наведении на блок."
L["M+ completed boss display"]                         = "Отображение побеждённых боссов"
L["How to show defeated bosses: checkmark icon or green color."] = "Как показывать побеждённых боссов: иконка галочки или зелёный цвет."
L["Checkmark"]                                          = "Галочка"
L["Green color"]                                        = "Зелёный цвет"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["Show achievements"]                                  = "Показывать достижения"
L["Show tracked achievements in the list."]             = "Показывает отслеживаемые достижения в списке."
L["Show completed achievements"]                        = "Показывать выполненные достижения"
L["Include completed achievements in the tracker. When off, only in-progress tracked achievements are shown."] = "Включает выполненные достижения. Выкл.: только в процессе."
L["Show achievement icons"]                             = "Показывать иконки достижений"
L["Show each achievement's icon next to the title. Requires 'Show quest type icons' in Display."] = "Показывает иконку каждого достижения. Требуется «Показывать иконки типов заданий»."
L["Only show missing requirements"]                     = "Показывать только недостающие критерии"
L["Show only criteria you haven't completed for each tracked achievement. When off, all criteria are shown."] = "Показывает только невыполненные критерии. Выкл.: все критерии."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["Show endeavors"]                                     = "Показывать начинания"
L["Show tracked Endeavors (Player Housing) in the list."] = "Показывает отслеживаемые начинания (жилище) в списке."
L["Show completed endeavors"]                           = "Показывать выполненные начинания"
L["Include completed Endeavors in the tracker. When off, only in-progress tracked Endeavors are shown."] = "Включает выполненные начинания. Выкл.: только в процессе."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["Show decor"]                                         = "Показывать украшения"
L["Show tracked housing decor in the list."]            = "Показывает отслеживаемые украшения жилища в списке."
L["Show decor icons"]                                   = "Показывать иконки украшений"
L["Show each decor item's icon next to the title. Requires 'Show quest type icons' in Display."] = "Показывает иконку каждого украшения. Требуется «Показывать иконки типов заданий»."

-- =====================================================================
-- OptionsData.lua Features — Adventure Guide
-- =====================================================================
L["Adventure Guide"]                                    = "Путеводитель"
L["Show Traveler's Log"]                                = "Показывать журнал путешественника"
L["Show tracked Traveler's Log objectives (Shift+click in Adventure Guide) in the list."] = "Показывает отслеживаемые цели журнала (Shift+клик в Путеводителе) в списке."
L["Auto-remove completed activities"]                   = "Автоудаление выполненных активностей"
L["Automatically stop tracking Traveler's Log activities once they have been completed."] = "Автоматически прекращает отслеживание выполненных активностей журнала."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["Show scenario events"]                               = "Показывать события сценария"
L["Show active scenario and Delve activities. Delves appear in DELVES; other scenarios in SCENARIO EVENTS."] = "Показывает активные сценарии и подземелья. Подземелья в ПОДЗЕМЕЛЬЯ; прочие в СОБЫТИЯ СЦЕНАРИЯ."
L["Track Delve, Dungeon, and scenario activities."]     = "Отслеживание активности в подземельях, бездах и сценариях."
L["Delves appear in Delves section; dungeons in Dungeon; other scenarios in Scenario Events."] = "Бездны в секции БЕЗДНЫ; подземелья в ПОДЗЕМЕЛЬЕ; прочие в СОБЫТИЯ СЦЕНАРИЯ."
L["Hide other categories in Delve or Dungeon"]          = "Скрывать другие категории в подземелье"
L["In Delves or party dungeons, show only the Delve/Dungeon section."] = "В подземельях показывать только соответствующую секцию."
L["Use delve name as section header"]                    = "Использовать название подземелья как заголовок"
L["When in a Delve, show the delve name, tier, and affixes as the section header instead of a separate banner. Disable to show the Delve block above the list."] = "В подземелье: название, уровень и модификаторы в заголовке. Выкл.: блок над списком."
L["Show affix names in Delves"]                         = "Показывать названия модификаторов в подземельях"
L["Show season affix names on the first Delve entry. Requires Blizzard's objective tracker widgets to be populated; may not show when using a full tracker replacement."] = "Показывает сезонные модификаторы на первой записи. Требуются виджеты Blizzard."
L["Cinematic scenario bar"]                             = "Кинематографическая панель сценария"
L["Show timer and progress bar for scenario entries."]  = "Показывает таймер и полосу прогресса для сценариев."
L["Show timer"]                                         = "Показывать таймер"
L["Show countdown timer on timed quests, events, and scenarios. When off, timers are hidden for all entry types."] = "Показывать обратный отсчёт на квестах с таймером, событиях и сценариях. Выкл. — таймеры скрыты."
L["Timer display"]                                      = "Отображение таймера"
L["Color timer by remaining time"]                      = "Цвет таймера по оставшемуся времени"
L["Green when plenty of time left, yellow when running low, red when critical."] = "Зелёный — много времени, жёлтый — мало, красный — критично."
L["Where to show the countdown: bar below objectives or text beside the quest name."] = "Где показывать обратный отсчёт: панель под целями или текст рядом с названием задания."
L["Bar below"]                                          = "Панель внизу"
L["Inline beside title"]                                = "Текст рядом с названием"
L["Show countdown timer bars on timed quests, events, and scenarios. When off, timer bars are hidden for all entry types."] = "Показывает панели обратного отсчёта на квестах, событиях и сценариях с таймером. При выключении панели таймера скрыты для всех типов записей."

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["Font family."]                                       = "Семейство шрифта."
L["Title font"]                                         = "Шрифт заголовков"
L["Zone font"]                                          = "Шрифт зон"
L["Objective font"]                                     = "Шрифт целей"
L["Section font"]                                       = "Шрифт секций"
L["Use global font"]                                    = "Использовать глобальный шрифт"
L["Font family for quest titles."]                      = "Семейство шрифта для названий заданий."
L["Font family for zone labels."]                       = "Семейство шрифта для названий зон."
L["Font family for objective text."]                    = "Семейство шрифта для текста целей."
L["Font family for section headers."]                    = "Семейство шрифта для заголовков секций."
L["Header size"]                                        = "Размер заголовка"
L["Header font size."]                                  = "Размер шрифта заголовка."
L["Title size"]                                         = "Размер названия"
L["Quest title font size."]                             = "Размер шрифта названий заданий."
L["Objective size"]                                     = "Размер целей"
L["Objective text font size."]                          = "Размер шрифта текста целей."
L["Zone size"]                                          = "Размер зон"
L["Zone label font size."]                              = "Размер шрифта названий зон."
L["Section size"]                                       = "Размер секций"
L["Section header font size."]                          = "Размер шрифта заголовков секций."
L["Progress bar font"]                                  = "Шрифт полосы прогресса"
L["Font family for the progress bar label."]            = "Семейство шрифта для подписи полосы."
L["Progress bar text size"]                             = "Размер текста полосы прогресса"
L["Font size for the progress bar label. Also adjusts bar height. Affects quest objectives, scenario progress, and scenario timer bars."] = "Размер шрифта подписи полосы. Также регулирует высоту. Влияет на цели заданий, прогресс сценариев и таймеры."
L["Progress bar fill"]                                  = "Заливка полосы прогресса"
L["Progress bar text"]                                  = "Текст полосы прогресса"
L["Outline"]                                            = "Контур"
L["Font outline style."]                                = "Стиль контура шрифта."

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["Header text case"]                                   = "Регистр заголовка"
L["Display case for header."]                           = "Регистр отображения заголовка."
L["Section header case"]                                = "Регистр заголовков секций"
L["Display case for category labels."]                  = "Регистр отображения категорий."
L["Quest title case"]                                   = "Регистр названий заданий"
L["Display case for quest titles."]                     = "Регистр отображения названий заданий."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["Show text shadow"]                                   = "Показывать тень текста"
L["Enable drop shadow on text."]                        = "Включает тень текста."
L["Shadow X"]                                           = "Тень X"
L["Horizontal shadow offset."]                          = "Горизонтальное смещение тени."
L["Shadow Y"]                                           = "Тень Y"
L["Vertical shadow offset."]                            = "Вертикальное смещение тени."
L["Shadow alpha"]                                       = "Прозрачность тени"
L["Shadow opacity (0–1)."]                              = "Прозрачность тени (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["Mythic+ Typography"]                                  = "Типографика Эпохального+"
L["Dungeon name size"]                                   = "Размер названия подземелья"
L["Font size for dungeon name (8–32 px)."]              = "Размер шрифта названия подземелья (8–32 px)."
L["Dungeon name color"]                                  = "Цвет названия подземелья"
L["Text color for dungeon name."]                        = "Цвет текста названия подземелья."
L["Timer size"]                                         = "Размер таймера"
L["Font size for timer (8–32 px)."]                     = "Размер шрифта таймера (8–32 px)."
L["Timer color"]                                        = "Цвет таймера"
L["Text color for timer (in time)."]                    = "Цвет таймера (в пределах времени)."
L["Timer overtime color"]                               = "Цвет таймера (время вышло)"
L["Text color for timer when over the time limit."]      = "Цвет таймера при превышении времени."
L["Progress size"]                                      = "Размер прогресса"
L["Font size for enemy forces (8–32 px)."]               = "Размер шрифта сил противника (8–32 px)."
L["Progress color"]                                     = "Цвет прогресса"
L["Text color for enemy forces."]                        = "Цвет текста сил противника."
L["Bar fill color"]                                     = "Цвет заливки полосы"
L["Progress bar fill color (in progress)."]             = "Цвет заливки полосы (в процессе)."
L["Bar complete color"]                                 = "Цвет завершённой полосы"
L["Progress bar fill color when enemy forces are at 100%."] = "Цвет заливки при 100% сил противника."
L["Affix size"]                                         = "Размер модификаторов"
L["Font size for affixes (8–32 px)."]                   = "Размер шрифта модификаторов (8–32 px)."
L["Affix color"]                                        = "Цвет модификаторов"
L["Text color for affixes."]                             = "Цвет текста модификаторов."
L["Boss size"]                                          = "Размер имён боссов"
L["Font size for boss names (8–32 px)."]                = "Размер шрифта имён боссов (8–32 px)."
L["Boss color"]                                         = "Цвет имён боссов"
L["Text color for boss names."]                          = "Цвет текста имён боссов."
L["Reset Mythic+ typography"]                           = "Сбросить типографику Эпохального+"

-- =====================================================================
-- OptionsData.lua Appearance
-- =====================================================================
L["Backdrop opacity"]                                   = "Прозрачность фона"
L["Panel background opacity (0–1)."]                    = "Прозрачность фона панели (0–1)."
L["Show border"]                                        = "Показывать границу"
L["Show border around the tracker."]                    = "Показывает рамку вокруг трекера."
L["Show scroll indicator"]                              = "Показывать индикатор прокрутки"
L["Show a visual hint when the list has more content than is visible."] = "Показывает подсказку при наличии скрытого контента."
L["Scroll indicator style"]                             = "Стиль индикатора прокрутки"
L["Choose between a fade-out gradient or a small arrow to indicate scrollable content."] = "Градиент или стрелка для обозначения прокручиваемого контента."
L["Arrow"]                                              = "Стрелка"
L["Highlight alpha"]                                    = "Прозрачность выделения"
L["Opacity of focused quest highlight (0–1)."]          = "Прозрачность выделения активного задания (0–1)."
L["Bar width"]                                          = "Ширина полосы"
L["Width of bar-style highlights (2–6 px)."]            = "Ширина полосы выделения (2–6 px)."

-- =====================================================================
-- OptionsData.lua Organization
-- =====================================================================
L["Focus category order"]                               = "Порядок категорий Фокуса"
L["Drag to reorder categories. DELVES and SCENARIO EVENTS stay first."] = "Перетащите для изменения порядка. ПОДЗЕМЕЛЬЯ и СОБЫТИЯ СЦЕНАРИЯ остаются первыми."
L["Focus sort mode"]                                    = "Режим сортировки Фокуса"
L["Order of entries within each category."]             = "Порядок записей в каждой категории."
L["Auto-track accepted quests"]                         = "Автоотслеживание принятых заданий"
L["When you accept a quest (quest log only, not world quests), add it to the tracker automatically."] = "Автоматически добавляет принятые задания в трекер (кроме локальных)."
L["Require Ctrl for focus & remove"]                    = "Требовать Ctrl для отслеживания/снятия"
L["Require Ctrl for focus/add (Left) and unfocus/untrack (Right) to prevent misclicks."] = "Требует Ctrl для добавления (ЛКМ) и снятия (ПКМ) отслеживания."
L["Use classic click behaviour"]                             = "Классическое поведение при клике"
L["Share with party"]                                        = "Поделиться с группой"
L["Abandon quest"]                                           = "Отменить квест"
L["Stop tracking"]                                           = "Прекратить отслеживание"
L["This quest cannot be shared."]                             = "Эту квесту нельзя поделиться."
L["You must be in a party to share this quest."]              = "Чтобы поделиться квестом, нужно быть в группе."
L["When on, left-click opens the quest map and right-click shows share/abandon menu (Blizzard-style). When off, left-click focuses and right-click untracks; Ctrl+Right shares with party."] = "Вкл: ЛКМ открывает карту квеста, ПКМ — меню «поделиться/отменить» (стиль Blizzard). Выкл: ЛКМ — следить, ПКМ — снять; Ctrl+ПКМ — поделиться с группой."
L["Animations"]                                         = "Анимации"
L["Enable slide and fade for quests."]                  = "Включает анимацию появления и исчезновения заданий."
L["Objective progress flash"]                           = "Вспышка при выполнении цели"
L["Show flash when an objective completes."]            = "Показывает вспышку при выполнении цели."
L["Flash intensity"]                                   = "Интенсивность вспышки"
L["How noticeable the objective-complete flash is."]    = "Заметность вспышки при выполнении цели."
L["Flash color"]                                        = "Цвет вспышки"
L["Color of the objective-complete flash."]             = "Цвет вспышки при выполнении цели."
L["Subtle"]                                             = "Лёгкая"
L["Medium"]                                             = "Средняя"
L["Strong"]                                             = "Сильная"
L["Require Ctrl for click to complete"]                 = "Требовать Ctrl для завершения кликом"
L["When on, requires Ctrl+Left-click to complete auto-complete quests. When off, plain Left-click completes them (Blizzard default). Only affects quests that can be completed by click (no NPC turn-in needed)."] = "Вкл.: Ctrl+ЛКМ для завершения. Выкл.: ЛКМ (по умолчанию Blizzard). Только для заданий, завершаемых кликом."
L["Suppress untracked until reload"]                     = "Скрывать снятые до перезагрузки"
L["When on, right-click untrack on world quests and in-zone weeklies/dailies hides them until you reload or start a new session. When off, they reappear when you return to the zone."] = "Вкл.: снятые с отслеживания скрыты до перезагрузки. Выкл.: появляются при возврате в зону."
L["Permanently suppress untracked quests"]               = "Постоянно скрывать снятые с отслеживания"
L["When on, right-click untracked world quests and in-zone weeklies/dailies are hidden permanently (persists across reloads). Takes priority over 'Suppress until reload'. Accepting a suppressed quest removes it from the blacklist."] = "Вкл.: снятые скрыты постоянно. Приоритет над «Скрывать до перезагрузки». Принятие снимает с чёрного списка."
L["Keep campaign quests in category"]                    = "Оставлять кампанийные задания в категории"
L["When on, campaign quests that are ready to turn in remain in the Campaign category instead of moving to Complete."] = "Вкл.: готовые к сдаче кампанийные остаются в категории Кампания."
L["Keep important quests in category"]                   = "Оставлять важные задания в категории"
L["When on, important quests that are ready to turn in remain in the Important category instead of moving to Complete."] = "Вкл.: готовые к сдаче важные остаются в категории Важные."
L["TomTom quest waypoint"]                               = "Точка маршрута TomTom"
L["Set a TomTom waypoint when focusing a quest."]        = "Устанавливать точку маршрута TomTom при фокусировке на задании."
L["Requires TomTom. Points the arrow to the next quest objective."] = "Требуется TomTom. Стрелка указывает на следующую цель задания."

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
L["Blacklisted quests"]                                  = "Задания в чёрном списке"
L["Permanently suppressed quests"]                       = "Постоянно скрытые задания"
L["Right-click untrack quests with 'Permanently suppress untracked quests' enabled to add them here."] = "ПКМ снять с отслеживания при включённой опции «Постоянно скрывать» для добавления сюда."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["Show quest type icons"]                              = "Показывать иконки типов заданий"
L["Show quest type icon in the Focus tracker (quest accept/complete, world quest, quest update)."] = "Показывает иконки в трекере (принятие/завершение, локальные, обновление)."
L["Show quest type icons on toasts"]                    = "Показывать иконки типов на уведомлениях"
L["Show quest type icon on Presence toasts (quest accept/complete, world quest, quest update)."] = "Показывает иконки типов на уведомлениях Присутствия."
L["Toast icon size"]                                    = "Размер иконок на уведомлениях"
L["Quest icon size on Presence toasts (16–36 px). Default 24."] = "Размер иконок заданий на уведомлениях (16–36 px). По умолчанию 24."
L["Hide quest update title"]                            = "Скрывать заголовок в уведомлениях о прогрессе"
L["Show only the objective line on quest progress toasts (e.g. 7/10 Boar Pelts), without the quest name or header."] = "Показывать только строку цели (напр., 7/10 Шкур кабана) без названия задания и заголовка."
L["Show discovery line"]                                = "Показывать строку «Обнаружено»"
L["Show 'Discovered' under zone/subzone when entering a new area."] = "Показывает «Обнаружено» под зоной/подзоной при входе в новую область."
L["Frame vertical position"]                            = "Вертикальная позиция фрейма"
L["Vertical offset of the Presence frame from center (-300 to 0)."] = "Вертикальное смещение фрейма от центра (-300 до 0)."
L["Frame scale"]                                        = "Масштаб фрейма"
L["Scale of the Presence frame (0.5–2)."]              = "Масштаб фрейма Присутствия (0.5–2)."
L["Boss emote color"]                                   = "Цвет эмоций боссов"
L["Color of raid and dungeon boss emote text."]          = "Цвет текста эмоций боссов в рейдах и подземельях."
L["Discovery line color"]                               = "Цвет строки «Обнаружено»"
L["Color of the 'Discovered' line under zone text."]     = "Цвет строки «Обнаружено» под текстом зоны."
L["Notification types"]                                 = "Типы уведомлений"
L["Show zone entry"]                                    = "Показывать вход в зону"
L["Show zone change when entering a new area."]         = "Показывает уведомление при входе в новую зону."
L["Show subzone changes"]                               = "Показывать смену подзон"
L["Show subzone change when moving within the same zone."] = "Показывает уведомление при перемещении между подзонами в той же зоне."
L["Hide zone name for subzone changes"]                 = "Скрывать название зоны при смене подзоны"
L["When moving between subzones within the same zone, only show the subzone name. The zone name still appears when entering a new zone."] = "При переходе между подзонами показывать только подзону. Название зоны при входе в новую зону."
L["Suppress zone changes in Mythic+"]                   = "Скрывать смену зон в Эпохальном+"
L["In Mythic+, only show boss emotes, achievements, and level-up. Hide zone, quest, and scenario notifications."] = "В Эпохальном+: только эмоции боссов, достижения и повышение уровня."
L["Show level up"]                                      = "Показывать повышение уровня"
L["Show level-up notification."]                        = "Показывает уведомление о повышении уровня."
L["Show boss emotes"]                                   = "Показывать эмоции боссов"
L["Show raid and dungeon boss emote notifications."]    = "Показывает уведомления об эмоциях боссов в рейдах и подземельях."
L["Show achievements"]                                  = "Показывать достижения"
L["Show achievement earned notifications."]            = "Показывает уведомления о полученных достижениях."
L["Achievement progress"]                               = "Прогресс достижений"
L["Show notification when tracked achievement criteria update."] = "Показывает уведомление при обновлении критериев отслеживаемого достижения."
L["Show quest accept"]                                  = "Показывать принятие задания"
L["Show notification when accepting a quest."]          = "Показывает уведомление при принятии задания."
L["Show world quest accept"]                            = "Показывать принятие локального задания"
L["Show notification when accepting a world quest."]    = "Показывает уведомление при принятии локального задания."
L["Show quest complete"]                                = "Показывать завершение задания"
L["Show notification when completing a quest."]         = "Показывает уведомление при завершении задания."
L["Show world quest complete"]                          = "Показывать завершение локального задания"
L["Show notification when completing a world quest."]   = "Показывает уведомление при завершении локального задания."
L["Show quest progress"]                                = "Показывать прогресс задания"
L["Show notification when quest objectives update."]     = "Показывает уведомление при обновлении целей задания."
L["Objective only"]                                     = "Только цель"
L["Show only the objective line on quest progress toasts, hiding the 'Quest Update' title."] = "Показывать только строку цели на уведомлениях прогресса, скрывая заголовок «Обновление задания»."
L["Show scenario start"]                                = "Показывать начало сценария"
L["Show notification when entering a scenario or Delve."] = "Показывает уведомление при входе в сценарий или Глубины."
L["Show scenario progress"]                             = "Показывать прогресс сценария"
L["Show notification when scenario or Delve objectives update."] = "Показывает уведомление при обновлении целей сценария или Глубин."
L["Animation"]                                          = "Анимация"
L["Enable animations"]                                  = "Включить анимации"
L["Enable entrance and exit animations for Presence notifications."] = "Включает анимации появления и исчезновения уведомлений."
L["Entrance duration"]                                  = "Длительность появления"
L["Duration of the entrance animation in seconds (0.2–1.5)."] = "Длительность анимации появления в секундах (0.2–1.5)."
L["Exit duration"]                                      = "Длительность исчезновения"
L["Duration of the exit animation in seconds (0.2–1.5)."] = "Длительность анимации исчезновения в секундах (0.2–1.5)."
L["Hold duration scale"]                                = "Множитель времени показа"
L["Multiplier for how long each notification stays on screen (0.5–2)."] = "Множитель времени показа уведомлений (0.5–2)."
L["Typography"]                                         = "Типографика"
L["Main title font"]                                    = "Шрифт основного заголовка"
L["Font family for the main title."]                     = "Семейство шрифтов для основного заголовка."
L["Subtitle font"]                                      = "Шрифт подзаголовка"
L["Font family for the subtitle."]                      = "Семейство шрифтов для подзаголовка."
L["Main title size"]                                    = "Размер основного заголовка"
L["Font size for the main title (24–72 px)."]            = "Размер шрифта основного заголовка (24–72 px)."
L["Subtitle size"]                                      = "Размер подзаголовка"
L["Font size for the subtitle (12–40 px)."]             = "Размер шрифта подзаголовка (12–40 px)."

-- =====================================================================
-- OptionsData.lua Dropdown options — Outline
-- =====================================================================
L["None"]                                               = "Нет"
L["Thick Outline"]                                      = "Толстый контур"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["Bar (left edge)"]                                    = "Полоса (слева)"
L["Bar (right edge)"]                                   = "Полоса (справа)"
L["Bar (top edge)"]                                     = "Полоса (сверху)"
L["Bar (bottom edge)"]                                  = "Полоса (снизу)"
L["Outline only"]                                       = "Только контур"
L["Soft glow"]                                          = "Мягкое свечение"
L["Dual edge bars"]                                     = "Двойные полосы"
L["Pill left accent"]                                   = "Акцент слева"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["Top"]                                                = "Сверху"
L["Bottom"]                                             = "Снизу"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["Location position"]                                  = "Позиция названия зоны"
L["Place the zone name above or below the minimap."]      = "Размещение названия зоны над или под миникартой."
L["Coordinates position"]                               = "Позиция координат"
L["Place the coordinates above or below the minimap."]    = "Размещение координат над или под миникартой."
L["Clock position"]                                     = "Позиция часов"
L["Place the clock above or below the minimap."]          = "Размещение часов над или под миникартой."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["Lower Case"]                                         = "Строчные"
L["Upper Case"]                                         = "Заглавные"
L["Proper"]                                             = "С заглавной буквы"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["Tracked / in log"]                                   = "Отслеживаемые / в журнале"
L["In log / max slots"]                                 = "В журнале / макс. слотов"

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["Alphabetical"]                                       = "По алфавиту"
L["Quest Type"]                                         = "По типу задания"
L["Quest Level"]                                        = "По уровню задания"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["Custom"]                                             = "Пользовательский"
L["Order"]                                              = "Порядок"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["DUNGEON"]           = "ПОДЗЕМЕЛЬЕ"
L["RAID"]              = "РЕЙД"
L["DELVES"]            = "ПОДЗЕМЕЛЬЯ"
L["SCENARIO EVENTS"]   = "СОБЫТИЯ СЦЕНАРИЯ"
L["AVAILABLE IN ZONE"] = "ДОСТУПНО В ЗОНЕ"
L["EVENTS IN ZONE"] = "События в зоне"
L["CURRENT EVENT"] = "Текущее событие"
L["CURRENT QUEST"]     = "ТЕКУЩИЙ КВЕСТ"
L["CURRENT ZONE"]      = "ТЕКУЩАЯ ЗОНА"
L["CAMPAIGN"]          = "КАМПАНИЯ"
L["IMPORTANT"]         = "ВАЖНЫЕ"
L["LEGENDARY"]         = "ЛЕГЕНДАРНЫЕ"
L["WORLD QUESTS"]      = "ЛОКАЛЬНЫЕ ЗАДАНИЯ"
L["WEEKLY QUESTS"]     = "ЕЖЕНЕДЕЛЬНЫЕ"
L["DAILY QUESTS"]      = "ЕЖЕДНЕВНЫЕ"
L["RARE BOSSES"]       = "РЕДКИЕ БОССЫ"
L["ACHIEVEMENTS"]      = "ДОСТИЖЕНИЯ"
L["ENDEAVORS"]         = "НАЧИНАНИЯ"
L["DECOR"]             = "УКРАШЕНИЯ"
L["QUESTS"]            = "ЗАДАНИЯ"
L["READY TO TURN IN"]  = "ГОТОВО К СДАЧЕ"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["OBJECTIVES"]                                                                                    = "ЦЕЛИ"
L["Options"]                                                                                       = "Настройки"
L["Discovered"]                                                                                    = "Обнаружено"
L["Refresh"]                                                                                       = "Обновить"
L["Best-effort only. Some unaccepted quests are not exposed until you interact with NPCs or meet phasing conditions."] = "Поиск приблизительный. Некоторые непринятые задания не отображаются до взаимодействия с НИП или условий фазы."
L["Unaccepted Quests - %s (map %s) - %d match(es)"]                                                  = "Непринятые задания - %s (карта %s) - %d совпадений"

L["LEVEL UP"]                                                                                      = "ПОВЫШЕНИЕ УРОВНЯ"
L["You have reached level 80"]                                                                     = "Вы достигли 80 уровня"
L["You have reached level %s"]                                                                     = "Вы достигли %s уровня"
L["ACHIEVEMENT EARNED"]                                                                            = "ДОСТИЖЕНИЕ ПОЛУЧЕНО"
L["Exploring the Midnight Isles"]                                                                  = "Исследование Полуночных островов"
L["Exploring Khaz Algar"]                                                                          = "Исследование Каз Алгара"
L["QUEST COMPLETE"]                                                                                = "ЗАДАНИЕ ВЫПОЛНЕНО"
L["Objective Secured"]                                                                             = "Цель достигнута"
L["Aiding the Accord"]                                                                             = "Помощь Согласию"
L["WORLD QUEST"]                                                                                   = "ЛОКАЛЬНОЕ ЗАДАНИЕ"
L["Azerite Mining"]                                                                                = "Добыча азерита"
L["WORLD QUEST ACCEPTED"]                                                                          = "ЛОКАЛЬНОЕ ЗАДАНИЕ ПРИНЯТО"
L["QUEST ACCEPTED"]                                                                                = "ЗАДАНИЕ ПРИНЯТО"
L["The Fate of the Horde"]                                                                         = "Судьба Орды"
L["New Quest"]                                                                                     = "Новое задание"
L["QUEST UPDATE"]                                                                                  = "ОБНОВЛЕНИЕ ЗАДАНИЯ"
L["Boar Pelts: 7/10"]                                                                              = "Шкуры кабана: 7/10"
L["Dragon Glyphs: 3/5"]                                                                            = "Драконьи руны: 3/5"

L["Presence test commands:"]                                                                       = "Тестовые команды Присутствия:"
L["  /h presence         - Show help + test current zone"]                                   = "  /h presence         - Справка + тест текущей зоны"
L["  /h presence zone     - Test Zone Change"]                                               = "  /h presence zone     - Тест смены зоны"
L["  /h presence subzone  - Test Subzone Change"]                                            = "  /h presence subzone  - Тест смены подзоны"
L["  /h presence discover - Test Zone Discovery"]                                            = "  /h presence discover - Тест обнаружения зоны"
L["  /h presence level    - Test Level Up"]                                                  = "  /h presence level    - Тест повышения уровня"
L["  /h presence boss     - Test Boss Emote"]                                                = "  /h presence boss     - Тест эмоции босса"
L["  /h presence ach      - Test Achievement"]                                               = "  /h presence ach      - Тест достижения"
L["  /h presence accept   - Test Quest Accepted"]                                            = "  /h presence accept   - Тест принятия задания"
L["  /h presence wqaccept - Test World Quest Accepted"]                                      = "  /h presence wqaccept - Тест принятия локального задания"
L["  /h presence scenario - Test Scenario Start"]                                            = "  /h presence scenario - Тест начала сценария"
L["  /h presence quest    - Test Quest Complete"]                                            = "  /h presence quest    - Тест завершения задания"
L["  /h presence wq       - Test World Quest"]                                               = "  /h presence wq       - Тест локального задания"
L["  /h presence update   - Test Quest Update"]                                              = "  /h presence update   - Тест обновления задания"
L["  /h presence achprogress - Test Achievement Progress"]                                   = "  /h presence achprogress - Тест прогресса достижения"
L["  /h presence all      - Demo reel (all types)"]                                          = "  /h presence all      - Демо (все типы)"
L["  /h presence debug    - Dump state to chat"]                                             = "  /h presence debug    - Вывод состояния в чат"
L["  /h presence debuglive - Toggle live debug panel (log as events happen)"]                = "  /h presence debuglive - Вкл/выкл панель отладки (логирование событий)"

-- =====================================================================
-- OptionsData.lua Vista — General
-- =====================================================================
L["Minimap"]                                                        = "Миникарта"
L["Minimap size"]                                                   = "Размер миникарты"
L["Width and height of the minimap in pixels (100–400)."]           = "Ширина и высота миникарты в пикселях (100–400)."
L["Circular minimap"]                                               = "Круглая миникарта"
L["Use a circular minimap instead of square."]                      = "Использовать круглую миникарту вместо квадратной."
L["Lock minimap position"]                                          = "Заблокировать позицию миникарты"
L["Prevent dragging the minimap."]                                  = "Запретить перетаскивание миникарты."
L["Reset minimap position"]                                         = "Сбросить позицию миникарты"
L["Reset minimap to its default position (top-right)."]             = "Вернуть миникарту на стандартное место (правый верхний угол)."
L["Auto Zoom"]                                                      = "Авто-зум"
L["Auto zoom-out delay"]                                            = "Задержка авто-отдаления"
L["Seconds after zooming before auto zoom-out fires. Set to 0 to disable."] = "Секунд до авто-отдаления после зума. 0 — отключить."

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["Zone Text"]                                                      = "Текст зоны"
L["Zone font"]                                                      = "Шрифт зоны"
L["Font for the zone name below the minimap."]                      = "Шрифт названия зоны под миникартой."
L["Zone font size"]                                                 = "Размер шрифта зоны"
L["Zone text color"]                                                = "Цвет текста зоны"
L["Color of the zone name text."]                                   = "Цвет текста названия зоны."
L["Coordinates Text"]                                               = "Текст координат"
L["Coordinates font"]                                               = "Шрифт координат"
L["Font for the coordinates text below the minimap."]               = "Шрифт текста координат под миникартой."
L["Coordinates font size"]                                          = "Размер шрифта координат"
L["Coordinates text color"]                                         = "Цвет текста координат"
L["Color of the coordinates text."]                                 = "Цвет текста координат."
L["Coordinate precision"]                                           = "Точность координат"
L["Number of decimal places shown for X and Y coordinates."]        = "Количество знаков после запятой для координат X и Y."
L["No decimals (e.g. 52, 37)"]                                      = "Без дробей (напр. 52, 37)"
L["1 decimal (e.g. 52.3, 37.1)"]                                    = "1 знак (напр. 52.3, 37.1)"
L["2 decimals (e.g. 52.34, 37.12)"]                                 = "2 знака (напр. 52.34, 37.12)"
L["Time Text"]                                                      = "Текст времени"
L["Time font"]                                                      = "Шрифт времени"
L["Font for the time text below the minimap."]                      = "Шрифт текста времени под миникартой."
L["Time font size"]                                                 = "Размер шрифта времени"
L["Time text color"]                                                = "Цвет текста времени"
L["Color of the time text."]                                        = "Цвет текста времени."
L["Difficulty Text"]                                                = "Текст сложности"
L["Difficulty text color (fallback)"]                               = "Цвет текста сложности (по умолчанию)"
L["Default color when no per-difficulty color is set."]             = "Цвет по умолчанию, если не задан цвет для конкретной сложности."
L["Difficulty font"]                                                = "Шрифт сложности"
L["Font for the instance difficulty text."]                         = "Шрифт текста сложности подземелья."
L["Difficulty font size"]                                           = "Размер шрифта сложности"
L["Per-Difficulty Colors"]                                          = "Цвета по сложности"
L["Mythic color"]                                                   = "Цвет «Эпохальный»"
L["Color for Mythic difficulty text."]                              = "Цвет текста эпохальной сложности."
L["Heroic color"]                                                   = "Цвет «Героический»"
L["Color for Heroic difficulty text."]                              = "Цвет текста героической сложности."
L["Normal color"]                                                   = "Цвет «Обычный»"
L["Color for Normal difficulty text."]                              = "Цвет текста обычной сложности."
L["LFR color"]                                                      = "Цвет «Поиск рейда»"
L["Color for Looking For Raid difficulty text."]                    = "Цвет текста сложности «Поиск рейда»."

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["Text Elements"]                                                  = "Текстовые элементы"
L["Show zone text"]                                                 = "Показывать текст зоны"
L["Show the zone name below the minimap."]                          = "Показывать название зоны под миникартой."
L["Zone text display mode"]                                         = "Режим отображения текста зоны"
L["What to show: zone only, subzone only, or both."]                = "Что показывать: только зону, только подзону или обе."
L["Zone only"]                                                      = "Только зона"
L["Subzone only"]                                                   = "Только подзона"
L["Both"]                                                           = "Обе"
L["Show coordinates"]                                               = "Показывать координаты"
L["Show player coordinates below the minimap."]                     = "Показывать координаты игрока под миникартой."
L["Show time"]                                                      = "Показывать время"
L["Show current game time below the minimap."]                      = "Показывать текущее игровое время под миникартой."
L["Use local time"]                                                 = "Использовать местное время"
L["When on, shows your local system time. When off, shows server time."] = "Вкл.: местное системное время. Выкл.: серверное время."
L["Minimap Buttons"]                                                = "Кнопки миникарты"
L["Queue status and mail indicator are always shown when relevant."] = "Статус очереди и индикатор почты всегда отображаются при необходимости."
L["Show tracking button"]                                           = "Показывать кнопку слежения"
L["Show the minimap tracking button."]                              = "Показывать кнопку слежения на миникарте."
L["Tracking button on mouseover only"]                              = "Кнопка слежения только при наведении"
L["Hide tracking button until you hover over the minimap."]         = "Скрывать кнопку слежения до наведения на миникарту."
L["Show calendar button"]                                           = "Показывать кнопку календаря"
L["Show the minimap calendar button."]                              = "Показывать кнопку календаря на миникарте."
L["Calendar button on mouseover only"]                              = "Кнопка календаря только при наведении"
L["Hide calendar button until you hover over the minimap."]         = "Скрывать кнопку календаря до наведения на миникарту."
L["Show zoom buttons"]                                              = "Показывать кнопки зума"
L["Show the + and - zoom buttons on the minimap."]                  = "Показывать кнопки + и - зума на миникарте."
L["Zoom buttons on mouseover only"]                                 = "Кнопки зума только при наведении"
L["Hide zoom buttons until you hover over the minimap."]            = "Скрывать кнопки зума до наведения на миникарту."

-- =====================================================================
-- OptionsData.lua Vista — Display
-- =====================================================================
L["Border"]                                                         = "Рамка"
L["Show a border around the minimap."]                              = "Показывать рамку вокруг миникарты."
L["Border color"]                                                   = "Цвет рамки"
L["Color (and opacity) of the minimap border."]                     = "Цвет (и прозрачность) рамки миникарты."
L["Border thickness"]                                               = "Толщина рамки"
L["Thickness of the minimap border in pixels (1–8)."]               = "Толщина рамки миникарты в пикселях (1–8)."
L["Text Positions"]                                                 = "Позиции текста"
L["Drag text elements to reposition them. Lock to prevent accidental movement."] = "Перетащите текстовые элементы для изменения позиции. Заблокируйте, чтобы избежать случайного перемещения."
L["Lock zone text position"]                                        = "Зафиксировать позицию текста зоны"
L["When on, the zone text cannot be dragged."]                      = "Вкл.: текст зоны нельзя перетащить."
L["Lock coordinates position"]                                      = "Зафиксировать позицию координат"
L["When on, the coordinates text cannot be dragged."]               = "Вкл.: текст координат нельзя перетащить."
L["Lock time position"]                                             = "Зафиксировать позицию времени"
L["When on, the time text cannot be dragged."]                      = "Вкл.: текст времени нельзя перетащить."
L["Lock difficulty text position"]                                  = "Зафиксировать позицию текста сложности"
L["When on, the difficulty text cannot be dragged."]                = "Вкл.: текст сложности нельзя перетащить."
L["Button Positions"]                                               = "Позиции кнопок"
L["Drag buttons to reposition them. Lock to prevent movement."]     = "Перетащите кнопки для изменения позиции. Заблокируйте для фиксации."
L["Lock Zoom In button"]                                            = "Зафиксировать кнопку «Приблизить»"
L["Prevent dragging the + zoom button."]                            = "Запретить перетаскивание кнопки зума +."
L["Lock Zoom Out button"]                                           = "Зафиксировать кнопку «Отдалить»"
L["Prevent dragging the - zoom button."]                            = "Запретить перетаскивание кнопки зума -."
L["Lock Tracking button"]                                           = "Зафиксировать кнопку слежения"
L["Prevent dragging the tracking button."]                          = "Запретить перетаскивание кнопки слежения."
L["Lock Calendar button"]                                           = "Зафиксировать кнопку календаря"
L["Prevent dragging the calendar button."]                          = "Запретить перетаскивание кнопки календаря."
L["Lock Queue button"]                                              = "Зафиксировать кнопку очереди"
L["Prevent dragging the queue status button."]                      = "Запретить перетаскивание кнопки статуса очереди."
L["Disable queue button handling"]                                  = "Отключить управление кнопкой очереди"
L["Turn off all queue button anchoring (use if another addon manages it)."] = "Отключить привязку кнопки очереди (если ею управляет другой аддон)."
L["Button Sizes"]                                                   = "Размеры кнопок"
L["Adjust the size of minimap overlay buttons."]                    = "Настроить размер кнопок поверх миникарты."
L["Tracking button size"]                                           = "Размер кнопки слежения"
L["Size of the tracking button (pixels)."]                          = "Размер кнопки слежения (пиксели)."
L["Calendar button size"]                                           = "Размер кнопки календаря"
L["Size of the calendar button (pixels)."]                          = "Размер кнопки календаря (пиксели)."
L["Queue button size"]                                              = "Размер кнопки очереди"
L["Size of the queue status button (pixels)."]                      = "Размер кнопки статуса очереди (пиксели)."
L["Zoom button size"]                                               = "Размер кнопок зума"
L["Size of the zoom in / zoom out buttons (pixels)."]               = "Размер кнопок зума + / - (пиксели)."
L["Mail indicator size"]                                            = "Размер индикатора почты"
L["Size of the new mail icon (pixels)."]                            = "Размер значка новой почты (пиксели)."
L["Addon button size"]                                              = "Размер кнопок аддонов"
L["Size of collected addon minimap buttons (pixels)."]              = "Размер собранных кнопок аддонов на миникарте (пиксели)."

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
L["Minimap Addon Buttons"]                                          = "Кнопки аддонов на миникарте"
L["Button Management"]                                              = "Управление кнопками"
L["Manage addon minimap buttons"]                                   = "Управлять кнопками аддонов на миникарте"
L["When on, Vista takes control of addon minimap buttons and groups them by the selected mode."] = "Вкл.: Vista берёт под контроль кнопки аддонов и группирует их выбранным способом."
L["Button mode"]                                                    = "Режим кнопок"
L["How addon buttons are presented: hover bar below minimap, panel on right-click, or floating drawer button."] = "Отображение кнопок аддонов: панель при наведении, панель по правому клику или плавающая кнопка."
L["Mouseover bar"]                                                  = "Панель при наведении"
L["Right-click panel"]                                              = "Панель по ПКМ"
L["Floating drawer"]                                                = "Плавающая панель"
L["Lock drawer button position"]                                    = "Зафиксировать кнопку панели"
L["Prevent dragging the floating drawer button."]                   = "Запретить перетаскивание кнопки плавающей панели."
L["Lock mouseover bar position"]                                    = "Зафиксировать панель при наведении"
L["Prevent dragging the mouseover button bar."]                     = "Запретить перетаскивание панели кнопок при наведении."
L["Lock right-click panel position"]                                = "Зафиксировать панель ПКМ"
L["Prevent dragging the right-click panel."]                        = "Запретить перетаскивание панели правого клика."
L["Buttons per row/column"]                                         = "Кнопок в строке/столбце"
L["Controls how many buttons appear before wrapping. For left/right direction this is columns; for up/down it is rows."] = "Количество кнопок до переноса строки. Для направлений влево/вправо — столбцы; вверх/вниз — строки."
L["Expand direction"]                                               = "Направление расширения"
L["Direction buttons fill from the anchor point. Left/Right = horizontal rows. Up/Down = vertical columns."] = "Направление заполнения от точки привязки. Влево/вправо = горизонтальные ряды. Вверх/вниз = вертикальные столбцы."
L["Right"]                                                          = "Вправо"
L["Left"]                                                           = "Влево"
L["Down"]                                                           = "Вниз"
L["Up"]                                                             = "Вверх"
L["Panel Appearance"]                                               = "Вид панели"
L["Colors for the drawer and right-click button panels."]           = "Цвета для панелей кнопок (плавающей и ПКМ)."
L["Panel background color"]                                         = "Цвет фона панели"
L["Background color of the addon button panels."]                   = "Цвет фона панелей кнопок аддонов."
L["Panel border color"]                                             = "Цвет рамки панели"
L["Border color of the addon button panels."]                       = "Цвет рамки панелей кнопок аддонов."
L["Managed buttons"]                                                = "Управляемые кнопки"
L["When off, this button is completely ignored by this addon."]     = "Выкл.: кнопка полностью игнорируется этим аддоном."
L["(No addon buttons detected yet)"]                                = "(Кнопки аддонов пока не обнаружены)"
L["Visible buttons (check to include)"]                             = "Видимые кнопки (отметьте для включения)"
L["(No addon buttons detected yet — open your minimap first)"]      = "(Кнопки аддонов не обнаружены — сначала откройте миникарту)"

