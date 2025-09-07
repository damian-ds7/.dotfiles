#!/usr/bin/env bash
set -Ceuo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: $0 <output_file> [debounce_seconds]"
    exit 1
fi

readonly OUTPUT_FILE="$1"
readonly OUTPUT_DIR=$(dirname "$OUTPUT_FILE")
readonly LOG_FILE="$OUTPUT_DIR/extension-prefs.log"
readonly DEBOUNCE_SECONDS="${2:-2}"

readonly REPO_DIR="$HOME/Projects/setup-scripts"
readonly REPO_URL="git@github.com:damian-ds7/setup-scripts"

debounce_action_pid=""
dconf_watch_pid=""

ensure_repo_exists() {
    if [ ! -d "$REPO_DIR" ]; then
        echo "Repository not found at $REPO_DIR"
        echo "Cloning repository from $REPO_URL..."

        mkdir -p "$HOME/Projects"

        if git clone "$REPO_URL" "$REPO_DIR"; then
            echo "Successfully cloned repository to $REPO_DIR"
        else
            echo "Failed to clone repository."
            return 1
        fi
    fi
    return 0
}

run_export_action() {
    echo "Waiting ${DEBOUNCE_SECONDS}s debounce interval before running export"
    sleep $((DEBOUNCE_SECONDS))

    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp: Running extension export after debounce"
    echo "$timestamp: Running extension export" >> "$LOG_FILE"

    if ensure_repo_exists; then
        "$REPO_DIR/fedora/gnome-extensions-config.sh" export "$OUTPUT_FILE"
    fi
}

cleanup() {
    echo "Shutting down..."
    if [ -n "$debounce_action_pid" ] && ps -p "$debounce_action_pid" > /dev/null 2>&1; then
        kill "$debounce_action_pid"
    fi
    if [ -n "$dconf_watch_pid" ] && ps -p "$dconf_watch_pid" > /dev/null 2>&1; then
        kill "$dconf_watch_pid"
    fi
    exit 0
}

trap cleanup SIGTERM SIGINT

echo "Starting GNOME extension monitoring with ${DEBOUNCE_SECONDS}s debounce"
echo "Logging to: $LOG_FILE"
echo "Output file: $OUTPUT_FILE"

mkdir -p "$OUTPUT_DIR"

ensure_repo_exists

dconf watch /org/gnome/shell/extensions/ | while IFS= read -r line; do
    if [[ -z "$line" ]]; then
        continue
    fi

    schema_path="$line"

    if IFS= read -r value_line; then
        if [[ -z "$value_line" ]]; then
            continue
        fi

        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        log_entry="$timestamp: Extension preference changed: $schema_path = $value_line"

        echo "$log_entry" >> "$LOG_FILE"

        if [ -n "$debounce_action_pid" ] && ps -p "$debounce_action_pid" > /dev/null 2>&1; then
            echo "Killing previous export action with PID: $debounce_action_pid"
            kill "$debounce_action_pid"
        fi

        run_export_action &
        debounce_action_pid=$!
    else
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        log_entry="$timestamp: Extension preference changed: $schema_path (no value)"

        echo "$log_entry" >> "$LOG_FILE"
        echo "$log_entry"
    fi
done
