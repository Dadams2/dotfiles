
# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Installation

### macOS

```bash
git clone git@github.com:Dadams2/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap-macos.sh  # Install packages
./install-macos.sh    # Stow configs
```

### Linux

```bash
git clone git@github.com:Dadams2/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap-linux.sh  # Install packages
./install-linux.sh    # Stow configs
```

## Included Configs

- **zsh, bash** - Shell configurations
- **tmux** - Terminal multiplexer
- **vim** - Text editor
- **kitty** - Terminal emulator
- **btop, bottom** - System monitors
- **git** - Git configuration

Linux also includes: i3, polybar, rofi, dunst, redshift, alacritty, cava, paru

## Uninstall

```bash
./uninstall.sh
```

## Manual Stow

```bash
stow zsh        # Install zsh config
stow -D zsh     # Remove zsh symlinks
```

