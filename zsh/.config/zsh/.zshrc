if [[ -n "$ZSH_PROFILE" ]]; then
  zmodload zsh/zprof
fi

(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv export zsh)"

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv hook zsh)"

# History Configuration
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
mkdir -p "$(dirname "$HISTFILE")"
DIRSTACKSIZE=1000

# Check deps
## fzf
if [[ -z "$NO_FZF" ]]; then
  if ! command -v fzf >/dev/null 2>&1; then
    source "$ZDOTDIR/utils/setup-fzf.zsh"
  fi
fi

# Plugin Initialization
source "$ZDOTDIR/utils/init-plugins.zsh"

# Shell Options
setopt glob_dots
setopt no_auto_menu
setopt nullglob
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt share_history
setopt append_history
setopt inc_append_history
setopt interactivecomments

WORDCHARS=${WORDCHARS//\//}
WORDCHARS=${WORDCHARS//-/}
WORDCHARS=${WORDCHARS//./}

# Binds
bindkey '^ ' autosuggest-accept
bindkey '^Y' forward-word
bindkey '^[ ' autosuggest-accept
bindkey '^[y' forward-word
bindkey '^Z' fancy-ctrl-z
bindkey '^[l' clear-screen
bindkey '^_' undo
bindkey ' ' magic-space
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^F' open-yazi

# Directory stack navigation
bindkey -M viins '^[[1;3D' cd-back     # Alt+Left
bindkey -M viins '^[[1;3C' cd-forward  # Alt+Right
bindkey -M viins '^[^H' cd-back        # Ctrl+Alt+Shift+H
bindkey -M viins '^[^L' cd-forward     # Ctrl+Alt+Shift+L
bindkey -M vicmd 'H' cd-back
bindkey -M vicmd 'L' cd-forward
bindkey -M visual 'H' cd-back
bindkey -M visual 'L' cd-forward

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Functions
autoload -Uz zmv

function md() { 
    [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1"
}
compdef _directories md

function fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line -w
  else
    zle push-input -w
    zle clear-screen -w
  fi
}
zle -N fancy-ctrl-z

function open-yazi() {
  if command -v yazi >/dev/null 2>&1; then
    yazi
    zle redisplay
  fi
}
zle -N open-yazi

# External Tool Initialization
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

if command -v atuin >/dev/null 2>&1; then
  source "$ZDOTDIR/utils/atuin.zsh"
fi

# Source External Files
## Aliases
[[ -f $ZDOTDIR/utils/aliases.zsh ]] && source "$ZDOTDIR/utils/aliases.zsh"


# Theme detection
THEME_MODE="$(cat "$THEME_MODE_FILE" 2>/dev/null || echo "dark")"
export THEME_MODE

update_theme_mode() {
  if [[ -f "$THEME_MODE_FILE" ]]; then
    local new_mode
    new_mode="$(cat "$THEME_MODE_FILE")"
    if [[ "$new_mode" != "$THEME_MODE" ]]; then
      export THEME_MODE="$new_mode"
    fi
  fi
}

TRAPUSR1() {
  update_theme_mode
  [[ ! -f "$ZDOTDIR/.p10k.zsh" ]] || source "$ZDOTDIR/.p10k.zsh"
}

[[ ! -f "$ZDOTDIR/.p10k.zsh" ]] || source "$ZDOTDIR/.p10k.zsh"

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

if [[ -n "$ZSH_PROFILE" ]]; then
  zprof
fi

