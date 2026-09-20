--[[
    Horizon Suite - Augment / Loot Roll - State
    Constants, DB key registry and accessors for the group loot roll frames.

    Roll types are Blizzard's button IDs, taken from GroupLootFrame.xml where
    each LootRollButtonTemplate calls RollOnLoot(rollID, self:GetID()):
    Pass 0 · Need 1 · Greed 2 · Disenchant 3 · Transmog 4. These are NOT the
    same numbers as Enum.EncounterLootDropRollState, which describes a roll
    already made and is handled in AugmentRollTally.lua.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment then return end

local Y = addon.Augment
Y.Roll = Y.Roll or {}
local R = Y.Roll

-- ============================================================================
-- DB KEY REGISTRY
-- Registered into Augment's shared routing table so OptionsData.lua dispatches
-- writes without its own allowlist (same as Alerts does in AugmentAlertsState).
-- ============================================================================

Y.DB_KEYS.augmentLootRollEnabled = true
Y.DB_KEYS.lootRollScale          = true
Y.DB_KEYS.lootRollOpacity        = true
Y.DB_KEYS.lootRollToastStyle     = true
Y.DB_KEYS.lootRollFontPath       = true
Y.DB_KEYS.lootRollFontSize       = true
Y.DB_KEYS.lootRollTextOutlineType = true
Y.DB_KEYS.lootRollIconSize       = true
Y.DB_KEYS.lootRollIconGap        = true
Y.DB_KEYS.lootRollIconSide       = true
Y.DB_KEYS.lootRollGrowDirection  = true
Y.DB_KEYS.lootRollMaxVisible     = true
Y.DB_KEYS.lootRollShowTally      = true
Y.DB_KEYS.lootRollShowBadgeAppearance = true
Y.DB_KEYS.lootRollShowBadgeItemLevel  = true
Y.DB_KEYS.lootRollShowBadgeBind       = true
Y.DB_KEYS.lootRollMinQuality     = true
Y.DB_KEYS.lootRollEditModeShow   = true
Y.DB_KEYS.lootRollDebugLive      = true
Y.DB_KEYS.lootRollPoint          = true
Y.DB_KEYS.lootRollRelPoint       = true
Y.DB_KEYS.lootRollX              = true
Y.DB_KEYS.lootRollY              = true

-- ============================================================================
-- CONSTANTS
-- ============================================================================

-- Blizzard button IDs for RollOnLoot's rollType argument.
R.ROLL_PASS       = 0
R.ROLL_NEED       = 1
R.ROLL_GREED      = 2
R.ROLL_DISENCHANT = 3
R.ROLL_TRANSMOG   = 4

-- Blizzard shows at most 4 group loot frames (NUM_GROUP_LOOT_FRAMES) and
-- queues the rest. We pool the same number for the same reason: more than
-- four simultaneous rolls on screen is unreadable, not more useful.
R.POOL_SIZE    = 4

R.WIDTH        = 330
R.ICON_SIZE    = 40
R.ICON_BG_PAD  = 1
R.ICON_GAP     = 10
R.LINE_SPACING = 6
R.TIMER_HEIGHT = 4
R.BUTTON_SIZE  = 26
R.BUTTON_GAP   = 4
-- Row height: icon + chrome headroom, plus a line for the tally/badge strip
-- and the timer bar beneath it.
R.ROW_PAD      = 22

R.DEFAULT_ANCHOR = "CENTER"
R.DEFAULT_X      = 0
R.DEFAULT_Y      = 180

-- Button art. Blizzard's own textures so the icons read as the same action
-- even though the chrome around them is ours.
R.BUTTON_TEXTURES = {
    [R.ROLL_NEED]       = "Interface\\Buttons\\UI-GroupLoot-Dice-Up",
    [R.ROLL_GREED]      = "Interface\\Buttons\\UI-GroupLoot-Coin-Up",
    [R.ROLL_DISENCHANT] = "Interface\\Buttons\\UI-GroupLoot-DE-Up",
    [R.ROLL_TRANSMOG]   = "Interface\\Buttons\\UI-GroupLoot-Transmog-Up",
    [R.ROLL_PASS]       = "Interface\\Buttons\\UI-GroupLoot-Pass-Up",
}

R.QUALITY_COLORS = Y.QUALITY_COLORS

-- ============================================================================
-- DB ACCESSORS
-- ============================================================================

-- Explicit nil-check so a stored `false` is not replaced by the default.
local function getDB(k, d)
    if not addon.GetDB then return d end
    local v = addon.GetDB(k, d)
    if v == nil then return d end
    return v
end
R.GetDB = getDB

local function clamped(key, fallback)
    local D = addon.AUGMENT_DEFAULTS
    local lim = addon.AUGMENT_LIMITS and addon.AUGMENT_LIMITS[key]
    local v = tonumber(getDB(key, D[key])) or fallback
    if lim then return math.max(lim.min, math.min(lim.max, v)) end
    return v
end

--- @return string styleID "compact", "framed", or "accent"
function R.GetToastStyle()
    local D = addon.AUGMENT_DEFAULTS
    local raw = getDB("lootRollToastStyle", D.lootRollToastStyle)
    local TS = Y.ToastStyles
    return (TS and TS.Normalize and TS.Normalize(raw)) or "framed"
end

--- @return number
function R.GetIconSize() return clamped("lootRollIconSize", 40) end

--- @return number
function R.GetIconGap() return clamped("lootRollIconGap", 10) end

--- @return number
function R.GetScale() return clamped("lootRollScale", 1.0) end

--- @return number 0..1
function R.GetOpacity()
    return math.max(0.1, math.min(1.0, clamped("lootRollOpacity", 100) / 100))
end

--- @return string "left"|"right"
function R.GetIconSide()
    local D = addon.AUGMENT_DEFAULTS
    return (getDB("lootRollIconSide", D.lootRollIconSide) == "right") and "right" or "left"
end

--- @return string "up"|"down"
function R.GetGrowDirection()
    local D = addon.AUGMENT_DEFAULTS
    return (getDB("lootRollGrowDirection", D.lootRollGrowDirection) == "up") and "up" or "down"
end

-- Vertical attach edge for roll rows. Mirrors Alerts' GetEntryAttachPoint.
--- @return string "TOP"|"BOTTOM"
function R.GetEntryAttachPoint()
    return (R.GetGrowDirection() == "up") and "BOTTOM" or "TOP"
end

--- @return number
function R.GetMaxVisible()
    return math.max(1, math.min(R.POOL_SIZE, clamped("lootRollMaxVisible", 4)))
end

--- Minimum item quality a roll must be to get a Horizon frame. Rolls below it
--- fall through to Blizzard's own frame rather than vanishing — see
--- AugmentRollEvents.lua, which only suppresses what it is going to draw.
--- @return number
function R.GetMinQuality()
    local D = addon.AUGMENT_DEFAULTS
    return tonumber(getDB("lootRollMinQuality", D.lootRollMinQuality)) or 0
end

--- @return boolean
function R.IsTallyEnabled()
    local D = addon.AUGMENT_DEFAULTS
    if not (addon.Platform and addon.Platform.Has("lootHistory")) then return false end
    return getDB("lootRollShowTally", D.lootRollShowTally) ~= false
end

--- @param which string "Appearance"|"ItemLevel"|"Bind"
--- @return boolean
function R.IsBadgeEnabled(which)
    local D = addon.AUGMENT_DEFAULTS
    local key = "lootRollShowBadge" .. which
    return getDB(key, D[key]) ~= false
end

-- ============================================================================
-- FONT
-- Resolution order matches Alerts and Loot: per-element key → global font DB →
-- addon default → Blizzard fallback.
-- ============================================================================

local FONT_USE_GLOBAL = "__global__"

--- @return string
function R.GetFontPath()
    local global = addon.GetActiveGlobalFont and addon.GetActiveGlobalFont()
    if global then return global end
    local D = addon.AUGMENT_DEFAULTS
    local raw = getDB("lootRollFontPath", D.lootRollFontPath)
    if raw == FONT_USE_GLOBAL or raw == nil or raw == "" then
        raw = (addon.GetDB and addon.GetDB("fontPath", nil)) or nil
    end
    if not raw or raw == "" or raw == FONT_USE_GLOBAL then
        return (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"
    end
    if addon.ResolveFontPath then
        local resolved = addon.ResolveFontPath(raw)
        if resolved and resolved ~= "" then return resolved end
    end
    return raw
end

--- @return number
function R.GetFontSize() return clamped("lootRollFontSize", 13) end

--- @return string
function R.GetFontFlags()
    local D = addon.AUGMENT_DEFAULTS
    return getDB("lootRollTextOutlineType", D.lootRollTextOutlineType) or "OUTLINE"
end

-- ============================================================================
-- POSITION
-- Own keys, so the roll stack anchors independently of both the loot toast
-- stack (augmentPoint/…) and the Alerts stack (alertsPoint/…).
-- ============================================================================

function R.GetPosition()
    if not addon.GetDB then
        return nil, nil, R.DEFAULT_X, R.DEFAULT_Y
    end
    return addon.GetDB("lootRollPoint", nil),
           addon.GetDB("lootRollRelPoint", nil),
           addon.GetDB("lootRollX", R.DEFAULT_X),
           addon.GetDB("lootRollY", R.DEFAULT_Y)
end

function R.SavePosition(point, relPoint, x, y)
    if not addon.SetDB then return end
    addon.SetDB("lootRollPoint", point)
    addon.SetDB("lootRollRelPoint", relPoint)
    addon.SetDB("lootRollX", x)
    addon.SetDB("lootRollY", y)
end

function R.ClearPosition()
    if not addon.SetDB then return end
    addon.SetDB("lootRollPoint", nil)
    addon.SetDB("lootRollRelPoint", nil)
    addon.SetDB("lootRollX", nil)
    addon.SetDB("lootRollY", nil)
end

-- ============================================================================
-- SAFE STRING
-- WoW can hand event payloads "secret string" values that throw on any string
-- method. Player names from loot history arrive from the server and go through
-- here before any concat. Same contract as A.SafeString in Alerts.
-- ============================================================================

function R.SafeString(v)
    if v == nil then return "" end
    local ok, s = pcall(tostring, v)
    if not ok or type(s) ~= "string" then return "" end
    local ok2, cleaned = pcall(function() return (s:gsub("%z", "")) end)
    if ok2 and type(cleaned) == "string" then return cleaned end
    return ""
end
