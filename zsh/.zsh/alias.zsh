# Aliases
alias ls='ls --color=auto'
alias gcd='cd $(ghq root)/$(ghq list | fzf-tmux -p 80%)'
alias mockcat='while true; do echo -e "HTTP/1.1 200 OK\n\n$(date)" | nc -l 1337; done'
alias ting='afplay /System/Library/Sounds/Blow.aiff'
