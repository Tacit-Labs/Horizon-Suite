# Dashboard premium polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add smooth switch and slider motion, press feedback, staggered card opening and changed-from-default markers to the settings dashboard.

**Architecture:** Motion helpers and tokens go in `options/OptionsWidgets.lua`. Card opening lives in `options/dashboard/DashboardAccordionBuild.lua` and `options/dashboard/DashboardAccordionCard.lua`. Default lookup and change detection are pure helpers in `options/OptionsHelpers.lua`, so the harness can test them. The markers are drawn by the row factories and the card builder.

**Tech Stack:** Lua 5.1 (WoW addon), fengari test harnesses run with Node.

**Spec:** `Docs/Engineering/2026-10-05-dashboard-premium-polish-design.md`

## Global Constraints

- **Tokens:** every duration, scale and offset is a `Def` token: `MotionFast` 0.12, `MotionPress` 0.06, `PressScale` 0.97, `SliderThumbHoverScale` 1.15, `RowStagger` 0.02, `RowStaggerCap` 0.25, `RowRise` 6, plus the marker size and colours.
- **Animations:** each runs on its widget's `OnUpdate` and is cleared on `OnHide`. Its end state is exact, whether it finishes, is interrupted or is hidden. Changes from outside a row snap.
- **Saved values:** none change, except an explicit reset click.
- **No regressions:** segmented slide, font rows, the colour matrix, search reveal, card open state, header switches, dependent rows, auto-hide, subheadings and the Presence preview all keep working.
- **Platforms:** Lua 5.1, Retail and Forever.
- **Tests:** all four must pass, each run as `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/<file>.js`: `test_options_logic` 273+, `test_options_modules` 48, `test_echo_logic` 2837, `test_lootroll_logic` 90. Every pure helper gets logic tests. Each report includes an in-game checklist.
- **Commits:** Conventional Commits, with `git add` and `git commit` run as separate commands and the trailer `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

---

### Task 1: Smooth switches and sliders; press feedback (spec items 1 and 2)

**Files:** `options/OptionsWidgets.lua` (toggle, compact toggle, slider, segmented, dropdown button, stepper, button), `options/dashboard/DashboardAccordionCard.lua` (header switch), `tools/test_options_logic.js` (pure easing and tween helpers).

- [ ] Add a small shared tween helper in `OptionsWidgets.lua`. It runs a 0→1 progress on `OnUpdate` with `addon.easeOut`, stops on hide and calls a finish callback. Export any pure maths for tests.
- [ ] Switches animate on a player click and snap on outside changes. The pattern is a click flag consumed by the next value paint, as the segmented control does.
- [ ] Slider thumbs grow on hover and drag, and the value text tweens on click or type changes.
- [ ] Add press feedback to the controls listed in the spec through one helper: `SetScale` on `OnMouseDown`/`OnMouseUp`/`OnHide`, guarded for disabled. Keep anchors stable, scaling about the centre. Check that scaling a child doesn't shift its anchor offsets; if it does, scale an inner visual frame instead.
- [ ] Run all four test commands, then commit `feat(options): animate switches and sliders, and press feedback`.

### Task 2: Staggered card opening (spec item 3)

**Files:** `options/dashboard/DashboardAccordionBuild.lua`, `options/dashboard/DashboardAccordionCard.lua`.

- [ ] On a player-initiated expand, fade and rise each visible row with a stagger capped at `RowStaggerCap`.
- [ ] Skip the stagger for saved-state opens at build, search jumps and `SetExpandedInstant`.
- [ ] Rows end exactly in place at alpha 1, even if the card is closed mid-sequence or relaid out. Row offsets must not fight `DoInstantRelayout`: animate a per-row visual offset that relayout reapplies, or animate alpha only and set the rise through the anchor at the end of each relayout.
- [ ] Run all four test commands, then commit `feat(options): stagger rows in as a card opens`.

### Task 3: Changed-from-default markers (spec item 4)

**Files:**
- `options/OptionsHelpers.lua`: `addon.OptionDefault(key, row)`, `addon.OptionIsChanged(row, getStored)` (pure: the stored-value getter is injected), and `addon.OptionStoredValue`
- `options/OptionsWidgets.lua`: marker dot and reset arrow in the shared row text helper
- `options/dashboard/DashboardAccordionBuild.lua`: per-card count and live updates
- `options/dashboard/DashboardAccordionCard.lua`: the "N changed" text
- `locales/horizon/*.lua`: the "%d changed" and reset tooltip strings, in enUS with stubs elsewhere
- `tools/test_options_logic.js`
- `tools/test_options_modules.js`: coverage, the share of rows with a resolvable default, per module in `--dump`

Steps:
- [ ] **Failing checks first:**
  - the default comes from `row.default` first, then the module tables;
  - unknown key → nil;
  - stored nil → not changed;
  - stored equal to default → not changed;
  - numbers within tolerance → not changed;
  - colour tables compared field by field;
  - split R/G/B/A keys;
  - a font row is changed when any part is.
- [ ] **Implement the helpers**, reading the stored value directly from the active profile (no default fallback). Find the right accessor in `core/Core.lua`.
- [ ] **Build the markers:**
  - the dot in the gutter and the reset arrow on hover, as in the spec;
  - reset runs the row's `set(default)`, then `SetDB(key, nil)`, then refreshes the row and its `refreshIds`;
  - the card count updates on every row refresh and after a profile switch (find the profile-change refresh path);
  - exclusions as in the spec.
- [ ] **Run all four test commands**, add the coverage numbers to the report, then commit `feat(options): mark settings changed from their default`.
