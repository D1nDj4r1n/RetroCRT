-- Space leader — mapowania jak w Vimie

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "save" })
vim.keymap.set("n", "<leader>q", "<cmd>quit<cr>", { desc = "quit" })
vim.keymap.set("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "clear search" })
vim.keymap.set("n", "<leader>e", "<cmd>Lexplore<cr>", { desc = "file panel" })

vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
