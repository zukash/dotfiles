brew install fzf

brew install stow
# apt install stow

# https://github.com/mattmc3/antidote
git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote

stow -R zsh -t $HOME
stow -R vscode -t "$HOME/Library/Application Support/Code/User"
stow -R config -t $HOME/.config
