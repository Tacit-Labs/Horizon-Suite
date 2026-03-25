if GetLocale() ~= "frFR" then return end

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = setmetatable({}, { __index = addon.L })
addon.L = L
addon.StandardFont = UNIT_NAME_FONT  -- Change only if your locale needs a different font

-- =====================================================================
-- OptionsPanel.lua — Title
-- =====================================================================
L["HORIZON SUITE"]                                                      = "HORIZON SUITE"

-- =====================================================================
-- OptionsPanel.lua — Sidebar module group labels
-- =====================================================================
L["Focus"]                                                              = "Focus"
L["Presence"]                                                           = "Presence"
L["Other"]                                                              = "Autres"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["Quest types"]                                                        = "Types de quêtes"
L["Element overrides"]                                                  = "Couleurs par élément"
L["Per category"]                                                       = "Couleurs par catégorie"
L["Grouping Overrides"]                                                 = "Couleurs personnalisées"
L["Section Overrides"]                                                  = "Couleurs de section"
L["Other colors"]                                                       = "Autres couleurs"

-- =====================================================================
-- OptionsPanel.lua — Color row labels (collapsible group sub-rows)
-- =====================================================================
L["Section"]                                                            = "Section"
L["Title"]                                                              = "Titre"
L["Zone"]                                                               = "Zone"
L["Objective"]                                                          = "Objectif"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["Ready to Turn In overrides base colours"]                            = "Choisir des couleurs différentes pour la section À Rendre"
L["Ready to Turn In uses its colours for quests in that section."]      = "La section À Rendre utilisera ses propres couleurs."
L["Current Zone overrides base colours"]                                = "Choisir des couleurs différentes pour la section Zone Actuelle"
L["Current Zone uses its colours for quests in that section."]          = "La section Zone Actuelle utilisera ses propres couleurs."
L["Current Quest overrides base colours"]                               = "Choisir des couleurs différentes pour la section Quête actuelle"
L["Current Quest uses its colours for quests in that section."]         = "La section En Cours utilisera ses propres couleurs."
L["Use distinct color for completed objectives"]                        = "Utiliser une couleur distincte pour les objectifs terminés"
L["When on, completed objectives (e.g. 1/1) use the color below; when off, they use the same color as incomplete objectives."]= "Activé : les objectifs terminés (ex. 1/1) utilisent la couleur suivante. Désactivé : ils utilisent la même couleur que les objectifs incomplets."
L["Completed objective"]                                                = "Objectif terminé"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["Reset"]                                                              = "Réinitialiser"
L["Reset quest types"]                                                  = "Réinitialiser les types de quêtes"
L["Reset overrides"]                                                    = "Réinitialiser les couleurs personnalisées"
L["Reset all to defaults"]                                              = "Tout réinitialiser aux valeurs par défaut"
L["Reset to defaults"]                                                  = "Réinitialiser les valeurs par défaut"
L["Reset to default"]                                                   = "Réinitialiser la valeur par défaut"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["Search settings..."]                                                 = "Recherche..."
L["Search fonts..."]                                                    = "Rechercher une police..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["Drag to resize"]                                                     = "Glisser pour redimensionner"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
L["Profiles"]                                                           = "Profils"
L["Modules"]                                                            = "Modules"
-- L["Module Toggles"]                                                     = "Module Toggles"  -- NEEDS TRANSLATION
L["Axis"]                                                               = "Axis"

-- =====================================================================
-- DashboardPanel.lua — First-run welcome
-- =====================================================================
-- L["Dashboard welcome tab"]                                              = "Welcome"  -- NEEDS TRANSLATION
-- L["Dashboard welcome title"]                                            = "Welcome to Horizon Suite"  -- NEEDS TRANSLATION
-- L["Dashboard welcome head sub"]                                         = "What each module does and where to turn them on"  -- NEEDS TRANSLATION
-- L["Dashboard welcome intro"]                                            = "Horizon Suite is modular — enable only the pieces you want. Turning a module on or off applies on reload. Use Open Module Toggles below, or open Axis, then Modules, in the sidebar. You can return to this Welcome page anytime from the sidebar."  -- NEEDS TRANSLATION
-- L["Dashboard welcome path"]                                             = "%s → %s → %s"  -- NEEDS TRANSLATION
-- L["Dashboard welcome modules heading"]                                  = "Modules"  -- NEEDS TRANSLATION
-- L["Dashboard welcome continue"]                                         = "Go to Home"  -- NEEDS TRANSLATION
-- L["Dashboard welcome open toggles"]                                     = "Open Module Toggles"  -- NEEDS TRANSLATION
-- L["Objective tracker for quests, world quests, rares, achievements, scenarios."]= "Objective tracker for quests, world quests, rares, achievements, scenarios."  -- NEEDS TRANSLATION
-- L["Zone text and notifications."]                                       = "Zone text and notifications."  -- NEEDS TRANSLATION
-- L["Minimap with zone text, coords, time, and button collector."]        = "Minimap with zone text, coords, time, and button collector."  -- NEEDS TRANSLATION
-- L["Tooltips with class colors, spec, and faction icons."]               = "Tooltips with class colors, spec, and faction icons."  -- NEEDS TRANSLATION
-- L["Loot toasts for items, money, currency, reputation."]                = "Loot toasts for items, money, currency, reputation."  -- NEEDS TRANSLATION
-- L["Persona module short description"]                                   = "Custom character sheet with 3D model, item level, stats, and gear grid."  -- NEEDS TRANSLATION
L["Layout"]                                                             = "Disposition"
L["Visibility"]                                                         = "Visibilité"
L["Display"]                                                            = "Affichage"
L["Features"]                                                           = "Fonctionnalités"
L["Typography"]                                                         = "Textes"
L["Appearance"]                                                         = "Apparence"
L["Colors"]                                                             = "Couleurs"
L["Organization"]                                                       = "Organisation"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["Panel behaviour"]                                                    = "Comportement du panneau"
L["Dimensions"]                                                         = "Dimensions"
L["Instance"]                                                           = "Instance"
L["Instances"]                                                          = "Instances"
L["Combat"]                                                             = "Combat"
L["Filtering"]                                                          = "Filtres"
L["Header"]                                                             = "En-tête"
L["Sections & structure"]                                               = "Sections & structure"
L["Entry details"]                                                      = "Détails de l'élément"
L["Progress & timers"]                                                  = "Progressions & décomptes"
L["Focus emphasis"]                                                     = "Mise en évidence"
L["List"]                                                               = "Liste"
L["Spacing"]                                                            = "Espacement"
L["Rare bosses"]                                                        = "Boss rares"
L["World quests"]                                                       = "Expéditions"
L["Floating quest item"]                                                = "Objet de quête flottant"
L["Mythic+"]                                                            = "Mythique+"
L["Achievements"]                                                       = "Hauts faits"
L["Endeavors"]                                                          = "Initiatives"
L["Decor"]                                                              = "Décoration"
L["Scenario & Delve"]                                                   = "Scénario et Gouffre"
L["Font"]                                                               = "Police"
L["Font families"]                                                      = "Familles de polices"
L["Global font size"]                                                   = "Taille du texte global"
L["Font sizes"]                                                         = "Tailles des textes"
L["Per-element fonts"]                                                  = "Polices par élément"
L["Text case"]                                                          = "Casse"
L["Shadow"]                                                             = "Ombre"
L["Panel"]                                                              = "Panneau"
L["Highlight"]                                                          = "Surbrillance"
L["Color matrix"]                                                       = "Matrice de couleurs"
L["Focus order"]                                                        = "Ordre de Focus"
L["Sort"]                                                               = "Tri"
L["Behaviour"]                                                          = "Comportement"
L["Content Types"]                                                      = "Types de contenu"
L["Delves"]                                                             = "Gouffres"
L["Delves & Dungeons"]                                                  = "Gouffres & Donjons"
L["Delve Complete"]                                                     = "Gouffre terminé"
L["Interactions"]                                                       = "Interactions"
L["Tracking"]                                                           = "Suivi"
L["Scenario Bar"]                                                       = "Barre de scénario"

-- =====================================================================
-- OptionsData.lua Profiles
-- =====================================================================
-- L["Vista"]                                                              = "Vista"  -- NEEDS TRANSLATION
-- L["Current profile"]                                                    = "Current profile"  -- NEEDS TRANSLATION
-- L["Select the profile currently in use."]                               = "Select the profile currently in use."  -- NEEDS TRANSLATION
-- L["Use global profile (account-wide)"]                                  = "Use global profile (account-wide)"  -- NEEDS TRANSLATION
-- L["All characters use the same profile."]                               = "All characters use the same profile."  -- NEEDS TRANSLATION
-- L["Enable per specialization profiles"]                                 = "Enable per specialization profiles"  -- NEEDS TRANSLATION
-- L["Pick different profiles per spec."]                                  = "Pick different profiles per spec."  -- NEEDS TRANSLATION
-- L["Specialization"]                                                     = "Specialization"  -- NEEDS TRANSLATION
-- L["Sharing"]                                                            = "Sharing"  -- NEEDS TRANSLATION
-- L["Import profile"]                                                     = "Import profile"  -- NEEDS TRANSLATION
-- L["Import string"]                                                      = "Import string"  -- NEEDS TRANSLATION
-- L["Export profile"]                                                     = "Export profile"  -- NEEDS TRANSLATION
-- L["Select a profile to export."]                                        = "Select a profile to export."  -- NEEDS TRANSLATION
-- L["Export string"]                                                      = "Export string"  -- NEEDS TRANSLATION
-- L["Copy from profile"]                                                  = "Copy from profile"  -- NEEDS TRANSLATION
-- L["Source profile for copying."]                                        = "Source profile for copying."  -- NEEDS TRANSLATION
-- L["Copy from selected"]                                                 = "Copy from selected"  -- NEEDS TRANSLATION
-- L["Create"]                                                             = "Create"  -- NEEDS TRANSLATION
-- L["Create new profile from Default template"]                           = "Create new profile from Default template"  -- NEEDS TRANSLATION
-- L["Creates a new profile with all default settings."]                   = "Creates a new profile with all default settings."  -- NEEDS TRANSLATION
-- L["Creates a new profile copied from the selected source profile."]     = "Creates a new profile copied from the selected source profile."  -- NEEDS TRANSLATION
-- L["Delete profile"]                                                     = "Delete profile"  -- NEEDS TRANSLATION
-- L["Select a profile to delete (current and Default not shown)."]        = "Select a profile to delete (current and Default not shown)."  -- NEEDS TRANSLATION
-- L["Delete selected"]                                                    = "Delete selected"  -- NEEDS TRANSLATION
-- L["Delete selected profile"]                                            = "Delete selected profile"  -- NEEDS TRANSLATION
-- L["Delete"]                                                             = "Delete"  -- NEEDS TRANSLATION
-- L["Deletes the selected profile."]                                      = "Deletes the selected profile."  -- NEEDS TRANSLATION
-- L["Global profile"]                                                     = "Global profile"  -- NEEDS TRANSLATION
-- L["Per-spec profiles"]                                                  = "Per-spec profiles"  -- NEEDS TRANSLATION

