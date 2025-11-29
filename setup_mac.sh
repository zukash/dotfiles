#!/bin/bash
# macOS dotfiles installer

# Deploy dotfiles using stow
echo "Deploying dotfiles..."
stow -R zsh -t "$HOME"
stow -R vscode -t "$HOME/Library/Application Support/Code/User"
stow -R karabiner -t "$HOME/.config/karabiner"
stow -R nvim -t "$HOME/.config/nvim"
stow -R tmux -t "$HOME/.config/tmux"
stow -R hammerspoon -t "$HOME/.hammerspoon"
stow -R opencode -t "$HOME/.config/opencode"
stow -R ghostty -t "$HOME/.config/ghostty"

echo "Deployment complete!"
