---
name: release
description: >
  Cut a Horizon Suite release: gather every PR merged since the last tag,
  enrich it from its linked issue, translate the lot into the user-facing
  CHANGELOG voice, bump the TOC, and fire the BigWigs packager with a tag.
  Invoke with /release [version]. Refuses to invent entries and refuses to
  ship a changelog it could not source from a merged PR.
allowed-tools:
  - Read
  - Edit
  - Write
  - Bash(git *)
  - Bash(gh *)
  - Bash(grep *)
  - Bash(sed *)
  - Bash(wc *)
---

## Description

A release is one tag push. Everything after it is automated, and everything
before it is judgement — which is why the manual half is the half that goes
wrong.

`.github/workflows/release.yml` fires on a `v*` tag and runs
`BigWigsMods/packager`, which reads `.pkgmeta`, builds the `HorizonSuite` zip,
creates the GitHub release, and publishes to CurseForge and Wago.
`.release/build-release-payload.sh` then extracts this version's section from
`CHANGELOG.md` into a Discord embed. None of that needs a human.

What needs a human is deciding what the release *says*. `CHANGELOG.md` is
hand-written and read by players, not developers. The `[Unreleased]` block has
carried the comment *"Changelog entries are generated from merged main PRs
(enriched with referenced issues) at release time"* since long before this
skill existed, describing a process no tracked tooling implemented. This is
that tooling.

### The changelog is a player-facing document

Two facts about `CHANGELOG.md`, both established by reading all 2,011 lines of
it rather than by preference:

- **No entry has ever carried a PR number.** Zero `(#123)` references in the
  whole file. The GitHub release page links the commits; the changelog explains
  the change.
- **No entry has ever described CI, dependencies, or tooling.** Dependabot
  bumps, action pins, luacheck config and workflow edits are invisible to a
  player and are invisible here.

The filter that follows from those: **if someone running the addon could not
notice the change, it does not appear.** A release whose every PR is a chore
produces no changelog section, and that is a correct outcome, not an empty one.

### What the packager does with the file

Worth knowing because it shapes the heading, not the prose:

| Consumer | Reads |
|---|---|
| GitHub release body | The **whole** `CHANGELOG.md`, verbatim |
| CurseForge / Wago | The same whole file, via `manual-changelog` in `.pkgmeta` |
| Discord embed | Only the `## [VERSION]` section, regex-extracted, capped at 4096 chars |
| **In-game popup and dashboard** | **`core/PatchNotesData.lua` — a different file entirely** |

Only Discord section-extracts. That asymmetry means a malformed heading costs
you the Discord announcement and nothing else, so it fails quietly — check it.

**The fourth row is the one that gets missed.** The notes players actually see,
in the popup on first login after updating and under Patch Notes in the
dashboard, do not come from `CHANGELOG.md` at all. They come from a
hand-maintained Lua table keyed by version string, and nothing connects the two
files. Ship a release without adding its key and the popup fires — the TOC
version changed, so it believes there is something new — with nothing to render,
and the dashboard shows the previous release as the newest. No error, no warning.
This happened on 5.6.4 and is why Phase 7 now has a step for it.

## Usage

```
/release [version]
```

- **Input:** an optional target version (`5.6.4`, or `v5.6.4`). Omitted, the
  skill proposes one from the contents.
- **Output:** a merged version-bump PR, a pushed `v*` tag, and the run it
  triggered.
- **Side effects:** one branch, one PR, one merge, one tag push. The tag push
  publishes to CurseForge and Wago and announces on Discord. Everything before
  Phase 7 is read-only.
- **Stop conditions:** not on `main` or a dirty tree (Phase 1), no merged PRs
  since the last tag (Phase 2), or `cancel` at the gate (Phase 6).

Assumes `gh` is authenticated and the working copy is the Horizon Suite repo.

## Steps

### Phase 1 — Preflight

```bash
git rev-parse --abbrev-ref HEAD          # must be main
git status --porcelain                   # must be empty
git fetch origin --tags
git log --oneline origin/main..main      # must be empty
LAST=$(git describe --tags --abbrev=0 --match 'v*')
grep '^## Version:' HorizonSuite.toc
```

Stop on a dirty tree, a branch that is not `main`, or local commits not on
`origin/main`. The tag must land on exactly what was packaged.

The TOC version should equal `$LAST` with the `v` stripped. If it does not, a
previous release left the bump half-applied — say so and stop rather than
guessing which is right.

