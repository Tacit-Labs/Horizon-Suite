--[[
    Horizon Suite - Dashboard News Feed definitions (ordered news-reel items).
    Higher `sort` appears first after layout. Edit this file to add/reorder announcements.
]]

local addon = _G.HorizonSuite

-- @type table[] News feed: roadmap, community & media content, announcements.
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
        artWidth = 393,
        artHeight = 333,
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
        metaKey = "DASH_NEWS_ROADMAP_META",
        artPath = "Interface/AddOns/HorizonSuite/media/dashboard/RoadmapImage.png",
        artWidth = 500,
        artHeight = 1000,
        artFit = "contain"
    },
    {
        id = "highlight",
        kind = "news_card",
        variant = "media",
        sort = 400,
        eyebrowKey = "DASH_NEWS_HIGHLIGHT_EYEBROW",
        badgeKey = "DASH_NEWS_BADGE_HIGHLIGHT",
        titleKey = "DASH_NEWS_HIGHLIGHT_TITLE",
        bodyKey = "DASH_NEWS_HIGHLIGHT_BODY",
        metaKey = "DASH_NEWS_HIGHLIGHT_META",
        artPath = "Interface/AddOns/HorizonSuite/media/dashboard/HighlightImage.png",
        artWidth = 500,
        artHeight = 1000,
        artFit = "contain"
    },
}