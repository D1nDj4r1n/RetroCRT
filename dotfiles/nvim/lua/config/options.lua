-- opcje jak w Twoim vimrc

local o = vim.opt

o.number = true
o.relativenumber = true
o.cursorline = true
o.showcmd = true
o.wildmenu = true

o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
o.autoindent = true
o.smartindent = true

o.wrap = true
o.linebreak = true
o.scrolloff = 5

o.ignorecase = true
o.smartcase = true
o.incsearch = true
o.hlsearch = true

o.undofile = true
o.swapfile = false
o.backup = false

o.termguicolors = true
o.clipboard = "unnamedplus"

o.laststatus = 2
o.showmode = false

-- netrw jak w Vimie
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 4
vim.g.netrw_winsize = 25
