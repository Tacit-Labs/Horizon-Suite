if GetLocale() ~= "esES" then return end

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
L["Focus"]                                                          = "Enfoque"
L["Presence"]                                                       = "Presencia"
L["Other"]                                                          = "Otro"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["Quest types"]                                                    = "Tipos de misiones"
L["Element overrides"]                                              = "Colores por elemento"
L["Per category"]                                                   = "Colores por categoría"
L["Grouping Overrides"]                                              = "Colores personalizados"
L["Other colors"]                                                   = "Otros colores"

-- =====================================================================
-- OptionsPanel.lua — Color row labels (collapsible group sub-rows)
-- =====================================================================
L["Section"]                                                        = "Sección"
L["Title"]                                                          = "Título"
L["Zone"]                                                           = "Zona"
L["Objective"]                                                      = "Objetivo"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["Ready to Turn In overrides base colours"]                        = "Usar colores distintos para la sección Listas para entregar"
L["Ready to Turn In uses its colours for quests in that section."]  = "La sección Listas para entregar usará sus propios colores."
L["Current Zone overrides base colours"]                            = "Usar colores distintos para la sección Zona actual"
L["Current Zone uses its colours for quests in that section."]      = "La sección Zona actual usará sus propios colores."
L["Current Quest overrides base colours"]                           = "Usar colores distintos para la sección Misión actual"
L["Current Quest uses its colours for quests in that section."]     = "La sección Misión actual usará sus propios colores."
L["Use distinct color for completed objectives"]                     = "Usar color distinto para objetivos completados"
L["When on, completed objectives (e.g. 1/1) use the color below; when off, they use the same color as incomplete objectives."] = "Activado: los objetivos completados (ej. 1/1) usan el color de abajo. Desactivado: usan el mismo color que los incompletos."
L["Completed objective"]                                           = "Objetivo completado"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["Reset"]                                                          = "Restablecer"
L["Reset quest types"]                                              = "Restablecer tipos de misiones"
L["Reset overrides"]                                                = "Restablecer colores personalizados"
L["Reset to defaults"]                                              = "Restablecer valores por defecto"
L["Reset to default"]                                               = "Restablecer valor por defecto"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["Search settings..."]                                             = "Buscar opciones..."
L["Search fonts..."]                                                 = "Buscar fuentes..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["Drag to resize"]                                                 = "Arrastra para redimensionar"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
L["Modules"]                                            = "Módulos"
L["Layout"]                                             = "Diseño"
L["Visibility"]                                         = "Visibilidad"
L["Display"]                                            = "Visualización"
L["Features"]                                           = "Características"
L["Typography"]                                         = "Tipografía"
L["Appearance"]                                         = "Apariencia"
L["Colors"]                                             = "Colores"
L["Organization"]                                       = "Organización"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["Panel behaviour"]                                    = "Comportamiento del panel"
L["Dimensions"]                                         = "Dimensiones"
L["Instance"]                                           = "Instancia"
L["Combat"]                                             = "Combate"
L["Filtering"]                                          = "Filtros"
L["Header"]                                             = "Encabezado"
L["List"]                                               = "Lista"
L["Spacing"]                                            = "Espaciado"
L["Rare bosses"]                                        = "Jefes raros"
L["World quests"]                                       = "Misiones de mundo"
L["Floating quest item"]                                = "Objeto de misión flotante"
L["Mythic+"]                                            = "Mítico+"
L["Achievements"]                                       = "Logros"
L["Endeavors"]                                          = "Empeños"
L["Decor"]                                              = "Decoración"
L["Scenario & Delve"]                                   = "Escenario y Sima"
L["Font"]                                               = "Fuente"
L["Text case"]                                          = "Mayúsculas/minúsculas"
L["Shadow"]                                             = "Sombra"
L["Panel"]                                              = "Panel"
L["Highlight"]                                          = "Resaltado"
L["Color matrix"]                                       = "Matriz de colores"
L["Focus order"]                                        = "Orden de enfoque"
L["Sort"]                                               = "Ordenar"
L["Behaviour"]                                          = "Comportamiento"
L["Content Types"]                                      = "Tipos de contenido"
L["Delves"]                                             = "Simas"
L["Delves & Dungeons"]                                  = "Simas y Mazmorras"
L["Delve Complete"]                                     = "Sima completada"
L["Interactions"]                                       = "Interacciones"
L["Tracking"]                                           = "Seguimiento"
L["Scenario Bar"]                                       = "Barra de escenario"

