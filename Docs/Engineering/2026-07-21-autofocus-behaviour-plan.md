# Auto-Focus Behaviour Modes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an Auto-Focus Behaviour dropdown (`always` / `respectManual` / `onlyWhenUnfocused`) so proximity auto-focus can yield to a player-chosen focus.

**Architecture:** Keep the master `proximityAutoSuperTrack` toggle. Branch inside `ApplyProximityAutoSuperTrack` by `proximityAutoBehaviour`. Session flags on `addon.focus` record which quest Auto-Focus set (`proximityAutoOwnedQID`) and when the player overrode it (`proximityManualOverride`). Tracker super-track clicks call exported helpers so override is marked immediately.

**Tech Stack:** WoW retail Lua 5.1 addon (Horizon Suite Focus + Options + enUS locales). No automated unit test harness — verify in-game / via `/h focus autofocus` and options UI. Run `luacheck` on touched Lua if available.

**Spec:** `Docs/Engineering/2026-07-21-autofocus-behaviour-design.md`

## Global Constraints

- Lua 5.1 only (no `goto`, `//`, native bitwise, `_ENV`, `require`).
- Namespace: `local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite` (match the file’s existing header pattern).
- Focus mutable state only under `addon.focus.*`.
- DB via `addon.GetDB` / `addon.SetDB` (options file uses OptionsData helpers already in that file).
- Default behaviour `"always"` — do not change existing installs’ feel.
- Keybind / `/h focus autofocus` toggle only the master switch.
- Do not persist override across reload.
- Edit enUS only for new locale keys (project locale flow for other locales).
- Update README.md, README-wago.md, and README-curseforge.md together.

## File map

| File | Responsibility |
|---|---|
| `modules/Focus/FocusState.lua` | Init session fields |
| `modules/Focus/rendering/FocusAggregator.lua` | Apply branching + override helpers + clear on toggle enable |
| `modules/Focus/interactions/FocusInteractions.lua` | Mark/clear override on player super-track |
| `options/modules/defaults/OptionsDefaultsFocus.lua` | Default `proximityAutoBehaviour` |
| `options/modules/OptionsFocus.lua` | Dropdown UI |
| `locales/horizon/enUS.lua` | Strings |
| README trio | User-facing one-liner |

---

### Task 1: Session state + Apply behaviour branching + helpers

**Files:**
- Modify: `modules/Focus/FocusState.lua` (proximity block ~117–121)
- Modify: `modules/Focus/rendering/FocusAggregator.lua` (`ApplyProximityAutoSuperTrack`, `ToggleProximityAutoSuperTrack`, exports ~989–990)

**Interfaces:**
- Consumes: `addon.focus.proximityClosestQID`, `proximityClosestDistSq`, existing Include Untracked widen logic
- Produces:
  - `addon.ClearProximityManualOverride()` → `nil`
  - `addon.MarkProximityManualOverride(questID)` → `nil` — `questID` number; `0`/nil clears; otherwise sets override when Auto-Focus is on and behaviour is `respectManual`
  - `addon.ApplyProximityAutoSuperTrack()` — extended behaviour (same call sites)
  - DB key `proximityAutoBehaviour`: `"always"` | `"respectManual"` | `"onlyWhenUnfocused"`

- [ ] **Step 1: Add session fields in FocusState**

In the proximity block at the end of `addon.focus = { ... }`, add:

```lua
    -- Proximity sort / Auto-Focus Closest Quest (FocusAggregator RefreshProximityRank).
    -- proximityRank: [questID] = rank (1 = closest). proximityClosestQID/DistSq: nearest candidate.
    proximityRank                     = {},
    proximityClosestQID               = nil,
    proximityClosestDistSq            = nil,
    -- Auto-Focus behaviour (session): last QID we set; true when player overrode under respectManual.
    proximityAutoOwnedQID             = nil,
    proximityManualOverride           = false,
```

