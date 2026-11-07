#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <phase-folder> <kernel-slug>" >&2
  echo "Example: $0 03-reduction sum-reduction" >&2
  exit 2
fi
phase="$1"
slug="$2"

# Keep names safe for paths.
for value in "$phase" "$slug"; do
  if [[ ! "$value" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "Invalid name: $value (allowed: letters, digits, dot, underscore, dash)" >&2
    exit 2
  fi
done

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="$root/labs/$phase/$slug"
if [[ -e "$target" ]]; then
  echo "Target already exists: $target" >&2
  exit 1
fi
mkdir -p "$target"
cp "$root/templates/kernel-lab.md" "$target/LAB.md"
cat > "$target/README.md" <<EOF
# $slug

## Goal

[What capability does this lab train?]

## Build / test

[Commands]

## Files

- [LAB.md](LAB.md)
EOF

echo "Created: $target"
echo "Next: edit LAB.md frontmatter and add a correctness reference/test before optimizing."