-- =====================================================================
-- OptionsData.lua Modules
-- =====================================================================
L["Enable Focus module"]                                                = "Activer le module Focus"
L["Show the objective tracker for quests, world quests, rares, achievements, and scenarios."]= "Affiche le suivi des objectifs pour les quêtes, expéditions, boss rares, hauts faits et scénarios."
L["Enable Presence module"]                                             = "Activer le module Presence"
L["Cinematic zone text and notifications (zone changes, level up, boss emotes, achievements, quest updates)."]= "Texte de zone cinématique et notifications (changement de zone, montée de niveau, emotes de boss, hauts faits, mises à jour de quêtes)."
L["Enable Yield module"]                                                = "Activer le module Yield"
L["Cinematic loot notifications (items, money, currency, reputation)."] = "Alertes cinématiques de butin (objets, argent, monnaies, réputation)."
L["Enable Vista module"]                                                = "Activer le module Vista"
L["Cinematic square minimap with zone text, coordinates, and button collector."]= "Minicarte carrée cinématique avec texte de zone, coordonnées et rubrique à boutons."
L["Cinematic square minimap with zone text, coordinates, time, and button collector."]= "Minicarte carrée cinématique avec texte de zone, coordonnées, horloge et conteneur de boutons."
L["Beta"]                                                               = "Beta"
L["Scaling"]                                                            = "Mise à l'échelle"
L["Global Toggles"]                                                     = "Réglages globaux"
L["Suite-wide class colour tinting and UI scale (global or per module)."]= "Teintes de couleur de classe et échelle d'interface pour toute la suite (globale ou par module)."
L["Global UI scale"]                                                    = "Échelle globale de l'interface"
L["Scale all sizes, spacings, and fonts by this factor (50–200%). Does not change your configured values."]= "Met à l'échelle toutes les tailles, espacements et polices selon ce facteur (50–200 %). Ne modifie pas vos valeurs configurées."
L["Per-module scaling"]                                                 = "Échelle par module"
L["Override the global scale with individual sliders for each module."] = "Remplace l'échelle globale par des curseurs individuels pour chaque module."
L["Overrides the global scale with individual sliders for Focus, Presence, Vista, etc."]= "Utiliser des glissières d'échelle individuelles pour les modules Focus, Presence, Vista, etc."
L["Doesn't change your configured values, only the effective display scale."]= "Ne change pas vos valeurs de réglages, seulement la mise à l'échelle de l'interface."
L["Focus scale"]                                                        = "Échelle Focus"
L["Scale for the Focus objective tracker (50–200%)."]                   = "Échelle du suivi d'objectifs Focus (50–200 %)."
L["Presence scale"]                                                     = "Échelle Presence"
L["Scale for the Presence cinematic text (50–200%)."]                   = "Échelle du texte cinématique Presence (50–200 %)."
L["Vista scale"]                                                        = "Échelle Vista"
L["Scale for the Vista minimap module (50–200%)."]                      = "Échelle du module de minicarte Vista (50–200 %)."
L["Insight scale"]                                                      = "Échelle Insight"
L["Scale for the Insight tooltip module (50–200%)."]                    = "Échelle du module d'infobulle Insight (50–200 %)."
L["Yield scale"]                                                        = "Échelle Yield"
L["Scale for the Yield loot toast module (50–200%)."]                   = "Échelle du module d'alerte de butin Yield (50–200 %)."
L["Enable Horizon Insight module"]                                      = "Activer le module Horizon Insight"
L["Cinematic tooltips with class colors, spec display, and faction icons."]= "Infobulles cinématiques avec couleurs de classe, spécialisation et icônes de faction."
L["Horizon Insight"]                                                    = "Horizon Insight"
L["Insight"]                                                            = "Insight"
L["Tooltip anchor mode"]                                                = "Mode d'ancrage des infobulles"
L["Where tooltips appear: follow cursor or fixed position."]            = "Où les infobulles s'affichent : suivre le curseur ou position fixe."
L["Cursor"]                                                             = "Curseur"
L["Fixed"]                                                              = "Fixe"
L["Show anchor to move"]                                                = "Afficher les poignées de déplacement"
L["Click to show or hide the anchor. Drag to set position, right-click to confirm."]= "Cliquer pour montrer ou cacher l'ancre. Glisser pour positionner, clic droit pour confirmer."
L["Show draggable frame to set fixed tooltip position. Drag, then right-click to confirm."]= "Affiche un cadre déplaçable pour définir la position fixe. Glisser, puis clic droit pour confirmer."
L["Reset tooltip position"]                                             = "Réinitialiser la position des infobulles"
L["Reset fixed position to default."]                                   = "Réinitialiser la position fixe par défaut."
L["Tooltip background color"]                                           = "Couleur de fond des infobulles"
L["Color of the tooltip background."]                                   = "Couleur de fond des infobulles."
L["Tooltip background opacity"]                                         = "Opacité du fond des infobulles"
L["Tooltip background opacity (0–100%)."]                               = "Opacité du fond des infobulles (0–100 %)."
L["Tooltip font"]                                                       = "Police de l'infobulle"
L["Font family used for all tooltip text."]                             = "Famille de police utilisée pour le texte de l'infobulle."
L["Tooltips"]                                                           = "Infobulles"
L["Item Tooltip"]                                                       = "Description d'objet"
L["Show transmog status"]                                               = "Afficher l'état de transmogrification"
L["Show whether you have collected the appearance of an item you hover over."]= "Montrer si l'apparence de l'objet a déjà été collecté."
L["Player Tooltip"]                                                     = "Infobulle du joueur"
L["Show guild rank"]                                                    = "Montrer le rang de guilde"
L["Append the player's guild rank next to their guild name."]           = "Ajouter le rang de la guilde du joueur à la suite de son nom."
L["Show Mythic+ score"]                                                 = "Montrer le score Mythique+"
L["Show the player's current season Mythic+ score, colour-coded by tier."]= "Montrer le score Mythique+ de la saison actuelle du joueur, coloré par palier."
L["Show item level"]                                                    = "Montrer le niveau d'objet"
L["Show the player's equipped item level after inspecting them."]       = "Affiche le niveau d'objet du joueur après l'avoir inspecté."
L["Show honor level"]                                                   = "Montrer l'honneur"
L["Show the player's PvP honor level in the tooltip."]                  = "Affiche le niveau d'honneur du joueur dans l'infobulle."
L["Show PvP title"]                                                     = "Montrer le titre PvP"
L["Show the player's PvP title (e.g. Gladiator) in the tooltip."]       = "Affiche le titre PvP du joueur (ex: Gladiateur) dans l'infobulle."
L["Character title"]                                                    = "Titre du personnage"
L["Show the player's selected title (achievement or PvP) in the name line."]= "Affiche le titre (haut fait ou PvP) à la suite du nom du personnage."
L["Title color"]                                                        = "Couleur du titre"
L["Color of the character title in the player tooltip name line."]      = "Couleur du titre sur la ligne du nom du joueur."
L["Show status badges"]                                                 = "Montrer les badges de statut"
L["Show inline badges for combat, AFK, DND, PvP flag, party/raid membership, friends, and whether the player is targeting you."]= "Affiche les différents badges de combat, ABS, NPD, PvP, présence en groupe/raid, amis, ou si le joueur vous cible."
L["Show mount info"]                                                    = "Montrer les informations de monture"
L["When hovering a mounted player, show their mount name, source, and whether you own it."]= "Au survol d'un joueur, affiche le nom de sa monture, sa source, et si vous la possédez."
L["Blank separator"]                                                    = "Séparateur vide"
L["Use a blank line instead of dashes between tooltip sections."]       = "Utilise un séparateur vide à la place des tirets entre les différentes sections de l'infobulle."
L["Show icons"]                                                         = "Montrer les icones"
L["Class icon style"]                                                   = "Style des icones de classe"
L["Use Default (Blizzard) or RondoMedia class icons on the class/spec line."]= "Utilise les icônes de classe par défaut (Blizzard) ou celles de RondoMedia sur la ligne de la classe/spé."
L["RondoMedia class icons by RondoFerrari — https://www.curseforge.com/wow/addons/rondomedia"]= "Icones de classes créées par RondoFerrari — https://www.curseforge.com/wow/addons/rondomedia"
L["Default"]                                                            = "Par défaut"
L["Show faction, spec, mount, and Mythic+ icons in tooltips."]          = "SMontrer la faction, la spécialisation, la monture et les icônes de Mythique+ dans les infobulles."
L["Yield"]                                                              = "Yield"
L["General"]                                                            = "Général"
L["Position"]                                                           = "Position"
L["Reset position"]                                                     = "Réinitialiser la position"
L["Reset loot toast position to default."]                              = "Réinitialiser la position des alertes de butin."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["Lock position"]                                                      = "Verrouiller la position"
L["Prevent dragging the tracker."]                                      = "Empêche de déplacer le panneau d'objectifs."
L["Grow upward"]                                                        = "Croissance vers le haut"
L["Grow-up header"]                                                     = "En-tête croissance"
L["When growing upward: keep header at bottom, or at top until collapsed."]= "En croissance vers le haut : garder l'en-tête en bas ou en haut jusqu'au repli."
L["Header at bottom"]                                                   = "En-tête en bas"
L["Header slides on collapse"]                                          = "En-tête glisse au repli"
L["Anchor at bottom so the list grows upward."]                         = "Ancré en bas pour que la liste s'agrandisse vers le haut."
L["Start collapsed"]                                                    = "Replié par défaut"
L["Start with only the header shown until you expand."]                 = "N'afficher que l'en-tête par défaut jusqu'au déploiement."
L["Align content right"]                                                = "Aligner le contenu à droite"
L["Right-align quest titles and objectives within the panel."]          = "Le titre des quêtes les objectifs s'ajustent sur le coté droit du panneau de suivi."
L["Panel width"]                                                        = "Largeur du panneau"
L["Tracker width in pixels."]                                           = "Largeur du panneau d'objectifs en pixels."
L["Max content height"]                                                 = "Hauteur max du contenu"
L["Max height of the scrollable list (pixels)."]                        = "Hauteur maximale de la liste défilable (pixels)."

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["Always show M+ block"]                                               = "Toujours afficher le bloc M+"
L["Show the M+ block whenever an active keystone is running"]           = "Affiche le bloc M+ dès qu'une clé Mythique est active."
L["Show in dungeon"]                                                    = "Afficher en Donjon"
L["Show tracker in party dungeons."]                                    = "Affiche le panneau d'objectifs dans les donjons."
L["Show in raid"]                                                       = "Afficher en Raid"
L["Show tracker in raids."]                                             = "Affiche le panneau d'objectifs dans les raids."
L["Show in battleground"]                                               = "Afficher en Champ de bataille"
L["Show tracker in battlegrounds."]                                     = "Affiche le panneau d'objectifs en champs de bataille."
L["Show in arena"]                                                      = "Afficher en Arène"
L["Show tracker in arenas."]                                            = "Affiche le panneau d'objectifs en arène."
L["Hide in combat"]                                                     = "Masquer en combat"
L["Hide tracker and floating quest item in combat."]                    = "Masque le panneau d'objectifs et les objets de quête flottants en combat."
L["Combat visibility"]                                                  = "Visibilité en combat"
L["How the tracker behaves in combat: show, fade to reduced opacity, or hide."]= "Comportement du panneau en combat : afficher, estomper ou masquer."
L["Show"]                                                               = "Afficher"
L["Fade"]                                                               = "Estomper"
L["Hide"]                                                               = "Masquer"
L["Combat fade opacity"]                                                = "Opacité en combat (estomper)"
L["How visible the tracker is when faded in combat (0 = invisible). Only applies when Combat visibility is Fade."]= "Visibilité du panneau quand estompé en combat (0 = invisible). S'applique uniquement quand la visibilité en combat est « Estomper »."
L["Mouseover"]                                                          = "Survol"
L["Show only on mouseover"]                                             = "Afficher au survol uniquement"
L["Fade tracker when not hovering; move mouse over it to show."]        = "Estompe le panneau quand la souris n'est pas dessus ; survolez pour l'afficher."
L["Faded opacity"]                                                      = "Opacité estompée"
L["How visible the tracker is when faded (0 = invisible)."]             = "Visibilité du panneau quand estompé (0 = invisible)."
L["Only show quests in current zone"]                                   = "Quêtes de la Zone Actuelle uniquement"
L["Hide quests outside your current zone."]                             = "Masque les quêtes hors de la Zone Actuelle."

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["Show quest count"]                                                   = "Afficher le nombre de quêtes"
L["Show quest count in header."]                                        = "Affiche le nombre de quêtes dans l'en-tête."
L["Header count format"]                                                = "Format du compteur de quêtes"
L["Tracked/in-log or in-log/max-slots. Tracked excludes world/live-in-zone quests."]= "Suivies/Dans le journal ou Dans le journal/Quêtes max. Les quêtes suivies ne prennent pas en compte les expéditions et les objectifs de zone bonus."
L["Show header divider"]                                                = "Afficher le séparateur d'en-tête"
L["Show the line below the header."]                                    = "Affiche la ligne sous l'en-tête."
L["Header divider color"]                                               = "Couleur du séparateur d'en-tête"
L["Color of the line below the header."]                                = "Couleur de la ligne sous l'en-tête."
L["Super-minimal mode"]                                                 = "Mode Super-minimal"
L["Hide header for a pure text list."]                                  = "Masque l'en-tête pour une liste de texte simple."
L["Show options button"]                                                = "Afficher le bouton Options"
L["Show the Options button in the tracker header."]                     = "Affiche le bouton Options dans l'en-tête."
L["Header color"]                                                       = "Couleur de l'en-tête"
L["Color of the OBJECTIVES header text."]                               = "Couleur du texte OBJECTIFS dans l'en-tête."
L["Header height"]                                                      = "Hauteur de l'en-tête"
L["Height of the header bar in pixels (18–48)."]                        = "Hauteur de la barre d'en-tête en pixels (18–48)."

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["Show section headers"]                                               = "Afficher les en-têtes de section"
L["Show category labels above each group."]                             = "Affiche les catégories au-dessus de chaque groupe."
L["Show category headers when collapsed"]                               = "En-têtes des catégories visibles quand replié"
L["Keep section headers visible when collapsed; click to expand a category."]= "Garde les en-têtes visibles quand le panneau est replié ; cliquez pour déployer une catégorie."
L["Show Nearby (Current Zone) group"]                                   = "Afficher le groupe Zone actuelle"
L["Show in-zone quests in a dedicated Current Zone section. When off, they appear in their normal category."]= "Affiche les quêtes de la Zone Actuelle dans une section dédiée. Quand Désactivé : elles apparaissent dans leur catégorie habituelle."
L["Show zone labels"]                                                   = "Afficher les noms de zone"
L["Show zone name under each quest title."]                             = "Affiche le nom de zone sous chaque titre de quête."
L["Active quest highlight"]                                             = "Surbrillance de la quête active"
L["How the focused quest is highlighted."]                              = "Règle la surbrillance de la quête active."
L["Show quest item buttons"]                                            = "Afficher les boutons d'objet de quête"
L["Show usable quest item button next to each quest."]                  = "Affiche le bouton d'objet utilisable à côté de chaque quête."
L["Tooltips on hover"]                                                  = "Infobulles au survol"
L["Show tooltips when hovering over tracker entries, item buttons, and scenario blocks."]= "Afficher les infobulles au survol des éléments du panneau d'objectifs, des boutons d'objets, et des blocs de scénarios."
L["Show WoWhead link in tooltips"]                                      = "Afficher le lien WoWhead dans les infobulles"
L["When a tooltip is shown, add a link to open the quest, achievement, or NPC on WoWhead."]= "Quand l'infobulle est affichée, ajoute un lien vers la page WoWhead de la quête, du haut fait, ou du PNJ."
L["View on WoWhead"]                                                    = "View on WoWhead"
L["Copy link"]                                                          = "Copy link"
L["Copy the URL below (Ctrl+C) and paste in your browser."]             = "Copy the URL below (Ctrl+C) and paste in your browser."
L["Show objective numbers"]                                             = "Afficher les numéros d'objectifs"
L["Objective prefix"]                                                   = "Préfixe d'objectif"
L["Prefix each objective with a number or hyphen."]                     = "Ajoute un chiffre ou un tiret devant chaque objectif."
L["Numbers (1. 2. 3.)"]                                                 = "Chiffres (1. 2. 3.)"
L["Hyphens (-)"]                                                        = "Tirets (-)"
L["After section header"]                                               = "Après l'en-tête de section"
L["Before section header"]                                              = "Avant l'en-tête de section"
L["Below header"]                                                       = "Sous l'en-tête header"
L["Inline below title"]                                                 = "A la ligne sous le titre"
L["Prefix objectives with 1., 2., 3."]                                  = "Préfixe les objectifs avec 1., 2., 3."
L["Show completed count"]                                               = "Afficher le compteur d'objectifs complétés"
L["Show X/Y progress in quest title."]                                  = "Affiche la progression X/Y dans les titres de quête."
L["Show objective progress bar"]                                        = "Afficher la barre de progression"
L["Show a progress bar under objectives that have numeric progress (e.g. 3/250). Only applies to entries with a single arithmetic objective where the required amount is greater than 1."]= "Affiche une barre de progression sous les objectifs ayant une progression numérique (ex. 3/250). S'applique uniquement aux entrées avec un seul objectif arithmétique dont le montant requis est supérieur à 1."
L["Use category color for progress bar"]                                = "Utiliser la couleur de catégorie pour la barre"
L["When on, the progress bar matches the quest/achievement category color. When off, uses the custom fill color below."]= "Quand activé : la barre de progression utilise la couleur de la catégorie (quête, haut fait). Quand désactivé : utilise la couleur personnalisée ci-dessous."
L["Progress bar texture"]                                               = "Texture de la barre de progression"
L["Progress bar types"]                                                 = "Types de barre de progression"
L["Texture for the progress bar fill."]                                 = "Texture de remplissage de la barre."
L["Texture for the progress bar fill. Solid uses your chosen colors. SharedMedia addons add more options."]= "Texture de remplissage. Solide utilise vos couleurs. Les addons SharedMedia ajoutent d'autres options."
L["Show progress bar for X/Y objectives, percent-only objectives, or both."]= "Afficher la barre pour les objectifs X/Y, les objectifs en pourcentage uniquement, ou les deux."
L["X/Y: objectives like 3/10. Percent: objectives like 45%."]           = "X/Y : objectifs comme 3/10. Pourcent : objectifs comme 45 %."
L["X/Y only"]                                                           = "X/Y uniquement"
L["Percent only"]                                                       = "Pourcentage uniquement"
L["Use tick for completed objectives"]                                  = "Utiliser une Coche pour les objectifs terminés"
L["When on, completed objectives show a checkmark (✓) instead of green color."]= "Quand Activé : les objectifs terminés affichent une coche (✓) au lieu de la couleur verte."
L["Show entry numbers"]                                                 = "Afficher la numérotation des quêtes"
L["Prefix quest titles with 1., 2., 3. within each category."]          = "Préfixe les titres de quêtes avec 1., 2., 3. dans chaque catégorie."
L["Completed objectives"]                                               = "Objectifs terminés"
L["For multi-objective quests, how to display objectives you've completed (e.g. 1/1)."]= "Règle l'affichage des objectifs terminés quand il y en a plusieurs (ex. 1/1)."
L["Show all"]                                                           = "Tout afficher"
L["Fade completed"]                                                     = "Estomper les objectifs terminés"
L["Hide completed"]                                                     = "Masquer les objectifs terminés"
L["Show icon for in-zone auto-tracking"]                                = "Afficher l'icône de suivi automatique en zone"
L["Display an icon next to auto-tracked world quests and weeklies/dailies that are not yet in your quest log (in-zone only)."]= "Affiche une icône à côté des expéditions et hebdomadaires/quotidiennes suivies automatiquement qui ne sont pas encore dans votre journal de quêtes (zone uniquement)."
L["Auto-track icon"]                                                    = "Icône de suivi automatique"
L["Choose which icon to display next to auto-tracked in-zone entries."] = "Choisissez l'icône affichée à côté des entrées suivies automatiquement en zone."
L["Append ** to world quests and weeklies/dailies that are not yet in your quest log (in-zone only)."]= "Ajoute ** aux expéditions et hebdomadaires/journalières non encore dans le journal de quêtes (de la zone actuelle uniquement)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["Compact mode"]                                                       = "Mode compact"
L["Preset: sets entry and objective spacing to 4 and 1 px."]            = "Préréglage : espacement des quêtes et objectifs à 4 et 1 px."
L["Spacing preset"]                                                     = "Préréglage d'espacement"
L["Preset for entry and objective spacing: Default (8/2 px), Compact (4/1 px), Spaced (12/3 px), or Custom (use sliders)."]= "Préréglages : Par défaut (8/2 px), Compact (4/1 px), Espacée (12/3 px) ou Personnalisé (utilise les curseurs)."
L["Compact version"]                                                    = "Version compacte"
L["Spaced version"]                                                     = "Version espacée"
L["Spacing between quest entries (px)"]                                 = "Espace entre les quêtes (px)"
L["Vertical gap between quest entries."]                                = "Espace vertical entre les différentes quêtes."
L["Spacing before category header (px)"]                                = "Espace avant l'en-tête (px)"
L["Gap between last entry of a group and the next category label."]     = "Espace entre la dernière entrée d'un groupe et la catégorie suivante."
L["Spacing after category header (px)"]                                 = "Espace après l'en-tête (px)"
L["Gap between category label and first quest entry below it."]         = "Espace entre le libellé et la première entrée de quête en dessous."
L["Spacing between objectives (px)"]                                    = "Espace entre les objectifs (px)"
L["Vertical gap between objective lines within a quest."]               = "Espace entre les lignes d'objectifs dans une quête."
L["Title to content"]                                                   = "Titre vers contenu"
L["Vertical gap between quest title and objectives or zone below it."]  = "Espace vertical entre le titre de quête et les objectifs ou zone en dessous."
L["Spacing below header (px)"]                                          = "Espace sous l'en-tête (px)"
L["Vertical gap between the objectives bar and the quest list."]        = "Espace entre la barre d'objectifs et la liste de quêtes."
L["Reset spacing"]                                                      = "Réinitialiser les espaces"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["Show quest level"]                                                   = "Afficher le niveau de quête"
L["Show quest level next to title."]                                    = "Affiche le niveau de quête à côté du titre."
L["Dim non-focused quests"]                                             = "Estomper les quêtes non actives"
L["Slightly dim title, zone, objectives, and section headers that are not focused."]= "Estompe légèrement les titres, zones, objectifs et en-têtes non actifs."
L["Dim unfocused entries"]                                              = "Estomper les éléments non mis en avant"
L["Click a section header to expand that category."]                    = "Cliquer sur un en-tête de section pour agrandir la catégorie."

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["Show rare bosses"]                                                   = "Afficher les boss rares"
L["Show rare boss vignettes in the list."]                              = "Affiche les boss rares dans la liste."
L["Rare Loot"]                                                          = "Butin rare"
L["Show treasure and item vignettes in the Rare Loot list."]            = "Affiche les trésors et objets dans la liste de butin rare."
L["Rare sound volume"]                                                  = "Volume du son de butin rare"
L["Volume of the rare alert sound (50–200%)."]                          = "Volume du son d'alerte de butin rare (50–200%)."
L["Boost or reduce the rare alert volume. 100% = normal; 150% = louder."]= "Augmente ou réduit le volume. 100% = normal ; 150% = plus fort."
L["Rare added sound"]                                                   = "Son d'ajout de rare"
L["Play a sound when a rare is added."]                                 = "Joue un son quand un rare est ajouté."

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["Show in-zone world quests"]                                          = "Afficher les expéditions de la zone"
L["Auto-add world quests in your current zone. When off, only quests you've tracked or world quests you're in close proximity to appear (Blizzard default)."]= "Ajoute automatiquement les expéditions de votre zone. Quand Désactivé : seules les quêtes suivies ou proches sont affichées (réglage par défaut Blizzard)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["Show floating quest item"]                                           = "Afficher l'objet de quête flottant"
L["Show quick-use button for the focused quest's usable item."]         = "Affiche le bouton d'utilisation rapide de l'objet de la quête active."
L["Lock floating quest item position"]                                  = "Verrouiller la position de l'objet flottant"
L["Prevent dragging the floating quest item button."]                   = "Empêche de déplacer le bouton d'objet de quête flottant."
L["Floating quest item source"]                                         = "Source de l'objet flottant"
L["Which quest's item to show: super-tracked first, or current zone first."]= "Quel objet afficher : Quête Suivie en priorité ou Zone Actuelle en priorité."
L["Super-tracked, then first"]                                          = "Quête Suivie en priorité"
L["Current zone first"]                                                 = "Zone Actuelle en priorité"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["Show Mythic+ block"]                                                 = "Afficher le bloc Mythique+"
L["Show timer, completion %, and affixes in Mythic+ dungeons."]         = "Affiche le timer, le % de complétion et les affixes en Mythique+."
L["M+ block position"]                                                  = "Position du bloc M+"
L["Position of the Mythic+ block relative to the quest list."]          = "Position du bloc Mythique+ par rapport à la liste de quêtes."
L["Show affix icons"]                                                   = "Afficher les icônes des affixes"
L["Show affix icons next to modifier names in the M+ block."]           = "Affiche les icônes des affixes à côté des noms dans le bloc M+."
L["Show affix descriptions in tooltip"]                                 = "Descriptions des affixes dans l'infobulle"
L["Show affix descriptions when hovering over the M+ block."]           = "Affiche les descriptions des affixes au survol du bloc M+."
L["M+ completed boss display"]                                          = "Affichage des boss M+ terminés"
L["How to show defeated bosses: checkmark icon or green color."]        = "Affichage des boss vaincus : icône coche ou couleur verte."
L["Checkmark"]                                                          = "Coche"
L["Green color"]                                                        = "Couleur Verte"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["Show achievements"]                                                  = "Afficher les hauts faits"
L["Show tracked achievements in the list."]                             = "Affiche les hauts faits suivis dans la liste."
L["Show completed achievements"]                                        = "Afficher les hauts faits terminés"
L["Include completed achievements in the tracker. When off, only in-progress tracked achievements are shown."]= "Inclut les hauts faits terminés. Quand Désactivé : seuls les hauts faits en cours sont affichés."
L["Show achievement icons"]                                             = "Afficher les icônes de hauts faits"
L["Show each achievement's icon next to the title. Requires 'Show quest type icons' in Display."]= "Affiche l'icône de chaque haut fait à côté du titre. Nécessite « Afficher les icônes de type de quête » dans Affichage."
L["Only show missing requirements"]                                     = "Afficher uniquement les objectifs manquants"
L["Show only criteria you haven't completed for each tracked achievement. When off, all criteria are shown."]= "Affiche uniquement les critères non terminés pour chaque haut fait suivi. Quand Désactivé : tous les critères sont affichés."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["Show endeavors"]                                                     = "Afficher les Initiatives"
L["Show tracked Endeavors (Player Housing) in the list."]               = "Affiche les Initiatives suivies (logement) dans la liste."
L["Show completed endeavors"]                                           = "Afficher les Initiatives terminées"
L["Include completed Endeavors in the tracker. When off, only in-progress tracked Endeavors are shown."]= "Inclut les Initiatives terminées. Quand Désactivé : seuls les Initiatives en cours sont affichées."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["Show decor"]                                                         = "Afficher les décorations"
L["Show tracked housing decor in the list."]                            = "Affiche les décorations de Logis suivies dans la liste."
L["Show decor icons"]                                                   = "Afficher les icônes de décorations"
L["Show each decor item's icon next to the title. Requires 'Show quest type icons' in Display."]= "Affiche l'icône de chaque décoration à côté du titre. Nécessite « Afficher les icônes de type de quête » dans Affichage."

