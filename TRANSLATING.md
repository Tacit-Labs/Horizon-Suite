# Translating Horizon Suite

Horizon Suite uses **symbolic keys** in `Localisation/*.lua` (e.g. `L["OPTIONS_FOCUS"] = "…"`). English is the source file `Localisation/enUS.lua`. Other languages override only the keys they translate; missing keys show **English** in-game automatically.

**Product and module names** (e.g. *Horizon Suite*, *Focus*, *Presence*, *Vista*, *Insight*, *Cache*, *Axis*) are **not** locale keys — they are fixed in `addon.BrandDisplay` in code. In full sentences you translate, **keep those proper nouns in English** so they match the UI.

## Finding work

1. Clone the repo and open `Localisation/<yourLocale>.lua` (e.g. `frFR.lua`).
2. Search for commented lines `-- L["…"]` — those are stubs with the English value (uncomment and translate the value).
3. Or run **`node tools/locale_audit.js --missing`** from the repo root to list keys missing for each locale.

## Editing

1. Uncomment a stub (or add a new line) and set the **value** (right-hand side) to your translation.
2. **Do not change** the key inside `L["…"]`.
3. Preserve **format tokens** exactly: `%s`, `%d`, `%%` must match the English string.
4. For long or quoted text, keep the same Lua string style as `enUS.lua` (`"…"` or `[=[ … ]=]`).

After editing, run:

```bash
node tools/restructure_locales.js
```

This keeps file order aligned with `enUS.lua` (run even if you only changed one locale).

## Validation metadata (optional)

Reviewers can record approval in `tools/locale-meta/<locale>.json` (not loaded by WoW):

```bash
node tools/locale_validate.js frFR OPTIONS_FOCUS
# or mark all non-validated keys that have a translation:
node tools/locale_validate.js frFR --all-unvalidated
```

## Submitting

Open a **merge request** on GitLab with your `Localisation/<locale>.lua` changes. Mention which keys you translated. Discord: project invite links are on the dashboard / README.

## Grep tips

```bash
# Stubs still needing translation (commented assignments)
rg '^-- L\[' Localisation/

# Find a key or section in the English source
rg "YOUR_KEY_PREFIX" Localisation/enUS.lua
```

See also [.claude/claude-md-archive/Localisation/CLAUDE.md](.claude/claude-md-archive/Localisation/CLAUDE.md) for the full developer workflow. (*Archived during rebuild; `.claude/` is gitignored — local copy only.*)
