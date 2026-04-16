# Changelog

All notable changes to Horizon Suite are documented here.

---

## [Unreleased]

<!-- Changelog entries are generated from closed GitHub Issues at release time. -->

---

## [4.12.4] – 2026-04-16

### 🐛 Fixes

- **(Insight)** Rolled back a recent change that was causing issues.

---

## [4.12.3] – 2026-04-16

### 🔧 Improvements

- **(Axis) Module name style** — New setting to control how module names appear: **Horizon** (code-name only, default), **Subtitle** (e.g. "Vista – Minimap"), or **Descriptive** (plain-language name only). Applies across options navigation and section headers.
- **(Focus) Grow Upwards priority order** — With **Grow Upwards** enabled, section headers now visually flip so High priority sits closest to the Objectives header at the bottom, matching the reversed growth direction.

### 🐛 Fixes

- **(Focus)** Current Event now reappears for World Quests you have **untracked** when you enter their zone, so the in-area event banner works without needing to re-track the quest.

---

## [4.12.2] – 2026-04-14

### 🔧 Improvements

- **(Insight) Gate NotifyInspect on player tooltip options** — Disabling every option under Player Characters now fully stops Insight from sending inspect requests on player mouseover, so other inspect-dependent addons are no longer interrupted. A new "Spec icon & role" toggle controls the spec/role line and its inspect query.

---

## [4.12.1] – 2026-04-13

### 🐛 Fixes

- **(Focus)** Warbound weekly quests now sort and track correctly; right-click to untrack no longer fails for Warbound weeklies.
- **(Focus)** Quest item button cooldowns now update properly while in combat.

---

## [4.12.0] – 2026-04-12

### ✨ New Features

- **(Axis)** **Resizable dashboard** with a **corner grabber**, **saved size and position**, and shared **layout scaling** helpers
- **(Axis)** **Ctrl+F** opens dashboard **search** from the options UI, and the search field is **focused** after you change **sidebar** sections

### 🔧 Improvements

- **(Axis)** **Handheld and narrow layouts** — patch notes and headers reflow without overlap, the **search bar** stays constrained, the **sidebar** scroll resets sensibly when content fits, and **accordions** / **two-column tiles** adapt on resize
- **(Vista)** **Minimap button** visibility and related settings are grouped under **Vista** with other minimap UI options

### 🐛 Fixes

- **(Focus)** Tracked **world quests** open on the **correct zone map** instead of the wrong area view
- **(Axis)** Dashboard layout stays **usable** on very **small** or **handheld-sized** windows — overlap, width, and resize **edge cases**

---

## [4.11.0] – 2026-04-10

### ✨ New Features

- **(Axis)** Dashboard **search page** with pinned sidebar entry and layout polish
- **(Axis)** Dashboard search: **filter results by module**
- **(Axis)** Welcome **scrollable feed** with detail wiring and locale strings
- **(Focus)** **Custom click profiles** for the objective tracker — map your own modifier combos to each row, or choose **Horizon+** for Horizon Suite's unified preset and row actions

### 🔧 Improvements

- **(Axis)** Overhaul **welcome** view, module guide, and home toggle cards
- **(Axis)** Welcome refresh and **minimap-open** keyboard fix
- **(Focus)** Unify **objective tracker icon** clicks with click profiles
- **(Axis)** **Settings search** — ranked matches, visible descriptions, and search bar only on the Search page
- **(Axis)** **All** module filter omits settings for **disabled** modules (Axis options still appear)
- **(Axis)** **News** refresh and copy aligned with Focus click options and Horizon+ / Blizzard+ defaults

### 🐛 Fixes

- **(Insight)** Unit and item tooltips avoid errors from **Midnight secret-value** API usage

---

## [4.10.0] – 2026-04-08

### ✨ New Features

- **(Insight)** Tooltip anchoring — cursor-follow tooltips can appear to the **left**, **right**, or **center** of the cursor, with optional offsets when using left or right

### 🔧 Improvements

- **(Axis)** Release packages no longer include internal **docs** and **tools** folders after packager and ignore updates
- **(Insight)** Item quality used for tooltip styling follows current item info data more reliably

### 🐛 Fixes

- **(Focus)** Quest-complete row no longer wipes the **inline countdown** on timed click-to-complete quests
- **(Insight)** **World-cursor** NPC tooltips — fewer errors and sturdier default cursor anchoring
- **(Insight)** **Player** tooltips keep custom styling when you move away and hover the same unit again
- **(Insight)** **Unit** tooltips keep addon content when Blizzard refreshes the frame via SetUnit

---

## [4.9.4] – 2026-04-07

### 🔧 Improvements

- **(Insight)** NPC tooltips keep Blizzard’s subtitle on the second line when the custom level line is enabled — level moves to line three when the subtitle is real content, not the level row

---

## [4.9.3] – 2026-04-06

### 🔧 Improvements

- **(Axis)** Dashboard typography: body text size in pixels, outline style dropdown, and text shadow toggle, with migration from older offset/outline/shadow keys
- **(Axis)** Option widgets pick up font flag changes when dashboard typography is updated
- **(Axis)** Home module tiles: class-coloured hover ring and clearer preview and coming-soon idle and hover states

### 🐛 Fixes

- **(Axis)** Settings search bar stays visible when you open a module after Welcome or Quick Start
- **(Focus)** Tracked quests that use `[DNT]` placeholder titles or objectives are left out of the tracker

---

## [4.9.2] – 2026-04-06

### 🔧 Improvements

- **(Focus)** Quest type icons are on by default for existing profiles (saved migration)
- **(Focus)** Header text case option default matches the tracker’s uppercase style
- **(Axis)** Dashboard sidebar: clicking a module row opens that module’s view and highlights its header
- **(Axis)** Home and subcategory cards use aligned chrome; Quick Start path glyphs fixed
- **(Axis)** Batching module on/off toggles applies a single deferred UI reload
- **(Insight)** Tooltip flags use hook-sourced state to avoid unsafe Midnight secret boolean checks
- **(Vista)** Difficulty text is anchored to the minimap, independent of the zone label
- **(Localization)** Locale restructure uses plain commented stubs (no `NEEDS TRANSLATION` suffix); multiline commented stubs and tooling updated accordingly

### 🐛 Fixes

- **(Axis)** Dashboard options search: accordion rows no longer overlap after jumping to a match

---

## [4.9.1] – 2026-04-06

### 🔧 Improvements

- **(Axis)** German (deDE) options and dashboard strings updated from a contributor export — many new or revised translations (appearances, click actions, context menu, backgrounds, Presence options); all locale files aligned with English key order via restructure

---

## [4.9.0] – 2026-04-05

### ✨ New Features

- **(Focus)** Auctionator craft dialog from the tracker includes a crafting tier menu (1–5)
- **(Focus)** Right-click auction house recipe search from the tracker can multiply reagent quantities by your craft count

### 🔧 Improvements

- **(Focus)** Auction craft dialog scales with your UI scale and Cancel/OK layout is clearer

### 🐛 Fixes

- **(Insight)** Tooltip handling no longer spams Lua errors when the game restricts certain boolean checks (e.g. Mythic+)

---

## [4.8.6] – 2026-04-05

### 🐛 Fixes

- **(Focus)** Delves section only picks up Delve-tagged quests from your log while you’re in a delve, instead of treating every nearby quest as Delve content

### 🔧 Improvements

- **(Focus)** Long objective lines wrap within the tracker after zone or affix rows, and wrapped affix names keep the first objective left-aligned under the full affix block

---

## [4.8.5] – 2026-04-05

### 🔧 Improvements

- **(Focus)** Optional Events in Zone content — turn off under Sorting & Filtering → Grouping to hide nearby unaccepted and zone-event quests from the tracker
- **(Axis)** More dashboard background themes, smaller JPG bundles, Teldrassil preset becomes a burning Teldrassil image with automatic migration for existing profiles

---

## [4.8.4] – 2026-04-05

### 🔧 Improvements

- **(Focus)** Delve affix names keep your tracker font; middle-dot separators use the game font so narrow fonts no longer show missing glyphs between modifiers
- **(Focus)** Long delve affix lists wrap within the tracker width and objectives sit below the full affix block instead of overlapping

---

## [4.8.3] – 2026-04-05

### 🔧 Improvements

- **(Focus)** Tracked achievement rows in the tracker with optional progress bars and description fallback
- **(Focus)** Recipe tooltips use a compact reagent list by default, with an option for full schematic detail
- **(Focus)** Auctionator shopping lists built from recipes include quantities
- **(Focus)** Quest level next to titles no longer relies on a separate “remove L” toggle
- **(Axis)** Dashboard JPG background bundles, expanded themes, updated options and locales

### 🐛 Fixes

- **(Insight)** Unit tooltips no longer error when hovering certain targets (secret unit token)

---

## [4.8.2] – 2026-04-03

### ✨ New Features

- **(Focus)** Tracker row interactions — transmog appearances (map, context menu, waypoints where enabled), clearer completion from clicks on finished quests, optional WoWhead line on tooltips, and new locale strings
- **(Insight)** Long numeric runs in tooltip and UI text can show thousands grouping (shared formatting with Focus objective lines)

### 🔧 Improvements

