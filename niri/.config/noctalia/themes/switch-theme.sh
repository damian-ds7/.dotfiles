#!/usr/bin/env bash
set -u

SCHEME="${1?Error: SCHEME (argument 1) is required}"
MODE="${2?Error: MODE (argument 2) is required}"

(
  cd "$HOME"/.config/noctalia/themes || exit
  THEME_FILE="$SCHEME/$MODE"
  if [[ ! -f "$THEME_FILE" ]]; then
    echo "Error: theme file not found: $THEME_FILE" >&2
    exit 1
  fi

  NAME=$(sed -n '1p' "$THEME_FILE")
  TYPE=$(sed -n '2p' "$THEME_FILE")

  if [[ -z "$NAME" || -z "$TYPE" ]]; then
    echo "Error: 'name' or 'type' missing in $THEME_FILE" >&2
    exit 1
  fi

  noctalia msg color-scheme-set "$TYPE" "$NAME"
  noctalia msg theme-mode-set "$MODE"
)
