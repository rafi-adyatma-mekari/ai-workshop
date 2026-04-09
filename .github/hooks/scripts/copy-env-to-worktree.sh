#!/usr/bin/env bash
# copy-env-to-worktree.sh
# Copies gitignored environment/config files from the main working tree
# to a newly created worktree so it has the same runtime environment.
#
# Usage: ./copy-env-to-worktree.sh <worktree-path>

set -euo pipefail

WORKTREE_PATH="${1:-}"
if [[ -z "$WORKTREE_PATH" ]]; then
  echo "Usage: $0 <worktree-path>" >&2
  exit 1
fi

if [[ ! -d "$WORKTREE_PATH" ]]; then
  echo "Error: worktree path '$WORKTREE_PATH' does not exist." >&2
  exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

# Patterns of gitignored files we want to mirror into the worktree.
# Extend this list as needed (e.g. *.pem, config.local.yaml).
PATTERNS=(".env" ".env.*" "*.pem" "*.key" "config.local.*" ".secrets")

COPIED=0
for pattern in "${PATTERNS[@]}"; do
  # find matches in repo root only (not recursive) for safety
  while IFS= read -r -d '' file; do
    # Confirm git actually ignores it (skip tracked files)
    if git check-ignore -q "$file" 2>/dev/null; then
      dest="$WORKTREE_PATH/$file"
      mkdir -p "$(dirname "$dest")"
      cp "$file" "$dest"
      echo "  Copied: $file → $dest"
      ((COPIED++))
    fi
  done < <(find . -maxdepth 1 -name "$pattern" -print0 2>/dev/null)
done

if [[ $COPIED -eq 0 ]]; then
  echo "  No gitignored environment files found to copy."
else
  echo "  Done. $COPIED file(s) copied to worktree."
fi