-- =====================================================================
-- OptionsData.lua Modules
-- =====================================================================
L["Enable Focus module"]                                = "Activar módulo Enfoque"
L["Show the objective tracker for quests, world quests, rares, achievements, and scenarios."] = "Muestra el rastreador de objetivos para misiones, misiones de mundo, raros, logros y escenarios."
L["Enable Presence module"]                             = "Activar módulo Presencia"
L["Cinematic zone text and notifications (zone changes, level up, boss emotes, achievements, quest updates)."] = "Texto de zona cinematográfico y notificaciones (cambios de zona, subida de nivel, emotes de jefes, logros, actualizaciones de misiones)."
L["Enable Yield module"]                                = "Activar módulo Yield"
L["Cinematic loot notifications (items, money, currency, reputation)."] = "Notificaciones cinematográficas de botín (objetos, oro, monedas, reputación)."
L["Enable Vista module"]                                = "Activar módulo Vista"
L["Cinematic square minimap with zone text, coordinates, and button collector."] = "Minimapa cuadrado cinematográfico con texto de zona, coordenadas y recopilador de botones."
L["Beta"]                                               = "Beta"
L["Scaling"]                                            = "Escala"
L["Global UI scale"]                                    = "Escala global de la interfaz"
L["Scale all sizes, spacings, and fonts by this factor (50–200%). Does not change your configured values."] = "Escala todos los tamaños, espaciados y fuentes por este factor (50–200%). No cambia tus valores configurados."
L["Per-module scaling"]                                 = "Escala por módulo"
L["Override the global scale with individual sliders for each module."] = "Reemplaza la escala global con controles deslizantes individuales para cada módulo."
L["Focus scale"]                                        = "Escala Enfoque"
L["Scale for the Focus objective tracker (50–200%)."]   = "Escala del rastreador de objetivos Enfoque (50–200%)."
L["Presence scale"]                                     = "Escala Presencia"
L["Scale for the Presence cinematic text (50–200%)."]   = "Escala del texto cinematográfico Presencia (50–200%)."
L["Vista scale"]                                        = "Escala Vista"
L["Scale for the Vista minimap module (50–200%)."]      = "Escala del módulo minimapa Vista (50–200%)."
L["Insight scale"]                                      = "Escala Insight"
L["Scale for the Insight tooltip module (50–200%)."]    = "Escala del módulo de descripción Insight (50–200%)."
L["Yield scale"]                                        = "Escala Yield"
L["Scale for the Yield loot toast module (50–200%)."]   = "Escala del módulo de notificaciones de botín Yield (50–200%)."
L["Enable Horizon Insight module"]                      = "Activar módulo Horizon Insight"
L["Cinematic tooltips with class colors, spec display, and faction icons."] = "Descripciones cinematográficas con colores de clase, especialización e iconos de facción."
L["Horizon Insight"]                                    = "Horizon Insight"
L["Insight"]                                            = "Insight"
L["Tooltip anchor mode"]                                = "Modo de anclaje de descripciones"
L["Where tooltips appear: follow cursor or fixed position."] = "Dónde aparecen las descripciones: seguir cursor o posición fija."
L["Cursor"]                                             = "Cursor"
L["Fixed"]                                              = "Fijo"
L["Show anchor to move"]                                = "Mostrar ancla para mover"
L["Show draggable frame to set fixed tooltip position. Drag, then right-click to confirm."] = "Muestra un marco arrastrable para definir la posición fija. Arrastra y haz clic derecho para confirmar."
L["Reset tooltip position"]                             = "Restablecer posición de descripciones"
L["Reset fixed position to default."]                   = "Restablecer posición fija al valor por defecto."
L["Yield"]                                              = "Yield"
L["General"]                                            = "General"
L["Position"]                                           = "Posición"
L["Reset position"]                                     = "Restablecer posición"
L["Reset loot toast position to default."]              = "Restablecer posición de notificaciones de botín."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["Lock position"]                                      = "Bloquear posición"
L["Prevent dragging the tracker."]                      = "Impide arrastrar el rastreador de objetivos."
L["Grow upward"]                                        = "Crecer hacia arriba"
L["Grow-up header"]                                     = "Encabezado al crecer"
L["When growing upward: keep header at bottom, or at top until collapsed."] = "Al crecer hacia arriba: mantener encabezado abajo o arriba hasta colapsar."
L["Header at bottom"]                                  = "Encabezado abajo"
L["Header slides on collapse"]                         = "Encabezado se desliza al colapsar"
L["Anchor at bottom so the list grows upward."]         = "Anclar abajo para que la lista crezca hacia arriba."
L["Start collapsed"]                                    = "Iniciar colapsado"
L["Start with only the header shown until you expand."] = "Mostrar solo el encabezado hasta que lo expandas."
L["Panel width"]                                        = "Ancho del panel"
L["Tracker width in pixels."]                           = "Ancho del rastreador de objetivos en píxeles."
L["Max content height"]                                 = "Altura máxima del contenido"
L["Max height of the scrollable list (pixels)."]        = "Altura máxima de la lista desplazable (píxeles)."

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["Always show M+ block"]                                           = "Mostrar siempre el bloque M+"
L["Show the M+ block whenever an active keystone is running"]       = "Muestra el bloque M+ cuando haya una piedra angular activa."
L["Show in dungeon"]                                    = "Mostrar en mazmorra"
L["Show tracker in party dungeons."]                    = "Muestra el rastreador en mazmorras de grupo."
L["Show in raid"]                                       = "Mostrar en banda"
L["Show tracker in raids."]                             = "Muestra el rastreador en bandas."
L["Show in battleground"]                               = "Mostrar en campo de batalla"
L["Show tracker in battlegrounds."]                     = "Muestra el rastreador en campos de batalla."
L["Show in arena"]                                      = "Mostrar en arena"
L["Show tracker in arenas."]                            = "Muestra el rastreador en arenas."
L["Hide in combat"]                                     = "Ocultar en combate"
L["Hide tracker and floating quest item in combat."]    = "Oculta el rastreador y el objeto de misión flotante en combate."
L["Combat visibility"]                                  = "Visibilidad en combate"
L["How the tracker behaves in combat: show, fade to reduced opacity, or hide."] = "Comportamiento del rastreador en combate: mostrar, atenuar o ocultar."
L["Show"]                                               = "Mostrar"
L["Fade"]                                               = "Atenuar"
L["Hide"]                                               = "Ocultar"
L["Combat fade opacity"]                                = "Opacidad atenuada en combate"
L["How visible the tracker is when faded in combat (0 = invisible). Only applies when Combat visibility is Fade."] = "Visibilidad del rastreador cuando está atenuado en combate (0 = invisible). Solo aplica cuando la visibilidad en combate es Atenuar."
L["Mouseover"]                                          = "Al pasar el ratón"
L["Show only on mouseover"]                             = "Mostrar solo al pasar el ratón"
L["Fade tracker when not hovering; move mouse over it to show."] = "Atenúa el rastreador cuando no pasas el ratón; pásalo por encima para mostrarlo."
L["Faded opacity"]                                      = "Opacidad atenuada"
L["How visible the tracker is when faded (0 = invisible)."] = "Visibilidad del rastreador cuando está atenuado (0 = invisible)."
L["Only show quests in current zone"]                   = "Solo misiones de la zona actual"
L["Hide quests outside your current zone."]             = "Oculta misiones fuera de tu zona actual."

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["Show quest count"]                                   = "Mostrar contador de misiones"
L["Show quest count in header."]                        = "Muestra el contador de misiones en el encabezado."
L["Header count format"]                                = "Formato del contador de misiones"
L["Tracked/in-log or in-log/max-slots. Tracked excludes world/live-in-zone quests."] = "Seguidas/En registro o En registro/Máx. ranuras. Seguidas excluye misiones de mundo y de zona activa."
L["Show header divider"]                                = "Mostrar divisor del encabezado"
L["Show the line below the header."]                    = "Muestra la línea debajo del encabezado."
L["Header divider color"]                               = "Color del divisor del encabezado"
L["Color of the line below the header."]                = "Color de la línea debajo del encabezado."
L["Super-minimal mode"]                                 = "Modo super minimalista"
L["Hide header for a pure text list."]                  = "Oculta el encabezado para una lista de solo texto."
L["Show options button"]                               = "Mostrar botón de opciones"
L["Show the Options button in the tracker header."]     = "Muestra el botón de opciones en el encabezado del rastreador."
L["Header color"]                                       = "Color del encabezado"
L["Color of the OBJECTIVES header text."]               = "Color del texto del encabezado OBJETIVOS."
L["Header height"]                                      = "Altura del encabezado"
L["Height of the header bar in pixels (18–48)."]        = "Altura de la barra del encabezado en píxeles (18–48)."

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["Show section headers"]                               = "Mostrar encabezados de sección"
L["Show category labels above each group."]             = "Muestra las etiquetas de categoría encima de cada grupo."
L["Show category headers when collapsed"]               = "Mostrar encabezados de categoría cuando está colapsado"
L["Keep section headers visible when collapsed; click to expand a category."] = "Mantiene los encabezados visibles cuando está colapsado; haz clic para expandir una categoría."
L["Show Nearby (Current Zone) group"]                   = "Mostrar grupo Zona actual"
L["Show in-zone quests in a dedicated Current Zone section. When off, they appear in their normal category."] = "Muestra las misiones de zona en una sección dedicada. Desactivado: aparecen en su categoría normal."
L["Show zone labels"]                                   = "Mostrar etiquetas de zona"
L["Show zone name under each quest title."]             = "Muestra el nombre de zona debajo de cada título de misión."
L["Active quest highlight"]                             = "Resaltado de misión activa"
L["How the focused quest is highlighted."]              = "Cómo se resalta la misión enfocada."
L["Show quest item buttons"]                            = "Mostrar botones de objeto de misión"
L["Show usable quest item button next to each quest."]  = "Muestra el botón de objeto utilizable junto a cada misión."
L["Show objective numbers"]                             = "Mostrar números de objetivos"
L["Prefix objectives with 1., 2., 3."]                  = "Prefijar objetivos con 1., 2., 3."
L["Show completed count"]                               = "Mostrar contador de completados"
L["Show X/Y progress in quest title."]                  = "Muestra el progreso X/Y en el título de la misión."
L["Show objective progress bar"]                        = "Mostrar barra de progreso de objetivos"
L["Show a progress bar under objectives that have numeric progress (e.g. 3/250). Only applies to entries with a single arithmetic objective where the required amount is greater than 1."] = "Muestra una barra de progreso bajo objetivos con progreso numérico (ej. 3/250). Solo aplica a entradas con un solo objetivo aritmético donde la cantidad requerida es mayor que 1."
L["Use category color for progress bar"]                = "Usar color de categoría para la barra"
L["When on, the progress bar matches the quest/achievement category color. When off, uses the custom fill color below."] = "Activado: la barra usa el color de la categoría. Desactivado: usa el color personalizado de abajo."
L["Progress bar types"]                                 = "Tipos de barra de progreso"
L["Show progress bar for X/Y objectives, percent-only objectives, or both."] = "Mostrar barra para objetivos X/Y, solo porcentaje, o ambos."
L["X/Y: objectives like 3/10. Percent: objectives like 45%."] = "X/Y: objetivos como 3/10. Porcentaje: objetivos como 45%."
L["X/Y only"]                                           = "Solo X/Y"
L["Percent only"]                                       = "Solo porcentaje"
L["Use tick for completed objectives"]                  = "Usar marca para objetivos completados"
L["When on, completed objectives show a checkmark (✓) instead of green color."] = "Activado: los objetivos completados muestran una marca (✓) en lugar de color verde."
L["Show entry numbers"]                                 = "Mostrar numeración de entradas"
L["Prefix quest titles with 1., 2., 3. within each category."] = "Prefijar títulos de misiones con 1., 2., 3. en cada categoría."
L["Completed objectives"]                               = "Objetivos completados"
L["For multi-objective quests, how to display objectives you've completed (e.g. 1/1)."] = "Para misiones con varios objetivos, cómo mostrar los completados (ej. 1/1)."
L["Show all"]                                           = "Mostrar todo"
L["Fade completed"]                                     = "Atenuar completados"
L["Hide completed"]                                     = "Ocultar completados"
L["Show icon for in-zone auto-tracking"]                = "Mostrar icono de seguimiento automático en zona"
L["Display an icon next to auto-tracked world quests and weeklies/dailies that are not yet in your quest log (in-zone only)."] = "Muestra un icono junto a misiones de mundo y semanales/diarias con seguimiento automático que aún no están en tu registro (solo en zona)."
L["Auto-track icon"]                                    = "Icono de seguimiento automático"
L["Choose which icon to display next to auto-tracked in-zone entries."] = "Elige qué icono mostrar junto a las entradas con seguimiento automático en zona."
L["Append ** to world quests and weeklies/dailies that are not yet in your quest log (in-zone only)."] = "Añade ** a misiones de mundo y semanales/diarias que aún no están en tu registro (solo en zona)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["Compact mode"]                                       = "Modo compacto"
L["Preset: sets entry and objective spacing to 4 and 1 px."] = "Preajuste: espaciado de entradas y objetivos a 4 y 1 px."
L["Spacing between quest entries (px)"]                 = "Espaciado entre misiones (px)"
L["Vertical gap between quest entries."]                = "Espacio vertical entre misiones."
L["Spacing before category header (px)"]                = "Espaciado antes del encabezado (px)"
L["Gap between last entry of a group and the next category label."] = "Espacio entre la última entrada de un grupo y la siguiente etiqueta de categoría."
L["Spacing after category header (px)"]                 = "Espaciado después del encabezado (px)"
L["Gap between category label and first quest entry below it."] = "Espacio entre la etiqueta de categoría y la primera misión debajo."
L["Spacing between objectives (px)"]                    = "Espaciado entre objetivos (px)"
L["Vertical gap between objective lines within a quest."] = "Espacio vertical entre líneas de objetivos en una misión."
L["Spacing below header (px)"]                          = "Espaciado debajo del encabezado (px)"
L["Vertical gap between the objectives bar and the quest list."] = "Espacio entre la barra de objetivos y la lista de misiones."
L["Reset spacing"]                                      = "Restablecer espaciado"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["Show quest level"]                                   = "Mostrar nivel de misión"
L["Show quest level next to title."]                    = "Muestra el nivel de misión junto al título."
L["Dim non-focused quests"]                             = "Atenuar misiones no enfocadas"
L["Slightly dim title, zone, objectives, and section headers that are not focused."] = "Atenúa ligeramente títulos, zonas, objetivos y encabezados no enfocados."

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["Show rare bosses"]                                   = "Mostrar jefes raros"
L["Show rare boss vignettes in the list."]              = "Muestra los jefes raros en la lista."
L["Rare added sound"]                                   = "Sonido al añadir raro"
L["Play a sound when a rare is added."]                 = "Reproduce un sonido cuando se añade un raro."
L["Rare added sound choice"]                            = "Elección de sonido de raro"
L["Choose which sound to play when a rare boss appears. Requires LibSharedMedia sounds to be installed for extra options."] = "Elige qué sonido reproducir cuando aparece un jefe raro. Requiere sonidos LibSharedMedia para más opciones."

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["Show in-zone world quests"]                          = "Mostrar misiones de mundo en zona"
L["Auto-add world quests in your current zone. When off, only quests you've tracked or world quests you're in close proximity to appear (Blizzard default)."] = "Añade automáticamente misiones de mundo de tu zona. Desactivado: solo las que sigues o las cercanas (predeterminado Blizzard)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["Show floating quest item"]                           = "Mostrar objeto de misión flotante"
L["Show quick-use button for the focused quest's usable item."] = "Muestra el botón de uso rápido del objeto utilizable de la misión enfocada."
L["Lock floating quest item position"]                  = "Bloquear posición del objeto flotante"
L["Prevent dragging the floating quest item button."]   = "Impide arrastrar el botón del objeto de misión flotante."
L["Floating quest item source"]                         = "Origen del objeto flotante"
L["Which quest's item to show: super-tracked first, or current zone first."] = "Qué objeto mostrar: primero el super-seguido o primero el de zona actual."
L["Super-tracked, then first"]                          = "Super-seguido primero"
L["Current zone first"]                                 = "Zona actual primero"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["Show Mythic+ block"]                                 = "Mostrar bloque Mítico+"
L["Show timer, completion %, and affixes in Mythic+ dungeons."] = "Muestra temporizador, % de completado y afijos en mazmorras Mítico+."
L["M+ block position"]                                  = "Posición del bloque M+"
L["Position of the Mythic+ block relative to the quest list."] = "Posición del bloque M+ respecto a la lista de misiones."
L["Show affix icons"]                                    = "Mostrar iconos de afijos"
L["Show affix icons next to modifier names in the M+ block."] = "Muestra iconos de afijos junto a los nombres en el bloque M+."
L["Show affix descriptions in tooltip"]                  = "Descripciones de afijos en descripción"
L["Show affix descriptions when hovering over the M+ block."] = "Muestra descripciones de afijos al pasar el ratón sobre el bloque M+."
L["M+ completed boss display"]                         = "Visualización de jefes M+ completados"
L["How to show defeated bosses: checkmark icon or green color."] = "Cómo mostrar jefes derrotados: icono de marca o color verde."
L["Checkmark"]                                          = "Marca"
L["Green color"]                                        = "Color verde"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["Show achievements"]                                  = "Mostrar logros"
L["Show tracked achievements in the list."]             = "Muestra los logros seguidos en la lista."
L["Show completed achievements"]                        = "Mostrar logros completados"
L["Include completed achievements in the tracker. When off, only in-progress tracked achievements are shown."] = "Incluye logros completados. Desactivado: solo los seguidos en progreso."
L["Show achievement icons"]                             = "Mostrar iconos de logros"
L["Show each achievement's icon next to the title. Requires 'Show quest type icons' in Display."] = "Muestra el icono de cada logro junto al título. Requiere 'Mostrar iconos de tipo de misión' en Visualización."
L["Only show missing requirements"]                     = "Solo mostrar requisitos faltantes"
L["Show only criteria you haven't completed for each tracked achievement. When off, all criteria are shown."] = "Muestra solo los criterios no completados. Desactivado: se muestran todos."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["Show endeavors"]                                     = "Mostrar empeños"
L["Show tracked Endeavors (Player Housing) in the list."] = "Muestra los empeños seguidos (vivienda) en la lista."
L["Show completed endeavors"]                           = "Mostrar empeños completados"
L["Include completed Endeavors in the tracker. When off, only in-progress tracked Endeavors are shown."] = "Incluye empeños completados. Desactivado: solo los seguidos en progreso."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["Show decor"]                                         = "Mostrar decoración"
L["Show tracked housing decor in the list."]            = "Muestra la decoración de vivienda seguida en la lista."
L["Show decor icons"]                                   = "Mostrar iconos de decoración"
L["Show each decor item's icon next to the title. Requires 'Show quest type icons' in Display."] = "Muestra el icono de cada decoración junto al título. Requiere 'Mostrar iconos de tipo de misión' en Visualización."

