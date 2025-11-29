# Agent Guidelines for Dotfiles Repository

## Repository Structure
This is a dotfiles repository managed with GNU Stow for macOS and Linux. Configurations for: zsh, vscode, hammerspoon (macOS only), karabiner (macOS only), nvim, tmux, opencode, ghostty.

## Setup Commands
- macOS: `./setup_mac.sh`
- Linux: `./setup_linux.sh`
- Deploy specific config manually: `stow -R <folder> -t <target>`
  - See setup_mac.sh and setup_linux.sh for platform-specific target paths

## Repository Responsibility
This repository is responsible ONLY for deploying dotfiles to appropriate locations. Tool installation (stow, fzf, antidote, etc.) is NOT managed by this repository and should be done manually by users.

## Testing/Validation
No automated tests. Manual validation: source configs and check for errors.

## Documentation Maintenance
When adding new configurations or making significant changes:
- Update README.md to reflect new tools/configurations
- Update setup_mac.sh and/or setup_linux.sh with appropriate stow commands
- Update this file (AGENTS.md) with relevant guidelines
- ALWAYS update documentation when modifying setup scripts or structure

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