- [ ] **Step 2: Add helpers and rewrite Apply / Toggle in FocusAggregator**

Replace `ApplyProximityAutoSuperTrack` through `ToggleProximityAutoSuperTrack` with the following (keep Include Untracked widen block unchanged before the behaviour branch). Place helpers immediately above Apply:

```lua
local VALID_PROXIMITY_AUTO_BEHAVIOUR = {
    always = true,
    respectManual = true,
    onlyWhenUnfocused = true,
}

local function GetProximityAutoBehaviour()
    local mode = addon.GetDB("proximityAutoBehaviour", "always")
    if type(mode) == "string" and VALID_PROXIMITY_AUTO_BEHAVIOUR[mode] then
        return mode
    end
    return "always"
end

--- Clear Respect Manual override and owned QID bookkeeping.
--- @return nil
local function ClearProximityManualOverride()
    local focus = addon.focus
    if not focus then return end
    focus.proximityManualOverride = false
    focus.proximityAutoOwnedQID = nil
end

--- Record a player-driven focus change for Respect Manual behaviour.
--- questID 0/nil clears override (player cleared focus). Other IDs set override when Auto-Focus
--- is on and behaviour is respectManual, unless the ID is the current closest or already owned.
--- @param questID number|nil
--- @return nil
local function MarkProximityManualOverride(questID)
    local focus = addon.focus
    if not focus then return end
    if not questID or questID <= 0 then
        focus.proximityManualOverride = false
        return
    end
    if not addon.GetDB("proximityAutoSuperTrack", false) then return end
    if GetProximityAutoBehaviour() ~= "respectManual" then return end
    if questID == focus.proximityClosestQID or questID == focus.proximityAutoOwnedQID then
        return
    end
    focus.proximityManualOverride = true
end

local function SetOwnedSuperTrack(closest)
    local focus = addon.focus
    if not focus then return end
    local ok, cur = pcall(C_SuperTrack.GetSuperTrackedQuestID)
    if ok and cur == closest then
        focus.proximityAutoOwnedQID = closest
        return
    end
    pcall(C_SuperTrack.SetSuperTrackedQuestID, closest)
    focus.proximityAutoOwnedQID = closest
end

--- Drive super-track to the nearest quest when Auto-Focus Closest Quest is enabled.
--- Behaviour: always | respectManual | onlyWhenUnfocused (DB proximityAutoBehaviour).
--- @return nil
local function ApplyProximityAutoSuperTrack()
    if not addon.GetDB("proximityAutoSuperTrack", false) then return end
    if not (C_SuperTrack and C_SuperTrack.SetSuperTrackedQuestID and C_SuperTrack.GetSuperTrackedQuestID) then return end
    local focus = addon.focus
    if not focus then return end
    local closest, closestDist = focus.proximityClosestQID, focus.proximityClosestDistSq

    -- Optionally widen the candidate pool to the whole quest log (unchanged from prior logic).
    if addon.GetDB("proximityAutoIncludeUntracked", false)
        and C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetInfo
        and C_QuestLog.GetDistanceSqToQuest then
        local rank = focus.proximityRank
        for i = 1, C_QuestLog.GetNumQuestLogEntries() do
            local info = C_QuestLog.GetInfo(i)
            local qid = info and not info.isHeader and not info.isHidden and info.questID
            if qid and qid > 0 and not (rank and rank[qid]) then
                local ok, distSq, onContinent = pcall(C_QuestLog.GetDistanceSqToQuest, qid)
                if ok and onContinent and distSq and (not closestDist or distSq < closestDist) then
                    closest, closestDist = qid, distSq
                end
            end
        end
    end

    if not closest or closest <= 0 then return end

    local behaviour = GetProximityAutoBehaviour()
    local ok, cur = pcall(C_SuperTrack.GetSuperTrackedQuestID)
    if not ok then return end
    cur = cur or 0

    if behaviour == "always" then
        focus.proximityManualOverride = false
        SetOwnedSuperTrack(closest)
        return
    end

    if behaviour == "onlyWhenUnfocused" then
        if cur and cur > 0 then return end
        SetOwnedSuperTrack(closest)
        return
    end

    -- respectManual
    if focus.proximityManualOverride then
        if not cur or cur <= 0 then
            focus.proximityManualOverride = false
        elseif cur ~= focus.proximityAutoOwnedQID then
            -- Still holding a non-owned focus (or owned quest abandoned: treat as gone).
            local stillValid = true
            if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
                local idx = C_QuestLog.GetLogIndexForQuestID(cur)
                if not idx then stillValid = false end
            end
            if stillValid then return end
            focus.proximityManualOverride = false
        end
    end

    if cur and cur > 0 and cur ~= closest and cur ~= focus.proximityAutoOwnedQID then
        focus.proximityManualOverride = true
        return
    end

    SetOwnedSuperTrack(closest)
end

--- Toggle Auto-Focus Closest Quest (slash and keybinding share this path).
--- Enabling clears Respect Manual override so automation resumes.
--- @return boolean New enabled state
local function ToggleProximityAutoSuperTrack()
    local newVal = not addon.GetDB("proximityAutoSuperTrack", false)
    addon.SetDB("proximityAutoSuperTrack", newVal)
    if newVal then
        ClearProximityManualOverride()
    end
    -- ... keep existing print/toast/dashboard refresh/ScheduleRefresh/FullLayout body unchanged ...
    return newVal
end
```

