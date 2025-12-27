#!/usr/bin/env zsh

SKIP_PLUGINS_FILE="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/.skip-plugins"

if [[ -f "$SKIP_PLUGINS_FILE" ]]; then
  return 0
fi

prompt_skip_plugins() {
  echo "" >&2
  echo "Git is required for zinit plugin management." >&2
  echo "" >&2

  local response
  if command -v gum >/dev/null 2>&1; then
    if gum confirm "Skip plugin installation?"; then
      response="y"
    else
      response="n"
    fi
  else
    echo -n "Skip plugin installation? [y/N]: " >&2
    read -r response
  fi

  if [[ "$response" =~ ^[Yy]$ ]]; then
    touch "$SKIP_PLUGINS_FILE"
    echo "Plugins disabled. To re-enable, delete: $SKIP_PLUGINS_FILE" >&2
    return 0  # Skip
  else
    return 1  # Don't skip
  fi
}

setup_zinit() {
  local zinit_home="${ZINIT_HOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git}"

  if [[ -d "$zinit_home" ]]; then
    return 0
  fi

  mkdir -p "$(dirname "$zinit_home")"

  if git clone https://github.com/zdharma-continuum/zinit.git "$zinit_home" 2>&1; then
    return 0
  else
    return 1
  fi
}

setup_zinit_plugins() {
  zinit light-mode depth=1 for \
    jeffreytse/zsh-vi-mode

  zinit wait lucid light-mode depth=1 for \
    blockf atpull'zinit creinstall -q .' \
      zsh-users/zsh-completions \
    Aloxaf/fzf-tab \
    atload"_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions \
    atinit"zicompinit; zicdreplay" \
      zdharma-continuum/fast-syntax-highlighting

  zstyle :omz:plugins:ssh-agent lazy yes

  zinit snippet OMZ::plugins/ssh-agent/ssh-agent.plugin.zsh
  zinit snippet OMZ::plugins/fancy-ctrl-z/fancy-ctrl-z.plugin.zsh
  zinit snippet OMZ::plugins/rust/rust.plugin.zsh
}

init_zinit() {
  if ! command -v git >/dev/null 2>&1; then
    if prompt_skip_plugins; then
      return 0
    else
      echo "Error: Git is required. Install it or skip plugins." >&2
      return 1
    fi
  fi

  setup_zinit || return 1

  local zinit_home="${ZINIT_HOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git}"
  source "${zinit_home}/zinit.zsh" || return 1

  setup_zinit_plugins

  [[ -f "$ZDOTDIR/utils/plugins/zsh-vi-mode.zsh" ]] && source "$ZDOTDIR/utils/plugins/zsh-vi-mode.zsh"
  [[ -f "$ZDOTDIR/utils/plugins/zsh-autosuggestions.zsh" ]] && source "$ZDOTDIR/utils/plugins/zsh-autosuggestions.zsh"
  [[ -f "$ZDOTDIR/utils/plugins/fzf-tab.zsh" ]] && source "$ZDOTDIR/utils/plugins/fzf-tab.zsh"

  return 0
}

init_zinit
