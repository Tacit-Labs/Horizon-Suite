# Translating for Horizon Suite
## [Official WoW Locales](blizzardlocales.md)
Do not edit anything within the `localisation/blizzard` folder.
<br>

---
## [Horizon Suite](localisation/horizon/)
Do not edit anything directly within the `localisation/horizon` folder if you intend to submit on Discord.

---
To start a **`new`** translation, copy the `enUS.lua` file and rename it to the locale that corresponds to the language you are translating to.
#### All Locale Names
German: **deDE.lua**
English:  **enUS.lua**
Spanish: **esES.lua**
Spanish: **esMX.lua**
French: **frFR.lua**
Italian: **itIT.lua**
Korean: **koKR.lua**
Portuguese: **ptBR.lua**
Russian: **ruRU.lua**
Chinese: **zhCN.lua**
Taiwanese: **zhTW.lua**

To **`continue`** an existing translation, copy the respective `locale file` from [GitHub](https://github.com/Tacit-Labs/Horizon-Suite/tree/main/localisation/horizon) and edit only your local copy.
In doing so, pay strict attention to the structure of the files. Do not edit the first nine lines of the file.

Every key shares the same format. It is **crucial** that the coding syntax remains the same.
```
L["DEFINED_TERM"]                                                = "Translated into the respective language, English by default."
```
Leave the code blocks alone and only edit the definition, as shown below in bold.
`L["DEFINED_TERM"]                                                = "`**Translated into the respective language, English by default.**`"`

Format tokens (`%%`, `[==[`, `%d`, etc) and proper nouns for names or brands (`Horizon Suite`, `CurseForge`, etc) are not to be translated.
### Submission
**Discord**: upload in [#localisation-submission](https://discord.com/channels/1471477531805749412/1483571479475126534).
Please indicate which sections or lines were translated if not 100% translated at time of submission.

**GitHub**: open a [pull request](https://github.com/Tacit-Labs/Horizon-Suite/pulls).
Please mention confidence on translation and if `node tools/restructure_locales.js` was run prior to a PR.