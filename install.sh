#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.config}"
LOCAL_BIN="$HOME/.local/bin"
LOCAL_OPT="$HOME/.local/opt"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Using DOTFILES=$DOTFILES"

mkdir -p "$LOCAL_BIN" "$LOCAL_OPT"

backup_and_link() {
    local src="$1"
    local dst="$2"

    if [ ! -e "$src" ]; then
        echo "Skip: source not found: $src"
        return 0
    fi

    if [ -L "$dst" ]; then
        echo "Replacing symlink: $dst"
        rm -f "$dst"
    elif [ -e "$dst" ]; then
        echo "Backing up $dst -> $dst.bak"
        mv "$dst" "$dst.bak"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "Linked: $dst -> $src"
}

detect_os() {
    case "$(uname -s)" in
        Linux)  OS="linux" ;;
        Darwin) OS="macos" ;;
        *) echo "Unsupported OS: $(uname -s)"; exit 1 ;;
    esac
}

detect_arch() {
    case "$(uname -m)" in
        x86_64) ARCH="x86_64" ;;
        aarch64|arm64) ARCH="aarch64" ;;
        *) echo "Unsupported arch: $(uname -m)"; exit 1 ;;
    esac
}

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Missing required command: $1"
        exit 1
    }
}

download_latest_fzf_linux() {
    echo "Installing latest fzf to $LOCAL_BIN/fzf"

    need_cmd curl
    need_cmd tar
    need_cmd grep
    need_cmd sed
    need_cmd head

    local ver
    local fzf_arch
    local url

    case "$ARCH" in
        x86_64) fzf_arch="linux_amd64" ;;
        aarch64) fzf_arch="linux_arm64" ;;
        *) echo "Unsupported fzf arch: $ARCH"; exit 1 ;;
    esac

    ver="$(curl -fsSL https://api.github.com/repos/junegunn/fzf/releases/latest \
        | grep '"tag_name"' | head -n1 | sed -E 's/.*"v([^"]+)".*/\1/')"

    url="https://github.com/junegunn/fzf/releases/download/v${ver}/fzf-${ver}-${fzf_arch}.tar.gz"

    curl -fL "$url" -o "$TMP_DIR/fzf.tgz"
    tar -xzf "$TMP_DIR/fzf.tgz" -C "$TMP_DIR"

    install -m 0755 "$TMP_DIR/fzf" "$LOCAL_BIN/fzf"
    echo "fzf installed: $("$LOCAL_BIN/fzf" --version)"
}

install_fzf_macos() {
    if command -v brew >/dev/null 2>&1; then
        echo "Installing/upgrading fzf with Homebrew"
        brew install fzf
    else
        echo "Homebrew not found, skip fzf install on macOS"
    fi
}

download_latest_fish_linux() {
    echo "Installing latest fish to $LOCAL_OPT/fish"

    need_cmd curl
    need_cmd tar
    need_cmd grep
    need_cmd sed
    need_cmd head

    local ver
    local fish_arch
    local url

    case "$ARCH" in
        x86_64) fish_arch="x86_64" ;;
        aarch64) fish_arch="aarch64" ;;
        *) echo "Unsupported fish arch: $ARCH"; exit 1 ;;
    esac

    ver="$(curl -fsSL https://api.github.com/repos/fish-shell/fish-shell/releases/latest \
        | grep '"tag_name"' | head -n1 | sed -E 's/.*"([^"]+)".*/\1/')"

    url="https://github.com/fish-shell/fish-shell/releases/download/${ver}/fish-${ver}-linux-${fish_arch}.tar.xz"

    curl -fL "$url" -o "$TMP_DIR/fish.tar.xz"
    tar -xJf "$TMP_DIR/fish.tar.xz" -C "$TMP_DIR"

    # 这个 tar 包里解出来是单独的 fish 二进制
    install -m 0755 "$TMP_DIR/fish" "$LOCAL_OPT/fish"

    echo "fish installed: $("$LOCAL_OPT/fish" --version)"
}

install_fish_macos() {
    if command -v brew >/dev/null 2>&1; then
        echo "Installing/upgrading fish with Homebrew"
        brew install fish
    else
        echo "Homebrew not found, skip fish install on macOS"
    fi
}

maybe_set_default_shell_linux() {
    if [ ! -x "$LOCAL_OPT/fish" ]; then
        echo "Skip setting default shell: $LOCAL_OPT/fish not found"
        return 0
    fi

    if [ "${SET_DEFAULT_FISH:-0}" != "1" ]; then
        echo "Skip changing default shell. Set SET_DEFAULT_FISH=1 to enable."
        return 0
    fi

    if command -v sudo >/dev/null 2>&1; then
        if ! grep -qx "$LOCAL_OPT/fish" /etc/shells 2>/dev/null; then
            echo "$LOCAL_OPT/fish" | sudo tee -a /etc/shells >/dev/null
        fi
        chsh -s "$LOCAL_OPT/fish" || true
        echo "Default shell changed to $LOCAL_OPT/fish"
    else
        echo "sudo not found, skip changing default shell"
    fi
}

link_dotfiles() {
    echo "Creating symlinks..."

    backup_and_link "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"
    backup_and_link "$DOTFILES/zsh/zimrc" "$HOME/.zimrc"
    backup_and_link "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"
    backup_and_link "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"

    # 如果你的 repo 不在 ~/.config，可打开下面这行
    # backup_and_link "$DOTFILES/fish/config.fish" "$HOME/.config/fish/config.fish"
}

main() {
    detect_os
    detect_arch

    link_dotfiles

    if [ "$OS" = "linux" ]; then
        download_latest_fzf_linux
        download_latest_fish_linux
        maybe_set_default_shell_linux

        echo
        echo "Add this to the top of ~/.config/fish/config.fish if not already present:"
        echo 'fish_add_path -p ~/.local/opt'
        echo 'fish_add_path -p ~/.local/bin'
        echo
        echo "Then start the new fish manually once:"
        echo '~/.local/opt/fish'
    else
        install_fzf_macos
        install_fish_macos
        echo
        echo "On macOS, fish/fzf were installed via Homebrew if available."
    fi

    echo "Done!"
}

main "$@"
