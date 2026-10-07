--[[
    Horizon Suite - Welcome showcase layout and credits.
    Rendered top to bottom by DashboardWelcomeShowcase.lua (DashboardShowcase_InitWelcome).
]]

local addon = _G.HorizonSuite

addon.DashboardWelcomeFeed = {
    { id = "hero",    kind = "showcase_hero" },
    { id = "modules", kind = "module_tiles",
      tiles = { "focus", "presence", "vista", "insight", "echo", "augment", "essence", "integrations" } },
    { id = "news",    kind = "news_strip" },
    { id = "credits", kind = "credits_footer" },
}

-- Tile screenshots shipped in media/dashboard/welcome/tiles/, keyed by tile key
-- (e.g. focus = "focus.png"). A tile without one shows an accent card with the module icon.
addon.WelcomeTileArt = {}

-- Credits shown in the footer tooltip. Supporters are { name, classFile }, where classFile is
-- WoW's English class token; translators carry the locale they translated.
addon.DashboardWelcomeCredits = {
    contributors = {
        { name = "Marthix" },
        { name = "Swift" },
        { name = "Boofuls" },
        { name = "Diva" },
        { name = "Rondo Media" },
    },
    supporters = {
        { name = "Diva", classFile = "PRIEST" },
        { name = "Feralus", classFile = "DRUID" },
        { name = "Jarvis", classFile = "MAGE" },
        { name = "Savs", classFile = "SHAMAN" },
        { name = "Vukolak", classFile = "WARLOCK" },
        { name = "Boofuls", classFile = "PALADIN" },
        { name = "SubtleGrind" },
    },
    translators = {
        { name = "Aishuu", locale = "frFR" },
        { name = "????-??", locale = "koKR" },
        { name = "Linho-Gallywix", locale = "ptBR" },
        { name = "allmoon", locale = "zhCN" },
    },
}
