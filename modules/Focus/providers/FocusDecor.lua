--[[
    Horizon Suite - Focus - Decor Tracking
    C_ContentTracking.GetTrackedIDs(ContentTrackingType.Decor) for tracked housing decor.
]]

local addon = _G.HorizonSuite

-- ============================================================================
-- DECOR DATA PROVIDER
-- ============================================================================

local TRACKING_TYPE_DECOR = (Enum and Enum.ContentTrackingType and Enum.ContentTrackingType.Decor) or 3

--- Get decor display info. Uses C_ContentTracking.GetTitle, C_HousingDecor.GetDecorName, or C_PlayerHousing fallbacks.
-- @param decorID number
-- @return string name, number|string icon
local function GetDecorDisplayInfo(decorID)
    -- C_ContentTracking.GetTitle is the canonical API for content-tracked items
    if C_ContentTracking and C_ContentTracking.GetTitle then
        local ok, title = pcall(C_ContentTracking.GetTitle, TRACKING_TYPE_DECOR, decorID)
        if ok and title and title ~= "" then
            local icon = nil
            if C_HousingDecor and C_HousingDecor.GetDecorIcon then
                local iconOk, iconVal = pcall(C_HousingDecor.GetDecorIcon, decorID)
                if iconOk and iconVal then icon = iconVal end
            end
            return title, icon
        end
    end
    if C_HousingDecor and C_HousingDecor.GetDecorName then
        local ok, name = pcall(C_HousingDecor.GetDecorName, decorID)
        if ok and name and name ~= "" then
            local icon = nil
            if C_HousingDecor.GetDecorIcon then
                local iconOk, iconVal = pcall(C_HousingDecor.GetDecorIcon, decorID)
                if iconOk and iconVal then icon = iconVal end
            end
            return name, icon
        end
    end
    if C_HousingDecor and C_HousingDecor.GetInfo then
        local ok, name, icon = pcall(C_HousingDecor.GetInfo, decorID)
        if ok and name and name ~= "" then
            return name, icon
        end
    end
    if C_PlayerHousing and C_PlayerHousing.GetDecorInfo then
        local ok, info = pcall(C_PlayerHousing.GetDecorInfo, decorID)
        if ok and info and type(info) == "table" then
            local name = info.name or info.title
            if name and name ~= "" then
                return name, info.icon or info.texture
            end
        end
    end
    return "Decor " .. tostring(decorID), nil
end

--- Build tracker rows from WoW tracked housing decor.
-- @return table Array of normalized entry tables for the tracker
local function ReadTrackedDecor()
    local out = {}
    if not addon.GetDB("showDecor", true) then return out end

    if not C_ContentTracking or not C_ContentTracking.GetTrackedIDs then return out end

    local ok, ids = pcall(C_ContentTracking.GetTrackedIDs, TRACKING_TYPE_DECOR)
    if not ok or not ids or type(ids) ~= "table" then return out end

    local idList = {}
    for _, id in ipairs(ids) do
        if type(id) == "number" and id > 0 then
            idList[#idList + 1] = id
        end
    end
    if #idList == 0 then return out end

    local decorColor = (addon.GetQuestColor and addon.GetQuestColor("DECOR")) or (addon.QUEST_COLORS and addon.QUEST_COLORS.DECOR) or { 0.65, 0.55, 0.45 }

    for _, decorID in ipairs(idList) do
        local name, icon = GetDecorDisplayInfo(decorID)
        local decorIcon = (icon and (type(icon) == "number" or (type(icon) == "string" and icon ~= ""))) and icon or nil
        out[#out + 1] = {
            entryKey       = "decor:" .. tostring(decorID),
            decorID        = decorID,
            questID        = nil,
            title          = name or ("Decor " .. tostring(decorID)),
            objectives     = {},
            color          = decorColor,
            category       = "DECOR",
            isComplete     = false,
            isSuperTracked = false,
            isNearby       = false,
            zoneName       = nil,
            itemLink       = nil,
            itemTexture    = nil,
            isDecor        = true,
            isTracked      = true,
            decorIcon      = decorIcon,
        }
    end

    return out
end

addon.ReadTrackedDecor = ReadTrackedDecor
