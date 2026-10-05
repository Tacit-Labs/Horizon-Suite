# Dashboard modern style

**Date:** 2026-10-05
**Status:** Approved by the director from the mockup
(`Docs/Engineering/mockups/2026-10-05-dashboard-modern-style.html`, "Proposed")
**Branch:** `feature/options-modern-style`, stacked on `refactor/options-cards-subheadings`

## Goal

Make the settings dashboard look like a current settings screen. Four changes, each numbered as
they were offered to the director:

1. **Grouped rows.** A card is one soft panel. Its rows are separated by hairlines rather than
   boxed, each label carries a muted one-line description, and the control sits on the right.
2. **Segmented buttons** replace dropdowns that offer two to four short choices.
4. **One accent colour,** used only where something is on or selected.
5. **A three-size type scale,** with bolder card titles and more space between cards than
   between rows.

The mockup is the reference for proportions and colours. The WoW renderer differs from a browser,
so the target is the mockup's feel, not a pixel match.

## Cards

- **Panel.** A card is a filled rounded panel, `Def.SectionCardBg` lifted slightly to about
  `#17171d`, with no visible border and a corner radius of 12. Cards are 14px apart.
- **Header.** The title is in the title size and semi-bold. A muted description follows it on the
  same line when the card has one, and a chevron sits at the right edge. The whole header is the
  click target.
- **Header switches** (`headerToggle`) keep working. The switch sits just left of the chevron.
- **Card descriptions** come from an optional `desc` on the card's first section. Only cards that
  already have a fitting locale string get one; the rest show the title alone.

## Rows

- **Dividers.** Rows have no box and no border. A 1px hairline (`Def.DividerColor` at low alpha)
  separates each row from the one above. There is no hairline above the first row of a card or
  of a subheading group.
- **Label and description.** The label is in the label size and colour. Below it, the row's
  `desc` shows in the help size and muted colour, on one line, ending in an ellipsis when it is
  too long. The full `desc` and `tooltip` stay in the tooltip. A row without a `desc` is one
  line tall.
- **Height.** A one-line row is about 40px and a row with a description about 52px. The layout
  already reads each widget's height.
- **Controls** sit right-aligned on a flat filled background (`Def.InputBg`), with radius 8 and
  no border. That covers dropdowns, the stepper, editboxes and buttons.
- **Switches** are 36×20 pills. The track is `Def.TrackOff` when off and the accent when on,
  with a white knob.
- **Sliders** are a thin track (4px), with the accent fill up to a white round thumb and the value
  shown to the right.
- **Colour swatches** are 22×22 with radius 6 and a hairline ring.
- **Dependent rows** (`indent`) keep a 2px accent line, at low alpha, to the left of the label.
- **Hover:** a very faint row highlight, used for every row type.
- **Disabled:** the whole row drops to about 40% alpha, as today.

## Segmented buttons

- **When.** A dropdown becomes segmented when its options are a static table of two to four
  entries. Static means not a function, not `searchable` and with no font preview. It also needs
  every segment to fit: the measured label widths plus padding must fit inside half the row's
  width. Otherwise it stays a dropdown. This is decided at layout time, so it also holds in other
  locales.
- **Opting out.** A row can set `segmented = false` to keep its dropdown.
- **Look.** An inset track (`Def.InputBg`, radius 8, 2px padding). The selected segment is a
  slightly raised fill with a hairline ring and normal text colour; the others are muted text.
  Segments size to their labels.
- **Behaviour.** A click selects. Get, set, `refreshIds`, disabled visuals and `Refresh` behave as
  the dropdown did, and a tooltip on each segment shows the full label.
- **Font rows.** The outline part of a font row uses the same rule, so None / Outline / Thick
  shows as segments.

## Accent and type

- **Accent.** The accent colour (`Def.AccentColor`, or the class colour when the Axis class theme
  is on) appears only on:
  - a switch that is on;
  - slider fill;
  - the dependent-row line;
  - the selected sidebar item.

  The selected segment uses a neutral raised fill, as in the mockup. Every other use of the
  accent turns neutral.
- **Type scale.** Three sizes from `Def`:

  | Size | Value | Used for |
  |---|---|---|
  | Title | `LabelSize + 2`, semi-bold where the font allows | Card titles |
  | Label | `LabelSize` | Row labels |
  | Help | `LabelSize - 2` | Descriptions, subheadings and notes |

  Page titles keep their own larger size.
- **Settings still apply.** The Axis dashboard settings (font, size, outline, background theme,
  class theme) still apply: sizes are derived from `Def`, so the dashboard text size scales all
  three.

## Sidebar

The selected module and page get a rounded accent-tinted fill (accent at about 16% alpha) and
normal text colour. Unselected items are muted with no box.

## Out of scope

- The live preview panel and changed-from-default markers.
- Card descriptions for every card. They are added where a string exists, and more can come
  later.
- Any change to settings, keys or layout order.
