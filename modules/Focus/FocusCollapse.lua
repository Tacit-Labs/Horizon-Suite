--[[
    Horizon Suite - Focus - Collapse and Combat
    ToggleCollapse, StartGroupCollapse, ShouldShowInInstance, CountTrackedInLog, RefreshContentInCombat.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

local pool       = addon.pool
local activeMap  = addon.activeMap
local sectionPool = addon.sectionPool
local scrollFrame = addon.scrollFrame
local scrollChild = addon.scrollChild

local COLLAPSE_CANCEL_DEBOUNCE_SEC  = 2
local COMPLETED_OBJECTIVE_FADE_ALPHA = 0.4
local MIN_TICK_SIZE                  = 10

--- Toggles full-panel collapsed/expanded state. Starts collapse animation or cancels in-progress collapse.
local function ToggleCollapse()
    if addon.focus.collapse.animating then
        if (GetTime() - addon.focus.collapse.animStart) < COLLAPSE_CANCEL_DEBOUNCE_SEC then return end
        addon.focus.collapse.animating = false
        addon.focus.collapse.sectionHeadersFadingOut = false
        addon.focus.collapse.sectionHeadersFadingOutKeys = nil
        addon.focus.collapse.sectionHeadersFadingIn = false
        addon.focus.collapse.headerSlidingToBottom = false
        addon.focus.collapse.headerSlidingToTop = false
        for i = 1, addon.POOL_SIZE do
            if pool[i].animState == "collapsing" then
                addon.ClearEntry(pool[i])
            end
        end
        for i = 1, addon.SECTION_POOL_SIZE do
            if sectionPool[i].active then
                sectionPool[i]:SetAlpha(0)
                sectionPool[i]:Hide()
                sectionPool[i].active = false
            end
        end
        wipe(activeMap)
        scrollFrame:Hide()
        addon.focus.layout.targetHeight = addon.GetCollapsedHeight()
    end
    -- When panel is collapsed but categories are expanded via pceg, the panel
    -- is visually "expanded". Clicking the header should re-collapse everything
    -- instead of toggling to the fully expanded state.
    local pceg = addon.focus.collapse.panelCollapsedExpandedGroups
    if addon.focus.collapsed and pceg and next(pceg) ~= nil then
        wipe(pceg)
        addon.chevron:SetText("+")

        -- Animate visible entries out
        local visibleEntries = {}
        for i = 1, addon.POOL_SIZE do
            local e = pool[i]
            if (e.questID or e.entryKey) and (e.animState == "active" or e.animState == "fadein") then
                visibleEntries[#visibleEntries + 1] = e
            end
        end
        table.sort(visibleEntries, function(a, b) return a.finalY < b.finalY end)
        for _, e in ipairs(visibleEntries) do
            addon.SetEntryCollapsing(e, 0)
        end

        local useAnim = addon.GetDB("animations", true)
        if useAnim then
            addon.focus.collapse.sectionHeadersFadingOut = true
            addon.focus.collapse.sectionHeaderFadeTime   = 0
        else
            for i = 1, addon.SECTION_POOL_SIZE do
                if sectionPool[i].active then
                    sectionPool[i]:SetAlpha(0)
                    sectionPool[i]:Hide()
                    sectionPool[i].active = false
                end
            end
        end

        -- Slide header from top to bottom
        if addon.GetDB("growUp", false) and addon.GetDB("growUpHeaderMode", "always") == "collapse" and useAnim then
            local panelH = addon.HS and addon.HS:GetHeight() or (addon.focus.layout and addon.focus.layout.currentHeight) or addon.GetCollapsedHeight()
            local minimal = addon.GetDB("hideObjectivesHeader", false)
            local S = addon.Scaled or function(v) return v end
            local pad = S(addon.PADDING)
            local headerH = minimal and addon.GetScaledMinimalHeaderHeight() or (pad + addon.GetHeaderHeight())
            addon.focus.collapse.headerSlidingToBottom = true
            addon.focus.collapse.headerSlideStartY = math.max(0, (panelH or 0) - headerH)
            addon.focus.collapse.headerSlideTime = 0
        end

        addon.focus.collapse.animating = #visibleEntries > 0 or addon.focus.collapse.sectionHeadersFadingOut or addon.focus.collapse.headerSlidingToBottom
        addon.focus.collapse.animStart = GetTime()
        if addon.focus.collapse.animating and addon.EnsureFocusUpdateRunning then
            addon.EnsureFocusUpdateRunning()
        end
        if not addon.focus.collapse.animating then
            local showHeadersWhenCollapsed = addon.GetDB("showSectionHeadersWhenCollapsed", false)
            if showHeadersWhenCollapsed then
                addon.FullLayout()
            else
                scrollFrame:Hide()
                addon.focus.layout.targetHeight = addon.GetCollapsedHeight()
            end
        end
        return
    end

    addon.focus.collapsed = not addon.focus.collapsed
    if addon.focus.collapse.panelCollapsedExpandedGroups then
        wipe(addon.focus.collapse.panelCollapsedExpandedGroups)
    end
    if addon.focus.collapsed then
        addon.chevron:SetText("+")

        local visibleEntries = {}
        for i = 1, addon.POOL_SIZE do
            local e = pool[i]
            if (e.questID or e.entryKey) and (e.animState == "active" or e.animState == "fadein") then
                visibleEntries[#visibleEntries + 1] = e
            end
        end

        table.sort(visibleEntries, function(a, b) return a.finalY < b.finalY end)

        for idx, e in ipairs(visibleEntries) do
            addon.SetEntryCollapsing(e, 0)
        end

        local showHeadersWhenCollapsed = addon.GetDB("showSectionHeadersWhenCollapsed", false)
        local useAnim = addon.GetDB("animations", true)
        if useAnim then
            addon.focus.collapse.sectionHeadersFadingOut = true
            addon.focus.collapse.sectionHeaderFadeTime   = 0
        else
            for i = 1, addon.SECTION_POOL_SIZE do
                if sectionPool[i].active then
                    sectionPool[i]:SetAlpha(0)
                    sectionPool[i]:Hide()
                    sectionPool[i].active = false
                end
            end
        end

        addon.focus.collapse.animating = #visibleEntries > 0 or addon.focus.collapse.sectionHeadersFadingOut or addon.focus.collapse.headerSlidingToBottom
        addon.focus.collapse.animStart = GetTime()
        -- Start header slide animation when growUp + collapse mode
        if addon.GetDB("growUp", false) and addon.GetDB("growUpHeaderMode", "always") == "collapse" and addon.GetDB("animations", true) then
            local panelH = addon.HS and addon.HS:GetHeight() or (addon.focus.layout and addon.focus.layout.currentHeight) or addon.GetCollapsedHeight()
            local minimal = addon.GetDB("hideObjectivesHeader", false)
            local S = addon.Scaled or function(v) return v end
            local pad = S(addon.PADDING)
            local headerH = minimal and addon.GetScaledMinimalHeaderHeight() or (pad + addon.GetHeaderHeight())
            addon.focus.collapse.headerSlidingToBottom = true
            addon.focus.collapse.headerSlideStartY = math.max(0, (panelH or 0) - headerH)
            addon.focus.collapse.headerSlideTime = 0
        end
        if addon.focus.collapse.animating and addon.EnsureFocusUpdateRunning then
            addon.EnsureFocusUpdateRunning()
        end
        if not addon.focus.collapse.animating then
            if showHeadersWhenCollapsed then
                addon.FullLayout()
            else
                scrollFrame:Hide()
                addon.focus.layout.targetHeight = addon.GetCollapsedHeight()
            end
        end
    else
        addon.chevron:SetText("-")
        scrollFrame:Show()
        if addon.GetDB("animations", true) then
            addon.focus.collapse.sectionHeadersFadingIn  = true
            addon.focus.collapse.sectionHeaderFadeTime    = 0
        end
        -- Start header slide up when growUp + collapse mode (header animates from bottom to top)
        if addon.GetDB("growUp", false) and addon.GetDB("growUpHeaderMode", "always") == "collapse" and addon.GetDB("animations", true) then
            local panelH = addon.focus.layout and addon.focus.layout.targetHeight or (addon.HS and addon.HS:GetHeight()) or addon.MIN_HEIGHT
            local minimal = addon.GetDB("hideObjectivesHeader", false)
            local S = addon.Scaled or function(v) return v end
            local pad = S(addon.PADDING)
            local headerH = minimal and addon.GetScaledMinimalHeaderHeight() or (pad + addon.GetHeaderHeight())
            addon.focus.collapse.headerSlidingToTop = true
            addon.focus.collapse.headerSlideEndY = math.max(0, (panelH or 0) - headerH)
            addon.focus.collapse.headerSlideTime = 0
        end
        addon.FullLayout()
    end
    addon.EnsureDB()
    addon.SetDB("collapsed", addon.focus.collapsed)
end

--- Initiates category collapse for a group. Animates entries collapsing, then runs FullLayout.
--- @param groupKey string Category key (e.g. "NEARBY", "WEEKLY")
local function StartGroupCollapse(groupKey)
    if not groupKey then return end

    local entries = {}
    for i = 1, addon.POOL_SIZE do
        local e = pool[i]
        if e.groupKey == groupKey
           and (e.questID or e.entryKey)
           and (e.animState == "active" or e.animState == "fadein") then
            entries[#entries + 1] = e
        end
    end

    if #entries == 0 then
        addon.SetCategoryCollapsed(groupKey, true)
        addon.FullLayout()
        return
    end

    table.sort(entries, function(a, b)
        return a.finalY > b.finalY
    end)

    for i, e in ipairs(entries) do
        addon.SetEntryCollapsing(e, i - 1)
    end

    addon.focus.collapse.groups[groupKey] = GetTime()
    if addon.EnsureFocusUpdateRunning then
        addon.EnsureFocusUpdateRunning()
    end

    if addon.SetCategoryCollapsed then
        addon.SetCategoryCollapsed(groupKey, true)
    end
end

--- Cancels an in-progress group collapse animation. Removes the group from the collapse tracker
--- and immediately clears any pool entries still animating out, so FullLayout() can run.
--- @param groupKey string Category key (e.g. "NEARBY", "WEEKLY")
local function CancelGroupCollapse(groupKey)
    if not groupKey then return end
    if addon.focus.collapse.groups then
        addon.focus.collapse.groups[groupKey] = nil
    end
    for i = 1, addon.POOL_SIZE do
        local e = pool[i]
        if e.groupKey == groupKey and e.animState == "collapsing" then
            addon.ClearEntry(e)
        end
    end
end

--- Same as StartGroupCollapse but visual-only: no FullLayout or SetCategoryCollapsed.
--- @param groupKey string Category key
local function StartGroupCollapseVisual(groupKey)
    if not groupKey then return end

    local entries = {}
    for i = 1, addon.POOL_SIZE do
        local e = pool[i]
        if e.groupKey == groupKey
           and (e.questID or e.entryKey)
           and (e.animState == "active" or e.animState == "fadein") then
            entries[#entries + 1] = e
        end
    end

    if #entries == 0 then
        if addon.FullLayout then addon.FullLayout() end
        return
    end

    table.sort(entries, function(a, b)
        return a.finalY > b.finalY
    end)

    for i, e in ipairs(entries) do
        addon.SetEntryCollapsing(e, i - 1)
    end

    addon.focus.collapse.groups[groupKey] = GetTime()
end

--- Triggers fade-in for NEARBY entries. Sorts by finalY descending and staggers fade-in.
local function TriggerNearbyEntriesFadeIn()
    local entries = {}
    for i = 1, addon.POOL_SIZE do
        local e = pool[i]
        if e.groupKey == "NEARBY" and (e.questID or e.entryKey) and (e.animState == "active" or e.animState == "fadein") then
            entries[#entries + 1] = e
        end
    end
    table.sort(entries, function(a, b)
        return (a.finalY or 0) > (b.finalY or 0)
    end)
    for i, e in ipairs(entries) do
        addon.SetEntryFadeIn(e, i - 1)
    end
end

--- Slides out non-NEARBY entries, then runs FullLayout and TriggerNearbyEntriesFadeIn when slide-out completes.
local function StartNearbyTurnOnTransition()
    local quests = addon.ReadTrackedQuests()
    local grouped = addon.SortAndGroupQuests(quests)
    local nearbyKeys = {}
    for _, grp in ipairs(grouped) do
        if grp.key == "NEARBY" then
            for _, q in ipairs(grp.quests) do
                nearbyKeys[q.entryKey or q.questID] = true
            end
            break
        end
    end

    local slideOutCount = 0
    for i = 1, addon.POOL_SIZE do
        local e = pool[i]
        local key = e.questID or e.entryKey
        if key and nearbyKeys[key] and e.groupKey ~= "NEARBY" and (e.animState == "active" or e.animState == "fadein") then
            e.animState = "slideout"
            e.animTime  = 0
            slideOutCount = slideOutCount + 1
        end
    end

    if slideOutCount > 0 then
        addon.focus.callbacks.onSlideOutComplete = function()
            addon.focus.callbacks.onSlideOutComplete = nil
            if addon.FullLayout then addon.FullLayout() end
            if addon.TriggerNearbyEntriesFadeIn then addon.TriggerNearbyEntriesFadeIn() end
        end
    else
        if addon.FullLayout then addon.FullLayout() end
        if addon.TriggerNearbyEntriesFadeIn then addon.TriggerNearbyEntriesFadeIn() end
    end
end

--- Whether to show the tracker in the current instance type (dungeon, raid, bg, arena).
--- Master dungeon/raid toggles apply first; per-difficulty keys only when master is on (nil = use default show).
--- @return boolean
local function ShouldShowInInstance()
    local _, inType, difficultyID = GetInstanceInfo()
    if inType == "none" then return true end
    if inType == "party" then
        if not addon.GetDB("showInDungeon", true) then
            return false
        end
        -- Per-difficulty dungeon toggles; nil granular = show (master is on)
        if difficultyID == 1 then  -- Normal
            local v = addon.GetDB("showInDungeonNormal", nil)
            if v ~= nil then return v end
        elseif difficultyID == 2 then  -- Heroic
            local v = addon.GetDB("showInDungeonHeroic", nil)
            if v ~= nil then return v end
        elseif difficultyID == 23 then  -- Mythic
            local v = addon.GetDB("showInDungeonMythic", nil)
            if v ~= nil then return v end
        elseif difficultyID == 8 then  -- Mythic Keystone (M+)
            local v = addon.GetDB("showInDungeonMythicPlus", nil)
            if v ~= nil then return v end
        end
        return true
    end
    if inType == "raid" then
        if not addon.GetDB("showInRaid", false) then
            return false
        end
        -- Per-difficulty raid toggles; nil granular = show (master is on)
        if difficultyID == 17 then  -- LFR
            local v = addon.GetDB("showInRaidLFR", nil)
            if v ~= nil then return v end
        elseif difficultyID == 14 then  -- Normal
            local v = addon.GetDB("showInRaidNormal", nil)
            if v ~= nil then return v end
        elseif difficultyID == 15 then  -- Heroic
            local v = addon.GetDB("showInRaidHeroic", nil)
            if v ~= nil then return v end
        elseif difficultyID == 16 then  -- Mythic
            local v = addon.GetDB("showInRaidMythic", nil)
            if v ~= nil then return v end
        end
        return true
    end
    if inType == "pvp"    then return addon.GetDB("showInBattleground", false) end
    if inType == "arena"  then return addon.GetDB("showInArena", false) end
    return true
end

--- Counts non-rare/achievement/endeavor/decor entries that are in the quest log.
--- @param quests table Array of normalized entry tables
--- @return number
local function CountTrackedInLog(quests)
    if not quests then return 0 end
    local n = 0
    local getLogIdx = C_QuestLog and C_QuestLog.GetLogIndexForQuestID
    local isWQ = addon.IsQuestWorldQuest
    for _, entry in ipairs(quests) do
        if not (entry.isRare or entry.category == "RARE" or entry.isAchievement or entry.category == "ACHIEVEMENT" or entry.isEndeavor or entry.category == "ENDEAVOR" or entry.isDecor or entry.category == "DECOR" or entry.isAppearance or entry.category == "APPEARANCE") then
            local qid = entry.questID
            if qid and getLogIdx and getLogIdx(qid) and (not isWQ or not isWQ(qid)) and entry.isTracked ~= false then
                n = n + 1
            end
        end
    end
    return n
end

addon.ToggleCollapse             = ToggleCollapse
addon.StartGroupCollapse         = StartGroupCollapse
addon.CancelGroupCollapse        = CancelGroupCollapse
addon.StartGroupCollapseVisual   = StartGroupCollapseVisual
addon.TriggerNearbyEntriesFadeIn = TriggerNearbyEntriesFadeIn
addon.StartNearbyTurnOnTransition = StartNearbyTurnOnTransition
addon.ShouldShowInInstance       = ShouldShowInInstance
addon.CountTrackedInLog          = CountTrackedInLog
