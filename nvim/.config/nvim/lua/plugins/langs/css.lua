local registry = require "core.lang_reg"

local lang = {
  tools = { "prettier" },
  treesitter = { "css" },
}

registry.register(lang)

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        css = { "prettier" },
      },
    },
  },
}
