# Option Defaults Review

## Context

After the sidebar reorganization (25 → 17 categories), we reviewed whether option defaults are appropriate. The goal: identify which features are core (ON by default — the out-of-box experience) vs optional extras (OFF by default — power-user or niche). Then flag any misalignments.

**Key file:** `options/OptionsData.lua` — all defaults defined inline via `getDB(key, default)`.

---

## Current Default Audit

### Focus — Layout

| Option | Default | Category |
|--------|---------|----------|
| Lock position | OFF | Extra — user places first |
| Grow upward | OFF | Extra — niche layout pref |
| Start collapsed | OFF | Extra — niche |
| Backdrop opacity | 0.3 | Core slider |
| Panel width / max height | sliders | Core sliders |
| Show border | OFF | Extra — visual pref |
| Scroll indicator | OFF | Extra — visual pref |
| All instance visibility (dungeon/raid/BG/arena) | OFF | Correct — tracker is open-world by default |
| Combat visibility | "show" | Core |
| Mouseover only | OFF | Extra — niche |
| Current zone only | OFF | Extra — niche |
| Compact mode | OFF | Extra |
| Spacing sliders | 8/6/2/4 | Core defaults |

### Focus — Display

| Option | Default | Category |
|--------|---------|----------|
| Quest count | ON | Core — shows tracked count |
| Header divider | ON | Core — visual structure |
| Minimal mode | OFF | Extra — hides header |
| Options button | ON (inverted key) | Core |
| Section headers | ON | Core — category labels |
| Section dividers | OFF | Extra — visual pref |
| Sections when collapsed | OFF | Extra |
| Current Zone group | ON | Core — key UX feature |
| Zone labels | ON | Core — context per quest |
| Quest item buttons | OFF | Extra |
| Entry numbers | ON | Core — scannable list |
| Completed count | OFF | Extra — X/Y in title |
| Progress bar | OFF | Extra |
| Category color for bar | ON | Core (dependent on bar) |
| Show timer | OFF | Extra |
| Timer display | "inline" | Core default when enabled |
| Color timer by remaining | OFF | Extra |
| Checkmark for completed | OFF | Extra — visual pref |
| Quest type icons | OFF | Extra |
| Auto-track icon | ON | Core — indicates auto-tracked |
| Quest level | OFF | Extra — niche |
| Dim unfocused | OFF | Extra |

### Focus — Typography

| Option | Default | Category |
|--------|---------|----------|
| Show text shadow | ON | Core — readability |
| Font/size/case sliders | various | Core defaults |

### Focus — Interactions

| Option | Default | Category |
|--------|---------|----------|
| Ctrl for focus/untrack | OFF | Extra — modifier pref |
| Classic clicks | OFF | Extra — alt click scheme |
| Ctrl to click-complete | OFF | Extra |
| Auto-track accepted quests | ON | Core |
| Suppress untracked until reload | OFF | Extra |
| Blacklist untracked | OFF | Extra |
| Animations | ON | Core |
| Objective progress flash | ON | Core |

### Focus — Instances

| Option | Default | Category |
|--------|---------|----------|
| Show Mythic+ block | OFF → ON | Core — M+ is core endgame |
| Always show M+ block | OFF | Extra |
| Show affix icons | ON | Core (when block shown) |
| Show affix descriptions | ON | Core (when block shown) |
| Scenario events | ON | Core — Delves/scenarios tracked |
| Delve/Dungeon only | OFF | Extra — hides other categories |
| Delve affix names | ON | Core |
| Scenario bar | ON | Core |

### Focus — Content

| Option | Default | Category |
|--------|---------|----------|
| In-zone world quests | ON | Core |
| Rare bosses | ON | Core |
| Rare sound alert | ON | Core |
| Achievements | ON | Core |
| Include completed achievements | OFF | Extra |
| Achievement icons | ON | Core |
| Missing criteria only | OFF | Extra |
| Endeavors | ON | Core |
| Include completed endeavors | OFF | Extra |
| Decor | ON | Core |
| Decor icons | ON | Core |
| Traveler's Log | ON | Core |
| Untrack when complete | ON | Core |
| Floating quest item | OFF | Extra |

### Presence — General

| Option | Default | Category |
|--------|---------|----------|
| Toast icons | inherits showQuestTypeIcons → OFF (now ON) | Review — decoupled, default ON |
| Discovery line | ON | Core |
| Animations | ON | Core |
| Frame Y / scale / durations | sliders | Core defaults |

### Presence — Notifications

