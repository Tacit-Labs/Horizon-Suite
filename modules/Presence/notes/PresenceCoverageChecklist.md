# Presence 1.0.0 Text Coverage Audit

Baseline coverage matrix, gap analysis, and implementation plan for release readiness.

---

## 1. Current Suppression/Replacement Coverage Matrix

### 1.1 Frame Suppression (PresenceBlizzard.lua)

| Surface | Blizzard Frame | Suppression Method | Replacement Trigger | Replacement Content | Confidence |
|---------|----------------|--------------------|---------------------|---------------------|------------|
| Zone name | `ZoneTextFrame` | KillBlizzardFrame | ZONE_CHANGED_NEW_AREA | QueueOrPlay ZONE_CHANGE | covered |
| Subzone name | `SubZoneTextFrame` | KillBlizzardFrame | ZONE_CHANGED, ZONE_CHANGED_INDOORS | QueueOrPlay SUBZONE_CHANGE | covered |
| Boss emotes | `RaidBossEmoteFrame` | KillBlizzardFrame | RAID_BOSS_EMOTE | QueueOrPlay BOSS_EMOTE | covered |
| Level-up | `LevelUpDisplay` | KillBlizzardFrame | PLAYER_LEVEL_UP | QueueOrPlay LEVEL_UP | covered |
| Boss encounter banner | `BossBanner` | KillBlizzardFrame | (N/A; banner shown via other path) | Presence does not replace boss encounter banners | partial |
| Tracker bonus banner | `ObjectiveTrackerBonusBannerFrame` | KillBlizzardFrame | — | N/A (suppress only) | covered |
| Tracker top banner | `ObjectiveTrackerTopBannerFrame` | KillBlizzardFrame | — | N/A (suppress only) | partial* |
| Event toasts | `EventToastManagerFrame` | KillBlizzardFrame | — | Presence replaces via events (achievement, quest) | covered |
| World quest complete banner | `WorldQuestCompleteBannerFrame` | KillBlizzardFrame + ADDON_LOADED retry | QUEST_TURNED_IN | QueueOrPlay WORLD_QUEST | partial** |

\* Frame may not exist at SuppressBlizzard time; fallback via `_G`.  
\** Depends on Blizzard_WorldQuestComplete load timing; first WQ after reload may show before suppression.

### 1.2 Event/Hook Suppression (PresenceErrors.lua)

| Surface | Mechanism | Suppression Method | Replacement | Confidence |
|---------|------------|--------------------|-------------|------------|
| "Discovered" (UIErrorsFrame) | hooksecurefunc AddMessage | Clear() after detection | ShowDiscoveryLine on zone layer | covered |
| Quest objective text (UIErrorsFrame) | hooksecurefunc AddMessage | Clear() after IsQuestText | QueueOrPlay QUEST_UPDATE | partial*** |
| Achievement alerts | AlertFrame:UnregisterEvent | ACHIEVEMENT_EARNED | QueueOrPlay ACHIEVEMENT | covered |
| Quest turn-in alerts | AlertFrame:UnregisterEvent | QUEST_TURNED_IN | QueueOrPlay QUEST_COMPLETE / WORLD_QUEST | covered |

\*** Clear runs after AddMessage; message may flash briefly before clearing.

### 1.3 Replacement Event Flow (PresenceEvents.lua)