-- =====================================================================
-- OptionsData.lua Features — Adventure Guide
-- =====================================================================
L["Adventure Guide"]                                                    = "Guide d'aventure"
L["Show Traveler's Log"]                                                = "Afficher le Journal du voyageur"
L["Show tracked Traveler's Log objectives (Shift+click in Adventure Guide) in the list."]= "Affiche les objectifs suivis du Journal du voyageur (Maj+clic dans le Guide d'aventure) dans la liste."
L["Auto-remove completed activities"]                                   = "Retirer automatiquement les activités terminées"
L["Automatically stop tracking Traveler's Log activities once they have been completed."]= "Arrête automatiquement le suivi des activités du Journal du voyageur une fois terminées."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["Show scenario events"]                                               = "Afficher les événements de scénario"
L["Show active scenario and Delve activities. Delves appear in DELVES; other scenarios in SCENARIO EVENTS."]= "Affiche les Scénarios et les Gouffres actifs. Les Gouffres s'affichent dans GOUFFRES ; les autres dans SCÉNARIO."
L["Track Delve, Dungeon, and scenario activities."]                     = "Suivre les activités de Gouffres, Donjons et scénarios."
L["Delves appear in Delves section; dungeons in Dungeon; other scenarios in Scenario Events."]= "Les Gouffres dans GOUFFRES ; les donjons dans DONJON ; les autres dans SCÉNARIO."
L["Delves appear in Delves section; other scenarios in Scenario Events."]= "Les Gouffres apparaissent dans la section Gouffres; les autres scenarios dans la section Scenario."
L["Delve affix names"]                                                  = "Noms des affixes du Gouffre"
L["Delve/Dungeon only"]                                                 = "Gouffre/Donjon seulement"
L["Scenario debug logging"]                                             = "Rapport de debug des scenario"
L["Log scenario API data to chat. Use /h debug focus scendebug to toggle."]= "Fait le rapport de l'API des scenario dans le chat. Tapper /h debug focus scendebug pour activer."
L["Prints C_ScenarioInfo criteria and widget data when in a scenario. Helps diagnose display issues like Abundance 46/300."]= "Affiche les critères de C_ScenarioInfo et les données de widget au cours d'un scenario. Cela aide le diagnostique des erreurs d'affichage comme Abondance 46/300."
L["Hide other categories in Delve or Dungeon"]                          = "Masquer les autres catégories en Donjon ou en Gouffres"
L["In Delves or party dungeons, show only the Delve/Dungeon section."]  = "Durant un Donjon ou un Gouffre, affiche uniquement la section correspondante."
L["Use delve name as section header"]                                   = "Utiliser le nom du Gouffre comme en-tête"
L["When in a Delve, show the delve name, tier, and affixes as the section header instead of a separate banner. Disable to show the Delve block above the list."]= "Durant un Gouffre : affiche le nom, le palier et les affixes dans l'en-tête. Quand Désactivé : affiche le bloc au-dessus de la liste."
L["Show affix names in Delves"]                                         = "Afficher le nom des affixes dans les Gouffres"
L["Show season affix names on the first Delve entry. Requires Blizzard's objective tracker widgets to be populated; may not show when using a full tracker replacement."]= "Affiche les noms des affixes saisonniers sur la première ligne du Gouffre. Nécessite les widgets Blizzard ; peut ne pas s'afficher correctement."
L["Cinematic scenario bar"]                                             = "Barre cinématique de scénario"
L["Show timer and progress bar for scenario entries."]                  = "Affiche le timer et la barre de progression pour les scénarios."
L["Show timer"]                                                         = "Afficher le timer"
L["Show countdown timer on timed quests, events, and scenarios. When off, timers are hidden for all entry types."]= "Affiche le compte à rebours sur les quêtes chronométrées, événements et scénarios. Désactivé, les timers sont masqués."
L["Timer display"]                                                      = "Affichage du timer"
L["Color timer by remaining time"]                                      = "Couleur du timer selon le temps restant"
L["Green when plenty of time left, yellow when running low, red when critical."]= "Vert quand il reste du temps, jaune quand il en reste peu, rouge quand c'est critique."
L["Where to show the countdown: bar below objectives or text beside the quest name."]= "Où afficher le compte à rebours : barre sous les objectifs ou texte à côté du nom de quête."
L["Bar below"]                                                          = "Barre en dessous"
L["Inline beside title"]                                                = "Texte à côté du titre"

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["Font family."]                                                       = "Police."
L["Title font"]                                                         = "Police des titres"
L["Zone font"]                                                          = "Police de zone"
L["Objective font"]                                                     = "Police des objectifs"
L["Section font"]                                                       = "Police des sections"
L["Use global font"]                                                    = "Utiliser la police globale"
L["Font family for quest titles."]                                      = "Police des titres de quête."
L["Font family for zone labels."]                                       = "Police des libellés de zone."
L["Font family for objective text."]                                    = "Police du texte des objectifs."
L["Font family for section headers."]                                   = "Police des en-têtes de section."
L["Header size"]                                                        = "Taille de l'en-tête"
L["Header font size."]                                                  = "Taille de police de l'en-tête."
L["Title size"]                                                         = "Taille du titre"
L["Quest title font size."]                                             = "Taille de police des titres de quête."
L["Objective size"]                                                     = "Taille des objectifs"
L["Objective text font size."]                                          = "Taille de police du texte des objectifs."
L["Zone size"]                                                          = "Taille des zones"
L["Zone label font size."]                                              = "Taille de police des libellés de zone."
L["Section size"]                                                       = "Taille des sections"
L["Section header font size."]                                          = "Taille de police des en-têtes de section."
L["Progress bar font"]                                                  = "Police de la barre de progression"
L["Font family for the progress bar label."]                            = "Police du texte de la barre de progression."
L["Progress bar text size"]                                             = "Taille du texte de la barre de progression"
L["Font size for the progress bar label. Also adjusts bar height. Affects quest objectives, scenario progress, and scenario timer bars."]= "Taille de police de la barre de progression. Ajuste également la hauteur. Affecte les objectifs de quêtes, la progression des scénarios et les barres de minuteur."
L["Progress bar fill"]                                                  = "Remplissage de la barre de progression"
L["Progress bar text"]                                                  = "Texte de la barre de progression"
L["Outline"]                                                            = "Contour"
L["Font outline style."]                                                = "Style de contour de police."

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["Header text case"]                                                   = "Casse de l'en-tête"
L["Display case for header."]                                           = "Casse d'affichage pour l'en-tête."
L["Section header case"]                                                = "Casse des en-têtes de section"
L["Display case for category labels."]                                  = "Casse d'affichage des catégorie."
L["Quest title case"]                                                   = "Casse des titres de quête"
L["Display case for quest titles."]                                     = "Casse d'affichage pour les titres de quête."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["Show text shadow"]                                                   = "Afficher l'ombre du texte"
L["Enable drop shadow on text."]                                        = "Active l'ombre portée du texte."
L["Shadow X"]                                                           = "Ombre X"
L["Horizontal shadow offset."]                                          = "Décalage horizontal de l'ombre."
L["Shadow Y"]                                                           = "Ombre Y"
L["Vertical shadow offset."]                                            = "Décalage vertical de l'ombre."
L["Shadow alpha"]                                                       = "Opacité de l'ombre"
L["Shadow opacity (0–1)."]                                              = "Opacité de l'ombre (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["Mythic+ Typography"]                                                 = "Textes Mythique+"
L["Dungeon name size"]                                                  = "Taille du nom du donjon"
L["Font size for dungeon name (8–32 px)."]                              = "Taille de police du nom du donjon (8–32 px)."
L["Dungeon name color"]                                                 = "Couleur du nom du donjon"
L["Text color for dungeon name."]                                       = "Couleur du texte du nom du donjon."
L["Timer size"]                                                         = "Taille du timer"
L["Font size for timer (8–32 px)."]                                     = "Taille de police du timer (8–32 px)."
L["Timer color"]                                                        = "Couleur du timer"
L["Text color for timer (in time)."]                                    = "Couleur du timer (dans les temps)."
L["Timer overtime color"]                                               = "Couleur du timer (temps dépassé)"
L["Text color for timer when over the time limit."]                     = "Couleur du timer quand le temps est écoulé."
L["Progress size"]                                                      = "Taille de la progression"
L["Font size for enemy forces (8–32 px)."]                              = "Taille de police des forces ennemies (8–32 px)."
L["Progress color"]                                                     = "Couleur de la progression"
L["Text color for enemy forces."]                                       = "Couleur du texte des forces ennemies."
L["Bar fill color"]                                                     = "Couleur de remplissage de la barre"
L["Progress bar fill color (in progress)."]                             = "Couleur de remplissage de la barre (Clé en cours)."
L["Bar complete color"]                                                 = "Couleur de la barre de Clé terminée"
L["Progress bar fill color when enemy forces are at 100%."]             = "Couleur de remplissage quand les forces ennemies sont à 100%."
L["Affix size"]                                                         = "Taille des affixes"
L["Font size for affixes (8–32 px)."]                                   = "Taille de police des affixes (8–32 px)."
L["Affix color"]                                                        = "Couleur des affixes"
L["Text color for affixes."]                                            = "Couleur du texte des affixes."
L["Boss size"]                                                          = "Taille des noms de boss"
L["Font size for boss names (8–32 px)."]                                = "Taille de police des noms de boss (8–32 px)."
L["Boss color"]                                                         = "Couleur des noms de boss"
L["Text color for boss names."]                                         = "Couleur du texte des noms de boss."
L["Reset Mythic+ typography"]                                           = "Réinitialiser les textes M+"

