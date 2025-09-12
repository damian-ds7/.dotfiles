# .bashrc

# Source global definitions

if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

# Load common configs
if [ -d ~/.config/shell/common ]; then
  for rc in ~/.config/shell/common/*; do
    [ -f "$rc" ] && . "$rc"
  done
fi

# Load bash-specific configs
if [ -d ~/.cofig/shell/bash ]; then
  for rc in ~/.config/shell/bash/*; do
    [ -f "$rc" ] && . "$rc"
  done
fi

unset rc

PATH="/home/damian/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/damian/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/damian/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/damian/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/damian/perl5"; export PERL_MM_OPT;

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
. "$HOME/.cargo/env"
