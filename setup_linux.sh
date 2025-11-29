#!/bin/bash
# Linux dotfiles installer

# Deploy dotfiles using stow
echo "Deploying dotfiles..."
stow -R zsh -t "$HOME"
stow -R vscode -t "$HOME/.config/Code/User"
stow -R nvim -t "$HOME/.config/nvim"
stow -R tmux -t "$HOME/.config/tmux"
stow -R opencode -t "$HOME/.config/opencode"
stow -R ghostty -t "$HOME/.config/ghostty"

echo "Deployment complete!"
