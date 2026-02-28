if GetLocale() ~= "ptBR" then return end

local addon = _G.HorizonSuite
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
L["Focus"]                                                          = "Configurar Foco"
L["Presence"]                                                       = "Configurar Notificações"
L["Other"]                                                          = "Outro"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["Quest types"]                                                    = "Tipos de Missões"
L["Element overrides"]                                              = "Cores por Elemento"
L["Per category"]                                                   = "Cores por Categoria"
L["Grouping Overrides"]                                             = "Cores Prioritárias"
L["Other colors"]                                                   = "Outras Cores"

-- =====================================================================
-- OptionsPanel.lua — Color row labels (collapsible group sub-rows)
-- =====================================================================
L["Section"]                                                        = "Seção"
L["Title"]                                                          = "Título"
L["Zone"]                                                           = "Zona"
L["Objective"]                                                      = "Objetivo"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["Ready to Turn In overrides base colours"]                        = "Pronto para Entregar substitui as cores base"
L["Ready to Turn In uses its colours for quests in that section."]  = "As missões prontas para entregar usam suas cores nesta seção."
L["Current Zone overrides base colours"]                            = "Zona Atual substitui as cores base"
L["Current Zone uses its colours for quests in that section."]      = "As missões da zona atual usam suas cores nesta seção."
L["Use distinct color for completed objectives"]                     = "Usar cor distinta para objetivos completos"
L["When on, completed objectives (e.g. 1/1) use the color below; when off, they use the same color as incomplete objectives."] = "Ativado: objetivos completos (ex. 1/1) usam a cor abaixo. Desativado: eles usam a mesma cor que objetivos incompletos."
L["Completed objective"]                                           = "Objetivo Completo"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["Reset"]                                                          = "Redefinir"
L["Reset quest types"]                                              = "Redefinir tipos de missões"
L["Reset overrides"]                                                = "Redefinir cores personalizadas"
L["Reset to defaults"]                                              = "Redefinir para padrões"
L["Reset to default"]                                               = "Redefinir para padrão"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["Search settings..."]                                             = "Buscar configurações..."
L["Search fonts..."]                                                 = "Buscar fonte..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["Drag to resize"]                                                 = "Arrastar para redimensionar"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
L["Modules"]                                            = "Módulos"
L["Layout"]                                             = "Layout"
L["Visibility"]                                         = "Visibilidade"
L["Display"]                                            = "Exibição"
L["Features"]                                           = "Recursos"
L["Typography"]                                         = "Tipografia"
L["Appearance"]                                         = "Aparência"
L["Colors"]                                             = "Cores"
L["Organization"]                                       = "Organização"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["Panel behaviour"]                                    = "Comportamento do Painel"
L["Dimensions"]                                         = "Dimensões"
L["Instance"]                                           = "Instância"
L["Combat"]                                             = "Combate"
L["Filtering"]                                          = "Filtragem"
L["Header"]                                             = "Cabeçalho"
L["List"]                                               = "Lista"
L["Spacing"]                                            = "Espaçamento"
L["Rare bosses"]                                        = "Chefes Raros"
L["World quests"]                                       = "Missões Mundiais"
L["Floating quest item"]                                = "Item de Missão Flutuante"
L["Mythic+"]                                            = "Mítica+"
L["Achievements"]                                       = "Conquistas"
L["Endeavors"]                                          = "Empreendimentos"
L["Decor"]                                              = "Decoração"
L["Scenario & Delve"]                                   = "Cenário e Delve"
L["Font"]                                               = "Fonte"
L["Text case"]                                          = "Caixa de Texto"
L["Shadow"]                                             = "Sombra"
L["Panel"]                                              = "Painel"
L["Highlight"]                                          = "Destaque"
L["Color matrix"]                                       = "Matriz de Cores"
L["Focus order"]                                        = "Ordem de Foco"
L["Sort"]                                               = "Classificação"
L["Behaviour"]                                          = "Comportamento"
L["Content Types"]                                      = "Tipos de Conteúdo"
L["Delves"]                                             = "Delves"
L["Interactions"]                                       = "Interações"
L["Tracking"]                                           = "Rastreamento"
L["Scenario Bar"]                                       = "Barra de Cenário"

