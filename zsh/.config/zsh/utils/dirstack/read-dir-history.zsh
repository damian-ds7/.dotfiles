#!/usr/bin/env zsh
# Based on dirstack navigation from romkatv/zsh4humans

() {
	emulate -L zsh

	local content
	local cache_dir=${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}

	if [[ -n $cache_dir && ! -d $cache_dir ]]; then
		mkdir -p -- $cache_dir 2>/dev/null || cache_dir=
	fi

	local file=$cache_dir/dir-history-$EUID

	if [[ -n $cache_dir && -r $file ]] && content=$(<$file); then
		typeset -ga _zsh_dir_history=(${(f)content})
	else
		typeset -ga _zsh_dir_history=()
	fi
}