-- =====================================================================
-- OptionsData.lua Appearance
-- =====================================================================
L["Frame"]                                                              = "Cadre"
L["Class colours - Dashboard"]                                          = "Couleurs de classe - Tableau de bord"
-- L["Class Colours"]                                                      = "Class Colours"  -- NEEDS TRANSLATION
-- L["Enable all class colours"]                                           = "Enable all class colours"  -- NEEDS TRANSLATION
-- L["Toggle class colours on or off for all modules at once."]            = "Toggle class colours on or off for all modules at once."  -- NEEDS TRANSLATION
-- L["Dashboard"]                                                          = "Dashboard"  -- NEEDS TRANSLATION
-- L["Tint Focus header title, category section headers, main and between-section dividers, and super-tracked highlight bars and borders with your class colour."]= "Tint Focus header title, category section headers, main and between-section dividers, and super-tracked highlight bars and borders with your class colour."  -- NEEDS TRANSLATION
-- L["Tint Presence toast title and divider with your class colour."]      = "Tint Presence toast title and divider with your class colour."  -- NEEDS TRANSLATION
-- L["Tint Vista minimap, addon-bar, and panel borders and text with your class colour."]= "Tint Vista minimap, addon-bar, and panel borders and text with your class colour."  -- NEEDS TRANSLATION
-- L["Use class colour for player tooltip name, class line, and border."]  = "Use class colour for player tooltip name, class line, and border."  -- NEEDS TRANSLATION
-- L["Tint Yield loot icon glow and edit/anchor borders with your class colour."]= "Tint Yield loot icon glow and edit/anchor borders with your class colour."  -- NEEDS TRANSLATION
-- L["Tint the character name on the Persona sheet with your class colour."]= "Tint the character name on the Persona sheet with your class colour."  -- NEEDS TRANSLATION
L["Class colors"]                                                       = "Couleurs de classe"
L["Tint dashboard accents, dividers, and highlights with your class colour."]= "Colore les éléments du Tableau de bord, des séparateurs et des surlignages avec la couleur de votre classe."
-- L["Theme"]                                                              = "Theme"  -- NEEDS TRANSLATION
-- L["Dashboard background"]                                               = "Dashboard background"  -- NEEDS TRANSLATION
-- L["Background style for the module dashboard window (Axis). Default is the standard flat dashboard background; Midnight adds soft artwork on top of the same base."]= "Background style for the module dashboard window (Axis). Default is the standard flat dashboard background; Midnight adds soft artwork on top of the same base."  -- NEEDS TRANSLATION
-- L["Dashboard background Midnight"]                                      = "Midnight"  -- NEEDS TRANSLATION
L["Backdrop opacity"]                                                   = "Opacité du fond"
L["Panel background opacity (0–1)."]                                    = "Opacité du fond du panneau (0–1)."
L["Show border"]                                                        = "Afficher la bordure"
L["Show border around the tracker."]                                    = "Affiche le cadre autour du panneau d'objectifs."
L["Show scroll indicator"]                                              = "Afficher l'indicateur de défilement"
L["Show a visual hint when the list has more content than is visible."] = "Affiche un indice visuel lorsque la liste contient plus de contenu que ce qui est visible."
L["Scroll indicator style"]                                             = "Style de l'indicateur de défilement"
L["Choose between a fade-out gradient or a small arrow to indicate scrollable content."]= "Choisissez entre un dégradé ou une petite flèche pour indiquer le contenu défilable."
L["Arrow"]                                                              = "Flèche"
L["Highlight alpha"]                                                    = "Opacité de la surbrillance"
L["Opacity of focused quest highlight (0–1)."]                          = "Opacité de la quête active (0–1)."
L["Bar width"]                                                          = "Largeur de la barre"
L["Width of bar-style highlights (2–6 px)."]                            = "Largeur de la barre de surbrillance (2–6 px)."

