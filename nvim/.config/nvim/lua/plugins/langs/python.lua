local registry = require "core.lang_reg"
local utils = require "utils.pack"

local lang = {
  servers = {
    ruff = {
      on_attach = function(client) client.server_capabilities.hoverProvider = false end,
      init_options = {
        settings = {
          configurationPreference = "filesystemFirst",
          configuration = vim.fn.stdpath "config" .. "/tools/ruff.toml",
        },
      },
    },
    ty = {},
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

utils.add(
  utils.gh "nvim-neotest/neotest-python",
  function() require "neotest-python" end,
  "filetype:python"
)

utils.add(
  utils.gh "mfussenegger/nvim-dap-python",
  function() require("dap-python").setup "debugpy-adapter" end,
  "filetype:python"
)
