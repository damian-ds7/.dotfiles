local registry = require "core.lang_reg"

local lang = {
  tools = { "prettier" },
  treesitter = { "css" },
  formatters = {
    css = { "prettier" },
  },
}

registry.register(lang)

return {}
