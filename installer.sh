# brew install fzf
# brew install stow
# apt install stow
# https://github.com/mattmc3/antidote
# git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote
# mcpctl: https://github.com/zukash/mcpctl

stow -R zsh -t $HOME
stow -R vscode -t "$HOME/Library/Application Support/Code/User"
#  code --list-extensions > ./vscode/extensions.txt
cat ./vscode/extensions.txt | xargs -n 1 code --install-extension
stow -R karabiner -t "$HOME/.config/karabiner"
stow -R mcpctl -t "$HOME/.config/mcpctl"
stow -R nvim -t "$HOME/.config/nvim"
stow -R tmux -t "$HOME/.config/tmux"
stow -R hammerspoon -t "$HOME/.hammerspoon"

# https://github.com/zukash/mcpctl
mcpctl apply -f ~/.config/mcpctl/mcp.json
