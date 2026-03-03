if GetLocale() ~= "deDE" then return end

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
L["Focus"]                                                          = "Fokus konfigurieren"
L["Presence"]                                                       = "Benachrichtigungen konfigurieren"
L["Other"]                                                          = "Sonstiges"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["Quest types"]                                                    = "Questtypen"
L["Element overrides"]                                              = "Elementübersteuerung"
L["Per category"]                                                   = "Pro Kategorie"
L["Grouping Overrides"]                                             = "Gruppenübersteuerung"
L["Other colors"]                                                   = "Weitere Farben"

-- =====================================================================
-- OptionsPanel.lua — Color row labels (collapsible group sub-rows)
-- =====================================================================
L["Section"]                                                        = "Abschnitt"
L["Title"]                                                          = "Titel"
L["Zone"]                                                           = "Zone"
L["Objective"]                                                      = "Ziel"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["Ready to Turn In overrides base colours"]                        = "Abgabereif überschreibt Basis-Farben"
L["Ready to Turn In uses its colours for quests in that section."]  = "Abgabereife Quests verwenden ihre Farben in diesem Abschnitt."
L["Current Zone overrides base colours"]                            = "Aktuelle Zone überschreibt Basis-Farben"
L["Current Zone uses its colours for quests in that section."]      = "Quests der aktuellen Zone verwenden ihre Farben in diesem Abschnitt."
L["Use distinct color for completed objectives"]                    = "Abgeschlossene Ziele hervorheben"
L["When on, completed objectives (e.g. 1/1) use the color below; when off, they use the same color as incomplete objectives."] = "An: abgeschlossene Ziele (z.B. 1/1) nutzen die Farbe unten. Aus: gleiche Farbe wie unvollständige Ziele."
L["Completed objective"]                                           = "Abgeschlossenes Ziel"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["Reset"]                                                          = "Zurücksetzen"
L["Reset quest types"]                                              = "Questtypen zurücksetzen"
L["Reset overrides"]                                                = "Übersteuerungen zurücksetzen"
L["Reset to defaults"]                                              = "Auf Standard zurücksetzen"
L["Reset to default"]                                               = "Auf Standard zurücksetzen"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["Search settings..."]                                             = "Einstellungen suchen..."
L["Search fonts..."]                                                = "Schriften suchen..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["Drag to resize"]                                                 = "Ziehen zum Ändern der Größe"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
L["Modules"]                                                        = "Module"
L["Layout"]                                                         = "Layout"
L["Visibility"]                                                     = "Sichtbarkeit"
L["Display"]                                                        = "Anzeige"
L["Features"]                                                       = "Funktionen"
L["Typography"]                                                     = "Typografie"
L["Appearance"]                                                     = "Aussehen"
L["Colors"]                                                         = "Farben"
L["Organization"]                                                   = "Organisation"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["Panel behaviour"]                                                = "Panelverhalten"
L["Dimensions"]                                                     = "Abmessungen"
L["Instance"]                                                       = "Instanz"
L["Combat"]                                                         = "Kampf"
L["Filtering"]                                                      = "Filter"
L["Header"]                                                         = "Kopfzeile"
L["List"]                                                           = "Liste"
L["Spacing"]                                                        = "Abstände"
L["Rare bosses"]                                                    = "Rare Bosse"
L["World quests"]                                                   = "Weltquests"
L["Floating quest item"]                                            = "Schwebendes Quest-Item"
L["Mythic+"]                                                        = "Mythisch+"
L["Achievements"]                                                   = "Erfolge"
L["Endeavors"]                                                      = "Bestrebungen"
L["Decor"]                                                          = "Dekoration"
L["Scenario & Delve"]                                               = "Szenario & Tiefe"
L["Font"]                                                           = "Schriftart"
L["Text case"]                                                      = "Groß-/Kleinschreibung"
L["Shadow"]                                                         = "Schatten"
L["Panel"]                                                          = "Panel"
L["Highlight"]                                                      = "Hervorhebung"
L["Color matrix"]                                                   = "Farbmatrix"
L["Focus order"]                                                    = "Fokus-Reihenfolge"
L["Sort"]                                                           = "Sortierung"
L["Behaviour"]                                                      = "Verhalten"
L["Content Types"]                                                  = "Inhaltstypen"
L["Delves"]                                                         = "Tiefen"
L["Delves & Dungeons"]                                               = "Tiefen & Dungeons"
L["Delve Complete"]                                                 = "Tiefe abgeschlossen"
L["Interactions"]                                                   = "Interaktionen"
L["Tracking"]                                                       = "Verfolgung"
L["Scenario Bar"]                                                   = "Szenario-Leiste"

