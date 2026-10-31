#!/usr/bin/env bash
set -u

SCHEME="${1?Error: SCHEME (argument 1) is required}"
MODE="${2?Error: MODE (argument 2) is required}"

(
  cd "$HOME"/.config/nvim/themes || exit
  ln -sfr "$SCHEME/$MODE" current-theme
)

pkill -USR1 -x nvim || true
