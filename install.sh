#!/bin/bash 

#install yay
git clone https://aur.archlinux.org/yay.git
cd yay 
makepkg -si
cd ..

#install utilities
sudo pacman -S --noconfirm xorg-server 

#install favourite programs 
sudo pacman -S --noconfirm tmux vim zsh alacritty neovim

#install awesome
sudo pacman -S --noconfirm awesome


#install dotfiles
config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

mkdir -p .config-bakup && \
    $config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} xargs -I{} mv {} .config-backup/{}

$config checkout

$config config --local status.showUntrackedfiles no

# Post install of tools
## oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

## powerline
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

## Tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


## vim plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

## colorls
sudo pacman -S ruby --noconfirm
gem install colorls

# install fonts
git clone https://aur.archlinux.org/packages/ttf-meslo-nerd-font-powerlevel10k/
cd ttf-meslo-nerd-font-powerlevel10k
makepkg -si
cd ..
rm -rf ttf-meslo-nerd-font-powerlevel10k 

# set everything up

source .zshrc
tmux source .tmux.conf
~/.tmux/plugins/tmp/scripts/install_plugins.sh
nvim +PlugInstall +qall

echo "startx to start"
