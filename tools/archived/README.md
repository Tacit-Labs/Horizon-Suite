# Archived locale tools

These scripts were used for **one-time migrations** (2026) from the old `locales/` layout to `Localisation/` with symbolic keys. They are **not** part of day-to-day development.

**Do not re-run** unless you are deliberately replaying history; `apply_locale_mapping.js` and `generate_symbolic_locales.js` expect removed paths or would no-op on current keys.

| File | Notes |
|------|--------|
| `apply_locale_mapping.js` | English phrase → symbolic key in consumer Lua |
| `generate_symbolic_locales.js` | Old `locales/` tree → `Localisation/` + mapping |
| `append_orphan_localisations.js` | Merged OptionsData-only strings into `enUS` + mapping |

If you ever need to execute one, run from repo root (paths resolve to the addon root):

```bash
node tools/archived/<script>.js
```

`ROOT` in each file is `path.resolve(__dirname, '..', '..')` so it still points at `HorizonSuite/` when the script lives here.
