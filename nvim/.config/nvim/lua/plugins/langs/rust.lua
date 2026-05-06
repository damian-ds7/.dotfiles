local registry = require "core.lang_reg"
local utils = require "utils.pack"

registry.register {
  tools = { "rust-analyzer" },
  treesitter = { "rust", "ron" },
  neotest_adapters = {
    ["rustaceanvim.neotest"] = {},
  },
}

vim.g.rustaceanvim = function()
  local codelldb = vim.fn.exepath "codelldb"
  local codelldb_lib_ext = io.popen("uname"):read "*l" == "Linux" and ".so" or ".dylib"
  local library_path = vim.fn.expand("$MASON/opt/lldb/lib/liblldb" .. codelldb_lib_ext)
  return {
    tools = { float_win_config = { border = "rounded" } },
    server = {
      on_attach = function(_, bufnr)
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

        vim.lsp.codelens.enable(true, { bufnr = bufnr })
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
      adapter = {
        type = "server",
        port = "${port}",
        executable = {
          command = codelldb,
          args = { "--liblldb", library_path, "--port", "${port}" },
        },
      },
    },
  }
end

utils.add({ src = utils.gh "mrcjkb/rustaceanvim", version = vim.version.range "8.*" }, function() end, "filetype:rust")
