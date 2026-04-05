local registry = require "core.lang_reg"

local lang = {
  servers = {
    hls = { mason_name = "haskell-language-server" },
  },

  tools = { "haskell-debug-adapter" },

  treesitter = { "haskell" },
}

registry.register(lang)

return {}
