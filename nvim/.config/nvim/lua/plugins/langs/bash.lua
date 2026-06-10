return lang {
  eager = true,
  filetype = { "bash", "sh", "zsh" },
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
