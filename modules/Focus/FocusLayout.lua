--[[
    Horizon Suite - Focus - Layout Engine
    PopulateEntry, FullLayout, ToggleCollapse, AcquireEntry, section headers, header button, keybind, floating item, M+ block.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- ============================================================================
-- LAYOUT ENGINE
-- ============================================================================

local pool       = addon.pool
local activeMap  = addon.activeMap
local sectionPool = addon.sectionPool
local scrollChild = addon.scrollChild
local scrollFrame = addon.scrollFrame

--- Returns the maximum height the panel can grow to without going off-screen.
--- Grow-down: distance from panel top to screen bottom. Grow-up: distance from panel bottom to screen top.
--- Falls back to a large sentinel when the panel isn't yet visible.
local function GetMaxPanelHeight()
    if not addon.HS then return 99999 end
    local uiBottom = UIParent and UIParent:GetBottom() or 0
    local uiTop = UIParent and UIParent:GetTop() or 0
    if addon.GetDB("growUp", false) then
        local bottom = addon.HS:GetBottom()
        if not bottom then return 99999 end
        local maxH = uiTop - bottom
        return (maxH > 0) and maxH or 99999
    end
    local top = addon.HS:GetTop()
    if not top then return 99999 end
    local maxH = top - uiBottom
    return (maxH > 0) and maxH or 99999
end

--- Player's current zone name from map API. Used to suppress redundant zone labels for in-zone quests.
--- Schedule deferred refreshes when Endeavors or Decor have placeholder names (API data not yet loaded).
--- Retries up to 3 times at 2s intervals; stops as soon as no placeholder is detected.
local function SchedulePlaceholderRefreshes(quests)
    if addon.focus.placeholderRefreshScheduled then return end
    local hasPlaceholder = false
    for _, q in ipairs(quests) do
        local isEndeavorPlaceholder = q.isEndeavor and q.endeavorID and q.title == ("Endeavor " .. tostring(q.endeavorID))
        local isDecorPlaceholder = q.isDecor and q.decorID and q.title == ("Decor " .. tostring(q.decorID))
        if isEndeavorPlaceholder or isDecorPlaceholder then
            hasPlaceholder = true
            break
        end
    end
    if not hasPlaceholder then return end

    addon.focus.placeholderRefreshScheduled = true
    local retriesLeft = 3
    local function retry()
        retriesLeft = retriesLeft - 1
        if not addon.focus.enabled then return end
        if addon.ScheduleRefresh then addon.ScheduleRefresh() end
        -- Only reschedule if we still have retries and placeholders might still exist.
        if retriesLeft > 0 then
            C_Timer.After(2, retry)
        else
            addon.focus.placeholderRefreshScheduled = false
        end
    end
    C_Timer.After(2, retry)
end

--- Player's current zone name. Uses Zone tier (whole zone, e.g. K'aresh), not continent or micro.
--- Dungeon/Delve: current map only. Overworld: GetZoneText() or walk up to Zone (mapType 3).
local function GetPlayerCurrentZoneName()
    if not C_Map or not C_Map.GetBestMapForUnit then return nil end
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID or not C_Map.GetMapInfo then return nil end

    -- Dungeon or Delve: use current map only (no walk-up).
    if (addon.IsDelveActive and addon.IsDelveActive()) or (addon.IsInPartyDungeon and addon.IsInPartyDungeon()) then
        local info = C_Map.GetMapInfo(mapID)
        return info and info.name or nil
    end

    -- Overworld: prefer GetZoneText() (fixes wrong-map e.g. Dornegol when in K'aresh).
    if GetZoneText and type(GetZoneText) == "function" then
        local zoneText = GetZoneText()
        if zoneText and zoneText:match("%S") then
            return zoneText:match("^%s*(.-)%s*$") or zoneText
        end
    end

    -- Fallback: walk up via parentMapID until Zone (mapType 3) or no parent.
    local UIMAPTYPE_ZONE = 3
    local current = mapID
    local info = C_Map.GetMapInfo(current)
    local firstInfo = info  -- keep the original mapID's info for final fallback
    while info do
        if info.mapType == UIMAPTYPE_ZONE then
            return info.name
        end
        if not info.parentMapID or info.parentMapID == 0 then
            break
        end
        current = info.parentMapID
        info = C_Map.GetMapInfo(current)
    end
    -- Fall back to the name of the original mapID (firstInfo already fetched above).
    return firstInfo and firstInfo.name or nil
end

local function AcquireEntry()
    for i = 1, addon.POOL_SIZE do
        if pool[i].animState == "idle" and not pool[i].questID and not pool[i].entryKey then
            return pool[i]
        end
    end
    for i = 1, addon.POOL_SIZE do
        if pool[i].animState == "fadeout" then
            addon.ClearEntry(pool[i])
            return pool[i]
        end
    end
    return nil
end

--- Set initial alpha when showing the tracker. Combat fade "in" overrides; otherwise apply hover-fade state.
local function ApplyShowAlpha()
    if addon.ShouldFadeInCombat and addon.ShouldFadeInCombat() then
        local fadeAlpha = addon.GetCombatFadeAlpha and addon.GetCombatFadeAlpha() or 0.3
        addon.HS:SetAlpha(fadeAlpha)
        local floatingBtn = _G.HSFloatingQuestItem
        if floatingBtn and floatingBtn:IsShown() then floatingBtn:SetAlpha(fadeAlpha) end
        return
    end
    if addon.focus.combat.fadeState == "in" then
        local startAlpha = addon.focus.combat.fadeInFromAlpha
        addon.HS:SetAlpha((startAlpha ~= nil) and startAlpha or 0)
        return
    end
    if addon.GetDB("showOnMouseoverOnly", false) then
        local pct = tonumber(addon.GetDB("fadeOnMouseoverOpacity", 10)) or 10
        local fadeAlpha = math.max(0, math.min(100, pct)) / 100
        addon.HS:SetAlpha(addon.IsFocusHoverActive and addon.IsFocusHoverActive() and 1 or fadeAlpha)
    else
        addon.HS:SetAlpha(1)
        local floatingBtn = _G.HSFloatingQuestItem
        if floatingBtn and floatingBtn:IsShown() then floatingBtn:SetAlpha(1) end
    end
end

-- Safety: if load order is disrupted (or a hot-reload partially loads files),
-- layout can run before FocusAnimation defines addon.SetEntryFadeIn.
-- Fall back to a no-animation init so we never hard-crash.
local function SafeEntryFadeIn(entry, staggerIndex)
    if addon.SetEntryFadeIn then
        addon.SetEntryFadeIn(entry, staggerIndex)
        return
    end
    if not entry then return end
    entry.animState = "active"
    entry.animTime = 0
    entry.staggerDelay = 0
    if entry.SetAlpha then entry:SetAlpha(1) end
end

local headerBtn = CreateFrame("Button", nil, addon.HS)
headerBtn:SetPoint("TOPLEFT", addon.HS, "TOPLEFT", 0, 0)
headerBtn:SetPoint("TOPRIGHT", addon.HS, "TOPRIGHT", 0, 0)
headerBtn:SetHeight(addon.GetScaledPadding() + addon.GetHeaderHeight())
headerBtn:RegisterForClicks("LeftButtonUp")
headerBtn:SetScript("OnClick", function()
    addon.ToggleCollapse()
end)
headerBtn:SetScript("OnEnter", function()
    if addon.GetDB("hideObjectivesHeader", false) then
        addon.chevron:SetAlpha(1)
        if not addon.GetDB("hideOptionsButton", false) then
            addon.optionsBtn:SetAlpha(1)
        end
    end
end)
headerBtn:SetScript("OnLeave", function()
    if addon.GetDB("hideObjectivesHeader", false) then
        if addon.optionsBtn:IsMouseOver() then return end
        addon.chevron:SetAlpha(0)
        if not addon.GetDB("hideOptionsButton", false) then
            addon.optionsBtn:SetAlpha(0)
        end
    end
end)
headerBtn:RegisterForDrag("LeftButton")
headerBtn:SetScript("OnDragStart", function()
    if addon.GetDB("lockPosition", false) then return end
    if InCombatLockdown() then return end
    addon.HS:StartMoving()
end)
headerBtn:SetScript("OnDragStop", function()
    if addon.GetDB("lockPosition", false) then return end
    addon.HS:StopMovingOrSizing()
    addon.HS:SetUserPlaced(false)
    if InCombatLockdown() then return end
    addon.SavePanelPosition()
end)

local collapseKeybindBtn = CreateFrame("Button", "HSCollapseButton", nil)
collapseKeybindBtn:SetScript("OnClick", function()
    addon.ToggleCollapse()
end)
collapseKeybindBtn:RegisterForClicks("AnyUp")

local nearbyToggleKeybindBtn = CreateFrame("Button", "HSNearbyToggleButton", nil)
nearbyToggleKeybindBtn:SetScript("OnClick", function()
    local newShow = not addon.GetDB("showNearbyGroup", true)
    addon.SetDB("showNearbyGroup", newShow)
    if newShow then
        if addon.GetDB("animations", true) and addon.StartNearbyTurnOnTransition then
            addon.StartNearbyTurnOnTransition()
        else
            if _G.HorizonSuite_RequestRefresh then _G.HorizonSuite_RequestRefresh() end
            if _G.HorizonSuite_FullLayout then _G.HorizonSuite_FullLayout() end
        end
    else
        if addon.GetDB("animations", true) and addon.StartGroupCollapseVisual then
            addon.StartGroupCollapseVisual("NEARBY")
        else
            if _G.HorizonSuite_RequestRefresh then _G.HorizonSuite_RequestRefresh() end
            if _G.HorizonSuite_FullLayout then _G.HorizonSuite_FullLayout() end
        end
    end
end)
nearbyToggleKeybindBtn:RegisterForClicks("AnyUp")

--- Full layout of the objectives panel.
-- @brief Computes and applies the complete tracker layout: visibility, quest list, section headers, entry positions, scroll height.
-- Algorithm: (1) Bail if disabled or in combat. (2) Hide panel if instance visibility
-- forbids. (3) Apply grow-up anchor and header visibility from DB. (4) When collapsed,
-- update floating item and header count then return. (5) Read and sort/group quests,
-- mark entries no longer in list for fadeout. (6) For each grouped quest, acquire or
-- reuse pool entry and PopulateEntry. (7) Place section headers and entries by group,
-- respecting collapsed categories. (8) Set scroll child height, clamp scroll offset,
-- compute target panel height and show frame.

--- Collect all tracked entries (quests + rares + achievements + endeavors + decor + adventure guide).
--- @param rares table Array of rare entries from GetRaresOnMap
--- @return table Combined entry array
local function CollectAllEntries(rares)
    local quests = addon.ReadTrackedQuests()
    for _, r in ipairs(rares) do quests[#quests + 1] = r end
    if addon.GetDB("showAchievements", true) and addon.ReadTrackedAchievements then
        for _, a in ipairs(addon.ReadTrackedAchievements()) do quests[#quests + 1] = a end
    end
    if addon.ReadTrackedEndeavors then
        for _, e in ipairs(addon.ReadTrackedEndeavors()) do quests[#quests + 1] = e end
    end
    if addon.ReadTrackedDecor then
        for _, d in ipairs(addon.ReadTrackedDecor()) do quests[#quests + 1] = d end
    end
    if addon.GetDB("showRecipes", true) and addon.ReadTrackedRecipes then
        for _, rp in ipairs(addon.ReadTrackedRecipes()) do quests[#quests + 1] = rp end
    end
    if addon.ReadTrackedAdventureGuide then
        for _, ag in ipairs(addon.ReadTrackedAdventureGuide()) do quests[#quests + 1] = ag end
    end
    return quests
end

local lastMinimal = false
local function HideAllItemButtons()
    for i = 1, addon.POOL_SIZE do
        local e = pool[i]
        if e and e.itemBtn then e.itemBtn:Hide() end
    end
end

local function FullLayout()
    if not addon.focus.enabled then return end
    addon.focus.layoutPendingAfterCombat = false

    if not addon.ShouldShowInInstance() then
        addon.HS:Hide()
        HideAllItemButtons()
        addon.UpdateFloatingQuestItem(nil)
        if addon.UpdateMplusBlock then addon.UpdateMplusBlock() end
        return
    end

    if addon.ShouldHideInCombat() then
        addon.HS:Hide()
        HideAllItemButtons()
        addon.UpdateFloatingQuestItem(nil)
        if addon.UpdateMplusBlock then addon.UpdateMplusBlock() end
        return
    end

    if addon.GetDB("growUp", false) then
        addon.ApplyGrowUpAnchor()
    end

    -- Layout indentation model:
    --  - Category chevron '−/+' is the left pivot.
    --  - Quest titles start two spaces to the right of the chevron.
    --  - Zone/objectives start two spaces to the right of the title.
    -- Measure "two spaces" using the current TitleFont so it scales with typography.
    do
        addon.focus.layout = addon.focus.layout or {}
        local twoSpaces = 8
        local ok = pcall(function()
            addon.focus.layout.__indentMeasure = addon.focus.layout.__indentMeasure or addon.scrollChild:CreateFontString(nil, "ARTWORK")
            local fs = addon.focus.layout.__indentMeasure
            fs:Hide()
            fs:SetFontObject(addon.TitleFont)
            fs:SetText("  ")
            local w = fs:GetStringWidth()
            if w and w > 0 then twoSpaces = w end
        end)
        if not ok then twoSpaces = 8 end
        addon.focus.layout.twoSpacesPx = twoSpaces
        addon.focus.layout.titleIndentPx = twoSpaces
    end

    local minimal = addon.GetDB("hideObjectivesHeader", false)
    local hideOptBtn = addon.GetDB("hideOptionsButton", false)
    if minimal then
        addon.headerText:Hide()
        addon.headerShadow:Hide()
        addon.countText:Hide()
        addon.countShadow:Hide()
        addon.divider:Hide()
        addon.optionsBtn:SetFrameLevel(headerBtn:GetFrameLevel() + 1)
        addon.optionsBtn:SetParent(addon.HS)
        headerBtn:SetHeight(addon.GetScaledMinimalHeaderHeight())
        addon.chevron:Show()
        if hideOptBtn then
            addon.optionsBtn:Hide()
        else
            addon.optionsLabel:SetText(addon.L["Options"])
            addon.optionsBtn:SetWidth(math.max(addon.optionsLabel:GetStringWidth() + 4, 44))
            addon.optionsBtn:Show()
            -- Visible on hover only: use alpha so frames stay in layout and remain clickable
            if not lastMinimal then
                addon.chevron:SetAlpha(headerBtn:IsMouseOver() and 1 or 0)
                addon.optionsBtn:SetAlpha(headerBtn:IsMouseOver() and 1 or 0)
            end
        end
    else
        addon.optionsBtn:SetFrameLevel(headerBtn:GetFrameLevel() + 1)
        addon.optionsBtn:SetParent(addon.HS)
        addon.chevron:SetAlpha(1)
        addon.headerText:Show()
        addon.headerShadow:Show()
        local headerStr = addon.ApplyTextCase(addon.L["OBJECTIVES"], "headerTextCase", "upper")
        addon.headerText:SetText(headerStr)
        addon.headerShadow:SetText(headerStr)
        if addon.GetDB("showQuestCount", true) then addon.countText:Show(); addon.countShadow:Show() else addon.countText:Hide(); addon.countShadow:Hide() end
        addon.chevron:Show()
        if hideOptBtn then
            addon.optionsBtn:Hide()
        else
            addon.optionsBtn:SetAlpha(1)
            addon.optionsBtn:Show()
            addon.optionsLabel:SetText(addon.L["Options"])
            addon.optionsBtn:SetWidth(math.max(addon.optionsLabel:GetStringWidth() + 4, 44))
        end
        local showDiv = addon.GetDB("showHeaderDivider", true)
        addon.divider:SetShown(showDiv)
        if showDiv then
            local dc = addon.GetHeaderDividerColor()
            addon.divider:SetColorTexture(dc[1], dc[2], dc[3], dc[4])
        end
        headerBtn:SetHeight(addon.GetScaledPadding() + addon.GetHeaderHeight())
    end
    lastMinimal = minimal

    local contentTop = addon.GetContentTop()

    -- Update the Mythic+ block so we can anchor the scrollFrame around it.
    if addon.UpdateMplusBlock then
        addon.UpdateMplusBlock()
    end

    scrollFrame:ClearAllPoints()
    local mplus = addon.mplusBlock
    local hasMplus = mplus and mplus:IsShown()
    local mplusPos = addon.GetDB("mplusBlockPosition", "top") or "top"
    local gap = addon.Scaled(4)

    local blockFrame = hasMplus and mplus or nil
    local blockPos = hasMplus and mplusPos or "top"

    if blockFrame and blockPos == "top" then
        scrollFrame:SetPoint("TOPLEFT", blockFrame, "BOTTOMLEFT", 0, -gap)
        scrollFrame:SetPoint("BOTTOMRIGHT", addon.HS, "BOTTOMRIGHT", 0, addon.GetScaledPadding())
    elseif blockFrame and blockPos == "bottom" then
        scrollFrame:SetPoint("TOPLEFT", addon.HS, "TOPLEFT", 0, contentTop)
        scrollFrame:SetPoint("BOTTOMRIGHT", blockFrame, "TOPRIGHT", 0, gap)
    else
        scrollFrame:SetPoint("TOPLEFT", addon.HS, "TOPLEFT", 0, contentTop)
        scrollFrame:SetPoint("BOTTOMRIGHT", addon.HS, "BOTTOMRIGHT", 0, addon.GetScaledPadding())
    end

    local rares = addon.GetDB("showRareBosses", true) and addon.GetRaresOnMap() or {}
    if #rares > 0 then
        local currentRareKeys = {}
        for _, r in ipairs(rares) do currentRareKeys[r.entryKey or r.questID] = true end
        if addon.focus.rares.trackingInit and not addon.focus.zoneJustChanged then
            for key in pairs(currentRareKeys) do
                if not addon.focus.rares.prevKeys[key] then
                    if addon.PlayRareAddedSound then
                        addon.PlayRareAddedSound()
                    elseif PlaySound and addon.GetDB("rareAddedSound", true) then
                        pcall(PlaySound, addon.RARE_ADDED_SOUND)
                    end
                    break
                end
            end
        end
        if addon.focus.zoneJustChanged then addon.focus.zoneJustChanged = false end
        addon.focus.rares.trackingInit = true
        addon.focus.rares.prevKeys = currentRareKeys
    else
        addon.focus.rares.prevKeys = {}
    end

    if addon.focus.collapsed then
        if addon.focus.collapse.pendingWQCollapse then
            addon.focus.collapse.pendingWQCollapse = false
        end
        local quests = CollectAllEntries(rares)
        SchedulePlaceholderRefreshes(quests)
        addon.UpdateFloatingQuestItem(quests)
        addon.UpdateHeaderQuestCount(#quests, addon.CountTrackedInLog(quests))

        -- During panel collapse animation, skip full collapsed layout so section headers
        -- stay visible; UpdateCollapseAnimations will call FullLayout when done.
        if addon.focus.collapse.animating then
            if #quests > 0 then
                ApplyShowAlpha()
                addon.HS:Show()
            end
            return
        end

        if addon.GetDB("showSectionHeadersWhenCollapsed", false) then
            -- Collapsed-with-headers: show section headers only, no entries.
            local grouped = addon.SortAndGroupQuests(quests)
            local showSections = #grouped >= 1 and addon.GetDB("showSectionHeaders", true)

            if showSections and #grouped > 0 then
                scrollFrame:Show()
                addon.HideAllSectionHeaders()
                addon.focus.layout.sectionIdx = 0
                local focusedGroupKey = addon.GetFocusedGroupKey(grouped)
                local yOff = 0
                for gi, grp in ipairs(grouped) do
                    if gi > 1 then
                        yOff = yOff - addon.GetSectionSpacing()
                    end
                    local sec = addon.AcquireSectionHeader(grp.key, focusedGroupKey)
                    if sec then
                        sec:ClearAllPoints()
                        local x = addon.GetScaledPadding()
                        sec:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", x, yOff)
                        sec.finalX, sec.finalY = x, yOff
                        yOff = yOff - addon.GetSectionHeaderHeight() - addon.GetSectionToEntryGap()
                    end
            end
            local totalContentH = math.max(-yOff, 1)
            scrollChild:SetHeight(totalContentH)
            addon.ApplyScrollOffset(0)
            addon.focus.layout.scrollOffset = 0
            if addon.UpdateScrollIndicators then addon.UpdateScrollIndicators() end
            local headerArea
            if addon.GetDB("hideObjectivesHeader", false) then
                headerArea = addon.GetScaledMinimalHeaderHeight() + addon.Scaled(4)
            else
                headerArea = addon.GetScaledPadding() + addon.GetHeaderHeight() + addon.GetScaledDividerHeight() + addon.GetHeaderToContentGap()
            end
            local visibleH = math.min(totalContentH, addon.GetMaxContentHeight())
            local blockHeight = (hasMplus and addon.GetMplusBlockHeight and (addon.GetMplusBlockHeight() + gap * 2)) or 0
            local desiredH = math.max(addon.GetScaledMinHeight(), headerArea + visibleH + addon.GetScaledPadding() + blockHeight)
            addon.focus.layout.targetHeight = math.min(desiredH, GetMaxPanelHeight())
            else
                scrollFrame:Hide()
                addon.focus.layout.targetHeight = addon.GetCollapsedHeight()
            end
        else
            scrollFrame:Hide()
            addon.focus.layout.targetHeight = addon.GetCollapsedHeight()
        end

        if #quests > 0 then
            ApplyShowAlpha()
            addon.HS:Show()
        else
            addon.HS:Hide()
            HideAllItemButtons()
            addon.UpdateFloatingQuestItem(nil)
        end
        return
    end

    scrollFrame:Show()

    local quests = CollectAllEntries(rares)
    -- Allow SchedulePlaceholderRefreshes to re-evaluate on every FullLayout call.
    -- The retry loop will have set this to false after its last attempt; clearing it here
    -- ensures an event-driven layout (e.g. INITIATIVE_TASKS_TRACKED_UPDATED) re-checks.
    addon.focus.placeholderRefreshScheduled = false
    SchedulePlaceholderRefreshes(quests)
    addon.UpdateFloatingQuestItem(quests)
    local grouped = addon.SortAndGroupQuests(quests)

    -- When a category is collapsing, skip full layout to avoid section header flicker.
    if addon.focus.collapse.groups and next(addon.focus.collapse.groups) then
        if addon.focus.collapse.pendingWQCollapse then
            addon.focus.collapse.pendingWQCollapse = false
        end
        addon.UpdateHeaderQuestCount(#quests, addon.CountTrackedInLog(quests))
        if addon.EnsureFocusUpdateRunning then addon.EnsureFocusUpdateRunning() end
        return
    end

    -- Source of truth: use filtered grouped output so hideOtherCategoriesInDelve
    -- correctly clears stale entries when transitioning into Delve/dungeon.
    local currentIDs = {}
    for _, grp in ipairs(grouped) do
        for _, qData in ipairs(grp.quests) do
            local key = qData.entryKey or qData.questID
            if key then currentIDs[key] = true end
        end
    end

    -- Align with SortAndGroupQuests hideOtherCategoriesInDelve: when filter returns
    -- only DELVES or DUNGEON, clear stale entries immediately (no fade animation).
    local onlyDelveShown = (#grouped == 1 and grouped[1] and grouped[1].key == "DELVES")
        and (addon.IsDelveActive and addon.IsDelveActive())
    local onlyDungeonShown = (#grouped == 1 and grouped[1] and grouped[1].key == "DUNGEON")
        and (addon.IsInPartyDungeon and addon.IsInPartyDungeon())
    local onlyInstanceGroupShown = onlyDelveShown or onlyDungeonShown
    local useWQCollapse = addon.focus.collapse.pendingWQCollapse
        and addon.GetDB("animations", true)
        and not onlyInstanceGroupShown
    local useWQExpand = addon.focus.collapse.pendingWQExpand
        and addon.GetDB("animations", true)
    if useWQExpand then
        if addon.PrepareGroupExpandSlideDown then addon.PrepareGroupExpandSlideDown("WORLD") end
        addon.focus.collapse.pendingWQExpand = false
    end
    local slideUpStarts = nil
    local slideUpStartsSec = nil
    if useWQCollapse then
        slideUpStarts = {}
        for k in pairs(currentIDs) do
            local e = activeMap[k]
            if e and (e.animState == "active" or e.animState == "fadein") and e.finalY ~= nil then
                slideUpStarts[k] = e.finalY
            end
        end
        slideUpStartsSec = {}
        for i = 1, addon.SECTION_POOL_SIZE do
            local s = sectionPool[i]
            if s and s.active and s.groupKey and s.finalY ~= nil then
                slideUpStartsSec[s.groupKey] = s.finalY
            end
        end
    end
    local toRemove = {}
    for key, entry in pairs(activeMap) do
        if not currentIDs[key] then
            if onlyInstanceGroupShown and addon.ClearEntry then
                addon.ClearEntry(entry)
            elseif useWQCollapse and entry.animState ~= "completing" and entry.animState ~= "fadeout" then
                toRemove[#toRemove + 1] = { key = key, entry = entry }
            elseif entry.animState ~= "completing" and entry.animState ~= "fadeout" then
                addon.SetEntryFadeOut(entry)
            end
            activeMap[key] = nil
        end
    end
    if useWQCollapse and #toRemove > 0 then
        table.sort(toRemove, function(a, b)
            return (a.entry.finalY or 0) > (b.entry.finalY or 0)
        end)
        addon.focus.collapse.optionCollapseKeys = {}
        for i, t in ipairs(toRemove) do
            addon.SetEntryCollapsing(t.entry, i - 1)
            addon.focus.collapse.optionCollapseKeys[t.key] = true
        end
        addon.focus.collapse.pendingWQCollapse = false
    end
    if addon.focus.collapse.pendingWQCollapse then
        addon.focus.collapse.pendingWQCollapse = false
    end
    if onlyInstanceGroupShown and addon.ClearEntry then
        for i = 1, addon.POOL_SIZE do
            local e = pool[i]
            if e and (e.questID or e.entryKey) then
                local key = e.questID or e.entryKey
                if not currentIDs[key] then
                    addon.ClearEntry(e)
                end
            end
        end
    end

    for _, grp in ipairs(grouped) do
        for _, qData in ipairs(grp.quests) do
            local key = qData.entryKey or qData.questID
            local entry = activeMap[key]
            if not entry then
                entry = AcquireEntry()
                if entry then
                    SafeEntryFadeIn(entry, 0)
                    activeMap[key] = entry
                end
            elseif entry.animState == "idle" and not entry.questID and not entry.entryKey then
                -- Zombie entry left over from a group collapse: reset it for fadein.
                SafeEntryFadeIn(entry, 0)
            end
            if entry then
                entry.groupKey = grp.key
                addon.PopulateEntry(entry, qData, grp.key)
            end
        end
    end

    -- Build current "priority" sets (tracked/in-log) for WORLD, WEEKLY, DAILY to detect promotion.
    local function isPriorityWorld(q) return (q.isTracked or q.isAccepted) and true or false end
    local function isPriorityWeeklyDaily(q) return q.isAccepted and true or false end
    local curPriority = {}
    for _, grp in ipairs(grouped) do
        if grp.key == "WORLD" or grp.key == "WEEKLY" or grp.key == "DAILY" then
            curPriority[grp.key] = {}
            for _, qData in ipairs(grp.quests) do
                local key = qData.entryKey or qData.questID
                if key and ((grp.key == "WORLD" and isPriorityWorld(qData)) or ((grp.key == "WEEKLY" or grp.key == "DAILY") and isPriorityWeeklyDaily(qData))) then
                    curPriority[grp.key][key] = true
                end
            end
        end
    end

    -- Promotion animation: if priority set grew (tracked/in-log added), fade out only the promoted quest(s) then reflow and fade them in at top.
    if addon.GetDB("animations", true) then
        addon.focus.promotion.prevWorld  = addon.focus.promotion.prevWorld  or {}
        addon.focus.promotion.prevWeekly = addon.focus.promotion.prevWeekly or {}
        addon.focus.promotion.prevDaily  = addon.focus.promotion.prevDaily  or {}
        local promotedKeys = {}
        for _, grp in ipairs(grouped) do
            if grp.key == "WORLD" or grp.key == "WEEKLY" or grp.key == "DAILY" then
                local cur = (grp.key == "WORLD" and curPriority.WORLD) or (grp.key == "WEEKLY" and curPriority.WEEKLY) or (grp.key == "DAILY" and curPriority.DAILY) or {}
                local prev = (grp.key == "WORLD" and addon.focus.promotion.prevWorld) or (grp.key == "WEEKLY" and addon.focus.promotion.prevWeekly) or (grp.key == "DAILY" and addon.focus.promotion.prevDaily) or {}
                if next(prev) then
                    for k in pairs(cur) do
                        if not prev[k] then promotedKeys[k] = true end
                    end
                end
            end
        end
        local promotionFadeOutCount = 0
        if next(promotedKeys) then
            addon.focus.promotion.prevWorld  = curPriority.WORLD  or {}
            addon.focus.promotion.prevWeekly = curPriority.WEEKLY or {}
            addon.focus.promotion.prevDaily  = curPriority.DAILY  or {}
            for key in pairs(promotedKeys) do
                local entry = activeMap[key]
                if entry and (entry.animState == "active" or entry.animState == "fadein") and entry.finalX and entry.finalY then
                    addon.SetEntryFadeOut(entry)
                    entry.promotionFadeOut = true
                    promotionFadeOutCount = promotionFadeOutCount + 1
                end
            end
            if promotionFadeOutCount > 0 then
                addon.promotionFadeOutCount = promotionFadeOutCount
                addon.onPromotionFadeOutCompleteCallback = function()
                    addon.onPromotionFadeOutCompleteCallback = nil
                    addon.promotionFadeOutCount = nil
                    if addon.FullLayout then addon.FullLayout() end
                end
                addon.UpdateHeaderQuestCount(#quests, addon.CountTrackedInLog(quests))
                if addon.EnsureFocusUpdateRunning then addon.EnsureFocusUpdateRunning() end
                return
            end
        end
    end

    -- Update prev priority for next comparison (when not doing promotion transition).
    addon.focus.promotion.prevWorld  = curPriority.WORLD  or {}
    addon.focus.promotion.prevWeekly = curPriority.WEEKLY or {}
    addon.focus.promotion.prevDaily  = curPriority.DAILY  or {}

    local excludeSectionHeadersForFade = nil
    if addon.focus.collapse.optionCollapseKeys and next(addon.focus.collapse.optionCollapseKeys) and addon.GetDB("animations", true) then
        local newGroupKeys = {}
        for _, grp in ipairs(grouped) do
            newGroupKeys[grp.key] = true
        end
        local disappearing = {}
        for i = 1, addon.SECTION_POOL_SIZE do
            local s = sectionPool[i]
            if s and s.active and s.groupKey and not newGroupKeys[s.groupKey] then
                disappearing[s.groupKey] = true
            end
        end
        if next(disappearing) then
            addon.focus.collapse.sectionHeadersFadingOut = true
            addon.focus.collapse.sectionHeadersFadingOutKeys = disappearing
            addon.focus.collapse.sectionHeaderFadeTime = 0
            excludeSectionHeadersForFade = disappearing
            if addon.EnsureFocusUpdateRunning then addon.EnsureFocusUpdateRunning() end
        end
    end
    addon.HideAllSectionHeaders(excludeSectionHeadersForFade)
    addon.focus.layout.sectionIdx = 0

    local yOff = 0
    local entryIndex = 0

    local showSections = addon.GetDB("showSectionHeaders", true)
    local focusedGroupKey = addon.GetFocusedGroupKey(grouped)

    -- Offset quest entries so their text starts under the section header label
    -- (i.e. same start as category text, excluding the chevron).
    local sectionLabelX = 0
    if showSections then
        local w = addon.focus.layout and addon.focus.layout.twoSpacesPx
        if type(w) == "number" and w > 0 then
            sectionLabelX = math.floor(w + 0.5)
        else
            -- Fallback if the layout cache isn't populated yet.
            local meas = addon.focus.layout.__sectionIndentMeasure
            if not meas then
                meas = scrollChild:CreateFontString(nil, "ARTWORK")
                meas:Hide()
                addon.focus.layout.__sectionIndentMeasure = meas
            end
            meas:SetFontObject(addon.TitleFont)
            meas:SetText("  ")
            local mw = meas:GetStringWidth()
            if mw and mw > 0 then sectionLabelX = math.floor(mw + 0.5) end
        end
    end

    -- Persist for other modules/tests.
    addon.focus.layout.sectionLabelX = sectionLabelX

    -- Section divider pool (lazy-created textures for between-section dividers)
    if not addon.focus.layout.sectionDividers then addon.focus.layout.sectionDividers = {} end
    local sectionDividers = addon.focus.layout.sectionDividers
    local showSectionDividers = addon.GetDB("showSectionDividers", false)
    local sectionDividerIdx = 0

    -- Hide all section dividers first
    for _, div in ipairs(sectionDividers) do div:Hide() end

    for gi, grp in ipairs(grouped) do
        local isCollapsed = false
        if showSections and addon.IsCategoryCollapsed then
            isCollapsed = addon.IsCategoryCollapsed(grp.key)
        end

        if showSections then
            local sectionGap = 0
            if gi > 1 then
                sectionGap = addon.GetSectionSpacing()

                -- Draw a divider between sections if enabled
                if showSectionDividers then
                    local divH = 1
                    local divPad = math.floor(sectionGap / 2)
                    yOff = yOff - divPad
                    sectionDividerIdx = sectionDividerIdx + 1
                    local div = sectionDividers[sectionDividerIdx]
                    if not div then
                        div = scrollChild:CreateTexture(nil, "ARTWORK")
                        sectionDividers[sectionDividerIdx] = div
                    end
                    local divColor = addon.GetDB("sectionDividerColor", nil)
                    if not divColor or type(divColor) ~= "table" or not divColor[1] then
                        divColor = { 0.3, 0.3, 0.35, 0.4 }
                    end
                    div:SetColorTexture(divColor[1], divColor[2], divColor[3], divColor[4] or 0.4)
                    local divX = addon.GetScaledPadding()
                    local divW = addon.GetPanelWidth() - divX * 2
                    div:SetSize(divW, divH)
                    div:ClearAllPoints()
                    div:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", divX, yOff)
                    div:Show()
                    yOff = yOff - divH - (sectionGap - divPad)
                else
                    yOff = yOff - sectionGap
                end
            end
            local sec = addon.AcquireSectionHeader(grp.key, focusedGroupKey)
            if sec then
                sec:ClearAllPoints()
                local x = addon.GetScaledPadding()
                sec:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", x, yOff)
                sec.finalX, sec.finalY = x, yOff
                sec._scrollFadeSpacing = addon.GetSectionToEntryGap()
                sec._scrollFadeLeadingGap = sectionGap
                yOff = yOff - addon.GetSectionHeaderHeight() - addon.GetSectionToEntryGap()
            end
        end

        if isCollapsed then
            -- Do not position entries for collapsed groups; hide any that are not
            -- currently animating a collapse.
            for _, qData in ipairs(grp.quests) do
                local key = qData.entryKey or qData.questID
                local entry = activeMap[key]
                if entry and entry.animState ~= "collapsing" then
                    entry:Hide()
                end
            end
        else
            local entrySpacing = ((grp.key == "DELVES" or grp.key == "DUNGEON") and addon.Scaled(addon.DELVE_ENTRY_SPACING)) or addon.GetTitleSpacing()
            local categoryCounter = 0
            for _, qData in ipairs(grp.quests) do
                categoryCounter = categoryCounter + 1
                qData.categoryIndex = categoryCounter
                local key = qData.entryKey or qData.questID
                local entry = activeMap[key]
                if entry then
                    entry.groupKey = grp.key

                    -- Use the same base X as section headers so entries stay aligned with categories.
                    -- Keep a small indent for entries (for numbering/chevron separation) via layout.entryIndentPx.
                    local entryBaseX = addon.GetScaledPadding()
                    local entryIndentPx = (addon.focus and addon.focus.layout and addon.focus.layout.entryIndentPx) or 0

                    -- Extra cushion when quest icons are enabled:
                    -- Do NOT shift the whole entry; that can make the icon sit left of the supertrack bar.
                    local iconModePad = 0

                    local entryX = entryBaseX + sectionLabelX + entryIndentPx + iconModePad

                    entry.finalX = entryX
                    entry.finalY = yOff
                    entry.staggerDelay = entryIndex * addon.FOCUS_ANIM.stagger
                    entryIndex = entryIndex + 1

                    if not entry:IsShown() and (entry.animState == "active" or entry.animState == "idle") and addon.GetDB("animations", true) then
                        SafeEntryFadeIn(entry, entryIndex - 1)
                    end
                    entry:ClearAllPoints()
                    entry:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", entryX, yOff)

                    local sfLeftInset = (blockFrame and blockPos == "top") and addon.GetScaledPadding() or 0
                    local sfVisibleW = addon.GetPanelWidth() - sfLeftInset
                    local entryW = sfVisibleW - entryX - addon.GetScaledContentRightPadding()
                    if entryW > 0 then
                        entry:SetWidth(entryW)
                    end

                    -- Keep questTypeIcon anchored to the entry frame so it scrolls/clips correctly.
                    if entry.questTypeIcon then
                        entry.questTypeIcon:ClearAllPoints()
                        local showIcons = addon.GetDB("showQuestTypeIcons", false)
                        if showIcons then
                            -- Place icon to the right of the supertracked highlight bar so the bar is always leftmost.
                            local highlightStyle = addon.NormalizeHighlightStyle(addon.GetDB("activeQuestHighlight", "bar-left")) or "bar-left"
                            local barW = math.max(2, math.min(6, tonumber(addon.GetDB("highlightBarWidth", 2)) or 2))
                            local barLeft = addon.Scaled(addon.BAR_LEFT_OFFSET or 12)
                            local padAfterBar = addon.Scaled(6)

                            if highlightStyle == "bar-left" or highlightStyle == "pill-left" then
                                -- bar starts at -barLeft; its right edge is (-barLeft + barW)
                                entry.questTypeIcon:SetPoint("TOPLEFT", entry, "TOPLEFT", -barLeft + barW + padAfterBar, 0)
                            else
                                -- Fallback to legacy off-to-the-left placement for non-left-bar styles.
                                local iconRight = addon.Scaled((addon.BAR_LEFT_OFFSET or 12) + 2)
                                entry.questTypeIcon:SetPoint("TOPRIGHT", entry, "TOPLEFT", -iconRight, 0)
                            end
                        else
                            -- Icons off: keep the legacy off-to-the-left placement so text alignment remains unchanged.
                            local iconRight = addon.Scaled((addon.BAR_LEFT_OFFSET or 12) + 2)
                            entry.questTypeIcon:SetPoint("TOPRIGHT", entry, "TOPLEFT", -iconRight, 0)
                        end
                    end

                    entry:Show()
                    entry._scrollFadeSpacing = entrySpacing
                    yOff = yOff - entry.entryHeight - entrySpacing
                end
            end
        end
    end

    if slideUpStarts and next(slideUpStarts) and addon.GetDB("animations", true) then
        for i = 1, addon.POOL_SIZE do
            local e = pool[i]
            if e and (e.questID or e.entryKey) and e.animState == "active" and e.finalY ~= nil then
                local key = e.questID or e.entryKey
                local prevY = slideUpStarts[key]
                if prevY and prevY ~= e.finalY then
                    addon.SetEntrySlideUp(e, prevY)
                end
            end
        end
    end
    if slideUpStartsSec and next(slideUpStartsSec) and addon.GetDB("animations", true) then
        for i = 1, addon.SECTION_POOL_SIZE do
            local s = sectionPool[i]
            if s and s.active and s.groupKey and s.finalY ~= nil then
                local prevY = slideUpStartsSec[s.groupKey]
                if prevY and prevY ~= s.finalY then
                    s.slideUpStartY = prevY
                    s.slideUpAnimTime = 0
                end
            end
        end
    end
    if useWQExpand and addon.ApplyGroupExpandSlideDown then
        addon.ApplyGroupExpandSlideDown()
    end

    addon.UpdateHeaderQuestCount(#quests, addon.CountTrackedInLog(quests))

    local totalContentH = math.max(-yOff, 1)
    local prevScroll = addon.focus.layout.scrollOffset
    scrollChild:SetHeight(totalContentH)

    local frameH = scrollFrame:GetHeight() or 0
    local maxScr = math.max(totalContentH - frameH, 0)
    addon.focus.layout.scrollOffset = math.min(prevScroll, maxScr)
    addon.ApplyScrollOffset(addon.focus.layout.scrollOffset)
    if addon.UpdateScrollIndicators then addon.UpdateScrollIndicators() end

    local headerArea
    if addon.GetDB("hideObjectivesHeader", false) then
        headerArea = addon.GetScaledMinimalHeaderHeight() + addon.Scaled(4)
    else
        headerArea = addon.GetScaledPadding() + addon.GetHeaderHeight() + addon.GetScaledDividerHeight() + addon.GetHeaderToContentGap()
    end
    local visibleH      = math.min(totalContentH, addon.GetMaxContentHeight())
    local blockHeight   = (hasMplus and addon.GetMplusBlockHeight and (addon.GetMplusBlockHeight() + gap * 2)) or 0
    local desiredH      = math.max(addon.GetScaledMinHeight(), headerArea + visibleH + addon.GetScaledPadding() + blockHeight)
    addon.focus.layout.targetHeight  = math.min(desiredH, GetMaxPanelHeight())

    if #quests > 0 then
        ApplyShowAlpha()
        addon.HS:Show()
    else
        addon.HS:Hide()
        HideAllItemButtons()
        addon.UpdateFloatingQuestItem(nil)
    end

    if addon.EnsureFocusUpdateRunning then addon.EnsureFocusUpdateRunning() end
end

--- Lightweight color refresh: updates section headers and entry title colors without FullLayout.
--- Used during live color picker drag for responsive feedback.
function addon.ApplyFocusColors()
    if not addon.focus or not addon.focus.enabled then return end
    local function ApplyTextureColorKeepAlpha(tex, color)
        if not tex or not tex.IsShown or not tex:IsShown() or not color then return end
        local _, _, _, a = tex:GetVertexColor()
        tex:SetColorTexture(color[1], color[2], color[3], a or 1)
    end
    local focusedGroupKey = addon.GetFocusedGroupKey and addon.GetFocusedGroupKey()
    for i = 1, addon.SECTION_POOL_SIZE do
        local s = sectionPool[i]
        if s and s.groupKey and s:IsShown() then
            local color = addon.GetSectionColor and addon.GetSectionColor(s.groupKey)
            if color and type(color) == "table" and color[1] and color[2] and color[3] then
                if addon.GetDB("dimNonSuperTracked", false) and focusedGroupKey and s.groupKey ~= focusedGroupKey then
                    color = addon.ApplyDimColor(color)
                end
                s.text:SetTextColor(color[1], color[2], color[3], addon.SECTION_COLOR_A or 1)
            end
        end
    end
    for key, entry in pairs(activeMap) do
        if entry and (entry.questID or entry.entryKey) and entry.titleText then
            local category = entry.category
            if not category and entry.groupKey == "RARES" then category = "RARE" end
            if not category and entry.groupKey == "ACHIEVEMENTS" then category = "ACHIEVEMENT" end
            if not category and entry.groupKey == "ENDEAVORS" then category = "ENDEAVOR" end
            if not category and entry.groupKey == "DECOR" then category = "DECOR" end
            if not category and entry.groupKey == "RECIPES" then category = "RECIPE" end
            local effectiveCat = (addon.GetEffectiveColorCategory and addon.GetEffectiveColorCategory(category, entry.groupKey, entry.baseCategory, entry.isEventQuest)) or category

            local titleColor = (addon.GetTitleColor and addon.GetTitleColor(effectiveCat)) or addon.QUEST_COLORS and addon.QUEST_COLORS.DEFAULT
            if titleColor and type(titleColor) == "table" and titleColor[1] and titleColor[2] and titleColor[3] then
                local dimAlpha = 1
                if entry.isDungeonQuest and not entry.isTracked then
                    local df = addon.DUNGEON_UNTRACKED_DIM or 0.65
                    titleColor = { titleColor[1] * df, titleColor[2] * df, titleColor[3] * df }
                elseif addon.GetDB("dimNonSuperTracked", false) and not entry.isSuperTracked then
                    titleColor = addon.ApplyDimColor(titleColor)
                    dimAlpha = addon.GetDimAlpha()
                end
                if entry.isRecipe and addon.GetDB("recipeRarityColors", false) and entry.outputQuality then
                    local qc = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[entry.outputQuality]
                    if qc then titleColor = { qc.r, qc.g, qc.b } end
                end
                entry.titleText:SetTextColor(titleColor[1], titleColor[2], titleColor[3], dimAlpha)
            end

            if entry.zoneText and entry.zoneText:IsShown() then
                local zoneColor = (addon.GetZoneColor and addon.GetZoneColor(effectiveCat)) or addon.ZONE_COLOR
                if zoneColor and type(zoneColor) == "table" and zoneColor[1] and zoneColor[2] and zoneColor[3] then
                    local dimAlpha = 1
                    if addon.GetDB("dimNonSuperTracked", false) and not entry.isSuperTracked then
                        zoneColor = addon.ApplyDimColor(zoneColor)
                        dimAlpha = addon.GetDimAlpha()
                    end
                    entry.zoneText:SetTextColor(zoneColor[1], zoneColor[2], zoneColor[3], dimAlpha)
                end
            end

            if entry.objectives then
                local objColor = (addon.GetObjectiveColor and addon.GetObjectiveColor(effectiveCat))
                    or addon.OBJ_COLOR or titleColor or { 0.9, 0.9, 0.9 }
                local doneColor = (addon.GetCompletedObjectiveColor and addon.GetCompletedObjectiveColor(effectiveCat))
                    or (addon.GetObjectiveColor and addon.GetObjectiveColor(effectiveCat))
                    or addon.OBJ_DONE_COLOR or objColor
                local dimAlpha = 1
                if addon.GetDB("dimNonSuperTracked", false) and not entry.isSuperTracked then
                    objColor = addon.ApplyDimColor(objColor)
                    doneColor = addon.ApplyDimColor(doneColor)
                    dimAlpha = addon.GetDimAlpha()
                end
                for j = 1, addon.MAX_OBJECTIVES do
                    local obj = entry.objectives[j]
                    if obj and obj.text and obj.text:IsShown() then
                        local alpha = (type(obj._hsAlpha) == "number") and obj._hsAlpha or 1
                        local isFinished = obj._hsFinished == true
                        local useTick = isFinished and addon.GetDB("useTickForCompletedObjectives", false) and not entry.isComplete
                        local targetColor = objColor
                        if entry.isRecipe and addon.GetDB("recipeRarityColors", false) and obj._hsItemQuality then
                            local qc = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[obj._hsItemQuality]
                            if qc then targetColor = { qc.r, qc.g, qc.b } end
                        end
                        if isFinished and not useTick then
                            targetColor = doneColor
                        end
                        obj.text:SetTextColor(targetColor[1], targetColor[2], targetColor[3], alpha * dimAlpha)

                        -- Live-update progress bar colors
                        if obj.progressBarFill and obj.progressBarFill:IsShown() then
                            local pfc
                            if addon.GetDB("progressBarUseCategoryColor", true) then
                                pfc = titleColor
                            else
                                pfc = addon.GetDB("progressBarFillColor", nil)
                                if not pfc or type(pfc) ~= "table" then pfc = { 0.40, 0.65, 0.90 } end
                            end
                            if pfc and pfc[1] and pfc[2] and pfc[3] then
                                obj.progressBarFill:SetColorTexture(pfc[1], pfc[2], pfc[3], pfc[4] or 0.85)
                            end
                        end
                        if obj.progressBarLabel and obj.progressBarLabel:IsShown() then
                            local ptc = addon.GetDB("progressBarTextColor", nil)
                            if not ptc or type(ptc) ~= "table" then ptc = { 0.95, 0.95, 0.95 } end
                            obj.progressBarLabel:SetTextColor(ptc[1], ptc[2], ptc[3], 1)
                        end
                    end
                end
            end

            if entry.isSuperTracked then
                local highlightColor = addon.GetDB("highlightColor", nil)
                if type(highlightColor) ~= "table" or not highlightColor[1] or not highlightColor[2] or not highlightColor[3] then
                    highlightColor = { 0.40, 0.70, 1.00 }
                end
                ApplyTextureColorKeepAlpha(entry.trackBar, highlightColor)
                ApplyTextureColorKeepAlpha(entry.highlightBg, highlightColor)
                ApplyTextureColorKeepAlpha(entry.highlightTop, highlightColor)
                ApplyTextureColorKeepAlpha(entry.highlightBorderT, highlightColor)
                ApplyTextureColorKeepAlpha(entry.highlightBorderB, highlightColor)
                ApplyTextureColorKeepAlpha(entry.highlightBorderL, highlightColor)
                ApplyTextureColorKeepAlpha(entry.highlightBorderR, highlightColor)
            end
        end
    end
end

addon.GetPlayerCurrentZoneName = GetPlayerCurrentZoneName
addon.AcquireEntry        = AcquireEntry
addon.FullLayout          = FullLayout
