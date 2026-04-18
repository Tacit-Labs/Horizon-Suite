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

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then return end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

addon.PATCH_NOTES = {

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
                "Focus: tracked recipe title and objective colours now follow the Axis Colors Recipes swatches instead of forcing the default sage-green.",
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
                "Axis: module name style setting — Horizon (code-name only), Subtitle (e.g. 'Vista – Minimap'), or Descriptive (plain-language only). Applies across options navigation and headers.",
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
