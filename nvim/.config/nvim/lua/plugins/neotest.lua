local utils = require "utils.pack"
local registry = require "core.lang_reg"

utils.ensure "https://github.com/nvim-neotest/nvim-nio"
utils.ensure "https://github.com/nvim-lua/plenary.nvim"
utils.ensure "https://github.com/nvim-treesitter/nvim-treesitter"

utils.add("https://github.com/nvim-neotest/neotest", function()
  vim.cmd.packadd "nvim-nio"
  vim.cmd.packadd "plenary.nvim"
  vim.cmd.packadd "nvim-treesitter"

  local neotest_ns = vim.api.nvim_create_namespace "neotest"
  vim.diagnostic.config({
    virtual_text = {
      format = function(diagnostic)
        return diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
      end,
    },
  }, neotest_ns)

  local raw_adapters = registry.get_all().neotest_adapters or {}
  local final_adapters = {}

  for key, value in pairs(raw_adapters) do
    local module_name = type(key) == "number" and value or key
    local opts = type(value) == "table" and value or {}

    if value ~= false then
      local plugin_name = vim.split(module_name, ".", { plain = true })[1]
      pcall(vim.cmd.packadd, plugin_name)

      local ok, adapter = pcall(require, module_name)
      if ok then
        if type(adapter) == "function" then
          adapter = adapter(opts)
        elseif type(adapter) == "table" and adapter.setup then
          adapter.setup(opts)
        end

        table.insert(final_adapters, adapter)
      end
    end
  end

  require("neotest").setup {
    adapters = final_adapters,
    status = { virtual_text = true },
    output = { enabled = true, open_on_run = "short" },
    quickfix = {
      enabled = true,
      open = false,
    },
    floating = {
      border = "rounded",
      max_height = 0.6,
      max_width = 0.6,
      options = {},
    },
    consumers = {
      notify = function(client)
        client.listeners.results = function(_, results, partial)
          if partial then return end

          local total = 0
          local passed = 0
          for _, r in pairs(results) do
            total = total + 1
            if r.status == "passed" then passed = passed + 1 end
          end

          vim.notify(passed .. "/" .. total .. " tests passed.")
        end
      end,
    },
  }
end, "event:BufReadPost,BufWritePost,BufNewFile")

-- Keymaps (Wrapped in require to trigger loading)
vim.keymap.set("n", "<leader>t", "", { desc = "+test" })
vim.keymap.set("n", "<leader>ta", function() require("neotest").run.attach() end, { desc = "Attach to Test (Neotest)" })
vim.keymap.set(
  "n",
  "<leader>tt",
  function() require("neotest").run.run(vim.fn.expand "%") end,
  { desc = "Run File (Neotest)" }
)
vim.keymap.set(
  "n",
  "<leader>tT",
  function() require("neotest").run.run(vim.uv.cwd()) end,
  { desc = "Run All Test Files (Neotest)" }
)
vim.keymap.set("n", "<leader>tr", function() require("neotest").run.run() end, { desc = "Run Nearest (Neotest)" })
vim.keymap.set("n", "<leader>tl", function() require("neotest").run.run_last() end, { desc = "Run Last (Neotest)" })
vim.keymap.set(
  "n",
  "<leader>ts",
  function() require("neotest").summary.toggle() end,
  { desc = "Toggle Summary (Neotest)" }
)
vim.keymap.set(
  "n",
  "<leader>to",
  function() require("neotest").output.open { enter = true, auto_close = true } end,
  { desc = "Show Output (Neotest)" }
)
vim.keymap.set(
  "n",
  "<leader>tO",
  function() require("neotest").output_panel.toggle() end,
  { desc = "Toggle Output Panel (Neotest)" }
)
vim.keymap.set("n", "<leader>tS", function() require("neotest").run.stop() end, { desc = "Stop (Neotest)" })
vim.keymap.set(
  "n",
  "<leader>tw",
  function() require("neotest").watch.toggle(vim.fn.expand "%") end,
  { desc = "Toggle Watch (Neotest)" }
)

-- Debug Keymap (DAP Integration)
vim.keymap.set("n", "<leader>td", function()
  pcall(vim.cmd.packadd, "nvim-dap")
  require("neotest").run.run { strategy = "dap" }
end, { desc = "Debug Nearest" })
