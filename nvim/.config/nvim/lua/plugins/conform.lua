local utils = require "utils.pack"
local registry = require "core.lang_reg"

utils.add(utils.gh "stevearc/conform.nvim", function()
  local formatters_by_ft = registry.get_all().formatters
  formatters_by_ft = vim.tbl_extend("force", formatters_by_ft, {
    lua = { "stylua" },
    tex = { "latexindent" },
    sh = { "shfmt" },
    zsh = { "shfmt" },
    bash = { "shfmt" },
    markdown = { "mdformat" },
  })
  require("conform").setup {
    formatters_by_ft = formatters_by_ft,
    formatters = {
      mdformat = {
        append_args = { "--wrap", "80" },
      },
    },
    format_on_save = {
      timeout = 500,
      lsp_format = "fallback",
    },
  }
end, "event:BufWritePre")

vim.keymap.set(
  "n",
  "<leader>cf",
  function() require("conform").format { lsp_format = "fallback" } end,
  { desc = "Format current file" }
)
