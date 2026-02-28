local registry = require "core.lang_reg"

local lang = {
  servers = {
    hls = {},
  },

  tools = { "haskell-debug-adapter" },

  treesitter = { "haskell" },
}

registry.register(lang)

return {}
