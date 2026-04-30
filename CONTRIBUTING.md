# Contributing

## Translations

See **[TRANSLATING.md](TRANSLATING.md)** for how to translate `Localisation/<locale>.lua`, run the audit, and submit pull requests. Maintainer tooling is listed in **[tools/README.md](tools/README.md)**.

For new user-visible strings, add them to **`Localisation/enUS.lua`** under the appropriate section header, then run `node tools/restructure_locales.js` before committing.


## Code

- Follow existing module patterns.
