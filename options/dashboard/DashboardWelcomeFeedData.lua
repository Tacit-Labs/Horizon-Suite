--[[
    Horizon Suite - Dashboard Welcome feed definitions (ordered news-reel items).
    Higher `sort` appears first after layout. Edit this file to add/reorder announcements.
    Locale strings use keys in locales/horizon/enUS.lua (titleKey, bodyKey, etc.).
    For welcome_action_card, `icon` may be an icon file name (string) or a table
    { atlas = "AtlasName", fallback = "INV_File" } (same pattern as dashboard sidebar buttons).
]]


local addon = _G.HorizonSuite


--- @type table[] Welcome feed: onboarding content (getting started, contributors, localisations, embedded guide).
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
    },
}

--- @type table[] News feed: roadmap, community & media content, announcements.
addon.DashboardNewsFeed = {
    {
        id = "featured",
        kind = "news_featured",
        variant = "featured",
        sort = 900,
        eyebrowKey = "DASH_NEWS_FEATURED_EYEBROW",
        badgeKey = "DASH_NEWS_BADGE_NEW",
        titleKey = "DASH_NEWS_FEATURED_TITLE",
        taglineKey = "DASH_NEWS_FEATURED_TAGLINE",
        bodyKey = "DASH_NEWS_FEATURED_BODY",
        metaKey = "DASH_NEWS_FEATURED_META",
        artPath = "Interface/AddOns/HorizonSuite/media/dashboard/FeaturedImage.png",
        artWidth = 381,
        artHeight = 248,
        artFit = "contain",
    },
    {
        id = "roadmap",
        kind = "news_card",
        variant = "media",
        sort = 410,
        eyebrowKey = "DASH_NEWS_ROADMAP_EYEBROW",
        titleKey = "DASH_NEWS_ROADMAP_TOP_TITLE",
        bodyKey = "DASH_NEWS_ROADMAP_TOP_BODY",
        secondaryTitleKey = "DASH_NEWS_ROADMAP_BOTTOM_TITLE",
        secondaryBodyKey = "DASH_NEWS_ROADMAP_BOTTOM_BODY",
        artPath = "Interface/AddOns/HorizonSuite/media/dashboard/RoadmapImage.png",
        artWidth = 464,
        artHeight = 880,
        artFit = "contain",
        ctaLabelKey = "DASH_NEWS_CTA_OPEN_PATCH_NOTES",
        ctaAction = { type = "patch_notes" },
    },
    {
        id = "highlight",
        kind = "news_card",
        variant = "standard",
        sort = 400,
        eyebrowKey = "DASH_NEWS_HIGHLIGHT_EYEBROW",
        badgeKey = "DASH_NEWS_BADGE_HIGHLIGHT",
        titleKey = "DASH_NEWS_HIGHLIGHT_TITLE",
        bodyKey = "DASH_NEWS_HIGHLIGHT_BODY",
        metaKey = "DASH_NEWS_HIGHLIGHT_META",
        showClassIconStrip = true,
        ctaLabelKey = "DASH_NEWS_CTA_VIEW_ARTIST",
        ctaAction = { type = "copy_url", url = "https://www.fiverr.com/gc_fresh_ideas?source=gig_page" },
    },
}
