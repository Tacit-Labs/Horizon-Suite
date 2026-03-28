# Locale metadata (optional)

JSON sidecar files `tools/locale-meta/<locale>.json` track review state per symbolic key:

- `status`: `unvalidated` | `validated` | `needs_review`
- `source_hash`: djb2 hex (6 chars) of the English string in `Localisation/enUS.lua` at validation time
- `translator`, `date`

WoW does **not** load these files. Update them with `node tools/locale_validate.js`.

If this folder is empty, `locale_audit.js` still reports coverage from the `.lua` files only.
