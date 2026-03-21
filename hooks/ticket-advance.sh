#!/usr/bin/env bash
# ticket-advance.sh — auto-advance ticket when finalized checkpoint is written.
#
# PostToolUse hook. Fires after Edit or Write tool calls.
# Detects "<!-- checkpoint: finalized -->" in the modified file and runs
# `tk advance <id>` if the file is in a .tickets/ directory.

set -euo pipefail

input="$(cat)"

# Only act on Edit and Write tool calls
tool="$(echo "$input" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null || echo "")"
if [[ "$tool" != "Edit" && "$tool" != "Write" ]]; then
    exit 0
fi

# Get the file path that was modified
file_path="$(echo "$input" | python3 -c "
import json,sys
d=json.load(sys.stdin)
inp = d.get('tool_input', {})
print(inp.get('file_path', inp.get('path', '')))
" 2>/dev/null || echo "")"

if [[ -z "$file_path" ]]; then
    exit 0
fi

# Only act on ticket files (.tickets/**/*.md)
if [[ "$file_path" != */.tickets/*.md && "$file_path" != */.tickets/*/*.md ]]; then
    exit 0
fi

# Check if file contains "<!-- checkpoint: finalized -->"
if ! grep -q '<!-- checkpoint: finalized -->' "$file_path" 2>/dev/null; then
    exit 0
fi

# Extract ticket ID from filename
ticket_id="$(basename "$file_path" .md)"

# Find repo root and run tk advance
repo_root="$(git -C "$(dirname "$file_path")" rev-parse --show-toplevel 2>/dev/null || echo "")"
if [[ -z "$repo_root" ]]; then
    exit 0
fi

cd "$repo_root"
if command -v tk &>/dev/null; then
    tk advance "$ticket_id" --force 2>/dev/null || true
fi