- **(Focus)** Optional colours on X/Y objective progress (gold in progress, green when complete) — toggle under Focus display
- **(Focus)** When objective count colouring is on, the slash between X and Y uses the same tint so the whole token reads as one styled unit
- **(Axis)** Module dashboard background defaults to Midnight; existing flat defaults migrate once; the flat style is labelled Minimalistic in settings
- **(Axis)** Bundled Night Fae and Zin-Azshari dashboard background art; legacy stored theme ids normalise to Midnight while the options list stays streamlined

---

## [4.8.1] – 2026-04-03

### 🔧 Improvements

- **(Axis)** Dashboard Welcome tab is driven by a configurable feed and a dedicated view, so announcements and sections are easier to maintain and extend
- **(Focus)** Bar left and Pill left active-quest highlights place the quest type icon beside the highlight bar and align quest titles without extra left padding when icons are shown

---

## [4.8.0] – 2026-04-03

### ✨ New Features

- **(Focus)** Introducing Blizzard+ as the standard for Focus; profile-based quest row clicks (including Classic Click) ship now, with Horizon+ and further customisation coming soon.

### 🔧 Improvements

- **(Axis)** Configurable font and text size for the Axis settings window
- **(Focus)** Resizing quest type icons keeps them inside the tracker panel for bar-left and pill-left active-quest highlights

---

## [4.7.0] – 2026-04-03

### ✨ New Features

- **(Focus)** Tracked transmog appearances in the tracker — Horizon and classic click behaviour, stable super-track, optional map/TomTom and dressing room
- **(Insight)** Custom class icons from files in the addon media folder

### 🔧 Improvements

- **(Insight)** Tooltip pipeline and shared display tweaks
- **(Focus)** Section headers and category order use localized UI labels
- **(Axis)** BLP class icons, dashboard welcome polish, and community footer updates
- **(Axis)** Dashboard footer — intrinsic wordmark sizing, optimized textures, mixed-script welcome font

---

## [4.6.1] – 2026-04-02

### 🔧 Improvements

- **(Insight)** Optional hide tooltips in combat — toggle under Insight → Global Tooltips closes styled tooltip frames when you enter combat and blocks them from staying open while fighting
- **(Axis)** Discord invite links updated in the dashboard, READMEs, and GitHub issue template so community links point at the current server
- **(Axis)** README and CurseForge listing refresh — clearer install steps, expanded CurseForge page copy, Basic Commands table removed from short READMEs

---

## [4.6.0] – 2026-04-01

### ✨ New Features

- **(Axis)** Dashboard Quick Start guide, streamlined Welcome, and locale updates

### 🔧 Improvements

- **(Insight)** Stop shopping tooltip fade flicker on minimap and world quest item tooltips
- **(Axis)** Dashboard welcome — community links with icons, mixed-script contributor text, and Cache hero art
- **(Vista)** Minimap — mouse-wheel zoom only; overlay zoom controls removed; reset overlay positions
- **(Focus)** Show Alt + Click hint next to WoWhead link in tooltip
- **(Focus)** Quest level next to titles uses bracketed numbers (e.g. `[60]`) instead of an `L` prefix (`[L60]`) when level display is enabled
- **(Axis)** Patch notes attention, labelling, and dashboard polish
- **(Insight)** Unit tooltip dismiss options and deferred dismiss behaviour
- **(Insight)** Player-frame unit tooltips; choose faction or class colour for the player name on the first line
- **(Axis)** What's New — version dates and capitalized module bullets

### 🐛 Fixes

- **(Insight)** Unit tooltip frame sometimes stays unskinned on refresh

---

## [4.5.0] – 2026-03-31

### ✨ New Features

- **(Presence)** Untracked achievements — optional progress toasts when an achievement is not on the tracker

### 🔧 Improvements

- **(Focus)** Stable achievement tracking and content-tracking refresh
- **(Focus)** Quest row pool increased from 25 to 50
- **(Focus)** Scenario and delve updates — fewer FPS dips from reduced layout churn
- **(Focus)** Dim unfocused applies only to quest rows, not achievements, endeavors, or rares

### 🐛 Fixes

- **(Presence)** Achievement progress toast showed the wrong criterion for multi-part achievements

---

## [4.4.2] – 2026-03-31

### 🔧 Improvements

- **(Vista)** Minimap — Horizon icon refresh, optional Vista collector integration, fade until the cursor is over the map, and tooltip anchored to the minimap button when it moves or resizes
- **(Axis)** Core and options dashboard — modular dashboard layout, profile import/export, URL copy dialog, and tooling layout updates

### 🐛 Fixes

- **(Focus)** Dim strength and dim alpha apply consistently when dimming unfocused entries
- **(Focus)** Text shadow offsets apply consistently across section headers, quest titles, and related controls

---

## [4.4.1] – 2026-03-30

### 🐛 Fixes

- **(Focus)** Turning off In Raid or In Dungeon for the tracker now hides it reliably — master visibility is applied before per-difficulty raid/dungeon options, so stale granular settings no longer keep the panel visible.

---

## [4.4.0] – 2026-03-29

### ✨ New Features

- **(Axis)** Localisation 2.0 — restructured string files and maintainer tooling
- **(Insight)** Tooltip options split across focused pages with a contextual dashboard preview
- **(Insight)** Cursor-follow tooltips with optional position offsets
- **(Axis)** Font dropdowns show each option in its own typeface
- **(Insight)** Live Insight tooltip preview on the dashboard; mount ownership in relevant tooltips
- **(Focus)** Zone changes refresh tracker rows reliably
- **(Insight)** Per-type tooltip styling options

### 🔧 Improvements

- **(Axis)** Options dashboard — modular layout under options/dashboard
- **(Axis)** Horizon module names use consistent English labels in the UI
- **(Insight)** Midnight-safe unit tooltips, per-section font sizes, and polish
- **(Vista)** Minimap FPS/latency strip — urgency colours on values, improved layout and dragging (no extended performance hover panel)

### 🐛 Fixes

- **(Presence)** Scenario progress toast shows the full count on the last objective of a step

---

## [4.3.1] – 2026-03-26

### 🔧 Improvements

- **(Axis)** Rename Yield and Persona modules to Cache and Essence
- **(Axis)** What's New — inline patch notes in the Dashboard
- **(Axis)** Dashboard — Meridian coming-soon tile, locales, and welcome layout

### 🐛 Fixes

- **(Insight)** Tooltip enhancements work more cleanly with the default UI, without error popups

---

## [4.3.0] – 2026-03-25

### ✨ New Features

- **(Axis)** Unified class colours — batch toggle and per-module tinting
- **(Focus)** Colour choices for global accents, headers, and objectives
- **(Axis)** Dashboard class icon using shared class icon media
- **(Axis)** Global toggles for class colours and scale; module options grouped for on/off and minimap
- **(Axis)** Dashboard background can use your current specialization’s talent art
- **(Axis)** Welcome screen and dashboard refresh

### 🔧 Improvements

- **(Insight)** Defer tooltip width clamping for more reliable tooltip layout
- **(Insight)** Fade out stale unit tooltips when mouseover clears

---

## [4.2.2] – 2026-03-24

### 🐛 Fixes

- **(Axis)** In-game What's New includes the 4.2.1 Focus and Presence fixes — patch notes data was missing from the 4.2.1 build, and the panel only shows entries for the current version

---

## [4.2.1] – 2026-03-24

### 🐛 Fixes

- **(Focus)** Bonus objectives stay visible when scenario row has no real content
- **(Presence)** Quest update toast shows wrong objective on multi-objective quests

---

## [4.2.0] – 2026-03-23

### ✨ New Features

- **(Axis)** New installs start with Horizon modules off until you enable them
- **(Axis)** Dashboard welcome tab and first-run onboarding — Welcome sidebar above Home; first options open can show Welcome once per profile, then Home by default

### 🔧 Improvements

- **(Focus)** Remaining delve lives on the Focus tracker scenario line — at-a-glance during a run without extra panels

### 🐛 Fixes

- **(Axis)** Options colour pickers for Focus and Vista no longer freeze the client or fail to apply colours
- **(Axis)** Dashboard accordion cards expand and collapse only from the header row, not when clicking settings inside the card

---

## [4.1.2] – 2026-03-18

### 🔧 Improvements

- **(Focus) WoWhead link in Focus tracker tooltips and copy-link box**
- **(Axis) Draggable minimap button with lock and reset options**

### 🐛 Fixes

- **(Axis) Fix release pipeline YAML parse error in debug lines**

---

## [4.1.0] – 2026-03-18

### ✨ New Features

- **(Profile) Add Essence module (Preview): custom character sheet with 3D model, item level, stats, gear grid**
- **(Focus) Auctionator search button on recipe entries in Focus tracker**

### 🔧 Improvements

- **(Focus) Auctionator recipe search: use CreateShoppingList and named lists**
- **(Insight) Insight tooltip fixes: item identity reapply, GetItem fallback, mouseover hide**
- **(Core) Promote Insight to stable**

---

## [4.0.0] – 2026-03-18

### ✨ New Features

- **(Focus) Dev mode: show Blizzard tracker alongside Focus for comparison**
- **(Focus) Objectives can render outside the tracker window**
- **(Focus) Focus tracker header options: quest count, divider, color, height, options button**
- **(Focus) Groupings toggle on or off**
- **(Core) Minimap icon and WoW settings panel integration**

### 🔧 Improvements

