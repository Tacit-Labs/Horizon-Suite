if GetLocale() ~= "deDE" then return end

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = setmetatable({}, { __index = addon.L })
addon.L = L
addon.StandardFont = UNIT_NAME_FONT

-- =====================================================================
-- OptionsPanel.lua — Title
-- =====================================================================
L["HORIZON SUITE"]                                                      = "HORIZON SUITE"

-- =====================================================================
-- OptionsPanel.lua — Sidebar module group labels
-- =====================================================================
L["Focus"]                                                              = "Fokus konfigurieren"
L["Presence"]                                                           = "Benachrichtigungen konfigurieren"
L["Other"]                                                              = "Sonstiges"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["Quest types"]                                                        = "Questtypen"
L["Element overrides"]                                                  = "Elementübersteuerung"
L["Per category"]                                                       = "Pro Kategorie"
L["Grouping Overrides"]                                                 = "Gruppenübersteuerung"
-- L["Section Overrides"]                                                  = "Section Overrides"  -- NEEDS TRANSLATION
L["Other colors"]                                                       = "Weitere Farben"

-- =====================================================================
-- OptionsPanel.lua — Color row labels (collapsible group sub-rows)
-- =====================================================================
L["Section"]                                                            = "Abschnitt"
L["Title"]                                                              = "Titel"
L["Zone"]                                                               = "Zone"
L["Objective"]                                                          = "Ziel"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["Ready to Turn In overrides base colours"]                            = "Abgabereif überschreibt Basis-Farben"
L["Ready to Turn In uses its colours for quests in that section."]      = "Abgabereife Quests verwenden ihre Farben in diesem Abschnitt."
L["Current Zone overrides base colours"]                                = "Aktuelle Zone überschreibt Basis-Farben"
L["Current Zone uses its colours for quests in that section."]          = "Quests der aktuellen Zone verwenden ihre Farben in diesem Abschnitt."
L["Current Quest overrides base colours"]                               = "Aktuelle Quest überschreibt Basis-Farben"
L["Current Quest uses its colours for quests in that section."]         = "Quests der aktuellen Quest verwenden ihre Farben in diesem Abschnitt."
L["Use distinct color for completed objectives"]                        = "Abgeschlossene Ziele hervorheben"
L["When on, completed objectives (e.g. 1/1) use the color below; when off, they use the same color as incomplete objectives."]= "An: abgeschlossene Ziele (z.B. 1/1) nutzen die Farbe unten. Aus: gleiche Farbe wie unvollständige Ziele."
L["Completed objective"]                                                = "Abgeschlossenes Ziel"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["Reset"]                                                              = "Zurücksetzen"
L["Reset quest types"]                                                  = "Questtypen zurücksetzen"
L["Reset overrides"]                                                    = "Übersteuerungen zurücksetzen"
L["Reset all to defaults"]                                              = "Alle auf Standard zurücksetzen"
L["Reset to defaults"]                                                  = "Auf Standard zurücksetzen"
L["Reset to default"]                                                   = "Auf Standard zurücksetzen"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["Search settings..."]                                                 = "Einstellungen suchen..."
L["Search fonts..."]                                                    = "Schriften suchen..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["Drag to resize"]                                                     = "Ziehen zum Ändern der Größe"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
L["Profiles"]                                                           = "Profile"
L["Modules"]                                                            = "Module"
-- L["Module Toggles"]                                                     = "Module Toggles"  -- NEEDS TRANSLATION
L["Axis"]                                                               = "Axis"