-- =====================================================================
-- OptionsData.lua Organization
-- =====================================================================
L["Activity"]                                                           = "Activité"
L["Content"]                                                            = "Contenu"
L["Sorting"]                                                            = "Tri"
L["Elements"]                                                           = "Éléments"
L["Category order"]                                                     = "Ordre des catégories"
L["Category color for bar"]                                             = "Couleur de la catégorie pour la barre"
L["Checkmark for completed"]                                            = "Coche pour les objectifs complétés"
L["Current Quest category"]                                             = "Catégorie Quête en Cours"
L["Current Quest window"]                                               = "Fenêtre Quête en Cours"
L["Show quests with recent progress at the top."]                       = "Afficher en haut du panneau les quêtes avec le progrès le plus récent."
L["Seconds of recent progress to show in Current Quest (30–120)."]      = "Secondes de progression récentes pour compter comme Quête en Cours (30–120)."
L["Quests you made progress on in the last minute appear in a dedicated section."]= "Les quêtes qui ont été avancées lors de la dernière minute s'affiche dans une section dédiée."
L["Focus category order"]                                               = "Ordre des catégories Focus"
L["Drag to reorder categories. DELVES and SCENARIO EVENTS stay first."] = "Glissez pour réordonner. GOUFFRES et SCÉNARIO restent en premier."
L["Drag to reorder. Delves and Scenarios stay first."]                  = "Glisser pour réordonner. Les Gouffres et les Scenario restent en premier."
L["Focus sort mode"]                                                    = "Mode de tri Focus"
L["Order of entries within each category."]                             = "Ordre des entrées dans chaque catégorie."
L["Auto-track accepted quests"]                                         = "Suivi auto des quêtes acceptées"
L["When you accept a quest (quest log only, not world quests), add it to the tracker automatically."]= "Suivi automatique des nouvelles quêtes (Sauf les expéditions)."
L["Require Ctrl for focus & remove"]                                    = "Ctrl requis pour suivre / ne plus suivre"
L["Require Ctrl for focus/add (Left) and unfocus/untrack (Right) to prevent misclicks."]= "Exige l'appui sur la touche Ctrl pour suivre (clic gauche) et ne plus suivre (clic droit) afin d'éviter les clics accidentels."
L["Ctrl for focus / untrack"]                                           = "Appui sur Ctrl pour suivre / ne plus suivre"
L["Ctrl to click-complete"]                                             = "Appui sur Ctrl pour Rendre en un clic"
L["Use classic click behaviour"]                                        = "Utiliser le comportement de clic classique"
L["Classic clicks"]                                                     = "Clics classiques"
L["Share with party"]                                                   = "Partager avec le groupe"
L["Abandon quest"]                                                      = "Abandonner la quête"
L["Stop tracking"]                                                      = "Arrêter le suivi"
L["This quest cannot be shared."]                                       = "Cette quête ne peut pas être partagée."
L["You must be in a party to share this quest."]                        = "Vous devez être en groupe pour partager cette quête."
L["When on, left-click opens the quest map and right-click shows share/abandon menu (Blizzard-style). When off, left-click focuses and right-click untracks; Ctrl+Right shares with party."]= "Activé : clic gauche ouvre la carte de quête, clic droit affiche le menu partager/abandonner (style Blizzard). Désactivé : clic gauche suit, clic droit arrête le suivi ; Ctrl+clic droit partage avec le groupe."
L["Animations"]                                                         = "Animations"
L["Enable slide and fade for quests."]                                  = "Active le glissement et le fondu pour les quêtes."
L["Objective progress flash"]                                           = "Flash de progression d'objectif"
L["Show flash when an objective completes."]                            = "Clignote quand un objectif est terminé."
L["Flash intensity"]                                                    = "Intensité du flash"
L["How noticeable the objective-complete flash is."]                    = "Intensité du flash à la complétion d'un objectif."
L["Flash color"]                                                        = "Couleur du flash"
L["Color of the objective-complete flash."]                             = "Couleur du flash à la complétion d'un objectif."
L["Subtle"]                                                             = "Subtil"
L["Medium"]                                                             = "Moyen"
L["Strong"]                                                             = "Fort"
L["Require Ctrl for click to complete"]                                 = "Ctrl requis pour cliquer et terminer"
L["When on, requires Ctrl+Left-click to complete auto-complete quests. When off, plain Left-click completes them (Blizzard default). Only affects quests that can be completed by click (no NPC turn-in needed)."]= "Quand Activé : Ctrl+clic gauche pour terminer. Quand Désactivé : un simple clic gauche (comportement Blizzard par défaut). Affecte uniquement les quêtes terminables par clic. (Sans dialogue avec un PNJ)"
L["Suppress untracked until reload"]                                    = "Masquer les quêtes non suivies jusqu'au prochain rechargement"
L["When on, right-click untrack on world quests and in-zone weeklies/dailies hides them until you reload or start a new session. When off, they reappear when you return to the zone."]= "Quand Activé : les quêtes non suivies restent masquées jusqu'au rechargement. Désactivé : elles réapparaissent à chaque retour en zone."
L["Permanently suppress untracked quests"]                              = "Masquer définitivement les quêtes non suivies"
L["When on, right-click untracked world quests and in-zone weeklies/dailies are hidden permanently (persists across reloads). Takes priority over 'Suppress until reload'. Accepting a suppressed quest removes it from the blacklist."]= "Quand Activé : les quêtes non suivies restent masquées définitivement. Prioritaire sur « Masquer jusqu'au prochain rechargement ». Accepter une quête masquée la retire de la liste noire."
L["Keep campaign quests in category"]                                   = "Garder les quêtes de campagne dans leur catégorie"
L["When on, campaign quests that are ready to turn in remain in the Campaign category instead of moving to Complete."]= "Quand Activé : les quêtes de campagne prêtes à être rendues restent dans la catégorie Campagne au lieu d'aller dans Terminées."
L["Keep important quests in category"]                                  = "Garder les quêtes importantes dans leur catégorie"
L["When on, important quests that are ready to turn in remain in the Important category instead of moving to Complete."]= "Quand Activé : les quêtes importantes prêtes à être rendues restent dans la catégorie Important au lieu d'aller dans Terminées."
L["TomTom quest waypoint"]                                              = "Point de repère TomTom"
L["Set a TomTom waypoint when focusing a quest."]                       = "Définir un point de repère TomTom en ciblant une quête."
L["Requires TomTom. Points the arrow to the next quest objective."]     = "Nécessite TomTom. Dirige la flèche vers le prochain objectif de quête."
L["TomTom rare waypoint"]                                               = "Point de repère TomTom (rare)"
L["Set a TomTom waypoint when clicking a rare boss."]                   = "Définir un point de repère TomTom en cliquant sur un boss rare."
L["Requires TomTom. Points the arrow to the rare's location."]          = "Nécessite TomTom. Dirige la flèche vers l'emplacement du boss rare."
L["Find a Group"]                                                       = "Recherche de groupe"
L["Click to search for a group for this quest."]                        = "Cliquer pour rechercher un groupe pour cette quête."

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
L["Blacklist"]                                                          = "Liste noire"
L["Blacklist untracked"]                                                = "Mettre en liste noire les quêtes arrêtées d'être suivies"
L["Enable 'Blacklist untracked' in Behaviour to add quests here."]      = "Activer 'Mettre en liste noire les quêtes arrêtées d'être suivies' dans Comportement pour ajouter des quêtes ici."
L["Hidden Quests"]                                                      = "Quêtes cachées"
L["Quests hidden via right-click untrack."]                             = "Les quêtes cachées avec le clic droit arrêtent d'être suivies."
L["Blacklisted quests"]                                                 = "Quêtes en liste noire"
L["Permanently suppressed quests"]                                      = "Quêtes supprimées définitivement"
L["Right-click untrack quests with 'Permanently suppress untracked quests' enabled to add them here."]= "Clic droit pour retirer les quêtes avec « Quêtes supprimées définitivement » activé afin de les ajouter ici."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["Show quest type icons"]                                              = "Afficher les icônes du type de quête"
L["Show quest type icon in the Focus tracker (quest accept/complete, world quest, quest update)."]= "Affiche dans le suivi : quête acceptée/terminée, expéditions, avancement de quête."
L["Show quest type icons on toasts"]                                    = "Montrer les icônes de type de quêtes sur les notifications"
L["Show quest type icon on Presence toasts (quest accept/complete, world quest, quest update)."]= "Affiche l'icône de type de quête sur les notifications : quête acceptée/terminée, expéditions, avancement de quête."
L["Toast icon size"]                                                    = "Taille des icônes sur les notifications"
L["Quest icon size on Presence toasts (16–36 px). Default 24."]         = "Taille des icônes de quête sur les notifications (16–36 px). Par défaut 24."
L["Hide quest update title"]                                            = "Masquer le titre sur les avancements de quête"
L["Show only the objective line on quest progress toasts (e.g. 7/10 Boar Pelts), without the quest name or header."]= "Affiche uniquement la ligne d'objectif (ex. 7/10 Peaux de sanglier) sans le nom de quête ni l'en-tête."
L["Show discovery line"]                                                = "Afficher la ligne de découverte"
L["Discovery line"]                                                     = "Ligne de Découverte"
L["Show 'Discovered' under zone/subzone when entering a new area."]     = "Affiche « Découverte » sous la zone/sous-zone à l'entrée d'une nouvelle zone."
L["Frame vertical position"]                                            = "Position verticale du cadre"
L["Vertical offset of the Presence frame from center (-300 to 0)."]     = "Décalage vertical depuis le centre (-300 à 0)."
L["Frame scale"]                                                        = "Échelle du cadre"
L["Scale of the Presence frame (0.5–2)."]                               = "Échelle du cadre Présence (0.5–2)."
L["Boss emote color"]                                                   = "Couleur des emotes de boss"
L["Color of raid and dungeon boss emote text."]                         = "Couleur du texte des emotes de boss en raid et donjon."
L["Discovery line color"]                                               = "Couleur de la ligne de découverte"
L["Color of the 'Discovered' line under zone text."]                    = "Couleur de la ligne « Découverte » sous le texte de zone."
L["Notification types"]                                                 = "Types de notifications"
L["Notifications"]                                                      = "Notifications"
L["Show notification when achievement criteria update (tracked achievements always; others when Blizzard provides the achievement ID)."]= "Montre une notification quand un objectif de haut fait progresse (pour tous les hauts faits suivis; et les autres lorsque Blizzard fournit l'ID du haut fait)."
L["Show zone entry"]                                                    = "Afficher l'entrée en zone"
L["Show zone change when entering a new area."]                         = "Affiche la notification lors de l'entrée dans une nouvelle zone."
L["Show subzone changes"]                                               = "Afficher les changements de sous-zone"
L["Show subzone change when moving within the same zone."]              = "Affiche la notification lors du déplacement entre sous-zones dans la même zone."
L["Hide zone name for subzone changes"]                                 = "Masquer le nom de zone pour les sous-zones"
L["When moving between subzones within the same zone, only show the subzone name. The zone name still appears when entering a new zone."]= "Lors des déplacements entre sous-zones dans la même zone, affiche uniquement le nom de la sous-zone. Le nom de la zone apparaît toujours en entrant dans une nouvelle zone."
L["Suppress in Delve"]                                                  = "Sourdine en Gouffre"
L["Suppress scenario progress notifications in Delves."]                = "Sourdine les notifications de progrès de scenario en Gouffre."
L["When on, hides objective update popups while in a Delve. Zone entry and completion toasts still show."]= "Quand activé, masque les messages de progression des objectifs dans les Gouffres. L'entrée en zone et les alertes de complétion continueront de s'afficher."
L["Suppress zone changes in Mythic+"]                                   = "Supprimer les changements de zone en Mythique+"
L["In Mythic+, only show boss emotes, achievements, and level-up. Hide zone, quest, and scenario notifications."]= "En Mythique+, affiche uniquement les emotes de boss, hauts faits et montée de niveau. Masque les notifications de zone, quête et scénario."
L["Show level up"]                                                      = "Afficher la montée de niveau"
L["Show level-up notification."]                                        = "Affiche la notification de montée de niveau."
L["Show boss emotes"]                                                   = "Afficher les emotes de boss"
L["Show raid and dungeon boss emote notifications."]                    = "Affiche les notifications d'emotes de boss en raid et donjon."
L["Show achievements"]                                                  = "Afficher les hauts faits"
L["Show achievement earned notifications."]                             = "Affiche les notifications de hauts faits obtenus."
L["Achievement progress"]                                               = "Progression des hauts faits"
L["Achievement earned"]                                                 = "Haut fait obtenu"
L["Quest accepted"]                                                     = "Quête acceptée"
L["World quest accepted"]                                               = "Expédition acceptée"
L["Scenario complete"]                                                  = "Scénario terminé"
L["Rare defeated"]                                                      = "Rare vaincu"
L["Show notification when tracked achievement criteria update."]        = "Affiche une notification lorsque les critères d'un haut fait suivi sont mis à jour."
L["Show quest accept"]                                                  = "Afficher l'acceptation de quête"
L["Show notification when accepting a quest."]                          = "Affiche la notification lors de l'acceptation d'une quête."
L["Show world quest accept"]                                            = "Afficher l'acceptation d'expédition"
L["Show notification when accepting a world quest."]                    = "Affiche la notification lors de l'acceptation d'une expédition."
L["Show quest complete"]                                                = "Afficher la complétion de quête"
L["Show notification when completing a quest."]                         = "Affiche la notification lors de la complétion d'une quête."
L["Show world quest complete"]                                          = "Afficher la complétion d'expédition"
L["Show notification when completing a world quest."]                   = "Affiche la notification lors de la complétion d'une expédition."
L["Show quest progress"]                                                = "Afficher la progression des quêtes"
L["Show notification when quest objectives update."]                    = "Affiche la notification lors de la mise à jour des objectifs."
L["Objective only"]                                                     = "Objectif uniquement"
L["Show only the objective line on quest progress toasts, hiding the 'Quest Update' title."]= "Affiche uniquement la ligne d'objectif sur les notifications de progression, en masquant le titre « Mise à jour de quête »."
L["Show scenario start"]                                                = "Afficher le début de scénario"
L["Show notification when entering a scenario or Delve."]               = "Affiche la notification à l'entrée d'un scénario ou d'un Gouffre."
L["Show scenario progress"]                                             = "Afficher la progression du scénario"
L["Show notification when scenario or Delve objectives update."]        = "Affiche la notification lors de la mise à jour des objectifs de scénario ou Gouffre."
L["Animation"]                                                          = "Animation"
L["Enable animations"]                                                  = "Activer les animations"
L["Enable entrance and exit animations for Presence notifications."]    = "Active les animations d'entrée et de sortie des notifications."
L["Entrance duration"]                                                  = "Durée d'entrée"
L["Duration of the entrance animation in seconds (0.2–1.5)."]           = "Durée de l'animation d'entrée en secondes (0.2–1.5)."
L["Exit duration"]                                                      = "Durée de sortie"
L["Duration of the exit animation in seconds (0.2–1.5)."]               = "Durée de l'animation de sortie en secondes (0.2–1.5)."
L["Hold duration scale"]                                                = "Facteur de durée d'affichage"
L["Multiplier for how long each notification stays on screen (0.5–2)."] = "Multiplicateur de la durée d'affichage des notifications (0.5–2)."
L["Preview"]                                                            = "Aperçu"
L["Preview toast type"]                                                 = "Aperçu des types d'alertes"
L["Select a toast type to preview."]                                    = "Sélectionner un type d'alerte à prévisualiser."
L["Show the selected toast type."]                                      = "Afficher le type d'alerte sélectionné."
L["Preview Presence toast layouts live and open a detachable sample while adjusting other settings."]= "Prévisualiser les mises en forme d'alertes Presence, et ouvre un échantillon détachable tout en ajustant d'autres options."
L["Open detached preview"]                                              = "Ouvrir l'aperçu détachable"
L["Open a movable preview window that stays visible while you change other Presence settings."]= "Ouvre une fenêtre d'aperçu ajustable qui reste visible pendant le réglage des autres options Presence."
L["Animate preview"]                                                    = "Animer l'aperçu"
L["Play the selected toast animation inside this preview window."]      = "Lire l'animation de l'alerte sélectionnée dans la fenêtre d'aperçu."
L["Detached preview"]                                                   = "Prévisualisation détachée"
L["Keep this open while adjusting Typography or Colors."]               = "Garder cette fenêtre ouverte en réglant les Textes et les Couleurs."
L["Typography"]                                                         = "Textes"
L["Main title font"]                                                    = "Police du titre principal"
L["Font family for the main title."]                                    = "Famille de police pour le titre principal."
L["Subtitle font"]                                                      = "Police du sous-titre"
L["Font family for the subtitle."]                                      = "Famille de police pour le sous-titre."
L["Reset typography to defaults"]                                       = "Réinitialiser les textes."
L["Reset all Presence typography options (fonts, sizes, colors) to defaults."]= "Réinitialise tous les réglages des textes Presence (polices, tailles, couleurs) à leur état par défaut."
L["Large notifications"]                                                = "Grandes notifications"
L["Medium notifications"]                                               = "Notifications moyennes"
L["Small notifications"]                                                = "Petites notifications"
L["Large primary size"]                                                 = "Taille primaire des grandes notifications"
L["Font size for large notification titles (zone, quest complete, achievement, etc.)."]= "Taille du texte des titres de grandes notifications (zones, quête terminée, haut fait, etc.)."
L["Large secondary size"]                                               = "Taille secondaire des grandes notifications"
L["Font size for large notification subtitles."]                        = "Taille de sous-titres des grandes notifications."
L["Medium primary size"]                                                = "Taille primaire des notifications moyennes"
L["Font size for medium notification titles (quest accept, subzone, scenario)."]= "Font size for medium notification titles (quest accept, subzone, scenario)."
L["Medium secondary size"]                                              = "Taille secondaire des notifications moyennes"
L["Font size for medium notification subtitles."]                       = "Taille de sous-titres des notifications moyennes."
L["Small primary size"]                                                 = "Taille primaire des petites notifications"
L["Font size for small notification titles (quest progress, achievement progress)."]= "Taille du texte des titres de petites notifications (progression des quêtes et de hauts faits)."
L["Small secondary size"]                                               = "Taille secondaire des petites notifications"
L["Font size for small notification subtitles."]                        = "Taille de sous-titres des petites notifications."

