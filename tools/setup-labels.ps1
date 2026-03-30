# Create GitHub labels for Horizon Suite. Requires gh CLI (https://cli.github.com/).
# Alternatively, run the Setup Labels workflow from GitHub Actions tab.

$labels = @(
    @{ name = "bug"; desc = "Defect / broken behavior"; color = "d73a4a" },
    @{ name = "feature"; desc = "New capability"; color = "a2eeef" },
    @{ name = "improvement"; desc = "Enhancement to existing functionality"; color = "84b6eb" },
    @{ name = "idea"; desc = "Speculative / backlog"; color = "fef2c0" },
    @{ name = "Focus"; desc = "Focus tracker module"; color = "1d76db" },
    @{ name = "Presence"; desc = "Presence notification module"; color = "1d76db" },
    @{ name = "Core"; desc = "Core addon / options / general"; color = "1d76db" },
    @{ name = "Vista"; desc = "Vista / minimap module"; color = "1d76db" },
    @{ name = "Yield"; desc = "Yield / loot module"; color = "1d76db" },
    @{ name = "Pulse"; desc = "Pulse / combat module"; color = "1d76db" },
    @{ name = "Essence"; desc = "Essence / unit frames module"; color = "1d76db" },
    @{ name = "Insight"; desc = "Insight / tooltips module"; color = "1d76db" },
    @{ name = "Verse"; desc = "Verse / chat module"; color = "1d76db" },
    @{ name = "Priority 0"; desc = "Major / blocking"; color = "b60205" },
    @{ name = "Priority 1"; desc = "Minor / next"; color = "fbca04" },
    @{ name = "Priority 2"; desc = "Patch / low"; color = "0e8a16" }
)

foreach ($l in $labels) {
    gh label create $l.name --description $l.desc --color $l.color 2>$null
    if ($LASTEXITCODE -eq 0) { Write-Host "Created: $($l.name)" } else { Write-Host "Skipped (exists): $($l.name)" }
}
