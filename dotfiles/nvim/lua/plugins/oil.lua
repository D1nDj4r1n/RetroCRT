-- ręcznie zainstalowany: pack/retro/start/oil.nvim

local ok, oil = pcall(require, "oil")
if not ok then
  vim.notify("oil.nvim nie znaleziony — sprawdź git clone", vim.log.levels.WARN)
  return
end

oil.setup({
  view_options = {
    show_hidden = true,
  },
  keymaps = {
    ["q"] = "actions.close",
    ["<C-h>"] = false, -- nie kłóć się z nawigacją okien
    ["<C-l>"] = false,
  },
})

-- Space e = oil zamiast Lexplore
vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { desc = "oil files" })
