# Dashboard font row

**Date:** 2026-10-05
**Status:** Approved by the director in outline (merged controls, family + size + outline on one row); built overnight, to be reviewed in game
**Parent spec:** `2026-10-04-dashboard-settings-consolidation-design.md` (phase 3, merged controls, style C)
**Branch:** `feature/options-font-row`, stacked on `refactor/options-module-prunes`

## Goal

A text element's font is set today with up to three rows, each a full row wide: a font
dropdown, a size slider and an outline dropdown. There are about 25 of these blocks across the
modules. One **font row** puts all three controls on a single line, so a Text card shows one row
per text element.

## What a player sees

```
 Title text           [ Friz Quadrata        ▾ ]   [ − 14 + ]   [ Outline     ▾ ]
```

- The label sits on the left, at the same position and in the same font as other row labels.
- The font dropdown works like today's font dropdowns. It keeps search and the font preview in
  the list, it flexes in width, and it is never narrower than 140px.
- Size is a compact stepper: − and + buttons with the value between them. Clicking the value lets
  the player type a number, which is clamped to the old slider's min, max and step.
- Outline is a dropdown with the existing outline options. Where the old control was an outline
  toggle (Talking Head), it is a compact toggle labelled "Outline".
- Any of the three slots may be missing. A missing slot leaves no gap: the controls stay
  right-aligned.
- When the row is narrower than 640px (a small dashboard), it wraps to two lines: the label and
  the font on the first, and size and outline right-aligned on the second.
- The row's tooltip is its description. Each control also has its own tooltip, naming what it
  sets.
- When the row is disabled, all three controls grey out together, as other rows do.

## Data

A font row is one option row:

```lua
FontRow(L["TITLE_TEXT"], L["TITLE_TEXT_DESC"], {
    family  = { dbKey = "titleFontPath", options = fn, get = fn, set = fn, displayFn = fn },
    size    = { dbKey = "titleFontSize", min = 8, max = 32, step = 1, get = fn, set = fn },
    outline = { dbKey = "fontOutline", options = OUTLINE_OPTIONS, get = fn, set = fn },
    -- outline = { dbKey = "...", kind = "toggle", get = fn, set = fn } for an on/off outline
}, { advanced = true, parent = "usePerElementFonts", keywords = { ... } })
```

- Each part keeps its own saved key, getter and setter. **No saved setting changes.**
- Each part can take its own `refreshIds`, for the Presence and Talking Head previews.
- The row's `dbKey` is its primary key: the family key if there is one, otherwise the size key.
  The assembler, search reveal, More and `parent` all key on it.
- A part with no getter or setter falls back to `GetDB` / `SetDB` on its key, the same way plain
  rows do.

## Rules

- **Advanced.** A font row is advanced only when every one of its parts was advanced; if any part was everyday, the row is everyday, so no control becomes harder to reach. A row is never gated by a `parent` or `disabled` that only some of its parts had: parts gated differently stay as separate rows (Focus per-element fonts).
- **Parents.** A row's `parent` applies to the whole row. The assembler also indexes the part
  keys, so a row elsewhere that names a part key as its `parent` resolves against that part's
  value. Today no row does.
- **Search.** A font row is one result. Its keywords include the names of the rows it replaced
  (for example "Title size" and "Outline"), so old searches still find it.
- **Refresh.** One `Refresh` updates all three controls. The row is registered in the refresh
  table under every part key, so refreshing any part's key updates it.

## Where it applies

| Module | Font rows | Stays separate |
|---|---|---|
| Augment | Loot window, Alerts and Loot Roll: font + size + outline. Talking Head name and dialogue: font + size + outline toggle | |
| Axis | Dashboard text: font + size + outline | Global font override (font only, under its toggle) |
| Vista | Zone, coordinates, time, performance and difficulty: font + size | |
| Focus | Main: font + outline (the outline applies to every Focus font). Per-element families and sizes stay separate rows (the families sit under per-element fonts, the sizes do not) | Header size, global size offset, M+ and run-timer sizes |
| Presence | Discovery: font + size + outline. Title and subtitle: font + outline | Title and subtitle large, medium and small sizes |
| Insight, Echo | | One font each, with sizes on other cards |

## Out of scope

- Shared typography across modules (phase 2).
- Colour swatches in the row. Vista's text colours stay as their own rows.
