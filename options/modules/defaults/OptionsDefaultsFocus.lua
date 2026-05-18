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

addon.COLOR_KEYS_ORDER        = COLOR_KEYS_ORDER
addon.ZONE_COLOR_DEFAULT      = ZONE_COLOR_DEFAULT
addon.OBJ_COLOR_DEFAULT       = OBJ_COLOR_DEFAULT
addon.OBJ_DONE_COLOR_DEFAULT  = OBJ_DONE_COLOR_DEFAULT
addon.HIGHLIGHT_COLOR_DEFAULT = HIGHLIGHT_COLOR_DEFAULT

-- SetDB routing keys: trigger ApplyMplusTypography / UpdateMplusBlock / click config
addon.FOCUS_CLICK_KEYS = {
    focusClickProfile     = true,
    focusIconClickAction  = true,
    focusClick_left       = true,
    focusClick_shiftLeft  = true,
    focusClick_ctrlLeft   = true,
    focusClick_altLeft    = true,
    focusClick_right      = true,
    focusClick_shiftRight = true,
    focusClick_ctrlRight  = true,
    focusClick_altRight   = true,
}

-- Keys whose values are baked into |cff...|r markup inside UpdateMplusBlockDisplay;
-- changing one requires re-running the display, not just ApplyMplusTypography.
addon.MPLUS_EMBEDDED_MARKUP_KEYS = {
    mplusShowSplitTimer  = true,
    mplusSplitColorR     = true, mplusSplitColorG     = true, mplusSplitColorB     = true,
    mplusSplitPastColorR = true, mplusSplitPastColorG = true, mplusSplitPastColorB = true,
}

addon.MPLUS_TYPOGRAPHY_KEYS = {
    fontPath     = true,
    fontOutline  = true,
    shadowOffsetX = true,
    shadowOffsetY = true,
    showTextShadow = true,
    shadowAlpha  = true,
    mplusDungeonSize   = true,
    mplusDungeonColorR = true, mplusDungeonColorG = true, mplusDungeonColorB = true,
    mplusTimerSize          = true,
    mplusTimerColorR        = true, mplusTimerColorG        = true, mplusTimerColorB        = true,
    mplusTimerOvertimeColorR = true, mplusTimerOvertimeColorG = true, mplusTimerOvertimeColorB = true,
    mplusShowSplitTimer = true,
    mplusSplitSize      = true,
    mplusSplitColorR    = true, mplusSplitColorG    = true, mplusSplitColorB    = true,
    mplusSplitPastColorR = true, mplusSplitPastColorG = true, mplusSplitPastColorB = true,
    mplusProgressSize   = true,
    mplusProgressColorR = true, mplusProgressColorG = true, mplusProgressColorB = true,
    mplusAffixSize      = true,
    mplusAffixColorR    = true, mplusAffixColorG    = true, mplusAffixColorB    = true,
    mplusBossSize       = true,
    mplusBossColorR     = true, mplusBossColorG     = true, mplusBossColorB     = true,
    mplusBarColorR      = true, mplusBarColorG      = true, mplusBarColorB      = true, mplusBarColorA      = true,
    mplusBarDoneColorR  = true, mplusBarDoneColorG  = true, mplusBarDoneColorB  = true, mplusBarDoneColorA  = true,
}
