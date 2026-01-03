# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

export GPG_TTY=$TTY
export EDITOR='nvim'
export VISUAL='nvim'
export GOPATH="$HOME/.go"

export PATH="$HOME/.local/bin:$HOME/bin:$PATH:$HOME/.cargo/bin:/usr/local/go/bin:$GOPATH/bin"
