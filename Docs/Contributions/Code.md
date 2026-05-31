# Internal `Naming Scheme`

It is in everyone's best interest to prioritise reviewers just as much as yourself.
 > “Indeed, the ratio of time spent reading versus writing is well over 10 to 1. We are constantly reading old code as part of the effort to write new code. ...[Therefore,] making it easy to read makes it easier to write.”
- Robert C. Martin - [Clean Code | A Handbook of Agile Software Craftsmanship](https://www.lkhibra.ma/books/clean-code.pdf)

## Files, Functions, Variables, etc.

Use any `alphabetical character` [a-z],[A-Z] in `Proper Case`.

Names should be intentional, eloquent, and consistent.
**Use the King's English whenever applicable.**
Variables should be nouns, Functions should be verbs, and so on.

**Notable Exceptions**:
|Location|Difference|Example|Reasoning|
|----------:|------------|-----------|-------------|
|WoW API|American English|SetColorTexture|WoW uses American English for their internal properties.|
|External Hooks|Case/Characters|GITHUB_TOKEN|External Hooks may follow a multitude of naming schemes.|
|Folders with `.`|Case/Characters|run-activity-post.sh|Crystilac does not hold these to the same standard, developer preference.|
|core/migrations|Case/Characters|20260221_combat_visibility.lua|Prioritise referential capacity (`YYYYMMDD_brief_description_of_change`).|

These examples are not a comprehensive list for their respective locations.
Everywhere else, please mention if you feel the pattern is not followed appropriately.

**General Example**:
This is meant as a rough guideline, not an ultimate authority.

|Example|Reasoning|
|-|-|
|<span style="color:#0BDA51;">HorizonContribution</span>|Words clearly distinguishable through Proper Case|
|<span style="color:#EE4B2B;">Horizon`_`Contribution</span>|No special characters are allowed|
|<span style="color:#EE4B2B;">H`0`rizonContribution</span>|No numeric characters are allowed|
|<span style="color:#EE4B2B;">Horizon`c`ontribution</span>|Words not clearly distinguishable through Proper Case|
|<span style="color:#EE4B2B;">`h`orizonContribution</span>|First word may be missed at a glance without Proper Case|
|<span style="color:#EE4B2B;">`h`orizon`c`ontribution</span>|Words not clearly distinguishable through Proper Case|

<br>

**Additional Examples:**
These are meant as a rough guideline, not an ultimate authority.
#### `Table of Horizon's tooltip default settings`

|Example|Reasoning
|-|-|
|<span style="color:#0BD151;">TooltipDefaults</span> `= {}`|Is direct as possible without referencing objects that may change (such as names)|
|<span style="color:#EE4B2B;">TooltipDs</span> `= {}`|`D` is too vague when referencing a table of values
|<span style="color:#EE4B2B;">TipDefaults</span> `= {}`|`Tip` is too vague when referencing a table of values|
|<span style="color:#EE4B2B;">TTDs</span> `= {}`|`TTDs` is incredibly vague|

<br>

#### `Function that animates the accordion collapse style`

|Example|Reasoning|
|-|-|
|<span style="color:#0BD151;">AnimateAccordionCollapse</span>`()`|Begins with a verb that describes the noun it will apply itself to|
|<span style="color:#EE4B2B;">AnimateAccordion</span> `()`|`Accordion` without additional context is too vague|
|<span style="color:#EE4B2B;">AnimatedAccordion</span> `()`| Begins with an adjective and is too vague without additional context|
|<span style="color:#EE4B2B;">AccordionAnimation</span> `()`|Begins with a noun and is too vague without additional context|
|<span style="color:#EE4B2B;">AccordionCollapse</span> `()`|Begins with a noun and is too vague without additional context|
|<span style="color:#0BD151;">CollapseAccordionStyle</span>`()`|Begins with a verb that describes the noun it will apply itself to|
|<span style="color:#EE4B2B;">CollapseAccordion</span> `()`|`Accordion` without additional context is too vague|
|<span style="color:#EE4B2B;">CollapsedStyle</span> `()`|Begins with an adjective and is too vague without additional context|
|<span style="color:#EE4B2B;">StyleCollapse</span> `()`|Too vague without additonal context|
|<span style="color:#EE4B2B;">AccordionStyle</span> `()`|Too vague without additional context|

<br>

#### `Variable that references the player's current coordinates`

|Example|Reasoning|
|-|-|
|<span style="color:#0BD151;">PlayerCoords</span>|Has a widely understood abbreviation and is direct as possible|
|<span style="color:#0BD151;">PlayerCoordinates</span>|Is direct as possible|
|<span style="color:#EE4B2B;">MapCoordinates</span>|`Map` without additional context is too vague|
|<span style="color:#EE4B2B;">MinimapXYZ</span>| Too vague without additional context|
|<span style="color:#EE4B2B;">MinimapPositioning</span>|Too vague with additional context|

<br>

#### `Variable that references a player's class`

|Example|Reasoning|
|-|-|
|<span style="color:#0BD151;">PlayerClass</span> `= GetPlayerClass()`|Is direct as possible|
|<span style="color:#EE4B2B;">PlayerCurrentClass</span> `= GetPlayerClass()`|Likely to reference self, vague without additional context|
|<span style="color:#EE4B2B;">CurrentClass</span> `= GetPlayerClass()`|Likely to reference self, vague without additional context|
|<span style="color:#EE4B2B;">CharacterClass</span> `= GetPlayerClass()`|Intended target is vague without additional context|
|<span style="color:#EE4B2B;">Class</span> `= GetPlayerClass()`|Too vague without additional context|
