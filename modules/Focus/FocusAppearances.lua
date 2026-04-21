--[[
    Horizon Suite - Focus - Transmog appearance tracking
    C_ContentTracking.GetTrackedIDs(ContentTrackingType.Appearance) for appearances tracked in the Collections UI.
    IDs are Blizzard content-tracking IDs (typically item modified appearance source IDs).
    Mouse/click behaviour for appearance rows lives in FocusInteractions.lua (same click profile as quests).
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then _G.HorizonSuite = {} end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- Blizzard UI atlases that represent transmog / Appearances (first match via C_Texture.GetAtlasExists wins).
local TRANSMOG_TYPE_ICON_ATLAS_CANDIDATES = {
    "services-icon-transmogrification",
    "hud-micro-button-ManagedTransmog-Up",
    "hud-micro-button-ManagedTransmog-Down",
    "transmog-icon",
    "worldquest-icon-transmog",
    "poi-transmogrifier",
}

local transmogTypeIconAtlasCache = { done = false, atlas = nil }

-- Resolve a single shared atlas for “transmog list” icon (cached after first lookup).
--- @return string|nil
local function GetResolvedTransmogTypeIconAtlas()
    if transmogTypeIconAtlasCache.done then
        return transmogTypeIconAtlasCache.atlas
    end
    transmogTypeIconAtlasCache.done = true
    if C_Texture and C_Texture.GetAtlasExists then
        for _, name in ipairs(TRANSMOG_TYPE_ICON_ATLAS_CANDIDATES) do
            local ok, exists = pcall(C_Texture.GetAtlasExists, name)
            if ok and exists then
                transmogTypeIconAtlasCache.atlas = name
                return name
            end
        end
    end
    return nil
end

-- ============================================================================
-- APPEARANCE DATA PROVIDER
-- ============================================================================

--- Resolve objective hint from content tracking (vendor / drop / etc.).
--- @param trackableType number Enum.ContentTrackingType value
--- @param trackableID number
--- @return string|nil
local function GetTrackingObjectiveText(trackableType, trackableID)
    if not C_ContentTracking or not C_ContentTracking.GetCurrentTrackingTarget or not C_ContentTracking.GetObjectiveText then
        return nil
    end
    local ok, targetType, targetID = pcall(C_ContentTracking.GetCurrentTrackingTarget, trackableType, trackableID)
    if not ok or targetType == nil or targetID == nil then return nil end
    local ok2, text = pcall(C_ContentTracking.GetObjectiveText, targetType, targetID, true)
    if ok2 and text and type(text) == "string" and text ~= "" then return text end
    return nil
end

--- Title, optional icon (fileID), optional item link for tooltips, collected flag.
--- @param trackableType number
--- @param appearanceID number Content tracking ID
--- @return string title, number|string|nil icon, string|nil itemLink, boolean isCollected
local function GetAppearanceDisplayInfo(trackableType, appearanceID)
    local fallbackTitle = "Appearance " .. tostring(appearanceID)
    local title = fallbackTitle
    if C_ContentTracking and C_ContentTracking.GetTitle then
        local ok, t = pcall(C_ContentTracking.GetTitle, trackableType, appearanceID)
        if ok and t and type(t) == "string" and t ~= "" then title = t end
    end

    local icon, itemLink = nil, nil
    local isCollected = false
    if C_TransmogCollection and C_TransmogCollection.GetAppearanceSourceInfo then
        local sOk, info = pcall(C_TransmogCollection.GetAppearanceSourceInfo, appearanceID)
        if sOk and info and type(info) == "table" then
            if info.icon then icon = info.icon end
            if info.itemLink and type(info.itemLink) == "string" and info.itemLink ~= "" then itemLink = info.itemLink end
        end
    end
    if C_TransmogCollection and C_TransmogCollection.GetAppearanceInfoBySource then
        local aOk, ainfo = pcall(C_TransmogCollection.GetAppearanceInfoBySource, appearanceID)
        if aOk and ainfo and type(ainfo) == "table" and ainfo.sourceIsCollected == true then
            isCollected = true
        end
    end

    return title, icon, itemLink, isCollected
end

--- Build tracker rows from WoW tracked transmog appearances.
--- @return table Array of normalized entry tables for the tracker
local function ReadTrackedAppearances()
    local out = {}
    if not addon.GetDB("showAppearances", true) then return out end
    if not (Enum and Enum.ContentTrackingType and Enum.ContentTrackingType.Appearance) then return out end
    if not C_ContentTracking or not C_ContentTracking.GetTrackedIDs then return out end

    local trackType = Enum.ContentTrackingType.Appearance
    local ok, ids = pcall(C_ContentTracking.GetTrackedIDs, trackType)
    if not ok or not ids or type(ids) ~= "table" then return out end

    local idList = {}
    for _, id in ipairs(ids) do
        if type(id) == "number" and id > 0 then
            idList[#idList + 1] = id
        end
    end
    if #idList == 0 then return out end

    local appearanceColor = (addon.GetQuestColor and addon.GetQuestColor("APPEARANCE"))
        or (addon.QUEST_COLORS and addon.QUEST_COLORS.APPEARANCE)
        or { 135/255, 96/255, 1 }
    local showCollected = addon.GetDB and addon.GetDB("showCollectedAppearances", false)
    local useTransmogTypeIcon = addon.GetDB and addon.GetDB("appearanceIconsUseTransmogTypeIcon", true)
    local transmogListAtlas = useTransmogTypeIcon and GetResolvedTransmogTypeIconAtlas() or nil

    local superType, superID = nil, nil
    if C_SuperTrack and C_SuperTrack.GetSuperTrackedContent then
        local ok, t, id = pcall(C_SuperTrack.GetSuperTrackedContent)
        if ok and t ~= nil and id ~= nil then
            superType, superID = t, id
        end
    end

    for _, appearanceID in ipairs(idList) do
        local title, icon, itemLink, isCollected = GetAppearanceDisplayInfo(trackType, appearanceID)
        if isCollected and not showCollected then
            -- Skip collected appearances unless the player opted in (mirror achievements / endeavors).
        else
            local objectives = {}
            local objText = GetTrackingObjectiveText(trackType, appearanceID)
            if objText then
                objectives[1] = { text = objText, finished = isCollected, percent = nil }
            end
            local appearanceIcon, appearanceIconAtlas = nil, nil
            if useTransmogTypeIcon and transmogListAtlas then
                appearanceIconAtlas = transmogListAtlas
            end
            if not appearanceIconAtlas then
                appearanceIcon = (icon and (type(icon) == "number" or (type(icon) == "string" and icon ~= ""))) and icon or nil
            end
            local isAppearanceFocused = (superType == trackType and superID == appearanceID)
            out[#out + 1] = {
                entryKey               = "appearance:" .. tostring(appearanceID),
                appearanceID           = appearanceID,
                questID                = nil,
                title                  = title,
                objectives             = objectives,
                color                  = appearanceColor,
                category               = "APPEARANCE",
                isComplete             = isCollected,
                isSuperTracked         = isAppearanceFocused,
                isNearby               = false,
                zoneName               = nil,
                itemLink               = nil,
                itemTexture            = nil,
                isAppearance           = true,
                isTracked              = true,
                appearanceIcon         = appearanceIcon,
                appearanceIconAtlas    = appearanceIconAtlas,
                appearanceItemLink     = itemLink,
            }
        end
    end

    return out
end

-- ============================================================================
-- COLLECTIONS UI
-- ============================================================================

--- Open the Collections Appearances (wardrobe) UI for a tracked appearance source ID.
--- Uses the canonical Blizzard flow from Blizzard_Wardrobe.lua:
---     WardrobeCollectionFrame:GoToItem(sourceID)
--- which internally calls SetTab(TAB_ITEMS), resolves the categoryID via
--- C_TransmogCollection.GetAppearanceSourceInfo, builds a transmogLocation with
--- TransmogUtil.GetTransmogLocation, and calls ItemsCollectionFrame:GoToSourceID.
--- When GoToItem is missing we reproduce the same steps manually so we never silently
--- land on the default slot (Head). Retries cover the frame/data lag between
--- ToggleCollectionsJournal and the wardrobe being ready to scroll.
--- @param itemModifiedAppearanceID number ID from content tracking (appearance source)
--- @return nil
local function OpenTrackedAppearanceInCollections(itemModifiedAppearanceID)
    if type(itemModifiedAppearanceID) ~= "number" or itemModifiedAppearanceID <= 0 then
        return
    end
    if InCombatLockdown() then
        return
    end

    if C_AddOns and C_AddOns.LoadAddOn then
        pcall(C_AddOns.LoadAddOn, "Blizzard_Collections")
    end

    -- Manual fallback when WardrobeCollectionFrame:GoToItem is unavailable. Mirrors
    -- WardrobeCollectionFrameMixin:GoToItem (Blizzard_Wardrobe.lua) step-for-step.
    local function manualGoToSource()
        local frame = _G.WardrobeCollectionFrame
        if not frame then return end
        local itemsTabID = frame.ITEMS_COLLECTION_TAB or 1
        if type(frame.SetTab) == "function" then
            pcall(frame.SetTab, frame, itemsTabID)
        end
        if not (C_TransmogCollection and C_TransmogCollection.GetAppearanceSourceInfo) then return end
        local okInfo, categoryID = pcall(C_TransmogCollection.GetAppearanceSourceInfo, itemModifiedAppearanceID)
        if not okInfo or type(categoryID) ~= "number" or categoryID <= 0 then return end
        if not (CollectionWardrobeUtil and CollectionWardrobeUtil.GetSlotFromCategoryID) then return end
        local okSlot, slot = pcall(CollectionWardrobeUtil.GetSlotFromCategoryID, categoryID)
        if not okSlot or not slot then return end
        if not (TransmogUtil and TransmogUtil.GetTransmogLocation) then return end
        local tType = Enum and Enum.TransmogType and Enum.TransmogType.Appearance
        local tMod  = Enum and Enum.TransmogModification and Enum.TransmogModification.Main
        local okLoc, transmogLocation = pcall(TransmogUtil.GetTransmogLocation, slot, tType, tMod)
        if not okLoc or not transmogLocation then return end
        local items = frame.ItemsCollectionFrame or _G.WardrobeCollectionItemsCollectionFrame
        if items and type(items.GoToSourceID) == "function" then
            pcall(items.GoToSourceID, items, itemModifiedAppearanceID, transmogLocation)
        end
    end

    -- pcall only suppresses errors; it does not mean the list scrolled to the source.
    local function tryGoToSource()
        if InCombatLockdown() then return end
        local frame = _G.WardrobeCollectionFrame
        if frame and type(frame.GoToItem) == "function" then
            pcall(frame.GoToItem, frame, itemModifiedAppearanceID)
            return
        end
        manualGoToSource()
    end

    local tab = nil
    if Enum and Enum.CollectionsJournalTab then
        tab = Enum.CollectionsJournalTab.Transmog or Enum.CollectionsJournalTab.Appearances
    end
    if ToggleCollectionsJournal then
        if tab ~= nil then
            pcall(ToggleCollectionsJournal, tab)
        else
            pcall(ToggleCollectionsJournal)
        end
    end

    -- Multiple retry windows: the wardrobe's slot data can lag several frames behind the tab toggle,
    -- so a single call often resolves to the default slot (Head) before the real source slot is
    -- ready. 0 / 0.1 / 0.25 / 0.5 covers layout, data fetch, and first paint.
    tryGoToSource()
    if C_Timer and C_Timer.After then
        C_Timer.After(0, tryGoToSource)
        C_Timer.After(0.1, tryGoToSource)
        C_Timer.After(0.25, tryGoToSource)
        C_Timer.After(0.5, tryGoToSource)
    end
end

addon.ReadTrackedAppearances = ReadTrackedAppearances
addon.OpenTrackedAppearanceInCollections = OpenTrackedAppearanceInCollections
