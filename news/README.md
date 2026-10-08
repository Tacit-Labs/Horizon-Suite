# Dashboard news feed

Stories are Markdown files in this directory. The build script compiles them into the Lua feed the dashboard reads.

## Fields (front matter)

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | string | yes | Lowercase letters, digits, and hyphens only; must match the file name (e.g. `hello-world` for `hello-world.md`) |
| `title` | string | yes | Display title; max 60 characters |
| `priority` | number | no | Sort order (high to low); default 100 |
| `layout` | string | no | `"card"` (default) or `"featured"` (needs an image) |
| `from` | date | yes | Posted date, and the start of the story's run; format `YYYY-MM-DD` |
| `until` | date | no | End date; format `YYYY-MM-DD`; must be on or after `from` |
| `untilVersion` | string | no | Version string; format `6.3.0` or similar |
| `image` | filename | no | PNG file from `media/news/`; must be power-of-two dimensions (e.g. 512×256), max 1024px per side |
| `button` | string | no | Button text; requires an `action` |
| `action` | string | no | What happens when the button is clicked; requires a `button` |
| `button2` | string | no | Second button text; requires `action2` and a first `button` |
| `action2` | string | no | Second button action; same forms as `action` |
| `modules` | list | no | Up to 3 comma-separated module keys (`vista, focus`), no duplicates; shown as tags under the title |

## Actions

An action form is `<kind> [<arg>]`:

- `module <key>` — Open a module. Key is one of: `axis focus presence vista insight augment essence echo`
- `patch_notes` — Show patch notes
- `news` — Show news
- `guide` — Show a guide
- `url <https://...>` — Open a URL (must be https)

## Body

After the closing `---`, blocks separated by blank lines. The body must start with a paragraph, which becomes the story's summary on cards and the Welcome strip.

- **Paragraph:** any block that is not a list. Line breaks inside it are joined with spaces.
- **List:** a block where every line starts with `- `. Each line is one item. A block that mixes `- ` lines with other lines is an error; keep each item on one line.
- **Bold:** `**text**` shows in white. Every `**` must be paired.

Pipe characters are doubled (`||`) so they display literally and can't start WoW escape codes; bold is added by the builder after that, so a story cannot inject its own codes.

The builder emits `summary`, `blocks` (`{ kind = "p", text }` and `{ kind = "list", items }`) and, for now, `paragraphs` (paragraph text only).

## Example

```markdown
---
id: hello-world
title: A new feature
priority: 200
from: 2026-10-01
until: 2026-12-31
modules: focus, vista
button: Open Focus
action: module focus
button2: Module guide
action2: guide
---
This is the summary paragraph, and it can
wrap across multiple lines. **Bold** shows in white.

- A list item.
- Another item.
```

## Building

```
python3 tools/build_news.py          # regenerate the feed
python3 tools/build_news.py --check  # check if the feed is current (used in CI)
```
