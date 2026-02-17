#!/usr/bin/env bash
set -u

SCHEME="${1?Error: SCHEME (argument 1) is required}"
MODE="${2?Error: MODE (argument 2) is required}"

(
  cd "$HOME"/.config/tmux/themes || exit
  ln -sfr "$SCHEME/$MODE.conf" current-theme.conf

  [ -x "reset.sh" ] && "./reset.sh"
  (tmux info >/dev/null 2>&1 && tmux source-file "../tmux.conf")
)
