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
    if category == "RECIPE" then return "RECIPES" end
    return category
end

local function CategoryFromEntry(entry)
    local category = entry and entry.category
    if category then return category end
    local groupKey = entry and entry.groupKey
    if groupKey == "RARES" then return "RARE" end
    if groupKey == "RARE_LOOT" then return "RARE_LOOT" end
    if groupKey == "ACHIEVEMENTS" then return "ACHIEVEMENT" end
    if groupKey == "ENDEAVORS" then return "ENDEAVOR" end
    if groupKey == "DECOR" then return "DECOR" end
    if groupKey == "RECIPES" then return "RECIPE" end
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
    HSPrint("  Shift+Left-click opens or closes quest details; Right-click a quest to untrack, recipe to untrack, rare to clear super-track.")
end

local function ShowFocusDebugHelp()
    HSPrint("Focus debug commands (/h debug focus [cmd]):")
    HSPrint("  scendebug - Scenario timer debug (also: /h scenario debug)")
    HSPrint("  devmode - Show Blizzard tracker alongside Focus for comparison")
    HSPrint("  wqdebug, nearbydebug, headercountdebug, groupdebug")
    HSPrint("  delvedebug, mplusaffixdebug, mplusdebug, endeavordebug, achievementdebug")
    HSPrint("  recipedebug, unaccepted, clicktodebug, profiledebug")
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
        HSPrint("Showing test data (all categories and groupings)...")

        local QC = addon.QUEST_COLORS or {}
        local function qc(k) return QC[k] or QC.DEFAULT or { 0.9, 0.9, 0.9 } end

        -- Seed CURRENT: one quest marked as recently progressed so it appears in Current Quest.
        if addon.focus then
            addon.focus.recentlyProgressedQuests = addon.focus.recentlyProgressedQuests or {}
            addon.focus.recentlyProgressedQuests[90001] = GetTime()
        end

        local testQuests = {
            -- CURRENT_EVENT (event quest, accepted, nearby)
            { entryKey = "test:current_event", questID = 90000, title = "[Test] Current Event: Zone Siege",
              color = qc("CURRENT_EVENT"), category = "SCENARIO", isEventQuest = true,
              questTypeAtlas = "quest-recurring-available",
              isComplete = false, isSuperTracked = true, isNearby = true, isAccepted = true,
              zoneName = "Valdrakken",
              objectives = { { text = "Defend the gate: 2/3", finished = false } }},
            -- CURRENT (recently progressed; seeded above)
            { entryKey = "test:current", questID = 90001, title = "[Test] Current Quest: The Fate of the Horde",
              color = qc("CURRENT"), category = "CAMPAIGN",
              questTypeAtlas = "Quest-Campaign-Available",
              isComplete = false, isSuperTracked = true, isNearby = true, isAccepted = true,
              zoneName = "Valdrakken",
              itemLink = "item:12345:0:0:0:0:0:0:0", itemTexture = "Interface\\Icons\\INV_Misc_Rune_01",
              objectives = { { text = "Speak with Thrall", finished = true }, { text = "Harbingers: 2/5", finished = false } }},
            -- DELVES
            { entryKey = "test:delves", questID = 90002, title = "[Test] Delves: Cinderbrew Mine",
              color = qc("DELVES"), category = "DELVES",
              questTypeAtlas = addon.DELVE_TIER_ATLAS or "delves-scenario-flag",
              isComplete = false, isNearby = false, isAccepted = true, zoneName = "Isle of Dorn",
              objectives = { { text = "Reach the vault", finished = false } }},
            -- SCENARIO
            { entryKey = "test:scenario", questID = 90003, title = "[Test] Scenario: Twilight's Call",
              color = qc("SCENARIO"), category = "SCENARIO",
              isComplete = false, isNearby = false, isAccepted = true, zoneName = "The Waking Shores",
              objectives = { { text = "Step 1/3", finished = false } }},
            -- ACHIEVEMENTS
            { entryKey = "test:ach", achievementID = 90001, questID = nil, title = "[Test] Achievement: Loremaster",
              color = qc("ACHIEVEMENT"), category = "ACHIEVEMENT", isAchievement = true,
              achievementIcon = "Interface\\Icons\\Achievement_General",
              isComplete = false, objectives = { { text = "Complete 50 quests: 37/50", finished = false, numFulfilled = 37, numRequired = 50 } }},
            -- ENDEAVORS
            { entryKey = "test:endeavor", endeavorID = 90001, questID = nil, title = "[Test] Endeavor: Gather 10 Herbs",
              color = qc("ENDEAVOR"), category = "ENDEAVOR", isEndeavor = true,
              isComplete = false, objectives = { { text = "Herbs: 6/10", finished = false } }},
            -- DECOR
            { entryKey = "test:decor", decorID = 90001, questID = nil, title = "[Test] Decor: Ancient Statue",
              color = qc("DECOR"), category = "DECOR", isDecor = true,
              decorIcon = "Interface\\Icons\\INV_Misc_Statue_01",
              isComplete = false, objectives = { { text = "Collect from raid", finished = false } }},
            -- RECIPES
            { entryKey = "test:recipe", recipeID = 90001, questID = nil, title = "[Test] Recipe: Flasks of the Currents",
              color = qc("RECIPE"), category = "RECIPE", isRecipe = true,
              recipeIcon = "Interface\\Icons\\INV_Potion_01",
              isComplete = false, objectives = { { text = "Craft 5", finished = false } }},
            -- ADVENTURE
            { entryKey = "test:adventure", questID = 90004, title = "[Test] Adventure Guide: Chromie Time",
              color = qc("ADVENTURE"), category = "ADVENTURE", isAdventureGuide = true,
              questTypeAtlas = "QuestNormal",
              isComplete = false, isNearby = false, isAccepted = true, zoneName = "Stormwind",
              objectives = { { text = "Select expansion", finished = false } }},
            -- DUNGEON
            { entryKey = "test:dungeon", questID = 90005, title = "[Test] Dungeon: Brackenhide Hollow",
              color = qc("DUNGEON"), category = "DUNGEON", isDungeonQuest = true,
              questTypeAtlas = "questlog-questtypeicon-dungeon",
              isComplete = false, isNearby = false, isAccepted = true, zoneName = "Ohn'ahran Plains",
              objectives = { { text = "Defeat Treemouth", finished = false } }},
            -- RAID
            { entryKey = "test:raid", questID = 90006, title = "[Test] Raid: Amirdrassil",
              color = qc("RAID"), category = "RAID", isRaidQuest = true,
              questTypeAtlas = "questlog-questtypeicon-raid",
              isComplete = false, isNearby = false, isAccepted = true, zoneName = "Emerald Dream",
              objectives = { { text = "Defeat Fyrakk", finished = false } }},
            -- NEARBY (accepted, in zone)
            { entryKey = "test:nearby", questID = 90007, title = "[Test] Nearby: Aiding the Accord",
              color = qc("NEARBY"), category = "DEFAULT",
              isComplete = false, isNearby = true, isAccepted = true, zoneName = "Valdrakken",
              objectives = { { text = "Dragon Glyphs: 3/5", finished = false } }},
            -- COMPLETE
            { entryKey = "test:complete", questID = 90008, title = "[Test] Ready: Boar Pelts",
              color = qc("COMPLETE"), category = "COMPLETE", baseCategory = "DEFAULT",
              questTypeAtlas = "QuestTurnin",
              isComplete = true, isAutoComplete = true, isNearby = false, isAccepted = true,
              zoneName = "Elwynn Forest",
              objectives = { { text = "Boar Pelts: 10/10", finished = true } }},
            -- WORLD
            { entryKey = "test:world", questID = 90009, title = "[Test] World Quest: Doomwalker",
              color = qc("WORLD"), category = "WORLD",
              questTypeAtlas = "quest-recurring-available",
              isComplete = false, isNearby = false, isAccepted = true, zoneName = "Thaldraszus",
              objectives = { { text = "Slay Doomwalker", finished = false } }},
            -- WEEKLY
            { entryKey = "test:weekly", questID = 90010, title = "[Test] Weekly: Dragonflight Dungeons",
              color = qc("WEEKLY"), category = "WEEKLY",
              questTypeAtlas = "quest-recurring-available",
              isComplete = false, isNearby = false, isAccepted = true, zoneName = "Valdrakken",
              objectives = { { text = "Complete 4 dungeons: 2/4", finished = false } }},
            -- DAILY
            { entryKey = "test:daily", questID = 90011, title = "[Test] Daily: Fishing Contest",
              color = qc("DAILY"), category = "DAILY",
              questTypeAtlas = "quest-recurring-available",
              isComplete = false, isNearby = false, isAccepted = true, zoneName = "Stranglethorn",
              objectives = { { text = "Catch 10 fish", finished = false } }},
            -- PREY weekly (accepted quest; appears first)
            { entryKey = "test:prey", questID = 90012, title = "[Test] Prey: Hunt the Shadowstalker",
              color = (QC.PREY or QC.WEEKLY), category = "PREY", isPreyWorldQuest = false,
              questTypeAtlas = "quest-recurring-available",
              isComplete = false, isNearby = false, isAccepted = true, zoneName = "Quel'Thalas",
              objectives = { { text = "Track and defeat target", finished = false } }},
            -- PREY activity (world quest; appears second, shows "Activity" as zone)
            { entryKey = "test:prey_wq", questID = 90018, title = "[Test] Prey: Ambush at the Crossroads",
              color = (QC.PREY or QC.WEEKLY), category = "PREY", isPreyWorldQuest = true,
              questTypeAtlas = "quest-recurring-available",
              isComplete = false, isNearby = true, isAccepted = true, zoneName = "Activity",
              objectives = { { text = "Complete hunt objectives", finished = false } }},
            -- RARES
            { entryKey = "test:rare", questID = nil, title = "[Test] Rare: Gorged Buzzard",
              color = qc("RARE"), category = "RARE", isRare = true,
              isComplete = false, isNearby = true, zoneName = "Ohn'ahran Plains",
              objectives = {} },
            -- AVAILABLE (Events in Zone: in zone, not accepted)
            { entryKey = "test:available", questID = 90013, title = "[Test] Available: The Lost Artifact",
              color = qc("AVAILABLE"), category = "DEFAULT", isEventQuest = true,
              isComplete = false, isNearby = true, isAccepted = false, zoneName = "Valdrakken",
              objectives = { { text = "Find the artifact", finished = false } }},
            -- CAMPAIGN
            { entryKey = "test:campaign", questID = 90014, title = "[Test] Campaign: Threads of Fate",
              color = qc("CAMPAIGN"), category = "CAMPAIGN",
              questTypeAtlas = "Quest-Campaign-Available",
              isComplete = false, isNearby = false, isAccepted = true, zoneName = "The Waking Shores",
              objectives = { { text = "Explore the Loom: 1/3", finished = false } }},
            -- IMPORTANT
            { entryKey = "test:important", questID = 90015, title = "[Test] Important: The Legendary Cloak",
              color = qc("IMPORTANT"), category = "IMPORTANT",
              questTypeAtlas = "importantavailablequesticon",
              isComplete = false, isNearby = false, isAccepted = true, zoneName = "Ohn'ahran Plains",
              objectives = { { text = "Collect 50 Echoes: 37/50", finished = false } }},
            -- LEGENDARY
            { entryKey = "test:legendary", questID = 90016, title = "[Test] Legendary: Ashjra'kamas",
              color = qc("LEGENDARY"), category = "LEGENDARY",
              questTypeAtlas = "UI-QuestPoiLegendary-QuestBang",
              isComplete = false, isNearby = false, isAccepted = true, zoneName = "Vale of Eternal Blossoms",
              objectives = { { text = "Gather 50 coalescing visions", finished = false } }},
            -- DEFAULT
            { entryKey = "test:default", questID = 90017, title = "[Test] Default: Supply Run",
              color = qc("DEFAULT"), category = "DEFAULT",
              isComplete = false, isNearby = false, isAccepted = true, zoneName = "Stormwind City",
              objectives = { { text = "Deliver supplies: 0/1", finished = false } }},
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
        if addon.focus and addon.focus.recentlyProgressedQuests then
            addon.focus.recentlyProgressedQuests[90001] = nil
        end
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
        -- One-shot timer dump for immediate feedback (run in scenario to diagnose missing timers)
        if addon.DumpScenarioTimerInfo then addon.DumpScenarioTimerInfo() end

    elseif cmd == "devmode" then
        local v = not (addon.GetDB and addon.GetDB("focusDevMode", false))
        if addon.SetDB then
            addon.SetDB("focusDevMode", v)
        end
        HSPrint("Dev mode (Blizzard tracker): " .. (v and "on" or "off"))
        if addon.focus and addon.focus.enabled then
            if v then
                if addon.RestoreTracker then addon.RestoreTracker() end
            else
                if addon.TrySuppressTracker then addon.TrySuppressTracker() end
            end
        end

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

    elseif cmd == "recipedebug" or cmd:match("^recipedebug%s") then
        local arg = cmd:match("^recipedebug%s+(%d+)")
        local rid = arg and tonumber(arg)
        if addon.DebugRecipeReagents then
            addon.DebugRecipeReagents(rid)
        else
            HSPrint("DebugRecipeReagents not available.")
        end

    elseif cmd == "delvedebug" then
        HSPrint("|cFF00CCFF--- Delve / Tier debug (run inside a Delve) ---|r")
        if C_PartyInfo and C_PartyInfo.IsDelveInProgress then
            local ok, v = pcall(C_PartyInfo.IsDelveInProgress)
            HSPrint("IsDelveInProgress: " .. tostring(ok and v or (ok and "false") or ("error: " .. tostring(v))))
        else
            HSPrint("IsDelveInProgress: not available")
        end
        if C_GossipInfo and C_GossipInfo.GetActiveDelveGossip then
            local ok, g = pcall(C_GossipInfo.GetActiveDelveGossip)
            HSPrint("GetActiveDelveGossip: " .. (ok and g and type(g.orderIndex) == "number" and ("tier=" .. tostring(g.orderIndex + 1)) or "nil/error"))
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

        -- Scenario objective progress debug (inspect both likely widget sets and multiple widget types).
        HSPrint("|cFF00CCFF--- Scenario objective progress (widgets + criteria) ---|r")
        local function ShortText(value, maxLen)
            local s = tostring(value or "")
            local limit = maxLen or 80
            s = s:gsub("\n", " "):gsub("\r", " ")
            if #s > limit then
                return s:sub(1, limit - 3) .. "..."
            end
            return s
        end
        local function GetWidgetTypeName(widgetType)
            if Enum and Enum.UIWidgetVisualizationType then
                for k, v in pairs(Enum.UIWidgetVisualizationType) do
                    if v == widgetType then return k end
                end
            end
            return "type=" .. tostring(widgetType)
        end
        local function PrintPercentPair(prefix, minValue, maxValue, value)
            if type(maxValue) ~= "number" or type(value) ~= "number" then return end
            local minNum = type(minValue) == "number" and minValue or 0
            local range = maxValue - minNum
            local pctRaw = (maxValue > 0) and math.floor(100 * value / maxValue) or 0
            local pctMin = (range > 0) and math.floor(100 * (value - minNum) / range) or 0
            HSPrint(("%s raw=%s%% withMin=%s%%"):format(prefix, tostring(pctRaw), tostring(pctMin)))
        end
        local function DumpWidgetSet(label, setID)
            if not setID or setID == 0 then
                HSPrint(("  %s: no widget set"):format(label))
                return
            end
            if not (C_UIWidgetManager and C_UIWidgetManager.GetAllWidgetsBySetID) then
                HSPrint(("  %s: widget manager unavailable"):format(label))
                return
            end
            local wOk, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, setID)
            if not wOk or type(widgets) ~= "table" then
                HSPrint(("  %s: failed to read widget set %s"):format(label, tostring(setID)))
                return
            end
            local count = 0
            for _ in pairs(widgets) do count = count + 1 end
            HSPrint(("  %s widgetSetID=%s widgets=%d"):format(label, tostring(setID), count))
            for _, wInfo in pairs(widgets) do
                local widgetID = type(wInfo) == "table" and wInfo.widgetID or (type(wInfo) == "number" and wInfo)
                local widgetType = type(wInfo) == "table" and wInfo.widgetType or nil
                if widgetID then
                    local widgetTypeName = GetWidgetTypeName(widgetType)
                    HSPrint(("    widget id=%s type=%s"):format(tostring(widgetID), widgetTypeName))

                    if C_UIWidgetManager.GetDiscreteProgressStepsVisualizationInfo then
                        local ok, info = pcall(C_UIWidgetManager.GetDiscreteProgressStepsVisualizationInfo, widgetID)
                        if ok and info and type(info) == "table" and type(info.progressMax) == "number" then
                            HSPrint(("      DiscreteProgress: min=%s max=%s val=%s steps=%s tooltip=%q"):format(
                                tostring(info.progressMin), tostring(info.progressMax), tostring(info.progressVal),
                                tostring(info.numSteps), ShortText(info.tooltip, 70)))
                            PrintPercentPair("      Discrete percent:", info.progressMin, info.progressMax, info.progressVal)
                        end
                    end

                    if C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo then
                        local ok, info = pcall(C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo, widgetID)
                        if ok and info and type(info) == "table" and type(info.fillMax) == "number" then
                            HSPrint(("      FillUpFrames: min=%s max=%s val=%s totalFrames=%s fullFrames=%s tooltip=%q"):format(
                                tostring(info.fillMin), tostring(info.fillMax), tostring(info.fillValue),
                                tostring(info.numTotalFrames), tostring(info.numFullFrames), ShortText(info.tooltip, 70)))
                            PrintPercentPair("      FillUp percent:", info.fillMin, info.fillMax, info.fillValue)
                        end
                    end

                    if C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo then
                        local ok, info = pcall(C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo, widgetID)
                        if ok and info and type(info) == "table" and type(info.barMax) == "number" then
                            HSPrint(("      StatusBar: min=%s max=%s val=%s text=%q override=%q valueTextType=%s"):format(
                                tostring(info.barMin), tostring(info.barMax), tostring(info.barValue),
                                ShortText(info.text, 60), ShortText(info.overrideBarText, 40), tostring(info.barValueTextType)))
                            PrintPercentPair("      StatusBar percent:", info.barMin, info.barMax, info.barValue)
                        end
                    end

                    if C_UIWidgetManager.GetDoubleStatusBarWidgetVisualizationInfo then
                        local ok, info = pcall(C_UIWidgetManager.GetDoubleStatusBarWidgetVisualizationInfo, widgetID)
                        if ok and info and type(info) == "table" and type(info.leftBarMax) == "number" then
                            HSPrint(("      DoubleStatus: text=%q left=%s/%s right=%s/%s"):format(
                                ShortText(info.text, 60), tostring(info.leftBarValue), tostring(info.leftBarMax),
                                tostring(info.rightBarValue), tostring(info.rightBarMax)))
                            PrintPercentPair("      Double left percent:", info.leftBarMin, info.leftBarMax, info.leftBarValue)
                            PrintPercentPair("      Double right percent:", info.rightBarMin, info.rightBarMax, info.rightBarValue)
                        end
                    end

                    if C_UIWidgetManager.GetUnitPowerBarWidgetVisualizationInfo then
                        local ok, info = pcall(C_UIWidgetManager.GetUnitPowerBarWidgetVisualizationInfo, widgetID)
                        if ok and info and type(info) == "table" and type(info.barMax) == "number" then
                            HSPrint(("      UnitPowerBar: min=%s max=%s val=%s override=%q valueTextType=%s"):format(
                                tostring(info.barMin), tostring(info.barMax), tostring(info.barValue),
                                ShortText(info.overrideBarText, 40), tostring(info.barValueTextType)))
                            PrintPercentPair("      UnitPower percent:", info.barMin, info.barMax, info.barValue)
                        end
                    end

                    if C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo then
                        local ok, info = pcall(C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo, widgetID)
                        if ok and info and type(info) == "table" and info.text and info.text ~= "" then
                            HSPrint(("      IconAndText: text=%q tooltip=%q dynamicTooltip=%q"):format(
                                ShortText(info.text, 60), ShortText(info.tooltip, 60), ShortText(info.dynamicTooltip, 60)))
                        end
                    end

                    if C_UIWidgetManager.GetDoubleIconAndTextWidgetVisualizationInfo then
                        local ok, info = pcall(C_UIWidgetManager.GetDoubleIconAndTextWidgetVisualizationInfo, widgetID)
                        if ok and info and type(info) == "table" and ((info.label and info.label ~= "") or (info.leftText and info.leftText ~= "") or (info.rightText and info.rightText ~= "")) then
                            HSPrint(("      DoubleIconAndText: label=%q left=%q right=%q"):format(
                                ShortText(info.label, 40), ShortText(info.leftText, 40), ShortText(info.rightText, 40)))
                        end
                    end

                    if C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo then
                        local ok, info = pcall(C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo, widgetID)
                        if ok and info and type(info) == "table" and info.text and info.text ~= "" then
                            HSPrint(("      TextWithState: text=%q tooltip=%q"):format(
                                ShortText(info.text, 70), ShortText(info.tooltip, 60)))
                        end
                    end

                    if C_UIWidgetManager.GetTextWithSubtextWidgetVisualizationInfo then
                        local ok, info = pcall(C_UIWidgetManager.GetTextWithSubtextWidgetVisualizationInfo, widgetID)
                        if ok and info and type(info) == "table" and ((info.text and info.text ~= "") or (info.subText and info.subText ~= "")) then
                            HSPrint(("      TextWithSubtext: text=%q subText=%q"):format(
                                ShortText(info.text, 60), ShortText(info.subText, 60)))
                        end
                    end

                    if C_UIWidgetManager.GetTextColumnRowVisualizationInfo then
                        local ok, info = pcall(C_UIWidgetManager.GetTextColumnRowVisualizationInfo, widgetID)
                        if ok and info and type(info) == "table" and type(info.entries) == "table" and #info.entries > 0 then
                            local parts = {}
                            for i = 1, math.min(#info.entries, 3) do
                                parts[#parts + 1] = ShortText(info.entries[i].text, 28)
                            end
                            HSPrint(("      TextColumnRow: %s"):format(table.concat(parts, " | ")))
                        end
                    end

                    if C_UIWidgetManager.GetTextureAndTextVisualizationInfo then
                        local ok, info = pcall(C_UIWidgetManager.GetTextureAndTextVisualizationInfo, widgetID)
                        if ok and info and type(info) == "table" and info.text and info.text ~= "" then
                            HSPrint(("      TextureAndText: text=%q tooltip=%q"):format(
                                ShortText(info.text, 70), ShortText(info.tooltip, 60)))
                        end
                    end

                    if C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo then
                        local ok, info = pcall(C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo, widgetID)
                        if ok and info and type(info) == "table" and ((info.headerText and info.headerText ~= "") or (info.tierText and info.tierText ~= "")) then
                            HSPrint(("      ScenarioHeaderDelves: header=%q tier=%q tooltip=%q spells=%s"):format(
                                ShortText(info.headerText, 50), ShortText(info.tierText, 20), ShortText(info.tooltip, 60),
                                tostring(info.spells and #info.spells or 0)))
                        end
                    end
                end
            end
        end
        local stepSetID, objSetID
        if C_Scenario and C_Scenario.GetStepInfo then
            local ok, t = pcall(function() return { C_Scenario.GetStepInfo() } end)
            if ok and t and type(t) == "table" and #t >= 12 then
                local ws = t[12]
                if type(ws) == "number" and ws ~= 0 then stepSetID = ws end
            end
        end
        if C_UIWidgetManager and C_UIWidgetManager.GetObjectiveTrackerWidgetSetID then
            local ok, s = pcall(C_UIWidgetManager.GetObjectiveTrackerWidgetSetID)
            if ok and s and type(s) == "number" then objSetID = s end
        end
        DumpWidgetSet("StepInfo", stepSetID)
        if objSetID ~= stepSetID then
            DumpWidgetSet("ObjectiveTracker", objSetID)
        end
        -- Criteria dump
        if C_ScenarioInfo and (C_ScenarioInfo.GetCriteriaInfo or C_ScenarioInfo.GetCriteriaInfoByStep) then
            local numCrit = 0
            local ok, _, _, n = pcall(C_Scenario.GetStepInfo)
            if ok and n and type(n) == "number" then numCrit = n + 3 end
            if numCrit > 0 then
                for i = 1, math.min(numCrit, 20) do
                    local cOk, crit = pcall(C_ScenarioInfo.GetCriteriaInfo, i)
                    if not cOk or not crit then cOk, crit = pcall(C_ScenarioInfo.GetCriteriaInfoByStep, 1, i) end
                    if cOk and crit and (crit.description and crit.description ~= "" or crit.quantityString and crit.quantityString ~= "" or (crit.quantity and crit.totalQuantity)) then
                        local q = crit.quantity
                        local tq = crit.totalQuantity
                        local qs = crit.quantityString or ""
                        local pct = (tq and tq > 0 and q) and math.floor(100 * q / tq) or "n/a"
                        local desc = (crit.description or crit.criteriaString or "") ~= "" and (crit.description or crit.criteriaString) or "(no desc)"
                        HSPrint(("  Criteria #%d: desc=%q quantity=%s totalQuantity=%s quantityString=%q percent=%s isWeighted=%s"):format(
                            i, tostring(desc):sub(1, 50), tostring(q), tostring(tq), tostring(qs):sub(1, 30), tostring(pct), tostring(crit.isWeightedProgress or false)))
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
