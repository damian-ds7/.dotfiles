#!/usr/bin/env bash
set -u

SCHEME="${1?Error: SCHEME (argument 1) is required}"
MODE="${2?Error: MODE (argument 2) is required}"

(
  cd "$HOME"/.config/noctalia/themes || exit
  CURRENT_SCHEME=$(cat current-theme 2>/dev/null || echo "")
  if [ "$CURRENT_SCHEME" != "$SCHEME" ]; then
    if [ -x "./$SCHEME/noctalia.sh" ]; then
      "./$SCHEME/noctalia.sh"
    else
      echo "Warning: No switch script found for $SCHEME"
    fi
  fi
)

if [ "$MODE" = "dark" ]; then
  qs ipc call darkMode setDark
else
  qs ipc call darkMode setLight
fi
