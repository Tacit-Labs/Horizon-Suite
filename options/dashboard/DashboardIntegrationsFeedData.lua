--[[
    Horizon Suite - Dashboard Integrations feed definitions.
    Each entry lists a third-party addon Horizon Suite integrates with.
    Detection at view-render time uses C_AddOns.IsAddOnLoaded(addonName) and
    C_AddOns.GetAddOnInfo(addonName).

    Fields:
      id           string  — stable identifier (used for locale keys, NEW-badge tracking).
      addonName    string  — TOC name passed to C_AddOns.IsAddOnLoaded / GetAddOnMetadata.
      displayName  string  — human-readable label (English).
      descKey      string  — locale key for the longer hover description.
      whatKey      string  — locale key for the "what this enables" body line.
      url          string? — CurseForge (or other) link; nil for bundled libs.
      icon         string|table — fallback when the addon isn't installed or has no
                                   IconTexture in its TOC. Bare name → Interface\Icons\<name>;
                                   path (contains \ or /) → used as-is; { atlas, fallback } also supported.
                                   Bundled logos live in media/integrations/<id>.{blp,tga} and are
                                   sourced from the original addon authors. See CREDITS for attribution.
      slashKey     string? — uppercase key into _G.SlashCmdList; click "Settings" calls it.
      bundled      boolean?— true for libs shipped inside HorizonSuite; UI always shows "Bundled" green tick.
      sort         number  — higher renders first.
]]

local addon = _G.HorizonSuite
if not addon then return end

-- @type table[]
addon.DashboardIntegrationsFeed = {
    {
        id          = "allthethings",
        addonName   = "AllTheThings",
        displayName = "All The Things",
        descKey     = "DASH_INT_ATT_DESC",
        whatKey     = "DASH_INT_ATT_WHAT",
        url         = "https://www.curseforge.com/wow/addons/all-the-things",
        icon        = "Interface\\AddOns\\HorizonSuite\\media\\integrations\\att",
        slashKey    = "ALLTHETHINGS",
        sort        = 500,
    },
    {
        id          = "auctionator",
        addonName   = "Auctionator",
        displayName = "Auctionator",
        descKey     = "DASH_INT_AUCTIONATOR_DESC",
        whatKey     = "DASH_INT_AUCTIONATOR_WHAT",
        url         = "https://www.curseforge.com/wow/addons/auctionator",
        icon        = "Interface\\AddOns\\HorizonSuite\\media\\integrations\\auctionator",
        slashKey    = "AUCTIONATOR",
        sort        = 400,
    },
    {
        id          = "totalrp3",
        addonName   = "totalRP3",
        displayName = "Total RP 3",
        descKey     = "DASH_INT_TRP3_DESC",
        whatKey     = "DASH_INT_TRP3_WHAT",
        url         = "https://www.curseforge.com/wow/addons/total-rp-3",
        icon        = "INV_Misc_Book_09",
        slashKey    = "TRP3",
        sort        = 350,
    },
    {
        id          = "rondomedia",
        addonName   = "RondoMedia",
        displayName = "Rondo Media",
        descKey     = "DASH_INT_RONDOMEDIA_DESC",
        whatKey     = "DASH_INT_RONDOMEDIA_WHAT",
        url         = "https://www.curseforge.com/wow/addons/rondomedia",
        icon        = "Interface\\AddOns\\HorizonSuite\\media\\integrations\\rondomedia.png",
        sort        = 300,
    },
    {
        id          = "worldquesttracker",
        addonName   = "WorldQuestTracker",
        displayName = "World Quest Tracker",
        descKey     = "DASH_INT_WQT_DESC",
        whatKey     = "DASH_INT_WQT_WHAT",
        url         = "https://www.curseforge.com/wow/addons/world-quest-tracker",
        icon        = "Interface\\AddOns\\HorizonSuite\\media\\integrations\\wqt.png",
        slashKey    = "WQT",
        sort        = 250,
    },
    {
        id          = "libsharedmedia",
        addonName   = "LibSharedMedia-3.0",
        displayName = "LibSharedMedia",
        descKey     = "DASH_INT_LSM_DESC",
        whatKey     = "DASH_INT_LSM_WHAT",
        url         = "https://www.curseforge.com/wow/addons/libsharedmedia-3-0",
        icon        = "INV_Misc_Note_01",
        sort        = 100,
    },
}
