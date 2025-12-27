#!/usr/bin/env zsh

if [[ -n "$SSH_TELEPORT" ]]; then
  return 0
fi

if ! command -v ssh >/dev/null 2>&1; then
  return 0
fi

function ssh() {
  if [[ -n "$NO_SSH_TELEPORT" ]]; then
    command ssh "$@"
    return
  fi

  if [[ -f "$ZDOTDIR/utils/ssh/ssh-teleport.zsh" ]]; then
    source "$ZDOTDIR/utils/ssh/ssh-teleport.zsh"
    ssh-teleport "$@"
  else
    command ssh "$@"
  fi
}
