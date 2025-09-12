# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs
eval "$(starship init bash)"

# Added by Toolbox App
export PATH="$PATH:/home/damian/.local/share/JetBrains/Toolbox/scripts"
. "$HOME/.cargo/env"
