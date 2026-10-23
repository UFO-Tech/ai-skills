# SessionStart hook: if the project already has CLAUDE.md (i.e. /init ran),
# create or complete .develop/ and leave a note in Claude's context.
# Silent when nothing changed. Never fails the session.
# Twin of session-check.sh for Windows without Git Bash (PowerShell 5.1+ / 7+).

try {
    $start = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { (Get-Location).Path }
    $root = $start
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $top = git -C $start rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0 -and $top) { $root = ($top | Select-Object -First 1).Trim() }
    }
    if (-not (Test-Path -LiteralPath (Join-Path $root 'CLAUDE.md'))) { exit 0 }

    $out = @(& (Join-Path $PSScriptRoot 'ensure-develop.ps1') -ProjectDir $root 2>$null)
    $legacy = @($out | Where-Object { $_ -like 'legacy: *' })

    if (-not ($out | Where-Object { $_ -like '*already complete' })) {
        "develop-folder: $($out[0]). Mention this to the user once and follow the develop-folder skill rules."
    }
    if ($legacy.Count -gt 0) {
        'develop-folder: old-layout notes found - offer the user to migrate them into the .develop structure:'
        $legacy
    }
} catch { }
exit 0
