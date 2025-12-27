#!/usr/bin/env zsh

zstyle ':fzf-tab:*' fzf-bindings 'tab:accept,enter:accept'
zstyle ':fzf-tab:*' continuous-trigger '/'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath 2>/dev/null'