-- =====================================================================
-- OptionsData.lua Modules
-- =====================================================================
L["Enable Focus module"]                                            = "Fokus-Modul aktivieren"
L["Show the objective tracker for quests, world quests, rares, achievements, and scenarios."] = "Zielverfolger für Quests, Weltquests, Rare Bosse, Erfolge und Szenarien anzeigen."
L["Enable Presence module"]                                         = "Präsenz-Modul aktivieren"
L["Cinematic zone text and notifications (zone changes, level up, boss emotes, achievements, quest updates)."] = "Filmische Zonentexte und Benachrichtigungen (Zonenwechsel, Levelaufstieg, Boss-Emotes, Erfolge, Quest-Updates)."
L["Enable Yield module"]                                            = "Ertrag-Modul aktivieren"
L["Cinematic loot notifications (items, money, currency, reputation)."] = "Filmische Beute-Benachrichtigungen (Items, Gold, Währung, Ruf)."
L["Enable Vista module"]                                            = "Vista-Modul aktivieren"
L["Cinematic square minimap with zone text, coordinates, and button collector."] = "Filmische quadratische Minimap mit Zonentext, Koordinaten und Button-Sammlung."
L["Beta"]                                                           = "Beta"
L["Scaling"]                                                        = "Skalierung"
L["Global UI scale"]                                                = "Globale UI-Skalierung"
L["Scale all sizes, spacings, and fonts by this factor (50–200%). Does not change your configured values."] = "Alle Größen, Abstände und Schriftarten mit diesem Faktor skalieren (50–200%). Ändert keine konfigurierten Werte."
L["Per-module scaling"]                                             = "Skalierung pro Modul"
L["Override the global scale with individual sliders for each module."] = "Globale Skalierung durch Einzelschieber je Modul ersetzen."
L["Focus scale"]                                                    = "Fokus-Skalierung"
L["Scale for the Focus objective tracker (50–200%)."]               = "Skalierung des Fokus-Zielverfolgers (50–200%)."
L["Presence scale"]                                                 = "Präsenz-Skalierung"
L["Scale for the Presence cinematic text (50–200%)."]               = "Skalierung des filmischen Präsenz-Textes (50–200%)."
L["Vista scale"]                                                    = "Vista-Skalierung"
L["Scale for the Vista minimap module (50–200%)."]                  = "Skalierung des Vista-Minimap-Moduls (50–200%)."
L["Insight scale"]                                                  = "Insight-Skalierung"
L["Scale for the Insight tooltip module (50–200%)."]                = "Skalierung des Insight-Tooltip-Moduls (50–200%)."
L["Yield scale"]                                                    = "Ertrag-Skalierung"
L["Scale for the Yield loot toast module (50–200%)."]               = "Skalierung des Ertrag-Beute-Toast-Moduls (50–200%)."
L["Enable Horizon Insight module"]                                  = "Horizon Insight-Modul aktivieren"
L["Cinematic tooltips with class colors, spec display, and faction icons."] = "Filmische Tooltips mit Klassenfarben, Spez-Anzeige und Fraktionssymbolen."
L["Horizon Insight"]                                                = "Horizon Insight"
L["Insight"]                                                        = "Insight"
L["Tooltip anchor mode"]                                            = "Tooltip-Anker-Modus"
L["Where tooltips appear: follow cursor or fixed position."]        = "Wo Tooltips erscheinen: Cursor folgen oder feste Position."
L["Cursor"]                                                         = "Cursor"
L["Fixed"]                                                          = "Fest"
L["Show anchor to move"]                                            = "Anker zum Verschieben anzeigen"
L["Show draggable frame to set fixed tooltip position. Drag, then right-click to confirm."] = "Ziehbaren Rahmen zur festen Tooltip-Position anzeigen. Ziehen, dann Rechtsklick zum Bestätigen."
L["Reset tooltip position"]                                         = "Tooltip-Position zurücksetzen"
L["Reset fixed position to default."]                               = "Feste Position auf Standard zurücksetzen."
L["Yield"]                                                          = "Ertrag"
L["General"]                                                        = "Allgemein"
L["Position"]                                                       = "Position"
L["Reset position"]                                                 = "Position zurücksetzen"
L["Reset loot toast position to default."]                          = "Beute-Toast-Position auf Standard zurücksetzen."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["Lock position"]                                                  = "Position sperren"
L["Prevent dragging the tracker."]                                  = "Verschieben des Zielverfolgers verhindern."
L["Grow upward"]                                                    = "Nach oben wachsen"
L["Grow-up header"]                                                 = "Aufwärts-Header"
L["When growing upward: keep header at bottom, or at top until collapsed."] = "Beim Aufwärtswachsen: Header unten lassen oder oben bis zum Einklappen."
L["Header at bottom"]                                               = "Header unten"
L["Header slides on collapse"]                                      = "Header gleitet beim Einklappen"
L["Anchor at bottom so the list grows upward."]                     = "Unten verankern, damit die Liste nach oben wächst."
L["Start collapsed"]                                                = "Eingeklappt starten"
L["Start with only the header shown until you expand."]             = "Nur mit Kopfzeile starten bis zum Aufklappen."
L["Panel width"]                                                    = "Panel-Breite"
L["Tracker width in pixels."]                                       = "Breite des Zielverfolgers in Pixeln."
L["Max content height"]                                             = "Max. Inhaltshöhe"
L["Max height of the scrollable list (pixels)."]                    = "Maximale Höhe der scrollbaren Liste (Pixel)."

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua
-- =====================================================================
L["OBJECTIVES"]                                                     = "ZIELE"
L["Options"]                                                        = "Optionen"
L["Discovered"]                                                     = "Entdeckt"
L["Refresh"]                                                        = "Aktualisieren"
L["Best-effort only. Some unaccepted quests are not exposed until you interact with NPCs or meet phasing conditions."] = "Nur bestmöglich. Manche nicht angenommenen Quests werden erst nach NPC-Interaktion oder Phasenbedingungen angezeigt."
L["Unaccepted Quests - %s (map %s) - %d match(es)"]                 = "Nicht angenommene Quests - %s (Karte %s) - %d Treffer"

