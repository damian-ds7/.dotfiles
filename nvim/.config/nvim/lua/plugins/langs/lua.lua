return {
  lang {
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
        ---@type lspconfig.settings.lua_ls
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
            diagnostics = {
              globals = { "vim", "Snacks" },
            },
          },
        },
      },
    },

    tools = { "stylua" },

    treesitter = { "lua", "luadoc", "luap" },
  },
  plugin {
    src = "folke/lazydev.nvim",
    filetype = "lua",
    opts = {
      library = {
        { path = "nvim-lspconfig", words = { "lspconfig", "lsp", "servers" } },
      },
    },
  },
}
