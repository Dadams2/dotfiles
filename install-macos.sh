#!/usr/bin/env bash

set -e

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Error: This script is for macOS only!"
    exit 1
fi

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo "Error: GNU Stow is not installed!"
    echo "Install it with: brew install stow"
    exit 1
fi

# Get the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# Stow packages
PACKAGES=(zsh bash tmux vim kitty btop bottom)

echo "Stowing dotfiles..."
for pkg in "${PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        echo "  $pkg"
        stow -R "$pkg"
    fi
done

echo "done"
