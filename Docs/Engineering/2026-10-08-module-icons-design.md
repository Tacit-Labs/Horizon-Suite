# Module icons

**Date:** 2026-10-08
**Status:** Draft for the director's review
**Branch:** `feature/dashboard-module-icons`, stacked on `feature/dashboard-welcome-showcase` (PR #522)

## Why

The dashboard shows each module with a Blizzard spell or item icon. Two tables pick them, and they
already disagree: Augment is a coin in the sidebar and a holy-light spell on the Home cards. The
icons have different art styles, borders and brightness, so the sidebar, the Home cards and the new
Welcome tiles never look like one product. Only Echo has its own icon.

## Decisions taken with the director

- **Style:** monoline glyphs. Thin, even lines on a 24-unit grid, white on transparent. The game
  tints each one, so it can take the module colour, a muted grey, or the class colour from the same
  file.
- **Glyphs:**

| Key | Glyph |
|---|---|
| `focus` | Quest scroll: a parchment roll with two text lines |
| `presence` | Zone title: two text bars between rules, with a diamond either side |
| `vista` | Compass: a ring with a diamond needle |
| `insight` | Eye |
| `echo` | Chat bubble with one text line |
| `augment` | Faceted gem |
| `essence` | Character portrait in a rounded frame |
| `axis` | Three sliders |
| `integrations` | Chain link |

Meridian (coming soon) keeps its current icon until the module exists.

## 1. Source and build

- **Source:** each glyph is an SVG in `tools/icons/<key>.svg`, on a `viewBox="0 0 24 24"` grid. It
  uses only `path`, `circle` and `rect`, with stroke 1.6, round caps and joins, no fill and no
  transforms. `tools/` is already excluded from the package.
- **Build:** `tools/make_module_icons.py` (Pillow, already used by the other art tools).
  - It parses those three elements. Paths support the `M L H V C S Q A Z` commands, absolute and
    relative.
  - It strokes them at 8× size and downsamples with LANCZOS to **128×128**. The output is white with
    anti-aliased alpha.
  - The script is deterministic, so the same SVG always gives the same bytes.
- **Output:** `media/icons/modules/<key>.tga` (RGBA TGA, the same format as Echo's existing icon). The
  same TGA serves every size from 16px to 48px.
- **Check:** `--check` exits 1 when a committed TGA no longer matches its SVG. The Luacheck workflow
  runs it, as it does for the news feed.

## 2. One table for every surface

`addon.DashboardModuleIcons` (in `DashboardHomeWelcome.lua`) becomes the only source. It maps each
module key, plus `integrations`, to the TGA path. The sidebar's `categoryIcons` reads module entries
from it instead of keeping its own list. That fixes the Augment mismatch. The non-module entries
(Profiles, General and so on) are unchanged.

Every place that draws one of these icons resets the texture coordinates to the full image (0–1),
because some Blizzard icons are cropped.

## 3. How each surface tints the glyph

| Surface | Size | On | Off / idle |
|---|---|---|---|
| Sidebar module rows | 16px | Unchanged: the existing muted tint, and the existing selected and hover styling | Unchanged (row dims) |
| Integrations sidebar row | 16px | Same as the module rows | — |
| Home toggle cards | 38px | Module colour | Grey (0.45), replacing desaturate |
| Welcome tiles | 40px | Module colour | Grey (0.45) |

The Welcome tile keeps its tinted placeholder panel behind the glyph until screenshots replace it.

## 4. Testing

- `tools/test_make_module_icons.py` (unittest) covers:
  - path parsing for each command, including a relative arc;
  - a known glyph rendering to 128×128 RGBA with white pixels only;
  - deterministic output;
  - `--check` passing on fresh output and failing after an SVG edit.
- **Existing suites stay green:**
  - Lua tests: news_logic, options_logic, options_modules, echo_logic and lootroll_logic;
  - `test_build_news.py`.
- **In game (director):**
  - all three surfaces show the new glyphs, crisp at 16px;
  - Home and Welcome show module colours;
  - off modules show grey;
  - Augment matches everywhere;
  - also check on Forever.

## 5. Delivery

One PR into `feature/dashboard-welcome-showcase`, so it merges after #522.

## Out of scope

- Icons for the minimap button, slash-command output or chat.
- Replacing Echo's own in-module icon (`modules/Echo/EchoView.lua`); only the dashboard uses the new
  glyph.
- A Meridian icon.
