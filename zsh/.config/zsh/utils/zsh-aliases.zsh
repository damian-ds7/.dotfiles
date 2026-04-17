alias reload='exec zsh'

# -------------------------
#  Suffix aliases
# -------------------------
alias -s json=jless
alias -s yaml=jless --yaml
alias -s {md,txt,log}=bat
alias -s {go,rs,c,cpp,h,hpp}='$EDITOR'
alias -s git="git clone"

# -------------------------
#  Global aliases
# -------------------------
alias -g H='| head'
alias -g L='| less'
alias -g B='| bat'
alias -g G='| grep'
alias -g F='| fzf'
alias -g W='| wc'
alias -g J='| jq'
alias -g T="| tr -d '\n' "
