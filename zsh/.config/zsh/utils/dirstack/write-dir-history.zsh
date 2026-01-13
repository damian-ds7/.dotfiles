#!/usr/bin/env zsh
# Based on dirstack navigation from romkatv/zsh4humans

() {
  emulate -L zsh

  local file=$ZSH_CACHE_DIR/dir-history-$EUID
  local tmp=$file.tmp.$$

  {
    if print -rC1 -- $_zsh_dir_history >$tmp 2>/dev/null; then
      mv -f -- $tmp $file 2>/dev/null
    else
      rm -f -- $tmp 2>/dev/null
    fi
  } &!
}
