--[[
    Horizon Suite - Augment / FlightTimer - Estimator
    Faction/learned-data lookup, multi-hop route-time estimation, and the two
    small pieces of live API discovery InFlight's Converter.lua relies on
    (factionless-zone node membership, the Khaz Algar Flight Master speed
    bonus). No third-party code is reused here, only Blizzard's own
    C_Map/C_TaxiMap APIs queried at runtime - see AugmentFlightTimerData.lua
    for the one file that does carry third-party-sourced data.
]]

local addon = _G.HorizonSuite
local Y = addon and addon.Augment
local F = Y and Y.FlightTimer
if not F then return end

local floor, format = math.floor, string.format

local playerFaction = UnitFactionGroup("player")
F.playerFaction = playerFaction

-- Strips the ", Zone Name" suffix WoW appends to many flight point names
-- (e.g. "Honor Hold, Hellfire Peninsula" -> "Honor Hold"). Not user-facing
-- translatable text, just a structural pattern, so no locale lookup needed.
function F.ShortenName(name)
    if not name then return name end
    return (name:gsub(", .+", ""))
end

-- ============================================================================
-- FACTIONLESS ZONE / KHAZ ALGAR DISCOVERY
-- Ported from InFlight's Converter.lua CreateNoFactionZoneNodes(): walks
-- Blizzard's own map API to find which taxi nodes belong to cross-faction
-- continents, since GetDstNodes needs to know whether to look a source node
-- up under a faction table or the factionless one. Re-run on
-- PLAYER_ENTERING_WORLD since some nodes only appear on the map after
-- certain campaign quests are completed.
-- ============================================================================

F.noFactionZoneNodes = F.noFactionZoneNodes or {}
F.khazAlgarNodes      = F.khazAlgarNodes or {}

local function FindAncestor(mapID, ancestorUiMapID)
    if not mapID then return false end
    if mapID == ancestorUiMapID then return true end
    local mapInfo = C_Map.GetMapInfo(mapID)
    if not mapInfo or not mapInfo.parentMapID or mapInfo.parentMapID == 0 then return false end
    return FindAncestor(mapInfo.parentMapID, ancestorUiMapID)
end

local function GetNodesInMap(parentMapId, nodes)
    for uiMapID = 1, 3000 do
        local mapInfo = C_Map.GetMapInfo(uiMapID)
        if mapInfo and mapInfo.mapID and FindAncestor(mapInfo.mapID, parentMapId) then
            local taxiNodes = C_TaxiMap.GetTaxiNodesForMap(mapInfo.mapID)
            if taxiNodes then
                for _, v in pairs(taxiNodes) do
                    nodes[v.nodeID] = true
                end
            end
        end
    end
end

-- @param mapID number  a UiMapID for a top-level cross-faction continent
-- @param nodes table   set to expand with `true` per discovered nodeID
-- @param extra table|nil  hardcoded nodeIDs Blizzard's map API doesn't surface
local function AddFactionlessContinent(mapID, nodes, extra)
    GetNodesInMap(mapID, nodes)
    if extra then
        for _, nodeID in ipairs(extra) do
            nodes[nodeID] = true
        end
    end
end

function F.RefreshFactionlessZoneNodes()
    local nodes = wipe(F.noFactionZoneNodes)

    -- Shadowlands. 2528/2548 ("Elysian Hold"/"Sinfall") aren't found by
    -- GetTaxiNodesForMap on any map.
    AddFactionlessContinent(1550, nodes, { 2528, 2548 })

    -- Dragon Isles. 2804 ("Uktulut Backwater") isn't found by GetTaxiNodesForMap.
    AddFactionlessContinent(1978, nodes, { 2804 })

    -- Khaz Algar. Tracked separately too, for the speed-bonus check below.
    local khazAlgar = wipe(F.khazAlgarNodes)
    GetNodesInMap(2274, khazAlgar)
    -- "Tranquil Strand" isn't on any map until a campaign quest is completed.
    khazAlgar[2970] = true
    for nodeID in pairs(khazAlgar) do
        nodes[nodeID] = true
    end
end

-- Khaz Algar flight points are 1.25x slower until the player has completed
-- the "Khaz Algar Flight Master" achievement (40430).
function F.KhazAlgarFlightMasterFactor(nodeID)
    if not F.khazAlgarNodes[nodeID] then return 1 end
    local _, _, _, completed = GetAchievementInfo(40430)
    if completed then return 1 end
    return 1.25
end

-- ============================================================================
-- DATA LOOKUP
-- Self-learned corrections take priority over the bundled dataset for any
-- destination they cover, since they reflect this player's actual mounts/
-- buffs/routes more accurately than the shipped averages.
-- ============================================================================

