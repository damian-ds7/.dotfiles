return {
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    config = function(_, opts)
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local registry = require("core.lang_reg").get_all()

      opts.servers = opts.servers or {}

      if registry.servers then opts.servers = vim.tbl_deep_extend("force", opts.servers, registry.servers) end

      for server, server_opts in pairs(opts.servers) do
        local server_name = type(server) == "table" and server[1] or server

        server_opts.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server_opts.capabilities or {})
        vim.lsp.config(server_name, server_opts)
        vim.lsp.enable(server_name)
      end
    end,
  },
}
