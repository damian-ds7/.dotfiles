local utils = require "utils.pack"

local function config()
  local capabilities = require("blink.cmp").get_lsp_capabilities()
  local registry = require("core.lang_reg").get_all()
  local servers = {}
  if registry.servers then servers = vim.tbl_deep_extend("force", servers, registry.servers) end
  for server, server_opts in pairs(servers) do
    local server_name = type(server) == "table" and server[1] or server
    server_opts.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server_opts.capabilities or {})
    vim.lsp.config(server_name, server_opts)
    vim.lsp.enable(server_name)
  end
end

utils.add(utils.gh "neovim/nvim-lspconfig", config, "later")
