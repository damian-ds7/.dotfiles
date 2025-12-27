#!/usr/bin/env zsh
# SSH Teleportation based on z4h implementation, modified for personal use

function _teleport_info() {
  [[ -n ${SSH_TELEPORT_DEBUG:-} ]] || return
  if command -v gum >/dev/null 2>&1; then
    gum style --foreground 212 "$*" >&2
  else
    print -Pr -- "%F{cyan}%f$*" >&2
  fi
}

function _teleport_success() {
  [[ -n ${SSH_TELEPORT_DEBUG:-} ]] || return
  if command -v gum >/dev/null 2>&1; then
    gum style --foreground 212 "$*" >&2
  else
    print -Pr -- "%F{green}%f$*" >&2
  fi
}

function _teleport_warn() {
  if command -v gum >/dev/null 2>&1; then
    gum style --foreground 220 "$*" >&2
  else
    print -Pr -- "%F{yellow}%f$*" >&2
  fi
}

function _teleport_error() {
  if command -v gum >/dev/null 2>&1; then
    gum style --foreground 196 "$*" >&2
  else
    print -Pr -- "%F{red}%f$*" >&2
  fi
}

function _teleport_debug() {
  [[ -n ${SSH_TELEPORT_DEBUG:-} ]] || return
  if command -v gum >/dev/null 2>&1; then
    gum style --foreground 99 "[DEBUG] $*" >&2
  else
    print -Pr -- "%F{magenta}[DEBUG]%f $*" >&2
  fi
}

function _teleport_load_hosts() {
  local hosts_file="${ZDOTDIR:-$HOME/.config/zsh}/utils/ssh/hosts.zsh"
  if [[ -f $hosts_file ]]; then
    source "$hosts_file"
  fi
}

function _teleport_check_host_config() {
  local hostname=$1

  _teleport_load_hosts

  if [[ ${SSH_TELEPORT_DISABLED_HOSTS[(ie)$hostname]} -le ${#SSH_TELEPORT_DISABLED_HOSTS} ]]; then
    return 2  # Disabled
  fi

  if [[ ${SSH_TELEPORT_ENABLED_HOSTS[(ie)$hostname]} -le ${#SSH_TELEPORT_ENABLED_HOSTS} ]]; then
    return 0  # Enabled
  fi

  local zstyle_value
  if zstyle -s :ssh-teleport:$hostname enable zstyle_value; then
    case $zstyle_value in
      yes|true|1|on)
        return 0  # Enabled by zstyle
        ;;
      no|false|0|off)
        return 2  # Disabled by zstyle
        ;;
    esac
  fi

  return 1  # Unknown, needs prompt
}

function _teleport_prompt_user() {
  local hostname=$1
  local user_choice

  _enable_and_confirm() {
    ssh-teleport-enable-host "$hostname"
    if command -v gum >/dev/null 2>&1; then
      gum style --foreground 212 "Host $hostname added to enabled list"
    else
      _teleport_success "Host %F{yellow}$hostname%f added to enabled list"
    fi
  }

  _disable_and_confirm() {
    ssh-teleport-disable-host "$hostname"
    if command -v gum >/dev/null 2>&1; then
      gum style --foreground 212 "Host $hostname added to disabled list"
    else
      _teleport_success "Host %F{yellow}$hostname%f added to disabled list"
    fi
  }

  if command -v gum >/dev/null 2>&1; then
    gum style \
      --foreground 212 --border-foreground 212 --border double \
      --align center --width 60 --margin "1 2" --padding "1 2" \
      "SSH Teleportation" \
      "" \
      "Teleport your zsh configuration to $(gum style --foreground 220 "$hostname")?" \
      "" \
      "This will sync your .zshrc, .zshenv, utilities, and prompt config."

    user_choice=$(gum choose \
      "Yes (this time only)" \
      "Yes, always for this host" \
      "No (this time only)" \
      "No, never for this host")

    case $user_choice in
      "Yes (this time only)")
        return 0
        ;;
      "Yes, always for this host")
        _enable_and_confirm
        return 0
        ;;
      "No (this time only)")
        return 1
        ;;
      "No, never for this host")
        _disable_and_confirm
        return 1
        ;;
      *)
        gum style --foreground 196 "No choice made, defaulting to No"
        return 1
        ;;
    esac
  else
    print -Pr -- ""
    print -Pr -- "%F{cyan}SSH Teleportation%f"
    print -Pr -- "Teleport your zsh configuration to %F{yellow}$hostname%f?"
    print -Pr -- ""
    print -Pr -- "This will sync your .zshrc, .zshenv, utilities, and prompt config."
    print -Pr -- ""
    print -Pr -- "  %F{green}1%f) Yes (this time only)"
    print -Pr -- "  %F{green}2%f) Yes, always for this host"
    print -Pr -- "  %F{red}3%f) No (this time only)"
    print -Pr -- "  %F{red}4%f) No, never for this host"
    print -Pr -- ""
    print -Prn -- "Choice [1-4]: "

    read -k 1 user_choice
    print ""
    print ""

    case $user_choice in
      1)
        return 0
        ;;
      2)
        _enable_and_confirm
        return 0
        ;;
      3)
        return 1
        ;;
      4)
        _disable_and_confirm
        return 1
        ;;
      *)
        _teleport_error "Invalid choice, defaulting to No"
        return 1
        ;;
    esac
  fi
}

