# Dashboard cards and subheadings

**Date:** 2026-10-05
**Status:** Approved by the director (replaces the More fold)
**Replaces:** the "Advanced rows" part of `2026-10-05-dashboard-module-prunes-design.md`
**Branch:** `refactor/options-cards-subheadings`, stacked on `feature/options-font-row`

## Why

The **More (n)** fold kept cards short by hiding settings behind a click that never said what
was behind it. The director prefers every setting visible once its card is open, with long cards
split into smaller topic cards and rows grouped under subheadings.

## What a player sees

```
Look & Feel

▾ Fonts
   Main font        [Friz Quadrata ▾]  [Outline ▾]
   ── Per-element ──
   Per-element fonts            [on]
      Title font    [Use global ▾]
      Zone font     [Use global ▾]

▸ Text sizes
▸ Text style
▸ Colours
▸ Background & border
```

- There is no More row anywhere. Every setting in an open card is visible, except sub-settings
  whose parent is off. Those still hide and indent under their parent, as before.
- Long cards become several topic cards. Only the first card on a page opens by default, and
  every card remembers whether the player left it open.
- A card built from more than one section shows each section's name as a **subheading**: a
  small muted label with a thin rule, left-aligned with the rows. A subheading whose rows are all
  hidden hides too.
- Cards whose rows are all hidden still hide.

## Rules for splitting

- **Size.** Aim for no more than 8 rows visible at default settings, and never more than 12 rows
  in total, in any card. Prefer no more than 7 cards on a page.
- **Topics.** Split by what the player is trying to do (fonts, text sizes, text style, colours,
  spacing, per-element overrides), not by how often a setting is used.
- **Names.** A new card takes the name of the section that starts it. Reuse existing section names
  and locale strings wherever one fits. New strings go in enUS, with commented stubs in the other
  locales.
- **Shared cards keep their place.** Visibility, Behaviour, Position, Size, Text, Colours,
  Background and Animation stay where the shared vocabulary puts them. When a shared card is too
  long, its overflow goes to module cards on the same page, placed straight after it.
- **Order inside a card.** Main controls first, then subheadings for the finer groups.

## Subheadings (assembler)

- When a card merges two or more sections, the assembler emits a `type = "header"` row before
  each section's rows, using that section's name. The exception is a section whose name matches
  the card's own displayed name.
- A section may set `subheading = <string>` to override the label, or `subheading = false` to
  suppress it.
- A subheading row is visible while any row between it and the next subheading (or the end of
  the card) would show. This uses the same content rule as card auto-hide.
- Subheadings are not search results. Search results keep showing their section name as the
  location.

## Removing the More fold

- The assembler no longer splits rows into everyday and advanced, and no longer emits
  `moreToggle` rows. A row's `advanced` field is ignored, and every module removes it as it is
  re-carded.
- The builder's More widget, the `optionsCardMoreOpen` store functions, the More step in search
  navigation, and the `DASH_MORE` / `DASH_LESS` strings are deleted. Old saved
  `optionsCardMoreOpen` data is left in the saved table; nothing reads it.
- The card auto-hide and the parent chains keep working without the More gate.

## Kept from phases 1 and 3

Shared pages, dependent rows (`parent`), card auto-hide, font rows and search coverage are
unchanged. Saved settings, defaults and getters are unchanged, so there is no migration.
