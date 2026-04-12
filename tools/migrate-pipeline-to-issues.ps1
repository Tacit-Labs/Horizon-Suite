# Migrate Open Items from pipeline.md to GitHub Issues.
# Run from repo root. Requires gh CLI (https://cli.github.com/).
# Run the Setup Labels workflow first, or scripts/setup-labels.ps1, to create labels.
# Usage: .\migrate-pipeline-to-issues.ps1 [ -Execute ]
# Without -Execute, prints gh commands. With -Execute, runs them.

param([switch]$Execute)

$pipelinePath = Join-Path $PSScriptRoot "..\pipeline.md"
$content = if (Test-Path $pipelinePath) {
    Get-Content $pipelinePath -Raw
} else {
    $repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
    Push-Location $repoRoot
    try {
        $c = $null
        foreach ($ref in @("HEAD", "HEAD^", "HEAD~2")) {
            $c = git show "${ref}:pipeline.md" 2>$null | Out-String
            if ($c) { break }
        }
        $c
    } finally {
        Pop-Location
    }
}

if (-not $content) { Write-Error "Could not read pipeline.md"; exit 1 }

$openSection = $content -match '(?s)## Open Items\s*\n(.*?)\n---'
if (-not $openSection) { Write-Error "Could not find Open Items section"; exit 1 }

$openBlock = $Matches[1]
$lines = $openBlock -split "`n" | Where-Object { $_.Trim() -like '- ``*' }

$count = 0
foreach ($line in $lines) {
    if ($line -notmatch '- `(BUG|FEAT|IMPR|IDEA|MOD|DOC)` OPEN \d{4}-\d{2}-\d{2}') { continue }

    $tag = $Matches[1]

    # Extract priority
    $priority = "[Status] Logged"
    if ($line -match '\[P0\]') { $priority = "[Status] Logged" }
    elseif ($line -match '\[P1\]') { $priority = "[Status] Logged" }
    elseif ($line -match '\[P2\]') { $priority = "[Status] Logged" }

    # Extract module
    $module = $null
    if ($line -match '`\[Focus\]`') { $module = "[Module] Focus" }
    elseif ($line -match '`\[Presence\]`') { $module = "[Module] Presence" }
    elseif ($line -match '`\[Vista\]`') { $module = "[Module] Vista" }
    elseif ($line -match '`\[Cache\]`') { $module = "[Module] Cache" }
    elseif ($line -match '`\[Essence\]`') { $module = "[Module] Essence" }
    elseif ($line -match '`\[Insight\]`') { $module = "[Module] Insight" }
    elseif ($line -match '`\[Flow\]`') { $module = "[Module] Flow" }
    elseif ($line -match '`\[Axis\]`') { $module = "[Module] Axis" }

    # Extract title: strip tag, status, date, priority, module prefix
    $title = $line -replace '^\s*-\s*`(BUG|FEAT|IMPR|IDEA|MOD|DOC)` OPEN \d{4}-\d{2}-\d{2}\s*', ''
    $title = $title -replace '^\[P[012]\]\s*', ''
    $title = $title -replace '^`\[(Focus|Presence|Vista)\]`\s*', ''
    # Remove trailing plan links
    if ($title -match '\.\s') {
        $idx = $title.IndexOf('. ')
        if ($idx -gt 0 -and $title.Substring($idx) -match 'plan') {
            $title = $title.Substring(0, $idx + 1)
        }
    }
    $title = $title.Trim()
    if ($title.Length -gt 256) { $title = $title.Substring(0, 253) + "..." }

    # Map tag to GitHub label
    $typeLabel = switch ($tag) {
        "BUG" { "[Enhancement] Improvement" }
        "FEAT" { "[Enhancement] Feature" }
        "MOD" { "[Enhancement] Feature" }
        "IMPR" { "[Enhancement] Improvement" }
        "IDEA" { "[Enhancement] Feature" }
        "DOC" { "[Enhancement] Localization" }
        default { "[Enhancement] Feature" }
    }

    $labelArgs = @($typeLabel, $priority)
    if ($module) { $labelArgs += $module }
    $labelStr = ($labelArgs | ForEach-Object { "--label ""$_""" }) -join " "

    $safeTitle = $title -replace '"', '\"'
    $body = "Migrated from pipeline.md (GitHub Issues workflow)"
    $cmd = "gh issue create --title ""$safeTitle"" --body ""$body"" $labelStr"

    if ($Execute) {
        Write-Host "Creating: $title"
        Invoke-Expression $cmd
        if ($LASTEXITCODE -ne 0) { Write-Warning "Failed: $cmd" }
    } else {
        Write-Host $cmd
    }
    $count++
}

Write-Host ""
if ($Execute) {
    Write-Host "Created $count issues."
} else {
    Write-Host "Total: $count issues. Run with -Execute to create them, or copy the commands above."
}
