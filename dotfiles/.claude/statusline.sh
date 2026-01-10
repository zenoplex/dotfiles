#!/bin/bash

# Status line for Claude Code
# Shows: model name, progress bar, context %, tokens, git branch, project folder

# Read JSON input
input=$(cat)

# Extract values from JSON
model_name=$(echo "$input" | jq -r '.model.display_name')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
project_name=$(basename "$current_dir")

# Git branch (skip optional locks for performance)
git_branch=""
if git -C "$current_dir" --no-optional-locks rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$current_dir" --no-optional-locks branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
        git_branch="$branch"
    fi
fi

# Context window usage with progress bar
progress_bar=""
context_pct=""
tokens_display=""
usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$usage" != "null" ]; then
    input_tokens=$(echo "$usage" | jq '.input_tokens')
    output_tokens=$(echo "$usage" | jq '.output_tokens')
    cache_creation=$(echo "$usage" | jq '.cache_creation_input_tokens')
    cache_read=$(echo "$usage" | jq '.cache_read_input_tokens')
    context_size=$(echo "$input" | jq '.context_window.context_window_size')

    # Calculate current context usage
    current_total=$((input_tokens + cache_creation + cache_read))
    pct=$((current_total * 100 / context_size))

    # Format token counts (e.g., 15k, 150k, 1.5M)
    format_tokens() {
        local num=$1
        if [ $num -ge 1000000 ]; then
            awk "BEGIN {printf \"%.1fM\", $num/1000000}"
        elif [ $num -ge 1000 ]; then
            awk "BEGIN {printf \"%.0fk\", $num/1000}"
        else
            echo "$num"
        fi
    }

    in_fmt=$(format_tokens $input_tokens)
    out_fmt=$(format_tokens $output_tokens)
    current_fmt=$(format_tokens $current_total)
    limit_fmt=$(format_tokens $context_size)

    # Create progress bar (20 chars wide)
    bar_width=20
    filled=$((pct * bar_width / 100))
    empty=$((bar_width - filled))

    bar="["
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done
    bar="${bar}]"

    progress_bar="$bar"
    context_pct="${pct}%"
    tokens_display="${current_fmt}/${limit_fmt} (↓${in_fmt} ↑${out_fmt})"
fi

# Build status line components in requested order
components=()

# 1. Model name
components+=("$(printf '\033[34m')${model_name}$(printf '\033[0m')")

# 2-4. Progress bar, context percentage, token counts (if available)
if [ -n "$progress_bar" ]; then
    # Color based on usage
    if [ "$pct" -lt 50 ]; then
        color="$(printf '\033[32m')"  # green
    elif [ "$pct" -lt 80 ]; then
        color="$(printf '\033[33m')"  # yellow
    else
        color="$(printf '\033[31m')"  # red
    fi

    components+=("${progress_bar}")
    components+=("${color}${context_pct}$(printf '\033[0m')")
    components+=("${tokens_display}")
fi

# 5. Git branch
if [ -n "$git_branch" ]; then
    components+=("$(printf '\033[35m')${git_branch}$(printf '\033[0m')")
fi

# 6. Project folder
components+=("$(printf '\033[36m')${project_name}$(printf '\033[0m')")

# Join components with separator
output=""
for i in "${!components[@]}"; do
    if [ $i -eq 0 ]; then
        output="${components[$i]}"
    else
        output="${output} | ${components[$i]}"
    fi
done

printf "%s" "$output"
