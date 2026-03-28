# FocusAchievements.lua – Step-by-Step Flow Notes

Open this file when studying the code. It explains the flow of each function in detail.

---

## GetAchievementCriteria(achievementID)

This helper turns one achievement's criteria (e.g. "Kill 10 wolves") into the list of objective rows the tracker can show. We return three values: the objectives table, how many are done, and how many total (for progress text).

1. **Setup** – Initialize the objectives table and two counters (criteriaDone, criteriaTotal). Read the addon option "only show missing requirements" so we can hide completed criteria if the user chose that.

2. **API guard** – If the game doesn't expose criteria (old client or no API), return empty results so the rest of the code doesn't have to special-case it.

3. **Count criteria** – Ask the game how many criteria this achievement has via GetAchievementNumCriteria. We use pcall because the API can error on invalid or stale IDs. If it fails, we treat it as 0 and still run the loop once so we don't assume the achievement has no criteria.

4. **Loop** – For each criteria index, call GetAchievementCriteriaInfo in pcall (it can throw). We only add a row if we got a non-empty criteria string.

5. **Include logic** – Count this criteria as total, and as done if completedCrit is true/1. We only include it in the objectives list if the user wants "all" or if it's not finished (when "only missing" is on).

6. **Build row** – If the criteria has quantity/reqQuantity (e.g. 3/10), compute a percentage for the UI. Also store `numFulfilled` and `numRequired` on each objective so the renderer can show "(50/300)" per criterion. Append one objective row: text, finished flag, optional percent, and optional numFulfilled/numRequired.

7. **Return** – Return the built objectives table and the two counts so the caller can show "2/5" style progress (or "50/300" for single-criterion numeric achievements).

---

## ReadTrackedAchievements()

This is the only function the rest of the Focus module calls for achievements. FullLayout calls it, gets an array of entry tables, and renders one row per entry. We don't take a context object because achievements aren't merged by the aggregator; we return the final shape directly.

1. **Setup** – We collect two things: `idList` = the achievement IDs the player is tracking, and `out` = the final array of entry tables we return.

2. **Step 1 – Get tracked IDs** – WoW 10.1.5+ uses C_ContentTracking.GetTrackedIDs(type). Older clients use GetTrackedAchievements() which returns up to MAX_LEGACY_TRACKED_ACHIEVEMENTS (10) IDs as multiple return values. We normalize both into a single array idList.

3. **Step 2 – Resolve color** – Decide what color to use for achievement rows. Check addon's color system first (user may have customized), then Config's QUEST_COLORS, then our DEFAULT_ACHIEVEMENT_COLOR.

4. **Step 3 – Loop over IDs** – For each tracked achievement ID we'll build one entry table. We skip invalid IDs (guard at top of loop).

5. **Get details** – Call the game for this achievement's details via GetAchievementInfo. It can throw (e.g. invalid ID), so we wrap in pcall. If name is missing we use a fallback so the row always has a title.

6. **Guard: show completed** – Respect the "show completed achievements" option. If this achievement is complete and the user has that option off, we skip adding it (guard clause: only add when we're allowed to show it).

7. **Build entry** – Resolve icon (number or string texture) and get the criteria list + counts from GetAchievementCriteria. When exactly one criterion has numeric progress (quantity/reqQuantity with reqQuantity > 1), add `numericQuantity` and `numericRequired` to the entry so the title shows e.g. "Collect 300 decors (50/300)" instead of "(0/1)". Build one entry table in the shape the tracker expects: entryKey (unique), achievementID, title, objectives, color, category, and all the standard flags (isComplete, isTracked, etc.). zoneName and isNearby are always nil/false for achievements.

8. **Return** – Return the full array. FullLayout will iterate this and call PopulateEntry for each.
