local registry = require "core.lang_reg"
local utils = require "utils.pack"

local lang = {
  servers = {
    ruff = {
      on_attach = function(client) client.server_capabilities.hoverProvider = false end,
    },
    ty = {
      on_attach = function(client, bufnr)
        if client:supports_method "textDocument/inlayHint" then
          vim.defer_fn(function() vim.lsp.inlay_hint.enable(true, { bufnr = bufnr }) end, 100)
        end
      end,
    },
  },
  tools = { "debugpy" },
  treesitter = { "python" },
  formatters = {
    python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
  },
  neotest_adapters = {
    ["neotest-python"] = {
      dap = { adapter = "debugpy" },
    },
  },
}

registry.register(lang)

utils.add("https://github.com/nvim-neotest/neotest-python", function() require "neotest-python" end, "filetype:python")

utils.add(
  "https://github.com/mfussenegger/nvim-dap-python",
  function() require("dap-python").setup "debugpy-adapter" end,
  "filetype:python"
)
