--[[
    Horizon Suite - Dashboard Welcome Feed definitions (ordered descriptive items).
    Higher `sort` appears first after layout. Edit this file to add/reorder announcements.
    For welcome_action_card, `icon` may be an icon file name (string) or a table
    { atlas = "AtlasName", fallback = "INV_File" } (same pattern as dashboard sidebar buttons).
]]

local addon = _G.HorizonSuite

-- @type table[] Welcome feed: onboarding content (getting started, contributors, localisations, embedded guide).
addon.DashboardWelcomeFeed = {
    {
        id = "welcome_hero",
        kind = "welcome_hero",
        sort = 10000,
        titleKey = "DASH_WELCOME_HERO_TITLE",
        taglineKey = "DASH_WELCOME_HERO_TAGLINE",
        bodyKey = "DASH_WELCOME_HERO_BODY",
    },
    {
        id = "start_here_modules",
        kind = "welcome_action_card",
        sort = 900,
        titleKey = "DASH_WELCOME_ACTION_MODULES_TITLE",
        bodyKey = "DASH_WELCOME_ACTION_MODULES_BODY",
        ctaLabelKey = "DASH_WELCOME_CTA_MODULES",
        icon = "INV_Misc_Wrench_01",
        ctaAction = { type = "dashboard" },
    },
    {
        id = "start_here_news",
        kind = "welcome_action_card",
        sort = 800,
        titleKey = "DASH_WELCOME_ACTION_NEWS_TITLE",
        bodyKey = "DASH_WELCOME_ACTION_NEWS_BODY",
        ctaLabelKey = "DASH_WELCOME_CTA_NEWS",
        icon = { atlas = "Quest-Campaign-Available", fallback = "INV_Misc_StarFall_Blue" },
        ctaAction = { type = "news" },
    },
    {
        id = "start_here_updates",
        kind = "welcome_action_card",
        sort = 750,
        titleKey = "DASH_WELCOME_ACTION_UPDATES_TITLE",
        bodyKey = "DASH_WELCOME_ACTION_UPDATES_BODY",
        ctaLabelKey = "DASH_WELCOME_CTA_PATCH_NOTES",
        icon = "INV_Scroll_05",
        ctaAction = { type = "patch_notes" },
    },
    {
        id = "module_guide_section",
        kind = "module_guide_section",
        sort = 650,
    },
    {
        id = "contributors",
        kind = "welcome_support_card",
        sort = 300,
        titleKey = "DASH_WELCOME_CONTRIBUTORS_HEADING",
        bodyKey = "DASH_WELCOME_CONTRIBUTORS_BODY",
    },
    {
        id = "supporters",
        kind = "welcome_support_card",
        sort = 200,
        titleKey = "DASH_WELCOME_SUPPORTERS_HEADING",
        bodyKey = "DASH_WELCOME_SUPPORTERS_BODY",
        -- { name, classFile } — classFile is WoW’s English class token (same as RAID_CLASS_COLORS keys), e.g. WARRIOR, DRUID.
        supporterEntries = {
            { name = "Diva", classFile = "PRIEST" },
            { name = "Feralus", classFile = "DRUID" },
            { name = "Jarvis", classFile = "MAGE" },
            { name = "Savs", classFile = "SHAMAN" },
            { name = "Vukolak", classFile = "WARLOCK" },
            { name = "Boofuls", classFile = "PALADIN" },
        },
    },
    {
        id = "localisations",
        kind = "welcome_support_card",
        sort = 100,
        titleKey = "DASH_WELCOME_LOCALISATIONS_HEADING",
        bodyKey = "DASH_WELCOME_LOCALISATIONS_BODY",
    }
}