-- =====================================================================
-- OptionsData.lua Dropdown options — Outline
-- =====================================================================
L["None"]                                                               = "Aucun"
L["Thick Outline"]                                                      = "Contour épais"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["Bar (left edge)"]                                                    = "Barre (bord gauche)"
L["Bar (right edge)"]                                                   = "Barre (bord droit)"
L["Bar (top edge)"]                                                     = "Barre (bord supérieur)"
L["Bar (bottom edge)"]                                                  = "Barre (bord inférieur)"
L["Outline only"]                                                       = "Contour uniquement"
L["Soft glow"]                                                          = "Lueur douce"
L["Dual edge bars"]                                                     = "Barres doubles"
L["Pill left accent"]                                                   = "Accent pilule gauche"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["Top"]                                                                = "Haut"
L["Bottom"]                                                             = "Bas"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["Location position"]                                                  = "Position du nom de zone"
L["Place the zone name above or below the minimap."]                    = "Place le nom de zone au-dessus ou en dessous de la minicarte."
L["Coordinates position"]                                               = "Position des coordonnées"
L["Place the coordinates above or below the minimap."]                  = "Place les coordonnées au-dessus ou en dessous de la minicarte."
L["Clock position"]                                                     = "Position de l'horloge"
L["Place the clock above or below the minimap."]                        = "Place l'horloge au-dessus ou en dessous de la minicarte."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["Lower Case"]                                                         = "Minuscules"
L["Upper Case"]                                                         = "Majuscules"
L["Proper"]                                                             = "Première lettre en majuscule"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["Tracked / in log"]                                                   = "Suivies / Dans le journal"
L["In log / max slots"]                                                 = "Dans le journal / Max"

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["Alphabetical"]                                                       = "Alphabétique"
L["Quest Type"]                                                         = "Type de quête"
L["Quest Level"]                                                        = "Niveau de quête"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["Custom"]                                                             = "Personnalisé"
L["Order"]                                                              = "Ordre"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["DUNGEON"]                                                            = "DONJON"
L["RAID"]                                                               = "RAID"
L["DELVES"]                                                             = "GOUFFRES"
L["SCENARIO EVENTS"]                                                    = "SCENARIO"
L["Stage"]                                                              = "Niveau"
L["Stage %d: %s"]                                                       = "Niveau %d: %s"
L["AVAILABLE IN ZONE"]                                                  = "DISPONIBLE DANS LA ZONE"
L["EVENTS IN ZONE"]                                                     = "ÉVÈNEMENTS DANS LA ZONE"
L["CURRENT EVENT"]                                                      = "ÉVÈNEMENT EN COURS"
L["CURRENT QUEST"]                                                      = "QUÊTE EN COURS"
L["CURRENT ZONE"]                                                       = "ZONE ACTUELLE"
L["CAMPAIGN"]                                                           = "CAMPAGNE"
L["IMPORTANT"]                                                          = "IMPORTANT"
L["LEGENDARY"]                                                          = "LEGENDAIRE"
L["WORLD QUESTS"]                                                       = "EXPÉDITIONS"
L["WEEKLY QUESTS"]                                                      = "QUÊTES HEBDOMDAIRES"
L["PREY"]                                                               = "TRAQUE"
L["Abundance"]                                                          = "Abondance"
L["Abundance Bag"]                                                      = "Sac d'abondance"
L["abundance held"]                                                     = "Abondance détenue"
L["DAILY QUESTS"]                                                       = "QUÊTES JOURNALIÈRES"
L["RARE BOSSES"]                                                        = "BOSS RARES"
L["ACHIEVEMENTS"]                                                       = "HAUTS FAITS"
L["ENDEAVORS"]                                                          = "INITIATIVES"
L["DECOR"]                                                              = "DÉCORATION"
L["QUESTS"]                                                             = "QUÊTES"
L["READY TO TURN IN"]                                                   = "À RENDRE"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["OBJECTIVES"]                                                         = "OBJECTIFS"
L["Options"]                                                            = "Options"
L["Open Horizon Suite"]                                                 = "Ouvrir Horizon Suite"
L["Open the full Horizon Suite options panel to configure Focus, Presence, Vista, and other modules."]= "Ouvre le panneau d'options complet pour configurer Focus, Presence, Vista et les autres modules."
L["Show minimap icon"]                                                  = "Afficher l'icône sur la minicarte"
L["Show a clickable icon on the minimap that opens the options panel."] = "Affiche une icône cliquable sur la minicarte qui ouvre le panneau d'options."
L["Lock minimap button position"]                                       = "Verrouiller le bouton de la minicarte"
L["Prevent dragging the Horizon minimap button."]                       = "Empêche de déplacer le bouton de la minicarte Horizon."
L["Reset minimap button position"]                                      = "Réinitialiser la position du bouton de la minicarte"
L["Reset the minimap button to the default position (bottom-left)."]    = "Replace le bouton de la minimap à sa position par défaut (en bas à gauche)."
L["Drag to move (when unlocked)."]                                      = "Glisser pour déplacer (quand déverrouillé)."
L["Locked"]                                                             = "Verrouillé"
L["Discovered"]                                                         = "Découverte"
L["Refresh"]                                                            = "Actualiser"
L["Best-effort only. Some unaccepted quests are not exposed until you interact with NPCs or meet phasing conditions."]= "Recherche approximative. Certaines quêtes non acceptées ne sont pas visibles avant d'interagir avec des PNJ ou dans certaines conditions de phase."
L["Unaccepted Quests - %s (map %s) - %d match(es)"]                     = "Quêtes non acceptées - %s (carte %s) - %d correspondante(s)"

