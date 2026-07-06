# Repository

Horizon Suite uses a single-branch **trunk** model, in line with the wider
Tacit Labs setup. `main` is the trunk: all work branches off `main` and merges
back into `main` via pull request. There is no `dev` branch.

Direct pushes to `main` are blocked — every change lands through a PR, squash-
merged to keep history linear. `main` is always releasable; releases are cut
from `main` by pushing a version tag (see `.github/workflows/release.yml`),
on a roughly weekly cadence or whenever the accumulated changes justify one.

See the following for further information.
|GitHub|Corresponding File|
|---------|----|
|**`Issues`**|`Docs/Contributions/Repository/GitHubIssues.md`|
|**`Branches`**|`Docs/Contributions/Repository/GitHubBranches.md`|
|**`Pull Requests`**|`Docs/Contributions/Repository/GitHubPRs.md`|
