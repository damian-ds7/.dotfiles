_fzf_git_custom_tab_widget() {
  local -a lwords=(${(z)LBUFFER})
  if [[ $LBUFFER[-1] != ' ' && ${#lwords} -gt 0 && ${lwords[-1]} == -* ]]; then
    zle fzf-tab-complete
    return
  fi

  # If completing after a command without a space, insert one first.
  if [[ $LBUFFER[-1] != ' ' ]]; then
    LBUFFER+=" "
  fi

  local -a words
  words=(${(z)BUFFER})

  if (( ! #words )); then
    zle fzf-tab-complete
    return
  fi

  local cmd_word=${words[1]}

  integer i=0
  while [[ -n ${aliases[$cmd_word]} && $i -lt 10 ]]; do
    local -a expanded_alias
    expanded_alias=(${(z)aliases[$cmd_word]})
    words=(${expanded_alias[@]} ${words[2,-1]})
    cmd_word=${words[1]}
    (( i++ ))
  done

  local canonical_buffer="${words[@]}"

  case $canonical_buffer in
    "git checkout"|"git checkout "*|"git switch"|"git switch "*)
      fzf-git-branches-widget
      ;;
    "git rebase"|"git rebase "*)
      fzf-git-each_ref-widget
      ;;
    "git reset"|"git reset "*|"git show"|"git show "*)
      fzf-git-hashes-widget
      ;;
    "git add"|"git add "*|"git diff"|"git diff "*)
      fzf-git-files-widget
      ;;
    "git stash"|"git stash "*)
      fzf-git-stashes-widget
      ;;
    "git remote"|"git remote "*)
      fzf-git-remotes-widget
      ;;
    "git tag"|"git tag "*)
      fzf-git-tags-widget
      ;;
    *)
      zle fzf-tab-complete
      ;;
  esac
}

zle -N fzf-git-custom-tab-widget _fzf_git_custom_tab_widget

bindkey '^I' fzf-git-custom-tab-widget

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