function ssh-teleport() {
  emulate -L zsh
  setopt no_unset pipe_fail

  _teleport_debug "ssh-teleport called with args: $*"

  local -i i
  local -a pos ssh_args
  local hostname

  for ((i = 1; i <= $#; ++i)); do
    case $*[i] in
      --) (( ++i <= $# )) && pos+=({$i..$#}); break;;
      -[bcDEeFIiJLlmOopQRSWwB]) ssh_args+=($*[i]); ((++i <= $#)) && ssh_args+=($*[i]);;
      -*) ssh_args+=($*[i]);;
      *)  pos+=($i);;
    esac
  done

  if (( $#pos == 0 )); then
    command ssh "${ssh_args[@]}" "$@"
    return
  fi

  local user_host=$*[pos[1]]
  hostname=${${user_host##*@}%%:*}

  if [[ -z $hostname ]]; then
    command ssh "$@"
    return
  fi

  _teleport_check_host_config "$hostname"
  local -i host_status=$?

  if (( host_status == 2 )); then
    _teleport_debug "Teleportation disabled for $hostname, using regular SSH"
    command ssh "$@"
    return
  fi

  if (( host_status == 1 )); then
    if ! _teleport_prompt_user "$hostname"; then
      command ssh "$@"
      return
    fi
  fi

  _teleport_load_hosts

  local -A send_files
  local -a prelude setup run teardown extra_files

  if [[ -f $ZDOTDIR/.zshrc ]]; then
    send_files[$ZDOTDIR/.zshrc]='"$ZDOTDIR"/.zshrc'
  fi

  if [[ -f $HOME/.zshenv ]]; then
    send_files[$HOME/.zshenv]='"$HOME"/.zshenv'
  fi

  if [[ -f $ZDOTDIR/.zshenv ]]; then
    send_files[$ZDOTDIR/.zshenv]='"$ZDOTDIR"/.zshenv'
  fi

  if [[ -f $HOME/.config/oh-my-posh/p10k.toml ]]; then
    send_files[$HOME/.config/oh-my-posh/p10k.toml]='"$HOME"/.config/oh-my-posh/p10k.toml'
  fi

  local util_file
  for util_file in $ZDOTDIR/utils/**/*(.N); do
    local rel_path=${util_file#$ZDOTDIR/utils/}
    send_files[$util_file]='"$ZDOTDIR"/utils/'${(q)rel_path}
  done

  if zstyle -a :ssh-teleport:$hostname send-extra-files extra_files; then
    local src dst
    for dst in $extra_files; do
      eval "src=$dst"
      if [[ -e $src ]]; then
        send_files[$src]=$dst
      fi
    done
  fi

  if (( $+functions[ssh-teleport-configure] )); then
    typeset -g ssh_teleport_send_files=send_files
    typeset -g ssh_teleport_prelude=prelude
    typeset -g ssh_teleport_setup=setup
    typeset -g ssh_teleport_run=run
    typeset -g ssh_teleport_teardown=teardown

    ssh-teleport-configure

    send_files=("${(@kv)ssh_teleport_send_files}")
    prelude=("${(@)ssh_teleport_prelude}")
    setup=("${(@)ssh_teleport_setup}")
    run=("${(@)ssh_teleport_run}")
    teardown=("${(@)ssh_teleport_teardown}")
  fi

  local tmpdir
  tmpdir=$(mktemp -d ${TMPDIR:-/tmp}/ssh-teleport.XXXXXXXXXX) || return 1

  {
    local -i index=0
    local src dst
    for src dst in "${(@kv)send_files}"; do
      if [[ ! -e $src ]]; then
        _teleport_warn "file not found: ${src:A}"
        continue
      fi

      (( ++index ))
      ln -s ${src:A} $tmpdir/$index || return 1
    done

    if (( index == 0 )); then
      _teleport_error "no files to send"
      return 1
    fi

    local script
    script=$(<$ZDOTDIR/utils/ssh/bootstrap.sh) || return 1

    local files_checksum
    files_checksum=$(
      for src dst in "${(@kv)send_files}"; do
        [[ -e $src ]] && print -r -- "${src:A}" && command sha256sum "${src:A}" 2>/dev/null
      done | command sha256sum 2>/dev/null | cut -d' ' -f1
    )

    local dump_marker
    dump_marker=$(LC_ALL=C command tr -dc 'a-zA-Z0-9' </dev/urandom 2>/dev/null | head -c 8)

    local term
    zstyle -s :ssh-teleport:$hostname term term || term=${TERM:-xterm-256color}

    local file_moves_code=""
    local -i idx=0
    for src dst in "${(@kv)send_files}"; do
      (( ++idx ))
      file_moves_code+="if '[' '-e' \"\$_teleport_tmp/$idx\" ']'; then
  _dst=$dst
  'command' 'mkdir' '-p' \"\${_dst%/*}\" 2>'/dev/null' || 'true'
  'command' 'mv' '-f' \"\$_teleport_tmp/$idx\" \"\$_dst\" || {
    >&2 'printf' '\\033[31mError:\\033[0m Failed to move file to %s\\n' \"\$_dst\"
  }
fi
"
    done

    local -a indices
    indices=({1..$index})

    COPYFILE_DISABLE=1 command tar -C $tmpdir -h -czf $tmpdir/payload.tar.gz -- $indices || return 1

    script=${script//'^TERM^'/${term}}
    script=${script//'^SSH_HOST^'/${hostname}}
    script=${script//'^DUMP_MARKER^'/${dump_marker}}
    script=${script//'^SEND_FILES^'/$file_moves_code}
    script=${script//'^FILES_CHECKSUM^'/${files_checksum}}

    script=${script//'^DUMP_POS^'/${(r:8:: :)${#script}}}

    _teleport_debug "DUMP_POS=${#script} (padded to 8 chars)"

    print -r -- $script >$tmpdir/bootstrap || return 1
    cat $tmpdir/payload.tar.gz >> $tmpdir/bootstrap || return 1

    if [[ -n ${SSH_TELEPORT_DEBUG:-} ]]; then
      cp $tmpdir/bootstrap /tmp/debug-bootstrap-$$.sh 2>/dev/null
      _teleport_debug "Bootstrap saved to /tmp/debug-bootstrap-$$.sh"
    fi

    local -a ssh_command
    if ! zstyle -a :ssh-teleport:$hostname ssh-command ssh_command; then
      ssh_command=(command ssh)
    fi

    local remote_stamp
    remote_stamp=$("${ssh_command[@]}" "${ssh_args[@]}" "$user_host" \
      'cat ~/.config/zsh/.teleport-stamp 2>/dev/null || true')

    if [[ -n $files_checksum && $remote_stamp == $files_checksum ]]; then
      _teleport_debug "Config up to date on $hostname (checksum match)"

      local -a interactive_args
      interactive_args=("${ssh_args[@]}")
      interactive_args+=(-t)

      TERM=$term "${ssh_command[@]}" "${interactive_args[@]}" "$user_host" \
        "export SSH_TELEPORT=1 ZDOTDIR=\$HOME/.config/zsh PATH=\$HOME/.local/bin:\$PATH; exec zsh -l"
      return $?
    fi

    _teleport_info "Teleporting to $hostname"

    local remote_script="/tmp/ssh-teleport-$$"
    local -i write_location

    write_location=$(
      "${ssh_command[@]}" "${ssh_args[@]}" "$user_host" \
        "cat >$remote_script && echo 1 || { cat >\$HOME/ssh-teleport-$$ && echo 2; }" \
        < $tmpdir/bootstrap
    ) || {
      _teleport_error "Failed to transmit bootstrap script"
      return 1
    }

    if [[ $write_location == 2 ]]; then
      remote_script="\$HOME/ssh-teleport-$$"
    fi

    "${ssh_command[@]}" "${ssh_args[@]}" "$user_host" "sh $remote_script; rm -f $remote_script" || {
      _teleport_error "Bootstrap script failed"
      return 1
    }

  } always {
    rm -rf $tmpdir 2>/dev/null
  }

  _teleport_debug "Bootstrap complete"

  local -a interactive_args
  interactive_args=("${ssh_args[@]}")
  interactive_args+=(-t)

  TERM=$term "${ssh_command[@]}" "${interactive_args[@]}" "$user_host" \
    "export SSH_TELEPORT=1 ZDOTDIR=\$HOME/.config/zsh PATH=\$HOME/.local/bin:\$PATH; exec zsh -l"
}
