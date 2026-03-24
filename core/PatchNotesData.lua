--[[
    Horizon Suite - Patch Notes Data
    Update this file each release. Key must exactly match ## Version in HorizonSuite.toc.
    In-game notes should be player-facing summaries — not every internal/CI entry.
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then return end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

addon.PATCH_NOTES = {

    ["4.2.2"] = {
        {
            section = "FIXES",
            bullets = {
                "Bonus objectives stay visible when scenario row has no real content",
                "Quest update toast shows wrong objective on multi-objective quests",
            },
        },
    },

    ["4.2.1"] = {
        {
            section = "FIXES",
            bullets = {
                "Bonus objectives stay visible when scenario row has no real content",
                "Quest update toast shows wrong objective on multi-objective quests",
            },
        },
    },

    ["4.2.0"] = {
        {
            section = "New Features",
            bullets = {
                "New installs start with Horizon modules off until you enable them",
                "Dashboard welcome tab and first-run onboarding",
            },
        },
        {
            section = "IMPROVEMENTS",
            bullets = {
                "Remaining delve lives on the Focus tracker scenario line",
            },
        },
        {
            section = "FIXES",
            bullets = {
                "Options colour pickers for Focus and Vista no longer freeze the client or fail to apply colours",
                "Dashboard accordion cards only toggle from the header row",
            },
        },
    },

    ["4.1.2"] = {
        {
            section = "IMPROVEMENTS",
            bullets = {
                "WoWhead link in Focus tracker tooltips and copy-link box",
                "Draggable minimap button with lock and reset options",
            },
        },
    },

    ["4.1.0"] = {
        {
            section = "New Features",
            bullets = {
                "Persona module (Preview): custom character sheet with 3D model, item level, stats, gear grid",
                "Auctionator search button on recipe entries in Focus tracker",
            },
        },
        {
            section = "IMPROVEMENTS",
            bullets = {
                "Auctionator recipe search uses CreateShoppingList and named lists",
                "Insight tooltip fixes: item identity reapply, GetItem fallback, mouseover hide",
            },
        },
    },

    ["4.0.0"] = {
        {
            section = "NEW",
            bullets = {
                "Minimap icon and WoW settings panel integration",
                "Focus tracker header: toggle quest count, divider, color, and options button",
                "Objectives can render outside the tracker window",
                "Category groupings can be individually toggled on or off",
            },
        },
        {
            section = "IMPROVEMENTS",
            bullets = {
                "Dashboard refreshes live when modules are toggled",
                "Class color tinting for the Dashboard (separate toggle)",
                "Insight now shows transmog status for trinkets, rings, and necks",
                "Optional tooltip on hover in the Focus tracker",
                "Delve affix tooltips in the Focus tracker",
                "Global font size offset added to options",
            },
        },
        {
            section = "FIXES",
            bullets = {
                "Delve name no longer shows incorrectly during reward stage",
                "Focus tracker no longer shifts position on /reload",
                "World quest timers no longer tick back up one second during refresh",
                "Text case handles umlauts and accented characters correctly",
            },
        },
    },

}
