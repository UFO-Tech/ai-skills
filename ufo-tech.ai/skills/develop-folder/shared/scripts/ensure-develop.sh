#!/usr/bin/env bash
# Create or complete <project-root>/.develop from the skill templates.
# Idempotent: existing files are never overwritten.
# Prints "legacy: ..." lines for old-layout files that need migration.
# Twin: ensure-develop.ps1 (Windows without Git Bash).
set -euo pipefail

skill_dir="$(cd "$(dirname "$0")/.." && pwd)"
target="$(cd "${1:-$PWD}" && pwd)"
root="$(git -C "$target" rev-parse --show-toplevel 2>/dev/null || echo "$target")"
dev="$root/.develop"

created=""
for d in investigations questions/open questions/accepted questions/rejected \
         issues/features issues/bugfix docs; do
  if [ ! -d "$dev/$d" ]; then
    mkdir -p "$dev/$d"
    created="$created $d/"
  fi
done
for f in README.md glossary.md; do
  if [ ! -e "$dev/$f" ]; then
    cp "$skill_dir/templates/$f" "$dev/$f"
    created="$created $f"
  fi
done

# Keep .develop out of git without touching the shared .gitignore
if git -C "$root" rev-parse --git-dir >/dev/null 2>&1; then
  (
    cd "$root"
    exclude="$(git rev-parse --git-path info/exclude)"
    mkdir -p "$(dirname "$exclude")"
    if ! grep -qxF '/.develop/' "$exclude" 2>/dev/null; then
      # don't glue the entry to a last line without a trailing newline
      if [ -s "$exclude" ] && [ -n "$(tail -c1 "$exclude")" ]; then echo >> "$exclude"; fi
      echo '/.develop/' >> "$exclude"
    fi
  )
fi

if [ -n "$created" ]; then
  echo "$dev: created$created"
else
  echo "$dev: already complete"
fi

for legacy in "$dev/investigate.md" "$dev/qa.md" "$root/.features"; do
  if [ -e "$legacy" ]; then echo "legacy: $legacy"; fi
done
exit 0
