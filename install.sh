#!/bin/bash

DOTFILES="$HOME/.config"

echo "Creating symlinks"

link() {
    local src=$1
    local dst=$2
    if [ -f "$dst" ] && [ ! -L "$dst" ]; then
        echo "Backing up $dst -> $dst.bak"
        mv "$dst" "$dst.bal"
    fi
    ln -sf "$src" "$dst"
}

link "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"
link "$DOTFILES/zsh/zimrc" "$HOME/.zimrc"
link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

echo "Done!"
