HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

EDITOR='nvim'
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^o' edit-command-line

# fzf
source <(fzf --zsh)
export FZF_TMUX=1
export FZF_TMUX_OPTS="-p 80%"
export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

# export environment variables from .env
set -a
[ -f ~/.zsh/.env ] && source ~/.zsh/.env
set +a

# functions
[ -f ~/.zsh/functions.zsh ] && source ~/.zsh/functions.zsh

# path
[ -f ~/.zsh/path.zsh ] && source ~/.zsh/path.zsh

# alias
[ -f ~/.zsh/alias.zsh ] && source ~/.zsh/alias.zsh

# antidote
source ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh
antidote load ${ZDOTDIR:-$HOME}/.zsh/plugins.txt