-- =====================================================================
-- OptionsData.lua Modules
-- =====================================================================
L["Enable Focus module"]                                = "Ativar Módulo de Foco"
L["Show the objective tracker for quests, world quests, rares, achievements, and scenarios."] = "Mostra o rastreador de objetivos para missões, missões mundiais, chefes raros, conquistas e cenários."
L["Enable Presence module"]                             = "Ativar Módulo de Presença"
L["Cinematic zone text and notifications (zone changes, level up, boss emotes, achievements, quest updates)."] = "Texto de zona cinematográfico e notificações (mudanças de zona, up de nível, emotes de chefes, conquistas, atualizações de missões)."
L["Enable Yield module"]                                = "Ativar Módulo de Rendimento"
L["Cinematic loot notifications (items, money, currency, reputation)."] = "Notificações cinematográficas de saque (itens, dinheiro, moedas, reputação)."
L["Enable Vista module"]                                = "Ativar Módulo Vista"
L["Cinematic square minimap with zone text, coordinates, and button collector."] = "Minimapa quadrado cinematográfico com texto de zona, coordenadas e coletor de botões."
L["Beta"]                                               = "Beta"
L["Scaling"]                                            = "Escala"
L["Global UI scale"]                                    = "Escala global da interface"
L["Scale all sizes, spacings, and fonts by this factor (50–200%). Does not change your configured values."] = "Escala todos os tamanhos, espaçamentos e fontes por este fator (50–200%). Não altera seus valores configurados."
L["Per-module scaling"]                                 = "Escala por módulo"
L["Override the global scale with individual sliders for each module."] = "Substitui a escala global por controles individuais para cada módulo."
L["Focus scale"]                                        = "Escala do Focus"
L["Scale for the Focus objective tracker (50–200%)."]   = "Escala do rastreador de objetivos Focus (50–200%)."
L["Presence scale"]                                     = "Escala do Presence"
L["Scale for the Presence cinematic text (50–200%)."]   = "Escala do texto cinemático Presence (50–200%)."
L["Vista scale"]                                        = "Escala do Vista"
L["Scale for the Vista minimap module (50–200%)."]      = "Escala do módulo de minimapa Vista (50–200%)."
L["Insight scale"]                                      = "Escala do Insight"
L["Scale for the Insight tooltip module (50–200%)."]    = "Escala do módulo de tooltip Insight (50–200%)."
L["Yield scale"]                                        = "Escala do Yield"
L["Scale for the Yield loot toast module (50–200%)."]   = "Escala do módulo de notificação de saque Yield (50–200%)."
L["Enable Horizon Insight module"]                      = "Ativar Módulo Horizon Insight"
L["Cinematic tooltips with class colors, spec display, and faction icons."] = "Tooltips cinematográficos com cores de classe, exibição de especialização e ícones de facção."
L["Horizon Insight"]                                    = "Horizon Insight"
L["Insight"]                                            = "Insight"
L["Tooltip anchor mode"]                                = "Modo de âncora do tooltip"
L["Where tooltips appear: follow cursor or fixed position."] = "Onde os tooltips aparecem: seguir o cursor ou posição fixa."
L["Cursor"]                                             = "Cursor"
L["Fixed"]                                              = "Fixo"
L["Show anchor to move"]                                = "Mostrar âncora para mover"
L["Show draggable frame to set fixed tooltip position. Drag, then right-click to confirm."] = "Mostra quadro arrastável para definir posição fixa do tooltip. Arraste e clique com o botão direito para confirmar."
L["Reset tooltip position"]                             = "Redefinir posição do tooltip"
L["Reset fixed position to default."]                   = "Redefinir posição fixa para o padrão."
L["Yield"]                                              = "Rendimento"
L["General"]                                            = "Geral"
L["Position"]                                           = "Posição"
L["Reset position"]                                     = "Redefinir Posição"
L["Reset loot toast position to default."]              = "Redefinir posição das notificações de saque."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["Lock position"]                                      = "Travar Posição"
L["Prevent dragging the tracker."]                      = "Impede de arrastar o rastreador."
L["Grow upward"]                                        = "Crescer para Cima"
L["Anchor at bottom so the list grows upward."]         = "Âncora na parte inferior para que a lista cresça para cima."
L["Start collapsed"]                                    = "Começar Colapsado"
L["Start with only the header shown until you expand."] = "Mostrar apenas o cabeçalho até expandir."
L["Panel width"]                                        = "Largura do Painel"
L["Tracker width in pixels."]                           = "Largura do rastreador em pixels."
L["Max content height"]                                 = "Altura Máx. do Conteúdo"
L["Max height of the scrollable list (pixels)."]        = "Altura máxima da lista rolável (pixels)."

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["Always show M+ block"]                                           = "Sempre mostrar bloco M+"
L["Show the M+ block whenever an active keystone is running"]       = "Mostrar o bloco M+ sempre que uma Pedra-Chave ativa estiver em andamento."
L["Show in dungeon"]                                    = "Mostrar em masmorra"
L["Show tracker in party dungeons."]                    = "Mostra o rastreador em masmorras de grupo."
L["Show in raid"]                                       = "Mostrar em raide"
L["Show tracker in raids."]                             = "Mostra o rastreador em raides."
L["Show in battleground"]                               = "Mostrar em campo de batalha"
L["Show tracker in battlegrounds."]                     = "Mostra o rastreador em campos de batalha."
L["Show in arena"]                                      = "Mostrar em arena"
L["Show tracker in arenas."]                            = "Mostra o rastreador em arenas."
L["Hide in combat"]                                     = "Ocultar em combate"
L["Hide tracker and floating quest item in combat."]    = "Oculta o rastreador e o item de missão flutuante em combate."
L["Combat visibility"]                                  = "Visibilidade em combate"
L["How the tracker behaves in combat: show, fade to reduced opacity, or hide."] = "Comportamento do rastreador em combate: mostrar, esmaecer ou ocultar."
L["Show"]                                               = "Mostrar"
L["Fade"]                                               = "Esmaecer"
L["Hide"]                                               = "Ocultar"
L["Combat fade opacity"]                                = "Opacidade em combate (esmaecer)"
L["How visible the tracker is when faded in combat (0 = invisible). Only applies when Combat visibility is Fade."] = "Quão visível o rastreador fica quando esmaecido em combate (0 = invisível). Aplica-se apenas quando a visibilidade em combate é Esmaecer."
L["Mouseover"]                                          = "Passar o mouse"
L["Show only on mouseover"]                             = "Mostrar somente ao passar o mouse"
L["Fade tracker when not hovering; move mouse over it to show."] = "Esmaece o rastreador quando o mouse não está sobre ele; passe o mouse para mostrar."
L["Faded opacity"]                                      = "Opacidade esmaecida"
L["How visible the tracker is when faded (0 = invisible)."] = "Quão visível o rastreador fica quando esmaecido (0 = invisível)."
L["Only show quests in current zone"]                   = "Mostrar apenas missões na zona atual"
L["Hide quests outside your current zone."]             = "Oculta missões fora da sua zona atual."

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["Show quest count"]                                   = "Mostrar contagem de missões"
L["Show quest count in header."]                        = "Mostra a quantidade de missões no cabeçalho."
L["Header count format"]                                = "Formato da contagem do cabeçalho"
L["Tracked/in-log or in-log/max-slots. Tracked excludes world/live-in-zone quests."] = "Rastreadas/no diário ou no diário/vagas máximas. Rastreadas excluem missões mundiais/em zona."
L["Show header divider"]                                = "Mostrar divisor do cabeçalho"
L["Show the line below the header."]                    = "Mostra a linha abaixo do cabeçalho."
L["Header divider color"]                               = "Cor do divisor do cabeçalho"
L["Color of the line below the header."]                = "Cor da linha abaixo do cabeçalho."
L["Super-minimal mode"]                                 = "Modo super minimalista"
L["Hide header for a pure text list."]                  = "Oculta o cabeçalho para ter apenas uma lista de texto."
L["Show options button"]                               = "Mostrar botão de Opções"
L["Show the Options button in the tracker header."]     = "Mostra o botão de Opções no cabeçalho do rastreador."
L["Header color"]                                       = "Cor do cabeçalho"
L["Color of the OBJECTIVES header text."]               = "Cor do texto do cabeçalho OBJECTIVES."
L["Header height"]                                      = "Altura do cabeçalho"
L["Height of the header bar in pixels (18–48)."]        = "Altura da barra de cabeçalho em pixels (18–48)."

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["Show section headers"]                               = "Mostrar cabeçalhos de seção"
L["Show category labels above each group."]             = "Mostra rótulos de categoria acima de cada grupo."
L["Show category headers when collapsed"]               = "Mostrar cabeçalhos ao recolher"
L["Keep section headers visible when collapsed; click to expand a category."] = "Mantém os cabeçalhos visíveis quando recolhidos; clique para expandir uma categoria."
L["Show Nearby (Current Zone) group"]                   = "Mostrar grupo Próximo (Zona Atual)"
L["Show in-zone quests in a dedicated Current Zone section. When off, they appear in their normal category."] = "Mostra missões da zona em uma seção Zona Atual dedicada. Desativado: elas aparecem na categoria normal."
L["Show zone labels"]                                   = "Mostrar nomes de zona"
L["Show zone name under each quest title."]             = "Mostra o nome da zona abaixo de cada título de missão."
L["Active quest highlight"]                             = "Destaque da missão ativa"
L["How the focused quest is highlighted."]              = "Como a missão focada é destacada."
L["Show quest item buttons"]                            = "Mostrar botões de item de missão"
L["Show usable quest item button next to each quest."]  = "Mostra o botão de item utilizável ao lado de cada missão."
L["Show objective numbers"]                             = "Mostrar números de objetivos"
L["Prefix objectives with 1., 2., 3."]                  = "Prefixa objetivos com 1., 2., 3."
L["Show completed count"]                               = "Mostrar contagem de concluídos"
L["Show X/Y progress in quest title."]                  = "Mostra o progresso X/Y no título da missão."
L["Show objective progress bar"]                        = "Mostrar barra de progresso do objetivo"
L["Show a progress bar under objectives that have numeric progress (e.g. 3/250). Only applies to entries with a single arithmetic objective where the required amount is greater than 1."] = "Mostra uma barra de progresso sob objetivos com progresso numérico (ex. 3/250). Aplica-se apenas a entradas com um único objetivo aritmético onde a quantidade necessária é maior que 1."
L["Use category color for progress bar"]                = "Usar cor da categoria na barra de progresso"
L["When on, the progress bar matches the quest/achievement category color. When off, uses the custom fill color below."] = "Quando ativado: a barra de progresso usa a cor da categoria (missão, conquista). Quando desativado: usa a cor personalizada abaixo."
L["Use tick for completed objectives"]                  = "Usar marca para objetivos concluídos"
L["When on, completed objectives show a checkmark (✓) instead of green color."] = "Ativado: objetivos concluídos mostram uma marca (✓) em vez de cor verde."
L["Show entry numbers"]                                 = "Mostrar números de entrada"
L["Prefix quest titles with 1., 2., 3. within each category."] = "Prefixa títulos de missão com 1., 2., 3. em cada categoria."
L["Completed objectives"]                               = "Objetivos concluídos"
L["For multi-objective quests, how to display objectives you've completed (e.g. 1/1)."] = "Para missões com vários objetivos, como exibir objetivos concluídos (ex. 1/1)."
L["Show all"]                                           = "Mostrar tudo"
L["Fade completed"]                                     = "Esmaecer concluídos"
L["Hide completed"]                                     = "Ocultar concluídos"
L["Show icon for in-zone auto-tracking"]                = "Mostrar ícone de rastreamento automático na zona"
L["Display an icon next to auto-tracked world quests and weeklies/dailies that are not yet in your quest log (in-zone only)."] = "Exibe um ícone ao lado de missões mundiais e semanais/diárias rastreadas automaticamente que ainda não estão no seu registro de missões (apenas na zona)."
L["Auto-track icon"]                                    = "Ícone de rastreamento automático"
L["Choose which icon to display next to auto-tracked in-zone entries."] = "Escolha qual ícone exibir ao lado das entradas rastreadas automaticamente na zona."
L["Append ** to world quests and weeklies/dailies that are not yet in your quest log (in-zone only)."] = "Adiciona ** a missões mundiais e semanais/diárias que ainda não estão no seu diário (apenas na zona)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["Compact mode"]                                       = "Modo compacto"
L["Preset: sets entry and objective spacing to 4 and 1 px."] = "Predefinição: define espaçamento de entradas e objetivos para 4 e 1 px."
L["Spacing between quest entries (px)"]                 = "Espaçamento entre entradas de missão (px)"
L["Vertical gap between quest entries."]                = "Espaço vertical entre entradas de missão."
L["Spacing before category header (px)"]                = "Espaçamento antes do cabeçalho da categoria (px)"
L["Gap between last entry of a group and the next category label."] = "Espaço entre a última entrada de um grupo e o próximo rótulo de categoria."
L["Spacing after category header (px)"]                 = "Espaçamento após o cabeçalho da categoria (px)"
L["Gap between category label and first quest entry below it."] = "Espaço entre o rótulo da categoria e a primeira missão abaixo dele."
L["Spacing between objectives (px)"]                    = "Espaçamento entre objetivos (px)"
L["Vertical gap between objective lines within a quest."] = "Espaço vertical entre linhas de objetivos dentro de uma missão."
L["Spacing below header (px)"]                          = "Espaçamento abaixo do cabeçalho (px)"
L["Vertical gap between the objectives bar and the quest list."] = "Espaço vertical entre a barra de objetivos e a lista de missões."
L["Reset spacing"]                                      = "Redefinir espaçamento"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["Show quest level"]                                   = "Mostrar nível da missão"
L["Show quest level next to title."]                    = "Mostra o nível da missão ao lado do título."
L["Dim non-focused quests"]                             = "Escurecer missões não focadas"
L["Slightly dim title, zone, objectives, and section headers that are not focused."] = "Escurece levemente títulos, zonas, objetivos e cabeçalhos de seção que não estão em foco."

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["Show rare bosses"]                                   = "Mostrar chefes raros"
L["Show rare boss vignettes in the list."]              = "Mostra chefes raros na lista."
L["Rare added sound"]                                   = "Som ao adicionar raro"
L["Play a sound when a rare is added."]                 = "Reproduz um som quando um raro é adicionado."
L["Rare added sound choice"]                            = "Escolha do som de raro"
L["Choose which sound to play when a rare boss appears. Requires LibSharedMedia sounds to be installed for extra options."] = "Escolha qual som reproduzir quando um chefe raro aparece. Requer sons LibSharedMedia instalados para opções extras."

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["Show in-zone world quests"]                          = "Mostrar missões mundiais da zona"
L["Auto-add world quests in your current zone. When off, only quests you've tracked or world quests you're in close proximity to appear (Blizzard default)."] = "Adiciona automaticamente missões mundiais na sua zona atual. Desativado: apenas missões rastreadas ou missões mundiais próximas aparecem (padrão Blizzard)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["Show floating quest item"]                           = "Mostrar item de missão flutuante"
L["Show quick-use button for the focused quest's usable item."] = "Mostra botão de uso rápido para o item utilizável da missão focada."
L["Lock floating quest item position"]                  = "Travar posição do item flutuante"
L["Prevent dragging the floating quest item button."]   = "Impede arrastar o botão do item de missão flutuante."
L["Floating quest item source"]                         = "Fonte do item de missão flutuante"
L["Which quest's item to show: super-tracked first, or current zone first."] = "Qual item de missão mostrar: primeiro o super-rastreado ou primeiro o da zona atual."
L["Super-tracked, then first"]                          = "Super-rastreado, depois primeiro"
L["Current zone first"]                                 = "Zona atual primeiro"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["Show Mythic+ block"]                                 = "Mostrar bloco Mítica+"
L["Show timer, completion %, and affixes in Mythic+ dungeons."] = "Mostra cronômetro, % de conclusão e afixos em masmorras Mítica+."
L["M+ block position"]                                  = "Posição do bloco M+"
L["Position of the Mythic+ block relative to the quest list."] = "Posição do bloco Mítica+ em relação à lista de missões."
L["Show affix icons"]                                    = "Mostrar ícones de afixos"
L["Show affix icons next to modifier names in the M+ block."] = "Mostra ícones de afixos ao lado dos modificadores no bloco M+."
L["Show affix descriptions in tooltip"]                  = "Mostrar descrições de afixos na dica"
L["Show affix descriptions when hovering over the M+ block."] = "Mostra descrições de afixos ao passar o mouse sobre o bloco M+."
L["M+ completed boss display"]                         = "Exibição de chefes M+ concluídos"
L["How to show defeated bosses: checkmark icon or green color."] = "Como mostrar chefes derrotados: ícone de marca ou cor verde."
L["Checkmark"]                                          = "Marca"
L["Green color"]                                        = "Cor verde"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["Show achievements"]                                  = "Mostrar conquistas"
L["Show tracked achievements in the list."]             = "Mostra conquistas rastreadas na lista."
L["Show completed achievements"]                        = "Mostrar conquistas concluídas"
L["Include completed achievements in the tracker. When off, only in-progress tracked achievements are shown."] = "Inclui conquistas concluídas no rastreador. Desativado: só conquistas em andamento são mostradas."
L["Show achievement icons"]                             = "Mostrar ícones de conquistas"
L["Show each achievement's icon next to the title. Requires 'Show quest type icons' in Display."] = "Mostra o ícone de cada conquista ao lado do título. Requer \"Mostrar ícones de tipo de missão\" em Exibição."
L["Only show missing requirements"]                     = "Mostrar apenas requisitos faltando"
L["Show only criteria you haven't completed for each tracked achievement. When off, all criteria are shown."] = "Mostra apenas critérios que você ainda não concluiu para cada conquista rastreada. Desativado: todos os critérios são mostrados."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["Show endeavors"]                                     = "Mostrar Empreendimentos"
L["Show tracked Endeavors (Player Housing) in the list."] = "Mostra Empreendimentos rastreados (Habitação do Jogador) na lista."
L["Show completed endeavors"]                           = "Mostrar Empreendimentos concluídos"
L["Include completed Endeavors in the tracker. When off, only in-progress tracked Endeavors are shown."] = "Inclui Empreendimentos concluídos no rastreador. Desativado: só Empreendimentos em andamento são mostrados."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["Show decor"]                                         = "Mostrar decoração"
L["Show tracked housing decor in the list."]            = "Mostra decorações de casa rastreadas na lista."
L["Show decor icons"]                                   = "Mostrar ícones de decoração"
L["Show each decor item's icon next to the title. Requires 'Show quest type icons' in Display."] = "Mostra o ícone de cada decoração ao lado do título. Requer \"Mostrar ícones de tipo de missão\" em Exibição."

