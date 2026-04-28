if GetLocale() ~= "deDE" then return end

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = setmetatable({}, { __index = addon.L })
addon.L = L
addon.StandardFont = UNIT_NAME_FONT

-- =====================================================================
-- Branding — Horizon Suite, module names, and third-party brand names
-- Never user copy; these are product/brand identifiers only.
-- =====================================================================
-- L["NAME_ADDON"]                                            = "Horizon Suite"
-- L["NAME_ADDON_OBJECTIVES"]                                 = "Focus"
-- L["NAME_ADDON_TOASTS"]                                     = "Presence"
-- L["NAME_ADDON_MINIMAP"]                                    = "Vista"
-- L["NAME_ADDON_TOOLTIPS"]                                   = "Insight"
-- L["NAME_ADDON_CHARACTER"]                                  = "Essence"
-- L["NAME_ADDON_LOOT"]                                       = "Cache"
-- L["NAME_ADDON_C-----S"]                                    = "Meridian"
-- L["NAME_ADDON_DASHBOARD"]                                  = "Axis"
-- L["NAME_DISCORD"]                                          = "Discord"
-- L["NAME_KO_FI"]                                            = "Ko-fi"
-- L["NAME_PATREON"]                                          = "Patreon"
L["NAME_GITHUB"]                                              = "GitLab"
-- L["NAME_CURSEFORGE"]                                       = "CurseForge"
-- L["NAME_WAGO"]                                             = "Wago"
-- L["NAME_TOMTOM"]                                           = "TomTom"
L["OTHER"]                                                    = "Andere"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["QUEST_TYPES"]                                              = "Quest-Typen"
L["ELEMENT_OVERRIDES"]                                        = "Eintragsübersteuerung"
L["PER_CATEGORY"]                                             = "Pro Kategorie"
L["GROUPING_OVERRIDES"]                                       = "Gruppenübersteuerung"
L["SECTION_OVERRIDES"]                                        = "Abschnittsübersteuerung"
L["OTHER_COLOURS"]                                            = "Weitere Farben"

-- =====================================================================
-- OptionsPanel.lua — Colour row labels (collapsible group sub-rows)
-- =====================================================================
L["FOCUS_SECTION"]                                            = "Abschnitt"
L["FOCUS_TITLE"]                                              = "Titel"
-- L["FOCUS_ZONE"]                                            = "Zone"
L["FOCUS_OBJECTIVE"]                                          = "Ziel"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["FOCUS_READY_TURN_OVERRIDES_BASE_COLOURS"]                  = "Abgabebereit überschreibt Basisfarben"
L["FOCUS_READY_TURN_COLOURS_QUESTS"]                          = "Abgabebereite Quests verwenden ihre Farben in diesem Abschnitt."
L["FOCUS_CURRENT_ZONE_OVERRIDES_BASE_COLOURS"]                = "Aktuelle Zone überschreibt Basisfarben"
L["FOCUS_CURRENT_ZONE_SECTION_COLOURS"]                       = "Quests der aktuellen Zone verwenden ihre Farben in diesem Abschnitt."
L["FOCUS_CURRENT_QUEST_OVERRIDES_BASE_COLOURS"]               = "Aktuelle Quest überschreibt Basisfarben"
L["FOCUS_CURRENT_QUEST_SECTION_COLOURS"]                      = "Quests der aktuellen Quest verwenden ihre Farben in diesem Abschnitt."
L["FOCUS_DISTINCT_COLOUR_COMPLETED_OBJECTIVES"]               = "Abgeschlossene Ziele hervorheben"
L["FOCUS_COMPLETED_OBJECTIVES_COLOURS_CHANGE"]                = "EIN: Abgeschlossene Ziele (z.B. 1/1) nutzen die Farbe unten. AUS: Gleiche Farbe wie unvollständige Ziele."
L["FOCUS_COMPLETED_OBJECTIVE"]                                = "Abgeschlossenes Ziel"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["FOCUS_RESET"]                                              = "Zurücksetzen"
L["FOCUS_RESET_QUEST_TYPES"]                                  = "Quest-Typen zurücksetzen"
L["FOCUS_RESET_OVERRIDES"]                                    = "Übersteuerungen zurücksetzen"
L["FOCUS_RESET_DEFAULTS"]                                     = "Alle auf Standard zurücksetzen"
L["FOCUS_RESET_TO_DEFAULTS"]                                  = "Auf Standard zurücksetzen"
L["FOCUS_RESET_DEFAULT"]                                      = "Auf Standard zurücksetzen"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["FOCUS_SEARCH_SETTINGS"]                                    = "Einstellungen durchsuchen..."
L["SEARCH_FONTS"]                                             = "Schriftarten durchsuchen..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["FOCUS_DRAG_RESIZE"]                                        = "Ziehen für Größenänderung"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
L["PROFILES"]                                                 = "Profile"
L["MODULES"]                                                  = "Module"
L["MODULE_TOGGLES"]                                           = "Modulsteuerung"
L["MODULE_PREVIEW_DISCLAIMER"]                                = "Dieses Modul befindet sich in einem frühen Vorschaustatus (Alpha). Von der täglichen Nutzung ist wegen möglicher Fehler und unvollständiger Funktionalität abzuraten."
L["AXIS_MODULE_NAME_DISPLAY"]                                 = "Stil der Modulbezeichnungen"
L["AXIS_MODULE_NAME_DISPLAY_DESC"]                            = "Modulbezeichnungen im Einstellungsfenster und Suchfilter."
-- L["AXIS_MODULE_NAME_HORIZON"]                              = "Horizon"
L["AXIS_MODULE_NAME_SUBTITLE"]                                = "Untertitel"
L["AXIS_MODULE_NAME_SIMPLE"]                                  = "Schlicht"
-- L["AXIS_MODULE_NAME_SIMPLE_DASHBOARD"]                     = "Settings"
-- L["AXIS_MODULE_NAME_SIMPLE_OBJECTIVES"]                    = "Objective Tracker"
-- L["AXIS_MODULE_NAME_SIMPLE_NOTIFICATIONS"]                 = "Notifications"
-- L["AXIS_MODULE_NAME_SIMPLE_MINIMAP"]                       = "Minimap"
-- L["AXIS_MODULE_NAME_SIMPLE_TOOLTIPS"]                      = "Tooltips"
-- L["AXIS_MODULE_NAME_SIMPLE_LOOT"]                          = "Loot Toasts"
-- L["AXIS_MODULE_NAME_SIMPLE_CHARACTER"]                     = "Character Sheet"
-- L["AXIS_MODULE_NAME_SIMPLE_C-----S"]                       = "Meridian"
L["MODULE_RELOAD_HINT"]                                       = "Lädt das Interface neu, um Moduländerungen anzwuwenden."
-- L["PROFILE_RELOAD_HINT"]                                   = "Reload the interface to finish applying profile changes."
L["RELOAD_UI"]                                                = "UI neuladen"

-- =====================================================================
-- options/dashboard/HomeWelcome.lua — First-run welcome
-- =====================================================================
L["DASH_WHATS_NEW"]                                           = "Änderungen"
L["DASH_FULL_CHANGELOG"]                                      = "Versionshistorie"
L["DASH_WHATS_NEW_UNREAD_SUFFIX"]                             = " (Neu!)"
L["DASH_PATCH_NOTES_HEAD_SUB"]                                = "Versionshistorie und aktuelle Änderungen"
L["DASH_PATCH_NOTES_EMPTY"]                                   = "Keine Änderungshinweise verfügbar."
-- L["DASH_PATCH_NOTES_DISMISS"]                              = "Dismiss"
-- L["DASH_PATCH_NOTES_VIEW_ALL"]                             = "View all patch notes"
L["DASH_WELCOME_TAB"]                                         = "Willkommen"
L["DASH_NEWS_TAB"]                                            = "Neuigkeiten"
L["DASH_SEARCH_TAB"]                                          = "Durchsuchen"
L["DASH_SEARCH_HEAD_SUB"]                                     = "Einstellungen schnell finden"
L["DASH_SEARCH_PLACEHOLDER"]                                  = "Einstellungen durchsuchen..."
L["DASH_SEARCH_EMPTY_HINT"]                                   = "Mindestens zwei Zeichen eingeben, um Einstellungen, Module und Optionen zu durchsuchen."
L["DASH_SEARCH_NO_RESULTS"]                                   = "Keine Übereinstimmungen gefunden. Versuche es mit anderen Begriffen."
L["DASH_SEARCH_FILTER_ALL"]                                   = "Alle"
L["DASH_SEARCH_FILTER_TOOLTIP"]                               = "Suche auf ein Modul beschränken."
L["DASH_SEARCH_NO_RESULTS_IN_MODULE"]                         = "Keine Übereinstimmungen in %s gefunden. Suche in allen Modulen oder nach anderen Begriffen."
L["DASH_NEWS_HEAD_SUB"]                                       = "Neueste Updates und Community-Highlights"
L["DASH_NEWS_BADGE_NEW"]                                      = "Neu"
-- L["DASH_NEWS_BADGE_HIGHLIGHT"]                             = "Highlight"
L["DASH_NEWS_EYEBROW_FEATURE"]                                = "Funktionsupdate"
-- L["DASH_NEWS_EYEBROW_COMMUNITY"]                           = "Community"
-- L["DASH_NEWS_EYEBROW_ROADMAP"]                             = "Roadmap"
L["DASH_NEWS_EYEBROW_GET_STARTED"]                            = "Loslegen"
L["DASH_NEWS_CTA_OPEN_FOCUS"]                                 = "Focus-Einstellungen öffnen"
L["DASH_NEWS_CTA_VIEW_ARTIST"]                                = "Link zum Künstler anzeigen"
L["DASH_NEWS_CTA_OPEN_PATCH_NOTES"]                           = "Änderungshinweise anzeigen"
L["DASH_NEWS_EDITORIAL_FOOTER_PREFIX"]                        = "Neuigkeitenbereich • Redaktionelles Layout"
L["DASH_NEWS_EDITORIAL_FOOTER_LINK"]                          = "Änderungshinweise"
L["DASH_NEWS_CTA_OPEN_GUIDE"]                                 = "Schnelleinstieg öffnen"
L["DASH_NEWS_FOCUS_CLICK_PROFILE_TITLE"]                      = "Blizzard+ ist nun das Standardklickprofil"
L["DASH_NEWS_FOCUS_CLICK_PROFILE_TAGLINE"]                    = "Focus orientiert sich nun stärker an der gewohnten Bedienung von Blizzard, bietet aber weiterhin die praktischen Funktionen von Horizon."
L["DASH_NEWS_FOCUS_CLICK_PROFILE_BODY"]                       = "Die aktualisierte Voreinstellung sorgt für ein übersichtlicheres Standard-Interaktionsmodell mit Quests. Für Anpassungen gehe zu Focus > Interaktionen. Halte Ausschau nach Horizon+ und erweiterten benutzerdefinierten Tastenkombinationen, die als Nächstes folgen."
L["DASH_NEWS_FOCUS_CLICK_PROFILE_META"]                       = "Focus • Interaktions-Voreinstellung • Jetzt verfügbar"
L["DASH_NEWS_GRADIENT_TOOLTIPS_TITLE"]                        = "Tooltip-Schriftverläufe, Dynamische Focus-Tooltips, ein Neu!-Indikator und Optionen für Modulbezeichnungen"
L["DASH_NEWS_GRADIENT_TOOLTIPS_TAGLINE"]                      = "Überraschung! Passe Insight-Tooltips mit Schriftfarbverläufen basierend Klassenfarben und Gegenstandsqualität. Hervorhebung kürzlich implementierter Funktionen mit einem Neu!-Indikator. Dynamische Tooltip-Positionierung in Focus auf Basis der Bildschirmposition."
L["DASH_NEWS_GRADIENT_TOOLTIPS_BODY"]                         = "Zusätzlich haben wir eine neue Einstellung für den |cffaaaaaaAxis > Modulbezeichnungsstil|r hinzugefügt: Horizon (Codenamen, Standard), Untertiel (z.B., Vista – Minikarte) oder Schlicht (vereinfachte, leicht verständliche Bezeichnungen)."
L["DASH_NEWS_GRADIENT_TOOLTIPS_META"]                         = "Insight • Dynamische Tooltips • Schriftfarbverläufe • Jetzt verfügbar"
L["DASH_NEWS_CLASS_ICONS_TITLE"]                              = "Ein vollständiges Horizon-Klassensymbolset ist jetzt enthalten"
L["DASH_NEWS_CLASS_ICONS_BODY"]                               = "Stelle unter Axis > Globale Einstellungen den Klassensymbolstil auf Horizon, um das neue Design in der gesamten Suite zu verwenden. Das Dashboard zeigt nun Aktualisierungen wie eine Veröffentlichung und nicht wie eine Fußnote an."
L["DASH_NEWS_CLASS_ICONS_META"]                               = "Axis • Globale Einstellungen • Kunst von Gabriel C"
L["DASH_NEWS_COMING_SOON_TITLE"]                              = "Weitere kuratierte Aktualisierungen werden hier folgen"
L["DASH_NEWS_COMING_SOON_BODY"]                               = "Dieser Bereich ist nun für vorgestellte Geschichten, Veröffentlichungs-Highlights und kleinere Folgeeinträge strukturiert. Bis die nächste Aktualisierungsrunde erfolgt, sind die Änderungshinweise weiterhin der schnellste Weg, um alle Neuerungen im Blick zu behalten."
L["DASH_NEWS_HANDHELD_TITLE"]                                 = "Handheld-Unterstützung ist in Arbeit"
L["DASH_NEWS_HANDHELD_BODY"]                                  = "Wir planen eine bessere Unterstützung für kleinere Bildschirme und das Spielen auf Mobilgeräten – Anpassungsfähige Layouts, sinnvolle Standardeinstellungen bei verkleinerter Benutzeroberfläche und weniger überfüllte Bedienfelder. Details dazu werden schrittweise in den |cffaaaaaaÄnderungshinweisen|r veröffentlicht."
L["DASH_NEWS_COMING_SOON_META"]                               = "Neuigkeitenbereich • Redaktionelles Layout • Im Addon kuratiert"
L["DASH_NEWS_QUICK_START_TITLE"]                              = "Noch mal eine schnelle Tour?"
L["DASH_NEWS_QUICK_START_BODY"]                               = "Der Schnelleinstieg ist nach wie vor ein nützlicher Begleiter für Neuigkeiten: Nutze ihn, wenn du einen schnellen Überblick darüber haben möchtest, was die einzelnen Module leisten, wo du sie aktivieren kannst und welche Bereiche du nach einem Update zuerst öffnen solltest."
L["DASH_NEWS_QUICK_START_META"]                               = "Leitfaden • Einführung • Immer verfügbar"
L["DASH_WELCOME_TITLE"]                                       = "Willkommen bei der Horizon-Suite"
L["DASH_WELCOME_HEAD_SUB"]                                    = "Der Funktionsumfang der Module und wie man sie aktiviert"
L["DASH_WELCOME_INTRO"]                                       = "Die Horizon Suite ist modular aufgebaut – Aktiviere die Komponenten, die du nutzen möchtest. Das Ein- oder Ausschalten eines Moduls wird beim Interface-Neuladen wirksam. Klick unten auf Mitwirkende oder Lokalisierungen, um die Mitwirkenden und die unterstützten Sprachen anzuschauen. Nutze die Schaltflächen zum Öffnen der Module unter Module oder öffne Axis > Module in der Seitenleiste. Über die Seitenleiste kannst du jederzeit zu dieser Willkommensseite zurückkehren."
L["DASH_WELCOME_HERO_EYEBROW"]                                = "Willkommen"
L["DASH_WELCOME_HERO_TITLE"]                                  = "Eine modulare UI-Suite mit auswählbaren Komponenten."
L["DASH_WELCOME_HERO_TAGLINE"]                                = "Passe Horizon an - Nutze wahlweise Quest-Verfolger, Benachrichtigungen, Minikarte, Tooltips und/oder Charakterfenster, ohne gleich eine komplette Umgestaltung vornehmen zu müssen."
L["DASH_WELCOME_HERO_BODY"]                                   = "Wähle zunächst die Module aus, die du tatsächlich nutzen möchtest. Orientiere dich dann anhand der folgenden Anleitung, um zu erfahren, wo sich alles befindet. Änderungshinweise und Neuigkeiten sind immer griffbereit, falls du dich schnell dazu informieren möchtest."
L["DASH_WELCOME_START_HERE"]                                  = "Hier loslegen"
L["DASH_WELCOME_CTA_MODULES"]                                 = "Module öffnen"
L["DASH_WELCOME_CTA_PATCH_NOTES"]                             = "Änderungshinweise ansehen"
L["DASH_WELCOME_CTA_NEWS"]                                    = "Neuigkeiten ansehen"
L["DASH_WELCOME_ACTION_MODULES_TITLE"]                        = "Wähle deine gewünschten Horizon-Komponenten"
L["DASH_WELCOME_ACTION_MODULES_BODY"]                         = "Nutze den Dashboard-Startbereich, um Module ein- oder auszusschalten. Lade anschließend das Interface neu um größere Konfigurationsänderungen wirksam werden zu lassen."
L["DASH_WELCOME_ACTION_UPDATES_TITLE"]                        = "Halte dich über Änderungen auf den Laufenden"
L["DASH_WELCOME_ACTION_UPDATES_BODY"]                         = "Änderungshinweise und Neuigkeiten sind der schnellste Weg, um neue Voreinstellungen, Kunst, Optimierungen und Muduländerungen zwischen Addon-Updates zu verfolgen."
L["DASH_WELCOME_ACTION_NEWS_TITLE"]                           = "Schau dir redaktionelle Aktualisierungen an"
L["DASH_WELCOME_ACTION_NEWS_BODY"]                            = "Neuigkeiten über Stories, Anmerkungen zur Roadmap, Kunst-Highlights und kleinere kuratierte Aktualisierungen an einem Ort."
L["DASH_WELCOME_LEARN_BODY"]                                  = "Dieser Abschnitt dient als Leitfaden für Horizon: Was die einzelnen Module leisten, wie man loslegt und wie man durchstartet, sobald die Grundlagen sitzen."
L["DASH_WELCOME_PATH"]                                        = "%s → %s → %s"
L["DASH_WELCOME_FOCUS_BLIZZARD_PLUS_HEADING"]                 = "Blizzard+-Mausklickprofil"
L["DASH_WELCOME_FOCUS_BLIZZARD_PLUS_BODY"]                    = [=[Focus verwendet jetzt standardmäßig |cffffffffBlizzard+|r — Blizzard-ähnliches Klickprofil mit einigen Horizon-Vorzügen. Öffne |cffaaaaaaFocus > Interaktionen|r und gehe zu |cffaaaaaaMausklickprofile|r, um die Voreinstellung anzussehen; |cffffffffHorizon+|r und voll |cffffffffanpassbare|r Belegungen sind in Arbeit.]=]
L["DASH_WELCOME_COMING_SOON_TITLE"]                           = "In Kürze"
L["DASH_WELCOME_COMING_SOON_TAGLINE"]                         = "Neue Einstiegserfahrungen sind auf dem Weg."
L["DASH_WELCOME_COMING_SOON_BODY"]                            = [=[Im Blick behalten — Aktualisierungen werden hier und in den |cffaaaaaaÄnderungshinweisen|r vorgestellt. Tritt unserem |cffaaaaaaDiscord|r für Neuigkeiten und Feedback bei (Links dazu unten).]=]
L["DASH_WELCOME_CLASS_ICONS_HEADING"]                         = "Horizon-Klassensymbole"
L["DASH_WELCOME_CLASS_ICONS_LEAD"]                            = [=[Horizon biete einen mitgelieferten Satz benutzerdefinierter Klassensymbole – Diese können unter |cffaaaaaaHorizon|r → |cffaaaaaaAxis → Globale Einstellungen → Klassensymbolstil aktiviert werden.]=]
L["DASH_WELCOME_CLASS_ICONS_THANK_BOOFULS"]                   = [=[Vielen Dank an Boofuls für dieses Kunstwerk und der Unterstützung, diese Symbole allen zugänglich zu machen.]=]
L["DASH_WELCOME_CLASS_ICONS_CREATED_PREFIX"]                  = "• Erstellt von "
-- L["DASH_WELCOME_CLASS_ICONS_ARTIST_NAME"]                  = "Gabriel C"
L["DASH_WELCOME_CONTRIBUTORS_HEADING"]                        = "Beitragende"
L["DASH_WELCOME_CONTRIBUTORS_BODY"]                           = [=[Danke an alle, die zur Horizon-Suite beigetragen haben:

• Feanor — Entwicklung
• Marthix — Entwicklung
• Swift — Koordinator
• Boofuls — Moderator
• Diva — Innovator
• Rondo Media (CurseForge-Addon)
• Gorak & Aur0r4  — Deutsche Lokalisierung (deDE)
• Aishuu — Französische Lokalisierung (frFR)
• 아즈샤라-두녘 — Koreanische Lokalisierung (koKR)
• Linho-Gallywix — Brasilianisch-Portugiesische Lokalisierung (ptBR)
• allmoon — Chinesische Lokalisierung (zhCN)]=]
L["DASH_WELCOME_SUPPORTERS_HEADING"]                          = "Unterstützer"
L["DASH_WELCOME_SUPPORTERS_BODY"]                             = [=[Vielen Dank an alle, die Horizon Suite über Ko-fi, Patreon und andere Wege unterstützen.]=]
L["DASH_WELCOME_LOCALISATIONS_HEADING"]                       = "Lokalisierungen"
L["DASH_WELCOME_LOCALISATIONS_BODY"]                          = [=[Das Konfigurationsfenster ist lokalisiert für:

• Chinesisch (zhCN) — Localisation/zhCN.lua
• Französisch (frFR) — Localisation/frFR.lua
• Deutsch (deDE) — Localisation/deDE.lua
• Koreanisch (koKR) — Localisation/koKR.lua
• Brasilianisch-Portugiesisch (ptBR) — Localisation/ptBR.lua
• Russisch (ruRU) — Localisation/ruRU.lua
• Spanisch (esES) — Localisation/esES.lua

Contributions for additional locales are welcome via Discord.]=]


