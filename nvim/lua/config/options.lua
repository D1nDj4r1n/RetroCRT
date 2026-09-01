-- Editor behaviour. Appearance belongs to lua/retrocrt.
local o = vim.opt

o.termguicolors = true
o.background = 'dark'

o.number = true
o.relativenumber = true
o.cursorline = true
o.signcolumn = 'yes'
o.scrolloff = 4
o.sidescrolloff = 8
o.wrap = false

o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
o.smartindent = true

o.ignorecase = true
o.smartcase = true
o.incsearch = true
o.hlsearch = true

o.splitbelow = true
o.splitright = true
o.laststatus = 2
o.showmode = false -- the statusline reports the mode

o.list = true
o.listchars = { tab = '› ', trail = '·', nbsp = '␣', extends = '›', precedes = '‹' }

o.undofile = true
o.swapfile = false
o.backup = false
o.writebackup = false

o.updatetime = 300
o.timeoutlen = 500
o.mouse = ''

-- Wayland: wl-clipboard is the provider Neovim picks up automatically.
o.clipboard = 'unnamedplus'
