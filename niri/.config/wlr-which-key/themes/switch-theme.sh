#!/usr/bin/env bash
set -u

SCHEME="${1?Error: SCHEME (argument 1) is required}"
MODE="${2?Error: MODE (argument 2) is required}"

(
  cd "$HOME"/.config/wlr-which-key/themes || exit
  WLR_FILE="../config.yaml"
  [ -f "$WLR_FILE" ] || return 0

  line="$(grep -n '^# Colors' "$WLR_FILE" | head -n1 | cut -d: -f1 || true)"
  [ -n "$line" ] || return 0

  start=$((line + 1))
  end=$((line + 3))

  tmp="$(mktemp)"

  sed -e "${line}r $SCHEME/$MODE.yaml" \
    -e "${start},${end}d" \
    "$WLR_FILE" >"$tmp"

  mv "$tmp" "$WLR_FILE"
)
