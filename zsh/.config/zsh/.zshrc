if [[ -n "$ZSH_PROFILE" ]]; then
  zmodload zsh/zprof
fi

# Cache Directory
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/zsh"
mkdir -p "$ZSH_CACHE_DIR"

# Environment Variables
export GPG_TTY=$TTY
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"
export EDITOR='nvim'
export VISUAL='nvim'
export GOPATH="$HOME/.go"
export VIRTUAL_ENV_DISABLE_PROMPT=0

# PATH Configuration
if [[ ! "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

if [[ ! "$PATH" =~ "$HOME/.cargo/bin:$HOME/bin:" ]]; then
    export PATH="$PATH:$HOME/.cargo/bin"
fi

export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"

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

## OMP
if [[ -z "$NO_OMP" ]]; then
  if ! command -v oh-my-posh >/dev/null 2>&1; then
    source "$ZDOTDIR/utils/setup-omp.zsh"
  fi
fi

# Plugin Initialization
source "$ZDOTDIR/utils/init-plugins.zsh"

# Oh My Posh
if [[ -z "$NO_OMP" ]]; then
  if command -v oh-my-posh >/dev/null 2>&1; then
    export SHOULD_NEWLINE=false
    eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/p10k.toml)"

    _set_should_newline() {
      export SHOULD_NEWLINE=true
    }
    autoload -Uz add-zsh-hook
    add-zsh-hook preexec _set_should_newline

    _redraw_prompt() {
      local precmd
      for precmd in "${precmd_functions[@]}"; do
        "$precmd"
      done

      zle .reset-prompt
    }
  fi
fi

# Theme detection for Oh My Posh
THEME_MODE_FILE="${HOME}/.config/themes/mode"
if [[ -f "$THEME_MODE_FILE" ]]; then
  export THEME_MODE="$(cat "$THEME_MODE_FILE")"
else
  export THEME_MODE="dark"
fi

update_theme_mode() {
  if [[ -f "$THEME_MODE_FILE" ]]; then
    local new_mode="$(cat "$THEME_MODE_FILE")"
    if [[ "$new_mode" != "$THEME_MODE" ]]; then
      export THEME_MODE="$new_mode"
    fi
  fi
}

TRAPUSR1() {
  update_theme_mode
  _redraw_prompt
}

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

function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
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

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

# Source External Files
## Aliases
[[ -f $ZDOTDIR/utils/aliases.zsh ]] && source $ZDOTDIR/utils/aliases.zsh
[[ -f $ZDOTDIR/utils/custom-git-bindings.zsh ]] && source $ZDOTDIR/utils/custom-git-bindings.zsh

. "$HOME/.cargo/env" 2>/dev/null

if [[ -n "$ZSH_PROFILE" ]]; then
  zprof
fi
