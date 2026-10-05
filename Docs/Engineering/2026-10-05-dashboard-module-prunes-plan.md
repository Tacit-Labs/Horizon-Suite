# Dashboard module prunes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make every dashboard card open short by marking niche rows `advanced` and converting simple `visibleWhen` dependencies to `parent`, module by module, Focus first.

**Architecture:** One assembler change (chained parents) in `options/OptionsAssemble.lua`, a `--dump` flag on the module test so results are reviewable without the game, then one data-only task per module that edits row tables in `options/modules/*.lua`.

**Tech Stack:** Lua 5.1 (WoW addon), fengari test harnesses run with Node.

**Spec:** `Docs/Engineering/2026-10-05-dashboard-module-prunes-design.md` (parent: `Docs/Engineering/2026-10-04-dashboard-settings-consolidation-design.md`)

## Global Constraints

- No saved-setting (`dbKey`) changes, no deleted settings, no default changes.
- No merged controls and no Integrations-view moves in this plan.
- A row converts to `parent` only when its `visibleWhen` reads exactly one setting on the same page (or a chain, see the spec table). Everything else keeps `visibleWhen`.
- When converting, remove the child's id from the parent's hand-written `refreshIds`; delete an emptied `refreshIds` field.
- A parent of everyday rows stays everyday; children of an advanced parent are advanced.
- About eight everyday rows per card at most; no card may open with zero everyday rows.
- Never mark advanced: a header switch, a module on/off, or a row with `isNew` set to the current or previous release.
- Tests, run from the repo root (all must pass, no new failures):
  - `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_logic.js`
  - `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_options_modules.js`
  - `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js`
  - `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_lootroll_logic.js`
