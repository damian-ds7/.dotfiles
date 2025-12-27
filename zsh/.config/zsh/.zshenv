case ":$PATH:" in
  *:$HOME/.local/bin:*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

if [ -z "${SSH_TELEPORT:-}" ] && ! command -v zsh >/dev/null 2>&1; then
  _zsh_tmp="${TMPDIR:-/tmp}/install-zsh.$$"

  _install_cmd=""
  if command -v curl >/dev/null 2>&1; then
    _install_cmd="curl -fsSL \"https://raw.githubusercontent.com/romkatv/zsh-bin/master/install\" -o \"$_zsh_tmp\" && sh \"$_zsh_tmp\" -d \"$HOME/.local\" -e no"
  elif command -v wget >/dev/null 2>&1; then
    _install_cmd="wget -qO \"$_zsh_tmp\" \"https://raw.githubusercontent.com/romkatv/zsh-bin/master/install\" && sh \"$_zsh_tmp\" -d \"$HOME/.local\" -e no"
  fi

  if [ -n "$_install_cmd" ]; then
    >&2 printf '\033[33mzsh\033[0m: installing to ~/.local/bin\n'
    sh -c "$_install_cmd"
    if command -v zsh >/dev/null 2>&1; then
      >&2 printf '\033[32mzsh\033[0m: installed successfully\n'
    fi
  fi

  rm -f "$_zsh_tmp" 2>/dev/null
  unset _install_cmd
fi

if [ -n "${ZSH_VERSION-}" ] && [ ! -f "$HOME/.config/zsh/.shell-changed" ]; then
  _current_shell="${SHELL:-/bin/sh}"
  _zsh_path="$(command -v zsh 2>/dev/null)"

  if [ -n "$_zsh_path" ] && [ "$_current_shell" != "$_zsh_path" ]; then
    _mark_shell_changed() {
      mkdir -p "$HOME/.config/zsh" 2>/dev/null
      touch "$HOME/.config/zsh/.shell-changed"
    }

    _change_shell() {
      if command -v chsh >/dev/null 2>&1; then
        if chsh -s "$_zsh_path" 2>/dev/null; then
          return 0
        else
          return 1
        fi
      else
        return 2  # chsh not available
      fi
    }

    if command -v gum >/dev/null 2>&1; then
      gum style --foreground 220 "Current login shell: $_current_shell"

      if gum confirm "Change login shell to zsh?"; then
        _change_shell
        case $? in
          0)
            gum style --foreground 212 "Login shell changed to $_zsh_path"
            _mark_shell_changed
            ;;
          1)
            gum style --foreground 196 "Failed to change shell. You may need to run: chsh -s $_zsh_path"
            ;;
          2)
            gum style --foreground 220 "chsh not available. Contact your system administrator."
            ;;
        esac
      else
        gum style "Keeping current shell. Change later with: chsh -s $_zsh_path"
        _mark_shell_changed
      fi
    else
      >&2 printf '\033[33mzsh\033[0m: Current login shell is %s\n' "$_current_shell"
      >&2 printf 'Change login shell to zsh? [y/N] '
      read -r _answer

      case "$_answer" in
        [Yy]*)
          _change_shell
          case $? in
            0)
              >&2 printf '\033[32mzsh\033[0m: Login shell changed to %s\n' "$_zsh_path"
              _mark_shell_changed
              ;;
            1)
              >&2 printf '\033[31mzsh\033[0m: Failed to change shell. You may need to run: chsh -s %s\n' "$_zsh_path"
              ;;
            2)
              >&2 printf '\033[33mzsh\033[0m: chsh not available. Contact your system administrator.\n'
              ;;
          esac
          ;;
        *)
          >&2 printf 'Keeping current shell. You can change it later with: chsh -s %s\n' "$_zsh_path"
          _mark_shell_changed
          ;;
      esac

      unset _answer
    fi

    unset -f _mark_shell_changed _change_shell
  fi

  unset _current_shell _zsh_path
fi
