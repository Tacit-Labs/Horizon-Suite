--[[
    Horizon Suite - Focus - Interactions
    Mouse scripts on pool entries (click, tooltip, scroll).
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- INTERACTIONS
-- ============================================================================

local pool = addon.pool

--- Append a WoWhead link line to GameTooltip when option is on and entry has a known URL.
--- @param entry table Pool entry (self) with questID, achievementID, and/or creatureID
local function AppendWoWheadLineToTooltip(entry)
    if not addon.GetDB("focusShowWoWheadLink", true) then return end
    local url = addon.GetWoWheadURL(entry)
    if not url then return end
    local text = (addon.L and addon.L["OPTIONS_FOCUS_VIEW_WOWHEAD"]) or "View on WoWhead"
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(("|cff00b4ff|Hurl:%s|h[%s]|h|r"):format(url, text), 0.4, 0.7, 1)
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

-- ============================================================================
-- QUEST WAYPOINT (TomTom / native)
-- ============================================================================

local activeQuestWaypointUID

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

--- Place a waypoint for a quest (TomTom or native). When keepQuestSuperTracked is true,
--- do not call SetSuperTrackedUserWaypoint so the quest remains the super-track target
--- (blue highlight in Focus, yellow in Blizzard quest log).
--- @param questID number
--- @param keepQuestSuperTracked boolean|nil If true, do not override quest super-track with user waypoint
local function SetQuestWaypoint(questID, keepQuestSuperTracked)
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

local function ClearQuestWaypoint()
    if not activeQuestWaypointUID then return end
    local TomTom = _G.TomTom
    if TomTom and TomTom.RemoveWaypoint then
        pcall(TomTom.RemoveWaypoint, TomTom, activeQuestWaypointUID)
    end
    activeQuestWaypointUID = nil
end

addon.SetQuestWaypoint = SetQuestWaypoint
addon.ClearQuestWaypoint = ClearQuestWaypoint

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
                    local recipeID = self.recipeID
                    -- ProfessionsUtil opens profession frame + navigates to recipe (works when closed)
                    if C_AddOns and C_AddOns.LoadAddOn then
                        pcall(C_AddOns.LoadAddOn, "Blizzard_Professions")
                    end
                    if ProfessionsUtil and ProfessionsUtil.OpenProfessionFrameToRecipe then
                        pcall(ProfessionsUtil.OpenProfessionFrameToRecipe, recipeID)
                    elseif C_TradeSkillUI and C_TradeSkillUI.OpenRecipe then
                        -- Fallback: only works when profession window is already open
                        pcall(C_TradeSkillUI.OpenRecipe, recipeID)
                    end
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

            local useClassic = addon.GetDB("useClassicClickBehaviour", false)
            if useClassic then
                -- Shift+Left: unfocus and/or untrack (same as right-click in Modern mode).
                if IsShiftKeyDown() then
                    if C_SuperTrack and C_SuperTrack.GetSuperTrackedQuestID and C_SuperTrack.SetSuperTrackedQuestID then
                        local focusedQuestID = C_SuperTrack.GetSuperTrackedQuestID()
                        if focusedQuestID and focusedQuestID == self.questID then
                            C_SuperTrack.SetSuperTrackedQuestID(0)
                            if addon.ClearQuestWaypoint then addon.ClearQuestWaypoint() end
                            local wqtPanel = _G.WorldQuestTrackerScreenPanel
                            if wqtPanel and wqtPanel:IsShown() then
                                wqtPanel:Hide()
                            end
                            if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                            return
                        end
                    end
                    local usePermanent = addon.GetDB("permanentlySuppressUntracked", false)
                    if addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(self.questID) and addon.RemoveWorldQuestWatch then
                        addon.RemoveWorldQuestWatch(self.questID)
                        if usePermanent then
                            local bl = addon.GetDB("permanentQuestBlacklist", nil)
                            if type(bl) ~= "table" then bl = {} end
                            bl[self.questID] = true
                            addon.SetDB("permanentQuestBlacklist", bl)
                            if addon.RefreshBlacklistGrid then addon.RefreshBlacklistGrid() end
                        else
                            if not addon.focus.recentlyUntrackedWorldQuests then addon.focus.recentlyUntrackedWorldQuests = {} end
                            addon.focus.recentlyUntrackedWorldQuests[self.questID] = true
                            if addon.GetDB("suppressUntrackedUntilReload", false) then
                                addon.SetDB("sessionSuppressedQuests", addon.focus.recentlyUntrackedWorldQuests)
                            end
                        end
                    elseif C_QuestLog and C_QuestLog.RemoveQuestWatch then
                        C_QuestLog.RemoveQuestWatch(self.questID)
                    end
                    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                    return
                end
                -- If click was on the quest icon, handle super-track here (entry may receive click before child).
                if self.questIconBtn and self.questIconBtn:IsVisible() and self.questIconBtn:IsMouseOver() then
                    if C_SuperTrack and C_SuperTrack.SetSuperTrackedQuestID and C_SuperTrack.GetSuperTrackedQuestID then
                        local questID = self.questID
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
                    return
                end
                -- Click-to-complete takes priority: auto-complete quests can be completed by left-click.
                if not IsShiftKeyDown() then
                    local needMod = addon.GetDB("requireModifierForClickToComplete", false)
                    if (not needMod or IsControlKeyDown()) and self.isAutoComplete and TryCompleteQuestFromClick(self.questID) then
                        return
                    end
                end
                if addon.ToggleQuestDetails then
                    addon.ToggleQuestDetails(self.questID)
                elseif addon.OpenQuestDetails then
                    addon.OpenQuestDetails(self.questID)
                end
                return
            end

            local requireCtrl = addon.GetDB("requireCtrlForQuestClicks", false)
            local isWorldQuest = addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(self.questID)

            -- Plain Left (no Shift): try click-to-complete for auto-complete quests (Blizzard behavior).
            if not IsShiftKeyDown() then
                local needMod = addon.GetDB("requireModifierForClickToComplete", false)
                local isAutoComplete = self.isAutoComplete
                if (not needMod or IsControlKeyDown()) and isAutoComplete and TryCompleteQuestFromClick(self.questID) then
                    return
                end
            end

            -- Shift+Left: toggle quest log & map (open if closed, close if already showing this quest).
            if IsShiftKeyDown() then
                if isWorldQuest and C_QuestLog.AddWorldQuestWatch then
                    -- With safety enabled, adding to watch for world quests requires Ctrl+Shift+Left.
                    if not requireCtrl or IsControlKeyDown() then
                        C_QuestLog.AddWorldQuestWatch(self.questID)
                        addon.ScheduleRefresh()
                    end
                end
                if addon.ToggleQuestDetails then
                    addon.ToggleQuestDetails(self.questID)
                elseif addon.OpenQuestDetails then
                    addon.OpenQuestDetails(self.questID)
                end
                return
            end

            -- Non-world quests that are not yet tracked or not yet accepted: handle appropriately.
            if not isWorldQuest and self.isTracked == false then
                if requireCtrl and not IsControlKeyDown() then
                    -- Safety: ignore plain Left-click when Ctrl is required.
                    return
                end
                -- Check if quest is accepted (IsOnQuest is authoritative for campaign/available entries)
                local isAccepted = addon.IsQuestAccepted and addon.IsQuestAccepted(self.questID) or false
                if isAccepted then
                    -- Quest is accepted but not tracked: add to tracker and promote to super-tracked
                    if C_QuestLog.AddQuestWatch then
                        C_QuestLog.AddQuestWatch(self.questID)
                    end
                    if C_SuperTrack and C_SuperTrack.SetSuperTrackedQuestID then
                        C_SuperTrack.SetSuperTrackedQuestID(self.questID)
                    end
                    if addon.GetDB("tomtomQuestWaypoint", false) then
                        SetQuestWaypoint(self.questID, true)
                    end
                    local wqtPanel = _G.WorldQuestTrackerScreenPanel
                    if wqtPanel and wqtPanel:IsShown() then
                        wqtPanel:Hide()
                    end
                else
                    -- Quest not yet accepted: set waypoint to quest giver/start location
                    if C_SuperTrack and C_SuperTrack.SetSuperTrackedQuestID then
                        C_SuperTrack.SetSuperTrackedQuestID(self.questID)
                        local wqtPanel = _G.WorldQuestTrackerScreenPanel
                        if wqtPanel and wqtPanel:IsShown() then
                            wqtPanel:Hide()
                        end
                    end
                end
                addon.ScheduleRefresh()
                return
            end

            -- Left (no modifier): focus (set as super-tracked quest).
            -- If already focused, toggle focus off (clear super-track).
            if requireCtrl and not IsControlKeyDown() then
                -- Safety: ignore plain Left-click on quests when Ctrl is required.
                return
            end
            if C_SuperTrack and C_SuperTrack.SetSuperTrackedQuestID and C_SuperTrack.GetSuperTrackedQuestID then
                local currentFocused = C_SuperTrack.GetSuperTrackedQuestID()
                if currentFocused and currentFocused == self.questID then
                    C_SuperTrack.SetSuperTrackedQuestID(0)
                    if addon.GetDB("tomtomQuestWaypoint", false) then
                        ClearQuestWaypoint()
                    end
                    local wqtPanel = _G.WorldQuestTrackerScreenPanel
                    if wqtPanel and wqtPanel:IsShown() then
                        wqtPanel:Hide()
                    end
                    if addon.FullLayout then
                        addon.ScheduleRefresh()
                    end
                    return
                end
                C_SuperTrack.SetSuperTrackedQuestID(self.questID)
                if addon.GetDB("tomtomQuestWaypoint", false) then
                    SetQuestWaypoint(self.questID, true)
                end
                local wqtPanel = _G.WorldQuestTrackerScreenPanel
                if wqtPanel and wqtPanel:IsShown() then
                    wqtPanel:Hide()
                end
            end
            if addon.FullLayout then
                addon.ScheduleRefresh()
            end
        elseif button == "RightButton" then
            if self.entryKey then
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
                -- Shift+Right: abandon quest with confirmation (non-world quests only). For world quests, untrack instead.
                if IsShiftKeyDown() then
                    if not (addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(self.questID)) then
                        local questName = C_QuestLog.GetTitleForQuestID(self.questID) or "this quest"
                        StaticPopup_Show("HORIZONSUITE_ABANDON_QUEST", questName, nil, { questID = self.questID })
                        return
                    end
                end

                local useClassic = addon.GetDB("useClassicClickBehaviour", false)
                if useClassic then
                    local questName = (C_QuestLog and C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(self.questID)) or "this quest"
                    ShowQuestContextMenu(self.questID, questName, self)
                    return
                end

                -- Ctrl+Right: share with party (when pushable and in group; classic mode off). If not shareable, no-op + feedback.
                if IsControlKeyDown() then
                    local printFn = addon.HSPrint or print
                    local L = addon.L or {}
                    if C_QuestLog and C_QuestLog.IsPushableQuest and C_QuestLog.IsPushableQuest(self.questID) then
                        local inGroup = (GetNumGroupMembers and GetNumGroupMembers() > 1) or (UnitInParty and UnitInParty("player"))
                        if inGroup and C_QuestLog.SetSelectedQuest and QuestLogPushQuest then
                            C_QuestLog.SetSelectedQuest(self.questID)
                            QuestLogPushQuest()
                        else
                            printFn("|cffffcc00" .. (L["OPTIONS_FOCUS_YOU_MUST_A_PARTY_SHARE_QUEST"] or "You must be in a party to share this quest.") .. "|r")
                        end
                    else
                        printFn("|cffffcc00" .. (L["OPTIONS_FOCUS_QUEST_CANNOT_SHARED"] or "This quest cannot be shared.") .. "|r")
                    end
                    return
                end

                local requireCtrl = addon.GetDB("requireCtrlForQuestClicks", false)
                if requireCtrl and not IsControlKeyDown() then
                    -- Safety: ignore plain Right-click on quests when Ctrl is required.
                    return
                end

                -- Right (no modifier): if this quest is focused, unfocus only; otherwise untrack.
                if C_SuperTrack and C_SuperTrack.GetSuperTrackedQuestID and C_SuperTrack.SetSuperTrackedQuestID then
                    local focusedQuestID = C_SuperTrack.GetSuperTrackedQuestID()
                    if focusedQuestID and focusedQuestID == self.questID then
                        C_SuperTrack.SetSuperTrackedQuestID(0)
                        local wqtPanel = _G.WorldQuestTrackerScreenPanel
                        if wqtPanel and wqtPanel:IsShown() then
                            wqtPanel:Hide()
                        end
                        if addon.FullLayout then
                            addon.ScheduleRefresh()
                        end
                        return
                    end
                end

                local usePermanent = addon.GetDB("permanentlySuppressUntracked", false)
                
                if addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(self.questID) and addon.RemoveWorldQuestWatch then
                    addon.RemoveWorldQuestWatch(self.questID)
                    -- Add to suppression: permanent or temporary
                    if usePermanent then
                        local bl = addon.GetDB("permanentQuestBlacklist", nil)
                        if type(bl) ~= "table" then bl = {} end
                        bl[self.questID] = true
                        addon.SetDB("permanentQuestBlacklist", bl)
                        -- Trigger blacklist grid refresh
                        if addon.RefreshBlacklistGrid then addon.RefreshBlacklistGrid() end
                    else
                        if not addon.focus.recentlyUntrackedWorldQuests then addon.focus.recentlyUntrackedWorldQuests = {} end
                        addon.focus.recentlyUntrackedWorldQuests[self.questID] = true
                        -- Persist so suppress-until-reload survives actual reloads.
                        if addon.GetDB("suppressUntrackedUntilReload", false) then
                            addon.SetDB("sessionSuppressedQuests", addon.focus.recentlyUntrackedWorldQuests)
                        end
                    end
                elseif C_QuestLog.RemoveQuestWatch then
                    C_QuestLog.RemoveQuestWatch(self.questID)
                end
                addon.ScheduleRefresh()
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
