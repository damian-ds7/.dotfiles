CURRENT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]:-$0}")")
source "$CURRENT_DIR/utils.sh"

unset CURRENT_DIR

# -------------------------
#  General Aliases
# -------------------------

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias du='du -h --max-depth=1'
alias df='df -hT'

alias c='clear'

# -------------------------
#  Aliases with fallback to original command
# -------------------------
if is_installed rg; then
  alias grep='rg'
else
  alias grep='command grep --color=auto'
fi

if is_installed lsd; then
  alias ls='lsd'
  alias ll='lsd -lX --group-dirs=first --header --no-symlink'
  alias la='lsd -lAX --group-dirs=first --header'
else
  alias ls='command ls --color=always'
  alias ll='ls -l --color=always'
  alias la='ls -al --color=always'
fi

alias tree='tree -I .git --gitignore --dirsfirst'

# -------------------------
#  Editor Shortcuts
# -------------------------

alias suvi='sudo vim'
alias suvim='sudo vim'
alias sunano='sudo nano'

# -------------------------
#  Package Management
# -------------------------

alias refresh='sudo dnf upgrade --refresh'
alias upgrade='sudo dnf upgrade'
alias inst='sudo dnf install'
alias remove='sudo dnf remove'

alias chme='sudo chown -R damian:damian'

# -------------------------
#  System-level ls with color (sudo ls variants)
# -------------------------

alias sll='sudo ls -hall --color=always'
alias sla='sudo ls -hall --color=always'
alias sls='sudo ls -hall --color=always'

# -------------------------
#  Docker
# -------------------------

alias dsp='docker system prune'

# -------------------------
#  File Ops
# -------------------------

alias compress='tar --use-compress-program="pigz -k -5" -cf'
alias scp='noglob scp'

# -------------------------
#  Git Aliases
# -------------------------

alias gst='git status --short'
alias gc='git commit'
alias gcm='git commit -m'
alias gcam='git commit -am'
alias gf='git fetch'
alias gcl='git clone'
alias gpl='git pull'
alias gps='git push'
alias gbr='git branch'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gl='git log --graph --all --pretty=format:"%C(magenta)%h %C(white) %an  %ar%C(auto)  %D%n%s%n"'
alias ga='git add'
alias gd='git diff'
alias gdw='git diff --word-diff=color'
alias diff-words='git diff --word-diff=color'

alias lg='lazygit'

# -------------------------
# Other
# -------------------------

alias code='code --enable-features=UseOzonePlatform --ozone-platform=wayland'
alias tcode='code-tabbed'
alias vsource='source .venv/bin/activate'

# -------------------------
#  Custom Functions
# -------------------------

mkcd() {
  if [ -z "$1" ]; then
    echo "Enter a directory name"
  elif [ -d "$1" ]; then
    echo "\`$1' already exists"
  else
    mkdir "$1" && cd "$1"
  fi
}

now() {
  export now=$(date +"%Y-%m-%dT%H%M%S")
}

xopen() {
  local arg="${1:-.}"
  xdg-open "$arg"
}

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# -------------------------
#  Systemd Helpers
# -------------------------

listd() {
  echo -e "${BLD}${RED} --> SYSTEM LEVEL <--${NRM}"
  tree /etc/systemd/system
  [[ -d "$HOME"/.config/systemd/user/default.target.wants ]] && {
    echo -e "${BLD}${RED} --> USER LEVEL <--${NRM}"
    tree "$HOME"/.config/systemd/user
  }
}

# System-level
start() { sudo systemctl start "$1"; }
stop() { sudo systemctl stop "$1"; }
restart() { sudo systemctl restart "$1"; }
status() { sudo systemctl status "$1"; }
enabled() {
  sudo systemctl enable "$1"
  listd
}
disabled() {
  sudo systemctl disable "$1"
  listd
}

# User-level
ustart() { systemctl --user start "$1"; }
ustop() { systemctl --user stop "$1"; }
ustatus() { systemctl --user status "$1"; }
uenable() { systemctl --user enable "$1"; }
udisable() { systemctl --user disable "$1"; }
