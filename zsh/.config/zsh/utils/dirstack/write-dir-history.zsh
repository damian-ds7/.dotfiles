#!/usr/bin/env zsh
# Based on dirstack navigation from romkatv/zsh4humans

local file=$ZSH_CACHE_DIR/dir-history-$EUID
local tmp=$file.tmp.$$

{
  print -rC1 -- $_zsh_dir_history >$tmp && mv -f -- $tmp $file
} &!
