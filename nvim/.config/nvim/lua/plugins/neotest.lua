local registry = require "core.lang_reg"

return plugin {
  src = "nvim-neotest/neotest",
  dependencies = { "nvim-neotest/nvim-nio", "nvim-lua/plenary.nvim" },
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
  config = function()
    local neotest_ns = vim.api.nvim_create_namespace "neotest"
    vim.diagnostic.config({
      virtual_text = {
        format = function(diagnostic)
          return diagnostic.message
            :gsub("\n", " ")
            :gsub("\t", " ")
            :gsub("%s+", " ")
            :gsub("^%s+", "")
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
  end,
  keys = {
    { "n", "<leader>t", "", desc = "+test" },
    {
      "n",
      "<leader>ta",
      function() require("neotest").run.attach() end,
      desc = "Attach to Test (Neotest)",
    },
    {
      "n",
      "<leader>tt",
      function() require("neotest").run.run(vim.fn.expand "%") end,
      desc = "Run File (Neotest)",
    },
    {
      "n",
      "<leader>tT",
      function() require("neotest").run.run(vim.uv.cwd()) end,
      desc = "Run All Test Files (Neotest)",
    },
    {
      "n",
      "<leader>tr",
      function() require("neotest").run.run() end,
      desc = "Run Nearest (Neotest)",
    },
    {
      "n",
      "<leader>tl",
      function() require("neotest").run.run_last() end,
      desc = "Run Last (Neotest)",
    },
    {
      "n",
      "<leader>ts",
      function() require("neotest").summary.toggle() end,
      desc = "Toggle Summary (Neotest)",
    },
    {
      "n",
      "<leader>to",
      function() require("neotest").output.open { enter = true, auto_close = true } end,
      desc = "Show Output (Neotest)",
    },
    {
      "n",
      "<leader>tO",
      function() require("neotest").output_panel.toggle() end,
      desc = "Toggle Output Panel (Neotest)",
    },
    {
      "n",
      "<leader>tS",
      function() require("neotest").run.stop() end,
      desc = "Stop (Neotest)",
    },
    {
      "n",
      "<leader>tw",
      function() require("neotest").watch.toggle(vim.fn.expand "%") end,
      desc = "Toggle Watch (Neotest)",
    },
    {
      "n",
      "<leader>td",
      function()
        pcall(vim.cmd.packadd, "nvim-dap")
        require("neotest").run.run { strategy = "dap" }
      end,
      desc = "Debug Nearest",
    },
  },
}
