if GetLocale() ~= "ptBR" then return end

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = setmetatable({}, { __index = addon.L })
addon.L = L
addon.StandardFont = UNIT_NAME_FONT

-- =====================================================================
-- OptionsPanel.lua (deprecated) — remaining strings for that UI
-- Panel title + module short names: addon.BrandDisplay (core/BrandDisplay.lua).
-- =====================================================================
L["OPTIONS_FOCUS_OTHER"]                                              = "Outro"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["OPTIONS_FOCUS_QUEST_TYPES"]                                        = "Tipos de Missões"
L["OPTIONS_FOCUS_ELEMENT_OVERRIDES"]                                  = "Cores por Elemento"
L["OPTIONS_FOCUS_PER_CATEGORY"]                                       = "Cores por Categoria"
L["OPTIONS_FOCUS_GROUPING_OVERRIDES"]                                 = "Cores Prioritárias"
-- L["OPTIONS_FOCUS_SECTION_OVERRIDES"]                               = "Section Overrides"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_COLORS"]                                             = "Outras Cores"

-- =====================================================================
-- OptionsPanel.lua — Color row labels (collapsible group sub-rows)
-- =====================================================================
L["OPTIONS_FOCUS_SECTION"]                                            = "Seção"
L["OPTIONS_FOCUS_TITLE"]                                              = "Título"
L["OPTIONS_FOCUS_ZONE"]                                               = "Zona"
L["OPTIONS_FOCUS_OBJECTIVE"]                                          = "Objetivo"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["OPTIONS_FOCUS_READY_TURN_OVERRIDES_BASE_COLOURS"]                  = "Pronto para Entregar substitui as cores base"
L["OPTIONS_FOCUS_READY_TURN_COLOURS_QUESTS"]                          = "As missões prontas para entregar usam suas cores nesta seção."
L["OPTIONS_FOCUS_CURRENT_ZONE_OVERRIDES_BASE_COLOURS"]                = "Zona Atual substitui as cores base"
L["OPTIONS_FOCUS_CURRENT_ZONE_COLOURS_QUESTS_SEC"]                    = "As missões da zona atual usam suas cores nesta seção."
L["OPTIONS_FOCUS_CURRENT_QUEST_OVERRIDES_BASE_COLOURS"]               = "Missão Atual substitui as cores base"
L["OPTIONS_FOCUS_CURRENT_QUEST_COLOURS_QUESTS_SE"]                    = "As missões da seção Missão Atual usam suas cores nesta seção."
L["OPTIONS_FOCUS_DISTINCT_COLOR_COMPLETED_OBJECTIVES"]                = "Usar cor distinta para objetivos completos"
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES_E_G_COLOR_B"]                   = "Ativado: objetivos completos (ex. 1/1) usam a cor abaixo. Desativado: eles usam a mesma cor que objetivos incompletos."
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVE"]                                = "Objetivo Completo"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["OPTIONS_FOCUS_RESET"]                                              = "Redefinir"
L["OPTIONS_FOCUS_RESET_QUEST_TYPES"]                                  = "Redefinir tipos de missões"
L["OPTIONS_FOCUS_RESET_OVERRIDES"]                                    = "Redefinir cores personalizadas"
L["OPTIONS_FOCUS_RESET_DEFAULTS"]                                     = "Redefinir tudo para padrões"
L["OPTIONS_FOCUS_RESET_TO_DEFAULTS"]                                  = "Redefinir para padrões"
L["OPTIONS_FOCUS_RESET_DEFAULT"]                                      = "Redefinir para padrão"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["OPTIONS_FOCUS_SEARCH_SETTINGS"]                                    = "Buscar configurações..."
L["OPTIONS_FOCUS_SEARCH_FONTS"]                                       = "Buscar fonte..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["OPTIONS_FOCUS_DRAG_RESIZE"]                                        = "Arrastar para redimensionar"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
L["OPTIONS_AXIS_PROFILES"]                                            = "Perfis"
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
-- L["DASH_WELCOME_PATH"]                                             = "%s → %s → %s"  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_COMING_SOON_TITLE"]                                = "Coming Soon"  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_COMING_SOON_TAGLINE"]                              = "New welcome experiences are on the way."  -- NEEDS TRANSLATION
-- L["DASH_WELCOME_COMING_SOON_BODY"]                                 = [=[Watch this space — we will post updates here and in |cffaaaaaaPatch Notes|r. Join |cffaaaaaaDiscord|r from the links below for news and feedback.]=]  -- NEEDS TRANSLATION
L["DASH_WELCOME_CLASS_ICONS_HEADING"]                                 = "Horizon class icons"
-- L["DASH_WELCOME_CLASS_ICONS_LEAD"]                                 = [=[We have added a bundled set of custom class icons — now the default when you choose |cffaaaaaaHorizon|r under |cffaaaaaaAxis → Global Toggles|r (Class icon style).]=]  -- NEEDS TRANSLATION
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
-- L["DASH_LAYOUT"]                                                   = "Layout"  -- NEEDS TRANSLATION
L["DASH_VISIBILITY"]                                                  = "Visibilidade"
L["DASH_DISPLAY"]                                                     = "Exibição"
L["DASH_FEATURES"]                                                    = "Recursos"
L["DASH_TYPOGRAPHY"]                                                  = "Tipografia"
L["DASH_APPEARANCE"]                                                  = "Aparência"
L["DASH_COLORS"]                                                      = "Cores"
L["DASH_ORGANIZATION"]                                                = "Organização"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["OPTIONS_FOCUS_PANEL_BEHAVIOUR"]                                    = "Comportamento do Painel"
L["OPTIONS_FOCUS_DIMENSIONS"]                                         = "Dimensões"
L["OPTIONS_FOCUS_INSTANCE"]                                           = "Instância"
-- L["OPTIONS_FOCUS_INSTANCES"]                                       = "Instances"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_COMBAT"]                                             = "Combate"
L["OPTIONS_FOCUS_FILTERING"]                                          = "Filtragem"
L["OPTIONS_FOCUS_HEADER"]                                             = "Cabeçalho"
-- L["OPTIONS_FOCUS_SECTIONS_STRUCTURE"]                              = "Sections & structure"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_ENTRY_DETAILS"]                                   = "Entry details"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_PROGRESS_TIMERS"]                                 = "Progress & timers"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_EMPHASIS"]                                        = "Focus emphasis"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_LIST"]                                               = "Lista"
L["OPTIONS_FOCUS_SPACING"]                                            = "Espaçamento"
L["OPTIONS_FOCUS_RARE_BOSSES"]                                        = "Chefes Raros"
L["OPTIONS_FOCUS_WORLD_QUESTS"]                                       = "Missões Mundiais"
L["OPTIONS_FOCUS_FLOATING_QUEST_ITEM"]                                = "Item de Missão Flutuante"
L["OPTIONS_FOCUS_MYTHIC"]                                             = "Mítica+"
L["OPTIONS_FOCUS_ACHIEVEMENTS"]                                       = "Conquistas"
L["OPTIONS_FOCUS_ENDEAVORS"]                                          = "Empreendimentos"
L["OPTIONS_FOCUS_DECOR"]                                              = "Decoração"
-- L["OPTIONS_FOCUS_APPEARANCES"]                                     = "Appearances"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_SCENARIO_DELVE"]                                     = "Cenário e Delve"
L["OPTIONS_FOCUS_FONT"]                                               = "Fonte"
-- L["OPTIONS_FOCUS_FONT_FAMILIES"]                                   = "Font families"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_GLOBAL_FONT_SIZE"]                                = "Global font size"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_FONT_SIZES"]                                      = "Font sizes"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_PER_ELEMENT_FONTS"]                               = "Per-element fonts"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_TEXT_CASE"]                                          = "Caixa de Texto"
L["OPTIONS_FOCUS_SHADOW"]                                             = "Sombra"
L["OPTIONS_FOCUS_PANEL"]                                              = "Painel"
L["OPTIONS_FOCUS_HIGHLIGHT"]                                          = "Destaque"
L["OPTIONS_FOCUS_COLOR_MATRIX"]                                       = "Matriz de Cores"
L["OPTIONS_FOCUS_ORDER"]                                              = "Ordem"
L["OPTIONS_FOCUS_SORT"]                                               = "Classificação"
L["OPTIONS_FOCUS_BEHAVIOUR"]                                          = "Comportamento"
L["OPTIONS_FOCUS_CONTENT_TYPES"]                                      = "Tipos de Conteúdo"
-- L["OPTIONS_FOCUS_DELVES"]                                          = "Delves"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_DELVES_DUNGEONS"]                                    = "Delves e Masmorras"
L["OPTIONS_FOCUS_DELVE_COMPLETE"]                                     = "Delve concluído"
L["OPTIONS_FOCUS_INTERACTIONS"]                                       = "Interações"
L["OPTIONS_FOCUS_TRACKING"]                                           = "Rastreamento"
L["OPTIONS_FOCUS_SCENARIO_BAR"]                                       = "Barra de Cenário"

-- =====================================================================
-- OptionsData.lua Profiles
-- =====================================================================
L["OPTIONS_AXIS_CURRENT_PROFILE"]                                     = "Perfil atual"
L["OPTIONS_AXIS_SELECT_PROFILE_CURRENTLY"]                            = "Selecione o perfil em uso no momento."
L["OPTIONS_AXIS_GLOBAL_PROFILE_ACCOUNT_WIDE"]                         = "Usar perfil global (conta inteira)"
L["OPTIONS_AXIS_CHARACTERS_SAME_PROFILE"]                             = "Todos os personagens usam o mesmo perfil."
L["OPTIONS_AXIS_ENABLE_PER_SPECIALIZATION_PROFILES"]                  = "Ativar perfis por especialização"
L["OPTIONS_AXIS_PICK_DIFFERENT_PROFILES_PER_SPEC"]                    = "Escolha perfis diferentes por especialização."
L["OPTIONS_AXIS_SPECIALIZATION"]                                      = "Especialização"
L["OPTIONS_AXIS_SHARING"]                                             = "Compartilhamento"
L["OPTIONS_AXIS_IMPORT_PROFILE"]                                      = "Importar perfil"
L["OPTIONS_AXIS_IMPORT_STRING"]                                       = "String de importação"
L["OPTIONS_AXIS_EXPORT_PROFILE"]                                      = "Exportar perfil"
L["OPTIONS_AXIS_SELECT_A_PROFILE_EXPORT"]                             = "Selecione um perfil para exportar."
L["OPTIONS_AXIS_EXPORT_STRING"]                                       = "String de exportação"
L["OPTIONS_AXIS_COPY_PROFILE"]                                        = "Copiar de perfil"
L["OPTIONS_AXIS_SOURCE_PROFILE_COPYING"]                              = "Perfil de origem para cópia."
L["OPTIONS_AXIS_COPY_SELECTED"]                                       = "Copiar do selecionado"
L["OPTIONS_AXIS_CREATE"]                                              = "Criar"
L["OPTIONS_AXIS_CREATE_PROFILE_DEFAULT_TEMPLATE"]                     = "Criar novo perfil a partir do modelo Padrão"
L["OPTIONS_AXIS_CREATES_A_PROFILE_DEFAULT_SETTINGS"]                  = "Cria um novo perfil com todas as configurações padrão."
L["OPTIONS_AXIS_CREATES_A_PROFILE_COPIED_SELECTED_SOURC"]             = "Cria um novo perfil copiado do perfil de origem selecionado."
L["OPTIONS_AXIS_DELETE_PROFILE"]                                      = "Excluir perfil"
L["OPTIONS_AXIS_SELECT_A_PROFILE_DELETE_CURRENT_DEFAULT"]             = "Selecione um perfil para excluir (atual e Padrão não aparecem)."
L["OPTIONS_AXIS_DELETE_SELECTED"]                                     = "Excluir selecionado"
-- L["OPTIONS_AXIS_DELETE_SELECTED_PROFILE"]                          = "Delete selected profile"  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_DELETE"]                                              = "Excluir"
L["OPTIONS_AXIS_DELETES_SELECTED_PROFILE"]                            = "Exclui o perfil selecionado."
-- L["OPTIONS_AXIS_GLOBAL_PROFILE"]                                   = "Global profile"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_PER_SPEC_PROFILES"]                                = "Per-spec profiles"  -- NEEDS TRANSLATION

