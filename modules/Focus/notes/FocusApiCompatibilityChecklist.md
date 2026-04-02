# Focus API Compatibility Checklist

Map of Focus module Blizzard API usage to [Blizzard_APIDocumentationGenerated](https://github.com/Gethe/wow-ui-source/tree/live/Interface/AddOns/Blizzard_APIDocumentationGenerated) (wow-ui-source live branch). Use when validating addon behavior across WoW patches or adding guards for new/removed APIs.

---

## Confirmed: Docs files exist

| Namespace | Used APIs in Focus | Doc file(s) | GitHub link |
|-----------|--------------------|-------------|-------------|
| **C_QuestLog** | GetTitleForQuestID, GetQuestObjectives, IsComplete, GetLogIndexForQuestID, GetInfo, GetNumQuestWatches, GetQuestIDForQuestWatchIndex, GetNumWorldQuestWatches, GetQuestIDForWorldQuestWatchIndex, GetQuestsOnMap, GetNextWaypoint, GetNumQuestLogEntries, AddQuestWatch, AddWorldQuestWatch, RemoveQuestWatch, RemoveWorldQuestWatch, IsWorldQuest, IsOnQuest, IsQuestCalling, IsRepeatableQuest, GetQuestTagInfo, SetSelectedQuest, SetAbandonQuest, AbandonQuest, GetTimeAllowed | QuestLogDocumentation.lua | [QuestLogDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua) |
| **C_TaskQuest** | GetQuestTimeLeftMinutes, GetQuestInfoByQuestID, GetQuestLocation, IsActive, RequestPreloadRewardData, GetQuestsOnMap | QuestTaskInfoDocumentation.lua | [QuestTaskInfoDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestTaskInfoDocumentation.lua) |
| **C_Map** | GetBestMapForUnit, GetMapInfo, GetMapChildrenInfo, GetPlayerMapPosition | MapDocumentation.lua | [MapDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/MapDocumentation.lua) |
| **C_SuperTrack** | GetSuperTrackedQuestID, SetSuperTrackedQuestID, GetSuperTrackedVignette, SetSuperTrackedVignette | SuperTrackManagerDocumentation.lua | [SuperTrackManagerDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/SuperTrackManagerDocumentation.lua) |
| **C_ContentTracking** | StopTracking, GetTrackedIDs, GetTitle, GetCurrentTrackingTarget, GetObjectiveText | ContentTrackingDocumentation.lua | [ContentTrackingDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/ContentTrackingDocumentation.lua) |
| **C_TransmogCollection** | GetAppearanceSourceInfo, GetAppearanceInfoBySource | TransmogItemsDocumentation.lua | [TransmogItemsDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/TransmogItemsDocumentation.lua) |
| **C_QuestInfoSystem** | GetQuestClassification | QuestInfoSystemDocumentation.lua | [QuestInfoSystemDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestInfoSystemDocumentation.lua) |
| **C_ScenarioInfo** | GetCriteriaInfo, GetCriteriaInfoByStep | ScenarioInfoDocumentation.lua | [ScenarioInfoDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/ScenarioInfoDocumentation.lua) |
| **C_AddOns** | IsAddOnLoaded, LoadAddOn | AddOnsDocumentation.lua | [AddOnsDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/AddOnsDocumentation.lua) |
| **C_Timer** | After, NewTicker | UITimerDocumentation.lua | [UITimerDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/UITimerDocumentation.lua) |
| **C_HousingCatalog** | GetCatalogEntryInfoByRecordID | HousingCatalogUIDocumentation.lua | [HousingCatalogUIDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/HousingCatalogUIDocumentation.lua) |
| **C_NeighborhoodInitiative** | RemoveTrackedInitiativeTask, GetInitiativeTaskInfo | NeighborhoodInitiativeDocumentation.lua | [NeighborhoodInitiativeDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/NeighborhoodInitiativeDocumentation.lua) |
| **C_QuestLine** | RequestQuestLinesForMap, GetAvailableQuestLines, GetForceVisibleQuests | QuestLineInfoDocumentation.lua | [QuestLineInfoDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestLineInfoDocumentation.lua) |
| **C_PartyInfo** | IsDelveInProgress, IsDelveComplete | PartyInfoDocumentation.lua | [PartyInfoDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/PartyInfoDocumentation.lua) |
| **C_DelvesUI** | HasActiveDelve, GetDelvesAffixSpellsForSeason, GetCurrentDelvesSeasonNumber, GetTieredEntrancePDEID, GetDelvesFactionForSeason, GetDelvesMinRequiredLevel | DelvesUIDocumentation.lua | [DelvesUIDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/DelvesUIDocumentation.lua) |
| **C_UIWidgetManager** | GetAllWidgetsBySetID, GetScenarioHeaderDelvesWidgetVisualizationInfo, GetObjectiveTrackerWidgetSetID (fallback). Affix data: use widgetSetID from C_Scenario.GetStepInfo first; ObjectiveTracker set may be empty when tracker is hidden. | UIWidgetManagerDocumentation.lua | [UIWidgetManagerDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/UIWidgetManagerDocumentation.lua) |
| **C_GossipInfo** | GetActiveDelveGossip (primary tier source when in delve; orderIndex + 1 = tier), GetGossipDelveMapID | GossipInfoDocumentation.lua | [GossipInfoDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/GossipInfoDocumentation.lua) |
| **C_PerksActivities** | GetTrackedPerksActivities, GetPerksActivityInfo, RemoveTrackedPerksActivity | PerksActivitiesDocumentation.lua | [PerksActivitiesDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/PerksActivitiesDocumentation.lua) |

---

## Enums and constants

| Enum / constant | Used in Focus | Doc file(s) |
|----------------|---------------|-------------|
| Enum.QuestClassification | Calling, Campaign, Recurring, Important, Legendary, Meta | [QuestInfoSharedDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestInfoSharedDocumentation.lua) |
| Enum.QuestFrequency | Daily, Weekly | QuestLogDocumentation.lua (QuestFrequency table) |
| Enum.ContentTrackingType | Achievement, Decor, Appearance | [ContentTrackingTypesDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/ContentTrackingTypesDocumentation.lua) |
| Enum.ContentTrackingStopType | Manual | ContentTrackingTypesDocumentation.lua |
| Enum.HousingCatalogEntryType | Decor | [HousingCatalogConstantsDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/HousingCatalogConstantsDocumentation.lua) |
| Enum.NeighborhoodInitiativeTaskType | RepeatableInfinite | [NeighborhoodInitiativesConstantsDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/NeighborhoodInitiativesConstantsDocumentation.lua) |
| LE_QUEST_FREQUENCY_DAILY, LE_QUEST_FREQUENCY_WEEKLY | FocusDailies, FocusCategories | Legacy global constants; fallback when Enum.QuestFrequency unavailable |

---

## Verify in-game (not in Blizzard_APIDocumentationGenerated)

These APIs are called by Focus but have **no dedicated generated docs file** in the wow-ui-source live branch. Treat as compatibility risks; guard with existence checks.

| Namespace / API | Used in Focus | Notes |
|-----------------|---------------|-------|
| **C_Scenario** | FocusScenario, FocusMplusBlock, FocusDelvesBlock | IsInScenario, GetInfo, GetStepInfo, GetBonusSteps, GetBonusStepRewardQuestID; FocusMplusBlock also uses GetScenarioStepInfo, GetScenarioInfo (different names). No ScenarioDocumentation.lua in TOC. Likely older or internal API; may coexist with C_ScenarioInfo. |
| **C_Endeavors** | FocusInteractions, FocusSlash, FocusEndeavors | StopTracking, GetTrackedIDs, GetEndeavorInfo, GetInfo. No Endeavors/EndeavorInfo docs file in TOC. Neighborhood Endeavors feature; API may change. |
| **GetQuestLogTitle** (global) | FocusAggregator, FocusCategories | Legacy API; used as fallback for quest level and frequency. pcall-wrapped. Prefer C_QuestLog.GetInfo when available. |
| **GetQuestLogSpecialItemInfo** (global) | FocusAggregator | Legacy API for quest item link/texture; takes logIndex. Guard with existence check. |
| **GetInstanceInfo** (global) | FocusCollapse, FocusSlash, FocusDungeons | Standard WoW API; not C_* namespace. Documented elsewhere. |
| **QuestUtils_IsQuestWorldQuest** (global) | FocusCategories | Blizzard internal; fallback before C_QuestLog.IsWorldQuest. |
| **ShowQuestComplete** (global) | FocusInteractions | Blizzard function; used for click-to-complete on auto-complete quests. Guard with existence check. |
| **GetFactionInfoByID** (global) | FocusDelvesBlock | Standard WoW API; returns faction name from factionID. Used for delve season faction in tooltip. |
| **GetCVarTableValue** (global) | FocusDelves | Table CVar access; used for lastSelectedTieredEntranceTier (per-delve tier). May not exist in older clients; guard with existence check. |
| **C_TradeSkillUI** | FocusRecipes, FocusInteractions | GetRecipesTracked, GetRecipeSchematic, GetRecipeRequirements, GetRecipeInfo, GetProfessionInfoByRecipeID, GetCraftableCount, GetRecipeQualityItemIDs, GetRecipeOutputItemData. TradeSkillUIDocumentation.lua exists. |
| **ProfessionsUtil** | FocusInteractions | OpenProfessionFrameToRecipe (opens profession frame + navigates to recipe; works when window closed). Provided by Blizzard_Professions addon; load via C_AddOns.LoadAddOn before first use. Fallback: C_TradeSkillUI.OpenRecipe when profession window already open. |

---

## Click-to-complete limitations

There is **no API to programmatically turn in quests** that require NPC interaction. Only **auto-complete** quests (`C_QuestLog.GetInfo(logIndex).isAutoComplete` + `C_QuestLog.IsComplete(questID)`) can be completed via `ShowQuestComplete(questID)`. For non-auto-complete quests, Focus continues to guide (super-track, open details); the player must interact with the turn-in NPC manually.

---

## Guard-pattern reference

Per `focus-coding-style.mdc`:

- **Existence check**: `if C_Foo and C_Foo.Bar then` — only for APIs in "Verify in-game" or expansion-specific. No legacy fallback chain.
- **pcall**: Only when the API exists but can throw on bad input (e.g. `C_QuestLog.GetInfo` with invalid logIndex). Add a comment explaining why.
- **Enums**: Use `Enum.ContentTrackingType.Achievement` directly when documented. No `or 2` fallback (retail-only).

---

## Quick links

- [Blizzard_APIDocumentationGenerated (live)](https://github.com/Gethe/wow-ui-source/tree/live/Interface/AddOns/Blizzard_APIDocumentationGenerated)
- [TOC file (full file list)](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/Blizzard_APIDocumentationGenerated.toc)
