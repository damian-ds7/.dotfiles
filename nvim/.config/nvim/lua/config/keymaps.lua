-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

map("i", "df", "<Esc>", { noremap = true })

map("n", "<C-d>", "<C-d>zz", { desc = "Jump half page down and center view" })
map("n", "<C-u>", "<C-u>zz", { desc = "Jump half page up and center view" })

map("n", "n", "'Nn'[v:searchforward].'zzzv'", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zzzv'", { expr = true, desc = "Prev Search Result" })

map("v", "<leader>p", '"_dP', { desc = "Paste over currently selected text without yanking it" })

map("i", "<A-.>", " -> ", { noremap = true, silent = true })
