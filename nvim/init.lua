-- ~/.config/nvim/init.lua — the IDE.
--
-- Vim is the lightweight editor; this is the one that gets LSP, language
-- configuration and oil.nvim. Load order is explicit on purpose:
-- options, keys, plugins, colours, plugin configuration.

-- Before any mapping is defined.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('config.options')
require('config.keymaps')

-- Plugins: plain git checkouts under pack/retro, loaded by hand.
local pack = require('lib.pack')
pack.setup()
pack.load('oil.nvim')

vim.cmd.colorscheme('retrocrt')

require('config.statusline')
require('config.oil')