-- =====================================================================
-- OptionsData.lua Features — Adventure Guide
-- =====================================================================
L["Adventure Guide"]                                    = "Guia de Aventura"
L["Show Traveler's Log"]                                = "Mostrar Diário do Viajante"
L["Show tracked Traveler's Log objectives (Shift+click in Adventure Guide) in the list."] = "Mostra objetivos rastreados do Diário do Viajante (Shift+clique no Guia de Aventura) na lista."
L["Auto-remove completed activities"]                   = "Remover automaticamente atividades concluídas"
L["Automatically stop tracking Traveler's Log activities once they have been completed."] = "Para automaticamente de rastrear atividades do Diário do Viajante quando concluídas."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["Show scenario events"]                               = "Mostrar eventos de cenário"
L["Show active scenario and Delve activities. Delves appear in DELVES; other scenarios in SCENARIO EVENTS."] = "Mostra cenários ativos e atividades de Delve. Delves aparecem em Delves; outros cenários em EVENTOS DE CENÁRIO."
L["Hide other categories in Delve or Dungeon"]          = "Ocultar outras categorias em Delves ou Masmorras"
L["In Delves or party dungeons, show only the Delve/Dungeon section."] = "Em Delves ou masmorras de grupo, mostra apenas a seção de Delve/Masmorra."
L["Use delve name as section header"]                    = "Usar nome do Delve como cabeçalho de seção"
L["When in a Delve, show the delve name, tier, and affixes as the section header instead of a separate banner. Disable to show the Delve block above the list."] = "Em um Delve, mostra nome, nível e afixos no cabeçalho da seção em vez de um banner separado. Desative para mostrar o bloco de Delve acima da lista."
L["Show affix names in Delves"]                         = "Mostrar nomes de afixos em Delves"
L["Show season affix names on the first Delve entry. Requires Blizzard's objective tracker widgets to be populated; may not show when using a full tracker replacement."] = "Mostra nomes de afixos da temporada na primeira entrada de Delve. Requer widgets do rastreador de objetivos da Blizzard; pode não aparecer ao usar um rastreador totalmente substituto."
L["Cinematic scenario bar"]                             = "Barra de cenário cinematográfica"
L["Show timer and progress bar for scenario entries."]  = "Mostra cronômetro e barra de progresso para entradas de cenário."
L["Show timer"]                                         = "Mostrar cronômetro"
L["Show countdown timer on timed quests, events, and scenarios. When off, timers are hidden for all entry types."] = "Mostra cronômetro em missões, eventos e cenários cronometrados. Desativado, os cronômetros são ocultados."
L["Timer display"]                                      = "Exibição do cronômetro"
L["Color timer by remaining time"]                      = "Cor do cronômetro por tempo restante"
L["Green when plenty of time left, yellow when running low, red when critical."] = "Verde quando há tempo, amarelo quando está acabando, vermelho quando crítico."
L["Where to show the countdown: bar below objectives or text beside the quest name."] = "Onde exibir a contagem regressiva: barra abaixo dos objetivos ou texto ao lado do nome da missão."
L["Bar below"]                                          = "Barra abaixo"
L["Inline beside title"]                                = "Ao lado do título"
L["Show countdown timer bars on timed quests, events, and scenarios. When off, timer bars are hidden for all entry types."] = "Mostra barras de contagem regressiva em missões, eventos e cenários cronometrados. Quando desativado, as barras de cronômetro ficam ocultas para todos os tipos de entrada."

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["Font family."]                                       = "Família de fonte."
L["Title font"]                                         = "Fonte dos títulos"
L["Zone font"]                                          = "Fonte das zonas"
L["Objective font"]                                     = "Fonte dos objetivos"
L["Section font"]                                       = "Fonte das seções"
L["Use global font"]                                    = "Usar fonte global"
L["Font family for quest titles."]                      = "Família de fonte dos títulos de missão."
L["Font family for zone labels."]                       = "Família de fonte dos rótulos de zona."
L["Font family for objective text."]                    = "Família de fonte do texto dos objetivos."
L["Font family for section headers."]                    = "Família de fonte dos cabeçalhos de seção."
L["Header size"]                                        = "Tamanho do cabeçalho"
L["Header font size."]                                  = "Tamanho da fonte do cabeçalho."
L["Title size"]                                         = "Tamanho do título"
L["Quest title font size."]                             = "Tamanho da fonte dos títulos de missão."
L["Objective size"]                                     = "Tamanho dos objetivos"
L["Objective text font size."]                          = "Tamanho da fonte do texto dos objetivos."
L["Zone size"]                                          = "Tamanho das zonas"
L["Zone label font size."]                              = "Tamanho da fonte dos rótulos de zona."
L["Section size"]                                       = "Tamanho das seções"
L["Section header font size."]                          = "Tamanho da fonte dos cabeçalhos de seção."
L["Progress bar font"]                                  = "Fonte da barra de progresso"
L["Font family for the progress bar label."]            = "Família de fonte para o texto da barra de progresso."
L["Progress bar text size"]                             = "Tamanho do texto da barra de progresso"
L["Font size for the progress bar label. Also adjusts bar height. Affects quest objectives, scenario progress, and scenario timer bars."] = "Tamanho da fonte do texto da barra de progresso. Também ajusta a altura da barra. Afeta objetivos de missões, progresso de cenário e barras de timer."
L["Progress bar fill"]                                  = "Preenchimento da barra de progresso"
L["Progress bar text"]                                  = "Texto da barra de progresso"
L["Outline"]                                            = "Contorno"
L["Font outline style."]                                = "Estilo de contorno da fonte."

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["Header text case"]                                   = "Caixa de texto do cabeçalho"
L["Display case for header."]                           = "Caixa de exibição para o cabeçalho."
L["Section header case"]                                = "Caixa dos cabeçalhos de seção"
L["Display case for category labels."]                  = "Caixa de exibição para rótulos de categoria."
L["Quest title case"]                                   = "Caixa dos títulos de missão"
L["Display case for quest titles."]                     = "Caixa de exibição para títulos de missão."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["Show text shadow"]                                   = "Mostrar sombra do texto"
L["Enable drop shadow on text."]                        = "Ativa sombra projetada no texto."
L["Shadow X"]                                           = "Sombra X"
L["Horizontal shadow offset."]                          = "Deslocamento horizontal da sombra."
L["Shadow Y"]                                           = "Sombra Y"
L["Vertical shadow offset."]                            = "Deslocamento vertical da sombra."
L["Shadow alpha"]                                       = "Opacidade da sombra"
L["Shadow opacity (0–1)."]                              = "Opacidade da sombra (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["Mythic+ Typography"]                                  = "Tipografia de Mítica+"
L["Dungeon name size"]                                   = "Tamanho do nome da masmorra"
L["Font size for dungeon name (8–32 px)."]              = "Tamanho da fonte do nome da masmorra (8–32 px)."
L["Dungeon name color"]                                  = "Cor do nome da masmorra"
L["Text color for dungeon name."]                        = "Cor do texto do nome da masmorra."
L["Timer size"]                                         = "Tamanho do cronômetro"
L["Font size for timer (8–32 px)."]                     = "Tamanho da fonte do cronômetro (8–32 px)."
L["Timer color"]                                        = "Cor do cronômetro"
L["Text color for timer (in time)."]                    = "Cor do texto do cronômetro (no tempo)."
L["Timer overtime color"]                               = "Cor do cronômetro em atraso"
L["Text color for timer when over the time limit."]      = "Cor do texto do cronômetro quando o tempo acabou."
L["Progress size"]                                      = "Tamanho da progressão"
L["Font size for enemy forces (8–32 px)."]               = "Tamanho da fonte das forças inimigas (8–32 px)."
L["Progress color"]                                     = "Cor da progressão"
L["Text color for enemy forces."]                        = "Cor do texto das forças inimigas."
L["Bar fill color"]                                     = "Cor de preenchimento da barra"
L["Progress bar fill color (in progress)."]             = "Cor de preenchimento da barra de progresso (em andamento)."
L["Bar complete color"]                                 = "Cor da barra concluída"
L["Progress bar fill color when enemy forces are at 100%."] = "Cor de preenchimento da barra quando as forças inimigas estão em 100%."
L["Affix size"]                                         = "Tamanho dos afixos"
L["Font size for affixes (8–32 px)."]                   = "Tamanho da fonte dos afixos (8–32 px)."
L["Affix color"]                                        = "Cor dos afixos"
L["Text color for affixes."]                             = "Cor do texto dos afixos."
L["Boss size"]                                          = "Tamanho dos nomes dos chefes"
L["Font size for boss names (8–32 px)."]                = "Tamanho da fonte dos nomes dos chefes (8–32 px)."
L["Boss color"]                                         = "Cor dos nomes dos chefes"
L["Text color for boss names."]                          = "Cor do texto dos nomes dos chefes."
L["Reset Mythic+ typography"]                           = "Redefinir tipografia de M+"

