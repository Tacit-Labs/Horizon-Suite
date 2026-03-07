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

local function IsNpcVignetteAtlas(atlasName)
    if not atlasName or atlasName == "" then return false end
    local lower = atlasName:lower()
    if lower:find("loot") or lower:find("treasure") or lower:find("container") or lower:find("chest") or lower:find("object") then
        return false
    end
    if lower:find("rare") or lower:find("elite") or lower:find("npc") or lower:find("vignettekill") then
        return true
    end
    return false
end

local function IsTreasureVignetteAtlas(atlasName)
    if not atlasName or atlasName == "" then return false end
    local lower = atlasName:lower()
    return lower:find("loot") or lower:find("treasure") or lower:find("container") or lower:find("chest") or lower:find("object")
end

local function GetRaresOnMap()
    local out = {}
    local rareColor = addon.GetQuestColor("RARE")

    if C_VignetteInfo and C_VignetteInfo.GetVignettes and C_VignetteInfo.GetVignetteInfo then
        local vignettes = C_VignetteInfo.GetVignettes()
        if vignettes then
            local seen = {}
            for _, vignetteGUID in ipairs(vignettes) do
                local vi = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
                if vi and (vi.name and vi.name ~= "") then
                    if IsNpcVignetteAtlas(vi.atlasName) then
                        local creatureID = vi.npcID or vi.creatureID
                        if not creatureID and vi.objectGUID then
                            local _, _, _, _, _, id, _ = strsplit("-", vi.objectGUID)
                            creatureID = tonumber(id)
                        end
                        if creatureID then
                            local dedupeKey = creatureID and ("c:" .. tostring(creatureID)) or ("n:" .. (vi.name or ""))
                            if seen[dedupeKey] then
                                -- skip duplicate (same creature from multiple vignette GUIDs)
                            else
                                seen[dedupeKey] = true
                                -- Get vignette position for waypoint support. GetVignettePosition requires uiMapID.
                                local vX, vY, vMapID
                                if C_Map and C_Map.GetBestMapForUnit then
                                    vMapID = C_Map.GetBestMapForUnit("player")
                                end
                                if vMapID and C_VignetteInfo.GetVignettePosition then
                                    local ok, pos = pcall(C_VignetteInfo.GetVignettePosition, vignetteGUID, vMapID)
                                    if ok and pos then
                                        vX = pos.x or (pos.GetXY and select(1, pos:GetXY()))
                                        vY = pos.y or (pos.GetXY and select(2, pos:GetXY()))
                                    end
                                end
                                out[#out + 1] = {
                                    entryKey    = "vignette:" .. tostring(vignetteGUID),
                                    questID     = nil,
                                    title       = vi.name or "Unknown",
                                    objectives  = {},
                                    color       = rareColor,
                                    category    = "RARE",
                                    isComplete  = false,
                                    isSuperTracked = false,
                                    isNearby    = true,
                                    zoneName    = nil,
                                    itemLink    = nil,
                                    itemTexture = nil,
                                    isRare      = true,
                                    creatureID  = creatureID,
                                    vignetteGUID = vignetteGUID,
                                    vignetteMapID = vMapID,
                                    vignetteX   = vX,
                                    vignetteY   = vY,
                                }
                            end
                        end
                    end
                end
            end
        end
        if #out > 0 then
            return out
        end
    end

    if not C_Map or not C_Map.GetBestMapForUnit then return out end
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then return out end

    local rares = RARES_BY_MAP[mapID]
    if not rares and C_Map.GetMapInfo then
        local current = mapID
        for _ = 1, 20 do
            local parentInfo = C_Map.GetMapInfo(current)
            if not parentInfo or not parentInfo.parentMapID then break end
            current = parentInfo.parentMapID
            rares = RARES_BY_MAP[current]
            if rares then break end
        end
    end
    if not rares then return out end

    local mapInfo = C_Map.GetMapInfo and C_Map.GetMapInfo(mapID)
    local zoneName = mapInfo and mapInfo.name or nil
    for _, t in ipairs(rares) do
        local creatureID, name = t[1], t[2]
        if creatureID and name then
            out[#out + 1] = {
                entryKey   = "rare:" .. tostring(creatureID),
                questID    = nil,
                title      = name,
                objectives = {},
                color      = rareColor,
                category   = "RARE",
                isComplete = false,
                isSuperTracked = false,
                isNearby   = true,
                zoneName   = zoneName,
                itemLink   = nil,
                itemTexture = nil,
                isRare     = true,
                creatureID = creatureID,
            }
        end
    end
    return out
end

local function GetTreasuresOnMap()
    local out = {}
    local rareLootColor = addon.GetQuestColor and addon.GetQuestColor("RARE_LOOT") or addon.GetQuestColor("RARE")

    if C_VignetteInfo and C_VignetteInfo.GetVignettes and C_VignetteInfo.GetVignetteInfo then
        local vignettes = C_VignetteInfo.GetVignettes()
        if vignettes then
            local seen = {}
            for _, vignetteGUID in ipairs(vignettes) do
                local vi = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
                if vi and (vi.name and vi.name ~= "") and IsTreasureVignetteAtlas(vi.atlasName) then
                    local vX, vY, vMapID
                    if C_Map and C_Map.GetBestMapForUnit then
                        vMapID = C_Map.GetBestMapForUnit("player")
                    end
                    if vMapID and C_VignetteInfo.GetVignettePosition then
                        local ok, pos = pcall(C_VignetteInfo.GetVignettePosition, vignetteGUID, vMapID)
                        if ok and pos then
                            vX = pos.x or (pos.GetXY and select(1, pos:GetXY()))
                            vY = pos.y or (pos.GetXY and select(2, pos:GetXY()))
                        end
                    end
                    local dedupeKey = (vMapID and vX and vY)
                        and ("p:%s:%.2f:%.2f"):format(tostring(vMapID), vX or 0, vY or 0)
                        or (vi.vignetteID and ("v:" .. tostring(vi.vignetteID)) or ("n:" .. (vi.name or "")))
                    if seen[dedupeKey] then
                        -- skip duplicate (same treasure from multiple vignette GUIDs)
                    else
                        seen[dedupeKey] = true
                    local zoneName
                    if vMapID and C_Map and C_Map.GetMapInfo then
                        local info = C_Map.GetMapInfo(vMapID)
                        zoneName = info and info.name or nil
                    end
                    out[#out + 1] = {
                        entryKey       = "vignette:" .. tostring(vignetteGUID),
                        questID        = nil,
                        title          = vi.name or "Unknown",
                        objectives     = {},
                        color          = rareLootColor,
                        category       = "RARE_LOOT",
                        isComplete     = false,
                        isSuperTracked = false,
                        isNearby       = true,
                        zoneName       = zoneName,
                        itemLink       = nil,
                        itemTexture    = nil,
                        isRareLoot     = true,
                        vignetteGUID   = vignetteGUID,
                        vignetteID     = vi.vignetteID,
                        vignetteMapID  = vMapID,
                        vignetteX      = vX,
                        vignetteY      = vY,
                        questTypeAtlas = vi.atlasName,
                    }
                    end
                end
            end
        end
    end
    return out
end

addon.GetRaresOnMap = GetRaresOnMap
addon.GetTreasuresOnMap = GetTreasuresOnMap

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

