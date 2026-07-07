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

  formatters_by_ft = {
    sh = { "shfmt" },
    zsh = { "shfmt" },
    bash = { "shfmt" },
  },

  tools = { "shfmt", "shellcheck" },

  treesitter = { "bash", "zsh" },
}