-- =====================================================================
-- OptionsData.lua Appearance
-- =====================================================================
L["Backdrop opacity"]                                   = "Opacidade do fundo"
L["Panel background opacity (0–1)."]                    = "Opacidade do fundo do painel (0–1)."
L["Show border"]                                        = "Mostrar borda"
L["Show border around the tracker."]                    = "Mostra uma borda ao redor do rastreador."
L["Show scroll indicator"]                              = "Mostrar indicador de rolagem"
L["Show a visual hint when the list has more content than is visible."] = "Mostra um indicador visual quando a lista tem mais conteúdo do que o visível."
L["Scroll indicator style"]                             = "Estilo do indicador de rolagem"
L["Choose between a fade-out gradient or a small arrow to indicate scrollable content."] = "Escolha entre um gradiente de desvanecimento ou uma pequena seta para indicar conteúdo rolável."
L["Arrow"]                                              = "Seta"
L["Highlight alpha"]                                    = "Opacidade do destaque"
L["Opacity of focused quest highlight (0–1)."]          = "Opacidade do destaque da missão focada (0–1)."
L["Bar width"]                                          = "Largura da barra"
L["Width of bar-style highlights (2–6 px)."]            = "Largura dos destaques em forma de barra (2–6 px)."

-- =====================================================================
-- OptionsData.lua Organization
-- =====================================================================
L["Focus category order"]                               = "Ordem das categorias de Foco"
L["Drag to reorder categories. DELVES and SCENARIO EVENTS stay first."] = "Arraste para reordenar categorias. Delves e EVENTOS DE CENÁRIO permanecem primeiro."
L["Focus sort mode"]                                    = "Modo de ordenação do Foco"
L["Order of entries within each category."]             = "Ordem das entradas em cada categoria."
L["Auto-track accepted quests"]                         = "Rastrear automaticamente missões aceitas"
L["When you accept a quest (quest log only, not world quests), add it to the tracker automatically."] = "Ao aceitar uma missão (apenas diário, não missões mundiais), adiciona-a automaticamente ao rastreador."
L["Require Ctrl for focus & remove"]                    = "Exigir Ctrl para focar e remover"
L["Require Ctrl for focus/add (Left) and unfocus/untrack (Right) to prevent misclicks."] = "Exige Ctrl para focar/adicionar (botão esquerdo) e desfocar/parar de rastrear (botão direito) para evitar cliques acidentais."
L["Use classic click behaviour"]                             = "Usar comportamento de clique clássico"
L["Share with party"]                                        = "Compartilhar com grupo"
L["Abandon quest"]                                           = "Abandonar missão"
L["Stop tracking"]                                           = "Parar de rastrear"
L["This quest cannot be shared."]                             = "Esta missão não pode ser compartilhada."
L["You must be in a party to share this quest."]              = "Você precisa estar em um grupo para compartilhar esta missão."
L["When on, left-click opens the quest map and right-click shows share/abandon menu (Blizzard-style). When off, left-click focuses and right-click untracks; Ctrl+Right shares with party."] = "Quando ativado, clique esquerdo abre o mapa da missão e clique direito exibe o menu compartilhar/abandonar (estilo Blizzard). Quando desativado, clique esquerdo foca e clique direito remove rastreamento; Ctrl+clique direito compartilha com o grupo."
L["Animations"]                                         = "Animações"
L["Enable slide and fade for quests."]                  = "Ativa deslizar e esmaecer para missões."
L["Objective progress flash"]                           = "Flash de progresso de objetivo"
L["Show flash when an objective completes."]            = "Mostra um flash quando um objetivo é concluído."
L["Flash intensity"]                                   = "Intensidade do flash"
L["How noticeable the objective-complete flash is."]    = "Quão perceptível é o flash de conclusão de objetivo."
L["Flash color"]                                        = "Cor do flash"
L["Color of the objective-complete flash."]             = "Cor do flash de conclusão de objetivo."
L["Subtle"]                                             = "Sutil"
L["Medium"]                                             = "Médio"
L["Strong"]                                             = "Forte"
L["Require Ctrl for click to complete"]                 = "Exigir Ctrl para clicar e concluir"
L["When on, requires Ctrl+Left-click to complete auto-complete quests. When off, plain Left-click completes them (Blizzard default). Only affects quests that can be completed by click (no NPC turn-in needed)."] = "Ativado: exige Ctrl+clique esquerdo para concluir missões de auto-conclusão. Desativado: clique esquerdo simples conclui (padrão Blizzard). Afeta apenas missões que podem ser concluídas por clique (sem entregar a um NPC)."
L["Suppress untracked until reload"]                     = "Ocultar não rastreadas até recarregar"
L["When on, right-click untrack on world quests and in-zone weeklies/dailies hides them until you reload or start a new session. When off, they reappear when you return to the zone."] = "Ativado: clicar com o botão direito para parar de rastrear missões mundiais e semanais/diárias na zona as oculta até você recarregar ou iniciar uma nova sessão. Desativado: elas reaparecem quando você volta à zona."
L["Permanently suppress untracked quests"]               = "Ocultar permanentemente missões não rastreadas"
L["When on, right-click untracked world quests and in-zone weeklies/dailies are hidden permanently (persists across reloads). Takes priority over 'Suppress until reload'. Accepting a suppressed quest removes it from the blacklist."] = "Ativado: missões mundiais e semanais/diárias na zona marcadas como não rastreadas ficam ocultas permanentemente (persiste entre recargas). Tem prioridade sobre \"Ocultar até recarregar\". Aceitar uma missão oculta a remove da lista negra."
L["Keep campaign quests in category"]                    = "Manter missões de campanha na categoria"
L["When on, campaign quests that are ready to turn in remain in the Campaign category instead of moving to Complete."] = "Ativado: missões de campanha prontas para entregar permanecem na categoria Campanha em vez de ir para Concluídas."
L["Keep important quests in category"]                   = "Manter missões importantes na categoria"
L["When on, important quests that are ready to turn in remain in the Important category instead of moving to Complete."] = "Ativado: missões importantes prontas para entregar permanecem na categoria Importante em vez de ir para Concluídas."

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
L["Blacklisted quests"]                                  = "Missões na lista negra"
L["Permanently suppressed quests"]                       = "Missões ocultas permanentemente"
L["Right-click untrack quests with 'Permanently suppress untracked quests' enabled to add them here."] = "Clique com o botão direito para parar de rastrear missões com \"Ocultar permanentemente missões não rastreadas\" ativado para adicioná-las aqui."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["Show quest type icons"]                              = "Mostrar ícones de tipo de missão"
L["Show quest type icon in the Focus tracker (quest accept/complete, world quest, quest update)."] = "Mostra ícone de tipo de missão no rastreador Foco (aceitar/concluir missão, missão mundial, atualização de missão)."
L["Show quest type icons on toasts"]                    = "Mostrar ícones de tipo nas notificações"
L["Show quest type icon on Presence toasts (quest accept/complete, world quest, quest update)."] = "Mostra ícone de tipo nas notificações Presence (aceitar/concluir missão, missão mundial, atualização de missão)."
L["Toast icon size"]                                    = "Tamanho dos ícones das notificações"
L["Quest icon size on Presence toasts (16–36 px). Default 24."] = "Tamanho do ícone de missão nas notificações Presence (16–36 px). Padrão 24."
L["Hide quest update title"]                            = "Ocultar título no avanço de missão"
L["Show only the objective line on quest progress toasts (e.g. 7/10 Boar Pelts), without the quest name or header."] = "Mostra apenas a linha do objetivo (ex.: 7/10 Peles de javali), sem o nome da missão ou cabeçalho."
L["Show discovery line"]                                = "Mostrar linha de descoberta"
L["Show 'Discovered' under zone/subzone when entering a new area."] = "Mostra \"Descoberto\" sob zona/subzona ao entrar em uma nova área."
L["Frame vertical position"]                            = "Posição vertical do quadro"
L["Vertical offset of the Presence frame from center (-300 to 0)."] = "Deslocamento vertical do quadro Presence a partir do centro (-300 a 0)."
L["Frame scale"]                                        = "Escala do quadro"
L["Scale of the Presence frame (0.5–2)."]              = "Escala do quadro Presence (0,5–2)."
L["Boss emote color"]                                   = "Cor dos emotes de chefe"
L["Color of raid and dungeon boss emote text."]          = "Cor do texto de emotes de chefes de raide e masmorra."
L["Discovery line color"]                               = "Cor da linha de descoberta"
L["Color of the 'Discovered' line under zone text."]     = "Cor da linha \"Descoberto\" sob o texto de zona."
L["Notification types"]                                 = "Tipos de notificação"
L["Show zone entry"]                                    = "Mostrar entrada em zona"
L["Show zone change when entering a new area."]         = "Mostra notificação ao entrar em uma nova área."
L["Show subzone changes"]                               = "Mostrar mudanças de subzona"
L["Show subzone change when moving within the same zone."] = "Mostra notificação ao se mover entre subzonas na mesma zona."
L["Hide zone name for subzone changes"]                 = "Ocultar nome da zona para mudanças de subzona"
L["When moving between subzones within the same zone, only show the subzone name. The zone name still appears when entering a new zone."] = "Ao se mover entre subzonas na mesma zona, mostra apenas o nome da subzona. O nome da zona ainda aparece ao entrar em uma nova zona."
L["Suppress zone changes in Mythic+"]                   = "Suprimir mudanças de zona em Mítico+"
L["In Mythic+, only show boss emotes, achievements, and level-up. Hide zone, quest, and scenario notifications."] = "Em Mítico+, mostra apenas emotes de chefe, conquistas e subida de nível. Oculta notificações de zona, missão e cenário."
L["Show level up"]                                      = "Mostrar subir de nível"
L["Show level-up notification."]                        = "Mostra notificação de subida de nível."
L["Show boss emotes"]                                   = "Mostrar emotes de chefe"
L["Show raid and dungeon boss emote notifications."]    = "Mostra notificações de emotes de chefes em raides e masmorras."
L["Show achievements"]                                  = "Mostrar conquistas"
L["Show achievement earned notifications."]            = "Mostra notificações de conquistas obtidas."
L["Show quest accept"]                                  = "Mostrar aceitação de missão"
L["Show notification when accepting a quest."]          = "Mostra notificação ao aceitar uma missão."
L["Show world quest accept"]                            = "Mostrar aceitação de missão mundial"
L["Show notification when accepting a world quest."]    = "Mostra notificação ao aceitar uma missão mundial."
L["Show quest complete"]                                = "Mostrar conclusão de missão"
L["Show notification when completing a quest."]        = "Mostra notificação ao concluir uma missão."
L["Show world quest complete"]                          = "Mostrar conclusão de missão mundial"
L["Show notification when completing a world quest."]   = "Mostra notificação ao concluir uma missão mundial."
L["Show quest progress"]                                = "Mostrar progresso da missão"
L["Show notification when quest objectives update."]    = "Mostra notificação quando objetivos da missão são atualizados."
L["Show scenario start"]                                = "Mostrar início de cenário"
L["Show notification when entering a scenario or Delve."] = "Mostra notificação ao entrar em um cenário ou Profundezas."
L["Show scenario progress"]                             = "Mostrar progresso do cenário"
L["Show notification when scenario or Delve objectives update."] = "Mostra notificação quando objetivos de cenário ou Profundezas são atualizados."
L["Animation"]                                          = "Animação"
L["Enable animations"]                                  = "Ativar animações"
L["Enable entrance and exit animations for Presence notifications."] = "Ativa animações de entrada e saída para notificações Presence."
L["Entrance duration"]                                  = "Duração da entrada"
L["Duration of the entrance animation in seconds (0.2–1.5)."] = "Duração da animação de entrada em segundos (0,2–1,5)."
L["Exit duration"]                                      = "Duração da saída"
L["Duration of the exit animation in seconds (0.2–1.5)."] = "Duração da animação de saída em segundos (0,2–1,5)."
L["Hold duration scale"]                                = "Fator de duração em tela"
L["Multiplier for how long each notification stays on screen (0.5–2)."] = "Multiplicador de quanto tempo cada notificação permanece na tela (0,5–2)."
L["Typography"]                                         = "Tipografia"
L["Main title font"]                                    = "Fonte do título principal"
L["Font family for the main title."]                     = "Família de fontes do título principal."
L["Subtitle font"]                                      = "Fonte do subtítulo"
L["Font family for the subtitle."]                      = "Família de fontes do subtítulo."
L["Main title size"]                                    = "Tamanho do título principal"
L["Font size for the main title (24–72 px)."]            = "Tamanho da fonte do título principal (24–72 px)."
L["Subtitle size"]                                      = "Tamanho do subtítulo"
L["Font size for the subtitle (12–40 px)."]             = "Tamanho da fonte do subtítulo (12–40 px)."

