# Dashboard cards and subheadings Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the More fold with smaller topic cards and in-card subheadings across every module.

**Architecture:** The assembler stops building More folds and starts adding a subheading before each section of a merged card. The dashboard draws those subheadings as quiet labels. Each module's options file then re-cards its rows by topic and drops `advanced`.

**Tech Stack:** Lua 5.1 (WoW addon), fengari test harnesses run with Node.

**Spec:** `Docs/Engineering/2026-10-05-dashboard-cards-subheadings-design.md`

## Global Constraints

- No saved-setting key, default or getter/setter changes. No setting deleted. Rows may move between cards and change order within a page. They must stay on the page they are on (shared-vocabulary pages), unless the spec's rules say otherwise.
- Card size: no more than 8 rows visible at default settings, and no more than 12 rows in total (font rows count as one). Prefer no more than 7 cards on a page.
- A new card takes the name of the section that starts it. Reuse existing locale strings; any new key goes in `locales/horizon/enUS.lua`, with commented stubs in the other `locales/horizon/*.lua`.
- Every `advanced = true` comes out of a module's file in that module's task. By the last task none is left (the module test checks this).
- A `parent` row must stay on the same page as its parent. A row that indents under its parent must stay in the same card.
- Tests, each run as `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/<file>.js`, must all pass: `test_options_logic.js`, `test_options_modules.js` (no assembler warnings), `test_echo_logic.js`, `test_lootroll_logic.js`. Baselines at the start: 199 / 39 / 2837 / 90.
- `node tools/test_options_modules.js --dump` is the review surface. After Task 1 it prints subheadings and per-card counts as `visibleAtDefaults/total`.
- Commits: Conventional Commits. `git add` and `git commit` run as separate commands. Add the trailer `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

---

### Task 1: Remove the More fold; add subheadings

**Files:**
- `options/OptionsAssemble.lua`
- `options/dashboard/DashboardAccordionBuild.lua`
- `options/dashboard/DashboardDetailView.lua`
- `options/OptionsSearch.lua`
- `locales/horizon/*.lua`
- `tools/test_options_logic.js`
- `tools/test_options_modules.js`

- [ ] **Step 1: Rewrite the tests.** Remove or rewrite every More check in `tools/test_options_logic.js` so it states the new behaviour. Add failing checks:
  1. A row with `advanced = true` stays in place among its card's rows, and no `moreToggle` row exists.
  2. A card merged from sections A and B gets a header row named B before B's rows. It also gets one named A before A's rows, unless A's name is the card's displayed name.
  3. `subheading = "X"` renames the header; `subheading = false` suppresses it.
  4. A single-section card has no header row.
  5. A header whose rows are all hidden (their parent is off) is hidden, and shows again when the parent turns on.
  6. Header rows are not search results.
- [ ] **Step 2: Run them; they fail.**
- [ ] **Step 3: Assembler.**
  - Drop the everyday/advanced split, the More row, `getCount` and `_countingCard`, and the More gate on `visibleWhen` and `contentWhen`.
  - Emit subheading rows, giving each a `visibleWhen` built from the content conditions of its rows.
  - Delete `IsMoreOpen` and `SetMoreOpen`.
  - Keep card auto-hide, parents and the Forever pre-prune working.
- [ ] **Step 4: Dashboard.**
  - Delete the More widget and its `_repaint` hook, and remove `SetMoreOpen` from `NavigateToOption`.
  - Style `header` rows as subheadings: muted small text and a thin rule to its right, about 22px tall, left-aligned with the rows. Check how header rows are drawn today and change only their look.
  - Delete `DASH_MORE` and `DASH_LESS` in every locale.
- [ ] **Step 5: Module test.**
  - Change `--dump` to print header rows as `── name ──` and each card's count as `visibleAtDefaults/total`.
  - Add a check, printed for now and not failing, that lists rows still carrying `advanced`. Task 6 turns it into a failing check.
- [ ] **Step 6: Run all four test commands; they pass.**
- [ ] **Step 7: Commit** `refactor(options): replace the More fold with subheadings`.

### Task 2: Focus

**Files:** `options/modules/OptionsFocus.lua` and `options/modules/OptionsFocusIntegrations.lua`.

Re-card by topic under the spec's splitting rules and remove every `advanced`.
- Look & Feel › Text becomes cards such as Fonts, Text sizes and Text style.
- The long What's tracked and Instances cards split by topic.
- Record the before and after `--dump` for Focus in the report.
- No card may break the size limits; give one line of reasoning for any card at the limit.

Commit `refactor(focus): split settings into topic cards`.

### Task 3: Vista and Insight

Same as Task 2, for `OptionsVista.lua` and `OptionsInsight.lua`. One commit per module: `refactor(vista): …` and `refactor(insight): …`, using the same wording as Task 2.

### Task 4: Presence and Echo

Same as Task 2, for `OptionsPresence.lua` and `OptionsEcho.lua`. One commit per module.

### Task 5: Augment

Same as Task 2, for the four `OptionsAugment*.lua` files. Talking Head must still open on a card with settings and keep its preview proxy. Commit `refactor(augment): split settings into topic cards`.

### Task 6: Axis and Essence, then the final check

Same as Task 2, for `OptionsAxis.lua`, `OptionsGlobal.lua` and `OptionsEssence.lua`. Then turn the module test's "rows still carrying advanced" list into a failing check, and add a failing check that no card is over 12 rows in total. Commit `refactor(axis): split settings into topic cards`, then `test(options): forbid advanced rows and oversized cards`.
