#!/usr/bin/env bash
# PostToolUse hook — run `go test ./...` after any file-editing tool.
# Skips silently for non-edit tool invocations to avoid noise.

set -euo pipefail

EDIT_TOOLS="replace_string_in_file|create_file|multi_replace_string_in_file"

# Read stdin once
INPUT=$(cat)

TOOL=$(echo "$INPUT" | jq -r '.toolName // .tool_name // ""')

# Only run for file-editing tools
if ! echo "$TOOL" | grep -qE "^($EDIT_TOOLS)$"; then
  exit 0
fi

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
cd "$REPO_ROOT"

echo "==> Running unit tests after edit to $(echo "$INPUT" | jq -r '.toolInput.filePath // .tool_input.file_path // "file"')..."

if go test ./... 2>&1; then
  echo "==> Tests passed."
else
  echo "==> Tests FAILED. Review the output above before continuing." >&2
  exit 2
fi
