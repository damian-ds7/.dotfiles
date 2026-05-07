local registry = require "core.lang_reg"
local utils = require "utils.pack"

registry.register {
  tools = { "rust-analyzer" },
  treesitter = { "rust", "ron" },
  neotest_adapters = {
    ["rustaceanvim.neotest"] = {},
  },
}

local setup_keymaps = function(bufnr)
  vim.keymap.set(
    "n",
    "<leader>ca",
    function() vim.cmd.RustLsp "codeAction" end,
    { desc = "LSP: Code Action", buffer = bufnr }
  )
  vim.keymap.set(
    "n",
    "<leader>cd",
    function() vim.cmd.RustLsp { "renderDiagnostic", "current" } end,
    { desc = "LSP: Explain Error", buffer = bufnr }
  )
  vim.keymap.set(
    "n",
    "<leader>ce",
    function() vim.cmd.RustLsp { "explainError", "current" } end,
    { desc = "LSP: Explain Error", buffer = bufnr }
  )
  vim.keymap.set("n", "K", function() vim.cmd.RustLsp { "hover", "actions" } end, { silent = true, buffer = bufnr })
  vim.keymap.set(
    "n",
    "<leader>dr",
    function() vim.cmd.RustLsp "debuggables" end,
    { desc = "Rust Debuggables", buffer = bufnr }
  )
end

vim.g.rustaceanvim = function()
  local codelldb = vim.fn.exepath "codelldb"
  local codelldb_lib_ext = io.popen("uname"):read "*l" == "Linux" and ".so" or ".dylib"
  local library_path = vim.fn.expand("$MASON/opt/lldb/lib/liblldb" .. codelldb_lib_ext)
  return {
    tools = { float_win_config = { border = "rounded" } },
    server = {
      on_attach = function(_, bufnr)
        setup_keymaps(bufnr)
        vim.lsp.codelens.enable(true)
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
