#!/usr/bin/env bash
# SessionStart hook for beadpowers plugin

set -euo pipefail

# Determine plugin root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Read content
content=$(cat "${PLUGIN_ROOT}/skills/using-powers/SKILL.md" 2>&1 || echo "Error reading using-powers skill")

# Escape outputs for JSON using pure bash
escape_for_json() {
    local input="$1"
    local output=""
    local i char
    for (( i=0; i<${#input}; i++ )); do
        char="${input:$i:1}"
        case "$char" in
            $'\\') output+='\\' ;;
            '"') output+='\"' ;;
            $'\n') output+='\n' ;;
            $'\r') output+='\r' ;;
            $'\t') output+='\t' ;;
            *) output+="$char" ;;
        esac
    done
    printf '%s' "$output"
}

content_escaped=$(escape_for_json "$content")

# Output context injection as JSON
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Powers plugin loaded. Run /create-feature, /create-bug, /work-ticket, /finishing-branch, /brainstorming, /investigate.\n\n${content_escaped}"
  }
}
EOF

exit 0