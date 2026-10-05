# Dashboard modern style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restyle the settings dashboard as in the approved mockup: grouped rows with inline descriptions, segmented buttons, a restrained accent colour and a three-size type scale.

**Architecture:** Most of the work is in the widget factories (`options/OptionsWidgets.lua`), the card frame (`options/dashboard/DashboardAccordionCard.lua`), the card builder (`options/dashboard/DashboardAccordionBuild.lua`) and the sidebar (`options/dashboard/DashboardSidebar.lua`). Colours, sizes and spacing become `Def` design tokens. Segmented eligibility is a pure helper, so the harness can test it.

**Tech Stack:** Lua 5.1 (WoW addon), fengari test harnesses run with Node.

**Spec:** `Docs/Engineering/2026-10-05-dashboard-modern-style-design.md`. Visual reference: `Docs/Engineering/mockups/2026-10-05-dashboard-modern-style.html` (open it in a browser; "Proposed").

## Global Constraints

- No settings, keys, defaults, getters or setters change. No option-file changes, except adding card `desc` fields where an existing locale string fits, or `segmented = false`.
- Every colour, size and spacing value comes from `Def` (named tokens), not from literals scattered through functions. Values may be tuned, and the mockup is the reference.
- The Axis dashboard settings must keep working: font, size, outline, background theme and class theme (accent). Read how `OptionsWidgets_SetDef`, `typoRefs` and `_refreshDashboardDetailOptionFonts` apply them, and keep every new FontString registered the same way.
- No existing behaviour may regress: search reveal, card open state, header switches, dependent rows, card auto-hide, subheadings and notes, font rows, the colour matrix, reorder lists, the blacklist grid and the Presence preview.
- Lua 5.1 only. Guard texture and mask APIs the way the file already does (for example `widget.CreateTexture` checks), so the code works on both Retail and Forever. For rounded corners, use whatever the codebase already uses (`addon.CreateBorder`, mask textures, existing rounded-backdrop helpers), and check that it exists on Forever (`core/Platform.lua`).
- Tests (all four must pass, run as `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/<file>.js`): `test_options_logic` 219, `test_options_modules` 48, `test_echo_logic` 2837, `test_lootroll_logic` 90. Pure helpers get logic tests. The harness builds no frames, so every task's report lists what to check in game.
- Commits: Conventional Commits. `git add` and `git commit` run as separate commands. Add the trailer `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

---

### Task 1: Tokens, type scale and cards

**Files:**
- `options/OptionsWidgets.lua` (`Def` tokens)
- `options/dashboard/DashboardAccordionCard.lua`
- `options/dashboard/DashboardAccordionBuild.lua` (card spacing; passing the card's description through)
- `tools/test_options_logic.js` (only if a pure helper is added)

- [ ] **Add tokens to `Def`:**
  - `TitleSize`, `HelpSize`
  - `CardBg`, `CardRadius = 12`, `CardGap = 14`, `RowDivider`, `RowHover`
  - `SegTrackBg`, `SegSelectedBg`, `SegSelectedRing`
  - `SidebarSelectedBg`
  - `TextColorMuted` (descriptions and help)

  Derive the sizes from `LabelSize`, so the dashboard text-size setting scales them. Keep the old token names working.
- [ ] **Restyle the card frame:**
  - filled rounded panel with no visible border;
  - semi-bold title in `TitleSize`;
  - optional muted description after the title (from the first section's `desc`), truncated to one line;
  - chevron at the right, with the header switch just left of it.

  The open/close animation, the header switch, the first-card-open rule and saved state are unchanged.
- [ ] **Space cards** `CardGap` apart, and pad each card's content to match the mockup.
- [ ] **Add card descriptions** only where an existing locale string clearly fits (for example a page or section `desc` that already exists). No new locale keys in this task.
- [ ] **Run all four test commands**, then commit `feat(options): restyle dashboard cards`.

### Task 2: Grouped rows and inline descriptions

**Files:**
- `options/OptionsWidgets.lua`: toggle, slider, dropdown (non-embedded), button, editbox, colour swatch, font row, stepper, compact toggle
- `options/dashboard/DashboardAccordionBuild.lua`: row dividers, indent line, hover

- [ ] **Remove boxes and borders.** No row has a box, and its controls sit flat on `Def.InputBg` with radius 8 and no border.
- [ ] **Show the description under the label:** the row's `desc` in `HelpSize`, in `TextColorMuted`, on one line ending in an ellipsis. Set the row height from whether a description is present: about 40px without and 52px with. The full `desc` and `tooltip` stay in the tooltip.
- [ ] **Draw the hairline divider and hover:**
  - a hairline (`RowDivider`) above every row except the first in a card or subheading group;
  - a faint `RowHover` highlight on every row type;
  - the dependent-row accent line at low alpha.
- [ ] **Restyle the controls:**
  - switch pill 36×20, accent when on and `TrackOff` when off;
  - slider with a 4px track, accent fill, white round thumb and the value on the right;
  - colour swatch 22×22, radius 6, hairline ring.
- [ ] **Check the special widgets.** The font row, colour matrix, reorder list, blacklist grid, notes, subheadings and Presence preview must still lay out correctly. Adjust their outer spacing only.
- [ ] **Run all four test commands**, then commit `feat(options): group settings rows with inline descriptions`.

### Task 3: Segmented buttons

**Files:**
- `options/OptionsHelpers.lua` or `options/OptionsWidgets.lua`: a pure helper `addon.SegmentedEligible(opt)` and a pure layout helper `addon.SegmentedFits(labelWidths, available, padding)`
- `options/OptionsWidgets.lua`: `OptionsWidgets_CreateSegmented`
- `options/dashboard/DashboardAccordionBuild.lua`: the dropdown branch picks segmented when it is eligible and fits, falling back to a dropdown
- `OptionsWidgets_CreateFontRow`: the outline part uses the same rule
- `tools/test_options_logic.js`

- [ ] **Write failing logic checks** for eligibility: a static table of 2–4 entries is eligible; 1 or 5 entries, `options` as a function, `searchable`, `fontPreviewInList` or `segmented = false` is not. Add checks for `SegmentedFits`.
- [ ] **Run them; they fail.**
- [ ] **Build the widget** as the spec describes:
  - an inset track with segments sized to their labels;
  - a raised selected segment;
  - get/set, `refreshIds`, disabled visuals, `Refresh` and a tooltip on each segment;
  - registration in `detailOptionFrames`, as for dropdowns.

  Decide whether the segments fit at layout time (`OnSizeChanged`, with the 0.5px guard), and switch to a dropdown when they don't. Building both and showing one is acceptable.
- [ ] **Report the conversions.** In the module test's `--dump`, mark rows that would render segmented with `[seg]`, and list in the report how many rows convert in each module.
- [ ] **Run all four test commands**, then commit `feat(options): show short choices as segmented buttons`.

### Task 4: Accent sweep and sidebar

**Files:** `options/dashboard/DashboardSidebar.lua`, `options/OptionsWidgets.lua`, `options/dashboard/*.lua`.

- [ ] **Restyle the sidebar selection:** a rounded `SidebarSelectedBg` fill (accent at about 16%) with normal text. Unselected items are muted with no box.
- [ ] **Sweep the accent colour.** Grep every use of `AccentColor`, `TrackOn` and `TextColorHighlight` in the dashboard and options widgets. Keep the accent only where the spec allows it:
  - a switch that is on;
  - slider fill;
  - the dependent-row line;
  - the sidebar selection.

  Everything else turns neutral. List each changed use in the report.
- [ ] **Check the class theme.** When the Axis class theme is on, the accent must still follow the class colour.
- [ ] **Run all four test commands**, then commit `feat(options): keep the accent colour for what's on or selected`.
