call plug#begin('~/.vim/plugged')

" Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Nerd tree
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'ryanoasis/vim-devicons'
"file finding
Plug 'ctrlpvim/ctrlp.vim' " fuzzy find files

"for tmux finding
Plug 'christoomey/vim-tmux-navigator'

Plug 'arcticicestudio/nord-vim'
call plug#end()

colorscheme nord

"Some airline things
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

"nerd tree things
nmap <C-n> :NERDTreeToggle<CR>
vmap ++ <plug>NERDCommenterToggle
nmap ++ <plug>NERDCommenterToggle

inoremap jk <ESC>
:let mapleader=" "
:syntax on
:set wildmenu
:set encoding=utf-8
:set clipboard=unnamedplus

"reload config
nnoremap <C-s> :source ~/.vimrc<CR>

"tab settings
set shiftwidth=4 autoindent smartindent tabstop=4 softtabstop=4 expandtab 

"good search
:set hls is ic

"command status
:set laststatus=2 cmdheight=1

" turn hybrid line numbers on
:set number relativenumber

:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
:  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
:augroup END


"better uses for arrow keys
nnoremap <Up> :resize +2<CR> 
nnoremap <Down> :resize -2<CR>
nnoremap <Left> :vertical resize +2<CR>
nnoremap <Right> :vertical resize -2<CR>

