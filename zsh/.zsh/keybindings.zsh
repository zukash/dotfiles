# Key bindings
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-line

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^o' edit-command-line  # Ctrl+o to open editor

# FZF + z integration
zle -N fzf-z-search
bindkey '^z' fzf-z-search

# zsh-flash
# https://github.com/zukash/zsh-flash
bindkey '^j' zsh-flash
