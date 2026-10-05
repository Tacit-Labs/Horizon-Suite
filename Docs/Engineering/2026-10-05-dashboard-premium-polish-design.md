# Dashboard premium polish

**Date:** 2026-10-05
**Status:** Approved by the director (items 1, 2, 3 and 4 of the "premium options" list)
**Branch:** `feature/options-premium-polish`, stacked on `feature/options-modern-style`

## 1. Smooth switches and sliders

- **Switches:** the knob slides between off and on over `Def.MotionFast` (about 0.12s, ease-out)
  and the track fills with the accent across the same time. A switch set from outside the row (a
  refresh or a profile switch) snaps without animating. Card header switches behave the same way.
- **Sliders:**
  - the thumb grows to about 1.15× while it is hovered or dragged, eased over `Def.MotionFast`;
  - the value text eases to its new number over `Def.MotionFast` when the value changes by a
    click or by typing, but follows the thumb exactly while it is being dragged;
  - a change from outside the row snaps.

## 2. Press feedback

While the mouse is held down on a button, a segment, a switch, a dropdown button or a stepper − or
+, the control scales to 0.97 about its centre and returns on release (`Def.PressScale`,
`Def.MotionPress` about 0.06s). It is visual only: the click itself behaves exactly as before.
Disabled controls don't react.

## 3. Card opening

When a card opens, its visible rows fade from alpha 0 to 1 and rise 6px into place, each starting
`Def.RowStagger` (about 0.02s) after the row above. The whole sequence is capped at 0.25s however
many rows the card has. The card's height animation is unchanged.

The effect is skipped when a card opens:

- from saved state at page build;
- from a search jump;
- with no animation (`SetExpandedInstant`).

Closing has no stagger.

## 4. Changed-from-default markers

- **What counts as changed.** A setting is changed when the active profile stores a value for its
  key and that value differs from the setting's default:
  - Numbers are compared with a small tolerance.
  - Tables (colours) are compared field by field.
  - A colour stored as separate `R`/`G`/`B`/`A` keys is changed when any of those keys is.

  When no default can be found, the row shows no marker.
- **Where defaults come from:**
  - the row's own `default` field, when its helper set one;
  - otherwise the module's defaults table (`addon.FOCUS_DEFAULTS`, `VISTA_DEFAULTS`,
    `INSIGHT_DEFAULTS`, `PRESENCE_DEFAULTS`, `ECHO_DEFAULTS`, `AUGMENT_DEFAULTS`,
    `TALKING_HEAD_DEFAULTS`, `AXIS_DEFAULTS` and `ESSENCE_DEFAULTS`).

  One helper, `addon.OptionDefault(key)`, answers this, and `addon.OptionIsChanged(row)` uses it.
- **Marker.** A small accent dot sits in the row's left gutter, beside the label and inside the
  card padding, so it never shifts the label.
- **Reset.** While a changed row is hovered, a small reset arrow appears just right of the label.
  Clicking it:
  1. calls the row's own `set(default)`, so the module's apply code runs exactly as if the player
     had chosen the default;
  2. then clears the stored value (`SetDB(key, nil)`), so the setting follows the default again;
  3. refreshes the row.

  A font row resets all of its parts.
- **Card count.** A card with changed rows shows a muted "N changed" after its title, ahead of its
  description.
- **Live updates.** Markers and counts update whenever a row refreshes: after a change, a reset
  or a profile switch.
- **Not marked:**
  - buttons, notes, subheadings, previews and lists (the reorder list, the blacklist grid and the
    colour matrix's own grid);
  - Profiles page rows;
  - rows with no `dbKey`.

## Constraints

- Every duration, scale and offset is a `Def` token.
- Animations use `OnUpdate` on the animated widget and stop when it hides. No animation may leave
  a control at a partial scale, alpha or offset when it ends, is interrupted or is hidden.
- Nothing here changes a saved value, except the explicit reset in item 4.
- Lua 5.1, Retail and Forever. `SetScale` is fine on both.
