#!/usr/bin/env zsh

if ! command -v rustup >/dev/null 2>&1; then
  echo "rustup not found, skipping completions setup"
  return 0
fi

COMPLETIONS_DIR="${ZDOTDIR:-$HOME/.config/zsh}/completions"

if [[ ! -d "$COMPLETIONS_DIR" ]]; then
  mkdir -p "$COMPLETIONS_DIR"
fi

if [[ ! -f "$COMPLETIONS_DIR/_cargo" ]]; then
  rustup completions zsh cargo > "$COMPLETIONS_DIR/_cargo"
fi

if [[ ! -f "$COMPLETIONS_DIR/_rustup" ]]; then
  rustup completions zsh rustup > "$COMPLETIONS_DIR/_rustup"
fi
