if [[ -n "$ZSH_PROFILE" ]]; then
  zmodload zsh/zprof
fi

((${+commands[direnv]})) && emulate zsh -c "$(direnv export zsh)"

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

((${+commands[direnv]})) && emulate zsh -c "$(direnv hook zsh)"

# History Configuration
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
HISTSIZE=10000
mkdir -p "$(dirname "$HISTFILE")"
export DIRSTACKSIZE=1000

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
WORDCHARS=${WORDCHARS//./}

# Accept forward, but a leading punctuation run "sticks" to the word AFTER it
custom-forward-word() {
  local rest=$RBUFFER
  if [[ $rest =~ '^[[:space:]]+' ]]; then
    CURSOR+=${#MATCH}
    rest=${rest[${#MATCH}+1,-1]}
  fi
  if [[ $rest =~ '^[^[:alnum:][:space:]]*[[:alnum:]]+' ]]; then
    CURSOR+=${#MATCH}
  else
    zle .forward-word
  fi
}
zle -N custom-forward-word
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(custom-forward-word)

# Delete backward, removing the trailing alnum run together with any
# punctuation run directly in front of it
custom-backward-kill-word() {
  local left=$LBUFFER
  local trimmed=0
  if [[ $left =~ '[[:space:]]+$' ]]; then
    trimmed=${#MATCH}
    left=${left[1,-1-trimmed]}
  fi

  if [[ $left =~ '[^[:alnum:][:space:]]*[[:alnum:]]+$' ]]; then
    local total=$((trimmed + ${#MATCH}))
    local newcursor=$((CURSOR - total))
    BUFFER=${LBUFFER[1,-1-total]}$RBUFFER
    CURSOR=$newcursor
  elif [[ $left =~ '[^[:alnum:][:space:]]+$' ]]; then
    local total=$((trimmed + ${#MATCH}))
    local newcursor=$((CURSOR - total))
    BUFFER=${LBUFFER[1,-1-total]}$RBUFFER
    CURSOR=$newcursor
  else
    zle .backward-kill-word
  fi
}
zle -N custom-backward-kill-word

# Binds
bindkey '^ ' autosuggest-accept
bindkey '^Y' custom-forward-word
bindkey '^[ ' autosuggest-accept
bindkey '^[y' custom-forward-word
bindkey '^Z' fancy-ctrl-z
bindkey '^[l' clear-screen
bindkey '^_' undo
bindkey ' ' magic-space
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^W' custom-backward-kill-word

# Directory stack navigation
bindkey -M viins '^[[1;3D' cd-back    # Alt+Left
bindkey -M viins '^[[1;3C' cd-forward # Alt+Right
bindkey -M viins '^[^H' cd-back       # Ctrl+Alt+Shift+H
bindkey -M viins '^[^L' cd-forward    # Ctrl+Alt+Shift+L
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

function fancy-ctrl-z() {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line -w
  else
    zle push-input -w
    zle clear-screen -w
  fi
}
zle -N fancy-ctrl-z

# External Tool Initialization
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

if command -v nvs >/dev/null 2>&1; then
  eval "$(nvs env --source)"
fi

if command -v atuin >/dev/null 2>&1; then
  source "$ZDOTDIR/utils/atuin.zsh"
fi

# Source External Files
## Aliases
[[ -f $HOME/.config/shell/aliases.sh ]] && source "$HOME/.config/shell/aliases.sh"
[[ -f $ZDOTDIR/utils/zsh-aliases.zsh ]] && source "$ZDOTDIR/utils/zsh-aliases.zsh"

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

if [[ -n "$ZSH_PROFILE" ]]; then
  zprof
fi
