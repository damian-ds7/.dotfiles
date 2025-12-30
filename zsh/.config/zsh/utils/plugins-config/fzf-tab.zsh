#!/usr/bin/env zsh

# Core completion styles (must be set after compinit)
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:ssh:argument-1:' tag-order hosts users
zstyle ':completion:*:scp:argument-rest:' tag-order hosts files users
zstyle ':completion:*:(ssh|scp|rdp):*:hosts' hosts

# fzf-tab specific styles
zstyle ':fzf-tab:*' fzf-bindings 'tab:accept,enter:accept'
zstyle ':fzf-tab:*' continuous-trigger '/'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath 2>/dev/null'
