local utils = require "utils.pack"

utils.ensure "https://github.com/mason-org/mason-lspconfig.nvim"

utils.add("https://github.com/mason-org/mason.nvim", function()
  vim.cmd.packadd "mason-lspconfig.nvim"
  require("mason").setup {
    ui = { border = "rounded" },
  }
end)

vim.keymap.set("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason" })

utils.add("https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim", function()
  local registry = require("core.lang_reg").get_all()
  local ensure = {}
  if registry.servers then vim.list_extend(ensure, vim.tbl_keys(registry.servers)) end
  if registry.tools then vim.list_extend(ensure, registry.tools) end
  require("mason-tool-installer").setup {
    ensure_installed = ensure,
    run_on_start = true,
  }
end)
