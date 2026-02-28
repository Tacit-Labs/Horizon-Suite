--[[
    Horizon Suite - Focus - Slash Commands
    /h focus [cmd] subcommands. Registers with core via addon.RegisterSlashHandler.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.RegisterSlashHandler then return end
local HSPrint = addon.HSPrint or function(msg) print("|cFF00CCFFHorizon Suite - Focus:|r " .. tostring(msg or "")) end
local colorCheckState = nil

local function DeepCopy(value)
    if type(value) ~= "table" then return value end
    local out = {}
    for k, v in pairs(value) do
        out[k] = DeepCopy(v)
    end
    return out
end

local function StopColorCheck(announce)
    if not colorCheckState then return end
    if colorCheckState.ticker and colorCheckState.ticker.Cancel then
        colorCheckState.ticker:Cancel()
    end

    addon.SetDB("colorMatrix", DeepCopy(colorCheckState.restore.colorMatrix))
    addon.SetDB("highlightColor", DeepCopy(colorCheckState.restore.highlightColor))
    addon.SetDB("completedObjectiveColor", DeepCopy(colorCheckState.restore.completedObjectiveColor))
    addon.SetDB("useCompletedObjectiveColor", colorCheckState.restore.useCompletedObjectiveColor)

    if addon.ApplyFocusColors then
        addon.ApplyFocusColors()
    elseif addon.FullLayout then
        addon.FullLayout()
    end

    colorCheckState = nil
    if announce then
        HSPrint("Color check stopped and original colors restored.")
    end
end

local function MatrixKey(category)
    if category == "RARE" then return "RARES" end
    if category == "ACHIEVEMENT" then return "ACHIEVEMENTS" end
    if category == "ENDEAVOR" then return "ENDEAVORS" end
    if category == "DECOR" then return "DECOR" end
    return category
end

local function CategoryFromEntry(entry)
    local category = entry and entry.category
    if category then return category end
    local groupKey = entry and entry.groupKey
    if groupKey == "RARES" then return "RARE" end
    if groupKey == "ACHIEVEMENTS" then return "ACHIEVEMENT" end
    if groupKey == "ENDEAVORS" then return "ENDEAVOR" end
    if groupKey == "DECOR" then return "DECOR" end
    return nil
end

local function CollectVisibleColorKeys()
    local categoryKeys = {}
    local sectionKeys = {}

    if addon.activeMap then
        for _, entry in pairs(addon.activeMap) do
            if entry and (entry.questID or entry.entryKey) then
                local cat = CategoryFromEntry(entry)
                if cat then categoryKeys[MatrixKey(cat)] = true end
            end
        end
    end
    if next(categoryKeys) == nil then
        categoryKeys.DEFAULT = true
    end

    local sectionPool = addon.sectionPool
    if sectionPool then
        for i = 1, addon.SECTION_POOL_SIZE do
            local s = sectionPool[i]
            if s and s.groupKey and s:IsShown() then
                sectionKeys[s.groupKey] = true
            end
        end
    end
    if next(sectionKeys) == nil then
        sectionKeys.DEFAULT = true
    end

    return categoryKeys, sectionKeys
end

-- ============================================================================
-- FOCUS HELP
-- ============================================================================

local function ShowFocusShortHelp()
    HSPrint("Focus commands:")
    HSPrint("  /h focus            - Show this help")
    HSPrint("  /h focus toggle     - Enable / disable")
    HSPrint("  /h focus collapse   - Collapse / expand panel")
    HSPrint("  /h focus nearby     - Toggle Nearby (Current Zone) group")
    HSPrint("  /h focus reset      - Reset to live data")
    HSPrint("  /h focus resetpos   - Reset panel to default position")
    HSPrint("  /h focus test       - Show with test data")
    HSPrint("  /h focus testitem   - Inject one debug quest with item (real quests stay)")
    HSPrint("  /h focus testsound  - Play the rare-added notification sound")
    HSPrint("  /h focus colorcheck - Cycle focus colors (title/objective/zone/section/highlight), then restore")
    HSPrint("")
    HSPrint("  Click the header row to collapse / expand.")
    HSPrint("  Scroll with mouse wheel when content overflows.")
    HSPrint("  Drag the panel to reposition it (saved across sessions).")
    HSPrint("  Left-click a quest or rare to super-track; Left-click auto-complete quests to complete them.")
    HSPrint("  Shift+Left-click opens quest details; Right-click a quest to untrack, rare to clear super-track.")
end

local function ShowFocusDebugHelp()
    HSPrint("Focus debug commands (/h debug focus [cmd]):")
    HSPrint("  wqdebug, scendebug, nearbydebug, headercountdebug, groupdebug")
    HSPrint("  delvedebug, mplusaffixdebug, mplusdebug, endeavordebug, achievementdebug")
    HSPrint("  unaccepted, clicktodebug, profiledebug")
end

-- ============================================================================
-- FOCUS SLASH HANDLER (user + test/demo)
-- ============================================================================

local function HandleFocusSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "toggle" then
        if InCombatLockdown() then
            print("|cFFFF0000Horizon Suite:|r Cannot toggle during combat.")
            return
        end
        local currentlyEnabled = addon:IsModuleEnabled("focus")
        addon:SetModuleEnabled("focus", not currentlyEnabled)
        if addon:IsModuleEnabled("focus") then
            HSPrint("|cFF00FF00Focus enabled|r")
        else
            HSPrint("|cFFFF0000Focus disabled|r")
        end

    elseif cmd == "collapse" then
        addon.ToggleCollapse()
        if addon.focus.collapsed then
            print("|cFF00CCFFHorizon Suite - Focus:|r Panel collapsed.")
        else
            print("|cFF00CCFFHorizon Suite - Focus:|r Panel expanded.")
        end

    elseif cmd == "nearby" then
        local show = not addon.GetDB("showNearbyGroup", true)
        addon.SetDB("showNearbyGroup", show)
        if show then
            if addon.GetDB("animations", true) and addon.StartNearbyTurnOnTransition then
                addon.StartNearbyTurnOnTransition()
            else
                if _G.HorizonSuite_RequestRefresh then _G.HorizonSuite_RequestRefresh() end
                if addon.FullLayout then addon.FullLayout() end
            end
        else
            if addon.GetDB("animations", true) and addon.StartGroupCollapseVisual then
                addon.StartGroupCollapseVisual("NEARBY")
            else
                if _G.HorizonSuite_RequestRefresh then _G.HorizonSuite_RequestRefresh() end
                if addon.FullLayout then addon.FullLayout() end
            end
        end
        if show then
            print("|cFF00CCFFHorizon Suite - Focus:|r Nearby group shown.")
        else
            print("|cFF00CCFFHorizon Suite - Focus:|r Nearby group hidden.")
        end

    elseif cmd == "testsound" then
        if addon.PlayRareAddedSound then
            addon.PlayRareAddedSound()
            HSPrint("Played rare-added sound (choice: " .. tostring(addon.GetDB("rareAddedSoundChoice", "default")) .. ").")
        elseif PlaySound then
            local ok, err = pcall(PlaySound, addon.RARE_ADDED_SOUND)
            if not ok and HSPrint then HSPrint("PlaySound rare failed: " .. tostring(err)) end
            HSPrint("Played rare-added sound.")
        else
            HSPrint("Could not play sound.")
        end

    elseif cmd == "test" then
        HSPrint("Showing test data (10 entries)...")

        local testQuests = {
            { questID = 90001, title = "The Fate of the Horde",
              color = addon.QUEST_COLORS.CAMPAIGN, category = "CAMPAIGN",
              questTypeAtlas = "Quest-Campaign-Available",
              isComplete = false, isSuperTracked = true, isNearby = true, isAccepted = true,
              isGroupQuest = true,
              zoneName = "Valdrakken",
              itemLink = "item:12345:0:0:0:0:0:0:0", itemTexture = "Interface\\Icons\\INV_Misc_Rune_01",
              objectives = {
                  { text = "Speak with Thrall", finished = true },
                  { text = "Harbingers defeated: 2/5", finished = false },
              }},
            { questID = 90002, title = "Aiding the Accord",
              color = addon.QUEST_COLORS.DEFAULT, category = "DEFAULT",
              isComplete = false, isSuperTracked = false, isNearby = true, isAccepted = true,
              zoneName = "Valdrakken",
              objectives = {
                  { text = "Dragon Glyphs: 3/5", finished = false },
                  { text = "World Quests: 2/3", finished = false },
              }},
            { questID = 90007, title = "Scales of War",
              color = addon.QUEST_COLORS.DEFAULT, category = "DEFAULT",
              isComplete = false, isSuperTracked = false, isNearby = true, isAccepted = true,
              isGroupQuest = true,
              zoneName = "Valdrakken",
              objectives = {
                  { text = "War Scales collected: 14/20", finished = false },
              }},
            { questID = 90006, title = "Threads of Fate",
              color = addon.QUEST_COLORS.CAMPAIGN, category = "CAMPAIGN",
              isComplete = false, isSuperTracked = false, isNearby = false, isAccepted = true,
              zoneName = "The Waking Shores",
              objectives = {
                  { text = "Explore the Loom: 1/3", finished = false },
              }},
            { questID = 90008, title = "The Last Stitch",
              color = addon.QUEST_COLORS.CAMPAIGN, category = "CAMPAIGN",
              isComplete = false, isSuperTracked = false, isNearby = false, isAccepted = true,
              zoneName = "Azure Span",
              itemLink = "item:67890:0:0:0:0:0:0:0", itemTexture = "Interface\\Icons\\INV_Fabric_Silk_02",
              objectives = {
                  { text = "Mend the Veil: 0/1", finished = false },
                  { text = "Gather Thread: 5/8", finished = false },
              }},
            { questID = 90003, title = "World Boss: Doomwalker",
              color = addon.QUEST_COLORS.WORLD, category = "WORLD",
              questTypeAtlas = "quest-recurring-available",
              isComplete = false, isSuperTracked = false, isNearby = false, isAccepted = true,
              isGroupQuest = true,
              zoneName = "Thaldraszus",
              objectives = {
                  { text = "Slay Doomwalker", finished = false },
              }},
            { questID = 90009, title = "Elemental Fury",
              color = addon.QUEST_COLORS.WORLD, category = "CALLING",
              isComplete = false, isSuperTracked = false, isNearby = false, isAccepted = true,
              zoneName = "The Forbidden Reach",
              objectives = {
                  { text = "Elemental cores: 1/3", finished = false },
              }},
            { questID = 90004, title = "The Legendary Cloak",
              color = addon.QUEST_COLORS.LEGENDARY, category = "LEGENDARY",
              questTypeAtlas = "UI-QuestPoiLegendary-QuestBang",
              isComplete = false, isSuperTracked = false, isNearby = false, isAccepted = true,
              zoneName = "Ohn'ahran Plains",
              objectives = {
                  { text = "Collect 50 Echoes: 37/50", finished = false },
              }},
            { questID = 90010, title = "Supply Run",
              color = addon.QUEST_COLORS.DEFAULT, category = "DEFAULT",
              isComplete = false, isSuperTracked = false, isNearby = false, isAccepted = true,
              zoneName = "Stormwind City",
              objectives = {
                  { text = "Deliver supplies: 0/1", finished = false },
              }},
            { questID = 90005, title = "Boar Pelts",
              color = addon.QUEST_COLORS.COMPLETE, category = "COMPLETE",
              questTypeAtlas = "QuestTurnin",
              isComplete = true, isAutoComplete = true, isSuperTracked = false, isNearby = false, isAccepted = true,
              zoneName = "Elwynn Forest",
              objectives = {
                  { text = "Boar Pelts: 10/10", finished = true },
              }},
        }

        -- Inject test data into the quest pipeline and use the normal layout engine.
        addon.testQuests = testQuests
        if addon.focus.collapsed then
            addon.focus.collapsed = false
            addon.chevron:SetText("-")
            addon.scrollFrame:Show()
            addon.SetDB("collapsed", false)
        end
        addon.FullLayout()

    elseif cmd == "testitem" then
        HSPrint("Injected one debug quest with a quest item (real quests remain). Use /h focus reset to clear.")
        addon.testQuestItem = {
            entryKey       = 89999,
            questID        = 89999,
            title          = "Debug: Quest Item",
            objectives     = { { text = "Use the item button to test", finished = false } },
            color          = addon.QUEST_COLORS and addon.QUEST_COLORS.DEFAULT or "|cFFFFFFFF",
            category       = "DEFAULT",
            isComplete     = false,
            isSuperTracked = false,
            isNearby       = true,
            isAccepted     = true,
            zoneName       = "Debug",
            itemLink       = "item:12345:0:0:0:0:0:0:0",
            itemTexture    = "Interface\\Icons\\INV_Misc_Rune_01",
            questTypeAtlas = nil,
            isDungeonQuest = false,
            isTracked      = true,
            level          = nil,
        }
        if addon.focus.collapsed then
            addon.focus.collapsed = false
            addon.chevron:SetText("-")
            addon.scrollFrame:Show()
            addon.SetDB("collapsed", false)
        end
        addon.FullLayout()

    elseif cmd == "reset" then
        -- Clear any injected test data and return to live quest data.
        addon.testQuests = nil
        addon.testQuestItem = nil
        addon.ScheduleRefresh()
        HSPrint("Reset tracker to live data.")

    elseif cmd == "resetpos" then
        addon.HS:ClearAllPoints()
        addon.HS:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", addon.PANEL_X, addon.PANEL_Y)
        addon.SetDB("point", nil)
        addon.SetDB("relPoint", nil)
        addon.SetDB("x", nil)
        addon.SetDB("y", nil)
        HSPrint("Position reset to default.")

    elseif cmd == "colorcheck" then
        if colorCheckState then
            StopColorCheck(true)
            return
        end

        local steps = {
            { name = "Red",   color = { 1.00, 0.25, 0.25 } },
            { name = "Green", color = { 0.25, 0.95, 0.35 } },
            { name = "Blue",  color = { 0.35, 0.60, 1.00 } },
            { name = "Gold",  color = { 1.00, 0.85, 0.25 } },
        }
        local categoryKeys, sectionKeys = CollectVisibleColorKeys()

        colorCheckState = {
            idx = 1,
            steps = steps,
            categoryKeys = categoryKeys,
            sectionKeys = sectionKeys,
            restore = {
                colorMatrix = DeepCopy(addon.GetDB("colorMatrix", nil)),
                highlightColor = DeepCopy(addon.GetDB("highlightColor", nil)),
                completedObjectiveColor = DeepCopy(addon.GetDB("completedObjectiveColor", nil)),
                useCompletedObjectiveColor = addon.GetDB("useCompletedObjectiveColor", true),
            },
        }

        local function ApplyStep(step)
            local matrix = DeepCopy(addon.GetDB("colorMatrix", nil))
            if type(matrix) ~= "table" then matrix = {} end
            matrix.categories = matrix.categories or {}
            matrix.overrides = matrix.overrides or {}

            for key in pairs(colorCheckState.categoryKeys) do
                matrix.categories[key] = matrix.categories[key] or {}
                matrix.categories[key].title = { step.color[1], step.color[2], step.color[3] }
                matrix.categories[key].objective = { step.color[1], step.color[2], step.color[3] }
                matrix.categories[key].zone = { step.color[1], step.color[2], step.color[3] }
            end
            for key in pairs(colorCheckState.sectionKeys) do
                matrix.categories[key] = matrix.categories[key] or {}
                matrix.categories[key].section = { step.color[1], step.color[2], step.color[3] }
            end

            addon.SetDB("colorMatrix", matrix)
            addon.SetDB("highlightColor", { step.color[1], step.color[2], step.color[3] })
            addon.SetDB("completedObjectiveColor", { step.color[1], step.color[2], step.color[3] })
            addon.SetDB("useCompletedObjectiveColor", true)

            if addon.ApplyFocusColors then
                addon.ApplyFocusColors()
            elseif addon.FullLayout then
                addon.FullLayout()
            end
        end

        local function Advance()
            if not colorCheckState then return end
            local step = colorCheckState.steps[colorCheckState.idx]
            if not step then
                StopColorCheck(false)
                HSPrint("Color check complete. Original colors restored.")
                return
            end
            ApplyStep(step)
            HSPrint(("Color check %d/%d: %s"):format(colorCheckState.idx, #colorCheckState.steps, step.name))
            colorCheckState.idx = colorCheckState.idx + 1
        end

        Advance()
        if C_Timer and C_Timer.NewTicker then
            colorCheckState.ticker = C_Timer.NewTicker(0.9, Advance, #steps)
        else
            StopColorCheck(false)
            HSPrint("Color check unavailable (C_Timer not found).")
        end

    else
        ShowFocusShortHelp()
    end
end

-- ============================================================================
-- FOCUS DEBUG HANDLER
-- ============================================================================

local function HandleFocusDebugSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "" or cmd == "help" then
        ShowFocusDebugHelp()
        return
    end

    if cmd == "wqdebug" then
        if addon.DumpWorldQuestDiscovery then
            addon.DumpWorldQuestDiscovery()
        else
            HSPrint("DumpWorldQuestDiscovery not available.")
        end

    elseif cmd == "scendebug" then
        local v = not (addon.GetDB and addon.GetDB("scenarioDebug", false))
        if addon.SetDB then addon.SetDB("scenarioDebug", v) end
        HSPrint("Scenario debug logging: " .. (v and "on" or "off"))
        if addon.ScheduleRefresh then addon.ScheduleRefresh() end

    elseif cmd == "mplusdebug" then
        addon.mplusDebugPreview = not addon.mplusDebugPreview
        if addon.FullLayout then addon.FullLayout() end
        HSPrint("M+ block debug preview: " .. (addon.mplusDebugPreview and "on" or "off"))

    elseif cmd == "mplusaffixdebug" then
        local mapId = C_ChallengeMode and C_ChallengeMode.GetActiveChallengeMapID and C_ChallengeMode.GetActiveChallengeMapID()
        HSPrint("--- M+ Affix Debug ---")
        HSPrint("GetActiveChallengeMapID: " .. (mapId and tostring(mapId) or "nil"))
        if not mapId then
            HSPrint("  (Not in an active challenge; run in M+ dungeon with key inserted)")
            return
        end
        if C_ChallengeMode and C_ChallengeMode.GetMapUIInfo then
            local name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapId)
            HSPrint("MapUIInfo: name=" .. tostring(name) .. " timeLimit=" .. tostring(timeLimit))
        end
        if C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo then
            local ok, level, affixes, wasEnergized = pcall(C_ChallengeMode.GetActiveKeystoneInfo)
            if ok then
                HSPrint("GetActiveKeystoneInfo: level=" .. tostring(level) .. " wasEnergized=" .. tostring(wasEnergized))
                if affixes and type(affixes) == "table" then
                    local ids = {}
                    for i = 1, #affixes do ids[#ids + 1] = tostring(affixes[i]) end
                    HSPrint("  affixes (IDs): " .. (#ids > 0 and table.concat(ids, ", ") or "empty"))
                    for i = 1, #affixes do
                        local id = affixes[i]
                        if id and type(id) == "number" and C_ChallengeMode.GetAffixInfo then
                            local aOk, name, desc, iconFileID = pcall(C_ChallengeMode.GetAffixInfo, id)
                            if aOk and name then
                                HSPrint("    ID " .. tostring(id) .. " -> " .. tostring(name))
                            else
                                HSPrint("    ID " .. tostring(id) .. " -> GetAffixInfo error or empty")
                            end
                        end
                    end
                else
                    HSPrint("  affixes: " .. (affixes == nil and "nil" or type(affixes)))
                end
            else
                HSPrint("GetActiveKeystoneInfo error: " .. tostring(level))
            end
        end
        if C_MythicPlus and C_MythicPlus.GetCurrentAffixes then
            local ok, currentAffixes = pcall(C_MythicPlus.GetCurrentAffixes)
            if ok and currentAffixes and type(currentAffixes) == "table" then
                local parts = {}
                for _, a in ipairs(currentAffixes) do
                    local id = (a and type(a) == "table" and a.id) or (type(a) == "number" and a) or nil
                    if id then parts[#parts + 1] = tostring(id) end
                end
                HSPrint("GetCurrentAffixes: " .. (#parts > 0 and table.concat(parts, ", ") or "empty"))
            else
                HSPrint("GetCurrentAffixes: " .. (ok and "empty/nil" or ("error: " .. tostring(currentAffixes))))
            end
        else
            HSPrint("GetCurrentAffixes: API not available")
        end
        if addon.GetMplusData then
            local data = addon.GetMplusData()
            if data and data.affixes then
                if #data.affixes > 0 then
                    local names = {}
                    for _, a in ipairs(data.affixes) do names[#names + 1] = a.name or "(nil)" end
                    HSPrint("GetMplusData.affixes (final): " .. table.concat(names, ", "))
                else
                    HSPrint("GetMplusData.affixes: empty")
                end
            else
                HSPrint("GetMplusData: nil or no affixes key")
            end
        else
            HSPrint("GetMplusData: not available")
        end
        HSPrint("--- End M+ Affix Debug ---")

    elseif cmd == "groupdebug" then
        HSPrint("|cFF00CCFF--- Group Quest Debug ---|r")
        local pool = addon.pool
        if pool then
            for i = 1, addon.POOL_SIZE do
                local e = pool[i]
                if e and e.questID and e.questID > 0 and e:IsShown() then
                    local qid = e.questID
                    local title = (e.titleText and e.titleText:GetText()) or tostring(qid)
                    local parts = { ("|cFFFFFF00%s|r (ID %d):"):format(title, qid) }
                    if C_QuestLog and C_QuestLog.GetQuestTagInfo then
                        local ok, ti = pcall(C_QuestLog.GetQuestTagInfo, qid)
                        if ok and ti then
                            parts[#parts+1] = ("  tagID=%s worldQuestType=%s tagName=%s"):format(
                                tostring(ti.tagID), tostring(ti.worldQuestType), tostring(ti.tagName))
                        else
                            parts[#parts+1] = "  GetQuestTagInfo: nil"
                        end
                    end
                    if C_TaskQuest and C_TaskQuest.GetQuestInfoByQuestID then
                        local ok, info = pcall(C_TaskQuest.GetQuestInfoByQuestID, qid)
                        if ok and info then
                            if type(info) == "table" then
                                local keys = {}
                                for k, v in pairs(info) do keys[#keys+1] = k .. "=" .. tostring(v) end
                                parts[#parts+1] = "  TaskQuestInfo: " .. table.concat(keys, ", ")
                            else
                                parts[#parts+1] = "  TaskQuestInfo: " .. tostring(info) .. " (type=" .. type(info) .. ")"
                            end
                        else
                            parts[#parts+1] = "  TaskQuestInfo: nil"
                        end
                    end
                    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
                        local logIdx = C_QuestLog.GetLogIndexForQuestID(qid)
                        if logIdx and C_QuestLog.GetInfo then
                            local ok, info = pcall(C_QuestLog.GetInfo, logIdx)
                            if ok and info then
                                parts[#parts+1] = ("  suggestedGroup=%s"):format(tostring(info.suggestedGroup))
                            end
                        else
                            parts[#parts+1] = "  Not in quest log"
                        end
                    end
                    local isGroup = addon.IsGroupQuest and addon.IsGroupQuest(qid) or false
                    parts[#parts+1] = ("  |cFF00FF00IsGroupQuest = %s|r"):format(tostring(isGroup))
                    for _, line in ipairs(parts) do
                        HSPrint(line)
                    end
                end
            end
        end
        HSPrint("|cFF00CCFF--- End Group Quest Debug ---|r")

    elseif cmd == "nearbydebug" then
        if addon.GetNearbyDebugInfo then
            HSPrint("|cFF00CCFF--- Nearby / Current Zone debug ---|r")
            for _, line in ipairs(addon.GetNearbyDebugInfo()) do
                HSPrint(line)
            end
        else
            HSPrint("GetNearbyDebugInfo not available.")
        end

    elseif cmd == "headercountdebug" then
        if addon.DebugHeaderCount then
            addon.DebugHeaderCount()
        else
            HSPrint("DebugHeaderCount not available.")
        end

    elseif cmd == "achievementdebug" then
        HSPrint("|cFF00CCFF--- Achievement Tracking Debug ---|r")
        local TRACKING_TYPE_ACHIEVEMENT = (Enum and Enum.ContentTrackingType and Enum.ContentTrackingType.Achievement) or 2
        local idList = {}
        if C_ContentTracking and C_ContentTracking.GetTrackedIDs then
            local ids = C_ContentTracking.GetTrackedIDs(TRACKING_TYPE_ACHIEVEMENT)
            if ids and type(ids) == "table" then
                for _, id in ipairs(ids) do
                    if type(id) == "number" and id > 0 then idList[#idList + 1] = id end
                end
            end
        elseif GetTrackedAchievements then
            for i = 1, 10 do
                local id = select(i, GetTrackedAchievements())
                if type(id) == "number" and id > 0 then idList[#idList + 1] = id end
            end
        end
        HSPrint("Tracked achievement IDs: " .. (#idList > 0 and table.concat(idList, ", ") or "none"))
        for _, achID in ipairs(idList) do
            HSPrint("|cFFFFCC00Achievement " .. tostring(achID) .. ":|r")
            if GetAchievementInfo then
                local aOk, id, name, points, completed, month, day, year, description, flags, icon = pcall(GetAchievementInfo, achID)
                if aOk then
                    HSPrint("  name=" .. tostring(name) .. "  completed=" .. tostring(completed) .. "  points=" .. tostring(points))
                    HSPrint("  description=" .. tostring(description))
                else
                    HSPrint("  GetAchievementInfo FAILED: " .. tostring(id))
                end
            end
            local numCriteria = 0
            if GetAchievementNumCriteria then
                local nOk, n = pcall(GetAchievementNumCriteria, achID)
                if nOk and type(n) == "number" then numCriteria = n end
                HSPrint("  numCriteria=" .. tostring(nOk and n or "error"))
            end
            if GetAchievementCriteriaInfo and numCriteria > 0 then
                for ci = 1, math.min(numCriteria, 15) do
                    local cOk, criteriaString, criteriaType, completedCrit, quantity, reqQuantity, charName, cflags, assetID, quantityString, criteriaID =
                        pcall(GetAchievementCriteriaInfo, achID, ci)
                    if cOk then
                        HSPrint(("  [%d] str=%q type=%s done=%s qty=%s/%s qtyStr=%q criteriaID=%s"):format(
                            ci, tostring(criteriaString or ""), tostring(criteriaType), tostring(completedCrit),
                            tostring(quantity), tostring(reqQuantity), tostring(quantityString or ""), tostring(criteriaID or "?")))
                    else
                        HSPrint(("  [%d] GetAchievementCriteriaInfo FAILED: %s"):format(ci, tostring(criteriaString)))
                    end
                end
                if numCriteria > 15 then
                    HSPrint("  ... (" .. tostring(numCriteria - 15) .. " more criteria)")
                end
            elseif numCriteria == 0 then
                HSPrint("  (no criteria)")
            end
        end
        HSPrint("|cFF00CCFF--- End Achievement Debug ---|r")

    elseif cmd == "endeavordebug" then
        HSPrint("|cFF00CCFF--- Endeavor API debug ---|r")
        HSPrint("C_ContentTracking: " .. (C_ContentTracking and "yes" or "no"))
        if Enum and Enum.ContentTrackingType then
            local t = {}
            for k, v in pairs(Enum.ContentTrackingType) do
                if type(v) == "number" then t[#t + 1] = k .. "=" .. tostring(v) end
            end
            HSPrint("ContentTrackingType: " .. table.concat(t, ", "))
        end
        for _, typ in ipairs({ 0, 1, 2, 3, 4, 5 }) do
            if C_ContentTracking and C_ContentTracking.GetTrackedIDs then
                local ok, ids = pcall(C_ContentTracking.GetTrackedIDs, typ)
                if ok and ids and type(ids) == "table" and #ids > 0 then
                    HSPrint("  GetTrackedIDs(" .. typ .. "): " .. #ids .. " ids: " .. table.concat(ids, ", "))
                end
            end
        end
        HSPrint("C_Endeavors: " .. (C_Endeavors and "yes" or "no"))
        if C_Endeavors then
            for _, fn in ipairs({ "GetTrackedIDs", "GetEndeavorInfo", "GetInfo", "GetActiveEndeavorID" }) do
                if C_Endeavors[fn] then HSPrint("  C_Endeavors." .. fn .. ": yes") end
            end
        end
        HSPrint("C_PlayerHousing: " .. (C_PlayerHousing and "yes" or "no"))
        if C_PlayerHousing then
            for _, fn in ipairs({ "GetActiveEndeavorID", "GetActiveEndeavorInfo", "GetEndeavorInfo" }) do
                if C_PlayerHousing[fn] then HSPrint("  C_PlayerHousing." .. fn .. ": yes") end
            end
        end
        HSPrint("C_NeighborhoodInitiative: " .. (C_NeighborhoodInitiative and "yes" or "no"))
        if C_NeighborhoodInitiative then
            for _, fn in ipairs({ "GetTrackedInitiativeTasks", "GetInitiativeTaskInfo", "RemoveTrackedInitiativeTask", "GetInitiativeTaskChatLink" }) do
                if C_NeighborhoodInitiative[fn] then HSPrint("  C_NeighborhoodInitiative." .. fn .. ": yes") end
            end
        end
        HSPrint("HousingFramesUtil: " .. (HousingFramesUtil and "yes" or "no"))
        if HousingFramesUtil and HousingFramesUtil.OpenFrameToTaskID then
            HSPrint("  HousingFramesUtil.OpenFrameToTaskID: yes")
        end
        HSPrint("ReadTrackedEndeavors count: " .. (addon.ReadTrackedEndeavors and #addon.ReadTrackedEndeavors() or 0))
        HSPrint("ReadTrackedDecor count: " .. (addon.ReadTrackedDecor and #addon.ReadTrackedDecor() or 0))
        if C_NeighborhoodInitiative and C_NeighborhoodInitiative.GetTrackedInitiativeTasks and C_NeighborhoodInitiative.GetInitiativeTaskInfo then
            local ok, result = pcall(C_NeighborhoodInitiative.GetTrackedInitiativeTasks)
            local ids = {}
            if ok and result then
                if result.trackedIDs and type(result.trackedIDs) == "table" then
                    ids = result.trackedIDs
                elseif type(result) == "table" and #result > 0 then
                    ids = result
                end
            end
            if #ids == 0 and addon.GetTrackedEndeavorIDs then
                ids = addon.GetTrackedEndeavorIDs() or {}
            end
            HSPrint("|cFF00CCFF--- GetInitiativeTaskInfo dump (" .. #ids .. " tracked) ---|r")
            for _, taskID in ipairs(ids) do
                local getOk, info = pcall(C_NeighborhoodInitiative.GetInitiativeTaskInfo, taskID)
                if getOk and info and type(info) == "table" then
                    HSPrint("  Endeavor " .. tostring(taskID) .. " (" .. tostring(info.taskName or "?") .. "):")
                    local keys = {}
                    for k in pairs(info) do keys[#keys + 1] = k end
                    table.sort(keys)
                    for _, k in ipairs(keys) do
                        local v = info[k]
                        if type(v) == "table" then
                            HSPrint("    " .. tostring(k) .. " = (table, #=" .. tostring(#v) .. ")")
                        else
                            HSPrint("    " .. tostring(k) .. " = " .. tostring(v))
                        end
                    end
                else
                    HSPrint("  Endeavor " .. tostring(taskID) .. ": GetInitiativeTaskInfo returned " .. (getOk and "nil" or ("error: " .. tostring(info))))
                end
            end
        end

    elseif cmd == "unaccepted" then
        if addon.ShowUnacceptedPopup then
            addon.ShowUnacceptedPopup()
            HSPrint("Opened unaccepted quests popup.")
        else
            HSPrint("ShowUnacceptedPopup not available.")
        end

    elseif cmd == "profiledebug" then
        HSPrint("|cFF00CCFF--- Profile Routing Debug ---|r")
        local charName = _G.UnitName and _G.UnitName("player") or "?"
        local realm = _G.GetNormalizedRealmName and _G.GetNormalizedRealmName() or "?"
        local charFullKey = tostring(charName) .. "-" .. tostring(realm)
        HSPrint("Character: " .. charFullKey)
        local numSpecs = _G.GetNumSpecializations and _G.GetNumSpecializations() or "?"
        local curSpec = _G.GetSpecialization and _G.GetSpecialization() or "?"
        HSPrint("Specs: " .. tostring(numSpecs) .. " | Current spec index: " .. tostring(curSpec))
        if _G[addon.DB_NAME] then
            local db = _G[addon.DB_NAME]
            HSPrint("useGlobalProfile: " .. tostring(db.useGlobalProfile))
            HSPrint("globalProfileKey: " .. tostring(db.globalProfileKey))
            HSPrint("usePerSpecProfiles: " .. tostring(db.usePerSpecProfiles))
            local charSpecs = db.charPerSpecKeys and db.charPerSpecKeys[charFullKey:gsub("%s+", "")]
            if charSpecs then
                for i = 1, 4 do
                    if charSpecs[i] then
                        local specName = _G.GetSpecializationInfo and select(2, _G.GetSpecializationInfo(i)) or ("Spec " .. i)
                        HSPrint("  charPerSpec[" .. i .. "] (" .. tostring(specName) .. "): " .. tostring(charSpecs[i]))
                    end
                end
            else
                HSPrint("  charPerSpecKeys: (none for this character)")
            end
            HSPrint("charProfileKeys:")
            if db.charProfileKeys then
                for ck, pk in pairs(db.charProfileKeys) do
                    HSPrint("  " .. tostring(ck) .. " -> " .. tostring(pk))
                end
            end
            HSPrint("Existing profiles:")
            if db.profiles then
                for k in pairs(db.profiles) do
                    HSPrint("  " .. tostring(k))
                end
            end
        end
        local effectiveKey = addon.GetEffectiveProfileKey and addon.GetEffectiveProfileKey() or "?"
        local activeKey = addon.GetActiveProfileKey and addon.GetActiveProfileKey() or "?"
        HSPrint("GetEffectiveProfileKey(): " .. tostring(effectiveKey))
        HSPrint("GetActiveProfileKey(): " .. tostring(activeKey))
        if addon.GetActiveProfile then
            local _, profileKey = addon.GetActiveProfile()
            HSPrint("GetActiveProfile() key: " .. tostring(profileKey))
        end

    elseif cmd == "clicktodebug" then
        HSPrint("|cFF00CCFF--- Click-to-complete debug ---|r")
        if not C_QuestLog then
            HSPrint("C_QuestLog: not available")
        else
            HSPrint("ShowQuestComplete: " .. (ShowQuestComplete and "yes" or "no"))
            HSPrint("requireModifierForClickToComplete: " .. tostring(addon.GetDB("requireModifierForClickToComplete", false)))
            local n = C_QuestLog.GetNumQuestWatches and C_QuestLog.GetNumQuestWatches() or 0
            HSPrint("Tracked quests: " .. tostring(n))
            local eligible = 0
            for i = 1, n do
                local qid = C_QuestLog.GetQuestIDForQuestWatchIndex and C_QuestLog.GetQuestIDForQuestWatchIndex(i)
                if qid and qid > 0 then
                    local title = C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(qid) or ("Quest " .. tostring(qid))
                    local logIdx = C_QuestLog.GetLogIndexForQuestID and C_QuestLog.GetLogIndexForQuestID(qid)
                    local isComplete = C_QuestLog.IsComplete and C_QuestLog.IsComplete(qid)
                    local isAuto = false
                    if logIdx and C_QuestLog.GetInfo then
                        local ok, info = pcall(C_QuestLog.GetInfo, logIdx)
                        if ok and info then isAuto = info.isAutoComplete and true or false end
                    end
                    local status = (isAuto and isComplete) and "|cFF00FF00eligible|r" or "not eligible"
                    if isAuto and isComplete then eligible = eligible + 1 end
                    HSPrint("  [" .. tostring(qid) .. "] " .. tostring(title):sub(1, 40) .. " | complete=" .. tostring(isComplete) .. " | autoComplete=" .. tostring(isAuto) .. " | " .. status)
                end
            end
            HSPrint("Eligible for click-to-complete: " .. tostring(eligible))
        end

    elseif cmd == "delvedebug" then
        HSPrint("|cFF00CCFF--- Delve / Tier debug (run inside a Delve) ---|r")
        if C_PartyInfo and C_PartyInfo.IsDelveInProgress then
            local ok, v = pcall(C_PartyInfo.IsDelveInProgress)
            HSPrint("IsDelveInProgress: " .. tostring(ok and v or (ok and "false") or ("error: " .. tostring(v))))
        else
            HSPrint("IsDelveInProgress: not available")
        end
        if GetCVarTableValue and C_DelvesUI and C_DelvesUI.GetTieredEntrancePDEID then
            local ok, pdeID = pcall(C_DelvesUI.GetTieredEntrancePDEID)
            if ok and pdeID then
                local vOk, tier = pcall(GetCVarTableValue, "lastSelectedTieredEntranceTier", pdeID, 0)
                HSPrint("GetCVarTableValue(lastSelectedTieredEntranceTier, pdeID=" .. tostring(pdeID) .. "): " .. (vOk and tostring(tier) or ("error: " .. tostring(tier))))
            end
        end
        if GetCVarNumberOrDefault then
            local ok, cvarTier = pcall(GetCVarNumberOrDefault, "lastSelectedDelvesTier", 1)
            HSPrint("GetCVarNumberOrDefault(lastSelectedDelvesTier, 1): " .. (ok and tostring(cvarTier) or ("error: " .. tostring(cvarTier))))
        end
        if GetInstanceInfo then
            local ok, name, instType, diffID, diffName = pcall(GetInstanceInfo)
            if ok then
                HSPrint("GetInstanceInfo: name=" .. tostring(name) .. " type=" .. tostring(instType) .. " diffID=" .. tostring(diffID) .. " diffName=" .. tostring(diffName))
            end
        end
        if addon.GetDelvesAffixes then
            local affixes = addon.GetDelvesAffixes()
            if affixes and #affixes > 0 then
                local names = {}
                for _, a in ipairs(affixes) do names[#names + 1] = a.name or "(nil)" end
                HSPrint("GetDelvesAffixes: " .. table.concat(names, ", "))
            else
                HSPrint("GetDelvesAffixes: nil or empty")
                if C_UIWidgetManager and C_UIWidgetManager.GetAllWidgetsBySetID and C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo then
                    local stepSetID, objSetID
                    if C_Scenario and C_Scenario.GetStepInfo then
                        local ok, t = pcall(function() return { C_Scenario.GetStepInfo() } end)
                        if ok and t and type(t) == "table" and #t >= 12 then
                            local ws = t[12]
                            if type(ws) == "number" and ws ~= 0 then stepSetID = ws end
                        end
                    end
                    if C_UIWidgetManager.GetObjectiveTrackerWidgetSetID then
                        local ok, s = pcall(C_UIWidgetManager.GetObjectiveTrackerWidgetSetID)
                        if ok and s and type(s) == "number" then objSetID = s end
                    end
                    HSPrint(("  widgetSetID: GetStepInfo=%s GetObjectiveTracker=%s"):format(
                        stepSetID and tostring(stepSetID) or "nil",
                        objSetID and tostring(objSetID) or "nil"))
                    local setID = stepSetID or objSetID
                    if setID then
                        local wOk, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, setID)
                        if wOk and widgets and type(widgets) == "table" then
                            local n = 0
                            for _ in pairs(widgets) do n = n + 1 end
                            local WIDGET_DELVES = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.ScenarioHeaderDelves) or 29
                            HSPrint("  widgets: " .. tostring(n))
                            for k, v in pairs(widgets) do
                                local testID = (v and type(v) == "table" and v.widgetID) or (type(v) == "number" and v) or nil
                                if testID and type(testID) == "number" then
                                    local wType = (v and type(v) == "table") and v.widgetType
                                    local isDelves = (wType == WIDGET_DELVES) and " [ScenarioHeaderDelves]" or ""
                                    local dOk, wi = pcall(C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo, testID)
                                    local spells = (dOk and wi and wi.spells) and #wi.spells or 0
                                    HSPrint(("  widget k=%s id=%s type=%s%s -> %d spells"):format(
                                        tostring(k), tostring(testID), tostring(wType or "?"), isDelves, spells))
                                end
                            end
                        end
                    end
                end
            end
        end

    else
        ShowFocusDebugHelp()
    end
end

addon.RegisterSlashHandler("focus", HandleFocusSlash)
if addon.RegisterSlashHandlerDebug then
    addon.RegisterSlashHandlerDebug("focus", HandleFocusDebugSlash)
end
