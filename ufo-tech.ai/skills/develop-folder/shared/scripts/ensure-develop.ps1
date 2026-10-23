# Create or complete <project-root>/.develop from the skill templates.
# Idempotent: existing files are never overwritten.
# Prints "legacy: ..." lines for old-layout files that need migration.
# Twin of ensure-develop.sh for Windows without Git Bash (PowerShell 5.1+ / 7+).
param([string]$ProjectDir = (Get-Location).Path)

$skillDir = Split-Path -Parent $PSScriptRoot
$target = (Resolve-Path -LiteralPath $ProjectDir).Path
$root = $target
$inGit = $false
if (Get-Command git -ErrorAction SilentlyContinue) {
    $top = git -C $target rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -eq 0 -and $top) { $root = ($top | Select-Object -First 1).Trim(); $inGit = $true }
}
$dev = Join-Path $root '.develop'

$created = @()
foreach ($d in 'investigations', 'questions/open', 'questions/accepted', 'questions/rejected',
               'issues/features', 'issues/bugfix', 'docs') {
    $p = Join-Path $dev $d
    if (-not (Test-Path -LiteralPath $p -PathType Container)) {
        New-Item -ItemType Directory -Path $p -Force | Out-Null
        $created += "$d/"
    }
}
foreach ($f in 'README.md', 'glossary.md') {
    $p = Join-Path $dev $f
    if (-not (Test-Path -LiteralPath $p)) {
        Copy-Item -LiteralPath (Join-Path (Join-Path $skillDir 'templates') $f) -Destination $p
        $created += $f
    }
}

# Keep .develop out of git without touching the shared .gitignore
if ($inGit) {
    Push-Location -LiteralPath $root
    try { $exclude = (git rev-parse --git-path info/exclude | Select-Object -First 1).Trim() } finally { Pop-Location }
    if (-not [System.IO.Path]::IsPathRooted($exclude)) { $exclude = Join-Path $root $exclude }
    New-Item -ItemType Directory -Path (Split-Path -Parent $exclude) -Force | Out-Null
    $lines = @()
    if (Test-Path -LiteralPath $exclude) { $lines = @(Get-Content -LiteralPath $exclude) }
    if ($lines -notcontains '/.develop/') {
        $raw = if (Test-Path -LiteralPath $exclude) { [System.IO.File]::ReadAllText($exclude) } else { '' }
        $prefix = if ($raw.Length -gt 0 -and -not $raw.EndsWith("`n")) { "`n" } else { '' }
        [System.IO.File]::AppendAllText($exclude, "$prefix/.develop/`n")
    }
}

if ($created.Count -gt 0) { "${dev}: created $($created -join ' ')" } else { "${dev}: already complete" }

foreach ($legacy in (Join-Path $dev 'investigate.md'), (Join-Path $dev 'qa.md'), (Join-Path $root '.features')) {
    if (Test-Path -LiteralPath $legacy) { "legacy: $legacy" }
}
exit 0