-- =====================================================================
-- OptionsData.lua Features — Adventure Guide
-- =====================================================================
L["Adventure Guide"]                                    = "Guía de aventuras"
L["Show Traveler's Log"]                                = "Mostrar Diario del viajero"
L["Show tracked Traveler's Log objectives (Shift+click in Adventure Guide) in the list."] = "Muestra los objetivos seguidos del Diario del viajero (Mayús+clic en Guía de aventuras) en la lista."
L["Auto-remove completed activities"]                   = "Quitar automáticamente actividades completadas"
L["Automatically stop tracking Traveler's Log activities once they have been completed."] = "Deja de seguir automáticamente las actividades del Diario del viajero al completarlas."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["Show scenario events"]                               = "Mostrar eventos de escenario"
L["Show active scenario and Delve activities. Delves appear in DELVES; other scenarios in SCENARIO EVENTS."] = "Muestra escenarios y Simas activos. Las Simas aparecen en SIMAS; otros en EVENTOS DE ESCENARIO."
L["Track Delve, Dungeon, and scenario activities."]     = "Rastrear actividades de Simas, Mazmorras y escenarios."
L["Delves appear in Delves section; dungeons in Dungeon; other scenarios in Scenario Events."] = "Las Simas en SIMAS; las mazmorras en MAZMORRA; otros en EVENTOS DE ESCENARIO."
L["Hide other categories in Delve or Dungeon"]          = "Ocultar otras categorías en Sima o Mazmorra"
L["In Delves or party dungeons, show only the Delve/Dungeon section."] = "En Simas o mazmorras de grupo, muestra solo la sección correspondiente."
L["Use delve name as section header"]                    = "Usar nombre de Sima como encabezado"
L["When in a Delve, show the delve name, tier, and affixes as the section header instead of a separate banner. Disable to show the Delve block above the list."] = "En una Sima: muestra nombre, nivel y afijos en el encabezado. Desactivado: muestra el bloque encima de la lista."
L["Show affix names in Delves"]                         = "Mostrar nombres de afijos en Simas"
L["Show season affix names on the first Delve entry. Requires Blizzard's objective tracker widgets to be populated; may not show when using a full tracker replacement."] = "Muestra nombres de afijos de temporada en la primera entrada de Sima. Requiere widgets de Blizzard; puede no mostrarse con reemplazo completo."
L["Cinematic scenario bar"]                             = "Barra de escenario cinematográfica"
L["Show timer and progress bar for scenario entries."]  = "Muestra temporizador y barra de progreso para escenarios."
L["Show timer"]                                         = "Mostrar temporizador"
L["Show countdown timer on timed quests, events, and scenarios. When off, timers are hidden for all entry types."] = "Muestra cuenta atrás en misiones, eventos y escenarios con tiempo. Desactivado: se ocultan todos los temporizadores."
L["Timer display"]                                      = "Visualización del temporizador"
L["Color timer by remaining time"]                      = "Colorear temporizador por tiempo restante"
L["Green when plenty of time left, yellow when running low, red when critical."] = "Verde con tiempo de sobra, amarillo cuando queda poco, rojo cuando es crítico."
L["Where to show the countdown: bar below objectives or text beside the quest name."] = "Dónde mostrar la cuenta atrás: barra bajo objetivos o texto junto al nombre de la misión."
L["Bar below"]                                          = "Barra debajo"
L["Inline beside title"]                                = "Texto junto al título"
L["Show countdown timer bars on timed quests, events, and scenarios. When off, timer bars are hidden for all entry types."] = "Muestra barras de cuenta atrás en misiones, eventos y escenarios con tiempo. Desactivado: se ocultan para todos los tipos."

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["Font family."]                                       = "Familia de fuente."
L["Title font"]                                         = "Fuente de títulos"
L["Zone font"]                                          = "Fuente de zonas"
L["Objective font"]                                     = "Fuente de objetivos"
L["Section font"]                                       = "Fuente de secciones"
L["Use global font"]                                    = "Usar fuente global"
L["Font family for quest titles."]                     = "Familia de fuente para títulos de misiones."
L["Font family for zone labels."]                       = "Familia de fuente para etiquetas de zona."
L["Font family for objective text."]                    = "Familia de fuente para texto de objetivos."
L["Font family for section headers."]                   = "Familia de fuente para encabezados de sección."
L["Header size"]                                        = "Tamaño del encabezado"
L["Header font size."]                                  = "Tamaño de fuente del encabezado."
L["Title size"]                                         = "Tamaño del título"
L["Quest title font size."]                             = "Tamaño de fuente de títulos de misiones."
L["Objective size"]                                     = "Tamaño de objetivos"
L["Objective text font size."]                          = "Tamaño de fuente del texto de objetivos."
L["Zone size"]                                          = "Tamaño de zonas"
L["Zone label font size."]                              = "Tamaño de fuente de etiquetas de zona."
L["Section size"]                                       = "Tamaño de secciones"
L["Section header font size."]                          = "Tamaño de fuente de encabezados de sección."
L["Progress bar font"]                                  = "Fuente de la barra de progreso"
L["Font family for the progress bar label."]            = "Familia de fuente para la etiqueta de la barra de progreso."
L["Progress bar text size"]                             = "Tamaño del texto de la barra de progreso"
L["Font size for the progress bar label. Also adjusts bar height. Affects quest objectives, scenario progress, and scenario timer bars."] = "Tamaño de fuente de la barra de progreso. También ajusta la altura. Afecta objetivos de misiones, progreso de escenarios y barras de temporizador."
L["Progress bar fill"]                                  = "Relleno de la barra de progreso"
L["Progress bar text"]                                  = "Texto de la barra de progreso"
L["Outline"]                                            = "Contorno"
L["Font outline style."]                                = "Estilo de contorno de fuente."

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["Header text case"]                                   = "Mayúsculas del encabezado"
L["Display case for header."]                           = "Mayúsculas para el encabezado."
L["Section header case"]                                = "Mayúsculas de encabezados de sección"
L["Display case for category labels."]                  = "Mayúsculas para etiquetas de categoría."
L["Quest title case"]                                   = "Mayúsculas de títulos de misiones"
L["Display case for quest titles."]                     = "Mayúsculas para títulos de misiones."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["Show text shadow"]                                   = "Mostrar sombra de texto"
L["Enable drop shadow on text."]                        = "Activa la sombra del texto."
L["Shadow X"]                                           = "Sombra X"
L["Horizontal shadow offset."]                          = "Desplazamiento horizontal de la sombra."
L["Shadow Y"]                                           = "Sombra Y"
L["Vertical shadow offset."]                            = "Desplazamiento vertical de la sombra."
L["Shadow alpha"]                                       = "Opacidad de la sombra"
L["Shadow opacity (0–1)."]                             = "Opacidad de la sombra (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["Mythic+ Typography"]                                  = "Tipografía Mítico+"
L["Dungeon name size"]                                   = "Tamaño del nombre de mazmorra"
L["Font size for dungeon name (8–32 px)."]              = "Tamaño de fuente del nombre de mazmorra (8–32 px)."
L["Dungeon name color"]                                  = "Color del nombre de mazmorra"
L["Text color for dungeon name."]                       = "Color del texto del nombre de mazmorra."
L["Timer size"]                                         = "Tamaño del temporizador"
L["Font size for timer (8–32 px)."]                     = "Tamaño de fuente del temporizador (8–32 px)."
L["Timer color"]                                        = "Color del temporizador"
L["Text color for timer (in time)."]                    = "Color del temporizador (dentro del tiempo)."
L["Timer overtime color"]                               = "Color del temporizador (tiempo excedido)"
L["Text color for timer when over the time limit."]      = "Color del temporizador cuando se excede el tiempo."
L["Progress size"]                                      = "Tamaño del progreso"
L["Font size for enemy forces (8–32 px)."]               = "Tamaño de fuente de fuerzas enemigas (8–32 px)."
L["Progress color"]                                     = "Color del progreso"
L["Text color for enemy forces."]                       = "Color del texto de fuerzas enemigas."
L["Bar fill color"]                                     = "Color de relleno de la barra"
L["Progress bar fill color (in progress)."]             = "Color de relleno de la barra (en progreso)."
L["Bar complete color"]                                 = "Color de barra completada"
L["Progress bar fill color when enemy forces are at 100%."] = "Color de relleno cuando las fuerzas enemigas están al 100%."
L["Affix size"]                                         = "Tamaño de afijos"
L["Font size for affixes (8–32 px)."]                   = "Tamaño de fuente de afijos (8–32 px)."
L["Affix color"]                                        = "Color de afijos"
L["Text color for affixes."]                            = "Color del texto de afijos."
L["Boss size"]                                          = "Tamaño de nombres de jefes"
L["Font size for boss names (8–32 px)."]                = "Tamaño de fuente de nombres de jefes (8–32 px)."
L["Boss color"]                                         = "Color de nombres de jefes"
L["Text color for boss names."]                         = "Color del texto de nombres de jefes."
L["Reset Mythic+ typography"]                           = "Restablecer tipografía M+"

