#!/bin/bash 

#install yay
git clone https://aur.archlinux.org/yay.git
cd yay 
makepkg -si --noconfirm
cd ..

#install utilities
sudo pacman -S --noconfirm xorg xorg-xinit

#install favourite programs 
sudo pacman -S --noconfirm tmux vim zsh alacritty neovim

#install awesome
sudo pacman -S --noconfirm awesome

#zsh bs
zsh
# Post install of tools
## oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

zsh

## powerline
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

## Tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


## vim plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

## colorls
sudo pacman -S ruby --noconfirm
gem install colorls

## autojump
git clone https://aur.archlinux.org/autojump.git
cd autojump
makepkg -si --noconfirm
cd ..

## zsh syntax highilghting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

#install dotfiles
config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

#mkdir -p .config-bakup && \
#    $config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} xargs -I{} mv {} .config-backup/{}

#$config checkout

#$config config --local status.showUntrackedfiles no

$config reset --hard

# install fonts
git clone https://aur.archlinux.org/ttf-meslo-nerd-font-powerlevel10k.git
cd ttf-meslo-nerd-font-powerlevel10k
makepkg -si --noconfirm
cd ..
rm -rf ttf-meslo-nerd-font-powerlevel10k 

# set everything up
sudo chsh -s /bin/zsh
tmux source .tmux.conf
~/.tmux/plugins/tmp/scripts/install_plugins.sh
nvim +PlugInstall +qall

echo "startx to start"
source .zshrc
