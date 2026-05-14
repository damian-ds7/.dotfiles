return lang {
  servers = {
    bashls = {
      mason_name = "bash-language-server",
      filetypes = { "bash", "zsh", "sh" },
      ---@type lspconfig.settings.bashls
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
