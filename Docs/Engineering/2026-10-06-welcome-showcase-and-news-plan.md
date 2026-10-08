# Welcome showcase and curated news implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the hand-written News page with stories built from `news/*.md`, and replace the long Welcome page with a one-screen showcase.

**Architecture:** A standard-library Python script compiles story files into `options/dashboard/DashboardNewsFeed.lua`. A pure Lua module (`DashboardNewsLogic.lua`) filters, sorts and tracks unread stories, and builds the release story from patch notes. A new UI file (`DashboardShowcase.lua`) renders the News page and the Welcome showcase. It replaces `DashboardWelcomeView.lua`, which is deleted at the end.

**Tech stack:** Lua 5.1 (WoW Retail and Forever), Python 3 standard library (build script), Pillow (art script only, dev tooling, already used by `tools/make_update_card.py`), fengari for Lua tests.

**Spec:** `Docs/Engineering/2026-10-06-welcome-showcase-and-news-design.md`

## Global constraints

- Worktree `/Users/chris/projects/horizon-suite-welcome`, branch `feature/dashboard-welcome-showcase`. Never commit on `main` or `feature/axis-settings-consolidation` directly.
- Commits: `type(scope): description`, ≤72 chars, ending with the line `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Run `git add`, `git commit` and `git push` as separate commands, never chained.
- `.gitattributes` forces CRLF for every text file except `*.sh`. Edit existing files in place without changing their line endings. Generated files are compared with `\r\n` normalised to `\n`.
- New enUS strings go in `locales/horizon/enUS.lua`. Each also gets a commented stub, `-- L["KEY"] = "English text"`, appended to the end of `deDE.lua`, `esES.lua`, `frFR.lua`, `koKR.lua`, `ptBR.lua` and `zhCN.lua`, matching their existing tail. When a key is removed, delete it from all seven files.
- Copy style is sentence case and short. No "please", no exclamation marks.
- WoW: put `OnEnter`/`OnLeave` only on mouse-enabled `Button`s, never on overlay textures or frames layered over clickable content (they swallow clicks).
- `|` in story text is doubled (`||`) so it displays literally and can't start a WoW escape code.
- Field names in generated Lua: `fromDate`, `untilDate`, `untilVersion` (`until` is a Lua keyword).
- Lua tests: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_<name>.js`. All four existing suites must stay green: `test_options_logic.js` (436), `test_options_modules.js` (48), `test_echo_logic.js` (2857), `test_lootroll_logic.js` (90).
- Compile check for every touched Lua file: `node /private/tmp/claude-503/-Users-chris-projects-horizon-suite/791f91ff-e4be-43fd-b32e-e992ae930607/scratchpad/parse.js <file>`. If that path is missing, run `luac -p <file>` instead.
- Module keys: `axis focus presence vista insight augment essence echo`. Welcome tiles cover `focus presence vista insight echo augment essence`, plus Integrations.
- Delivery is two stacked PRs into `feature/axis-settings-consolidation` (see Ruling R1): PR A is Tasks 1–5, PR B is Tasks 6–7.

## Rulings made while planning

- **R1. Two PRs, not three.** The spec says the pipeline and the page restyle land separately. But the new feed format can't be drawn by the old renderers, so PR A on its own would leave News blank. The pipeline and the News page ship together as PR A.
  - If wrong: one larger PR to review, with no behaviour difference.
- **R2. "Support" is Ko-fi and Patreon.** The repo has no single support URL. The footer shows Discord, GitHub, Ko-fi and Patreon, using the existing `NAME_*` keys and URLs from `DashboardUtil.lua:594-597`.
- **R3. The release story never counts as unread.** The "What's new" sidebar row already badges new versions through `PatchNotes_RefreshAttentionIndicators`, so counting it here would badge one release twice.
- **R4. Welcome feed data.** The spec (§3.5) has the Welcome page assembled from typed feed entries, kept in `DashboardWelcomeFeedData.lua`. That file shrinks to the four entries and the credit lists. The renderer draws only those four kinds.

---

## File structure

| File | Status | Responsibility |
|---|---|---|
| `tools/build_news.py` | create | Parse, validate and compile `news/*.md` into Lua. `--check` mode for CI. |
| `tools/test_build_news.py` | create | unittest suite for the build script. |
| `news/axis-settings-refresh.md` | create | The launch story. |
| `options/dashboard/DashboardNewsFeed.lua` | regenerate | Generated `addon.DashboardNewsFeed`. |
| `options/dashboard/DashboardNewsLogic.lua` | create | Pure logic: version compare, visibility, sort, release story, unread state. |
| `tools/test_news_logic.js` | create | fengari tests for the logic module. |
| `tools/make_welcome_art.py` | create | Pillow: hero art, story images, screenshot tiles. |
| `media/dashboard/welcome/hero.png`, `media/news/axis-settings-refresh.png` | create | Generated art. |
| `options/dashboard/DashboardShowcase.lua` | create | Shared drawing helpers, the News page, and the Welcome showcase. |
| `options/dashboard/DashboardHomeWelcome.lua` | modify | Call the showcase initialisers instead of `DashboardWelcomeView_Init`. |
| `options/dashboard/DashboardFrame.lua` | modify | Un-embed the guide, mark news seen in `f.ShowNews`, refresh the badge on open. |
| `options/dashboard/DashboardWelcomeFeedData.lua` | rewrite | Four showcase entries plus credit lists. |
| `options/dashboard/DashboardWelcomeView.lua` | delete (Task 7) | Replaced by `DashboardShowcase.lua`. |
| `HorizonSuite.toc` | modify | Add `DashboardNewsLogic.lua` and `DashboardShowcase.lua`; remove `DashboardWelcomeView.lua` in Task 7. |
| `.pkgmeta`, `.github/workflows/luacheck.yml` | modify | Ignore `news`; run `build_news.py --check`. |
| `locales/horizon/*.lua` | modify | New keys added, retired keys removed. |

---

### Task 1: News build script, launch story and CI check

**Files:**
- Create: `tools/build_news.py`, `tools/test_build_news.py`, `news/axis-settings-refresh.md`
- Regenerate: `options/dashboard/DashboardNewsFeed.lua`
- Modify: `.pkgmeta` (add `- news` to `ignore:`, after `- tools`), `.github/workflows/luacheck.yml` (new step)

**Interfaces:**
- Produces: `addon.DashboardNewsFeed`, an array of story tables:
  - `id` (string), `title` (string), `layout` (`"card"` or `"featured"`), `priority` (number, default 100);
  - optional `fromDate`, `untilDate` (`"YYYY-MM-DD"`), `untilVersion` (string), `image` (texture path `"Interface/AddOns/HorizonSuite/media/news/<file>"`), `button` (string);
  - `action` (`{type="module",moduleKey=k}` | `{type="patch_notes"}` | `{type="news"}` | `{type="guide"}` | `{type="copy_url",url=u}`);
  - `paragraphs` (array of strings, at least 1).
- Produces: `python3 tools/build_news.py [--check]`.

- [ ] **Step 1: Write the failing tests** in `tools/test_build_news.py`:

```python
#!/usr/bin/env python3
"""Tests for tools/build_news.py. Run: python3 tools/test_build_news.py"""
import os
import struct
import sys
import tempfile
import unittest
import zlib

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import build_news as bn  # noqa: E402


def write_png(path, w, h):
    def chunk(tag, data):
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data))
    raw = b"".join(b"\x00" + b"\x00\x00\x00" * w for _ in range(h))
    with open(path, "wb") as fh:
        fh.write(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))
                 + chunk(b"IDAT", zlib.compress(raw)) + chunk(b"IEND", b""))


GOOD = """---
id: hello-world
title: Hello world
priority: 200
from: 2026-10-01
until: 2026-11-01
button: Open Focus
action: module focus
---
First paragraph
wraps here.

Second | paragraph "quoted".
"""


class Base(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.news = os.path.join(self.tmp.name, "news")
        self.media = os.path.join(self.tmp.name, "media")
        os.makedirs(self.news)
        os.makedirs(self.media)

    def tearDown(self):
        self.tmp.cleanup()

    def story(self, name, text):
        with open(os.path.join(self.news, name), "w", newline="\n") as fh:
            fh.write(text)

    def build(self):
        return bn.build(self.news, self.media)

    def assertRejects(self, text, fragment, name="hello-world.md"):
        self.story(name, text)
        with self.assertRaises(bn.StoryError) as ctx:
            self.build()
        self.assertIn(fragment, str(ctx.exception))


class BuildTests(Base):
    def test_good_story_compiles(self):
        self.story("hello-world.md", GOOD)
        lua = self.build()
        self.assertIn('id = "hello-world",', lua)
        self.assertIn('priority = 200,', lua)
        self.assertIn('fromDate = "2026-10-01",', lua)
        self.assertIn('untilDate = "2026-11-01",', lua)
        self.assertIn('action = { type = "module", moduleKey = "focus" },', lua)
        self.assertIn('"First paragraph wraps here.",', lua)
        self.assertIn('"Second || paragraph \\"quoted\\".",', lua)
        self.assertIn('layout = "card",', lua)

    def test_crlf_input_is_accepted(self):
        self.story("hello-world.md", GOOD.replace("\n", "\r\n"))
        self.assertIn('id = "hello-world",', self.build())

    def test_output_is_deterministic(self):
        self.story("hello-world.md", GOOD)
        self.story("another.md", GOOD.replace("hello-world", "another"))
        self.assertEqual(self.build(), self.build())
        self.assertLess(self.build().index('"another"'), self.build().index('"hello-world"'))

    def test_no_stories_gives_empty_feed(self):
        self.assertIn("addon.DashboardNewsFeed = {\n}", self.build())

    def test_url_action(self):
        self.story("hello-world.md", GOOD.replace("action: module focus", "action: url https://example.com/x"))
        self.assertIn('action = { type = "copy_url", url = "https://example.com/x" },', self.build())

    def test_featured_with_image(self):
        write_png(os.path.join(self.media, "pic.png"), 512, 256)
        self.story("hello-world.md", GOOD.replace("priority: 200", "priority: 200\nlayout: featured\nimage: pic.png"))
        lua = self.build()
        self.assertIn('image = "Interface/AddOns/HorizonSuite/media/news/pic.png",', lua)
        self.assertIn('layout = "featured",', lua)


class RejectTests(Base):
    def test_missing_front_matter(self):
        self.assertRejects("no front matter\n", "front matter")

    def test_missing_title(self):
        self.assertRejects(GOOD.replace("title: Hello world\n", ""), "missing required field 'title'")

    def test_unknown_field(self):
        self.assertRejects(GOOD.replace("priority: 200", "colour: red"), "unknown field 'colour'")

    def test_id_must_match_file(self):
        self.assertRejects(GOOD, "must match the file name", name="other.md")

    def test_bad_id(self):
        self.assertRejects(GOOD.replace("id: hello-world", "id: Hello_World"), "id", name="Hello_World.md")

    def test_duplicate_field(self):
        self.assertRejects(GOOD.replace("priority: 200", "priority: 200\npriority: 3"), "duplicate field")

    def test_long_title(self):
        self.assertRejects(GOOD.replace("Hello world", "x" * 61), "60 characters")

    def test_bad_layout(self):
        self.assertRejects(GOOD.replace("priority: 200", "layout: banner"), "layout")

    def test_bad_priority(self):
        self.assertRejects(GOOD.replace("priority: 200", "priority: high"), "priority")

    def test_bad_date(self):
        self.assertRejects(GOOD.replace("2026-10-01", "2026-13-01"), "from")

    def test_until_before_from(self):
        self.assertRejects(GOOD.replace("until: 2026-11-01", "until: 2026-09-01"), "before")

    def test_bad_version(self):
        self.assertRejects(GOOD.replace("priority: 200", "untilVersion: six"), "untilVersion")

    def test_missing_image(self):
        self.assertRejects(GOOD.replace("priority: 200", "image: nope.png"), "not found")

    def test_image_not_power_of_two(self):
        write_png(os.path.join(self.media, "pic.png"), 500, 256)
        self.assertRejects(GOOD.replace("priority: 200", "image: pic.png"), "power of two")

    def test_image_too_big(self):
        write_png(os.path.join(self.media, "pic.png"), 2048, 256)
        self.assertRejects(GOOD.replace("priority: 200", "image: pic.png"), "1024")

    def test_image_not_png(self):
        with open(os.path.join(self.media, "pic.png"), "wb") as fh:
            fh.write(b"GIF89a" + b"\x00" * 30)
        self.assertRejects(GOOD.replace("priority: 200", "image: pic.png"), "not a PNG")

    def test_featured_needs_image(self):
        self.assertRejects(GOOD.replace("priority: 200", "layout: featured"), "needs an image")

    def test_button_without_action(self):
        self.assertRejects(GOOD.replace("action: module focus\n", ""), "both")

    def test_unknown_module(self):
        self.assertRejects(GOOD.replace("module focus", "module meridian"), "unknown module")

    def test_http_url(self):
        self.assertRejects(GOOD.replace("module focus", "url http://example.com"), "https")

    def test_unknown_action(self):
        self.assertRejects(GOOD.replace("module focus", "launch"), "unknown action")

    def test_empty_body(self):
        self.assertRejects(GOOD.split("---\nFirst")[0] + "---\n\n", "no text")


class CheckModeTests(Base):
    def test_check_passes_then_fails_after_edit(self):
        self.story("hello-world.md", GOOD)
        out = os.path.join(self.tmp.name, "Feed.lua")
        self.assertEqual(bn.main(["--news", self.news, "--media", self.media, "--out", out]), 0)
        self.assertEqual(bn.main(["--check", "--news", self.news, "--media", self.media, "--out", out]), 0)
        self.story("hello-world.md", GOOD.replace("Hello world", "Changed"))
        self.assertEqual(bn.main(["--check", "--news", self.news, "--media", self.media, "--out", out]), 1)

    def test_check_ignores_crlf_difference(self):
        self.story("hello-world.md", GOOD)
        out = os.path.join(self.tmp.name, "Feed.lua")
        bn.main(["--news", self.news, "--media", self.media, "--out", out])
        with open(out, "rb") as fh:
            data = fh.read()
        with open(out, "wb") as fh:
            fh.write(data.replace(b"\r\n", b"\n"))
        self.assertEqual(bn.main(["--check", "--news", self.news, "--media", self.media, "--out", out]), 0)

    def test_invalid_story_exits_2(self):
        self.story("hello-world.md", "nope\n")
        out = os.path.join(self.tmp.name, "Feed.lua")
        self.assertEqual(bn.main(["--news", self.news, "--media", self.media, "--out", out]), 2)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run the tests and confirm they fail.**
  - Run: `python3 tools/test_build_news.py`
  - Expected: `ModuleNotFoundError: No module named 'build_news'`

- [ ] **Step 3: Write `tools/build_news.py`:**

```python
#!/usr/bin/env python3
"""Compile news/*.md into options/dashboard/DashboardNewsFeed.lua.

Each story is one Markdown file with a front matter block (see news/README.md).
The generated Lua is committed so a branch pulled onto a test PC shows the same
news a release will; CI runs --check so a story edited without a rebuild fails.

Usage:
  python3 tools/build_news.py          # rebuild the feed
  python3 tools/build_news.py --check  # exit 1 if the committed feed is stale

Exit codes: 0 ok, 1 stale (--check), 2 invalid story. Standard library only.
"""
import argparse
import datetime
import os
import re
import struct
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_NEWS = os.path.join(REPO, "news")
DEFAULT_MEDIA = os.path.join(REPO, "media", "news")
DEFAULT_OUT = os.path.join(REPO, "options", "dashboard", "DashboardNewsFeed.lua")
TEXTURE_PREFIX = "Interface/AddOns/HorizonSuite/media/news/"