**Then list what is still open**, because the director may be waiting on
something:

```bash
gh pr list --repo Tacit-Labs/Horizon-Suite --json number,title,headRefName
```

Print them and ask once whether anything there belongs in this release. A
verified branch that never got merged is the single most common way a fix
misses its own release.

### Phase 2 — Gather the merged PRs

Squash merges put `(#N)` in the subject, so the commit range *is* the PR list.
This is exact; a date-windowed `gh pr list --search "merged:>=..."` is not, and
drifts whenever a PR is merged out of order.

```bash
git log --oneline "$LAST"..origin/main
git log --format='%s' "$LAST"..origin/main | grep -oE '\(#[0-9]+\)$' | tr -d '(#)'
```

For each number:

```bash
gh pr view <N> --repo Tacit-Labs/Horizon-Suite \
  --json number,title,body,labels,url,mergedAt
```

No PRs in the range: stop cleanly. There is nothing to release.

### Phase 3 — Enrich from the linked issue

The PR title is a commit subject written for reviewers. The issue is written
about the user's problem, so it is the better source for the entry — that is
what "enriched with referenced issues" means.

For each PR, pull issue references out of the body (`Closes #N`, `Fixes #N`,
`Resolves #N`), then:

```bash
gh issue view <N> --repo Tacit-Labs/Horizon-Suite \
  --json number,title,body,issueType,labels
```

Take from the issue: the **type** (`Feature` / `Improvement` / `Bug` — the org
issue field, not a label) and the **problem statement**, which usually already
describes the change in player terms.

A PR with no linked issue is normal. Fall back to its conventional-commit
prefix: `feat:` → Feature, `fix:` → Bug, `refactor:` → Improvement.

### Phase 4 — Filter to what a player can notice

Drop, without asking:

- `chore(deps)`, `chore(ci)`, anything authored by `dependabot[bot]`
- Workflow, action-pin, luacheck or `.github` changes
- Test-only and `Docs/`-only changes
- Refactors with no behavioural difference

Keep everything else. When a change is genuinely borderline — a performance fix
with no visible symptom, say — keep it and let the director strike it at the
gate. Over-reporting is recoverable in one edit; a silently dropped fix is
discovered by a player.

State the drops explicitly in Phase 6 rather than silently shrinking the list.

### Phase 5 — Write it in the file's voice

Sections, in this order, omitting any that would be empty:

```markdown
### ✨ New Features
### 🔧 Improvements
### 🐛 Fixes
```

Two bullet shapes, both taken from the existing file:

```markdown
- **(Focus)** Collapsed categories no longer leave a gap when headers are off.
- **(Augment) Skinned personal loot window** — When Auto Loot is off, the loot
  window stays usable and matches the Compact / Framed / Accent toast chrome.
```

The first is the fix shape: module tag, then the restored behaviour in one
sentence. The second is the feature and improvement shape: module tag plus a
named thing, an em dash, then what it does.

Rules, all of them load-bearing:

- **Module tag** from the PR's `[Module] *` label or the commit scope, in
  parentheses and bold: `(Focus)`, `(Augment)`, `(Vista)`, `(Presence)`,
  `(Insight)`, `(Essence)`, `(Core)`.
- **No PR or issue numbers.** Not one appears in the file today.
- **Outcome, not mechanism.** No file names, no function names, no API names.
  "Clicking a tracked achievement opens the achievement journal again", never
  "fixed the Midnight API call in FocusInteractions".
- **Present tense, describing the fixed world.** "no longer leaves a gap", not
  "fixed a bug where it left a gap".
- **UK English**, per the org writing-style rule: *colour*, *organise*,
  *behaviour*.
- **One sentence** unless the change genuinely needs two.

Then propose the version, unless the director passed one:

- Any `✨ New Features` entry → bump the minor (`5.6.3` → `5.7.0`)
- Otherwise → bump the patch (`5.6.3` → `5.6.4`)

**Cross-check `isNew` markers before settling on the number.** Options carrying
`isNew = "X.Y.Z"` name the version that introduced them, and the "(New!)" badge
only clears against an exact string match:

```bash
grep -rn 'isNew = "' options/ | grep -v "$(git describe --tags --abbrev=0 --match 'v*' | tr -d v)"
```

Any marker naming an unreleased version must equal the version being cut. If
the numbers diverge, either change the marker or change the release number, but
do not ship them mismatched — the badge silently never clears.