-- =====================================================================
-- OptionsData.lua Dropdown options — Outline
-- =====================================================================
L["None"]                                               = "Nenhum"
L["Thick Outline"]                                      = "Contorno espesso"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["Bar (left edge)"]                                    = "Barra (borda esquerda)"
L["Bar (right edge)"]                                   = "Barra (borda direita)"
L["Bar (top edge)"]                                     = "Barra (borda superior)"
L["Bar (bottom edge)"]                                  = "Barra (borda inferior)"
L["Outline only"]                                       = "Apenas contorno"
L["Soft glow"]                                          = "Brilho suave"
L["Dual edge bars"]                                     = "Barras duplas nas bordas"
L["Pill left accent"]                                   = "Realce em pílula à esquerda"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["Top"]                                                = "Topo"
L["Bottom"]                                             = "Fundo"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["Location position"]                                  = "Posição do nome da zona"
L["Place the zone name above or below the minimap."]      = "Coloca o nome da zona acima ou abaixo do minimapa."
L["Coordinates position"]                               = "Posição das coordenadas"
L["Place the coordinates above or below the minimap."]    = "Coloca as coordenadas acima ou abaixo do minimapa."
L["Clock position"]                                     = "Posição do relógio"
L["Place the clock above or below the minimap."]         = "Coloca o relógio acima ou abaixo do minimapa."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["Lower Case"]                                         = "Minúsculas"
L["Upper Case"]                                         = "Maiúsculas"
L["Proper"]                                             = "Primeira letra maiúscula"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["Tracked / in log"]                                   = "Rastreadas / no diário"
L["In log / max slots"]                                 = "No diário / vagas máx."

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["Alphabetical"]                                       = "Alfabética"
L["Quest Type"]                                         = "Tipo de missão"
L["Quest Level"]                                        = "Nível da missão"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["Custom"]                                             = "Personalizado"
L["Order"]                                              = "Ordem"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["DUNGEON"]           = "MASMORRA"
L["RAID"]              = "RAIDE"
L["DELVES"]            = "Delves"
L["SCENARIO EVENTS"]   = "EVENTOS DE CENÁRIO"
L["AVAILABLE IN ZONE"] = "DISPONÍVEL NA ZONA"
L["EVENTS IN ZONE"] = "Eventos na zona"
L["CURRENT ZONE"]      = "ZONA ATUAL"
L["CAMPAIGN"]          = "CAMPANHA"
L["IMPORTANT"]         = "IMPORTANTE"
L["LEGENDARY"]         = "LENDÁRIA"
L["WORLD QUESTS"]      = "MISSÕES MUNDIAIS"
L["WEEKLY QUESTS"]     = "MISSÕES SEMANAIS"
L["DAILY QUESTS"]      = "MISSÕES DIÁRIAS"
L["RARE BOSSES"]       = "CHEFES RAROS"
L["ACHIEVEMENTS"]      = "CONQUISTAS"
L["ENDEAVORS"]         = "EMPREENDIMENTOS"
L["DECOR"]             = "DECORAÇÃO"
L["QUESTS"]            = "MISSÕES"
L["READY TO TURN IN"]  = "PRONTO PARA ENTREGAR"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["OBJECTIVES"]                                                                                    = "OBJETIVOS"
L["Options"]                                                                                       = "Opções"
L["Discovered"]                                                                                    = "Descoberto"
L["Refresh"]                                                                                       = "Atualizar"
L["Best-effort only. Some unaccepted quests are not exposed until you interact with NPCs or meet phasing conditions."] = "Melhor esforço apenas. Algumas missões não aceitas não são exibidas até você interagir com NPCs ou atender às condições de faseamento."
L["Unaccepted Quests - %s (map %s) - %d match(es)"]                                                  = "Missões não aceitas - %s (mapa %s) - %d correspondência(s)"

