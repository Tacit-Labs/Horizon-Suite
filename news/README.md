# Dashboard news feed

Stories are Markdown files in this directory. The build script compiles them into the Lua feed the dashboard reads.

## Fields (front matter)

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | string | yes | Lowercase letters, digits, and hyphens only; must match the file name (e.g. `hello-world` for `hello-world.md`) |
| `title` | string | yes | Display title; max 60 characters |
| `priority` | number | no | Sort order (high to low); default 100 |
| `layout` | string | no | `"card"` (default) or `"featured"` (needs an image) |
| `from` | date | no | Start date; format `YYYY-MM-DD` |
| `until` | date | no | End date; format `YYYY-MM-DD`; must be on or after `from` |
| `untilVersion` | string | no | Version string; format `6.3.0` or similar |
| `image` | filename | no | PNG file from `media/news/`; must be power-of-two dimensions (e.g. 512×256), max 1024px per side |
| `button` | string | no | Button text; requires an `action` |
| `action` | string | no | What happens when the button is clicked; requires a `button` |

## Actions

An action form is `<kind> [<arg>]`:

- `module <key>` — Open a module. Key is one of: `axis focus presence vista insight augment essence echo`
- `patch_notes` — Show patch notes
- `news` — Show news
- `guide` — Show a guide
- `url <https://...>` — Open a URL (must be https)

## Body

After the closing `---`, one or more paragraphs. Blank lines separate paragraphs. Within a paragraph, line breaks are stripped. Pipe characters are doubled (`||`) so they display literally and can't start WoW escape codes.

## Example

```markdown
---
id: hello-world
title: A new feature
priority: 200
from: 2026-10-01
until: 2026-12-31
button: Learn more
action: guide
---
This is the first paragraph, and it can
wrap across multiple lines.

This is the second paragraph. The dashboard
will display both.
```

## Building

```
python3 tools/build_news.py          # regenerate the feed
python3 tools/build_news.py --check  # check if the feed is current (used in CI)
```
