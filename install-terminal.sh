#!/usr/bin/env bash

set -e

# Install GNU Stow to ~/.local without root
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
if ! command -v stow &>/dev/null; then
    tmp=$(mktemp -d)
    wget -qO- https://ftp.gnu.org/gnu/stow/stow-2.4.0.tar.gz | tar -xz -C "$tmp"
    (cd "$tmp/stow-2.4.0" && ./configure --prefix="$HOME/.local" -q && make -s && make install -s)
    rm -rf "$tmp"
fi

# Get the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# Stow packages
PACKAGES=(zsh bash tmux vim kitty btop bottom git)

echo "Stowing dotfiles..."
for pkg in "${PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        echo "  $pkg"
        stow -R "$pkg"
    fi
done

echo "Done!"
