--[[
    Horizon Suite - Essence - Options categories
    Self-registers into addon.OptionCategories after OptionsData.lua runs.
]]
local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end

local categories = {
    {
        key       = "Essence",
        name      = "Character Sheet",
        desc      = "Custom character panel with 3D model, item level, secondary stats, and gear slots.",
        moduleKey = "essence",
        options   = {
            { type = "section", name = "Position" },
            { type = "toggle", name = "Lock position", desc = "Prevent dragging the panel.", dbKey = "essenceLockPosition", get = function() return getDB("essenceLockPosition", false) end, set = function(v) setDB("essenceLockPosition", v) end },
            { type = "button", name = "Reset position", desc = "Snap the panel back to screen centre.", onClick = function()
                setDB("essencePoint", "CENTER"); setDB("essenceX", 0); setDB("essenceY", 0)
                if addon.Essence and addon.Essence.ApplyPosition then addon.Essence.ApplyPosition(true) end
            end },
            { type = "section", name = "Appearance" },
            { type = "toggle", name = "PvP title", desc = "Show the character's PvP title above the identity line.", dbKey = "essenceShowTitle", get = function() return getDB("essenceShowTitle", true) end, set = function(v) setDB("essenceShowTitle", v) end },
            { type = "toggle", name = "Secondary stat bars", desc = "Show Crit, Haste, Mastery, and Versatility bars.", dbKey = "essenceShowStatBars", get = function() return getDB("essenceShowStatBars", true) end, set = function(v) setDB("essenceShowStatBars", v) end },
            { type = "toggle", name = "Item level badge on gear slots", desc = "Show the item level on each equipped gear slot.", dbKey = "essenceShowIlvlBadge", get = function() return getDB("essenceShowIlvlBadge", true) end, set = function(v) setDB("essenceShowIlvlBadge", v) end },
            { type = "slider", name = "Stat bar cap (%)", desc = "The percentage shown as a full bar. Lower = more detail at common stat values.", dbKey = "essenceStatCap", min = 20, max = 100, step = 5, get = function() return tonumber(getDB("essenceStatCap", 50)) or 50 end, set = function(v) setDB("essenceStatCap", math.max(20, math.min(100, v))) end },
        },
    },
}

for i = 1, #categories do
    addon.OptionCategories[#addon.OptionCategories + 1] = categories[i]
end