### Phase 6 — Confirm

```
Release:  5.6.4  (from 5.6.3, patch — no new features)
Tag:      v5.6.4
TOC:      5.6.3 → 5.6.4
PRs:      4 merged since v5.6.3, 2 user-facing, 2 dropped

Dropped (not player-visible):
  #411 chore(ci): keep action pins current
  #412 chore(deps): bump tsickert/discord-webhook

Changelog section:
## [5.6.4] – 2026-09-06

### 🐛 Fixes
- **(Focus)** ...

  ship        bump, PR, merge, tag, publish
  edit <what> revise and show me again
  dry-run     write the changelog and TOC locally, stop before the PR
  cancel      change nothing
>
```

`dry-run` exists because the tag push is the irreversible step. It leaves the
edits in the working tree for inspection and creates nothing.

### Phase 7 — Bump, PR, merge

`main` is protected under the `trunk` regime, so the bump goes through a PR
like anything else.

1. `git switch -c chore/release-<version>`
2. Edit `## Version:` in `HorizonSuite.toc`
3. Insert the new section in `CHANGELOG.md` directly below the `[Unreleased]`
   block's `---`, leaving `[Unreleased]` present and empty
4. **Add the matching key to `core/PatchNotesData.lua`.** Same content, different
   file and different shape — this is what players actually read:

   ```lua
   ["5.6.4"] = {
       date = "2026-09-06",
       {
           section = "Fixes",
           bullets = {
               "Focus: collapsed categories no longer leave a gap when section headers are turned off.",
           },
       },
   },
   ```

   Sections are `"New Features"`, `"Improvements"`, `"Fixes"` — plain strings, no
   emoji, unlike the changelog. Bullets take the `Module: rest` shape and the UI
   capitalises after the colon, so lowercase there is fine. Newest key goes first.
   The file is CRLF; preserve it.

5. Commit: `chore(release): 5.6.4`
6. Push, then open the PR with the `/pr` skill — never a hand-written body
7. Merge once CI is green, then `git checkout main && git pull`

**Gate before the tag — the TOC version must have a patch-notes key:**

```bash
# tr -d '\r' is not optional: .gitattributes checks every file out as CRLF, so
# awk's $3 carries a trailing carriage return. macOS grep truncates its pattern
# at that CR and matches anyway; GNU grep on the CI runner does not. Without the
# strip this passes locally and fails only in CI.
V=$(grep -m1 '^## Version:' HorizonSuite.toc | tr -d '\r' | awk '{print $3}')
grep -q "\[\"$V\"\] = {" core/PatchNotesData.lua \
  && echo "OK: PATCH_NOTES has key $V" \
  || { echo "MISSING: no PATCH_NOTES key for $V — players will get an empty popup"; exit 1; }
```

`.github/workflows/release-preflight.yml` now enforces this on every PR and every
push to `main`, along with the matching `## [VERSION]` heading in `CHANGELOG.md`.
Run it locally anyway — knowing before you open the PR is cheaper than being told
by a red check, and the local run is the same grep.

Check the heading before moving on. Discord's extractor matches
`##\s*\[VERSION\]`, so the version inside the brackets must be exact:

```bash
grep -n "^## \[<version>\]" CHANGELOG.md
bash .release/build-release-payload.sh "v<version>" && \
  jq -r '.embeds[0].description' .release/discord-release-payload.json | head -20
```

That renders the Discord embed locally without posting it. If the description
falls back to "See the GitHub release page for full notes", the heading did not
match.

### Phase 8 — Tag, and watch it

Only once the bump is on `origin/main`:

```bash
git checkout main && git pull
git tag "v<version>"
git push origin "v<version>"
```

Then follow it:

```bash
gh run watch "$(gh run list --workflow='Package Addon' --limit 1 --json databaseId --jq '.[0].databaseId')"
gh release view "v<version>" --repo Tacit-Labs/Horizon-Suite --json url,assets \
  --jq '"\(.url)\n\([.assets[].name] | join(", "))"'
```

Report the release URL, the uploaded asset names, and that CurseForge, Wago and
Discord were driven by the same run. Do not claim CurseForge or Wago succeeded
without the run's own log saying so — those steps carry their own API keys and
fail independently of the packaging.

## Examples