MODULE_KEYS = {"axis", "focus", "presence", "vista", "insight", "augment", "essence", "echo"}
FIELDS = {"id", "title", "layout", "priority", "from", "until", "untilVersion",
          "image", "button", "action"}
ID_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
VERSION_RE = re.compile(r"^\d+(\.\d+){0,3}$")
MAX_TITLE = 60
MAX_IMAGE = 1024

HEADER = """--[[
    Horizon Suite - Dashboard news feed.
    GENERATED by tools/build_news.py from news/*.md. Do not edit this file:
    edit or add a story in news/ and run `python3 tools/build_news.py`.
]]

local addon = _G.HorizonSuite

"""


class StoryError(Exception):
    pass


def parse_story(name, text):
    text = text.replace("\r\n", "\n").lstrip("﻿")
    if not text.startswith("---\n"):
        raise StoryError(f"{name}: must start with a '---' front matter line")
    end = text.find("\n---\n", 3)
    if end < 0:
        raise StoryError(f"{name}: front matter has no closing '---' line")
    meta = {}
    for n, line in enumerate(text[4:end].split("\n"), start=2):
        if not line.strip():
            continue
        key, sep, value = line.partition(":")
        key, value = key.strip(), value.strip()
        if not sep:
            raise StoryError(f"{name}:{n}: expected 'key: value'")
        if key not in FIELDS:
            raise StoryError(f"{name}:{n}: unknown field '{key}'")
        if key in meta:
            raise StoryError(f"{name}:{n}: duplicate field '{key}'")
        meta[key] = value
    body = text[end + 5:]
    paragraphs = [" ".join(p.split()) for p in re.split(r"\n\s*\n", body) if p.strip()]
    return meta, paragraphs


def png_size(path):
    with open(path, "rb") as fh:
        head = fh.read(24)
    if len(head) < 24 or head[:8] != b"\x89PNG\r\n\x1a\n" or head[12:16] != b"IHDR":
        return None
    return struct.unpack(">II", head[16:24])


def parse_date(name, field, value):
    try:
        datetime.date.fromisoformat(value)
    except ValueError:
        raise StoryError(f"{name}: '{field}' must be a real date as YYYY-MM-DD, got '{value}'")
    if len(value) != 10:
        raise StoryError(f"{name}: '{field}' must be YYYY-MM-DD, got '{value}'")
    return value


def parse_action(name, value):
    kind, _, arg = value.partition(" ")
    arg = arg.strip()
    if kind == "module":
        if arg not in MODULE_KEYS:
            raise StoryError(f"{name}: unknown module '{arg}' (use one of {', '.join(sorted(MODULE_KEYS))})")
        return [("type", "module"), ("moduleKey", arg)]
    if kind in ("patch_notes", "news", "guide") and not arg:
        return [("type", kind)]
    if kind == "url":
        if not arg.startswith("https://") or " " in arg:
            raise StoryError(f"{name}: a url action needs one https:// address")
        return [("type", "copy_url"), ("url", arg)]
    raise StoryError(f"{name}: unknown action '{value}' (module <key>, patch_notes, news, guide, url <https://...>)")


def validate(name, meta, paragraphs, media_dir):
    for req in ("id", "title"):
        if not meta.get(req):
            raise StoryError(f"{name}: missing required field '{req}'")
    sid = meta["id"]
    if not ID_RE.match(sid):
        raise StoryError(f"{name}: id '{sid}' must be lowercase letters, digits and hyphens")
    if name != sid + ".md":
        raise StoryError(f"{name}: id '{sid}' must match the file name ({sid}.md)")
    if len(meta["title"]) > MAX_TITLE:
        raise StoryError(f"{name}: title is longer than {MAX_TITLE} characters")
    story = {"id": sid, "title": meta["title"]}
    layout = meta.get("layout", "card")
    if layout not in ("card", "featured"):
        raise StoryError(f"{name}: layout must be 'card' or 'featured', got '{layout}'")
    story["layout"] = layout
    priority = meta.get("priority", "100")
    if not re.match(r"^-?\d+$", priority):
        raise StoryError(f"{name}: priority must be a whole number, got '{priority}'")
    story["priority"] = int(priority)
    if "from" in meta:
        story["fromDate"] = parse_date(name, "from", meta["from"])
    if "until" in meta:
        story["untilDate"] = parse_date(name, "until", meta["until"])
    if "fromDate" in story and "untilDate" in story and story["untilDate"] < story["fromDate"]:
        raise StoryError(f"{name}: 'until' is before 'from'")
    if "untilVersion" in meta:
        if not VERSION_RE.match(meta["untilVersion"]):
            raise StoryError(f"{name}: untilVersion must look like 6.6.0, got '{meta['untilVersion']}'")
        story["untilVersion"] = meta["untilVersion"]
    if "image" in meta:
        img = meta["image"]
        path = os.path.join(media_dir, img)
        if "/" in img or "\\" in img or not os.path.isfile(path):
            raise StoryError(f"{name}: image '{img}' not found in media/news/")
        size = png_size(path)
        if size is None:
            raise StoryError(f"{name}: image '{img}' is not a PNG")
        for dim in size:
            if dim > MAX_IMAGE:
                raise StoryError(f"{name}: image '{img}' is {size[0]}x{size[1]}; the limit is {MAX_IMAGE}")
            if dim & (dim - 1):
                raise StoryError(f"{name}: image '{img}' is {size[0]}x{size[1]}; each side must be a power of two")
        story["image"] = TEXTURE_PREFIX + img
    elif layout == "featured":
        raise StoryError(f"{name}: a featured story needs an image")
    if ("button" in meta) != ("action" in meta):
        raise StoryError(f"{name}: give both 'button' and 'action', or neither")
    if "button" in meta:
        story["button"] = meta["button"]
        story["action"] = parse_action(name, meta["action"])
    if not paragraphs:
        raise StoryError(f"{name}: story has no text")
    story["paragraphs"] = paragraphs
    return story


