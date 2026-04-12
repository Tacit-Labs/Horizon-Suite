# Horizon Suite — `tools/`

Scripts for **localisation** maintenance and project administration. Run from the repo root (`HorizonSuite/`).

## Layout

| Path | Purpose |
|------|---------|
| `lib/` | Shared helpers (`parseLocalisationEnUS.js`, `localeHash.js`) |
| `locale-meta/` | Optional per-locale validation metadata (see `locale-meta/README.md`) |
| `archived/` | **Historical** one-off migrations — do not use in normal workflow |
| `color-palette-review.html` | Local HTML preview of the Focus colour palette for design review |
| `gitlab_issue_dry_run.js` | Preview GitLab -> GitHub issue drafts without creating anything |
| `gitlab-label-catalog.json` | GitLab-parity label catalog for GitHub (generated/updated by `gitlab_issue_dry_run.js`) |
| `migrate-pipeline-to-issues.ps1` | Bulk-create GitHub Issues from `pipeline.md` Open Items (`gh` CLI) |
| `setup-labels.ps1` | Create/update GitHub issue labels via `gh` CLI (reads `gitlab-label-catalog.json`) |

## Everyday commands

| Script | Command | When |
|--------|---------|------|
| GitLab issue migration preview | `node tools/gitlab_issue_dry_run.js` | Before importing GitLab issues into GitHub; writes `tools/gitlab-issues-dry-run.json` and refreshes `tools/gitlab-label-catalog.json` |
| Sync locale files to `enUS` order | `node tools/restructure_locales.js` | Rewrites `enUS.lua` format (no per-key `-- Context:`; no blank lines between keys; pads spaces so `=` and values align in one column from the longest `L["KEY"]`), then regenerates other locales; strips assignments that duplicate enUS (commented-out `-- L["KEY"] = …` so runtime uses `__index` fallback) |
| Coverage check | `node tools/locale_audit.js --strict` | Before merge requests (same as CI `locale-check`); strict = every key has a row; coverage counts only strings that differ from enUS |
| Optional key metadata | `node tools/locale_validate.js <locale> <KEY>` or `… --all-unvalidated` | Reviewer workflow |

## Maintainer-only (key renames)

| Script | Purpose |
|--------|---------|
| `apply_locale_key_rename.js` | Apply `locale-key-rename.json` and merge `semantic_collision_rename.json`; updates Lua + `locale-key-mapping.json` |
| `apply_semantic_collision_rename.js` | Apply only `semantic_collision_rename.json` |
| `generate_locale_key_rename.js` | Regenerate a **proposal** into `locale-key-rename.json` — **review before** `apply_*` |

After any bulk rename: `restructure_locales.js`, then `locale_audit.js --strict`.

**Data files**

- `locale-key-mapping.json` — phrase → key (legacy tooling / orphan checks)
- `locale-key-rename.json` — bulk `oldKey` → `newKey`; often `{}` after a migration to avoid accidental re-compression
- `semantic_collision_rename.json` — readable names for collision suffixes (`_2`, etc.)

## CI / automation

- `locale_audit.js --strict` — run before opening a pull request; strict = every key has a row
- `locale_audit_discord.js` — scheduled/manual Discord summary

## Orphan / consistency

- `find_orphan_l_keys.js` — reports `L["…"]` usages in Lua whose keys are not in `enUS` or `locale-key-mapping.json`

## See also

- [.claude/claude-md-archive/Localisation/CLAUDE.md](../.claude/claude-md-archive/Localisation/CLAUDE.md) — contributor workflow for strings (*archived during rebuild; gitignored*)
- [TRANSLATING.md](../TRANSLATING.md) — translators
- [archived/README.md](archived/README.md) — retired migration scripts