L["LEVEL UP"]                                                           = "MONTÉE DE NIVEAU"
L["You have reached level 80"]                                          = "Vous avez atteint le niveau 80"
L["You have reached level %s"]                                          = "Vous avez atteint le niveau %s"
L["ACHIEVEMENT EARNED"]                                                 = "HAUT FAIT OBTENU"
L["Exploring the Midnight Isles"]                                       = "Exploration des Îles de Midnight"
L["Exploring Khaz Algar"]                                               = "Exploration de Khaz Algar"
L["QUEST COMPLETE"]                                                     = "QUÊTE TERMINÉE"
L["Objective Secured"]                                                  = "Objectif sécurisé"
L["Aiding the Accord"]                                                  = "Aider l'Accord"
L["WORLD QUEST"]                                                        = "EXPÉDITION"
L["WORLD QUEST COMPLETE"]                                               = "EXPÉDITION TERMINÉE"
L["Azerite Mining"]                                                     = "Extraction d'azérite"
L["WORLD QUEST ACCEPTED"]                                               = "EXPÉDITION ACCEPTÉE"
L["QUEST ACCEPTED"]                                                     = "QUÊTE ACCEPTÉE"
L["The Fate of the Horde"]                                              = "Le Destin de la Horde"
L["New Quest"]                                                          = "Nouvelle quête"
L["QUEST UPDATE"]                                                       = "MISE À JOUR DE QUÊTE"
L["Boar Pelts: 7/10"]                                                   = "Peaux de sanglier : 7/10"
L["Dragon Glyphs: 3/5"]                                                 = "Glyphes de dragon : 3/5"

L["Presence test commands:"]                                            = "Commandes de test Presence :"
L["  /h presence debugtypes - Dump notification toggles and Blizzard suppression state"]= "  /h presence debugtypes - Rapporte toggle de notifications et les états de suppression Blizzard"
L["Presence: Playing demo reel (all notification types)..."]            = "Presence: Lecture de la démo (tous les types de notifications)..."
L["  /h presence         - Show help + test current zone"]              = "  /h presence         - Afficher l'aide + test de la zone actuelle"
L["  /h presence zone     - Test Zone Change"]                          = "  /h presence zone     - Test de changement de zone"
L["  /h presence subzone  - Test Subzone Change"]                       = "  /h presence subzone  - Test de changement de sous-zone"
L["  /h presence discover - Test Zone Discovery"]                       = "  /h presence discover - Test de découverte de zone"
L["  /h presence level    - Test Level Up"]                             = "  /h presence level    - Test de montée de niveau"
L["  /h presence boss     - Test Boss Emote"]                           = "  /h presence boss     - Test d'emote de boss"
L["  /h presence ach      - Test Achievement"]                          = "  /h presence ach      - Test de haut fait"
L["  /h presence accept   - Test Quest Accepted"]                       = "  /h presence accept   - Test de quête acceptée"
L["  /h presence wqaccept - Test World Quest Accepted"]                 = "  /h presence wqaccept - Test d'expédition acceptée"
L["  /h presence scenario - Test Scenario Start"]                       = "  /h presence scenario - Test de début de scénario"
L["  /h presence quest    - Test Quest Complete"]                       = "  /h presence quest    - Test de quête terminée"
L["  /h presence wq       - Test World Quest"]                          = "  /h presence wq       - Test d'expédition"
L["  /h presence update   - Test Quest Update"]                         = "  /h presence update   - Test de mise à jour de quête"
L["  /h presence achprogress - Test Achievement Progress"]              = "  /h presence achprogress - Test de progression de haut fait"
L["  /h presence all      - Demo reel (all types)"]                     = "  /h presence all      - Démo (tous les types)"
L["  /h presence debug    - Dump state to chat"]                        = "  /h presence debug    - Rapporte les états dans le chat"
L["  /h presence debuglive - Toggle live debug panel (log as events happen)"]= "  /h presence debuglive - Activer/désactiver le panneau de debug en direct (journaliser les événements)"

-- =====================================================================
-- OptionsData.lua Vista — General
L["Position & layout"]                                                  = "Position & Mise en forme"
-- =====================================================================
L["Minimap"]                                                            = "Minicarte"
L["Minimap size"]                                                       = "Taille de la minicarte"
L["Width and height of the minimap in pixels (100–400)."]               = "Largeur et hauteur de la minicarte en pixels (100–400)."
L["Circular minimap"]                                                   = "Minicarte circulaire"
L["Circular shape"]                                                     = "Forme circulaire"
L["Use a circular minimap instead of square."]                          = "Utilise une minicarte circulaire au lieu de carrée."
L["Lock minimap position"]                                              = "Verrouiller la position de la minicarte"
L["Prevent dragging the minimap."]                                      = "Empêche de déplacer la minicarte."
L["Reset minimap position"]                                             = "Réinitialiser la position de la minicarte"
L["Reset minimap to its default position (top-right)."]                 = "Réinitialise la minicarte à sa position par défaut (en haut à droite)."
L["Auto Zoom"]                                                          = "Zoom automatique"
L["Auto zoom-out delay"]                                                = "Délai de dézoom automatique"
L["Seconds after zooming before auto zoom-out fires. Set to 0 to disable."]= "Secondes après un zoom avant le dézoom automatique. Mettre à 0 pour désactiver."

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["Zone Text"]                                                          = "Texte de zone"
L["Zone font"]                                                          = "Police de zone"
L["Font for the zone name below the minimap."]                          = "Police du nom de zone sous la minicarte."
L["Zone font size"]                                                     = "Taille de la police de zone"
L["Zone text color"]                                                    = "Couleur du texte de zone"
L["Color of the zone name text."]                                       = "Couleur du texte du nom de zone."
L["Coordinates Text"]                                                   = "Texte des coordonnées"
L["Coordinates font"]                                                   = "Police des coordonnées"
L["Font for the coordinates text below the minimap."]                   = "Police du texte des coordonnées sous la minicarte."
L["Coordinates font size"]                                              = "Taille de la police des coordonnées"
L["Coordinates text color"]                                             = "Couleur du texte des coordonnées"
L["Color of the coordinates text."]                                     = "Couleur du texte des coordonnées."
L["Coordinate precision"]                                               = "Précision des coordonnées"
L["Number of decimal places shown for X and Y coordinates."]            = "Nombre de décimales affichées pour les coordonnées X et Y."
L["No decimals (e.g. 52, 37)"]                                          = "Sans décimales (ex. 52, 37)"
L["1 decimal (e.g. 52.3, 37.1)"]                                        = "1 décimale (ex. 52.3, 37.1)"
L["2 decimals (e.g. 52.34, 37.12)"]                                     = "2 décimales (ex. 52.34, 37.12)"
L["Time Text"]                                                          = "Texte de l'heure"
L["Time font"]                                                          = "Police de l'heure"
L["Font for the time text below the minimap."]                          = "Police du texte de l'heure sous la minicarte."
L["Time font size"]                                                     = "Taille de la police de l'heure"
L["Time text color"]                                                    = "Couleur du texte de l'heure"
L["Color of the time text."]                                            = "Couleur du texte de l'heure."
L["Performance Text"]                                                   = "Texte de performances"
L["Performance font"]                                                   = "Police de performances"
L["Font for the FPS and latency text below the minimap."]               = "Police d'affichage des FPS et de la latence sous la minicarte."
L["Performance font size"]                                              = "Taille de la police de performances"
L["Performance text color"]                                             = "Couleur du texte de performances"
L["Color of the FPS and latency text."]                                 = "Couleur des FPS et du texte."
L["Difficulty Text"]                                                    = "Texte de difficulté"
L["Difficulty text color (fallback)"]                                   = "Couleur du texte de difficulté (par défaut)"
L["Default color when no per-difficulty color is set."]                 = "Couleur par défaut quand aucune couleur par difficulté n'est définie."
L["Difficulty font"]                                                    = "Police de difficulté"
L["Font for the instance difficulty text."]                             = "Police du texte de difficulté d'instance."
L["Difficulty font size"]                                               = "Taille de la police de difficulté"
L["Per-Difficulty Colors"]                                              = "Couleurs par difficulté"
L["Mythic color"]                                                       = "Couleur Mythique"
L["Color for Mythic difficulty text."]                                  = "Couleur du texte de difficulté Mythique."
L["Heroic color"]                                                       = "Couleur Héroïque"
L["Color for Heroic difficulty text."]                                  = "Couleur du texte de difficulté Héroïque."
L["Normal color"]                                                       = "Couleur Normal"
L["Color for Normal difficulty text."]                                  = "Couleur du texte de difficulté Normal."
L["LFR color"]                                                          = "Couleur LFR"
L["Color for Looking For Raid difficulty text."]                        = "Couleur du texte de difficulté Raid aléatoire."

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["Text Elements"]                                                      = "Éléments de texte"
L["Show zone text"]                                                     = "Afficher le texte de zone"
L["Show the zone name below the minimap."]                              = "Affiche le nom de zone sous la minicarte."
L["Zone text display mode"]                                             = "Mode d'affichage du texte de zone"
L["What to show: zone only, subzone only, or both."]                    = "Quoi afficher : zone seulement, sous-zone seulement, ou les deux."
L["Zone only"]                                                          = "Zone seulement"
L["Subzone only"]                                                       = "Sous-zone seulement"
L["Both"]                                                               = "Les deux"
L["Show coordinates"]                                                   = "Afficher les coordonnées"
L["Show player coordinates below the minimap."]                         = "Affiche les coordonnées du joueur sous la minicarte."
L["Show time"]                                                          = "Afficher l'heure"
L["Show current game time below the minimap."]                          = "Affiche l'heure actuelle du jeu sous la minicarte."
L["24-hour clock"]                                                      = "Affichage 24h"
L["Display time in 24-hour format (e.g. 14:30 instead of 2:30 PM)."]    = "Affiche l'heure dans un format 24h (ex 14:30 au lieu de 2:30 PM)."
L["Use local time"]                                                     = "Utiliser l'heure locale"
L["When on, shows your local system time. When off, shows server time."]= "Activé : affiche l'heure locale du système. Désactivé : affiche l'heure du serveur."
L["Show FPS and latency"]                                               = "Afficher les FPS et la latence"
L["Show FPS and latency (ms) below the minimap."]                       = "Affiche les FPS et la latence (ms) sous la minicarte."
L["Minimap Buttons"]                                                    = "Boutons de minicarte"
L["Queue status and mail indicator are always shown when relevant."]    = "Le statut de file et l'indicateur de courrier sont toujours affichés si pertinents."
L["Show tracking button"]                                               = "Afficher le bouton de suivi"
L["Show the minimap tracking button."]                                  = "Affiche le bouton de suivi sur la minicarte."
L["Tracking button on mouseover only"]                                  = "Bouton de suivi au survol uniquement"
L["Hide tracking button until you hover over the minimap."]             = "Masque le bouton de suivi jusqu'au survol de la minicarte."
L["Show calendar button"]                                               = "Afficher le bouton de calendrier"
L["Show the minimap calendar button."]                                  = "Affiche le bouton de calendrier sur la minicarte."
L["Calendar button on mouseover only"]                                  = "Bouton de calendrier au survol uniquement"
L["Hide calendar button until you hover over the minimap."]             = "Masque le bouton de calendrier jusqu'au survol de la minicarte."
L["Show zoom buttons"]                                                  = "Afficher les boutons de zoom"
L["Show the + and - zoom buttons on the minimap."]                      = "Affiche les boutons de zoom + et - sur la minicarte."
L["Zoom buttons on mouseover only"]                                     = "Boutons de zoom au survol uniquement"
L["Hide zoom buttons until you hover over the minimap."]                = "Masque les boutons de zoom jusqu'au survol de la minicarte."