| Event | Handler | QueueOrPlay Type | Data Source |
|-------|---------|------------------|-------------|
| ZONE_CHANGED_NEW_AREA | OnZoneChangedNewArea | ZONE_CHANGE | GetZoneText, GetSubZoneText |
| ZONE_CHANGED / ZONE_CHANGED_INDOORS | OnZoneChanged | SUBZONE_CHANGE | GetZoneText, GetSubZoneText |
| PLAYER_LEVEL_UP | OnPlayerLevelUp | LEVEL_UP | level param |
| RAID_BOSS_EMOTE | OnRaidBossEmote | BOSS_EMOTE | msg, unitName |
| ACHIEVEMENT_EARNED | OnAchievementEarned | ACHIEVEMENT | GetAchievementInfo |
| QUEST_ACCEPTED | OnQuestAccepted | QUEST_ACCEPT / WORLD_QUEST_ACCEPT | C_QuestLog.GetTitleForQuestID |
| QUEST_TURNED_IN | OnQuestTurnedIn | QUEST_COMPLETE / WORLD_QUEST | C_QuestLog.GetTitleForQuestID |
| QUEST_WATCH_UPDATE | OnQuestWatchUpdate | QUEST_UPDATE | C_QuestLog.GetQuestObjectives |
| QUEST_LOG_UPDATE | OnQuestLogUpdate | QUEST_UPDATE (blind WQ) | GetWorldQuestIDForObjectiveUpdate |
| UI_INFO_MESSAGE | OnUIInfoMessage | QUEST_UPDATE (fallback) | msg text |
| SCENARIO_UPDATE | TryShowScenarioStart | SCENARIO_START | addon.GetScenarioDisplayInfo |
| SCENARIO_CRITERIA_UPDATE | TryShowScenarioStart + RequestScenarioCriteriaUpdate (when wasInScenario) | SCENARIO_UPDATE | C_ScenarioInfo.GetCriteriaInfo |

### 1.4 KillBlizzardFrame Mechanism (PresenceBlizzard.lua)

1. `frame:UnregisterAllEvents()`
2. Store original parent, point, alpha
3. `frame:SetParent(hiddenParent)`
4. `frame:Hide()`
5. `frame:SetAlpha(0)`
6. `frame:SetScript("OnShow", function(self) self:Hide() end)`

---

## 2. WoW UI Source – Additional Candidate Text Surfaces