L["LEVEL UP"]                                                       = "LEVELAUFSTIEG"
L["You have reached level 80"]                                      = "Ihr habt Stufe 80 erreicht"
L["You have reached level %s"]                                      = "Ihr habt Stufe %s erreicht"
L["ACHIEVEMENT EARNED"]                                             = "ERFOLG ERLANGT"
L["QUEST COMPLETE"]                                                 = "QUEST ABGESCHLOSSEN"
L["QUEST ACCEPTED"]                                                 = "QUEST ANGENOMMEN"
L["WORLD QUEST"]                                                    = "WELTQUEST"
L["WORLD QUEST ACCEPTED"]                                           = "WELTQUEST ANGENOMMEN"
L["QUEST UPDATE"]                                                   = "QUEST-UPDATE"
L["New Quest"]                                                      = "Neue Quest"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["DUNGEON"]           = "DUNGEON"
L["RAID"]              = "RAID"
L["DELVES"]            = "Tiefen"
L["SCENARIO EVENTS"]   = "Szenario-Ereignisse"
L["AVAILABLE IN ZONE"] = "IN ZONE VERFÜGBAR"
L["EVENTS IN ZONE"]    = "Ereignisse in Zone"
L["CURRENT ZONE"]      = "AKTUELLE ZONE"
L["CAMPAIGN"]          = "KAMPAGNE"
L["IMPORTANT"]         = "WICHTIG"
L["LEGENDARY"]         = "LEGENDÄR"
L["WORLD QUESTS"]      = "WELTQUESTS"
L["WEEKLY QUESTS"]     = "Wochenquests"
L["DAILY QUESTS"]      = "Tagesquests"
L["RARE BOSSES"]       = "RARE BOSSE"
L["ACHIEVEMENTS"]      = "ERFOLGE"
L["ENDEAVORS"]         = "BESTREBUNGEN"
L["DECOR"]             = "DEKORATION"
L["QUESTS"]            = "QUESTS"
L["READY TO TURN IN"]  = "ABGABEBEREIT"

