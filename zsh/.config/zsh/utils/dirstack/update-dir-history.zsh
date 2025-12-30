#!/usr/bin/env zsh
# Based on dirstack navigation from romkatv/zsh4humans

function _zsh_update_dir_history() {
  if (( ${+_zsh_dir_hist_fd} )); then
    zle -F "$_zsh_dir_hist_fd" 2>/dev/null
    exec {_zsh_dir_hist_fd}>&- 2>/dev/null
    unset _zsh_dir_hist_fd
  fi

  local dir
  zstyle -s :zsh:dir-history: cwd dir || dir=${(%):-%~}
  [[ -z $dir || $dir == ${_zsh_last_dir-} ]] && return

  typeset -g _zsh_last_dir=$dir
  [[ $dir != ('~'|/)* ]] && return

  source $ZDOTDIR/utils/dirstack/read-dir-history.zsh || return

  if (( ! $#dirstack && (DIRSTACKSIZE || ! $+DIRSTACKSIZE) )); then
    local d stack=()
    for d in $_zsh_dir_history; do
      {
        if [[ ($#stack -ne 0 || $d != $dir) ]]; then
          d=${~d}
          if [[ -d ${d::=${(g:oce:)d}} ]]; then
            stack+=($d)
            (( $+DIRSTACKSIZE && $#stack >= DIRSTACKSIZE - 1 )) && break
          fi
        fi
      } always {
        TRY_BLOCK_ERROR=0
      }
    done 2>/dev/null
    dirstack=($stack)
  fi

  local -i pos=$_zsh_dir_history[(ie)$dir]
  _zsh_dir_history[pos]=()
  _zsh_dir_history[1,0]=($dir)

  local max_size
  zstyle -s :zsh:dir-history: max-size max_size
  if [[ $max_size != -<-> ]]; then
    [[ $max_size == <-> ]] || max_size=10000
    local -i drop=$(($#_zsh_dir_history - max_size))
    if (( drop > 0 )); then
      _zsh_dir_history[-drop,-1]=()
    fi
  fi

  source $ZDOTDIR/utils/dirstack/write-dir-history.zsh
}
