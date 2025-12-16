# Zinit Setup
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Completions Setup
if [[ ! -d "$ZDOTDIR/completions" ]]; then
  source "$ZDOTDIR/setup-completions.sh"
fi
fpath=($ZDOTDIR/completions $fpath)
autoload -Uz compinit && compinit

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
eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/p10k.toml)"

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

# PATH Configuration
if [[ ! "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

export PATH="$PATH:/usr/local/go/bin"

# ZVM Configuration
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
ZVM_VI_EDITOR=$EDITOR
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

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

# History Configuration
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
mkdir -p "$(dirname "$HISTFILE")"

# Key Bindings
setup_keybindings() {
  bindkey '^ ' autosuggest-accept
  bindkey '^Y' forward-word
  bindkey '^[l' clear-screen
}

setup_keybindings

# Functions
autoload -Uz zmv

function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# External Tool Initialization
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Source External Files
## Aliases
[[ -f $HOME/.config/zsh/aliases.sh ]] && source $HOME/.config/zsh/aliases.sh

. "$HOME/.cargo/env" 2>/dev/null

# Post-Init Hooks
function zvm_after_init() {
  if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
  fi

  setup_keybindings
}
