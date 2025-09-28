#!/bin/bash

LOCKFILE="$HOME/.config/niri/.swayidle_toggle.lock"
SHOW_NOTIFICATIONS=true

while getopts "n" opt; do
    case $opt in
        n)
            SHOW_NOTIFICATIONS=false
            ;;
        \?)
            echo "Usage: $0 [-n]"
            echo "  -n    Suppress notifications"
            exit 1
            ;;
    esac
done

send_notification() {
    if [ "$SHOW_NOTIFICATIONS" = true ]; then
        notify-send "$1" "$2"
    fi
}

if pgrep -f "swayidle"; then
    pkill -f "swayidle"
    rm -f "$LOCKFILE"
    send_notification "Auto Suspend" "Auto Suspend is now disabled"
else
    swayidle -w \
      timeout 180 'niri msg action power-off-monitors' \
      timeout 240 'swaylock -f' \
      timeout 300 'systemctl suspend' \
      resume 'niri msg action power-off-monitors' \
      before-sleep 'swaylock -f' &

    touch "$LOCKFILE"
    send_notification "Auto Suspend" "Auto Suspend is now enabled"
fi
