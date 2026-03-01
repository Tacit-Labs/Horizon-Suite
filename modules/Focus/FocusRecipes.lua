--[[
    Horizon Suite - Focus - Recipe Tracking
    C_TradeSkillUI data provider for tracked profession recipes.
    When the player tracks a recipe in the profession UI, it appears in the tracker.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- ============================================================================
-- REAGENT TYPE CONSTANTS
-- ============================================================================

local REAGENT_TYPE_MODIFYING = (Enum and Enum.CraftingReagentType and Enum.CraftingReagentType.Modifying) or 0
local REAGENT_TYPE_BASIC     = (Enum and Enum.CraftingReagentType and Enum.CraftingReagentType.Basic) or 1
local REAGENT_TYPE_FINISHING = (Enum and Enum.CraftingReagentType and Enum.CraftingReagentType.Finishing) or 2

-- ============================================================================
-- ITEM RESOLUTION HELPER
-- ============================================================================

-- Item info cache: persists across layout passes so resolved items aren't re-requested.
-- Entries: itemInfoCache[itemID] = { name, link, itemQuality } or false (pending).
local itemInfoCache = {}

-- Batch item loading: track how many items are still loading per layout pass
-- and schedule a single coalesced refresh once ALL pending items have arrived.
-- The generation counter invalidates stale callbacks from previous passes so
-- the pending count cannot accumulate across FullLayout calls.
local pendingItemLoads = 0
local refreshScheduled = false
local loadGeneration = 0
local MAX_REFRESH_RETRIES = 3
local refreshRetryCount = 0

local function OnItemLoaded(gen)
    -- Ignore callbacks from a previous layout pass (stale Item objects).
    if gen ~= loadGeneration then return end
    pendingItemLoads = pendingItemLoads - 1
    if pendingItemLoads <= 0 and not refreshScheduled and refreshRetryCount < MAX_REFRESH_RETRIES then
        refreshScheduled = true
        refreshRetryCount = refreshRetryCount + 1
        C_Timer.After(0.35, function()
            refreshScheduled = false
            pendingItemLoads = 0
            -- Dirty the result cache so the next layout pass rebuilds with resolved items.
            resultCacheDirty = true
            if addon.ScheduleRefresh then addon.ScheduleRefresh() end
        end)
    end
end

--- Call at the start of each ReadTrackedRecipes pass to reset item-load tracking.
local function BeginItemLoadPass()
    loadGeneration = loadGeneration + 1
    pendingItemLoads = 0
    refreshScheduled = false
    refreshRetryCount = 0
    -- Clear stale "pending" markers so items that failed to load can be re-requested.
    -- Fully resolved entries (tables) are kept.
    for id, v in pairs(itemInfoCache) do
        if v == false then itemInfoCache[id] = nil end
    end
end

--- Schedule a safety-net refresh if any items were requested but callbacks may not fire.
local function EndItemLoadPass()
    if pendingItemLoads > 0 and refreshRetryCount < MAX_REFRESH_RETRIES then
        C_Timer.After(1.0, function()
            if pendingItemLoads > 0 then
                pendingItemLoads = 0
                refreshScheduled = false
                if addon.ScheduleRefresh then addon.ScheduleRefresh() end
            end
        end)
    end
end

--- Resolve item name, link, and quality for an itemID.
-- Tries GetItemInfo first, falls back to Item:CreateFromItemID for uncached items.
-- When an item is uncached, requests a background load and increments the pending
-- counter; a single refresh fires once all pending items have loaded.
-- Returns nil name when item data is not yet available — callers should skip the entry.
-- @param itemID number
-- @return string|nil name, string link, number|nil itemQuality
local function ResolveItemInfo(itemID)
    -- Check persistent cache first to avoid re-requesting on every layout pass.
    local cached = itemInfoCache[itemID]
    if cached and cached ~= false then
        return cached[1], cached[2], cached[3]
    end

    local name, link, itemQuality = GetItemInfo(itemID)
    if name then
        link = link or ("item:" .. tostring(itemID))
        itemInfoCache[itemID] = { name, link, itemQuality }
        return name, link, itemQuality
    end

    -- Already have a pending request for this item — don't request again.
    if cached == false then
        return nil, "item:" .. tostring(itemID), nil
    end

    -- Item not cached — request async load (once per itemID).
    itemInfoCache[itemID] = false
    local gen = loadGeneration
    if Item and Item.CreateFromItemID then
        local item = Item:CreateFromItemID(itemID)
        if item then
            if item.GetItemLink then link = item:GetItemLink() end
            if item.ContinueOnItemLoad then
                pendingItemLoads = pendingItemLoads + 1
                item:ContinueOnItemLoad(function()
                    -- Populate cache when the data arrives.
                    local n, l, q = GetItemInfo(itemID)
                    if n then itemInfoCache[itemID] = { n, l or ("item:" .. tostring(itemID)), q } end
                    OnItemLoaded(gen)
                end)
            end
        end
    end
    -- Extract name from link if available
    if link then
        name = link:match("%[(.-)%]")
        if name then
            itemInfoCache[itemID] = { name, link, itemQuality }
            return name, link, itemQuality
        end
    end
    -- Truly uncached — return nil so callers skip this entry until data arrives
    return nil, "item:" .. tostring(itemID), nil
end

--- Get item count from bags, bank, reagent bank, and warband bank.
-- @param itemID number
-- @return number
local function GetOwnedCount(itemID)
    if not C_Item or not C_Item.GetItemCount then return 0 end
    -- Args: itemID, includeBank, includeUses, includeReagentBank, includeAccountBank
    local ok, count = pcall(C_Item.GetItemCount, itemID, true, false, true, true)
    return (ok and type(count) == "number") and count or 0
end

-- ============================================================================
-- TRACKED RECIPE IDS
-- ============================================================================

--- Resolve tracked recipe IDs with isRecraft flag from C_TradeSkillUI.GetRecipesTracked.
-- @return table Array of { recipeID = number, isRecraft = boolean }
local function GetTrackedRecipeIDs()
    local idList = {}
    if not C_TradeSkillUI or not C_TradeSkillUI.GetRecipesTracked then return idList end

    local seen = {}
    for _, isRecraft in ipairs({ false, true }) do
        local ok, ids = pcall(C_TradeSkillUI.GetRecipesTracked, isRecraft)
        if ok and ids and type(ids) == "table" then
            for _, id in ipairs(ids) do
                local seenKey = tostring(id) .. (isRecraft and ":r" or "")
                if type(id) == "number" and id > 0 and not seen[seenKey] then
                    seen[seenKey] = true
                    idList[#idList + 1] = { recipeID = id, isRecraft = isRecraft }
                end
            end
        end
    end
    return idList
end

-- ============================================================================
-- REAGENT DEDUPLICATION
-- ============================================================================

--- Deduplicate reagents by name (quality-tier variants share a name but have distinct itemIDs).
-- Merges owned counts and keeps the highest-quality itemID for display.
-- @param raw table Array of { name, itemID, link, owned, qtyRequired, itemQuality[, currencyID] }
-- @return table Array of deduplicated entries in original order
local function DedupeByName(raw)
    if #raw == 0 then return {} end
    local byName, order = {}, {}
    for _, r in ipairs(raw) do
        local key = r.name or (r.currencyID and ("currency:" .. tostring(r.currencyID))) or ("item:" .. tostring(r.itemID))
        if not byName[key] then
            byName[key] = { name = r.name, itemID = r.itemID, currencyID = r.currencyID, link = r.link, owned = 0, qtyRequired = r.qtyRequired, itemQuality = r.itemQuality }
            order[#order + 1] = key
        end
        byName[key].owned = byName[key].owned + r.owned
        -- Keep the highest-quality variant's itemID/link for display.
        if r.itemID and (r.itemQuality or 0) > (byName[key].itemQuality or 0) then
            byName[key].itemID = r.itemID
            byName[key].link = r.link
            byName[key].itemQuality = r.itemQuality
        end
    end
    local out = {}
    for _, key in ipairs(order) do
        out[#out + 1] = byName[key]
    end
    return out
end

--- Deduplicate reagents and append as objectives. Optionally prepends a section header.
-- @param raw table Array of raw reagent entries
-- @param objectives table Array to append to
-- @param sectionHeader string|nil Header text for this section
-- @param sectionType string|nil "finishing" | "optional" | nil
local function DedupeAndAppend(raw, objectives, sectionHeader, sectionType)
    if #raw == 0 then return end
    local deduped = DedupeByName(raw)
    if sectionHeader and sectionType then
        objectives[#objectives + 1] = {
            text             = sectionHeader,
            isSectionHeader  = true,
            isFinishingHeader = (sectionType == "finishing"),
            isOptionalHeader  = (sectionType == "optional"),
            isCollapsible    = true,
            sectionCount     = #deduped,
        }
    end
    for _, agg in ipairs(deduped) do
        local obj = {
            text         = agg.name,
            numFulfilled = agg.owned,
            numRequired  = agg.qtyRequired,
            itemID       = agg.itemID,
            currencyID   = agg.currencyID,
            itemLink     = agg.link,
            itemQuality  = agg.itemQuality,
            finished     = (agg.owned >= (agg.qtyRequired or 1)),
        }
        if sectionType == "finishing" then obj.isFinishingReagent = true end
        if sectionType == "optional" then obj.isOptionalReagent = true end
        objectives[#objectives + 1] = obj
    end
end

-- ============================================================================
-- RECIPE OBJECTIVES (REAGENT SHOPPING LIST)
-- ============================================================================

--- Returns true if a reagent slot is a choice slot (multiple options, pick 1).
local function IsChoiceSlot(slot)
    local reagents = slot and slot.reagents
    return reagents and type(reagents) == "table" and #reagents > 1 and (slot.quantityRequired or 1) == 1
end

--- Derive a display name for a choice slot header from its variant names.
-- Uses the first variant's name + " (any)".
local function DeriveChoiceHeaderName(variants)
    if #variants == 0 then return "Item (any)" end
    local firstName = variants[1].text or "Item"
    return firstName .. " (any)"
end

--- Collect raw reagent info for a single item-based reagent.
-- Returns nil if item data is not yet cached (a deferred refresh is already scheduled).
-- @return table|nil { name, itemID, link, owned, qtyRequired, itemQuality }
local function CollectItemReagent(itemID, qtyRequired)
    local name, link, itemQuality = ResolveItemInfo(itemID)
    if not name then return nil end
    local owned = GetOwnedCount(itemID)
    return { name = name, itemID = itemID, link = link, owned = owned, qtyRequired = qtyRequired, itemQuality = itemQuality }
end

--- Collect raw reagent info for a currency-based reagent.
-- @return table|nil
local function CollectCurrencyReagent(currencyID, qtyRequired)
    local info = C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo(currencyID)
    if not info then return nil end
    return { name = info.name, itemID = nil, currencyID = currencyID, link = nil, owned = info.quantity or 0, qtyRequired = qtyRequired }
end

--- Build choice slot data from a reagent slot with multiple options.
-- @return table { choiceSlotKey, baseName, numFulfilled, numRequired, finished, variants }
local function BuildChoiceSlot(slot, recipeID, slotIdx)
    local raw = {}
    for _, reagent in ipairs(slot.reagents) do
        local itemID = reagent and reagent.itemID
        if type(itemID) == "number" and itemID > 0 then
            local name, link, itemQuality = ResolveItemInfo(itemID)
            if name then
                local owned = GetOwnedCount(itemID)
                raw[#raw + 1] = { name = name, itemID = itemID, link = link, owned = owned, qtyRequired = 1, itemQuality = itemQuality }
            end
        end
    end
    if #raw == 0 then return nil end

    -- Deduplicate quality-tier variants (same name, different itemIDs)
    local deduped = DedupeByName(raw)
    local variants, totalOwned = {}, 0
    for _, agg in ipairs(deduped) do
        local owned = agg.owned
        totalOwned = totalOwned + owned
        variants[#variants + 1] = {
            text = agg.name, itemID = agg.itemID, itemLink = agg.link,
            numFulfilled = owned, numRequired = 1,
            itemQuality = agg.itemQuality, finished = (owned >= 1),
        }
    end

    return {
        choiceSlotKey = "recipe:" .. tostring(recipeID) .. ":slot:" .. tostring(slotIdx),
        baseName      = DeriveChoiceHeaderName(variants),
        numFulfilled  = totalOwned,
        numRequired   = 1,
        finished      = (totalOwned >= 1),
        variants      = variants,
    }
end

--- Build reagent objectives for a recipe (shopping list: owned vs required).
-- @param recipeID number Recipe spell ID
-- @param isRecraft boolean
-- @return table Array of objective tables
local function BuildRecipeObjectives(recipeID, isRecraft)
    local objectives = {}
    if not addon.GetDB("showRecipeReagents", true) then return objectives end
    if not C_TradeSkillUI or not C_TradeSkillUI.GetRecipeSchematic then return objectives end

    local ok, schematic = pcall(C_TradeSkillUI.GetRecipeSchematic, recipeID, isRecraft, nil)
    if not ok or not schematic or type(schematic) ~= "table" or not schematic.reagentSlotSchematics then
        return objectives
    end

    local optionalHeader = (addon.L and addon.L["Optional reagents"]) or "Optional reagents"
    local finishingHeader = (addon.L and addon.L["Finishing reagents"]) or "Finishing reagents"
    local showOptional = addon.GetDB("showOptionalReagents", true)
    local showFinishing = addon.GetDB("showFinishingReagents", true)
    local showChoiceSlots = addon.GetDB("showChoiceSlots", true)

    local requiredRaw, optionalRaw, finishingRaw, choiceSlots = {}, {}, {}, {}

    for slotIdx, slot in ipairs(schematic.reagentSlotSchematics) do
        local reagentType = slot.reagentType
        local reagents = slot.reagents
        local qtyRequired = slot.quantityRequired or 1
        if reagents and type(reagents) == "table" then
            if IsChoiceSlot(slot) then
                local cs = BuildChoiceSlot(slot, recipeID, slotIdx)
                if cs then choiceSlots[#choiceSlots + 1] = cs end
            elseif reagentType == REAGENT_TYPE_BASIC or reagentType == REAGENT_TYPE_MODIFYING or reagentType == REAGENT_TYPE_FINISHING then
                local target
                if reagentType == REAGENT_TYPE_FINISHING then target = finishingRaw
                elseif reagentType == REAGENT_TYPE_MODIFYING then target = optionalRaw
                else target = requiredRaw end

                for _, reagent in ipairs(reagents) do
                    local itemID = reagent and reagent.itemID
                    if type(itemID) == "number" and itemID > 0 then
                        local entry = CollectItemReagent(itemID, qtyRequired)
                        if entry then target[#target + 1] = entry end
                    elseif reagent and type(reagent.currencyID) == "number" and reagent.currencyID > 0 then
                        local entry = CollectCurrencyReagent(reagent.currencyID, qtyRequired)
                        if entry then target[#target + 1] = entry end
                    end
                end
            end
        end
    end

    -- Required reagents first
    DedupeAndAppend(requiredRaw, objectives, nil, nil)

    -- Choice slots: collapsible headers with variants, or flat list
    for _, cs in ipairs(choiceSlots) do
        if showChoiceSlots then
            objectives[#objectives + 1] = {
                isChoiceHeader = true, isCollapsible = true,
                choiceSlotKey = cs.choiceSlotKey, text = cs.baseName,
                numFulfilled = cs.numFulfilled, numRequired = cs.numRequired,
                finished = cs.finished, variants = cs.variants,
            }
            for _, v in ipairs(cs.variants) do
                objectives[#objectives + 1] = {
                    isChoiceVariant = true, choiceSlotKey = cs.choiceSlotKey,
                    text = v.text, numFulfilled = v.numFulfilled, numRequired = v.numRequired,
                    itemID = v.itemID, itemLink = v.itemLink, itemQuality = v.itemQuality,
                    finished = v.finished,
                }
            end
        else
            for _, v in ipairs(cs.variants) do
                objectives[#objectives + 1] = {
                    text = v.text, numFulfilled = v.numFulfilled, numRequired = v.numRequired,
                    itemID = v.itemID, itemLink = v.itemLink, itemQuality = v.itemQuality,
                    finished = v.finished,
                }
            end
        end
    end

    -- Optional and finishing sections
    if showOptional and #optionalRaw > 0 then
        DedupeAndAppend(optionalRaw, objectives, optionalHeader, "optional")
    end
    if showFinishing and #finishingRaw > 0 then
        DedupeAndAppend(finishingRaw, objectives, finishingHeader, "finishing")
    end

    return objectives
end

-- ============================================================================
-- RECIPE REQUIREMENTS
-- ============================================================================

--- Build unmet crafting station requirements for a recipe.
-- @param recipeID number Recipe spell ID
-- @return table Array of { text, isRequirement, finished, numFulfilled, numRequired }
local function BuildRecipeRequirements(recipeID)
    local out = {}
    if not C_TradeSkillUI or not C_TradeSkillUI.GetRecipeRequirements then return out end
    local ok, reqs = pcall(C_TradeSkillUI.GetRecipeRequirements, recipeID)
    if not ok or type(reqs) ~= "table" then return out end
    for _, req in ipairs(reqs) do
        if req and req.met == false and type(req.name) == "string" and req.name ~= "" then
            out[#out + 1] = {
                text         = "Requires: " .. req.name,
                isRequirement = true,
                finished     = false,
                numFulfilled = 0,
                numRequired  = 1,
            }
        end
    end
    return out
end

-- ============================================================================
-- RECIPE OUTPUT QUALITY
-- ============================================================================

--- Get recipe output quality for display coloring.
-- Returns crafting quality tier (1-5) from schematic, or item rarity (0-7) as fallback.
-- @param recipeID number
-- @param isRecraft boolean|nil
-- @return number|nil quality value
local function GetRecipeOutputQuality(recipeID, isRecraft)
    if not C_TradeSkillUI then return nil end

    -- 1. Schematic: productQuality or outputItemID
    if C_TradeSkillUI.GetRecipeSchematic then
        local ok, schematic = pcall(C_TradeSkillUI.GetRecipeSchematic, recipeID, isRecraft or false, nil)
        if ok and schematic and type(schematic) == "table" then
            if type(schematic.productQuality) == "number" and schematic.productQuality > 0 then
                return schematic.productQuality
            end
            if type(schematic.outputItemID) == "number" and schematic.outputItemID > 0 then
                local _, _, q = GetItemInfo(schematic.outputItemID)
                if type(q) == "number" then return q end
            end
        end
    end

    -- 2. Quality-tier item IDs (sparse table of itemIDs per quality level)
    if C_TradeSkillUI.GetRecipeQualityItemIDs then
        local ok, ids = pcall(C_TradeSkillUI.GetRecipeQualityItemIDs, recipeID)
        if ok and ids and type(ids) == "table" then
            for _, itemID in pairs(ids) do
                if type(itemID) == "number" and itemID > 0 then
                    local _, _, q = GetItemInfo(itemID)
                    if type(q) == "number" then return q end
                end
            end
        end
    end

    -- 3. Output item data (generic fallback)
    if C_TradeSkillUI.GetRecipeOutputItemData then
        local ok, outputInfo = pcall(C_TradeSkillUI.GetRecipeOutputItemData, recipeID, nil, nil, nil, nil)
        if ok and outputInfo and type(outputInfo) == "table" then
            local itemID = outputInfo.itemID or outputInfo.outputItemID
            if type(itemID) == "number" and itemID > 0 then
                local _, _, q = GetItemInfo(itemID)
                if type(q) == "number" then return q end
            end
        end
    end

    return nil
end

-- ============================================================================
-- RECIPE DISPLAY INFO
-- ============================================================================

--- Get recipe display info from C_TradeSkillUI.
-- @param recipeID number
-- @return string name, number|string icon, boolean supportsQualities, number maxQuality, boolean firstCraft
local function GetRecipeDisplayInfo(recipeID)
    if C_TradeSkillUI and C_TradeSkillUI.GetRecipeInfo then
        local ok, info = pcall(C_TradeSkillUI.GetRecipeInfo, recipeID)
        if ok and info and type(info) == "table" and info.name and info.name ~= "" then
            return info.name, info.icon,
                   info.supportsQualities == true,
                   type(info.maxQuality) == "number" and info.maxQuality or nil,
                   info.firstCraft == true
        end
    end
    if C_TradeSkillUI and C_TradeSkillUI.GetProfessionInfoByRecipeID then
        local ok, info = pcall(C_TradeSkillUI.GetProfessionInfoByRecipeID, recipeID)
        if ok and info and type(info) == "table" and info.professionName then
            return info.professionName .. " — Recipe #" .. tostring(recipeID), nil, false, nil, false
        end
    end
    return "Recipe " .. tostring(recipeID), nil, false, nil, false
end

-- ============================================================================
-- RESULT CACHE
-- ============================================================================
-- Caches the full ReadTrackedRecipes output between layout passes.
-- Invalidated when: tracked recipe set changes, bag contents change, or a
-- configurable TTL expires (covers edge cases like profession window changes).

local resultCache       = nil   -- cached output table
local resultCacheKey    = nil   -- fingerprint of tracked recipe IDs + option flags
local resultCacheDirty  = true  -- explicit dirty flag (bag events, item loads, etc.)

--- Build a fingerprint string from the current tracked recipe set + relevant options.
local function BuildCacheKey(idList)
    local parts = {}
    for _, item in ipairs(idList) do
        local rid = (type(item) == "table" and item.recipeID) or item
        local rc  = (type(item) == "table" and item.isRecraft) and "r" or ""
        parts[#parts + 1] = tostring(rid) .. rc
    end
    -- Include option flags so toggling an option invalidates the cache.
    parts[#parts + 1] = addon.GetDB("showRecipeReagents", true) and "R1" or "R0"
    parts[#parts + 1] = addon.GetDB("showRecipeRequirements", false) and "Q1" or "Q0"
    parts[#parts + 1] = addon.GetDB("showCraftableCount", false) and "C1" or "C0"
    parts[#parts + 1] = addon.GetDB("showRecipeQualityInfo", false) and "I1" or "I0"
    parts[#parts + 1] = addon.GetDB("showOptionalReagents", true) and "O1" or "O0"
    parts[#parts + 1] = addon.GetDB("showFinishingReagents", true) and "F1" or "F0"
    parts[#parts + 1] = addon.GetDB("showChoiceSlots", true) and "S1" or "S0"
    return table.concat(parts, ";")
end

--- Mark the recipe cache as dirty (called from events that change bag/bank contents).
local function InvalidateRecipeCache()
    resultCacheDirty = true
end

-- ============================================================================
-- STATIC DATA CACHE (display info + output quality)
-- ============================================================================
-- These rarely change mid-session; cache per recipeID.

local displayInfoCache = {}  -- [recipeID] = { name, icon, supportsQualities, maxQuality, firstCraft }
local outputQualityCache = {} -- [cacheKey] = quality or false (nil means uncached)

local function GetCachedDisplayInfo(recipeID)
    local c = displayInfoCache[recipeID]
    if c then return c[1], c[2], c[3], c[4], c[5] end
    local name, icon, sq, mq, fc = GetRecipeDisplayInfo(recipeID)
    displayInfoCache[recipeID] = { name, icon, sq, mq, fc }
    return name, icon, sq, mq, fc
end

local function GetCachedOutputQuality(recipeID, isRecraft)
    local key = recipeID .. (isRecraft and ":r" or "")
    local c = outputQualityCache[key]
    if c ~= nil then return c or nil end
    local q = GetRecipeOutputQuality(recipeID, isRecraft)
    outputQualityCache[key] = q or false
    return q
end

-- ============================================================================
-- MAIN DATA PROVIDER
-- ============================================================================

--- Build tracker rows from WoW tracked profession recipes.
-- @return table Array of normalized entry tables for the tracker
local function ReadTrackedRecipes()
    local out = {}
    if not addon.GetDB("showRecipes", true) then return out end

    local idList = GetTrackedRecipeIDs()
    if #idList == 0 then
        resultCache, resultCacheKey = nil, nil
        return out
    end

    -- Check if the cached result is still valid.
    local key = BuildCacheKey(idList)
    if resultCache and not resultCacheDirty and resultCacheKey == key then
        return resultCache
    end

    -- Reset item-load tracking so stale callbacks from a previous pass are ignored.
    BeginItemLoadPass()

    resultCacheDirty = false

    local recipeColor = (addon.GetQuestColor and addon.GetQuestColor("RECIPE")) or (addon.QUEST_COLORS and addon.QUEST_COLORS.RECIPE) or { 0.55, 0.75, 0.45 }
    local showRequirements = addon.GetDB("showRecipeRequirements", false)
    local showCraftableCount = addon.GetDB("showCraftableCount", false)
    local showQualityInfo = addon.GetDB("showRecipeQualityInfo", false)

    for _, item in ipairs(idList) do
        local recipeID = (type(item) == "table" and item.recipeID) or item
        local isRecraft = (type(item) == "table" and item.isRecraft == true) or false
        if type(recipeID) == "number" and recipeID > 0 then
            local name, icon, supportsQualities, maxQuality, firstCraft = GetCachedDisplayInfo(recipeID)
            local recipeIcon = (icon and (type(icon) == "number" or (type(icon) == "string" and icon ~= ""))) and icon or nil
            local objectives = BuildRecipeObjectives(recipeID, isRecraft)
            local outputQuality = GetCachedOutputQuality(recipeID, isRecraft)

            -- Build prefix objectives (inserted in reverse order so they appear first)
            local prefixes = {}

            -- Unmet requirements
            if showRequirements then
                local reqs = BuildRecipeRequirements(recipeID)
                for _, r in ipairs(reqs) do prefixes[#prefixes + 1] = r end
            end

            -- Craftable count
            local craftableCount = nil
            if showCraftableCount and C_TradeSkillUI and C_TradeSkillUI.GetCraftableCount then
                local cOk, count = pcall(C_TradeSkillUI.GetCraftableCount, recipeID)
                if cOk and type(count) == "number" then
                    craftableCount = count
                    prefixes[#prefixes + 1] = {
                        text = "Can craft: " .. tostring(count),
                        isCraftableCount = true,
                        finished = true, numFulfilled = 1, numRequired = 1,
                    }
                end
            end

            -- Quality tier indicator (uses WoW atlas textures for quality pips)
            if showQualityInfo and supportsQualities and maxQuality and maxQuality > 0 then
                local pips = {}
                for i = 1, maxQuality do
                    pips[i] = "|A:Professions-Icon-Quality-Tier" .. i .. "-Small:0:0|a"
                end
                prefixes[#prefixes + 1] = {
                    text = "Quality: " .. table.concat(pips, " ") .. " (1\226\128\147" .. tostring(maxQuality) .. ")",
                    isQualityInfo = true,
                    finished = true, numFulfilled = 1, numRequired = 1,
                }
            end

            -- Merge prefixes + reagent objectives into a single list
            if #prefixes > 0 then
                for _, o in ipairs(objectives) do prefixes[#prefixes + 1] = o end
                objectives = prefixes
            end

            out[#out + 1] = {
                entryKey           = "recipe:" .. tostring(recipeID) .. (isRecraft and ":recraft" or ""),
                recipeID           = recipeID,
                recipeIsRecraft    = isRecraft,
                questID            = nil,
                title              = name or ("Recipe " .. tostring(recipeID)),
                objectives         = objectives,
                color              = recipeColor,
                outputQuality      = outputQuality,
                category           = "RECIPE",
                isComplete         = false,
                isSuperTracked     = false,
                isNearby           = false,
                zoneName           = nil,
                itemLink           = nil,
                itemTexture        = nil,
                isRecipe           = true,
                isTracked          = true,
                recipeIcon         = recipeIcon,
                supportsQualities  = supportsQualities,
                maxQuality         = maxQuality,
                firstCraft         = firstCraft,
                craftableCount     = craftableCount,
            }
        end
    end

    -- Safety-net: if any items are pending but callbacks never fire, force a refresh.
    EndItemLoadPass()

    resultCache = out
    resultCacheKey = key
    return out
end

-- ============================================================================
-- DEBUG
-- ============================================================================

--- Dump recipe reagent structure to chat for debugging.
-- @param recipeID number|nil Specific recipe, or nil to dump all tracked recipes
local function DebugRecipeReagents(recipeID)
    local HSPrint = (addon and addon.HSPrint) or _G.HSPrint or print
    if not C_TradeSkillUI or not C_TradeSkillUI.GetRecipeSchematic then
        HSPrint("C_TradeSkillUI.GetRecipeSchematic not available.")
        return
    end

    local targets = {}
    if type(recipeID) == "number" and recipeID > 0 then
        targets[#targets + 1] = { recipeID = recipeID, isRecraft = false }
    else
        targets = GetTrackedRecipeIDs()
    end
    if #targets == 0 then
        HSPrint("No tracked recipes. Track some in the profession UI, or use: /horizon recipedebug 12345")
        return
    end

    HSPrint("--- Recipe Reagent Debug ---")
    for _, item in ipairs(targets) do
        local rid = item.recipeID
        local isRecraft = item.isRecraft
        local ok, schematic = pcall(C_TradeSkillUI.GetRecipeSchematic, rid, isRecraft, nil)
        if not ok or not schematic or type(schematic) ~= "table" or not schematic.reagentSlotSchematics then
            HSPrint("  Recipe " .. rid .. (isRecraft and " (recraft)" or "") .. ": no schematic")
        else
            local name = GetRecipeDisplayInfo(rid)
            HSPrint("  Recipe " .. rid .. (isRecraft and " (recraft)" or "") .. ": " .. tostring(name))

            -- Count reagents by type
            local counts = { required = 0, optional = 0, finishing = 0, choice = 0 }
            for _, slot in ipairs(schematic.reagentSlotSchematics) do
                if IsChoiceSlot(slot) then
                    counts.choice = counts.choice + 1
                elseif slot.reagentType == REAGENT_TYPE_BASIC then
                    counts.required = counts.required + #(slot.reagents or {})
                elseif slot.reagentType == REAGENT_TYPE_MODIFYING then
                    counts.optional = counts.optional + #(slot.reagents or {})
                elseif slot.reagentType == REAGENT_TYPE_FINISHING then
                    counts.finishing = counts.finishing + #(slot.reagents or {})
                end
            end
            HSPrint("    Slots: required=" .. counts.required .. " optional=" .. counts.optional .. " choice=" .. counts.choice .. " finishing=" .. counts.finishing)

            -- Built objectives with flags
            local objectives = BuildRecipeObjectives(rid, isRecraft)
            HSPrint("    Objectives: " .. #objectives)
            for i, o in ipairs(objectives) do
                local flags = {}
                if o.isChoiceHeader then flags[#flags + 1] = "choiceHeader" end
                if o.isChoiceVariant then flags[#flags + 1] = "choiceVariant" end
                if o.isOptionalHeader then flags[#flags + 1] = "optionalHeader" end
                if o.isOptionalReagent then flags[#flags + 1] = "optionalReagent" end
                if o.isFinishingHeader then flags[#flags + 1] = "finishingHeader" end
                if o.isFinishingReagent then flags[#flags + 1] = "finishingReagent" end
                if o.isRequirement then flags[#flags + 1] = "requirement" end
                if o.isCraftableCount then flags[#flags + 1] = "craftableCount" end
                if o.isQualityInfo then flags[#flags + 1] = "qualityInfo" end
                if o.currencyID then flags[#flags + 1] = "currency:" .. tostring(o.currencyID) end
                local flagStr = #flags > 0 and (" [" .. table.concat(flags, ",") .. "]") or ""
                HSPrint("      " .. i .. ": " .. tostring(o.text or "(no text)") .. flagStr)
            end
        end
    end
    HSPrint("--- End ---")
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

addon.GetTrackedRecipeIDs = GetTrackedRecipeIDs
addon.ReadTrackedRecipes = ReadTrackedRecipes
addon.InvalidateRecipeCache = InvalidateRecipeCache
addon.DebugRecipeReagents = DebugRecipeReagents