```
$ /release

Branch: main, clean, up to date with origin. Last tag v5.6.3, TOC 5.6.3. ✓

9 PRs open. Anything here belong in this release?
  413 fix/completed-quests-zone-filter — fix(focus): keep completed quests visible
> yes, merge that one first

...

Release:  5.6.4  (from 5.6.3, patch — no new features)
PRs:      4 merged since v5.6.3, 2 user-facing, 2 dropped

Dropped (not player-visible):
  #411 chore(ci): keep action pins current
  #412 chore(deps): bump tsickert/discord-webhook from 5.3.0 to 7.0.0

Changelog section:
## [5.6.4] – 2026-09-06

### 🐛 Fixes
- **(Focus)** Collapsed categories no longer leave a gap when section headers
  are turned off.
- **(Focus)** Quests ready to turn in stay listed when Current Zone Only is on,
  including click-to-complete quests picked up in the zone you are standing in.

  ship / edit <what> / dry-run / cancel
> ship

✅ chore(release): 5.6.4 merged
✅ Tagged v5.6.4, pushed
✅ Package Addon run 1234567 succeeded
   https://github.com/Tacit-Labs/Horizon-Suite/releases/tag/v5.6.4
   HorizonSuite-5.6.4.zip
   CurseForge, Wago and Discord all driven by that run.
```

## Gotchas

- **The tag is the release.** Pushing it publishes to CurseForge and Wago and
  announces on Discord. There is no staging step and no undo that unsends a
  Discord post. `dry-run` is the rehearsal.

- **Never move a tag that has already been pushed.** The workflow is
  tag-push-triggered; force-updating a tag does not cleanly re-run it, and the
  packager will refuse a release that already exists. A bad release is fixed by
  cutting the next patch, not by rewriting the last one.

- **Tag `main` after the bump merges, never the branch.** Tagging before the
  merge packages the old `## Version:` string, and the zip's TOC then disagrees
  with its own release name. Nothing errors; players see the wrong version in
  their addon list.

- **The GitHub release body is the entire CHANGELOG.md.** The packager's
  `manual-changelog` takes the file wholesale — the v5.6.3 body is 103,638
  characters of complete history. Only Discord extracts one section. This is
  pre-existing and worth fixing one day; do not discover it mid-release and
  start reformatting the file.

- **`isNew = "X.Y.Z"` markers must match the shipped version exactly.** The
  "(New!)" badge compares strings, so a setting marked `5.6.4` in a release cut
  as `5.7.0` wears the badge forever and no error is raised. Check them in
  Phase 5, before the number is settled.

- **CI and dependency PRs never appear.** Not once in 2,011 lines. A release
  containing only chores gets a version bump with no changelog section, which
  is correct.

- **`CHANGELOG.md` is not what players read.** The in-game popup and the
  dashboard's Patch Notes page read `core/PatchNotesData.lua`, a separate
  hand-maintained table keyed by version string. Nothing links the two files and
  nothing validates them against each other, so a missing key produces an empty
  popup rather than an error — and the popup still fires, because it keys off the
  TOC version having changed. 5.6.4 shipped this way. Run the Phase 7 gate.

- **A missing patch-notes key cannot be fixed by re-tagging.** Once a player has
  seen the empty popup, `patchNotesLastViewedVersion` is set to that version and
  it never fires again for them. The content can be backfilled — the dashboard
  renders every key it finds, so a late addition shows up in the history — but
  the popup moment is gone for anyone who already updated. Which is the argument
  for the gate rather than a fast follow-up.

- **`.release/run-changelog.sh` is dead.** Nothing calls it, and its label
  matching (`\bfeature\b`, `\bimprovement\b`, `\bbug\b`) predates types becoming
  org issue fields, so it would classify nothing today. Do not resurrect it as a
  shortcut for Phase 4.

- **Squash subjects are the PR index, not the changelog.** They are written for
  reviewers and carry scopes, file names and conventional-commit prefixes. Every
  one gets rewritten in Phase 5; pasting them through is the failure this skill
  exists to prevent.

- **This skill is tracked in this repo, deliberately not org-wide.** `.gitignore`
  ignores `.claude/*` but un-ignores `.claude/skills/`, and `.pkgmeta` keeps
  `.claude` out of the addon zip. It stays Horizon-scoped rather than becoming a
  `tacit-wow` plugin because everything in it — the packager, the TOC, the
  patch-notes table — is specific to this addon. The reason it is tracked at all
  is that its predecessor lived in one director's Cursor config and was lost.
