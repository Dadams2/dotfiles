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
