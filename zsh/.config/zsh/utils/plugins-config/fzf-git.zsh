if [[ $__fzf_git_fzf ]]; then
  eval "$__fzf_git_fzf"
else
  _fzf_git_fzf() {
    fzf --height 50% \
      --layout reverse --multi --min-height 20+ --border \
      --no-separator --header-border horizontal \
      --border-label-pos 2 \
      --color 'label:blue' \
      --preview-window 'right,50%' --preview-border line \
      --bind 'ctrl-/:change-preview-window(down,50%|hidden|)' "$@"
  }
fi
