#!/usr/bin/env bash
set -u

SCHEME="${1?Error: SCHEME (argument 1) is required}"
MODE="${2?Error: MODE (argument 2) is required}"

(
  cd "$HOME"/.config/nvim/themes || exit
  ln -sfr "$SCHEME/$MODE" current-theme

  scheme
  read -r scheme <current-theme

  if [[ -d "$NVIM_SOCKET_DIR" ]]; then
    for sock in "$NVIM_SOCKET_DIR"/*; do
      if [[ -S "$sock" ]]; then
        nvim --server "$sock" --remote-send ":silent colorscheme $scheme<CR>"
        echo "NVIM: theme '$scheme' set for socket '$sock'" >&1
      fi
    done
  fi
)
