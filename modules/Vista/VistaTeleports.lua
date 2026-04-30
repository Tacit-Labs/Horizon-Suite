--[[
    Horizon Suite - Vista - Teleports
    Curated catalogue of teleport toys, items, and class spells, plus a helper
    that returns only those the current character has unlocked. Consumed by the
    Vista teleport proxy button (see VistaCore.lua DEFAULT_BTN_DEFS).
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

addon.Vista = addon.Vista or {}

local GROUP_ORDER = {
    hearthstone = 1,
    profession  = 2,
    class       = 3,
    event       = 4,
}

addon.Vista.TeleportCatalog = {
    -- Hearthstones (item + toys)
    { kind = "item",  id = 6948,   group = "hearthstone" }, -- Hearthstone
    { kind = "toy",   id = 110560, group = "hearthstone" }, -- Garrison Hearthstone
    { kind = "toy",   id = 140192, group = "hearthstone" }, -- Dalaran Hearthstone
    { kind = "toy",   id = 162973, group = "hearthstone" }, -- Greatfather Winter's Hearthstone
    { kind = "toy",   id = 163045, group = "hearthstone" }, -- Headless Horseman's Hearthstone
    { kind = "toy",   id = 165669, group = "hearthstone" }, -- Lunar Elder's Hearthstone
    { kind = "toy",   id = 165670, group = "hearthstone" }, -- Peddlefeet's Lovely Hearthstone
    { kind = "toy",   id = 166747, group = "hearthstone" }, -- Brewfest Reveler's Hearthstone
    { kind = "toy",   id = 168907, group = "hearthstone" }, -- Holographic Digitalization Hearthstone
    { kind = "toy",   id = 172179, group = "hearthstone" }, -- Eternal Traveler's Hearthstone
    { kind = "toy",   id = 180290, group = "hearthstone" }, -- Night Fae Hearthstone
    { kind = "toy",   id = 182773, group = "hearthstone" }, -- Necrolord Hearthstone
    { kind = "toy",   id = 183716, group = "hearthstone" }, -- Venthyr Sinstone
    { kind = "toy",   id = 184353, group = "hearthstone" }, -- Kyrian Hearthstone
    { kind = "toy",   id = 188952, group = "hearthstone" }, -- Dominated Hearthstone
    { kind = "toy",   id = 190196, group = "hearthstone" }, -- Enlightened Hearthstone
    { kind = "toy",   id = 190237, group = "hearthstone" }, -- Broker Translocation Matrix
    { kind = "toy",   id = 200630, group = "hearthstone" }, -- Ohn'ir Windsage's Hearthstone
    { kind = "toy",   id = 206195, group = "hearthstone" }, -- Path of the Naaru
    { kind = "toy",   id = 208704, group = "hearthstone" }, -- Deepdweller's Earthen Hearthstone
    { kind = "toy",   id = 209035, group = "hearthstone" }, -- Hearthstone of the Flame
    { kind = "toy",   id = 212337, group = "hearthstone" }, -- Notorious Thread's Hearthstone
    { kind = "toy",   id = 228940, group = "hearthstone" }, -- Stone of the Hearth

    -- Engineering wormhole toys
    { kind = "toy",   id = 87215,  group = "profession" }, -- Wormhole Generator: Pandaria
    { kind = "toy",   id = 153716, group = "profession" }, -- Wormhole Generator: Argus
    { kind = "toy",   id = 168807, group = "profession" }, -- Wormhole Generator: Kul Tiras
    { kind = "toy",   id = 168808, group = "profession" }, -- Wormhole Generator: Zandalar
    { kind = "toy",   id = 198156, group = "profession" }, -- Wormhole Generator: Dragon Isles
    { kind = "toy",   id = 219030, group = "profession" }, -- Wormhole Generator: Khaz Algar

    -- Class teleports (spells)
    { kind = "spell", id = 556,    group = "class" }, -- Astral Recall (Shaman)
    { kind = "spell", id = 18960,  group = "class" }, -- Teleport: Moonglade (Druid)
    { kind = "spell", id = 193753, group = "class" }, -- Dreamwalk (Druid)
    { kind = "spell", id = 50977,  group = "class" }, -- Death Gate (Death Knight)
    { kind = "spell", id = 126892, group = "class" }, -- Zen Pilgrimage (Monk)
    { kind = "spell", id = 193759, group = "class" }, -- Hall of the Guardian (Mage)

    -- Mage teleports / portals (subset; player only sees what they know)
    { kind = "spell", id = 3561,   group = "class" }, -- Teleport: Stormwind
    { kind = "spell", id = 3562,   group = "class" }, -- Teleport: Ironforge
    { kind = "spell", id = 3565,   group = "class" }, -- Teleport: Darnassus
    { kind = "spell", id = 32271,  group = "class" }, -- Teleport: Exodar
    { kind = "spell", id = 49361,  group = "class" }, -- Teleport: Theramore
    { kind = "spell", id = 33690,  group = "class" }, -- Teleport: Shattrath (Alliance)
    { kind = "spell", id = 88342,  group = "class" }, -- Teleport: Tol Barad (Alliance)
    { kind = "spell", id = 132621, group = "class" }, -- Teleport: Vale of Eternal Blossoms (Alliance)
    { kind = "spell", id = 176248, group = "class" }, -- Teleport: Stormshield
    { kind = "spell", id = 281403, group = "class" }, -- Teleport: Boralus
    { kind = "spell", id = 3567,   group = "class" }, -- Teleport: Orgrimmar
    { kind = "spell", id = 3566,   group = "class" }, -- Teleport: Thunder Bluff
    { kind = "spell", id = 3563,   group = "class" }, -- Teleport: Undercity
    { kind = "spell", id = 35715,  group = "class" }, -- Teleport: Shattrath (Horde)
    { kind = "spell", id = 49358,  group = "class" }, -- Teleport: Stonard
    { kind = "spell", id = 88344,  group = "class" }, -- Teleport: Tol Barad (Horde)
    { kind = "spell", id = 132627, group = "class" }, -- Teleport: Vale of Eternal Blossoms (Horde)
    { kind = "spell", id = 176242, group = "class" }, -- Teleport: Warspear
    { kind = "spell", id = 281404, group = "class" }, -- Teleport: Dazar'alor
    { kind = "spell", id = 53140,  group = "class" }, -- Teleport: Dalaran (Northrend)
    { kind = "spell", id = 224869, group = "class" }, -- Teleport: Dalaran (Broken Isles)
}

local FALLBACK_ICON = 134400

-- Resolve a catalogue entry against the current character. Returns the populated
-- entry table, or nil if the player does not have the toy / item / spell.
local function ResolveEntry(entry)
    local kind, id = entry.kind, entry.id
    if not kind or not id then return nil end

    if kind == "toy" then
        if not PlayerHasToy or not PlayerHasToy(id) then return nil end
        if not C_ToyBox or not C_ToyBox.GetToyInfo then return nil end
        local _, name, icon = C_ToyBox.GetToyInfo(id)
        if not name or name == "" then return nil end
        return {
            kind  = kind,
            id    = id,
            name  = name,
            icon  = icon or FALLBACK_ICON,
            group = entry.group,
        }
    end

    if kind == "item" then
        if not C_Item or not C_Item.GetItemCount then return nil end
        local count = C_Item.GetItemCount(id) or 0
        if count <= 0 then return nil end
        local name = C_Item.GetItemInfo and C_Item.GetItemInfo(id) or nil
        if not name then
            if C_Item.RequestLoadItemDataByID then C_Item.RequestLoadItemDataByID(id) end
            return nil
        end
        local icon = C_Item.GetItemIconByID and C_Item.GetItemIconByID(id) or FALLBACK_ICON
        return {
            kind  = kind,
            id    = id,
            name  = name,
            icon  = icon,
            group = entry.group,
        }
    end

    if kind == "spell" then
        local known = false
        if IsPlayerSpell then known = IsPlayerSpell(id) end
        if not known and IsSpellKnown then known = IsSpellKnown(id) end
        if not known then return nil end
        if not C_Spell or not C_Spell.GetSpellInfo then return nil end
        local info = C_Spell.GetSpellInfo(id)
        if not info or not info.name then return nil end
        return {
            kind  = kind,
            id    = id,
            name  = info.name,
            icon  = info.iconID or FALLBACK_ICON,
            group = entry.group,
        }
    end

    return nil
end

local function GroupRank(g)
    return GROUP_ORDER[g or ""] or 99
end

-- Returns an ordered list of entries the player has unlocked. Sort order:
-- group (hearthstone → profession → class → event), then name within group.
function addon.Vista.GetUnlockedTeleports()
    local out = {}
    local catalog = addon.Vista.TeleportCatalog
    if type(catalog) ~= "table" then return out end
    for i = 1, #catalog do
        local resolved = ResolveEntry(catalog[i])
        if resolved then
            out[#out + 1] = resolved
        end
    end
    table.sort(out, function(a, b)
        local ra, rb = GroupRank(a.group), GroupRank(b.group)
        if ra ~= rb then return ra < rb end
        return (a.name or "") < (b.name or "")
    end)
    return out
end