L["LEVEL UP"]                                                                                      = "SUBIU DE NÍVEL"
L["You have reached level 80"]                                                                     = "Você alcançou o nível 80"
L["You have reached level %s"]                                                                     = "Você alcançou o nível %s"
L["ACHIEVEMENT EARNED"]                                                                            = "CONQUISTA OBTIDA"
L["Exploring the Midnight Isles"]                                                                  = "Explorando as Ilhas da Meia-noite"
L["Exploring Khaz Algar"]                                                                          = "Explorando Khaz Algar"
L["QUEST COMPLETE"]                                                                                = "MISSÃO CONCLUÍDA"
L["Objective Secured"]                                                                             = "Objetivo Garantido"
L["Aiding the Accord"]                                                                             = "Ajudando o Pacto"
L["WORLD QUEST"]                                                                                   = "MISSÃO MUNDIAL"
L["Azerite Mining"]                                                                                = "Mineração de Azerita"
L["WORLD QUEST ACCEPTED"]                                                                          = "MISSÃO MUNDIAL ACEITA"
L["QUEST ACCEPTED"]                                                                                = "MISSÃO ACEITA"
L["The Fate of the Horde"]                                                                         = "O Destino da Horda"
L["New Quest"]                                                                                     = "Nova Missão"
L["QUEST UPDATE"]                                                                                  = "ATUALIZAÇÃO DE MISSÃO"
L["Boar Pelts: 7/10"]                                                                              = "Pelagens de Javali: 7/10"
L["Dragon Glyphs: 3/5"]                                                                            = "Glifos de Dragão: 3/5"

L["Presence test commands:"]                                                                       = "Comandos de teste do Presence:"
L["  /h presence         - Show help + test current zone"]                                   = "  /h presence         - Mostrar ajuda + testar zona atual"
L["  /h presence zone     - Test Zone Change"]                                               = "  /h presence zone     - Testar Mudança de Zona"
L["  /h presence subzone  - Test Subzone Change"]                                            = "  /h presence subzone  - Testar Mudança de Subzona"
L["  /h presence discover - Test Zone Discovery"]                                            = "  /h presence discover - Testar Descoberta de Zona"
L["  /h presence level    - Test Level Up"]                                                  = "  /h presence level    - Testar Subir de Nível"
L["  /h presence boss     - Test Boss Emote"]                                                = "  /h presence boss     - Testar Emote de Chefe"
L["  /h presence ach      - Test Achievement"]                                               = "  /h presence ach      - Testar Conquista"
L["  /h presence accept   - Test Quest Accepted"]                                            = "  /h presence accept   - Testar Missão Aceita"
L["  /h presence wqaccept - Test World Quest Accepted"]                                      = "  /h presence wqaccept - Testar Missão Mundial Aceita"
L["  /h presence scenario - Test Scenario Start"]                                            = "  /h presence scenario - Testar Início de Cenário"
L["  /h presence quest    - Test Quest Complete"]                                            = "  /h presence quest    - Testar Missão Concluída"
L["  /h presence wq       - Test World Quest"]                                               = "  /h presence wq       - Testar Missão Mundial"
L["  /h presence update   - Test Quest Update"]                                              = "  /h presence update   - Testar Atualização de Missão"
L["  /h presence all      - Demo reel (all types)"]                                          = "  /h presence all      - Demo (todos os tipos)"
L["  /h presence debug    - Dump state to chat"]                                             = "  /h presence debug    - Mostrar estado no chat"
L["  /h presence debuglive - Toggle live debug panel (log as events happen)"]                = "  /h presence debuglive - Alternar painel de debug ao vivo (logar eventos em tempo real)"

