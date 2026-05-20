# VS-Code-Agentic-First-Developer-Environment — Windows Setup Script
# Run from an elevated PowerShell prompt for the Defender exclusion step.
# Usage: .\install\setup.ps1

param(
    [switch]$SkipDefenderFix,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Green  = { param($m) Write-Host $m -ForegroundColor Green }
$Yellow = { param($m) Write-Host $m -ForegroundColor Yellow }
$Red    = { param($m) Write-Host $m -ForegroundColor Red }

& $Green "=== VS Code Agentic-First Developer Environment Setup ==="
Write-Host ""

# ── 1. Locate Claude Code settings directory ──────────────────────────────────
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$ClaudeSettings = Join-Path $ClaudeDir "settings.json"
$ConfigSource   = Join-Path $PSScriptRoot "..\config\claude-settings.json"

if (-not (Test-Path $ClaudeDir)) {
    if (-not $DryRun) { New-Item -ItemType Directory -Path $ClaudeDir | Out-Null }
    & $Green "[+] Created $ClaudeDir"
}

# ── 2. Write ~/.claude/settings.json ──────────────────────────────────────────
$newSettings = Get-Content $ConfigSource -Raw | ConvertFrom-Json

if (Test-Path $ClaudeSettings) {
    $existing = Get-Content $ClaudeSettings -Raw | ConvertFrom-Json
    # Merge: new keys win, existing keys preserved if not overridden
    $newSettings.PSObject.Properties | ForEach-Object {
        $existing | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value -Force
    }
    $merged = $existing
    & $Yellow "[~] Merged with existing $ClaudeSettings"
} else {
    $merged = $newSettings
    & $Green "[+] Creating $ClaudeSettings"
}

if (-not $DryRun) {
    $merged | ConvertTo-Json -Depth 10 | Set-Content -Path $ClaudeSettings -Encoding UTF8
}

# ── 3. Patch VS Code User settings.json ───────────────────────────────────────
$VSCodeSettingsPath = Join-Path $env:APPDATA "Code\User\settings.json"
$VSCodeFragment     = Join-Path $PSScriptRoot "..\config\vscode-settings-fragment.json"

if (Test-Path $VSCodeSettingsPath) {
    $vscSettings = Get-Content $VSCodeSettingsPath -Raw | ConvertFrom-Json
    $fragment    = Get-Content $VSCodeFragment -Raw | ConvertFrom-Json

    $fragment.PSObject.Properties | Where-Object { $_.Name -notlike "_*" } | ForEach-Object {
        $vscSettings | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value -Force
    }

    if (-not $DryRun) {
        $vscSettings | ConvertTo-Json -Depth 10 | Set-Content -Path $VSCodeSettingsPath -Encoding UTF8
    }
    & $Green "[+] Patched VS Code settings"
} else {
    & $Yellow "[!] VS Code settings.json not found at $VSCodeSettingsPath — skipping."
}

# ── 4. Optional: Windows Defender exclusion for .node files in Temp ───────────
if (-not $SkipDefenderFix) {
    $TempPath = $env:TEMP
    Write-Host ""
    & $Yellow "[!] Windows Defender may block Claude Code's native modules (.node files) in:"
    & $Yellow "    $TempPath"
    Write-Host "    Adding exclusion requires admin privileges..."

    try {
        Add-MpPreference -ExclusionPath $TempPath -ErrorAction Stop
        & $Green "[+] Defender exclusion added for $TempPath"
    } catch {
        & $Red "[x] Could not add Defender exclusion (need admin). Run this script as Administrator,"
        & $Red "    or manually add an exclusion for: $TempPath"
        & $Yellow "    Windows Security > Virus & threat protection > Manage settings > Add exclusion > Folder"
    }
}

Write-Host ""
& $Green "=== Setup complete. Restart VS Code to apply all changes. ==="
Write-Host ""
Write-Host "What was configured:" -ForegroundColor Cyan
Write-Host "  ~/.claude/settings.json  -> agent=developer, permissions.defaultMode=auto"
Write-Host "  VS Code settings         -> claudeCode.initialPermissionMode=auto, preferredLocation=panel"
