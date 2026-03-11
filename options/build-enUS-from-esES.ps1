# Build enUS.lua (source of truth) from esES structure + LocaleBase English values.
# Then align LocaleBase.lua with enUS.
# Run from options/ directory.

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$optionsDir = $scriptDir
$esESPath = Join-Path $optionsDir "esES.lua"
$localeBasePath = Join-Path $optionsDir "LocaleBase.lua"
$enUSPath = Join-Path $optionsDir "enUS.lua"

if (-not (Test-Path $esESPath)) { Write-Error "esES.lua not found" }
if (-not (Test-Path $localeBasePath)) { Write-Error "LocaleBase.lua not found" }

# Build key -> English value from LocaleBase
$baseValues = @{}
$baseContent = Get-Content $localeBasePath -Raw -Encoding UTF8
$baseMatches = [regex]::Matches($baseContent, 'L\["([^"]+)"\]\s*=\s*"((?:[^"\\]|\\.)*)"')
foreach ($m in $baseMatches) {
    $baseValues[$m.Groups[1].Value] = $m.Groups[2].Value
}
Write-Host "Loaded $($baseValues.Count) keys from LocaleBase"

# Parse esES line by line
$esESLines = Get-Content $esESPath -Encoding UTF8
$enUSLines = @()

# enUS header
$enUSLines += "--[["
$enUSLines += "    Horizon Suite - enUS (Source of truth)"
$enUSLines += "    This file is intentionally not loaded in HorizonSuite.toc."
$enUSLines += "    Use as the canonical source for structure and English strings."
$enUSLines += "    LocaleBase.lua is aligned with this file for runtime loading."
$enUSLines += "]]"
$enUSLines += ""
$enUSLines += "local L = {}"
$enUSLines += ""

$lineNum = 0
foreach ($line in $esESLines) {
    $lineNum++
    if ($lineNum -le 9) { continue }

    # Keep comments and blank lines
    if ($line -match '^\s*$' -or $line -match '^\s*--') {
        $enUSLines += $line
        continue
    }

    # Match L["key"] = "value" - capture key and the part before =
    if ($line -match '^(\s*L\["([^"]+)"\])\s*=\s*".*"\s*$') {
        $key = $Matches[2]
        $lhs = $Matches[1]
        if ($baseValues.ContainsKey($key)) {
            $eng = $baseValues[$key]
            $padded = $lhs.PadRight(115)
            $enUSLines += "$padded = `"$eng`""
        }
        continue
    }

    # Fallback: keep line as-is (e.g. addon.L = setmetatable - shouldn't appear after line 9)
    $enUSLines += $line
}

# Write enUS
$enUSLines | Out-File $enUSPath -Encoding UTF8 -NoNewline
# Fix: Out-File adds trailing newline, ensure we have proper line endings
$content = $enUSLines -join "`r`n"
[System.IO.File]::WriteAllText($enUSPath, $content + "`r`n", [System.Text.UTF8Encoding]::new($false))
Write-Host "Created enUS.lua"

# Build LocaleBase from enUS (add addon header and setmetatable footer)
$localeBaseHeader = @"
--[[
    Horizon Suite - Locale Base (enUS)
    Loaded for all clients. Locale-specific files override with fallback to this.
    Aligned with enUS.lua (source of truth).
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = {}

"@

$localeBaseFooter = "`r`n`r`naddon.L = setmetatable(L, { __index = function(t, k) return k end })`r`n"

$enUSContent = Get-Content $enUSPath -Raw -Encoding UTF8
# Remove enUS header (--[[ ... ]] and local L = {})
$body = $enUSContent -replace '(?s)^--\[\[.*?\]\].*?local L = \{\}\s*\r?\n+', ''
$localeBaseContent = $localeBaseHeader + $body + $localeBaseFooter
[System.IO.File]::WriteAllText($localeBasePath, $localeBaseContent, [System.Text.UTF8Encoding]::new($false))
Write-Host "Aligned LocaleBase.lua with enUS"
Write-Host "Done."
