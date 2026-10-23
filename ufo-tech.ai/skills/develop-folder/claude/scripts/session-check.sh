#!/usr/bin/env bash
# SessionStart hook: if the project already has CLAUDE.md (i.e. /init ran),
# create or complete .develop/ and leave a note in Claude's context.
# Silent when nothing changed. Never fails the session.
# Twin: session-check.ps1 (Windows without Git Bash).

cat >/dev/null 2>&1 || true   # hook input JSON is not needed
skill_dir="$(cd "$(dirname "$0")/.." && pwd)"
start="${CLAUDE_PROJECT_DIR:-$PWD}"
root="$(git -C "$start" rev-parse --show-toplevel 2>/dev/null || echo "$start")"

[ -f "$root/CLAUDE.md" ] || exit 0

out="$(bash "$skill_dir/scripts/ensure-develop.sh" "$root" 2>/dev/null)" || exit 0
legacy="$(printf '%s\n' "$out" | grep '^legacy: ' || true)"

if ! printf '%s' "$out" | grep -q 'already complete'; then
  echo "develop-folder: $(printf '%s\n' "$out" | head -1). Mention this to the user once and follow the develop-folder skill rules."
fi
if [ -n "$legacy" ]; then
  echo "develop-folder: old-layout notes found - offer the user to migrate them into the .develop structure:"
  printf '%s\n' "$legacy"
fi
exit 0
