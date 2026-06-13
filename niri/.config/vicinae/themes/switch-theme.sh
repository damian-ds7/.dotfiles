#!/usr/bin/env bash
set -u

SCHEME="${1?Error: SCHEME (argument 1) is required}"
MODE="${2?Error: MODE (argument 2) is required}"

(
  cd "$HOME"/.config/vicinae/themes || exit
  ln -sfr "$SCHEME/$MODE.json" current-theme.json
  systemctl --user restart vicinae.service || vicinae server --replace
)
