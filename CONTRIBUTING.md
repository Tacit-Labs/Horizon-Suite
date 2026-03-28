# Contributing

## Translations

See **[TRANSLATING.md](TRANSLATING.md)** for how to translate `Localisation/<locale>.lua`, run the audit, and submit merge requests. Maintainer tooling is listed in **[tools/README.md](tools/README.md)**.

## Code

- Follow existing module patterns and `CLAUDE.md` at the repo root.
- For new user-visible strings, add them to **`Localisation/enUS.lua`** under the appropriate section header, then run `node tools/restructure_locales.js` before committing.
