#!/usr/bin/env zsh
# SSH Teleportation - Host Configuration

typeset -gUa SSH_TELEPORT_ENABLED_HOSTS
typeset -gUa SSH_TELEPORT_DISABLED_HOSTS

local ssh_dir="${ZDOTDIR:-$HOME/.config/zsh}/utils/ssh"

if [[ -f "$ssh_dir/hosts-enabled.txt" ]]; then
  SSH_TELEPORT_ENABLED_HOSTS=(${(f)"$(grep -v '^#' "$ssh_dir/hosts-enabled.txt" | grep -v '^[[:space:]]*$')"})
fi

if [[ -f "$ssh_dir/hosts-disabled.txt" ]]; then
  SSH_TELEPORT_DISABLED_HOSTS=(${(f)"$(grep -v '^#' "$ssh_dir/hosts-disabled.txt" | grep -v '^[[:space:]]*$')"})
fi

function ssh-teleport-enable-host() {
  local host=$1
  local ssh_dir="${ZDOTDIR:-$HOME/.config/zsh}/utils/ssh"

  if [[ -z $host ]]; then
    print -u 2 "Usage: ssh-teleport-enable-host <hostname>"
    return 1
  fi

  if [[ -f "$ssh_dir/hosts-disabled.txt" ]]; then
    grep -v "^$host\$" "$ssh_dir/hosts-disabled.txt" > "$ssh_dir/hosts-disabled.txt.tmp" 2>/dev/null
    mv "$ssh_dir/hosts-disabled.txt.tmp" "$ssh_dir/hosts-disabled.txt"
  fi

  if [[ -f "$ssh_dir/hosts-enabled.txt" ]] && ! grep -q "^$host\$" "$ssh_dir/hosts-enabled.txt" 2>/dev/null; then
    echo "$host" >> "$ssh_dir/hosts-enabled.txt"
  fi

  SSH_TELEPORT_DISABLED_HOSTS=(${SSH_TELEPORT_DISABLED_HOSTS:#$host})
  if [[ ! ${SSH_TELEPORT_ENABLED_HOSTS[(ie)$host]} -le ${#SSH_TELEPORT_ENABLED_HOSTS} ]]; then
    SSH_TELEPORT_ENABLED_HOSTS+=($host)
  fi
}

function ssh-teleport-disable-host() {
  local host=$1
  local ssh_dir="${ZDOTDIR:-$HOME/.config/zsh}/utils/ssh"

  if [[ -z $host ]]; then
    print -u 2 "Usage: ssh-teleport-disable-host <hostname>"
    return 1
  fi

  if [[ -f "$ssh_dir/hosts-enabled.txt" ]]; then
    grep -v "^$host\$" "$ssh_dir/hosts-enabled.txt" > "$ssh_dir/hosts-enabled.txt.tmp" 2>/dev/null
    mv "$ssh_dir/hosts-enabled.txt.tmp" "$ssh_dir/hosts-enabled.txt"
  fi

  if [[ -f "$ssh_dir/hosts-disabled.txt" ]] && ! grep -q "^$host\$" "$ssh_dir/hosts-disabled.txt" 2>/dev/null; then
    echo "$host" >> "$ssh_dir/hosts-disabled.txt"
  fi

  SSH_TELEPORT_ENABLED_HOSTS=(${SSH_TELEPORT_ENABLED_HOSTS:#$host})
  if [[ ! ${SSH_TELEPORT_DISABLED_HOSTS[(ie)$host]} -le ${#SSH_TELEPORT_DISABLED_HOSTS} ]]; then
    SSH_TELEPORT_DISABLED_HOSTS+=($host)
  fi
}
