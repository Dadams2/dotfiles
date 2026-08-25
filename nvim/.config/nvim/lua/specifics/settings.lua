vim.opt.termguicolors = true

-- make line numbers default
vim.opt.number = true

-- relative line numbers are the best
vim.opt.relativenumber = true

vim.smartindent = true

vim.opt.guicursor = 'n-v-c:block,i-ci-ve:hor40,r-cr:hor20,o:hor50,a:blinkwait10-blinkoff5-blinkon5-Cursor'

-- enable mouse mode, useful for resizing splits
vim.opt.mouse = 'a'

-- tabs are superior
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

vim.opt.shiftwidth = 4
vim.opt.textwidth = 120
vim.opt.colorcolumn = "120"

vim.opt.expandtab = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- vim.opt.wrap = true -- Set to true if you want to wrap lines
vim.opt.scrolloff = 30
vim.opt.updatetime = 50

vim.opt.signcolumn = 'yes'


vim.g.default_terminal = "tmux-256color"

-- Enable undo/redo changes even after closing and reopening file
vim.o.undofile = true

-- configure how splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- shows what line the cursor is on
vim.o.cursorline = true

-- minimum number of screen lines to keep above and below the cursor
vim.o.scrolloff = 10

-- Sync clipboard between os an Neovim
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
