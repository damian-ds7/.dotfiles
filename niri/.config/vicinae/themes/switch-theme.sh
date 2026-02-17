#!/usr/bin/env bash
set -u

SCHEME="${1?Error: SCHEME (argument 1) is required}"
MODE="${2?Error: MODE (argument 2) is required}"

(
  cd "$HOME"/.config/vicinae/themes || exit
  ln -sfr "$SCHEME/$MODE" current-theme
  CURRENT_SCHEME=$(cat current-theme 2>/dev/null || echo "")
  vicinae theme set "$CURRENT_SCHEME"
)
