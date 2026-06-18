--[[
    Horizon Suite - Vista - Teleports
    Catalogue of teleport toys, items, and class spells, plus a helper that
    returns only those the current character has unlocked. Read by the Vista
    teleport proxy button (see VistaCore.lua DEFAULT_BTN_DEFS).
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = addon.L

addon.Vista = addon.Vista or {}

local GROUP_ORDER = {
    hearthstone = 1,
    profession  = 2,
    class       = 3,
    dungeon     = 4,
    event       = 5,
    other       = 6,
}

-- Localized display label for a teleport group (read lazily at menu-build time,
-- so a missing locale at file scope can never cascade into a load-time error).
function addon.Vista.GroupLabel(group)
    local key = "VISTA_TELEPORT_GROUP_" .. string.upper(group or "other")
    return L[key]
end

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
    { kind = "toy",   id = 168807, group = "profession" }, -- Wormhole Generator: Kul Tiras
    { kind = "toy",   id = 168808, group = "profession" }, -- Wormhole Generator: Zandalar
    { kind = "toy",   id = 198156, group = "profession" }, -- Wyrmhole Generator: Dragon Isles

    -- Class teleports (spells)
    { kind = "spell", id = 556,    group = "class" }, -- Astral Recall (Shaman)
    { kind = "spell", id = 18960,  group = "class" }, -- Teleport: Moonglade (Druid)
    { kind = "spell", id = 193753, group = "class" }, -- Dreamwalk (Druid)
    { kind = "spell", id = 50977,  group = "class" }, -- Death Gate (Death Knight)
    { kind = "spell", id = 126892, group = "class" }, -- Zen Pilgrimage (Monk)
    { kind = "spell", id = 193759, group = "class" }, -- Teleport: Hall of the Guardian (Mage)

    -- Mage teleports / portals (subset; player only sees what they know)
    { kind = "spell", id = 3561,   group = "class" }, -- Teleport: Stormwind
    { kind = "spell", id = 3562,   group = "class" }, -- Teleport: Ironforge
    { kind = "spell", id = 3565,   group = "class" }, -- Teleport: Darnassus
    { kind = "spell", id = 32271,  group = "class" }, -- Teleport: Exodar
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

    -- Hearthstones (toys) — extended (names resolve live via C_ToyBox; ownership-filtered)
    { kind = "toy",   id = 236687, group = "hearthstone" }, -- Explosive Hearthstone
    { kind = "toy",   id = 246565, group = "hearthstone" }, -- Cosmic Hearthstone
    { kind = "toy",   id = 245970, group = "hearthstone" }, -- P.O.S.T. Master's Express Hearthstone
    { kind = "toy",   id = 193588, group = "hearthstone" }, -- Timewalker's Hearthstone
    { kind = "toy",   id = 265100, group = "hearthstone" }, -- Corewarden's Hearthstone
    { kind = "toy",   id = 257736, group = "hearthstone" }, -- Lightcalled Hearthstone
    { kind = "toy",   id = 263933, group = "hearthstone" }, -- Preyseeker's Hearthstone
    { kind = "toy",   id = 264367, group = "hearthstone" }, -- Mycomancer's Hearthspore

    -- Engineering wormholes / transporters (toys) — extended
    { kind = "toy",   id = 48933,  group = "profession" }, -- Wormhole Generator: Northrend
    { kind = "toy",   id = 112059, group = "profession" }, -- Wormhole Centrifuge
    { kind = "toy",   id = 172924, group = "profession" }, -- Wormhole Generator: Shadowlands
    { kind = "toy",   id = 221966, group = "profession" }, -- Wormhole Generator: Khaz Algar
    { kind = "toy",   id = 18986,  group = "profession" }, -- Ultrasafe Transporter: Gadgetzan
    { kind = "toy",   id = 30544,  group = "profession" }, -- Ultrasafe Transporter: Toshley's Station
    { kind = "toy",   id = 18984,  group = "profession" }, -- Dimensional Ripper - Everlook
    { kind = "toy",   id = 30542,  group = "profession" }, -- Dimensional Ripper - Area 52

    -- Mage portals + later-expansion class teleports (spells)
    { kind = "spell", id = 1259190, group = "class" }, -- Teleport: Silvermoon City (Midnight)
    { kind = "spell", id = 1259194, group = "class" }, -- Portal: Silvermoon City (Midnight)
    { kind = "spell", id = 446540, group = "class" }, -- Teleport: Dornogal
    { kind = "spell", id = 446534, group = "class" }, -- Portal: Dornogal
    { kind = "spell", id = 395277, group = "class" }, -- Teleport: Valdrakken
    { kind = "spell", id = 395289, group = "class" }, -- Portal: Valdrakken
    { kind = "spell", id = 344587, group = "class" }, -- Teleport: Oribos
    { kind = "spell", id = 344597, group = "class" }, -- Portal: Oribos
    { kind = "spell", id = 281400, group = "class" }, -- Portal: Boralus (Alliance)
    { kind = "spell", id = 281402, group = "class" }, -- Portal: Dazar'alor (Horde)
    { kind = "spell", id = 224871, group = "class" }, -- Portal: Dalaran - Broken Isles
    { kind = "spell", id = 176246, group = "class" }, -- Portal: Stormshield (Alliance)
    { kind = "spell", id = 176244, group = "class" }, -- Portal: Warspear (Horde)
    { kind = "spell", id = 132620, group = "class" }, -- Portal: Vale of Eternal Blossoms (Alliance)
    { kind = "spell", id = 132626, group = "class" }, -- Portal: Vale of Eternal Blossoms (Horde)
    { kind = "spell", id = 88345,  group = "class" }, -- Portal: Tol Barad (Alliance)
    { kind = "spell", id = 88346,  group = "class" }, -- Portal: Tol Barad (Horde)
    { kind = "spell", id = 53142,  group = "class" }, -- Portal: Dalaran - Northrend
    { kind = "spell", id = 49360,  group = "class" }, -- Portal: Theramore (Alliance)
    { kind = "spell", id = 35717,  group = "class" }, -- Portal: Shattrath (Horde)
    { kind = "spell", id = 33691,  group = "class" }, -- Portal: Shattrath (Alliance)
    { kind = "spell", id = 32267,  group = "class" }, -- Portal: Silvermoon (Horde, Burning Crusade)
    { kind = "spell", id = 32272,  group = "class" }, -- Teleport: Silvermoon (Horde, Burning Crusade)
    { kind = "spell", id = 32266,  group = "class" }, -- Portal: Exodar (Alliance)
    { kind = "spell", id = 10059,  group = "class" }, -- Portal: Stormwind (Alliance)
    { kind = "spell", id = 11416,  group = "class" }, -- Portal: Ironforge (Alliance)
    { kind = "spell", id = 11419,  group = "class" }, -- Portal: Darnassus (Alliance)
    { kind = "spell", id = 11417,  group = "class" }, -- Portal: Orgrimmar (Horde)
    { kind = "spell", id = 11420,  group = "class" }, -- Portal: Thunder Bluff (Horde)
    { kind = "spell", id = 11418,  group = "class" }, -- Portal: Undercity (Horde)

    -- Dungeon / raid teleports ("Path of ...") — group "dungeon"
    -- Mists of Pandaria
    { kind = "spell", id = 131204, group = "dungeon" }, -- Path of the Jade Serpent
    { kind = "spell", id = 131205, group = "dungeon" }, -- Path of the Stout Brew
    { kind = "spell", id = 131206, group = "dungeon" }, -- Path of the Shado-Pan
    { kind = "spell", id = 131222, group = "dungeon" }, -- Path of the Mogu King
    { kind = "spell", id = 131225, group = "dungeon" }, -- Path of the Setting Sun
    { kind = "spell", id = 131228, group = "dungeon" }, -- Path of the Black Ox
    { kind = "spell", id = 131229, group = "dungeon" }, -- Path of the Scarlet Mitre
    { kind = "spell", id = 131231, group = "dungeon" }, -- Path of the Scarlet Blade
    { kind = "spell", id = 131232, group = "dungeon" }, -- Path of the Necromancer
    -- Warlords of Draenor
    { kind = "spell", id = 159895, group = "dungeon" }, -- Path of the Bloodmaul
    { kind = "spell", id = 159896, group = "dungeon" }, -- Path of the Iron Prow
    { kind = "spell", id = 159897, group = "dungeon" }, -- Path of the Vigilant
    { kind = "spell", id = 159898, group = "dungeon" }, -- Path of the Skies
    { kind = "spell", id = 159899, group = "dungeon" }, -- Path of the Crescent Moon
    { kind = "spell", id = 159900, group = "dungeon" }, -- Path of the Dark Rail
    { kind = "spell", id = 159902, group = "dungeon" }, -- Path of the Burning Mountain
    -- Legion
    { kind = "spell", id = 373262, group = "dungeon" }, -- Path of the Fallen Guardian
    { kind = "spell", id = 393764, group = "dungeon" }, -- Path of Proven Worth
    { kind = "spell", id = 393766, group = "dungeon" }, -- Path of the Grand Magistrix
    { kind = "spell", id = 424153, group = "dungeon" }, -- Path of Ancient Horrors
    { kind = "spell", id = 424163, group = "dungeon" }, -- Path of the Nightmare Lord
    { kind = "spell", id = 410078, group = "dungeon" }, -- Path of the Earth-Warder
    -- Cataclysm
    { kind = "spell", id = 410080, group = "dungeon" }, -- Path of Wind's Domain
    { kind = "spell", id = 424142, group = "dungeon" }, -- Path of the Tidehunter
    { kind = "spell", id = 445424, group = "dungeon" }, -- Path of the Twilight Fortress
    -- Battle for Azeroth
    { kind = "spell", id = 424187, group = "dungeon" }, -- Path of the Golden Tomb
    { kind = "spell", id = 467553, group = "dungeon" }, -- Path of the Azerite Refinery
    { kind = "spell", id = 410071, group = "dungeon" }, -- Path of the Freebooter
    { kind = "spell", id = 445418, group = "dungeon" }, -- Path of the Besieged Harbor
    { kind = "spell", id = 424167, group = "dungeon" }, -- Path of Heart's Bane
    { kind = "spell", id = 410074, group = "dungeon" }, -- Path of Festering Rot
    { kind = "spell", id = 373274, group = "dungeon" }, -- Path of the Scrappy Prince
    -- Shadowlands dungeons
    { kind = "spell", id = 354464, group = "dungeon" }, -- Path of the Misty Forest
    { kind = "spell", id = 354468, group = "dungeon" }, -- Path of the Scheming Loa
    { kind = "spell", id = 354462, group = "dungeon" }, -- Path of the Courageous
    { kind = "spell", id = 354466, group = "dungeon" }, -- Path of the Ascendant
    { kind = "spell", id = 354465, group = "dungeon" }, -- Path of the Sinful Soul
    { kind = "spell", id = 354469, group = "dungeon" }, -- Path of the Stone Warden
    { kind = "spell", id = 354463, group = "dungeon" }, -- Path of the Plagued
    { kind = "spell", id = 354467, group = "dungeon" }, -- Path of the Undefeated
    { kind = "spell", id = 367416, group = "dungeon" }, -- Path of the Streetwise Merchant
    -- Shadowlands raids
    { kind = "spell", id = 373190, group = "dungeon" }, -- Path of the Sire (Castle Nathria)
    { kind = "spell", id = 373191, group = "dungeon" }, -- Path of the Tormented Soul (Sanctum of Domination)
    { kind = "spell", id = 373192, group = "dungeon" }, -- Path of the First Ones (Sepulcher of the First Ones)
    -- Dragonflight dungeons
    { kind = "spell", id = 393256, group = "dungeon" }, -- Path of the Clutch Defender
    { kind = "spell", id = 393276, group = "dungeon" }, -- Path of the Obsidian Hoard
    { kind = "spell", id = 393262, group = "dungeon" }, -- Path of the Windswept Plains
    { kind = "spell", id = 393279, group = "dungeon" }, -- Path of Arcane Secrets
    { kind = "spell", id = 393267, group = "dungeon" }, -- Path of the Rotting Woods
    { kind = "spell", id = 393273, group = "dungeon" }, -- Path of the Draconic Diploma
    { kind = "spell", id = 393283, group = "dungeon" }, -- Path of the Titanic Reservoir
    { kind = "spell", id = 393222, group = "dungeon" }, -- Path of the Watcher's Legacy
    { kind = "spell", id = 424197, group = "dungeon" }, -- Path of Twisted Time
    -- Dragonflight raids
    { kind = "spell", id = 432254, group = "dungeon" }, -- Path of the Primal Prison (Vault of the Incarnates)
    { kind = "spell", id = 432257, group = "dungeon" }, -- Path of the Bitter Legacy (Aberrus)
    { kind = "spell", id = 432258, group = "dungeon" }, -- Path of the Scorching Dream (Amirdrassil)
    -- The War Within dungeons
    { kind = "spell", id = 445444, group = "dungeon" }, -- Path of the Light's Reverence
    { kind = "spell", id = 445414, group = "dungeon" }, -- Path of the Arathi Flagship
    { kind = "spell", id = 445443, group = "dungeon" }, -- Path of the Fallen Stormriders
    { kind = "spell", id = 445440, group = "dungeon" }, -- Path of the Flaming Brewery
    { kind = "spell", id = 445269, group = "dungeon" }, -- Path of the Corrupted Foundry
    { kind = "spell", id = 445441, group = "dungeon" }, -- Path of the Warding Candles
    { kind = "spell", id = 1216786, group = "dungeon" }, -- Path of the Circuit Breaker
    { kind = "spell", id = 445416, group = "dungeon" }, -- Path of Nerubian Ascension
    { kind = "spell", id = 445417, group = "dungeon" }, -- Path of the Ruined City
    { kind = "spell", id = 1237215, group = "dungeon" }, -- Path of the Eco-Dome
    -- The War Within raids
    { kind = "spell", id = 1226482, group = "dungeon" }, -- Path of the Full House (Liberation of Undermine)
    { kind = "spell", id = 1239155, group = "dungeon" }, -- Path of the All-Devouring (Manaforge Omega)
    -- Midnight (12.0) dungeons
    { kind = "spell", id = 1254400, group = "dungeon" }, -- Path of the Windrunners (Windrunner Spire)
    { kind = "spell", id = 1254572, group = "dungeon" }, -- Path of Devoted Magistry (Magisters' Terrace)
    { kind = "spell", id = 1254551, group = "dungeon" }, -- Path of Dark Dereliction (Seat of the Triumvirate)
    { kind = "spell", id = 1254563, group = "dungeon" }, -- Path of the Fractured Core
    { kind = "spell", id = 1254559, group = "dungeon" }, -- Path of Cavernous Depths
    { kind = "spell", id = 1254555, group = "dungeon" }, -- Path of Unyielding Blight
    { kind = "spell", id = 1254557, group = "dungeon" }, -- Path of the Crowning Pinnacle

    -- Event / other teleport toys & items
    { kind = "toy",   id = 205255, group = "other" }, -- Niffen Diggin' Mitts (Zaralek Cavern)
    { kind = "toy",   id = 243056, group = "event" }, -- Delver's Mana-Bound Ethergate
    { kind = "item",  id = 234389, group = "other" }, -- Gallagio Loyalty Rewards Card: Silver
    { kind = "item",  id = 234390, group = "other" }, -- Gallagio Loyalty Rewards Card: Gold
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
        -- C_SpellBook.IsSpellKnown (11.2.0+) replaces the removed IsPlayerSpell /
        -- IsSpellKnown globals; true for spells in the player's spellbook.
        if not C_SpellBook or not C_SpellBook.IsSpellKnown then return nil end
        if not C_SpellBook.IsSpellKnown(id) then return nil end
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

-- Groups that have their own visibility toggle. Anything outside this set is
-- gated by the "other" catch-all instead.
local KNOWN_GROUPS = {
    hearthstone = true, profession = true, class = true,
    dungeon = true, event = true, other = true,
}

-- True if the given teleport group is enabled for display. Unknown groups fall
-- through to the "other" catch-all toggle. Every group defaults to shown — we
-- pass `true` as the default so an un-touched profile shows everything (rather
-- than keying off whether the value has been written yet).
local function GroupEnabled(group)
    local g = group or "other"
    if not KNOWN_GROUPS[g] then g = "other" end
    return addon.GetDB("vistaTeleportGroup_" .. g, true) and true or false
end

-- True when every teleport group toggle is off, so the menu's empty state can
-- distinguish "nothing unlocked" from "all groups hidden".
function addon.Vista.AllTeleportGroupsHidden()
    for g in pairs(KNOWN_GROUPS) do
        if addon.GetDB("vistaTeleportGroup_" .. g, true) then return false end
    end
    return true
end

-- Returns an ordered list of entries the player has unlocked, sorted by group
-- (following GROUP_ORDER) then by name within each group. Groups disabled in
-- options are filtered out.
function addon.Vista.GetUnlockedTeleports()
    local out = {}
    local catalog = addon.Vista.TeleportCatalog
    if type(catalog) ~= "table" then return out end
    for i = 1, #catalog do
        local resolved = ResolveEntry(catalog[i])
        if resolved and GroupEnabled(resolved.group) then
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

-- ============================================================================
-- Favorites + recently-used (per-character, under the active Vista profile)
-- ============================================================================

local RECENT_CAP = 5

-- Stable identity for a teleport entry, e.g. "spell:3561" / "toy:140192".
function addon.Vista.TeleportKey(kind, id)
    return tostring(kind) .. ":" .. tostring(id)
end
local TeleportKey = addon.Vista.TeleportKey

-- Favorites are a set: { ["kind:id"] = true }. Lazily created and persisted so a
-- later SetDB has a stable home (GetDB returns the live profile table).
function addon.Vista.GetTeleportFavorites()
    local fav = addon.GetDB("vistaTeleportFavorites", nil)
    if type(fav) ~= "table" then
        fav = {}
        addon.SetDB("vistaTeleportFavorites", fav)
    end
    return fav
end

function addon.Vista.IsTeleportFavorite(kind, id)
    return addon.Vista.GetTeleportFavorites()[TeleportKey(kind, id)] == true
end

-- Flip favorite state; returns the new boolean.
function addon.Vista.ToggleTeleportFavorite(kind, id)
    local fav = addon.Vista.GetTeleportFavorites()
    local key = TeleportKey(kind, id)
    local nowFav = not fav[key]
    fav[key] = nowFav or nil
    addon.SetDB("vistaTeleportFavorites", fav)
    return nowFav
end

-- Recents are an ordered array of "kind:id", most-recent-first, capped.
function addon.Vista.GetTeleportRecents()
    local rec = addon.GetDB("vistaTeleportRecent", nil)
    if type(rec) ~= "table" then
        rec = {}
        addon.SetDB("vistaTeleportRecent", rec)
    end
    return rec
end

-- Record a use: de-dup, push to front, trim to RECENT_CAP.
function addon.Vista.RecordTeleportUse(kind, id)
    local rec = addon.Vista.GetTeleportRecents()
    local key = TeleportKey(kind, id)
    for i = #rec, 1, -1 do
        if rec[i] == key then table.remove(rec, i) end
    end
    table.insert(rec, 1, key)
    for i = #rec, RECENT_CAP + 1, -1 do
        rec[i] = nil
    end
    addon.SetDB("vistaTeleportRecent", rec)
end

-- Builds the ordered menu entry list. Each returned entry is a resolved teleport
-- annotated with `.section` (the display header it belongs under) and
-- `.isFavorite`. Order: Favorites (if enabled + any), Recent (if enabled + any),
-- then the remaining unlocked teleports grouped by group. Favorites/recents are
-- de-duplicated out of the grouped tail. Stale favorites/recents are dropped
-- automatically because only currently-unlocked entries are surfaced.
function addon.Vista.GetTeleportMenuEntries()
    local unlocked = addon.Vista.GetUnlockedTeleports()
    local list = {}

    local enableFav  = addon.GetDB("vistaTeleportEnableFavorites", true)
    local showRecent = addon.GetDB("vistaTeleportShowRecents", true)

    local byKey = {}
    for i = 1, #unlocked do
        byKey[TeleportKey(unlocked[i].kind, unlocked[i].id)] = unlocked[i]
    end
    local used = {}

    if enableFav then
        local favSet = addon.Vista.GetTeleportFavorites()
        local favLabel = L["VISTA_TELEPORT_FAVOURITES"]
        for i = 1, #unlocked do
            local e = unlocked[i]
            local k = TeleportKey(e.kind, e.id)
            if favSet[k] then
                e.section = favLabel
                e.isFavorite = true
                used[k] = true
                list[#list + 1] = e
            end
        end
    end

    if showRecent then
        local recents = addon.Vista.GetTeleportRecents()
        local recLabel = L["VISTA_TELEPORT_RECENT"]
        for i = 1, #recents do
            local k = recents[i]
            local e = byKey[k]
            if e and not used[k] then
                e.section = recLabel
                e.isFavorite = enableFav and (addon.Vista.GetTeleportFavorites()[k] == true) or false
                used[k] = true
                list[#list + 1] = e
            end
        end
    end

    local favSet = enableFav and addon.Vista.GetTeleportFavorites() or nil
    for i = 1, #unlocked do
        local e = unlocked[i]
        local k = TeleportKey(e.kind, e.id)
        if not used[k] then
            e.section = addon.Vista.GroupLabel(e.group)
            e.isFavorite = favSet and (favSet[k] == true) or false
            list[#list + 1] = e
        end
    end

    return list
end
