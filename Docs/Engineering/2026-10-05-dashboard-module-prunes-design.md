# Dashboard module prunes (phase 3)

> **Superseded in part:** the More fold is replaced by `2026-10-05-dashboard-cards-subheadings-design.md`.

**Date:** 2026-10-05
**Status:** Written for autonomous overnight execution, to be reviewed by the director
**Parent spec:** `2026-10-04-dashboard-settings-consolidation-design.md` (phase 3)
**Branch:** PRs go into `feature/axis-settings-consolidation`

## Goal

Phase 1 gave every module the same pages and gave cards the tools to stay short: the **More**
fold (`advanced = true`) and dependent rows (`parent` / `parentIs`). Not one row uses either yet,
so every card still shows every setting at once. Phase 3 puts those tools to use, one module at a
time with Focus first, so a player who opens a card sees the settings most people change and
nothing that cannot apply to their current setup.

## Rulings for this round

The parent spec lists five kinds of prune work. This round does the first two, plus label fixes,
in every module. The other two change what players see in ways the director should approve first.

| Work | This round | Why |
|---|---|---|
| Mark niche rows `advanced` | Yes, every module | Biggest cut in visible rows; nothing is removed or renamed |
| Replace simple `visibleWhen` with `parent` | Yes, every module | Same behaviour, plus indenting and the search hint |
| Reword overlapping card or section labels | Only where two cards on one page share a name | Small and reversible |
| Merged controls (style C: font family, size and outline on one row) | No | Needs a new widget and a visual sign-off |
| Move RareScanner, SilverDragon and TRP3 into the Integrations view | No | Needs a design for option cards inside that view |

No saved-setting key changes, no setting is deleted, and no default changes. Every change can be
undone by removing a field.

## Chained parents (assembler change)

Today a dependent row checks only its own parent's value. Focus has chains: the header divider
colour depends on the divider toggle, which depends on the header being shown. Writing those
as `parent` alone would leave the colour row showing while its parent is hidden.

`ExpandParents` therefore treats a parent that is itself hidden as unmatched:

- a child shows only while its parent is visible (its `visibleWhen` passes) **and** its value
  matches `parentIs`;
- a parent's `refreshIds` gains every descendant, not just its direct children, so turning off
  the top toggle hides the whole chain at once;
- a cycle (`a` depends on `b`, `b` on `a`) is a load-time warning and both rows keep their own
  `visibleWhen`.

A search hit on a hidden row still reveals it in place, as in phase 1.

## Advanced rows: the test

A row goes behind **More** when most players never change it. Use these as the default answers:

| Advanced | Everyday |
|---|---|
| Pixel offsets, padding, gaps, spacing, sub-element heights and widths | The module's own on/off and a card's header switch |
| Secondary opacities (mouseover, faded, dimmed) | The main size, scale or width of the frame |
| Colours of secondary parts: dividers, borders, shadows | Font family and font size of the main text |
| Text case, shadow offsets, outline choice | Feature toggles that change what is shown |
| Tooltips-on-hover, Wowhead links, debug or diagnostic rows | Rows flagged `isNew` for the current or previous release |
| Per-element font overrides beyond the main font | Anything a first-time player is likely to look for |

Two structural rules:

- A row that is the `parent` of everyday rows stays everyday.
- When a parent is advanced, its children are advanced too, so a chain never splits across the
  fold.

Aim for no more than about eight everyday rows per card. A card whose rows are all advanced keeps
its first one or two everyday so it does not open empty.

## Dependent rows: the conversion

A row converts to `parent` when its `visibleWhen` reads exactly one setting on the same page:

| Today | Becomes |
|---|---|
| `visibleWhen = function() return getDB("x", D.x) end` | `parent = "x"` |
| `... return not getDB("x", D.x) end` | `parent = "x", parentIs = false` |
| `... return getDB("x", D.x) == "bar" end` | `parent = "x", parentIs = "bar"` |
| `... return getDB("x") ~= "off" end` | `parent = "x", parentIs = function(v) return v ~= "off" end` |
| `not getDB("a") and getDB("b")`, where `b` itself depends on `a` | `parent = "b"` (the chain covers `a`) |

The same goes for a row **greyed** by one setting on the same page
(`disabled = function() return not getDB("x", D.x) end`): it becomes `parent = "x"`, so it hides
instead of greying. That is a deliberate change in what players see, and the one the director
asked for: sub-settings stay out of sight until their parent applies. Greying stays for blockers
outside the card, such as the module being off.

The matching entry comes out of the parent's hand-written `refreshIds`. Anything else stays as
`visibleWhen`: conditions on another page, on another addon being loaded, on game state, or on
two settings that are not a chain.

## Order of work

One task per module, in this order: Focus, Vista, Insight, Presence, Echo, Augment, Axis
(with `OptionsGlobal.lua`), Essence. Focus integrations (`OptionsFocusIntegrations.lua`) only
get advanced marking: their conditions read whether the other addon is loaded.

## Testing

- `tools/test_options_logic.js`: chained parent visibility, transitive refresh ids and the cycle
  warning.
- `tools/test_options_modules.js`: still no assembler warnings on Retail and Forever, and a new
  `--dump` flag that prints every page and card with its everyday and advanced rows, so a
  reviewer can read each module's result without the game.
- In game, per module: each card opens short, **More (n)** reveals the rest, dependent rows
  indent and hide with their parent, and search still finds advanced rows.