-- =====================================================================
-- OptionsData.lua Vista — General
-- =====================================================================
L["Minimap"]                                                        = "Minimapa"
L["Minimap size"]                                                   = "Tamanho do minimapa"
L["Width and height of the minimap in pixels (100–400)."]           = "Largura e altura do minimapa em pixels (100–400)."
L["Circular minimap"]                                               = "Minimapa circular"
L["Use a circular minimap instead of square."]                      = "Usar minimapa circular em vez de quadrado."
L["Lock minimap position"]                                          = "Bloquear posição do minimapa"
L["Prevent dragging the minimap."]                                  = "Impede arrastar o minimapa."
L["Reset minimap position"]                                         = "Redefinir posição do minimapa"
L["Reset minimap to its default position (top-right)."]             = "Redefine o minimapa para a posição padrão (canto superior direito)."
L["Auto Zoom"]                                                      = "Zoom Automático"
L["Auto zoom-out delay"]                                            = "Atraso do zoom-out automático"
L["Seconds after zooming before auto zoom-out fires. Set to 0 to disable."] = "Segundos após o zoom antes do zoom-out automático. 0 para desativar."

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["Zone Text"]                                                      = "Texto da Zona"
L["Zone font"]                                                      = "Fonte da zona"
L["Font for the zone name below the minimap."]                      = "Fonte do nome da zona abaixo do minimapa."
L["Zone font size"]                                                 = "Tamanho da fonte da zona"
L["Zone text color"]                                                = "Cor do texto da zona"
L["Color of the zone name text."]                                   = "Cor do texto do nome da zona."
L["Coordinates Text"]                                               = "Texto de Coordenadas"
L["Coordinates font"]                                               = "Fonte das coordenadas"
L["Font for the coordinates text below the minimap."]               = "Fonte do texto de coordenadas abaixo do minimapa."
L["Coordinates font size"]                                          = "Tamanho da fonte das coordenadas"
L["Coordinates text color"]                                         = "Cor do texto das coordenadas"
L["Color of the coordinates text."]                                 = "Cor do texto das coordenadas."
L["Coordinate precision"]                                           = "Precisão das coordenadas"
L["Number of decimal places shown for X and Y coordinates."]        = "Número de casas decimais para as coordenadas X e Y."
L["No decimals (e.g. 52, 37)"]                                      = "Sem decimais (ex.: 52, 37)"
L["1 decimal (e.g. 52.3, 37.1)"]                                    = "1 decimal (ex.: 52.3, 37.1)"
L["2 decimals (e.g. 52.34, 37.12)"]                                 = "2 decimais (ex.: 52.34, 37.12)"
L["Time Text"]                                                      = "Texto do Horário"
L["Time font"]                                                      = "Fonte do horário"
L["Font for the time text below the minimap."]                      = "Fonte do texto de horário abaixo do minimapa."
L["Time font size"]                                                 = "Tamanho da fonte do horário"
L["Time text color"]                                                = "Cor do texto do horário"
L["Color of the time text."]                                        = "Cor do texto do horário."
L["Difficulty Text"]                                                = "Texto de Dificuldade"
L["Difficulty text color (fallback)"]                               = "Cor do texto de dificuldade (padrão)"
L["Default color when no per-difficulty color is set."]             = "Cor padrão quando nenhuma cor por dificuldade está definida."
L["Difficulty font"]                                                = "Fonte de dificuldade"
L["Font for the instance difficulty text."]                         = "Fonte do texto de dificuldade de instância."
L["Difficulty font size"]                                           = "Tamanho da fonte de dificuldade"
L["Per-Difficulty Colors"]                                          = "Cores por Dificuldade"
L["Mythic color"]                                                   = "Cor Mítica"
L["Color for Mythic difficulty text."]                              = "Cor do texto de dificuldade Mítica."
L["Heroic color"]                                                   = "Cor Heroica"
L["Color for Heroic difficulty text."]                              = "Cor do texto de dificuldade Heroica."
L["Normal color"]                                                   = "Cor Normal"
L["Color for Normal difficulty text."]                              = "Cor do texto de dificuldade Normal."
L["LFR color"]                                                      = "Cor LFR"
L["Color for Looking For Raid difficulty text."]                    = "Cor do texto de dificuldade Procurar Raide."

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["Text Elements"]                                                  = "Elementos de Texto"
L["Show zone text"]                                                 = "Mostrar texto da zona"
L["Show the zone name below the minimap."]                          = "Mostra o nome da zona abaixo do minimapa."
L["Zone text display mode"]                                         = "Modo de exibição do texto da zona"
L["What to show: zone only, subzone only, or both."]                = "O que mostrar: apenas zona, apenas subzona ou ambas."
L["Zone only"]                                                      = "Apenas zona"
L["Subzone only"]                                                   = "Apenas subzona"
L["Both"]                                                           = "Ambas"
L["Show coordinates"]                                               = "Mostrar coordenadas"
L["Show player coordinates below the minimap."]                     = "Mostra as coordenadas do jogador abaixo do minimapa."
L["Show time"]                                                      = "Mostrar horário"
L["Show current game time below the minimap."]                      = "Mostra o horário do jogo abaixo do minimapa."
L["Use local time"]                                                 = "Usar horário local"
L["When on, shows your local system time. When off, shows server time."] = "Ativado: mostra o horário local do sistema. Desativado: mostra o horário do servidor."
L["Minimap Buttons"]                                                = "Botões do Minimapa"
L["Queue status and mail indicator are always shown when relevant."] = "O status da fila e o indicador de correio sempre são exibidos quando relevantes."
L["Show tracking button"]                                           = "Mostrar botão de rastreamento"
L["Show the minimap tracking button."]                              = "Mostra o botão de rastreamento no minimapa."
L["Tracking button on mouseover only"]                              = "Botão de rastreamento somente ao passar o mouse"
L["Hide tracking button until you hover over the minimap."]         = "Oculta o botão de rastreamento até passar o mouse sobre o minimapa."
L["Show calendar button"]                                           = "Mostrar botão de calendário"
L["Show the minimap calendar button."]                              = "Mostra o botão de calendário no minimapa."
L["Calendar button on mouseover only"]                              = "Botão de calendário somente ao passar o mouse"
L["Hide calendar button until you hover over the minimap."]         = "Oculta o botão de calendário até passar o mouse sobre o minimapa."
L["Show zoom buttons"]                                              = "Mostrar botões de zoom"
L["Show the + and - zoom buttons on the minimap."]                  = "Mostra os botões de zoom + e - no minimapa."
L["Zoom buttons on mouseover only"]                                 = "Botões de zoom somente ao passar o mouse"
L["Hide zoom buttons until you hover over the minimap."]            = "Oculta os botões de zoom até passar o mouse sobre o minimapa."

-- =====================================================================
-- OptionsData.lua Vista — Display
-- =====================================================================
L["Border"]                                                         = "Borda"
L["Show a border around the minimap."]                              = "Mostra uma borda ao redor do minimapa."
L["Border color"]                                                   = "Cor da borda"
L["Color (and opacity) of the minimap border."]                     = "Cor (e opacidade) da borda do minimapa."
L["Border thickness"]                                               = "Espessura da borda"
L["Thickness of the minimap border in pixels (1–8)."]               = "Espessura da borda do minimapa em pixels (1–8)."
L["Text Positions"]                                                 = "Posições do Texto"
L["Drag text elements to reposition them. Lock to prevent accidental movement."] = "Arraste os elementos de texto para reposicioná-los. Bloqueie para evitar movimentos acidentais."
L["Lock zone text position"]                                        = "Bloquear posição do texto da zona"
L["When on, the zone text cannot be dragged."]                      = "Ativado: o texto da zona não pode ser arrastado."
L["Lock coordinates position"]                                      = "Bloquear posição das coordenadas"
L["When on, the coordinates text cannot be dragged."]               = "Ativado: o texto das coordenadas não pode ser arrastado."
L["Lock time position"]                                             = "Bloquear posição do horário"
L["When on, the time text cannot be dragged."]                      = "Ativado: o texto do horário não pode ser arrastado."
L["Lock difficulty text position"]                                  = "Bloquear posição do texto de dificuldade"
L["When on, the difficulty text cannot be dragged."]                = "Ativado: o texto de dificuldade não pode ser arrastado."
L["Button Positions"]                                               = "Posições dos Botões"
L["Drag buttons to reposition them. Lock to prevent movement."]     = "Arraste os botões para reposicioná-los. Bloqueie para fixar."
L["Lock Zoom In button"]                                            = "Bloquear botão Zoom +"
L["Prevent dragging the + zoom button."]                            = "Impede arrastar o botão de zoom +."
L["Lock Zoom Out button"]                                           = "Bloquear botão Zoom -"
L["Prevent dragging the - zoom button."]                            = "Impede arrastar o botão de zoom -."
L["Lock Tracking button"]                                           = "Bloquear botão de rastreamento"
L["Prevent dragging the tracking button."]                          = "Impede arrastar o botão de rastreamento."
L["Lock Calendar button"]                                           = "Bloquear botão de calendário"
L["Prevent dragging the calendar button."]                          = "Impede arrastar o botão de calendário."
L["Lock Queue button"]                                              = "Bloquear botão de fila"
L["Prevent dragging the queue status button."]                      = "Impede arrastar o botão de status da fila."
L["Disable queue button handling"]                                  = "Desativar gerenciamento do botão de fila"
L["Turn off all queue button anchoring (use if another addon manages it)."] = "Desativa toda ancoragem do botão de fila (use se outro addon o gerencia)."
L["Button Sizes"]                                                   = "Tamanhos dos Botões"
L["Adjust the size of minimap overlay buttons."]                    = "Ajusta o tamanho dos botões sobrepostos ao minimapa."
L["Tracking button size"]                                           = "Tamanho do botão de rastreamento"
L["Size of the tracking button (pixels)."]                          = "Tamanho do botão de rastreamento (pixels)."
L["Calendar button size"]                                           = "Tamanho do botão de calendário"
L["Size of the calendar button (pixels)."]                          = "Tamanho do botão de calendário (pixels)."
L["Queue button size"]                                              = "Tamanho do botão de fila"
L["Size of the queue status button (pixels)."]                      = "Tamanho do botão de status da fila (pixels)."
L["Zoom button size"]                                               = "Tamanho dos botões de zoom"
L["Size of the zoom in / zoom out buttons (pixels)."]               = "Tamanho dos botões de zoom + / - (pixels)."
L["Mail indicator size"]                                            = "Tamanho do indicador de correio"
L["Size of the new mail icon (pixels)."]                            = "Tamanho do ícone de novo correio (pixels)."
L["Addon button size"]                                              = "Tamanho dos botões de addon"
L["Size of collected addon minimap buttons (pixels)."]              = "Tamanho dos botões de addon coletados no minimapa (pixels)."

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
L["Minimap Addon Buttons"]                                          = "Botões de Addon no Minimapa"
L["Button Management"]                                              = "Gerenciamento de Botões"
L["Manage addon minimap buttons"]                                   = "Gerenciar botões de addon no minimapa"
L["When on, Vista takes control of addon minimap buttons and groups them by the selected mode."] = "Ativado: Vista assume o controle dos botões de addon e os agrupa pelo modo selecionado."
L["Button mode"]                                                    = "Modo dos botões"
L["How addon buttons are presented: hover bar below minimap, panel on right-click, or floating drawer button."] = "Como os botões de addon são apresentados: barra ao passar o mouse, painel ao clicar com o botão direito ou botão gaveta flutuante."
L["Mouseover bar"]                                                  = "Barra ao passar o mouse"
L["Right-click panel"]                                              = "Painel com botão direito"
L["Floating drawer"]                                                = "Gaveta flutuante"
L["Lock drawer button position"]                                    = "Bloquear posição do botão gaveta"
L["Prevent dragging the floating drawer button."]                   = "Impede arrastar o botão da gaveta flutuante."
L["Lock mouseover bar position"]                                    = "Bloquear posição da barra ao passar o mouse"
L["Prevent dragging the mouseover button bar."]                     = "Impede arrastar a barra de botões ao passar o mouse."
L["Lock right-click panel position"]                                = "Bloquear posição do painel de botão direito"
L["Prevent dragging the right-click panel."]                        = "Impede arrastar o painel de botão direito."
L["Buttons per row/column"]                                         = "Botões por linha/coluna"
L["Controls how many buttons appear before wrapping. For left/right direction this is columns; for up/down it is rows."] = "Controla quantos botões aparecem antes de quebrar. Para esquerda/direita são colunas; para cima/baixo são linhas."
L["Expand direction"]                                               = "Direção de expansão"
L["Direction buttons fill from the anchor point. Left/Right = horizontal rows. Up/Down = vertical columns."] = "Direção de preenchimento a partir do ponto de ancoragem. Esquerda/Direita = linhas horizontais. Cima/Baixo = colunas verticais."
L["Right"]                                                          = "Direita"
L["Left"]                                                           = "Esquerda"
L["Down"]                                                           = "Baixo"
L["Up"]                                                             = "Cima"
L["Panel Appearance"]                                               = "Aparência do Painel"
L["Colors for the drawer and right-click button panels."]           = "Cores para os painéis de botões (gaveta e botão direito)."
L["Panel background color"]                                         = "Cor de fundo do painel"
L["Background color of the addon button panels."]                   = "Cor de fundo dos painéis de botões de addon."
L["Panel border color"]                                             = "Cor da borda do painel"
L["Border color of the addon button panels."]                       = "Cor da borda dos painéis de botões de addon."
L["Managed buttons"]                                                = "Botões gerenciados"
L["When off, this button is completely ignored by this addon."]     = "Desativado: este botão é completamente ignorado por este addon."
L["(No addon buttons detected yet)"]                                = "(Nenhum botão de addon detectado ainda)"
L["Visible buttons (check to include)"]                             = "Botões visíveis (marque para incluir)"
L["(No addon buttons detected yet — open your minimap first)"]      = "(Nenhum botão de addon detectado — abra o minimapa primeiro)"


