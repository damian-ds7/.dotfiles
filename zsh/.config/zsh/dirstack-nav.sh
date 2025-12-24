#!/usr/bin/env zsh
# Directory stack navigation (ported from zsh4humans)

# Usage: -cd-rotate +1  (go back)
#        -cd-rotate -0  (go forward)
function -cd-rotate() {
  emulate -L zsh -o extended_glob

  while (( $#dirstack )) && ! pushd -q $1 &>/dev/null; do
    popd -q $1
  done

  if (( $#dirstack )); then
    if typeset -f _omp_redraw-prompt >/dev/null 2>&1; then
      _omp_redraw-prompt
    else
      zle && zle .reset-prompt
    fi
    return 0
  fi

  return 1
}

function cd-back() {
  -cd-rotate +1
}

function cd-forward() {
  -cd-rotate -0
}

zle -N cd-back
zle -N cd-forward