-- =====================================================================
-- OptionsData.lua Appearance
-- =====================================================================
L["Backdrop opacity"]                                   = "Opacidad del fondo"
L["Panel background opacity (0–1)."]                    = "Opacidad del fondo del panel (0–1)."
L["Show border"]                                        = "Mostrar borde"
L["Show border around the tracker."]                    = "Muestra un borde alrededor del rastreador."
L["Show scroll indicator"]                              = "Mostrar indicador de desplazamiento"
L["Show a visual hint when the list has more content than is visible."] = "Muestra una pista visual cuando la lista tiene más contenido del visible."
L["Scroll indicator style"]                             = "Estilo del indicador de desplazamiento"
L["Choose between a fade-out gradient or a small arrow to indicate scrollable content."] = "Elige entre un degradado o una flecha pequeña para indicar contenido desplazable."
L["Arrow"]                                              = "Flecha"
L["Highlight alpha"]                                    = "Opacidad del resaltado"
L["Opacity of focused quest highlight (0–1)."]          = "Opacidad del resaltado de misión enfocada (0–1)."
L["Bar width"]                                          = "Ancho de la barra"
L["Width of bar-style highlights (2–6 px)."]           = "Ancho de las barras de resaltado (2–6 px)."

-- =====================================================================
-- OptionsData.lua Organization
-- =====================================================================
L["Focus category order"]                               = "Orden de categorías de Enfoque"
L["Drag to reorder categories. DELVES and SCENARIO EVENTS stay first."] = "Arrastra para reordenar. SIMAS y EVENTOS DE ESCENARIO permanecen primero."
L["Focus sort mode"]                                    = "Modo de ordenación de Enfoque"
L["Order of entries within each category."]             = "Orden de entradas dentro de cada categoría."
L["Auto-track accepted quests"]                         = "Seguir automáticamente misiones aceptadas"
L["When you accept a quest (quest log only, not world quests), add it to the tracker automatically."] = "Al aceptar una misión (solo registro, no misiones de mundo), la añade al rastreador automáticamente."
L["Require Ctrl for focus & remove"]                    = "Requerir Ctrl para enfocar y quitar"
L["Require Ctrl for focus/add (Left) and unfocus/untrack (Right) to prevent misclicks."] = "Requiere Ctrl para enfocar (clic izquierdo) y quitar (clic derecho) para evitar clics accidentales."
L["Use classic click behaviour"]                             = "Usar comportamiento de clic clásico"
L["Share with party"]                                        = "Compartir con el grupo"
L["Abandon quest"]                                           = "Abandonar misión"
L["Stop tracking"]                                           = "Dejar de seguir"
L["This quest cannot be shared."]                             = "Esta misión no se puede compartir."
L["You must be in a party to share this quest."]              = "Debes estar en un grupo para compartir esta misión."
L["When on, left-click opens the quest map and right-click shows share/abandon menu (Blizzard-style). When off, left-click focuses and right-click untracks; Ctrl+Right shares with party."] = "Activado: clic izquierdo abre el mapa de misión, clic derecho muestra menú compartir/abandonar (estilo Blizzard). Desactivado: clic izquierdo enfoca, clic derecho deja de seguir; Ctrl+Clic derecho comparte con el grupo."
L["Animations"]                                         = "Animaciones"
L["Enable slide and fade for quests."]                  = "Activa deslizamiento y fundido para misiones."
L["Objective progress flash"]                           = "Destello de progreso de objetivo"
L["Show flash when an objective completes."]             = "Muestra un destello cuando se completa un objetivo."
L["Flash intensity"]                                    = "Intensidad del destello"
L["How noticeable the objective-complete flash is."]    = "Qué tan notable es el destello al completar un objetivo."
L["Flash color"]                                        = "Color del destello"
L["Color of the objective-complete flash."]             = "Color del destello al completar un objetivo."
L["Subtle"]                                             = "Sutil"
L["Medium"]                                             = "Medio"
L["Strong"]                                             = "Fuerte"
L["Require Ctrl for click to complete"]                 = "Requerir Ctrl para clic y completar"
L["When on, requires Ctrl+Left-click to complete auto-complete quests. When off, plain Left-click completes them (Blizzard default). Only affects quests that can be completed by click (no NPC turn-in needed)."] = "Activado: requiere Ctrl+Clic izquierdo para completar. Desactivado: un simple clic izquierdo (predeterminado Blizzard). Solo afecta misiones completables por clic."
L["Suppress untracked until reload"]                     = "Ocultar no seguidas hasta recargar"
L["When on, right-click untrack on world quests and in-zone weeklies/dailies hides them until you reload or start a new session. When off, they reappear when you return to the zone."] = "Activado: dejar de seguir oculta hasta recargar. Desactivado: reaparecen al volver a la zona."
L["Permanently suppress untracked quests"]               = "Ocultar permanentemente misiones no seguidas"
L["When on, right-click untracked world quests and in-zone weeklies/dailies are hidden permanently (persists across reloads). Takes priority over 'Suppress until reload'. Accepting a suppressed quest removes it from the blacklist."] = "Activado: las no seguidas se ocultan permanentemente. Tiene prioridad sobre 'Ocultar hasta recargar'. Aceptar una oculta la quita de la lista negra."
L["Keep campaign quests in category"]                    = "Mantener misiones de campaña en categoría"
L["When on, campaign quests that are ready to turn in remain in the Campaign category instead of moving to Complete."] = "Activado: las misiones de campaña listas para entregar permanecen en Campaña en lugar de pasar a Completadas."
L["Keep important quests in category"]                   = "Mantener misiones importantes en categoría"
L["When on, important quests that are ready to turn in remain in the Important category instead of moving to Complete."] = "Activado: las misiones importantes listas para entregar permanecen en Importante en lugar de pasar a Completadas."
L["TomTom quest waypoint"]                               = "Punto de referencia TomTom"
L["Set a TomTom waypoint when focusing a quest."]        = "Establecer un punto de referencia TomTom al enfocar una misión."
L["Requires TomTom. Points the arrow to the next quest objective."] = "Requiere TomTom. Apunta la flecha al siguiente objetivo de misión."

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
L["Blacklisted quests"]                                  = "Misiones en lista negra"
L["Permanently suppressed quests"]                       = "Misiones ocultas permanentemente"
L["Right-click untrack quests with 'Permanently suppress untracked quests' enabled to add them here."] = "Clic derecho para dejar de seguir con 'Ocultar permanentemente' activado para añadirlas aquí."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["Show quest type icons"]                              = "Mostrar iconos de tipo de misión"
L["Show quest type icon in the Focus tracker (quest accept/complete, world quest, quest update)."] = "Muestra en el rastreador: misión aceptada/completada, misión de mundo, actualización de misión."
L["Show quest type icons on toasts"]                    = "Mostrar iconos de tipo de misión en notificaciones"
L["Show quest type icon on Presence toasts (quest accept/complete, world quest, quest update)."] = "Muestra el icono de tipo de misión en notificaciones: aceptada/completada, misión de mundo, actualización."
L["Toast icon size"]                                    = "Tamaño de iconos en notificaciones"
L["Quest icon size on Presence toasts (16–36 px). Default 24."] = "Tamaño de iconos de misión en notificaciones (16–36 px). Por defecto 24."
L["Hide quest update title"]                            = "Ocultar título en avances de misión"
L["Show only the objective line on quest progress toasts (e.g. 7/10 Boar Pelts), without the quest name or header."] = "Muestra solo la línea de objetivo (ej. 7/10 Pieles de jabalí) sin el nombre de misión ni encabezado."
L["Show discovery line"]                                = "Mostrar línea de descubrimiento"
L["Show 'Discovered' under zone/subzone when entering a new area."] = "Muestra 'Descubierto' bajo zona/subzona al entrar en un área nueva."
L["Frame vertical position"]                            = "Posición vertical del marco"
L["Vertical offset of the Presence frame from center (-300 to 0)."] = "Desplazamiento vertical del marco Presencia desde el centro (-300 a 0)."
L["Frame scale"]                                        = "Escala del marco"
L["Scale of the Presence frame (0.5–2)."]              = "Escala del marco Presencia (0.5–2)."
L["Boss emote color"]                                   = "Color de emotes de jefes"
L["Color of raid and dungeon boss emote text."]          = "Color del texto de emotes de jefes en banda y mazmorra."
L["Discovery line color"]                               = "Color de la línea de descubrimiento"
L["Color of the 'Discovered' line under zone text."]    = "Color de la línea 'Descubierto' bajo el texto de zona."
L["Notification types"]                                 = "Tipos de notificación"
L["Show zone entry"]                                    = "Mostrar entrada en zona"
L["Show zone change when entering a new area."]         = "Muestra notificación al entrar en un área nueva."
L["Show subzone changes"]                               = "Mostrar cambios de subzona"
L["Show subzone change when moving within the same zone."] = "Muestra notificación al moverse entre subzonas en la misma zona."
L["Hide zone name for subzone changes"]                 = "Ocultar nombre de zona para cambios de subzona"
L["When moving between subzones within the same zone, only show the subzone name. The zone name still appears when entering a new zone."] = "Al moverse entre subzonas, solo muestra el nombre de subzona. El nombre de zona aparece al entrar en una zona nueva."
L["Suppress zone changes in Mythic+"]                   = "Suprimir cambios de zona en Mítico+"
L["In Mythic+, only show boss emotes, achievements, and level-up. Hide zone, quest, and scenario notifications."] = "En Mítico+, solo muestra emotes de jefes, logros y subida de nivel. Oculta notificaciones de zona, misión y escenario."
L["Show level up"]                                      = "Mostrar subida de nivel"
L["Show level-up notification."]                        = "Muestra la notificación de subida de nivel."
L["Show boss emotes"]                                   = "Mostrar emotes de jefes"
L["Show raid and dungeon boss emote notifications."]    = "Muestra notificaciones de emotes de jefes en banda y mazmorra."
L["Show achievements"]                                  = "Mostrar logros"
L["Show achievement earned notifications."]             = "Muestra notificaciones de logros obtenidos."
L["Achievement progress"]                               = "Progreso de logros"
L["Show notification when tracked achievement criteria update."] = "Muestra notificación cuando se actualizan los criterios de un logro rastreado."
L["Show quest accept"]                                  = "Mostrar aceptación de misión"
L["Show notification when accepting a quest."]          = "Muestra notificación al aceptar una misión."
L["Show world quest accept"]                            = "Mostrar aceptación de misión de mundo"
L["Show notification when accepting a world quest."]    = "Muestra notificación al aceptar una misión de mundo."
L["Show quest complete"]                                = "Mostrar misión completada"
L["Show notification when completing a quest."]         = "Muestra notificación al completar una misión."
L["Show world quest complete"]                         = "Mostrar misión de mundo completada"
L["Show notification when completing a world quest."]   = "Muestra notificación al completar una misión de mundo."
L["Show quest progress"]                                = "Mostrar progreso de misiones"
L["Show notification when quest objectives update."]    = "Muestra notificación cuando se actualizan los objetivos."
L["Objective only"]                                     = "Solo objetivo"
L["Show only the objective line on quest progress toasts, hiding the 'Quest Update' title."] = "Muestra solo la línea del objetivo en las notificaciones de progreso, ocultando el título 'Actualización de misión'."
L["Show scenario start"]                                = "Mostrar inicio de escenario"
L["Show notification when entering a scenario or Delve."] = "Muestra notificación al entrar en un escenario o Sima."
L["Show scenario progress"]                             = "Mostrar progreso de escenario"
L["Show notification when scenario or Delve objectives update."] = "Muestra notificación cuando se actualizan objetivos de escenario o Sima."
L["Animation"]                                          = "Animación"
L["Enable animations"]                                  = "Activar animaciones"
L["Enable entrance and exit animations for Presence notifications."] = "Activa animaciones de entrada y salida para notificaciones."
L["Entrance duration"]                                  = "Duración de entrada"
L["Duration of the entrance animation in seconds (0.2–1.5)."] = "Duración de la animación de entrada en segundos (0.2–1.5)."
L["Exit duration"]                                      = "Duración de salida"
L["Duration of the exit animation in seconds (0.2–1.5)."] = "Duración de la animación de salida en segundos (0.2–1.5)."
L["Hold duration scale"]                                = "Factor de duración de visualización"
L["Multiplier for how long each notification stays on screen (0.5–2)."] = "Multiplicador de cuánto tiempo permanece cada notificación en pantalla (0.5–2)."
L["Typography"]                                         = "Tipografía"
L["Main title font"]                                    = "Fuente del título principal"
L["Font family for the main title."]                     = "Familia de fuente para el título principal."
L["Subtitle font"]                                      = "Fuente del subtítulo"
L["Font family for the subtitle."]                      = "Familia de fuente para el subtítulo."
L["Main title size"]                                    = "Tamaño del título principal"
L["Font size for the main title (24–72 px)."]           = "Tamaño de fuente del título principal (24–72 px)."
L["Subtitle size"]                                      = "Tamaño del subtítulo"
L["Font size for the subtitle (12–40 px)."]             = "Tamaño de fuente del subtítulo (12–40 px)."