-- =====================================================================
-- OptionsData.lua Vista — Display (Border / Text Positions / Buttons)
-- =====================================================================
L["Border"]                                                             = "Bordure"
L["Show a border around the minimap."]                                  = "Affiche une bordure autour de la minicarte."
L["Border color"]                                                       = "Couleur de la bordure"
L["Color (and opacity) of the minimap border."]                         = "Couleur (et opacité) de la bordure de la minicarte."
L["Border thickness"]                                                   = "Épaisseur de la bordure"
L["Thickness of the minimap border in pixels (1–8)."]                   = "Épaisseur de la bordure de la minicarte en pixels (1–8)."
L["Class colours"]                                                      = "Couleurs de classe"
L["Tint Vista border and text (coords, time, FPS/MS labels) with your class colour. Numbers use the configured colour."]= "Colore les contours Vista (coordonnées, heure, affichage FPS/MS) avec la couleur de la classe. Les chiffres utilisent la couleur personnalisée."
L["Text Positions"]                                                     = "Positions du texte"
L["Drag text elements to reposition them. Lock to prevent accidental movement."]= "Glissez les éléments de texte pour les repositionner. Verrouillez pour éviter les déplacements accidentels."
L["Lock zone text position"]                                            = "Verrouiller la position du texte de zone"
L["When on, the zone text cannot be dragged."]                          = "Activé : le texte de zone ne peut pas être déplacé."
L["Lock coordinates position"]                                          = "Verrouiller la position des coordonnées"
L["When on, the coordinates text cannot be dragged."]                   = "Activé : le texte des coordonnées ne peut pas être déplacé."
L["Lock time position"]                                                 = "Verrouiller la position de l'heure"
L["When on, the time text cannot be dragged."]                          = "Activé : le texte de l'heure ne peut pas être déplacé."
L["Performance text position"]                                          = "Position du texte des performances."
L["Place the FPS/latency text above or below the minimap."]             = "Positionne le texte des FPS/latence au-dessus ou au-dessous de la minicarte."
L["Lock performance text position"]                                     = "Verrouiller la position du texte des performances."
L["When on, the FPS/latency text cannot be dragged."]                   = "Quand activé, le texte des FPS/latence ne peut plus être déplacé."
L["Lock difficulty text position"]                                      = "Verrouiller la position du texte de difficulté"
L["When on, the difficulty text cannot be dragged."]                    = "Activé : le texte de difficulté ne peut pas être déplacé."
L["Button Positions"]                                                   = "Positions des boutons"
L["Drag buttons to reposition them. Lock to prevent movement."]         = "Glissez les boutons pour les repositionner. Verrouillez pour bloquer le déplacement."
L["Lock Zoom In button"]                                                = "Verrouiller le bouton Zoom +"
L["Prevent dragging the + zoom button."]                                = "Empêche de déplacer le bouton de zoom +."
L["Lock Zoom Out button"]                                               = "Verrouiller le bouton Zoom -"
L["Prevent dragging the - zoom button."]                                = "Empêche de déplacer le bouton de zoom -."
L["Lock Tracking button"]                                               = "Verrouiller le bouton de suivi"
L["Prevent dragging the tracking button."]                              = "Empêche de déplacer le bouton de suivi."
L["Lock Calendar button"]                                               = "Verrouiller le bouton de calendrier"
L["Prevent dragging the calendar button."]                              = "Empêche de déplacer le bouton de calendrier."
L["Lock Queue button"]                                                  = "Verrouiller le bouton de la file d'attente"
L["Prevent dragging the queue status button."]                          = "Empêche de déplacer le bouton de statut de la file d'attente."
L["Lock Mail indicator"]                                                = "Verrouiller l'indicateur de courrier"
L["Prevent dragging the mail icon."]                                    = "Empêche de déplacer l'icône de courrier."
L["Disable queue handling"]                                             = "Désactiver la gestion de la file d'attente"
L["Disable queue button handling"]                                      = "Désactiver la gestion du bouton de la file d'attente"
L["Turn off all queue button anchoring (use if another addon manages it)."]= "Désactive tout ancrage du bouton de file d'attente (si un autre addon le gère)."
L["Button Sizes"]                                                       = "Tailles des boutons"
L["Adjust the size of minimap overlay buttons."]                        = "Ajuste la taille des boutons superposés à la minicarte."
L["Tracking button size"]                                               = "Taille du bouton de suivi"
L["Size of the tracking button (pixels)."]                              = "Taille du bouton de suivi (pixels)."
L["Calendar button size"]                                               = "Taille du bouton de calendrier"
L["Size of the calendar button (pixels)."]                              = "Taille du bouton de calendrier (pixels)."
L["Queue button size"]                                                  = "Taille du bouton de file"
L["Size of the queue status button (pixels)."]                          = "Taille du bouton de statut de la file d'attente (pixels)."
L["Zoom button size"]                                                   = "Taille des boutons de zoom"
L["Size of the zoom in / zoom out buttons (pixels)."]                   = "Taille des boutons zoom + / zoom - (pixels)."
L["Mail indicator size"]                                                = "Taille de l'indicateur de courrier"
L["Size of the new mail icon (pixels)."]                                = "Taille de l'icône de nouveau courrier (pixels)."
L["Addon button size"]                                                  = "Taille des boutons d'addon"
L["Size of collected addon minimap buttons (pixels)."]                  = "Taille des boutons d'addon collectés sur la minicarte (pixels)."

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
L["Addon Buttons"]                                                      = "Boutons d'addons"
L["Minimap Addon Buttons"]                                              = "Boutons d'addon sur la minicarte"
L["Button Management"]                                                  = "Gestion des boutons"
L["Manage addon minimap buttons"]                                       = "Gérer les boutons d'addon sur la minicarte"
L["When on, Vista takes control of addon minimap buttons and groups them by the selected mode."]= "Activé : Vista prend le contrôle des boutons d'addon et les regroupe selon le mode sélectionné."
L["Button mode"]                                                        = "Mode des boutons"
L["How addon buttons are presented: hover bar below minimap, panel on right-click, or floating drawer button."]= "Comment les boutons d'addon sont présentés : barre au survol, panneau au clic droit, ou tiroir flottant."
L["Always show bar"]                                                    = "Toujours montrer la barre"
L["Always show mouseover bar (for positioning)"]                        = "Toujours montrer la barre au survol (pour déplacer)"
L["Keep the mouseover bar visible at all times so you can reposition it. Disable when done."]= "Toujours garder la barre au survol visible pour permettre son déplacement. Désactiver une fois terminé."
L["Disable when done."]                                                 = "Désactiver une fois terminé."
L["Mouseover bar"]                                                      = "Barre au survol"
L["Right-click panel"]                                                  = "Panneau clic droit"
L["Floating drawer"]                                                    = "Tiroir flottant"
L["Lock drawer button position"]                                        = "Verrouiller la position du bouton tiroir"
L["Prevent dragging the floating drawer button."]                       = "Empêche de déplacer le bouton du tiroir flottant."
L["Lock mouseover bar position"]                                        = "Verrouiller la position de la barre au survol"
L["Prevent dragging the mouseover button bar."]                         = "Empêche de déplacer la barre de boutons au survol."
L["Lock right-click panel position"]                                    = "Verrouiller la position du panneau clic droit"
L["Prevent dragging the right-click panel."]                            = "Empêche de déplacer le panneau clic droit."
L["Buttons per row/column"]                                             = "Boutons par ligne/colonne"
L["Controls how many buttons appear before wrapping. For left/right direction this is columns; for up/down it is rows."]= "Contrôle le nombre de boutons avant retour à la ligne. Pour gauche/droite : colonnes ; pour haut/bas : lignes."
L["Expand direction"]                                                   = "Direction d'expansion"
L["Direction buttons fill from the anchor point. Left/Right = horizontal rows. Up/Down = vertical columns."]= "Direction de remplissage depuis le point d'ancrage. Gauche/Droite = lignes horizontales. Haut/Bas = colonnes verticales."
L["Right"]                                                              = "Droite"
L["Left"]                                                               = "Gauche"
L["Down"]                                                               = "Bas"
L["Up"]                                                                 = "Haut"
L["Mouseover Bar Appearance"]                                           = "Apparence de la barre au survol"
L["Background and border for the mouseover button bar."]                = "Fond et contour de la barre de boutons au survol."
L["Backdrop color"]                                                     = "Couleur de fond"
L["Background color of the mouseover button bar (use alpha to control transparency)."]= "Couleur de fond de la barre de boutons au survol (Utiliser l'alpha pour controler la transparence)."
L["Show bar border"]                                                    = "Afficher les contours de la barre"
L["Show a border around the mouseover button bar."]                     = "Affiche un contour autour de la barre de boutons au survol."
L["Bar border color"]                                                   = "Couleur de contour de la barre"
L["Border color of the mouseover button bar."]                          = "Couleur du contour de la barre de boutons au survol."
L["Bar background color"]                                               = "Couleur du fond de la barre"
L["Panel background color."]                                            = "Couleur du fond du panneau."
L["Close / Fade Timing"]                                                = "Timing de Fermeture / Fondu"
L["Mouseover bar — close delay (seconds)"]                              = "Barre au survol — Délai de fermeture (secondes)"
L["How long (in seconds) the bar stays visible after the cursor leaves. 0 = instant fade."]= "Combien de temps (en secondes) la barre reste visible après que le curseur ne la survole plus. 0 = fondu instantané."
L["Right-click panel — close delay (seconds)"]                          = "Clic droit sur le panneau — Délai de fermeture (secondes)"
L["How long (in seconds) the panel stays open after the cursor leaves. 0 = never auto-close (close by right-clicking again)."]= "Combien de temps (en secondes) le panneau reste ouvert après que le curseur ne la survole plus. 0 = ne ferme jamais (Fermer de nouveau avec un clic droit)."
L["Floating drawer — close delay (seconds)"]                            = "Conteneur flottant — Délai de fermeture (secondes)"
L["Drawer close delay"]                                                 = "Délai de fermeture du conteneur"
L["How long (in seconds) the drawer panel stays open after clicking away. 0 = never auto-close (close only by clicking the drawer button again)."]= "Combien de temps (en secondes) le conteneur reste ouvert après avoir cliquer ailleurs. 0 = pas de fermeture automatique (ne ferme qu'en recliquant sur le bouton de conteneur)."
L["Mail icon blink"]                                                    = "Clignotement de l'icône de courrier"
L["When on, the mail icon pulses to draw attention. When off, it stays at full opacity."]= "Quand activé, l'icône de courrier clignote pour attirer l'attention. Désactivé, il reste fixe et opaque."
L["Panel Appearance"]                                                   = "Apparence du panneau"
L["Colors for the drawer and right-click button panels."]               = "Couleurs pour le tiroir et les panneaux du clic droit."
L["Panel background color"]                                             = "Couleur de fond du panneau"
L["Background color of the addon button panels."]                       = "Couleur de fond des boutons d'addons."
L["Panel border color"]                                                 = "Couleur de contour du panneau"
L["Border color of the addon button panels."]                           = "Couleur de contour des boutons d'addons."
L["Managed buttons"]                                                    = "Boutons gérés"
L["When off, this button is completely ignored by this addon."]         = "Désactivé : ce bouton est complètement ignoré par cet addon."
L["(No addon buttons detected yet)"]                                    = "(Aucun bouton d'addon détecté)"
L["Visible buttons (check to include)"]                                 = "Boutons visibles (cocher pour inclure)"
L["(No addon buttons detected yet — open your minimap first)"]          = "(Aucun bouton d'addon détecté — ouvrez d'abord votre minicarte)"



