local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = augroup("kickstart-highlight-yank", { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

autocmd("ColorScheme", {
  desc = "Set inlay hints color",
  group = augroup("inlay-hints-bg", { clear = true }),
  callback = function() vim.api.nvim_set_hl(0, "LspInlayHint", { link = "Comment" }) end,
})