-- =====================================================================
-- OptionsData.lua Dropdown options — Outline
-- =====================================================================
L["None"]                                               = "Ninguno"
L["Thick Outline"]                                      = "Contorno grueso"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["Bar (left edge)"]                                    = "Barra (borde izquierdo)"
L["Bar (right edge)"]                                   = "Barra (borde derecho)"
L["Bar (top edge)"]                                     = "Barra (borde superior)"
L["Bar (bottom edge)"]                                  = "Barra (borde inferior)"
L["Outline only"]                                       = "Solo contorno"
L["Soft glow"]                                          = "Brillo suave"
L["Dual edge bars"]                                     = "Barras dobles"
L["Pill left accent"]                                   = "Acento píldora izquierdo"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["Top"]                                                = "Arriba"
L["Bottom"]                                             = "Abajo"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["Location position"]                                  = "Posición del nombre de zona"
L["Place the zone name above or below the minimap."]     = "Coloca el nombre de zona encima o debajo del minimapa."
L["Coordinates position"]                               = "Posición de coordenadas"
L["Place the coordinates above or below the minimap."]   = "Coloca las coordenadas encima o debajo del minimapa."
L["Clock position"]                                     = "Posición del reloj"
L["Place the clock above or below the minimap."]         = "Coloca el reloj encima o debajo del minimapa."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["Lower Case"]                                         = "Minúsculas"
L["Upper Case"]                                         = "Mayúsculas"
L["Proper"]                                             = "Primera letra mayúscula"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["Tracked / in log"]                                   = "Seguidas / En registro"
L["In log / max slots"]                                 = "En registro / Máx. ranuras"

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["Alphabetical"]                                       = "Alfabético"
L["Quest Type"]                                         = "Tipo de misión"
L["Quest Level"]                                        = "Nivel de misión"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["Custom"]                                             = "Personalizado"
L["Order"]                                              = "Orden"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["DUNGEON"]           = "MAZMORRA"
L["RAID"]              = "BANDA"
L["DELVES"]            = "SIMAS"
L["SCENARIO EVENTS"]   = "EVENTOS DE ESCENARIO"
L["AVAILABLE IN ZONE"] = "DISPONIBLE EN LA ZONA"
L["EVENTS IN ZONE"] = "Eventos en la zona"
L["CURRENT EVENT"] = "Evento actual"
L["CURRENT QUEST"]     = "MISIÓN ACTUAL"
L["CURRENT ZONE"]      = "ZONA ACTUAL"
L["CAMPAIGN"]          = "CAMPAÑA"
L["IMPORTANT"]         = "IMPORTANTE"
L["LEGENDARY"]         = "LEGENDARIA"
L["WORLD QUESTS"]      = "MISIONES DE MUNDO"
L["WEEKLY QUESTS"]     = "MISIONES SEMANALES"
L["DAILY QUESTS"]      = "MISIONES DIARIAS"
L["RARE BOSSES"]       = "JEFES RAROS"
L["ACHIEVEMENTS"]      = "LOGROS"
L["ENDEAVORS"]         = "EMPEÑOS"
L["DECOR"]             = "DECORACIÓN"
L["QUESTS"]            = "MISIONES"
L["READY TO TURN IN"]  = "LISTAS PARA ENTREGAR"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["OBJECTIVES"]                                                                                    = "OBJETIVOS"
L["Options"]                                                                                       = "Opciones"
L["Discovered"]                                                                                    = "Descubierto"
L["Refresh"]                                                                                       = "Actualizar"
L["Best-effort only. Some unaccepted quests are not exposed until you interact with NPCs or meet phasing conditions."] = "Solo aproximado. Algunas misiones no aceptadas no aparecen hasta interactuar con PNJs o cumplir condiciones de fase."
L["Unaccepted Quests - %s (map %s) - %d match(es)"]                                                  = "Misiones no aceptadas - %s (mapa %s) - %d coincidencia(s)"

