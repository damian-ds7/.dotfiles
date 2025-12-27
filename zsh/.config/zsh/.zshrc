# Cache Directory
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/zsh"
mkdir -p "$ZSH_CACHE_DIR"

# Zinit Setup
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# PATH Configuration
if [[ ! "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

if [[ ! "$PATH" =~ "$HOME/.cargo/bin:$HOME/bin:" ]]; then
    export PATH="$PATH:$HOME/.cargo/bin"
fi

export PATH="$PATH:/usr/local/go/bin"

# Completions Setup
if [[ ! -d "$ZDOTDIR/completions" ]]; then
  source "$ZDOTDIR/utils/setup-completions.zsh"
fi
fpath=($ZSH_CACHE_DIR/completions $fpath)
autoload -Uz compinit && compinit

# fzf
if [[ -z "$NO_FZF" ]]; then
  if ! command -v fzf >/dev/null 2>&1; then
    source "$ZDOTDIR/utils/setup-fzf.zsh"
  fi
fi

# Zinit Plugins
zinit ice depth=1; zinit light jeffreytse/zsh-vi-mode
zinit ice depth=1; zinit light zsh-users/zsh-completions
zinit ice depth=1; zinit light Aloxaf/fzf-tab
zinit ice depth=1; zinit light zsh-users/zsh-autosuggestions
zinit ice depth=1; zinit light zsh-users/zsh-syntax-highlighting

# Plugin Configuration
## Autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=40

# Oh My Posh
if [[ -z "$NO_OMP" ]]; then
  if ! command -v oh-my-posh >/dev/null 2>&1; then
    source "$ZDOTDIR/utils/setup-omp.zsh"
  fi

  if command -v oh-my-posh >/dev/null 2>&1; then
    eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/p10k.toml)"
  fi
fi

## FZF Tab
zstyle ':fzf-tab:*' fzf-bindings 'tab:accept,enter:accept'
zstyle ':fzf-tab:*' continuous-trigger '/'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath 2>/dev/null'

## Completion Styles
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:ssh:argument-1:' tag-order hosts users
zstyle ':completion:*:scp:argument-rest:' tag-order hosts files users
zstyle ':completion:*:(ssh|scp|rdp):*:hosts' hosts

# Environment Variables
export GPG_TTY=$TTY
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"
export EDITOR='nvim'
export VISUAL='nvim'
export GOPATH="$HOME/.go"
export VIRTUAL_ENV_DISABLE_PROMPT=0

# ZVM Configuration
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
ZVM_VI_EDITOR=$EDITOR
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
ZVM_SYSTEM_CLIPBOARD_ENABLED=true

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

WORDCHARS=${WORDCHARS//\//}
WORDCHARS=${WORDCHARS//-/}
WORDCHARS=${WORDCHARS//./}

# History Configuration
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
mkdir -p "$(dirname "$HISTFILE")"
DIRSTACKSIZE=1000

# Key Bindings
setup_keybindings() {
  bindkey '^ ' autosuggest-accept
  bindkey '^Y' forward-word
  bindkey '^[l' clear-screen

  # Directory stack navigation
  bindkey -M viins '^[[1;3D' cd-back     # Alt+Left
  bindkey -M viins '^[[1;3C' cd-forward  # Alt+Right
  bindkey -M viins '^[^H' cd-back     # Alt+Left
  bindkey -M viins '^[^L' cd-forward  # Alt+Right
  bindkey -M vicmd 'H' cd-back
  bindkey -M vicmd 'L' cd-forward
  bindkey -M visual 'H' cd-back
  bindkey -M visual 'L' cd-forward

  bindkey -M vicmd '^M' accept-line-in-insert
}

# Functions
autoload -Uz zmv

function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Custom widget that switches to insert mode before accepting line
# Fixes the issue with OMP transient prompt not working when command
# is run in normal mode
function accept-line-in-insert() {
  zle accept-line
  zvm_select_vi_mode $ZVM_MODE_INSERT
}
zle -N accept-line-in-insert

# External Tool Initialization
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Source External Files
# SSH Teleportation
if [[ -f "$ZDOTDIR/utils/ssh/ssh-wrapper.zsh" ]]; then
  source "$ZDOTDIR/utils/ssh/ssh-wrapper.zsh"
fi

## Aliases
[[ -f $ZDOTDIR/utils/aliases.zsh ]] && source $ZDOTDIR/utils/aliases.zsh

## Directory Stack Navigation
[[ -f $ZDOTDIR/utils/dirstack/nav.zsh ]] && source $ZDOTDIR/utils/dirstack/nav.zsh

# Directory history persistence
if [[ -f $ZDOTDIR/utils/dirstack/update-dir-history.zsh ]]; then
  source $ZDOTDIR/utils/dirstack/update-dir-history.zsh
  autoload -Uz add-zsh-hook
  add-zsh-hook chpwd -zsh-update-dir-history
  -zsh-update-dir-history
fi

. "$HOME/.cargo/env" 2>/dev/null

# Post-Init Hooks
function zvm_after_init() {
  if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
  fi

  setup_keybindings
}

# OMP zsh-vi-mode integration
_omp_redraw-prompt() {
  local precmd
  for precmd in "${precmd_functions[@]}"; do
    "$precmd"
  done

  zle .reset-prompt
}

export POSH_VI_MODE="insert"

function zvm_after_select_vi_mode() {
  case $ZVM_MODE in
  $ZVM_MODE_NORMAL)
    POSH_VI_MODE="command"
    ;;
  $ZVM_MODE_INSERT)
    POSH_VI_MODE="insert"
    ;;
  $ZVM_MODE_VISUAL)
    POSH_VI_MODE="visual"
    ;;
  $ZVM_MODE_VISUAL_LINE)
    POSH_VI_MODE="visual"
    ;;
  $ZVM_MODE_REPLACE)
    POSH_VI_MODE="insert"
    ;;
  esac
  _omp_redraw-prompt
}
