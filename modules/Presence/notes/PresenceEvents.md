# PresenceEvents Flow Notes

## RequestQuestUpdate

1. Called from `OnQuestWatchUpdate` (direct questID) or `OnQuestLogUpdate`/`OnUIInfoMessage` (blind, guessed ID).
2. Cancels any existing C_Timer for this questID (debounce).
3. Schedules `C_Timer.After(UPDATE_BUFFER_TIME, ...)` so we process the *final* state (fixes 55/100 → 71/100 flicker).
4. ExecuteQuestUpdate: When result is 0/X from QUEST_WATCH_UPDATE, re-samples after ZERO_PROGRESS_RETRY_TIME (meta quests like "0/8 WQs" often lag; avoids showing stale 0/8 right after completion).

## ExecuteQuestUpdate

1. Timer fires; clear `bufferedUpdates[questID]`.
2. Fetch objectives via `C_QuestLog.GetQuestObjectives(questID)`.
3. Build serialized state string; compare with `lastQuestObjectivesCache[questID]`. Skip if unchanged.
4. Blind update suppression: if `isBlindUpdate` and `isNew` (no cache entry), skip (avoids popup on unrelated QUEST_LOG_UPDATE).
5. Update cache with new state.
6. Pick display text (in order): if `pendingQuestObjectiveHint[questID]` was set from **UI_INFO_MESSAGE** (normalized chat line), consume it and use the first objective row whose `NormalizeQuestUpdateText(Strip(text))` equals that hint (`ui_hint_match`); else **first objective row** (by index) where `oldState` and `newState` differ on `text`, `finished`, `numFulfilled`, or `numRequired` and `newO.text` is non-empty; else if this is the **first** cached run for the quest (`isNew`): first **finished** objective with text; else first **unfinished** objective with text — unless there is **no** `oldState` and **multiple** objectives, in which case use the neutral `"Objective updated"` (`ambiguous_no_baseline`) to avoid showing the wrong row; else first row with text; else the literal `"Objective updated"`.
7. Call `QueueOrPlay("QUEST_UPDATE", ...)` with `{ questID = questID, source = source }`.

## GetWorldQuestIDForObjectiveUpdate

1. Super-tracked quest (C_SuperTrack) if it's a WQ and not complete.
2. Else: `addon.ReadTrackedQuests()` → filter WORLD/CALLING, not complete, isNearby → first candidate.
3. Used for blind updates when we don't know which quest changed.

## Scenario Criteria Update (SCENARIO_UPDATE)

Delve and scenario objectives use C_ScenarioInfo (scenario criteria), not C_QuestLog. They cannot be tracked, so QUEST_WATCH_UPDATE never fires. This flow handles objective progress toasts for delves, party dungeons, and other scenarios.

### RequestScenarioCriteriaUpdate

1. Called from `OnScenarioCriteriaUpdate` when `wasInScenario` is true (i.e. after we've shown SCENARIO_START).
2. Cancels any existing C_Timer (debounce).
3. Schedules `C_Timer.After(SCENARIO_UPDATE_BUFFER_TIME, ExecuteScenarioCriteriaUpdate)`.

### ExecuteScenarioCriteriaUpdate

1. Timer fires; clear `scenarioCriteriaUpdateTimer`.
2. Guard: IsScenarioActive, showScenarioEvents, GetScenarioDisplayInfo.
3. Fetch main-step criteria via `GetMainStepCriteria()` (C_ScenarioInfo.GetCriteriaInfo / GetCriteriaInfoByStep).
4. Build state key; compare with `lastScenarioCriteriaCache`. Skip if unchanged.
5. Update cache with new state.
6. Pick display text: first unfinished criteria with text (plus X/Y if applicable), or "X/Y", or first text, or "Objective updated".
7. Resolve category from `GetScenarioDisplayInfo()` (DELVES | DUNGEON | SCENARIO).
8. Call `QueueOrPlay("SCENARIO_UPDATE", "SCENARIO UPDATE", text, { category = category })`.

### OnScenarioCompleted

Clears `lastScenarioCriteriaCache` and cancels `scenarioCriteriaUpdateTimer`.