-- =====================================================================
-- OptionsData.lua Modules
-- =====================================================================
L["OPTIONS_AXIS_ENABLE_FOCUS_MODULE"]                                 = "Ativar Módulo de Foco"
L["OPTIONS_AXIS_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS_R"]             = "Mostra o rastreador de objetivos para missões, missões mundiais, chefes raros, conquistas e cenários."
L["OPTIONS_AXIS_ENABLE_PRESENCE_MODULE"]                              = "Ativar Módulo de Presença"
L["OPTIONS_AXIS_CINEMATIC_ZONE_TEXT_NOTIFICATIONS_ZONE_CHANGES"]      = "Texto de zona cinematográfico e notificações (mudanças de zona, up de nível, emotes de chefes, conquistas, atualizações de missões)."
L["OPTIONS_AXIS_ENABLE_CACHE_MODULE"]                                 = "Ativar Módulo de Rendimento"
L["OPTIONS_AXIS_CINEMATIC_LOOT_NOTIFICATIONS_ITEMS_MONEY_CURRENCY"]   = "Notificações cinematográficas de saque (itens, dinheiro, moedas, reputação)."
L["OPTIONS_AXIS_ENABLE_VISTA_MODULE"]                                 = "Ativar Módulo Vista"
L["OPTIONS_AXIS_CINEMATIC_SQUARE_MINIMAP_ZONE_TEXT_COORDINATES"]      = "Minimapa quadrado cinematográfico com texto de zona, coordenadas e coletor de botões."
L["OPTIONS_AXIS_MINIMAP_ZONE_TIME_COLLECTOR"]                         = "Minimapa quadrado cinematográfico com texto de zona, coordenadas, horário e coletor de botões."
-- L["OPTIONS_AXIS_BETA"]                                             = "Beta"  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_SCALING"]                                             = "Escala"
-- L["OPTIONS_AXIS_GLOBAL_TOGGLES"]                                   = "Global Toggles"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_PATCH_NOTES_SECTION"]                              = "Patch notes"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN"]                   = "Show Patch Notes automatically after an update"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN_DESC"]              = "When on, Axis opens to Patch Notes once after each new addon version. When off, a green dot appears on the Horizon minimap icon until you open Patch Notes."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_SUITE_WIDE_CLASS_COLOUR_TINTING_UI"]               = "Dashboard background theme, class colour tinting, and UI scale (global or per module)."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_GLOBAL_UI_SCALE"]                                     = "Escala global da interface"
L["OPTIONS_AXIS_SCALE_SIZES_SPACINGS_FONTS_FACTOR"]                   = "Escala todos os tamanhos, espaçamentos e fontes por este fator (50–200%). Não altera seus valores configurados."
L["OPTIONS_AXIS_PER_MODULE_SCALING"]                                  = "Escala por módulo"
L["OPTIONS_AXIS_OVERRIDE_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_FO"]         = "Substitui a escala global por controles individuais para cada módulo."
-- L["OPTIONS_AXIS_OVERRIDES_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_F"]      = "Overrides the global scale with individual sliders for Focus, Presence, Vista, etc."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_DOESN_T_CHANGE_YOUR_CONFIGURED_VALUES"]            = "Doesn't change your configured values, only the effective display scale."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_SCALE"]                                              = "Escala do Focus"
L["OPTIONS_AXIS_SCALE_FOCUS_OBJECTIVE_TRACKER"]                       = "Escala do rastreador de objetivos Focus (50–200%)."
L["OPTIONS_PRESENCE_SCALE"]                                           = "Escala do Presence"
L["OPTIONS_AXIS_SCALE_PRESENCE_CINEMATIC_TEXT"]                       = "Escala do texto cinemático Presence (50–200%)."
L["OPTIONS_VISTA_SCALE"]                                              = "Escala do Vista"
L["OPTIONS_AXIS_SCALE_VISTA_MINIMAP_MODULE"]                          = "Escala do módulo de minimapa Vista (50–200%)."
L["OPTIONS_INSIGHT_SCALE"]                                            = "Escala do Insight"
L["OPTIONS_AXIS_SCALE_INSIGHT_TOOLTIP_MODULE"]                        = "Escala do módulo de tooltip Insight (50–200%)."
L["OPTIONS_CACHE_SCALE"]                                              = "Escala do Cache"
L["OPTIONS_AXIS_SCALE_CACHE_LOOT_TOAST_MODULE"]                       = "Escala do módulo de notificação de saque Cache (50–200%)."
L["OPTIONS_AXIS_ENABLE_HORIZON_INSIGHT_MODULE"]                       = "Ativar Módulo Horizon Insight"
L["OPTIONS_AXIS_CINEMATIC_TOOLTIPS_CLASS_COLORS_SPEC_DISPLAY"]        = "Tooltips cinematográficos com cores de classe, exibição de especialização e ícones de facção."
L["OPTIONS_AXIS_TOOLTIP_ANCHOR_MODE"]                                 = "Modo de âncora do tooltip"
L["OPTIONS_AXIS_WHERE_TOOLTIPS_APPEAR_FOLLOW_CURSOR_FIXED"]           = "Onde os tooltips aparecem: seguir o cursor ou posição fixa."
-- L["OPTIONS_AXIS_CURSOR"]                                           = "Cursor"  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_FIXED"]                                               = "Fixo"
L["OPTIONS_AXIS_ANCHOR_MOVE"]                                         = "Mostrar âncora para mover"
-- L["OPTIONS_AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITIO"]                   = "Click to show or hide the anchor. Drag to set position, right-click to confirm."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_DRAGGABLE_FRAME_FIXED_TOOLTIP_POSITION_D"]            = "Mostra quadro arrastável para definir posição fixa do tooltip. Arraste e clique com o botão direito para confirmar."
L["OPTIONS_AXIS_RESET_TOOLTIP_POSITION"]                              = "Redefinir posição do tooltip"
L["OPTIONS_AXIS_RESET_FIXED_POSITION_DEFAULT"]                        = "Redefinir posição fixa para o padrão."
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_X"]                               = "Cursor offset X"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_X_DESC"]                          = "Horizontal pixel offset from the default cursor tooltip position (cursor anchor only)."  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_Y"]                               = "Cursor offset Y"  -- NEEDS TRANSLATION
-- L["OPTIONS_INSIGHT_CURSOR_OFFSET_Y_DESC"]                          = "Vertical pixel offset from the default cursor tooltip position (cursor anchor only)."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_TOOLTIP_BACKGROUND_COLOR"]                            = "Cor de fundo do tooltip"
L["OPTIONS_AXIS_COLOR_OF_TOOLTIP_BACKGROUND"]                         = "Cor de fundo do tooltip."
L["OPTIONS_AXIS_TOOLTIP_BACKGROUND_OPACITY"]                          = "Opacidade do fundo do tooltip"
L["OPTIONS_AXIS_TOOLTIP_BG_OPACITY_PCT_DESC"]                         = "Opacidade do fundo do tooltip (0–100%)."
L["OPTIONS_AXIS_TOOLTIP_FONT"]                                        = "Fonte do tooltip"
L["OPTIONS_AXIS_FONT_FAMILY_TOOLTIP_TEXT"]                            = "Família de fontes usada para todo o texto do tooltip."
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
L["OPTIONS_AXIS_ITEM_TOOLTIP"]                                        = "Tooltip de item"
L["OPTIONS_AXIS_TRANSMOG_STATUS"]                                     = "Mostrar status de transmog"
L["OPTIONS_AXIS_WHETHER_YOU_COLLECTED_APPEARANCE_OF_AN"]              = "Mostra se você já coletou a aparência do item sobre o qual está com o mouse."
L["OPTIONS_AXIS_PLAYER_TOOLTIP"]                                      = "Tooltip de jogador"
L["OPTIONS_AXIS_GUILD_RANK"]                                          = "Mostrar cargo da guilda"
L["OPTIONS_AXIS_APPEND_PLAYER_S_GUILD_RANK_NEXT"]                     = "Adiciona o cargo da guilda do jogador ao lado do nome da guilda."
L["OPTIONS_AXIS_MYTHIC_SCORE"]                                        = "Mostrar pontuação de Mítica+"
L["OPTIONS_AXIS_PLAYER_S_CURRENT_SEASON_MYTHIC_SCORE"]                = "Mostra a pontuação de Mítica+ da temporada atual do jogador, com cor por faixa."
L["OPTIONS_AXIS_ITEM_LEVEL"]                                          = "Mostrar nível de item"
L["OPTIONS_AXIS_PLAYER_S_EQUIPPED_ITEM_LEVEL_AFTER"]                  = "Mostra o nível de item equipado do jogador após inspecioná-lo."
L["OPTIONS_AXIS_HONOR_LEVEL"]                                         = "Mostrar nível de honra"
L["OPTIONS_AXIS_PLAYER_S_PVP_HONOR_LEVEL_TOOLTIP"]                    = "Mostra o nível de honra JxJ do jogador no tooltip."
L["OPTIONS_AXIS_PVP_TITLE"]                                           = "Mostrar título JxJ"
L["OPTIONS_AXIS_PLAYER_S_PVP_TITLE_E_G"]                              = "Mostra o título JxJ do jogador (ex.: Gladiador) no tooltip."
-- L["OPTIONS_AXIS_CHARACTER_TITLE"]                                  = "Character title"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_PLAYER_S_SELECTED_TITLE_ACHIEVEMENT_PVP"]          = "Show the player's selected title (achievement or PvP) in the name line."  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_TITLE_COLOR"]                                      = "Title color"  -- NEEDS TRANSLATION
-- L["OPTIONS_AXIS_COLOR_OF_CHARACTER_TITLE_PLAYER_TOOLTIP"]          = "Color of the character title in the player tooltip name line."  -- NEEDS TRANSLATION
L["OPTIONS_AXIS_STATUS_BADGES"]                                       = "Mostrar badges de status"
L["OPTIONS_AXIS_INLINE_BADGES_COMBAT_AFK_DND_PVP"]                    = "Mostra badges em linha para combate, AUS, NOP, marcação JxJ, grupo/raide, amigos e se o jogador está mirando em você."
L["OPTIONS_AXIS_MOUNT_INFO"]                                          = "Mostrar informações da montaria"
L["OPTIONS_AXIS_HOVERING_A_MOUNTED_PLAYER_THEIR_MOUNT"]               = "Ao passar o mouse sobre um jogador montado, mostra nome da montaria, origem e se você a possui."
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
L["OPTIONS_AXIS_GENERAL"]                                             = "Geral"
L["OPTIONS_AXIS_POSITION"]                                            = "Posição"
L["OPTIONS_AXIS_RESET_POSITION"]                                      = "Redefinir Posição"
L["OPTIONS_AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"]                   = "Redefinir posição das notificações de saque."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["OPTIONS_FOCUS_LOCK_POSITION"]                                      = "Travar Posição"
L["OPTIONS_FOCUS_PREVENT_DRAGGING_TRACKER"]                           = "Impede de arrastar o rastreador."
L["OPTIONS_FOCUS_GROW_UPWARD"]                                        = "Crescer para Cima"
L["OPTIONS_FOCUS_GROW_HEADER"]                                        = "Cabeçalho ao crescer"
L["OPTIONS_FOCUS_GROWING_UPWARD_KEEP_HEADER_BOTTOM_TOP"]              = "Ao crescer para cima: manter cabeçalho embaixo ou em cima até colapsar."
L["OPTIONS_FOCUS_HEADER_BOTTOM"]                                      = "Cabeçalho embaixo"
L["OPTIONS_FOCUS_HEADER_SLIDES_COLLAPSE"]                             = "Cabeçalho desliza ao colapsar"
L["OPTIONS_FOCUS_ANCHOR_BOTTOM_LIST_GROWS_UPWARD"]                    = "Âncora na parte inferior para que a lista cresça para cima."
L["OPTIONS_FOCUS_START_COLLAPSED"]                                    = "Começar Colapsado"
L["OPTIONS_FOCUS_START_HEADER_SHOWN_UNTIL_YOU_EXPAND"]                = "Mostrar apenas o cabeçalho até expandir."
-- L["OPTIONS_FOCUS_ALIGN_CONTENT_RIGHT"]                             = "Align content right"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_RIGHT_ALIGN_QUEST_TITLES_OBJECTIVES_WITHIN"]      = "Right-align quest titles and objectives within the panel."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_PANEL_WIDTH"]                                        = "Largura do Painel"
L["OPTIONS_FOCUS_TRACKER_WIDTH_PIXELS"]                               = "Largura do rastreador em pixels."
L["OPTIONS_FOCUS_MAX_CONTENT_HEIGHT"]                                 = "Altura Máx. do Conteúdo"
L["OPTIONS_FOCUS_MAX_HEIGHT_OF_SCROLLABLE_LIST_PIXELS"]               = "Altura máxima da lista rolável (pixels)."

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["OPTIONS_FOCUS_ALWAYS_M_BLOCK"]                                     = "Sempre mostrar bloco M+"
L["OPTIONS_FOCUS_M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]                = "Mostrar o bloco M+ sempre que uma Pedra-Chave ativa estiver em andamento."
L["OPTIONS_FOCUS_DUNGEON"]                                            = "Mostrar em masmorra"
L["OPTIONS_FOCUS_TRACKER_PARTY_DUNGEONS"]                             = "Mostra o rastreador em masmorras de grupo."
L["OPTIONS_FOCUS_RAID"]                                               = "Mostrar em raide"
L["OPTIONS_FOCUS_TRACKER_RAIDS"]                                      = "Mostra o rastreador em raides."
L["OPTIONS_FOCUS_BATTLEGROUND"]                                       = "Mostrar em campo de batalha"
L["OPTIONS_FOCUS_TRACKER_BATTLEGROUNDS"]                              = "Mostra o rastreador em campos de batalha."
L["OPTIONS_FOCUS_ARENA"]                                              = "Mostrar em arena"
L["OPTIONS_FOCUS_TRACKER_ARENAS"]                                     = "Mostra o rastreador em arenas."
L["OPTIONS_FOCUS_HIDE_COMBAT"]                                        = "Ocultar em combate"
L["OPTIONS_FOCUS_HIDE_TRACKER_FLOATING_QUEST_ITEM_COMBAT"]            = "Oculta o rastreador e o item de missão flutuante em combate."
L["OPTIONS_FOCUS_COMBAT_VISIBILITY"]                                  = "Visibilidade em combate"
L["OPTIONS_FOCUS_TRACKER_BEHAVES_COMBAT_FADE_REDUC"]                  = "Comportamento do rastreador em combate: mostrar, esmaecer ou ocultar."
L["OPTIONS_FOCUS_SHOW"]                                               = "Mostrar"
L["OPTIONS_FOCUS_FADE"]                                               = "Esmaecer"
L["OPTIONS_FOCUS_HIDE"]                                               = "Ocultar"
L["OPTIONS_FOCUS_COMBAT_FADE_OPACITY"]                                = "Opacidade em combate (esmaecer)"
L["OPTIONS_FOCUS_VISIBLE_TRACKER_FADED_COMBAT"]                       = "Quão visível o rastreador fica quando esmaecido em combate (0 = invisível). Aplica-se apenas quando a visibilidade em combate é Esmaecer."
L["OPTIONS_FOCUS_MOUSEOVER"]                                          = "Passar o mouse"
L["OPTIONS_FOCUS_SHOW_ONLY_MOUSEOVER"]                                = "Mostrar somente ao passar o mouse"
L["OPTIONS_FOCUS_FADE_TRACKER_HOVERING_MOVE_MOUSE"]                   = "Esmaece o rastreador quando o mouse não está sobre ele; passe o mouse para mostrar."
L["OPTIONS_FOCUS_FADED_OPACITY"]                                      = "Opacidade esmaecida"
L["OPTIONS_FOCUS_VISIBLE_TRACKER_FADED_INVISIBLE"]                    = "Quão visível o rastreador fica quando esmaecido (0 = invisível)."
L["OPTIONS_FOCUS_QUESTS_CURRENT_ZONE"]                                = "Mostrar apenas missões na zona atual"
L["OPTIONS_FOCUS_HIDE_QUESTS_OUTSIDE_YOUR_CURRENT_ZONE"]              = "Oculta missões fora da sua zona atual."

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["OPTIONS_FOCUS_QUEST_COUNT"]                                        = "Mostrar contagem de missões"
L["OPTIONS_FOCUS_QUEST_COUNT_HEADER"]                                 = "Mostra a quantidade de missões no cabeçalho."
L["OPTIONS_FOCUS_HEADER_COUNT_FORMAT"]                                = "Formato da contagem do cabeçalho"
L["OPTIONS_FOCUS_TRACKED_LOG_LOG_MAX_SLOTS_TRACKED"]                  = "Rastreadas/no diário ou no diário/vagas máximas. Rastreadas excluem missões mundiais/em zona."
L["OPTIONS_FOCUS_HEADER_DIVIDER"]                                     = "Mostrar divisor do cabeçalho"
L["OPTIONS_FOCUS_LINE_BELOW_HEADER"]                                  = "Mostra a linha abaixo do cabeçalho."
L["OPTIONS_FOCUS_HEADER_DIVIDER_COLOR"]                               = "Cor do divisor do cabeçalho"
L["OPTIONS_FOCUS_COLOR_OF_LINE_BELOW_HEADER"]                         = "Cor da linha abaixo do cabeçalho."
L["OPTIONS_FOCUS_SUPER_MINIMAL_MODE"]                                 = "Modo super minimalista"
L["OPTIONS_FOCUS_HIDE_HEADER_A_PURE_TEXT_LIST"]                       = "Oculta o cabeçalho para ter apenas uma lista de texto."
L["OPTIONS_FOCUS_OPTIONS_BUTTON"]                                     = "Mostrar botão de Opções"
L["OPTIONS_FOCUS_OPTIONS_BUTTON_TRACKER_HEADER"]                      = "Mostra o botão de Opções no cabeçalho do rastreador."
L["OPTIONS_FOCUS_HEADER_COLOR"]                                       = "Cor do cabeçalho"
L["OPTIONS_FOCUS_COLOR_OF_OBJECTIVES_HEADER_TEXT"]                    = "Cor do texto do cabeçalho OBJECTIVES."
L["OPTIONS_FOCUS_HEADER_HEIGHT"]                                      = "Altura do cabeçalho"
L["OPTIONS_FOCUS_HEIGHT_OF_HEADER_BAR_PIXELS"]                        = "Altura da barra de cabeçalho em pixels (18–48)."

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["OPTIONS_FOCUS_SECTION_HEADERS"]                                    = "Mostrar cabeçalhos de seção"
L["OPTIONS_FOCUS_CATEGORY_LABELS_ABOVE_GROUP"]                        = "Mostra rótulos de categoria acima de cada grupo."
L["OPTIONS_FOCUS_CATEGORY_HEADERS_COLLAPSED"]                         = "Mostrar cabeçalhos ao recolher"
L["OPTIONS_FOCUS_KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED_CLICK"]       = "Mantém os cabeçalhos visíveis quando recolhidos; clique para expandir uma categoria."
L["OPTIONS_FOCUS_NEARBY_CURRENT_ZONE_GROUP"]                          = "Mostrar grupo Próximo (Zona Atual)"
L["OPTIONS_FOCUS_ZONE_QUESTS_A_DEDICATED_CURRENT_ZONE"]               = "Mostra missões da zona em uma seção Zona Atual dedicada. Desativado: elas aparecem na categoria normal."
L["OPTIONS_FOCUS_ZONE_LABELS"]                                        = "Mostrar nomes de zona"
L["OPTIONS_FOCUS_ZONE_NAME_UNDER_QUEST_TITLE"]                        = "Mostra o nome da zona abaixo de cada título de missão."
L["OPTIONS_FOCUS_ACTIVE_QUEST_HIGHLIGHT"]                             = "Destaque da missão ativa"
L["OPTIONS_FOCUS_FOCUSED_QUEST_HIGHLIGHTED"]                          = "Como a missão focada é destacada."
L["OPTIONS_FOCUS_QUEST_ITEM_BUTTONS"]                                 = "Mostrar botões de item de missão"
L["OPTIONS_FOCUS_USABLE_QUEST_ITEM_BUTTON_NEXT_QUEST"]                = "Mostra o botão de item utilizável ao lado de cada missão."
-- L["OPTIONS_FOCUS_TOOLTIPS_HOVER"]                                  = "Tooltips on hover"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_TOOLTIPS_HOVERING_TRACKER_ENTRIES_ITE"]           = "Show tooltips when hovering over tracker entries, item buttons, and scenario blocks."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_WOWHEAD_LINK_TOOLTIPS"]                           = "Show WoWhead link in tooltips"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_A_TOOLTIP_SHOWN_ADD_A_LINK"]                      = "When a tooltip is shown, add a link to open the quest, achievement, or NPC on WoWhead."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_VIEW_WOWHEAD"]                                    = "View on WoWhead"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_WOWHEAD_ALT_CLICK_HINT"]                             = "Alt+click row to copy"
-- L["OPTIONS_FOCUS_COPY_LINK"]                                       = "Copy link"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_COPY_URL_BELOW_CTRL_C_PASTE"]                     = "Copy the URL below (Ctrl+C) and paste in your browser."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_OBJECTIVE_NUMBERS"]                                  = "Mostrar números de objetivos"
L["OPTIONS_FOCUS_OBJECTIVE_PREFIX"]                                   = "Prefixo dos objetivos"
L["OPTIONS_FOCUS_PREFIX_OBJECTIVE_A_NUMBER_HYPHEN"]                   = "Prefixa cada objetivo com número ou hífen."
L["OPTIONS_FOCUS_NUMBERS"]                                            = "Números (1. 2. 3.)"
L["OPTIONS_FOCUS_HYPHENS"]                                            = "Hífens (-)"
-- L["OPTIONS_FOCUS_AFTER_SECTION_HEADER"]                            = "After section header"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_BEFORE_SECTION_HEADER"]                           = "Before section header"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_BELOW_HEADER"]                                    = "Below header"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_INLINE_BELOW_TITLE"]                              = "Inline below title"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_PREFIX_OBJECTIVES"]                                  = "Prefixa objetivos com 1., 2., 3."
L["OPTIONS_FOCUS_COMPLETED_COUNT"]                                    = "Mostrar contagem de concluídos"
L["OPTIONS_FOCUS_X_Y_PROGRESS_QUEST_TITLE"]                           = "Mostra o progresso X/Y no título da missão."
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_BAR"]                             = "Mostrar barra de progresso do objetivo"
L["OPTIONS_FOCUS_A_PROGRESS_BAR_UNDER_OBJECTIVES_NUMER"]              = "Mostra uma barra de progresso sob objetivos com progresso numérico (ex. 3/250). Aplica-se apenas a entradas com um único objetivo aritmético onde a quantidade necessária é maior que 1."
L["OPTIONS_FOCUS_CATEGORY_COLOR_PROGRESS_BAR"]                        = "Usar cor da categoria na barra de progresso"
L["OPTIONS_FOCUS_PROGRESS_BAR_MATCHES_QUEST_ACHIEVEME"]               = "Quando ativado: a barra de progresso usa a cor da categoria (missão, conquista). Quando desativado: usa a cor personalizada abaixo."
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXTURE"]                               = "Textura da barra de progresso"
L["OPTIONS_FOCUS_PROGRESS_BAR_TYPES"]                                 = "Tipos de barra de progresso"
L["OPTIONS_FOCUS_TEXTURE_PROGRESS_BAR_FILL"]                          = "Textura do preenchimento da barra."
L["OPTIONS_FOCUS_TEXTURE_PROGRESS_BAR_FILL_SOLID_YOUR"]               = "Textura do preenchimento. Sólido usa suas cores. Addons SharedMedia adicionam mais opções."
L["OPTIONS_FOCUS_PROGRESS_BAR_X_Y_OBJECTIVES_PERCENT"]                = "Mostrar barra para objetivos X/Y, apenas percentual ou ambos."
L["OPTIONS_FOCUS_X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]             = "X/Y: objetivos como 3/10. Percentual: objetivos como 45%."
L["OPTIONS_FOCUS_X_Y"]                                                = "Apenas X/Y"
L["OPTIONS_FOCUS_PERCENT"]                                            = "Apenas percentual"
L["OPTIONS_FOCUS_TICK_COMPLETED_OBJECTIVES"]                          = "Usar marca para objetivos concluídos"
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES_A_CHECKMARK_INSTEA"]            = "Ativado: objetivos concluídos mostram uma marca (✓) em vez de cor verde."
L["OPTIONS_FOCUS_ENTRY_NUMBERS"]                                      = "Mostrar números de entrada"
L["OPTIONS_FOCUS_PREFIX_QUEST_TITLES_WITHIN_CATEGORY"]                = "Prefixa títulos de missão com 1., 2., 3. em cada categoria."
L["OPTIONS_FOCUS_COMPLETED_OBJECTIVES"]                               = "Objetivos concluídos"
L["OPTIONS_FOCUS_MULTI_OBJECTIVE_QUESTS_DISPLAY_OBJECTIVES"]          = "Para missões com vários objetivos, como exibir objetivos concluídos (ex. 1/1)."
L["OPTIONS_FOCUS_ALL"]                                                = "Mostrar tudo"
L["OPTIONS_FOCUS_FADE_COMPLETED"]                                     = "Esmaecer concluídos"
L["OPTIONS_FOCUS_HIDE_COMPLETED"]                                     = "Ocultar concluídos"
L["OPTIONS_FOCUS_ICON_ZONE_AUTO_TRACKING"]                            = "Mostrar ícone de rastreamento automático na zona"
L["OPTIONS_FOCUS_DISPLAY_AN_ICON_NEXT_AUTO_TRACKED"]                  = "Exibe um ícone ao lado de missões mundiais e semanais/diárias rastreadas automaticamente que ainda não estão no seu registro de missões (apenas na zona)."
L["OPTIONS_FOCUS_AUTO_TRACK_ICON"]                                    = "Ícone de rastreamento automático"
L["OPTIONS_FOCUS_CHOOSE_WHICH_ICON_DISPLAY_NEXT_AUTO"]                = "Escolha qual ícone exibir ao lado das entradas rastreadas automaticamente na zona."
L["OPTIONS_FOCUS_APPEND_WORLD_QUESTS_WEEKLIES_DAILIES"]               = "Adiciona ** a missões mundiais e semanais/diárias que ainda não estão no seu diário (apenas na zona)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["OPTIONS_FOCUS_COMPACT_MODE"]                                       = "Modo compacto"
L["OPTIONS_FOCUS_PRESET_SETS_ENTRY_OBJECTIVE_SPACING_P"]              = "Predefinição: define espaçamento de entradas e objetivos para 4 e 1 px."
L["OPTIONS_FOCUS_SPACING_PRESET"]                                     = "Predefinição de espaçamento"
L["OPTIONS_FOCUS_PRESET_ENTRY_OBJECTIVE_SPACING_DEFAULT_P"]           = "Predefinição: Padrão (8/2 px), Compacto (4/1 px), Espaçado (12/3 px) ou Personalizado (usar sliders)."
L["OPTIONS_FOCUS_COMPACT_VERSION"]                                    = "Versão compacta"
L["OPTIONS_FOCUS_SPACED_VERSION"]                                     = "Versão espaçada"
L["OPTIONS_FOCUS_SPACING_BETWEEN_QUEST_ENTRIES_PX"]                   = "Espaçamento entre entradas de missão (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_QUEST_ENTRIES"]                 = "Espaço vertical entre entradas de missão."
L["OPTIONS_FOCUS_SPACING_BEFORE_CATEGORY_HEADER_PX"]                  = "Espaçamento antes do cabeçalho da categoria (px)"
L["OPTIONS_FOCUS_GAP_BETWEEN_LAST_ENTRY_OF_A"]                        = "Espaço entre a última entrada de um grupo e o próximo rótulo de categoria."
L["OPTIONS_FOCUS_SPACING_AFTER_CATEGORY_HEADER_PX"]                   = "Espaçamento após o cabeçalho da categoria (px)"
L["OPTIONS_FOCUS_GAP_BETWEEN_CATEGORY_LABEL_FIRST_QUEST"]             = "Espaço entre o rótulo da categoria e a primeira missão abaixo dele."
L["OPTIONS_FOCUS_SPACING_BETWEEN_OBJECTIVES_PX"]                      = "Espaçamento entre objetivos (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVE_LINES_WITHIN"]        = "Espaço vertical entre linhas de objetivos dentro de uma missão."
L["OPTIONS_FOCUS_TITLE_CONTENT"]                                      = "Título para conteúdo"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_QUEST_TITLE_OBJECTIVES"]        = "Espaço vertical entre o título da missão e os objetivos ou zona abaixo."
L["OPTIONS_FOCUS_SPACING_BELOW_HEADER_PX"]                            = "Espaçamento abaixo do cabeçalho (px)"
L["OPTIONS_FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVES_BAR_QUES"]           = "Espaço vertical entre a barra de objetivos e a lista de missões."
L["OPTIONS_FOCUS_RESET_SPACING"]                                      = "Redefinir espaçamento"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_QUEST_LEVEL"]                                   = "Mostrar nível da missão"
L["OPTIONS_FOCUS_QUEST_LEVEL_NEXT_TITLE"]                             = "Mostra o nível da missão ao lado do título."
L["OPTIONS_FOCUS_DIM_FOCUSED_QUESTS"]                                 = "Escurecer missões não focadas"
L["OPTIONS_FOCUS_SLIGHTLY_DIM_TITLE_ZONE_OBJECTIVES_SECTION"]         = "Escurece levemente títulos, zonas, objetivos e cabeçalhos de seção que não estão em foco."
-- L["OPTIONS_FOCUS_DIM_UNFOCUSED_ENTRIES"]                           = "Dim unfocused entries"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CLICK_A_SECTION_HEADER_EXPAND_CATEGORY"]          = "Click a section header to expand that category."  -- NEEDS TRANSLATION

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["UI_SHOW_RARE_BOSSES"]                                              = "Mostrar chefes raros"
L["UI_RARE_BOSS_VIGNETTES_LIST"]                                      = "Mostra chefes raros na lista."
L["UI_RARE_LOOT"]                                                     = "Saque raro"
L["UI_TREASURE_ITEM_VIGNETTES_RARE_LOOT"]                             = "Mostra tesouros e itens na lista de saque raro."
L["UI_RARE_SOUND_VOLUME"]                                             = "Volume do som de saque raro"
L["UI_VOLUME_OF_RARE_ALERT_SOUND"]                                    = "Volume do som de alerta de saque raro (50–200%)."
L["UI_BOOST_REDUCE_RARE_ALERT_VOLUME"]                                = "Aumente ou reduza o volume. 100% = normal; 150% = mais alto."
L["UI_RARE_ADDED_SOUND"]                                              = "Som ao adicionar raro"
L["UI_PLAY_A_SOUND_A_RARE"]                                           = "Reproduz um som quando um raro é adicionado."
-- L["UI_MINIMAP_PATCH_NOTES_UNREAD_HINT"]                            = "New patch notes — open Axis and choose Patch Notes."  -- NEEDS TRANSLATION

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["OPTIONS_FOCUS_ZONE_WORLD_QUESTS"]                                  = "Mostrar missões mundiais da zona"
L["OPTIONS_FOCUS_AUTO_ADD_WORLD_QUESTS_YOUR_CURRENT"]                 = "Adiciona automaticamente missões mundiais na sua zona atual. Desativado: apenas missões rastreadas ou missões mundiais próximas aparecem (padrão Blizzard)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_FLOATING_QUEST_ITEM"]                           = "Mostrar item de missão flutuante"
L["OPTIONS_FOCUS_QUICK_BUTTON_FOCUSED_QUEST_S_USABLE"]                = "Mostra botão de uso rápido para o item utilizável da missão focada."
L["OPTIONS_FOCUS_LOCK_FLOATING_QUEST_ITEM_POSITION"]                  = "Travar posição do item flutuante"
L["OPTIONS_FOCUS_PREVENT_DRAGGING_FLOATING_QUEST_ITEM_BUTTON"]        = "Impede arrastar o botão do item de missão flutuante."
L["OPTIONS_FOCUS_FLOATING_QUEST_ITEM_SOURCE"]                         = "Fonte do item de missão flutuante"
L["OPTIONS_FOCUS_WHICH_QUEST_S_ITEM_SUPER_TRACKED"]                   = "Qual item de missão mostrar: primeiro o super-rastreado ou primeiro o da zona atual."
L["OPTIONS_FOCUS_SUPER_TRACKED_FIRST"]                                = "Super-rastreado, depois primeiro"
L["OPTIONS_FOCUS_CURRENT_ZONE_FIRST"]                                 = "Zona atual primeiro"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["OPTIONS_FOCUS_MYTHIC_BLOCK"]                                       = "Mostrar bloco Mítica+"
L["OPTIONS_FOCUS_TIMER_COMPLETION_AFFIXES_MYTHIC_DUNGEONS"]           = "Mostra cronômetro, % de conclusão e afixos em masmorras Mítica+."
L["OPTIONS_FOCUS_M_BLOCK_POSITION"]                                   = "Posição do bloco M+"
L["OPTIONS_FOCUS_POSITION_OF_MYTHIC_BLOCK_RELATIVE_QUEST"]            = "Posição do bloco Mítica+ em relação à lista de missões."
L["OPTIONS_FOCUS_AFFIX_ICONS"]                                        = "Mostrar ícones de afixos"
L["OPTIONS_FOCUS_AFFIX_ICONS_NEXT_MODIFIER_NAMES_M"]                  = "Mostra ícones de afixos ao lado dos modificadores no bloco M+."
L["OPTIONS_FOCUS_AFFIX_DESCRIPTIONS_TOOLTIP"]                         = "Mostrar descrições de afixos na dica"
L["OPTIONS_FOCUS_AFFIX_DESCRIPTIONS_HOVERING_M_BLO"]                  = "Mostra descrições de afixos ao passar o mouse sobre o bloco M+."
L["OPTIONS_FOCUS_M_COMPLETED_BOSS_DISPLAY"]                           = "Exibição de chefes M+ concluídos"
L["OPTIONS_FOCUS_DEFEATED_BOSSES_CHECKMARK_ICON_GREEN"]               = "Como mostrar chefes derrotados: ícone de marca ou cor verde."
L["OPTIONS_FOCUS_CHECKMARK"]                                          = "Marca"
L["OPTIONS_FOCUS_GREEN_COLOR"]                                        = "Cor verde"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["OPTIONS_PRESENCE_ACHIEVEMENTS"]                                    = "Mostrar conquistas"
L["OPTIONS_FOCUS_TRACKED_ACHIEVEMENTS_LIST"]                          = "Mostra conquistas rastreadas na lista."
L["OPTIONS_FOCUS_COMPLETED_ACHIEVEMENTS"]                             = "Mostrar conquistas concluídas"
L["OPTIONS_FOCUS_INCLUDE_COMPLETED_ACHIEVEMENTS_TRACKER_O"]           = "Inclui conquistas concluídas no rastreador. Desativado: só conquistas em andamento são mostradas."
L["OPTIONS_FOCUS_ACHIEVEMENT_ICONS"]                                  = "Mostrar ícones de conquistas"
L["OPTIONS_FOCUS_ACHIEVEMENT_S_ICON_NEXT_TITLE_REQUI"]                = "Mostra o ícone de cada conquista ao lado do título. Requer \"Mostrar ícones de tipo de missão\" em Exibição."
L["OPTIONS_FOCUS_MISSING_REQUIREMENTS"]                               = "Mostrar apenas requisitos faltando"
L["OPTIONS_FOCUS_CRITERIA_YOU_HAVEN_T_COMPLETED_TR"]                  = "Mostra apenas critérios que você ainda não concluiu para cada conquista rastreada. Desativado: todos os critérios são mostrados."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_ENDEAVORS"]                                     = "Mostrar Empreendimentos"
L["OPTIONS_FOCUS_TRACKED_ENDEAVORS_PLAYER_HOUSING_LIST"]              = "Mostra Empreendimentos rastreados (Habitação do Jogador) na lista."
L["OPTIONS_FOCUS_COMPLETED_ENDEAVORS"]                                = "Mostrar Empreendimentos concluídos"
L["OPTIONS_FOCUS_INCLUDE_COMPLETED_ENDEAVORS_TRACKER"]                = "Inclui Empreendimentos concluídos no rastreador. Desativado: só Empreendimentos em andamento são mostrados."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["OPTIONS_FOCUS_SHOW_DECOR"]                                         = "Mostrar decoração"
L["OPTIONS_FOCUS_TRACKED_HOUSING_DECOR_LIST"]                         = "Mostra decorações de casa rastreadas na lista."
L["OPTIONS_FOCUS_DECOR_ICONS"]                                        = "Mostrar ícones de decoração"
L["OPTIONS_FOCUS_DECOR_ITEM_S_ICON_NEXT_TITLE"]                       = "Mostra o ícone de cada decoração ao lado do título. Requer \"Mostrar ícones de tipo de missão\" em Exibição."

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
-- L["OPTIONS_FOCUS_OPEN_APPEARANCES_COLLECTIONS"]                    = "Open Collections"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_UNTRACK_APPEARANCE"]                              = "Untrack appearance"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_APPEARANCE_HORIZON_CONTROLS_HINT"]                   = "Horizon: Shift-click map, Ctrl-click Collections, Ctrl+Shift-click dressing room. Right-click clears focus or untracks."

