#!/usr/bin/env bash
# PostToolUse hook — run golangci-lint after any .go file edit.
# Skips silently for non-edit tool invocations or non-Go files.

set -euo pipefail

EDIT_TOOLS="replace_string_in_file|create_file|multi_replace_string_in_file"

# Read stdin once
INPUT=$(cat)

TOOL=$(echo "$INPUT" | jq -r '.toolName // .tool_name // ""')

# Only run for file-editing tools
if ! echo "$TOOL" | grep -qE "^($EDIT_TOOLS)$"; then
  exit 0
fi

# Only run when the edited file is a .go file
FILE=$(echo "$INPUT" | jq -r '.toolInput.filePath // .tool_input.file_path // ""')
if [[ "$FILE" != *.go ]]; then
  exit 0
fi

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
cd "$REPO_ROOT"

echo "==> Running golangci-lint after edit to $FILE..."

if golangci-lint run ./... 2>&1; then
  echo "==> Lint passed."
else
  echo "==> Lint FAILED. Fix the issues above before continuing." >&2
  exit 2
fi
