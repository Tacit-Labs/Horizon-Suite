# Flow: the quest box

**Date:** 2026-09-18
**Status:** Approved for planning
**Module:** Flow (new)

## Goal

Bring the NPC quest dialogue window in line with the design language of Focus and
Presence: Horizon chrome and typography, objectives above the fold, and a quest
that reads as part of the same product as the tracker sitting next to it.

Horizon draws the window's chrome, header, footer and an objectives band.
Blizzard keeps the body text layout and every control that grants loot. Flow
never calls `AcceptQuest` or `GetQuestReward`.

In simple terms: the parchment box becomes a Horizon box, tells you what to do
before it tells you why, and Blizzard still hands you the reward.

## Locked decisions

| Decision | Choice |
|----------|--------|
| Module | **New module, `flow`**, order 28, colour `#3399FF` |
| Approach | **Host, do not reparent** — `QuestFrame` stays the frame and Horizon dresses it |
| Surface | Giver dialogue only: Detail, Progress, Reward, Greeting panels |
| Layout | Horizon-drawn objectives band, flavour text collapsed behind an expander |
| Hook point | `hooksecurefunc("QuestInfo_Display", …)` |
| Style source | **Flow's own** appearance settings, defaulting to match Focus |
| Default state | **Off**, per Essence |
| Platform gating | None required |
| Reward upgrade hints | v2 |
| Quest log and journal | v3 |

## Why a new module

Augment is a bag of self-contained Blizzard quality-of-life improvements, each
one a single frame or behaviour with no options surface of its own. The skinned
loot window fits there because it is one frame driven by one existing style
setting.

The quest box is not that. It has its own information architecture, its own
appearance settings, a real risk profile if it breaks, and a growth path into
the quest log and journal. Essence is the precedent: a whole module whose job is
replacing a core Blizzard frame, shipped disabled by default.

The name and colour already exist. `Flow` / `#3399FF` is reserved in
`Docs/Branding/ColourSchema.md` and in the patch-notes colour map at
`options/dashboard/DashboardPatchNotesContent.lua:36`, with nothing behind it.

## Problem this fixes

Four complaints, all of them live at once:

1. **Visual mismatch.** Parchment, gold filigree and Friz Quadrata next to
   Focus's dark panel, class tint and chosen font.
2. **Hard to read what is asked.** The objective sits under paragraphs of
   flavour text.
3. **Rewards lack weight.** Picking an epic reads exactly like handing in a
   daily.
4. **Interaction friction.** Greeting lists, button placement, no signal about
   which reward is an upgrade.

v1 answers 1 and 2 fully, 3 and 4 partially. v2 finishes 3.

## Architecture

### 1. Host, do not reparent

`QuestFrame` is registered in `UIPanelWindows`, which owns its show and hide,
ESC handling, panel stacking and auto-close on range. A separate Horizon shell
would mean fighting that system, and `SetParent` on a UIPanel frame is a known
taint vector.

It is also unnecessary. `QuestInfo_Display` already calls `SetParent` and
`SetAllPoints` on its parent panel every time it runs. So `QuestFrame` stays the
frame, stays in the UIPanel system, and Flow dresses it:

- Strip the parchment art and NineSlice.
- Apply Horizon backdrop, border and class-tinted header.
- Add header, footer and objectives band as children of `QuestFrame`.
- Resize to Horizon proportions.

Flow never calls `Show`, `Hide` or `SetParent` on `QuestFrame`, so combat needs
no special casing.

### 2. Template element ordering

`QuestInfo` renders from global template tables. At enable, Flow deep-copies
`QUEST_TEMPLATE_DETAIL`, `QUEST_TEMPLATE_PROGRESS` and `QUEST_TEMPLATE_REWARD`,
then installs replacements whose `elements` arrays put objectives above flavour
text. The originals are restored on disable.

Scoping by template also contains the blast radius. The map details pane renders
from `QUEST_TEMPLATE_MAP_DETAILS`, which Flow never touches, so the map and
`QuestLogPopupDetailFrame` stay stock Blizzard while Flow is on.

### 3. The objectives band

Flow hides Blizzard's objectives element and draws its own band above the body.

What the band can show depends on what the API has:

| Panel | Source | Renders as |
|---|---|---|
| Detail, quest not yet accepted | `GetObjectiveText()` | one styled prose line |
| Progress, Reward, anything in the log | quest log leaderboards | bullets with `x/y` counts |

This is a game constraint, not a limitation of the approach: you cannot have
progress on a quest you have not taken. Blizzard's own templates reflect it,
which is why `QUEST_TEMPLATE_DETAIL` uses `QuestInfo_ShowObjectivesText` while
`QUEST_TEMPLATE_LOG` uses `QuestInfo_ShowObjectives`. The band is present and
styled in both cases; only its internal shape changes.

Everything the band reads is read-only API.

### 4. Typography and colour

Fonts are set on the specific fontstrings after each display. Never on the
global font objects, which would leak across the whole UI.

For text colour the intended path is Blizzard's own material system: register a
Horizon entry in the material colour table and have `QuestFrame_GetMaterial`
return it, so recolouring flows through Blizzard's code rather than Flow chasing
fontstrings. Exact names need verifying in-game, with per-fontstring
recolouring as the fallback.

### 5. Data flow

