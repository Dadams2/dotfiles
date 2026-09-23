#!/usr/bin/env bash

set -e

echo "========================================"
echo "  Linux Package Bootstrap"
echo "========================================"
echo ""

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo -e "${RED}Error: This script is for Linux only!${NC}"
    exit 1
fi

echo -e "${BLUE}Operating System:${NC} Linux"
echo ""

# Detect package manager
PM=""
if command -v pacman &> /dev/null; then
    PM="pacman"
    echo -e "${BLUE}Package Manager:${NC} pacman (Arch-based)"
elif command -v apt &> /dev/null; then
    PM="apt"
    echo -e "${BLUE}Package Manager:${NC} apt (Debian-based)"
else
    echo -e "${RED}Error: No supported package manager found (pacman or apt)${NC}"
    exit 1
fi
echo ""

# Function to check if a package is installed
is_package_installed() {
    if [[ "$PM" == "pacman" ]]; then
        pacman -Q "$1" &> /dev/null
        return $?
    elif [[ "$PM" == "apt" ]]; then
        dpkg -l "$1" &> /dev/null 2>&1
        return $?
    fi
    return 1
}

# Function to install packages
install_packages() {
    local packages=("$@")
    local to_install=()
    
    for pkg in "${packages[@]}"; do
        if is_package_installed "$pkg"; then
            echo -e "${GREEN}✓${NC} $pkg is already installed"
        else
            to_install+=("$pkg")
        fi
    done
    
    if [ ${#to_install[@]} -gt 0 ]; then
        echo -e "${YELLOW}Installing:${NC} ${to_install[*]}"
        if [[ "$PM" == "pacman" ]]; then
            sudo pacman -S --noconfirm "${to_install[@]}"
        elif [[ "$PM" == "apt" ]]; then
            sudo apt update
            sudo apt install -y "${to_install[@]}"
        fi
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
    stow
)

# Add distro-specific packages
if [[ "$PM" == "pacman" ]]; then
    CORE_PACKAGES+=(
        fzf
        ripgrep
        fd
    )
elif [[ "$PM" == "apt" ]]; then
    CORE_PACKAGES+=(
        fzf
        ripgrep
        fd-find
    )
fi

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
    MONITOR_PACKAGES=(bottom)
    
    # btop is available in pacman but may need special handling on apt
    if [[ "$PM" == "pacman" ]]; then
        MONITOR_PACKAGES+=(btop)
    else
        echo -e "${YELLOW}Note:${NC} btop may need ./install_btop.sh on apt-based systems"
    fi
    
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

# Desktop environment tools
echo "========================================"
read -p "Install desktop environment tools? (i3, polybar, rofi, dunst, redshift) [y/N]: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [[ "$PM" == "pacman" ]]; then
        DE_PACKAGES=(
            i3-wm
            polybar
            rofi
            dunst
            redshift
        )
    elif [[ "$PM" == "apt" ]]; then
        DE_PACKAGES=(
            i3
            polybar
            rofi
            dunst
            redshift
        )
    fi
    
    install_packages "${DE_PACKAGES[@]}"
    
    # Note about paru (AUR helper for Arch)
    if [[ "$PM" == "pacman" ]]; then
        echo ""
        if command -v paru &> /dev/null; then
            echo -e "${GREEN}✓${NC} paru (AUR helper) is already installed"
        else
            echo -e "${YELLOW}Note:${NC} paru (AUR helper) not found."
            echo "Install manually from: https://github.com/Morganamilo/paru"
        fi
    fi
fi
echo ""

# Rust CLI tools via cargo
echo "========================================"
read -p "Install Rust CLI tools via cargo? (git-delta, zoxide, eza, hyperfine) [y/N]: " -n 1 -r
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
        cargo install git-delta zoxide eza hyperfine
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
echo -e "   ${YELLOW}./install-linux.sh${NC}"
echo ""
echo "2. Restart your terminal or run: source ~/.zshrc"
echo ""
if [ -f "./install_btop.sh" ]; then
    echo "3. For btop (if needed), run: ./install_btop.sh"
    echo ""
fi