Source: [Gethe/wow-ui-source live branch](https://github.com/Gethe/wow-ui-source/tree/live/Interface/AddOns).

### 2.1 Blizzard_FrameXML (Zone, Talking Head, Alerts, Event Toast)

| Surface | File | Frame Name | Events / Mechanism | Text Elements |
|---------|------|------------|--------------------|---------------|
| Zone text | ZoneText.lua | ZoneTextFrame, SubZoneTextFrame | ZONE_CHANGED, ZONE_CHANGED_INDOORS, ZONE_CHANGED_NEW_AREA | ZoneTextString, SubZoneTextString, PVPInfoTextString |
| Talking head | TalkingHeadUI.lua | TalkingHeadFrame | TALKINGHEAD_REQUESTED | NameFrame.Name, TextFrame.Text |
| AlertFrame | AlertFrames.lua | AlertFrame | ACHIEVEMENT_EARNED, QUEST_TURNED_IN, +many | Multiple subsystems (AchievementAlertSystem, WorldQuestCompleteAlertSystem, etc.) |
| Event toast | EventToastManager.lua | EventToastManagerFrame | Various toast types | Toast content |

### 2.2 TalkingHeadFrame Details

- `TALKINGHEAD_REQUESTED` → `PlayCurrent()` → `NameFrame.Name:SetText(name)`, `TextFrame.Text:SetText(textFormatted)`
- Uses `AlertFrame:AddExternallyAnchoredSubSystem(self)` (anchored to alert system)
- **Not suppressed** by Presence; overlaps with zone/quest narrative text

### 2.3 AlertFrame Subsystems (Partial)

- `AchievementAlertSystem` – ACHIEVEMENT_EARNED
- `CriteriaAlertSystem` – CRITERIA_EARNED
- `WorldQuestCompleteAlertSystem` – QUEST_TURNED_IN (when `C_QuestInfoSystem.GetQuestShouldToastCompletion`)
- `ScenarioAlertSystem`, `DungeonCompletionAlertSystem` – LFG_COMPLETION_REWARD
- Many others (loot, garrison, etc.)

Presence mutes `ACHIEVEMENT_EARNED`, `QUEST_TURNED_IN` and the criteria events on AlertFrame
**per notification type** — an event is unregistered only while the type that replaces it is on,
so switching a type off returns its alert to Blizzard. Other subsystems remain untouched.

### 2.4 Blizzard_ObjectiveTracker (Banners)

- `Blizzard_AutoQuestPopUpTracker` – auto-quest accept popups
- `ObjectiveTrackerBonusBannerFrame` – bonus objective banners (suppressed)
- `ObjectiveTrackerTopBannerFrame` – top banners (suppressed)
- `Blizzard_WorldQuestObjectiveTracker` – world quest tracking (in tracker, not banners)

### 2.5 Blizzard_LevelUpDisplay

- `LevelUpDisplay` (suppressed)
- `Blizzard_LevelUpDisplay/Mists/` – level-up UI

### 2.6 Quest Dialog Surfaces (Not in Blizzard_FrameXML)

Quest accept/complete dialogs are likely in `Blizzard_QuestInfo`, `Blizzard_QuestChoice`, or similar. These addons were not found under that exact path in wow-ui-source live; they may be embedded in Blizzard_FrameXML or another addon. In-game frame names to verify:

- `QuestFrame` – accept/complete dialog
- `QuestChoiceFrame` – multi-quest choice
- `GossipFrame` – NPC dialog with quest options

---

## 3. Gap Analysis & Release Risk Ranking

### 3.1 Blocker for 1.0.0

| Gap | Evidence | Impact |
|-----|----------|--------|
| None identified | Current coverage appears sufficient for transient notifications | — |

### 3.2 Should Fix Pre-1.0.0

| Gap | Evidence | Mitigation |
|-----|----------|------------|
| **TalkingHeadFrame** | Shows NPC name + dialogue during quests/zones; not suppressed. Overlaps Presence’s cinematic zone/quest text. | Add `KillBlizzardFrame(TalkingHeadFrame)` or UnregisterEvent `TALKINGHEAD_REQUESTED` when Presence replaces narrative. |
| **WorldQuestCompleteBannerFrame timing** | Loaded by `Blizzard_WorldQuestComplete`; first WQ after `/reload` may show banner before `ADDON_LOADED` fires. | Retry `KillWorldQuestBanner` more aggressively (e.g. on `QUEST_TURNED_IN` if WQ). |
| **UIErrorsFrame quest text flash** | `hooksecurefunc` runs after `AddMessage`; message may render briefly before `Clear()`. | Consider pre-hook to block add, or `UIErrorsFrame:SetAlpha(0)` when Presence handles; restore on disable. |

### 3.3 Post-1.0 (Edge Cases / Low Frequency)

| Gap | Evidence | Notes |
|-----|----------|-------|
| Quest accept/complete dialog frames | `QuestFrame`, `QuestGiverFrame`, `QuestChoiceFrame` show quest text in dialogs. Scope: “transient + dialog” – these are dialog UI, not floating toasts. | If scope includes dialogs: suppress or hide quest-text overlays; otherwise defer. |
| GossipFrame quest offer text | Gossip dialog with quest options. | Same as above; typically part of NPC interaction, not a Presence-style toast. |
| AlertFrame subsystems besides ACHIEVEMENT / QUEST_TURNED_IN | Scenario, dungeon completion, garrison, etc. | Presence focuses on zone/quest/achievement; other alerts are lower priority. |
| ObjectiveTrackerTopBannerFrame | May not exist at SuppressBlizzard time. | Fallback via `_G`; low risk. |

### 3.4 Explicit Validation Checklist (High-Risk Items)

- [ ] WorldQuestCompleteBannerFrame: Complete a world quest immediately after `/reload`; confirm no Blizzard banner appears.
- [ ] UIErrorsFrame: Trigger quest objective update; confirm no brief quest text flash.
- [ ] TalkingHeadFrame: Enter zone/quest that triggers talking head; confirm if it overlaps Presence.

---

## 4. Implementation Plan (Next Pass)

### 4.1 Priority 1: TalkingHeadFrame Suppression

**File:** `modules/Presence/PresenceBlizzard.lua`

**Change:** Add `TalkingHeadFrame` to `SuppressBlizzard()` and `RestoreBlizzard()`.

```lua
-- In SuppressBlizzard():
local talkingHeadFrame = TalkingHeadFrame or _G["TalkingHeadFrame"]
if talkingHeadFrame then
    KillBlizzardFrame(talkingHeadFrame)
end

-- In RestoreBlizzard():
local talkingHeadFrame = TalkingHeadFrame or _G["TalkingHeadFrame"]
if talkingHeadFrame then RestoreBlizzardFrame(talkingHeadFrame) end
```

**Caveat:** TalkingHeadFrame shows NPC dialogue during quests. Suppressing it removes that narrative. Consider adding an option (e.g. `showTalkingHead`) so users can re-enable it if desired.

### 4.2 Priority 2: WorldQuestCompleteBannerFrame Timing

**File:** `modules/Presence/PresenceEvents.lua`

**Change:** On `QUEST_TURNED_IN`, if it's a world quest and Presence is enabled, call `KillWorldQuestBanner()` proactively (in addition to ADDON_LOADED).

```lua
-- In OnQuestTurnedIn, before QueueOrPlay:
if addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID) and addon.Presence.KillWorldQuestBanner then
    addon.Presence.KillWorldQuestBanner()
end
```

**Alternative:** Keep ADDON_LOADED retry but add a short `C_Timer.After` chain (e.g. 0, 0.5, 1.0, 2.0) to catch late loads.

### 4.3 Priority 3: UIErrorsFrame Quest Text Flash (Optional)

**File:** `modules/Presence/PresenceErrors.lua`

**Options:**
- (A) Pre-hook to prevent add: replace `AddMessage` with a wrapper that discards quest text before calling original. Complex; may break other addons.
- (B) Set `UIErrorsFrame:SetAlpha(0)` when Presence handles quest text; restore on disable. Simpler but hides all error messages briefly.
- (C) Accept brief flash; document as known limitation. Lowest risk.

**Recommendation:** (C) for 1.0.0; revisit if users report it.

### 4.4 Test Checklist (Per-Surface Verification)

| Surface | Test | Expected |
|---------|------|----------|
| ZoneTextFrame | Fly to new zone | Presence zone text only |
| SubZoneTextFrame | Enter subzone | Presence subzone text only |
| RaidBossEmoteFrame | Boss emote (raid/dungeon) | Presence BOSS_EMOTE only |
| LevelUpDisplay | Level up | Presence LEVEL_UP only |
| EventToastManagerFrame | Achievement / quest complete | Presence toasts only |
| ObjectiveTrackerBonusBannerFrame | Bonus objective | No Blizzard banner |
| AlertFrame (ACHIEVEMENT_EARNED) | Earn achievement | Presence ACHIEVEMENT only |
| AlertFrame (QUEST_TURNED_IN) | Turn in quest | Presence QUEST_COMPLETE only |
| UIErrorsFrame (Discovered) | Enter new zone | Presence "Discovered" only |
| UIErrorsFrame (quest text) | Quest objective progress | Presence QUEST_UPDATE; may flash Blizzard text |
| WorldQuestCompleteBannerFrame | Complete world quest | Presence WORLD_QUEST only |
| TalkingHeadFrame | Trigger talking head (quest/zone) | *(If implemented)* Presence only; *(current)* both may show |

### 4.5 Files to Modify (Summary)

| File | Changes |
|------|---------|
| `PresenceBlizzard.lua` | Add TalkingHeadFrame to SuppressBlizzard / RestoreBlizzard |
| `PresenceEvents.lua` | Optional: call KillWorldQuestBanner in OnQuestTurnedIn for WQ |
| `PresenceErrors.lua` | Optional: UIErrorsFrame flash mitigation (defer to post-1.0) |