When editing Toggle, only insert the `if newVal then ClearProximityManualOverride() end` after `SetDB`; do not rewrite toast/dashboard logic.

Also clear override when the options UI sets behaviour to `always` (Task 3) and when master toggle is set `true` from options (Task 3).

- [ ] **Step 3: Export helpers**

Next to existing exports:

```lua
addon.ApplyProximityAutoSuperTrack = ApplyProximityAutoSuperTrack
addon.ToggleProximityAutoSuperTrack = ToggleProximityAutoSuperTrack
addon.ClearProximityManualOverride = ClearProximityManualOverride
addon.MarkProximityManualOverride = MarkProximityManualOverride
```

- [ ] **Step 4: Sanity-check Lua syntax**

Run (from repo root, if luacheck is available):

```bash
luacheck modules/Focus/FocusState.lua modules/Focus/rendering/FocusAggregator.lua
```

Expected: no new errors on these files (warnings pre-existing OK).

- [ ] **Step 5: Commit**

```bash
git add modules/Focus/FocusState.lua modules/Focus/rendering/FocusAggregator.lua
git commit -m "feat(focus): Auto-Focus behaviour modes in ApplyProximityAutoSuperTrack"
```

---

### Task 2: Mark override from player super-track clicks

**Files:**
- Modify: `modules/Focus/interactions/FocusInteractions.lua` (`QUEST_ACTIONS["superTrack"]` ~1488–1529; classic icon path ~1112–1129)

**Interfaces:**
- Consumes: `addon.MarkProximityManualOverride(questID)`
- Produces: immediate override on manual focus / clear on unfocus

- [ ] **Step 1: Hook QUEST_ACTIONS["superTrack"]**

After every successful `SetSuperTrackedQuestID` call in that function, notify:

```lua
-- After SetSuperTrackedQuestID(entry.questID):
if addon.MarkProximityManualOverride then
    addon.MarkProximityManualOverride(entry.questID)
end

-- After SetSuperTrackedQuestID(0):
if addon.MarkProximityManualOverride then
    addon.MarkProximityManualOverride(0)
end
```

Apply in all three branches of `QUEST_ACTIONS["superTrack"]` (untracked accepted, untracked unaccepted, toggle on/off).

- [ ] **Step 2: Hook classic icon click path**

In the block around 1113–1122, after set-to-quest and set-to-0:

```lua
if addon.MarkProximityManualOverride then
    addon.MarkProximityManualOverride(questID)  -- or 0 when clearing
end
```

- [ ] **Step 3: Commit**

```bash
git add modules/Focus/interactions/FocusInteractions.lua
git commit -m "feat(focus): mark Auto-Focus manual override on player super-track"
```

---

### Task 3: Options default + dropdown + locale + README

**Files:**
- Modify: `options/modules/defaults/OptionsDefaultsFocus.lua` (~156)
- Modify: `options/modules/OptionsFocus.lua` (~520–521)
- Modify: `locales/horizon/enUS.lua` (~1447–1452)
- Modify: `README.md`, `README-wago.md`, `README-curseforge.md` (Auto-Focus bullet)

**Interfaces:**
- Consumes: DB helpers already in OptionsFocus; `addon.ClearProximityManualOverride`
- Produces: visible dropdown when Auto-Focus on; clears override when enabling Auto-Focus or selecting `always`

- [ ] **Step 1: Default**

```lua
proximityAutoSuperTrack   = false,
proximityAutoBehaviour    = "always",
proximityAutoIncludeUntracked = false,
```

- [ ] **Step 2: Locale keys (enUS)**

Update tip and add:

```lua
L["FOCUS_PROXIMITY_AUTO_SUPERTRACK_TIP"] = "When on, HorizonSuite can focus the nearest tracked quest, re-evaluating as you move. Use Auto-Focus Behaviour to choose whether it always owns focus, yields after you pick a quest by hand, or only fills an empty focus. Toggle on the fly via /h focus autofocus or a keybinding (Key Bindings > Horizon Suite)."
L["FOCUS_PROXIMITY_AUTO_BEHAVIOUR"] = "Auto-Focus Behaviour"
L["FOCUS_PROXIMITY_AUTO_BEHAVIOUR_DESC"] = "How Auto-Focus Closest Quest manages your focused quest."
L["FOCUS_PROXIMITY_AUTO_BEHAVIOUR_TIP"] = "Always Closest continuously focuses the nearest quest. Respect Manual Focus auto-tracks until you focus a different quest, then yields until you clear focus or re-enable Auto-Focus. Only When Unfocused fills an empty focus and never replaces one you already have."
L["FOCUS_PROXIMITY_AUTO_ALWAYS"] = "Always Closest"
L["FOCUS_PROXIMITY_AUTO_RESPECT_MANUAL"] = "Respect Manual Focus"
L["FOCUS_PROXIMITY_AUTO_ONLY_UNFOCUSED"] = "Only When Unfocused"
```

- [ ] **Step 3: Options row**

Replace the Auto-Focus toggle’s `refreshIds` and insert dropdown between Auto-Focus and Include Untracked:

```lua
{ type = "toggle", name = L["FOCUS_PROXIMITY_AUTO_SUPERTRACK"], desc = L["FOCUS_PROXIMITY_AUTO_SUPERTRACK_DESC"], tooltip = L["FOCUS_PROXIMITY_AUTO_SUPERTRACK_TIP"], dbKey = "proximityAutoSuperTrack", isNew = "5.1.3", get = function() return getDB("proximityAutoSuperTrack", D.proximityAutoSuperTrack) end, set = function(v)
    setDB("proximityAutoSuperTrack", v)
    if v and addon.ClearProximityManualOverride then addon.ClearProximityManualOverride() end
    if addon.RequestRefresh then addon.RequestRefresh() end
    if addon.FullLayout then addon.FullLayout() end
end, refreshIds = { "proximityAutoBehaviour", "proximityAutoIncludeUntracked" } },
{ type = "dropdown", name = L["FOCUS_PROXIMITY_AUTO_BEHAVIOUR"], desc = L["FOCUS_PROXIMITY_AUTO_BEHAVIOUR_DESC"], tooltip = L["FOCUS_PROXIMITY_AUTO_BEHAVIOUR_TIP"], dbKey = "proximityAutoBehaviour", isNew = "5.3.4", preserveOrder = true, options = {
    { L["FOCUS_PROXIMITY_AUTO_ALWAYS"], "always" },
    { L["FOCUS_PROXIMITY_AUTO_RESPECT_MANUAL"], "respectManual" },
    { L["FOCUS_PROXIMITY_AUTO_ONLY_UNFOCUSED"], "onlyWhenUnfocused" },
}, get = function() return getDB("proximityAutoBehaviour", D.proximityAutoBehaviour) end, set = function(v)
    setDB("proximityAutoBehaviour", v)
    if v == "always" and addon.ClearProximityManualOverride then addon.ClearProximityManualOverride() end
    if addon.RequestRefresh then addon.RequestRefresh() end
    if addon.FullLayout then addon.FullLayout() end
end, visibleWhen = function() return getDB("proximityAutoSuperTrack", D.proximityAutoSuperTrack) end, id = "proximityAutoBehaviour" },
{ type = "toggle", name = L["FOCUS_PROXIMITY_INCLUDE_UNTRACKED"], ... existing ..., visibleWhen = function() return getDB("proximityAutoSuperTrack", D.proximityAutoSuperTrack) end, id = "proximityAutoIncludeUntracked" },
```

Use the next patch `isNew` version that matches the project’s current versioning at implement time (bump if 5.3.4 is already shipped).

- [ ] **Step 4: README trio**

Replace the Auto-Focus bullet with:

```markdown
- **Auto-Focus Closest Quest** — Optionally super-track the nearest tracked quest (works with any sort mode). Choose **Auto-Focus Behaviour**: Always Closest, Respect Manual Focus, or Only When Unfocused. Optional **Include Untracked Quests** lets a closer log quest take focus even if it isn't on the tracker. Toggle on the fly with `/h focus autofocus` or a keybinding under Key Bindings → Horizon Suite.
```

Apply the same wording to `README-wago.md` and `README-curseforge.md`.

- [ ] **Step 5: Commit**

```bash
git add options/modules/defaults/OptionsDefaultsFocus.lua options/modules/OptionsFocus.lua locales/horizon/enUS.lua README.md README-wago.md README-curseforge.md
git commit -m "feat(focus): Auto-Focus Behaviour options and docs"
```

---

### Task 4: In-game verification

**Files:** none (manual)

- [ ] **Step 1: Reload UI** with Auto-Focus on.

- [ ] **Step 2: Always Closest** — focus a far quest; confirm nearest takes over on next layout/move.

- [ ] **Step 3: Respect Manual Focus** — focus a far quest; confirm it holds while nearby exists; clear focus or `/h focus autofocus` off→on; confirm auto resumes.

- [ ] **Step 4: Only When Unfocused** — with a focus set, move; confirm no swap; clear focus; confirm closest fills.

- [ ] **Step 5: Include Untracked** — still widens pool under each behaviour.

- [ ] **Step 6: Options** — dropdown hidden when Auto-Focus off; slash toggle syncs dashboard if open.

---

## Spec coverage self-check

| Spec requirement | Task |
|---|---|
| Dropdown under Auto-Focus | 3 |
| Defaults `always` | 1–3 |
| Mode matrix | 1 |
| Session owned + override | 1 |
| Mark from tracker clicks | 2 |
| Infer external focus change in Apply | 1 (`respectManual` branch) |
| Clear on empty / toggle on / `always` | 1 + 3 |
| Include Untracked unchanged | 1 |
| README trio | 3 |
| Out of scope (sort, keybinds, persist) | not implemented |

## Placeholder / consistency check

- Helper names: `MarkProximityManualOverride`, `ClearProximityManualOverride` — used consistently in Tasks 1–3.
- DB key: `proximityAutoBehaviour` throughout.
- Values: `always` | `respectManual` | `onlyWhenUnfocused` only.