| Option | Default | Category |
|--------|---------|----------|
| Zone entry | ON | Core |
| Subzone changes | inherits zone entry → ON | Core |
| Subzone only | OFF | Extra |
| Suppress in M+ | ON | Core — reduces noise |
| Suppress in dungeon/raid/PvP/BG | OFF | Extra — per-instance opt-in |
| Level up | ON | Core |
| Boss emotes | ON | Core |
| Achievements | ON | Core |
| Quest accept/complete/world/progress | inherit presenceQuestEvents → ON | Core |
| Scenario start/progress/complete | inherit showScenarioEvents → ON | Core |
| Rare defeated | ON | Core |
| Color by zone type | OFF | Extra — visual pref |

### Presence — Typography

Fonts, sizes, colors — all core styling defaults. No toggles to review.

### Insight — Tooltips

| Option | Default | Category |
|--------|---------|----------|
| Guild rank | ON | Core |
| PvP title | ON | Core |
| Honor level | ON | Core |
| Status badges | ON | Core |
| Mythic+ score | ON | Core |
| Item level | ON | Core |
| Mount info | ON | Core |
| Transmog status | ON | Core |

**Note:** Insight module itself defaults to disabled. So all features being ON is correct — when you opt into the module, you get the full experience. Individual features are opt-out.

### Vista — Minimap

| Option | Default | Category |
|--------|---------|----------|
| Circular minimap | OFF | Extra — major visual change |
| Lock position | ON | Core — prevents accidental drag |
| Zone text | ON | Core |
| Coordinates | ON | Core |
| Show time | OFF → ON | Core — QoL time display |
| Local time | OFF → ON | Core — real-world time |
| Tracking button | ON | Core |
| Tracking mouseover | ON | Core — hover reveal |
| Calendar button | ON | Core |
| Calendar mouseover | ON | Core |
| Zoom buttons | ON | Core |
| Zoom mouseover | ON | Core |

### Vista — Appearance

| Option | Default | Category |
|--------|---------|----------|
| Border | ON | Core |
| All lock toggles | ON | Core — prevents accidental drag |
| Queue handling disabled | OFF | Core (inverted — handling is ON) |
| Mail blink | ON | Core |
| Bar border | OFF | Extra |

### Vista — Addon Buttons

| Option | Default | Category |
|--------|---------|----------|
| Manage addon buttons | ON | Core |
| All button managed toggles | ON | Core — collect by default |
| Drawer/mouseover/rightclick locks | various | Core |
| Mouseover bar visible | OFF | Extra |

---

## Assessment

### Overall philosophy (well-executed)

The defaults follow a clear, consistent philosophy:

1. **Content ON, visual extras OFF** — All content types (world quests, rares, achievements, endeavors, decor, scenarios) are tracked by default. Visual enhancements (progress bars, timers, quest icons, dim effects) are opt-in.
2. **Structure ON, decoration OFF** — Headers, section headers, zone labels, entry numbers, dividers are ON. Borders, section dividers, completed counts are OFF.
3. **Module-level gating** — Insight and Cache are disabled modules. All their individual features default ON, which is correct: opting into the module gives you everything; you opt out of specific features.
4. **Instance content is opt-in** — Tracker hides in dungeons/raids/PvP by default. M+ block was OFF; now ON (M+ is core endgame).
5. **Notifications are generous** — Almost all Presence notification types are ON. This is good: the notification system is ambient and non-intrusive, so "show me everything" is the right default.

### Flags for discussion

#### 1. Toast icons (Presence) — inherits showQuestTypeIcons → OFF

**Current (before fix):** `showPresenceQuestTypeIcons` fell back to `getDB("showQuestTypeIcons", false)` — the Focus tracker setting. So toast icons were OFF because Focus quest type icons are OFF.

**Issue:** These are unrelated contexts. Focus quest type icons add visual density to a compact list (reasonable OFF). But Presence toasts are large, one-at-a-time cinematic banners where an icon adds useful context without clutter.

**Recommendation (implemented):** Change Presence toast icons to default ON independently (`getDB("showPresenceQuestTypeIcons", true)`). The inheritance from Focus made sense historically but creates a confusing dependency.

#### 2. Show Mythic+ block — OFF

**Current (before fix):** The M+ timer/affix block didn't show by default even when you're in an M+ dungeon.

**Issue:** M+ is core endgame content. If you're running a key, seeing the timer and affixes in the tracker is expected. This should be ON.

**Recommendation (implemented):** Change `showMythicPlusBlock` to default ON.

#### 3. Scroll indicator — OFF

**Current:** No hint that the list is scrollable.