- **(Core) Beta release zip no longer returns 404 when job artifacts expire**
- **(Core) Discord issuelog: rename Improvements to Improvement Requests**
- **(Core) Dashboard live refresh when modules are toggled**
- **(Core) Refactor color matrix to compact cards and add Section Overrides**
- **(Core) Restructure locale system, add locale debug and CI audit, improve options panel and Focus grouping**
- **(Core) Global font size offset and options panel visibility improvements**
- **(Vista) Minimap button fades in on hover**
- **(Focus) Defer map event handlers to avoid taint; show delve affix tooltip on hover**
- **(Core) Dashboard class colours: separate toggle and live refresh**
- **(Insight) Insight tooltip shows transmog status for trinkets, rings, necks**
- **(Core) Merge Profiles and Modules into single Axis group in options dashboard**
- **(Core) Dashboard: version API fallback, clean card/tile teardown, and sidebar collapse hides child tabs**
- **(Core) Release announcements include direct CurseForge and Wago links**
- **(Core) Cache: Draggable anchor frame for repositioning loot toasts**
- **(Core) Dashboard: Back button, sidebar state, and Focus colours refactor**
- **(Core) Animated card relayout when options visibility changes**
- **(Core) Options dashboard: hide dependent options when parent toggle is off**
- **(Core) Compact options widgets and move descriptions to tooltips**
- **(Focus) Setting to show or hide tooltips on hover in Focus tracker**
- **(Focus) Spacing preset dropdown (Default, Compact, Spaced, Custom) and title-to-content gap**
- **(Focus) Scenario tracker: stage line, objective deduplication, and current event suppression**
- **(Focus) French: Dedicated Traque Section**
- **(Insight) Insight tooltip options: background opacity, blank separator, show icons; remove accent bar**
- **(Insight) Optional RondoMedia class icons in Insight tooltips**

### 🐛 Fixes

- **(Focus) Delve name shows wrong or disappears during reward stage**
- **(Core) Relayout animation cancellation leaves card in inconsistent state**
- **(Core) Dashboard sidebar stays synced across home, module, and category views**
- **(Core) Fix Discord release announcement embed size limit**
- **(Presence) Fix stale 0/X in delve and scenario completion text**
- **(Focus) Focus tracker moves on /reload**
- **(Focus) Tracker panel nudges when toggling grow-up off**
- **(Focus) World Quest and task quest timers tick back up one second during refresh**
- **(Focus) Quest Level: Lowercase "L"**
- **(Focus) Typography: Improper Proper Case**

---

## [3.11.6] – 2026-03-13

### 🐛 Fixes

- **(Focus) Abundance scenario detection fails for localized clients** — use localized strings for scenario name and objective detection (Abondance, Überfluss, etc.)

---

## [3.11.5] – 2026-03-13

### 🐛 Fixes

- **(Focus) Bonus objectives not showing when entering zone** — e.g. Saltheril's Soiree; cache invalidation and relaxed map check
- **(Core) Defensive guard for OptionsWidgetsDef in Dashboard collapsible groups** — prevents nil error when opening options

---

## [3.11.4] – 2026-03-13

### 🐛 Fixes

- **(Presence) Zone change errors: attempt to index global 'L' (a nil value)**

---

## [3.11.3] – 2026-03-13

### 🔧 Improvements

- **(Presence) Animate preview button for Presence toast notifications in options**
- **(Core) Sidebar scroll height and sub-button parenting during category collapse**
- **(Presence) Live preview of Presence toast types in options with optional detached window**
- **(Core) Dashboard chevrons and sidebar polish**
- **(Presence) QUEST_UPDATE notifications use quest category color**
- **(Insight) Character title in player tooltip name line with configurable color**
- **(Presence) Presence individual notification sizes (large, medium, small)**
- **(Focus) Prey quest detection: relax colon requirement and improve French (Traque) localization**

---

## [3.11.2] – 2026-03-13

### 🐛 Fixes

- **(Insight) Player tooltip formatting not showing on first hover**

### 🔧 Improvements

- **(Core) Update README branding and links for GitLab migration**
- **(Core) Fix beta release job when release already exists**
- **(Core) Dashboard: add sidebar navigation and layout refinements**
- **(Core) Dashboard and options panel polish**
- **(Focus) Scenario timer bar updates every 0.5s instead of 1s**
- **(Focus) Localize Prey quest detection for Midnight hunting activity**
- **(Presence) Achievement toast shows redundant 1/1 for single-objective achievements when objective is finished**
- **(Insight) Improve Insight item tooltips: fix AH flashing, quality identity, transmog filter**

---

## [3.11.1] – 2026-03-11

### 🐛 Fixes

- **(Focus) Fix grow-up mode: scroll position and arrow overlay on header**

### 🔧 Improvements

- **(Core) Localization workflow: LocaleBase as source of truth**

---

## [3.11.0] – 2026-03-10

### 🐛 Fixes

- **(Insight) Insight tooltip content sometimes spills out of container for NPCs**
- **(Focus) Scenario tracker: fix weighted progress when quantity is percentage (0-100)**

### ✨ New Features

- **(Focus) Shift-click to link quests, achievements, endeavors, recipes, and adventure guide in chat;

### 🔧 Improvements

- **(Vista) 24-hour clock toggle for Vista time display**
- **(Vista) Class colour tinting for Vista and options panel**
- **(Core) Vertical scrollbar for options panel main content**
- **(Focus) Scenario tracker improvements**

---

## [3.10.0] – 2026-03-09

### ✨ New Features

- **(Focus) Progress bar texture selection via SharedMedia** — Choose progress bar fill textures (Blizzard, Solid, or addon packs). New dropdown in Focus Display options with search.

---

## [3.9.6] – 2026-03-08

### 🔧 Improvements

- **(Core) Update README contributors and localizations list** — Add allmoon as Chinese (zhCN) contributor; add Chinese and German to localizations list.
- **(Core) LocaleBase fallback and zhCN support** — Add zhCN locale fallback and Chinese localization support.

---

## [3.9.5] – 2026-03-08

### 🐛 Fixes

- **(Focus) Focus tracker only updates after combat ends during world scenarios** — Tracker (including world scenario objectives) now updates during combat.

---

## [3.9.4] – 2026-03-08

### 🐛 Fixes

- **(Presence) Quest objective text shows wrong progress (e.g. 2 instead of 8/12)** — Single-step strip pattern no longer incorrectly matches "8/1" in "8/12"; quest update toasts now display correct progress.

---

## [3.9.3] – 2026-03-08

### 🐛 Fixes

- **(Focus) Guard layout against combat lockdown** — Tracker layout no longer errors when updated during combat.

### 🔧 Improvements

- **(Focus) Exclude world quests from Current Quest grouping** — World quests no longer appear in the Current Quest group.
- **(Focus) Classic mode: quest icon click to super-track, Shift+Left to unfocus** — Click the quest icon to super-track; Shift+Left to unfocus or untrack.
- **(Presence) Scenario notifications: omit 1/1 from single-step objectives** — Single-step objectives no longer show redundant "1/1" in scenario toasts.

---

## [3.9.2] – 2026-03-07

### 🐛 Fixes

- **(Focus) Scenario tracker: suppress progress bar for boolean objectives and fix weighted progress edge case** — Boolean (yes/no) objectives no longer show incorrect progress bars; weighted progress handles edge cases correctly.
- **(Focus) Skip progress bar for objectives with arithmetic X/Y progress** — Objectives that show X/Y counts no longer display a redundant progress bar.
- **(Focus) Inline quest item button does not fade when scrolling past tracker bottom** — Item button now fades correctly when scrolled out of view.

### 🔧 Improvements

- **(Focus) Improve Abundance scenario tracker: widget parsing, progress bar labels, and bar visibility** — Better widget parsing, clearer progress bar labels, and improved bar visibility for Abundance scenarios.
- **(Focus) Deduplicate Rare Loot entries when multiple vignettes show the same treasure** — Same treasure from multiple vignettes now appears once in the Rare Loot list.

---

## [3.9.1] – 2026-03-07

### 🔧 Improvements

- **(Focus) Allow click-to-complete for auto-complete quests when using classic click behaviour** — Classic click behaviour now supports click-to-complete for auto-complete quests.
- **(Focus) Scope Abundance scenario widget fallback and bar styling to Abundance only** — Widget fallback and progress bar styling apply only to Abundance scenarios, not other scenario types.

---

## [3.9.0] – 2026-03-07

### ✨ New Features

- **(Focus) Rare Loot section** — Show treasure and item vignettes in a separate Rare Loot list with a toggle.
- **(Focus) TomTom waypoint when clicking rares or rare loot** — Set a TomTom waypoint when clicking a rare boss or rare loot item (requires TomTom addon; setting in options).
- **(Focus) RARE color** — Warm orange for rares and rare loot, distinct from Current Quest coral.
- **(Focus) Rare sound volume** — Slider to adjust rare alert volume (50–200%).

---

## [3.8.4] – 2026-03-07

### 🐛 Fixes

- **(Focus) Rare vignettes sometimes appear duplicated in Focus tracker** — Same rare creature from multiple vignette GUIDs now appears once; deduplicated by creature ID.

### 🔧 Improvements

- **(Vista) Mail icon can be unlocked and repositioned on minimap** — Option to unlock the mail indicator so it can be dragged and repositioned like the queue, tracking, and calendar buttons.
- **(Focus) Add Inline below title option to timer display dropdown** — Third timer display option: countdown always appears on its own line below the quest title instead of beside it.
- **(Focus) Abundance scenario bar turns green when full** — Progress bar turns green when abundance held reaches the target.
- **(Focus) Shift+Left-click opens or closes quest details; closes when already showing** — Toggle behaviour for quest details; closing when already open.
- **(Focus) Inline timer wraps to own line when narrow; layout reflows during resize** — Timer text wraps when panel is narrow; layout updates live during resize drag.

