#!/usr/bin/env bash
# Print the next free number in .develop:
#   questions        -> global N from "### <icon> N." headings in questions/**
#   features|bugfix  -> NNN from "<icon>-NNN-<name>.md" files in issues/<kind>/
set -euo pipefail

kind="${1:?usage: next-number.sh questions|features|bugfix [project-dir]}"
target="$(cd "${2:-$PWD}" && pwd)"
root="$(git -C "$target" rev-parse --show-toplevel 2>/dev/null || echo "$target")"
dev="$root/.develop"

case "$kind" in
  questions)
    max="$( (grep -rhE '^### ' "$dev/questions" 2>/dev/null || true) \
      | sed -nE 's/^### [^0-9]*([0-9]+)\..*/\1/p' | sort -n | tail -1)"
    echo $(( ${max:-0} + 1 ))
    ;;
  features|bugfix)
    max="$( (ls "$dev/issues/$kind" 2>/dev/null || true) \
      | sed -nE 's/^[^-]*-([0-9]+)-.*/\1/p' | sed 's/^0*//' | sort -n | tail -1)"
    printf '%03d\n' $(( ${max:-0} + 1 ))
    ;;
  *)
    echo "unknown kind: $kind" >&2
    exit 1
    ;;
esac