-- =====================================================================
-- options/dashboard/ModuleGuide.lua — In-game module quick-start
-- =====================================================================
L["DASH_GUIDE_TAB"]                                           = "Anleitung"
L["DASH_GUIDE_HEAD_SUB"]                                      = "Funktionsumfang der Horizon-Module"
L["DASH_GUIDE_HERO_TITLE"]                                    = "Mit Horizon loslegen"
L["DASH_GUIDE_HERO_TAGLINE"]                                  = "Ein modulares UI-Paket für Quests, Benachrichtigunen, Minikarte und mehr."
L["DASH_GUIDE_HERO_INTRO"]                                    = "Wähle die gewünschten Module aus, passe sie in der Seitenleiste an und lade das Interface neu, wenn ein Modul ein- oder ausgeschaltet wurde. Diese Seite ist immer verfügbar — Du kannst sie jederzeit mit 'Leitfaden' unter der Willkommensnachricht erreichen."
L["DASH_GUIDE_HERO_THEME_PROMPT"]                             = [=[Unter |cffaaaaaaAxis > Globale Einstellungen:|r |cff73b4ff|Hhsdash:classcolours|hKlassenfärbung|h|r für Dashboard und Module einstellen, sowie ein Auswahl an |cff73b4ff|Hhsdash:theme|hDashboard-Motiven|h|r.]=]
L["DASH_GUIDE_HORIZON_HEADING"]                               = "Was ist Horizon?"
L["DASH_GUIDE_HORIZON_BULLETS"]                               = [=[• Axis — Profile, Modulsteuerungen, globale Einstellungen, Typografie und andere Horizon-weite Konfigurationen.
• Focus — Zielverfolger: Quests, Welt-Quests, Szenarien, Rares, Erfolge und mehr in farbigen Abschnitten.
• Presence — Große cinematische Benachrichtigungen für Zonen, Quests, Szenarien, Erfolge, Levelaufstiege und ähnliche Ereignisse.
• Vista — Minikarte: Zonentext, Koordinaten, Uhr und geordnete Minikartenschaltflächen.
• Insight — Tooltips for Spieler, NPCs und Gegenstände (Klassenfärbung, Spezialisierung, Symbole, Extras).
• Cache — Beutebenachrichtigungen und Taschendarstellung.
• Essence — Charakterdatenblatt mit 3D-Modell, Gegenstandsstufe, Werten und Ausrüstungsübersicht.
• Meridian — In Kürze.]=]
L["DASH_GUIDE_MOD_AXIS_BODY"]                                 = "Axis ist das Kontrollzentrum: Verwalte Profile, Module und globale Einstellungen für Klassenfärbung, UI-Skalierung, sowie umfangreiche Typografie- und Erscheingungsbildoptionen, die Horizon-weit gelten. Beginne  hier, wenn du das Addon zum ersten Mal installiert hast oder du den Ressourcenverbrauch durch Deaktivieren von Modulen reduzieren möchtest."
L["DASH_GUIDE_MOD_FOCUS_BODY"]                                = [=[Focus ersetzt den Standard-Quest-Tracker mit einem flexiblen Zielverfolger. Verfolgte Quests, Welt-Quests, Scenarien, seltene Gegner & Schätze, Erfolge, Unterfangen, Dekoration, Rezepte und mehr werden in farbige Abschnitte gruppiert. Dadurch verbessert sich die Übersicht enorm.
Abschnitte werden nur eingeblendet, wenn sie Inhalt haben — Beispielsweise Aktuell (kürzlicher Fortschritt), aktuelle Zone, Bereit zur Abgabe, Welt-/ wöchentliche / tägliche / Beutejagd-, Kampagnen- und Spezial-Quests, Tiefen & Szenarien, seltene Gegner und Schätze, Erfolge, Sammlungen, sowie zeitbegrenzte oder Zonenereignisse.

Unter Focus → Sortierung & Filterung können die Abschnitte neu angeordnet und unter Focus → Inhalt die gewünschten Elementtypen ein- und ausgeblendet werden.]=]
L["DASH_GUIDE_PRESENCE_INTRO"]                                = "Presence zeigt große stilistische Benachrichtigungen für Ereignisse — Zonenwechsel, Quest-Fortschritt, Erfolge, Szenarien und mehr. Inhalt und Typografie der Benachrichtigungen können in den Presence-Einstellungen konfiguriert werden."
L["DASH_GUIDE_PRESENCE_BODY"]                                 = [=[Typische Presence-Benachrichtigungen enthalten:
• Entdeckung von Zonen und Unterzonen beim Betreten neuer Bereiche.
• Angenommene Quests, Zielfortschritt, Quest-Abschluss und Welt-Quest-Fertigstellung.
• Szenariobeginn, -fortschritt und -abschluss (inklusieve Tiefen-ähnlicher Stieldarstellung).
• Errungene Erfolge und optionale Erfolgsfortschritte.
• Stufenaufstieg, Boss-Geschwätz und besiegte seltene Gegner.]=]
L["DASH_GUIDE_PRESENCE_BLIZZARD"]                             = [=[Sobald ein Presence-Typ aktiviert ist, kann Horizon das entsprechende Standard-UI-Element ausblenden. Dadurch werden Duplikatanzeigen vermieden — Beispielsweise Einblendungen zu Zonennamen, Stufenaufstieg, Boss-Geschwätz, Ereignisse, Welt-Quest-Abschlüsse oder Bonusziele. Schalte einen Presence-Typ in den Einstellungen aus, um die Standard-UI-Darstellung für diese Kategorie wieder einzublenden.]=]
L["DASH_GUIDE_MOD_VISTA_BODY"]                                = "Vista verziert die Minikarte mit lesbarem Zonen- und Unterzonentext, optionalen Koordinaten, einer Uhr, sowie eine Leiste, die sämtliche Schlatflächen der Minikarte geordnet sammelt. Layout und Farben sind unter Vista in der eitenleiste anpassbar."
L["DASH_GUIDE_MOD_INSIGHT_BODY"]                              = "Insight erweitert die Blizzard-Tooltips für Spielercharaktere, NPCs und Gegenstände — Färbung nach Klasse und Fraktion, Spezialisierungs- und Symbolzeilen, optionale Mythsch-Plus-Wertung, Gegenstandsstufe, Hinweise zu Reittieren, sowie saubere Trenner. Jede Tooltip-Art hat eine eigene Kategorie unter Insight."
L["DASH_GUIDE_MOD_CACHE_BODY"]                                = "Cache übernimmt die Beutebenachrichtigung: Stilistische Benachrichtigungen für Gegenstände, Gold, Währung und Ruf, sowie Optionen zur Darstellung von Belohnungen. Aktivieren, um Horizons Repräsentation anstelle der Standardbenachrichtigungen zu nutzen."
L["DASH_GUIDE_MOD_ESSENCE_BODY"]                              = "Essence ist ein optionales Charakterdatenblatt: 3D-Model, Gegenstandsstufe, Primärwerte und eine übersichtliche Darstellung der Ausrüstung. Essence in der Seitenleiste öffnen, um Layout und Sichtbarkeit anzupassen."
L["DASH_GUIDE_MOD_MERIDIAN_BODY"]                             = [=[Der genaue Leistungsumfang steht noch nicht fest; spekuliert ruhig mit, was sich für Horizon gut anfühlen würde. Wenn du mitdenken oder die Idee beisteuern möchtest, komm in den |cffaaaaaaDiscord|r (Links unter Community & Support am unteren Rand des Dashboards) und teile uns mit, wofür du es nutzen würdest.]=]
L["DASH_AXIS_MODULE_SHORT_DESCRIPTION"]                       = "Einstellungsbereich für Profile, Module und globale Steuerungen."
L["DASH_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS"]               = "Zielverfolgung für Quests, Welt-Quests, Seltenes, Erfolge und Szenarien."
L["DASH_ZONE_TEXT_AND_NOTIFICATIONS"]                         = "Zonentext und Benachrichtigungen."
L["DASH_MINIMAP_ZONE_TEXT_COORDS_BUTTON"]                     = "Minikarte mit Zonentext, Koordinaten, Uhrzeit und Schaltflächensammler."
L["DASH_TOOLTIPS_CLASS_COLOURS_SPEC_FACTION"]                 = "Tooltips mit Klassenfarben, Spezialisierungs- und Fraktionssymbolen."
L["DASH_LOOT_TOASTS_ITEMS_MONEY_CURRENCY"]                    = "Einblendungen für Gegenstände, Gold, Währung und Ruf, sowie Überholung der Taschendarstellung."
L["DASH_ESSENCE_MODULE_SHORT_DESCRIPTION"]                    = "Charakterdatenblatt mit 3D-Modell, Gegenstandsstufe, Werte und Ausrüstungsmatrix."
L["DASH_MERIDIAN_MODULE_SHORT_DESCRIPTION"]                   = "Kompassartige Wegpunkte und Peilungen für Orientierung in der Welt — in Entwicklung."
-- L["DASH_WELCOME_COMMUNITY_HEADING"]                        = "Community & Support"
L["DASH_COPY_LINK_X"]                                         = "Link kopieren — %s"
L["HOME_HEAD_SUB"]                                            = "Module aktivieren und konfigurieren"
L["HOME_MOD_FOCUS_SHORT"]                                     = "Verfolge Zauber, Abklingzeiten und Procs."
L["HOME_MOD_PRESENCE_SHORT"]                                  = "Verbesserte Namensplaketten und Einheitenrahmen."
L["HOME_MOD_VISTA_SHORT"]                                     = "Verbesserte Welt- und Minikarte."
L["HOME_MOD_INSIGHT_SHORT"]                                   = "Füge Kontext zu Tooltips und Inspektionen hinzu."
L["HOME_MOD_CACHE_SHORT"]                                     = "Clevere Beute- und Gegenstandsverwaltung."
L["HOME_MOD_ESSENCE_SHORT"]                                   = "Benutzerdefinierte HUD-Elemente und Aktionsleisten."
L["DASH_RESIZE_TOOLTIP"]                                      = "Ziehen für Größenänderung\nRechtsklick zum Zurücksetzen"
L["HOME_RELOAD_PROMPT"]                                       = "Neuladen zum Anwenden der Moduländerungen."
L["RELOAD_UI"]                                                = "UI neuladen"
-- L["DASH_LAYOUT"]                                           = "Layout"
L["DASH_VISIBILITY"]                                          = "Sichtbarkeit"
L["DASH_DISPLAY"]                                             = "Anzeige"
L["DASH_FEATURES"]                                            = "Funktionen"
L["DASH_TYPOGRAPHY"]                                          = "Typografie"
L["DASH_APPEARANCE"]                                          = "Design"
L["DASH_CLICK_OPTIONS"]                                       = "Interaktion"
L["DASH_COLOURS"]                                             = "Farben"
-- L["DASH_ORGANISATION"]                                     = "Organisation"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["FOCUS_PANEL_BEHAVIOUR"]                                    = "Anzeigeverhalten"
L["FOCUS_DIMENSIONS"]                                         = "Abmessungen"
L["FOCUS_INSTANCE"]                                           = "Instanz"
L["FOCUS_INSTANCES"]                                          = "Instanzen"
L["FOCUS_COMBAT"]                                             = "Kampf"
L["FOCUS_FILTERING"]                                          = "Filterung"
L["FOCUS_HEADER"]                                             = "Kopfzeile"
L["FOCUS_SECTIONS_STRUCTURE"]                                 = "Abschnitte & Struktur"
L["FOCUS_ENTRY_DETAILS"]                                      = "Einträge"
L["FOCUS_PROGRESS_TIMERS"]                                    = "Fortschritt & Timer"
L["FOCUS_EMPHASIS"]                                           = "Hervorhebung"
L["FOCUS_LIST"]                                               = "Liste"
L["FOCUS_SPACING"]                                            = "Abstände"
L["FOCUS_RARE_BOSSES"]                                        = "Seltene Gegner"
L["FOCUS_WORLD_QUESTS"]                                       = "Welt-Quests"
L["FOCUS_FLOATING_QUEST_ITEM"]                                = "Quest-Gegenstände"
L["FOCUS_MYTHIC"]                                             = "Mythisch Plus"
L["FOCUS_ACHIEVEMENTS"]                                       = "Erfolge"
L["FOCUS_ACHIEVEMENT_PROGRESS_BARS"]                          = "Fortschrittsleisten für Erfolge"
L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_DESC"]                     = "Blendet eine Fortschrittsleiste unterhalb verfolgter Erfolge ein, die numerische Kriterien (inklusive 0/1 und X/Y) anzeigt. Unabhängig von Quest-Fortschrittsleisten."
L["FOCUS_ACHIEVEMENT_PROGRESS_BARS_TIP"]                      = "Wenn diese Option verfügbar ist, werden die selben Farben, Texturen und Schriftarten für Leisten verwendet, wie bei den anderen Focus-Fortschrittsleisten."
L["FOCUS_ENDEAVORS"]                                          = "Unterfangen"
L["FOCUS_DECOR"]                                              = "Dekoration"
L["FOCUS_APPEARANCES"]                                        = "Vorlagen"
L["FOCUS_SCENARIO_DELVE"]                                     = "Szenarien & Tiefen"
L["FOCUS_FONT"]                                               = "Schriftart"
L["FOCUS_FONT_FAMILIES"]                                      = "Schriftarten"
L["FOCUS_GLOBAL_FONT_SIZE"]                                   = "Globale Schriftgröße"
L["FOCUS_FONT_SIZES"]                                         = "Schriftgrößen"
L["FOCUS_PER_ELEMENT_FONTS"]                                  = "Schriftart pro Element"
L["FOCUS_TEXT_CASE"]                                          = "Groß-/Kleinschreibung"
L["FOCUS_SHADOW"]                                             = "Schattierung"
L["FOCUS_PANEL"]                                              = "Anzeige"
L["FOCUS_HIGHLIGHT"]                                          = "Hervorhebung"
L["FOCUS_COLOUR_MATRIX"]                                      = "Farbmatrix"
L["FOCUS_ORDER"]                                              = "Reihenfolge"
L["FOCUS_SORT"]                                               = "Sortierung"
L["FOCUS_BEHAVIOUR"]                                          = "Verhalten"
L["FOCUS_CONTENT_TYPES"]                                      = "Inhaltstypen"
L["FOCUS_DELVES"]                                             = "Tiefen"
L["FOCUS_DELVES_DUNGEONS"]                                    = "Tiefen & Verliese"
L["FOCUS_DELVE_COMPLETE"]                                     = "Tiefe abgeschlossen"
L["FOCUS_INTERACTIONS"]                                       = "Interaktionen"
-- L["FOCUS_LAYOUT_TAB_DESC"]                                 = "Configure and customise settings related to layout."
L["FOCUS_APPEARANCE_TAB_DESC"]                                = "Darstellung, Abblendung und Listen-Layout (Kopfbereich, Abschnitte, Einträge, Timer, Hervorhebung) des Zielverfolgers."
L["FOCUS_CLICK_OPTIONS_TAB_DESC"]                             = "Klickprofile, Komboaktionen und optionale Sicherheitseinstellungen für den Zielverfolger."
L["FOCUS_INTERACTIONS_TAB_DESC"]                              = "Quest-Verfolgungsregeln und TomTom-Integration konfigurieren."
L["FOCUS_TRACKING"]                                           = "Verfolgung"
L["FOCUS_SCENARIO_BAR"]                                       = "Szenarioleiste"

-- =====================================================================
-- OptionsData.lua Profiles
-- =====================================================================
L["AXIS_CURRENT_PROFILE"]                                     = "Aktuelles Profil"
L["AXIS_SELECT_PROFILE_CURRENTLY"]                            = "Das aktuell verwendete Profil"
L["AXIS_GLOBAL_PROFILE_ACCOUNT_WIDE"]                         = "Globales Profil (Account-weit) verwenden"
L["AXIS_CHARACTERS_SAME_PROFILE"]                             = "Alle Charaktere verwenden dasselbe Profil"
L["AXIS_ENABLE_PER_SPECIALIZATION_PROFILES"]                  = "Profil pro Spezialisierung aktivieren"
L["AXIS_PICK_DIFFERENT_PROFILES_PER_SPEC"]                    = "Wähle unterschiedliche Profile für Spezialisierungen."
L["AXIS_SPECIALIZATION"]                                      = "Spezialisierung"
-- L["AXIS_SPEC_PROFILES"]                                    = "Spec Profiles"
-- L["AXIS_ENABLE"]                                           = "Enable"
L["AXIS_SHARING"]                                             = "Teilen"
L["AXIS_IMPORT_PROFILE"]                                      = "Profil importieren"
L["AXIS_IMPORT_STRING"]                                       = "Import-Zeichenkette"
L["AXIS_EXPORT_PROFILE"]                                      = "Profil exportieren"
L["AXIS_SELECT_A_PROFILE_EXPORT"]                             = "Wähle ein Profil für den Export"
L["AXIS_EXPORT_STRING"]                                       = "Export-Zeichenkette"
L["AXIS_COPY_PROFILE"]                                        = "Von Profil kopieren"
L["AXIS_SOURCE_PROFILE_COPYING"]                              = "Quellprofil zum Kopieren"
L["AXIS_COPY_SELECTED"]                                       = "Auswahl kopieren"
L["AXIS_CREATE"]                                              = "Erstellen"
L["AXIS_CREATE_PROFILE_DEFAULT_TEMPLATE"]                     = "Erstelle neues Profil aus Standardvorlage"
L["AXIS_CREATES_A_PROFILE_DEFAULT_SETTINGS"]                  = "Erstellt ein neues Profil mit den Standardeinstellungen"
L["AXIS_CREATES_A_PROFILE_COPIED_SELECTED_SOURC"]             = "Erstellt ein neues Profil mit den Einstellungen des Quellprofils"
L["AXIS_DELETE_PROFILE"]                                      = "Profil löschen"
L["AXIS_SELECT_A_PROFILE_DELETE_CURRENT_DEFAULT"]             = "Profil zum Löschen wählen (aktuelles und Standard nicht angezeigt)"
L["AXIS_DELETE_SELECTED"]                                     = "Ausgewähltes löschen"
L["AXIS_DELETE_SELECTED_PROFILE"]                             = "Ausgewähltes Profil löschen"
L["AXIS_DELETE"]                                              = "Löschen"
L["AXIS_DELETES_SELECTED_PROFILE"]                            = "Löscht das ausgewählte Profil"
L["AXIS_GLOBAL_PROFILE"]                                      = "Globales Profil"
L["AXIS_PER_SPEC_PROFILES"]                                   = "Profile pro Spezialisierung"

