# Presence API Compatibility Checklist

Map of Presence module Blizzard API usage to [Blizzard_APIDocumentationGenerated](https://github.com/Gethe/wow-ui-source/tree/live/Interface/AddOns/Blizzard_APIDocumentationGenerated) (wow-ui-source live branch). Use when validating addon behavior across WoW patches or adding guards for new/removed APIs.

---

## Confirmed: Docs files exist

| Namespace | Used APIs in Presence | Doc file(s) | GitHub link |
|-----------|------------------------|-------------|-------------|
| **C_QuestLog** | GetTitleForQuestID, GetQuestObjectives, IsComplete, GetLogIndexForQuestID, GetInfo, GetNumQuestWatches, GetQuestIDForQuestWatchIndex, GetNumQuestLogEntries, IsOnQuest | QuestLogDocumentation.lua | [QuestLogDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua) |
| **C_ScenarioInfo** | GetCriteriaInfo, GetCriteriaInfoByStep, GetScenarioStepInfo | ScenarioInfoDocumentation.lua | [ScenarioInfoDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/ScenarioInfoDocumentation.lua) |
| **C_SuperTrack** | GetSuperTrackedQuestID | SuperTrackManagerDocumentation.lua | [SuperTrackManagerDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/SuperTrackManagerDocumentation.lua) |
| **C_Timer** | After | UITimerDocumentation.lua | [UITimerDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/UITimerDocumentation.lua) |
| **C_ContentTracking** | GetTrackedIDs | ContentTrackingDocumentation.lua | [ContentTrackingDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/ContentTrackingDocumentation.lua) |
| **C_PvP** | GetZonePVPInfo | PvPDocumentation.lua | [PvPDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/PvPDocumentation.lua) |

---

## Enums and constants

| Enum / constant | Used in Presence | Doc file(s) |
|-----------------|------------------|-------------|
| Enum.ContentTrackingType | Achievement (for tracked achievements) | ContentTrackingTypesDocumentation.lua |

---

## Verify in-game (not in Blizzard_APIDocumentationGenerated)

These APIs are called by Presence but have **no dedicated generated docs file** in the wow-ui-source live branch. Treat as compatibility risks; guard with existence checks.

| Namespace / API | Used in Presence | Notes |
|-----------------|------------------|-------|
| **C_Scenario** | PresenceCore, PresenceEvents | GetInfo, GetStepInfo. Used for IsScenarioActive, GetScenarioDisplayInfo, GetMainStepCriteria numCriteria fallback. No ScenarioDocumentation.lua. Prefer C_ScenarioInfo.GetScenarioStepInfo for step structure. |
| **GetZoneText** (global) | PresenceEvents, PresenceCore, PresenceSlash | Zone/subzone display strings. Standard WoW API. |
| **GetSubZoneText** (global) | PresenceEvents, PresenceSlash | Subzone display. Standard WoW API. |
| **GetInstanceInfo** (global) | PresenceEvents, PresenceCore | Instance type for suppression; dungeon name for scenario display. Standard WoW API. |
| **GetAchievementInfo** (global) | PresenceEvents | Achievement name for ACHIEVEMENT and ACHIEVEMENT_PROGRESS toasts. pcall-wrapped (can throw on invalid ID). |
| **C_VignetteInfo** | Utilities (GetRareNamesOnMap) | GetVignettes, GetVignetteInfo. Used for rare defeated detection when Focus disabled. |

---

## Migration decisions

| Decision | Rationale |
|----------|-----------|
| **C_ScenarioInfo.GetScenarioStepInfo** for numCriteria | Documented (9.1.0+). Replaces C_Scenario.GetStepInfo for step structure. GetCriteriaInfo/GetCriteriaInfoByStep remain for criteria iteration. |
| **C_PvP.GetZonePVPInfo** preferred over GetZonePVPInfo | PresenceCore already prefers C_*; no fallback needed when C_PvP exists. |
| **GetAchievementInfo** retained | C_AchievementInfo has no GetAchievementInfo equivalent in docs. Keep global with pcall. |

---

## Guard-pattern reference

Per `presence-coding-style.mdc`:

- **Existence check**: `if C_Foo and C_Foo.Bar then` — default for APIs that may not exist in current WoW version.
- **pcall**: Only when the API exists but can throw on bad input (e.g. `GetAchievementInfo` with invalid ID). Add a comment explaining why.
- **Fallback values**: Use `(Enum and Enum.X and Enum.X.Value) or fallbackNumber` when Enum may be nil.

---

## Quick links

- [Blizzard_APIDocumentationGenerated (live)](https://github.com/Gethe/wow-ui-source/tree/live/Interface/AddOns/Blizzard_APIDocumentationGenerated)
- [TOC file (full file list)](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/Blizzard_APIDocumentationGenerated.toc)
