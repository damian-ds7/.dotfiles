#!/usr/bin/env bash
set -u

SCHEME="${1?Error: SCHEME (argument 1) is required}"
MODE="${2?Error: MODE (argument 2) is required}"

(
  cd "$HOME/.config/umbriel/themes" || exit
  ln -sfn "$SCHEME/$MODE.toml" current-theme.toml
)

# Umbriel doesn't notice the symlink being replaced, so reload explicitly
if "$HOME/.local/bin/in-umbriel"; then
  umbriel msg config-reload >/dev/null
fi
