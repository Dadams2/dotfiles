#!/usr/bin/env bash

set -e

echo "========================================"
echo "  macOS Package Bootstrap"
echo "========================================"
echo ""

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}Error: This script is for macOS only!${NC}"
    exit 1
fi

echo -e "${BLUE}Operating System:${NC} macOS"
echo ""

# Check and install Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    echo -e "${GREEN}✓${NC} Homebrew installed"
else
    echo -e "${GREEN}✓${NC} Homebrew is already installed"
fi
echo ""

# Function to check if a brew package is installed
is_brew_installed() {
    brew list "$1" &> /dev/null
    return $?
}

# Function to install packages
install_packages() {
    local packages=("$@")
    local to_install=()
    
    for pkg in "${packages[@]}"; do
        if is_brew_installed "$pkg"; then
            echo -e "${GREEN}✓${NC} $pkg is already installed"
        else
            to_install+=("$pkg")
        fi
    done
    
    if [ ${#to_install[@]} -gt 0 ]; then
        echo -e "${YELLOW}Installing:${NC} ${to_install[*]}"
        brew install "${to_install[@]}"
    fi
}

# Core packages (always install)
echo "========================================"
echo "Installing core packages..."
echo "========================================"
CORE_PACKAGES=(
    git
    zsh
    vim
    tmux
    herdr
    stow
    fzf
    ripgrep
    fd
    zoxide
    eza
)
install_packages "${CORE_PACKAGES[@]}"
echo ""

# Terminal emulators
echo "========================================"
read -p "Install terminal emulators? (alacritty, kitty) [y/N]: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    TERMINAL_PACKAGES=(alacritty kitty)
    install_packages "${TERMINAL_PACKAGES[@]}"
fi
echo ""

# System monitors
echo "========================================"
read -p "Install system monitors? (btop, bottom) [y/N]: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    MONITOR_PACKAGES=(btop bottom)
    install_packages "${MONITOR_PACKAGES[@]}"
fi
echo ""

# Audio visualizer
echo "========================================"
read -p "Install audio visualizer? (cava) [y/N]: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_packages cava
fi
echo ""

# Rust CLI tools via cargo
echo "========================================"
read -p "Install Rust CLI tools via cargo? (git-delta, ripgrep, fd, zoxide, eza, hyperfine) [y/N]: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if ! command -v cargo &> /dev/null; then
        echo -e "${YELLOW}Rust not found. Installing Rust...${NC}"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        echo -e "${GREEN}✓${NC} Rust installed"
    fi
    
    if command -v cargo &> /dev/null; then
        echo -e "${YELLOW}Installing Rust CLI tools...${NC}"
        cargo install git-delta ripgrep fd-find zoxide bottom eza hyperfine
        echo -e "${GREEN}✓${NC} Rust CLI tools installed"
    else
        echo -e "${RED}Error: cargo not found after installation attempt${NC}"
    fi
fi
echo ""

# Change default shell to zsh
echo "========================================"
if [ "$SHELL" != "$(which zsh)" ]; then
    read -p "Change default shell to zsh? [y/N]: " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        chsh -s "$(which zsh)"
        echo -e "${GREEN}✓${NC} Default shell changed to zsh (restart required)"
    fi
else
    echo -e "${GREEN}✓${NC} Default shell is already zsh"
fi
echo ""

echo "========================================"
echo -e "${GREEN}Bootstrap complete!${NC}"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Run the dotfiles install script:"
echo -e "   ${YELLOW}./install-macos.sh${NC}"
echo ""
echo "2. Restart your terminal or run: source ~/.zshrc"
echo ""
