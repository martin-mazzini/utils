#!/bin/bash
# input-needed.sh - User input notification script for macOS
# Usage: ./input-needed.sh [title] [message] [sound]

set -euo pipefail

# Default values with user-provided overrides
TITLE="${1:-Input Required 🤖}"
MESSAGE="${2:-💭 Waiting for your input...}"
SOUND="${3:-Purr}"

# Resolve the directory this script is in (robust against symlinks and relative paths)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/input_log.txt"

##############################################
# Show a macOS notification with sound
# Uses `terminal-notifier` if available, falls back to `osascript`
##############################################
show_input_notification() {
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
play_input_sound() {
    local sound_file="/System/Library/Sounds/${SOUND}.aiff"

    if [[ -f "$sound_file" ]]; then
        afplay "$sound_file" 2>/dev/null || true
    else
        echo "Warning: Sound file $sound_file not found, trying default" >&2
        afplay /System/Library/Sounds/Glass.aiff 2>/dev/null || true
    fi
}

##############################################
# Append input request to local log file
##############################################
log_input_request() {
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    echo "[$timestamp] Input requested: $TITLE - $MESSAGE" >> "$LOG_FILE"
}

##############################################
# Print a visual "waiting" banner to the terminal
# Uses figlet if available
##############################################
show_waiting() {
    echo "🤖 Input needed at $(date '+%H:%M:%S')!"

    if command -v figlet >/dev/null 2>&1; then
        figlet "INPUT?" 2>/dev/null || echo "INPUT NEEDED!"
    else
        echo "=============="
        echo "INPUT NEEDED!"
        echo "=============="
    fi
}

##############################################
# Main orchestration function
##############################################
main() {
    show_waiting
    play_input_sound
    show_input_notification "$TITLE" "$MESSAGE" "$SOUND"
    log_input_request "$TITLE" "$MESSAGE" "$SOUND"
}

# Run only if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi