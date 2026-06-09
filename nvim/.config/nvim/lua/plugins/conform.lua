local registry = require "core.lang_reg"

return plugin {
  src = "stevearc/conform.nvim",
  event = "BufWritePre",
  config = function(opts)
    local formatters_by_ft = registry.get_all().formatters_by_ft
    local formatters = registry.get_all().formatters
    opts.formatters_by_ft =
      vim.tbl_extend("force", formatters_by_ft, opts.formatters_by_ft or {})
    opts.formatters = vim.tbl_extend("force", formatters, opts.formatters or {})
    require("conform").setup(opts)
  end,
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      sh = { "shfmt" },
      zsh = { "shfmt" },
      bash = { "shfmt" },
      markdown = { "mdformat" },
    },
    formatters = {
      mdformat = {
        append_args = { "--wrap", "80" },
      },
    },
    format_on_save = function(bufnr)
      if vim.g.autoformat == false then return end
      return { timeout_ms = 500, lsp_format = "fallback" }
    end,
  },
  keys = {
    {
      "n",
      "<leader>cf",
      function() require("conform").format { lsp_format = "fallback" } end,
      desc = "Format current file",
    },
  },
}
