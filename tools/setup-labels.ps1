# Create GitHub labels for Horizon Suite (GitLab parity names).
# Requires gh CLI (https://cli.github.com/).
# Alternatively, run the Setup Labels workflow from GitHub Actions tab.

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$catalogPath = Join-Path $here "gitlab-label-catalog.json"
$labels = Get-Content -Raw -Path $catalogPath | ConvertFrom-Json

foreach ($l in $labels) {
    $name = [string]$l.name
    $desc = [string]$l.description
    $color = [string]$l.color

    if (-not $name) { continue }
    if (-not $color) { $color = "ededed" }
    $color = $color.TrimStart('#')

    gh label create $name --description $desc --color $color 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Created: $name"
        continue
    }

    gh label edit $name --description $desc --color $color 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Updated: $name"
    } else {
        Write-Host "Failed: $name"
    }
}
