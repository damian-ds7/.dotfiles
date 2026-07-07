return lang {
  servers = {
    luau_lsp = {
      mason_name = "luau-lsp",
      settings = {
        ["luau-lsp"] = {
          ignoreGlobs = { "**/*.d.luau" },
        },
      },
    },
  },

  formatters_by_ft = {
    luau = { "stylua_luau" },
  },

  formatters = {
    stylua_luau = {
      inherit = false,
      command = "stylua",
      args = { "--stdin-filepath", "$FILENAME", "--syntax", "luau", "-" },
    },
  },

  tools = { "stylua" },

  treesitter = { "luau" },
}
