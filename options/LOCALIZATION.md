# Horizon Suite — Localization

## Overview

Horizon Suite uses a fallback-based localization system. **LocaleBase.lua** is loaded for all clients and provides English strings. Locale-specific files override keys with translations; missing keys fall back to LocaleBase (or the key itself).

## Source of Truth

- **LocaleBase.lua** — Single source of truth for structure and English strings. Edit this file when adding or updating keys. Loaded for all clients.
- **enUS.lua** — Optional reference copy derived from LocaleBase (not loaded in-game). Use `build-enUS-from-LocaleBase.ps1` if you need it.

## Process for Updating Localization

### 1. Add or update a key

Edit **LocaleBase.lua** directly:

- Add the new line in the correct section (see File Structure below).
- Use aligned format: `L["key"]` padded to 115 chars, then ` = "value"`.
- Example: `L["New option"]` + spaces to column 115 + ` = "New option"`

### 2. Sync enUS (optional)

If you keep enUS as a reference file:

```powershell
cd options
.\build-enUS-from-LocaleBase.ps1
```

### 3. Update locale files (translations)

Run the audit to see which locales need the new key:

```powershell
cd options
.\locale-audit.ps1
```

Open `locale-audit.txt` — it lists missing keys per locale. Add the translated value to each locale file (esES, deDE, frFR, koKR, etc.) in the same section as LocaleBase. Untranslated keys will show English at runtime.

### 4. Add translations to locale files

Open each locale file (esES, deDE, frFR, etc.) and add the new key in the same section as LocaleBase. Use the key as the value if untranslated (it will fall back to English at runtime).

## Audit Script

Run the audit to compare locale files against LocaleBase:

```powershell
cd options
.\locale-audit.ps1
```

Output: `locale-audit.txt` — lists missing keys (will show English) and orphaned keys (in locale but not in LocaleBase) per locale. Run periodically to catch drift.

## Locale Files

| File      | Locale        | Loaded when `GetLocale()` returns |
|-----------|---------------|-----------------------------------|
| deDE.lua  | German        | deDE                              |
| esES.lua  | Spanish (EU)  | esES                              |
| frFR.lua  | French        | frFR                              |
| koKR.lua  | Korean        | koKR                              |
| ptBR.lua  | Portuguese (BR) | ptBR                            |
| ruRU.lua  | Russian       | ruRU                              |
| zhCN.lua  | Chinese (Simplified) | zhCN                        |

Each locale file uses `setmetatable({}, { __index = addon.L })` so it inherits from LocaleBase. Only override keys you translate. Use **LocaleBase.lua** as the structural template when adding keys to other locales.

## File Structure

- Group keys by OptionsData section (e.g. `-- OptionsData.lua Appearance`).
- Use consistent alignment: `L["key"]` padded to 115 chars before ` = `.
- Place new keys in the section that matches their usage in OptionsData.lua.
- See LocaleBase.lua for the canonical section order.

## Scripts

| Script | Purpose |
|--------|---------|
| `locale-audit.ps1` | Compare locale files against LocaleBase; output `locale-audit.txt` |
| `build-enUS-from-LocaleBase.ps1` | Build enUS reference from LocaleBase (optional) |

**Legacy (no longer used):** `build-enUS-from-esES.ps1`, `align-LocaleBase-from-enUS.ps1` — these assumed esES/enUS as source of truth.
