-- Options
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

local opt = vim.opt

-- Appearance
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.cmdheight = 2
opt.scrolloff = 3
opt.colorcolumn = "80"

-- Search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = false
opt.autoindent = true
opt.smartindent = true

-- Folding
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevelstart = 99

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Wrapping
opt.wrap = true
opt.linebreak = true

-- Backups
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true

-- Completion
opt.completeopt = "menu,menuone,noselect"

-- Clipboard
opt.clipboard = "unnamed"

-- Misc
opt.mouse = "a"
opt.updatetime = 300
opt.timeoutlen = 500
opt.hidden = true
opt.fileformats = "unix,dos,mac"
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"