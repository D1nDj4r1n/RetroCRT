-- ~/.config/nvim/init.lua
-- Most z Vima — bez pluginów

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.cmd.colorscheme('retrocrt')

require("config.options")
require("config.keymaps")
require("config.ui")
require("plugins.oil")
