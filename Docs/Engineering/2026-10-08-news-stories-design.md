# News: easy stories, full stories, module tags

**Date:** 2026-10-08
**Status:** Draft for the director's review
**Branch:** `feature/dashboard-news-stories`, stacked on `fix/dashboard-reveal-animation` (PR #525)
**Builds on:** `2026-10-06-welcome-showcase-and-news-design.md`

## Why

News works, but it will go stale for three reasons:

- **Writing a story is a developer chore:** a Markdown file, an image made by a script, a rebuild and a PR.
- **Card stories only ever show their first paragraph,** and nothing opens the rest.
- **Stories say nothing about themselves:** no date, no module, and nothing different for a player who has that module turned off.

The director chose three improvements, covered in sections 1–3 below.

## 1. Writing a story: `/news`

A new project skill, `.claude/skills/news/SKILL.md`, invoked as `/news <what the story is about>`:

1. **Gather facts.** It reads the merged PRs, `core/PatchNotesData.lua` and `CHANGELOG.md` for the change the story describes. It **refuses to state anything it can't source**, the same rule as `/release`.
2. **Draft the story.**
   - A title of 60 characters or fewer.
   - A one-paragraph summary first, then optional detail.
   - Module tags.
   - A layout:
     - `featured` for a headline feature;
     - `card` otherwise.
   - A priority and dates:
     - `from` is today;
     - `until` defaults to 60 days later.
   - Up to two buttons.
3. **Art.** For a featured story it runs `python3 tools/make_welcome_art.py story <id>`.
4. **Check.** It runs `tools/build_news.py`, `--check`, and the news tests.
5. **Show the director first.** It shows the story as it will read in game, then commits and opens a PR into the current integration branch **only after the director approves**.

`/release` gets one extra closing step: after the tag is pushed, it suggests a `/news` story drafted from the release's headline features. It only suggests; nothing is created without the director's approval.

## 2. Richer stories that open

### Format additions (`news/*.md`, validated by `tools/build_news.py`)

| Addition | Meaning |
|---|---|
| `- item` lines | A bullet list. Consecutive lines form one list. |
| `**text**` | Bold. In game it shows in white, against the muted body text. |
| `button2`, `action2` | A second button. The same rules as `button` and `action`. |
| `modules: vista, focus` | Module tags. Known keys only, at most 3 (see §3). |
| `from` | Now required. It is the story's posted date. |

The builder emits each story's body as blocks:

- `{ kind = "p", text = ... }` for a paragraph;
- `{ kind = "list", items = { ... } }` for a bullet list;
- `summary`, the first paragraph, kept separately for cards and the Welcome strip.

For bold, the builder writes WoW colour codes itself. This happens after story text has had its `|` doubled, so a story still can't inject its own codes.

### Story view in game

- **Opening a story:** clicking a card, a featured story or the release story opens it **inside the News page**, keeping the dashboard header and sidebar.
- **Layout:** a "‹ All news" back link sits on top, then:
  - the image (featured only);
  - the title;
  - the tag and date line (see §3);
  - the full body, with paragraphs and lists;
  - the buttons.
- **Getting back:** "‹ All news", Escape, or clicking News in the sidebar returns to the list at the same scroll position.
- **Cards:** a card shows its summary and **Read more** when it has more than a summary.
- **Welcome strip:** its **Read more** opens News straight onto that story.

## 3. Module tags and dates

- **Tag line.** Under each title sits a line of up to 3 module chips, each showing the module's monoline icon and name in its colour. The chips use the shared `addon.DashboardModuleIcons` and the module colours. The posted date follows:
  - "Today" or "Yesterday";
  - "N days ago" up to 6 days;
  - then "12 Oct".

  `NewsLogic.PostedLabel(fromDate, today)` produces this text and is pure and tested.
- **Turned-off modules.** When a tagged module is off, its chip is grey and the line ends with "Vista is off · **Turn on**". **Turn on** opens the module hub, which owns enabling and the reload banner. The story isn't hidden or dimmed: the player may well want to read why to turn it on.
- **Release story.** It is tagged with the modules named in its two bullets (the "Module:" prefix in patch notes) and dated from the version's patch-notes date.

## 4. Testing

- **`tools/test_build_news.py`, new cases:**
  - bullet lists;
  - bold, including that a `|` inside bold stays escaped;
  - `button2`/`action2` pairing;
  - `modules`: unknown key, more than 3, duplicates;
  - `from` required;
  - the emitted block and summary structure.
- **`tools/test_news_logic.js`, new cases:**
  - every `PostedLabel` bucket, including a future date and year boundaries;
  - module tags derived for the release story.
- **In game (director):**
  - open and close a story by every route;
  - a disabled-module story shows "Turn on";
  - the Welcome strip opens the right story;
  - lists and bold read well;
  - check on Retail and Forever.

## 5. Delivery

One PR stacked on #525. It also updates the launch story to use tags, a list and a second button, so the page shows the new features from day one.

## Out of scope

- Fetching news from the web.
- Translating stories.
- An archive of expired stories (deferred: suggestion 5).
- A richer release story (deferred: suggestion 4).
