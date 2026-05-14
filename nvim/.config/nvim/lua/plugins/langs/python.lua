local registry = require "core.lang_reg"

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

return {
  plugin {
    src = "nvim-neotest/neotest-python",
    filetype = "python",
  config = function() require "neotest-python" end,
  },
  plugin {
    src = "mfussenegger/nvim-dap-python",
    filetype = "python",
    config = function() require("nvim-dap-python").setup "debugpy-adapter" end,
  }
}
