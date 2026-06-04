return lang {
  servers = {
    lua_ls = {
      mason_name = "lua-language-server",
      on_attach = function(_, buf)
        -- HACK: enabling inlay hints won't work in LspAttach, needs to be delayed
        vim.defer_fn(
          function() vim.lsp.inlay_hint.enable(true, { bufnr = buf }) end,
          100
        )
      end,
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
            path = vim.split(package.path, ";"),
          },
          diagnostics = {
            globals = { "vim", "Snacks" },
          },
          workspace = {
            library = { vim.env.VIMRUNTIME },
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
        },
      },
    },
  },

  tools = { "stylua" },

  treesitter = { "lua", "luadoc", "luap" },
}
