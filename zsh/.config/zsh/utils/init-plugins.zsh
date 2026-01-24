#!/usr/bin/env zsh

SKIP_PLUGINS_FILE="${ZSH_CACHE_DIR:-$HOME/.cache}/zsh/skip-plugins"
[[ -f "$SKIP_PLUGINS_FILE" ]] && return 0

function zcompile-many() {
  local f
  setopt localoptions nullglob
  for f in "$@"; do
    if [[ -f "$f" ]]; then
      if [[ ! -f "${f}.zwc" || "$f" -nt "${f}.zwc" ]]; then
        zcompile "${f}.zwc" "$f" 2>/dev/null || true
      fi
    fi
  done
}

zcompile-many "$ZDOTDIR"/plugins/syntax-highlighting/zsh-syntax-highlighting.zsh \
              "$ZDOTDIR"/plugins/syntax-highlighting/highlighters/*/*.zsh

zcompile-many "$ZDOTDIR"/plugins/autosuggestions/zsh-autosuggestions.zsh \
              "$ZDOTDIR"/plugins/autosuggestions/src/**/*.zsh

zcompile-many "$ZDOTDIR/plugins/powerlevel10k/powerlevel10k.zsh-theme" \
              "$ZDOTDIR/plugins/ssh-agent/ssh-agent.zsh" \
              "$ZDOTDIR/plugins/conventional-commits/conventional-commits.zsh" \
              "$ZDOTDIR/utils/setup-vimode.zsh" \
              "$ZDOTDIR/plugins/fzf-tab/fzf-tab.zsh" \
              "$ZDOTDIR/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" \


autoload -Uz "$ZDOTDIR/plugins/defer/zsh-defer"

fpath+=("$ZDOTDIR/completions")
fpath+=("$ZDOTDIR/plugins/completions/src")

autoload -Uz compinit
zcompdump="${ZSH_CACHE_DIR:-$HOME/.cache/zsh}/.zcompdump"
compinit -d "$zcompdump"
[[ "$zcompdump".zwc -nt "$zcompdump" ]] || zcompile-many "$zcompdump"

source "$ZDOTDIR/plugins/powerlevel10k/powerlevel10k.zsh-theme"

# ssh-agent
zstyle :omz:plugins:ssh-agent lazy yes
zstyle :omz:plugins:ssh-agent quiet yes
source "$ZDOTDIR/plugins/ssh-agent/ssh-agent.zsh"

source "$ZDOTDIR/plugins/conventional-commits/conventional-commits.zsh"
source "$ZDOTDIR/utils/setup-vimode.zsh"

source "$ZDOTDIR/plugins/fzf-tab/fzf-tab.zsh"
source "$ZDOTDIR/utils/plugins-config/fzf-tab.zsh"

source "$ZDOTDIR/plugins/fzf-git/fzf-git.sh"
source "$ZDOTDIR/utils/plugins-config/fzf-git.zsh"

source "$ZDOTDIR/utils/plugins-config/zsh-autosuggestions.zsh"
zsh-defer source "$ZDOTDIR/plugins/autosuggestions/zsh-autosuggestions.zsh"

zsh-defer source "$ZDOTDIR/plugins/syntax-highlighting/zsh-syntax-highlighting.zsh"

source "$ZDOTDIR/utils/plugins-config/zsh-history-substring-search.zsh"
source "$ZDOTDIR/plugins/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh" 

if [[ -d "$ZDOTDIR/utils/dirstack" ]]; then
  zcompile-many "$ZDOTDIR/utils/dirstack/**/*.zsh" true

  source "$ZDOTDIR/utils/dirstack/nav.zsh"
  source "$ZDOTDIR/utils/dirstack/read-dir-history.zsh"
  source "$ZDOTDIR/utils/dirstack/update-dir-history.zsh"
  source "$ZDOTDIR/utils/dirstack/write-dir-history.zsh"

  if typeset -f -- _zsh_update_dir_history >/dev/null; then
    autoload -Uz add-zsh-hook
    add-zsh-hook chpwd _zsh_update_dir_history
    _zsh_update_dir_history
  fi
fi
