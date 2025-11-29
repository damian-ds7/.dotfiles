-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = LazyVim.safe_keymap_set

map("n", "<C-d>", "<C-d>zz", { desc = "Jump half page down and center view" })
map("n", "<C-u>", "<C-u>zz", { desc = "Jump half page up and center view" })

map("n", "n", "'Nn'[v:searchforward].'zzzv'", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zzzv'", { expr = true, desc = "Prev Search Result" })

map("n", "<leader>ko", function()
  require("telescope").extensions.file_browser.file_browser({
    path = vim.fn.getcwd(),
    cwd = vim.fn.getcwd(),
    hidden = true,
    grouped = true,
    initial_mode = "insert",
  })
end, { desc = "Change directory with file browser" })

map("n", "<leader>kO", function()
  require("telescope").extensions.file_browser.file_browser({
    path = vim.fn.expand("~"),
    cwd = vim.fn.expand("~"),
    hidden = true,
    grouped = true,
    initial_mode = "insert",
  })
end, { desc = "Change directory from home" })

map("n", "<leader>kp", function()
  require("telescope").extensions.project.project({ display_type = "full" })
end, { desc = "Open project picker" })
