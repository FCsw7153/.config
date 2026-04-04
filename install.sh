#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.config}"
LOCAL_BIN="$HOME/.local/bin"
LOCAL_OPT="$HOME/.local/opt"
FISH_BIN="$LOCAL_OPT/fish"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$LOCAL_BIN" "$LOCAL_OPT" "$HOME/.config/fish"

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

ensure_line() {
    local line="$1"
    local file="$2"
    mkdir -p "$(dirname "$file")"
    touch "$file"
    grep -Fqx "$line" "$file" || printf '%s\n' "$line" >> "$file"
}

detect_arch() {
    case "$(uname -m)" in
        x86_64) ARCH="x86_64" ;;
        aarch64|arm64) ARCH="aarch64" ;;
        *) echo "Unsupported arch: $(uname -m)"; exit 1 ;;
    esac
}

install_latest_fzf_linux() {
    local ver fzf_arch url

    case "$ARCH" in
        x86_64) fzf_arch="linux_amd64" ;;
        aarch64) fzf_arch="linux_arm64" ;;
    esac

    ver="$(curl -fsSL https://api.github.com/repos/junegunn/fzf/releases/latest \
        | grep '"tag_name"' | head -n1 | sed -E 's/.*"v([^"]+)".*/\1/')"
    url="https://github.com/junegunn/fzf/releases/download/v${ver}/fzf-${ver}-${fzf_arch}.tar.gz"

    curl -fL "$url" -o "$TMP_DIR/fzf.tgz"
    tar -xzf "$TMP_DIR/fzf.tgz" -C "$TMP_DIR"
    install -m 0755 "$TMP_DIR/fzf" "$LOCAL_BIN/fzf"

    echo "fzf installed: $("$LOCAL_BIN/fzf" --version)"
}

install_latest_fish_linux() {
    local ver fish_arch url

    case "$ARCH" in
        x86_64) fish_arch="x86_64" ;;
        aarch64) fish_arch="aarch64" ;;
    esac

    ver="$(curl -fsSL https://api.github.com/repos/fish-shell/fish-shell/releases/latest \
        | grep '"tag_name"' | head -n1 | sed -E 's/.*"([^"]+)".*/\1/')"
    url="https://github.com/fish-shell/fish-shell/releases/download/${ver}/fish-${ver}-linux-${fish_arch}.tar.xz"

    curl -fL "$url" -o "$TMP_DIR/fish.tar.xz"
    tar -xJf "$TMP_DIR/fish.tar.xz" -C "$TMP_DIR"
    install -m 0755 "$TMP_DIR/fish" "$FISH_BIN"

    echo "fish installed: $("$FISH_BIN" --version)"
}

set_default_shell_to_fish() {
    if ! command -v chsh >/dev/null 2>&1; then
        echo "Skip: chsh not found, cannot set default shell automatically."
        return 0
    fi

    if [ ! -x "$FISH_BIN" ]; then
        echo "Skip: fish binary not found: $FISH_BIN"
        return 0
    fi

    if [ "${SHELL:-}" = "$FISH_BIN" ]; then
        echo "Default shell already set to $FISH_BIN"
        return 0
    fi

    if [ -r /etc/shells ] && grep -Fxq "$FISH_BIN" /etc/shells; then
        if chsh -s "$FISH_BIN" "$USER"; then
            echo "Default shell changed to: $FISH_BIN"
        else
            echo "Warning: failed to change default shell via chsh."
        fi
    else
        echo "Skip: $FISH_BIN is not listed in /etc/shells, so chsh will likely refuse it."
        echo "You can still start fish manually with: $FISH_BIN -l"
    fi
}

main() {
    detect_arch

    backup_and_link "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"
    backup_and_link "$DOTFILES/zsh/zimrc" "$HOME/.zimrc"
    backup_and_link "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"
    backup_and_link "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"

    install_latest_fzf_linux
    install_latest_fish_linux

    ensure_line 'fish_add_path -p ~/.local/bin' "$HOME/.config/fish/config.fish"
    ensure_line 'fish_add_path -p ~/.local/opt' "$HOME/.config/fish/config.fish"

    export PATH="$LOCAL_BIN:$LOCAL_OPT:$PATH"

    set_default_shell_to_fish

    echo "Switching to new fish..."
    exec "$FISH_BIN" -l
}

main "$@"
