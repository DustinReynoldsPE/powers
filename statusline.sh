#!/bin/bash
# Read JSON data that Claude Code sends to stdin
input=$(cat)

# Extract fields using jq
MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')

# The "// 0" provides a fallback if the field is null
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0' | cut -d. -f1)

# Build progress bar: printf creates spaces, tr replaces with blocks
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
for ((i=0; i<FILLED; i++)); do BAR="${BAR}▓"; done
for ((i=0; i<EMPTY; i++)); do BAR="${BAR}░"; done

# Usage Duration
DURATION_SEC=$((DURATION_MS / 1000))
MINS=$((DURATION_SEC / 60))
SECS=$((DURATION_SEC % 60))

GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

if git rev-parse --git-dir > /dev/null 2>&1; then

    CACHE_FILE="/tmp/statusline-git-cache"
    CACHE_MAX_AGE=5  # seconds

    cache_is_stale() {
        [ ! -f "$CACHE_FILE" ] || \
        # stat -f %m is macOS, stat -c %Y is Linux
        [ $(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0))) -gt $CACHE_MAX_AGE ]
    }

    if cache_is_stale; then
        if git rev-parse --git-dir > /dev/null 2>&1; then
            BRANCH=$(git branch --show-current 2>/dev/null)
            STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
            MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
            echo "$BRANCH|$STAGED|$MODIFIED" > "$CACHE_FILE"
        else
            echo "||" > "$CACHE_FILE"
        fi
    fi

    IFS='|' read -r BRANCH STAGED MODIFIED < "$CACHE_FILE"

    GIT_STATUS=""
    [ "$STAGED" -gt 0 ] && GIT_STATUS="${GREEN}+${STAGED}${RESET}"
    [ "$MODIFIED" -gt 0 ] && GIT_STATUS="${GIT_STATUS}${YELLOW}~${MODIFIED}${RESET}"

    REPO_SLUG=$(git remote get-url origin 2>/dev/null | sed 's/.*github\.com[:/]//' | sed 's/\.git$//')
    printf '%b' "[$MODEL] $BAR $PCT% | ⏱️ ${MINS}m ${SECS}s | 📁 ${DIR##*/} | 🌿 $BRANCH $GIT_STATUS${REPO_SLUG:+ | 🔗 $REPO_SLUG}\n"
else
    # Output the status line - ${DIR##*/} extracts just the folder name
    echo "[$MODEL] $BAR $PCT%  | ⏱️ ${MINS}m ${SECS}s | 📁 ${DIR##*/}"
fi