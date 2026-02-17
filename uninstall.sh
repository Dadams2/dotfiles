#!/usr/bin/env bash

set -e

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo "Error: GNU Stow is not installed!"
    exit 1
fi

# Get the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# Unstow all packages
PACKAGES=(zsh bash tmux vim kitty btop bottom git alacritty cava paru polybar rofi dunst redshift i3)

echo "Unstowing dotfiles..."
for pkg in "${PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        echo "  $pkg"
        stow -D "$pkg" 2>/dev/null || true
    fi
done

echo "Done!"
