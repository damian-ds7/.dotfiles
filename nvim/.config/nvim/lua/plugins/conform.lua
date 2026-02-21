return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  opts = {
    formatters_by_ft = {
      go = { "gofmt", "goimports", "golines" },
      lua = { "stylua" },
      tex = { "latexindent" },
      markdown = { "mdformat" },
    },
    formatters = {
      mdformat = {
        append_args = { "--wrap", "80" },
      },
    },
    format_on_save = {
      timeout = 500,
      lsp_format = "fallback",
    },
  },
  keys = {
    {
      "<leader>cf",
      function() require("conform").format { lsp_format = "fallback" } end,
      desc = "Format current file",
    },
  },
}