L["LEVEL UP"]                                                                                      = "SUBIDA DE NIVEL"
L["You have reached level 80"]                                                                     = "Has alcanzado el nivel 80"
L["You have reached level %s"]                                                                     = "Has alcanzado el nivel %s"
L["ACHIEVEMENT EARNED"]                                                                            = "LOGRO OBTENIDO"
L["Exploring the Midnight Isles"]                                                                  = "Explorando las Islas de Medianoche"
L["Exploring Khaz Algar"]                                                                          = "Explorando Khaz Algar"
L["QUEST COMPLETE"]                                                                                = "MISIÓN COMPLETADA"
L["Objective Secured"]                                                                             = "Objetivo asegurado"
L["Aiding the Accord"]                                                                             = "Ayudando al Acuerdo"
L["WORLD QUEST"]                                                                                   = "MISIÓN DE MUNDO"
L["Azerite Mining"]                                                                                = "Minería de azerita"
L["WORLD QUEST ACCEPTED"]                                                                          = "MISIÓN DE MUNDO ACEPTADA"
L["QUEST ACCEPTED"]                                                                                = "MISIÓN ACEPTADA"
L["The Fate of the Horde"]                                                                         = "El Destino de la Horda"
L["New Quest"]                                                                                     = "Nueva misión"
L["QUEST UPDATE"]                                                                                  = "ACTUALIZACIÓN DE MISIÓN"
L["Boar Pelts: 7/10"]                                                                              = "Pieles de jabalí: 7/10"
L["Dragon Glyphs: 3/5"]                                                                            = "Glifos de dragón: 3/5"