-- =====================================================================
-- New strings recently updated
-- =====================================================================
L["Vista"]                                                          = "Vista"
L["Profiles"]                                                       = "Perfis"
L["Current profile"]                                                = "Perfil atual"
L["Select the profile currently in use."]                           = "Selecione o perfil em uso no momento."
L["Use global profile (account-wide)"]                              = "Usar perfil global (conta inteira)"
L["All characters use the same profile."]                           = "Todos os personagens usam o mesmo perfil."
L["Enable per specialization profiles"]                             = "Ativar perfis por especialização"
L["Pick different profiles per spec."]                              = "Escolha perfis diferentes por especialização."
L["Specialization"]                                                 = "Especialização"
L["Sharing"]                                                        = "Compartilhamento"
L["Import profile"]                                                 = "Importar perfil"
L["Import string"]                                                  = "String de importação"
L["Export profile"]                                                 = "Exportar perfil"
L["Select a profile to export."]                                    = "Selecione um perfil para exportar."
L["Export string"]                                                  = "String de exportação"
L["Copy from profile"]                                              = "Copiar de perfil"
L["Source profile for copying."]                                    = "Perfil de origem para cópia."
L["Copy from selected"]                                             = "Copiar do selecionado"
L["Create"]                                                         = "Criar"
L["Create new profile from Default template"]                       = "Criar novo perfil a partir do modelo Padrão"
L["Creates a new profile with all default settings."]               = "Cria um novo perfil com todas as configurações padrão."
L["Creates a new profile copied from the selected source profile."] = "Cria um novo perfil copiado do perfil de origem selecionado."
L["Delete profile"]                                                 = "Excluir perfil"
L["Select a profile to delete (current and Default not shown)."]    = "Selecione um perfil para excluir (atual e Padrão não aparecem)."
L["Delete selected"]                                                = "Excluir selecionado"
L["Delete"]                                                         = "Excluir"
L["Deletes the selected profile."]                                  = "Exclui o perfil selecionado."
L["Blacklist"]                                                      = "Lista negra"
L["Objective prefix"]                                               = "Prefixo dos objetivos"
L["Prefix each objective with a number or hyphen."]                 = "Prefixa cada objetivo com número ou hífen."
L["Numbers (1. 2. 3.)"]                                             = "Números (1. 2. 3.)"
L["Hyphens (-)"]                                                    = "Hífens (-)"
L["Cinematic square minimap with zone text, coordinates, time, and button collector."] = "Minimapa quadrado cinematográfico com texto de zona, coordenadas, horário e coletor de botões."
L["Always show mouseover bar (for positioning)"]                    = "Sempre mostrar barra ao passar o mouse (para posicionamento)"
L["Keep the mouseover bar visible at all times so you can reposition it. Disable when done."] = "Mantém a barra visível o tempo todo para você reposicioná-la. Desative quando terminar."
L["Mouseover Bar Appearance"]                                       = "Aparência da barra ao passar o mouse"
L["Background and border for the mouseover button bar."]            = "Fundo e borda da barra de botões ao passar o mouse."
L["Backdrop color"]                                                 = "Cor do fundo"
L["Background color of the mouseover button bar (use alpha to control transparency)."] = "Cor de fundo da barra de botões ao passar o mouse (use alfa para controlar a transparência)."
L["Show bar border"]                                                = "Mostrar borda da barra"
L["Show a border around the mouseover button bar."]                 = "Mostra uma borda ao redor da barra de botões ao passar o mouse."
L["Bar border color"]                                               = "Cor da borda da barra"
L["Border color of the mouseover button bar."]                      = "Cor da borda da barra de botões ao passar o mouse."
L["Bar background color"]                                           = "Cor de fundo da barra"
L["Panel background color."]                                        = "Cor de fundo do painel."
L["Close / Fade Timing"]                                            = "Tempo de fechamento/esmaecimento"
L["Mouseover bar — close delay (seconds)"]                          = "Barra ao passar o mouse — atraso para fechar (segundos)"
L["How long (in seconds) the bar stays visible after the cursor leaves. 0 = instant fade."] = "Por quanto tempo (em segundos) a barra permanece visível após o cursor sair. 0 = esmaecimento instantâneo."
L["Right-click panel — close delay (seconds)"]                      = "Painel de clique direito — atraso para fechar (segundos)"
L["How long (in seconds) the panel stays open after the cursor leaves. 0 = never auto-close (close by right-clicking again)."] = "Por quanto tempo (em segundos) o painel fica aberto após o cursor sair. 0 = nunca fechar automaticamente (feche clicando com o botão direito novamente)."
L["Floating drawer — close delay (seconds)"]                        = "Gaveta flutuante — atraso para fechar (segundos)"
L["How long (in seconds) the drawer panel stays open after clicking away. 0 = never auto-close (close only by clicking the drawer button again)."] = "Por quanto tempo (em segundos) o painel da gaveta permanece aberto após clicar fora. 0 = nunca fechar automaticamente (feche apenas clicando no botão da gaveta novamente)."
L["Mail icon blink"]                                                = "Piscar ícone de correio"
L["When on, the mail icon pulses to draw attention. When off, it stays at full opacity."] = "Ativado: o ícone de correio pulsa para chamar atenção. Desativado: permanece com opacidade total."
L["Item Tooltip"]                                                   = "Tooltip de item"
L["Show transmog status"]                                           = "Mostrar status de transmog"
L["Show whether you have collected the appearance of an item you hover over."] = "Mostra se você já coletou a aparência do item sobre o qual está com o mouse."
L["Player Tooltip"]                                                 = "Tooltip de jogador"
L["Show guild rank"]                                                = "Mostrar cargo da guilda"
L["Append the player's guild rank next to their guild name."]       = "Adiciona o cargo da guilda do jogador ao lado do nome da guilda."
L["Show Mythic+ score"]                                             = "Mostrar pontuação de Mítica+"
L["Show the player's current season Mythic+ score, colour-coded by tier."] = "Mostra a pontuação de Mítica+ da temporada atual do jogador, com cor por faixa."
L["Show item level"]                                                = "Mostrar nível de item"
L["Show the player's equipped item level after inspecting them."]   = "Mostra o nível de item equipado do jogador após inspecioná-lo."
L["Show honor level"]                                               = "Mostrar nível de honra"
L["Show the player's PvP honor level in the tooltip."]              = "Mostra o nível de honra JxJ do jogador no tooltip."
L["Show PvP title"]                                                 = "Mostrar título JxJ"
L["Show the player's PvP title (e.g. Gladiator) in the tooltip."]   = "Mostra o título JxJ do jogador (ex.: Gladiador) no tooltip."
L["Show status badges"]                                             = "Mostrar badges de status"
L["Show inline badges for combat, AFK, DND, PvP flag, party/raid membership, friends, and whether the player is targeting you."] = "Mostra badges em linha para combate, AUS, NOP, marcação JxJ, grupo/raide, amigos e se o jogador está mirando em você."
L["Show mount info"]                                                = "Mostrar informações da montaria"
L["When hovering a mounted player, show their mount name, source, and whether you own it."] = "Ao passar o mouse sobre um jogador montado, mostra nome da montaria, origem e se você a possui."
L["Presence: Playing demo reel (all notification types)..."]        = "Presence: reproduzindo demo (todos os tipos de notificação)..."
L["  /h presence debugtypes - Dump notification toggles and Blizzard suppression state"] = "  /h presence debugtypes - Exibir toggles de notificação e estado de supressão da Blizzard"
L["Find a Group"]                                                   = "Encontrar um Grupo"
L["Click to search for a group for this quest."]                   = "Clique para procurar um grupo para esta missao."
