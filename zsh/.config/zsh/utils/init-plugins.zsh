#!/usr/bin/env zsh

SKIP_PLUGINS_FILE="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/.skip-plugins"
[[ -f "$SKIP_PLUGINS_FILE" ]] && return 0

source-compiled() {
  local file="$1"
  [[ -f "$file" ]] || return 1

  if [[ ! -f "${file}.zwc" ]] || [[ "$file" -nt "${file}.zwc" ]]; then
    zcompile "$file" 2>/dev/null || true
  fi

  source "$file"
}

compile-digest() {
  local digest="$1"
  shift
  local files=("$@")

  local needs_compile=0
  [[ ! -f "${digest}.zwc" ]] && needs_compile=1

  if [[ $needs_compile -eq 0 ]]; then
    for file in "${files[@]}"; do
      [[ ! -f "$file" ]] && return 1
      [[ "$file" -nt "${digest}.zwc" ]] && needs_compile=1 && break
    done
  fi

  if [[ $needs_compile -eq 1 ]]; then
    zcompile "$digest" "${files[@]}" 2>/dev/null || true
  fi
}

source-directory() {
  local dir="$1"
  local use_digest="${2:-false}"

  [[ ! -d "$dir" ]] && return 1

  local files=("$dir"/*.zsh(N))
  [[ ${#files[@]} -eq 0 ]] && return 0

  if [[ "$use_digest" == "true" ]]; then
    compile-digest "${dir}/.digest" "${files[@]}"
  fi

  for file in "${files[@]}"; do
    source "$file"
  done
}

autoload -Uz "$ZDOTDIR/plugins/defer/zsh-defer"

fpath+=("$ZDOTDIR/completions")
fpath+=("$ZDOTDIR/plugins/completions/src")

autoload -Uz compinit
zcompdump="${ZSH_CACHE_DIR:-$HOME/.cache/zsh}/.zcompdump"

if [[ ! -f "$zcompdump" || -n ${zcompdump}(#qN.m1) ]]; then
  compinit -i -C -d "$zcompdump"
  { rm -f "${zcompdump}.zwc" && zcompile "$zcompdump" } &!
else
  compinit -C -d "$zcompdump"
fi


# ssh-agent
if [[ -f "$ZDOTDIR/plugins/ssh-agent/ssh-agent.zsh" ]]; then
  zstyle :omz:plugins:ssh-agent lazy yes
  zstyle :omz:plugins:ssh-agent quiet yes
  source-compiled "$ZDOTDIR/plugins/ssh-agent/ssh-agent.zsh"
fi

source-compiled "$ZDOTDIR/utils/setup-vimode.zsh"

source-compiled "$ZDOTDIR/utils/plugins-config/zsh-autosuggestions.zsh"
zsh-defer source-compiled "$ZDOTDIR/plugins/autosuggestions/zsh-autosuggestions.zsh"

zsh-defer source-compiled "$ZDOTDIR/plugins/syntax-highlighting/zsh-syntax-highlighting.zsh"

source-compiled "$ZDOTDIR/utils/plugins-config/fzf-tab.zsh"
zsh-defer source-compiled "$ZDOTDIR/plugins/fzf-tab/fzf-tab.zsh"

# Utils
if [[ -d "$ZDOTDIR/utils/dirstack" ]]; then
  source-directory "$ZDOTDIR/utils/dirstack" true

  if typeset -f -- _zsh_update_dir_history >/dev/null; then
    autoload -Uz add-zsh-hook
    add-zsh-hook chpwd _zsh_update_dir_history
    _zsh_update_dir_history
  fi
fi
