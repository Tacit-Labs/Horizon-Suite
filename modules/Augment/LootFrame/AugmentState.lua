--[[
    Horizon Suite - Augment - State
    Runtime state and DB accessors for loot toasts. Blizzard: CHAT_MSG_LOOT, C_CurrencyInfo.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Augment = addon.Augment or {}
addon.augment = addon.augment or {}

local Y = addon.Augment
local y = addon.augment

-- ============================================================================
-- CONSTANTS
-- ============================================================================

Y.FONT_PATH       = "Fonts\\FRIZQT__.TTF"  -- ultimate fallback; prefer Y.GetFontPath()
Y.FONT_SIZE       = 16

local FONT_USE_GLOBAL = "__global__"

-- Resolve the active font path for Augment loot toasts. Mirrors VistaCore.ResolveFont
-- (modules/Vista/VistaCore.lua) and InsightShared (modules/Insight/InsightShared.lua):
-- per-module DB key → global fontPath DB → addon.GetDefaultFontPath() → Y.FONT_PATH.
-- @return string font file path
function Y.GetFontPath()
    local global = addon.GetActiveGlobalFont and addon.GetActiveGlobalFont()
    if global then return global end
    local raw = (addon.GetDB and addon.GetDB("augmentFontPath", FONT_USE_GLOBAL)) or FONT_USE_GLOBAL
    if raw == FONT_USE_GLOBAL or raw == nil or raw == "" then
        raw = (addon.GetDB and addon.GetDB("fontPath", nil)) or nil
    end
    if not raw or raw == "" or raw == FONT_USE_GLOBAL then
        return (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or Y.FONT_PATH
    end
    if addon.ResolveFontPath then
        local resolved = addon.ResolveFontPath(raw)
        if resolved and resolved ~= "" then return resolved end
    end
    return raw
end
Y.ICON_SIZE       = 34
Y.BORDER_PAD      = 1
Y.ENTRY_HEIGHT    = 38
Y.TEXT_WIDTH      = 300
Y.ICON_GAP        = 10
Y.TOTAL_WIDTH     = (Y.ICON_SIZE + Y.BORDER_PAD * 2) + Y.ICON_GAP + Y.TEXT_WIDTH
Y.LINE_SPACING    = 5
Y.LINE_HEIGHT     = Y.ENTRY_HEIGHT + Y.LINE_SPACING
Y.POOL_SIZE       = 15

Y.DEFAULT_ANCHOR  = "BOTTOMRIGHT"
Y.DEFAULT_X       = -30
Y.DEFAULT_Y       = 250

Y.ENTRANCE_DUR    = 0.3
Y.EXIT_DUR        = 0.5
Y.SLIDE_DIST      = 20
Y.EXIT_DRIFT      = 10
Y.NUDGE_SPEED     = 10

Y.HOLD_ITEM       = 5.0
Y.HOLD_EPIC       = 6.5
Y.HOLD_LEGENDARY  = 8.0
Y.HOLD_MONEY      = 3.0
Y.HOLD_CURRENCY   = 3.0
Y.HOLD_REP        = 3.0

Y.ENTRANCE_DUR_EPIC      = 0.45
Y.ENTRANCE_DUR_LEGENDARY = 0.6
Y.POP_SCALE_START        = 0.75
Y.POP_SCALE_PEAK_EPIC    = 1.12
Y.POP_SCALE_PEAK_LEGEND  = 1.18
Y.POP_SETTLE_FRAC        = 0.35
Y.BORDER_PULSE_SPEED     = 2.2
Y.BORDER_PULSE_ALPHA     = 0.45
Y.FLASH_DUR              = 0.15

Y.SOUND_EPIC      = (SOUNDKIT and SOUNDKIT.UI_CHALLENGES_NEW_RECORD) or 33338
Y.SOUND_LEGENDARY = (SOUNDKIT and SOUNDKIT.UI_LEGENDARY_LOOT_TOAST) or 63971
Y.SOUND_MONEY     = (SOUNDKIT and SOUNDKIT.UI_BNET_TOAST_DEFAULT) or 80638
Y.SOUND_CURRENCY  = (SOUNDKIT and SOUNDKIT.UI_BNET_TOAST_DEFAULT) or 80638
Y.SOUND_REP       = (SOUNDKIT and SOUNDKIT.UI_BNET_TOAST_DEFAULT) or 80638

Y.QUALITY_COLORS = {
    [0] = {0.62, 0.62, 0.62},
    [1] = {1.00, 1.00, 1.00},
    [2] = {0.12, 1.00, 0.00},
    [3] = {0.00, 0.44, 0.87},
    [4] = {0.64, 0.21, 0.93},
    [5] = {1.00, 0.50, 0.00},
    [6] = {0.90, 0.80, 0.50},
    [7] = {0.00, 0.80, 1.00},
    [8] = {0.00, 0.80, 1.00},
}

Y.MONEY_COLOR     = {1.00, 0.84, 0.00}
Y.CURRENCY_COLOR  = {0.40, 0.80, 1.00}
Y.REP_GAIN_COLOR  = {0.00, 0.80, 0.40}
Y.REP_LOSS_COLOR  = {0.80, 0.20, 0.20}

Y.MONEY_ICON      = "Interface\\Icons\\INV_Misc_Coin_02"
Y.REP_ICON        = "Interface\\Icons\\Achievement_Reputation_01"
Y.UNKNOWN_ICON    = "Interface\\Icons\\INV_Misc_QuestionMark"

-- ============================================================================
-- RUNTIME STATE (addon.augment)
-- ============================================================================

y.pool           = y.pool or {}
y.activeCount    = y.activeCount or 0
y.patternsOK     = y.patternsOK or false
y.playerGUID     = y.playerGUID
y.debugMode      = y.debugMode or false
y.editMode       = y.editMode or false
y.nativeEditMode = y.nativeEditMode or false

-- ============================================================================
-- DB ACCESSORS
-- ============================================================================

-- ============================================================================
-- DB KEY REGISTRY
-- Add any new Augment DB key here so OptionsData.lua reacts to it without
-- needing its own manual allowlist.
-- ============================================================================

Y.DB_KEYS = {
    augmentPoint            = true,
    augmentRelPoint         = true,
    augmentX                = true,
    augmentY                = true,
    augmentFontPath         = true,
    augmentShowItems        = true,
    augmentShowMoney        = true,
    augmentShowCurrency     = true,
    augmentShowRep          = true,
    augmentMinQuality       = true,
    augmentToastOpacity     = true,
    augmentMaxVisible       = true,
    augmentHoldItem         = true,
    augmentHoldEpic         = true,
    augmentHoldLegendary    = true,
    augmentHoldMoney        = true,
    augmentHoldCurrency     = true,
    augmentHoldRep          = true,
    augmentTextOutline      = true,
    augmentTextOutlineType  = true,
    augmentSoundEnabled     = true,
    augmentSoundChannel     = true,
    augmentSoundItems       = true,
    augmentSoundMoney       = true,
    augmentSoundCurrency    = true,
    augmentSoundRep         = true,
    augmentEditModeShow     = true,
    augmentLootFrameEnabled = true,
    -- SelfHighlight and AutoVendor mini-modules append their own keys below.
}

-- Return the hold duration for a toast, reading from DB when available.
-- Falls back to the module constants so behaviour is unchanged with no saved value.
-- @param kind string  "item"|"money"|"currency"|"rep"
-- @param quality number|nil  item quality (only relevant for kind=="item")
-- @return number seconds
function Y.GetHoldDur(kind, quality)
    local D = addon.AUGMENT_DEFAULTS
    if kind == "money" then
        return (addon.GetDB and tonumber(addon.GetDB("augmentHoldMoney",    D.augmentHoldMoney)))    or D.augmentHoldMoney
    elseif kind == "currency" then
        return (addon.GetDB and tonumber(addon.GetDB("augmentHoldCurrency", D.augmentHoldCurrency))) or D.augmentHoldCurrency
    elseif kind == "rep" then
        return (addon.GetDB and tonumber(addon.GetDB("augmentHoldRep",      D.augmentHoldRep)))      or D.augmentHoldRep
    else
        if quality == 5 then
            return (addon.GetDB and tonumber(addon.GetDB("augmentHoldLegendary", D.augmentHoldLegendary))) or D.augmentHoldLegendary
        elseif quality == 4 then
            return (addon.GetDB and tonumber(addon.GetDB("augmentHoldEpic",      D.augmentHoldEpic)))      or D.augmentHoldEpic
        end
        return (addon.GetDB and tonumber(addon.GetDB("augmentHoldItem", D.augmentHoldItem))) or D.augmentHoldItem
    end
end

-- Get position from profile (or defaults).
-- @return point string|nil, relPoint string|nil, x number|nil, y number|nil
function Y.GetPosition()
    if not addon.GetDB then
        return nil, nil, Y.DEFAULT_X, Y.DEFAULT_Y
    end
    local pt = addon.GetDB("augmentPoint", nil)
    local rp = addon.GetDB("augmentRelPoint", nil)
    local px = addon.GetDB("augmentX", Y.DEFAULT_X)
    local py = addon.GetDB("augmentY", Y.DEFAULT_Y)
    return pt, rp, px, py
end

-- Save frame position to active profile.
-- @param point string
-- @param relPoint string
-- @param x number
-- @param y number
-- @return nil
function Y.SavePosition(point, relPoint, x, y)
    if not addon.SetDB then return end
    addon.SetDB("augmentPoint", point)
    addon.SetDB("augmentRelPoint", relPoint)
    addon.SetDB("augmentX", x)
    addon.SetDB("augmentY", y)
end

-- Clear saved position.
-- @return nil
function Y.ClearPosition()
    if not addon.SetDB then return end
    addon.SetDB("augmentPoint", nil)
    addon.SetDB("augmentRelPoint", nil)
    addon.SetDB("augmentX", nil)
    addon.SetDB("augmentY", nil)
end
