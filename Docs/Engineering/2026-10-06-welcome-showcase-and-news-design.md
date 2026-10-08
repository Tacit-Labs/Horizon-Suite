# Welcome showcase and curated news

**Date:** 2026-10-06
**Status:** Draft for the director's review
**Branch:** `feature/dashboard-welcome-showcase`, from `feature/axis-settings-consolidation`

## Why

The Welcome page is a long scroll of text: a hero, three "start here" cards, the module guide
accordions, then three credit cards. The News page is hand-written Lua plus locale keys, so nobody
updates it. Its top story is still "Augment Alerts" from 5.x while the addon is on 6.6.0.

Two decisions frame this design:

- **Welcome is a showcase.** It is a polished front page with hero art, the modules and credits.
  Settings and module switches stay on their own pages.
- **News is a curated file, built automatically.** WoW addons cannot go online, so the news ships
  with each version. It is written as plain files and turned into Lua by a script.

## 1. News pipeline

### 1.1 Story files

Each story is one Markdown file in `news/`, named `<id>.md`:

```markdown
---
id: axis-settings-refresh
title: A tidier settings dashboard
layout: featured
priority: 500
from: 2026-10-06
until: 2026-11-30
image: axis-refresh.png
button: Open settings
action: module axis
---
Every on-screen element now has one card, with its switch at the top and everything else for it
underneath.

Search understands typos and synonyms, and remembers what you looked for.
```

| Field | Required | Meaning |
|---|---|---|
| `id` | yes | Lowercase letters, digits and hyphens. Must match the file name. |
| `title` | yes | 60 characters at most. |
| `layout` | no | `featured` (big image beside the text) or `card` (default). |
| `priority` | no | Higher sorts first. Default 100. |
| `from` | no | ISO date. Hidden before it. |
| `until` | no | ISO date. Hidden after it. |
| `untilVersion` | no | Hidden once the installed version is newer than this. |
| `image` | no | A file in `media/news/`. |
| `button`, `action` | no, but both or neither | `action` is `module <key>`, `patch_notes`, `news`, `guide` or `url <https://…>`. A URL opens the existing copy-link dialog. |

The body is plain text. Blank lines separate paragraphs. The first paragraph is the summary shown on
the Welcome page.

Stories are English only, because they change too often to translate. The page's own labels
("Latest news", "All news", "New") are locale strings as usual.

### 1.2 Build script

`tools/build_news.py` uses the Python standard library only. It reads `news/*.md` and writes
`options/dashboard/DashboardNewsFeed.lua`, keeping the existing file name so the TOC doesn't change.
The generated file starts with a "generated, do not edit" header, and the build is deterministic:
the same input always produces the same bytes.

The script rejects a story, naming the file and the reason, when:

- a required field is missing;
- an `id` is a duplicate or doesn't match its file name;
- a date or version is malformed, or `until` comes before `from`;
- an image is missing, or is not a PNG of a power-of-two size of at most 1024;
- `button` and `action` aren't both present or both absent;
- an `action` names an unknown module or a URL that isn't `https`;
- a title is longer than 60 characters.

Text is escaped for Lua, and `|` is doubled so a story cannot inject WoW escape codes.

`python3 tools/build_news.py --check` exits non-zero when the committed Lua file is out of date. The
Luacheck workflow runs it, so editing a story without rebuilding fails CI.

The generated file is committed, rather than built inside the release step, so a branch pulled on
the Windows test PC has the same news that a release will.

`.pkgmeta` ignores `news`, so the source files don't ship. The images in `media/news/` do ship.

### 1.3 In game

New pure logic in `options/dashboard/DashboardNewsLogic.lua`, testable in the fengari harness:

- **`NewsLogic.Visible(stories, now, version)`** drops stories outside `from`/`until`, and those
  whose `untilVersion` is older than the installed version. It sorts the rest by priority, then by
  `from` (newest first), then by `id`.
- **`NewsLogic.ReleaseStory(patchNotes, version)`** builds a story from the installed version's patch
  notes:
  - title "What's new in 6.6.0";
  - summary from the first two bullets;
  - button "Patch notes";
  - id `release-<version>`.

  It is always first, so the page is never empty or out of date. It returns nil when that version has
  no notes.
- **Unread badge.** Story ids the player has seen are kept in root saved variables (`newsSeen`, not
  per profile). The News row in the sidebar shows "New" through `DashboardSidebar_SetRowBadge` while
  any visible story is unseen. Opening News marks every visible story as seen. On first run, every
  story already visible is marked seen, so existing players aren't badged for old news.

### 1.4 Existing stories

The three hand-written stories are retired because they are out of date: Augment Alerts, the Game
Menu button, and "Cache" becoming "Augment". One new story ships with this work, covering the Axis
settings consolidation, so the pipeline launches with real content. Their locale keys are removed.

## 2. News page

It uses the same visual language as the Welcome showcase:

- The release story is first, at full width, with the hero art as its background.
- Below it, the other stories:
  - `featured` stories take full width, with the image on the left;
  - `card` stories sit two to a row, image on top.
- Each story has a "New" badge until it is seen, and its button if it has one.
- The empty state ("No news right now", with a Patch notes button) shows only if there are no
  stories and no release notes.

The news renderers in `DashboardWelcomeView.lua` (`news_featured`, `news_card`) are rewritten for this.
The unused news kinds (`class_icon_strip`, `text_banner`, `hero_media`, `accordion`) are removed once
nothing references them.

## 3. Welcome showcase

At the dashboard's native 1280×720 size, the page aims to fit without scrolling. It scrolls if the
player's text scale makes it taller. From top to bottom:

### 3.1 Hero (about 180px)

- **Left half:**
  - a version chip ("Version 6.6.0 · 5 October");
  - a title;
  - one line of text;
  - two buttons: **Open settings** (the module hub) and **What's new** (patch notes).
- **Right half:** the hero art, fading into the panel through a gradient alpha mask.
- It replaces the current hero and the three "start here" cards.

### 3.2 Module tiles (two rows, about 140px each)

There are eight tiles in a 4×2 grid: the seven modules (Focus, Presence, Vista, Insight, Echo,
Augment, Essence) plus **Integrations**.

- **Each tile has:**
  - a 4px strip in the module's accent colour;
  - a screenshot;
  - the module name and a two-word description;
  - an on/off chip.
- **The on/off chip is read-only.** Switching modules stays on the module hub, which owns the
  reload banner. Having two places to switch a module is the kind of duplication the consolidation
  work removed.
- **On hover,** the tile lifts its border to the accent colour and shows **Open**. Hover handlers sit
  on the tile button itself, never on an overlay texture.
- **Clicking** opens that module's settings. The Integrations tile opens the Integrations view.
- **A module that's off** shows a desaturated screenshot.

### 3.3 News strip (about 100px)

The top story from §1.3 takes about two thirds of the width: image, title, summary and "Read more".
The next two headlines sit beside it, with "All news". It uses the same data as the News page, so the
two can never disagree.

### 3.4 Credits footer (one line)

- Contributors, supporters (in class colours) and translators, with the full lists in a tooltip.
- Links to Discord, GitHub and Support, through the copy-link dialog.
- A **Module guide** link, which opens the existing standalone guide (`f.ShowModuleGuide`). The guide
  is no longer embedded in Welcome.

### 3.5 Feed data

`DashboardWelcomeFeedData.lua` is rewritten with the new kinds: `showcase_hero`, `module_tiles`,
`news_strip` and `credits_footer`. Supporter and contributor lists keep their current data. The old
kinds and their locale keys are removed once nothing references them.

## 4. Art

There is no AI image model in this environment, so the hero art is generated in code.

- **Hero image.** `tools/make_welcome_art.py` (Pillow) draws an abstract horizon:
  - layered arcs and a soft glow in the module accent colours on the dashboard's dark background;
  - 1024×512 PNG in `media/dashboard/welcome/`.

  The director approves it. A drop-in replacement with the same name and size needs no code change.
- **Module screenshots.** The director provides one per module and one of the Integrations view:
  - full-screen captures at the same UI scale;
  - each showing the module doing its main job.

  `tools/make_welcome_art.py --tiles` crops and resizes them to 512×256 PNGs in
  `media/dashboard/welcome/tiles/`.
- **Placeholders.** Until the screenshots arrive, each tile shows a flat accent-tinted card with the
  module's icon, so the page can ship and be tested without them.

## 5. Testing

- **`tools/test_build_news.py`** (unittest, standard library only):
  - parsing;
  - every rejection rule in §1.2;
  - escaping;
  - byte-for-byte deterministic output;
  - `--check` passing on a fresh build and failing after a story is edited.
- **`tools/test_news_logic.js`** (fengari):
  - expiry by date and by version;
  - sort order;
  - the release story, including versions with no notes;
  - unread state, including the first-run seeding.
- **Existing suites** stay green: options_logic, options_modules, echo_logic and lootroll_logic.
- **In game on Windows (director):**
  - Welcome fits at 1280×720 with default text;
  - tiles open the right pages;
  - the off-module tile is desaturated;
  - the News badge clears after opening News;
  - a story past its `until` date disappears without an update.

## 6. Delivery

Three stacked PRs into `feature/axis-settings-consolidation`:

1. **News pipeline:**
   - `news/` folder, build script, generated feed and CI check;
   - `DashboardNewsLogic`, the release story and the unread badge;
   - retire the old stories and ship the new one.
2. **News page restyle** (§2).
3. **Welcome showcase** (§3), with the generated hero art and placeholder tiles. Screenshots follow
   in that PR, or in a small follow-up if they arrive later.

## Out of scope

- Fetching news from the web, or sharing it between players over addon channels.
- Translating stories.
- Switching modules from the Welcome page.
- An onboarding or setup flow.
