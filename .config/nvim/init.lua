-- Neovim is the IDE. Vim remains the lightweight system editor.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.clipboard:append("unnamedplus")

require("lib.pack").setup()
vim.cmd.colorscheme("retrocrt")

pcall(vim.cmd, "packadd oil.nvim")
require("retrocrt.oil").setup()

vim.keymap.set("n", "<leader>e", function()
  local ok, oil = pcall(require, "oil")
  if not ok then
    vim.notify("oil.nvim is missing; run :PackEnsure", vim.log.levels.WARN)
    return
  end
  oil.open()
end, { desc = "Open oil file explorer" })

_G.retrocrt_statusline = function()
  local mode = vim.fn.mode(1)
  local group, label
  if mode:match("^[iR]") then
    group, label = "RetroStatusInsert", " INSERT "
  elseif mode:match("^[vV\22sS\19]") then
    group, label = "RetroStatusVisual", " VISUAL "
  else
    group, label = "RetroStatusNormal", " NORMAL "
  end

  return table.concat({
    "%#",
    group,
    "#",
    label,
    "%#StatusLine# %f %m%r%=",
    "%y  %l:%c  %p%% ",
  })
end

vim.opt.statusline = "%!v:lua.retrocrt_statusline()"
vim.opt.laststatus = 2
