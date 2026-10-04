---
name: update-card
description: >
  Build the shareable update card for a Horizon Suite change a player can see:
  one PNG with the module's brand header, the option row if there is one, and
  the before and after side by side. Run it whenever such a change merges, and
  before merging when the PR needs evidence. Invoke with /update-card [PR number].
allowed-tools:
  - Read
  - Bash(python3 tools/make_update_card.py *)
  - Bash(gh *)
  - Bash(git *)
---

## Description

Every merged change a player can see gets an update card. It's the image Chris
shares with players to show what changed, so it has to make sense to someone
who has never seen the diff, and it has to look the same every time, so
players recognise it.

`tools/make_update_card.py` draws it. The layout is fixed:

1. A strip in the module's colour, from `Docs/Branding/ColourSchema.md`.
2. `HORIZON SUITE · <MODULE>`, the version on the right and, when only one
   client can see the change, `FOREVER ONLY` or `RETAIL ONLY`.
3. The title, written for a player ("Hide the group finder eye", not
   "add showGroupFinderButton toggle"), and a subtitle saying where to find it.
4. The options row, with the empty middle cut out, when the change adds or
   uses an option.
5. Before and after side by side, labelled. A brand-new frame with no before
   gets a single "New" panel.
6. The repo link along the bottom.

The card is the user-facing side of the PR's `## Evidence` section. The
screenshots that prove the change to a reviewer are the same ones that show
it to a player, so build the card from them; don't take a second set.

## Usage

**When:** a PR is about to merge, or has just merged, and changes something
that shows up on screen: a frame, a tracker entry, an option, a toast. Skip it
for refactors, CI, docs and anything that only changes behaviour a player
can't see.

1. **Get the screenshots.** WoW only runs on the Windows PC, so Chris
   captures them. Ask for:
   - the before, taken on `main` (or the default setting)
   - the after, taken on the branch with the same character, place and
     tracked content, so the only difference is the change
   - the options row, if the change has an option. A full-width row is fine.
2. **Write the words.** Title: what the player gets, at most about 40
   characters. Subtitle: where to find it (`New option: Focus > Group Finder
   Button`) or when it happens (`Shown when you loot a mount`). Labels: say
   what state each side is in, for example `Before: eye shown (default)` and
   `After: Group Finder Button off`.
3. **Build it** into the session scratchpad, never into the repo:

   ```bash
   python3 tools/make_update_card.py --module Focus \
     --title "Hide the group finder eye" \
     --subtitle "New option: Focus > Group Finder Button" \
     --option option.png --before before.png --after after.png \
     --before-label "Before: eye shown (default)" \
     --after-label "After: Group Finder Button off" \
     --version 6.6.0 --out "$SCRATCH/update-card-<PR>.png"
   ```

   `--version` is the release the change ships in: the next minor after the
   TOC's `## Version` for a feature, the next patch for a fix.
4. **Look at it** with Read before sending it anywhere. Check that the squeezed
   option row still shows both the label and the control, and that the labels
   don't overlap the screenshots.
5. **Publish it:**
   - Upload it to the PR's evidence draft release (`gh release upload <tag>
     <file>`), creating one with `gh release create <tag> --draft` if the PR
     has none. Media never goes in git.
   - Add it to the PR: in `## Evidence` before merging, or as a PR comment
     (`![update card](<asset url>)`) when the PR has already merged.
   - Send it to Chris with SendUserFile so it's ready to share.

## Examples

Option added, PR #480:

```bash
python3 tools/make_update_card.py --module Focus \
  --title "Hide the group finder eye" \
  --subtitle "New option: Focus > Group Finder Button" \
  --option lfg-toggle-option.png --before lfg-before.png --after lfg-after.png \
  --before-label "Before: eye shown (default)" \
  --after-label "After: Group Finder Button off" \
  --version 6.6.0 --out update-card-480.png
```

A new frame that only Forever has, so there is no before:

```bash
python3 tools/make_update_card.py --module Vista --flavour Forever \
  --title "A minimap clock that fits Forever" \
  --subtitle "Shown under the minimap by default" \
  --after clock.png --version 6.7.0 --out update-card-512.png
```

A fix with no option:

```bash
python3 tools/make_update_card.py --module Insight \
  --title "Quest levels use the server's difficulty colours" \
  --before old.png --after new.png --version 6.3.1 --out update-card-466.png
```

## Gotchas

- **Same conditions on both sides.** A before in Dornogal and an after in
  Stormwind shows two differences, and players will look for the wrong one.
  Same character, same place, same tracked quests.
- **Crop the option row tightly at the top and bottom.** The script removes the
  empty middle, but it can't tell a sliver of the row above from part of this
  row. Pass `--no-squeeze` if the squeeze cuts into the label.
- **Screenshots wider than 520px are scaled down.** Crop to the part that
  changed rather than sending a full 4K frame, or the tracker text gets too
  small to read.
- **The title is player-facing.** No setting keys, file names or PR jargon.
  Treat it like a patch-note line.
- **Module colours live in `Docs/Branding/ColourSchema.md`.** The script keeps
  its own copy in `MODULE_COLOURS`. When a module is added or recoloured,
  update both.
- **Fonts:** Arial is used on macOS and Windows, and DejaVu Sans on Linux. If
  none of them is present, Pillow falls back to its default bitmap font, which
  looks wrong. Install one rather than shipping that card.
