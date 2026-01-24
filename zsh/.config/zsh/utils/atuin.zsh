#!/usr/bin/env zsh

export ATUIN_NOBIND="true"
eval "$(atuin init zsh)"

bindkey -M vicmd '^r' atuin-search-vicmd

# Smart Up/Down:
# - If BUFFER is empty -> Atuin (atuin-up-search / atuin-search)
# - If BUFFER not empty -> zsh-history-substring-search (up/down)
# - If substring widgets don't exist -> use Atuin everywhere

# Treat whitespace-only as empty too
__buffer_has_text() {
  [[ -n ${${BUFFER}//[[:space:]]/} ]]
}

typeset -g __HAS_SUBSTRING=0
if (( $+widgets[history-substring-search-up] && $+widgets[history-substring-search-down] )); then
  __HAS_SUBSTRING=1
fi

typeset -g __ATUIN_UP_EMACS="atuin-up-search"
typeset -g __ATUIN_UP_VIINS="atuin-up-search-viins"
typeset -g __ATUIN_UP_VICMD="atuin-up-search-vicmd"

__smart_up_emacs() {
  if (( __HAS_SUBSTRING )) && __buffer_has_text; then
    zle history-substring-search-up
  else
    zle $__ATUIN_UP_EMACS
  fi
}

__smart_up_viins() {
  if (( __HAS_SUBSTRING )) && __buffer_has_text; then
    zle history-substring-search-up
  else
    zle $__ATUIN_UP_VIINS
  fi
}

__smart_up_vicmd() {
  if (( __HAS_SUBSTRING )) && __buffer_has_text; then
    zle history-substring-search-up
  else
    zle $__ATUIN_UP_VICMD
  fi
}

__smart_down_emacs() {
  if (( __HAS_SUBSTRING )) && __buffer_has_text; then
    zle history-substring-search-down
  else
    zle down-line-or-history
  fi
}

__smart_down_viins() {
  if (( __HAS_SUBSTRING )) && __buffer_has_text; then
    zle history-substring-search-down
  else
    zle down-line-or-history
  fi
}

__smart_down_vicmd() {
  if (( __HAS_SUBSTRING )) && __buffer_has_text; then
    zle history-substring-search-down
  else
    zle down-line-or-history
  fi
}

zle -N __smart_up_emacs
zle -N __smart_up_viins
zle -N __smart_up_vicmd
zle -N __smart_down_emacs
zle -N __smart_down_viins
zle -N __smart_down_vicmd

bindkey -M emacs '^[[A' __smart_up_emacs
bindkey -M emacs '^[[B' __smart_down_emacs

bindkey -M viins '^[[A' __smart_up_viins
bindkey -M viins '^[[B' __smart_down_viins

bindkey -M vicmd '^[[A' __smart_up_vicmd
bindkey -M vicmd '^[[B' __smart_down_vicmd
bindkey -M vicmd 'k' __smart_up_vicmd
bindkey -M vicmd 'j' __smart_down_vicmd
