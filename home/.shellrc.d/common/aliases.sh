# -------------------------
#  General Aliases
# -------------------------

alias history='history 1'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias grep='grep --color=auto'
alias du='du -h --max-depth=1'
alias df='df -hT'

alias reload='source ~/.bashrc'

# -------------------------
#  Functions with fallback to original command
# -------------------------

cat() {
  if command -v bat >/dev/null 2>&1; then
    bat "$@"
  else
    command cat "$@"
  fi
}

ls() {
  if command -v lsd >/dev/null 2>&1; then
    lsd -1 "$@"
  else
    ls -1 "$@"
  fi
}

ll() {
  if command -v lsd >/dev/null 2>&1; then
    lsd -lX --group-dirs=first "$@"
  else
    ls -l "$@"
  fi
}

la() {
  if command -v lsd >/dev/null 2>&1; then
    lsd -laX --group-dirs=first "$@"
  else
    ls -al "$@"
  fi
}

lt() {
  if command -v lsd >/dev/null 2>&1; then
    lsd --tree --group-dirs=first -I .git "$@"
  else
    echo "Error: 'lsd' is required for 'lt' command."
    return 1
  fi
}

# -------------------------
#  Editor Shortcuts
# -------------------------

alias suvi='sudo vim'
alias suvim='sudo vim'
alias sunano='sudo nano'

# -------------------------
#  Package Management
# -------------------------

alias update='sudo dnf update'
alias inst='sudo dnf install'
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

alias gs='git status --short'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gpu='git push'
alias gbr='git branch'
alias gco='git checkout'
alias gl='git log --graph --pretty=format:"%C(yellow)%h%Creset  %C(cyan)%cn%Creset  %Cgreen%s%Creset"'

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
start()    { sudo systemctl start "$1"; }
stop()     { sudo systemctl stop "$1"; }
restart()  { sudo systemctl restart "$1"; }
status()   { sudo systemctl status "$1"; }
enabled()  { sudo systemctl enable "$1"; listd; }
disabled() { sudo systemctl disable "$1"; listd; }

# User-level
ustart()    { systemctl --user start "$1"; }
ustop()     { systemctl --user stop "$1"; }
ustatus()   { systemctl --user status "$1"; }
uenable()   { systemctl --user enable "$1"; }
udisable()  { systemctl --user disable "$1"; }

# -------------------------
#  File/Dir Search Helpers
# -------------------------

ff() {
  [[ -n "$1" ]] || return 1
  find . -type f -name "$1"
}

fd() {
  [[ -n "$1" ]] || return 1
  find . -type d -name "$1"
}

