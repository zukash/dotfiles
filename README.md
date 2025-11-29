# dotfiles

macOS dotfiles managed with GNU Stow.

## Prerequisites

```sh
brew install stow fzf
git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote
```

## Installation

Run the installer script:

```sh
./installer.sh
```

Or manually deploy specific configurations:

```sh
stow -R zsh -t $HOME
stow -R vscode -t "$HOME/Library/Application Support/Code/User"
stow -R karabiner -t "$HOME/.config/karabiner"
stow -R nvim -t "$HOME/.config/nvim"
stow -R tmux -t "$HOME/.config/tmux"
stow -R hammerspoon -t "$HOME/.hammerspoon"
stow -R opencode -t "$HOME/.config/opencode"
stow -R ghostty -t "$HOME/.config/ghostty"
```

## VSCode Extensions

Install extensions:
```sh
cat ./vscode/extensions.txt | xargs -n 1 code --install-extension
```

Update extension list:
```sh
code --list-extensions > ./vscode/extensions.txt
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