-- =====================================================================
-- OptionsData.lua Features — Adventure Guide
-- =====================================================================
L["OPTIONS_FOCUS_ADVENTURE_GUIDE"]                                    = "Guia de Aventura"
L["OPTIONS_FOCUS_TRAVELER_S_LOG"]                                     = "Mostrar Diário do Viajante"
L["OPTIONS_FOCUS_TRACKED_TRAVELER_S_LOG_OBJECTIVES_SHIFT"]            = "Mostra objetivos rastreados do Diário do Viajante (Shift+clique no Guia de Aventura) na lista."
L["OPTIONS_FOCUS_AUTO_REMOVE_COMPLETED_ACTIVITIES"]                   = "Remover automaticamente atividades concluídas"
L["OPTIONS_FOCUS_AUTOMATICALLY_STOP_TRACKING_TRAVELER_S_LOG"]         = "Para automaticamente de rastrear atividades do Diário do Viajante quando concluídas."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["OPTIONS_FOCUS_SCENARIO_EVENTS"]                                    = "Mostrar eventos de cenário"
L["OPTIONS_FOCUS_ACTIVE_SCENARIO_DELVE_ACTIVITIES_DELVES_APP"]        = "Mostra cenários ativos e atividades de Delve. Delves aparecem em Delves; outros cenários em EVENTOS DE CENÁRIO."
L["OPTIONS_FOCUS_TRACK_DELVE_DUNGEON_SCENARIO_ACTIVITIES"]            = "Rastrear atividades de Delves, Masmorras e cenários."
L["OPTIONS_FOCUS_DELVES_APPEAR_DELVES_SECTION_DUNGEONS_DUNGEON"]      = "Delves aparecem na seção Delves; masmorras em Masmorra; outros cenários em Eventos de Cenário."
-- L["OPTIONS_FOCUS_DELVES_APPEAR_DELVES_SECTION_SCENARIOS_S"]        = "Delves appear in Delves section; other scenarios in Scenario Events."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DELVE_AFFIX_NAMES"]                               = "Delve affix names"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_DELVE_DUNGEON"]                                   = "Delve/Dungeon only"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_SCENARIO_DEBUG_LOGGING"]                          = "Scenario debug logging"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_LOG_SCENARIO_API_DATA_CHAT_H"]                    = "Log scenario API data to chat. Use /h debug focus scendebug to toggle."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_PRINTS_C_SCENARIOINFO_CRITERIA_WIDGET_DATA"]      = "Prints C_ScenarioInfo criteria and widget data when in a scenario. Helps diagnose display issues like Abundance 46/300."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_HIDE_CATEGORIES_DELVE_DUNGEON"]                      = "Ocultar outras categorias em Delves ou Masmorras"
L["OPTIONS_FOCUS_DELVES_PARTY_DUNGEONS_DELVE_DUNG"]                   = "Em Delves ou masmorras de grupo, mostra apenas a seção de Delve/Masmorra."
L["OPTIONS_FOCUS_DELVE_NAME_SECTION_HEADER"]                          = "Usar nome do Delve como cabeçalho de seção"
L["OPTIONS_FOCUS_A_DELVE_DELVE_NAME_TIER_AFFIXES"]                    = "Em um Delve, mostra nome, nível e afixos no cabeçalho da seção em vez de um banner separado. Desative para mostrar o bloco de Delve acima da lista."
L["OPTIONS_FOCUS_AFFIX_NAMES_DELVES"]                                 = "Mostrar nomes de afixos em Delves"
L["OPTIONS_FOCUS_SEASON_AFFIX_NAMES_FIRST_DELVE_ENTRY"]               = "Mostra nomes de afixos da temporada na primeira entrada de Delve. Requer widgets do rastreador de objetivos da Blizzard; pode não aparecer ao usar um rastreador totalmente substituto."
L["OPTIONS_FOCUS_CINEMATIC_SCENARIO_BAR"]                             = "Barra de cenário cinematográfica"
L["OPTIONS_FOCUS_TIMER_PROGRESS_BAR_SCENARIO_ENTRIES"]                = "Mostra cronômetro e barra de progresso para entradas de cenário."
L["OPTIONS_FOCUS_TIMER"]                                              = "Mostrar cronômetro"
L["OPTIONS_FOCUS_COUNTDOWN_TIMER_TIMED_QUESTS_EVENTS_SCEN"]           = "Mostra cronômetro em missões, eventos e cenários cronometrados. Desativado, os cronômetros são ocultados."
L["OPTIONS_FOCUS_TIMER_SCENARIOS"]                                    = "Timers: scenarios & delves"
L["OPTIONS_FOCUS_TIMER_SCENARIOS_DESC"]                               = "Countdown timer for scenario, delve, and dungeon tracker entries."
L["OPTIONS_FOCUS_TIMER_WORLD"]                                        = "Timers: world & callings"
L["OPTIONS_FOCUS_TIMER_WORLD_DESC"]                                   = "Countdown timer for world quests and callings."
L["OPTIONS_FOCUS_TIMER_QUEST_LOG"]                                    = "Timers: quest log (timed)"
L["OPTIONS_FOCUS_TIMER_QUEST_LOG_DESC"]                               = "Countdown timer for dailies, weeklies, and other quest log entries with a time limit."
L["OPTIONS_FOCUS_TIMER_DISPLAY"]                                      = "Exibição do cronômetro"
L["OPTIONS_FOCUS_COLOR_TIMER_REMAINING"]                              = "Cor do cronômetro por tempo restante"
L["OPTIONS_FOCUS_GREEN_PLENTY_OF_LEFT_YELLOW_RUNNING"]                = "Verde quando há tempo, amarelo quando está acabando, vermelho quando crítico."
L["OPTIONS_FOCUS_WHERE_COUNTDOWN_BAR_BELOW_OBJECTIVES"]               = "Onde exibir a contagem regressiva: barra abaixo dos objetivos ou texto ao lado do nome da missão."
L["OPTIONS_FOCUS_BAR_BELOW"]                                          = "Barra abaixo"
L["OPTIONS_FOCUS_INLINE_BESIDE_TITLE"]                                = "Ao lado do título"

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["OPTIONS_FOCUS_FONT_FAMILY"]                                        = "Família de fonte."
L["OPTIONS_FOCUS_TITLE_FONT"]                                         = "Fonte dos títulos"
L["OPTIONS_VISTA_ZONE_FONT"]                                          = "Fonte da zona"
L["OPTIONS_FOCUS_OBJECTIVE_FONT"]                                     = "Fonte dos objetivos"
L["OPTIONS_FOCUS_SECTION_FONT"]                                       = "Fonte das seções"
L["OPTIONS_FOCUS_GLOBAL_FONT"]                                        = "Usar fonte global"
L["OPTIONS_FOCUS_FONT_FAMILY_QUEST_TITLES"]                           = "Família de fonte dos títulos de missão."
L["OPTIONS_FOCUS_FONT_FAMILY_ZONE_LABELS"]                            = "Família de fonte dos rótulos de zona."
L["OPTIONS_FOCUS_FONT_FAMILY_OBJECTIVE_TEXT"]                         = "Família de fonte do texto dos objetivos."
L["OPTIONS_FOCUS_FONT_FAMILY_SECTION_HEADERS"]                        = "Família de fonte dos cabeçalhos de seção."
L["OPTIONS_FOCUS_HEADER_SIZE"]                                        = "Tamanho do cabeçalho"
L["OPTIONS_FOCUS_HEADER_FONT_SIZE"]                                   = "Tamanho da fonte do cabeçalho."
L["OPTIONS_FOCUS_TITLE_SIZE"]                                         = "Tamanho do título"
L["OPTIONS_FOCUS_QUEST_TITLE_FONT_SIZE"]                              = "Tamanho da fonte dos títulos de missão."
L["OPTIONS_FOCUS_OBJECTIVE_SIZE"]                                     = "Tamanho dos objetivos"
L["OPTIONS_FOCUS_OBJECTIVE_TEXT_FONT_SIZE"]                           = "Tamanho da fonte do texto dos objetivos."
L["OPTIONS_FOCUS_ZONE_SIZE"]                                          = "Tamanho das zonas"
L["OPTIONS_FOCUS_ZONE_LABEL_FONT_SIZE"]                               = "Tamanho da fonte dos rótulos de zona."
L["OPTIONS_FOCUS_SECTION_SIZE"]                                       = "Tamanho das seções"
L["OPTIONS_FOCUS_SECTION_HEADER_FONT_SIZE"]                           = "Tamanho da fonte dos cabeçalhos de seção."
L["OPTIONS_FOCUS_PROGRESS_BAR_FONT"]                                  = "Fonte da barra de progresso"
L["OPTIONS_FOCUS_FONT_FAMILY_PROGRESS_BAR_LABEL"]                     = "Família de fonte para o texto da barra de progresso."
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXT_SIZE"]                             = "Tamanho do texto da barra de progresso"
L["OPTIONS_FOCUS_FONT_SIZE_PROGRESS_BAR_LABEL_ADJUSTS"]               = "Tamanho da fonte do texto da barra de progresso. Também ajusta a altura da barra. Afeta objetivos de missões, progresso de cenário e barras de timer."
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL"]                                  = "Preenchimento da barra de progresso"
L["OPTIONS_FOCUS_PROGRESS_BAR_TEXT"]                                  = "Texto da barra de progresso"
L["OPTIONS_FOCUS_OUTLINE"]                                            = "Contorno"
L["OPTIONS_FOCUS_FONT_OUTLINE_STYLE"]                                 = "Estilo de contorno da fonte."

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["OPTIONS_FOCUS_HEADER_TEXT_CASE"]                                   = "Caixa de texto do cabeçalho"
L["OPTIONS_FOCUS_DISPLAY_CASE_HEADER"]                                = "Caixa de exibição para o cabeçalho."
L["OPTIONS_FOCUS_SECTION_HEADER_CASE"]                                = "Caixa dos cabeçalhos de seção"
L["OPTIONS_FOCUS_DISPLAY_CASE_CATEGORY_LABELS"]                       = "Caixa de exibição para rótulos de categoria."
L["OPTIONS_FOCUS_QUEST_TITLE_CASE"]                                   = "Caixa dos títulos de missão"
L["OPTIONS_FOCUS_DISPLAY_CASE_QUEST_TITLES"]                          = "Caixa de exibição para títulos de missão."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["OPTIONS_FOCUS_TEXT_SHADOW"]                                        = "Mostrar sombra do texto"
L["OPTIONS_FOCUS_ENABLE_DROP_SHADOW_TEXT"]                            = "Ativa sombra projetada no texto."
L["OPTIONS_FOCUS_SHADOW_X"]                                           = "Sombra X"
L["OPTIONS_FOCUS_HORIZONTAL_SHADOW_OFFSET"]                           = "Deslocamento horizontal da sombra."
L["OPTIONS_FOCUS_SHADOW_Y"]                                           = "Sombra Y"
L["OPTIONS_FOCUS_VERTICAL_SHADOW_OFFSET"]                             = "Deslocamento vertical da sombra."
L["OPTIONS_FOCUS_SHADOW_ALPHA"]                                       = "Opacidade da sombra"
L["OPTIONS_FOCUS_SHADOW_OPACITY"]                                     = "Opacidade da sombra (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["OPTIONS_FOCUS_MYTHIC_TYPOGRAPHY"]                                  = "Tipografia de Mítica+"
L["OPTIONS_FOCUS_DUNGEON_NAME_SIZE"]                                  = "Tamanho do nome da masmorra"
L["OPTIONS_FOCUS_FONT_SIZE_DUNGEON_NAME_PX"]                          = "Tamanho da fonte do nome da masmorra (8–32 px)."
L["OPTIONS_FOCUS_DUNGEON_NAME_COLOR"]                                 = "Cor do nome da masmorra"
L["OPTIONS_FOCUS_TEXT_COLOR_DUNGEON_NAME"]                            = "Cor do texto do nome da masmorra."
L["OPTIONS_FOCUS_TIMER_SIZE"]                                         = "Tamanho do cronômetro"
L["OPTIONS_FOCUS_FONT_SIZE_TIMER_PX"]                                 = "Tamanho da fonte do cronômetro (8–32 px)."
L["OPTIONS_FOCUS_TIMER_COLOR"]                                        = "Cor do cronômetro"
L["OPTIONS_FOCUS_TEXT_COLOR_TIMER"]                                   = "Cor do texto do cronômetro (no tempo)."
L["OPTIONS_FOCUS_TIMER_OVERTIME_COLOR"]                               = "Cor do cronômetro em atraso"
L["OPTIONS_FOCUS_TEXT_COLOR_TIMER_LIMIT"]                             = "Cor do texto do cronômetro quando o tempo acabou."
L["OPTIONS_FOCUS_PROGRESS_SIZE"]                                      = "Tamanho da progressão"
L["OPTIONS_FOCUS_FONT_SIZE_ENEMY_FORCES_PX"]                          = "Tamanho da fonte das forças inimigas (8–32 px)."
L["OPTIONS_FOCUS_PROGRESS_COLOR"]                                     = "Cor da progressão"
L["OPTIONS_FOCUS_TEXT_COLOR_ENEMY_FORCES"]                            = "Cor do texto das forças inimigas."
L["OPTIONS_FOCUS_BAR_FILL_COLOR"]                                     = "Cor de preenchimento da barra"
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL_COLOR_PROGRESS"]                   = "Cor de preenchimento da barra de progresso (em andamento)."
L["OPTIONS_FOCUS_BAR_COMPLETE_COLOR"]                                 = "Cor da barra concluída"
L["OPTIONS_FOCUS_PROGRESS_BAR_FILL_COLOR_ENEMY_FORCES"]               = "Cor de preenchimento da barra quando as forças inimigas estão em 100%."
L["OPTIONS_FOCUS_AFFIX_SIZE"]                                         = "Tamanho dos afixos"
L["OPTIONS_FOCUS_FONT_SIZE_AFFIXES_PX"]                               = "Tamanho da fonte dos afixos (8–32 px)."
L["OPTIONS_FOCUS_AFFIX_COLOR"]                                        = "Cor dos afixos"
L["OPTIONS_FOCUS_TEXT_COLOR_AFFIXES"]                                 = "Cor do texto dos afixos."
L["OPTIONS_FOCUS_BOSS_SIZE"]                                          = "Tamanho dos nomes dos chefes"
L["OPTIONS_FOCUS_FONT_SIZE_BOSS_NAMES_PX"]                            = "Tamanho da fonte dos nomes dos chefes (8–32 px)."
L["OPTIONS_FOCUS_BOSS_COLOR"]                                         = "Cor dos nomes dos chefes"
L["OPTIONS_FOCUS_TEXT_COLOR_BOSS_NAMES"]                              = "Cor do texto dos nomes dos chefes."
L["OPTIONS_FOCUS_RESET_MYTHIC_TYPOGRAPHY"]                            = "Redefinir tipografia de M+"

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
L["OPTIONS_FOCUS_BACKDROP_OPACITY"]                                   = "Opacidade do fundo"
L["OPTIONS_FOCUS_PANEL_BACKGROUND_OPACITY"]                           = "Opacidade do fundo do painel (0–1)."
L["OPTIONS_FOCUS_BORDER"]                                             = "Mostrar borda"
L["OPTIONS_FOCUS_BORDER_AROUND_TRACKER"]                              = "Mostra uma borda ao redor do rastreador."
L["OPTIONS_FOCUS_SCROLL_INDICATOR"]                                   = "Mostrar indicador de rolagem"
L["OPTIONS_FOCUS_A_VISUAL_HINT_LIST_CONTENT_TH"]                      = "Mostra um indicador visual quando a lista tem mais conteúdo do que o visível."
L["OPTIONS_FOCUS_SCROLL_INDICATOR_STYLE"]                             = "Estilo do indicador de rolagem"
L["OPTIONS_FOCUS_CHOOSE_BETWEEN_A_FADE_GRADIENT_A"]                   = "Escolha entre um gradiente de desvanecimento ou uma pequena seta para indicar conteúdo rolável."
L["OPTIONS_FOCUS_ARROW"]                                              = "Seta"
L["OPTIONS_FOCUS_HIGHLIGHT_ALPHA"]                                    = "Opacidade do destaque"
L["OPTIONS_FOCUS_OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]                 = "Opacidade do destaque da missão focada (0–1)."
L["OPTIONS_FOCUS_BAR_WIDTH"]                                          = "Largura da barra"
L["OPTIONS_FOCUS_WIDTH_OF_BAR_STYLE_HIGHLIGHTS_PX"]                   = "Largura dos destaques em forma de barra (2–6 px)."

-- =====================================================================
-- OptionsData.lua Organization
-- =====================================================================
-- L["OPTIONS_FOCUS_ACTIVITY"]                                        = "Activity"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CONTENT"]                                         = "Content"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_SORTING"]                                         = "Sorting"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_ELEMENTS"]                                        = "Elements"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_CATEGORY_ORDER"]                                     = "Ordem das categorias de Foco"
-- L["OPTIONS_FOCUS_CATEGORY_COLOR_BAR"]                              = "Category color for bar"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CHECKMARK_COMPLETED"]                             = "Checkmark for completed"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CURRENT_QUEST_CATEGORY"]                          = "Current Quest category"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CURRENT_QUEST_WINDOW"]                            = "Current Quest window"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_QUESTS_RECENT_PROGRESS_TOP"]                      = "Show quests with recent progress at the top."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_SECONDS_OF_RECENT_PROGRESS_CURRENT_QUEST"]        = "Seconds of recent progress to show in Current Quest (30–120)."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_QUESTS_YOU_MADE_PROGRESS_LAST_MINUTE"]            = "Quests you made progress on in the last minute appear in a dedicated section."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_CATEGORY_ORDER"]                                     = "Ordem das categorias de Foco"
L["OPTIONS_FOCUS_DRAG_REORDER_CATEGORIES_DELVES_SCENARIO_EVENT"]      = "Arraste para reordenar categorias. Delves e EVENTOS DE CENÁRIO permanecem primeiro."
-- L["OPTIONS_FOCUS_DRAG_REORDER_DELVES_SCENARIOS_STAY_FIRST"]        = "Drag to reorder. Delves and Scenarios stay first."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_SORT_MODE"]                                          = "Modo de ordenação do Foco"
L["OPTIONS_FOCUS_ORDER_OF_ENTRIES_WITHIN_CATEGORY"]                   = "Ordem das entradas em cada categoria."
L["OPTIONS_FOCUS_AUTO_TRACK_ACCEPTED_QUESTS"]                         = "Rastrear automaticamente missões aceitas"
L["OPTIONS_FOCUS_YOU_ACCEPT_A_QUEST_QUEST_LOG"]                       = "Ao aceitar uma missão (apenas diário, não missões mundiais), adiciona-a automaticamente ao rastreador."
L["OPTIONS_FOCUS_REQUIRE_CTRL_FOCUS_REMOVE"]                          = "Exigir Ctrl para focar e remover"
L["OPTIONS_FOCUS_REQUIRE_CTRL_FOCUS_ADD_LEFT_UNFOCUS"]                = "Exige Ctrl para focar/adicionar (botão esquerdo) e desfocar/parar de rastrear (botão direito) para evitar cliques acidentais."
-- L["OPTIONS_FOCUS_CTRL_FOCUS_UNTRACK"]                              = "Ctrl for focus / untrack"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_CTRL_CLICK_COMPLETE"]                             = "Ctrl to click-complete"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_CLASSIC_CLICK_BEHAVIOUR"]                            = "Usar comportamento de clique clássico"
-- L["OPTIONS_FOCUS_CLASSIC_CLICKS"]                                  = "Classic clicks"  -- NEEDS TRANSLATION
-- === Focus Click Profiles ===
-- L["OPTIONS_FOCUS_CLICK_PROFILE"]                                   = "Click profile"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_CLICK_PROFILE_DESC"]                                 = "Choose how mouse clicks on tracker entries behave."
-- L["OPTIONS_FOCUS_PROFILE_HORIZON_PLUS"]                            = "Horizon+"  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_PROFILE_BLIZZARD_DEFAULT"]                           = "Blizzard Default"
-- L["OPTIONS_FOCUS_PROFILE_CUSTOM"]                                  = "Custom"  -- NEEDS TRANSLATION
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
L["OPTIONS_FOCUS_SHARE_PARTY"]                                        = "Compartilhar com grupo"
L["OPTIONS_FOCUS_ABANDON_QUEST"]                                      = "Abandonar missão"
L["OPTIONS_FOCUS_STOP_TRACKING"]                                      = "Parar de rastrear"
L["OPTIONS_FOCUS_QUEST_CANNOT_SHARED"]                                = "Esta missão não pode ser compartilhada."
L["OPTIONS_FOCUS_YOU_MUST_A_PARTY_SHARE_QUEST"]                       = "Você precisa estar em um grupo para compartilhar esta missão."
L["OPTIONS_FOCUS_LEFT_CLICK_OPENS_QUEST_MAP_RIGHT"]                   = "Quando ativado, clique esquerdo abre o mapa da missão e clique direito exibe o menu compartilhar/abandonar (estilo Blizzard). Quando desativado, clique esquerdo foca e clique direito remove rastreamento; Ctrl+clique direito compartilha com o grupo."
L["OPTIONS_FOCUS_ANIMATIONS"]                                         = "Focus animations"
L["OPTIONS_FOCUS_ENABLE_SLIDE_FADE_QUESTS"]                           = "Ativa deslizar e esmaecer para missões."
L["OPTIONS_FOCUS_OBJECTIVE_PROGRESS_FLASH"]                           = "Flash de progresso de objetivo"
L["OPTIONS_FOCUS_FLASH_AN_OBJECTIVE_COMPLETES"]                       = "Mostra um flash quando um objetivo é concluído."
L["OPTIONS_FOCUS_FLASH_INTENSITY"]                                    = "Intensidade do flash"
L["OPTIONS_FOCUS_NOTICEABLE_OBJECTIVE_COMPLETE_FLASH"]                = "Quão perceptível é o flash de conclusão de objetivo."
L["OPTIONS_FOCUS_FLASH_COLOR"]                                        = "Cor do flash"
L["OPTIONS_FOCUS_COLOR_OF_OBJECTIVE_COMPLETE_FLASH"]                  = "Cor do flash de conclusão de objetivo."
L["OPTIONS_FOCUS_SUBTLE"]                                             = "Sutil"
L["OPTIONS_FOCUS_MEDIUM"]                                             = "Médio"
L["OPTIONS_FOCUS_STRONG"]                                             = "Forte"
L["OPTIONS_FOCUS_REQUIRE_CTRL_CLICK_COMPLETE"]                        = "Exigir Ctrl para clicar e concluir"
L["OPTIONS_FOCUS_REQUIRES_CTRL_LEFT_CLICK_COMPLETE_AUTO"]             = "Ativado: exige Ctrl+clique esquerdo para concluir missões de auto-conclusão. Desativado: clique esquerdo simples conclui (padrão Blizzard). Afeta apenas missões que podem ser concluídas por clique (sem entregar a um NPC)."
L["OPTIONS_FOCUS_SUPPRESS_UNTRACKED_UNTIL_RELOAD"]                    = "Ocultar não rastreadas até recarregar"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS_Z"]                 = "Ativado: clicar com o botão direito para parar de rastrear missões mundiais e semanais/diárias na zona as oculta até você recarregar ou iniciar uma nova sessão. Desativado: elas reaparecem quando você volta à zona."
L["OPTIONS_FOCUS_PERMANENTLY_SUPPRESS_UNTRACKED_QUESTS"]              = "Ocultar permanentemente missões não rastreadas"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACKED_WORLD_QUESTS_ZO"]              = "Ativado: missões mundiais e semanais/diárias na zona marcadas como não rastreadas ficam ocultas permanentemente (persiste entre recargas). Tem prioridade sobre \"Ocultar até recarregar\". Aceitar uma missão oculta a remove da lista negra."
L["OPTIONS_FOCUS_KEEP_CAMPAIGN_QUESTS_CATEGORY"]                      = "Manter missões de campanha na categoria"
L["OPTIONS_FOCUS_CAMPAIGN_QUESTS_READY_TURN_RE"]                      = "Ativado: missões de campanha prontas para entregar permanecem na categoria Campanha em vez de ir para Concluídas."
L["OPTIONS_FOCUS_KEEP_IMPORTANT_QUESTS_CATEGORY"]                     = "Manter missões importantes na categoria"
L["OPTIONS_FOCUS_IMPORTANT_QUESTS_READY_TURN_R"]                      = "Ativado: missões importantes prontas para entregar permanecem na categoria Importante em vez de ir para Concluídas."
L["OPTIONS_FOCUS_TOMTOM_QUEST_WAYPOINT"]                              = "Ponto de referência TomTom"
L["OPTIONS_FOCUS_A_TOMTOM_WAYPOINT_FOCUSING_A_QUEST"]                 = "Definir um ponto de referência TomTom ao focar uma missão."
L["OPTIONS_FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_NEXT_QUEST"]            = "Requer TomTom. Aponta a seta para o próximo objetivo da missão."
L["OPTIONS_FOCUS_TOMTOM_RARE_WAYPOINT"]                               = "Ponto de referência TomTom (raro)"
L["OPTIONS_FOCUS_A_TOMTOM_WAYPOINT_CLICKING_A_RARE"]                  = "Definir um ponto de referência TomTom ao clicar em um chefe raro."
L["OPTIONS_FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_RARE_S"]                = "Requer TomTom. Aponta a seta para a localização do chefe raro."
L["OPTIONS_FOCUS_FIND_A_GROUP"]                                       = "Encontrar um Grupo"
L["OPTIONS_FOCUS_CLICK_SEARCH_A_GROUP_QUEST"]                         = "Clique para procurar um grupo para esta missao."

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
L["OPTIONS_FOCUS_BLACKLIST"]                                          = "Lista negra"
-- L["OPTIONS_FOCUS_BLACKLIST_UNTRACKED"]                             = "Blacklist untracked"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_ENABLE_BLACKLIST_UNTRACKED_BEHAVIOUR_ADD_QUEST"]  = "Enable 'Blacklist untracked' in Behaviour to add quests here."  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_HIDDEN_QUESTS"]                                   = "Hidden Quests"  -- NEEDS TRANSLATION
-- L["OPTIONS_FOCUS_QUESTS_HIDDEN_RIGHT_CLICK_UNTRACK"]               = "Quests hidden via right-click untrack."  -- NEEDS TRANSLATION
L["OPTIONS_FOCUS_BLACKLISTED_QUESTS"]                                 = "Missões na lista negra"
L["OPTIONS_FOCUS_PERMANENTLY_SUPPRESSED_QUESTS"]                      = "Missões ocultas permanentemente"
L["OPTIONS_FOCUS_RIGHT_CLICK_UNTRACK_QUESTS_PERMANENTLY_SUPPRESS"]    = "Clique com o botão direito para parar de rastrear missões com \"Ocultar permanentemente missões não rastreadas\" ativado para adicioná-las aqui."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["OPTIONS_PRESENCE_QUEST_TYPE_ICONS"]                                = "Mostrar ícones de tipo de missão"
L["OPTIONS_PRESENCE_QUEST_TYPE_ICON_FOCUS_TRACKER_QUEST"]             = "Mostra ícone de tipo de missão no rastreador Foco (aceitar/concluir missão, missão mundial, atualização de missão)."
L["OPTIONS_PRESENCE_QUEST_TYPE_ICONS_TOASTS"]                         = "Mostrar ícones de tipo nas notificações"
L["OPTIONS_PRESENCE_QUEST_TYPE_ICON_PRESENCE_TOASTS_QUEST"]           = "Mostra ícone de tipo nas notificações Presence (aceitar/concluir missão, missão mundial, atualização de missão)."
L["OPTIONS_PRESENCE_TOAST_ICON_SIZE"]                                 = "Tamanho dos ícones das notificações"
L["OPTIONS_PRESENCE_QUEST_ICON_SIZE_PRESENCE_TOASTS_PX"]              = "Tamanho do ícone de missão nas notificações Presence (16–36 px). Padrão 24."
L["OPTIONS_PRESENCE_HIDE_QUEST_UPDATE_TITLE"]                         = "Ocultar título no avanço de missão"
L["OPTIONS_PRESENCE_OBJECTIVE_LINE_QUEST_PROGRESS_TOAST"]             = "Mostra apenas a linha do objetivo (ex.: 7/10 Peles de javali), sem o nome da missão ou cabeçalho."
L["OPTIONS_PRESENCE_SHOW_DISCOVERY_LINE"]                             = "Mostrar linha de descoberta"
-- L["OPTIONS_PRESENCE_DISCOVERY_LINE"]                               = "Discovery line"  -- NEEDS TRANSLATION
L["OPTIONS_PRESENCE_DISCOVERED_UNDER_ZONE_SUBZONE_ENTERING_A"]        = "Mostra \"Descoberto\" sob zona/subzona ao entrar em uma nova área."
L["OPTIONS_PRESENCE_FRAME_VERTICAL_POSITION"]                         = "Posição vertical do quadro"
L["OPTIONS_PRESENCE_VERTICAL_OFFSET_OF_PRESENCE_FRAME_CENTER"]        = "Deslocamento vertical do quadro Presence a partir do centro (-300 a 0)."
L["OPTIONS_PRESENCE_FRAME_SCALE"]                                     = "Escala do quadro"
L["OPTIONS_PRESENCE_SCALE_OF_PRESENCE_FRAME"]                         = "Escala do quadro Presence (0,5–2)."
L["OPTIONS_PRESENCE_BOSS_EMOTE_COLOR"]                                = "Cor dos emotes de chefe"
L["OPTIONS_PRESENCE_COLOR_OF_RAID_DUNGEON_BOSS_EMOTE"]                = "Cor do texto de emotes de chefes de raide e masmorra."
L["OPTIONS_PRESENCE_DISCOVERY_LINE_COLOR"]                            = "Cor da linha de descoberta"
L["OPTIONS_PRESENCE_COLOR_OF_DISCOVERED_LINE_UNDER_ZONE"]             = "Cor da linha \"Descoberto\" sob o texto de zona."
L["OPTIONS_PRESENCE_NOTIFICATION_TYPES"]                              = "Tipos de notificação"
-- L["OPTIONS_PRESENCE_NOTIFICATIONS"]                                = "Notifications"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_NOTIFICATION_ACHIEVEMENT_CRITERIA_UPDATE_T"]   = "Show notification when achievement criteria update (tracked achievements always; others when Blizzard provides the achievement ID)."  -- NEEDS TRANSLATION
L["OPTIONS_PRESENCE_ZONE_ENTRY"]                                      = "Mostrar entrada em zona"
L["OPTIONS_PRESENCE_ZONE_CHANGE_ENTERING_A_AREA"]                     = "Mostra notificação ao entrar em uma nova área."
L["OPTIONS_PRESENCE_SUBZONE_CHANGES"]                                 = "Mostrar mudanças de subzona"
L["OPTIONS_PRESENCE_SUBZONE_CHANGE_MOVING_WITHIN_SAME_ZONE"]          = "Mostra notificação ao se mover entre subzonas na mesma zona."
L["OPTIONS_PRESENCE_HIDE_ZONE_NAME_SUBZONE_CHANGES"]                  = "Ocultar nome da zona para mudanças de subzona"
L["OPTIONS_PRESENCE_MOVING_BETWEEN_SUBZONES_WITHIN_SAME_ZONE"]        = "Ao se mover entre subzonas na mesma zona, mostra apenas o nome da subzona. O nome da zona ainda aparece ao entrar em uma nova zona."
-- L["OPTIONS_PRESENCE_SUPPRESS_DELVE"]                               = "Suppress in Delve"  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_SUPPRESS_SCENARIO_PROGRESS_NOTIFICATIONS_DELVES"]= "Suppress scenario progress notifications in Delves."  -- NEEDS TRANSLATION
-- L["OPTIONS_PRESENCE_HIDES_OBJECTIVE_UPDATE_POPUPS_WHILE_A"]        = "When on, hides objective update popups while in a Delve. Zone entry and completion toasts still show."  -- NEEDS TRANSLATION
L["OPTIONS_PRESENCE_SUPPRESS_ZONE_CHANGES_MYTHIC"]                    = "Suprimir mudanças de zona em Mítico+"
L["OPTIONS_PRESENCE_MYTHIC_BOSS_EMOTES_ACHIEVEMENTS_LEV"]             = "Em Mítico+, mostra apenas emotes de chefe, conquistas e subida de nível. Oculta notificações de zona, missão e cenário."
L["OPTIONS_PRESENCE_LEVEL"]                                           = "Mostrar subir de nível"
L["OPTIONS_PRESENCE_LEVEL_NOTIFICATION"]                              = "Mostra notificação de subida de nível."
L["OPTIONS_PRESENCE_BOSS_EMOTES"]                                     = "Mostrar emotes de chefe"
L["OPTIONS_PRESENCE_RAID_DUNGEON_BOSS_EMOTE_NOTIFICATIONS"]           = "Mostra notificações de emotes de chefes em raides e masmorras."
L["OPTIONS_PRESENCE_ACHIEVEMENTS"]                                    = "Mostrar conquistas"
L["OPTIONS_PRESENCE_ACHIEVEMENT_EARNED_NOTIFICATIONS"]                = "Mostra notificações de conquistas obtidas."
L["OPTIONS_PRESENCE_ACHIEVEMENT_PROGRESS"]                            = "Progresso de conquistas"
L["OPTIONS_PRESENCE_ACHIEVEMENT_EARNED"]                              = "Conquista obtida"
L["OPTIONS_PRESENCE_QUEST_ACCEPTED"]                                  = "Missão aceita"
L["OPTIONS_PRESENCE_WORLD_QUEST_ACCEPTED"]                            = "Missão mundial aceita"
L["OPTIONS_PRESENCE_SCENARIO_COMPLETE"]                               = "Cenário concluído"
L["OPTIONS_PRESENCE_RARE_DEFEATED"]                                   = "Raro derrotado"
L["OPTIONS_PRESENCE_NOTIFICATION_TRACKED_ACHIEVEMENT_CRITERIA"]       = "Mostra notificação quando os critérios de uma conquista rastreada são atualizados."
L["OPTIONS_PRESENCE_QUEST_ACCEPT"]                                    = "Mostrar aceitação de missão"
L["OPTIONS_PRESENCE_NOTIFICATION_ACCEPTING_A_QUEST"]                  = "Mostra notificação ao aceitar uma missão."
L["OPTIONS_PRESENCE_WORLD_QUEST_ACCEPT"]                              = "Mostrar aceitação de missão mundial"
L["OPTIONS_PRESENCE_NOTIFICATION_ACCEPTING_A_WORLD_QUEST"]            = "Mostra notificação ao aceitar uma missão mundial."
L["OPTIONS_PRESENCE_QUEST_COMPLETE"]                                  = "Mostrar conclusão de missão"
L["OPTIONS_PRESENCE_NOTIFICATION_COMPLETING_A_QUEST"]                 = "Mostra notificação ao concluir uma missão."
L["OPTIONS_PRESENCE_WORLD_QUEST_COMPLETE"]                            = "Mostrar conclusão de missão mundial"
L["OPTIONS_PRESENCE_NOTIFICATION_COMPLETING_A_WORLD_QUEST"]           = "Mostra notificação ao concluir uma missão mundial."
L["OPTIONS_PRESENCE_QUEST_PROGRESS"]                                  = "Mostrar progresso da missão"
L["OPTIONS_PRESENCE_NOTIFICATION_QUEST_OBJECTIVES_UPDATE"]            = "Mostra notificação quando objetivos da missão são atualizados."
L["OPTIONS_PRESENCE_OBJECTIVE"]                                       = "Apenas objetivo"
L["OPTIONS_PRESENCE_QUEST_PROGRESS_HIDE_TITLE"]                       = "Mostra apenas a linha do objetivo nas notificações de progresso, ocultando o título 'Atualização de Missão'."
L["OPTIONS_PRESENCE_SCENARIO_START"]                                  = "Mostrar início de cenário"
L["OPTIONS_PRESENCE_NOTIFICATION_ENTERING_A_SCENARIO_DELVE"]          = "Mostra notificação ao entrar em um cenário ou Profundezas."
L["OPTIONS_PRESENCE_SCENARIO_PROGRESS"]                               = "Mostrar progresso do cenário"
L["OPTIONS_PRESENCE_NOTIFICATION_SCENARIO_DELVE_OBJECTIVES"]          = "Mostra notificação quando objetivos de cenário ou Profundezas são atualizados."
L["OPTIONS_PRESENCE_ANIMATION"]                                       = "Animação"
L["OPTIONS_PRESENCE_ENABLE_ANIMATIONS"]                               = "Ativar animações"
L["OPTIONS_PRESENCE_ENABLE_ENTRANCE_EXIT_ANIMATIONS_PRESENCE"]        = "Ativa animações de entrada e saída para notificações Presence."
L["OPTIONS_PRESENCE_ENTRANCE_DURATION"]                               = "Duração da entrada"
L["OPTIONS_PRESENCE_DURATION_OF_ENTRANCE_ANIMATION_SECONDS"]          = "Duração da animação de entrada em segundos (0,2–1,5)."
L["OPTIONS_PRESENCE_EXIT_DURATION"]                                   = "Duração da saída"
L["OPTIONS_PRESENCE_DURATION_OF_EXIT_ANIMATION_SECONDS"]              = "Duração da animação de saída em segundos (0,2–1,5)."
L["OPTIONS_PRESENCE_HOLD_DURATION_SCALE"]                             = "Fator de duração em tela"
L["OPTIONS_PRESENCE_MULTIPLIER_LONG_NOTIFICATION_STAYS_S"]            = "Multiplicador de quanto tempo cada notificação permanece na tela (0,5–2)."
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
L["DASH_TYPOGRAPHY"]                                                  = "Tipografia"
L["OPTIONS_PRESENCE_MAIN_TITLE_FONT"]                                 = "Fonte do título principal"
L["OPTIONS_PRESENCE_FONT_FAMILY_MAIN_TITLE"]                          = "Família de fontes do título principal."
L["OPTIONS_PRESENCE_SUBTITLE_FONT"]                                   = "Fonte do subtítulo"
L["OPTIONS_PRESENCE_FONT_FAMILY_SUBTITLE"]                            = "Família de fontes do subtítulo."
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
L["OPTIONS_FOCUS_NONE"]                                               = "Nenhum"
L["OPTIONS_FOCUS_THICK_OUTLINE"]                                      = "Contorno espesso"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["OPTIONS_FOCUS_BAR_LEFT_EDGE"]                                      = "Barra (borda esquerda)"
L["OPTIONS_FOCUS_BAR_RIGHT_EDGE"]                                     = "Barra (borda direita)"
L["OPTIONS_FOCUS_BAR_TOP_EDGE"]                                       = "Barra (borda superior)"
L["OPTIONS_FOCUS_BAR_BOTTOM_EDGE"]                                    = "Barra (borda inferior)"
L["OPTIONS_FOCUS_OUTLINE_ONLY_STYLE"]                                 = "Apenas contorno"
L["OPTIONS_FOCUS_SOFT_GLOW"]                                          = "Brilho suave"
L["OPTIONS_FOCUS_DUAL_EDGE_BARS"]                                     = "Barras duplas nas bordas"
L["OPTIONS_FOCUS_PILL_LEFT_ACCENT"]                                   = "Realce em pílula à esquerda"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["OPTIONS_FOCUS_TOP"]                                                = "Topo"
L["OPTIONS_FOCUS_BOTTOM"]                                             = "Fundo"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["OPTIONS_VISTA_LOCATION_POSITION"]                                  = "Posição do nome da zona"
L["OPTIONS_VISTA_PLACE_ZONE_NAME_ABOVE_BELOW_MINIMAP"]                = "Coloca o nome da zona acima ou abaixo do minimapa."
L["OPTIONS_VISTA_COORDINATES_POSITION"]                               = "Posição das coordenadas"
L["OPTIONS_VISTA_PLACE_COORDINATES_ABOVE_BELOW_MINIMAP"]              = "Coloca as coordenadas acima ou abaixo do minimapa."
L["OPTIONS_VISTA_CLOCK_POSITION"]                                     = "Posição do relógio"
L["OPTIONS_VISTA_PLACE_CLOCK_ABOVE_BELOW_MINIMAP"]                    = "Coloca o relógio acima ou abaixo do minimapa."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["OPTIONS_FOCUS_LOWER_CASE"]                                         = "Minúsculas"
L["OPTIONS_FOCUS_UPPER_CASE"]                                         = "Maiúsculas"
L["OPTIONS_FOCUS_PROPER"]                                             = "Primeira letra maiúscula"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["OPTIONS_FOCUS_TRACKED_LOG"]                                        = "Rastreadas / no diário"
L["OPTIONS_FOCUS_LOG_MAX_SLOTS"]                                      = "No diário / vagas máx."

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["OPTIONS_FOCUS_ALPHABETICAL"]                                       = "Alfabética"
L["OPTIONS_FOCUS_QUEST_TYPE"]                                         = "Tipo de missão"
L["OPTIONS_FOCUS_QUEST_LEVEL"]                                        = "Nível da missão"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["OPTIONS_FOCUS_CUSTOM"]                                             = "Personalizado"
L["OPTIONS_FOCUS_ORDER"]                                              = "Ordem"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["UI_DUNGEON"]                                                       = "MASMORRA"
L["UI_RAID"]                                                          = "RAIDE"
-- L["UI_DELVES"]                                                     = "Delves"  -- NEEDS TRANSLATION
L["UI_SCENARIO_EVENTS"]                                               = "EVENTOS DE CENÁRIO"
-- L["UI_STAGE"]                                                      = "Stage"  -- NEEDS TRANSLATION
-- L["UI_STAGE_X_X"]                                                  = "Stage %d: %s"  -- NEEDS TRANSLATION
L["UI_AVAILABLE_IN_ZONE"]                                             = "DISPONÍVEL NA ZONA"
L["UI_EVENTS_IN_ZONE"]                                                = "Eventos na zona"
L["UI_CURRENT_EVENT"]                                                 = "Evento atual"
L["UI_CURRENT_QUEST"]                                                 = "MISSÃO ATUAL"
L["UI_CURRENT_ZONE"]                                                  = "ZONA ATUAL"
L["UI_CAMPAIGN"]                                                      = "CAMPANHA"
L["UI_IMPORTANT"]                                                     = "IMPORTANTE"
L["UI_LEGENDARY"]                                                     = "LENDÁRIA"
L["UI_WORLD_QUESTS"]                                                  = "MISSÕES MUNDIAIS"
L["UI_WEEKLY_QUESTS"]                                                 = "MISSÕES SEMANAIS"
L["UI_PREY"]                                                          = "Presa"
L["UI_ABUNDANCE"]                                                     = "Abundância"
L["UI_ABUNDANCE_BAG"]                                                 = "Bolsa de abundância"
L["UI_ABUNDANCE_HELD"]                                                = "abundância retida"
L["UI_DAILY_QUESTS"]                                                  = "MISSÕES DIÁRIAS"
L["UI_RARE_BOSSES"]                                                   = "CHEFES RAROS"
L["UI_ACHIEVEMENTS"]                                                  = "CONQUISTAS"
L["UI_ENDEAVORS"]                                                     = "EMPREENDIMENTOS"
L["UI_DECOR"]                                                         = "DECORAÇÃO"
-- L["UI_RECIPES"]                                                    = "Recipes"  -- NEEDS TRANSLATION
-- L["UI_ADVENTURE_GUIDE"]                                            = "Adventure Guide"  -- NEEDS TRANSLATION
-- L["UI_APPEARANCES"]                                                = "Appearances"  -- NEEDS TRANSLATION
L["UI_QUESTS"]                                                        = "MISSÕES"
L["UI_READY_TO_TURN_IN"]                                              = "PRONTO PARA ENTREGAR"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["PRESENCE_OBJECTIVES"]                                              = "OBJETIVOS"
L["PRESENCE_OPTIONS"]                                                 = "Opções"
L["PRESENCE_OPEN_HORIZON_SUITE"]                                      = "Abrir Horizon Suite"
L["PRESENCE_OPEN_FULL_HORIZON_SUITE_OPTIONS"]                         = "Abre o painel de opções completo para configurar Focus, Presence, Vista e outros módulos."
L["PRESENCE_SHOW_MINIMAP_ICON"]                                       = "Mostrar ícone no minimapa"
L["PRESENCE_A_CLICKABLE_ICON_MINIMAP_OPENS"]                          = "Mostra um ícone clicável no minimapa que abre o painel de opções."
-- L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER"]              = "Fade until minimap hover"  -- NEEDS TRANSLATION
-- L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER_DESC"]         = "When on, the icon stays faded until you move the cursor over the minimap. When off, it stays fully visible."  -- NEEDS TRANSLATION
-- L["PRESENCE_LOCK_MINIMAP_BUTTON_POSITION"]                         = "Lock minimap button position"  -- NEEDS TRANSLATION
-- L["PRESENCE_PREVENT_DRAGGING_HORIZON_MINIMAP_BUTTON"]              = "Prevent dragging the Horizon minimap button."  -- NEEDS TRANSLATION
-- L["PRESENCE_RESET_MINIMAP_BUTTON_POSITION"]                        = "Reset minimap button position"  -- NEEDS TRANSLATION
-- L["PRESENCE_RESET_MINIMAP_BUTTON_DEFAULT_POSITION"]                = "Reset the minimap button to the default position (bottom-left)."  -- NEEDS TRANSLATION
-- L["PRESENCE_DRAG_TO_MOVE_WHEN_UNLOCKED"]                           = "Drag to move (when unlocked)."  -- NEEDS TRANSLATION
-- L["PRESENCE_LOCKED"]                                               = "Locked"  -- NEEDS TRANSLATION
L["PRESENCE_DISCOVERED"]                                              = "Descoberto"
L["PRESENCE_REFRESH"]                                                 = "Atualizar"
L["PRESENCE_BEST_EFFORT_UNACCEPTED_QUESTS_EXPO"]                      = "Melhor esforço apenas. Algumas missões não aceitas não são exibidas até você interagir com NPCs ou atender às condições de faseamento."
L["PRESENCE_UNACCEPTED_QUESTS_X_MAP_X"]                               = "Missões não aceitas - %s (mapa %s) - %d correspondência(s)"
L["PRESENCE_LEVEL_UP"]                                                = "SUBIU DE NÍVEL"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_80"]                               = "Você alcançou o nível 80"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_X"]                                = "Você alcançou o nível %s"
L["PRESENCE_ACHIEVEMENT_EARNED"]                                      = "CONQUISTA OBTIDA"
L["PRESENCE_EXPLORING_THE_MIDNIGHT_ISLES"]                            = "Explorando as Ilhas da Meia-noite"
L["PRESENCE_EXPLORING_KHAZ_ALGAR"]                                    = "Explorando Khaz Algar"
L["PRESENCE_QUEST_COMPLETE"]                                          = "MISSÃO CONCLUÍDA"
L["PRESENCE_OBJECTIVE_SECURED"]                                       = "Objetivo Garantido"
L["PRESENCE_AIDING_THE_ACCORD"]                                       = "Ajudando o Pacto"
L["PRESENCE_WORLD_QUEST"]                                             = "MISSÃO MUNDIAL"
L["PRESENCE_WORLD_QUEST_COMPLETE"]                                    = "MISSÃO MUNDIAL CONCLUÍDA"
L["PRESENCE_AZERITE_MINING"]                                          = "Mineração de Azerita"
L["PRESENCE_WORLD_QUEST_ACCEPTED"]                                    = "MISSÃO MUNDIAL ACEITA"
L["PRESENCE_QUEST_ACCEPTED"]                                          = "MISSÃO ACEITA"
L["PRESENCE_THE_FATE_OF_THE_HORDE"]                                   = "O Destino da Horda"
L["PRESENCE_NEW_QUEST"]                                               = "Nova Missão"
L["PRESENCE_QUEST_UPDATE"]                                            = "ATUALIZAÇÃO DE MISSÃO"
L["PRESENCE_BOAR_PELTS_7_10"]                                         = "Pelagens de Javali: 7/10"
L["PRESENCE_DRAGON_GLYPHS_3_5"]                                       = "Glifos de Dragão: 3/5"
L["PRESENCE_PRESENCE_TEST_COMMANDS"]                                  = "Comandos de teste do Presence:"
L["PRESENCE_H_PRESENCE_DEBUGTYPES_DUMP_NOTIFICATION"]                 = "  /h presence debugtypes - Exibir toggles de notificação e estado de supressão da Blizzard"
L["PRESENCE_PRESENCE_PLAYING_DEMO_REEL_NOTIFICATION"]                 = "Presence: reproduzindo demo (todos os tipos de notificação)..."
L["PRESENCE_H_PRESENCE_HELP_TEST_CURRENT"]                            = "  /h presence         - Mostrar ajuda + testar zona atual"
L["PRESENCE_H_PRESENCE_ZONE_TEST_ZONE"]                               = "  /h presence zone     - Testar Mudança de Zona"
L["PRESENCE_H_PRESENCE_SUBZONE_TEST_SUBZONE"]                         = "  /h presence subzone  - Testar Mudança de Subzona"
L["PRESENCE_H_PRESENCE_DISCOVER_TEST_ZONE"]                           = "  /h presence discover - Testar Descoberta de Zona"
L["PRESENCE_H_PRESENCE_LEVEL_TEST_LEVEL"]                             = "  /h presence level    - Testar Subir de Nível"
L["PRESENCE_H_PRESENCE_BOSS_TEST_BOSS"]                               = "  /h presence boss     - Testar Emote de Chefe"
L["PRESENCE_H_PRESENCE_ACH_TEST_ACHIEVEMENT"]                         = "  /h presence ach      - Testar Conquista"
L["PRESENCE_H_PRESENCE_ACCEPT_TEST_QUEST"]                            = "  /h presence accept   - Testar Missão Aceita"
L["PRESENCE_H_PRESENCE_WQACCEPT_TEST_WORLD"]                          = "  /h presence wqaccept - Testar Missão Mundial Aceita"
L["PRESENCE_H_PRESENCE_SCENARIO_TEST_SCENARIO"]                       = "  /h presence scenario - Testar Início de Cenário"
L["PRESENCE_H_PRESENCE_QUEST_TEST_QUEST"]                             = "  /h presence quest    - Testar Missão Concluída"
L["PRESENCE_H_PRESENCE_WQ_TEST_WORLD"]                                = "  /h presence wq       - Testar Missão Mundial"
L["PRESENCE_H_PRESENCE_UPDATE_TEST_QUEST"]                            = "  /h presence update   - Testar Atualização de Missão"
L["PRESENCE_H_PRESENCE_ACHPROGRESS_TEST_ACHIEVEMENT"]                 = "  /h presence achprogress - Testar Progresso de Conquista"
L["PRESENCE_H_PRESENCE_DEMO_REEL_TYPES"]                              = "  /h presence all      - Demo (todos os tipos)"
L["PRESENCE_H_PRESENCE_DEBUG_DUMP_STATE"]                             = "  /h presence debug    - Mostrar estado no chat"
L["PRESENCE_H_PRESENCE_DEBUGLIVE_TOGGLE_LIVE"]                        = "  /h presence debuglive - Alternar painel de debug ao vivo (logar eventos em tempo real)"

