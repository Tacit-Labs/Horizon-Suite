--[[
    Horizon Suite - Patch Notes Data
    Update this file each release. Key must exactly match ## Version in HorizonSuite.toc.
    In-game notes should be player-facing summaries — not every internal/CI entry.

    Per version table:
    - date = "YYYY-MM-DD" (optional but preferred) — store ISO for CHANGELOG parity; the dashboard shows long UK text
      (e.g. 31 March 2026) in parentheses after the version.
    - Array entries { section = "...", bullets = { ... } } — bullets may use "Module: rest"; the UI capitalizes the
      first letter after ": " when it is lowercase (ASCII). Data can stay lowercase after the colon if you prefer.
]]

local addon = _G.HorizonSuite

addon.PATCH_NOTES = {

    ["5.3.3"] = {
        date = "2026-07-20",
        {
            section = "Fixes",
            bullets = {
                "Insight: Total RP 3 character info once again shows inside Horizon's tooltip, while Blizzard Edit Mode stays free of errors blamed on Horizon Suite.",
            },
        },
    },

    ["5.3.2"] = {
        date = "2026-07-18",
        {
            section = "Fixes",
            bullets = {
                "Insight: Player tooltips in battlegrounds and arenas no longer error when Midnight hides unit names from addons.",
            },
        },
    },

    ["5.3.1"] = {
        date = "2026-07-18",
        {
            section = "Fixes",
            bullets = {
                "Insight: Opening Blizzard Edit Mode with Total RP 3 no longer shows Boss Warnings errors blamed on Horizon Suite.",
            },
        },
    },

    ["5.3.0"] = {
        date = "2026-07-18",
        {
            section = "New Features",
            bullets = {
                "Augment: Alerts mini-module — Status toasts for low durability, bags nearly full, new mail, Great Vault rewards ready, and friends coming online/offline, with a Dashboard page, Edit Mode positioning, and per-kind toggles (off by default until you enable them).",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Core: Opening the Game Menu with EllesmereUI no longer triggers a protected-action error blamed on Horizon.",
                "Augment: Currency transfers no longer hit an action-forbidden error from loot-alert suppression.",
            },
        },
    },

    ["5.2.0"] = {
        date = "2026-07-10",
        {
            section = "New Features",
            bullets = {
                "Vista: Vista button for quick teleport overview (toys, hearthstones, etc.) — Minimap button opens a menu of unlocked teleports (hearthstones, profession, class, dungeon & raid, event) with favourites, recents, and cooldowns; cast in place without opening the map or bags.",
                "Focus: Proximity sort and auto-focus closest quest — New Proximity (Closest First) sort mode, plus an optional Auto-Focus Closest Quest toggle (/h focus autofocus and a keybind) that keeps the waypoint on the nearest quest.",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Focus: Total achievement points on Achievements header — Optional readout of your account achievement points on the Achievements section header (off by default).",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Options: Colour picker hex and RGB values stay readable with large fonts, the window collapses when opacity is unused, and it remembers its dragged position.",
            },
        },
    },

    ["5.1.2"] = {
        date = "2026-07-05",
        {
            section = "Improvements",
            bullets = {
                "Presence: the zone/area \"Discovered\" line now has its own font, outline, and size controls, instead of inheriting the subtitle font.",
            },
        },
    },

    ["5.1.1"] = {
        date = "2026-07-05",
        {
            section = "Improvements",
            bullets = {
                "General: general updates and fixes.",
                "Focus: the RareScanner and SilverDragon bridge add-ons now register as optional dependencies, so they load in the correct order and their integration alerts surface reliably.",
            },
        },
    },

    ["5.1.0"] = {
        date = "2026-06-19",
        {
            section = "New Features",
            bullets = {
                "Augment: quality-of-life mini-modules — Augment now splits into five independently-toggled features: Loot Toasts, Self Highlight (highlights your character in combat and when targeted by hostiles), Auto Vendor (auto-sells junk and repairs gear at merchants), Talking Head (customise the frame's font, position, and hold duration), and Achievement Tracker (auto-removes earned achievements from the objective tracker).",
                "Focus: RareScanner & SilverDragon integration — rare NPC, treasure, and event alerts now surface inside the Focus tracker, with a 3D portrait, click-to-waypoint coordinates (TomTom or map pin), click-to-target with a raid marker, Ctrl+Click Wowhead link copy, and a configurable alert queue; both appear in the Dashboard Integrations view.",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "General: every colour swatch in the Options panel and Dashboard now opens a dark, Horizon-styled colour picker (wheel, brightness, hex/RGB entry, opacity, compare view) with an account-wide saved-colours palette shared across your characters.",
                "General: options sliders get a visual refresh — a gradient bar with a square handle and hover/drag feedback.",
                "Augment: loot toasts gain new options — show the item count before the name, and adjust icon size and icon-to-name spacing.",
                "Augment: the Style options are reworked into a cleaner two-column layout, and the text-outline toggle becomes an Outline Type dropdown (None / Thin / Thick).",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Insight: cursor-anchored tooltips no longer get stuck using the Fixed anchor's dynamic position after switching anchor modes.",
                "Insight: tooltips no longer get stuck in cursor mode in certain cases.",
                "General: fixed a frame leak in the hidden-quests list and a dropdown popup highlight-clipping issue.",
            },
        },
    },

    ["5.0.2"] = {
        date = "2026-06-02",
        {
            section = "Fixes",
            bullets = {
                "General: various bug fixes and taint error fixes.",
            },
        },
    },

    ["5.0.1"] = {
        date = "2026-05-29",
        {
            section = "Improvements",
            bullets = {
                "Axis: added an option to show or hide the Horizon Suite entry in the Esc game menu.",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Focus: the bullet point option is now selectable in the objective prefix dropdown.",
                "Dashboard: LibSharedMedia is now correctly detected as installed in the Integrations view when it loads on demand.",
                "Essence: custom fonts chosen via LibSharedMedia now display correctly, and a related refresh error has been fixed.",
                "Insight: resolved a frame-rate drop caused by repeated tooltip font hooks.",
            },
        },
    },

    ["5.0.0"] = {
        date = "2026-05-22",
        {
            section = "New Features",
            bullets = {
                "Augment: New Module — a full quality-of-life module with its own dashboard and settings, currently including the on-screen toast module for loot, currency and reputation (previously named \"Cache\").",
                "Dashboard: Integrations view — every third-party addon integrated with Horizon Suite now exists within a sidebar tab showing which are installed, disabled, or missing, with an Install link to each missing addon's CurseForge page and a Settings button into installed addons' own config.",
                "Insight: Total RP 3 profile integration — TRP3's character icon, name colour, IC/OOC badge, pronouns, race, class, guild, and Currently text now render inside the Insight-styled tooltip instead of a separate TRP3 frame.",
                "Core: in-game menu button — a Horizon Suite entry in the Esc menu that opens the dashboard.",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Focus: objectives can now be prefixed with a bullet point instead of the current hyphen or numbering system.",
                "Insight: a player's total achievement points may now be shown, with or without a modifier, next to a star in gold.",
                "Localisation: German update and general upkeep across all locales.",
                "Backend: began to introduce maintenance helpers and scaffolding for future upkeep.",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Focus: coloured shadow text in objective rows no longer leaks colour escape codes into the shadow string.",
            },
        },
    },

    ["4.18.2"] = {
        date = "2026-05-15",
        {
            section = "Fixes",
            bullets = {
                "Focus: quest entries no longer throw a Lua error when the tracked quest's zone is anything other than \"Activity\" (regression from 4.18.1).",
            },
        },
    },

    ["4.18.1"] = {
        date = "2026-05-15",
        {
            section = "Improvements",
            bullets = {
                "Localisation: strings now fall back to English only when a locale key is missing, surfacing untranslated entries instead of masking them with English text.",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Presence: World Quest complete sound is no longer suppressed when the Presence banner replaces the default Blizzard banner.",
            },
        },
    },

    ["4.18.0"] = {
        date = "2026-05-14",
        {
            section = "New Features",
            bullets = {
                "Presence: Talking Head customisation — fonts, colours, portrait/frame visibility, scale, and voice-over mute.",
                "Focus: Focused Quest category — super-tracked quests hoist into their own reorderable section.",
                "Focus: Mythic+ split timers — remaining time to the +1, +2, and +3 cut-offs, with crossed tiers dimmed.",
                "Insight: Tooltip preview window and new toggles — content-sized previews, Shift-modifier refresh, per-stat display modes, per-status-badge toggles, Spec-Override class icon, Realm Names and Section Separation dropdowns, and bundled race icons.",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Focus: Shrink-to-fit width — tracker grows to the longest visible row, capped at a configurable maximum.",
                "Focus: Progress bar text inherits the objective's category colour by default; the custom colour picker still overrides.",
                "Localisation: German locale refresh plus ongoing locale hygiene across the other non-English locales.",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Presence: Disabling Zone Notifications now hides them correctly.",
                "Focus: Objective lines with a leading dash no longer double up the bullet prefix.",
            },
        },
    },

    ["4.17.7"] = {
        date = "2026-05-09",
        {
            section = "Improvements",
            bullets = {
                "Vista: circular Horizon button variant to match SexyMap and HidingBar-style round minimap buttons.",
                "Presence: font outline options (None, Thin Outline, Thick Outline, Monochrome Outline, SLUG).",
                "Insight: suffix character titles now render correctly (including comma forms), with a new Title Colour mode picker (Match Name / Match Name (Gradient) / Custom).",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Insight: guild rank now displays correctly in player tooltips without realm name leakage.",
                "Vista: square minimap mode no longer errors when clearing the Horizon button's highlight texture.",
            },
        },
    },

    ["4.17.6"] = {
        date = "2026-05-08",
        {
            section = "Improvements",
            bullets = {
                "Focus: bar texture and colour changes now apply live without requiring a UI reload.",
                "Axis: Welcome and News content now honours the Dashboard Font option.",
                "Axis: choose a softer heading colour for the Dashboard Welcome and News blocks — previously locked to pure white, which is uncomfortable on HDR displays.",
            },
        },
    },

    ["4.17.5"] = {
        date = "2026-05-07",
        {
            section = "Fixes",
            bullets = {
                "Focus: Mythic+ block 'Always Show' toggle now previews the block outside of a Mythic+ dungeon — previously it did nothing. The toggle is reset to off on upgrade.",
            },
        },
    },

    ["4.17.4"] = {
        date = "2026-05-04",
        {
            section = "Improvements",
            bullets = {
                "Axis: SLUG, SLUG Outline, and SLUG Thick Outline are now selectable in the shared outline dropdown alongside Outline and Thick Outline.",
                "Localisation: English settings labels and tooltip descriptions now follow Title Case consistently.",
            },
        },
    },

    ["4.17.3"] = {
        date = "2026-05-02",
        {
            section = "Fixes",
            bullets = {
                "Localisation: non-English clients now display in the player's selected language again instead of falling back to English (regression introduced in 4.17.2).",
            },
        },
    },

    ["4.17.2"] = {
        date = "2026-05-02",
        {
            section = "Improvements",
            bullets = {
                "Focus: Ritual Site scenario headers now show their currency icons and progress values alongside the other objectives.",
                "Vista: choose a custom icon for the floating drawer button — accepts a Blizzard icon name or texture path.",
            },
        },
    },

    ["4.17.1"] = {
        date = "2026-04-29",
        {
            section = "Fixes",
            bullets = {
                "Insight: tooltip quality colour now matches the item's actual rarity instead of occasionally showing the wrong border and name colour.",
            },
        },
    },

    ["4.17.0"] = {
        date = "2026-04-28",
        {
            section = "New Features",
            bullets = {
                "Focus: static background size option — lock the Focus tracker background to a fixed size regardless of how many entries are tracked.",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Cache: per-module font picker with locale-aware default — Cyrillic, Korean, and other non-Latin glyphs now render correctly in the loot display, and each module can pick its own font.",
            },
        },
    },

    ["4.16.1"] = {
        date = "2026-04-26",
        {
            section = "Improvements",
            bullets = {
                "Vista: mail icon tooltip now lists senders like the default Blizzard tooltip.",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Focus: quest icon clicks in Blizzard+ mode now reliably focus the quest, even after the slot previously rendered a non-quest row.",
                "Focus: Auctionator search button now appears immediately on tracked recipe entries when the Auction House opens.",
            },
        },
    },

    ["4.16.0"] = {
        date = "2026-04-25",
        {
            section = "New Features",
            bullets = {
                "Axis: Dashboard smart open routing — the dashboard now resumes wherever you left it (including module sub-categories), and the Welcome page only appears once on first install.",
                "Axis: patch notes popup — on the first reload after an update, a small standalone popup shows the latest release notes instead of taking over the dashboard, so your last view is preserved.",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Vista: the Crafting Orders minimap icon no longer flashes briefly on characters with no pending orders.",
                "Vista: the Crafting Orders tooltip now lists each profession with a pending order beneath the total, instead of only showing a count.",
            },
        },
    },

    ["4.15.0"] = {
        date = "2026-04-24",
        {
            section = "New Features",
            bullets = {
                "Axis: settings overhaul begins — start of a broader Horizon settings and Dashboard overhaul. Axis is the first module to land with a reorganised, more consistent options layout; other modules will follow in subsequent releases.",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Axis: staged Reload UI for profile changes — profile toggles and dropdowns now queue a single reload prompt instead of reloading on every click, matching the Modules pattern.",
                "Axis: Dashboard class-colour controls — new master toggle gates the Dashboard's class-colour treatments, with sub-toggles for the class-colour background and class icon.",
                "Focus: Timer Text and Options Text fonts are now independent of the Title and Objective font settings.",
                "Vista: Crafting Orders minimap indicator — adds Crafting Orders support on the Vista minimap with the same trigger conditions as the default UI.",
                "Vista: unlocked minimap icons now render semi-transparent for a clear visual cue when they're in a movable state.",
                "Localisation: updated German (deDE) translations from a Discord submission.",
                "Localisation: options name labels now use headline-style capitalisation across the panel.",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Focus: daily recurring quests now appear in their own Daily section instead of being grouped under Weekly.",
                "Focus: collapsing then quickly re-expanding a category no longer leaves a blank space with no quests rendered.",
                "Focus: accepting a quest now animates in smoothly instead of popping the slot open and flashing into position.",
                "Focus: disabling a per-element font toggle now reverts that element to the global font immediately.",
                "Vista: Crafting Orders indicator now repairs correctly and honours the unified minimap drag positioning.",
                "Axis: toggling the minimap icon now saves immediately so the setting survives an instant reload.",
            },
        },
    },

    ["4.14.0"] = {
        date = "2026-04-22",
        {
            section = "New Features",
            bullets = {
                "Focus: Delve Nemesis groups indicator — while in a Delve, the main Focus row can show Nemesis enemy groups remaining (and the completed checkmark state).",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Focus: Blizzard+ Click Style — clicking a tracked line with the chat window open now shares the item to chat instead of untracking it, Ctrl+Left-click on collection items opens the preview/wardrobe, and Right-click → Open Collections navigates to the correct category and item.",
            },
        },
    },

    ["4.13.0"] = {
        date = "2026-04-21",
        {
            section = "New Features",
            bullets = {
                "Insight: Gradient tooltip fonts — item tooltips render in quality-colour gradients; player character tooltips use class-colour gradients.",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Focus: Significant performance improvements — quest update events are debounced, rare and treasure vignette scans are consolidated and cached, and layout passes are skipped when position hasn't changed.",
                "Vista: Minimap button collector now offers alphabetical sorting for a more predictable button order.",
            },
        },
    },

    ["4.12.6"] = {
        date = "2026-04-19",
        {
            section = "Improvements",
            bullets = {
                "Focus: hover tooltips now pin to the outer edge of the Horizon panel so they never cover the tracker, whether it's docked on the left or right side of the screen.",
                "Insight: new toggle keeps Focus tracker tooltips on the dynamic edge anchor even when all other Insight tooltips are pinned to a fixed position.",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Focus: hover tooltips (quests, rares, endeavors, recipes, LFG/AH buttons, floating quest item, M+ block) now honour the Insight anchor mode (Cursor / Fixed) instead of always opening right of the hovered widget.",
                "Insight: Cursor:Center anchor now correctly centres the tooltip at the cursor instead of using the Fixed anchor position.",
                "Focus: WoWhead click-combo hint now shows 'Shift + Left click' etc. instead of raw tokens like 'shiftLeft'.",
            },
        },
    },

    ["4.12.5"] = {
        date = "2026-04-18",
        {
            section = "Improvements",
            bullets = {
                "Focus: weekly meta quests now group under the Weekly section alongside other weekly-reset activities.",
                "Focus: completed-count suffixes (e.g. 0/1, 1/1) no longer appear on single-objective quests.",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Focus: tracked recipe title and objective colours now follow the Axis Colours Recipes swatches instead of forcing the default sage-green.",
                "Axis: profile switching now fully refreshes class colours, frame positions, and imported settings without requiring a reload.",
            },
        },
    },

    ["4.12.4"] = {
        date = "2026-04-16",
        {
            section = "Fixes",
            bullets = {
                "Insight: rolled back a recent change that was causing issues.",
            },
        },
    },

    ["4.12.3"] = {
        date = "2026-04-16",
        {
            section = "Improvements",
            bullets = {
                "Axis: module name style setting — Horizon (code-name only), Subtitle (e.g. 'Vista – Minimap'), or Simple (plain-language only). Applies across options navigation and headers.",
                "Focus: with Grow Upwards enabled, section header priority order now flips so High priority sits closest to the Objectives header.",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Focus: Current Event reappears for untracked World Quests when you enter their zone, without needing to re-track the quest.",
            },
        },
    },

    ["4.12.2"] = {
        date = "2026-04-14",
        {
            section = "Improvements",
            bullets = {
                "Insight: Gate NotifyInspect on player tooltip options — disabling every Player Characters option fully stops inspect requests on mouseover, so other inspect-dependent addons are no longer interrupted. A new 'Spec icon & role' toggle controls the spec/role display and its inspect query.",
            },
        },
    },

    ["4.12.1"] = {
        date = "2026-04-13",
        {
            section = "Fixes",
            bullets = {
                "Focus: Warbound weekly quests now sort and track correctly; right-click to untrack no longer fails for Warbound weeklies.",
                "Focus: Quest item button cooldowns now update properly while in combat.",
            },
        },
    },

    ["4.12.0"] = {
        date = "2026-04-12",
        {
            section = "New Features",
            bullets = {
                "Axis: resizable dashboard with corner grabber, saved size and position, and layout scaling helpers",
                "Axis: Ctrl+F opens dashboard search from the options UI; search focuses after sidebar changes",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Axis: handheld and narrow layouts — patch notes and headers reflow without overlap, constrained search bar, sensible sidebar scroll when content fits, accordions and two-column tiles adapt on resize",
                "Vista: minimap button visibility and related settings grouped under Vista with other minimap UI options",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Focus: tracked world quests open on the correct zone map instead of the wrong area view",
                "Axis: dashboard layout stays usable on very small or handheld-sized windows (overlap, width, and resize edge cases)",
            },
        },
    },

    ["4.11.0"] = {
        date = "2026-04-10",
        {
            section = "New Features",
            bullets = {
                "Axis: dashboard search page with pinned sidebar and layout polish",
                "Axis: filter dashboard search results by module",
                "Axis: welcome scrollable feed with detail wiring and locale strings",
                "Focus: custom click profiles for the objective tracker — map your own modifier combos to each row, or choose Horizon+ for Horizon Suite's unified preset and row actions",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Axis: overhaul welcome view, module guide, and home toggle cards",
                "Axis: welcome refresh and minimap-open keyboard fix",
                "Focus: unify objective tracker icon clicks with click profiles",
                "Axis: settings search — ranked matches, visible descriptions, search only on Search page",
                "Axis: All module filter omits settings for disabled modules (Axis options still shown)",
                "Axis: news refresh and Focus click options aligned with Blizzard+ profile and Horizon+ bindings",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Insight: unit and item tooltips avoid errors from Midnight secret-value APIs",
            },
        },
    },

    ["4.10.0"] = {
        date = "2026-04-08",
        {
            section = "New Features",
            bullets = {
                "Insight: cursor tooltips can anchor to the left, right, or center of the cursor, with optional offsets for left and right",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Axis: release zip no longer ships docs and tools (pkgmeta and ignore updates)",
                "Insight: item quality for tooltip chrome uses current item info data",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Focus: quest-complete row keeps the inline timer on timed click-to-complete quests",
                "Insight: world-cursor NPC tooltips — fewer errors and sturdier default cursor anchoring",
                "Insight: player tooltips keep custom styling when re-hovering the same unit",
                "Insight: unit tooltips keep addon lines after a Blizzard SetUnit refresh",
            },
        },
    },

    ["4.9.4"] = {
        date = "2026-04-07",
        {
            section = "Improvements",
            bullets = {
                "Insight: NPC subtitles stay visible when the custom level line is on (level on line three when line two is real subtitle text)",
            },
        },
    },

    ["4.9.3"] = {
        date = "2026-04-06",
        {
            section = "Improvements",
            bullets = {
                "Axis: dashboard body text size, outline dropdown, and shadow toggle (migrates older keys)",
                "Axis: option widget fonts refresh when dashboard typography changes",
                "Axis: home tiles — class-colour hover ring; clearer preview and coming-soon states",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Axis: settings search stays visible when opening a module after Welcome or Quick Start",
                "Focus: omit tracked quests whose title or objectives contain [DNT] placeholders",
            },
        },
    },

    ["4.9.2"] = {
        date = "2026-04-06",
        {
            section = "Improvements",
            bullets = {
                "Focus: quest type icons on by default for existing profiles (migration)",
                "Focus: header text case default matches tracker uppercase",
                "Axis: sidebar module row opens that module and highlights its header; Home and subcategory card chrome aligned; Quick Start path glyphs fixed; batched module toggles use one deferred reload",
                "Insight: hook-sourced tooltip flags avoid unsafe secret boolean checks on Midnight",
                "Vista: difficulty text anchored to the minimap, independent of zone text",
                "Localization: plain commented locale stubs and safer multiline restructure output",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Axis: dashboard options search accordion no longer overlaps after jump-to-match",
            },
        },
    },

    ["4.9.1"] = {
        date = "2026-04-06",
        {
            section = "Improvements",
            bullets = {
                "Axis: German (deDE) options and dashboard text refreshed from a contributor export, with locale files restructured to match English key order",
            },
        },
    },

    ["4.9.0"] = {
        date = "2026-04-05",
        {
            section = "New Features",
            bullets = {
                "Focus: Auctionator craft dialog from the tracker includes a crafting tier menu (1–5)",
                "Focus: right-click auction house recipe search from the tracker can multiply reagent quantities by your craft count",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Focus: auction craft dialog scales with your UI scale and Cancel/OK layout is clearer",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Insight: tooltip handling no longer spams Lua errors when the game restricts certain boolean checks",
            },
        },
    },

    ["4.8.6"] = {
        date = "2026-04-05",
        {
            section = "Fixes",
            bullets = {
                "Focus: Delves section only includes Delve-tagged log quests in a delve, not every nearby quest",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Focus: long objectives wrap correctly after zone or affix rows; wrapped affix lines keep objectives aligned on the left under the full block",
            },
        },
    },

    ["4.8.5"] = {
        date = "2026-04-05",
        {
            section = "Improvements",
            bullets = {
                "Focus: optional Events in Zone bucket — turn off under Sorting & Filtering to hide nearby unaccepted and zone-event quests from the tracker",
                "Axis: more dashboard background themes, compressed art, Teldrassil preset migrates to burning Teldrassil for existing profiles",
            },
        },
    },

    ["4.8.4"] = {
        date = "2026-04-05",
        {
            section = "Improvements",
            bullets = {
                "Focus: delve affix names keep your font; separators use the game font to avoid missing glyphs with decorative typefaces",
                "Focus: long delve affix lines wrap and objectives align under the full affix block",
            },
        },
    },

    ["4.8.3"] = {
        date = "2026-04-05",
        {
            section = "Improvements",
            bullets = {
                "Focus: tracked achievement rows with optional progress bars and description fallback",
                "Focus: compact recipe reagent list by default with optional full schematic detail",
                "Focus: Auctionator shopping lists from recipes include quantities",
                "Focus: quest level display without a separate remove-L toggle",
                "Axis: dashboard JPG backgrounds, expanded themes, options and locales",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Insight: unit tooltips no longer error on some targets (secret unit token)",
            },
        },
    },

    ["4.8.2"] = {
        date = "2026-04-03",
        {
            section = "New Features",
            bullets = {
                "Focus: tracker rows — transmog appearances (map, menu, waypoints), better quest completion from clicks, optional WoWhead tooltip line",
                "Insight: grouped thousands for long numbers in tooltips and UI text (shared with Focus)",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Focus: optional gold/green X/Y objective progress colours while in progress or complete",
                "Focus: coloured progress mode also tints the slash between counts for one consistent token",
                "Axis: dashboard background defaults to Midnight; old flat choices migrate once; flat style labelled Minimalistic",
                "Axis: Night Fae and Zin-Azshari background art bundled; legacy theme ids map to Midnight",
            },
        },
    },

    ["4.8.1"] = {
        date = "2026-04-03",
        {
            section = "Improvements",
            bullets = {
                "Axis: dashboard Welcome tab is built from a configurable feed and dedicated view so sections are easier to maintain and extend",
                "Focus: bar left and pill left highlights place quest type icons beside the bar and remove extra title padding when icons are shown",
            },
        },
    },

    ["4.8.0"] = {
        date = "2026-04-03",
        {
            section = "New Features",
            bullets = {
                "Focus: introducing Blizzard+ as the standard; profile-based quest row clicks (including Classic Click) are available now, with Horizon+ and further customisation coming soon",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Axis: configurable font and text size for the settings window",
                "Focus: when you resize quest type icons larger, bar-left and pill-left layouts keep them inside the tracker panel",
            },
        },
    },

    ["4.7.0"] = {
        date = "2026-04-03",
        {
            section = "New Features",
            bullets = {
                "Focus: tracked transmog appearances in the tracker with Horizon and classic clicks (super-track, dressing room, map/TomTom when enabled)",
                "Insight: custom class icons from the addon media folder",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Insight: tooltip pipeline and shared display tweaks",
                "Focus: section headers and category order use localized UI labels",
                "Axis: BLP class icons, dashboard welcome polish, and community footer updates",
                "Axis: dashboard footer intrinsic wordmark sizing, optimized textures, mixed-script welcome font",
            },
        },
    },

    ["4.6.1"] = {
        date = "2026-04-02",
        {
            section = "Improvements",
            bullets = {
                "Insight: optional hide tooltips in combat — toggle under Global Tooltips; frames close on combat start and stay suppressed while in combat",
                "Axis: Discord invite links updated in dashboard, READMEs, and GitHub issue template",
                "Axis: README and CurseForge listing refresh — clearer install steps and expanded listing copy",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Focus: world quest / tracker quest item hover no longer double-triggers the item tooltip (Insight fade flicker)",
                "Insight: tooltip fade-in dedupes item tooltips by stable item id when the link string changes on refresh",
            },
        },
    },

    ["4.6.0"] = {
        date = "2026-04-01",
        {
            section = "New Features",
            bullets = {
                "Axis: dashboard Quick Start guide, streamlined Welcome, and locale updates",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Insight: stop shopping tooltip fade flicker on minimap and world quest item tooltips",
                "Axis: dashboard welcome with community link icons, mixed-script contributors, and Cache hero art",
                "Vista: minimap mouse-wheel zoom only; overlay zoom controls removed; reset overlay positions",
                "Focus: Alt + Click hint next to WoWhead link in tooltip",
                "Focus: quest level next to titles shows as [60] instead of [L60] when level display is on",
                "Axis: patch notes attention, labelling, and dashboard polish",
                "Insight: unit tooltip dismiss options and deferred dismiss behaviour",
                "Insight: player-frame unit tooltips; choose faction or class colour for the player name on the first line",
                "Axis: What's New shows version dates and capitalizes module bullets",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Insight: unit tooltip frame no longer sometimes stays unskinned on refresh",
            },
        },
    },

    ["4.5.0"] = {
        date = "2026-03-31",
        {
            section = "New Features",
            bullets = {
                "Presence: optional progress toasts for achievements that are not tracked",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Focus: stable achievement tracking and content-tracking refresh",
                "Focus: quest row pool increased from 25 to 50",
                "Focus: scenario and delve updates with fewer FPS dips from less layout churn",
                "Focus: dim unfocused affects only quest rows",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Presence: achievement progress toast uses the correct criterion on multi-part achievements",
            },
        },
    },

    ["4.4.2"] = {
        date = "2026-03-31",
        {
            section = "Improvements",
            bullets = {
                "Vista: Minimap Horizon icon, optional Vista bar integration, fade until hover over the map, anchored tooltip when the button moves",
                "Axis: Modular options dashboard, profile import/export, URL copy dialog, tooling layout",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Focus: Dim strength and dim alpha apply consistently when dimming unfocused entries",
                "Focus: Text shadow offsets apply consistently across headers, titles, and controls",
            },
        },
    },

    ["4.4.1"] = {
        date = "2026-03-30",
        {
            section = "Fixes",
            bullets = {
                "Focus: In Raid and In Dungeon master visibility is honored before per-difficulty options, so the tracker hides when those masters are off",
            },
        },
    },

    ["4.4.0"] = {
        date = "2026-03-29",
        {
            section = "New Features",
            bullets = {
                "Localisation 2.0 — restructured strings and tooling",
                "Insight: tooltip options on separate pages with dashboard preview; cursor-follow tooltips and offsets; live preview and mount ownership on the dashboard",
                "Font dropdowns show each font in its own typeface",
                "Focus: zone-change tracker refresh; Insight: per-type tooltip options",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Options dashboard: modular layout under options/dashboard",
                "Module names use fixed English labels in the UI",
                "Insight: Midnight-safe unit tooltips, per-section font sizes, and polish",
                "Vista: minimap FPS/latency strip — urgency colours, smoother layout and drag",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Presence: scenario progress toast shows the full count on the last objective of a step",
            },
        },
    },

    ["4.3.1"] = {
        date = "2026-03-26",
        {
            section = "Improvements",
            bullets = {
                "Axis: Rename Yield and Persona modules to Cache and Essence",
                "Axis: Patch Notes — inline patch notes in the Dashboard",
                "Axis: Dashboard — Meridian coming-soon tile, locales, and welcome layout",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Insight: Tooltip enhancements work more cleanly with the default UI, without error popups",
            },
        },
    },

    ["4.3.0"] = {
        date = "2026-03-25",
        {
            section = "New Features",
            bullets = {
                "Axis: Unified class colours — batch toggle and per-module tinting",
                "Focus: Colour choices for global, headers, and objectives",
                "Axis: Dashboard class icon with shared class media",
                "Axis: Global toggles for class colours and scale; module options grouped for on/off and minimap",
                "Axis: Dashboard background option uses current specialisation talent art",
                "Axis: Welcome screen and dashboard refresh",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Insight: Defer tooltip width clamping for more reliable layout",
                "Insight: Fade out stale unit tooltips when mouseover clears",
            },
        },
    },

    ["4.2.2"] = {
        date = "2026-03-24",
        {
            section = "Fixes",
            bullets = {
                "Focus: Bonus objectives stay visible when scenario row has no real content",
                "Focus: Quest update toast shows wrong objective on multi-objective quests",
            },
        },
    },

    ["4.2.1"] = {
        date = "2026-03-24",
        {
            section = "Fixes",
            bullets = {
                "Focus: Bonus objectives stay visible when scenario row has no real content",
                "Focus: Quest update toast shows wrong objective on multi-objective quests",
            },
        },
    },

    ["4.2.0"] = {
        date = "2026-03-23",
        {
            section = "New Features",
            bullets = {
                "Axis: New installs start with Horizon modules off until you enable them",
                "Axis: Dashboard welcome tab and first-run onboarding",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Focus: Remaining delve lives on the scenario line",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Axis: Colour pickers for Focus and Vista no longer freeze the client or fail to apply colours",
                "Axis: Dashboard accordion cards only toggle from the header row",
            },
        },
    },

    ["4.1.2"] = {
        date = "2026-03-18",
        {
            section = "Improvements",
            bullets = {
                "Focus: WoWhead link in tracker tooltips and copy-link box",
                "Axis: Draggable minimap button with lock and reset options",
            },
        },
    },

    ["4.1.0"] = {
        date = "2026-03-18",
        {
            section = "New Features",
            bullets = {
                "Essence: Module preview — custom character sheet with 3D model, item level, stats, and gear grid",
                "Focus: Auctionator search button on recipe entries in the tracker",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Focus: Auctionator recipe search uses named shopping lists",
                "Insight: Tooltip fixes — item identity reapply, item data fallback, and mouseover hide",
            },
        },
    },

    ["4.0.0"] = {
        date = "2026-03-18",
        {
            section = "New Features",
            bullets = {
                "Axis: Minimap icon and settings panel integration",
                "Focus: Tracker header — toggle quest count, divider, colour, and options button",
                "Focus: Objectives can render outside the tracker window",
                "Focus: Category groupings can be individually toggled on or off",
            },
        },
        {
            section = "Improvements",
            bullets = {
                "Axis: Dashboard refreshes live when modules are toggled",
                "Axis: Class colour tinting for the dashboard (separate toggle)",
                "Insight: Now shows transmog status for trinkets, rings, and necks",
                "Focus: Optional tooltip on hover in the tracker",
                "Focus: Delve affix tooltips in the tracker",
                "Axis: Global font size offset added to options",
            },
        },
        {
            section = "Fixes",
            bullets = {
                "Focus: Delve name no longer shows incorrectly during the reward stage",
                "Focus: Tracker no longer shifts position on /reload",
                "Focus: World quest timers no longer tick back one second during refresh",
                "Focus: Text case handles umlauts and accented characters correctly",
            },
        },
    },

}
