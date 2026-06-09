return {
  plugin {
    src = "mason-org/mason.nvim",
    opts = {
      ui = { border = "rounded" },
    },
    keys = {
      { "n", "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
    },
  },
  plugin {
    src = "WhoIsSethDaniel/mason-tool-installer.nvim",
    config = function()
      local registry = require("core.lang_reg").get_all()
      local ensure = {}
      if registry.servers then
        for server, opts in pairs(registry.servers) do
          table.insert(ensure, (opts.mason_name or server))
        end
      end
      if registry.tools then vim.list_extend(ensure, registry.tools) end
      require("mason-tool-installer").setup {
        ensure_installed = ensure,
        run_on_start = true,
      }
    end,
  },
}
