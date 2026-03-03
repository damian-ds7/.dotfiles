if true then return {} end

local registry = require "core.lang_reg"

local lang = {
  servers = {
    qmlls = {
      cmd = { "qmlls", "-E" },
    },
  },

  treesitter = { "qmljs" },
}

registry.register(lang)

return {}
