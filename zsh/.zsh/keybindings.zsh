# Key bindings
bindkey -e

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^o' edit-command-line  # Ctrl+o to open editor

# FZF + z integration
zle -N fzf-z-search
bindkey '^z' fzf-z-search

# Clear the screen while preserving scrollback
# https://github.com/herdrdev/herdr/issues/2897
_clear_preserve_scrollback() {
  printf '\n%.0s' {1..$LINES}
  printf '\e[H'
  zle reset-prompt
}
zle -N _clear_preserve_scrollback
bindkey '^L' _clear_preserve_scrollback

# zsh-flash
# https://github.com/zukash/zsh-flash
bindkey '^j' zsh-flash
