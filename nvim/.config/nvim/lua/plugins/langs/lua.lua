local registry = require "core.lang_reg"

local lang = {
  servers = {
    lua_ls = {
      mason_name = "lua-language-server",
      on_attach = function(client, buf)
        -- HACK: enabling inlay hints won't work in LspAttach, needs to be delayed
        vim.defer_fn(
          function() vim.lsp.inlay_hint.enable(true, { bufnr = buf }) end,
          100
        )
      end,
      on_init = function(client)
        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if
            path ~= vim.fn.stdpath "config"
            and (
              vim.uv.fs_stat(path .. "/.luarc.json")
              or vim.uv.fs_stat(path .. "/.luarc.jsonc")
            )
          then
            return
          end
        end

        client.config.settings.Lua =
          vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = {
              version = "LuaJIT",
              path = { "lua/?.lua", "lua/?/init.lua" },
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
                -- Depending on the usage, you might want to add additional paths
                -- here.
                -- '${3rd}/luv/library',
                -- '${3rd}/busted/library',
              },
            },
          })
      end,
      settings = {
        Lua = {
          completion = {
            callSnippet = "Replace",
          },
        },
      },
    },
  },

  tools = { "stylua" },

  treesitter = { "lua", "luadoc", "luap" },
}

registry.register(lang)
