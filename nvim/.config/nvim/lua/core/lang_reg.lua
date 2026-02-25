local M = {
  servers = {
    lua_ls = {
      on_init = function(client)
        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if path ~= vim.fn.stdpath "config" and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc")) then return end
        end

        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
          runtime = {
            version = "LuaJIT",
            path = { "lua/?.lua", "lua/?/init.lua" },
          },
          workspace = {
            checkThirdParty = false,
            library = vim.api.nvim_get_runtime_file("", true),
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
    bashls = {
      filetypes = { "bash", "zsh", "sh" },
      settings = {
        bashIde = {
          shellcheckPath = vim.fn.stdpath "data" .. "/mason/bin/shellcheck",
        },
      },
    },
  },
  tools = { "stylua", "lua-language-server", "bash-language-server", "shfmt", "shellcheck" },
  treesitter = { "lua", "luadoc", "luap", "bash", "zsh" },
}

function M.register(lang)
  if lang.servers then M.servers = vim.tbl_deep_extend("force", M.servers, lang.servers) end

  if lang.tools then
    for _, tool in ipairs(lang.tools) do
      table.insert(M.tools, tool)
    end
  end

  if lang.treesitter then
    for _, parser in ipairs(lang.treesitter) do
      table.insert(M.treesitter, parser)
    end
  end
end

function M.get_all() return M end

return M
