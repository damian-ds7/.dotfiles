local registry = require "core.lang_reg"
local utils = require "utils.pack"

registry.register {
  tools = { "rust_analyzer" },
  treesitter = { "rust", "ron" },
  neotest_adapters = {
    ["rustaceanvim.neotest"] = {},
  },
}

utils.add({ src = "https://github.com/mrcjkb/rustaceanvim", version = vim.version.range "8.*" }, function()
  local codelldb = vim.fn.exepath "codelldb"
  local codelldb_lib_ext = io.popen("uname"):read "*l" == "Linux" and ".so" or ".dylib"
  local library_path = vim.fn.expand("$MASON/opt/lldb/lib/liblldb" .. codelldb_lib_ext)

  ---@type rustaceanvim.Opts
  local opts = {
    tools = {
      float_win_config = {
        border = "rounded",
      },
    },
    server = {
      on_attach = function(_, bufnr)
        if vim.lsp.inlay_hint then vim.lsp.inlay_hint.enable(true, { bufnr = bufnr }) end

        vim.keymap.set(
          "n",
          "<leader>ca",
          function() vim.cmd.RustLsp "codeAction" end,
          { desc = "Code Action", buffer = bufnr }
        )
        vim.keymap.set(
          "n",
          "<leader>dr",
          function() vim.cmd.RustLsp "debuggables" end,
          { desc = "Rust Debuggables", buffer = bufnr }
        )
      end,
      default_settings = {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true,
            loadOutDirsFromCheck = true,
            buildScripts = { enable = true },
          },
          checkOnSave = true,
          diagnostics = { enable = true },
          procMacro = { enable = true },
          files = {
            exclude = {
              ".direnv",
              ".git",
              ".jj",
              ".github",
              ".gitlab",
              "bin",
              "node_modules",
              "target",
              "venv",
              ".venv",
            },
            watcher = "client",
          },
        },
      },
    },
    dap = {
      adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, library_path),
    },
  }

  vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts)
end, "later")