-- =====================================================================
-- Presence test commands
-- =====================================================================
L["Presence test commands:"]                                        = "Präsenz-Testbefehle:"
L["  /h presence         - Show help + test current zone"]          = "  /h presence         - Hilfe + aktuelle Zone testen"
L["  /h presence zone     - Test Zone Change"]                      = "  /h presence zone     - Zonenwechsel testen"
L["  /h presence subzone  - Test Subzone Change"]                   = "  /h presence subzone  - Unterzonenwechsel testen"
L["  /h presence discover - Test Zone Discovery"]                   = "  /h presence discover - Zonenentdeckung testen"
L["  /h presence level    - Test Level Up"]                         = "  /h presence level    - Levelaufstieg testen"
L["  /h presence boss     - Test Boss Emote"]                       = "  /h presence boss     - Boss-Emote testen"
L["  /h presence ach      - Test Achievement"]                      = "  /h presence ach      - Erfolg testen"
L["  /h presence accept   - Test Quest Accepted"]                   = "  /h presence accept   - Quest angenommen testen"
L["  /h presence wqaccept - Test World Quest Accepted"]             = "  /h presence wqaccept - Weltquest angenommen testen"
L["  /h presence scenario - Test Scenario Start"]                   = "  /h presence scenario - Szenario-Start testen"
L["  /h presence quest    - Test Quest Complete"]                   = "  /h presence quest    - Quest abgeschlossen testen"
L["  /h presence wq       - Test World Quest"]                      = "  /h presence wq       - Weltquest testen"
L["  /h presence update   - Test Quest Update"]                     = "  /h presence update   - Quest-Update testen"
L["  /h presence achprogress - Test Achievement Progress"]          = "  /h presence achprogress - Erfolgsfortschritt testen"
L["  /h presence all      - Demo reel (all types)"]                 = "  /h presence all      - Demo (alle Typen)"
L["  /h presence debug    - Dump state to chat"]                    = "  /h presence debug    - Status im Chat ausgeben"
L["  /h presence debuglive - Toggle live debug panel (log as events happen)"] = "  /h presence debuglive - Live-Debug-Panel umschalten"
L["Presence: Playing demo reel (all notification types)..."]        = "Präsenz: Demo wird abgespielt (alle Benachrichtigungstypen)..."

-- =====================================================================
-- Dropdown options
-- =====================================================================
L["None"]                                                           = "Keine"
L["Outline"]                                                        = "Umriss"
L["Thick Outline"]                                                  = "Dicker Umriss"
L["Top"]                                                            = "Oben"
L["Bottom"]                                                         = "Unten"
L["Lower Case"]                                                     = "Kleinbuchstaben"
L["Upper Case"]                                                     = "Großbuchstaben"
L["Proper"]                                                         = "Erster Buchstabe groß"
L["Custom"]                                                         = "Benutzerdefiniert"
L["Use global font"]                                                = "Globale Schriftart verwenden"
L["Arrow"]                                                          = "Pfeil"
L["Fade"]                                                           = "Verblassen"
L["Show"]                                                           = "Anzeigen"
L["Hide"]                                                           = "Verbergen"

-- =====================================================================
-- Additional common strings (extend as needed)
-- =====================================================================
L["Position & layout"]                                              = "Position & Layout"
L["Dimensions"]                                                     = "Abmessungen"
L["Appearance"]                                                     = "Aussehen"
L["Instance"]                                                       = "Instanz"
L["In dungeon"]                                                     = "In Dungeon"
L["Show tracker in party dungeons."]                                = "Zielverfolger in Gruppen-Dungeons anzeigen."
L["Profiles"]                                                       = "Profile"
L["Current profile"]                                                = "Aktuelles Profil"
L["Select the profile currently in use."]                           = "Aktuell verwendetes Profil auswählen."
L["Vista"]                                                          = "Vista"
L["Find a Group"]                                                   = "Gruppe finden"
L["Click to search for a group for this quest."]                    = "Klicken, um eine Gruppe für diese Quest zu suchen."
