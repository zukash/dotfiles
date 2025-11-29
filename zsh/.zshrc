# ============================================================================
# Core configs
# ============================================================================
set -a
source ~/.zsh/.env
set +a

source ~/.zsh/options.zsh
source ~/.zsh/path.zsh
source ~/.zsh/functions.zsh
source ~/.zsh/keybindings.zsh
source ~/.zsh/alias.zsh

# ============================================================================
# Plugins (antidote)
# ============================================================================
source ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh

source <(antidote bundle rupa/z)                              # Directory jumping
source <(antidote bundle sindresorhus/pure)                   # Prompt theme
source <(antidote bundle zsh-users/zsh-autosuggestions)       # Command suggestions
source <(antidote bundle zsh-users/zsh-syntax-highlighting)   # Syntax highlighting

# ============================================================================
# Integrations
# ============================================================================
source <(fzf --zsh)
autoload -Uz compinit && compinit

# bun completions
[ -s "/Users/zukash/.bun/_bun" ] && source "/Users/zukash/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
