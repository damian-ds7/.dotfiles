local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = augroup("highlight-yank", { clear = true }),
  callback = function()
    if vim.version().minor < 13 then
      -- TODO: remove
      vim.hl.on_yank()
    else
      vim.hl.hl_op()
    end
  end,
})

autocmd("ColorScheme", {
  desc = "Set inlay hints color",
  group = augroup("inlay-hints-bg", { clear = true }),
  callback = function() vim.api.nvim_set_hl(0, "LspInlayHint", { link = "Comment" }) end,
})

autocmd("BufWritePre", {
  desc = "Remove trailing whitespaces on save",
  group = augroup("trim-whitespace", { clear = true }),
  pattern = "*",
  callback = function()
    local view = vim.fn.winsaveview()
    vim.cmd [[%s/\s\+$//e]]
    vim.fn.winrestview(view)
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  desc = "Remove scrolloff in terminal buffers",
  group = augroup("term-scrolloff", { clear = true }),
  callback = function()
    vim.opt_local.scrolloff = 0
    if vim.version().minor >= 13 then vim.opt_local.scrolloffpad = 0 end
  end,
})
