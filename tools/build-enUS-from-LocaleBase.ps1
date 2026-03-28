# Build enUS.lua (reference) from LocaleBase.lua (source of truth).
# enUS is not loaded in-game; use as a reference copy.
# Run from repo root or any cwd; paths resolve from this script (tools/).

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$addonRoot = Split-Path $scriptDir -Parent
$localeBasePath = Join-Path $addonRoot "options\LocaleBase.lua"
$enUSPath = Join-Path $addonRoot "options\enUS.lua"

if (-not (Test-Path $localeBasePath)) { Write-Error "LocaleBase.lua not found" }

$baseContent = Get-Content $localeBasePath -Raw -Encoding UTF8

# Extract body: between "local L = {}" and "addon.L = setmetatable"
$body = $baseContent -replace '(?s)^.*?local L = \{\}\s*\r?\n', ''
$body = $body -replace '\r?\n\s*addon\.L = setmetatable.*$', ''

$enUSHeader = @"
--[[
    Horizon Suite - enUS (Reference)
    Derived from LocaleBase.lua (source of truth).
    This file is intentionally not loaded in HorizonSuite.toc.
]]

local L = {}

"@

$enUSContent = $enUSHeader + $body.TrimEnd() + "`r`n"
[System.IO.File]::WriteAllText($enUSPath, $enUSContent, [System.Text.UTF8Encoding]::new($false))
Write-Host "Created enUS.lua from LocaleBase.lua"
