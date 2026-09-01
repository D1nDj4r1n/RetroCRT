-- Leader is set in init.lua, before anything is mapped.
local map = vim.keymap.set

-- <leader>e opens oil.nvim, the file explorer inside Neovim.
-- Yazi stays where it belongs: in the terminal, not in here.
map('n', '<leader>e', function()
  local ok, oil = pcall(require, 'oil')
  if ok then
    oil.open()
  else
    vim.notify('oil.nvim is not installed, run :PackEnsure', vim.log.levels.WARN)
  end
end, { desc = 'File explorer (oil)' })

map('n', '<leader><space>', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })

map('n', '<C-h>', '<C-w>h', { desc = 'Window left' })
map('n', '<C-j>', '<C-w>j', { desc = 'Window down' })
map('n', '<C-k>', '<C-w>k', { desc = 'Window up' })
map('n', '<C-l>', '<C-w>l', { desc = 'Window right' })

-- Diagnostics are part of the IDE role; the keys work with or without an LSP.
map('n', '<leader>dd', vim.diagnostic.open_float, { desc = 'Diagnostic under cursor' })
map('n', '<leader>dl', vim.diagnostic.setloclist, { desc = 'Diagnostics to loclist' })

map('t', '<C-\\><C-n>', '<C-\\><C-n>', { desc = 'Leave terminal mode' })