**Assessment:** Could argue for ON since discoverability matters, but the tracker auto-scrolls to focused content. The indicator would be visible noise most of the time. **Keep OFF.**

#### 4. Show time (Vista) — OFF

**Current (before fix):** Clock and local time not shown on minimap by default.

**Issue:** Having a time display on the minimap is a core quality-of-life feature. Local time is what most players actually want to see. Both should be ON.

**Recommendation (implemented):** Change `vistaShowTimeText` to default ON and `vistaTimeUseLocal` to default ON.

#### 5. Quest type icons (Focus) — OFF

**Current:** No quest type icons in the tracker list.

**Assessment:** Correct. The tracker is text-focused by design. Icons add visual weight. Players who want them can enable them. **Keep OFF.**

#### 6. Progress bar (Focus) — OFF

**Assessment:** Correct. Progress bars under objectives are a visual extra. The text already shows "3/10" — the bar is supplementary. **Keep OFF.**

---

## Recommended Changes (implemented)

### Change 1: Presence toast icons → ON by default

**File:** `options/OptionsData.lua` (line ~1209)

**Before:**
```lua
get = function() local v = getDB("showPresenceQuestTypeIcons", nil); if v == nil then return getDB("showQuestTypeIcons", false) end; return v end
```

**After:**
```lua
get = function() return getDB("showPresenceQuestTypeIcons", true) end
```

**Rationale:** Toast icons and Focus tracker icons serve different purposes. Presence toasts are cinematic — an icon enriches them. The inheritance from Focus was a shortcut that creates confusing coupling. New installs get toast icons; existing users who never touched the setting will see icons appear (minor, positive change).

### Change 2: Show Mythic+ block → ON by default

**File:** `options/OptionsData.lua` (line ~1112)

**Before:** `get = function() return getDB("showMythicPlusBlock", false) end`

**After:** `get = function() return getDB("showMythicPlusBlock", true) end`

**Rationale:** M+ is core endgame content. When running a key, players expect to see the timer and affixes. The block only appears during active keystones anyway, so there's no downside to defaulting it ON.

**Also:** Wire `showMythicPlusBlock` into `FocusMplusBlock.lua` (was using `showInDungeon` for block visibility; the option existed but wasn't used).

### Change 3: Vista show time → ON by default

**File:** `options/OptionsData.lua` (line ~1359)

**Before:** `get = function() return getDB("vistaShowTimeText", false) end`

**After:** `get = function() return getDB("vistaShowTimeText", true) end`

**Also:** Update the disabled check on local time (line ~1366) to match: `disabled = function() return not getDB("vistaShowTimeText", true) end`

### Change 4: Vista local time → ON by default

**File:** `options/OptionsData.lua` (line ~1364)

**Before:** `get = function() return getDB("vistaTimeUseLocal", false) end`

**After:** `get = function() return getDB("vistaTimeUseLocal", true) end`

**Rationale for 3 & 4:** Time on the minimap is a core QoL feature. Local time (real-world clock) is what most players want to see at a glance. New installs should show it; existing users who never touched the setting will see time appear (positive change).

---

## Implementation

1. Apply the 4 default changes in `options/OptionsData.lua`
2. Update any disabled functions that reference the old default values (e.g. `vistaShowTimeText` used as `false` in disabled checks)
3. Update runtime consumers: `PresenceCore.lua`, `FocusMplusBlock.lua`, `VistaCore.lua`
4. Save this review document as `docs/defaults-review.md` for future reference

### Files modified

| File | Changes |
|------|---------|
| `options/OptionsData.lua` | 4 getter defaults + 1 disabled default |
| `modules/Presence/PresenceCore.lua` | Toast icon fallback → `true` |
| `modules/Focus/FocusMplusBlock.lua` | Use `showMythicPlusBlock` instead of `showInDungeon` |
| `modules/Vista/VistaCore.lua` | `ShowTime` and `TimeUseLocal` defaults → `true` |

---

## Verification

1. **New install:** Presence toast notifications for quest accept/complete should show an icon
2. **New install:** Vista minimap should show a local-time clock
3. **New install:** M+ block should appear when entering a Mythic+ dungeon
4. **Existing user who never changed these settings:** Will see toast icons + time + M+ block appear (positive, non-disruptive)
5. **Existing user who explicitly set any of these to true/false:** No change (their saved value takes precedence)
6. **Focus quest type icons** remain OFF by default — unaffected

---

## Everything else: keep as-is

The remaining defaults are well-calibrated. The "content ON, visual extras OFF" philosophy is consistent and user-friendly. No other changes needed.
