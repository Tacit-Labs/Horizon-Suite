--[[
    Horizon Suite - Essence - Options categories
    Self-registers into addon.OptionCategories after OptionsData.lua runs.
]]
local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L = addon.L
local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end

local categories = {
    {
        key       = "Essence",
        name      = L["AXIS_MODULE_NAME_SIMPLE_CHARACTER"],
        desc      = L["ESSENCE_DESC"],
        moduleKey = "essence",
        options   = {
            { type = "section", name = L["AXIS_POSITION"] },
            { type = "toggle", name = L["ESSENCE_LOCK_POSITION"], desc = L["ESSENCE_LOCK_POSITION_DESC"], dbKey = "essenceLockPosition", get = function() return getDB("essenceLockPosition", false) end, set = function(v) setDB("essenceLockPosition", v) end },
            { type = "button", name = L["AXIS_RESET_POSITION"], desc = L["ESSENCE_RESET_POSITION_DESC"], onClick = function()
                setDB("essencePoint", "CENTER"); setDB("essenceX", 0); setDB("essenceY", 0)
                if addon.Essence and addon.Essence.ApplyPosition then addon.Essence.ApplyPosition(true) end
            end },
            { type = "section", name = L["DASH_APPEARANCE"] },
            { type = "toggle", name = L["ESSENCE_PVP_TITLE"], desc = L["ESSENCE_PVP_TITLE_DESC"], dbKey = "essenceShowTitle", get = function() return getDB("essenceShowTitle", true) end, set = function(v) setDB("essenceShowTitle", v) end },
            { type = "toggle", name = L["ESSENCE_STAT_BARS"], desc = L["ESSENCE_STAT_BARS_DESC"], dbKey = "essenceShowStatBars", get = function() return getDB("essenceShowStatBars", true) end, set = function(v) setDB("essenceShowStatBars", v) end },
            { type = "toggle", name = L["ESSENCE_ILVL_BADGE"], desc = L["ESSENCE_ILVL_BADGE_DESC"], dbKey = "essenceShowIlvlBadge", get = function() return getDB("essenceShowIlvlBadge", true) end, set = function(v) setDB("essenceShowIlvlBadge", v) end },
            { type = "slider", name = L["ESSENCE_STAT_CAP"], desc = L["ESSENCE_STAT_CAP_DESC"], dbKey = "essenceStatCap", min = 20, max = 100, step = 5, get = function() return tonumber(getDB("essenceStatCap", 50)) or 50 end, set = function(v) setDB("essenceStatCap", math.max(20, math.min(100, v))) end },
        },
    },
}

for i = 1, #categories do
    addon.OptionCategories[#addon.OptionCategories + 1] = categories[i]
end
