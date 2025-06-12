# PATH
export PATH="$HOME/.poetry/bin:$PATH"
export PATH="$HOME/dotfiles/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.lmstudio/bin"

# zplug
export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh
zplug "mafredri/zsh-async"
zplug "sindresorhus/pure"
zplug "zsh-users/zsh-autosuggestions"
zplug "b4b4r07/enhancd", use:init.sh
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-completions"
zplug load

# alias
alias ls='ls -G'
alias gcd='cd $(ghq root)/$(ghq list | fzf)'
alias docker-rmc='docker ps -a | tail -n +2 | fzf -m | awk "{print \$1}" | xargs -I{} docker rm {}'
alias docker-rmi='docker images | tail -n +2 | fzf -m | awk "{print \$3}" | xargs -I{} docker rmi {}'
alias mockcat='while true; do echo -e "HTTP/1.1 200 OK\n\n$(date)" | nc -l 1337; done'
alias ting='afplay /System/Library/Sounds/Blow.aiff'

# pyenv
eval "$(pyenv init -)"