---

## [3.8.3] – 2026-03-06

### 🔧 Improvements

- **(Focus) Abundance scenario display improvements and scenario debug option** — Abundance scenario objectives (e.g. 46/300) now show correctly via widget fallback when C_ScenarioInfo returns percent-only; progress bar shows X/Y abundance held/bag; duplicate X/Y stripped in tracker and Presence toasts; new scenario debug logging toggle for diagnosing display issues.

---

## [3.8.2] – 2026-03-06

### 🔧 Improvements

- **(Focus) World quests in Current Event, auto-complete display, and quest map open fix** — World quests and callings in the quest area appear in Current Event; auto-complete quests show the turn-in prompt; quest map opens more reliably.
- **(Presence) Fix stale world quest count in Presence quest update toasts** — Quest update toasts now show accurate progress counts instead of outdated values.
- **(Core) Options dashboard redesign and options panel polish** — Centered layout, smooth scroll, cascade animations, shorter descriptions with tooltips, row hover highlight.

---

## [3.8.1] – 2026-03-06

### 🔧 Improvements

- **(Focus) World quest progress bar and objectives preserved when outside quest zone** — Progress bars and objective text remain visible when briefly leaving the zone (e.g. flying, hearth).

### 🐛 Fixes

- **(Insight) Tooltip font text comparison may error; add defensive pcall** — Prevents addon errors when processing tooltip text in edge cases.

---

## [3.8.0] – 2026-03-06

### ✨ New Features

