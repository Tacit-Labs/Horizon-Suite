--[[
    Horizon Suite - Augment / Loot Roll - Item context badges
    Short markers on the roll frame answering "is this worth anything to me"
    before the timer runs out: a new appearance, an item level delta against
    what you have equipped, and whether it binds on pickup.

    Every badge is independent. Each returns nil when its capability is absent,
    when its option is off, or when it has nothing to say — so a client missing
    one system loses one badge, not the strip.

    GetItemInfo and GetSpellInfo do not exist on Forever. C_Item.GetItemInfo is
    used throughout (see Docs/Engineering/2026-09-18-forever-platform-capabilities.md).
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment or not addon.Augment.Roll then return end

local R = addon.Augment.Roll
R.Badges = R.Badges or {}
local B = R.Badges
local L = addon.L

local function Has(capability)
    return addon.Platform and addon.Platform.Has(capability)
end

local COLOR_GOOD    = "|cFF40C040"
local COLOR_BAD     = "|cFFC04040"
local COLOR_NEUTRAL = "|cFFAAAAAA"
local COLOR_MOG     = "|cFFFF80FF"

-- ============================================================================
-- APPEARANCE
-- ============================================================================

--- "New look" when this item's appearance is not yet collected.
--- Transmog is present on both clients (237 head appearances confirmed on the
--- Forever beta), so this is capability-gated rather than client-branched.
--- @param itemLink string|nil
--- @return string|nil
function B.Appearance(itemLink)
    if not itemLink or itemLink == "" then return nil end
    if not Has("transmog") then return nil end
    if not R.IsBadgeEnabled("Appearance") then return nil end
    if not (C_TransmogCollection and C_TransmogCollection.PlayerHasTransmogByItemInfo) then return nil end

    local ok, known = pcall(C_TransmogCollection.PlayerHasTransmogByItemInfo, itemLink)
    -- A nil answer means "cannot tell" (not a transmoggable item, or the client
    -- declined). Only the definite "you do not have this" earns a badge.
    if not ok or known ~= false then return nil end

    return COLOR_MOG .. ((L and L["LOOT_ROLL_BADGE_NEW_APPEARANCE"]) or "New look") .. "|r"
end

-- ============================================================================
-- ITEM LEVEL
-- ============================================================================

-- Equipment slot name → inventory slot IDs to compare against. Two-slot cases
-- compare against the weaker side, which is the honest comparison: replacing
-- your worse ring is what an upgrade actually does.
local SLOT_IDS = {
    INVTYPE_HEAD            = { 1 },
    INVTYPE_NECK            = { 2 },
    INVTYPE_SHOULDER        = { 3 },
    INVTYPE_BODY            = { 4 },
    INVTYPE_CHEST           = { 5 },
    INVTYPE_ROBE            = { 5 },
    INVTYPE_WAIST           = { 6 },
    INVTYPE_LEGS            = { 7 },
    INVTYPE_FEET            = { 8 },
    INVTYPE_WRIST           = { 9 },
    INVTYPE_HAND            = { 10 },
    INVTYPE_FINGER          = { 11, 12 },
    INVTYPE_TRINKET         = { 13, 14 },
    INVTYPE_CLOAK           = { 15 },
    INVTYPE_WEAPON          = { 16, 17 },
    INVTYPE_2HWEAPON        = { 16 },
    INVTYPE_WEAPONMAINHAND  = { 16 },
    INVTYPE_WEAPONOFFHAND   = { 17 },
    INVTYPE_HOLDABLE        = { 17 },
    INVTYPE_SHIELD          = { 17 },
    INVTYPE_RANGED          = { 16 },
    INVTYPE_RANGEDRIGHT     = { 16 },
}

local function EquippedLevel(slotID)
    local link = GetInventoryItemLink and GetInventoryItemLink("player", slotID)
    if not link then return nil end
    local ok, _, _, _, level = pcall(C_Item.GetItemInfo, link)
    if not ok then return nil end
    return tonumber(level)
end

--- Item level delta against the matching equipped slot, e.g. "+13 ilvl".
--- Deliberately NOT a spec-aware "upgrade" judgement: that needs `specs`, which
--- Forever does not have, and the raw delta answers most of the question on
--- both clients without forking.
--- @param itemLink string|nil
--- @return string|nil
function B.ItemLevel(itemLink)
    if not itemLink or itemLink == "" then return nil end
    if not R.IsBadgeEnabled("ItemLevel") then return nil end
    if not (C_Item and C_Item.GetItemInfo) then return nil end

    local ok, _, _, _, level, _, _, _, _, equipSlot = pcall(C_Item.GetItemInfo, itemLink)
    if not ok then return nil end
    level = tonumber(level)
    if not level or level <= 0 then return nil end

    local slots = equipSlot and SLOT_IDS[equipSlot]
    if not slots then return nil end

    -- Compare against the weakest thing currently filling the slot. An empty
    -- slot counts as zero-but-unknown: nothing to compare, so no badge.
    local lowest
    for _, slotID in ipairs(slots) do
        local equipped = EquippedLevel(slotID)
        if equipped then
            if not lowest or equipped < lowest then lowest = equipped end
        end
    end
    if not lowest then return nil end

    local delta = level - lowest
    if delta == 0 then return nil end

    local label = (L and L["LOOT_ROLL_BADGE_ILVL"]) or "ilvl"
    local color = delta > 0 and COLOR_GOOD or COLOR_BAD
    return ("%s%+d %s|r"):format(color, delta, label)
end

-- ============================================================================
-- BIND
-- ============================================================================

--- "BoP" when winning the roll would bind the item to you.
--- Reads the flag from the roll info rather than the item, because that is what
--- the roll itself reports (GetLootRollItemInfo's fifth return).
--- @param bindOnPickUp boolean|nil
--- @return string|nil
function B.Bind(bindOnPickUp)
    if not bindOnPickUp then return nil end
    if not R.IsBadgeEnabled("Bind") then return nil end
    return COLOR_NEUTRAL .. ((L and L["LOOT_ROLL_BADGE_BOP"]) or "BoP") .. "|r"
end

-- ============================================================================
-- STRIP
-- ============================================================================

--- Build the badge strip for a roll.
--- @param roll table  Roll descriptor (see AugmentRollEvents.lua BuildRoll)
--- @return string  "" when no badge has anything to say
function B.Build(roll)
    if type(roll) ~= "table" then return "" end
    local parts = {}
    local appearance = B.Appearance(roll.itemLink)
    if appearance then parts[#parts + 1] = appearance end
    local ilvl = B.ItemLevel(roll.itemLink)
    if ilvl then parts[#parts + 1] = ilvl end
    local bind = B.Bind(roll.bindOnPickUp)
    if bind then parts[#parts + 1] = bind end
    return table.concat(parts, "  ")
end
