#!/usr/bin/env bash
# exit-state.sh — write a structured exit block into the active ticket.
#
# Called by PreCompact and SessionEnd hooks. Reads the active ticket from
# the current git repo's .tickets/ directory and asks the agent (via prompt
# injection) to update it with a checkpoint block before exiting.
#
# This is a command hook that emits a hookSpecificOutput prompt, causing
# the agent to write the exit-state block before the session ends.
#
# Registered in hooks.json as:
#   PreCompact  → prompt type (inline)
#   SessionEnd  → command type (this script)

set -euo pipefail

input="$(cat)"
cwd="$(echo "$input" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('cwd',''))" 2>/dev/null || echo "")"

if [[ -z "$cwd" || ! -d "$cwd" ]]; then
    exit 0
fi

# Find the git root
git_root="$(cd "$cwd" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null || echo "")"
if [[ -z "$git_root" ]]; then
    exit 0
fi

tickets_dir="$git_root/.tickets"
if [[ ! -d "$tickets_dir" ]]; then
    exit 0
fi

# Find the most recently modified in-progress ticket
active_ticket="$(find "$tickets_dir" -name '*.md' -newer "$tickets_dir" -not -path '*/.log/*' \
    2>/dev/null | head -1)"

if [[ -z "$active_ticket" ]]; then
    # Fall back to any non-done ticket modified today
    active_ticket="$(find "$tickets_dir" -name '*.md' -not -path '*/.log/*' \
        -newer "$tickets_dir/.log" 2>/dev/null | head -1 || true)"
fi

ticket_hint=""
if [[ -n "$active_ticket" ]]; then
    ticket_id="$(basename "$active_ticket" .md)"
    ticket_hint=" for ticket \`${ticket_id}\`"
fi

# Emit a prompt that asks the agent to write the exit block
cat <<EOF
{
  "systemMessage": "Before this session ends, update the active ticket${ticket_hint} with a session exit block. Append these HTML comment markers to the ticket file:\n\n\`\`\`\n<!-- checkpoint: <current-phase> -->\n<!-- exit-state: <one sentence: what you were doing, where you stopped, immediate next step> -->\n<!-- key-files: <comma-separated paths that are load-bearing for resuming> -->\n<!-- open-questions: <anything unresolved that the next session should address, or 'none'> -->\n\`\`\`\n\nIf no ticket is active or the work is complete, skip this. Keep exit-state to one sentence."
}
EOF
