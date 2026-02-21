return {
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    -- opts = {
    --   servers = {
    --     lua_ls = {
    --       on_init = function(client)
    --         if client.workspace_folders then
    --           local path = client.workspace_folders[1].name
    --           if path ~= vim.fn.stdpath "config" and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc")) then return end
    --         end
    --
    --         client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
    --           runtime = {
    --             version = "LuaJIT",
    --             path = { "lua/?.lua", "lua/?/init.lua" },
    --           },
    --           workspace = {
    --             checkThirdParty = false,
    --             library = vim.api.nvim_get_runtime_file("", true),
    --           },
    --         })
    --       end,
    --       settings = {
    --         Lua = {
    --           completion = {
    --             callSnippet = "Replace",
    --           },
    --         },
    --       },
    --     },
    --   },
    --   tools = {
    --     "stylua",
    --   },
    --   setup = {},
    -- },
    config = function(_, opts)
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local registry = require("core.lang_reg").get_all()

      opts.servers = opts.servers or {}

      if registry.servers then opts.servers = vim.tbl_deep_extend("force", opts.servers, registry.servers) end

      for server, server_opts in pairs(opts.servers) do
        local server_name = type(server) == "table" and server[1] or server

        server_opts.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server_opts.capabilities or {})
        vim.lsp.config(server_name, server_opts)
        vim.lsp.enable(server_name)
      end
    end,
  },
}
