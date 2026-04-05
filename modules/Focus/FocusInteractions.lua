--[[
    Horizon Suite - Focus - Interactions
    Mouse scripts on pool entries (click, tooltip, scroll).
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then _G.HorizonSuite = {} end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- INTERACTIONS
-- ============================================================================

local pool = addon.pool
local CLASSIC_ICON_CLICK_DEBOUNCE = 0.05

--- Append a WoWhead link line to GameTooltip when option is on and entry has a known URL.
--- @param entry table Pool entry (self) with questID, achievementID, and/or creatureID
local function AppendWoWheadLineToTooltip(entry)
    if not addon.GetDB("focusShowWoWheadLink", true) then return end
    local url = addon.GetWoWheadURL(entry)
    if not url then return end
    local text = (addon.L and addon.L["OPTIONS_FOCUS_VIEW_WOWHEAD"]) or "View on WoWhead"
    local hint = (addon.L and addon.L["OPTIONS_FOCUS_WOWHEAD_ALT_CLICK_HINT"]) or "Alt + Click"
    local line = ("|cff00b4ff|Hurl:%s|h[%s]|h|r |cff888888(%s)|r"):format(url, text, hint)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(line, 0.4, 0.7, 1)
end

--- Try to complete an auto-complete quest via ShowQuestComplete (Blizzard behavior).
--- Returns true if completion was triggered; false otherwise.
--- @param questID number
--- @return boolean
local function TryCompleteQuestFromClick(questID)
    if not questID or questID <= 0 then return false end
    -- Test-mode bypass: when /horizon test is active, simulate click-to-complete for fake auto-complete quests.
    if addon.testQuests and questID >= 90001 and questID <= 90010 then
        for _, q in ipairs(addon.testQuests) do
            if q.questID == questID and q.isComplete and q.isAutoComplete then
                local printFn = addon.HSPrint or print
                printFn("|cFF00FF00[DEBUG]|r Click-to-complete hit (test quest " .. tostring(questID) .. ") - would call ShowQuestComplete in live.")
                if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                return true
            end
        end
    end
    if not C_QuestLog or not C_QuestLog.GetLogIndexForQuestID or not C_QuestLog.IsComplete then return false end
    local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
    if not logIndex then return false end
    if not C_QuestLog.IsComplete(questID) then return false end

    -- Check for isAutoComplete flag first (standard auto-complete quests)
    local isAutoComplete = false
    if C_QuestLog.GetInfo then
        local ok, info = pcall(C_QuestLog.GetInfo, logIndex)
        if ok and info and info.isAutoComplete then isAutoComplete = true end
    end

    if isAutoComplete then
        if ShowQuestComplete and type(ShowQuestComplete) == "function" then
            pcall(ShowQuestComplete, questID)
            if addon.ScheduleRefresh then addon.ScheduleRefresh() end
            return true
        end
    end

    -- Fallback for quests that are complete but not flagged isAutoComplete:
    -- Try to open the quest completion dialog via SetSelectedQuest + CompleteQuest.
    if C_QuestLog.SetSelectedQuest then
        C_QuestLog.SetSelectedQuest(questID)
    end
    if ShowQuestComplete and type(ShowQuestComplete) == "function" then
        local ok = pcall(ShowQuestComplete, questID)
        if ok then
            if addon.ScheduleRefresh then addon.ScheduleRefresh() end
            return true
        end
    end

    return false
end

--- Show share/abandon context menu for a quest (classic click mode).
--- Always shows at least one actionable item; mimics Blizzard behaviour.
--- @param questID number
--- @param questName string
--- @param anchor frame|nil Frame to anchor menu to; if nil, uses cursor
local function ShowQuestContextMenu(questID, questName, anchor)
    if not questID then return end
    local L = addon.L or {}
    local menuList = {}
    if C_QuestLog and C_QuestLog.IsPushableQuest and C_QuestLog.IsPushableQuest(questID) then
        local inGroup = (GetNumGroupMembers and GetNumGroupMembers() > 1) or (UnitInParty and UnitInParty("player"))
        if inGroup then
            menuList[#menuList + 1] = {
                text = _G.SHARE_QUEST or L["OPTIONS_FOCUS_SHARE_PARTY"] or "Share with party",
                notCheckable = true,
                func = function()
                    if C_QuestLog and C_QuestLog.SetSelectedQuest then C_QuestLog.SetSelectedQuest(questID) end
                    if QuestLogPushQuest then QuestLogPushQuest() end
                end,
            }
        end
    end
    if C_QuestLog and C_QuestLog.CanAbandonQuest and C_QuestLog.CanAbandonQuest(questID) then
        menuList[#menuList + 1] = {
            text = _G.ABANDON_QUEST or L["OPTIONS_FOCUS_ABANDON_QUEST"] or "Abandon quest",
            notCheckable = true,
            func = function()
                StaticPopup_Show("HORIZONSUITE_ABANDON_QUEST", questName or "this quest", nil, { questID = questID })
            end,
        }
    end
    if addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID) then
        menuList[#menuList + 1] = {
            text = L["OPTIONS_FOCUS_STOP_TRACKING"] or "Stop tracking",
            notCheckable = true,
            func = function()
                if addon.RemoveWorldQuestWatch then addon.RemoveWorldQuestWatch(questID) end
                addon.ScheduleRefresh()
            end,
        }
    else
        menuList[#menuList + 1] = {
            text = L["OPTIONS_FOCUS_STOP_TRACKING"] or "Stop tracking",
            notCheckable = true,
            func = function()
                if C_QuestLog and C_QuestLog.RemoveQuestWatch then C_QuestLog.RemoveQuestWatch(questID) end
                addon.ScheduleRefresh()
            end,
        }
    end
    if #menuList == 0 then return end
    if C_AddOns and C_AddOns.LoadAddOn then
        pcall(C_AddOns.LoadAddOn, "Blizzard_UIDropDownMenu")
    end
    local menuFrame = _G.HorizonSuite_QuestContextMenu
    if not menuFrame then
        menuFrame = CreateFrame("Frame", "HorizonSuite_QuestContextMenu", UIParent, "UIDropDownMenuTemplate")
        if not menuFrame then return end
    end
    local anchorFrame = anchor or UIParent
    if EasyMenu then
        if CloseDropDownMenus then CloseDropDownMenus() end
        C_Timer.After(0, function()
            EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU")
        end)
    elseif UIDropDownMenu_Initialize and ToggleDropDownMenu and UIDropDownMenu_CreateInfo and UIDropDownMenu_AddButton then
        local items = menuList
        UIDropDownMenu_Initialize(menuFrame, function(dropdown, level, list)
            if not level or level ~= 1 then return end
            for _, item in ipairs(items) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = item.text
                info.notCheckable = true
                info.func = item.func
                UIDropDownMenu_AddButton(info, level)
            end
        end, "MENU", 1, nil)
        if CloseDropDownMenus then CloseDropDownMenus() end
        C_Timer.After(0, function()
            ToggleDropDownMenu(1, nil, menuFrame, anchorFrame, 0, 0)
        end)
    end
end

-- ---------------------------------------------------------------------------
-- Tracked appearances: same profile / focusClick_* as quests; row actions use GetAppearanceClickAction (= GetQuestClickAction).
-- ---------------------------------------------------------------------------

local function GetAppearanceDressLink(entry)
    if entry.appearanceItemLink and type(entry.appearanceItemLink) == "string" and entry.appearanceItemLink ~= "" then
        return entry.appearanceItemLink
    end
    if entry.appearanceID and C_TransmogCollection and C_TransmogCollection.GetAppearanceSourceInfo then
        local ok, info = pcall(C_TransmogCollection.GetAppearanceSourceInfo, entry.appearanceID)
        if ok and info and type(info) == "table" and info.itemLink and type(info.itemLink) == "string" and info.itemLink ~= "" then
            return info.itemLink
        end
    end
    return nil
end

local function AppearanceOpenDressingRoom(entry)
    local link = GetAppearanceDressLink(entry)
    if not link then return end
    if DressUpItemLink and type(DressUpItemLink) == "function" then
        pcall(DressUpItemLink, link)
    end
end

local function AppearanceStopTracking(appearanceID)
    if not appearanceID then return end
    if addon.focus and addon.focus.appearanceMapToggleID == appearanceID then
        addon.focus.appearanceMapToggleID = nil
    end
    if addon._appearanceWaypointTargetID == appearanceID and addon.ClearAppearanceWaypoint then
        addon.ClearAppearanceWaypoint()
    end
    local trackType = Enum and Enum.ContentTrackingType and Enum.ContentTrackingType.Appearance
    local stopType = Enum and Enum.ContentTrackingStopType and Enum.ContentTrackingStopType.Manual
    if trackType and stopType and C_ContentTracking and C_ContentTracking.StopTracking then
        pcall(C_ContentTracking.StopTracking, trackType, appearanceID, stopType)
    end
    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
end

-- Open the world map for a tracked appearance: prefer C_ContentTracking map + C_Map.OpenWorldMap so the correct zone is shown.
-- ContentTrackingUtil.OpenMapToTrackable alone can open the wrong map when called the same frame as SetSuperTrackedContent (Blizzard+ title click).
--- @param appearanceID number
--- @param deferOpen boolean|nil When true, run next frame (after super-track state updates).
local function AppearanceOpenMapToTrackable(appearanceID, deferOpen)
    if not appearanceID or appearanceID <= 0 then return end
    local trackType = Enum and Enum.ContentTrackingType and Enum.ContentTrackingType.Appearance
    if not trackType then return end

    local function runOpenMap()
        if InCombatLockdown() then return end
        local opened = false
        local togglableOpen = false
        if C_ContentTracking and C_ContentTracking.GetBestMapForTrackable and C_Map and C_Map.OpenWorldMap then
            local okP, _, bestMapID = pcall(C_ContentTracking.GetBestMapForTrackable, trackType, appearanceID, false)
            if okP and type(bestMapID) == "number" and bestMapID > 0 then
                pcall(C_Map.OpenWorldMap, bestMapID)
                opened = true
                togglableOpen = true
            end
        end
        if not opened and ContentTrackingUtil and ContentTrackingUtil.OpenMapToTrackable then
            pcall(ContentTrackingUtil.OpenMapToTrackable, trackType, appearanceID)
            togglableOpen = true
        end
        if togglableOpen and addon.focus then
            addon.focus.appearanceMapToggleID = appearanceID
        end
        if addon.SetAppearanceWaypoint then
            addon.SetAppearanceWaypoint(appearanceID)
        end
    end

    if deferOpen and C_Timer and C_Timer.After then
        C_Timer.After(0, runOpenMap)
    else
        runOpenMap()
    end
end

--- Toggle world map for a tracked appearance: close if already open from this row (same ID), else open.
--- Mirrors addon.ToggleQuestDetails / openQuestLog quest behaviour.
--- @param appearanceID number
local function ToggleAppearanceMapToTrackable(appearanceID)
    if not appearanceID or appearanceID <= 0 then return end
    if InCombatLockdown() then return end
    local worldMap = _G.WorldMapFrame
    if worldMap and worldMap.IsShown and worldMap:IsShown() and addon.focus
        and addon.focus.appearanceMapToggleID == appearanceID then
        if HideUIPanel and type(HideUIPanel) == "function" then
            pcall(HideUIPanel, worldMap)
        else
            pcall(function() worldMap:Hide() end)
        end
        addon.focus.appearanceMapToggleID = nil
        return
    end
    AppearanceOpenMapToTrackable(appearanceID)
end

local function AppearanceToggleContentFocus(appearanceID)
    if not appearanceID then return end
    local trackType = Enum and Enum.ContentTrackingType and Enum.ContentTrackingType.Appearance
    if not trackType or not C_SuperTrack or not C_SuperTrack.GetSuperTrackedContent or not C_SuperTrack.SetSuperTrackedContent then
        return
    end
    local ok, curType, curId = pcall(C_SuperTrack.GetSuperTrackedContent)
    if ok and curType == trackType and curId == appearanceID then
        if C_SuperTrack.ClearSuperTrackedContent then
            pcall(C_SuperTrack.ClearSuperTrackedContent)
        end
        if addon.ClearAppearanceWaypoint then
            addon.ClearAppearanceWaypoint()
        end
    else
        -- Retail keeps a single super-track target; a focused quest prevents content super-track from sticking (focus flashes off).
        if C_SuperTrack.GetSuperTrackedQuestID and C_SuperTrack.SetSuperTrackedQuestID then
            local okQ, qid = pcall(C_SuperTrack.GetSuperTrackedQuestID)
            if okQ and type(qid) == "number" and qid > 0 then
                pcall(C_SuperTrack.SetSuperTrackedQuestID, 0)
                if addon.ClearQuestWaypoint then
                    addon.ClearQuestWaypoint()
                end
            end
        end
        pcall(C_SuperTrack.SetSuperTrackedContent, trackType, appearanceID)
        if addon.focus and addon.focus.UseBlizzardStyleQuestIconClicks and addon.focus.UseBlizzardStyleQuestIconClicks() then
            -- No map open: TomTom waypoint only, matching quest icon behaviour (super-track persists).
            -- Defer one frame: GetNextWaypointForTrackable often returns nothing the same frame as SetSuperTrackedContent
            -- (same class of issue as map open vs super-track in AppearanceOpenMapToTrackable).
            local idDeferred = appearanceID
            if C_Timer and C_Timer.After then
                C_Timer.After(0, function()
                    if addon.SetAppearanceWaypoint then
                        addon.SetAppearanceWaypoint(idDeferred)
                    end
                end)
            elseif addon.SetAppearanceWaypoint then
                addon.SetAppearanceWaypoint(appearanceID)
            end
        end
        -- Shift+Left still opens the map via AppearanceOpenMapToTrackable (separate action path).
    end
    local wqtPanel = _G.WorldQuestTrackerScreenPanel
    if wqtPanel and wqtPanel:IsShown() then
        wqtPanel:Hide()
    end
    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
end

local function AppearanceClearFocusOnly()
    if C_SuperTrack and C_SuperTrack.ClearSuperTrackedContent then
        pcall(C_SuperTrack.ClearSuperTrackedContent)
    end
    if addon.ClearAppearanceWaypoint then
        addon.ClearAppearanceWaypoint()
    end
    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
end

--- Classic mode: context menu for tracked appearance (dressing room 3D preview, jump to Appearances page, Untrack).
--- @param appearanceID number
--- @param anchor Frame|nil Pool entry frame (for cached item link when opening dressing room).
local function ShowAppearanceContextMenu(appearanceID, anchor)
    if not appearanceID then return end
    local L = addon.L or {}
    local menuList = {
        {
            text = L["OPTIONS_FOCUS_SHOW_APPEARANCE_WARDROBE"] or "Show wardrobe",
            notCheckable = true,
            func = function()
                local entry = anchor
                if not (type(entry) == "table" and entry.appearanceID == appearanceID) then
                    entry = { appearanceID = appearanceID }
                end
                AppearanceOpenDressingRoom(entry)
            end,
        },
        {
            text = L["OPTIONS_FOCUS_OPEN_APPEARANCES_COLLECTIONS"] or "Open Collections",
            notCheckable = true,
            func = function()
                if addon.OpenTrackedAppearanceInCollections then
                    addon.OpenTrackedAppearanceInCollections(appearanceID)
                end
            end,
        },
        {
            text = L["OPTIONS_FOCUS_UNTRACK_APPEARANCE"] or "Untrack appearance",
            notCheckable = true,
            func = function()
                AppearanceStopTracking(appearanceID)
            end,
        },
    }
    if C_AddOns and C_AddOns.LoadAddOn then
        pcall(C_AddOns.LoadAddOn, "Blizzard_UIDropDownMenu")
    end
    local menuFrame = _G.HorizonSuite_AppearanceContextMenu
    if not menuFrame then
        menuFrame = CreateFrame("Frame", "HorizonSuite_AppearanceContextMenu", UIParent, "UIDropDownMenuTemplate")
        if not menuFrame then return end
    end
    local anchorFrame = anchor or UIParent
    if EasyMenu then
        if CloseDropDownMenus then CloseDropDownMenus() end
        C_Timer.After(0, function()
            EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU")
        end)
    elseif UIDropDownMenu_Initialize and ToggleDropDownMenu and UIDropDownMenu_CreateInfo and UIDropDownMenu_AddButton then
        local items = menuList
        UIDropDownMenu_Initialize(menuFrame, function(dropdown, level, list)
            if not level or level ~= 1 then return end
            for _, item in ipairs(items) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = item.text
                info.notCheckable = true
                info.func = item.func
                UIDropDownMenu_AddButton(info, level)
            end
        end, "MENU", 1, nil)
        if CloseDropDownMenus then CloseDropDownMenus() end
        C_Timer.After(0, function()
            ToggleDropDownMenu(1, nil, menuFrame, anchorFrame, 0, 0)
        end)
    end
end

-- ---------------------------------------------------------------------------
-- Tracked non-quest rows (Blizzard+): same GetQuestClickAction as quests.
-- ---------------------------------------------------------------------------

--- @param entry Frame
--- @return string|nil kind ach|endeavor|decor|advguide|recipe|rare
local function ResolveTrackedContentKind(entry)
    if not entry or not entry.entryKey or type(entry.entryKey) ~= "string" then return nil end
    if entry.entryKey:match("^ach:%d+$") and entry.achievementID then return "ach" end
    if entry.entryKey:match("^endeavor:%d+$") and entry.endeavorID then return "endeavor" end
    if entry.entryKey:match("^decor:%d+$") and entry.decorID then return "decor" end
    if entry.entryKey:match("^advguide:") and entry.adventureGuideID then return "advguide" end
    if entry.isRecipe and entry.recipeID then return "recipe" end
    local hasVig = entry.entryKey:match("^vignette:(.+)$")
    local hasRare = entry.entryKey:match("^rare:(%d+)$")
    local isRareOrRareLoot = entry.isRare or entry.isRareLoot or entry.category == "RARE" or entry.category == "RARE_LOOT"
    if (hasVig or hasRare) and isRareOrRareLoot then return "rare" end
    return nil
end

local function OpenAchievementEntry(entry)
    if entry.achievementID and addon.OpenAchievementToAchievement then
        addon.OpenAchievementToAchievement(entry.achievementID)
    end
end

local function UntrackAchievementEntry(entry)
    if not entry.achievementID then return end
    local trackType = Enum and Enum.ContentTrackingType and Enum.ContentTrackingType.Achievement
    local stopType = Enum and Enum.ContentTrackingStopType and Enum.ContentTrackingStopType.Manual
    if trackType and stopType and C_ContentTracking and C_ContentTracking.StopTracking then
        pcall(C_ContentTracking.StopTracking, trackType, entry.achievementID, stopType)
    elseif RemoveTrackedAchievement then
        RemoveTrackedAchievement(entry.achievementID)
    end
    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
end

local function OpenEndeavorEntry(entry)
    if not entry.endeavorID then return end
    if HousingFramesUtil and HousingFramesUtil.OpenFrameToTaskID then
        pcall(HousingFramesUtil.OpenFrameToTaskID, entry.endeavorID)
    elseif ToggleHousingDashboard then
        ToggleHousingDashboard()
    elseif HousingFrame and HousingFrame.Show then
        if HousingFrame:IsShown() then HousingFrame:Hide() else HousingFrame:Show() end
    end
end

local function UntrackEndeavorEntry(entry)
    if not entry.endeavorID then return end
    if C_NeighborhoodInitiative and C_NeighborhoodInitiative.RemoveTrackedInitiativeTask then
        pcall(C_NeighborhoodInitiative.RemoveTrackedInitiativeTask, entry.endeavorID)
    elseif C_Endeavors and C_Endeavors.StopTracking then
        pcall(C_Endeavors.StopTracking, entry.endeavorID)
    end
    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
end

-- If InspectRecipeFrame is open on this recipe, hide it (second click on the same Focus row). Uses SchematicForm:IsCurrentRecipe.
local function TryCloseInspectRecipeFrameForRecipe(recipeID)
    local inspectFrame = _G.InspectRecipeFrame
    if not inspectFrame or not inspectFrame.IsShown or not inspectFrame:IsShown() then return false end
    local schematic = inspectFrame.SchematicForm
    if not schematic or not schematic.IsCurrentRecipe then return false end
    local ok, isSame = pcall(function()
        return schematic:IsCurrentRecipe(recipeID)
    end)
    if not ok or not isSame then return false end
    if HideUIPanel then
        pcall(HideUIPanel, inspectFrame)
    elseif inspectFrame.Hide then
        pcall(inspectFrame.Hide, inspectFrame)
    end
    return true
end

-- Open tracked recipe: prefer Blizzard's standalone InspectRecipeFrame (see Blizzard_ProfessionsInspectRecipe.lua InspectRecipeMixin:Open).
-- Menu paths must pass recipeID (pool entries recycle and clear fields).
local function OpenRecipeByID(recipeID, isRecraft)
    if not recipeID or type(recipeID) ~= "number" or recipeID <= 0 then return end
    isRecraft = (isRecraft == true)
    if C_AddOns and C_AddOns.LoadAddOn then
        pcall(C_AddOns.LoadAddOn, "Blizzard_Professions")
    end

    if TryCloseInspectRecipeFrameForRecipe(recipeID) then
        return
    end

    -- Standalone recipe panel (RegisterUIPanel); ShowUIPanel may not run during combat lockdown.
    if not InCombatLockdown() then
        local inspectFrame = _G.InspectRecipeFrame
        if inspectFrame and type(inspectFrame.Open) == "function" then
            -- pcall: Open uses C_TradeSkillUI data; can error on invalid or unloaded recipe.
            local inspectOk = pcall(function()
                inspectFrame:Open(recipeID)
            end)
            if inspectOk then
                return
            end
        end
    end

    local hasProfessionsUtil = ProfessionsUtil and ProfessionsUtil.OpenProfessionFrameToRecipe
    if hasProfessionsUtil then
        if isRecraft then
            pcall(ProfessionsUtil.OpenProfessionFrameToRecipe, recipeID, true)
        else
            pcall(ProfessionsUtil.OpenProfessionFrameToRecipe, recipeID)
        end
    elseif C_TradeSkillUI and C_TradeSkillUI.GetProfessionInfoByRecipeID and C_TradeSkillUI.GetProfessionSkillLineID and C_TradeSkillUI.OpenTradeSkill then
        -- No ProfessionsUtil: open the correct tradeskill (e.g. Jewelcrafting) so OpenRecipe / inspect pane can show.
        local ok, profInfo = pcall(C_TradeSkillUI.GetProfessionInfoByRecipeID, recipeID)
        if ok and type(profInfo) == "table" and profInfo.profession then
            local ok2, skillLineID = pcall(C_TradeSkillUI.GetProfessionSkillLineID, profInfo.profession)
            if ok2 and type(skillLineID) == "number" and skillLineID > 0 then
                pcall(C_TradeSkillUI.OpenTradeSkill, skillLineID)
            end
        end
    end

    local function fireOpenRecipe()
        if C_TradeSkillUI and C_TradeSkillUI.OpenRecipe then
            pcall(C_TradeSkillUI.OpenRecipe, recipeID)
        end
    end
    fireOpenRecipe()
    -- Next frame: profession frame may not accept OpenRecipe until after layout (InspectRecipe / details pane).
    if C_Timer and C_Timer.After then
        C_Timer.After(0, fireOpenRecipe)
    end
end

local function OpenRecipeEntry(entry)
    if not entry or not entry.recipeID then return end
    OpenRecipeByID(entry.recipeID, entry.recipeIsRecraft == true)
end

local function UntrackRecipeByID(recipeID, isRecraft)
    if not recipeID or type(recipeID) ~= "number" or recipeID <= 0 then return end
    isRecraft = (isRecraft == true)
    if C_AddOns and C_AddOns.LoadAddOn then
        pcall(C_AddOns.LoadAddOn, "Blizzard_Professions")
    end
    if C_TradeSkillUI and C_TradeSkillUI.SetRecipeTracked then
        pcall(C_TradeSkillUI.SetRecipeTracked, recipeID, false, isRecraft)
    end
    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
end

local function UntrackRecipeEntry(entry)
    if not entry or not entry.recipeID then return end
    UntrackRecipeByID(entry.recipeID, entry.recipeIsRecraft == true)
end

local function OpenAdventureGuideEntry(_entry)
    if ToggleEncounterJournal then
        ToggleEncounterJournal()
    end
end

local function UntrackAdventureGuideEntry(entry)
    if not entry.adventureGuideID then return end
    if C_PerksActivities and C_PerksActivities.RemoveTrackedPerksActivity then
        pcall(C_PerksActivities.RemoveTrackedPerksActivity, entry.adventureGuideID)
    end
    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
end

local function DecorOpenMap(entry)
    if not entry or not entry.decorID or InCombatLockdown() then return end
    local trackTypeDecor = Enum and Enum.ContentTrackingType and Enum.ContentTrackingType.Decor
    if trackTypeDecor and ContentTrackingUtil and ContentTrackingUtil.OpenMapToTrackable then
        pcall(ContentTrackingUtil.OpenMapToTrackable, trackTypeDecor, entry.decorID)
    end
end

local function DecorPreview(entry)
    if not entry or not entry.decorID then return end
    if HousingFramesUtil and HousingFramesUtil.PreviewHousingDecorID then
        pcall(HousingFramesUtil.PreviewHousingDecorID, entry.decorID)
    elseif ToggleHousingDashboard then
        ToggleHousingDashboard()
    elseif HousingFrame and HousingFrame.Show then
        if HousingFrame:IsShown() then HousingFrame:Hide() else HousingFrame:Show() end
    end
end

local function OpenDecorCatalogEntry(entry)
    if not entry or not entry.decorID then return end
    if not HousingDashboardFrame and C_AddOns and C_AddOns.LoadAddOn then
        pcall(C_AddOns.LoadAddOn, "Blizzard_HousingDashboard")
    end
    local entryType = Enum and Enum.HousingCatalogEntryType and Enum.HousingCatalogEntryType.Decor
    local ok, info = pcall(function()
        if C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByRecordID and entryType then
            return C_HousingCatalog.GetCatalogEntryInfoByRecordID(entryType, entry.decorID, true)
        end
    end)
    if ok and info and HousingDashboardFrame and HousingDashboardFrame.SetTab and HousingDashboardFrame.catalogTab then
        ShowUIPanel(HousingDashboardFrame)
        HousingDashboardFrame:SetTab(HousingDashboardFrame.catalogTab)
        if C_Timer and C_Timer.After then
            C_Timer.After(0.5, function()
                if HousingDashboardFrame and HousingDashboardFrame.CatalogContent and HousingDashboardFrame.CatalogContent.PreviewFrame then
                    local pf = HousingDashboardFrame.CatalogContent.PreviewFrame
                    if pf.PreviewCatalogEntryInfo then
                        pcall(pf.PreviewCatalogEntryInfo, pf, info)
                    end
                    if pf.Show then pf:Show() end
                end
            end)
        end
    elseif ToggleHousingDashboard then
        ToggleHousingDashboard()
    elseif HousingFrame and HousingFrame.Show then
        if HousingFrame:IsShown() then HousingFrame:Hide() else HousingFrame:Show() end
    end
end

local function UntrackDecorEntry(entry)
    if not entry or not entry.decorID then return end
    local trackTypeDecor = Enum and Enum.ContentTrackingType and Enum.ContentTrackingType.Decor
    local stopType = Enum and Enum.ContentTrackingStopType and Enum.ContentTrackingStopType.Manual
    if trackTypeDecor and stopType and C_ContentTracking and C_ContentTracking.StopTracking then
        pcall(C_ContentTracking.StopTracking, trackTypeDecor, entry.decorID, stopType)
    end
    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
end

local function OpenRareWaypointEntry(entry)
    if not entry then return end
    if addon.GetDB("tomtomRareWaypoint", true) then
        if addon.SetRareWaypoint then
            addon.SetRareWaypoint(entry)
        end
    else
        local vignetteGUID = entry.vignetteGUID or (entry.entryKey and entry.entryKey:match("^vignette:(.+)$"))
        if vignetteGUID and C_SuperTrack and C_SuperTrack.SetSuperTrackedVignette then
            C_SuperTrack.SetSuperTrackedVignette(vignetteGUID)
        end
    end
    local wqtPanel = _G.WorldQuestTrackerScreenPanel
    if wqtPanel and wqtPanel:IsShown() then
        wqtPanel:Hide()
    end
end

local function UntrackRareEntry(entry)
    local vignetteGUID = entry and (entry.vignetteGUID or (entry.entryKey and entry.entryKey:match("^vignette:(.+)$")))
    if vignetteGUID and C_SuperTrack and C_SuperTrack.GetSuperTrackedVignette and C_SuperTrack.SetSuperTrackedVignette then
        if C_SuperTrack.GetSuperTrackedVignette() == vignetteGUID then
            C_SuperTrack.SetSuperTrackedVignette(nil)
        end
    end
    local wqtPanel = _G.WorldQuestTrackerScreenPanel
    if wqtPanel and wqtPanel:IsShown() then
        wqtPanel:Hide()
    end
    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
end

local function RunEasyMenuTracked(menuList, frameName, anchor)
    if not menuList or #menuList == 0 then return end
    if C_AddOns and C_AddOns.LoadAddOn then
        pcall(C_AddOns.LoadAddOn, "Blizzard_UIDropDownMenu")
    end
    local menuFrame = _G[frameName]
    if not menuFrame then
        menuFrame = CreateFrame("Frame", frameName, UIParent, "UIDropDownMenuTemplate")
        if not menuFrame then return end
        _G[frameName] = menuFrame
    end
    local anchorFrame = anchor or UIParent
    if EasyMenu then
        if CloseDropDownMenus then CloseDropDownMenus() end
        C_Timer.After(0, function()
            EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU")
        end)
    elseif UIDropDownMenu_Initialize and ToggleDropDownMenu and UIDropDownMenu_CreateInfo and UIDropDownMenu_AddButton then
        local items = menuList
        UIDropDownMenu_Initialize(menuFrame, function(_, level)
            if not level or level ~= 1 then return end
            for _, item in ipairs(items) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = item.text
                info.notCheckable = true
                info.func = item.func
                UIDropDownMenu_AddButton(info, level)
            end
        end, "MENU", 1, nil)
        if CloseDropDownMenus then CloseDropDownMenus() end
        C_Timer.After(0, function()
            ToggleDropDownMenu(1, nil, menuFrame, anchorFrame, 0, 0)
        end)
    end
end

local function ShowTrackedAchievementContextMenu(entry, anchor)
    local L = addon.L or {}
    local aid = entry.achievementID
    if not aid then return end
    RunEasyMenuTracked({
        {
            text = L["OPTIONS_FOCUS_CONTEXT_OPEN_ACHIEVEMENT"] or "Open achievement",
            notCheckable = true,
            func = function() OpenAchievementEntry(entry) end,
        },
        {
            text = L["OPTIONS_FOCUS_STOP_TRACKING"] or "Stop tracking",
            notCheckable = true,
            func = function() UntrackAchievementEntry(entry) end,
        },
    }, "HorizonSuite_TrackedAchContextMenu", anchor)
end

local function ShowTrackedEndeavorContextMenu(entry, anchor)
    local L = addon.L or {}
    if not entry.endeavorID then return end
    RunEasyMenuTracked({
        {
            text = L["OPTIONS_FOCUS_CONTEXT_OPEN_ENDEAVOR"] or "Open endeavor",
            notCheckable = true,
            func = function() OpenEndeavorEntry(entry) end,
        },
        {
            text = L["OPTIONS_FOCUS_STOP_TRACKING"] or "Stop tracking",
            notCheckable = true,
            func = function() UntrackEndeavorEntry(entry) end,
        },
    }, "HorizonSuite_TrackedEndeavorContextMenu", anchor)
end

local function ShowTrackedRecipeContextMenu(entry, anchor)
    local L = addon.L or {}
    if not entry.recipeID then return end
    -- Copy IDs now: pool entry may be cleared before the menu item runs.
    local recipeID = entry.recipeID
    local isRecraft = entry.recipeIsRecraft == true
    RunEasyMenuTracked({
        {
            text = L["OPTIONS_FOCUS_CONTEXT_OPEN_RECIPE"] or "Open recipe",
            notCheckable = true,
            func = function() OpenRecipeByID(recipeID, isRecraft) end,
        },
        {
            text = L["OPTIONS_FOCUS_STOP_TRACKING"] or "Stop tracking",
            notCheckable = true,
            func = function() UntrackRecipeByID(recipeID, isRecraft) end,
        },
    }, "HorizonSuite_TrackedRecipeContextMenu", anchor)
end

local function ShowTrackedDecorContextMenu(entry, anchor)
    local L = addon.L or {}
    if not entry.decorID then return end
    RunEasyMenuTracked({
        {
            text = L["OPTIONS_FOCUS_CONTEXT_OPEN_DECOR_CATALOG"] or "Open in catalog",
            notCheckable = true,
            func = function() OpenDecorCatalogEntry(entry) end,
        },
        {
            text = L["OPTIONS_FOCUS_CONTEXT_PREVIEW_DECOR"] or "Preview decor",
            notCheckable = true,
            func = function() DecorPreview(entry) end,
        },
        {
            text = L["OPTIONS_FOCUS_CONTEXT_SHOW_DECOR_MAP"] or "Show on map",
            notCheckable = true,
            func = function() DecorOpenMap(entry) end,
        },
        {
            text = L["OPTIONS_FOCUS_STOP_TRACKING"] or "Stop tracking",
            notCheckable = true,
            func = function() UntrackDecorEntry(entry) end,
        },
    }, "HorizonSuite_TrackedDecorContextMenu", anchor)
end

local function ShowTrackedAdventureGuideContextMenu(entry, anchor)
    local L = addon.L or {}
    if not entry.adventureGuideID then return end
    RunEasyMenuTracked({
        {
            text = L["OPTIONS_FOCUS_CONTEXT_OPEN_TRAVELERS_LOG"] or "Open Traveler's Log",
            notCheckable = true,
            func = function() OpenAdventureGuideEntry(entry) end,
        },
        {
            text = L["OPTIONS_FOCUS_STOP_TRACKING"] or "Stop tracking",
            notCheckable = true,
            func = function() UntrackAdventureGuideEntry(entry) end,
        },
    }, "HorizonSuite_TrackedAdvGuideContextMenu", anchor)
end

local function ShowTrackedRareContextMenu(entry, anchor)
    local L = addon.L or {}
    RunEasyMenuTracked({
        {
            text = L["OPTIONS_FOCUS_CONTEXT_SET_RARE_WAYPOINT"] or "Set waypoint",
            notCheckable = true,
            func = function() OpenRareWaypointEntry(entry) end,
        },
        {
            text = L["OPTIONS_FOCUS_CONTEXT_CLEAR_RARE_FOCUS"] or "Clear map focus",
            notCheckable = true,
            func = function() UntrackRareEntry(entry) end,
        },
    }, "HorizonSuite_TrackedRareContextMenu", anchor)
end

--- Dispatch profile action for tracked non-quest rows (Blizzard+).
--- @param action string
--- @param kind string
--- @param entry Frame
local function ExecuteTrackedContentAction(action, kind, entry)
    if action == "openQuestLog" or action == "openProfession" then
        if kind == "ach" then OpenAchievementEntry(entry)
        elseif kind == "endeavor" then OpenEndeavorEntry(entry)
        elseif kind == "recipe" then OpenRecipeEntry(entry)
        elseif kind == "decor" then OpenDecorCatalogEntry(entry)
        elseif kind == "advguide" then OpenAdventureGuideEntry(entry)
        elseif kind == "rare" then OpenRareWaypointEntry(entry)
        end
    elseif action == "untrack" or action == "abandon" then
        if kind == "ach" then UntrackAchievementEntry(entry)
        elseif kind == "endeavor" then UntrackEndeavorEntry(entry)
        elseif kind == "recipe" then UntrackRecipeEntry(entry)
        elseif kind == "decor" then UntrackDecorEntry(entry)
        elseif kind == "advguide" then UntrackAdventureGuideEntry(entry)
        elseif kind == "rare" then UntrackRareEntry(entry)
        end
    elseif action == "contextMenu" then
        if kind == "ach" then ShowTrackedAchievementContextMenu(entry, entry)
        elseif kind == "endeavor" then ShowTrackedEndeavorContextMenu(entry, entry)
        elseif kind == "recipe" then ShowTrackedRecipeContextMenu(entry, entry)
        elseif kind == "decor" then ShowTrackedDecorContextMenu(entry, entry)
        elseif kind == "advguide" then ShowTrackedAdventureGuideContextMenu(entry, entry)
        elseif kind == "rare" then ShowTrackedRareContextMenu(entry, entry)
        end
    elseif action == "wowhear" then
        local url = addon.GetWoWheadURL and addon.GetWoWheadURL(entry)
        if url and type(url) == "string" and url ~= "" and addon.ShowURLCopyBox then
            addon.ShowURLCopyBox(url)
        end
    elseif action == "chatLink" then
        if ChatFrameUtil and ChatFrameUtil.GetActiveWindow and ChatFrameUtil.GetActiveWindow() and ChatFrameUtil.InsertLink then
            if kind == "ach" and entry.achievementID and GetAchievementLink then
                local link = GetAchievementLink(entry.achievementID)
                if link then ChatFrameUtil.InsertLink(link) end
            elseif kind == "endeavor" and entry.endeavorID and C_NeighborhoodInitiative and C_NeighborhoodInitiative.GetInitiativeTaskChatLink then
                local ok, link = pcall(C_NeighborhoodInitiative.GetInitiativeTaskChatLink, entry.endeavorID)
                if ok and link and type(link) == "string" and link ~= "" then ChatFrameUtil.InsertLink(link) end
            elseif kind == "recipe" and entry.recipeID and C_TradeSkillUI and C_TradeSkillUI.GetRecipeInfo then
                local ok, info = pcall(C_TradeSkillUI.GetRecipeInfo, entry.recipeID)
                if ok and info and type(info) == "table" and info.hyperlink then ChatFrameUtil.InsertLink(info.hyperlink) end
            elseif kind == "advguide" and entry.adventureGuideID and C_PerksActivities and C_PerksActivities.GetPerksActivityChatLink then
                local ok, link = pcall(C_PerksActivities.GetPerksActivityChatLink, entry.adventureGuideID)
                if ok and link and type(link) == "string" and link ~= "" then ChatFrameUtil.InsertLink(link) end
            end
        end
    elseif action == "share" then
        local printFn = addon.HSPrint or print
        local L = addon.L or {}
        printFn("|cffffcc00" .. (L["OPTIONS_FOCUS_TRACKED_CONTENT_CANNOT_SHARE"] or "This entry cannot be shared.") .. "|r")
    elseif action == "superTrack" then
        if kind == "rare" then
            OpenRareWaypointEntry(entry)
        end
    end
end

local function MaybeLogTrackedContentDispatch(buttonName, profile, clickModsTbl, action, kind, note)
    if not (addon.focus and addon.focus.clickDispatchDebug) then return end
    local printFn = addon.HSPrint or print
    local combo = addon.focus.GetQuestClickComboKey and addon.focus.GetQuestClickComboKey(buttonName, clickModsTbl) or "?"
    local prof = profile
    if prof == nil then prof = addon.GetDB("focusClickProfile", "blizzardDefault") end
    printFn(("[Horizon Focus click] profile=%s combo=%s action=%s trackedKind=%s %s"):format(
        tostring(prof), tostring(combo), tostring(action), tostring(kind), note or ""))
end

--- Left-click on quest type icon: toggle super-track (classic mode, Blizzard+ profile, or row hit-test fallback).
--- @param entry Frame pool entry
--- @return nil
function addon.HandleClassicQuestIconMouseDown(entry)
    if not entry or not entry.questID then return end

    local now = (GetTimePreciseSec and GetTimePreciseSec()) or GetTime()
    local lastClick = entry._classicQuestIconClickAt
    if lastClick and (now - lastClick) < CLASSIC_ICON_CLICK_DEBOUNCE then
        return
    end
    entry._classicQuestIconClickAt = now

    local questID = entry.questID
    if C_SuperTrack and C_SuperTrack.SetSuperTrackedQuestID and C_SuperTrack.GetSuperTrackedQuestID then
        local currentFocused = C_SuperTrack.GetSuperTrackedQuestID()
        if currentFocused and currentFocused == questID then
            C_SuperTrack.SetSuperTrackedQuestID(0)
            if addon.ClearQuestWaypoint then addon.ClearQuestWaypoint() end
        else
            C_SuperTrack.SetSuperTrackedQuestID(questID)
            if addon.GetDB("tomtomQuestWaypoint", false) and addon.SetQuestWaypoint then
                addon.SetQuestWaypoint(questID, true)
            end
        end
        local wqtPanel = _G.WorldQuestTrackerScreenPanel
        if wqtPanel and wqtPanel:IsShown() then
            wqtPanel:Hide()
        end
    end
    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
end

--- Classic: left-click on appearance type icon (questIconBtn). Called from FocusEntryPool.
--- @param entry Frame pool entry
function addon.HandleClassicAppearanceIconMouseDown(entry)
    if not entry or not entry.appearanceID then return end
    local id = entry.appearanceID
    if IsModifiedClick("CHATLINK") and ChatFrameUtil and ChatFrameUtil.GetActiveWindow and ChatFrameUtil.GetActiveWindow() and ChatFrameUtil.InsertLink then
        local link = GetAppearanceDressLink(entry)
        if link then
            ChatFrameUtil.InsertLink(link)
            if addon.ScheduleRefresh then addon.ScheduleRefresh() end
            return
        end
    end
    if IsAltKeyDown() then
        local url = addon.GetWoWheadURL(entry)
        if url and type(url) == "string" and url ~= "" then
            if addon.ShowURLCopyBox then addon.ShowURLCopyBox(url) end
            return
        end
    end
    if IsShiftKeyDown() then
        AppearanceStopTracking(id)
        return
    end
    if IsControlKeyDown() then
        AppearanceOpenDressingRoom(entry)
        return
    end
    AppearanceToggleContentFocus(id)
end

StaticPopupDialogs["HORIZONSUITE_ABANDON_QUEST"] = StaticPopupDialogs["HORIZONSUITE_ABANDON_QUEST"] or {
    text = "Abandon %s?",
    button1 = YES,
    button2 = NO,
    OnAccept = function(self)
        local data = self.data
        if data and data.questID and C_QuestLog and C_QuestLog.AbandonQuest then
            if C_QuestLog.SetSelectedQuest then
                C_QuestLog.SetSelectedQuest(data.questID)
            end
            if C_QuestLog.SetAbandonQuest then
                C_QuestLog.SetAbandonQuest()
            elseif SetAbandonQuest then
                SetAbandonQuest()
            end
            C_QuestLog.AbandonQuest()
            addon.ScheduleRefresh()
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

-- Auctionator craft dialog: addon.focus.ShowAuctionCraftDialog (FocusAuctionCraftDialog.lua), same chrome as UrlCopyDialog.

-- ============================================================================
-- QUEST WAYPOINT (TomTom / native)
-- ============================================================================

local activeQuestWaypointUID
local activeAppearanceWaypointUID

local function TryWaypointOnMap(questID, mapID)
    if not mapID then return nil, nil end
    if C_QuestLog.GetNextWaypointForMap then
        local ok, x, y = pcall(C_QuestLog.GetNextWaypointForMap, questID, mapID)
        if ok and x and y then return x, y end
    end
    if C_SuperTrack and C_SuperTrack.GetNextWaypointForMap then
        local ok, x, y = pcall(C_SuperTrack.GetNextWaypointForMap, mapID)
        if ok and x and y then return x, y end
    end
    return nil, nil
end

local function FindQuestOnMap(questID, mapID)
    if not mapID or not C_QuestLog.GetQuestsOnMap then return nil, nil end
    local ok, quests = pcall(C_QuestLog.GetQuestsOnMap, mapID)
    if not ok or not quests then return nil, nil end
    for _, q in ipairs(quests) do
        if q.questID == questID and q.x and q.y and q.x > 0 and q.y > 0 then
            return q.x, q.y
        end
    end
    return nil, nil
end

local function GetParentChain(mapID)
    local chain = {}
    local current = mapID
    for _ = 1, 10 do
        if not current or current == 0 then break end
        local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(current)
        if not info then break end
        local parent = info.parentMapID
        if not parent or parent == 0 or parent == current then break end
        chain[#chain + 1] = parent
        current = parent
    end
    return chain
end

local function GetQuestObjectiveCoords(questID)
    local playerMap = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")

    if C_QuestLog.GetNextWaypoint then
        local ok, mapID, x, y = pcall(C_QuestLog.GetNextWaypoint, questID)
        if ok and mapID and x and y then return mapID, x, y end
    end

    local mapsToTry = {}
    local seen = {}
    local function addMap(m)
        if m and m ~= 0 and not seen[m] then
            seen[m] = true
            mapsToTry[#mapsToTry + 1] = m
        end
    end

    addMap(playerMap)

    if C_QuestLog.GetMapForQuestPOIs then
        local ok, poiMap = pcall(C_QuestLog.GetMapForQuestPOIs)
        if ok and poiMap then addMap(poiMap) end
    end

    if playerMap then
        for _, parent in ipairs(GetParentChain(playerMap)) do
            addMap(parent)
        end
    end

    for _, m in ipairs(mapsToTry) do
        local x, y = TryWaypointOnMap(questID, m)
        if x and y then return m, x, y end
    end

    for _, m in ipairs(mapsToTry) do
        local x, y = FindQuestOnMap(questID, m)
        if x and y then return m, x, y end
    end

    if playerMap and C_Map and C_Map.GetMapChildrenInfo then
        local continentMap = nil
        for _, m in ipairs(mapsToTry) do
            local info = C_Map.GetMapInfo(m)
            if info and info.mapType and info.mapType == 2 then
                continentMap = m
                break
            end
        end
        if continentMap then
            local ok, children = pcall(C_Map.GetMapChildrenInfo, continentMap, Enum.UIMapType.Zone, true)
            if ok and children then
                for _, child in ipairs(children) do
                    local childID = child.mapID
                    if childID and not seen[childID] then
                        seen[childID] = true
                        local x, y = FindQuestOnMap(questID, childID)
                        if x and y then return childID, x, y end
                    end
                end
            end
        end
    end

    if C_TaskQuest and C_TaskQuest.GetQuestLocation and playerMap then
        local ok, x, y = pcall(C_TaskQuest.GetQuestLocation, questID, playerMap)
        if ok and x and y then return playerMap, x, y end
    end

    return nil, nil, nil
end

local function ClearAppearanceWaypoint()
    addon._appearanceWaypointTargetID = nil
    if not activeAppearanceWaypointUID then return end
    local TomTom = _G.TomTom
    if TomTom and TomTom.RemoveWaypoint then
        pcall(TomTom.RemoveWaypoint, TomTom, activeAppearanceWaypointUID)
    end
    activeAppearanceWaypointUID = nil
end

local function ClearQuestWaypoint()
    if not activeQuestWaypointUID then return end
    local TomTom = _G.TomTom
    if TomTom and TomTom.RemoveWaypoint then
        pcall(TomTom.RemoveWaypoint, TomTom, activeQuestWaypointUID)
    end
    activeQuestWaypointUID = nil
end

--- Waypoint for super-tracked transmog appearance: TomTom if available, else native map user waypoint.
--- Same preference order and option (`tomtomQuestWaypoint`) as SetQuestWaypoint; does not call
--- SetSuperTrackedUserWaypoint so appearance content super-track stays the active target.
--- @param appearanceID number
local function SetAppearanceWaypoint(appearanceID)
    if not appearanceID or appearanceID <= 0 then return end
    if not addon.GetDB("tomtomQuestWaypoint", false) then return end
    local trackType = Enum and Enum.ContentTrackingType and Enum.ContentTrackingType.Appearance
    if not trackType or not C_ContentTracking or not C_ContentTracking.GetBestMapForTrackable or not C_ContentTracking.GetNextWaypointForTrackable then
        return
    end
    ClearQuestWaypoint()
    local okBest, _, bestMapID = pcall(C_ContentTracking.GetBestMapForTrackable, trackType, appearanceID, false)
    if not okBest or not bestMapID or bestMapID == 0 then return end
    local okNext, _, mapInfo = pcall(C_ContentTracking.GetNextWaypointForTrackable, trackType, appearanceID, bestMapID)
    if not okNext or not mapInfo or type(mapInfo) ~= "table" then return end
    local x, y = mapInfo.x, mapInfo.y
    if type(x) ~= "number" or type(y) ~= "number" then return end
    local title = "Appearance " .. tostring(appearanceID)
    if C_ContentTracking.GetTitle then
        local okT, t = pcall(C_ContentTracking.GetTitle, trackType, appearanceID)
        if okT and t and type(t) == "string" and t ~= "" then title = t end
    end
    ClearAppearanceWaypoint()
    local TomTom = _G.TomTom
    if TomTom and TomTom.AddWaypoint then
        local okAdd, uid = pcall(TomTom.AddWaypoint, TomTom, bestMapID, x, y, { title = title, persistent = false, minimap = true, world = true, crazy = true })
        activeAppearanceWaypointUID = okAdd and uid or nil
        if activeAppearanceWaypointUID then
            addon._appearanceWaypointTargetID = appearanceID
        end
        return
    end

    if C_Map and C_Map.SetUserWaypoint and UiMapPoint then
        local point = UiMapPoint.CreateFromCoordinates(bestMapID, x, y)
        if point then
            local okSet = pcall(C_Map.SetUserWaypoint, point)
            if okSet then
                addon._appearanceWaypointTargetID = appearanceID
            end
            -- Do not call SetSuperTrackedUserWaypoint: keep appearance as content super-track target.
        end
    end
end

--- Place a waypoint for a quest (TomTom or native). When keepQuestSuperTracked is true,
--- do not call SetSuperTrackedUserWaypoint so the quest remains the super-track target
--- (blue highlight in Focus, yellow in Blizzard quest log).
--- @param questID number
--- @param keepQuestSuperTracked boolean|nil If true, do not override quest super-track with user waypoint
local function SetQuestWaypoint(questID, keepQuestSuperTracked)
    ClearAppearanceWaypoint()
    if not questID or questID <= 0 then return end
    if not C_QuestLog then return end
    local mapID, x, y = GetQuestObjectiveCoords(questID)
    if not mapID or not x or not y then return end
    local title = (C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(questID)) or ("Quest " .. questID)

    local TomTom = _G.TomTom
    if TomTom and TomTom.AddWaypoint then
        if activeQuestWaypointUID and TomTom.RemoveWaypoint then
            pcall(TomTom.RemoveWaypoint, TomTom, activeQuestWaypointUID)
        end
        local okAdd, uid = pcall(TomTom.AddWaypoint, TomTom, mapID, x, y, { title = title, persistent = false, minimap = true, world = true, crazy = true })
        activeQuestWaypointUID = okAdd and uid or nil
        return
    end

    if C_Map and C_Map.SetUserWaypoint and UiMapPoint then
        local point = UiMapPoint.CreateFromCoordinates(mapID, x, y)
        if point then
            pcall(C_Map.SetUserWaypoint, point)
            -- Do not override quest super-track: SetSuperTrackedUserWaypoint would replace the quest
            -- as the active target, preventing blue highlight in Focus and yellow in quest log.
            if not keepQuestSuperTracked and C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, true)
            end
        end
    end
end

addon.SetQuestWaypoint = SetQuestWaypoint
addon.ClearQuestWaypoint = ClearQuestWaypoint
addon.SetAppearanceWaypoint = SetAppearanceWaypoint
addon.ClearAppearanceWaypoint = ClearAppearanceWaypoint

local function AppendDelveTooltipData(self, tooltip)
    if self.tierSpellID and addon.GetDB("showDelveAffixes", true) then
        local tierName, tierIcon
        if GetSpellInfo and type(GetSpellInfo) == "function" then
            tierName, _, tierIcon = GetSpellInfo(self.tierSpellID)
        elseif C_Spell and C_Spell.GetSpellInfo then
            local ok, info = pcall(C_Spell.GetSpellInfo, self.tierSpellID)
            if ok and info then tierName, tierIcon = info.name, info.iconID end
        end
        local tierDesc
        if C_Spell and C_Spell.GetSpellDescription then
            local ok, d = pcall(C_Spell.GetSpellDescription, self.tierSpellID)
            if ok and d and d ~= "" then tierDesc = d end
        end
        if tierName or tierDesc then
            tooltip:AddLine(" ")
            if tierName then
                local title = tierName
                if tierIcon and type(tierIcon) == "number" then
                    title = "|T" .. tierIcon .. ":20:20:0:0|t " .. title
                end
                tooltip:AddLine(title, 1, 0.82, 0)
            end
            if tierDesc then
                tooltip:AddLine(tierDesc, 0.8, 0.8, 0.8, true)
            end
        end
    end

    if self.affixData and #self.affixData > 0 and addon.GetDB("showDelveAffixes", true) then
        tooltip:AddLine(" ")
        tooltip:AddLine(_G.SEASON_AFFIXES or "Season Affixes:", 0.7, 0.7, 0.7)
        for _, a in ipairs(self.affixData) do
            local title = a.name
            if a.icon and type(a.icon) == "number" then
                title = "|T" .. a.icon .. ":20:20:0:0|t " .. title
            end
            tooltip:AddLine(title, 1, 1, 1)
            if a.desc and a.desc ~= "" then
                tooltip:AddLine(a.desc, 0.8, 0.8, 0.8, true)
            end
        end
    end
end

-- ============================================================================
-- QUEST ACTION DISPATCH
-- Named action functions extracted from click handlers.
-- Called by ExecuteQuestAction which is driven by addon.focus.GetQuestClickAction.
-- ============================================================================

-- Defer OpenQuestDetails when combat blocks the map / quest UI (silent no-op otherwise).
local openQuestDetailsAfterCombatFrame

local function QueueOpenQuestDetailsAfterCombat(questID)
    if not questID or questID <= 0 then return end
    if not addon.focus then return end
    addon.focus.pendingQuestDetailsOpenID = questID
    if not openQuestDetailsAfterCombatFrame then
        openQuestDetailsAfterCombatFrame = CreateFrame("Frame")
        openQuestDetailsAfterCombatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        openQuestDetailsAfterCombatFrame:SetScript("OnEvent", function(_, event)
            if event ~= "PLAYER_REGEN_ENABLED" then return end
            local qid = addon.focus and addon.focus.pendingQuestDetailsOpenID
            if addon.focus then
                addon.focus.pendingQuestDetailsOpenID = nil
            end
            if qid and qid > 0 and addon.OpenQuestDetails then
                addon.OpenQuestDetails(qid)
            end
        end)
    end
end

local QUEST_ACTIONS = {}

QUEST_ACTIONS["superTrack"] = function(entry)
    local isWorldQuest = addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(entry.questID)

    -- Non-world quests not yet tracked: add to tracker and promote.
    if not isWorldQuest and entry.isTracked == false then
        local isAccepted = addon.IsQuestAccepted and addon.IsQuestAccepted(entry.questID) or false
        if isAccepted then
            if C_QuestLog.AddQuestWatch then C_QuestLog.AddQuestWatch(entry.questID) end
            if C_SuperTrack and C_SuperTrack.SetSuperTrackedQuestID then
                C_SuperTrack.SetSuperTrackedQuestID(entry.questID)
            end
            if addon.GetDB("tomtomQuestWaypoint", false) then
                SetQuestWaypoint(entry.questID, true)
            end
        else
            if C_SuperTrack and C_SuperTrack.SetSuperTrackedQuestID then
                C_SuperTrack.SetSuperTrackedQuestID(entry.questID)
            end
        end
        local wqtPanel = _G.WorldQuestTrackerScreenPanel
        if wqtPanel and wqtPanel:IsShown() then wqtPanel:Hide() end
        if addon.ScheduleRefresh then addon.ScheduleRefresh() end
        return
    end

    -- Toggle super-track on already-tracked quests.
    if C_SuperTrack and C_SuperTrack.SetSuperTrackedQuestID and C_SuperTrack.GetSuperTrackedQuestID then
        local currentFocused = C_SuperTrack.GetSuperTrackedQuestID()
        if currentFocused and currentFocused == entry.questID then
            C_SuperTrack.SetSuperTrackedQuestID(0)
            if addon.GetDB("tomtomQuestWaypoint", false) then ClearQuestWaypoint() end
        else
            C_SuperTrack.SetSuperTrackedQuestID(entry.questID)
            if addon.GetDB("tomtomQuestWaypoint", false) then
                SetQuestWaypoint(entry.questID, true)
            end
        end
    end
    local wqtPanel = _G.WorldQuestTrackerScreenPanel
    if wqtPanel and wqtPanel:IsShown() then wqtPanel:Hide() end
    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
end

QUEST_ACTIONS["openQuestLog"] = function(entry)
    local isWorldQuest = addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(entry.questID)
    if isWorldQuest and C_QuestLog.AddWorldQuestWatch then
        local requireCtrl = addon.GetDB("requireCtrlForQuestClicks", false)
        if not requireCtrl or IsControlKeyDown() then
            C_QuestLog.AddWorldQuestWatch(entry.questID)
            if addon.ScheduleRefresh then addon.ScheduleRefresh() end
        end
    end
    if InCombatLockdown() then
        QueueOpenQuestDetailsAfterCombat(entry.questID)
        local printFn = addon.HSPrint or print
        local L = addon.L or {}
        printFn("|cFF00CCFF" .. (L["OPTIONS_FOCUS_QUEST_DETAILS_AFTER_COMBAT"] or "Quest details will open when you leave combat.") .. "|r")
        return
    end
    if addon.ToggleQuestDetails then
        addon.ToggleQuestDetails(entry.questID)
    elseif addon.OpenQuestDetails then
        addon.OpenQuestDetails(entry.questID)
    end
end

QUEST_ACTIONS["openProfession"] = QUEST_ACTIONS["openQuestLog"]

QUEST_ACTIONS["untrack"] = function(entry)
    -- If focused, clear focus only; then untrack.
    if C_SuperTrack and C_SuperTrack.GetSuperTrackedQuestID and C_SuperTrack.SetSuperTrackedQuestID then
        local focusedQuestID = C_SuperTrack.GetSuperTrackedQuestID()
        if focusedQuestID and focusedQuestID == entry.questID then
            C_SuperTrack.SetSuperTrackedQuestID(0)
            local wqtPanel = _G.WorldQuestTrackerScreenPanel
            if wqtPanel and wqtPanel:IsShown() then wqtPanel:Hide() end
            if addon.FullLayout then addon.ScheduleRefresh() end
            return
        end
    end
    local usePermanent = addon.GetDB("permanentlySuppressUntracked", false)
    if addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(entry.questID) and addon.RemoveWorldQuestWatch then
        addon.RemoveWorldQuestWatch(entry.questID)
        if usePermanent then
            local bl = addon.GetDB("permanentQuestBlacklist", nil)
            if type(bl) ~= "table" then bl = {} end
            bl[entry.questID] = true
            addon.SetDB("permanentQuestBlacklist", bl)
            if addon.RefreshBlacklistGrid then addon.RefreshBlacklistGrid() end
        else
            if not addon.focus.recentlyUntrackedWorldQuests then addon.focus.recentlyUntrackedWorldQuests = {} end
            addon.focus.recentlyUntrackedWorldQuests[entry.questID] = true
            if addon.GetDB("suppressUntrackedUntilReload", false) then
                addon.SetDB("sessionSuppressedQuests", addon.focus.recentlyUntrackedWorldQuests)
            end
        end
    elseif C_QuestLog.RemoveQuestWatch then
        C_QuestLog.RemoveQuestWatch(entry.questID)
    end
    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
end

QUEST_ACTIONS["contextMenu"] = function(entry)
    local name = (C_QuestLog and C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(entry.questID)) or "this quest"
    ShowQuestContextMenu(entry.questID, name, entry)
end

QUEST_ACTIONS["share"] = function(entry)
    local printFn = addon.HSPrint or print
    local L = addon.L or {}
    if C_QuestLog and C_QuestLog.IsPushableQuest and C_QuestLog.IsPushableQuest(entry.questID) then
        local inGroup = (GetNumGroupMembers and GetNumGroupMembers() > 1) or (UnitInParty and UnitInParty("player"))
        if inGroup and C_QuestLog.SetSelectedQuest and QuestLogPushQuest then
            C_QuestLog.SetSelectedQuest(entry.questID)
            QuestLogPushQuest()
        else
            printFn("|cffffcc00" .. (L["OPTIONS_FOCUS_YOU_MUST_A_PARTY_SHARE_QUEST"] or "You must be in a party to share this quest.") .. "|r")
        end
    else
        printFn("|cffffcc00" .. (L["OPTIONS_FOCUS_QUEST_CANNOT_SHARED"] or "This quest cannot be shared.") .. "|r")
    end
end

QUEST_ACTIONS["abandon"] = function(entry)
    local name = (C_QuestLog and C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(entry.questID)) or "this quest"
    StaticPopup_Show("HORIZONSUITE_ABANDON_QUEST", name, nil, { questID = entry.questID })
end

QUEST_ACTIONS["wowhear"] = function(entry)
    local url = addon.GetWoWheadURL and addon.GetWoWheadURL(entry)
    if url and type(url) == "string" and url ~= "" then
        if addon.ShowURLCopyBox then addon.ShowURLCopyBox(url) end
    end
end

QUEST_ACTIONS["chatLink"] = function(entry)
    if ChatFrameUtil and ChatFrameUtil.GetActiveWindow and ChatFrameUtil.GetActiveWindow() and ChatFrameUtil.InsertLink then
        if entry.questID and GetQuestLink then
            local link = GetQuestLink(entry.questID)
            if link then ChatFrameUtil.InsertLink(link) end
        end
    end
end

QUEST_ACTIONS["none"] = function(_) end

-- ============================================================================
-- APPEARANCE ROW ACTION DISPATCH (tracked transmog; driven by GetAppearanceClickAction)
-- ============================================================================

local APPEARANCE_ACTIONS = {}

APPEARANCE_ACTIONS["superTrack"] = function(entry)
    if entry.appearanceID then
        AppearanceToggleContentFocus(entry.appearanceID)
    end
end

-- "Open quest log" on appearance rows opens the map to the trackable (Blizzard+ row left; Horizon+ shift matches quest binding).
APPEARANCE_ACTIONS["openQuestLog"] = function(entry)
    if entry.appearanceID then
        ToggleAppearanceMapToTrackable(entry.appearanceID)
    end
end

APPEARANCE_ACTIONS["openProfession"] = APPEARANCE_ACTIONS["openQuestLog"]

APPEARANCE_ACTIONS["untrack"] = function(entry)
    local id = entry.appearanceID
    if not id then return end
    local trackType = Enum and Enum.ContentTrackingType and Enum.ContentTrackingType.Appearance
    if trackType and C_SuperTrack and C_SuperTrack.GetSuperTrackedContent then
        local ok, curType, curId = pcall(C_SuperTrack.GetSuperTrackedContent)
        if ok and curType == trackType and curId == id then
            AppearanceClearFocusOnly()
            return
        end
    end
    AppearanceStopTracking(id)
end

APPEARANCE_ACTIONS["contextMenu"] = function(entry)
    if entry.appearanceID then
        ShowAppearanceContextMenu(entry.appearanceID, entry)
    end
end

APPEARANCE_ACTIONS["share"] = function(_)
    local printFn = addon.HSPrint or print
    local L = addon.L or {}
    printFn("|cffffcc00" .. (L["OPTIONS_FOCUS_APPEARANCE_CANNOT_SHARE"] or "Appearances cannot be shared like quests.") .. "|r")
end

APPEARANCE_ACTIONS["abandon"] = function(entry)
    if entry.appearanceID then
        AppearanceStopTracking(entry.appearanceID)
    end
end

APPEARANCE_ACTIONS["wowhear"] = function(entry)
    local url = addon.GetWoWheadURL and addon.GetWoWheadURL(entry)
    if url and type(url) == "string" and url ~= "" then
        if addon.ShowURLCopyBox then addon.ShowURLCopyBox(url) end
    end
end

APPEARANCE_ACTIONS["chatLink"] = function(entry)
    if ChatFrameUtil and ChatFrameUtil.GetActiveWindow and ChatFrameUtil.GetActiveWindow() and ChatFrameUtil.InsertLink then
        local link = GetAppearanceDressLink(entry)
        if link then ChatFrameUtil.InsertLink(link) end
    end
end

APPEARANCE_ACTIONS["none"] = function(_) end

--- Execute a named appearance-row action on a pool entry.
--- @param action string
--- @param entry Frame pool entry
local function ExecuteAppearanceAction(action, entry)
    local fn = action and APPEARANCE_ACTIONS[action]
    if not fn then
        fn = APPEARANCE_ACTIONS["none"]
    end
    fn(entry)
end

-- Log resolved click action when /h debug focus clickdebug is on.
local function MaybeLogQuestClickDispatch(buttonName, profile, clickModsTbl, action, questID, note)
    if not (addon.focus and addon.focus.clickDispatchDebug) then return end
    local printFn = addon.HSPrint or print
    local combo = addon.focus.GetQuestClickComboKey and addon.focus.GetQuestClickComboKey(buttonName, clickModsTbl) or "?"
    local prof = profile
    if prof == nil then prof = addon.GetDB("focusClickProfile", "blizzardDefault") end
    printFn(("[Horizon Focus click] profile=%s combo=%s action=%s questID=%s %s"):format(
        tostring(prof), tostring(combo), tostring(action), tostring(questID), note or ""))
end

local function MaybeLogAppearanceClickDispatch(buttonName, profile, clickModsTbl, action, appearanceID, note)
    if not (addon.focus and addon.focus.clickDispatchDebug) then return end
    local printFn = addon.HSPrint or print
    local combo = addon.focus.GetQuestClickComboKey and addon.focus.GetQuestClickComboKey(buttonName, clickModsTbl) or "?"
    local prof = profile
    if prof == nil then prof = addon.GetDB("focusClickProfile", "blizzardDefault") end
    printFn(("[Horizon Focus click] profile=%s combo=%s action=%s appearanceID=%s %s"):format(
        tostring(prof), tostring(combo), tostring(action), tostring(appearanceID), note or ""))
end

--- Execute a named quest action on a pool entry.
--- @param action string Action key (e.g. "superTrack", "untrack")
--- @param entry Frame pool entry (self from OnMouseDown)
local function ExecuteQuestAction(action, entry)
    local fn = action and QUEST_ACTIONS[action]
    if not fn then
        fn = QUEST_ACTIONS["none"]
    end
    fn(entry)
end

-- Reused per click to avoid per-click table allocation.
local clickMods = { shift = false, ctrl = false, alt = false }

for i = 1, addon.POOL_SIZE do
    local e = pool[i]
    e:EnableMouse(true)

    e:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            -- Shift+click to link in chat (native WoW behavior). Must run before any other click handling.
            if IsModifiedClick("CHATLINK") and ChatFrameUtil and ChatFrameUtil.GetActiveWindow and ChatFrameUtil.GetActiveWindow() and ChatFrameUtil.InsertLink then
                if self.questID and GetQuestLink then
                    local link = GetQuestLink(self.questID)
                    if link then ChatFrameUtil.InsertLink(link); return end
                end
                if self.achievementID and GetAchievementLink then
                    local link = GetAchievementLink(self.achievementID)
                    if link then ChatFrameUtil.InsertLink(link); return end
                end
                if self.endeavorID and C_NeighborhoodInitiative and C_NeighborhoodInitiative.GetInitiativeTaskChatLink then
                    local ok, link = pcall(C_NeighborhoodInitiative.GetInitiativeTaskChatLink, self.endeavorID)
                    if ok and link and type(link) == "string" and link ~= "" then ChatFrameUtil.InsertLink(link); return end
                end
                if self.recipeID and C_TradeSkillUI and C_TradeSkillUI.GetRecipeInfo then
                    local ok, info = pcall(C_TradeSkillUI.GetRecipeInfo, self.recipeID)
                    if ok and info and type(info) == "table" and info.hyperlink then ChatFrameUtil.InsertLink(info.hyperlink); return end
                end
                if self.adventureGuideID and C_PerksActivities and C_PerksActivities.GetPerksActivityChatLink then
                    local ok, link = pcall(C_PerksActivities.GetPerksActivityChatLink, self.adventureGuideID)
                    if ok and link and type(link) == "string" and link ~= "" then ChatFrameUtil.InsertLink(link); return end
                end
                if self.appearanceID and self.entryKey and self.entryKey:match("^appearance:%d+$") then
                    local dressLink = GetAppearanceDressLink(self)
                    if dressLink then ChatFrameUtil.InsertLink(dressLink); return end
                end
            end
            -- Tracked appearance: same profile system as quests (Horizon+ / Blizzard+ / Custom); icon delegates when UseBlizzardStyleQuestIconClicks.
            local isAppearanceRow = self.appearanceID and self.entryKey and self.entryKey:match("^appearance:%d+$")
            if isAppearanceRow and addon.focus and addon.focus.GetAppearanceClickAction then
                if addon.focus.UseBlizzardStyleQuestIconClicks and addon.focus.UseBlizzardStyleQuestIconClicks() then
                    if self.questIconBtn and self.questIconBtn:IsVisible() and self.questIconBtn:IsMouseOver() then
                        if addon.HandleClassicAppearanceIconMouseDown then addon.HandleClassicAppearanceIconMouseDown(self) end
                        return
                    end
                    -- Ctrl+left on row body: match icon behaviour (dressing room); icon handler only runs when over questIconBtn.
                    if IsControlKeyDown() and not IsShiftKeyDown() and not IsAltKeyDown() then
                        AppearanceOpenDressingRoom(self)
                        return
                    end
                end
                local profileAppearance = addon.GetDB("focusClickProfile", "blizzardDefault")
                clickMods.shift = IsShiftKeyDown()
                clickMods.ctrl  = IsControlKeyDown()
                clickMods.alt   = IsAltKeyDown()
                if addon.GetDB("requireCtrlForQuestClicks", false) and not clickMods.ctrl then
                    MaybeLogAppearanceClickDispatch("LeftButton", profileAppearance, clickMods, "(blocked: requireCtrl)", self.appearanceID, "")
                    return
                end
                local actionAppearance = addon.focus.GetAppearanceClickAction("LeftButton", clickMods, profileAppearance)
                MaybeLogAppearanceClickDispatch("LeftButton", profileAppearance, clickMods, actionAppearance, self.appearanceID, "")
                ExecuteAppearanceAction(actionAppearance, self)
                return
            end
            -- Alt+LeftClick: show WoWhead URL in the copy box so the user can Ctrl+C and paste in a browser.
            if IsAltKeyDown() then
                local url = addon.GetWoWheadURL(self)
                if url and type(url) == "string" and url ~= "" then
                    if addon.ShowURLCopyBox then addon.ShowURLCopyBox(url) end
                    return
                end
            end
            if self.entryKey then
                local trackedKind = ResolveTrackedContentKind(self)
                if trackedKind and addon.focus.UseBlizzardStyleQuestIconClicks and addon.focus.UseBlizzardStyleQuestIconClicks() then
                    if trackedKind == "decor" then
                        if IsControlKeyDown() and not IsShiftKeyDown() and not IsAltKeyDown() then
                            DecorOpenMap(self)
                            return
                        end
                        if IsAltKeyDown() and not IsShiftKeyDown() and not IsControlKeyDown() then
                            DecorPreview(self)
                            return
                        end
                    end
                    local profileTC = addon.GetDB("focusClickProfile", "blizzardDefault")
                    clickMods.shift = IsShiftKeyDown()
                    clickMods.ctrl = IsControlKeyDown()
                    clickMods.alt = IsAltKeyDown()
                    if addon.GetDB("requireCtrlForQuestClicks", false) and not clickMods.ctrl then
                        MaybeLogTrackedContentDispatch("LeftButton", profileTC, clickMods, "(blocked: requireCtrl)", trackedKind, "")
                        return
                    end
                    local actionTC = addon.focus.GetQuestClickAction("LeftButton", clickMods, profileTC)
                    MaybeLogTrackedContentDispatch("LeftButton", profileTC, clickMods, actionTC, trackedKind, "")
                    ExecuteTrackedContentAction(actionTC, trackedKind, self)
                    return
                end
                local achID = self.entryKey:match("^ach:(%d+)$")
                if achID and self.achievementID then
                    local requireCtrl = addon.GetDB("requireCtrlForQuestClicks", false)
                    if requireCtrl and not IsControlKeyDown() then return end
                    if addon.OpenAchievementToAchievement then
                        addon.OpenAchievementToAchievement(self.achievementID)
                    end
                    return
                end
                local endID = self.entryKey:match("^endeavor:(%d+)$")
                if endID and self.endeavorID then
                    local requireCtrl = addon.GetDB("requireCtrlForQuestClicks", false)
                    if requireCtrl and not IsControlKeyDown() then return end
                    if HousingFramesUtil and HousingFramesUtil.OpenFrameToTaskID then
                        pcall(HousingFramesUtil.OpenFrameToTaskID, self.endeavorID)
                    elseif ToggleHousingDashboard then
                        ToggleHousingDashboard()
                    elseif HousingFrame and HousingFrame.Show then
                        if HousingFrame:IsShown() then HousingFrame:Hide() else HousingFrame:Show() end
                    end
                    return
                end
                local decorID = self.entryKey:match("^decor:(%d+)$")
                if decorID and self.decorID then
                    local requireCtrl = addon.GetDB("requireCtrlForQuestClicks", false)
                    if requireCtrl and not IsControlKeyDown() then return end
                    if IsShiftKeyDown() then
                        if InCombatLockdown() then return end
                        local trackTypeDecor = (Enum and Enum.ContentTrackingType and Enum.ContentTrackingType.Decor) or 3
                        if ContentTrackingUtil and ContentTrackingUtil.OpenMapToTrackable then
                            pcall(ContentTrackingUtil.OpenMapToTrackable, trackTypeDecor, self.decorID)
                        end
                    elseif IsAltKeyDown() then
                        if HousingFramesUtil and HousingFramesUtil.PreviewHousingDecorID then
                            pcall(HousingFramesUtil.PreviewHousingDecorID, self.decorID)
                        elseif ToggleHousingDashboard then
                            ToggleHousingDashboard()
                        elseif HousingFrame and HousingFrame.Show then
                            if HousingFrame:IsShown() then HousingFrame:Hide() else HousingFrame:Show() end
                        end
                    else
                        if not HousingDashboardFrame and C_AddOns and C_AddOns.LoadAddOn then
                            pcall(C_AddOns.LoadAddOn, "Blizzard_HousingDashboard")
                        end
                        local entryType = (Enum and Enum.HousingCatalogEntryType and Enum.HousingCatalogEntryType.Decor) or 1
                        local ok, info = pcall(function()
                            if C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByRecordID then
                                return C_HousingCatalog.GetCatalogEntryInfoByRecordID(entryType, self.decorID, true)
                            end
                        end)
                        if ok and info and HousingDashboardFrame and HousingDashboardFrame.SetTab and HousingDashboardFrame.catalogTab then
                            ShowUIPanel(HousingDashboardFrame)
                            HousingDashboardFrame:SetTab(HousingDashboardFrame.catalogTab)
                            if C_Timer and C_Timer.After then
                                C_Timer.After(0.5, function()
                                    if HousingDashboardFrame and HousingDashboardFrame.CatalogContent and HousingDashboardFrame.CatalogContent.PreviewFrame then
                                        local pf = HousingDashboardFrame.CatalogContent.PreviewFrame
                                        if pf.PreviewCatalogEntryInfo then
                                            pcall(pf.PreviewCatalogEntryInfo, pf, info)
                                        end
                                        if pf.Show then pf:Show() end
                                    end
                                end)
                            end
                        elseif ToggleHousingDashboard then
                            ToggleHousingDashboard()
                        elseif HousingFrame and HousingFrame.Show then
                            if HousingFrame:IsShown() then HousingFrame:Hide() else HousingFrame:Show() end
                        end
                    end
                    return
                end
                local advMatch = self.entryKey:match("^advguide:")
                if advMatch and self.adventureGuideID then
                    local requireCtrl = addon.GetDB("requireCtrlForQuestClicks", false)
                    if requireCtrl and not IsControlKeyDown() then return end
                    -- Open the Adventure Guide / Encounter Journal to the Traveler's Log tab
                    if ToggleEncounterJournal then
                        ToggleEncounterJournal()
                    end
                    return
                end
                if self.isRecipe and self.recipeID then
                    local requireCtrl = addon.GetDB("requireCtrlForQuestClicks", false)
                    if requireCtrl and not IsControlKeyDown() then return end
                    OpenRecipeByID(self.recipeID, self.recipeIsRecraft == true)
                    return
                end
                local vignetteGUID = self.entryKey:match("^vignette:(.+)$")
                local rareCreatureID = self.entryKey:match("^rare:(%d+)$")
                local isRareOrRareLoot = self.isRare or self.isRareLoot or self.category == "RARE" or self.category == "RARE_LOOT"
                if (vignetteGUID or rareCreatureID) and isRareOrRareLoot then
                    if addon.GetDB("tomtomRareWaypoint", true) then
                        if addon.SetRareWaypoint then
                            addon.SetRareWaypoint(self)
                        end
                    elseif vignetteGUID and C_SuperTrack and C_SuperTrack.SetSuperTrackedVignette then
                        C_SuperTrack.SetSuperTrackedVignette(vignetteGUID)
                    end
                    local wqtPanel = _G.WorldQuestTrackerScreenPanel
                    if wqtPanel and wqtPanel:IsShown() then
                        wqtPanel:Hide()
                    end
                    return
                end
            end
            if not self.questID then return end

            -- Classic icon click: delegate to icon handler (runs before all other quest logic).
            local profile = addon.GetDB("focusClickProfile", "blizzardDefault")
            local isClassicProfile = (profile == "blizzardDefault")
            if isClassicProfile then
                if self.questIconBtn and self.questIconBtn:IsVisible() and self.questIconBtn:IsMouseOver() then
                    if addon.HandleClassicQuestIconMouseDown then
                        addon.HandleClassicQuestIconMouseDown(self)
                    end
                    return
                end
            end

            -- Auto-complete always takes priority regardless of profile.
            if not IsShiftKeyDown() then
                local needMod = addon.GetDB("requireModifierForClickToComplete", false)
                if (not needMod or IsControlKeyDown()) and self.isAutoComplete and TryCompleteQuestFromClick(self.questID) then
                    return
                end
            end

            clickMods.shift = IsShiftKeyDown()
            clickMods.ctrl  = IsControlKeyDown()
            clickMods.alt   = IsAltKeyDown()
            -- Safety guard: require Ctrl when option is on.
            if addon.GetDB("requireCtrlForQuestClicks", false) and not clickMods.ctrl then
                MaybeLogQuestClickDispatch("LeftButton", profile, clickMods, "(blocked: requireCtrl)", self.questID, "")
                return
            end
            local action = addon.focus.GetQuestClickAction("LeftButton", clickMods, profile)
            MaybeLogQuestClickDispatch("LeftButton", profile, clickMods, action, self.questID, "")
            ExecuteQuestAction(action, self)
        elseif button == "RightButton" then
            local isAppearanceRowRight = self.appearanceID and self.entryKey and self.entryKey:match("^appearance:%d+$")
            if isAppearanceRowRight and addon.focus and addon.focus.GetAppearanceClickAction then
                local profileAppRight = addon.GetDB("focusClickProfile", "blizzardDefault")
                clickMods.shift = IsShiftKeyDown()
                clickMods.ctrl  = IsControlKeyDown()
                clickMods.alt   = IsAltKeyDown()
                if addon.GetDB("requireCtrlForQuestClicks", false) and not clickMods.ctrl then
                    MaybeLogAppearanceClickDispatch("RightButton", profileAppRight, clickMods, "(blocked: requireCtrl)", self.appearanceID, "")
                    return
                end
                local actionAppRight = addon.focus.GetAppearanceClickAction("RightButton", clickMods, profileAppRight)
                MaybeLogAppearanceClickDispatch("RightButton", profileAppRight, clickMods, actionAppRight, self.appearanceID, "")
                ExecuteAppearanceAction(actionAppRight, self)
                return
            end
            if self.entryKey then
                local trackedKindRight = ResolveTrackedContentKind(self)
                if trackedKindRight and addon.focus.UseBlizzardStyleQuestIconClicks and addon.focus.UseBlizzardStyleQuestIconClicks() then
                    local profileTCR = addon.GetDB("focusClickProfile", "blizzardDefault")
                    clickMods.shift = IsShiftKeyDown()
                    clickMods.ctrl = IsControlKeyDown()
                    clickMods.alt = IsAltKeyDown()
                    if addon.GetDB("requireCtrlForQuestClicks", false) and not clickMods.ctrl then
                        MaybeLogTrackedContentDispatch("RightButton", profileTCR, clickMods, "(blocked: requireCtrl)", trackedKindRight, "")
                        return
                    end
                    local actionTCR = addon.focus.GetQuestClickAction("RightButton", clickMods, profileTCR)
                    MaybeLogTrackedContentDispatch("RightButton", profileTCR, clickMods, actionTCR, trackedKindRight, "")
                    ExecuteTrackedContentAction(actionTCR, trackedKindRight, self)
                    return
                end
                local achID = self.entryKey:match("^ach:(%d+)$")
                if achID and self.achievementID then
                    local requireCtrl = addon.GetDB("requireCtrlForQuestClicks", false)
                    if requireCtrl and not IsControlKeyDown() then return end
                    local trackType = (Enum and Enum.ContentTrackingType and Enum.ContentTrackingType.Achievement) or 2
                    local stopType = (Enum and Enum.ContentTrackingStopType and Enum.ContentTrackingStopType.Manual) or 0
                    if C_ContentTracking and C_ContentTracking.StopTracking then
                        C_ContentTracking.StopTracking(trackType, self.achievementID, stopType)
                    elseif RemoveTrackedAchievement then
                        RemoveTrackedAchievement(self.achievementID)
                    end
                    addon.ScheduleRefresh()
                    return
                end
                local endID = self.entryKey:match("^endeavor:(%d+)$")
                if endID and self.endeavorID then
                    local requireCtrl = addon.GetDB("requireCtrlForQuestClicks", false)
                    if requireCtrl and not IsControlKeyDown() then return end
                    if C_NeighborhoodInitiative and C_NeighborhoodInitiative.RemoveTrackedInitiativeTask then
                        pcall(C_NeighborhoodInitiative.RemoveTrackedInitiativeTask, self.endeavorID)
                    elseif C_Endeavors and C_Endeavors.StopTracking then
                        pcall(C_Endeavors.StopTracking, self.endeavorID)
                    end
                    addon.ScheduleRefresh()
                    return
                end
                local decorID = self.entryKey:match("^decor:(%d+)$")
                if decorID and self.decorID then
                    local requireCtrl = addon.GetDB("requireCtrlForQuestClicks", false)
                    if requireCtrl and not IsControlKeyDown() then return end
                    local trackTypeDecor = (Enum and Enum.ContentTrackingType and Enum.ContentTrackingType.Decor) or 3
                    local stopType = (Enum and Enum.ContentTrackingStopType and Enum.ContentTrackingStopType.Manual) or 0
                    if C_ContentTracking and C_ContentTracking.StopTracking then
                        pcall(C_ContentTracking.StopTracking, trackTypeDecor, self.decorID, stopType)
                    end
                    addon.ScheduleRefresh()
                    return
                end
                local advMatch = self.entryKey:match("^advguide:")
                if advMatch and self.adventureGuideID then
                    local requireCtrl = addon.GetDB("requireCtrlForQuestClicks", false)
                    if requireCtrl and not IsControlKeyDown() then return end
                    if C_PerksActivities and C_PerksActivities.RemoveTrackedPerksActivity then
                        pcall(C_PerksActivities.RemoveTrackedPerksActivity, self.adventureGuideID)
                    end
                    addon.ScheduleRefresh()
                    return
                end
                local vignetteGUID = self.entryKey:match("^vignette:(.+)$")
                if vignetteGUID and C_SuperTrack and C_SuperTrack.GetSuperTrackedVignette then
                    if C_SuperTrack.GetSuperTrackedVignette() == vignetteGUID then
                        C_SuperTrack.SetSuperTrackedVignette(nil)
                        local wqtPanel = _G.WorldQuestTrackerScreenPanel
                        if wqtPanel and wqtPanel:IsShown() then
                            wqtPanel:Hide()
                        end
                    end
                end
                if self.isRecipe and self.recipeID then
                    local requireCtrl = addon.GetDB("requireCtrlForQuestClicks", false)
                    if requireCtrl and not IsControlKeyDown() then return end
                    if C_AddOns and C_AddOns.LoadAddOn then
                        pcall(C_AddOns.LoadAddOn, "Blizzard_Professions")
                    end
                    if C_TradeSkillUI and C_TradeSkillUI.SetRecipeTracked then
                        local isRecraft = (self.recipeIsRecraft == true)
                        pcall(C_TradeSkillUI.SetRecipeTracked, self.recipeID, false, isRecraft)
                    end
                    addon.ScheduleRefresh()
                    return
                end
                return
            end
            if self.questID then
                -- Shift+Right: abandon non-world quests unconditionally (destructive — kept outside profile system).
                if IsShiftKeyDown() then
                    if not (addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(self.questID)) then
                        local questName = (C_QuestLog and C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(self.questID)) or "this quest"
                        StaticPopup_Show("HORIZONSUITE_ABANDON_QUEST", questName, nil, { questID = self.questID })
                        return
                    end
                end

                clickMods.shift = IsShiftKeyDown()
                clickMods.ctrl  = IsControlKeyDown()
                clickMods.alt   = IsAltKeyDown()
                -- Safety guard: require Ctrl when option is on.
                if addon.GetDB("requireCtrlForQuestClicks", false) and not clickMods.ctrl then
                    MaybeLogQuestClickDispatch("RightButton", nil, clickMods, "(blocked: requireCtrl)", self.questID, "")
                    return
                end
                local action = addon.focus.GetQuestClickAction("RightButton", clickMods)
                MaybeLogQuestClickDispatch("RightButton", nil, clickMods, action, self.questID, "")
                ExecuteQuestAction(action, self)
            end
        end
    end)

    e:SetScript("OnEnter", function(self)
        if not self.questID and not self.entryKey then return end
        local r, g, b, a = self.titleText:GetTextColor()
        local base = { r, g, b, a or 1 }
        local bright = { math.min(r * 1.25, 1), math.min(g * 1.25, 1), math.min(b * 1.25, 1), 1 }
        self._savedColor = { r, g, b }
        if addon.GetDB("animations", true) and addon.EnsureFocusUpdateRunning then
            self.hoverAnimState = "in"
            self.hoverAnimTime = 0
            self._hoverFromColor = base
            self._hoverToColor = bright
            addon.EnsureFocusUpdateRunning()
        else
            self.titleText:SetTextColor(bright[1], bright[2], bright[3], 1)
        end
        local showTooltip = addon.GetDB("focusShowTooltipOnHover", false)
            or (addon.GetDB("showDelveAffixes", true) and (self.tierSpellID or (self.affixData and #self.affixData > 0)))
        if not showTooltip then return end
        if self.creatureID then
            local link = ("unit:Creature-0-0-0-0-%d-0000000000"):format(self.creatureID)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            pcall(GameTooltip.SetHyperlink, GameTooltip, link)
            local att = _G.AllTheThings
            if att and att.Modules and att.Modules.Tooltip then
                local attach = att.Modules.Tooltip.AttachTooltipSearchResults
                local searchFn = att.SearchForObject or att.SearchForField
                if attach and searchFn then
                    pcall(attach, GameTooltip, searchFn, "npcID", self.creatureID)
                end
            end
            AppendWoWheadLineToTooltip(self)
            GameTooltip:Show()
        elseif self.endeavorID then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            local endeavorColor = (addon.GetQuestColor and addon.GetQuestColor("ENDEAVOR")) or (addon.QUEST_COLORS and addon.QUEST_COLORS.ENDEAVOR) or { 0.45, 0.95, 0.75 }
            local ecR, ecG, ecB = endeavorColor[1], endeavorColor[2], endeavorColor[3]
            local greyR, greyG, greyB = 0.7, 0.7, 0.7
            local whiteR, whiteG, whiteB = 0.9, 0.9, 0.9
            local doneR, doneG, doneB = 0.5, 0.8, 0.5

            local ok, info = pcall(function()
                return C_NeighborhoodInitiative and C_NeighborhoodInitiative.GetInitiativeTaskInfo and C_NeighborhoodInitiative.GetInitiativeTaskInfo(self.endeavorID)
            end)
            if ok and info and type(info) == "table" then
                local title = info.taskName or self.titleText:GetText() or ("Endeavor #" .. tostring(self.endeavorID))
                local isRepeatable = (Enum and Enum.NeighborhoodInitiativeTaskType and info.taskType == Enum.NeighborhoodInitiativeTaskType.RepeatableInfinite)
                if isRepeatable and info.timesCompleted and info.timesCompleted > 0 and _G.HOUSING_DASHBOARD_REPEATABLE_TASK_TITLE_TOOLTIP_FORMAT then
                    title = _G.HOUSING_DASHBOARD_REPEATABLE_TASK_TITLE_TOOLTIP_FORMAT:format(info.taskName or title, info.timesCompleted)
                end
                GameTooltip:AddLine(title, ecR, ecG, ecB)
                if isRepeatable and _G.HOUSING_ENDEAVOR_REPEATABLE_TASK then
                    GameTooltip:AddLine(_G.HOUSING_ENDEAVOR_REPEATABLE_TASK, greyR, greyG, greyB)
                end
                GameTooltip:AddLine(" ")
                if info.description and type(info.description) == "string" and info.description ~= "" then
                    GameTooltip:AddLine(info.description, 1, 1, 1, true)
                    GameTooltip:AddLine(" ")
                end
                local reqHeader = _G.REQUIREMENTS or "Requirements:"
                GameTooltip:AddLine(reqHeader, greyR, greyG, greyB)
                if info.requirementsList and type(info.requirementsList) == "table" then
                    for _, req in ipairs(info.requirementsList) do
                        local text = (type(req) == "table" and req.requirementText) or tostring(req)
                        if text and text ~= "" then
                            text = text:gsub(" / ", "/")
                            local r, g, b = whiteR, whiteG, whiteB
                            if type(req) == "table" and req.completed then r, g, b = doneR, doneG, doneB end
                            GameTooltip:AddLine("  " .. text, r, g, b)
                        end
                    end
                end
                -- Resolve contribution/XP amount (GetInitiativeTaskInfo uses progressContributionAmount for housing/neighborhood favor).
                local contributionAmount = (info.progressContributionAmount and type(info.progressContributionAmount) == "number") and info.progressContributionAmount
                    or (info.thresholdContributionAmount and type(info.thresholdContributionAmount) == "number") and info.thresholdContributionAmount
                    or (info.contributionAmount and type(info.contributionAmount) == "number") and info.contributionAmount
                    or nil
                if not (contributionAmount and contributionAmount > 0) then
                    for k, v in pairs(info) do
                        if type(k) == "string" and type(v) == "number" and v > 0 then
                            local lower = k:lower()
                            if lower:find("contribution") or lower:find("favor") or lower:find("reward") and lower:find("amount") or lower:find("threshold") or lower:find("xp") or (lower:find("amount") and not lower:find("completed")) then
                                contributionAmount = v
                                break
                            end
                        end
                    end
                end
                local hasContribution = contributionAmount and contributionAmount > 0
                local hasQuestReward = info.rewardQuestID and addon.AddQuestRewardsToTooltip
                if hasContribution or hasQuestReward then
                    GameTooltip:AddLine(" ")
                    local rewardsHeader = _G.REWARDS or "Rewards:"
                    GameTooltip:AddLine(rewardsHeader, greyR, greyG, greyB)
                    if hasContribution then
                        local amountStr = (type(FormatLargeNumber) == "function" and FormatLargeNumber(contributionAmount)) or tostring(contributionAmount)
                        local favorLabel = _G.HOUSING_ENDEAVOR_REWARD_HOUSING_XP or _G.NEIGHBORHOOD_FAVOR_PROGRESS or "Housing XP"
                        -- Use the chevron XP icon and identical line format to currency rewards.
                        local xpTex = _G.HOUSING_XP_CURRENCY_ICON or _G.HOUSING_XP_ICON_FILE_ID or 894556
                        local iconStr = "|T" .. tostring(xpTex) .. ":0|t "
                        GameTooltip:AddLine(iconStr .. amountStr .. " " .. favorLabel, 1, 1, 1)
                    end
                    if hasQuestReward then
                        addon.AddQuestRewardsToTooltip(GameTooltip, info.rewardQuestID)
                    end
                end
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(("Endeavor #%s"):format(tostring(self.endeavorID)), greyR, greyG, greyB)
            else
                local title = self.titleText:GetText() or ("Endeavor #" .. tostring(self.endeavorID))
                GameTooltip:AddLine(title, ecR, ecG, ecB)
                GameTooltip:AddLine(("Endeavor #%s"):format(tostring(self.endeavorID)), greyR, greyG, greyB)
                if addon.GetEndeavorDisplayInfo then
                    local getOk, name, _, objectives = pcall(addon.GetEndeavorDisplayInfo, self.endeavorID)
                    if getOk and objectives and type(objectives) == "table" and #objectives > 0 then
                        GameTooltip:AddLine(" ")
                        for _, obj in ipairs(objectives) do
                            local text = (type(obj) == "table" and obj.text) or tostring(obj)
                            if text and text ~= "" then
                                local r, g, b = whiteR, whiteG, whiteB
                                if type(obj) == "table" and obj.finished then r, g, b = doneR, doneG, doneB end
                                GameTooltip:AddLine("  " .. text, r, g, b)
                            end
                        end
                    end
                end
            end
            if not GameTooltip:NumLines() or GameTooltip:NumLines() == 0 then
                GameTooltip:SetText(self.titleText:GetText() or ("Endeavor #" .. tostring(self.endeavorID)))
            end
            AppendWoWheadLineToTooltip(self)
            GameTooltip:Show()
        elseif self.decorID then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.titleText:GetText() or "")
            GameTooltip:AddLine(("Decor #%d"):format(self.decorID), 0.7, 0.7, 0.7)
            AppendWoWheadLineToTooltip(self)
            GameTooltip:Show()
        elseif self.appearanceID then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local link = self.appearanceItemLink
            if link and type(link) == "string" and link ~= "" and GameTooltip.SetHyperlink then
                local ok = pcall(GameTooltip.SetHyperlink, GameTooltip, link)
                if not ok then
                    GameTooltip:SetText(self.titleText:GetText() or "")
                    GameTooltip:AddLine(("Appearance #%s"):format(tostring(self.appearanceID)), 0.7, 0.7, 0.7)
                end
            else
                GameTooltip:SetText(self.titleText:GetText() or "")
                GameTooltip:AddLine(("Appearance #%s"):format(tostring(self.appearanceID)), 0.7, 0.7, 0.7)
            end
            AppendWoWheadLineToTooltip(self)
            GameTooltip:Show()
        elseif self.achievementID and GetAchievementLink then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local link = GetAchievementLink(self.achievementID)
            if link then
                pcall(GameTooltip.SetHyperlink, GameTooltip, link)
            else
                GameTooltip:SetText(self.titleText:GetText() or "")
            end
            AppendWoWheadLineToTooltip(self)
            GameTooltip:Show()
        elseif self.questID then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            pcall(GameTooltip.SetHyperlink, GameTooltip, "quest:" .. self.questID)
            addon.AddQuestRewardsToTooltip(GameTooltip, self.questID)
            addon.AddQuestPartyProgressToTooltip(GameTooltip, self.questID)
            AppendDelveTooltipData(self, GameTooltip)
            AppendWoWheadLineToTooltip(self)
            GameTooltip:Show()
        elseif self.entryKey then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.titleText:GetText() or "")
            AppendDelveTooltipData(self, GameTooltip)
            AppendWoWheadLineToTooltip(self)
            GameTooltip:Show()
        end
    end)

    e:SetScript("OnLeave", function(self)
        if addon.GetDB("animations", true) and addon.EnsureFocusUpdateRunning then
            local sc = self._savedColor
            if sc then
                self.hoverAnimState = "out"
                self.hoverAnimTime = 0
                local r, g, b, a = self.titleText:GetTextColor()
                self._hoverFromColor = { r, g, b, a or 1 }
                self._hoverToColor = { sc[1], sc[2], sc[3], 1 }
                addon.EnsureFocusUpdateRunning()
            end
        elseif self._savedColor then
            local sc = self._savedColor
            self.titleText:SetTextColor(sc[1], sc[2], sc[3], 1)
            self._savedColor = nil
        end
        if GameTooltip:GetOwner() == self then
            GameTooltip:Hide()
        end
    end)

    e:EnableMouseWheel(true)
    e:SetScript("OnMouseWheel", function(_, delta) addon.HandleScroll(delta) end)
end
