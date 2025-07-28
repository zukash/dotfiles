HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

# EDITOR='nvim'
# autoload -Uz edit-command-line
# zle -N edit-command-line
# bindkey '^o' edit-command-line

# export
export $(grep -v '^#' ~/.zsh/.env | xargs)

# functions
[ -f ~/.zsh/functions.zsh ] && source ~/.zsh/functions.zsh

# path
[ -f ~/.zsh/path.zsh ] && source ~/.zsh/path.zsh

# alias
[ -f ~/.zsh/alias.zsh ] && source ~/.zsh/alias.zsh

# pyenv
eval "$(pyenv init -)"

# antidote
source ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh
antidote load ${ZDOTDIR:-$HOME}/.zsh/plugins.txt

# fzf
source <(fzf --zsh)
export FZF_TMUX=1
export FZF_TMUX_OPTS="-p"
