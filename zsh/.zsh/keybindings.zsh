# Key bindings
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^o' edit-command-line  # Ctrl+o to open editor

# FZF + z integration
zle -N fzf-z-search
bindkey '^z' fzf-z-search

# GHQ + tmux integration
zle -N ghq-tmux
bindkey '^g' ghq-tmux