- Every edited Lua file must parse (the module test loads them all; a parse error fails it).
- Commits: Conventional Commits, `git add`, `git commit` and `git push` as separate commands, trailer `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Lua style: match the surrounding file (4-space indent, `L["KEY"]` strings, comment density).

---

### Task 1: Chained parents and the `--dump` flag

**Files:**
- Modify: `options/OptionsAssemble.lua` (`ParentMatches`, `ExpandParents`)
- Modify: `tools/test_options_logic.js` (new checks)
- Modify: `tools/test_options_modules.js` (`--dump`)

**Interfaces:**
- Produces: `parent` chains work at any depth; `node tools/test_options_modules.js --dump` prints, for Retail, every module › page › card with each row's label, marked `[adv]` for advanced and `↳ parent` for dependent rows, plus per-card counts `everyday/advanced`. Without `--dump` the output is unchanged.

- [ ] **Step 1: Write failing logic checks** in `tools/test_options_logic.js`, in the existing style:
  1. Chain `a` (toggle) → `b` (toggle, `parent="a"`) → `c` (`parent="b"`): with `a=false, b=true`, `c` is hidden; with `a=true, b=true`, `c` is visible.
  2. After assembly, `a`'s `refreshIds` contains both `b` and `c`.
  3. A cycle `x.parent="y"`, `y.parent="x"` raises one warning containing `cycle` and both rows keep their original `visibleWhen` (nil here, so both visible).
  4. A parent hidden by its own `visibleWhen` (returns false) hides its child even when the value matches.
  5. A revealed child (search reveal) still shows while its parent is hidden.
- [ ] **Step 2: Run the logic test and confirm the new checks fail.**
- [ ] **Step 3: Implement.** In `ExpandParents`: first build `byKey` and detect cycles by walking each row's `parent` chain (a chain that revisits a key is a cycle: warn once per cycle with the word `cycle`, and leave those rows unwired). `ParentMatches` (or the `match` closure) returns false when the parent row has a `visibleWhen` that returns false. After wiring, extend each parent's `refreshIds` with every transitive descendant (no duplicates).
- [ ] **Step 4: Add `--dump`** to `tools/test_options_modules.js`: when `process.argv` includes `--dump`, after the Retail run print the assembled pages as described in Interfaces. Use the row's `name`, else `searchName`, else `labelText`, else `type`. Checks still run and the exit code is unchanged.
- [ ] **Step 5: Run all four test commands; all pass.** Record new totals.
- [ ] **Step 6: Commit** `feat(options): let dependent rows chain through hidden parents`.

### Task 2: Focus

**Files:**
- Modify: `options/modules/OptionsFocus.lua`
- Modify: `options/modules/OptionsFocusIntegrations.lua` (advanced marking only)

- [ ] **Step 1:** Run `node tools/test_options_modules.js --dump` and save the Focus part as the before state in your report.
- [ ] **Step 2: Convert dependencies.** For every row whose `visibleWhen` matches a pattern in the spec's conversion table, replace it with `parent` / `parentIs` (helper rows such as `Toggle(...)`, `Color(...)` take these in their trailing options table) and remove the child from the parent's `refreshIds`. Leave cross-page, compound non-chain and game-state conditions alone. Conversion must not change when a row shows.
- [ ] **Step 3: Mark advanced rows** using the spec's table and the Global Constraints. Add `advanced = true` to the row table (or the helper's options table).
- [ ] **Step 4:** Run `--dump` again; check that no card opens with zero everyday rows and that most cards have eight or fewer everyday rows. Put the after state in the report, with a one-line reason for any card still above eight.
- [ ] **Step 5: Run all four test commands; all pass, no assembler warnings.**
- [ ] **Step 6: Commit** `refactor(focus): fold niche settings and nest dependent rows`.

### Task 3: Vista

**Files:** Modify `options/modules/OptionsVista.lua`.

Same steps as Task 2 (before dump, convert, mark advanced, after dump, tests). Vista has 125 rows and few dependencies, so most of the cut comes from advanced marking. Commit `refactor(vista): fold niche settings and nest dependent rows`.

### Task 4: Insight

**Files:** Modify `options/modules/OptionsInsight.lua`.

Same steps as Task 2. Leave the TRP3 card's `TRP3Installed` condition alone. Commit `refactor(insight): fold niche settings and nest dependent rows`.

### Task 5: Presence and Echo

**Files:** Modify `options/modules/OptionsPresence.lua`, `options/modules/OptionsEcho.lua`.

Same steps as Task 2 for each file. Leave the Presence preview row everyday. One commit per module: `refactor(presence): …` and `refactor(echo): …` with the same wording as Task 2.

### Task 6: Augment

**Files:** Modify `options/modules/OptionsAugment.lua`, `OptionsAugmentAlerts.lua`, `OptionsAugmentLootRoll.lua`, `OptionsAugmentTalkingHead.lua`.

Same steps as Task 2. Each Augment feature page's header switch stays everyday, and the Talking Head page must still open on a card with settings (the module test checks this). Commit `refactor(augment): fold niche settings and nest dependent rows`.

### Task 7: Axis and Essence

**Files:** Modify `options/modules/OptionsAxis.lua`, `options/modules/OptionsGlobal.lua`, `options/modules/OptionsEssence.lua`.

Same steps as Task 2. Essence has five rows; mark nothing unless a row is clearly niche. Commit `refactor(axis): fold niche settings and nest dependent rows`.

### Task 8: Cards with nothing to show hide themselves; indent only under a same-card parent

Added during execution. Hiding sub-settings left some cards as a bare title. Two cases: Vista's buttons page when "Manage addon buttons" is off, and the Alerts sound card. Separately, a child whose parent sits in another card (Augment loot) is indented under a row the player cannot see beside it.

**Files:**
- Modify: `options/OptionsAssemble.lua` (`BuildPage`, `ExpandParents`)
- Modify: `options/dashboard/DashboardAccordionBuild.lua` only if card visibility is not re-evaluated when a row's parent changes
- Modify: `tools/test_options_logic.js`

- [ ] **Step 1: Failing checks** in `tools/test_options_logic.js`:
  1. A card whose rows all have a `parent` that does not match is hidden: its section row's `visibleWhen` returns false. It shows again once the parent matches.
  2. A card with a header switch (`headerToggle`) is never auto-hidden.
  3. A card whose everyday rows are all hidden but which has advanced rows whose own conditions pass stays visible, so the More row can be reached.
  4. A section row with its own `visibleWhen` keeps it: the auto rule is ANDed with it.
  5. A child in the same card as its parent gets `indent = true`. A child in a different card on the same page gets no indent, but its hiding and hint wiring is unchanged.
- [ ] **Step 2: Run, see them fail.**
- [ ] **Step 3: Implement.** A card has content when any of its rows other than headers, `moreToggle` and the preview proxy would show, judged by the row's own condition without the More gate. The parent itself must also be able to show. Give advanced rows their pre-More condition so this can be evaluated. Work out how the dashboard re-evaluates a card's `visibleWhen` when a row in it changes (look at how `refreshIds` and card visibility interact in `DashboardAccordionBuild.lua`). Make sure that when a parent toggle changes, any card holding its descendants is re-evaluated. If that needs the parent's `refreshIds` to carry the card id, add it.
- [ ] **Step 4: All four test commands pass, with no assembler warnings.**
- [ ] **Step 5: Commit** `feat(options): hide cards whose settings are all hidden`.
