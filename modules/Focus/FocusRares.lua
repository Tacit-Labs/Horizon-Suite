--[[
    Horizon Suite - Focus - Rare Bosses
    RARES_BY_MAP, vignette detection, GetRaresOnMap.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- ============================================================================
-- RARE BOSSES BY ZONE AND VIGNETTE DETECTION
-- ============================================================================

local RARES_BY_MAP = {
    [2112] = {
        { 193136, "Researcher Sneakwing" },
        { 193166, "Sparkspitter Vrak" },
        { 193173, "Territorial Coastling" },
    },
    [2133] = {
        { 193157, "Dragonhunter Gorund" },
        { 193168, "Breezebiter" },
        { 193209, "Tenek" },
    },
    [2198] = {
        { 212557, "Bonesifter" },
        { 212558, "Captain Dailis" },
    },
}

--- Classifies a vignette atlas name as rare ("rare") or treasure ("treasure"), else nil.
--- The lowercased atlas name is computed once; the original per-call IsNpc/IsTreasure
--- helpers each called :lower() separately, allocating a new string per vignette.
local function ClassifyVignetteAtlas(atlasName)
    if not atlasName or atlasName == "" then return nil end
    local lower = atlasName:lower()
    if lower:find("loot") or lower:find("treasure") or lower:find("container")
        or lower:find("chest") or lower:find("object") then
        return "treasure"
    end
    if lower:find("rare") or lower:find("elite") or lower:find("npc")
        or lower:find("vignettekill") then
        return "rare"
    end
    return nil
end

-- ----------------------------------------------------------------------------
-- SCAN CACHE
-- Rare + treasure lists are built in one shared vignette pass, then cached.
-- Invalidated on VIGNETTES_UPDATED (new rare/treasure spawned or despawned) and
-- on ZONE_CHANGED / PLAYER_ENTERING_WORLD (zone switch). The invalidation frame
-- fires regardless of focus.enabled so Presence (which also consumes these APIs)
-- sees fresh data even when the Focus module is disabled.
-- ----------------------------------------------------------------------------

local scanCacheValid = false
local scanCacheRares = nil
local scanCacheTreasures = nil

-- Parent-map hierarchy cache for RARES_BY_MAP fallback lookups.
-- The previous code walked up to 20 parents on every call; we memoise per mapID.
local mapLookupMapID = nil
local mapLookupRares = nil
local mapLookupZoneName = nil

local function InvalidateScanCache()
    scanCacheValid = false
end

local function InvalidateMapLookup()
    mapLookupMapID = nil
    mapLookupRares = nil
    mapLookupZoneName = nil
end

addon.InvalidateRareScanCache = InvalidateScanCache

--- Resolve RARES_BY_MAP entries for mapID, walking the parent-map hierarchy.
--- Cached per-mapID; zone changes invalidate the cache.
local function ResolveMapRares(mapID)
    if not mapID then return nil, nil end
    if mapLookupMapID == mapID then
        return mapLookupRares, mapLookupZoneName
    end
    local rares = RARES_BY_MAP[mapID]
    if not rares and C_Map and C_Map.GetMapInfo then
        local current = mapID
        for _ = 1, 20 do
            local parentInfo = C_Map.GetMapInfo(current)
            if not parentInfo or not parentInfo.parentMapID or parentInfo.parentMapID == 0 then break end
            current = parentInfo.parentMapID
            rares = RARES_BY_MAP[current]
            if rares then break end
        end
    end
    local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(mapID) or nil
    mapLookupMapID = mapID
    mapLookupRares = rares
    mapLookupZoneName = info and info.name or nil
    return rares, mapLookupZoneName
end

--- Single shared vignette pass that populates both rare and treasure output lists.
--- Player mapID is resolved once per build (was previously per-vignette) and shared
--- with GetVignettePosition and the treasure zone-name lookup.
local function BuildScan()
    local rareColor     = addon.GetQuestColor("RARE")
    local rareLootColor = (addon.GetQuestColor and addon.GetQuestColor("RARE_LOOT")) or addon.GetQuestColor("RARE")

    local rares, treasures = {}, {}
    local mapID = (C_Map and C_Map.GetBestMapForUnit) and C_Map.GetBestMapForUnit("player") or nil
    local treasureZoneName  -- lazy-populated once on first treasure hit

    if C_VignetteInfo and C_VignetteInfo.GetVignettes and C_VignetteInfo.GetVignetteInfo then
        local vignettes = C_VignetteInfo.GetVignettes()
        if vignettes then
            local seenRares, seenTreasures = {}, {}
            for _, vignetteGUID in ipairs(vignettes) do
                local vi = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
                if vi and vi.name and vi.name ~= "" then
                    local kind = ClassifyVignetteAtlas(vi.atlasName)
                    if kind then
                        -- Position lookup is shared between rare + treasure paths. GetVignettePosition
                        -- requires a uiMapID, which we resolved once above.
                        local vX, vY
                        if mapID and C_VignetteInfo.GetVignettePosition then
                            local ok, pos = pcall(C_VignetteInfo.GetVignettePosition, vignetteGUID, mapID)
                            if ok and pos then
                                vX = pos.x or (pos.GetXY and select(1, pos:GetXY()))
                                vY = pos.y or (pos.GetXY and select(2, pos:GetXY()))
                            end
                        end

                        if kind == "rare" then
                            local creatureID = vi.npcID or vi.creatureID
                            if not creatureID and vi.objectGUID then
                                local _, _, _, _, _, id, _ = strsplit("-", vi.objectGUID)
                                creatureID = tonumber(id)
                            end
                            if creatureID then
                                local dedupeKey = "c:" .. tostring(creatureID)
                                if not seenRares[dedupeKey] then
                                    seenRares[dedupeKey] = true
                                    rares[#rares + 1] = {
                                        entryKey       = "vignette:" .. tostring(vignetteGUID),
                                        questID        = nil,
                                        title          = vi.name or "Unknown",
                                        objectives     = {},
                                        color          = rareColor,
                                        category       = "RARE",
                                        isComplete     = false,
                                        isSuperTracked = false,
                                        isNearby       = true,
                                        zoneName       = nil,
                                        itemLink       = nil,
                                        itemTexture    = nil,
                                        isRare         = true,
                                        creatureID     = creatureID,
                                        vignetteGUID   = vignetteGUID,
                                        vignetteMapID  = mapID,
                                        vignetteX      = vX,
                                        vignetteY      = vY,
                                    }
                                end
                            end
                        else -- treasure
                            local dedupeKey = (mapID and vX and vY)
                                and ("p:%s:%.2f:%.2f"):format(tostring(mapID), vX or 0, vY or 0)
                                or (vi.vignetteID and ("v:" .. tostring(vi.vignetteID)) or ("n:" .. (vi.name or "")))
                            if not seenTreasures[dedupeKey] then
                                seenTreasures[dedupeKey] = true
                                if not treasureZoneName and mapID and C_Map and C_Map.GetMapInfo then
                                    local info = C_Map.GetMapInfo(mapID)
                                    treasureZoneName = info and info.name or nil
                                end
                                treasures[#treasures + 1] = {
                                    entryKey       = "vignette:" .. tostring(vignetteGUID),
                                    questID        = nil,
                                    title          = vi.name or "Unknown",
                                    objectives     = {},
                                    color          = rareLootColor,
                                    category       = "RARE_LOOT",
                                    isComplete     = false,
                                    isSuperTracked = false,
                                    isNearby       = true,
                                    zoneName       = treasureZoneName,
                                    itemLink       = nil,
                                    itemTexture    = nil,
                                    isRareLoot     = true,
                                    vignetteGUID   = vignetteGUID,
                                    vignetteID     = vi.vignetteID,
                                    vignetteMapID  = mapID,
                                    vignetteX      = vX,
                                    vignetteY      = vY,
                                    questTypeAtlas = vi.atlasName,
                                }
                            end
                        end
                    end
                end
            end
        end
    end

    -- Hardcoded RARES_BY_MAP fallback: only when the vignette pass found no rares.
    -- Preserves the original precedence (vignette data wins over hardcoded list).
    if #rares == 0 and mapID then
        local mappedRares, zoneName = ResolveMapRares(mapID)
        if mappedRares then
            for _, t in ipairs(mappedRares) do
                local creatureID, name = t[1], t[2]
                if creatureID and name then
                    rares[#rares + 1] = {
                        entryKey       = "rare:" .. tostring(creatureID),
                        questID        = nil,
                        title          = name,
                        objectives     = {},
                        color          = rareColor,
                        category       = "RARE",
                        isComplete     = false,
                        isSuperTracked = false,
                        isNearby       = true,
                        zoneName       = zoneName,
                        itemLink       = nil,
                        itemTexture    = nil,
                        isRare         = true,
                        creatureID     = creatureID,
                    }
                end
            end
        end
    end

    scanCacheRares     = rares
    scanCacheTreasures = treasures
    scanCacheValid     = true
end

local function EnsureScan()
    if not scanCacheValid then BuildScan() end
end

local function GetRaresOnMap()
    EnsureScan()
    return scanCacheRares or {}
end

local function GetTreasuresOnMap()
    EnsureScan()
    return scanCacheTreasures or {}
end

addon.GetRaresOnMap = GetRaresOnMap
addon.GetTreasuresOnMap = GetTreasuresOnMap

-- Always-on invalidation frame. Runs regardless of focus.enabled so Presence, which
-- calls GetRaresOnMap independently, always sees a fresh scan after zone/vignette changes.
local invalidationFrame = CreateFrame("Frame")
invalidationFrame:RegisterEvent("VIGNETTES_UPDATED")
invalidationFrame:RegisterEvent("ZONE_CHANGED")
invalidationFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
pcall(function() invalidationFrame:RegisterEvent("ZONE_CHANGED_INDOORS") end)
invalidationFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
invalidationFrame:SetScript("OnEvent", function(_, event)
    InvalidateScanCache()
    if event ~= "VIGNETTES_UPDATED" then
        -- Zone boundary: the player's mapID may have changed, so the parent-map
        -- hierarchy cache must also be invalidated.
        InvalidateMapLookup()
    end
end)

-- ============================================================================
-- RARE BOSS WAYPOINT
-- ============================================================================

--- Set a waypoint for a rare boss entry. TomTom first, then native API.
--- Does NOT open the world map.
--- @param entry table The rare boss entry from the tracker
local function SetRareWaypoint(entry)
    if not entry then return end

    local vignetteGUID = entry.vignetteGUID or (entry.entryKey and entry.entryKey:match("^vignette:(.+)$"))
    local mapID = entry.vignetteMapID
    local x, y = entry.vignetteX, entry.vignetteY
    local name = entry.title or "Rare"

    if not mapID and C_Map and C_Map.GetBestMapForUnit then
        mapID = C_Map.GetBestMapForUnit("player")
    end
    -- If we have a vignetteGUID but no position, try to fetch it now. GetVignettePosition requires uiMapID.
    if vignetteGUID and (not x or not y) and mapID and C_VignetteInfo and C_VignetteInfo.GetVignettePosition then
        local ok, pos = pcall(C_VignetteInfo.GetVignettePosition, vignetteGUID, mapID)
        if ok and pos then
            x = pos.x or (pos.GetXY and select(1, pos:GetXY()))
            y = pos.y or (pos.GetXY and select(2, pos:GetXY()))
        end
    end

    -- Priority 1: TomTom addon
    local TomTom = _G.TomTom
    if TomTom and TomTom.AddWaypoint and mapID and x and y then
        pcall(TomTom.AddWaypoint, TomTom, mapID, x, y, { title = name, persistent = false, minimap = true, world = true, crazy = true })
        return
    end

    -- Priority 2: Native waypoint (no map opening)
    if vignetteGUID and C_SuperTrack and C_SuperTrack.SetSuperTrackedVignette then
        C_SuperTrack.SetSuperTrackedVignette(vignetteGUID)
        return
    end

    -- Priority 3: C_Map.SetUserWaypoint for known coordinates
    if mapID and x and y and C_Map and C_Map.SetUserWaypoint then
        local uiMapPoint = UiMapPoint and UiMapPoint.CreateFromCoordinates(mapID, x, y)
        if uiMapPoint then
            pcall(C_Map.SetUserWaypoint, uiMapPoint)
            if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, true)
            end
        end
    end
end

addon.SetRareWaypoint = SetRareWaypoint

-- ============================================================================
-- RARE BOSS SOUND
-- ============================================================================

local RARE_SOUND_RESTORE_DELAY = 0.5

--- Apply volume multiplier by temporarily boosting Master volume, then restore.
--- @param mult number Multiplier (e.g. 1.5 for 150%)
--- @param playFn function Callback to play the sound
local function PlayWithVolumeBoost(mult, playFn)
    if not (GetCVar and SetCVar) or mult <= 0 then
        playFn()
        return
    end
    if mult >= 0.99 and mult <= 1.01 then
        playFn()
        return
    end
    local saved = GetCVar("Sound_MasterVolume")
    if saved then
        local cur = tonumber(saved) or 1
        local boosted = math.min(1, cur * mult)
        pcall(SetCVar, "Sound_MasterVolume", tostring(boosted))
        playFn()
        C_Timer.After(RARE_SOUND_RESTORE_DELAY, function()
            if GetCVar and SetCVar then pcall(SetCVar, "Sound_MasterVolume", saved) end
        end)
    else
        playFn()
    end
end

--- Play the user-selected rare-added sound. Uses SharedMedia if a custom sound is chosen.
function addon.PlayRareAddedSound()
    if not addon.GetDB("rareAddedSound", true) then return end
    local volPct = tonumber(addon.GetDB("rareAddedSoundVolume", 100)) or 100
    local mult = volPct / 100
    local choice = addon.GetDB("rareAddedSoundChoice", "default")
    local function doPlay()
        if choice == "default" or not choice or choice == "" then
            if PlaySound then pcall(PlaySound, addon.RARE_ADDED_SOUND) end
            return
        end
        local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
        if LSM then
            local path = LSM:Fetch("sound", choice)
            if path and PlaySoundFile then
                pcall(PlaySoundFile, path, "Master")
                return
            end
        end
        if PlaySound then pcall(PlaySound, addon.RARE_ADDED_SOUND) end
    end
    PlayWithVolumeBoost(mult, doPlay)
end

