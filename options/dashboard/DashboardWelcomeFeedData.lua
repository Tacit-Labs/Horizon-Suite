--[[
    Horizon Suite - Dashboard Welcome feed definitions (ordered news-reel items).
    Higher `sort` appears first after layout. Edit this file to add/reorder announcements.
    Locale strings use keys in Localisation/enUS.lua (titleKey, bodyKey, etc.).
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then _G.HorizonSuite = {} end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

--- @type table[] Each entry: id, kind, sort, plus kind-specific keys (static_header, text_banner, class_icon_strip, hero_media, accordion — see DashboardWelcomeView.lua).
addon.DashboardWelcomeFeed = {
    {
        id = "welcome_header",
        kind = "static_header",
        sort = 10000,
        titleKey = "DASH_WELCOME_TITLE",
        introKey = "DASH_WELCOME_INTRO",
    },
    {
        id = "focus_blizzard_plus_clicks",
        kind = "text_banner",
        sort = 600,
        titleKey = "DASH_WELCOME_FOCUS_BLIZZARD_PLUS_HEADING",
        bodyKey = "DASH_WELCOME_FOCUS_BLIZZARD_PLUS_BODY",
    },
    {
        id = "class_icons",
        kind = "class_icon_strip",
        sort = 400,
        titleKey = "DASH_WELCOME_CLASS_ICONS_HEADING",
        leadKey = "DASH_WELCOME_CLASS_ICONS_LEAD",
        thankKey = "DASH_WELCOME_CLASS_ICONS_THANK_BOOFULS",
        createdPrefixKey = "DASH_WELCOME_CLASS_ICONS_CREATED_PREFIX",
        artistNameKey = "DASH_WELCOME_CLASS_ICONS_ARTIST_NAME",
        artistUrl = "https://www.fiverr.com/gc_fresh_ideas?source=gig_page",
    },
    {
        id = "coming_soon",
        kind = "hero_media",
        sort = 300,
        mediaPath = "Interface/AddOns/HorizonSuite/media/cache.tga",
        titleKey = "DASH_WELCOME_COMING_SOON_TITLE",
        taglineKey = "DASH_WELCOME_COMING_SOON_TAGLINE",
        bodyKey = "DASH_WELCOME_COMING_SOON_BODY",
    },
    {
        id = "contributors",
        kind = "accordion",
        sort = 200,
        headingKey = "DASH_WELCOME_CONTRIBUTORS_HEADING",
        bodyKey = "DASH_WELCOME_CONTRIBUTORS_BODY",
    },
    {
        id = "localisations",
        kind = "accordion",
        sort = 100,
        headingKey = "DASH_WELCOME_LOCALISATIONS_HEADING",
        bodyKey = "DASH_WELCOME_LOCALISATIONS_BODY",
    },
}