-- =====================================================================
-- OptionsData.lua Vista — General
-- L["OPTIONS_VISTA_POSITION_LAYOUT"]                                 = "Position & layout"  -- NEEDS TRANSLATION

-- =====================================================================
L["OPTIONS_VISTA_MINIMAP"]                                            = "Minimapa"
L["OPTIONS_VISTA_MINIMAP_SIZE"]                                       = "Tamanho do minimapa"
L["OPTIONS_VISTA_WIDTH_HEIGHT_OF_MINIMAP_PIXELS"]                     = "Largura e altura do minimapa em pixels (100–400)."
L["OPTIONS_VISTA_CIRCULAR_MINIMAP"]                                   = "Minimapa circular"
-- L["OPTIONS_VISTA_CIRCULAR_SHAPE"]                                  = "Circular shape"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_A_CIRCULAR_MINIMAP_INSTEAD_OF_SQUARE"]               = "Usar minimapa circular em vez de quadrado."
L["OPTIONS_VISTA_LOCK_MINIMAP_POSITION"]                              = "Bloquear posição do minimapa"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MINIMAP"]                           = "Impede arrastar o minimapa."
L["OPTIONS_VISTA_RESET_MINIMAP_POSITION"]                             = "Redefinir posição do minimapa"
L["OPTIONS_VISTA_RESET_MINIMAP_DEFAULT_POSITION_TOP_RIGHT"]           = "Redefine o minimapa para a posição padrão (canto superior direito)."
-- L["OPTIONS_VISTA_RESET_OVERLAY_POSITIONS"]                         = "Reset overlay positions to defaults"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_RESET_OVERLAY_POSITIONS_DESC"]                       = "Clear saved positions for zone text, coordinates, clock, performance and difficulty text, zoom buttons, tracking, calendar, queue, mail, the addon button bar, drawer button, and right-click panel. The minimap frame position is not changed."
L["OPTIONS_VISTA_AUTO_ZOOM"]                                          = "Zoom Automático"
L["OPTIONS_VISTA_AUTO_ZOOM_DELAY"]                                    = "Atraso do zoom-out automático"
L["OPTIONS_VISTA_SECONDS_AFTER_ZOOMING_BEFORE_AUTO_ZOOM"]             = "Segundos após o zoom antes do zoom-out automático. 0 para desativar."

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["OPTIONS_VISTA_ZONE_TEXT_HEADER"]                                   = "Texto da Zona"
L["OPTIONS_VISTA_ZONE_FONT"]                                          = "Fonte da zona"
L["OPTIONS_VISTA_FONT_ZONE_NAME_BELOW_MINIMAP"]                       = "Fonte do nome da zona abaixo do minimapa."
L["OPTIONS_VISTA_ZONE_FONT_SIZE"]                                     = "Tamanho da fonte da zona"
L["OPTIONS_VISTA_ZONE_TEXT_COLOR"]                                    = "Cor do texto da zona"
L["OPTIONS_VISTA_COLOR_OF_ZONE_NAME_TEXT"]                            = "Cor do texto do nome da zona."
L["OPTIONS_VISTA_COORDINATES_TEXT"]                                   = "Texto de Coordenadas"
L["OPTIONS_VISTA_COORDINATES_FONT"]                                   = "Fonte das coordenadas"
L["OPTIONS_VISTA_FONT_COORDINATES_TEXT_BELOW_MINIMAP"]                = "Fonte do texto de coordenadas abaixo do minimapa."
L["OPTIONS_VISTA_COORDINATES_FONT_SIZE"]                              = "Tamanho da fonte das coordenadas"
L["OPTIONS_VISTA_COORDINATES_TEXT_COLOR"]                             = "Cor do texto das coordenadas"
L["OPTIONS_VISTA_COLOR_OF_COORDINATES_TEXT"]                          = "Cor do texto das coordenadas."
L["OPTIONS_VISTA_COORDINATE_PRECISION"]                               = "Precisão das coordenadas"
L["OPTIONS_VISTA_NUMBER_OF_DECIMAL_PLACES_SHOWN_X"]                   = "Número de casas decimais para as coordenadas X e Y."
L["OPTIONS_VISTA_COORDS_DECIMALS_OFF"]                                = "Sem decimais (ex.: 52, 37)"
L["OPTIONS_VISTA_DECIMAL_E_G"]                                        = "1 decimal (ex.: 52.3, 37.1)"
L["OPTIONS_VISTA_DECIMALS_E_G"]                                       = "2 decimais (ex.: 52.34, 37.12)"
L["OPTIONS_VISTA_TEXT"]                                               = "Texto do Horário"
L["OPTIONS_VISTA_FONT"]                                               = "Fonte do horário"
L["OPTIONS_VISTA_FONT_TEXT_BELOW_MINIMAP"]                            = "Fonte do texto de horário abaixo do minimapa."
L["OPTIONS_VISTA_FONT_SIZE"]                                          = "Tamanho da fonte do horário"
L["OPTIONS_VISTA_TEXT_COLOR"]                                         = "Cor do texto do horário"
L["OPTIONS_VISTA_COLOR_OF_TEXT"]                                      = "Cor do texto do horário."
-- L["OPTIONS_VISTA_PERFORMANCE_TEXT"]                                = "Performance Text"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_PERFORMANCE_FONT"]                                = "Performance font"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_FONT_FPS_LATENCY_TEXT_BELOW_MINIMAP"]             = "Font for the FPS and latency text below the minimap."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_PERFORMANCE_FONT_SIZE"]                           = "Performance font size"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_PERFORMANCE_TEXT_COLOR"]                          = "Performance text color"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_COLOR_OF_FPS_LATENCY_TEXT"]                       = "Color of the FPS and latency text."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_DIFFICULTY_TEXT"]                                    = "Texto de Dificuldade"
L["OPTIONS_VISTA_DIFFICULTY_TEXT_COLOR_FALLBACK"]                     = "Cor do texto de dificuldade (padrão)"
L["OPTIONS_VISTA_DEFAULT_COLOR_PER_DIFFICULTY_COLOR"]                 = "Cor padrão quando nenhuma cor por dificuldade está definida."
L["OPTIONS_VISTA_DIFFICULTY_FONT"]                                    = "Fonte de dificuldade"
L["OPTIONS_VISTA_FONT_INSTANCE_DIFFICULTY_TEXT"]                      = "Fonte do texto de dificuldade de instância."
L["OPTIONS_VISTA_DIFFICULTY_FONT_SIZE"]                               = "Tamanho da fonte de dificuldade"
L["OPTIONS_VISTA_PER_DIFFICULTY_COLORS"]                              = "Cores por Dificuldade"
L["OPTIONS_VISTA_MYTHIC_COLOR"]                                       = "Cor Mítica"
L["OPTIONS_VISTA_COLOR_MYTHIC_DIFFICULTY_TEXT"]                       = "Cor do texto de dificuldade Mítica."
L["OPTIONS_VISTA_HEROIC_COLOR"]                                       = "Cor Heroica"
L["OPTIONS_VISTA_COLOR_HEROIC_DIFFICULTY_TEXT"]                       = "Cor do texto de dificuldade Heroica."
L["OPTIONS_VISTA_NORMAL_COLOR"]                                       = "Cor Normal"
L["OPTIONS_VISTA_COLOR_NORMAL_DIFFICULTY_TEXT"]                       = "Cor do texto de dificuldade Normal."
L["OPTIONS_VISTA_LFR_COLOR"]                                          = "Cor LFR"
L["OPTIONS_VISTA_COLOR_LOOKING_RAID_DIFFICULTY_TEXT"]                 = "Cor do texto de dificuldade Procurar Raide."

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["OPTIONS_VISTA_TEXT_ELEMENTS"]                                      = "Elementos de Texto"
L["OPTIONS_VISTA_ZONE_TEXT"]                                          = "Mostrar texto da zona"
L["OPTIONS_VISTA_ZONE_NAME_BELOW_MINIMAP"]                            = "Mostra o nome da zona abaixo do minimapa."
L["OPTIONS_VISTA_ZONE_TEXT_DISPLAY_MODE"]                             = "Modo de exibição do texto da zona"
L["OPTIONS_VISTA_WHAT_ZONE_SUBZONE"]                                  = "O que mostrar: apenas zona, apenas subzona ou ambas."
L["OPTIONS_VISTA_ZONE"]                                               = "Apenas zona"
L["OPTIONS_VISTA_SUBZONE"]                                            = "Apenas subzona"
L["OPTIONS_VISTA_BOTH"]                                               = "Ambas"
L["OPTIONS_VISTA_COORDINATES"]                                        = "Mostrar coordenadas"
L["OPTIONS_VISTA_PLAYER_COORDINATES_BELOW_MINIMAP"]                   = "Mostra as coordenadas do jogador abaixo do minimapa."
L["OPTIONS_VISTA_TIME"]                                               = "Mostrar horário"
L["OPTIONS_VISTA_CURRENT_GAME_BELOW_MINIMAP"]                         = "Mostra o horário do jogo abaixo do minimapa."
-- L["OPTIONS_VISTA_HOUR_CLOCK"]                                      = "24-hour clock"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_DISPLAY_HOUR_FORMAT_E_G_INSTEAD"]                 = "Display time in 24-hour format (e.g. 14:30 instead of 2:30 PM)."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_LOCAL"]                                              = "Usar horário local"
L["OPTIONS_VISTA_YOUR_LOCAL_SYSTEM"]                                  = "Ativado: mostra o horário local do sistema. Desativado: mostra o horário do servidor."
-- L["OPTIONS_VISTA_FPS_LATENCY"]                                     = "Show FPS and latency"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_FPS_LATENCY_MS_BELOW_MINIMAP"]                    = "Show FPS and latency (ms) below the minimap."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_MINIMAP_BUTTONS"]                                    = "Botões do Minimapa"
L["OPTIONS_VISTA_QUEUE_STATUS_MAIL_INDICATOR_ALWAYS_SHOWN"]           = "O status da fila e o indicador de correio sempre são exibidos quando relevantes."
L["OPTIONS_VISTA_TRACKING_BUTTON"]                                    = "Mostrar botão de rastreamento"
L["OPTIONS_VISTA_MINIMAP_TRACKING_BUTTON"]                            = "Mostra o botão de rastreamento no minimapa."
L["OPTIONS_VISTA_TRACKING_BUTTON_MOUSEOVER"]                          = "Botão de rastreamento somente ao passar o mouse"
L["OPTIONS_VISTA_HIDE_TRACKING_BUTTON_UNTIL_YOU_HOVER"]               = "Oculta o botão de rastreamento até passar o mouse sobre o minimapa."
L["OPTIONS_VISTA_CALENDAR_BUTTON"]                                    = "Mostrar botão de calendário"
L["OPTIONS_VISTA_MINIMAP_CALENDAR_BUTTON"]                            = "Mostra o botão de calendário no minimapa."
L["OPTIONS_VISTA_CALENDAR_BUTTON_MOUSEOVER"]                          = "Botão de calendário somente ao passar o mouse"
L["OPTIONS_VISTA_HIDE_CALENDAR_BUTTON_UNTIL_YOU_HOVER"]               = "Oculta o botão de calendário até passar o mouse sobre o minimapa."
L["OPTIONS_VISTA_ZOOM_BUTTONS"]                                       = "Mostrar botões de zoom"
L["OPTIONS_VISTA_ZOOM_BUTTONS_MINIMAP"]                               = "Mostra os botões de zoom + e - no minimapa."
L["OPTIONS_VISTA_ZOOM_BUTTONS_MOUSEOVER"]                             = "Botões de zoom somente ao passar o mouse"
L["OPTIONS_VISTA_HIDE_ZOOM_BUTTONS_UNTIL_YOU_HOVER"]                  = "Oculta os botões de zoom até passar o mouse sobre o minimapa."

