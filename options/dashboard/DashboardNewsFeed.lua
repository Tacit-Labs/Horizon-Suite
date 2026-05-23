--[[
    Horizon Suite - Dashboard News Feed definitions (ordered news-reel items).
    Higher `sort` appears first after layout. Edit this file to add/reorder announcements.
]]

local addon = _G.HorizonSuite

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
        variant = "media",
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