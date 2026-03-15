local registry = require "core.lang_reg"

local lang = {
  servers = {
    ruff = {
      on_attach = function(client) client.server_capabilities.hoverProvider = false end,
    },
    pyrefly = {
      on_attach = function(client, bufnr)
        if client:supports_method "textDocument/inlayHint" then
          vim.defer_fn(function() vim.lsp.inlay_hint.enable(true, { bufnr = bufnr }) end, 100)
        end
      end,
      settings = {
        python = {
          pyrefly = {
            displayTypeErrors = "force-on",
          },
        },
      },
    },
  },

  tools = { "debugpy" },

  treesitter = { "python" },
}

registry.register(lang)

return {
  {
    "nvim-neotest/neotest-python",
    ft = "python",
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    keys = {
      { "<leader>dPt", function() require("dap-python").test_method() end, desc = "Debug Method", ft = "python" },
      { "<leader>dPc", function() require("dap-python").test_class() end, desc = "Debug Class", ft = "python" },
    },
    config = function() require("dap-python").setup "debugpy-adapter" end,
  },
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    ft = "python",
    keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" } },
    config = function()
      local original_notify = vim.notify

      require("venv-selector").setup {}

      vim.schedule(function()
        if type(vim.notify) ~= "function" and type(original_notify) == "function" then vim.notify = original_notify end
      end)
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
      },
    },
  },
}
