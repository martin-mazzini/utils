#!/bin/bash
# finish.sh - Enhanced task completion notification script for macOS
# Usage: ./finish.sh [title] [message] [sound] (TASK_START_TIME must be exported if you want duration)

set -euo pipefail

# Default values with user-provided overrides
TITLE="${1:-Task Finished 🎉}"
MESSAGE="${2:-🎯 Task completed successfully!}"
SOUND="${3:-Funk}"

# Resolve the directory this script is in (robust against symlinks and relative paths)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/finish_log.txt"

##############################################
# Show a macOS notification with sound
# Uses `terminal-notifier` if available, falls back to `osascript`
##############################################
show_completion_notification() {
    local title="$1"
    local message="$2"
    local sound="$3"

    if command -v terminal-notifier >/dev/null 2>&1; then
        terminal-notifier -title "$title" -message "$message" -sound "$sound" -timeout 10
    else
        echo "Warning: terminal-notifier not found. Install with: brew install terminal-notifier" >&2
        osascript -e "display notification \"$message\" with title \"$title\" sound name \"$sound\""
    fi
}

##############################################
# Play system sound by name using afplay
# Falls back to 'Glass.aiff' if chosen sound doesn't exist
##############################################
play_completion_sound() {
    local sound_file="/System/Library/Sounds/${SOUND}.aiff"

    if [[ -f "$sound_file" ]]; then
        afplay "$sound_file" 2>/dev/null || true
    else
        echo "Warning: Sound file $sound_file not found, trying default" >&2
        afplay /System/Library/Sounds/Glass.aiff 2>/dev/null || true
    fi
}

##############################################
# Append task completion to local log file
# Includes duration if available
##############################################
log_completion() {
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local duration=""

    # If a 4th argument is passed, treat it as duration
    if [[ -n "${4:-}" ]]; then
        duration=" (Duration: $4)"
    fi

    echo "[$timestamp] Task completed: $TITLE - $MESSAGE$duration" >> "$LOG_FILE"
}

##############################################
# Print a visual "celebration" banner to the terminal
# Uses figlet if available
##############################################
celebrate() {
    echo "🎉 Task completed at $(date '+%H:%M:%S')!"

    if command -v figlet >/dev/null 2>&1; then
        figlet "DONE!" 2>/dev/null || echo "TASK COMPLETE!"
    else
        echo "=============="
        echo "TASK COMPLETE!"
        echo "=============="
    fi
}

##############################################
# Main orchestration function
# Computes duration if TASK_START_TIME is exported
##############################################
main() {
    local start_time="${TASK_START_TIME:-}"
    local duration=""

    if [[ -n "$start_time" ]]; then
        local end_time
        end_time=$(date +%s)
        local elapsed=$((end_time - start_time))
        duration="${elapsed}s"
    fi

    celebrate
    play_completion_sound
    show_completion_notification "$TITLE" "$MESSAGE" "$SOUND"
    log_completion "$TITLE" "$MESSAGE" "$SOUND" "$duration"
}

# Run only if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi