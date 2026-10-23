# Print the next free number in .develop:
#   questions        -> global N from "### <icon> N." headings in questions/**
#   features|bugfix  -> NNN from "<icon>-NNN-<name>.md" files in issues/<kind>/
# Twin of next-number.sh for Windows without Git Bash (PowerShell 5.1+ / 7+).
param(
    [Parameter(Mandatory = $true)][ValidateSet('questions', 'features', 'bugfix')][string]$Kind,
    [string]$ProjectDir = (Get-Location).Path
)

$target = (Resolve-Path -LiteralPath $ProjectDir).Path
$root = $target
if (Get-Command git -ErrorAction SilentlyContinue) {
    $top = git -C $target rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -eq 0 -and $top) { $root = ($top | Select-Object -First 1).Trim() }
}
$dev = Join-Path $root '.develop'

$max = 0
if ($Kind -eq 'questions') {
    $dir = Join-Path $dev 'questions'
    if (Test-Path -LiteralPath $dir) {
        foreach ($file in Get-ChildItem -LiteralPath $dir -Recurse -File -Filter '*.md') {
            foreach ($line in Get-Content -LiteralPath $file.FullName -Encoding UTF8) {
                if ($line -match '^### \D*(\d+)\.') { $n = [int]$Matches[1]; if ($n -gt $max) { $max = $n } }
            }
        }
    }
    $max + 1
} else {
    $dir = Join-Path (Join-Path $dev 'issues') $Kind
    if (Test-Path -LiteralPath $dir) {
        foreach ($file in Get-ChildItem -LiteralPath $dir -File) {
            if ($file.Name -match '^[^-]*-(\d+)-') { $n = [int]$Matches[1]; if ($n -gt $max) { $max = $n } }
        }
    }
    '{0:D3}' -f ($max + 1)
}