-- =====================================================================
-- DashboardPanel.lua — First-run welcome
-- =====================================================================
-- L["Dashboard welcome tab"]                                              = "Welcome"  -- NEEDS TRANSLATION
-- L["Dashboard welcome title"]                                            = "Welcome to Horizon Suite"  -- NEEDS TRANSLATION
-- L["Dashboard welcome head sub"]                                         = "What each module does and where to turn them on"  -- NEEDS TRANSLATION
-- L["Dashboard welcome intro"]                                            = "Horizon Suite is modular — enable only the pieces you want. Turning a module on or off applies on reload. Expand Contributors or Localisations below for credits and supported languages. Use Open module toggles under Modules, or open Axis, then Modules, in the sidebar. You can return to this Welcome page anytime from the sidebar."  -- NEEDS TRANSLATION
-- L["Dashboard welcome path"]                                             = "%s → %s → %s"  -- NEEDS TRANSLATION
-- L["Dashboard welcome modules heading"]                                  = "Modules"  -- NEEDS TRANSLATION
-- L["Dashboard welcome contributors heading"]                             = "Contributors"  -- NEEDS TRANSLATION
-- L["Dashboard welcome contributors body"]                                = [=[Thanks to everyone who has contributed to Horizon Suite:  -- NEEDS TRANSLATION

-- L["Dashboard welcome localisations heading"]                            = "Localisations"  -- NEEDS TRANSLATION
-- L["Dashboard welcome localisations body"]                               = [=[The options panel is localised for:  -- NEEDS TRANSLATION


-- L["Dashboard welcome open module toggles link"]                         = "Open module toggles"  -- NEEDS TRANSLATION
-- L["Axis module short description"]                                      = "Core settings hub: profiles, modules, and global toggles."  -- NEEDS TRANSLATION
-- L["Objective tracker for quests, world quests, rares, achievements, scenarios."]= "Objective tracker for quests, world quests, rares, achievements, scenarios."  -- NEEDS TRANSLATION
-- L["Zone text and notifications."]                                       = "Zone text and notifications."  -- NEEDS TRANSLATION
-- L["Minimap with zone text, coords, time, and button collector."]        = "Minimap with zone text, coords, time, and button collector."  -- NEEDS TRANSLATION
-- L["Tooltips with class colors, spec, and faction icons."]               = "Tooltips with class colors, spec, and faction icons."  -- NEEDS TRANSLATION
-- L["Loot toasts for items, money, currency, reputation."]                = "Loot toasts for items, money, currency, reputation."  -- NEEDS TRANSLATION
-- L["Essence module short description"]                                   = "Custom character sheet with 3D model, item level, stats, and gear grid."  -- NEEDS TRANSLATION
-- L["Dashboard welcome community heading"]                                = "Community & Support"  -- NEEDS TRANSLATION
-- L["Discord"]                                                            = "Discord"  -- NEEDS TRANSLATION
-- L["Ko-fi"]                                                              = "Ko-fi"  -- NEEDS TRANSLATION
-- L["Patreon"]                                                            = "Patreon"  -- NEEDS TRANSLATION
-- L["GitLab"]                                                             = "GitLab"  -- NEEDS TRANSLATION
-- L["CurseForge"]                                                         = "CurseForge"  -- NEEDS TRANSLATION
-- L["Wago"]                                                               = "Wago"  -- NEEDS TRANSLATION
-- L["Copy link — %s"]                                                     = "Copy link — %s"  -- NEEDS TRANSLATION
L["Layout"]                                                             = "Layout"
L["Visibility"]                                                         = "Sichtbarkeit"
L["Display"]                                                            = "Anzeige"
L["Features"]                                                           = "Funktionen"
L["Typography"]                                                         = "Typografie"
L["Appearance"]                                                         = "Aussehen"
L["Colors"]                                                             = "Farben"
L["Organization"]                                                       = "Organisation"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["Panel behaviour"]                                                    = "Panelverhalten"
L["Dimensions"]                                                         = "Abmessungen"
L["Instance"]                                                           = "Instanz"
L["Instances"]                                                          = "Instanzen"
L["Combat"]                                                             = "Kampf"
L["Filtering"]                                                          = "Filter"
L["Header"]                                                             = "Kopfzeile"
-- L["Sections & structure"]                                               = "Sections & structure"  -- NEEDS TRANSLATION
-- L["Entry details"]                                                      = "Entry details"  -- NEEDS TRANSLATION
-- L["Progress & timers"]                                                  = "Progress & timers"  -- NEEDS TRANSLATION
-- L["Focus emphasis"]                                                     = "Focus emphasis"  -- NEEDS TRANSLATION
L["List"]                                                               = "Liste"
L["Spacing"]                                                            = "Abstände"
L["Rare bosses"]                                                        = "Rare Bosse"
L["World quests"]                                                       = "Weltquests"
L["Floating quest item"]                                                = "Schwebendes Quest-Item"
L["Mythic+"]                                                            = "Mythisch+"
L["Achievements"]                                                       = "Erfolge"
L["Endeavors"]                                                          = "Bestrebungen"
L["Decor"]                                                              = "Dekoration"
L["Scenario & Delve"]                                                   = "Szenario & Tiefe"
L["Font"]                                                               = "Schriftart"
-- L["Font families"]                                                      = "Font families"  -- NEEDS TRANSLATION
-- L["Global font size"]                                                   = "Global font size"  -- NEEDS TRANSLATION
-- L["Font sizes"]                                                         = "Font sizes"  -- NEEDS TRANSLATION
-- L["Per-element fonts"]                                                  = "Per-element fonts"  -- NEEDS TRANSLATION
L["Text case"]                                                          = "Groß-/Kleinschreibung"
L["Shadow"]                                                             = "Schatten"
L["Panel"]                                                              = "Panel"
L["Highlight"]                                                          = "Hervorhebung"
L["Color matrix"]                                                       = "Farbmatrix"
L["Focus order"]                                                        = "Fokus-Reihenfolge"
L["Sort"]                                                               = "Sortierung"
L["Behaviour"]                                                          = "Verhalten"
L["Content Types"]                                                      = "Inhaltstypen"
L["Delves"]                                                             = "Tiefen"
L["Delves & Dungeons"]                                                  = "Tiefen & Dungeons"
L["Delve Complete"]                                                     = "Tiefe abgeschlossen"
L["Interactions"]                                                       = "Interaktionen"
L["Tracking"]                                                           = "Verfolgung"
L["Scenario Bar"]                                                       = "Szenario-Leiste"

-- =====================================================================
-- OptionsData.lua Profiles
-- =====================================================================
L["Vista"]                                                              = "Vista"
L["Current profile"]                                                    = "Aktuelles Profil"
L["Select the profile currently in use."]                               = "Aktuell verwendetes Profil auswählen."
L["Use global profile (account-wide)"]                                  = "Globales Profil (accountweit) verwenden"
L["All characters use the same profile."]                               = "Alle Charaktere verwenden dasselbe Profil."
L["Enable per specialization profiles"]                                 = "Profile pro Spezialisierung aktivieren"
L["Pick different profiles per spec."]                                  = "Verschiedene Profile pro Spezialisierung wählen."
L["Specialization"]                                                     = "Spezialisierung"
L["Sharing"]                                                            = "Teilen"
L["Import profile"]                                                     = "Profil importieren"
L["Import string"]                                                      = "Import-String"
L["Export profile"]                                                     = "Profil exportieren"
L["Select a profile to export."]                                        = "Profil zum Exportieren wählen."
L["Export string"]                                                      = "Export-String"
L["Copy from profile"]                                                  = "Aus Profil kopieren"
L["Source profile for copying."]                                        = "Quellprofil zum Kopieren."
L["Copy from selected"]                                                 = "Aus Auswahl kopieren"
L["Create"]                                                             = "Erstellen"
L["Create new profile from Default template"]                           = "Neues Profil aus Standard-Vorlage erstellen"
L["Creates a new profile with all default settings."]                   = "Erstellt ein neues Profil mit allen Standardeinstellungen."
L["Creates a new profile copied from the selected source profile."]     = "Erstellt ein neues Profil als Kopie des ausgewählten Quellprofils."
L["Delete profile"]                                                     = "Profil löschen"
L["Select a profile to delete (current and Default not shown)."]        = "Profil zum Löschen wählen (aktuell und Standard nicht angezeigt)."
L["Delete selected"]                                                    = "Auswahl löschen"
L["Delete selected profile"]                                            = "Ausgewähltes Profil löschen"
L["Delete"]                                                             = "Löschen"
L["Deletes the selected profile."]                                      = "Löscht das ausgewählte Profil."
L["Global profile"]                                                     = "Globales Profil"
L["Per-spec profiles"]                                                  = "Profile pro Spezialisierung"

-- =====================================================================
-- OptionsData.lua Modules
-- =====================================================================
L["Enable Focus module"]                                                = "Fokus-Modul aktivieren"
L["Show the objective tracker for quests, world quests, rares, achievements, and scenarios."]= "Zielverfolger für Quests, Weltquests, Rare Bosse, Erfolge und Szenarien anzeigen."
L["Enable Presence module"]                                             = "Präsenz-Modul aktivieren"
L["Cinematic zone text and notifications (zone changes, level up, boss emotes, achievements, quest updates)."]= "Filmische Zonentexte und Benachrichtigungen (Zonenwechsel, Levelaufstieg, Boss-Emotes, Erfolge, Quest-Updates)."
L["Enable Cache module"]                                                = "Ertrag-Modul aktivieren"
L["Cinematic loot notifications (items, money, currency, reputation)."] = "Filmische Beute-Benachrichtigungen (Items, Gold, Währung, Ruf)."
L["Enable Vista module"]                                                = "Vista-Modul aktivieren"
L["Cinematic square minimap with zone text, coordinates, and button collector."]= "Filmische quadratische Minimap mit Zonentext, Koordinaten und Button-Sammlung."
L["Cinematic square minimap with zone text, coordinates, time, and button collector."]= "Filmische quadratische Minikarte mit Zonentext, Koordinaten, Zeit und Button-Sammlung."
L["Beta"]                                                               = "Beta"
L["Scaling"]                                                            = "Skalierung"
-- L["Global Toggles"]                                                     = "Global Toggles"  -- NEEDS TRANSLATION
-- L["Suite-wide class colour tinting and UI scale (global or per module)."]= "Dashboard background theme, class colour tinting, and UI scale (global or per module)."  -- NEEDS TRANSLATION
L["Global UI scale"]                                                    = "Globale UI-Skalierung"
L["Scale all sizes, spacings, and fonts by this factor (50–200%). Does not change your configured values."]= "Alle Größen, Abstände und Schriftarten mit diesem Faktor skalieren (50–200%). Ändert keine konfigurierten Werte."
L["Per-module scaling"]                                                 = "Skalierung pro Modul"
L["Override the global scale with individual sliders for each module."] = "Globale Skalierung durch Einzelschieber je Modul ersetzen."
L["Overrides the global scale with individual sliders for Focus, Presence, Vista, etc."]= "Globale Skalierung durch Einzelschieber für Focus, Presence, Vista usw. ersetzen."
L["Doesn't change your configured values, only the effective display scale."]= "Ändert keine konfigurierten Werte, nur die effektive Anzeige-Skalierung."
L["Focus scale"]                                                        = "Fokus-Skalierung"
L["Scale for the Focus objective tracker (50–200%)."]                   = "Skalierung des Fokus-Zielverfolgers (50–200%)."
L["Presence scale"]                                                     = "Präsenz-Skalierung"
L["Scale for the Presence cinematic text (50–200%)."]                   = "Skalierung des filmischen Präsenz-Textes (50–200%)."
L["Vista scale"]                                                        = "Vista-Skalierung"
L["Scale for the Vista minimap module (50–200%)."]                      = "Skalierung des Vista-Minimap-Moduls (50–200%)."
L["Insight scale"]                                                      = "Insight-Skalierung"
L["Scale for the Insight tooltip module (50–200%)."]                    = "Skalierung des Insight-Tooltip-Moduls (50–200%)."
L["Cache scale"]                                                        = "Ertrag-Skalierung"
L["Scale for the Cache loot toast module (50–200%)."]                   = "Skalierung des Ertrag-Beute-Toast-Moduls (50–200%)."
L["Enable Horizon Insight module"]                                      = "Horizon Insight-Modul aktivieren"
L["Cinematic tooltips with class colors, spec display, and faction icons."]= "Filmische Tooltips mit Klassenfarben, Spez-Anzeige und Fraktionssymbolen."
L["Horizon Insight"]                                                    = "Horizon Insight"
L["Insight"]                                                            = "Insight"
L["Tooltip anchor mode"]                                                = "Tooltip-Anker-Modus"
L["Where tooltips appear: follow cursor or fixed position."]            = "Wo Tooltips erscheinen: Cursor folgen oder feste Position."
L["Cursor"]                                                             = "Cursor"
L["Fixed"]                                                              = "Fest"
L["Show anchor to move"]                                                = "Anker zum Verschieben anzeigen"
-- L["Click to show or hide the anchor. Drag to set position, right-click to confirm."]= "Click to show or hide the anchor. Drag to set position, right-click to confirm."  -- NEEDS TRANSLATION
L["Show draggable frame to set fixed tooltip position. Drag, then right-click to confirm."]= "Ziehbaren Rahmen zur festen Tooltip-Position anzeigen. Ziehen, dann Rechtsklick zum Bestätigen."
L["Reset tooltip position"]                                             = "Tooltip-Position zurücksetzen"
L["Reset fixed position to default."]                                   = "Feste Position auf Standard zurücksetzen."
L["Tooltip background color"]                                           = "Tooltip-Hintergrundfarbe"
L["Color of the tooltip background."]                                   = "Farbe des Tooltip-Hintergrunds."
L["Tooltip background opacity"]                                         = "Tooltip-Hintergrunddeckkraft"
L["Tooltip background opacity (0–100%)."]                               = "Tooltip-Hintergrunddeckkraft (0–100 %)."
L["Tooltip font"]                                                       = "Tooltip-Schriftart"
L["Font family used for all tooltip text."]                             = "Schriftfamilie für den gesamten Tooltip-Text."
L["Tooltips"]                                                           = "Tooltips"
L["Item Tooltip"]                                                       = "Item-Tooltip"
L["Show transmog status"]                                               = "Transmog-Status anzeigen"
L["Show whether you have collected the appearance of an item you hover over."]= "Anzeigen ob Sie bereits die Erscheinung eines Items gesammelt haben."
L["Player Tooltip"]                                                     = "Spieler-Tooltip"
L["Show guild rank"]                                                    = "Gildenrang anzeigen"
L["Append the player's guild rank next to their guild name."]           = "Gildenrang des Spielers neben dem Gildennamen anzeigen."
L["Show Mythic+ score"]                                                 = "Mythisch+-Punkte anzeigen"
L["Show the player's current season Mythic+ score, colour-coded by tier."]= "Aktuelle Saison-Mythisch+-Punkte des Spielers, farbcodiert nach Stufe."
L["Show item level"]                                                    = "Itemlevel anzeigen"
L["Show the player's equipped item level after inspecting them."]       = "Itemlevel des Spielers nach Inspektion anzeigen."
L["Show honor level"]                                                   = "Ehren-Ebenen anzeigen"
L["Show the player's PvP honor level in the tooltip."]                  = "PvP-Ehren-Ebene des Spielers im Tooltip anzeigen."
L["Show PvP title"]                                                     = "PvP-Titel anzeigen"
L["Show the player's PvP title (e.g. Gladiator) in the tooltip."]       = "PvP-Titel des Spielers (z.B. Gladiator) im Tooltip anzeigen."
-- L["Character title"]                                                    = "Character title"  -- NEEDS TRANSLATION
-- L["Show the player's selected title (achievement or PvP) in the name line."]= "Show the player's selected title (achievement or PvP) in the name line."  -- NEEDS TRANSLATION
-- L["Title color"]                                                        = "Title color"  -- NEEDS TRANSLATION
-- L["Color of the character title in the player tooltip name line."]      = "Color of the character title in the player tooltip name line."  -- NEEDS TRANSLATION
L["Show status badges"]                                                 = "Status-Badges anzeigen"
L["Show inline badges for combat, AFK, DND, PvP flag, party/raid membership, friends, and whether the player is targeting you."]= "Inline-Badges für Kampf, AFK, DND, PvP, Schlachtzug/Gruppe, Freunde und Zielanzeige anzeigen."
L["Show mount info"]                                                    = "Reittier-Info anzeigen"
L["When hovering a mounted player, show their mount name, source, and whether you own it."]= "Bei Reittier-Spieler: Reittiername, Quelle und ob Sie es besitzen anzeigen."
-- L["Blank separator"]                                                    = "Blank separator"  -- NEEDS TRANSLATION
-- L["Use a blank line instead of dashes between tooltip sections."]       = "Use a blank line instead of dashes between tooltip sections."  -- NEEDS TRANSLATION
-- L["Show icons"]                                                         = "Show icons"  -- NEEDS TRANSLATION
-- L["Class icon style"]                                                   = "Class icon style"  -- NEEDS TRANSLATION
-- L["Use Default (Blizzard) or RondoMedia class icons on the class/spec line."]= "Use Default (Blizzard) or RondoMedia class icons on the class/spec line."  -- NEEDS TRANSLATION
-- L["RondoMedia class icons by RondoFerrari — https://www.curseforge.com/wow/addons/rondomedia"]= "RondoMedia class icons by RondoFerrari — https://www.curseforge.com/wow/addons/rondomedia"  -- NEEDS TRANSLATION
-- L["Default"]                                                            = "Default"  -- NEEDS TRANSLATION
-- L["Show faction, spec, mount, and Mythic+ icons in tooltips."]          = "Show faction, spec, mount, and Mythic+ icons in tooltips."  -- NEEDS TRANSLATION
L["Cache"]                                                              = "Ertrag"
L["General"]                                                            = "Allgemein"
L["Position"]                                                           = "Position"
L["Reset position"]                                                     = "Position zurücksetzen"
L["Reset loot toast position to default."]                              = "Beute-Toast-Position auf Standard zurücksetzen."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["Lock position"]                                                      = "Position sperren"
L["Prevent dragging the tracker."]                                      = "Verschieben des Zielverfolgers verhindern."
L["Grow upward"]                                                        = "Nach oben wachsen"
L["Grow-up header"]                                                     = "Aufwärts-Header"
L["When growing upward: keep header at bottom, or at top until collapsed."]= "Beim Aufwärtswachsen: Header unten lassen oder oben bis zum Einklappen."
L["Header at bottom"]                                                   = "Header unten"
L["Header slides on collapse"]                                          = "Header gleitet beim Einklappen"
L["Anchor at bottom so the list grows upward."]                         = "Unten verankern, damit die Liste nach oben wächst."
L["Start collapsed"]                                                    = "Eingeklappt starten"
L["Start with only the header shown until you expand."]                 = "Nur mit Kopfzeile starten bis zum Aufklappen."
L["Align content right"]                                                = "Inhalt rechts ausrichten"
L["Right-align quest titles and objectives within the panel."]          = "Questtitel und Ziele im Panel rechts ausrichten."
L["Panel width"]                                                        = "Panel-Breite"
L["Tracker width in pixels."]                                           = "Breite des Zielverfolgers in Pixeln."
L["Max content height"]                                                 = "Max. Inhaltshöhe"
L["Max height of the scrollable list (pixels)."]                        = "Maximale Höhe der scrollbaren Liste (Pixel)."

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["Always show M+ block"]                                               = "M+-Block immer anzeigen"
L["Show the M+ block whenever an active keystone is running"]           = "M+-Block anzeigen wenn aktiver Schlüsselstein läuft"
L["Show in dungeon"]                                                    = "In Dungeon anzeigen"
L["Show tracker in party dungeons."]                                    = "Zielverfolger in Gruppen-Dungeons anzeigen."
L["Show in raid"]                                                       = "In Schlachtzug anzeigen"
L["Show tracker in raids."]                                             = "Zielverfolger in Schlachtzügen anzeigen."
L["Show in battleground"]                                               = "In Schlachtfeld anzeigen"
L["Show tracker in battlegrounds."]                                     = "Zielverfolger in Schlachtfeldern anzeigen."
L["Show in arena"]                                                      = "In Arena anzeigen"
L["Show tracker in arenas."]                                            = "Zielverfolger in Arenen anzeigen."
L["Hide in combat"]                                                     = "Im Kampf verbergen"
L["Hide tracker and floating quest item in combat."]                    = "Zielverfolger und schwebendes Quest-Item im Kampf verbergen."
L["Combat visibility"]                                                  = "Kampf-Sichtbarkeit"
L["How the tracker behaves in combat: show, fade to reduced opacity, or hide."]= "Verhalten des Zielverfolgers im Kampf: anzeigen, abdunkeln oder verbergen."
L["Show"]                                                               = "Anzeigen"
L["Fade"]                                                               = "Verblassen"
L["Hide"]                                                               = "Verbergen"
L["Combat fade opacity"]                                                = "Kampf-Ausblend-Deckkraft"
L["How visible the tracker is when faded in combat (0 = invisible). Only applies when Combat visibility is Fade."]= "Sichtbarkeit ausgeblendet im Kampf (0 = unsichtbar). Nur bei Kampf-Sichtbarkeit „Ausblenden\"."
L["Mouseover"]                                                          = "Mausüber"
L["Show only on mouseover"]                                             = "Nur bei Mausüber anzeigen"
L["Fade tracker when not hovering; move mouse over it to show."]        = "Zielverfolger ausblenden wenn nicht darüber; Maus darüber für Anzeige."
L["Faded opacity"]                                                      = "Ausgeblendete Deckkraft"
L["How visible the tracker is when faded (0 = invisible)."]             = "Sichtbarkeit des Zielverfolgers ausgeblendet (0 = unsichtbar)."
L["Only show quests in current zone"]                                   = "Nur Quests in aktueller Zone anzeigen"
L["Hide quests outside your current zone."]                             = "Quests außerhalb Ihrer Zone verbergen."

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["Show quest count"]                                                   = "Quest-Anzahl anzeigen"
L["Show quest count in header."]                                        = "Quest-Anzahl in Kopfzeile anzeigen."
L["Header count format"]                                                = "Kopfzeilen-Zählformat"
L["Tracked/in-log or in-log/max-slots. Tracked excludes world/live-in-zone quests."]= "Verfolgt/im-Log oder im-Log/max-Plätze. Verfolgt schließt Welt-/Zonen-Quests aus."
L["Show header divider"]                                                = "Kopfzeilen-Trennlinie anzeigen"
L["Show the line below the header."]                                    = "Linie unter der Kopfzeile anzeigen."
L["Header divider color"]                                               = "Kopfzeilen-Trennlinien-Farbe"
L["Color of the line below the header."]                                = "Farbe der Linie unter der Kopfzeile."
L["Super-minimal mode"]                                                 = "Super-Minimal-Modus"
L["Hide header for a pure text list."]                                  = "Kopfzeile für reine Textliste verbergen."
L["Show options button"]                                                = "Optionen-Button anzeigen"
L["Show the Options button in the tracker header."]                     = "Optionen-Button in der Zielverfolger-Kopfzeile anzeigen."
L["Header color"]                                                       = "Kopfzeilen-Farbe"
L["Color of the OBJECTIVES header text."]                               = "Farbe des ZIELE-Header-Texts."
L["Header height"]                                                      = "Kopfzeilen-Höhe"
L["Height of the header bar in pixels (18–48)."]                        = "Höhe der Kopfzeilen-Leiste in Pixeln (18–48)."

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["Show section headers"]                                               = "Abschnitts-Header anzeigen"
L["Show category labels above each group."]                             = "Kategorie-Labels über jeder Gruppe anzeigen."
L["Show category headers when collapsed"]                               = "Kategorie-Header eingeklappt anzeigen"
L["Keep section headers visible when collapsed; click to expand a category."]= "Abschnittsüberschriften eingeklappt sichtbar lassen; klicken zum Erweitern."
L["Show Nearby (Current Zone) group"]                                   = "Nah (Aktuelle Zone) Gruppe anzeigen"
L["Show in-zone quests in a dedicated Current Zone section. When off, they appear in their normal category."]= "Zonen-Quests in eigenem Aktuelle-Zone-Abschnitt. Aus: normale Kategorie."
L["Show zone labels"]                                                   = "Zonen-Labels anzeigen"
L["Show zone name under each quest title."]                             = "Zonennamen unter jedem Quest-Titel anzeigen."
L["Active quest highlight"]                                             = "Aktive Quest hervorheben"
L["How the focused quest is highlighted."]                              = "Wie die fokussierte Quest hervorgehoben wird."
L["Show quest item buttons"]                                            = "Quest-Item-Buttons anzeigen"
L["Show usable quest item button next to each quest."]                  = "Nutzbares Quest-Item-Button neben jeder Quest anzeigen."
-- L["Tooltips on hover"]                                                  = "Tooltips on hover"  -- NEEDS TRANSLATION
-- L["Show tooltips when hovering over tracker entries, item buttons, and scenario blocks."]= "Show tooltips when hovering over tracker entries, item buttons, and scenario blocks."  -- NEEDS TRANSLATION
-- L["Show WoWhead link in tooltips"]                                      = "Show WoWhead link in tooltips"  -- NEEDS TRANSLATION
-- L["When a tooltip is shown, add a link to open the quest, achievement, or NPC on WoWhead."]= "When a tooltip is shown, add a link to open the quest, achievement, or NPC on WoWhead."  -- NEEDS TRANSLATION
-- L["View on WoWhead"]                                                    = "View on WoWhead"  -- NEEDS TRANSLATION
-- L["Copy link"]                                                          = "Copy link"  -- NEEDS TRANSLATION
-- L["Copy the URL below (Ctrl+C) and paste in your browser."]             = "Copy the URL below (Ctrl+C) and paste in your browser."  -- NEEDS TRANSLATION
L["Show objective numbers"]                                             = "Zielnummern anzeigen"
L["Objective prefix"]                                                   = "Ziel-Präfix"
L["Prefix each objective with a number or hyphen."]                     = "Jedes Ziel mit Nummer oder Bindestrich versehen."
L["Numbers (1. 2. 3.)"]                                                 = "Zahlen (1. 2. 3.)"
L["Hyphens (-)"]                                                        = "Bindestriche (-)"
L["After section header"]                                               = "Nach Abschnittsüberschrift"
L["Before section header"]                                              = "Vor Abschnittsüberschrift"
L["Below header"]                                                       = "Unter Kopfzeile"
L["Inline below title"]                                                 = "Inline unter Titel"
L["Prefix objectives with 1., 2., 3."]                                  = "Ziele mit 1., 2., 3. versehen."
L["Show completed count"]                                               = "Abgeschlossene-Anzahl anzeigen"
L["Show X/Y progress in quest title."]                                  = "X/Y-Fortschritt im Quest-Titel anzeigen."
L["Show objective progress bar"]                                        = "Ziel-Fortschrittsbalken anzeigen"
L["Show a progress bar under objectives that have numeric progress (e.g. 3/250). Only applies to entries with a single arithmetic objective where the required amount is greater than 1."]= "Fortschrittsbalken unter Zielen mit numerischem Fortschritt (z.B. 3/250). Nur bei Einträgen mit einem arithmetischen Ziel > 1."
L["Use category color for progress bar"]                                = "Kategoriefarbe für Fortschrittsbalken verwenden"
L["When on, the progress bar matches the quest/achievement category color. When off, uses the custom fill color below."]= "An: Fortschrittsbalken nutzt Kategoriefarbe. Aus: benutzerdefinierte Füllfarbe unten."
L["Progress bar texture"]                                               = "Fortschrittsbalken-Textur"
L["Progress bar types"]                                                 = "Fortschrittsbalken-Typen"
L["Texture for the progress bar fill."]                                 = "Textur für die Fortschrittsbalken-Füllung."
L["Texture for the progress bar fill. Solid uses your chosen colors. SharedMedia addons add more options."]= "Textur für Fortschrittsbalken-Füllung. Solid nutzt Ihre Farben. SharedMedia-Addons bieten mehr Optionen."
L["Show progress bar for X/Y objectives, percent-only objectives, or both."]= "Fortschrittsleiste für X/Y-Ziele, nur-Prozent-Ziele oder beides anzeigen."
L["X/Y: objectives like 3/10. Percent: objectives like 45%."]           = "X/Y: Ziele wie 3/10. Prozent: Ziele wie 45%."
L["X/Y only"]                                                           = "Nur X/Y"
L["Percent only"]                                                       = "Nur Prozent"
L["Use tick for completed objectives"]                                  = "Häkchen für abgeschlossene Ziele verwenden"
L["When on, completed objectives show a checkmark (✓) instead of green color."]= "An: abgeschlossene Ziele zeigen Häkchen (✓) statt grüner Farbe."
L["Show entry numbers"]                                                 = "Eintragsnummern anzeigen"
L["Prefix quest titles with 1., 2., 3. within each category."]          = "Quest-Titel mit 1., 2., 3. versehen."
L["Completed objectives"]                                               = "Abgeschlossene Ziele"
L["For multi-objective quests, how to display objectives you've completed (e.g. 1/1)."]= "Für Multi-Ziel-Quests: Darstellung abgeschlossener Ziele (z.B. 1/1)."
L["Show all"]                                                           = "Alle anzeigen"
L["Fade completed"]                                                     = "Abgeschlossene ausblenden"
L["Hide completed"]                                                     = "Abgeschlossene verbergen"
L["Show icon for in-zone auto-tracking"]                                = "Symbol für automatische Zonen-Verfolgung anzeigen"
L["Display an icon next to auto-tracked world quests and weeklies/dailies that are not yet in your quest log (in-zone only)."]= "Symbol bei automatisch verfolgten Weltquests und Wochen-/Tagesquests anzeigen, die noch nicht im Questlog sind (nur in Zone)."
L["Auto-track icon"]                                                    = "Auto-Track-Symbol"
L["Choose which icon to display next to auto-tracked in-zone entries."] = "Symbol für automatisch verfolgte Zoneneinträge wählen."
L["Append ** to world quests and weeklies/dailies that are not yet in your quest log (in-zone only)."]= "** an Weltquests und Wochen-/Tagesquests anhängen, die noch nicht im Questlog sind (nur in Zone)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["Compact mode"]                                                       = "Kompaktmodus"
L["Preset: sets entry and objective spacing to 4 and 1 px."]            = "Voreinstellung: Eintrags- und Zielabstand auf 4 und 1 px."
L["Spacing preset"]                                                     = "Abstands-Voreinstellung"
L["Preset for entry and objective spacing: Default (8/2 px), Compact (4/1 px), Spaced (12/3 px), or Custom (use sliders)."]= "Voreinstellung: Standard (8/2 px), Kompakt (4/1 px), Abstand (12/3 px) oder Benutzerdefiniert (Slider)."
L["Compact version"]                                                    = "Kompakte Version"
L["Spaced version"]                                                     = "Abstands-Version"
L["Spacing between quest entries (px)"]                                 = "Abstand zwischen Quest-Einträgen (px)"
L["Vertical gap between quest entries."]                                = "Vertikaler Abstand zwischen Quest-Einträgen."
L["Spacing before category header (px)"]                                = "Abstand vor Kategorie-Header (px)"
L["Gap between last entry of a group and the next category label."]     = "Abstand zwischen letztem Eintrag einer Gruppe und dem nächsten Kategorie-Label."
L["Spacing after category header (px)"]                                 = "Abstand nach Kategorie-Header (px)"
L["Gap between category label and first quest entry below it."]         = "Abstand zwischen Kategorie-Label und erstem Quest-Eintrag darunter."
L["Spacing between objectives (px)"]                                    = "Abstand zwischen Zielen (px)"
L["Vertical gap between objective lines within a quest."]               = "Vertikaler Abstand zwischen Zielzeilen innerhalb einer Quest."
L["Title to content"]                                                   = "Titel zu Inhalt"
L["Vertical gap between quest title and objectives or zone below it."]  = "Vertikaler Abstand zwischen Quest-Titel und Zielen oder Zone darunter."
L["Spacing below header (px)"]                                          = "Abstand unter Kopfzeile (px)"
L["Vertical gap between the objectives bar and the quest list."]        = "Vertikaler Abstand zwischen Ziele-Leiste und Questliste."
L["Reset spacing"]                                                      = "Abstände zurücksetzen"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["Show quest level"]                                                   = "Quest-Stufe anzeigen"
L["Show quest level next to title."]                                    = "Quest-Stufe neben Titel anzeigen."
L["Dim non-focused quests"]                                             = "Nicht fokussierte Quests abdunkeln"
L["Slightly dim title, zone, objectives, and section headers that are not focused."]= "Nicht fokussierte Titel, Zonen, Ziele und Abschnitts-Header leicht abdunkeln."
L["Dim unfocused entries"]                                              = "Nicht fokussierte Einträge abdunkeln"
L["Click a section header to expand that category."]                    = "Abschnittsüberschrift klicken, um Kategorie zu erweitern."

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["Show rare bosses"]                                                   = "Seltene Bosse anzeigen"
L["Show rare boss vignettes in the list."]                              = "Seltene-Boss-Vignetten in der Liste anzeigen."
L["Rare Loot"]                                                          = "Seltene Beute"
L["Show treasure and item vignettes in the Rare Loot list."]            = "Zeigt Schätze und Gegenstände in der Liste seltener Beute."
L["Rare sound volume"]                                                  = "Lautstärke seltener Beute"
L["Volume of the rare alert sound (50–200%)."]                          = "Lautstärke des Alarmsounds für seltene Beute (50–200%)."
L["Boost or reduce the rare alert volume. 100% = normal; 150% = louder."]= "Lautstärke anpassen. 100% = normal; 150% = lauter."
L["Rare added sound"]                                                   = "Sound bei seltenem Boss"
L["Play a sound when a rare is added."]                                 = "Sound abspielen wenn ein seltener Boss hinzugefügt wird."

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["Show in-zone world quests"]                                          = "Weltquests in Zone anzeigen"
L["Auto-add world quests in your current zone. When off, only quests you've tracked or world quests you're in close proximity to appear (Blizzard default)."]= "Weltquests in Ihrer Zone automatisch hinzufügen. Aus: nur getrackte Quests oder nahe Weltquests (Blizzard-Standard)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["Show floating quest item"]                                           = "Schwebendes Quest-Item anzeigen"
L["Show quick-use button for the focused quest's usable item."]         = "Schnell-Button für nutzbares Item der fokussierten Quest anzeigen."
L["Lock floating quest item position"]                                  = "Schwebendes Quest-Item sperren"
L["Prevent dragging the floating quest item button."]                   = "Schwebendes Quest-Item nicht verschiebbar."
L["Floating quest item source"]                                         = "Quelle für schwebendes Quest-Item"
L["Which quest's item to show: super-tracked first, or current zone first."]= "Welches Quest-Item anzeigen: super-verfolgt zuerst oder aktuelle Zone zuerst."
L["Super-tracked, then first"]                                          = "Super-verfolgt, dann zuerst"
L["Current zone first"]                                                 = "Aktuelle Zone zuerst"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["Show Mythic+ block"]                                                 = "Mythisch+-Block anzeigen"
L["Show timer, completion %, and affixes in Mythic+ dungeons."]         = "Timer, Abschluss-% und Affixe in Mythisch+-Dungeons anzeigen."
L["M+ block position"]                                                  = "M+-Block-Position"
L["Position of the Mythic+ block relative to the quest list."]          = "Position des M+-Blocks relativ zur Questliste."
L["Show affix icons"]                                                   = "Affix-Symbole anzeigen"
L["Show affix icons next to modifier names in the M+ block."]           = "Affix-Symbole neben Modifikator-Namen im M+-Block anzeigen."
L["Show affix descriptions in tooltip"]                                 = "Affix-Beschreibungen im Tooltip anzeigen"
L["Show affix descriptions when hovering over the M+ block."]           = "Affix-Beschreibungen bei Mausüber M+-Block anzeigen."
L["M+ completed boss display"]                                          = "M+ besiegte Boss-Anzeige"
L["How to show defeated bosses: checkmark icon or green color."]        = "Besiegte Bosse: Häkchen-Symbol oder grüne Farbe."
L["Checkmark"]                                                          = "Häkchen"
L["Green color"]                                                        = "Grün-Farbe"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["Show achievements"]                                                  = "Erfolge anzeigen"
L["Show tracked achievements in the list."]                             = "Verfolgte Erfolge in der Liste anzeigen."
L["Show completed achievements"]                                        = "Abgeschlossene Erfolge anzeigen"
L["Include completed achievements in the tracker. When off, only in-progress tracked achievements are shown."]= "Abgeschlossene Erfolge im Zielverfolger anzeigen. Aus: nur verfolgte in Bearbeitung."
L["Show achievement icons"]                                             = "Erfolgs-Symbole anzeigen"
L["Show each achievement's icon next to the title. Requires 'Show quest type icons' in Display."]= "Erfolgs-Symbol neben Titel anzeigen. Erfordert „Quest-Typ-Symbole anzeigen\" in Anzeige."
L["Only show missing requirements"]                                     = "Nur fehlende Anforderungen anzeigen"
L["Show only criteria you haven't completed for each tracked achievement. When off, all criteria are shown."]= "Nur nicht abgeschlossene Kriterien pro verfolgtem Erfolg. Aus: alle Kriterien."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["Show endeavors"]                                                     = "Bestrebungen anzeigen"
L["Show tracked Endeavors (Player Housing) in the list."]               = "Verfolgte Bestrebungen (Spielerwohnung) in der Liste anzeigen."
L["Show completed endeavors"]                                           = "Abgeschlossene Bestrebungen anzeigen"
L["Include completed Endeavors in the tracker. When off, only in-progress tracked Endeavors are shown."]= "Abgeschlossene Bestrebungen im Zielverfolger anzeigen. Aus: nur verfolgte in Bearbeitung."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["Show decor"]                                                         = "Dekoration anzeigen"
L["Show tracked housing decor in the list."]                            = "Verfolgte Wohnungs-Dekoration in der Liste anzeigen."
L["Show decor icons"]                                                   = "Dekorations-Symbole anzeigen"
L["Show each decor item's icon next to the title. Requires 'Show quest type icons' in Display."]= "Dekorations-Symbol neben Titel anzeigen. Erfordert „Quest-Typ-Symbole anzeigen\" in Anzeige."

-- =====================================================================
-- OptionsData.lua Features — Adventure Guide
-- =====================================================================
L["Adventure Guide"]                                                    = "Abenteuerführer"
L["Show Traveler's Log"]                                                = "Reisenden-Log anzeigen"
L["Show tracked Traveler's Log objectives (Shift+click in Adventure Guide) in the list."]= "Verfolgte Reisenden-Log-Ziele (Umschalt+Klick im Abenteuerführer) in der Liste anzeigen."
L["Auto-remove completed activities"]                                   = "Abgeschlossene Aktivitäten automatisch entfernen"
L["Automatically stop tracking Traveler's Log activities once they have been completed."]= "Reisenden-Log-Aktivitäten nach Abschluss automatisch nicht mehr verfolgen."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["Show scenario events"]                                               = "Szenario-Ereignisse anzeigen"
L["Show active scenario and Delve activities. Delves appear in DELVES; other scenarios in SCENARIO EVENTS."]= "Aktive Szenario- und Tiefen-Aktivitäten anzeigen. Tiefen in Tiefen; andere in Szenario-Ereignisse."
L["Track Delve, Dungeon, and scenario activities."]                     = "Tiefen-, Dungeon- und Szenario-Aktivitäten verfolgen."
L["Delves appear in Delves section; dungeons in Dungeon; other scenarios in Scenario Events."]= "Tiefen in Tiefen; Dungeons in Dungeon; andere Szenarien in Szenario-Ereignisse."
L["Delves appear in Delves section; other scenarios in Scenario Events."]= "Tiefen in Tiefen; andere Szenarien in Szenario-Ereignisse."
L["Delve affix names"]                                                  = "Tiefen-Affix-Namen"
L["Delve/Dungeon only"]                                                 = "Nur Tiefe/Dungeon"
L["Scenario debug logging"]                                             = "Szenario-Debug-Protokoll"
L["Log scenario API data to chat. Use /h debug focus scendebug to toggle."]= "Szenario-API-Daten im Chat protokollieren. /h debug focus scendebug zum Umschalten."
L["Prints C_ScenarioInfo criteria and widget data when in a scenario. Helps diagnose display issues like Abundance 46/300."]= "Gibt C_ScenarioInfo-Kriterien und Widget-Daten aus. Hilft bei Anzeigeproblemen wie Abundance 46/300."
L["Hide other categories in Delve or Dungeon"]                          = "Andere Kategorien in Tiefe oder Dungeon verbergen"
L["In Delves or party dungeons, show only the Delve/Dungeon section."]  = "In Tiefen oder Gruppen-Dungeons nur Tiefe/Dungeon-Abschnitt anzeigen."
L["Use delve name as section header"]                                   = "Tiefen-Namen als Abschnitts-Header verwenden"
L["When in a Delve, show the delve name, tier, and affixes as the section header instead of a separate banner. Disable to show the Delve block above the list."]= "In Tiefe: Tiefenname, Stufe und Affixe als Abschnitts-Header statt separatem Banner. Aus: Tiefen-Block über Liste."
L["Show affix names in Delves"]                                         = "Affix-Namen in Tiefen anzeigen"
L["Show season affix names on the first Delve entry. Requires Blizzard's objective tracker widgets to be populated; may not show when using a full tracker replacement."]= "Saison-Affix-Namen beim ersten Tiefen-Eintrag anzeigen. Erfordert Blizzard-Widgets; evtl. nicht bei Tracker-Ersatz."
L["Cinematic scenario bar"]                                             = "Filmische Szenario-Leiste"
L["Show timer and progress bar for scenario entries."]                  = "Timer und Fortschrittsbalken für Szenario-Einträge anzeigen."
L["Show timer"]                                                         = "Timer anzeigen"
L["Show countdown timer on timed quests, events, and scenarios. When off, timers are hidden for all entry types."]= "Countdown-Timer bei zeitgesteuerten Quests, Events und Szenarien. Aus: Timer für alle ausgeblendet."
L["Timer display"]                                                      = "Timer-Anzeige"
L["Color timer by remaining time"]                                      = "Timer nach verbleibender Zeit einfärben"
L["Green when plenty of time left, yellow when running low, red when critical."]= "Grün bei viel Zeit, gelb bei wenig, rot bei kritisch."
L["Where to show the countdown: bar below objectives or text beside the quest name."]= "Wo der Countdown angezeigt wird: Leiste unter Zielen oder Text neben dem Questnamen."
L["Bar below"]                                                          = "Leiste unten"
L["Inline beside title"]                                                = "Inline neben Titel"

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["Font family."]                                                       = "Schriftart."
L["Title font"]                                                         = "Titel-Schriftart"
L["Zone font"]                                                          = "Zonen-Schriftart"
L["Objective font"]                                                     = "Ziel-Schriftart"
L["Section font"]                                                       = "Abschnitts-Schriftart"
L["Use global font"]                                                    = "Globale Schriftart verwenden"
L["Font family for quest titles."]                                      = "Schriftart für Quest-Titel."
L["Font family for zone labels."]                                       = "Schriftart für Zonen-Labels."
L["Font family for objective text."]                                    = "Schriftart für Zieltext."
L["Font family for section headers."]                                   = "Schriftart für Abschnittsüberschriften."
L["Header size"]                                                        = "Kopfzeilen-Größe"
L["Header font size."]                                                  = "Kopfzeilen-Schriftgröße."
L["Title size"]                                                         = "Titel-Größe"
L["Quest title font size."]                                             = "Quest-Titel-Schriftgröße."
L["Objective size"]                                                     = "Ziel-Größe"
L["Objective text font size."]                                          = "Zieltext-Schriftgröße."
L["Zone size"]                                                          = "Zonen-Größe"
L["Zone label font size."]                                              = "Zonen-Label-Schriftgröße."
L["Section size"]                                                       = "Abschnitts-Größe"
L["Section header font size."]                                          = "Abschnitts-Header-Schriftgröße."
L["Progress bar font"]                                                  = "Fortschrittsbalken-Schriftart"
L["Font family for the progress bar label."]                            = "Schriftart für die Fortschrittsbalken-Beschriftung."
L["Progress bar text size"]                                             = "Fortschrittsbalken-Textgröße"
L["Font size for the progress bar label. Also adjusts bar height. Affects quest objectives, scenario progress, and scenario timer bars."]= "Schriftgröße für Fortschrittsbalken-Beschriftung. Beeinflusst auch Balkenhöhe. Gilt für Quest-Ziele, Szenario-Fortschritt und Timer-Balken."
L["Progress bar fill"]                                                  = "Fortschrittsbalken-Füllung"
L["Progress bar text"]                                                  = "Fortschrittsbalken-Text"
L["Outline"]                                                            = "Umriss"
L["Font outline style."]                                                = "Schriftart-Umriss-Stil."

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["Header text case"]                                                   = "Kopfzeilen-Groß-/Kleinschreibung"
L["Display case for header."]                                           = "Groß-/Kleinschreibung für Kopfzeile."
L["Section header case"]                                                = "Abschnitts-Header Groß-/Kleinschreibung"
L["Display case for category labels."]                                  = "Groß-/Kleinschreibung für Kategorie-Labels."
L["Quest title case"]                                                   = "Quest-Titel Groß-/Kleinschreibung"
L["Display case for quest titles."]                                     = "Groß-/Kleinschreibung für Quest-Titel."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["Show text shadow"]                                                   = "Text-Schatten anzeigen"
L["Enable drop shadow on text."]                                        = "Schattierung für Text aktivieren."
L["Shadow X"]                                                           = "Schatten X"
L["Horizontal shadow offset."]                                          = "Horizontaler Schatten-Offset."
L["Shadow Y"]                                                           = "Schatten Y"
L["Vertical shadow offset."]                                            = "Vertikaler Schatten-Offset."
L["Shadow alpha"]                                                       = "Schatten-Alpha"
L["Shadow opacity (0–1)."]                                              = "Schatten-Deckkraft (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["Mythic+ Typography"]                                                 = "Mythisch+-Typografie"
L["Dungeon name size"]                                                  = "Dungeon-Namen-Größe"
L["Font size for dungeon name (8–32 px)."]                              = "Schriftgröße für Dungeon-Namen (8–32 px)."
L["Dungeon name color"]                                                 = "Dungeon-Namen-Farbe"
L["Text color for dungeon name."]                                       = "Textfarbe für Dungeon-Namen."
L["Timer size"]                                                         = "Timer-Größe"
L["Font size for timer (8–32 px)."]                                     = "Schriftgröße für Timer (8–32 px)."
L["Timer color"]                                                        = "Timer-Farbe"
L["Text color for timer (in time)."]                                    = "Textfarbe für Timer (in Zeit)."
L["Timer overtime color"]                                               = "Timer-Überzeit-Farbe"
L["Text color for timer when over the time limit."]                     = "Textfarbe für Timer bei Überschreitung."
L["Progress size"]                                                      = "Fortschritts-Größe"
L["Font size for enemy forces (8–32 px)."]                              = "Schriftgröße für feindliche Streitkräfte (8–32 px)."
L["Progress color"]                                                     = "Fortschritts-Farbe"
L["Text color for enemy forces."]                                       = "Textfarbe für feindliche Streitkräfte."
L["Bar fill color"]                                                     = "Leisten-Füllfarbe"
L["Progress bar fill color (in progress)."]                             = "Fortschrittsbalken-Füllfarbe (in Bearbeitung)."
L["Bar complete color"]                                                 = "Leisten-Farbe (abgeschlossen)"
L["Progress bar fill color when enemy forces are at 100%."]             = "Fortschrittsbalken-Füllfarbe bei 100% feindlicher Streitkräfte."
L["Affix size"]                                                         = "Affix-Größe"
L["Font size for affixes (8–32 px)."]                                   = "Schriftgröße für Affixe (8–32 px)."
L["Affix color"]                                                        = "Affix-Farbe"
L["Text color for affixes."]                                            = "Textfarbe für Affixe."
L["Boss size"]                                                          = "Boss-Größe"
L["Font size for boss names (8–32 px)."]                                = "Schriftgröße für Boss-Namen (8–32 px)."
L["Boss color"]                                                         = "Boss-Farbe"
L["Text color for boss names."]                                         = "Textfarbe für Boss-Namen."
L["Reset Mythic+ typography"]                                           = "Mythisch+-Typografie zurücksetzen"

-- =====================================================================
-- OptionsData.lua Appearance
-- =====================================================================
-- L["Frame"]                                                              = "Frame"  -- NEEDS TRANSLATION
L["Class colours - Dashboard"]                                          = "Klassenfarben – Dashboard"
-- L["Class Colours"]                                                      = "Class Colours"  -- NEEDS TRANSLATION
-- L["Enable all class colours"]                                           = "Enable all class colours"  -- NEEDS TRANSLATION
-- L["Toggle class colours on or off for all modules at once."]            = "Toggle class colours on or off for all modules at once."  -- NEEDS TRANSLATION
-- L["Dashboard"]                                                          = "Dashboard"  -- NEEDS TRANSLATION
-- L["Tint Focus header title, category section headers, main and between-section dividers, and super-tracked highlight bars and borders with your class colour."]= "Tint Focus header title, category section headers, main and between-section dividers, and super-tracked highlight bars and borders with your class colour."  -- NEEDS TRANSLATION
-- L["Tint Presence toast title and divider with your class colour."]      = "Tint Presence toast title and divider with your class colour."  -- NEEDS TRANSLATION
-- L["Tint Vista minimap, addon-bar, and panel borders and text with your class colour."]= "Tint Vista minimap, addon-bar, and panel borders and text with your class colour."  -- NEEDS TRANSLATION
-- L["Use class colour for player tooltip name, class line, and border."]  = "Use class colour for player tooltip name, class line, and border."  -- NEEDS TRANSLATION
-- L["Tint Cache loot icon glow and edit/anchor borders with your class colour."]= "Tint Cache loot icon glow and edit/anchor borders with your class colour."  -- NEEDS TRANSLATION
-- L["Tint the character name on the Essence sheet with your class colour."]= "Tint the character name on the Essence sheet with your class colour."  -- NEEDS TRANSLATION
L["Class colors"]                                                       = "Klassenfarben"
L["Tint dashboard accents, dividers, and highlights with your class colour."]= "Dashboard-Akzente, Trennlinien und Hervorhebungen mit Klassenfarbe einfärben."
-- L["Theme"]                                                              = "Theme"  -- NEEDS TRANSLATION
-- L["Dashboard background"]                                               = "Dashboard background"  -- NEEDS TRANSLATION
-- L["Background style for the module dashboard window (Axis). Default is flat; Midnight uses bundled artwork; Specialisation (auto) uses the in-game talent UI background for your current specialization."]= "Background style for the module dashboard window (Axis). Default is flat; Midnight uses bundled artwork; Specialisation (auto) uses the in-game talent UI background for your current specialization."  -- NEEDS TRANSLATION
-- L["Dashboard background Midnight"]                                      = "Midnight"  -- NEEDS TRANSLATION
-- L["Dashboard background Class talents"]                                 = "Specialisation (auto)"  -- NEEDS TRANSLATION
-- L["Dashboard background opacity"]                                       = "Dashboard background opacity"  -- NEEDS TRANSLATION
-- L["Adjust the opacity of the dashboard background (50–100%). Lower values let more of the game world show through."]= "Adjust the opacity of the dashboard background (50–100%). Lower values let more of the game world show through."  -- NEEDS TRANSLATION
L["Backdrop opacity"]                                                   = "Hintergrunddeckkraft"
L["Panel background opacity (0–1)."]                                    = "Panel-Hintergrund-Deckkraft (0–1)."
L["Show border"]                                                        = "Rahmen anzeigen"
L["Show border around the tracker."]                                    = "Rahmen um den Zielverfolger anzeigen."
L["Show scroll indicator"]                                              = "Scroll-Indikator anzeigen"
L["Show a visual hint when the list has more content than is visible."] = "Visuellen Hinweis anzeigen wenn mehr Inhalt als sichtbar vorhanden."
L["Scroll indicator style"]                                             = "Scroll-Indikator-Stil"
L["Choose between a fade-out gradient or a small arrow to indicate scrollable content."]= "Verlauf oder Pfeil für scrollbaren Inhalt wählen."
L["Arrow"]                                                              = "Pfeil"
L["Highlight alpha"]                                                    = "Hervorhebungs-Alpha"
L["Opacity of focused quest highlight (0–1)."]                          = "Deckkraft der Quest-Hervorhebung (0–1)."
L["Bar width"]                                                          = "Leistenbreite"
L["Width of bar-style highlights (2–6 px)."]                            = "Breite der Leisten-Hervorhebung (2–6 px)."

-- =====================================================================
-- OptionsData.lua Organization
-- =====================================================================
L["Activity"]                                                           = "Aktivität"
L["Content"]                                                            = "Inhalt"
L["Sorting"]                                                            = "Sortierung"
L["Elements"]                                                           = "Elemente"
L["Category order"]                                                     = "Kategorie-Reihenfolge"
L["Category color for bar"]                                             = "Kategoriefarbe für Leiste"
L["Checkmark for completed"]                                            = "Häkchen für abgeschlossen"
L["Current Quest category"]                                             = "Aktuelle Quest-Kategorie"
L["Current Quest window"]                                               = "Aktuelle Quest-Fenster"
L["Show quests with recent progress at the top."]                       = "Quests mit kürzlichem Fortschritt oben anzeigen."
L["Seconds of recent progress to show in Current Quest (30–120)."]      = "Sekunden Fortschritt für Aktuelle Quest (30–120)."
L["Quests you made progress on in the last minute appear in a dedicated section."]= "Quests mit Fortschritt in der letzten Minute erscheinen in eigenem Abschnitt."
L["Focus category order"]                                               = "Fokus-Kategorie-Reihenfolge"
L["Drag to reorder categories. DELVES and SCENARIO EVENTS stay first."] = "Ziehen zum Ändern der Kategorie-Reihenfolge. Tiefen und Szenario-Ereignisse bleiben zuerst."
L["Drag to reorder. Delves and Scenarios stay first."]                  = "Ziehen zum Ändern der Reihenfolge. Tiefen und Szenarien bleiben zuerst."
L["Focus sort mode"]                                                    = "Fokus-Sortiermodus"
L["Order of entries within each category."]                             = "Reihenfolge der Einträge innerhalb jeder Kategorie."
L["Auto-track accepted quests"]                                         = "Angenommene Quests automatisch verfolgen"
L["When you accept a quest (quest log only, not world quests), add it to the tracker automatically."]= "Angenommene Quests (nur Questlog, nicht Weltquests) automatisch zum Zielverfolger hinzufügen."
L["Require Ctrl for focus & remove"]                                    = "Strg für Fokus & Entfernen erforderlich"
L["Require Ctrl for focus/add (Left) and unfocus/untrack (Right) to prevent misclicks."]= "Strg für Fokus/Hinzufügen (Links) und Entfokussieren/Entfernen (Rechts) erforderlich, um Fehlklicks zu vermeiden."
L["Ctrl for focus / untrack"]                                           = "Strg für Fokus / Nicht verfolgen"
L["Ctrl to click-complete"]                                             = "Strg für Klick-Abschluss"
L["Use classic click behaviour"]                                        = "Klassisches Klick-Verhalten verwenden"
L["Classic clicks"]                                                     = "Klassische Klicks"
L["Share with party"]                                                   = "Mit Gruppe teilen"
L["Abandon quest"]                                                      = "Quest abbrechen"
L["Stop tracking"]                                                      = "Nicht mehr verfolgen"
L["This quest cannot be shared."]                                       = "Diese Quest kann nicht geteilt werden."
L["You must be in a party to share this quest."]                        = "Sie müssen in einer Gruppe sein, um diese Quest zu teilen."
L["When on, left-click opens the quest map and right-click shows share/abandon menu (Blizzard-style). When off, left-click focuses and right-click untracks; Ctrl+Right shares with party."]= "An: Linksklick öffnet Questkarte, Rechtsklick Teilen/Abbruch (Blizzard). Aus: Linksklick fokussiert, Rechtsklick nicht verfolgen; Strg+Rechts teilt."
L["Animations"]                                                         = "Animationen"
L["Enable slide and fade for quests."]                                  = "Slide- und Fade-Effekte für Quests aktivieren."
L["Objective progress flash"]                                           = "Ziel-Fortschritt-Blitz"
L["Show flash when an objective completes."]                            = "Blitz bei Ziel-Abschluss anzeigen."
L["Flash intensity"]                                                    = "Blitz-Intensität"
L["How noticeable the objective-complete flash is."]                    = "Wie auffällig der Ziel-Abschluss-Blitz ist."
L["Flash color"]                                                        = "Blitz-Farbe"
L["Color of the objective-complete flash."]                             = "Farbe des Ziel-Abschluss-Blitzes."
L["Subtle"]                                                             = "Dezent"
L["Medium"]                                                             = "Mittel"
L["Strong"]                                                             = "Stark"
L["Require Ctrl for click to complete"]                                 = "Strg für Klick zum Abschließen erforderlich"
L["When on, requires Ctrl+Left-click to complete auto-complete quests. When off, plain Left-click completes them (Blizzard default). Only affects quests that can be completed by click (no NPC turn-in needed)."]= "An: Strg+Linksklick für Klick-Abschluss. Aus: einfacher Linksklick (Blizzard-Standard). Nur bei klickbaren Quests."
L["Suppress untracked until reload"]                                    = "Nicht verfolgte bis Neuladen unterdrücken"
L["When on, right-click untrack on world quests and in-zone weeklies/dailies hides them until you reload or start a new session. When off, they reappear when you return to the zone."]= "An: Rechtsklick Nicht verfolgen versteckt bis Neuladen oder neuer Sitzung. Aus: erscheinen wieder bei Zonen-Rückkehr."
L["Permanently suppress untracked quests"]                              = "Nicht verfolgte Quests dauerhaft unterdrücken"
L["When on, right-click untracked world quests and in-zone weeklies/dailies are hidden permanently (persists across reloads). Takes priority over 'Suppress until reload'. Accepting a suppressed quest removes it from the blacklist."]= "An: Rechtsklick Nicht verfolgen versteckt dauerhaft (über Neuladen). Vorrang vor „Bis Neuladen\". Annehmen entfernt von Sperrliste."
L["Keep campaign quests in category"]                                   = "Kampagnen-Quest in Kategorie bleiben"
L["When on, campaign quests that are ready to turn in remain in the Campaign category instead of moving to Complete."]= "An: abgabereife Kampagnen-Quests bleiben in Kampagne statt in Abgeschlossen."
L["Keep important quests in category"]                                  = "Wichtige Quests in Kategorie bleiben"
L["When on, important quests that are ready to turn in remain in the Important category instead of moving to Complete."]= "An: abgabereife wichtige Quests bleiben in Wichtig statt in Abgeschlossen."
L["TomTom quest waypoint"]                                              = "TomTom-Quest-Wegpunkt"
L["Set a TomTom waypoint when focusing a quest."]                       = "TomTom-Wegpunkt setzen beim Fokussieren einer Quest."
L["Requires TomTom. Points the arrow to the next quest objective."]     = "TomTom erforderlich. Der Pfeil zeigt auf das nächste Questziel."
L["TomTom rare waypoint"]                                               = "TomTom-Selten-Boss-Wegpunkt"
L["Set a TomTom waypoint when clicking a rare boss."]                   = "TomTom-Wegpunkt setzen beim Klicken auf einen seltenen Boss."
L["Requires TomTom. Points the arrow to the rare's location."]          = "TomTom erforderlich. Der Pfeil zeigt auf die Position des seltenen Bosses."
L["Find a Group"]                                                       = "Gruppe finden"
L["Click to search for a group for this quest."]                        = "Klicken, um eine Gruppe für diese Quest zu suchen."

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
L["Blacklist"]                                                          = "Sperrliste"
L["Blacklist untracked"]                                                = "Nicht verfolgte sperren"
L["Enable 'Blacklist untracked' in Behaviour to add quests here."]      = "„Nicht verfolgte sperren\" in Verhalten aktivieren, um Quests hier hinzuzufügen."
L["Hidden Quests"]                                                      = "Versteckte Quests"
L["Quests hidden via right-click untrack."]                             = "Quests versteckt durch Rechtsklick Nicht verfolgen."
L["Blacklisted quests"]                                                 = "Gesperrte Quests"
L["Permanently suppressed quests"]                                      = "Dauerhaft unterdrückte Quests"
L["Right-click untrack quests with 'Permanently suppress untracked quests' enabled to add them here."]= "Rechtsklick Nicht verfolgen mit „Dauerhaft unterdrücken\" aktiviert fügt Quests hier hinzu."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["Show quest type icons"]                                              = "Quest-Typ-Symbole anzeigen"
L["Show quest type icon in the Focus tracker (quest accept/complete, world quest, quest update)."]= "Quest-Typ-Symbol im Focus-Zielverfolger anzeigen."
L["Show quest type icons on toasts"]                                    = "Quest-Typ-Symbole auf Toasts anzeigen"
L["Show quest type icon on Presence toasts (quest accept/complete, world quest, quest update)."]= "Quest-Typ-Symbol auf Präsenz-Toasts anzeigen."
L["Toast icon size"]                                                    = "Toast-Symbolgröße"
L["Quest icon size on Presence toasts (16–36 px). Default 24."]         = "Quest-Symbolgröße auf Präsenz-Toasts (16–36 px). Standard 24."
L["Hide quest update title"]                                            = "Quest-Update-Titel verbergen"
L["Show only the objective line on quest progress toasts (e.g. 7/10 Boar Pelts), without the quest name or header."]= "Nur Zielzeile auf Quest-Fortschritt-Toasts (z.B. 7/10 Eberfelle), ohne Questname oder Header."
L["Show discovery line"]                                                = "Entdeckungs-Zeile anzeigen"
L["Discovery line"]                                                     = "Entdeckungs-Zeile"
L["Show 'Discovered' under zone/subzone when entering a new area."]     = "„Entdeckt\" unter Zone/Unterzone bei neuem Gebiet anzeigen."
L["Frame vertical position"]                                            = "Rahmen vertikale Position"
L["Vertical offset of the Presence frame from center (-300 to 0)."]     = "Vertikaler Offset des Präsenz-Rahmens von Mitte (-300 bis 0)."
L["Frame scale"]                                                        = "Rahmen-Skalierung"
L["Scale of the Presence frame (0.5–2)."]                               = "Skalierung des Präsenz-Rahmens (0,5–2)."
L["Boss emote color"]                                                   = "Boss-Emote-Farbe"
L["Color of raid and dungeon boss emote text."]                         = "Farbe von Boss-Emote-Text in Schlachtzügen und Dungeons."
L["Discovery line color"]                                               = "Entdeckungs-Zeilen-Farbe"
L["Color of the 'Discovered' line under zone text."]                    = "Farbe der „Entdeckt\"-Zeile unter dem Zonentext."
L["Notification types"]                                                 = "Benachrichtigungstypen"
L["Notifications"]                                                      = "Benachrichtigungen"
L["Show notification when achievement criteria update (tracked achievements always; others when Blizzard provides the achievement ID)."]= "Benachrichtigung bei Erfolgs-Kriterien-Update (verfolgte immer; andere wenn Blizzard ID liefert)."
L["Show zone entry"]                                                    = "Zoneneintritt anzeigen"
L["Show zone change when entering a new area."]                         = "Zonenwechsel bei neuem Gebiet anzeigen."
L["Show subzone changes"]                                               = "Unterzonenwechsel anzeigen"
L["Show subzone change when moving within the same zone."]              = "Unterzonenwechsel bei Bewegung in gleicher Zone anzeigen."
L["Hide zone name for subzone changes"]                                 = "Zonennamen bei Unterzonenwechsel verbergen"
L["When moving between subzones within the same zone, only show the subzone name. The zone name still appears when entering a new zone."]= "Bei Unterzonenwechsel in gleicher Zone nur Unterzonenname. Zonennamen erscheint bei neuer Zone."
-- L["Suppress in Delve"]                                                  = "Suppress in Delve"  -- NEEDS TRANSLATION
-- L["Suppress scenario progress notifications in Delves."]                = "Suppress scenario progress notifications in Delves."  -- NEEDS TRANSLATION
-- L["When on, hides objective update popups while in a Delve. Zone entry and completion toasts still show."]= "When on, hides objective update popups while in a Delve. Zone entry and completion toasts still show."  -- NEEDS TRANSLATION
L["Suppress zone changes in Mythic+"]                                   = "Zonenwechsel in Mythisch+ unterdrücken"
L["In Mythic+, only show boss emotes, achievements, and level-up. Hide zone, quest, and scenario notifications."]= "In Mythisch+ nur Boss-Emotes, Erfolge und Levelaufstieg. Zone-, Quest- und Szenario-Benachrichtigungen verbergen."
L["Show level up"]                                                      = "Levelaufstieg anzeigen"
L["Show level-up notification."]                                        = "Levelaufstieg-Benachrichtigung anzeigen."
L["Show boss emotes"]                                                   = "Boss-Emotes anzeigen"
L["Show raid and dungeon boss emote notifications."]                    = "Schlachtzug- und Dungeon-Boss-Emote-Benachrichtigungen anzeigen."
L["Show achievements"]                                                  = "Erfolge anzeigen"
L["Show achievement earned notifications."]                             = "Benachrichtigungen bei erlangten Erfolgen anzeigen."
L["Achievement progress"]                                               = "Erfolgsfortschritt"
L["Achievement earned"]                                                 = "Erfolg erlangt"
L["Quest accepted"]                                                     = "Quest angenommen"
L["World quest accepted"]                                               = "Weltquest angenommen"
L["Scenario complete"]                                                  = "Szenario abgeschlossen"
L["Rare defeated"]                                                      = "Selten besiegt"
L["Show notification when tracked achievement criteria update."]        = "Benachrichtigung bei verfolgtem Erfolgs-Kriterien-Update anzeigen."
L["Show quest accept"]                                                  = "Quest-Annahme anzeigen"
L["Show notification when accepting a quest."]                          = "Benachrichtigung bei Quest-Annahme anzeigen."
L["Show world quest accept"]                                            = "Weltquest-Annahme anzeigen"
L["Show notification when accepting a world quest."]                    = "Benachrichtigung bei Weltquest-Annahme anzeigen."
L["Show quest complete"]                                                = "Quest-Abschluss anzeigen"
L["Show notification when completing a quest."]                         = "Benachrichtigung bei Quest-Abschluss anzeigen."
L["Show world quest complete"]                                          = "Weltquest-Abschluss anzeigen"
L["Show notification when completing a world quest."]                   = "Benachrichtigung bei Weltquest-Abschluss anzeigen."
L["Show quest progress"]                                                = "Quest-Fortschritt anzeigen"
L["Show notification when quest objectives update."]                    = "Benachrichtigung bei Quest-Ziel-Update anzeigen."
L["Objective only"]                                                     = "Nur Ziel"
L["Show only the objective line on quest progress toasts, hiding the 'Quest Update' title."]= "Nur Zielzeile auf Quest-Fortschritt-Toasts, „Quest-Update\"-Titel verbergen."
L["Show scenario start"]                                                = "Szenario-Start anzeigen"
L["Show notification when entering a scenario or Delve."]               = "Benachrichtigung bei Szenario- oder Tiefen-Eintritt anzeigen."
L["Show scenario progress"]                                             = "Szenario-Fortschritt anzeigen"
L["Show notification when scenario or Delve objectives update."]        = "Benachrichtigung bei Szenario- oder Tiefen-Ziel-Update anzeigen."
L["Animation"]                                                          = "Animation"
L["Enable animations"]                                                  = "Animationen aktivieren"
L["Enable entrance and exit animations for Presence notifications."]    = "Ein- und Ausblend-Animationen für Präsenz-Benachrichtigungen aktivieren."
L["Entrance duration"]                                                  = "Einblend-Dauer"
L["Duration of the entrance animation in seconds (0.2–1.5)."]           = "Dauer der Einblend-Animation in Sekunden (0,2–1,5)."
L["Exit duration"]                                                      = "Ausblend-Dauer"
L["Duration of the exit animation in seconds (0.2–1.5)."]               = "Dauer der Ausblend-Animation in Sekunden (0,2–1,5)."
L["Hold duration scale"]                                                = "Anzeige-Dauer-Multiplikator"
L["Multiplier for how long each notification stays on screen (0.5–2)."] = "Multiplikator für Anzeige-Dauer jeder Benachrichtigung (0,5–2)."
-- L["Preview"]                                                            = "Preview"  -- NEEDS TRANSLATION
-- L["Preview toast type"]                                                 = "Preview toast type"  -- NEEDS TRANSLATION
-- L["Select a toast type to preview."]                                    = "Select a toast type to preview."  -- NEEDS TRANSLATION
-- L["Show the selected toast type."]                                      = "Show the selected toast type."  -- NEEDS TRANSLATION
-- L["Preview Presence toast layouts live and open a detachable sample while adjusting other settings."]= "Preview Presence toast layouts live and open a detachable sample while adjusting other settings."  -- NEEDS TRANSLATION
-- L["Open detached preview"]                                              = "Open detached preview"  -- NEEDS TRANSLATION
-- L["Open a movable preview window that stays visible while you change other Presence settings."]= "Open a movable preview window that stays visible while you change other Presence settings."  -- NEEDS TRANSLATION
-- L["Animate preview"]                                                    = "Animate preview"  -- NEEDS TRANSLATION
-- L["Play the selected toast animation inside this preview window."]      = "Play the selected toast animation inside this preview window."  -- NEEDS TRANSLATION
-- L["Detached preview"]                                                   = "Detached preview"  -- NEEDS TRANSLATION
-- L["Keep this open while adjusting Typography or Colors."]               = "Keep this open while adjusting Typography or Colors."  -- NEEDS TRANSLATION
L["Typography"]                                                         = "Typografie"
L["Main title font"]                                                    = "Haupttitel-Schriftart"
L["Font family for the main title."]                                    = "Schriftart für den Haupttitel."
L["Subtitle font"]                                                      = "Untertitel-Schriftart"
L["Font family for the subtitle."]                                      = "Schriftart für den Untertitel."
-- L["Reset typography to defaults"]                                       = "Reset typography to defaults"  -- NEEDS TRANSLATION
-- L["Reset all Presence typography options (fonts, sizes, colors) to defaults."]= "Reset all Presence typography options (fonts, sizes, colors) to defaults."  -- NEEDS TRANSLATION
-- L["Large notifications"]                                                = "Large notifications"  -- NEEDS TRANSLATION
-- L["Medium notifications"]                                               = "Medium notifications"  -- NEEDS TRANSLATION
-- L["Small notifications"]                                                = "Small notifications"  -- NEEDS TRANSLATION
-- L["Large primary size"]                                                 = "Large primary size"  -- NEEDS TRANSLATION
-- L["Font size for large notification titles (zone, quest complete, achievement, etc.)."]= "Font size for large notification titles (zone, quest complete, achievement, etc.)."  -- NEEDS TRANSLATION
-- L["Large secondary size"]                                               = "Large secondary size"  -- NEEDS TRANSLATION
-- L["Font size for large notification subtitles."]                        = "Font size for large notification subtitles."  -- NEEDS TRANSLATION
-- L["Medium primary size"]                                                = "Medium primary size"  -- NEEDS TRANSLATION
-- L["Font size for medium notification titles (quest accept, subzone, scenario)."]= "Font size for medium notification titles (quest accept, subzone, scenario)."  -- NEEDS TRANSLATION
-- L["Medium secondary size"]                                              = "Medium secondary size"  -- NEEDS TRANSLATION
-- L["Font size for medium notification subtitles."]                       = "Font size for medium notification subtitles."  -- NEEDS TRANSLATION
-- L["Small primary size"]                                                 = "Small primary size"  -- NEEDS TRANSLATION
-- L["Font size for small notification titles (quest progress, achievement progress)."]= "Font size for small notification titles (quest progress, achievement progress)."  -- NEEDS TRANSLATION
-- L["Small secondary size"]                                               = "Small secondary size"  -- NEEDS TRANSLATION
-- L["Font size for small notification subtitles."]                        = "Font size for small notification subtitles."  -- NEEDS TRANSLATION

-- =====================================================================
-- OptionsData.lua Dropdown options — Outline
-- =====================================================================
L["None"]                                                               = "Keine"
L["Thick Outline"]                                                      = "Dicker Umriss"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["Bar (left edge)"]                                                    = "Leiste (linker Rand)"
L["Bar (right edge)"]                                                   = "Leiste (rechter Rand)"
L["Bar (top edge)"]                                                     = "Leiste (oberer Rand)"
L["Bar (bottom edge)"]                                                  = "Leiste (unterer Rand)"
L["Outline only"]                                                       = "Nur Umriss"
L["Soft glow"]                                                          = "Sanftes Leuchten"
L["Dual edge bars"]                                                     = "Doppelrand-Leisten"
L["Pill left accent"]                                                   = "Pill-Links-Akzent"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["Top"]                                                                = "Oben"
L["Bottom"]                                                             = "Unten"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["Location position"]                                                  = "Standort-Position"
L["Place the zone name above or below the minimap."]                    = "Zonennamen über oder unter der Minikarte platzieren."
L["Coordinates position"]                                               = "Koordinaten-Position"
L["Place the coordinates above or below the minimap."]                  = "Koordinaten über oder unter der Minikarte platzieren."
L["Clock position"]                                                     = "Uhr-Position"
L["Place the clock above or below the minimap."]                        = "Uhr über oder unter der Minikarte platzieren."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["Lower Case"]                                                         = "Kleinbuchstaben"
L["Upper Case"]                                                         = "Großbuchstaben"
L["Proper"]                                                             = "Erster Buchstabe groß"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["Tracked / in log"]                                                   = "Verfolgt / im Log"
L["In log / max slots"]                                                 = "Im Log / max. Plätze"

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["Alphabetical"]                                                       = "Alphabetisch"
L["Quest Type"]                                                         = "Quest-Typ"
L["Quest Level"]                                                        = "Quest-Stufe"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["Custom"]                                                             = "Benutzerdefiniert"
L["Order"]                                                              = "Reihenfolge"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["DUNGEON"]                                                            = "DUNGEON"
L["RAID"]                                                               = "RAID"
L["DELVES"]                                                             = "Tiefen"
L["SCENARIO EVENTS"]                                                    = "Szenario-Ereignisse"
-- L["Stage"]                                                              = "Stage"  -- NEEDS TRANSLATION
-- L["Stage %d: %s"]                                                       = "Stage %d: %s"  -- NEEDS TRANSLATION
L["AVAILABLE IN ZONE"]                                                  = "IN ZONE VERFÜGBAR"
L["EVENTS IN ZONE"]                                                     = "Ereignisse in Zone"
L["CURRENT EVENT"]                                                      = "Aktuelles Ereignis"
L["CURRENT QUEST"]                                                      = "AKTUELLE QUEST"
L["CURRENT ZONE"]                                                       = "AKTUELLE ZONE"
L["CAMPAIGN"]                                                           = "KAMPAGNE"
L["IMPORTANT"]                                                          = "WICHTIG"
L["LEGENDARY"]                                                          = "LEGENDÄR"
L["WORLD QUESTS"]                                                       = "WELTQUESTS"
L["WEEKLY QUESTS"]                                                      = "Wochenquests"
L["PREY"]                                                               = "Beute"
L["Abundance"]                                                          = "Überfluss"
L["Abundance Bag"]                                                      = "Überflussbeutel"
L["abundance held"]                                                     = "Überfluss gehalten"
L["DAILY QUESTS"]                                                       = "Tagesquests"
L["RARE BOSSES"]                                                        = "RARE BOSSE"
L["ACHIEVEMENTS"]                                                       = "ERFOLGE"
L["ENDEAVORS"]                                                          = "BESTREBUNGEN"
L["DECOR"]                                                              = "DEKORATION"
L["QUESTS"]                                                             = "QUESTS"
L["READY TO TURN IN"]                                                   = "ABGABEBEREIT"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["OBJECTIVES"]                                                         = "ZIELE"
L["Options"]                                                            = "Optionen"
L["Open Horizon Suite"]                                                 = "Horizon Suite öffnen"
L["Open the full Horizon Suite options panel to configure Focus, Presence, Vista, and other modules."]= "Öffnet das vollständige Horizon Suite-Optionsfenster zur Konfiguration von Focus, Presence, Vista und anderen Modulen."
L["Show minimap icon"]                                                  = "Minimap-Symbol anzeigen"
L["Show a clickable icon on the minimap that opens the options panel."] = "Zeigt ein klickbares Symbol auf der Minimap, das das Optionsfenster öffnet."
-- L["Lock minimap button position"]                                       = "Lock minimap button position"  -- NEEDS TRANSLATION
-- L["Prevent dragging the Horizon minimap button."]                       = "Prevent dragging the Horizon minimap button."  -- NEEDS TRANSLATION
-- L["Reset minimap button position"]                                      = "Reset minimap button position"  -- NEEDS TRANSLATION
-- L["Reset the minimap button to the default position (bottom-left)."]    = "Reset the minimap button to the default position (bottom-left)."  -- NEEDS TRANSLATION
-- L["Drag to move (when unlocked)."]                                      = "Drag to move (when unlocked)."  -- NEEDS TRANSLATION
-- L["Locked"]                                                             = "Locked"  -- NEEDS TRANSLATION
L["Discovered"]                                                         = "Entdeckt"
L["Refresh"]                                                            = "Aktualisieren"
L["Best-effort only. Some unaccepted quests are not exposed until you interact with NPCs or meet phasing conditions."]= "Nur bestmöglich. Manche nicht angenommenen Quests werden erst nach NPC-Interaktion oder Phasenbedingungen angezeigt."
L["Unaccepted Quests - %s (map %s) - %d match(es)"]                     = "Nicht angenommene Quests - %s (Karte %s) - %d Treffer"

L["LEVEL UP"]                                                           = "LEVELAUFSTIEG"
L["You have reached level 80"]                                          = "Ihr habt Stufe 80 erreicht"
L["You have reached level %s"]                                          = "Ihr habt Stufe %s erreicht"
L["ACHIEVEMENT EARNED"]                                                 = "ERFOLG ERLANGT"
L["Exploring the Midnight Isles"]                                       = "Mitternachtsinseln erkunden"
L["Exploring Khaz Algar"]                                               = "Khaz Algar erkunden"
L["QUEST COMPLETE"]                                                     = "QUEST ABGESCHLOSSEN"
L["Objective Secured"]                                                  = "Ziel gesichert"
L["Aiding the Accord"]                                                  = "Dem Abkommen helfen"
L["WORLD QUEST"]                                                        = "WELTQUEST"
L["WORLD QUEST COMPLETE"]                                               = "WELTQUEST ABGESCHLOSSEN"
L["Azerite Mining"]                                                     = "Azerit-Abbau"
L["WORLD QUEST ACCEPTED"]                                               = "WELTQUEST ANGENOMMEN"
L["QUEST ACCEPTED"]                                                     = "QUEST ANGENOMMEN"
L["The Fate of the Horde"]                                              = "Das Schicksal der Horde"
L["New Quest"]                                                          = "Neue Quest"
L["QUEST UPDATE"]                                                       = "QUEST-UPDATE"
L["Boar Pelts: 7/10"]                                                   = "Eberfelle: 7/10"
L["Dragon Glyphs: 3/5"]                                                 = "Dragon Glyphs: 3/5"

L["Presence test commands:"]                                            = "Präsenz-Testbefehle:"
L["  /h presence debugtypes - Dump notification toggles and Blizzard suppression state"]= "  /h presence debugtypes - Benachrichtigungsoptionen und Blizzard-Unterdrückungsstatus ausgeben"
L["Presence: Playing demo reel (all notification types)..."]            = "Präsenz: Demo wird abgespielt (alle Benachrichtigungstypen)..."
L["  /h presence         - Show help + test current zone"]              = "  /h presence         - Hilfe + aktuelle Zone testen"
L["  /h presence zone     - Test Zone Change"]                          = "  /h presence zone     - Zonenwechsel testen"
L["  /h presence subzone  - Test Subzone Change"]                       = "  /h presence subzone  - Unterzonenwechsel testen"
L["  /h presence discover - Test Zone Discovery"]                       = "  /h presence discover - Zonenentdeckung testen"
L["  /h presence level    - Test Level Up"]                             = "  /h presence level    - Levelaufstieg testen"
L["  /h presence boss     - Test Boss Emote"]                           = "  /h presence boss     - Boss-Emote testen"
L["  /h presence ach      - Test Achievement"]                          = "  /h presence ach      - Erfolg testen"
L["  /h presence accept   - Test Quest Accepted"]                       = "  /h presence accept   - Quest angenommen testen"
L["  /h presence wqaccept - Test World Quest Accepted"]                 = "  /h presence wqaccept - Weltquest angenommen testen"
L["  /h presence scenario - Test Scenario Start"]                       = "  /h presence scenario - Szenario-Start testen"
L["  /h presence quest    - Test Quest Complete"]                       = "  /h presence quest    - Quest abgeschlossen testen"
L["  /h presence wq       - Test World Quest"]                          = "  /h presence wq       - Weltquest testen"
L["  /h presence update   - Test Quest Update"]                         = "  /h presence update   - Quest-Update testen"
L["  /h presence achprogress - Test Achievement Progress"]              = "  /h presence achprogress - Erfolgsfortschritt testen"
L["  /h presence all      - Demo reel (all types)"]                     = "  /h presence all      - Demo (alle Typen)"
L["  /h presence debug    - Dump state to chat"]                        = "  /h presence debug    - Status im Chat ausgeben"
L["  /h presence debuglive - Toggle live debug panel (log as events happen)"]= "  /h presence debuglive - Live-Debug-Panel umschalten"

-- =====================================================================
-- OptionsData.lua Vista — General
L["Position & layout"]                                                  = "Position & Layout"
-- =====================================================================
L["Minimap"]                                                            = "Minikarte"
L["Minimap size"]                                                       = "Minikarten-Größe"
L["Width and height of the minimap in pixels (100–400)."]               = "Breite und Höhe der Minikarte in Pixeln (100–400)."
L["Circular minimap"]                                                   = "Runde Minikarte"
L["Circular shape"]                                                     = "Runde Form"
L["Use a circular minimap instead of square."]                          = "Runde Minikarte statt quadratisch verwenden."
L["Lock minimap position"]                                              = "Minikarten-Position sperren"
L["Prevent dragging the minimap."]                                      = "Minikarte nicht verschiebbar."
L["Reset minimap position"]                                             = "Minikarten-Position zurücksetzen"
L["Reset minimap to its default position (top-right)."]                 = "Minikarte auf Standardposition (oben rechts) zurücksetzen."
L["Auto Zoom"]                                                          = "Auto-Zoom"
L["Auto zoom-out delay"]                                                = "Auto-Zoom-Out-Verzögerung"
L["Seconds after zooming before auto zoom-out fires. Set to 0 to disable."]= "Sekunden nach Zoom bis Auto-Zoom-Out. 0 = deaktiviert."

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["Zone Text"]                                                          = "Zonen-Text"
L["Zone font"]                                                          = "Zonen-Schriftart"
L["Font for the zone name below the minimap."]                          = "Schriftart für den Zonennamen unter der Minikarte."
L["Zone font size"]                                                     = "Zonen-Schriftgröße"
L["Zone text color"]                                                    = "Zonentext-Farbe"
L["Color of the zone name text."]                                       = "Farbe des Zonennamen-Texts."
L["Coordinates Text"]                                                   = "Koordinaten-Text"
L["Coordinates font"]                                                   = "Koordinaten-Schriftart"
L["Font for the coordinates text below the minimap."]                   = "Schriftart für den Koordinaten-Text unter der Minikarte."
L["Coordinates font size"]                                              = "Koordinaten-Schriftgröße"
L["Coordinates text color"]                                             = "Koordinaten-Textfarbe"
L["Color of the coordinates text."]                                     = "Farbe des Koordinaten-Texts."
L["Coordinate precision"]                                               = "Koordinaten-Genauigkeit"
L["Number of decimal places shown for X and Y coordinates."]            = "Anzahl Dezimalstellen für X- und Y-Koordinaten."
L["No decimals (e.g. 52, 37)"]                                          = "Keine Dezimalstellen (z.B. 52, 37)"
L["1 decimal (e.g. 52.3, 37.1)"]                                        = "1 Dezimalstelle (z.B. 52,3, 37,1)"
L["2 decimals (e.g. 52.34, 37.12)"]                                     = "2 Dezimalstellen (z.B. 52,34, 37,12)"
L["Time Text"]                                                          = "Zeit-Text"
L["Time font"]                                                          = "Zeit-Schriftart"
L["Font for the time text below the minimap."]                          = "Schriftart für den Zeit-Text unter der Minikarte."
L["Time font size"]                                                     = "Zeit-Schriftgröße"
L["Time text color"]                                                    = "Zeit-Textfarbe"
L["Color of the time text."]                                            = "Farbe des Zeit-Texts."
L["Performance Text"]                                                   = "Performance-Text"
L["Performance font"]                                                   = "Performance-Schriftart"
L["Font for the FPS and latency text below the minimap."]               = "Schriftart für FPS- und Latenz-Text unter der Minikarte."
L["Performance font size"]                                              = "Performance-Schriftgröße"
L["Performance text color"]                                             = "Performance-Textfarbe"
L["Color of the FPS and latency text."]                                 = "Farbe des FPS- und Latenz-Texts."
L["Difficulty Text"]                                                    = "Schwierigkeits-Text"
L["Difficulty text color (fallback)"]                                   = "Schwierigkeits-Textfarbe (Fallback)"
L["Default color when no per-difficulty color is set."]                 = "Standardfarbe für nicht gesetzte Schwierigkeitsfarben."
L["Difficulty font"]                                                    = "Schwierigkeits-Schriftart"
L["Font for the instance difficulty text."]                             = "Schriftart für den Instanz-Schwierigkeitstext."
L["Difficulty font size"]                                               = "Schwierigkeits-Schriftgröße"
L["Per-Difficulty Colors"]                                              = "Farben pro Schwierigkeit"
L["Mythic color"]                                                       = "Mythisch-Farbe"
L["Color for Mythic difficulty text."]                                  = "Farbe für Mythisch-Schwierigkeitstext."
L["Heroic color"]                                                       = "Heroisch-Farbe"
L["Color for Heroic difficulty text."]                                  = "Farbe für Heroisch-Schwierigkeitstext."
L["Normal color"]                                                       = "Normal-Farbe"
L["Color for Normal difficulty text."]                                  = "Farbe für Normal-Schwierigkeitstext."
L["LFR color"]                                                          = "LFR-Farbe"
L["Color for Looking For Raid difficulty text."]                        = "Farbe für Suche-nach-Schlachtzug-Text."

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["Text Elements"]                                                      = "Text-Elemente"
L["Show zone text"]                                                     = "Zonentext anzeigen"
L["Show the zone name below the minimap."]                              = "Zonennamen unter der Minikarte anzeigen."
L["Zone text display mode"]                                             = "Zonentext-Anzeigemodus"
L["What to show: zone only, subzone only, or both."]                    = "Was anzeigen: nur Zone, nur Unterzone oder beides."
L["Zone only"]                                                          = "Nur Zone"
L["Subzone only"]                                                       = "Nur Unterzone"
L["Both"]                                                               = "Beides"
L["Show coordinates"]                                                   = "Koordinaten anzeigen"
L["Show player coordinates below the minimap."]                         = "Spielerkoordinaten unter der Minikarte anzeigen."
L["Show time"]                                                          = "Zeit anzeigen"
L["Show current game time below the minimap."]                          = "Aktuelle Spielzeit unter der Minikarte anzeigen."
L["24-hour clock"]                                                      = "24-Stunden-Zeit"
L["Display time in 24-hour format (e.g. 14:30 instead of 2:30 PM)."]    = "Zeit im 24-Stunden-Format anzeigen (z.B. 14:30 statt 2:30 PM)."
L["Use local time"]                                                     = "Lokale Zeit verwenden"
L["When on, shows your local system time. When off, shows server time."]= "An: lokale Systemzeit. Aus: Serverzeit."
L["Show FPS and latency"]                                               = "FPS und Latenz anzeigen"
L["Show FPS and latency (ms) below the minimap."]                       = "FPS und Latenz (ms) unter der Minikarte anzeigen."
L["Minimap Buttons"]                                                    = "Minikarten-Buttons"
L["Queue status and mail indicator are always shown when relevant."]    = "Warteschlangen- und Post-Status werden bei Relevanz angezeigt."
L["Show tracking button"]                                               = "Verfolgen-Button anzeigen"
L["Show the minimap tracking button."]                                  = "Minikarten-Verfolgen-Button anzeigen."
L["Tracking button on mouseover only"]                                  = "Verfolgen-Button nur bei Mausüber"
L["Hide tracking button until you hover over the minimap."]             = "Verfolgen-Button verbergen bis Maus über Minikarte."
L["Show calendar button"]                                               = "Kalender-Button anzeigen"
L["Show the minimap calendar button."]                                  = "Minikarten-Kalender-Button anzeigen."
L["Calendar button on mouseover only"]                                  = "Kalender-Button nur bei Mausüber"
L["Hide calendar button until you hover over the minimap."]             = "Kalender-Button verbergen bis Maus über Minikarte."
L["Show zoom buttons"]                                                  = "Zoom-Buttons anzeigen"
L["Show the + and - zoom buttons on the minimap."]                      = "Zoom-Buttons (+ und -) auf der Minikarte anzeigen."
L["Zoom buttons on mouseover only"]                                     = "Zoom-Buttons nur bei Mausüber"
L["Hide zoom buttons until you hover over the minimap."]                = "Zoom-Buttons verbergen bis Maus über Minikarte."

-- =====================================================================
-- OptionsData.lua Vista — Display (Border / Text Positions / Buttons)
-- =====================================================================
L["Border"]                                                             = "Rahmen"
L["Show a border around the minimap."]                                  = "Rahmen um die Minikarte anzeigen."
L["Border color"]                                                       = "Rahmenfarbe"
L["Color (and opacity) of the minimap border."]                         = "Farbe (und Deckkraft) des Minikarten-Rahmens."
L["Border thickness"]                                                   = "Rahmenstärke"
L["Thickness of the minimap border in pixels (1–8)."]                   = "Stärke des Minikarten-Rahmens in Pixeln (1–8)."
L["Class colours"]                                                      = "Klassenfarben"
L["Tint Vista border and text (coords, time, FPS/MS labels) with your class colour. Numbers use the configured colour."]= "Vista-Rahmen und Text (Koords, Zeit, FPS/MS) mit Klassenfarbe einfärben. Zahlen nutzen die konfigurierte Farbe."
L["Text Positions"]                                                     = "Text-Positionen"
L["Drag text elements to reposition them. Lock to prevent accidental movement."]= "Textelemente ziehen zum Verschieben. Sperren verhindert versehentliche Bewegung."
L["Lock zone text position"]                                            = "Zonentext-Position sperren"
L["When on, the zone text cannot be dragged."]                          = "An: Zonentext nicht verschiebbar."
L["Lock coordinates position"]                                          = "Koordinaten-Position sperren"
L["When on, the coordinates text cannot be dragged."]                   = "An: Koordinaten-Text nicht verschiebbar."
L["Lock time position"]                                                 = "Zeit-Position sperren"
L["When on, the time text cannot be dragged."]                          = "An: Zeit-Text nicht verschiebbar."
L["Performance text position"]                                          = "Position des Performance-Texts"
L["Place the FPS/latency text above or below the minimap."]             = "FPS/ Latenz-Text über oder unter der Minikarte platzieren."
L["Lock performance text position"]                                     = "Position des Performance-Texts sperren"
L["When on, the FPS/latency text cannot be dragged."]                   = "An: FPS/ Latenz-Text kann nicht gezogen werden."
L["Lock difficulty text position"]                                      = "Schwierigkeits-Text-Position sperren"
L["When on, the difficulty text cannot be dragged."]                    = "An: Schwierigkeits-Text nicht verschiebbar."
L["Button Positions"]                                                   = "Button-Positionen"
L["Drag buttons to reposition them. Lock to prevent movement."]         = "Buttons ziehen zum Verschieben. Sperren verhindert Bewegung."
L["Lock Zoom In button"]                                                = "Vergrößern-Button sperren"
L["Prevent dragging the + zoom button."]                                = "Vergrößern-Button nicht verschiebbar."
L["Lock Zoom Out button"]                                               = "Verkleinern-Button sperren"
L["Prevent dragging the - zoom button."]                                = "Verkleinern-Button nicht verschiebbar."
L["Lock Tracking button"]                                               = "Verfolgen-Button sperren"
L["Prevent dragging the tracking button."]                              = "Verfolgen-Button nicht verschiebbar."
L["Lock Calendar button"]                                               = "Kalender-Button sperren"
L["Prevent dragging the calendar button."]                              = "Kalender-Button nicht verschiebbar."
L["Lock Queue button"]                                                  = "Warteschlangen-Button sperren"
L["Prevent dragging the queue status button."]                          = "Warteschlangen-Button nicht verschiebbar."
L["Lock Mail indicator"]                                                = "Post-Symbol sperren"
L["Prevent dragging the mail icon."]                                    = "Post-Symbol nicht verschiebbar."
L["Disable queue handling"]                                             = "Warteschlangen-Verwaltung deaktivieren"
L["Disable queue button handling"]                                      = "Warteschlangen-Button-Verwaltung deaktivieren"
L["Turn off all queue button anchoring (use if another addon manages it)."]= "Alle Warteschlangen-Button-Ankerungen deaktivieren (wenn anderes Addon verwaltet)."
L["Button Sizes"]                                                       = "Button-Größen"
L["Adjust the size of minimap overlay buttons."]                        = "Größe der Minikarten-Overlay-Buttons anpassen."
L["Tracking button size"]                                               = "Verfolgen-Button-Größe"
L["Size of the tracking button (pixels)."]                              = "Größe des Verfolgen-Buttons (Pixel)."
L["Calendar button size"]                                               = "Kalender-Button-Größe"
L["Size of the calendar button (pixels)."]                              = "Größe des Kalender-Buttons (Pixel)."
L["Queue button size"]                                                  = "Warteschlangen-Button-Größe"
L["Size of the queue status button (pixels)."]                          = "Größe des Warteschlangen-Buttons (Pixel)."
L["Zoom button size"]                                                   = "Zoom-Button-Größe"
L["Size of the zoom in / zoom out buttons (pixels)."]                   = "Größe der Zoom-Buttons (Pixel)."
L["Mail indicator size"]                                                = "Post-Symbol-Größe"
L["Size of the new mail icon (pixels)."]                                = "Größe des Post-Symbols (Pixel)."
L["Addon button size"]                                                  = "Addon-Button-Größe"
L["Size of collected addon minimap buttons (pixels)."]                  = "Größe der gesammelten Addon-Minikarten-Buttons (Pixel)."

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
L["Addon Buttons"]                                                      = "Addon-Buttons"
L["Minimap Addon Buttons"]                                              = "Minikarten-Addon-Buttons"
L["Button Management"]                                                  = "Button-Verwaltung"
L["Manage addon minimap buttons"]                                       = "Addon-Minikarten-Buttons verwalten"
L["When on, Vista takes control of addon minimap buttons and groups them by the selected mode."]= "An: Vista übernimmt Addon-Minikarten-Buttons und gruppiert nach gewähltem Modus."
L["Button mode"]                                                        = "Button-Modus"
L["How addon buttons are presented: hover bar below minimap, panel on right-click, or floating drawer button."]= "Darstellung der Addon-Buttons: Mausüber-Leiste, Rechtsklick-Panel oder schwebender Schubladen-Button."
L["Always show bar"]                                                    = "Leiste immer anzeigen"
L["Always show mouseover bar (for positioning)"]                        = "Mausüber-Leiste immer anzeigen (zum Positionieren)"
L["Keep the mouseover bar visible at all times so you can reposition it. Disable when done."]= "Mausüber-Leiste immer sichtbar für Positionierung. Deaktivieren wenn fertig."
L["Disable when done."]                                                 = "Deaktivieren wenn fertig."
L["Mouseover bar"]                                                      = "Mausüber-Leiste"
L["Right-click panel"]                                                  = "Rechtsklick-Panel"
L["Floating drawer"]                                                    = "Schwebende Schublade"
L["Lock drawer button position"]                                        = "Schubladen-Button-Position sperren"
L["Prevent dragging the floating drawer button."]                       = "Schubladen-Button nicht verschiebbar."
L["Lock mouseover bar position"]                                        = "Mausüber-Leisten-Position sperren"
L["Prevent dragging the mouseover button bar."]                         = "Mausüber-Leiste nicht verschiebbar."
L["Lock right-click panel position"]                                    = "Rechtsklick-Panel-Position sperren"
L["Prevent dragging the right-click panel."]                            = "Rechtsklick-Panel nicht verschiebbar."
L["Buttons per row/column"]                                             = "Buttons pro Zeile/Spalte"
L["Controls how many buttons appear before wrapping. For left/right direction this is columns; for up/down it is rows."]= "Anzahl Buttons vor Umbruch. Links/Rechts = Spalten; Oben/Unten = Zeilen."
L["Expand direction"]                                                   = "Erweiterungsrichtung"
L["Direction buttons fill from the anchor point. Left/Right = horizontal rows. Up/Down = vertical columns."]= "Richtung: Buttons füllen vom Anker. Links/Rechts = Zeilen; Oben/Unten = Spalten."
L["Right"]                                                              = "Rechts"
L["Left"]                                                               = "Links"
L["Down"]                                                               = "Unten"
L["Up"]                                                                 = "Oben"
L["Mouseover Bar Appearance"]                                           = "Mausüber-Leisten-Aussehen"
L["Background and border for the mouseover button bar."]                = "Hintergrund und Rahmen für die Mausüber-Button-Leiste."
L["Backdrop color"]                                                     = "Hintergrundfarbe"
L["Background color of the mouseover button bar (use alpha to control transparency)."]= "Hintergrundfarbe der Mausüber-Leiste (Alpha für Transparenz)."
L["Show bar border"]                                                    = "Leisten-Rahmen anzeigen"
L["Show a border around the mouseover button bar."]                     = "Rahmen um die Mausüber-Leiste anzeigen."
L["Bar border color"]                                                   = "Leisten-Rahmenfarbe"
L["Border color of the mouseover button bar."]                          = "Rahmenfarbe der Mausüber-Leiste."
L["Bar background color"]                                               = "Leisten-Hintergrundfarbe"
L["Panel background color."]                                            = "Panel-Hintergrundfarbe."
L["Close / Fade Timing"]                                                = "Schließen / Einblend-Timing"
L["Mouseover bar — close delay (seconds)"]                              = "Mausüber-Leiste — Schließ-Verzögerung (Sekunden)"
L["How long (in seconds) the bar stays visible after the cursor leaves. 0 = instant fade."]= "Wie lange (Sekunden) die Leiste sichtbar bleibt nach Verlassen. 0 = sofortiges Ausblenden."
L["Right-click panel — close delay (seconds)"]                          = "Rechtsklick-Panel — Schließ-Verzögerung (Sekunden)"
L["How long (in seconds) the panel stays open after the cursor leaves. 0 = never auto-close (close by right-clicking again)."]= "Wie lange (Sekunden) das Panel offen bleibt nach Verlassen. 0 = nie automatisch schließen."
L["Floating drawer — close delay (seconds)"]                            = "Schwebende Schublade — Schließ-Verzögerung (Sekunden)"
L["Drawer close delay"]                                                 = "Schublade-Schließ-Verzögerung"
L["How long (in seconds) the drawer panel stays open after clicking away. 0 = never auto-close (close only by clicking the drawer button again)."]= "Wie lange (Sekunden) die Schublade offen bleibt nach Wegklicken. 0 = nie automatisch schließen."
L["Mail icon blink"]                                                    = "Post-Symbol blinken"
L["When on, the mail icon pulses to draw attention. When off, it stays at full opacity."]= "An: Post-Symbol pulsiert. Aus: volle Deckkraft."
L["Panel Appearance"]                                                   = "Panel-Aussehen"
L["Colors for the drawer and right-click button panels."]               = "Farben für Schublade und Rechtsklick-Panels."
L["Panel background color"]                                             = "Panel-Hintergrundfarbe"
L["Background color of the addon button panels."]                       = "Hintergrundfarbe der Addon-Button-Panels."
L["Panel border color"]                                                 = "Panel-Rahmenfarbe"
L["Border color of the addon button panels."]                           = "Rahmenfarbe der Addon-Button-Panels."
L["Managed buttons"]                                                    = "Verwaltete Buttons"
L["When off, this button is completely ignored by this addon."]         = "Aus: Dieser Button wird vom Addon ignoriert."
L["(No addon buttons detected yet)"]                                    = "(Noch keine Addon-Buttons erkannt)"
L["Visible buttons (check to include)"]                                 = "Sichtbare Buttons (zum Einbinden ankreuzen)"
L["(No addon buttons detected yet — open your minimap first)"]          = "(Noch keine Addon-Buttons erkannt — öffnen Sie zuerst Ihre Minikarte)"



