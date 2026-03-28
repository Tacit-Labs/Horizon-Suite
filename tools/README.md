# Horizon Suite — `tools/`

Node scripts for **localisation** maintenance. Run from the repo root (`HorizonSuite/`).

## Layout

| Path | Purpose |
|------|---------|
| `lib/` | Shared helpers (`parseLocalisationEnUS.js`, `localeHash.js`) |
| `locale-meta/` | Optional per-locale validation metadata (see `locale-meta/README.md`) |
| `archived/` | **Historical** one-off migrations — do not use in normal workflow |

## Everyday commands

| Script | Command | When |
|--------|---------|------|
| Sync locale files to `enUS` order | `node tools/restructure_locales.js` | Rewrites `enUS.lua` format (no per-key `-- Context:`; no blank lines between keys; pads spaces so `=` and values align in one column from the longest `L["KEY"]`), then regenerates other locales; strips assignments that duplicate enUS (comment + `NEEDS TRANSLATION` so runtime uses `__index` fallback) |
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

- `locale_audit.js --strict` — merge request pipeline (`.gitlab-ci.yml` → `locale-check`)
- `locale_audit_discord.js` — scheduled/manual Discord summary

## Orphan / consistency

- `find_orphan_l_keys.js` — reports `L["…"]` usages in Lua whose keys are not in `enUS` or `locale-key-mapping.json`

## See also

- [Localisation/CLAUDE.md](../Localisation/CLAUDE.md) — contributor workflow for strings
- [TRANSLATING.md](../TRANSLATING.md) — translators
- [archived/README.md](archived/README.md) — retired migration scripts
