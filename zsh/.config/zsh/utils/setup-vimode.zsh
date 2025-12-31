#!/usr/bin/env zsh

bindkey -v

export POSH_VI_MODE="insert"

bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char
bindkey -M viins '^W' backward-kill-word
bindkey -M viins 'jk' vi-cmd-mode

function enter-visual-mode() {
  zle visual-mode
  POSH_VI_MODE="visual"
  _redraw_prompt
}
zle -N enter-visual-mode

function exit-visual-mode() {
  zle deactivate-region
  POSH_VI_MODE="command"
  _redraw_prompt
}
zle -N exit-visual-mode

bindkey -M vicmd 'v' enter-visual-mode
bindkey -M visual 'v' exit-visual-mode
bindkey -M visual '^[' exit-visual-mode

# Text Objects: ci', ci", ci`, etc.
autoload -U select-quoted
zle -N select-quoted
quotes=(\' \" \`)
for m in visual viopp; do
  for c in a i; do
    for q in ${quotes[@]}; do
      bindkey -M $m "$c$q" select-quoted
    done
  done
done

# Text Objects: ci{, ci(, ci<, di{, etc.
autoload -U select-bracketed
zle -N select-bracketed
brackets=(\( \) \{ \} \[ \] \< \>)
for m in visual viopp; do
  for c in a i; do
    for b in ${brackets[@]}; do
       bindkey -M $m "$c$b" select-bracketed
    done
  done
done

# Reset to insert mode before each prompt (handles Ctrl+C, after command, etc.)
function _reset_vimode_precmd() {
  if [[ -z "${ZLE_STATE:-}" ]]; then
    POSH_VI_MODE="insert"
    echo -ne '\e[6 q'
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _reset_vimode_precmd

function zle-keymap-select() {
  case "${KEYMAP}" in
    vicmd)
      echo -ne '\e[2 q'  # Block cursor
      POSH_VI_MODE="command"
      ;;
    viins|main)
      echo -ne '\e[6 q'  # Beam cursor
      POSH_VI_MODE="insert"
      ;;
  esac
  _redraw_prompt
}
zle -N zle-keymap-select