-- =====================================================================
-- OptionsData.lua Vista — Display (Border / Text Positions / Buttons)
-- =====================================================================
L["OPTIONS_VISTA_BORDER"]                                             = "Borda"
L["OPTIONS_VISTA_A_BORDER_AROUND_MINIMAP"]                            = "Mostra uma borda ao redor do minimapa."
L["OPTIONS_VISTA_BORDER_COLOR"]                                       = "Cor da borda"
L["OPTIONS_VISTA_COLOR_OPACITY_OF_MINIMAP_BORDER"]                    = "Cor (e opacidade) da borda do minimapa."
L["OPTIONS_VISTA_BORDER_THICKNESS"]                                   = "Espessura da borda"
L["OPTIONS_VISTA_THICKNESS_OF_MINIMAP_BORDER_PIXELS"]                 = "Espessura da borda do minimapa em pixels (1–8)."
-- L["OPTIONS_VISTA_CLASS_COLOURS"]                                   = "Class colours"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_TINT_VISTA_BORDER_TEXT_COORDS_FPS"]               = "Tint Vista border and text (coords, time, FPS/MS labels) with your class colour. Numbers use the configured colour."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_TEXT_POSITIONS"]                                     = "Posições do Texto"
L["OPTIONS_VISTA_DRAG_TEXT_ELEMENTS_REPOSITION_LOCK_PREVEN"]          = "Arraste os elementos de texto para reposicioná-los. Bloqueie para evitar movimentos acidentais."
L["OPTIONS_VISTA_LOCK_ZONE_TEXT_POSITION"]                            = "Bloquear posição do texto da zona"
L["OPTIONS_VISTA_ZONE_TEXT_CANNOT_DRAGGED"]                           = "Ativado: o texto da zona não pode ser arrastado."
L["OPTIONS_VISTA_LOCK_COORDINATES_POSITION"]                          = "Bloquear posição das coordenadas"
L["OPTIONS_VISTA_COORDINATES_TEXT_CANNOT_DRAGGED"]                    = "Ativado: o texto das coordenadas não pode ser arrastado."
L["OPTIONS_VISTA_LOCK_POSITION"]                                      = "Bloquear posição do horário"
L["OPTIONS_VISTA_TEXT_CANNOT_DRAGGED"]                                = "Ativado: o texto do horário não pode ser arrastado."
-- L["OPTIONS_VISTA_PERFORMANCE_TEXT_POSITION"]                       = "Performance text position"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_PLACE_FPS_LATENCY_TEXT_ABOVE_BELOW"]              = "Place the FPS/latency text above or below the minimap."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_LOCK_PERFORMANCE_TEXT_POSITION"]                  = "Lock performance text position"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_FPS_LATENCY_TEXT_CANNOT_DRAGGED"]                 = "When on, the FPS/latency text cannot be dragged."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_LOCK_DIFFICULTY_TEXT_POSITION"]                      = "Bloquear posição do texto de dificuldade"
L["OPTIONS_VISTA_DIFFICULTY_TEXT_CANNOT_DRAGGED"]                     = "Ativado: o texto de dificuldade não pode ser arrastado."
L["OPTIONS_VISTA_BUTTON_POSITIONS"]                                   = "Posições dos Botões"
L["OPTIONS_VISTA_DRAG_BUTTONS_REPOSITION_LOCK_PREVENT_MOVE"]          = "Arraste os botões para reposicioná-los. Bloqueie para fixar."
L["OPTIONS_VISTA_LOCK_ZOOM_BUTTON"]                                   = "Bloquear botão Zoom +"
L["OPTIONS_VISTA_PREVENT_DRAGGING_ZOOM_BUTTON"]                       = "Impede arrastar o botão de zoom +."
L["OPTIONS_VISTA_LOCK_ZOOM_OUT_BUTTON"]                               = "Bloquear botão Zoom -"
L["OPTIONS_VISTA_LOCK_ZOOM_OUT_DRAG"]                                 = "Impede arrastar o botão de zoom -."
L["OPTIONS_VISTA_LOCK_TRACKING_BUTTON"]                               = "Bloquear botão de rastreamento"
L["OPTIONS_VISTA_PREVENT_DRAGGING_TRACKING_BUTTON"]                   = "Impede arrastar o botão de rastreamento."
L["OPTIONS_VISTA_LOCK_CALENDAR_BUTTON"]                               = "Bloquear botão de calendário"
L["OPTIONS_VISTA_PREVENT_DRAGGING_CALENDAR_BUTTON"]                   = "Impede arrastar o botão de calendário."
L["OPTIONS_VISTA_LOCK_QUEUE_BUTTON"]                                  = "Bloquear botão de fila"
L["OPTIONS_VISTA_PREVENT_DRAGGING_QUEUE_STATUS_BUTTON"]               = "Impede arrastar o botão de status da fila."
L["OPTIONS_VISTA_LOCK_MAIL_INDICATOR"]                                = "Bloquear indicador de correio"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MAIL_ICON"]                         = "Impede arrastar o ícone de correio."
-- L["OPTIONS_VISTA_DISABLE_QUEUE_HANDLING"]                          = "Disable queue handling"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_DISABLE_QUEUE_BUTTON_HANDLING"]                      = "Desativar gerenciamento do botão de fila"
L["OPTIONS_VISTA_TURN_QUEUE_BUTTON_ANCHORING_ANOTHER_A"]              = "Desativa toda ancoragem do botão de fila (use se outro addon o gerencia)."
L["OPTIONS_VISTA_BUTTON_SIZES"]                                       = "Tamanhos dos Botões"
L["OPTIONS_VISTA_ADJUST_SIZE_OF_MINIMAP_OVERLAY_BUTTONS"]             = "Ajusta o tamanho dos botões sobrepostos ao minimapa."
L["OPTIONS_VISTA_TRACKING_BUTTON_SIZE"]                               = "Tamanho do botão de rastreamento"
L["OPTIONS_VISTA_SIZE_OF_TRACKING_BUTTON_PIXELS"]                     = "Tamanho do botão de rastreamento (pixels)."
L["OPTIONS_VISTA_CALENDAR_BUTTON_SIZE"]                               = "Tamanho do botão de calendário"
L["OPTIONS_VISTA_SIZE_OF_CALENDAR_BUTTON_PIXELS"]                     = "Tamanho do botão de calendário (pixels)."
L["OPTIONS_VISTA_QUEUE_BUTTON_SIZE"]                                  = "Tamanho do botão de fila"
L["OPTIONS_VISTA_SIZE_OF_QUEUE_STATUS_BUTTON_PIXELS"]                 = "Tamanho do botão de status da fila (pixels)."
L["OPTIONS_VISTA_ZOOM_BUTTON_SIZE"]                                   = "Tamanho dos botões de zoom"
L["OPTIONS_VISTA_SIZE_OF_ZOOM_ZOOM_BUTTONS_PIXELS"]                   = "Tamanho dos botões de zoom + / - (pixels)."
L["OPTIONS_VISTA_MAIL_INDICATOR_SIZE"]                                = "Tamanho do indicador de correio"
L["OPTIONS_VISTA_SIZE_OF_MAIL_ICON_PIXELS"]                           = "Tamanho do ícone de novo correio (pixels)."
L["OPTIONS_VISTA_ADDON_BUTTON_SIZE"]                                  = "Tamanho dos botões de addon"
L["OPTIONS_VISTA_SIZE_OF_COLLECTED_ADDON_MINIMAP_BUTTONS"]            = "Tamanho dos botões de addon coletados no minimapa (pixels)."

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
-- L["OPTIONS_VISTA_COLLECT_HORIZON_MINIMAP"]                         = "Include Horizon minimap icon"  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_COLLECT_HORIZON_MINIMAP_DESC"]                    = "Put Horizon's own minimap icon in the managed addon bar, right-click panel, or drawer instead of leaving it on the minimap edge."  -- NEEDS TRANSLATION
-- L["OPTIONS_VISTA_ADDON_BUTTONS"]                                   = "Addon Buttons"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_MINIMAP_ADDON_BUTTONS"]                              = "Botões de Addon no Minimapa"
L["OPTIONS_VISTA_BUTTON_MANAGEMENT"]                                  = "Gerenciamento de Botões"
L["OPTIONS_VISTA_MANAGE_ADDON_MINIMAP_BUTTONS"]                       = "Gerenciar botões de addon no minimapa"
L["OPTIONS_VISTA_VISTA_TAKES_CONTROL_OF_ADDON_MINIMAP"]               = "Ativado: Vista assume o controle dos botões de addon e os agrupa pelo modo selecionado."
L["OPTIONS_VISTA_BUTTON_MODE"]                                        = "Modo dos botões"
L["OPTIONS_VISTA_ADDON_BUTTONS_PRESENTED_HOVER_BAR_BELOW"]            = "Como os botões de addon são apresentados: barra ao passar o mouse, painel ao clicar com o botão direito ou botão gaveta flutuante."
-- L["OPTIONS_VISTA_ALWAYS_BAR"]                                      = "Always show bar"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_ALWAYS_MOUSEOVER_BAR_POSITIONING"]                   = "Sempre mostrar barra ao passar o mouse (para posicionamento)"
L["OPTIONS_VISTA_KEEP_MOUSEOVER_BAR_VISIBLE_TIMES_YOU"]               = "Mantém a barra visível o tempo todo para você reposicioná-la. Desative quando terminar."
-- L["OPTIONS_VISTA_DISABLE_DONE"]                                    = "Disable when done."  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_MOUSEOVER_BAR"]                                      = "Barra ao passar o mouse"
L["OPTIONS_VISTA_RIGHT_CLICK_PANEL"]                                  = "Painel com botão direito"
L["OPTIONS_VISTA_FLOATING_DRAWER"]                                    = "Gaveta flutuante"
L["OPTIONS_VISTA_LOCK_DRAWER_BUTTON_POSITION"]                        = "Bloquear posição do botão gaveta"
L["OPTIONS_VISTA_PREVENT_DRAGGING_FLOATING_DRAWER_BUTTON"]            = "Impede arrastar o botão da gaveta flutuante."
L["OPTIONS_VISTA_LOCK_MOUSEOVER_BAR_POSITION"]                        = "Bloquear posição da barra ao passar o mouse"
L["OPTIONS_VISTA_PREVENT_DRAGGING_MOUSEOVER_BUTTON_BAR"]              = "Impede arrastar a barra de botões ao passar o mouse."
L["OPTIONS_VISTA_LOCK_RIGHT_CLICK_PANEL_POSITION"]                    = "Bloquear posição do painel de botão direito"
L["OPTIONS_VISTA_PREVENT_DRAGGING_RIGHT_CLICK_PANEL"]                 = "Impede arrastar o painel de botão direito."
L["OPTIONS_VISTA_BUTTONS_PER_ROW_COLUMN"]                             = "Botões por linha/coluna"
L["OPTIONS_VISTA_CONTROLS_MANY_BUTTONS_APPEAR_BEFORE_WRAPPING"]       = "Controla quantos botões aparecem antes de quebrar. Para esquerda/direita são colunas; para cima/baixo são linhas."
L["OPTIONS_VISTA_EXPAND_DIRECTION"]                                   = "Direção de expansão"
L["OPTIONS_VISTA_DIRECTION_BUTTONS_FILL_ANCHOR_POINT_LEFT"]           = "Direção de preenchimento a partir do ponto de ancoragem. Esquerda/Direita = linhas horizontais. Cima/Baixo = colunas verticais."
L["OPTIONS_VISTA_RIGHT"]                                              = "Direita"
L["OPTIONS_VISTA_LEFT"]                                               = "Esquerda"
L["OPTIONS_VISTA_DOWN"]                                               = "Baixo"
L["OPTIONS_VISTA_UP"]                                                 = "Cima"
L["OPTIONS_VISTA_MOUSEOVER_BAR_APPEARANCE"]                           = "Aparência da barra ao passar o mouse"
L["OPTIONS_VISTA_BACKGROUND_BORDER_MOUSEOVER_BUTTON_BAR"]             = "Fundo e borda da barra de botões ao passar o mouse."
L["OPTIONS_VISTA_BACKDROP_COLOR"]                                     = "Cor do fundo"
L["OPTIONS_VISTA_BACKGROUND_COLOR_OF_MOUSEOVER_BUTTON_BAR"]           = "Cor de fundo da barra de botões ao passar o mouse (use alfa para controlar a transparência)."
L["OPTIONS_VISTA_BAR_BORDER"]                                         = "Mostrar borda da barra"
L["OPTIONS_VISTA_A_BORDER_AROUND_MOUSEOVER_BUTTON_BAR"]               = "Mostra uma borda ao redor da barra de botões ao passar o mouse."
L["OPTIONS_VISTA_BAR_BORDER_COLOR"]                                   = "Cor da borda da barra"
L["OPTIONS_VISTA_BORDER_COLOR_OF_MOUSEOVER_BUTTON_BAR"]               = "Cor da borda da barra de botões ao passar o mouse."
L["OPTIONS_VISTA_BAR_BACKGROUND_COLOR"]                               = "Cor de fundo da barra"
L["OPTIONS_VISTA_PANEL_BACKGROUND_COLOR"]                             = "Cor de fundo do painel."
L["OPTIONS_VISTA_CLOSE_FADE_TIMING"]                                  = "Tempo de fechamento/esmaecimento"
L["OPTIONS_VISTA_MOUSEOVER_BAR_CLOSE_DELAY_SECONDS"]                  = "Barra ao passar o mouse — atraso para fechar (segundos)"
L["OPTIONS_VISTA_LONG_SECONDS_BAR_STAYS_VISIBLE_AFTER"]               = "Por quanto tempo (em segundos) a barra permanece visível após o cursor sair. 0 = esmaecimento instantâneo."
L["OPTIONS_VISTA_RIGHT_CLICK_PANEL_CLOSE_DELAY_SECONDS"]              = "Painel de clique direito — atraso para fechar (segundos)"
L["OPTIONS_VISTA_LONG_SECONDS_PANEL_STAYS_OPEN_AFTER"]                = "Por quanto tempo (em segundos) o painel fica aberto após o cursor sair. 0 = nunca fechar automaticamente (feche clicando com o botão direito novamente)."
L["OPTIONS_VISTA_FLOATING_DRAWER_CLOSE_DELAY_SECONDS"]                = "Gaveta flutuante — atraso para fechar (segundos)"
-- L["OPTIONS_VISTA_DRAWER_CLOSE_DELAY"]                              = "Drawer close delay"  -- NEEDS TRANSLATION
L["OPTIONS_VISTA_LONG_SECONDS_DRAWER_PANEL_STAYS_OPEN"]               = "Por quanto tempo (em segundos) o painel da gaveta permanece aberto após clicar fora. 0 = nunca fechar automaticamente (feche apenas clicando no botão da gaveta novamente)."
L["OPTIONS_VISTA_MAIL_ICON_BLINK"]                                    = "Piscar ícone de correio"
L["OPTIONS_VISTA_MAIL_ICON_PULSES_DRAW_ATTENTION"]                    = "Ativado: o ícone de correio pulsa para chamar atenção. Desativado: permanece com opacidade total."
L["OPTIONS_VISTA_PANEL_APPEARANCE"]                                   = "Aparência do Painel"
L["OPTIONS_VISTA_COLORS_DRAWER_RIGHT_CLICK_BUTTON_PANELS"]            = "Cores para os painéis de botões (gaveta e botão direito)."
L["OPTIONS_VISTA_PANEL_BG_COLOR_LABEL"]                               = "Cor de fundo do painel"
L["OPTIONS_VISTA_BACKGROUND_COLOR_OF_ADDON_BUTTON_PANELS"]            = "Cor de fundo dos painéis de botões de addon."
L["OPTIONS_VISTA_PANEL_BORDER_COLOR"]                                 = "Cor da borda do painel"
L["OPTIONS_VISTA_BORDER_COLOR_OF_ADDON_BUTTON_PANELS"]                = "Cor da borda dos painéis de botões de addon."
L["OPTIONS_VISTA_MANAGED_BUTTONS"]                                    = "Botões gerenciados"
L["OPTIONS_VISTA_BUTTON_COMPLETELY_IGNORED_A"]                        = "Desativado: este botão é completamente ignorado por este addon."
L["OPTIONS_VISTA_ADDON_BUTTONS_DETECTED"]                             = "(Nenhum botão de addon detectado ainda)"
L["OPTIONS_VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE"]                      = "Botões visíveis (marque para incluir)"
L["OPTIONS_VISTA_ADDON_BUTTONS_DETECTED_OPEN_YOUR_MINIMAP"]           = "(Nenhum botão de addon detectado — abra o minimapa primeiro)"

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










































































