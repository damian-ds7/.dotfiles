return plugin {
  src = "neovim/nvim-lspconfig",
  lazy = true,
  config = function()
    local capabilities = require("blink.cmp").get_lsp_capabilities()
    for server, opts in pairs(require("core.lang_reg").get_servers()) do
      opts = vim.tbl_deep_extend("force", {}, opts)
      opts.capabilities = vim.tbl_deep_extend("force", {}, capabilities, opts.capabilities or {})
      vim.lsp.config(server, opts)
      vim.lsp.enable(server)
    end
  end,
}