-- Cached per srcNodeID for the session (tooltip hovers re-query the same
-- handful of taxi nodes repeatedly while a map is open), invalidated only
-- when learned data actually changes - see F.InvalidateDstNodesCache, called
-- from AugmentFlightTimerState.lua's SetLearnedTime/ResetLearnedData.
local dstNodesCache = {}

function F.InvalidateDstNodesCache()
    wipe(dstNodesCache)
end

-- @param srcNodeID number|string
-- @return table|nil  { [dstNodeID] = seconds, ..., name = "Source Name" }
function F.GetDstNodes(srcNodeID)
    if not srcNodeID then return nil end

    local cached = dstNodesCache[srcNodeID]
    if cached ~= nil then
        if cached == false then return nil end
        return cached
    end

    local bucket = F.noFactionZoneNodes[srcNodeID] and "FactionlessZones" or playerFaction
    local bundled = F.BUNDLED_DATA[bucket] and F.BUNDLED_DATA[bucket][srcNodeID]
    local learned = F.GetLearnedData()
    learned = learned and learned[bucket] and learned[bucket][srcNodeID]

    local result
    if not bundled and not learned then
        result = false
    elseif not learned then
        result = bundled
    else
        result = {}
        for k, v in pairs(bundled) do result[k] = v end
        for k, v in pairs(learned) do result[k] = v end
    end

    dstNodesCache[srcNodeID] = result
    if result == false then return nil end
    return result
end

-- ============================================================================
-- MULTI-HOP ESTIMATION
-- Ported from InFlight.lua's GetEstimatedTime(): when there's no direct
-- entry for src->dst, walk the route's intermediate hops (as reported by
-- Blizzard's own GetNumRoutes/TaxiGetNodeSlot) and sum known hop durations,
-- backtracking through alternate hop combinations if a hop's duration isn't
-- in the dataset. Returns nil (caller shows "??") if no combination resolves.
-- ============================================================================

local function GetNodeID(slot, viewedTaxiMapID)
    local taximapNodes = C_TaxiMap.GetAllTaxiNodes(viewedTaxiMapID)
    for _, taxiNodeData in ipairs(taximapNodes) do
        if slot == taxiNodeData.slotIndex then
            return taxiNodeData.nodeID
        end
    end
end

-- @param srcNodeID number  current location's nodeID
-- @param slot number       destination's taxi button/slot index
-- @param viewedTaxiMapID number  the currently viewed taxi map (caller resolves
--   this, since "viewed" can differ from GetTaxiMapID() on cross-map flights)
-- @return number|nil  estimated seconds, or nil if no estimate could be made
function F.GetEstimatedTime(srcNodeID, slot, viewedTaxiMapID)
    local numRoutes = GetNumRoutes(slot)
    if numRoutes < 2 then return nil end

    local taxiNodes = { [1] = srcNodeID, [numRoutes + 1] = GetNodeID(slot, viewedTaxiMapID) }
    for hop = 2, numRoutes do
        taxiNodes[hop] = GetNodeID(TaxiGetNodeSlot(slot, hop, true), viewedTaxiMapID)
    end

    -- Intermediate hops of cross-map routes can't always be resolved to a
    -- node ID, because GetNodeID only searches the currently viewed taxi map.
    -- Without every node ID the per-hop durations can't be summed, so skip
    -- the estimate instead of erroring on a nil node below.
    for hop = 1, numRoutes + 1 do
        if not taxiNodes[hop] then return nil end
    end

    local etimes = { 0 }
    local prevNode, nextNode = {}, {}
    local srcHop, dstHop = 1, #taxiNodes - 1

    while srcHop and srcHop < #taxiNodes do
        while dstHop and dstHop > srcHop do
            local dstNodes = F.GetDstNodes(taxiNodes[srcHop])
            if dstNodes and dstNodes[taxiNodes[dstHop]] then
                if not etimes[dstHop] then
                    local factor = F.KhazAlgarFlightMasterFactor(taxiNodes[dstHop])
                    etimes[dstHop] = etimes[srcHop] + dstNodes[taxiNodes[dstHop]] * factor
                    nextNode[srcHop] = dstHop - 1
                    prevNode[dstHop] = srcHop
                    srcHop = dstHop
                    dstHop = #taxiNodes
                else
                    dstHop = dstHop - 1
                end
            else
                dstHop = dstHop - 1
            end
        end

        if not etimes[#taxiNodes] then
            srcHop = prevNode[srcHop]
            dstHop = srcHop and nextNode[srcHop]
        end
    end

    return etimes[#taxiNodes]
end
