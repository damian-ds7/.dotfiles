return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    opts = {
      ui = { border = "rounded" },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = false,
    dependencies = { "mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim" },
    config = function()
      local registry = require("core.lang_reg").get_all()
      local ensure = {}

      if registry.servers then vim.list_extend(ensure, vim.tbl_keys(registry.servers)) end

      if registry.tools then vim.list_extend(ensure, registry.tools) end

      require("mason-tool-installer").setup {
        ensure_installed = ensure,
        run_on_start = true,
      }
    end,
  },
}
