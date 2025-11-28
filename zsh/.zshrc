HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS      # 重複コマンドを履歴に保存しない
setopt HIST_IGNORE_SPACE     # スペースで始まるコマンドを履歴に保存しない
setopt SHARE_HISTORY         # 複数セッション間で履歴を共有

EDITOR='nvim'
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^o' edit-command-line

# fzf
source <(fzf --zsh)

# helper function
source_if_exists() {
  [ -f "$1" ] && source "$1"
}

# export environment variables from .env
set -a
source_if_exists ~/.zsh/.env
set +a

# functions, path, alias
source_if_exists ~/.zsh/functions.zsh
source_if_exists ~/.zsh/path.zsh
source_if_exists ~/.zsh/alias.zsh

# antidote
source ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh

# Load plugins dynamically
source <(antidote bundle rupa/z)
source <(antidote bundle sindresorhus/pure)
source <(antidote bundle zsh-users/zsh-autosuggestions)
source <(antidote bundle zsh-users/zsh-syntax-highlighting)

# prompt
autoload -U promptinit; promptinit
prompt pure

# completion
autoload -Uz compinit && compinit
