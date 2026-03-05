#!/usr/bin/env bash
set -u

SCHEME="${1?Error: SCHEME (argument 1) is required}"
MODE="${2?Error: MODE (argument 2) is required}"

(
    cd "$HOME/.config/kitty/themes" || exit
    ln -sf "$SCHEME/$MODE" current-theme
)

killall -q -SIGUSR1 kitty
