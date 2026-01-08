#!/usr/bin/env zsh
# Directory stack navigation (ported from zsh4humans)

function redraw-prompt() {
  local f
  for f in chpwd "${chpwd_functions[@]}" precmd "${precmd_functions[@]}"; do
    [[ "${+functions[$f]}" == 0 ]] || "$f" &>/dev/null || true
  done
  p10k display -r
}

function -cd-rotate() {
  () {
    emulate -L zsh
    while (( $#dirstack )) && ! builtin pushd -q $1 &>/dev/null; do
      builtin popd -q $1
    done
    (( $#dirstack ))
  } "$@" && redraw-prompt
}

setopt autopushd

function cd-back() {
  -cd-rotate +1
}

function cd-forward() {
  -cd-rotate -0
}

zle -N cd-back
zle -N cd-forward
