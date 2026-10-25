# powerbi-dev cross-AI installer
# Idempotent: safe to run repeatedly. -Uninstall removes all adapters.
# Usage:
#   powershell -ExecutionPolicy Bypass -File install.ps1
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Workspace "C:\path\repo"
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Uninstall
param(
    [string]$Workspace = "",
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"
$PluginRoot = $PSScriptRoot
$Home_ = $HOME
$Marker = "BEGIN powerbi-dev plugin"
$MarkerEnd = "END powerbi-dev plugin"
$Summary = @()

function Update-MarkerBlock {
    param([string]$FilePath, [string]$BlockContent, [switch]$Remove)
    $dir = Split-Path $FilePath -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $existing = ""
    if (Test-Path $FilePath) { $existing = Get-Content $FilePath -Raw }
    $pattern = "(?s)\r?\n*# $Marker.*?# $MarkerEnd\r?\n*"
    if ($Remove) {
        if ($existing -match $pattern) {
            Set-Content -Path $FilePath -Value ($existing -replace $pattern, "`r`n") -Encoding UTF8
            return "removed"
        }
        return "absent"
    }
    if ($existing -match [regex]::Escape("# $Marker")) {
        # replace existing block
        Set-Content -Path $FilePath -Value ($existing -replace $pattern, "`r`n$BlockContent`r`n") -Encoding UTF8
        return "updated"
    }
    Add-Content -Path $FilePath -Value "`r`n$BlockContent`r`n" -Encoding UTF8
    return "added"
}

$AdapterBlock = @"
# $Marker
# Power BI Developer plugin - agent instructions
# Source of truth: $PluginRoot
# When working on Power BI / DAX / Power Query / TMDL / PBIP tasks,
# read: $PluginRoot\AGENTS.md  and the matching skill under: $PluginRoot\skills\<skill-name>\SKILL.md
# $MarkerEnd
"@

# --- 1. Claude Code / Claude Desktop: copy skills to ~/.claude/skills ---
$ClaudeSkills = Join-Path $Home_ ".claude\skills"
if ($Uninstall) {
    if (Test-Path $ClaudeSkills) {
        Get-ChildItem (Join-Path $PluginRoot "skills") -Directory | ForEach-Object {
            $target = Join-Path $ClaudeSkills $_.Name
            if (Test-Path $target) { Remove-Item $target -Recurse -Force; $Summary += "claude: removed $($_.Name)" }
        }
    }
} else {
    New-Item -ItemType Directory -Path $ClaudeSkills -Force | Out-Null
    Get-ChildItem (Join-Path $PluginRoot "skills") -Directory | ForEach-Object {
        $target = Join-Path $ClaudeSkills $_.Name
        if (Test-Path $target) { Remove-Item $target -Recurse -Force }
        Copy-Item $_.FullName $target -Recurse -Force
        $Summary += "claude: installed $($_.Name)"
    }
}

# --- 2. Cursor: always-apply rule file ---
$CursorRule = Join-Path $Home_ ".cursor\rules\powerbi-dev.mdc"
if ($Uninstall) {
    if (Test-Path $CursorRule) { Remove-Item $CursorRule -Force; $Summary += "cursor: rule removed" }
} else {
    $mdc = @"
---
description: Power BI Developer standards (from powerbi-dev plugin)
alwaysApply: false
globs: ["**/*.tmdl", "**/*.pbip", "**/*.m", "**/*.dax", "**/*.pbir", "**/*.pbism"]
---

$($AdapterBlock -replace '(?m)^# ', '# ')
"@
    New-Item -ItemType Directory -Path (Split-Path $CursorRule -Parent) -Force | Out-Null
    Set-Content -Path $CursorRule -Value $mdc -Encoding UTF8
    $Summary += "cursor: rule installed"
}

# --- 3. Codex / Antigravity: ~/.codex/AGENTS.md ---
$CodexAgents = Join-Path $Home_ ".codex\AGENTS.md"
$result = Update-MarkerBlock -FilePath $CodexAgents -BlockContent $AdapterBlock -Remove:$Uninstall
$Summary += "codex: $result"

# --- 4. Gemini CLI: ~/.gemini/GEMINI.md ---
$GeminiMd = Join-Path $Home_ ".gemini\GEMINI.md"
$result = Update-MarkerBlock -FilePath $GeminiMd -BlockContent $AdapterBlock -Remove:$Uninstall
$Summary += "gemini: $result"

# --- 5. Cline global context: ~/.cline/rules ---
$ClineRule = Join-Path $Home_ ".cline\rules\powerbi-dev.md"
if ($Uninstall) {
    if (Test-Path $ClineRule) { Remove-Item $ClineRule -Force; $Summary += "cline: rule removed" }
} else {
    $dir = Split-Path $ClineRule -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -Path $ClineRule -Value $AdapterBlock -Encoding UTF8
    $Summary += "cline: rule installed"
}

# --- 6. Windsurf (Codeium): append to global memories/rules ---
$WindsurfRules = Join-Path $Home_ ".codeium\windsurf\memories\global_rules.md"
$result = Update-MarkerBlock -FilePath $WindsurfRules -BlockContent $AdapterBlock -Remove:$Uninstall
$Summary += "windsurf: $result"

# --- 7. Aider: conventions file + best-effort conf entry ---
$AiderConv = Join-Path $Home_ ".aider\powerbi-dev-conventions.md"
if ($Uninstall) {
    if (Test-Path $AiderConv) { Remove-Item $AiderConv -Force; $Summary += "aider: conventions removed" }
    $AiderConf = Join-Path $Home_ ".aider.conf.yml"
    if (Test-Path $AiderConf) {
        $conf = Get-Content $AiderConf -Raw
        if ($conf -match [regex]::Escape($AiderConv)) {
            $cleaned = ($conf -split "`r?`n" | Where-Object { $_ -notmatch [regex]::Escape($AiderConv) }) -join "`r`n"
            Set-Content -Path $AiderConf -Value $cleaned -Encoding UTF8
            $Summary += "aider: conf entry removed"
        }
    }
} else {
    $dir = Split-Path $AiderConv -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -Path $AiderConv -Value $AdapterBlock -Encoding UTF8
    $AiderConf = Join-Path $Home_ ".aider.conf.yml"
    if (Test-Path $AiderConf) {
        $conf = Get-Content $AiderConf -Raw
        if ($conf -notmatch [regex]::Escape($AiderConv)) {
            if ($conf -match "(?m)^\s*read\s*:") {
                Add-Content -Path $AiderConf -Value "  - $AiderConv" -Encoding UTF8
            } else {
                Add-Content -Path $AiderConf -Value "read:`r`n  - $AiderConv" -Encoding UTF8
            }
        }
        $Summary += "aider: conf wired"
    } else {
        Set-Content -Path $AiderConf -Value "read:`r`n  - $AiderConv" -Encoding UTF8
        $Summary += "aider: conf created"
    }
}

# --- 8. Optional workspace wiring (multi-agent) ---
if ($Workspace -ne "") {
    if (-not (Test-Path $Workspace)) { throw "Workspace path not found: $Workspace" }
    # AGENTS.md - native for Codex/Zed/Warp/OpenCode/Goose/Jules/Devin/Factory/Amp/Kilo
    $result = Update-MarkerBlock -FilePath (Join-Path $Workspace "AGENTS.md") -BlockContent $AdapterBlock -Remove:$Uninstall
    $Summary += "workspace AGENTS.md: $result"
    # Cursor
    $wsCursor = Join-Path $Workspace ".cursor\rules\powerbi-dev.mdc"
    if ($Uninstall) {
        if (Test-Path $wsCursor) { Remove-Item $wsCursor -Force; $Summary += "workspace cursor rule: removed" }
    } else {
        New-Item -ItemType Directory -Path (Split-Path $wsCursor -Parent) -Force | Out-Null
        Copy-Item $CursorRule $wsCursor -Force
        $Summary += "workspace cursor rule: installed"
    }
    # GitHub Copilot (VS Code / github.com)
    $wsCopilot = Join-Path $Workspace ".github\copilot-instructions.md"
    $result = Update-MarkerBlock -FilePath $wsCopilot -BlockContent $AdapterBlock -Remove:$Uninstall
    $Summary += "workspace copilot-instructions: $result"
    # Windsurf project rules
    $wsWindsurf = Join-Path $Workspace ".windsurf\rules\powerbi-dev.md"
    if ($Uninstall) {
        if (Test-Path $wsWindsurf) { Remove-Item $wsWindsurf -Force; $Summary += "workspace windsurf rule: removed" }
    } else {
        New-Item -ItemType Directory -Path (Split-Path $wsWindsurf -Parent) -Force | Out-Null
        Set-Content -Path $wsWindsurf -Value $AdapterBlock -Encoding UTF8
        $Summary += "workspace windsurf rule: installed"
    }
    # RooCode / Cline project rules
    $wsRoo = Join-Path $Workspace ".roo\rules\powerbi-dev.md"
    if ($Uninstall) {
        if (Test-Path $wsRoo) { Remove-Item $wsRoo -Force; $Summary += "workspace roo rule: removed" }
    } else {
        New-Item -ItemType Directory -Path (Split-Path $wsRoo -Parent) -Force | Out-Null
        Set-Content -Path $wsRoo -Value $AdapterBlock -Encoding UTF8
        $Summary += "workspace roo rule: installed"
    }
    # Aider per-repo conventions
    $result = Update-MarkerBlock -FilePath (Join-Path $Workspace ".aider.conf.yml") -BlockContent ("read:`r`n  - " + $AiderConv) -Remove:$Uninstall
    $Summary += "workspace aider conf: $result"
}

$Summary | ForEach-Object { Write-Host "  $_" }
Write-Host ""
if ($Uninstall) {
    Write-Host "powerbi-dev adapters removed."
} else {
    Write-Host "powerbi-dev installed. Source of truth: $PluginRoot"
}
