--[[
    Horizon Suite - Patch Notes Data
    Update this file each release. Key must exactly match ## Version in HorizonSuite.toc.
    In-game notes should be player-facing summaries — not every internal/CI entry.
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then return end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

addon.PATCH_NOTES = {

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
