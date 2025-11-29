# dotfiles

Dotfiles managed with GNU Stow for macOS and Linux.

## Prerequisites

### macOS
```sh
brew install stow fzf
git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

### Linux
```sh
# Ubuntu/Debian
sudo apt install stow fzf

# Fedora
sudo dnf install stow fzf

# Arch
sudo pacman -S stow fzf

git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

## Setup

Run the setup script:

```sh
# macOS
./setup_mac.sh

# Linux
./setup_linux.sh
```

## Configurations Included

- **zsh**: Shell configuration with antidote plugin manager
- **vscode**: Editor settings, keybindings, and extensions
- **karabiner**: Keyboard customization
- **nvim**: Neovim configuration with vim-plug
- **tmux**: Terminal multiplexer settings
- **hammerspoon**: macOS automation scripts
- **opencode**: OpenCode AI assistant configuration
- **ghostty**: Terminal emulator configuration
