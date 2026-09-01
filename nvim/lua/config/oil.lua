-- oil.nvim — the file explorer inside Neovim.
--
-- It edits a directory as if it were a buffer, which is why it lives here and
-- not in the terminal. Yazi is the terminal file manager and is not affected
-- by anything in this file.
--
-- Columns are text rather than icons: no Nerd Font dependency, and the same
-- information density as `ls -l`. Colours come from the retrocrt Oil* groups.

local ok, oil = pcall(require, 'oil')
if not ok then
  return
end

oil.setup({
  default_file_explorer = true,
  columns = { 'permissions', 'size', 'mtime' },
  delete_to_trash = true,
  skip_confirm_for_simple_edits = false,
  view_options = {
    show_hidden = true,
  },
  win_options = {
    signcolumn = 'no',
    cursorline = true,
  },
  keymaps = {
    ['g?'] = 'actions.show_help',
    ['<CR>'] = 'actions.select',
    ['<C-s>'] = { 'actions.select', opts = { vertical = true } },
    ['<C-p>'] = 'actions.preview',
    ['<C-c>'] = 'actions.close',
    ['-'] = 'actions.parent',
    ['_'] = 'actions.open_cwd',
    ['gs'] = 'actions.change_sort',
    ['g.'] = 'actions.toggle_hidden',
  },
})
