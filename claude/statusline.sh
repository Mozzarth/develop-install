#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | awk '{printf "%.0f", $1}')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
BRANCH=$(echo "$input" | jq -r '.workspace.git_worktree // empty')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')

COST_FMT=$(printf '$%.4f' "$COST")
FOLDER="${DIR##*/}"
RL=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
EFFORT=$(echo "$input" | jq -r '.effort.level // empty')

if [ -z "$BRANCH" ]; then
    BRANCH=$(git -C "$DIR" --no-optional-locks branch --show-current 2>/dev/null)
fi

# ANSI colors (will render dimmed in Claude Code status line)
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
MAGENTA='\033[0;35m'
BLUE='\033[0;34m'
RED='\033[0;31m'
WHITE='\033[0;37m'
RESET='\033[0m'

MODEL_PART=$(printf "${CYAN}[%s]${RESET}" "$MODEL")
FOLDER_PART=$(printf "${YELLOW}%s${RESET}" "$FOLDER")
PCT_PART=$(printf "${GREEN}%s%% ctx${RESET}" "$PCT")
COST_PART=$(printf "${MAGENTA}%s${RESET}" "$COST_FMT")

OPTIONAL_PARTS=""
[ -n "$RL" ] && OPTIONAL_PARTS="$OPTIONAL_PARTS | $(printf "${RED}RL: $(printf '%.0f' "$RL")%%${RESET}")"
[ -n "$EFFORT" ] && OPTIONAL_PARTS="$OPTIONAL_PARTS | $(printf "${WHITE}effort: %s${RESET}" "$EFFORT")"

if [ -n "$BRANCH" ]; then
    BRANCH_PART=$(printf "${BLUE}%s${RESET}" "$BRANCH")
    printf "%b %b | %b | %b | %b%b\n" "$MODEL_PART" "$FOLDER_PART" "$BRANCH_PART" "$PCT_PART" "$COST_PART" "$OPTIONAL_PARTS"
else
    printf "%b %b | %b | %b%b\n" "$MODEL_PART" "$FOLDER_PART" "$PCT_PART" "$COST_PART" "$OPTIONAL_PARTS"
fi
