

# install oh my bash
git clone git://github.com/ohmybash/oh-my-bash.git ~/.oh-my-bash

# install vim plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PlugInstall +qall

source .bashrc
