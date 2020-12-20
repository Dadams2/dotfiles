#!/bin/bash 

#install yay
git clone https://aur.archlinux.org/yay.git
cd yay 
makepkg -si
cd ..

#install utilities
sudo pacman -S --noconfirm xorg-server 

#install favourite programs 
sudo pacman -S --noconfirm tmux vim zsh alacritty

#install awesome
sudo pacman -S --noconfirm awesome

#install dotfiles
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

mkdir -p .config-bakup && \
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} xargs -I{} mv {} .config-backup/{}

config checkout

config config --local status.showUntrackedfiles no
