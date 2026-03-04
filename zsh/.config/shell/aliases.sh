is_installed() {
    command -v "$1" >/dev/null 2>&1
}

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

alias suvi='sudo -E nvim'
alias suvim='sudo -E nvim'
alias sunano='sudo -E nano'

# -------------------------
#  Package Management
# -------------------------

alias update-poweroff='sudo dnf upgrade -y && flatpak update -y && systemctl poweroff'

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

xopen() {
    local arg="${1:-.}"
    (nohup xdg-open "$arg" >/dev/null 2>&1 </dev/null &) >/dev/null 2>&1
}

function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd <"$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

function nvim() {
    if [[ -z "$NVIM_ADDRESS" ]]; then
        command nvim "$@"
        return $?
    fi

    local target_dir="${NVIM_TERM_ORIG_DIR:-}"

    if [ $# -eq 0 ]; then
        if [[ -n "$TMUX" ]]; then
            tmux detach-client
        else
            command nvim --server "$NVIM_ADDRESS" --remote-send "<C-\><C-N>:FloatTerm<CR>"
        fi
        return 0
    fi

    local files=()
    local dirs=()

    for arg in "$@"; do
        if [ -d "$arg" ]; then
            dirs+=("$arg")
        else
            files+=("$arg")
        fi
    done

    for arg in "${files[@]}" "${dirs[@]}"; do
        local fp=$(realpath "$arg")
        command nvim --server "$NVIM_ADDRESS" --remote-send "<C-\><C-N>:e $fp<CR>"
    done

    if [[ -n "$TMUX" ]]; then
        tmux detach-client
    else
        command nvim --server "$NVIM_ADDRESS" --remote-send "<C-\><C-N>:FloatTerm<CR>"
    fi

    return 0
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
alias start='sudo systemctl start'
alias stop='sudo systemctl stop'
alias restart='sudo systemctl restart'
alias status='sudo systemctl status'
alias enabled='sudo systemctl enable'
alias disabled='sudo systemctl disable'

# User-level
alias ustart='systemctl --user start'
alias ustop='systemctl --user stop'
alias ustatus='systemctl --user status'
alias uenable='systemctl --user enable'
alias udisable='systemctl --user disable'
alias urestart='systemctl --user restart'