-- =====================================================================
-- OptionsData.lua Modules
-- =====================================================================
L["AXIS_ENABLE_FOCUS_MODULE"]                                 = "Focus-Modul aktivieren"
L["AXIS_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS_R"]             = "Zeige die Zielverfolgung für Welt-(Quests), Rares, Erfolge und Szenarien an"
L["AXIS_ENABLE_PRESENCE_MODULE"]                              = "Presence-Modul aktivieren"
L["AXIS_CINEMATIC_ZONE_TEXT_NOTIFICATIONS_ZONE_CHANGES"]      = "Filmische Zonentext- und Benachrichtigungsanzeige (Zonenänderungen, Stufenaufstieg, Boss-Geschwätz, Erfolge, Quest-Aktualisierungen)"
L["AXIS_ENABLE_CACHE_MODULE"]                                 = "Cache-Modul aktivieren"
L["AXIS_CINEMATIC_LOOT_NOTIFICATIONS_ITEMS_MONEY_CURRENCY"]   = "Filmische Beutebenachrichtigungen (Gegenstände, Gold, Währungen, Ruf)"
L["AXIS_ENABLE_VISTA_MODULE"]                                 = "Vista-Modul aktivieren"
L["AXIS_CINEMATIC_SQUARE_MINIMAP_ZONE_TEXT_COORDINATES"]      = "Filmische quadratische Minimap mit Zonentext, Koordinaten und Schaltflächensammlung"
L["AXIS_MINIMAP_ZONE_TIME_COLLECTOR"]                         = "Filmische quadratische Minimap mit Zonentext, Koordinaten, Uhrzeit und Schaltflächensammlung"
-- L["AXIS_BETA"]                                             = "Beta"
L["AXIS_SCALING"]                                             = "Skalierung"
L["AXIS_GLOBAL_TOGGLES"]                                      = "Globale Einstellungen"
-- L["AXIS_DASHBOARD_SECTION"]                                = "Dashboard"
-- L["AXIS_GLOBAL_FONT_SECTION"]                              = "Global Font (Coming Soon!)"
-- L["AXIS_GLOBAL_SCALE_SECTION"]                             = "Global Scale"
-- L["AXIS_MINIMAP_ICON_SECTION"]                             = "Minimap Icon"
-- L["AXIS_CLASS_THEME_SECTION"]                              = "Class Theme"
-- L["AXIS_GLOBAL_CLASS_THEME"]                               = "Global Class Theme"
-- L["AXIS_CLASS_THEME_DASHBOARD"]                            = "Dashboard"
-- L["AXIS_CLASS_THEME_DASHBOARD_DESC"]                       = "Enables Dashboard class theming. Flipping it on turns on Class Colours, Dashboard Class Icon, and Override Background; each sub-option can then be adjusted independently while the master stays on."
-- L["AXIS_DASHBOARD_CLASS_COLOURS"]                          = "Class Colours"
-- L["AXIS_DASHBOARD_CLASS_ICON"]                             = "Dashboard Class Icon"
-- L["AXIS_DASHBOARD_CLASS_ICON_DESC"]                        = "Show a class icon on the Dashboard. Independent of class colour tinting and of the class background override."
-- L["AXIS_DASHBOARD_BG_CLASS_OVERRIDE"]                      = "Override Background to Class Background"
-- L["AXIS_DASHBOARD_BG_CLASS_OVERRIDE_DESC"]                 = "Replace the Dashboard background with a class-themed background. Independent of class colour tinting and of the class icon."
L["AXIS_PATCH_NOTES_SECTION"]                                 = "Änderungshinweise"
L["AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN"]                      = "Änderungshinweise nach Aktualisierung automatisch einblenden"
L["AXIS_AUTO_SHOW_PATCH_NOTES_ON_LOGIN_DESC"]                 = "EIN: Änderungshinweise zu Horizon werden nach jeder Aktualisierung einmalig eingeblendet. AUS: Ein grüner Indikator erscheint auf dem Horizon-Minikartensymbol bis die Änderungshinweise manuell geöffnet werden"
L["AXIS_SUITE_WIDE_CLASS_COLOUR_TINTING_UI"]                  = "Dashboard-Hintergrundmotiv, Klassenfärbung und UI-Skalierung (global oder pro Modul)."
L["AXIS_GLOBAL_UI_SCALE"]                                     = "Globale UI-Skalierung"
L["AXIS_SCALE_SIZES_SPACINGS_FONTS_FACTOR"]                   = "Sämtliche Größen, Abstände und Schriftarten werden um diesen Faktor (50–200 %) skaliert. Die konfigurierten Werte bleiben dabei unverändert."
L["AXIS_PER_MODULE_SCALING"]                                  = "Skalierung pro Modul"
L["AXIS_OVERRIDE_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_FO"]         = "Globale Skalierung durch Einzelschieber pro Modul ersetzen."
L["AXIS_OVERRIDES_GLOBAL_SCALE_INDIVIDUAL_SLIDERS_F"]         = "Überschreibt die globale Skalierung durch individuelle Schieberegler für Focus, Presence, Vista, usw."
L["AXIS_DOESN_T_CHANGE_YOUR_CONFIGURED_VALUES"]               = "Die konfigurierten Werte werden dadurch nicht verändert, lediglich die effektive Anzeigeskalierung"
L["FOCUS_SCALE"]                                              = "Focus-Skalierung"
L["AXIS_SCALE_FOCUS_OBJECTIVE_TRACKER"]                       = "Focus-Zielverfolgerskalierung (50–200 %)"
L["PRESENCE_SCALE"]                                           = "Presence-Skalierung"
L["AXIS_SCALE_PRESENCE_CINEMATIC_TEXT"]                       = "Skalierung für den filmischen Presence-Text (50–200 %)"
L["VISTA_SCALE"]                                              = "Vista-Skalierung"
L["AXIS_SCALE_VISTA_MINIMAP_MODULE"]                          = "Skalierung für das Vista-Minimap-Modul (50–200 %)"
L["INSIGHT_SCALE"]                                            = "Insight-Skalierung"
L["AXIS_SCALE_INSIGHT_TOOLTIP_MODULE"]                        = "Skalierung für das Insight-Tooltip-Modul (50–200 %)"
L["CACHE_SCALE"]                                              = "Cache-Skalierung"
L["AXIS_SCALE_CACHE_LOOT_TOAST_MODULE"]                       = "Skalierung des Cache-Beutebenachrichtungsmoduls (50–200 %)."
-- L["CACHE_FONT"]                                            = "Loot toast font"
-- L["CACHE_FONT_FAMILY"]                                     = "Font family used for loot toast text. Use 'Use global font' to follow the addon-wide font."
L["AXIS_ENABLE_HORIZON_INSIGHT_MODULE"]                       = "Horizon-Insight-Modul aktivieren"
L["AXIS_CINEMATIC_TOOLTIPS_CLASS_COLOURS_SPEC_DISPLAY"]       = "Filmische Tooltips mit Klassenfarben, Spezialisierungsanzeige und Fraktionssymbolen."
L["AXIS_TOOLTIP_ANCHOR_MODE"]                                 = "Tooltip-Ankermodus"
L["AXIS_WHERE_TOOLTIPS_APPEAR_FOLLOW_CURSOR_FIXED"]           = "Tooltip-Position: Mauszeiger folgen oder feste Position."
L["AXIS_CURSOR"]                                              = "Mauszeiger"
L["AXIS_FIXED"]                                               = "Fixiert"
L["INSIGHT_CURSOR_SIDE"]                                      = "Mauszeigerseite"
L["INSIGHT_CURSOR_SIDE_DESC"]                                 = "Seite des Mauszeigers, auf der Tooltips eingeblendet werden."
L["INSIGHT_CURSOR_SIDE_CENTER"]                               = "Zentriert"
L["INSIGHT_CURSOR_SIDE_LEFT"]                                 = "Links"
L["INSIGHT_CURSOR_SIDE_RIGHT"]                                = "Rechts"
L["AXIS_ANCHOR_MOVE"]                                         = "Positionierungsanker anzeigen"
L["AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITION"]                     = "Anker ein- oder ausblenden. Zum Positionieren ziehen und mit Rechtsklick bestätigen."
L["AXIS_DRAGGABLE_FRAME_FIXED_TOOLTIP_POSITION_DESC"]         = "Verschiebbaren Anker für feste Tooltip-Position anzeigen. Ziehen, dann Rechtsklick zum Bestätigen."
L["AXIS_RESET_TOOLTIP_POSITION"]                              = "Tooltip-Position zurücksetzen"
L["AXIS_RESET_FIXED_POSITION_DEFAULT"]                        = "Fixierte Position auf Standard zurücksetzen."
L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED"]                           = "Dynamische Position für Focus-Tooltips"
L["INSIGHT_FOCUS_DYNAMIC_IN_FIXED_DESC"]                      = "Bei fixiertem Anker werden Focus-Tooltips weiterhin am außeren Rand platziert. Dadurch verdecken sie nicht den Zielverfolger."
L["INSIGHT_CURSOR_OFFSET_X"]                                  = "X-Zeigerversatz"
L["INSIGHT_CURSOR_OFFSET_X_DESC"]                             = "Nur für fixierten Zeigeranker: Horizontaler Versatz der Zeigerposition."
L["INSIGHT_CURSOR_OFFSET_Y"]                                  = "Y-Zeigerversatz"
L["INSIGHT_CURSOR_OFFSET_Y_DESC"]                             = "Nur für fixierten Zeigeranker: Vertikaler Versatz der Zeigerposition."
L["AXIS_TOOLTIP_BACKGROUND_COLOUR"]                           = "Hintergrundfarbe des Tooltips"
L["AXIS_COLOUR_OF_TOOLTIP_BACKGROUND"]                        = "Farbe des Tooltip-Hintergrunds."
L["AXIS_TOOLTIP_BACKGROUND_OPACITY"]                          = "Hintergrunddeckkraft des Tooltips"
L["AXIS_TOOLTIP_BG_OPACITY_PCT_DESC"]                         = "Tooltip-Hintergrunddeckkraft (0–100 %)."
L["AXIS_TOOLTIP_FONT"]                                        = "Schriftart für Tooltips"
L["AXIS_FONT_FAMILY_TOOLTIP_TEXT"]                            = "Schriftart für den gesamten Tooltip-Text."
L["INSIGHT_BODY_SIZE"]                                        = "Schriftgröße für Tooltip-Körper"
L["INSIGHT_BODY_FONT_SIZE"]                                   = "Schriftgröße für den Tooltip-Körper."
L["INSIGHT_BADGES_SIZE"]                                      = "Schriftgröße für Statusmarkierungen"
L["INSIGHT_BADGES_FONT_SIZE"]                                 = "Schriftgröße für Statusmarkierungen (AFK, DND, etc.)"
L["INSIGHT_STATS_SIZE"]                                       = "Schriftgröße für Wertungen"
L["INSIGHT_STATS_FONT_SIZE"]                                  = "Schriftgröße für Mythisch-Plus-Wertung, sowie Gegenstands- und Ehrenstufen."
L["INSIGHT_MOUNT_SIZE"]                                       = "Schriftgröße für Reittier"
L["INSIGHT_MOUNT_FONT_SIZE"]                                  = "Schriftgröße für Reittier (Name, Quelle & Besitz)."
L["INSIGHT_MOUNT_OWNERSHIP_DISPLAY"]                          = "Indikator für Reittiersammlung"
L["INSIGHT_MOUNT_OWNERSHIP_DISPLAY_DESC"]                     = "Die Besitzanzeigedarstellung des Spielerreittiers."
L["INSIGHT_MOUNT_OWNERSHIP_TEXT"]                             = "Vollständiger Text"
L["INSIGHT_MOUNT_OWNERSHIP_ICONS"]                            = "Häckchen/Kreuz"
L["INSIGHT_MOUNT_OWNED"]                                      = "Reittier in Besitz"
L["INSIGHT_MOUNT_NOT_OWNED"]                                  = "Reittier nicht in Besitz"
L["INSIGHT_TRANSMOG_SIZE"]                                    = "Transmog-Größe"
L["INSIGHT_TRANSMOG_FONT_SIZE"]                               = "Schriftgröße für Gegenstandsvorlagen."
-- L["AXIS_TOOLTIPS"]                                         = "Tooltips"
L["INSIGHT_CATEGORY_GLOBAL"]                                  = "Globale Tooltips"
L["INSIGHT_CATEGORY_GLOBAL_DESC"]                             = "Gemeinsame Anker, Hintergrund, Schriftarten/-größen und Anzeigeoptionen für alle Tooltip-Arten."
L["INSIGHT_CATEGORY_PLAYER"]                                  = "Spieler"
L["INSIGHT_CATEGORY_PLAYER_DESC"]                             = "Gildenrang, Titel, Abzeichen, PvP, Wertungen, Ausrüstung & Reittier in Spieler-Tooltips."
-- L["INSIGHT_CATEGORY_NPC"]                                  = "NPCs"
L["INSIGHT_CATEGORY_NPC_DESC"]                                = "Tooltip-Darstellung für NPCs. Zusätzliche NPC-spezifische Optionen können hier später folgen."
L["INSIGHT_CATEGORY_ITEM"]                                    = "Gegenstände"
L["INSIGHT_CATEGORY_ITEM_DESC"]                               = "Optionen für Gegenstands-Tooltips wie Status der Transmog-Sammlung."
L["INSIGHT_SECTION_IDENTITY"]                                 = "Identität"
L["INSIGHT_PLAYER_NAME_COLOUR"]                               = "Farbe des Spielernamens"
L["INSIGHT_PLAYER_NAME_COLOUR_DESC"]                          = "Farbe des Spielernamens in der ersten Tooltip-Zeile: Fraktion (Allianz blau, Horde rot) oder Klassenfarbe."
L["INSIGHT_PLAYER_NAME_COLOUR_FACTION"]                       = "Fraktion"
L["INSIGHT_PLAYER_NAME_COLOUR_CLASS"]                         = "Klasse"
-- L["INSIGHT_PLAYER_NAME_GRADIENT"]                          = "Class Colour Gradient"
-- L["INSIGHT_PLAYER_NAME_GRADIENT_DESC"]                     = "Render the player name as a two-stop gradient of their class colour (only applies when the name colour is set to Class)."
-- L["INSIGHT_SECTION_STATUS_PVP"]                            = "Status & PvP"
L["INSIGHT_SECTION_RATINGS_GEAR"]                             = "Wertungen & Ausrüstung"
L["INSIGHT_SPEC_ROLE"]                                        = "Spezialisierungssymbol & Rolle"
L["INSIGHT_SPEC_ROLE_DESC"]                                   = "Zeigt ein Symbol für die Spezialisierung des Spielers und seiner Rolle nach dem inspizieren. AUS: Insight wird bei Maus-Over kein NotifyInspect durchführen."
L["INSIGHT_SECTION_MOUNT"]                                    = "Reittier"
L["INSIGHT_SECTION_DISMISS"]                                  = "Ausblendung des Einheiten-Tooltips"
L["INSIGHT_DISMISS_GRACE"]                                    = "Ausblendverzögerung"
L["INSIGHT_DISMISS_GRACE_DESC"]                               = "Verzögerung der Tooltip-Ausblendung wenn der Mauszeiger eine Einheit. Längere Ausblendverzögerung reduziert Flackern."
L["INSIGHT_DISMISS_GRACE_INSTANT"]                            = "Sofort"
-- L["INSIGHT_DISMISS_GRACE_DEFAULT"]                         = "Normal"
L["INSIGHT_DISMISS_GRACE_RELAXED"]                            = "Entspannt"
L["INSIGHT_SECTION_COMBAT"]                                   = "Kampf"
L["INSIGHT_HIDE_IN_COMBAT"]                                   = "Tooltips im Kampf verbergen"
L["INSIGHT_HIDE_IN_COMBAT_DESC"]                              = "Nur mit aktiviertem Insight-Modul: Im Kampf werden Spiel- und Insight-Tooltips blockiert."
L["INSIGHT_FADE_OUT_SEC"]                                     = "Ausblenddauer"
L["INSIGHT_FADE_OUT_SEC_DESC"]                                = "Sekunden zum Ausblenden des Einheit-Tooltips nachdem die Ausblendung startet. 0: Sofort Ausblenden. Nur für GameTooltip-Einheiten-Tooltips."
L["INSIGHT_SECTION_ICONS_AND_SEPARATORS"]                     = "Symbole & Trenner"
L["INSIGHT_SECTION_NPC_TOOLTIP"]                              = "NPC-Tooltip"
-- L["INSIGHT_SECTION_TRANSMOG"]                              = "Transmog"
L["INSIGHT_NPC_PLACEHOLDER"]                                  = "NPC-spezifische Optionen werden hier angezeigt, sobald sie verfügbar sind. Reaktionsfarben und Detailzeilen werden weiterhin angezeigt."
L["INSIGHT_NPC_REACTION_BORDER"]                              = "Umrandung mit Reaktionsfärbung"
L["INSIGHT_NPC_REACTION_BORDER_DESC"]                         = "Färbung der Tooltip-Umrandung des NPCs nach Reaktion (rot für feindlich, grün für freundlich, gelb für neutral)."
L["INSIGHT_NPC_REACTION_NAME"]                                = "Namen mit Reaktionsfärbung"
L["INSIGHT_NPC_REACTION_NAME_DESC"]                           = "Färbung des NPC-Namens nach seiner Fraktionsreaktion."
L["INSIGHT_NPC_LEVEL_LINE"]                                   = "Zeile mit Einheitendetails"
L["INSIGHT_NPC_LEVEL_LINE_DESC"]                              = "Stufe, Klassifizierung (Elite, Rar, etc.) und Kreaturentyp für NPCs und Kreaturen unter dem Namen anzeigen."
L["INSIGHT_NPC_ICONS_DESC"]                                   = "Zeigt für NPCs mit unbekannter Stufe ein Symbol anstelle '??' an."
L["INSIGHT_SECTION_ITEM_STYLING"]                             = "Gegenstandsdarstellung"
L["INSIGHT_ITEM_QUALITY_BORDER"]                              = "Umrandung mit Qualitätsfärbung"
L["INSIGHT_ITEM_QUALITY_BORDER_DESC"]                         = "Färbung der Tooltip-Umrandung nach Gegenstandsqualität (grün für ungewöhnlich, blau für selten, Lila für episch, etc.)"
-- L["INSIGHT_ITEM_NAME_GRADIENT"]                            = "Quality Gradient Name"
-- L["INSIGHT_ITEM_NAME_GRADIENT_DESC"]                       = "Render the item name as a two-stop gradient of its quality colour (Uncommon green, Rare blue, Epic purple, etc.)."
L["INSIGHT_ITEM_SECTION_SPACING"]                             = "Leerzeile vor Blöcken"
L["INSIGHT_ITEM_SECTION_SPACING_DESC"]                        = "Fügt eine Leerzeile anstelle einer gefärbten Trennlinie vor Insight-Blöcken in Gegenstands-Tooltips ein."
L["AXIS_ITEM_TOOLTIP"]                                        = "Gegenstands-Tooltip"
L["AXIS_TRANSMOG_STATUS"]                                     = "Transmog-Status anzeigen"
L["AXIS_WHETHER_YOU_COLLECTED_APPEARANCE_OF_AN"]              = "Anzeigen, ob die Erscheinung eines Gegenstands gesammelt wurde."
L["AXIS_PLAYER_TOOLTIP"]                                      = "Spieler-Tooltip"
L["AXIS_GUILD_RANK"]                                          = "Gildenrang anzeigen"
L["AXIS_APPEND_PLAYER_S_GUILD_RANK_NEXT"]                     = "Gildenrang des Spielers neben dem Gildennamen anzeigen."
L["AXIS_MYTHIC_SCORE"]                                        = "Mythisch-Plus-Wertung anzeigen"
L["AXIS_PLAYER_S_CURRENT_SEASON_MYTHIC_SCORE"]                = "Aktuelle Saison-Mythisch-Plus-Wertung des Spielers, gefärbt nach Stufe."
L["AXIS_ITEM_LEVEL"]                                          = "Gegenstandsstufe anzeigen"
L["AXIS_PLAYER_S_EQUIPPED_ITEM_LEVEL_AFTER"]                  = "Gegenstandsstufe des Spielers nach Inspektion anzeigen."
L["AXIS_HONOR_LEVEL"]                                         = "Ehrenstufe anzeigen"
L["AXIS_PLAYER_S_PVP_HONOR_LEVEL_TOOLTIP"]                    = "PvP-Ehrenstufe des Spielers im Tooltip anzeigen."
L["AXIS_PVP_TITLE"]                                           = "PvP-Titel anzeigen"
L["AXIS_PLAYER_S_PVP_TITLE_E_G"]                              = "PvP-Titel des Spielers (z.B. Gladiator) im Tooltip anzeigen."
L["AXIS_CHARACTER_TITLE"]                                     = "Charaktertitel"
L["AXIS_PLAYER_S_SELECTED_TITLE_ACHIEVEMENT_PVP"]             = "Stellt den gewählten Titel (Erfolg oder PvP) in der Namenszeile voran."
L["AXIS_TITLE_COLOUR"]                                        = "Titelfarbe"
L["AXIS_COLOUR_OF_CHARACTER_TITLE_PLAYER_TOOLTIP"]            = "Farbe des Charaktertitels in der Namenszeile des Tooltips."
L["AXIS_STATUS_BADGES"]                                       = "Statusmarkierungen anzeigen"
L["AXIS_INLINE_BADGES_COMBAT_AFK_DND_PVP"]                    = "markierungen für Kampf, AFK, DND, PvP, Schlachtzug/Gruppe, Freunde und Ziel anzeigen."
L["AXIS_MOUNT_INFO"]                                          = "Reittierinfo anzeigen"
L["AXIS_HOVERING_A_MOUNTED_PLAYER_THEIR_MOUNT"]               = "Bei Reittier-Spieler: Reittiername, Quelle und ob Sie es besitzen anzeigen."
L["AXIS_BLANK_SEPARATOR"]                                     = "Leere Trennzeile"
L["AXIS_A_BLANK_LINE_INSTEAD_OF_DASHES"]                      = "Fügt eine leere Zeile anstelle von Bindestrichen zwischen Tooltip-Sektionen ein."
L["AXIS_ICONS"]                                               = "Symbole anzeigen"
L["AXIS_CLASS_ICON_STYLE"]                                    = "Klassensymbolstil"
L["AXIS_DEFAULT_BLIZZARD_RONDOMEDIA_CLASS_ICONS_TH"]          = "Verwende Blizzard-Standard- oder Klassensymbole von RondoMedia in der Klassen/Spezialisierungszeile."
L["AXIS_CUSTOM_CLASS_ICONS_LABEL"]                            = "Benutzerdefiniert (Addon-Medien)"
L["AXIS_CLASS_ICON_SOURCES_TOOLTIP"]                          = "RondoMedia: https://www.curseforge.com/wow/addons/rondomedia — Benutzerdefiniert: Platziere eine TGA-Datei pro Klasse unter media/CustomClassIcons/<CLASS>/<class lower>.tga (z.B. WARRIOR/warrior.tga), anschließend Interface neuladen."
L["AXIS_RONDOMEDIA_CLASS_ICONS_RONDOFERRARI_HTTPS_WWW"]       = "RondoMedia-Klassensymbole von RondoFerrari — https://www.curseforge.com/wow/addons/rondomedia"
L["AXIS_DEFAULT"]                                             = "Standard"
L["AXIS_FACTION_SPEC_MOUNT_MYTHIC_ICONS_TOOLTIPS"]            = "Fraktion, Spezialisierung, Reittier und Mythisch-Plus-Symbole in Tooltips anzeigen."
L["AXIS_GENERAL"]                                             = "Allgemein"
-- L["AXIS_POSITION"]                                         = "Position"
L["AXIS_RESET_POSITION"]                                      = "Position zurücksetzen"
L["AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"]                   = "Position der Beutebenachrichtigung auf Standard zurücksetzen."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["FOCUS_LOCK_POSITION"]                                      = "Position fixieren"
L["FOCUS_PREVENT_DRAGGING_TRACKER"]                           = "Verhindert das Verschieben des Trackers."
L["FOCUS_GROW_UPWARD"]                                        = "Aufwärts erweitern"
L["FOCUS_GROW_HEADER"]                                        = "Kopfzeile nach oben erweitern"
L["FOCUS_GROWING_UPWARD_KEEP_HEADER_BOTTOM_TOP"]              = "Wenn aufwärts erweitert: Behalte die Kopfzeile unten, oder oben bis sie ausgeblendet wird."
L["FOCUS_HEADER_BOTTOM"]                                      = "Kopfzeile unten"
L["FOCUS_HEADER_SLIDES_COLLAPSE"]                             = "Überschrift gleitet beim Einklappen"
L["FOCUS_ANCHOR_BOTTOM_LIST_GROWS_UPWARD"]                    = "Die Liste nach unten ausrichten, damit sie nach oben erweitert wird."
L["FOCUS_START_COLLAPSED"]                                    = "Initial eingeklappt"
L["FOCUS_START_HEADER_SHOWN_UNTIL_YOU_EXPAND"]                = "Zeigt zu Beginn nur den Header an, bis du sie aufklappst"
L["FOCUS_ALIGN_CONTENT_RIGHT"]                                = "Inhalt rechts ausrichten"
L["FOCUS_RIGHT_ALIGN_QUEST_TITLES_OBJECTIVES_WITHIN"]         = "Richte die Quest-Titel und -ziele rechtsbündig aus"
L["FOCUS_PANEL_WIDTH"]                                        = "Anzeigebreite"
L["FOCUS_TRACKER_WIDTH_PIXELS"]                               = "Breite des Zielverfolgers"
L["FOCUS_MAX_CONTENT_HEIGHT"]                                 = "Maximalhöhe"
L["FOCUS_MAX_HEIGHT_OF_SCROLLABLE_LIST_PIXELS"]               = "Maximale Höhe der scrollbaren ZielverfolgerListe"
-- L["FOCUS_STATIC_BACKGROUND"]                               = "Static Background Size"
-- L["FOCUS_STATIC_BACKGROUND_DESC"]                          = "Lock the panel to a fixed height regardless of tracked content."
-- L["FOCUS_STATIC_PANEL_HEIGHT"]                             = "Static Panel Height"
-- L["FOCUS_STATIC_PANEL_HEIGHT_DESC"]                        = "Pixel height of the panel when static background is enabled."

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["FOCUS_ALWAYS_M_BLOCK"]                                     = "Mythisch-Plus-Block immer anzeigen"
L["FOCUS_M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]                = "Wenn ein aktiver Schlüsselstein läuft wird der Mythisch-Plus-Block immer eingeblendet."
L["FOCUS_DUNGEON"]                                            = "In Dungeons anzeigen"
L["FOCUS_TRACKER_PARTY_DUNGEONS"]                             = "Zeige Zielverfolger in Gruppen-Dungeons."
L["FOCUS_RAID"]                                               = "In Schlachtzügen anzeigen"
L["FOCUS_TRACKER_RAIDS"]                                      = "Zeige den Zielverfolger in Schlachtzügen."
L["FOCUS_BATTLEGROUND"]                                       = "In Schlachtfeldern anzeigen"
L["FOCUS_TRACKER_BATTLEGROUNDS"]                              = "Zeige den Zielverfolger auf Schlachtfeldern."
L["FOCUS_ARENA"]                                              = "In Arenen anzeigen"
L["FOCUS_TRACKER_ARENAS"]                                     = "Zeigt den Zielverfolger in Arenen an."
L["FOCUS_HIDE_COMBAT"]                                        = "Im Kampf verstecken"
L["FOCUS_HIDE_TRACKER_FLOATING_QUEST_ITEM_COMBAT"]            = "Verstecke Zielverfolger und Quest-Gegenstände im Kampf."
L["FOCUS_COMBAT_VISIBILITY"]                                  = "Sichtbarkeit im Kampf"
L["FOCUS_TRACKER_BEHAVES_COMBAT_FADE_REDUC"]                  = "Wie sich der Tracker im Kampf verhält: anzeigen, verblassen, oder ausblenden"
L["FOCUS_SHOW"]                                               = "Anzeigen"
L["FOCUS_FADE"]                                               = "Verblassen"
L["FOCUS_HIDE"]                                               = "Ausblenden"
L["FOCUS_COMBAT_FADE_OPACITY"]                                = "Sichtbarkeit im Kampf"
L["FOCUS_VISIBLE_TRACKER_FADED_COMBAT"]                       = "Wie sichtbar der Tracker ist, wenn er im Kampf verblasst (0 = unsichtbar). Gilt nur, wenn die Sichtbarkeit im Kampf auf „Ausblenden“ eingestellt ist."
-- L["FOCUS_MOUSEOVER"]                                       = "Mouseover"
L["FOCUS_SHOW_ONLY_MOUSEOVER"]                                = "Zeige nur bei Mouseover."
L["FOCUS_FADE_TRACKER_HOVERING_MOVE_MOUSE"]                   = "Zielverfolger verblasst wenn der Mauszeiger nicht darüber schwebt"
L["FOCUS_FADED_OPACITY"]                                      = "Sichtbarkeit wenn verblasst"
L["FOCUS_VISIBLE_TRACKER_FADED_INVISIBLE"]                    = "Sichtbarkeit des Trackers wenn er verblasst ist (0 = unsichtbar)"
L["FOCUS_QUESTS_CURRENT_ZONE"]                                = "Nur Quests der aktuellen Zone anzeigen"
L["FOCUS_HIDE_QUESTS_OUTSIDE_YOUR_CURRENT_ZONE"]              = "Verstecke Quests außerhalb der aktuellen Zone."

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["FOCUS_QUEST_COUNT"]                                        = "Anzahl der Quests anzeigen"
L["FOCUS_QUEST_COUNT_HEADER"]                                 = "Zeige die Anzahl der Quests in der Kopfzeile an"
L["FOCUS_HEADER_COUNT_FORMAT"]                                = "Format des Zählers"
L["FOCUS_TRACKED_LOG_LOG_MAX_SLOTS_TRACKED"]                  = "Verfolgt/im-Log oder im-Log/max-Plätze. Verfolgt schließt Welt- & Zonen-Quests aus."
L["FOCUS_HEADER_DIVIDER"]                                     = "Trennlinie für Kopfzeile anzeigen"
L["FOCUS_LINE_BELOW_HEADER"]                                  = "Fügt eine Linie unterhalb der Kopfzeile ein."
L["FOCUS_HEADER_DIVIDER_COLOUR"]                              = "Farbe der Kopfzeilentrennlinie"
L["FOCUS_COLOUR_OF_LINE_BELOW_HEADER"]                        = "Farbe der Linie unterhalb der Kopfzeile."
L["FOCUS_SUPER_MINIMAL_MODE"]                                 = "Super-Minimal-Modus"
L["FOCUS_HIDE_HEADER_A_PURE_TEXT_LIST"]                       = "Kopfzeile ausblenden, um eine reine Textliste anzuzeigen"
L["FOCUS_OPTIONS_BUTTON"]                                     = "Optionsschaltfläche"
L["FOCUS_OPTIONS_BUTTON_TRACKER_HEADER"]                      = "Zeigt die Optionsschaltfläche in der Kopfzeile an"
L["FOCUS_HEADER_COLOUR"]                                      = "Farbe der Kopfzeile"
L["FOCUS_COLOUR_OF_OBJECTIVES_HEADER_TEXT"]                   = "Farbe der ZIEL-Text Kopfzeile."
L["FOCUS_HEADER_HEIGHT"]                                      = "Höhe der Kopfzeile"
L["FOCUS_HEIGHT_OF_HEADER_BAR_PIXELS"]                        = "Höhe der Kopfzeilenleiste (18–48 px)."

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["FOCUS_SECTION_HEADERS"]                                    = "Abschnittsüberschriften anzeigen"
L["FOCUS_CATEGORY_LABELS_ABOVE_GROUP"]                        = "Kategoriebezeichnungen über jeder Gruppe anzeigen."
L["FOCUS_CATEGORY_HEADERS_COLLAPSED"]                         = "Kategorieüberschriften anzeigen, wenn ausgeblendet"
L["FOCUS_KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED_CLICK"]       = "Die Überschriften der Abschnitte bleiben sichtbar wenn eingeklappt ; klicke darauf, um eine Kategorie zu erweitern"
L["FOCUS_NEARBY_CURRENT_ZONE_GROUP"]                          = "Zeige Abschnitt für Quests in der Nähe (aktuelle Zone)"
L["FOCUS_ZONE_QUESTS_A_DEDICATED_CURRENT_ZONE"]               = "Zeige Quests in der aktuellen Zone in einem eigenen Abschnitt an. Wenn deaktiviert, werden sie in ihrem normalen Abschnitt angezeigt."
L["FOCUS_ZONE_LABELS"]                                        = "Zeige Zonenbezeichnung"
L["FOCUS_ZONE_NAME_UNDER_QUEST_TITLE"]                        = "Zeige den Namen der Zone unter jedem Quest-Titel an."
L["FOCUS_ACTIVE_QUEST_HIGHLIGHT"]                             = "Aktive Quest hervorheben"
L["FOCUS_FOCUSED_QUEST_HIGHLIGHTED"]                          = "Wie die aktuelle Quest hervorgehoben wird"
L["FOCUS_QUEST_ITEM_BUTTONS"]                                 = "Quest-Gegenstände anzeigen"
L["FOCUS_USABLE_QUEST_ITEM_BUTTON_NEXT_QUEST"]                = "Zeige neben jeder Quest eine Schaltfläche benutzbare Quest-Gegenstände an."
L["FOCUS_TOOLTIPS_HOVER"]                                     = "Tooltips bei Mouseover"
L["FOCUS_TOOLTIPS_HOVERING_TRACKER_ENTRIES_ITE"]              = "Tooltips anzeigen, wenn der Mauszeiger über Quests, Quest-Gegenstände und Szenario-Blöcken bewegt wird"
L["FOCUS_WOWHEAD_LINK_TOOLTIPS"]                              = "Wowhead-Links im Tooltip anzeigen"
L["FOCUS_A_TOOLTIP_SHOWN_ADD_A_LINK"]                         = "Wenn ein Tooltip angezeigt wird, füge einen Link hinzu, über den die Quest, der Erfolg oder der NPC auf WoWhead geöffnet werden kann."
L["FOCUS_VIEW_WOWHEAD"]                                       = "Auf Wowhead anzeigen"
L["FOCUS_WOWHEAD_ALT_CLICK_HINT"]                             = "ALT+Klick für Link"
-- L["FOCUS_WOWHEAD_HINT_LIST_SEPARATOR"]                     = " · "
L["FOCUS_WOWHEAD_TOOLTIP_HINT_FALLBACK"]                      = "In Focus-Optionen festlegen"
L["FOCUS_COPY_LINK"]                                          = "Link kopieren"
L["FOCUS_COPY_URL_BELOW_CTRL_C_PASTE"]                        = "Kopiere die folgende URL (STRG+C) und füge sie im Browser ein."
L["FOCUS_OBJECTIVE_NUMBERS"]                                  = "Nummerierung für Ziele anzeigen"
L["FOCUS_OBJECTIVE_PREFIX"]                                   = "Auflistung für Ziele"
L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS"]                  = "Färbung des Zielfortschritts"
L["FOCUS_OBJECTIVE_PROGRESS_NUMBER_COLOURS_DESC"]             = "Nummerierungsfärbung (X/Y): Standardfarbe bei 0/n, gold bei in Arbeit, grün wenn abgeschlossen."
L["FOCUS_PREFIX_OBJECTIVE_A_NUMBER_HYPHEN"]                   = "Quest-Zielen Nummerierungen oder Bindestriche voranstellen."
L["FOCUS_NUMBERS"]                                            = "Nummerierung (1. 2. 3.)"
L["FOCUS_HYPHENS"]                                            = "Bindestriche (-)"
L["FOCUS_AFTER_SECTION_HEADER"]                               = "Abstand nach Abschnittsüberschrift"
L["FOCUS_BEFORE_SECTION_HEADER"]                              = "Abstand vor Abschnittsüberschrift"
L["FOCUS_BELOW_HEADER"]                                       = "Unterhalb der Kopfzeile"
L["FOCUS_INLINE_BELOW_TITLE"]                                 = "Unterhalb des Titels eingebettet"
L["FOCUS_PREFIX_OBJECTIVES"]                                  = "Zielen eine Nummerierung voranstellen: 1., 2., 3."
L["FOCUS_COMPLETED_COUNT"]                                    = "Anzahl abgeschlossener Quests anzeigen"
L["FOCUS_X_Y_PROGRESS_QUEST_TITLE"]                           = "Fortschritt (X/Y) im Quest-Titel anzeigen."
L["FOCUS_OBJECTIVE_PROGRESS_BAR"]                             = "Leisten für Zielfortschritte anzeigen"
L["FOCUS_A_PROGRESS_BAR_UNDER_OBJECTIVES_NUMER"]              = "Zeigt eine Fortschrittsleiste unterhalb von Zielen an, die einen numerischen Fortschritt aufweisen (z. B. 3/250). Dies gilt nur für Einträge mit einem einzelnen rechnerischen Ziel, bei denen der erforderliche Wert größer als 1 ist."
L["FOCUS_CATEGORY_COLOUR_PROGRESS_BAR"]                       = "Kategoriefärbung für Fortschrittsleisten"
L["FOCUS_PROGRESS_BAR_MATCHES_QUEST_ACHIEVEME"]               = "EIN: Färbung der Fortschrittsleiste nach Quest-/Erfolgsabschnitt an. AUS: Benutzerdefinierte Füllfarbe verwenden."
L["FOCUS_PROGRESS_BAR_TEXTURE"]                               = "Textur für den Fortschrittsleisten"
L["FOCUS_PROGRESS_BAR_TYPES"]                                 = "Arten von Fortschrittsleisten"
L["FOCUS_TEXTURE_PROGRESS_BAR_FILL"]                          = "Textur für die Füllung der Fortschrittsleiste"
L["FOCUS_TEXTURE_PROGRESS_BAR_FILL_SOLID_YOUR"]               = "Textur für die Füllung der Fortschrittsleiste. Bei „Solid“ werden die von dir gewählten Farben verwendet. Add-ons wie SharedMedia bieten weitere Optionen."
L["FOCUS_PROGRESS_BAR_X_Y_OBJECTIVES_PERCENT"]                = "Zeige eine Fortschrittsleisten für numerische (X/Y), prozentuale Ziele oder beide an"
L["FOCUS_X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]             = "Numerische Ziele: 3/10. Prozentuale Ziele: 45 %"
L["FOCUS_X_Y"]                                                = "Nur numerische Ziele"
L["FOCUS_PERCENT"]                                            = "Nur prozentuale Ziele"
L["FOCUS_TICK_COMPLETED_OBJECTIVES"]                          = "Häkchen für abgeschlossene Ziele anzeigen"
L["FOCUS_COMPLETED_OBJECTIVES_A_CHECKMARK_INSTEA"]            = "Wenn die Funktion aktiviert ist, werden abgeschlossene Ziele mit einem Häkchen (✓) statt in Grünfärbung angezeigt."
L["FOCUS_ENTRY_NUMBERS"]                                      = "Nummerierung anzeigen"
L["FOCUS_PREFIX_QUEST_TITLES_WITHIN_CATEGORY"]                = "Stellt Quest-Titeln innerhalb jedes Abschnittes eine Nummerierung voran."
L["FOCUS_COMPLETED_OBJECTIVES"]                               = "Abgeschlossene Ziele"
L["FOCUS_MULTI_OBJECTIVE_QUESTS_DISPLAY_OBJECTIVES"]          = "Wie bei Quests mit mehreren Zielen die bereits erfüllten Ziele angezeigt werden (z. B. 1/1)"
L["FOCUS_ALL"]                                                = "Alle anzeigen"
L["FOCUS_FADE_COMPLETED"]                                     = "Abgeschlossene abblenden"
L["FOCUS_HIDE_COMPLETED"]                                     = "Abgeschlossene ausblenden"
L["FOCUS_ICON_ZONE_AUTO_TRACKING"]                            = "Symbol für automatische Verfolgung innerhalb der derzeitigen Zone anzeigen"
L["FOCUS_DISPLAY_AN_ICON_NEXT_AUTO_TRACKED"]                  = "Zeige ein Symbol neben automatisch verfolgten Weltquests und wöchentlichen/täglichen Quests an, die noch nicht in deinem Questlog stehen (nur innerhalb der Zone)."
L["FOCUS_AUTO_TRACK_ICON"]                                    = "Symbol für automatische Verfolgung"
L["FOCUS_CHOOSE_WHICH_ICON_DISPLAY_NEXT_AUTO"]                = "Wähle aus, welches Symbol neben automatisch erfassten Einträgen innerhalb der derzeitigen Zone angezeigt werden soll."
L["FOCUS_APPEND_WORLD_QUESTS_WEEKLIES_DAILIES"]               = "Füge ** zu Weltquests und wöchentlichen/täglichen Quests hinzu, die noch nicht in deinem Questlog stehen (nur in derzeitiger Zone)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["FOCUS_COMPACT_MODE"]                                       = "Kompakter Modus"
L["FOCUS_PRESET_SETS_ENTRY_OBJECTIVE_SPACING_P"]              = "Voreinstellung: Eintrags- und Zielabstand auf 4 und 1 px setzen."
L["FOCUS_SPACING_PRESET"]                                     = "Voreinstellung für Abstände"
L["FOCUS_PRESET_ENTRY_OBJECTIVE_SPACING_DEFAULT_P"]           = "Voreinstellung: Standard (8/2 px), Kompakt (4/1 px), Abstand (12/3 px) oder Benutzerdefiniert (Schieberegler)."
L["FOCUS_COMPACT_VERSION"]                                    = "Kompaktversion"
L["FOCUS_SPACED_VERSION"]                                     = "Abstandsversion"
L["FOCUS_SPACING_BETWEEN_QUEST_ENTRIES_PX"]                   = "Abstand zwischen Quest-Einträgen"
L["FOCUS_VERTICAL_GAP_BETWEEN_QUEST_ENTRIES"]                 = "Vertikaler Abstand zwischen Quest-Einträgen."
L["FOCUS_SPACING_BEFORE_CATEGORY_HEADER_PX"]                  = "Abstand vor Abschnittsüberschrift"
L["FOCUS_GAP_BETWEEN_LAST_ENTRY_OF_A"]                        = "Abstand zwischen letztem Eintrag einer Gruppe und der nächsten Abschnittsüberschrift."
L["FOCUS_SPACING_AFTER_CATEGORY_HEADER_PX"]                   = "Abstand nach Abschnittsüberschrift"
L["FOCUS_GAP_BETWEEN_CATEGORY_LABEL_FIRST_QUEST"]             = "Abstand zwischen Abschnittsüberschrift und erstem Quest-Eintrag darunter."
L["FOCUS_SPACING_BETWEEN_OBJECTIVES_PX"]                      = "Abstand zwischen Zielen"
L["FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVE_LINES_WITHIN"]        = "Vertikaler Abstand zwischen Zielzeilen innerhalb einer Quest."
L["FOCUS_TITLE_CONTENT"]                                      = "Abstand zwischen Titel und Inhalt"
L["FOCUS_VERTICAL_GAP_BETWEEN_QUEST_TITLE_OBJECTIVES"]        = "Vertikaler Abstand zwischen Quest-Titel und Zielen oder Zone darunter."
L["FOCUS_SPACING_BELOW_HEADER_PX"]                            = "Abstand unter Kopfzeile"
L["FOCUS_VERTICAL_GAP_BETWEEN_OBJECTIVES_BAR_QUES"]           = "Vertikaler Abstand zwischen Zielleiste und Quest-Liste."
L["FOCUS_RESET_SPACING"]                                      = "Abstände zurücksetzen"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["FOCUS_SHOW_QUEST_LEVEL"]                                   = "Quest-Stufe anzeigen"
L["FOCUS_QUEST_LEVEL_NEXT_TITLE"]                             = "Quest-Stufe neben Titel anzeigen."
L["FOCUS_DIM_FOCUSED_QUESTS"]                                 = "Nicht fokussierte Quests abdunkeln"
L["FOCUS_SLIGHTLY_DIM_TITLE_ZONE_OBJECTIVES_SECTION"]         = "Nicht fokussierte Titel, Zonen, Ziele und Abschnittsüberschriften leicht abdunkeln."
L["FOCUS_DIM_UNFOCUSED_ENTRIES"]                              = "Nicht fokussierte Einträge abdunkeln"
L["FOCUS_CLICK_A_SECTION_HEADER_EXPAND_CATEGORY"]             = "Abschnittsüberschrift klicken, um Kategorie zu erweitern."

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["UI_SHOW_RARE_BOSSES"]                                      = "Seltene Gegner anzeigen"
L["UI_RARE_BOSS_VIGNETTES_LIST"]                              = "Vignetten seltener Gegner im Zielverfolger anzeigen."
L["UI_RARE_LOOT"]                                             = "Seltene Schätze"
L["UI_TREASURE_ITEM_VIGNETTES_RARE_LOOT"]                     = "Zeigt Schätze und Gegenstände in der Liste seltener Beute."
L["UI_RARE_SOUND_VOLUME"]                                     = "Lautstärke seltener Beute"
L["UI_VOLUME_OF_RARE_ALERT_SOUND"]                            = "Lautstärke des Audioeffekts für seltene Beute (50–200 %)."
L["UI_BOOST_REDUCE_RARE_ALERT_VOLUME"]                        = "Lautstärke anpassen. 100 % = normal; 150 % = lauter."
L["UI_RARE_ADDED_SOUND"]                                      = "Audioeffekt bei seltenen Gegnern"
L["UI_PLAY_A_SOUND_A_RARE"]                                   = "Audioeffekt abspielen, wenn ein seltener Gegner gefunden wird."
L["UI_MINIMAP_PATCH_NOTES_UNREAD_HINT"]                       = "Neue Änderungshinweise — Öffne Axis und wähle Änderungshinweise."

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["FOCUS_ZONE_WORLD_QUESTS"]                                  = "Welt-Quests in Zone anzeigen"
L["FOCUS_AUTO_ADD_WORLD_QUESTS_YOUR_CURRENT"]                 = "Welt-Quests in Zone automatisch hinzufügen. AUS: Nur verfolgte Quests oder nahe Welt-Quests (Blizzard-Standard)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["FOCUS_SHOW_FLOATING_QUEST_ITEM"]                           = "Schaltfläche für Quest-Gegenstand anzeigen"
L["FOCUS_QUICK_BUTTON_FOCUSED_QUEST_S_USABLE"]                = "Benutzbarer Quest-Gegenstände für fokussierte Quest anzeigen."
L["FOCUS_LOCK_FLOATING_QUEST_ITEM_POSITION"]                  = "Schaltfläche für Quest-Gegenstand fixieren"
L["FOCUS_PREVENT_DRAGGING_FLOATING_QUEST_ITEM_BUTTON"]        = "Die Schaltfläche für Quest-Gegenstand ist nicht verschiebbar."
L["FOCUS_FLOATING_QUEST_ITEM_SOURCE"]                         = "Quelle für Quest-Gegenstand"
L["FOCUS_WHICH_QUEST_S_ITEM_SUPER_TRACKED"]                   = "Priorisierung des Quest-Gegenstands: Super-verfolgt oder aktuelle Zone zuerst."
L["FOCUS_SUPER_TRACKED_FIRST"]                                = "Vorrangig Super-verfolgt"
L["FOCUS_CURRENT_ZONE_FIRST"]                                 = "Vorrangig aktuelle Zone"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["FOCUS_MYTHIC_BLOCK"]                                       = "Mythisch-Plus-Block anzeigen"
L["FOCUS_TIMER_COMPLETION_AFFIXES_MYTHIC_DUNGEONS"]           = "Timer, Streitkräfte-% und Affixe in Mythisch-Plus-Dungeons anzeigen."
L["FOCUS_M_BLOCK_POSITION"]                                   = "Position des Mythisch-Plus-Blocks"
L["FOCUS_POSITION_OF_MYTHIC_BLOCK_RELATIVE_QUEST"]            = "Position des Mythisch-Plus-Blocks relativ zur Quest-Liste."
L["FOCUS_AFFIX_ICONS"]                                        = "Affix-Symbole anzeigen"
L["FOCUS_AFFIX_ICONS_NEXT_MODIFIER_NAMES_M"]                  = "Affix-Symbole neben Modifikatornamen im Mythisch-Plus-Block anzeigen."
L["FOCUS_AFFIX_DESCRIPTIONS_TOOLTIP"]                         = "Affix-Beschreibungen im Tooltip anzeigen"
L["FOCUS_AFFIX_DESCRIPTIONS_HOVERING_M_BLO"]                  = "Affix-Beschreibungen bei Maus-Over über Mythisch-Plus-Block anzeigen."
L["FOCUS_M_COMPLETED_BOSS_DISPLAY"]                           = "Anzeige besiegter Mythisch-Plus-Bosse"
L["FOCUS_DEFEATED_BOSSES_CHECKMARK_ICON_GREEN"]               = "Besiegte Bosse: Häkchen oder Grünfärbung."
L["FOCUS_CHECKMARK"]                                          = "Häkchen"
L["FOCUS_GREEN_COLOUR"]                                       = "Grünfärbung"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["PRESENCE_ACHIEVEMENTS"]                                    = "Erfolge anzeigen"
L["FOCUS_TRACKED_ACHIEVEMENTS_LIST"]                          = "Verfolgte Erfolge in der Liste anzeigen."
L["FOCUS_COMPLETED_ACHIEVEMENTS"]                             = "Errungene Erfolge anzeigen"
L["FOCUS_INCLUDE_COMPLETED_ACHIEVEMENTS_TRACKER_O"]           = "Errungene Erfolge im Zielverfolger anzeigen. AUS: Nur verfolgte in Bearbeitung."
L["FOCUS_ACHIEVEMENT_ICONS"]                                  = "Erfolgssymbole anzeigen"
L["FOCUS_ACHIEVEMENT_S_ICON_NEXT_TITLE_REQUI"]                = "Erfolgssymbol neben Titel anzeigen. Erfordert „Quest-Typsymbole anzeigen\" in Anzeige."
L["FOCUS_MISSING_REQUIREMENTS"]                               = "Nur offene Kriterien anzeigen"
L["FOCUS_CRITERIA_YOU_HAVEN_T_COMPLETED_TR"]                  = "Nur offene Kriterien pro verfolgtem Erfolg. AUS: Alle Kriterien."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["FOCUS_SHOW_ENDEAVORS"]                                     = "Unterfangen anzeigen"
L["FOCUS_TRACKED_ENDEAVORS_PLAYER_HOUSING_LIST"]              = "Verfolgte Unterfangen (Spielerbehausung) in der Liste anzeigen."
L["FOCUS_COMPLETED_ENDEAVORS"]                                = "Abgeschlossene Unterfangen anzeigen"
L["FOCUS_INCLUDE_COMPLETED_ENDEAVORS_TRACKER"]                = "Abgeschlossene Unterfangen im Zielverfolger anzeigen. AUS: Nur verfolgte in Bearbeitung."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["FOCUS_SHOW_DECOR"]                                         = "Dekoration anzeigen"
L["FOCUS_TRACKED_HOUSING_DECOR_LIST"]                         = "Verfolgte Behausungsdekoration in der Liste anzeigen."
L["FOCUS_DECOR_ICONS"]                                        = "Dekorationssymbole anzeigen"
L["FOCUS_DECOR_ITEM_S_ICON_NEXT_TITLE"]                       = "Dekorationssymbol neben Titel anzeigen. Erfordert „Quest-Typ-Symbole anzeigen\" in Anzeige."

-- =====================================================================
-- OptionsData.lua Features — Appearances
-- =====================================================================
L["FOCUS_SHOW_APPEARANCES"]                                   = "Vorlagen zeigen"
L["FOCUS_TRACKED_TRANSMOG_APPEARANCES_LIST"]                  = "Verfolgte Transmog-Vorlagen in der Liste anzeigen."
L["FOCUS_INCLUDE_COLLECTED_APPEARANCES_TRACKER"]              = "EIN: Gesammelte Vorlagen im Zielverfolger belassen. AUS: Nur ungesammelte Vorlagen anzeigen."
L["FOCUS_APPEARANCE_ICONS"]                                   = "Vorlagensymbole anzeigen"
L["FOCUS_APPEARANCE_ICON_NEXT_TITLE"]                         = "Zeigt Vorlagensymbole neben Titel an. Erfordert die Anzeige von Quest-Typsymbolen."
L["FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON"]                  = "Transmog-Listensymbol verwenden"
L["FOCUS_APPEARANCE_USE_TRANSMOG_TYPE_ICON_DESC"]             = "Nutzt das Vorlagen-/Transmog-Listensymbol für Einträge, anstatt die einzelnen Symbole der Gegenstände. Wenn dieses Symbol nicht gefunden werden kann, wird stattdessen das Gegenstandssymbol verwendet."
L["FOCUS_SHOW_APPEARANCE_WARDROBE"]                           = "Garderobe anzeigen"
L["FOCUS_OPEN_APPEARANCES_COLLECTIONS"]                       = "Sammlung anzeigen"
L["FOCUS_UNTRACK_APPEARANCE"]                                 = "Vorlageverfolgung beenden"
L["FOCUS_APPEARANCE_HORIZON_CONTROLS_HINT"]                   = "Horizon: SCHIFT-Klickclick auf Karte; Mit aktivierten TomTom-Wegpunktenerzeugt dieser Klick auf einen Verfolgsungspfeil. STRG-Klick für Sammlungen, ALT-Klick für Anprobe. Rechtsklick Fokus entfernen oder entfolgen."

-- =====================================================================
-- OptionsData.lua Features — Adventure Guide
-- =====================================================================
L["FOCUS_ADVENTURE_GUIDE"]                                    = "Abenteuerführer"
L["FOCUS_TRAVELER_S_LOG"]                                     = "Reisetagebuch anzeigen"
L["FOCUS_TRACKED_TRAVELER_S_LOG_OBJECTIVES_SHIFT"]            = "Verfolgte Reisetagebuchziele (SHIFT+Klick im Abenteuerführer) in der Liste anzeigen."
L["FOCUS_AUTO_REMOVE_COMPLETED_ACTIVITIES"]                   = "Abgeschlossene Aktivitäten automatisch entfernen"
L["FOCUS_AUTOMATICALLY_STOP_TRACKING_TRAVELER_S_LOG"]         = "Reisetagebuchaktivitäten nach Abschluss automatisch entfolgen."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["FOCUS_SCENARIO_EVENTS"]                                    = "Szenarioereignisse anzeigen"
L["FOCUS_ACTIVE_SCENARIO_DELVE_ACTIVITIES_DELVES_APP"]        = "Aktive Szenarien und Tiefen anzeigen. Tiefen in Tiefen; andere in Szenario-Ereignisse."
L["FOCUS_TRACK_DELVE_DUNGEON_SCENARIO_ACTIVITIES"]            = "Tiefen-, Dungeon- und Szenarioaktivitäten verfolgen."
L["FOCUS_DELVES_APPEAR_DELVES_SECTION_DUNGEONS_DUNGEON"]      = "Tiefen in Tiefen; Dungeons in Dungeon; andere Szenarien in Szenarioereignisse."
L["FOCUS_DELVES_APPEAR_DELVES_SECTION_SCENARIOS"]             = "Tiefen in Tiefen; andere Szenarien in Szenarioereignissen."
L["FOCUS_DELVE_AFFIX_NAMES"]                                  = "Tiefen-Affixe"
L["FOCUS_DELVE_DUNGEON"]                                      = "Nur Tiefen & Dungeons"
L["FOCUS_SCENARIO_DEBUG_LOGGING"]                             = "Szenario-Debug-Protokoll"
L["FOCUS_LOG_SCENARIO_API_DATA_CHAT_H"]                       = "Szenario-API-Daten im Chat protokollieren. /h debug focus scendebug zum Umschalten."
L["FOCUS_PRINTS_C_SCENARIOINFO_CRITERIA_WIDGET_DATA"]         = "Gibt C_ScenarioInfo-Kriterien und Widget-Daten aus. Hilft bei Anzeigeproblemen wie Abundance 46/300."
L["FOCUS_HIDE_CATEGORIES_DELVE_DUNGEON"]                      = "Andere Abschnitte in Tiefen & Dungeons verbergen"
L["FOCUS_DELVES_PARTY_DUNGEONS_DELVE_DUNG"]                   = "In Tiefen oder Gruppen-Dungeons nur Tiefen/Dungeon-Abschnitt anzeigen."
L["FOCUS_DELVE_NAME_SECTION_HEADER"]                          = "Tiefen-Namen als Abschnittsüberschrift verwenden"
L["FOCUS_A_DELVE_DELVE_NAME_TIER_AFFIXES"]                    = "In Tiefe: Tiefenname, Stufe und Affixe als Abschnittsüberschrift statt separatem Banner. AUS: Tiefen-Block über Liste."
L["FOCUS_AFFIX_NAMES_DELVES"]                                 = "Zeige Affix-Namen in Tiefen"
L["FOCUS_SEASON_AFFIX_NAMES_FIRST_DELVE_ENTRY"]               = "Saison-Affixe beim ersten Tiefen-Eintrag anzeigen. Erfordert Blizzard-Widgets; evtl. nicht bei Tracker-Ersatz."
L["FOCUS_CINEMATIC_SCENARIO_BAR"]                             = "Filmische Szenarioleiste"
L["FOCUS_TIMER_PROGRESS_BAR_SCENARIO_ENTRIES"]                = "Timer und Fortschrittleisten für Szenarien anzeigen."
L["FOCUS_TIMER"]                                              = "Timer anzeigen"
L["FOCUS_COUNTDOWN_TIMER_TIMED_QUESTS_EVENTS_SCEN"]           = "Countdown-Timer für zeitgesteuerte Quests, Ereignisse und Szenarien. AUS: Timer für alle ausgeblendet."
L["FOCUS_TIMER_SCENARIOS"]                                    = "Timer für Szenarien & Tiefen"
L["FOCUS_TIMER_SCENARIOS_DESC"]                               = "Countdown-Timer für Szenario-, Tiefen- und Dungeon-Einträge."
L["FOCUS_TIMER_WORLD"]                                        = "Timer für Welt- & Abgesandten-Quests"
L["FOCUS_TIMER_WORLD_DESC"]                                   = "Timer für Welt- & Abgesandten-Quests anzeigen."
L["FOCUS_TIMER_QUEST_LOG"]                                    = "Timer für zeitlich begrenzte Quests aus dem Log"
L["FOCUS_TIMER_QUEST_LOG_DESC"]                               = "Timer für tägliche, wöchentliche und andere zeitlimitierte Quests im Log."
L["FOCUS_TIMER_DISPLAY"]                                      = "Timer-Anzeige"
L["FOCUS_COLOUR_TIMER_REMAINING"]                             = "Timer nach verbleibender Zeit einfärben"
L["FOCUS_GREEN_PLENTY_OF_LEFT_YELLOW_RUNNING"]                = "Grün bei viel Zeit, gelb bei wenig, rot bei kritisch."
L["FOCUS_WHERE_COUNTDOWN_BAR_BELOW_OBJECTIVES"]               = "Countdown-Position: Leiste unter Zielen oder Text neben dem Questnamen."
L["FOCUS_BAR_BELOW"]                                          = "Leiste unten"
L["FOCUS_INLINE_BESIDE_TITLE"]                                = "Eingebettet neben Titel"

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["FOCUS_FONT_FAMILY"]                                        = "Schriftart"
L["FOCUS_TITLE_FONT"]                                         = "Schriftart für Titel"
L["VISTA_ZONE_FONT"]                                          = "Schriftart für Zone"
L["FOCUS_OBJECTIVE_FONT"]                                     = "Schriftart für Ziele"
L["FOCUS_SECTION_FONT"]                                       = "Schriftart für Abschnitte"
L["FOCUS_GLOBAL_FONT"]                                        = "Globale Schriftart"
L["FOCUS_FONT_FAMILY_QUEST_TITLES"]                           = "Schriftart für Quest-Titel."
L["FOCUS_FONT_FAMILY_ZONE_LABELS"]                            = "Schriftart für Zonenbezeichnungen."
L["FOCUS_FONT_FAMILY_OBJECTIVE_TEXT"]                         = "Schriftart für Quest-Ziele."
L["FOCUS_FONT_FAMILY_SECTION_HEADERS"]                        = "Schriftart für Abschnittsüberschriften."
L["FOCUS_HEADER_SIZE"]                                        = "Schriftgröße für Kopfzeile"
L["FOCUS_HEADER_FONT_SIZE"]                                   = "Schriftgröße der Kopfzeile."
L["FOCUS_TITLE_SIZE"]                                         = "Schriftgröße für Quest-Titel"
L["FOCUS_QUEST_TITLE_FONT_SIZE"]                              = "Schriftgröße für Quest-Titel."
L["FOCUS_OBJECTIVE_SIZE"]                                     = "Schriftgröße für Ziele"
L["FOCUS_OBJECTIVE_TEXT_FONT_SIZE"]                           = "Schriftgröße für Ziele."
L["FOCUS_ZONE_SIZE"]                                          = "Schriftgröße für Zonen"
L["FOCUS_ZONE_LABEL_FONT_SIZE"]                               = "Schriftgröße für Zonenbezeichnungen."
L["FOCUS_SECTION_SIZE"]                                       = "Schriftgröße für Abschnitte"
L["FOCUS_SECTION_HEADER_FONT_SIZE"]                           = "Schriftgröße für Abschnittsüberschriften"
L["FOCUS_PROGRESS_BAR_FONT"]                                  = "Schriftart für Fortschrittsleisten"
L["FOCUS_FONT_FAMILY_PROGRESS_BAR_LABEL"]                     = "Schriftart für die Beschriftung der Fortschrittleisten."
L["FOCUS_PROGRESS_BAR_TEXT_SIZE"]                             = "Schriftgröße für Fortschrittsleistentext"
L["FOCUS_FONT_SIZE_PROGRESS_BAR_LABEL_ADJUSTS"]               = "Schriftgröße für die Beschriftung der Fortschrittsleiste. Ändert auch die Höhe der Leiste. Betrifft Quest-Ziele, Szenariofortschritt und Szenario-Zeitleisten."
-- L["FOCUS_TIMER_TEXT_FONT"]                                 = "Timer Font"
-- L["FOCUS_FONT_FAMILY_TIMER_TEXT"]                          = "Font family for quest timer text (inline timers and world quest timers)."
-- L["FOCUS_TIMER_TEXT_SIZE"]                                 = "Timer Text Size"
-- L["FOCUS_TIMER_TEXT_FONT_SIZE"]                            = "Quest timer text font size."
-- L["FOCUS_OPTIONS_FONT"]                                    = "Options Font"
-- L["FOCUS_FONT_FAMILY_OPTIONS"]                             = "Font family for the Options button label in the tracker header."
-- L["FOCUS_OPTIONS_TEXT_SIZE"]                               = "Options Text Size"
-- L["FOCUS_OPTIONS_TEXT_FONT_SIZE"]                          = "Options button label font size."
L["FOCUS_PROGRESS_BAR_FILL"]                                  = "Füllung der Fortschrittsleiste"
L["FOCUS_PROGRESS_BAR_TEXT"]                                  = "Text der Fortschrittsleiste"
L["FOCUS_OUTLINE"]                                            = "Kontur"
L["FOCUS_FONT_OUTLINE_STYLE"]                                 = "Schriftkonturstil"

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["FOCUS_HEADER_TEXT_CASE"]                                   = "Groß-/Kleinschreibung für Kopfzeile"
L["FOCUS_DISPLAY_CASE_HEADER"]                                = "Groß-/Kleinschreibung für die Kopfzeile."
L["FOCUS_SECTION_HEADER_CASE"]                                = "Groß-/Kleinschreibung für Abschnitte"
L["FOCUS_DISPLAY_CASE_CATEGORY_LABELS"]                       = "Groß-/Kleinschreibung für die Abschnittsüberschriften."
L["FOCUS_QUEST_TITLE_CASE"]                                   = "Groß-/Kleinschreibung für Titel"
L["FOCUS_DISPLAY_CASE_QUEST_TITLES"]                          = "Groß-/Kleinschreibung für die Quest-Titel."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["FOCUS_TEXT_SHADOW"]                                        = "Textschatten anzeigen"
L["FOCUS_ENABLE_DROP_SHADOW_TEXT"]                            = "Schattierung für Text aktivieren."
L["FOCUS_SHADOW_X"]                                           = "X-Schattenversatz"
L["FOCUS_HORIZONTAL_SHADOW_OFFSET"]                           = "Horizontaler Schattenversatz."
L["FOCUS_SHADOW_Y"]                                           = "Y-Schattenversatz"
L["FOCUS_VERTICAL_SHADOW_OFFSET"]                             = "Vertikaler Schattenversatz."
L["FOCUS_SHADOW_ALPHA"]                                       = "Schattendeckkraft"
L["FOCUS_SHADOW_OPACITY"]                                     = "Schattendeckkraft (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["FOCUS_MYTHIC_TYPOGRAPHY"]                                  = "Mythisch-Plus-Typografie"
L["FOCUS_DUNGEON_NAME_SIZE"]                                  = "Schriftgröße für Dungeon-Name"
L["FOCUS_FONT_SIZE_DUNGEON_NAME_PX"]                          = "Schriftgröße des Dungeon-Namens (8–32 px)."
L["FOCUS_DUNGEON_NAME_COLOUR"]                                = "Farbe des Dungeon-Namens"
L["FOCUS_TEXT_COLOUR_DUNGEON_NAME"]                           = "Textfarbe des Dungeon-Namens."
L["FOCUS_TIMER_SIZE"]                                         = "Schriftgröße des Timer"
L["FOCUS_FONT_SIZE_TIMER_PX"]                                 = "Schriftgröße für Timer (8–32 px)."
L["FOCUS_TIMER_COLOUR"]                                       = "Farbe des Timers"
L["FOCUS_TEXT_COLOUR_TIMER"]                                  = "Textfarbe für Timer (in Zeit)."
L["FOCUS_TIMER_OVERTIME_COLOUR"]                              = "Farbe für Überzeit-Timer"
L["FOCUS_TEXT_COLOUR_TIMER_LIMIT"]                            = "Textfarbe für Timer bei Überschreitung."
L["FOCUS_PROGRESS_SIZE"]                                      = "Schriftgröße für Fortschritt"
L["FOCUS_FONT_SIZE_ENEMY_FORCES_PX"]                          = "Schriftgröße für feindliche Streitkräfte (8–32 px)."
L["FOCUS_PROGRESS_COLOUR"]                                    = "Farbe für Fortschritt"
L["FOCUS_TEXT_COLOUR_ENEMY_FORCES"]                           = "Textfarbe für feindliche Streitkräfte."
L["FOCUS_BAR_FILL_COLOUR"]                                    = "Farbe der Leistenfüllung"
L["FOCUS_PROGRESS_BAR_FILL_COLOUR_PROGRESS"]                  = "Füllfarbe der Fortschrittsleiste (im Gange)."
L["FOCUS_BAR_COMPLETE_COLOUR"]                                = "Farbe der Leistenfüllung (abgeschlossen)"
L["FOCUS_PROGRESS_BAR_FILL_COLOUR_ENEMY_FORCES"]              = "Füllfarbe der Fortschrittsleiste bei 100 % feindlicher Streitkräfte."
L["FOCUS_AFFIX_SIZE"]                                         = "Schriftgröße für Affixe"
L["FOCUS_FONT_SIZE_AFFIXES_PX"]                               = "Schriftgröße für Affixe (8–32 px)."
L["FOCUS_AFFIX_COLOUR"]                                       = "Farbe für Affixe"
L["FOCUS_TEXT_COLOUR_AFFIXES"]                                = "Textfarbe für Affixe."
L["FOCUS_BOSS_SIZE"]                                          = "Schriftgröße für Bosse"
L["FOCUS_FONT_SIZE_BOSS_NAMES_PX"]                            = "Schriftgröße für Bossnamen (8–32 px)."
L["FOCUS_BOSS_COLOUR"]                                        = "Farbe für Bosse"
L["FOCUS_TEXT_COLOUR_BOSS_NAMES"]                             = "Textfarbe für Bossnamen."
L["FOCUS_RESET_MYTHIC_TYPOGRAPHY"]                            = "Mythisch-Plus-Typografie zurücksetzen"

-- =====================================================================
-- OptionsData.lua Appearance
-- =====================================================================
L["DASH_FRAME"]                                               = "Rahmen"
L["FOCUS_CLASS_COLOURS_DASHBOARD"]                            = "Klassenfarben – Dashboard"
L["FOCUS_CLASS_COLOURS"]                                      = "Klassenfarben"
L["FOCUS_ENABLE_CLASS_COLOURS"]                               = "Sämtliche Klassenfärbungen aktivieren"
L["DASH_CLASS_COLOURS_MODULES_GLOBAL"]                        = "Schaltet Klassenfärbung für alle Modules ein."
-- L["FOCUS_DASHBOARD"]                                       = "Dashboard"
L["FOCUS_CLASS_COLOURS_DESC"]                                 = "Klassenfärbung für Focus-Zielverfolger: Kopfzeile, Abschnittsüberschriften, Trennlinien, Hervorhebungsleisten und Umrandungen für super-verfolgte Quests."
L["PRESENCE_CLASS_COLOURS_DESC"]                              = "Klassenfärbung für Presence-Benachrichtigungen: überschriften und Trennlinien."
L["VISTA_CLASS_COLOURS_DESC"]                                 = "Klassenfärbung für Vista-Minikarte: Addon-Leiste, Anzeigeumrandung und Texte."
L["INSIGHT_CLASS_COLOURS_DESC"]                               = "Klassenfärbung für Insight-Tooltips: Spielernamen, Klassentext und Umrandung."
L["CACHE_CLASS_COLOURS_DESC"]                                 = "Klassenfärbung für Cache-Beuteanzeige: Symbolleuchten und Bearbeitungs-/Ankerumrandungen."
L["ESSENCE_CLASS_COLOURS_DESC"]                               = "Klassenfärbung für Essence-Charakterdatenblatt: Charakternamename."
L["AXIS_CLASS_COLOURS_DESC"]                                  = "Dashboard-Akzente, Trennlinien und Hervorhebungen mit Klassenfarbe einfärben."
L["DASH_THEME"]                                               = "Motiv"
L["FOCUS_DASHBOARD_BACKGROUND"]                               = "Dashboard-Hintergrund"
L["DASH_BACKGROUND"]                                          = "Hintergrundstil des Modul-Dashboards (Axis). Standard: Minimalistisch; Midnight nutzt enthaltene Grafiken; Spezialisierung (dynamisch) nutzt die Talenthintergründe des Spiels der gegenwärtigen Spezialisierung."
L["FOCUS_DASHBOARD_BACKGROUND_MINIMALISTIC"]                  = "Minimalistisch"
-- L["FOCUS_DASHBOARD_BACKGROUND_MIDNIGHT"]                   = "Midnight"
L["FOCUS_DASHBOARD_BACKGROUND_TELDRASSIL_BURNS"]              = "Teldrassil (brennend)"
L["FOCUS_DASHBOARD_BACKGROUND_NIGHTFAE"]                      = "Nachtfae"
L["FOCUS_DASHBOARD_BACKGROUND_ARDENWEALD"]                    = "Ardenwald"
-- L["FOCUS_DASHBOARD_BACKGROUND_ZIN_AZSHARI"]                = "Zin-Azshari"
L["FOCUS_DASHBOARD_BACKGROUND_SURAMAR_GARDEN"]                = "Suramar-Gärten"
-- L["DASH_BACKGROUND_QUEL_THALAS"]                           = "Quel'Thalas"
L["FOCUS_DASHBOARD_BACKGROUND_TWILIGHT_VINEYARDS"]            = "Zwielichtweinberge"
-- L["FOCUS_DASHBOARD_BACKGROUND_ZUL_AMAN"]                   = "Zul'Aman"
-- L["FOCUS_DASHBOARD_BACKGROUND_ILLIDAN"]                    = "Illidan"
L["FOCUS_DASHBOARD_BACKGROUND_LICH_KING"]                     = "Der Lichkönig"
-- L["FOCUS_DASHBOARD_BACKGROUND_TBC_ANNIVERSARY"]            = "TBC Anniversary"
L["FOCUS_DASHBOARD_BACKGROUND_BELEDARS_LIGHT"]                = "Beledars Licht"
L["FOCUS_DASHBOARD_BACKGROUND_CLASS_TALENTS"]                 = "Spezialisierung"
L["FOCUS_DASHBOARD_BACKGROUND_OPACITY"]                       = "Deckkraft des Dashboard-Hintergrunds"
L["FOCUS_ADJUST_OPACITY_OF_DASHBOARD_BACKGROUND"]             = "Anpassung der Hintergrunddeckkraft des Dashboards (50–100 %). Niedrigere Werte zeigen mehr von der Spielwelt."
L["DASHBOARD_TYPO_SECTION"]                                   = "Dashboard-Typografie"
L["DASHBOARD_TYPO_FONT"]                                      = "Schriftart des Dashboard-Textes"
L["DASHBOARD_TYPO_FONT_DESC"]                                 = "Schriftart für das Axis-Einstellungsfenster (Seitenleiste, Suche und Optionseinträge). Unabhängig von Schriftart des Focus-Zielverfolgers. Für CJK- oder Mixed-Script-Willkommenstext, nötigenfalls Schriftart mit breiter Unterstützung (z.B. 2002) wählen."
L["DASHBOARD_TYPO_SIZE"]                                      = "Schriftgröße des Dashboard-Texts"
L["DASHBOARD_TYPO_SIZE_DESC"]                                 = "Skalierung des Dashboard-Textes (−4 to +4), ähnlich zur globalen Schriftgrößenänderung bei Focus."
L["DASHBOARD_TYPO_OUTLINE"]                                   = "Schriftkontur des Dashboard-Textes"
L["DASHBOARD_TYPO_OUTLINE_DESC"]                              = "When on, dashboard UI text uses the standard outlined font style. Turn off for a softer, flat look."
L["DASHBOARD_TYPO_SHADOW"]                                    = "Textschattierung für Dashboard-Text"
L["DASHBOARD_TYPO_SHADOW_DESC"]                               = "Fügt einen subtilen Schlagschatten hinter dem Dashboard-Text, um die Lesbarkeit zu verbessern."
L["FOCUS_BACKDROP_OPACITY"]                                   = "Deckkraft des Hintergrunds"
L["FOCUS_PANEL_BACKGROUND_OPACITY"]                           = "Hintergrunddeckkraft des Fensters (0–1)."
L["FOCUS_BORDER"]                                             = "Rahmen anzeigen"
L["FOCUS_BORDER_AROUND_TRACKER"]                              = "Rahmen um den Zielverfolger anzeigen."
L["FOCUS_SCROLL_INDICATOR"]                                   = "Scroll-Indikator anzeigen"
L["FOCUS_A_VISUAL_HINT_LIST_CONTENT_TH"]                      = "Visuellen Hinweis anzeigen, wenn mehr Inhalt als sichtbar vorhanden."
L["FOCUS_SCROLL_INDICATOR_STYLE"]                             = "Scroll-Indikatorstil"
L["FOCUS_CHOOSE_BETWEEN_A_FADE_GRADIENT_A"]                   = "Verlauf oder Pfeil für scrollbaren Inhalt wählen."
L["FOCUS_ARROW"]                                              = "Pfeil"
L["FOCUS_HIGHLIGHT_ALPHA"]                                    = "Deckkraft der Hervorhebung"
L["FOCUS_OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]                 = "Deckkraft der Quest-Hervorhebung (0–1)."
L["FOCUS_BAR_WIDTH"]                                          = "Breite der Leiste"
L["FOCUS_WIDTH_OF_BAR_STYLE_HIGHLIGHTS_PX"]                   = "Breite der Leistenhervorhebung (2–6)."

-- =====================================================================
-- OptionsData.lua Organisation
-- =====================================================================
L["FOCUS_ACTIVITY"]                                           = "Aktivität"
L["FOCUS_CONTENT"]                                            = "Inhalt"
L["FOCUS_SORTING"]                                            = "Sortierung"
L["FOCUS_ELEMENTS"]                                           = "Elemente"
L["FOCUS_CATEGORY_ORDER"]                                     = "Fokus-Abschnittsanordnung"
L["FOCUS_CATEGORY_COLOUR_BAR"]                                = "Färbung der Leiste nach Abschnitt"
L["FOCUS_CHECKMARK_COMPLETED"]                                = "Häkchen für abgeschlossen"
L["FOCUS_CURRENT_QUEST_CATEGORY"]                             = "Abschnitt für aktuelle Quest"
L["FOCUS_CURRENT_QUEST_WINDOW"]                               = "Aktuelle Quest-Fenster"
L["FOCUS_QUESTS_RECENT_PROGRESS_TOP"]                         = "Quests mit kürzlichem Fortschritt oben auflisten."
L["FOCUS_RECENT_QUEST_SECONDS"]                               = "Sekundenfortschritt für aktuelle Quest (30–120)."
L["FOCUS_QUEST_PROGRESSION_SECTION"]                          = "Quests mit Fortschritt in der letzten Minute erscheinen in eigenem Abschnitt."
L["FOCUS_SHOW_ZONE_EVENTS"]                                   = "Abschnitt für Zonenereignisse"
L["FOCUS_SHOW_ZONE_EVENTS_DESC"]                              = "Zeige Abschnitt für Zonenergeignisse, für nahe verfügbarre Quests und Zonenereignis-Quests."
L["FOCUS_SHOW_ZONE_EVENTS_TIP"]                               = "AUS: Diese Quests werden in ihrem normalen Abschnitt gelistet."
L["FOCUS_CATEGORY_ORDER"]                                     = "Fokus-Abschnittsanordnung"
L["FOCUS_CATEGORIES_REORDER_EXCEPT_DELVES_SCENARIOS"]         = "Ziehen zum Ändern der Abschnittsreihenfolge. Tiefen und Szenarioereignisse bleiben zuerst gelistet."
L["FOCUS_CATEGORIES_REORDER_EXCEPT_DELVES_SCENARIOS_TIP"]     = "Ziehen zum Ändern der Reihenfolge. Tiefen und Szenarien bleiben zuerst."
L["FOCUS_SORT_MODE"]                                          = "Fokus-Sortiermethode"
L["FOCUS_ENTRY_NUMBER_IN_CATEGORY"]                           = "Reihenfolge der Einträge innerhalb jeder Kategorie."
L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS"]                         = "Angenommene Quests automatisch verfolgen"
L["FOCUS_AUTO_TRACK_ACCEPTED_QUESTS_TIP"]                     = "Angenommene Quests (nur Questlog, nicht Weltquests) automatisch zum Zielverfolger hinzufügen."
L["FOCUS_CTRL_FOCUS_REMOVE"]                                  = "STRG für Fokussieren & Entfolgen erforderlich"
L["FOCUS_CTRL_FOCUS_REMOVE_MOUSECLICK"]                       = "STRG für Fokussieren/Hinzufügen (Links) und Entfokussieren/Entfernen (Rechts) erforderlich, um Fehlklicks zu vermeiden."
L["FOCUS_CTRL_FOCUS_UNTRACK"]                                 = "STRG für Fokussieren & Entfolgen"
L["FOCUS_CTRL_CLICK_COMPLETE"]                                = "STRG für Klickabschluss"
L["FOCUS_CLASSIC_CLICK_BEHAVIOUR"]                            = "Klassisches Klickverhalten verwenden"
L["FOCUS_CLASSIC_CLICKS"]                                     = "Klassische Klicks"
-- === Focus Click Profiles ===
L["FOCUS_CLICK_PROFILE"]                                      = "Mausklickprofil"
L["FOCUS_CLICK_PROFILE_DESC"]                                 = "Auswählen, wie sich Mausklicks auf Zielverfolgereinträge auswirken."
L["FOCUS_ICON_CLICK_ACTION"]                                  = "Klickaktion für Quest- & Vorlagensymbol"
L["FOCUS_ICON_CLICK_ACTION_DESC"]                             = "Verhalten bei Mausklick direkt auf Quest- oder Vorlagensymbole."
-- L["FOCUS_PROFILE_HORIZON_PLUS"]                            = "Horizon+"
L["FOCUS_PROFILE_BLIZZARD_DEFAULT"]                           = "Blizzard-Standard"
L["FOCUS_PROFILE_CUSTOM"]                                     = "Benutzerdefiniert"
L["FOCUS_COMING_SOON"]                                        = "In Kürze"
L["FOCUS_CLICK_COMBOS"]                                       = "Benutzerdefinierte Belegung"
L["FOCUS_CLICK_COMBO_LOCKED_TOOLTIP"]                         = "Für dieses Profil gesperrt. Benutzerdefiniertes Profil wählen, um Belegung anzupassen."
L["FOCUS_CLICK_SAFETY"]                                       = "Sicherheit"
L["FOCUS_COMBO_LEFT"]                                         = "Linksklick"
L["FOCUS_COMBO_SHIFT_LEFT"]                                   = "UMSCH+Linksklick"
L["FOCUS_COMBO_CTRL_LEFT"]                                    = "STRG+Linksklick"
L["FOCUS_COMBO_ALT_LEFT"]                                     = "ALT+Linksklick"
L["FOCUS_COMBO_RIGHT"]                                        = "Rechtsklick"
L["FOCUS_COMBO_SHIFT_RIGHT"]                                  = "UMSCH+Rechtsklick"
L["FOCUS_COMBO_CTRL_RIGHT"]                                   = "STRG+Rechtsklick"
L["FOCUS_COMBO_ALT_RIGHT"]                                    = "ALT+Rechtsklick"
L["FOCUS_CLICK_ACTION_NONE"]                                  = "Nichts tun"
L["FOCUS_CLICK_ACTION_SUPER_TRACK"]                           = "Quest fokussieren"
L["FOCUS_CLICK_ACTION_OPEN_DETAILS"]                          = "Relevante Details anzeigen"
L["FOCUS_CLICK_ACTION_OPEN_PROFESSION"]                       = "Berufsfenster oder Quest-Details öffnen"
L["FOCUS_CLICK_ACTION_OPEN_QUEST_LOG"]                        = "Quest-Log öffnen"
L["FOCUS_CLICK_ACTION_UNTRACK"]                               = "Verfolgung beenden"
L["FOCUS_CLICK_ACTION_CONTEXT_MENU"]                          = "Kontextmenü"
L["FOCUS_CLICK_ACTION_SHARE"]                                 = "Mit Gruppe teilen"
L["FOCUS_CLICK_ACTION_ABANDON"]                               = "Quest abbrechen"
L["FOCUS_CLICK_ACTION_WOWHEAD"]                               = "Wowhead-Link"
L["FOCUS_CLICK_ACTION_CHAT_LINK"]                             = "In Chat verlinken"
L["FOCUS_CLICK_ACTION_PREVIEW"]                               = "Vorschau"
L["FOCUS_APPEARANCE_CANNOT_SHARE"]                            = "Vorlagen können nicht wie Quests geteilt werden."
L["FOCUS_QUEST_DETAILS_AFTER_COMBAT"]                         = "Quest-Details werden nach dem Kampf geöffnet."
L["FOCUS_SHARE_PARTY"]                                        = "Mit Gruppe teilen"
L["FOCUS_ABANDON_QUEST"]                                      = "Quest abbrechen"
L["FOCUS_CONTEXT_FOCUS_QUEST"]                                = "Quest fokussieren"
L["FOCUS_STOP_TRACKING"]                                      = "Verfolgung beenden"
L["FOCUS_CONTEXT_OPEN_ACHIEVEMENT"]                           = "Erfolg anzeigen"
L["FOCUS_CONTEXT_OPEN_ENDEAVOR"]                              = "Unterfangen anzeigen"
L["FOCUS_CONTEXT_OPEN_RECIPE"]                                = "Rezept anzeigen"
L["FOCUS_CONTEXT_OPEN_DECOR_CATALOG"]                         = "In Katalog öffnen"
L["FOCUS_CONTEXT_PREVIEW_DECOR"]                              = "Dekorvorschau"
L["FOCUS_CONTEXT_SHOW_DECOR_MAP"]                             = "Auf Karte zeigen"
L["FOCUS_CONTEXT_OPEN_TRAVELERS_LOG"]                         = "Reisetagebuch öffnen"
L["FOCUS_CONTEXT_SET_RARE_WAYPOINT"]                          = "Wegpunkt setzen"
L["FOCUS_CONTEXT_CLEAR_RARE_FOCUS"]                           = "Kartenfokus entfernen"
L["FOCUS_TRACKED_CONTENT_CANNOT_SHARE"]                       = "Dieser Eintrag kann nicht mit der Gruppe geteilt werden."
L["FOCUS_CANNOT_SHARE_QUEST"]                                 = "Diese Quest kann nicht geteilt werden."
L["FOCUS_REQUIRE_PARTY_SHARE"]                                = "Ihr müsst in einer Gruppe sein, um diese Quest zu teilen."
L["FOCUS_LEFT_CLICK_MAP_RIGHT_CLICK_ABANDON"]                 = "Ein: Linksklick öffnet Questkarte, Rechtsklick Teilen/Abbruch (Blizzard). Aus: Linksklick fokussiert, Rechtsklick nicht verfolgen; Strg+Rechts teilt."
L["FOCUS_ANIMATIONS"]                                         = "Animationen"
L["FOCUS_SLIDE_FADE_QUESTS"]                                  = "Wisch- und Verblassungseffekte für Quests aktivieren."
L["FOCUS_OBJECTIVE_PROGRESS_FLASH"]                           = "Aufleuchten bei Zielfortschritt"
L["FOCUS_FLASH_OBJECTIVE_COMPLETION"]                         = "Leuchten bei Zielabschluss anzeigen."
L["FOCUS_FLASH_INTENSITY"]                                    = "Leuchtintensität"
L["FOCUS_OBJECTIVE_PROGRESS_FLASH_VISIBILITY"]                = "Auffälligkeit des Zielabschlussleuchtens."
L["FOCUS_FLASH_COLOUR"]                                       = "Leuchtfarbe"
L["FOCUS_FLASH_COLOUR_DESC"]                                  = "Farbe des Zielabschlussleuchtens."
L["FOCUS_SUBTLE"]                                             = "Dezent"
L["FOCUS_MEDIUM"]                                             = "Mittel"
L["FOCUS_STRONG"]                                             = "Intensiv"
L["FOCUS_REQUIRE_CTRL_CLICK_COMPLETE"]                        = "STRG für Klick zum Abschließen erforderlich"
L["FOCUS_REQUIRES_CTRL_LEFT_CLICK_COMPLETE_AUTO"]             = "EIN: STRG+Linksklick für Klick-Abschluss. AUS: einfacher Linksklick (Blizzard-Standard). Nur bei klickbaren Quests."
L["FOCUS_SUPPRESS_UNTRACKED_UNTIL_RELOAD"]                    = "Nicht verfolgte Quests bis Neuladen unterdrücken"
L["FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS"]                   = "EIN: Rechtsklick Nicht verfolgen versteckt bis Neuladen oder neuer Sitzung. AUS: erscheinen wieder bei Zonen-Rückkehr."
L["FOCUS_PERMANENTLY_SUPPRESS_UNTRACKED_QUESTS"]              = "Nicht verfolgte Quests dauerhaft unterdrücken"
L["FOCUS_RIGHT_CLICK_UNTRACK_WORLD_QUESTS_DESC"]              = "EIN: Rechtsklick Nicht verfolgen versteckt dauerhaft (über Neuladen). Vorrang vor „Bis Neuladen\". Annehmen entfernt von Sperrliste."
L["FOCUS_KEEP_CAMPAIGN_CATEGORY"]                             = "Kampagnen-Quest in Abschnitt behalten"
L["FOCUS_CAMPAIGN_READY_STAY"]                                = "EIN: abgabebereite Kampagnen-Quests verbleiben im Kampagnenabschnitt statt in Abgeschlossen."
L["FOCUS_KEEP_IMPORTANT_QUESTS_CATEGORY"]                     = "Prioritäts-Quests in Abschnitt behalten"
L["FOCUS_IMPORTANT_READY_STAY"]                               = "EIN: Abgabebereite Prioritäts-Quests bleiben im Abschnitt Priorität statt Abgeschlossen."
L["FOCUS_TOMTOM_QUEST_WAYPOINT"]                              = "TomTom-Wegpunkte für Quests"
L["FOCUS_TOMTOM_QUEST_WAYPOINT_TIP"]                          = "TomTom-Wegpunkt beim Fokussieren einer Quest setzen."
L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_NEXT_QUEST"]            = "TomTom erforderlich. Der Pfeil zeigt auf das nächste Quest-Ziel."
L["FOCUS_TOMTOM_RARE_WAYPOINT"]                               = "TomTom-Wegpunkte für Seltenes"
L["FOCUS_TOMTOM_WAYPOINT_RARE_CLICK"]                         = "TomTom-Wegpunkt setzen beim Klicken auf einen seltenen Gegner."
L["FOCUS_REQUIRES_TOMTOM_POINTS_ARROW_RARE"]                  = "TomTom erforderlich. Der Pfeil zeigt auf die Position des seltenen Gegners."
L["FOCUS_FIND_GROUP"]                                         = "Gruppe finden"
L["FOCUS_GROUP_QUEST_SEARCH_CLICK"]                           = "Klicken, um eine Gruppe für diese Quest zu suchen."

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
L["FOCUS_BLACKLIST"]                                          = "Sperrliste"
L["FOCUS_BLACKLIST_UNTRACKED"]                                = "Nicht verfolgte sperren"
L["FOCUS_ENABLE_BLACKLIST_UNTRACKED_BEHAVIOUR_ADD_QUEST"]     = "„Nicht verfolgte sperren\" in Verhalten aktivieren, um Quests hier hinzuzufügen."
L["FOCUS_HIDDEN_QUESTS"]                                      = "Versteckte Quests"
L["FOCUS_QUESTS_HIDDEN_RIGHT_CLICK_UNTRACK"]                  = "Durch Rechtsklick versteckte Quests nicht verfolgen."
L["FOCUS_BLACKLISTED_QUESTS"]                                 = "Gesperrte Quests"
L["FOCUS_PERMANENTLY_SUPPRESSED_QUESTS"]                      = "Dauerhaft unterdrückte Quests"
L["FOCUS_RIGHT_CLICK_UNTRACK_QUESTS_PERMANENTLY_SUPPRESS"]    = "Mit Rechtsklick dauerhaft unterdrückte Quests werden hier gelistet."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["PRESENCE_QUEST_TYPE_ICONS"]                                = "Quest-Typsymbole anzeigen"
L["PRESENCE_QUEST_TYPE_ICON_FOCUS_TRACKER_QUEST"]             = "Quest-Typsymbole im Zielverfolger anzeigen."
L["PRESENCE_QUEST_TYPE_ICONS_TOASTS"]                         = "Quest-Typsymbole in Benachrichtigungen anzeigen."
L["PRESENCE_QUEST_TYPE_ICON_PRESENCE_TOASTS_QUEST"]           = "Quest-Typsymbole in Presence-Benachrichtigungen anzeigen."
L["PRESENCE_TOAST_ICON_SIZE"]                                 = "Symbolgröße für Benachrichtigungen"
L["PRESENCE_QUEST_ICON_SIZE_PRESENCE_TOASTS_PX"]              = "Quest-Symbolgröße in Presence-Benachrichtigungen (16–36 px). Standard 24."
L["PRESENCE_HIDE_QUEST_UPDATE_TITLE"]                         = "Quest-Titel bei Aktualisierungen verbergen"
L["PRESENCE_OBJECTIVE_LINE_QUEST_PROGRESS_TOAST"]             = "Nur Ziele in Benachrichtigungen über Quest-Fortschritte (z.B. 7/10 Eberfelle), ohne Quest-Titel oder Abschnitt anzeigen."
L["PRESENCE_SHOW_DISCOVERY_LINE"]                             = "Entdeckungszeile anzeigen"
L["PRESENCE_DISCOVERY_LINE"]                                  = "Entdeckungszeile"
L["PRESENCE_SHOW_DISCOVERED"]                                 = "„Entdeckt\" unter Zone/Unterzone bei neuem Gebiet anzeigen."
L["PRESENCE_FRAME_VERTICAL_POSITION"]                         = "Vertikaler Versatz"
L["PRESENCE_VERTICAL_OFFSET_OF_PRESENCE_FRAME_CENTER"]        = "Vertikaler Versatz des Presence-Rahmens von Mitte (-300 bis 0)."
L["PRESENCE_FRAME_SCALE"]                                     = "Skalierung"
L["PRESENCE_FRAME_SCALE_TIP"]                                 = "Skalierung des Presence-Rahmens (0.5–2)."
L["PRESENCE_BOSS_EMOTE_COLOUR"]                               = "Farbe von Boss-Geschwätz"
L["PRESENCE_COLOUR_RAID_DUNGEON_BOSS_EMOTE"]                  = "Farbe von Boss-Emote-Texten in Schlachtzügen und Dungeons."
L["PRESENCE_DISCOVERY_LINE_COLOUR"]                           = "Farbe der Entdeckungszeile"
L["PRESENCE_COLOUR_OF_DISCOVERED_LINE_UNDER_ZONE_TIP"]        = "Farbe der „Entdeckt\"-Zeile unter dem Zonentext."
L["PRESENCE_NOTIFICATION_TYPES"]                              = "Benachrichtigungsarten"
L["PRESENCE_NOTIFICATIONS"]                                   = "Benachrichtigungen"
L["PRESENCE_NOTIFICATION_ACHIEVEMENT_CRITERIA_UPDATE"]        = "Benachrichtigung bei Aktualisierung von Erfolgskriterien (verfolgte immer; andere wenn Blizzard ID liefert)."
L["PRESENCE_ZONE_ENTRY"]                                      = "Zonenwechsel anzeigen"
L["PRESENCE_ZONE_CHANGE_ENTERING_A_AREA"]                     = "Zonenwechsel beim Betreten neuer Gebiete anzeigen."
L["PRESENCE_SUBZONE_CHANGES"]                                 = "Unterzonenwechsel anzeigen"
L["PRESENCE_SUBZONE_CHANGE_MOVING_WITHIN_SAME_ZONE"]          = "Wechsel von Unterzonen in gleichbleibender Zone anzeigen."
L["PRESENCE_HIDE_ZONE_NAME_SUBZONE_CHANGES"]                  = "Zonennamen bei Unterzonenwechsel verbergen"
L["PRESENCE_MOVING_BETWEEN_SUBZONES_WITHIN_SAME_ZONE"]        = "Bei Unterzonenwechsel in gleicher Zone nur Unterzonenname. Zonennamen erscheint bei neuer Zone."
L["PRESENCE_SUPPRESS_DELVE"]                                  = "In Tiefen unterdrücken"
L["PRESENCE_SUPPRESS_SCENARIO_PROGRESS_NOTIFICATIONS_DELVES"]   = "Benachrichtigungen zu Szenariofortschritten in Tiefen unterdrücken."
L["PRESENCE_HIDE_DELVE_OBJECTIVE_UPDATE"]                     = "EIN: Zielaktualisierungen in Tiefen verbergen. Zonenwechsel und Abschlussbenachrichtigungen werden weiterhin angezeigt."
L["PRESENCE_SUPPRESS_ZONE_CHANGES_MYTHIC"]                    = "Zonenwechsel in Mythisch-Plus unterdrücken"
L["PRESENCE_MYTHICPLUS_SHOW_BOSS_EMOTES_ACHIEVEMENTS_LEVELS"]   = "In Mythisch-Plus nur Bossgeschwätz, Erfolge und Stufenaufstieg. Zonen-, Quest- und Szenariobenachrichtigungen verbergen."
L["PRESENCE_LEVEL"]                                           = "Stufenaufstieg anzeigen"
L["PRESENCE_LEVEL_NOTIFICATION"]                              = "Benachrichtigungen zu Stufenaufstiege anzeigen."
L["PRESENCE_BOSS_EMOTES"]                                     = "Bossgeschwätz anzeigen"
L["PRESENCE_RAID_DUNGEON_BOSS_EMOTE_NOTIFICATIONS"]           = "Schlachtzug- und Dungeon-Boss-Emote-Benachrichtigungen anzeigen."
L["PRESENCE_ACHIEVEMENTS"]                                    = "Erfolge anzeigen"
L["PRESENCE_ACHIEVEMENT_EARNED_NOTIFICATIONS"]                = "Benachrichtigungen bei errungenen Erfolgen anzeigen."
L["PRESENCE_ACHIEVEMENT_PROGRESS"]                            = "Erfolgsfortschritt"
L["PRESENCE_SHOW_ACHIEVEMENT_EARNED"]                         = "Erfolg errungen"
L["PRESENCE_SHOW_QUEST_ACCEPTED"]                             = "Quest angenommen"
L["PRESENCE_SHOW_WORLD_QUEST_ACCEPTED"]                       = "Welt-Quest angenommen"
L["PRESENCE_SHOW_SCENARIO_COMPLETE"]                          = "Szenario abgeschlossen"
L["PRESENCE_SHOW_RARE_DEFEATED"]                              = "Seltener Gegner besiegt"
L["PRESENCE_NOTIFICATION_TRACKED_ACHIEVEMENT_CRITERIA"]       = "Benachrichtigung bei Aktualisierung von Kriterien verfolgter Erfolge anzeigen."
L["PRESENCE_QUEST_ACCEPT"]                                    = "Quest-Annahme anzeigen"
L["PRESENCE_NOTIFICATION_ACCEPTING_A_QUEST"]                  = "Benachrichtigung bei Quest-Annahme anzeigen."
L["PRESENCE_WORLD_QUEST_ACCEPT"]                              = "Weltquest-Annahme anzeigen"
L["PRESENCE_NOTIFICATION_ACCEPTING_A_WORLD_QUEST"]            = "Benachrichtigung bei Weltquest-Annahme anzeigen."
L["PRESENCE_SHOW_QUEST_COMPLETE"]                             = "Quest-Abschluss anzeigen"
L["PRESENCE_NOTIFICATION_COMPLETING_A_QUEST"]                 = "Benachrichtigung bei Quest-Abschluss anzeigen."
L["PRESENCE_SHOW_WORLD_QUEST_COMPLETE"]                       = "Welt-Quest-Abschluss anzeigen"
L["PRESENCE_NOTIFICATION_COMPLETING_A_WORLD_QUEST"]           = "Benachrichtigung bei Welt-Quest-Abschluss anzeigen."
L["PRESENCE_QUEST_PROGRESS"]                                  = "Quest-Fortschritt anzeigen"
L["PRESENCE_NOTIFICATION_QUEST_OBJECTIVES_UPDATE"]            = "Benachrichtigung bei Quest-Zielaktualisierung anzeigen."
L["PRESENCE_OBJECTIVE"]                                       = "Nur Ziele"
L["PRESENCE_QUEST_PROGRESS_HIDE_TITLE"]                       = "Nur Ziele in Benachrichtigungen zu Quest-Fortschritt. Quest-Titel verbergen."
L["PRESENCE_SCENARIO_START"]                                  = "Szenariobeginn anzeigen"
L["PRESENCE_NOTIFICATION_ENTERING_A_SCENARIO_DELVE"]          = "Benachrichtigung bei Szenario- oder Tiefen-Eintritt anzeigen."
L["PRESENCE_SCENARIO_PROGRESS"]                               = "Szenariofortschritt anzeigen"
L["PRESENCE_NOTIFICATION_SCENARIO_DELVE_OBJECTIVES"]          = "Benachrichtigung bei Aktualisierungen von Szenarien- und Tiefen-Zielen anzeigen."
L["PRESENCE_ANIMATION"]                                       = "Animationen"
L["PRESENCE_ENABLE_ANIMATIONS"]                               = "Animationen aktivieren"
L["PRESENCE_ENABLE_ENTRANCE_EXIT_ANIMATIONS_PRESENCE"]        = "Ein- und Ausblendanimationen für Presence-Benachrichtigungen aktivieren."
L["PRESENCE_ENTRANCE_DURATION"]                               = "Einblenddauer"
L["PRESENCE_DURATION_OF_ENTRANCE_ANIMATION_SECONDS"]          = "Dauer der Einblendanimation in Sekunden (0.2–1,5)."
L["PRESENCE_EXIT_DURATION"]                                   = "Ausblenddauer"
L["PRESENCE_DURATION_OF_EXIT_ANIMATION_SECONDS"]              = "Dauer der Ausblendanimation in Sekunden (0.2–1.5)."
L["PRESENCE_HOLD_DURATION_SCALE"]                             = "Anzeigedauer-Multiplikator"
L["PRESENCE_MULTIPLIER_LONG_NOTIFICATION_STAY"]               = "Multiplikator für Anzeigedauer aller Benachrichtigungen (0,5–2)."
L["PRESENCE_PREVIEW"]                                         = "Vorschau"
L["PRESENCE_PREVIEW_TOAST_TYPE"]                              = "Benachrichtigungstyp der Vorschau"
L["PRESENCE_SELECT_A_TOAST_TYPE_PREVIEW"]                     = "Auswahl des Benachrichtigungstyps zur Vorschau."
L["PRESENCE_SELECTED_TOAST_TYPE"]                             = "Gewählten Benachrichtigungstyp anzeigen."
L["PRESENCE_PREVIEW_PRESENCE_TOAST_LAYOUTS_LIVE_OPEN"]        = "Presence-Benachrichtigungen mit einem abekoppelten Fenster testen."
L["PRESENCE_OPEN_DETACHED_PREVIEW"]                           = "Entkoppelte Vorschau öffnen"
L["PRESENCE_OPEN_A_MOVABLE_PREVIEW_WINDOW_STAYS"]             = "Öffnet ein bewegliches Vorschaufenster zum Testen während zeitgleich andere Presence-Einstellungen angepasst werden können."
L["PRESENCE_ANIMATE_PREVIEW"]                                 = "Animierte Vorschau"
L["PRESENCE_PLAY_SELECTED_TOAST_ANIMATION_INSIDE_PREVIEW"]    = "Spielt die gewählte animierte Benachrichtigung innerhalb dieses Vorschaufensters ab."
L["PRESENCE_DETACHED_PREVIEW"]                                = "Entkoppelte Vorschau"
L["PRESENCE_KEEP_OPEN_WHILE_ADJUSTING_TYPOGRAPHY_COLOURS"]    = "Bleibt geöffnet während zeitgleich Typografie und Farben angepasst werden können."
L["DASH_TYPOGRAPHY"]                                          = "Typografie"
L["PRESENCE_MAIN_TITLE_FONT"]                                 = "Schriftart für Titel"
L["PRESENCE_FONT_FAMILY_MAIN_TITLE"]                          = "Schriftart für den Haupttitel."
L["PRESENCE_SUBTITLE_FONT"]                                   = "Schriftart für Untertitel"
L["PRESENCE_FONT_FAMILY_SUBTITLE"]                            = "Schriftart für den Untertitel."
L["PRESENCE_RESET_TYPOGRAPHY_DEFAULTS"]                       = "Typografie auf Standardwerte zurücksetzen"
L["PRESENCE_RESET_PRESENCE_TYPOGRAPHY_OPTIONS_FONTS_SIZES"]   = "Setzt sämtliche Presence-Typografieeinstellungen (Schriftarten & -größen, sowie Farben) auf die Standardwerte zurück."
L["PRESENCE_LARGE_NOTIFICATIONS"]                             = "Große Benachrichtigungen"
L["PRESENCE_MEDIUM_NOTIFICATIONS"]                            = "Mittlere Benachrichtigungen"
L["PRESENCE_SMALL_NOTIFICATIONS"]                             = "Kleine Benachrichtigungen"
L["PRESENCE_LARGE_PRIMARY_SIZE"]                              = "Schriftgröße großer Primärzeilen"
L["PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_TITLES_ZONE"]        = "Schriftgröße für große Benachrichtigungstitel (Zonenwechsel, Quest-Abschluss, Erfolge, etc.)"
L["PRESENCE_LARGE_SECONDARY_SIZE"]                            = "Schriftgröße großer Sekundärzeilen"
L["PRESENCE_FONT_SIZE_LARGE_NOTIFICATION_SUBTITLES"]          = "Schriftgröße für Untertitel großer Benachrichtigungen."
L["PRESENCE_MEDIUM_PRIMARY_SIZE"]                             = "Schriftgröße mittlerer Primärzeilen"
L["PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_TITLES_QUEST"]      = "Schriftgröße für mittlere Benachrichtigungstitel (Quest-Annahme, Unterzone, Szenario)."
L["PRESENCE_MEDIUM_SECONDARY_SIZE"]                           = "Schriftgröße mittlerer Sekundärzeilen"
L["PRESENCE_FONT_SIZE_MEDIUM_NOTIFICATION_SUBTITLES"]         = "Schriftgröße für Untertitel mittlerer Benachrichtigungen."
L["PRESENCE_SMALL_PRIMARY_SIZE"]                              = "Schriftgröße kleiner Primärzeilen"
L["PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_TITLES_QUEST"]       = "Schriftgröße für kleine Benachrichtigungstitel (Quest- & Erfolgsfortschritte)."
L["PRESENCE_SMALL_SECONDARY_SIZE"]                            = "Schriftgröße kleiner Sekundärzeilen"
L["PRESENCE_FONT_SIZE_SMALL_NOTIFICATION_SUBTITLES"]          = "Schriftgröße für Untertitel kleiner Benachrichtigungen."

-- =====================================================================
-- OptionsData.lua Dropdown options — Outline
-- =====================================================================
L["FOCUS_OUTLINE_NONE"]                                       = "Keine"
L["FOCUS_THICK_OUTLINE"]                                      = "Starke Kontur"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["FOCUS_HIGHLIGHT_BAR_LEFT_EDGE"]                            = "Leiste links"
L["FOCUS_HIGHLIGHT_BAR_RIGHT_EDGE"]                           = "Leiste rechts"
L["FOCUS_HIGHLIGHT_BAR_TOP_EDGE"]                             = "Leiste oben"
L["FOCUS_HIGHLIGHT_BAR_BOTTOM_EDGE"]                          = "Leiste unten"
L["FOCUS_HIGHLIGHT_OUTLINE_ONLY"]                             = "Umrandung"
L["FOCUS_HIGHLIGHT_SOFT_GLOW"]                                = "Sanftes Leuchten"
L["FOCUS_HIGHLIGHT_DUAL_EDGE_BARS"]                           = "Doppelrandleisten"
L["FOCUS_HIGHLIGHT_PILL_LEFT_ACCENT"]                         = "Akzentpille links"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["FOCUS_MYTHICPLUS_POSITION_TOP"]                            = "Oben"
L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"]                         = "Unten"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["VISTA_LOCATION_POSITION"]                                  = "Position des Standorts"
L["VISTA_PLACE_ZONE_NAME_ABOVE_BELOW_MINIMAP"]                = "Zonennamen über- oder unterhalb der Minikarte platzieren."
L["VISTA_COORDINATES_POSITION"]                               = "Position der Koordinaten"
L["VISTA_PLACE_COORDINATES_ABOVE_BELOW_MINIMAP"]              = "Koordinaten über- oder unterhalb der Minikarte platzieren."
L["VISTA_CLOCK_POSITION"]                                     = "Position der Uhrzeit"
L["VISTA_PLACE_CLOCK_ABOVE_BELOW_MINIMAP"]                    = "Uhrzeit über- oder unterhalb der Minikarte platzieren."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["FOCUS_TEXT_LOWER_CASE"]                                    = "Kleinbuchstaben"
L["FOCUS_TEXT_UPPER_CASE"]                                    = "Großbuchstaben"
L["FOCUS_TEXT_PROPER_CASE"]                                   = "Große Anfangsbuchstaben"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["FOCUS_TRACKED_LOG"]                                        = "Verfolgt/Im Log"
L["FOCUS_LOG_MAX_SLOTS"]                                      = "Im Log/Maximal"

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["FOCUS_ALPHABETICAL"]                                       = "Alphabetisch"
L["FOCUS_QUEST_TYPE"]                                         = "Quest-Typ"
L["FOCUS_QUEST_LEVEL"]                                        = "Quest-Stufe"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["FOCUS_CUSTOM"]                                             = "Benutzerdefiniert"
L["FOCUS_ORDER"]                                              = "Reihenfolge"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["UI_DUNGEON"]                                               = "Dungeon"
L["UI_RAID"]                                                  = "Schlachtzug"
L["UI_DELVES"]                                                = "Tiefen"
L["UI_SCENARIO_EVENTS"]                                       = "Szenario"
L["UI_STAGE"]                                                 = "Phase"
L["UI_STAGE_X_X"]                                             = "Phase %d: %s"
L["UI_AVAILABLE_IN_ZONE"]                                     = "In Zone verfügbar"
L["UI_EVENTS_IN_ZONE"]                                        = "Zonenereignisse"
L["UI_CURRENT_EVENT"]                                         = "Aktuelles Ereignis"
L["UI_CURRENT_QUEST"]                                         = "Aktuelle Quest"
L["UI_CURRENT_ZONE"]                                          = "Aktuelle Zone"
L["UI_CAMPAIGN"]                                              = "Kampagne"
L["UI_IMPORTANT"]                                             = "Priorität"
L["UI_LEGENDARY"]                                             = "Legendär"
L["UI_WORLD_QUESTS"]                                          = "Welt"
L["UI_WEEKLY_QUESTS"]                                         = "Wöchentlich"
L["UI_PREY"]                                                  = "Beutejagd"
L["UI_ABUNDANCE"]                                             = "Überfluss"
L["UI_ABUNDANCE_BAG"]                                         = "Überflussbeutel"
L["UI_ABUNDANCE_HELD"]                                        = "Überfluss gehalten"
L["UI_DAILY_QUESTS"]                                          = "Täglich"
L["UI_RARE_BOSSES"]                                           = "Seltene Gegner"
L["UI_ACHIEVEMENTS"]                                          = "Erfolge"
L["UI_ENDEAVORS"]                                             = "Unterfangen"
L["UI_DECOR"]                                                 = "Dekoration"
L["UI_RECIPES"]                                               = "Rezepte"
L["UI_ADVENTURE_GUIDE"]                                       = "Reisetagebuch"
L["UI_APPEARANCES"]                                           = "Vorlagen"
L["UI_QUESTS"]                                                = "Quests"
L["UI_READY_TO_TURN_IN"]                                      = "Bereit zur Abgabe"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["PRESENCE_OBJECTIVES"]                                      = "ZIELE"
L["PRESENCE_OPTIONS"]                                         = "Optionen"
L["PRESENCE_OPEN_HORIZON_SUITE"]                              = "Horizon Suite öffnen"
L["PRESENCE_OPEN_FULL_HORIZON_SUITE_OPTIONS"]                 = "Öffnet das vollständige Einstellungsfenster der Horizon Suite zur Konfiguration von Focus, Presence, Vista und anderen Modulen."
L["PRESENCE_MINIMAP_SECTION"]                                 = "Minikartensymbol"
L["PRESENCE_SHOW_MINIMAP_ICON"]                               = "Minikartensymbol anzeigen"
L["PRESENCE_A_CLICKABLE_ICON_MINIMAP_OPENS"]                  = "Zeigt ein klickbares Symbol auf der Minikarte an, um das Optionsfenster zu öffnen."
L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER"]         = "Nur bei Mouseover einblenden"
L["PRESENCE_MINIMAP_ICON_SHOW_ONLY_ON_MINIMAP_HOVER_DESC"]    = "EIN: Das Symbol bleibt verblasst, bis die Maus über die Minikarte bewegt wird. AUS: Das Symbol belibt vollständig sichtbar."
L["PRESENCE_LOCK_MINIMAP_BUTTON_POSITION"]                    = "Position der Minikartenschaltfläche fixieren"
L["PRESENCE_PREVENT_DRAGGING_HORIZON_MINIMAP_BUTTON"]         = "Verhindert das Verschieben der Minikartenschaltfläche von Horizon."
L["PRESENCE_RESET_MINIMAP_BUTTON_POSITION"]                   = "Position der Minikartenschaltfläche zurücksetzen"
L["PRESENCE_RESET_MINIMAP_BUTTON_DEFAULT_POSITION"]           = "Zurücksetzen der Minikartenschaltfläche auf die Standardposition (links unten)."
L["PRESENCE_DRAG_TO_MOVE_WHEN_UNLOCKED"]                      = "Ziehen zum bewegen (falls nicht fixiert)."
L["PRESENCE_LOCKED"]                                          = "Fixiert"
L["PRESENCE_DISCOVERED"]                                      = "Entdeckt"
L["PRESENCE_REFRESH"]                                         = "Aktualisieren"
L["PRESENCE_BEST_EFFORT_UNACCEPTED_QUESTS_EXPO"]              = "Nur bestmöglich. Manche nicht angenommenen Quests werden erst nach NPC-Interaktion oder Phasenbedingungen angezeigt."
L["PRESENCE_UNACCEPTED_QUESTS_X_MAP_X"]                       = "Nicht angenommene Quests - %s (Karte %s) - %d Treffer"
L["PRESENCE_LEVEL_UP"]                                        = "STUFENAUFSTIEG"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_80"]                       = "Ihr habt Stufe 80 erreicht"
L["PRESENCE_YOU_HAVE_REACHED_LEVEL_X"]                        = "Ihr habt Stufe %s erreicht"
L["PRESENCE_ACHIEVEMENT_EARNED"]                              = "ERFOLG ERRUNGEN"
L["PRESENCE_EXPLORING_THE_MIDNIGHT_ISLES"]                    = "Mitternachtsinseln erkunden"
L["PRESENCE_EXPLORING_KHAZ_ALGAR"]                            = "Khaz Algar erkunden"
L["PRESENCE_QUEST_COMPLETE"]                                  = "QUEST ABGESCHLOSSEN"
L["PRESENCE_OBJECTIVE_SECURED"]                               = "Ziel gesichert"
L["PRESENCE_AIDING_THE_ACCORD"]                               = "Dem Abkommen helfen"
L["PRESENCE_WORLD_QUEST"]                                     = "WELT-QUEST"
L["PRESENCE_WORLD_QUEST_COMPLETE"]                            = "WELT-QUEST ABGESCHLOSSEN"
L["PRESENCE_AZERITE_MINING"]                                  = "Azerit-Abbau"
L["PRESENCE_WORLD_QUEST_ACCEPTED"]                            = "WELT-QUEST ANGENOMMEN"
L["PRESENCE_QUEST_ACCEPTED"]                                  = "QUEST ANGENOMMEN"
L["PRESENCE_THE_FATE_OF_THE_HORDE"]                           = "Das Schicksal der Horde"
L["PRESENCE_NEW_QUEST"]                                       = "Neue Quest"
L["PRESENCE_QUEST_UPDATE"]                                    = "QUEST-FORTSCHRITT"
L["PRESENCE_BOAR_PELTS_7_10"]                                 = "Eberfelle: 7/10"
L["PRESENCE_DRAGON_GLYPHS_3_5"]                               = "Drachenglyphen: 3/5"
L["PRESENCE_TEST_COMMANDS"]                                   = "Presence-Testbefehle:"
L["PRESENCE_H_DEBUGTYPES_DUMP_NOTIFICATION"]                  = "  /h presence debugtypes - Benachrichtigungsoptionen und Blizzard-Unterdrückungsstatus ausgeben"
L["PRESENCE_PLAYING_DEMO_REEL_NOTIFICATION"]                  = "Presence: Demo wird abgespielt (alle Benachrichtigungstypen)..."
L["PRESENCE_H_HELP_TEST_CURRENT"]                             = "  /h presence          - Hilfe + aktuelle Zone testen"
L["PRESENCE_H_ZONE_TEST"]                                     = "  /h presence zone     - Zonenwechsel testen"
L["PRESENCE_H_SUBZONE_TEST"]                                  = "  /h presence subzone  - Unterzonenwechsel testen"
L["PRESENCE_H_DISCOVER_TEST_ZONE"]                            = "  /h presence discover - Zonenentdeckung testen"
L["PRESENCE_H_LEVEL_TEST"]                                    = "  /h presence level    - Levelaufstieg testen"
L["PRESENCE_H_BOSS_TEST"]                                     = "  /h presence boss     - Boss-Emote testen"
L["PRESENCE_H_ACHIEVEMENT_TEST"]                              = "  /h presence ach      - Erfolg testen"
L["PRESENCE_H_ACCEPT_TEST_QUEST"]                             = "  /h presence accept   - Quest angenommen testen"
L["PRESENCE_H_WORLD_QUEST_ACCEPT_TEST"]                       = "  /h presence wqaccept - Weltquest angenommen testen"
L["PRESENCE_H_SCENARIO_TEST"]                                 = "  /h presence scenario - Szenario-Start testen"
L["PRESENCE_H_QUEST_TEST_COMPLETE"]                           = "  /h presence quest    - Quest abgeschlossen testen"
L["PRESENCE_H_WORLD_QUEST_TEST"]                              = "  /h presence wq       - Weltquest testen"
L["PRESENCE_H_QUEST_UPDATE_TEST"]                             = "  /h presence update   - Quest-Update testen"
L["PRESENCE_H_ACHIEVEMENT_PROGRESS_TEST"]                     = "  /h presence achprogress - Erfolgsfortschritt testen"
L["PRESENCE_H_DEMO_REEL_TYPES"]                               = "  /h presence all      - Demo (alle Typen)"
L["PRESENCE_H_DEBUG_DUMP_STATE"]                              = "  /h presence debug    - Status im Chat ausgeben"
L["PRESENCE_H_DEBUGLIVE_TOGGLE_LIVE"]                         = "  /h presence debuglive - Live-Debug-Panel umschalten"

-- =====================================================================
-- OptionsData.lua Vista — General
-- L["VISTA_POSITION_LAYOUT"]                                 = "Position & Layout"

-- =====================================================================
L["VISTA_DESC"]                                               = "Minikarte"
L["VISTA_SIZE"]                                               = "Größe der Minikarte"
L["VISTA_WIDTH_HEIGHT_OF_MINIMAP_PIXELS"]                     = "Breite und Höhe der Minikarte (100–400 px)."
L["VISTA_CIRCULAR_MINIMAP"]                                   = "Kreisförmige Minikarte"
L["VISTA_CIRCULAR_SHAPE"]                                     = "Kreisförmig"
L["VISTA_A_CIRCULAR_MINIMAP_INSTEAD_OF_SQUARE"]               = "Kreisförmige statt quadratische Minikarte verwenden."
L["VISTA_LOCK_MINIMAP_POSITION"]                              = "Position der Minikarte fixieren"
L["VISTA_PREVENT_DRAGGING_MINIMAP"]                           = "Minikarte ist nicht verschiebbar."
L["VISTA_RESET_MINIMAP_POSITION"]                             = "Position der Minikarte zurücksetzen"
L["VISTA_RESET_MINIMAP_DEFAULT_POSITION_TOP_RIGHT"]           = "Position der Minikarte auf Standardwert (oben rechts) zurücksetzen."
L["VISTA_RESET_OVERLAY_POSITIONS"]                            = "Komponenten der Minikarten zurücksetzen"
L["VISTA_RESET_OVERLAY_POSITIONS_DESC"]                       = "Zurücksetzen der Positionen auf Standardwerte für Zonentext, Koordinaten, Uhrzeit, Leistung, Schwierigkeit, Zoom-Schaltflächen, Verfolgung, Kalender, Warteschlange, Post, Addon-Schaltflächenleiste, Schublade and Rechtsklick-Anzeige. Die Position der Minikarte selbst bleibt unverändert."
L["VISTA_AUTO_ZOOM"]                                          = "Automatischer Zoom"
L["VISTA_AUTO_ZOOM_DELAY"]                                    = "Verzögerung des automatischen Zoom-Outs"
L["VISTA_SECONDS_AFTER_ZOOMING_BEFORE_AUTO_ZOOM"]             = "Sekunden nach Zoom bis Auto-Zoom-Out. 0 = deaktiviert."

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["VISTA_ZONE_TEXT_HEADER"]                                   = "Zonentext"
L["VISTA_ZONE_FONT"]                                          = "Schriftart für Zone"
L["VISTA_FONT_ZONE_NAME_BELOW_MINIMAP"]                       = "Schriftart für den Zonennamen unter der Minikarte."
L["VISTA_ZONE_FONT_SIZE"]                                     = "Schriftgröße für Zone"
L["VISTA_ZONE_TEXT_COLOUR"]                                   = "Farbe der Zone"
L["VISTA_COLOUR_OF_ZONE_NAME_TEXT"]                           = "Farbe des Zonentexts."
L["VISTA_COORDINATES_TEXT"]                                   = "Koordinatentext"
L["VISTA_COORDINATES_FONT"]                                   = "Schriftart für Koordinaten"
L["VISTA_FONT_COORDINATES_TEXT_BELOW_MINIMAP"]                = "Schriftart für den Koordinatentext unterhalb der Minikarte."
L["VISTA_COORDINATES_FONT_SIZE"]                              = "Schriftgröße für Koordinaten"
L["VISTA_COORDINATES_TEXT_COLOUR"]                            = "Farbe des Koordinatentexts"
L["VISTA_COLOUR_OF_COORDINATES_TEXT"]                         = "Farbe des Koordinatentexts."
L["VISTA_COORDINATE_PRECISION"]                               = "Präzision der Koordinaten"
L["VISTA_NUMBER_OF_DECIMAL_PLACES_SHOWN_X"]                   = "Anzahl Dezimalstellen für X- und Y-Koordinaten."
L["VISTA_COORDS_DECIMALS_OFF"]                                = "Keine Dezimalstellen (z.B. 52, 37)"
L["VISTA_DECIMAL_E_G"]                                        = "Eine Dezimalstelle (z.B. 52,3, 37,1)"
L["VISTA_DECIMALS_E_G"]                                       = "Zwei Dezimalstellen (z.B. 52,34, 37,12)"
L["VISTA_TEXT"]                                               = "Uhrzeit"
L["VISTA_FONT"]                                               = "Schriftart für Uhrzeit"
L["VISTA_FONT_TEXT_BELOW_MINIMAP"]                            = "Schriftart für den Zeittext unterhalb der Minikarte."
L["VISTA_FONT_SIZE"]                                          = "Schriftgröße für Uhrzeit"
L["VISTA_TEXT_COLOUR"]                                        = "Farbe der Uhrzeit"
L["VISTA_COLOUR_OF_TEXT"]                                     = "Farbe des Zeittexts."
L["VISTA_PERFORMANCE_TEXT"]                                   = "Leistungsmessung"
L["VISTA_PERFORMANCE_FONT"]                                   = "Schrifart für Leistungmessung"
L["VISTA_FONT_FPS_LATENCY_TEXT_BELOW_MINIMAP"]                = "Schriftart für FPS- und Latenztext unterhalb der Minikarte."
L["VISTA_PERFORMANCE_FONT_SIZE"]                              = "Schriftgröße für Leistungsmessung"
L["VISTA_PERFORMANCE_TEXT_COLOUR"]                            = "Farbe der Leistungsmessung"
L["VISTA_COLOUR_OF_FPS_LATENCY_TEXT"]                         = "Farbe des FPS- und Latenztexts."
L["VISTA_DIFFICULTY_TEXT"]                                    = "Schwierigkeitsgrad"
L["VISTA_DIFFICULTY_TEXT_COLOUR_FALLBACK"]                    = "Farbe des Schwierigkeitsgrades (Fallback)"
L["VISTA_DEFAULT_COLOUR_PER_DIFFICULTY_COLOUR"]               = "Standardfarbe für nicht gesetzte Schwierigkeit."
L["VISTA_DIFFICULTY_FONT"]                                    = "Schriftart für Schwierigkeitsgrad"
L["VISTA_FONT_INSTANCE_DIFFICULTY_TEXT"]                      = "Schriftart der Instanz-Schwierigkeit."
L["VISTA_DIFFICULTY_FONT_SIZE"]                               = "Schriftgröße für Schwierigkeitsgrad"
L["VISTA_PER_DIFFICULTY_COLOURS"]                             = "Färbung nach Schwierigkeitsgrad"
L["VISTA_MYTHIC_COLOUR"]                                      = "Farbe für Mythisch"
L["VISTA_COLOUR_MYTHIC_DIFFICULTY_TEXT"]                      = "Farbe für mythischen Schwierigkeit."
L["VISTA_HEROIC_COLOUR"]                                      = "Farbe für Heroisch"
L["VISTA_COLOUR_HEROIC_DIFFICULTY_TEXT"]                      = "Farbe für heroische Schwierigkeit."
L["VISTA_NORMAL_COLOUR"]                                      = "Farbe für Normal"
L["VISTA_COLOUR_NORMAL_DIFFICULTY_TEXT"]                      = "Farbe für normale Schwierigkeit."
L["VISTA_LFR_COLOUR"]                                         = "Farbe für Schlachtzugsbrowser"
L["VISTA_COLOUR_LOOKING_RAID_DIFFICULTY_TEXT"]                = "Farbe für Suche-nach-Schlachtzug-Text."

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["VISTA_TEXT_ELEMENTS"]                                      = "Textelemente"
L["VISTA_ZONE_TEXT"]                                          = "Zonentext anzeigen"
L["VISTA_ZONE_NAME_BELOW_MINIMAP"]                            = "Zonennamen unter der Minikarte anzeigen."
L["VISTA_ZONE_TEXT_DISPLAY_MODE"]                             = "Zonentext-Anzeigemodus"
L["VISTA_WHAT_ZONE_SUBZONE"]                                  = "Nur Zone, Unterzone oder beides anzeigen."
L["VISTA_SHOW_ZONE"]                                          = "Nur Zone"
L["VISTA_SHOW_SUBZONE"]                                       = "Nur Unterzone"
L["VISTA_SHOW_ZONE_AND_SUBZONE"]                              = "Beides"
L["VISTA_COORDINATES"]                                        = "Koordinaten anzeigen"
L["VISTA_PLAYER_COORDINATES_BELOW_MINIMAP"]                   = "Spielerkoordinaten unter der Minikarte anzeigen."
L["VISTA_TIME"]                                               = "Zeit anzeigen"
L["VISTA_CURRENT_GAME_BELOW_MINIMAP"]                         = "Aktuelle Spielzeit unter der Minikarte anzeigen."
L["VISTA_HOUR_CLOCK"]                                         = "24-Stunden-Format"
L["VISTA_DISPLAY_HOUR_FORMAT_24"]                             = "Uhrzeit im 24-Stunden-Format anzeigen (z.B. 14:30 statt 2:30 PM)."
L["VISTA_LOCAL_TIME"]                                         = "Lokalzeit verwenden"
L["VISTA_LOCAL_TIME_TIP"]                                     = "An: lokale Systemzeit. Aus: Serverzeit."
L["VISTA_FPS_LATENCY"]                                        = "FPS und Latenz anzeigen"
L["VISTA_FPS_LATENCY_MS_BELOW_MINIMAP"]                       = "FPS und Latenz (ms) unter der Minikarte anzeigen."
L["VISTA_MINIMAP_BUTTONS"]                                    = "Minikarten-Schaltflächen"
L["VISTA_QUEUE_STATUS_MAIL_INDICATOR_ALWAYS_SHOWN"]           = "Warteschlangen- und Post-Status werden bei Relevanz angezeigt."
L["VISTA_TRACKING_BUTTON"]                                    = "Verfolgen-Button anzeigen"
L["VISTA_MINIMAP_TRACKING_BUTTON"]                            = "Minikarten-Verfolgen-Button anzeigen."
L["VISTA_TRACKING_BUTTON_MOUSEOVER"]                          = "Verfolgen-Button nur bei Mausüber"
L["VISTA_HIDE_TRACKING_BUTTON_UNTIL_YOU_HOVER"]               = "Verfolgen-Button verbergen bis Maus über Minikarte."
L["VISTA_CALENDAR_BUTTON"]                                    = "Kalender-Button anzeigen"
L["VISTA_MINIMAP_CALENDAR_BUTTON"]                            = "Minikarten-Kalender-Button anzeigen."
L["VISTA_CALENDAR_BUTTON_MOUSEOVER"]                          = "Kalender-Button nur bei Mausüber"
L["VISTA_HIDE_CALENDAR_BUTTON_UNTIL_YOU_HOVER"]               = "Kalender-Button verbergen bis Maus über Minikarte."
-- L["VISTA_TELEPORT_BUTTON"]                                 = "Show Teleport Button"
-- L["VISTA_MINIMAP_TELEPORT_BUTTON"]                         = "Show a button that lists toys, hearthstones and class teleports the character has unlocked."
-- L["VISTA_TELEPORT_BUTTON_MOUSEOVER"]                       = "Teleport Button on Mouseover Only"
-- L["VISTA_HIDE_TELEPORT_BUTTON_UNTIL_YOU_HOVER"]            = "Hide teleport button until you hover over the minimap."
-- L["VISTA_TELEPORT_TOOLTIP"]                                = "Teleports"
-- L["VISTA_NO_TELEPORTS_UNLOCKED"]                           = "No teleports unlocked"
L["VISTA_ZOOM_BUTTONS"]                                       = "Zoom-Buttons anzeigen"
L["VISTA_ZOOM_BUTTONS_MINIMAP"]                               = "Zoom-Buttons (+ & -) auf der Minikarte anzeigen."
L["VISTA_ZOOM_BUTTONS_MOUSEOVER"]                             = "Zoom-Buttons nur bei Mausüber"
L["VISTA_HIDE_ZOOM_BUTTONS_UNTIL_YOU_HOVER"]                  = "Zoom-Buttons verbergen bis Maus über Minikarte."

-- =====================================================================
-- OptionsData.lua Vista — Display (Border / Text Positions / Buttons)
-- =====================================================================
L["VISTA_BORDER"]                                             = "Rahmen"
L["VISTA_BORDER_TIP"]                                         = "Rahmen um die Minikarte anzeigen."
L["VISTA_BORDER_COLOUR"]                                      = "Rahmenfarbe"
L["VISTA_COLOUR_OPACITY_OF_MINIMAP_BORDER"]                   = "Farbe (und Deckkraft) des Minikarten-Rahmens."
L["VISTA_BORDER_THICKNESS"]                                   = "Rahmenstärke"
L["VISTA_THICKNESS_OF_MINIMAP_BORDER_PIXELS"]                 = "Stärke des Minikarten-Rahmens in Pixeln (1–8)."
L["VISTA_CLASS_COLOURS"]                                      = "Klassenfarben"
L["VISTA_TINT_VISTA_BORDER_TEXT_COORDS_FPS"]                  = "Vista-Rahmen und Text (Koordinaten, Zeit, FPS/MS) in Klassenfärbung. Zahlen nutzen die konfigurierte Farbe."
L["VISTA_TEXT_POSITIONS"]                                     = "Textpositionierung"
L["VISTA_DRAG_TEXT_ELEMENTS_REPOSITION_LOCK_PREVEN"]          = "Textelemente ziehen zum Verschieben. Fixierung verhindert ungewollte Verschiebung."
L["VISTA_LOCK_ZONE_TEXT_POSITION"]                            = "Position des Zonentextes fixieren"
L["VISTA_ZONE_TEXT_CANNOT_DRAGGED"]                           = "EIN: Zonentext nicht verschiebbar."
L["VISTA_LOCK_COORDINATES_POSITION"]                          = "Position der Koordinaten fixieren"
L["VISTA_COORDINATES_TEXT_CANNOT_DRAGGED"]                    = "EIN: Koordinatentext nicht verschiebbar."
L["VISTA_LOCK_POSITION"]                                      = "Position der Uhrzeit fixieren"
L["VISTA_TEXT_CANNOT_DRAGGED"]                                = "EIN: Zeittext nicht verschiebbar."
L["VISTA_PERFORMANCE_TEXT_POSITION"]                          = "Position des Leistungstexts"
L["VISTA_PLACE_FPS_LATENCY_TEXT_ABOVE_BELOW"]                 = "FPS/Latenz-Text über- oder unterhalb der Minikarte platzieren."
L["VISTA_LOCK_PERFORMANCE_TEXT_POSITION"]                     = "Position des Leistungstexts fixieren"
L["VISTA_FPS_LATENCY_TEXT_CANNOT_DRAGGED"]                    = "EIN: FPS/Latenz-Text nicht verschiebbar."
L["VISTA_DIFFICULTY_TEXT_POSITION"]                           = "Position des Schwierigkeitstexts"
L["VISTA_PLACE_DIFFICULTY_TEXT_ABOVE_BELOW"]                  = "Die Anzeige der Instanzschwierigkeit ober- oder unterhalb der Minikarte positionieren. Die Platzierung ist unabhängig vom Zonentext."
L["VISTA_LOCK_DIFFICULTY_TEXT_POSITION"]                      = "Position des Schwierigkeitstexts fixieren"
L["VISTA_DIFFICULTY_TEXT_CANNOT_DRAGGED"]                     = "EIN: Schwierigkeitstext nicht verschiebbar."
L["VISTA_BUTTON_POSITIONS"]                                   = "Positionen der Schaltflächen"
L["VISTA_DRAG_BUTTONS_REPOSITION_LOCK_PREVENT_MOVE"]          = "Schaltflächen zum Verschieben ziehen."
L["VISTA_LOCK_ZOOM_BUTTON"]                                   = "Vergrößern-Button sperren"
L["VISTA_PREVENT_DRAGGING_ZOOM_BUTTON"]                       = "Vergrößern-Button nicht verschiebbar."
L["VISTA_LOCK_ZOOM_OUT_BUTTON"]                               = "Verkleinern-Button sperren"
L["VISTA_LOCK_ZOOM_OUT_DRAG"]                                 = "Verkleinern-Button nicht verschiebbar."
L["VISTA_LOCK_TRACKING_BUTTON"]                               = "Verfolgen-Button sperren"
L["VISTA_PREVENT_DRAGGING_TRACKING_BUTTON"]                   = "Verfolgen-Button nicht verschiebbar."
L["VISTA_LOCK_CALENDAR_BUTTON"]                               = "Kalenderschaltfläche fixieren"
L["VISTA_PREVENT_DRAGGING_CALENDAR_BUTTON"]                   = "Kalenderschaltfläche nicht verschiebbar."
L["VISTA_LOCK_QUEUE_BUTTON"]                                  = "Warteschlangen-Button sperren"
L["VISTA_PREVENT_DRAGGING_QUEUE_STATUS_BUTTON"]               = "Warteschlangen-Button nicht verschiebbar."
L["VISTA_LOCK_MAIL_INDICATOR"]                                = "Postsymbol fixieren"
L["VISTA_PREVENT_DRAGGING_MAIL_ICON"]                         = "Postsymbol nicht verschiebbar."
-- L["VISTA_LOCK_CRAFTING_ORDER_INDICATOR"]                   = "Lock Crafting Order Indicator"
-- L["VISTA_PREVENT_DRAGGING_CRAFTING_ORDER_ICON"]            = "Prevent dragging the crafting order icon."
L["VISTA_DISABLE_QUEUE_HANDLING"]                             = "Warteschlangen-Verwaltung deaktivieren"
L["VISTA_DISABLE_QUEUE_BUTTON_HANDLING"]                      = "Warteschlangen-Button-Verwaltung deaktivieren"
L["VISTA_TURN_QUEUE_BUTTON_ANCHORING_OFF_ADDON_CONFLICT"]     = "Alle Warteschlangen-Button-Ankerungen deaktivieren (wenn anderes Addon verwaltet)."
L["VISTA_BUTTON_SIZES"]                                       = "Größe der Schaltflächen"
L["VISTA_ADJUST_SIZE_OF_MINIMAP_OVERLAY_BUTTONS"]             = "Größe der Überlagerungschaltflächen an der Minikarte anpassen."
L["VISTA_TRACKING_BUTTON_SIZE"]                               = "Verfolgen-Button-Größe"
L["VISTA_SIZE_OF_TRACKING_BUTTON_PIXELS"]                     = "Größe der Verfolgenschaltfläche (in Pixel)."
L["VISTA_CALENDAR_BUTTON_SIZE"]                               = "Größe der Kalenderschaltfläche"
L["VISTA_SIZE_OF_CALENDAR_BUTTON_PIXELS"]                     = "Größe des Kalenderschaltfläche (in Pixel)."
L["VISTA_QUEUE_BUTTON_SIZE"]                                  = "Größe der Warteschlangen-Schaltfläche"
L["VISTA_SIZE_OF_QUEUE_STATUS_BUTTON_PIXELS"]                 = "Größe der Warteschlangen-Schaltfläche (in Pixel)."
L["VISTA_ZOOM_BUTTON_SIZE"]                                   = "Größe der Zoom-Schaltfläche"
L["VISTA_SIZE_OF_ZOOM_ZOOM_BUTTONS_PIXELS"]                   = "Größe der Zoom-Schaltfläche (in Pixel)."
L["VISTA_MAIL_INDICATOR_SIZE"]                                = "Grüße des Postsymbols"
L["VISTA_SIZE_OF_MAIL_ICON_PIXELS"]                           = "Größe des Postsymbols (in Pixel)."
-- L["VISTA_CRAFTING_ORDER_INDICATOR_SIZE"]                   = "Crafting Order Indicator Size"
-- L["VISTA_SIZE_OF_CRAFTING_ORDER_ICON_PIXELS"]              = "Size of the crafting order icon (pixels)."
L["VISTA_ADDON_BUTTON_SIZE"]                                  = "Größe der Addon-Schaltfläche"
L["VISTA_SIZE_OF_COLLECTED_ADDON_MINIMAP_BUTTONS"]            = "Größe der gesammelten Minikarten-Schaltflächen von Addons (in Pixel)."

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
L["VISTA_COLLECT_HORIZON_MINIMAP"]                            = "Minikartensymbol von Horizon mit einschließen"
L["VISTA_COLLECT_HORIZON_MINIMAP_DESC"]                       = "Verlegt Horizons eigenen Minikartensymbol in die verwaltete Addon-Leiste, die Rechtsklick-Anzeige oder die Schublade anstatt es am Rand der Minikarte zu belassen."
-- L["VISTA_SORT_BUTTONS_ALPHA"]                              = "Sort Buttons Alphabetically"
-- L["VISTA_SORT_BUTTONS_ALPHA_DESC"]                         = "Sort collected addon minimap buttons alphabetically by name."
L["VISTA_ADDON_BUTTONS"]                                      = "Addon-Schaltflächen"
L["VISTA_MINIMAP_ADDON_BUTTONS"]                              = "Minikartenschaltflächen von Addons"
L["VISTA_BUTTON_MANAGEMENT"]                                  = "Verwaltung der SChaltflächen"
L["VISTA_MANAGE_ADDON_MINIMAP_BUTTONS"]                       = "Addon-Minikarten-Buttons verwalten"
L["VISTA_TAKES_CONTROL_OF_ADDON_MINIMAP"]                     = "EIN: Vista übernimmt Minikartenschaltflächen von Addons und gruppiert nach gewähltem Modus."
L["VISTA_BUTTON_MODE"]                                        = "Schaltflächenmodus"
L["VISTA_ADDON_BUTTONS_PRESENTED_HOVER_BAR_BELOW"]            = "Darstellung der Addon-Schaltflächen: Mausüber-Leiste, Rechtsklick-Anzeige oder schwebende Schubladenschaltfläche."
L["VISTA_ALWAYS_BAR"]                                         = "Leiste immer anzeigen"
L["VISTA_ALWAYS_MOUSEOVER_BAR_POSITIONING"]                   = "Mausüber-Leiste immer anzeigen (zum Positionieren)"
L["VISTA_KEEP_MOUSEOVER_BAR_VISIBLE_TIMES_YOU"]               = "Mausüber-Leiste immer sichtbar für Positionierung. Deaktivieren wenn fertig."
L["VISTA_DISABLE_DONE"]                                       = "Deaktivieren wenn fertig."
L["VISTA_MOUSEOVER_BAR"]                                      = "Mausüber-Leiste"
L["VISTA_RIGHT_CLICK_PANEL"]                                  = "Rechtsklick-Anzeige"
L["VISTA_FLOATING_DRAWER"]                                    = "Schwebende Schublade"
L["VISTA_LOCK_DRAWER_BUTTON_POSITION"]                        = "Position der Schubladenschaltfläche fixieren"
L["VISTA_PREVENT_DRAGGING_FLOATING_DRAWER_BUTTON"]            = "Schubladenschaltfläche nicht verschiebbar."
L["VISTA_LOCK_MOUSEOVER_BAR_POSITION"]                        = "Position der Mausüber-Leiste fixieren"
L["VISTA_PREVENT_DRAGGING_MOUSEOVER_BUTTON_BAR"]              = "Mausüber-Leiste nicht verschiebbar."
L["VISTA_LOCK_RIGHT_CLICK_PANEL_POSITION"]                    = "Position der Rechtsklick-Anzeige fixieren"
L["VISTA_PREVENT_DRAGGING_RIGHT_CLICK_PANEL"]                 = "Rechtsklick-Anzeige nicht verschiebbar."
L["VISTA_BUTTONS_PER_ROW_COLUMN"]                             = "Schaltflächen pro Zeile & Spalte"
L["VISTA_CONTROLS_MANY_BUTTONS_APPEAR_BEFORE_WRAPPING"]       = "Anzahl Schaltflächen vor Umbruch. Links/Rechts = Spalten; Oben/Unten = Zeilen."
L["VISTA_EXPAND_DIRECTION"]                                   = "Ausbreitungsrichtung"
L["VISTA_DIRECTION_BUTTONS_FILL_ANCHOR_POINT_LEFT"]           = "Richtung: Buttons füllen vom Anker. Links/Rechts = Zeilen; Oben/Unten = Spalten."
L["VISTA_BUTTONS_FILL_RIGHT"]                                 = "Rechts"
L["VISTA_BUTTONS_FILL_LEFT"]                                  = "Links"
L["VISTA_BUTTONS_FILL_DOWN"]                                  = "Unten"
L["VISTA_BUTTONS_FILL_UP"]                                    = "Oben"
L["VISTA_MOUSEOVER_BAR_APPEARANCE"]                           = "Darstellung der Mouseover-Leiste"
L["VISTA_BACKGROUND_BORDER_MOUSEOVER_BUTTON_BAR"]             = "Hintergrund und Rahmen für die Mausüber-Button-Leiste."
L["VISTA_BACKDROP_COLOUR"]                                    = "Hintergrundfarbe"
L["VISTA_BACKGROUND_COLOUR_OF_MOUSEOVER_BUTTON_BAR"]          = "Hintergrundfarbe der Mausüber-Leiste (Alpha für Transparenz)."
L["VISTA_BAR_BORDER"]                                         = "Leistenrahmen anzeigen"
L["VISTA_A_BORDER_AROUND_MOUSEOVER_BUTTON_BAR"]               = "Rahmen um die Mausüber-Leiste anzeigen."
L["VISTA_BAR_BORDER_COLOUR"]                                  = "Farbe des Leistenrahmens"
L["VISTA_BORDER_COLOUR_OF_MOUSEOVER_BUTTON_BAR"]              = "Rahmenfarbe der Mausüber-Leiste."
L["VISTA_BAR_BACKGROUND_COLOUR"]                              = "Hintergrundfarbe der Leiste"
L["VISTA_PANEL_BACKGROUND_COLOUR"]                            = "Hintergrundfarbe der Anzeige."
L["VISTA_CLOSE_FADE_TIMING"]                                  = "Schließen / Einblend-Timing"
L["VISTA_MOUSEOVER_BAR_CLOSE_DELAY_SECONDS"]                  = "Mausüber-Leiste — Schließ-Verzögerung (Sekunden)"
L["VISTA_LONG_SECONDS_BAR_STAYS_VISIBLE_AFTER"]               = "Wie lange (Sekunden) die Leiste sichtbar bleibt nach Verlassen. 0 = sofortiges Ausblenden."
L["VISTA_RIGHT_CLICK_PANEL_CLOSE_DELAY_SECONDS"]              = "Rechtsklick-Panel — Schließ-Verzögerung (Sekunden)"
L["VISTA_LONG_SECONDS_PANEL_STAYS_OPEN_AFTER"]                = "Wie lange (Sekunden) das Panel offen bleibt nach Verlassen. 0 = nie automatisch schließen."
L["VISTA_FLOATING_DRAWER_CLOSE_DELAY_SECONDS"]                = "Schwebende Schublade — Schließ-Verzögerung (Sekunden)"
L["VISTA_DRAWER_CLOSE_DELAY"]                                 = "Schublade-Schließ-Verzögerung"
L["VISTA_LONG_SECONDS_DRAWER_PANEL_STAYS_OPEN"]               = "Dauer (in Sekunden), in der die Schublade nach dem wegklicken geöffnet bleibt. 0 = nie automatisch schließen."
L["VISTA_MAIL_ICON_BLINK"]                                    = "Blinkendes Postsymbol"
L["VISTA_MAIL_ICON_PULSES_DRAW_ATTENTION"]                    = "EIN: Postsymbol pulsiert. AUS: volle Deckkraft."
-- L["VISTA_CRAFTING_ORDER_ICON_PULSE"]                       = "Crafting Order Icon Pulse"
-- L["VISTA_CRAFTING_ORDER_ICON_PULSES_DRAW_ATTENTION"]       = "When on, the crafting order icon pulses to draw attention. When off, it stays at full opacity."
-- L["VISTA_CRAFTING_ORDER_TOOLTIP"]                          = "Personal Crafting Orders"
-- L["VISTA_CRAFTING_ORDER_PENDING_COUNT"]                    = "%d pending"
-- L["VISTA_CRAFTING_ORDER_PROFESSION_LINE"]                  = "  %s: %d"
L["VISTA_PANEL_APPEARANCE"]                                   = "Anzeigedarstellung"
L["VISTA_COLOURS_DRAWER_RIGHT_CLICK_BUTTON_PANELS"]           = "Farben für Schublade und Rechtsklick-Anzeigen."
L["VISTA_PANEL_BG_COLOUR_LABEL"]                              = "Hintergrundfrabe der Anzeige"
L["VISTA_BACKGROUND_COLOUR_OF_ADDON_BUTTON_PANELS"]           = "Hintergrundfarbe der Addon-Schaltflächenanzeigen."
L["VISTA_PANEL_BORDER_COLOUR"]                                = "Rahmenfarbe der Anzeige"
L["VISTA_BORDER_COLOUR_OF_ADDON_BUTTON_PANELS"]               = "Rahmenfarbe der Addon-Schaltflächenanzeige."
L["VISTA_MANAGED_BUTTONS"]                                    = "Verwaltete Schaltflächen"
L["VISTA_BUTTON_COMPLETELY_IGNORED"]                          = "AUS: Diese Schaltfläche wird vom Addon ignoriert."
L["VISTA_ADDON_BUTTONS_DETECTED"]                             = "(Noch keine Addon-Schaltflächen erkannt)"
L["VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE"]                      = "Sichtbare Schaltflächen (zum Einbinden ankreuzen)"
L["VISTA_ADDON_BUTTONS_DETECTED_OPEN_YOUR_MINIMAP"]           = "(Noch keine Addon-Schaltflächen erkannt — Zuerst Minikarte öffnen)"

-- =====================================================================
-- Inline option / module strings (used in OptionsData / modules; symbolic migration)
-- =====================================================================

L["HEROIC_DUNGEON"]                                           = " - Heroische Dungeons"
L["HEROIC_RAID"]                                              = " - Heroische Schlachtzüge"
L["LFR"]                                                      = " - Schlachtzugs-Browser"
L["MYTHIC_DUNGEON"]                                           = " - Mythische Dungeons"
L["MYTHIC_RAID"]                                              = " - Mythische Schlachtzüge"
L["MYTHIC_PLUS_DUNGEON"]                                      = " - Mythisch-Plus-Dungeons"
L["NORMAL_DUNGEON"]                                           = " - Normale Dungeons"
L["NORMAL_RAID"]                                              = " - Normale Schlachtzüge"
L["ACHIEVEMENT_ICONS"]                                        = "Erfolgssymbole"
L["ACTIVE_INSTANCE"]                                          = "Nur aktive Instanz"
L["ADJUST_FONT_SIZES_AMOUNT"]                                 = "Sämtliche Schriftgrößen um diesen Wert anpassen."
L["ADJUST_FONTS_SIZES_CASING_DROP_SHADOWS"]                   = "Art, Größe, Kontur und Schattierung von Schriften anpassen."
L["AFFIX_ICONS"]                                              = "Affix-Symbole"
L["AFFIX_TOOLTIPS"]                                           = "Affix-Tooltips"
L["AFFECTS_SCENARIO_PROGRESS_TIMER_BARS"]                     = "Beeinflusst ebenfalls Szenariofortschritts- und Timer-Leisten."
L["ALWAYS"]                                                   = "Immer anzeigen"
L["ALWAYS_M_TIMER"]                                           = "Timer für Mythisch-Plus immer anzeigen."
L["AUTO_ADD_WQS_YOUR_CURRENT_ZONE"]                           = "Welt-Quests in der aktuellen Zone automatisch hinzufügen."
L["AUTO_CLOSE_DELAY_DISABLE"]                                 = "Verzögerung für automatisches Schließen (0 = ausgeschaltet)."
L["AUTO_UNTRACK_FINISHED_ACTIVITIES"]                         = "Abgeschlossene Aktivitäten automatisch entfolgen."
L["FOCUS_BAR_UNDER_NUMERIC_OBJECTIVES"]                       = "Leiste unterhalb numerischer Ziele (z.B. 3/250)."
L["DASH_CLASS_ICONS_RONDOMEDIA"]                              = "Blizzard default or RondoMedia class icon on the Dashboard when Dashboard class colours are on. Independent of Insight tooltip class icons."
L["BLOCK_POSITION"]                                           = "Postition des Blocks"
L["BOSS_EMOTES"]                                              = "Bossgeschwätz"
L["CHOICE_SLOTS"]                                             = "Auswahlreagenzienplätze"
L["CHOOSE_WHICH_EVENTS_TRIGGER_SCREEN_ALERTS"]                = "Auswahl der Ereignisse, die eine Alarmanzeige auslösen."
L["CHOOSE_WHICH_SOUND_PLAY_A_RARE"]                           = "Auswahl des Audioeffekts, wenn ein seltener Gegner erscheint. Benötigt installierte LibSharedMedia-Soundsfür zusätzliche Optionen."
L["CLICK_BEHAVIOR"]                                           = "Klickverhalten"
L["COLLECT_GROUP_ADDON_MINIMAP_BUTTONS"]                      = "Minikartenschaltflächen sammeln und gruppieren."
L["COLOUR_REMAINING"]                                         = "Färbung nach verbleibender Zeit."
L["COLOUR_ZONE_TYPE"]                                         = "Färbung nach Zonentyp"
L["COLOUR_CONTESTED_ZONES_ORANGE_DEFAULT"]                    = "Farbe für umkämpfte Zonen (Standard: organge)."
L["COLOUR_FRIENDLY_ZONES_GREEN_DEFAULT"]                      = "Farbe für freundliche Zonen (Standard: grün)."
L["COLOUR_HOSTILE_ZONES_RED_DEFAULT"]                         = "Farbe für feindliche Zonen (Standard: rot)."
L["COLOUR_SANCTUARY_ZONES_BLUE_DEFAULT"]                      = "Farbe für sichere Zonen (Standard: blau)."
L["COLOUR_OF_DIVIDER_LINES_BETWEEN_SECTIONS"]                 = "Farbe der Trennlinien zwischen Abschnitten."
L["COLOUR_RECIPE_TITLES_OUTPUT_ITEM_RARITY"]                  = "Färbung von Rezeptnamen nach Produktseltenheit."
L["COLOUR_ZONE_SUBZONE_TITLES_PVP_ZONE"]                      = "Färbung von Zonen- und Unterzonennamen nach  PvP-Zonentyp (freundlich, feindlich, umkämpft, sicher). AUS: Verwendet Standardfarbe des Abschnittes."
L["COMBAT_AFK_DND_PVP_PARTY_FRIENDS"]                         = "Kampf, AFK, DND, PvP, Gruppe, Freunde & Ziele."
L["COMING_SOON"]                                              = "In Kürze"
L["COMPLETED_BOSS_STYLE"]                                     = "Darstellung besiegter Bosse"
L["COMPLETED_COUNT"]                                          = "Anzahl besiegter Streitkräfte"
L["FOCUS_TOMTOM_CONFIGURE_DESC"]                              = "Klickverhalten, Verfolgungsregeln und TomTom-Integration."
L["CONFIGURE_MINIMAP_S_SHAPE_SIZE_POSITION"]                  = "Konfiguration der Minikartenform, -größe, -position und Textüberlagerungen."
L["CONTESTED_ZONE_COLOUR"]                                    = "Farbe für umkämpfte Zonen"
L["CONTROL_TRACKER_VISIBILITY_WITHIN_DUNGEONS_RAIDS"]         = "Sichtbarkeit des Zielverfolgers in Dungeons, Schlachtzügen und PvP."
L["SETTINGS_PRESENCE_NOTIFICATION_FRAMEWORK"]                 = "Kerneinstellungen für das Presence-Benachrichtigungs-Framework."
L["CRAFTABLE_COUNT"]                                          = "Herstellbare Anzahl"
L["CTRL_LEFT_FOCUS_ADD_CTRL_RIGHT"]                           = "STRG+Linksklick = fokussieren/hinzufügen, STRG+Rechtsklick = entfokussieren/entfolgen."
L["CURRENT_ZONE_GROUP"]                                       = "Abschnitt für aktuelle Zone"
L["CURRENT_ZONE"]                                             = "Nur aktuelle Zone"
L["VISTA_CUSTOMISE_BORDERS_COLOURS_POSITIONING"]              = "Anpassung von Rahmen und Farben, sowie Positionierung spezifischer Elemente der Minikarte."
L["CUSTOMIZE_VISUAL_INTERFACE_LAYOUT_ELEMENTS"]               = "Visuelle Erscheinung und Layoutelemente anpassen."
L["DASHBOARD_CLASS_ICON_STYLE"]                               = "Dashboard-Klassensymbolstil"
L["DECOR_ICONS"]                                              = "Symbole für Dekoration"
L["DEDICATED_SECTION_COMPLETED_QUESTS"]                       = "Eigenständiger Abschnitt für abgabebereite Quests."
L["DEDICATED_SECTION_ZONE_QUESTS"]                            = "Eigenständiger Abschnitt für Quests in der aktullen Zone."
L["DEFEATED_BOSS_STYLE"]                                      = "Darstellung besiegter Bosse."
L["DESATURATE_FOCUSED_ENTRIES"]                               = "Nicht-fokussierte Einträge entsättigen."
L["DESATURATE_FOCUSED_QUESTS"]                                = "Nicht-fokussierte Quests entsättigen"
L["DIM_ALPHA"]                                                = "Deckkraft der Abdunkelung"
L["DIM_STRENGTH"]                                             = "Intensität der Abdunkelung"
L["DIM_UNFOCUSED_TRACKER_ENTRIES"]                            = "Nicht-fokussierte Ziele Abdunkeln."
L["DIMMING_STRENGTH"]                                         = "Intensität der Abdunkelung (0-100 %)."
L["DISPLAY_COMPLETED_OBJECTIVES"]                             = "Abgeschlossene Ziele anzeigen."
L["ENABLE_BLACKLIST_UNTRACKED_INTERACTIONS_ADD_QUEST"]        = "Unter Interaktion die Funktion zur Sperrung von unverfolgten Einträgen einschalten, um Quests hier hinzuzufügen."
L["ENABLE_M_BLOCK"]                                           = "Mytisch-Plus-Block aktivieren"
L["ENEMY_FORCES_COLOUR"]                                      = "Farbe feindlicher Streitkräfte"
L["ENEMY_FORCES_SIZE"]                                        = "Schriftgröße feindlicher Streitkräfte"
L["ENHANCE_PLAYER_ITEM_TOOLTIPS_EXTRA_DETAILS"]               = "Tooltips von Spielern und Gegenständen mit zusätzlichen Details wie z.B. Mythisch-Plus-Wertung oder Transmog-Status erweitern."
L["ENTRY_NUMBERS"]                                            = "Nummerierte Einträge"
L["ENTRY_SPACING"]                                            = "Abstand zwischen Einträgen"
L["EXPAND_DIRECTION_ANCHOR"]                                  = "Ausbreitungsrichtung ausgehend vom Anker."
L["FADE_HOVERING"]                                            = "Ohne Mouseover abblenden."
L["FOCUS_FINISHING_REAGENTS"]                                 = "Fertigungsreagenzien"
L["FOCUS_ANIMATIONS"]                                         = "Animationen"
L["FONT_SIZE_BAR_LABEL_BAR_HEIGHT"]                           = "Schriftgröße für Leistenbezeichnung und -höhe."
L["FONTS_SIZES_COLOURS_PRESENCE_NOTIFICATIONS"]               = "Schriftarten, -größen und -farben für Presence-Benachrichtigungen."
L["WORLD_QUESTS_WEEKLIES_YOUR_QUEST_LOG"]                     = "Für Welt- und wöchentliche Quests, die sich nicht im Quest-Log befinden."
L["FRIENDLY_ZONE_COLOUR"]                                     = "Farbe freundlicher Zonen"
L["GROUPING"]                                                 = "Gruppierung"
L["GROUPS_SELECTED_LAYOUT_MODE_BELOW"]                        = "Mit unten gewählten Layoutmodus gruppieren."
L["GUILD_RANK"]                                               = "Gildenrang"
L["HEADER_DIVIDER"]                                           = "Trenner für Kopfzeile"
L["HIDE_UNTRACKED_QUESTS_UNTIL_RELOAD"]                       = "Nichtverfolgte Quests bis zum Neuladen verbergen."
L["HIDE_ZONE_NOTIFICATIONS_MYTHIC"]                           = "Zonenbenachrichtigungen in Mytschich-Plus verbergen."
L["HIDES_CATEGORIES_WHILE_A_DELVE_PARTY"]                     = "Andere Abschnitte in Tiefen oder Dungeons verbergen."
L["HINT_LIST_SCROLLABLE"]                                     = "Hinweis bei scrollbarer Liste."
L["HONOR_LEVEL"]                                              = "Ehrenstufe"
L["HOSTILE_ZONE_COLOUR"]                                      = "Farbe feindlicher Zonen"
L["FOCUS_DIM_UNFOCUSED_ENTRIES_DESC"]                         = "Grad der Abdunklung nicht-fokussierter Einträge (0 = keine Abdunklung, 100 = vollständig abgedunkelt). Standard: 40 %."
L["ICON_NEXT_ACHIEVEMENT_TITLE"]                              = "Symbol neben Erfolgstitel."
L["ICON_NEXT_AUTO_TRACKED_ZONE_ENTRIES"]                      = "Symbol neben automatisch verfolgten Einträgen in der Zone."
L["ARENA"]                                                    = "In Arenen"
L["BATTLEGROUND"]                                             = "In Schlachtfeldern"
L["DUNGEON"]                                                  = "In Dungeons"
L["RAID"]                                                     = "In Schlachtzügen"
L["ZONE_WORLD_QUESTS"]                                        = "Welt-Quests in aktueller Zone"
L["INCLUDE_COMPLETED"]                                        = "Abgeschlossene einschließen"
L["INSTANCE_SUPPRESSION"]                                     = "Unterdrückung in Instanzen"
L["ITEM_LEVEL"]                                               = "Gegenstandsstufe"
L["ITEM_SOURCE"]                                              = "Gegenstandsquelle"
L["KEEP_BAR_VISIBLE_REPOSITIONING"]                           = "Leiste für Positionierung sichtbar halten."
L["KEEP_CAMPAIGN_CATEGORY"]                                   = "Kampagnen-Quests in Abschnitt behalten"
L["KEEP_HEADER_BOTTOM_TOP_UNTIL_COLLAPSED"]                   = "Kopfbereich unten halten, oder oben bis zum Zusammenklappen."
L["KEEP_IMPORTANT_CATEGORY"]                                  = "Prioritäts-Quests in Abschnitt behalten"
L["KEEP_CAMPAIGN_READY_TURN"]                                 = "Im Kampagnenabschnitt behalten, wenn abgabebereit."
L["KEEP_IMPORTANT_READY_TURN"]                                = "Im Prioritätsabschnitt behalten, wenn abgabebereit."
L["KEEP_SECTION_HEADERS_VISIBLE_COLLAPSED"]                   = "Anschnittsüberschriften bleiben sichtbar wenn zusammengeklappt."
L["L_CLICK_OPENS_MAP_R_CLICK"]                                = "Linksklick öffnet Karte, Rechtsklick öffnet Menü."
L["PRESENCE_LEVEL_UP_TOGGLE"]                                 = "Stufenaufstieg"
L["LOCK_DRAWER_BUTTON"]                                       = "Schubladenschaltfläche fixieren"
L["LOCK_ITEM_POSITION"]                                       = "Position für Quest-Gegenstand fixieren"
L["LOCK_MINIMAP"]                                             = "Minikarte fixieren"
L["LOCK_MOUSEOVER_BAR"]                                       = "Mouseover-Leiste fixieren"
L["LOCK_RIGHT_CLICK_PANEL"]                                   = "Rechtsklick-Anzeige fixieren"
L["MAIL_ICON_PULSE"]                                          = "Pulsierendes Postsymbol"
L["MAKE_FOCUSED_ENTRIES_GREYSCALE_PARTIALLY_DESATURATE"]      = "Unfokussierte Einträge in Graustufen oder teilweise entfärbt darstellen, zusätzlich zur Abdunklung."
L["MANAGE_ADDON_BUTTONS"]                                     = "Addon-Schaltflächen verwalten"
L["VISTA_ICON_MANAGEMENT"]                                    = "Minikartenschaltflächen von anderen Addons in einer kleinen Schublade oder Leiste organisieren und verwalten."
L["MANAGE_SWITCH_BETWEEN_YOUR_ADDON_CONFIGURATIONS"]          = "Addon-Konfigurationen verwalten und wechseln."
L["MATCH_BAR_QUEST_CATEGORY_COLOUR"]                          = "Färbung der Leiste nach Abschnitt."
L["APPEAR_FULL_TRACKER_REPLACEMENTS"]                         = "Könnte bei vollständigen Zielverfolgerersatz nicht verfügbar sein."
L["MINIMAL_MODE"]                                             = "Minimalmodus"
L["MISSING_CRITERIA"]                                         = "Nur offene Kriterien"
L["MOUNT_INFO"]                                               = "Reittierinfo"
L["MOUNT_NAME_SOURCE_COLLECTION_STATUS"]                      = "Name, Quelle und Sammlungsstatus von Reittieren."
L["MOUSEOVER_CLOSE_DELAY"]                                    = "Verzögerung für Mouseover-Schließen"
L["MOUSEOVER"]                                                = "Nur Mouseover"
L["MOVE_COMPLETED_QUESTS_BOTTOM_OF_CURRENT"]                  = "Liste abgeschlossene Quests unten im Abschnitt der aktuellen Zone."
L["MYTHIC_BLOCK"]                                             = "Mythisch-Plus-Block"
L["MYTHIC_COLOURS"]                                           = "Farben für Mythisch-Plus"
L["MYTHIC_SCORE"]                                             = "Wertung für Mythisch-Plus"
L["DEFAULT"]                                                  = "Neu aus Voreinstellung"
L["HIDDEN_QUESTS"]                                            = "Keine versteckten Quests."
L["NOTIFY_ACHIEVEMENT_CRITERIA_UPDATE"]                       = "Bei Aktualisierung von Erfolgskriterien benachrichtigen."
L["OBJECTIVE_PROGRESS"]                                       = "Zielfortschritt"
L["OBJECTIVE_SPACING"]                                        = "Abstand zwischen Zielen"
L["L_CLICK_FOCUSES_R_CLICK_UNTRACKS"]                         = "AUS: Linksklick fokussiert, Rechtsklick entfolgt. STRG+Rechtsklick teilt."
L["PROGRESS_TRACKED_ACHIEVEMENTS_SHOWN"]                      = "AUS: Nur Erfolge mit kürzlichen Fortschritt anzeigen."
L["TRACKED_NEARBY_WQS_APPEAR_BLIZZARD_DEFAULT"]               = "AUS: Nur verfolgte und nahe Welt-Quests werden angezeigt (Blizzard-Standard)."
L["BOSS_EMOTES_ACHIEVEMENTS_LEVEL_HIDES_ZONE"]                = "Nur Bossgeschwätz, Erfolge und Stufenaufstiege anzeigen. Versteckt Benachrichtigungen zu Zonen, Quests und Szenarien in Mythisch-Plus."
L["ENTRIES_A_SINGLE_NUMERIC_OBJECTIVE_WHERE"]                 = "Nur für Einträge mit einzelnen numerischen Zielen, die mehr als 1 benötigen."
L["QUESTS_DON_T_NEED_NPC_TURN"]                               = "Nur für Quests ohne Abgabe-NPC. AUS = Blizzard-Standard."
L["INCOMPLETE_CRITERIA"]                                      = "Nur offene Kriterien anzeigen."
L["SUBZONE_NAME_WITHIN_SAME_ZONE"]                            = "In der gleichen Zone nur den Namen der Unterzone anzeigen."
L["OPACITY_OF_FOCUSED_QUEST_HIGHLIGHT"]                       = "Deckkraft der Hervorhebung fokussierter Quests (0–100 %)."
L["OPACITY_OF_UNFOCUSED_ENTRIES"]                             = "Deckkraft nichtfokussierter Einträge."
L["FOCUS_OPTIONAL_REAGENTS"]                                  = "Optionale Reagenzien"
L["FOCUS_RECIPE_REAGENTS_FULL_DETAIL"]                        = "Vollständige Reagenziendetails"
L["FOCUS_RECIPE_REAGENTS_FULL_DETAIL_DESC"]                   = "Alle Herstellungsplätze auflisten: optionale und Fertigungsreagenzien, Auswahlplätze mit allen Varianten, sowie nicht-Basisreagenzien. AUS: Nur Basisreagenzienplätze nutzen das erste Reagenz pro Platz (Listenstil einer kompakten Einkaufsliste)."
L["ORGANIZE_HIDE_TRACKED_ENTRIES_YOUR_PREFERENCE"]            = "Verfolgte Einträge nach Bedarf organisieren verstecken."
L["OVERRIDE_FONT_PER_ELEMENT"]                                = "Schriftart pro Element überschreiben."
L["PANEL_BACKGROUND_OPACITY"]                                 = "Hintergrunddeckkraft der Anzeige (0–100 %)."
L["PERMANENTLY_HIDE_UNTRACKED_QUESTS"]                        = "Nichtverfolgte Quests dauerhaft verstecken."
L["PERSONALIZE_COLOUR_PALETTE_TRACKER_TEXT_ELEMENTS"]         = "Die Farbpalette für Textelemente des Zielverfolgers personalisieren."
L["POSITIONING_VISIBILITY_CACHE_LOOT_TOAST_SYS"]              = "Positionierung und Sichtbarkeit der Cache-Beutebenachrichtigungen."
L["PREVENT_ACCIDENTAL_CLICKS"]                                = "Verhindert ungewollte Klicks."
L["QUALITY_INFO"]                                             = "Qualitätsinfo"
L["QUEST_ACCEPT"]                                             = "Quest angemommen"
L["QUEST_COMPLETE"]                                           = "Quest abgeschlossen"
L["QUEST_COUNT"]                                              = "Anzahl der Quests"
L["QUEST_ITEM_BUTTONS"]                                       = "Schaltflächen für Quest-Gegenstände"
L["QUEST_LEVEL"]                                              = "Quest-Stufe"
L["QUEST_PROGRESS"]                                           = "Quest-Fortschritt"
L["QUEST_PROGRESS_BAR"]                                       = "Fortschrittsleiste für Quests"
L["QUEST_TRACKING"]                                           = "Quest-Verfolgung"
L["QUEST_TYPE_ICONS"]                                         = "Symbole für Quest-Typ"
L["FOCUS_QUEST_TYPE_ICON_SIZE"]                               = "Größe der Quest-Typsymbole"
L["FOCUS_QUEST_TYPE_ICON_SIZE_DESC"]                          = "Größe des Quest-Typsymbols (Standard: 16)."
L["PRESENCE_RARE_DEFEATED"]                                   = "SELTENER GEGNER BESIEGT"
L["RARE_ADDED_SOUND_CHOICE"]                                  = "Auswahl des Audioeffekts für Seltenes"
L["RARE_SOUND_ALERT"]                                         = "Audioeffekt für Seltenes"
L["RARITY_COLOURS"]                                           = "Färbung nach Seltenheit"
L["READY_TURN_GROUP"]                                         = "Abschnitt für abgabebereite Quests"
L["READY_TURN_BOTTOM"]                                        = "Abgabebereite Quests unten listen"
L["REAGENTS"]                                                 = "Reagenzien"
L["RECIPE_ICONS"]                                             = "Rezeptsymbole"
L["RECIPES"]                                                  = "Rezepte"
L["REDUCE_OPACITY_OF_FOCUSED_ENTRIES_INVISIBLE"]              = "Deckkraft für nichtfokussierte Einträge (0 = unsichtbar, 100 = volle Deckkraft). Standard: 100 % (keine Änderung)"
L["REQUIRE_CTRL_COMPLETE_CLICK_COMPLETABLE_QUESTS"]           = "STRG für Klickabschluss-Quests erforderlich."
L["REQUIREMENTS"]                                             = "Anforderungen"
L["REQUIRES_QUEST_TYPE_ICONS_ENABLED_DISPLAY"]                = "Benötigt eingeschaltete Quest-Typsymbole."
L["RESET_MYTHIC_STYLING"]                                     = "Mythisch-Plus-Darstellung zurücksetzen"
L["REVIEW_MANAGE_QUESTS_YOU_MANUALLY_UNTRACKED"]              = "Manuell entfolgte oder gesperrte Quests verwalten."
L["RIGHT_CLICK_CLOSE_DELAY"]                                  = "Verzögerung für Rechtsklick-Schließen"
L["SANCTUARY_ZONE_COLOUR"]                                    = "Farbe sicherer Zonen"
L["SCALE_UI_ELEMENTS"]                                        = "Sämtliche UI-Elemente skalieren (50–200 %)."
L["PRESENCE_SCENARIO_COMPLETE"]                               = "Szenario abgeschlossen"
L["SCENARIO_EVENTS"]                                          = "Szenarioereignisse"
L["SCENARIO_PROGRESS"]                                        = "Szenariofortschritt"
L["SCENARIO_PROGRESS_BAR"]                                    = "Fortschrittsleiste für Szenarien"
L["SCENARIO_START"]                                           = "Szenariobeginn"
L["SCENARIO_TIMER_BAR"]                                       = "Timer-Leiste für Szenarien"
L["SCROLL_INDICATOR"]                                         = "Scroll-Indikator"
L["SECONDS_OF_RECENT_PROGRESS"]                               = "Erforderliche Anzahl der Sekunden kürzlichen Fortschritts zum anzeigen."
L["SECTION_DIVIDER_COLOUR"]                                   = "Farbe des Abschnitttrenners"
L["SECTION_HEADERS"]                                          = "Abschnittsüberschriften"
L["SECTIONS_COLLAPSED"]                                       = "Abschnitte wenn zusammengeklappt"
L["SEPARATE_SCALE_SLIDER_PER_MODULE"]                         = "Separate Skalierung pro Modul."
L["SHADOW_OPACITY"]                                           = "Schattendeckkraft (0–100 %)."
L["A_VISUAL_DIVIDER_LINE_BETWEEN_FOCUS"]                      = "Fügt einen visuellen Trenner zwischen Focus-Abschnitten zur leichteren Unterscheidung ein."
L["AFFIX_NAMES_FIRST_DELVE_ENTRY"]                            = "Affix-Namen im ersten Tiefen-Eintrag anzeigen."
L["COLLAPSIBLE_CHOICE_REAGENT_SLOTS"]                         = "Einklappbare Reagenzienauswahlplätze anzeigen."
L["COMPLETED_ACHIEVEMENTS_LIST"]                              = "Abgeschlossene Erfolge in der Liste anzeigen."
L["FINISHING_REAGENT_SLOTS"]                                  = "Fertigungsreagenzienplätze anzeigen."
L["MANY_TIMES_RECIPE_CRAFTED"]                                = "Zeigt an, wie oft das Rezept hergestellt werden kann."
L["NORMAL_DUNGEONS"]                                          = "In normalen Dungeons anzeigen."
L["LOCAL_SYSTEM"]                                             = "Lokale Systemzeit anzeigen."
L["NOTIFICATION_A_RARE_MOB_DEFEATED_NEARBY"]                  = "Benachrichtigung bei Sieg über seltene Gegner in der Nähe."
L["NOTIFICATION_A_SCENARIO_DELVE_FULLY_COM"]                  = "Benachrichtigung bei vollständigen Abschluss von Szenarien oder Tiefen."
L["OBJECTIVE_LINE"]                                           = "Nur Zielzeile anzeigen."
L["HOVER"]                                                    = "Nur bei Mouseover anzeigen."
L["ACTIVE_INSTANCE_SECTION"]                                  = "Nur den aktiven Instanz-Abschnitt anzeigen."
L["OPTIONAL_REAGENT_SLOTS"]                                   = "Optionale Reagenzplätze anzeigen."
L["RECIPES_TIER_QUALITY_PIPS"]                                = "Qualitätsstufen für Rezepte anzeigen, die darüber verfügen."
L["REAGENT_SHOPPING_LIST_RECIPE"]                             = "Einkaufsliste für Rezepte anzeigen."
L["FOCUS_AH_SEARCH_TITLE"]                                    = "Auktionshaus durchsuchen"
L["FOCUS_AH_SEARCH_TOOLTIP"]                                  = "Linksklick: Suche nach Reagenzien für eine einzelne Herstellung. (Gegenstandsqualität und Herstellungsstufe, wenn Auctionator sie unterstützt).\nRechtsklick: Herstellungsmenge und optionale Herstellungsstufe (Menü, 1–5) — 'Beliebig' für keine Qualitäts- oder Stufenfilter auf der Liste wählen.\nDas Auktionshausfenster muss dazu geöffnet sein."
-- L["FOCUS_AUCTIONATOR_SEARCH"]                              = "Auctionator search button"
-- L["FOCUS_AUCTIONATOR_SEARCH_DESC"]                         = "Show a button on recipe entries to search for required reagents in the Auction House (requires Auctionator)."
L["FOCUS_AH_CRAFT_DIALOG_SUBTITLE"]                           = "Einkaufsliste für Auktionshaus"
L["FOCUS_AH_CRAFT_HINT_CRAFT_COUNT"]                          = "Anzahl der Herstellungen für den Materialkauf (1–999). Listenmengen werden mit diesem Wert multipliziert."
L["FOCUS_AH_CRAFT_HINT_TIER"]                                 = "Optionale Qualitätsstufestufe (1–5) in jeder Zeile. Für breiteres Suchfeld 'Beliebige Stufe' wählen."
L["FOCUS_AH_CRAFT_TIER_ANY"]                                  = "Beliebige Stufe"
L["FOCUS_AH_CRAFT_TIER_N"]                                    = "Stufe %d"
L["FOCUS_AH_CRAFT_COUNT_INVALID"]                             = "Ganzzahl zwischen 1 und 999."
L["RECENT_PROGRESS_TOP"]                                      = "Kürzlichen Fortschritt oben auflisten."
L["RECIPE_ICON_NEXT_TITLE_REQUIRES_QUEST"]                    = "Rezeptsymbol neben Titel anzeigen. Erfordert aktivierte Symbole für  Quest-Typen."
L["SECTION_DIVIDERS"]                                         = "Trenner für Abschnitte anzeigen"
L["M_BLOCK_WHENEVER_AN_ACTIVE_KEYSTONE"]                      = "Mythisch-Plus-Block bei laufenden Schlüsselstein immer anzeigen."
L["TRACKED_PROFESSION_RECIPES_LIST"]                          = "Verfolgte Berufsrezepte in der Liste anzeigen."
L["TRACKER_HEROIC_DUNGEONS"]                                  = "Zielverfolger in heroischen Dungeons anzeigen. AUS: Globale Dungeon-Einstellung verwenden."
L["TRACKER_HEROIC_RAIDS"]                                     = "Zielverfolger in heroischen Schlachtzügen anzeigen. AUS: Globale Schlachtzug-Einstellung verwenden."
L["TRACKER_LFR_RAID"]                                         = "Zielverfolger in Schlachtzugsbrowser anzeigen. AUS: Globale Schlachtzug-Einstellung verwenden."
L["TRACKER_MYTHIC_KEYSTONES"]                                 = "Zielverfolger in Mythisch-Plus-Dungeons anzeigen. AUS: Globale Dungeon-Einstellung verwenden."
L["TRACKER_MYTHIC_DUNGEONS"]                                  = "Zielverfolger in mythischen Dungeons anzeigen. AUS: Globale Dungeon-Einstellung verwenden."
L["TRACKER_MYTHIC_RAIDS"]                                     = "Zielverfolger in mythischen Schlachtzügen anzeigen. AUS: Globale Schlachtzug-Einstellung verwenden."
L["TRACKER_NORMAL_DUNGEONS"]                                  = "Zielverfolger in normalen Dungeons anzeigen. AUS: Globale Dungeon-Einstellung verwenden."
L["TRACKER_NORMAL_RAIDS"]                                     = "Zielverfolger in normalen Schlachtzügen anzeigen. AUS: Globale Schlachtzug-Einstellung verwenden."
L["TRACKER_PARTY_DUNGEONS"]                                   = "Zielverfolger in Dungeons anzeigen. Globale Einstellung für alle Dungeon-Schwierigkeitsgrade."
L["TRACKER_RAIDS_ALL"]                                        = "Zielverfolger in Raids anzeigen. Globale Einstellunge für alle Raid-Schwierigkeitsgrade."
L["UNMET_CRAFTING_STATION_REQUIREMENTS"]                      = "Unerfüllte Anforderung für Herstellungsstation anzeigen."
L["SHOWN_HOVERING_A_MOUNTED_PLAYER"]                          = "Wird angezeigt, wenn die Maus über einen berittenen Spieler platziert wird."
L["SIZE_SHAPE"]                                               = "Größe & Form"
L["SIZE_OF_ZOOM_BUTTONS_PIXELS"]                              = "Größe der Zoom-Schaltflächen in Pixel."
L["SORT_MODE"]                                                = "Sortiermethode"
L["SORTING_FILTERING"]                                        = "Sortierung & Filterung"
L["SOUND_PLAYED_A_RARE_BOSS_APPEARS"]                         = "Audioeffekt beim Erscheinen seltener Gegner."
L["STATUS_BADGES"]                                            = "Statusmarkierungen"
L["SUBZONE_CHANGES"]                                          = "Unterzonenänderungen"
L["SUPER_TRACKED_FIRST_CURRENT_ZONE_FIRST"]                   = "Vorrangig super-verfolgte oder aktuelle Zone."
L["SUPPRESS_IN_ARENA_DETAIL"]                                 = "Unterdrücke sämtliche Presence-Benachrichtigungen in Arenen."
L["SUPPRESS_PRESENCE_NOTIFICATIONS_WHILE_INSIDE_A"]           = "Unterdrücke sämtliche Presence-Benachrichtigungen auf Schlachtfeldern."
L["SUPPRESS_IN_DUNGEON_DETAIL"]                               = "Unterdrücke alle Presence-Benachrichtigungen in Dungeons (Ausnahmen: Bossgeschätz, Erfolge und Stufenaufstiege)."
L["SUPPRESS_IN_RAID_DETAIL"]                                  = "Unterdrücke alle Presence-Benachrichtigungen im Schlachtzug."
L["SUPPRESS_M"]                                               = "Unterdrückt in Mytisch-Plus"
L["SUPPRESS_PVP"]                                             = "Unterdrückt in PvP"
L["SUPPRESS_BATTLEGROUND"]                                    = "Unterdrückt in Schlachtfeldern"
L["SUPPRESS_DUNGEON"]                                         = "Unterdrückt in Dungeons"
L["SUPPRESS_RAID"]                                            = "Unterdrückt in Schlachtzügen"
L["SUPPRESS_NOTIFICATIONS_DUNGEONS"]                          = "Unterdrückt Benachrichtigungen in Dungeons."
L["TAKES_PRIORITY_SUPPRESS_UNTIL_RELOAD_ACCEPTING"]           = "Übersteuert 'Unterdrücken bis zum Neuladen'. Die annahme von Quests entfernt sie aus der Sperrliste."
L["TOAST_ICONS"]                                              = "Symbole für Benachrichtigungen"
L["TOGGLE_TRACKING_WORLD_QUESTS_RARES_ACHIEVEMENTS"]          = "Verfolgung für Welt-Quests, seltene Gegner/Schätze und mehr."
L["TOOLTIP_ANCHOR"]                                           = "Tooltip-Anker"
L["TRACKED_OBJECTIVES_ADVENTURE_GUIDE"]                       = "Verfolgte Ziele aus dem Abenteuerführer."
L["TRACKED_VS_LOG_COUNT"]                                     = "Anzahl verfolgt vs. Anzahl im Log."
L["TRACKED_LOG_LOG_MAX_TRACKED_EXCLUDES"]                     = "Verfolgte/Im Log oder Im Log/Maximal. Verfolgte beinhalten keine Welt- und Zonen-Quests."
L["TRANSMOG_STATUS"]                                          = "Transmog-Status"
L["TRAVELERS_LOG"]                                            = "Reisetagebuch"
L["TUNE_SLIDE_FADE_EFFECTS_PLUS_OBJECTIVE"]                   = "Wisch- & Verblassungseffekte, sowie Leuchten bei Zielfortschritt konfigurieren."
L["UNBLOCK"]                                                  = "Blockierung aufheben"
L["UNTRACK_COMPLETE"]                                         = "Nach Abschluss entfolgen"
L["CHECKMARK_COMPLETED_OBJECTIVES"]                           = "Häkchen für abgeschlossene Ziele verwenden."
L["VISIBILITY_FADING"]                                        = "Sichtbarkeit & Abblendung"
L["COMPLETED_QUESTS_STAY_THEIR_ORIGINAL_CATEGO"]              = "AUS: Abgeschlossene Quests verbleiben in ihrem ursprünglichen Abschnitt."
L["ZONE_QUESTS_APPEAR_THEIR_NORMAL_CATEGORY"]                 = "AUS: Quests in aktueller Zone verbleiben im normalen Abschnitt."
L["THEY_MOVE_COMPLETE_SECTION"]                               = "AUS: Quests werden in den abgabebereiten Abschnitt verschoben."
L["CUSTOM_FILL_COLOUR_BELOW"]                                 = "AUS: Die unten definierte Füllfarbe wird verwendet."
L["COMPLETED_OBJECTIVES_COLOUR_BELOW"]                        = "EIN: Abgeschlossene Ziele verwenden die unten definierte Farbe."
L["WHERE_COUNTDOWN"]                                          = "Anzeigeposition des Countdowns."
L["WORLD_QUEST_ACCEPT"]                                       = "Welt-Quest angenommen"
L["WORLD_QUEST_COMPLETE"]                                     = "Welt-Quest abgeschlossen"
L["X_Y_OBJECTIVES_LIKE_PERCENT_OBJECTIVES"]                   = "Numerische Ziele: X/Y. Prozentuale Ziele: 45 %%."
L["ZONE_ENTRY"]                                               = "Zoneneintritt"
L["ZONE_LABELS"]                                              = "Zonenbeschriftungen"
L["ZONE_NAME_NEW_ZONE"]                                       = "Der Zonenname erscheint weiterhin beim Betreten einer neuen Zone."
L["ZONE_TYPE_COLOURING"]                                      = "Färbung nach Zonentyp"
L["FOCUS_COMPLETED_CHECKMARK"]                                = "|TInterface\\\\Buttons\\\\UI-CheckBox-Check:12:12:0:0|t anstelle von grüngefärbten abgeschlossenen Zielen."































































































































































