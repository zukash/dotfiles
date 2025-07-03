# alias
alias ls='ls -G'
alias gcd='cd $(ghq root)/$(ghq list | fzf)'
alias docker-rmc='docker ps -a | tail -n +2 | fzf -m | awk "{print \$1}" | xargs -I{} docker rm {}'
alias docker-rmi='docker images | tail -n +2 | fzf -m | awk "{print \$3}" | xargs -I{} docker rmi {}'
alias mockcat='while true; do echo -e "HTTP/1.1 200 OK\n\n$(date)" | nc -l 1337; done'
alias ting='afplay /System/Library/Sounds/Blow.aiff'
alias enc='openssl enc -aes-256-cbc -salt -base64'    
alias dec='openssl enc -aes-256-cbc -d -base64'
