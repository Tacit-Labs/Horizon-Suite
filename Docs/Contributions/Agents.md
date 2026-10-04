# Generative AI

Some of the developers utilise generative AI (primarily Claude) in their work.
Below is a list of everything that pertains particularly to the use of AI agents and their contributions to Horizon.

Will be updated by Crystilac as needed.

## Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): short description
```

Valid types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

The scope is optional but encouraged — use the module name in lowercase:
`feat(focus): add group objective tracking`

## Update cards

Every merged change a player can see on screen gets an update card: one PNG
with the module's colour, the option (if there is one), and the before and
after side by side. It goes in the PR and is what gets shared with players.

Run `/update-card` (`.claude/skills/update-card/SKILL.md`) as part of merging.
It builds the card with `tools/make_update_card.py` from the before and after
screenshots taken while testing. Refactors, CI and docs changes don't need one.
