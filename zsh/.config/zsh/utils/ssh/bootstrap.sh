#!/bin/sh

if '[' '-n' "${ZSH_VERSION-}" ']'; then
  'emulate' 'sh' '-o' 'no_aliases' '-o' 'no_glob'
else
  'set' '-f'
fi

_teleport_bypass=''

for _teleport_cmd in 'tar' 'tail' 'rm' 'mkdir' 'mv' 'cp' 'wc' 'cat' 'uname' 'tr' 'chmod'; do
  if ! command -v "$_teleport_cmd" >'/dev/null' 2>&1; then
    _teleport_bypass='1'
    'break'
  fi
done

if '[' '-z' "$_teleport_bypass" ']'; then
  {
    _teleport_platform="$('command' 'uname' '-sm')" &&
      _teleport_platform="$('printf' '%s' "$_teleport_platform" | 'command' 'tr' '[A-Z]' '[a-z]')" ||
      _teleport_platform=''
  } 2>'/dev/null'

  case "$_teleport_platform" in
  'darwin arm64') ;;
  'darwin x86_64') ;;
  'linux aarch64') ;;
  'linux armv6l') ;;
  'linux armv7l') ;;
  'linux armv8l') ;;
  'linux x86_64') ;;
  'linux i686') ;;
  *) _teleport_bypass='1' ;;
  esac
fi

if '[' '-n' "$_teleport_bypass" ']'; then
  command -v 'rm' >'/dev/null' 2>&1 && 'command' 'rm' '-f' '--' "$0"

  export TERM=^TERM^

  if '[' '-x' "${SHELL-}" ']'; then
    case "/$SHELL" in
    */'bash')
      'exec' "$SHELL" '-l'
      'exit'
      ;;
    */'zsh')
      'exec' "$SHELL" '-l'
      'exit'
      ;;
    */'ksh')
      'exec' "$SHELL" '-l'
      'exit'
      ;;
    */'dash')
      'exec' "$SHELL" '-l'
      'exit'
      ;;
    esac
  fi

  'printf' '\001teleport.%s%s' ^DUMP_MARKER^ 'bypass          '
  'exit'
fi

'set' '--' "$0"

_teleport_error() {
  >&2 'printf' '\n'
  >&2 'printf' '\033[33mssh-teleport\033[0m: failed to start \033[32mzsh\033[0m on \033[1m%s\033[0m\n' ^SSH_HOST^
  >&2 'printf' '\n'
  >&2 'printf' 'See error messages above to identify the culprit.\n'
  >&2 'printf' '\n'
  >&2 'printf' 'Disable teleportation for \033[1m%s\033[0m:\n' ^SSH_HOST^
  >&2 'printf' '\n'
  >&2 'printf' '  \033[32mzstyle\033[0m \033[33m'\'':ssh-teleport:%s'\''\033[0m enable no\n' ^SSH_HOST^
  >&2 'printf' '\n'
  >&2 'printf' 'Or use regular SSH:\n'
  >&2 'printf' '\n'
  >&2 'printf' '  \033[32mNO_SSH_TELEPORT=1 ssh\033[0m %s\n' ^SSH_HOST^
  >&2 'printf' '\n'
}

_teleport_mktemp() {
  if '[' '-n' "${TMPDIR-}" '-a' '(' '(' '-d' "${TMPDIR-}" '-a' '-w' "${TMPDIR-}" ')' '-o' \
    '!' '(' '-d' '/tmp' '-a' '-w' '/tmp' ')' ')' ']'; then
    'set' '--' "$TMPDIR"
  else
    'set' '--' '/tmp'
  fi

  if command -v 'mktemp' >'/dev/null' 2>&1; then
    _teleport_tmp="$('command' 'mktemp' '-d' -- "$1"/ssh-teleport.XXXXXXXXXX)"
  else
    _teleport_tmp="$1"/ssh-teleport.tmp."$$"
    '[' '!' '-e' "$_teleport_tmp" ']' || 'command' 'rm' '-rf' '--' "$_teleport_tmp" || 'exit'
    'command' 'mkdir' '-p' '--' "$_teleport_tmp" || 'exit'
  fi
}

_teleport_cleanup='"trap" "-" "HUP" "INT" "TERM" "EXIT"; "command" "rm" "-rf" "--" "$@" 2>"/dev/null"'
'trap' "$_teleport_cleanup; 'exit' '129'" 'HUP'
'trap' "$_teleport_cleanup; 'exit' '130'" 'INT'
'trap' "$_teleport_cleanup; 'exit' '143'" 'TERM'

_teleport_mktemp || 'exit'
'trap' "$_teleport_cleanup "'$_teleport_tmp'"; 'exit'" 'EXIT'

'printf' 'Extracting configuration files...\n'
if ! 'command' 'tail' '-c' +^DUMP_POS^ '--' "$1" | 'command' 'tar' '-C' "$_teleport_tmp" '-xzf' '-'; then
  >&2 'printf' '\033[31mError:\033[0m Failed to extract configuration tarball\n'
  _teleport_error
  'exit' '1'
fi

ZDOTDIR="${HOME}/.config/zsh"
'command' 'mkdir' '-p' "$ZDOTDIR" || {
  >&2 'printf' '\033[31mError:\033[0m Failed to create %s\n' "$ZDOTDIR"
  _teleport_error
  'exit' '1'
}

case ":$PATH:" in
*:$HOME/.local/bin:*) ;;
*) export PATH="$HOME/.local/bin:$PATH" ;;
esac

^SEND_FILES^

if ! command -v zsh >'/dev/null' 2>&1; then
  'printf' 'Installing zsh to ~/.local/bin...\n'

  _zsh_tmp="${TMPDIR:-/tmp}/install-zsh.$$"
  _zsh_url='https://raw.githubusercontent.com/romkatv/zsh-bin/master/install'

  if command -v curl >'/dev/null' 2>&1; then
    command curl -fsSL -- "$_zsh_url" 2>&1 >"$_zsh_tmp" || {
      >&2 'printf' '\033[31mError:\033[0m Failed to download zsh installer\n'
      _teleport_error
      'exit' '1'
    }
  elif command -v wget >'/dev/null' 2>&1; then
    command wget -O- -- "$_zsh_url" 2>&1 >"$_zsh_tmp" || {
      >&2 'printf' '\033[31mError:\033[0m Failed to download zsh installer\n'
      _teleport_error
      'exit' '1'
    }
  else
    >&2 'printf' '\033[31mError:\033[0m Please install curl or wget\n'
    _teleport_error
    'exit' '1'
  fi

  'command' 'sh' '--' "$_zsh_tmp" '-d' "$HOME"/.local '-e' 'no' || {
    >&2 'printf' '\033[31mError:\033[0m Failed to install zsh\n'
    _teleport_error
    'exit' '1'
  }

  'command' 'rm' '-f' '--' "$_zsh_tmp" 2>'/dev/null'

  if command -v zsh >'/dev/null' 2>&1; then
    'printf' '\033[32m[OK]\033[0m zsh installed successfully\n'
  else
    >&2 'printf' '\033[31mError:\033[0m zsh installation verification failed\n'
    _teleport_error
    'exit' '1'
  fi
fi

export SSH_TELEPORT='1'
export TERM=^TERM^
export ZDOTDIR="$HOME/.config/zsh"

'printf' '%s' '^FILES_CHECKSUM^' >"$ZDOTDIR/.teleport-stamp" 2>'/dev/null' || 'true'

'printf' '\033[32m[OK]\033[0m Teleportation complete\n'
'exit' '0'
