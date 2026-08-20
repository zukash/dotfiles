# ============================================================================
# Core configs
# ============================================================================
set -a
source ~/.zsh/.env
set +a

source ~/.zsh/options.zsh
source ~/.zsh/path.zsh
source ~/.zsh/functions.zsh
source ~/.zsh/hooks.zsh
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
source <(antidote bundle zukash/zsh-flash)                    # Jump-label navigation

# ============================================================================
# Integrations
# ============================================================================
source <(fzf --zsh)
autoload -Uz compinit && compinit

# mise: project-local tools, environment variables, and tasks
eval "$(mise activate zsh)"