- **(Focus) Sub-setting to filter progress bar by X/Y or percent-only objectives** — Dropdown under the progress bar toggle lets you show bars for X/Y objectives (e.g. 3/10), percent-only objectives (e.g. 45%), or both.
- **(Insight) NPC tooltips: reaction-colored border, level/classification/creature type, skull icon** — NPC tooltips now show a reaction-colored border, a single line with level (or skull for unknown), classification (Elite, Rare, etc.), and creature type (Humanoid, Beast, etc.).
- **(Focus) Rare boss tracking activated in Midnight** — Rares in Midnight zones (e.g. Zul'Aman) now appear in the tracker.

---

## [3.7.1] – 2026-03-05

### 🐛 Fixes

- **(Presence) Presence quest complete detection misses some localized strings** — Added ERR_QUEST_UNKNOWN_COMPLETE, QUEST_WATCH_QUEST_COMPLETE, and QUEST_WATCH_POPUP_QUEST_COMPLETE to the suppression check so quest complete notifications are not shown when the message matches these localized strings.

### 🔧 Improvements

- **(Focus) Event category transition re-sorts before fade-out completes** — Event quests moving between Current Event and Events in Zone now fade out from their current position, other rows slide, then the row fades in at its new position; no pre-animation snap to the new category order.

---

## [3.7.0] – 2026-03-05

### ✨ New Features

- **(Focus) Current Quest category with zone routing and animations** — Section at top with coral colour; quests with progress in the last minute (configurable 30–120 sec); expired quests route to Current Zone when in zone; fade-out and fade-in when moving between categories; horizontal fade-out for consistency.

### 🐛 Fixes

- **(Presence) Quest update toast missing quest name when quest is not super-tracked** — Non-super-tracked quests now show quest name and objective in the update toast.
- **(Focus) Skip percent calculation for single-objective quests in progress display** — Single-objective quests use discrete count instead of percent bar.

### 🔧 Improvements

- **(Focus) Use IsOnQuest for quest acceptance and preserve super-track when placing waypoints** — Authoritative quest acceptance check; waypoints no longer override quest super-track.
- **(Core) Options panel: default collapsed for advanced sections, header labels, persist sidebar group collapse** — Advanced sections collapsed by default; header labels; sidebar group collapse persisted.

---

## [3.6.7] – 2026-03-04

### 🐛 Fixes

- **(Focus) Objective progress bars fail to show when percent comes from text or type is progressbar** — Progress bars now appear for objectives that report percent via text or Blizzard progressbar type; single-objective (1/1) uses discrete count instead of bar.
- **(Presence) Quest acceptance detection fails in non-English locales** — Locale-safe keyword matching from Blizzard globals and addon translations; completion message matching strips trailing punctuation for locale variants.

### 🔧 Improvements

- **(Core) Reorganize Focus options into clearer categories** — Appearance, Sorting & Filtering, Animations, and Instances sections; renamed labels for clarity (e.g. Enemy forces size, Active instance only).

---

## [3.6.6] – 2026-03-04

### 🐛 Fixes

- **(Presence) Fix Presence debug function nil errors** — Quest update notifications and live debug no longer crash from undefined debug functions.

---

## [3.6.5] – 2026-03-04

### 🐛 Fixes

- **(Presence) Presence quest update notifications show duplicates or wrong text** — One notification per objective completion with correct text; no more duplicate popups or generic Blizzard messages.

### 🔧 Improvements

- **(Presence) Remove Presence debug logging** — Temporary debug output removed.
- **(Core) Options panel: refresh dependent widgets when parent toggle changes** — Dependent dropdowns and sliders update immediately when toggling options like Scroll indicator, Dim unfocused entries, or Rare sound alert.

---

## [3.6.4] – 2026-03-04

### 🔧 Improvements

- **(Focus, Presence) Fix scenario percentage display and delve completion notification subtitle** — Scenario criteria now show correct percentage values; delve completion toasts display the actual delve name instead of a generic fallback.

---

## [3.6.3] – 2026-03-03

### 🔧 Improvements

- **(Core) Options panel: class color accent and Delves and Dungeons section rename** — Tint the options panel accent with your class color; renamed Delves section to Delves and Dungeons with updated descriptions.
- **(Focus) Focus Delve tier sometimes wrong or missing in tracker** — Uses ScenarioHeaderDelvesWidget tierText for accurate tier display in delves.
- **(Focus) Focus tracker: improved collapse/expand behavior with grow-up header animations** — Clearer animated feedback when expanding/collapsing categories in grow-up layout.

---

## [3.6.2] – 2026-03-03

### 🔧 Improvements

- **(Focus) Right-click recipe to untrack and improved reagent display** — Crafting recipes can be untracked via right-click; reagent display improved.
- **(Focus) Show tracker in dungeons by default instead of hidden** — Tracker is visible in dungeons by default for easier objective tracking.

### 🐛 Fixes

- **(Focus) Apply combat fade alpha when tracker is shown in combat** — Tracker now respects combat fade when shown during combat.

---

## [3.6.0] – 2026-03-02

### ✨ New Features

- **(Focus) Sort ready-to-turn-in quests to bottom of Current Zone** — Completed quests in the Current Zone (Nearby) section sort to the bottom, keeping in-progress objectives visible at the top.
- **(Presence) Scenario and delve completion notification** — Cinematic toasts when completing a scenario or delve; delves show "Delve Complete" with name or tier, scenarios show "Scenario Complete".

### 🔧 Improvements

- **(Core) German (deDE) localization for options panel** — Options panel now fully translated into German.

### 🐛 Fixes

- **(Focus) World quest objectives show progress bars when the option is enabled** — World quest objectives now display progress bars like regular quests when the progress bar option is turned on.

---

## [3.5.0] – 2026-02-28

### ✨ New Features

- **(Presence) Achievement progress toast notifications** — Cinematic toasts when you make progress on tracked achievements (e.g. 50/300, 100/500), not only on completion.

### 🔧 Improvements

- **(Focus) Accurate delve tier display** — The tracker uses the correct API so the displayed tier matches what Blizzard considers active when in a delve.
- **(Focus) Instance name in dungeon scenario header** — Dungeon scenarios show the instance name (e.g. Blackrock Caverns) instead of blank or generic text.
- **(Focus) Restrict world quest fallback to bonus objectives only** — Zone events (bonus objectives) from the map appear in the tracker; unrelated task quests are excluded.
- **(Presence) Cleaner objective progress toasts** — Avoids duplicate numeric values when both quantity and text already contain the same info.

---

## [3.4.0] – 2026-02-28

### ✨ New Features

- **(Vista) All The Things minimap button can be tracked** — Add the All The Things minimap button to Vista's button bar.
- **(Focus) TomTom integration** — Click a quest in Focus to set TomTom's arrow to the next objective with distance display.
- **(Insight) Mount and All The Things info in character tooltips** — Character tooltips show the player's current mount and ATT collection data.

### 🔧 Improvements

- **(Presence) Option to hide "Quest Update" title on Presence toasts** — Show only the objective line without the redundant header.

### 🐛 Fixes

- **(Focus) Progress bar hides when objective is complete** — Bar no longer stays visible at full fill after completion.
- **(Presence) Event quest completion no longer shows 0/10 toast** — Completion state shown instead of a progress update.
- **(Focus) Quel'danas bonus objectives in Midnight intro now show in quest tracker** — Bonus objectives appear correctly during the phased intro.
- **(Focus) Quest tooltip no longer duplicates when in a party with All The Things** — Hover info shows once when in a party.
- **(Core) Settings search description displays fully on first open** — Clicking a search result no longer cuts off the description until you scroll.

---

## [3.3.1] – 2026-02-28

### 🔧 Improvements

- **(Core) Add Spanish (esES) locale for options panel** — Options panel now fully translated into Spanish; checkmark-for-completed option uses a texture icon for reliable display across locales and fonts.
- **(Insight) Strip health/power text and redundant Hero Talent line from unit tooltips** — Tooltip clutter reduced; Insight shows reaction and class info without duplicating stats; redundant Hero Talent line removed.

### 🐛 Fixes

- **(Focus) Quests in Ready to turn in section cannot be left-clicked to focus** — Left-click on turn-in quests now sets focus correctly so you get a waypoint to the turn-in NPC.

---

## [3.3.0] – 2026-02-27

### ✨ New Features

- **(Core) Unified slash command system with /h as primary shortcut** — Use /h, /hopt, and /hedit for help, options, and edit screen; module subcommands under /h focus, /h presence, and similar.
- **Beta can install alongside release** — Install both stable and beta versions simultaneously for testing without overwriting each other.

### 🔧 Improvements

- **(Focus) Events in Zone section label and event quest colour continuity** — Section renamed from "Available in Zone"; event quests keep their distinct colour when accepted and move to Current Zone.
- **(Core) Beta uses separate SavedVariable** — Profiles and settings stay separate between beta and release when running both.
- **(Insight) Suppress tooltip fade-in when refreshing unit tooltips** — Prevents animation flicker when the tooltip updates.

---

## [3.2.0] – 2026-02-27

### ✨ New Features

- **(Focus) Inline timer display mode and urgency-based timer coloring** — Show countdown timers beside quest titles or as bars; optionally color by remaining time (green, yellow, red).
- **(Focus) Alpha slider for progress bar and Mythic+ bar colors** — Make progress bars and M+ bars semi-transparent.
- **(Focus) Option to hide Focus tracker only in Mythic+** — Hide the tracker during Mythic+ runs while keeping it visible in normal, heroic, or mythic dungeons.
- **(Focus) Per-difficulty instance visibility** — Choose which dungeon and raid difficulties show the Focus tracker (normal, heroic, mythic, Mythic+ separately).
- **(Focus) Section dividers between categories** — Optional dividers with configurable color between tracker sections.
- **(Presence) Zone title color by zone type** — Zone text changes color by affiliation: green friendly, red enemy, yellow neutral, light blue sanctuary; toggle to enable.
- **(Presence) Option to disable Presence in battlegrounds** — Turn off zone and notification toasts during PvP matches.
- **(Core) Improve Brazilian Portuguese localization and enUS base template** — Additional ptBR translations; enUS template for creating new locale files.

### 🔧 Improvements

- **(Focus) Compact timer format for quests and scenarios** — Human-readable format (e.g. 2d 5h 30m, 45m 12s) instead of raw MM:SS.
- **(Focus) Backdrop opacity and shadow alpha sliders use 0–100%** — Finer control with integer steps while storing values internally.
- **(Focus) Untrack quest by re-clicking** — Defocus by clicking the same quest again.
- **(Focus) Options to desaturate or adjust alpha for dimmed non-focused quests** — Additional dimming controls beyond color.
- **(Focus) Completed nearby quests respect "Show nearby quests in their own group"** — Setting now applies consistently.
- **(Vista) Restore flash when unlocking mouseover bar** — Brief flash helps find the bar when repositioning.
- **(Insight) Tooltip polish** — Class-coloured separator lines, number formatting with commas, cursor tooltip clamping.
- **(Core) Options panel reorganization and Focus combat refresh** — Refined categories; tracker refreshes achievements, endeavors, decor, rares in combat.
- **(Core) Align core defaults and beta changelog sourcing** — Consistent out-of-box experience; beta workflow uses closed-issue filtering.

### 🐛 Fixes

- **(Focus) Typography shadow applies to section headers and quest titles** — Shadow on/off and X/Y offsets now affect all tracker text.
- **(Focus) Shadow offsets work with section headers and quest titles** — Typography shadow options apply correctly.
- **(Focus) Active Quest Highlight alpha, alignment, and outline** — Alpha slider has fine control; Highlight, Soft Glow, and Outline align with text.
- **(Focus) Section header text no longer clips at large font sizes** — Headers display fully when section font size is 16 or 18.
- **(Focus) LFG queue green eye shows and hides reliably** — Queue indicator visibility correct after moving tracker.
- **(Focus) Quest list height persists** — Vertical size setting no longer resets to default.
- **(Presence) Quest update text spacing** — Spacing matches other objective lines.
- **Missing scenario event timers** — World Soul Memory, Nightfall, Theater Troupe, Midnight Pre-Patch Rares now appear in tracker.

---

## [3.1.5] – 2026-02-25

### 🔧 Improvements

- **(Presence) Higher-priority notifications can interrupt current** — Level-up and achievements can preempt zone changes or quest accepts so important moments are never delayed by less important toasts.
- **(Core) Profile export strips machine-specific Vista button keys** — Exported profiles can be shared or imported without carrying per-machine minimap button state.
- **(Presence) Replace-in-queue for rapid same-type notifications** — Multiple quest or scenario updates replace the pending entry instead of stacking.
- **(Presence) Live update for quest and scenario progress** — Rapid objective updates appear as subtitle changes on the current toast instead of stacking in the queue.

### 🐛 Fixes

- **(Focus) Text case "Proper" with special characters** — Umlauts and European accented characters (ä, ö, ü, etc.) no longer incorrectly capitalize the following letter in German and other languages.

---

## [3.1.4] – 2026-02-25

### 🔧 Improvements

- **(Vista)** Removed duplicate variable declaration.

### 🐛 Fixes

- **(Vista)** Drawer button now opens panel when clicked in floating drawer mode.

---

## [3.1.3] – 2026-02-25

### 🔧 Improvements

- **(Vista) Configurable close delays** — Set how long the mouseover bar, right-click panel, and floating drawer stay open after the cursor leaves (0 = instant or never auto-close).
- **(Vista) Configurable background and border for mouseover button bar** — Customize color and optional border for the addon button bar.
- **(Vista) Reposition addon button bar discoverability** — Tooltip and option description explain how to drag the bar to reposition when unlocked.

---

## [3.1.2] – 2026-02-24

### 🔧 Improvements

- **(Vista)** Allow minimap pin tooltips to show when hovering over pins.

---

## [3.1.1] – 2026-02-24

### 🔧 Improvements

- **(Presence) Presence frame scale up to 2x** — Users can make notifications larger on high-DPI displays.
- **(Focus) Tracker max height fix for grow-up mode** — Correct max height when the tracker grows upward from the bottom.

### 🐛 Fixes

- **(Vista)** Minimap can be dragged when unlocked, even with right-click panel mode overlay enabled.

---

## [3.1.0] – 2026-02-24

### ✨ New Features

- **(Vista) Option for buttons per row/column and expand direction** — Choose how many addon buttons per row before wrapping and which direction they fill (right, left, down, up).
- **(Vista) Option to disable queue button handling** — Turn off Vista's queue status button anchoring when another addon manages it or you prefer Blizzard's placement.
- **(Vista) Draggable right-click panel with lock option** — Drag the addon button panel to reposition; lock toggle prevents accidental movement.
- **(Vista) Draggable difficulty text with lock option** — Drag Mythic/Heroic/Normal text to reposition; lock toggle in options.
- **(Vista) Option to set coordinate precision (0, 1, or 2 decimal places)** — Choose how many decimal places for X and Y coordinates.
- **(Focus) Option to use left-click for quest map and right-click for share/abandon on tracker quests** — Restore classic click behavior via a toggle.
- **(Vista) Color difficulty text by difficulty with customizable colors** — Per-difficulty color pickers (e.g. Mythic purple, Heroic red).
- **(Vista) Option to select zone display: general zone, subzone, or both** — Show zone only, subzone only, or both (e.g. Stormwind with Trade District below).
- **(Vista) Option to select which addon buttons are managed vs always visible** — Mark buttons as always visible (e.g. Plumber expansion summary) or managed in the mouseover bar.
- **(Vista) Separate addon button mouseover bar from zone text position** — Position zone text and addon buttons independently (e.g. zone at top, buttons at bottom).
- **(Vista) Option to change the size of the difficulty text** — Scale or resize Mythic/Heroic/Normal text.

### 🔧 Improvements

- **(Vista) Correct zone/subzone display for interior zones** — Zone text shows the correct location in interior zones (e.g. inside buildings).
- **(Vista) Suppress minimap ping when right-clicking to open addon panel** — Right-click opens the panel without pinging the minimap.
- **(Focus) Option to change header divider color** — Customize the Focus tracker header divider color.

### 🐛 Fixes

- **(Vista) Minimap addon button gold borders misaligned after changing button size** — Gold borders stay aligned with buttons at any configured size.
- **(Vista) Border thickness slider drops FPS from 74 to 10 when dragging** — Slider no longer causes severe FPS drops.
- **(Core) Options pane scrolls infinitely and does not stop at end of list** — Scroll stops at the end of the options list.
- **(Focus) Queue status tracker appears only in dungeon and persists after leaving** — Queue/LFG status shows when queued and hides when no longer relevant.
- **(Vista) Option to use local time in Vista clock** — Clock can display local time instead of server time.
- **(Focus) Right-click to abandon quest only untracks when World Quest Tracker (WQT) is enabled** — Abandon behavior works correctly with WQT enabled.

---

## [3.0.2] – 2026-02-24

### 🔧 Improvements

- **(Vista) Zone, coordinates, and clock above or below minimap** — Choose to place zone name, coordinates, and clock above or below the minimap in Vista options.
- **(Focus) Scenario bars match progress bar styling** — Timer and progress bars in scenarios now use the same font, colors, and height as quest objective progress bars.
- **(Presence) More reliable notification display** — Level-up, boss emotes, and scenario toasts display correctly when event frames load.

---

## [3.0.1] – 2026-02-23

### 🐛 Fixes

- **Dev addon fix.**

---

## [3.0.0] – 2026-02-23

### ✨ New Features

- **(Vista) Minimap sizing and free positioning.**
- **(Vista) Minimap border thickness and visibility control.**
- **(Vista) Replace MinimapButtonButton/Hiding bar with built-in opt-out list of addon buttons to show.**
- **(Vista) Zone text control: position, background color and visibility, font size, font.**
- **(Vista) Coordinates text: position and styling; optional format (decimal precision, X/Y prefixes).**
- **(Vista) Time/clock text: same controls as coords; optional format options.**
- **(Vista) Default map button visibility, position, size, and custom icons.**
- **(Presence) Per-type toggles for Presence notifications.**
- **(Core) Options panel localization for Russian (ruRU)** — Options panel is now fully translated into Russian.

---

## [2.6.1] – 2026-02-23

---

## [2.6.0] – 2026-02-23

### ✨ New Features

- **(Presence) Option to show only subzone when staying in same major zone** — Zone notifications display the local area name instead of the full zone when moving between subzones within the same zone.
- **(Vista) Square minimap option** — Choose a square minimap shape in Vista options.

### 🔧 Improvements

- **(Focus) Improve tracker performance and responsiveness.**
- **(Core) Option to scale Horizon Suite when WoW UI scale is lowered** — Scale addon elements independently so they remain readable at different game UI scale settings.

### 🐛 Fixes

- **(Focus)** Quest tracker no longer triggers errors when quest rows fade out during combat.

---

## [2.5.0] – 2026-02-22

### ✨ New Features

- **(Focus) Scroll indicators when quest list is truncated** — Arrows or fade at top and bottom show when more content is available above or below.
- **(Focus) Dungeon journal objectives in tracker** — Objectives tracked via the dungeon journal (checkmarked in the journal UI) now appear in the Focus tracker.
- **(Focus) Achievement progress tracking** — Tracked achievements with numeric goals (e.g. harvest 250 lumber) now show live progress (e.g. 1/250, 200/250) in the tracker.
- **(Presence) Setting to disable quest update notifications** — Option to turn off quest objective progress toasts (e.g. "Boar Pelts: 7/10") so they no longer distract during dungeons.
- **(Focus) Option to always show Campaign and Important quests in their own categories** — Keep purple triangle quests in dedicated sections even after completion instead of moving to Current Zone or Ready to Turn In.
- **(Focus) Font selector options for header, sections, and quest titles** — Customize typography for each element in the Typography section.
- **(Focus) Preview mode for the M+ block** — Configure and position the Mythic+ block without being inside an active key.
- **(Focus) Find group button for group quests** — Quick access to Group Finder for group quests in the tracker.
- **(Focus) Option to show quest objective progress as a bar** — Display progress (e.g. 3/10, 45%) as a visual bar instead of raw numbers.

### 🔧 Improvements

- **(Focus) Objective progress bar toggle animates like other options** — Panel refresh is deferred so the toggle animates consistently with other toggles.
- **(Core) Localization for typography font options in French, Korean, and Portuguese (Brazil)** — Title font, zone font, objective font, and section font labels are now localized.
- **(Focus) Tracker mouseover detection and options panel UI** — Reliable hover detection over child frames; title bar drag only from the bar; section cards reset on open; improved toggle and dropdown styling.
- **(Focus) Restructured options into clearer categories** — Panel, Display, Typography, Behaviour, Mythic+, Delves, and Content Types as dedicated sections.
- **(Focus) Separate fonts for quest title, quest text, and zone text** — Choose different fonts for each element in the Typography section.

### 🐛 Fixes

- **(Focus)** Floating quest item button and per-entry quest item buttons now appear when quests have usable items.
- **(Focus)** Dungeon eye icon now shows for world boss group finder entries.
- **(Focus)** Disable world quests option now works correctly when World Quest Tracker is enabled.
- **(Focus)** Achievements with many objectives no longer get cut off in the tracker.
- **(Focus)** Category prefix now renders as a dash instead of a square across fonts.
- **(Focus)** Quest items with cooldowns now update correctly when used in combat.

---

## [2.4.0] – 2026-02-21

### 🔧 Improvements

- **(Presence)** Suppress zone changes in Mythic+ and combat lockdown guards — New option under Presence → Notification types. When enabled, zone, quest, and scenario notifications are hidden during M+ runs. Frame Hide/Show and drag handlers are guarded during combat across Focus, Cache, and Options.

### 🐛 Fixes

- **(Focus)** Tracker collapse/expand no longer causes errors during combat.
- **(Presence)** Zone name and completion percentage no longer spam during Mythic+ runs.

---

## [2.3.0] – 2026-02-21

### ✨ New Features

- **(Focus) Raid quest category in tracker** — Raid quests now appear in their own red section in the Focus tracker, distinct from dungeon quests.
- **(Focus) Full profile support with import/export, per-spec and global account modes** — Create, switch, copy, and delete named profiles. Use per-character, per-specialization, or global (account-wide) modes. Import and export profiles as shareable text strings in the Profiles options section.

### 🔧 Improvements

- **(Focus) Auto-track icon choice for in-zone entries** — Choose which radar icon to display next to auto-tracked world quests and weeklies/dailies that are not yet in your quest log (in-zone only).
- **(Core) Panel backdrop colour and opacity** — Customize the tracker panel background colour and opacity in the Visuals options.

### 🐛 Fixes

- **(Core)** Debug command no longer errors when counting quests by log index.

---

## [2.2.0] – 2026-02-21

### ✨ New Features

- **(Focus) Option to fade objectives during combat instead of fully hiding them** — Objectives remain visible but partially transparent in combat; opacity returns to normal out of combat.

### 🔧 Improvements

- **(Core) Changelog sections use emoji icons for quicker scanning** — Section headers now have emoji prefixes for visual distinction.
- **(Core) Update credits section with French localization contributor and development attribution** — Credits now list Aishuu for French localization and development attribution for feanor21.
- **(Core) Add Presence notification strings to French and Korean localization** — Level-up, achievement, quest complete, and other Presence notification text is now localized for French and Korean.
- **(Core) Improve French localization clarity and consistency in options panel** — French labels and tooltips are clearer and align better with game terminology.

### 🐛 Fixes

- **(Core)** Beta release workflow no longer crashes when creating the beta tag.
- **(Core)** SharedMedia_Noto fonts now appear in the font dropdown alongside other SharedMedia fonts.

---

## [2.1.0] – 2026-02-21

### ✨ New Features

- **(Core) Search bar in font dropdown** — Filter fonts by typing in the Typography section when many fonts are available.
- **(Focus) Tracker fades by default and appears on mouseover** — Tracker is hidden by default and shows when you hover over it.

### 🔧 Improvements

- **(Core) French localization for options panel** — Options panel displays all labels, descriptions, and section headers in French when the player's client is set to French.
---

## [2.0.4] – 2026-02-21

### 🐛 Fixes

- **(Focus)** Font selection in Typography section now updates the displayed font immediately.
---

## [2.0.3] – 2026-02-21

### 🐛 Fixes

- **(Focus)** M+ block no longer triggers protected frame errors during Mythic+ runs.
---

## [2.0.2] – 2026-02-21

### ✨ New Features

- **(Cache) Cinematic loot notifications module** — Items, money, currency, and reputation gains appear as styled toasts with quality-based colours and smooth animations. Epic and legendary loot get extra flair. Enable in options; use `/horizon cache` for test commands.

### 🐛 Fixes

- **(Core)** Font selection now persists after reload, log out, or game exit.
---

## [2.0.1] – 2026-02-20

### 🔧 Improvements

- **(Presence) Presence module enabled by default for new installs** — New users get the full Horizon Suite experience (cinematic zone text, quest notifications, achievements, etc.) immediately after install. Users migrating from the legacy Vista module have their previous enabled/disabled preference preserved.
---

## [2.0.0] – 2026-02-20

### ✨ New Features

- **(Presence) Configurable colors, animations, and subtitle transitions for Presence notifications** — Tailor the look and feel of Presence toasts to match your UI theme. Per-type colors for boss emotes, discovery lines, and other categories; configurable animations; smooth subtitle fade when multi-line notifications update.
- **(Focus) Show achievement progress for numeric objectives in tracker** — Tracked achievements with numeric goals (e.g., collect 300 decors) now display current progress (e.g. 247/300) in the tracker at a glance.
---

## [1.2.4] – 2026-02-20

### ✨ New Features

- **(Presence) Delve and scenario objective progress toasts** — Objective updates in Delves, party dungeons, and other scenarios now show Presence toasts (e.g. "Slay enemies 5/10").
- **(Focus) Separate Hide in dungeons from M+ timer** — You can now hide the tracker in dungeons independently of the Mythic+ timer block.
- **(Focus) Show unaccepted quests in the current zone** — Quests available to accept in your current zone appear in the tracker.
- **(Focus) Scenario start notification** — Entering a Delve, scenario, or dungeon triggers a Presence notification.
- **(Focus) Deaths in M+ block** — The Mythic+ module now displays death count.
- **(Focus) Separate font, size, and color for M+ module** — Typography for the M+ block can be customized separately from the main tracker.

### 🔧 Improvements

- **(Core) Add missing non-options strings to koKR locale** — Strings in modules (Focus, Presence) are now in koKR so Korean users can fork and translate.
---

## [1.2.3] – 2026-02-20

### 🐛 Fixes

- **(Core)** En Dash character now renders correctly in the Korean WoW client for collapsible color groups in options.
---

## [1.2.2] – 2026-02-20

### ✨ New Features

- **(Focus) Show season affix names in Delves on quest list entries** — Delve entries now display season affixes and tier (e.g. Tier 5) in the tracker, with an option to toggle and tooltips for tier and affix details.
---

## [1.2.1] – 2026-02-20

### 🔧 Improvements

- **(Focus) M+ timer verification, debug cleanup, and localization** — Follow-up polish from recent Mythic+ and world quest improvements.
---

## [1.2.0] – 2026-02-19

### ✨ New Features

- **(Focus) Per-objective progress (e.g. 15/18) on individual objectives** — Objectives with multiple instances (e.g. "Pressure Valve fixed", "Cache and Release" valves) now display numeric progress when the game provides it, so you can see partial completion at a glance.
- **(Focus) Configurable fading animations and smoother transitions** — Adjust flash intensity (subtle, medium, strong) and optionally customize the flash color when objectives update; collapse/expand transitions are smoother.
- **(Focus) Option to show tick instead of green color for completed objectives** — Toggle to display a checkmark instead of color for completed objectives, for easier scanning or different color schemes.
- **(Focus) Setting to hide or show the options button.**
- **(Core) Add Korean language support.**

### 🔧 Improvements

- **(Focus) Hovering quest objectives now shows party member progress** — Parity with default UI tooltip.
- **(Focus) Option for a current-zone quest item button that can be keybound** — ExtraQuestButton-style: use without clicking.

### 🐛 Fixes

- **(Focus) Focus Tracker — ADDON_ACTION_BLOCKED** — Fixed error when changing options during combat; dimension changes are now deferred until after combat.
- **(Focus) Scenario and Delve objectives now show per-objective progress (e.g. 0/5 Workers rescued)** — Objectives from Delves, scenarios, and dungeons now display the correct count.
- **(Focus) Options to set header color and header height.**
---

## [1.1.5] – 2026-02-19

### ✨ New Features

- **(Focus) Option to fade or hide completed quest objectives** — Completed objectives (e.g. 1/1) can be faded or hidden so remaining tasks are visible at a glance.

### 🐛 Fixes

- **(Core)** Beta Release Action now runs correctly; release zipping and workflow updated.
- **(Focus)** Click to complete quest in old content (no turn-in NPC) now works; users no longer need to disable the addon to complete those quests.
---

## [1.1.4] – 2026-02-16

### ✨ New Features

- **(Focus) Quest text adapts to tracker height** — Full text shows or hides based on available space when the tracker is short.
- **(Vista)** Game reports addon action no longer blocked when opening the World Map.
- **Setting to hide or show the drag-to-resize handle** — Option for the bottom-right corner of the quest list.

### 🐛 Fixes

- **(Focus)** Quest titles with apostrophes no longer show wrong capitalization (e.g. "Traitor'S Rest").
- **(Core)** Version number in settings window now matches the addon version.
- **(Presence)** Quest update bugs fixed: race conditions causing 0/X display, intermediate progress numbers, and suppressed completion toasts.
- **(Focus)** World quest zone labels corrected; in-zone redundancy and off-map missing labels fixed.
- **(Core)** Font dropdown is now scrollable so fonts below the fold can be selected.
- **(Focus)** SharedMedia compatibility added so addons and custom fonts can be used across the suite.
---

## [1.1.3] – 2026-02-15

### ✨ New Features

- **(Focus) In-zone world quests, weeklies and dailies** — Shown when in zone; right-click untracks and hides until zone change (not subzone). Option in Display → List to show a suffix for in-zone but not yet in log.

### 🔧 Improvements

- **(Focus) Tracked WQs and in-log weeklies/dailies** — Now sort to the top of their section.
- **(Focus) Promotion animation** — Only the promoted quest fades out then fades in at the top; fixed blank space until next event.
- **(Focus) Right-click on world quests** — Untracks only (no abandon popup); Ctrl+right-click still abandons.

### 🐛 Fixes

- **(Focus) Category reordering** — Drop target now matches cursor; auto-scroll direction when dragging near top or bottom corrected.
---

## [1.1.2] – 2026-02-15

### 🐛 Fixes

- **(Focus)** Game sounds no longer muted or clipped when endeavor cache primes at login.
---

## [1.1.1] – 2026-02-14

### ✨ New Features

- **(Focus) Auto-track accepted quests** — Accepted quests are now automatically added to the Focus tracker. You can enable or disable this in Organization -> Behaviour.

### 🔧 Improvements

- **(Focus) Endeavor tooltip rewards** — Endeavor hover tooltips now use the panel-style layout and include House XP with the chevron icon in the rewards section.

### 🐛 Fixes

- **UI taint errors** — Fixed taint errors that could appear when opening Blizzard panels such as Character Frame and Game Menu.
- **(Focus) Shift+Right-click abandon** — Confirm abandon now works correctly when using Shift+Right-click on quests.
---

## [1.1.0] – 2026-02-14

### ✨ New Features

- **(Focus) Decor tracking** — Track Decor items in the Focus list. Shows item names; left-click opens the catalog; Shift+Left-click opens the map to the drop location.
- **(Focus) Endeavor tracking** — Track Endeavors in the Focus list. Names load on reload without opening the panel; left-click opens the housing dashboard.
- **(Focus) Achievement requirements display** — Option to only show missing requirements for tracked achievements; completed criteria are shown in green.

### 🔧 Improvements

- **(Focus) Spacing slider** — Slider in Display → Spacing to adjust the gap below the objectives bar (0–24 px), preventing the first line from being cut off.
- **(Focus) Dim non-focused quests** — Display option to dim full quest details and section headers for non-focused quests.

### 🐛 Fixes

- **(Focus)** World quests no longer remain in the tracker after changing zones (e.g. hearthing to another zone).
- **(Focus)** Confirm abandon quest now works when using Shift+Right-click.
---

## [1.0.6] – 2026-02-14

### 🐛 Fixes

- **(Focus)** Quest text (objectives, timers) now updates during combat — Content-only refresh runs when ScheduleRefresh is requested in combat.
- **(Presence)** Quest progress and kills in combat now show Presence toasts — Removed combat lock in QueueOrPlay so progress and kills (e.g. Argent Tournament jousting) appear.
---

## [1.0.5] – 2026-02-14

### ✨ New Features

- **(Focus) Super-compact mode — options and collapse** — Super-minimal mode now has a thin bar with expand/collapse and a compact "O" options button. Objectives can be opened when "Start collapsed" is set.
---

## [1.0.4] – 2026-02-14

### 🔧 Improvements

- **Focus — Quest-area world quests when option is off** — When "Show in-zone world quests" is disabled, the tracker still shows WQs when you physically enter their quest area (distance-based proximity using C_TaskQuest.GetQuestLocation, matching default Blizzard behavior). Zone-wide WQs remain hidden.
- **Presence — Colours and quest-type icon aligned with Focus** — Presence notifications now use the same colour palette and options as Focus. Quest Complete and Quest Accept colours are driven by quest type (campaign, world, default, etc.); Achievement uses Focus bronze; World Quest uses Focus purple; Quest Update uses Nearby blue; zone/subzone use default title and campaign gold subtitle. Boss emote uses a dedicated red in Config. When "Show quest type icons" is enabled in options, quest-related Presence toasts (accept, complete, world quest) show the same quest-type icon as the Focus tracker.

### 🐛 Fixes

- **Focus Tracker — ADDON_ACTION_BLOCKED** — Fixed error when `HSFrame:Hide()` was called during combat. Protected Hide() calls are now guarded by InCombatLockdown() and deferred until PLAYER_REGEN_ENABLED.
---

## [1.0.3] – 2026-02-13

### ✨ New Features

- **Quest header count** — Option to show quest count as tracked/in-log (e.g. 4/19, default) or in-log/max-slots (e.g. 19/35). Uses `isHidden` for an accurate in-log count.

### 🔧 Improvements

- **Focus — Granular spacing options** — Vertical gaps are now user-configurable via sliders in Display → Spacing: between quest entries (2–20 px), before and after category headers (0–24 px, 0–16 px), and between objectives (0–8 px). Compact mode applies a preset (4 px entries, 1 px objectives).
- **Presence — World Quest Accept** — World quest accepts now use a dedicated purple-style notification type (`WORLD_QUEST_ACCEPT`) instead of sharing the standard quest accept style.
---

## [1.0.2] – 2026-02-13

### ✨ New Features

- **Track specific world quests when WQs are off** — Watch-list and super-tracked world quests now appear in the tracker even when the general world quests option is disabled. You can turn off auto-added zone WQs while still seeing the ones you explicitly track.

### 🔧 Improvements

- **Mythic+ design** — Improved M+ block layout and styling in the Focus tracker.

### 🐛 Fixes

- **Focus Tracker — per-category collapse** — Section header collapse (clicking category headers like Campaign, World Quests) no longer delays or flickers. The collapse animation starts immediately and section headers stay visible during the animation.
- **Focus Tracker — main collapse** — Main tracker collapse behaviour refined: ensures the update loop runs when toggling collapse, and section headers display correctly when a single category is collapsed.
---

## [1.0.1] – 2026-02-13

### 🐛 Fixes

- **Focus Tracker — completed achievements** — The tracker no longer clutters the list with achievements you’ve already finished. Completed achievements are hidden by default; you can turn on “Show completed achievements” in options if you want to see them.
- **Focus Tracker — collapse** — Collapsing the tracker now behaves correctly: the collapse animation starts right away, section headers stay visible while it animates, and a single category still shows its header when collapsed.
---

## [1.0.0] – 2026-02-13

### ✨ New Features

- **Modular architecture** — Horizon Suite is now a core addon with pluggable modules. The Focus (objective tracker) is the first module. A new **Modules** category in options lets you enable or disable each suite. Use `/horizon toggle` or Options → Modules → Enable Focus module to turn the tracker on or off. Additional suites will appear as modules in the same options panel. SavedVariables remain compatible; existing installs default to Focus enabled.
- **Presence module** — Cinematic zone text and notifications. Replaces default zone/subzone text, level-up, boss emotes, achievements, quest accept/complete/update, and world quest banners with styled notifications. Priority queueing, smooth entrance/exit animations, and "Discovered" lines for zone discoveries. Enable in Options → Modules → Enable Presence module. Test with `/horizon presence` (e.g. `/horizon presence zone`, `/horizon presence all`). Blizzard frames are fully restored when Presence is disabled. (Renamed from Vista; `/horizon vista` is now `/horizon presence`.)

### 🔧 Improvements

- **Performance optimizations** — Reduced CPU usage by replacing per-frame OnUpdate with event-driven logic and timers: scenario heartbeat and map check now use C_Timer tickers; main tracker OnUpdate runs only when animating or lerping; Presence OnUpdate runs only during cinematics; scenario timer bars use a shared 1s tick instead of per-bar updates; options toggle OnUpdate runs only during its short animation.
- **Options panel UX overhaul** — Cinematic, modern, minimalistic redesign: softer colour palette with low-contrast borders and dividers; pill-shaped search input; taller sidebar tabs with hover states; minimal X close button; section cards with inset backgrounds; refined toggles, sliders, dropdowns, and colour swatches; subtle dividers between colour-matrix sections; consistent hover feedback on buttons and tabs.
- **Search bar redesign** — Custom-styled search input without Blizzard template: search icon (spyglass) on the left, integrated clear button (visible only when typing), subtle focus state with accent-colour border, and tighter visual connection to the results dropdown.
---

## [0.7.1] – 2026-02-13

### 🔧 Improvements

- **Zone labels** — Refined how quest zone names are chosen so objectives show clearer, more accurate zone labels, especially when quests span parent/child maps.
- **Mythic+ integration** — Improved how Mythic+ objectives and blocks behave in the tracker and options, with clearer descriptions and more consistent behaviour.
- **Options usability** — Polished several option labels and descriptions (including Mythic+ and zone-related settings) to better explain what they do and how they interact.
- **Options panel overhaul** — Fixed search so clicking a result now switches to the correct category and scrolls to that setting. Settings are reorganized into eight categories (Layout, Visibility, Display, Features, Typography, Appearance, Colors, Organization) for easier discovery. Toggles use a rounded pill style; search results show category and section with the option name emphasised.
- **World quest map fallback removed** — World quests are now sourced only from live APIs (`GetTasksTable`, `C_QuestLog.GetQuestsOnMap`, `C_TaskQuest` map APIs, and waypoint fallback) without requiring the world map to be open. The previous map-open cache and heartbeat fallback have been removed.
---

## [0.7.0] – 2026-02-13

### 🔧 Improvements

- **Version 0.7.0** — Release bump.
---

## [0.6.9] – 2026-02-13

### ✨ New Features

- **Nearby group toggle** — Toggle to show or hide the nearby group section, with key binding support. Key bindings can be set in the game’s Key Bindings → AddOns → Horizon Suite. Animation and behaviour for the nearby group section have been enhanced.
- **Dungeon support** — Quest tracking now supports Dungeon quests so dungeon objectives appear correctly in the tracker.
- **Delve support** — Delve quests are supported with updated event handling so Delve objectives are tracked and displayed.

### 🔧 Improvements

- **Floating quest item button** — Styling, text case options, and UI layout improved. Button behaviour and layout (e.g. icon, label, progress) are more consistent and configurable.
- **Quest caching** — Quest ID retrieval and caching logic refactored for better reliability. Event handling and debugging around quest updates have been improved.
- **README** — Documentation revised for clarity and formatting.
---

## [0.6.6] – 2026-02-11

### ✨ New Features

- **Weekly quests** — New category for weekly (recurring) quests with its own section in the tracker. Weekly quests in your current zone are auto-added like world quests. Quest classification now uses a single source of truth for determining world quests.
- **Daily quests** — Daily quests are supported with their own section and labeling. Daily quests in your current zone are auto-added to the tracker. Quests that are available to accept but not yet accepted show an **"— Available"** label.
- **Focus sort mode** — In Options → Categories, you can choose how entries are ordered within each category: **Alphabetical**, **Quest Type**, **Zone**, or **Quest Level**. A new options section controls sorting within categories.

### 🔧 Improvements

- **Quest caching** — Quest caching logic improved for your current zone and parent maps so quests display correctly without needing to open the map first.
- **Quest bar layout** — Left offset for quest bars adjusted for more consistent layout.
- **Database refactor** — All references updated from `HorizonSuiteDB` to `HorizonDB` for consistency. Options panel and quest tracking aligned to the new saved variable name; TOC and changelog updated accordingly.
---

## [0.6.5] – 2025-02-10

### ✨ New Features

- **Hide in combat** — New option in General (Combat section): when enabled, the tracker panel and floating quest item button are hidden while in combat. When combat ends, visibility is restored according to your existing settings (instance visibility, collapsed state, quest content). When **Animations** is enabled, the tracker and floating button fade out over ~0.2s on entering combat and fade in on leaving combat.
- **Focus category order** — The order of categories in the Focus list (Campaign, World Quests, Rares, etc.) can now be customised. In the options popout (Appearance), reorder categories via drag-and-drop; the new order is saved and used for section headers and section header colors. Use "Reset order" to restore the default order.

### 🔧 Improvements

- **Settings panel** — The options/settings UI has been updated for clearer layout and easier navigation.
- **New settings** — A range of new options have been added across General, Appearance, and other sections so you can tailor the tracker and behaviour to your preference.
---

## [0.6] – 2025-02-09

### ✨ New Features

- **World quest tracking** — World quests in your current zone now appear in the tracker automatically, using both `C_QuestLog` and `C_TaskQuest` data. No need to track every WQ manually.
- **Cross-zone world quest tracking** — World quests you track via the map watch list stay in the tracker when you leave their zone. They are shown with an **[Off-map]** label and their zone name. Use **Shift+click** on a world quest entry to add it to your watch list so it appears on other maps.
- **World map cache** — Opening the world map caches quest data for the viewed map and your current zone. World quests appear more reliably and update when you change map or close the map.
- **Map-close sync** — Closing the world map after untracking world quests there updates the tracker immediately so untracked WQs are removed.
- **Per-category collapse** — Section headers (Campaign, World Quests, Rares, etc.) can be clicked to collapse or expand that category. Collapse state is saved per category. Collapsing uses a short staggered slide-out animation.
- **Combat-safe scrolling** — Mouse wheel scrolling on the tracker is disabled during combat to avoid taint.

### 🔧 Improvements

- **Focus category reorder UX** — The category order list in options now uses live drag-and-drop: a ghost row follows the cursor, an insertion line shows the drop position, the list auto-scrolls when dragging near the edges, and Reset order updates the list immediately. All Focus groups (Campaign, Important, Quests, etc.) are always shown.
- **Nearby quest detection** — Parent and child maps are considered when finding “nearby” quests, so quests in subzones and parent zones are included.
- **Active task quests** — Quests from `C_TaskQuest.IsActive` (e.g. bonus objectives, invasion points) are shown in the tracker under World Quests.
- **Zone change behaviour** — World quest cache is cleared on major zone changes (`ZONE_CHANGED_NEW_AREA`) but kept when moving between subzones, reducing flicker when moving within a zone.
- **Delayed refresh** — An extra refresh runs 1.5s after login and after zone changes so late-loading quest data is picked up.

### 🐛 Fixes

- **TOC** — Version set to 0.6. SavedVariables corrected to a single line: `HorizonDB`.
- **Debug overlay removed** — The development-only world quest cache indicator (bottom-left of screen when the map was open) has been removed from release builds.
- **World map hook polling** — Reduced from 30 retry timers to 5 when waiting for the world map to load; map show/hide hooks no longer reference the removed indicator.

### Technical

- World quest data flow uses `C_QuestLog.GetQuestsOnMap`, `C_TaskQuest.GetQuestsForPlayerByMapID`, and optional `WorldQuestDataProviderMixin.RefreshAllData` hook when available.
- Per-category collapse state is stored in `HorizonDB.collapsedCategories`.
---

## [0.5] and earlier

Initial release and earlier versions. See README.md for full feature list.
