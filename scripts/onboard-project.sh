#!/usr/bin/env bash
# onboard-project.sh — wire a new or existing repo into the full dev stack.
#
# Sets up:
#   - .tickets/ directory (tk init)
#   - CLAUDE.md from template (if missing)
#   - zeroclaw config.toml entries (workspace + tmux_target)
#   - Per-room cron status job in zeroclaw
#
# Usage:
#   ./scripts/onboard-project.sh --path <repo_path> [options]
#
# Options:
#   --path <path>         Path to the repo (required)
#   --room <room_id>      Matrix room ID to map (e.g. !abc:matrix.local)
#   --tmux <target>       Tmux target (e.g. main:myproject)
#   --name <name>         Project name (defaults to directory basename)
#   --dry-run             Print what would happen, don't change anything
#
# Prerequisites:
#   - tk CLI available
#   - zeroclaw installed and ~/.zeroclaw/config.toml exists
#   - Powers plugin installed in Claude Code

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POWERS_ROOT="$(dirname "$SCRIPT_DIR")"
ZEROCLAW_CONFIG="${ZEROCLAW_CONFIG:-$HOME/.zeroclaw/config.toml}"
ZEROCLAW_BIN="${ZEROCLAW_BIN:-$(which zeroclaw 2>/dev/null || echo "$HOME/.cargo/bin/zeroclaw")}"
CRON_SCRIPT="$HOME/code/zeroclaw/services/cron-bot-status.sh"
DRY_RUN=0
REPO_PATH=""
ROOM_ID=""
TMUX_TARGET=""
PROJECT_NAME=""

usage() {
    sed -n '2,/^$/p' "$0" | grep '#' | sed 's/^# *//'
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --path)    REPO_PATH="$2"; shift 2 ;;
        --room)    ROOM_ID="$2"; shift 2 ;;
        --tmux)    TMUX_TARGET="$2"; shift 2 ;;
        --name)    PROJECT_NAME="$2"; shift 2 ;;
        --dry-run) DRY_RUN=1; shift ;;
        *) echo "Unknown arg: $1" >&2; usage ;;
    esac
done

if [[ -z "$REPO_PATH" ]]; then
    echo "Error: --path is required" >&2; usage
fi

REPO_PATH="$(cd "$REPO_PATH" && pwd)"
PROJECT_NAME="${PROJECT_NAME:-$(basename "$REPO_PATH")}"

run() {
    if [[ "$DRY_RUN" == "1" ]]; then
        echo "[dry-run] $*"
    else
        "$@"
    fi
}

echo "=== Onboarding: $PROJECT_NAME ==="
echo "  Path:  $REPO_PATH"
[[ -n "$ROOM_ID" ]]     && echo "  Room:  $ROOM_ID"
[[ -n "$TMUX_TARGET" ]] && echo "  Tmux:  $TMUX_TARGET"
echo ""

# ── Step 1: Initialize ticket store ─────────────────────────────────────────
if [[ ! -d "$REPO_PATH/.tickets" ]]; then
    echo "→ Creating .tickets/"
    run mkdir -p "$REPO_PATH/.tickets"
    run mkdir -p "$REPO_PATH/.tickets/.log"
else
    echo "✓ .tickets/ already exists"
fi

# ── Step 2: CLAUDE.md ────────────────────────────────────────────────────────
CLAUDE_MD="$REPO_PATH/CLAUDE.md"
if [[ ! -f "$CLAUDE_MD" ]]; then
    echo "→ Creating CLAUDE.md from template"
    if [[ "$DRY_RUN" == "0" ]]; then
        cat > "$CLAUDE_MD" <<TEMPLATE
# CLAUDE.md — ${PROJECT_NAME}

## Commands

