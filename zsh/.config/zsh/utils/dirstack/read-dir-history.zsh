#!/usr/bin/env zsh
# Based on dirstack navigation from romkatv/zsh4humans

local content
local file=$ZSH_CACHE_DIR/dir-history-$EUID
if [[ -r $file ]] && content=$(<$file); then
  typeset -ga _zsh_dir_history=(${(f)content})
else
  typeset -ga _zsh_dir_history=()
fi
