# GitHub Pull Requests

All PRs should be directed to `main`. A PR is always required — direct pushes to
`main` are blocked — and PRs are squash-merged to keep history linear.

Review is optional: a director may self-merge their own PR, which is a clean
merge under the trunk ruleset. Request a reviewer whenever a change genuinely
warrants a second pair of eyes (anything risky, cross-module, or user-facing).

<br>

## Naming
Try to make the title brief but informative.

The **first** method is to name it *after the branch*, which would be in  `lower-kebab-case` and prefixed with the associated issue type.
The **second** method is to name it through *keywords* of the author's choosing. These may include, but are not restricted to, `type`, `label(s)`, or `'Intent' Summary`.

The following example is meant as a rough guideline, not an ultimate authority:
PR #325 was [FIX THE DAMN IMPROPER LOCALE CALLS](https://github.com/Tacit-Labs/Horizon-Suite/pull/325), from branch `chore/im-so-over-this`.
The PR author was upset at the frequency of the error and, despite multiple attempts to fix it, errors continued to return.

This title is acceptable as it is brief, informative, contains a `type`, and a `summary of the PR's 'Intent' section`. 

|Alternative Names|Reasoning|
|-----------:|:------------|
|<span style="color:#0BDA51;">Fix: Locale Key Call</span>|This is brief, informative, contains a `type`, and  `summary of the PR's 'Intent' section`.|
|<span style="color:#0BDA51;">Locale Reference Fixes</span>|This is brief, informative, contains a `type` in acceptable formatting, and contains a `summary of the PR's 'Intent' section`.|
|<span style="color:#EE4B2B;">chore/im-so-over-this</span>|This is brief and a direct copy of the branch name yet non-informative. The branch met its required naming but would not make a proper PR title.|
|<span style="color:#0BDA51;">chore/locale-key-fixes</span>|If the branch were named so, this would be acceptable as it is brief, informative, and a copy of the branch's name.|
|<span style="color:#0BDA51;">Chore/Locale Key Fixes</span>|If the branch were named so, this would be acceptable as it is brief, informative, and a copy of the branch's name in acceptable formatting.|

<br>

## Drafting
Try to be brief but informative.

Write in third-person as the `author`, avoiding first-person terminology when possible.
This includes, but is not limited to, `I`, `Me`, and `My/Mine`

The PR Template is listed in **`.github/PULL_REQUEST_TEMPLATE`**. Its sections and comments are listed below as well.
Its comments, indicated by **`<!-- -->`**, are for author recall only and do not appear in the final PR. They may be erased if desired.

<br>

### `# Intent`
**A very concise description of the overarching purpose.**

For example, `Closes #X`, `Update Internal Documents`, `Adjust variable names for consistency`, etc.
If examples or more than one sentence are here, it likely contains information that can be relegated to another section.

### `## Reviewer Notes`
**A general overview that anyone without a deep knowledge of the code base can understand.**

Effectively, summarise the PR's changes without diving too deep into the underlying mechanisms of the codebase.

### `## Developer Notes`
**Specific rationale for all changes that those with a working knowledge of the code base can reference.**

This is not meant as a repetition of  `Reviewer Notes` in more technical terms, unless deemed absolutely necessary.
If applicable, this section should detail not only what the author *did* try, but what they *didn't* try or could not get working.

### `## Reviewer Checklist`
**Direct reviewer with specific steps beyond generic reviewer responsibilities (checking in-game, code integrity/validation, etc.).**

The checkboxes provided are meant to be very specific, to encourage both the author and reviewer to thoroughly think through the ramifications of the changes within.

### `## Resources` `<OPTIONAL>`
**List any sort of documentation, examples, or references (along with their purpose) that you feel may help when reviewing the changes within.**

Only appearing when deemed necessary, this section is left in a comment block as to not require its deletion in every PR.

### `It is expected that all PRs have already been self-reviewed, tested in-game, and free of noticeable errors (unless otherwise specified).`
Though left in a comment block, this statement is critical for **both author and reviewer**.
It is assumed that a PR has been reviewed, tested, and debugged. When checkboxes for these were placed prior, they were rarely checked off.

Due to the above reasoning, the `self-review`, `in-game test`, and `free of noticable errors` have been removed from the checklist.

<br>
<br>

### `When reviewing a PR, the checklist is not just for show.`
Check off the boxes that you have confirmed work. The checks appear for everyone.

On GitHub, each PR has a series of tasks, seen as a circle with a number of `current`/`max` tasks completed.
As a task is checked off, that number increments and that circle nears completion.

If you are unable to check off the entire list, state so in the PR comments so another reviewer is able to pick up where you left off.
Checking off these task-lists allows both the team and the author to see how much progress has been made on testing the specifics of the changes within that PR.

<br>

### `CRITICAL REMINDER`
If any locale **KEYS and/or STRINGS** were changed, mention in the PR if  the changes were propagated to all horizon locales.
This can be done manually or through automation.

Horizon Suite does have a tool to automate this in `tools/restructure_locales.js` and can be triggered by entering `node tools/restructure_locales.js` in the terminal.
This tool, at time of writing documentation, does contain some errors or inconsistencies in relation to `locales/horizon/enUS.lua`.

See **`locales/Key Nomenclature.md`** for more information on locales.

<br>

---
