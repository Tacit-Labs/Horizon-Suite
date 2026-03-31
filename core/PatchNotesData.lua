--[[
    Horizon Suite - Patch Notes Data
    Update this file each release. Key must exactly match ## Version in HorizonSuite.toc.
    In-game notes should be player-facing summaries — not every internal/CI entry.
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then return end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

addon.PATCH_NOTES = {

    ["4.5.0"] = {
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
        {
            section = "Fixes",
            bullets = {
                "Focus: In Raid and In Dungeon master visibility is honored before per-difficulty options, so the tracker hides when those masters are off",
            },
        },
    },

    ["4.4.0"] = {
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
        {
            section = "Improvements",
            bullets = {
                "Axis: Rename Yield and Persona modules to Cache and Essence",
                "Axis: What's New — inline patch notes in the Dashboard",
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
        {
            section = "Fixes",
            bullets = {
                "Focus: Bonus objectives stay visible when scenario row has no real content",
                "Focus: Quest update toast shows wrong objective on multi-objective quests",
            },
        },
    },

    ["4.2.1"] = {
        {
            section = "Fixes",
            bullets = {
                "Focus: Bonus objectives stay visible when scenario row has no real content",
                "Focus: Quest update toast shows wrong objective on multi-objective quests",
            },
        },
    },

    ["4.2.0"] = {
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
        {
            section = "Improvements",
            bullets = {
                "Focus: WoWhead link in tracker tooltips and copy-link box",
                "Axis: Draggable minimap button with lock and reset options",
            },
        },
    },

    ["4.1.0"] = {
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
