# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

export GOPATH="$HOME/.go"
export PATH="$HOME/.local/bin:$HOME/bin:$PATH:$HOME/.cargo/bin:/usr/local/go/bin:$GOPATH/bin"