Blizzard fires `QUEST_DETAIL`, `QUEST_PROGRESS` or `QUEST_COMPLETE`.
`QuestFrame` shows the matching panel and calls `QuestInfo_Display` with the
relevant template. Flow attaches through `hooksecurefunc`, which runs after
Blizzard's layout and cannot taint it. In that post-hook Flow hides the
objectives element, rebuilds and positions the band, applies fonts and colours,
and sizes the frame.

One hook point, one code path, all panels.

### 6. Lifecycle

| Event | Behaviour |
|---|---|
| Flow enable | copy and replace templates, install hooks, skin `QuestFrame` if loaded |
| `QuestInfo_Display` | rebuild band, restyle, resize |
| `QuestFrame` show | entrance on alpha and scale, cosmetic only |
| Setting change | apply on next open, immediately if shown |
| Flow disable | restore templates and art, drop regions, unhook |
| `/h flow restore` | same teardown without clearing the enabled flag |
| `/reload` | clean slate |

`/h flow restore` exists because the failure this design most needs to survive
is a player stuck mid-quest-chain unable to turn anything in. Styling passes run
under `pcall`, so a Lua error degrades to an ugly quest box rather than an
unusable one.

## Module skeleton

| File | Purpose |
|---|---|
| `modules/Flow/FlowModule.lua` | `RegisterModule("flow", …)`, Essence-shaped |
| `modules/Flow/FlowCore.lua` | chrome, hooks, teardown |
| `modules/Flow/FlowQuestBand.lua` | the objectives band |
| `modules/Flow/FlowTemplates.lua` | template copy, replace and restore |
| `modules/Flow/FlowSlash.lua` | `/h flow`, `/h flow restore` |
| `options/modules/defaults/OptionsDefaultsFlow.lua` | `FLOW_KEYS`, `FLOW_DEFAULTS`, `FLOW_LIMITS` |
| `options/modules/OptionsFlow.lua` | `OptionCategories` entry, `moduleKey = "flow"` |
| `HorizonSuite.lua` | seed `db.modules.flow = { enabled = false }` plus an existing-install guard |
| `core/Config.lua` | module name maps |
| `HorizonSuite.toc` | new load block |
| `locales/horizon/enUS.lua` | new keys, enUS only |
| `.luacheckrc` | new Blizzard globals |
| `README.md` | new module section |

Flow joins the Axis global toggles for class tint and per-module scale, beside
Focus, Presence, Vista, Insight and Essence.

File split is deliberate. `FocusLayout.lua` at 1938 lines and
`PresenceCore.lua` at 2052 are the shape to avoid, not to copy.

## Options

Flow carries its own appearance settings rather than reading Focus's. Coupling
them would mean reconfiguring or disabling Focus silently changes the quest box.
Defaults are chosen to match Focus out of the box, so it looks consistent
without being dependent.

- Backdrop colour and opacity
- Border on or off
- Font and size
- Entrance animation on or off
- Collapse flavour text by default, remembered per profile
- Quest type pill on or off

Option text should say that Flow takes the result when ElvUI or EllesmereUI
also skin the quest frame.

## Platform

Quest givers are identical on Retail and the Forever beta, so nothing here needs
a `Platform.Has()` guard. Flow works on both clients on day one, unlike anything
touching delves, housing or Mythic+.

## Out of scope for v1

- Reward tiles with quality colouring and item level upgrade hints (v2)
- Greeting list rework (v2)
- Quest log and journal (v3)
- The map details pane and `QuestLogPopupDetailFrame`, which stay stock Blizzard
- A movable or resizable Flow window; `QuestFrame` keeps UIPanel positioning
- Reimplementing any reward or acceptance call
- Detecting other skinning addons and standing down

## Edge cases

- Auto-accepted quests, where the Detail panel may never show
- Quests with required items on the Progress panel
- An NPC offering several quests at once, through the Greeting panel
- Spell, currency and follower rewards
- Warmode bonus rows
- A quest whose objective text is empty
- Map pane and `QuestLogPopupDetailFrame` opened while Flow is enabled
- Module disabled mid-quest-chain
- ElvUI or EllesmereUI skinning the same frame
- Combat: appearance only, no protected calls

## Success criteria

- [ ] Accept and decline both work
- [ ] Completing a quest with a choice of rewards delivers the chosen item
- [ ] Objectives render above flavour text on all three panels
- [ ] Band shows bullets with counts where the API has them, a prose line where it does not
- [ ] Flavour text expander collapses, expands, and remembers the preference
- [ ] Greeting panel with several quests still selects correctly
- [ ] Required-item Progress panel renders and completes
- [ ] Map details pane and `QuestLogPopupDetailFrame` render as stock Blizzard while Flow is on
- [ ] Disabling Flow restores the parchment frame without a reload
- [ ] `/h flow restore` recovers a broken state mid-chain
- [ ] Runs on the Forever beta as well as Retail
- [ ] Runs with ElvUI's quest skin active without visual garbage
- [ ] `luacheck` clean

## Open for the implementation plan

Verification items, not design blockers:

- Real names behind the material colour table and `QuestFrame_GetMaterial` on Midnight
- Whether the Greeting panel routes through `QuestInfo_Display` at all
- Current `QUEST_TEMPLATE_*` element tuple shape
- Whether `QuestFrame` tolerates the resize Horizon proportions want, inside UIPanel layout

All settle in one in-game spike on the Windows client, run against both Retail
and the Forever install.
