# dotfiles

Dotfiles managed with GNU Stow for macOS and Linux.

## Prerequisites

Install these dependencies using your preferred method:

- `mise`
- GNU Stow
- `fzf`
- [antidote](https://github.com/mattmc3/antidote)
- [TPM](https://github.com/tmux-plugins/tpm)

## Setup

Deploy the dotfiles with mise:

```sh
# macOS
mise run setup-mac
```

```sh
# Linux
mise run setup-linux
```

```sh
# Install tools declared in mise/config.toml
mise install
```

## Included

zsh, mise, VS Code, Neovim, tmux, OpenCode, Ghostty, and platform-specific
Karabiner and AeroSpace configurations.

## mise

`mise/config.toml` manages Bun, Node.js, Deno, Python, and uv. The shell
integration is enabled automatically by `.zshrc`.

Build the Karabiner configuration with:

```sh
mise run karabiner:build
```