def lua_str(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"').replace("|", "||") + '"'


def emit(stories):
    out = [HEADER, "addon.DashboardNewsFeed = {\n"]
    for s in stories:
        out.append("    {\n")
        for key in ("id", "title", "layout"):
            out.append(f"        {key} = {lua_str(s[key])},\n")
        out.append(f"        priority = {s['priority']},\n")
        for key in ("fromDate", "untilDate", "untilVersion", "image", "button"):
            if key in s:
                out.append(f"        {key} = {lua_str(s[key])},\n")
        if "action" in s:
            parts = ", ".join(f"{k} = {lua_str(v)}" for k, v in s["action"])
            out.append(f"        action = {{ {parts} }},\n")
        out.append("        paragraphs = {\n")
        for p in s["paragraphs"]:
            out.append(f"            {lua_str(p)},\n")
        out.append("        },\n    },\n")
    out.append("}\n")
    return "".join(out)


def build(news_dir, media_dir):
    stories = []
    names = sorted(n for n in os.listdir(news_dir) if n.endswith(".md") and n != "README.md") \
        if os.path.isdir(news_dir) else []
    for name in names:
        with open(os.path.join(news_dir, name), encoding="utf-8") as fh:
            meta, paragraphs = parse_story(name, fh.read())
        stories.append(validate(name, meta, paragraphs, media_dir))
    return emit(stories)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--check", action="store_true", help="exit 1 if the feed file is stale")
    ap.add_argument("--news", default=DEFAULT_NEWS)
    ap.add_argument("--media", default=DEFAULT_MEDIA)
    ap.add_argument("--out", default=DEFAULT_OUT)
    args = ap.parse_args(argv)
    try:
        lua = build(args.news, args.media)
    except StoryError as e:
        print(f"build_news: {e}", file=sys.stderr)
        return 2
    if args.check:
        try:
            with open(args.out, "rb") as fh:
                current = fh.read().decode("utf-8").replace("\r\n", "\n")
        except FileNotFoundError:
            current = None
        if current != lua:
            print(f"build_news: {os.path.relpath(args.out, REPO)} is out of date; "
                  "run `python3 tools/build_news.py` and commit the result", file=sys.stderr)
            return 1
        return 0
    with open(args.out, "wb") as fh:
        fh.write(lua.replace("\n", "\r\n").encode("utf-8"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

- [ ] **Step 4: Run the tests.**
  - Run: `python3 tools/test_build_news.py`
  - Expected: `OK` (31 tests). Fix the script, not the tests, unless a test contradicts the spec.

- [ ] **Step 5: Add `news/README.md` and the launch story.**
  - `news/README.md` holds the field table from spec §1.1 (copy it), the action forms, and the two commands. `build()` skips `README.md`.
  - `news/axis-settings-refresh.md`, as a `card` with no image until Task 4 adds the art:

```markdown
---
id: axis-settings-refresh
title: A tidier settings dashboard
priority: 500
from: 2026-10-06
until: 2026-12-31
button: Open settings
action: module axis
---
Every on-screen element now has one card, with its switch at the top and everything else for it underneath.

Search understands typos and synonyms, and remembers what you looked for.
```

- [ ] **Step 6: Regenerate the feed, then confirm `--check` and Lua parsing.**
  - Run: `python3 tools/build_news.py && python3 tools/build_news.py --check && echo FRESH`
  - Expected: `FRESH`.
  - Then run the compile check on `options/dashboard/DashboardNewsFeed.lua`.
  - The old renderer now gets entries with no `kind`, so News shows nothing until Task 5. PR A isn't opened until Task 5 is done.

- [ ] **Step 7: CI and packaging.**
  - `.pkgmeta`: add the line `  - news` after `  - tools`.
  - `.github/workflows/luacheck.yml`: add a step after checkout, preserving CRLF:

```yaml
      - name: News feed is up to date
        run: |
          python3 tools/build_news.py --check
          python3 tools/test_build_news.py
```

- [ ] **Step 8: Commit.**
  - `git add tools/build_news.py tools/test_build_news.py news .pkgmeta .github/workflows/luacheck.yml options/dashboard/DashboardNewsFeed.lua`
  - `git commit -m "feat(dashboard): build the news feed from story files"`, with the trailer.

---

### Task 2: News logic module

**Files:**
- Create: `options/dashboard/DashboardNewsLogic.lua`, `tools/test_news_logic.js`
- Modify: `HorizonSuite.toc` (add `options\dashboard\DashboardNewsLogic.lua` directly after the `DashboardNewsFeed.lua` line, matching the existing path style there), `locales/horizon/enUS.lua` plus stubs (add `DASH_NEWS_RELEASE_TITLE_X = "What's new in %s"` and `DASH_NEWS_RELEASE_BUTTON = "Patch notes"` near the other `DASH_NEWS_` keys)

**Interfaces:**
- Consumes: `addon.DashboardNewsFeed` (Task 1 shape), `addon.PATCH_NOTES`, `addon.L`.
- Produces `addon.NewsLogic` with:
  - `CompareVersions(a, b) -> -1|0|1`
  - `IsVisible(story, today, version) -> bool`
  - `Visible(stories, today, version) -> array` (sorted)
  - `ReleaseStory(patchNotes, version) -> story|nil` (`layout="release"`, `isRelease=true`, `version`, `date`)
  - `Feed(stories, patchNotes, today, version) -> array` (release first)
  - `UnseenCount(feed, seen) -> number`
  - `MarkSeen(feed, seen)`
  - `EnsureSeen(rootDB, feed) -> seenTable, firstRun`
  - `Today() -> "YYYY-MM-DD"`
  - `CurrentVersion() -> string`

- [ ] **Step 1: Write the failing test** `tools/test_news_logic.js`. Copy the header, harness and `run()` from `tools/test_lootroll_logic.js` lines 1–49, then:

```js
run(`
  _G.HorizonSuite = { L = setmetatable({}, { __index = function(_, k) return k end }) }
`, 'stubs');
run(read('locales/horizon/enUS.lua'), 'enUS');
run(read('options/dashboard/DashboardNewsLogic.lua'), 'NewsLogic');

run(`
  local N = HorizonSuite.NewsLogic
  local pass, fail = 0, 0
  local function check(name, ok, got)
    if ok then pass = pass + 1
    else fail = fail + 1; print("  FAIL: " .. name .. "  got: " .. tostring(got)) end
  end
  local function ids(list) local t = {} for i, s in ipairs(list) do t[i] = s.id end return table.concat(t, ",") end

  -- Versions compare numerically, so 6.10.0 is newer than 6.9.0.
  check("6.10.0 > 6.9.0", N.CompareVersions("6.10.0", "6.9.0") == 1)
  check("6.6 == 6.6.0", N.CompareVersions("6.6", "6.6.0") == 0)
  check("6.5.1 < 6.6.0", N.CompareVersions("6.5.1", "6.6.0") == -1)

  local s = { id = "a", fromDate = "2026-10-01", untilDate = "2026-10-31" }
  check("before from is hidden", not N.IsVisible(s, "2026-09-30", "6.6.0"))
  check("on from is shown", N.IsVisible(s, "2026-10-01", "6.6.0"))
  check("on until is shown", N.IsVisible(s, "2026-10-31", "6.6.0"))
  check("after until is hidden", not N.IsVisible(s, "2026-11-01", "6.6.0"))
  local v = { id = "v", untilVersion = "6.6.0" }
  check("same version shown", N.IsVisible(v, "2026-10-06", "6.6.0"))
  check("newer version hides", not N.IsVisible(v, "2026-10-06", "6.6.1"))
  check("unknown version keeps it", N.IsVisible(v, "2026-10-06", ""))

  local feed = N.Visible({
    { id = "low",  priority = 100, fromDate = "2026-10-05" },
    { id = "high", priority = 500 },
    { id = "newer", priority = 100, fromDate = "2026-10-06" },
    { id = "b", priority = 100 }, { id = "a", priority = 100 },
    { id = "gone", priority = 900, untilDate = "2026-01-01" },
  }, "2026-10-06", "6.6.0")
  check("sort: priority, then newest from, then id", ids(feed) == "high,newer,low,a,b", ids(feed))

  local notes = { ["6.6.0"] = { date = "2026-10-05",
    { section = "New Features", bullets = { "One." } },
    { section = "Fixes", bullets = { "Two.", "Three." } } } }
  local r = N.ReleaseStory(notes, "6.6.0")
  check("release id", r and r.id == "release-6.6.0", r and r.id)
  check("release title", r and r.title == "What's new in 6.6.0", r and r.title)
  check("release takes first two bullets", r and #r.paragraphs == 2 and r.paragraphs[2] == "Two.")
  check("release action", r and r.action.type == "patch_notes")
  check("release flagged", r and r.isRelease == true and r.layout == "release" and r.date == "2026-10-05")
  check("no notes, no release", N.ReleaseStory(notes, "9.9.9") == nil)
  check("nil notes, no release", N.ReleaseStory(nil, "6.6.0") == nil)
  check("empty notes, no release", N.ReleaseStory({ ["1.0"] = { { section = "x", bullets = {} } } }, "1.0") == nil)

  local full = N.Feed({ { id = "x", priority = 999 } }, notes, "2026-10-06", "6.6.0")
  check("release story is first", ids(full) == "release-6.6.0,x", ids(full))
  check("feed with nothing is empty", #N.Feed(nil, nil, "2026-10-06", "6.6.0") == 0)

  -- Unread: the release story never counts (the What's new row badges it already).
  local root = {}
  local seen, first = N.EnsureSeen(root, full)
  check("first run creates the table", first == true and root.newsSeen == seen)
  check("first run marks existing stories seen", N.UnseenCount(full, seen) == 0)
  local more = N.Feed({ { id = "x" }, { id = "y" } }, notes, "2026-10-06", "6.6.0")
  local seen2, first2 = N.EnsureSeen(root, more)
  check("second run is not first", first2 == false and seen2 == seen)
  check("a new story is unseen", N.UnseenCount(more, seen2) == 1, N.UnseenCount(more, seen2))
  N.MarkSeen(more, seen2)
  check("mark seen clears it", N.UnseenCount(more, seen2) == 0)
  check("release id never stored", seen2["release-6.6.0"] == nil)
  check("Today is ISO", type(N.Today()) == "string")

  print(string.format("news_logic: %d passed, %d failed", pass, fail))
  if fail > 0 then error("failures") end
`, 'assertions');
```

  `Today()` relies on `os.date`, which fengari provides. In game it uses the global `date`.

- [ ] **Step 2: Run it and confirm it fails.**
  - Run: `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_news_logic.js`
  - Expected: an error that `DashboardNewsLogic.lua` is missing (ENOENT).

- [ ] **Step 3: Write `options/dashboard/DashboardNewsLogic.lua`:**

```lua
--[[
    Horizon Suite - Dashboard news logic (pure; no frames).
    Filters the generated feed (DashboardNewsFeed.lua) by date and version, sorts it,
    puts a story built from this version's patch notes first, and tracks which
    stories the player has seen. Tested by tools/test_news_logic.js.
]]

local addon = _G.HorizonSuite
if not addon then return end

local NewsLogic = {}
addon.NewsLogic = NewsLogic

local DEFAULT_PRIORITY = 100

local function VersionParts(v)
    local t = {}
    for n in tostring(v or ""):gmatch("%d+") do t[#t + 1] = tonumber(n) end
    return t
end

--- @return number -1 when a < b, 0 when equal, 1 when a > b (numeric per part; missing parts are 0)
function NewsLogic.CompareVersions(a, b)
    local pa, pb = VersionParts(a), VersionParts(b)
    for i = 1, math.max(#pa, #pb) do
        local x, y = pa[i] or 0, pb[i] or 0
        if x ~= y then return x < y and -1 or 1 end
    end
    return 0
end

--- Dates are ISO strings, so string comparison orders them correctly.
function NewsLogic.IsVisible(story, today, version)
    if story.fromDate and today < story.fromDate then return false end
    if story.untilDate and today > story.untilDate then return false end
    if story.untilVersion and version and version ~= ""
        and NewsLogic.CompareVersions(version, story.untilVersion) > 0 then
        return false
    end
    return true
end

function NewsLogic.Visible(stories, today, version)
    local out = {}
    for i = 1, #(stories or {}) do
        local s = stories[i]
        if NewsLogic.IsVisible(s, today, version) then out[#out + 1] = s end
    end
    table.sort(out, function(a, b)
        local pa, pb = a.priority or DEFAULT_PRIORITY, b.priority or DEFAULT_PRIORITY
        if pa ~= pb then return pa > pb end
        local fa, fb = a.fromDate or "", b.fromDate or ""
        if fa ~= fb then return fa > fb end
        return a.id < b.id
    end)
    return out
end

--- A story from the installed version's patch notes: its first two bullets, linking to Patch notes.
function NewsLogic.ReleaseStory(patchNotes, version)
    local notes = type(patchNotes) == "table" and version and patchNotes[version]
    if type(notes) ~= "table" then return nil end
    local paragraphs = {}
    for _, section in ipairs(notes) do
        for _, bullet in ipairs(section.bullets or {}) do
            if #paragraphs < 2 then paragraphs[#paragraphs + 1] = bullet end
        end
    end
    if #paragraphs == 0 then return nil end
    local L = addon.L or {}
    return {
        id = "release-" .. version,
        layout = "release",
        isRelease = true,
        version = version,
        date = notes.date,
        title = (L["DASH_NEWS_RELEASE_TITLE_X"] or "What's new in %s"):format(version),
        button = L["DASH_NEWS_RELEASE_BUTTON"] or "Patch notes",
        action = { type = "patch_notes" },
        paragraphs = paragraphs,
    }
end

function NewsLogic.Feed(stories, patchNotes, today, version)
    local out = {}
    local release = NewsLogic.ReleaseStory(patchNotes, version)
    if release then out[1] = release end
    local visible = NewsLogic.Visible(stories, today, version)
    for i = 1, #visible do out[#out + 1] = visible[i] end
    return out
end

function NewsLogic.UnseenCount(feed, seen)
    local n = 0
    for i = 1, #(feed or {}) do
        local s = feed[i]
        if not s.isRelease and not (seen and seen[s.id]) then n = n + 1 end
    end
    return n
end

function NewsLogic.MarkSeen(feed, seen)
    for i = 1, #(feed or {}) do
        local s = feed[i]
        if not s.isRelease then seen[s.id] = true end
    end
end

--- Returns rootDB.newsSeen, creating it on first run with every current story marked
--- seen, so existing players aren't badged for news that was already there.
--- @return table seen, boolean firstRun
function NewsLogic.EnsureSeen(rootDB, feed)
    if type(rootDB.newsSeen) == "table" then return rootDB.newsSeen, false end
    rootDB.newsSeen = {}
    NewsLogic.MarkSeen(feed, rootDB.newsSeen)
    return rootDB.newsSeen, true
end

function NewsLogic.Today()
    local d = _G.date or (os and os.date)
    return d and d("%Y-%m-%d") or ""
end

function NewsLogic.CurrentVersion()
    local gm = (C_AddOns and C_AddOns.GetAddOnMetadata) or _G.GetAddOnMetadata
    return (gm and gm(addon.ADDON_NAME or "HorizonSuite", "Version")) or ""
end

--- The feed as the dashboard shows it right now.
function NewsLogic.CurrentFeed()
    return NewsLogic.Feed(addon.DashboardNewsFeed, addon.PATCH_NOTES, NewsLogic.Today(), NewsLogic.CurrentVersion())
end
```

- [ ] **Step 4: Run the tests.**
  - Run `test_news_logic.js`; expect `news_logic: 30 passed, 0 failed` (the exact count may differ by one or two).
  - Run the compile check on the new file.

- [ ] **Step 5: Add the TOC line and locale keys, then rerun all four existing suites.** Expect the counts in Global Constraints.

- [ ] **Step 6: Commit.**
  - `git add options/dashboard/DashboardNewsLogic.lua tools/test_news_logic.js HorizonSuite.toc locales/horizon`
  - `git commit -m "feat(dashboard): filter, sort and track news stories"`, with the trailer.

---

### Task 3: Showcase art script and generated art

**Files:**
- Create: `tools/make_welcome_art.py`, `media/dashboard/welcome/hero.png`, `media/news/axis-settings-refresh.png`
- Modify: `news/axis-settings-refresh.md` (add `layout: featured` and `image: axis-settings-refresh.png`), the regenerated `options/dashboard/DashboardNewsFeed.lua`

**Interfaces:**
- Produces:
  - `media/dashboard/welcome/hero.png`, 1024×512 RGBA;
  - `media/news/axis-settings-refresh.png`, 512×256;
  - the CLI `python3 tools/make_welcome_art.py hero|story <name>|tiles <src_dir>`.
- `tiles` writes `media/dashboard/welcome/tiles/<module>.png`, 512×256, from screenshots named `<module>.png|jpg` (`focus presence vista insight echo augment essence integrations`). It centre-crops to 2:1 and resizes with LANCZOS.

- [ ] **Step 1: Write the script.**
  - Use Pillow only, with `argparse` subcommands. It must be deterministic: a fixed `random.Random(seed)`, where the seed is `zlib.crc32` of the output name.
  - Background: the dashboard's dark `#16161C`.
  - Draw an abstract horizon:
    - a low wide ellipse glow near the bottom-right, built from concentric ellipses with alpha falling 60→0;
    - 7 thin arcs (width 2–3px) in the module accents, `FFD133 33FFDF B366FF FF66B3 8FA3E8 33CC66 DC143C`, fanning from a point off the right edge;
    - a faint star field of 60 dots at alpha 30–90.
  - Leave the left 40% darkest. The Lua side fades the left edge with a gradient, so the art doesn't need to.
  - `story <name>` draws the same motif at 512×256, with the seed taken from the name.
  - Save with `optimize=True`.
  - Also write a short module docstring with usage, matching `tools/make_update_card.py`'s style.
- [ ] **Step 2: Generate the art.**
  - Run: `python3 tools/make_welcome_art.py hero && python3 tools/make_welcome_art.py story axis-settings-refresh`
  - Run it twice and confirm the output is identical: `shasum media/dashboard/welcome/hero.png` should match both times.
- [ ] **Step 3: Test `tiles` on a fake screenshot.**
  - `python3 - <<'EOF'` with Pillow, create `/private/tmp/claude-503/-Users-chris-projects-horizon-suite/791f91ff-e4be-43fd-b32e-e992ae930607/scratchpad/shots/focus.png` at 1920×1080.
  - Run `tiles` on that folder with an `--out` override pointing to the scratchpad, so the repo isn't touched.
  - Check the output is 512×256. Don't commit any tile output.
- [ ] **Step 4: Feature the launch story.**
  - Add `layout: featured` and `image: axis-settings-refresh.png` to the story.
  - Run `python3 tools/build_news.py && python3 tools/build_news.py --check` and the compile check.
- [ ] **Step 5: Send both PNGs to the director** with SendUserFile for approval (this is the controller's job, not the implementer's).
- [ ] **Step 6: Commit.**
  - `git add tools/make_welcome_art.py media/dashboard/welcome/hero.png media/news news options/dashboard/DashboardNewsFeed.lua`
  - `git commit -m "feat(dashboard): generate showcase hero and story art"`, with the trailer.

---

### Task 4: Shared showcase helpers and the News page

**Files:**
- Create: `options/dashboard/DashboardShowcase.lua`
- Modify:
  - `HorizonSuite.toc`: add `DashboardShowcase.lua` after `DashboardWelcomeView.lua`.
  - `options/dashboard/DashboardHomeWelcome.lua:509-516`: replace the `newsEnv` block with `envAddon.DashboardShowcase_InitNews(env)`.
  - `options/dashboard/DashboardFrame.lua`: in `f.ShowNews` (about line 1566), after the view is shown, call `addon.News_MarkAllSeen()`. After the sidebar is built (after `f.newsSidebarBtn = newsBtn`, about line 1745), call `addon.News_RefreshSidebarBadge()`.
  - `locales/horizon/*.lua`: add the keys below; remove the keys of the retired stories.

**Interfaces:**
- Consumes:
  - `addon.NewsLogic` (Task 2);
  - `addon.DashboardSidebar_SetRowBadge(btn, text|nil, "accent")`;
  - `_G.HorizonDB` (the root DB; create it if nil);
  - `f.OpenModule(name, key)`, `f.ShowPatchNotes`, `f.ShowNews`, `f.ShowModuleGuide`, `f.ShowDashboard`;
  - `addon.ShowURLCopyBox(url, subtitle)`, `addon.Dashboard_BrandModule(key)`, `addon.PatchNotes_FormatIsoDateLongUK(iso)`;
  - the env fields listed under "Env" below.
- Produces:
  - `addon.DashboardShowcase_InitNews(env)`;
  - `addon.News_MarkAllSeen()`, `addon.News_RefreshSidebarBadge()`;
  - `addon.Showcase` (helper table) with `Showcase.DispatchAction(f, action, label)`, `Showcase.MakePanel(parent)`, `Showcase.MakeStory(parent, env, story, style)` (`style` is `"hero"|"featured"|"card"|"strip"`; returns a block with `:Layout(width) -> height`), `Showcase.MakeButton(parent, env, label, filled)`, `Showcase.HERO_ART`.
  - `newsView._layoutWelcomeContent` (kept under that name because `DashboardFrame.lua:2323` calls it on resize) and `newsView._scrollContent`.

**Env** (`newsEnv` is `homeEnv`, already in scope in `DashboardHomeWelcome_Init`): `f, addon, L, newsView, dashScrollTopOffset, dashAccentRefs, GetAccentColor, MakeText, DASHBOARD_CONTENT_CARD_ALPHA_MULT`.

**New enUS keys:**

| Key | Text |
|---|---|
| `DASH_NEWS_EMPTY_TITLE` | No news right now |
| `DASH_NEWS_EMPTY_BODY` | Patch notes list every change in this version. |
| `DASH_NEWS_READ_MORE` | Read more |

`DASH_NEWS_BADGE_NEW` ("New") is reused.

**Keys to remove from all seven locales:** every `DASH_NEWS_*` key in the fact list except `TAB`, `HEAD_SUB`, `BADGE_NEW`, `RELEASE_TITLE_X`, `RELEASE_BUTTON` and the three above. Before deleting each key, `grep -rn` the repo; keep any key that is still referenced outside `DashboardWelcomeView.lua`.

Requirements (the implementer writes the frame code against these; most-capable model):

- [ ] **Step 1: Scaffold.** Shape `DashboardShowcase.lua` like the other dashboard files: the header comment, `local addon = _G.HorizonSuite; if not addon then return end`, and `local Showcase = {}; addon.Showcase = Showcase`.
  - `Showcase.HERO_ART = "Interface/AddOns/HorizonSuite/media/dashboard/welcome/hero.png"`.
- [ ] **Step 2: Scroll and background.** `DashboardShowcase_InitNews(env)` builds the view's background, scroll frame and content the same way `DashboardWelcomeView.lua:330-352` does.
  - Copy its `welcomeBg` insets and `Dashboard_ApplySmoothScroll(scroll, content, 60, true)`.
  - Keep the community footer: `addon.Dashboard_CreateCommunityFooter(newsView, env)`, laid out as in that file.
  - Set `newsView._scrollContent = content`.
- [ ] **Step 3: `Showcase.DispatchAction(f, action, label)`.** Port `DispatchNewsAction` from `DashboardWelcomeView.lua:286-319` (read it there; the file still exists until Task 7).
  - Action types: `module`, `patch_notes`, `guide`, `dashboard`, `news`, `copy_url`, and new `integrations` (calls `f.ShowIntegrations`).
  - `copy_url` calls `addon.ShowURLCopyBox(action.url, (L["DASH_COPY_LINK_X"]):format(label))`.
- [ ] **Step 4: `Showcase.MakeStory(parent, env, story, style)`.** Each style draws as follows:
  - **`hero`** (used for the release story):
    - a full-width panel 200px high with `Showcase.HERO_ART` filling it (`SetTexCoord` crop keeps a 2:1 ratio);
    - a left-to-right gradient overlay from the panel colour at alpha 1 to alpha 0 over the left 60% (`tex:SetGradient("HORIZONTAL", CreateColor(r,g,b,1), CreateColor(r,g,b,0))`, guarded with `if CreateColor then`);
    - on the left: the version chip text (`date` via `PatchNotes_FormatIsoDateLongUK`), the title at 20pt, both paragraphs at 12pt in `{0.72,0.72,0.76}`, and the button.
  - **`featured`:** full width, 150px high; the image on the left at a 2:1 ratio, with title, paragraphs and button on the right.
  - **`card`:** half width; the image on top at a 2:1 ratio if present, then title, the first paragraph, then the button.
  - **`strip`:** used by Welcome in Task 6; image on the left, about 110×55. Show only the title and the first paragraph, at most 2 lines (`SetMaxLines(2)`), then a "Read more" link that runs the story's action.
  - **Every style:**
    - panel background from `addon.OptionsWidgetsDef.SectionCardBg` times `DASHBOARD_CONTENT_CARD_ALPHA_MULT`, with a 1px border at alpha 0.08;
    - a "New" badge (the accent pill, the same look as the sidebar's `SetRowBadge`) at the top right when `not story.isRelease and not seen[story.id]`, where `seen` is passed in through `env.newsSeen`;
    - the button runs `Showcase.DispatchAction(env.f, story.action, story.button)`.
  - Text uses `env.MakeText(parent, text, size, r, g, b, "LEFT")`, so fonts follow the dashboard typography settings. Titles are white; the accent comes from `env.GetAccentColor()`, with button and chip objects registered in `env.dashAccentRefs` the same way the existing CTA buttons are.
- [ ] **Step 5: News page layout.** `_layoutWelcomeContent` does the following:
  - Read `NewsLogic.CurrentFeed()` and `seen` (`NewsLogic.EnsureSeen(HorizonDB, feed)`).
  - Release story: `hero`. Then `featured` stories at full width, then `card` stories two per row with a 12px gap, keeping the feed's order in each group.
  - Empty feed: centre the empty-state title and body, with a "Patch notes" button (`patch_notes` action).
  - Pool the blocks by story id. Hide blocks whose id is gone.
  - Content height is the sum of the blocks. Then lay out the footer, as `DashboardWelcomeView` does.
  - Register `OnShow` and `OnSizeChanged` the same way `DashboardWelcomeView.lua:2039-2050` does.
- [ ] **Step 6: Badge API.** Add `addon.News_RefreshSidebarBadge()` and `addon.News_MarkAllSeen()`:
  - **`News_RefreshSidebarBadge()`:**
    - `local dash = _G.HorizonSuiteDashboard`;
    - if `dash and dash.newsSidebarBtn`, set the badge to `L["DASH_NEWS_BADGE_NEW"]` when the unseen count is above 0, otherwise to nil.
  - **`News_MarkAllSeen()`:**
    - `MarkSeen` on the current feed;
    - refresh the badge;
    - relayout `newsView` if it's shown, so the story badges clear on the *next* open, not instantly. Badges are drawn from the `seen` snapshot taken when the page opens.
- [ ] **Step 7: Wire it in.**
  - Replace the news Init call in `DashboardHomeWelcome.lua`.
  - Add the two calls in `DashboardFrame.lua`.
  - Add the TOC line.
  - Run the compile check on every touched Lua file.
- [ ] **Step 8: Remove the retired news locale keys** from all seven locale files, with the grep guard above. Then:
  - run all five fengari suites;
  - run `python3 tools/test_build_news.py`;
  - run `grep -rn "DASH_NEWS_FEATURED\|DASH_NEWS_ROADMAP\|DASH_NEWS_HIGHLIGHT" --include=*.lua .`, and expect hits only in `DashboardWelcomeView.lua`.
- [ ] **Step 9: Commit.**
  - `git add options/dashboard HorizonSuite.toc locales/horizon`
  - `git commit -m "feat(dashboard): redesign the news page around story files"`, with the trailer.

---

### Task 5: Open PR A

- [ ] **Step 1:** Push the branch as `feature/dashboard-news-feed`:
  - `git push -u origin HEAD:feature/dashboard-news-feed`;
  - then `git branch -m feature/dashboard-news-feed` locally.

  PR B continues on `feature/dashboard-welcome-showcase`, created from it in Task 6.
- [ ] **Step 2:** Open the PR to `feature/axis-settings-consolidation` with the `/pr` skill. Evidence for a no-screenshot change:
  - the test output;
  - the generated feed diff;
  - the art PNGs;
  - the Windows command `git fetch origin; git switch feature/dashboard-news-feed; git pull`.

  The reviewer checklist covers the News page in game:
  - the release story is on top;
  - the launch story shows its art;
  - the New badge is on the sidebar for a fresh story and clears after News is opened twice;
  - resizing the dashboard reflows.

---

### Task 6: Welcome showcase

**Files:**
- Modify:
  - `options/dashboard/DashboardShowcase.lua`: add `addon.DashboardShowcase_InitWelcome(env)`.
  - `options/dashboard/DashboardWelcomeFeedData.lua`: rewrite.
  - `options/dashboard/DashboardHomeWelcome.lua:505-507`: call `DashboardShowcase_InitWelcome(env)` instead of `DashboardWelcomeView_Init(env)`.
  - `options/dashboard/DashboardFrame.lua:1480-1481`: set `guideEmbeddedInWelcome = false` and delete the `guideScrollContent` line, so the guide builds its own standalone view through `f.ShowModuleGuide`.
  - `locales/horizon/*.lua`.

**Interfaces:**
- Consumes:
  - everything Task 4 produced, including `Showcase.MakeStory(..., "strip")`;
  - `addon:IsModuleEnabled(key)`, `f.OpenModule`, `f.ShowIntegrations`, `f.ShowDashboard`, `f.ShowPatchNotes`, `f.ShowModuleGuide`;
  - `addon.Dashboard_BrandModule(key)`.
- Produces:
  - `f.ShowWelcome`, with the same behaviour as `DashboardWelcomeView.lua:2051` (port its body: hide the other views, fade in, head subtitle, hide the search shell, `SetSidebarState({view="welcome",...})`, `DashboardPreview.SetActiveModuleKey(nil)`, `ApplyDashboardClassColor`);
  - `welcomeView._layoutWelcomeContent` and `welcomeView._scrollContent`.

**`DashboardWelcomeFeedData.lua` rewrite:**

```lua
--[[
    Horizon Suite - Welcome showcase layout and credits.
    Rendered top to bottom by DashboardShowcase.lua (DashboardShowcase_InitWelcome).
]]

local addon = _G.HorizonSuite

addon.DashboardWelcomeFeed = {
    { id = "hero",    kind = "showcase_hero" },
    { id = "modules", kind = "module_tiles",
      tiles = { "focus", "presence", "vista", "insight", "echo", "augment", "essence", "integrations" } },
    { id = "news",    kind = "news_strip" },
    { id = "credits", kind = "credits_footer" },
}

-- Credits shown in the footer tooltip. { name, classFile } — classFile is WoW's English class token.
addon.DashboardWelcomeCredits = {
    contributors = { --[[ copy the names from the current DASH_WELCOME_CONTRIBUTORS_BODY string ]] },
    supporters = {
        { name = "Diva", classFile = "PRIEST" },
        { name = "Feralus", classFile = "DRUID" },
        { name = "Jarvis", classFile = "MAGE" },
        { name = "Savs", classFile = "SHAMAN" },
        { name = "Vukolak", classFile = "WARLOCK" },
        { name = "Boofuls", classFile = "PALADIN" },
        { name = "SubtleGrind" },
    },
    translators = { --[[ copy the names from the current DASH_WELCOME_LOCALISATIONS_BODY string ]] },
}
```

Fill the two copied lists with the actual names from the enUS strings before committing; no comment placeholders may remain. If a string carries prose rather than a list of names, keep that string's key and show it as the tooltip text instead.

**New enUS keys:**

| Key | Text |
|---|---|
| `DASH_WELCOME_SHOWCASE_TITLE` | Craft your UI, your way |
| `DASH_WELCOME_SHOWCASE_BODY` | Seven modules that reshape Blizzard's interface. Turn on the ones you want. |
| `DASH_WELCOME_VERSION_X` | Version %s |
| `DASH_WELCOME_OPEN_SETTINGS` | Open settings |
| `DASH_WELCOME_WHATS_NEW` | What's new |
| `DASH_WELCOME_MODULES` | The modules |
| `DASH_WELCOME_OPEN` | Open |
| `DASH_WELCOME_ON` | On |
| `DASH_WELCOME_OFF` | Off |
| `DASH_WELCOME_LATEST` | Latest news |
| `DASH_WELCOME_ALL_NEWS` | All news |
| `DASH_WELCOME_MADE_WITH` | Made with help from contributors, supporters and translators |
| `DASH_WELCOME_MODULE_GUIDE` | Module guide |
| `DASH_WELCOME_TILE_FOCUS` | Quest tracker |
| `DASH_WELCOME_TILE_PRESENCE` | Zone and quest text |
| `DASH_WELCOME_TILE_VISTA` | Minimap |
| `DASH_WELCOME_TILE_INSIGHT` | Tooltips |
| `DASH_WELCOME_TILE_ECHO` | Chat |
| `DASH_WELCOME_TILE_AUGMENT` | Loot and alerts |
| `DASH_WELCOME_TILE_ESSENCE` | Character sheet |
| `DASH_WELCOME_TILE_INTEGRATIONS` | Other addons |

Requirements:

- [ ] **Step 1: Hero (180px).**
  - A panel with `Showcase.HERO_ART` on its right 55%, with the same left gradient fade as the News hero.
  - Version chip: `DASH_WELCOME_VERSION_X` with `NewsLogic.CurrentVersion()`, plus " · " and the date from `PatchNotes_FormatIsoDateLongUK(PATCH_NOTES[v].date)` when it exists.
  - Title at 22pt and body at 12pt, then two buttons:
    - **Open settings** (filled) runs `f.ShowDashboard`;
    - **What's new** (outline) runs `f.ShowPatchNotes`.
- [ ] **Step 2: Module tiles.**
  - "The modules" label, then a 4×2 grid with a 10px gap. Tile width is `(w - 30) / 4` and height is 140.
  - Each tile is a `Button` (mouse enabled) with:
    - a 4px top strip in the module accent, taken from `TILE_MODULE_LABEL_COLORS` (in `homeEnv`); Integrations uses the dashboard accent;
    - an image area 2:1 under it. If `media/dashboard/welcome/tiles/<key>.png` exists in `addon.WelcomeTileArt[key]` (a table in `DashboardWelcomeFeedData.lua` listing the shipped tile files, empty for now), show it. Otherwise show the placeholder: the accent colour at alpha 0.12 with the module icon centred at 40px (the icons from `DashboardHomeWelcome.lua:67` `MODULE_ICONS`; move that table to `addon.DashboardModuleIcons` and use it from both files);
    - the brand name (`Dashboard_BrandModule(key)`, or `L["DASH_INTEGRATIONS_TAB"]`) at 13pt with the tile description at 11pt under it;
    - an On/Off chip on the right, accent-filled when on and grey when off. It is read-only: no mouse handlers. Integrations has no chip.
  - When a module is off, the image (or icon) is desaturated with `SetDesaturated(true)`, and the strip drops to alpha 0.35.
  - Hover (`OnEnter`/`OnLeave` on the tile Button only): the border goes to the accent at alpha 0.6, and an "Open" label fades in at the bottom right over `0.12s` (use `addon.OptionsWidgets_StartTween` if present, otherwise just show it).
  - Click: `f.OpenModule(Dashboard_BrandModule(key), key)`, or `f.ShowIntegrations()` for Integrations.
- [ ] **Step 3: News strip (100px).**
  - Use the current feed (`NewsLogic.CurrentFeed()`).
  - The left two thirds is `Showcase.MakeStory(..., feed[1], "strip")`, with the release story allowed.
  - The right third is a panel headed "Latest news". It lists the titles of `feed[2]` and `feed[3]`, each a Button that runs its action, then "All news" (`f.ShowNews`).
  - Fewer than two stories: hide the right panel and let the strip take the full width.
  - Empty feed: hide the whole row.
- [ ] **Step 4: Credits footer (one line, 28px).**
  - On the left, `DASH_WELCOME_MADE_WITH` as a Button whose `OnEnter` shows a `GameTooltip` with three headed sections from `addon.DashboardWelcomeCredits`. Supporters are class-coloured through `RAID_CLASS_COLORS[classFile]`.
  - On the right, small text buttons:
    - **Module guide** runs `f.ShowModuleGuide`;
    - **Discord**, **GitHub**, **Ko-fi** and **Patreon** call `ShowURLCopyBox`, using the URLs at `DashboardUtil.lua:594-597`. Move those to `addon.DashboardCommunityLinks` and use them from both places.
  - No community footer panel on Welcome.
- [ ] **Step 5: Layout and fit.**
  - Vertical rhythm is a 14px gap. The content height at a 1280×720 frame must fit the view without scrolling: 180 + 20 + 290 + 100 + 28 + 4 gaps × 14 = 674.
  - Keep the scroll frame for large text scales.
  - `_layoutWelcomeContent` relays out everything at the current width and is called on `OnShow`, `OnSizeChanged` and resize, as in Task 4.
- [ ] **Step 6: Wire it in.**
  - Change the Init call in `DashboardHomeWelcome.lua`.
  - Set `guideEmbeddedInWelcome = false`.
  - Remove the `DashboardModuleGuide_LayoutEmbedded` assignment at `DashboardModuleGuide.lua:539-551` if nothing else calls it (grep first).
  - Run the compile check on every touched file.
- [ ] **Step 7: Run all suites.** All five fengari suites plus `test_build_news.py` must pass.
- [ ] **Step 8: Commit.**
  - `git add options/dashboard locales/horizon HorizonSuite.toc`
  - `git commit -m "feat(dashboard): turn the welcome page into a showcase"`, with the trailer.

---

### Task 7: Remove the old renderer and open PR B

**Files:**
- Delete: `options/dashboard/DashboardWelcomeView.lua`
- Modify:
  - `HorizonSuite.toc`: remove its line;
  - `DashboardFrame.lua` comment at line 4, if it names the file;
  - `locales/horizon/*.lua`: remove retired `DASH_WELCOME_*` keys.

- [ ] **Step 1: Check what still references the old renderer.**
  - Run `grep -rn "DashboardWelcomeView\|DashboardWelcomeView_Init\|welcome_action_card\|module_guide_section\|news_featured" --include=*.lua --include=*.toc .`
  - The only remaining hit allowed is the file itself.
- [ ] **Step 2: Delete the file and its TOC line.**
- [ ] **Step 3: Remove retired keys.** For each `DASH_WELCOME_*` key in the fact list that `grep -rn '"KEY"' --include=*.lua .` finds only in locale files, delete it from all seven locales. Keep:
  - `TAB`, `HEAD_SUB`, `COMMUNITY_HEADING` (the community footer still uses it);
  - every new key;
  - any key the credits fallback in Task 6 kept.
- [ ] **Step 4: Run the checks.**
  - All five fengari suites, `test_build_news.py`, and `python3 tools/build_news.py --check`.
  - `node tools/locale_audit.js`, if it runs without network, to confirm no locale references a missing key.
- [ ] **Step 5: Commit.**
  - `git add -A options/dashboard HorizonSuite.toc locales/horizon`
  - `git commit -m "refactor(dashboard): remove the old welcome and news renderer"`, with the trailer.
- [ ] **Step 6: Push and open PR B.**
  - Push `feature/dashboard-welcome-showcase` and open PR B with base `feature/dashboard-news-feed` and `/pr`.
  - Evidence: the art and a description of the layout.
  - Checklist in game:
    - Welcome fits at 1280×720 with default text;
    - each tile opens its page;
    - an off module's tile is desaturated with an Off chip;
    - hovering a tile doesn't block its click;
    - the credits tooltip lists supporters in class colours;
    - the Module guide link opens the guide;
    - What's new opens patch notes.
