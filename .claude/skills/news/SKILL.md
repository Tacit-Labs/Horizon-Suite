---
name: news
description: >
  Draft a Horizon Suite dashboard News story: gather sourced facts from merged
  PRs, patch notes and the changelog, write news/<id>.md (title, summary, list,
  module tags, dates, buttons), make art for a featured story, rebuild the feed,
  run the news tests, and show the director the finished story before anything
  is committed. Invoke with /news <what the story is about>. Refuses to state
  anything it cannot source.
allowed-tools:
  - Read
  - Edit
  - Write
  - Bash(git *)
  - Bash(gh *)
  - Bash(grep *)
  - Bash(python3 *)
  - Bash(node *)
  - Bash(date *)
  - Bash(ls *)
  - Skill
---

## Description

News stories are Markdown files in `news/`, compiled by `tools/build_news.py`
into `options/dashboard/DashboardNewsFeed.lua`. Writing one by hand means
knowing the front matter, the art script and the checks. This skill does the
mechanical half and keeps the judgement half with the director: what the story
claims, and whether it ships.

The format is documented in `news/README.md`. Stories open inside the News page
in game, so the first paragraph is the summary (cards and the Welcome strip show
only that) and any detail follows as more paragraphs or a `- ` list.

## Usage

```
/news <what the story is about>
```

- **Input:** a short description of the change or announcement.
- **Output:** `news/<id>.md`, the rebuilt feed, optional art in `media/news/`,
  and, after approval, a commit and a PR.
- **Side effects:** files in the working tree. Nothing is committed or pushed
  until the director approves the rendered story.

### Steps

1. **Gather facts.** Read the merged PRs (`gh pr list --state merged`, `gh pr
   view`), `core/PatchNotesData.lua` and `CHANGELOG.md` for the change. Every
   claim in the story must trace to one of them. If it cannot be sourced, leave
   it out and say so.
2. **Draft the story.**
   - Title of 60 characters or fewer; the id is the kebab-case file name.
   - A one-paragraph summary first, then optional detail (more paragraphs, a
     short `- ` list, `**bold**` for the one thing to notice).
   - `modules:` with up to 3 known keys (`axis focus presence vista insight
     augment essence echo`) for the modules the story is about.
   - `layout: featured` for a headline feature, otherwise `card`.
   - `priority` (default 100; featured stories use 500) and dates: `from` is
     today, `until` defaults to 60 days later.
   - Up to two buttons (`button`/`action`, `button2`/`action2`).
3. **Art.** For a featured story run `python3 tools/make_welcome_art.py story <id>`
   and set `image:` to the file it writes in `media/news/`.
4. **Check.** Run `python3 tools/build_news.py`, then `python3 tools/build_news.py
   --check`, `python3 tools/test_build_news.py` and
   `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_news_logic.js`.
5. **Show the director first.** Print the story as it will read in game: title,
   tag line, summary, body, buttons, dates. Wait for approval. Only then commit
   (`feat(news): <title>`) and open a PR through the `/pr` skill.

## Examples

```
$ /news Focus now keeps pinned quests visible across zones

Sources: PR #431 (merged), PatchNotesData 6.7.0 "Focus: pinned quests ..."

  Pinned quests stay put                       [Focus]  Today
  Pinned quests no longer drop off the tracker when you change zone.
  - Works in cities and dungeons.
  - Pin as many as the tracker has room for.
  [Open Focus]  [Module guide]
  from 2026-10-08, until 2026-12-07, card, priority 100

Checks: build ok, --check ok, 47 python tests, 54 logic checks.
Commit and open a PR into the current integration branch? (yes / edit / cancel)
```

## Gotchas

- **Never state anything you cannot source.** A news story is read as a
  promise. If no merged PR, patch note or changelog entry says it, it does not
  go in. Ask the director rather than guess.
- **English only.** Stories are not translated; the locale files do not carry
  story text.
- **Title is 60 characters or fewer.** The builder rejects longer titles.
- **`until` defaults to `from` plus 60 days.** Leave it out only if the director
  wants the story to run until a version (`untilVersion`) instead; otherwise it
  would show forever.
- **`from` is required** and is the date shown on the story ("Today", "3 days
  ago"). Use today's date, not a future one.
- **A featured story needs art.** Run `python3 tools/make_welcome_art.py story
  <id>` first; the builder rejects a featured story with no `image`, and images
  must be power-of-two PNGs up to 1024 per side.
- **The body must start with a paragraph.** It becomes the summary. Lists and
  extra paragraphs only show once the story is opened.
- **Max 3 modules, known keys only, no duplicates.** A tag for a module the
  story does not touch is wrong; leave `modules` out instead.
- **Always run the builder and every check** (`build_news.py`, `--check`,
  `test_build_news.py`, `test_news_logic.js`). The generated feed is committed,
  and CI fails a story edited without a rebuild.
- **Do not hand-edit `DashboardNewsFeed.lua`.** It is generated.
- **Show the rendered story and wait for approval before committing or opening
  a PR.** Stories go straight to players' dashboards.
- **PR base is the current integration branch** (e.g. `feature/axis-settings-consolidation`,
  or the top of an open stack), never `main` directly unless the director says
  so. Find it with `git branch --show-current` and `gh pr list` before opening.
- **Working copies are CRLF** for most text files; use the Edit tool for existing
  files, and confirm `git show :<path> | grep -c $'\r'` is 0 after `git add`.
