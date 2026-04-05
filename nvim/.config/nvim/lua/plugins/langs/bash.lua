local registry = require "core.lang_reg"

local lang = {
  servers = {
    bashls = {
      mason_name = "bash-language-server",
      filetypes = { "bash", "zsh", "sh" },
      settings = {
        bashIde = {
          shellcheckPath = vim.fn.stdpath "data" .. "/mason/bin/shellcheck",
        },
      },
    },
  },

  tools = { "shfmt", "shellcheck" },

  treesitter = { "bash", "zsh" },
}

registry.register(lang)
