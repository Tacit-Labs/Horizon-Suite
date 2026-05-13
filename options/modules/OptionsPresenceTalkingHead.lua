--[[
    Horizon Suite - Presence - Talking Head options category
    Self-registers into addon.OptionCategories after OptionsData.lua runs.
]]

local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L = addon.L
local D = addon.Presence.TalkingHeadDefaults

local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end

local function updateTalkingHead()
    if addon.Presence and addon.Presence.UpdateTalkingHead then
        addon.Presence.UpdateTalkingHead()
    end
end

local function isCustomising() return getDB("talkingHeadCustomise", D.talkingHeadCustomise) end

local FONT_USE_GLOBAL = "__global__"

local function GetFontOptions(dbKey)
    if addon.RefreshFontList then addon.RefreshFontList() end
    local list = (addon.GetFontList and addon.GetFontList()) or {}
    local out = { { L["FOCUS_GLOBAL_FONT"], FONT_USE_GLOBAL } }
    for i = 1, #list do out[#out + 1] = list[i] end
    local saved = getDB(dbKey, FONT_USE_GLOBAL)
    if saved == FONT_USE_GLOBAL then return out end
    for _, o in ipairs(out) do
        if o[2] == saved then return out end
    end
    out[#out + 1] = { L["FOCUS_CUSTOM"], saved }
    return out
end

local function DisplayFont(v)
    if v == FONT_USE_GLOBAL then return L["FOCUS_GLOBAL_FONT"] end
    return addon.GetFontNameForPath and addon.GetFontNameForPath(v) or v
end

local category = {
    key       = "PresenceTalkingHead",
    name      = L["TALKING_HEAD"],
    desc      = L["TALKING_HEAD_CATEGORY_DESC"],
    moduleKey = "presence",
    options   = {
        { type = "section", name = L["AXIS_GENERAL"] },
        {
            type  = "toggle",
            name  = L["TALKING_HEAD_ENABLE"],
            desc  = L["TALKING_HEAD_ENABLE_DESC"],
            dbKey = "talkingHeadEnabled",
            get   = function() return getDB("talkingHeadEnabled", D.talkingHeadEnabled) end,
            set   = function(value) setDB("talkingHeadEnabled", value); updateTalkingHead() end,
        },
        {
            type  = "toggle",
            name  = L["TALKING_HEAD_MUTE_VOICE"],
            desc  = L["TALKING_HEAD_MUTE_VOICE_DESC"],
            dbKey = "talkingHeadMuteVoice",
            get   = function() return getDB("talkingHeadMuteVoice", D.talkingHeadMuteVoice) end,
            set   = function(value) setDB("talkingHeadMuteVoice", value) end,
        },
        {
            type  = "toggle",
            name  = L["TALKING_HEAD_CUSTOMISE"],
            desc  = L["TALKING_HEAD_CUSTOMISE_DESC"],
            dbKey = "talkingHeadCustomise",
            get   = function() return getDB("talkingHeadCustomise", D.talkingHeadCustomise) end,
            set   = function(v) setDB("talkingHeadCustomise", v); updateTalkingHead() end,
            refreshIds = {
                "talkingHeadNameFontPath", "talkingHeadNameSize", "talkingHeadNameOutline", "talkingHeadNameColor",
                "talkingHeadTextFontPath", "talkingHeadTextSize", "talkingHeadTextOutline", "talkingHeadShowPortrait",
                "talkingHeadShowPortraitBorder", "talkingHeadBackground", "talkingHeadCloseButton", "talkingHeadScale",
                "talkingHeadContentSection", "talkingHeadFrameSection", "talkingHeadPreviewSection", "talkingHeadPreview",
            },
        },
        { type = "section", name = L["TALKING_HEAD_FRAME_CONTENT"], dbKey = "talkingHeadContentSection", visibleWhen = isCustomising },
        {
            type              = "dropdown",
            name              = L["TALKING_HEAD_NAME_FONT"],
            desc              = L["TALKING_HEAD_NAME_FONT_DESC"],
            dbKey             = "talkingHeadNameFontPath",
            searchable        = true,
            options           = function() return GetFontOptions("talkingHeadNameFontPath") end,
            get               = function() return getDB("talkingHeadNameFontPath", FONT_USE_GLOBAL) end,
            set               = function(v) setDB("talkingHeadNameFontPath", v); updateTalkingHead() end,
            refreshIds        = { "talkingHeadPreview" },
            displayFn         = DisplayFont,
            fontPreviewInList = true,
            visibleWhen       = isCustomising,
        },
        {
            type  = "slider",
            name  = L["TALKING_HEAD_NAME_SIZE"],
            desc  = L["TALKING_HEAD_NAME_SIZE_DESC"],
            dbKey = "talkingHeadNameSize",
            min   = 10,
            max   = 24,
            get        = function() return math.max(10, math.min(24, tonumber(getDB("talkingHeadNameSize", D.talkingHeadNameSize)) or D.talkingHeadNameSize)) end,
            set        = function(v) setDB("talkingHeadNameSize", math.max(10, math.min(24, v))); updateTalkingHead() end,
            refreshIds = { "talkingHeadPreview" },
            visibleWhen = isCustomising,
        },
        {
            type  = "toggle",
            name  = L["TALKING_HEAD_NAME_OUTLINE"],
            desc  = L["TALKING_HEAD_NAME_OUTLINE_DESC"],
            dbKey = "talkingHeadNameOutline",
            get        = function() return getDB("talkingHeadNameOutline", D.talkingHeadNameOutline) end,
            set        = function(v) setDB("talkingHeadNameOutline", v); updateTalkingHead() end,
            refreshIds = { "talkingHeadPreview" },
            visibleWhen = isCustomising,
        },
        {
            type    = "color",
            name    = L["TALKING_HEAD_NAME_COLOUR"],
            desc    = L["TALKING_HEAD_NAME_COLOUR_DESC"],
            dbKey   = "talkingHeadNameColor",
            default = { D.talkingHeadNameColorR, D.talkingHeadNameColorG, D.talkingHeadNameColorB },
            get        = function() return getDB("talkingHeadNameColorR", D.talkingHeadNameColorR), getDB("talkingHeadNameColorG", D.talkingHeadNameColorG), getDB("talkingHeadNameColorB", D.talkingHeadNameColorB) end,
            set        = function(r, g, b) setDB("talkingHeadNameColorR", r); setDB("talkingHeadNameColorG", g); setDB("talkingHeadNameColorB", b); updateTalkingHead() end,
            refreshIds = { "talkingHeadPreview" },
            visibleWhen = isCustomising,
        },
        {
            type              = "dropdown",
            name              = L["TALKING_HEAD_DIALOGUE_FONT"],
            desc              = L["TALKING_HEAD_DIALOGUE_FONT_DESC"],
            dbKey             = "talkingHeadTextFontPath",
            searchable        = true,
            options           = function() return GetFontOptions("talkingHeadTextFontPath") end,
            get               = function() return getDB("talkingHeadTextFontPath", FONT_USE_GLOBAL) end,
            set               = function(v) setDB("talkingHeadTextFontPath", v); updateTalkingHead() end,
            refreshIds        = { "talkingHeadPreview" },
            displayFn         = DisplayFont,
            fontPreviewInList = true,
            visibleWhen       = isCustomising,
        },
        {
            type  = "slider",
            name  = L["TALKING_HEAD_DIALOGUE_SIZE"],
            desc  = L["TALKING_HEAD_DIALOGUE_SIZE_DESC"],
            dbKey = "talkingHeadTextSize",
            min   = 10,
            max   = 20,
            get        = function() return math.max(10, math.min(20, tonumber(getDB("talkingHeadTextSize", D.talkingHeadTextSize)) or D.talkingHeadTextSize)) end,
            set        = function(v) setDB("talkingHeadTextSize", math.max(10, math.min(20, v))); updateTalkingHead() end,
            refreshIds = { "talkingHeadPreview" },
            visibleWhen = isCustomising,
        },
        {
            type  = "toggle",
            name  = L["TALKING_HEAD_DIALOGUE_OUTLINE"],
            desc  = L["TALKING_HEAD_DIALOGUE_OUTLINE_DESC"],
            dbKey = "talkingHeadTextOutline",
            get        = function() return getDB("talkingHeadTextOutline", D.talkingHeadTextOutline) end,
            set        = function(v) setDB("talkingHeadTextOutline", v); updateTalkingHead() end,
            refreshIds = { "talkingHeadPreview" },
            visibleWhen = isCustomising,
        },
        {
            type  = "toggle",
            name  = L["TALKING_HEAD_SHOW_PORTRAIT"],
            desc  = L["TALKING_HEAD_SHOW_PORTRAIT_DESC"],
            dbKey = "talkingHeadShowPortrait",
            get        = function() return getDB("talkingHeadShowPortrait", D.talkingHeadShowPortrait) end,
            set        = function(value) setDB("talkingHeadShowPortrait", value); updateTalkingHead() end,
            refreshIds = { "talkingHeadShowPortraitBorder", "talkingHeadPreview" },
            visibleWhen = isCustomising,
        },
        {
            type  = "toggle",
            name  = L["TALKING_HEAD_SHOW_PORTRAIT_BORDER"],
            desc  = L["TALKING_HEAD_SHOW_PORTRAIT_BORDER_DESC"],
            dbKey = "talkingHeadShowPortraitBorder",
            get        = function() return getDB("talkingHeadShowPortraitBorder", D.talkingHeadShowPortraitBorder) end,
            set        = function(value) setDB("talkingHeadShowPortraitBorder", value); updateTalkingHead() end,
            refreshIds = { "talkingHeadPreview" },
            visibleWhen = function() return isCustomising() and getDB("talkingHeadShowPortrait", D.talkingHeadShowPortrait) end,
        },
        { type = "section", name = L["TALKING_HEAD_FRAME"], dbKey = "talkingHeadFrameSection", visibleWhen = isCustomising },
        {
            type  = "toggle",
            name  = L["TALKING_HEAD_SHOW_BG"],
            desc  = L["TALKING_HEAD_SHOW_BG_DESC"],
            dbKey = "talkingHeadBackground",
            get   = function() return getDB("talkingHeadBackground", D.talkingHeadBackground) end,
            set   = function(value) setDB("talkingHeadBackground", value); updateTalkingHead() end,
            visibleWhen = isCustomising,
        },
        {
            type  = "toggle",
            name  = L["TALKING_HEAD_SHOW_CLOSE"],
            desc  = L["TALKING_HEAD_SHOW_CLOSE_DESC"],
            dbKey = "talkingHeadCloseButton",
            get   = function() return getDB("talkingHeadCloseButton", D.talkingHeadCloseButton) end,
            set   = function(value) setDB("talkingHeadCloseButton", value); updateTalkingHead() end,
            visibleWhen = isCustomising,
        },
        {
            type  = "slider",
            name  = L["TALKING_HEAD_SCALE"],
            desc  = L["TALKING_HEAD_SCALE_DESC"],
            dbKey = "talkingHeadScale",
            min   = 0.5,
            max   = 2.0,
            step  = 0.1,
            get         = function() return math.max(0.5, math.min(2.0, tonumber(getDB("talkingHeadScale", D.talkingHeadScale)) or D.talkingHeadScale)) end,
            set         = function(v) setDB("talkingHeadScale", math.max(0.5, math.min(2.0, v))); updateTalkingHead() end,
            visibleWhen = isCustomising,
        },
        { type = "section", name = L["TALKING_HEAD_CONTENT_PREVIEW"], dbKey = "talkingHeadPreviewSection", visibleWhen = isCustomising },
        { type = "talkingHeadPreview", visibleWhen = isCustomising },
    },
}

-- Insert after the last Presence category to preserve sidebar order
local insertAt = #addon.OptionCategories + 1
for i, cat in ipairs(addon.OptionCategories) do
    if cat.moduleKey == "presence" then insertAt = i + 1 end
end
table.insert(addon.OptionCategories, insertAt, category)
