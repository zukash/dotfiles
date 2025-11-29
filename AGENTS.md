# Agent Guidelines for Dotfiles Repository

## Repository Structure
This is a dotfiles repository managed with GNU Stow for macOS. Configurations for: zsh, vscode, hammerspoon, karabiner, nvim, tmux, opencode, ghostty.

## Installation/Setup Commands
- Install dependencies: `brew install stow fzf` and `git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote`
- Deploy dotfiles: `stow -R <folder> -t <target>` (see installer.sh:8-16 for specific targets)
- VSCode extensions: `cat ./vscode/extensions.txt | xargs -n 1 code --install-extension`
- List VSCode extensions: `code --list-extensions > ./vscode/extensions.txt`

## Testing/Validation
No automated tests. Manual validation: source configs and check for errors.

## Documentation Maintenance
When adding new configurations or making significant changes:
- Update README.md to reflect new tools/configurations
- Update installer.sh with appropriate stow commands
- Update this file (AGENTS.md) with relevant guidelines

## Code Style Guidelines

### Shell Scripts (zsh)
- Use functions for reusable logic (see zsh/.zsh/functions.zsh)
- Keep aliases simple and in alias.zsh
- Environment variables in .env (gitignored), load via `export $(grep -v '^#' ~/.zsh/.env | xargs)`
- Prefer fzf-tmux for interactive selections with `-p 80%` flag

### Lua (Hammerspoon)
- Modular: separate concerns into files (e.g., notification.lua)
- Use `hs.` prefix for Hammerspoon APIs

### Vim (init.vim)
- Use vim-plug for plugin management
- Consistent keybindings: Emacs-style in insert mode (C-a, C-e, C-f, C-b, C-p, C-n, C-h, C-d, C-k)
