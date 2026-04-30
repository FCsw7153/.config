#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.config}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

backup_and_link() {
    local src="$1"
    local dst="$2"

    if [ ! -e "$src" ]; then
        echo "Skip: source not found: $src"
        return 0
    fi

    if [ -L "$dst" ]; then
        rm -f "$dst"
    elif [ -e "$dst" ]; then
        mv "$dst" "$dst.bak"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "Linked: $dst -> $src"
}

detect_brew() {
    if command -v brew >/dev/null 2>&1; then
        BREW_BIN="$(command -v brew)"
        return 0
    fi

    for candidate in \
        /opt/homebrew/bin/brew \
        /usr/local/bin/brew \
        /home/linuxbrew/.linuxbrew/bin/brew \
        "$HOME/.linuxbrew/bin/brew"
    do
        if [ -x "$candidate" ]; then
            BREW_BIN="$candidate"
            return 0
        fi
    done

    return 1
}

install_homebrew_from_script_url() {
    echo "Installing Homebrew from official install script..."

    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh \
        -o "$TMP_DIR/homebrew-install.sh"

    /bin/bash "$TMP_DIR/homebrew-install.sh"
}

install_homebrew_from_git_repo() {
    echo "Official install script failed. Trying official Homebrew install repo..."

    git clone --depth=1 \
        https://github.com/Homebrew/install.git \
        "$TMP_DIR/brew-install"

    /bin/bash "$TMP_DIR/brew-install/install.sh"
}

install_homebrew() {
    if detect_brew; then
        echo "Homebrew found: $BREW_BIN"
        return 0
    fi

    if ! install_homebrew_from_script_url; then
        install_homebrew_from_git_repo
    fi

    if ! detect_brew; then
        echo "Error: Homebrew installed, but brew binary was not found."
        exit 1
    fi

    echo "Homebrew ready: $BREW_BIN"
}

init_brew_env_for_current_script() {
    eval "$("$BREW_BIN" shellenv)"

    BREW_PREFIX="$(brew --prefix)"
    FISH_BIN="$BREW_PREFIX/bin/fish"
}

install_packages_with_brew() {
    brew update
    brew install fish fzf neovim lsd

    BREW_PREFIX="$(brew --prefix)"
    FISH_BIN="$BREW_PREFIX/bin/fish"
}

set_default_shell_to_fish() {
    if [ ! -x "$FISH_BIN" ]; then
        echo "Skip: fish binary not found: $FISH_BIN"
        return 0
    fi

    if [ "${SHELL:-}" = "$FISH_BIN" ]; then
        echo "Default shell already set to $FISH_BIN"
        return 0
    fi

    if ! grep -Fxq "$FISH_BIN" /etc/shells 2>/dev/null; then
        echo "Adding $FISH_BIN to /etc/shells..."

        if [ "$(id -u)" -eq 0 ]; then
            echo "$FISH_BIN" >> /etc/shells
        else
            echo "$FISH_BIN" | sudo tee -a /etc/shells >/dev/null
        fi
    fi

    if chsh -s "$FISH_BIN"; then
        echo "Default shell changed to: $FISH_BIN"
    else
        echo "Warning: chsh failed. Try running manually:"
        echo "  echo '$FISH_BIN' | sudo tee -a /etc/shells"
        echo "  chsh -s '$FISH_BIN'"
    fi
}

main() {
    backup_and_link "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"
    backup_and_link "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"

    install_homebrew
    init_brew_env_for_current_script
    install_packages_with_brew
    set_default_shell_to_fish

    echo "Switching to new fish..."
    exec "$FISH_BIN" -l
}

main "$@"
