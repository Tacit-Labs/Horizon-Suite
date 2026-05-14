--[[
    Horizon Suite - Focus - Option color defaults
    Default values for Focus tracker color pickers, exported for use by
    OptionsWidgets (colorMatrixFull) and any code that reads these baselines.
]]
local addon = _G.HorizonSuite
if not addon then return end

-- Use addon.QUEST_COLORS from Config as single source for quest type colors.
local COLOR_KEYS_ORDER = { "DEFAULT", "CAMPAIGN", "IMPORTANT", "LEGENDARY", "WORLD", "DELVES", "SCENARIO", "RAID", "ACHIEVEMENT", "APPEARANCE", "WEEKLY", "PREY", "DAILY", "COMPLETE", "RARE" }
local ZONE_COLOR_DEFAULT     = { 0.55, 0.65, 0.75 }
local OBJ_COLOR_DEFAULT      = { 0.78, 0.78, 0.78 }
local OBJ_DONE_COLOR_DEFAULT = { 0.20, 1.00, 0.40 }  -- matches Ready to Turn In #33FF66
local HIGHLIGHT_COLOR_DEFAULT = { 0.4, 0.7, 1 }

addon.COLOR_KEYS_ORDER      = COLOR_KEYS_ORDER
addon.ZONE_COLOR_DEFAULT     = ZONE_COLOR_DEFAULT
addon.OBJ_COLOR_DEFAULT      = OBJ_COLOR_DEFAULT
addon.OBJ_DONE_COLOR_DEFAULT = OBJ_DONE_COLOR_DEFAULT
addon.HIGHLIGHT_COLOR_DEFAULT = HIGHLIGHT_COLOR_DEFAULT
