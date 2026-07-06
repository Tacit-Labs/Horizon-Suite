# In-House Trunk Migration — Runbook

One-time record of Horizon Suite's move from the `parked` regime (two-branch
`dev`/`main` with external collaborators) onto the org-standard **`trunk`**
regime (single `main`, in-house only). Mirrors the per-repo migration the nine
product repos followed under tacit-claude#367 (ratified 2026-07-05).

This file documents the **org-admin cutover** — steps that need org-level
GitHub permissions (custom properties, org rulesets, collaborator/team admin)
and cross-repo changes in `tacit-claude` / `tacit-wiki`. The **repo-file half**
(this PR) is already done: CODEOWNERS removed, `auto-assign-dev-reviewers.yml`
removed, `branch-janitor.yml` de-`dev`-ed, external contributors dropped from
`discord-user-map.json` and the docs, and the repo docs rewritten for trunk.

Run the cutover as an ordered sequence — ordering matters so no open work is
stranded.

---

## Target state

| Aspect | Before (`parked`) | After (`trunk`) |
|---|---|---|
| Branches | `feature → dev → main` | `feature → main` (no `dev`) |
| `main` merge | merge commit, 1 approval | squash, linear, **0 required approvals** |
| Protection | 2 repo-scoped rulesets (`16172044`, `16172050`) | org `protect-main-trunk` ruleset |
| Direct push to `main` | — | blocked (bypass mode `pull_request`) |
| Code owners | directors + 3 external write | none (CODEOWNERS deleted) |
| Collaborators | 3 external write + reviewer team | in-house directors only |
| Release | tag → BigWigsMods packager | **unchanged** (WoW addon → CurseForge/Wago) |
| Labels | `[Priority]`/`[Module]`/`[Upkeep]` | **unchanged** (documented exception) |

Note: `trunk` (branch protection) and the `tacit-consumer` topic (product
pipeline discovery) are independent. Horizon stays **without** the
`tacit-consumer` topic — it is a director-led addon, not part of the consumer
`/tacit-raise-issue` allowlist or the Android engineer pipeline. `tacit-stack`
stays unset (no WoW/Lua value exists; the property is optional).

---

## Cutover sequence

### 1. Land the repo-file changes (this PR)
Merge this PR first so `main` no longer advertises the `dev`/external-reviewer
model or a CODEOWNERS file that would conflict with the trunk ruleset.

### 2. Drain and retire `dev`
At migration time there were **11 open PRs, all based on `dev`** (7 in-house,
4 external: #343 SwiftMint; #347/#350/#351 ProgrammingSam).

1. Decide the fate of the 4 external PRs (retarget to `main`, keep on `dev` to
   triage, or close).
2. Retarget the in-house PRs you intend to keep from `dev` → `main`
   (`gh pr edit <n> --base main`), rebasing each onto `main`.
3. Promote any `dev`-only commits not yet in `main` (final `dev → main`), then
   delete `dev`. `dev` is protected by ruleset `16172050`, so deletion needs a
   director bypass or removing that ruleset first (step 4 covers its removal).

### 3. Remove external access
- Remove the external write collaborators (`nightsofglass`, `ProgrammingSam`,
  `SwiftMint`) from the repo.
- Delete the `horizon-reviewers` team (id `17588531`) — it now only contains
  Chris and has no purpose under `trunk` (review is optional, no code-owner
  gate).

### 4. Flip the regime `parked → trunk`
- Set the repo custom property: `tacit-regime = trunk`
  (`gh api -X PATCH repos/Tacit-Labs/Horizon-Suite/properties/values -f 'properties[][property_name]=tacit-regime' -f 'properties[][value]=trunk'`,
  or via the org custom-property UI).
- Retire Horizon's two repo-scoped rulesets once the org `protect-main-trunk`
  ruleset covers it:
  - `16172044` (main)
  - `16172050` (dev)
  `gh api -X DELETE repos/Tacit-Labs/Horizon-Suite/rulesets/16172044` (and `…/16172050`).
- Confirm `protect-main-trunk` (property-targeted at `tacit-regime = trunk`)
  now applies: squash-only, linear history, PR required, 0 approvals,
  direct-push blocked. `protect-tags-product` and `block-secret-files` also
  begin covering the repo automatically (both target `trunk`).

### 5. Register in governance (tacit-claude)
In `governance/org-config.json`:
- Move `Horizon-Suite` from `repo_regime.parked` → `repo_regime.trunk`.
- Remove the two `Horizon-Suite` entries from `delete_rulesets.keep`
  (`16172044`, `16172050`) — they are now deleted, not kept.
- Update the `_meta.parked` list (drop `Horizon-Suite`).
Run `governance/drift-check.sh` to confirm the live state matches the spec.

### 6. Update the workflow docs (tacit-claude + wiki)
- `.claude/rules/git-workflow.md` and `.claude/skills/tacit/git-workflow/SKILL.md`
  — move `Horizon-Suite` out of the `parked` row into `trunk`; drop the
  "one repo with code-owner review" / `base=dev` special-cases for it.
- `docs/repo-governance-final-design.md` §8 (the Horizon-Suite special track)
  and `docs/github-workflow-policy.md` (remove the `horizon-reviewers` bypass
  row) — Horizon is no longer an exception.
- `.claude/skills/tacit/agentic-engineer/SKILL.md` — Horizon no longer has a
  protected `dev`; base is `main`.
- tacit-wiki `decisions/trunk-based-development-product-repos.md` — add the
  Horizon record (last repo, brought in-house at the same time).

### 7. Verify
- A test PR into `main` merges via squash with no approval and no bypass prompt.
- A direct push to `main` is rejected.
- `dev` no longer exists; `git-workflow` docs no longer reference it for Horizon.
- `drift-check.sh` is clean.

---

## What deliberately does **not** change
- **Release pipeline** — `release.yml` (tag → BigWigsMods packager → CurseForge/
  Wago/Discord) is WoW-addon-specific and stays. No release-please.
- **Labels** — the legacy `[Priority]`/`[Module]`/`[Upkeep]` scheme stays; it is
  an explicitly documented exception in tacit-claude `docs/issue-types-and-labels.md`.
- **Discord workflows** — `activity-feed.yml` and `issuelog.yml` stay.
- **`claude-code-review.yml`** — stays (matches the org self-review pattern).