L["Presence test commands:"]                                                                       = "Comandos de prueba de Presencia:"
L["  /h presence         - Show help + test current zone"]                                   = "  /h presence         - Mostrar ayuda + probar zona actual"
L["  /h presence zone     - Test Zone Change"]                                               = "  /h presence zone     - Probar cambio de zona"
L["  /h presence subzone  - Test Subzone Change"]                                            = "  /h presence subzone  - Probar cambio de subzona"
L["  /h presence discover - Test Zone Discovery"]                                            = "  /h presence discover - Probar descubrimiento de zona"
L["  /h presence level    - Test Level Up"]                                                  = "  /h presence level    - Probar subida de nivel"
L["  /h presence boss     - Test Boss Emote"]                                                = "  /h presence boss     - Probar emote de jefe"
L["  /h presence ach      - Test Achievement"]                                               = "  /h presence ach      - Probar logro"
L["  /h presence accept   - Test Quest Accepted"]                                              = "  /h presence accept   - Probar misión aceptada"
L["  /h presence wqaccept - Test World Quest Accepted"]                                       = "  /h presence wqaccept - Probar misión de mundo aceptada"
L["  /h presence scenario - Test Scenario Start"]                                            = "  /h presence scenario - Probar inicio de escenario"
L["  /h presence quest    - Test Quest Complete"]                                             = "  /h presence quest    - Probar misión completada"
L["  /h presence wq       - Test World Quest"]                                                = "  /h presence wq       - Probar misión de mundo"
L["  /h presence update   - Test Quest Update"]                                                = "  /h presence update   - Probar actualización de misión"
L["  /h presence achprogress - Test Achievement Progress"]                                     = "  /h presence achprogress - Probar progreso de logro"
L["  /h presence all      - Demo reel (all types)"]                                          = "  /h presence all      - Demostración (todos los tipos)"
L["  /h presence debug    - Dump state to chat"]                                             = "  /h presence debug    - Volcar estado al chat"
L["  /h presence debuglive - Toggle live debug panel (log as events happen)"]                = "  /h presence debuglive - Activar/desactivar panel de depuración en vivo (registrar eventos)"

-- =====================================================================
-- OptionsData.lua Vista — General
-- =====================================================================
L["Minimap"]                                                        = "Minimapa"
L["Minimap size"]                                                   = "Tamaño del minimapa"
L["Width and height of the minimap in pixels (100–400)."]           = "Ancho y alto del minimapa en píxeles (100–400)."
L["Circular minimap"]                                               = "Minimapa circular"
L["Use a circular minimap instead of square."]                      = "Usa un minimapa circular en lugar de cuadrado."
L["Lock minimap position"]                                          = "Bloquear posición del minimapa"
L["Prevent dragging the minimap."]                                  = "Impide arrastrar el minimapa."
L["Reset minimap position"]                                         = "Restablecer posición del minimapa"
L["Reset minimap to its default position (top-right)."]              = "Restablece el minimapa a su posición por defecto (arriba derecha)."
L["Auto Zoom"]                                                      = "Zoom automático"
L["Auto zoom-out delay"]                                            = "Retraso de zoom automático"
L["Seconds after zooming before auto zoom-out fires. Set to 0 to disable."] = "Segundos tras hacer zoom antes del zoom automático. Pon 0 para desactivar."

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["Zone Text"]                                                      = "Texto de zona"
L["Zone font"]                                                      = "Fuente de zona"
L["Font for the zone name below the minimap."]                      = "Fuente del nombre de zona debajo del minimapa."
L["Zone font size"]                                                 = "Tamaño de fuente de zona"
L["Zone text color"]                                                = "Color del texto de zona"
L["Color of the zone name text."]                                   = "Color del texto del nombre de zona."
L["Coordinates Text"]                                               = "Texto de coordenadas"
L["Coordinates font"]                                               = "Fuente de coordenadas"
L["Font for the coordinates text below the minimap."]               = "Fuente del texto de coordenadas debajo del minimapa."
L["Coordinates font size"]                                          = "Tamaño de fuente de coordenadas"
L["Coordinates text color"]                                         = "Color del texto de coordenadas"
L["Color of the coordinates text."]                                 = "Color del texto de coordenadas."
L["Coordinate precision"]                                           = "Precisión de coordenadas"
L["Number of decimal places shown for X and Y coordinates."]        = "Número de decimales mostrados para coordenadas X e Y."
L["No decimals (e.g. 52, 37)"]                                      = "Sin decimales (ej. 52, 37)"
L["1 decimal (e.g. 52.3, 37.1)"]                                    = "1 decimal (ej. 52.3, 37.1)"
L["2 decimals (e.g. 52.34, 37.12)"]                                 = "2 decimales (ej. 52.34, 37.12)"
L["Time Text"]                                                      = "Texto de hora"
L["Time font"]                                                      = "Fuente de hora"
L["Font for the time text below the minimap."]                      = "Fuente del texto de hora debajo del minimapa."
L["Time font size"]                                                 = "Tamaño de fuente de hora"
L["Time text color"]                                                = "Color del texto de hora"
L["Color of the time text."]                                        = "Color del texto de hora."
L["Difficulty Text"]                                                = "Texto de dificultad"
L["Difficulty text color (fallback)"]                               = "Color del texto de dificultad (reserva)"
L["Default color when no per-difficulty color is set."]             = "Color por defecto cuando no hay color por dificultad."
L["Difficulty font"]                                                = "Fuente de dificultad"
L["Font for the instance difficulty text."]                         = "Fuente del texto de dificultad de instancia."
L["Difficulty font size"]                                          = "Tamaño de fuente de dificultad"
L["Per-Difficulty Colors"]                                          = "Colores por dificultad"
L["Mythic color"]                                                   = "Color Mítico"
L["Color for Mythic difficulty text."]                              = "Color del texto de dificultad Mítico."
L["Heroic color"]                                                   = "Color Heroico"
L["Color for Heroic difficulty text."]                              = "Color del texto de dificultad Heroico."
L["Normal color"]                                                   = "Color Normal"
L["Color for Normal difficulty text."]                              = "Color del texto de dificultad Normal."
L["LFR color"]                                                      = "Color LFR"
L["Color for Looking For Raid difficulty text."]                    = "Color del texto de dificultad Búsqueda de banda."

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["Text Elements"]                                                  = "Elementos de texto"
L["Show zone text"]                                                 = "Mostrar texto de zona"
L["Show the zone name below the minimap."]                          = "Muestra el nombre de zona debajo del minimapa."
L["Zone text display mode"]                                         = "Modo de visualización del texto de zona"
L["What to show: zone only, subzone only, or both."]                = "Qué mostrar: solo zona, solo subzona o ambos."
L["Zone only"]                                                      = "Solo zona"
L["Subzone only"]                                                   = "Solo subzona"
L["Both"]                                                           = "Ambos"
L["Show coordinates"]                                               = "Mostrar coordenadas"
L["Show player coordinates below the minimap."]                     = "Muestra las coordenadas del jugador debajo del minimapa."
L["Show time"]                                                      = "Mostrar hora"
L["Show current game time below the minimap."]                      = "Muestra la hora actual del juego debajo del minimapa."
L["Use local time"]                                                 = "Usar hora local"
L["When on, shows your local system time. When off, shows server time."] = "Activado: muestra la hora local del sistema. Desactivado: muestra la hora del servidor."
L["Minimap Buttons"]                                                = "Botones del minimapa"
L["Queue status and mail indicator are always shown when relevant."] = "El estado de cola y el indicador de correo se muestran cuando son relevantes."
L["Show tracking button"]                                           = "Mostrar botón de seguimiento"
L["Show the minimap tracking button."]                              = "Muestra el botón de seguimiento en el minimapa."
L["Tracking button on mouseover only"]                              = "Botón de seguimiento solo al pasar el ratón"
L["Hide tracking button until you hover over the minimap."]         = "Oculta el botón de seguimiento hasta pasar el ratón sobre el minimapa."
L["Show calendar button"]                                           = "Mostrar botón de calendario"
L["Show the minimap calendar button."]                              = "Muestra el botón de calendario en el minimapa."
L["Calendar button on mouseover only"]                              = "Botón de calendario solo al pasar el ratón"
L["Hide calendar button until you hover over the minimap."]         = "Oculta el botón de calendario hasta pasar el ratón sobre el minimapa."
L["Show zoom buttons"]                                              = "Mostrar botones de zoom"
L["Show the + and - zoom buttons on the minimap."]                  = "Muestra los botones de zoom + y - en el minimapa."
L["Zoom buttons on mouseover only"]                                 = "Botones de zoom solo al pasar el ratón"
L["Hide zoom buttons until you hover over the minimap."]            = "Oculta los botones de zoom hasta pasar el ratón sobre el minimapa."