\`\`\`bash
# Add build/test/lint commands here
\`\`\`

## Project Snapshot

<!-- 2-3 sentences describing what this project does and its architecture -->

## Repository Map

<!-- Key directories and what they contain -->

## Ticket Tracking

\`\`\`bash
tk list                    # All open tickets
tk ready                   # Unblocked tickets ready to work
tk show <id>               # Full ticket details
tk create "title" --type task --priority 2
tk advance <id> --force    # Move through pipeline
\`\`\`

Pipeline: \`triage → spec → design → implement → test → verify → done\`
TEMPLATE
    fi
    echo "  Created: $CLAUDE_MD (fill in project details)"
else
    echo "✓ CLAUDE.md already exists"
fi

# ── Step 3: zeroclaw config.toml entries ─────────────────────────────────────
if [[ -n "$ROOM_ID" && -f "$ZEROCLAW_CONFIG" ]]; then
    if grep -qF "$ROOM_ID" "$ZEROCLAW_CONFIG"; then
        echo "✓ zeroclaw workspace already mapped for $ROOM_ID"
    else
        echo "→ Adding zeroclaw workspace mapping"
        if [[ "$DRY_RUN" == "0" ]]; then
            python3 - <<PYEOF
import re

config_path = "$ZEROCLAW_CONFIG"
room_id = "$ROOM_ID"
repo_path = "$REPO_PATH"
tmux_target = "$TMUX_TARGET"

with open(config_path) as f:
    content = f.read()

# Add to channel_workspaces
ws_line = f'"{room_id}" = "{repo_path}"'
content = re.sub(
    r'(\[channel_workspaces\]\n)',
    f'\\1{ws_line}\n',
    content
)

# Add to tmux_targets if provided
if tmux_target:
    tmux_line = f'"{room_id}" = "{tmux_target}"'
    content = re.sub(
        r'(\[tmux_targets\]\n)',
        f'\\1{tmux_line}\n',
        content
    )

with open(config_path, 'w') as f:
    f.write(content)

print("  Config updated.")
PYEOF
        else
            echo "  Would add workspace: \"$ROOM_ID\" = \"$REPO_PATH\""
            [[ -n "$TMUX_TARGET" ]] && echo "  Would add tmux: \"$ROOM_ID\" = \"$TMUX_TARGET\""
        fi
    fi
fi

# ── Step 4: zeroclaw cron status job ─────────────────────────────────────────
if [[ -n "$ROOM_ID" && -x "$ZEROCLAW_BIN" && -f "$CRON_SCRIPT" ]]; then
    echo "→ Adding cron status job for room $ROOM_ID"
    # Get next available minute offset (0-59) to avoid collisions
    NEXT_MIN="$(python3 -c "
import subprocess, json, sys
result = subprocess.run(['$ZEROCLAW_BIN', 'cron', 'list', '--json'],
    capture_output=True, text=True)
try:
    jobs = json.loads(result.stdout) if result.stdout.strip() else []
    used = set()
    for j in jobs:
        sched = j.get('schedule','')
        parts = sched.split()
        if parts:
            try: used.add(int(parts[0]))
            except: pass
    for m in range(60):
        if m not in used:
            print(m); sys.exit()
except Exception as e:
    print(0)
" 2>/dev/null || echo "5")"
    CRON_CMD="$CRON_SCRIPT $ROOM_ID"
    CRON_SCHEDULE="${NEXT_MIN} * * * *"
    if [[ "$DRY_RUN" == "0" ]]; then
        "$ZEROCLAW_BIN" cron add "$CRON_SCHEDULE" "$CRON_CMD" \
            --name "status-$PROJECT_NAME" 2>/dev/null && \
            echo "  Cron added: $CRON_SCHEDULE → $CRON_CMD" || \
            echo "  Warning: could not add cron job (add manually)"
    else
        echo "  Would add cron: $CRON_SCHEDULE → $CRON_CMD"
    fi
fi

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "=== Done ==="
echo ""
echo "Next steps:"
echo "  1. Fill in CLAUDE.md with project details (keep ≤80 lines)"
echo "  2. Create initial tickets: tk create 'project setup' --type chore"
[[ -n "$ROOM_ID" ]] && echo "  3. Restart zeroclaw daemon to pick up config changes"
echo "  4. Ensure Powers is installed: /plugin install DustinReynoldsPE/powers"
echo ""
