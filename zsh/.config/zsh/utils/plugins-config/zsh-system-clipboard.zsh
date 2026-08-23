if [[ -n "$SSH_CONNECTION" ]]; then
  export ZSH_SYSTEM_CLIPBOARD_METHOD=tmux
else
  export ZSH_SYSTEM_CLIPBOARD_METHOD=wlc
fi
