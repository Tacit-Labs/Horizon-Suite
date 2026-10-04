# Dashboard font row Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace each module's separate font, size and outline rows with one font row.

**Architecture:** A new `fontRow` option type. The helper `addon.FontRow` builds it, the assembler indexes its part keys, search picks up its keywords, and a builder branch in `DashboardAccordionBuild.lua` draws the row. That branch reuses the dropdown factory through a small layout option instead of copying its list code. Module files then swap their blocks for font rows.

**Tech Stack:** Lua 5.1 (WoW addon), fengari test harnesses run with Node.

**Spec:** `Docs/Engineering/2026-10-05-dashboard-font-row-design.md`

## Global Constraints

- No saved-setting key, default or getter/setter behaviour changes. A part's get and set are the old row's get and set, moved unchanged.
- Each replaced row's name goes into the font row's `keywords`, so old searches still match.
- A font row is advanced exactly when its family part (or, without one, its size part) was advanced. Rows that used to `parent` a part key must keep working (the assembler resolves part keys).
- Size stepper: clamps to the old slider's min and max, and steps by its step (1 when none was set).
- The row stays a single line at 640px wide or more; below that it wraps to two lines.
- No list, search or font-preview code may be copied out of `OptionsWidgets_CreateCustomDropdown`; extend that factory with an optional trailing layout table instead.
- Tests (all must pass, with no new failures), each run as `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/<file>.js`: `test_options_logic.js` (baseline 145), `test_options_modules.js` (39), `test_echo_logic.js` (2837), `test_lootroll_logic.js` (90).
- Commits: Conventional Commits. `git add` and `git commit` run as separate commands. Add the trailer `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Lua style: match the surrounding file.

---

### Task 1: The font row type

**Files:**
- Modify: `options/OptionsHelpers.lua` (add `FontRow` helper, exported as `addon.FontRow`)
- Modify: `options/OptionsAssemble.lua` (part keys in `ExpandParents` lookup; Copy keeps parts)
- Modify: `options/OptionsSearch.lua` (only if needed for keywords/name; it likely works as is)
- Modify: `options/OptionsWidgets.lua` (dropdown factory: optional trailing `layout` table `{ embedded = true }` that skips the label, desc, row hover and row tooltip and lets the caller size and anchor the button; plus a new `OptionsWidgets_CreateSizeStepper`)
- Modify: `options/dashboard/DashboardAccordionBuild.lua` (new `elseif opt.type == "fontRow"` branch)
- Modify: `locales/horizon/enUS.lua` (any new strings, such as the toggle's "Outline" label if no existing key fits), with commented stubs in the other locales
- Modify: `tools/test_options_logic.js`, `tools/test_options_modules.js` (dump prints font rows with their parts)

**Interfaces:**
- Produces: `addon.FontRow(name, desc, parts, opts)`, which returns `{ type = "fontRow", name, desc, dbKey = <primary>, parts = { family?, size?, outline? }, ... }` with `opts` merged (advanced, parent, parentIs, keywords, visibleWhen, disabled, tooltip, isNew, id). `parts.outline.kind` is `"dropdown"` (the default) or `"toggle"`.

- [ ] **Step 1: Failing logic checks**:
  1. `FontRow` sets `dbKey` to the family key, or to the size key when there is no family.
  2. A row whose `parent` names a font row's outline part key shows or hides with that part's value.
  3. A font row is indexed by search once, and a query for one of its keywords finds it.
  4. A font row marked `advanced` goes behind More like any row.
- [ ] **Step 2: Run them; they fail.**
- [ ] **Step 3: Implement the helper and the assembler and search changes.** Make the checks pass.
- [ ] **Step 4: Build the widget.**
  - Add the dropdown factory's `layout` option. Without it, behaviour must be byte-for-byte unchanged.
  - Add the size stepper: − and + buttons, a value editbox, clamping, disabled visuals, `Refresh`.
  - Add the `fontRow` builder branch. It draws a container frame the height of a normal row, with the label on the left and the controls right-aligned in the order font, size, outline. It re-lays out on `OnSizeChanged` (with a 0.5px guard, as `colorMatrix` does) and wraps to two lines below 640px.
  - The row has one `Refresh` that refreshes all parts and its own disabled state. It is registered in `detailOptionFrames` under every part key.
  - Each part's `set` calls `RefreshLinkedTargets(part.refreshIds)`.
  - Give the row the row tooltip and hover highlight, and give each control its own tooltip.
  - Support `indent` and `visibleWhen` the way the generic post-processing already does for other widgets.
- [ ] **Step 5: Run all four test commands; they pass.** Because the harness builds no frames, also review your builder code against the colorMatrix branch for anchoring and parenting.
- [ ] **Step 6: Commit** `feat(options): add a font row that sets font, size and outline together`.

### Task 2: Augment and Axis font rows

**Files:** `options/modules/OptionsAugment.lua`, `OptionsAugmentAlerts.lua`, `OptionsAugmentLootRoll.lua`, `OptionsAugmentTalkingHead.lua`, `options/modules/OptionsGlobal.lua`.

- [ ] Replace each block listed in the spec's table with one `FontRow`. Move the get, set, options, min, max, step and refreshIds into the parts unchanged. Put the old row names in `keywords`. The Talking Head outline parts use `kind = "toggle"`.
- [ ] Run the before and after `--dump`. Every replaced key must still appear, as a part.
- [ ] Run all four test commands; they pass. Commit `refactor(options): use font rows in Augment and the dashboard settings`.

### Task 3: Vista, Focus and Presence font rows

**Files:** `options/modules/OptionsVista.lua`, `options/modules/OptionsFocus.lua`, `options/modules/OptionsPresence.lua`.

- [ ] Same as Task 2, following the spec's table.
  - **Focus:** the main row is font + outline (`fontOutline`), everyday. The seven per-element rows are font + size, advanced, with `parent = "usePerElementFonts"`. Header size, the global size offset and the M+ and run-timer sizes stay as sliders.
  - **Presence:** discovery is font + size + outline. Title and subtitle are font + outline, and their sizes stay as sliders. Keep `refreshIds = { "presencePreview" }` on every part.
- [ ] Run the before and after `--dump`, then all four test commands. Commit `refactor(options): use font rows in Vista, Focus and Presence`.
