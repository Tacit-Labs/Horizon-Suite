--[[
    Horizon Suite - Essence - Options categories
    Self-registers into addon.OptionCategories after OptionsData.lua runs.
]]
local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L = addon.L
local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end
local Section = addon.Section
local Button  = addon.Button
local Toggle  = addon.Toggle
local D   = addon.ESSENCE_DEFAULTS
local LIM = addon.ESSENCE_LIMITS
local function clamp(v, key) local lim = LIM[key]; return math.max(lim.min, math.min(lim.max, v)) end

local categories = {
    {
        key       = "Essence",
        name      = L["AXIS_MODULE_NAME_SIMPLE_CHARACTER"],
        desc      = L["ESSENCE_DESC"],
        moduleKey = "essence",
        options   = {
            Section(L["AXIS_POSITION"]),
            Toggle(L["ESSENCE_LOCK_POSITION"], L["ESSENCE_LOCK_POSITION_DESC"], "essenceLockPosition", D.essenceLockPosition),
            Button(L["AXIS_RESET_POSITION"], L["ESSENCE_RESET_POSITION_DESC"], function()
                setDB("essencePoint", D.essencePoint); setDB("essenceX", D.essenceX); setDB("essenceY", D.essenceY)
                if addon.Essence and addon.Essence.ApplyPosition then addon.Essence.ApplyPosition(true) end
            end),
            Section(L["DASH_APPEARANCE"]),
            Toggle(L["ESSENCE_PVP_TITLE"],   L["ESSENCE_PVP_TITLE_DESC"],   "essenceShowTitle",     D.essenceShowTitle),
            Toggle(L["ESSENCE_STAT_BARS"],   L["ESSENCE_STAT_BARS_DESC"],   "essenceShowStatBars",  D.essenceShowStatBars),
            Toggle(L["ESSENCE_ILVL_BADGE"],  L["ESSENCE_ILVL_BADGE_DESC"],  "essenceShowIlvlBadge", D.essenceShowIlvlBadge),
            { type = "slider", name = L["ESSENCE_STAT_CAP"], desc = L["ESSENCE_STAT_CAP_DESC"], dbKey = "essenceStatCap", min = LIM.essenceStatCap.min, max = LIM.essenceStatCap.max, step = 5, get = function() return tonumber(getDB("essenceStatCap", D.essenceStatCap)) or D.essenceStatCap end, set = function(v) setDB("essenceStatCap", clamp(v, "essenceStatCap")) end },
        },
    },
}

for i = 1, #categories do
    addon.OptionCategories[#addon.OptionCategories + 1] = categories[i]
end
