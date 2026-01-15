return {
  "stevearc/conform.nvim",
  opts = {
    formatters = {
      mdformat = {
        append_args = { "--wrap", "80" },
      },
    },
    formatters_by_ft = {
      markdown = { "mdformat" },
    },
  },
}
