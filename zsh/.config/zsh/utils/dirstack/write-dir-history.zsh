#!/usr/bin/env zsh
# Based on dirstack navigation from romkatv/zsh4humans

() {
	emulate -L zsh

	local cache_dir=${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}

	if [[ -n $cache_dir && ! -d $cache_dir ]]; then
		mkdir -p -- $cache_dir 2>/dev/null || return
	fi

	[[ -n $cache_dir && -w $cache_dir ]] || return

	local file=$cache_dir/dir-history-$EUID
	local tmp=$file.tmp.$$

	{
		if print -rC1 -- $_zsh_dir_history >$tmp 2>/dev/null; then
			mv -f -- $tmp $file 2>/dev/null
		else
			rm -f -- $tmp 2>/dev/null
		fi
	} &|
}
