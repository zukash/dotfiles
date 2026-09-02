# Agent Guidelines for Dotfiles Repository

## Repository Structure
This is a dotfiles repository managed with GNU Stow for macOS and Linux. Configurations for: zsh, mise, vscode, karabiner (macOS only), nvim, tmux, opencode, ghostty, herdr plugins, and agent skills.

## Setup Commands
- macOS: `mise run setup-mac`
- Linux: `mise run setup-linux`
- Deploy specific config manually: `stow -R <folder> -t <target>`
  - See the `mise.toml` setup tasks for platform-specific target paths
- Agent skills live in the `agents` Stow package and deploy to `~/.agents/skills`.
- Herdr local plugins live under `herdr/plugins` and are registered with `herdr plugin link`.
- Hunk skills are kept under `agents/.agents/skills`: `hunk-fix` applies user
  feedback, `hunk-comment` adds contextual agent notes, and `hunk-pr` requires
  note approval before creating a PR with `gh`.

## Repository Responsibility
This repository is responsible ONLY for deploying dotfiles to appropriate locations. Tool installation (stow, fzf, antidote, etc.) is NOT managed by this repository and should be done manually by users.

## Testing/Validation
No automated tests. Manual validation: source configs and check for errors.

## Documentation Maintenance
When adding new configurations or making significant changes:
- Update README.md to reflect new tools/configurations
- Update `mise.toml` with appropriate setup tasks and stow commands
- Update this file (AGENTS.md) with relevant guidelines
- ALWAYS update documentation when modifying setup scripts or structure

## Code Style Guidelines

### Shell Scripts (zsh)
- Use functions for reusable logic (see zsh/.zsh/functions.zsh)
- Keep aliases simple and in alias.zsh
- Shell hooks (precmd, preexec, etc.) in hooks.zsh
- Environment variables in .env (gitignored), load via `export $(grep -v '^#' ~/.zsh/.env | xargs)`
- Prefer fzf-tmux for interactive selections with `-p 80%` flag

### Vim (init.vim)
- Use vim-plug for plugin management
- Consistent keybindings: Emacs-style in insert mode (C-a, C-e, C-f, C-b, C-p, C-n, C-h, C-d, C-k)