-- =====================================================================
-- OptionsData.lua Vista — Display (Border / Text Positions / Buttons)
-- =====================================================================
L["Border"]                                                         = "Borde"
L["Show a border around the minimap."]                              = "Muestra un borde alrededor del minimapa."
L["Border color"]                                                   = "Color del borde"
L["Color (and opacity) of the minimap border."]                     = "Color (y opacidad) del borde del minimapa."
L["Border thickness"]                                               = "Grosor del borde"
L["Thickness of the minimap border in pixels (1–8)."]               = "Grosor del borde del minimapa en píxeles (1–8)."
L["Text Positions"]                                                 = "Posiciones del texto"
L["Drag text elements to reposition them. Lock to prevent accidental movement."] = "Arrastra elementos de texto para reposicionarlos. Bloquea para evitar movimientos accidentales."
L["Lock zone text position"]                                        = "Bloquear posición del texto de zona"
L["When on, the zone text cannot be dragged."]                      = "Activado: el texto de zona no se puede arrastrar."
L["Lock coordinates position"]                                      = "Bloquear posición de coordenadas"
L["When on, the coordinates text cannot be dragged."]                = "Activado: el texto de coordenadas no se puede arrastrar."
L["Lock time position"]                                             = "Bloquear posición de la hora"
L["When on, the time text cannot be dragged."]                      = "Activado: el texto de hora no se puede arrastrar."
L["Lock difficulty text position"]                                  = "Bloquear posición del texto de dificultad"
L["When on, the difficulty text cannot be dragged."]                = "Activado: el texto de dificultad no se puede arrastrar."
L["Button Positions"]                                               = "Posiciones de botones"
L["Drag buttons to reposition them. Lock to prevent movement."]     = "Arrastra botones para reposicionarlos. Bloquea para impedir movimiento."
L["Lock Zoom In button"]                                            = "Bloquear botón Zoom +"
L["Prevent dragging the + zoom button."]                            = "Impide arrastrar el botón de zoom +."
L["Lock Zoom Out button"]                                           = "Bloquear botón Zoom -"
L["Prevent dragging the - zoom button."]                            = "Impide arrastrar el botón de zoom -."
L["Lock Tracking button"]                                           = "Bloquear botón de seguimiento"
L["Prevent dragging the tracking button."]                          = "Impide arrastrar el botón de seguimiento."
L["Lock Calendar button"]                                           = "Bloquear botón de calendario"
L["Prevent dragging the calendar button."]                          = "Impide arrastrar el botón de calendario."
L["Lock Queue button"]                                              = "Bloquear botón de cola"
L["Prevent dragging the queue status button."]                      = "Impide arrastrar el botón de estado de cola."
L["Disable queue button handling"]                                  = "Desactivar gestión del botón de cola"
L["Turn off all queue button anchoring (use if another addon manages it)."] = "Desactiva todo el anclaje del botón de cola (usa si otro addon lo gestiona)."
L["Button Sizes"]                                                   = "Tamaños de botones"
L["Adjust the size of minimap overlay buttons."]                    = "Ajusta el tamaño de los botones superpuestos del minimapa."
L["Tracking button size"]                                           = "Tamaño del botón de seguimiento"
L["Size of the tracking button (pixels)."]                          = "Tamaño del botón de seguimiento (píxeles)."
L["Calendar button size"]                                            = "Tamaño del botón de calendario"
L["Size of the calendar button (pixels)."]                          = "Tamaño del botón de calendario (píxeles)."
L["Queue button size"]                                              = "Tamaño del botón de cola"
L["Size of the queue status button (pixels)."]                      = "Tamaño del botón de estado de cola (píxeles)."
L["Zoom button size"]                                               = "Tamaño de los botones de zoom"
L["Size of the zoom in / zoom out buttons (pixels)."]              = "Tamaño de los botones de zoom + / zoom - (píxeles)."
L["Mail indicator size"]                                            = "Tamaño del indicador de correo"
L["Size of the new mail icon (pixels)."]                            = "Tamaño del icono de correo nuevo (píxeles)."
L["Addon button size"]                                              = "Tamaño de botones de addons"
L["Size of collected addon minimap buttons (pixels)."]              = "Tamaño de los botones de addons recopilados en el minimapa (píxeles)."

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
L["Minimap Addon Buttons"]                                          = "Botones de addons del minimapa"
L["Button Management"]                                              = "Gestión de botones"
L["Manage addon minimap buttons"]                                   = "Gestionar botones de addons del minimapa"
L["When on, Vista takes control of addon minimap buttons and groups them by the selected mode."] = "Activado: Vista toma el control de los botones de addons y los agrupa según el modo seleccionado."
L["Button mode"]                                                    = "Modo de botones"
L["How addon buttons are presented: hover bar below minimap, panel on right-click, or floating drawer button."] = "Cómo se presentan los botones: barra al pasar el ratón, panel al clic derecho o botón de cajón flotante."
L["Mouseover bar"]                                                  = "Barra al pasar el ratón"
L["Right-click panel"]                                              = "Panel clic derecho"
L["Floating drawer"]                                                = "Cajón flotante"
L["Lock drawer button position"]                                    = "Bloquear posición del botón del cajón"
L["Prevent dragging the floating drawer button."]                   = "Impide arrastrar el botón del cajón flotante."
L["Lock mouseover bar position"]                                    = "Bloquear posición de la barra al pasar el ratón"
L["Prevent dragging the mouseover button bar."]                     = "Impide arrastrar la barra de botones al pasar el ratón."
L["Lock right-click panel position"]                                = "Bloquear posición del panel clic derecho"
L["Prevent dragging the right-click panel."]                        = "Impide arrastrar el panel de clic derecho."
L["Buttons per row/column"]                                         = "Botones por fila/columna"
L["Controls how many buttons appear before wrapping. For left/right direction this is columns; for up/down it is rows."] = "Controla cuántos botones aparecen antes de envolver. Izquierda/derecha: columnas; arriba/abajo: filas."
L["Expand direction"]                                               = "Dirección de expansión"
L["Direction buttons fill from the anchor point. Left/Right = horizontal rows. Up/Down = vertical columns."] = "Dirección de llenado desde el punto de anclaje. Izquierda/Derecha: filas horizontales. Arriba/Abajo: columnas verticales."
L["Right"]                                                          = "Derecha"
L["Left"]                                                           = "Izquierda"
L["Down"]                                                           = "Abajo"
L["Up"]                                                             = "Arriba"
L["Panel Appearance"]                                               = "Apariencia del panel"
L["Colors for the drawer and right-click button panels."]           = "Colores para los paneles del cajón y clic derecho."
L["Panel background color"]                                         = "Color de fondo del panel"
L["Background color of the addon button panels."]                   = "Color de fondo de los paneles de botones de addons."
L["Panel border color"]                                              = "Color del borde del panel"
L["Border color of the addon button panels."]                       = "Color del borde de los paneles de botones de addons."
L["Managed buttons"]                                                = "Botones gestionados"
L["When off, this button is completely ignored by this addon."]    = "Desactivado: este botón es ignorado por completo por este addon."
L["(No addon buttons detected yet)"]                                = "(Aún no se han detectado botones de addons)"
L["Visible buttons (check to include)"]                             = "Botones visibles (marca para incluir)"
L["(No addon buttons detected yet — open your minimap first)"]      = "(Aún no se han detectado botones de addons — abre primero tu minimapa)"
